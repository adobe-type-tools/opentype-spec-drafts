---
title: "OTT Variation Conditions: Condition Value"
date: August 24, 2023
author: Skef Iterum, Adobe, Inc.
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

# Proposed Specification Changes

Relative to ISO/IEC 14496-22 Fourth edition 2019-01, these changes modify
parts of section 6.2.9 "Feature variations"

1. In "FeatureVariations Table", note that if minorVersion is 0 then only
   Condition Table version 1 can be used. If minorVersion is 1 then
   Condition Table version 2 can also be used.

2. In the first paragraph of the "Condition Table" subpart, remove the last
   sentence.

3. Add new subpart between "Condition Table Format 1: Font Variation Axis
   Range" and "FeatureTableSubstitution Table" with this content:

    Condition Table Format 2: Condition Value

    A condition value is an interpolated *value* interpreted as a boolean
    condition. Like a variable xPlacement field in a GPOS ValueRecord, it is
    specified as a int16 default value together with a delta set index pair.
    The condition is evaluated by calculating the value at the current
    variation instance. If that value is greater than 0 the condition is true,
    if the value is less than or equal to zero the condition is false.

    The application of a condition value is up to the font designer, but they
    were added for cases when variations need to be applied across two or more
    *interrelated* axes.

    Consider an archetypal case of substitution: A variable font has two glyphs
    for the dollar sign, a main design wth two vertical strokes and an
    alternate with just one stroke. The designer wants to switch to the
    alternate the two strokes are too thick to leave room for each
    other.

    In a font with just one axis that affects stem width, the substitution
    point can be chosen with a format 1 condition. Some fonts, however, have
    more than one axis that affects stroke width. For example, both a wght axis
    and an opsz axis typically do so. In a font with both of those axes a a
    designer's judgment about when to substitute the alternate might look
    something like this, with the alternate used to the left of the line:

    ![Two related axes](cond_fig5.svg){ width=90% }
    \ 

    This is impossible to express exactly using format 1 conditions.  The best
    you can do is a stepwise approximation, perhaps something like this:

    ![Two related axes, approximated](cond_fig6.svg){ width=90% }
    \ 

    In contrast, a condition value can express this substitution exactly, using
    these values at the indicated "master" positions:

    ![Two related axes, exact](cond_fig7.svg){ width=90% }
    \ 

    Because a condition value is an interpolated int16, large magnitudes are
    recommended to reduce rounding error. This example was constructed from a
    starting value of 10,000 at one edge and -10,000 at the other. The values
    were then adjusted to match the zero line of the value to the substitution
    line.

    *ConditionTableFormat2*

    -------------------------------------------------------------------------
    Type     Name                       Description
    -------- -------------------------- -------------------------------------
    uint16   format                     Format = 2

    int16    default                    Value at default instance

    uint16   deltaSetOuterIndex         A delta set outer index — used to
                                        select an item variation data
                                        subtable within the item variation
                                        store

    uint16   deltaSetInnerIndex         A delta set inner index — used to
                                        select a delta-set row within an
                                        item variation data subtable
    -------------------------------------------------------------------------

    As with variable GPOS values, the delta set index pair refers to the
    item variation data subtable in the 'GDEF' table.

4. Add appropriate content GSUB to the following sentences: 

    On page 166: "Within the GPOS, JSTF, GDEF and BASE tables, delta-set
    indices are stored in VariationIndex tables."

    On page 199, "In variable fonts, the GDEF, GPOS and JSTF tables may all
    reference variation data within the ItemVariationStore table contained
    within the GDEF table."

    On page 201, "This same table, within the GDEF table, can also hold
    variation data used for X or Y values in the GPOS or JSTF tables."

    On page 215, "The same Item Variation Store is also used for adjustment of
    values in the GDEF and JSTF tables."

    In section 7.1.6, "If a font has OFF Layout tables, variation data for
    values from the ‘GDEF’, ‘GPOS’ or ‘JSTF’ table will be included, as needed,
    within the ‘GDEF’ table."

    In the first bullet list in section 7.2.1, "Deltas for anchor positions in
    ‘GPOS’ lookups and other items used in ‘GDEF’, ‘GPOS’ or ‘JSTF’ tables are
    stored within variation data contained in the ‘GDEF’ table."

