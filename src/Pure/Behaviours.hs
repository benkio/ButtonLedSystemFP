{-# LANGUAGE DeriveGeneric              #-} -- Allows Generic, for auto-generation of serialization code
module Pure.Behaviours where

import Control.Concurrent.MVar
import Control.Monad.Writer.Lazy
import GHC.Generics (Generic) -- For auto-derivation of serialization
import Data.Typeable (Typeable) -- For safe serialization
import Data.Binary (Binary) -- Objects have to be binary to send over the network
import Pure.Data
import Control.Distributed.Process
import Data.List

-- Led Domain Model Behaviours

switch :: Led -> Led
switch Led{status=l} = Led{status=not l}

getLedStatus :: Led -> Bool
getLedStatus Led{status=s} = s

initialLedStatus :: Led
initialLedStatus = Led{status=False}

{- Logger Domain Model Behaviours -}

logBLS :: Monad m => a -> String -> m (a,String) -- WriterT String m a
logBLS a s = runWriterT $ tell ("Log message: " ++ s ++ "\n") >> return a

{- Observer Pattern - Button Domain Model Behaviours -}

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

nodeStateBuilder :: [ProcessId] -> NodeType -> NodeState
nodeStateBuilder addr ButtonNT = ButtonServerState{_observers=addr}
nodeStateBuilder _ LedNT = LedServerState{_ledStatus=Led{status=False}}
nodeStateBuilder _ (NT LogNT) = LogServerState{_logMsg=""}
nodeStateBuilder (x:y:z) ControlNT = if ((null (tail z)) && (not (null z))) then ControlServerState{_led=x, _logger=y, _button=(head z)} else error "cannot bulidthe node state"
nodeStateBuilder _ _ = error "cannot build the node state"

nodeConfigBuilder :: ProcessId -> NodeConfig
nodeConfigBuilder i = NodeConfig{myId=i}
