package it.unibo.BLSJavaFP.EffectFull;

import fj.F;
import fj.P2;
import fj.Unit;
import fj.data.IO;
import fj.data.IOFunctions;
import fj.data.List;
import fj.data.State;
import static it.unibo.BLSJavaFP.EffectFull.Console.ledStateMachine;
import static it.unibo.BLSJavaFP.Pure.Behaviour.LedBehaviour.initialLedStatus;
import static it.unibo.BLSJavaFP.Pure.Behaviour.LedBehaviour.ledNextState;
import static it.unibo.BLSJavaFP.Pure.Behaviour.LoggerBehaviour.logLed;
import it.unibo.BLSJavaFP.Pure.Data.Led;
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
    
    public final static IO<Unit> graphicMain = () -> {
        MVar status = MVar.withDefault(initialLedStatus());
        BLSSwing.btn.addActionListener(e -> {
            String ledMessage = "";
            try {
                ledMessage = (String) mVarObserver(status).run();
            }catch (IOException f) {}
            BLSSwing.ledLabel.setText(ledMessage);
        });
        BLSSwing.main();
        return Unit.unit();
    };
            
    public static IO<String> mVarObserver(MVar<Led> ml) {
        try{
            Led l = ml.take();
            Led lnext = ledNextState().eval(l);
            ml.put(lnext);
            String ledMessage;
            if (lnext.on)
                ledMessage = "on";
            else 
                ledMessage = "off";
            return IOFunctions.<String>unit(ledMessage);
        }catch (InterruptedException e){
            return IOFunctions.unit("error");
        }
    }          
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
    
    public static <T> IO<Unit> ledStateMachine1(Subject<T> s) throws IOException {
        boolean b = askPress.run();
        if(b) return IOFunctions.ioUnit;
        else{
            List<T> l = Subject.notify(s).run();
            Subject<T> s1 = Subject.setSubject(s, l.head());
            return ledStateMachine1(s1);
        }
    }
}
