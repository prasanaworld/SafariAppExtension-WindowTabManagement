//
//  SafariWindowManager.swift
//  WindowTabManangement Extension
//
//  Created by Prasana Kannan on 26/01/20.
//  Copyright © 2020 Prasana Kannan. All rights reserved.
//
import Foundation
import SafariServices
import SafariServices.SFSafariApplication


/**
 WindowTabEventManager provide the core functionality of handling the event received from page
 
 MARK: SafariWindowExtensionProtocol
 **/
class WindowTabEventManager  {
    
    // Concurrent queue for Event processing
    static let tabEventManagerQueue =  DispatchQueue(label: "windowTabEventManager-Parellel-queue", qos: .default, attributes: .concurrent)
    
    // Concurrent queue for Event dispatcher
    static let tabEventDipatcherQueue =  DispatchQueue(label: "EventDispatch-Parellel-queue", qos: .default, attributes: .concurrent)
    
    // Browser Tab lifecycle event
    public enum BrowserPageEvent: String {
        case PAGE_LOAD_EVENT = "PAGE_LOAD"
        case PAGE_UNLOAD_EVENT = "PAGE_UNLOADED"
        case PAGE_SHOWN_EVENT = "PAGE_SHOWN"
    }
    
    // Window / Tab event
    public enum WTEvents {
        case ADDED
        case REMOVED
        case UPDATED
    }
    
    // Category of the Event - window / Tab
    public enum WTEventCategory {
        case WINDOW_EVENTS
        case TAB_EVENTS
    }
    
    // Window Events
    public enum WINDOW_EVENTS: String {
        case ADDED = "WINDOW_ADDED"
        case REMOVED = "WINDOW_REMOVED"
        case UPDATED = "WINDOW_UPDATED"
    }
    
    // Tab Events
    public enum TAB_EVENTS: String {
        case ADDED = "TAB_ADDED"
        case REMOVED = "TAB_REMOVED"
        case UPDATED = "TAB_UPDATED"
    }
    
    public static let event = CustomEvent()
    
    private static var windowList: Set<String> = []
    private static var tabList: Set<String> = []
    
    // Check to find out the difference and identify whether a tab/window added, removed or updated
    private static func comparator(oldList: Set<String>, newList: Set<String>, pageEvent: BrowserPageEvent) -> (WTEvents, Set<String>?) {
        
        if pageEvent == .PAGE_LOAD_EVENT || pageEvent == .PAGE_SHOWN_EVENT  {
            // comparing previouslist with current new list - to check if new Window/Tab is added
            let isAdded = newList.subtracting(oldList)
            
            if !isAdded.isEmpty {
                return (.ADDED, isAdded)
            }
        }
        
        if pageEvent == .PAGE_UNLOAD_EVENT || pageEvent == .PAGE_SHOWN_EVENT  {
            // comparing previouslist with current new list - to check if new Window/Tab is removed
            let isRemoved = oldList.subtracting(newList)
            
            if !isRemoved.isEmpty {
                return (.REMOVED, isRemoved)
            }
        }
        
        return (.UPDATED, nil)
    }
    
    private static func handleWindowEvent(usingPage page: SFSafariPage, currentWindowList:  Set<String>, pageEvent: BrowserPageEvent) {
        
        let (eventType, eventData) = comparator(oldList: windowList, newList: currentWindowList, pageEvent: pageEvent)
        
        windowList = currentWindowList
        
        if pageEvent == .PAGE_SHOWN_EVENT {
            return
        }
        
        if let currentData = eventData {
            return dispatchEvent(eventCategory: .WINDOW_EVENTS, eventType: eventType, eventInfo: currentData)
        }
    }
    
    // Handle Tab Events
    private static func handleTabEvent(usingPage page: SFSafariPage, currentTabList: Set<String>, pageEvent: BrowserPageEvent) {
        let (eventType, eventData) = comparator(oldList: tabList, newList: currentTabList, pageEvent: pageEvent);
        
        tabList = currentTabList
        
        if let currentData = eventData {
            return dispatchEvent(eventCategory: .TAB_EVENTS, eventType: eventType, eventInfo: currentData)
        }
        
        if pageEvent == .PAGE_SHOWN_EVENT {
            return
        }
        
        // On tab-updated no-diff is found (eventData) so fetch the current Tab id (main page of the Tab which send the event)
        page.getContainingTab { currentTab in
            return dispatchEvent(eventCategory: .TAB_EVENTS, eventType: eventType, eventInfo: Set([currentTab.id]))
        }
    }
    
