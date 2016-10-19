{-# LANGUAGE DeriveGeneric              #-} -- Allows Generic, for auto-generation of serialization code
module Pure.Behaviours where

import Control.Monad.Writer.Lazy
import Pure.Data
import Control.Distributed.Process
import Control.Monad.State.Lazy

-- Led Domain Model Behaviours

switch :: Led -> Led
switch Led{on=l} = Led{on=not l}

getLedStatus :: Led -> Bool
getLedStatus Led{on=s} = s

initialLedStatus :: Led
initialLedStatus = Led{on=False}

ledNextState :: State Led Led
ledNextState = do l <- get
                  put (switch l)
                  return l

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

notify :: Monad m => Subject m a -> m [a]
notify (Subject _ []) = return []
notify (Subject x (f:fs)) = case f of
                              StatelessObs g -> do
                                g x
                                notify $ Subject x fs
                              StatefullObs g -> do
                                y <- g x
                                ys <-(notify (Subject x fs))
                                return $ y:ys

nodeStateBuilder :: [ProcessId] -> NodeType -> NodeState
nodeStateBuilder addr ButtonNT     = ButtonServerState{_observers=addr}
nodeStateBuilder _ LedNT           = LedServerState{_ledStatus=Led{on=False}}
nodeStateBuilder _ (NT LogNT)      = LogServerState{_logMsg=""}
nodeStateBuilder (x:y:z) ControlNT = if ((null (tail z)) && (not (null z))) then ControlServerState{_led=x, _logger=y, _button=(head z)} else error "cannot bulid the node state"
nodeStateBuilder _ _               = error "cannot build the node state"

nodeConfigBuilder :: ProcessId -> NodeConfig
nodeConfigBuilder i = NodeConfig{myId=i}
