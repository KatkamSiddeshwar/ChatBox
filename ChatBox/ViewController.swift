//
//  ViewController.swift
//  ChatBox
//
//  Created by Auriga on 14/09/22.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
        
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var MessageText: UITextView!
    @IBOutlet weak var RoomText: UITextView!
    @IBOutlet weak var KeyboardHeight: NSLayoutConstraint!
    
    var mSocket = SocketHandler.sharedInstance.getSocket()
    var message = [String]()
    let cellReuseIdentifier = "cell"
    var room = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        SocketHandler.sharedInstance.establishConnection()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        mSocket.on("receive-message") { ( data, ack) -> Void in
            let dataReceived = data[0] as! String
            self.message.append("Other: " + dataReceived)
            self.tableView.reloadData()
        }
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return message.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:UITableViewCell = (self.tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as UITableViewCell?)!
        cell.textLabel?.text = message[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    @IBAction func MessageSend(_ sender: Any) {
        if MessageText.text == "" { return }
        mSocket.emit("send-message", MessageText.text, room)
        message.append("Self: " + MessageText.text)
        tableView.reloadData()
        MessageText.text = ""
    }
    
    @IBAction func RoomSend(_ sender: Any) {
        if RoomText.text == "" { return }
        room = RoomText.text
        mSocket.emit("join-room", RoomText.text)
        message.append("Joined: " + RoomText.text)
        tableView.reloadData()
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardHeight = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height {
            let bottomPadding = UIApplication.shared.windows.first?.safeAreaInsets.bottom
            self.KeyboardHeight.constant = keyboardHeight - CGFloat(bottomPadding!)
            UIView.animate(withDuration: 0.2, animations: {
                self.view.layoutIfNeeded()
            })
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        UIView.animate(withDuration: 0.2, animations: {
            self.KeyboardHeight.constant = 0
        })
    }
}
