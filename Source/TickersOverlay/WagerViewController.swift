//
//  WagerViewController.swift
//  watch2earn-applesdk
//
//  Created by Asad Iqbal on 16/05/2023.
//

import UIKit

class WagerViewController: UIViewController {

    @IBOutlet weak var wagerPopupView: UIView!
    @IBOutlet weak var poll_question: UILabel!
    @IBOutlet weak var selected_ans: UILabel!
    @IBOutlet weak var wager_value: UITextField!
    @IBOutlet weak var wager_btn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    
    func configure(with poll: Poll) {
        print("Config ", poll)
        GamificationViewController.wagerPoll.append(poll)
        poll_question.text = poll.poll
        selected_ans.text = poll.choices[poll.selected!]
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
