
BASES := conditions vfdefault repinstance_spec condvalue_spec newfeatvar
PANDOC := pandoc
PANARGS := --data-dir=pandoc-data --pdf-engine=lualatex --template=paper --toc
PDFS := ${BASES:=.pdf}

all: ${PDFS}

clean:
	${RM} ${PDFS}

%.pdf : %.md
	${PANDOC} ${PANARGS} -o $@ $<
