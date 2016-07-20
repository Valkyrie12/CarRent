//
//  Tools.swift
//  CarManagement
//
//  Created by zhy on 16/4/11.
//  Copyright © 2016年 随便. All rights reserved.
//


import UIKit
import Alamofire
//import MapKit
import WebImage
import CryptoSwift


//MARK: - 全局变量

//let nibArray: Array<UINib> = Array<UINib>()		//nib array，加速xib文件加载


//public typealias ExecuteClosure = @convention(block)() -> Void
var tempClosure: () -> Void = {}			//临时闭包存储属性，用来传递闭包

//根据设备尺寸动态调整按钮文字大小
var buttonFontSize: CGFloat {
	switch SCREEN_WIDTH {
	case 320:
		return 15
		
	case 375:
		return 17
		
	case 414:
		return 19
		
	default:
		return 17
	}
}

//MARK: - 设置网络图片
public func SetImageView(imageView: UIImageView, imageURL URL: String?, circle isCircle: Bool) {
	if URL != nil {
		imageView.sd_setImageWithURL(NSURL(string: PUBLIC_URL + URL!), placeholderImage: UIImage(named: "placeholder"))
	}
	else {
		imageView.sd_setImageWithURL(NSURL(string: ""), placeholderImage: UIImage(named: "placeholder"))
	}
	
	if isCircle {
		imageView.layer.cornerRadius = imageView.frame.width / 2
	}
	
	
	imageView.clipsToBounds = true
	imageView.contentMode = UIViewContentMode.ScaleAspectFill
}


public func SetImageView(imageView: UIImageView, image: UIImage, circle isCircle: Bool) {
	imageView.image = image
	
	if isCircle {
		imageView.layer.cornerRadius = imageView.frame.width / 2
	}
	
	imageView.clipsToBounds = true
	imageView.contentMode = UIViewContentMode.ScaleAspectFill
}


//MARK: - 弹出警示窗口
public func ShowAlertWindow(target vc: UIViewController, alertTitle title: String?, message msg: String?, actionTitle actTitle: String) {
	let controller = UIAlertController(title: title, message: msg, preferredStyle: UIAlertControllerStyle.Alert)
	
	let action = UIAlertAction(title: actTitle, style: UIAlertActionStyle.Default) { (UIAlertAction) -> Void in
		controller.dismissViewControllerAnimated(true, completion: nil)
	}
	
	controller.addAction(action)
	
	vc.presentViewController(controller, animated: true, completion: nil)
}

public func ShowActionSheet(target vc: UIViewController, andActions acts: UIAlertController -> Void) {
	let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
	
	acts(sheet)
	
	vc.presentViewController(sheet, animated: true, completion: nil)
}

public func ShowAlertWindow(target vc: UIViewController, alertTitle title: String?, message msg: String?, actionTitle actTitle: String, actionCompletionHandler action: () -> Void) {
	
	let controller = UIAlertController(title: title, message: msg, preferredStyle: UIAlertControllerStyle.Alert)
	
	let action = UIAlertAction(title: actTitle, style: UIAlertActionStyle.Default) { (UIAlertAction) -> Void in
		controller.dismissViewControllerAnimated(true, completion: nil)
		
		action()
	}
	
	controller.addAction(action)
	
	vc.presentViewController(controller, animated: true, completion: nil)
}

public func ShowAlertController(forTarget vc: UIViewController, withStyle style: UIAlertControllerStyle, alertTitle title: String?, message msg: String?, addActions: ((UIAlertController) -> [UIAlertAction])?) -> UIAlertController {
	let controller = UIAlertController(title: title, message: msg, preferredStyle: style)
	
    if addActions != nil {
        for action in addActions!(controller) {
            controller.addAction(action)
        }
    }
	
	vc.presentViewController(controller, animated: true, completion: nil)
	
	return controller
}


