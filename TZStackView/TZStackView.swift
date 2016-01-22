//
//  TZStackView.swift
//  TZStackView
//
//  Created by Tom van Zummeren on 10/06/15.
//  Copyright © 2015 Tom van Zummeren. All rights reserved.
//

import UIKit

struct TZAnimationDidStopQueueEntry: Equatable {
    let view: UIView
    let hidden: Bool
}

func ==(lhs: TZAnimationDidStopQueueEntry, rhs: TZAnimationDidStopQueueEntry) -> Bool {
    return lhs.view === rhs.view
}

@IBDesignable
public class TZStackView: UIView {

    public var distribution: TZStackViewDistribution = .Fill {
        didSet {
            setNeedsUpdateConstraints()
        }
    }

    public var axis: UILayoutConstraintAxis = .Horizontal {
        didSet {
            setNeedsUpdateConstraints()
        }
    }
    
    public var alignment: TZStackViewAlignment = .Fill {
        didSet {
            setNeedsUpdateConstraints()
        }
    }
    
    @objc @IBInspectable private var axisValue: Int {
        get {
            return axis.rawValue
        }
        set {
            axis = UILayoutConstraintAxis(rawValue: newValue) ?? .Horizontal
        }
    }
    
    @objc @IBInspectable private var alignmentValue: Int {
        get {
            return alignment.rawValue
        }
        set {
            alignment = TZStackViewAlignment(rawValue: newValue) ?? .Fill
        }
    }
    
    @objc @IBInspectable private var distributionValue: Int {
        get {
            return distribution.rawValue
        }
        set {
            distribution = TZStackViewDistribution(rawValue: newValue) ?? .Fill
        }
    }

    @objc @IBInspectable public var spacing: CGFloat = 0 {
        didSet {
            setNeedsUpdateConstraints()
        }
    }
    
    @objc @IBInspectable public var layoutMarginsRelativeArrangement: Bool = false {
        didSet {
            setNeedsUpdateConstraints()
        }
    }
    
