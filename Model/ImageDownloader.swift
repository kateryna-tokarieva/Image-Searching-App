//
//  ImageDownloader.swift
//  ImageSearch
//
//  Created by Екатерина Токарева on 18/02/2023.
//

import Foundation
import Kingfisher
import UIKit

final class ImageDownloader {
    func downloadImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
        KingfisherManager.shared.retrieveImage(with: url) { result in
            switch result {
            case .success(let value):
                completion(value.image)
            case .failure(let error):
                print("Error downloading image: \(error)")
                completion(nil)
            }
        }
    }
    
    enum ImageDownloadError: Error {
        case imageNotFound
    }
}
