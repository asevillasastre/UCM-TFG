$Title Modelo de flujo con vehiculos, coste variable, coste por rehabilitacion
* 12-03-23: M, num_transitorios, gran refactorizacion, reordenacion y redocumentacion

Set
j Nodos.
/0*6/
v Tipos de vehiculo.
/0*2/
;

Alias
(j,i,k)
;

Parameters
dem(j) Demanda de cada nodo en toneladas de paquetes de ayuda.
/
0 0
1 0
2 0
3 0
4 5
5 6
6 7
/
num_transitorios Numero de nodos transitorios.
/4/
capacidad_vehiculo(v) Capacidad en toneladas de una unidad vehicular de tipo v.
/
0 1
1 2
2 5
/
coste_fijo(v) Coste fijo en euros de hacer partir un vehiculo de tipo v.
/
0 10
1 20
2 30
/
coste_variable Coste variable en euros por km recorrido por cualquier vehiculo.
/1/
max_coste Maximo presupuesto que se puede invertir en total en la mision.
/60/
max_habilitaciones Maximo numero de arcos que se pueden rehabilitar previo paso a los vehiculos.
/1/
M Cota de flujo maximo.
/99/
;

Table E(i,j) Existe el arco de i a j.
    0   1   2   3   4   5   6
0   0   1   1   1   0   1   0
1   1   0   0   0   0   0   0
2   1   0   0   0   0   0   0
3   1   0   0   0   1   0   0
4   0   0   0   1   0   0   0
5   1   0   0   0   0   0   1
6   0   0   0   0   0   1   0  
;

Table U(i,j) El inicio es utilizable el arco de i a j.
    0   1   2   3   4   5   6
0   0   1   0   1   0   0   0
1   1   0   0   0   0   0   0
2   0   0   0   0   0   0   0
3   1   0   0   0   0   0   0
4   0   0   0   0   0   0   0
5   0   0   0   0   0   0   1
6   0   0   0   0   0   1   0
;

Table dist(i,j) Distancia del arco de i a j en km.
    0     1   2   3   4   5      6
0   0     0.1 0.1 0.1 0   0.01   0
1   0.1   0   0   0   0   0      0
2   0.1   0   0   0   0   0      0
3   0.1   0   0   0   0.1 0      0
4   0     0   0   0.1 0   0      0
5   0.01  0   0   0   0   0      0.001
6   0     0   0   0   0   0.001  0
;

Table coste_rehabilitacion(i,j) Coste de rehabilitar el arco de i a j.
    0   1   2   3   4   5   6
0   0   8   3   3   0   4   0
1   8   0   0   0   0   0   0
2   3   0   0   0   0   0   0
3   3   0   0   0   1   0   0
4   0   0   0   1   0   0   0
5   4   0   0   0   0   0   2
6   0   0   0   0   0   2   0
;

Variables

Xmas(i,j,v) Flujo positivo de vehiculos de tipo v en el arco de i a j.
Xmenos(i,j,v) Flujo negativo de vehiculos de tipo v en el arco de i a j.
Y(j,v) Cantidad de vehiculos de tipo v que reparten su mercancia en j.
Z(j) Toneladas totales que se reparten en j.
Zaux(j) Variable binaria que determina si llega alguna ayuda a j.
H(i,j) Variable binaria que determina si se habilita el arco de i a j.
Insatisaux Demanda insatisfecha en cada nodo en toneladas.

Insatis
Eq
Coste
;

Positive variables Insatisaux;
Binary variables H, Zaux, Usado;
Integer variables Xmas, Xmenos; 

Equations

flujo_transitorios(j,v) Define el flujo positivo en los nodos transitorios.
flujo_destinos(j,v) Define el flujo positivo en los nodos con demanda.
def_Y(j,v) Ecuacion de flujo.
def_Z(j) Ayuda total en toneladas que llega al nodo j.

arcos_buenos_mas(i,j,v) Considera de flujo nulo uno de los sentidos de cada arco.
arcos_buenos_menos(i,j,v)
existencia_ruta_max(i,j,v) Impide el paso por arcos no existentes.
existencia_ruta_min(i,j,v)
usabilidad_ruta_max(i,j,v) Impide el paso por arcos no usables ni rehabilitados.
usabilidad_ruta_min(i,j,v)

lim_coste
lim_habilitaciones

def_insatisaux Definimos la demanda insatisfecha.
def_Zaux_destinos(j) Definimos los nodos a los que llega alguna ayuda.
def_Zaux_transitorios(j) A los nodos transitorios no puede llegar ninguna ayuda.
lim_demanda(j) Restriccion que limita lo repartido en cada nodo a la demanda del mismo.

f_insatis Funcion objetivo 1. Demanda insatisfecha total.
f_eq Funcion objetivo 2. Criterio de equidad. Numero de nodos a los que se les reparte alguna cantidad de ayuda.
def_coste Definicion del coste.

;

flujo_transitorios(j,v)$(ord(j)>1 and ord(j)<=num_transitorios).. Y(j,v) =E= 0;
flujo_destinos(j,v)$(ord(j)>=num_transitorios+1).. Y(j,v) =G= 0;
def_Y(j,v).. Y(j,v) =E= sum(i, Xmas(i,j,v)-Xmenos(i,j,v)) - sum(i, Xmas(j,i,v)-Xmenos(j,i,v));
def_Z(j).. Z(j) =E= sum(v, Y(j,v)*capacidad_vehiculo(v));

arcos_buenos_mas(i,j,v)$(ord(i)<=ord(j)).. Xmas(j,i,v) =E= 0;
arcos_buenos_menos(i,j,v)$(ord(i)<=ord(j)).. Xmenos(j,i,v) =E= 0;
existencia_ruta_max(i,j,v).. Xmas(i,j,v)-Xmenos(i,j,v) =L= M*E(i,j);
existencia_ruta_min(i,j,v).. Xmas(i,j,v)-Xmenos(i,j,v) =G= -M*E(i,j);
usabilidad_ruta_max(i,j,v).. Xmas(i,j,v)-Xmenos(i,j,v) =L= M*(U(i,j) +  H(i,j));
usabilidad_ruta_min(i,j,v).. Xmas(i,j,v)-Xmenos(i,j,v) =G= -M*(U(i,j) +  H(i,j));

lim_coste.. Coste =L= max_coste;
lim_habilitaciones..  sum(i, sum(j, H(i,j))) =L= max_habilitaciones;

def_insatisaux(j)$(ord(j)>=num_transitorios+1).. Insatisaux =G= dem(j) - Z(j);
def_Zaux_destinos(j)$(ord(j)>=num_transitorios+1).. Zaux(j) =L= M*Z(j);
def_Zaux_transitorios(j)$(ord(j)<=num_transitorios).. Zaux(j) =E= 0;
lim_demanda(j).. Z(j) =L= dem(j);

f_eq.. Eq =E= sum(j, Zaux(j));
f_insatis.. Insatis =E= sum(j, Insatisaux);
def_coste.. Coste =E= - sum(v,Y("0",v)*coste_fijo(v)) + sum(v, sum(i, sum(j, (Xmas(i,j,v)+Xmenos(i,j,v))*dist(i,j)*coste_variable)))
                        + sum(i, sum(j, coste_rehabilitacion(i,j)*H(i,j)));

model modelo1 /all/;

solve modelo1 using MIP minimizing Insatis;
solve modelo1 using MIP maximizing Eq;
*solve modelo1 using MIP minimizing Coste;
