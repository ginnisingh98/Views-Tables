--------------------------------------------------------
--  DDL for Package Body PAY_NO_EMP_CONT_2007
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_NO_EMP_CONT_2007" as
/* $Header: pynoempcont2007.pkb 120.1.12010000.4 2008/09/29 11:49:40 rsengupt ship $ */


----------------------------------Function definitions----------------------------------------------

-- Function to calculate the Employer Contributions

FUNCTION GET_EMPLOYER_DEDUCTION
  (p_tax_unit_id		IN  NUMBER
  ,p_local_unit_id		IN  NUMBER
  ,p_jurisdiction_code		IN  VARCHAR2
  ,p_payroll_id			IN  NUMBER
  ,p_payroll_action_id		IN  NUMBER
  ,p_date_earned		IN  DATE
  ,p_asg_act_id			IN  NUMBER
  ,p_bus_group_id		IN  NUMBER
  ,p_under_age_high_rate	IN  NUMBER
  ,p_over_age_high_rate		IN  NUMBER
  ,p_run_base			OUT NOCOPY NUMBER
  ,p_run_contribution      	OUT NOCOPY NUMBER
  ,p_curr_exemption_limit_used	OUT NOCOPY NUMBER) RETURN NUMBER IS


  -- Local Variables

	l_le_status			VARCHAR2(40) ;
	l_lu_status			VARCHAR2(40) ;
        l_lu_rep_sep			VARCHAR2(1) ;
	l_lu_tax_mun			VARCHAR2(200) ;

	l_val				NUMBER;
	l_temp				NUMBER;
	l_check				NUMBER;
	l_check2			NUMBER;

	l_le_exists			BOOLEAN;
	l_le_lu_exists			BOOLEAN;

	l_main_index			NUMBER;
	start_index_main		NUMBER;
	end_index_main			NUMBER;
	start_index_calc		NUMBER;
	end_index_calc			NUMBER;

	start_index_mu			NUMBER;
	end_index_mu			NUMBER;
	start_index_lu			NUMBER;
	end_index_lu			NUMBER;

	l_asg_ers_base			NUMBER;
	l_asg_ers_base2			NUMBER;
	l_asg_ers_base_diff		NUMBER;

	l_lu_ers_base			NUMBER;
	l_lu_ers			NUMBER;

	l_le_ers_base			NUMBER;
	l_le_ers			NUMBER;

	l_zone				VARCHAR2(10);
	l_zone_temp			VARCHAR2(20);
	l_cell				NUMBER;

	l_le_lu_index			NUMBER;
	l_le_index			NUMBER;

	l_def_bal_id_1			NUMBER;
	l_def_bal_id_2			NUMBER;
	l_def_bal_id_3			NUMBER;
	l_def_bal_id_4			NUMBER;


	l_bal_val_ytd			NUMBER;
	l_bal_val_bimonth		NUMBER;

	l_le_run			NUMBER;

	l_exemption_limit_used		NUMBER;
	l_exemption_limit_used_yet	NUMBER;
	l_exemption_limit		NUMBER;

	-- 2007 Legislative changes for 'Economic Aid' to Employer
	l_economic_aid			NUMBER;

	l_LU_over_limit			VARCHAR2(1);
	l_LE_over_limit			VARCHAR2(1);

	l_table_name			VARCHAR2(240);
	l_col_name			VARCHAR2(240);
	l_zone_value			VARCHAR2(240);

	l_high_rate			NUMBER;
	l_normal_rate			NUMBER;
	l_diff_rate			NUMBER;

	l_saving			NUMBER;
	l_total_saving			NUMBER;
	l_amount_over_limit		NUMBER;
	l_base_over_limit		NUMBER;

	l_total_bimonth_base		NUMBER;
	l_old_bimonth_base		NUMBER;
	l_new_bimonth_base		NUMBER;

	l_old_run_base			NUMBER;
	l_new_run_base			NUMBER;

	l_old_bmth_cont_todate		NUMBER;
	l_new_bmth_cont_todate		NUMBER;

	l_curr_zone			VARCHAR2(10);
	l_bimonth_end_date		DATE;


  -- Local PL/SQL Tables

	g_tab_calc			PAY_NO_EMP_CONT_2007.g_tab_calc_tabtype;
	g_lu_tab			PAY_NO_EMP_CONT_2007.g_lu_tabtype;
	g_mu_tab			PAY_NO_EMP_CONT_2007.g_mu_tabtype;

  -- Cursor definitions

   	-- csr to get the current assignment_action_ids with the same LE
	cursor csr_curr_le_asg_act_id
	(p_tax_unit_id   pay_assignment_actions.TAX_UNIT_ID%TYPE
	,p_payroll_action_id  pay_payroll_actions.PAYROLL_ACTION_ID%type
	,p_date_earned  DATE ) is
	select pact.ASSIGNMENT_ACTION_ID
	from pay_assignment_actions pact
	    ,pay_run_types_f		prt
	where pact.PAYROLL_ACTION_ID = p_payroll_action_id
	and   pact.TAX_UNIT_ID = p_tax_unit_id
	and   prt.LEGISLATION_CODE = 'NO'
	and   prt.RUN_TYPE_NAME = 'Employer Contributions'
	and   nvl(pact.RUN_TYPE_ID,-99) <> prt.RUN_TYPE_ID
	and   p_date_earned between prt.EFFECTIVE_START_DATE and prt.EFFECTIVE_END_DATE ;


------------- Remove this
-- testing the number of rows returned by the above	cursor
   	-- csr to get the current assignment_action_ids with the same LE
	cursor csr_test_aag_act_id
	(p_tax_unit_id   pay_assignment_actions.TAX_UNIT_ID%TYPE
        ,p_payroll_action_id  pay_payroll_actions.PAYROLL_ACTION_ID%type
	,p_date_earned  DATE ) is
	select count(*)
	from pay_assignment_actions pact
	    ,pay_run_types_f		prt
	where pact.PAYROLL_ACTION_ID = p_payroll_action_id
	and   pact.TAX_UNIT_ID = p_tax_unit_id
	and   prt.LEGISLATION_CODE = 'NO'
	and   prt.RUN_TYPE_NAME = 'Employer Contributions'
	and   nvl(pact.RUN_TYPE_ID,-99) <> prt.RUN_TYPE_ID
	and   p_date_earned between prt.EFFECTIVE_START_DATE and prt.EFFECTIVE_END_DATE ;

--------------

    cursor csr_get_bimonth_end_date (p_date_earned DATE) is
    select last_day(Add_months(p_date_earned,MOD(TO_NUMBER(TO_CHAR(p_date_earned,'MM')),2)))
    from dual;

