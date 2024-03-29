//
//  ViewController.swift
//  Twitter-Slide-Out
//
//  Created by Rishabh Raj on 01/07/19.
//  Copyright © 2019 Rishabh Raj. All rights reserved.
//

import UIKit

class HomeController: UITableViewController {
    
    fileprivate let cellId = "cellId"

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        tableView.backgroundColor = .red
        setupNavigationItems()
        
        setupMenuController()
        
        // Pan Gesture
        setupPanGesture()
        
        setupDarkCoverView()
        
        
    }
    
    let darkCoverView = UIView()
    
    fileprivate func setupDarkCoverView() {
        darkCoverView.backgroundColor = UIColor(white: 0, alpha: 0.8)
        darkCoverView.alpha = 0
//        navigationController?.view.addSubview(darkCoverView)
       darkCoverView.isUserInteractionEnabled = false
        
        let mainWindow = UIApplication.shared.keyWindow
        mainWindow?.addSubview(darkCoverView)
        darkCoverView.frame = mainWindow?.frame ?? .zero

    }
    
    // Private functions below public
    let menuController = MenuController()
    
    fileprivate let menuWidth : CGFloat = 300
    fileprivate var isMenuOpened = false
    fileprivate let velocityOpenThreshold : CGFloat = 500
    
    @objc func handleOpen() {
        isMenuOpened = true
        performAnimations(transform: CGAffineTransform(translationX: self.menuWidth, y: 0))
        
    }
    
    @objc func handleHide() {
        isMenuOpened = false
        performAnimations(transform: .identity)
    
    }
    
    @objc func handlePan(gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)
        
        if gesture.state == .changed {
            var x = translation.x
            
            if isMenuOpened {
                x += menuWidth
            }
            
            x = min(menuWidth,x)
            
            x = max(0,x)
            
            let transform = CGAffineTransform(translationX: x, y: 0)
            
            menuController.view.transform = transform
            navigationController?.view.transform = transform
            darkCoverView.transform = transform
            
            darkCoverView.alpha = x / menuWidth
        }else if gesture.state == .ended {
            handleEnded(gesture: gesture)
        }
    }
    
    fileprivate func setupPanGesture() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        view.addGestureRecognizer(panGesture)
    }
    
    fileprivate func handleEnded(gesture : UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)
        
        let velocity = gesture.velocity(in: view)
        
        if isMenuOpened {
            if abs(velocity.x) > velocityOpenThreshold {
                handleHide()
                return
            }
            
            if abs(translation.x) < menuWidth / 2{
                 handleOpen()
            }else {
               handleHide()
            }
        }
        else {
            if velocity.x > velocityOpenThreshold {
                handleOpen()
                return
            }
                if translation.x < menuWidth / 2 {
                    handleHide()
                }else {
                    handleOpen()
                }
            }
    }
    
    fileprivate func performAnimations(transform : CGAffineTransform) {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.menuController.view.transform = transform
            self.navigationController?.view.transform = transform
            self.darkCoverView.transform = transform
            
            self.darkCoverView.alpha = transform == .identity ? 0 : 1
            
//            if transform == .identity {
//                self.darkCoverView.alpha = 0
//            }else {
//                self.darkCoverView.alpha = 1
//            }
//            
            
        })
    }
    
    fileprivate func setupMenuController() {
        menuController.view.frame = CGRect(x: -menuWidth, y: 0, width: menuWidth, height: UIScreen.main.bounds.height)
        
        let mainWindow = UIApplication.shared.keyWindow
        
        mainWindow?.addSubview(menuController.view)
        addChild(menuController)
    }
    
    fileprivate func setupNavigationItems() {
        navigationItem.title = "Home"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Open", style: .plain, target: self, action: #selector(handleOpen))
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Hide", style: .plain, target: self, action: #selector(handleHide))
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        cell.textLabel?.text = "Row: \(indexPath.item)"
        return cell
    }


}

