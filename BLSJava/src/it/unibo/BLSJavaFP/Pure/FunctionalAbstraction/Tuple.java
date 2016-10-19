package it.unibo.BLSJavaFP.Pure.FunctionalAbstraction;

/**
 * Copied here: https://dzone.com/articles/do-it-in-java-8-state-monad
 */
public class Tuple<A, B> {

    public final A _1;
    public final B _2;

    public Tuple(A a, B b) {
        _1 = a;
        _2 = b;
    }
}