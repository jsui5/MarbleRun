//
//  ViewController.swift
//  WantToCryEngine
//
//  Created by Alex on 2023-02-10.
//

import GLKit

extension ViewController: GLKViewControllerDelegate {
    func glkViewControllerUpdate(_ controller: GLKViewController) {
        GameUpdate(game);
    }
}

class ViewController: GLKViewController {
    
    private var context: EAGLContext?;
    private var game: OpaquePointer!;
    
    private func setup(){
        context = EAGLContext(api: .openGLES3);
        EAGLContext.setCurrent(context);
        if let view = self.view as? GLKView, let context = context {
            view.context = context;
            delegate = self as GLKViewControllerDelegate;
            //initialize game (with its renderer)
            game = NewGame(view);
        }

    }
    
    override func viewDidLoad() {
        super.viewDidLoad();
        // Do any additional setup after loading the view.
        setup();
        
        //Gesture recognizer to send input through to the Game.
        let drag = UIPanGestureRecognizer(target: self, action: #selector(self.doDrag(_:)))
        drag.minimumNumberOfTouches = 1;
        drag.maximumNumberOfTouches = 1;
        view.addGestureRecognizer(drag);

        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(self.doPinch(_:)))
        view.addGestureRecognizer(pinch);

        
        let doubleDrag = UIPanGestureRecognizer(target: self, action: #selector(self.doDoubleDrag(_:)))
        doubleDrag.minimumNumberOfTouches = 2;
        doubleDrag.maximumNumberOfTouches = 2;
        view.addGestureRecognizer(doubleDrag);

    }
    
    @objc func doDrag(_ sender: UIPanGestureRecognizer){
        let rot = GLKVector2Make(Float(sender.velocity(in: view).y/2000), Float(sender.velocity(in: view).x/2000));
        //Call relevant game event.
        GameEventSinglePan(game, rot);
    }

    @objc func doDoubleDrag(_ sender: UIPanGestureRecognizer){
        let trans = GLKVector2Make(Float(sender.velocity(in: view).x/2000), Float(sender.velocity(in: view).y/2000));
        //Call relevant game event.
        GameEventDoublePan(game, trans);
    }

    @objc func doPinch(_ sender: UIPinchGestureRecognizer){
        GameEventPinch(game, Float(sender.velocity/10));
    }
    
    override func glkView(_ view: GLKView, drawIn rect: CGRect) {
        GameDraw(game, rect);
    }

}

