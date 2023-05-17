//
//  ReminderVC.swift
//  TimelyDrink
//
//  Created by yangjian on 2023/5/15.
//

import Foundation
import UIKit

class ReminderVC: BaseVC {
    
    var datasource: [String] = []
    
    lazy var tableView: UITableView = {
        let view = UITableView(frame: .zero, style: .plain)
        view.dataSource = self
        view.delegate = self
        view.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        view.backgroundColor = .clear
        view.backgroundView?.backgroundColor = .clear
        view.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 0, right: 0)
        view.register(ReminderCell.classForCoder(), forCellReuseIdentifier: "ReminderCell")
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        makeDatasource()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func makeDatasource() {
        datasource = FileUtil.shared.getReminderList()
        if datasource.count == 0 {
            // 默认闹钟列表
            for (_, item) in defaultReminder.enumerated() {
                appendItem(item)
            }
        }
        datasource = datasource.sorted { m1, m2 in
            return m1 < m2
        }
        tableView.reloadData()
    }
    
}

extension ReminderVC {
    
    func appendItem(_ item: String) {
        if let index = self.datasource.firstIndex(of: item) {
            self.datasource[index] = item
            self.datasource = self.datasource.sorted { m1, m2 in
                return m1 < m2
            }
            tableView.reloadData()
        } else {
            datasource.append(item)
            datasource = datasource.sorted { m1, m2 in
                return m1 < m2
            }
            tableView.reloadData()
        }
        
        
        FileUtil.shared.appendReminder(item)
        NotificationUtil.shared.appendReminder(item)
    }
    
    func deleteItem(item: String) {
        datasource = self.datasource.filter({ it in
            return item != it
        })
        tableView.reloadData()
        
        FileUtil.shared.deleteReminder(item)
        NotificationUtil.shared.deleteNotifications(item)
    }
    
    @objc func addAction() {
        NewReminderView.present { selectTime in
            if (self.datasource.firstIndex(of: selectTime) ?? 0) > 0 {
                self.alert("Duplicate reminder.")
                return
            }
            self.appendItem(selectTime)
            
            FirebaseUtil.log(event: .reminderConfirm)

        }
        
        FirebaseUtil.log(event: .newReminder)
    }
    
}

extension ReminderVC {
    
    override func setupUI() {
        view.backgroundColor = .white
        let itemView = UIImageView(image: UIImage(named: "reminder_item"))
        view.addSubview(itemView)
        itemView.snp.makeConstraints { make in
            make.top.equalTo(view.snp.topMargin).offset(-28)
            make.left.equalToSuperview().offset(20)
        }
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(view.snp.topMargin)
            make.left.right.bottom.equalToSuperview()
        }
        
    }
    
    override func setupNavigation() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "reminder_add")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(addAction))
    }
    
}

extension ReminderVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datasource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReminderCell", for: indexPath)
        if let cell = cell as? ReminderCell {
            cell.item = datasource[indexPath.row]
            cell.deleteHandle = { [weak self] item in
                if let item = item {
                    self?.deleteItem(item: item)
                }
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        64.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        NewReminderView.present(title: datasource[indexPath.row]) { item in
            if (self.datasource.firstIndex(of: item) ?? 0) > 0 {
                self.alert("Duplicate reminder.")
                return
            }
            self.deleteItem(item: item)
            self.appendItem(self.datasource[indexPath.row])
        }
    }
    
}

extension ReminderVC {
    
    class ReminderCell: UITableViewCell {
        
        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            setupUI()
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        private lazy var title: UILabel = {
            let label = UILabel()
            label.textColor = UIColor(named: "#08080A")
            label.font = UIFont.systemFont(ofSize: 20.0)
            return label
        }()
        
        private func setupUI() {
            self.backgroundColor = .clear
            self.backgroundView?.backgroundColor = .clear
            self.selectionStyle = .none
            
            self.contentView.isHidden = true
            
            self.addSubview(title)
            title.snp.makeConstraints { make in
                make.centerY.equalToSuperview()
                make.left.equalToSuperview().offset(21)
            }
            
            let delete = UIButton()
            delete.setImage(UIImage(named: "reminder_delete"), for: .normal)
            delete.addTarget(self, action: #selector(deleteAction), for: .touchUpInside)
            self.addSubview(delete)
            delete.snp.makeConstraints { make in
                make.centerY.equalToSuperview()
                make.right.equalToSuperview().offset(-20)
            }
        }
        
        @objc private func deleteAction() {
            deleteHandle?(item)
        }
        
        var deleteHandle:((String?)->Void)? = nil
        
        var item: String? = nil {
            didSet {
                title.text = item
            }
        }
    }
}

