//
//  Thumbnail-Image.swift
//  AVFoundation-MediaFeed
//
//  Created by Tsering Lama on 4/14/20.
//  Copyright © 2020 Tsering Lama. All rights reserved.
//

import UIKit
import AVFoundation

extension URL {
    
    public func videoPreviewThumbnail() -> UIImage? {
        
        // AVAsset instance
        let asset = AVAsset(url: self) // self is the URL instance (eg. mediaObject.videoURL)
     
        // the AVAssetImageGenerator is an AVFoundation class that converts a given media url to an image
        let assestGenerator = AVAssetImageGenerator(asset: asset)
        assestGenerator.appliesPreferredTrackTransform = true  // maintian aspect ratio
        
        // create a time stamp of needed location in the video
        // CMTIme (core media)
        
        let timestamp = CMTime(seconds: 1, preferredTimescale: 60)
        
        var image: UIImage?
        
        do {
            let cgImage = try assestGenerator.copyCGImage(at: timestamp, actualTime: nil) // CGImage
            image = UIImage(cgImage: cgImage)
        } catch {
            print("failed to generate image")
        }
        return image
    }
}
