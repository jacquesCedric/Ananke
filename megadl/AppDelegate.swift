//
//  AppDelegate.swift
//  megadl
//
//  Created by jacques on 18/02/2017.
//  Copyright © 2017 Jacob Gaffney. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
	
	@IBOutlet var consoleOutput: NSTextView!
	@IBOutlet weak var window: NSWindow!
    
	let bundle = Bundle.main
	let task = Process()
	
	var currentUser : String = ""
	var downloadLink = ""
	var downloadPath : String = ""
	

    func applicationDidFinishLaunching(_ aNotification: Notification) {
		/* This next block of code helps us findout who's running the program
		 * and the default download directory
		 */
		var output : [String] = []
		let pipe = Pipe()
		
		// The tool's name says it all
		let path = "/usr/bin/whoami"
		task.launchPath = path
		task.standardOutput = pipe
		task.launch()
		
		// Parse the output so we can read it
		let outdata = pipe.fileHandleForReading.readDataToEndOfFile()
		if var string = String(data: outdata, encoding: .utf8) {
			string = string.trimmingCharacters(in: .newlines)
			output = string.components(separatedBy: "\n")
		}
		
		task.waitUntilExit()
		
		currentUser = output[0]
		print("Found current user: " + currentUser)
		
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        
    }
    
    @IBAction func startDownloadNow(_ sender: NSButton) {
		//var output : [String] = []
		let pipe = Pipe()
		
		let path = bundle.path(forResource: "megadl", ofType: "")
		//let path = "/usr/local/bin/megadl"
		task.launchPath = path
		task.arguments = ["--path", downloadPath, downloadLink]
		task.standardOutput = pipe
		task.launch()
		
		//let outdata = pipe.fileHandleForReading.readDataToEndOfFile()
		
		task.waitUntilExit()
		let status = task.terminationStatus
		
		print(status)
		
    }
	
    /*
    @IBAction func selectDownloadPath(_ sender: NSButton) {
        let openPanel = NSOpenPanel()
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = true
        openPanel.canCreateDirectories = false
        openPanel.canChooseFiles = false
        openPanel.begin { (result) -> Void in
            if result == NSFileHandlingPanelOKButton {
                //Do what you will
                //If there's only one URL, surely 'openPanel.URL'
                //but otherwise a for loop works
            }
        }
    }
    */

}

