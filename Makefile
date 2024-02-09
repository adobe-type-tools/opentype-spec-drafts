
TOCBASES := conditions vfdefault repinstance_spec condvalue_spec newfeatvar
NOTOCBASES := varchintguide newfeatvar_spec negation cff2hintorder
PANDOC := pandoc
PANARGS := --data-dir=pandoc-data --pdf-engine=lualatex
TOCPDFS := ${TOCBASES:=.pdf}
NOTOCPDFS := ${NOTOCBASES:=.pdf}
${TOCPDFS}: EXTRA_ARGS := --template=paper
${NOTOCPDFS}: EXTRA_ARGS := --template=notocpaper

all: ${TOCPDFS} ${NOTOCPDFS}

clean:
	${RM} ${TOCPDFS} ${NOTOCPDFS}

%.pdf : %.md
	${PANDOC} ${PANARGS} ${EXTRA_ARGS} -o $@ $<
