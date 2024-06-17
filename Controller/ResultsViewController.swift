//
//  ResultsViewController.swift
//  ImageSearch
//
//  Created by Екатерина Токарева on 11/02/2023.
//

import UIKit
import Kingfisher

final class ResultsViewController: BaseNavigationController {
    
    @IBOutlet private weak var imagesCountLabel: UILabel!
    @IBOutlet private weak var imagesCollectionView: UICollectionView!
    @IBOutlet private weak var filterSegmentedControl: UISegmentedControl!
    private var searchedText = ""
    private var searchedData: ImageSearchData?
    private let searchService = ImagesSearchService()
    private let imageFilters: [ImageFilter] = [.all, .photo, .illustration, .vector]
    private var selectedFilter: ImageFilter = .all
    private var selectedImage: Image?
    weak var delegate: SelectedImageDataDelegate?
    private var imagesPerRow: CGFloat {
        self.view.frame.width > 400 ? 2 : 1
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        search()
        imagesCollectionView.collectionViewLayout = UICollectionViewFlowLayout()
        self.setupNavigationBar(text: searchedText)
        setupFilters()
        navigationController?.isNavigationBarHidden = false
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        imagesCollectionView.reloadData()
    }
    
    private func setupFilters() {
        filterSegmentedControl.setBackgroundImage(UIImage(ciImage: .clear), for: .normal, barMetrics: .default)
        filterSegmentedControl.setBackgroundImage(UIImage(named: "purple.pdf"), for: .selected, barMetrics: .default)
        filterSegmentedControl.selectedSegmentTintColor = Constants.selectedSegmentTintColor
        filterSegmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: .selected)
        filterSegmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.black], for: .normal)
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let searchedData = searchedData, let selectedImage = selectedImage else { return }
        if segue.identifier == "ImageViewController" {
            let destinationVC = segue.destination as! ImageViewController
            destinationVC.delegate = self
            self.delegate = destinationVC
            delegate?.didSelectImage(mainImage: selectedImage, relatedImagesData: searchedData, searchText: searchedText)
        }
    }
    
    private func search() {
        guard !searchedText.isEmpty else { return }
        let search = searchedText.components(separatedBy: .whitespaces).joined(separator: "+")
        searchService.fetchImages(search: search, imageType: selectedFilter, completionHandler: { [weak self] imageSearchData in
            guard let self = self else { return }
            self.searchedData = imageSearchData
            DispatchQueue.main.async {
                self.imagesCollectionView.reloadData()
            }
        })
    }
    
    @IBAction func filterChanged() {
        switch filterSegmentedControl.selectedSegmentIndex {
        case 0:
            selectedFilter = .all
        case 1:
            selectedFilter = .photo
        case 2:
            selectedFilter = .illustration
        case 3:
            selectedFilter = .vector
        default:
            return
        }
        search()
    }
}

extension ResultsViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        searchedData?.totalImages ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = imagesCollectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! ImageCell
        guard let searchedData = searchedData else { return cell }
        guard indexPath.item < searchedData.images.count else { return cell }
        DispatchQueue.main.async {
            cell.configure(withImage: searchedData.images[indexPath.item].webformatURL, shareButtonIsHidden: false)
            cell.parentViewController = self
            self.imagesCountLabel.text = String(self.searchedData?.totalImages ?? 0) + " images"
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let searchedData = searchedData else { return }
        if indexPath.item < searchedData.images.count {
            selectedImage = searchedData.images[indexPath.item]
            performSegue(withIdentifier: "ImageViewController", sender: nil)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let paddingWidth = Constants.padding * (imagesPerRow - 1)
        let availableWidth = collectionView.frame.width - paddingWidth
        let widthPerItem = availableWidth / imagesPerRow
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
}

extension ResultsViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let text = textField.text else { return false }
        textField.resignFirstResponder()
        searchedText = text
        search()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let text = textField.text else { return }
        searchedText = text
    }
}

extension ResultsViewController: SearchDataDelegate {
    func didSelectFilter(_ filter: ImageFilter) {
        if !searchedText.isEmpty {
            selectedFilter = filter
            search()
        }
    }
    
    func didChangeQuery(_ text: String) {
        if !text.isEmpty {
            searchedText = text
            setupTextField(text: searchedText)
            search()
        }
    }
}

private extension ResultsViewController {
    struct Constants {
        static let minimumLineSpacingForSection: CGFloat = 10
        static let minimumInteritemSpacingForSection: CGFloat = 0
        static let insetForSection = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        static let padding: CGFloat = 10
        static let selectedSegmentTintColor = UIColor(red: 67/255, green: 11/255, blue: 224/255, alpha: 1)
    }
}
