//
//  JNMentionTextView.swift
//  JNMentionTextView
//
//  Created by JNDisrupter 💡 on 6/17/19.
//

import UIKit

/// Component Values
struct ComponentValues {
    
    // Default Cell Height
    static let defaultCellHeight: CGFloat = 50.0
}

/// JNMentionEntity
public struct JNMentionEntity {
    
    /// Ranage
    public var range: NSRange
    
    /// Symbol
    public var symbol: String
    
    /// Pickable Item
     public var item: JNMentionPickable

    /**
     Initializer
     - Parameter item: JNMentionEntityPickable Item
     - Parameter symbol: Symbol special character
     */
   public init(item: JNMentionPickable, symbol: String) {
        
        self.item = item
        self.symbol = symbol
        self.range = NSRange(location: 0, length: 0)
    }
}

/// JNMentionTextView
open class JNMentionTextView: UITextView {
    
    /// JNMentionAttributeName
    static let JNMentionAttributeName: NSAttributedString.Key = (NSString("JNMENTIONITEM")) as NSAttributedString.Key

    /// Picker View Controller
    var pickerViewController: JNMentionPickerViewController?
    var chipListView = ChipListView()

    /// Options
    var options: JNMentionPickerViewOptions!
    
    /// Search String
    var searchString: String!
    
    /// Selected Symbol
    var selectedSymbol: String!
    
    /// Selected Symbol Location
    var selectedSymbolLocation: Int!
    
    /// Selected Symbol Attributes
    var selectedSymbolAttributes: [NSAttributedString.Key : Any]!
    
