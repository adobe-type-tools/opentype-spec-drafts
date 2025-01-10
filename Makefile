
TOCBASES := conditions vfdefault repinstance_spec condvalue_spec newfeatvar
NOTOCBASES := negation cff2hintorder
ISOBASES := newfeatvar_spec varchintguide vsindex vslength
PANDOC := pandoc
PANARGS := --data-dir=pandoc-data --pdf-engine=lualatex
TOCPDFS := ${TOCBASES:=.pdf}
ISOPDFS := ${ISOBASES:=.pdf}
NOTOCPDFS := ${NOTOCBASES:=.pdf}
${TOCPDFS}: EXTRA_ARGS := --template=paper
${ISOPDFS}: EXTRA_ARGS := --template=iso --from markdown+fancy_lists+mark
${NOTOCPDFS}: EXTRA_ARGS := --template=notocpaper

all: ${TOCPDFS} ${NOTOCPDFS} ${ISOPDFS}

clean:
	${RM} ${TOCPDFS} ${NOTOCPDFS} ${ISOPDFS}

%.pdf : %.md
	${PANDOC} ${PANARGS} ${EXTRA_ARGS} -o $@ $<
