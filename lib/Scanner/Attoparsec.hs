
module Scanner.Attoparsec
( atto
)
where

import qualified Scanner
import Scanner.Internal (Scanner (Scanner))

import qualified Data.Attoparsec.ByteString as Atto

{-# INLINE atto #-}
atto :: Atto.Parser a -> Scanner a
atto p = Scanner $ \bs next ->
  case Atto.parse p bs of
    Atto.Done bs' r -> next bs' r
    Atto.Fail bs' _ err -> Scanner.Fail bs' err
    Atto.Partial cont -> slowPath cont next
  where
  slowPath cont next = Scanner.More $ \bs ->
    case cont bs of
      Atto.Done bs' r -> next bs' r
      Atto.Fail bs' _ err -> Scanner.Fail bs' err
      Atto.Partial cont' -> slowPath cont' next
