//
//  ViewController.swift
//  Harpy
//
//  Created by Felix Hedlund on 2017-02-21.
//  Copyright © 2017 Felix Hedlund. All rights reserved.
//

import UIKit
class HarpyViewController: UIViewController, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var textEditorBackground: UIView!
    @IBOutlet weak var textEditor: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var sendButtonWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var inputContainerBottomConstraint: NSLayoutConstraint!
    
    var dataSource: HarpyDataSource!
    var apiService: APIAIService!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        dataSource = HarpyDataSource()
        apiService = APIAIService()
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 44
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillChangeFrameNotification(notification:)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.endWriting()
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
            self.dataSource.addNewComment(message: message)
            self.textEditor.text = ""
            self.endWriting()
            self.tableView.reloadData()
            apiService.performTextRequest(message: message, success: {
                
            }, failure: {
                
            })
        }
        
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
    
    //MARK: - UItableViewDatasource, Delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.comments.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let comment = dataSource.comments[indexPath.row]
        if comment.isServerResponse{
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

extension UIViewController {
    func keyboardWillChangeFrameNotification(notification: NSNotification, scrollBottomConstant: NSLayoutConstraint) {
        let duration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber
        let curve = notification.userInfo?[UIKeyboardAnimationCurveUserInfoKey] as! NSNumber
        let keyboardBeginFrame = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        let keyboardEndFrame = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        let screenHeight = UIScreen.main.bounds.height
        let isBeginOrEnd = keyboardBeginFrame.origin.y == screenHeight || keyboardEndFrame.origin.y == screenHeight
        let heightOffset = keyboardBeginFrame.origin.y - keyboardEndFrame.origin.y - (isBeginOrEnd ? bottomLayoutGuide.length : 0)
        
        UIView.animate(withDuration: duration.doubleValue,
                                   delay: 0,
                                   options: UIViewAnimationOptions(rawValue: UInt(curve.intValue << 16)),
                                   animations: { () in
                                    scrollBottomConstant.constant = scrollBottomConstant.constant + heightOffset
                                    self.view.layoutIfNeeded()
        },
                                   completion: nil
        )
    }
}

