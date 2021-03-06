package it.unibo.BLSJavaFP;

import fj.F;
import fj.P2;
import fj.Unit;
import fj.data.IO;
import fj.data.IOFunctions;
import fj.data.List;
import it.unibo.BLSJavaFP.EffectFull.BLSSwing;
import it.unibo.BLSJavaFP.EffectFull.Button;
import it.unibo.BLSJavaFP.EffectFull.Console;
import static it.unibo.BLSJavaFP.Pure.Behaviour.LedBehaviour.initialLedStatus;
import static it.unibo.BLSJavaFP.Pure.Behaviour.LedBehaviour.ledNextState;
import static it.unibo.BLSJavaFP.Pure.Behaviour.LoggerBehaviour.logLed;
import it.unibo.BLSJavaFP.Pure.Data.Led;
import it.unibo.BLSJavaFP.Pure.Data.Observer;
import it.unibo.BLSJavaFP.Pure.Data.Subject;
import it.unibo.BLSJavaFP.Pure.MVar;
import java.io.IOException;
import java.util.logging.Level;
import java.util.logging.Logger;


public class Main {

    public static void main(String[] args){
        GUIMain();
    }
    
    private static void SimplerMain(){
        it.unibo.BLSJavaFP.EffectFull.Led.ledStateMachine().run(initialLedStatus());
    }
    
    private static void ConsoleMain(){
        
        F<Led,IO<Led>> f = l -> {
            Led l1 = l;
            try {
                l1 = IOFunctions.unit(ledNextState().eval(l)).run();
            } catch (IOException ex) {
                Logger.getLogger(Main.class.getName()).log(Level.SEVERE, null, ex);
            }
            P2<Led,String> l1logged = logLed(l1, "Led Status Changed: ");
            IO<Unit> ioShow = Console.showLog.f(l1logged._2());
            try {
                ioShow.run();
            } catch (IOException ex) {
                Logger.getLogger(Main.class.getName()).log(Level.SEVERE, null, ex);
            }
            return IOFunctions.unit(l1logged._1());
        };
        Observer<Led> o = Observer.stateFullObs(f);
        Subject<Led> s = new Subject(initialLedStatus(), List.list(o));
        try {
            it.unibo.BLSJavaFP.EffectFull.Led.ledStateMachine1(s).run();
        } catch (IOException ex) {
            Logger.getLogger(Main.class.getName()).log(Level.SEVERE, null, ex);
        }
    }
    
    private static void GUIMain(){
        try {
            graphicMain.run();
        } catch (IOException ex) {
            Logger.getLogger(Main.class.getName()).log(Level.SEVERE, null, ex);
        }
    }
    
     private static final IO<Unit> graphicMain = () -> {
        MVar status = MVar.withDefault(initialLedStatus());
        BLSSwing.btn.addActionListener((java.awt.event.ActionEvent e) -> {
            String ledMessage = "";
            try {
                ledMessage = (String) Button.mVarObserver(status).run();
            } catch (IOException f) {
            }
            BLSSwing.ledLabel.setText(ledMessage);
        });
        BLSSwing.main();
        return Unit.unit();
    };
}
