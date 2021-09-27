//
//  JNMentionTextView+MentionEngine.swift
//  JNMentionTextView
//
//  Created by JNDisrupter 💡 on 6/17/19.
//

import UIKit

/// Mention Engine
extension JNMentionTextView {
    
    /**
     Start Mention Process
     */
    func startMentionProcess() {
        
//                guard let _pickerViewController = self.pickerViewController else {
//                    return
//                }
//
//                _pickerViewController.modalPresentationStyle = UIModalPresentationStyle.popover
//                _pickerViewController.preferredContentSize = CGSize(width: self.frame.width, height: self.mentionDelegate?.heightForPickerView() ?? 0.0)
//                _pickerViewController.options = self.options
//                _pickerViewController.delegate = self
        //
        //        let popoverPresentationController = _pickerViewController.popoverPresentationController
        //        popoverPresentationController?.delegate = self
        //        popoverPresentationController?.sourceView = self
        //        popoverPresentationController?.backgroundColor = self.options.backgroundColor
        //
        //        switch self.options.viewPositionMode {
        //        case .up:
        //            popoverPresentationController?.permittedArrowDirections = .up
        //        case .down:
        //            popoverPresentationController?.permittedArrowDirections = .down
        //        default:
        //            popoverPresentationController?.permittedArrowDirections = [.up, .down]
        //        }
        //
        
                if let viewcontroller = self.mentionDelegate?.sourceViewControllerForPickerView() {
                    if  let cell = self.mentionDelegate?.objectOfTableviewCell(), let table = self.mentionDelegate?.objectForTableview() {

                    let position = self.position(from: self.beginningOfDocument, offset: self.selectedSymbolLocation + 1) ?? self.beginningOfDocument
                    
                    let rect: CGRect = self.caretRect(for: position)
                    var y = CGFloat()
                    var height = CGFloat()
                        let point = self.convert(rect.origin, to: cell.contentView)
                        let point2 = cell.convert(point, to: table)
                        let point3 = table.convert(point2, to: viewcontroller.view)
                        

                    if (viewcontroller.view.frame.height - KeyboardService.keyboardHeight()) - rect.origin.y >= 220 + 35 {
                        y = point3.y + 35
                        height = 200
                    }else if (viewcontroller.view.frame.height - KeyboardService.keyboardHeight()) - rect.origin.y >= 170+35 && (viewcontroller.view.frame.height - KeyboardService.keyboardHeight()) - rect.origin.y <= 219+35 {
                        y = point3.y + 35
                        height = 150
                    }else{
                        y = point3.y - 35 - 200
                        height = 200
                    }
                        self.chipListView.frame = CGRect(x: 15, y: y, width: viewcontroller.view.frame.width-30, height: height)
                        self.chipListView.options = self.options
                        self.chipListView.delegate = self
                        viewcontroller.view.addSubview(self.chipListView)
                        viewcontroller.view.layoutSubviews()
                        DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
                            // Retrieve Picker Data
                            self.pickerViewRetrieveData()
                        }
                  

                    
        //            let popoverPresentationController = _pickerViewController.popoverPresentationController
        //            popoverPresentationController?.sourceRect = rect
        //
        //            viewcontroller.present(_pickerViewController, animated: true, completion: { [weak self] in
        //
        //                // Get strong self refrence
        //                guard let strongSelf = self else { return }
        //
        //                // Retrieve Picker Data
        //                strongSelf.pickerViewRetrieveData()
        //            })
                }
                }

    }
    
    /**
     End Mention Process
     - Parameter animated: is animated bool value.
     - Parameter completion: completion block.
     */
    func endMentionProcess(animated: Bool = true, completion: (() -> ())? = nil) {
        
//        if let pickerView = self.pickerViewController, self.isInMentionProcess() {
        if  self.isInMentionProcess() {
            if let viewcontroller = self.mentionDelegate?.sourceViewControllerForPickerView() {
                if let viewWithTag = viewcontroller.view.viewWithTag(11011){
                    viewWithTag.removeFromSuperview()
                }
                self.searchString = ""
                self.selectedSymbol = ""
                self.selectedSymbolLocation = 0
                self.selectedSymbolAttributes = [:]
                completion?()
            }
        } else {
            completion?()
        }
    }
    
    /**
     Apply Mention Engine
     - Parameter searchRange: NSRange.
     */
    func applyMentionEngine(searchRange: NSRange) {
        
        // in mention process
        guard !self.isInMentionProcess() else { return }
        
        // iterate through each replacement symbol
        for (pattern, attributes) in self.mentionReplacements {
            
            do {
                let regex = try NSRegularExpression(pattern: "\\\(pattern)")
                regex.enumerateMatches(in: self.textStorage.string, range: searchRange) {
                    match, flags, stop in
                    
                    if var matchRange = match?.range(at: 0), let selectedRange = self.selectedTextRange {
                        
                        let cursorPosition = self.offset(from: self.beginningOfDocument, to: selectedRange.start)
                        guard cursorPosition > matchRange.location && cursorPosition <= matchRange.location + matchRange.length else { return }
                        
                        // update match range length
                        matchRange.length = cursorPosition - matchRange.location
                        
                        // set selected symbol information
                        self.selectedSymbol = String((self.textStorage.string as NSString).substring(with: matchRange).first ?? Character(""))
                        self.selectedSymbolLocation = matchRange.location
                        self.selectedSymbolAttributes = attributes
                        
                        // start mention process
                        self.startMentionProcess()
                    }
                }
            }
                
            catch {
                print("An error occurred attempting to locate pattern: " +
                    "\(error.localizedDescription)")
            }
        }
    }
}

/// Mention Engine
extension JNMentionTextView: UIPopoverPresentationControllerDelegate {
    
    public func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
    
    public func popoverPresentationControllerShouldDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) -> Bool {
        self.endMentionProcess()
        return true
    }
}
