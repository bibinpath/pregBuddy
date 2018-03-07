//
//  Utility.swift
//  PregBuddy
//
//  Created by Bibin P Sebastian on 3/6/18.
//  Copyright © 2018 Bibin P Sebastian. All rights reserved.
//

import Foundation
import TwitterKit

class Utility {
    
    static let sharedInstance = Utility()
    
    private init() {
        
    }
    
    var tweetsFilePath: String {
        let manager = FileManager.default
        let url = manager.urls(for: .documentDirectory, in: .userDomainMask).first
        return (url!.appendingPathComponent("Tweets").path)
    }

    func saveTweetLocally(tweet:TWTRTweet){
        if var savedTweets = NSKeyedUnarchiver.unarchiveObject(withFile: tweetsFilePath) as? [String:TWTRTweet] {
           
           savedTweets[tweet.tweetID] = tweet
           NSKeyedArchiver.archiveRootObject(savedTweets, toFile: tweetsFilePath)
            
        }
        else {
            NSKeyedArchiver.archiveRootObject([tweet.tweetID:tweet], toFile: tweetsFilePath)
        }
        
    }
    
    func removeSavedTweet(tweet:TWTRTweet){
        if var savedTweets = NSKeyedUnarchiver.unarchiveObject(withFile: tweetsFilePath) as? [String:TWTRTweet],let _ = savedTweets[tweet.tweetID] {
            
            savedTweets.removeValue(forKey: tweet.tweetID)
            NSKeyedArchiver.archiveRootObject(savedTweets, toFile: tweetsFilePath)
            
        }
        
    }
    
    func allSavedTweets() -> [TWTRTweet]?{
        if var savedTweets = NSKeyedUnarchiver.unarchiveObject(withFile: tweetsFilePath) as? [String:TWTRTweet]{
            
            let tweets = savedTweets.values.sorted(by: { (a, b) -> Bool in
                return a.tweetID < b.tweetID
            })
            return tweets
        }
        return nil
    }
}
