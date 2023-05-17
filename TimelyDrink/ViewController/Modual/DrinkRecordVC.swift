//
//  DrinkRecordVC.swift
//  TimelyDrink
//
//  Created by yangjian on 2023/5/15.
//

import Foundation
import IQKeyboardManagerSwift
import UIKit

class DrinkRecordVC: BaseVC {
    
    lazy var titleTextField: UITextField = {
        let titleTextField = UITextField()
        titleTextField.textColor = UIColor(named: "#0F1034")
        titleTextField.delegate = self
        titleTextField.font = UIFont.systemFont(ofSize: 16)
        let leftView = UIView()
        leftView.frame = CGRect(x: 0, y: 0, width: 16, height: 20)
        titleTextField.leftView = leftView
        titleTextField.leftViewMode = .always
        titleTextField.returnKeyType = .done
        titleTextField.backgroundColor = .white
        return titleTextField
    }()
    
    lazy var mlTextField: UITextField = {
        let titleTextField = UITextField()
        titleTextField.textColor = UIColor(named: "#0F1034")
        titleTextField.delegate = self
        titleTextField.font = UIFont.systemFont(ofSize: 16)
        let leftView = UIView()
        leftView.frame = CGRect(x: 0, y: 0, width: 16, height: 20)
        titleTextField.leftView = leftView
        titleTextField.leftViewMode = .always
        titleTextField.keyboardType = .phonePad
        titleTextField.returnKeyType = .done
        titleTextField.backgroundColor = .white
        return titleTextField
    }()
    
    lazy var collectionView: UICollectionView = {
        let flowlayout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowlayout)
        collectionView.register(ItemCell.classForCoder(), forCellWithReuseIdentifier: "ItemCell")
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .clear
        return collectionView
    }()
    
    var item: DrinkModel.Item = DrinkModel.Item.allCases.first! {
        didSet {
            total = 200
            titleTextField.text = item.title
            mlTextField.text = "200ml"
            mlTextField.isEnabled = true
            titleTextField.isEnabled = item == .customization
        }
    }
    
    var total: Int = 200
    
    override func viewDidLoad() {
        super.viewDidLoad()
        item = .water
        collectionView.reloadData()
        IQKeyboardManager.shared.enable = true
    }
    
    override func back() {
        super.back()
        FirebaseUtil.log(event: .recordBack)
    }
    
}

extension DrinkRecordVC {
    
    override func setupUI() {
        super.setupUI()
        view.backgroundColor = UIColor(named: "#F8F8F8")
        
        let inputView = UIView()
        view.addSubview(inputView)
        inputView.snp.makeConstraints { make in
            make.top.equalTo(view.snp.topMargin).offset(12)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(160)
        }
        
        let inpuBackground = UIImageView()
        inpuBackground.image = UIImage(named: "drink_record_bg")
        inputView.addSubview(inpuBackground)
        inpuBackground.snp.makeConstraints { make in
            make.top.left.right.bottom.equalToSuperview()
        }
        
        inputView.addSubview(titleTextField)
        titleTextField.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(24)
            make.left.equalToSuperview().offset(60)
            make.right.equalToSuperview().offset(-60)
            make.height.equalTo(48)
        }
        
        inputView.addSubview(mlTextField)
        mlTextField.snp.makeConstraints { make in
            make.top.equalTo(titleTextField.snp.bottom).offset(16)
            make.left.equalToSuperview().offset(60)
            make.right.equalToSuperview().offset(-60)
            make.height.equalTo(48)
        }
        
        
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(inputView.snp.bottom).offset(12)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
        }
        
        let confirmButton = UIButton()
        confirmButton.backgroundColor = .black
        confirmButton.layer.cornerRadius = 6
        confirmButton.layer.masksToBounds = true
        confirmButton.setTitle("OK", for: .normal)
        confirmButton.setTitleColor(.white, for: .normal)
        confirmButton.addTarget(self, action: #selector(confirmAction), for: .touchUpInside)
        view.addSubview(confirmButton)
        confirmButton.snp.makeConstraints { make in
            make.top.equalTo(collectionView.snp.bottom).offset(40)
            make.left.equalToSuperview().offset(60)
            make.right.equalToSuperview().offset(-60)
            make.height.equalTo(52)
            make.bottom.equalTo(view.snp.bottomMargin).offset(-45)
        }
    }
    
    override func setupNavigation() {
        super.setupNavigation()
        navigationItem.title = "Record"
    }
    
}

