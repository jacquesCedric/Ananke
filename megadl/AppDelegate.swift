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
	
	@IBOutlet weak var window: NSWindow!
    @IBOutlet var downloadPathBar: NSPathCell!
    @IBOutlet var megaLinkUrl: NSTextField!
	@IBOutlet var consoleOutput: NSTextView!
    @IBOutlet var chooseDownloadLocationButton: NSButton!
    @IBOutlet var downloadLinkButton: NSButton!
	
	var currentUser : String = ""
	var downloadPathString : String = ""
    var downloadPathUrl : URL? = nil
	
	var taskQueue = DispatchQueue.global(qos: .background)

    func applicationDidFinishLaunching(_ aNotification: Notification) {
		/* This next block of code helps us findout who's running the program
		 * and the default download directory
		 */
		let task = Process()
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
		
		// Set current user for paths
		currentUser = output[0]
		print("Found current user: " + currentUser)
		
		// Give ourselves a little bit of feedback
		print("setting default download folder")
		downloadPathString = "/Users/" + currentUser + "/Downloads"
		print("current download path set to: " + downloadPathString)
        downloadPathUrl = Foundation.URL(string: downloadPathString)!
		
		// Setup some of the interface
        downloadPathBar.url = downloadPathUrl
		
    }

    func applicationWillTerminate(_ aNotification: Notification) {}
    
    @IBAction func selectDownloadPath(_ sender: NSButton) {
        // Create a file picker panel for us
        let openPanel = NSOpenPanel()
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = true
        openPanel.canCreateDirectories = true
        openPanel.canChooseFiles = false
        openPanel.begin { (result) -> Void in
            // If the user hits okay, set the new download path
            if result == NSFileHandlingPanelOKButton {
                //If there's only one URL, surely 'openPanel.URL'
				self.downloadPathUrl = openPanel.url
				self.downloadPathString = self.downloadPathUrl!.path
				self.downloadPathBar.url = self.downloadPathUrl
            }
        }
    }
    
    @IBAction func startDownloadNow(_ sender: NSButton) {
		// Check if there's actually a link to download from
		if (megaLinkUrl.stringValue != "") {
			taskQueue.async {
				let bundle = Bundle.main
				let task = Process()
				let pipe = Pipe()
				let path = bundle.path(forResource: "megadl", ofType: "")
				
				task.launchPath = path
				task.arguments = ["--path", self.downloadPathString, self.megaLinkUrl.stringValue]
				task.standardOutput = pipe
				task.launch()
				
				self.chooseDownloadLocationButton.isEnabled = false
				self.downloadLinkButton.isEnabled = false
				
				task.waitUntilExit()
				
				self.chooseDownloadLocationButton.isEnabled = true
				self.downloadLinkButton.isEnabled = true
				
				let status = task.terminationStatus
				print(status)
			}
		}
		else {
			print("No link inserted!")
			consoleOutput.string = "****************************\n***  No link inserted!  ****"
		}
    }
	
}

