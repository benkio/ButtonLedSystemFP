package it.unibo.BLSJavaFP.Pure.Behaviour;

import it.unibo.BLSJavaFP.Pure.Data.Led;
import it.unibo.BLSJavaFP.Pure.FunctionalAbstraction.StateMonad;

import static it.unibo.BLSJavaFP.Pure.FunctionalAbstraction.StateMonad.get;

/**
 * Created by benkio on 10/19/16.
 */
public class LedBehaviour {

    public static boolean getLedStatus(Led l) {
        return l.on;
    }

    public static String show(Led l) {
        return "Led{on=" + getLedStatus(l) + "}";
    }

    public static Led initialLedStatus(){
        return new Led(false);
    }

    public static Led switchStatus(Led l){
        return new Led(!getLedStatus(l));
    }

    public static StateMonad<Led, Led> ledNextState(){
        return StateMonad.<Led>get().flatMap((Led l) -> StateMonad.getState((Led x) -> switchStatus(x)));
    }
}
