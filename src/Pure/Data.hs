{-# LANGUAGE GeneralizedNewtypeDeriving #-} -- Allows automatic derivation of e.g. Monad
{-# LANGUAGE DeriveGeneric              #-} -- Allows Generic, for auto-generation of serialization code
{-# LANGUAGE TemplateHaskell            #-} -- Allows automatic creation of Lenses for ServerState

module Pure.Data where

-- based on the code here: https://github.com/wyager/Example-Distributed-App/blob/master/Distributed.hs
-- here the description of that code: http://yager.io/Distributed/Distributed.html

import Control.Distributed.Process
import Data.Binary (Binary) -- Objects have to be binary to send over the network
import GHC.Generics (Generic) -- For auto-derivation of serialization
import Data.Typeable (Typeable) -- For safe serialization
import Control.Lens
import Control.Monad.RWS.Strict

data NodeType           = ButtonNT | LedNT | ControlNT | NT ReceiveOnlyNT | NT' SendOnlyNT deriving Show
data ReceiveOnlyNT      = LogNT deriving Show
data SendOnlyNT         = PressButtonNT deriving Show

-- Button and Led Data

data Led = Led{status :: Bool} deriving (Show, Generic, Typeable)

type Observer m a = a -> m()
data Subject m a = Subject a ([Observer m a])

--Messages and data in distribuited context

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

-- Server Data

data NodeState = ButtonServerState { _observers :: [ProcessId] }
                 | LedServerState { _ledStatus :: Led }
                 | LogServerState { _logMsg :: String }
                 | ControlServerState {_led :: ProcessId, _logger :: ProcessId, _button :: ProcessId}
                 deriving (Show)
makeLenses ''NodeState

data NodeConfig = NodeConfig{myId :: ProcessId}

newtype ServerAction a = ServerAction {runAction :: RWS NodeConfig [Envelop] NodeState a}
    deriving (Functor, Applicative, Monad, MonadState NodeState, MonadWriter [Envelop], MonadReader NodeConfig)

-- Binary Instances for network sending

instance Binary MessageContent
instance Binary Envelop
instance Binary Led
