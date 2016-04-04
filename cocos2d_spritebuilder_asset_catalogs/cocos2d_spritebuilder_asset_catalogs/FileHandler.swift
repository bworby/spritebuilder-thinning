//
//  FileHandler.swift
//  mp4_maker_dodad
//
//  Created by Brandon Worby on 9/11/15.
//  Copyright (c) 2015 Brandon Worby. All rights reserved.
//

import Cocoa
import Foundation

protocol fileHandlerProtocol {
    func collectedAllFileData()
    func completedMovingFiles()
    func copiedFile()
}

class FileHandler: NSObject {
   
    var delegate:fileHandlerProtocol!
    var errorCopies = Array<String>()
    var extensionsToConvert:Array<String> = [ "png"  ]
    var numberOfFilesToMove = 0
    var numberOfFilesMoved = 0
    var numberOfFilesMovedWithError = 0
    var imageFilesToSave = Dictionary<String,Array<Dictionary<String,String>>>()
    var destinationForFiles = ""
    var shouldOverwrite = true
    
    func searchDirForFilesAndPopulateArray( sourceDir:String , desinationDir:String , seperateByFileType:Bool = false ){
        
        let fileManager = NSFileManager.defaultManager()
        let enumerator:NSDirectoryEnumerator = fileManager.enumeratorAtPath(sourceDir)!
        destinationForFiles = desinationDir

        print("  sourceDir \( sourceDir )")
        print("  destinationForFiles \( destinationForFiles )")
        
        while let element = enumerator.nextObject() as? String {
            
            let url = NSURL(fileURLWithPath: element )
            let ext = url.pathExtension
            //let ext = element.pathExtension as String
            if( extensionsToConvert.contains( ext! ) ){
                
                let url = NSURL(fileURLWithPath: element )
                let fileExtension = url.pathExtension
                var name = url.lastPathComponent
                let name_without_extension = NSURL(fileURLWithPath: element).URLByDeletingPathExtension?.lastPathComponent
                let src = sourceDir+element

                var file_name_incrementor = ""
                var idiom = "iphone"
                var scale = "1x"
                
                switch checkSize( src ) {
                case "phone":
                    file_name_incrementor = "-1"
                    print(" test ")
                case "phonehd":
                    file_name_incrementor = "-2"
                    scale = "2x"
                    print(" test ")
                case "tablet":
                    file_name_incrementor = "-3"
                    idiom = "ipad"
                    scale = "1x"
                    print(" test ")
                case "tablethd":
                    file_name_incrementor = "-4"
                    idiom = "ipad"
                    scale = "2x"
                    print(" test ")
                default:
                    print(" UNKNOWN IMAGE SIZE?? __  ")
                    break
                }
                
                numberOfFilesToMove += 1
                let output_name = name_without_extension! + file_name_incrementor + "." + fileExtension!
                let foldername = "\(name_without_extension!).imageset"
                let destForElement = destinationForFiles + "\(foldername)/\(output_name)"
  
                let newFileData:Dictionary<String,String> = [
                    "src":src,
                    "dest":destForElement,
                    "foldername":foldername,
                    "output_name":output_name,
                    "idiom":idiom,
                    "scale":scale
                ]
                
                if let _ = imageFilesToSave[name_without_extension!] {
                    //key exists
                    print(" We have an existing image - ")
                    var temp_array = imageFilesToSave[name_without_extension!]
                    temp_array?.append(newFileData)
                    imageFilesToSave[name_without_extension!] = temp_array
                } else {
                    //create new key element
                    print(" create new key element ")
                    imageFilesToSave[name_without_extension!] = [newFileData]
                }
            }
        }
        self.delegate.collectedAllFileData()
        
    }
    
    func moveAndCreateJSON(){
        createJSON()
        copyFiles()
    }
    
