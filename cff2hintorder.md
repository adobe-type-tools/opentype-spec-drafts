---
title: "Ordering and overlap between variable CFF2 stem hints"
date: February 9, 2024
author: Skef Iterum
mainfont: LibertinusSerif-Regular.otf
geometry: margin=1.4in
output:
  pdf_document:
    md_extensions: +fancy_lists 
mainfontoptions:
- BoldFont=LibertinusSerif-Bold.otf
- ItalicFont=LibertinusSerif-Italic.otf 
- BoldItalicFont=LibertinusSerif-BoldItalic.otf
---

\noindent The following unnumbered section is added to the end of the current
CFF2 section "Hints":

> # Variable hints {-}

> As with other CharString values, the values of `hstem`, `hstemhm`, `vstem` and
> `vstemhm` operators can be blended so that they vary across a design space.
> The requirements on stem hints are relaxed in the following two ways in the
> context of a variable font:

> * Although horizontal and vertical stems must always be sorted according to
>   their values in the default instance, their relative ordering can
>   change in other instances.
> * Any instance, including the default instance, can have more than one stem
>   with exactly the same position and width.

> Any pair of stems that overlap with one another at any point in design
> space—and therefore any pair of stems that change order or are identical in
> some instance—must be treated as overlapping when choosing between the `stem`
> and `stemhm` operator variants and when constructing `hintmasks` for the
> CharString.
