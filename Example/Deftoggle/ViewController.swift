//
//  ViewController.swift
//  Deftoggle
//
//  Created by Ilya Alesker on 01/06/2017.
//  Copyright (c) 2017 Ilya Alesker. All rights reserved.
//

import UIKit
import SnapKit
import Deftoggle

class ViewController: UIViewController {

    open let toggle = Deftoggle()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.toggle.backgroundImage = #imageLiteral(resourceName: "toggle_bg")
        self.toggle.thumbOnImage = #imageLiteral(resourceName: "toggle_thumb_on")
        self.toggle.thumbOffImage = #imageLiteral(resourceName: "toggle_thumb_off")
        self.view.addSubview(self.toggle)
        self.toggle.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
}

