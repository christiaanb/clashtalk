%include clashtalk.fmt
\section{Examples}

\subsection{MAC}
\frame
{
    \frametitle{Multiply-accumulate}
\numbersreset
    \begin{code}
mac acc x y = acc + x * y
    \end{code}
    \only<2-> {
\numbersreset
      \begin{code}
type Int16 = Signed 16
mac16 :: Int16 -> Int16 -> Int16 -> Int16
mac16 = mac
      \end{code}
    }
    \smallskip
    \def\svgwidth{6cm}
    \centerline{\includesvg{mac}
    \only<2-> {
      \def\svgwidth{4.5cm}
      \includesvg{mac16}
    }}
}

\frame
{
    \frametitle{Stateful multiply-accumulate}
\numbersreset
    \begin{code}
macS s (x,y) = (s',s)
  where
    s' = mac16 s x y
    \end{code}
    \smallskip
    \def\svgwidth{6cm}
    \centerline{\includesvg{smac}}
}

\subsection{Simulation}
\frame
{
    \frametitle{Simulation}
    \only<1-> {
      Map the hardware over a series of inputs, using the state as an accumulator
\numbersreset

      \begin{code}
simulate _    _ []      = []
simulate hw   s (i:is)  = o : (simulate hw s' is)
  where
    (s',o) = hw s i
      \end{code}
    }
    \only<2-> {
      Simulation run of the stateful multiply-accumulate:
\numbersreset
      \begin{code}
simulateMac = simulate macS (State 0)
  [(2,3),(2,2),(3,7),(4,7)]
      \end{code}
    }
    \only<3-> {
      Simulation result:
\numbersreset
      \begin{code}
> simulateMac
[0,6,10,31]
      \end{code}
    }
}

\subsection{Higher Order functions}
\frame
{
  \frametitle{map, zipWith and foldl}

  \centerline{map f xs}\smallskip
  \centerline{\includesvg{map}}

  \centerline{zipWith f xs ys}\smallskip
  \centerline{\includesvg{zipWith}}


  \centerline{foldl f z xs}\smallskip
  \centerline{\includesvg{fold}}
}

\frame
{
    \frametitle{Dot-product}
    \centerline{The dot-product}
    \[
    \overrightarrow a  \bullet \overrightarrow b  = \sum\nolimits_{i = 0}^{n - 1} {a_i }  \cdot b_i
    \]
    \smallskip
    \smallskip
    \numbersreset
    \begin{code}
    dotp z as bs = foldl (+) z (zipWith (*) as bs)
    \end{code}
}

\frame
{
    \frametitle{FIR filter}
    \only<1> {
      \numbersreset
      \begin{code}
e +>> v  = e +> (init v)

fir hs pxs x = (x +>> xs, dotp 0 pxs hs)
      \end{code}
    }
    \only<2-> {
      \numbersreset
      \begin{code}
type Fir4S = Vector 4 Int16

fir4T :: Fir4S -> Int16 -> (Fir4S, Int16)
fir4T xs x = (xs', y)
  where
    (xs',y) = fir [2,3,-2,8] xs x
      \end{code}
    }
}

\frame
{
    \frametitle{FIR Filter}
    \numbersreset
    \begin{code}
    e +>> v  = e +> (init v)
    dotp z as bs = foldl (+) z (zipWith (*) as bs)
    \end{code}
    \def\svgwidth{9cm}
    \centerline{\includesvg{4tapfir}}
}

\subsection{CPU}
\frame
{
    \frametitle{Simple CPU}
    \def\svgwidth{12cm}
    \hspace{-0.4cm}\centerline{\includesvg{cpu}}
}

\frame
{
  \frametitle{Fixed function function units}
  \numbersreset
  \begin{code}
  fu op inputs (a1, a2) =
    op (inputs!a1) (inputs!a2)
  \end{code}
  \vspace{1cm}
  \numbersreset
  \begin{code}
  fu1 = fu (+)
  fu2 = fu (-)
  fu3 = fu (*)
  \end{code}
}

\frame
{
    \frametitle{Simple CPU}
    \def\svgwidth{12cm}
    \hspace{-0.4cm}\centerline{\includesvg{cpu}}
}

\frame
{
  \frametitle{Multi-purpose function unit}
  \numbersreset
  \begin{code}
  data Opcode = Shift | Xor | Equal

  multiop Shift   = shift
  multiop Xor     = xor
  multiop Equal   = \a b -> if a == b then 1 else 0
  \end{code}
  \vspace{2cm}
  \numbersreset
  \begin{code}
  fu0 c = fu (multiop c)
  \end{code}
}

\frame
{
    \frametitle{Simple CPU}
    \def\svgwidth{12cm}
    \hspace{-0.4cm}\centerline{\includesvg{cpu}}
}

\frame
{
  \frametitle{The complete CPU}
  \numbersreset
  \begin{code}
type CpuState = Vector 4 Int16

cpuT :: CpuState
  -> (Int16, Opcode, Vector 4 (Index 7, Index 7))
  -> (CpuState, Int16)
cpuT s (x, opc, addrs) = (s', out)
  where
    inputs = x +> 0 +> 1 +> s
    s'     = (fu0 opc inputs (addrs!0))   +>
             (fu1     inputs (addrs!1))   +>
             (fu2     inputs (addrs!2))   +>
             (fu3     inputs (addrs!3))   +>
             empty
    out    = last s
  \end{code}
}

\begin{frame}[plain]
   \centerline{\includegraphics[width=\paperwidth]{images/cpu.png}}
\end{frame}

\begin{frame}[plain]
   \centerline{\includegraphics[height=\paperheight]{images/fu.png}}
\end{frame}
