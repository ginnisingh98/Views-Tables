--------------------------------------------------------
--  DDL for Package Body PAY_HK_MPF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_HK_MPF" AS
/* $Header: pyhkudfs.pkb 120.2.12010000.3 2008/08/06 07:23:19 ubhat ship $ */
FUNCTION get_retro_mpf(p_bus_grp_id            in NUMBER,
		       p_assignment_id         in NUMBER,
		       p_date_from             in DATE,
		       p_date_to               in DATE,
		       p_pay_basis             in VARCHAR2,
		       p_percentage            in NUMBER,
		       p_calc_method           in VARCHAR2,
                       p_hire_date             in DATE,
                       p_min_birthday          in DATE,
                       p_ER_Liability_Start_Date in DATE,
                       p_EE_Deductions_Start_Date in DATE,
                       p_Contributions_End_Date  in DATE) RETURN NUMBER IS
--
CURSOR get_prev_periods (p_assignment_id NUMBER,
                         p_date_from     DATE,
                         p_date_to       DATE) is
select ptp.time_period_id,
       bal.action_sequence,
       bal.balance_name||bal.database_item_suffix,
       ptp.start_date,
       ptp.end_date,
       bal.value
from   pay_hk_mpf_ri_balances_v   bal,
       per_time_periods           ptp
where  bal.assignment_id = p_assignment_id
and    bal.balance_name  = 'MPF_RI'
and    bal.payroll_id    = ptp.payroll_id
and    bal.expiry_date     between  ptp.start_date and ptp.end_date
and    ptp.end_date        between p_date_from and p_date_to
order by ptp.start_date, bal.action_sequence desc;
--
--

l_action_sequence       NUMBER;
l_period_id             NUMBER;
l_period_start_date     DATE;
l_period_end_date       DATE;
l_old_period_id         NUMBER ;
l_prorator              NUMBER ;
l_value                 NUMBER;
l_balance               VARCHAR2(160);
l_cum_mpf_arrs          NUMBER;
l_cum_mpf_ri            NUMBER;
l_min_ri                NUMBER;
l_max_ri                NUMBER;
l_capped_ri_ptd         NUMBER;
l_er_prorator           NUMBER;

