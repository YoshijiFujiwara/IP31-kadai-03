//
//  ViewController.swift
//  H03031
//
//  Created by web on 2019/06/07.
//  Copyright © 2019 web. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, UITextFieldDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var displayMap: MKMapView! // マップビュー
    var center: CLLocationCoordinate2D! //
    @IBOutlet weak var searchText: UITextField! // 検索用テキストボックス
    var myLocationManager:CLLocationManager! //
    @IBOutlet weak var latitudeLabel: UILabel! // 緯度のラベル
    @IBOutlet weak var longitudeLabel: UILabel! // 経度のラベル
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // delegeteの設定
        searchText.delegate = self
        
        center = CLLocationCoordinate2DMake(35.691529, 139.696872)
        let pin = MKPointAnnotation()
        pin.coordinate = center
        pin.title="初期地点"
        displayMap.addAnnotation(pin)
        // の許可を求めるメッセージの表示、取得
        myLocationManager = CLLocationManager()
        // 位置情報の許可を得る（常時）
//        myLocationManager.requestAlwaysAuthorization()
        // 位置情報の許可を得る（アプリ起動時）
        myLocationManager.requestWhenInUseAuthorization()
        
        let status = CLLocationManager.authorizationStatus()
        
        if status == .authorizedWhenInUse {
            myLocationManager.delegate = self
            myLocationManager.distanceFilter = 50.0
        }
    }
    
    // 吹き出しに表示されているボタンが押された時に動くメソッド
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let view = MKAnnotationView(annotation: annotation, reuseIdentifier: "AnnotId")
        view.canShowCallout = true
        return view
    }
    
    // 位置情報に関するデリゲートメソッド
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        latitudeLabel.text = "緯度：" + (manager.location?.coordinate.latitude.description)!
        longitudeLabel.text = "緯度：" + (manager.location?.coordinate.longitude.description)!
        
        print("緯度：" + (manager.location?.coordinate.latitude.description)!)
        print("緯度：" + (manager.location?.coordinate.longitude.description)!)
        
        let location = locations.last! as CLLocation
        
        // トラッキングピンを立てる
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)

        let pin = MKPointAnnotation()
        pin.coordinate = center
        pin.title="tracking"
        
        displayMap.addAnnotation(pin)
    }
    
    // 緯度・経度情報が取れなかった時に動く
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // キーを隠す
        searchText.resignFirstResponder()
        // ジオコーディング
        let geocorder = CLGeocoder()
        let searchKeyword = searchText.text
        geocorder.geocodeAddressString(searchKeyword!, completionHandler: {(placemarks: [CLPlacemark]?, error: Error?) in
            // nilだったらelseに移動。thenの処理をしなさい。 if let placemark = placemarks?[0]{
            if let placemark = placemarks?[0]{
                if let targetCoordinate = placemark.location?.coordinate{
                    //targetCoordinateに緯度経度が必ず入っている
                    let pin = MKPointAnnotation()
                    pin.coordinate = targetCoordinate //centerと同じ
                    self.displayMap.addAnnotation(pin)
                    var region:MKCoordinateRegion = self.displayMap.region
                    region.center = targetCoordinate
                    region.span.latitudeDelta = 0.02
                    region.span.longitudeDelta = 0.02
                    self.displayMap.setRegion(region, animated:true) }
            }
        })
        
        return true
    }
    
    
    @IBAction func myButtonAction(_ sender: Any) {
        // 押されたボタンによって条件分岐
        let buttonTagButton:UIButton = sender as! UIButton
        let buttonTag = buttonTagButton.tag
        
        center = CLLocationCoordinate2DMake(35.691529, 139.696872)
        let pin = MKPointAnnotation()
        
        switch buttonTag {
        case 0:
            center = CLLocationCoordinate2DMake(34.699707, 135.493144)
        case 1:
            center = CLLocationCoordinate2DMake(35.691571, 139.697084)
        case 2:
            center = CLLocationCoordinate2DMake(35.168174, 136.885764)
        default:
            print("対応してないタグのボタンが押されました")
        }
        
        pin.coordinate = center
        pin.title = buttonTagButton.currentTitle
        displayMap.addAnnotation(pin)
        
        var region:MKCoordinateRegion = self.displayMap.region
        region.center = center
        region.span.latitudeDelta = 0.2
        region.span.longitudeDelta = 0.2
        self.displayMap.setRegion(region, animated:true)
    }
    
    @IBAction func appleButtonAction(_ sender: Any) {
        let buttonTagButton:UIButton = sender as! UIButton
        let pin = MKPointAnnotation()
        center = CLLocationCoordinate2DMake(37.331676, -122.030189)
        
        pin.coordinate = center
        pin.title = buttonTagButton.currentTitle
        displayMap.addAnnotation(pin)
        
        var region:MKCoordinateRegion = self.displayMap.region
        region.center = center
        region.span.latitudeDelta = 0.2
        region.span.longitudeDelta = 0.2
        self.displayMap.setRegion(region, animated:true)
    }
    
    @IBAction func changeMode(_ sender: Any) {
        if displayMap.mapType == .hybrid {
            displayMap.mapType = .standard
        } else if displayMap.mapType == .standard {
            displayMap.mapType = .satellite
        } else {
            displayMap.mapType = .hybrid
        }
    }
    
    // トラッキング開始
    @IBAction func startTracking(_ sender: Any) {
        let trackingButton:UIButton = sender as! UIButton
        // タイトル取得
        let nowTitle = trackingButton.currentTitle
        
        switch nowTitle {
        case "開始":
            trackingButton.setTitle("停止", for: UIControl.State.normal)
            print("現在位置の取得開始")
            // 現在位置の取得開始
            myLocationManager.startUpdatingLocation()
        case "停止":
            trackingButton.setTitle("開始", for: UIControl.State.normal)
            print("現在位置の取得終了")
            // 現在位置の取得終了
            myLocationManager.stopUpdatingLocation()
        
        default:
            print("error")
        }
        
    }
    
    // クリアボタン
    @IBAction func allClear(_ sender: Any) {
        // ピンの一括削除
        for annotation in displayMap.annotations {
            if annotation.title == "tracking" {
                displayMap.removeAnnotation(annotation)
            }
        }
    }
}

