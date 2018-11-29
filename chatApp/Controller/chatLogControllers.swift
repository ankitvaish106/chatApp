import UIKit
import Firebase
import MobileCoreServices
import AVFoundation

class ChatLogController: UICollectionViewController, UITextFieldDelegate, UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var user: User? {
        didSet {
            titleView.addSubview(name)
            name.translatesAutoresizingMaskIntoConstraints = false
            StatusName.translatesAutoresizingMaskIntoConstraints = false
            
            titleView.addSubview(StatusName)
            name.text = user?.name
            Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(getStatus), userInfo: nil, repeats: true)
            navigationItem.titleView = titleView
            titleView.frame = CGRect(x: 0, y: 0, width: 150, height: 50)
            NSLayoutConstraint.activate([name.centerXAnchor.constraint(equalTo: titleView.centerXAnchor),name.heightAnchor.constraint(equalToConstant: 20),name.topAnchor.constraint(equalTo: titleView.topAnchor)])
            NSLayoutConstraint.activate([StatusName.centerXAnchor.constraint(equalTo: titleView.centerXAnchor),StatusName.heightAnchor.constraint(equalToConstant: 20),StatusName.topAnchor.constraint(equalTo: name.bottomAnchor)])
            observeMessages()
        }
    }
    
    @objc func  getStatus(){
        Database.database().reference().child("users").child((user?.id)!).child("online").observe(.value) { (snapshot) in
            if (self.user?.online)! == snapshot.value as? String{
                self.StatusName.text =  "online"
                self.StatusName.textColor = .blue
            }else{
                self.StatusName.text =  "offline"
                self.StatusName.textColor = .red
            }
        }
    }
    
    let name = UILabel()
    let StatusName = UILabel()
    let titleView:UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    var messages = [Message]()
     var messageController:MessagesController?
    func observeMessages() {
        guard let uid = Auth.auth().currentUser?.uid, let toId = user?.id else {
            return
        }
        
        let userMessagesRef = Database.database().reference().child("user-messages").child(uid).child(toId)
        userMessagesRef.observe(.childAdded, with: { (snapshot) in
            
            let messageId = snapshot.key
            let messagesRef = Database.database().reference().child("massages").child(messageId)
            messagesRef.observeSingleEvent(of: .value, with: { (snapshot) in
                
                guard let dictionary = snapshot.value as? [String: AnyObject] else {
                    return
                }
                
                self.messages.append(Message(dictionary: dictionary))
                DispatchQueue.main.async(execute: {
                    self.collectionView?.reloadData()
                    //scroll to the last index
                    let indexPath = IndexPath(item: self.messages.count - 1, section: 0)
                    self.collectionView?.scrollToItem(at: indexPath, at: .bottom, animated: true)
                })
                
            }, withCancel: nil)
            
        }, withCancel: nil)
    }
    
    
    
    let cellId = "cellId"
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        collectionView?.alwaysBounceVertical = true
        collectionView?.backgroundColor = UIColor.white
        collectionView?.register(chatMessagesCell.self, forCellWithReuseIdentifier: cellId)
        collectionView?.keyboardDismissMode = .interactive
        setupKeyboardObservers()
    }
    
    lazy var inputContainerView: bottomConatinerView = {
        let containerView = bottomConatinerView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50))
        containerView.chatlogController = self
        return containerView
    }()
    
    @objc func handleUploadTap() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.allowsEditing = true
        imagePickerController.delegate = self
        imagePickerController.mediaTypes = [kUTTypeImage as String, kUTTypeMovie as String]
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let videoUrl = info[UIImagePickerControllerMediaURL] as? URL {
            handleVideoSelectedForInfo(url: videoUrl as NSURL)
        } else {
            handleImageSelectedForInfo(info as [String : AnyObject])
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    private func handleVideoSelectedForInfo(url:NSURL){
      let filename = UUID().uuidString + ".mov"
        let storegRef = Storage.storage().reference().child("message_movies").child(filename)
        let ref  = storegRef.putFile(from: url as URL, metadata: nil) { (metadata, error) in
            if error != nil{
                print(error!)
                return
            }
            storegRef.downloadURL(completion: { (url, error) in
                if error != nil{
                    print(error!)
                    return
                }
                if let videoUrl = url?.absoluteString{
                    if let urlUrl = url?.absoluteURL{
                        if let thumbnailImage =  self.thumbnailImageForFileUrl(urlUrl){
                            self.uploadToFirebaseStorageUsingImage(thumbnailImage, completion: { (imageUrl) in
                                let properties: [String: AnyObject] = ["messages-images": imageUrl as AnyObject, "image-width": thumbnailImage.size.width as AnyObject, "image-height": thumbnailImage.size.height as AnyObject, "videoUrl": videoUrl as AnyObject]
                                self.sendMessageWithProperties(properties)
                                
                            })
                        }
                    }
                }
            })
        }
        // Add a progress observer to an upload task
        _ = ref.observe(.progress) { snapshot in
            if let completionUnitCount = snapshot.progress?.completedUnitCount{
                self.navigationItem.title = String(completionUnitCount)
            }
        }
        _ = ref.observe(.success, handler: { (snapshot) in
            self.navigationItem.title = self.user?.name
        })
    }
    fileprivate func thumbnailImageForFileUrl(_ fileUrl: URL) -> UIImage? {
        let asset = AVAsset(url: fileUrl)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        
        do {
            
            let thumbnailCGImage = try imageGenerator.copyCGImage(at: CMTimeMake(1, 60), actualTime: nil)
            return UIImage(cgImage: thumbnailCGImage)
            
        } catch let err {
            print(err)
        }
         return nil
    }
    
    fileprivate func handleImageSelectedForInfo(_ info: [String: AnyObject]) {
        var selectedImageFromPicker: UIImage?
        
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            selectedImageFromPicker = editedImage
        } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            
            selectedImageFromPicker = originalImage
        }
        
        if let selectedImage = selectedImageFromPicker {
            uploadToFirebaseStorageUsingImage(selectedImage, completion: { (imageUrl) in
                self.sendMessageWithImageUrl(imageUrl, image: selectedImage)
            })
        }
    }
    
    fileprivate func uploadToFirebaseStorageUsingImage(_ image: UIImage, completion: @escaping (_ imageUrl: String) -> ()) {
        let imageName = UUID().uuidString
        let ref = Storage.storage().reference().child("messages_images").child(imageName)
        
        if let uploadData = UIImageJPEGRepresentation(image, 0.2) {
            ref.putData(uploadData, metadata: nil) { (metadata, error) in
                if error != nil {
                    print("Failed to upload image:", error!)
                    return
                }

                ref.downloadURL { (url, error) in
                    
                    if error != nil{
                        print(error ?? "error")
                        return
                    }
                    if let urlstring = url?.absoluteString{
                       completion(urlstring)
                        
                    }}
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    override var inputAccessoryView: UIView? {
        get {
            return inputContainerView
        }
     }
    
    override var canBecomeFirstResponder : Bool {
        return true
    }
    
    func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardDidShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
    }
    
    @objc func handleKeyboardDidShow() {
        if messages.count > 0 {
            let indexPath = IndexPath(item: messages.count - 1, section: 0)
            collectionView?.scrollToItem(at: indexPath, at: .top, animated: true)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
//
//    func handleKeyboardWillShow(_ notification: Notification) {
//        let keyboardFrame = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
//        let keyboardDuration = (notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue
 //     containerViewBottomAnchor?.constant = -keyboardFrame!.height
//        UIView.animate(withDuration: keyboardDuration!, animations: {
//            self.view.layoutIfNeeded()
//        })
//    }
//
//    func handleKeyboardWillHide(_ notification: Notification) {
//        let keyboardDuration = (notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue
//
//        containerViewBottomAnchor?.constant = 0
//        UIView.animate(withDuration: keyboardDuration!, animations: {
//            self.view.layoutIfNeeded()
//        })
//    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! chatMessagesCell
         cell.chatLogController = self
        let message = messages[indexPath.item]
        cell.message = message
        cell.messagesTextView.text = message.text
        setupCell(cell, message: message)
        
        if let text = message.text {
            cell.bubbelWidth?.constant = estimateFrameForText(text).width + 32
            cell.messagesTextView.isHidden = false
        } else if message.imageUrl != nil {
            cell.bubbelWidth?.constant = 200
            cell.messagesTextView.isHidden = true
        }
        cell.playButton.isHidden = message.videoUrl == nil
        cell.FerjiView.isHidden = message.videoUrl == nil
        return cell
    }
//    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        print("sdsd")
//    }
    fileprivate func setupCell(_ cell: chatMessagesCell, message: Message) {
        if let profileImageUrl = self.user?.profileImageUrl {
            cell.profileImageInMessage.loadImageUsingCacheWithUrlString(profileImageUrl)
        }
        
        if message.fromId == Auth.auth().currentUser?.uid {
            //outgoing blue
            cell.bubbleView.backgroundColor = UIColor(r: 0, g: 137, b: 249)
            cell.messagesTextView.textColor = UIColor.white
            cell.profileImageInMessage.isHidden = true
            
            cell.bubbelrightAncher?.isActive = true
            cell.bubbelleftAncher?.isActive = false
            
        } else {
            //incoming gray
            cell.bubbleView.backgroundColor = UIColor(r: 240, g: 240, b: 240)
            cell.messagesTextView.textColor = UIColor.black
            cell.profileImageInMessage.isHidden = false
            
            cell.bubbelrightAncher?.isActive = false
            cell.bubbelleftAncher?.isActive = true
        }
        
        if let messageImageUrl = message.imageUrl {
            cell.messageImage.loadImageUsingCacheWithUrlString(messageImageUrl)
            cell.messageImage.isHidden = false
            cell.bubbleView.backgroundColor = UIColor.clear
        } else {
            cell.messageImage.isHidden = true
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView?.collectionViewLayout.invalidateLayout()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var height: CGFloat = 80
        
        let message = messages[indexPath.item]
        if let text = message.text {
            height = estimateFrameForText(text).height + 20
        } else if let imageWidth = message.image_width?.floatValue, let imageHeight = message.image_height?.floatValue {
            height = CGFloat(imageHeight / imageWidth * 200)
        }
         let width = UIScreen.main.bounds.width
        return CGSize(width: width, height: height)
    }
    
    fileprivate func estimateFrameForText(_ text: String) -> CGRect {
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        return  NSString(string: text).boundingRect(with: size, options: options, attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 16)], context: nil)
    }
    
    var containerViewBottomAnchor: NSLayoutConstraint?
    
    @objc func handleSend() {
        let properties = ["text": inputContainerView.inputTextField.text!]
        sendMessageWithProperties(properties as [String : AnyObject])
    }
    
    fileprivate func sendMessageWithImageUrl(_ imageUrl: String, image: UIImage) {
        let properties: [String: AnyObject] = ["messages-images": imageUrl as AnyObject, "image-width": image.size.width as AnyObject, "image-height": image.size.height as AnyObject]
        sendMessageWithProperties(properties)
    }
    
    fileprivate func sendMessageWithProperties(_ properties: [String: AnyObject]) {
        let ref = Database.database().reference().child("massages")
        let childRef = ref.childByAutoId()
        let toId = user!.id!
        let fromId = Auth.auth().currentUser!.uid
        let timestamp = Int(Date().timeIntervalSince1970)
        
        var values: [String: AnyObject] = ["deleteId":childRef.key as AnyObject,"toId": toId as AnyObject, "fromId": fromId as AnyObject, "timestamp": timestamp as AnyObject]

        properties.forEach({values[$0] = $1})
        
        childRef.updateChildValues(values) { (error, ref) in
            if error != nil {
                print(error!)
                return
            }
            
            self.inputContainerView.inputTextField.text = nil
            
            let userMessagesRef = Database.database().reference().child("user-messages").child(fromId).child(toId)
            
            let messageId = childRef.key
            userMessagesRef.updateChildValues([messageId!: 1])
            
            let recipientUserMessagesRef = Database.database().reference().child("user-messages").child(toId).child(fromId)
            recipientUserMessagesRef.updateChildValues([messageId!: 1])
        }
    }
    
    var startingFrame: CGRect?
    var blackBackgroundView: UIView?
    var startingImageView: UIImageView?
    
    //my custom zooming logic
    func performZoomInForStartingImageView(_ startingImageView: UIImageView) {
        
        self.startingImageView = startingImageView
        self.startingImageView?.isHidden = true
        
        startingFrame = startingImageView.superview?.convert(startingImageView.frame, to: nil)
        
        let zoomingImageView = UIImageView(frame: startingFrame!)
        zoomingImageView.backgroundColor = UIColor.red
        zoomingImageView.image = startingImageView.image
        zoomingImageView.isUserInteractionEnabled = true
        zoomingImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomOut)))
        
        if let keyWindow = UIApplication.shared.keyWindow {
            blackBackgroundView = UIView(frame: keyWindow.frame)
            blackBackgroundView?.backgroundColor = UIColor.black
            blackBackgroundView?.alpha = 0
            keyWindow.addSubview(blackBackgroundView!)
            
            keyWindow.addSubview(zoomingImageView)
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                
                self.blackBackgroundView?.alpha = 1
                self.inputContainerView.alpha = 0

                // h2 / w1 = h1 / w1
                // h2 = h1 / w1 * w1
                let height = self.startingFrame!.height / self.startingFrame!.width * keyWindow.frame.width
                
                zoomingImageView.frame = CGRect(x: 0, y: 0, width: keyWindow.frame.width, height: height)
                
                zoomingImageView.center = keyWindow.center
                
            }, completion: { (completed) in
                //                    do nothing
            })
            
        }
    }
    
    @objc func handleZoomOut(_ tapGesture: UITapGestureRecognizer) {
        if let zoomOutImageView = tapGesture.view {
            //need to animate back out to controller
            zoomOutImageView.layer.cornerRadius = 16
            zoomOutImageView.clipsToBounds = true
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                
                zoomOutImageView.frame = self.startingFrame!
                self.blackBackgroundView?.alpha = 0
                self.inputContainerView.alpha = 1
                
            }, completion: { (completed) in
                zoomOutImageView.removeFromSuperview()
                self.startingImageView?.isHidden = false
            })
        }
    }
}
