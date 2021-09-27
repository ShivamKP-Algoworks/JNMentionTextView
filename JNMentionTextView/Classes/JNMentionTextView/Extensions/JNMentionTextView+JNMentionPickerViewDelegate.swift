//
//  JNMentionTextView+JNMentionPickerViewDelegate.swift
//  JNMentionTextView
//
//  Created by JNDisrupter 💡 on 6/17/19.
//

import UIKit

/// JNMentionPickerViewDelegate
extension JNMentionTextView: JNMentionPickerViewControllerDelegate {
        
    /**
     Cell
     - Parameter item: Pickable item.
     - Returns: UITableViewCell.
     */
    func jnMentionPickerViewController(cellFor item: JNMentionPickable) -> UITableViewCell {
        return self.mentionDelegate?.jnMentionTextView(cellFor: item, tableView: self.pickerViewController!.tableView) ?? UITableViewCell()
    }
    
    /**
     Height for cell
     - Parameter item: Pickable item.
     - Returns: UITableViewCell.
     */
    func jnMentionPickerViewController(cellHeightFor item: JNMentionPickable) -> CGFloat {
        return self.mentionDelegate?.jnMentionTextView(heightfor: item, tableView: self.pickerViewController!.tableView) ?? 0.0
    }
    
    /**
     Did Select Item
     - Parameter indexPath: IndexPath.
     */
    func jnMentionPickerViewController(didSelectItemAt indexPath: IndexPath) {
        
//        if let _pickerViewController =  self.pickerViewController, _pickerViewController.dataList.count > indexPath.row {
        if  self.chipListView.dataList.count > indexPath.row {

            // selected item & range
            let selectedItem = self.chipListView.dataList[indexPath.row]
            
            // selected location
            guard let selectedRange = selectedTextRange else { return }
            let location = offset(from: beginningOfDocument, to: selectedRange.start)
            
            // replace characters with pickable item
            self.replaceCharacters(with: selectedItem, in: location)
            
            // Trigger text did change
            self.textViewDidChange(self)
        }
    }
}
