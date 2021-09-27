//
//  JNMentionTableViewController.swift
//  JNMentionTextView_Example
//
//  Created by JNDisrupter 💡 on 6/25/19.
//  Copyright © 2019 JNDisrupter. All rights reserved.
//

import UIKit
import JNMentionTextView

/// ComponentValues
private struct ComponentValues {
    static let cellHeight: CGFloat = 130
}

// JNMentionTableViewController
class JNMentionTableViewController: UIViewController {
    
    /// Table View
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var constantBottomTableview: NSLayoutConstraint!
    /**
     View Did load
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // empty back title
        self.navigationController?.navigationBar.topItem?.title = " "
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.estimatedRowHeight = 120
        tableView.rowHeight = UITableView.automaticDimension
        self.tableView.separatorStyle = .none
        
        addNecessaryObservers()
        //adding tap gesture for removing the chip list view when user tap outside the chip view
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self,
                                                                 action: #selector(removeChipListViewWhenTapOutside))
        tap.cancelsTouchesInView = false
        tableView.addGestureRecognizer(tap)
        
    }
    //removing the chip list view when user tap outside the chip view
    @objc private func removeChipListViewWhenTapOutside() {
        if let viewWithTag = self.view.viewWithTag(11011){
            viewWithTag.removeFromSuperview()
        }
    }
    
    
    private func addNecessaryObservers() {
            NotificationCenter.default
                .addObserver(self,  selector: #selector(keyboardWillShow(_:)),
                             name: UIResponder.keyboardWillShowNotification, object: nil)
            NotificationCenter.default
                .addObserver(self, selector: #selector(keyboardWillHide),
                             name: UIResponder.keyboardWillHideNotification, object: nil)
        }
   @objc func keyboardWillShow(_ notification: Notification) {
            if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
                if UIDevice().userInterfaceIdiom == .phone {
                    switch UIScreen.main.nativeBounds.height {
                    case 2436:
                        constantBottomTableview.constant = keyboardFrame.cgRectValue.height - 30
                    default:
                        constantBottomTableview.constant = keyboardFrame.cgRectValue.height
                    }
                }
            }
            view.layoutIfNeeded()
        }
        
    @objc func keyboardWillHide() {
        constantBottomTableview.constant = 0
        view.layoutIfNeeded()
    }
}

/// UITableViewDataSource, UITableViewDelegate
extension JNMentionTableViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "JNMentionTextViewTableViewCell", for: indexPath) as! JNMentionTextViewTableViewCell
            cell.parentViewController = self
            return cell
    }

}
