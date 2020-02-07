//
//  DemoEvent.swift
//  WindowTabManangement Extension
//
//  Created by Prasana Kannan on 27/01/20.
//  Copyright © 2020 Prasana Kannan. All rights reserved.
//
import Foundation
import SafariServices
import SafariServices.SFSafariApplication


// To demonstrate the listener functionality by registering the listeners and logging on to console
public class Demo {
    
    // State to indicate whether  it is registered or no
    static var isRegistered = false
    
    
    // To register all the window and tab listeners
    static func register() {
        
        isRegistered = true
        
        SFSafariWindow.onWindowAdded { windowList in
            print("NEW WINDOW Added are", windowList);
        }

        SFSafariWindow.onWindowRemoved { windowList in
            print("WINDOW Removed are", windowList);
        }
        
        SFSafariTab.onTabAdded { tabList in
            print("Tab Added are", tabList);
        }
        
        SFSafariTab.onTabRemoved { tabList in
            print("Tab Removed are", tabList);
        }
        
        SFSafariTab.onTabUpdated { tabList in
            print("Tab updated are", tabList);
        }
    }
}











