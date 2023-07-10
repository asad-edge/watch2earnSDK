//
//  GamificationViewController.swift
//  watch2earn-applesdk
//
//  Created by Asad Iqbal on 08/05/2023.
//

import UIKit
import AVFoundation

public class GamificationViewController: UIViewController {
    
    @IBOutlet weak var gamePollView: UIView!
    @IBOutlet weak var watch2earnView: UIView!
    
    let pollScrollView  = UIScrollView()
    let pollContentView = UIStackView()
    
    @IBOutlet weak var resolvePollView: UIView!
    let resolveScrollView  = UIScrollView()
    let resolveContentView = UIStackView()
    
    @IBOutlet weak var gameWin: UILabel!
    @IBOutlet weak var gameLose: UILabel!
    @IBOutlet weak var gameResult: UILabel!
    @IBOutlet weak var totalGaim: UILabel!
    @IBOutlet weak var totalPoints: UILabel!
    @IBOutlet weak var totalBalance: UILabel!
    @IBOutlet weak var tvIcon: UIImageView!

    var tickerTimer: Timer = Timer()
    
    var currentWagerIndex = 0 // Index of the current wager poll
    var wagerTimer: Timer? // Timer to trigger wager poll updates
    
    var currentPollIndex = 0 // Index of the current wager poll
    var pollTimer: Timer? // Timer to trigger wager poll updates
    
    var cacheStore = CacheStorage()
    var audioPlayer: AVAudioPlayer?
    var polls: [Poll] = []
    var selectedPolls: [Poll] = []
    static var wagerPoll: [Poll] = []
    let wagerViewController = WagerViewController(nibName: "WagerViewController", bundle: Bundle(for: WagerViewController.self))

    
    public override func viewDidLoad() {
        super.viewDidLoad()
        tvIcon.load(url: W2EManager.w2eSdk.tvLogo!)
        watch2earnView.roundCorners(corners: [.bottomLeft, .bottomRight], radius: 30.0)
//        let points = cacheStore.getDouble(_key: "WinPoints")
        EarnifySDK.animateFigure.updateBalance(newBalance: W2EManager.w2eSdk.getW2EDataStore().offchainBalance, animationTime: 20.0, pointsUI: totalPoints)
        DispatchQueue.main.async {
            self.tickerTimer.invalidate();
//            Thread(target: self, selector: #selector(self.showSocktsData), object: nil).start()
            self.tickerTimer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(self.updatingOverlay), userInfo: nil, repeats: true);

        }
        
        setupScrollView()
        setupContentView()
                
        // Set up the polls array with data
//        setupPolls()
        // Do any additional setup after loading the view.
//        populatePollViews()
        populateWagerPoll()
        
//        startWagerTimer()
        startPollTimer()

    }
    
    public override func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)
            
            // Invalidate the timer when the view is about to disappear
            stopWagerTimer()
            stopPollTimer()
        }
    
