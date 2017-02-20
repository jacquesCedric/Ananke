//
//  AppDelegate.swift
//  megadl
//
//  Created by Jacob Gaffney on 18/02/2017.
//  Copyright © 2017 Jacob Gaffney. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
	// Interface related
	@IBOutlet weak var window: NSWindow!
    @IBOutlet var downloadPathBar: NSPathCell!
    @IBOutlet var megaLinkUrl: NSTextField!
	@IBOutlet var consoleOutput: NSTextView!
    @IBOutlet var chooseDownloadLocationButton: NSButton!
    @IBOutlet var downloadLinkButton: NSButton!
	
	// Thing we should know about
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
		
		consoleOutput.font = NSFont(name: "Monaco", size: 9)
		consoleOutput.backgroundColor = NSColor.black
		consoleOutput.textColor = NSColor.green
		
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
		// Check if there's actually a download link in place
		if (megaLinkUrl.stringValue != "") {
			taskQueue.async {
				let bundle = Bundle.main
				let task = Process()
				let pipe = Pipe()
				let path = bundle.path(forResource: "megadl", ofType: "")
				
				task.launchPath = path
				task.arguments = ["--path", self.downloadPathString, self.megaLinkUrl.stringValue]
				task.standardOutput = pipe
				
				// So we can show users what's happening
				self.captureStandardOutputAndRouteToTextView(task)
				
				// Launch our task
				task.launch()
				
				// Stop silly button presses during the download
				self.megaLinkUrl.isEnabled = false
				self.chooseDownloadLocationButton.isEnabled = false
				self.downloadLinkButton.isEnabled = false
				
				task.waitUntilExit()
				
				// Renable our buttons once the download is complete
				self.megaLinkUrl.isEnabled = true
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
	
	// We'll use this to tell users what's happening - show download progress, error, etc...
	func captureStandardOutputAndRouteToTextView(_ task:Process) {
		let outputPipe = Pipe()
		task.standardOutput = outputPipe
		
		outputPipe.fileHandleForReading.waitForDataInBackgroundAndNotify()
			
		// We have to watch for changes so we know when to print them
		NotificationCenter.default.addObserver(forName: NSNotification.Name.NSFileHandleDataAvailable, object: outputPipe.fileHandleForReading , queue: nil) {
			notification in

			// Format our data so we can print it correctly
			let output = outputPipe.fileHandleForReading.availableData
			let outputString = String(data: output, encoding: String.Encoding.utf8) ?? ""
			var formattedString = ""
			
			do {
				let regexString = try NSRegularExpression(pattern: "[0-9][0-9];[0-9]m|\\[|0m|0K|\\?")
				let range = NSMakeRange(0, outputString.characters.count)
				formattedString = regexString.stringByReplacingMatches(in: outputString,
																		options: [],
																		range: range,
																		withTemplate: "")
			} catch {
				print("regex error")
			}
			

			// Do not live in fear of the beach ball
			DispatchQueue.main.async(execute: {
				let previousOutput = self.consoleOutput.string ?? ""
				let nextOutput = previousOutput + "\n" + formattedString
				self.consoleOutput.string = nextOutput

				let range = NSRange(location:nextOutput.characters.count,length:0)
				// Keep the relevant part of the console in view
				self.consoleOutput.scrollRangeToVisible(range)

			})

			outputPipe.fileHandleForReading.waitForDataInBackgroundAndNotify()
		}
			
	}
	
}

