
import UIKit
import Firebase

class ChatViewController: JSQMessagesViewController {
//    let incomingBubble = JSQMessagesBubbleImageFactory().incomingMessagesBubbleImageWithColor(UIColor.lightGrayColor())
//    let outgoingBubble = JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImageWithColor(UIColor(red: 102/255, green: 103/255, blue: 151/255, alpha: 1.0))
    
    let incomingBubble = JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleLightGrayColor())
    let outgoingBubble = JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleBlueColor())
    
    
    var messages = [JSQMessage]()
    var friend: UserMsgModel?
    var userId: String?
    var ref: FIRDatabaseReference = FIRDatabase.database().reference()
    private var messageRef: FIRDatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Chat"
        self.senderId = self.userId!
        self.senderDisplayName = self.userId!
        self.setup()
        self.observeMessages()
    }
    
    func setUser(userId: String, friend: UserMsgModel) {
        self.userId = userId
        self.friend = friend
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

//MARK - Setup
extension ChatViewController {
    func observeMessages() {
        messageRef = ref.child("convers").child("\(self.friend!.converId)")
        messageRef.queryLimitedToFirst(25).observeEventType(.ChildAdded, withBlock: { (snapshot) in
            if let msgDict = snapshot.value as? Dictionary<String, AnyObject> {
                if let name = msgDict["senderName"] as? String, let text = msgDict["text"] as? String {
                    self.addMessage(withId: name, name: name, text: text)
                    self.finishReceivingMessage()
                }
            }
        })
    }
    
    private func addMessage(withId id: String, name: String, text: String) {
        if text.characters.count > 0, let message = JSQMessage(senderId: name, displayName: name, text: text) {
            messages.append(message)
        }
    }
    
    func setup() {
        self.collectionView.collectionViewLayout.incomingAvatarViewSize = CGSizeMake(40, 40)
        self.collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSizeMake(40, 40)
    }
}

//MARK - Data Source
extension ChatViewController {
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.messages.count
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        let data = self.messages[indexPath.row]
        return data
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, didDeleteMessageAtIndexPath indexPath: NSIndexPath!) {
        self.messages.removeAtIndex(indexPath.row)
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
        let data = messages[indexPath.row]
        switch(data.senderId) {
        case self.userId!:
            return self.outgoingBubble
        default:
            return self.incomingBubble
        }
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
         var avatar: JSQMessagesAvatarImage!
         if indexPath.row % 2 == 0 {
            avatar = JSQMessagesAvatarImage.avatarWithImage(UIImage(named: "demo_avatar_jobs"))
         } else {
            avatar = JSQMessagesAvatarImage.avatarWithImage(UIImage(named: "demo_avatar_cook"))
         }
         return avatar
    }
    
    //group time
    override func collectionView(collectionView: JSQMessagesCollectionView!, attributedTextForCellTopLabelAtIndexPath indexPath: NSIndexPath!) -> NSAttributedString! {
        if (indexPath.item % 3 == 0) {
            //let message = self.messages[indexPath.item]
            //return JSQMessagesTimestampFormatter.sharedFormatter().attributedTimestampForDate(message.date)
            
            let myString = "27/11/2012 10:05:00"
            let myAttribute = [ NSForegroundColorAttributeName: UIColor.lightGrayColor()]
            let myAttrString = NSAttributedString(string: myString, attributes: myAttribute)
            return myAttrString
        }
        return nil
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellTopLabelAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        return 30
    }
    
    //display name
    override func collectionView(collectionView: JSQMessagesCollectionView!, attributedTextForMessageBubbleTopLabelAtIndexPath indexPath: NSIndexPath!) -> NSAttributedString! {
        let data = messages[indexPath.row]
        let senderNameDisplay = data.senderDisplayName
        let myAttribute = [ NSForegroundColorAttributeName: UIColor.lightGrayColor()]
        let myAttrString = NSAttributedString(string: senderNameDisplay, attributes: myAttribute)
        return myAttrString
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        return 30
    }
}

//MARK - Toolbar
extension ChatViewController {
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
        let itemRef = messageRef.childByAutoId()
        let messageItem = [
            "senderName": senderId!,
            "text": text!,
            "time": ""
            ]
        itemRef.setValue(messageItem)
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        finishSendingMessage()
    }
    
    override func didPressAccessoryButton(sender: UIButton!) {
        
    }
}
