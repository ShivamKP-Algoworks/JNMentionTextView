//
//  JNMentionTextViewTableViewCell.swift
//  JNMentionTextView_Example
//
//  Created by JNDisrupter 💡 on 6/25/19.
//  Copyright © 2019 JNDisrupter. All rights reserved.
//

import UIKit
import JNMentionTextView

/// JNMentionTextViewTableViewCell
class JNMentionTextViewTableViewCell: UITableViewCell {
    
    /// Text View
    @IBOutlet weak var textView: JNMentionTextView!
    
    /// Data
    var data: [String: [JNMentionPickable]] = [:]
    
    /// Parent View Controller
    var parentViewController: UIViewController!
    
    /**
     Awake From Nib
     */
    override func awakeFromNib() {
        super.awakeFromNib()
        textView.addDoneButton(title: "Done", target: self, selector: #selector(tapDone(sender:)))

        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.textContainer.lineFragmentPadding = 0
        textView.backgroundColor = .clear
        textView.keyboardType = .asciiCapable
        textView.allowsEditingTextAttributes = true
        textView.isScrollEnabled = false
        
        textView.becomeFirstResponder()
        
        // Set Selection Style
        self.selectionStyle = UITableViewCell.SelectionStyle.none
        
        
        // customize text view apperance
        self.textView.font = UIFont.systemFont(ofSize: 17.0)
        
        // set text view mention replacements
        self.textView.mentionReplacements = ["+": [NSAttributedString.Key.foregroundColor: UIColor.black,
                                                   NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18.0), NSAttributedString.Key.backgroundColor: UIColor(red: 238/255, green: 238/255, blue: 238/255, alpha: 1)]]
        
        // init options
        let options = JNMentionPickerViewOptions(viewPositionMode: JNMentionPickerViewPositionwMode.automatic)
        
        
        // build data
        let firstUser  = User(id: 1,
                              name: "Tom Hanks",
                              details: "American actor and filmmaker",
                              imageName: "tom_hanks")
        
        let secondUser = User(id: 2,
                              name: "Leonardo DiCaprio",
                              details: "American actor and filmmaker",
                              imageName: "leonardo_diCaprio")
        
        let thirdUser  = User(id: 3,
                              name: "Morgan Freeman",
                              details: "American actor and filmmaker",
                              imageName: "morgan_freeman")
        
        let fourthUser = User(id: 4,
                              name: "Samuel L. Jackson",
                              details: "American actor and filmmaker",
                              imageName: "samuel_l_jackson")
        
        let fifthUser  = User(id: 5,
                              name: "Tom Cruise",
                              details: "American actor and filmmaker",
                              imageName: "tom_cruise")
        
        // set data
        self.data = ["+": [firstUser, secondUser, thirdUser, fourthUser, fifthUser]]
        
        // etup text view
        self.textView.returnKeyType = .done
        
        // etup text view
        self.textView.setup(options: options)
        
        // set mention delegate
        self.textView.mentionDelegate = self
    }
    @objc func tapDone(sender: Any) {
          parentViewController.view.endEditing(true)
      }
   
    
    /**
     Register cell class in the table
     - Parameter tableView : The table view to register the cell in it
     */
    class func registerCell(in tableView: UITableView) {
        tableView.register(UINib(nibName: "JNMentionTextViewTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: JNMentionTextViewTableViewCell.getReuseIdentifier())
    }
    
    /**
     Get cell reuse identifier
     - Returns: Cell reuse identifier
     */
    class func getReuseIdentifier() -> String {
        return "JNMentionTextViewTableViewCell"
    }
    
    /**
     Get Cell Height
     - Returns : Cell height
     */
    class func getCellHeight() -> CGFloat {
        return 120.0
    }
}

/// JNMentionTextViewDelegate
extension JNMentionTextViewTableViewCell: JNMentionTextViewDelegate {
    
    /**
     Get Mention Item For
     - Parameter symbol: replacement string.
     - Parameter id: JNMentionEntityPickable ID.
     - Returns: JNMentionEntityPickable object for the search criteria.
     */
    func jnMentionTextView(getMentionItemFor symbol: String, id: String) -> JNMentionPickable? {
        
        for item in self.data[symbol] ?? [] {
            if item.getPickableIdentifier() == id {
                return item
            }
        }
        
        return nil
    }
    
    /**
     Retrieve Data For
     - Parameter symbol: replacement string.
     - Parameter searchString: search string.
     - Parameter compliation: list of JNMentionEntityPickable objects for the search criteria.
     */
    func jnMentionTextView(retrieveDataFor symbol: String, using searchString: String, compliation: (([JNMentionPickable]) -> ())) {
        
        var data = self.data[symbol] ?? []
        if !searchString.isEmpty {
            data = data.filter({ $0.getPickableTitle().lowercased().contains(searchString.lowercased())})
        }
        
        return compliation(data)
    }
    
    /**
     Frame at
     - Parameter indexPath: IndexPath.
     - Returns frame: view frame.
     */
    func jnMentionTextViewFrame(at indexPath: IndexPath?) -> CGRect {
        return self.textView.frame
    }
    
    /**
     Source View For Picker View
     - Returns: the super view for the picker view.
     */
    func sourceViewControllerForPickerView() -> UIViewController {
        return self.parentViewController
    }
    func objectOfTableviewCell() -> UITableViewCell{
        return self
    }
    func objectForTableview() -> UITableView? {
        return self.tableView
    }
    /**
     height for picker view
     - Returns: picker view height.
     */
    func heightForPickerView() -> CGFloat {
        return 200.0
    }
    func yForTextView() -> CGFloat {
        let height = UIApplication.shared.statusBarFrame.size.height +
                    (parentViewController.navigationController?.navigationBar.frame.height ?? 0.0)
        return height
    }
    
    /**
     Should Begin Editing
     */
//    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
//        (self.superview as! UITableView).scrollToRow(at: IndexPath(row: 0, section: 0), at: UITableView.ScrollPosition.top, animated: true)
//        return true
//    }
    
    
    func textViewDidChange(_ textView: UITextView) {
//        let size = textView.bounds.size
//        let newSize = textView.sizeThatFits(CGSize(width: size.width, height: CGFloat.greatestFiniteMagnitude))
        
        // Resize the cell only when cell's size is changed
//        if size.height != newSize.height {
//            UIView.setAnimationsEnabled(false)
        DispatchQueue.main.async{
            self.tableView?.beginUpdates()
            self.tableView?.endUpdates()
        }
//            UIView.setAnimationsEnabled(true)
//        }
//        if let thisIndexPath = self.tableView?.indexPath(for: self) {
//            self.tableView?.scrollToRow(at: thisIndexPath, at: .bottom, animated: false)
//        }
    }
}
extension UITableViewCell {
    /// Search up the view hierarchy of the table view cell to find the containing table view
    var tableView: UITableView? {
        get {
            var table: UIView? = superview
            while !(table is UITableView) && table != nil {
                table = table?.superview
            }

            return table as? UITableView
        }
    }
}
extension UITextView {
    
    func addDoneButton(title: String, target: Any, selector: Selector) {
        
        let toolBar = UIToolbar(frame: CGRect(x: 0.0,
                                              y: 0.0,
                                              width: UIScreen.main.bounds.size.width,
                                              height: 44.0))//1
        let flexible = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)//2
        let barButton = UIBarButtonItem(title: title, style: .plain, target: target, action: selector)//3
        toolBar.setItems([flexible, barButton], animated: false)//4
        self.inputAccessoryView = toolBar//5
    }
}
