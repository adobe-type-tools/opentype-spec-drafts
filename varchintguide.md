---
title: "VARC Hint Guidance for CFF2"

date: March 4, 2024
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


# CFSH — Compact Font Format Supplementary Hint Table {-}

(This section is added as a new table specification.)

'CFSH' is an optional table used to provide supplementary 'CFF2'-format
PrivateDICT structures for VARC composite glyphs, and to map each VARC glyph to
those PrivateDICTs or to PrivateDICTs in the 'CFF2' table.  Its contents are
certain `CFF2` subtables, in some cases slightly modified.

## CFSH Header {-}

-------------------------------------------------------------------------
Type     Name                       Description
-------- -------------------------- -------------------------------------
uint16   major\_version             Table major version number (=1)

uint16   minor\_version             Table minor version number (=0)

Offset32 privateDICTIndexOffset     Offset (from start of CFSH table) 
                                    to a 'CFF2' INDEX of Private DICTs.
                                    0 if no PrivateDICTIndex.

uint16   initialPrivateDICT         The FontDICT index associated with of
                                    the first entry in the
                                    PrivateDICTIndex (default is 0).

Offset32 fdSelectOffset             Offset (from start of CFSH table) to
                                    the FontDICTSelect subtable. Must not
                                    be 0.

Offset32 itemVarStoreOffset         Offset (from start of CFSH table) to
                                    the Item Variation Store table (may
                                    be 0)
-------------------------------------------------------------------------
    
## Private DICT Index and initialPrivateDICT {-}

In the CFF2 table a Font DICT INDEX contains FontDICT structures, each of
which encodes the size and offset of a Private DICT as is described in
(crossreference section on CFF2 Private DICTs). CFSH also encodes CFF2
Private DICTs but eliminates the indirection through the FontDICT.
Instead, in contains a Private DICT Index, which is a CFF2 Index structure
(cross-reference section on CFF2 Indexes) that stores a list of Private
DICTs directly.

The initialPrivateDICT field is the "FontDICT index" associated with the
first entry in the Private DICT Index.  Thus if initialPrivateDICT is 24,
the index of the first CFSH private dict is 24, the index of the second is
25, and so on. The initialPrivateDICT field is normally be set to the size
of the CFF2 FontDICT INDEX, so that the index of the first CFSH Private DICT is
one greater than the index of the last CFF2 Private DICT. The indexes of the
two sets of Private DICTs must not overlap.

If the itemVarStoreOffset field is non-zero, then the `vsindex` and `blend`
operators relate to the Item Variation Store it points to. If the field is zero
then those operators relate to the Item Variation Store in the CFF2 table.

A PrivateDICT in the CFSH table must not include the `Subrs` operator.

## The FontDICTSelect Offset {-}

The FontDICTSelect offset points to a CFF2 FontDICTSelect subtable
(cross-reference 'CFF2' section on FDSelect). A client should ignore this field
when it is set to 0 to support future minor extensions of the table. However,
in a version 1.0 'CFSH' table the offset should not be 0.  As of version 1.0
only FontDICTSelect format 4, as described in (cross-reference section on
FDSelect format 4), is supported, with one modification: it is not required
that the `fd` field in the first Range4 record be 0.

The FontDICTSelect subtable in 'CFSH' can overlap with the FontDICTSelect
subtable in the 'CFF2' table but there must not be gap between the last glyph
mapped in 'CFF2' and the first glyph mapped in 'CFSH'. The `sentinel` field in
'CFSH' must be the highest GID defined in the font (from `maxp` or `MAXP`).

## The itemVarStore Offset {-}

When not zero, this field points to an Item Variation Store used for the
`vsindex` and `blend` operators for any PrivateDICTs in the `CFSH` table.

# VARC and Hinting {-}

(This will be a new, appropriately placed section in the VARC chapter.)

