import Development.Shake
import Development.Shake.Command
import Development.Shake.FilePath
import Development.Shake.Util
import Text.Regex
import Data.List

compactMacro :: String -> IO String
compactMacro x = do
  f <- readFile x
  let subbed = subRegex (mkRegex "\n") f ""
  return subbed

mdify :: String -> String
mdify fileName = fileName -<.> "md"
gppC :: String -> String
gppC file = "gpp -H -x -DTEX=1 -Igpp/ " ++ file

main :: IO ()
main = shakeArgs shakeOptions{shakeFiles="build", shakeProgress = progressSimple} $ do
    "//*.pdf" %> \out -> do
      putNormal $ "Building " ++ out
      need ["build/" ++ out -<.> "tex"]
      cmd (Cwd "build/") ("xelatex -shell-escape " ++ out -<.> "tex") :: Action ()
      cmd ("cp " ++ "build/" ++ out ++ " " ++ out) :: Action ()
      putNormal $ "Done " ++ out

    "//*.tex" %> \out -> do
      let in' = dropDirectory1 $ mdify out
      let out' = dropDirectory1 out
      putNormal $ "Building " ++ out
      need ["gpp/tex.gppb", in']
      Stdout processed <- cmd (gppC $ in')
      cmd (Stdin processed) ("pandoc --template=default.latex --filter=pandoc-citeproc --filter=pandoc-minted -f markdown " ++ "-t " ++ "latex " ++ "-o " ++ out ++ " " ++ in') :: Action ()
      putNormal $ "Done " ++ out

    "gpp/*.gppb" %> \out -> do
        putNormal $ "Compacting " ++ out
        cont <- liftIO (compactMacro (out -<.> "gpp"))
        writeFile' out cont
