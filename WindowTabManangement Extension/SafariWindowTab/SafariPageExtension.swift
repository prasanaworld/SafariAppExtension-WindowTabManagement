//
//  SafariPageExtension.swift
//  WindowTabManangement Extension
//
//  Created by Prasana Kannan on 26/01/20.
//  Copyright © 2020 Prasana Kannan. All rights reserved.
//
import Foundation
import SafariServices
import SafariServices.SFSafariApplication


/**  SafariPageExtension provide basic structure which all SFSafariPage should comply
 
 MARK: SafariWindowExtensionProtocol
 **/
protocol SafariPageExtension: SafariWTPExtensionProtocol {
    
    // Get all the pages for the list of  specified tablist
    static func getPagesForTab(tabList: [SFSafariTab], completionHandler: @escaping ([PageGUID: SFSafariPage]) -> ())
    
    // Get all the windows and their id
    static func getAllPagesWithID(completionHandler: @escaping ([PageGUID: SFSafariPage]) -> ())
}

extension SafariPageExtension {
    
    /** Get all the pages for the list of  specified tablist
     - Returns: Callback with the dictionary of PageID and corresponding page
     
     MARK: getPagesForTab
     **/
    static func getPagesForTab(tabList: [SFSafariTab], completionHandler: @escaping ([PageGUID: SFSafariPage]) -> ()) {
        var pageIDList: [PageGUID: SFSafariPage] = [:]
        let dispatchGroup = DispatchGroup()
        
        tabList.forEach { currentTab in
            dispatchGroup.enter()
            currentTab.getPagesWithCompletionHandler{ pageList in
                pageList?.forEach { currentPage in
                    pageIDList[currentPage.id] =  currentPage;
                }
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: DispatchQueue.main) {
            completionHandler(pageIDList)
        }
    }
    
    /** Get all the Page and their id
     - Returns: Return the dictionary of PageID and corresponding Page
     
     MARK: getAllPagesWithID
     **/
    static func getAllPagesWithID(completionHandler: @escaping ([PageGUID : SFSafariPage]) -> ()) {
        SFSafariTab.getAllTabsWithID { tabs in
            let tabList = Array(tabs.values);
            
            getPagesForTab(tabList: tabList) { pageIDList in
                completionHandler(pageIDList)
            }
        }
    }
}



/**
 Extending SFSafariPage object to add feature like id and getPage functionalities
 
 MARK: SFSafariPage
 **/
//extension SFSafariPage: SafariPageExtension {
extension SFSafariPage: SafariPageExtension {
    
    // PageGUID represent the identifier for the page
    typealias Guid = PageGUID
    
    /** getPage is Resposible for fetch the page using corresponding pageID
     
     - parameter usingPageID : pageID of the page which needs to be retreived
     - Returns: It return corresponding SFSafariPage
     
     MARK: getPage
     **/
    class func getPage(usingPageID pageID: PageGUID, completionHandler: @escaping (SFSafariPage?) -> ()) {
        getAllPagesWithID { pages in
            
            let foundPage = pages.filter{ currentPageID, currentPage in
                return currentPageID == pageID
                }.first?.value;
            
            completionHandler(foundPage);
        }
        
    }
}
