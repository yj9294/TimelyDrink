//
//  NewReminderView.swift
//  TimelyDrink
//
//  Created by yangjian on 2023/5/16.
//

import Foundation
import UIKit

class NewReminderView: UIView {
    
    var hours: [String] = []
    var minutes: [String] = []
    
    var selectHour: String = "00"
    var selectMin: String = "00"
    
    var compoletion: ((String)->Void)? = nil
    
    private lazy var pickerView = {
        let picker = UIPickerView()
        picker.delegate = self
        picker.dataSource = self
        return picker
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI () {
        self.backgroundColor = UIColor(white: 0, alpha: 0.4)
        let contentView = UIView()
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 6
        contentView.layer.masksToBounds = true
        self.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.bottom.equalTo(self.snp.bottom).offset(-30)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(300)
        }
        
        
        contentView.addSubview(pickerView)
        pickerView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.right.equalToSuperview().offset(-24)
            make.left.equalToSuperview().offset(24)
        }
        
        let cancelButton = UIButton()
        cancelButton.layer.cornerRadius = 6
        cancelButton.layer.masksToBounds = true
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.setTitleColor(.black, for: .normal)
        cancelButton.layer.borderColor = UIColor(named: "#BDBCBF")?.cgColor
        cancelButton.layer.borderWidth = 1
        cancelButton.addTarget(self, action: #selector(dismiss), for: .touchUpInside)
        cancelButton.backgroundColor = .white
        contentView.addSubview(cancelButton)
        cancelButton.snp.makeConstraints { make in
            make.height.equalTo(48)
            make.left.equalToSuperview().offset(24)
            make.bottom.equalToSuperview().offset(-30)
        }
        
        let confirmButton = UIButton()
        confirmButton.layer.cornerRadius = 6
        confirmButton.layer.masksToBounds = true
        confirmButton.setTitle("OK", for: .normal)
        confirmButton.setTitleColor(.white, for: .normal)
        confirmButton.addTarget(self, action: #selector(confirm), for: .touchUpInside)
        confirmButton.backgroundColor = .black
        confirmButton.titleLabel?.font = .systemFont(ofSize: 16)
        contentView.addSubview(confirmButton)
        confirmButton.snp.makeConstraints { make in
            make.height.equalTo(48)
            make.right.equalToSuperview().offset(-24)
            make.left.equalTo(cancelButton.snp.right).offset(16)
            make.width.equalTo(cancelButton.snp.width)
            make.bottom.equalToSuperview().offset(-30)
        }
    }
    
    func commonInit() {
        for index in 0..<24 {
            hours.append(String(format: "%02d", index))
        }
        
        for index in 0..<60 {
            minutes.append(String(format: "%02d", index))
        }
        
        pickerView.reloadAllComponents()
    }
    
    func selectItem(item: String) {
        let array = item.components(separatedBy: ":")
        if array.count < 1 {
            return
        }
        
        selectHour = array[0]
        selectMin = array[1]
        
        if let hourIndex = hours.firstIndex(of: selectHour) {
            pickerView.selectRow(hourIndex, inComponent: 0, animated: true)
        }
        
        if let mineIndex = minutes.firstIndex(of: selectMin) {
            pickerView.selectRow(mineIndex, inComponent: 1, animated: true)
        }
    }
    
}

extension NewReminderView: UIPickerViewDataSource, UIPickerViewDelegate {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return hours.count
        } else {
            return minutes.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return ((bounds.width  - 40 - 48 ) / 2.0 )
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 {
            return hours[row]
        } else {
            return minutes[row]
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 56.0
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        var text: String = ""
        if component == 0 {
            text = hours[row]
        } else {
            text = minutes[row]
        }
        let string  = NSAttributedString(string: text, attributes: [NSAttributedString.Key.foregroundColor: UIColor.black, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20, weight: .bold)])
        
        let label = UILabel()
        label.textAlignment = .center
        label.attributedText = string
        return label
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0 {
            selectHour = hours[row]
        } else {
            selectMin = minutes[row]
        }
    }
    
    @objc func dismiss() {
        NewReminderView.dismiss()
        FirebaseUtil.log(event: .reminderCancel)
    }
    
    @objc func confirm() {
        compoletion?("\(selectHour):\(selectMin)")
        NewReminderView.dismiss()
    }
    
}

extension NewReminderView {
    
    class func present(title: String = Date().time, completion: ((String)->Void)? = nil) {
        let window = UIApplication.shared.windows.filter({$0.isKeyWindow}).first ?? UIWindow()
        let view = NewReminderView(frame: .zero)
        window.addSubview(view)
        view.compoletion = completion
        view.selectItem(item: title)
        view.snp.makeConstraints { make in
            make.top.left.right.bottom.equalToSuperview()
        }
    }
    
    class func dismiss() {
        let window = UIApplication.shared.windows.filter({$0.isKeyWindow}).first ?? UIWindow()
        window.subviews.forEach({
            if $0 is NewReminderView {
                $0.removeFromSuperview()
            }
        })
    }
    
}
