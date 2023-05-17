//
//  ItemView.swift
//  TimelyDrink
//
//  Created by yangjian on 2023/5/16.
//

import Foundation
import UIKit

protocol ItemViewDataSource {
    func numberOfItemsInView(view: ItemView) -> Int
    func itemTitleForView(index: Int) -> String
    func itemImageForView(index: Int) -> UIImage?
    func itemSelectedAt(index: Int)
}

extension ItemViewDataSource {
    
    func itemSelectedAt(index: Int) {
    }
    
}

class ItemView: UIView {
    
    enum Flex {
        case horizontal, vertical
    }
    
    public var direction: Flex = .vertical
    
    public var datasource: ItemViewDataSource? = nil {
        didSet {
            setupUI()
        }
    }
    
    public var padding: Double = 12.0
    
    public var spacing: Double = 12.0
    
    public var isEnable: Bool = false
    
    public var height: CGFloat = 36.0
    
    private var lastHeight: Double = 0.0 {
        didSet {
            scrollView.snp.remakeConstraints { make in
                make.top.left.right.bottom.equalToSuperview()
                make.height.equalTo(lastHeight)
            }
        }
    }
    
    private lazy var scrollView: UIScrollView = {
        let view = UIScrollView()
        return view
    }()
    
    private var itemsView: [UIView] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        scrollView.subviews.forEach {
            $0.removeFromSuperview()
        }
        itemsView.removeAll()
        addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.top.left.right.bottom.equalToSuperview()
            make.height.equalTo(131)
        }
        if let number = datasource?.numberOfItemsInView(view: self), number > 0 {
            for index in 0..<number {
                if let title = datasource?.itemTitleForView(index: index), let image = datasource?.itemImageForView(index: index) {
                    let item = setItem(with: title, image: image , index: index)
                    itemsView.append(item)
                    scrollView.addSubview(item)
                }
            }
        }
    }
    
    private func setItem(with title: String, image: UIImage, index: Int) -> Item {
        let item = Item()
        item.setTitleColor(.black, for: .normal)
        item.setTitleColor(.white, for: .selected)
        item.setBackgroundColor(.white, for: .normal)
        item.setBackgroundColor(UIColor(named: "#5373F7"), for: .selected)
        item.title = title
        item.image = image
        item.isSelected = false
        item.layer.cornerRadius = 6
        item.layer.masksToBounds = true
        item.layer.borderWidth = 1
        item.isEnabled = isEnable
        item.layer.borderColor = UIColor(named: "#EEEEEE")?.cgColor
        item.selectedHandle = { it in
            self.selected(item: it)
        }
        return item
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if lastHeight != preparLayout() {
            lastHeight = preparLayout()
        }
    }
    
    @discardableResult
    func preparLayout() -> CGFloat {
        if direction == .vertical {
            // 锤子滚动
            var lastX = 0.0
            var lastY = 0.0
            itemsView.forEach { view in
                if lastX + view.bounds.width > self.bounds.width {
                    lastX = 0
                    lastY = lastY + height + spacing
                }
                view.frame = CGRect(x: lastX, y: lastY, width: view.bounds.width, height: view.bounds.height)
                lastX = lastX + view.bounds.width + padding
            }
            return height + lastY
        }
        return height
    }
    
    public func itemSelectedAt(index: Int) {
        itemsView.forEach { view in
            if let indexView = itemsView[index] as? Item, indexView == view {
                indexView.isSelected = true
            } else if let view  = view as? Item {
                view.isSelected = false
            }
        }
        datasource?.itemSelectedAt(index: index)
    }
    
   private func selected(item: Item) {
        itemsView.forEach { view in
            if let view  = view as? Item {
                view.isSelected = false
            }
        }
        item.isSelected = true
        if let index = itemsView.firstIndex(of: item) {
            datasource?.itemSelectedAt(index: index)
        }
    }
}

extension ItemView {
    func reloadData() {
        setupUI()
        setNeedsLayout()
    }
}

extension ItemView {
    
    class Item: UIControl {
        
        private lazy var iconView: UIImageView = {
            let imageView = UIImageView()
            imageView.contentMode = .scaleAspectFill
            return imageView
        }()
        
        private lazy var titleLabel: UILabel = {
            let label = UILabel()
            label.font = .systemFont(ofSize: 14, weight: .semibold)
            return label
        }()
        
        private lazy var eventButton: UIButton = {
            let button = UIButton()
            button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
            button.isEnabled = false
            return button
        }()
        
        private var titleColors: [UIControl.State.RawValue: UIColor] = [:]
        private var backgroundColors: [UIControl.State.RawValue: UIColor] = [:]
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            setupUI()
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override var isSelected: Bool {
            didSet {
                if isSelected {
                    titleLabel.textColor = titleColors[UIControl.State.selected.rawValue]
                    backgroundColor = backgroundColors[UIControl.State.selected.rawValue]
                } else {
                    titleLabel.textColor = titleColors[UIControl.State.normal.rawValue]
                    backgroundColor = backgroundColors[UIControl.State.normal.rawValue]
                }
            }
        }
        
        public override var isEnabled: Bool {
            didSet {
                eventButton.isEnabled = isEnabled
            }
        }
        
        var selectedHandle: ((Item)->Void)? = nil
        
        public var title: String? = nil {
            didSet {
                titleLabel.text = title
                layoutIfNeeded()
            }
        }
        
        public var image: UIImage? = nil {
            didSet {
                iconView.image = image
            }
        }
        
        private func setupUI () {
            addSubview(iconView)
            addSubview(titleLabel)
            addSubview(eventButton)
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            iconView.frame = CGRect(x: 10, y: 5, width: 20, height: 26)
            let width = title?.width(with: titleLabel.font) ?? 100.0
            titleLabel.frame = CGRect(x: iconView.frame.maxX + 9, y: 12, width: width, height: 20)
            self.bounds = CGRect(x: 0, y: 0, width: width + 10 + 20 + 6 + 20, height: 36.0)
            eventButton.frame = self.bounds
        }
        
        @objc private func buttonAction() {
            selectedHandle?(self)
        }
        
    }
    
}

extension ItemView.Item {
    
    func setTitleColor(_ color: UIColor?, for state: UIControl.State) {
        titleColors[state.rawValue] = color
    }
    
    func setBackgroundColor(_ color: UIColor?, for state: UIControl.State) {
        backgroundColors[state.rawValue] = color
    }

}
