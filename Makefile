all: paper

paper:
	latexmk -r latexmkrc -pdf -pvc clashtalk.lhs

clean:
	latexmk -CA
	rm talk/*.tex
	rm images/*.pdf_tex
