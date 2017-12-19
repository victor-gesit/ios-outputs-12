//
//  ViewController.swift
//  Output12
//
//  Created by Victor Idongesit on 01/12/2017.
//  Copyright © 2017 Victor Idongesit. All rights reserved.
//

import UIKit
class FriendsController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    private var cellId:String = "cellId"
    var messages: [Message]?
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Recent"
        collectionView?.backgroundColor = UIColor.white
        collectionView?.alwaysBounceVertical = true
        collectionView?.register(MessageCell.self, forCellWithReuseIdentifier: cellId)
        setupData()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIView.animate(withDuration: 0.5, delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations: {
            self.view.layoutIfNeeded()
        }, completion: { (completed) in
            self.tabBarController?.tabBar.isHidden = false
        })
    }
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let count = messages?.count {
         return count
        }
        return 0
    }
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as? MessageCell {
            let message = messages![indexPath.row]
            cell.message = message
            return cell
        } else {
            fatalError("Cell is not an instance of MessageCell")
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 100)
    }
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let layout = UICollectionViewFlowLayout()
        let controller = ChatLogController(collectionViewLayout: layout)
        controller.friend = messages?[indexPath.row].friend
        navigationController?.pushViewController(controller, animated: true)
    }
}

class MessageCell: BaseCell {
    override var isHighlighted: Bool {
        didSet {
            backgroundColor = isHighlighted ? UIColor(red: 0, green: 134/255, blue: 249/255, alpha: 1) :  .white
            nameLabel.textColor = isHighlighted ? .white :  .black
            messageLabel.textColor = isHighlighted ? .white :  .black
            timeLabel.textColor = isHighlighted ? .white :  .black
        }
    }
    var message: Message? {
        didSet {
            nameLabel.text = message?.friend?.name
            if let profileImageName = message?.friend?.profileImageName {
                profileImageView.image = UIImage(named: profileImageName)
                hasReadImageView.image = UIImage(named: profileImageName)
            }
            messageLabel.text = message?.text
            if let date = message?.date {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "h:mm a"
                let elapsedTimeInSeconds = Date().timeIntervalSince(date)
                let secondInDay:TimeInterval = 60 * 60 * 24
                print("Got here first", secondInDay.description, elapsedTimeInSeconds.description)
                if elapsedTimeInSeconds >= secondInDay * 7 {
                    dateFormatter.dateFormat = "MM/dd/yy"
                } else if elapsedTimeInSeconds >= secondInDay {
                    dateFormatter.dateFormat = "EEE"
                }
                timeLabel.text = dateFormatter.string(from: date)
            }
        }
    }
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 34
        imageView.layer.masksToBounds = true
        return imageView
    }()
    let dividerLineView: UIView = {
        let dividerLine = UIView()
        dividerLine.backgroundColor = UIColor(white: 0.5, alpha: 0.5)
        return dividerLine
    }()
    let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18)
        label.text = "Idem Gesit"
        label.textColor = .darkGray
        return label
    }()
    let messageLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.text = "Your friend's message and something else"
        return label
    }()
    let timeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .right
        label.text = "12:05 pm"
        return label
    }()
    let hasReadImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 10
        imageView.layer.masksToBounds = true
        return imageView
    }()
    override func setupViews() {
        // backgroundColor = .blue
        addSubview(profileImageView)
        addSubview(dividerLineView)
        
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        dividerLineView.translatesAutoresizingMaskIntoConstraints = false
        addConstraintWithFormat("H:|-12-[v0(68)]", profileImageView)
        addConstraintWithFormat("V:[v0(68)]", profileImageView)
        addConstraint(NSLayoutConstraint(item: profileImageView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
        addConstraintWithFormat("H:|-82-[v0]|", dividerLineView)
        addConstraintWithFormat("V:[v0(1)]|", dividerLineView)
        setupContainerView()
    }
    private func setupContainerView() {
        let containerView = UIView();
        addSubview(containerView)
        addConstraintWithFormat("H:|-90-[v0]|", containerView)
        addConstraintWithFormat("V:[v0(60)]", containerView)
        
        containerView.addSubview(nameLabel)
        containerView.addSubview(messageLabel)
        containerView.addSubview(timeLabel)
        containerView.addSubview(hasReadImageView)
        
        containerView.addConstraintWithFormat("H:|[v0][v1(80)]-12-|", nameLabel, timeLabel)
        containerView.addConstraintWithFormat("H:|[v0]-8-[v1(20)]-12-|", messageLabel, hasReadImageView)
        containerView.addConstraintWithFormat("V:|[v0][v1(24)]|", nameLabel, messageLabel)
        containerView.addConstraintWithFormat("V:|[v0(20)]", timeLabel)
        containerView.addConstraintWithFormat("V:[v0(20)]|", hasReadImageView)
    }
}

extension UIView {
    func addConstraintWithFormat(_ formatString: String, _ views: UIView...) {
        var viewsDictionary = [String: UIView]()
        for (index, view) in views.enumerated() {
            let key = "v\(index)"
            viewsDictionary[key] = view
            view.translatesAutoresizingMaskIntoConstraints = false
        }
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: formatString, options: NSLayoutFormatOptions(), metrics: nil, views: viewsDictionary))
    }
}

class BaseCell: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder) has not been implemented")
    }
    func setupViews() {
    }
}
