package it.unibo.BLSJavaFP.Pure.FunctionalAbstraction;

/** This type represents an action, yielding type R */
@FunctionalInterface
interface IO<R> {

    /** Warning! May have arbitrary side-effects! */
    R unsafePerformIO();

}