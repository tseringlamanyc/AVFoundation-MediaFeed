//
//  MediaObject.swift
//  AVFoundation-MediaFeed
//
//  Created by Tsering Lama on 4/13/20.
//  Copyright © 2020 Tsering Lama. All rights reserved.
//

import Foundation

struct MediaObject {
    let imageData: Data?
    let videoURL: URL?
    let caption: String?
    let id = UUID().uuidString
    let createdDate = Date()
}
