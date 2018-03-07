//
//  ViewController.swift
//  PregBuddy
//
//  Created by Bibin P Sebastian on 3/6/18.
//  Copyright © 2018 Bibin P Sebastian. All rights reserved.
//

import UIKit
import TwitterKit

class SearchViewController: UIViewController{
    @IBOutlet weak var tweetTableView: UITableView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var filterButton: UIButton!
    
    private var totalTweets = [TWTRTweet]()
    private var tableViewSource = [TWTRTweet]()
    private var lastLoadedPage = 0
    private var isLoading = false
    private var refreshControl = UIRefreshControl()
    
    let saveStateText = "hearts"
    let unsaveStateText = "heartsBlack"
    
    enum filterMode:String{
        
        case None = "Home"
        case Top10Retweeted = "Top Retweeted Tweets"
        case Top10Liked = "Top liked Tweets"
    }
    
    var currentMode:filterMode = .None {
        
        didSet {
            self.channgedMode(mode: currentMode)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureTableView()
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if self.totalTweets.count == 0 {
            self.searchAPI()
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func configureTableView(){
        self.tweetTableView.rowHeight = UITableViewAutomaticDimension
        self.tweetTableView.estimatedRowHeight = 50
        
        refreshControl.addTarget(self, action: #selector(searchAPI), for: UIControlEvents.valueChanged)
        self.tweetTableView.addSubview(refreshControl)
        
        let tableVC = UITableViewController()
        tableVC.tableView = self.tweetTableView
        tableVC.refreshControl = refreshControl
        
    }

    @objc func searchAPI(){
        let x = PBActivityView()
        x.startAnimating(onView: self.view)
        let client = TWTRAPIClient()
        let statusesShowEndpoint = "https://api.twitter.com/1.1/search/tweets.json"
        let params = ["q": "pregnancy","count":"100"]
        var clientError : NSError?
        
        let request = client.urlRequest(withMethod: "GET", urlString: statusesShowEndpoint, parameters: params, error: &clientError)
        
        client.sendTwitterRequest(request) { (response, data, connectionError) -> Void in
            self.refreshControl.endRefreshing()
            x.stopanimating()
            if connectionError != nil {
                
            }
            
            do {
                if let _ = data, let json = try JSONSerialization.jsonObject(with: data!, options: []) as? [String:Any],let tweets = json["statuses"] as? [[String:Any]]{
                    if let tweetsObjects = TWTRTweet.tweets(withJSONArray: tweets) as? [TWTRTweet]{
                        self.totalTweets = tweetsObjects
                        self.lastLoadedPage = 0
                        self.tweetTableView.reloadData()
                    }
                   
                }
            } catch {
                
            }
        }
    }
    @IBAction func filterButtonTapped(_ sender: Any) {
        self.showFilterSelectionMode()
    }
    
}

extension SearchViewController:UITableViewDataSource,UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.currentMode == .None {
            self.tableViewSource = self.totalTweets
            let x = (lastLoadedPage + 1)*20
            let count = (x < self.tableViewSource.count ? x : self.tableViewSource.count)
            self.tweetTableView.isHidden = count == 0 ?  true : false
            return count
        }
        else if self.currentMode == .Top10Liked {
            self.tableViewSource = self.topLikedTweets()
            
        }
        else {
            self.tableViewSource = self.topRetweetedTweeta()
        }
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
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        //Use the respective pagination api calls if needed.
        if (self.currentMode == .None) {
        if indexPath.row + 1 == tableView.numberOfRows(inSection: 0) && !self.isLoading && (lastLoadedPage+1)*20 < self.tableViewSource.count {
            self.lastLoadedPage += 1
            self.isLoading = true 
            self.tweetTableView.reloadData()
            self.isLoading = false
        }
        }
    }
}

extension SearchViewController {
    
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
    }
    
    func topLikedTweets() -> [TWTRTweet]{
        
       let x = self.totalTweets.sorted { (a, b) -> Bool in
            
            return a.likeCount > b.likeCount
        }
        
        return x.count > 10 ? Array(x[0...9]) : x
    }
    
    func topRetweetedTweeta() -> [TWTRTweet] {
        let x = self.totalTweets.sorted { (a, b) -> Bool in
            
            return a.retweetCount > b.retweetCount
        }
        
        return x.count > 10 ? Array(x[0...9]) : x
    }
    
    func channgedMode(mode:filterMode) {
        
        self.titleLabel.text = mode.rawValue
        self.tweetTableView.reloadData()
        if mode == .None {
            self.filterButton.setImage(UIImage(named:"filter"), for: .normal)
        }
        else {
            self.filterButton.setImage(UIImage(named:"filterFilled"), for: .normal)
        }
    }
    
    func showFilterSelectionMode(){
        
        let attachmentSelectionView = UIAlertController(title: "Choose Filter", message: nil, preferredStyle: .actionSheet)
        let cancelActionButton = UIAlertAction(title: filterMode.None.rawValue, style: .cancel) { _ in
            //            print("Cancel")
            self.currentMode = .None
        }
        
        
        let top10liked = UIAlertAction(title: filterMode.Top10Liked.rawValue, style: .default)
        { _ in
            self.currentMode = .Top10Liked
            
        }
        
        
        let top10Retweeted = UIAlertAction(title: filterMode.Top10Retweeted.rawValue, style: .default)
        { _ in
            self.currentMode = .Top10Retweeted
        }
        attachmentSelectionView.addAction(cancelActionButton)
        attachmentSelectionView.addAction(top10liked)
        attachmentSelectionView.addAction(top10Retweeted)
        if let appdelegate = UIApplication.shared.delegate as? AppDelegate{
            
            appdelegate.window?.rootViewController!.present(attachmentSelectionView, animated: true, completion: nil)
        }
        
    }
}

