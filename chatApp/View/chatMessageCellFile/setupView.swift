//
//  setupView.swift
//  chatApp
//
//  Created by NTGMM-02 on 13/07/18.
//  Copyright © 2018 NTGMM-02. All rights reserved.
//
import UIKit
extension chatMessagesCell{
   func setupViews(){
    addSubview(bubbleView)
    addSubview(messagesTextView)
    bubbleView.addSubview(messageFerjiView)
    messageFerjiView.frame = bubbleView.frame
    addSubview(profileImageInMessage)
    bubbleView.addSubview(messageImage)
    messageImage.leftAnchor.constraint(equalTo: bubbleView.leftAnchor).isActive = true
    messageImage.topAnchor.constraint(equalTo: bubbleView.topAnchor).isActive = true
    messageImage.widthAnchor.constraint(equalTo: bubbleView.widthAnchor).isActive = true
    messageImage.heightAnchor.constraint(equalTo: bubbleView.heightAnchor).isActive = true
    
    bubbleView.addSubview(playButton)
    playButton.centerXAnchor.constraint(equalTo: bubbleView.centerXAnchor).isActive = true
    playButton.centerYAnchor.constraint(equalTo: bubbleView.centerYAnchor).isActive = true
    playButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
    playButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
    
    bubbleView.addSubview(FerjiView)
    FerjiView.widthAnchor.constraint(equalTo: bubbleView.widthAnchor).isActive = true
    FerjiView.leftAnchor.constraint(equalTo: bubbleView.leftAnchor).isActive = true
    FerjiView.topAnchor.constraint(equalTo: bubbleView.topAnchor).isActive = true
    FerjiView.heightAnchor.constraint(equalTo: bubbleView.heightAnchor).isActive = true
    
    bubbleView.addSubview(activityIndicatorView)
    activityIndicatorView.centerXAnchor.constraint(equalTo: bubbleView.centerXAnchor).isActive = true
    activityIndicatorView.centerYAnchor.constraint(equalTo: bubbleView.centerYAnchor).isActive = true
    activityIndicatorView.widthAnchor.constraint(equalToConstant: 50).isActive = true
    activityIndicatorView.heightAnchor.constraint(equalToConstant: 50).isActive = true
    
    profileImageInMessage.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
    profileImageInMessage.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
    profileImageInMessage.widthAnchor.constraint(equalToConstant: 32).isActive = true
    profileImageInMessage.heightAnchor.constraint(equalToConstant: 32).isActive = true
    
    //x,y,w,h
    
    bubbelrightAncher = bubbleView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -8)
    bubbelrightAncher?.isActive = true
    bubbelleftAncher = bubbleView.leftAnchor.constraint(equalTo: profileImageInMessage.rightAnchor, constant: 8)
    bubbleView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
    bubbelWidth = bubbleView.widthAnchor.constraint(equalToConstant: 200)
    bubbelWidth?.isActive = true
    bubbleView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
    
    messagesTextView.leftAnchor.constraint(equalTo: bubbleView.leftAnchor, constant: 8).isActive = true
    messagesTextView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
    messagesTextView.rightAnchor.constraint(equalTo: bubbleView.rightAnchor).isActive = true
    messagesTextView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
    
    messagesTextView.addSubview(messageTextFerjiView)
    messageTextFerjiView.leftAnchor.constraint(equalTo: messagesTextView.leftAnchor).isActive = true
    messageTextFerjiView.bottomAnchor.constraint(equalTo: messagesTextView.bottomAnchor).isActive = true
    messageTextFerjiView.rightAnchor.constraint(equalTo: messagesTextView.rightAnchor).isActive = true
    messageTextFerjiView.topAnchor.constraint(equalTo: messagesTextView.topAnchor).isActive = true
    
    addSubview(deleteView)
    deleteView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
    deleteView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
    deleteView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
    deleteView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
    
    }
    func  setUpStartButton(){
        keyWindow?.addSubview(self.startButton)
        startButton.isHidden = true
        NSLayoutConstraint.activate([self.startButton.centerXAnchor.constraint(equalTo: keyWindow!.centerXAnchor),self.startButton.centerYAnchor.constraint(equalTo: keyWindow!.centerYAnchor),self.startButton.heightAnchor.constraint(equalToConstant: 50),self.startButton.widthAnchor.constraint(equalToConstant: 50)])
    }
    
    func  setupminimizeButton(){
        if let blackBackgroundView = blackBackgroundView{
            blackBackgroundView.addSubview(minimizeButton)
            NSLayoutConstraint.activate([minimizeButton.centerXAnchor.constraint(equalTo: blackBackgroundView.centerXAnchor),minimizeButton.topAnchor.constraint(equalTo: blackBackgroundView.topAnchor, constant: 50),minimizeButton.widthAnchor.constraint(equalToConstant: 100),minimizeButton.heightAnchor.constraint(equalToConstant: 50)])
        }
    }

}
