/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package it.unibo.BLSJavaFP.Pure.Data;

import fj.data.IO;
import fj.data.IOFunctions;
import fj.data.List;
import java.io.IOException;

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
    
    public static <T> Subject<T> setSubject(Subject<T> s, T a){
        return new Subject<T>(a, s.obs);
    }
    
    public static <T> T getSubject(Subject<T> s){
        return s.sub;
    }
    
    public static <T> Subject<T> addObserver(Subject<T> s, Observer<T> o){
        return new Subject(s.sub, s.obs.cons(o));
    }
    
    public static <T> IO<List<T>> notify(Subject<T> s) throws IOException{
        if (s.obs.isEmpty()) return IOFunctions.unit(List.nil());
        else{
            Observer<T> o = s.obs.head();
            if (o.func.isLeft()){
                o.func.left().value().f(s.sub);
                return notify(new Subject(s.sub, s.obs.tail()));
            }else{
                T x = o.func.right().value().f(s.sub).run();
                List<T> xs = (List<T>) notify(new Subject(s.sub, s.obs.tail())).run();
                return IOFunctions.unit(List.cons(x, xs));
            }
        }
    }       
}