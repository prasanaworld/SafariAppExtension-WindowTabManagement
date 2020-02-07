# SafariAppExtension-WindowTabManagement
A Demo POC adding window-tab Management functionality to safariAppExtension. 


### Supported Features
+ [X] Identifier for Window, Tab and Page
+ [x] Tab added listeners
+ [x] Tab removed listener
+ [x] Tab Updated listener  
+ [x] Window added listener
+ [x] Window removed listener

### Enhancement 
+ [ ] Performance Improvement
+ [ ] :bug: Bug Fixes


### Example

##### Listener Register

```swift
        SFSafariWindow.onWindowAdded { windowList in
            // callback invoked when new window added
            print("NEW WINDOW Added are", windowList); // windowlist - specifies list of newly window added window
            // implementation when new window added 
        }
      
        SFSafariWindow.onWindowRemoved { windowList in
            // callback invoked when  window removed
            print("WINDOW Removed are", windowList); // windowlist - specifies list of  window removed
            // implementation when window removed
        }
        
        SFSafariTab.onTabAdded { tabList in
             // callback invoked when tab is updated
            print("Tab Added are", tabList); // windowlist - specifies list of  window added
        }
        
        SFSafariTab.onTabRemoved { tabList in
            // callback invoked when tab is removed
            print("Tab Removed are", tabList); // tabList - specifies list of  tab removed
        }
        
        SFSafariTab.onTabUpdated { tabList in
            // callback invoked when tab is updated
            print("Tab updated are", tabList); // tabList - specifies list of  tab updated
        }
```

##### Identifier

```swift
 SFSafariWindow.id  // instance of safari window can be accessed with id
 
 SFSafariTab.id // instance of the safari tab can be accessed with  id
 
 SFSafariPage.id // instance of the safari page can be accessed with id

```

### Setup

+ Include the following files to Extension.
  + CustomEvent.swift
  + SafariTabExtension.swift		
  + SafariWindowExtension.swift		
  + SafariPageExtension.swift		
  + SafariWTPExtensionProtocol.swift	
  + SafariWindowTabManager.swift
  + safariWTPManager.js // runs as content script in browser
  
+ Update the info.plist file to include the `safariWTPManager.js` file
```xml
    <dict>
        <key>Script</key>
        <string>safariWTPManager.js</string>
    </dict>
```
+ Register the `analyzeEventMessage` as show below in `SafariExtensionHandler` class
```swift
    //  include the below line in messageReceived of SafariExtensionHandler
    WindowTabEventManager.analyzeEventMessage(message: messageName, page: page)
```

```swift    
    override func messageReceived(withName messageName: String, from page: SFSafariPage, userInfo: [String : Any]?) { 
        // Should ProcessMessage to know whether it window/tab/page related Event
        WindowTabEventManager.analyzeEventMessage(message: messageName, page: page)
    }
```
+ That's all Folks, Enjoy :)


**Note**: Since the extension is unsigned, Please select `Allow unsigned Extension` in safari toolbar (*developer* -> *Allow unsigned Extension*) before installing the extension.


If you would like to contribute to improve the code, Please feel free to raise a PR. Also, You can also reach out to me using [twitter](https://twitter.com/prasanaworld) or [Linkedin](https://www.linkedin.com/in/prasanakannan/). 👍
