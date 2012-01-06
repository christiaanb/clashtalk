%include clashtalk.fmt
\section{Introduction}

\frame
{
\frametitle{Functional Languages \& Digital Hardware}
\numbersreset
\begin{code}
halfAdder :: Bit -> Bit -> (Bit,Bit)
haldAdder a b = (a `xor` b, a .&. b)
\end{code}
\smallskip
\def\svgwidth{4cm}
\centerline{\includesvg{halfAdder}}
}

\frame
{
\frametitle{Functional Languages \& Digital Hardware}
\numbersreset
\begin{code}
fullAdder :: Bit -> Bit -> Bit -> (Bit,Bit)
fullAdder a b cin = (s,cout)
  where
    (s1  ,c1)  = halfAdder a b
    (s   ,c2)  = halfAdder s1 cin
    cout       = c1 .|. c2
\end{code}
\def\svgwidth{7cm}
\centerline{\includesvg{fullAdder}}
}

\frame{
\frametitle{CλaSH}
\begin{itemize}
  \item \textbf{CλaSH}: CAES Language for Synchronous Hardware
  \item A functional hardware description language
  \item Supports: Polymorphism, Higher-Order functions, Algebraic Datatypes, Pattern Matching, Type Classes
\end{itemize}
}

\frame{
\frametitle{CλaSH and Haskell}
\begin{itemize}
  \item Every CλaSH description is a valid Haskell program
  \item Not every Haskell program is a valid CλaSH Description:
  \begin{itemize}
    \item Recursive/Inductive Datatypes
    \item Recursive function definitions
  \end{itemize}
\end{itemize}
\bigskip
\bigskip
\only<2>{
Will come back on the subject of recursive function definitons
}
}

\frame
{
\frametitle{CλaSH Compiler}
The CλaSH compiler takes a functional hardware description, and produces a netlist in the form of synthesizable VHDL code.

\smallskip
CλaSH compiler pipeline:
\begin{itemize}
  \item GHC frontend for: Parsing, Desugaring, and TypeChecking
  \item Normalization
  \item VHDL Code Generator
\end{itemize}
}

