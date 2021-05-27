using Distributions

m = constructdice()
run(m)

# Uncertain parameters defined in "Projections and Uncertainties about Climate
# Change in an Era of Minimal Climate Policies" (Nordhaus, 2018) EViews file
# provided by the AEJ : https://www.aeaweb.org/articles?id=10.1257/pol.20170046

mcs = @defsim begin
    t2xco2  = LogNormal(1.106, 0.2646)
	ga0     = Normal(0.076, 0.056)
	gsigma1 = Normal(-0.0152, 0.0032)
	mueq    = LogNormal(5.851, 0.2649)
	a2      = Normal(0.00227, 0.001135)

## Added parameters

	## Howard and Sterner Damage Functions

		## means
			# 			t2      	mkt_t2      cat_t2     prod_t2       cross
			# 	mean   .59538273  -.62173351   .25985113   .11332489   1.7004998
	
		## covariance matrix, table 2 column 4 
			# 					t2     		mkt_t2     cat_t2     	prod_t2    cross
			# 	t2   		.03628389
			# 	mkt_t2  	-.03628389   .05115502
			# 	cat_t2  	-.04206286   .04206286   .07143358
			# 	prod_t2 	-1.274e-17  -.01407326   2.389e-17   .01574598
			#  	cross  		-2.127e-17  -.01413532   4.114e-17   .00436625   .11743273
	
		## create matrix of random draws
		hs_mu = [0.59538273 ; -0.62173351 ; 0.25985113 ; 0.11332489 ; 1.7004998]

		hs_sig = Symmetric([ 0.03628389  -0.03628389  -0.04206286  -1.274e-17   -2.127e-17;
							-0.03628389   0.05115502   0.04206286  -0.01407326  -0.01413532;
							-0.04206286   0.04206286   0.07143358   2.389e-17    4.114e-17;
							-1.274e-17   -0.01407326   2.389e-17    0.01574598   0.00436625
							-2.127e-17   -0.01413532   4.114e-17    0.00436625   0.11743273])
							
		hs_mvn = MvNormal(hs_mu, hs_sig)
		
		hs_t2      = hs_mvn[1]
		hs_cat_t2  = hs_mvn[3]
		hs_prod_t2 = hs_mvn[4]

    save(damages.DAMAGES)
	save(grosseconomy.YGROSS)
	save(emissions.E)
	save(co2cycle.MU)
	save(damages.DAMFRAC)
end

run(mcs, m, 1000; trials_output_filename = "/tmp/dice-2016/trialdata.csv", results_output_dir="/tmp/dice-2016")
