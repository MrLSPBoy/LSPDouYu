//
//  LSRecommendViewController.swift
//  LSPDouYuTV
//
//  Created by lishaopeng on 17/2/28.
//  Copyright © 2017年 lishaopeng. All rights reserved.
//

import UIKit

private let kItemMargin : CGFloat = 10
private let kItemW : CGFloat = (kScreenW - 3 * kItemMargin) / 2
private let kNormalItemH : CGFloat = kItemW * 3 / 4
private let kPrettyItemH : CGFloat = kItemW * 4 / 3
private let kHeaderViewH: CGFloat = 50
private let KNormalCellId = "KNormalCellId"
private let KPrettyCellId = "KPrettyCellId"
private let KHeadViewCellId = "KHeadViewCellId"

class LSRecommendViewController: UIViewController {

    //MARK:-懒加载属性
    fileprivate lazy var recommendVM : LSRecommendViewModel = LSRecommendViewModel()
    
    //MARK:-懒加载
    fileprivate lazy var collectionView: UICollectionView = {[unowned self] in
        
        //1.创建布局
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: kItemW, height: kNormalItemH)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = kItemMargin
        layout.headerReferenceSize = CGSize(width: kScreenW, height: kHeaderViewH)
        layout.sectionInset = UIEdgeInsets(top: 0, left: kItemMargin, bottom: 0, right: kItemMargin)
        
        let collectionView = UICollectionView(frame: self.view.bounds, collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor.white
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.register(UINib(nibName: "LSCollectionNormalCell", bundle: nil), forCellWithReuseIdentifier: KNormalCellId)
        collectionView.register(UINib(nibName: "LSCollectionPrettyCell", bundle: nil), forCellWithReuseIdentifier: KPrettyCellId)
        collectionView.register(UINib(nibName: "LSCollectionHeaderView", bundle: nil), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: KHeadViewCellId)
        return collectionView
    }()
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.white
        //设置UI
        setupUI()
        
        loadData()
    }

}

//MARK:--设置UI界面内容
extension LSRecommendViewController{
    fileprivate func setupUI(){
        //1.将UICollectionView添加到控制器的View中
        view.addSubview(collectionView)
       
    }
}

//MARK:--请求数据
extension LSRecommendViewController{
    
    fileprivate func loadData(){
         recommendVM.requestData { 
            self.collectionView.reloadData()
        }
    }
}



//MARK:--遵守UICollectionView的数据源和代理协议
extension LSRecommendViewController : UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return recommendVM.anchorGroups.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let group = recommendVM.anchorGroups[section]
        return group.anchors.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        //0.取出模型对象
        let group = recommendVM.anchorGroups[indexPath.section]
        let achor = group.anchors[indexPath.item]
        
        //1.定义cell
        var cell : LSBaseCollectionViewCell!
        
        //1.获取cell
        
        
        if indexPath.section == 1 {
          cell = collectionView.dequeueReusableCell(withReuseIdentifier: KPrettyCellId, for: indexPath) as! LSBaseCollectionViewCell
        }else{
           cell = collectionView.dequeueReusableCell(withReuseIdentifier: KNormalCellId, for: indexPath) as! LSBaseCollectionViewCell
        }
        cell.anchor = achor
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        //1.取出section的HeaderView
        let headView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: KHeadViewCellId, for: indexPath) as! LSCollectionHeaderView
        //2.取出模型
        let group = recommendVM.anchorGroups[indexPath.section]
        
        headView.group = group
        
        return headView
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.section == 1{
            return CGSize(width: kItemW, height: kPrettyItemH)
        }else{
            return CGSize(width: kItemW, height: kNormalItemH)
        }
    }
}
