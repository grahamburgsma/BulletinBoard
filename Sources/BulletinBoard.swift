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

	private var currentIndex: Int? {
		return items.index(where: { $0 === currentItem })
	}

	public var backgroundViewStyle: BulletinBackgroundViewStyle = .dimmed
	public var cornerRadius: CGFloat = 12 {
		didSet {
			contentView.layer.cornerRadius = cornerRadius
		}
	}

	public var allowsSwipeInteraction: Bool = true

	@IBOutlet var contentView: UIView!
	@IBOutlet var contentStackView: UIStackView!
	@IBOutlet var activityIndicator: UIActivityIndicatorView!

	@IBOutlet weak var centerYConstraint: NSLayoutConstraint!
	@IBOutlet weak var bottomYConstraint: NSLayoutConstraint!

	var isDismissable: Bool = false

	var swipeInteractionController: BulletinSwipeInteractionController!

	public init(items: [BulletinItem]) {
		precondition(items.isEmpty == false, "Must provide at least 1 item")
		self.items = items
		self.currentItem = items.first!

		super.init(nibName: "BulletinBoard", bundle: Bundle(for: type(of: self)))

		self.items.forEach { $0.board = self }

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

		if #available(iOSApplicationExtension 11.0, *) {
			cornerRadius = screenHasRoundedCorners ? 36 : 12
		} else {
			cornerRadius = 12
		}

		setUpKeyboardLogic()
		show(item: currentItem, animated: false)
	}

	// MARK: - Touch Events

	@IBAction fileprivate func handleTap(recognizer: UITapGestureRecognizer) {
		dismiss(animated: true, completion: nil)
	}

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

	@available(iOSApplicationExtension 11.0, *)
	public override func viewSafeAreaInsetsDidChange() {
		super.viewSafeAreaInsetsDidChange()

		cornerRadius = screenHasRoundedCorners ? 36 : 12
	}
}

extension BulletinBoard {

	func show(item: BulletinItem, animated: Bool = true) {
		let oldArrangedSubviews = contentStackView.arrangedSubviews

		let newArrangedSubviews = item.views
		newArrangedSubviews.forEach { (view) in
			view.isHidden = true
			contentStackView.addArrangedSubview(view)
		}

		let animationDuration = animated ? 0.75 : 0
		let transitionAnimationChain = AnimationChain(duration: animationDuration)

		let hideSubviewsAnimationPhase = AnimationPhase(relativeDuration: 1 / 3, curve: .linear, animations: {
			oldArrangedSubviews.forEach {
				$0.layer.removeAllAnimations()
				$0.alpha = 0
			}
			newArrangedSubviews.forEach { $0.alpha = 0 }
		}, completion: nil)

		let displayNewItemsAnimationPhase = AnimationPhase(relativeDuration: 1 / 3, curve: .linear, animations: {
			newArrangedSubviews.forEach { $0.isHidden = false }
			oldArrangedSubviews.forEach { $0.isHidden = true }
		}, completion: {
			self.contentStackView.alpha = 1
		 })

		let finalAnimationPhase = AnimationPhase(relativeDuration: 1 / 3, curve: .linear, animations: {
			newArrangedSubviews.forEach { $0.alpha = 1 }
		}, completion: {
			self.isDismissable = self.currentItem.isDismissable

			oldArrangedSubviews.forEach { $0.removeFromSuperview() }

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

// MARK: - System Elements

extension BulletinBoard {

	@available(iOS 11.0, *)
	fileprivate var screenHasRoundedCorners: Bool {
		return view.safeAreaInsets.bottom > 0
	}

	fileprivate func updateCornerRadius() {

//		if cardPadding.rawValue == 0 {
//			contentView.layer.cornerRadius = 0
//			return
//		}

		var defaultRadius: CGFloat = 12

		if #available(iOS 11.0, *) {
			defaultRadius = screenHasRoundedCorners ? 36 : 12
		}

		contentView.layer.cornerRadius = defaultRadius
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

//	public func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
//		guard allowsSwipeInteraction else { return nil }
//
//		let isEligible = swipeInteractionController.isInteractionInProgress
//		return isEligible ? swipeInteractionController : nil
//	}
}
