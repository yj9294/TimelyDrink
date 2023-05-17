//
//  ChartVC.swift
//  TimelyDrink
//
//  Created by yangjian on 2023/5/15.
//

import Foundation
import UIKit

class ChartVC: BaseVC {
    
    lazy var collectionView: UICollectionView = {
        let collectionFlowlayout = UICollectionViewFlowLayout()
        collectionFlowlayout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionFlowlayout)
        collectionView.register(ChartCell.classForCoder(), forCellWithReuseIdentifier: "ChartCell")
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 20)
        collectionView.layer.masksToBounds = true
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false

        return collectionView
    }()
    
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ChartSepartorCell.classForCoder(), forCellReuseIdentifier: "ChartSepartorCell")
        tableView.layer.cornerRadius = 6
        tableView.layer.borderColor = UIColor(named: "#BDBCBF")?.cgColor
        tableView.layer.borderWidth = 1
        tableView.layer.masksToBounds = true
        return tableView
    }()
    
    var item: ChartModel.Item = .day
    
    var timer: Timer? = nil
    
    var datasource: [ChartModel] = []
    
    var totalArray:[String]  = ["8000", "6000", "4000", "2000", "0"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        makeDataSource()
    }
    
    func makeDataSource() {
        switch item {
        case .day:
            datasource = item.unit.map { unit in
                let total = FileUtil.shared.getTimeTotalDrinks(time: unit)
                return ChartModel(progress: Double(total)  / 8000.0 , totalML: total, unit: unit)
            }
            totalArray  = ["8000", "6000", "4000", "2000", "0"]
        case .week:
            datasource = item.unit.map { unit in
                let total = FileUtil.shared.getWeekTotalDrinks(weeks: unit)
                return ChartModel(progress: Double(total)  / 8000.0, totalML: total, unit: unit)
            }
            totalArray  = ["8000", "6000", "4000", "2000", "0"]
        case .month:
            datasource = item.unit.map { unit in
                let total = FileUtil.shared.getMonthTotalDrinks(date: unit)
                return ChartModel(progress: Double(total)  / 8000.0, totalML: total, unit: unit)
            }
            totalArray  = ["8000", "6000", "4000", "2000", "0"]
        case .year:
            datasource = item.unit.map { unit in
                let total = FileUtil.shared.getYearTotalDrinks(date: unit)
                return ChartModel(progress: Double(total)  / 240000.0, totalML: total, unit: unit)
            }
            totalArray  = ["240000", "180000", "120000", "600000", "0"]
        }
        
        if timer != nil {
            timer?.invalidate()
            timer = nil
        }
        
        collectionView.reloadData()
        tableView.reloadData()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            
            //动画
            var progress = 0.0
            self.timer = Timer.scheduledTimer(withTimeInterval: 0.005, repeats: true) { timer in
                progress += 0.005 / 1.5
                if progress > 1.0 {
                    timer.invalidate()
                    return
                }
                self.datasource = self.datasource.compactMap({ model in
                    if progress <= model.progress {
                        return ChartModel(displayProgerss: progress, progress: model.progress, totalML: model.totalML, unit: model.unit)
                    }
                    return model
                })
                self.collectionView.reloadData()
            }
            
            self.collectionView.scrollToItem(at: IndexPath(row: self.datasource.count - 1, section: 0), at: .right, animated: true)
        }
    }
}

extension ChartVC {
    
    override func setupUI() {
        view.backgroundColor  = .white
        
        let itemView = UIImageView(image: UIImage(named: "chart_item"))
        view.addSubview(itemView)
        itemView.snp.makeConstraints { make in
            make.top.equalTo(view.snp.topMargin).offset(-28)
            make.left.equalToSuperview().offset(20)
        }
        
        let topView = UIImageView(image: UIImage(named: "chart_top"))
        view.addSubview(topView)
        view.contentMode = .scaleAspectFill
        topView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
        }
        
