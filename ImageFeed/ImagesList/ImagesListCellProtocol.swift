//
//  ImagesListCellProtocol.swift
//  ImageFeed
//
//  Created by Maksim on 18.07.2024.
//

import Foundation
protocol ImagesListCellDelegate: AnyObject {
    func imageListCellDidTapLike(_ cell: ImagesListCell)
}