    func createJSON(){
        print( " ---- LETS createJSON ---- SETUP " )
        let json_file_name = "Contents.json"
        for ( key , value ) in imageFilesToSave {
            var json_for_file = Dictionary< String , AnyObject >()
            json_for_file["info"] = [
                "version" : 1,
                "author" : "xcode"
            ]
            var imagesJSONArray = Array<Dictionary<String,AnyObject>>()
            for image_data in value {
                let img_json:Dictionary<String,String> = [
                    "idiom" : image_data["idiom"]!,
                    "filename" : image_data["output_name"]!,
                    "scale" : image_data["scale"]!
                ]
                imagesJSONArray.append( img_json )
            }
            json_for_file["images"] = imagesJSONArray
            let foldername = "\(key).imageset"
            let jsonFolderPath = "\(destinationForFiles)\(foldername)"
            if( createDirAtPath(jsonFolderPath)  ){
                let json_file = "\(destinationForFiles)\(foldername)/\(json_file_name)"
                if( createFileAtPath( json_file ) ){
                    // Write that JSON to the file created earlier
                    let jsonFilePath = json_file
                    do {
                        let jsonData = try NSJSONSerialization.dataWithJSONObject( json_for_file , options: NSJSONWritingOptions())
                        let file = try NSFileHandle(forWritingToURL: NSURL(fileURLWithPath: jsonFilePath) )
                        file.writeData(jsonData)
                        print(" YAY JSON data was written to the file successfully!")
                    } catch let error as NSError {
                        print("Couldn't write to file: \(error.localizedDescription)")
                    }
                } else {
                    print(" ERROR NO CREATE FILE AT PATH json_file: \( json_file )")
                }
            }
        }
    }
    
    func createFileAtPath( path:String ) ->Bool {
        let fileManager = NSFileManager.defaultManager()
        var isDirectory: ObjCBool = false
        if !fileManager.fileExistsAtPath( path , isDirectory: &isDirectory) {
            let created = fileManager.createFileAtPath( path , contents: nil, attributes: nil)
            if created {
                return true
            } else {
                print("Couldn't create file for some reason")
                return false
            }
        } else {
            print("File already exists")
            return true
        }
        return false
    }
    
    func createDirAtPath( path:String ) ->Bool {
        if( !NSFileManager.defaultManager().fileExistsAtPath( path ) ){
            do {
                try NSFileManager.defaultManager().createDirectoryAtPath( path , withIntermediateDirectories: false, attributes: nil)
                return true
            } catch let error as NSError {
                print(" ERROR createDirAtPath path: \( path ) with error \( error.localizedDescription  ) ")
                return false
            }
        } else {
            return true
        }
        return false
    }
   
    func checkSize( src_file_path:String ) -> String {
        if src_file_path.rangeOfString("resources-phonehd") != nil{
            return "phonehd"
        } else if src_file_path.rangeOfString("resources-phone") != nil{
            return "phone"
        } else if src_file_path.rangeOfString("resources-tablethd") != nil{
            return "tablethd"
        } else if src_file_path.rangeOfString("resources-tablet") != nil{
            return "tablet"
        }
        return ""
    }
    
    //MARK:: COPYING FILES - no convert
    func copyFiles(){
        for (key,fileInfo) in imageFilesToSave {
            let foldername = "\(key).imageset"
            for image_data in fileInfo {
                let source_file = image_data["src"]
                let destination = image_data["dest"]
                copyFile( source_file! , dest: destination! )
                self.delegate.copiedFile()
            }
        }
    }
    
    func copyFile( src:String , dest:String ){
        print( " copyFile \( src ) " )
        
        let fileManager = NSFileManager.defaultManager()
        if( shouldOverwrite ){
            if( fileManager.fileExistsAtPath(dest) ){
                do{
                   try fileManager.removeItemAtPath(dest)
                } catch let error as NSError {
                    print(" ERROR REMOVING ITEM AT PATH \( dest ) error \( error ) ")
                }
            }
        }

            if( !fileManager.fileExistsAtPath(dest) ){
                var error: NSError?
                do {
                    try fileManager.copyItemAtPath(src, toPath: dest)
                    self.numberOfFilesMoved += 1
                } catch let error1 as NSError {
                    error = error1
                    self.numberOfFilesMovedWithError += 1
                    print("Copy failed with error: \(error!.localizedDescription)")
                    self.errorCopies.append(dest)
                } catch {
                    fatalError()
                }
            } else {
                print(" File does exist ")
            }
            
            dispatch_async(dispatch_get_main_queue()) {
                if( self.numberOfFilesToMove == (self.numberOfFilesMovedWithError + self.numberOfFilesMoved ) ){
                    self.delegate.completedMovingFiles()
                }
            }
    }
    
    
}
