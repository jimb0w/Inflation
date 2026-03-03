
texdoc init Sydney_EA_wage_loss, replace logdir(log) gropts(optargs(width=0.8\textwidth))
set linesize 100

texdoc stlog, nolog nodo
cd /home/jimb0w/Documents/SA/Inflation
texdoc do Sydney_EA_wage_loss.do
exit
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
        \textbf{Wages lost to inflation at Sydney University from July 2021 until 30 June 2026}
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

Jerome has sourced the following data for this calculation:

\begin{table}[h!]
\centering
\caption{University of Sydney wage increases vs. annual inflation from 1 July 2021 to 30 June 2026}
\label{usydinfl}
\begin{tabular}{p{0.2\textwidth}p{0.25\textwidth}p{0.25\textwidth}p{0.25\textwidth}}
\hline
Period & Wage increase & CPI & Comparison \\
\hline
1 July 2021 to 30 June 2022 &
No wage increase (index = 100) &
6.2 \% (index = 106.2) &
Wages behind CPI by 6.2\% at 30 June 2022 \\
1 July 2022 to 30 June 2023 &
2.1\% (July 2022) (index = 102.1) &
6\% (index = 112.6) &
Wages behind CPI by 10.5\% at 30 June 2023 \\
1 July 2023 to 30 June 2024 &
4.6\% (24 Aug 2023) (index = 106.8) &
3.8\% (index = 116.8) &
Wages behind CPI by 10\% at 30 June 2024 \\
1 July 2024 to 30 June 2025 &
3.75\% (1 July 2024) (index = 110.8) &
2.1\% (index = 119.3) &
Wages behind CPI by 8.5\% at 30 June 2025 \\
1 July 2025 to 30 June 2026 &
\specialcell{3.75\% (1 July 2025) (index = 114.9) \\ 4\% (1 June 2026) (index = 119.5)} &
4.2\% (forecast*) (index = 124.3) &
Wages behind CPI* by 4.8\% at 30 June 2026 \\
\hline
\end{tabular}
\end{table}

Sources:
\begin{itemize}
\item Forecast inflation* from Reserve Bank (Feb 2026):
https://www.rba.gov.au/publications/smp/2026/feb/outlook.html
``Inflation is now expected to peak in mid-2026 – with underlying inflation at 3.7 per cent and headline inflation at 4.2 per cent – before moderating to a little above the midpoint of the 2–3 per cent range by mid-2028.''
\item Inflation figures from Reserve Bank:
https://www.rba.gov.au/inflation/measures-cpi.html
\item Wages from 2023-26 EA:
https://www.fwc.gov.au/document-view/agreements/the-university-of-sydney-enterprise-agreement-2023-2026?from=search
\end{itemize}

(I will get the latest inflation figures from the ABS and use those, adding a single data point for inflation to June as 4.2\%.)

The goal here is to estimate the total amount of money lost to inflation since July 2021 for the following classifications:
\begin{itemize}
\item Lecturer level A8 (starting salary July 2021 = \$105,305)
\item HEO 4.3 (starting salary July 2021 = \$76,323)
\item HEO 5.5 (starting salary July 2021 = \$87,420)
\item HEO 6.4 (starting salary July 2021 = \$96,764)
\end{itemize}

