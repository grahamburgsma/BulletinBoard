/**
*  BulletinBoard
*  Copyright (c) 2017 Alexis Aubry. Licensed under the MIT license.
*/

import UIKit

final public class BulletinBoard: UIViewController, UIGestureRecognizerDelegate {

	public var items: [BulletinItem]

	public var currentItem: BulletinItem {
		didSet {
			show(item: currentItem)
		}
	}

	var currentIndex: Int? {
		return items.index(where: { $0 === currentItem })
	}

	@objc public var backgroundViewStyle: BulletinBackgroundViewStyle = .dimmed
	@objc public var statusBarAppearance: BulletinStatusBarAppearance = .automatic
	@objc public var statusBarAnimation: UIStatusBarAnimation = .fade
	@objc public var hidesHomeIndicator: Bool = false
	@objc public var cardPadding: BulletinPadding = .regular

	@objc public var allowsSwipeInteraction: Bool = true

	@IBOutlet var contentView: UIView!
	@IBOutlet var contentStackView: UIStackView!
	@IBOutlet var activityIndicator: UIActivityIndicatorView!

	var isDismissable: Bool = false

	var activeSnapshotView: UIView?
	var swipeInteractionController: BulletinSwipeInteractionController!

	// MARK: - Private Interface Elements

	fileprivate let bottomSafeAreaCoverView = UIVisualEffectView()

	public init(items: [BulletinItem]) {
		self.items = items
		self.currentItem = items.first!

		super.init(nibName: "BulletinBoard", bundle: Bundle(for: type(of: self)))

		self.items.forEach({ $0.board = self })

		modalPresentationStyle = .custom
		transitioningDelegate = self
		setNeedsStatusBarAppearanceUpdate()

		if #available(iOS 11.0, *) {
			setNeedsUpdateOfHomeIndicatorAutoHidden()
		}
	}

	required public init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	public override func viewDidLoad() {
		super.viewDidLoad()

		contentView.layer.cornerRadius = 12

		setUpKeyboardLogic()
		show(item: currentItem, animated: false)
	}

	override public func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)

		/// Animate status bar appearance when hiding
		UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
			self.setNeedsStatusBarAppearanceUpdate()
		})
	}

	@available(iOS 11.0, *)
	override public func viewSafeAreaInsetsDidChange() {
		super.viewSafeAreaInsetsDidChange()

		updateCornerRadius()
	}

	// MARK: - Gesture Recognizer

	public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
		if touch.view?.isDescendant(of: contentView) == true {
			return false
		}

		return true
	}

	deinit {
		print("DEINIT: ", String(describing: self))
		cleanUpKeyboardLogic()
	}
}

extension BulletinBoard {

	func show(item: BulletinItem, animated: Bool = true) {
		swipeInteractionController?.cancelIfNeeded()
		refreshSwipeInteractionController()

		let oldArrangedSubviews = contentStackView.arrangedSubviews

		let newArrangedSubviews = item.makeArrangedSubviews()
		newArrangedSubviews.forEach { (view) in
			view.isHidden = true
			contentStackView.addArrangedSubview(view)
		}

		let animationDuration = animated ? 0.75 : 0
		let transitionAnimationChain = AnimationChain(duration: animationDuration)

		let hideSubviewsAnimationPhase = AnimationPhase(relativeDuration: 1 / 3, curve: .linear, animations: {
			self.hideActivityIndicator(showContentStack: false)

			oldArrangedSubviews.forEach({ $0.alpha = 0 })
			newArrangedSubviews.forEach({ $0.alpha = 0 })
		}, completion: nil)

		let displayNewItemsAnimationPhase = AnimationPhase(relativeDuration: 1 / 3, curve: .linear, animations: {
			newArrangedSubviews.forEach({ $0.isHidden = false })
			oldArrangedSubviews.forEach({ $0.isHidden = true })
		}, completion: {
			self.contentStackView.alpha = 1
		})

		let finalAnimationPhase = AnimationPhase(relativeDuration: 1 / 3, curve: .linear, animations: {
			newArrangedSubviews.forEach({ $0.alpha = 1 })
		}, completion: {
			self.isDismissable = self.currentItem.isDismissable

			oldArrangedSubviews.forEach({ $0.removeFromSuperview() })

			UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, newArrangedSubviews.first)
		})

		transitionAnimationChain.add(hideSubviewsAnimationPhase)
		transitionAnimationChain.add(displayNewItemsAnimationPhase)
		transitionAnimationChain.add(finalAnimationPhase)

		transitionAnimationChain.start()
	}

	public func showFirst() {
		currentItem = items.first!
	}

	public func showNext() {
		if let index = currentIndex, items.count > index {
			currentItem = items[index + 1]
		}
	}

	public func showLast() {
		currentItem = items.last!
	}
}

