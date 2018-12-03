//
//  ViewForCarousel.swift
//  TestApp
//
//  Created by Shweta Adagale on 20/11/18.
//  Copyright © 2018 Shweta Adagale. All rights reserved.
//

import UIKit

class ViewForCarousel: UIView ,UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewFlowLayout: UICollectionViewFlowLayout!
    private var indexOfCellBeforeDragging = 0

    var arrayOfImage : [String] = []
    var isCircular : Bool!
    var sepration : CGFloat!
    var hasFooter : Bool!
    var widthOfCell : CGFloat!
    var frameOfView : CGRect!
    var visiblePart : CGFloat!
    
    static func instantiate(arrayOfImage : [String], isCircular : Bool, sepration : CGFloat, visiblePercentageOfPeekingCell visiblePart : CGFloat, hasFooter : Bool,frameOfView : CGRect, backGroundColor : UIColor) -> ViewForCarousel {
         let view: ViewForCarousel = initFromNib()
        view.arrayOfImage = arrayOfImage
        view.isCircular = isCircular
        view.sepration = sepration
        view.frameOfView = frameOfView
        view.widthOfCell =  (frameOfView.width - 2 * sepration) / (1 + CGFloat(2 * visiblePart))
        view.hasFooter = hasFooter
        view.visiblePart = visiblePart
        view.collectionView.register(UINib(nibName: "CarouselItemCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "cell")
        view.collectionView.register(UINib(nibName: "FooterView", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "footer")

        view.configureCollectionViewLayoutItemSize()
        //UI changes in view
        view.frame = frameOfView
        view.backgroundColor = backGroundColor
        //for circurlar carousel
        if isCircular {
        let indexPath = IndexPath(row: (arrayOfImage.count * 15), section: 0)
        view.collectionView!.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
        }
        view.collectionViewFlowLayout.minimumLineSpacing = 0
        return view
    }

    private func calculateSectionInset() -> CGFloat {
        var inset : CGFloat = 0.0
        if let width = collectionView?.frame.width {
//            inset = (width - widthOfCell) / 4
            inset = visiblePart + sepration
        }
        return inset
    }
    
    private func configureCollectionViewLayoutItemSize() {
        let inset: CGFloat = calculateSectionInset()
        if isCircular {
            collectionViewFlowLayout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        } else {
            collectionViewFlowLayout.sectionInset = UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset)

        }
        collectionView.reloadData()
        collectionView.layoutIfNeeded()
    }
    
    private func indexOfMajorCell() -> Int {
//        let itemWidth = collectionViewFlowLayout.itemSize.width
//        let proportionalOffset = collectionViewFlowLayout.collectionView!.contentOffset.x / itemWidth
        let proportionalOffset = collectionViewFlowLayout.collectionView!.contentOffset.x / widthOfCell
        let index = Int(round(proportionalOffset))
        let safeIndex = max(0, min((arrayOfImage.count * 30) - 1, index))
        return safeIndex
    }
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        indexOfCellBeforeDragging = indexOfMajorCell()
    }
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        // Stop scrollView sliding:
        targetContentOffset.pointee = scrollView.contentOffset
        
        // calculate where scrollView should snap to:
        let indexOfMajorCell = self.indexOfMajorCell()
        
        // calculate conditions:
        let swipeVelocityThreshold: CGFloat = 0.5 // after some trail and error
        let hasEnoughVelocityToSlideToTheNextCell = indexOfCellBeforeDragging + 1 < (arrayOfImage.count * 30) && velocity.x > swipeVelocityThreshold
        let hasEnoughVelocityToSlideToThePreviousCell = indexOfCellBeforeDragging - 1 >= 0 && velocity.x < -swipeVelocityThreshold
        let majorCellIsTheCellBeforeDragging = indexOfMajorCell == indexOfCellBeforeDragging
        let didUseSwipeToSkipCell = majorCellIsTheCellBeforeDragging && (hasEnoughVelocityToSlideToTheNextCell || hasEnoughVelocityToSlideToThePreviousCell)
        
        if didUseSwipeToSkipCell {
            
            let snapToIndex = indexOfCellBeforeDragging + (hasEnoughVelocityToSlideToTheNextCell ? 1 : -1)
            let indexPath = IndexPath(row: snapToIndex, section: 0)
            collectionViewFlowLayout.collectionView!.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        } else {
            // This is a much better way to scroll to a cell:
            let indexPath = IndexPath(row: indexOfMajorCell, section: 0)
            collectionViewFlowLayout.collectionView!.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        }
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if isCircular {
            return arrayOfImage.count * 30
        } else {
            return arrayOfImage.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CarouselItemCollectionViewCell
        var index = indexPath.row
        if isCircular {
           index = indexPath.row % arrayOfImage.count
        }
        cell.imageView.image = UIImage(named: arrayOfImage[index])
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let sizeOfCell = CGSize(width: widthOfCell, height: frameOfView.height)
        return sizeOfCell
    }
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
            
        case UICollectionView.elementKindSectionFooter:
            let footer = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "footer", for: indexPath) as! FooterView
            return footer
            
        default:
            
            assert(false, "Unexpected element kind")
        }
    }
}
extension UIView {
    class func initFromNib<T: UIView>() -> T {
        return Bundle.main.loadNibNamed(String(describing: self), owner: nil, options: nil)?[0] as! T
    }
}
