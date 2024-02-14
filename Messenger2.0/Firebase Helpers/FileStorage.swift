//
//  FileStorage.swift
//  Messenger2.0
//
//  Created by Dan Hozan on 07.02.2024.
//

import Foundation
import FirebaseStorage
import ProgressHUD

let storage = Storage.storage()

//MARK: - Images
class FileStorage {
    
    //MARK: - Images
    class func uploadImage(_ image: UIImage, directory: String, completion: @escaping (_ documentLink: String?) -> Void) {
        
        let storageRef = storage.reference(forURL: kFILEREFERENCE).child(directory)
        let imageData = image.jpegData(compressionQuality: 0.6)
        var task: StorageUploadTask!
        
        task = storageRef.putData(imageData!, metadata: nil, completion: { (metadata, error) in
            task.removeAllObservers()
            ProgressHUD.dismiss()
            
            if error != nil {
                print("error uploading image \(error!.localizedDescription)")
                return
            }
            storageRef.downloadURL { (url, error) in
                
                guard let downloadUrl = url  else {
                    completion(nil)
                    return
                }
                completion(downloadUrl.absoluteString)
            }
        })
        task.observe(StorageTaskStatus.progress) { (snapshot) in
            
            let progress = snapshot.progress!.completedUnitCount / snapshot.progress!.totalUnitCount
            ProgressHUD.progress(CGFloat(progress))
        }
    }
    
    
    //MARK: - Save Locally
    class func saveFileLocally(fileData: NSData, fileName: String) {
        let docUrl = getDocumentsURL().appendingPathComponent(fileName, isDirectory: false)
        fileData.write(to: docUrl, atomically: true)
    }
    
    
    
    class func downloadImage(imageUrl: String, completion: @escaping (_ image: UIImage?) -> Void) {
        let imageFileName = fileNameFrom(fileUrl: imageUrl)
        
        if fileExistsAtPath(path: imageFileName) {
            //get it locally
            if let contentsOfFile = UIImage(contentsOfFile: fileInDocumentsDirectory(fileName: imageFileName)) {
                
                completion(contentsOfFile)
            } else {
                print("couldnt convert local image")
                completion(UIImage(named: "avatar"))
            }
            
        } else {
            //download from FB
            if imageUrl != "" {
                let documentUrl = URL(string: imageUrl)
                let downloadQueue = DispatchQueue(label: "imageDownloadQueue")
                downloadQueue.async {
                    let data = NSData(contentsOf: documentUrl!)
                    if data != nil {
                        //Save locally
                        FileStorage.saveFileLocally(fileData: data!, fileName: imageFileName)
                        
                        DispatchQueue.main.async {
                            completion(UIImage(data: data! as Data))
                        }
                        
                    } else {
                        print("no document in database")
                        DispatchQueue.main.async {
                            completion(nil)
                        }
                    }
                }
            }
        }
    }
    
    //MARK: - Video
    class func uploadVideo(_ video: NSData, directory: String, completion: @escaping (_ videoLink: String?) -> Void) {
        let storageRef = storage.reference(forURL: kFILEREFERENCE).child(directory)
        var task: StorageUploadTask!
        task = storageRef.putData(video as Data, metadata: nil, completion: { (metadata, error) in
            
            task.removeAllObservers()
            ProgressHUD.dismiss()
            
            if error != nil {
                print("error uploading video \(error!.localizedDescription)")
                return
            }
            storageRef.downloadURL { (url, error) in
                guard let downloadUrl = url  else {
                    completion(nil)
                    return
                }
                completion(downloadUrl.absoluteString)
            }
        })
        task.observe(StorageTaskStatus.progress) { (snapshot) in
            
            let progress = snapshot.progress!.completedUnitCount / snapshot.progress!.totalUnitCount
            ProgressHUD.progress(CGFloat(progress))
        }
    }
    
    class func downloadVideo(videoLink: String, completion: @escaping (_ isReadyToPlay: Bool, _ videoFileName: String) -> Void) {
        
        let videoUrl = URL(string: videoLink)
        let videoFileName = fileNameFrom(fileUrl: videoLink) + ".mov"
        
        if fileExistsAtPath(path: videoFileName) {
            completion(true, videoFileName)
        } else {
            let downloadQueue = DispatchQueue(label: "VideoDownloadQueue")
            downloadQueue.async {
                let data = NSData(contentsOf: videoUrl!)
                if data != nil {
                    //Save locally
                    FileStorage.saveFileLocally(fileData: data!, fileName: videoFileName)
                    
                    DispatchQueue.main.async {
                        completion(true, videoFileName)
                    }
                    
                } else {
                    print("no document in database")
                }
            }
        }
    }
    
    
    //MARK: - Audio
    class func uploadAudio(_ audioFileName: String, directory: String, completion: @escaping (_ audioLink: String?) -> Void) {
        
        let fileName = audioFileName + ".m4a"
        let storageRef = storage.reference(forURL: kFILEREFERENCE).child(directory)
        var task: StorageUploadTask!
        
        if fileExistsAtPath(path: fileName) {
            
            if let audioData = NSData(contentsOfFile: fileInDocumentsDirectory(fileName: fileName)) {
                task = storageRef.putData(audioData as Data, metadata: nil, completion: { (metadata, error) in
                    
                    task.removeAllObservers()
                    ProgressHUD.dismiss()
                    
                    if error != nil {
                        print("error uploading audio \(error!.localizedDescription)")
                        return
                    }
                    storageRef.downloadURL { (url, error) in
                        guard let downloadUrl = url  else {
                            completion(nil)
                            return
                        }
                        completion(downloadUrl.absoluteString)
                    }
                })
            
                task.observe(StorageTaskStatus.progress) { (snapshot) in
                    let progress = snapshot.progress!.completedUnitCount / snapshot.progress!.totalUnitCount
                    ProgressHUD.progress(CGFloat(progress))
                }
            } else {
                print("nothing to upload (audio)")
            }
        }
    }
    
    class func downloadAudio(audioLink: String, completion: @escaping (_ audioFileName: String) -> Void) {
        
        let audioFileName = fileNameFrom(fileUrl: audioLink) + ".m4a"
        
        if fileExistsAtPath(path: audioFileName) {
            
            completion(audioFileName)
            
        } else {
            
            let downloadQueue = DispatchQueue(label: "AudioDownloadQueue")
            
            downloadQueue.async {
                
                let data = NSData(contentsOf: URL(string: audioLink)!)
                
                if data != nil {
                    
                    //Save locally
                    FileStorage.saveFileLocally(fileData: data!, fileName: audioFileName)
                    
                    DispatchQueue.main.async {
                        completion(audioFileName)
                    }
                    
                } else {
                    print("no document in database audio")
                }
            }
        }
    }
    
    
    
}





//Helpers
func fileInDocumentsDirectory(fileName: String) -> String {
    return getDocumentsURL().appendingPathComponent(fileName).path
}

func getDocumentsURL() -> URL {
    return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!
}

func fileExistsAtPath(path: String) -> Bool {
    return FileManager.default.fileExists(atPath: fileInDocumentsDirectory(fileName: path))
}

