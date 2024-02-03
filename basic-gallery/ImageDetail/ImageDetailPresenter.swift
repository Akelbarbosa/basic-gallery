//
//  ImageDetailPresenter.swift
//  basic-gallery
//
//  Created by Akel Barbosa on 5/02/24.
//

import Foundation
import UIKit

//MARK: - Protocol
protocol ImageDetailPresenterInput {
    func viewDidLoad()
    func deleteImage()
    func presentDetail()
}

protocol ImageDetailPresenterDelegate: AnyObject {
    func configureView(image: UIImage, title: String)
}

//MARK: - Class
class ImageDetailPresenter: ImageDetailPresenterInput {
    
    var router: ImageDetailRouterInput?
    var image: ImageEntity
    
    weak var delegate: ImageDetailPresenterDelegate?
    
    //MARK: - Init
    init(router: ImageDetailRouterInput? = nil, image: ImageEntity) {
        self.router = router
        self.image = image
    }
    
    //MARK: - Methods
    func viewDidLoad() {
        delegate?.configureView(image: image.image, title: image.name)
    }
        
    func deleteImage() {
        router?.imageDeleted()
    }
    
    func presentDetail() {
        router?.presentImageData(image: image)
    }
}
