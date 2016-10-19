package it.unibo.BLSJavaFP.Pure.FunctionalAbstraction;

/**
 * Copied from here: http://stackoverflow.com/questions/6647852/haskell-actual-io-monad-implementation-in-different-language
 */
import java.util.function.Function;

/**
 * This, internally impure, provides pure interface for action sequencing (aka
 * Monad)
 */
interface IOMonad {

    // -- IOMonad$

    static <T> IO<T> pure(final T value) {
        return () -> value;
    }

    static <T> IO<T> join(final IO<IO<T>> action) {
        return () -> action.unsafePerformIO().unsafePerformIO();
    }

    static <A, B> IO<B> fmap(final Function<A, B> func, final IO<A> action) {
        return () -> func.apply(action.unsafePerformIO());
    }

    static <A, B> IO<B> bind(IO<A> action, Function<A, IO<B>> func) {
        return join(fmap(func, action));
    }

}