    // Handle window Events
    private static func handleWindowTabEvent(usingPage page: SFSafariPage, pageEvent: BrowserPageEvent) {
        // Handle window event - add/remove
        tabEventManagerQueue.async {
            SFSafariWindow.getAllWindowsWithID { currentWindowList in
                handleWindowEvent(usingPage: page, currentWindowList: Set<String>(currentWindowList.keys), pageEvent: pageEvent)
            }
        }
        
        // Handle tab event - add/remove/update
        tabEventManagerQueue.async {
            SFSafariTab.getAllTabsWithID { currentTabList in
                handleTabEvent(usingPage: page, currentTabList: Set<String>(currentTabList.keys), pageEvent: pageEvent)
            }
        }
    }
    
    /**
          Event dispatcher based on the event received from the page
          category - Window / Tab
          eventType - Added / Removed / Updated
        **/
    private static func dispatchEvent(eventCategory: WTEventCategory, eventType: WTEvents, eventInfo: Set<String>) {
        tabEventDipatcherQueue.async {
            let eventData = Array(eventInfo);
            switch (eventCategory, eventType) {
                case (.WINDOW_EVENTS, .ADDED):
                    event.trigger(topic: WINDOW_EVENTS.ADDED.rawValue, info: eventData)
                    break
                case (.WINDOW_EVENTS, .REMOVED):
                    event.trigger(topic: WINDOW_EVENTS.REMOVED.rawValue, info: eventData)
                    break
                case (.TAB_EVENTS, .ADDED):
                    event.trigger(topic: TAB_EVENTS.ADDED.rawValue, info: eventData)
                    break
                case (.TAB_EVENTS, .REMOVED):
                    event.trigger(topic: TAB_EVENTS.REMOVED.rawValue, info: eventData)
                    break
                case (.TAB_EVENTS, .UPDATED):
                    event.trigger(topic: TAB_EVENTS.UPDATED.rawValue, info: eventData)
                    break
                default:
                    break
            }
        }
    }
    
    // Analyze the message and check if the message is a browser event
    public static func analyzeEventMessage(message: String, page: SFSafariPage) {
        let pageEvent = BrowserPageEvent(rawValue: message);
        
        switch pageEvent {
            case .PAGE_LOAD_EVENT?, .PAGE_UNLOAD_EVENT?, .PAGE_SHOWN_EVENT?:
                handleWindowTabEvent(usingPage: page, pageEvent: pageEvent!)
                break;
            case .none:
                break;
        }
    }
    
    
    // Event registration function when a new window is added
    public static func onWindowAdded(action: @escaping (Any) -> ()) {
        WindowTabEventManager.event.addEventListener(topic: WINDOW_EVENTS.ADDED.rawValue, action: action)
    }
    
    // Event registration function when a window is removed
    public static func onWindowRemoved(action: @escaping (Any) -> ()) {
        WindowTabEventManager.event.addEventListener(topic: WINDOW_EVENTS.REMOVED.rawValue, action: action)
    }
    
    // Event registration function when a new tab is added
    public static func onTabAdded(action: @escaping (Any) -> ()) {
        WindowTabEventManager.event.addEventListener(topic: TAB_EVENTS.ADDED.rawValue, action: action)
    }
    
    // Event registration function when a tab gets removed
    public static func onTabRemoved(action: @escaping (Any) -> ()) {
        WindowTabEventManager.event.addEventListener(topic: TAB_EVENTS.REMOVED.rawValue, action: action)
    }
    
    // Event registration function when a tab gets updated
    public static func onTabUpdated(action: @escaping (Any) -> ()) {
        WindowTabEventManager.event.addEventListener(topic: TAB_EVENTS.UPDATED.rawValue, action: action)
    }
}


