//
//  UserViewController.swift
//  CarRent
//
//  Created by zhy on 16/7/7.
//  Copyright © 2016年 Valkyrie. All rights reserved.
//

import UIKit


class UserViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

	@IBOutlet weak var tableView: UITableView!
	@IBOutlet weak var settingsButton: UIButton!

	var dataSource: [[[String : String]]]?
	var headImageView: UIImageView!
	var headBlurView: UIVisualEffectView!
	var userImageView: UIImageView!
	var userNameLabel: UILabel!


	let headHeight = SCREEN_HEIGHT * 0.15


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.


		//navigationbar
		ClearBackView(target: self, superView: navigationController!.navigationBar)

		//tableView
        tableView.contentInset = UIEdgeInsets(top: headHeight, left: 0, bottom: 0, right: 0)
        tableView.delegate     = self
        tableView.dataSource   = self

		//tableView头部背景图
        headImageView               = UIImageView(frame: CGRect(x: 0, y: tableView.contentOffset.y, width: SCREEN_WIDTH, height: -tableView.contentOffset.y))
        headImageView.image         = UIImage(named: "1")
        headImageView.clipsToBounds = true
        headImageView.contentMode   = .ScaleAspectFill

		//头部背景图高斯模糊
        headBlurView       = UIVisualEffectView(effect: UIBlurEffect(style: .Light))
        headBlurView.frame = CGRect(x: 0, y: tableView.contentOffset.y, width: SCREEN_WIDTH, height: -tableView.contentOffset.y)
		
		tableView.addSubview(headImageView)
		tableView.addSubview(headBlurView)

		//用户头像
		userImageView = UIImageView(frame: CGRect(
			x: 20,
			y: -5,
			width: -tableView.contentOffset.y - navigationController!.navigationBar.frame.height - UIApplication.sharedApplication().statusBarFrame.height,
			height: -tableView.contentOffset.y - navigationController!.navigationBar.frame.height - UIApplication.sharedApplication().statusBarFrame.height))
		SetImageView(userImageView, image: UIImage(named: "头像")!, circle: true)

		//用户名称
//		let userName: NSString = "欢迎您"
//		let userNameSize = userName.boundingRectWithSize(
//			CGSize(),
//			options: .UsesFontLeading,
//			attributes: <#T##[String : AnyObject]?#>,
//			context: <#T##NSStringDrawingContext?#>)
//
//
//		userNameLabel = UILabel(frame: CGRect(x: userImageView.frame.minX + 15, y: <#T##CGFloat#>, width: <#T##CGFloat#>, height: <#T##CGFloat#>))


		//settings按钮
//		let settingsImage = UIImage(named: "设置")?.resizableImageWithCapInsets(
//			UIEdgeInsets(top: 5, left: 5, bottom: 0, right: 0)
//		)
//
//		settingsButton.setBackgroundImage(settingsImage, forState: .Normal)

		//tableView数据源
		dataSource = [
			[
				["text": "11", "detail": "2"],
				["text": "12", "detail": "3"]
			],
			[
				["text": "21", "detail": "2"],
				["text": "22", "detail": "3"]
			]
		]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */


	//MARK: - tableView代理方法
	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return dataSource == nil ? 0 : dataSource!.count
	}

	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return dataSource![section].count
	}

	func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return 1
	}

	func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
		return 9
	}

	func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		return 44
	}

	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let identifier = "user"
		var cell: UITableViewCell? = tableView.dequeueReusableCellWithIdentifier(identifier)

		if cell == nil {
			cell = UITableViewCell(style: .Default, reuseIdentifier: identifier)
		}

        cell?.textLabel?.text       = dataSource![indexPath.section][indexPath.row]["text"]
        cell?.detailTextLabel?.text = dataSource![indexPath.section][indexPath.row]["detail"]

		return cell!
	}

	//MARK: - scrollView代理
	func scrollViewDidScroll(scrollView: UIScrollView) {
//		print("offset: \(scrollView.contentOffset.y) headHeight: \(headHeight) offset: \(offset)")

        headImageView.frame    = CGRect(x: 0, y: scrollView.contentOffset.y, width: SCREEN_WIDTH, height: -scrollView.contentOffset.y)
        headBlurView.frame = CGRect(x: 0, y: scrollView.contentOffset.y, width: SCREEN_WIDTH, height: -scrollView.contentOffset.y)
	}
}
