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
    
    @IBOutlet weak var overwriteDestinationFilesCheckbox: NSButton!
    @IBOutlet weak var deleteSourceWhenDoneCheckBox: NSButton!
    
    @IBOutlet weak var iphone1xcheckbox: NSButton!
    @IBOutlet weak var iphone2xcheckbox: NSButton!
    @IBOutlet weak var iphone3xcheckbox: NSButton!
    
    @IBOutlet weak var ipad1xcheckbox: NSButton!
    @IBOutlet weak var ipad2xcheckbox: NSButton!
    
    @IBOutlet weak var fileTypesToSearchForTextField: NSTextField!
    
    var fileHandler = FileHandler()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fileHandler.delegate = self
        srcLabel.stringValue = "/Users/brandonworby/Desktop/move_files_test/Published-iOS/test"
        destLabel.stringValue = "/Users/brandonworby/Desktop/move_files_test/destination"
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
        setFileHandlerSizes()
        fileHandler.setExtensionsFromString( fileTypesToSearchForTextField.stringValue )
        fileHandler.searchDirForFilesAndPopulateArray( srcLabel.stringValue+"/" , desinationDir: destLabel.stringValue+"/")
    }
    
    @IBAction func moveAndCreate(sender: AnyObject) {
        
        if( deleteSourceWhenDoneCheckBox.state == 1 ){
            fileHandler.deleteSourceFilesAfterMove = true
        } else {
            fileHandler.deleteSourceFilesAfterMove = false
        }
        if( overwriteDestinationFilesCheckbox.state == 1 ){
            fileHandler.shouldOverwrite = true
        } else {
            fileHandler.shouldOverwrite = false
        }
        fileHandler.moveAndCreateJSON()
    }
    
    func setFileHandlerSizes(){
        
        fileHandler.includedSizes.removeAll()
        
        if( iphone1xcheckbox.state == 1 ){
            fileHandler.includedSizes.append("iphone-1x")
        }
        if( iphone2xcheckbox.state == 1 ){
            fileHandler.includedSizes.append("iphone-2x")
        }
        if( iphone3xcheckbox.state == 1 ){
            fileHandler.includedSizes.append("iphone-3x")
        }
        if( ipad1xcheckbox.state == 1 ){
            fileHandler.includedSizes.append("ipad-1x")
        }
        if( ipad2xcheckbox.state == 1 ){
            fileHandler.includedSizes.append("ipad-2x")
        }
    }
    
    //File Hanlder Delegates
    func collectedAllFileData(){
        filesFoundLabel.stringValue = "\( fileHandler.numberOfFilesToMove  )"
    }
    
    func completedMovingFiles(){
        doneLabel.hidden = false
    }
    
    func copiedFile(){
        copiedFilesLabel.stringValue = "\( fileHandler.numberOfFilesMoved )"
    }
    func copiedFileWithError(){
        copiedFilesErrorLabel.stringValue = "\( fileHandler.numberOfFilesMovedWithError )"
    }
    
}

