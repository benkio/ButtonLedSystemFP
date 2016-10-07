{-# LANGUAGE GeneralizedNewtypeDeriving #-} -- Allows automatic derivation of e.g. Monad
{-# LANGUAGE DeriveGeneric              #-} -- Allows Generic, for auto-generation of serialization code
{-# LANGUAGE TemplateHaskell            #-} -- Allows automatic creation of Lenses for ServerState

module DomainModel.MessageBSL where

-- based on the code here: https://github.com/wyager/Example-Distributed-App/blob/master/Distributed.hs
-- here the description of that code: http://yager.io/Distributed/Distributed.html

import Data.Binary
import Data.Typeable
import Control.Distributed.Process
import Data.Binary (Binary) -- Objects have to be binary to send over the network
import GHC.Generics (Generic) -- For auto-derivation of serialization
import Data.Typeable (Typeable) -- For safe serialization
import Control.Lens
import Control.Monad.RWS.Strict
import DomainModel.Core

data MessageContent = NotifyPush
                    | ButtonPressed
                    | LedSwitch
                    | LedStatus
                    | LedStatusChanged  Led
                    | RemoveObserver
                    | RegisterObserver
                    deriving (Typeable, Generic, Show)

data Envelop = Envelop {senderOf :: ProcessId, recipientOf :: ProcessId, msg :: MessageContent}
               deriving (Show, Generic, Typeable)


instance Binary MessageContent
instance Binary Envelop

data NodeState = ButtonServerState { _observers :: [ProcessId] }
                 | LedServerState { _ledStatus :: Led }
                 | LogServerState { _logMsg :: String }
                 | ControlServerState {_led :: ProcessId, _logger :: ProcessId}
                 deriving (Show)
makeLenses ''NodeState

data NodeConfig = NodeConfig{myId :: ProcessId}

newtype ServerAction a = ServerAction {runAction :: RWS NodeConfig [Envelop] NodeState a}
    deriving (Functor, Applicative, Monad, MonadState NodeState, MonadWriter [Envelop], MonadReader NodeConfig)
{-
instance Binary (MessageBSL) where
  put (NotifyPush         p)       = putWord8 1 >> put p
  put (ButtonPressed      p)       = putWord8 2 >> put p
  put (Switch             p)       = putWord8 3 >> put p
  put (LedStatus          p)       = putWord8 4 >> put p
  put (LedStatusChanged  p l)      = put (5 :: Word8) >> put p >> put l
  put (RemoveObserver    p o)      = put (6 :: Word8) >> put p >> put o
  put (RegisterObserver  p o)      = put (7 :: Word8) >> put p >> put o
  put (Log               p s)      = put (8 :: Word8) >> put p >> put s
  get                            = do t <- get :: Get Word8
                                      p <- get :: Get (SendPort MessageBSL)
                                      case t of
                                           1 -> return (NotifyPush p)
                                           2 -> return (ButtonPressed p)
                                           3 -> return (Switch p)
                                           4 -> return (LedStatus p)
                                           5 -> get >>= (\l -> return (LedStatusChanged p l))
                                           6 -> get >>= (\o -> return (RemoveObserver   p o))
                                           7 -> get >>= (\o -> return (RegisterObserver p o))
                                           8 -> get >>= (\s -> return (Log p s))

getSendPort :: MessageBSL -> SendPort MessageBSL
getSendPort (NotifyPush       p)   = p
getSendPort (ButtonPressed    p)   = p
getSendPort (Switch           p)   = p
getSendPort (LedStatus        p)   = p
getSendPort (LedStatusChanged p _) = p
getSendPort (RemoveObserver   p _) = p
getSendPort (RegisterObserver p _) = p
getSendPort (Log              p _) = p
-}