------------------- end cursor definitions

			--------------- Begin -------------------------------------

  BEGIN

	-- hr_utility.trace_on(null,'NOEC');
	hr_utility.trace('2007 EMP_CONT ::: Enterd procedure GET_EMPLOYER_DEDUCTION ----------------------------------');
	hr_utility.trace('2007 EMP_CONT ::: -------------------------------------------------');
	hr_utility.trace('2007 EMP_CONT :::  p_tax_unit_id = '|| p_tax_unit_id );
	hr_utility.trace('2007 EMP_CONT :::  p_local_unit_id = '|| p_local_unit_id );
	hr_utility.trace('2007 EMP_CONT :::  p_jurisdiction_code = '|| p_jurisdiction_code );
	hr_utility.trace('2007 EMP_CONT :::  p_payroll_id = '|| p_payroll_id );
	hr_utility.trace('2007 EMP_CONT :::  p_payroll_action_id = '|| p_payroll_action_id );
	hr_utility.trace('2007 EMP_CONT :::  p_asg_act_id = '|| p_asg_act_id );
	hr_utility.trace('2007 EMP_CONT :::  p_bus_group_id = '|| p_bus_group_id );
	hr_utility.trace('2007 EMP_CONT :::  p_date_earned = '|| p_date_earned );
	hr_utility.trace('2007 EMP_CONT :::  p_under_age_high_rate = '|| p_under_age_high_rate );
	hr_utility.trace('2007 EMP_CONT :::  p_over_age_high_rate = '|| p_over_age_high_rate );
	hr_utility.trace('2007 EMP_CONT ::: -------------------------------------------------');


	-- cursor retrieves bimonth end date for the p_date_earned
	OPEN csr_get_bimonth_end_date (p_date_earned);
	FETCH csr_get_bimonth_end_date INTO l_bimonth_end_date;
	CLOSE csr_get_bimonth_end_date;

        -- Get the current assignment's Zone

	-- zone will now be fetched from user tables, have to change the below call
	-- l_curr_zone	:= to_number(substr(get_lookup_meaning('NO_TAX_MUNICIPALITY',p_jurisdiction_code),1,1));
	l_curr_zone	:= hruserdt.get_table_value (p_bus_group_id, 'NO_TAX_MUNICIPALITY' , 'ZONE', p_jurisdiction_code, p_date_earned ) ;

	hr_utility.trace('2007 EMP_CONT :::  l_curr_zone = '|| l_curr_zone );

	-- Get the Status , Report Separately and Tax Municipality for the Local Unit of the current assignment
	OPEN PAY_NO_EMP_CONT_2007.get_lu_details(p_local_unit_id);
	FETCH PAY_NO_EMP_CONT_2007.get_lu_details INTO l_lu_status , l_lu_rep_sep , l_lu_tax_mun ;
	CLOSE PAY_NO_EMP_CONT_2007.get_lu_details;

	hr_utility.trace('2007 EMP_CONT :::  l_lu_status = '|| l_lu_status );
	hr_utility.trace('2007 EMP_CONT :::  l_lu_rep_sep = '|| l_lu_rep_sep );
	hr_utility.trace('2007 EMP_CONT :::  l_lu_tax_mun = '|| l_lu_tax_mun );
	hr_utility.trace('2007 EMP_CONT :::  goin to test for local unit report separately..........');

	-- check if Local Unit is Report separately = yes
	IF trim(l_lu_rep_sep) = 'Y'

		THEN ---------------------------------------------------------------------------------------------------------------------------------
			-- since LU is report separately, check if LE LU combination exists

			hr_utility.trace('2007 EMP_CONT ::: Local unit is Rep Sep');

			start_index_main 		:= NVL (PAY_NO_EMP_CONT_2007.g_tab_main.FIRST, 0) ;
			end_index_main   		:= NVL (PAY_NO_EMP_CONT_2007.g_tab_main.LAST, 0) ;
			l_le_lu_exists 			:= FALSE;

			-- loop through existing records for LE LU to check if the current LE LU exists

			WHILE (PAY_NO_EMP_CONT_2007.g_tab_main.EXISTS(start_index_main)) and (start_index_main <= end_index_main) LOOP
				IF (PAY_NO_EMP_CONT_2007.g_tab_main(start_index_main).legal_employer_id = p_tax_unit_id) AND
				   (PAY_NO_EMP_CONT_2007.g_tab_main(start_index_main).local_unit_id = p_local_unit_id) AND
				   (PAY_NO_EMP_CONT_2007.g_tab_main(start_index_main).zone = l_curr_zone)

					THEN
						l_le_lu_exists := TRUE;
						l_le_lu_index  := start_index_main;

						hr_utility.trace('2007 EMP_CONT ::: LE LU combination found');
						hr_utility.trace('2007 EMP_CONT ::: l_le_lu_index  = '|| l_le_lu_index );
						EXIT;
				END IF;
				start_index_main := start_index_main + 1;
			END LOOP; -- end while loop


			-- if the LE LU exists, return the values
			IF l_le_lu_exists

				THEN -------------------------------------------------------------------------------------------------------------------------
					-- since the combination alreday exists, calculation has been already done, just return values
		 			p_run_base			:= 	PAY_NO_EMP_CONT_2007.g_tab_main(l_le_lu_index).run_base;
					p_run_contribution		:= 	PAY_NO_EMP_CONT_2007.g_tab_main(l_le_lu_index).run_contribution;
					p_curr_exemption_limit_used	:= 	0;  -- coz this value must have been returned before

					hr_utility.trace('2007 EMP_CONT ::: LU found, since results exist, just returning them');
					hr_utility.trace('2007 EMP_CONT ::: LU ***** l_le_lu_index  = '|| l_le_lu_index );
					hr_utility.trace('2007 EMP_CONT ::: LU ***** p_run_base  = '|| p_run_base );
					hr_utility.trace('2007 EMP_CONT ::: LU ***** p_run_contribution = '|| p_run_contribution );
					hr_utility.trace('2007 EMP_CONT ::: LU ***** p_curr_exemption_limit_used = '|| p_curr_exemption_limit_used );

					hr_utility.trace('2007 EMP_CONT ::: LU ***** Leaving procedure-----------------------------------');

					RETURN 1; -- here return le_run and the other values thru OUT parameters

				ELSE --------------------------------------------------------------------------------------------------------------------------
					-- combination does not exist, calculation has to be done and values returned
					hr_utility.trace('2007 EMP_CONT ::: LU does not exist, calculate for this LU');

					------------------- initializing the g_tab_calc table for LE LU combination
					hr_utility.trace('2007 EMP_CONT ::: LU ***** initializing g_tab_calc ');
					-- loop for each zone

					g_tab_calc(1).zone := '1'  ;
					g_tab_calc(2).zone := '1a' ;
					g_tab_calc(3).zone := '2'  ;
					g_tab_calc(4).zone := '3'  ;
					g_tab_calc(5).zone := '4'  ;
					g_tab_calc(6).zone := '4a' ;
					g_tab_calc(7).zone := '5'  ;


					FOR i IN 1..7 LOOP

					    g_tab_calc(i).under_limit 	:= 'Y';
					    g_tab_calc(i).status 	:= l_lu_status;

						-- initializing all balance values to zero
						g_tab_calc(i).bimonth_base 		  := 0 ;
						g_tab_calc(i).run_base 			  := 0 ;
						g_tab_calc(i).bimonth_contribution        := 0 ;
						g_tab_calc(i).bimonth_contribution_todate := 0 ;
						g_tab_calc(i).run_contribution 		  := 0 ;

					END LOOP; -- end i loop

					hr_utility.trace('2007 EMP_CONT ::: -- calling display_table_calc function  ');
					l_check := display_table_calc(g_tab_calc);
					hr_utility.trace('2007 EMP_CONT ::: -- returned from display_table_calc function  ');

					hr_utility.trace('2007 EMP_CONT ::: LU ***** finished initializing g_tab_calc ');
					-------------------- finished initializing the g_tab_lu table

					------------------ get exemption limit used	for LU
					hr_utility.trace('2007 EMP_CONT ::: LU ***** get exemption limit ');

					-- set the context values for balance
					pay_balance_pkg.set_context('LOCAL_UNIT_ID',p_local_unit_id);

					-- get defined balance ids
					l_def_bal_id_1 := get_defined_balance_id('Employer Contribution Exemption Limit Used','_TU_LU_YTD') ;
					l_def_bal_id_2 := get_defined_balance_id('Employer Contribution Exemption Limit Used','_TU_LU_BIMONTH') ;

					hr_utility.trace('2007 EMP_CONT ::: LU ***** l_def_bal_id_1 = '|| l_def_bal_id_1 );
					hr_utility.trace('2007 EMP_CONT ::: LU ***** l_def_bal_id_2 = '|| l_def_bal_id_2 );

					-- get the balance value
					l_bal_val_ytd     := pay_balance_pkg.get_value(l_def_bal_id_1,p_asg_act_id,p_tax_unit_id,p_jurisdiction_code,NULL,NULL,NULL,l_bimonth_end_date);
					l_bal_val_bimonth := pay_balance_pkg.get_value(l_def_bal_id_2,p_asg_act_id,p_tax_unit_id,p_jurisdiction_code,NULL,NULL,NULL,l_bimonth_end_date);

					l_exemption_limit_used_yet := l_bal_val_ytd - l_bal_val_bimonth ;

					hr_utility.trace('2007 EMP_CONT ::: LU *****  l_bal_val_ytd = '|| l_bal_val_ytd );
					hr_utility.trace('2007 EMP_CONT ::: LU *****  l_bal_val_bimonth = '|| l_bal_val_bimonth );
					hr_utility.trace('2007 EMP_CONT ::: LU *****  l_exemption_limit_used_yet = '|| l_exemption_limit_used_yet );

					OPEN PAY_NO_EMP_CONT_2007.csr_get_exemption_limit(p_local_unit_id ,p_date_earned );

					-- 2007 Legislative changes for 'Economic Aid' to Employer
					-- FETCH PAY_NO_EMP_CONT_2007.csr_get_exemption_limit INTO l_exemption_limit ;
					FETCH PAY_NO_EMP_CONT_2007.csr_get_exemption_limit INTO l_exemption_limit , l_economic_aid ;

					CLOSE PAY_NO_EMP_CONT_2007.csr_get_exemption_limit;

					hr_utility.trace('2007 EMP_CONT ::: LU *****  l_exemption_limit = ' || l_exemption_limit );
					hr_utility.trace('2007 EMP_CONT ::: LU *****  l_economic_aid = ' || l_economic_aid );

					-- 2007 Legislative changes for 'Economic Aid' to Employer
					l_exemption_limit := l_exemption_limit - l_economic_aid ;

					hr_utility.trace('2007 EMP_CONT ::: LU *****  l_exemption_limit after reducing eco aid = ' || l_exemption_limit );


					IF l_exemption_limit_used_yet >= l_exemption_limit
						THEN
							l_LU_over_limit := 'Y';
						ELSE
							l_LU_over_limit := 'N';
					END IF ; -- end if exemption limit check

					hr_utility.trace('2007 EMP_CONT ::: LU *****  l_exemption_limit  = '||l_exemption_limit  );
					hr_utility.trace('2007 EMP_CONT ::: LU *****  l_LU_over_limit = '|| l_LU_over_limit );
					hr_utility.trace('2007 EMP_CONT ::: LU *****  got exemtion limt , leaving'  );

					------------------- got exemption limit used for LU

					----------------- populating the tables g_lu_tab (LU) and g_mu_tab (MU)

					-- from 2007 , the tax municipality will be picked from the local unit

					hr_utility.trace('2007 EMP_CONT ::: LU *****  populating g_lu_tab and g_mu_tab , entering '  );

					l_temp := populate_tables
					  (p_tax_unit_id
					  ,p_payroll_id
					  ,p_date_earned
					  ,g_lu_tab
					  ,g_mu_tab  );


					hr_utility.trace('2007 EMP_CONT ::: LU *****  populated g_lu_tab and g_mu_tab , leaving '  );
					----------------- Fetch the run base using assignment level balances (at LU level)
					hr_utility.trace('2007 EMP_CONT ::: LU *****  Fetch the run base using assignment level balances , enetring '  );

					-- get defined balance ids
					l_def_bal_id_1 := get_defined_balance_id('Employer Contribution Base','_ASG_TU_MU_LU_BIMONTH') ;
					l_def_bal_id_2 := get_defined_balance_id('Employer Contribution Base 2','_ASG_TU_MU_LU_BIMONTH') ;

					hr_utility.trace('2007 EMP_CONT ::: LU ***** l_def_bal_id_1 = '|| l_def_bal_id_1 );
					hr_utility.trace('2007 EMP_CONT ::: LU ***** l_def_bal_id_2 = '|| l_def_bal_id_2 );

					----- test only , Remove it
					OPEN   csr_test_aag_act_id (p_tax_unit_id , p_payroll_action_id, p_date_earned);
					FETCH  csr_test_aag_act_id INTO l_check2;
					CLOSE  csr_test_aag_act_id;
					hr_utility.trace('2007 EMP_CONT ::: LU ***** l_check2 , no of rows returned by asg act id cursor  = '||l_check2  );
					-- remove till here

					hr_utility.trace('2007 EMP_CONT ::: LU ***** level 0 leave' );

					pay_balance_pkg.set_context('TAX_UNIT_ID',p_tax_unit_id);
					pay_balance_pkg.set_context('LOCAL_UNIT_ID',p_local_unit_id);

					-----

					-- loop to get all assignment_action_id in the current payroll_action_id
					FOR csr1_rec IN csr_curr_le_asg_act_id (p_tax_unit_id , p_payroll_action_id, p_date_earned) LOOP

						hr_utility.trace('2007 EMP_CONT ::: LU ***** level 1 , loop csr_curr_le_asg_act_id ' );

						start_index_mu := NVL (g_mu_tab.FIRST, 0) ;
						end_index_mu   := NVL (g_mu_tab.LAST, 0) ;

						WHILE (g_mu_tab.EXISTS(start_index_mu)) and (start_index_mu <= end_index_mu) LOOP

							hr_utility.trace('2007 EMP_CONT ::: LU ***** level 2, g_mu_tab ' );
							hr_utility.trace('2007 EMP_CONT ::: LU ***** ASS_ACT_ID = '|| csr1_rec.ASSIGNMENT_ACTION_ID || ' MU = '|| g_mu_tab(start_index_mu)|| ' LU = '|| p_local_unit_id );

							pay_balance_pkg.set_context('JURISDICTION_CODE',g_mu_tab(start_index_mu));

							-- get the balance value
							l_asg_ers_base      := pay_balance_pkg.get_value(l_def_bal_id_1,csr1_rec.ASSIGNMENT_ACTION_ID);
							l_asg_ers_base2     := pay_balance_pkg.get_value(l_def_bal_id_2,csr1_rec.ASSIGNMENT_ACTION_ID);
							l_asg_ers_base_diff :=	l_asg_ers_base - l_asg_ers_base2;


							hr_utility.trace('2007 EMP_CONT ::: LU *****  l_asg_ers_base = '|| l_asg_ers_base );
							hr_utility.trace('2007 EMP_CONT ::: LU *****  l_asg_ers_base2 = '|| l_asg_ers_base2 );
							hr_utility.trace('2007 EMP_CONT ::: LU *****  l_asg_ers_base_diff = '|| l_asg_ers_base_diff );

							hr_utility.trace('2007 EMP_CONT ::: LU ***** ============== just checking================= ');
							hr_utility.trace('2007 EMP_CONT ::: LU ***** g_mu_tab(start_index_mu) = '|| g_mu_tab(start_index_mu) );

							l_zone_temp := to_char(g_mu_tab(start_index_mu));

							hr_utility.trace('2007 EMP_CONT ::: LU ***** l_zone_temp  = '|| l_zone_temp );

							-- l_zone := to_number(substr(get_lookup_meaning('NO_TAX_MUNICIPALITY',l_zone_temp),1,1));
							l_zone	:= hruserdt.get_table_value (p_bus_group_id, 'NO_TAX_MUNICIPALITY' , 'ZONE', l_zone_temp, p_date_earned ) ;


							hr_utility.trace('2007 EMP_CONT ::: LU ***** l_zone  = '|| l_zone );

							l_cell := lookup_cell(g_tab_calc, l_zone);
							g_tab_calc(l_cell).run_base  := g_tab_calc(l_cell).run_base + l_asg_ers_base_diff ;

							hr_utility.trace('2007 EMP_CONT ::: LU ***** l_cell = '|| l_cell );

							start_index_mu := start_index_mu + 1;

						END LOOP; -- end while loop

					END LOOP;	-- end loop csr1_rec


					hr_utility.trace('2007 EMP_CONT ::: LU ***** level 0 back' );

					hr_utility.trace('2007 EMP_CONT ::: -- calling display_table_calc function  ');
					l_check := display_table_calc(g_tab_calc);
					hr_utility.trace('2007 EMP_CONT ::: -- returned from display_table_calc function  ');

					hr_utility.trace('2007 EMP_CONT ::: LU *****  Fetched the run base using assignment level balances , leaving '  );
					---------------------- Fetched the run base using assignment level balances (at LU level)

					----------------- Fetch the bimonth base using group level balances (at LU level)
					hr_utility.trace('2007 EMP_CONT ::: LU *****  Fetch the bimonth base using group level balances  , entering '  );

					-- get defined balance ids
					l_def_bal_id_1 := get_defined_balance_id('Employer Contribution Base','_TU_MU_LU_BIMONTH') ;
					l_def_bal_id_2 := get_defined_balance_id('Employer Contribution','_TU_MU_LU_BIMONTH') ;

					hr_utility.trace('2007 EMP_CONT ::: LU ***** l_def_bal_id_1 = '|| l_def_bal_id_1 );
					hr_utility.trace('2007 EMP_CONT ::: LU ***** l_def_bal_id_2 = '|| l_def_bal_id_2 );

					-- loop to get all MU in g_mu_tab

						start_index_mu := NVL (g_mu_tab.FIRST, 0) ;
						end_index_mu   := NVL (g_mu_tab.LAST, 0) ;

					hr_utility.trace('2007 EMP_CONT ::: LU *****   level 0 leave ' );

					pay_balance_pkg.set_context('LOCAL_UNIT_ID',p_local_unit_id);


					WHILE (g_mu_tab.EXISTS(start_index_mu)) and (start_index_mu <= end_index_mu) LOOP

						hr_utility.trace('2007 EMP_CONT ::: LU *****   level 1 ,g_mu_tab  '  );

						pay_balance_pkg.set_context('JURISDICTION_CODE',g_mu_tab(start_index_mu));

						hr_utility.trace('2007 EMP_CONT ::: LU *****  MU = '|| g_mu_tab(start_index_mu)|| ' LU = '|| p_local_unit_id );

						-- get the balance value
						l_lu_ers_base := pay_balance_pkg.get_value(l_def_bal_id_1,p_asg_act_id,p_tax_unit_id,g_mu_tab(start_index_mu),NULL,NULL,NULL,l_bimonth_end_date);
						l_lu_ers := pay_balance_pkg.get_value(l_def_bal_id_2,p_asg_act_id,p_tax_unit_id,g_mu_tab(start_index_mu),NULL,NULL,NULL,l_bimonth_end_date);

						hr_utility.trace('2007 EMP_CONT ::: LU *****  l_lu_ers_base = '||  l_lu_ers_base);
						hr_utility.trace('2007 EMP_CONT ::: LU *****  l_lu_ers = '||l_lu_ers );

						hr_utility.trace('2007 EMP_CONT ::: LU ***** ============== just checking again ================= ');

						hr_utility.trace('2007 EMP_CONT ::: LU ***** g_mu_tab(start_index_mu) = '|| g_mu_tab(start_index_mu) );

						l_zone_temp := to_char(g_mu_tab(start_index_mu));

						hr_utility.trace('2007 EMP_CONT ::: LU ***** l_zone_temp  = '|| l_zone_temp );

						-- l_zone := to_number(substr(get_lookup_meaning('NO_TAX_MUNICIPALITY',l_zone_temp),1,1));
						l_zone	:= hruserdt.get_table_value (p_bus_group_id, 'NO_TAX_MUNICIPALITY' , 'ZONE', l_zone_temp, p_date_earned ) ;

						hr_utility.trace('2007 EMP_CONT ::: LU *****  l_zone  = '|| l_zone );

						l_cell := lookup_cell(g_tab_calc, l_zone);
						g_tab_calc(l_cell).bimonth_base  := g_tab_calc(l_cell).bimonth_base + l_lu_ers_base ;
						g_tab_calc(l_cell).bimonth_contribution_todate  := g_tab_calc(l_cell).bimonth_contribution_todate + l_lu_ers ;

						hr_utility.trace('2007 EMP_CONT ::: LU *****  l_cell = '|| l_cell );

						start_index_mu := start_index_mu + 1;
					END LOOP; -- end while loop

					hr_utility.trace('2007 EMP_CONT ::: LU *****   level 0 back' );

					hr_utility.trace('2007 EMP_CONT ::: -- calling display_table_calc function  ');
					l_check := display_table_calc(g_tab_calc);
					hr_utility.trace('2007 EMP_CONT ::: -- returned from display_table_calc function  ');

					hr_utility.trace('2007 EMP_CONT ::: LU *****  Fetched the bimonth base using group level balances  , leaving '  );
					---------------------- Fetched the bimonth base using group level balances (at LU level)


					------------------------------ apply differential rate and check exemption limit at LU Level

					hr_utility.trace('2007 EMP_CONT ::: LU *****  apply differential rate and check exemption limit , entering '  );
					--l_lu_status   status for LU
					--l_le_status   status for LE
					l_total_saving := 0;

					-- changing this calc

					-- check if exemption limit already used up
					IF l_LU_over_limit = 'Y'

						THEN
							hr_utility.trace('2007 EMP_CONT ::: LU ***** l_LU_over_limit = Y  '  );

							-- as limit is over, put under_limit as N for all rows
							FOR i IN 1..7 LOOP
							    g_tab_calc(i).under_limit 	:= 'N';
							END LOOP; -- end i loop

							hr_utility.trace('2007 EMP_CONT ::: LU ***** as limit is over, put under_limit as N for all rows  '  );

						ELSE
							hr_utility.trace('2007 EMP_CONT ::: LU ***** l_LU_over_limit = N  '  );

							-- limit is not over
							-- perform exemption limit check only if status = AA,CC,GG
							IF ( l_lu_status = 'AA' OR l_lu_status = 'GG' OR l_lu_status = 'CC' )

								THEN
									hr_utility.trace('2007 EMP_CONT ::: LU ***** status is = '|| l_lu_status  );

									-------- performing exemption limit check
									l_table_name := 'NO_NIS_ZONE_RATES';

									-- loop for each zone,under_62 commbination
									FOR i IN 2..7 LOOP

										-- l_col_name := 'Under Age Percentage';
										-- BUG Fix : 5999230
										-- Renaming user column of user table NO_NIS_ZONE_RATES from 'Under Age Percentage' to 'NIS Rates'

										l_col_name := 'NIS Rates';
										l_high_rate :=  p_under_age_high_rate;

										hr_utility.trace('2007 EMP_CONT ::: LU *****   exemption limit check ----------------------------'  );

									        l_zone_value  := g_tab_calc(i).zone;
										-- l_normal_rate := TO_NUMBER(hruserdt.get_table_value (p_bus_group_id, l_table_name, l_col_name, l_zone_value, p_date_earned ));
										l_normal_rate := fnd_number.canonical_to_number(hruserdt.get_table_value (p_bus_group_id, l_table_name, l_col_name, l_zone_value, p_date_earned ));
										l_diff_rate   := l_high_rate - l_normal_rate ;


										l_saving := ( g_tab_calc(i).bimonth_base * l_diff_rate ) / 100 ;
										l_total_saving := l_total_saving + l_saving ;

										hr_utility.trace('2007 EMP_CONT ::: LU *****  i = '||i||' l_zone_value = '||l_zone_value
									                      ||' l_normal_rate = '||l_normal_rate||' l_high_rate = '||l_high_rate
														  ||' l_diff_rate = '||l_diff_rate||' l_saving = '||l_saving||' l_total_saving = '||l_total_saving );

										-- check if exemption limit exceeded
										IF ((l_exemption_limit_used_yet + l_total_saving) >= l_exemption_limit)
											THEN
												hr_utility.trace('2007 EMP_CONT ::: LU********  exemption limit exceeded in table');
												hr_utility.trace('2007 EMP_CONT ::: LU ***** bimonth_base  = '|| g_tab_calc(i).bimonth_base );
												hr_utility.trace('2007 EMP_CONT ::: LU ***** run_base  = '||g_tab_calc(i).run_base  );
												hr_utility.trace('2007 EMP_CONT ::: LU *****  l_zone_value = '|| l_zone_value );
												hr_utility.trace('2007 EMP_CONT ::: LU *****  l_normal_rate = '|| l_normal_rate );
												hr_utility.trace('2007 EMP_CONT ::: LU *****  l_high_rate = '|| l_high_rate );
												hr_utility.trace('2007 EMP_CONT ::: LU *****  l_diff_rate = '|| l_diff_rate );
												hr_utility.trace('2007 EMP_CONT ::: LU *****  l_saving = '|| l_saving );
												hr_utility.trace('2007 EMP_CONT ::: LU *****  l_total_saving= '|| l_total_saving );
												hr_utility.trace('2007 EMP_CONT ::: LU *****  l_exemption_limit_used_yet = '|| l_exemption_limit_used_yet  );

												-- get the exceeding amount
												l_amount_over_limit := ((l_exemption_limit_used_yet + l_total_saving) - l_exemption_limit);
												l_base_over_limit := (l_amount_over_limit / l_diff_rate) * 100 ;

												-------
												l_total_bimonth_base := g_tab_calc(i).bimonth_base ;
												l_old_bimonth_base := l_total_bimonth_base - l_base_over_limit ;
												l_new_bimonth_base := l_base_over_limit ;

												l_old_run_base := (l_old_bimonth_base / l_total_bimonth_base ) * g_tab_calc(i).run_base ;
												l_new_run_base := (l_new_bimonth_base / l_total_bimonth_base ) * g_tab_calc(i).run_base ;

												l_old_bmth_cont_todate := ( l_old_bimonth_base / l_total_bimonth_base ) *  g_tab_calc(i).bimonth_contribution_todate ;
												l_new_bmth_cont_todate := ( l_new_bimonth_base / l_total_bimonth_base ) *  g_tab_calc(i).bimonth_contribution_todate ;

												g_tab_calc(i).bimonth_base 			:= l_old_bimonth_base ;
												g_tab_calc(i).run_base 				:= l_old_run_base ;
												g_tab_calc(i).bimonth_contribution_todate 	:= l_old_bmth_cont_todate ;

												-------

												-- to set the actual total saving coz here the total saving might cross the exemption limit provided
												-- set the new l_total_saving

												l_total_saving := l_exemption_limit - l_exemption_limit_used_yet ;

												hr_utility.trace('2007 EMP_CONT ::: LU ***** l_amount_over_limit  = '|| l_amount_over_limit );
												hr_utility.trace('2007 EMP_CONT ::: LU ***** l_base_over_limit  = '|| l_base_over_limit );
												hr_utility.trace('2007 EMP_CONT ::: LU ***** NEW bimonth base for current row  = '|| g_tab_calc(i).bimonth_base );
												hr_utility.trace('2007 EMP_CONT ::: LU ***** NEW l_total_saving  = '|| l_total_saving );

												-- insert a new row for exceeded limit

											        g_tab_calc(8).zone 				:= g_tab_calc(i).zone;
											        g_tab_calc(8).under_limit 			:= 'N';
												g_tab_calc(8).status 				:= g_tab_calc(i).status;
												g_tab_calc(8).bimonth_base 			:= l_new_bimonth_base ;
												g_tab_calc(8).run_base 				:= l_new_run_base ;
												g_tab_calc(8).bimonth_contribution 		:= g_tab_calc(i).bimonth_contribution ;
												g_tab_calc(8).bimonth_contribution_todate 	:= l_new_bmth_cont_todate ;
												g_tab_calc(8).run_contribution 			:= g_tab_calc(i).run_contribution ;

												-- finished inserting new row

												-- set remaining rows under_limit = N
												FOR j IN i+1..7 LOOP
													g_tab_calc(j).under_limit := 'N';
												END LOOP; --end j loop

												l_LU_over_limit := 'Y'; -- indicating exemption limit on LU level is over

												--hr_utility.trace('2007 EMP_CONT ::: LU ***** l_LU_over_limit Y' );
												hr_utility.trace('2007 EMP_CONT ::: LU ***** l_LU_over_limit = '||l_LU_over_limit );

												EXIT; -- exit loop i since no more check is required
										END IF; -- end check if exemption limit exceeded

										-- for AA and GG, only exemption limit check required for zone 1a, exit after that
										IF ( l_lu_status = 'AA' OR l_lu_status = 'GG')
										  THEN EXIT ;
										END IF;

									END LOOP; -- end i loop

									-------- performed exemption limit check

							END IF; -- end if status = AA,CC,GG

					END IF; -- end if l_LU_over_limit = Y

					-- from the total saving, removing exemption limit reported in the bimonth period
					-- exemption limit used currently at LU level
					l_exemption_limit_used := l_total_saving - l_bal_val_bimonth ;

					hr_utility.trace('2007 EMP_CONT ::: LU ***** l_total_saving  = '||l_total_saving  );
					hr_utility.trace('2007 EMP_CONT ::: LU ***** l_bal_val_bimonth  = '||l_bal_val_bimonth  );
					hr_utility.trace('2007 EMP_CONT ::: LU ***** l_exemption_limit_used  = '||l_exemption_limit_used  );

					hr_utility.trace('2007 EMP_CONT ::: -- calling display_table_calc function  ');
					l_check := display_table_calc(g_tab_calc);
					hr_utility.trace('2007 EMP_CONT ::: -- returned from display_table_calc function  ');

					hr_utility.trace('2007 EMP_CONT ::: LU *****  applied differential rate and check exemption limit , leaving '  );
					------------------------------ applied differential rate and check exemption limit	at LU Level

					-- ec_main_calculation function call for LU
					hr_utility.trace('2007 EMP_CONT ::: LU *****  ec_main_calculation function call for LU , entering '  );

					l_main_index := ec_main_calculation (    g_tab_calc
										,PAY_NO_EMP_CONT_2007.g_tab_main
										,p_tax_unit_id
										,p_local_unit_id
										,l_exemption_limit_used
										,l_lu_status
										,p_bus_group_id
										,p_date_earned
										,p_under_age_high_rate
										,p_over_age_high_rate
										,l_curr_zone		) ;

					hr_utility.trace('2007 EMP_CONT ::: -- calling display_table_calc function  ');
					l_check := display_table_calc(g_tab_calc);
					hr_utility.trace('2007 EMP_CONT ::: -- returned from display_table_calc function  ');

					hr_utility.trace('2007 EMP_CONT ::: LU *****  ec_main_calculation function call for LU , leaving '  );

					-- done all caclculation  and entered values in the main table for next time usage

					-- returning values at LU level
					p_run_base			:= 	PAY_NO_EMP_CONT_2007.g_tab_main(l_main_index).run_base;
					p_run_contribution		:= 	PAY_NO_EMP_CONT_2007.g_tab_main(l_main_index).run_contribution;
					p_curr_exemption_limit_used	:= 	PAY_NO_EMP_CONT_2007.g_tab_main(l_main_index).exemption_limit_used;

					hr_utility.trace('2007 EMP_CONT ::: LU ***** l_main_index  = '|| l_main_index );
					hr_utility.trace('2007 EMP_CONT ::: LU ***** p_run_base  = '|| p_run_base );
					hr_utility.trace('2007 EMP_CONT ::: LU ***** p_run_contribution = '|| p_run_contribution );
					hr_utility.trace('2007 EMP_CONT ::: LU ***** p_curr_exemption_limit_used = '|| p_curr_exemption_limit_used );

					hr_utility.trace('2007 EMP_CONT ::: LU ***** Leaving procedure-----------------------------------');

					RETURN 1; -- here return 1 , other values thru OUT parameters

			END IF; --end if l_le_lu_exists


		ELSE ---------------------------------------------------------------------------------------------------------------------------------
			-- since LU is NOT report separately, check if LE -9999 combination exists

			hr_utility.trace('2007 EMP_CONT ::: LU is not report separately');
			hr_utility.trace('2007 EMP_CONT ::: checking if LE exists');

			start_index_main 		:= NVL (PAY_NO_EMP_CONT_2007.g_tab_main.FIRST, 0) ;
			end_index_main   		:= NVL (PAY_NO_EMP_CONT_2007.g_tab_main.LAST, 0) ;
			l_le_exists 			:= FALSE;

			-- loop through existing records for LE and -9999 to check if the current LE exists
			WHILE (PAY_NO_EMP_CONT_2007.g_tab_main.EXISTS(start_index_main)) and (start_index_main <= end_index_main) LOOP

				IF (PAY_NO_EMP_CONT_2007.g_tab_main(start_index_main).legal_employer_id = p_tax_unit_id) AND
				   (PAY_NO_EMP_CONT_2007.g_tab_main(start_index_main).local_unit_id = -9999) AND
				   (PAY_NO_EMP_CONT_2007.g_tab_main(start_index_main).zone = l_curr_zone)

					THEN
						l_le_exists := TRUE;
						l_le_index  := start_index_main;

						hr_utility.trace('2007 EMP_CONT ::: LE exists');
						hr_utility.trace('2007 EMP_CONT ::: l_le_index = '||l_le_index);

						EXIT;
				END IF;
				start_index_main := start_index_main + 1;
			END LOOP; -- end while loop


			-- if the LE and -9999 exists, return the values
			IF l_le_exists

				THEN -------------------------------------------------------------------------------------------------------------------------
					p_run_base			:= 	PAY_NO_EMP_CONT_2007.g_tab_main(l_le_index).run_base;
					p_run_contribution		:= 	PAY_NO_EMP_CONT_2007.g_tab_main(l_le_index).run_contribution;
					p_curr_exemption_limit_used	:= 	0;  -- coz this value must have been returned before

					hr_utility.trace('2007 EMP_CONT ::: LE #### LE already exists, so just returning vales' );
					hr_utility.trace('2007 EMP_CONT ::: LE #### l_le_index  = '|| l_le_index );
					hr_utility.trace('2007 EMP_CONT ::: LE #### p_run_base  = '|| p_run_base );
					hr_utility.trace('2007 EMP_CONT ::: LE #### p_run_contribution = '|| p_run_contribution );
					hr_utility.trace('2007 EMP_CONT ::: LE #### p_curr_exemption_limit_used = '|| p_curr_exemption_limit_used );

					hr_utility.trace('2007 EMP_CONT ::: LE #### Leaving procedure-----------------------------------');


					RETURN 1; -- here return le_run and the other values thru OUT parameters

				ELSE --------------------------------------------------------------------------------------------------------------------------
					-- combination does not exist, calculation has to be done and values returned

					---------- initializing the g_tab_calc table for LE and -9999 combination
					hr_utility.trace('2007 EMP_CONT ::: LE #### initializing the g_tab_calc , entering');

					OPEN PAY_NO_EMP_CONT_2007.get_le_status(p_tax_unit_id);
				        FETCH PAY_NO_EMP_CONT_2007.get_le_status INTO l_le_status;
					CLOSE PAY_NO_EMP_CONT_2007.get_le_status;

					hr_utility.trace('2007 EMP_CONT ::: LE ####  l_le_status = '|| l_le_status );

		 			-- loop for each zone

					g_tab_calc(1).zone := '1'  ;
					g_tab_calc(2).zone := '1a' ;
					g_tab_calc(3).zone := '2'  ;
					g_tab_calc(4).zone := '3'  ;
					g_tab_calc(5).zone := '4'  ;
					g_tab_calc(6).zone := '4a' ;
					g_tab_calc(7).zone := '5'  ;


					FOR i IN 1..7 LOOP

					    g_tab_calc(i).under_limit 	:= 'Y';
					    g_tab_calc(i).status 	:= l_le_status;

						-- initializing all balance values to zero
						g_tab_calc(i).bimonth_base 		  := 0 ;
						g_tab_calc(i).run_base 			  := 0 ;
						g_tab_calc(i).bimonth_contribution        := 0 ;
						g_tab_calc(i).bimonth_contribution_todate := 0 ;
						g_tab_calc(i).run_contribution 		  := 0 ;

					END LOOP; -- end i loop

					hr_utility.trace('2007 EMP_CONT ::: -- calling display_table_calc function  ');
					l_check := display_table_calc(g_tab_calc);
					hr_utility.trace('2007 EMP_CONT ::: -- returned from display_table_calc function  ');

					hr_utility.trace('2007 EMP_CONT ::: LE #### finished initializing the g_tab_calc , leaving ');
					---------------- finished initializing the g_tab_lu table

					---------------- get exemption limit used	for LE
					hr_utility.trace('2007 EMP_CONT ::: LE #### get exemption limit used	for LE , entering');

					-- set the context values for balance

					pay_balance_pkg.set_context('LOCAL_UNIT_ID',p_local_unit_id);

					-- get defined balance ids
					l_def_bal_id_1 := get_defined_balance_id('Employer Contribution Exemption Limit Used','_TU_LU_YTD') ;
					l_def_bal_id_2 := get_defined_balance_id('Employer Contribution Exemption Limit Used','_TU_LU_BIMONTH') ;

					hr_utility.trace('2007 EMP_CONT ::: LE #### l_def_bal_id_1 = '|| l_def_bal_id_1 );
					hr_utility.trace('2007 EMP_CONT ::: LE #### l_def_bal_id_2 = '|| l_def_bal_id_2 );

					-- get the balance value
					l_bal_val_ytd := pay_balance_pkg.get_value(l_def_bal_id_1,p_asg_act_id,p_tax_unit_id,p_jurisdiction_code,NULL,NULL,NULL,l_bimonth_end_date);
					l_bal_val_bimonth := pay_balance_pkg.get_value(l_def_bal_id_2,p_asg_act_id,p_tax_unit_id,p_jurisdiction_code,NULL,NULL,NULL,l_bimonth_end_date);

					--l_bal_val_ytd := 0 ;
					--l_bal_val_bimonth := 0 ;

					l_exemption_limit_used_yet := l_bal_val_ytd - l_bal_val_bimonth ;

					hr_utility.trace('2007 EMP_CONT ::: LE ####  l_bal_val_ytd = '|| l_bal_val_ytd );
					hr_utility.trace('2007 EMP_CONT ::: LE ####  l_bal_val_bimonth = '|| l_bal_val_bimonth );
					hr_utility.trace('2007 EMP_CONT ::: LE ####  l_exemption_limit_used_yet = '|| l_exemption_limit_used_yet );

					OPEN PAY_NO_EMP_CONT_2007.csr_get_exemption_limit(p_tax_unit_id ,p_date_earned );

					-- 2007 Legislative changes for 'Economic Aid' to Employer
					-- FETCH PAY_NO_EMP_CONT_2007.csr_get_exemption_limit INTO l_exemption_limit ;
					FETCH PAY_NO_EMP_CONT_2007.csr_get_exemption_limit INTO l_exemption_limit , l_economic_aid ;

					CLOSE PAY_NO_EMP_CONT_2007.csr_get_exemption_limit;

					hr_utility.trace('2007 EMP_CONT ::: LE ####  l_exemption_limit = ' || l_exemption_limit );
					hr_utility.trace('2007 EMP_CONT ::: LE ####  l_economic_aid = ' || l_economic_aid );

					-- 2007 Legislative changes for 'Economic Aid' to Employer
					l_exemption_limit := l_exemption_limit - l_economic_aid ;

					hr_utility.trace('2007 EMP_CONT ::: LE ####  l_exemption_limit after reducing eco aid = ' || l_exemption_limit );

					IF l_exemption_limit_used_yet >= l_exemption_limit
						THEN
							l_LE_over_limit := 'Y';
						ELSE
							l_LE_over_limit := 'N';
					END IF ; -- end if exemption limit check

					hr_utility.trace('2007 EMP_CONT ::: LE ####  l_exemption_limit = '|| l_exemption_limit );
					hr_utility.trace('2007 EMP_CONT ::: LE ####  l_LE_over_limit = '|| l_LE_over_limit  );
					hr_utility.trace('2007 EMP_CONT ::: LE #### got exemption limit used for LE , leaving ');
					------------------- got exemption limit used for LE

					------------------ populating the tables g_lu_tab (LU) and g_mu_tab (MU)
					hr_utility.trace('2007 EMP_CONT ::: LE ####  populating the tables g_lu_tab and g_mu_tab , entering');

					-- from 2007 , the tax municipality will be picked from the local unit

					l_temp := populate_tables
					  (p_tax_unit_id
					  ,p_payroll_id
					  ,p_date_earned
					  ,g_lu_tab
					  ,g_mu_tab  );

					hr_utility.trace('2007 EMP_CONT ::: LE ####  populating the tables g_lu_tab and g_mu_tab, leaving ');

					-------------------- Fetch the run base using assignment level balances (at LE level)
					hr_utility.trace('2007 EMP_CONT ::: LE ####  Fetch the run base using assignment level balances , entering');

					-- get defined balance ids
					l_def_bal_id_1 := get_defined_balance_id('Employer Contribution Base','_ASG_TU_MU_LU_BIMONTH') ;
					l_def_bal_id_2 := get_defined_balance_id('Employer Contribution Base 2','_ASG_TU_MU_LU_BIMONTH') ;

					hr_utility.trace('2007 EMP_CONT ::: LE #### l_def_bal_id_1 = '|| l_def_bal_id_1 );
					hr_utility.trace('2007 EMP_CONT ::: LE #### l_def_bal_id_2 = '|| l_def_bal_id_2 );

					----- test only , Remove it
					OPEN   csr_test_aag_act_id (p_tax_unit_id , p_payroll_action_id, p_date_earned);
					FETCH  csr_test_aag_act_id INTO l_check2;
					CLOSE  csr_test_aag_act_id;
					hr_utility.trace('2007 EMP_CONT ::: LE #### l_check2 , no of rows returned by asg act id cursor  = '||l_check2  );
					-- remove till here

					hr_utility.trace('2007 EMP_CONT ::: LE #### level 0 leave' );

					-- change 2b -1
					pay_balance_pkg.set_context('TAX_UNIT_ID',p_tax_unit_id);
					----

					-- loop to get all assignment_action_id in the current payroll_action_id
					FOR csr1_rec IN csr_curr_le_asg_act_id (p_tax_unit_id , p_payroll_action_id, p_date_earned) LOOP

						hr_utility.trace('2007 EMP_CONT ::: LE #### level 1 , loop csr_curr_le_asg_act_id ' );

						start_index_lu := NVL (g_lu_tab.FIRST, 0) ;
						end_index_lu   := NVL (g_lu_tab.LAST, 0) ;

						WHILE (g_lu_tab.EXISTS(start_index_lu)) and (start_index_lu <= end_index_lu) LOOP

							hr_utility.trace('2007 EMP_CONT ::: LE #### level 2, g_lu_tab ' );

							start_index_mu := NVL (g_mu_tab.FIRST, 0) ;
							end_index_mu   := NVL (g_mu_tab.LAST, 0) ;

							-- Change 2b - 2
							pay_balance_pkg.set_context('LOCAL_UNIT_ID',g_lu_tab(start_index_lu));
							-----

							WHILE (g_mu_tab.EXISTS(start_index_mu)) and (start_index_mu <= end_index_mu) LOOP

								hr_utility.trace('2007 EMP_CONT ::: LE #### level 3, g_mu_tab ' );
								hr_utility.trace('2007 EMP_CONT ::: LE #### ASS_ACT_ID = '|| csr1_rec.ASSIGNMENT_ACTION_ID || ' MU = '|| g_mu_tab(start_index_mu)|| ' LU = '|| g_lu_tab(start_index_lu) );

								--setting the context values
								pay_balance_pkg.set_context('JURISDICTION_CODE',g_mu_tab(start_index_mu));

								-- get the balance value
								l_asg_ers_base := pay_balance_pkg.get_value(l_def_bal_id_1,csr1_rec.ASSIGNMENT_ACTION_ID);
								l_asg_ers_base2 := pay_balance_pkg.get_value(l_def_bal_id_2,csr1_rec.ASSIGNMENT_ACTION_ID);
								l_asg_ers_base_diff :=	l_asg_ers_base - l_asg_ers_base2;

								hr_utility.trace('2007 EMP_CONT ::: LE ####  l_asg_ers_base = '|| l_asg_ers_base );
								hr_utility.trace('2007 EMP_CONT ::: LE ####  l_asg_ers_base2 = '|| l_asg_ers_base2 );
								hr_utility.trace('2007 EMP_CONT ::: LE ####  l_asg_ers_base_diff = '|| l_asg_ers_base_diff );

								hr_utility.trace('2007 EMP_CONT ::: LE #### ============== just checking================= ');

								hr_utility.trace('2007 EMP_CONT ::: LE #### g_mu_tab(start_index_mu) = '|| g_mu_tab(start_index_mu) );

								l_zone_temp := to_char(g_mu_tab(start_index_mu));

								hr_utility.trace('2007 EMP_CONT ::: LE #### l_zone_temp  = '|| l_zone_temp );

								-- l_zone := to_number(substr(get_lookup_meaning('NO_TAX_MUNICIPALITY',l_zone_temp),1,1));
								l_zone := hruserdt.get_table_value (p_bus_group_id, 'NO_TAX_MUNICIPALITY' , 'ZONE', l_zone_temp, p_date_earned ) ;

								hr_utility.trace('2007 EMP_CONT ::: LE #### l_zone  = '|| l_zone );

								l_cell := lookup_cell(g_tab_calc,l_zone);
								g_tab_calc(l_cell).run_base  := g_tab_calc(l_cell).run_base + l_asg_ers_base_diff ;

								hr_utility.trace('2007 EMP_CONT ::: LE #### l_cell = '|| l_cell );

								start_index_mu := start_index_mu + 1;
							END LOOP; -- end while loop g_mu_tab

							start_index_lu := start_index_lu + 1;
						END LOOP; -- end while loop g_lu_tab

					END LOOP;	-- end loop csr1_rec

					hr_utility.trace('2007 EMP_CONT ::: LE #### level 0 back' );

					hr_utility.trace('2007 EMP_CONT ::: -- calling display_table_calc function  ');
					l_check := display_table_calc(g_tab_calc);
					hr_utility.trace('2007 EMP_CONT ::: -- returned from display_table_calc function  ');

					hr_utility.trace('2007 EMP_CONT ::: LE ####  Fetched the run base using assignment level balances , leaving');
					-------------------- Fetched the run base using assignment level balances (at LE level)

					-------------------- Fetch the bimonth base using group level balances (at LE level)
					hr_utility.trace('2007 EMP_CONT ::: LE ####  Fetch the bimonth base using group level balances , entering');

					-- get defined balance ids
					l_def_bal_id_1 := get_defined_balance_id('Employer Contribution Base','_TU_MU_LU_BIMONTH') ;
					l_def_bal_id_2 := get_defined_balance_id('Employer Contribution','_TU_MU_LU_BIMONTH') ;

					hr_utility.trace('2007 EMP_CONT ::: LE #### l_def_bal_id_1 = '|| l_def_bal_id_1 );
					hr_utility.trace('2007 EMP_CONT ::: LE #### l_def_bal_id_2 = '|| l_def_bal_id_2 );

					-- loop to get all LU in g_lu_tab

					start_index_lu := NVL (g_lu_tab.FIRST, 0) ;
					end_index_lu   := NVL (g_lu_tab.LAST, 0) ;

					hr_utility.trace('2007 EMP_CONT ::: LE ####   level 0 leave ' );

					-- change 3b -1
					--pay_balance_pkg.set_context('TAX_UNIT_ID',p_tax_unit_id);
					----

					WHILE (g_lu_tab.EXISTS(start_index_lu)) and (start_index_lu <= end_index_lu) LOOP

						hr_utility.trace('2007 EMP_CONT ::: LE ####   level 1 ,g_lu_tab  '  );

						-- loop to get all MU in g_mu_tab
						start_index_mu := NVL (g_mu_tab.FIRST, 0) ;
						end_index_mu   := NVL (g_mu_tab.LAST, 0) ;

						-- change 3b -2
						pay_balance_pkg.set_context('LOCAL_UNIT_ID',g_lu_tab(start_index_lu));
						----

						WHILE (g_mu_tab.EXISTS(start_index_mu)) and (start_index_mu <= end_index_mu) LOOP

							hr_utility.trace('2007 EMP_CONT ::: LE ####   level 2 ,g_mu_tab  '  );

							hr_utility.trace('2007 EMP_CONT ::: LE ####  MU = '|| g_mu_tab(start_index_mu)|| ' LU = '|| g_lu_tab(start_index_lu) );

							--setting the context values
							--pay_balance_pkg.set_context('TAX_UNIT_ID',p_tax_unit_id);
							pay_balance_pkg.set_context('JURISDICTION_CODE',g_mu_tab(start_index_mu));
							--pay_balance_pkg.set_context('LOCAL_UNIT_ID',g_lu_tab(start_index_lu));

							-- get the balance value
							l_le_ers_base := pay_balance_pkg.get_value(l_def_bal_id_1,p_asg_act_id,p_tax_unit_id,g_mu_tab(start_index_mu),NULL,NULL,NULL,l_bimonth_end_date);
							l_le_ers := pay_balance_pkg.get_value(l_def_bal_id_2,p_asg_act_id,p_tax_unit_id,g_mu_tab(start_index_mu),NULL,NULL,NULL,l_bimonth_end_date);

							hr_utility.trace('2007 EMP_CONT ::: LE ####  l_le_ers_base = '||  l_le_ers_base);
							hr_utility.trace('2007 EMP_CONT ::: LE ####  l_le_ers = '||l_le_ers );

							hr_utility.trace('2007 EMP_CONT ::: LE #### ============== just checking again ================= ');

							hr_utility.trace('2007 EMP_CONT ::: LE #### g_mu_tab(start_index_mu) = '|| g_mu_tab(start_index_mu) );

							l_zone_temp := to_char(g_mu_tab(start_index_mu));

							hr_utility.trace('2007 EMP_CONT ::: LE #### l_zone_temp  = '|| l_zone_temp );

							-- l_zone := to_number(substr(get_lookup_meaning('NO_TAX_MUNICIPALITY',l_zone_temp),1,1));
							l_zone	:= hruserdt.get_table_value (p_bus_group_id, 'NO_TAX_MUNICIPALITY' , 'ZONE', l_zone_temp, p_date_earned ) ;

							hr_utility.trace('2007 EMP_CONT ::: LE ####  l_zone  = '|| l_zone );

							l_cell := lookup_cell(g_tab_calc,l_zone);
							g_tab_calc(l_cell).bimonth_base  := g_tab_calc(l_cell).bimonth_base + l_le_ers_base ;
							g_tab_calc(l_cell).bimonth_contribution_todate  := g_tab_calc(l_cell).bimonth_contribution_todate + l_le_ers ;

							hr_utility.trace('2007 EMP_CONT ::: LE ####  l_cell = '|| l_cell );

							start_index_mu := start_index_mu + 1;
						END LOOP; -- end while loop g_mu_tab

						start_index_lu := start_index_lu + 1;
					END LOOP; -- end while loop g_lu_tab

					hr_utility.trace('2007 EMP_CONT ::: LE ####   level 0 back' );

					hr_utility.trace('2007 EMP_CONT ::: -- calling display_table_calc function  ');
					l_check := display_table_calc(g_tab_calc);
					hr_utility.trace('2007 EMP_CONT ::: -- returned from display_table_calc function  ');

					hr_utility.trace('2007 EMP_CONT ::: LE ####  Fetch the bimonth base using group level balances , leaving ');
					-------------------- Fetched the bimonth base using group level balances (at LE level)

					------------------------------ apply differential rate and check exemption limit at LE Level
					hr_utility.trace('2007 EMP_CONT ::: LE ####  apply differential rate and check exemption limit , entering ');

					--l_lu_status   --status for LU
					--l_le_status   --status for LE
					l_total_saving := 0;

					-- check if exemption limit already used up
					IF l_LE_over_limit = 'Y'

						THEN
							hr_utility.trace('2007 EMP_CONT ::: LE #### l_LE_over_limit = Y  '  );

							-- as limit is over, put under_limit as N for all rows
							FOR i IN 1..7 LOOP
							    g_tab_calc(i).under_limit 	:= 'N';
							END LOOP; -- end i loop

							hr_utility.trace('2007 EMP_CONT ::: LE #### as limit is over, put under_limit as N for all rows ');

						ELSE
							hr_utility.trace('2007 EMP_CONT ::: LE #### l_LE_over_limit = N  '  );

							-- limit is not over
							-- perform exemption limit check only if status = AA,CC,GG
							IF ( l_le_status = 'AA' OR l_le_status = 'GG' OR l_le_status = 'CC' )

								THEN
									hr_utility.trace('2007 EMP_CONT ::: LE #### status is = '|| l_le_status  );

									-------- performing exemption limit check
									l_table_name := 'NO_NIS_ZONE_RATES';

									-- loop for each zone
									FOR i IN 2..7 LOOP

										-- l_col_name := 'Under Age Percentage';
										-- BUG Fix : 5999230
										-- Renaming user column of user table NO_NIS_ZONE_RATES from 'Under Age Percentage' to 'NIS Rates'

										l_col_name := 'NIS Rates';
										l_high_rate :=  p_under_age_high_rate;

										hr_utility.trace('2007 EMP_CONT ::: LE ####   exemption limit check ----------------------'  );

										l_zone_value  := to_char(g_tab_calc(i).zone);
										-- l_normal_rate := TO_NUMBER(hruserdt.get_table_value (p_bus_group_id, l_table_name, l_col_name, l_zone_value, p_date_earned ));
										l_normal_rate := fnd_number.canonical_to_number(hruserdt.get_table_value (p_bus_group_id, l_table_name, l_col_name, l_zone_value, p_date_earned ));
										l_diff_rate   := l_high_rate - l_normal_rate ;

										l_saving := ( g_tab_calc(i).bimonth_base * l_diff_rate ) / 100 ;
										l_total_saving := l_total_saving + l_saving ;

										hr_utility.trace('2007 EMP_CONT ::: LE ####  i = '||i||' l_zone_value = '||l_zone_value
									                      ||' l_normal_rate = '||l_normal_rate||' l_high_rate = '||l_high_rate
														  ||' l_diff_rate = '||l_diff_rate||' l_saving = '||l_saving||' l_total_saving = '||l_total_saving );

										-- check if exemption limit exceeded
										IF ((l_exemption_limit_used_yet + l_total_saving) >= l_exemption_limit)
											THEN
												hr_utility.trace('2007 EMP_CONT ::: LE ####  exemption limit exceeded in table');
												hr_utility.trace('2007 EMP_CONT ::: LE ####  bimonth_base  = '|| g_tab_calc(i).bimonth_base );
												hr_utility.trace('2007 EMP_CONT ::: LE ####  run_base  = '||g_tab_calc(i).run_base  );
												hr_utility.trace('2007 EMP_CONT ::: LE ####  l_zone_value = '|| l_zone_value );
												hr_utility.trace('2007 EMP_CONT ::: LE ####  l_normal_rate = '|| l_normal_rate );
												hr_utility.trace('2007 EMP_CONT ::: LE ####  l_high_rate = '|| l_high_rate );
												hr_utility.trace('2007 EMP_CONT ::: LE ####  l_diff_rate = '|| l_diff_rate );
												hr_utility.trace('2007 EMP_CONT ::: LE ####  l_saving = '|| l_saving );
												hr_utility.trace('2007 EMP_CONT ::: LE ####  l_total_saving= '|| l_total_saving );
												hr_utility.trace('2007 EMP_CONT ::: LE ####  l_exemption_limit_used_yet = '|| l_exemption_limit_used_yet  );

												-- get the exceeding amount
												l_amount_over_limit := ((l_exemption_limit_used_yet + l_total_saving) - l_exemption_limit);
												l_base_over_limit := ( l_amount_over_limit / l_diff_rate ) * 100 ;
												--g_tab_calc(i).bimonth_base := g_tab_calc(i).bimonth_base - l_base_over_limit;

												-----------
												l_total_bimonth_base := g_tab_calc(i).bimonth_base ;
												l_old_bimonth_base := l_total_bimonth_base - l_base_over_limit ;
												l_new_bimonth_base := l_base_over_limit ;

												l_old_run_base := (l_old_bimonth_base / l_total_bimonth_base ) * g_tab_calc(i).run_base ;
												l_new_run_base := (l_new_bimonth_base / l_total_bimonth_base ) * g_tab_calc(i).run_base ;

												l_old_bmth_cont_todate := ( l_old_bimonth_base / l_total_bimonth_base ) *  g_tab_calc(i).bimonth_contribution_todate ;
												l_new_bmth_cont_todate := ( l_new_bimonth_base / l_total_bimonth_base ) *  g_tab_calc(i).bimonth_contribution_todate ;


												g_tab_calc(i).bimonth_base 			:= l_old_bimonth_base ;
												g_tab_calc(i).run_base 				:= l_old_run_base ;
												g_tab_calc(i).bimonth_contribution_todate 	:= l_old_bmth_cont_todate ;

												------------

												-- to set the actual total saving coz here the total saving might cross the exemption limit provided
												-- set the new l_total_saving

												l_total_saving := l_exemption_limit - l_exemption_limit_used_yet ;

												hr_utility.trace('2007 EMP_CONT ::: LE #### l_amount_over_limit  = '|| l_amount_over_limit );
												hr_utility.trace('2007 EMP_CONT ::: LE #### l_base_over_limit  = '|| l_base_over_limit );
												hr_utility.trace('2007 EMP_CONT ::: LE #### NEW bimonth base for current row  = '|| g_tab_calc(i).bimonth_base );
												hr_utility.trace('2007 EMP_CONT ::: LE #### NEW l_total_saving  = '|| l_total_saving );

												-- insert a new row for exceeded limit

												g_tab_calc(8).zone 				:= g_tab_calc(i).zone;
												g_tab_calc(8).under_limit 			:= 'N';
												g_tab_calc(8).status 				:= g_tab_calc(i).status;
												g_tab_calc(8).bimonth_base 			:= l_new_bimonth_base ;
												g_tab_calc(8).run_base 				:= l_new_run_base ;
												g_tab_calc(8).bimonth_contribution 		:= g_tab_calc(i).bimonth_contribution ;
												g_tab_calc(8).bimonth_contribution_todate 	:= l_new_bmth_cont_todate ;
												g_tab_calc(8).run_contribution 			:= g_tab_calc(i).run_contribution ;

												-- finished inserting new row

												-- set remaining rows under_limit = N
												FOR j IN i+1..7 LOOP
													g_tab_calc(j).under_limit := 'N';
												END LOOP; --end j loop

												l_LE_over_limit := 'Y'; -- indicating exemption limit on LE level is over

												--hr_utility.trace('2007 EMP_CONT ::: LE #### l_LE_over_limit Y' );
												hr_utility.trace('2007 EMP_CONT ::: LE #### l_LE_over_limit = '||l_LE_over_limit );

												EXIT; -- exit loop i since no more check is required
										END IF; -- end check if exemption limit exceeded

										-- for AA and GG, only exemption limit check required for zone 1a, exit after that
										IF ( l_le_status = 'AA' OR l_le_status = 'GG')
										  THEN EXIT ;
										END IF;

									END LOOP; -- end i loop

									-------- performed exemption limit check

							END IF; -- end if status = AA,CC,GG

					END IF; -- end if l_LE_over_limit = Y

					l_exemption_limit_used := l_total_saving - l_bal_val_bimonth ;

					hr_utility.trace('2007 EMP_CONT ::: LE #### l_total_saving  = '||l_total_saving  );
					hr_utility.trace('2007 EMP_CONT ::: LE #### l_bal_val_bimonth  = '||l_bal_val_bimonth  );
					hr_utility.trace('2007 EMP_CONT ::: LE #### l_exemption_limit_used  = '||l_exemption_limit_used  );

					hr_utility.trace('2007 EMP_CONT ::: -- calling display_table_calc function  ');
					l_check := display_table_calc(g_tab_calc);
					hr_utility.trace('2007 EMP_CONT ::: -- returned from display_table_calc function  ');

					hr_utility.trace('2007 EMP_CONT ::: LE ####  apply differential rate and check exemption limit , leaving ');
					------------------------------ applied differential rate and check exemption limit	at LE Level

					-- ec_main_calculation function call for LE
					hr_utility.trace('2007 EMP_CONT ::: LE ####  ec_main_calculation function call for LE , entering '  );

					l_main_index := ec_main_calculation (    g_tab_calc
										,PAY_NO_EMP_CONT_2007.g_tab_main
										,p_tax_unit_id
										,-9999
										,l_exemption_limit_used
										,l_le_status
										,p_bus_group_id
										,p_date_earned
										,p_under_age_high_rate
										,p_over_age_high_rate
										,l_curr_zone	) ;



					hr_utility.trace('2007 EMP_CONT ::: -- calling display_table_calc function  ');
					l_check := display_table_calc(g_tab_calc);
					hr_utility.trace('2007 EMP_CONT ::: -- returned from display_table_calc function  ');

					hr_utility.trace('2007 EMP_CONT ::: LE ####  ec_main_calculation function call for LE , leaving '  );

					-- done all caclculation and entered values in the main table for next time usage

					-- returning values at LE level
					p_run_base			:= 	PAY_NO_EMP_CONT_2007.g_tab_main(l_main_index).run_base;
					p_run_contribution		:= 	PAY_NO_EMP_CONT_2007.g_tab_main(l_main_index).run_contribution;
					p_curr_exemption_limit_used	:= 	PAY_NO_EMP_CONT_2007.g_tab_main(l_main_index).exemption_limit_used;

					hr_utility.trace('2007 EMP_CONT ::: LE #### l_main_index  = '|| l_main_index );
					hr_utility.trace('2007 EMP_CONT ::: LE #### p_run_base  = '|| p_run_base );
					hr_utility.trace('2007 EMP_CONT ::: LE #### p_run_contribution = '|| p_run_contribution );
					hr_utility.trace('2007 EMP_CONT ::: LE #### p_curr_exemption_limit_used = '|| p_curr_exemption_limit_used );

					hr_utility.trace('2007 EMP_CONT ::: LE #### Leaving procedure-----------------------------------');

					RETURN 1; -- here return 1 and the other values thru OUT parameters


			END IF; --	end if l_le_exists


	END IF; -- end if l_lu_rep_sep = 'Y'

	hr_utility.trace('2007 EMP_CONT :::  exiting main function');
	--hr_utility.trace_off();

    -----------------------------------Exception -----------------------------------------------------------
	--EXCEPTION

