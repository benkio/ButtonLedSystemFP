/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package it.unibo.BLSJavaFP.EffectFull;

import fj.F;
import fj.P2;
import fj.Unit;
import fj.data.IO;
import fj.data.IOFunctions;
import fj.data.List;
import fj.data.State;
import it.unibo.BLSJavaFP.Pure.Behaviour.ButtonBehaviour;
import static it.unibo.BLSJavaFP.Pure.Behaviour.LedBehaviour.ledNextState;
import static it.unibo.BLSJavaFP.Pure.Behaviour.LoggerBehaviour.logLed;
import it.unibo.BLSJavaFP.Pure.Data.Subject;
import java.io.IOException;

/**
 *
 * @author benkio
 */
public class Led {

    public static State<it.unibo.BLSJavaFP.Pure.Data.Led, it.unibo.BLSJavaFP.Pure.Data.Led> ledStateMachine() {
        F<it.unibo.BLSJavaFP.Pure.Data.Led, P2<it.unibo.BLSJavaFP.Pure.Data.Led, it.unibo.BLSJavaFP.Pure.Data.Led>> fun = (it.unibo.BLSJavaFP.Pure.Data.Led s) -> {
            State<it.unibo.BLSJavaFP.Pure.Data.Led, it.unibo.BLSJavaFP.Pure.Data.Led> l = State.<it.unibo.BLSJavaFP.Pure.Data.Led>init();
            boolean b = false;
            try {
                b = Console.askPress.run();
            } catch (IOException e) {
            }
            if (b) {
                return l.run(s);
            } else {
                P2<it.unibo.BLSJavaFP.Pure.Data.Led, it.unibo.BLSJavaFP.Pure.Data.Led> lnext = ledNextState().run(s);
                P2<it.unibo.BLSJavaFP.Pure.Data.Led, String> lnextLogged = logLed(lnext._2(), "Led Status Changed: ");
                Console.showLog.f(lnextLogged._2());
                return ledStateMachine().run(lnext._2());
            }
        };
        return State.unit(fun);
    }

    public static <T> IO<Unit> ledStateMachine1(Subject<T> s) throws IOException {
        boolean b = Console.askPress.run();
        if (b) {
            return IOFunctions.ioUnit;
        } else {
            List<T> l = Button.notify(s).run();
            Subject<T> s1 = ButtonBehaviour.setSubject(s, l.head());
            return ledStateMachine1(s1);
        }
    }
    
}