// MARK: - Layout

extension BulletinBoard {

	// MARK: - Transition Adaptivity

	func bottomMargin() -> CGFloat {

		var bottomMargin: CGFloat = cardPadding.rawValue

		if hidesHomeIndicator == true {
			bottomMargin = cardPadding.rawValue == 0 ? 0 : 6
		}

		return bottomMargin

	}

	// MARK: - Touch Events

	@IBAction fileprivate func handleTap(recognizer: UITapGestureRecognizer) {
		dismiss(animated: true, completion: nil)
	}
}

// MARK: - System Elements

extension BulletinBoard {

	override public var preferredStatusBarStyle: UIStatusBarStyle {
		switch statusBarAppearance {
		case .lightContent:
			return .lightContent
		case .automatic:
			return backgroundViewStyle.rawValue.isDark ? .lightContent : .default
		default:
			break
		}

		return .default
	}

	override public var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
		return statusBarAnimation
	}

	override public var prefersStatusBarHidden: Bool {
		return statusBarAppearance == .hidden
	}

	@available(iOS 11.0, *)
	override public func prefersHomeIndicatorAutoHidden() -> Bool {
		return hidesHomeIndicator
	}

}

// MARK: - Safe Area

extension BulletinBoard {

	@available(iOS 11.0, *)
	fileprivate var screenHasRoundedCorners: Bool {
		return view.safeAreaInsets.bottom > 0
	}

	fileprivate func updateCornerRadius() {

		if cardPadding.rawValue == 0 {
			contentView.layer.cornerRadius = 0
			return
		}

		var defaultRadius: CGFloat = 12

		if #available(iOS 11.0, *) {
			defaultRadius = screenHasRoundedCorners ? 36 : 12
		}

		contentView.layer.cornerRadius = defaultRadius
	}
}

// MARK: - Background

extension BulletinBoard {

	/// Displays the cover view at the bottom of the safe area. Animatable.
	func showBottomSafeAreaCover() {

		let isDark = backgroundViewStyle.rawValue.isDark

		let blurStyle: UIBlurEffectStyle = isDark ? .dark : .extraLight
		bottomSafeAreaCoverView.effect = UIBlurEffect(style: blurStyle)

	}

	/// Hides the cover view at the bottom of the safe area. Animatable.
	func hideBottomSafeAreaCover() {
		bottomSafeAreaCoverView.effect = nil
	}

}

// MARK: - Activity Indicator

extension BulletinBoard {

	/// Displays the activity indicator.
	func displayActivityIndicator(color: UIColor) {

		activityIndicator.color = color
		activityIndicator.startAnimating()

		UIView.animate(withDuration: 0.25, animations: {
			self.contentStackView.alpha = 0
		}) { _ in
			UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, self.activityIndicator)
		}

	}

	/// Hides the activity indicator.
	func hideActivityIndicator(showContentStack: Bool) {

		activityIndicator.stopAnimating()

		UIView.animate(withDuration: 0.25) {
			if showContentStack {
				self.contentStackView.alpha = 1
			}
		}
	}
}

// MARK: - Transitions

extension BulletinBoard: UIViewControllerTransitioningDelegate {

	public func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
		return BulletinPresentationController(presentedViewController: presented, presenting: presenting, backgroundStyle: backgroundViewStyle)
	}

	public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		return BulletinPresentationAnimationController(style: backgroundViewStyle)
	}

	public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		return BulletinDismissalAnimationController()
	}

	public func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
		guard allowsSwipeInteraction else { return nil }

		let isEligible = swipeInteractionController.isInteractionInProgress
		return isEligible ? swipeInteractionController : nil
	}

	/// Creates a new view swipe interaction controller and wires it to the content view.
	func refreshSwipeInteractionController() {
		guard allowsSwipeInteraction else { return }

		swipeInteractionController = BulletinSwipeInteractionController()
		swipeInteractionController.wire(to: self)
	}

	/// Prepares the view controller for dismissal.
	func prepareForDismissal(displaying snapshot: UIView) {
		view.bringSubview(toFront: bottomSafeAreaCoverView)
		activeSnapshotView = snapshot
	}

}

extension UIViewAnimationOptions {
	init(curve: UIViewAnimationCurve) {
		self = UIViewAnimationOptions(rawValue: UInt(curve.rawValue << 16))
	}
}

// MARK: - Swift Compatibility

#if swift(>=4.0)
	let UILayoutPriorityRequired = UILayoutPriority.required
	let UILayoutPriorityDefaultHigh = UILayoutPriority.defaultHigh
	let UILayoutPriorityDefaultLow = UILayoutPriority.defaultLow
#endif