When a VARC composite glyph is built from 'glyf' components that include TT
instructions, or from 'CFF2' components that include hinting parameters, that
data should be considered part of the composite. Whether and how hint data is
used when rasterizing the glyph can depend on a number of factors, including
the transforms applied to the component both within VARC or "externally" (e.g.
using a CSS transform).

The 'glyf' table has long included its own composite format that makes use of
the TT instructions of component glyphs. That mechanism can serve as a model
for when and how to apply instructions when rasterizing a 'glyf'-based VARC
composite.

Neither CFF nor CFF2, in contrast, has internal support for compositing, and
while the 'COLR' table implicitly adds such support, `COLR` leaves the question
of hinted rasterization open.  The rest of this section closes this gap by
clarifying how to adapt 'CFF2' hinting parameters when rasterizing a VARC
composite glyph. Those parameter can then be applied as they would be when
rasterizing a hinted CharString in a `CFF2` table.

## Hinting CFF2 components in a VARC context {-}

The hinting parameters in the 'CFF2' table evolved from related information
included in PostScript Type 1 fonts, and consists of a combination of
PrivateDict parameters—each of which is associated with a particualr subset of
glyphs—and per-glyph parameters.  With VARC the PrivateDict parameters are
taken from the PrivateDICT associated with the composite glyph—or if there are
multiple layers of compositing, the PrivateDICT associated with the outer-most
composite. The per-glyph parameters are adapted from the hint operators
included in the CFF2 CharString of a component glyph, and therefore in VARC are
technically per-component rather than per-glyph. These must be adapted to 
account for the transformations and translations applied in each layer of
compositing.

### The Private DICT {-}

When a CFF2 glyph is included in a VARC composite as a component, both the
PrivateDICT of the component and that of the composite must typically be
consulted in order to render it.

The PrivateDICT of the component glyph will always be in the CFF2 table and is
mapped via the component's GID in the CFF2 FontDICTSelect subtable (unless all
CFF2 glyphs use the same PrivateDICT, in which case there will only be one).
That PrivateDICT may contain `Subrs` or `vsindex` operators needed to
desubroutinize the component's CharString and to resolve any blends it contains
relative to the specified location in design space.

The PrivateDICT of the (top-level) VARC composite glyph will either be in the
CFF2 table or the CFSH table. It is found using this procedure:

1.  If there is a CFSH table and it contains a FontDICTSelect structure, that
    is checked for the GID of the VARC composite glyph. If the GID is mapped,
    the PrivateDICT index it maps to is the index for the composite.
2.  If there is no CFSH table, no FontDICTSelect structure in the table, or
    the GID of the composite is not mapped in that structure, the
    FontDICTSelect structure in the CFF2 table is checked for the GID, and
    the PrivateDICT index it maps to is the index for the composite.
3.  If neither FontDICTSelect structure maps the GID the font is malformed.
    If there is a CFSH table, the value of the initialPrivateDICT field is the
    fallback index for the composite. Otherwise the fallback index is 0.
4.  If there is a CFSH table and the index for the composite is greater than
    or equal to its initialPrivateDICT field, the value of that field is
    subtracted from the index and the result used as the offset into the
    CFSH PrivateDICT Index.
5.  Otherwise the index for the composite is used as the offset into the CFF2
    FontDICT Index, and its PrivateDICT is used for the composite.

### Per-glyph parameters {-}

A hinted glyph has some combination of these parameters:

1. Horizontal and vertical stem regions (hstem(hm), vstem(hm))
2. Hintmasks
3. Counter hinting (cntrmask)

These are described in (cross-reference section(s) on per-glyph hinting
parameters). 

Relative to a given "top-level" composite glyph to be rendered, an "atomic"
(or "bottom-level") component glyph may be subject to multiple sets of
transformations and translations, with one set per level of VARC compositing.
How these transformations affect component point values is documented 
elsewhere. This section describes how to apply analogous transformations 
and translations to stem regions, and how to decide whether to proceed with
hinting in a given dimension of the component glyph (horizontal or vertical) or
to *cancel* hinting in that dimension.  Intuitively, hinting in a given
dimension should be cancelled when there is rotation that is not a multiple of
180 degrees, or when there is any skew in the opposite dimension.