END GET_EMPLOYER_DEDUCTION;

-----------------------------------------------------------------------------------------------------------------------------------

-- Function to get defined balance id

FUNCTION get_defined_balance_id
  (p_balance_name   		IN  VARCHAR2
  ,p_dbi_suffix     		IN  VARCHAR2 ) RETURN NUMBER IS

  l_defined_balance_id 		NUMBER;

BEGIN

	SELECT pdb.defined_balance_id
	INTO   l_defined_balance_id
	FROM   pay_defined_balances      pdb
	      ,pay_balance_types         pbt
	      ,pay_balance_dimensions    pbd
	WHERE  pbd.database_item_suffix = p_dbi_suffix
	AND    pbd.legislation_code = 'NO'
	AND    pbt.balance_name = p_balance_name
	AND    pbt.legislation_code = 'NO'
	AND    pdb.balance_type_id = pbt.balance_type_id
	AND    pdb.balance_dimension_id = pbd.balance_dimension_id
	AND    pdb.legislation_code = 'NO';

	l_defined_balance_id := NVL(l_defined_balance_id,0);

RETURN l_defined_balance_id ;
END get_defined_balance_id ;

-----------------------------------------------------------------------------------------------------------------------------------

-- Function to populate LU (g_lu_tab) and MU (g_mu_tab) tables

