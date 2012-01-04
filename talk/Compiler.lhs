%include clashtalk.fmt
\section{Compiler}

\frame{
  \frametitle{CλaSH Compiler}
  \begin{itemize}
    \item \textbf{CλaSH}: CAES Language for Synchronous Hardware
    \item Compiles demonstrated hardware descriptions to VHDL
    \item VHDL can be processed by industry-standard tools to make real silicon, or allow prototyping on an FPGA
  \end{itemize}
}

\frame{
  \frametitle{CλaSH Compiler}
  \begin{center}
  Haskell $>$------ GHC (front-end) ------$>$ Core \\
    \ \\
     Core $>$------ Normalization ------$>$ Core \\
     \ \\
     Core $>$------ Back-end ------$>$ VHDL
  \end{center}
}

\frame{
  \frametitle{Why normalization?}
  \begin{itemize}
    \item Netlist: components connected by wires
    \item Core does not always correspond directly to a netlist
    \item Example problem: What is the name of the output port of the following function?: square x = x * x
  \end{itemize}
  
}

\frame{
  \frametitle{Transformation}
  func = E \\
  \rule{5cm}{0.3mm} E has no name \\
  func = let res = E in res \\
  \ \\
  square x = x*x \\
  \rule{5cm}{0.3mm} \\
  square x = let res = x*x in res
}

\frame{
\frametitle{Normal Form}
\begin{tabular}{lcll}
$u$ & $::=$   & $x\ \vert\ K$                                                        & Variables and Data \\
    &         &                                                                      & Constructors \\
$e$ & $::=$   & $u$                                                                  & Term atom\\
    & $\vert$ & $u\ \overline{x}$                                                    & Term application (arity $\equal$ 0)\\
$f$ & $::=$   & $e$                                                                  & User application\\
    & $\vert$ & $f$ $\varphi$                                                        & Type Application\footnote{Free variables in $f$ are builtin functions/constructors}\\
    & $\vert$ & $f$ $f_{2}$                                                          & Term Application\footnotemark[\value{footnote}]\\ 
    &         &                                                                      & \\
$p$ & $::=$   & $K\ \overline{c:\kappa}\ \overline{x:\tau}$                          & Patterns \\
    &         &                                                                      & \\
$g$ & $::=$   & $e\ \vert\ f$                                                        & User/Builtin application \\
    & $\vert$ & $\mathbf{case}\ x_{1}\ \mathbf{of}\ \overline{p \rightarrow x_{2}}$  & Branch on values\\
    & $\vert$ & $\mathbf{case}\ x_{1}\ \mathbf{of}\ K\ \overline{c:\kappa}\ \overline{x:\tau}\ \rightarrow x$  & Extract value \\
    &         &                                                                      & \\
$t$ & $::=$   & $\lambda x:\tau.t$                                                   & Term abstractions \\
    & $\vert$ & $\mathbf{let}\ \overline{x_{1}:\tau = g}\ \mathbf{in}\ x_{2}$        & Recursive let-binding \\
\end{tabular}
}

\frame{
\frametitle{Normal Form - Example}
Haskell:
\numbersreset
\begin{code}
invinc x = y + 1
  where
    y = inv x
\end{code}

Core:
\numbersreset
\begin{code}
invinc = \x -> 
  let   y = inv x
  in    y + 1
\end{code}

Normalized Core:
\numbersreset
\begin{code}
invinc = \x -> 
  let   y     = inv x
        z     = 1
        res   = y + z
  in    res
\end{code}
}

\frame{
%format entity       = "\textbf{entity}"
%format architecture = "\textbf{architecture}"
%format is           = "\textbf{is}"
%format out          = "\textbf{out}"
%format begin        = "\textbf{begin}"
%format end          = "\textbf{end}"
\frametitle{Generated VHDL}
\numbersreset
\begin{code}
invinc :: Signed D16 -> Signed D16
invinc = \x -> let y = inv x ; z = 1; res = y + z in res
\end{code}
\rule{\linewidth}{0.3mm}
\numbersreset
\begin{code}
entity invinc is
  port  (  x    : in    signed_16;
           res  : out   signed_16);
end entity invinc;

architecture structural of invinc is
  signal y : signed_16;
  signal z : signed_16;
begin
  y    <= inv x
  z    <= to_signed(1,16)
  res  <= x + z;
end architecture structural;
\end{code}
}

