---
title: "OFF fvar: Representative Instance Proposal"
date: August 24, 2023
author: Skef Iterum and Frank Grießhammer, Adobe Inc.
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

# Background

A central aspect of support for variable fonts in OpenType is the default
location, which has a normalized value of 0 on every axis.  Variable glyph
outline data and other values (e.g. for spacing and kerning) are specified as
deltas relative to the value at the default location. 

Many TTF variable fonts, with `glyf` outlines and deltas stored in the `gvar`
table, can still be used on systems that have not yet been upgraded to support
variable font functionality. Indeed, the split between `glyf` and `gvar` was
specified to allow this.  When designing a glyph for this sort of use, one
would typically position the most "general" font instance as the default. For
example, in a font with one `wght` axis, the "Regular" weight would be a good
choice of default.

However, not all fonts are designed this way. The `CFF2` table is not backward
compatible, except in the sense that it is possible to include both a `CFF` and
a `CFF2` table in the same font, with the former serving as a fallback if the
latter is not supported. And although one can choose to put the most general
instance of a `glyf`-based font at the default location, one may not want to.
For example, if the starting point in the design is two axes with four masters
at four "extreme" locations, it might be preferable to choose one of those
masters as the default, because doing so would substantially decrease the font
file size compared with adding an extra pre-generated master there.

It is already possible to build a self-consistent variable font in this way.
However, *not* putting the "most regular" instance at the default location
poses an additional problem, as the OpenType *format* default location is also,
at present, also the *interface* default location. That is, it is the location:

1. Rendered by default when no other location is specified.
2. Presented as the initial instance in a UI or font picker.

This hard link between the interface default and the format default is not
inherent to variable font technology; it is just how things work now because
there is currently no means of adjusting one without adjusting the other.
Because providing that option would allow some fonts to be significantly
smaller with no other drawback, we are proposing a format extension to do so.

# Proposed Specification Changes

All references are relative to ISO/IEC 14496-22 Fourth edition 2019-01, and all
changes are to "InstanceRecord" subpart of 7.3.3 "fvar — Font variations table"

1. The "Description" field of the "flags" row in the `InstanceRecord` table
   changes to "Instance qualifiers — see details below".

2. The paragraphs starting with "The subfamilyNameID" and "The
   postScriptNameID" should be end with "should only be used if the
   REPRESENTATIVE\_INSTANCE flag is set or if the instance corresponds to the
   font's default instance."

3. In the paragraph starting with "The default instance of a font is that
   instance", the sentence "When enumerating named instances, the default
   instance should be enumerated even if there is no corresponding instance
   record." should be changed to "When enumerating named instances, unless an
   instance has the REPRESENTATIVE\_INSTANCE flag set, the default instance
   should be enumerated even if there is no corresponding instance record."

4. The following text is added to the end of the subpart (before 7.3.3.2):

    Flags can be assigned to indicate certain uses or behaviors for a given
    instance. The following flags are defined.
    
    -------------------------------------------------------------------------
    Mask     Name                       Description
    -------- -------------------------- -------------------------------------
    0x0001   REPRESENTATIVE\_INSTANCE   The axis values of this instance
                                        should be used as the initial value
                                        for any axis not otherwise provided.
    
    0xFFFE   Reserved                   Reserved for future use — set to 0.
    -------------------------------------------------------------------------
    
    The REPRESENTATIVE\_INSTANCE flag indicates that the respective axis values
    of this instance should be used in place of the axis defaultValue when its
    location is not otherwise specified. For example, if no axis values are
    specified then this instance should be chosen, and if all but one axis values
    are specified the remaining value should be taken from this instance. In
    effect, the instance with this flag overrides the axis defaults from a
    user-interface perspective (without otherwise affecting the role of axis
    defaults within the format). The flag must not be used more than once in the
    same font.
    
    A REPRESENTATIVE\_INSTANCE is only needed in a font where the defaultValue of
    one or more axes is not regular or paradigmatic, or (less commonly) in a font
    where what is regular may differ from what is paradigmatic.  For example, the
    original sources for a font with one wght axis might consist of just two
    masters at the lightest and heaviest weight. One way to construct the
    variable font would be to interpolate a master at the Regular weight and
    place it at the defaultValue, but this will substantially increase the font's
    file size.  Another way is to put one extreme at the wght axis defaultValue
    and add an InstanceRecord for Regular with the REPRESENTATIVE\_INSTANCE flag
    set.
    
    Absent other relevant considerations, it is recommended that the
    REPRESENTATIVE\_INSTANCE, when present, be used to display the font in font
    pickers and analogous user interfaces, at least initially.

5. In section 7.3.3.2, the sentence "If a value is not specified for any particular
   axis, the default value for that axis defined in the font is used." changes
   to "If a value is not specified for any particular axis, and an instance has
   the REPRESENTATIVE\_INSTANCE flag set, the value for that axis is taken from
   that instance.  Otherwise the default value for that axis from the
   VariationAxisRecord is used."

# Suggested Cross-references

The specification discusses the default instance in a number of locations.
We suggest that a note to the effect of "(However, note the fvar InstanceRecord
REPRESENTATIVE\_INSTANCE flag in section 7.3.3.1)" be added to:

1. The second to last paragraph of section 7.1.1 ("A variable font has a 
   default instance ...")
2. The eighth paragraph of 7.1.3 ("The font designer can determine which design
   is considered the default ..."

