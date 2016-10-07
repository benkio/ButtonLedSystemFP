{-# LANGUAGE DeriveGeneric              #-} -- Allows Generic, for auto-generation of serialization code
module DomainModel.Core where

import Control.Concurrent.MVar
import Control.Monad.Writer.Lazy
import GHC.Generics (Generic) -- For auto-derivation of serialization
import Data.Typeable (Typeable) -- For safe serialization

data Led = Led{status :: Bool} deriving (Show, Generic, Typeable)

switch :: Led -> Led
switch Led{status=l} = Led{status=not l}

getLedStatus :: Led -> Bool
getLedStatus Led{status=s} = s

initialLedStatus :: Led
initialLedStatus = Led{status=False}

{- Logger Domain Model -}

logBLS :: Monad m => a -> String -> m (a,String) -- WriterT String m a
logBLS a s = runWriterT $ tell ("Log message: " ++ s ++ "\n") >> return a

{- Observer Pattern - Button Model -}

type Observer m a = a -> m()
data Subject m a = Subject a ([Observer m a])

setSubject :: Monad m => Subject m a -> a -> m (Subject m a)
setSubject (Subject _ xs) b = return $ Subject b xs

getSubject :: Monad m => Subject m a -> m a
getSubject (Subject a _) = return a

addObserver :: Monad m => Subject m a -> Observer m a -> m (Subject m a)
addObserver (Subject a xs) o = return (Subject a (xs++[o]))

notify :: Monad m => Subject m a -> m ()
notify (Subject x []) = return ()
notify (Subject x (f:fs)) = do f x
                               notify $ Subject x fs
