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


    // initialize app remote
    lazy var appRemote: SPTAppRemote = {
        let appRemote = SPTAppRemote(configuration: configuration, logLevel: .debug)
        appRemote.delegate = self
        
        return appRemote
    }()
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        // SPTConfiguration & SPTSession Manager are both configured
        // Invoke the authorization screen
        let requestedScopes: SPTScope = [.appRemoteControl]
        self.sessionManager.initiateSession(with: requestedScopes, options: .default)
        
        return true
    }

    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        if self.appRemote.isConnected {
            self.appRemote.disconnect()
        }
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
        if let _ = self.appRemote.connectionParameters.accessToken {
            self.appRemote.connect()
        }
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
    // configure authorization callback
    // notifies session manager after the user returns to the app
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
            self.sessionManager.application(app, open: url, options: options)
        
        return true
    }
    
    // Handles authorization
    func sessionManager(manager: SPTSessionManager, didInitiate session: SPTSession) {
        self.appRemote.connectionParameters.accessToken = session.accessToken
        self.appRemote.connect()
        print("success", session)
    }
    func sessionManager(manager: SPTSessionManager, didFailWith error: Error) {
        print("fail", error)
    }
    func sessionManager(manager: SPTSessionManager, didRenew session: SPTSession) {
        print("renewed", session)
    }

    
    // implement methods for app remote play back
    func appRemoteDidEstablishConnection(_ appRemote: SPTAppRemote) {
        print("connected")
        
        self.appRemote.playerAPI?.delegate = self
        self.appRemote.playerAPI?.subscribe(toPlayerState: { (result, error) in
            if let error = error {
                debugPrint(error.localizedDescription)
            }
        })
    }
    func appRemote(_ appRemote: SPTAppRemote, didDisconnectWithError error: Error?) {
        print("disconnected")
    }
    func appRemote(_ appRemote: SPTAppRemote, didFailConnectionAttemptWithError error: Error?) {
        print("failed")
    }
    
    
    // log state of player output
    func playerStateDidChange(_ playerState: SPTAppRemotePlayerState) {
        debugPrint("Track name: %@", playerState.track.name)
        
        // print statements from Spotify's gist
        print("player state changed")
        print("isPaused", playerState.isPaused)
        print("track.uri", playerState.track.uri)
        print("track.name", playerState.track.name)
        print("track.imageIdentifier", playerState.track.imageIdentifier)
        print("track.artist.name", playerState.track.artist.name)
        print("track.album.name", playerState.track.album.name)
        print("track.isSaved", playerState.track.isSaved)
        print("playbackSpeed", playerState.playbackSpeed)
        print("playbackOptions.isShuffling", playerState.playbackOptions.isShuffling)
        print("playbackOptions.repeatMode", playerState.playbackOptions.repeatMode.hashValue)
        print("playbackPosition", playerState.playbackPosition)
    }

}
