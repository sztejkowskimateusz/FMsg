//
//  Extensions.swift
//  qckMSG
//
//  Created by Mateusz on 15/04/2021.
//

import Foundation
import UIKit

extension UIView {
    public var width: CGFloat {
        return self.frame.size.width
    }
    
    public var height: CGFloat {
        return self.frame.size.height
    }
    
    public var top: CGFloat {
        return self.frame.origin.y
    }
    
    public var bottom: CGFloat {
        return self.frame.size.height + self.frame.origin.y
    }
    
    public var left: CGFloat {
        return self.frame.origin.x
    }
    
    public var right: CGFloat {
        return self.frame.origin.x + self.frame.size.width
    }
}

extension Notification.Name {
    static let zalogowanoPowiadomienie = Notification.Name("zalogowanoPowiadomienie")
}

extension UITextField {
    
    func setIcon(image: UIImage) {
        let iconView = UIImageView(frame: CGRect(x: 10, y: 5, width: 20, height: 20))
        iconView.image = image
        iconView.tintColor = .systemYellow
        
        let iconContainterView: UIView = UIView(frame: CGRect(x: 20,
                                                              y: 0,
                                                              width: 40,
                                                              height: 30))
        iconContainterView.addSubview(iconView)
        leftView = iconContainterView
        leftViewMode = .always
    }
}
