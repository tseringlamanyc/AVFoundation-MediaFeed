//
//  Data-To-URL.swift
//  AVFoundation-MediaFeed
//
//  Created by Tsering Lama on 4/15/20.
//  Copyright © 2020 Tsering Lama. All rights reserved.
//

import Foundation

extension Data {
    
    // mediaObject.videoData.convertToURL (returns a URL)
    public func convertToURL() -> URL? {
        
        // create temporary URL
        // NSTempDirectory - stores temp files, which gets deleted as needed
        // when playing back the video we need to have a URL pointing to the video location on disk
        // AVPlayer needs a URL pointing to disk
        
        let tempURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("video").appendingPathExtension("mp4")
        
        do {
            try self.write(to: tempURL, options: [.atomic])
        } catch {
            print("Failed to write (save) video data to temporary file with error: \(error)")
        }
        
        return tempURL
        
    }
}
