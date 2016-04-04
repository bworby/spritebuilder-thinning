//
//  ViewController.swift
//  cocos2d_thinning_helper
//
//  Created by Brandon Worby on 4/3/16.
//  Copyright © 2016 worbyworks. All rights reserved.
//

import Cocoa

class ViewController: NSViewController , fileHandlerProtocol {
    
    
    @IBOutlet weak var srcLabel: NSTextField!
    @IBOutlet weak var destLabel: NSTextField!
    @IBOutlet weak var filesFoundLabel: NSTextField!
    @IBOutlet weak var copiedFilesLabel: NSTextField!
    @IBOutlet weak var copiedFilesErrorLabel: NSTextField!
    @IBOutlet weak var doneLabel: NSTextField!
    
    var fileHandler = FileHandler()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fileHandler.delegate = self
        // Do any additional setup after loading the view.
    }
    
    override var representedObject: AnyObject? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    @IBAction func chooseSource(sender: AnyObject) {
        let openPanel = NSOpenPanel()
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = true
        openPanel.canCreateDirectories = true
        openPanel.canChooseFiles = false
        openPanel.beginWithCompletionHandler { (result) -> Void in
            if result == NSFileHandlingPanelOKButton {
                self.srcLabel.stringValue = "\( openPanel.URL!.path! )"
            }
        }
    }
    
    @IBAction func chooseDestination(sender: AnyObject) {
        let openPanel = NSOpenPanel()
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = true
        openPanel.canCreateDirectories = true
        openPanel.canChooseFiles = false
        openPanel.beginWithCompletionHandler { (result) -> Void in
            if result == NSFileHandlingPanelOKButton {
                self.destLabel.stringValue = "\( openPanel.URL!.path! )"
            }
        }
    }
    
    @IBAction func startPressed( sender: AnyObject ){
        fileHandler.searchDirForFilesAndPopulateArray( srcLabel.stringValue+"/" , desinationDir: destLabel.stringValue+"/")
    }
    
    @IBAction func moveAndCreate(sender: AnyObject) {
        fileHandler.moveAndCreateJSON()
    }
    
    
    //File Hanlder Delegates
    func collectedAllFileData(){
        filesFoundLabel.stringValue = "\( fileHandler.numberOfFilesToMove  )"
    }
    
    func completedMovingFiles(){
        print(" Completed moving files -- ")
        doneLabel.hidden = false
    }
    
    func copiedFile(){
        copiedFilesLabel.stringValue = "\( fileHandler.numberOfFilesMoved )"
    }
    func copiedFileWithError(){
        copiedFilesErrorLabel.stringValue = "\( fileHandler.numberOfFilesMovedWithError )"
    }
    
}