l_max_birthday          DATE;
l_ee_eligibility        DATE;
--
BEGIN
        --
        hr_utility.set_location('pyhkudfs get_retro_mpf', 01);
        --
 	l_cum_mpf_arrs := 0;
 	l_cum_mpf_ri := 0;
	l_old_period_id := 0;
	l_prorator   := 1;
        l_max_birthday := add_months(p_min_birthday,564) ; /* Bug 3623970 - Get the 65th Birthday date */

	/* Bug 6924031 employee who commences employment after 1-February-2003 and reaches the age of 18 on or
        after 18th January 2008. In this case Employee contribution start date will be 31st day from 18th Bday. */

        IF p_hire_date >= to_date('2003/02/01','YYYY/MM/DD') and
	   p_min_birthday >= to_date('2008/01/18','YYYY/MM/DD') and
	   p_hire_date < p_min_birthday THEN
        l_ee_eligibility := p_min_birthday+30;
        ELSE
	l_ee_eligibility := p_hire_date+30;
        END IF;

	OPEN get_prev_periods(p_assignment_id, p_date_from, p_date_to);
	LOOP
	        /*
	        **  Get period RI balance, and approriate period dates
	        */
		FETCH 	get_prev_periods
                INTO    l_period_id, l_action_sequence, l_balance,
                        l_period_start_date, l_period_end_date, l_value;
                EXIT WHEN get_prev_periods%NOTFOUND;


                IF l_period_id <> l_old_period_id THEN -- dealing with new period
                   /*
		   **  Get the MPF RI LIMITS that were in force at the period end date
		   */
		   hr_utility.set_location('pyhkudfs get_retro_mpf', 02);
                   IF p_pay_basis <> 'Year' and
                      p_pay_basis <> 'Semi-Year' and
                      p_pay_basis <> 'Semi-Month' and /* Bug 7171659, based on Day rate times days*/
                      p_pay_basis <> 'Lunar Month' THEN
                      l_min_ri := to_number(hruserdt.get_table_value(p_bus_grp_id,'MPF_RI_LIMITS'
                                          ,p_pay_basis,'Lower',l_period_end_date));
                      l_max_ri := to_number(hruserdt.get_table_value(p_bus_grp_id,'MPF_RI_LIMITS'
                                          ,p_pay_basis,'Upper',l_period_end_date));
                   ELSIF p_pay_basis = 'Semi-Month' THEN /* Bug 7171659 */
                      l_min_ri := to_number(hruserdt.get_table_value(p_bus_grp_id,'MPF_RI_LIMITS'
                                          ,'Day','Lower',l_period_end_date))*(l_period_end_date-l_period_start_date+1);
                      l_max_ri := to_number(hruserdt.get_table_value(p_bus_grp_id,'MPF_RI_LIMITS'
                                          ,'Day','Upper',l_period_end_date))*(l_period_end_date-l_period_start_date+1);
                   ELSIF p_pay_basis = 'Year' THEN
                      l_min_ri := to_number(hruserdt.get_table_value(p_bus_grp_id,'MPF_RI_LIMITS'
                                          ,'Calendar Month','Lower',l_period_end_date))*12;
                      l_max_ri := to_number(hruserdt.get_table_value(p_bus_grp_id,'MPF_RI_LIMITS'
                                          ,'Calendar Month','Upper',l_period_end_date))*12;
                   ELSIF p_pay_basis = 'Semi-Year' THEN
                      l_min_ri := to_number(hruserdt.get_table_value(p_bus_grp_id,'MPF_RI_LIMITS'
                                          ,'Calendar Month','Lower',l_period_end_date))*6;
                      l_max_ri := to_number(hruserdt.get_table_value(p_bus_grp_id,'MPF_RI_LIMITS'
                                          ,'Calendar Month','Upper',l_period_end_date))*6;
                   ELSIF p_pay_basis = 'Lunar Month' THEN
                      l_min_ri := to_number(hruserdt.get_table_value(p_bus_grp_id,'MPF_RI_LIMITS'
                                          ,'Week','Lower',l_period_end_date))*4;
                      l_max_ri := to_number(hruserdt.get_table_value(p_bus_grp_id,'MPF_RI_LIMITS'
                                          ,'Week','Upper',l_period_end_date))*4;
                   END IF;
                   /*
                   **  Calculate Return Values based on p_calc_method and
                   **  apply the capping to the periodic RI based on p_calc_method
                   */


                      hr_utility.trace('l_cum_mpf_arrs' || to_char(l_cum_mpf_arrs));
                      hr_utility.trace('l_value' || to_char(l_value));
                      hr_utility.trace('l_min_ri' || to_char(l_min_ri));
                      hr_utility.trace('l_max_ri' || to_char(l_max_ri));
                      hr_utility.trace('p_percentage' || to_char(p_percentage));
                      hr_utility.trace('p_calc_method' ||p_calc_method);

                   IF p_calc_method = 'RI' THEN
                      hr_utility.set_location('pyhkudfs get_retro_mpf', 10);
                      l_cum_mpf_ri := l_cum_mpf_ri + l_value;
                   ELSIF p_calc_method = 'ER' THEN
                      hr_utility.set_location('pyhkudfs get_retro_mpf', 15);
               /* Bug 2798013. Added the following proration logic to calculate
                  Retro MPF Liability  */
                      IF p_date_from <= l_period_start_date and
		     	p_date_to >= l_period_end_date and
		     	p_Contributions_End_Date  > l_period_end_date THEN
		     	l_er_prorator := 1;
		     	    /* Bug 2824603 added p_min_birthday check, p_contributions_end_date check */
		     	    /* Bug 2824660  Added proration logic when p_ER_Liability_Start_Date is
			       entered and is mid period. */
                            /* Bug 3623970 - Excluded BirthDate from 65 Years check */
		      ELSIF p_Contributions_End_Date  > l_period_start_date and
		             p_Contributions_End_Date <= l_period_end_date then
			        if p_Contributions_End_Date = l_max_birthday
				then
		           	l_er_prorator := (p_Contributions_End_Date- greatest(p_date_from,l_period_start_date)) /
		                                      (l_period_end_date-l_period_start_date+1);
				else
		           	l_er_prorator := (p_Contributions_End_Date- greatest(p_date_from,l_period_start_date)+1) /
		                                      (l_period_end_date-l_period_start_date+1);
                                end if;
                      /* Bug 3976900 Removed prorated calculation for join after 18thDOB at same mth*/
                      /* Bug 4175965 Included prorated calculation for the 18th DOB is the last day of the first mth */
		      ELSIF ((p_min_birthday > l_period_start_date and
                            p_min_birthday <= l_period_end_date) or
                            (p_ER_Liability_Start_Date > l_period_start_date and
                             p_ER_Liability_Start_Date < l_period_end_date)) then

                                IF (p_hire_date > l_period_start_date and
                                  p_hire_date < l_period_end_date) and
                                   p_min_birthday <= p_hire_date THEN
                                        l_er_prorator := 1;
                            	ELSIF p_date_from > l_period_start_date and
		     	       	   p_date_to >= l_period_end_date THEN
		     	       		l_er_prorator := (l_period_end_date-p_date_from+1) /
		     		            (l_period_end_date-l_period_start_date+1);
		            	ELSIF p_date_from >= l_period_start_date and
		     	       	     p_date_to < l_period_end_date THEN
		     	       		l_er_prorator := (p_date_to-l_period_start_date+1) /
		     		            (l_period_end_date-l_period_start_date+1);
                            	END IF;

                       ELSE
                            l_er_prorator := 1;
                       END IF;
                       hr_utility.trace('Anu ER p_date_from' || to_char(p_date_from,'DD/MM/YYYY'));
                      hr_utility.trace('p_date_to' || to_char(p_date_to,'DD/MM/YYYY'));
                      hr_utility.trace('l_period_start_date' || to_char(l_period_start_date,'DD/MM/YYYY'));
                      hr_utility.trace('l_period_end_date' || to_char(l_period_end_date,'DD/MM/YYYY'));
                      hr_utility.trace('p_ER_Liability_Start_Date' || to_char(p_ER_Liability_Start_Date,'DD/MM/YYYY'));
                      hr_utility.trace('l_er_prorator' || to_char(l_er_prorator));

                      /* Bug 2753292. Removed the check for min RI threshold */
                      l_cum_mpf_arrs := l_cum_mpf_arrs +
                                        least(((l_value * l_er_prorator) * p_percentage / 100)
                                           ,(l_max_ri * p_percentage / 100)) ;

                   ELSE
                      /*
		      **  Establish if its a full period RI,
		      **  if not, derive prorator for qualifying days
		      */
		      hr_utility.set_location('pyhkudfs get_retro_mpf', 20);


                      /* Bug 2753272. Added p_hire_date condition */
                      /* Bug# 4314140 Modified the partial period waiver logic so that partial period waiver should be applicable only for the month
                         in which 30th day of the employment falls*/
                      /* Bug 6270465, Modified the partial period waiver logic so that if ee eligibility date is the same as the period start date,
                         the prorator should not be the zero */
		      IF (p_calc_method = 'EE' and l_ee_eligibility > l_period_start_date and /* Bug 6270465 */
                          p_hire_date>=to_date('01/02/2003','DD/MM/YYYY') )  then
                          l_prorator := 0;          /* Bug 2660969 */
		      ELSIF  p_date_from <= l_period_start_date and
		         p_date_to >= l_period_end_date and
		         p_Contributions_End_Date > l_period_end_date THEN
		         l_prorator := 1;
		         /* Bug 2824660   Added proration logic when p_EE_Deductions_Start_Date is
			 entered and is mid period and hire date is before 01-feb-2003
			 Bug 2824603 Added proration logic whn employee turns 65 or contribution end date is entered */
                         /* Bug 3623970 - Excluded BirthDate from 65 Years check */
			 ELSIF   p_Contributions_End_Date  > l_period_start_date and
		                    p_Contributions_End_Date <= l_period_end_date then
				     if p_Contributions_End_Date = l_max_birthday
				     then
		      	 	     l_prorator := (p_Contributions_End_Date-greatest(p_date_from,l_period_start_date)) /
		                          (l_period_end_date-l_period_start_date+1);
				     else
		      	 	     l_prorator := (p_Contributions_End_Date-greatest(p_date_from,l_period_start_date) + 1) /
		                          (l_period_end_date-l_period_start_date+1);
                                     end if;
                         /* Bug# 4314140 Proration calculation is included for the employee whose 18th birthday is end of the month*/
			 ELSIF (p_min_birthday > l_period_start_date and
                                   p_min_birthday <= l_period_end_date) then
		      	 	 IF p_date_from > l_period_start_date and
		            	    p_date_to >= l_period_end_date THEN
		            		l_prorator := (l_period_end_date-p_date_from+1) /
		                          (l_period_end_date-l_period_start_date+1);
		     		 ELSIF p_date_from >= l_period_start_date and
		            		p_date_to < l_period_end_date THEN
		            		l_prorator := (p_date_to-l_period_start_date+1) /
		                          (l_period_end_date-l_period_start_date+1);
		                 END IF;
		      	  ELSIF (p_EE_Deductions_Start_Date > l_period_start_date and
                             p_EE_Deductions_Start_Date < l_period_end_date and
                             p_hire_date < to_date('01/02/2003','DD/MM/YYYY')) or
                             p_hire_date < to_date('01/02/2003','DD/MM/YYYY') then
		      	 	 IF p_date_from > l_period_start_date and
		            	   p_date_to >= l_period_end_date THEN
		            		l_prorator := (l_period_end_date-p_date_from+1) /
		                          (l_period_end_date-l_period_start_date+1);
		     		 ELSIF p_date_from >= l_period_start_date and
		            		p_date_to < l_period_end_date THEN
		            		l_prorator := (p_date_to-l_period_start_date+1) /
		                          (l_period_end_date-l_period_start_date+1);
		                 END IF;
		       END IF;

                      hr_utility.trace('p_date_from' || to_char(p_date_from,'DD/MM/YYYY'));
                      hr_utility.trace('p_date_to' || to_char(p_date_to,'DD/MM/YYYY'));
                      hr_utility.trace('l_period_start_date' || to_char(l_period_start_date,'DD/MM/YYYY'));
                      hr_utility.trace('l_period_end_date' || to_char(l_period_end_date,'DD/MM/YYYY'));
                      hr_utility.trace('l_prorator' || to_char(l_prorator));

                    /*
                    ** Bug #2270318 - Check the RI with prorated value of Minimum Threshold
                    **                Also prorate the Maximum Threshold Value
                    ** Bug #4494597 - Removed Maximum Threshold Value Proration
                    */

                      IF (l_value >= l_min_ri * l_prorator) THEN
                      l_cum_mpf_arrs := l_cum_mpf_arrs +
                                      least(((l_value * l_prorator) * p_percentage / 100)
                                           ,(l_max_ri * p_percentage / 100));
                      END IF;
                   END IF;
                   l_old_period_id := l_period_id;
                END IF;
	END LOOP;
	CLOSE get_prev_periods;
	IF p_calc_method = 'RI' THEN
           hr_utility.set_location('pyhkudfs get_retro_mpf', 50);
	   RETURN l_cum_mpf_ri;
	ELSE
           hr_utility.set_location('pyhkudfs get_retro_mpf', 55);
	   RETURN l_cum_mpf_arrs;
	END IF;
