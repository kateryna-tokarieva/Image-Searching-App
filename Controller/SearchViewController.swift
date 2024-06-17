//
//  ViewController.swift
//  ImageSearch
//
//  Created by Екатерина Токарева on 11/02/2023.
//

import UIKit

final class SearchViewController: UIViewController  {
    
    @IBOutlet private weak var label: UILabel!
    @IBOutlet private weak var searchButton: UIButton!
    @IBOutlet private weak var searchTextField: UITextField!
    weak var delegate: SearchDataDelegate?
    private let imageFilters: [ImageFilter] = [.all, .photo, .illustration, .vector]
    private var selectedFilter: ImageFilter = .all
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchTextField.delegate = self
        searchButton.layer.cornerRadius = 5
        searchButton.layer.masksToBounds = true
        setupTextField()
        navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        searchTextField.text = ""
    }
    
    private func setupTextField() {
        let dropdownButton = UIButton(type: .system)
        dropdownButton.frame = CGRect(x: 0, y: 0, width: 30, height: 15)
        dropdownButton.setImage(UIImage(systemName: "chevron.down"), for: .normal)
        dropdownButton.tintColor = .gray
        dropdownButton.addTarget(self, action: #selector(showFilterOptions), for: .touchUpInside)
        let rightView = UIView(frame: CGRect(x: 0, y: 0, width: 60, height: 20))
        rightView.addSubview(dropdownButton)
        dropdownButton.center = rightView.center
        searchTextField.rightView = rightView
        searchTextField.rightViewMode = .always
        
        let magnifyingGlass = UIImageView(image: UIImage(systemName: "magnifyingglass"))
        magnifyingGlass.tintColor = .gray
        let leftView = UIView(frame: CGRect(x: 0, y: 0, width: 60, height: 20))
        leftView.addSubview(magnifyingGlass)
        magnifyingGlass.center = leftView.center
        searchTextField.leftView = leftView
        searchTextField.leftViewMode = .always
    }
    
    @objc private func showFilterOptions() {
        let alertController = UIAlertController(title: "Please choose prefered image type", message: nil, preferredStyle: .actionSheet)
        for filter in imageFilters {
            let action = UIAlertAction(title: filter.rawValue, style: .default) { [weak self] _ in
                self?.selectedFilter = filter
            }
            alertController.addAction(action)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        if let popoverPresentationController = alertController.popoverPresentationController {
            popoverPresentationController.sourceView = searchTextField.leftView
            popoverPresentationController.sourceRect = searchTextField.leftView?.bounds ?? CGRect.zero
        }
        present(alertController, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "ResultsViewController" else { return }
        guard let text = searchTextField.text else { return }
        let destinationVC = segue.destination as! ResultsViewController
        self.delegate = destinationVC
        self.delegate?.didChangeQuery(text)
        self.delegate?.didSelectFilter(selectedFilter)
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
    }
    
    @IBAction func searchTextFeildAction() {
        guard let text = searchTextField.text,
                !text.isEmpty else { return }
        performSegue(withIdentifier: "ResultsViewController", sender: nil)
    }
}

extension SearchViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        searchTextFeildAction()
        return true
    }
}
