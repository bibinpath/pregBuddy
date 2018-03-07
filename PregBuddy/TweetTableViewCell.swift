//
//  TweetTableViewCell.swift
//  PregBuddy
//
//  Created by Bibin P Sebastian on 3/6/18.
//  Copyright © 2018 Bibin P Sebastian. All rights reserved.
//

import UIKit
import TwitterKit
class TweetTableViewCell: UITableViewCell {
    
    @IBOutlet weak var tweetView: TWTRTweetView!
    @IBOutlet weak var bookMarkButton: UIButton!
    @IBOutlet weak var likeCountLabel: UILabel!
    @IBOutlet weak var retweetCountLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
