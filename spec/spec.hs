{-# LANGUAGE OverloadedStrings #-}

module Main
( main
)
where

import Scanner
import Scanner.Attoparsec

import Data.Either
import Data.ByteString (ByteString)
import qualified Data.ByteString.Lazy as Lazy.ByteString
import qualified Data.Attoparsec.ByteString as Atto
import Control.Applicative
import Control.Monad

import Test.Hspec

main :: IO ()
main = hspec $ do
  attoSpec

attoSpec :: Spec
attoSpec = describe "atto" $ do
  it "should apply attoparsec parser" $ do
    let bs = "+hello"
    scanOnly p bs `shouldBe` Right "hello"

  it "should backtrack" $ do
    let bs = "-hell"
    scanOnly p bs `shouldBe` Right "hell"

  it "should consume input" $ do
    let bs = "-hello"
    scanOnly (p *> anyChar8) bs `shouldBe` Right 'o'

  it "should fail on invalid input" $ do
    let bs = "!hello"
    scanOnly (p *> anyChar8) bs `shouldSatisfy` isLeft

  it "should ask for more input" $ do
    let bs = Lazy.ByteString.fromChunks
          [ "+"
          , "he"
          , "ll"
          , "o world"
          ]
    scanLazy p bs `shouldBe` Right "hello"

p :: Scanner ByteString
p = atto $ plusP <|> minusP

plusP :: Atto.Parser ByteString
plusP = do
  void $ Atto.string "+"
  Atto.take 5

minusP :: Atto.Parser ByteString
minusP = do
  void $ Atto.string "-"
  Atto.take 4
