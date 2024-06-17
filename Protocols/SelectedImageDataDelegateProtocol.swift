//
//  SelectedImageDataDelegateProtocol.swift
//  ImageSearch
//
//  Created by Екатерина Токарева on 15/02/2023.
//

import Foundation

protocol SelectedImageDataDelegate: AnyObject {
    func didSelectImage(mainImage: Image, relatedImagesData: ImageSearchData?, searchText: String?)
}
