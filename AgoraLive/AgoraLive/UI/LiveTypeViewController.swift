//
//  LiveTypeViewController.swift
//  AgoraLive
//
//  Created by CavanSu on 2020/2/11.
//  Copyright © 2020 Agora. All rights reserved.
//

import UIKit
import RxSwift
import RxRelay
import RxCocoa

class LiveTypeCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var backgroundImageViewBottom: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundImageViewBottom.constant = 10
        titleLabel.adjustsFontSizeToFitWidth = true
        self.contentView.layer.shadowOpacity = 1
        self.contentView.layer.shadowOffset = CGSize(width: 0, height: 0.5)
        self.contentView.layer.cornerRadius = 10
        self.contentView.layer.masksToBounds = true
        self.contentView.layer.shadowRadius = 1
        self.contentView.layer.shadowColor = UIColor(hexString: "#03043A-0.2").cgColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

class LiveTypeViewController: UIViewController {
    struct `Type` {
        var background: UIImage
        var title: String
        var description: String
        
        static var list = BehaviorRelay(value: [
            `Type`(background: UIImage(named: "pic-多人连麦")!,
                   title: NSLocalizedString("Multi_Broadcasters"),
                   description: NSLocalizedString("Multi_Broadcasters_Description")),
            `Type`(background: UIImage(named: "pic-单主播")!,
                   title: NSLocalizedString("Single_Broadcaster"),
                   description: NSLocalizedString("Multi_Broadcasters_Description")),
            `Type`(background: UIImage(named: "pic-PK直播")!,
                   title: NSLocalizedString("PK_Live"),
                   description: NSLocalizedString("Multi_Broadcasters_Description")),
            `Type`(background: UIImage(named: "pic-虚拟直播")!,
                   title: NSLocalizedString("Virtual_Live"),
                   description: NSLocalizedString("Comming_Soon")),
        ])
    }
    
    @IBOutlet weak var tableViewLeft: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Frame
        let imageWith = UIScreen.main.bounds.width - 30.0
        tableView.rowHeight = ((imageWith * 133.0) / 345.0) + 10.0
        
        // DataSource
        `Type`.list.bind(to: tableView.rx.items(cellIdentifier: "LiveTypeCell",
                                                cellType: LiveTypeCell.self)) { index, type, cell in
                                                    cell.titleLabel.text = type.title
                                                    cell.descriptionLabel.text = type.description
                                                    cell.backgroundImageView.image = type.background
        }.disposed(by: disposeBag)
        
        // Selected Event
        guard let parentVC = self.parent,
            let tabbarVC = parentVC as? UITabBarController,
            let children = tabbarVC.viewControllers else {
            fatalError()
        }
        
        var tLiveListTabVC: LiveListTabViewController?
        
        for child in children where child is UINavigationController {
            let navi = child as! UINavigationController
            
            if let tabVC = navi.viewControllers.first as? LiveListTabViewController {
                tLiveListTabVC = tabVC
                break
            }
        }
        
        guard let liveListTabVC = tLiveListTabVC else {
            fatalError()
        }
        
        _ = liveListTabVC.view
        
        tableView.rx.itemSelected.subscribe(onNext: { [weak tabbarVC, weak liveListTabVC] (index) in
            let commingSoonIndex = 3
            guard index.row < commingSoonIndex else {
                return
            }
            let liveListTabVCIndex = 1
            tabbarVC?.selectedIndex = liveListTabVCIndex
            liveListTabVC?.tabView.selectedIndex.accept(index.row)
        }).disposed(by: disposeBag)
    }
}
