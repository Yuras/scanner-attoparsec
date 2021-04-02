
module Scanner.Attoparsec
( atto
, toAtto
)
where

import qualified Scanner
import Scanner.Internal (Scanner (Scanner))

import Data.Maybe
import qualified Data.ByteString as ByteString
import qualified Data.Attoparsec.ByteString as Atto

{-# INLINE atto #-}
-- | Convert attoparsec parser into a scanner
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

-- | Convert scanner to attoparsec parser
--
-- @since 0.2
toAtto :: Scanner a -> Atto.Parser a
toAtto s = go (Scanner.scan s)
  where
  go run = do
    chunk <- fromMaybe ByteString.empty <$> Atto.getChunk
    case run chunk of
      Scanner.Done bs r -> do
        _ <- Atto.take (ByteString.length chunk - ByteString.length bs)
        return r
      Scanner.Fail bs msg -> do
        _ <- Atto.take (ByteString.length chunk - ByteString.length bs)
        fail msg
      Scanner.More next -> do
        _ <- Atto.take (ByteString.length chunk)
        go next
