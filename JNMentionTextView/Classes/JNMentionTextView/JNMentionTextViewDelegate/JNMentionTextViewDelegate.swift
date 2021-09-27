//
//  JNMentionTextViewDelegate.swift
//  JNMentionTextView
//
//  Created by JNDisrupter 💡 on 6/26/19.
//

import Foundation

/// JNMention Text View Delegate
public protocol JNMentionTextViewDelegate: UITextViewDelegate {
    
    /**
     Get Mention Item For
     - Parameter symbol: replacement string.
     - Parameter id: JNMentionEntityPickable ID.
     - Returns: JNMentionEntityPickable objects for the search criteria.
     */
    func jnMentionTextView(getMentionItemFor symbol: String, id: String) -> JNMentionPickable?
    
    /**
     Retrieve Data For
     - Parameter symbol: replacement string.
     - Parameter searchString: search string.
     - Parameter compliation: list of JNMentionEntityPickable objects for the search criteria.
     */
    func jnMentionTextView(retrieveDataFor symbol: String, using searchString: String, compliation: (([JNMentionPickable]) -> ()))
    
    /**
     Cell For
     - Parameter item: JNMentionEntityPickable Item.
     - Parameter tableView: The data list UITableView.
     - Returns: UITableViewCell.
     */
    func jnMentionTextView(cellFor item: JNMentionPickable, tableView: UITableView) -> UITableViewCell
    
    /**
     Height for cell
     - Parameter item: JNMentionEntityPickable item.
     - Parameter tableView: The data list UITableView.
     - Returns: cell height.
     */
    func jnMentionTextView(heightfor item: JNMentionPickable, tableView: UITableView) -> CGFloat
    
    /**
     Source View Controller to present the Picker View on
     - Returns: the super view for the picker view.
     */
    func sourceViewControllerForPickerView() -> UIViewController
    func objectOfTableviewCell() -> UITableViewCell
    func objectForTableview() -> UITableView?

    /**
     height for picker view
     - Returns: picker view height.
     */
    func heightForPickerView() -> CGFloat
    func yForTextView() -> CGFloat
}


/// JNMentionTextViewDelegate
public extension JNMentionTextViewDelegate {
    
    /**
     Cell For
     - Parameter item: JNMentionEntityPickable Item.
     - Parameter tableView: The data list UITableView.
     - Returns: UITableViewCell.
     */
    func jnMentionTextView(cellFor item: JNMentionPickable, tableView: UITableView) -> UITableViewCell {
        
        let cell = UITableViewCell()
        cell.textLabel?.text = item.getPickableTitle()
        cell.contentView.backgroundColor = .clear
        cell.textLabel?.backgroundColor = UIColor.clear
        cell.backgroundColor = UIColor.clear
        return cell
    }
    
    /**
     Height for cell
     - Parameter item: JNMentionEntityPickable item.
     - Parameter tableView: The data list UITableView.
     - Returns: cell height.
     */
    func jnMentionTextView(heightfor item: JNMentionPickable, tableView: UITableView) -> CGFloat {
        return ComponentValues.defaultCellHeight
    }
}
