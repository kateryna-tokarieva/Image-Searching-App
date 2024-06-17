//
//  ImageViewController.swift
//  ImageSearch
//
//  Created by Екатерина Токарева on 11/02/2023.
//

import UIKit
import Kingfisher
import ImageScrollView

final class ImageViewController: UIViewController {
    
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var heightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var imageView: ImageScrollView!
    @IBOutlet private weak var formatLabel: UILabel!
    @IBOutlet private weak var shareButton: UIButton!
    @IBOutlet private weak var downloadButton: UIButton!
    @IBOutlet private weak var relatedImagesView: UICollectionView!
    private var searchedText = ""
    private var imageData: Image?
    private var downloadLink: String?
    private var searchedData: ImageSearchData?
    private let searchService = ImagesSearchService()
    private var currentZoomScale: CGFloat = 1.0
    weak var delegate: SearchDataDelegate?
    weak var imageDelegate: ImageCropViewController?
    private let plusButton = UIButton()
    private let minusButton = UIButton()
    private let cropButton = UIButton()
    private let stackView = UIStackView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialUI()
        setupImage()
    }
    
    private func initialUI() {
        imageView.contentMode = .scaleAspectFit
        imageView.imageContentMode = .aspectFill
        relatedImagesView.collectionViewLayout = UICollectionViewFlowLayout()
        downloadButton.layer.cornerRadius = Constants.cornerRadius
        downloadButton.layer.masksToBounds = true
        shareButton.layer.cornerRadius = Constants.cornerRadius
        shareButton.layer.masksToBounds = true
        shareButton.layer.borderWidth = Constants.boarderWidth
        imageView.imageScrollViewDelegate = self
        setupZoomButtons()
        setupCropButton()
    }
    
    private func setupCropButton() {
        cropButton.setImage(UIImage(named: "cropIcon"), for: .normal)
        cropButton.addTarget(self, action: #selector(cropButtonAction), for: .touchUpInside)
        view.addSubview(cropButton)
        cropButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            cropButton.trailingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: -10),
            cropButton.bottomAnchor.constraint(equalTo: stackView.topAnchor, constant: -10)
        ])
    }
    
    @objc private func cropButtonAction() {
        performSegue(withIdentifier: "CropViewController", sender: nil)
    }
    
    private func setupZoomButtons() {
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.alignment = .center
        plusButton.setImage(UIImage(named: "plus"), for: .normal)
        plusButton.tintColor = Constants.iconColor
        plusButton.addTarget(self, action: #selector(plusButtonAction), for: .touchUpInside)
        stackView.addArrangedSubview(plusButton)
        minusButton.setImage(UIImage(named: "minus"), for: .normal)
        minusButton.tintColor = Constants.iconColor
        minusButton.addTarget(self, action: #selector(minusButtonAction), for: .touchUpInside)
        stackView.addArrangedSubview(minusButton)
        view.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.trailingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: -10),
            stackView.bottomAnchor.constraint(equalTo: imageView.bottomAnchor, constant: -10)
        ])
        imageView.maximumZoomScale = 10
        imageView.minimumZoomScale = 1
        updateZoomButtons()
    }
    
    @objc private func plusButtonAction() {
        imageView.zoomScale += 1
        imageView.layoutIfNeeded()
        updateZoomButtons()
    }
    
    @objc private func minusButtonAction() {
        imageView.zoomScale -= 1
        imageView.layoutIfNeeded()
        updateZoomButtons()
    }
    
    private func updateZoomButtons() {
        plusButton.isHidden = imageView.maximumZoomScale ==  imageView.zoomScale
        minusButton.isHidden = imageView.zoomScale == imageView.minimumZoomScale
    }

    private func setupImage() {
        guard let data = imageData else { return }
        let imageUrl = URL(string: data.webformatURL)
        guard let imageUrl = imageUrl else { return }
        let task = URLSession.shared.dataTask(with: imageUrl) { [weak self] data, response, error in
            guard let data = data, let image = UIImage(data: data) else {
                return
            }
            DispatchQueue.main.async {
                guard let self = self else { return }
                let aspectRatio = image.size.width / image.size.height
                let newHeight = self.imageView.frame.width / aspectRatio
                self.heightConstraint.constant = newHeight
                self.imageView.display(image: image)
                self.view.layoutIfNeeded()
            }
        }
        task.resume()
        downloadLink = data.largeImageURL
        formatLabel.text = "Image in " + data.type + " format"
    }
    
    @IBAction private func shareButtonAction() {
        guard let link = downloadLink else { return }
        let url = URL(string: link)
        guard let url = url else { return }
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, let image = UIImage(data: data) else {
                return
            }
            DispatchQueue.main.async {
                let activityVC = UIActivityViewController(activityItems: [image as Any], applicationActivities: nil)
                activityVC.popoverPresentationController?.sourceView = self.view
                activityVC.popoverPresentationController?.sourceRect = CGRectMake(0, 20, 150, 100)
                self.present(activityVC, animated: true)
            }
        }
        task.resume()
    }
    
    @IBAction private func downloadButtonAction() {
        guard let link = downloadLink, let url = URL(string: link) else { return }
        
        let downloader = ImageDownloader()
        downloader.downloadImage(from: url) { image in
            guard let image = image else {
                print("Error downloading image")
                return
            }
            UIImageWriteToSavedPhotosAlbum(image, self, #selector(self.image(_:didFinishSavingWithError:contextInfo:)), nil)
        }
    }
    
    @objc private func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            print("Error saving image: \(error.localizedDescription)")
        } else {
            let alertController = UIAlertController(title: "Download Complete", message: nil, preferredStyle: .alert)
            self.present(alertController, animated: true, completion: nil)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                alertController.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let imageData = imageData else { return }
        if segue.identifier == "CropViewController" {
            let destinationVC = segue.destination as! ImageCropViewController
            self.imageDelegate = destinationVC
            imageDelegate?.didSelectImage(mainImage: imageData, relatedImagesData: nil, searchText: nil)
        }
    }
}