public func ShowDatePicker(target vc: UIViewController, mode: UIDatePickerMode, frame: CGRect?, completionHandler action: (NSDate -> Void)?) -> UIDatePicker {
    let datePicker = UIDatePicker(frame: (frame != nil)
                                       ? frame!
                                       : CGRectMake(0, SCREEN_HEIGHT - 216, SCREEN_WIDTH, 216))
    
    datePicker.datePickerMode = mode
    datePicker.setDate(NSDate(), animated: false)
    
    //设置模糊背景
    let blurView   = UIVisualEffectView(effect: UIBlurEffect(style: .Light))
    blurView.frame = CGRectMake(0, datePicker.frame.minY - 30, SCREEN_WIDTH, datePicker.frame.height + 30)
    
    //设置完成条
    let completeView             = UIView(frame: CGRectMake(0, datePicker.frame.minY - 30, SCREEN_WIDTH, 30))
    completeView.backgroundColor = UIColor.clearColor();
    //completeView下方分割线
    let layer             = CALayer()
    layer.frame           = CGRectMake(0, 30 - 0.5, SCREEN_WIDTH, 0.5)
    layer.backgroundColor = UIColor ( red: 0.7556, green: 0.7556, blue: 0.7556, alpha: 1.0 ).CGColor
    
    completeView.layer.addSublayer(layer)
    
    //添加完成按钮
    let completeBtn              = CMButton(type: .Custom)
    completeBtn.frame            = CGRectMake(SCREEN_WIDTH - 60, 0, 60, 30)
    completeBtn.setTitle("完成", forState: .Normal)
    completeBtn.setTitleColor(UIColor ( red: 0.2031, green: 0.3677, blue: 0.9483, alpha: 1.0 ), forState: .Normal)
    completeBtn.titleLabel?.font = UIFont.systemFontOfSize(16)
    completeBtn.addTarget(forControlEvents: .TouchUpInside) {
        //执行回调
        action?(datePicker.date)
        
        //下移所有view
        UIView.animateWithDuration(0.3, animations: {
            blurView.frame     = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, blurView.frame.height)
            datePicker.frame   = CGRectMake(0, SCREEN_HEIGHT + 30, SCREEN_WIDTH, datePicker.frame.height)
            completeView.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, completeView.frame.height)
        })
        
        //移除所有datePicker相关view
        CMTimer.scheduledTimerWithTimeInterval(0.3, userInfo: nil, repeats: false, completionHandler: { (timer) in
            blurView.removeFromSuperview()
            completeView.removeFromSuperview()
            datePicker.removeFromSuperview()
        })
    }
    
    completeView.addSubview(completeBtn)
    
    //添加subviews
    vc.view.addSubview(blurView)
    vc.view.addSubview(datePicker)
    vc.view.addSubview(completeView)
    
    return datePicker
}


//MARK: - post请求封装方法
public func PostWithInterface(service service: String, parameters para: [String: AnyObject]?) -> Request {
	var paras: [String: AnyObject]!
	
	if para != nil {
		paras = para
	} else {
		paras = [String: AnyObject]()
	}
	
//    paras["r"]        = service
    paras["deviceID"] = DEVICE_ID!.sha1()
    
	return request(.POST, PUBLIC_URL + "?r=" + service, parameters: paras, encoding: .URL, headers: nil)
}

public func PostWithInterface(service: String, parameters para: [String : AnyObject]?, andConfiguration conf: NSURLSessionConfiguration) -> Request {
    let manager = Manager(configuration: conf)
    
    var paras: [String: AnyObject]!
    
    if para != nil {
        paras = para
    } else {
        paras = [String: AnyObject]()
    }
    
//    paras["r"]        = service
    paras["deviceID"] = DEVICE_ID!.sha1()
    
    return manager.request(.POST, PUBLIC_URL + "?r=" + service, parameters: paras, encoding: .URL, headers: nil)
}

public struct UploadData {
	var data: NSData!
	var name: String!
	var fileName: String?
	var mimeType: String?
	
	init(data: NSData!, name: String!, fileName: String?, mimeType: String?) {
		self.data = data
		self.name = name
		self.fileName = fileName
		self.mimeType = mimeType
	}
}

//上传图片，可带参数
public func UploadWithPostParameters(interface service: String, parameters para: [String: String]?, uploadDataArray data: [UploadData], encodingCompletionSuccess succcessHandler: Response<AnyObject, NSError> -> Void, encodingCompletionFailure failureHandler: ErrorType -> Void) {
	
	upload(.POST, PUBLIC_URL + service, multipartFormData: { (MultipartFormData) -> Void in
		for upData in data {
			MultipartFormData.appendBodyPart(data: upData.data, name: upData.name, fileName: upData.fileName!, mimeType: upData.mimeType!)
		}
		
		if para != nil {
			for (key, value) in para! {
				MultipartFormData.appendBodyPart(data: value.dataUsingEncoding(NSUTF8StringEncoding)!, name: key)
			}
			
			//添加deviceid
			MultipartFormData.appendBodyPart(data: DEVICE_ID!.md5().dataUsingEncoding(NSUTF8StringEncoding)!, name: "deviceid")
		}
	}) { (encodingResult) -> Void in
		switch encodingResult {
		case .Success(request: let upload, streamingFromDisk: _, streamFileURL: _):
			upload.responseJSON(completionHandler: succcessHandler)
			
		case .Failure(let error):
			failureHandler(error)
		}
	}
}


