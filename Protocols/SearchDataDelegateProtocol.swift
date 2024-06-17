//
//  SearchDataDelegateProtocol.swift
//  ImageSearch
//
//  Created by Екатерина Токарева on 15/02/2023.
//

import Foundation

protocol SearchDataDelegate: AnyObject {
    func didSelectFilter(_ filter: ImageFilter)
    func didChangeQuery(_ text: String)
}
