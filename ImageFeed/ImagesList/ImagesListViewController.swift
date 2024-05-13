//
//  ViewController.swift
//  ImageFeed
//
//  Created by Maksim on 03.05.2024.
//

import UIKit

class ImagesListViewController: UIViewController {
    

    @IBOutlet private var tableView: UITableView!
    
    private let photosName: [String] = Array(0..<20).map{ "\($0)"}
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = 200
        tableView.backgroundColor = UIColor(named: "YP Black")
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
    }
    
  
}

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photosName.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
        
        guard let imagesListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }
        configCell(for: imagesListCell, with: indexPath)
        return imagesListCell
    }
}

extension ImagesListViewController {
    
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        
        guard let image = UIImage(named: photosName[indexPath.row]) else {
            return
        }
        
        cell.cellImage.image = image
        cell.dateLabel.text = dateFormatter.string(from: Date())
        
        let isLiked = indexPath.row % 2 == 0
        let likeImage = isLiked ? UIImage(named: "like_button_on") : UIImage(named: "like_button_off")
        cell.likeButton.setImage(likeImage, for: .normal)
    }
}

extension ImagesListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let image = UIImage(named: photosName[indexPath.row]) else {
            return 0
        }
        
        let imageInserts = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInserts.left - imageInserts.right
        let imageWidth = image.size.width
        let scale = imageViewWidth / imageWidth
        let cellHeight = image.size.height * scale + imageInserts.top + imageInserts.bottom
        return cellHeight
    }
    
}
