$Title Modelo de rutas con vehiculos, coste variable, coste por rehabilitacion, CON VUELTA
* 17-03-23: tiempo implementado
* 06-04-23: incluida Eq, se queda en un nodo implementado, quitamos auto_cero
* 06-04-23: modelo de vuelta

Set
j Nodos.
/0*5/
v Tipos de vehiculo.
/0*2/
w Vehiculos posibles de tipo v.
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
3 8
4 5
5 6
/
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
/2/
max_coste Maximo presupuesto que se puede invertir en total en la mision.
/200/
max_habilitaciones Maximo numero de arcos que se pueden rehabilitar previo paso a los vehiculos.
/2/
M Cota de vehiculos maximos.
/9/
P_total Probabilidad aceptable de que todos los convoys puedan pasar por todas las rutas elegidas.
/0.2/
T_max Tiempo maximo asumible en horas para el reparto de toda la ayuda.
/1.6/
velocidad_vehiculo(v)  Inversa de la velocidad en h por km que recorre un vehiculo de tipo v.
/
0 0.4
1 0.3
2 0.2
/
;

* Matrices de ejemplo generadas con la versión buena de mi programa (la del 16-03-23)
* [num_nodos, num_cut, min_prob_rute] = [6, 2, 0.6]
Table E(i,j) Existe el arco de i a j.
      0     1     2     3     4     5
0     0     1     0     1     0     0     
1     1     0     1     0     0     0     
2     0     1     0     0     1     0     
3     1     0     0     0     0     0     
4     0     0     1     0     0     1     
5     0     0     0     0     1     0     
;
Table U(i,j) El inicio es utilizable el arco de i a j.
      0     1     2     3     4     5
0     0     1     0     1     0     0     
1     1     0     1     0     0     0     
2     0     1     0     0     0     0     
3     1     0     0     0     0     0     
4     0     0     0     0     0     0     
5     0     0     0     0     0     0     
;
Table dist(i,j) Distancia de las rutas de i a j en km.
      0     1     2     3     4     5
0     0     2     0     4     0     0     
1     2     0     1     0     0     0     
2     0     1     0     0     0     0     
3     4     0     0     0     0     0     
4     0     0     0     0     0     0     
5     0     0     0     0     0     0     
;
Table coste_rehabilitacion(i,j) Coste de rehabilitar el arco de i a j.
      0     1     2     3     4     5
0     0     2     0     4     0     0     
1     2     0     1     0     0     0     
2     0     1     0     0     0     0     
3     4     0     0     0     0     0     
4     0     0     0     0     0     0     
5     0     0     0     0     0     0     
;

Table P(i,j) Probabilidad de que se pueda utilizar el arco de i a j.
    0     1   2   3   4   5   
0   1     0.7 0.7 0.7 1   0.8  
1   0.7   1   1   1   1   1   
2   0.7   1   1   1   1   1      
3   0.7   1   1   1   0.7 1    
4   1     1   1   0.7 1   1    
5   0.8   1   1   1   1   1     
;

loop(i,
    loop(j,
        P(i, j) := log2(P(i,j));
        );
    );

P_total = log2(P_total);

Variables

X(i,j,v,w) El vehiculo de tipo v w-esimo va de i a j.
Z(j,v,w) El vehiculo de tipo v w-esimo reparte a j.
Ayuda(j) Ayuda total repartida a j.
H(i,j) Habilitamos el arco de i a j.

Insatis Total demanda insatisfecha.
Coste Coste total del proyecto.

Fiabilidad Logaritmo de la robabilidad de que todos los convoys puedan pasar por todos los arcos elegidos.
Usado(i,j) Variable binaria que determina si se usa el arco de i a j.

t(j,v,w) Instante de tiempo en el que el vehículo w-esimo de tipo v llega a j.

Eq Criterio de equidad numero de nodos a los que llega alguna ayuda.

Salio(v,w)
;

Positive variables t;
Integer variables Ayuda;
Binary variables X, Z, H, Usado, Salio;

