//
//  CoreDataManager.swift
//  AVFoundation-MediaFeed
//
//  Created by Tsering Lama on 4/14/20.
//  Copyright © 2020 Tsering Lama. All rights reserved.
//

import UIKit
import CoreData

class CoreDataManager {
    
    private init() {}
    static let shared = CoreDataManager()
    
    private var mediaObjects = [CDMediaObject]()
    
    // instance of NSManagedObject from AppDelegate
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    // NSManagedObjectContext does saving, fetching on NSManagedObjects...
    
    // CRUD
    func createMediaObject(imageData: Data, videoURL: URL?) -> CDMediaObject {
        let mediaObject = CDMediaObject(entity: CDMediaObject.entity(), insertInto: context)
        mediaObject.createdDate = Date() // todays date
        mediaObject.id = UUID().uuidString // unique string
        mediaObject.imageData = imageData // both video and image have imageData
        
        if let videoURL = videoURL { // if exists , it means its a video
            // convert URL to data
            do {
                mediaObject.videoData = try Data(contentsOf: videoURL)
            } catch {
                print("Failed to convert URL to data: \(error)")
            }
        }
        
        // save the newly created mediaObject entity instance to the NSManagedObjectContext
        do {
            try context.save()
        } catch {
            print("Failed to save newly created media: \(error)")
        }
        
        return mediaObject
    }
    
    func fetchMediaObjects() -> [CDMediaObject] {
        do {
            mediaObjects = try context.fetch(CDMediaObject.fetchRequest())
        } catch {
            print("Failed to fetch media objects: \(error)")
        }
        return mediaObjects
    }
    
}
