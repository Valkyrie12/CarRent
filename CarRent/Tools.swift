//
//  Tools.swift
//  CarManagement
//
//  Created by zhy on 16/4/11.
//  Copyright © 2016年 随便. All rights reserved.
//


import UIKit
import Alamofire
import MapKit
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



//MARK: - 城市列表
//let cityList = [750: "洋浦", 14: "南阳", 30: "济宁", 440: "自贡", 665: "福建全省", 254: "蚌埠", 177: "红河", 182: "大理", 443: "平顶山", 3: "毕节", 198: "张掖", 206: "临夏", 32: "聊城", 58: "常州", 201: "嘉峪关", 717: "铜川", 385: "汉中", 223: "长春", 153: "东莞", 731: "三沙", 103: "三明", 284: "长治", 23: "济南", 342: "伊春", 386: "南充", 90: "克孜勒苏", 5: "六盘水", 216: "秦皇岛", 195: "兰州", 63: "徐州", 348: "大兴安岭", 11: "洛阳", 116: "绍兴县", 333: "咸阳", 232: "银川", 236: "中卫", 364: "九江", 273: "阿拉善", 268: "包头", 675: "浙江全省", 294: "陵水", 320: "盘锦", 105: "南平", 257: "亳州", 193: "渭南", 274: "通辽", 310: "沈阳", 323: "威海", 402: "萍乡", 189: "北京", 224: "吉林", 442: "漯河", 209: "石家庄", 202: "武威", 210: "唐山", 361: "鹰潭", 145: "恩施", 9: "黔西南", 282: "大同", 44: "寿光", 35: "德州", 152: "深圳", 197: "天水", 262: "六安", 327: "镇江", 297: "琼中", 684: "辽阳", 381: "新余", 678: "海南全省", 135: "荆州", 681: "安徽全省", 279: "乌海", 15: "开封", 29: "泰安", 326: "乳山", 204: "金昌", 97: "泉州", 191: "宝鸡", 137: "黄冈", 276: "乌兰察布", 275: "鄂尔多斯", 22: "驻马店", 129: "舟山", 183: "迪庆", 219: "张家口", 178: "丽江", 267: "呼和浩特", 57: "无锡", 250: "合肥", 69: "连云港", 329: "温州", 194: "延安", 213: "沧州", 269: "兴安", 91: "石河子", 302: "定安县", 229: "松原", 317: "铁岭", 335: "朝阳", 319: "葫芦岛", 340: "齐齐哈尔", 215: "承德", 668: "江西全省", 325: "文登", 120: "温岭", 682: "湖北全省", 214: "廊坊", 285: "临汾", 674: "黑龙江全省", 350: "赣州", 368: "巴中", 158: "江门", 357: "宜春", 130: "临海", 190: "西安", 176: "曲靖", 125: "上虞", 266: "池州", 228: "辽源", 142: "孝感", 253: "黄山", 679: "吉林全省", 180: "普洱", 211: "保定", 341: "鸡西", 251: "芜湖", 689: "商洛", 7: "铜仁", 127: "丽水", 344: "鹤岗", 241: "湘潭", 16: "鹤壁", 735: "凉山", 714: "资阳", 393: "内江", 264: "宿州", 742: "奎屯", 303: "儋州", 307: "临高县", 26: "淄博", 696: "德阳", 66: "盐城", 304: "保亭", 290: "朔州", 392: "榆林", 79: "伊犁", 65: "宜兴", 24: "青岛", 308: "东方", 83: "哈密", 663: "山西全省", 365: "郑州", 72: "溧阳", 339: "牡丹江", 19: "三门峡", 88: "塔城", 109: "杭州", 148: "天门", 292: "海口", 351: "南昌", 160: "惠州", 239: "衡阳", 218: "衡水", 86: "吐鲁番", 80: "克拉玛依", 111: "义乌", 10: "新乡", 358: "信阳", 667: "贵州全省", 426: "泸州", 121: "桐乡", 147: "潜江", 654: "新疆全省", 157: "珠海", 281: "太原", 347: "七台河", 48: "招远", 227: "白山", 33: "滕州", 378: "阿坝", 174: "玉溪", 199: "白银", 4: "黔东南", 162: "肇庆", 140: "随州", 288: "忻州", 17: "濮阳", 154: "佛山", 77: "乌鲁木齐", 286: "晋城", 306: "乐东", 68: "常熟", 334: "益阳", 277: "呼伦贝尔", 278: "巴彦淖尔", 293: "三亚", 196: "酒泉", 258: "滁州", 428: "抚州", 28: "潍坊", 200: "庆阳", 84: "和田", 6: "安顺", 144: "咸宁", 131: "平湖", 659: "四川全省", 124: "玉环县", 12: "焦作", 377: "广安", 25: "烟台", 134: "宜昌", 207: "陇南", 301: "屯昌县", 118: "金华", 78: "巴音郭楞", 37: "莱芜", 337: "大庆", 366: "襄阳", 338: "佳木斯", 2: "遵义", 316: "营口", 255: "安庆", 683: "湖南全省", 188: "怒江", 101: "漳州", 117: "嘉兴", 123: "诸暨", 146: "神农架", 225: "四平", 141: "荆门", 27: "临沂", 181: "临沧", 300: "文昌", 359: "上饶", 87: "阿勒泰", 76: "西宁", 736: "海北", 710: "绵阳", 21: "周口", 718: "雅安", 370: "遂宁", 143: "鄂州", 280: "上海", 184: "楚雄", 256: "马鞍山", 260: "淮南", 311: "大连", 427: "达州", 231: "延边", 173: "昆明", 100: "莆田", 709: "眉山", 271: "赤峰", 85: "昌吉", 56: "南京", 322: "济源", 89: "博尔塔拉", 186: "文山", 155: "中山", 18: "商丘", 53: "肥城", 62: "扬州", 664: "云南全省", 265: "宣城", 701: "本溪", 263: "巢湖", 346: "双鸭山", 312: "鞍山", 345: "绥化", 299: "昌江", 106: "宁德", 230: "白城", 20: "许昌", 296: "琼海", 38: "枣庄", 226: "通化", 349: "天津", 233: "吴忠", 179: "昭通", 59: "苏州", 208: "定西", 217: "邢台", 39: "菏泽", 34: "日照", 46: "胶州", 698: "攀枝花", 734: "甘孜", 81: "阿克苏", 95: "福州", 168: "梅州", 295: "白沙", 309: "万宁", 314: "锦州", 369: "泰州", 336: "哈尔滨", 287: "阳泉", 298: "澄迈县", 96: "厦门", 237: "长沙", 305: "五指山", 332: "重庆", 291: "吕梁", 272: "锡林郭勒", 360: "景德镇", 289: "晋中", 115: "永康", 252: "阜阳", 313: "丹东", 64: "南通", 690: "宜宾", 104: "龙岩", 31: "东营", 685: "乐山", 110: "宁波", 658: "广东全省", 384: "淮安", 205: "甘南", 474: "宿迁", 8: "黔南", 175: "保山", 151: "广州", 261: "淮北", 128: "衢州", 657: "宁夏全省", 212: "邯郸", 362: "吉安", 40: "滨州", 283: "运城", 82: "喀什", 13: "安阳", 240: "株洲", 259: "铜陵", 192: "安康", 122: "海宁", 318: "阜新", 343: "黑河", 203: "平凉", 1: "贵阳", 138: "十堰", 185: "西双版纳", 234: "石嘴山", 662: "甘肃全省", 149: "仙桃", 161: "潮州", 139: "黄石", 315: "抚顺", 653: "青海全省", 133: "武汉", 54: "成都", 677: "河北全省", 694: "广元", 235: "固原", 660: "内蒙古全省", 112: "台州", 126: "湖州", 187: "德宏", 119: "绍兴"]