FUNCTION populate_tables
  (p_tax_unit_id    IN  NUMBER
  ,p_payroll_id     IN  NUMBER
  ,p_date_earned    IN  DATE
  ,g_lu_tab    	    IN  OUT	NOCOPY PAY_NO_EMP_CONT_2007.g_lu_tabtype
  ,g_mu_tab  	    IN  OUT 	NOCOPY PAY_NO_EMP_CONT_2007.g_mu_tabtype ) RETURN NUMBER IS


/* cursor to get the element_type_id of element 'Tax Deduction Base' */

/*
CURSOR csr_element_type (p_date_earned  DATE ) IS
SELECT ELEMENT_TYPE_ID
FROM pay_element_types_f      pet
WHERE pet.element_name = 'Tax Deduction Base'
AND   pet.LEGISLATION_CODE = 'NO'
AND   p_date_earned BETWEEN pet.EFFECTIVE_START_DATE AND pet.EFFECTIVE_END_DATE ;
*/

-- changing element from Tax Deduction Base to Tax

CURSOR csr_element_type (p_date_earned  DATE ) IS
SELECT ELEMENT_TYPE_ID
FROM pay_element_types_f      pet
WHERE pet.element_name = 'Tax'
AND   pet.LEGISLATION_CODE = 'NO'
AND   p_date_earned BETWEEN pet.EFFECTIVE_START_DATE AND pet.EFFECTIVE_END_DATE ;


