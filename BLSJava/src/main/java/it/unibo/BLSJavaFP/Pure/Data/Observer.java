/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package it.unibo.BLSJavaFP.Pure.Data;

import fj.F;
import fj.Unit;
import fj.data.Either;
import fj.data.IO;

/**
 *
 * @author benkio
 */
public class Observer<T> {
    public Either<F<T,IO<Unit>>,F<T,IO<T>>> func;
    
    private void setFuncUnit(F<T,IO<Unit>> f){
        func = Either.left(f);
    }
    
    private void setFuncT(F<T,IO<T>> f){
        func = Either.right(f);
    }
    
    public static <T> Observer<T> statelessObs(F<T,IO<Unit>> f){
        Observer<T> obs = new Observer();
        obs.setFuncUnit(f);
        return obs;
    }
    
    public static <T> Observer<T> stateFullObs(F<T,IO<T>> f){
        Observer<T> obs = new Observer();
        obs.setFuncT(f);
        return obs;
    }
}
