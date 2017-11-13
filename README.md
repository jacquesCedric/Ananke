# Ananke ![](https://github.com/jacquesCedric/Ananke/blob/master/megadl/Assets.xcassets/AppIcon.appiconset/icon_32x32.png?raw=true)

![](https://github.com/jacquesCedric/Ananke/blob/master/anankeScreen.png?raw=true)  
A macOS application that allows you to download files and folders from the popular file-sharing service, Mega.nz. This used to allow users to bypass download restrictions.

Now deprecated as mega has patched this aspect of their api.

### Prerequisites
- MacOS 10.11 or greater
- Have Homebrew installed [[link](https://brew.sh/)]

### How to use
1. Install megatools

 ~~~~
 brew install megatools
 ~~~~
2. Download the app from the [Releases page](https://github.com/jacquesCedric/Ananke/releases) or, optionally, compile from source (see below)
3. Unzip and place in Applications folder
4. Open Application
5. Paste in a Mega link
6. Choose a download location
7. Download!

### Compilation
1. Clone source
2. Open project in Xcode
3. Compile/run

### Notes
GPLv3 Licensed.  
Relies on the excellent [megatools command line tool](https://github.com/megous/megatools).  
Built with Xcode 7.3.1 on macOS 10.11.4  
