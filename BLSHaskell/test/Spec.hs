import Test.Hspec
import Test.QuickCheck
import Control.Exception (evaluate)
import DomainModel.Core
import Numeric.Natural
import Data.Functor.Identity

main :: IO ()
main = hspec $ do
  describe "Switch function" $ do
    it "return the input after even calls, the inverse otherwise" $ property $
      switchProperty
  describe "log Function" $ do
    it "return the input plus the log message" $ property $ do
      logProperty

applyNTimes :: (Enum b, Num b) => b -> (a -> a) -> a -> a
applyNTimes n f val = foldl (\s e -> e s) val [f | x <- [1..n]]

switchProperty :: Bool -> Natural -> Bool
switchProperty x y = if (y `mod` 2 == 0)
                     then getLedStatus (applyNTimes y switch l) == (getLedStatus l)
                     else getLedStatus (applyNTimes y switch l) == not (getLedStatus l)
                          where l = Led{status=x}

logProperty :: Int -> String -> Bool
logProperty a b = runIdentity $ logBLS a b >>= \(l,label) -> return $ label == ("Log message: " ++ b ++ "\n") && l == a
