//
//  DrinkSettingVC.swift
//  TimelyDrink
//
//  Created by yangjian on 2023/5/15.
//

import Foundation
import UIKit

class DrinkSettingVC: BaseVC {
    
    lazy var inputTextField: UITextField = {
        let inpuTextField = UITextField()
        inpuTextField.textAlignment = .right
        inpuTextField.returnKeyType = .done
        inpuTextField.keyboardType = .phonePad
        inpuTextField.font = .systemFont(ofSize: 32, weight: .bold)
        inpuTextField.textColor = .black
        inpuTextField.text = "0"
        inpuTextField.isEnabled = false
        return inpuTextField
    }()
    
    lazy var tipLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(named: "#79797C")
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 16.0, weight: .semibold)
        return label
    }()
    
    lazy var slider: UISlider = {
        let slider = UISlider()
        slider.maximumTrackTintColor = UIColor(named: "#EFEFEF")
        slider.minimumTrackTintColor = UIColor(named: "#9062FF")
        slider.addTarget(self, action: #selector(sliderValueChanged), for: .valueChanged)
        return slider
    }()
    
    var total: Int = 0 {
        didSet {
            tipLabel.text = "Your daily water goal：\(total)ml"
            inputTextField.text = "\(total)"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.total = FileUtil.shared.getTotalML()
        slider.setValue(Float(total) / 8000.0, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        removeTabbarGesture()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        addTabbarGesture()
    }
    
}

extension DrinkSettingVC {
    
    override func setupUI() {
        super.setupUI()

        let inputView = UIView()
        inputView.layer.borderColor = UIColor(named: "#BDBCBF")?.cgColor
        inputView.layer.borderWidth = 1
        inputView.layer.cornerRadius = 6
        inputView.layer.masksToBounds = true
        view.addSubview(inputView)
        inputView.snp.makeConstraints { make in
            make.top.equalTo(view.snp.topMargin).offset(88)
            make.left.equalToSuperview().offset(32)
            make.right.equalToSuperview().offset(-32)
            make.height.equalTo(72)
        }
        
        let contentView = UIView()
        inputView.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        contentView.addSubview(inputTextField)
        inputTextField.snp.makeConstraints { make in
            make.top.left.bottom.equalToSuperview()
            make.height.equalTo(72)
        }
        
        let ml = UILabel()
        ml.textColor = .black
        ml.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        ml.text = "ml"
        contentView.addSubview(ml)
        ml.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview()
            make.left.equalTo(inputTextField.snp.right).offset(12)
        }
        
        view.addSubview(tipLabel)
        tipLabel.snp.makeConstraints { make in
            make.top.equalTo(inputView.snp.bottom).offset(80)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview()
        }
        
        let sliderView = UIView()
        view.addSubview(sliderView)
        sliderView.snp.makeConstraints { make in
            make.top.equalTo(tipLabel.snp.bottom).offset(30)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(32)
        }
        
        let reduceButton = UIButton()
        reduceButton.setImage(UIImage(named: "drink_reduce"), for: .normal)
        reduceButton.addTarget(self, action: #selector(reduce), for: .touchUpInside)
        sliderView.addSubview(reduceButton)
        reduceButton.snp.makeConstraints { make in
            make.top.left.bottom.equalToSuperview()
        }
        
        sliderView.addSubview(slider)
        slider.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.left.equalTo(reduceButton.snp.right).offset(8)
        }
        
        let addButton = UIButton()
        addButton.setImage(UIImage(named: "drink_add"), for: .normal)
        addButton.addTarget(self, action: #selector(add), for: .touchUpInside)
        sliderView.addSubview(addButton)
        addButton.snp.makeConstraints { make in
            make.top.bottom.right.equalToSuperview()
            make.left.equalTo(slider.snp.right).offset(8)
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
            make.top.equalTo(sliderView.snp.bottom).offset(60)
            make.left.equalToSuperview().offset(60)
            make.right.equalToSuperview().offset(-60)
            make.height.equalTo(52)
        }
        
    }
    
    override func setupNavigation() {
        super.setupNavigation()
        navigationItem.title = "Drinking water setting"
    }
    
}

extension DrinkSettingVC {
    
    @objc override func keyboardWillHidden() {
        if let text = inputTextField.text, text.count > 0 {
           if let total = Int(text), total > 0 {
                self.total = total
                inputTextField.text = "\(total)"
            } else {
                alert("Please input valid number.")
                inputTextField.text = "0"
                self.total = 0
            }
        } else {
            self.total = 0
        }
    }
    
}

extension DrinkSettingVC {
    
    @objc func sliderValueChanged() {
        total = Int(slider.value * 80.0) * 100
    }
    
    @objc func confirmAction() {
        if total == 0 {
            alert("Please enter the daily water intake")
            return
        }
        
        // 创建总量
        FileUtil.shared.setTotalML(ml: total)
        back()
    }
    
    @objc func reduce() {
        total = (total > 100) ? (total - 100) : 0
    }
    
    @objc func add() {
        total = (total < 8000) ? (total + 100) : 8000
    }
}
