//
//  SafariWindowExtension.swift
//  WindowTabManangement Extension
//
//  Created by Prasana Kannan on 26/01/20.
//  Copyright © 2020 Prasana Kannan. All rights reserved.
//
import Foundation
import SafariServices
import SafariServices.SFSafariApplication



/**
 SafariWindowExtensionProtocol provide basic structure which all SFSafariTab, SFSafariWindow and SFSafariWindow should comply
 
 MARK: SafariWindowExtensionProtocol
 **/
protocol SafariWindowExtensionProtocol: SafariWTPExtensionProtocol {
    // get all the windows and their id
    static func getAllWindowsWithID(completion: @escaping ([WindowGUID: SFSafariWindow]) -> ())
}


extension SafariWindowExtensionProtocol {
    /**
         Get all the windows and their id
         - Returns: Return the dictionary of windowID and corresponding window
     
         MARK: getAllWindowsWithID
        **/
    static func getAllWindowsWithID(completion: @escaping ([WindowGUID : SFSafariWindow]) -> ()) {
        var windowIDList: [WindowGUID: SFSafariWindow] = [:]
        
        SFSafariApplication.getAllWindows { windowList in
            windowList.forEach{ currentWindow in
                windowIDList[currentWindow.id] = currentWindow;
            }
            completion(windowIDList);
        }
    }
    
}

/**
 Extending SFSafariWindow object to add feature like id and getWindow functionalities
 
 MARK: SFSafariWindow
 **/
//extension SFSafariWindow: SafariWindowExtensionProtocol {
extension SFSafariWindow: SafariWindowExtensionProtocol {
    
    // WindowGUID represent the identifier for the window
    typealias Guid = WindowGUID
    
    /**
        getWindow is Resposible for fetch the window using corresponding windowID
     
         - parameter usingWindowID : pageID of the page which needs to be retreived
         - Returns: It return corresponding SFSafariPage
     
         MARK: getWindow
         **/
    class func getWindow(usingWindowID windowID: WindowGUID, completionHandler: @escaping (SFSafariWindow?) -> ()) {
        getAllWindowsWithID { windowsList in
            
            let foundWindow = windowsList.filter { currentWindowID, currentWindow in
                return currentWindowID == windowID
            }.first?.value
            
            completionHandler(foundWindow);
        }
    }
    
    // window added event listener
    public class func onWindowAdded(action: @escaping (Any?) -> ()) {
        WindowTabEventManager.onWindowAdded(action: action)
    }
    
    // window removed event listener
    public class func onWindowRemoved(action: @escaping (Any?) -> ()) {
        WindowTabEventManager.onWindowRemoved(action: action)
    }
    
}






