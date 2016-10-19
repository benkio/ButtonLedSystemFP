package it.unibo.BLSJavaFP.EffectFull;

import fj.F;
import static fj.P.p;
import fj.P2;
import fj.Unit;
import fj.data.IO;
import fj.data.IOFunctions;
import fj.data.State;
import static it.unibo.BLSJavaFP.EffectFull.Console.ledStateMachine;
import static it.unibo.BLSJavaFP.Pure.Behaviour.LedBehaviour.ledNextState;
import static it.unibo.BLSJavaFP.Pure.Behaviour.LoggerBehaviour.logLed;
import it.unibo.BLSJavaFP.Pure.Data.Led;
import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
   
public class Console {
    
    final static IO<Boolean> askPress = () -> {
        BufferedReader br = new BufferedReader(new InputStreamReader(System.in));
        System.out.println("premi x per terminare o un tasto qualsiasi per cambiare lo stato del led");
        String response = null;
        try {
            response = br.readLine();
        } catch (IOException e) {
        }
        return response.equals("x");
    };

    final static F<String,IO<Unit>> showLog = (String l) -> {
        System.out.println(l);
        return IOFunctions.ioUnit;
    };
          
    public static State<Led,Led> ledStateMachine() {
        F<Led,P2<Led,Led>> fun = s -> {
            State<Led,Led> l = State.<Led>init();
            boolean b = false;
            try {
                b = askPress.run();
            }catch (IOException e){
            }
            if (b){
                return l.run(s);
            }else{
                P2<Led,Led> lnext = ledNextState().run(s);
                P2<Led,String> lnextLogged = logLed(lnext._2(), "Led Status Changed: ");
                showLog.f(lnextLogged._2());
                return ledStateMachine().run(lnext._2());
            }
        };
        return State.unit(fun);
    }
}