    override public var layoutMargins: UIEdgeInsets {
        get {
            if #available(iOS 8, *) {
                return super.layoutMargins
            } else {
                return _layoutMargins
            }
        }
        set {
            if #available(iOS 8, *) {
                super.layoutMargins = newValue
            } else {
                _layoutMargins = newValue
                setNeedsUpdateConstraints()
            }
        }
    }
    
    private  var  _layoutMargins = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)

    public private(set) var arrangedSubviews: [UIView] = [] {
        didSet {
            setNeedsUpdateConstraints()
            registerHiddenListeners(oldValue)
        }
    }

    private var kvoContext = UInt8()

    private var stackViewConstraints = [NSLayoutConstraint]()
    private var subviewConstraints = [NSLayoutConstraint]()
    
    private var layoutMarginsView: TZSpacerView?
    private var alignmentSpanner: TZSpacerView?
    private var orderingSpanner: TZSpacerView?
    private var distributionSpacers: [TZSpacerView] = []
    
    private var animationDidStopQueueEntries = [TZAnimationDidStopQueueEntry]()
    
    private var registeredKvoSubviews = [UIView]()
    
    private var animatingToHiddenViews = [UIView]()

    public convenience init() {
        self.init(arrangedSubviews: [])
    }
    
    public init(arrangedSubviews: [UIView]) {
        super.init(frame: CGRectZero)
        commonInit(arrangedSubviews)
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        commonInit([])
    }

    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        commonInit([])
    }
    
    private func commonInit(arrangedSubviews: [UIView]) {
        for arrangedSubview in arrangedSubviews {
            arrangedSubview.translatesAutoresizingMaskIntoConstraints = false
            addSubview(arrangedSubview)
        }

        // Closure to invoke didSet()
        { self.arrangedSubviews = arrangedSubviews }()
    }
    
    deinit {
        // This removes `hidden` value KVO observers using didSet()
        { self.arrangedSubviews = [] }()
    }

    override public func awakeFromNib() {
        super.awakeFromNib()
        
        // a hack, remove Interface Builder generated constraints that are not created by you
        for aConstraint in constraints where NSStringFromClass(aConstraint.dynamicType) == "NSIBPrototypingLayoutConstraint" {
            removeConstraint(aConstraint)
        }
        
        for aView in subviews {
            addArrangedSubview(aView)
        }
    }
    
    override public func prepareForInterfaceBuilder() {
        if #available(iOS 8.0, *) {
            super.prepareForInterfaceBuilder()
                        
            for aView in subviews {
                addArrangedSubview(aView)
            }
        }
    }

    private func registerHiddenListeners(previousArrangedSubviews: [UIView]) {
        for subview in previousArrangedSubviews {
            self.removeHiddenListener(subview)
        }

        for subview in arrangedSubviews {
            self.addHiddenListener(subview)
        }
    }
    
    private func addHiddenListener(view: UIView) {
        view.addObserver(self, forKeyPath: "hidden", options: [.Old, .New], context: &kvoContext)
        registeredKvoSubviews.append(view)
    }
    
    private func removeHiddenListener(view: UIView) {
        if let index = registeredKvoSubviews.indexOf(view) {
            view.removeObserver(self, forKeyPath: "hidden", context: &kvoContext)
            registeredKvoSubviews.removeAtIndex(index)
        }
    }

    public override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if let view = object as? UIView, change = change where keyPath == "hidden" {
            let hidden = view.hidden
            let previousValue = change["old"] as! Bool
            if hidden == previousValue {
                return
            }
            if hidden {
                animatingToHiddenViews.append(view)
            }
            // Perform the animation
            setNeedsUpdateConstraints()
            setNeedsLayout()
            layoutIfNeeded()
            
            removeHiddenListener(view)
            view.hidden = false

            if let _ = view.layer.animationKeys() {
                UIView.setAnimationDelegate(self)
                animationDidStopQueueEntries.insert(TZAnimationDidStopQueueEntry(view: view, hidden: hidden), atIndex: 0)
                UIView.setAnimationDidStopSelector("hiddenAnimationStopped")
            } else {
                didFinishSettingHiddenValue(view, hidden: hidden)
            }
        }
    }
    
    private func didFinishSettingHiddenValue(arrangedSubview: UIView, hidden: Bool) {
        arrangedSubview.hidden = hidden
        if let index = animatingToHiddenViews.indexOf(arrangedSubview) {
            animatingToHiddenViews.removeAtIndex(index)
        }
        addHiddenListener(arrangedSubview)
    }

    func hiddenAnimationStopped() {
        var queueEntriesToRemove = [TZAnimationDidStopQueueEntry]()
        for entry in animationDidStopQueueEntries {
            let view = entry.view
            if view.layer.animationKeys() == nil {
                didFinishSettingHiddenValue(view, hidden: entry.hidden)
                queueEntriesToRemove.append(entry)
            }
        }
        for entry in queueEntriesToRemove {
            if let index = animationDidStopQueueEntries.indexOf(entry) {
                animationDidStopQueueEntries.removeAtIndex(index)
            }
        }
    }
    
    public func addArrangedSubview(view: UIView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        arrangedSubviews.append(view)
    }
    
    public func removeArrangedSubview(view: UIView) {
        if let index = arrangedSubviews.indexOf(view) {
            arrangedSubviews.removeAtIndex(index)
        }
    }

    public func insertArrangedSubview(view: UIView, atIndex stackIndex: Int) {
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        arrangedSubviews.insert(view, atIndex: stackIndex)
    }

    override public func willRemoveSubview(subview: UIView) {
        removeArrangedSubview(subview)
    }

    override public func updateConstraints() {
        removeConstraints(stackViewConstraints)
        stackViewConstraints.removeAll()

        for arrangedSubview in arrangedSubviews {
            arrangedSubview.removeConstraints(subviewConstraints)
        }
        subviewConstraints.removeAll()
        
        if let spacerView = layoutMarginsView {
            spacerView.removeFromSuperview()
            layoutMarginsView = nil
        }
        
        if let spacerView = alignmentSpanner {
            spacerView.removeFromSuperview()
            alignmentSpanner = nil
        }
        
        if let spacerView = orderingSpanner {
            spacerView.removeFromSuperview()
            orderingSpanner = nil
        }
        
        for spacerView in distributionSpacers {
            spacerView.removeFromSuperview()
        }
        distributionSpacers.removeAll()
        
        for arrangedSubview in arrangedSubviews {
            
            if alignment != .Fill {
                let guideConstraint: NSLayoutConstraint
                switch axis {
                case .Horizontal:
                    guideConstraint = constraint(item: arrangedSubview, attribute: .Height, toItem: nil, attribute: .NotAnAttribute, constant: 0, priority: 25)
                case .Vertical:
                    guideConstraint = constraint(item: arrangedSubview, attribute: .Width, toItem: nil, attribute: .NotAnAttribute, constant: 0, priority: 25)
                }
                guideConstraint.identifier = "TZSV-ambiguity-suppression"
                subviewConstraints.append(guideConstraint)
                arrangedSubview.addConstraint(guideConstraint)
            }
            
            if isHidden(arrangedSubview) {
                let hiddenConstraint: NSLayoutConstraint
                switch axis {
                case .Horizontal:
                    hiddenConstraint = constraint(item: arrangedSubview, attribute: .Width, toItem: nil, attribute: .NotAnAttribute, constant: 0)
                case .Vertical:
                    hiddenConstraint = constraint(item: arrangedSubview, attribute: .Height, toItem: nil, attribute: .NotAnAttribute, constant: 0)
                }
                hiddenConstraint.identifier = "TZSV-hiding"
                subviewConstraints.append(hiddenConstraint)
                arrangedSubview.addConstraint(hiddenConstraint)
            }
        }
        
        if arrangedSubviews.count > 0 {
            if layoutMarginsRelativeArrangement {
                layoutMarginsView = addSpacerView("TZViewLayoutMarginsGuide")
            }
            
            if alignment != .Fill || areAllViewsHidden() {
                alignmentSpanner = addSpacerView("TZSV-alignment-spanner")
            }

            if areAllViewsHidden() {
                orderingSpanner = addSpacerView("TZSV-ordering-spanner")
            }
            
            stackViewConstraints += createMatchEdgesContraints(arrangedSubviews)
            stackViewConstraints += createFirstAndLastViewMatchEdgesContraints()
            stackViewConstraints += createCanvasFitConstraints()
            
            let visibleArrangedSubviews = arrangedSubviews.filter({!self.isHidden($0)})
            
            switch distribution {
            case .FillEqually, .Fill, .FillProportionally:
                if distribution == .FillEqually {
                    stackViewConstraints += createFillEquallyConstraints(arrangedSubviews, identifier: "TZSV-fill-equally")
                }
                if distribution == .FillProportionally {
                    let (someStackViewConstraints, someSubviewConstraints) = createFillProportionallyConstraints(arrangedSubviews)
                    
                    stackViewConstraints += someStackViewConstraints
                    for (owningView, constraints) in someSubviewConstraints {
                        owningView.addConstraints(constraints)
                        subviewConstraints += constraints
                    }
                }
                
                stackViewConstraints += createFillConstraints(arrangedSubviews, constant: spacing, identifier: "TZSV-spacing")
            case .EqualSpacing:
                var views = [UIView]()
                var index = 0
                for arrangedSubview in arrangedSubviews {
                    if isHidden(arrangedSubview) {
                        continue
                    }
                    if index > 0 {
                        let spacerView = addSpacerView("TZSV-distributing")
                        distributionSpacers.append(spacerView)
                        views.append(spacerView)
                    }
                    views.append(arrangedSubview)
                    index++
                }

                stackViewConstraints += createFillConstraints(views, constant: 0, identifier: "TZSV-distributing-edge")
                stackViewConstraints += createFillEquallyConstraints(distributionSpacers, identifier: "TZSV-fill-equally")
                stackViewConstraints += createFillConstraints(arrangedSubviews, relatedBy: .GreaterThanOrEqual, constant: spacing, identifier: "TZSV-spacing")
            case .EqualCentering:
                for (index, _) in visibleArrangedSubviews.enumerate() {
                    if index > 0 {
                        distributionSpacers.append(addSpacerView("TZSV-distributing"))
                    }
                }

                stackViewConstraints += createEqualCenteringConstraints(arrangedSubviews)
            }
            
            if let spanner = alignmentSpanner {
                stackViewConstraints += createSurroundingSpacerViewConstraints(spanner, views: visibleArrangedSubviews)
            }

            if let layoutMarginsView = layoutMarginsView {
                let bottomConstraint: NSLayoutConstraint
                let leftConstraint: NSLayoutConstraint
                let rightConstraint: NSLayoutConstraint
                let topConstraint: NSLayoutConstraint
                if #available(iOS 8.0, *) {
                    bottomConstraint = constraint(item: self, attribute: .BottomMargin, toItem: layoutMarginsView, attribute: .Bottom)
                    leftConstraint = constraint(item: self, attribute: .LeftMargin, toItem: layoutMarginsView, attribute: .Left)
                    rightConstraint = constraint(item: self, attribute: .RightMargin, toItem: layoutMarginsView, attribute: .Right)
                    topConstraint = constraint(item: self, attribute: .TopMargin, toItem: layoutMarginsView, attribute: .Top)
                } else {
                    bottomConstraint = constraint(item: self, attribute: .Bottom, toItem: layoutMarginsView, attribute: .Bottom, constant: _layoutMargins.bottom)
                    leftConstraint = constraint(item: self, attribute: .Left, toItem: layoutMarginsView, attribute: .Left, constant: -_layoutMargins.left)
                    rightConstraint = constraint(item: self, attribute: .Right, toItem: layoutMarginsView, attribute: .Right, constant: _layoutMargins.right)
                    topConstraint = constraint(item: self, attribute: .Top, toItem: layoutMarginsView, attribute: .Top, constant: -_layoutMargins.top)
                }
            
                bottomConstraint.identifier = "TZView-bottomMargin-guide-constraint"
                leftConstraint.identifier = "TZView-leftMargin-guide-constraint"
                rightConstraint.identifier = "TZView-rightMargin-guide-constraint"
                topConstraint.identifier = "TZView-topMargin-guide-constraint"
                stackViewConstraints += [bottomConstraint, leftConstraint, rightConstraint, topConstraint]
            }
            
            if axis == .Horizontal {
                switch distribution {
                case .Fill, .EqualSpacing, .EqualCentering:
                    let totalVisible = visibleArrangedSubviews.count
                    let multilineLabels = arrangedSubviews.filter { view in
                        isMultilineLabel(view)
                    }
                    
                    if  totalVisible > 0 {
                        let totalSpacing = spacing * CGFloat(totalVisible - 1)
                        
                        let ratio = CGFloat(1) / CGFloat(totalVisible)
                        let decrease = totalSpacing / CGFloat(totalVisible)
                        
                        let edgeItem = layoutMarginsView ?? self
                        
                        for label in multilineLabels {
                            stackViewConstraints.append(constraint(item: label, attribute: .Width, relatedBy: .Equal, toItem: edgeItem, attribute: .Width, multiplier: ratio, constant: -decrease, priority: 760, identifier: "TZSV-text-width-disambiguation"))
                        }
                    } else {
                        for label in multilineLabels {
                            let aConstraint = constraint(item: label, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, constant: 0, priority: 760, identifier: "TZSV-text-width-disambiguation")
                            subviewConstraints.append(aConstraint)
                            label.addConstraint(aConstraint)
                        }
                    }
                case .FillEqually, .FillProportionally:
                    break
                }
            }
            
            addConstraints(stackViewConstraints)
        }

        super.updateConstraints()
    }

    private func addSpacerView(identifier: String = "") -> TZSpacerView {
        let spacerView = TZSpacerView()
        spacerView.translatesAutoresizingMaskIntoConstraints = false
        spacerView.identifier = identifier
        
        insertSubview(spacerView, atIndex: 0)
        return spacerView
    }
    
    private func createCanvasFitConstraints() -> [NSLayoutConstraint] {
        func widthFitConstraint() -> NSLayoutConstraint {
            return constraint(item: self, attribute: .Width, toItem: nil, attribute: .NotAnAttribute, priority: 49, identifier: "TZSV-canvas-fit")
        }
        
        func heightFitConstraint() -> NSLayoutConstraint {
            return constraint(item: self, attribute: .Height, toItem: nil, attribute: .NotAnAttribute, priority: 49, identifier: "TZSV-canvas-fit")
        }
        
        var result = [NSLayoutConstraint]()
        
        let baselineAlignment = (alignment == .FirstBaseline || alignment == .LastBaseline) && axis == .Horizontal

        if baselineAlignment && !areAllViewsHidden() {
            result.append(heightFitConstraint())
        }
        
        switch distribution {
        case .FillEqually, .Fill, .FillProportionally:
            break
        case .EqualSpacing, .EqualCentering:
            switch axis {
            case .Horizontal:
                result.append(widthFitConstraint())
            case .Vertical:
                result.append(heightFitConstraint())
            }
        }
        return result
    }
    
    private func createSurroundingSpacerViewConstraints(spacerView: UIView, views: [UIView]) -> [NSLayoutConstraint] {
        if alignment == .Fill {
            return []
        }
        
        var topPriority: UILayoutPriority = 1000
        var topRelation: NSLayoutRelation = .LessThanOrEqual
        
        var bottomPriority: UILayoutPriority = 1000
        var bottomRelation: NSLayoutRelation = .GreaterThanOrEqual
        
        if alignment == .Top || alignment == .Leading {
            topPriority = 999.5
            topRelation = .Equal
        }
        
        if alignment == .Bottom || alignment == .Trailing {
            bottomPriority = 999.5
            bottomRelation = .Equal
        }
        
        var constraints = [NSLayoutConstraint]()
        for view in views {
            switch axis {
            case .Horizontal:
                constraints.append(constraint(item: spacerView, attribute: .Top, relatedBy: topRelation, toItem: view, priority: topPriority, identifier: "TZSV-spanning-boundary"))
                constraints.append(constraint(item: spacerView, attribute: .Bottom, relatedBy: bottomRelation, toItem: view, priority: bottomPriority, identifier: "TZSV-spanning-boundary"))
            case .Vertical:
                constraints.append(constraint(item: spacerView, attribute: .Leading, relatedBy: topRelation, toItem: view, priority: topPriority, identifier: "TZSV-spanning-boundary"))
                constraints.append(constraint(item: spacerView, attribute: .Trailing, relatedBy: bottomRelation, toItem: view, priority: bottomPriority, identifier: "TZSV-spanning-boundary"))
            }
        }
        
        switch axis {
        case .Horizontal:
            constraints.append(constraint(item: spacerView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, constant: 0, priority: 51, identifier: "TZSV-spanning-fit"))
        case .Vertical:
            constraints.append(constraint(item: spacerView, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, constant: 0, priority: 51, identifier: "TZSV-spanning-fit"))
        }

        return constraints
    }
    
    private func createFillProportionallyConstraints(views: [UIView]) -> (stackViewConstraints: [NSLayoutConstraint], subviewConstraints: [(owningView: UIView, [NSLayoutConstraint])]) {
        func intrinsicContentLengthOf(view: UIView) -> CGFloat {
            let size = view.intrinsicContentSize()
            switch axis {
            case .Horizontal:
                if let label = view as? UILabel where label.numberOfLines != 1 { // multiline label
                    return 0
                } else {
                    return size.width != UIViewNoIntrinsicMetric ? size.width : 0
                }
            case .Vertical:
                return size.height != UIViewNoIntrinsicMetric ? size.height : 0
            }
        }
        
        let nonHiddenViews = views.filter { view in
            return !isHidden(view)
        }
        
        if nonHiddenViews.count == 0 {
            return ([], [])
        }
        
        let numberOfHiddenViews = views.count - nonHiddenViews.count
        
        let totalViewLength = nonHiddenViews
            .map { view in
                intrinsicContentLengthOf(view)
            }
            .reduce(CGFloat(0), combine: +)
        
        let showingTotalIsSmall: Bool
        if  numberOfHiddenViews == 0 {
            switch nonHiddenViews.count {
            case 0: // not possible
                showingTotalIsSmall = false
            case 1:
                let view = nonHiddenViews[0]
                showingTotalIsSmall = intrinsicContentLengthOf(view) <= 1
            default:
                showingTotalIsSmall = totalViewLength == 0
            }
        } else {
            showingTotalIsSmall = totalViewLength <= spacing * CGFloat(numberOfHiddenViews)
        }
        
        if showingTotalIsSmall {
            return (stackViewConstraints: createFillEquallyConstraints(nonHiddenViews, identifier: "TZSV-fill-equally"), subviewConstraints: [])
        }
        
        var stackViewConstraints = [NSLayoutConstraint]()
        var subviewConstraints = [(owningView: UIView, [NSLayoutConstraint])]()

        let totalSpacing = CGFloat(nonHiddenViews.count - 1) * spacing
        let totalSize = totalViewLength + totalSpacing

        var priority: UILayoutPriority = 1000
        let countDownPriority = nonHiddenViews.count > 1
        for arrangedSubview in views {
            if countDownPriority {
                priority--
            }
            
            if isHidden(arrangedSubview) {
                continue
            }

            let length = intrinsicContentLengthOf(arrangedSubview)
            if length == 0 {
                let theConstraint: NSLayoutConstraint
                switch axis {
                case .Horizontal:
                    theConstraint = constraint(item: arrangedSubview, attribute: .Width, toItem: nil, attribute: .NotAnAttribute, priority: 1000, constant: 0)
                case .Vertical:
                    theConstraint = constraint(item: arrangedSubview, attribute: .Height, toItem: nil, attribute: .NotAnAttribute, priority: 1000, constant: 0)
                }
                theConstraint.identifier = "TZSV-fill-proportionally"
                subviewConstraints.append((owningView: arrangedSubview, [theConstraint]))
            } else {
                // totalSize can't be zero, since nonHiddenViews.count != 0
                let multiplier = length / totalSize
                let theConstraint: NSLayoutConstraint
                switch axis {
                case .Horizontal:
                    theConstraint = constraint(item: arrangedSubview, attribute: .Width, toItem: self, multiplier: multiplier, priority: priority)
                case .Vertical:
                    theConstraint = constraint(item: arrangedSubview, attribute: .Height, toItem: self, multiplier: multiplier, priority: priority)
                }
                
                theConstraint.identifier = "TZSV-fill-proportionally"
                stackViewConstraints.append(theConstraint)
            }
        }
        
        return (stackViewConstraints, subviewConstraints)
    }
    
    // Matchs all Width or Height attributes of all given views
    private func createFillEquallyConstraints(views: [UIView], identifier: String, priority: UILayoutPriority = 1000) -> [NSLayoutConstraint] {
        let constraints: [NSLayoutConstraint]
        switch axis {
        case .Horizontal:
            constraints = equalAttributes(views: views.filter({ !self.isHidden($0) }), attribute: .Width, priority: priority)
        case .Vertical:
            constraints = equalAttributes(views: views.filter({ !self.isHidden($0) }), attribute: .Height, priority: priority)
        }
        constraints.forEach { $0.identifier = identifier }
        return constraints
    }
    
    // Chains together the given views using Leading/Trailing or Top/Bottom
    private func createFillConstraints(views: [UIView], priority: UILayoutPriority = 1000, relatedBy relation: NSLayoutRelation = .Equal, constant: CGFloat, identifier: String) -> [NSLayoutConstraint] {
        var constraints = [NSLayoutConstraint]()

        var previousView: UIView?
        for view in views {
            if let previousView = previousView {
                var c: CGFloat = 0
                if !isHidden(previousView) && !isHidden(view) {
                    c = constant
                } else if isHidden(previousView) && !isHidden(view) && views.first != previousView {
                    c = (constant / 2)
                } else if isHidden(view) && !isHidden(previousView) && views.last != view {
                    c = (constant / 2)
                }
                switch axis {
                case .Horizontal:
                    constraints.append(constraint(item: view, attribute: .Leading, relatedBy: relation, toItem: previousView, attribute: .Trailing, constant: c, priority: priority))
                    
                case .Vertical:
                    constraints.append(constraint(item: view, attribute: .Top, relatedBy: relation, toItem: previousView, attribute: .Bottom, constant: c, priority: priority))
                }
            }
            previousView = view
        }
        
        constraints.forEach { $0.identifier = identifier }
        return constraints
    }
    
    private func createEqualCenteringConstraints(views: [UIView]) -> [NSLayoutConstraint] {
        var constraints = [NSLayoutConstraint]()
        
        let visibleViewsWithIndex = views.enumerate().filter { (_, view) in !isHidden(view) }
        
        for enumerationIndex in visibleViewsWithIndex.indices.dropFirst() {
            let spacerView = distributionSpacers[enumerationIndex - 1]
            let previouseView = visibleViewsWithIndex[enumerationIndex - 1].1
            let view = visibleViewsWithIndex[enumerationIndex].1
            
            switch axis {
            case .Horizontal:
                constraints.append(constraint(item: previouseView, attribute: .CenterX, toItem: spacerView, attribute: .Leading, identifier: "TZSV-distributing-edge"))
                constraints.append(constraint(item: view, attribute: .CenterX, toItem: spacerView, attribute: .Trailing, identifier: "TZSV-distributing-edge"))
            case .Vertical:
                constraints.append(constraint(item: previouseView, attribute: .CenterY, toItem: spacerView, attribute: .Top, identifier: "TZSV-distributing-edge"))
                constraints.append(constraint(item: view, attribute: .CenterY, toItem: spacerView, attribute: .Bottom, identifier: "TZSV-distributing-edge"))
            }
        }
        
        if let firstSpacerView = distributionSpacers.first {
            for enumerationIndex in visibleViewsWithIndex.indices.dropFirst(2) {
                let spacerView = distributionSpacers[enumerationIndex - 1]
                let viewIndex = visibleViewsWithIndex[enumerationIndex - 1].0
                
                let attribute: NSLayoutAttribute
                switch axis {
                case .Horizontal:
                    attribute = .Width
                case .Vertical:
                    attribute = .Height
                }
                
                let aConstraint = constraint(item: firstSpacerView, attribute: attribute, toItem: spacerView, attribute: attribute, priority: 150 - UILayoutPriority(viewIndex), identifier: "TZSV-fill-equally")
                constraints.append(aConstraint)
            }
        }
                
        constraints += createFillConstraints(arrangedSubviews, relatedBy: .GreaterThanOrEqual, constant: spacing, identifier: "TZSV-spacing")
        
        return constraints
    }
    
    // Matches all Bottom/Top or Leading Trailing constraints of te given views and matches those attributes of the first/last view to the container
    private func createMatchEdgesContraints(views: [UIView]) -> [NSLayoutConstraint] {
        var constraints = [NSLayoutConstraint]()

        switch axis {
        case .Horizontal:
            switch alignment {
            case .Fill:
                constraints += equalAttributes(views: views, attribute: .Bottom)
                constraints += equalAttributes(views: views, attribute: .Top)
            case .Center:
                constraints += equalAttributes(views: views, attribute: .CenterY)
            case .Leading:
                constraints += equalAttributes(views: views, attribute: .Top)
            case .Trailing:
                constraints += equalAttributes(views: views, attribute: .Bottom)
            case .FirstBaseline:
                if #available(iOS 8.0, *) {
                    constraints += equalAttributes(views: views, attribute: .FirstBaseline)
                }
            case .LastBaseline:
                constraints += equalAttributes(views: views, attribute: .Baseline)
            }
            
        case .Vertical:
            switch alignment {
            case .Fill:
                constraints += equalAttributes(views: views, attribute: .Trailing)
                constraints += equalAttributes(views: views, attribute: .Leading)
            case .Center:
                constraints += equalAttributes(views: views, attribute: .CenterX)
            case .Leading:
                constraints += equalAttributes(views: views, attribute: .Leading)
            case .Trailing:
                constraints += equalAttributes(views: views, attribute: .Trailing)
            case .FirstBaseline, .LastBaseline:
                constraints += []
            }
        }
        
        constraints.forEach { $0.identifier = "TZSV-alignment" }
        return constraints
    }
    
    private func createFirstAndLastViewMatchEdgesContraints() -> [NSLayoutConstraint] {
        
        var constraints = [NSLayoutConstraint]()
        
        let visibleViews = arrangedSubviews.filter({!self.isHidden($0)})
        let firstView = visibleViews.first
        let lastView = visibleViews.last
        
        let edgeItem = layoutMarginsView ?? self
        
        if areAllViewsHidden() {
            switch axis {
            case .Horizontal:
                constraints.append(constraint(item: edgeItem, attribute: .Leading, toItem: orderingSpanner!))
                constraints.append(constraint(item: edgeItem, attribute: .Trailing, toItem: orderingSpanner!))
                
                constraints.append(constraint(item: edgeItem, attribute: .Top, toItem: alignmentSpanner!))
                constraints.append(constraint(item: edgeItem, attribute: .Bottom, toItem: alignmentSpanner!))
                
                switch alignment {
                case .Center:
                    constraints.append(constraint(item: edgeItem, attribute: .CenterY, toItem: alignmentSpanner!))
                default:
                    break
                }
            case .Vertical:
                constraints.append(constraint(item: edgeItem, attribute: .Top, toItem: orderingSpanner!))
                constraints.append(constraint(item: edgeItem, attribute: .Bottom, toItem: orderingSpanner!))
                
                constraints.append(constraint(item: edgeItem, attribute: .Leading, toItem: alignmentSpanner!))
                constraints.append(constraint(item: edgeItem, attribute: .Trailing, toItem: alignmentSpanner!))
                
                switch alignment {
                case .Center:
                    constraints.append(constraint(item: edgeItem, attribute: .CenterX, toItem: alignmentSpanner!))
                default:
                    break
                }
            }
        } else {
            switch axis {
            case .Horizontal:
                if let firstView = firstView {
                    constraints.append(constraint(item: edgeItem, attribute: .Leading, toItem: firstView))
                }
                if let lastView = lastView {
                    constraints.append(constraint(item: edgeItem, attribute: .Trailing, toItem: lastView))
                }
            case .Vertical:
                if let firstView = firstView {
                    constraints.append(constraint(item: edgeItem, attribute: .Top, toItem: firstView))
                }
                if let lastView = lastView {
                    constraints.append(constraint(item: edgeItem, attribute: .Bottom, toItem: lastView))
                }
            }

            let firstArrangedView = arrangedSubviews.first!
            
            let topView: UIView
            var topRelation = NSLayoutRelation.Equal
            
            let bottomView: UIView
            var bottomRelation = NSLayoutRelation.Equal
            
            var centerView: UIView?
            
            // alignmentSpanner must be non nil when alignment is not .Fill
            switch alignment {
            case .Fill:
                topView = firstArrangedView
                bottomView = firstArrangedView
            case .Center:
                topView = alignmentSpanner!
                bottomView = alignmentSpanner!
                centerView = firstArrangedView
            case .Leading:
                topView = firstArrangedView
                bottomView = alignmentSpanner!
            case .Trailing:
                topView = alignmentSpanner!
                bottomView = firstArrangedView
            case .FirstBaseline:
                switch axis {
                case .Horizontal:
                    topView = firstArrangedView
                    bottomView = alignmentSpanner!
                    topRelation = .LessThanOrEqual
                case .Vertical:
                    topView = alignmentSpanner!
                    bottomView = alignmentSpanner!
                }
            case .LastBaseline:
                switch axis {
                case .Horizontal:
                    topView = alignmentSpanner!
                    bottomView = firstArrangedView
                    bottomRelation = .GreaterThanOrEqual
                case .Vertical:
                    topView = alignmentSpanner!
                    bottomView = alignmentSpanner!
                }
            }
            
            switch axis {
            case .Horizontal:
                constraints.append(constraint(item: edgeItem, attribute: .Top, relatedBy: topRelation, toItem: topView))
                constraints.append(constraint(item: edgeItem, attribute: .Bottom, relatedBy: bottomRelation, toItem: bottomView))

                if let centerView = centerView {
                    constraints.append(constraint(item: edgeItem, attribute: .CenterY, toItem: centerView))
                }
            case .Vertical:
                constraints.append(constraint(item: edgeItem, attribute: .Leading, relatedBy: topRelation, toItem: topView))
                constraints.append(constraint(item: edgeItem, attribute: .Trailing, relatedBy: bottomRelation, toItem: bottomView))

                if let centerView = centerView  {
                    constraints.append(constraint(item: edgeItem, attribute: .CenterX, toItem: centerView))
                }
            }
        }
    
        constraints.forEach { $0.identifier = "TZSV-canvas-connection" }
        return constraints
    }
    
    private func equalAttributes(views views: [UIView], attribute: NSLayoutAttribute, priority: UILayoutPriority = 1000) -> [NSLayoutConstraint] {
        var constraints = [NSLayoutConstraint]()
        if views.count > 0 {
            var firstView: UIView?

            for view in views {
                if let firstView = firstView {
                    constraints.append(constraint(item: firstView, attribute: attribute, toItem: view, priority: priority))
                } else {
                    firstView = view
                }
            }
        }
        return constraints
    }

    // Convenience method to help make NSLayoutConstraint in a less verbose way
    private func constraint(item view1: AnyObject, attribute attr1: NSLayoutAttribute, relatedBy relation: NSLayoutRelation = .Equal, toItem view2: AnyObject?, attribute attr2: NSLayoutAttribute? = nil, multiplier: CGFloat = 1, constant c: CGFloat = 0, priority: UILayoutPriority = 1000, identifier: String? = nil) -> NSLayoutConstraint {

        let attribute2 = attr2 != nil ? attr2! : attr1

        let constraint = NSLayoutConstraint(item: view1, attribute: attr1, relatedBy: relation, toItem: view2, attribute: attribute2, multiplier: multiplier, constant: c)
        constraint.priority = priority
        constraint.identifier = identifier
        return constraint
    }
    
    private func isHidden(view: UIView) -> Bool {
        if view.hidden {
            return true
        }
        return animatingToHiddenViews.indexOf(view) != nil
    }
    
    private func areAllViewsHidden() -> Bool {
        return arrangedSubviews
            .map { isHidden($0) }
            .reduce(true) { $0 && $1 }
    }
        
    private func isMultilineLabel(view: UIView) -> Bool {
        if let label = view as? UILabel where label.numberOfLines != 1 {
            return true
        } else {
            return false
        }
    }
    
    // Disables setting the background color to mimic an actual UIStackView which is a non-drawing view.
    override public class func layerClass() -> AnyClass {
        return CATransformLayer.self
    }
    
    // Suppress the warning of "changing property backgroundColor in transform-only layer, will have no effect"
    override public var backgroundColor: UIColor? {
        get {
            return nil
        }
        set {
            
        }
    }
    
    // Suppress the warning of "changing property opaque in transform-only layer, will have no effect"
    override public var opaque: Bool {
        get {
            return true
        }
        set {
            
        }
    }
}
