//
//  chatMessagesCell2.swift
//  chatApp
//
//  Created by NTGMM-02 on 16/07/18.
//  Copyright © 2018 NTGMM-02. All rights reserved.
//

import UIKit
import AVFoundation

class chatMessagesCell: UICollectionViewCell {
    
    var message: Message?
    var chatLogController: ChatLogController?
    var playerLayer: AVPlayerLayer?
    var player: AVPlayer?
    var bubbelWidth: NSLayoutConstraint?
    var bubbelrightAncher: NSLayoutConstraint?
    var bubbelleftAncher: NSLayoutConstraint?
    var startingFrame: CGRect?
    var blackBackgroundView: UIView?
    var startingImageView: UIView?
    var zoomingView:UIImageView?
    var keyWindow:UIWindow?
    var isPlaying = true
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        
    }
    let activityIndicatorView: UIActivityIndicatorView = {
        let aiv = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        aiv.translatesAutoresizingMaskIntoConstraints = false
        aiv.hidesWhenStopped = true
        return aiv
    }()
    
    lazy var playButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        let image = UIImage(named: "play")
        button.tintColor = UIColor.white
        button.setImage(image, for: UIControlState())
    //    button.addTarget(self, action: #selector(handlePlay), for: .touchUpInside)
        return button
    }()
    

    
    @objc func handlePlay() {
        if let videoUrlString = message?.videoUrl, let url = URL(string: videoUrlString) {
            player = AVPlayer(url: url)
            playerLayer = AVPlayerLayer(player: player)
            playerLayer?.frame = zoomingView!.bounds
            zoomingView!.layer.addSublayer(playerLayer!)
            player?.play()
            playerObservers()
            setupActivityIndicatorView()
            activityIndicatorView.startAnimating()
            playPauseButton.isHidden = true
            startButton.isHidden = true
        }
    }
    func playerObservers(){
        player?.addObserver(self, forKeyPath: "currentItem.loadedTimeRanges", options: .new, context: nil)
        let interval = CMTime(value: 1, timescale: 2)
        player?.addPeriodicTimeObserver(forInterval: interval, queue:DispatchQueue.main, using: { (completion) in
            let duration = CMTimeGetSeconds(completion)
            let seconds = String(format:"%02d", Int(duration.truncatingRemainder(dividingBy:60)))
            let minute = String(format:"%02d",Int(duration/60))
            self.videoPlayerLabelLeft.text = "\(minute):\(seconds)"
            if let durations = self.player?.currentItem?.duration {
                let durationSeconds = CMTimeGetSeconds(durations)
                self.slider.value =  Float(duration / durationSeconds)
            }
        })
    }
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath ==  "currentItem.loadedTimeRanges"{
            activityIndicatorView.stopAnimating()
            playPauseButton.isHidden = false
            if let duration = player?.currentItem?.duration{
                let durationInSecond  = CMTimeGetSeconds(duration)
                let seconds = Int(durationInSecond.truncatingRemainder(dividingBy: 60))
                let minute = Int(durationInSecond) / 60
                let minuteInString = String(format: "%02d", minute)
                videoPlayerLabelRight.text = "\(minuteInString):\(seconds)"
            }
        }
        
    }
    func setupActivityIndicatorView(){
        keyWindow?.addSubview(activityIndicatorView)
        NSLayoutConstraint.activate([activityIndicatorView.centerXAnchor.constraint(equalTo:keyWindow!.centerXAnchor),activityIndicatorView.centerYAnchor.constraint(equalTo: keyWindow!.centerYAnchor),activityIndicatorView.widthAnchor.constraint(equalToConstant: 50),activityIndicatorView.heightAnchor.constraint(equalToConstant: 50)])
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        playerLayer?.removeFromSuperlayer()
        player?.pause()
        activityIndicatorView.stopAnimating()
    }
    
    let messagesTextView: UITextView = {
        let tv = UITextView()
        tv.text = "SAMPLE TEXT FOR NOW"
        tv.font = UIFont.systemFont(ofSize: 16)
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.backgroundColor = UIColor.clear
        tv.textColor = .white
        tv.isEditable = false
        return tv
    }()
    
    static let blueColor = UIColor(r: 0, g: 137, b: 249)
    
    let bubbleView: UIView = {
        let view = UIView()
        view.backgroundColor = blueColor
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        return view
    }()
    
    let profileImageInMessage: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 16
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    lazy var messageImage: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 16
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomTap)))
         return imageView
    }()
    
    @objc func handleZoomTap(_ tapGesture: UITapGestureRecognizer) {
        if message?.videoUrl != nil {
            return
        }
        
        if let imageView = tapGesture.view as? UIImageView {
            self.chatLogController?.performZoomInForStartingImageView(imageView)
        }
    }

    
    lazy var FerjiView:UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleferjiView)))
        return view
    }()

  
    lazy var startButton:UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(self.handlePlay), for: .touchUpInside)
        button.setImage(#imageLiteral(resourceName: "play").withRenderingMode(.alwaysOriginal), for: .normal)
        return button
    }()
 

    lazy var minimizeButton:UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Cancel", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 20)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(self.handleZoomOut), for: .touchUpInside)
        return button
    }()
    lazy var tapView:UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handletapView)))
        return view
    }()
    
    @objc func handletapView(_ tapGesture: UITapGestureRecognizer){
        if let view = tapGesture.view{
            setuphandleVedioView(view)
        }
        Timer.scheduledTimer(timeInterval: 7, target: self, selector: #selector(self.handleRemoveVedioView), userInfo: nil, repeats: false)
    }
    @objc func handleRemoveVedioView(){
        handleVedioView.isHidden = true
    }
    lazy var  playPauseButton:UIButton={
        let play = UIButton(type: .system)
        play.setImage(#imageLiteral(resourceName: "pause").withRenderingMode(.alwaysOriginal), for: .normal)
        play.tintColor = .white
        play.isHidden = false
        play.addTarget(self, action: #selector(handlePlayPause), for: .touchUpInside)
        play.translatesAutoresizingMaskIntoConstraints = false
        return play
    }()
    @objc func handlePlayPause(){
        if isPlaying{
            player?.pause()
            playPauseButton.setImage(#imageLiteral(resourceName: "play").withRenderingMode(.alwaysOriginal), for: .normal)
        }
        else{
            player?.play()
            playPauseButton.setImage(#imageLiteral(resourceName: "pause").withRenderingMode(.alwaysOriginal), for: .normal)
        }
        isPlaying = !isPlaying
    }
    
    let videoPlayerLabelRight:UILabel = {
        let label = UILabel()
        label.text = "00:00"
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 13)
        label.textAlignment = .right
        return label
        
    }()
    
    let videoPlayerLabelLeft:UILabel = {
        let label = UILabel()
        label.text = "00:00"
        label.textColor = .white
        label.font = .systemFont(ofSize: 13)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .left
        return label
        
    }()
    lazy var slider:UISlider = {
        let slide = UISlider()
        slide.minimumTrackTintColor = .red
        slide.maximumTrackTintColor = .white
        slide.setThumbImage(UIImage(named: "thumb"), for: .normal)
        slide.addTarget(self, action: #selector(handleSlideChange), for: .valueChanged)
        slide.translatesAutoresizingMaskIntoConstraints = false
        return slide
    }()
    @objc func handleSlideChange(){
        if let duration = player?.currentItem?.duration{
            let totalSecond = CMTimeGetSeconds(duration)
            let value = Float64(slider.value)*totalSecond
            let seekTime = CMTime(value: Int64(value), timescale: 1)
            player?.seek(to: seekTime, completionHandler: { (completion) in
            })
        }
        
    }
    func setuphandleVedioView(_ view:UIView){
        self.handleVedioView.isHidden = false
        handleVedioView.frame = view.bounds
        handleVedioView.backgroundColor = .clear
        handleVedioView.addSubview(playPauseButton)
        playPauseButton.centerXAnchor.constraint(equalTo: handleVedioView.centerXAnchor).isActive = true
        playPauseButton.centerYAnchor.constraint(equalTo: handleVedioView.centerYAnchor).isActive = true
        playPauseButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        playPauseButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        handleVedioView.addSubview(videoPlayerLabelRight)
        handleVedioView.addSubview(videoPlayerLabelLeft)
        
        NSLayoutConstraint.activate([videoPlayerLabelRight.rightAnchor.constraint(equalTo: handleVedioView.rightAnchor, constant: -8),videoPlayerLabelRight.bottomAnchor.constraint(equalTo: handleVedioView.bottomAnchor),videoPlayerLabelRight.widthAnchor.constraint(equalToConstant: 50),videoPlayerLabelRight.heightAnchor.constraint(equalToConstant: 24)])
        NSLayoutConstraint.activate([videoPlayerLabelLeft.leftAnchor.constraint(equalTo: handleVedioView.leftAnchor, constant: 8),videoPlayerLabelLeft.bottomAnchor.constraint(equalTo: handleVedioView.bottomAnchor),videoPlayerLabelLeft.widthAnchor.constraint(equalToConstant: 50),videoPlayerLabelLeft.heightAnchor.constraint(equalToConstant: 24)])
        handleVedioView.addSubview(slider)
        NSLayoutConstraint.activate([slider.rightAnchor.constraint(equalTo: videoPlayerLabelRight.leftAnchor),slider.bottomAnchor.constraint(equalTo: handleVedioView.bottomAnchor),slider.heightAnchor.constraint(equalToConstant: 25),slider.leftAnchor.constraint(equalTo: videoPlayerLabelLeft.rightAnchor)])
        
    }
    lazy var  handleVedioView:UIView = {
        let view = UIView()
        view.backgroundColor = .yellow
         //view.addObserver(self, forKeyPath: <#T##String#>, options: .new, context: nil)
        return view
    }()
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
}
}
