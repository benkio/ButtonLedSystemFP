/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package it.unibo.BLSJavaFP.Pure.Behaviour;

import fj.data.IO;
import fj.data.IOFunctions;
import fj.data.List;
import it.unibo.BLSJavaFP.Pure.Data.Observer;
import it.unibo.BLSJavaFP.Pure.Data.Subject;
import java.io.IOException;

/**
 *
 * @author benkio
 */
public class ButtonBehaviour {

    public static <T> Subject<T> setSubject(Subject<T> s, T a) {
        return new Subject<>(a, s.getObs());
    }

    public static <T> Subject<T> addObserver(Subject<T> s, Observer<T> o) {
        return new Subject(s.getSub(), s.getObs().cons(o));
    }
}