Equations

si_sales_entraste(j,v,w) Un vehiculo solo puede salir de un nodo al que ha entrado.
pasas_por_Z(j,v,w) Define Z como alguno de los nodos por los que pasa el vehiculo.
solo_un_Z(v,w) Un vehiculo reparte en un unico nodo por el que pasa.
debes_volver(v,w) Todo vehiculo deben regresar al punto de partida.
def_salio_1(v,w) Determina si el vehiculo w-esimo de tipo v emprende la mision.
def_salio_2(v,w)

existencia(i,j,v,w) Impide el paso por arcos no existentes.
usabilidad(i,j,v,w) Impide el paso por arcos no usables ni rehabilitados.

lim_coste 
lim_habilitaciones

def_Ayuda(j) Ayuda total en toneladas que llega al nodo j.
lim_demanda(j) Impide superar la demanda de cada nodo.

f_Insatis
def_Coste Definicion del coste.

def_fiabilidad Define el valor de la fiabilidad.
lim_fiabilidad Obliga a la solucion a contemplar una fiabilidad minima.
arco_usado(i,j) Determina si el arco de i a j se ha utilizado.

def_tiempos(i,j,v,w) Define los tiempos de llegada de los vehiculos a los nodos.
lim_tiempo(j,v,w) Establece el limite temporal de la mision.

def_Eq Definicion de la variable criterio de equidad Eq.
;

si_sales_entraste(j,v,w)$(ord(j)>1).. sum(i, X(i,j,v,w)) =G= sum(i, X(j,i,v,w));
pasas_por_Z(j,v,w).. Z(j,v,w) =L= sum(i, X(i,j,v,w));
solo_un_Z(v,w).. sum(j, Z(j,v,w)) =E= Salio(v,w);
debes_volver(v,w).. sum(i, X(i,"0",v,w)) =G= Salio(v,w);
def_salio_1(v,w).. Salio(v,w) =L= M*sum(j, X("0",j,v,w));
def_salio_2(v,w).. sum(j, X("0",j,v,w)) =L= M*Salio(v,w);
 
existencia(i,j,v,w).. X(i,j,v,w) =L= E(i,j);
usabilidad(i,j,v,w)$(E(i,j) > 0).. X(i,j,v,w) =L= U(i,j) + H(i,j);

lim_coste.. Coste =L= max_coste;
lim_habilitaciones.. sum(i, sum(j, H(i,j))) =L= max_habilitaciones;

def_Ayuda(j).. Ayuda(j) =E= sum(v, sum(w, Z(j,v,w)*capacidad_vehiculo(v)));
lim_demanda(j).. Ayuda(j) =L= dem(j);


f_Insatis.. Insatis =E= sum(j, dem(j) - Ayuda(j));
def_Coste.. Coste =E= sum(i, sum(j, sum(v, sum(w, X(i,j,v,w)*coste_variable*Dist(i,j))))) +
                      sum(i, sum(j, H(i,j)*coste_rehabilitacion(i,j))) +
                      sum(v, sum(w, Salio(v,w)*coste_fijo(v)));

def_fiabilidad.. Fiabilidad =E= sum(i, sum(j, Usado(i,j)*P(i,j)));
lim_fiabilidad..  Fiabilidad =G= P_total;
arco_usado(i,j)$(E(i,j) > 0).. Usado(i,j) =G= sum(v, sum(w, X(i,j,v,w)));

def_tiempos(i,j,v,w)$(E(i,j) > 0).. t(j,v,w) - t(i,v,w) + dist(i,j)*velocidad_vehiculo(v)=L= T_max*(1 - X(i,j,v,w));
lim_tiempo(j,v,w).. t(j,v,w) =L= T_max;

def_Eq.. Eq =E= sum(j, sum(v, sum(w, Z(j,v,w))));

model modelo1 /all/;

solve modelo1 using MIP minimizing Insatis
solve modelo1 using MIP maximizing Eq
;



