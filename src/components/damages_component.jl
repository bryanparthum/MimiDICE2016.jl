@defcomp damages begin
    DAMAGES = Variable(index=[time])    #Damages (trillions 2010 USD per year)
    DAMFRAC = Variable(index=[time])    #Damages (fraction of gross output)

    TATM    = Parameter(index=[time])   #Increase temperature of atmosphere (degrees C from 1900)
    YGROSS  = Parameter(index=[time])   #Gross world product GROSS of abatement and damages (trillions 2010 USD per year)
    a1      = Parameter()               #Damage coefficient
    a2      = Parameter()               #Damage quadratic term
    a3      = Parameter()               #Damage exponent

    ## Added parameters
    ## Weitzman 2012
    w_temp = Parameter()
    w_exp  = Parameter()
    ## Howard and Sterner 2018
    hs_t2      = Parameter()               
    hs_cat_t2  = Parameter()              
    hs_prod_t2 = Parameter()               

    function run_timestep(p, v, d, t)
        #Define function for DAMFRAC
        if damage_function == DICE

            v.DAMFRAC[t] = p.a1*p.TATM[t] + p.a2*p.TATM[t]^p.a3
    
        elseif damage_function == WEITZMAN

            damfrac[t] = (p.a1*TATM[t] + p.a2*TATM[t]^p.a3 + p.w_temp*TATM[t]^p.w_exp)/(1 + p.a1*TATM[t] + p.a2*TATM[t]^p.a3 + p.w_temp*TATM[t]^p.w_exp)

        elseif damage_function == HOWARD_STERNER_1

            v.DAMFRAC[t] = p.a1*p.TATM[t] + ((p.hs_t2*1.25)/100)*p.TATM[t]^p.a3

        elseif damage_function == HOWARD_STERNER_2

            v.DAMFRAC[t] = p.a1*p.TATM[t] + ((p.hs_t2*1.25+p.hs_cat_t2)/100)*p.TATM[t]^p.a3

        elseif damage_function == HOWARD_STERNER_3

            v.DAMFRAC[t] = p.a1*p.TATM[t] + (((p.hs_t2+p.hs_prod_t2)*1.25+p.hs_cat_t2)/100)*p.TATM[t]^p.a3

        else
            error("Unknown damage function :$damage_function.")

        #Define function for DAMAGES
            v.DAMAGES[t] = p.YGROSS[t] * v.DAMFRAC[t]
        end
    end