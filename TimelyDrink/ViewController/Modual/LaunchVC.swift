//
//  LaunchVC.swift
//  TimelyDrink
//
//  Created by yangjian on 2023/5/15.
//

import Foundation
import UIKit

class LaunchVC: BaseVC {
    
    init(_ launched: (()->Void)? = nil) {
        super.init(nibName: nil, bundle: nil)
        self.launched = launched
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public var launched:(()->Void)? = nil
    
    lazy private var progressView: UIProgressView = {
        let progressView = UIProgressView()
        progressView.tintColor = .black
        progressView.backgroundColor = UIColor(named: "#EBD0FF")
        return progressView
    }()
    
    private var timer: Timer? = nil
    
    private var progress = 0.0 {
        didSet {
            DispatchQueue.main.async {
                if self.progress > 1.0 {
                    self.timer?.invalidate()
                    self.timer = nil
                    self.launched?()
                  return
                }
                self.progressView.progress = Float(self.progress)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        launching()
    }
    
    func launching() {
        let durateion = 3.0
        self.timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true, block: { [weak self] _ in
            guard let self = self else {return}
            self.progress += 0.01 / durateion
        })
    }
    
}

extension LaunchVC {
    
    override func setupUI() {
        super.setupUI()
        
        let bg = UIImageView(image: UIImage(named: "launch_background"))
        bg.contentMode = .scaleAspectFill
        view.addSubview(bg)
        bg.snp.makeConstraints { make in
            make.top.left.right.bottom.equalToSuperview()
        }
        
        let icon = UIImageView(image: UIImage(named: "launch_icon"))
        view.addSubview(icon)
        icon.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(view.snp.topMargin).offset(140)
        }
        
        view.addSubview(progressView)
        progressView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(88)
            make.right.equalToSuperview().offset(-88)
            make.bottom.equalTo(view.snp.bottomMargin).offset(-60)
        }
    }
    
    override func setupNavigation() {
        super.setupNavigation()
    }
    
}