        let toolbar = Toolbar()
        toolbar.delegate = self
        toolbar.layer.cornerRadius = 6
        toolbar.layer.masksToBounds = true
        view.addSubview(toolbar)
        toolbar.snp.makeConstraints { make in
            make.top.equalTo(itemView.snp.bottom).offset(32)
            make.left.equalToSuperview().offset(28)
            make.right.equalToSuperview().offset(-28)
            make.height.equalTo(40)
        }
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(toolbar.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(346)
        }
        
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.top.bottom.right.equalTo(tableView)
            make.left.equalTo(tableView).offset(65)
        }
        
        
        
    }
    
    override func setupNavigation() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "chart_history")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(toHistoryVC))
    }
    
}

extension ChartVC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        item.unit.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ChartCell", for: indexPath)
        if let cell = cell as? ChartCell {
            cell.model = datasource[indexPath.row]
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 15.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 36, height: collectionView.bounds.height)
    }
    
}

extension ChartVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return totalArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChartSepartorCell", for: indexPath)
        if let cell = cell as? ChartSepartorCell {
            cell.item = totalArray[indexPath.row]
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let height = ( tableView.bounds.height ) - 46
        return height / 5.0
    }
    
}

extension ChartVC {
    
    class ChartCell: UICollectionViewCell {
        
        private lazy var progressView: UIView = {
            let view = UIView()
            view.backgroundColor = UIColor(named: "#9062FF")
            return view
        }()
        
        private lazy var unitLabel: UILabel = {
            let label = UILabel()
            label.textColor = UIColor(named: "#888996")
            label.font = UIFont.systemFont(ofSize: 12)
            return label
        }()
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            setupUI()
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        func setupUI() {
            addSubview(progressView)
            progressView.snp.makeConstraints { make in
                make.bottom.equalToSuperview().offset(-46)
                make.width.equalTo(36)
                make.centerX.equalToSuperview()
                make.height.equalTo(0)
            }
            
            addSubview(unitLabel)
            unitLabel.snp.makeConstraints { make in
                make.centerX.equalToSuperview()
                make.bottom.equalToSuperview().offset(-24)
            }
    
        }
        
        var model: ChartModel? = nil {
            didSet {
                unitLabel.text = model?.unit

                guard let model = model else {
                    return
                }
                
                self.progressView.snp.remakeConstraints { make in
                    make.bottom.equalToSuperview().offset(-46)
                    make.width.equalTo(36)
                    make.centerX.equalToSuperview()
                    make.height.equalTo(0)
                }
                
                if model.progress.isNaN {
                    return
                }
                
                // 一格的高度
                let height = (self.bounds.height - 46) / 5.0
                self.progressView.snp.remakeConstraints { make in
                    make.bottom.equalToSuperview().offset(-46)
                    make.width.equalTo(36)
                    make.centerX.equalToSuperview()
                    make.height.equalTo((self.bounds.height - 46  - height / 2.0) * model.displayProgerss)
                }
            }
        }
        
    }
}

extension ChartVC {
    
    class ChartSepartorCell: UITableViewCell {
        
        lazy var title: UILabel = {
            let label = UILabel()
            label.textColor = UIColor(named: "#888996")
            label.textAlignment = .right
            label.font = .systemFont(ofSize: 12)
            return label
        }()
        
        lazy var separtorLine: UIView = {
            let view = UIView()
            view.backgroundColor = UIColor(named: "#F6F6F6")
            return view
        }()
        
        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            setupUI()
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        func setupUI() {
            self.selectionStyle = .none
            self.backgroundView?.backgroundColor = .clear
            self.backgroundColor = .clear
            
            self.addSubview(title)
            title.snp.makeConstraints { make in
                make.left.equalToSuperview()
                make.bottom.equalToSuperview()
                make.width.equalTo(55)
            }
            
            self.addSubview(separtorLine)
            separtorLine.snp.makeConstraints { make in
                make.bottom.equalToSuperview()
                make.left.equalTo(title.snp.right).offset(15)
                make.height.equalTo(1)
                make.right.equalToSuperview()
            }
        }
        
        var item: String? = "" {
            didSet {
                title.text = item
            }
        }
        
    }
}

extension ChartVC: ToolbarDelegate {
        
    func toolbarDidSelected(item: ChartModel.Item) {
        self.item = item
        makeDataSource()
    }
    
}

extension ChartVC {
    
    @objc func toHistoryVC() {
        let vc = HistoryRecord()
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
        
        FirebaseUtil.log(event: .historyRecord)
    }
}
