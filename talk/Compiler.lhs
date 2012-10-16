%include clashtalk.fmt
\section{Compiler}

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

% \frame{
%   \frametitle{CλaSH Compiler}
%   \begin{itemize}
%     \item \textbf{CλaSH}: CAES Language for Synchronous Hardware
%     \item Compiles demonstrated hardware descriptions to VHDL
%     \item VHDL can be processed by industry-standard tools to make real silicon, or allow prototyping on an FPGA
%   \end{itemize}
% }

% \frame{
%   \frametitle{CλaSH Compiler}
%   \begin{center}
%   Haskell $>$------ GHC (front-end) ------$>$ Core \\
%     \ \\
%      Core $>$------ Normalization ------$>$ Core \\
%      \ \\
%      Core $>$------ Back-end ------$>$ VHDL
%   \end{center}
% }

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

% \frame
% {
% \frametitle{Making descriptions first-order}
% \only<1>{
% \begin{tabbing}
% $\mathcal{S}_{1}$ \= = \= $\mathcal{E}_{1}$ \\
% $\mathcal{E}_{1}$ \> = \> $\mathit{lam}\ \mathcal{E}_{1}\ ∪\ \mathit{app}\ (\mathcal{E}_{1} - prim)\ \mathcal{E}_{1}\ ∪\ app\ prim\ (\mathcal{F}'_{1} ∩ \mathcal{B}'_{1})\ ∪\ \mathit{con}\ ∪$\\
%                   \>   \> $\mathit{var}\ ∪\ \mathit{fun}\ ∪\ \mathit{prim}\ ∪\ \mathit{let}\ \mathcal{E}_{1}\ \mathcal{E}_{1}\ ∪ \mathit{case}\ \mathcal{F}'_{1}\ \mathcal{E}_{1}$ \\
% $\mathcal{F}'_{n}$ \> = \> $\mathcal{E}_{n} - \mathrm{FUN}\ \mathcal{E}_{n}$ \\
% $\mathcal{B}'_{n}$ \> = \> $\mathcal{E}_{n} - \mathrm{BOX}\ \mathcal{E}_{n}$
% \end{tabbing}
% }
% \only<2>{
% \small{
% \begin{mathpar}
% \inferrule*[right=LamApp]{(λx:σ.e)\ u}{\mathbf{let}\ x:σ=u\ \mathbf{in}\ e}
% \and
% \inferrule*[right=CaseApp]
% {(\mathbf{case}\ e\ \mathbf{of}\ \{p₁ → u₁; ...\, ; p_{n} → u_{n}\})\ u}
% {\mathbf{case}\ e\ \mathbf{of}\ \{p₁ → u₁\ u; ...\, ; p_{n} → u_{n}\ u\}}
% \and
% \inferrule*[right=LetApp]
% {(\mathbf{let}\ \overline{binds}\ \mathbf{in}\ u)\ e}
% {\mathbf{let}\ \overline{binds}\ \mathbf{in}\ (u\ e)}
% \and
% \inferrule*[right=BindFun]
% {\mathbf{let} \{...;x = e_{i} : σ_{i};...\}\ \mathbf{in}\ u \\ \mathrm{FUN}(σ_{i}) ∨ \mathrm{BOX}(σ_{i})}
% {\mathbf{let} \{...[x := e_{i}];...[x := e_{i}]\}\ \mathbf{in}\ u [x := e_{i}]}
% \and
% \inferrule*[right=FunSpec]
% {(f\ \overline{e})\ (u\!:\!σ) \\ \mathrm{FUN}(σ) ∨ \mathrm{BOX}(σ)}
% {f'\ \overline{e}\ \overline{\mathrm{FV}(u)} \\\\ Γ_{g}^{new} = Γ_{g}^{old} ∪ \{(f',λ\overline{x}.λ\overline{\mathrm{FV}(u)}.(Γ_{g}@@f)\ \overline{x}\ u)\}}
% \end{mathpar}}
% }
% \only<3>{
% \begin{tabbing}
% $\mathcal{S}_{2}$ \= = \= $\mathcal{E}_{2}$ \\
% $\mathcal{E}_{2}$ \> = \> $lam\ \mathcal{E}_{2}\ ∪\ app\ con\ \mathcal{E}_{2}\ ∪\ app\ fun\ (\mathcal{F}'_{2} ∩ \mathcal{B}'_{2})\ ∪\ con\ ∪$\\
%                   \>   \> $var\ ∪\ fun\ ∪\ prim\ ∪\ let\ (\mathcal{F}'_{2} ∩ \mathcal{B}'_{2})\ \mathcal{E}_{2}\ ∪\ case\ \mathcal{F}'_{2}\ \mathcal{E}_{2}$
% \end{tabbing}
% }
% \only<4>{
% \small{
% \begin{mathpar}
% \inferrule*[right=CaseCon]
% {\mathbf{case}\ K\ \overline{σ}\ \overline{y} : τ\ \mathbf{of}\ \{...; K\ \overline{x} → e; ...\} \\ \mathrm{BOX}(τ)}
% {\mathbf{let}\ \overline{x = y}\ \mathbf{in}\ e}
% \and
% \inferrule*[right=CaseCase]
% {\mathbf{case}\ (\mathbf{case}\ e\ \mathbf{of}\ \{p₁ → u₁;\ ...;\ p_{n} → u_{n}\} : σ)\ \mathbf{of}\ \overline{alts} \\ \mathrm{BOX}(σ)}
% {\mathbf{case}\ e\ \mathbf{of} \{p₁ → \mathbf{case}\ u₁\ \mathbf{of}\ \overline{alts};\ ...;\ p_{n} → \mathbf{case}\ u_{n}\ \mathbf{of}\ \overline{alts}\}}
% \and
% \inferrule*[right=CaseLet]
% {\mathbf{case}\ (\mathbf{let}\ \overline{binds}\ \mathbf{in}\ e : σ)\ \mathbf{of}\ \overline{alts} \\ \mathrm{BOX}(σ)}
% {\mathbf{let}\ \overline{binds}\ \mathbf{in}\ (\mathbf{case}\ e\ \mathbf{of}\ \overline{alts})}
% \and
% \inferrule*[right=InlineBox]
% {\mathbf{case}\ (f\ \overline{e}):σ\ \mathbf{of}\ \overline{alts} \\ \mathrm{BOX}(σ)}
% {\mathbf{case}\ (Γ_{g}@@y)\ \overline{e}\ \mathbf{of}\ \overline{alts}}
% \end{mathpar}}
% }
% \only<5>{
% \begin{tabbing}
% $\mathcal{S}_{3}$ \= = \= $\mathcal{E}_{3}$ \\
% $\mathcal{E}_{3}$ \> = \> $lam\ \mathcal{E}_{3}\ ∪\ app\ con\ \mathcal{E}_{3}\ ∪\ app\ fun\ (\mathcal{F}'_{3} ∩ \mathcal{B}'_{3})\ ∪\ con\ ∪$\\
%                   \>   \> $var\ ∪\ fun\ ∪\ prim\ ∪\ let\ (\mathcal{F}'_{3} ∩ \mathcal{B}'_{3})\ \mathcal{E}_{3}\ ∪\ case\ (\mathcal{F}'_{3} ∩ \mathcal{B}'_{3})\ \mathcal{E}_{3}$
% \end{tabbing}
% }
% \only<6>{
% \begin{tabbing}
% $\mathcal{S}_{3}$ \= = \= $\mathcal{E}_{3}$ \\
% $\mathcal{E}_{3}$ \> = \> $lam\ \mathcal{E}_{3}\ ∪\ app\ con\ \mathcal{E}_{3}\ ∪\ app\ fun\ (\mathcal{F}'_{3} ∩ \mathcal{B}'_{3})\ ∪\ con\ ∪$\\
%                   \>   \> $var\ ∪\ fun\ ∪\ prim\ ∪\ let\ (\mathcal{F}'_{3} ∩ \mathcal{B}'_{3})\ \mathcal{E}_{3}\ ∪\ case\ (\mathcal{F}'_{3} ∩ \mathcal{B}'_{3})\ \mathcal{E}_{3}$ \\
%                   \>   \> \\
% $\mathcal{F}_{p}$ \> = \> $lam\ \mathcal{E}_{3}\ ∪\ app\ fun\ \_$
% \end{tabbing}
% }
% }