//    func startWagerTimer() {
//            // Invalidate the timer if it's already running
//            stopWagerTimer()
//        currentWagerIndex = GamificationViewController.wagerPoll.count - 1
//            // Populate the initial poll
//        if currentWagerIndex >= 0 {
//            populateCurrentWagerPoll()
//        }
//
//            // Start the timer to update polls every 10 seconds
//            wagerTimer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(updateWagerPoll), userInfo: nil, repeats: true)
//        }
    
    func startPollTimer() {
            // Invalidate the timer if it's already running
            pollContentView.arrangedSubviews.forEach { $0.removeFromSuperview() }
            stopPollTimer()
        currentPollIndex = GamificationSocket.newPolls.count - 1
            // Populate the initial poll
        if currentPollIndex >= 0 {
            DispatchQueue.main.async {
                self.populateCurrentPoll()
            }
        }
            // Start the timer to update polls every 20 seconds
            pollTimer = Timer.scheduledTimer(timeInterval: 20, target: self, selector: #selector(updatePoll), userInfo: nil, repeats: true)
        }
    func stopWagerTimer() {
        wagerTimer?.invalidate()
        wagerTimer = nil
        GamificationViewController.wagerPoll.removeAll()
        }
    func stopPollTimer() {
        pollTimer?.invalidate()
        pollTimer = nil
        }
    
//    @objc func updateWagerPoll() {
//            // Increment the current poll index
//        currentWagerIndex -= 1
//
//            // Check if the current poll index is within bounds
//        if currentWagerIndex >= 0 {
//            populateCurrentWagerPoll()
//            } else {
//                // Stop the timer if all polls have been displayed
//                currentWagerIndex = GamificationViewController.wagerPoll.count
//            }
//        }
    
    @objc func updatePoll() {
                    // Increment the current poll index
        currentPollIndex -= 1
            
            // Check if the current poll index is within bounds
        if currentPollIndex >= 0 {
            DispatchQueue.main.async {
                self.populateCurrentPoll()
            }
            
            } else {
                // Stop the timer if all polls have been displayed
                stopPollTimer()
            }
        }
    
//    func populateCurrentWagerPoll() {
//            // Get the poll at the current index from the array
//            let poll = GamificationViewController.wagerPoll[currentWagerIndex]
//
//            // Update the poll label with the current poll
//
//        if(poll.correct == nil){
//            gameResult.text = "AI Watching For Outcome..."
//            gameResult.textColor = .white
//        }
//        else if(poll.correct! > 0){
//            gameResult.text = "WIN"
//            gameResult.textColor = .systemGreen
//        }else{
//            let correct = poll.choices[(poll.correct?.first)! - 2]
//            print("Lose Correct answer is", correct)
//            gameResult.text = String(format: #"LOSE [%@]"#, correct)
//            gameResult.textColor = .systemRed
//            gameResult.adjustFontToFitWidth(withLineBreakMode: .byWordWrapping, numberOfLines: 2)
//        }
//
//
//        let pollCount = GamificationViewController.wagerPoll.count
//        print("Total polls: ", pollCount)
//
//        }
    
    func populateCurrentPoll() {
        
            pollContentView.arrangedSubviews.forEach { $0.removeFromSuperview() }
            // Get the poll at the current index from the array
            let poll = GamificationSocket.newPolls[currentPollIndex]
        let pollView = PollViewController()
            // Update the poll label with the current poll
        pollView.heightAnchor.constraint(equalToConstant: 565).isActive = true
        pollContentView.insertArrangedSubview(pollView, at: 0)
        //scrollView.contentSize = CGSize(width: scrollView.contentSize.width, height: scrollView.contentSize.height + 565)
        pollView.configure(with: poll)
        pollView.opt_1.addTarget(self, action: #selector(selectPollAnswer(_:)))
        pollView.opt_1.additionalParameter = poll
        pollView.opt_2.addTarget(self, action: #selector(selectPollAnswer(_:)))
        pollView.opt_2.additionalParameter = poll
        pollView.opt_3.addTarget(self, action: #selector(selectPollAnswer(_:)))
        pollView.opt_3.additionalParameter = poll
        pollView.opt_4.addTarget(self, action: #selector(selectPollAnswer(_:)))
        pollView.opt_4.additionalParameter = poll
        }
    
    private func setupScrollView() {

        //setup polls scroll view and manage its constraints
        
        pollScrollView.backgroundColor = .clear
        gamePollView.addSubview(pollScrollView)
        pollScrollView.translatesAutoresizingMaskIntoConstraints = false
        pollScrollView.leadingAnchor.constraint(equalTo: gamePollView.leadingAnchor).isActive = true
        pollScrollView.trailingAnchor.constraint(equalTo: gamePollView.trailingAnchor).isActive = true
        pollScrollView.topAnchor.constraint(equalTo: gamePollView.topAnchor).isActive = true
        pollScrollView.bottomAnchor.constraint(equalTo: gamePollView.bottomAnchor).isActive = true
        
        //setup resolve scroll view and manage its constraints
        
        resolveScrollView.backgroundColor = .clear
        resolvePollView.addSubview(resolveScrollView)
        resolveScrollView.translatesAutoresizingMaskIntoConstraints = false
        resolveScrollView.leadingAnchor.constraint(equalTo: resolvePollView.leadingAnchor).isActive = true
        resolveScrollView.trailingAnchor.constraint(equalTo: resolvePollView.trailingAnchor).isActive = true
        resolveScrollView.topAnchor.constraint(equalTo: resolvePollView.topAnchor).isActive = true
        resolveScrollView.bottomAnchor.constraint(equalTo: resolvePollView.bottomAnchor).isActive = true
        
        
        }

        private func setupContentView() {

            //setup polls stack view and manage its constraints
            
            pollContentView.axis            = .vertical
            pollContentView.distribution    = .fill
            pollContentView.alignment       = .fill
            pollScrollView.addSubview(pollContentView)
            pollContentView.translatesAutoresizingMaskIntoConstraints = false
            pollContentView.leadingAnchor.constraint(equalTo: gamePollView.leadingAnchor).isActive = true
            pollContentView.trailingAnchor.constraint(equalTo: gamePollView.trailingAnchor).isActive = true
            pollContentView.topAnchor.constraint(equalTo: pollScrollView.topAnchor).isActive = true
            pollContentView.bottomAnchor.constraint(equalTo: pollScrollView.bottomAnchor).isActive = true
            
            //setup resolve stack view and manage its constraints
            
            resolveContentView.axis            = .vertical
            resolveContentView.distribution    = .fill
            resolveContentView.alignment       = .fill
            resolveScrollView.addSubview(resolveContentView)
            resolveContentView.translatesAutoresizingMaskIntoConstraints = false
            resolveContentView.leadingAnchor.constraint(equalTo: resolvePollView.leadingAnchor).isActive = true
            resolveContentView.trailingAnchor.constraint(equalTo: resolvePollView.trailingAnchor).isActive = true
            resolveContentView.topAnchor.constraint(equalTo: resolveScrollView.topAnchor).isActive = true
            resolveContentView.bottomAnchor.constraint(equalTo: resolveScrollView.bottomAnchor).isActive = true
            

        }
    
    func playSound(sound: String){
        if let soundURL = Bundle.main.url(forResource: sound, withExtension: "mp3") {
                do {
                    print("attemp to Load sound")
                    audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
                } catch {
                    print("Failed to load the sound file: \(error)")
                }
        }else{
            print("mp3 sound not found")
        }
        
        audioPlayer?.play()

    }
    
    public override func viewDidLayoutSubviews() {
                   
//        scrollView.panGestureRecognizer.allowedTouchTypes = [NSNumber(value: UITouch.TouchType.indirect.rawValue)]
        W2EManager.w2eSdk.getGamifyMessage{ result in
            switch result {
            case .success(let message):
                print("Received message: \(message)")
                if message.contains("type") {
                    let parseObj: AnyObject? = message.jsonObjParse
                    if(parseObj?["type"] as! String == "poll" ){
                        DispatchQueue.main.async {
                            self.playSound(sound: "data-reveal")
                            self.startPollTimer()
                            W2EManager.w2eSdk.showGamifyTicketWhenPollRecieved()
                        }
                    }
                    if(parseObj?["type"] as! String == "winloss" ){
                        print("winloss Type Recived")
                        DispatchQueue.main.async {
                            self.resolvePoll((parseObj!["id"] as! String).toInt64()!, amount: parseObj!["amount"] as! Int, correct: parseObj!["correct"] as! [Int])
                            W2EManager.w2eSdk.showHideGamifyTicketWhenWinLoseRecieved()
                        }
                    }
                }
                
            case .failure(let error):
                print("Error receiving message: \(error)")
            }
        }

        }
    
//    func setupPolls() {
//            // Create and add poll instances to the array
//            let poll1 = Poll(type: "poll", poll: "What is your favorite color?", mode: 1, id: 1, explanation: "Choose your favorite color from the options.", created: 1683093551321, correct: [2], choices: ["Red", "Blue", "Green", "Yellow"])
//            polls.append(poll1)
//
//            let poll2 = Poll(type: "poll", poll: "What is your favorite animal?", mode: 1, id: 2, explanation: "Select your favorite animal.", created: 1683093551322, correct: [1], choices: ["Dog", "Cat", "Elephant", "Lion"])
//            polls.append(poll2)
//
//        let poll3 = Poll(type: "poll", poll: "What is your favorite animal?", mode: 1, id: 3, explanation: "Select your favorite animal.", created: 1683093551322, correct: [3], choices: ["Dog", "Cat", "Elephant", "Lion"])
//        polls.append(poll3)
//
//            // Add more polls as needed
//        }
    func populatePollViews() {
        pollContentView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        for poll in GamificationSocket.newPolls {
            let pollView = PollViewController()
            pollView.heightAnchor.constraint(equalToConstant: 565).isActive = true
            pollContentView.addArrangedSubview(pollView)
            //scrollView.contentSize = CGSize(width: scrollView.contentSize.width, height: scrollView.contentSize.height + 565)
            pollView.configure(with: poll)
            pollView.opt_1.addTarget(self, action: #selector(selectPollAnswer(_:)))
            pollView.opt_1.additionalParameter = poll
            pollView.opt_2.addTarget(self, action: #selector(selectPollAnswer(_:)))
            pollView.opt_2.additionalParameter = poll
            pollView.opt_3.addTarget(self, action: #selector(selectPollAnswer(_:)))
            pollView.opt_3.additionalParameter = poll
            pollView.opt_4.addTarget(self, action: #selector(selectPollAnswer(_:)))
            pollView.opt_4.additionalParameter = poll

                    }
        pollContentView.layoutIfNeeded()
        
        }
    
    private func populateWagerPoll(){
            resolveContentView.arrangedSubviews.forEach { $0.removeFromSuperview() }

            for poll in GamificationViewController.wagerPoll {
                let resolveView = ResolveViewController()
                resolveView.heightAnchor.constraint(equalToConstant: 522).isActive = true
                resolveContentView.addArrangedSubview(resolveView)

                resolveView.configure(with: poll)
            }
            
            resolveContentView.layoutIfNeeded()
        }
    
   
    @objc func selectPollAnswer(_ sender: UILabel) {
        //wagerPopupView.isHidden = false
        if var poll = sender.additionalParameter {
            GamificationSocket.newPolls.removeAll(where: {$0.id == poll.id && $0.mode == poll.mode})
            
            poll.selected = sender.tag
            
            if(poll.mode == 1){
                wagerViewController.modalPresentationStyle = .overCurrentContext
                wagerViewController.accessibilityViewIsModal = true
                wagerViewController.didMove(toParent: self);
                self.present(wagerViewController, animated: true)
                wagerViewController.configure(with: poll)
                wagerViewController.wager_btn.titleLabel?.additionalParameter = poll
                wagerViewController.wager_btn.addTarget(self, action: #selector(wagerPoints(_:)), for: .primaryActionTriggered)
            }else{
                GamificationViewController.wagerPoll.append(poll)
                W2EManager.w2eSdk.gamifySocketAnswerMessage(pollID: poll.id, selectedAns: poll.selected!, wagerValue: 0)
                startPollTimer()
                DispatchQueue.main.async {
                    self.populateWagerPoll()
                }
            }
        }
    }
    
    private func resolvePoll(_ id: Int64, amount: Int, correct: [Int]){
        let wagered = GamificationViewController.wagerPoll;
        var selectedPoll: Poll?
        if(wagered.isEmpty){
            return
        }else {
        selectedPoll = wagered.first(where: {$0.id == id})
            if(selectedPoll == nil) {
                return
            }
        }
        GamificationViewController.wagerPoll.removeAll(where: {$0.id == id})
        selectedPoll?.correct = [correct.first!,amount]
        GamificationViewController.wagerPoll.append(selectedPoll!)
        DispatchQueue.main.async {
            self.showResultAction(selectedPoll!)
            //self.updateNewPoints(-10.0)
//            self.startWagerTimer()
            self.populateWagerPoll()
        }
    }
    var numberOfWins = 0
    var numberOflose = 0
    private func showResultAction(_ poll: Poll){
        
        if(poll.correct!.last! > 0) {
            DispatchQueue.main.async {
                
                self.playSound(sound: "success")
                self.updateNewPoints(Double(poll.correct!.last!))
                self.numberOfWins += 1
                self.totalPoints.textColor = .systemYellow
            }
            
        }else{
            DispatchQueue.main.async {
                self.playSound(sound: "loose_sound")
                self.numberOflose += 1
                self.updateNewPoints(Double(poll.correct!.last!))
                self.totalPoints.textColor = .systemRed
            }
            //self.resultLabel.adjustFontToFitWidth(withLineBreakMode: .byWordWrapping, numberOfLines: 3)
            //W2EManager.overlay.points.textColor = .systemRed
        }
        Timer.scheduledTimer(withTimeInterval: 10.0, repeats: false){ [self]_ in
            GamificationViewController.wagerPoll.removeAll(where: {$0.id == poll.id && $0.mode == poll.mode})
            DispatchQueue.main.async {
//                self.startWagerTimer()
                self.populateWagerPoll()
            }
        }
    }
    
    private func updateNewPoints(_ newPoin: Double){
//        let points = cacheStore.getDouble(_key: "WinPoints")
//        let bal = points + newPoin;
//        cacheStore.saveDouble(_key: "WinPoints", _value: bal)
        let newPoints = W2EManager.w2eSdk.getW2EDataStore().offchainBalance + newPoin
        if newPoints > 0 {
            EarnifySDK.animateFigure.updateBalance(newBalance: newPoints, animationTime: 5, pointsUI: totalPoints )
        }
    }

    @objc func wagerPoints(_ sender: UIButton) {
        print("Wager Button Pressed" )
        let wagerValue = wagerViewController.wager_value.text?.toInt64()
        if let poll = sender.titleLabel?.additionalParameter {
            print("Wagered poll: ", poll)
            W2EManager.w2eSdk.gamifySocketAnswerMessage(pollID: poll.id, selectedAns: poll.selected!, wagerValue: Int(wagerValue!))
            startPollTimer()
            DispatchQueue.main.async {
                self.populateWagerPoll()
                self.dismiss(animated: true)
            }
        }
    }
    
    @objc func updatingOverlay() {
        
               let stakingData = W2EManager.w2eSdk.getStakingData();
               let ticker = W2EManager.w2eSdk.getAllTickers();
               
        let eatBalance = stakingData.balance
        var usdBalance = "0.00"
    
    if ticker.price > 0.0 {
        usdBalance = "$"+(eatBalance*ticker.price).delimiter
         }
    totalBalance.text = usdBalance
//        W2EManager.overlay.points.text = points.delimiter
    totalGaim.text = eatBalance.delimiter
        gameWin.text = String(numberOfWins)
        gameLose.text = String(numberOflose)
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
private var AssociatedObjectHandle: UInt8 = 0
extension UILabel {
    var additionalParameter: Poll? {
        get {
            return objc_getAssociatedObject(self, &AssociatedObjectHandle) as? Poll
        }
        set {
            objc_setAssociatedObject(self, &AssociatedObjectHandle, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}
extension UILabel {
    private struct AssociatedKeys {
        static var interactiveLabelFocusGuide = "interactiveLabelFocusGuide"
        static var labelTarget = "labelTarget"
        static var labelAction = "labelAction"
        static var borderAction = "borderCorner"
    }
    private var focusGuide: UIFocusGuide? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.interactiveLabelFocusGuide) as? UIFocusGuide
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.interactiveLabelFocusGuide, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
     var borderCorners: UIRectCorner? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.borderAction) as? UIRectCorner
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.borderAction, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    
    var isInteractiveLabel: Bool {
        get {
            return focusGuide != nil
        }
        set {
            if newValue {
                enableInteractiveLabel()
            } else {
                disableInteractiveLabel()
            }
        }
    }
    
    private func enableInteractiveLabel() {
        if focusGuide == nil {
            let focusGuide = UIFocusGuide()
            addLayoutGuide(focusGuide)
            
            focusGuide.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
            focusGuide.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
            focusGuide.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
            focusGuide.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            
            self.focusGuide = focusGuide
        }
        
        isUserInteractionEnabled = true
        focusGuide?.isEnabled = true
    }
    
    private func disableInteractiveLabel() {
        isUserInteractionEnabled = false
        focusGuide?.isEnabled = false
    }
    
    open override var canBecomeFocused: Bool {
        return isInteractiveLabel
    }
    
    open override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        updateAppearance(isFocused: context.nextFocusedView == self)
    }
    
    private func updateAppearance(isFocused: Bool) {
        self.roundCorner(corners: borderCorners ?? .bottomRight, radius: 30, borderWidth: 4.0, borderColor: UIColor.white, isFocused: isFocused)
    }

        private var labelTarget: AnyObject? {
            get {
                return objc_getAssociatedObject(self, &AssociatedKeys.labelTarget) as AnyObject?
            }
            set {
                objc_setAssociatedObject(self, &AssociatedKeys.labelTarget, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
        
        private var labelAction: Selector? {
            get {
                let actionString = objc_getAssociatedObject(self, &AssociatedKeys.labelAction) as? String
                return actionString != nil ? NSSelectorFromString(actionString!) : nil
            }
            set {
                let actionString = newValue != nil ? NSStringFromSelector(newValue!) : nil
                objc_setAssociatedObject(self, &AssociatedKeys.labelAction, actionString, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
        
        func addTarget(_ target: AnyObject, action: Selector) {
            labelTarget = target
            labelAction = action
            isUserInteractionEnabled = true
            addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(labelTapped(_:))))
        }
        
        @objc private func labelTapped(_ recognizer: UITapGestureRecognizer) {
            if let target = labelTarget, let action = labelAction {
                target.performSelector(onMainThread: action, with: self, waitUntilDone: true)
            }
        }
    
}

