/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package it.unibo.BLSJavaFP.Pure.Data;

import fj.data.List;

/**
 *
 * @author benkio
 */
public class Subject<T> {
    private final T sub;
    private final List<Observer<T>> obs;
    
    public Subject(T s, List<Observer<T>> obs){
        this.sub = s;
        this.obs = obs;
    }
    
    public T getSub(){ return sub; }
    public List<Observer<T>> getObs(){ return obs; }
}