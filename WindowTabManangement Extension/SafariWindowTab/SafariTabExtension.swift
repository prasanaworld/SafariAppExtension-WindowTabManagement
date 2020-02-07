//
//  SafariTabExtension.swift
//  WindowTabManangement Extension
//
//  Created by Prasana Kannan on 26/01/20.
//  Copyright © 2020 Prasana Kannan. All rights reserved.
//
import Foundation
import SafariServices
import SafariServices.SFSafariApplication


/**
 SafariTabExtensionProtocol provide basic structure which all SFSafariTab should comply
 
 MARK: SafariWindowExtensionProtocol
 **/
protocol SafariTabExtensionProtocol: SafariWTPExtensionProtocol {
    
    // Get all the tabs for the list windows specified
    static func getTabforWindow(windowList: [SFSafariWindow], completionHandler: @escaping ([TabGUID: SFSafariTab]) -> ())
    
    // Get all the windows and their id
    static func getAllTabsWithID(completionHandler: @escaping ([TabGUID: SFSafariTab]) -> ())
}

extension SafariTabExtensionProtocol {
    
    /**
        Get all the tabs for the list windows specified
        - Returns: Callback with the dictionary of TabID and corresponding Tab
     
        MARK: getTabforWindow
        **/
    static func getTabforWindow(windowList: [SFSafariWindow], completionHandler: @escaping ([TabGUID: SFSafariTab]) -> ()) {
        var tabIDList: [TabGUID: SFSafariTab] = [:]
        let dispatchGroup = DispatchGroup()
        
        windowList.forEach { currentWindow in
            dispatchGroup.enter()
            
            currentWindow.getAllTabs { tabList in
                tabList.forEach{ currentTab in
                    tabIDList[currentTab.id] = currentTab;
                }
                
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: DispatchQueue.main) {
            completionHandler(tabIDList)
        }
    }
    
    /**
         Get all the Tab and their id
         - Returns: Callback with the dictionary of TabID and corresponding Tab
     
         MARK: getAllTabsWithID
        **/
    static func getAllTabsWithID(completionHandler: @escaping ([TabGUID: SFSafariTab]) -> ()) {
    
        SFSafariWindow.getAllWindowsWithID { (windows: [WindowGUID: SFSafariWindow]) in
            let windowList = Array(windows.values)

            getTabforWindow(windowList: windowList) { tabsList in
                completionHandler(tabsList)
            }
        }
    }
}

/**
 Extending SFSafariTab object to add feature like id and getTab functionalities
 
 MARK: SFSafariTab
 **/
//extension SFSafariTab: SafariTabExtensionProtocol {
extension SFSafariTab: SafariTabExtensionProtocol {
    
    // TABGUID represent the identifier for the tab
    typealias Guid = TabGUID
    
    
    /**
     getTab is Resposible for fetch the tab using corresponding tabID
     
     - parameter byTabId : tabID of the tab which needs to be retreived
     - Returns: It return corresponding SFSafariTab
     
     MARK: getTab
     **/
    class func getTab(usingTabID tabID: TabGUID, completionHandler: @escaping (SFSafariTab?) -> ()) {
        getAllTabsWithID { tabs in
            let foundTab = tabs.filter{ currentTabID, currentTab in
                return currentTabID == tabID
                }.first?.value
            
            completionHandler(foundTab);
        }
    }
    
    // Tab added event listener
    public class func onTabAdded(action: @escaping (Any?) -> ()) {
        WindowTabEventManager.onTabAdded(action: action);
    }
    
    // Tab removed event listener
    public static func onTabRemoved(action: @escaping (Any?) -> ()) {
        WindowTabEventManager.onTabRemoved(action: action)
    }
    
    // Tab updated event listener
    public static func onTabUpdated(action: @escaping (Any?) -> ()) {
        WindowTabEventManager.onTabUpdated(action: action)
    }
}
