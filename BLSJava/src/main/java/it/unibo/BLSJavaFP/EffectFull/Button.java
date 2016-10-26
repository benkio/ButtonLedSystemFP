/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package it.unibo.BLSJavaFP.EffectFull;

import fj.data.IO;
import fj.data.IOFunctions;
import fj.data.List;
import it.unibo.BLSJavaFP.Pure.Behaviour.LedBehaviour;
import static it.unibo.BLSJavaFP.Pure.Behaviour.LedBehaviour.ledNextState;
import it.unibo.BLSJavaFP.Pure.Data.Led;
import it.unibo.BLSJavaFP.Pure.Data.Observer;
import it.unibo.BLSJavaFP.Pure.Data.Subject;
import it.unibo.BLSJavaFP.Pure.MVar;
import java.io.IOException;

/**
 *
 * @author benkio
 */
public class Button {

    public static IO<String> mVarObserver(MVar<Led> ml) {
        try {
            Led l = ml.take();
            Led lnext = ledNextState().eval(l);
            ml.put(lnext);
            String ledMessage;
            if (LedBehaviour.getLedStatus(lnext)) {
                ledMessage = "on";
            } else {
                ledMessage = "off";
            }
            return IOFunctions.<String>unit(ledMessage);
        } catch (InterruptedException e) {
            return IOFunctions.unit("error");
        }
    }

    public static <T> IO<List<T>> notify(Subject<T> s) throws IOException {
        if (s.getObs().isEmpty()) {
            return IOFunctions.unit(List.nil());
        } else {
            Observer<T> o = s.getObs().head();
            if (o.func.isLeft()) {
                o.func.left().value().f(s.getSub());
                return notify(new Subject(s.getSub(), s.getObs().tail()));
            } else {
                T x = o.func.right().value().f(s.getSub()).run();
                List<T> xs = (List<T>) notify(new Subject(s.getSub(), s.getObs().tail())).run();
                return IOFunctions.unit(List.cons(x, xs));
            }
        }
    }
}
