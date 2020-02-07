// Never exclude this file from info.plist, it will break the window/tab management
(function (global) {
    "use strict";
 
     const safariWTPManager = (function safariWTPManager() {
       const PAGE_EVENT = {
         PAGE_LOAD_EVENT : "PAGE_LOAD",
         PAGE_UNLOAD_EVENT: "PAGE_UNLOADED",
         PAGE_SHOWN_EVNET: "PAGE_SHOWN"
       };
                               
       const isPageLoadHappen = false;
       
       const extension = safari.extension;
       
       // Check if the frame is top window
       function isTopWindow() {
            return (window.top === window);
       }
       
       // handle tab load event
       function handleTabLoad(event) {
           if (isTopWindow()) {
                extension.dispatchMessage(PAGE_EVENT.PAGE_LOAD_EVENT);
                isPageLoadHappen = true;
           }
       }
       
        // handle tab unload event
       function handleTabUnload(event) {
           if (isTopWindow()) {
                extension.dispatchMessage(PAGE_EVENT.PAGE_UNLOAD_EVENT);
           }
       }
        
        // handle tab visibility change event
       function handleTabVisibility(event) {
           if (isPageLoadHappen) {
               // send Message on both page shown and page hide event
               extension.dispatchMessage(PAGE_EVENT.PAGE_SHOWN_EVNET);
           }
           isPageLoadHappen = false;
       }
                            

       document.addEventListener("DOMContentLoaded", handleTabLoad);
       global.addEventListener("beforeunload", handleTabUnload);
       document.addEventListener("visibilitychange", handleTabVisibility);
                               
    })();
 
})(window);
