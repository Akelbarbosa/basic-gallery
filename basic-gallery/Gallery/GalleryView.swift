//
//  GalleryView.swift
//  basic-gallery
//
//  Created by Akel Barbosa on 3/02/24.
//

import UIKit
import PhotosUI

class GalleryView: UIViewController {
    var presenter: GalleryPresenterInput
    
    //MARK: - Init
    init(presenter: GalleryPresenterInput) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        debugPrint("\(self) deallocate")
    }
    
    //MARK: - Views
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        return collectionView
    }()
    
    
    private let addImageButton: UIButton = {
        var configuration = UIButton.Configuration.filled()
        let button = UIButton()
        button.configuration = configuration
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
        
    }()
    
    private let deletePhotoButton: UIButton =  {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let emptyGalleryLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var activityIndicator: UIActivityIndicatorView?
    
    var spacing: CGFloat {
        return view.frame.width * 0.02
    }
    
    //MARK: - Configure Views
    private func configureViews() {
        
        //Log Out Button
        deletePhotoButton.setTitle("Delete All", for: .normal)
        deletePhotoButton.setTitleColor(.systemRed, for: .normal)
        deletePhotoButton.addTarget(self, action: #selector(deletePhotoButtonAction), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: deletePhotoButton)
        
        //Collection Views
        view.addSubview(collectionView)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .clear
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        collectionView.register(ImageCollectionViewCell.self, forCellWithReuseIdentifier: ImageCollectionViewCell.identifer)
        collectionView.backgroundColor = .clear
        
        let layout = UICollectionViewFlowLayout()
        
        let cellSize = (view.frame.width - spacing) / 3
        layout.itemSize = CGSize(width: cellSize, height: cellSize)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = spacing / 2
        
        collectionView.collectionViewLayout = layout
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        collectionView.addGestureRecognizer(longPressGesture)

        
        // Empty Label
        collectionView.addSubview(emptyGalleryLabel)
        emptyGalleryLabel.font = UIFont.preferredFont(forTextStyle: .title3)
        emptyGalleryLabel.text = "The gallery is empty."
        emptyGalleryLabel.isHidden = true
        
       
        NSLayoutConstraint.activate([
            emptyGalleryLabel.centerXAnchor.constraint(equalTo: collectionView.centerXAnchor),
            emptyGalleryLabel.centerYAnchor.constraint(equalTo: collectionView.centerYAnchor)
        ])
        
        // Button Add
        view.addSubview(addImageButton)
        
        addImageButton.configuration?.image = UIImage(systemName: "plus")
        addImageButton.configuration?.baseBackgroundColor = .green
        addImageButton.configuration?.cornerStyle = .capsule
        addImageButton.addTarget(self, action: #selector(addImageButtonAction), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            addImageButton.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: -50),
            addImageButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50),
            addImageButton.heightAnchor.constraint(equalToConstant: 50),
            addImageButton.widthAnchor.constraint(equalToConstant: 50),
        ])
        
        // Button
        
        
    }
    
    private func configureViewController() {
        view.backgroundColor = .systemGroupedBackground
        title = "Gallery"
        navigationController?.navigationBar.prefersLargeTitles = true

    }
    //MARK: - Main
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewController()
        configureViews()
        presenter.viewDidLoad()
    }
    
    //MARK: - Actions
    @objc func deletePhotoButtonAction() {
        presenter.deletePhotos()
    }
    
    @objc func addImageButtonAction() {
        presenter.presentSelectImage()
    }
    
    private func activateActivityIndicator() {
        let activityIndicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.large)
        activityIndicator.hidesWhenStopped = true
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false

        
        collectionView.addSubview(activityIndicator)
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: collectionView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: collectionView.centerYAnchor)
        ])
        
        activityIndicator.startAnimating()
        self.activityIndicator = activityIndicator

    }
    
    private func desactivateActivityIndicator() {
        activityIndicator?.stopAnimating()
        activityIndicator?.removeFromSuperview()
        activityIndicator = nil
    }
    
    @objc func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began else { return }

        let point = gesture.location(in: collectionView)

        if let indexPath = collectionView.indexPathForItem(at: point) {
            let alertController = UIAlertController(title: "Options", message: nil, preferredStyle: .actionSheet)

            let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
                self?.presenter.deleteImage(at: indexPath.row)
            }

            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

            alertController.addAction(deleteAction)
            alertController.addAction(cancelAction)

            present(alertController, animated: true, completion: nil)
        }
    }

    
}

//MARK: - Collection Views Delegate
extension GalleryView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        presenter.imagesList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        presenter.managerCell(collectionView, indexPath: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        presenter.goToImageDetail(imageIndex: indexPath.row)
    }
}


//MARK: - Presenter Delagate.
extension GalleryView: GalleryPresenterDelegate {
    func showEmptyMessage(show: Bool) {
        DispatchQueue.main.async {[weak self] in
            self?.emptyGalleryLabel.isHidden = show
            self?.deletePhotoButton.isHidden = !show
        }
    }
    
    func startActivityIndicator() {
        DispatchQueue.main.async {[weak self] in
            self?.activateActivityIndicator()
        }
    }
    
    func stopActivityIndicator() {
        DispatchQueue.main.async {[weak self] in
            self?.desactivateActivityIndicator()
        }
    }
    
    func reloadCollectionView() {
        DispatchQueue.main.async {[weak self] in
            self?.collectionView.reloadData()
        }
    }
    
    
}
