//
//  EventManager.swift
//  WindowTabManangement Extension
//
//  Created by Prasana Kannan on 27/01/20.
//  Copyright © 2020 Prasana Kannan. All rights reserved.
//
import Foundation


// Responsible for holding custom Event Action
class EventActionHolder {
    let action:((Any?) -> ())?;
    
    init(callback: @escaping ((Any?) -> ()) ) {
        self.action = callback;
    }
}

// Responsible for Managing Event - Add, Remove and Trigger of Event
class CustomEvent {
    
    // NSMutableArray for dynamic modification of Array
    var listeners = Dictionary<String, NSMutableArray>();
    
    /**
     Add a new Event to the listener for specific
     -parameter topic : topic to be enrolled
     -action: The block of code you want executed when the event triggers
     **/
    func addEventListener(topic:String, action: @escaping ((Any?)->())) {
        let newListener = EventActionHolder(callback: action);
        
        if let listenerArray = self.listeners[topic] {
            // Eary return
            return listenerArray.add(newListener);
        }
        
        self.listeners[topic] = [newListener] as NSMutableArray;
    }
    
    /**
     Removes all listeners by default, or specific listeners through paramters
     -parameter topic: If an event name is passed, only listeners for that event will be removed
     **/
    func removeEventListeners(topic:String?) {
        
        guard let unSubscribedTopic = topic else {
            self.listeners.removeAll(keepingCapacity: false);
            return
        }
        
        
        if let actionArray = self.listeners[unSubscribedTopic] {
            actionArray.removeAllObjects();
        }
        
    }
    
    /**
     Triggers an event for the specific eventName
     -parameter topic:
     -parameter info: data to be passed
     **/
    func trigger(topic:String, info: Any? = nil) {
        
        guard let actions = self.listeners[topic]  else {
            return debugPrint("No Listeners are registered");
        }
        
        actions.forEach { [unowned self] action in
            if let actionMethod = action as? EventActionHolder,
                let method = actionMethod.action {
                method(info);
            }
        }
    }
}