\frame
{
\frametitle{Another example}
\only<1>{
\numbersreset
\begin{code}
data OPC = ADD | MULT

alu ADD   = (+)
alu MULT  = (*)
\end{code}}
\only<2>{
\numbersreset
\begin{code}
alu = \opc -> 
  case opc of
    ADD   -> (+)
    MULT  -> (*)
\end{code}}
\only<3>{
\numbersreset
\begin{code}
alu = \opc -> 
  case opc of
    ADD   -> (+)
    MULT  -> (*)
\end{code}

\textbf{η-expansion} \\
E \\
\rule{5cm}{0.3mm} \\
λx.E x \\

\numbersreset
\begin{code}
alu = \opc x -> 
  (case opc of
    ADD   -> (+)
    MULT  -> (*)) x
\end{code}
}
\only<4>{
\numbersreset
\begin{code}
alu = \opc x -> 
  (case opc of
    ADD   -> (+)
    MULT  -> (*))  x
\end{code}
A few \textbf{η-expansion}s later:
\numbersreset
\begin{code}
alu = \opc x y -> 
  (case opc of
    ADD   -> (\a b -> (+) a b)
    MULT  -> (\p q -> (*) p q)) x y
\end{code}
}
\only<5>{
\textbf{app-propagation}
\numbersoff
\begin{code}
(case x of
  _(p)(0) -> _(E)(0)
  ...
  _(p)(n) -> _(E)(n)) M
\end{code}
\rule{5cm}{0.3mm}
\begin{code}
(case x of
  _(p)(0) -> _(E)(0) M
  ...
  _(p)(n) -> _(E)(n) M)
\end{code}
}
\only<6>{
\numbersreset
\begin{code}
alu = \opc x y -> 
  (case opc of
    ADD   -> (\a b -> (+) a b)
    MULT  -> (\p q -> (*) p q)) x y
\end{code}
Apply \textbf{app-propagation} 2 times:
\numbersreset
\begin{code}
alu = \opc x y -> 
  case opc of
    ADD   -> (\a b -> (+) a b) x y
    MULT  -> (\p q -> (*) p q) x y
\end{code}
}

\only<7>{
\numbersreset
\begin{code}
alu = \opc x y -> 
  case opc of
    ADD   -> (\a b -> (+) a b) x y
    MULT  -> (\p q -> (*) p q) x y
\end{code}

\textbf{β-reduction}  \\
(λx.E) M \\
\rule{5cm}{0.3mm} \\
\hs{E[x=>M]} \\

\numbersreset
\begin{code}
alu = \opc x y -> 
  case opc of
    ADD   -> (\b    -> (+) x b) y
    MULT  -> (\p q  -> (*) p q) x y
\end{code}
}

\only<8>{
\numbersreset
\begin{code}
alu = \opc x y -> 
  case opc of
    ADD   -> (\b    -> (+) x b) y
    MULT  -> (\p q  -> (*) p q) x y
\end{code}
A few \textbf{β-reduction}s later:
\numbersreset
\begin{code}
alu = \opc x y -> 
  case opc of
    ADD   -> (+) x y
    MULT  -> (*) x y
\end{code}
}

\only<9>{
\numbersreset
\begin{code}
alu = \opc x y -> 
  case opc of
    ADD   -> (+) x y
    MULT  -> (*) x y
\end{code}
\textbf{case-simplification}:
\numbersreset
\begin{code}
alu = \opc x y -> 
  let  a = (+) x y
       b = (*) x y
  in   case opc of ADD -> a ; MULT -> b
\end{code}
}

\only<10>{
\numbersreset
\begin{code}
alu = \opc x y -> 
  let  a = (+) x y
       b = (*) x y
  in   case opc of ADD -> a ; MULT -> b
\end{code}

\textbf{retval-simplification}  \\
\hs{let binds in E} \\
\rule{5cm}{0.3mm} \\
\hs{let binds, res = E in res} \\

\numbersreset
\begin{code}
alu = \opc x y -> 
  let  a    =  (+) x y
       b    =  (*) x y
       res  =  case opc of ADD -> a; MULT -> b
  in   res
\end{code}
}

\only<11>{
Haskell:
\numbersreset
\begin{code}
alu ADD   = (+)
alu MULT  = (*)
\end{code}
Normalized Core:
\numbersreset
\begin{code}
alu = \opc x y -> 
  let  a     = (+) x y
       b     = (*) x y
       res   = case opc of ADD -> a ; MULT -> b
  in   res
\end{code}
}

%format <= = "<="
\only<12>{
VHDL:
\numbersreset
\begin{code}
entity alu is
  port  (  opc  : in    opcode;
           x    : in    signed_16;
           y    : in    signed_16;
           res  : out   signed_16);
end entity alu;

architecture structural of alu is
  signal a : signed_16;
  signal b : signed_16;
begin
  a    <= x + y;
  b    <= resize_signed(x * y, 16);
  res  <= a when opc = 0 else b;
end architecture structural;
\end{code}
}
}