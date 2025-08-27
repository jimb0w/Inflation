
texdoc init Inflation, replace logdir(log) gropts(optargs(width=0.8\textwidth))
set linesize 100

*ssc install texdoc, replace
*net from http://www.stata-journal.com/production
*net install sjlatex
*copy "http://www.stata-journal.com/production/sjlatex/stata.sty" stata.sty

texdoc stlog, nolog nodo
cd /home/jimb0w/Documents/Inflation
texdoc do Inflation.do
texdoc stlog close

/***

\documentclass[11pt]{article}
\usepackage{fullpage}
\usepackage{siunitx}
\usepackage{hyperref,graphicx,booktabs,dcolumn}
\usepackage{stata}
\usepackage[x11names]{xcolor}
\bibliographystyle{unsrt}
\usepackage{natbib}
\usepackage{pdflscape}
\usepackage[section]{placeins}

\usepackage{chngcntr}
\counterwithin{figure}{section}
\counterwithin{table}{section}

\usepackage{multirow}
\usepackage{booktabs}

\newcommand{\specialcell}[2][c]{%
  \begin{tabular}[#1]{@{}c@{}}#2\end{tabular}}
\newcommand{\thedate}{\today}

\usepackage{pgfplotstable}

\begin{document}


\begin{titlepage}
    \begin{flushright}
        \Huge
        \textbf{How much to workers really lose to inflation?}
\color{black}
\rule{16cm}{2mm} \\
\Large
\color{black}
\thedate \\
\color{blue}
https://github.com/jimb0w/Inflation \\
\color{black}
       \vfill
    \end{flushright}
        \Large

\end{titlepage}

\clearpage
\tableofcontents

\clearpage
\section{Average loss to inflation from July 2021 to June 2025}


***/

texdoc stlog, cmdlog nodo
cd /home/jimb0w/Documents/Inflation
copy https://www.abs.gov.au/statistics/labour/earnings-and-working-conditions/average-weekly-earnings-australia/may-2025/6302001.xlsx Wages.xlsx

copy https://www.abs.gov.au/statistics/economy/price-indexes-and-inflation/consumer-price-index-australia/jun-quarter-2025/640101.xlsx CPI.xlsx
copy https://www.abs.gov.au/statistics/economy/price-indexes-and-inflation/selected-living-cost-indexes-australia/jun-2025/646701.xlsx ECLI.xlsx

import excel "/home/jimb0w/Documents/Inflation/Wages.xlsx", sheet("Data1") cellrange(A11:J37) clear
rename (A C D F G I J) (date M_FT M_T F_FT F_T A_FT A_T)
drop B E H
save wages, replace


import excel "/home/jimb0w/Documents/Inflation/CPI.xlsx", sheet("Data1") cellrange(A265:S318) clear
rename (A J S) (date CPI_I CPI)
keep date CPI*
save CPI, replace

import excel "/home/jimb0w/Documents/Inflation/ECLI.xlsx", sheet("Data1") cellrange(A66:H119) clear
rename (A C H) (date ECLI_I ECLI)
keep date ECLI*
save ECLI, replace

use wages, clear
gen AFT_I = 100*A_FT/A_FT[1]
gen AT_I = 100*A_T/A_T[1]
append using CPI ECLI


forval i = 2012(4)2024 {
local i`i' = td(1,1,`i')
}
twoway ///
(connected AFT_I date) ///
(connected AT_I date) ///
(connected CPI_I date) ///
(connected ECLI_I date) ///
, xtitle(Calendar time) ytitle(Index) ///
xlabel( ///
`i2012' "2012" ///
`i2016' "2016" ///
`i2020' "2020" ///
`i2024' "2024") ///
legend(position(3) ///
order(1 "Full-time mean earnings" ///
2 "Total mean earnings" ///
3 "Consumer Price Index" ///
4 "Employee Cost of Living Index" ///
) cols(1))


use CPI, clear
drop if date < td(1,5,2021)
gen CPI1 = 100*CPI_I/CPI_I[1]
save cpi1, replace
use ECLI, clear
drop if date < td(1,5,2021)
gen ECLI1 = 100*ECLI_I/ECLI_I[1]
save ecli1, replace


use wages, clear
drop if date < td(1,5,2021)
gen AFT_I = 100*A_FT/A_FT[1]
gen AT_I = 100*A_T/A_T[1]
append using cpi1 ecli1
forval i = 2021(1)2025 {
local i`i' = td(1,1,`i')
}
twoway ///
(connected AFT_I date) ///
(connected AT_I date) ///
(connected CPI1 date) ///
(connected ECLI1 date) ///
, xtitle(Calendar time) ytitle(Index) ///
xlabel( ///
`i2021' "2021" ///
`i2022' "2022" ///
`i2023' "2023" ///
`i2024' "2024" ///
`i2025' "2025") ///
legend(position(3) ///
order(1 "Full-time mean earnings" ///
2 "Total mean earnings" ///
3 "Consumer Price Index" ///
4 "Employee Cost of Living Index" ///
) cols(1))

*So while this is a good approximation across the economy, it's not a good approximation for 
*an individual, for whom the experience looks more like this: 
*That's because wage rises for most come once a year

gen njm = _n

expand 2 if AT_I!=. & njm!=9
sort njm date
drop if njm == 3 | njm == 5 | njm == 7
replace date = date[_n+1]-1 if AT_I==AT_I[_n-1] & AT_I!=.
replace AFT_I = AFT_I[_n-1] if njm == 9
replace AT_I = AT_I[_n-1] if njm == 9

twoway ///
(line AFT_I date) ///
(line AT_I date) ///
(line CPI1 date) ///
(line ECLI1 date) ///
, xtitle(Calendar time) ytitle(Index) ///
xlabel( ///
`i2021' "2021" ///
`i2022' "2022" ///
`i2023' "2023" ///
`i2024' "2024" ///
`i2025' "2025") ///
legend(position(3) ///
order(1 "Full-time mean earnings" ///
2 "Total mean earnings" ///
3 "Consumer Price Index" ///
4 "Employee Cost of Living Index" ///
) cols(1))




di td(01,01,2016)

texdoc stlog close

/***

\clearpage
\section{Methods}

Goes at the end

\color{Blue4}
***/

texdoc stlog, cmdlog nodo
cd /home/jimb0w/Documents/Inflation

texdoc stlog close

/***
\color{black}

\end{document}
***/

texdoc close

! pdflatex Inflation
! pdflatex Inflation
! pdflatex Inflation

erase Inflation.aux
erase Inflation.log
erase Inflation.out
erase Inflation.toc

! git init .
! git add Inflation.do Inflation.pdf
! git commit -m "0"
! git remote remove origin
! git remote add origin https://github.com/jimb0w/Inflation.git
! git remote set-url origin git@github.com:jimb0w/Inflation.git
! git push --set-upstream origin master
