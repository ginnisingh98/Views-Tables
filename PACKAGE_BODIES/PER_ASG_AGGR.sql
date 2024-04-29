--------------------------------------------------------
--  DDL for Package Body PER_ASG_AGGR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_ASG_AGGR" AS
/* $Header: peaggasg.pkb 120.4.12010000.5 2010/04/07 11:09:51 rlingama ship $ */

G_WHO_CALLED varchar2(100); /* Bug Fix 9253988 */
G_VALIDATION_FAILURE boolean;

/*---------------------------------------------------
              --FUNCTION: assg_aggr_possible
 Function to check if multiple assignments with
 same tax district exist for this person.
 ---------------------------------------------------*/
 FUNCTION assg_aggr_possible (p_person_id IN NUMBER,
                              p_effective_date IN DATE,
                              p_message IN VARCHAR2) RETURN boolean
 IS
 l_segment_prev hr_soft_coding_keyflex.segment1%TYPE;
 l_count_assignments NUMBER;
 l_count_paye_link   NUMBER;
 l_same_tax_district BOOLEAN default FALSE;
 l_same_paye_element_value BOOLEAN default TRUE;
 l_new_paye_element_value VARCHAR(100) default NULL;
 l_old_paye_element_value VARCHAR(100) default NULL;
 l_sys_per_type varchar2(30);
 l_ni_flag  varchar2(10);
 l_paye_flag varchar2(10);
 l_profile_value varchar2(30); -- bug8370225

 -- Start of Bug 5671777-9
 l_effective_end_date DATE;
 l_new_cpe_strat_date DATE;
 l_old_cpe_strat_date DATE;
 l_old_assignment_id  NUMBER;
 l_new_assignment_id  NUMBER;
 l_old_effective_end_date DATE;
 l_new_effective_end_date DATE;
 l_old_effective_start_date DATE;
 l_new_effective_start_date DATE;
 -- End of Bug 5671777-9

 --
 -- Start of Bug 5671777-9
 -- Changed the cursor to fecth PAYE agg flag effective end date
 cursor cur_get_aggr_flag(c_person_id in number,
                          c_effective_date in date) is
 select per_information10,effective_end_date
 from   per_all_people_f
 where  person_id = c_person_id
 and    c_effective_date between effective_start_date and effective_end_date;
 -- End of Bug 5671777-9

 cursor cur_person_type (c_person_id in number,
                         c_effective_date in date) is
  select typ.system_person_type
  from per_person_types typ,
       per_all_people_f ppf
  where ppf.person_id = c_person_id
  and   ppf.person_type_id = typ.person_type_id
  and c_effective_date between
     ppf.effective_start_date and ppf.effective_end_date;
 --
 CURSOR cur_rows_assg IS
 SELECT count(*)
 FROM per_all_assignments_f
 WHERE person_id = p_person_id
 AND p_effective_date BETWEEN effective_start_date AND effective_end_date ;

 CURSOR cur_tax_reference IS
  SELECT COUNT(hsck.segment1) Num, hsck.segment1 tax_district
  FROM hr_soft_coding_keyflex hsck,
       pay_all_payrolls_f papf,
       per_all_assignments_f paaf,
       per_assignment_status_types past
  WHERE hsck.soft_coding_keyflex_id = papf.soft_coding_keyflex_id
  AND papf.payroll_id =paaf.payroll_id
  AND past.assignment_status_type_id = paaf.assignment_status_type_id
  AND paaf.person_id = p_person_id
 /*Commented for bug fix 3949536*/
--AND past.per_system_status='ACTIVE_ASSIGN'
  AND p_effective_date BETWEEN paaf.effective_start_date AND paaf.effective_end_date
  AND p_effective_date BETWEEN papf.effective_start_date AND papf.effective_end_date
  GROUP BY hsck.segment1;

  /*BUG 2879391 Added the cursor to compare PAYE info for multiple assignments*/
  /*BUG 4520393 added joins with pay_all_payrolls_f and hr_soft_coding_keyflex to validate
    PAYE info only for assignments within the same PAYE reference*/

  -- Start of BUG 5671777-9
  -- Added code to fetch PAYE info of the multiple assignments with same CPE
  --

  CURSOR cur_paye_element_values(p_tax_district varchar2,p_start_date date,p_end_date date) IS
  SELECT nvl(min(decode(inv.name, 'Tax Code', eev.screen_entry_value, null)),0)||
  nvl(min(decode(inv.name, 'Tax Basis', substr(HR_GENERAL.DECODE_LOOKUP('GB_TAX_BASIS',eev.screen_entry_value),1,80),null)),0)||
  nvl(min(decode(inv.name, 'Refundable', substr(HR_GENERAL.DECODE_LOOKUP('GB_REFUNDABLE',eev.screen_entry_value),1,80),null)),0)||
  nvl(min(decode(inv.name, 'Pay Previous', eev.screen_entry_value, null)),0)||
  nvl(min(decode(inv.name, 'Tax Previous', eev.screen_entry_value, null)),0)||
  nvl(min(decode(inv.name, 'Authority', substr(HR_GENERAL.DECODE_LOOKUP('GB_AUTHORITY',eev.screen_entry_value),1,80),null)),0)||
  nvl(ele.entry_information1,0)||
  nvl(ele.entry_information2,0) VALUE,
  pay_gb_eoy_archive.get_agg_active_start(paa.assignment_id, p_tax_district, greatest(paa.effective_start_date,ppf.effective_start_date)) cpe_start_date,
  paa.assignment_id assignment_id,
  eev.effective_start_date effective_start_date,
  eev.effective_end_date effective_end_date
  from
  pay_element_entries_f ele,
  pay_element_entry_values_f eev,
  pay_input_values_f inv,
  pay_element_links_f lnk, pay_element_types_f elt,
  per_all_assignments_f paa,
  pay_all_payrolls_f ppf,
  hr_soft_coding_keyflex scl
  where ele.element_entry_id = eev.element_entry_id
  -- and p_effective_date between ele.effective_start_date and ele.effective_end_date
  and ele.effective_start_date <= p_end_date
  and ele.effective_end_date >= p_start_date
  and eev.input_value_id + 0 = inv.input_value_id
  -- and p_effective_date between eev.effective_start_date and eev.effective_end_date
  and eev.effective_start_date <= p_end_date
  and eev.effective_end_date >= p_start_date
  and inv.element_type_id = elt.element_type_id
  -- and p_effective_date between inv.effective_start_date and inv.effective_end_date
  and inv.effective_start_date <= p_end_date
  and inv.effective_end_date >= p_start_date
  and ele.element_link_id = lnk.element_link_id
  and elt.element_type_id = lnk.element_type_id
  --  and p_effective_date between lnk.effective_start_date and lnk.effective_end_date
  and lnk.effective_start_date <= p_end_date
  and lnk.effective_end_date >= p_start_date
  and elt.element_name = 'PAYE Details'
  and paa.person_id= p_person_id
  and ele.assignment_id=paa.assignment_id
  -- and p_effective_date between elt.effective_start_date and elt.effective_end_date
  and elt.effective_start_date <= p_end_date
  and elt.effective_end_date >= p_start_date
  --  and p_effective_date between paa.effective_start_date and paa.effective_end_date
  and paa.effective_start_date <= p_end_date
  and paa.effective_end_date >= p_start_date
  and scl.segment1=p_tax_district
  and ppf.soft_coding_keyflex_id=scl.soft_coding_keyflex_id
  and ppf.payroll_id = paa.payroll_id
  -- and p_effective_date between ppf.effective_start_date and ppf.effective_end_date
  and ppf.effective_start_date <= p_end_date
  and ppf.effective_end_date >= p_start_date

  and exists ( SELECT 1
	       FROM per_all_assignments_f paaf,
	            pay_all_payrolls_f papf,
		    hr_soft_coding_keyflex hsck,
		    per_assignment_status_types past
	       WHERE paaf.person_id = p_person_id
	       and paaf.assignment_id not in (paa.assignment_id)
               and paaf.effective_start_date <= p_end_date
               and paaf.effective_end_date >= p_start_date
	       and papf.effective_start_date <= p_end_date
	       and papf.effective_end_date >= p_start_date
	       and papf.payroll_id = paaf.payroll_id
	       and papf.soft_coding_keyflex_id=hsck.soft_coding_keyflex_id
	       and hsck.segment1 = scl.segment1
	       and pay_gb_eoy_archive.get_agg_active_end(paa.assignment_id, p_tax_district, greatest(paa.effective_start_date,ppf.effective_start_date))
	         = pay_gb_eoy_archive.get_agg_active_end(paaf.assignment_id, p_tax_district, greatest(paaf.effective_start_date,papf.effective_start_date))
	       and pay_gb_eoy_archive.get_agg_active_start(paa.assignment_id, p_tax_district, greatest(paa.effective_start_date,ppf.effective_start_date))
	         = pay_gb_eoy_archive.get_agg_active_start(paaf.assignment_id, p_tax_district, greatest(paaf.effective_start_date,papf.effective_start_date))
	       and paaf.assignment_status_type_id = past.assignment_status_type_id
	       and past.per_system_status in ('ACTIVE_ASSIGN','SUSP_ASSIGN')
	      )
  group by ele.rowid, scl.segment1,
  ele.assignment_id,ele.element_entry_id,
  ele.entry_information_category, ele.entry_information1, ele.entry_information2,
  ele.effective_start_date, ele.effective_end_date,
  eev.effective_start_date,eev.effective_end_date,
  paa.assignment_id,paa.effective_start_date,ppf.effective_start_date
  order by cpe_start_date,eev.effective_start_date,paa.assignment_id;

  -- End of Bug 5671777-9

  CURSOR cur_paye_element_link IS
  select count(*)
  from   pay_element_entries_f      ele,
  	 pay_element_links_f        lnk,
  	 pay_element_types_f        elt,
  	 per_all_assignments_f      paa
  where  elt.element_name    = 'PAYE Details'
  and    p_effective_date between elt.effective_start_date and elt.effective_end_date
  and    elt.element_type_id = lnk.element_type_id
  and    p_effective_date between lnk.effective_start_date and lnk.effective_end_date
  and    lnk.element_link_id = ele.element_link_id
  and    p_effective_date between ele.effective_start_date and ele.effective_end_date
  and    ele.assignment_id   = paa.assignment_id
  and    paa.person_id       = p_person_id
  and    p_effective_date between paa.effective_start_date and paa.effective_end_date;

