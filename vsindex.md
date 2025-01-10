---
title: "Clarification of vsindex operator in CFF2"
date: November 1, 2024
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

# Introduction

Editorial changes along the following lines have been quite reasonably
requested by Behdad Esfahbod on behalf of Google. They clarify that the default
vsindex value for a CharString is the one specified in its PrivateDict, and
when there no vsindex operator its default value is 0. This is currently the
case and any implementation that doesn't treat the values this way will be
broken with existing fonts, but the language in the specification can be
interpreted in in other ways.

# Changes

In section 5.3.3.9.3 (PrivateDict variation operators):

After the sentences

> When used within a PrivateDICT, it has effect not only for
> variation of values specified by PrivateDICT keys but also for variation
> in all CharStrings associated with that PrivateDICT. However, a *vsindex*
> operator can also be used within a CharString, taking precedence over the
> *vsindex* specified in the PrivateDICT.

this sentence is added

> ==When not used within a PrivateDICT, a default *vsindex* value of 0 applies
> under both circumstances.==

In section 5.3.3.11.3 (Variation Operators):

These sentences are deleted:

> By default, the first ItemVariationData structure (index 0) will be used.
> The vsindex operator can be used for glyphs that require a different
> list of regions.

and the sentences

> The vsindex key may be used in a PrivateDICT to select a different list
> of regions for a group of glyphs associated with that PrivateDICT.
> vsindex may also be used in a CharString to select the list of regions
> for that glyph. When used in a CharString, it overrides a setting in the
> associated PrivateDICT.

become

> The *vsindex* key may be used in a PrivateDICT==, in which case it selects
> the regions for a *blend* operator in the PrivateDict and any CharString
> associated with that PrivateDict. When used in a CharString it overrides
> value in the PrivateDict for blends in that CharString. When there is no
> explicit *vsindex* operator a default value of 0 applies, corresponding
> to the first ItemVariationData structure.==

