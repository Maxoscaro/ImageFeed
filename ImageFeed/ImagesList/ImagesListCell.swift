//
//  ImagesListCell.swift
//  ImageFeed
//
//  Created by Maksim on 11.05.2024.
//
import UIKit

final class ImagesListCell: UITableViewCell {
    
    weak var delegate: ImagesListCellDelegate?
    
    static let reuseIdentifier = "ImagesListCell"
    
    @IBOutlet weak var cellImage: UIImageView!
    
    @IBOutlet weak var likeButton: UIButton!
    
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBAction private func likeButtonClicked(_ sender: UIButton) {
        delegate?.imageListCellDidTapLike(self)
        print("Like tapped")
    }
    
    func setIsLiked(isLiked: Bool){
        let likeImage = isLiked ? UIImage(named: "like_button_on") : UIImage(named: "like_button_off")
        likeButton.setImage(likeImage, for: .normal)
       
    }
}
