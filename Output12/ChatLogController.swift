//
//  ChatLogController.swift
//  Output12
//
//  Created by Victor Idongesit on 03/12/2017.
//  Copyright © 2017 Victor Idongesit. All rights reserved.
//

import UIKit
class ChatLogController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    private let cellId: String = "cellId"
    var friend: Friend? {
        didSet {
            navigationItem.title = friend?.name
            messages = friend?.messages?.allObjects as? [Message]
            messages = messages?.sorted(by: {$0.date!.compare($1.date!) == .orderedAscending})
        }
    }
    let messageInputContainerView: UIView = {
       let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    let inputTextField: UITextField = {
       let textField = UITextField()
        textField.placeholder = "Enter message..."
        return textField
    }()
    let sendButton: UIButton = {
        let button = UIButton()
        button.setTitle("Send", for: .normal)
        let titleColor = UIColor(red: 0, green: 137/255, blue: 245/255, alpha: 1)
        button.setTitleColor(titleColor, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
        return button
    }()
    
    @objc
    func handleSend() {
        let delegate = UIApplication.shared.delegate as? AppDelegate
        
        if let context = delegate?.persistentContainer.viewContext {
            let message = FriendsController.createMessageWithText(text: inputTextField.text!, friend: friend!, minutesAgo: 0, context: context, isSender: true)
            do {
                try context.save()
                messages?.append(message)
                let item = messages!.count - 1
                let insertionIndexPath = IndexPath(item: item, section: 0)
                collectionView?.insertItems(at: [insertionIndexPath])
                collectionView?.scrollToItem(at: insertionIndexPath, at: .bottom, animated: true)
                inputTextField.text = nil
            } catch let err {
                print(err)
            }
        }
    }
    
    private var bottomConstraint: NSLayoutConstraint?
    var messages: [Message]?
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.backgroundColor = .white
        tabBarController?.tabBar.isHidden = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Simulate", style: .plain, target: self, action: #selector(simulate))
        collectionView?.register(ChatLogMessageCell.self, forCellWithReuseIdentifier: cellId)
        view.addSubview(messageInputContainerView)
        view.addConstraintWithFormat("H:|[v0]|", messageInputContainerView)
        view.addConstraintWithFormat("V:[v0(48)]", messageInputContainerView)
        bottomConstraint = NSLayoutConstraint(item: messageInputContainerView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0)
        view.addConstraint(bottomConstraint!)
        setupInputContainerView()
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    @objc
    private func simulate() {
        let delegate = UIApplication.shared.delegate as? AppDelegate
        
        if let context = delegate?.persistentContainer.viewContext {
            let message = FriendsController.createMessageWithText(text: "That was sent a minute ago", friend: friend!, minutesAgo: 1, context: context, isSender: false)
            do {
                try context.save()
                messages?.append(message)
                messages = messages?.sorted(by: { $0.date!.compare($1.date!) == .orderedAscending })
                if let item = messages?.index(of: message) {
                    let receivingIndexPath = IndexPath(item: item, section: 0)
                    collectionView?.insertItems(at: [receivingIndexPath])
                }
            } catch let err {
                print(err)
            }
        }
    }
    @objc
    private func handleKeyboardNotification(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            let keyboardNSValue = userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue
            let keyboardFrame = keyboardNSValue?.cgRectValue
            let isKeyboardShowing = notification.name == .UIKeyboardWillShow
            bottomConstraint?.constant = isKeyboardShowing ? -keyboardFrame!.height : 0
            UIView.animate(withDuration: 0, delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations: {
                self.view.layoutIfNeeded()
            }, completion: { (completed) in
                if isKeyboardShowing {
                    let indexPath = IndexPath(item: self.messages!.count - 1, section: 0)
                    self.collectionView?.scrollToItem(at: indexPath, at: .bottom, animated: true)
                }
            })
        }
    }
    @objc
    private func setupInputContainerView() {
        let topBorderView = UIView()
        topBorderView.backgroundColor = UIColor(white: 0.5, alpha: 0.5)
        
        messageInputContainerView.addSubview(inputTextField)
        messageInputContainerView.addSubview(sendButton)
        messageInputContainerView.addSubview(topBorderView)
        
        messageInputContainerView.addConstraintWithFormat("V:|[v0]|", inputTextField)
        messageInputContainerView.addConstraintWithFormat("V:|[v0]|", sendButton)
        messageInputContainerView.addConstraintWithFormat("H:|-8-[v0][v1(60)]|", inputTextField, sendButton)
        
        messageInputContainerView.addConstraintWithFormat("H:|[v0]|", topBorderView)
        messageInputContainerView.addConstraintWithFormat("V:|[v0(1)]", topBorderView)
    }
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let count = messages?.count {
            return count
        }
        return 0
    }
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        inputTextField.endEditing(true)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if let messageText = messages?[indexPath.row].text {
            let size = CGSize(width: 250, height: 1000)
            let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
            let estimatedFrame = NSString(string: messageText).boundingRect(with: size, options: options, attributes: [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 18)], context: nil)
            return CGSize(width: view.frame.width, height: estimatedFrame.height + 20)
        }
        return CGSize(width: view.frame.width, height: 100)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 8, left: 0, bottom: 80, right: 0)
    }
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as? ChatLogMessageCell {
            let message = messages![indexPath.row]
            cell.messageTextView.text = message.text
            if let messageText = messages?[indexPath.row].text, let profileImageName = messages?[indexPath.row].friend?.profileImageName {
                cell.profileImageView.image = UIImage(named: profileImageName)
                let size = CGSize(width: 250, height: 1000)
                let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
                let estimatedFrame = NSString(string: messageText).boundingRect(with: size, options: options, attributes: [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 18)], context: nil)
                if !message.isSender {
                    cell.messageTextView.frame = CGRect(x: 48, y: 0, width: estimatedFrame.width + 16, height: estimatedFrame.height + 20)
                    cell.bubbleImageView.frame = CGRect(x: 32, y: 0, width: estimatedFrame.width + 16 + 16 + 8, height: estimatedFrame.height + 20)
                    cell.bubbleImageView.image = ChatLogMessageCell.grayBubbleImage
                    cell.bubbleImageView.tintColor = UIColor(white: 0.90, alpha: 1)
                    cell.textBubbleView.frame = CGRect(x: 48, y: 0, width: estimatedFrame.width + 16 + 8, height: estimatedFrame.height + 20)
                    cell.profileImageView.isHidden = false
                    cell.textBubbleView.backgroundColor = .clear // UIColor(white: 0.95, alpha: 1)
                    cell.messageTextView.textColor = .black
                } else {
                    // outgoing message
                    cell.messageTextView.frame = CGRect(x: view.frame.width - estimatedFrame.width - 32, y: 0, width: estimatedFrame.width + 16, height: estimatedFrame.height + 20)
                    cell.bubbleImageView.frame = CGRect(x: view.frame.width - estimatedFrame.width - 40, y: 0, width: estimatedFrame.width + 16 + 16 + 8, height: estimatedFrame.height + 20)
                    cell.bubbleImageView.image = ChatLogMessageCell.blueBubbleImage
                    cell.bubbleImageView.tintColor = UIColor(red: 0, green: 137/255, blue: 249/255, alpha: 1)
                    cell.textBubbleView.frame = CGRect(x: view.frame.width - estimatedFrame.width - 40, y: 0, width: estimatedFrame.width + 16 + 8, height: estimatedFrame.height + 20)
                    cell.profileImageView.isHidden = true
                    cell.textBubbleView.backgroundColor = .clear // UIColor(red: 0, green: 137/255, blue: 249/255, alpha: 1)
                    cell.messageTextView.textColor = .white
                }
            }
            return cell
        } else {
            fatalError("Cell is not an instance of ChatLogMessageCell")
        }
    }
}

