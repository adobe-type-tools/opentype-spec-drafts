---
title: "Feature Variations: Conditon Negations"
date: February 5, 2024
author: Skef Iterum, Adobe Inc.
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

# Condition Negation Proposal

The first change is that this sub-section is inserted after the current
"Condition Table Format 1: Font Variation Axis Range":

> Condition Table Format 2: Negated Font Variation Axis Range
> 
> The fields in this table after Format are identical to the fields for
> format 1, and are interpreted the same way. The difference between
> the formats is that when ever a format 1 condition is true the format
> 2 condition is false, and vice versa.

\footnotesize

> -------------------------------------------------------------------------------------
> Type      Name                                Description 
> --------- ----------------------------------- ---------------------------------------
> uint16    Format                              Format = 2
> 
> uint16    AxisIndex                           Same as in format 1
> 
> F2DOT14   FilterRangeMinValue                 Same as in format 1
> 
> F2DOT14   FilterRangeMaxValue                 Same as in format 1
> -------------------------------------------------------------------------------------

\normalsize

The second change is that the Condition Value table format is changed from 2
(as it was when added to the working draft) to 3.

Then this is added after that sub-section:

> Condition Table Format 4: Negated Condition Value
> 
> The fields in this table after Format are identical to the fields for
> format 3, and are interpreted the same way. The difference between
> the formats is that when ever a format 3 condition is true the format
> 4 condition is false, and vice versa.

\footnotesize

> -------------------------------------------------------------------------
> Type     Name                       Description
> -------- -------------------------- -------------------------------------
> uint16   Format                     Format = 4
> 
> int16    Default                    Same as in format 3
> 
> uint16   DeltaSetOuterIndex         Same as in format 3
> 
> uint16   DeltaSetInnerIndex         Same as in format 3
> -------------------------------------------------------------------------

\normalsize
