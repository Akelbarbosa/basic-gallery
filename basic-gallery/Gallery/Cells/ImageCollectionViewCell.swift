//
//  ImageCollectionViewCell.swift
//  basic-gallery
//
//  Created by Akel Barbosa on 3/02/24.
//

import Foundation
import UIKit

class ImageCollectionViewCell: UICollectionViewCell {
    static let identifer = "ImageCollectionViewCell"
    
    //MARK: - Views
    private let imageView: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    //MARK: - Configure Views
    private func setupImageView() {
        
        // Image View
        addSubview(imageView)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    
    //MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupImageView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupImageView()
    }
    
    
    //MARK: - Configure Cell
    func configure(_ image: UIImage) {
        imageView.image = image
    }

}