    /// Normal Attributes
    public var normalAttributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.foregroundColor: UIColor.black,NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18.0)]
    
    /// Mention Replacements
    public var mentionReplacements: [String: [NSAttributedString.Key : Any]] = [:]
    
    /// Mention Delegate
    public weak var mentionDelegate: JNMentionTextViewDelegate?
    
    // MARK:- Initializers

    /**
     Initializer
     */
    public override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        
        self.initView()
    }
    
    /**
     Initializer
     */
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.initView()
    }
 
    /**
     Resign First Responder
     - Parameter completion: Completion block.
     */
    public func resignFirstResponder(completion: (() -> ())? = nil){
        
        // end mention process
        self.endMentionProcess(animated: false) {
            self.resignFirstResponder()
            completion?()
        }
    }
    
    /**
     Init View
     */
    private func initView(){
        
        self.selectedSymbol = ""
        self.selectedSymbolLocation = 0
        self.selectedSymbolAttributes = [:]
        self.searchString = ""
        self.pickerViewController = JNMentionPickerViewController()
        self.chipListView.tag = 11011
        self.delegate = self
    }
    
    /**
     Setup
     - Parameter options: JNMentionOptions Object.
     */
    public func setup(options: JNMentionPickerViewOptions) {
        
        // set options
        self.options = options
    }

    /**
     Register Table View Cells
     - Parameter nib: UINib.
     - Parameter identifier: string identifier.
     */
    public func registerTableViewCell(_ nib: UINib?, forCellReuseIdentifier identifier: String) {
        self.pickerViewController?.tableView.register(nib, forCellReuseIdentifier: identifier)
    }
    
    /**
     Get Mentioned Items
     - Parameter attributedString: NSAttributedString.
     - Parameter symbol: Symbol string value.
     - Returns [JNMentionEntity]: list of mentioned (JNMentionEntity)
     */
    public class func getMentionedItems(from attributedString: NSAttributedString, symbol: String = "") -> [JNMentionEntity] {
        
        var mentionedItems: [JNMentionEntity] = []
        
        attributedString.enumerateAttributes(in: NSRange(0..<attributedString.length), options: [], using:{ attrs, range, stop in
            
            if let item = (attrs[JNMentionTextView.JNMentionAttributeName] as AnyObject) as? JNMentionEntity {
                
                if !symbol.isEmpty, symbol != item.symbol {
                    return
                }
                
                var mentionedItem = item
                mentionedItem.range = range
                mentionedItems.append(mentionedItem)
            }
        })
        
        return mentionedItems
    }
    
    /**
     Is In Mention Process
     - Returns Bool: Bool value to indicate if the mention is in filter process.
     */
    func isInMentionProcess() -> Bool {
        var isPopPresented = false
        if let viewcontroller = self.mentionDelegate?.sourceViewControllerForPickerView() {
            viewcontroller.view.subviews.forEach{
                if $0 is ChipListView {
                    isPopPresented = true
                    return
                }
            }
        }
        return isPopPresented
//        return ((self.pickerViewController?.viewIfLoaded) != nil) && self.pickerViewController?.view.window != nil
    }
    
    /**
     Move cursor to
     - Parameter location: Location.
     - Parameter completion: completion closure block
     */
    func moveCursor(to location: Int, completion:(() -> ())? = nil) {
        
        // get cursor position
        if let newPosition = self.position(from: self.beginningOfDocument, offset: location) {
            DispatchQueue.main.async {
                self.selectedTextRange = self.textRange(from: newPosition, to: newPosition)
                completion?()
            }
        }
    }
    
    /**
     Retrieve Data
     - Returns: Pickable data array.
     */
    func pickerViewRetrieveData() {
        
        // Show Loading Indicator View
//        self.pickerViewController?.showLoadingIndicatorView()
        
        // Data
        self.mentionDelegate?.jnMentionTextView(retrieveDataFor: self.selectedSymbol, using: self.searchString, compliation: { [weak self] (results) in
            
            // Get strong self refrence
            guard let strongSelf = self else { return }
            
            // Set Data
            strongSelf.chipListView.dataList = results
            
            if results.isEmpty {
                strongSelf.endMentionProcess()
            }
            
            // Reload Data
            strongSelf.chipListView.reloadData()
            
            if !results.isEmpty, let viewcontroller = strongSelf.mentionDelegate?.sourceViewControllerForPickerView(),
               let cell = strongSelf.mentionDelegate?.objectOfTableviewCell(),
               let table = strongSelf.mentionDelegate?.objectForTableview() {
                
                let position = strongSelf.position(from: strongSelf.beginningOfDocument, offset: strongSelf.selectedSymbolLocation + 1) ?? strongSelf.beginningOfDocument
                
                let rect: CGRect = strongSelf.caretRect(for: position)
                var y = CGFloat()
                var height = CGFloat()
                let point = strongSelf.convert(rect.origin, to: cell.contentView)
                let point2 = cell.convert(point, to: table)
                let point3 = table.convert(point2, to: viewcontroller.view)
                
                let actualVisibleFrameHeight = viewcontroller.view.frame.height - KeyboardService.keyboardHeight()
                strongSelf.becomeFirstResponder()
                if results.count >= 3{
                    if (actualVisibleFrameHeight) - point3.y >= (150 + 35) {
                        y = point3.y + 35
                        height = 150
                    } else {
                        y = point3.y - 15 - 150
                        height = 150
                    }
                }else if results.count == 2{
                    if (actualVisibleFrameHeight) - point3.y >= (100 + 35) {
                        y = point3.y + 35
                        height = 100
                    }else{
                        y = point3.y - 15 - 100
                        height = 100
                    }
                }else if results.count == 1{
                    if (actualVisibleFrameHeight) - point3.y >= (50 + 35) {
                        y = point3.y + 35
                        height = 50
                    }else{
                        y = point3.y - 15 - 50
                        height = 50
                    }
                }
                strongSelf.chipListView.frame = CGRect(x: 15, y: y, width: viewcontroller.view.frame.width-30, height: height)
                strongSelf.chipListView.options = strongSelf.options
                strongSelf.chipListView.delegate = self
                viewcontroller.view.addSubview(strongSelf.chipListView)
                viewcontroller.view.layoutSubviews()
                viewcontroller.view.layoutIfNeeded()
            }
        })
    }
    
}
