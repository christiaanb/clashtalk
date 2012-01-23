%include clashtalk.fmt

\frame
{
\frametitle{CλaSH \& VHDL}
\only<1>{
\textcolor{red}{CλaSH:}
\numbersreset
\begin{code}
main :: Signed D9 -> Signed D9 -> Signed D9
main a b = a + b
\end{code}

\textcolor{red}{VHDL:}
\numbersreset
%format <= = "\Leftarrow"
%format entity = "\mathbf{entity}"
%format architecture = "\mathbf{architecture}"
%format is = "\mathbf{is}"
%format begin = "\mathbf{begin}"
%format end = "\mathbf{end}"
%format out = "\mathbf{out}"
%format port = "\mathbf{port}"
\begin{code}
entity main is
  port  (  a    : in   signed (8 downto 0);
           b    : in   signed (8 downto 0);
           res  : out  signed (8 downto 0));
end entity main;

architecture rtl of main is
begin
  res <= a + b;
end architecture rtl;
\end{code}
}
\only<2>{
\textcolor{red}{CλaSH:}
\numbersreset
\begin{code}
z = multiOp op a b
\end{code}

\textcolor{red}{VHDL:}
\numbersreset
%{
%format map = "\mathbf{map}"
\begin{code}
compInst_z : entity multiOp
              port map (op => op, a => a, b => b, res => z);
\end{code}
%}
}

\only<3>{
\textcolor{red}{CλaSH:}
\numbersreset
\begin{code}
z = case op of
  ADD   -> a  +  b
  MUL   -> a  *  b
  MIN   -> a  -  b
\end{code}

\textcolor{red}{VHDL:}
\numbersreset
%format when = "\mathbf{when}"
\begin{code}
z <=  a  +  b  when op = "00" else
      a  *  b  when op = "01" else
      a  -  b;
\end{code}
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
\frametitle{Core Language}
\textbf{Expressions}
\begin{tabbing}
\hspace{0.2em} \= $e,u$ \= ::=      \= $x$ \hspace{8em}                                  \= Variable reference \\
               \>       \> $\ \mid$ \> $K \mid ⊗$                                        \> Data Constructor / Primitive Function \\
               \>       \> $\ \mid$ \> $Λα.e\ \mid\ e \ τ$                               \> Type abstraction / application \\
               \>       \> $\ \mid$ \> $λx\!:\!σ.e\ \mid\ e\ u$                          \> Term abstraction / application \\
               \>       \> $\ \mid$ \> $\mathbf{let}\ \overline{x = e}\ \mathbf{in}\ u$  \> Recursive let-binding \\
               \>       \> $\ \mid$ \> $\mathbf{case}\ e\ \mathbf{of}\ \overline{p → u}$ \> Case decomposition \\
\textbf{Patterns} \> \> \> \> \\
\hspace{0.2em} \> $p$ \> ::=      \> $\_$              \> Default case \\
               \>     \> $\ \mid$ \> $K\ \overline{x}$ \> Match data constructor
\end{tabbing}
}

\frame{
\frametitle{CλaSH \&Core}
\only<1>{
\textcolor{red}{CλaSH:}
\numbersreset
\begin{code}
id :: α -> α
id a = a
\end{code}
\textcolor{red}{Core:}
\numbersreset
\begin{code}
id = Λα.λ(a:α).a
\end{code}
}
\only<2>{
\textcolor{red}{CλaSH:}
\numbersreset
\begin{code}
op :: Bit -> Bit
op a = z
  where
    z = a `xor` H
\end{code}
\textcolor{red}{Core:}
\numbersreset
\begin{code}
op = λ(a:Bit).
  let z = xor a H
  in z
\end{code}
}
\only<3>{
\textcolor{red}{CλaSH:}
\numbersreset
\begin{code}
fst :: (α,β) -> α
fst (a,b) = a
\end{code}
\textcolor{red}{Core:}
\numbersreset
\begin{code}
fst = Λα.Λβ.λ(ds : (,) α β).
  case ds of ((,) a _) -> a
\end{code}
}
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

\frame
{
\frametitle{Polymorphism \& Hardware}
\numbersreset
\begin{code}
id :: α -> α
id a = a
\end{code}
\onslide<2->{
\\[0ex]
\textcolor{red}{How many wires do I need to represent this function?}
}
\onslide<3->{
\numbersreset
\begin{code}
main :: Bit -> Bit
main = id
\end{code}
}
\onslide<4->{
\\[0ex]
\textcolor{red}{We intuitively know how many wires we need for the entire function hierarchy: 1}
}
}

\frame{
\frametitle{From Intuition to Reality}
\numbersreset
\begin{code}
id = Λα.λ(a:α).a

main = id Bit
\end{code}
\onslide<2->{
\\[0ex]
\textcolor{red}{Specialize on type:}
\numbersreset
\begin{code}
idBit = (Λα.λ(a:α).a) Bit

main = idBit
\end{code}
}
\onslide<3->{
\\[0ex]
\textcolor{red}{What the CλaSH code would look like:}
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
\onslide<2->{
\\[0ex]
\textcolor{red}{How many wires do I need to represent this function?}
}
\onslide<3->{
\numbersreset
\begin{code}
main :: (Bit,Bit) -> Bit
main = uncurry xor
\end{code}
}
\onslide<4->{
\\[0ex]
\textcolor{red}{We also intuitively know how many wires we need for this entire function hierarchy: 3}
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
\onslide<2->{
\\[-2.5ex]
\textcolor{red}{Specialize on type AND function:}
\numbersreset
\begin{code}
uncurryXor = (Λα.Λβ.Λγ.λ(f:α -> β -> γ).λ(ds:(,) α β)).
              let  a = case ds of (a,_) -> a
                   b = case ds of (_,b) -> b
              in f a b) Bit Bit Bit xor

main = uncurryXor
\end{code}
}
\onslide<3->{
\\[-2.5ex]
\textcolor{red}{What the CλaSH code would look like:}
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
This type of specialization can make the entire function hierarchy monomorphic and first order, given the following restrictions on the input:
\begin{itemize}
  \item The \hs{main} function neither receives nor returns functional values
  \item The \hs{main} function is monomorphic
  \item Primitives neither receive nor return functional values
\end{itemize}
\bigskip
Where a functional value is either a value with a function type (e.g.:~\hs{α -> β}) or a `wrapped' function type (e.g.: \hs{Maybe (α -> β)})
}

\frame
{
\frametitle{Term Rewrite System}
The normalization phase of the compiler behaves like a term rewrite system that exhaustively applies a set of transformations.
\bigskip{}
\onslide<2->{
Normalization also split in phases:
\begin{itemize}
  \item Make monomorphic
  \item Make first-order
  \item `Simplify'
\end{itemize}
}
}

\frame
{
\frametitle{Future Work: Recursion}
\onslide<1->{
\numbersreset
\begin{code}
vmap :: Natural s => (a -> b) -> Vector s a -> Vector s b
vmap f 〈〉      = 〈〉
vmap f (x▹xs)  = (f x)▹(vmap f xs)
\end{code}
}
\onslide<2->{
\begin{code}
main :: (Signed D8) -> (Signed D8) -> Vector D2 (Signed D8)
main a b = vmap (*2) 〈a,b〉
\end{code}
}

\begin{itemize}
\onslide<3->{\item We need to evaluate map based on the structure of its 2nd argument to `unwind' the recursion.}
\onslide<4->{\item Work done by Arjan Boeijink, based on work: Max Bolingbroke and Simon Peyton Jones, ``Supercompilation by Evaluation".}
\end{itemize}
}

\frame
{
\frametitle{Conclusions}
Getting a better feel of the relation:\\[0ex] Functional Description ↔ Actual Hardware:
\\[2ex]
\begin{itemize}
  \item Functions become components
  \item Applications of functions become component instantiations
  \item Case-statements turn into multiplexers
  \item Functional arguments are specialized
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

