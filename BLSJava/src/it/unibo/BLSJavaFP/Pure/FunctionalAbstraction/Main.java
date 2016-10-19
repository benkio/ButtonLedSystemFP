package it.unibo.BLSJavaFP.Pure.FunctionalAbstraction;

import static it.unibo.BLSJavaFP.Pure.FunctionalAbstraction.ConsoleIO.getLine;
import static it.unibo.BLSJavaFP.Pure.FunctionalAbstraction.ConsoleIO.putStrLn;
import static it.unibo.BLSJavaFP.Pure.FunctionalAbstraction.IOMonad.bind;

/** The program composed out of IO actions in a purely functional manner. */
interface Main {

    // -- Main$

    /** A variant of bind, which discards the bound value. */
    static IO<Unit> bind_(final IO<Unit> a, final IO<Unit> b) {
        return bind(a, arg -> b);
    }

    /**
     * The greeting action -- asks the user for his name and then prints
     * greeting
     */
    final static IO<Unit> greet = bind_(putStrLn("Enter your name:"),
            bind(getLine, arg -> putStrLn("Hello, " + arg + "!")));

    /** A simple echo action -- reads a line, prints it back */
    final static IO<Unit> echo = bind(getLine, putStrLn);

    /**
     * A function taking some action and producing the same action run repeatedly
     * forever (modulo stack overflow :D)
     */
    static IO<Unit> loop(final IO<Unit> action) {
        return bind(action, arg -> loop(action));
    }

    /** The action corresponding to the whole program */
    final static IO<Unit> main = bind_(greet, bind_(putStrLn("Entering the echo loop."), loop(echo)));

}