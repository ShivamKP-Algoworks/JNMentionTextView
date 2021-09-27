import UIKit

class ChipListView: UIView {
    
    //MARK:- Outlets
    @IBOutlet var viewContainer: UIView!
    @IBOutlet weak var viewChipList: UIView!
    @IBOutlet weak var tableViewChipList: UITableView!
    
    /// Options
    var options: JNMentionPickerViewOptions = JNMentionPickerViewOptions(viewPositionMode: JNMentionPickerViewPositionwMode.automatic)
    
    /// Table View
    var dataList: [JNMentionPickable] = []
    
    /// Delegate
    weak var delegate: JNMentionPickerViewControllerDelegate?

    
    //MARK:- Initialization methods
    override init(frame: CGRect){ // for using view in code
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) { // for using view in IB
        super.init(coder: aDecoder)
        commonInit()
    }
    
     func commonInit(){
        let nib =  Bundle(for: self.classForCoder).loadNibNamed("ChipListView", owner: self, options: nil)![0] as! UIView
        nib.frame = self.bounds
        addSubview(nib)
        tableViewChipList.register(UINib(nibName: "ChipListViewTVC", bundle: Bundle(for: self.classForCoder)) , forCellReuseIdentifier: "ChipListViewTVC")
        
        viewChipList.layer.shadowColor = UIColor.lightGray.cgColor
        viewChipList.layer.shadowOpacity = 1
        viewChipList.layer.shadowOffset = .zero
        viewChipList.layer.shadowRadius = 4

        viewChipList.layer.cornerRadius = 8
        viewChipList.clipsToBounds = true
        viewChipList.layer.masksToBounds = false
        
        tableViewChipList.dataSource = self
        tableViewChipList.delegate = self
        tableViewChipList.reloadData()
    }
    
    class func instanceFromNib() -> UIView {
        return UINib(nibName: "ChipListView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! UIView
      }
    
    /**
     Reload Data
     */
    func reloadData() {
        tableViewChipList.dataSource = self
        tableViewChipList.delegate = self
        tableViewChipList.reloadData()
    }
}

extension ChipListView: UITableViewDataSource, UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.dataList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChipListViewTVC", for: indexPath) as! ChipListViewTVC
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor(red: 245.0/255.0, green: 245.0/255.0, blue: 245.0/255.0, alpha: 1.0)
        cell.selectedBackgroundView = backgroundView
        cell.lblChipTitle.text = self.dataList[indexPath.row].getPickableTitle()
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        50
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        debugPrint("selected row is \(indexPath.row+1)")
        // did select item
        self.delegate?.jnMentionPickerViewController(didSelectItemAt: indexPath)
    }
    
}
