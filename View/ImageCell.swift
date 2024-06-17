//
//  Cell.swift
//  ImageSearch
//
//  Created by Екатерина Токарева on 21/02/2023.
//

import UIKit
import Kingfisher

final class ImageCell: UICollectionViewCell {
    
    private let imageView = UIImageView()
    private let shareButton = UIButton()
    weak var parentViewController: UIViewController?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func configure(withImage imageLink: String, shareButtonIsHidden: Bool) {
        shareButton.isHidden = shareButtonIsHidden
        imageView.kf.indicatorType = .activity
        let url = URL(string: imageLink)
        imageView.kf.setImage(with: url)
        shareButton.setBackgroundImage(UIImage(named: "share.png"), for: .normal)
        shareButton.setTitle("", for: .normal)
        imageView.backgroundColor = .gray
        imageView.contentMode = .scaleAspectFill
        contentView.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        shareButton.setBackgroundImage(UIImage(named: "share.png"), for: .normal)
        shareButton.setTitle("", for: .normal)
        shareButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(shareButton)
        shareButton.widthAnchor.constraint(equalToConstant: 32).isActive = true
        shareButton.heightAnchor.constraint(equalToConstant: 32).isActive = true
        shareButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8).isActive = true
        shareButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8).isActive = true
        shareButton.addTarget(self, action: #selector(shareButtonAction), for: .touchUpInside)
    }
    
    @objc private func shareButtonAction() {
        guard let parentViewController = parentViewController else {
            return
        }
        let activityVC = UIActivityViewController(activityItems: [imageView.image as Any], applicationActivities: nil)
        activityVC.popoverPresentationController?.sourceView = parentViewController.view
        activityVC.popoverPresentationController?.sourceRect = CGRectMake(0, 20, 150, 100)
        parentViewController.present(activityVC, animated: true)
    }
}