% \frame
% {
% \small{
% \begin{framed}
% \textsc{LamApp}
% \begin{center}
% \begin{tabular}{c}
% $(λx.e)\ u$ \\ \cmidrule(r){1-1}
% $\mathbf{let}\ \{x=u\}\ \mathbf{in}\ e$
% \end{tabular}
% \end{center}
% \end{framed}
% \begin{framed}
% \textsc{LetApp}
% \begin{center}
% \begin{tabular}{c}
% $(\mathbf{let}\ \overline{x:σ = e}\ \mathbf{in}\ u)\ e₀$ \\ \cmidrule(r){1-1}
% $\mathbf{let}\ \overline{x:σ = e}\ \mathbf{in}\ (u\ e₀)$
% \end{tabular}
% \end{center}
% \end{framed}
% \begin{framed}
% \textsc{CaseApp}
% \begin{center}
% \begin{tabular}{c}
% $(\mathbf{case}\ e\ \mathbf{of}\ \overline{p → u})\ u₀$ \\ \cmidrule(r){1-1}
% $\mathbf{let}\ \{x = u₀\}\ \mathbf{in}\ (\mathbf{case}\ e\ \mathbf{of}\ \overline{p → (u\ x)})$
% \end{tabular}
% \end{center}
% \end{framed}}
% }

