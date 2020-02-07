//
//  SafariExtensionHandler.swift
//  WindowTabManangement Extension
//
//  Created by Prasana Kannan on 26/01/20.
//  Copyright © 2020 Prasana Kannan. All rights reserved.
//

import SafariServices


class SafariExtensionHandler: SFSafariExtensionHandler {
    
    override func messageReceived(withName messageName: String, from page: SFSafariPage, userInfo: [String : Any]?) {
        
        if (!Demo.isRegistered) {
            Demo.register();
        }
        
        // Should ProcessMessage to know whether it window/tab/page related Event
        WindowTabEventManager.analyzeEventMessage(message: messageName, page: page)
    }
    
    override func toolbarItemClicked(in window: SFSafariWindow) {
        // This method will be called when your toolbar item is clicked.
        print(window.id)
        
        // Print the list of windows and their corresponding ID
        SFSafariWindow.getAllWindowsWithID { windowList in
            print("windowList", windowList);
        }
        
        // Print the list of tabs and their corresponding ID
        SFSafariTab.getAllTabsWithID { pageList in
            print("pageList", pageList);
        }
        
    }
    
    override func validateToolbarItem(in window: SFSafariWindow, validationHandler: @escaping ((Bool, String) -> Void)) {
        // This is called when Safari's state changed in some way that would require the extension's toolbar item to be validated again.
        validationHandler(true, "")
    }
    
    override func popoverViewController() -> SFSafariExtensionViewController {
        return SafariExtensionViewController.shared
    }
}
