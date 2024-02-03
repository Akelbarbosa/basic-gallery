//
//  GalleryRouter.swift
//  basic-gallery
//
//  Created by Akel Barbosa on 3/02/24.
//

import Foundation
import UIKit
import PhotosUI

//MARK: - Protocols
protocol GalleryRouterInput {

    func presentSelectImages()
    
    func goToDetailView(with image: ImageEntity, at index: Int)
}

protocol GalleryRouterDelegate: AnyObject {

    func imageDetailViewImageDeleted(index: Int)
}

//MARK: - Class
class GalleryRouter: GalleryRouterInput {
    weak var viewController: UIViewController?
    weak var delegate: GalleryRouterDelegate?
    
    var presenter: GalleryPresenter?
    
    func createModule() -> UIViewController {
        let interactor = GalleryInteractor()
        let presenter = GalleryPresenter(interactor: interactor, router: self)
        let view = GalleryView(presenter: presenter)
        
        interactor.delegate = presenter
        presenter.delegate = view
        
        self.presenter = presenter
        viewController = view
        delegate = presenter
        
        return view
    }
    
    
    func presentSelectImages() {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        configuration.selectionLimit = 10

        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = presenter
        viewController?.present(picker, animated: true, completion: nil)
    }
    
    func goToDetailView(with image: ImageEntity, at index: Int) {
        let detail = ImageDetailRouter(index: index, image: image)
        detail.delegate = self
        
        viewController?.navigationController?.pushViewController(detail.createModule(), animated: true)
    }
    

}

//MARK: - Detail View Delegate
extension GalleryRouter: ImageDetailRouterDelegate {
    func imageDeleted(index: Int) {
        delegate?.imageDetailViewImageDeleted(index: index)
    }
}