BEGIN
 --
 open cur_get_aggr_flag(p_person_id, p_effective_date);
 fetch cur_get_aggr_flag into  l_paye_flag,l_effective_end_date;
 close cur_get_aggr_flag;

 -- if the current values is already 'Y' then no need for validation
 if (l_paye_flag = 'Y')  then
   return true;
 end if;
 --
 open cur_person_type(p_person_id, p_effective_date);
 fetch cur_person_type into l_sys_per_type;
 close cur_person_type;
 --
 if l_sys_per_type <> 'EX_EMP' then
    -- If the Person is an Ex Employee, then no checks below
    -- necessary as they are given a new assignment on rehire
    OPEN cur_rows_assg;
    FETCH cur_rows_assg INTO l_count_assignments;
    CLOSE cur_rows_assg;
    --
    -- check number of asgs for live person.
  IF l_count_assignments <=1 THEN
    IF p_message = 'Y' THEN
    -- start of bug 8370225
    -- We should igonore the HR_78101_CHK_MULTI_ASSG error message while defaulting the PAYE and NI flags
    fnd_profile.get('GB_PAYE_NI_AGGREGATION',l_profile_value);
    if NVL(l_profile_value,'N') <> 'Y' then
     -- end of bug 8370225
     /* Bug 9253988. Setting validation failure flag. */
     if (nvl(G_WHO_CALLED,'~') = 'PER_ASG_AGGR.SET_PAYE_AGGR') then
        G_VALIDATION_FAILURE := true;
     end if;
     hr_utility.set_message(800,'HR_78101_CHK_MULTI_ASSG');
     hr_utility.raise_error;
    END IF;
    END IF;
    RETURN FALSE;
  ELSE
    --
  	FOR l_segment_1 IN cur_tax_reference LOOP
  		--
  	 	IF l_segment_1.Num > 1 THEN
  	 		l_same_tax_district:= TRUE;
                END IF;
                --
  	END LOOP;
  	--
  	IF l_same_tax_district <> TRUE THEN
  	IF p_message = 'Y' THEN
          /* Bug 9253988. Setting validation failure flag. */
          if (nvl(G_WHO_CALLED,'~') = 'PER_ASG_AGGR.SET_PAYE_AGGR') then
               G_VALIDATION_FAILURE := true;
          end if;
  	  hr_utility.set_message(800,'HR_78102_DIFF_TAX_DIST');
          hr_utility.raise_error;

  	END IF;
  	RETURN FALSE;
  	END IF;
  	--

  	/*BUG 3516114 Added code to check for PAYE Details element link */
  	OPEN cur_paye_element_link;
  	FETCH cur_paye_element_link INTO l_count_paye_link;
  	CLOSE cur_paye_element_link;

  	IF l_count_paye_link < 1 THEN
  	  IF p_message = 'Y' THEN
  	     /* Bug 9253988. Setting validation failure flag. */
             if (nvl(G_WHO_CALLED,'~') = 'PER_ASG_AGGR.SET_PAYE_AGGR') then
                G_VALIDATION_FAILURE := true;
             end if;
             hr_utility.set_message(801,'HR_78110_DIFF_PAYE_VALUES');
             hr_utility.raise_error;

    	  END IF;
  	  RETURN FALSE;
  	END IF;
  	--

  	/*BUG 2879391 Added Code to check that multiple assignments have same PAYE info*/
	/* BUG 4520393 Added futher code to check that multiple assignments within SAME PAYE reference
	   have same PAYE info*/
       -- Start of Bug 5671777-9
       -- Added code to check that multiple assignments with same CPE have sme PAYE info

        FOR l_tax_ref IN cur_tax_reference LOOP
          FOR l_paye_values IN cur_paye_element_values(L_TAX_REF.tax_district,p_effective_date,l_effective_end_date) LOOP

            IF  l_new_paye_element_value is null AND l_old_paye_element_value is null
            AND l_new_cpe_strat_date is null AND l_old_cpe_strat_date is null THEN
  	         l_old_paye_element_value := l_paye_values.VALUE ;
  	         l_old_cpe_strat_date := l_paye_values.cpe_start_date;
  	         l_old_assignment_id := l_paye_values.assignment_id;
  	         l_old_effective_start_date := l_paye_values.effective_start_date;
  	         l_old_effective_end_date := l_paye_values.effective_end_date;
            ELSE
  	         l_new_paye_element_value := l_paye_values.VALUE;
  	         l_new_cpe_strat_date := l_paye_values.cpe_start_date;
  	         l_new_assignment_id := l_paye_values.assignment_id;
  	         l_new_effective_start_date := l_paye_values.effective_start_date;
  	         l_new_effective_end_date := l_paye_values.effective_end_date;

                IF l_old_cpe_strat_date = l_new_cpe_strat_date THEN
                  IF l_old_assignment_id = l_new_assignment_id AND l_old_paye_element_value = l_new_paye_element_value THEN
                     l_old_effective_end_date := l_new_effective_end_date;
                  ELSIF l_old_assignment_id = l_new_assignment_id AND l_old_paye_element_value <> l_new_paye_element_value THEN
                     IF l_old_effective_end_date + 1 = l_new_effective_start_date THEN
                        l_old_paye_element_value := l_new_paye_element_value;
                        l_old_effective_start_date := l_new_effective_start_date;
  	                l_old_effective_end_date := l_new_effective_end_date;
                     ELSE
                        l_same_paye_element_value := FALSE;
                        EXIT;
                     END IF;
 	          ELSIF l_old_assignment_id <> l_new_assignment_id AND l_old_paye_element_value = l_new_paye_element_value THEN
 	                l_old_effective_end_date := greatest(l_new_effective_end_date,l_old_effective_end_date);
                  ELSIF l_old_assignment_id <> l_new_assignment_id AND l_old_paye_element_value <>l_new_paye_element_value THEN
  	             IF l_old_effective_end_date + 1 = l_new_effective_start_date THEN
                        l_old_paye_element_value := l_new_paye_element_value;
                        l_old_effective_start_date := l_new_effective_start_date;
  	                l_old_effective_end_date := l_new_effective_end_date;
                     ELSE
                        l_same_paye_element_value := FALSE;
                        EXIT;
                     END IF;
                  END IF;
  	        ELSE
		    l_old_paye_element_value := l_new_paye_element_value;
                    l_old_cpe_strat_date := l_new_cpe_strat_date;
                    l_old_assignment_id := l_new_assignment_id;
  	            l_old_effective_start_date := l_new_effective_start_date;
  	            l_old_effective_end_date := l_new_effective_end_date;
  	        END IF;
  	    END IF;
       	 END LOOP;
           l_new_paye_element_value := NULL;
           l_old_paye_element_value := NULL;
           l_new_cpe_strat_date := NULL;
           l_old_cpe_strat_date := NULL;
           l_old_assignment_id := NULL;
           l_new_assignment_id := NULL;
           l_old_effective_start_date := NULL;
           l_new_effective_start_date := NULL;
           l_old_effective_end_date := NULL;
           l_new_effective_end_date := NULL;
        END LOOP;
	-- End of Bug 5671777-9

        IF l_same_paye_element_value <> TRUE THEN
         IF p_message = 'Y' THEN
        -- Input values of the Paye Details for multiple assignments is not same
           /* Bug 9253988. Setting validation failure flag. */
           if (nvl(G_WHO_CALLED,'~') = 'PER_ASG_AGGR.SET_PAYE_AGGR') then
               G_VALIDATION_FAILURE := true;
           end if;
           hr_utility.set_message(801,'HR_78110_DIFF_PAYE_VALUES');
           hr_utility.raise_error;
         END IF;
        --
        RETURN FALSE;
	END IF;
	RETURN TRUE;
  	--
  END IF; -- Count of assignments
  --
 else -- The person is an ex employee so this is a rehire,
      -- return TRUE
  RETURN TRUE;
  --
 end if; -- Ex employee check
