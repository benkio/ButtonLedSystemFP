package it.unibo.BLSJavaFP.Pure.FunctionalAbstraction;

import java.util.function.Function;

/**
 * Created by benkio on 10/19/16.
 */
public class IOMonad<T>{

    public final Function<Unit, T> action;

    public IOMonad(Function<Unit, T> action) {
        this.action = action;
    }

    static <T> IOMonad<T> pure(final T value) {
        return new IOMonad(x -> value);
    }

    T unsafePerformIO(){
        return action.apply(Unit.VALUE);
    }

    public <K> IOMonad<K> bind(Function<T, IOMonad<K>> f) {
        return f.apply(unsafePerformIO());
    }
}
