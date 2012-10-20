%include clashtalk.fmt
% \section{Introduction}

\frame
{
\frametitle{Parallel Functional Programming}
Functional programming:
\begin{itemize}
  \item \emph{Pure} by default, controlled / limited side-effects
  \item Only \emph{true} data dependencies $\Rightarrow$ easy to parallelize.
  \item ``Parallel by default''
\end{itemize}
}

\frame
{
\frametitle{Back then (80's): Tried, and failed to deliver}
Context:
\begin{itemize}
  \item Uniprocessors were getting faster, quickly
  \item Compilers were naive
  \item Parallel Computers were expensive
\end{itemize}
\bigskip
No story about:
\begin{itemize}
    \item Locality
    \item Exploiting regularity, and
    \item Granularity
  \end{itemize}
\bigskip
\scriptsize{Acknowledgements: Slide copied from Simon Peyton-Jones}
}

\frame
{
\frametitle{Now: Still trying, and starting to deliver}
Context:
\begin{itemize}
  \item Uniprocessors are stalled
  \item Compilers are pretty good
  \item Multi-core is everywhere
\end{itemize}
\bigskip
Progress:
\begin{itemize}
  \item Explicit threads + Software Transactional Memory
  \item Distributed memory and processes + Message passing
  \item Annotations for data parallelism:
  \begin{itemize}
    \item Implicit DP: Sparks + Worker threads
    \item Deterministic DP: Explicit dataflow
    \item Nested DP: trees, sparse-matrix, etc. $\Rightarrow$ Flatten to SIMD
  \end{itemize}
\end{itemize}
\bigskip
\scriptsize{Acknowledgements: Slide copied from Simon Peyton-Jones}
}

\frame
{
\frametitle{Annotations for Granularity}
All current approaches have a recurrent theme:
\begin{itemize}
  \item Developer annotates code for granularity and locality
  \item Purity and type safety guarantee the safe execution of a parallel program
\end{itemize}
}

\frame{
\frametitle{CλaSH goes a different direction}
\begin{itemize}
  \item Focus on implicit data-parallelism.
  \item Do not annotate the code.
  \item ``Automatic parallelisation'': everything that \emph{can} happen in parallel \emph{will} happen in parallel.
  \item Bad Idea for multi-core machines
  \item Good\footnote{But still naive} idea for FPGAs:
  \begin{itemize}
    \item Fine-grain parallelism
    \item Locality of data
    \item Local memories
  \end{itemize}
\end{itemize}
}

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


\frame{
\frametitle{CλaSH}
\begin{itemize}
  \item \textbf{CλaSH}: CAES Language for Synchronous Hardware
  \item A functional hardware description language
  % \item Supports: Polymorphism, Higher-Order functions, Algebraic Datatypes, Pattern Matching, Type Inference
  \item The CλaSH compiler takes a functional hardware description, and produces a netlist in the form of synthesizable VHDL code.
\end{itemize}
}

\frame{
  \frametitle{Using CλaSH}
  \def\svgwidth{6cm}
  $\hskip 0.9cm$\centerline{\includesvg{compilationchain}}
}

\frame{
\frametitle{CλaSH and Haskell}
\begin{itemize}
  \item Every CλaSH description is a valid Haskell program
  \item Use Haskell interpreter and compiler for fast simulation
  \item Not every Haskell program is a valid CλaSH Description:
  \begin{itemize}
    \item Recursive/Inductive Datatypes
    \item Recursive function definitions
    \item Difficult to imagine hardware for the above
  \end{itemize}
\end{itemize}
% \bigskip
% \bigskip
% \only<2>{
% Compilation issues for a next lecture
% }
}

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