--
END assg_aggr_possible;

/* -----------------------------------------------------------
            --PROCEDURE:check_aggr_assg
 Procedure to be called through User hook of update_person_api
 for calling function assg_aggr_possible and checking if 'NI
 Multiple assignments' flag is 'Y' if aggregate assignment flag
 is 'Y'
 -------------------------------------------------------------*/

PROCEDURE check_aggr_assg(p_person_id IN NUMBER,
                           p_effective_date IN DATE,
                           p_per_information9 IN VARCHAR2,
                           p_per_information10 IN VARCHAR2,
                           p_datetrack_update_mode in VARCHAR2 default null)
 IS

-- Start of bug#8370225
l_effective_date date;
l_cur_agg_paye_flag per_assignment_status_types.per_system_status%type;
l_cur_paye_agg_flag per_all_people_f.per_information10%type;
l_cur_effective_start_date date;
l_cur_effective_end_date date;
l_earliest_tax_year date;
l_latest_tax_year date;
l_update_mode varchar2(100);
l_date_soy date;
l_date_eoy date;
l_found number;
l_tax_pay_asg_td_ytd_dfbid     number;
l_tax_pay_per_td_cpe_ytd_dfbid number;
l_paye_asg_td_ytd_dfbid        number;
l_paye_per_td_cpe_ytd_dfbid    number;
l_term_asg_found           number;
l_prev_agg_paye_flag       per_all_people_f.per_information10%type;
l_prev_effective_start_date date;
l_profile_value varchar2(30);

   --
   -- Cursor to fetch PAYE agg flag details
   --
   cursor cur_person_details(c_person_id number, c_effective_date date) IS
   select a.per_information10, a.effective_start_date,a.effective_end_date
   from   per_all_people_f a
   where  a.person_id = c_person_id
   and    c_effective_date between a.effective_start_date and a.effective_end_date;

   --
   -- check multiple assignments of the person exists between start of the year and start of change -1
   -- which shares same CPE and PAYE reference
   --
   cursor cur_chk_multiple_asg(c_person_id in number, c_start_date date, c_end_date date) IS
   select 1
   from   pay_all_payrolls_f papf,
          per_all_assignments_f paaf,
          hr_soft_coding_keyflex hsck,
	      per_assignment_status_types past
   where  paaf.person_id = c_person_id
   and    paaf.effective_start_date <= c_end_date-1
   and    paaf.effective_end_date >= c_start_date
   and    paaf.assignment_status_type_id = past.assignment_status_type_id
   and    past.per_system_status in ('ACTIVE_ASSIGN','SUSP_ASSIGN')
   and    papf.payroll_id =paaf.payroll_id
   and    papf.soft_coding_keyflex_id = hsck.soft_coding_keyflex_id
   and    c_end_date between papf.effective_start_date and papf.effective_end_date
   and    exists ( select 1
   from   pay_all_payrolls_f apf,
          per_all_assignments_f aaf,
          hr_soft_coding_keyflex sck,
	  per_assignment_status_types ast
   where  aaf.person_id = c_person_id
   and    aaf.assignment_id not in (paaf.assignment_id)
   and    aaf.effective_start_date <= c_end_date-1
   and    aaf.effective_end_date >= c_start_date
   and    aaf.assignment_status_type_id = ast.assignment_status_type_id
   and    ast.per_system_status in ('ACTIVE_ASSIGN','SUSP_ASSIGN')
   and    apf.payroll_id =aaf.payroll_id
   and    c_end_date between apf.effective_start_date and apf.effective_end_date
   and    apf.soft_coding_keyflex_id   = sck.soft_coding_keyflex_id
   and    sck.segment1 = hsck.segment1
   AND    pay_gb_eoy_archive.get_agg_active_end(aaf.assignment_id, hsck.segment1, c_end_date)
     =    pay_gb_eoy_archive.get_agg_active_end(paaf.assignment_id, hsck.segment1, c_end_date)
   AND    pay_gb_eoy_archive.get_agg_active_start(aaf.assignment_id, hsck.segment1, c_end_date)
     =    pay_gb_eoy_archive.get_agg_active_start(paaf.assignment_id, hsck.segment1, c_end_date));
  --
  -- cursor to fetch earliest and latest payroll actions tax year for this assignment
  --

  CURSOR  csr_ear_lat_tax_year(c_assignment_id in number,c_start_date date, c_end_date date) IS
  select min(ppa.effective_date),
         max(ppa.effective_date)
  from   pay_assignment_actions paa,
         pay_payroll_actions ppa,
         per_all_assignments_f paaf
  where  paa.assignment_id = c_assignment_id
  and    paaf.assignment_id = c_assignment_id
  and    paa.payroll_action_id  = ppa.payroll_action_id
  and    ppa.action_type in ('R','Q')
  and    ppa.effective_date between c_start_date and c_end_date
  and    paaf.effective_start_date <= c_end_date
  and    paaf.effective_end_date >= c_start_date
  and    paaf.payroll_id = ppa.payroll_id
  order by ppa.effective_date;

   CURSOR csr_all_assignments(c_person_id in number, c_start_date date, c_end_date date) IS
      select assignment_id
      from   per_all_assignments_f
      where  person_id = c_person_id
      and    effective_end_date   >= c_start_date
      and    effective_start_date <= c_end_date;

   CURSOR csr_asg_per_bal_diff(c_assignment_id number,c_date_eoy date) IS
     select 1 from dual
     where  nvl(hr_gbbal.calc_all_balances(c_date_eoy, c_assignment_id, l_tax_pay_asg_td_ytd_dfbid),0) <>
            nvl(hr_gbbal.calc_all_balances(c_date_eoy, c_assignment_id, l_tax_pay_per_td_cpe_ytd_dfbid),0) OR
            nvl(hr_gbbal.calc_all_balances(c_date_eoy, c_assignment_id, l_paye_asg_td_ytd_dfbid),0) <>
            nvl(hr_gbbal.calc_all_balances(c_date_eoy, c_assignment_id, l_paye_per_td_cpe_ytd_dfbid),0);

   CURSOR cur_defined_balance(c_balance_name varchar2, c_dimension_name varchar2) IS
     SELECT defined_balance_id
     FROM   pay_defined_balances
     WHERE  balance_type_id = (SELECT balance_type_id
                               FROM   pay_balance_types
                              WHERE  balance_name = c_balance_name AND legislation_code = 'GB')
        AND    balance_dimension_id = (SELECT balance_dimension_id
                                       FROM   pay_balance_dimensions
                                       WHERE  dimension_name = c_dimension_name AND legislation_code = 'GB');
 --
 -- to fetch the agg paye flag from person details
 --
   cursor cur_person_dtls(c_person_id number, c_effective_date date) IS
    select a.per_information10, a.effective_start_date
    from   per_all_people_f a
    where  a.person_id = c_person_id
    and    c_effective_date between a.effective_start_date and a.effective_end_date;

  --
  -- to find whether any terminated assignment exists for a person on effective date of change
  --
   cursor cur_term_asg_dtls(c_person_id number, c_effective_date date) IS
     select 1
     from   per_all_assignments_f a,
            per_assignment_status_types past
     where  a.assignment_status_type_id = past.assignment_status_type_id
     and    past.per_system_status = 'TERM_ASSIGN'
     and    a.person_id = c_person_id
     and    c_effective_date between a.effective_start_date and a.effective_end_date;



 -- End of bug#8370225

 BEGIN

  --
  -- Added for GSI Bug 5472781
  --
  -- Start bug 9535747  : perform below validations only when PAYE flag value chnged
  l_effective_date := p_effective_date;
  l_update_mode := p_datetrack_update_mode;

  open cur_person_details(p_person_id, l_effective_date);
  fetch cur_person_details into l_cur_paye_agg_flag, l_cur_effective_start_date,l_cur_effective_end_date;
  close cur_person_details;
  -- If API call doesn't have parameter for PAYE aggregation flag, we need assign defatult value.
  If p_per_information10 = hr_api.g_varchar2 then
     l_cur_paye_agg_flag := hr_api.g_varchar2;
  end if;

  IF nvl(l_cur_paye_agg_flag,'N') <> nvl(p_per_information10,'N') THEN
 -- End of bug 9535747
  IF hr_utility.chk_product_install('Oracle Human Resources', 'GB') THEN
    --
    --If aggregate assignment flag is 'Y'
    IF p_per_information10 = 'Y' THEN
    -- Check if 'NI Multiple assignments' flag is 'Y'
      IF p_per_information9 = 'Y' THEN
        -- Check for multiple assignments and same tax district
        IF NOT assg_aggr_possible (p_person_id , p_effective_date,'Y')  THEN
        -- start of bug 8370225
        -- We should igonore error message while defaulting the PAYE and NI flags
          fnd_profile.get('GB_PAYE_NI_AGGREGATION',l_profile_value);
          IF NVL(l_profile_value,'N') <> 'Y' then
        -- End of bug 8370225
	    /* Bug 9253988. Setting validation failure flag. */
            if (nvl(G_WHO_CALLED,'~') = 'PER_ASG_AGGR.SET_PAYE_AGGR') then
               G_VALIDATION_FAILURE := true;
            end if;
            hr_utility.raise_error;
	  END IF;
        END IF;
      ELSE

        -- if 'NI MUltiple assignment flag is not 'Y'
        -- aggregate assignment flag cannot be 'Y'
        /* Bug 9253988. Dont raise error when called from set_paye_aggr. */
        if (nvl(G_WHO_CALLED,'~') <> 'PER_ASG_AGGR.SET_PAYE_AGGR') then
            hr_utility.set_message(800,'HR_78103_CHK_NI_MULTI_ASSG_FLG');
	    hr_utility.raise_error;
        end if;

      END IF;
    END IF;
   END IF;

