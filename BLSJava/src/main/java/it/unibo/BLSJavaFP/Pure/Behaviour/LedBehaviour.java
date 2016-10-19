package it.unibo.BLSJavaFP.Pure.Behaviour;

import fj.data.State;
import it.unibo.BLSJavaFP.Pure.Data.Led;

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

    public static State<Led, Led> ledNextState(){
        return State.<Led>init().map((Led l) -> (Led) switchStatus(l));
    }
}