start_index_mu	NUMBER;
end_index_mu	NUMBER;
l_mu_exists	BOOLEAN;

k		NUMBER;
l_lu_status  	VARCHAR2(40) ;
l_lu_rep_sep    VARCHAR2(1) ;
l_lu_tax_mun	VARCHAR2(200) ;

start_index_lu	NUMBER;
end_index_lu	NUMBER;
l_lu_exists	BOOLEAN;

l_tax_ele_type_id   NUMBER;

BEGIN

OPEN csr_element_type (p_date_earned) ;
FETCH csr_element_type INTO l_tax_ele_type_id ;
CLOSE csr_element_type ;



------------- testing the 3 cursor loops

			-- loop to get all payroll_action_id in the bimonth period for the current payroll
			FOR csr1_rec IN PAY_NO_EMP_CONT_2007.csr_payroll_action_id (p_date_earned) LOOP

				-- loop to get assignment_id and assignment_action_id for all payroll_action_id obtained above for the current legal employer
    			FOR csr2_rec IN PAY_NO_EMP_CONT_2007.csr_assignment_id (p_tax_unit_id , csr1_rec.PAYROLL_ACTION_ID) LOOP

    				-- loop to get local unit and tax municipality for all assignment actions obtained above
				FOR csr3_rec IN PAY_NO_EMP_CONT_2007.csr_lu_mu (csr2_rec.ASSIGNMENT_ID , csr2_rec.ASSIGNMENT_ACTION_ID , p_date_earned , l_tax_ele_type_id ) LOOP

            			hr_utility.trace('2007 EMP_CONT ::: --------------------------------------------------------');

            			hr_utility.trace('2007 EMP_CONT :::  PAY_ACT_ID = '||csr1_rec.PAYROLL_ACTION_ID||' ASS_ID = '||csr2_rec.ASSIGNMENT_ID||' ASS_ACT_ID = '||csr2_rec.ASSIGNMENT_ACTION_ID
                        			     ||' Local Unit = '||csr3_rec.local_unit_id||' Tax Mul = '||csr3_rec.tax_mun_id);

						----------------------------- check for MU -------------------------------------------
						start_index_mu := NVL (g_mu_tab.FIRST, 0) ;
						end_index_mu   := NVL (g_mu_tab.LAST, 0) ;
						l_mu_exists    := FALSE;

						-- loop through existing records for local unit and tax municipality to check if the current combination exists
						WHILE (g_mu_tab.EXISTS(start_index_mu)) and (start_index_mu <= end_index_mu) LOOP
							IF (g_mu_tab(start_index_mu) = csr3_rec.tax_mun_id)
								THEN
									l_mu_exists := TRUE;
									EXIT;
							END IF;
							start_index_mu := start_index_mu + 1;
						END LOOP; -- end while loop

						-- if the current combination doe not exists , add the combination to the pl/sql table
						IF NOT l_mu_exists
							THEN
								k := NVL (g_mu_tab.LAST, 0) + 1 ;
								g_mu_tab(k) := csr3_rec.tax_mun_id ;
						END IF;
						-------------------------------------------------------------------------------------------------

						----------------------------- check for unique LU -------------------------------------------

						-- Get the Status and Report Separately for this particular Local Unit
						OPEN PAY_NO_EMP_CONT_2007.get_lu_details(csr3_rec.local_unit_id);
						FETCH PAY_NO_EMP_CONT_2007.get_lu_details INTO l_lu_status , l_lu_rep_sep , l_lu_tax_mun ;
						CLOSE PAY_NO_EMP_CONT_2007.get_lu_details;

						IF trim(l_lu_rep_sep) = 'N'
							THEN

								start_index_lu 		:= NVL (g_lu_tab.FIRST, 0) ;
								end_index_lu   		:= NVL (g_lu_tab.LAST, 0) ;
								l_lu_exists    		:= FALSE;

								-- loop through existing records for local unit to check if the current Local Unit exists
								WHILE (g_lu_tab.EXISTS(start_index_lu)) and (start_index_lu <= end_index_lu) LOOP
									IF (g_lu_tab(start_index_lu) = csr3_rec.local_unit_id)
										THEN
											l_lu_exists := TRUE;
											EXIT;
									END IF;
									start_index_lu := start_index_lu + 1;
								END LOOP; -- end while loop


								-- if the current Local Unit doe not exists , add the Local Unit to the pl/sql table
								IF NOT l_lu_exists
									THEN
										k := NVL (g_lu_tab.LAST, 0) + 1 ;
										g_lu_tab(k) := csr3_rec.local_unit_id ;
								END IF; -- end IF for inserting Local Unit in l_unique_lu_tab table

						END IF; -- end IF for checking is report separatly is Y
						-------------------------------------------------------------------------------------------------


		        	END LOOP;  -- end loop csr3_rec

    			END LOOP;	-- end loop csr2_rec

			END LOOP;	-- end loop csr1_rec

