%include clashtalk.fmt
% \section{Examples}

% \subsection{MAC}
\frame
{
    \frametitle{Multiply-and-Add}
\numbersreset
    \begin{code}
ma x y a = x * y + a
    \end{code}
%     \only<2->{
% \numbersreset
%       \begin{code}
% type Int16 = Signed 16
% mac16 :: Int16 -> Int16 -> Int16 -> Int16
% mac16 = mac
%       \end{code}
%     }
    \smallskip
    \def\svgwidth{6cm}
    \centerline{\includesvg{mac}}
    % \only<2-> {
    %   \def\svgwidth{4.5cm}
    %   \includesvg{mac16}
    % }
}

\frame
{
    \frametitle{Multiply-Accumulate}
\numbersreset
    \begin{code}
mac x y = s
  where
    s'  = ma x y s
    s   = register 0 s'
    \end{code}
    \smallskip
    \def\svgwidth{6cm}
    \centerline{\includesvg{smac}}
}

% \subsection{Simulation}
% \frame
% {
%     \frametitle{Simulation}
%     \only<1-> {
%       Map the hardware over a series of inputs, using the state as an accumulator
% \numbersreset

%       \begin{code}
% simulate _    _ []      = []
% simulate hw   s (i:is)  = o : (simulate hw s' is)
%   where
%     (s',o) = hw s i
%       \end{code}
%     }
%     \only<2-> {
%       Simulation run of the stateful multiply-accumulate:
% \numbersreset
%       \begin{code}
% simulateMac = simulate macS (State 0)
%   [(2,3),(2,2),(3,7),(4,7)]
%       \end{code}
%     }
%     \only<3-> {
%       Simulation result:
% \numbersreset
%       \begin{code}
% > simulateMac
% [0,6,10,31]
%       \end{code}
%     }
% }

% \subsection{Higher Order functions}
\frame
{
\frametitle{Vectors \& Higher-Order functions}
\numbersreset
\begin{code}
data Vec a
  =  Nil
  |  a :> (Vec a)
\end{code}

\begin{code}
map :: (a -> b) -> Vec a -> Vec b
map f Nil      = Nil
map f (x:>xs)  = (f a) :> (map f xs)
\end{code}

\centerline{\Large{map f xs}}\smallskip
\centerline{\includesvg{map}}
}

\frame
{
  \frametitle{Other higher-order functions: zipWith \& reduce}

  \centerline{\Large{zipWith f xs ys}}\smallskip
  \def\svgwidth{8.5cm}
  \centerline{\includesvg{zipWith}}

  \bigskip

  \centerline{\Large{reduce f xs}}\smallskip
  \def\svgwidth{8.5cm}
  \centerline{\includesvg{reduce}}
}


\frame
{
\frametitle{FIR filter - Definition}
An FIR filter is the dot-product of:
\begin{itemize}
  \item Filter coefficients (\textbf{h})
  \item A stream of input values (\textbf{x})
\end{itemize}

\[
y_t = \sum\limits_{i=0}^{N-1}{h_{i} \cdot x_{t-i}}
\]
}

\frame
{
    \frametitle{Dot-product}
    \[
    \mathbf{a} \bullet \mathbf{b} = \sum\limits_{i = 0}^{N - 1} {a_i } \cdot b_i
    \]
    \smallskip
    \smallskip
    \numbersreset
    \begin{code}
    sum       = reduce (+)
    as ** bs  = sum (zipWith (*) as bs)
    \end{code}
}

%format rememberN = "remember_{N}"
%format x_t       = "x_{t}"
%format x_1       = "x_{t-1}"
%format x_2       = "x_{t-2}"
%format x_N       = "x_{t-N+1}"

\frame
{
\frametitle{Creating a stream}
\begin{center}
Create a stream using the \hs{rememberN} function:
\[
\mathit{remember_{N}}\ x_{t} \Rightarrow [x_{t},x_{t-1},x_{t-2},...,x_{t-N+1}]
\]
\end{center}
\def\svgwidth{8.5cm}
\hspace{-0.35cm}\centerline{\includesvg{remembern}}
}

%format y_t = "y_{t}"
\frame
{
    \frametitle{FIR Filter - Description}
      \[
      y_t = \sum\limits_{i=0}^{N-1}{h_{i} \cdot x_{t-i}}
      \]
      \numbersreset
      \begin{code}
fir hs x_t = y_t
  where
    y_t  = hs ** xs
    xs   = rememberN x_t
      \end{code}
}

\frame{
    \frametitle{4-Tap FIR filter}
      \numbersreset
      \begin{code}
fir4 = fir hs
  where
    hs = V [2 :: Int16,3,-2,8]
      \end{code}
      \def\svgwidth{8.5cm}
    \centerline{\includesvg{4tapfir}}

}

\frame
{
    \frametitle{4-Tap FIR filter}
    \numbersreset
    \begin{code}
    sum       = reduce (+)
    as ** bs  = sum (zipWith (*) as bs)
    fir4 x_t  = V [2 :: Int16,3,-2,8] ** (rememberN x_t)
    \end{code}
    \def\svgwidth{8.5cm}
    \centerline{\includesvg{4tapfir}}
}

\setlength{\columnseprule}{0.4pt}

\frame{
\frametitle{Dot-Product: Generated VHDL}
\numbersreset
\begin{code}
sum       = reduce (+)
as ** bs  = sum (zipWith (*) as bs)
\end{code}
\hrule
\begin{multicols}{2}
\vhdlfont{
\begin{verbatim}
-- Automatically generated VHDL
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use STD.TEXTIO.ALL;
use work.types.all;
use work.all;
entity ztzt_3 is
  port(as_i1 : in signed16_vector(3 downto 0);
       bs_i2 : in signed16_vector(3 downto 0);
       res_o : out signed(15 downto 0));
end entity ztzt_3;
architecture str of ztzt_3 is
  signal arg_0 : signed16_vector(3 downto 0);
  signal arg_0_tmp1 : signed(15 downto 0);
  signal arg_0_tmp2 : signed(15 downto 0);
  signal arg_0_tmp3 : signed(15 downto 0);
  signal arg_0_tmp4 : signed(15 downto 0);
begin
  comp_inst_res_o : entity sum_4
  port map (p_i1 => arg_0,res_o => res_o);
  arg_0_tmp1 <= resize((as_i1(0) * bs_i2(0)),16);
  arg_0_tmp2 <= resize((as_i1(1) * bs_i2(1)),16);
  arg_0_tmp3 <= resize((as_i1(2) * bs_i2(2)),16);
  arg_0_tmp4 <= resize((as_i1(3) * bs_i2(3)),16);
  arg_0 <= (arg_0_tmp4,arg_0_tmp3,arg_0_tmp2,arg_0_tmp1);
end architecture str;
\end{verbatim}}
\end{multicols}
}

\begin{frame}[plain]
  \centerline{\includegraphics[width=\paperwidth]{images/fir_rtl_0.png}}
\end{frame}
\begin{frame}[plain]
  \centerline{\includegraphics[width=\paperwidth]{images/fir_rtl_1.png}}
\end{frame}
\begin{frame}[plain]
  \centerline{\includegraphics[width=\paperwidth]{images/fir_rtl_2.png}}
\end{frame}

\frame
{
\frametitle{Not shown today}
\begin{itemize}
  \item Self-defined higher-order functions
  \item Algebraic datatypes
  \item Pattern-Maching $\Rightarrow$ Control structures
  \item Type-Classes
  \item Multi-clock Designs
\end{itemize}
}

% \subsection{CPU}
% \frame
% {
%     \frametitle{Simple CPU}
%     \def\svgwidth{12cm}
%     \hspace{-0.4cm}\centerline{\includesvg{cpu}}
% }

% \frame
% {
%   \frametitle{Fixed function function units}
%   \numbersreset
%   \begin{code}
%   fu op inputs (a1, a2) =
%     op (inputs!a1) (inputs!a2)
%   \end{code}
%   \vspace{1cm}
%   \numbersreset
%   \begin{code}
%   fu1 = fu (+)
%   fu2 = fu (-)
%   fu3 = fu (*)
%   \end{code}
% }

% \frame
% {
%     \frametitle{Simple CPU}
%     \def\svgwidth{12cm}
%     \hspace{-0.4cm}\centerline{\includesvg{cpu}}
% }

% \frame
% {
%   \frametitle{Multi-purpose function unit}
%   \numbersreset
%   \begin{code}
%   data Opcode = Shift | Xor | Equal

%   multiop Shift   = shift
%   multiop Xor     = xor
%   multiop Equal   = \a b -> if a == b then 1 else 0
%   \end{code}
%   \vspace{2cm}
%   \numbersreset
%   \begin{code}
%   fu0 c = fu (multiop c)
%   \end{code}
% }

% \frame
% {
%     \frametitle{Simple CPU}
%     \def\svgwidth{12cm}
%     \hspace{-0.4cm}\centerline{\includesvg{cpu}}
% }

% \frame
% {
%   \frametitle{The complete CPU}
%   \numbersreset
%   \begin{code}
% type CpuState = Vector 4 Int16

% cpuT :: CpuState
%   -> (Int16, Opcode, Vector 4 (Index 7, Index 7))
%   -> (CpuState, Int16)
% cpuT s (x, opc, addrs) = (s', out)
%   where
%     inputs = x +> 0 +> 1 +> s
%     s'     = (fu0 opc inputs (addrs!0))   +>
%              (fu1     inputs (addrs!1))   +>
%              (fu2     inputs (addrs!2))   +>
%              (fu3     inputs (addrs!3))   +>
%              empty
%     out    = last s
%   \end{code}
% }

% \begin{frame}[plain]
%    \centerline{\includegraphics[width=\paperwidth]{images/cpu.png}}
% \end{frame}

% \begin{frame}[plain]
%    \centerline{\includegraphics[height=\paperheight]{images/fu.png}}
% \end{frame}
