# Parameters
param n; # nodes
param N; # cap on visited nodes
param L; # minimum cost
param init; # starting node
param fini; # ending node
param G {1..n, 1..n} integer; # cost network

# Variables 
var x {i in 1..n, j in 1..n, k in 2..N} binary; # arc incidence
var u {i in 1..n, k in 1..N} integer >=0, <=N; # node visitation order

# Objective 
minimize TotalCost:
	sum {i in 1..n, j in 1..n, k in 2..N} x[i,j,k]*G[i,j];

# Constraints
subject to Balance {i in 1..n}:
	sum {j in 1..n, k in 2..N} (x[i,j,k]-x[j,i,k]) = 0;  

subject to Order {i in 1..n, j in 1..n, k in 1..N-1}:
	u[i,k]-u[j,k+1]+1-N*(1-x[i,j,k+1]) <= 0;

# only one node per step
subject to UniqueU {i in 1..n, k in 1..N-1}:
	u[i,k] - N*(sum {j in 1..n} x[i,j,k+1]) <= 0;

subject to UniqueL {i in 1..n, k in 1..N-1}:
	u[i,k] + N*(sum {j in 1..n} x[i,j,k+1]) >= 0;
	
subject to UniqueN {k in 1..N}:
	k - sum {i in 1..n} u[i,k] = 0;

# at most one arc per step
subject to UniqueS {k in 2..N}:
	sum {i in 1..n, j in 1..n} x[i,j,k] <= 1;
	
# arcs can only be used once
subject to UniqueA {i in 1..n, j in 1..n}:
	sum {k in 2..N} x[i,j,k] <= 1;

# minimum cost
subject to Lowerbound:
	sum {i in 1..n, j in 1..n,k in 2..N} x[i,j,k]*G[i,j] - L >= 0;

# starting node
subject to Start:
	u[init,1] = 1;

# ending node
subject to End:
	u[fini, N] = N;
	
# Only use feasible arcs
subject to Feasible {i in 1..n, j in 1..n}:
	sum {k in 2..N} x[i,j,k] <= 10000 - G[i,j];


option solver gurobi;
option gurobi_options 'tech:timing=1';

data;
param n = 20;
param N = 28;
param L = 500;
param init = 1;
param fini = 1;
param G:
    1       2     3     4     5     6     7     8     9    10    11    12    13    14    15    16    17    18    19    20 :=
1 10000    11     9     1     7     7    15     5    11    18     9    20    20     3     3     4     8    14     4     4 
2   16 10000     6    18    13    19     8     4     4    15    11 10000    10    11     4    20     1    18     8     5 
3    5    15 10000     7     2     7     4    17     4    11 10000    10    12     6    16     2    12     3    12 10000 
4 10000    20 10000 10000     8    10     7    20     1    18    10    11     5 10000    17 10000    14     7     5     6 
5   12    12    14    15 10000     7    17     9    19    13     3     8     3 10000 10000     8    20    18     5     2 
6   18     5     2    18    15 10000 10000    11    19 10000     3     5    11     8    18     9    13    18     3     2 
7    3     7     4    19    18    17 10000    18 10000    15     7     3     3     8    14     1    19     7     2    14 
8   19     7 10000    16     7     3    20 10000    13    10    13     9     6    17    10    14     3     2     8    16 
9   14    14    12     7    13     6     2    11 10000     8    19     1    10     5    14     6    19     7    19     7 
10   16     2 10000    17    13     3     5     8    12 10000     1     2 10000    13 10000 10000    10    14     2    16 
11    5 10000     8    16    10     3    15    17     4    17 10000    14     3 10000 10000     3 10000    16    16    16 
12    8     1    10     2    17     9     9    14 10000    15     1 10000     8     8     7     3    13     1    16    10 
13   17     9     4     9     5 10000    13    16    19    11 10000     7 10000    17    18     5    20     4    14 10000 
14 10000 10000    17    14    18 10000    16    13    16    14    18    12    10 10000    17     9    18 10000     8     9 
15    8     6     5     4    11    12    11    12     1    13     3     8 10000    16 10000    17    16     2     3    15 
16   16    17    14 10000 10000     7    20    17    18     1    12    19    17    15     1 10000     9     2     7    11 
17    7    16    16    15    12     5    15    16    10    17     7 10000    14 10000     9     7 10000    11    14    18 
18   13    15     5 10000     6    10     3     6     1     4     3     8    15    18    15    16     4 10000 10000    18 
19 10000 10000     2 10000     3     7    16     5    15    20 10000     5     3 10000     6 10000     7    18 10000     6 
20   14     7     9     8    14     2     5     1    18    12    18     8    14    13    17     4     9 10000    12 10000;
solve;

display {i in 1..n, j in 1..n} sum {k in 2..N} x[i,j,k];