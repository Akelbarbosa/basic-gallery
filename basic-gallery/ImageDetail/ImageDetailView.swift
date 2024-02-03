//
//  ImageDetailView.swift
//  basic-gallery
//
//  Created by Akel Barbosa on 5/02/24.
//

import UIKit

class ImageDetailView: UIViewController {

    var presenter: ImageDetailPresenterInput
    
    //MARK: - Init
    init(presenter: ImageDetailPresenterInput) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Views
 
    private let imageView: UIImageView = {
        let image = UIImageView()
        return image
    }()
    
    private let deleteImageButton: UIButton =  {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let infoImageButton: UIButton =  {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private var initialFrame: CGRect?
    private var originalTransform: CGAffineTransform?
    private var isZoomed = false {
        didSet {
            if isZoomed {
                navigationController?.setNavigationBarHidden(true, animated: true)
            } else {
                navigationController?.setNavigationBarHidden(false, animated: true)
            }
        }
    }

    
    //MARK: - Configure Views
    private func configureViews() {
        
        //Info
        infoImageButton.setImage(UIImage(systemName: "info.circle"), for: .normal)
        infoImageButton.setTitleColor(.systemRed, for: .normal)
        infoImageButton.tintColor = .systemBlue
        infoImageButton.addTarget(self, action: #selector(infoImageButtonAction), for: .touchUpInside)
        

        // Delete
        deleteImageButton.setImage(UIImage(systemName: "trash"), for: .normal)
        deleteImageButton.addTarget(self, action: #selector(deletePhotoButtonAction), for: .touchUpInside)
        deleteImageButton.tintColor = .systemRed
        
        navigationItem.rightBarButtonItems = [UIBarButtonItem(customView: deleteImageButton),
                                              UIBarButtonItem(customView: infoImageButton)]
        
        //ImageView
        view.addSubview(imageView)
        imageView.frame = view.bounds
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true
        
        
        
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
        pinchGesture.delegate = self
        imageView.addGestureRecognizer(pinchGesture)

        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        panGesture.delegate = self
        imageView.addGestureRecognizer(panGesture)

        let doubleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
        doubleTapRecognizer.numberOfTapsRequired = 2
        imageView.addGestureRecognizer(doubleTapRecognizer)
    }
    
    private func configureViewController() {
        view.backgroundColor = .systemBackground
    }
    

    //MARK: - Main
    deinit {
        debugPrint("\(self) deallocate")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewController()
        configureViews()
        presenter.viewDidLoad()
    }
    
    //MARK: - Actions 
    @objc func handlePinch(_ gestureRecognizer: UIPinchGestureRecognizer) {
        guard let view = gestureRecognizer.view else { return }

        if gestureRecognizer.state == .began {
            initialFrame = view.frame
            originalTransform = view.transform
        }

        let scale = gestureRecognizer.scale
        view.transform = (originalTransform ?? CGAffineTransform.identity).scaledBy(x: scale, y: scale)

        // Verificar si hay zoom basado en el estado del transform
        isZoomed = view.transform != CGAffineTransform.identity

        if gestureRecognizer.state == .ended {
            let scaleFactor = min(view.bounds.width / initialFrame!.width, view.bounds.height / initialFrame!.height)
            UIView.animate(withDuration: 0.3) {
                view.transform = CGAffineTransform.identity.scaledBy(x: scaleFactor, y: scaleFactor)
            }
        }
    }


    @objc func handlePan(_ gestureRecognizer: UIPanGestureRecognizer) {
        guard isZoomed, let view = gestureRecognizer.view else { return }

        let translation = gestureRecognizer.translation(in: view)

        if gestureRecognizer.state == .began || gestureRecognizer.state == .changed {
            var newCenter = view.center

            let panSpeed: CGFloat = 1.5
            let scaledTranslation = CGPoint(x: translation.x * panSpeed, y: translation.y * panSpeed)

            newCenter.x += scaledTranslation.x
            newCenter.y += scaledTranslation.y

            let halfWidth = view.bounds.width / 2
            let halfHeight = view.bounds.height / 2

            let minX = view.superview!.bounds.width / 2 - halfWidth
            let maxX = view.superview!.bounds.width / 2 + halfWidth

            let minY = view.superview!.bounds.height / 2 - halfHeight
            let maxY = view.superview!.bounds.height / 2 + halfHeight

            newCenter.x = min(maxX, max(minX, newCenter.x))
            newCenter.y = min(maxY, max(minY, newCenter.y))

            view.center = newCenter

            gestureRecognizer.setTranslation(.zero, in: view.superview)
        }
    }

    @objc func handleDoubleTap(_ recognizer: UITapGestureRecognizer) {
        UIView.animate(withDuration: 0.3) {
            if self.isZoomed {
                self.imageView.transform = .identity
                self.imageView.frame = self.view.bounds
                
                self.isZoomed = false
            } else {
                
                let zoomScale: CGFloat = 4.0
                let newTransform = self.imageView.transform.scaledBy(x: zoomScale, y: zoomScale)
                self.imageView.transform = newTransform

                let touchPoint = recognizer.location(in: self.imageView)
                let newCenter = CGPoint(x: self.imageView.bounds.width / 2,
                                        y: self.imageView.bounds.height / 2 )
                
                self.imageView.center = newCenter

                self.isZoomed = true
            }
        }
    }
    
    @objc func deletePhotoButtonAction() {
        confirmDeleteImage()
    }
    
    private func confirmDeleteImage() {
        let alertController = UIAlertController(title: "Delete image", message: "Are you sure you want to delete this image?", preferredStyle: .alert)

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)

        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            self?.presenter.deleteImage()
        }
        alertController.addAction(deleteAction)

        present(alertController, animated: true, completion: nil)
    }
    
    @objc func infoImageButtonAction() {
        presenter.presentDetail()
    }

}


//MARK: - Presenter Delegate
extension ImageDetailView: ImageDetailPresenterDelegate {
    func configureView(image: UIImage, title: String) {
        DispatchQueue.main.async {[weak self] in
            debugPrint(image)
            self?.imageView.image = image
            self?.title = title
        }
    }

    
}

//MARK: - Extension ScrollView
extension ImageDetailView: UIGestureRecognizerDelegate  {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    

}
