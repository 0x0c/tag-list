//
//  TagsLayout.swift
//  TagsListExample
//
//  Created by Антон Текутов on 30.01.2020.
//  Copyright © 2020 Антон Текутов. All rights reserved.
//

import UIKit

public class TagsLayout: UICollectionViewFlowLayout {
    public enum Alignment: Int, CaseIterable {
        case justified
        case left
        case center
        case right
    }
    
    typealias AlignmentType = (lastRow: Int, lastMargin: CGFloat)
    
    public var alignment: Alignment = .left
    
    public init(alignment: Alignment = .left) {
        self.alignment = alignment
        super.init()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var delegate: UICollectionViewDelegateFlowLayout? {
        return self.collectionView?.delegate as? UICollectionViewDelegateFlowLayout
    }

    public override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let collectionView = collectionView else { return nil }
        guard let attributes = super.layoutAttributesForElements(in: rect) else { return nil }

        let shifFrame: ((UICollectionViewLayoutAttributes) -> Void) = { [unowned self] layoutAttribute in
            if layoutAttribute.frame.origin.x + layoutAttribute.frame.size.width > collectionView.bounds.size.width {
                layoutAttribute.frame.size.width = collectionView.bounds.size.width - self.sectionInset.left - self.sectionInset.right
            }
        }
        
        var leftMargin = sectionInset.left
        var maxY: CGFloat = -1.0
        var alignData: [AlignmentType] = []
        
        attributes.forEach { layoutAttribute in
            switch alignment {
            case .left, .center, .right:
                if layoutAttribute.frame.origin.y >= maxY {
                    alignData.append((lastRow: layoutAttribute.indexPath.row, lastMargin: leftMargin - minimumInteritemSpacing))
                    leftMargin = sectionInset.left
                }
                
                shifFrame(layoutAttribute)
                
                layoutAttribute.frame.origin.x = leftMargin
                
                leftMargin += layoutAttribute.frame.width + minimumInteritemSpacing
                
                maxY = max(layoutAttribute.frame.maxY , maxY)
            case .justified:
                shifFrame(layoutAttribute)
            }
        }
        
        calculateAlignment(attributes: attributes, alignmentTypes: alignData, leftMargin: leftMargin - minimumInteritemSpacing)

        return attributes
    }

    private func calculateAlignment(attributes: [UICollectionViewLayoutAttributes], alignmentTypes: [AlignmentType], leftMargin: CGFloat) {
            guard let collectionView = collectionView else { return }
            switch alignment {
            case .left, .justified:
                break
            case .center:
                attributes.forEach { layoutAttribute in
                    if let data = alignmentTypes.filter({ $0.lastRow > layoutAttribute.indexPath.row }).first {
                        layoutAttribute.frame.origin.x += ((collectionView.bounds.size.width - data.lastMargin - sectionInset.right) / 2)
                    } else {
                        layoutAttribute.frame.origin.x += ((collectionView.bounds.size.width - leftMargin - sectionInset.right) / 2)
                    }
                }
            case .right:
                attributes.forEach { layoutAttribute in
                    if let data = alignmentTypes.filter({ $0.lastRow > layoutAttribute.indexPath.row }).first {
                        layoutAttribute.frame.origin.x += (collectionView.bounds.size.width - data.lastMargin - sectionInset.right)
                    } else {
                        layoutAttribute.frame.origin.x += (collectionView.bounds.size.width - leftMargin - sectionInset.right)
                    }
                }
            }
        }
}
