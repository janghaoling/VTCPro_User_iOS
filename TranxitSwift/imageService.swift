//
//  imageService.swift
//  TranxitUser
//
//  Created by JRC on 6/8/19.
//  Copyright © 2019 Appoets. All rights reserved.
//

import Foundation
import UIKit

class ImageService {
    static func downloadImage(withURL url: URL, completion: @escaping (_ image:UIImage?->()) {
        let dataTask = URLSession.shared.dataTask(with: url) {data, url, error in
        var downloadedImage:UIImage?
        
        if let data = data {
        downloadedImage = UIImage(data: data)
        }
        
            DispatchQueue.main.async {
                complete(downloadedImage)
            }
        }
      dataTask.resume()
    }

}
