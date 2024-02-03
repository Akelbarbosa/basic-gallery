//
//  GalleryInteractor.swift
//  basic-gallery
//
//  Created by Akel Barbosa on 3/02/24.
//

import Foundation
import UIKit


//MARK: - Protocols
protocol GalleryInteractorInput {
    func saveImageUrl(urlPath: [String])
    
    func getImageFromUrlPath() -> [ImageEntity]
    
    func deleteAllUrlPaths()
    func deleteUrlPaths(urlsToDelete: [String])
}

protocol GalleryInteractorDelegate: AnyObject {
    func updateUrlPathSaved()
}

//MARK: - Class
class GalleryInteractor: GalleryInteractorInput {
    private let imagesKey = "imagesKey"
    weak var delegate: GalleryInteractorDelegate?
    
    
    //MARK: - Methods
    var getListImagesSaved: [String] {
        return UserDefaults.standard.stringArray(forKey: imagesKey) ?? []
    }
    
    func saveImageUrl(urlPath: [String]) {
        var existingUrls = getListImagesSaved

        let uniqueUrls = urlPath.filter { !existingUrls.contains($0) }

        existingUrls.append(contentsOf: uniqueUrls)

        UserDefaults.standard.set(existingUrls, forKey: imagesKey)
        
    }
    
    
    func deleteAllUrlPaths() {
        UserDefaults.standard.removeObject(forKey: imagesKey)
        delegate?.updateUrlPathSaved()
    }

    func deleteUrlPaths(urlsToDelete: [String]) {
        let existingUrls = getListImagesSaved

        let updatedUrls = existingUrls.filter { !urlsToDelete.contains($0) }

        // Guardar las URLPaths actualizadas
        UserDefaults.standard.set(updatedUrls, forKey: imagesKey)
    }
    
    func getImageFromUrlPath() -> [ImageEntity] {
        return getListImagesSaved.compactMap { element in
            guard let image = loadImage(from: element) else { return nil}
            return image
        }
        
    }
    
    private func loadImage(from localURL: String) -> ImageEntity? {
        guard let url = URL(string: localURL) else { return nil}
        do {
            let imageData = try Data(contentsOf: url)
            guard let image = UIImage(data: imageData) else { return nil }
            let imageEntity = ImageEntity(image: image, 
                                          urlPath: localURL,
                                          creationDate: "",
                                          name: "",
                                          size: "")
                    
            return imageEntity
        } catch {
            print("Error al cargar la imagen desde la URL local: \(error.localizedDescription)")
            return nil
        }
    }

    
    
}
