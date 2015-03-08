{-# LANGUAGE BangPatterns #-}
{-# LANGUAGE ForeignFunctionInterface #-}
import Numeric.LinearAlgebra.HMatrix
import Criterion
import Criterion.Main
import qualified Data.Array.Repa as R
import Data.Array.Repa (Z(..), fromFunction, fromListUnboxed)
import Foreign.C.Types
import qualified Data.Vector as V
import Control.Applicative
import Control.Parallel.Strategies
import Control.Monad (forever)

foreign import ccall unsafe "cppAdditionImpl" cppAdditionImpl :: CInt -> IO ()


-- C++
{-# INLINE cppAddition #-}
cppAddition :: Int -> IO ()
cppAddition = cppAdditionImpl . CInt . fromIntegral 
-- HMatrix:
hMatrixAddition :: Int -> Vector Double
hMatrixAddition size = let myvec = vector [1.. fromIntegral size]
                in myvec + myvec
                   

-- Repa:
{-# INLINE repaAddition #-}

repaAddition :: Int -> R.Array R.D R.DIM1 Double
repaAddition !size =
  let
      myvec = fromListUnboxed (Z R.:. size) [1.. fromIntegral size] :: R.Array R.U R.DIM1 Double
  in R.zipWith (+) myvec myvec



{-# INLINE sRepaAddition #-}
sRepaAddition :: Int -> R.Array R.U R.DIM1 Double
sRepaAddition size =
    let
        result = R.computeS . repaAddition $ size
    in         
      R.deepSeqArray result result

{-# INLINE pRepaAddition #-}
pRepaAddition :: Int -> IO (R.Array R.U R.DIM1 Double)
pRepaAddition !size = R.computeP . repaAddition $ size


-- vector:
vectorAddition :: Int -> V.Vector Double
vectorAddition size =
    let
        myvec = V.generate size fromIntegral
    in
      V.zipWith (+) myvec myvec

vectorAdditionPar :: Int -> V.Vector Double
vectorAdditionPar size =
    let
        splitAt = size `div` 2
        myvec = V.generate size fromIntegral
        (part1, part2) = V.splitAt splitAt myvec
        (result1, result2) = runEval $ 
                             (,)
                             <$> (rpar $ V.zipWith (+) part1 part1)
                             <*> (rseq $ V.zipWith (+) part2 part2)
    in
        result1 V.++ result2


--
dataPoints !n = n : dataPoints (n*10)


--

benchGroup size = bgroup (show size) [
                   --bench "Haskell HMatrix" $ nf hMatrixAddition size
                   bench "Haskell Vector seq" $  nf vectorAddition size
                   --, bench "Haskell Vector par" $  whnf vectorAdditionPar size
                   --, bench "Haskell Repa seq" $ whnf sRepaAddition size
                   --, bench "Haskell Repa par" $  whnfIO $ pRepaAddition size
                   , bench "C++ ViennaCL" $  whnfIO $ cppAddition size
                  ]
           

main :: IO ()
main = defaultMain . map benchGroup . take 5 . dataPoints $ 100
{--
main = do
  --forever $ print $ (vectorAddition 10000000) V.! 9999999
  forever $ cppAddition 10000000
  print $ sRepaAddition 10
  pRepaAddition 10 >>= print
  

--}
