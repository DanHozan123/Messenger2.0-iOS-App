//
//  ChannelTableViewCell.swift
//  Messenger2.0
//
//  Created by Dan Hozan on 15.02.2024.
//

import UIKit

class ChannelTableViewCell: UITableViewCell {

    //MARK: - IBOutlets
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var aboutLabel: UILabel!
    @IBOutlet weak var memberCountLabel: UILabel!
    @IBOutlet weak var lastMessageDateLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
          super.setSelected(selected, animated: animated)
      }
      
      
      func configure(channel: Channel) {
          
          nameLabel.text = channel.name
          aboutLabel.text = channel.aboutChannel
          memberCountLabel.text = "\(channel.memberIds.count) members"
          lastMessageDateLabel.text = timeElapsed(channel.lastMessageDate ?? Date())
          lastMessageDateLabel.adjustsFontSizeToFitWidth = true
          setAvatar(avatarLink: channel.avatarLink)
      }
      
      private func setAvatar(avatarLink: String) {

          if avatarLink != "" {
              FileStorage.downloadImage(imageUrl: avatarLink) { (avatarImage) in
                  
                  DispatchQueue.main.async {
                      self.avatarImageView.image = avatarImage != nil ? avatarImage?.circleMasked : UIImage(named: "avatar")
                  }
              }
          } else {
              self.avatarImageView.image = UIImage(named: "avatar")
          }
      }

}
