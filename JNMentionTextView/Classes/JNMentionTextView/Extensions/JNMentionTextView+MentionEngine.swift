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
        
        if let viewcontroller = self.mentionDelegate?.sourceViewControllerForPickerView() {
            if  let cell = self.mentionDelegate?.objectOfTableviewCell(), let table = self.mentionDelegate?.objectForTableview() {
                
                let position = self.position(from: self.beginningOfDocument, offset: self.selectedSymbolLocation + 1) ?? self.beginningOfDocument
                
                let rect: CGRect = self.caretRect(for: position)
                var y = CGFloat()
                var height = CGFloat()
                let point = self.convert(rect.origin, to: cell.contentView)
                let point2 = cell.convert(point, to: table)
                let point3 = table.convert(point2, to: viewcontroller.view)
                let navigationHeight = self.mentionDelegate?.yForTextView() ?? 0.0
                
                let actualVisibleFrameHeight = viewcontroller.view.frame.height - KeyboardService.keyboardHeight()
                self.becomeFirstResponder()
                
                if (actualVisibleFrameHeight) - point3.y >= (200 + 35) {
                    y = point3.y + 35
                    height = 200
                }else if (actualVisibleFrameHeight) - point3.y >= (150+35) && (actualVisibleFrameHeight) - point3.y <= (199+35) {
                    y = point3.y + 35
                    height = 150
                }else{
                    y = point3.y - 15 - 200
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