-- Start of bug#8370225
-- If this procedure is called form PERWSHRG.fmb. We are not doing the validations as
-- all these validations are preformed in OBJ form. Hence passed p_datetrack_update_mode
-- parameter as 'NOVALIDATION' in PERGBOB.fmb

if p_datetrack_update_mode <> 'NOVALIDATION' then


begin

-- while changing the PAYE aggregation flag, we need to ensure that there are no future payroll actions, on
-- two (or) more assignment(s) referring a single PAYE Tax district reference(so asg'saggregated).
-- If found then we need to raise an error.
   -- bug 9535747 : commented the below code as aggregation details are already fetched.
   /* l_effective_date := p_effective_date;
    l_update_mode := p_datetrack_update_mode;

    open cur_person_details(p_person_id, l_effective_date);
    fetch cur_person_details into l_cur_paye_agg_flag, l_cur_effective_start_date,l_cur_effective_end_date;
    close cur_person_details;*/

    if nvl(l_cur_paye_agg_flag,'N') <> nvl(p_per_information10,'N') then
      if l_update_mode = 'CORRECTION' THEN
         l_effective_date := l_cur_effective_start_date;
      end if;

      if l_update_mode = 'UPDATE_OVERRIDE' THEN
         l_cur_effective_end_date := to_date('31-12-4712','DD-MM-YYYY');
      end if;

      If l_effective_date >= to_date('06-04-'||substr(to_char(l_effective_date,'YYYY/MON/DD'),1,4),'DD-MM-YYYY' ) Then
         l_date_soy := to_date('06-04-'||substr(to_char(l_effective_date,'YYYY/MON/DD'),1,4),'DD-MM-YYYY' ) ;
         l_date_eoy := to_date('05-04-'||to_char(to_number(substr(to_char(l_effective_date,'YYYY/MON/DD'),1,4))+1 ),'DD-MM-YYYY')  ;
      Else
         l_date_soy := to_date('06-04-'||to_char(to_number(substr(to_char(l_effective_date,'YYYY/MON/DD'),1,4))-1 ),'DD-MM-YYYY')  ;
         l_date_eoy := to_date('05-04-'||substr(to_char(l_effective_date,'YYYY/MON/DD'),1,4),'DD-MM-YYYY') ;
      End If;

      -- Check if another assignment of the person exists between start of the year and start of change -1
      -- which shares same CPE and PAYE reference

       If l_date_soy < l_effective_date then
	  open cur_chk_multiple_asg(p_person_id, l_date_soy, l_effective_date);
	  fetch cur_chk_multiple_asg into l_found;

	  If cur_chk_multiple_asg%found then
             /* Bug 9253988. Dont raise error when called from set_paye_aggr. */
             if (nvl(G_WHO_CALLED,'~') <> 'PER_ASG_AGGR.SET_PAYE_AGGR') then
                close cur_chk_multiple_asg;
                hr_utility.set_message(800,'HR_GB_78134_MULTI_ASG_CREATION');
                hr_utility.raise_error;
             end if;
        --hr_utility.raise_error;

	  End If;
	  close cur_chk_multiple_asg;
       End if;

      -- If the date on which change ends is end of a tax years or end of time (31-12-4712) then donothing
      -- If the date on which change ends is middle of a tax year then raise error
      If  not ((substr(to_char(l_cur_effective_end_date,'YYYY/MON/DD'),5,11) = substr(to_char(l_date_eoy,'YYYY/MON/DD'),5,11))
          or  (to_char(l_cur_effective_end_date,'DD-MM-YYYY') = to_char(to_date('31-12-4712','DD-MM-YYYY'),'DD-MM-YYYY'))) Then

             /* Bug 9253988. Dont raise error when called from set_paye_aggr. */
             if (nvl(G_WHO_CALLED,'~') <> 'PER_ASG_AGGR.SET_PAYE_AGGR') then
                hr_utility.set_message(800,'HR_GB_78135_AGG_PAYE_FLAG_END');
                hr_utility.raise_error;
             end if;
           --hr_utility.raise_error;

      End if;

      open cur_defined_balance('Taxable Pay', '_ASG_TD_YTD');
      fetch cur_defined_balance into l_tax_pay_asg_td_ytd_dfbid;
      close cur_defined_balance;

      open cur_defined_balance('Taxable Pay', '_PER_TD_CPE_YTD');
      fetch cur_defined_balance into l_tax_pay_per_td_cpe_ytd_dfbid;
      close cur_defined_balance;

      open cur_defined_balance('PAYE', '_ASG_TD_YTD');
      fetch cur_defined_balance into l_paye_asg_td_ytd_dfbid;
      close cur_defined_balance;

      open cur_defined_balance('PAYE', '_PER_TD_CPE_YTD');
      fetch cur_defined_balance into l_paye_per_td_cpe_ytd_dfbid;
      close cur_defined_balance;

    -- Check there is no more than one assignment processed for the employee on any
    -- PAYE Ref between start and end dates of the change,
      for asg_rec in csr_all_assignments(p_person_id, l_effective_date, l_cur_effective_end_date)
    --for asg_rec in csr_all_assignments(p_person_id, l_date_soy, l_date_eoy)
      loop
        /* Bug 9453542. Change l_effective_date to SOY. */
        if (nvl(G_WHO_CALLED,'~') = 'PER_ASG_AGGR.SET_PAYE_AGGR') then
            l_effective_date := l_date_soy;
        end if;
	open csr_ear_lat_tax_year(asg_rec.assignment_id, l_effective_date, l_cur_effective_end_date);
        fetch csr_ear_lat_tax_year into l_earliest_tax_year,l_latest_tax_year;
	if l_earliest_tax_year is not null and l_latest_tax_year is not null then

	 If l_earliest_tax_year >= to_date('06-04-'||substr(to_char(l_earliest_tax_year,'YYYY/MON/DD'),1,4),'DD-MM-YYYY' ) Then
            l_earliest_tax_year := to_date('05-04-'||to_char(to_number(substr(to_char(l_earliest_tax_year,'YYYY/MON/DD'),1,4))+1 ),'DD-MM-YYYY')  ;
         Else
            l_earliest_tax_year := to_date('05-04-'||substr(to_char(l_earliest_tax_year,'YYYY/MON/DD'),1,4),'DD-MM-YYYY') ;
         End If;

	loop
	  open csr_asg_per_bal_diff(asg_rec.assignment_id,l_earliest_tax_year);
          fetch csr_asg_per_bal_diff into l_found;
          if csr_asg_per_bal_diff%found then
            close csr_asg_per_bal_diff;

           /* Bug 9253988. Setting validation failure flag. */
           if (nvl(G_WHO_CALLED,'~') = 'PER_ASG_AGGR.SET_PAYE_AGGR') then
               G_VALIDATION_FAILURE := true;
           end if;
           hr_utility.set_message(800,'HR_GB_78133_MULTI_PRL_ACTIONS');
           hr_utility.raise_error;

          end if;
          close csr_asg_per_bal_diff;
	  EXIT when l_earliest_tax_year >= l_latest_tax_year;
	  l_earliest_tax_year :=
	  to_date(substr(to_char(l_earliest_tax_year,'dd/mm/yyyy'),1,6)||
	  to_char(to_number(substr(to_char(l_earliest_tax_year,'dd/mm/yyyy'),7,10))+1),'dd/mm/yyyy');
        end loop;
	end if;
	close csr_ear_lat_tax_year;
      end loop;
    end if;

             l_effective_date := p_effective_date;

             open cur_person_dtls(p_person_id, l_effective_date);
             fetch cur_person_dtls into l_cur_agg_paye_flag, l_cur_effective_start_date;
             close cur_person_dtls;
             --
             -- when the date of change is from 06-04 and
             -- the current Agg. PAYE flag = N and new Agg PAYE flag = Y then we need to check
             -- for any terminated asg's on that date.
             -- in the correction datetrack mode, we have to consider the effective start date as
             -- effective date(date of change)
             --
             if nvl(l_cur_agg_paye_flag,'N') <> nvl(p_per_information10,'N') and
                to_char(l_effective_date,'dd-mm') = '06-04' and l_update_mode <> 'CORRECTION' then

                open cur_term_asg_dtls(p_person_id, l_effective_date);
                fetch cur_term_asg_dtls into l_term_asg_found;
                if cur_term_asg_dtls%found then
                   close cur_term_asg_dtls;
                   /* Bug 9253988. Setting validation failure flag. */
                   if (nvl(G_WHO_CALLED,'~') = 'PER_ASG_AGGR.SET_PAYE_AGGR') then
                      G_VALIDATION_FAILURE := true;
                   end if;
                   hr_utility.set_message(800,'HR_GB_78129_TERM_ASG_FOUND_SOY');
                   hr_utility.set_message_token('AGG_START_DATE', fnd_date.date_to_displaydate(l_effective_date));
                   hr_utility.raise_error;

                end if;
                close cur_term_asg_dtls;
             elsif nvl(l_cur_agg_paye_flag,'N') <> nvl(p_per_information10,'N') and
                to_char(l_cur_effective_start_date,'dd-mm') = '06-04' and l_update_mode = 'CORRECTION' then
                --
                -- if datetrack mode is correction and from SOY then check for the previous day aggregation flag,
                -- if the flag is Y; then we should not stop this aggregation flag change from N to Y
                --
                open cur_person_dtls(p_person_id, l_cur_effective_start_date-1);
                fetch cur_person_dtls into l_prev_agg_paye_flag, l_prev_effective_start_date;
                close cur_person_dtls;
                if nvl(l_prev_agg_paye_flag,'N') <> nvl(p_per_information10,'N') then
                  open cur_term_asg_dtls(p_person_id, l_cur_effective_start_date);
                  fetch cur_term_asg_dtls into l_term_asg_found;
                  if cur_term_asg_dtls%found then
                     close cur_term_asg_dtls;
                     /* Bug 9253988. Setting validation failure flag. */
                     if (nvl(G_WHO_CALLED,'~') = 'PER_ASG_AGGR.SET_PAYE_AGGR') then
                        G_VALIDATION_FAILURE := true;
                     end if;
                     hr_utility.set_message(800,'HR_GB_78129_TERM_ASG_FOUND_SOY');
                     hr_utility.set_message_token('AGG_START_DATE', fnd_date.date_to_displaydate(l_cur_effective_start_date));
                     hr_utility.raise_error;
                     --hr_utility.raise_error;
                  end if;
                  close cur_term_asg_dtls;
                end if;
             end if;
        end;
     end if;
   -- End of bug#8370225
   end if; -- bug 9535747
 END check_aggr_assg;
--
/* Procedure Name: set_paye_aggr
   Details:
   This procedure is After Process hook for CREATE_SECONDARY_ASSIGNMENT module.
   When profile option is set, and secondary assignment is created, then PAYE
   Aggregation flag should be set by default, provided the PAYE Agg validations
   are successful.
*/
PROCEDURE set_paye_aggr(p_person_id IN NUMBER,
                          p_effective_date IN DATE,
                          p_assignment_id IN NUMBER,
                          p_payroll_id IN NUMBER)
IS
/* Cursor to identify if PAYE flag is set or not */
 cursor cur_get_aggr_flag(c_person_id in number,
                          c_effective_date in date) is
 select per_information10, object_version_number, employee_number
 from   per_all_people_f
 where  person_id = c_person_id
 and    c_effective_date between effective_start_date and effective_end_date;

/* Get date track records from per_all_people_f, including and after effective date*/
 cursor people_dt_records(c_person_id in number,
                          c_effective_date in date) is
 select person_id, effective_start_date, effective_end_date,
 per_information9,  per_information10, full_name, object_version_number
 from per_all_people_f
 where person_id=c_person_id
 and effective_end_date >= c_effective_date
 order by effective_start_date;

/* Identify the number of assignments for the person_id*/
 cursor cur_asg_count(c_person_id in number,
                          c_effective_date in date) is
  select count (distinct assignment_id)
  from per_all_assignments_f
  where person_id = c_person_id
  and c_effective_date between effective_start_date and effective_end_date;

/* Identify the TD details of the assignment newly created*/
 cursor get_curr_td_info(c_assignment_id in number,
                          c_effective_date in date) is
  SELECT --COUNT(hsck.segment1) Num,
  hsck.segment1 tax_district
  FROM hr_soft_coding_keyflex hsck,
       pay_all_payrolls_f papf,
       per_all_assignments_f paaf
  WHERE paaf.assignment_id= c_assignment_id
  AND papf.payroll_id =paaf.payroll_id
  AND hsck.soft_coding_keyflex_id = papf.soft_coding_keyflex_id
  AND c_effective_date BETWEEN paaf.effective_start_date AND paaf.effective_end_date
  AND c_effective_date BETWEEN papf.effective_start_date AND papf.effective_end_date
  GROUP BY hsck.segment1;

/* Get PAYE Input values of assignment eligible for aggregation with newly created assg. */
 cursor get_paye_details(c_person_id in number,
                         c_tax_ref in varchar2,
                         c_effective_date in date,
                         c_assignment_id in number) is
 SELECT distinct
                ppev.TAX_CODE,
                ppev.Tax_Basis,
                ppev.Pay_Previous,
                ppev.Tax_Previous,
                ppev.Refundable,
                ppev.Authority
           FROM (SELECT min(decode(inv.name, 'Tax Code', eev.screen_entry_value, null)) Tax_Code,
                        min(decode(inv.name, 'Tax Basis', eev.screen_entry_value, null)) Tax_Basis,
                        min(decode(inv.name, 'Refundable', eev.screen_entry_value, null)) Refundable,
                        min(decode(inv.name, 'Pay Previous', nvl(eev.screen_entry_value,0), null)) Pay_Previous,
                        min(decode(inv.name, 'Tax Previous', nvl(eev.screen_entry_value,0), null)) Tax_Previous,
                        min(decode(inv.name, 'Authority', eev.screen_entry_value, null)) Authority
                   FROM pay_element_entries_f ele,
                        pay_element_entry_values_f eev,
                        pay_input_values_f inv,
                        pay_element_links_f lnk,
                        pay_element_types_f elt,
                        pay_all_payrolls_f papf,
                        per_all_assignments_f paaf,
                        hr_soft_coding_keyflex hsck
                  WHERE paaf.person_id = c_person_id
                    AND c_effective_date BETWEEN paaf.effective_start_date AND paaf.effective_end_date
                    AND paaf.payroll_id = papf.payroll_id
                    AND c_effective_date BETWEEN papf.effective_start_date AND papf.effective_end_date
                    AND papf.soft_coding_keyflex_id=hsck.soft_coding_keyflex_id
                    AND hsck.segment1 = c_tax_ref
                    AND ele.assignment_id=paaf.assignment_id
                    AND c_effective_date between ele.effective_start_date and ele.effective_end_date
                    AND ele.element_entry_id = eev.element_entry_id
                    AND eev.input_value_id + 0 = inv.input_value_id
                    AND c_effective_date between eev.effective_start_date and eev.effective_end_date
                    AND inv.element_type_id = elt.element_type_id
                    AND c_effective_date between inv.effective_start_date and inv.effective_end_date
                    AND ele.element_link_id = lnk.element_link_id
                    AND c_effective_date between lnk.effective_start_date and lnk.effective_end_date
                    AND elt.element_name = 'PAYE Details'
                    AND elt.legislation_code = 'GB'
                    AND c_effective_date between elt.effective_start_date and elt.effective_end_date
                    -- AND pay_p45_pkg.PAYE_SYNC_P45_ISSUED_FLAG(paaf.assignment_id,c_effective_date) = 'N'
                    AND paaf.assignment_id <> c_assignment_id
                    AND pay_gb_eoy_archive.get_agg_active_start(paaf.assignment_id, c_tax_ref,c_effective_date) =
                        pay_gb_eoy_archive.get_agg_active_start(c_assignment_id, c_tax_ref,c_effective_date)
                    AND pay_gb_eoy_archive.get_agg_active_end(paaf.assignment_id, c_tax_ref,c_effective_date) =
                        pay_gb_eoy_archive.get_agg_active_end(c_assignment_id, c_tax_ref,c_effective_date)
                    ) ppev
                 where ppev.TAX_CODE is not null
                   and ppev.Tax_Basis is not null
                   and ppev.Refundable is not null;

/* Get current assignment PAYE Details element input values */
  cursor current_asg_paye_details(c_assignment_id in number, c_effective_date in date) is
  SELECT       ele.element_entry_id element_entry_id,
               min(decode(inv.name, 'Tax Code', eev.screen_entry_value, null)) Tax_Code,
               min(decode(inv.name, 'Tax Code', eev.input_value_id, null)) Tax_Code_iv_id,
               min(decode(inv.name, 'Tax Basis', eev.screen_entry_value, null)) Tax_Basis,
               min(decode(inv.name, 'Tax Basis', eev.input_value_id, null)) Tax_Basis_iv_id,
               min(decode(inv.name, 'Refundable', eev.screen_entry_value, null)) Refundable,
               min(decode(inv.name, 'Refundable', eev.input_value_id, null)) Refundable_iv_id,
               min(decode(inv.name, 'Pay Previous', nvl(eev.screen_entry_value,0), null)) Pay_Previous,
               min(decode(inv.name, 'Pay Previous', eev.input_value_id, null)) Pay_Previous_iv_id,
               min(decode(inv.name, 'Tax Previous', nvl(eev.screen_entry_value,0), null)) Tax_Previous,
               min(decode(inv.name, 'Tax Previous', eev.input_value_id, null)) Tax_Previous_iv_id,
               min(decode(inv.name, 'Authority', eev.screen_entry_value, null)) Authority,
               min(decode(inv.name, 'Authority', eev.input_value_id, null)) Authority_iv_id
          FROM pay_element_entries_f ele,
               pay_element_entry_values_f eev,
               pay_input_values_f inv,
               pay_element_links_f lnk,
               pay_element_types_f elt,
               per_all_assignments_f paaf
         WHERE ele.element_entry_id = eev.element_entry_id
           AND c_effective_date between ele.effective_start_date and ele.effective_end_date
           AND eev.input_value_id + 0 = inv.input_value_id
           AND c_effective_date between eev.effective_start_date and eev.effective_end_date
           AND inv.element_type_id = elt.element_type_id
           AND c_effective_date between inv.effective_start_date and inv.effective_end_date
           AND ele.element_link_id = lnk.element_link_id
           AND c_effective_date between lnk.effective_start_date and lnk.effective_end_date
           AND elt.element_name = 'PAYE Details'
           AND elt.legislation_code = 'GB'
           AND c_effective_date between elt.effective_start_date and elt.effective_end_date
           AND ele.assignment_id=paaf.assignment_id
           AND c_effective_date BETWEEN paaf.effective_start_date AND paaf.effective_end_date
           AND paaf.assignment_id = c_assignment_id
           group by ele.element_entry_id;

/* Get the lookup values and meaning */
cursor get_tax_basis_code(c_lookup_type varchar2, c_lookup_code varchar2) is
select meaning from hr_lookups
where lookup_type=c_lookup_type
and lookup_code=c_lookup_code;

l_proc varchar2(30) := 'PER_ASG_AGGR.SET_PAYE_AGGR: ';

l_paye_profile varchar2(30);
l_paye_agg varchar2(2) := 'N';
l_obj_version_num number;
l_employee_number varchar2(50);

l_asg_count number := 0;
l_curr_tax_district varchar2(30);
l_same_paye_det_count number := 0;

r_curr_asg_paye current_asg_paye_details%rowtype;
r_agg_paye get_paye_details%rowtype;

l_person_effective_date date;

l_pers_dt_mode varchar2(30);
l_effective_start_date date;
l_effective_end_date date;
l_full_name per_all_people_f.full_name%type;
l_comment_id per_all_people_f.comment_id%type;
l_name_combination_warning boolean;
l_assign_payroll_warning boolean;
l_orig_hire_warning boolean;

BEGIN
 hr_utility.set_location(' Entering:'||l_proc, 10);

 savepoint start_agg_flag;
 G_VALIDATION_FAILURE := false;
 G_WHO_CALLED := null;

 fnd_profile.get('GB_DEFAULT_AGG_FLAG',l_paye_profile);
 if (nvl(l_paye_profile,'~') = 'PAYE') then

    hr_utility.set_location(l_proc, 20);
    open cur_get_aggr_flag(p_person_id, p_effective_date);
    fetch cur_get_aggr_flag into  l_paye_agg, l_obj_version_num, l_employee_number;
    close cur_get_aggr_flag;

    if (nvl(l_paye_agg,'N') <> 'Y') then

      hr_utility.set_location(l_proc, 25);
      open cur_asg_count(p_person_id, p_effective_date);
      fetch cur_asg_count into  l_asg_count;
      close cur_asg_count;

      /* Check if this is the secondary assignment */
      if (l_asg_count > 1) then

        hr_utility.set_location(l_proc, 30);
        G_WHO_CALLED := 'PER_ASG_AGGR.SET_PAYE_AGGR';

        if p_payroll_id is null then
           hr_utility.set_message(800,'HR_78102_DIFF_TAX_DIST');
           G_VALIDATION_FAILURE := true;
           hr_utility.raise_error;
        end if;
        hr_utility.set_location(l_proc, 35);

        open get_curr_td_info(p_assignment_id, p_effective_date);
        fetch get_curr_td_info into  l_curr_tax_district;
        close get_curr_td_info;

        if l_curr_tax_district is null then
           hr_utility.set_message(800,'HR_78102_DIFF_TAX_DIST');
           G_VALIDATION_FAILURE := true;
           hr_utility.raise_error;
        end if;
        hr_utility.set_location(l_proc, 40);

        open current_asg_paye_details(p_assignment_id, p_effective_date);
        fetch current_asg_paye_details into r_curr_asg_paye;
        close current_asg_paye_details;
        hr_utility.set_location(l_proc, 45);

        for rec_paye in get_paye_details(p_person_id, l_curr_tax_district, p_effective_date, p_assignment_id)
        loop
            /* Multiple PAYE details for the same Tax district, then error */
            if (l_same_paye_det_count = 1) then
               hr_utility.set_message(801,'HR_78110_DIFF_PAYE_VALUES');
               G_VALIDATION_FAILURE := true;
               hr_utility.raise_error;
            end if;
            l_same_paye_det_count := l_same_paye_det_count + 1;
            r_agg_paye.Tax_Code := rec_paye.Tax_Code;
            r_agg_paye.Tax_Basis := rec_paye.Tax_Basis;
            r_agg_paye.Refundable := rec_paye.Refundable;
            r_agg_paye.Pay_Previous := rec_paye.Pay_Previous;
            r_agg_paye.Tax_Previous := rec_paye.Tax_Previous;
            r_agg_paye.Authority := rec_paye.Authority;
        end loop;

        if (l_same_paye_det_count = 0) then
           hr_utility.set_message(800,'HR_78102_DIFF_TAX_DIST');
           G_VALIDATION_FAILURE := true;
           hr_utility.raise_error;
        end if;
        hr_utility.set_location(l_proc, 50);

        open get_tax_basis_code('GB_TAX_BASIS', r_agg_paye.Tax_Basis);
        fetch get_tax_basis_code into r_agg_paye.Tax_Basis;
        close get_tax_basis_code;
        open get_tax_basis_code('GB_TAX_BASIS', r_curr_asg_paye.Tax_Basis);
        fetch get_tax_basis_code into r_curr_asg_paye.Tax_Basis;
        close get_tax_basis_code;

        open get_tax_basis_code('GB_REFUNDABLE', r_agg_paye.Refundable);
        fetch get_tax_basis_code into r_agg_paye.Refundable;
        close get_tax_basis_code;
        open get_tax_basis_code('GB_REFUNDABLE', r_curr_asg_paye.Refundable);
        fetch get_tax_basis_code into r_curr_asg_paye.Refundable;
        close get_tax_basis_code;

        hr_utility.set_location(l_proc, 60);
        if ((nvl(r_agg_paye.Tax_Code,'~') <> nvl(r_curr_asg_paye.Tax_Code,'~')) or
            (nvl(r_agg_paye.Tax_Basis,'~') <> nvl(r_curr_asg_paye.Tax_Basis,'~')) or
            (nvl(r_agg_paye.Refundable,'~') <> nvl(r_curr_asg_paye.Refundable,'~')) or
            (nvl(r_agg_paye.Pay_Previous,'~') <> nvl(r_curr_asg_paye.Pay_Previous,'~')) or
            (nvl(r_agg_paye.Tax_Previous,'~') <> nvl(r_curr_asg_paye.Tax_Previous,'~')) or
            (nvl(r_agg_paye.Authority,'~') <> nvl(r_curr_asg_paye.Authority,'~'))) then
          hr_utility.set_location(l_proc, 70);
          hr_entry_api.update_element_entry(p_dt_update_mode => 'CORRECTION',
                            p_session_date  => p_effective_date,
                            p_element_entry_id => r_curr_asg_paye.element_entry_id,
                            p_input_value_id1 => r_curr_asg_paye.Tax_Code_iv_id,
                            p_input_value_id2 => r_curr_asg_paye.Tax_Basis_iv_id,
                            p_input_value_id3 => r_curr_asg_paye.Pay_Previous_iv_id,
                            p_input_value_id4 => r_curr_asg_paye.Tax_Previous_iv_id,
                            p_input_value_id5 => r_curr_asg_paye.Refundable_iv_id,
                            p_input_value_id6 => r_curr_asg_paye.Authority_iv_id,
                            p_entry_value1 => r_agg_paye.Tax_Code,
                            p_entry_value2 => r_agg_paye.Tax_Basis,
                            p_entry_value3 => r_agg_paye.Pay_Previous,
                            p_entry_value4 => r_agg_paye.Tax_Previous,
                            p_entry_value5 => r_agg_paye.Refundable,
                            p_entry_value6 => r_agg_paye.Authority );

        end if;

        l_person_effective_date := p_effective_date;

        hr_utility.set_location(l_proc, 80);
        for rec in people_dt_records(p_person_id, p_effective_date)
        loop
          /* From second iteration, effective date is set to effec_start_date of the record. */
          if (l_person_effective_date <> p_effective_date) then
             l_person_effective_date := rec.effective_start_date;
          end if;

          /* Idenfity the date track mode to be used. */
          if (rec.effective_start_date <> l_person_effective_date) then
             if (rec.effective_end_date = hr_api.g_eot) then
                l_pers_dt_mode := 'UPDATE';
             else
                l_pers_dt_mode := 'UPDATE_CHANGE_INSERT';
             end if;
          else
             l_pers_dt_mode := 'CORRECTION';
          end if;

          /* Call API to update PAYE Agg flag, this will fire validations from check_aggr_assg. */
          hr_person_api.update_person(p_validate => false
          ,p_effective_date  =>  l_person_effective_date
          ,p_datetrack_update_mode => l_pers_dt_mode
          ,p_person_id => p_person_id
          ,p_object_version_number => rec.object_version_number
          ,p_employee_number => l_employee_number
          ,p_effective_start_date => l_effective_start_date
          ,p_effective_end_date => l_effective_end_date
          ,p_per_information9 => 'Y'
          ,p_per_information10 => 'Y'
          ,p_full_name => rec.full_name
          ,p_comment_id => l_comment_id
          ,p_name_combination_warning => l_name_combination_warning
          ,p_assign_payroll_warning => l_assign_payroll_warning
          ,p_orig_hire_warning => l_orig_hire_warning
          );

          /* Reset/change the variable */
          l_person_effective_date := rec.effective_start_date;

        end loop; -- Records in per_all_people_f which need to be updated.

      hr_utility.set_location(l_proc, 90);
      end if; -- If secondary assignment
    end if; -- PAYE Agg not set already
 end if; -- Profile set
hr_utility.set_location(' Leaving:'||l_proc, 100);

exception
when others then
if G_VALIDATION_FAILURE then
   rollback to start_agg_flag;
   hr_utility.set_warning;
else
   raise;
end if;

END SET_PAYE_AGGR;

--
/* Name: get_paye_agg_status
   Details: This function is called from PERGBOBJ.fmb, for POST-INSERT event of secondary Assignment.
   Return: This will return the Error Message Name and Application, if any validations for PAYE Agg
           failed. Else it will return null. Return values are used in PERGBOBJ.fmb to show appropriate
           warning message to user. */
FUNCTION get_paye_agg_status(p_person_id IN NUMBER,
                          p_effective_date IN DATE,
                          p_assignment_id IN NUMBER,
                          p_payroll_id IN NUMBER) return varchar2
is
l_msg_name varchar2(100);
l_msg_appl varchar2(100);
l_proc varchar2(60) := 'PER_ASG_AGGR.GET_PAYE_AGG_STATUS';
begin
 hr_utility.set_location(' Entering:'||l_proc, 1);

 PER_ASG_AGGR.SET_PAYE_AGGR(p_person_id, p_effective_date, p_assignment_id, p_payroll_id);

 if G_VALIDATION_FAILURE then
    hr_utility.set_location(l_proc, 2);
    hr_utility.get_message_details(l_msg_name, l_msg_appl);
    G_VALIDATION_FAILURE := false;
    return l_msg_appl||':'||l_msg_name;
 end if;

 hr_utility.set_location(l_proc, 3);
 return null;
end get_paye_agg_status;
--
END per_asg_aggr;

/
