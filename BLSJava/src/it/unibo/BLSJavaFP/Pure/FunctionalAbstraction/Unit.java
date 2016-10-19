package it.unibo.BLSJavaFP.Pure.FunctionalAbstraction;

/**
 * Copied here: https://dzone.com/articles/do-it-in-java-8-state-monad
 */
public final class Unit {
    public static final Unit VALUE = new Unit();
    private Unit() {}
}