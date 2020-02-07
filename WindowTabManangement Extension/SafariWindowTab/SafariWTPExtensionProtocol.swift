//
//  SafariWTPExtensionProtocol.swift
//  WindowTabManangement Extension
//
//  Created by Prasana Kannan on 26/01/20.
//  Copyright © 2020 Prasana Kannan. All rights reserved.
//
import Foundation
import SafariServices
import SafariServices.SFSafariApplication


protocol SafariWTPExtensionProtocol: Hashable {
    
    // TABGUID represent the identifier for the tab
    typealias TabGUID = String
    
    // PageGUID represent the identifier for the page
    typealias PageGUID = String
    
    // WindowGUID represent the identifier for the window
    typealias WindowGUID = String
    
    // Guid is identifier
    associatedtype Guid where Guid == String
    
    // common identifier implementation for the tab, page and window
    var id: Guid { get }
}


/**
 ISAFIDProvider provide basic structure which all SFSafariTab, SFSafariWindow and SFSafariWindow should comply
 
 MARK: ISAFIDProvider
 **/
var __idValue: String = "";

extension SafariWTPExtensionProtocol {
    
    // common identifier implementation for the tab, page and window
    var id: Guid {
        let id = objc_getAssociatedObject(self.hashValue, &__idValue) as? String

        if let existingGUID = id {
            return existingGUID
        }

        let generatedGUID = UUID().uuidString
        objc_setAssociatedObject(self.hashValue, &__idValue, generatedGUID, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return generatedGUID
    }
}
