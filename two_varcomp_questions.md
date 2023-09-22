Since the TypeCon meeting last week I've been preoccupied with a number of
questions about the variable composite proposal.  I hope these are the good,
potentially productive kind of question rather than the crabby, lets-just-
not-do-this type, but they aren't small. I'm wondering if things might be
significantly better with some significant changes.

I've boiled these thoughts into two interrelated multi-part questions, 
which I'll post here and in the linked issues in the boring-expansion-spec
GitHub repository. Those issues seem like a good context for subsequent
discussion.

# Should variable composites be in the glyf table, and why?

I think I understand how we got to the current proposal. Roughly:

1. The variable composites specification extends the current glyf 
   composites mechanism.
2. Leaving variable composites in the glyf table saves some bytes,
   in that the offsets can remain in loca and you share the Tuple
   Variation Store offsets with gvar.

However:

1. Maybe the overall variable composites system shouldn't be so 
   directly derived from the glyf mechanism (see the other question).
2. Everything proposed would seem to apply just as well to pulling
   outlines out of a CFF2 table.
3. We already have a model for how to do this in an external table,
   that being COLR.

Right now, a system that understands COLR starts by looking in that table for
an entry. If it finds one, it pulls path data from either glyf or CFF(2). If it
doesn't, it falls back to glyf or CFF(2).  All of this happens
"below"/subsequent to shaping:

(shaping) -> COLR -> (glyf | CFF(2))

It seems like what "variable compositing" amounts to is an additional,
simplified shaping step. Call it "intra-glyph shaping", which occurs here:

(inter-glyph shaping) -> COLR -> (intra-glyph shaping) -> (glyf | CFF2)

The only reason the system doesn't already look like this is that the
compositing data is stored in the glyf table.

Set aside the question of other potential changes and just consider the current
proposal: If one wanted to have this mechanism for CFF2 also, would it be
substantially different? If it had to live inside the CFF2 table it would be
formatted differently (with blends instead of a separate tuple variation store,
perhaps using floats instead of fixed-point values of different scales, etc.)
But would the meaning of the parameters be any different? Would other
parameters be needed, or redundant, in the CFF2 case?  I don't see how, or why.

So suppose the system worked this way instead:

1. Variable composite data is in its own table, call it "vcmp". It has some 
   top-level mechanism for mapping data to GIDs analogous to that of COLR.
   The per-glyph tuple variation stores could be at an offset within the
   data.
2. For the sake of argument, leave the per-glyph format exactly like it is
   now, except for an additional `hint flags` field in the component record
   (and minus the stuff needed to play nice in the glyf table, like 
   `numberOfContours`).
3. Prohibit the use of the existing `glyf` composite mechanism when using
   this separate table.
4. Specify that when there is path data for a GID in the (glyf | CFF(2)) table,
   and that GID also has a composite entry, the path data is added with no
   transformation to the composite data. (This was asked for toward the end
   of the TypeCon meeting.)
5. Specify that when there is hinting data for a GID in the (glyf | CFF(2)) table,
   (TrueType instructions or CFF stems) and that GID also has a composite entry,
   the relationship of the additional hinting data to the component hinting data
   is determined by the hint flags.

The main thing to work out with this system would be the details of the hint
flags, but those problems are analogous for the two path data sources.  Maybe
you need different flags for glyf and for CFF2 — which could overlap, because
one assumes mixing sources is off the table — but in each case the only thing
to be worked out is how to reconcile the hinting data. (We know this because we
already have COLR, so we already have implementations that grab data from the
bottom-level tables, alter the points according to affine transformations, and
render the results.)

This change would have these cons:

1. A modest increase in size, due redundant loca/gvar/vcmp offset entries and
   duplication across the tuple variation stores (header, regions).
2. ?

And these pros:

1. Assuming someone does the work of specifying the hinting behavior for CFF2,
   the system would work just as well with CFF2 and glyf. This reduces pressure
   on glyf format changes. CFF2 already goes above 64k glyphs, already supports
   cubics, and can already losslessly represent quadratics as cubics (at the cost
   of using floating point values in the conversion, when that precision is
   needed).
2. If the composite system needs to do other things, its internal structure
   doesn't need to be so closely tied to the older glyf composite mechanism.

Note: Although I can't make any promises, I've thought through some of what one
would need to say about CFF2 hinting and variable components. It does seem like
there could be a viable model here where overall hinting quality could approach
that of the current system. ("Decompositing" to CFF (or CFF2) would involve
some hinting compromises, but that's already true for CFF2 to CFF because of
overlap.)

# Variable Compositing is analogous to shaping. So what about substitution?

I noted in the other question that "variable compositing" seems to amount to an
additional, simplified shaping step. However, as specified the system only
includes an analog of positioning, and lacks an analog of substitution.

Let's consider a specific case.

Suppose that you are working in a model that has three conceptual layers: atoms,
molecules, and glyphs. Perhaps these are exposed by a font editor.

For a given molecule, the designer decides she wants the outline of one atom to
change within one sub-region of design space, and a different atom to change
within a slightly different sub-region of design space. The molecule is used in
25 different glyphs. With the existing proposal it seems like there are two
options:

1. Force the designer to play tricks with the masters so that all versions of
   the atom interpolate, and then position the masters in design space right next
   to each other for quick interpolations. This increases the burden on the 
   designer.
2. Allow the designer to specify different, non-interpolable versions of an
   atom in different subspaces of design space, and sort things out in the
   compiled font.

In our example, it seems like the only option for 2 with the current proposal
would be to use GSUB's `rvrn` or something similar. Given that the molecule has
four versions (for each permutation of default and altered atom), you would
need 100 GIDs to handle the 25 glyphs. You would also need to either duplicate
the composite data for the other, always-present atoms across the four
molecules, or add another "base molecule" layer into the hierarchy to collect
that data together to avoid duplication.

Now, of course, in *some* cases you'll need to do something like this anyway:
mainly when swapping an atom affects the metrics of the ultimate glyph. But
such cases seem like the exception rather than the rule. 

So:

1. Should there be some more targeted way of supporting this sort of case
   in a variable composite model?
2. Does this suggest that the model should draw a little bit more from
   GSUB/GPOS and perhaps be less closely tied to the older glyf model? (For
   example, you might need distinct positioning data for the different atoms
   that can be substituted into a molecule, perhaps loosely analogous to
   distinct contextual positioning GPOS rules that could apply after a
   substitution.)