END get_retro_mpf;
--
FUNCTION hk_scheme_val(p_bus_grp_id            in NUMBER,
                       p_assignment_id         in NUMBER,
		       p_entry_value           in VARCHAR2) RETURN VARCHAR2 IS
		       --
v_valid_scheme         varchar2(1);
--
CURSOR check_source (p_bus_grp_id    NUMBER,
                     p_entry_value   VARCHAR2) is
select      'S'
from        hr_organization_information d
           ,hr_all_organization_units b
where       to_number(d.org_information20) = to_number(p_entry_value)
and         b.business_group_id = p_bus_grp_id
and         b.organization_id = d.organization_id
and         d.org_information_context = 'HK_MPF_SCHEMES';
--
BEGIN
    --
    hr_utility.set_location('pyhkudfs hk_scheme_val', 01);
    --
    v_valid_scheme := 'E';
    open check_source (p_bus_grp_id, p_entry_value);
    fetch check_source into v_valid_scheme;
    close check_source;
    --
    hr_utility.set_location('pyhkudfs hk_scheme_val', 03);
    --
    RETURN v_valid_scheme;
    --
END hk_scheme_val;
--
FUNCTION hk_quarters_val(p_bus_grp_id            in NUMBER,
                         p_assignment_id         in NUMBER,
		         p_entry_value           in VARCHAR2) RETURN VARCHAR2 IS
		         --