% \frame{
% \small{
% \begin{framed}
% \textsc{CaseLet}
% \begin{center}
% \begin{tabular}{c}
% $\mathbf{case}\ (\mathbf{let}\ \overline{x:σ = e}\ \mathbf{in}\ e : σ)\ \mathbf{of}\ \overline{p → u}$ \\ \cmidrule(r){1-1}
% $\mathbf{let}\ \overline{x:σ = e}\ \mathbf{in}\ (\mathbf{case}\ e\ \mathbf{of}\ \overline{p → u})$
% \end{tabular}
% \end{center}
% \end{framed}
% \begin{framed}
% \textsc{CaseCon}
% \begin{center}
% \begin{tabular}{clc}
% $\mathbf{case}\ K_{i}\ \overline{σ}\ \overline{y}\ \mathbf{of}\ \{...; K_{i}\ \overline{x:σ} → e; ...\}$ & & $\mathbf{case}\ u\ \mathbf{of}\ \{\_ → e\}$ \\ \cmidrule(r){1-1} \cmidrule(r){3-3}
% $\mathbf{let}\ \overline{x:σ = y}\ \mathbf{in}\ e$ & & $e$
% \end{tabular}
% \end{center}
% \end{framed}
% \begin{framed}
% \textsc{CaseCase}\hspace{14em} Preconditions: BOX σ\vspace{-0.5em}
% \begin{center}
% \begin{tabular}{c}
% $\mathbf{case}\ (\mathbf{case}\ e\ \mathbf{of}\ \{p₁ → u₁;\ ...\ ;\ p_{n} → u_{n}\} : σ)\ \mathbf{of}\ \overline{p → u}$ \\ \cmidrule(r){1-1}
% $\mathbf{case}\ e\ \mathbf{of} \{p₁ → \mathbf{case}\ u₁\ \mathbf{of}\ \overline{p → u};\ ...\ ;\ p_{n} → \mathbf{case}\ u_{n}\ \mathbf{of}\ \overline{p → u}\}$
% \end{tabular}
% \end{center}
% \end{framed}
% }
% }

% \frame{
% \small{
% \begin{framed}
% \textsc{InlineBox}\hspace{13.6em} Preconditions: BOX σ
% \begin{center}
% \begin{tabular}{c}
% $\mathbf{case}\ (f\ \overline{e}):σ\ \mathbf{of}\ \overline{p → u}$ \\ \cmidrule(r){1-1}
% $\mathbf{case}\ ((Γ@@f)\ \overline{e})\ \mathbf{of}\ \overline{p → u}$
% \end{tabular}
% \end{center}
% \end{framed}
% \begin{framed}
% \textsc{BindFun}\\[2ex]
% \begin{tabular}{cl}
% $\mathbf{let} \{b_{1};\ x : σ_{i} = e_{i};\ b_{n}\}\ \mathbf{in}\ u$ & Definitions: $(∅,\overline{y}) = \mathrm{FV}\ e_{i}$ \\ \cmidrule(r){1-1}
% $(\mathbf{let} \{b_{1};...;b_{n}\}\ \mathbf{in}\ u)\ [x := e_{i}]$ & Preconditions: (FUN $σ_{i}$) ∨ \\
%  & (BOX $σ_{i}$) ∧ ($x ∉ \overline{y}$)
% \end{tabular}
% \end{framed}
% }
% }

