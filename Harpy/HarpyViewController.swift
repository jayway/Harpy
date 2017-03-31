//
//  ViewController.swift
//  Harpy
//
//  Created by Felix Hedlund on 2017-02-21.
//  Copyright © 2017 Felix Hedlund. All rights reserved.
//

import UIKit
class HarpyViewController: UIViewController, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate, BankIDActionDelegate {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var textEditorBackground: UIView!
    @IBOutlet weak var textEditor: UITextField!
    @IBOutlet weak var titleHeader: UIView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var sendButtonWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var inputContainerBottomConstraint: NSLayoutConstraint!
    
    var dataSource: HarpyDataSource!
    var apiService: APIAIService!
    
    var isWaitingForResponse = false
    var tapGestureRecognizor: UITapGestureRecognizer!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        dataSource = HarpyDataSource()
        apiService = APIAIService()
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 44
        tableView.contentInset = UIEdgeInsetsMake(titleHeader.frame.height, 0, 0, 0)
        
        tapGestureRecognizor = UITapGestureRecognizer(target: self, action: #selector(didTapView))
        self.view.addGestureRecognizer(tapGestureRecognizor)
        tapGestureRecognizor.isEnabled = false
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillChangeFrameNotification(notification:)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
        
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(openBankID))
        view.addGestureRecognizer(swipe)
        
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.extraLight)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)

        blurEffectView.frame = titleHeader.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        titleHeader.addSubview(blurEffectView)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func openBankID() {
        UIApplication.shared.openURL(URL(string: "http://mayholm.com/bankid/mock")!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.didPressSend(self.textEditor)
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.startWriting()
    }
    
    func keyboardWillChangeFrameNotification(notification: NSNotification) {
        self.keyboardWillChangeFrameNotification(notification: notification, scrollBottomConstant: inputContainerBottomConstraint)
//        if let indexPath = self.lastIndexPath{
//            self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
//        }
        
        // Write more to here if you want.
    }
    
    @IBAction func didPressSend(_ sender: Any) {
        if let message = textEditor.text{
            if message != ""{
                self.dataSource.addNewComment(message: message)
                self.textEditor.text = ""
                self.endWriting()
                self.isWaitingForResponse = true
                self.tableView.reloadData()
                
                apiService.performTextRequest(message: message, success: { (commentArray) in
                    for comment in commentArray{
                        if let replies = comment.replies, replies.count > 0{
                            print("===SHOULD DISPLAY REPLY ALTERNATIVES===")
                        }else{
                            self.dataSource.addNewCommentObject(comment: comment)
                        }
                    }
                    self.isWaitingForResponse = false
                    self.tableView.reloadData()
                }, failure: {
                    
                })
            }
        }
    }
    
    fileprivate func scrollToBottom(){
        let lastItem = IndexPath(item: self.dataSource.comments.count - 1, section: 0)
        self.tableView.scrollToRow(at: lastItem, at: .bottom, animated: true)
    }
    
    private func startWriting(){
        UIView.animate(withDuration: 0.5) { 
            self.sendButtonWidthConstraint.constant = 36
            self.textEditor.textAlignment = NSTextAlignment.left
        }
    }
    
    private func endWriting(){
        UIView.animate(withDuration: 0.5) {
            self.sendButtonWidthConstraint.constant = 0
            self.textEditor.textAlignment = NSTextAlignment.center
        }
        self.view.endEditing(true)
    }
    
    func didTapView(){
        textEditor.resignFirstResponder()
    }
    
    fileprivate func addGestureRecognizer(){
        tapGestureRecognizor.isEnabled = true
    }
    
    fileprivate func removeGestureRecognizer(){
        tapGestureRecognizor.isEnabled = false
    }
    
    
    //MARK: - UItableViewDatasource, Delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.isWaitingForResponse{
            return dataSource.comments.count + 1
        }
        return dataSource.comments.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isWaitingForResponse && indexPath.row == dataSource.comments.count{
            let cell = tableView.dequeueReusableCell(withIdentifier: "Waiting", for: indexPath) as! WaitingTableViewCell
            cell.setup()
            return cell
        }
        let comment = dataSource.comments[indexPath.row]
        if comment.isBankIdRequest{
            let cell = tableView.dequeueReusableCell(withIdentifier: "BankIDActionCell", for: indexPath) as! BankIDActionTableViewCell
            cell.messageLabel.text = comment.commentString
            cell.delegate = self
            return cell
        }else if comment.isServerResponse{
            let cell = tableView.dequeueReusableCell(withIdentifier: "CommentLeft", for: indexPath) as! CommentTableViewCell
            cell.commentLabel.text = comment.commentString
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "CommentRight", for: indexPath) as! CommentTableViewCell
            cell.commentLabel.text = comment.commentString
            return cell
        }
        
    }


}

extension HarpyViewController {
    func keyboardWillChangeFrameNotification(notification: NSNotification, scrollBottomConstant: NSLayoutConstraint) {
        let duration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber
        let curve = notification.userInfo?[UIKeyboardAnimationCurveUserInfoKey] as! NSNumber
        let keyboardBeginFrame = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        let keyboardEndFrame = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        let screenHeight = UIScreen.main.bounds.height
        let isBeginOrEnd = keyboardBeginFrame.origin.y == screenHeight || keyboardEndFrame.origin.y == screenHeight
        let heightOffset = keyboardBeginFrame.origin.y - keyboardEndFrame.origin.y - (isBeginOrEnd ? bottomLayoutGuide.length : 0)
        
        if heightOffset > 0{
            self.addGestureRecognizer()
        }else{
            self.removeGestureRecognizer()
        }
        
        UIView.animate(withDuration: duration.doubleValue,
                                   delay: 0,
                                   options: UIViewAnimationOptions(rawValue: UInt(curve.intValue << 16)),
                                   animations: { () in
                                    scrollBottomConstant.constant = scrollBottomConstant.constant + heightOffset
                                    self.view.layoutIfNeeded()
        },
                                   completion: { (completed) in
                                    self.scrollToBottom()
                                    
                                    
        })
    }
}

