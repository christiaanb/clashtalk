%include clashtalk.fmt

\begin{frame}
  \frametitle{Reduction circuit}

  Reduce (add) rows of floating point values:

  The row: \textcolor{red}{3,3,5},\textcolor{blue}{1,9,2},\textcolor{brown}{6,7,9,1}
  Results in: \textcolor{red}{11},\textcolor{blue}{12},\textcolor{brown}{23}
  \newline
  \newline
  \newline
  Acknowledgements: Work and slides by Marco Gerards
\end{frame}

% \begin{frame}[t]
% \frametitle{Demonstration}
% \input{talk/test.dem}
% \end{frame}

\begin{frame}
  \frametitle{Schematic representation of hardware components}
    \scalebox{0.75}{
      \input{talk/reduction.dem}
    }
\end{frame}

\begin{frame}<1,2,3,4,5>
\frametitle{Reduction circuit as transition functions}
\setbeamercovered{transparent}
\begin{columns}[t]
  \begin{column}[T]{5cm}
    \input{talk/frame_redcode2.dem}
  \end{column}
  \begin{column}[T]{3cm}
    \scalebox{0.3}{
        \input{talk/reduction.dem}
      }
  \end{column}
\end{columns}
\setbeamercovered{invisible}
\end{frame}

\section{Dealing with state}
\begin{frame}
\frametitle{Dealing with state}

Packing + unpacking the state: Cumbersome
\vspace{2em}

\only<1>{\mbox{}}
\only<2->{\textcolor{red}{Solution: hide the state}}
\\[2em]
\onslide<3->
\begin{itemize}
\item Use a concept called the Automata Arrow
\item We `lift' transition functions to components.
\item A component is a function with a hidden internal state.
\end{itemize}
\end{frame}

\begin{frame}
\frametitle{Lifting functions to components}
\onslide<1->{
Type definition:
\numbersreset
\begin{code}
(^^^) :: (State s -> i ->(State s,o)) -> s -> Comp i o
\end{code}
}

\onslide<2->{
Using it:
\numbersreset
\begin{code}
macT (State s) (a,b) = (State s', s)
  where
    s' = s + a * b

macC = macT ^^^ 0
\end{code}
}
\end{frame}

\begin{frame}
\frametitle{Reduction Circuit using Components}
%{
%format D    = "\mathcal{D}"
%format I    = "\mathcal{I}"
%format P    = "\mathcal{P}"
%format R    = "\mathcal{R}"
%format C    = "\mathcal{C}"
%format s(a) = "\sigma_{" a "}^{0}"
%format i_1 = "i_{1}"
%format i_2 = "i_{2}"
%format a_1 = "a_{1}"
%format a_2 = "a_{2}"
%format delta = "\delta"
%format rho  = "\rho"
\numbersreset
\begin{code}
reducer = proc (x,i) -> do
  rec  (new,d)             <- D  ^^^ s(D)   -< i
       (i_1,i_2)           <- I  ^^^ s(I)   -< (x, d, delta)
       rho                 <- P  ^^^ s(P)   -< (a_1, a_2)
       (r,y)               <- R  ^^^ s(R)   -< (new,d,rho,r')
       (a_1,a_2,delta,r')  <- C  ^^^ s(C)   -< (i_1, i_2, rho, r)
  returnA -< y
\end{code}
%}
\end{frame}


\begin{frame}<5>
\frametitle{Reduction circuit as Transition functions}
\setbeamercovered{transparent}
\begin{columns}[t]
  \begin{column}[T]{5cm}
    \input{talk/frame_redcode2.dem}
  \end{column}
  \begin{column}[T]{3cm}
    \scalebox{0.3}{
        \input{talk/reduction.dem}
      }
  \end{column}
\end{columns}
\setbeamercovered{invisible}
\end{frame}

\begin{frame}
\frametitle{Discussion}
\onslide<1->{
\begin{itemize}
  \item Components allow us to easily compose functions that have a statefull behavior
  \item We can bind different initial states to the same transfer function
\end{itemize}
}

\onslide<2->{
More advanced benefits:
\begin{itemize}
  \item Bind additional information to a transfer function, such as a clock domain |->| multi-clock descriptions
\end{itemize}
}
\end{frame}

\frame
{
\vspace{2cm}\centerline{\Huge{
Questions?
}}
\vspace{2cm}
\centerline{http://clash.ewi.utwente.nl}
}
