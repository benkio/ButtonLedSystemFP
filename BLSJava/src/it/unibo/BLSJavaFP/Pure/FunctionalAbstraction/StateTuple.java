package it.unibo.BLSJavaFP.Pure.FunctionalAbstraction;

import java.util.Objects;

/**
 * Copied here: https://dzone.com/articles/do-it-in-java-8-state-monad
 */
public class StateTuple<A, S> {

    public final A value;
    public final S state;

    public StateTuple(A a, S s) {
        value = Objects.requireNonNull(a);
        state = Objects.requireNonNull(s);
    }
}