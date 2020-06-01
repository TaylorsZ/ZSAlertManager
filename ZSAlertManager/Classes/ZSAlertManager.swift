//
//  ZSAlert.swift
//  Pods-ZSAlert_Example
//
//  Created by Taylor on 2020/5/20.
//

import UIKit

public let ZSAlertInstance = ZSAlertManager.manager

open class ZSAlert: NSObject {
    
    public  typealias ZSAlertHandler = (_ cancle:Bool) ->();
    
    public  typealias ZSAlertDismissHandler = () ->();
    /// 点击回调
  public  var handler:ZSAlertHandler?
   
    /// 标题
    private(set) var title: String?
    /// 信息文本
    private(set) var message: String?
    /// 消失回调
    var didDismiss:ZSAlertDismissHandler?
    
    private var alertController:UIAlertController?
    
    public init(title:String,message:String,handler:@escaping ZSAlertHandler) {
        super.init()

        self.title = title
        self.message = message
        self.handler = handler
        
        initAlertController()
    }
    
    func initAlertController() {
        
        alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: { [weak self] action in
            guard let strongSelf = self else {
                return
            }
            if strongSelf.handler != nil {
                strongSelf.handler!(true)
            }
            
            if strongSelf.didDismiss != nil {
                strongSelf.didDismiss!()
            }
        })
        alertController!.addAction(cancelAction)
        
        let confirmAction = UIAlertAction(title: "确认", style: .destructive, handler: { [weak self] action in
            
            guard let strongSelf = self else{
                return
            }
            if strongSelf.handler != nil {
                strongSelf.handler!(false)
            }
            if strongSelf.didDismiss != nil {
                strongSelf.didDismiss!()
            }
        })
        alertController!.addAction(confirmAction)
        
    }
    
    func show() {
        
        let rootVC = UIApplication.getTopMostViewController()
        rootVC?.present(alertController!, animated: true, completion: nil);
        
    }
    
    
    
}

open class ZSAlertManager: NSObject {
    
    
    
    
    var alertQueue:NSMutableArray = [];
    
    
    public static let manager: ZSAlertManager = {
        let instance = ZSAlertManager()
        return instance
    }()
    
    public func add(alert:ZSAlert?) {
        if alert != nil{
            
            alertQueue.add(alert!)
            
        }
        
    }
    public func add(alerts:[ZSAlert]) {
        alertQueue.addObjects(from: alerts)
        
    }
    public  func showAlerts() {
        
//        let aArray = alertQueue.sorted { (obj1, obj2) -> Bool in
//
//            let num1 = NSNumber(value: (obj1 as AnyObject).priority!)
//            let num2 = NSNumber(value: (obj2 as AnyObject).priority!)
//            let result = num1.compare(num2)
//            if result == .orderedAscending{
//                return true
//            }else{
//                return false
//            }
//            }
        
        
        
        showAlertInOrder()
    }
    func showAlertInOrder() {
        if alertQueue.count <= 0 {
            return
        }
        let alert:ZSAlert = alertQueue.firstObject as! ZSAlert
        
        alert.didDismiss = { [weak self] in
            guard let strongSelf = self  else{
                return
            }
            
            strongSelf.alertQueue.remove(alert)
            strongSelf.showAlertInOrder()
        }
        
        alert.show()
    }
}

extension UIApplication {
    class func getTopMostViewController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return getTopMostViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController {
                return getTopMostViewController(base: selected)
            }
        }
        if let presented = base?.presentedViewController {
            return getTopMostViewController(base: presented)
        }
        return base
    }
}
