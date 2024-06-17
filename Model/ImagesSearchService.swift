//
//  NetworkService.swift
//  ImageSearch
//
//  Created by Екатерина Токарева on 11/02/2023.
//

import Foundation

final class ImagesSearchService {
    
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func fetchImages(search: String, imageType: ImageFilter, completionHandler: @escaping (ImageSearchData) -> Void) {
        let url = self.searchURL(for: search, with: imageType)
        performRequest(withURL: url, completionHandler: completionHandler)
    }
    
    private func performRequest(withURL url: URL?, completionHandler: @escaping (ImageSearchData) -> Void) {
        guard let url = url else {
            // Handle the case where the URL is nil
            return
        }
        session.dataTask(with: url) { data, response, error in
            if let data = data,
               let imageSearchData = self.parseJSON(withData: data) {
                completionHandler(imageSearchData)
            }
        }.resume()
    }
    
    private func parseJSON(withData data: Data) -> ImageSearchData? {
        let decoder = JSONDecoder()
        var imageSearchData: ImageSearchData?
        do {
            imageSearchData = try decoder.decode(ImageSearchData.self, from: data)
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        return imageSearchData
    }
    
    private func searchURL(for search: String, with imageType: ImageFilter) -> URL? {
        var components = URLComponents(string: API.baseURL)
        components?.queryItems = [URLQueryItem(name: "key", value: API.key),
                                  URLQueryItem(name: "q", value: search),
                                  URLQueryItem(name: "image_type", value: imageType.rawValue)]
        return components?.url
    }
}
