//
//  HistoryRecordVC.swift
//  TimelyDrink
//
//  Created by yangjian on 2023/5/16.
//

import Foundation
import UIKit

class HistoryRecord: BaseVC {
    
    var datasource: [RecordModel] = []
    
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        tableView.dataSource = self
        tableView.backgroundColor = .clear
        tableView.backgroundView?.backgroundColor = .clear
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 0, right: 0)
        tableView.separatorStyle = .none
        tableView.register(RecordCell.classForCoder(), forCellReuseIdentifier: "RecordCell")
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        makeDatasource()
    }
    
    func makeDatasource() {
        let drinks = FileUtil.shared.getDrinks()
        if drinks.count == 0 {
            return
        }
        let array: [[DrinkModel]] = drinks.reduce(into: [[]]) { partialResult, model in
            if let lastElement = partialResult.last,
               let lastIndex = partialResult.indices.last,
               let element = lastElement.last {
                if  element.day == model.day {
                    partialResult[lastIndex].append(model)
                } else {
                    partialResult.append([model])
                }
            } else {
                partialResult = [[drinks.first!]]
            }
        }
        datasource = array.compactMap({ models in
            if let model = models.first {
                return RecordModel(date: model.day, items: models)
            } else {
                return nil
            }
        })
        tableView.reloadData()
    }
    
}

extension HistoryRecord {
    
    override func setupUI() {
        super.setupUI()
        view.backgroundColor = UIColor(named: "#F8F8F8")
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.left.right.bottom.equalToSuperview()
        }
    }
    
    override func setupNavigation() {
        super.setupNavigation()
        title = "Historical record"
    }
}

extension HistoryRecord: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datasource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RecordCell", for: indexPath)
        if let cell = cell as? RecordCell {
            cell.model = datasource[indexPath.row]
        }
        return cell
    }
    
}

extension HistoryRecord {
    
    class RecordCell: UITableViewCell, ItemViewDataSource {
        
        lazy var calendarIcon: UIImageView = {
            let imageView = UIImageView(image: UIImage(named: "chart_calendar"))
            imageView.contentMode = .scaleAspectFill
            return imageView
        }()
        
        lazy var calendar: UILabel = {
            let calendar = UILabel()
            calendar.textColor = UIColor(named: "#323163")
            calendar.font = .systemFont(ofSize: 14, weight: .medium)
            return calendar
        }()
        
        lazy var itemView: ItemView = {
            let view = ItemView()
            view.datasource = self
            return view
        }()
        
        
        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            setupUI()
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        private func setupUI() {
            self.contentView.isHidden = true
            
            self.selectionStyle = .none
            self.backgroundColor = .clear
            let centerView = UIView()
            centerView.backgroundColor = .white
            centerView.layer.cornerRadius = 6
            centerView.layer.masksToBounds = true
            addSubview(centerView)
            centerView.snp.makeConstraints { make in
                make.top.equalToSuperview().offset(8)
                make.bottom.equalToSuperview().offset(-8).priority(.low)
                make.left.equalToSuperview().offset(20)
                make.right.equalToSuperview().offset(-20)
            }
            
            centerView.addSubview(calendarIcon)
            calendarIcon.snp.makeConstraints { make in
                make.top.equalToSuperview().offset(16)
                make.left.equalToSuperview().offset(16)
                make.width.height.equalTo(24)
            }
            
            
            centerView.addSubview(calendar)
            calendar.snp.makeConstraints { make in
                make.centerY.equalTo(calendarIcon)
                make.left.equalTo(calendarIcon.snp.right).offset(6)
            }
            
            let lineView = UIView()
            lineView.backgroundColor = UIColor(named: "#EEEEEE")
            centerView.addSubview(lineView)
            lineView.snp.makeConstraints { make in
                make.top.equalTo(calendar.snp.bottom).offset(12)
                make.left.equalTo(calendar)
                make.right.equalToSuperview().offset(-16)
                make.height.equalTo(1)
            }
            
            centerView.addSubview(itemView)
            itemView.snp.makeConstraints { make in
                make.top.equalTo(calendar.snp.bottom).offset(24)
                make.left.equalToSuperview().offset(13)
                make.right.equalToSuperview().offset(-13)
                make.bottom.equalToSuperview().offset(-12)
            }
        }
        
        public var model: RecordModel? = nil {
            didSet {
                calendar.text = model?.date
                itemView.reloadData()
            }
        }
        
        func numberOfItemsInView(view: ItemView) -> Int {
            return model?.items.count ?? 0
        }
        
        func itemImageForView(index: Int) -> UIImage? {
            return model?.items[index].item.icon
        }
        
        func itemTitleForView(index: Int) -> String {
            if let item = model?.items[index] {
                return "\(item.name) \(item.ml)ml"
            }
            return ""
        }
    }
    
}
