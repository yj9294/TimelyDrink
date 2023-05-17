//
//  Toolbar.swift
//  TimelyDrink
//
//  Created by yangjian on 2023/5/16.
//

import Foundation
import UIKit

protocol ToolbarDelegate {
    func toolbarDidSelected(item: ChartModel.Item)
}

class Toolbar: UIView {
    
    var delegate: ToolbarDelegate? = nil
    
    var selectItem: ChartModel.Item = .day
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var collection: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        let view = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        view.dataSource = self
        view.delegate = self
        view.backgroundView?.backgroundColor = .clear
        view.backgroundColor = .clear
        view.register(ToolBarCell.classForCoder(), forCellWithReuseIdentifier: "ChartToolBarCell")
        return view
    }()
    
    func setupUI() {
        self.backgroundColor = .white
        addSubview(collection)
        collection.snp.makeConstraints { make in
            make.top.left.right.bottom.equalToSuperview()
        }
    }
    
}

class ToolBarCell: UICollectionViewCell {
    
    private lazy var title: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
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
    
    private func setupUI() {
        
        self.layer.cornerRadius = 6
        self.layer.masksToBounds = true
        
        addSubview(title)
        title.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
        }
    }
    
    var item: ChartModel.Item? = nil {
        didSet {
            title.text = item?.rawValue.capitalized
        }
    }
    
    var select: Bool = false {
        didSet {
            title.textColor = select ? UIColor.white : UIColor(named: "#0F1034")
            backgroundColor = select ? UIColor(named: "#0F1034") : .white
        }
    }
    
}

extension Toolbar: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return ChartModel.Item.allCases.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ChartToolBarCell", for: indexPath)
        if let cell = cell as? ToolBarCell {
            let it = ChartModel.Item.allCases[indexPath.row]
            cell.item = it
            cell.select = selectItem == it
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let it = ChartModel.Item.allCases[indexPath.row]
        self.selectItem = it
        collectionView.reloadData()
        delegate?.toolbarDidSelected(item: it)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var width = self.bounds.width
        width = width / Double(ChartModel.Item.allCases.count)
        let height = self.bounds.height
        return CGSize(width: width, height: height)
    }
    
}