(Note that in addition to VARC composite transforms a glyph may also be 
subject to "external" transforms, such as those specified with a Cascading
Style Sheets `transform` property. A rasterizer implementation can either 
avoid hinting in such circumstances or compose those transforms into the 
cumulative transformation of the stem hints as described below.)

Whether hinting in a given dimension should be canceled, and how the stems in
that dimension should be adjusted when it is not cancelled, can be determined
by performing the cumulative transformation on the three points *p~1~* (100,
0), *p~2~* (0, 0) and *p~3~* (0, 100) and considering the result. If we call
the transformed points *p~1~′*, *p~2~′*, and *p~3~′* respectively, adjustment
of the horizontal stems proceeds as follows:

If the line from *p~1~′* to *p~2~′* is not close enough to horizontal for
hinting purposes (which may vary by rasterizer implementation), hinting of
horizontal stems is cancelled. Otherwise hinting proceeds in that dimension
with a scale factor of 

   *s* = (*y~3~′* - *y~2~′*) / 100

\noindent and a translation factor of

   *t* = *y~2~'*

\noindent If hinting proceeds, the horizontal stem deltas are unpacked into
positional bottom, top pairs and each pair is processed as follows:

1. If the pair does not represent an edge stem, each value is multiplied by *s*
   and translated by *t*. If *s* is negative the top and bottom values are
   swapped.
2. If the pair represents a bottom edge stem, the lower edge is multiplied by
   *s* and translated by *t*. If *s* is positive the pair is re-encoded as a
   bottom edge stem with the adjusted value as the bottom. If *s* is negative
   the pair is re-encoded as a top edge stem with the adjusted value as the
   top.

   For example, if the original bottom position was *b*, the unpacked pair was
   encoded as having a width of -21 (i.e. the first number unpacked to *b* + 21
   (the "upper edge") and the second to *b* (the "lower edge")).  If *s* is
   positive the adjusted lower edge will be *b*\**s* + *t* and the adjusted
   upper edge will be *b*\**s* + *t* + 21. (If necessary this can be reencoded
   as a bottom edge hint with the first value *b*\**s* + *t* + 21 and a width
   of -21.)

   If *s* is negative then the hint is adjusted to be a top hint, with
   *b*\**s* + *t* as the upper edge and *b*\**s* + *t* - 20 as the lower
   edge, which can be re-encoded as an initial value of *b*\**s* + *t* and
   a width of -20.
3. If the pair represents a top edge stem, the upper edge is multiplied by *s*
   and translated by *t*. If *s* is positive the pair is re-encoded as a top
   edge stem with the adjusted value as the top. If *s* is negative the pair is
   re-encoded as a bottom edge stem with the adjusted value as the bottom.

If *s* is positive the adjusted stem pairs simply replace the respective
original pairs. If *s* is negative the orders of both the stem pairs and the
corresponding bits in each of the `hintmasks` and `cntrmasks` for the glyph are
reversed, and those stem pairs and masks are used to render the component.

Adjustment or cancellation of vertical stems is analogous to the horizontal
case.

# Adjustments to CFF2 chapter {-}

(These aren't quite in "editorial form" yet, because the previous proposal
that extensively modified the CFF2 text is not yet integrated.)

1.  When a font has a VARC table, the length of the CFF2 CharStringINDEX
    can be less than the maxp count, otherwise it must be equal to the
    maxp count.

2.  When a font has a VARC table, the highest glyph mapped by the
    FontDICTSelect structure can be less than the maxp count as long as two
    requirements are met. The first requirement is that there is a `CFSH` table
    that maps any remaining glyphs. The second requirement is that every glyph
    in the CharStringINDEX must be mapped.

    The ranges of mapped glyphs can overlap as described in (cross-reference
    `CFSH` section "The FontDICTSelect Offset")