extension ImageViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        searchedData?.totalImages ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = relatedImagesView.dequeueReusableCell(withReuseIdentifier: "RelatedImageCell", for: indexPath) as! ImageCell
        guard let searchedData = searchedData else { return cell }
        if indexPath.item < searchedData.images.count {
            DispatchQueue.main.async {
                cell.configure(withImage: searchedData.images[indexPath.item].webformatURL, shareButtonIsHidden: true)
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let paddingWidth = Constants.padding * (Constants.imagesPerRow - 1)
        let availableWidth = collectionView.frame.width - paddingWidth
        let widthPerItem = availableWidth / Constants.imagesPerRow
        return CGSize(width: widthPerItem, height: widthPerItem)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        Constants.insetForSection
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        Constants.minimumLineSpacingForSection
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        Constants.minimumInteritemSpacingForSection
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let searchedData = searchedData else { return }
        if indexPath.item < searchedData.images.count {
            imageData = searchedData.images[indexPath.item]
            setupImage()
            scrollView.setContentOffset(CGPoint(x: 0, y: -scrollView.contentInset.top), animated: true)
        }
    }
}

private extension ImageViewController {
    struct Constants {
        static let imagesPerRow: CGFloat = 2
        static let minimumLineSpacingForSection: CGFloat = 10
        static let minimumInteritemSpacingForSection: CGFloat = 0
        static let insetForSection = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        static let padding: CGFloat = 10
        static let cornerRadius: CGFloat = 5
        static let boarderWidth: CGFloat = 1
        static let iconColor = UIColor(red: 67/255, green: 11/255, blue: 224/255, alpha: 1)
    }
}

extension ImageViewController: SelectedImageDataDelegate {
    func didSelectImage(mainImage: Image, relatedImagesData: ImageSearchData?, searchText: String?) {
        guard let searchText, let relatedImagesData else { return }
        self.searchedText = searchText
        self.searchedData = relatedImagesData
        self.imageData = mainImage
    }
}

extension ImageViewController: ImageScrollViewDelegate {
    func imageScrollViewDidChangeOrientation(imageScrollView: ImageScrollView) {
        if UIDevice.current.orientation.isLandscape {
            heightConstraint.constant = self.view.frame.height
        } else {
            setupImage()
        }
        self.view.layoutIfNeeded()
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        currentZoomScale = scrollView.zoomScale
        updateZoomButtons()
    }
}
