/**
*  BulletinBoard
*  Copyright (c) 2017 Alexis Aubry. Licensed under the MIT license.
*/

import UIKit

final public class BulletinBoard: UIViewController, UIGestureRecognizerDelegate {

	public var items: [BulletinItem] {
		didSet {
			items.forEach { $0.board = self }
		}
	}

	public var currentItem: BulletinItem {
		didSet {
			show(item: currentItem)
		}
	}

	private var currentIndex: Int {
		return items.index(where: { $0 === currentItem }) ?? 0
	}

	public var backgroundViewStyle: BulletinBackgroundViewStyle = .dimmed
	public var cornerRadius: CGFloat = 12 {
		didSet {
			view.layer.cornerRadius = cornerRadius
		}
	}

	var isLoading: Bool = false {
		didSet {
            isLoading ? activityIndicator.startAnimating() : activityIndicator.stopAnimating()
			contentStackView.isHidden = isLoading
		}
	}

    public var allowDismissal: Bool = true
	public var allowSwipeInteraction: Bool = true

	@IBOutlet var contentStackView: UIStackView!
	@IBOutlet var activityIndicator: UIActivityIndicatorView!

    var panGestureRecognizer: UIPanGestureRecognizer!

    public var dismissalHandler: ((BulletinBoard) -> Void)?

	public convenience init(_ item: BulletinItem) {
		self.init(items: [item])
	}

	public init(items: [BulletinItem]) {
		precondition(items.isEmpty == false, "Must provide at least 1 item")

		self.items = items
		self.currentItem = items.first!

		super.init(nibName: "BulletinBoard", bundle: Bundle(for: type(of: self)))

        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        
        items.forEach { $0.board = self }

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

        view.addGestureRecognizer(panGestureRecognizer)

		setCornerRadius()

		show(item: currentItem, animated: false)
	}

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        updatePreferredContentSize()
    }

	public override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        view.endEditing(true)
        
		super.dismiss(animated: flag) {
			self.dismissalHandler?(self)
			completion?()
		}
	}

	// MARK: - Touch Events
    @objc private func handlePan(_ recognizer: UIPanGestureRecognizer) {
        if recognizer.state == .began, isBeingDismissed == false, isBeingPresented == false {
            dismiss(animated: true)
        }
    }

	@available(iOS 11.0, *)
	public override func viewSafeAreaInsetsDidChange() {
		super.viewSafeAreaInsetsDidChange()

		setCornerRadius()
	}
}

extension BulletinBoard {

    func updatePreferredContentSize() {
        if traitCollection.horizontalSizeClass == .regular {
            preferredContentSize = view.systemLayoutSizeFitting(
                CGSize(width: 450, height: UIView.layoutFittingCompressedSize.height),
                withHorizontalFittingPriority: .required,
                verticalFittingPriority: .fittingSizeLevel)
        } else {
            preferredContentSize = view.systemLayoutSizeFitting(
                CGSize(width: view.frame.width, height: UIView.layoutFittingCompressedSize.height),
                withHorizontalFittingPriority: .required,
                verticalFittingPriority: .fittingSizeLevel)
        }
    }

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
		}, completion: {
            newArrangedSubviews.forEach { $0.isHidden = false }
            oldArrangedSubviews.forEach { $0.isHidden = true }
        })

		let displayNewItemsAnimationPhase = AnimationPhase(relativeDuration: 1 / 3, curve: .linear, animations: {
            self.updatePreferredContentSize()
		}, completion: {
			self.contentStackView.alpha = 1
		 })

		let finalAnimationPhase = AnimationPhase(relativeDuration: 1 / 3, curve: .linear, animations: {
			newArrangedSubviews.forEach { $0.alpha = 1 }
		}, completion: {
			oldArrangedSubviews.forEach { $0.removeFromSuperview() }

			UIAccessibility.post(notification: UIAccessibility.Notification.screenChanged, argument: newArrangedSubviews.first)
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
		if hasNext {
			currentItem = items[currentIndex + 1]
		}
	}

	public func showNextOrDismiss() {
		if hasNext {
			currentItem = items[currentIndex + 1]
		} else {
			dismiss(animated: true, completion: nil)
		}
	}

	public var hasNext: Bool {
		return currentIndex + 1 < items.count
	}

	public func showLast() {
		currentItem = items.last!
	}
}

// MARK: - System Elements

extension BulletinBoard {

	@available(iOS 11.0, *)
	fileprivate var screenHasRoundedCorners: Bool {
		return (view.window ?? view).safeAreaInsets.bottom > 0
	}

	func setCornerRadius() {
		if traitCollection.horizontalSizeClass == .regular {
			cornerRadius = 36
		} else if #available(iOS 11.0, *) {
			cornerRadius = screenHasRoundedCorners ? 36 : 12
		} else {
			cornerRadius = 12
		}
	}
}

// MARK: - Transitions
extension BulletinBoard: UIViewControllerTransitioningDelegate {

	public func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        let presentationController: BulletinPresentationController = BulletinPresentationController(presentedViewController: presented, presenting: presenting, backgroundStyle: backgroundViewStyle)
        presentationController.dimissOnTap = allowDismissal
        return presentationController
	}

	public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return BulletinAnimationController(operation: .present)
	}

	public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		return BulletinAnimationController(operation: .dismiss)
	}

    public func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        guard
            allowSwipeInteraction,
            let animator = animator as? BulletinAnimationController
            else { return nil }

        return BulletinSwipeInteractionController(animationController: animator, panGestureRecognizer: panGestureRecognizer)
    }

    public func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        guard
            allowSwipeInteraction,
            let animator = animator as? BulletinAnimationController
            else { return nil }

        return BulletinSwipeInteractionController(animationController: animator, panGestureRecognizer: panGestureRecognizer)
    }
}
