package it.unibo.BLSJavaFP.Pure.FunctionalAbstraction;

import java.util.function.Function;

/**
 * Copied from: https://dzone.com/articles/do-it-in-java-8-state-monad
 */
public class StateMonad<S, A> {

    public final Function<S, StateTuple<A, S>> runState;

    public StateMonad(Function<S, StateTuple<A, S>> runState) {
        this.runState = runState;
    }

    public static <S, A> StateMonad<S, A> unit(A a) {
        return new StateMonad<>(s -> new StateTuple<>(a, s));
    }

    public static <S> StateMonad<S, S> get() {
        return new StateMonad<>(s -> new StateTuple<>(s, s));
    }

    public static <S, A> StateMonad<S, A> getState(Function<S, A> f) {
        return new StateMonad<>(s -> new StateTuple<>(f.apply(s), s));
    }

    public static <S> StateMonad<S, Unit> transition(Function<S, S> f) {
        return new StateMonad<>(s -> new StateTuple<>(Unit.VALUE, f.apply(s)));
    }

    public static <S, A> StateMonad<S, A> transition(Function<S, S> f, A value) {
        return new StateMonad<>(s -> new StateTuple<>(value, f.apply(s)));
    }

    public static <S, A> StateMonad<S, List<A>> compose(List<StateMonad<S, A>> fs) {
        return fs.foldRight(StateMonad.unit(List.<A>empty()), f -> acc -> f.map2(acc, a -> b -> b.cons(a)));
    }

    public <B> StateMonad<S, B> flatMap(Function<A, StateMonad<S, B>> f) {
        return new StateMonad<>(s -> {
            StateTuple<A, S> temp = runState.apply(s);
            return f.apply(temp.value).runState.apply(temp.state);
        });
    }

    public <B> StateMonad<S, B> map(Function<A, B> f) {
        return flatMap(a -> StateMonad.unit(f.apply(a)));
    }

    public <B, C> StateMonad<S, C> map2(StateMonad<S, B> sb, Function<A, Function<B, C>> f) {
        return flatMap(a -> sb.map(b -> f.apply(a).apply(b)));
    }

    public A eval(S s) {
        return runState.apply(s).value;
    }

}