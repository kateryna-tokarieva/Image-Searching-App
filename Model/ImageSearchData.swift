//
//  ImageSearchData.swift
//  ImageSearch
//
//  Created by Екатерина Токарева on 11/02/2023.
//

import Foundation

struct ImageSearchData: Codable {
    let totalImages: Int
    let images: [Image]
    
    enum CodingKeys: String, CodingKey {
        case totalImages = "totalHits"
        case images = "hits"
    }
}
