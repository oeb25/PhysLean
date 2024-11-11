/-
Copyright (c) 2024 Joseph Tooby-Smith. All rights reserved.
Released under Apache 2.0 license.
Authors: Joseph Tooby-Smith
-/
import HepLean.Meta.Basic
/-!

# HepLean Stats

This file concerns with statistics of HepLean.

-/


open Lean System Meta HepLean


def getStats : MetaM String := do
  let noDefsVal ← noDefs
  let noLemmasVal ← noLemmas
  let noImportsVal ← noImports
  let noDefsNoDocVal ← noDefsNoDocString
  let noLemmasNoDocVal ← noLemmasNoDocString
  let noLinesVal ← noLines
  let s := s!"
    Number of Imports: {noImportsVal}
    Number of Definitions: {noDefsVal}
    Number of Lemmas: {noLemmasVal}
    Number of Definitions without doc strings: {noDefsNoDocVal} (out of {noDefsVal})
    Number of Lemmas without doc strings: {noLemmasNoDocVal} (out of {noLemmasVal})
    Number of Lines: {noLinesVal}"
  pure s

unsafe def Stats.toHtml : MetaM String := do
  let noDefsVal ← noDefs
  let noLemmasVal ← noLemmas
  let noImportsVal ← noImports
  let noDefsNoDocVal ← noDefsNoDocString
  let noLemmasNoDocVal ← noLemmasNoDocString
  let noLinesVal ← noLines
  let noInformalDefsVal ← noInformalDefs
  let noInformalLemmasVal ← noInformalLemmas
  let header := "---
layout: default
---
<!DOCTYPE html>
<html>
<head>
    <title>Stats for HepLean</title>
     <meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">
     <style>
        /* Style the progress bar to be wider and take up more space */
        progress {
            width: 80%; /* Adjust to take up more horizontal space */
            height: 30px; /* Increase height to make it wider */
            appearance: none; /* Remove default browser styles */
        }

        /* Change the color for WebKit browsers (Chrome, Safari, etc.) */
        progress::-webkit-progress-bar {
            background-color: #f3f3f3; /* Background color */
            border-radius: 5px;
            overflow: hidden;
        }

        progress::-webkit-progress-value {
            background-color: #157878; /* Change this to your desired color */
            border-radius: 5px;
        }

        /* Change the color for Firefox */
        progress::-moz-progress-bar {
            background-color: #157878; /* Change this to your desired color */
        }
    </style>
</head>
<body>"
  let body := s!"
<h1>Stats for HepLean</h1>
<h3>Number of Files 📄: {noImportsVal}</h3>
<h3>Number of lines 💻: {noLinesVal}</h3>
<h3>Number of Definitions (incl. instances): {noDefsVal - noInformalLemmasVal}</h3>
<p>- Of which {noDefsVal - noDefsNoDocVal- noInformalLemmasVal} have doc-strings:</p>
<progress value=\"{noDefsVal - noDefsNoDocVal- noInformalLemmasVal}\" max=\"{noDefsVal- noInformalLemmasVal}\"></progress>
<p>- Of which {noDefsVal - noInformalLemmasVal - noInformalDefsVal} are not informal definitions:</p>
<progress value=\"{noDefsVal - noInformalLemmasVal - noInformalDefsVal}\" max=\"{noDefsVal - noInformalLemmasVal}\"></progress>

<h3>Number of Lemmas: {noLemmasVal + noInformalLemmasVal}</h3>
<p>- Of which {noLemmasVal - noLemmasNoDocVal + noInformalLemmasVal} have doc-strings:</p>
<progress value=\"{noLemmasVal - noLemmasNoDocVal + noInformalLemmasVal}\" max=\"{noLemmasVal + noInformalLemmasVal}\"></progress>
<p>- Of which {noLemmasVal} are not informal lemmas:</p>
<progress value=\"{noLemmasVal}\" max=\"{noLemmasVal + noInformalLemmasVal}\"></progress>
   "
  let footer := "
</body>
</html>
"
  pure (header ++ "\n" ++ body ++  "\n" ++ footer)

unsafe def main (args  : List String) : IO UInt32 := do
  let _ ← noImports
  let statString ← CoreM.withImportModules #[`HepLean] (getStats).run'
  println! statString
  if "mkHTML" ∈ args then
    let html ← CoreM.withImportModules #[`HepLean] (Stats.toHtml).run'
    let htmlFile : System.FilePath := {toString := "./docs/Stats.html"}
    IO.FS.writeFile htmlFile html
    IO.println (s!"HTML file made.")
  pure 0
