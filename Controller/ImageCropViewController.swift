//
//  CropViewController.swift
//  ImageSearch
//
//  Created by Екатерина Токарева on 25/02/2023.
//

import UIKit
import CropViewController

final class ImageCropViewController: UIViewController {
    
    private let imageView = UIImageView()
    private let imagePicker = UIImagePickerController()
    private var cropImage: UIImage?
    private var croppingStyle = CropViewCroppingStyle.default
    private var croppedRect = CGRect.zero
    private var croppedAngle = 0
    private var imageData: Image?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonTapped(sender:)))
        let shareButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(sharePhoto))
        navigationItem.rightBarButtonItems = [addButton, shareButton]
        navigationItem.rightBarButtonItems?[1].isEnabled = false
        imageView.isUserInteractionEnabled = true
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .green
        imageView.isHidden = false
        view.addSubview(imageView)
        let tapRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(didTapImageView))
        imageView.addGestureRecognizer(tapRecognizer)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        layoutImageView()
    }
    
    private func presentCropViewController() {
        guard let image = cropImage else { return }
        let imageToCrop: UIImage = image
        let cropViewController = CropViewController(image: imageToCrop)
        cropViewController.delegate = self
        present(cropViewController, animated: true, completion: nil)
    }
    
    private func updateImageViewWithImage(_ image: UIImage, fromCropViewController cropViewController: CropViewController) {
        cropImage = image
        imageView.image = image
        layoutImageView()
        navigationItem.rightBarButtonItems?[1].isEnabled = true
        imageView.isHidden = false
        cropViewController.dismiss(animated: true, completion: nil)
    }
    
    private func layoutImageView() {
        guard imageView.image != nil else { return }
        let padding: CGFloat = 20.0
        var viewFrame = self.view.bounds
        viewFrame.size.width -= padding * 2.0
        viewFrame.size.height -= padding * 2.0
        var imageFrame = CGRect.zero
        guard let image = imageView.image else { return }
        imageFrame.size = image.size
        if image.size.width > viewFrame.size.width || image.size.height > viewFrame.size.height {
            let scale = min(viewFrame.size.width / imageFrame.size.width, viewFrame.size.height / imageFrame.size.height)
            imageFrame.size.width *= scale
            imageFrame.size.height *= scale
            imageFrame.origin.x = (self.view.bounds.size.width - imageFrame.size.width) * 0.5
            imageFrame.origin.y = (self.view.bounds.size.height - imageFrame.size.height) * 0.5
            imageView.frame = imageFrame
        } else {
            self.imageView.frame = imageFrame;
            self.imageView.center = CGPoint(x: self.view.bounds.midX, y: self.view.bounds.midY)
        }
    }
    
    @objc private func didTapImageView() {
        let cropViewController = CropViewController(croppingStyle: self.croppingStyle, image: self.cropImage!)
        cropViewController.delegate = self
        let viewFrame = view.convert(imageView.frame, to: navigationController!.view)
        cropViewController.presentAnimatedFrom(self,
                                               fromImage: self.imageView.image,
                                               fromView: nil,
                                               fromFrame: viewFrame,
                                               angle: self.croppedAngle,
                                               toImageFrame: self.croppedRect,
                                               setup: { self.imageView.isHidden = true },
                                               completion: nil)
    }
    
    @objc private func addButtonTapped(sender: AnyObject) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let defaultAction = UIAlertAction(title: "Photo Gallery", style: .default) { (action) in
            self.croppingStyle = .default
            self.imagePicker.sourceType = .photoLibrary
            self.imagePicker.allowsEditing = false
            self.imagePicker.delegate = self
            self.imagePicker.modalPresentationStyle = .overCurrentContext
            self.present(self.imagePicker, animated: true)
        }
        alertController.addAction(defaultAction)
        alertController.modalPresentationStyle = .popover
        self.present(alertController, animated: true) {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissAlertController))
            alertController.view.superview?.subviews.first?.addGestureRecognizer(tapGesture)
        }
    }
    
    @objc private func dismissAlertController(){
        self.dismiss(animated: true)
    }
    
    @objc private func sharePhoto() {
        guard let image = imageView.image else {
            return
        }
        let activityViewController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        activityViewController.completionWithItemsHandler = { activityType, completed, _, error in
            if completed && activityType == .saveToCameraRoll {
                self.showCheckmark()
            }
        }
        present(activityViewController, animated: true, completion: nil)
    }
    
    private func showCheckmark() {
        let alertController = UIAlertController(title: "Image saved to Photo Library", message: nil, preferredStyle: .alert)
        self.present(alertController, animated: true)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            alertController.dismiss(animated: true)
        }
    }
}

extension ImageCropViewController: SelectedImageDataDelegate {
    func didSelectImage(mainImage: Image, relatedImagesData: ImageSearchData?, searchText: String?) {
        self.imageData = mainImage
        guard let data = imageData else { return }
        let imageUrl = URL(string: data.webformatURL)
        guard let imageUrl = imageUrl else { return }
        let task = URLSession.shared.dataTask(with: imageUrl) { [weak self] data, response, error in
            guard let data = data, let image = UIImage(data: data) else {
                return
            }
            DispatchQueue.main.async {
                self?.cropImage = image
                self?.presentCropViewController()
            }
        }
        task.resume()
    }
}

extension ImageCropViewController: CropViewControllerDelegate {
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        croppedRect = cropRect
        croppedAngle = angle
        updateImageViewWithImage(image, fromCropViewController: cropViewController)
    }
    
    func cropViewController(_ cropViewController: CropViewController, didFinishCancelled cancelled: Bool) {
        if let cropImage {
            updateImageViewWithImage(cropImage, fromCropViewController: cropViewController)
        }
    }
}

extension ImageCropViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = (info[UIImagePickerController.InfoKey.originalImage] as? UIImage) else { return }
        
        let cropController = CropViewController(croppingStyle: croppingStyle, image: image)
        cropController.modalPresentationStyle = .fullScreen
        cropController.delegate = self
        cropController.title = "Crop Image"
        cropImage = image
        if croppingStyle == .circular && picker.sourceType == .camera {
            picker.dismiss(animated: true) {
                self.present(cropController, animated: true)
            }
        } else {
            picker.pushViewController(cropController, animated: true)
        }
    }
}
