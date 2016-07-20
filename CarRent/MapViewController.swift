//
//  MapViewController.swift
//  CarRent
//
//  Created by zhy on 16/7/7.
//  Copyright © 2016年 Valkyrie. All rights reserved.
//

import UIKit


class MapViewController: UIViewController, MAMapViewDelegate, AMapSearchDelegate {

	var mapView: MAMapView!
	var search: AMapSearchAPI!



    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		//初始化地图
		mapView = MAMapView(frame: view.frame)
		mapView.delegate = self

		view.addSubview(mapView)

		search = AMapSearchAPI()
		search.delegate = self

		
    }

	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)

		mapView.showsUserLocation = true
		mapView.userTrackingMode = MAUserTrackingMode.Follow
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


	//MARK: - map代理
	func mapView(mapView: MAMapView!, didLongPressedAtCoordinate coordinate: CLLocationCoordinate2D) {
		//逆地理编码请求
		let reGeoCode = AMapReGeocodeSearchRequest()

		reGeoCode.location = AMapGeoPoint.locationWithLatitude(CGFloat(coordinate.latitude), longitude: CGFloat(coordinate.longitude))

		//发送到查询服务
		search.AMapReGoecodeSearch(reGeoCode)
	}

	func mapView(mapView: MAMapView!, didSingleTappedAtCoordinate coordinate: CLLocationCoordinate2D) {
		//逆地理编码请求
		let reGeoCode = AMapReGeocodeSearchRequest()

		reGeoCode.location = AMapGeoPoint.locationWithLatitude(CGFloat(coordinate.latitude), longitude: CGFloat(coordinate.longitude))

		//发送到查询服务
		search.AMapReGoecodeSearch(reGeoCode)
	}

	func mapView(mapView: MAMapView!, viewForAnnotation annotation: MAAnnotation!) -> MAAnnotationView! {
		if annotation is MAPointAnnotation {
			let identifier = "annoView"
			var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier) as? MAPinAnnotationView

			if annotationView == nil {
				annotationView = MAPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
			}

			annotationView!.pinColor = MAPinAnnotationColor.Red
			annotationView!.animatesDrop = true
			annotationView!.canShowCallout = true

			return annotationView!
		}

		return nil
	}


	//MARK: - search代理
	func onReGeocodeSearchDone(request: AMapReGeocodeSearchRequest!, response: AMapReGeocodeSearchResponse!) {
		let annotation = MAPointAnnotation()

		annotation.coordinate = CLLocationCoordinate2D(latitude: Double(request.location.latitude), longitude: Double(request.location.longitude))
		annotation.title = response.regeocode.formattedAddress
		annotation.subtitle = response.regeocode.addressComponent.province

		mapView.addAnnotation(annotation)
	}

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

	//MARK: - customize

}
