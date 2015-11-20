import Development.Shake
import Development.Shake.Command
import Development.Shake.FilePath
import Development.Shake.Util
import System.FilePath.Glob
import Text.Regex
import Data.List

compactMacro :: String -> IO String
compactMacro x = do
  f <- readFile x
  let subbed = subRegex (mkRegex "\n") f "" -- `wow' for testing purposes
  return subbed

mdify :: String -> String
mdify fileName = fileName -<.> "md"
gppC :: String -> String
gppC file = "gpp -H -x -DTEX=1 -Igpp/ " ++ file

main :: IO ()
main = shakeArgs shakeOptions{shakeFiles="_build", shakeProgress = progressSimple} $ do
    "//*.pdf" %> \out -> do
      putNormal $ "Building " ++ out
      need ["gpp/tex.gppb"]
      need [out -<.> "md"]
      Stdout processed <- cmd (gppC $ mdify out)
      cmd (Stdin processed) ("pandoc -f markdown " ++ "-t " ++ "latex " ++ "-o " ++ out ++ " " ++ mdify out) :: Action ()
      putNormal $ "Done " ++ out


    "gpp/*.gppb" %> \out -> do
        putNormal $ "Compacting " ++ out
        cont <- liftIO (compactMacro (out -<.> "gpp"))
        writeFile' out cont
