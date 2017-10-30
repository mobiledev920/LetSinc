//
//  EmptyDeleteTextField.swift
//  LetSinc
//
//  Created by Mateo Kozomara on 18/05/2017.
//  Copyright © 2017 Mateo Kozomara. All rights reserved.
//

import UIKit

protocol DeletePressedProtocol {
    
    func deletePressed(textField:UITextField)
}

class EmptyDeleteTextField: UITextField {

    var deleteDelegate:DeletePressedProtocol?
    
    override func deleteBackward() {
        
        deleteDelegate?.deletePressed(textField: self)
        super.deleteBackward()
        
    }
}