class ChatLogMessageCell: BaseCell {
    let messageTextView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 18)
        textView.text = "Sample Text"
        textView.isEditable = false
        textView.backgroundColor = .clear
        return textView
    }()
    let textBubbleView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.95, alpha: 1)
        view.layer.cornerRadius = 15
        view.layer.masksToBounds = true
        return view
    }()
    let profileImageView: UIImageView = {
       let imageView = UIImageView()
        imageView.backgroundColor = .red
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 15
        imageView.layer.masksToBounds = true
        return imageView
    }()
    static let grayBubbleImage  = UIImage(named: "bubble_gray")!.resizableImage(withCapInsets: UIEdgeInsets(top: 22, left: 26, bottom: 22, right: 26)).withRenderingMode(.alwaysTemplate)
    static let blueBubbleImage = UIImage(named: "bubble_blue")!.resizableImage(withCapInsets: UIEdgeInsets(top: 22, left: 26, bottom: 22, right: 26)).withRenderingMode(.alwaysTemplate)
    let bubbleImageView: UIImageView = {
       let imageView = UIImageView()
        imageView.image = ChatLogMessageCell.grayBubbleImage
        imageView.tintColor = UIColor(white: 0.90, alpha: 1)
        return imageView
    }()
    override func setupViews() {
        super.setupViews()
        addSubview(textBubbleView)
        addSubview(bubbleImageView)
        addSubview(messageTextView)
        addSubview(profileImageView)
        addConstraintWithFormat("H:|-8-[v0(30)]", profileImageView)
        addConstraintWithFormat("V:[v0(30)]|", profileImageView)
        
//        addConstraintWithFormat("V:|[v0]|", bubbleImageView)
//        addConstraintWithFormat("H:|[v0]|", bubbleImageView)
    }
}
