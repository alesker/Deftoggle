//
//  Deftoggle.swift
//  Pods
//
//  Created by Ilya Alesker on 05/01/2017.
//
//

import Foundation
import UIKit
import SnapKit

public class Deftoggle: UIControl {

    public var thumbOnImage: UIImage? {
        didSet {
            if self.isOn {
                self.thumbImageView.image = self.thumbOnImage
            }
            self.setOn(self.isOn, animated: false)
        }
    }

    public var thumbOffImage: UIImage? {
        didSet {
            if !self.isOn {
                self.thumbImageView.image = self.thumbOffImage
            }
            self.setOn(self.isOn, animated: false)
        }
    }

    public var backgroundImage: UIImage? {
        didSet {
            self.backgroundImageView.image = self.backgroundImage
            self.setOn(self.isOn, animated: false)
        }
    }

    public var thumbOffset: CGFloat = 0 {
        didSet {
            self.setOn(self.isOn, animated: false)
        }
    }

    public var isOn: Bool {
        get { return self.toggleValue }
        set { self.setOn(newValue, animated: false) }
    }

    public func setOn(_ isOn: Bool, animated: Bool) {
        self.toggleValue = isOn

        if self.isOn {
            self.showOn(animated: animated)
        } else {
            self.showOff(animated: animated)
        }
    }

    private var toggleValue: Bool = false

    private var backgroundImageView: UIImageView = UIImageView()
    private var thumbImageView: UIImageView = UIImageView()

    private var thumbImageViewHorizontalConstraint: Constraint?

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }

    private func setup() {
        self.addSubview(self.backgroundImageView)
        self.addSubview(self.thumbImageView)

        self.backgroundImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        self.thumbImageView.snp.remakeConstraints { (make) in
            make.centerY.equalToSuperview()
            self.thumbImageViewHorizontalConstraint = make.centerX.equalTo(self.snp.centerX).constraint
        }
        self.isOn = false
    }

    typealias ConstraintChange = (_ make: ConstraintMaker) -> Constraint?

    private func updateThumbImageViewConstraint(with constraintChange: ConstraintChange) {
        self.thumbImageViewHorizontalConstraint?.deactivate()
        self.layoutIfNeeded()
        self.thumbImageView.snp.makeConstraints { make in
            self.thumbImageViewHorizontalConstraint = constraintChange(make)
        }
        self.layoutIfNeeded()
    }

    private func showOn(animated: Bool) {
        if animated {
            self.animateThumbPositionChange {
                self.updateThumbImageViewConstraint(with: { make -> Constraint? in
                    return make.right.equalTo(self.snp.right).offset(self.thumbOffset).constraint
                })
            }
            self.animateThumbImageChange {
                self.thumbImageView.image = self.thumbOnImage
            }
        } else {
            self.updateThumbImageViewConstraint(with: { make -> Constraint? in
                return make.right.equalTo(self.snp.right).offset(self.thumbOffset).constraint
            })
            self.thumbImageView.image = self.thumbOnImage
        }
    }

    private func showOff(animated: Bool) {
        if animated {
            self.animateThumbPositionChange {
                self.updateThumbImageViewConstraint(with: { make -> Constraint? in
                    return make.left.equalTo(self.snp.left).offset(-self.thumbOffset).constraint
                })
            }
            self.animateThumbImageChange {
                self.thumbImageView.image = self.thumbOffImage
            }
        } else {
            self.updateThumbImageViewConstraint(with: { make -> Constraint? in
                return make.left.equalTo(self.snp.left).offset(-self.thumbOffset).constraint
            })
            self.thumbImageView.image = self.thumbOffImage
        }
    }

    private func animateThumbPositionChange(_ animation: @escaping () -> Swift.Void) {
        UIView.animate(withDuration: 0.2,
                       delay: 0.0,
                       options: .curveEaseInOut,
                       animations: animation,
                       completion: nil)
    }

    private func animateThumbImageChange(_ animation: @escaping () -> Swift.Void) {
        UIView.transition(with: self.thumbImageView,
                          duration: 0.1,
                          options: .transitionCrossDissolve,
                          animations: animation,
                          completion: nil)
    }

    override open func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        super.continueTracking(touch, with: event)

        let lastPoint = touch.location(in: self)
        if lastPoint.x > self.bounds.size.width / 2 {
            self.showOn(animated: true)
        } else {
            self.showOff(animated: true)
        }

        return true
    }

    override open func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        super.endTracking(touch, with: event)
        self.setOn(!self.isOn, animated: true)
        self.sendActions(for: UIControlEvents.valueChanged)
    }

    override open func cancelTracking(with event: UIEvent?) {
        super.cancelTracking(with: event)
        self.setOn(self.isOn, animated: true)
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        if !self.frame.size.equalTo(self.intrinsicContentSize) {
            self.invalidateIntrinsicContentSize()
        }
    }

    public override var intrinsicContentSize : CGSize {
        let maxThumbWidth = max(self.thumbOnImage?.size.width ?? 0, self.thumbOffImage?.size.width ?? 0)
        let maxThumbHeight = max(self.thumbOnImage?.size.height ?? 0, self.thumbOffImage?.size.height ?? 0)
        let maxWidth = max(self.backgroundImage?.size.width ?? 0 + self.thumbOffset * 2, maxThumbWidth)
        let maxHeight = max(self.backgroundImage?.size.height ?? 0, maxThumbHeight)
        return CGSize(width: maxWidth, height: maxHeight)
    }
}
