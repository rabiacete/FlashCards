//
//  GradientView.swift
//  FlashCard
//
//  Created by Rabia Çete on 9.09.2025.
//

import UIKit

final class GradientView: UIView {
    override class var layerClass: AnyClass { CAGradientLayer.self }
    private var gLayer: CAGradientLayer { layer as! CAGradientLayer }

    init(colors: [UIColor] = [AppColors.gradientTop, AppColors.gradientBottom]) {
        super.init(frame: .zero)
        setColors(colors)
    }
    required init?(coder: NSCoder) { super.init(coder: coder); setColors([AppColors.gradientTop, AppColors.gradientBottom]) }

    func setColors(_ colors: [UIColor]) {
        gLayer.colors = colors.map { $0.cgColor }
        gLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        gLayer.endPoint   = CGPoint(x: 0.5, y: 1.0)
    }
}