v_valid_quarters         varchar2(1);
--
CURSOR check_source (p_assignment_id NUMBER,
                     p_entry_value   VARCHAR2) is
select      'S'
from        per_assignment_extra_info d
where       to_number(d.aei_information20) = to_number(p_entry_value)
and         d.assignment_id = p_assignment_id
and         d.aei_information_category = 'HR_QUARTERS_INFO_HK';
--
BEGIN
    --
    hr_utility.set_location('pyhkudfs hk_quarters_val', 01);
    --
    v_valid_quarters	:= 'E';
    open check_source (p_assignment_id, p_entry_value);
    fetch check_source into v_valid_quarters;
    close check_source;
    --
    hr_utility.set_location('pyhkudfs hk_quarters_val', 03);
    --
    RETURN v_valid_quarters;
    --
END hk_quarters_val;

/* Bug:3333006. Added the following function */
FUNCTION get_act_termination_date
          (p_assignment_id in per_all_assignments_f.assignment_id%type,
           p_date in date) RETURN date IS

l_act_term_date date;

CURSOR get_act_term_date(p_assignment_id in per_all_assignments_f.assignment_id%type,
                         p_date in date) IS
SELECT target.ACTUAL_TERMINATION_DATE
FROM
        per_periods_of_service                 target,
        per_assignments_f                      ASSIGN
WHERE   p_date BETWEEN ASSIGN.effective_start_date
                 AND ASSIGN.effective_end_date
AND    ASSIGN.assignment_id                  = p_assignment_id
AND    ASSIGN.assignment_type                = 'E'
AND    target.period_of_service_id           = ASSIGN.period_of_service_id;

BEGIN

    Open get_act_term_date(p_assignment_id,p_date);
    Fetch get_act_term_date into l_act_term_date;
    If get_act_term_date%notfound then
       l_act_term_date := to_date('31/12/4712','dd/mm/yyyy');
    end if;
    Close get_act_term_date;

    return l_act_term_date;

END get_act_termination_date;
--
END pay_hk_mpf;

/
