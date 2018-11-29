//
//  handles.swift
//  chatApp
//
//  Created by NTGMM-02 on 13/07/18.
//  Copyright © 2018 NTGMM-02. All rights reserved.
//

import UIKit
import AVFoundation
extension chatMessagesCell{
    
    @objc func  handleferjiView(tapGesture:UITapGestureRecognizer){
        if let view =  tapGesture.view{
            self.performZoomForPlayingVedio(view)
        }
    }
    
    func performZoomForPlayingVedio(_ startingImageView: UIView) {
        self.startingImageView = startingImageView
        startingFrame = startingImageView.superview?.convert(startingImageView.frame, to: nil)
        zoomingView = UIImageView(frame: startingFrame!)
        if  let KeyWindow = UIApplication.shared.keyWindow {
            keyWindow  = KeyWindow
            if let keyWindow = keyWindow {
                blackBackgroundView = UIView(frame: keyWindow.frame)
                blackBackgroundView?.backgroundColor = UIColor.black
                blackBackgroundView?.alpha = 0
                keyWindow.addSubview(blackBackgroundView!)
                setupminimizeButton()
                keyWindow.addSubview(zoomingView!)
                keyWindow.addSubview(self.tapView)
                tapView.addSubview(handleVedioView)
                handleVedioView.isHidden = true
                setUpStartButton()
                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                    self.blackBackgroundView?.alpha = 1
                    let height = self.startingFrame!.height / self.startingFrame!.width * keyWindow.frame.width
                    self.zoomingView?.frame = CGRect(x: 0, y: 0, width: keyWindow.frame.width, height: height)
                    self.zoomingView?.center = keyWindow.center
                    if let url = self.message?.imageUrl{
                        self.zoomingView!.loadImageUsingCacheWithUrlString(url)
                    }
                    self.tapView.frame = self.zoomingView!.frame
                    self.chatLogController?.inputContainerView.isHidden = true
                }, completion: { (completed) in
                    self.startButton.isHidden = false
                    self.tapView.isHidden = false
                })
            }}
    }
    
    @objc func handleZoomOut(){
        player?.pause()
        tapView.isHidden = true
        handleVedioView.isHidden = true
        handleVedioView.removeFromSuperview()
        startButton.isHidden = true
        activityIndicatorView.stopAnimating()
        if let zoomOutImageView = zoomingView {
            //need to animate back out to controller
            zoomOutImageView.layer.cornerRadius = 16
            zoomOutImageView.clipsToBounds = true
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                zoomOutImageView.frame = self.startingFrame!
                self.blackBackgroundView?.alpha = 0
                // self.inputContainerView.alpha = 1
                self.handleVedioView.isHidden = true
                self.chatLogController?.inputContainerView.isHidden = false
            }, completion: { (completed) in
                zoomOutImageView.removeFromSuperview()
                self.messageImage.isHidden = false
            })
        }
    }

    
}
