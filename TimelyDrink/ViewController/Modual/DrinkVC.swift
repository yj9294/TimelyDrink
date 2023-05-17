//
//  DrinkVC.swift
//  TimelyDrink
//
//  Created by yangjian on 2023/5/15.
//

import Foundation
import UIKit

class DrinkVC: BaseVC {
    
    lazy var emptyView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    lazy var progressContentView: UIView = {
        let progressContentView = UIView()
        return progressContentView
    }()
    
    lazy var progressView: CircleProgressView = {
        let view = CircleProgressView(frame: .zero)
        return view
    }()
    

    lazy var progressLabel: UILabel = {
        let progressLabel = UILabel()
        progressLabel.font = .systemFont(ofSize: 26)
        progressLabel.text = "0%"
        progressLabel.textColor = .black
        return progressLabel
    }()
    
    lazy var progressButton: UIButton = {
        let progressButton = UIButton()
        progressButton.backgroundColor = UIColor(named: "#E1B6FF")
        progressButton.setTitle("Daily drinking water \(total)ml", for: .normal)
        progressButton.setTitleColor(.black, for: .normal)
        progressButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 250, bottom: 0, right: 0)
        progressButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: -30, bottom: 0, right: 0)
        progressButton.setImage(UIImage(named: "drink_edit"), for: .normal)
        progressButton.layer.cornerRadius = 6
        progressButton.layer.masksToBounds = true
        progressButton.addTarget(self, action: #selector(toSettingVC), for: .touchUpInside)
        return progressButton
    }()
    
    lazy var recordButton = {
        let recordButton = UIButton()
        recordButton.setTitle("+ Record", for: .normal)
        recordButton.setTitleColor(.white, for: .normal)
        recordButton.backgroundColor = .black
        recordButton.layer.cornerRadius = 6
        recordButton.layer.masksToBounds = true
        recordButton.addTarget(self, action: #selector(toRecordVC), for: .touchUpInside)
        return recordButton
    }()
    
    var total: Int = FileUtil.shared.getTotalML()
    var today: Int = FileUtil.shared.getTodayDrinks()
    
    var progress: Int = 0 {
        didSet {
            if progress > 1000 {
                progress = 1000
            }
            progressAnimation()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refresh()
    }
    
    func refresh() {
        total = FileUtil.shared.getTotalML()
        today = FileUtil.shared.getTodayDrinks()
        
        progressContentView.isHidden = total == 0
        emptyView.isHidden = total != 0
        recordButton.setTitle( total == 0 ? "+ Drinking water plan" : "+ Record", for: .normal)
        
        progressButton.setTitle("Daily drinking water \(total)ml", for: .normal)
        
        if total > 0 {
            progress = Int( Double(today) / Double(total) * 1000 )
        }
    }
    
    @objc func toRecordVC() {
        if total == 0 {
            toSettingVC()
            return
        }
        
        let vc = DrinkRecordVC()
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
        FirebaseUtil.log(event: .drinkRecord)
    }
    
    @objc func toSettingVC() {
        let vc = DrinkSettingVC()
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
        FirebaseUtil.log(event: .drinkSettin)
    }
    
}

extension DrinkVC {
    
    override func setupUI() {
        view.backgroundColor = .white
        
        let leftItem = UIImageView(image: UIImage(named: "home_left_item"))
        view.addSubview(leftItem)
        leftItem.snp.makeConstraints { make in
            make.top.equalTo(view.snp.topMargin).offset(-28)
            make.left.equalToSuperview().offset(20)
        }
        
        let contentView = UIView()
        view.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.top.equalTo(view.snp.topMargin)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(view.snp.bottomMargin)
        }
        
        let centerView = UIView()
        contentView.addSubview(centerView)
        centerView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.right.equalToSuperview()
        }
        
        centerView.addSubview(progressContentView)
        progressContentView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
        }
        
        centerView.addSubview(emptyView)
        emptyView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.right.bottom.equalTo(progressContentView)
        }
        
        let progressImageView = UIImageView(image: UIImage(named: "drink_bg"))
        progressContentView.addSubview(progressImageView)
        progressImageView.snp.makeConstraints { make in
            make.top.left.right.bottom.equalToSuperview()
        }
        
        progressContentView.addSubview(progressView)
        progressView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(22)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(200)
        }
        
        let progressIconView = UIImageView(image: UIImage(named: "drink_icon"))
        progressImageView.addSubview(progressIconView)
        progressIconView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(80)
            make.centerX.equalToSuperview()
        }
        

        progressContentView.addSubview(progressLabel)
        progressLabel.snp.makeConstraints { make in
            make.top.equalTo(progressIconView.snp.bottom).offset(12)
            make.centerX.equalToSuperview()
        }
        
        
        progressContentView.addSubview(progressButton)
        progressButton.snp.makeConstraints { make in
            make.top.equalTo(progressLabel.snp.bottom).offset(34)
            make.left.equalToSuperview().offset(32)
            make.right.equalToSuperview().offset(-32)
            make.height.equalTo(56)
        }
        
        
        centerView.addSubview(recordButton)
        recordButton.snp.makeConstraints { make in
            make.top.equalTo(progressContentView.snp.bottom).offset(24)
            make.left.equalToSuperview().offset(30)
            make.right.equalToSuperview().offset(-30)
            make.height.equalTo(52)
            make.bottom.equalToSuperview()
        }
        
        
    }
    
    override func setupNavigation() {
        super.setupNavigation()
    }
    
}

extension DrinkVC {
    
    func progressAnimation() {
        var progress = 0
        Timer.scheduledTimer(withTimeInterval: 0.005, repeats: true) { [weak self] timer in
            guard let self = self else {return}
            if progress >= self.progress {
                timer.invalidate()
            } else {
                progress += Int(0.005 / 2 * 1000)
                self.progressView.setProgress(progress)
                self.progressLabel.text = "\(progress/10)%"
            }
        }
    }
    
}
