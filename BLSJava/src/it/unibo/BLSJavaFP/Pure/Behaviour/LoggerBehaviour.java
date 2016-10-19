package it.unibo.BLSJavaFP.Pure.Behaviour;

import it.unibo.BLSJavaFP.Pure.Data.Led;
import it.unibo.BLSJavaFP.Pure.FunctionalAbstraction.Tuple;

import static it.unibo.BLSJavaFP.Pure.Behaviour.LedBehaviour.getLedStatus;
import static it.unibo.BLSJavaFP.Pure.Behaviour.LedBehaviour.show;

/**
 * Created by benkio on 10/19/16.
 */
public class LoggerBehaviour {

    public static Tuple<Led,String> logLed(Led l, String m){
        return new Tuple<Led,String>(l, m + " led status: " + show(l));
    }
}
