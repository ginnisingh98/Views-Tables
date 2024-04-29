--------------------------------------------------------
--  DDL for Package Body PAY_KR_WG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_KR_WG_PKG" AS
/* $Header: pykrffwg.pkb 120.16.12000000.1 2007/01/17 22:04:46 appldev noship $ */

--Global var introduced for bug 3223825
g_wg_deduction_bal_id		NUMBER;
g_wg_interest_bal_id		NUMBER;
--Global var introduced for bug 4498363
g_min_undeduct_amt	 	NUMBER	       :=  0;
g_base_undeduct_amt	 	NUMBER	       :=  0;
g_max_attachable_earnings	NUMBER         :=  0;
g_change_effective_date         DATE	       := to_date('2005/07/28', 'YYYY/MM/DD');
--Global variable added for the enhancement 4680413
g_change_eff_date_NTLA          DATE           := to_date('2006/04/28', 'YYYY/MM/DD');
g_excpn_court_order_flag	VARCHAR2(1)    := 'N';
--
cursor csr_get_global_values(p_global_name IN varchar2) is
	select global_value from ff_globals_f where global_name = p_global_name;
--
g_debug boolean := hr_utility.debug_enabled;
  -----------------------------------------------------------------------------------------------
  -- Function calc_wage_garnishment. Function with added parameter o_adjusted_amount.
  -- This function calls another version with the parameter p_attachment_sequence_no
  -----------------------------------------------------------------------------------------------
  FUNCTION calc_wage_garnishment(	p_assignment_id 		IN		NUMBER,
					p_assignment_action_id		IN		NUMBER,
					p_date_earned 			IN		DATE,
					p_element_entry_id 		IN		NUMBER,
					p_net_earnings 			IN		NUMBER,
                                        p_run_type			IN      	VARCHAR2,
					p_attachment_amount		OUT	NOCOPY	NUMBER,
					p_adjusted_amount		OUT	NOCOPY	NUMBER,
					p_attach_total_base		OUT	NOCOPY	NUMBER,
					p_real_attach_total		OUT	NOCOPY	NUMBER,
					p_emp_attach_total		OUT	NOCOPY	NUMBER,
					p_interest_amount		OUT	NOCOPY	NUMBER,
					p_adjustment_amount		OUT	NOCOPY	NUMBER,
					p_unadjusted_amount		OUT	NOCOPY	NUMBER,
					p_stop_flag			OUT	NOCOPY	VARCHAR2,
					p_message			OUT	NOCOPY	VARCHAR2,
                                        p_curr_attach_seq_no		OUT     NOCOPY	VARCHAR2,
                                        p_curr_case_number		OUT     NOCOPY	VARCHAR2,
                                        p_payout_date			OUT	NOCOPY  DATE,
                                        p_date_paid			IN              DATE,
					p_wg_attach_earnings_mtd	IN              NUMBER,
					p_wg_deductions_mtd		IN              NUMBER

                     ) RETURN NUMBER
  IS

    l_attachment_seq_no		VARCHAR2(100);
    l_return			NUMBER         := 0;
  BEGIN
     --
     --
     l_attachment_seq_no := pay_kr_wg_report_pkg.get_attach_seq_no(p_element_entry_id);


     if g_debug then
      	hr_utility.set_location('Got the attachment seq no : '||l_attachment_seq_no, 10);
     end if;

     l_return := calc_wage_garnishment(	p_assignment_id			=>   p_assignment_id 	        ,
					p_assignment_action_id		=>   p_assignment_action_id	,
					p_date_earned			=>   p_date_earned 		,
					p_attachment_seq_no		=>   l_attachment_seq_no 	,
					p_net_earnings			=>   p_net_earnings 		,
                                        p_run_type			=>   p_run_type                 ,
					p_attachment_amount		=>   p_attachment_amount	,
					p_adjusted_amount		=>   p_adjusted_amount	        ,
					p_attach_total_base		=>   p_attach_total_base	,
					p_real_attach_total		=>   p_real_attach_total	,
					p_emp_attach_total		=>   p_emp_attach_total		,
					p_interest_amount		=>   p_interest_amount		,
					p_adjustment_amount		=>   p_adjustment_amount	,
					p_unadjusted_amount		=>   p_unadjusted_amount	,
					p_stop_flag			=>   p_stop_flag		,
					p_message			=>   p_message			,
                                        p_curr_attach_seq_no		=>   p_curr_attach_seq_no    	,
                                        p_curr_case_number		=>   p_curr_case_number         ,
                                        p_payout_date			=>   p_payout_date              ,
					p_date_paid			=>   p_date_paid		,
					p_wg_attach_earnings_mtd	=>   p_wg_attach_earnings_mtd   ,
					p_wg_deductions_mtd		=>   p_wg_deductions_mtd	);


    RETURN l_return;

  END calc_wage_garnishment;
  --==================================================================================================

  ----------------------------------------------------------------------------------------------------
  -- Function calc_wage_garnishments.
  ----------------------------------------------------------------------------------------------------
  FUNCTION calc_wage_garnishment(	p_assignment_id 		IN		NUMBER,
					p_assignment_action_id		IN		NUMBER,
					p_date_earned 			IN		DATE,
					p_attachment_seq_no 		IN		VARCHAR2,
					p_net_earnings 			IN		NUMBER,
                                        p_run_type			IN      	VARCHAR2,
					p_attachment_amount		OUT	NOCOPY	NUMBER,
					p_adjusted_amount		OUT	NOCOPY	NUMBER,
					p_attach_total_base		OUT	NOCOPY	NUMBER,
					p_real_attach_total		OUT	NOCOPY	NUMBER,
					p_emp_attach_total		OUT	NOCOPY	NUMBER,
					p_interest_amount		OUT	NOCOPY	NUMBER,
					p_adjustment_amount		OUT	NOCOPY	NUMBER,
					p_unadjusted_amount		OUT	NOCOPY	NUMBER,
					p_stop_flag			OUT	NOCOPY	VARCHAR2,
					p_message			OUT	NOCOPY	VARCHAR2,
                                        p_curr_attach_seq_no		OUT     NOCOPY	VARCHAR2,
                                        p_curr_case_number		OUT     NOCOPY	VARCHAR2,
                                        p_payout_date			OUT     NOCOPY  DATE,
					p_date_paid			IN	        DATE,
					p_wg_attach_earnings_mtd	IN		NUMBER,
					p_wg_deductions_mtd		IN		NUMBER
                     ) RETURN NUMBER
  IS
          c_all_attachment    		   CHAR(1) 	DEFAULT 'N';
          d_all_attach_date   		   DATE                    ;
          c_actual_attachment      	   CHAR(1) 	DEFAULT 'N';
          c_obligation_release  	   CHAR(1)	DEFAULT 'N';
          c_all_attach_full_paid           CHAR(1)      DEFAULT 'N';
          c_waiting_for_all_attach         CHAR(1)      DEFAULT 'N';
          c_redistribution_required	   CHAR(1)	DEFAULT 'N'; --4866417

          g_emp_total          		   t_emp_total      ;
          g_actual_attach                  tab_actual_attach;

          l_emp_attach_total               NUMBER	:= 0;
          l_correction_amount              NUMBER	:= 0;
          l_period_start_date              DATE   ;
          l_period_end_date                DATE   ;
          l_payout_date                    DATE   ;
          l_payroll_action_id              pay_assignment_actions.payroll_action_id%TYPE;

	  --Local variables introduced for Bug :4498363--
	  l_count_court_orders		   NUMBER	:= 0;
          l_count_actual_attach		   NUMBER	:= 0;
          l_earnings			   NUMBER	:= 0;
          l_count_oblig_rel_before	   NUMBER	:= 0;
          l_count_oblig_rel_after	   NUMBER	:= 0;

          e_duplicate_attach_exception     EXCEPTION;
          e_prev_case_notfound_exception   EXCEPTION;
          e_all_attachment_exception       EXCEPTION;

          -- Bug 2715365 Cursors for Payroll Period dates

          Cursor csr_pay_period(p_asg_action_id NUMBER)
          IS
           select TPERIOD.start_date
                 ,TPERIOD.end_date
                 ,PACTION.payroll_action_id
             from pay_payroll_actions                      PACTION
                 ,pay_assignment_actions                   ASSACTION
                 ,per_time_periods                         TPERIOD
                 ,per_time_period_types                    TPTYPE
            where ASSACTION.assignment_action_id         = p_asg_action_id
              and PACTION.payroll_action_id              = ASSACTION.payroll_action_id
              and TPERIOD.time_period_id                 = PACTION.time_period_id
              and TPTYPE.period_type                     = TPERIOD.period_type;
     --
     -- Local Procedures
     --
     -- 1. load_court_orders
     -- 2. calc_net_earnings -- Bug : 4498363
     -- 3. calc_real_attachment_total
     -- 4. calc_emp_attachment_total
     -- 5. distribute_paid_amt
     -- 6. get_court_order_start_date.
     -- 7. is_oblig_release_processed
     --
     ----------------------------------------------------------------
     -- Procedure to get all current court orders
     ----------------------------------------------------------------
     PROCEDURE load_court_orders
     IS
        CURSOR csr_etype(p_element_name VARCHAR2) IS
		SELECT	element_type_id
		from	pay_element_types_f
		where	element_name = p_element_name
		and	legislation_code = 'KR'
		and	business_group_id is null
                and     p_date_earned between effective_start_date and effective_end_date
		group by element_type_id;

        CURSOR csr_wg(p_element_type_id number) IS
		SELECT  pee.assignment_id,
			pee.element_entry_id,
			peev.input_value_id,
                        pee.effective_start_date court_order_start_date,
                        pee.entry_information1  interest_from_date1,
                        pee.entry_information2  interest_to_date1,
                        pee.entry_information3  interest_base1,
                        pee.entry_information4  interest_rate1,
                        pee.entry_information5  interest_from_date2,
                        pee.entry_information6  interest_to_date2,
                        pee.entry_information7  interest_base2,
                        pee.entry_information8  interest_rate2,
                        pee.entry_information9  interest_from_date3,
                        pee.entry_information10 interest_to_date3,
                        pee.entry_information11 interest_base3,
                        pee.entry_information12 interest_rate3,
                        pee.entry_information13 interest_from_date4,
                        pee.entry_information14 interest_to_date4,
                        pee.entry_information15 interest_base4,
                        pee.entry_information16 interest_rate4,
                        pee.entry_information17 interest_from_date5,
                        pee.entry_information18 interest_to_date5,
                        pee.entry_information19 interest_base5,
                        pee.entry_information20 interest_rate5,
                        pee.entry_information21 previous_case_number,
                        pee.entry_information23 payout_date,
			pee.entry_information24 court_order_origin,
                        name,
			peev.screen_entry_value
		from	pay_element_entry_values_f  peev,
			pay_element_entries_f	    pee,
			pay_element_links_f	    pel,
                        pay_input_values_f          piv
		where	pel.element_type_id = p_element_type_id
                and     piv.element_type_id = p_element_type_id
                and     piv.element_type_id = pel.element_type_id
		and	p_date_earned between pel.effective_start_date and pel.effective_end_date
		and	p_date_earned between piv.effective_start_date and piv.effective_end_date
                and     peev.input_value_id = piv.input_value_id
		and	pee.element_link_id = pel.element_link_id
		and	pee.assignment_id = p_assignment_id
		and	nvl(pee.entry_type, 'E') = 'E'
		and	p_date_earned between pee.effective_start_date and pee.effective_end_date
		and	peev.element_entry_id = pee.element_entry_id
		and	peev.effective_start_date = pee.effective_start_date
		and	peev.effective_end_date = pee.effective_end_date
                -- Bug 2786290
	        -- Bug 4866417 -- removed the not exists clause introduced for bug 2786290
                -- Order by clause changes for bug 268885
		order by 1,2,3 desc;


        l_element_type_id    NUMBER      := 0;
        l_element_entry_id   NUMBER      := 0;
        l_court_order_no     NUMBER      := 0;
        l_valid_attach_seq   VARCHAR2(1) := 'Y';
        l_interest_loaded    BOOLEAN     := FALSE;
        l_check_condition    VARCHAR2(1) := 'N'; --4498363
        ---------------------------------------------------------------------
        -- Bug : 4533467
        ---------------------------------------------------------------------
        FUNCTION get_court_order_start_date(p_element_entry_id IN NUMBER)
        RETURN DATE
        IS
	--
        Cursor csr_get_court_order_start_date(p_element_entry_id IN NUMBER) IS
           select min(effective_start_date)
           from pay_element_entries_f pee
           where pee.element_entry_id = p_element_entry_id;
        --
        l_court_order_start_date	DATE;
        --
        BEGIN
           OPEN csr_get_court_order_start_date(p_element_entry_id);
           FETCH csr_get_court_order_start_date into l_court_order_start_date;
           CLOSE csr_get_court_order_start_date;
           --
           RETURN l_court_order_start_date;
         END get_court_order_start_date;

        ---------------------------------------------------------------------
        -- Bug : 4866417
        ---------------------------------------------------------------------

        FUNCTION is_oblig_release_processed(p_element_entry_id IN NUMBER,
					        p_element_type_id  IN NUMBER)
	RETURN VARCHAR2
        IS
	    l_oblig_release_processed		VARCHAR2(1) := 'N';
        --
	Cursor csr_oblig_release_processed IS
           SELECT 'Y'
		  from    pay_run_results       prr
		         ,pay_run_result_values prrv
		         ,pay_input_values_f    piv
		  where prr.source_id         =   p_element_entry_id
		    and     prr.entry_type        IN  ('I','E')
		    and     prr.status            =  'P'
		    and     prrv.run_result_id    =   prr.run_result_id
		    and     piv.input_value_id    =   prrv.input_value_id
		    and     piv.element_type_id   =   p_element_type_id
		    and     piv.name              =  'Obligation Release'
		    and     prrv.result_value     = 'Y'
		    and     piv.legislation_code  =  'KR'
		    and     p_date_earned between piv.effective_start_date and piv.effective_end_date;
	--
        BEGIN
	   OPEN csr_oblig_release_processed;
           FETCH csr_oblig_release_processed into l_oblig_release_processed;
           CLOSE csr_oblig_release_processed;

           return l_oblig_release_processed;

       END is_oblig_release_processed;

        ---------------------------------------------------------------------
        -- Bug 2893245
        -- Function get_previous_payout_date
        ---------------------------------------------------------------------
        FUNCTION get_previous_payout_date (p_element_entry_id IN NUMBER, p_attachment_seq_no IN VARCHAR2) RETURN DATE
        IS

          CURSOR csr_prev_payout IS
	        SELECT	fnd_date.canonical_to_date(prrv.result_value)
		from	pay_run_results       prr
                       ,pay_run_result_values prrv
                       ,pay_element_types_f   pet
                       ,pay_input_values_f    piv
		where	prr.source_id         =   p_element_entry_id
                and     prr.entry_type        IN  ('I','E')
                and     prr.status            IN  ('P')
                and     prrv.run_result_id    =   prr.run_result_id
                and     piv.input_value_id    =   prrv.input_value_id
                and     pet.element_name      =  'WG Results'
                and     pet.legislation_code  =  'KR'
                and     piv.element_type_id   =   pet.element_type_id
                and     piv.name              =  'Payout Date'
		and	piv.legislation_code  =  'KR'
		and	piv.business_group_id IS NULL
                and     p_date_earned between piv.effective_start_date and piv.effective_end_date
                order by prr.assignment_action_id desc;
          --
	  -- Bug : 4859775
	  -- Removed join with pay_element_types_f and used the cursor csr_etype
          -- to get the element_type_id of 'WG Results'
	  --
          CURSOR csr_prev_payout_bal_adj(p_element_type_id IN NUMBER) IS
               SELECT  fnd_date.canonical_to_date(prrv.result_value)
               from    pay_payroll_actions    ppa
                      ,pay_assignment_actions paa
                      ,pay_run_results        prr
                      ,pay_run_result_values  prrv
                      ,pay_run_result_values  prrv1
                      ,pay_input_values_f     piv
                      ,pay_input_values_f     piv1
               where   paa.assignment_id        =   p_assignment_id
                 and   prr.assignment_action_id =   paa.assignment_action_id
                 and   paa.action_status        =   'C'
                 and   ppa.payroll_action_id    =   paa.payroll_action_id
                 and   ppa.action_type          =  'B'
                 and   ppa.effective_date       <=  p_date_earned
                 -- following condition is put for performance reasons
                 and   paa.assignment_action_id <=  p_assignment_action_id
                 and   prr.status               =  'P'
                 and   prr.entry_type           =  'B'
                 and   prr.element_type_id      =   p_element_type_id
                 and   prrv1.run_result_id      =   prr.run_result_id
                 and   piv1.name                =  'Attachment Seq No'
                 and   piv1.legislation_code    =  'KR'
                 and   piv1.business_group_id   IS NULL
                 and   piv1.element_type_id     =   p_element_type_id
                 and   piv1.input_value_id      =   prrv1.input_value_id
                 and   prrv1.result_value       =   p_attachment_seq_no
                 and   piv.name                 =  'Payout Date'
                 and   piv.legislation_code     =  'KR'
                 and   piv.business_group_id    IS NULL
                 and   prrv.run_result_id       =   prr.run_result_id
                 and   piv.input_value_id       =   prrv.input_value_id
                 and   piv.element_type_id      =   p_element_type_id
                 and   p_date_earned between piv.effective_start_date and piv.effective_end_date
                 order by ppa.effective_date desc;

           l_prev_payout_date             DATE;
           l_prev_payout_date_bal_adj     DATE;
           l_elem_type_id		  NUMBER;

        BEGIN

           OPEN  csr_prev_payout;
           FETCH csr_prev_payout INTO l_prev_payout_date;
           CLOSE csr_prev_payout;

	   --
	   -- Bug : 4859775
	   -- Added code to get element_type_id for 'WG Results'
	   --
           OPEN csr_etype('WG Results');
	   FETCH csr_etype into l_elem_type_id;
	   CLOSE csr_etype;

           OPEN  csr_prev_payout_bal_adj(l_elem_type_id);
           FETCH csr_prev_payout_bal_adj INTO l_prev_payout_date_bal_adj;
           CLOSE csr_prev_payout_bal_adj;

           -------------------------------------------------------------------------
           -- If both are not null then return the higher date
           -- If one of them is not null then return the date which is not null
           -- If both of them are null then return NULL
           -------------------------------------------------------------------------

           IF l_prev_payout_date IS NULL OR l_prev_payout_date_bal_adj IS NULL THEN

             IF l_prev_payout_date_bal_adj IS NOT NULL THEN
               l_prev_payout_date := l_prev_payout_date_bal_adj;
             END IF;

           ELSIF l_prev_payout_date_bal_adj > l_prev_payout_date THEN
             l_prev_payout_date := l_prev_payout_date_bal_adj;

           END IF;
           if g_debug then
	           hr_utility.set_location('Previous Payout Date is : '||to_char(l_prev_payout_date), 1);
	   end if;

           RETURN l_prev_payout_date;

        EXCEPTION
           WHEN OTHERS THEN
	     if g_debug then
             	hr_utility.set_location('Error in get_previous_payout_date. Message : '||substr(sqlerrm,1,200), -10);
             end if;
             RAISE;

        END get_previous_payout_date;
        -----------------------------------------------------------------

        ---------------------------------------------------------------------
        -- Function processing_first_time
        ---------------------------------------------------------------------
        FUNCTION processing_first_time (p_attach_seq_no IN VARCHAR2) RETURN BOOLEAN
        IS

           CURSOR csr_defined_bal_id(p_balance_name IN VARCHAR2,  p_dim_name IN VARCHAR2)
           IS
             SELECT pdb.defined_balance_id
               from pay_balance_types          pbt
                   ,pay_balance_dimensions     pbd
                   ,pay_defined_balances       pdb
              where pbt.balance_name         = p_balance_name
                and pbt.legislation_code     ='KR'
                and pbd.database_item_suffix = p_dim_name
                and pbd.legislation_code     ='KR'
                and pdb.balance_type_id      = pbt.balance_type_id
                and pdb.balance_dimension_id = pbd.balance_dimension_id
                and pdb.legislation_code     ='KR';

           l_value                   NUMBER  DEFAULT  0 ;
           -- Bug 3223825
           l_defined_balance_id      NUMBER  DEFAULT 0;

        BEGIN
           -- Bug 2762478
           pay_balance_pkg.set_context('SOURCE_TEXT', p_attach_seq_no);

           -- Bug 3223825
           IF g_wg_deduction_bal_id IS NULL THEN
              IF g_debug THEN
                 hr_utility.trace('first attempt');
              END IF;

              OPEN  csr_defined_bal_id('WG Deductions', '_ASG_WG_ITD');
              FETCH csr_defined_bal_id INTO l_defined_balance_id;
              CLOSE csr_defined_bal_id;

              g_wg_deduction_bal_id:=l_defined_balance_id;
           ELSE

              IF g_debug THEN
                 hr_utility.trace('sec attempt');
              END IF;

              l_defined_balance_id  :=   g_wg_deduction_bal_id;

           END IF;
           -- Bug 3435686
	   l_value:=pay_balance_pkg.get_value (l_defined_balance_id, p_assignment_action_id);

           if g_debug then
	           hr_utility.trace('l_value wg deduction ' || l_value)  ;
           end if;

           IF l_value > 0 THEN

              RETURN FALSE;

           ELSE

              IF g_wg_interest_bal_id is  NULL THEN
                 IF g_debug THEN
                    hr_utility.trace('first attempt');
                 END IF;

   	         OPEN  csr_defined_bal_id('WG Paid Interest', '_ASG_WG_ITD');
   		 FETCH csr_defined_bal_id INTO l_defined_balance_id;
           	 CLOSE csr_defined_bal_id;

		 g_wg_interest_bal_id  :=  l_defined_balance_id;

              ELSE
                 IF g_debug THEN
		       hr_utility.trace('sec attempt');
                 end if;

		 l_defined_balance_id:=g_wg_interest_bal_id;

	      END IF;
              -- Bug 3435686
  	      l_value:=pay_balance_pkg.get_value (l_defined_balance_id, p_assignment_action_id);

	      IF g_debug THEN
                 hr_utility.trace('l_value wg paid interest ' || l_value);
              END IF;

              IF l_value > 0 THEN
                 RETURN FALSE;
              END IF;

           END IF;

           RETURN TRUE;

        EXCEPTION
           WHEN OTHERS THEN
             if g_debug then
	             hr_utility.set_location('Error in Processing First Time. Message : '||substr(sqlerrm,1,200), -10);
             end if;
             RAISE;

        END processing_first_time;
        -----------------------------------------------------------------

        -----------------------------------------------------------------
        -- procedure validate_interest_bands
        ------------------------------------------------------------------------------
        -- Bug 2762097. Introduced this procedure to make interest calculation modular
        -- Bug 2822757. check for previous payout date included.
        -- Bug 2860586. check for Bug 2822757 is modified. >= is used instead of >
        -- Bug 2893245. NVL used for previous_payout_date if court order is not processing first time
        --              Payroll Period Start Date is used if previous payout date is null.
        -- Bug 3062873. Outer Period Interest Calculation.
        --              Check for interest_to_date5 >= l_period_start_date excluded.
        ---------------------------------------------------------------------------------------------
        PROCEDURE validate_interest_bands (i IN PLS_INTEGER)
        IS
          l_processing_first_time    BOOLEAN;

        BEGIN
           -----------------------------------------------------------------
           -- User must enter the payout date while running the payroll run.
           -- However this is not a mandatory parameter.
           -- Payout Date is defaulted to Date Paid.
           -----------------------------------------------------------------
           IF l_payout_date IS NULL THEN
              l_payout_date := l_period_end_date;
           END IF;

           ---------------------------------------------------------------------------------------------
           -- If current payout date is less than previous payout date, then interest band is not valid.
           -- Set interest_calc_to_date to null.
           ----------------------------------------------------------------------------------------------
           -- Otherwise, take the least of user entered value of interest_to_date and payout date - 1
           -- because if interest band is effetive then interest should be calculated upto payout date - 1.
           -------------------------------------------------------------------------------------------------
           IF l_payout_date <= g_court_orders(i).previous_payout_date THEN
              g_court_orders(i).interest_to_date1 := NULL;
              g_court_orders(i).interest_to_date2 := NULL;
              g_court_orders(i).interest_to_date3 := NULL;
              g_court_orders(i).interest_to_date4 := NULL;
              g_court_orders(i).interest_to_date5 := NULL;
           ELSE
              g_court_orders(i).interest_to_date1 := least(g_court_orders(i).interest_to_date1, l_payout_date-1);
              g_court_orders(i).interest_to_date2 := least(g_court_orders(i).interest_to_date2, l_payout_date-1);
              g_court_orders(i).interest_to_date3 := least(g_court_orders(i).interest_to_date3, l_payout_date-1);
              g_court_orders(i).interest_to_date4 := least(g_court_orders(i).interest_to_date4, l_payout_date-1);
              g_court_orders(i).interest_to_date5 := least(g_court_orders(i).interest_to_date5, l_payout_date-1);
           END IF;

           l_processing_first_time := processing_first_time(g_court_orders(l_court_order_no).attachment_sequence_no);

           ----------------------------------------------------------------------------------------------------
           -- Interest From Date will be populated only if interest period is valid for the current payroll run
           -- At all later stages Interest Rate is used to identify interest rate based calculations
           -- If interest from date is not null then apply interest calculation.
           ----------------------------------------------------------------------------------------------
           -- If Interest Rate or Interest From Date is not specified for an interest band, it is invalid
           -------------------------------------------------------------------------------------------------------------
           -- If Interest To Date for an interest band in set to null because of the above condition, it becomes invalid
           -------------------------------------------------------------------------------------------------------------
           -- If user has entered interest from date and if interest from date is for a future date after payroll period
           -- Then this interest band will not be considered in this payroll run.
           ----------------------------------------------------------------------------------------------------------------
           -- Interest_calc_from_date must be less than or equal to interest_calc_to_date for an interest band to be valid.
           ----------------------------------------------------------------------------------------------------------------
           -- For the first payroll run, interest period is derived from user entries in Element Entry DDF.
           -- For all payroll runs thereafter, interest period is derived from previous payout date.
           ------------------------------------------------------------------------------------------------
           -- Interest Band 1
           ------------------
           IF NOT (g_court_orders(i).interest_rate1 > 0                       AND
                   g_court_orders(i).interest_to_date1 IS NOT NULL            AND
                   g_court_orders(i).interest_from_date1 IS NOT NULL          AND
                   g_court_orders(i).interest_to_date1 >= nvl(g_court_orders(i).previous_payout_date, g_court_orders(i).interest_to_date1) AND
                   g_court_orders(i).interest_from_date1 <= g_court_orders(i).interest_to_date1)
           THEN
              g_court_orders(i).interest_from_date1 := NULL;

           ELSIF g_court_orders(i).interest_to_date1 < l_period_start_date THEN
              IF NOT l_processing_first_time THEN

                IF NOT g_court_orders(i).previous_payout_date < g_court_orders(i).interest_to_date1 THEN
                  g_court_orders(i).interest_from_date1 := NULL;
                ELSE
                  g_court_orders(i).interest_from_date1 := greatest(g_court_orders(i).previous_payout_date, g_court_orders(i).interest_from_date1);
                END IF;

              END IF;

           ELSIF NOT l_processing_first_time THEN
              g_court_orders(i).interest_from_date1 := greatest(g_court_orders(i).interest_from_date1, nvl(g_court_orders(i).previous_payout_date, l_period_start_date));
           END IF;
           ------------------
           -- Interest Band 2
           ------------------
           IF NOT (g_court_orders(i).interest_rate2 > 0                       AND
                   g_court_orders(i).interest_to_date2 IS NOT NULL            AND
                   g_court_orders(i).interest_from_date2 IS NOT NULL          AND
                   g_court_orders(i).interest_to_date2 >= nvl(g_court_orders(i).previous_payout_date, g_court_orders(i).interest_to_date2) AND
                   g_court_orders(i).interest_from_date2 <= g_court_orders(i).interest_to_date2)
           THEN
              g_court_orders(i).interest_from_date2 := NULL;

           ELSIF g_court_orders(i).interest_to_date2 < l_period_start_date THEN
              IF NOT l_processing_first_time THEN

                IF NOT g_court_orders(i).previous_payout_date < g_court_orders(i).interest_to_date2 THEN
                  g_court_orders(i).interest_from_date2 := NULL;
                ELSE
                  g_court_orders(i).interest_from_date2 := greatest(g_court_orders(i).previous_payout_date, g_court_orders(i).interest_from_date2);
                END IF;

              END IF;

           ELSIF NOT l_processing_first_time THEN
              g_court_orders(i).interest_from_date2 := greatest(g_court_orders(i).interest_from_date2, nvl(g_court_orders(i).previous_payout_date, l_period_start_date));
           END IF;
           ------------------
           -- Interest Band 3
           ------------------
           IF NOT (g_court_orders(i).interest_rate3 > 0                       AND
                   g_court_orders(i).interest_to_date3 IS NOT NULL            AND
                   g_court_orders(i).interest_from_date3 IS NOT NULL          AND
                   g_court_orders(i).interest_to_date3 >= nvl(g_court_orders(i).previous_payout_date, g_court_orders(i).interest_to_date3) AND
                   g_court_orders(i).interest_from_date3 <= g_court_orders(i).interest_to_date3)
           THEN
              g_court_orders(i).interest_from_date3 := NULL;

           ELSIF g_court_orders(i).interest_to_date3 < l_period_start_date THEN
              IF NOT l_processing_first_time THEN

                IF NOT g_court_orders(i).previous_payout_date < g_court_orders(i).interest_to_date3 THEN
                  g_court_orders(i).interest_from_date3 := NULL;
                ELSE
                  g_court_orders(i).interest_from_date3 := greatest(g_court_orders(i).previous_payout_date, g_court_orders(i).interest_from_date3);
                END IF;

              END IF;

           ELSIF NOT l_processing_first_time THEN
              g_court_orders(i).interest_from_date3 := greatest(g_court_orders(i).interest_from_date3, nvl(g_court_orders(i).previous_payout_date, l_period_start_date));
           END IF;
           ------------------
           -- Interest Band 4
           ------------------
           IF NOT (g_court_orders(i).interest_rate4 > 0                       AND
                   g_court_orders(i).interest_to_date4 IS NOT NULL            AND
                   g_court_orders(i).interest_from_date4 IS NOT NULL          AND
                   g_court_orders(i).interest_to_date4 >= nvl(g_court_orders(i).previous_payout_date, g_court_orders(i).interest_to_date4) AND
                   g_court_orders(i).interest_from_date4 <= g_court_orders(i).interest_to_date4)
           THEN
              g_court_orders(i).interest_from_date4 := NULL;

           ELSIF g_court_orders(i).interest_to_date4 < l_period_start_date THEN
              IF NOT l_processing_first_time THEN

                IF NOT g_court_orders(i).previous_payout_date < g_court_orders(i).interest_to_date4 THEN
                  g_court_orders(i).interest_from_date4 := NULL;
                ELSE
                  g_court_orders(i).interest_from_date4 := greatest(g_court_orders(i).previous_payout_date, g_court_orders(i).interest_from_date4);
                END IF;

              END IF;

           ELSIF NOT l_processing_first_time THEN
              g_court_orders(i).interest_from_date4 := greatest(g_court_orders(i).interest_from_date4, nvl(g_court_orders(i).previous_payout_date, l_period_start_date));
           END IF;
           ------------------
           -- Interest Band 5
           ------------------
           IF NOT (g_court_orders(i).interest_rate5 > 0                       AND
                   g_court_orders(i).interest_to_date5 IS NOT NULL            AND
                   g_court_orders(i).interest_from_date5 IS NOT NULL          AND
                   g_court_orders(i).interest_to_date5 >= nvl(g_court_orders(i).previous_payout_date, g_court_orders(i).interest_to_date5) AND
                   g_court_orders(i).interest_from_date5 <= g_court_orders(i).interest_to_date5)
           THEN
              g_court_orders(i).interest_from_date5 := NULL;

           ELSIF g_court_orders(i).interest_to_date5 < l_period_start_date THEN
              IF NOT l_processing_first_time THEN

                IF NOT g_court_orders(i).previous_payout_date < g_court_orders(i).interest_to_date5 THEN
                  g_court_orders(i).interest_from_date5 := NULL;
                ELSE
                  g_court_orders(i).interest_from_date5 := greatest(g_court_orders(i).previous_payout_date, g_court_orders(i).interest_from_date5);
                END IF;

              END IF;

           ELSIF NOT l_processing_first_time THEN
              g_court_orders(i).interest_from_date5 := greatest(g_court_orders(i).interest_from_date5, nvl(g_court_orders(i).previous_payout_date, l_period_start_date));
           END IF;

        EXCEPTION
           WHEN OTHERS THEN
             if g_debug then
	             hr_utility.set_location('Error in Interest Validation. Message : '||substr(sqlerrm,1,200), -20);
             end if;
             RAISE;

        END validate_interest_bands;
        -----------------------------------------------------------------

        --------------------------------------------------------------------------------------
        --Bug : 4498363
        -- Function returns 'Y' if the corresponding Provisional court order's start date of an
        -- 'Actual Seizure and Collection' court received after 28-JUL-2005 is greater than
        -- 28-JUL-2005
        --------------------------------------------------------------------------------------
	FUNCTION check_exception_case (p_prev_case_num IN VARCHAR2)
        RETURN VARCHAR2
        IS
           l_provisional_date		DATE;
           l_court_order_origin		VARCHAR2(30);
	   --
           cursor csr_get_provisional_date(p_prev_case_num IN VARCHAR2) is
                SELECT pee.effective_start_date,pee.entry_information24
		from	pay_element_entry_values_f  peev,
			pay_element_entries_f	    pee,
			pay_element_links_f	    pel,
                        pay_input_values_f          piv
		where	pel.element_type_id = l_element_type_id
                and     piv.element_type_id = l_element_type_id
                and     piv.element_type_id = pel.element_type_id
		and	p_date_earned between pel.effective_start_date and pel.effective_end_date
		and	p_date_earned between piv.effective_start_date and piv.effective_end_date
                and     peev.input_value_id = piv.input_value_id
		and	pee.element_link_id = pel.element_link_id
		and	pee.assignment_id = p_assignment_id
		and	nvl(pee.entry_type, 'E') = 'E'
		and	p_date_earned between pee.effective_start_date and pee.effective_end_date
		and	peev.element_entry_id = pee.element_entry_id
		and	peev.effective_start_date = pee.effective_start_date
		and	peev.effective_end_date = pee.effective_end_date
		and     piv.name = 'Case Number'
		and     peev.screen_entry_value = p_prev_case_num
                order by pee.effective_start_date;

         BEGIN
              OPEN csr_get_provisional_date(p_prev_case_num);
	      FETCH csr_get_provisional_date into l_provisional_date,l_court_order_origin;
              CLOSE csr_get_provisional_date;
              --
              IF l_provisional_date >= g_change_effective_date and l_court_order_origin = '01' THEN
                  RETURN 'Y';
              -- Bug 4680413
              -- If the date recieved for Provisional Court Order is after 28-APR-2006,then
              -- Court Order will follow new rule.
              ELSIF l_provisional_date >= g_change_eff_date_NTLA THEN
                  RETURN 'Y';
              ELSE
                  RETURN 'N';
              END IF;
	      if g_debug then
                hr_utility.trace('l_count_court_orders  '||l_count_court_orders);
                hr_utility.trace('p_assignment_id  '||p_assignment_id);
                hr_utility.trace('l_provisional_date  '||l_provisional_date);
	        hr_utility.trace('p_provisional_case_num  '||p_prev_case_num);
	     end if;
        END check_exception_case;

     --------------------------------------------------------------------------------------
     -- Procedure load_court_orders begins here
     --------------------------------------------------------------------------------------
     BEGIN

        OPEN  csr_etype('Wage Garnishments');
        FETCH csr_etype into l_element_type_id;
        CLOSE csr_etype;

        FOR i IN csr_wg(l_element_type_id)
        LOOP

           -- Element entry is a new court order if it has not already been loaded
           -- Load values in the same court order if element entry id is same as previously loaded

           IF (l_element_entry_id = 0) OR (l_element_entry_id <> i.element_entry_id) THEN

              l_court_order_no    := g_court_orders.count + 1;
              l_interest_loaded   := FALSE;
              l_element_entry_id  := i.element_entry_id;

              g_court_orders(l_court_order_no).court_order_start_date      := get_court_order_start_date(i.element_entry_id); --Bug : 4533467
              g_court_orders(l_court_order_no).previous_case_number        := ltrim(rtrim(i.previous_case_number));
              g_court_orders(l_court_order_no).interest_rate1              := to_number(nvl(i.interest_rate1,'0'));
              g_court_orders(l_court_order_no).interest_calculation_base1  := to_number(nvl(i.interest_base1,'0'));
              g_court_orders(l_court_order_no).interest_rate2              := to_number(nvl(i.interest_rate2,'0'));
              g_court_orders(l_court_order_no).interest_calculation_base2  := to_number(nvl(i.interest_base2,'0'));
              g_court_orders(l_court_order_no).interest_rate3              := to_number(nvl(i.interest_rate3,'0'));
              g_court_orders(l_court_order_no).interest_calculation_base3  := to_number(nvl(i.interest_base3,'0'));
              g_court_orders(l_court_order_no).interest_rate4              := to_number(nvl(i.interest_rate4,'0'));
              g_court_orders(l_court_order_no).interest_calculation_base4  := to_number(nvl(i.interest_base4,'0'));
              g_court_orders(l_court_order_no).interest_rate5              := to_number(nvl(i.interest_rate5,'0'));
              g_court_orders(l_court_order_no).interest_calculation_base5  := to_number(nvl(i.interest_base5,'0'));
	      g_court_orders(l_court_order_no).court_order_origin	   := nvl(i.court_order_origin,'01');

           ELSE
              l_court_order_no := g_court_orders.count;

           END IF;

           g_court_orders(l_court_order_no).element_entry_id := i.element_entry_id;

           IF upper(i.name) = 'ATTACHMENT SEQ NO' THEN
               g_court_orders(l_court_order_no).attachment_sequence_no := i.screen_entry_value;
               if g_debug then
		  hr_utility.trace('attachment_sequence_no'||g_court_orders(l_court_order_no).attachment_sequence_no);
	       end if;
	       -------------------------------------------------------------------
               -- RAISE error in attachment sequence number has already been used.
               -- This check will be run only once for a court order.
               -- Bug 2856663 : procedure call modified to include new parameter p_assignment_id
	       -------------------------------------------------------------------
               l_valid_attach_seq := attachment_seq_no_is_valid( p_assignment_id,
								 l_element_entry_id,
								 g_court_orders(l_court_order_no).attachment_sequence_no);
               --
               IF l_valid_attach_seq <> 'Y' THEN
                   p_curr_attach_seq_no := g_court_orders(l_court_order_no).attachment_sequence_no;
                   p_curr_case_number   := g_court_orders(l_court_order_no).case_number;
                   RAISE e_duplicate_attach_exception;
               END IF;

           ELSIF upper(i.name) = 'PROCESSING TYPE' THEN
               g_court_orders(l_court_order_no).processing_type := i.screen_entry_value;
               --------------------------------------------------------------------------------------
               --Bug : 4498363 Logic to check if a Provisional court order with start date before
               --28-JUL-2005 has received an Actual Seizure and Collection after 28-JUL-2005.
	       --------------------------------------------------------------------------------------
                IF g_court_orders(l_court_order_no).processing_type in ('AS', 'AA') AND g_court_orders(l_court_order_no).court_order_start_date >= g_change_effective_date THEN
                   l_check_condition := check_exception_case(g_court_orders(l_court_order_no).previous_case_number);
                   if l_check_condition = 'Y' then
                      l_count_court_orders := l_count_court_orders + 1;
                   end if;
		--------------------------------------------------------------------------------------
	        -- Bug 4498363
	        --
		--Logic to calculate the no. of court orders received after 28-JUL-2005
		--and from Individual/Organization.
		--------------------------------------------------------------------------------------
                ELSIF g_court_orders(l_court_order_no).court_order_start_date >= g_change_effective_date THEN
                   -- Bug 4680413
                   --Added condition to check for court orders after the effective Date 28-APR-2006
		   IF g_court_orders(l_court_order_no).court_order_start_date >= g_change_eff_date_NTLA THEN
                      l_count_court_orders := l_count_court_orders + 1;
                   ELSE
	   	      IF nvl(g_court_orders(l_court_order_no).court_order_origin,'01') = '01' then
			     l_count_court_orders := l_count_court_orders + 1;
                      END IF;
                   END IF;
                END IF;

           ELSIF upper(i.name) = 'PRINCIPAL BASE' THEN
               g_court_orders(l_court_order_no).principal_base := to_number(nvl(i.screen_entry_value,'0'));

           ELSIF upper(i.name) = 'COURT FEE BASE' THEN
               g_court_orders(l_court_order_no).court_fee_base := to_number(nvl(i.screen_entry_value,'0'));

           ELSIF upper(i.name) = 'INTEREST BASE' THEN
               g_court_orders(l_court_order_no).interest_base := to_number(nvl(i.screen_entry_value,'0'));

           ELSIF upper(i.name) = 'CASE NUMBER' THEN
               g_court_orders(l_court_order_no).case_number := i.screen_entry_value;

           ELSIF upper(i.name) = 'OBLIGATION RELEASE' THEN
               g_court_orders(l_court_order_no).obligation_release := nvl(i.screen_entry_value,'N');
	       --
               -- Bug 4866417
               -- An obligation release is considered to be processed if a run result with the value
               -- 'Y' is found for the Obligation release for this Court Order
               --
               g_court_orders(l_court_order_no).obligation_release_processed := nvl(is_oblig_release_processed(l_element_entry_id,l_element_type_id),'N');
               --
               -- This flag c_redistribution_required will be used by the main procedure
               -- to redistribute the Obligation Release amount only if at least one unprocessed
               -- Obligation Released court order is found.
               --
               if g_debug then
		  hr_utility.trace('obligation_release_processed  '||g_court_orders(l_court_order_no).obligation_release_processed);
		  hr_utility.trace('attachment_sequence_no'||g_court_orders(l_court_order_no).attachment_sequence_no);
	       end if;
	       --
               IF g_court_orders(l_court_order_no).obligation_release_processed = 'N' THEN
                  c_redistribution_required := 'Y';
               END IF;
	       --------------------------------------------------------------------------------------
               -- Changes for Bug 4498363
               -- Logic to check whether an Obligation release is received for Court Orders
               -- with start date less than 28-JUL-2005.
               --------------------------------------------------------------------------------------
	       IF g_court_orders(l_court_order_no).obligation_release = 'Y' THEN
                  --
	          IF (g_court_orders(l_court_order_no).court_order_start_date >= g_change_effective_date) THEN
                  -- Bug 4680413
                  -- Added logic to increment l_count_oblig_rel_after if the Court Order is from NTLA
                  -- after 28-APR-2006
                     IF (g_court_orders(l_court_order_no).court_order_start_date >= g_change_eff_date_NTLA) THEN
                     --
                        l_count_oblig_rel_after := l_count_oblig_rel_after + 1;
                     ELSE
                        IF nvl(g_court_orders(l_court_order_no).court_order_origin,'01') = '01' THEN
		           l_count_oblig_rel_after := l_count_oblig_rel_after + 1;
                        ELSE
                           l_count_oblig_rel_before := l_count_oblig_rel_before + 1;
                        END IF;
                     END IF;
                  ELSE
                    l_count_oblig_rel_before := l_count_oblig_rel_before + 1;
                  END IF;
                  if g_debug then
                    hr_utility.set_location('num of court orders which received obligation_release'||l_count_oblig_rel_before,310);
	          end if;
	       END IF;
           --
           -- Changes for Bug 2708036
           --
           ELSIF upper(i.name) = 'RECEPTION TIME' THEN
               g_court_orders(l_court_order_no).reception_time         := nvl(hr_chkfmt.changeformat(i.screen_entry_value, 'H_HHMM', null),'00:00');
               g_court_orders(l_court_order_no).court_order_start_date := to_date( ( to_char( g_court_orders(l_court_order_no).court_order_start_date, 'YYYY/MM/DD')
                                                                                            ||' '||g_court_orders(l_court_order_no).reception_time), 'YYYY/MM/DD HH24:MI');
           --
           END IF;

           ------------------------------------------------------------------------------------------
           -- Load Interest only after attachment seq no has been populated as attachment seq no
           -- is used while calling procedure processing_first_time (it sets the context for balance)
           ------------------------------------------------------------------------------------------
           -- Load interest calculation information only if interest base is not specified.
           -- This check is placed for performance reasons.
           -------------------------------------------------------------------------------
           -- Interest needs to be leaded only once for each court order
           -------------------------------------------------------------

           IF g_court_orders(l_court_order_no).attachment_sequence_no IS NOT NULL AND
              g_court_orders(l_court_order_no).interest_base = 0                  AND
              NOT l_interest_loaded
           THEN

              g_court_orders(l_court_order_no).interest_from_date1 := fnd_date.canonical_to_date(i.interest_from_date1);
              g_court_orders(l_court_order_no).interest_from_date2 := fnd_date.canonical_to_date(i.interest_from_date2);
              g_court_orders(l_court_order_no).interest_from_date3 := fnd_date.canonical_to_date(i.interest_from_date3);
              g_court_orders(l_court_order_no).interest_from_date4 := fnd_date.canonical_to_date(i.interest_from_date4);
              g_court_orders(l_court_order_no).interest_from_date5 := fnd_date.canonical_to_date(i.interest_from_date5);
              -------------------------------------------------------------------------------
              -- If interest_to_date is null, then populate payout_date-1 in interest_to_date
              -------------------------------------------------------------------------------
              g_court_orders(l_court_order_no).interest_to_date1   := nvl(fnd_date.canonical_to_date(i.interest_to_date1), l_payout_date-1);
              g_court_orders(l_court_order_no).interest_to_date2   := nvl(fnd_date.canonical_to_date(i.interest_to_date2), l_payout_date-1);
              g_court_orders(l_court_order_no).interest_to_date3   := nvl(fnd_date.canonical_to_date(i.interest_to_date3), l_payout_date-1);
              g_court_orders(l_court_order_no).interest_to_date4   := nvl(fnd_date.canonical_to_date(i.interest_to_date4), l_payout_date-1);
              g_court_orders(l_court_order_no).interest_to_date5   := nvl(fnd_date.canonical_to_date(i.interest_to_date5), l_payout_date-1);
              --------------------------------------------------------------------------------------
              -- Bug 2893245
              -- Previous Payout Date is now computed only for the interest rate based court orders.
              --------------------------------------------------------------------------------------
              g_court_orders(l_court_order_no).previous_payout_date := get_previous_payout_date(g_court_orders(l_court_order_no).element_entry_id,
                                                                                                g_court_orders(l_court_order_no).attachment_sequence_no);

              validate_interest_bands(l_court_order_no);

              l_interest_loaded := TRUE;
              if g_debug then
	              hr_utility.set_location('Attachment Sequence Number :  '||g_court_orders(l_court_order_no).attachment_sequence_no||

                                                            ' Band 1 : '||
                                                            ' '|| to_char(g_court_orders(l_court_order_no).interest_calculation_base1)||
                                                            ' '|| to_char(g_court_orders(l_court_order_no).interest_rate1)||
                                                            ' '|| to_char(g_court_orders(l_court_order_no).interest_from_date1)||
                                                            ' '|| to_char(g_court_orders(l_court_order_no).interest_to_date1),11);


	              hr_utility.set_location('Attachment Sequence Number :  '||g_court_orders(l_court_order_no).attachment_sequence_no||

                                                            ' Band 2 : '||
                                                            ' '|| to_char(g_court_orders(l_court_order_no).interest_calculation_base2)||
                                                            ' '|| to_char(g_court_orders(l_court_order_no).interest_rate2)||
                                                            ' '|| to_char(g_court_orders(l_court_order_no).interest_from_date2)||
                                                            ' '|| to_char(g_court_orders(l_court_order_no).interest_to_date2),21);

              	       hr_utility.set_location('Attachment Sequence Number :  '||g_court_orders(l_court_order_no).attachment_sequence_no||
                                                            ' Band 3 : '||
                                                            ' '|| to_char(g_court_orders(l_court_order_no).interest_calculation_base3)||
                                                            ' '|| to_char(g_court_orders(l_court_order_no).interest_rate3)||
                                                            ' '|| to_char(g_court_orders(l_court_order_no).interest_from_date3)||
                                                            ' '|| to_char(g_court_orders(l_court_order_no).interest_to_date3),31);

                        hr_utility.set_location('Attachment Sequence Number :  '||g_court_orders(l_court_order_no).attachment_sequence_no||
                                                            ' Band 4 : '||
                                                            ' '|| to_char(g_court_orders(l_court_order_no).interest_calculation_base4)||
                                                            ' '|| to_char(g_court_orders(l_court_order_no).interest_rate4)||
                                                            ' '|| to_char(g_court_orders(l_court_order_no).interest_from_date4)||
                                                            ' '|| to_char(g_court_orders(l_court_order_no).interest_to_date4),41);

              		hr_utility.set_location('Attachment Sequence Number :  '||g_court_orders(l_court_order_no).attachment_sequence_no||
                                                            ' Band 5 : '||
                                                            ' '|| to_char(g_court_orders(l_court_order_no).interest_calculation_base5)||
                                                            ' '|| to_char(g_court_orders(l_court_order_no).interest_rate5)||
                                                            ' '|| to_char(g_court_orders(l_court_order_no).interest_from_date5)||
                                                       ' '|| to_char(g_court_orders(l_court_order_no).interest_to_date5),51);
                  end if;

           END IF; -- interest loaded

        END LOOP;
	--------------------------------------------------------------------------------------
        -- Bug : 4498363
        -- Logic to check if an exceptional condition of court orders has been met
        -- and if whether in such a condition obligation release has been received by
        -- court orders with start date before 28-JUL-2005.
        --------------------------------------------------------------------------------------
	IF  (l_count_court_orders = 0) OR (l_count_court_orders = g_court_orders.count) then
		 g_excpn_court_order_flag :='N';
	ELSE
	    IF ((l_count_oblig_rel_before >= 1) AND (l_count_oblig_rel_before = (g_court_orders.count-l_count_court_orders)))
               OR ((l_count_oblig_rel_after >= 1) AND (l_count_oblig_rel_after = l_count_court_orders)) then
		 g_excpn_court_order_flag :='N';
	    ELSE
		 g_excpn_court_order_flag :='Y';
	    END IF;
	END IF;
        if g_debug then
	  hr_utility.trace('l_count_oblig_rel_before  '||l_count_oblig_rel_before);
	  hr_utility.trace('l_count_oblig_rel_after  '||l_count_oblig_rel_after);
        end if;
        --
     EXCEPTION
        WHEN OTHERS THEN
          if g_debug then
	          hr_utility.set_location('Error in loading court orders. Message : '||substr(sqlerrm,1,200), -30);
          end if;
          RAISE;

     END load_court_orders;

     ------------------------------------------------------------------------------------------------------------
     -- Function to calculate net earnings (BUG : 4498363)
     ------------------------------------------------------------------------------------------------------------
     FUNCTION calc_net_earnings(p_net_earnings			NUMBER,
				p_wg_attach_earnings_mtd	NUMBER,
				p_wg_deductions_mtd		NUMBER,
				p_date_paid			DATE)
     RETURN NUMBER
     IS
       l_net_earnings_mtd	 NUMBER  := 0;
       l_deductable_earnings_mtd NUMBER  := 0;
       l_new_rule_earnings       NUMBER  := 0;
       l_old_rule_earnings       NUMBER  := 0;
       l_deductable_amount       NUMBER  := 0;
     BEGIN
        if g_debug then
           hr_utility.trace('calc_net_earnings : p_net_earnings'||to_char(p_net_earnings) );
           hr_utility.trace('calc_net_earnings : p_date_paid'||to_char(p_date_paid) );
           hr_utility.trace('calc_net_earnings : l_count_court_orders'||to_char(l_count_court_orders) );
           hr_utility.trace('calc_net_earnings : p_wg_attach_earnings_mtd'||to_char(p_wg_attach_earnings_mtd) );
           hr_utility.trace('calc_net_earnings : p_wg_deductions_mtd'||to_char(p_wg_deductions_mtd) );
	end if;
        l_old_rule_earnings := p_net_earnings * g_max_attachable_earnings;
	--
	IF p_date_paid >= g_change_effective_date and l_count_court_orders > 0 then  --After 28-JUL-2005
	 --
		l_net_earnings_mtd        := p_wg_attach_earnings_mtd;
		l_deductable_earnings_mtd := l_net_earnings_mtd * g_max_attachable_earnings;
		--
		IF  l_deductable_earnings_mtd < g_min_undeduct_amt then
		    l_new_rule_earnings := greatest(l_net_earnings_mtd - g_min_undeduct_amt, 0);
	        ELSIF l_deductable_earnings_mtd >= g_base_undeduct_amt then
		    l_new_rule_earnings := l_net_earnings_mtd - (greatest(g_base_undeduct_amt, (g_base_undeduct_amt + (l_deductable_earnings_mtd - g_base_undeduct_amt)/2)));
		ELSE
		    l_new_rule_earnings := l_deductable_earnings_mtd;
		END IF;
		--
		IF g_excpn_court_order_flag = 'Y' THEN
		  l_deductable_amount := greatest(l_new_rule_earnings, l_old_rule_earnings, 0);
		ELSE
		  l_deductable_amount := greatest(l_new_rule_earnings, 0);
		END IF;
		--
		IF p_wg_attach_earnings_mtd > p_net_earnings then
		    l_deductable_amount := greatest(l_deductable_amount - p_wg_deductions_mtd, 0);
		END IF;
		--
		if g_debug then
                   hr_utility.trace('calc_net_earnings : l_deductable_amount'||to_char(l_deductable_amount) );
		end if;
		return l_deductable_amount;
	ELSE						--Before 28-JUL-2005
		if g_debug then
                   hr_utility.trace('calc_net_earnings : l_old_rule_earnings'||to_char(l_old_rule_earnings) );
		end if;
	        return l_old_rule_earnings;
	END IF;
     END calc_net_earnings;

     ------------------------------------------------------------------------------------------------------------
     -- Procedure to calculate real attachment total
     ------------------------------------------------------------------------------------------------------------
     -- This procedure is called from the main procedure.
     -- In normal processing, this procedure will be called only once.
     -- But in case when an All Attachment was in process and some amount is available in wg_attachable_earnings
     --    after fully paying All Attachment, in such cases the unused amount will be distributed among the court
     --    orders suspended because of the All Attachment.
     -- For such court orders this procedure is again called from after_all_attachment
     --
     -- Care must be taken in this procedure with flags c_all_attach_full_paid and c_waiting_for_all_attach which
     --    are used to  signal such events.
     ------------------------------------------------------------------------------------------------------------
     PROCEDURE calc_real_attachment_total
     IS
       l_interest                  NUMBER  := 0;
       l_interest_to_date          DATE;
       l_no_of_actual_attachments  NUMBER  := 0;

     BEGIN


       IF g_court_orders.count > 0 THEN

         FOR i in 1..g_court_orders.last
         LOOP
            if g_debug then
	            hr_utility.set_location('Attachment Sequence : '||g_court_orders(i).attachment_sequence_no,12);
            end if;
            --
            IF nvl(g_court_orders(i).stop_flag, 'N') <> 'Y' THEN

               -----------------------------------------------------------------------------------------------
               -- Setting flags for Actual Attachment and All Attachment
               -----------------------------------------------------------------------------------------------

               -- This check is placed to avoid setting the flag during after all attachment run

               IF NOT c_all_attach_full_paid ='Y' THEN

                  -- Set flags for All attachment.
                  -- Two types of All Attachment are possible. 1. All Attachment     2. Actual All Attachment

                  IF g_court_orders(i).processing_type IN ('A','AA') THEN

                      -- RAISE error if an All Attachment is already processing.

                      IF c_all_attachment = 'Y' THEN
                         p_curr_attach_seq_no := g_court_orders(i).attachment_sequence_no;
                         p_curr_case_number   := g_court_orders(i).case_number;
                         RAISE e_all_attachment_exception;
                      END IF;

                      c_all_attachment   := 'Y';

                      d_all_attach_date  := g_court_orders(i).court_order_start_date;

                  END IF;

                  -- Set flags for actual attachment.
                  -- Two types of actual Attachment are possible. 1. Actual Seizure and Collection     2. Actual All Attachment

                  IF g_court_orders(i).processing_type IN ('AS','AA') THEN

                      l_no_of_actual_attachments := g_actual_attach.count + 1;

                      c_actual_attachment      := 'Y';
                      g_actual_attach(l_no_of_actual_attachments).d_actual_attach_date := g_court_orders(i).court_order_start_date;

                      -- If previous case number is not specified then RAISE error

                      IF g_court_orders(i).previous_case_number IS NULL THEN
                         p_curr_attach_seq_no := g_court_orders(i).attachment_sequence_no;
                         p_curr_case_number   := g_court_orders(i).case_number;
                         RAISE e_prev_case_notfound_exception;
                      END IF;

                      g_actual_attach(l_no_of_actual_attachments).c_actual_attach_prev_case  := g_court_orders(i).previous_case_number;

                  END IF;
               END IF; -- c_all_attach_full_paid

               -----------------------------------------------------------------------------------------------
               -- End of setting flags
               -----------------------------------------------------------------------------------------------

               -- Now calculating Real Attachment Total

               -----------------------------------------------------------------------------------------------
               -- Obligation Release has the highest priority for all court orders
               -- Do not calculate real attachment total for those court orders for which obligation release has come
               -- For all other court orders calculate real attachment total
               -----------------------------------------------------------------------------------------------

               IF (g_court_orders(i).obligation_release = 'N') OR (g_court_orders(i).obligation_release IS NULL) THEN

                  --------------------------------------------------------------------------------------------
                  -- For court orders for which are not Obligation Released, All Attachment has the highest priority.
                  --
                  -- If an All Attachment has come then court orders with court_order_start_date later than All Attachment
                  --    will not be processed in this run.
                  -- If there is any such court order, flag c_waiting_for_all_attach will be set.
                  -- Such court orders are processed only after All Attachment is fully paid.
                  --
                  -- And if no All Attachment has come then, process all court orders.
                  --------------------------------------------------------------------------------------------

                  IF c_all_attachment = 'N' OR
                     (c_all_attachment = 'Y' AND g_court_orders(i).court_order_start_date <= d_all_attach_date) OR
                     g_court_orders(i).processing_type IN ('A' , 'AA') OR
                     c_all_attach_full_paid = 'Y'
                  THEN
                     ------------------------------------------------------------------
                     -- A court order specifies either interest rate or interest base
                     --
                     -- Bug 2715287
                     -- However if neither interest base nor interest rate is specified
                     --   then court order will follow the interest base processing.
                     -- Bug 2860586
                     -- interest_rate is used to identify interest rate based court orders.
                     ----------------------------------------------------------------------

                     IF (g_court_orders(i).interest_rate1 > 0  OR
                         g_court_orders(i).interest_rate2 > 0  OR
                         g_court_orders(i).interest_rate3 > 0  OR
                         g_court_orders(i).interest_rate4 > 0  OR
                         g_court_orders(i).interest_rate5 > 0  )
                     THEN                                                         -- Interest Rate case

                        -- Attachment Total Base = Principal Base + Court Fee Base

                        g_court_orders(i).attachment_total_base := g_court_orders(i).principal_base +
                                                                   g_court_orders(i).court_fee_base ;
                        ---------------------------------------------------------------------------------
                        -- Calculating Interest this period
                        ---------------------------------------------------------------------------------

                        IF g_court_orders(i).interest_from_date1 is not null AND
                           g_court_orders(i).interest_calculation_base1 > 0
                        THEN
                           l_interest := l_interest + round(g_court_orders(i).interest_calculation_base1 * g_court_orders(i).interest_rate1 *
                                                               ((g_court_orders(i).interest_to_date1 - g_court_orders(i).interest_from_date1 + 1)/365) / 100);
                        END IF;

                        IF g_court_orders(i).interest_from_date2 is not null AND
                           g_court_orders(i).interest_calculation_base2 > 0
                        THEN
                           l_interest := l_interest + round(g_court_orders(i).interest_calculation_base2 * g_court_orders(i).interest_rate2 *
                                                               ((g_court_orders(i).interest_to_date2 - g_court_orders(i).interest_from_date2 + 1)/365) / 100);
                        END IF;

                        IF g_court_orders(i).interest_from_date3 is not null AND
                           g_court_orders(i).interest_calculation_base3 > 0
                        THEN
                           l_interest := l_interest + round(g_court_orders(i).interest_calculation_base3 * g_court_orders(i).interest_rate3 *
                                                               ((g_court_orders(i).interest_to_date3 - g_court_orders(i).interest_from_date3 + 1)/365) / 100);
                        END IF;

                        IF g_court_orders(i).interest_from_date4 is not null AND
                           g_court_orders(i).interest_calculation_base4 > 0
                        THEN
                           l_interest := l_interest + round(g_court_orders(i).interest_calculation_base4 * g_court_orders(i).interest_rate4 *
                                                               ((g_court_orders(i).interest_to_date4 - g_court_orders(i).interest_from_date4 + 1)/365) / 100);
                        END IF;

                        IF g_court_orders(i).interest_from_date5 is not null AND
                           g_court_orders(i).interest_calculation_base5 > 0
                        THEN
                           l_interest := l_interest + round(g_court_orders(i).interest_calculation_base5 * g_court_orders(i).interest_rate5 *
                                                               ((g_court_orders(i).interest_to_date5 - g_court_orders(i).interest_from_date5 + 1)/365) / 100);
                        END IF;
                        g_court_orders(i).interest_amount := l_interest;

                        l_interest         := 0;
                        --------------------------------------------------------------------------
                        -- End of interest calculation
                        --------------------------------------------------------------------------

                        -- Real Attachment Total = Attachment Total Base + Total Prepaid Interest + Interest this period

                        g_court_orders(i).real_attach_total_by_creditor := g_court_orders(i).attachment_total_base + g_court_orders(i).interest_amount +
                                         nvl(pay_kr_wg_report_pkg.paid_interest(p_assignment_id , g_court_orders(i).element_entry_id , p_date_earned ),0) ;

                     ELSE -- Interest Base Case
                        --------------------------------------------------------------------------
                        -- Attachment Total Base = Principal Base + Court Fee Base + Interest Base
                        -- Real Attachment Total = Attachment Total Base  -- Bug 2713144
                        --------------------------------------------------------------------------

                        g_court_orders(i).attachment_total_base := g_court_orders(i).principal_base +
                                                                   g_court_orders(i).court_fee_base +
                                                                   g_court_orders(i).interest_base ;

                        g_court_orders(i).real_attach_total_by_creditor := g_court_orders(i).attachment_total_base;

                     END IF;

                  END IF; -- All Attachment

               END IF; -- Obligation Release
               if g_debug then
	               hr_utility.set_location('Real Attachment Total By Creditor : '||to_CHAR(g_court_orders(i).real_attach_total_by_creditor),22);
	               hr_utility.set_location('Interest Amount for this Creditor : '||to_CHAR(g_court_orders(i).interest_amount),32);
        	       hr_utility.set_location('Attachment Total Base             : '||to_CHAR(g_court_orders(i).attachment_total_base),42);
                end if;
            END IF; -- Stop Flag

          END LOOP;

        END IF; -- Count

     EXCEPTION
        WHEN OTHERS THEN
          if g_debug then
	          hr_utility.set_location('Error in calculating Real Attachment Total. '||substr(sqlerrm,1,200), -40);
          end if;
          RAISE;

     END calc_real_attachment_total;

     ------------------------------------------------------------------------------------------------------------
     -- Procedure to calculate employee attachment total
     ------------------------------------------------------------------------------------------------------------
     -- This procedure is called from the main procedure.
     -- In normal processing, this procedure will be called only once.
     -- But in case when an All Attachment was in process and some amount is available in wg_attachable_earnings
     --    after fully paying All Attachment, in such cases the unused amount will be distributed among the court
     --    orders suspended because of the All Attachment.
     -- For such court orders this procedure is again called from after_all_attachment
     --
     -- Care must be taken in this procedure with flags c_all_attach_full_paid and c_waiting_for_all_attach which
     --    are used to  signal such events.
     -------------------------------------------------------------------------------------------------------------
     PROCEDURE calc_emp_attachment_total
     IS

        -------------------------------------------------------------------------
        -- Function to compare previous case numbers in case of Actual Attachment
        -------------------------------------------------------------------------
        FUNCTION case_number_matches(p_case_number	    IN		VARCHAR2,
				     p_court_order_type     IN		VARCHAR2
				     ) RETURN BOOLEAN
        IS
          b_case_number_matches     BOOLEAN := FALSE;

        BEGIN

           IF p_court_order_type = 'ACT' THEN
             IF g_actual_attach.count > 0 THEN
                FOR i in 1..g_actual_attach.last LOOP
                   IF p_case_number = g_actual_attach(i).c_actual_attach_prev_case THEN
                      g_actual_attach(i).c_actual_attach_case_found := 'Y';
                      b_case_number_matches := TRUE;
                      EXIT;
                   END IF;
                 END LOOP;
              END IF;
           END IF; -- Court Order Type = 'ACT'

           RETURN b_case_number_matches;

        END case_number_matches;
        --------------------------------------------------------------------
     BEGIN
       IF g_court_orders.count > 0 THEN

         FOR i in 1..g_court_orders.last
         LOOP
            if g_debug then
	            hr_utility.set_location('Attachment Sequence : '||g_court_orders(i).attachment_sequence_no,13);
            end if;
	    --
            IF nvl(g_court_orders(i).stop_flag, 'N') <> 'Y' THEN

               -- Calculate Employee Attachment total for attachments not affected by obligation release

               IF (g_court_orders(i).obligation_release = 'N') OR (g_court_orders(i).obligation_release IS NULL) THEN

                  -----------------------------------------------------------------
                  -- If no all attachment has come.
                  -- Or this is the all attachment
                  -- Or this attachment came before all attachment
                  -- Or All Attachment is fully paid and still money is avilable
                  -----------------------------------------------------------------

                  IF c_all_attachment = 'N' OR
                     (c_all_attachment = 'Y' AND g_court_orders(i).court_order_start_date <= d_all_attach_date) OR
                     g_court_orders(i).processing_type IN ('A' ,'AA') OR
                     c_all_attach_full_paid ='Y'
                  THEN

                     ---------------------------------------------------------------------------------
                     -- For those attachments not affected by obligation release or All Attachment,
                     --    Actual Attachment has the highest priority.
                     -- If an Actual Attachment comes, then it specifies the previous case number.
                     -- The court order with case number same as previous case number stops processing.
                     --
                     -- For all other court orders processing is as normal.
                     ---------------------------------------------------------------------------------

                     IF (c_actual_attachment = 'Y') AND
                        case_number_matches(g_court_orders(i).case_number, 'ACT')
                     THEN

                        --
                        g_court_orders(i).emp_attach_total_by_creditor := 0;
                        g_court_orders(i).stop_flag := 'Y';
                        g_court_orders(i).out_message := 'PAY_KR_WG_ACTUAL_ATTACH_MSG';

                     ELSE  -- Court orders not affected by actual attachment.

                        ------------------------------------------------------------------------------
                        -- Bug 2860586
                        -- interest_rate is used to identify interest rate based court orders.
                        ----------------------------------------------------------------------

                        IF (g_court_orders(i).interest_rate1 is not null  OR
                            g_court_orders(i).interest_rate2 is not null  OR
                            g_court_orders(i).interest_rate3 is not null  OR
                            g_court_orders(i).interest_rate4 is not null  OR
                            g_court_orders(i).interest_rate5 is not null )
                        THEN                                                        -- Interest Rate case.

                           -- Employee attachment total = Real Attachment Total - Prepaid Debt

                           g_court_orders(i).emp_attach_total_by_creditor := g_court_orders(i).real_attach_total_by_creditor -
                                 nvl(pay_kr_wg_report_pkg.paid_amount(p_assignment_id , g_court_orders(i).element_entry_id, p_date_earned ),0);

                           -- Bug 2713144 Distribution Base = Real Attachment Total By Creditor

                           g_court_orders(i).distribution_base := g_court_orders(i).real_attach_total_by_creditor;

                        ELSE -- Interest Base case.

                           -- Employee attachment total = Real Attachment Total - Prepaid Debt -- Bug 2713144

                           g_court_orders(i).emp_attach_total_by_creditor := g_court_orders(i).real_attach_total_by_creditor -
                                nvl(pay_kr_wg_report_pkg.paid_amount(p_assignment_id , g_court_orders(i).element_entry_id, p_date_earned ),0);

                           -- Bug 2713144 Distribution Base = Real Attachment Total

                           g_court_orders(i).distribution_base := g_court_orders(i).real_attach_total_by_creditor;

                        END IF;

                     END IF;   -- Actual Attachment
                     -----------------------------------------------------------------------------------------------
                     -- Resetting PAY_KR_WG_ALL_ATTACH_MSG message because earnings are available in the current run
                     -- to process attachments after All Attachment
                     -----------------------------------------------------------------------------------------------

                     IF c_all_attach_full_paid = 'Y' THEN
                        g_court_orders(i).out_message := 'XYZ';
                     END IF;

                  ELSE -- All Attachment
                     -- If all attachment is processing then do not process any new attachment

                     g_court_orders(i).real_attach_total_by_creditor :=  0 ;
                     g_court_orders(i).interest_amount               :=  0 ;
                     g_court_orders(i).attachment_total_base         :=  0 ;
                     g_court_orders(i).emp_attach_total_by_creditor  :=  0;
                     c_waiting_for_all_attach                        := 'Y';
                     g_court_orders(i).out_message                   := 'PAY_KR_WG_ALL_ATTACH_MSG';

                  END IF; -- All Attachment

                  -- Processing for the attachment for which obligation release has come.

               ELSE -- Obligation Release

                  g_court_orders(i).real_attach_total_by_creditor :=  0 ;
                  g_court_orders(i).interest_amount               :=  0 ;
                  g_court_orders(i).attachment_total_base         :=  0 ;
                  c_obligation_release                            := 'Y';
                  g_court_orders(i).emp_attach_total_by_creditor  :=  0;
                  g_court_orders(i).out_message                   := 'PAY_KR_WG_OBLIG_RELEASE_MSG';
		  g_court_orders(i).stop_flag                     := 'Y';   -- Bug : 4498363

                  -- Caclulate wage garnishment adjustment.
                  -- Adjustment is applicable only in case of Provisional Attachment

                  IF g_court_orders(i).processing_type = 'P' THEN

                     -- Calculate wage garnishment adjustment amount for this obligation release
                     -- And calculate total wage garnishment adjustment amount for all obligation releases
                     -- Bug 4866417
                     -- Redistrubution amount should be calcualted only if obligation release
                     -- has not earlier been processed.
                     --
                     IF g_court_orders(i).obligation_release_processed = 'N' THEN -- 4866417
                     	g_court_orders(i).wg_adjustment_amount := nvl(pay_kr_wg_report_pkg.paid_amount(p_assignment_id, g_court_orders(i).element_entry_id, p_date_earned ),0);
                     	g_emp_total.wg_adjustment              := g_emp_total.wg_adjustment + g_court_orders(i).wg_adjustment_amount;
                     END IF;
                     --
                     if g_debug then
	                hr_utility.set_location('WG Adjustment amount ' || to_char(g_emp_total.wg_adjustment),23);
	             end if;

                  END IF;

               END IF; -- Obligation Release

               g_emp_total.emp_attach_total  := g_emp_total.emp_attach_total  + g_court_orders(i).emp_attach_total_by_creditor ;
               -- Bug 2713144
               g_emp_total.distribution_base := g_emp_total.distribution_base + g_court_orders(i).distribution_base;

            END IF;
               if g_debug then
	               hr_utility.set_location('Employee Attachment Total : '|| to_char(g_court_orders(i).emp_attach_total_by_creditor),33);
               end if;
         END LOOP;
         --
         if g_debug then
	         hr_utility.set_location('Employee Attachment Total for all creditors: '|| to_char(g_emp_total.emp_attach_total),43);
         end if;
       END IF; -- g_court_orders.count > 0

     EXCEPTION
        WHEN OTHERS THEN
          if g_debug then
	          hr_utility.set_location('Error in calculating Employee Attachment Total. '||substr(sqlerrm,1,200), -50);
          end if;
          RAISE;
     END calc_emp_attachment_total;

     -----------------------------------------------------------
     -- Procedure to distribute the current employee paid amount
     -----------------------------------------------------------
     PROCEDURE distribute_paid_amt(p_distribution_amount number, p_distribute_actual_flag char, p_adj_pay_flag char)
     IS
         -- Bug 2926020

         l_unpaid_amount     NUMBER := 0;
         l_leftover_amount   NUMBER := 0;

         l_temp        NUMBER := 0;
         l_temp_total  NUMBER := 0;
         l_correction  NUMBER := 0;

     BEGIN
       if g_debug then
       		hr_utility.set_location('Inside distribute_paid_amt',14);
       end if;
       IF g_court_orders.count > 0 THEN

         FOR i in 1..g_court_orders.last
         LOOP
            if g_debug then
	            hr_utility.set_location('Attachment Sequence '||g_court_orders(i).attachment_sequence_no,24);
            end if;

            IF nvl(g_court_orders(i).stop_flag, 'N') <> 'Y' THEN

               -----------------------------------------------------------------------------------------------
               -- Distribute amount to all attachments not affected by obligation release and All Attachment
               -- Court Orders affected by Actual Attachment have already been stopped in emp_attachment_total
               -----------------------------------------------------------------------------------------------

               IF (g_court_orders(i).obligation_release = 'N') OR (g_court_orders(i).obligation_release IS NULL) THEN

                  IF c_all_attachment = 'N' OR
                     (c_all_attachment = 'Y' AND g_court_orders(i).court_order_start_date <= d_all_attach_date) OR
                     g_court_orders(i).processing_type IN ('A' , 'AA') OR
                     c_all_attach_full_paid = 'Y'
                  THEN

                    -----------------------------------------------------------------------------------------------
                    -- Distribute Logic Begins here
                    -- Distribution will take place only if available amount is less than employee attachment total
                    -- Otherwise actual amounts will be paid.
                    -----------------------------------------------------------------------------------------------

                    IF g_court_orders(i).emp_attach_total_by_creditor > 0 THEN

                      IF p_distribute_actual_flag = 'D' THEN

                        -- This check is placed to avoid divide by zero error in case of wg adjustment distribution

                        IF g_emp_total.emp_attach_total > 0 THEN
                            ----------------------------------------------------------------------------------
                            -- Bug 2713144 : In case of redistribution distribution rate should be calculated
                            --               on the basis of Employee Attachment Total
                            -- Bug 2926020 : trunc is used instead of round in calculating distribution rate
                            --               and curr_emp_paid_amt_by_creditor
                            ----------------------------------------------------------------------------------

                            IF p_adj_pay_flag = 'A' THEN
                               g_court_orders(i).distribution_rate := trunc(( g_court_orders(i).emp_attach_total_by_creditor / ( g_emp_total.emp_attach_total - l_correction_amount ) ), 15);
                            ELSE
                               g_court_orders(i).distribution_rate := trunc(( g_court_orders(i).distribution_base / ( g_emp_total.distribution_base - l_correction_amount ) ), 15);
                            END IF;

                            -------------------------------------------------------------------------------
                            -- If calculated distribution amount is more than the outstanding amount then
                            -- Pay only the outstanding amount and redistribute the difference amount among
                            -- other outstanding court orders.
                            --------------------------------------------------------------------------------
                            -- While redistributing the excess amount emp_attach_total for such court orders
                            -- must be excluded from distribution rate calculations.
                            -------------------------------------------------------------------------------
                            -- l_temp       = Excess Paid Amount for a court order.
                            -- l_temp_total = Total Excess Paid Amount for all court orders.
                            -- l_correction = Sum of employee attachment totals for all such court orders.
                            -- Bug 3048774  = curr_emp_paid_amt_by_creditor should be deducted while calculating
                            --                Outstanding amount in the recursive runs.
                            -------------------------------------------------------------------------------

                            l_temp := trunc(g_court_orders(i).distribution_rate * p_distribution_amount) - (g_court_orders(i).emp_attach_total_by_creditor -  g_court_orders(i).wg_adjusted_amount - g_court_orders(i).curr_emp_paid_amt_by_creditor);

                            IF l_temp > 0 THEN
                               -- Pay Only the outstanding amount.
                               g_court_orders(i).curr_emp_paid_amt_by_creditor := g_court_orders(i).emp_attach_total_by_creditor - g_court_orders(i).wg_adjusted_amount;

                               l_temp_total := l_temp_total + l_temp;

                               IF p_adj_pay_flag = 'A' THEN
                                  l_correction := l_correction + g_court_orders(i).emp_attach_total_by_creditor;
                               ELSE
                                  l_correction := l_correction + g_court_orders(i).distribution_base;
                               END IF;

                            ELSE
                               ------------------------------------------------------------------------------------
                               -- curr_emp_paid_amt_by_creditor = curr_emp_paid_amt_by_creditor + correction amount
                               -- (correction amount resulted from excess distribution for some other court order)
                               ------------------------------------------------------------------------------------
                               g_court_orders(i).curr_emp_paid_amt_by_creditor := g_court_orders(i).curr_emp_paid_amt_by_creditor + trunc(g_court_orders(i).distribution_rate * p_distribution_amount);

                            END IF;

                            -- Bug 2926020
                            l_leftover_amount := l_leftover_amount + trunc(g_court_orders(i).distribution_rate * p_distribution_amount);

                        ELSE
                            g_court_orders(i).distribution_rate := 0;
                        END IF;
                        if g_debug then
	                        hr_utility.set_location('Distribution Rate : ' || to_char(g_court_orders(i).distribution_rate),34);
        	                hr_utility.set_location('p_distribution_amount : '|| to_char(p_distribution_amount),44);
                        end if;
                      ELSE
                        g_court_orders(i).curr_emp_paid_amt_by_creditor := g_court_orders(i).emp_attach_total_by_creditor -  g_court_orders(i).wg_adjusted_amount;

                      END IF;

                    END IF;

                    ----------------------
                    -- End of Distribution
                    ----------------------
                    if g_debug then
	                    hr_utility.set_location('g_court_orders(i).curr_emp_paid_amt_by_creditor : '||to_char(g_court_orders(i).curr_emp_paid_amt_by_creditor),54);
	                    hr_utility.set_location('g_court_orders(i).emp_attach_total_by_creditor  : '||to_char(g_court_orders(i).emp_attach_total_by_creditor),64);
        	            hr_utility.set_location('g_court_orders(i).wg_adjusted_amount            : '||to_char(g_court_orders(i).wg_adjusted_amount),74);
                    end if;
                    ---------------------------------------------------------------
                    -- Setting flags if full amount has been paid for a court order
                    ---------------------------------------------------------------

                    IF g_court_orders(i).curr_emp_paid_amt_by_creditor = g_court_orders(i).emp_attach_total_by_creditor -  g_court_orders(i).wg_adjusted_amount THEN

                       --------------------------------------------------------------------------------------------
                       -- This check is placed to avoid setting stop_flag for attachments came after All Attachment
                       -- Since such attachments are not prcessed, they should not be stopped.
                       --------------------------------------------------------------------------------------------

                       IF g_court_orders(i).emp_attach_total_by_creditor > 0 THEN
			  if g_debug then
	                          hr_utility.set_location('Setting stop flag...................',84);
			  end if;
                          g_court_orders(i).stop_flag   := 'Y';
                       END IF;

                       --------------------------------------------------------------------------------------------
                       -- Check placed to set flag if All Attachment is fully paid
                       -- If this flag is set, Attachments coming after All Attachment will be processed if
                       -- earnings are available after paying All Attachment
                       --------------------------------------------------------------------------------------------

                       IF g_court_orders(i).processing_type IN ('A' , 'AA') THEN
                          c_all_attach_full_paid := 'Y';
                       END IF;

                       --------------------------------------------------------------------------------------------
                       -- This check is placed to avoid changing the message in case of provisional attachment
                       -- overridden by actual attachment
                       --------------------------------------------------------------------------------------------

                       IF g_court_orders(i).curr_emp_paid_amt_by_creditor > 0 THEN
                          g_court_orders(i).out_message := 'PAY_KR_WG_FUL_DEBT_PAID_MSG';
                       END IF;

                    END IF;
                    -----------------------
                    -- End of Setting flags
                    -----------------------

                    -----------------------------------------------------------------------------
                    -- Set the value of wage garnishment adjustment in case of obligation release
                    -----------------------------------------------------------------------------
                    IF p_adj_pay_flag = 'A' THEN

                       g_court_orders(i).wg_adjusted_amount := g_court_orders(i).wg_adjusted_amount + g_court_orders(i).curr_emp_paid_amt_by_creditor;

                       g_emp_total.wg_adjusted := g_emp_total.wg_adjusted + g_court_orders(i).wg_adjusted_amount;

                       ----------------------------------------------------------------------------------------------
                       -- Either curr_emp_paid_amt_by_creditor or wg_adjusted_amount should hold value for a creditor
                       ----------------------------------------------------------------------------------------------
                       g_court_orders(i).curr_emp_paid_amt_by_creditor := 0;

                    END IF;

                    if g_debug then
	                    hr_utility.set_location('g_court_orders(i).curr_emp_paid_amt_by_creditor : '||to_char(g_court_orders(i).curr_emp_paid_amt_by_creditor),94);
                	    hr_utility.set_location('g_court_orders(i).emp_attach_total_by_creditor  : '||to_char(g_court_orders(i).emp_attach_total_by_creditor),104);
        	            hr_utility.set_location('g_court_orders(i).wg_adjusted_amount            : '||to_char(g_court_orders(i).wg_adjusted_amount),114);
                     end if;
                  END IF; -- All Attachment

               ELSE -- Obligation Release

                  g_court_orders(i).curr_emp_paid_amt_by_creditor := 0;

               --Bug : 4498363
               --Removed stop_flag and placed in calc_emp_attachment_total since it is required
               --prior to distribution

               END IF; -- Obligation Release
               --------------------------------------------------------------------------
               -- Set the stop flag for separation pay run
               -- Bug 2657588 - Court Order should not be stopped for interim separation.
	       -- Bug 4866417 - Below logic has been moved to the end of this procedure
               --------------------------------------------------------------------------
            END IF; -- stop flag
         END LOOP;

         ----------------------------------------------------------------------------------------------------
         -- Correction Logic for cases when calculated distribution amount is greater than outstanding amount
	 -- If the correction is required because of excess paid amounts then while doing corrections]
	 -- leftover amount should also be added.
         ----------------------------------------------------------------------------------------------------

         l_leftover_amount := p_distribution_amount - l_leftover_amount;

         IF l_temp_total > 0 THEN
            -----------------------------------------------------------------------
            -- Bug 3048774
            -- l_correction_amount should hold cumulative value for all recursions.
            -----------------------------------------------------------------------

            l_correction_amount := l_correction_amount + l_correction;
            if g_debug then
	       hr_utility.trace('Going to call distribute_paid_amount recursively for the correction logic');
	    end if;
            distribute_paid_amt(l_temp_total + l_leftover_amount, p_distribute_actual_flag, p_adj_pay_flag);
            l_leftover_amount := 0;

         ELSE
            l_correction_amount := 0;
         END IF;

         -------------------------
         -- Bug 2926020
         -- Left-over Amount Logic
         -------------------------
         if g_debug then
	    hr_utility.trace('Going to adjust the leftover amount among outstanding court orders');
	 end if;
	 --
         IF p_distribute_actual_flag = 'D' and l_leftover_amount > 0 THEN

            FOR i in 1..g_court_orders.count LOOP

               EXIT WHEN l_leftover_amount = 0;

               IF g_court_orders(i).emp_attach_total_by_creditor > 0 AND nvl(g_court_orders(i).stop_flag, 'N') <> 'Y' THEN

                  l_unpaid_amount  :=  g_court_orders(i).emp_attach_total_by_creditor
                                       - g_court_orders(i).curr_emp_paid_amt_by_creditor
                                       - g_court_orders(i).wg_adjusted_amount;

                  IF l_unpaid_amount > l_leftover_amount THEN

                     IF p_adj_pay_flag = 'A' THEN
                        g_court_orders(i).wg_adjusted_amount := g_court_orders(i).wg_adjusted_amount + l_leftover_amount;
                        g_emp_total.wg_adjusted              := g_emp_total.wg_adjusted + l_leftover_amount;
                     ELSE
                        g_court_orders(i).curr_emp_paid_amt_by_creditor := g_court_orders(i).curr_emp_paid_amt_by_creditor + l_leftover_amount;

                     END IF;

                     l_leftover_amount := 0;

                  ELSE

                     l_leftover_amount := l_leftover_amount - l_unpaid_amount;

                     IF p_adj_pay_flag = 'A' THEN
                        g_court_orders(i).wg_adjusted_amount := g_court_orders(i).wg_adjusted_amount + l_unpaid_amount;
                        g_emp_total.wg_adjusted              := g_emp_total.wg_adjusted + l_unpaid_amount;
                     ELSE
                        g_court_orders(i).curr_emp_paid_amt_by_creditor := g_court_orders(i).curr_emp_paid_amt_by_creditor + l_unpaid_amount;

                     END IF;

                     g_court_orders(i).stop_flag   := 'Y';
                     g_court_orders(i).out_message := 'PAY_KR_WG_FUL_DEBT_PAID_MSG';

                     IF g_court_orders(i).processing_type IN ('A' , 'AA') THEN
                        c_all_attach_full_paid := 'Y';
                     END IF;
                  END IF;
               END IF;
            END LOOP;
         END IF;
         --------------------------------
         -- End of Left-over amount logic
         --------------------------------
         ----------------------------------------------------------------------------------------------------
         -- Set the stop flag for separation pay run
         -- Bug 2657588 - Court Order should not be stopped for interim separation.
	 -- Bug : 4866417
	 -- This logic has been moved after the leftover amount logic because in case of separation pay stop
	 -- flag was being set before the leftover logic, because of which leftover amount didn't get
	 -- Adjusted in outstanding court orders in separation pay run.
	 ----------------------------------------------------------------------------------------------------
	 FOR i in 1..g_court_orders.count LOOP
            IF p_run_type = 'SEP' THEN
               IF p_adj_pay_flag = 'A' THEN
                  IF p_distribute_actual_flag <> 'D' THEN
                      g_court_orders(i).stop_flag := 'Y';
                  END IF;
               ELSE
                  g_court_orders(i).stop_flag := 'Y';
               END IF;
            END IF;
	 END LOOP;
       END IF;     -- count > 0

     EXCEPTION
        WHEN OTHERS THEN
	  if g_debug then
	          hr_utility.set_location('Error in Distributing Paid Amount. '||substr(sqlerrm,1,200), -60);
          end if;
          RAISE;

     END distribute_paid_amt;

     --------------------------------------------------------------------------------------------
     -- Procedure to process attachments came after All Attachment if All Attachment has stopped.
     --------------------------------------------------------------------------------------------
     PROCEDURE after_all_attachment (p_earnings IN NUMBER, p_adj_pay IN CHAR)
     IS

     BEGIN
        if g_debug then
	        hr_utility.set_location('Earnings for after_all_attachment : '||to_char(p_earnings),15);
        end if;
        g_emp_total.emp_attach_total  := 0;

        -- Bug 2713144    Resetting Distribution Base

        g_emp_total.distribution_base := 0;
        if g_debug then
	        hr_utility.set_location('Calculating Real Attachment Total for After All Attachment processing',25);
        end if;

        calc_real_attachment_total;
        if g_debug then
	        hr_utility.set_location('Calculating employee attachment total for After All Attachment processing',35);
        end if;
        calc_emp_attachment_total;

        g_emp_total.curr_emp_paid_amt := least(g_emp_total.emp_attach_total, p_earnings);
        if g_debug then
	        hr_utility.set_location('Distributing paid amount for After All Attachment processing ',45);

        end if;
        IF p_earnings >= g_emp_total.emp_attach_total THEN
           distribute_paid_amt(0, 'A', p_adj_pay);
        ELSE
           distribute_paid_amt(p_earnings, 'D', p_adj_pay);
        END IF;
        if g_debug then
	        hr_utility.set_location('Employee Attachment total for After All Attachment processing : '||to_char(g_emp_total.emp_attach_total),55);
        end if;
        IF p_adj_pay = 'A' AND g_emp_total.emp_attach_total > p_earnings THEN
           if g_debug then
	           hr_utility.set_location('p_net_earnings '||to_char(p_net_earnings),65);
           end if;
           g_emp_total.curr_emp_paid_amt := least(g_emp_total.emp_attach_total - p_earnings, p_net_earnings);

           IF p_net_earnings >= g_emp_total.emp_attach_total - p_earnings THEN
              distribute_paid_amt(0, 'A', 'P');
           ELSE
              distribute_paid_amt(p_net_earnings, 'D', 'P');
           END IF;

        END IF;

     EXCEPTION
        WHEN OTHERS THEN
          if g_debug then
	          hr_utility.set_location('Error in After All Attachment Processing. '||substr(sqlerrm,1,200), -70);
          end if;
          RAISE;

     END;

  ----------------------------------------
  -- Main proceudre body begins here
  ----------------------------------------
  BEGIN
     if g_debug then
	     hr_utility.set_location('---------Entering pay_kr_wg_pkg.calc_wage_garnishment--------',10);
     end if;
     -- Bug 2715365 Fetch Payroll period start date and end date from per_time_periods table

     OPEN  csr_pay_period(p_assignment_action_id);
     FETCH csr_pay_period INTO l_period_start_date, l_period_end_date, l_payroll_action_id;
     CLOSE csr_pay_period;

     -- Bug 2762097 Fetch payoutdate from legislative_parameters in pay_payroll_actions table
     -- Bug 3021794 payout date is now stored in canonical format in legislative parameter.
     --             Thus modified the function call to get_legislative_parameter

     l_payout_date := fnd_date.canonical_to_date (pay_kr_ff_functions_pkg.get_legislative_parameter(
                               			  P_PAYROLL_ACTION_ID  =>  l_payroll_action_id,
                                	          P_PARAMETER_NAME     =>  'PAYOUTDATE',
                              			  P_DEFAULT_VALUE      =>  fnd_date.date_to_canonical(l_period_end_date)));

     -- Load court orders only if this is the first assignment or is not previously processed

     IF (g_last_assignment_processed IS NULL) OR (p_assignment_id <> g_last_assignment_processed) THEN

        -- Delete court orders of previous assignment

        g_court_orders.delete;

        -- Set the global variable to skip processing this assignment for next entry

        g_last_assignment_processed := p_assignment_id;

        -- Load all court orders for this assignment
        if g_debug then
	        hr_utility.set_location('Loading court orders',30);
        end if;
        load_court_orders;

        -- Calculate attachment total base and real attachment total for each creditor
        if g_debug then
	        hr_utility.set_location('Calculating Real Attachment Total',40);
        end if;
        calc_real_attachment_total;

        -- calculate employee attachment total for each creditor and total of employee attahcment total
        if g_debug then
	        hr_utility.set_location('Calculating Employee Attachment Total',50);
        end if;
        calc_emp_attachment_total;

        ------------------------------------------------------------------------------------
        -- Distribute Wage Garnishment Adjustment in case any obligation release has come
        -- Distribute_paid_amt procedure must be run at lease once because all output values
        -- are returned from this procedure
        ------------------------------------------------------------------------------------

        l_emp_attach_total := g_emp_total.emp_attach_total;
        if g_debug then
	        hr_utility.set_location('Adjusting WG Adjustment',60);
        end if;
        ------------------------------------------------------------------------------------
        -- Bug : 4498363
        -- Check for exception condition and distribution of earnings among court orders
        -- is done only if exceptional condition does not exist.
        ------------------------------------------------------------------------------------
        if p_run_type = 'SEP' or p_run_type = 'SEP_I' then    -- Bug 4737220
		l_earnings := p_net_earnings * g_max_attachable_earnings;
        else
		l_earnings := calc_net_earnings(p_net_earnings, p_wg_attach_earnings_mtd, p_wg_deductions_mtd, p_date_paid);
        end if;
	--
        if g_debug then
          hr_utility.set_location('Net earnings '||l_earnings,350);
          hr_utility.trace('c_redistribution_required	'||c_redistribution_required);
        end if;
	--
	IF c_obligation_release = 'Y' and c_redistribution_required = 'Y' THEN --4866417
	   if g_debug then
		   hr_utility.set_location('g_emp_total.emp_attach_total : '||to_char(g_emp_total.emp_attach_total),70);
		   hr_utility.set_location('g_emp_total.wg_adjustment : '|| to_char(g_emp_total.wg_adjustment),80);
	   end if;

	   g_emp_total.curr_emp_paid_amt := least(g_emp_total.emp_attach_total, g_emp_total.wg_adjustment);

	   IF g_emp_total.curr_emp_paid_amt > 0 THEN

	      IF g_emp_total.emp_attach_total <= g_emp_total.wg_adjustment THEN

	         distribute_paid_amt(0, 'A', 'A');
	         -----------------------------------------------------------------------------------------------
	         -- Since WG_Adjustment amount is more than employee attachment total, some amount
	         -- will be available in WG_Adjustment after redistribution.
	         --
	         -- If this is the case then, we need to check if some court orders have been suspended
	         -- because of a court order of processing priority All Attachment.
	         --
	         -- And if a court order is suspended because of All Attachment then it should be processed now.
	         ------------------------------------------------------------------------------------------------

	         IF c_all_attachment = 'Y' AND c_all_attach_full_paid = 'Y' AND c_waiting_for_all_attach = 'Y' THEN
	   	   after_all_attachment(g_emp_total.wg_adjustment - g_emp_total.curr_emp_paid_amt, 'A');
	         END IF;

	      ELSE
	         distribute_paid_amt(g_emp_total.wg_adjustment,'D', 'A');
	      END IF;
	   END IF;
	END IF;
	-----------------------------------------------------------------------------------------------------------
	-- Do this processing only if employee attachment total is greater than wage garnishment adjustment amount.
	-- This means if either WG_Adjustment amount is 0, Or
	-- WG_Adjustment is not sufficient to fully pay all court orders. Then net earnings will be used to pay the
	--    balance amount.
	-----------------------------------------------------------------------------------------------------------
	if g_debug then
		hr_utility.set_location('Distributing Amount',90);
	end if;

	IF l_emp_attach_total > g_emp_total.wg_adjustment THEN
	   ---------------------------------------------------------------------------------------------
	   -- current employee paid amount = minimum of net earnings and employee attachment total
	   --
	   -- WG_Adjustment amount should be subtracted from employee attachment total when calculating
	   --   Current Employee Paid Amount
	   ---------------------------------------------------------------------------------------------

	  g_emp_total.curr_emp_paid_amt := least(l_emp_attach_total - g_emp_total.wg_adjusted, l_earnings);

	  ----------------------------------------------------------------------------------------------------------------
	  -- Calculate the distribution percent of current paid amount for each creditor
	  --
	  -- If employee attachment total is less than attachable earnings then do not distribute the amount, pay actuals
	  -- This is identfied with a flag distribute/actual, whose value will be 'D'-distribute and 'A'-actual
	  ----------------------------------------------------------------------------------------------------------------
	  if g_debug then
		  hr_utility.set_location('Net Earnings  : ' || to_char(l_earnings),100);
	  end if;
	  IF l_emp_attach_total - g_emp_total.wg_adjusted <= l_earnings THEN

	     distribute_paid_amt(0, 'A', 'P');

	     ----------------------------------------------------------------------------------------------------
	     -- Since net earnings is higher than balance employee attachment total, amount is still avaialable.
	     --
	     -- If this is the case, we need to check if any court order was suspended because of All Attachment.
	     -- Now, since All Attachment has been fully paid, balance amount in net earnings should be used to
	     --   to pay the debt of all suspended court orders.
	     ----------------------------------------------------------------------------------------------------

	     IF c_all_attachment = 'Y' AND c_all_attach_full_paid = 'Y' AND c_waiting_for_all_attach = 'Y' THEN
		after_all_attachment(l_earnings - g_emp_total.curr_emp_paid_amt, 'P');
	     END IF;

	  ELSE
	     distribute_paid_amt(g_emp_total.curr_emp_paid_amt, 'D', 'P');
	  END IF;

	END IF;
        --
	if g_debug then
	    hr_utility.set_location('p_adjustment_amount   := '||to_char(g_emp_total.wg_adjustment),110);
 	    hr_utility.set_location('p_unadjusted_amount   := '||to_char(g_emp_total.wg_adjustment - g_emp_total.wg_adjusted),120);
	end if;
	p_adjustment_amount   := g_emp_total.wg_adjustment;
	p_unadjusted_amount   := g_emp_total.wg_adjustment - g_emp_total.wg_adjusted;

     ELSE
        p_adjustment_amount   := 0;
        p_unadjusted_amount   := 0;
     END IF;

     -- RETURN output parameters

     IF g_court_orders.count > 0 THEN

        FOR i in 1..g_court_orders.last
        LOOP
           IF p_attachment_seq_no = g_court_orders(i).attachment_sequence_no THEN
              if g_debug then
	              hr_utility.set_location('p_attachment_amount   := '||to_char(g_court_orders(i).curr_emp_paid_amt_by_creditor),130);
        	      hr_utility.set_location('p_adjusted_amount     := '||to_char(g_court_orders(i).wg_adjusted_amount),140);
              	      hr_utility.set_location('p_interest_amount     := '||to_char(g_court_orders(i).interest_amount),150);
	              hr_utility.set_location('p_stop_flag           := '||g_court_orders(i).stop_flag,160);
        	      hr_utility.set_location('p_real_attach_total   := '||to_char(g_court_orders(i).real_attach_total_by_creditor),170);
	              hr_utility.set_location('p_emp_attach_total    := '||to_char(g_court_orders(i).emp_attach_total_by_creditor),180);
        	      hr_utility.set_location('p_attach_total_base   := '||to_char(g_court_orders(i).attachment_total_base),190);
              	      hr_utility.set_location('p_message             := '||g_court_orders(i).out_message,200);
	              hr_utility.set_location('p_curr_attach_seq_no  := '||g_court_orders(i).attachment_sequence_no,210);
        	      hr_utility.set_location('p_curr_case_number    := '||g_court_orders(i).case_number,220);
              end if;
              p_curr_attach_seq_no  := g_court_orders(i).attachment_sequence_no;
              p_curr_case_number    := g_court_orders(i).case_number;
              p_attachment_amount   := g_court_orders(i).curr_emp_paid_amt_by_creditor;
              p_adjusted_amount     := g_court_orders(i).wg_adjusted_amount;
              p_interest_amount     := g_court_orders(i).interest_amount;
              p_stop_flag           := g_court_orders(i).stop_flag;
              p_real_attach_total   := g_court_orders(i).real_attach_total_by_creditor;
              p_emp_attach_total    := g_court_orders(i).emp_attach_total_by_creditor;
              p_attach_total_base   := g_court_orders(i).attachment_total_base;
	      p_message             := g_court_orders(i).out_message;

              -- Bug 2860586 IF condition added to return previous payout date if user has entered a
              --             lesser payout date than previous payout date.

              IF l_payout_date  <  g_court_orders(i).previous_payout_date THEN
                 p_payout_date  := g_court_orders(i).previous_payout_date;
              ELSE
                 p_payout_date  := l_payout_date;
              END IF;

              EXIT;

           END IF;
        END LOOP;

     END IF;
     --
     if g_debug then
	     hr_utility.set_location('---------Leaving pay_kr_wg_pkg.calc_wage_garnishment--------',230);
     end if;
     RETURN 0;

  EXCEPTION

     WHEN e_duplicate_attach_exception THEN
       RETURN 1;

     WHEN e_prev_case_notfound_exception THEN
       RETURN 2;

     WHEN e_all_attachment_exception THEN
       RETURN 4;

     WHEN OTHERS THEN
       if g_debug then
	       hr_utility.set_location(substr(sqlerrm,1,200),-80);
       end if;
       RAISE;

  END calc_wage_garnishment;

  ----------------------------------------------------------------------------------
  -- Function <-------- ATTACHMENT_SEQ_NO_IS_VALID ------>
  ----------------------------------------------------------------------------------
  -- Bug 2856663 : check for assignment_id included in the where clause.
  ----------------------------------------------------------------------------------
  FUNCTION attachment_seq_no_is_valid (p_assignment_id          IN      NUMBER,
				       p_element_entry_id	IN	NUMBER,
                                       p_attachment_seq_no      IN      VARCHAR2)
         RETURN VARCHAR2
  IS
     Cursor csr_attach IS
                SELECT  'Y'
		from	pay_element_entry_values_f  peev,
			pay_element_entries_f	    pee,
			pay_element_links_f	    pel,
                        pay_input_values_f          piv,
                        pay_element_types_f         pet,
                        fnd_sessions                ses
		where	pet.element_name = 'Wage Garnishments'
                and     pet.legislation_code = 'KR'
                and     pet.business_group_id IS NULL
                and     ses.session_id = userenv('sessionid')
                and     pel.element_type_id = pet.element_type_id
                and     piv.element_type_id = pel.element_type_id
                and     piv.name = 'Attachment Seq No'
		and	pee.element_link_id = pel.element_link_id
		and	nvl(pee.entry_type, 'E') = 'E'
                and     pee.assignment_id = p_assignment_id
                and     peev.input_value_id = piv.input_value_id
		and	peev.element_entry_id = pee.element_entry_id
                and     peev.element_entry_id <> p_element_entry_id
		and	ses.effective_date between pel.effective_start_date and pel.effective_end_date
		and	ses.effective_date between piv.effective_start_date and piv.effective_end_date
		and	ses.effective_date between pet.effective_start_date and pet.effective_end_date
                and     pee.element_entry_id  <> p_element_entry_id
		and	peev.effective_start_date = pee.effective_start_date
		and	peev.effective_end_date = pee.effective_end_date
		and     peev.screen_entry_value = p_attachment_seq_no;

     l_exists   VARCHAR2(1)  := 'N';

  BEGIN

     OPEN csr_attach;
     FETCH csr_attach INTO l_exists;
     CLOSE csr_attach;

     IF l_exists = 'Y' THEN
        RETURN 'N';
     ELSE
        RETURN 'Y';
     END IF;

  END attachment_seq_no_is_valid;

---------------------------------
----Package pay_kr_wg_pkg--------
---------------------------------
BEGIN
     -- Bug : 4498363
     OPEN csr_get_global_values('KR_WG_MIN_UNDEDUCTABLE_AMOUNT');
     FETCH csr_get_global_values into g_min_undeduct_amt;
     CLOSE csr_get_global_values;

     OPEN csr_get_global_values('KR_WG_BASE_UNDEDUCTABLE_AMOUNT');
     FETCH csr_get_global_values into g_base_undeduct_amt;
     CLOSE csr_get_global_values;

     OPEN csr_get_global_values('KR_WG_MAX_ATTACHABLE_EARNINGS');
     FETCH csr_get_global_values into g_max_attachable_earnings;
     CLOSE csr_get_global_values;

END pay_kr_wg_pkg;

/
