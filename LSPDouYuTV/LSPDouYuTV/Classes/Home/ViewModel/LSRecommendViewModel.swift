//
//  LSRecommendViewModel.swift
//  LSPDouYuTV
//
//  Created by lishaopeng on 17/3/1.
//  Copyright © 2017年 lishaopeng. All rights reserved.
//

import UIKit

class LSRecommendViewModel: LSBaseViewModel {
   //MARK:-懒加载属性
    lazy var cycleModels : [LSCycleModel] = [LSCycleModel]()
    fileprivate lazy var bigDataGroup : LSAnchorGroup = LSAnchorGroup()
    fileprivate lazy var prettyGroup : LSAnchorGroup = LSAnchorGroup()
}

//MARK:--发送网络请求
extension LSRecommendViewModel {
    
    //请求推荐的数据
    func requestData(finishCallBack : @escaping () -> ()){
        
        //0.定义参数
        let parameters = ["limit" : "4","offset" : "0","time" : NSDate.getCurrentTime] as [String : Any]
        
        //1.创建group
        let dis_group = DispatchGroup()
        //2.请求数据
        //1.请求第一部分的推荐数据
        //入组
        dis_group.enter()
        NetworkTools.requestData(.GET, URLString: "http://capi.douyucdn.cn/api/v1/getbigDataRoom", parameters: ["time" : NSDate.getCurrentTime()]) { (result) in
            //1.1将result转成字典类型
            guard let resultDict = result as? [String : NSObject],
                let dataArray = resultDict["data"] as? [[String : NSObject]]else{
                    return
            }
            //1.2遍历数组，获取字典，并且将字典转成模型对象
           
            //1.2.1设置组的属性
            self.bigDataGroup.tag_name = "热门"
            self.bigDataGroup.icon_name = "home_header_hot"
            //1.2.2获取主播数据
            for dict in dataArray{
                let anchor = LSAnchorModel(dict: dict)
                self.bigDataGroup.anchors.append(anchor)
            }
            //出组
            dis_group.leave()
            //print("第一组")
        }
        
        
        
        //2.请求第二部分颜值数据
        dis_group.enter()
        NetworkTools.requestData(.GET, URLString: "http://capi.douyucdn.cn/api/v1/getVerticalRoom", parameters: parameters) { (result) in
            //2.1将result转成字典类型
            guard let resultDict = result as? [String : NSObject],
                  let dataArray = resultDict["data"] as? [[String : NSObject]]else{
                    return
            }
            //2.2遍历数组，获取字典，并且将字典转成模型对象
        
            //2.2.1设置组的属性
            self.prettyGroup.tag_name = "颜值"
            self.prettyGroup.icon_name = "home_header_phone"
            //2.2.2获取主播数据
            for dict in dataArray{
                let anchor = LSAnchorModel(dict: dict)
                self.prettyGroup.anchors.append(anchor)
            }
            //出组
            dis_group.leave()
             //print("第二组")
        }
        
        
        
        //3.请求2-12部分游戏数据
        dis_group.enter()
        loadAnchorData(isGroupData: true, URLString: "http://capi.douyucdn.cn/api/v1/getHotCate", parameters: parameters) {
            //出组
            dis_group.leave()
        }
        
        dis_group.notify(queue: DispatchQueue.main) {
            //print("完成")
            self.anchorGroups.insert(self.prettyGroup, at: 0)
            self.anchorGroups.insert(self.bigDataGroup, at: 0)
            finishCallBack()
        }
    }
    
    //请求无线轮播
    func requestCycleData(finishCallBack : @escaping () -> ()) {
        NetworkTools.requestData(.GET, URLString: "http://www.douyutv.com/api/v1/slide/6", parameters: ["version" : "2.300"]) { (result) in
//            print(result)
            //1.获取整体字典数据
            guard let resultDic = result as? [String : NSObject],
                  let dataArray = resultDic["data"] as? [[String : NSObject]] else {return}
            
            //2.字典转模型对象
            for dic in dataArray{
                self.cycleModels.append(LSCycleModel(dict: dic))
            }

            finishCallBack()
        }
    }
}
