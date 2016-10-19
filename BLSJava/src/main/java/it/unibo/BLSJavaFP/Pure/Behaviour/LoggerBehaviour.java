package it.unibo.BLSJavaFP.Pure.Behaviour;

import static fj.P.p;
import fj.P2;
import it.unibo.BLSJavaFP.Pure.Data.Led;

import static it.unibo.BLSJavaFP.Pure.Behaviour.LedBehaviour.show;

/**
 * Created by benkio on 10/19/16.
 */
public class LoggerBehaviour {

    public static P2<Led,String> logLed(Led l, String m){
        return p(l, m + " led status: " + show(l));
    }
}
