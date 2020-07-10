/*
    Copyright (C) 2015 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information

    Abstract:
    A view controller hosting the various recipes being demonstrated.
*/

import UIKit

class RecipesContainerViewController: UIViewController {
    // MARK: Properties

    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var titleLabel: UILabel!

    @IBOutlet var navigationButtons: [UIButton]!

    let recipes = Recipe.loadRecipes()
    
    var currentRecipeIndex = 0
    
    var showInstructionsForFullScreenMode = true
    
    // MARK: UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Give the container view a border and layout margins.
        containerView.layer.borderWidth = 1.0
        containerView.layer.borderColor = UIColor.black.cgColor
        containerView.layoutMargins = UIEdgeInsets(top: 8.0, left: 8.0, bottom: 8.0, right: 8.0)
                
        showRecipe(recipe: recipes[currentRecipeIndex])
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let segueIdentifier = segue.identifier, let identifier = CookbookStoryboardIdentifier(rawValue: segueIdentifier) else { return }
        
        switch identifier {
            case .InformationView:
                // Fetch the `InformationViewController` from the presented `UINavigationController`.
                guard let navigationController = segue.destination as? UINavigationController,
                    let infoViewController = navigationController.viewControllers.first as? InformationViewController else {
                        return
                }
                
                let recipe = recipes[currentRecipeIndex]
                infoViewController.informationText = recipe.description

            default:
                /*
                    Add a double tap gesture recognizer to presented recipe view
                    controllers. This recognizer will dismiss the presented controller.
                */
                let doubleTapGesture = UITapGestureRecognizer(target: self, action: "handleDismissPresentedViewControllerGestureRecognizer:")
                
                doubleTapGesture.numberOfTapsRequired = 2
                doubleTapGesture.numberOfTouchesRequired = 1
                
                segue.destination.view.addGestureRecognizer(doubleTapGesture)
        }
    }
    
    // MARK: Interface Builder actions

    @IBAction func dismissInformationViewController(sender: UIStoryboardSegue) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func showPreviousRecipe(_ sender: Any) {
        let count = recipes.count
        //        let index = (currentRecipeIndex.predecessor() + count) % count
        if currentRecipeIndex == 0 {
            currentRecipeIndex = 0
        }else{
            currentRecipeIndex -= 1
        }
//        let index = (currentRecipeIndex + count) % count
        let recipe = recipes[currentRecipeIndex]
        
        showRecipe(recipe: recipe)
   
    }
    
    @IBAction func showNextRecipe(_ sender: Any) {
        
        if currentRecipeIndex != recipes.count {
            currentRecipeIndex += 1
        }
        let recipe = recipes[currentRecipeIndex]
        
        showRecipe(recipe: recipe)
 
        
        
        //        let count = recipes.count
////        let index = currentRecipeIndex.successor() % count
//          let index = currentRecipeIndex % count
//        let recipe = recipes[index]
//
//        showRecipe(recipe: recipe)
//        currentRecipeIndex = index
    }

    @IBAction func displayFullScreen(sender: UIGestureRecognizer) {
        guard sender.state == .began else { return }
        
        let recipe = recipes[currentRecipeIndex]
        self.performSegue(withIdentifier: recipe.segueIdentifier, sender: nil)
        
        if showInstructionsForFullScreenMode {
            let alertController = UIAlertController(title: "Full Screen Mode", message: "Double-tap to exit full screen mode.", preferredStyle: .alert)
            let dismissAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            let acceptAction = UIAlertAction(title: "Don't Show Again", style: .default) { _ in
                self.showInstructionsForFullScreenMode = false
            }
            
            alertController.addAction(dismissAction)
            alertController.addAction(acceptAction)
            
            presentedViewController?.present(alertController, animated: true, completion: nil)
        }
    }

    // MARK: Gesture recognizer handlers
    
    func handleDismissPresentedViewControllerGestureRecognizer(gestureRecognizer: UITapGestureRecognizer) {
        if gestureRecognizer.state == .recognized {
            presentedViewController?.dismiss(animated: true, completion: nil)
        }
    }

    // MARK: Convenience
    
    private func enableButtons(enabled: Bool = true) {
        for button in navigationButtons {
            button.isEnabled = enabled
        }
    }

    private func showRecipe(recipe: Recipe) {
        titleLabel.text = recipe.title
        enableButtons(enabled: false)
        
        let newViewController = recipe.instantiateViewController()
        let oldViewController = children[0]
        
        let newView = newViewController.view
        let containerMargins = containerView.layoutMarginsGuide

        newView?.translatesAutoresizingMaskIntoConstraints = false
        addChild(newViewController)
        
        transition(from: oldViewController, to: newViewController, duration: 0.25, options: [.transitionCrossDissolve], animations: {
            newView?.leadingAnchor.constraint(equalTo: containerMargins.leadingAnchor).isActive = true
            newView?.trailingAnchor.constraint(equalTo: containerMargins.trailingAnchor).isActive = true
            newView?.topAnchor.constraint(equalTo: containerMargins.topAnchor).isActive = true
            newView?.bottomAnchor.constraint(equalTo: containerMargins.bottomAnchor).isActive = true
        }, completion: { [unowned self] _ in
            oldViewController.removeFromParent()
            self.enableButtons()
        })
    }
}

