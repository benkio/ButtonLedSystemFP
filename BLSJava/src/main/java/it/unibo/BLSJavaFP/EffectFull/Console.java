package it.unibo.BLSJavaFP.EffectFull;

import fj.F;
import fj.Unit;
import fj.data.IO;
import fj.data.IOFunctions;
import fj.data.List;
import static it.unibo.BLSJavaFP.Pure.Behaviour.LedBehaviour.initialLedStatus;
import static it.unibo.BLSJavaFP.Pure.Behaviour.LedBehaviour.ledNextState;
import it.unibo.BLSJavaFP.Pure.Data.Led;
import it.unibo.BLSJavaFP.Pure.Data.Observer;
import it.unibo.BLSJavaFP.Pure.Data.Subject;
import it.unibo.BLSJavaFP.Pure.MVar;
import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
   
public class Console {
    
    public final static IO<Boolean> askPress = () -> {
        BufferedReader br = new BufferedReader(new InputStreamReader(System.in));
        System.out.println("premi x per terminare o un tasto qualsiasi per cambiare lo stato del led");
        String response = null;
        try {
            response = br.readLine();
        } catch (IOException e) {
        }
        return response.equals("x");
    };

    public final static F<String,IO<Unit>> showLog = (String l) -> {
        System.out.println(l);
        return IOFunctions.ioUnit;
    };
}