\frame{
\frametitle{Normalization}
Brings function hierarchy into a desired `normal' form:
\begin{itemize}
  \item Completely monomorphic
  \item No higher-order functions
  \item All function arguments are named (η-expansion + ANF)
  \item No nested let-bindings
  \item Scrutinee and alternatives of a case-statement are simple variables
  \item etc.
\end{itemize}
}

\frame{
\frametitle{Core Language}
\textbf{Types}
\begin{tabbing}
\hspace{0.2em} \= $τ,σ$ \= ::=      \= $α$ \hspace{8em}             \= Type variable references \\
               \>       \> $\ \mid$ \> $T\ \mid\ τ → σ$ \> Datatypes / Function Types \\
               \>       \> $\ \mid$ \> $τ\ σ$           \> Application \\
               \>       \> $\ \mid$ \> $∀α.σ$     \> Polymorphic types \\
\textbf{Expressions} \> \> \> \> \\
\hspace{0.2em} \> $e,u$ \> ::=      \> $x$                                               \> Variable reference \\
               \>       \> $\ \mid$ \> $K \mid ⊗$                                        \> Data Constructor / Primitive Function \\
               \>       \> $\ \mid$ \> $Λα.e\ \mid\ e \ τ$                       \> Type abstraction / application \\
               \>       \> $\ \mid$ \> $λx\!:\!σ.e\ \mid\ e\ u$                        \> Term abstraction / application \\
               \>       \> $\ \mid$ \> $\mathbf{let}\ \overline{x = e}\ \mathbf{in}\ u$  \> Recursive let-binding \\
               \>       \> $\ \mid$ \> $\mathbf{case}\ e\ \mathbf{of}\ \overline{p → u}$ \> Case decomposition \\
\textbf{Patterns} \> \> \> \> \\
\hspace{0.2em} \> $p$ \> ::=      \> $\_$              \> Default case \\
               \>     \> $\ \mid$ \> $K\ \overline{x}$ \> Match data constructor
\end{tabbing}
}

\frame
{
\frametitle{Polymorphism \& Hardware}
\numbersreset
\begin{code}
id :: α -> α
id a = a
\end{code}
\only<2->{
How many wires do I need to represent this function?
}
\only<3->{
\numbersreset
\begin{code}
main :: Bit -> Bit
main = id
\end{code}
}
\only<4->{
We intuitively know how many wires we need for the entire function hierarchy: 1
}
}

\frame{
\frametitle{From Intuition to Reality}
\numbersreset
\begin{code}
id = Λα.λ(a:α).a

main = id Bit
\end{code}
\only<2->{
Specialize on type:
\numbersreset
\begin{code}
idBit = (Λα.λ(a:α).a) Bit

main = idBit
\end{code}
}
\only<3->{
\numbersreset
\begin{code}
idBit :: Bit -> Bit
idBit a = a

main = idBit
\end{code}
}
}

\frame
{
\frametitle{Functional Values \& Hardware}
\numbersreset
\begin{code}
uncurry :: (α -> β -> γ) -> (α,β) -> γ
uncurry f (a,b) = f a b
\end{code}
\only<2->{
How many wires do I need to represent this function?
}
\only<3->{
\numbersreset
\begin{code}
main :: (Bit,Bit) -> Bit
main = uncurry xor
\end{code}
}
\only<4->{
We also intuitively know how many wires we need for this entire function hierarchy: 3
}
}

\frame
{
\frametitle{From Intuition to Reality}
\numbersreset
\begin{code}
uncurry = Λα.Λβ.Λγ.λ(f:α -> β -> γ).λ(ds:(,) α β)).
            let  a = case ds of (a,_) -> a
                 b = case ds of (_,b) -> b
            in f a b

main = uncurry Bit Bit Bit xor
\end{code}
\only<2->{
Specialize on type AND function:
\numbersreset
\begin{code}
uncurryXor = (Λα.Λβ.Λγ.λ(f:α -> β -> γ).λ(ds:(,) α β)).
              let  a = case ds of (a,_) -> a
                   b = case ds of (_,b) -> b
              in f a b) Bit Bit Bit xor

main = uncurryXor
\end{code}
}
\only<3->{
\numbersreset
\begin{code}
uncurryXor :: (Bit, Bit) -> Bit
uncurryXor (a,b) = xor a b

main = uncorryXor
\end{code}
}
}

\frame
{
\frametitle{Monomorphic \& First Order}
We want a system/algorithm that can make an entire function hierarchy monomorphic and first order, accepting the following restrictions on the input:
\begin{itemize}
  \item The \hs{main} function neither receives nor returns functional values
  \item The \hs{main} function is monomorphic
  \item Primitives neither receive nor return functional values
\end{itemize}
\bigskip
Where a functional value is either a value with a function type (e.g. \hs{α -> β}) or a `boxed' function type (e.g. \hs{Maybe (α -> β)})
}

