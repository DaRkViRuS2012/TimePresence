//
//  LapCell.swift
//  TaskManager
//
//  Created by Nour  on 6/4/18.
//  Copyright © 2018 NourAraar. All rights reserved.
//

import UIKit

class LapCell: UITableViewCell {

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    
    var lap:Lap?{
        
        didSet{
            
            guard let lap = lap else{
                return
            }
            
            if let date = lap.date{
                    self.dateLabel.text = DateHelper.getStringFromDate(date)
            }
            
            self.timeLabel.text = "\(DateHelper.timeString(time: TimeInterval(lap.seconds)))"
            self.titleLabel.text = lap.title
        }
        
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
