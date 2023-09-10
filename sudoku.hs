module sudoku where
-- Nombre: Joaquin Mesa

import Prelude
import Data.List

------------------------------------------------------
--Solucionador de sudoku 4x4 y 9x9.
------------------------------------------------------

type Config = [(Int,Int,Int)]

bigOr :: [Nat] -> (Nat -> L) -> L
bigOr [] f =error "no puede ser vacía"
bigOr [x] f = Or (f x) bot
bigOr (x:xs) f = Or (f x)(bigOr xs f)

bigAnd :: [Nat] -> (Nat -> L) -> L
bigAnd [] f =error "no puede ser vacía"
bigAnd [x] f = And (f x) top 
bigAnd (x:xs) f = And (f x)(bigAnd xs f)

trd::(a,b,c)->c
trd (_,_,n) = n

leer::Config->L
leer [(m,n,o)] = v3 "p" m n o 
leer ((m,n,o):xs) = And (v3 "p" m n o) (leer xs)

v3::String->Int->Int->Int->L
v3 prefijo f c v= V(prefijo ++ show f ++ show c ++ show v)

todasColumnas :: Nat -> L
todasColumnas l =bigAnd [1..l] (\f->bigAnd[1..l](\n->bigOr [1..l] (\c->v3 "p" f c n)))

todasFilas :: Nat -> L
todasFilas l =bigAnd [1..l] (\c->bigAnd[1..l](\n->bigOr [1..l] (\f->v3 "p" f c n)))

--Pre:-No puede ser vacio
--Pos:Elimina el elemento n de la lista
sacarUno:: [Nat] -> Nat -> [Nat]
sacarUno [] n=error "no puede estar vacio"
sacarUno [x] n
  |n==x =[]
  |otherwise =[x]
sacarUno (x:xs) n
  |n==x = sacarUno xs n
  |otherwise = x:sacarUno xs n

--Pre:-
--Pos:
c4::Nat->L
c4 l = bigAnd [1..l] (\f->bigAnd[1..l](\n->bigOr[1..l](\c->v3 "p" f c n `And` Neg (bigOr (sacarUno [1..l] n)(\j -> v3 "p" f c j))))) 

--Pre:-
--Pos:
regiones :: Nat -> L
regiones l = bigAnd[0..(isqrt l  -1)](\ifa->bigAnd[1..(isqrt l-1)](\ico-> bigAnd[1..l](\n->bigOr[1..(isqrt l)](\f -> bigOr[1.. (isqrt l)](\c -> v3 "p" ((ifa* isqrt l)+ f) ((ico * isqrt l) + c) n)))))

-- Pre: recibe un número cuadrado n y una configuración inicial c para jugar un Sudoku de tamaño nXn
-- Pos: retorna una fórmula de LP formalizando el problema de resolver el Sudoku de tamaño nXn 
--      partiendo de la configuración c
sudoku :: Nat -> Config -> L
sudoku n c = todasFilas n `And` todasColumnas n `And` regiones n `And` c4 n `And` leer c

-- Configuración inicial para un Sudoku 4x4
c_n4 :: Config
c_n4 = [(2,1,3),(4,1,2),(3,3,2),(3,4,1),(4,3,3),(4,4,4)]

-- Configuración inicial para un Sudoku 9x9
c_n9 :: Config
c_n9 = [(1,3,9),(1,4,5),(1,7,2),(1,9,8),(2,2,7),(2,5,4),(2,6,8),(3,2,3),(4,2,8),(4,4,4),(4,7,5),(6,2,2),(6,3,5),(6,5,6),(6,7,9),(7,3,6),(7,8,7),(8,3,8),(8,4,2),(8,6,9),(8,7,3),(8,8,5),(9,1,7),(9,5,8),(9,6,6),(9,9,2)]
----------------------------------------------------------------------------------
-- Algunas funciones auxiliares 
----------------------------------------------------------------------------------
-- Pre: recibe un natural n.
-- Pos: devuelve la raiz cuadrada entera de n.
isqrt :: Nat -> Nat
isqrt 0 = 0
isqrt n = if (r+1)*(r+1) <= n then r+1 else r
          where 
            r = isqrt (n-1)

-- Pre: recibe una fórmula de LP.
-- Pos: pretty printing de la fórmula en formato SMT-LIB, esto es: parentizada y prefija.
toPrefix :: L -> String
toPrefix (V p)       = p
toPrefix (Neg a)     = "(not " ++ toPrefix a ++ ")"
toPrefix (a `And` b) = "(and " ++ toPrefix a ++ " " ++ toPrefix b ++ ")"
toPrefix (a `Or` b)  = "(or "  ++ toPrefix a ++ " " ++ toPrefix b ++ ")"
toPrefix (a `Imp` b) = "(=> "  ++ toPrefix a ++ " " ++ toPrefix b ++ ")"
toPrefix (a `Iff` b) = "(= "   ++ toPrefix a ++ " " ++ toPrefix b ++ ")"