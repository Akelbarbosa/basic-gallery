//
//  ImageDetailInfoSubView.swift
//  basic-gallery
//
//  Created by Akel Barbosa on 6/02/24.
//

import UIKit

class ImageDetailInfoSubView: UIViewController {

    var imageData: ImageEntity
    
    //MARK: - Init
    init(imageData: ImageEntity) {
        self.imageData = imageData
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Views
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let sizeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let creationDateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    //MARK: - ConfigureViews
    private func configureViews() {
        //Stack View
        view.addSubview(stackView)
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.backgroundColor = .secondarySystemGroupedBackground
        stackView.layer.cornerRadius = 10
        stackView.layoutMargins = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        stackView.isLayoutMarginsRelativeArrangement = true
        
        NSLayoutConstraint.activate([
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9)
        ])
        
        //Name
        stackView.addArrangedSubview(nameLabel)
        nameLabel.font = UIFont.preferredFont(forTextStyle: .title3)
        nameLabel.textAlignment = .left
        nameLabel.numberOfLines = 0
        nameLabel.attributedText = formatAttributedString(baseString: "Name: ", data: imageData.name)
        
        //creation
        stackView.addArrangedSubview(creationDateLabel)
        creationDateLabel.font = UIFont.preferredFont(forTextStyle: .title3)
        creationDateLabel.textAlignment = .left
        creationDateLabel.numberOfLines = 0
        creationDateLabel.attributedText = formatAttributedString(baseString: "Creation date: ", data: imageData.creationDate)
        
        // size
        stackView.addArrangedSubview(sizeLabel)
        sizeLabel.font = UIFont.preferredFont(forTextStyle: .title3)
        sizeLabel.textAlignment = .left
        sizeLabel.text = "Size:  \(imageData.size) Mb"
        sizeLabel.numberOfLines = 0
        sizeLabel.attributedText = formatAttributedString(baseString: "Size: ", data: " \(imageData.size) Mb")
        // Spacer
        stackView.addArrangedSubview(UIView())
    }
    
    private func configureViewController() {
        view.backgroundColor = .systemGroupedBackground
    }
    
    
    //MARK: - Main
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewController()
        configureViews()
    }
    
    //MARK: - Actions
    private func formatAttributedString(baseString: String, data: String) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: baseString, attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 20)])

        let normalText = NSAttributedString(string: data, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20)])
        
        attributedString.append(normalText)

        return attributedString
    }

}
