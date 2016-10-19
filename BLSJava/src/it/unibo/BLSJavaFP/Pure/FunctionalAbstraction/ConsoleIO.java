package it.unibo.BLSJavaFP.Pure.FunctionalAbstraction;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.function.Function;

/**
 * This, internally impure, provides pure interface for interaction with stdin
 * and stdout
 */
interface ConsoleIO {

    // -- ConsoleIO$

    static IO<Unit> putStrLn(final String line) {
        return () -> {
            System.out.println(line);
            return Unit.VALUE;
        };
    };

    final static Function<String, IO<Unit>> putStrLn = arg -> putStrLn(arg);

    final static BufferedReader in = new BufferedReader(new InputStreamReader(System.in));

    static IO<String> getLine = () -> {
        try {
            return in.readLine();
        }

        catch (IOException e) {
            throw new RuntimeException(e);
        }
    };

}