extension DrinkRecordVC: UITextFieldDelegate {
    
    @objc override func keyboardWillHidden() {
        guard let type = mlTextField.text, type.count > 0 else {
            total = 0
            return
        }
        if let text = mlTextField.text, text.count > 0 {
            if text.suffix(2) == "ml" {
                
            } else if let total = Int(text), total > 0 {
                self.total = total
                mlTextField.text = "\(total)ml"
            } else {
                alert("Please input valid number.")
            }
        } else {
            total = 0
        }
    }
    
    @objc func confirmAction() {
        FirebaseUtil.log(event: .recordConfirm)
        if item == .customization, titleTextField.text?.count == 0 {
            alert("Please input title.")
            return
        }
        if total == 0 {
            alert("Please enter the daily water intake")
            return
        }
        // 记录喝水
        var name = item.title
        if item == .customization {
            name = titleTextField.text!
        }
        let model = DrinkModel(day: Date().day, time: Date().time, item: item, name: name, ml: total)
        FileUtil.shared.addDrinks(model: model)
        back()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        textField.text = ""
        return true
    }
    
}


extension DrinkRecordVC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return DrinkModel.Item.allCases.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ItemCell", for: indexPath)
        if let cell = cell as? ItemCell {
            cell.item = DrinkModel.Item.allCases[indexPath.row]
            cell.select = item == DrinkModel.Item.allCases[indexPath.row]
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var width = view.window?.bounds.width ?? 0
        width = (width - 40 - 15 ) / 2.0 - 2
        return CGSize(width: width, height: 112)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 15.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 15.0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if item == DrinkModel.Item.allCases[indexPath.row] {
            return
        }
        item = DrinkModel.Item.allCases[indexPath.row]
        collectionView.reloadData()
        self.view.endEditing(true)
    }
    
}

extension DrinkRecordVC {
    
    class ItemCell: UICollectionViewCell {        
        lazy var icon: UIImageView = {
            let imageView = UIImageView()
            return imageView
        }()
        
        lazy var lineView: UIView = {
            let view = UIView()
            view.backgroundColor = UIColor(named: "#837EF8")
            view.isHidden = true
            return view
        }()
        
        lazy var title: UILabel = {
            let label = UILabel()
            label.textColor = UIColor(named: "#0F1034")
            label.font = .systemFont(ofSize: 14, weight: .bold)
            label.numberOfLines = 0
            label.textAlignment = .center
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
            self.backgroundColor = .white
            self.layer.cornerRadius = 6
            self.layer.masksToBounds = true
            
            self.contentView.isHidden = true
            addSubview(icon)
            icon.snp.makeConstraints { make in
                make.top.equalToSuperview().offset(10)
                make.centerX.equalToSuperview()
                make.height.equalTo(58)
                make.width.equalTo(44)
            }
            
            addSubview(title)
            title.snp.makeConstraints { make in
                make.top.equalTo(icon.snp.bottom).offset(8)
                make.centerX.equalToSuperview()
                make.left.equalToSuperview().offset(5)
                make.right.equalToSuperview().offset(-5)
            }
            
            addSubview(lineView)
            lineView.snp.makeConstraints { make in
                make.left.right.bottom.equalToSuperview()
                make.height.equalTo(2)
            }
            
        }
        
        var item: DrinkModel.Item? = nil {
            didSet {
                icon.image = item?.icon
                title.text = "\(item?.title ?? "") 200ml"
                if item == .customization {
                    title.text = "\(item?.title ?? "")"
                }
            }
        }
        
        var select: Bool = false {
            didSet {
                self.lineView.isHidden = !select
            }
        }
        
    }
}
