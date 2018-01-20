//
//  CustomContainerArrayView.swift
//  SteamScout
//
//  Created by Srinivas Dhanwada on 3/1/16.
//  Copyright © 2016 dhanwada. All rights reserved.
//

import UIKit

enum CCAVViewPos {
    case low, high, moving
}

struct CCAVViewData {
    var id:Int = 0
    var nc:UINavigationController
    var lowCenter:CGPoint = CGPoint.zero
    var highCenter:CGPoint = CGPoint.zero
    var panStartCenter:CGPoint = CGPoint.zero
    var halfwayPoint:CGPoint {
        get {
            return CGPoint(x: highCenter.x, y: (lowCenter.y + highCenter.y) / 2)
        }
    }
    var isShowing:Bool = false
    var viewPos:CCAVViewPos = .high
    
    func centerForViewPos() -> CGPoint {
        return self.viewPos == .high ? self.highCenter : self.lowCenter
    }
    
    init(id:Int, nc:UINavigationController) {
        self.id = id
        self.nc = nc
        self.lowCenter = CGPoint.zero
        self.highCenter = CGPoint.zero
        self.panStartCenter = CGPoint.zero
        self.isShowing = false
        self.viewPos = .high
    }
}

class CustomContainerArrayView: UIViewController {
    var views:[UIViewController] = [UIViewController]()
    var viewData:[CCAVViewData] = [CCAVViewData]()
    
    var panViews:[CCAVViewData] = [CCAVViewData]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        let v1 = UIViewController()
//        let v2 = UIViewController()
//        let v3 = UIViewController()
//        let v4 = UIViewController()
//        let v5 = UIViewController()
//        
//        self.views = [v1, v2, v3, v4, v5]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if viewData.count <= 0 {
            setupViewDataArray()
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(CustomContainerArrayView.orientationChange), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
    }
    
    func setupViewDataArray() {
        if views.count <= 0 {
            return;
        }
        
        for (index, value) in views.enumerated() {
            let nc = UINavigationController(rootViewController: value)
            nc.navigationBar.tag = index
            let tapRecog = UITapGestureRecognizer(target: self, action: #selector(CustomContainerArrayView.handleTap(_:)))
            nc.navigationBar.addGestureRecognizer(tapRecog)
            if index > 0 {
                let panRecog = UIPanGestureRecognizer(target: self, action: #selector(CustomContainerArrayView.handlePan(_:)))
                nc.navigationBar.addGestureRecognizer(panRecog)
                let borderRect = CGRect(x: 0, y: 0, width: nc.navigationBar.frame.width, height: 1)
                let border = UIView(frame: borderRect)
                border.backgroundColor = UIColor.lightGray
                nc.navigationBar.addSubview(border)
            }
            
            self.addChildViewController(nc)
            
            let y = nc.navigationBar.frame.height * CGFloat(index);
            let width = self.view.bounds.width
            let height = self.view.bounds.height - (nc.navigationBar.frame.height * CGFloat(self.views.count - 1))
            let frame = CGRect(x: 0, y: y, width: width, height: height)
            nc.view.frame = frame

            self.view.addSubview(nc.view)
            nc.didMove(toParentViewController: self)
            
//            value.navigationItem.title = "View \(index+1)"
//            let hue:CGFloat = CGFloat(arc4random_uniform(257)) / 256.0
//            let saturation:CGFloat = CGFloat(arc4random_uniform(129)) / 256.0 + 0.5
//            let brightness:CGFloat = CGFloat(arc4random_uniform(129)) / 256.0 + 0.5
//            let color = UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1.0)
//            value.view.backgroundColor = color
            var vd = CCAVViewData(id: index, nc: nc)
            
            vd.highCenter = nc.view.center
            vd.lowCenter = CGPoint(x: vd.highCenter.x, y: vd.highCenter.y + nc.view.frame.height - nc.navigationBar.frame.height)
            viewData.append(vd)
        }
        
        viewData[viewData.count - 1].isShowing = true
    }
    
    @objc func handleTap(_ sender:UITapGestureRecognizer) {
        //print("Tapped NC at Index: \(sender.view?.tag)")
        let view = self.viewData[sender.view!.tag]
        if view.isShowing { return }

        UIView.animate(withDuration: 0.2, animations: {
            for (index, value) in self.viewData.enumerated() {
                if index <= sender.view!.tag {
                    value.nc.view.center = value.highCenter
                    self.viewData[index].viewPos = .high
                } else {
                    value.nc.view.center = value.lowCenter
                    self.viewData[index].viewPos = .low
                }
            }
        })
        for i in 0..<self.viewData.count {
            self.viewData[i].isShowing = (i == sender.view!.tag)
        }
    }
    
    @objc func handlePan(_ sender:UIPanGestureRecognizer) {
        if sender.state == .began {
            self.panViews.removeAll()
            let view = self.viewData[sender.view!.tag]
            for i in 0..<self.viewData.count {
                if(i <= sender.view!.tag && view.viewPos == .low && self.viewData[i].viewPos == .low) {
                    panViews.append(self.viewData[i])
                } else if i >= sender.view!.tag && view.viewPos == .high && self.viewData[i].viewPos == .high {
                    panViews.append(self.viewData[i])
                }
            }
            for i in 0..<self.panViews.count {
                self.panViews[i].panStartCenter = self.panViews[i].nc.view.center
            }
        } else if sender.state == .changed {
            let translation = sender.translation(in: self.viewData[sender.view!.tag].nc.view)
            for i in 0..<self.panViews.count {
                let newCenter = CGPoint(x: self.panViews[i].panStartCenter.x, y: self.panViews[i].panStartCenter.y + translation.y)
                self.panViews[i].viewPos = self.panViews[i].halfwayPoint.y > newCenter.y ? .high : .low
                self.panViews[i].nc.view.center = newCenter
            }
        } else if sender.state == .ended {
            UIView.animate(withDuration: 0.2, animations: {
                for view in self.panViews {
                    view.nc.view.center = view.centerForViewPos()
                    for i in 0..<self.viewData.count {
                        if self.viewData[i].id == view.id {
                            self.viewData[i].viewPos = view.viewPos
                        }
                    }
                }
            }, completion: {complete in
                self.viewData[self.viewData.count - 1].isShowing = true
                for i in 0..<self.viewData.count-1 {
                    if self.viewData[i].viewPos == .high && self.viewData[i+1].viewPos == .low {
                        self.viewData[self.viewData.count - 1].isShowing = false
                        self.viewData[i].isShowing = true
                    } else {
                        self.viewData[i].isShowing = false
                    }
                }
            })
        }
    }
    
    @objc func orientationChange() {
        for i in 0..<self.viewData.count {
            let y = self.viewData[i].nc.navigationBar.frame.height * CGFloat(i);
            let width = self.view.bounds.width
            let height = self.view.bounds.height - (self.viewData[i].nc.navigationBar.frame.height * CGFloat(self.views.count - 1))
            let frame = CGRect(x: 0, y: y, width: width, height: height)
            self.viewData[i].nc.view.frame = frame
            self.viewData[i].highCenter = self.viewData[i].nc.view.center
            self.viewData[i].lowCenter = CGPoint(x: self.viewData[i].highCenter.x, y: self.viewData[i].highCenter.y + self.viewData[i].nc.view.frame.height - self.viewData[i].nc.navigationBar.frame.height)
            self.viewData[i].nc.view.center = self.viewData[i].centerForViewPos()
        }
    }
}