This is represented graphically in Figure~\ref{usydwages}, where the loss
to inflation is the difference between the two lines. The results are shown in 
Tables~\ref{T1_LA8}-\ref{T1_HEO64}. The methods are available in ``Inflation.pdf'' at 
\color{blue}\href{https://github.com/jimb0w/Inflation}{https://github.com/jimb0w/Inflation}\color{black}.

\color{Blue4}
***/

texdoc stlog, cmdlog nodo
*Grab the data from the ABS
cd /home/jimb0w/Documents/SA/Inflation
copy https://www.abs.gov.au/statistics/economy/price-indexes-and-inflation/consumer-price-index-australia/jan-2026/6401017.xlsx CPI_jan26.xlsx, replace
import excel "/home/jimb0w/Documents/SA/Inflation/CPI_jan26.xlsx", sheet("Data1") cellrange(A302:S320) clear
rename (A J) (date CPI_I)
keep date CPI_I
gen CPI = 100*CPI_I/CPI_I[1]
drop CPI_I
set obs 20
replace date = td(1,6,2026) if _n == 20
replace CPI = CPI[17]*1.042 if _n == 20
save CPI_jan26, replace
clear
set obs 1
gen date = td(1,7,2021)
format date %td
gen LA8 = 105305
gen HEO43 = 76323
gen HEO55 = 87420
gen HEO64 = 96764
expand 6
replace date = td(1,7,2022) if _n == 2
replace date = td(24,8,2023) if _n == 3
replace date = td(1,7,2024) if _n == 4
replace date = td(1,7,2025) if _n == 5
replace date = td(1,6,2026) if _n == 6
foreach var of varlist LA8-HEO64 {
replace `var' = `var'[1]*1.021 if _n == 2
replace `var' = `var'[2]*1.046 if _n == 3
replace `var' = `var'[3]*1.0375 if _n == 4
replace `var' = `var'[4]*1.0375 if _n == 5
replace `var' = `var'[5]*1.04 if _n == 6
}
save usyd_wages, replace
use usyd_wages, clear
gen WI = 100*LA8/LA8[1]
gen njm = _n
expand 2 if njm!=1
sort njm date
bysort njm (date) : replace date = date[_n+1]-1 if _n == 1 & njm!=1
replace WI = WI[_n-1] if njm!=1 & WI==WI[_n+1]
append using CPI_jan26
forval i = 2021(1)2026 {
local i`i' = td(1,1,`i')
}
twoway ///
(line WI date) ///
(line CPI date) ///
, xtitle(Calendar time) ytitle(Index) ///
xlabel( ///
`i2021' "2021" ///
`i2022' "2022" ///
`i2023' "2023" ///
`i2024' "2024" ///
`i2025' "2025" ///
`i2026' "2026") ///
legend(position(3) ///
order(1 "Wages" ///
2 "Consumer Price Index" ///
) cols(1))
graph export usydwages.pdf, as(pdf) replace
texdoc stlog close

/***
\color{black}

\clearpage
\begin{figure}[h!]
    \centering
    \caption{University of Sydney wages vs. inflation.}
    \includegraphics[width=0.8\textwidth]{usydwages.pdf}
    \label{usydwages}
\end{figure}

\color{Blue4}
***/

texdoc stlog, cmdlog
use CPI_jan26, clear
replace date = date-45
centile(date), centile(5 35 65 95)
local A1 = r(c_1)
local A2 = r(c_2)
local A3 = r(c_3)
local A4 = r(c_4)
mkspline timesp = date, cubic knots(`A1' `A2' `A3' `A4')
reg CPI timesp*
clear
set obs 1826
gen date = td(1,7,2021) if _n == 1
replace date = date[_n-1]+1 if _n > 1
format date %td
mkspline timesp = date, cubic knots(`A1' `A2' `A3' `A4')
predict CPI1
keep date CPI1
gen CPI = 100*CPI/CPI[1]
drop CPI1
save cpifm_usyd, replace
clear
set obs 1826
gen date = td(1,7,2021) if _n == 1
replace date = date[_n-1]+1 if _n > 1
format date %td
merge 1:1 date using usyd_wages, keep(1 3) nogen
merge 1:1 date using cpifm_usyd, nogen
foreach var of varlist LA8-HEO64 {
preserve
replace `var' = `var'[_n-1] if `var'==.
gen d`var'=`var'/365.25
gen WMI_`var' = d`var'[1]*CPI/100
gen loss_CPI_`var' = WMI_`var'-d`var'
gen tloss_CPI_`var' = sum(loss_CPI_`var')
gen aWMI_`var'=WMI_`var'*365.25
drop d`var' loss_CPI_`var' WMI_`var'
gen diff_`var' = aWMI_`var'-`var'
gen windex = 100*`var'/`var'[1]
gen dindex = CPI-windex
su dindex
gen A = r(mean)
tostring A, replace force format(%9.2f)
texdoc local mu = A[1]
keep if ///
date == td(1,7,2021) | ///
date == td(31,12,2021) | ///
date == td(30,6,2022) | ///
date == td(31,12,2022) | ///
date == td(30,6,2023) | ///
date == td(31,12,2023) | ///
date == td(30,6,2024) | ///
date == td(31,12,2024) | ///
date == td(30,6,2025) | ///
date == td(31,12,2025) | ///
date == td(30,6,2026)
gen B = tloss_CPI[11]-2000
tostring B, replace force format(%9.2fc)
texdoc local tot_`var' = B[1]
keep date CPI `var' aWMI_`var' tloss_CPI_`var' diff_`var'
order date CPI `var' aWMI_`var' diff_`var' tloss_CPI_`var'
tostring CPI `var' aWMI_`var' tloss_CPI_`var' diff_`var', replace force format(%15.2fc)
export delimited using T1_`var'.csv, delimiter(":") novarnames replace
restore
}
texdoc stlog close

/***
\color{black}

\begin{landscape}
\begin{table}[h!]
  \begin{center}
    \caption{Wages lost to inflation from July 2021 to June 2026 for a Lecturer, level A8.
The mean percentage behind inflation for the life of the agreement was `mu'\%.
The total lost over the agreement to inflation for this wage level was \$`tot_LA8' (i.e., including
the one-off \$2,000 payment).}
    \hspace*{-2cm}
    \label{T1_LA8}
     \pgfplotstabletypeset[
      col sep=colon,
      header=false,
      string type,
      display columns/0/.style={column name=Date, column type={l}},
      display columns/1/.style={column name=CPI, column type={r}},
      display columns/2/.style={column name=Full time earnings, column type={r}},
      display columns/3/.style={column name=\specialcell{Full-time earnings if they \\ matched CPI inflation}, column type={r}},
      display columns/4/.style={column name=Annualised loss to CPI, column type={r}},
      display columns/5/.style={column name=Cumulative loss to CPI, column type={r}},
      every head row/.style={
        before row={\toprule},
        after row={\midrule}
            },
    ]{T1_LA8.csv}
  \end{center}
\end{table}

\begin{table}[h!]
  \begin{center}
    \caption{Wages lost to inflation from July 2021 to June 2026 for an HEO 4.3.
The mean percentage behind inflation for the life of the agreement was `mu'\%.
The total lost over the agreement to inflation for this wage level was \$`tot_HEO43' (i.e., including
the one-off \$2,000 payment).}
    \hspace*{-2cm}
    \label{T1_HEO43}
     \pgfplotstabletypeset[
      col sep=colon,
      header=false,
      string type,
      display columns/0/.style={column name=Date, column type={l}},
      display columns/1/.style={column name=CPI, column type={r}},
      display columns/2/.style={column name=Full time earnings, column type={r}},
      display columns/3/.style={column name=\specialcell{Full-time earnings if they \\ matched CPI inflation}, column type={r}},
      display columns/4/.style={column name=Annualised loss to CPI, column type={r}},
      display columns/5/.style={column name=Cumulative loss to CPI, column type={r}},
      every head row/.style={
        before row={\toprule},
        after row={\midrule}
            },
    ]{T1_HEO43.csv}
  \end{center}
\end{table}

\begin{table}[h!]
  \begin{center}
    \caption{Wages lost to inflation from July 2021 to June 2026 for an HEO 5.5.
The mean percentage behind inflation for the life of the agreement was `mu'\%.
The total lost over the agreement to inflation for this wage level was \$`tot_HEO55' (i.e., including
the one-off \$2,000 payment)}
    \hspace*{-2cm}
    \label{T1_HEO55}
     \pgfplotstabletypeset[
      col sep=colon,
      header=false,
      string type,
      display columns/0/.style={column name=Date, column type={l}},
      display columns/1/.style={column name=CPI, column type={r}},
      display columns/2/.style={column name=Full time earnings, column type={r}},
      display columns/3/.style={column name=\specialcell{Full-time earnings if they \\ matched CPI inflation}, column type={r}},
      display columns/4/.style={column name=Annualised loss to CPI, column type={r}},
      display columns/5/.style={column name=Cumulative loss to CPI, column type={r}},
      every head row/.style={
        before row={\toprule},
        after row={\midrule}
            },
    ]{T1_HEO55.csv}
  \end{center}
\end{table}

\begin{table}[h!]
  \begin{center}
    \caption{Wages lost to inflation from July 2021 to June 2026 for an HEO 6.4.
The mean percentage behind inflation for the life of the agreement was `mu'\%.
The total lost over the agreement to inflation for this wage level was \$`tot_HEO64' (i.e., including
the one-off \$2,000 payment)}
    \hspace*{-2cm}
    \label{T1_HEO64}
     \pgfplotstabletypeset[
      col sep=colon,
      header=false,
      string type,
      display columns/0/.style={column name=Date, column type={l}},
      display columns/1/.style={column name=CPI, column type={r}},
      display columns/2/.style={column name=Full time earnings, column type={r}},
      display columns/3/.style={column name=\specialcell{Full-time earnings if they \\ matched CPI inflation}, column type={r}},
      display columns/4/.style={column name=Annualised loss to CPI, column type={r}},
      display columns/5/.style={column name=Cumulative loss to CPI, column type={r}},
      every head row/.style={
        before row={\toprule},
        after row={\midrule}
            },
    ]{T1_HEO64.csv}
  \end{center}
\end{table}


\end{landscape}

***/

/***
\end{document}
***/

texdoc close

! pdflatex Sydney_EA_wage_loss
! pdflatex Sydney_EA_wage_loss
! pdflatex Sydney_EA_wage_loss

erase Sydney_EA_wage_loss.aux
erase Sydney_EA_wage_loss.log
erase Sydney_EA_wage_loss.out

! git init .
! git add Inflation.do Inflation.pdf Sydney_EA_wage_loss.do Sydney_EA_wage_loss.pdf
! git commit -m "0"
! git remote remove origin
! git remote add origin https://github.com/jimb0w/Inflation.git
! git remote set-url origin git@github.com:jimb0w/Inflation.git
! git push --set-upstream origin master