//MARK: - NSTimer扩展，使其支持闭包
class CMTimer {
	var timerClosure: (NSTimer -> Void)?
	
	init(action: NSTimer -> Void) {
		timerClosure = action
	}
	
	//重载timer方法，添加闭包
	class func scheduledTimerWithTimeInterval(ti: NSTimeInterval, userInfo: AnyObject?, repeats yesOrNo: Bool, completionHandler handler: NSTimer -> Void) {
		let cmTimer = CMTimer(action: handler)
		
		NSTimer.scheduledTimerWithTimeInterval(ti, target: cmTimer, selector: #selector(timerSelector(_:)), userInfo: userInfo, repeats: yesOrNo)
	}
	
	@objc func timerSelector(timer: NSTimer) {
		timerClosure!(timer)
	}
}

//var EMTimerClosure: NSTimer -> Void = {_ in}
//extension NSTimer {
//	//重载timer方法，添加闭包
//	public class func scheduledTimerWithTimeInterval(ti: NSTimeInterval, userInfo: AnyObject?, repeats yesOrNo: Bool, completionHandler handler: NSTimer -> Void) {
//		self.scheduledTimerWithTimeInterval(ti, target: self, selector: #selector(timerClosure(_:)), userInfo: userInfo, repeats: yesOrNo)
//		EMTimerClosure = handler
//	}
//	
//	//充当selector
//	func timerClosure(timer: NSTimer) {
//		EMTimerClosure(timer)
//	}
//}


//MARK: - UIButton子类，使其支持闭包
class CMButton: UIButton {
	var buttonAction: (() -> Void)?
	
	func addTarget(forControlEvents controlEvents: UIControlEvents, responseAction action: () -> Void) {
		super.addTarget(self, action: #selector(actionSelector), forControlEvents: controlEvents)
		buttonAction = action
	}
	
	func actionSelector() {
		buttonAction!()
	}
}


//MARK: - tap手势子类，使其支持闭包
class CMTapGestureRecognizer: UITapGestureRecognizer {
	var _action: (() -> Void)!
	
	init(action: () -> Void) {
		super.init(target: nil, action: nil)
		_action = action
	}
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
	
	class func addTarget(action: () -> Void) -> CMTapGestureRecognizer {
		let cmTap = CMTapGestureRecognizer(action: action)
		
		cmTap.addTarget(cmTap, action: #selector(tapSelector))
		
		return cmTap
	}
	
	func tapSelector() {
		_action()
	}
}


class CMLongPressGestureRecognizer: UILongPressGestureRecognizer {
	var _action: (() -> Void)!
	
	init(action: () -> Void) {
		super.init(target: nil, action: nil)
		_action = action
	}
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
	
	class func addTarget(action: () -> Void) -> CMLongPressGestureRecognizer {
		let cmPress = CMLongPressGestureRecognizer(action: action)
		
		cmPress.addTarget(cmPress, action: #selector(pressSelector))
		
		return cmPress
	}
	
	func pressSelector() {
		_action()
	}
}


extension MJRefreshNormalHeader {
	public class func refreshingAction(action: () -> Void) -> MJRefreshNormalHeader {
		tempClosure = action
		return MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(MJRefreshNormalHeader.action))
	}
	
	class func action() {
		tempClosure()
	}
}


//MARK: - other
public func SetNavItemTitle(title: String, color: UIColor, forItem item: UINavigationItem) {
    let label       = UILabel()
    label.text      = title
    label.textColor = color
    label.font      = UIFont.boldSystemFontOfSize(18)
    
    item.titleView = label
    
    label.sizeToFit()
}

//MARK: - 清除导航栏背景
public func ClearBackView(target vc: UIViewController, superView view: UIView) {
	if view.isKindOfClass(NSClassFromString("_UINavigationBarBackground")!) {
		for view in view.subviews {
			if view.isKindOfClass(UIImageView) {
				//                    view.removeFromSuperview()
				view.hidden = true
			}
		}

		let navBackView: UIView = view
		navBackView.backgroundColor = UIColor.orangeColor().colorWithAlphaComponent(0)
	}
	else if view.isKindOfClass(NSClassFromString("_UIBackdropView")!) {
		view.hidden = true
	}

	for subView in view.subviews {
		ClearBackView(target: vc, superView: subView)
	}
}
