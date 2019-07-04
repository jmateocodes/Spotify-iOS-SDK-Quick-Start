//
//  AppDelegate.swift
//  Spotify iOS SDK Quick Start
//
//  Created by Johanny Mateo on 7/3/19.
//  Copyright © 2019 Johanny A. Mateo. All rights reserved.
//

import UIKit

// Added 'SPTSessionManagerDelegate' to handle authorization
// Added 'SPTAppRemote...' to allow connections & playback states

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, SPTSessionManagerDelegate, SPTAppRemoteDelegate, SPTAppRemotePlayerStateDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    // Implemented the 3 methods below to handle auth.
    func sessionManager(manager: SPTSessionManager, didInitiate session: STPSession) {
        print("success", session)
    }
    
    func sessionManager(manager: SPTSessionManager, didFailWith error: Error) {
        print("fail", error)
    }
    
    func sessionManager(manager: SPTSessionManager, didRenew session: SPTSession) {
        print("renewed", session)
    }
    
    // Instantiate SPTConfiguration
    // Define CLient ID, Redirect URI, and initiate the SDK
    let SpotifyClientID = "f29ed6af2017417583694445c09cfd82"
    let SpotifyRedirectURL = URL(string: "spotify-ios-quick-start://spotify-login-callback")!
    
    lazy var configuration = SPTConfiguration(clientID: SpotifyClientID,
                                              redirectURL: SpotifyRedirectURL)
    
    
    // Set up the token swap (app deployed on Heroku)
    lazy var sessionManager: SPTSessionManager = {
        if let tokenSwapURL = URL(string: "https://spotify-ios-sdk-quick-start.herokuapp.com/api/token"),
            let tokenRefreshURL = URL(string: "https://spotify-ios-sdk-quick-start.herokuapp/api/refresh_token") {
            self.configuration.tokenSwapURL = tokenSwapURL
            self.configuration.tokenRefreshURL = tokenRefreshURL
            
            // playURI allows iOS to wake the Spotify app to play music
            // an empty playURI plays the last song, else it will play the requested track's URI
            self.configuration.playURI = ""
        }
        
        let manager = SPTSessionManager(configuration: self.configuration, delegate: self)
        return manager
    } ()
    
    // SPTConfiguration & SPTSession Manager are both configured
    // Invoke the authorization screen
    let requestedScopes: SPTScope = [.appRemoteControl]
    self.sessionManager.initiateSession(with: requestedScopes, options: .default)
    
    // configure authorization callback
    // notifies session manager after the user returns to the app
    func application(_app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
            self.sessionManager.application(app, open: url, options: options)
                return true
    }

    
    // implement methods for app remote play back
    func appRemoteDidEstablishConnection(_appremote: SPTAppRemote) {
        print("connected")
    }
    
}
