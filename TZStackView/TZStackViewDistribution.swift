//
//  TZStackViewDistribution.swift
//  TZStackView
//
//  Created by Tom van Zummeren on 10/06/15.
//  Copyright © 2015 Tom van Zummeren. All rights reserved.
//
import Foundation

/* Distribution—the layout along the stacking axis.

All UIStackViewDistribution enum values fit first and last arranged subviews tightly to the container,
and except for UIStackViewDistributionFillEqually, fit all items to intrinsicContentSize when possible.
*/
@objc public enum TZStackViewDistribution : Int {
    
    /* When items do not fit (overflow) or fill (underflow) the space available
    adjustments occur according to compressionResistance or hugging
    priorities of items, or when that is ambiguous, according to arrangement
    order.
    */
    case Fill = 0
    
    /* Items are all the same size.
    When space allows, this will be the size of the item with the largest
    intrinsicContentSize (along the axis of the stack).
    Overflow or underflow adjustments are distributed equally among the items.
    */
    case FillEqually = 1
    
    /* Overflow or underflow adjustments are distributed among the items proportional
    to their intrinsicContentSizes.
    */
    case FillProportionally = 2
    
    /* Additional underflow spacing is divided equally in the spaces between the items.
    Overflow squeezing is controlled by compressionResistance priorities followed by
    arrangement order.
    */
    case EqualSpacing = 3
    
    /* Equal center-to-center spacing of the items is maintained as much
    as possible while still maintaining a minimum edge-to-edge spacing within the
    allowed area.
    Additional underflow spacing is divided equally in the spacing. Overflow
    squeezing is distributed first according to compressionResistance priorities
    of items, then according to subview order while maintaining the configured
    (edge-to-edge) spacing as a minimum.
    */
    case EqualCentering = 4
}
