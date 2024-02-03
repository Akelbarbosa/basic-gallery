//
//  GalleryPresenter.swift
//  basic-gallery
//
//  Created by Akel Barbosa on 3/02/24.
//

import Foundation
import UIKit
import PhotosUI


//MARK: - Protocols
protocol GalleryPresenterInput {
    var imagesList: [ImageEntity] { get set }
    
    func viewDidLoad()
    
    func managerCell(_ collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell
    
    func presentSelectImage()
    
    func finishSelectImage()
    
    func deleteImage(at: Int)
    
    func deletePhotos()
    
    func goToImageDetail(imageIndex: Int)
    
}

protocol GalleryPresenterDelegate: AnyObject {
    func startActivityIndicator()
    func stopActivityIndicator()
    
    func showEmptyMessage(show: Bool)
    
    func reloadCollectionView()
}

//MARK: - Class
class GalleryPresenter: GalleryPresenterInput {
    
    var interactor: GalleryInteractorInput
    var router: GalleryRouterInput
    weak var delegate: GalleryPresenterDelegate?
    
    
    //Images' List
    var imagesList: [ImageEntity] = [] {
        didSet {
            validateEmptyMessage()
        }
    }
    
    //MARK: - Init

    init(interactor: GalleryInteractorInput, router: GalleryRouterInput) {
        self.interactor = interactor
        self.router = router
    }
    
    
    //MARK: - Methods
    func viewDidLoad() {
        delegate?.startActivityIndicator()
        
        getImageFromUrlPath()
        
        finishSelectImage()
    }
    
    private func getImageFromUrlPath() {
        let image  = interactor.getImageFromUrlPath()
        let imageData: [ImageEntity] = image.compactMap{ element in
            guard let url  = element.urlPath, let urlPath = URL(string: url) else { return nil }
            let data = getImageFileInfo(for: urlPath)
            
            return ImageEntity(image: element.image,
                               urlPath: element.urlPath,
                               creationDate: data.creation,
                               name: data.name,
                               size: data.size)
        }
        
        imagesList = imageData
    }
    
    private func validateEmptyMessage() {
        let isImageListEmpty = imagesList.isEmpty
        delegate?.showEmptyMessage(show: !isImageListEmpty)
    }
    
    func presentSelectImage() {
        router.presentSelectImages()
    }
        
    
    func managerCell(_ collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCollectionViewCell.identifer, for: indexPath) as? ImageCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        let image = imagesList[indexPath.row].image
        
        cell.configure(image)
        
        return cell
    }
    
    func finishSelectImage() {
        delegate?.stopActivityIndicator()
        delegate?.reloadCollectionView()
        
    }
    
    private func saveImageAsUrlPath(images: [String]) {
        let urlPaths: [String] = images.compactMap{$0}
        interactor.saveImageUrl(urlPath: urlPaths)
    }
    

    func getTemporaryCopyImageURL(for image: UIImage, completion: @escaping (URL?) -> Void) {
        guard let imageData = image.pngData() else {
            completion(nil)
            return
        }

        let temporaryDirectory = FileManager.default.temporaryDirectory
        let fileName = UUID().uuidString
        let fileURL = temporaryDirectory.appendingPathComponent(fileName)

        do {
            try imageData.write(to: fileURL)
            completion(fileURL)
        } catch {
            print("Error al escribir en el disco: \(error.localizedDescription)")
            completion(nil)
        }
    }
    
    func getImageFileInfo(for imageURL: URL) -> (name: String, size: String, creation: String) {
        var name: String = ""
        var size: String = ""
        var creation: String = ""
        
        do {
            let fileAttributes = try FileManager.default.attributesOfItem(atPath: imageURL.path)
            
            let fileName = imageURL.lastPathComponent
            
            if let fileSize = fileAttributes[.size] as? Int {
                let formattedSize = ByteCountFormatter.string(fromByteCount: Int64(fileSize), countStyle: .file)
                name = fileName
                size = formattedSize
            }
            
            if let creationDate = fileAttributes[.creationDate] as? Date {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                creation = dateFormatter.string(from: creationDate)
            }
        } catch {
            print("Error al obtener la información del archivo: \(error.localizedDescription)")
        }
        
        return (name, size, creation)
    }
    
    func deleteImage(at indexPath: Int) {
        let imageDeleted = imagesList.remove(at: indexPath)
        interactor.deleteUrlPaths(urlsToDelete: [imageDeleted.urlPath ?? ""])
        delegate?.reloadCollectionView()
    }

    func deletePhotos() {
        imagesList = []
        interactor.deleteAllUrlPaths()
    }
    
    func goToImageDetail(imageIndex: Int) {
        let image = imagesList[imageIndex]
        
        router.goToDetailView(with: image, at: imageIndex)
    }
    

    
}

//MARK: - Interactor Delegate
extension GalleryPresenter: GalleryInteractorDelegate {
    func updateUrlPathSaved() {
        delegate?.reloadCollectionView()
    }
    
    
}

//MARK: - Router Delegate
extension GalleryPresenter: GalleryRouterDelegate {
    func imageDetailViewImageDeleted(index: Int) {
        deleteImage(at: index)
    }
    
}

//MARK: - PHPicker Delegate
extension GalleryPresenter: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        var images: [UIImage] = []
        var urlPaths: [URL?] = []
        var imagesEntities: [ImageEntity] = []
        
        let group = DispatchGroup()

        for result in results {
            guard result.itemProvider.canLoadObject(ofClass: UIImage.self) else { continue }
            group.enter()

            result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] (image, error) in
                defer {
                    group.leave()
                }

                guard let image = image as? UIImage else { return }
                self?.getTemporaryCopyImageURL(for: image, completion: { url in
                    urlPaths.append(url)
                    guard let url = url,
                          let imageData = self?.getImageFileInfo(for: url) else { return }
                     
                    imagesEntities.append(ImageEntity(image: image,
                                                      urlPath: url.absoluteString,
                                                      creationDate: imageData.creation,
                                                      name: imageData.name,
                                                      size: imageData.size))
                })
                
                images.append(image)
            }
        }

        group.notify(queue: DispatchQueue.main) {[weak self] in
            self?.imagesList += imagesEntities

            self?.saveImageAsUrlPath(images: imagesEntities.compactMap{$0.urlPath})
            
            self?.delegate?.reloadCollectionView()
        }
        
        picker.dismiss(animated: true, completion: nil)
    }

}
