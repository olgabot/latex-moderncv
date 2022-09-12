
CV_NAME=olga-botvinnik-cv
ADVISOR_FOLDER=potential-advisors
ADVISOR_FILES=$(wildcard ${ADVISOR_FOLDER}/*.tex)
COVER_FOLDER=cover-letters


cv: clean
	TEX=${CV_NAME} make compile

dance: clean
	TEX=${CV_NAME}-$@ make compile

clean:
	# Remove BibTeX and TeX auxiliary files
	rm -rf *bbl *blg *aux

coverletter:
	rm -rf ${COVER_FOLDER}/*

	mkdir -p ${COVER_FOLDER}

	# Copy the bibliographies to the cover letter folder
	cp *.bib ${COVER_FOLDER}

	# Copy the bibliography styles to the gover letter folder
	cp *.bst ${COVER_FOLDER}

	# Copy the makefile to the cover letter folder too
	cp Makefile ${COVER_FOLDER}

	for ADVISOR_TEX in $(ADVISOR_FILES) ; do \
		ADVISOR_BASENAME=$$(basename $${ADVISOR_TEX}) ; \
		ADVISOR_PREFIX=$$(echo $${ADVISOR_BASENAME}} | cut -d'.' -f1) ; \
		sed "s:.*\\input{filename}.*:\\\input{../${ADVISOR_FOLDER}/$${ADVISOR_BASENAME}}:g" < ${CV_NAME}.tex > ${COVER_FOLDER}/${CV_NAME}-$${ADVISOR_BASENAME} ; \
		echo ${COVER_FOLDER}/${CV_NAME}-$${ADVISOR_PREFIX} ;\
		pushd ${COVER_FOLDER} ; \
		TEX=${CV_NAME}-$${ADVISOR_PREFIX} make compile; \
		popd ; \
	done

compile:
	latex ${TEX}.tex
	# bibtex each citation class separately
	# These are defined in .tex, not the names of the .bib iles
	bibtex article
	bibtex book
	bibtex poster
	latex ${TEX}.tex
	latex ${TEX}.tex
	dvips -t letter -Ppdf ${TEX}.dvi -o ${TEX}.ps
	# Comment out the next line if you want to create a PDF
	ps2pdf ${TEX}.ps ${TEX}.pdf
