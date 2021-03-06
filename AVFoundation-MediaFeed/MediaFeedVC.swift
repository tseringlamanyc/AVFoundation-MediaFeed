//
//  ViewController.swift
//  AVFoundation-MediaFeed
//
//  Created by Tsering Lama on 4/13/20.
//  Copyright © 2020 Tsering Lama. All rights reserved.
//

import UIKit
import AVFoundation // video done on a CALayer
import AVKit // AVPlayerViewController , video on AVPlayerController

class MediaFeedVC: UIViewController {
    
    @IBOutlet weak var photoButton: UIBarButtonItem!
    @IBOutlet weak var videoButton: UIBarButtonItem!
    @IBOutlet weak var mediaCV: UICollectionView!
    
    lazy var imagePickerController: UIImagePickerController = {
        let mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary) // photos or videos
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.mediaTypes = mediaTypes ?? ["kUTTypeImage"]
        return pickerController
    }()
    
    private var mediaObjects = [CDMediaObject]() {
        didSet {
            mediaCV.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCV()
        
        if !UIImagePickerController.isSourceTypeAvailable(.camera) {
            videoButton.isEnabled = false
        }
        
        fetchMediaObjects()
    }
    
    private func configureCV() {
        mediaCV.dataSource = self
        mediaCV.delegate = self
    }
    
    // NSPredicate
    // NSFetchResultController
    private func fetchMediaObjects() {
        mediaObjects = CoreDataManager.shared.fetchMediaObjects()
    }
    
    @IBAction func videoButtonPressed(_ sender: UIBarButtonItem) {
        imagePickerController.sourceType = .camera
        present(imagePickerController, animated: true)
    }
    
    
    @IBAction func photoLibraryPressed(_ sender: UIBarButtonItem) {
        imagePickerController.sourceType = .photoLibrary
        present(imagePickerController, animated: true)
    }
    
    private func playRandomVideo(view: UIView) {
        // we want all non-nill media objects
        let videoDataObjects = mediaObjects.compactMap {$0.videoData}
        
        // get a random video URL
        if let videoObject = videoDataObjects.randomElement(), let videoURL = videoObject.convertToURL() {
            let player = AVPlayer(url: videoURL)
            
            // create sublayer (CA Layer)
            let playerLayer = AVPlayerLayer(player: player)
            
            // set its frame
            playerLayer.frame = view.bounds   // take up the entire header view
            
            // aspect ratio
            playerLayer.videoGravity = .resize
            
            // remove all sublayers from headerview
            view.layer.sublayers?.removeAll()
            
            // add layer to header view
            view.layer.addSublayer(playerLayer)
            
            player.play() // plays video
        }
    }
    
}

extension MediaFeedVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return mediaObjects.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "mediaCell", for: indexPath) as? MediaCell else {
            fatalError()
        }
        let aMedia = mediaObjects[indexPath.row]
        cell.configureCell(mediaObject: aMedia)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "headerView", for: indexPath) as? HeaderView else {
            fatalError()
        }
        playRandomVideo(view: headerView)
        return headerView
    }
}

extension MediaFeedVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let maxSize: CGSize = UIScreen.main.bounds.size
        let itemWidth: CGFloat = maxSize.width
        let itemHeight: CGFloat = maxSize.height * 0.40
        return CGSize(width: itemWidth, height: itemHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: mediaCV.bounds.width, height: mediaCV.bounds.height * 0.50)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let playerVC = AVPlayerViewController() // AVKit
        
        let mediaObject = mediaObjects[indexPath.row]
        
        guard let videoURL = mediaObject.videoData?.convertToURL() else {return}
        let player = AVPlayer(url: videoURL)
        playerVC.player = player
        
        present(playerVC, animated: true) {
            player.play() // plays automatically 
        }
    }
}

extension MediaFeedVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        // Infokey =  mediatype (originalImage, mediaURL)
        guard let mediaType = info[UIImagePickerController.InfoKey.mediaType] as? String else {
            return
        }
        
        print("mediatype: \(mediaType)")
        
        switch mediaType {
        case "public.image":
            if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage, let imageData = originalImage.jpegData(compressionQuality: 1.0) {
                //  let mediaObject = CDMediaObject(imageData: imageData, videoURL: nil, caption: nil)
                let mediaObject = CoreDataManager.shared.createMediaObject(imageData: imageData, videoURL: nil)
                mediaObjects.append(mediaObject)
            }
        case "public.movie":
            if let mediaURL = info[UIImagePickerController.InfoKey.mediaURL] as? URL, let image = mediaURL.videoPreviewThumbnail(), let imageData = image.jpegData(compressionQuality: 1.0) {
                //  let mediaObject = CDMediaObject(imageData: nil, videoURL: mediaURL, caption: nil)
                let mediaObject = CoreDataManager.shared.createMediaObject(imageData: imageData, videoURL: mediaURL)
                mediaObjects.append(mediaObject)
            }
        default:
            break
        }
        
        picker.dismiss(animated: true)
    }
}

