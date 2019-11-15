  
using JuMP, Clp, Printf

d = [40 60 75 25]                      #  Quarter demands.

m = Model(with_optimizer(Clp.Optimizer))

@variable(m, 0 <= x[1:4] <= 40)       #boats produced with regular labor.
@variable(m, y[1:4] >= 0)             #boats produced with overtime labor.
#@variable(m, h[1:5])                 #boats held in inventory.
@variable(m, hplus[1:5] >= 0)         #h+ held in inventory.
@variable(m, hminus[1:5] >= 0)        #h- held in inventory.
@variable(m, cplus[1:4] >= 0)
@variable(m, cminus[1:4] >= 0)

@constraint(m, hplus[4] >= 10)        
@constraint(m, hminus[4] <= 0)         
@constraint(m, hplus[1]-hminus[1] ==  (10)+x[1]+y[1]-d[1])
@constraint(m, x[1]+y[1]-(50) == cplus[1]-cminus[1])
@constraint(m, stream[i in 1:3], x[i+1]+y[i+1]-(x[i]+y[i]) == cplus[i+1]-cminus[i+1])
@constraint(m, flow[i in 1:3], (hplus[i+1] - hminus[i+1]) == (hplus[i] - hminus[i]) + x[i+1]+y[i+1]-d[i+1])

@objective(m, Min, 400*sum(x) + 450*sum(y) + 20*sum(hplus) + 100*sum(hminus) + 400*sum(cplus) + 500*sum(cminus))           #Minimizing cost with formula

optimize!(m)

@printf("\n")
@printf("Expected demand for each four quarter in oneyear : %d %d %d %d\n",(d[1]), (d[2]), (d[3]), (d[4]))
@printf("Boats to build regular labor: %d %d %d %d\n", value(x[1]), value(x[2]), value(x[3]), value(x[4]))
@printf("Boats to build extra labor: %d %d %d %d\n", value(y[1]), value(y[2]), value(y[3]), value(y[4]))
#@printf("Inventories: %d %d %d %d %d\n", value(h[1]), value(h[2]), value(h[3]), value(h[4]), value(h[5]))
@printf("H+ values: %d %d %d %d %d\n", value(hplus[1]), value(hplus[2]), value(hplus[3]), value(hplus[4]), value(hplus[5]))
@printf("H- values: %d %d %d %d %d\n", value(hminus[1]), value(hminus[2]), value(hminus[3]), value(hminus[4]), value(hminus[5]))
#@printf("C+ values: %d %d %d %d\n", value(cplus[1]), value(cplus[2]), value(cplus[3]), value(cplus[4]))       
#@printf("C- values: %d %d %d %d\n", value(cminus[1]), value(cminus[2]), value(cminus[3]), value(cminus[4]))        
@printf("Objective cost: %f\n", objective_value(m))