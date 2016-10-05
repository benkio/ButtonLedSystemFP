import Test.Hspec
import Test.QuickCheck
import Control.Exception (evaluate)
import DomainModel
import Numeric.Natural

main :: IO ()
main = hspec $ do
  describe "Switch function" $ do
    it "return the input after even calls, the inverse otherwise" $ property $
      switchProperty

applyNTimes :: (Enum b, Num b) => b -> (a -> a) -> a -> a
applyNTimes n f val = foldl (\s e -> e s) val [f | x <- [1..n]]

switchProperty :: Bool -> Natural -> Bool
switchProperty x y = if (y `mod` 2 == 0)
                     then getLedStatus (applyNTimes y switch l) == (getLedStatus l)
                     else getLedStatus (applyNTimes y switch l) == not (getLedStatus l)
                          where l = Led{status=x}
