//
//  ViewController.swift
//  Harpy
//
//  Created by Felix Hedlund on 2017-02-21.
//  Copyright © 2017 Felix Hedlund. All rights reserved.
//

import UIKit
import IBAnimatable
class HarpyViewController: UIViewController, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate, BankIDActionDelegate {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var answersContainerView: UIView!
    @IBOutlet weak var answersStackView: AnimatableStackView!
    @IBOutlet weak var textEditorBackground: UIView!
    @IBOutlet weak var textEditor: UITextField!
    @IBOutlet weak var titleHeader: UIView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var sendButtonWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var inputContainerBottomConstraint: NSLayoutConstraint!
    
    var ingvarView: IngvarView?
    var hasBeenPresentedInitially = false

    static let BANKID_NOTIFICATION = "bankIdWasVerified"
    
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
        tableView.contentInset = UIEdgeInsetsMake(60, 0, 0, 0)
        
        tapGestureRecognizor = UITapGestureRecognizer(target: self, action: #selector(didTapView))
        self.view.addGestureRecognizer(tapGestureRecognizor)
        tapGestureRecognizor.isEnabled = false
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillChangeFrameNotification(notification:)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(bankIdVerified), name: NSNotification.Name(rawValue: HarpyViewController.BANKID_NOTIFICATION), object: nil)
        
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(openBankID))
        view.addGestureRecognizer(swipe)
        
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.extraLight)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)

        blurEffectView.frame = titleHeader.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        titleHeader.addSubview(blurEffectView)
        
        view.tintColor = UIColor.init(hexString: "EC0000")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if !hasBeenPresentedInitially{
            let ingvarView = IngvarView.instanceFromNib()
            ingvarView!.frame = self.view.frame
            self.view.addSubview(ingvarView!)
            self.ingvarView = ingvarView
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if !hasBeenPresentedInitially{
            Timer.scheduledTimer(withTimeInterval: 1, repeats: false, block: { (timer) in
                self.ingvarView?.startAnimating()
            })
            
            self.hasBeenPresentedInitially = true
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func openBankID() {
        UIApplication.shared.openURL(URL(string: "http://mayholm.com/bankid/mock")!)
    }
    
    func bankIdVerified() {
        let message = "butterstick"
        self.dataSource.addNewComment(message: "Confirmed with BankID")
        self.dataSource.removeAllBankRequest()
        self.isWaitingForResponse = true
        self.tableView.reloadData()
        apiService.performTextRequest(message: message, success: { (commentArray) in
            self.isWaitingForResponse = false
            self.addCommentsToDatasource(commentArray: commentArray)
            self.isWaitingForResponse = false
            self.tableView.reloadData()
            self.scrollToBottom()
        }, failure: {
            
        })
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
    
    private func addCommentsToDatasource(commentArray: [Comment]){
        for comment in commentArray{
            if let replies = comment.replies, replies.count > 0{
                self.answersStackView.isHidden = true
                self.answersStackView.duration = 0
                self.answersStackView.slide(.out, direction: .down){
                    replies.forEach { self.addAnswerButton(text: $0) }
                    self.answersStackView.isHidden = false
                    self.answersStackView.duration = 1
                    self.answersStackView.slide(.in, direction: .up)
                }
                self.view.setNeedsLayout()
                self.view.layoutIfNeeded()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                    self.scrollToBottom()
                })
            }else{
                self.dataSource.addNewCommentObject(comment: comment)
            }
        }
    }
    
    private func addAnswerButton(text: String) {
        let button = AnswerButton.instanceFromNib()!
        button.label.text = text
        button.addTarget(self, action: #selector(pressedAnswerButton), for: .touchUpInside)
        answersStackView.addArrangedSubview(button)
    }
    
    func pressedAnswerButton(sender: AnswerButton) {
        let message = sender.label.text!
        self.dataSource.addNewComment(message: message)
        self.isWaitingForResponse = true
        self.tableView.reloadData()
        apiService.performTextRequest(message: message, success: { (commentArray) in
            self.addCommentsToDatasource(commentArray: commentArray)
            self.isWaitingForResponse = false
            self.tableView.reloadData()
        }, failure: {
            
        })
        self.answersStackView.subviews.forEach { $0.removeFromSuperview() }
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
                    self.addCommentsToDatasource(commentArray: commentArray)
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
            if indexPath.row > 0 {
                let previousComment = dataSource.comments[indexPath.row-1]
                if previousComment.isServerResponse {
                    cell.topMargin.constant = 0
                }
            }
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "CommentRight", for: indexPath) as! CommentTableViewCell
            cell.commentLabel.text = comment.commentString
            return cell
        }
        
    }

    override func viewDidLayoutSubviews() {
        tableView.contentInset = UIEdgeInsetsMake(60, 0, self.answersContainerView.frame.height, 0)
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
            let height = tableView.contentSize.height
               UIView.animate(withDuration: duration.doubleValue,
                       delay: 0,
                       options: UIViewAnimationOptions(rawValue: UInt(curve.intValue << 16)),
                       animations: { () in
                        scrollBottomConstant.constant = scrollBottomConstant.constant + heightOffset
                        self.view.layoutIfNeeded()
                        self.tableView.contentOffset = CGPoint(x: 0, y: max(0, height - self.tableView.bounds.height))
        },
                       completion: { (completed) in
                        self.scrollToBottom()
                        
        })
    }
}