% \frame{
% \small{
% \begin{framed}
% \textsc{LiftFun}\hspace{4em} Preconditions: (FUN $σ_{i}$) ∨ (BOX $σ_{i}$) ∧ ($x ∈ \overline{y}$)\\[2ex]
% \begin{tabular}{cl}
% $\mathbf{let} \{b_{1};\ x : σ_{i} = e_{i};\ b_{n}\}\ \mathbf{in}\ u$ & \\ \cmidrule(r){1-1}
% $(\mathbf{let} \{b_{1};...;b_{n}\}\ \mathbf{in}\ u)\ [x := f\ \overline{z})]$ &  Definitions: $(∅,\overline{y}) = \mathrm{FV}\ e_{i}$ \\
%  & $\ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \overline{z}\ \ \ \ \ = \overline{y} - \{x\}$
% \end{tabular}
% \begin{center}
% New Environment: $Γ ∪ \{(f,λ\overline{z}.e_{i}[x:=f])\}$
% \end{center}
% \end{framed}
% \begin{framed}
% \textsc{FunSpec}\\[2ex]
% \begin{tabular}{lclll}
% \hspace{1em} & $(f\ \overline{e})\ (u\!:\!σ)$ & \hspace{3em} & Preconditions: & (FUN σ) ∨ (BOX σ) \\ \cmidrule(r){2-2}
% & $f'\ \overline{e}\ \overline{y}$ & & Definitions: & $(∅,\overline{y}) = \mathrm{FV}\ u$ \\ \\
% \multicolumn{5}{c}{New Environment: $Γ ∪_{αs} \{(f',λ\overline{x}.λ\overline{y}.(Γ@@f)\ \overline{x}\ u)\}$}
% \end{tabular}
% \end{framed}
% }
% }


\frame{
\frametitle{Normalization}
Brings function hierarchy into a desired `normal' form:
\begin{itemize}
  \item Completely monomorphic
  \item No higher-order functions
  \item All function arguments are ``named'' (η-expansion + ANF)
  \item No nested let-bindings
  \item Scrutinee and alternatives of a case-statement are simple variables
  \item etc.
\end{itemize}
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
\rule{1.5cm}{0.3mm} E has a function type \\
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
%format (_(a)(b)) = a "_{" b "}"
\only<5>{
\textbf{CaseApp}
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
Apply \textbf{CaseApp} 2 times:
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
\textbf{CaseSimpl}:
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

\textbf{RetLet}  \\
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


\frame
{
\frametitle{Discussion}
\begin{itemize}
  \item Why specialize instead of inlining?
  \item To preserve as much of the function hierarchy in the generated netlist.
  \item However: inlining the definitions of \hs{($)}, \hs{(.)}, etc., seems prefererable to specialization.
  \item Open question: When should we inline instead of specialize?
\end{itemize}
}

\frame
{
\frametitle{Conclusions}
\begin{itemize}
  \item All polymorphic, higher-order functions can be transformed into a monomorphic, first-order representation; given only minor restrictions on the input.
  \item Monomorphic, first-order functions can be straightforwardly simplified and translated into a netlist.
\end{itemize}
}

% \frame
% {
% \frametitle{Conclusions}
% \begin{itemize}
%   \item All higher-order descriptions can be made first-order, given only minor restrictions on the input.
%   \item Making the entire function hierarchy monomorphic works in a similar way.
% \end{itemize}
% }

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
\pause
\item We need to evaluate map based on the structure of its 2nd argument to `unwind' the recursion.
% \item Work done by Arjan Boeijink, based on work: Max Bolingbroke and Simon Peyton Jones, Supercompilation by Evaluation.
\end{itemize}
}
