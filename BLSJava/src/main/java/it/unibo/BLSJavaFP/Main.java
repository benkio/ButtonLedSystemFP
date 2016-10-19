package it.unibo.BLSJavaFP;

import it.unibo.BLSJavaFP.EffectFull.Console;
import static it.unibo.BLSJavaFP.Pure.Behaviour.LedBehaviour.initialLedStatus;


public class Main {

    public static void main(String[] args){
        Console.ledStateMachine().run(initialLedStatus());
    }
    
   /* public static void main(String[] args) {
	    IOMonad<Unit> main = new IOMonad<Unit>(x -> {
            ledStateMachine().runState.apply(initialLedStatus());
            return Unit.VALUE;
        });
        main.action.apply(Unit.VALUE);
    }

    private static StateMonad<Led,Led> ledStateMachine(){
        return new StateMonad<Led,Led>(l -> {
            StateTuple<Led,Led> l1 = StateMonad.<Led>get().runState.apply(l);
            IOMonad<Boolean> waitToPressIO = new IOMonad<Boolean>(x -> {
                BufferedReader br = new BufferedReader(new InputStreamReader(System.in));
                System.out.println("premi x per terminare o un tasto qualsiasi per cambiare lo stato del led");
                String response = null;
                try {
                    response = br.readLine();
                } catch (IOException e) {
                    e.printStackTrace();
                }
                if (response.equals("x")) return true; else return false;
            });
            if (waitToPressIO.action.apply(Unit.VALUE)){
                return l1;
            }else{
                Led lnewState = ledNextState().runState.apply(l).value;
                Tuple<Led,String> t = logLed(lnewState, "Led Status Changed");
                IOMonad<Unit> logIO = new IOMonad<Unit>(x -> {
                    System.out.println(t._2);
                    return Unit.VALUE;
                });
                logIO.action.apply(Unit.VALUE);
                return ledStateMachine().runState.apply(lnewState);
            }
        });
    }
    */
}
