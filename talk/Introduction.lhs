%include clashtalk.fmt
\section{Introduction}

% \frame
% {
% \frametitle{Functional Languages \& Digital Hardware}
% \numbersreset
% \begin{code}
% halfAdder :: Bit -> Bit -> (Bit,Bit)
% haldAdder a b = (a `xor` b, a .&. b)
% \end{code}
% \smallskip
% \def\svgwidth{4cm}
% \centerline{\includesvg{halfAdder}}
% }

% \frame
% {
% \frametitle{Functional Languages \& Digital Hardware}
% \numbersreset
% \begin{code}
% fullAdder :: Bit -> Bit -> Bit -> (Bit,Bit)
% fullAdder a b cin = (s,cout)
%   where
%     (s1  ,c1)  = halfAdder a b
%     (s   ,c2)  = halfAdder s1 cin
%     cout       = c1 .|. c2
% \end{code}
% \def\svgwidth{7cm}
% \centerline{\includesvg{fullAdder}}
% }

% \frame{
% \frametitle{Content}
% \begin{itemize}
%   \item What is CλaSH
%   \item Why CλaSH?
%   \item How do you describe hardware in CλaSH?
%   \item Examples
%   \item Demo
%   \item Conclusions
% \end{itemize}
% }


% \frame{
% \frametitle{CλaSH}
% \begin{itemize}
%   \item \textbf{CλaSH}: CAES Language for Synchronous Hardware
%   \item A functional hardware description language
%   \item Supports: Polymorphism, Higher-Order functions, Algebraic Datatypes, Pattern Matching, Type Classes
% \end{itemize}
% }

% \frame{
% \frametitle{CλaSH and Haskell}
% \begin{itemize}
%   \item Every CλaSH description is a valid Haskell program
%   \item Not every Haskell program is a valid CλaSH Description:
%   \begin{itemize}
%     \item Recursive/Inductive Datatypes
%     \item Recursive function definitions
%   \end{itemize}
% \end{itemize}
% \bigskip
% \bigskip
% \only<2>{
% Compilation issues for a next lecture
% }
% }

% \frame
% {
% \vspace{2cm}\centerline{\Huge{
% Questions?
% }}
% \vspace{2cm}
% \centerline{http://clash.ewi.utwente.nl}
% }

% \frame
% {
% \frametitle{Problems with hardware design today}
% \begin{itemize}
%   \item Productivity of HW designer has not kept up with improvements in chip production.
%   \item Traditional languages such as VHDL and Verilog lack support for highly needed abstraction mechanisms.
% \end{itemize}
% }

% \frame
% {
%   \frametitle{Hardware and Functional Languages}
%   \begin{itemize}
%     \item Combinational Hardware can be directly modeled as mathematical functions.
%     \item Functional languages languages lend themselves very well to describe and (de-)compose those mathematical functions.
%     \item Operations in a functional languages have no order; only respect data-dependencies $\Rightarrow$ They can happen in parallel!
%     \item Conclusion: perfect semantic match of hardware and functional languages
%   \end{itemize}
% }
