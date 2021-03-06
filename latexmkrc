$pdf_mode = 1;
$pdflatex = 'lhs2TeX -v --poly %B.lhs > %B.tex; pdflatex -file-line-error -halt-on-error --enable-write18 %O %B.tex %B.pdf';
$pdf_previewer = 'open %S';
$pdf_update_method = 0;
$clean_ext = "nav snm ptb tex aux bbl pdf_tex";

add_cus_dep('lhs', 'tex', 0, 'cus_dep_require_primary_run');
add_cus_dep('svg', 'pdf', 0, 'cus_dep_require_primary_run');
