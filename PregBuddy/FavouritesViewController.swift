//
//  FavouritesViewController.swift
//  PregBuddy
//
//  Created by Bibin P Sebastian on 3/7/18.
//  Copyright © 2018 Bibin P Sebastian. All rights reserved.
//

import UIKit
import TwitterKit

class FavouritesViewController: UIViewController {

    @IBOutlet weak var favouritesTableView: UITableView!
    
    let saveStateText = "hearts"
    let unsaveStateText = "heartsBlack"
    var tableViewSource = [TWTRTweet]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let bgLabel = UILabel()
        bgLabel.text = "No Favourited Tweets"
        bgLabel.textAlignment = .center
        self.favouritesTableView.backgroundView = bgLabel
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.favouritesTableView.reloadData()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
extension FavouritesViewController:UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableViewSource = Utility.sharedInstance.allSavedTweets() ?? tableViewSource
        tableView.backgroundView?.isHidden = tableViewSource.count > 0
        return tableViewSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "twitterCell") as? TweetTableViewCell {
            
            cell.tweetView.configure(with: self.tableViewSource[indexPath.row])
            cell.tweetView.showBorder = false
            cell.likeCountLabel.text = "\(self.tableViewSource[indexPath.row].likeCount) Likes"
            cell.retweetCountLabel.text = "\(self.tableViewSource[indexPath.row].retweetCount) Retweets"
            cell.bookMarkButton.tag = indexPath.row
            cell.bookMarkButton.addTarget(self, action: #selector(bookMarkAction(sender:)), for: .touchUpInside)
            let savedTweets = Utility.sharedInstance.allSavedTweets()
            let flag = (savedTweets?.filter({ (tweet) -> Bool in
                return tweet.tweetID == self.tableViewSource[indexPath.row].tweetID
            }).count ?? 0 > 0)
            let titleImagex = flag ? UIImage(named: unsaveStateText) : UIImage(named:saveStateText)
            cell.bookMarkButton.setImage(titleImagex, for: .normal)
            cell.bookMarkButton.imageView?.tag = flag ? 1 : -1
            return cell
        }
        return UITableViewCell()
    }
    
    @objc func bookMarkAction(sender:UIButton){
        
        let tweet = tableViewSource[sender.tag]
        if sender.imageView?.tag == -1 {
            Utility.sharedInstance.saveTweetLocally(tweet: tweet)
            sender.setImage(UIImage(named:unsaveStateText), for: .normal)
            sender.imageView?.tag = 1
        }else if sender.imageView?.tag == 1  {
            Utility.sharedInstance.removeSavedTweet(tweet: tweet)
            sender.setImage(UIImage(named:saveStateText), for: .normal)
            sender.imageView?.tag = -1
        }
        self.favouritesTableView.reloadData()
    }

}
