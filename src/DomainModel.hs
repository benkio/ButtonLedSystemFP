module DomainModel where

data Led = Led{status :: Bool}

switch :: Led -> Led
switch Led{status=l} = Led{status=not l}

getLedStatus :: Led -> Bool
getLedStatus Led{status=s} = s
{- Logger Domain Model -}

log :: String -> IO()
log s = putStrLn s

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