------------- end testing the 3 cursor loops


			---- sub test 1
			start_index_mu := NVL (g_mu_tab.FIRST, 0) ;
			end_index_mu   := NVL (g_mu_tab.LAST, 0) ;

			WHILE (g_mu_tab.EXISTS(start_index_mu)) and (start_index_mu <= end_index_mu) LOOP
				hr_utility.trace('2007 EMP_CONT ::: *****************************************************************************');
				hr_utility.trace('2007 EMP_CONT :::  Tax Mul = '|| g_mu_tab(start_index_mu));

				start_index_mu := start_index_mu + 1;
			END LOOP; -- end while loop
			hr_utility.trace('2007 EMP_CONT ::: *****************************************************************************');

			-- end sub test 1
			-------------------------------------------------------------------------------------------------



			---- sub test 2
			start_index_lu 		:= NVL (g_lu_tab.FIRST, 0) ;
			end_index_lu   		:= NVL (g_lu_tab.LAST, 0) ;


			WHILE (g_lu_tab.EXISTS(start_index_lu)) and (start_index_lu <= end_index_lu) LOOP
				hr_utility.trace('2007 EMP_CONT ::: \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\');
				hr_utility.trace('2007 EMP_CONT :::  Local Unit = '|| g_lu_tab(start_index_lu));

				start_index_lu := start_index_lu + 1;
			END LOOP; -- end while loop
			hr_utility.trace('2007 EMP_CONT ::: \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\');

			-- end sub test 2

------------------------------
RETURN 1;

END populate_tables ;


-----------------------------------------------------------------------------------------------------------------------------------

-- function to get the lookup meaning

  FUNCTION get_lookup_meaning (p_lookup_type IN varchar2,p_lookup_code IN varchar2) RETURN VARCHAR2 IS

    CURSOR csr_lookup IS
    select meaning
    from   hr_lookups
    where  lookup_type  = p_lookup_type
    and    lookup_code  = p_lookup_code
    and    enabled_flag = 'Y';

    l_meaning hr_lookups.meaning%type;

  BEGIN

    OPEN csr_lookup;
    FETCH csr_lookup INTO l_Meaning;
    CLOSE csr_lookup;

    RETURN l_meaning;
  END get_lookup_meaning;

-----------------------------------------------------------------------------------------------------------------------------------

-- Function to look up the corresponding cell number in he table g_tab_calc

FUNCTION lookup_cell
  (g_tab_calc  IN  PAY_NO_EMP_CONT_2007.g_tab_calc_tabtype
  ,l_zone      IN  VARCHAR2 ) RETURN NUMBER IS

  l_cell	NUMBER;

BEGIN
	l_cell := 0;

	FOR i IN 1..7 LOOP

		IF (g_tab_calc(i).zone = l_zone ) THEN  l_cell := i;  EXIT;  END IF;

	END LOOP; -- end i loop

RETURN l_cell ;

END lookup_cell ;

-----------------------------------------------------------------------------------------------------------------------------------
-- NEW function for main calculation

FUNCTION ec_main_calculation

  (g_tab_calc  			IN  OUT NOCOPY 	PAY_NO_EMP_CONT_2007.g_tab_calc_tabtype
  ,g_tab_main  			IN  OUT NOCOPY  PAY_NO_EMP_CONT_2007.g_tab_main_tabtype
  ,p_tax_unit_id    		IN  NUMBER
  ,p_local_unit_id 		IN  NUMBER
  ,p_exemption_limit_used 	IN  NUMBER
  ,p_org_status 		IN  VARCHAR2
  ,p_bus_group_id      		IN  NUMBER
  ,p_date_earned    		IN  DATE
  ,p_under_age_high_rate	IN  NUMBER
  ,p_over_age_high_rate		IN  NUMBER
  ,l_curr_zone			IN  VARCHAR2
  ) RETURN NUMBER IS


l_main_index  		NUMBER;
start_main_index  	NUMBER;
end_main_index  	NUMBER;
l_curr_index  		NUMBER;

start_index_calc	NUMBER;
end_index_calc		NUMBER;

l_rate			NUMBER;
i			NUMBER;
x			NUMBER;
l_run_base		NUMBER;
l_unallocated_cont	NUMBER;
l_extra_run_cont	NUMBER;

BEGIN

	-- get the next location for the main table record
	start_main_index := NVL (g_tab_main.LAST, 0) + 1 ;
	end_main_index	 := start_main_index + 6 ;
	x := 1;

	hr_utility.trace('2007 EMP_CONT ::: Initializing Main Table --------');

	-- initialize 7 rows of the main table g_tab_main
	------------------------------------------------------------------------------------------------------

	g_tab_main(start_main_index + 0).zone := '1'  ;
	g_tab_main(start_main_index + 1).zone := '1a' ;
	g_tab_main(start_main_index + 2).zone := '2'  ;
	g_tab_main(start_main_index + 3).zone := '3'  ;
	g_tab_main(start_main_index + 4).zone := '4'  ;
	g_tab_main(start_main_index + 5).zone := '4a' ;
	g_tab_main(start_main_index + 6).zone := '5'  ;

	FOR j IN start_main_index..end_main_index	LOOP

		-- populate the fixed values
		g_tab_main(j).legal_employer_id 		:= p_tax_unit_id ;
		g_tab_main(j).local_unit_id 			:= p_local_unit_id ;
		g_tab_main(j).exemption_limit_used 		:= p_exemption_limit_used ;

		-- initializing other values
		g_tab_main(j).run_base 		:= 0 ;
		g_tab_main(j).run_contribution 	:= 0 ;


		x := x+1;

		-- finding the l_main_index
		IF (g_tab_main(j).zone = l_curr_zone) THEN  l_main_index := j;	END IF; -- end if finding the l_main_index


	END LOOP; -- end loop for initializing g_tab_main

	hr_utility.trace('2007 EMP_CONT ::: Finished Initializing Main Table --------');
	------------------------------------------------------------------------------------------------------

	l_run_base := 0;
	l_unallocated_cont := 0;

	start_index_calc := NVL (g_tab_calc.FIRST, 0) ;
	end_index_calc   := NVL (g_tab_calc.LAST, 0) ;

	hr_utility.trace('2007 EMP_CONT ::: Main Calc Entered--------'  );
	hr_utility.trace('2007 EMP_CONT ::: Main Calc  i -- p_org_status - zone -- under_limit -- l_rate = -- bimonth_base -- bimonth_cont -- bimonth_todate -- run_cont ' );

	FOR i IN start_index_calc..end_index_calc LOOP

 	    l_rate := PAY_NO_EMP_CONT_2007.get_ec_rate (g_tab_calc(i).zone
				  ,g_tab_calc(i).under_limit
				  ,p_org_status
				  ,p_bus_group_id
				  ,p_date_earned
				  ,p_under_age_high_rate
				  ,p_over_age_high_rate );

		-- calculating values for g_tab_calc
		g_tab_calc(i).bimonth_contribution 	:= ( g_tab_calc(i).bimonth_base  * l_rate ) / 100 ;
		g_tab_calc(i).run_contribution 		:= g_tab_calc(i).bimonth_contribution - g_tab_calc(i).bimonth_contribution_todate ;

		-- Rounding Downwards the run contribution to the nearest NOK
		--g_tab_calc(i).run_contribution 	:= trunc(g_tab_calc(i).run_contribution) ;

		-- collecting the run_base
		l_run_base := l_run_base + g_tab_calc(i).run_base ;

		-- collecting the run_contributions where run_base is zero (for re-allocating the run_contributions)
		IF (g_tab_calc(i).run_base = 0) and (g_tab_calc(i).run_contribution <> 0)
			THEN
				l_unallocated_cont := l_unallocated_cont + g_tab_calc(i).run_contribution ;
		END IF;

		hr_utility.trace('2007 EMP_CONT ::: Main Calc  '||i
                 ||' '||p_org_status
                 ||' '||g_tab_calc(i).zone
		 ||' '||g_tab_calc(i).under_limit
		 ||' '||l_rate
		 ||' '||g_tab_calc(i).bimonth_base
		 ||' '||g_tab_calc(i).bimonth_contribution
		 ||' '||g_tab_calc(i).bimonth_contribution_todate
		 ||' '||g_tab_calc(i).run_contribution );

	END LOOP;

	hr_utility.trace('2007 EMP_CONT ::: Main Calc --- exited from Main calc loop'  );
	hr_utility.trace('2007 EMP_CONT ::: Main Calc l_run_base = '|| l_run_base );
	hr_utility.trace('2007 EMP_CONT ::: Main Calc l_unallocated_cont = '|| l_unallocated_cont );

	-- re-allocating the run_contributions that can be allocated
	-- and also summing the values to get the final values

	hr_utility.trace('2007 EMP_CONT ::: Main Calc --- entered loop for re-allocation and summing up values'  );

	FOR i IN start_index_calc..end_index_calc LOOP

		-- to handle the error of division by zero

		IF ( l_run_base <> 0 )
		   THEN

			-- re-allocate unallocated contributions to rows where there is some run base
			l_extra_run_cont := l_unallocated_cont * (g_tab_calc(i).run_base / l_run_base) ;

			-- add the extra run_cont to existing run_cont
			g_tab_calc(i).run_contribution := g_tab_calc(i).run_contribution + l_extra_run_cont;

		ELSE
			l_extra_run_cont := 0 ;

		END IF;

		hr_utility.trace('2007 EMP_CONT ::: Main Calc  '||i
		||' '||g_tab_calc(i).run_base
		||' '||l_run_base
		 ||' '||l_unallocated_cont
		 ||' '||l_extra_run_cont
		 ||' '||g_tab_calc(i).run_contribution ) ;

		-- getting the value of l_curr_index of the g_tab_main where the present values should go

		-- l_curr_index := main_lookup_cell(g_tab_main , start_main_index , g_tab_calc(i).under_62 , g_tab_calc(i).zone );
		l_curr_index := main_lookup_cell(g_tab_main , start_main_index , g_tab_calc(i).zone );

		-- inserting values in g_tab_main
		g_tab_main(l_curr_index).run_base 		:= g_tab_main(l_curr_index).run_base + g_tab_calc(i).run_base ;
		g_tab_main(l_curr_index).run_contribution 	:= g_tab_main(l_curr_index).run_contribution + g_tab_calc(i).run_contribution ;

	END LOOP;

	hr_utility.trace('2007 EMP_CONT ::: Main Calc --- leaving loop for re-allocation and summing up values'  );

	hr_utility.trace('2007 EMP_CONT ::: Main Calc Leaving--------'  );

RETURN l_main_index ;

END ec_main_calculation ;


-----------------------------------------------------------------------------------------------------------------------------------

-- function to get the ec rate

FUNCTION get_ec_rate

  (p_zone			IN  VARCHAR2
  ,p_under_limit		IN  VARCHAR2
  ,p_org_status 		IN  VARCHAR2
  ,p_bus_group_id      		IN  NUMBER
  ,p_date_earned    		IN  DATE
  ,p_under_age_high_rate	IN NUMBER
  ,p_over_age_high_rate		IN NUMBER ) RETURN NUMBER IS

  l_ec_rate 		NUMBER;
  l_table_name		VARCHAR2(240);
  l_col_name		VARCHAR2(240);
  l_zone_value		VARCHAR2(240);

BEGIN

	-- providing existing values
	l_table_name := 'NO_NIS_ZONE_RATES';

	l_zone_value := to_char(p_zone);

	l_ec_rate    := 0 ;


	IF (p_org_status = 'EE') -------------------------------------
		THEN
			-- no contribution for status EE
			l_ec_rate := 0;

	ELSIF ( (p_org_status = 'AA') OR (p_org_status = 'GG') )  -------------------------------------
		THEN
			-- Normal rates apply for all except zone '1a'
			-- For zone '1a', high rate applies after exemption limit is exhausted

			IF ((l_zone_value = '1a') AND (p_under_limit = 'N'))

				THEN l_ec_rate := p_under_age_high_rate ;

				-- ELSE l_ec_rate := TO_NUMBER(hruserdt.get_table_value (p_bus_group_id, l_table_name, 'Under Age Percentage', l_zone_value, p_date_earned ));
				-- ELSE l_ec_rate := fnd_number.canonical_to_number(hruserdt.get_table_value (p_bus_group_id, l_table_name, 'Under Age Percentage', l_zone_value, p_date_earned ));
				-- BUG Fix : 5999230
				-- Renaming user column of user table NO_NIS_ZONE_RATES from 'Under Age Percentage' to 'NIS Rates'

				ELSE l_ec_rate := fnd_number.canonical_to_number(hruserdt.get_table_value (p_bus_group_id, l_table_name, 'NIS Rates', l_zone_value, p_date_earned ));

			END IF;


	ELSIF (p_org_status = 'BB')   -------------------------------------
		THEN
			-- Normal rates apply for all
			-- For zone '1a', the normal rate of zone '1' is used

			IF (l_zone_value = '1a') THEN l_zone_value := '1' ; END IF;

			-- l_ec_rate := TO_NUMBER(hruserdt.get_table_value (p_bus_group_id, l_table_name, 'Under Age Percentage', l_zone_value, p_date_earned ));
			-- l_ec_rate := fnd_number.canonical_to_number(hruserdt.get_table_value (p_bus_group_id, l_table_name, 'Under Age Percentage', l_zone_value, p_date_earned ));
			-- BUG Fix : 5999230
			-- Renaming user column of user table NO_NIS_ZONE_RATES from 'Under Age Percentage' to 'NIS Rates'

			l_ec_rate := fnd_number.canonical_to_number(hruserdt.get_table_value (p_bus_group_id, l_table_name, 'NIS Rates', l_zone_value, p_date_earned ));


	ELSIF (p_org_status = 'DD')   -------------------------------------
		THEN
			-- Normal rates apply for all
			-- For zone '4a', the normal rate of zone '4' is used

			IF (l_zone_value = '4a') THEN l_zone_value := '4' ; END IF;

			-- l_ec_rate := TO_NUMBER(hruserdt.get_table_value (p_bus_group_id, l_table_name, 'Under Age Percentage', l_zone_value, p_date_earned ));
			-- l_ec_rate := fnd_number.canonical_to_number(hruserdt.get_table_value (p_bus_group_id, l_table_name, 'Under Age Percentage', l_zone_value, p_date_earned ));
			-- BUG Fix : 5999230
			-- Renaming user column of user table NO_NIS_ZONE_RATES from 'Under Age Percentage' to 'NIS Rates'

			l_ec_rate := fnd_number.canonical_to_number(hruserdt.get_table_value (p_bus_group_id, l_table_name, 'NIS Rates', l_zone_value, p_date_earned ));


	ELSIF (p_org_status = 'CC')  -------------------------------------
		THEN
			-- Normal rates apply for all except zone '1a'
			-- For zone '1a', high rate applies after exemption limit is exhausted

			IF (p_under_limit = 'N')

				THEN l_ec_rate := p_under_age_high_rate ;

				-- ELSE l_ec_rate := TO_NUMBER(hruserdt.get_table_value (p_bus_group_id, l_table_name, 'Under Age Percentage', l_zone_value, p_date_earned ));
				-- ELSE l_ec_rate := fnd_number.canonical_to_number(hruserdt.get_table_value (p_bus_group_id, l_table_name, 'Under Age Percentage', l_zone_value, p_date_earned ));
				-- BUG Fix : 5999230
				-- Renaming user column of user table NO_NIS_ZONE_RATES from 'Under Age Percentage' to 'NIS Rates'

				ELSE l_ec_rate := fnd_number.canonical_to_number(hruserdt.get_table_value (p_bus_group_id, l_table_name, 'NIS Rates', l_zone_value, p_date_earned ));

			END IF;

	END IF; -- end status check -------------------------------------


RETURN l_ec_rate ;

END get_ec_rate ;

-----------------------------------------------------------------------------------------------------------------------------------

-- function to display table values of g_tab_calc

FUNCTION display_table_calc
  (g_tab_calc  IN  PAY_NO_EMP_CONT_2007.g_tab_calc_tabtype ) RETURN NUMBER IS

start_index_calc	NUMBER;
end_index_calc		NUMBER;

BEGIN

	start_index_calc := NVL (g_tab_calc.FIRST, 0) ;
	end_index_calc   := NVL (g_tab_calc.LAST, 0) ;

	hr_utility.trace('2007 EMP_CONT ::: ---------- Displaying g_tab_calc table data ----------------------');
	hr_utility.trace('2007 EMP_CONT :::  zone  -- under_limit -- status -- bimonth_base -- run_base -- bimonth_cont -- bimonth_cont_todate -- run_cont ');

	FOR i IN start_index_calc..end_index_calc LOOP

		hr_utility.trace('2007 EMP_CONT ::: '
		                 ||'  '||g_tab_calc(i).zone
				 ||'  '||g_tab_calc(i).under_limit
				 ||'  '||g_tab_calc(i).status
				 ||'  '||g_tab_calc(i).bimonth_base
				 ||'  '||g_tab_calc(i).run_base
				 ||'  '||g_tab_calc(i).bimonth_contribution
				 ||'  '||g_tab_calc(i).bimonth_contribution_todate
				 ||'  '||g_tab_calc(i).run_contribution	 );

	END LOOP;
	hr_utility.trace('2007 EMP_CONT ::: ---------- Displayed g_tab_calc table data , exiting function ----------------------');

RETURN 1 ;

END display_table_calc ;

-----------------------------------------------------------------------------------------------------------------------------------
-- changing the function to fetch the avg ni base rate for months and end of year averaging
-- function to get the average NI Base Rate Value

FUNCTION avg_ni_base_rate (p_date_earned  IN  DATE , p_bus_grp_id NUMBER ) RETURN NUMBER IS

l_base_rate_value 		NUMBER;
l_cum_base_rate_value	NUMBER;
l_avg_base_rate_value	NUMBER;

l_no_of_mths		NUMBER;
l_start_of_year 	DATE;
l_end_of_year 		DATE;

l_eff_start_date	DATE;
l_eff_end_date		DATE;

-- defining cursor to get all NI Base Rate values
-- NEW

/*

cursor csr_get_ni_base_rates (p_date_earned date ,p_bus_grp_id NUMBER ) IS
 select pucf.EFFECTIVE_START_DATE
		,pucf.EFFECTIVE_END_DATE
		,pucf.VALUE
from pay_user_tables	put
	,pay_user_rows_f	pur
	,pay_user_columns	puc
	,pay_user_column_instances_f	pucf
where	put.USER_TABLE_NAME = 'NO_GLOBAL_CONSTANTS'
and 	pur.ROW_LOW_RANGE_OR_NAME = 'NATIONAL_INSURANCE_BASE_RATE'
and 	puc.USER_COLUMN_NAME = 'Value'
and 	put.legislation_code = 'NO'
and 	pur.legislation_code = 'NO'
and 	puc.legislation_code = 'NO'
and 	( pucf.business_group_id = p_bus_grp_id OR pucf.business_group_id is NULL )
and 	put.user_table_id = pur.user_table_id
and 	put.user_table_id = puc.user_table_id
and		pucf.user_row_id = pur.user_row_id
and 	pucf.user_column_id = puc.user_column_id
and		p_date_earned between pur.effective_start_date and pur.effective_end_date
and     pucf.effective_start_date < (trunc(add_months(p_date_earned,12),'Y')-1)
and     pucf.effective_end_date > trunc(p_date_earned , 'Y' ) ;

*/

-- Bug Fix 5566622 : Value of G (National Insurance Base Rate) to be taken
-- from Global (NO_NATIONAL_INSURANCE_BASE_RATE) and not user table (NATIONAL_INSURANCE_BASE_RATE).
-- modifying cursor csr_get_ni_base_rates

/*
cursor csr_get_ni_base_rates (p_date_earned date ) IS
       select  EFFECTIVE_START_DATE
             , EFFECTIVE_END_DATE
             , to_number(global_value) VALUE
       from ff_globals_f
       where legislation_code = 'NO'
       and   global_name = 'NO_NATIONAL_INSURANCE_BASE_RATE'
       and   BUSINESS_GROUP_ID IS NULL
       and   effective_start_date  <= (trunc(add_months(p_date_earned,12),'Y')-1)
       and   effective_end_date    >= trunc(p_date_earned , 'Y' ) ;
*/

cursor csr_get_ni_base_rates (p_date_earned date ) IS
       select  EFFECTIVE_START_DATE
             , EFFECTIVE_END_DATE
             , fnd_number.canonical_to_number(global_value) VALUE
       from ff_globals_f
       where legislation_code = 'NO'
       and   global_name = 'NO_NATIONAL_INSURANCE_BASE_RATE'
       and   BUSINESS_GROUP_ID IS NULL
       and   effective_start_date  <= (trunc(add_months(p_date_earned,12),'Y')-1)
       and   effective_end_date    >= trunc(p_date_earned , 'Y' ) ;


BEGIN

l_end_of_year := (trunc(add_months(p_date_earned,12),'Y')-1) ;
l_start_of_year := trunc(p_date_earned, 'Y');

l_cum_base_rate_value := 0 ;

hr_utility.trace('2007 EMP_CONT ::: p_date_earned =  '||p_date_earned);
hr_utility.trace('2007 EMP_CONT ::: l_start_of_year = '||l_start_of_year);
hr_utility.trace('2007 EMP_CONT ::: l_end_of_year = '||l_end_of_year);
hr_utility.trace('2007 EMP_CONT ::: ========================================= ');

-- Bug Fix 5566622 : Value of G (National Insurance Base Rate) to be taken from Global and not user table.
-- modifying call for cursor csr_get_ni_base_rates

-- FOR csr_rec IN csr_get_ni_base_rates (p_date_earned , p_bus_grp_id) LOOP
FOR csr_rec IN csr_get_ni_base_rates (p_date_earned ) LOOP

	l_base_rate_value := csr_rec.VALUE ;
	l_eff_start_date  := csr_rec.EFFECTIVE_START_DATE ;
	l_eff_end_date	  := csr_rec.EFFECTIVE_END_DATE	;

	-- check if effective start date is before the starting of the year

	IF (l_eff_start_date < l_start_of_year)
		THEN
			hr_utility.trace('2007 EMP_CONT ::: OLD  l_eff_start_date = '||l_eff_start_date);
			l_eff_start_date := l_start_of_year;
			hr_utility.trace('2007 EMP_CONT ::: NEW  l_eff_start_date = '||l_eff_start_date);
	END IF;

	-- check if effective end date is after the end of the period

	IF (l_eff_end_date > l_end_of_year)
		THEN
			hr_utility.trace('2007 EMP_CONT ::: OLD  l_eff_end_date = '||l_eff_end_date);
			l_eff_end_date := l_end_of_year;
			hr_utility.trace('2007 EMP_CONT ::: NEW  l_eff_end_date = '||l_eff_end_date);
	END IF;

	-- calculating the number of months the value is valid for

	l_no_of_mths := months_between(l_eff_end_date , (l_eff_start_date -1) );
	l_cum_base_rate_value := l_cum_base_rate_value + (l_base_rate_value * l_no_of_mths) ;


	hr_utility.trace('2007 EMP_CONT ::: -------------- ');
	hr_utility.trace('2007 EMP_CONT ::: l_base_rate_value = '||l_base_rate_value);
	hr_utility.trace('2007 EMP_CONT ::: l_eff_start_date = '||l_eff_start_date);
	hr_utility.trace('2007 EMP_CONT ::: l_eff_end_date = '||l_eff_end_date);
	hr_utility.trace('2007 EMP_CONT ::: l_no_of_mths = '||l_no_of_mths);
	hr_utility.trace('2007 EMP_CONT ::: l_base_rate_value * l_no_of_mths = '||l_base_rate_value * l_no_of_mths);
	hr_utility.trace('2007 EMP_CONT ::: l_cum_base_rate_value = '||l_cum_base_rate_value);
	hr_utility.trace('2007 EMP_CONT ::: -------------- ');

END LOOP; -- end cursor loop

l_avg_base_rate_value := l_cum_base_rate_value / 12 ;

hr_utility.trace('2007 EMP_CONT ::: =================================================== ');
hr_utility.trace('2007 EMP_CONT ::: l_cum_base_rate_value = '||l_cum_base_rate_value);
hr_utility.trace('2007 EMP_CONT ::: l_avg_base_rate_value = '||l_avg_base_rate_value);
hr_utility.trace('2007 EMP_CONT ::: ---------------- OVER ---------------- ');


RETURN l_avg_base_rate_value ;

EXCEPTION
WHEN OTHERS THEN
l_avg_base_rate_value := 0;
RETURN l_avg_base_rate_value ;


END avg_ni_base_rate ;


---------------------------------------------------------------------------------------------------------------

-- Function to look up the corresponding cell number in he table g_tab_main

FUNCTION main_lookup_cell
  (g_tab_main  		IN  PAY_NO_EMP_CONT_2007.g_tab_main_tabtype
  ,start_main_index	IN  NUMBER
  ,l_zone      		IN  VARCHAR2 ) RETURN NUMBER IS

  l_cell	NUMBER;

BEGIN
	l_cell := 0;

	FOR i IN start_main_index..(start_main_index + 6) LOOP

		IF (g_tab_main(i).zone = l_zone ) THEN 	l_cell := i; EXIT;  END IF;

	END LOOP; -- end i loop

RETURN l_cell ;

END main_lookup_cell ;

---------------------------------------------------------------------------------------------------------------

-- Function to check if any exemption limit error exists

FUNCTION chk_exemption_limit_err
  (p_date_earned	IN  DATE
  ,p_bus_grp_id		IN  NUMBER
  ,p_payroll_action_id  IN  NUMBER )

RETURN NUMBER IS

l_status	VARCHAR2(240);
l_rep_sep	VARCHAR2(240);
l_exempt_limit	NUMBER;
l_org_name	VARCHAR2(240);
l_lu_tax_mun	VARCHAR2(200) ;

-- 2007 Legislative changes for 'Economic Aid' to Employer
l_economic_aid	NUMBER;

BEGIN

	hr_utility.trace('2007 EXEM_LIM ::: Entered the procedure for exemption limit  ');
	--p_err_text := '';

	IF ( g_error_flag = TRUE )

		THEN
			hr_utility.trace('2007 EXEM_LIM :::  g_error_flag = TRUE , returning 1' );
			RETURN 1 ; -- error has occured already , return 1 to formula funnction and from there just RETURN

	ELSIF ( g_error_check = TRUE )

		THEN
			hr_utility.trace('2007 EXEM_LIM :::  g_error_flag = FALE but g_error_check = TRUE , returning 0' );
			RETURN 0 ; -- checking has been done but no error is there , return 0 to formula function , continue processing

	ELSE   -- the error condition has not been checked yet

		hr_utility.trace('2007 EXEM_LIM ::: both globals are false , nocheck has been performed  ');
		-- since we are checking the condition now , set the check global to TRUE
		g_error_check	:= TRUE ;
		hr_utility.trace('2007 EXEM_LIM ::: made g_error_check := TRUE   ');

		-- loop thru the cursor csr_get_lu_le and get all LE and LU

		FOR csr_rec in PAY_NO_EMP_CONT_2007.csr_get_lu_le (p_payroll_action_id ,p_date_earned ) LOOP

			hr_utility.trace('2007 EXEM_LIM ::: ------------------Inside For loop-------------  ' );
			hr_utility.trace('2007 EXEM_LIM :::  Local unit id = '||csr_rec.loc_unit ||'  Legal Employer ID = '||csr_rec.leg_emp  );
			-- get the status and report separately for the LU

			OPEN PAY_NO_EMP_CONT_2007.get_lu_details (csr_rec.loc_unit);
			FETCH PAY_NO_EMP_CONT_2007.get_lu_details INTO l_status , l_rep_sep , l_lu_tax_mun ;
			CLOSE PAY_NO_EMP_CONT_2007.get_lu_details ;

			hr_utility.trace('2007 EXEM_LIM :::  l_status '|| l_status );
			hr_utility.trace('2007 EXEM_LIM :::  l_rep_sep '||l_rep_sep  );

			-- if report separately = yes and status in AA,CC,GG
			IF ( trim(l_rep_sep) = 'Y' ) AND ( l_status IN ('AA','CC','GG') )

				THEN
					hr_utility.trace('2007 EXEM_LIM :::  local unit is rep sep and status in AA,CC,GG....fetching exemption limit ');
					-- then open exemption limit cursor
					OPEN PAY_NO_EMP_CONT_2007.csr_get_exemption_limit (csr_rec.loc_unit, p_date_earned) ;

					-- 2007 Legislative changes for 'Economic Aid' to Employer
					-- FETCH PAY_NO_EMP_CONT_2007.csr_get_exemption_limit INTO l_exempt_limit ;
					FETCH PAY_NO_EMP_CONT_2007.csr_get_exemption_limit INTO l_exempt_limit , l_economic_aid ;

					-- if any error is there
					-- checking if no data returned for Exemption Limit
					IF (PAY_NO_EMP_CONT_2007.csr_get_exemption_limit%NOTFOUND OR l_exempt_limit IS NULL)
						THEN
						    hr_utility.trace('2007 EXEM_LIM ::: Problem in getting Exemption limit ' );
						    -- Exemption Limit for this Local Unit Not Specified for this Period or not specified at all

						    -- get global error flag to TRUE
						    g_error_flag	:= TRUE ;
						    hr_utility.trace('2007 EXEM_LIM ::: set g_error_flag = TRUE ');

						    -- get the name of the local unit
						    OPEN PAY_NO_EMP_CONT_2007.csr_org_name(csr_rec.loc_unit ,p_bus_grp_id );
						    FETCH PAY_NO_EMP_CONT_2007.csr_org_name INTO l_org_name ;
						    CLOSE PAY_NO_EMP_CONT_2007.csr_org_name;

						    hr_utility.trace('2007 EXEM_LIM ::: name of local unit = '|| l_org_name );

						    -- Set the message and message token
						    hr_utility.set_message (801, 'PAY_376856_NO_LU_NO_EXEM_LIMIT');
						    hr_utility.set_message_token (801, 'ORG_NAME', l_org_name);

						    hr_utility.trace('2007 EXEM_LIM :::  set the message =  '||hr_utility.get_message  );

						    -- Put the meassage in the log file
						    fnd_file.put_line (fnd_file.LOG, hr_utility.get_message);

						    hr_utility.trace('2007 EXEM_LIM ::: put the msg in the log file  ');

						    -- p_err_text := p_err_text || hr_utility.get_message ;

					END IF; -- end exemption limit got check

					CLOSE PAY_NO_EMP_CONT_2007.csr_get_exemption_limit;

			ELSIF	( trim(l_rep_sep) = 'N' ) -- else if LU is not rep sep , check at the legal employer level

			    THEN
				hr_utility.trace('2007 EXEM_LIM :::  local unit is NOT rep sep....fetching LE Status ');
				-- get the status of the LE
				OPEN PAY_NO_EMP_CONT_2007.get_le_status (csr_rec.leg_emp) ;
				FETCH PAY_NO_EMP_CONT_2007.get_le_status INTO l_status ;
				CLOSE PAY_NO_EMP_CONT_2007.get_le_status ;

				hr_utility.trace('2007 EXEM_LIM ::: LE l_status '|| l_status );

				-- if the status of LE in AA,CC,GG
				IF  ( l_status IN ('AA','CC','GG') )
				    THEN
					hr_utility.trace('2007 EXEM_LIM :::  Legal Emp status in AA,CC,GG ....fetching exemption limit ');
					-- then open exemption limit cursor
					OPEN PAY_NO_EMP_CONT_2007.csr_get_exemption_limit (csr_rec.leg_emp, p_date_earned) ;

					-- 2007 Legislative changes for 'Economic Aid' to Employer
					-- FETCH PAY_NO_EMP_CONT_2007.csr_get_exemption_limit INTO l_exempt_limit ;
					FETCH PAY_NO_EMP_CONT_2007.csr_get_exemption_limit INTO l_exempt_limit , l_economic_aid ;

					-- if any error is there
					-- checking if no data returned for Exemption Limit
					IF (PAY_NO_EMP_CONT_2007.csr_get_exemption_limit%NOTFOUND OR l_exempt_limit IS NULL)
						THEN
						    hr_utility.trace('2007 EXEM_LIM ::: Problem in getting Exemption limit ' );
						    -- Exemption Limit for this Legal Emplyer Not Specified for this Period or not specified at all

						    -- get global error flag to TRUE
						    g_error_flag	:= TRUE ;
						     hr_utility.trace('2007 EXEM_LIM ::: set g_error_flag = TRUE ');

						    -- get the name of the Legal Employer
						    OPEN PAY_NO_EMP_CONT_2007.csr_org_name(csr_rec.leg_emp ,p_bus_grp_id );
						    FETCH PAY_NO_EMP_CONT_2007.csr_org_name INTO l_org_name ;
						    CLOSE PAY_NO_EMP_CONT_2007.csr_org_name;

						     hr_utility.trace('2007 EXEM_LIM ::: name of legal employer = '|| l_org_name );

						    -- Set the message and message token
						    hr_utility.set_message (801, 'PAY_376857_NO_LE_NO_EXEM_LIMIT');
						    hr_utility.set_message_token (801, 'ORG_NAME', l_org_name);
						    hr_utility.trace('2007 EXEM_LIM :::  set the message =  '||hr_utility.get_message  );

						    -- Put the meassage in the log file
						    fnd_file.put_line (fnd_file.LOG, hr_utility.get_message);
						    hr_utility.trace('2007 EXEM_LIM ::: put the msg in the log file  ');

						    -- p_err_text := p_err_text || hr_utility.get_message ;

					END IF; -- end exemption limit got check

					CLOSE PAY_NO_EMP_CONT_2007.csr_get_exemption_limit;

				END IF; -- end if the status of LE in AA,CC,GG

			END IF ;  -- end if report separately = yes and status in AA,CC,GG

		END LOOP; -- end loop thru the cursor csr_get_lu_le and get all LE and LU

		hr_utility.trace('2007 EXEM_LIM ::: **************** end of loop *************  ');

		hr_utility.trace('2007 EXEM_LIM :::  final error check ');

		-- finally check if any error did occur
		IF ( g_error_flag = TRUE )
			THEN
				hr_utility.trace('2007 EXEM_LIM ::: g_error_flag = TRUE , returning 1  ');
				RETURN 1 ; -- error did occur
		ELSE
			hr_utility.trace('2007 EXEM_LIM ::: g_error_flag = FALSE , returning 1  ');
			RETURN 0  ; -- error didnot occur

		END IF; -- end final check for error

	END IF ; -- end of error check


-- end of function
END chk_exemption_limit_err ;

--------------------------------------------------------------------------------------------------------------------------------

-- function to get the employer contribution rate
 FUNCTION get_emp_contr_rate

              (p_bus_group_id IN NUMBER,
	      p_tax_unit_id IN NUMBER,
	      p_local_unit_id IN NUMBER,
	      p_jurisdiction_code IN VARCHAR2,
	      p_date_earned IN DATE,
	      p_asg_act_id IN NUMBER,
	      p_under_age_high_rate IN NUMBER,
	      p_over_age_high_rate IN NUMBER,
	      p_under_limit IN VARCHAR2)  RETURN NUMBER IS

	      l_ec_rate NUMBER;
              l_org_status VARCHAR2(40);
              l_le_status VARCHAR2(40);
              l_lu_status VARCHAR2(40);
              l_lu_rep_sep VARCHAR2(1);
	      l_lu_tax_mun  VARCHAR2(200) ;
          --  l_curr_zone NUMBER;
	      l_curr_zone VARCHAR2(10);  -- current zone can return Character Values


              BEGIN

                OPEN PAY_NO_EMP_CONT_2007.get_lu_details(p_local_unit_id);
                FETCH PAY_NO_EMP_CONT_2007.get_lu_details
                INTO l_lu_status , l_lu_rep_sep , l_lu_tax_mun ;
                CLOSE PAY_NO_EMP_CONT_2007.get_lu_details;


                IF(l_lu_rep_sep = 'Y') THEN
                  l_org_status := l_lu_status; -- if report sepeartely is yes then assigning the lu status


                ELSE


                  OPEN PAY_NO_EMP_CONT_2007.get_le_status(p_tax_unit_id);
                  FETCH PAY_NO_EMP_CONT_2007.get_le_status
                  INTO l_le_status;
                  CLOSE PAY_NO_EMP_CONT_2007.get_le_status;

                  l_org_status := l_le_status;    -- assigning the le status
                END IF;

		-- l_curr_zone := to_number(SUBSTR(PAY_NO_EMP_CONT_2007.get_lookup_meaning('NO_TAX_MUNICIPALITY',   p_jurisdiction_code),   1,   1));
		l_curr_zone	:= hruserdt.get_table_value (p_bus_group_id, 'NO_TAX_MUNICIPALITY' , 'ZONE', p_jurisdiction_code, p_date_earned ) ;



                l_ec_rate := PAY_NO_EMP_CONT_2007.get_ec_rate( l_curr_zone,   p_under_limit,   l_org_status,   p_bus_group_id,   p_date_earned,   p_under_age_high_rate,   p_over_age_high_rate);



                RETURN l_ec_rate;
END get_emp_contr_rate;

--------------------------------------------------------------------------------------------------------------------------


---------------------------- end of package ---------------------------------------------------------------------------------------

END PAY_NO_EMP_CONT_2007;

/
