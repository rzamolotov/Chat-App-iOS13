//
//  WelcomeViewController.swift
//  Flash Chat iOS13
//
//  Created by Angela Yu on 21/10/2019.
//  Copyright © 2019 Angela Yu. All rights reserved.
//

import UIKit

class WelcomeViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.text = ""
        var charIndex = 0.0//переменная созданная для того чтобы можно было создать очередность запуска таймера
        let titleText = "ChatApp"
        for letter in titleText {
            Timer.scheduledTimer(withTimeInterval: 0.1 * charIndex, repeats: false) { (timer) in
                self.titleLabel.text?.append(letter)
            } // запускаем таймер с добавление по одной букве в цикле for in
            charIndex += 1
        } // добавляем переменную + 1, для запуска анимации
       
    }
    

}