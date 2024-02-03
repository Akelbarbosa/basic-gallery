//
//  ImageDetailRouter.swift
//  basic-gallery
//
//  Created by Akel Barbosa on 5/02/24.
//

import Foundation
import UIKit

//MARK: - Protocols
protocol ImageDetailRouterInput {
    func createModule() -> UIViewController
    func presentImageData(image: ImageEntity)
    func imageDeleted()
    
}

protocol ImageDetailRouterDelegate: AnyObject {
    func imageDeleted(index: Int)
}

//MARK: - Class
class ImageDetailRouter: ImageDetailRouterInput {
    weak var viewController: UIViewController?
    weak var delegate: ImageDetailRouterDelegate?
    
    var index: Int
    var image: ImageEntity
    
    //MARK: - Init
    init(index: Int, image: ImageEntity) {
        self.index = index
        self.image = image
    }
    
    //MARK: - Create View
    func createModule() -> UIViewController {
        
        let presenter = ImageDetailPresenter(router: self, image: image)
        let view = ImageDetailView(presenter: presenter)
        
        presenter.delegate = view
        viewController = view
        return view
    }
    
    func imageDeleted() {
        DispatchQueue.main.async {[weak self] in
            self?.viewController?.navigationController?.popViewController(animated: true)
            self?.delegate?.imageDeleted(index: self?.index ?? 0)
        }

    }
    
    func presentImageData(image: ImageEntity) {
        
        DispatchQueue.main.async {[weak self] in
            let view = ImageDetailInfoSubView(imageData: image)
            
            self?.viewController?.navigationController?.present(view, animated: true)
        }

    }
    
    
}
