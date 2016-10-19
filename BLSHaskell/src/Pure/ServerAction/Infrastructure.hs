module Pure.ServerAction.Infrastructure where

import Pure.Data
import Control.Distributed.Process
import Control.Monad.RWS.Strict

sendTo :: ProcessId -> MessageContent -> ServerAction ()
sendTo recipient content = do
    NodeConfig mId <- ask
    tell [Envelop mId recipient content]