\frame
{
\frametitle{Term Rewrite System}
The normalization phase of the compiler behaves like a term rewrite system that exhaustively applies a set of transformations.
\bigskip
Normalization also split in phases:
\begin{itemize}
  \item Make monomorphic
  \item Make first-order
  \item `Simplify'
\end{itemize}
}

\frame
{
\frametitle{Making descriptions first-order}
\only<1>{
\begin{tabbing}
$\mathcal{S}_{1}$ \= = \= $\mathcal{E}_{1}$ \\
$\mathcal{E}_{1}$ \> = \> $\mathit{lam}\ \mathcal{E}_{1}\ ∪\ \mathit{app}\ (\mathcal{E}_{1} - prim)\ \mathcal{E}_{1}\ ∪\ app\ prim\ (\mathcal{F}'_{1} ∩ \mathcal{B}'_{1})\ ∪\ \mathit{con}\ ∪$\\
                  \>   \> $\mathit{var}\ ∪\ \mathit{prim}\ ∪\ \mathit{let}\ \mathcal{E}_{1}\ \mathcal{E}_{1}\ ∪ \mathit{case}\ \mathcal{F}'_{1}\ \mathcal{E}_{1}$ \\
$\mathcal{F}'_{n}$ \> = \> $\mathcal{E}_{n} - \mathrm{FUN}\ \mathcal{E}_{n}$ \\
$\mathcal{B}'_{n}$ \> = \> $\mathcal{E}_{n} - \mathrm{BOX}\ \mathcal{E}_{n}$
\end{tabbing}
}
\only<2>{
\small{
\begin{mathpar}
\inferrule*[right=BetaRed]{(λx.e)\ (u : σ) \\ \mathrm{FUN}(σ) ∨ \mathrm{BOX}(σ)}{e [x:=u]}
\and
\inferrule*[right=CaseApp]
{(\mathbf{case}\ e\ \mathbf{of}\ \{p₁ → u₁; ...\, ; p_{n} → u_{n}\})\ (u : σ) \\ \mathrm{FUN}(σ) ∨ \mathrm{BOX}(σ)}
{\mathbf{case}\ e\ \mathbf{of}\ \{p₁ → u₁\ u; ...\, ; p_{n} → u_{n}\ u\}}
\and
\inferrule*[right=LetApp]
{(\mathbf{let}\ \overline{binds}\ \mathbf{in}\ u)\ (e : σ) \\ \mathrm{FUN}(σ) ∨ \mathrm{BOX}(σ)}
{\mathbf{let}\ \overline{binds}\ \mathbf{in}\ (u\ e)}
\and
\inferrule*[right=BindFun]
{\mathbf{let} \{...;x = e_{i} : σ_{i};...\}\ \mathbf{in}\ u \\ \mathrm{FUN}(σ_{i}) ∨ \mathrm{BOX}(σ_{i})}
{\mathbf{let} \{...[x := e_{i}];...[x := e_{i}]\}\ \mathbf{in}\ u [x := e_{i}]}
\and
\inferrule*[right=FunSpec]
{(y\ \overline{e})\ (u\!:\!σ) \\ \mathrm{FUN}(σ) ∨ \mathrm{BOX}(σ) \\ y ∈ \hat{π}₁(Γ_{g})}
{y'\ \overline{e}\ \overline{\mathrm{FV}(u)} \\\\ Γ_{g}^{new} = Γ_{g}^{old} ∪ \{(y',λ\overline{x}λ\overline{\mathrm{FV}(u)}.π₂(Γ_{g}@@y)\ \overline{x}\ u)\}}
\end{mathpar}}
}
\only<3>{
\begin{tabbing}
$\mathcal{S}_{2}$ \= = \= $\mathcal{E}_{2}$ \\
$\mathcal{E}_{2}$ \> = \> $lam\ \mathcal{E}_{2}\ ∪\ app\ con\ \mathcal{E}_{2}\ ∪\ app\ \mathcal{E}_{2}\ (\mathcal{F}'_{2} ∩ \mathcal{B}'_{2})\ ∪\ con\ ∪$\\
                  \>   \> $var\ ∪\ prim\ ∪\ let\ (\mathcal{F}'_{2} ∩ \mathcal{B}'_{2})\ \mathcal{E}_{2}\ ∪\ case\ \mathcal{F}'_{2}\ \mathcal{E}_{2}$
\end{tabbing}
}
\only<4>{
\small{
\begin{mathpar}
\inferrule*[right=CaseCon]
{\mathbf{case}\ K\ \overline{σ}\ \overline{y} : τ\ \mathbf{of}\ \{...; K\ \overline{x} → e; ...\} \\ \mathrm{BOX}(τ)}
{\mathbf{let}\ \overline{x = y}\ \mathbf{in}\ e}
\and
\inferrule*[right=CaseCase]
{\mathbf{case}\ (\mathbf{case}\ e\ \mathbf{of}\ \{p₁ → u₁;\ ...;\ p_{n} → u_{n}\} : σ)\ \mathbf{of}\ \overline{alts} \\ \mathrm{BOX}(σ)}
{\mathbf{case}\ e\ \mathbf{of} \{p₁ → \mathbf{case}\ u₁\ \mathbf{of}\ \overline{alts};\ ...;\ p_{n} → \mathbf{case}\ u_{n}\ \mathbf{of}\ \overline{alts}\}}
\and
\inferrule*[right=CaseLet]
{\mathbf{case}\ (\mathbf{let}\ \overline{binds}\ \mathbf{in}\ e : σ)\ \mathbf{of}\ \overline{alts} \\ \mathrm{BOX}(σ)}
{\mathbf{let}\ \overline{binds}\ \mathbf{in}\ (\mathbf{case}\ e\ \mathbf{of}\ \overline{alts})}
\and
\inferrule*[right=InlineBox]
{\mathbf{case}\ (y\ \overline{e}):σ\ \mathbf{of}\ \overline{alts} \\\\ \mathrm{BOX}(σ) \\ y ∈ \hat{π}₁(Γ_{g})}
{\mathbf{case}\ (π₂(Γ_{g}@@y)\ \overline{e})\ \mathbf{of}\ \overline{alts}}
\end{mathpar}}
}
\only<5>{
\begin{tabbing}
$\mathcal{S}_{3}$ \= = \= $\mathcal{E}_{3}$ \\
$\mathcal{E}_{3}$ \> = \> $lam\ \mathcal{E}_{3}\ ∪\ app\ con\ \mathcal{E}_{3}\ ∪\ app\ \mathcal{E}_{3}\ (\mathcal{F}'_{3} ∩ \mathcal{B}'_{3})\ ∪\ con\ ∪$\\
                  \>   \> $var\ ∪\ prim\ ∪\ let\ (\mathcal{F}'_{3} ∩ \mathcal{B}'_{3})\ \mathcal{E}_{3}\ ∪\ case\ (\mathcal{F}'_{3} ∩ \mathcal{B}'_{3})\ \mathcal{E}_{3}$
\end{tabbing}
}
\only<6>{
\begin{tabbing}
$\mathcal{S}_{3}$ \= = \= $\mathcal{E}_{3}$ \\
$\mathcal{E}_{3}$ \> = \> $lam\ \mathcal{E}_{3}\ ∪\ app\ con\ \mathcal{E}_{3}\ ∪\ app\ \mathcal{E}_{3}\ (\mathcal{F}'_{3} ∩ \mathcal{B}'_{3})\ ∪\ con\ ∪$\\
                  \>   \> $var\ ∪\ prim\ ∪\ let\ (\mathcal{F}'_{3} ∩ \mathcal{B}'_{3})\ \mathcal{E}_{3}\ ∪\ case\ (\mathcal{F}'_{3} ∩ \mathcal{B}'_{3})\ \mathcal{E}_{3}$ \\
                  \>   \> \\
$\mathcal{F}_{p}$ \> = \> $lam\ \mathcal{E}_{3}\ ∪\ app\ \mathcal{E}_{3}\ \_$
\end{tabbing}
}
}

\frame
{
\frametitle{Conclusions}
\begin{itemize}
  \item All higher-order descriptions can be made first-order, given only minor restrictions on the input.
  \item Making the entire function hierarchy monomorphic works in a similar way.
\end{itemize}
}

\frame
{
\frametitle{Future Work: Recursion}
\only<1->{
\numbersreset
\begin{code}
map :: (a -> b) -> [a] -> [b]
map f []      = []
map f (x:xs)  = (f x):(map f xs)
\end{code}
}
\only<2->{
\begin{code}
main :: Int8 -> Int8 -> [Int8]
main a b = map (*2) [a,b]
\end{code}
}
\begin{itemize}
\item We need to evaluate map based on the structure of its 2nd argument to `unwind' the recursion.
\pause
\item Work done by Arjan Boeijink, based on work: Max Bolingbroke and Simon Peyton Jones, Supercompilation by Evaluation.
\end{itemize}
}

\frame
{
\vspace{2cm}\centerline{\Huge{
Questions?
}}
\vspace{2cm}
\centerline{http://clash.ewi.utwente.nl}
}

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
