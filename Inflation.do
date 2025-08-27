
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

texdoc stlog, nolog nodo
*Grab the data from the ABS
cd /home/jimb0w/Documents/Inflation
copy https://www.abs.gov.au/statistics/labour/earnings-and-working-conditions/average-weekly-earnings-australia/may-2025/6302001.xlsx Wages.xlsx, replace
copy https://www.abs.gov.au/statistics/economy/price-indexes-and-inflation/consumer-price-index-australia/jun-quarter-2025/640101.xlsx CPI.xlsx, replace
copy https://www.abs.gov.au/statistics/economy/price-indexes-and-inflation/selected-living-cost-indexes-australia/jun-2025/646701.xlsx ECLI.xlsx, replace
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
*Look at the data
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
(connected ECLI_I date, col(magenta)) ///
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
graph save crude_total, replace
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
(connected ECLI1 date, col(magenta)) ///
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
graph save crude_period, replace
use wages, clear
drop if date < td(1,5,2021)
gen AFT_I = 100*A_FT/A_FT[1]
gen AT_I = 100*A_T/A_T[1]
append using cpi1 ecli1
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
graph save crude_period_individual, replace
use wages, clear
drop if date < td(1,5,2021)
centile(date), centile(5 35 65 95)
local A1 = r(c_1)
local A2 = r(c_2)
local A3 = r(c_3)
local A4 = r(c_4)
mkspline timesp = date, cubic knots(`A1' `A2' `A3' `A4')
reg A_FT timesp*
predict A_FT1
forval i = 2021(1)2025 {
local i`i' = td(1,1,`i')
}
twoway ///
(scatter A_FT date) ///
(line A_FT1 date) ///
, ytitle(AUD (weekly)) xtitle(Calendar time) ///
xlabel( ///
`i2021' "2021" ///
`i2022' "2022" ///
`i2023' "2023" ///
`i2024' "2024" ///
`i2025' "2025") ///
legend(position(3) ///
order(1 "Actual" ///
2 "Modelled") cols(1))
graph save FTwage_modelcheck, replace
clear
set obs 1461
gen date = td(1,7,2021) if _n == 1
replace date = date[_n-1]+1 if _n > 1
format date %td
mkspline timesp = date, cubic knots(`A1' `A2' `A3' `A4')
predict A_FT1
keep date A_FT1
gen increment = 1 if date <= td(31,12,2021)
replace increment = 2 if inrange(date,td(1,1,2022),td(31,12,2022))
replace increment = 3 if inrange(date,td(1,1,2023),td(31,12,2023))
replace increment = 4 if inrange(date,td(1,1,2024),td(31,12,2024))
replace increment = 5 if inrange(date,td(1,1,2025),td(31,12,2025))
bysort increment (date) : gen FT = A_FT1[1]
gen dFT = FT/7
gen aFT = 365.25*FT/7
gen ST = A_FT1[1]
gen dST = ST/7
save ftwfm, replace
use wages, clear
drop if date < td(1,5,2021)
centile(date), centile(5 35 65 95)
local A1 = r(c_1)
local A2 = r(c_2)
local A3 = r(c_3)
local A4 = r(c_4)
mkspline timesp = date, cubic knots(`A1' `A2' `A3' `A4')
reg A_T timesp*
predict A_T1
forval i = 2021(1)2025 {
local i`i' = td(1,1,`i')
}
twoway ///
(scatter A_T date) ///
(line A_T1 date) ///
, ytitle(AUD (weekly)) xtitle(Calendar time) ///
xlabel( ///
`i2021' "2021" ///
`i2022' "2022" ///
`i2023' "2023" ///
`i2024' "2024" ///
`i2025' "2025") ///
legend(position(3) ///
order(1 "Actual" ///
2 "Modelled") cols(1))
graph save Twage_modelcheck, replace
clear
set obs 1461
gen date = td(1,7,2021) if _n == 1
replace date = date[_n-1]+1 if _n > 1
format date %td
mkspline timesp = date, cubic knots(`A1' `A2' `A3' `A4')
predict A_T1
keep date A_T1
gen increment = 1 if date <= td(31,12,2021)
replace increment = 2 if inrange(date,td(1,1,2022),td(31,12,2022))
replace increment = 3 if inrange(date,td(1,1,2023),td(31,12,2023))
replace increment = 4 if inrange(date,td(1,1,2024),td(31,12,2024))
replace increment = 5 if inrange(date,td(1,1,2025),td(31,12,2025))
bysort increment (date) : gen T = A_T1[1]
gen dT = T/7
gen aT = 365.25*T/7
gen ST = A_T1[1]
gen dST = ST/7
save twfm, replace
use cpi1, clear
drop CPI CPI_I
drop if date < td(1,5,2021)
replace date = date-16
centile(date), centile(5 35 65 95)
local A1 = r(c_1)
local A2 = r(c_2)
local A3 = r(c_3)
local A4 = r(c_4)
mkspline timesp = date, cubic knots(`A1' `A2' `A3' `A4')
reg CPI1 timesp*
predict CPI
forval i = 2021(1)2025 {
local i`i' = td(1,1,`i')
}
twoway ///
(scatter CPI1 date) ///
(line CPI date) ///
, ytitle(CPI index) xtitle(Calendar time) ///
xlabel( ///
`i2021' "2021" ///
`i2022' "2022" ///
`i2023' "2023" ///
`i2024' "2024" ///
`i2025' "2025") ///
legend(position(3) ///
order(1 "Actual" ///
2 "Modelled") cols(1))
graph save CPI_modelcheck, replace
clear
set obs 1461
gen date = td(1,7,2021) if _n == 1
replace date = date[_n-1]+1 if _n > 1
format date %td
mkspline timesp = date, cubic knots(`A1' `A2' `A3' `A4')
predict CPI
keep date CPI
gen CPI1 = 100*CPI/CPI[1]
drop CPI
replace CPI = CPI1
save cpifm, replace
use ecli1, clear
drop ECLI ECLI_I
drop if date < td(1,5,2021)
replace date = date-16
centile(date), centile(5 35 65 95)
local A1 = r(c_1)
local A2 = r(c_2)
local A3 = r(c_3)
local A4 = r(c_4)
mkspline timesp = date, cubic knots(`A1' `A2' `A3' `A4')
reg ECLI1 timesp*
predict ECLI
forval i = 2021(1)2025 {
local i`i' = td(1,1,`i')
}
twoway ///
(scatter ECLI1 date) ///
(line ECLI date) ///
, ytitle(ECLI index) xtitle(Calendar time) ///
xlabel( ///
`i2021' "2021" ///
`i2022' "2022" ///
`i2023' "2023" ///
`i2024' "2024" ///
`i2025' "2025") ///
legend(position(3) ///
order(1 "Actual" ///
2 "Modelled") cols(1))
graph save ECLI_modelcheck, replace
clear
set obs 1461
gen date = td(1,7,2021) if _n == 1
replace date = date[_n-1]+1 if _n > 1
format date %td
mkspline timesp = date, cubic knots(`A1' `A2' `A3' `A4')
predict ECLI
keep date ECLI
gen ECLI1 = 100*ECLI/ECLI[1]
drop ECLI
replace ECLI = ECLI1
save eclifm, replace
use ftwfm, clear
merge 1:1 date using cpifm, nogen
merge 1:1 date using eclifm, nogen
gen WMI = dST*CPI1/100
gen WME = dST*ECLI1/100
gen loss_CPI = WMI-dFT
gen loss_ECLI = WME-dFT
gen tloss_CPI = sum(loss_CPI)
gen tloss_ECLI = sum(loss_ECLI)
gen normalisedwage = 100*FT/ST
forval i = 2021(1)2025 {
local i`i' = td(1,1,`i')
}
twoway ///
(line CPI date, col(black)) ///
(line normalisedwage date, col(black)) ///
(rarea CPI normalisedwage date, color(black%30) fintensity(inten80) lwidth(none)) ///
, ytitle(Index) xtitle(Calendar time) ///
xlabel( ///
`i2021' "2021" ///
`i2022' "2022" ///
`i2023' "2023" ///
`i2024' "2024" ///
`i2025' "2025") ///
legend(off)
graph save whatestimated_CPI, replace
forval i = 2021(1)2025 {
local i`i' = td(1,1,`i')
}
twoway ///
(line tloss_ECLI date, col(dknavy)) ///
(line tloss_CPI date, col(magenta)) ///
, ytitle(AUD) xtitle(Calendar time) ///
xlabel( ///
`i2021' "2021" ///
`i2022' "2022" ///
`i2023' "2023" ///
`i2024' "2024" ///
`i2025' "2025") ///
legend(position(3) ///
order(1 "Cumulative total lost to ECLI" ///
2 "Cumulative total lost to CPI") cols(1)) ///
ylabel(, format(%9.0fc))
graph save cumloss, replace
keep if ///
date == td(31,12,2021) | ///
date == td(30,6,2022) | ///
date == td(31,12,2022) | ///
date == td(30,6,2023) | ///
date == td(31,12,2023) | ///
date == td(30,6,2024) | ///
date == td(31,12,2024) | ///
date == td(30,6,2025)
gen aWMI=WMI*365.25
gen aWME=WME*365.25
keep date aFT aWME aWMI tloss_CPI tloss_ECLI
tostring aFT-aWME, replace force format(%15.2fc)
order date aFT aWMI aWME
export delimited using T1.csv, delimiter(":") novarnames replace
texdoc stlog close


/***

The goal was to estimate the total earnings (in dollars) lost to inflation
for an average earner from July 2021 to June 2025 in Australia.
Data were sourced directly from the Australian Bureau of Statistics 
(see the methods for full sources), and are shown in Figure~\ref{crude_period}.
The slope of the lines is representative of an average across the economy,
but for an individual wage earner, who only gets a pay rise once a year, while prices
rise more or less continuously, the actual experience looks more like Figure~\ref{crude_period_individual}.

We calculated the cumulative
lost earnings to inflation (i.e., the area shown in Figure~\ref{whatestimated_CPI})
under the following
assumptions:
\begin{itemize}
\item The period of study starts at 1 July 2021 and ends on 30 June 2025.
\item Workers receive annual wage rises on 1 January each year (timed to be at the mid-point
of the study yearly cycles). 
\item Inflation is continuous.
\end{itemize}

The results are shown in Figure~\ref{cumloss} and Table~\ref{T1}.

***/

texdoc stlog, nolog
graph use crude_period.gph
texdoc graph, label(crude_period) figure(h!) cabove ///
caption(Crude data derived from the ABS.)
graph use crude_period_individual.gph
texdoc graph, label(crude_period_individual) figure(h!) cabove ///
caption(Schematic of what inflation looks like for an individual.)
graph use whatestimated_CPI.gph
texdoc graph, label(whatestimated_CPI) figure(h!) cabove ///
caption(Illustration of what was estimated.)
graph use cumloss.gph
texdoc graph, label(cumloss) figure(h!) cabove ///
caption(Cumulative loss to inflation for the average full time worker.)
texdoc stlog close

/***
\color{black}

\begin{landscape}
\begin{table}[h!]
  \begin{center}
    \caption{Summary statistics.}
    \hspace*{-2cm}
    \label{T1}
     \pgfplotstabletypeset[
      col sep=colon,
      header=false,
      string type,
      display columns/0/.style={column name=Date, column type={l}},
      display columns/1/.style={column name=Full-time earnings, column type={r}},
      display columns/2/.style={column name=\specialcell{Full-time earnings if they \\ matched CPI inflation}, column type={r}},
      display columns/3/.style={column name=\specialcell{Full-time earnings if they \\ matched ECLI inflation}, column type={r}},
      display columns/4/.style={column name=Cumulative loss to CPI, column type={r}},
      display columns/5/.style={column name=Cumulative loss to ECLI, column type={r}},
      every head row/.style={
        before row={\toprule},
        after row={\midrule}
            },
    ]{T1.csv}
  \end{center}
\end{table}
\end{landscape}

\clearpage
\section{Median earnings}

Mean earnings are right-skewed because of high-income earners;
median earnings probably more accurately capture the experience
for the average Australian than does the mean. 
Let's repeat the above calculations, but using median wage instead of mean.
This will also be stratified by sex.

***/

texdoc stlog, nolog nodo
copy https://www.abs.gov.au/statistics/labour/earnings-and-working-conditions/employee-earnings/aug-2024/63370_Table01.xlsx medianwage.xlsx, replace
import excel "/home/jimb0w/Documents/Inflation/medianwage.xlsx", sheet("Data 1") cellrange(A8:V5407) clear
keep if A == "Median weekly earnings"
keep if C == "Full-time"
keep if D == "Total"
keep B E V
gen yr = substr(E,-2,2)
drop if yr>"30"
replace yr = "08/15/20"+yr
gen date = date(yr,"MDY")
format date %td
drop E yr
rename V wages
replace B = subinstr(B," ","",.)
save medianwages, replace
use medianwages, clear
drop if date < td(1,5,2020)
centile(date), centile(5 35 65 95)
local A1 = r(c_1)
local A2 = r(c_2)
local A3 = r(c_3)
local A4 = r(c_4)
mkspline timesp = date, cubic knots(`A1' `A2' `A3' `A4')
foreach i in Persons Females Males {
preserve
reg wages timesp* if B == "`i'"
clear
set obs 1461
gen date = td(1,7,2021) if _n == 1
replace date = date[_n-1]+1 if _n > 1
format date %td
mkspline timesp = date, cubic knots(`A1' `A2' `A3' `A4')
predict medFT
keep date medFT
gen increment = 1 if date <= td(31,12,2021)
replace increment = 2 if inrange(date,td(1,1,2022),td(31,12,2022))
replace increment = 3 if inrange(date,td(1,1,2023),td(31,12,2023))
replace increment = 4 if inrange(date,td(1,1,2024),td(31,12,2024))
replace increment = 5 if inrange(date,td(1,1,2025),td(31,12,2025))
bysort increment (date) : gen FT = medFT[1]
gen dFT = FT/7
gen aFT = 365.25*FT/7
gen ST = medFT[1]
gen dST = ST/7
save medFT_`i', replace
restore
}
foreach ii in Persons Females Males {
use medFT_`ii', clear
merge 1:1 date using cpifm, nogen
merge 1:1 date using eclifm, nogen
gen WMI = dST*CPI1/100
gen WME = dST*ECLI1/100
gen loss_CPI = WMI-dFT
gen loss_ECLI = WME-dFT
gen tloss_CPI = sum(loss_CPI)
gen tloss_ECLI = sum(loss_ECLI)
gen normalisedwage = 100*FT/ST
forval i = 2021(1)2025 {
local i`i' = td(1,1,`i')
}
twoway ///
(line tloss_ECLI date, col(dknavy)) ///
(line tloss_CPI date, col(magenta)) ///
, ytitle(AUD) xtitle(Calendar time) ///
xlabel( ///
`i2021' "2021" ///
`i2022' "2022" ///
`i2023' "2023" ///
`i2024' "2024" ///
`i2025' "2025") ///
legend(position(3) ///
order(1 "Cumulative total lost to ECLI" ///
2 "Cumulative total lost to CPI") cols(1)) ///
ylabel(0(5000)25000, format(%9.0fc)) title(`ii', placement(west) col(black) size(medium))
graph save cumloss_`ii', replace
keep if ///
date == td(31,12,2021) | ///
date == td(30,6,2022) | ///
date == td(31,12,2022) | ///
date == td(30,6,2023) | ///
date == td(31,12,2023) | ///
date == td(30,6,2024) | ///
date == td(31,12,2024) | ///
date == td(30,6,2025)
gen aWMI=WMI*365.25
gen aWME=WME*365.25
keep date aFT aWME aWMI tloss_CPI tloss_ECLI
tostring aFT-aWME, replace force format(%15.2fc)
gen sex = "`ii'"
save T2_`ii', replace
}
clear
append using T2_Females T2_Males
order sex date aFT aWMI aWME
export delimited using T2.csv, delimiter(":") novarnames replace
texdoc stlog close
texdoc stlog, nolog
graph combine ///
cumloss_Females.gph ///
cumloss_Males.gph ///
, graphregion(color(white)) cols(2) altshrink xsize(15)
texdoc graph, label(cumloss) figure(h!) cabove ///
caption(Cumulative loss to inflation for the median full time worker, by sex.)
texdoc stlog close

/***
\color{black}


\begin{landscape}
\begin{table}[h!]
  \begin{center}
    \caption{Summary statistics.}
    \hspace*{-2cm}
    \label{T2}
     \pgfplotstabletypeset[
      col sep=colon,
      header=false,
      string type,
      display columns/0/.style={column name=Sex, column type={l}},
      display columns/1/.style={column name=Date, column type={l}},
      display columns/2/.style={column name=Full-time earnings, column type={r}},
      display columns/3/.style={column name=\specialcell{Full-time earnings if they \\ matched CPI inflation}, column type={r}},
      display columns/4/.style={column name=\specialcell{Full-time earnings if they \\ matched ECLI inflation}, column type={r}},
      display columns/5/.style={column name=Cumulative loss to CPI, column type={r}},
      display columns/6/.style={column name=Cumulative loss to ECLI, column type={r}},
      every head row/.style={
        before row={\toprule},
        after row={\midrule}
            },
        every nth row={8}{before row=\midrule},
    ]{T2.csv}
  \end{center}
\end{table}
\end{landscape}


\clearpage
\section{Methods}

TBD

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
