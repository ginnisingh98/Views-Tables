--------------------------------------------------------
--  DDL for Package Body PAY_GTNLOD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_GTNLOD_PKG" as
/* $Header: pygtnlod.pkb 120.12.12010000.6 2009/09/16 09:16:09 kagangul ship $ */
/*
   Copyright (c) Oracle Corporation 1991,1992,1993. All rights reserved
--
   Name        :This package defines the cursors needed for GTN to run Multi-Threaded
--
   Change List
   -----------
   Date         Name        Vers   Description
   -----------  ----------  -----  -----------------------------------
   21-NOV-1999  ssarma      40.0   created
   19-oct-2000  tclewis     115.1  added procedure load_wc_er_liab
                                   to load workers compensation ...
                                   (wc2 and wc3) ER liabilities into
                                   the pay_reports_totals table to be
                                   displayed in the GTN report.
   02-jan-2001  tmehra      115.2  Added procedure 'load_alien_earnings'
                                   to reflect 'Alien/Expat Earnings' also
                                   modified procedure 'ee_lod_dedutions'
                                   to reflect 'Alien/Expat Deductions'
   09-OCT-2001  tclewis     115.5  Modified load_prepay procedure to run
                                   Multi threaded.
   31-JAN-2002  tclewis     115.6  Modified the load_ee_tax specificall the
                                   query of local taxes to join to the
                                   ppa_year_effective_date of the
                                   pay_us_local_taxes_v views, to eliminate
                                   local taxes being reporting incorrectly.
                                   Bug 2060255.   Modified the load_message
                                   lines routine, adding a cursor look around
                                   the outer cursor, to check each row in the
                                   pay_pre_payments table With Out payments.
   19-FEB-2002  tclewis     115.9  Change label "Number of Incomplete Payments'
                                   to "Incomplete Payments" and
                                   "Number of Complete Payments" back to
                                   "Disbursements".
   16-MAY-2002  ahanda      115.10 Added session var to supress PTD balance calls.
   22-MAY-2002  sodhingr    115.11 For bug 2304091- Modified the cursor ee_tax
			           removed the join with column paa_year_effective_date as
				   the view pay_us_local_taxes_v has been changed (removed the
				   inline view).
   10-JUL-2002  tclewis     115.12 modified load_prepay,  when inserting data into
				   pay_us_rpt_totals also load pay_pre_payments.pre_payment_id
                            	   into the pay_us_rpt_totals.location_id (an indexed column).
                            	   New logic to look for the Pre_payment_id in the table
                            	   before inserting.  This will eliminate duplicates.
                            	   added same functionality to load_mesg_line for the count
                            	   of unpaid pre-payments.
   29-APR-2003  rsirigir    115.13 Bug 1937448,modified the appropriate select
                                   statements in the cursor ee_tax, cursor er_tax
                                   to include state name,school_district_name,county_name,
                                   city_name to user reporting name
   10-JUN-2002  tclewis     115.15 modified the load_er_liab procedures cursor
                            	   to join to pet.business_group_id.

   04-AUG-2003 irgonzal     115.16 Bug fix 3046274. Amended cursor prepay
                                   and added new condition to process only
                                   one "run" asg action.
   18-NOV-2003 rmonge       115.20 Fix for bug 3168646.  Modified the load_prepay
                                   program. Added new query to select the maximum
                                   assignment_action_id for the payroll runs being
                                   processed including the ones for Suplemental
                                   runs with a separate check set to yes.
  20-NOV-2003  irgonzal     115.22 Added the School District code and state abreviation
                                   when displaying SD withheld (3271447).
   6-NOV-2003 tlewis        115.17 Added code to Load EE Credit to handle State EIC.
  14-APR-2004 schauhan      115.25 Modified the appropiate select statement in the cursor
                                   ee_tax to include state_name,school_district_name,county_name
                                   and city_name to user_reporting_name.Bug3553730
  16-APR-2004 schauhan      115.26 Bug 3543649. Changed the query for the cursor prepay in the procedure
                                   load_prepay so that query also returns third party payments.
  04-MAY-2004 irgonzal      115.27 Bug fix 3270485. Modified load_data procedure and commented
                                   out the insert into rpt totals.
  05-May-2004 irgonzal      115.28 Fixed GSCC errors.
  22-JUL-2004 saurgupt      115.29 Bug 3369218: Modified cursor er_liab in procedure load_er_liab
                                   to remove FTS on pay_element_types_f
  29-SEP-2004 saurgupt      115.30 Bug 3873069: Modified cursor er_liab of procedure load_er_liab
                                   and cursor wc_er_liab of procedure load_wc_er_liab. The condition
                                   pet.element_name = pbt.balance_name is modified to
                                   pet.element_information10 = pbt.balance_type_id. This condition will
                                   work even if balance_name of primary balance of element is not
                                   equal to element_name.
  09-DEC-2004 sgajula       115.31 Changed the procedures to implement BRA.
  11-DEC-2004 sgajula       115.32 Changed the bulk insert block to Simple Insert
  09-FEB-2005 rdhingra      115.33 Reset varibale l_status to 0 in deduction region
  05-Mar-2005 rdhingra      115.34 Changed ee_or_er_code = 'ER' in load_er_tax
  01-JUL-2005 tclewis       115.35 On Behalf of sackumar and saurgupt.  Implemened
                                   changes for bug 3774591.  First change in the
                                   load_mesg_line  added code to check for the existance
                                   of a pre-payment assignment action before counting
                                   a payroll run as a unprocessed prepayment.
                                   The second issue is to modify the load_prepay
                                   In the code to determine the max_action_sequence
                                   assignment action, added a check for the existence
                                   of run results when pulling the max_action_sequece.
 18-Jul-2005 sackumar      115.36  For Bug No 4429173. Change the condition for checking the
				   source_action_id in load_prepay procedure.
 29-Aug-2005 rdhingra      115.37  For Bug No 4568652. Modified cursor cv of procedure
                                   load_er_liab.
                                   The condition pet.element_name = pbt.balance_name is modified to
                                   pet.element_information10 = pbt.balance_type_id.
 29-Aug-2005 sackumar      115.38  For Performance Bug No 4344971.
				   Introduced Index Hint in the SQL ID 12201224 and 12201189
 12-SEP-2005 pragupta      115.39  Bug 4534407: Changed the attribute1 in the g_totals_table in
                                   the load_er_liab procedure from 'EE-CREDIT' to 'ER-LIAB'. Also
                                   added an extra condition in the l_er_liab_where variable.
16-SEP-2005 rdhingra      115.40  Added a distinct clause in cursor cv of procedure load_er_liab
02-FEB-2006 schauhan      115.41  Changed the dimension for FUTA CREDIT from ASG_GRE_RUN to ASG_JD_GRE_RUN
                                   and passed jurisdiction_code to balance call. Bug 4443935.
21-MAR-2006 schauhan      115.42  Bug 5021468.
10-May-2006 sackumar      115.43  Bug 5068645. modified the dynamic query in load_er_tax procedure.
24-May-2006 sackumar      115.44  Bug 5244469. modified the dynamic query in load_er_tax procedure.
11-AUG-2006 saurgupt      115.45  Bug 5409416: Modified the procedure load_er_credit. Removed
                                  prr.jurisdiction_code from select clause as this will fail if l_futa_from
                                  is pay_run_balances table.
16-OCT-2006 jdevasah      115.46  Bug 4942114: Dynamic cursors in procedures load_deductions, load_earnings,
                                  load_ee_tax, load_er_tax, load_ee_credit, load_er_credit, load_er_liab
				  and load_wc_er_liab are replaced by static procedures. Input parameters
				  to all the above procedures are changed to status flags instead
				  from respective view names.

16-OCT-2006 jdevasah      115.46  Bug 6998211: Restricted GRE Name to 228 chars as report showing
                                  blank when we give gre_name more than 228 chars.
25-Jan-2009 sudedas       115.48  Bug# 7831012: Procedure load_earnings modified. Changed
                                  cursors csr_earn_rbr, csr_earn to add Alien/Expat earnings.
20-Apr-2009 kagangul      115.49  Bug# 8363373: Introducing function get_state_name, get_county_name
                                  and get_city_name to get the names based on jurisdiction code.
				  This will help distinguishing the City Withheld for same city name
				  but in different state/county.
16-Sep-2009 kagangul	  115.51  Bug# 8913221: Adding State name and Jurisdiction code with County
				  Tax and State name and Jurisdiction code with Head Tax
*/
------------------------------------- Global Varaibles ---------------------------
l_start_date               pay_payroll_actions.start_date%type;
l_end_date                 pay_payroll_actions.effective_date%type;
l_business_group_id        pay_payroll_actions.business_group_id%type;
l_payroll_action_id        pay_payroll_actions.payroll_action_id%type;
l_effective_date           pay_payroll_actions.effective_date%type;
l_action_type              pay_payroll_actions.action_type%type;
l_assignment_action_id     pay_assignment_actions.assignment_action_id%type;
l_assignment_id            pay_assignment_actions.assignment_id%type;
l_tax_unit_id              hr_organization_units.organization_id%type;
l_person_id                per_all_people_f.person_id%TYPE;             -- #1937448
l_assignment_number        per_all_assignments_f.assignment_number%TYPE;
l_gre_name                 hr_organization_units.name%type;
l_organization_id          hr_organization_units.organization_id%type;
l_org_name                 hr_organization_units.name%type;
l_location_id              hr_locations.location_id%type;
l_location_code            hr_locations.location_code%type;
l_ppp_assignment_action_id pay_assignment_actions.assignment_action_id%type;
l_bal_value                number(20,2);
l_leg_param                varchar2(240);
l_leg_start_date           date;
l_leg_end_date             date;
t_payroll_id               number(15);
t_consolidation_set_id     number(15);
t_gre_id                   number(15);
t_payroll_action_id        pay_payroll_actions.payroll_action_id%type;
l_defined_balance_id       number;
l_row_count                number;
l_full_name                per_all_people_f.full_name%TYPE;
l_asg_flag                 varchar2(1);

----------------------------------------------------------------------------------
/*-- Bug#4942114 starts -- */
 -- procedure load_deductions (l_assignment_action_id number,l_ded_view_name varchar2) is
 -- TYPE cv_typ IS REF CURSOR;
 -- cv cv_typ;

 procedure load_deductions (l_assignment_action_id number,p_ded_bal_status1 varchar2,p_ded_bal_status2 varchar2) is
 cursor csr_ded is
 select classification_name,
  decode(classification_name,'Pre-Tax Deductions','1','Involuntary Deductions','2','Voluntary Deductions','3','9')subclass,
  element_name,
  RUN_VALUE cash_value
  from PAY_US_GTN_DEDUCT_V
  where assignment_action_id =l_assignment_action_id
  and classification_name in ('Pre-Tax Deductions',
                              'Involuntary Deductions',
                              'Voluntary Deductions');

Cursor csr_ded_rbr is
select classification_name,
  decode(classification_name,'Pre-Tax Deductions','1','Involuntary Deductions','2','Voluntary Deductions','3','9')subclass,
  element_name,
  RUN_VALUE cash_value
  from PAY_US_ASG_RUN_DED_RBR_V
  where assignment_action_id =l_assignment_action_id
  and classification_name in ('Pre-Tax Deductions',
                              'Involuntary Deductions',
                              'Voluntary Deductions');
 /*-- Bug#4942114 ends -- */

 l_classification_name varchar2(100);
 l_element_name varchar2(100);
 l_cash_value varchar2(100);
 l_hours_value varchar2(100);
 l_subclass varchar2(5);
 l_ded_temp varchar2(2000);
 l_status number :=0;

 BEGIN
/*-- Bug#4942114 starts -- */
  /* hr_utility.trace('view name = '|| l_ded_view_name);

     OPEN cv FOR
 'select classification_name,
                decode(classification_name,'||'''Pre-Tax Deductions'''||','||'''1'''||','||'''Involuntary Deductions'''||','||'''2'''||','||'''Voluntary Deductions'''||','||'''3'''||','||'''9'''||')subclass,
                element_name,
                RUN_VALUE cash_value
  from '||l_ded_view_name||
  ' where assignment_action_id ='|| l_assignment_action_id||
  '  and classification_name in ('||'''Pre-Tax Deductions'''||','
                                        ||'''Involuntary Deductions'''||','||
                                        '''Voluntary Deductions'''||')';

  hr_utility.trace('statement build success');
  */
  hr_utility.trace('Balance Status1 = '|| p_ded_bal_status1);
  hr_utility.trace('Balance Status2 = '|| p_ded_bal_status2);

  if p_ded_bal_status1 = 'Y' AND p_ded_bal_status2 = 'Y' THEN
   open csr_ded_rbr;
  else
   open csr_ded;
  end if;

  LOOP

    if p_ded_bal_status1 = 'Y' AND p_ded_bal_status2 = 'Y' THEN
       FETCH csr_ded_rbr INTO l_classification_name,l_subclass,l_element_name,l_cash_value;
       EXIT WHEN csr_ded_rbr%NOTFOUND;
    else
       FETCH csr_ded INTO l_classification_name,l_subclass,l_element_name,l_cash_value;
       EXIT WHEN csr_ded%NOTFOUND;
    end if;
    hr_utility.trace('-'||l_classification_name||'+'||l_subclass||'+'||l_element_name||'+'||l_cash_value||'-');

    /*          FETCH cv INTO l_classification_name,l_subclass,l_element_name,l_cash_value;
     hr_utility.trace('-'||l_classification_name||'+'||l_subclass||'+'||l_element_name||'+'||l_cash_value||'-');
     EXIT WHEN cv%NOTFOUND;
    */
 /*-- Bug#4942114 ends -- */
    if l_asg_flag <> 'Y' THEN
       if l_index <>0 then
         l_status := 0;
         for l_temp_index in g_totals_table.first..g_totals_table.last LOOP
           if g_totals_table(l_temp_index).attribute5 = l_element_name
              and g_totals_table(l_temp_index).gre_name = l_gre_name
              and g_totals_table(l_temp_index).organization_name = l_org_name
              and g_totals_table(l_temp_index).location_name = l_location_code then
                 hr_utility.trace('testing 1');
                 g_totals_table(l_temp_index).value2 := g_totals_table(l_temp_index).value2 +
                                                          to_number(l_cash_value);
		 hr_utility.trace('for deductions...l_index ='||l_index);
		 hr_utility.trace('element name ='||l_element_name);
		 hr_utility.trace('payroll action='||to_char(g_totals_table(l_index).tax_unit_id));
		 hr_utility.trace('gre_name='||l_gre_name);
		 hr_utility.trace('org name='||l_org_name);
	         hr_utility.trace('location='||l_location_code);
	         hr_utility.trace('Toal Cash value ='||to_char(g_totals_table(l_temp_index).value2));
	         hr_utility.trace('Cash Value ='||l_cash_value);
                 l_status := 1;
           end if;
         end loop;
       end if;
       if l_status <> 1 or l_index = 0 then
          l_index := l_index + 1;
	  g_totals_table(l_index).gre_name := l_gre_name;
	  g_totals_table(l_index).organization_name := l_org_name;
	  g_totals_table(l_index).location_name := l_location_code;
	  g_totals_table(l_index).tax_unit_id := l_payroll_action_id;
	  g_totals_table(l_index).attribute4 := l_classification_name;
	  g_totals_table(l_index).attribute3 := l_subclass;
	  g_totals_table(l_index).attribute5 := l_element_name;
	  g_totals_table(l_index).value2 := to_number(l_cash_value);
	  g_totals_table(l_index).value3 := NULL;
	  g_totals_table(l_index).attribute1 := 'DEDUCTIONS';
	  g_totals_table(l_index).attribute2 := '4';
	  hr_utility.trace('for deductions...l_index ='||l_index);
	  hr_utility.trace('element name ='||l_element_name);
	  hr_utility.trace('payroll action='||to_char(l_payroll_action_id));
	  hr_utility.trace('gre_name='||l_gre_name);
	  hr_utility.trace('org name='||l_org_name);
	  hr_utility.trace('location='||l_location_code);
	  hr_utility.trace('Cash Value ='||l_cash_value);
       end if;
    else
       insert into pay_us_rpt_totals
         (tax_unit_id,
	  gre_name,
	  organization_name,
	  location_name,
          attribute1,
          value1,
          attribute2,
          attribute3,
          attribute4,
          attribute5,
          value2,
          organization_id,
          business_group_id,
          attribute12)
       values
          (l_payroll_action_id,
	   l_gre_name,
	   l_org_name,
	   l_location_code,
           'DEDUCTIONS',
           l_payroll_action_id,
           '4',
           l_subclass,
           l_classification_name,
           l_element_name,
           l_cash_value,
           l_assignment_action_id,
           l_person_id,
           l_full_name
          );
    end if;
  end loop;

  if p_ded_bal_status1 = 'Y' AND p_ded_bal_status2 = 'Y' THEN
     close csr_ded_rbr;
  else
     close csr_ded;
  end if;
  --      close cv;
  hr_utility.trace('l_index ='||to_char(l_index));
 exception
   when others then
     hr_utility.trace('Error occurred load_deductions ...' ||SQLERRM);
   raise;
 end load_deductions;


/*-- Bug#4942114 starts -- */
-- procedure load_earnings (l_assignment_action_id number,l_earn_view_name varchar2) is
-- TYPE cv_typ IS REF CURSOR;
--    cv cv_typ;

procedure load_earnings  (l_assignment_action_id number,p_earn_bal_status varchar2) is

 cursor csr_earn_rbr is
  select classification_name,
         decode(classification_name,'Earnings','1',
	                            'Imputed Earnings','2',
				    'Supplemental Earnings','3',
				    'Non-payroll Payments','4',
                            'Alien/Expat Earnings', '5',
				    '9')subclass,
         element_name,
         cash_value cash_value,
         hours_value hours_value
  from PAY_US_ASG_RUN_EARN_AMT_RBR_V
  where assignment_action_id = l_assignment_action_id
        and classification_name in ('Earnings',
                                    'Imputed Earnings',
                                    'Supplemental Earnings',
                                    'Non-payroll Payments',
                                    'Alien/Expat Earnings');

cursor csr_earn is
select /*+ index(pay_us_gtn_earnings_v.ernv.pec , pay_element_classification_pk)
           INDEX(pay_us_gtn_earnings_v.ernv.PETTL PAY_ELEMENT_TYPES_F_TL_PK)
           INDEX(pay_us_gtn_earnings_v.ernv.pet PAY_ELEMENT_TYPES_F_pk)
          */
       classification_name,
       decode(classification_name,'Earnings','1',
                                  'Imputed Earnings','2',
				  'Supplemental Earnings','3',
				  'Non-payroll Payments','4',
                          'Alien/Expat Earnings', '5',
				  '9')subclass,
       element_name,
       cash_value cash_value,
       hours_value hours_value
  from  PAY_US_GTN_EARNINGS_V
  where assignment_action_id = l_assignment_action_id
        and classification_name in ('Earnings',
                                    'Imputed Earnings',
                                    'Supplemental Earnings',
                                    'Non-payroll Payments',
                                    'Alien/Expat Earnings');
/*-- Bug#4942114 ends -- */

 l_classification_name varchar2(100);
 l_element_name varchar2(100);
 l_cash_value varchar2(100);
 l_hours_value varchar2(100);
 l_subclass varchar2(5);
 l_earn_temp varchar2(2000);
 l_status number :=0;
 BEGIN

/*-- Bug#4942114 starts -- */
--   hr_utility.trace('l_earn_view_name = '|| l_earn_view_name);


--      OPEN cv FOR
--  'select /*+ index(pay_us_gtn_earnings_v.ernv.pec , pay_element_classification_pk)
--           INDEX(pay_us_gtn_earnings_v.ernv.PETTL PAY_ELEMENT_TYPES_F_TL_PK)
--           INDEX(pay_us_gtn_earnings_v.ernv.pet PAY_ELEMENT_TYPES_F_pk)
--          */
--	        classification_name,
--                decode(classification_name,'||'''Earnings'''||','||'''1'''||','||'''Imputed Earnings'''||','||'''2'''||','||'''Supplemental Earnings'''||','||'''3'''||','||'''Non-payroll Payments'''||','||'''4'''||','||'''9'''||')subclass,
--                element_name,
--                cash_value cash_value,
--                hours_value hours_value
--  from '||l_earn_view_name||
--  ' where assignment_action_id = '||l_assignment_action_id||
--  '  and classification_name in ('||'''Earnings'''||','
--                                        ||'''Imputed Earnings'''||','||
--                                        '''Supplemental Earnings'''||','
--                                        ||'''Non-payroll Payments'''||')';
--   hr_utility.trace('statement build success');

   if p_earn_bal_status = 'Y' THEN
      open csr_earn_rbr;
   else
      open csr_earn;
   end if;


  LOOP

   if p_earn_bal_status = 'Y' THEN
      FETCH csr_earn_rbr INTO l_classification_name,l_subclass,l_element_name,l_cash_value,l_hours_value;
      EXIT WHEN csr_earn_rbr%NOTFOUND;
   else
      FETCH csr_earn INTO l_classification_name,l_subclass,l_element_name,l_cash_value,l_hours_value;
      EXIT WHEN csr_earn%NOTFOUND;
   end if;
   --       FETCH cv INTO l_classification_name,l_subclass,l_element_name,l_cash_value,l_hours_value;
   --  EXIT WHEN cv%NOTFOUND;

   /*-- Bug#4942114 ends -- */
   if l_asg_flag <> 'Y' THEN
      if l_index <>0 then
         l_status :=0;
         for l_temp_index in g_totals_table.first..g_totals_table.last LOOP
            if g_totals_table(l_temp_index).attribute3 = l_subclass and
               g_totals_table(l_temp_index).attribute4 = l_classification_name and
               g_totals_table(l_temp_index).attribute5 = l_element_name and
               g_totals_table(l_temp_index).gre_name = l_gre_name and
               g_totals_table(l_temp_index).organization_name = l_org_name and
               g_totals_table(l_temp_index).location_name = l_location_code then
                  g_totals_table(l_temp_index).value2 := g_totals_table(l_temp_index).value2 +
                                                                         to_number(l_cash_value);
                  g_totals_table(l_temp_index).value3 := g_totals_table(l_temp_index).value3 +
                                                                         to_number(l_hours_value);
                  l_status := 1;
		  hr_utility.trace('for earnings...l_index ='||l_index);
		  hr_utility.trace('element name ='||l_element_name);
		  hr_utility.trace('payroll action='||to_char(g_totals_table(l_index).tax_unit_id));
		  hr_utility.trace('gre_name='||l_gre_name);
		  hr_utility.trace('org name='||l_org_name);
		  hr_utility.trace('location='||l_location_code);
		  hr_utility.trace('Toal Cash value ='||to_char(g_totals_table(l_temp_index).value2));
		  hr_utility.trace('Cash Value ='||l_cash_value);

            end if;
         end loop;
      end if;
      if l_status <> 1 or l_index = 0 then
         hr_utility.trace('l_status ='||l_status||' l_index ='||l_index);
         l_index := l_index + 1;
	 g_totals_table(l_index).gre_name := l_gre_name;
	 g_totals_table(l_index).organization_name := l_org_name;
	 g_totals_table(l_index).location_name := l_location_code;
	 g_totals_table(l_index).tax_unit_id := l_payroll_action_id;
	 g_totals_table(l_index).attribute4 := l_classification_name;
	 g_totals_table(l_index).attribute3 := l_subclass;
	 g_totals_table(l_index).attribute5 := l_element_name;
	 g_totals_table(l_index).value2 := to_number(l_cash_value);
	 g_totals_table(l_index).value3 := to_number(l_hours_value);
	 g_totals_table(l_index).attribute1 := 'EARNINGS';
	 g_totals_table(l_index).attribute2 := '1';
         hr_utility.trace('for earnings...l_index ='||l_index);
         hr_utility.trace('element name ='||l_element_name);
         hr_utility.trace('payroll action='||to_char(l_payroll_action_id));
         hr_utility.trace('gre_name='||l_gre_name);
         hr_utility.trace('org name='||l_org_name);
         hr_utility.trace('location='||l_location_code);
         hr_utility.trace('Cash Value ='||l_cash_value);
      end if;
   else
      insert into pay_us_rpt_totals
       (tax_unit_id,
        gre_name,
	organization_name,
	location_name,
        attribute1,
        value1,
        attribute2,
        attribute3,
        attribute4,
        attribute5,
        value2,
        value3,
        organization_id,
        business_group_id,
        attribute12)
      values
       (l_payroll_action_id,
        l_gre_name,
	l_org_name,
	l_location_code,
        'EARNINGS',
        l_payroll_action_id,
        '1',
        l_subclass,
        l_classification_name,
        l_element_name,
        l_cash_value,
        l_hours_value,
        l_assignment_action_id,
        l_person_id,
        l_full_name);
   end if;
  end loop;
  /*-- Bug#4942114 starts -- */
  --      close cv;

   if p_earn_bal_status = 'Y' THEN
      close csr_earn_rbr;
   else
      close csr_earn;
   end if;
/*-- Bug#4942114 ends -- */

 exception
    when others then
       hr_utility.trace('Error occurred load_earnings ...' ||SQLERRM);
       raise;
 end load_earnings;
--------------------------------------------------------------
-- Following procedure has been added by tmehra on 02-JAN-2001
-- to reflect 'Alien/Expat Earnings'
--------------------------------------------------------------
-- procedure name : load_alien_earnings
--------------------------------------------------------------
procedure load_alien_earnings (l_assignment_action_id number) is
 cursor ee_earn is
        select /*+ index(pay_us_earnings_amounts_v.pet , pay_element_types_f_pk)*/
	       classification_name,
               5 sub_class,
               element_name,
               run_val cash_value,
               hours_run_val hours_value
         from pay_us_earnings_amounts_v
        where assignment_action_id = l_assignment_action_id
          and classification_name =  'Alien/Expat Earnings';

        ee_earn_rec ee_earn%rowtype;
 begin
      open ee_earn ;
      loop
         fetch ee_earn into ee_earn_rec;
      hr_utility.trace('Number of Earnings Records fetched = '||to_char(ee_earn%ROWCOUNT));
         exit when ee_earn%notfound;
         insert into pay_us_rpt_totals
         (tax_unit_id, gre_name, organization_name, location_name,
          attribute1,
          value1,
          attribute2,
          attribute3,
          attribute4,
          attribute5,
          value2,
          value3,
          organization_id)
         values
         (l_payroll_action_id, l_gre_name, l_org_name, l_location_code,
          'EARNINGS',
          l_payroll_action_id,
          '1',
          ee_earn_rec.sub_class,
          ee_earn_rec.classification_name,
          ee_earn_rec.element_name,
          ee_earn_rec.cash_value,
          ee_earn_rec.hours_value,
          l_assignment_action_id);
      end loop;
      close ee_earn;
exception
          when others then
        hr_utility.trace('Error occurred load_earnings ...' ||SQLERRM);
        raise;
end load_alien_earnings;

FUNCTION get_state_name(p_tax_type_code IN VARCHAR2, p_jurisdiction_code IN VARCHAR2)
RETURN VARCHAR2 IS
ls_state_name pay_us_states.state_name%TYPE := NULL;
BEGIN
   hr_utility.trace('GET_STATE_NAME called');
   hr_utility.trace('p_tax_type_code : ' || p_tax_type_code || ' p_jurisdiction_code : ' || p_jurisdiction_code);
   SELECT state_abbrev INTO ls_state_name
   FROM pay_us_states
   WHERE state_code = substr(p_jurisdiction_code,1,2);

   hr_utility.trace('GET_STATE_NAME returns ' || ls_state_name);
   RETURN ls_state_name;

EXCEPTION
   WHEN OTHERS THEN
      RETURN NULL;
END get_state_name;

FUNCTION get_county_name(p_tax_type_code IN VARCHAR2, p_jurisdiction_code IN VARCHAR2)
RETURN VARCHAR2 IS
ls_county_name pay_us_counties.county_name%TYPE := NULL;
BEGIN
   hr_utility.trace('GET_COUNTY_NAME called');
   hr_utility.trace('p_tax_type_code : ' || p_tax_type_code || ' p_jurisdiction_code : ' || p_jurisdiction_code);
   IF p_tax_type_code = 'COUNTY' THEN
      SELECT county_name INTO ls_county_name
      FROM pay_us_counties
      WHERE state_code = substr(p_jurisdiction_code,1,2)
      AND county_code = substr(p_jurisdiction_code,4,3);

   END IF;
   hr_utility.trace('GET_COUNTY_NAME returns ' || ls_county_name);
   RETURN ls_county_name;
EXCEPTION
   WHEN OTHERS THEN
      RETURN NULL;
END get_county_name;

FUNCTION get_city_name(p_tax_type_code IN VARCHAR2, p_jurisdiction_code IN VARCHAR2)
RETURN VARCHAR2 IS
ls_city_name pay_us_city_names.city_name%TYPE := NULL;
CURSOR c_get_city IS
   SELECT city_name FROM pay_us_city_names
   WHERE state_code = substr(p_jurisdiction_code,1,2)
   AND county_code = substr(p_jurisdiction_code,4,3)
   AND city_code =  substr(p_jurisdiction_code,8,4)
   AND upper(primary_flag) = 'Y';

BEGIN
   hr_utility.trace('GET_CITY_NAME called');
   hr_utility.trace('p_tax_type_code : ' || p_tax_type_code || ' p_jurisdiction_code : ' || p_jurisdiction_code);
   IF p_tax_type_code IN ('CITY','HT') THEN
      OPEN c_get_city;
      FETCH c_get_city INTO ls_city_name;
      CLOSE c_get_city;
   END IF;
   hr_utility.trace('GET_CITY_NAME returns ' || ls_city_name);
   RETURN ls_city_name;
EXCEPTION
   WHEN OTHERS THEN
      RETURN NULL;
END get_city_name;

--------------------------------------------------------------
/*-- Bug#4942114 starts -- */
/* procedure load_ee_tax (l_assignment_action_id number,l_fed_view_name varchar2,
                       l_state_view_name varchar2,l_local_view_name varchar2) is
TYPE cv_typ IS REF CURSOR;
   cv cv_typ; */
procedure load_ee_tax (l_assignment_action_id number,p_fed_bal_status varchar2,p_state_bal_status varchar2,p_local_bal_status varchar2) is
  cursor csr_ee_tax_rbr is
     select user_reporting_name,'1' sub_class,run_val,null,null
     from PAY_US_ASG_RUN_FED_TAX_RBR_V
     where assignment_action_id = l_assignment_action_id
           and ee_or_er_code = 'EE'
           and tax_type_code <> 'EIC'
     UNION ALL
     select user_reporting_name ||'   '|| state_name,'2' sub_class,run_val,TAX_TYPE_CODE,jurisdiction_code
     from PAY_US_ASG_RUN_STATE_TAX_RBR_V
     where assignment_action_id =l_assignment_action_id
           and ee_or_er_code = 'EE'
           and tax_type_code <> 'STEIC'
     UNION ALL
     select /* Bug # 8363373
	     user_reporting_name||'    '||(decode(state_name,'INVALID',null,state_name))||
             '   '|| nvl((decode(school_district_name,'INVALID',null, school_district_name)),
                         nvl((decode(county_name,'INVALID',null,county_name)),
                             (decode(city_name,'INVALID',null,city_name))
                            )
		        )*/
	   /*user_reporting_name||'    '||
	   get_state_name(TAX_TYPE_CODE,jurisdiction_code) || '   ' ||
            nvl((decode(school_district_name,'INVALID',null, school_district_name)),
                 nvl(get_county_name(TAX_TYPE_CODE,jurisdiction_code),
                     get_city_name(TAX_TYPE_CODE,jurisdiction_code))
		)*/
	   /*user_reporting_name*/
	   decode(TAX_TYPE_CODE,'SCHOOL',user_reporting_name,'CITY',user_reporting_name,
	   /* Bug 8913221 : Added the following line */
	                        'COUNTY',user_reporting_name,'HT',user_reporting_name,
	          user_reporting_name||'    '||(decode(state_name,'INVALID',null,state_name))
		  || '   '|| nvl((decode(school_district_name,'INVALID',null, school_district_name)),
				  nvl((decode(county_name,'INVALID',null,county_name)),
				      (decode(city_name,'INVALID',null,city_name))
                                     )
                                )
		 ),
	   '3' sub_class,run_val,
	   TAX_TYPE_CODE,
	   jurisdiction_code
      from PAY_US_ASG_RUN_LOCAL_TAX_RBR_V
      where assignment_action_id = l_assignment_action_id
            and ee_or_er_code = 'EE'
      UNION ALL
      SELECT 'EE Non W2 FIT Withheld',
             '4' sub_class,
             pqp_us_ff_functions.get_nonw2_bal('Non W2 FIT Withheld','run',paa.assignment_action_id,null,paa.tax_unit_id) run_value,
             null,
             null
       FROM  pay_assignment_actions paa
       WHERE pqp_us_ff_functions.is_windstar(null,paa.assignment_id) = 'TRUE'
             AND assignment_action_id = l_assignment_action_id
       UNION ALL
       SELECT  'EE Non W2 SIT Withheld',
	       '4',
	       pqp_us_ff_functions.get_nonw2_bal('SIT Alien Withheld','run',paa.assignment_action_id,state.jurisdiction_code,paa.tax_unit_id) run_value,
	       null,
	       null
	  FROM pay_assignment_actions paa,
	       pay_us_emp_state_tax_rules_f state,
	       pay_payroll_actions ppa
	 WHERE pqp_us_ff_functions.is_windstar(null,paa.assignment_id) = 'TRUE'
	       AND state.assignment_id = paa.assignment_id
	       AND ppa.payroll_action_id = paa.payroll_action_id
	       AND paa.assignment_action_id =l_assignment_action_id
	       AND ppa.effective_date BETWEEN state.effective_start_date AND state.effective_end_date;




   cursor csr_ee_tax is
     select user_reporting_name,'1' sub_class,run_val,null,null
     from PAY_US_FED_TAXES_V
     where assignment_action_id = l_assignment_action_id
           and ee_or_er_code = 'EE'
           and tax_type_code <> 'EIC'
     UNION ALL
     select user_reporting_name ||'   '|| state_name,'2' sub_class,run_val,TAX_TYPE_CODE,jurisdiction_code
     from PAY_US_STATE_TAXES_V
     where assignment_action_id =l_assignment_action_id
           and ee_or_er_code = 'EE'
           and tax_type_code <> 'STEIC'
     UNION ALL
     select /* Bug # 8363373
             user_reporting_name||'    '||(decode(state_name,'INVALID',null,state_name))||
             '   '|| nvl((decode(school_district_name,'INVALID',null, school_district_name)),
                         nvl((decode(county_name,'INVALID',null,county_name)),
                             (decode(city_name,'INVALID',null,city_name))
                            )
		        )*/
	   /*user_reporting_name||'    '||
	   get_state_name(TAX_TYPE_CODE,jurisdiction_code) || '   ' ||
            nvl((decode(school_district_name,'INVALID',null, school_district_name)),
                 nvl(get_county_name(TAX_TYPE_CODE,jurisdiction_code),
                     get_city_name(TAX_TYPE_CODE,jurisdiction_code))
		)*/
	   /*user_reporting_name*/
	   decode(TAX_TYPE_CODE,'SCHOOL',user_reporting_name,'CITY',user_reporting_name,
   	   /* Bug 8913221 : Added the following line */
	                        'COUNTY',user_reporting_name,'HT',user_reporting_name,
	          user_reporting_name||'    '||(decode(state_name,'INVALID',null,state_name))
		  ||'   '|| nvl((decode(school_district_name,'INVALID',null, school_district_name)),
                                nvl((decode(county_name,'INVALID',null,county_name)),
                                    (decode(city_name,'INVALID',null,city_name))
                                   )
		               )
		 ),
	   '3' sub_class,run_val,
	   TAX_TYPE_CODE,
	   jurisdiction_code
      from PAY_US_LOCAL_TAXES_V
      where assignment_action_id = l_assignment_action_id
            and ee_or_er_code = 'EE'
      UNION ALL
      SELECT 'EE Non W2 FIT Withheld',
             '4' sub_class,
             pqp_us_ff_functions.get_nonw2_bal('Non W2 FIT Withheld','run',paa.assignment_action_id,null,paa.tax_unit_id) run_value,
             null,
             null
       FROM  pay_assignment_actions paa
       WHERE pqp_us_ff_functions.is_windstar(null,paa.assignment_id) = 'TRUE'
             AND assignment_action_id = l_assignment_action_id
       UNION ALL
       SELECT  'EE Non W2 SIT Withheld',
	       '4',
	       pqp_us_ff_functions.get_nonw2_bal('SIT Alien Withheld','run',paa.assignment_action_id,state.jurisdiction_code,paa.tax_unit_id) run_value,
	       null,
	       null
	  FROM pay_assignment_actions paa,
	       pay_us_emp_state_tax_rules_f state,
	       pay_payroll_actions ppa
	 WHERE pqp_us_ff_functions.is_windstar(null,paa.assignment_id) = 'TRUE'
	       AND state.assignment_id = paa.assignment_id
	       AND ppa.payroll_action_id = paa.payroll_action_id
	       AND paa.assignment_action_id =l_assignment_action_id
	       AND ppa.effective_date BETWEEN state.effective_start_date AND state.effective_end_date;
/*-- Bug#4942114 ends -- */

l_user_reporting_name varchar2(60);
l_sub_class           varchar2(1);
l_run_val             number(20,2);
l_tax_type_code       varchar2(30);
l_jurisdiction_code   varchar2(11);
l_sd_name             varchar2(30);
l_ee_tax_temp varchar2(3000);
l_status number :=0;
   cursor csr_sd_name(p_state_code varchar2, p_sd_code varchar2)
   is
     select STATE_ABBREV||'-'||SCHOOL_DST_NAME
       from pay_us_school_dsts DS
           ,pay_us_states      st
      where DS.STATE_CODE = p_state_code
        and DS.SCHOOL_DST_CODE = p_sd_code
        and ST.state_code = DS.state_code;
BEGIN
hr_utility.trace('Inside LOAD_EE_TAX');
/*-- Bug#4942114 starts -- */
/* hr_utility.trace('view names = '|| l_fed_view_name || l_state_view_name || l_local_view_name);

OPEN cv FOR
'select user_reporting_name,''1'' sub_class,run_val,null,null
                from '||l_fed_view_name||
                ' where assignment_action_id ='|| l_assignment_action_id||
                ' and ee_or_er_code = ''EE''
                  and tax_type_code <> ''EIC'' UNION ALL
                select user_reporting_name ||''   ''|| state_name,''2'' sub_class,run_val,TAX_TYPE_CODE,jurisdiction_code
                from '||l_state_view_name||
                ' where assignment_action_id ='||l_assignment_action_id||
                ' and ee_or_er_code = ''EE''
                  and tax_type_code <> ''STEIC'' UNION ALL
                select user_reporting_name||''    ''||(decode(state_name,''INVALID'',null,state_name))||
                      ''   ''|| nvl((decode(school_district_name,''INVALID'',null, school_district_name)),
                  nvl(
                     (decode(county_name,''INVALID'',null,county_name)),
                     (decode(city_name,''INVALID'',null,city_name))
                  )),''3'' sub_class,run_val,TAX_TYPE_CODE,jurisdiction_code
                 from '|| l_local_view_name||
                 ' where assignment_action_id = '||l_assignment_action_id||
                 ' and ee_or_er_code = ''EE''
                                            UNION ALL
                 SELECT ''EE Non W2 FIT Withheld''       ,
                         ''4'' sub_class,
                       pqp_us_ff_functions.get_nonw2_bal(''Non W2 FIT Withheld'',''run'',paa.assignment_action_id,null,paa.tax_unit_id) run_value,
                       null,
                       null
                 FROM  pay_assignment_actions paa
                 WHERE pqp_us_ff_functions.is_windstar(null,paa.assignment_id) = ''TRUE''
                 AND assignment_action_id = '||l_assignment_action_id ||' UNION ALL
                       SELECT  ''EE Non W2 SIT Withheld''       ,
		               ''4'',
		               pqp_us_ff_functions.get_nonw2_bal(''SIT Alien Withheld'',''run'',paa.assignment_action_id,state.jurisdiction_code,paa.tax_unit_id) run_value,
		               null,
		               null
		         FROM
		               pay_assignment_actions paa,
		               pay_us_emp_state_tax_rules_f state,
		               pay_payroll_actions ppa
		         WHERE pqp_us_ff_functions.is_windstar(null,paa.assignment_id) = ''TRUE''
		           AND state.assignment_id = paa.assignment_id
		           AND ppa.payroll_action_id = paa.payroll_action_id
		           AND paa.assignment_action_id ='|| l_assignment_action_id||
		         '  AND ppa.effective_date BETWEEN state.effective_start_date AND state.effective_end_date';
   hr_utility.trace('statement build success');
 LOOP
           FETCH cv INTO l_user_reporting_name,l_sub_class,l_run_val
                         , l_tax_type_code, l_jurisdiction_code; */

 if p_fed_bal_status = 'Y' and p_state_bal_status = 'Y'  and p_local_bal_status = 'Y' then
    open csr_ee_tax_rbr;
    hr_utility.trace('Cursor CSR_EE_TAX_RBR Opened');
 else
    open csr_ee_tax;
    hr_utility.trace('Cursor CSR_EE_TAX Opened');
 end if;

 loop

 if p_fed_bal_status = 'Y' and p_state_bal_status = 'Y' and p_local_bal_status = 'Y' then
    FETCH csr_ee_tax_rbr INTO l_user_reporting_name,l_sub_class,l_run_val
                            , l_tax_type_code, l_jurisdiction_code;
     IF csr_ee_tax_rbr%FOUND THEN
	hr_utility.trace('Cursor Record No : ');
	hr_utility.trace(csr_ee_tax_rbr%ROWCOUNT);
     END IF;
    exit when csr_ee_tax_rbr%NOTFOUND;
 else
    FETCH csr_ee_tax INTO l_user_reporting_name,l_sub_class,l_run_val
			, l_tax_type_code, l_jurisdiction_code;
     IF csr_ee_tax%FOUND THEN
	hr_utility.trace('Cursor Record No : ');
	hr_utility.trace(csr_ee_tax%ROWCOUNT);
     END IF;
    exit when csr_ee_tax%NOTFOUND;
 end if;

 hr_utility.trace('l_user_reporting_name : ' || l_user_reporting_name || ', l_sub_class : '
		  || l_sub_class || ', l_run_val : ' || l_run_val || ', l_tax_type_code : ' || l_tax_type_code ||
		  ', l_jurisdiction_code : ' || l_jurisdiction_code);

/*-- Bug#4942114 ends -- */
         if l_tax_type_code = 'SCHOOL' then
            open csr_sd_name(substr(l_jurisdiction_code,1,2), substr(l_jurisdiction_code,4));
            fetch csr_sd_name into l_sd_name;
            if csr_sd_name%found then
               l_user_reporting_name := substr(l_user_reporting_name||' '||
                                               l_jurisdiction_code||' '||l_sd_name,1,60);
            end if;
            close csr_sd_name;
	 /* Added For Bug# 8363373 */
	 ELSIF l_tax_type_code = 'CITY' THEN
	    l_user_reporting_name := substr(l_user_reporting_name ||' '||
				     get_state_name(l_tax_type_code,l_jurisdiction_code) || '-' ||
				     get_city_name(l_tax_type_code,l_jurisdiction_code) || ' ' ||
				     l_jurisdiction_code,1,60);
/* Bug 8913221 : Added the following two condition for Head Tax and County Tax */
	 ELSIF l_tax_type_code = 'HT' THEN
	    l_user_reporting_name := substr(l_user_reporting_name ||' '||
				     get_state_name(l_tax_type_code,l_jurisdiction_code) || '-' ||
				     get_city_name(l_tax_type_code,l_jurisdiction_code) || ' ' ||
				     l_jurisdiction_code,1,60);
	 ELSIF l_tax_type_code = 'COUNTY' THEN
	    l_user_reporting_name := substr(l_user_reporting_name ||' '||
				     get_state_name(l_tax_type_code,l_jurisdiction_code) || '-' ||
				     get_county_name(l_tax_type_code,l_jurisdiction_code) || ' ' ||
				     l_jurisdiction_code,1,60);

         end if;
--      EXIT WHEN cv%NOTFOUND;  /*-- Bug#4942114 -- */
   if l_asg_flag <> 'Y' THEN
      if l_index <>0 then
         l_status :=0;
         for l_temp_index in g_totals_table.first..g_totals_table.last LOOP
             if g_totals_table(l_temp_index).attribute5 = l_user_reporting_name and
		g_totals_table(l_temp_index).gre_name = l_gre_name and
		g_totals_table(l_temp_index).organization_name = l_org_name and
		g_totals_table(l_temp_index).location_name = l_location_code then

		hr_utility.trace('testing 1');
		g_totals_table(l_temp_index).value2 := g_totals_table(l_temp_index).value2 +
                                                      to_number(l_run_val);
		l_status := 1;
		hr_utility.trace('for ee tax...l_index ='||l_index);
		hr_utility.trace('element name ='||l_user_reporting_name);
		hr_utility.trace('payroll action='||to_char(g_totals_table(l_index).tax_unit_id));
		hr_utility.trace('gre_name='||l_gre_name);
		hr_utility.trace('org name='||l_org_name);
		hr_utility.trace('location='||l_location_code);
		hr_utility.trace('Toal Cash value ='||to_char(g_totals_table(l_temp_index).value2));
		hr_utility.trace('Cash Value ='||l_run_val);
             end if;
         end loop;
      end if;
      if l_status <> 1 or l_index = 0 then
          hr_utility.trace('testing 6');
          l_index := l_index + 1;
	  g_totals_table(l_index).gre_name := l_gre_name;
	  g_totals_table(l_index).organization_name := l_org_name;
	  g_totals_table(l_index).location_name := l_location_code;
	  g_totals_table(l_index).tax_unit_id := l_payroll_action_id;
	  g_totals_table(l_index).attribute4 := 'Tax Deductions';
	  g_totals_table(l_index).attribute3 := '1';
	  g_totals_table(l_index).attribute5 := l_user_reporting_name;
	  g_totals_table(l_index).value2 := to_number(l_run_val);
	  g_totals_table(l_index).value3 := NULL;
	  g_totals_table(l_index).attribute1 := 'EE-TAX';
	  g_totals_table(l_index).attribute2 := '2';
      end if;
      hr_utility.trace('for ee tax...l_index ='||l_index);
      hr_utility.trace('element name ='||l_user_reporting_name);
      hr_utility.trace('payroll action='||to_char(l_payroll_action_id));
      hr_utility.trace('gre_name='||l_gre_name);
      hr_utility.trace('org name='||l_org_name);
      hr_utility.trace('location='||l_location_code);
      hr_utility.trace('Cash Value ='||l_run_val);
   else
      hr_utility.trace('Direct Insert into pay_us_rpt_totals');
      insert into pay_us_rpt_totals
         (tax_unit_id, gre_name, organization_name, location_name,
          attribute1,
          value1,
          attribute2,
          attribute3,
          attribute4,
          attribute5,
          value2,
          organization_id,
          business_group_id,
          attribute12)
      values
         (l_payroll_action_id, l_gre_name, l_org_name, l_location_code,
          'EE-TAX',
          l_payroll_action_id,
          '2',
          '1', --l_sub_class,
          'Tax Deductions',
          l_user_reporting_name,
          l_run_val,
          l_assignment_action_id,
          l_person_id,
          l_full_name);
   end if;
End loop;
/*-- Bug#4942114 starts -- */
  if p_fed_bal_status = 'Y' and p_state_bal_status = 'Y'  and p_local_bal_status = 'Y' then
    close csr_ee_tax_rbr;
 else
    close csr_ee_tax;
 end if;
/*-- Bug#4942114 ends -- */
exception
   when others then
      hr_utility.trace('Error occurred load_ee_tax ...' ||SQLERRM);
      raise;
end load_ee_tax;

/*-- Bug#4942114 starts -- */
/* procedure load_er_tax (l_assignment_action_id number,l_fed_liab_view_name varchar2,l_state_liab_view_name varchar2,l_local_liab_view_name varchar2) is
TYPE cv_typ IS REF CURSOR;
   cv cv_typ; */

procedure load_er_tax (l_assignment_action_id number, p_fed_liab_bal_status varchar2,p_state_liab_bal_status varchar2,p_local_bal_status varchar2) is

  cursor csr_er_tax_rbr is
    select user_reporting_name,'1' sub_class,run_val
    from PAY_US_ASG_RUN_FED_LIAB_RBR_V
    where assignment_action_id = l_assignment_action_id
	  and ee_or_er_code = 'ER'
	  and database_item_suffix = decode(upper(user_reporting_name),
                                  'ER FUTA LIABILITY' ,'_ASG_JD_GRE_RUN' ,
				  '_ASG_GRE_RUN')
    UNION ALL
    select user_reporting_name ||'   '|| state_name,'2' sub_class,run_val
    from PAY_US_ASG_RUN_ST_LIAB_RBR_V
    where assignment_action_id =l_assignment_action_id
          and ee_or_er_code = 'ER'
    UNION ALL
    select user_reporting_name||'    '||(decode(state_name,'INVALID',null,state_name))||
                      '   '|| nvl((decode(school_district_name,'INVALID',null, school_district_name)),
				  nvl((decode(county_name,'INVALID',null,county_name)),
                                      (decode(city_name,'INVALID',null,city_name))
                                     )
				  ),
	   '3' sub_class,run_val
   from PAY_US_ASG_RUN_LOCAL_TAX_RBR_V
   where assignment_action_id = l_assignment_action_id
         and ee_or_er_code = 'ER';


  cursor csr_er_tax is
    select user_reporting_name,'1' sub_class,run_val
    from PAY_US_FED_LIABILITIES_V
    where assignment_action_id = l_assignment_action_id
	  and ee_or_er_code = 'ER'
    UNION ALL
    select user_reporting_name ||'   '|| state_name,'2' sub_class,run_val
    from PAY_US_STATE_LIABILITIES_V
    where assignment_action_id =l_assignment_action_id
          and ee_or_er_code = 'ER'
    UNION ALL
    select user_reporting_name||'    '||(decode(state_name,'INVALID',null,state_name))||
                      '   '|| nvl((decode(school_district_name,'INVALID',null, school_district_name)),
				  nvl((decode(county_name,'INVALID',null,county_name)),
                                      (decode(city_name,'INVALID',null,city_name))
                                     )
				  ),
	   '3' sub_class,run_val
   from PAY_US_LOCAL_TAXES_V
   where assignment_action_id = l_assignment_action_id
         and ee_or_er_code = 'ER';

/*-- Bug#4942114 ends -- */
l_user_reporting_name varchar2(60);
l_sub_class           varchar2(1);
l_run_val             number(20,2);
l_tax_type_code       varchar2(30);
l_jurisdiction_code   varchar2(11);
l_sd_name             varchar2(30);
l_status number :=0;
-- lv_sql_query varchar2(3000); -- Bug#4942114
BEGIN
/*-- Bug#4942114 ends -- */
/*    hr_utility.trace('view names = '|| l_fed_liab_view_name || l_state_liab_view_name || l_local_liab_view_name);

lv_sql_query := 'select user_reporting_name,''1'' sub_class,run_val
                from ' || l_fed_liab_view_name ||
                ' where assignment_action_id ='|| l_assignment_action_id||
                ' and ee_or_er_code = ''ER'' ';

if  l_fed_liab_view_name = 'PAY_US_ASG_RUN_FED_LIAB_RBR_V' then
      lv_sql_query := lv_sql_query  || ' and database_item_suffix = decode
							 (
							 upper(user_reporting_name),
		                                         ''ER FUTA LIABILITY'' ,
							 ''_ASG_JD_GRE_RUN'' ,
							 ''_ASG_GRE_RUN''
							 ) ' ;
end if;

lv_sql_query := lv_sql_query  || '  UNION ALL
                select user_reporting_name ||''   ''|| state_name,''2'' sub_class,run_val
                from '||l_state_liab_view_name||
                ' where assignment_action_id ='||l_assignment_action_id||
                ' and ee_or_er_code = ''ER''
                  UNION ALL
                select user_reporting_name||''    ''||(decode(state_name,''INVALID'',null,state_name))||
                      ''   ''|| nvl((decode(school_district_name,''INVALID'',null, school_district_name)),
                  nvl(
                     (decode(county_name,''INVALID'',null,county_name)),
                     (decode(city_name,''INVALID'',null,city_name))
                  )),''3'' sub_class,run_val
                 from '|| l_local_liab_view_name||
                 ' where assignment_action_id = '||l_assignment_action_id||
                 ' and ee_or_er_code = ''ER''';

     OPEN cv FOR lv_sql_query;

   hr_utility.trace('statement build success');
 LOOP
	         fetch cv into l_user_reporting_name, l_sub_class, l_run_val;
	      hr_utility.trace('assignment_Action_id in load_er_tax ='||to_char(l_assignment_action_id));
                 EXIT WHEN cv%NOTFOUND; */

 if p_fed_liab_bal_status = 'Y'  and p_state_liab_bal_status = 'Y' and p_local_bal_status = 'Y' then
    open csr_er_tax_rbr;
else
    open csr_er_tax;
end if;

 loop

    if p_fed_liab_bal_status = 'Y' and p_state_liab_bal_status = 'Y' and p_local_bal_status = 'Y' then
       fetch csr_er_tax_rbr into l_user_reporting_name, l_sub_class, l_run_val;
       EXIT WHEN csr_er_tax_rbr%NOTFOUND;
   else
      fetch csr_er_tax into l_user_reporting_name, l_sub_class, l_run_val;
      EXIT WHEN csr_er_tax%NOTFOUND;
   end if;
    hr_utility.trace('assignment_Action_id in load_er_tax ='||to_char(l_assignment_action_id));
/*-- Bug#4942114 ends -- */


   if l_asg_flag <> 'Y' THEN
      if l_index <>0 then
         l_status :=0;
         for l_temp_index in g_totals_table.first..g_totals_table.last LOOP
	     if g_totals_table(l_temp_index).attribute5 = l_user_reporting_name and
		g_totals_table(l_temp_index).gre_name = l_gre_name and
		g_totals_table(l_temp_index).organization_name = l_org_name and
		g_totals_table(l_temp_index).location_name = l_location_code then

		hr_utility.trace('testing 1');
		g_totals_table(l_temp_index).value2 := g_totals_table(l_temp_index).value2 +
                                                      to_number(l_run_val);
		l_status := 1;
		hr_utility.trace('for er tax...l_index ='||l_index);
		hr_utility.trace('element name ='||l_user_reporting_name);
		hr_utility.trace('payroll action='||to_char(g_totals_table(l_index).tax_unit_id));
		hr_utility.trace('gre_name='||l_gre_name);
		hr_utility.trace('org name='||l_org_name);
		hr_utility.trace('location='||l_location_code);
		hr_utility.trace('Toal Cash value ='||to_char(g_totals_table(l_temp_index).value2));
		hr_utility.trace('Cash Value ='||l_run_val);

             end if;
          end loop;
       end if;
       if l_status <> 1 or l_index = 0 then
          hr_utility.trace('testing 6');
          l_index := l_index + 1;
	  g_totals_table(l_index).gre_name := l_gre_name;
	  g_totals_table(l_index).organization_name := l_org_name;
	  g_totals_table(l_index).location_name := l_location_code;
	  g_totals_table(l_index).tax_unit_id := l_payroll_action_id;
	  g_totals_table(l_index).attribute4 := 'Employer Taxes';
	  g_totals_table(l_index).attribute3 := '1';
	  g_totals_table(l_index).attribute5 := l_user_reporting_name;
	  g_totals_table(l_index).value2 := to_number(l_run_val);
	  g_totals_table(l_index).value3 := NULL;
	  g_totals_table(l_index).attribute1 := 'ER-TAX';
	  g_totals_table(l_index).attribute2 := '6';
	  hr_utility.trace('for er tax...l_index ='||l_index);
	  hr_utility.trace('element name ='||l_user_reporting_name);
	  hr_utility.trace('payroll action='||to_char(l_payroll_action_id));
	  hr_utility.trace('gre_name='||l_gre_name);
	  hr_utility.trace('org name='||l_org_name);
	  hr_utility.trace('location='||l_location_code);
	  hr_utility.trace('Cash Value ='||l_run_val);
       end if;
    else
          insert into pay_us_rpt_totals
	         ( tax_unit_id, gre_name, organization_name, location_name,
	          attribute1,
	          value1,
	          attribute2,
	          attribute3,
	          attribute4,
	          attribute5,
	          value2,
	          organization_id,
	          business_group_id,
	          attribute12)
	    values
	         (l_payroll_action_id, l_gre_name, l_org_name, l_location_code,
	          'ER-TAX',
	          l_payroll_action_id,
	          '6',
	          '1', --l_sub_class,
	          'Employer Taxes',
	          l_user_reporting_name,
	          l_run_val,
	          l_assignment_action_id,
	          l_person_id,
	          l_full_name);
    end if;
 end loop;
 /*-- Bug#4942114 ends -- */
  if p_fed_liab_bal_status = 'Y'  and p_state_liab_bal_status = 'Y' and p_local_bal_status = 'Y' then
    close csr_er_tax_rbr;
else
    close csr_er_tax;
end if;

 /*-- Bug#4942114 ends -- */
 hr_utility.trace('Leaving load_er_tax');
exception
   when others then
      hr_utility.trace('Error occurred load_er_tax ...' ||SQLERRM);
      raise;
end load_er_tax;
--------------------------------------------------------------------------------
/*-- Bug#4942114 starts -- */
/* procedure load_ee_credit (l_assignment_action_id number,l_fed_view_name varchar2,l_state_view_name varchar2) is
TYPE cv_typ IS REF CURSOR;
   cv cv_typ; */

 procedure load_ee_credit (l_assignment_action_id number,p_fed_bal_status varchar2, p_state_bal_status varchar2) is

      cursor csr_ee_credit_rbr is
          select user_reporting_name,run_val
          from PAY_US_ASG_RUN_FED_TAX_RBR_V
          where assignment_action_id = l_assignment_action_id
                and ee_or_er_code = 'EE'
                and tax_type_code = 'EIC'
	  UNION ALL
          select user_reporting_name ,run_val
          from PAY_US_ASG_RUN_STATE_TAX_RBR_V
          where assignment_action_id =l_assignment_action_id
                and ee_or_er_code = 'EE'
                and tax_type_code = 'STEIC';

     cursor csr_ee_credit is
	  select user_reporting_name,run_val
          from PAY_US_FED_TAXES_V
          where assignment_action_id = l_assignment_action_id
                and ee_or_er_code = 'EE'
                and tax_type_code = 'EIC'
	  UNION ALL
          select user_reporting_name ,run_val
          from PAY_US_STATE_TAXES_V
          where assignment_action_id =l_assignment_action_id
                and ee_or_er_code = 'EE'
                and tax_type_code = 'STEIC';

/*-- Bug#4942114 ends -- */

l_state_bal_status  varchar2(1);
l_user_reporting_name varchar2(60);
l_run_val             number(20,2);
l_status number :=0;
BEGIN
/*-- Bug#4942114 starts -- */
 /*    hr_utility.trace('view names = '|| l_fed_view_name || l_state_view_name);
     OPEN cv FOR
		'select user_reporting_name,run_val
                from '||l_fed_view_name||
                ' where assignment_action_id ='|| l_assignment_action_id||
                ' and ee_or_er_code = ''EE''
                  and tax_type_code = ''EIC'' UNION ALL
                select user_reporting_name ,run_val
                from '||l_state_view_name||
                ' where assignment_action_id ='||l_assignment_action_id||
                ' and ee_or_er_code = ''EE''
                  and tax_type_code = ''STEIC''';
   hr_utility.trace('statement build success');
      loop
         fetch cv into l_user_reporting_name, l_run_val;
         exit when cv%notfound;  */

   IF p_fed_bal_status = 'Y' and  p_state_bal_status = 'Y' then
      open csr_ee_credit_rbr;
   else
      open csr_ee_credit;
   end if;


  loop
     IF p_fed_bal_status = 'Y' and p_state_bal_status = 'Y' then
        fetch csr_ee_credit_rbr into l_user_reporting_name, l_run_val;
        exit when csr_ee_credit_rbr%notfound;
     else
        fetch csr_ee_credit into l_user_reporting_name, l_run_val;
        exit when csr_ee_credit%notfound;
     END IF;
/*-- Bug#4942114 ends -- */

     if l_asg_flag <> 'Y' THEN
        if l_index <>0 then
           l_status :=0;
           for l_temp_index in g_totals_table.first..g_totals_table.last LOOP
	      if g_totals_table(l_temp_index).attribute5 = l_user_reporting_name and
                 g_totals_table(l_temp_index).gre_name = l_gre_name and
                 g_totals_table(l_temp_index).organization_name = l_org_name and
                 g_totals_table(l_temp_index).location_name = l_location_code then


         g_totals_table(l_temp_index).value2 := g_totals_table(l_temp_index).value2 -
                                                      to_number(l_run_val);
           l_status := 1;
      hr_utility.trace('for er credit...l_index ='||l_index);
      hr_utility.trace('element name ='||l_user_reporting_name);
      hr_utility.trace('payroll action='||to_char(g_totals_table(l_index).tax_unit_id));
      hr_utility.trace('gre_name='||l_gre_name);
      hr_utility.trace('org name='||l_org_name);
      hr_utility.trace('location='||l_location_code);
      hr_utility.trace('Toal Cash value ='||to_char(g_totals_table(l_temp_index).value2));
      hr_utility.trace('Cash Value ='||l_run_val);

       end if;
       end loop;
       end if;
       if l_status <> 1 or l_index = 0 then
          hr_utility.trace('testing 6');
          l_index := l_index + 1;
	  g_totals_table(l_index).gre_name := l_gre_name;
	  g_totals_table(l_index).organization_name := l_org_name;
	  g_totals_table(l_index).location_name := l_location_code;
	  g_totals_table(l_index).tax_unit_id := l_payroll_action_id;
	  g_totals_table(l_index).attribute4 := 'Tax Credits';
	  g_totals_table(l_index).attribute3 := '1';
	  g_totals_table(l_index).attribute5 := l_user_reporting_name;
	  g_totals_table(l_index).value2 := -1*to_number(l_run_val);
	  g_totals_table(l_index).value3 := NULL;
	  g_totals_table(l_index).attribute1 := 'EE-CREDIT';
	  g_totals_table(l_index).attribute2 := '3';
	  end if;
      hr_utility.trace('for er credit...l_index ='||l_index);
      hr_utility.trace('element name ='||l_user_reporting_name);
      hr_utility.trace('payroll action='||to_char(l_payroll_action_id));
      hr_utility.trace('gre_name='||l_gre_name);
      hr_utility.trace('org name='||l_org_name);
      hr_utility.trace('location='||l_location_code);
      hr_utility.trace('Cash Value ='||l_run_val);
      else
         insert into pay_us_rpt_totals
         (tax_unit_id, gre_name, organization_name, location_name,
          attribute1,
          value1,
          attribute2,
          attribute3,
          attribute4,
          attribute5,
          value2,
          organization_id,
          business_group_id,
          attribute12)
         values
         (l_payroll_action_id, l_gre_name, l_org_name, l_location_code,
          'EE-CREDIT',
          l_payroll_action_id,
          '3',
          '1',
          'Tax Credits',
          l_user_reporting_name,
          -1*l_run_val,
          l_assignment_action_id,
          l_person_id,
          l_full_name);
   end if;
end loop;

/*-- Bug#4942114 starts -- */
-- close cv;
   IF p_fed_bal_status = 'Y' and  p_state_bal_status = 'Y' then
      close csr_ee_credit_rbr;
   else
      close csr_ee_credit;
   end if;
/*-- Bug#4942114 ends -- */
exception
   when others then
      hr_utility.trace('Error occurred load_ee_credit ...' ||SQLERRM);
      raise;
end load_ee_credit;
---------------------------------------------------------------------------------------------
/*-- Bug#4942114 starts -- */
/* procedure load_er_credit (l_assignment_action_id number,l_futa_where varchar2,l_futa_from varchar2) is
TYPE cv_typ IS REF CURSOR;
   cv cv_typ; */

procedure load_er_credit (l_assignment_action_id number,p_futa_status_count number,p_futa_def_bal_id number) is

  cursor csr_er_credit_rbr is
   select distinct 'ER Tax Credits' classification_name ,'FUTA CREDIT' balance_name ,
      pet.element_name element_name, prb.jurisdiction_code jurisdiction_code
   from pay_element_types_f pet,
        pay_run_balances prb
   where l_effective_date between pet.effective_start_date and pet.effective_end_date
         and pet.element_name ='FUTA CREDIT'
         and prb.defined_balance_id = p_futa_def_bal_id
         AND prb.assignment_action_id = l_assignment_action_id;

 cursor csr_er_credit is
   select distinct 'ER Tax Credits' classification_name ,'FUTA CREDIT' balance_name ,
      pet.element_name element_name, prr.jurisdiction_code jurisdiction_code
   from pay_element_types_f pet,
        pay_run_results prr
   where l_effective_date between pet.effective_start_date and pet.effective_end_date
      and pet.element_name ='FUTA CREDIT'
      and prr.status in ('P','PA')
      and pet.element_type_id      = prr.element_type_id
      and prr.assignment_action_id = l_assignment_action_id;
/*-- Bug#4942114 ends -- */

 l_classification_name varchar2(60);
 l_balance_name        varchar2(60);
 l_element_name        varchar2(60);
 l_run_val             number(20,2);
 l_status              number :=0;
 l_jurisdiction_code   varchar2(15); -- Bug 4443935
 l_tname	       varchar2(60);
begin

hr_utility.trace('Entered load_csr_er_credit');

/*-- Bug#4942114 starts -- */
/*  if (instr(l_futa_from,'prb') > 0) then
     l_tname := 'prb';
  else
     l_tname := 'prr';
  end if;

--      ||l_tname||'.jurisdiction_code jurisdiction_code

  --hr_utility.trace('l_futa_where ='||l_futa_where);
  --hr_utility.trace('l_futa_from ='||l_futa_from);
  --hr_utility.trace('l_tname ='||l_tname);
  -- Bug 5409416 : Removed prr.jurisdiction_code with
  OPEN cv FOR
    ' select distinct'||'''ER Tax Credits'''||' classification_name ,'||'''FUTA CREDIT'''||' balance_name ,
      pet.element_name element_name,'|| l_tname||'.jurisdiction_code jurisdiction_code
      from pay_element_types_f pet,'
   || l_futa_from ||
    ' where '''||l_effective_date||''' between pet.effective_start_date and pet.effective_end_date
      and pet.element_name ='||'''FUTA CREDIT'''||
     ' and '||l_futa_where;

     hr_utility.trace('statement build success');
      loop
         fetch cv into l_classification_name,
                              l_balance_name,
                              l_element_name,
			      l_jurisdiction_code;

      hr_utility.trace('assignment_Action_id in load_er_credit ='||to_char(l_assignment_action_id));
      hr_utility.trace('Number of ER CREDIT Records fetched = '||to_char(cv%ROWCOUNT));
         exit when cv%notfound; */

   if p_futa_status_count = 1 then
      open csr_er_credit_rbr;
   else
      open csr_er_credit;
   end if;

   loop
      if p_futa_status_count = 1 then
         fetch csr_er_credit_rbr into l_classification_name,
                              l_balance_name,
                              l_element_name,
			      l_jurisdiction_code;
         hr_utility.trace('assignment_Action_id in load_er_credit ='||to_char(l_assignment_action_id));
         hr_utility.trace('Number of ER CREDIT Records fetched = '||to_char(csr_er_credit_rbr%ROWCOUNT));
	 exit when csr_er_credit_rbr%notfound;
      else
         fetch csr_er_credit into l_classification_name,
                                  l_balance_name,
                                  l_element_name,
			          l_jurisdiction_code;
         hr_utility.trace('assignment_Action_id in load_er_credit ='||to_char(l_assignment_action_id));
         hr_utility.trace('Number of ER CREDIT Records fetched = '||to_char(csr_er_credit%ROWCOUNT));
	 exit when csr_er_credit%notfound;
      end if;

/*-- Bug#4942114 ends -- */
      l_bal_value := pay_us_taxbal_view_pkg.us_named_balance('FUTA CREDIT',
				                             'ASG_JD_GRE_RUN',
							     l_assignment_action_id,
				                             null,
				                             null,
				                             'GRE',
				                             l_tax_unit_id,
				                             l_business_group_id,
				                             l_jurisdiction_code);   -- 4443935
      hr_utility.trace('l_bal_value : '|| l_bal_value );
      if l_asg_flag <> 'Y' THEN
         if l_index <>0 then
            l_status :=0;
            for l_temp_index in g_totals_table.first..g_totals_table.last LOOP
               if g_totals_table(l_temp_index).attribute5 = l_element_name and
	          g_totals_table(l_temp_index).gre_name = l_gre_name and
		  g_totals_table(l_temp_index).organization_name = l_org_name and
	          g_totals_table(l_temp_index).location_name = l_location_code then

                  hr_utility.trace('testing 1');
		  g_totals_table(l_temp_index).value2 := g_totals_table(l_temp_index).value2 +
                                                         to_number(l_bal_value);
	          l_status := 1;
		  hr_utility.trace('bulk elename ='|| l_element_name);
		  hr_utility.trace('bulk cashval='|| l_bal_value);
                  hr_utility.trace('bulk totalcashval='|| g_totals_table(l_temp_index).value2);
               end if;
            end loop;
         end if;
         if l_status <> 1 or l_index = 0 then
            hr_utility.trace('testing 6');
	    l_index := l_index + 1;
	    g_totals_table(l_index).gre_name := l_gre_name;
	    g_totals_table(l_index).organization_name := l_org_name;
	    g_totals_table(l_index).location_name := l_location_code;
	    g_totals_table(l_index).tax_unit_id := l_payroll_action_id;
	    g_totals_table(l_index).attribute4 := 'Employer Tax Credits';
	    g_totals_table(l_index).attribute3 := '1';
	    g_totals_table(l_index).attribute5 := l_element_name;
	    g_totals_table(l_index).value2 := to_number(l_bal_value);
	    g_totals_table(l_index).value3 := NULL;
	    g_totals_table(l_index).attribute1 := 'ER-CREDIT';
	    g_totals_table(l_index).attribute2 := '7';
	 end if;
         hr_utility.trace('bulk elename ='|| l_element_name);
         hr_utility.trace('bulk cashval='|| l_bal_value);
         hr_utility.trace('gre name='||l_gre_name);
         hr_utility.trace('org name='||l_org_name);
         hr_utility.trace('loc name='||l_location_code);
      else
         insert into pay_us_rpt_totals
         (tax_unit_id, gre_name, organization_name, location_name,
          attribute1,
          value1,
          attribute2,
          attribute3,
          attribute4,
          attribute5,
          value2,
          organization_id,
          business_group_id,
          attribute12)
         values
         (l_payroll_action_id, l_gre_name, l_org_name, l_location_code,
          'ER-CREDIT',
          l_payroll_action_id,
          '7',
          '1',
          'Employer Tax Credits',
          l_element_name,
          l_bal_value,
          l_assignment_action_id,
          l_person_id,
          l_full_name);
      end if;
   end loop;
/*-- Bug#4942114 starts -- */
   if p_futa_status_count = 1 then
      close csr_er_credit_rbr;
   else
      close csr_er_credit;
   end if;
/*-- Bug#4942114 ends -- */
end load_er_credit;
--------------------------------------------------------------------------------------------

/*-- Bug#4942114 starts -- */
/* procedure load_er_liab (l_business_group_id number,
                        l_assignment_action_id number,
                        l_er_liab_where varchar2,
                        l_er_liab_from varchar2) is
TYPE cv_typ IS REF CURSOR;
   cv cv_typ; */

procedure load_er_liab (l_business_group_id number, l_assignment_action_id number,p_er_liab_status varchar2) is

 cursor csr_er_liab_rbr is
   select distinct pec.classification_name classification_name,
                   pbt.balance_name        balance_name,
                   pet.element_name        element_name
   from pay_balance_types           pbt,
        pay_element_types_f         pet,
        pay_element_classifications pec,
        pay_run_balances	    prb,
	pay_defined_balances	    pdb,
	pay_balance_dimensions	    pbd
   where pec.classification_name     ='Employer Liabilities'
         and pec.legislation_code    ='US'
         and pet.classification_id   = pec.classification_id
         and pet.business_group_id   = l_business_group_id
         and pet.element_type_id >= 0
         and l_effective_date between pet.effective_start_date
                              and pet.effective_end_date
         and pet.element_information10 = pbt.balance_type_id
         and pbt.business_group_id     = l_business_group_id
         and prb.defined_balance_id    = pdb.defined_balance_id
         and (pdb.business_group_id    = l_business_group_id
              or pbd.legislation_code  ='US')
         and  pdb.balance_type_id      = pbt.balance_type_id
         and pdb.balance_dimension_id  = pbd.balance_dimension_id
         and pbd.legislation_code      = 'US'
         and pbd.database_item_suffix  = '_ASG_GRE_RUN'
         and prb.assignment_action_id  = l_assignment_action_id;

 cursor csr_er_liab is
   select distinct pec.classification_name classification_name,
                   pbt.balance_name        balance_name,
                   pet.element_name        element_name
   from pay_balance_types           pbt,
        pay_element_types_f         pet,
        pay_element_classifications pec,
        pay_run_results		    prr
   where pec.classification_name     ='Employer Liabilities'
         and pec.legislation_code    ='US'
         and pet.classification_id   = pec.classification_id
         and pet.business_group_id   = l_business_group_id
         and pet.element_type_id >= 0
         and l_effective_date between pet.effective_start_date
                              and pet.effective_end_date
         and pet.element_information10 = pbt.balance_type_id
         and pbt.business_group_id     =l_business_group_id
         and prr.element_type_id +0 = pet.element_type_id
         and prr.status in ('P','PA')
         and prr.assignment_action_id = l_assignment_action_id;
/*-- Bug#4942114 ends -- */
 l_classification_name varchar2(60);
 l_balance_name        varchar2(60);
 l_element_name        varchar2(60);
 l_run_val             number(20,2);
 l_status number :=0;
BEGIN
  hr_utility.trace('entered er_liab');

/*-- Bug#4942114 starts -- */
  /*open cv FOR
  'select distinct pec.classification_name classification_name,
                 pbt.balance_name        balance_name,
                 pet.element_name        element_name
          from
               pay_balance_types           pbt,
               pay_element_types_f         pet,
               pay_element_classifications pec,'
            || l_er_liab_from||
       ' where pec.classification_name     ='||'''Employer Liabilities'''||
       ' and pec.legislation_code        ='||'''US'''||
       ' and pet.classification_id       = pec.classification_id
           and pet.business_group_id       = '||l_business_group_id||
       ' and pet.element_type_id >= 0                                  -- Bug 3369218: Added to enforce index to
        and '''|| l_effective_date||''' between pet.effective_start_date -- remove FTS on pay_element_types_f
                                                 and pet.effective_end_date
        and pet.element_information10 = pbt.balance_type_id
           and pbt.business_group_id       ='|| l_business_group_id ||
       ' and '||l_er_liab_where;
      loop
         fetch cv into l_classification_name,
                            l_balance_name,
                            l_element_name;
      hr_utility.trace('assignment_Action_id in load_er_liab ='||to_char(l_assignment_action_id));
      hr_utility.trace('Number of ER LIAB Records fetched = '||to_char(cv%ROWCOUNT));
         exit when cv%notfound; */

  if p_er_liab_status = 'Y' then
     open csr_er_liab_rbr;
  else
     open csr_er_liab;
  end if;

  loop

     if p_er_liab_status = 'Y' then
        fetch csr_er_liab_rbr into l_classification_name,
				   l_balance_name,
				   l_element_name;
        hr_utility.trace('assignment_Action_id in load_er_liab ='||to_char(l_assignment_action_id));
        hr_utility.trace('Number of ER LIAB Records fetched = '||to_char(csr_er_liab_rbr%ROWCOUNT));
	exit when csr_er_liab_rbr%notfound;
     else
        fetch csr_er_liab into l_classification_name,
			       l_balance_name,
                               l_element_name;
        hr_utility.trace('assignment_Action_id in load_er_liab ='||to_char(l_assignment_action_id));
        hr_utility.trace('Number of ER LIAB Records fetched = '||to_char(csr_er_liab%ROWCOUNT));
	exit when csr_er_liab%notfound;
     end if;
/*-- Bug#4942114 ends -- */
     l_bal_value := pay_us_taxbal_view_pkg.us_named_balance(upper(l_balance_name),
							    'ASG_GRE_RUN',
				                            l_assignment_action_id,
							    null,
				                            null,
				                            'GRE',
				                            l_tax_unit_id,
				                            l_business_group_id,
				                            null);
     if l_asg_flag <> 'Y' THEN
        if l_index <>0 then
           l_status :=0;
           for l_temp_index in g_totals_table.first..g_totals_table.last LOOP
              if g_totals_table(l_temp_index).attribute5 = l_element_name and
		 g_totals_table(l_temp_index).gre_name = l_gre_name and
	         g_totals_table(l_temp_index).organization_name = l_org_name and
		 g_totals_table(l_temp_index).location_name = l_location_code then

                 hr_utility.trace('testing 1');
		 g_totals_table(l_temp_index).value2 := g_totals_table(l_temp_index).value2 +
			                                               to_number(l_bal_value);
	         l_status := 1;
		 hr_utility.trace('for er liab...l_index ='||l_index);
		 hr_utility.trace('element name ='||l_element_name);
		 hr_utility.trace('payroll action='||to_char(g_totals_table(l_index).tax_unit_id));
	         hr_utility.trace('gre_name='||l_gre_name);
		 hr_utility.trace('org name='||l_org_name);
		 hr_utility.trace('location='||l_location_code);
		 hr_utility.trace('Toal Cash value ='||to_char(g_totals_table(l_temp_index).value2));
		 hr_utility.trace('Cash Value ='||l_bal_value);
              end if;
           end loop;
        end if;
        if l_status <> 1 or l_index = 0 then
           hr_utility.trace('testing 6');
           l_index := l_index + 1;
	   g_totals_table(l_index).gre_name := l_gre_name;
	   g_totals_table(l_index).organization_name := l_org_name;
	   g_totals_table(l_index).location_name := l_location_code;
	   g_totals_table(l_index).tax_unit_id := l_payroll_action_id;
	   g_totals_table(l_index).attribute4 := l_classification_name;
	   g_totals_table(l_index).attribute3 := '1';
	   g_totals_table(l_index).attribute5 := l_element_name;
	   g_totals_table(l_index).value2 := to_number(l_bal_value);
           g_totals_table(l_index).value3 := NULL;
	   g_totals_table(l_index).attribute1 := 'ER-LIAB';
	   g_totals_table(l_index).attribute2 := '5';
        end if;
        hr_utility.trace('for er liab...l_index ='||l_index);
        hr_utility.trace('element name ='||l_element_name);
        hr_utility.trace('payroll action='||to_char(g_totals_table(l_index).tax_unit_id));
        hr_utility.trace('gre_name='||l_gre_name);
        hr_utility.trace('org name='||l_org_name);
        hr_utility.trace('location='||l_location_code);
        hr_utility.trace('Cash Value ='||l_bal_value);
     else
        insert into pay_us_rpt_totals
         (tax_unit_id, gre_name, organization_name, location_name,
          attribute1,
          value1,
          attribute2,
          attribute3,
          attribute4,
          attribute5,
          value2,
          organization_id,
          business_group_id,
          attribute12)
        values
         (l_payroll_action_id, l_gre_name, l_org_name, l_location_code,
          'ER-LIAB',
          l_payroll_action_id,
          '5',
          '1',
          l_classification_name,
          l_element_name,
          l_bal_value,
          l_assignment_action_id,
          l_person_id,
          l_full_name);
     end if;
  end loop;
/*-- Bug#4942114 starts -- */
  if p_er_liab_status = 'Y' then
     close csr_er_liab_rbr;
  else
     close csr_er_liab;
  end if;
/*-- Bug#4942114 ends -- */
  exception
     when others then
        hr_utility.trace('Error occurred load_er_liab ...' ||SQLERRM);
        raise;
end load_er_liab;




procedure load_mesg_line (l_assignment_action_id number) is

         l_found varchar2(1);
         l_ppp_pre_payment_id number(11);
         l_dummy_var          varchar2(1);

 -- #1937448

         l_full_name          per_all_people_f.full_name%TYPE;
         l_payment_method_name pay_org_payment_methods_f.org_payment_method_name%TYPE;
         l_account_type        fnd_common_lookups.meaning%TYPE;
         l_account_number      pay_external_accounts.segment3%TYPE;
         l_routing_number      pay_external_accounts.segment4%TYPE;

  cursor person_details is    -- #1937448
   select ppf.full_name
     from per_all_people_f ppf
    where ppf.person_id = l_person_id
      and l_effective_date
          between ppf.effective_start_date and ppf.effective_end_date ;


cursor nacha_details is      -- #1937448
    select popm.org_payment_method_name Payment_Method_Name,
           fcl.meaning,
           decode(pea.segment3,null,null,'*****'||substr(pea.segment3,-4,4)),
           substr(ltrim(pea.segment4),1,9)
      from fnd_common_lookups fcl,
           pay_external_accounts pea,
           pay_personal_payment_methods_f pppm,
           pay_org_payment_methods_f popm,
           pay_payment_types         ppt,
           pay_pre_payments          ppp
     where fcl.application_id(+) = 800
       and fcl.lookup_type(+)    = 'US_ACCOUNT_TYPE'
       and pea.segment2          = fcl.lookup_code(+)
       and pea.external_account_id(+) = pppm.external_account_id
       and pppm.personal_payment_method_id(+) = ppp.personal_payment_method_id
       and popm.org_payment_method_id         = ppp.org_payment_method_id
       and ppt.payment_type_name in ('NACHA','Check')
       and l_effective_date
              between popm.effective_start_date and popm.effective_end_date
       and popm.payment_type_id  = ppt.payment_type_id
       and l_effective_date
              between
                           nvl(pppm.effective_start_date, l_effective_date )
                           and
                           nvl(pppm.effective_end_date, l_effective_date)
       and ppp.pre_payment_id = l_ppp_pre_payment_id;

 cursor ppp_action is
      select ppp.pre_payment_id             pre_payment_id
        from pay_pre_payments               ppp,
             pay_payroll_actions            ppa_ppp,
             pay_assignment_actions         paa_ppp,
             pay_action_interlocks          pai
       where pai.locked_action_id         = l_assignment_action_id
         and paa_ppp.assignment_action_id = pai.locking_action_id
         and paa_ppp.action_status        = 'C'
         and ppa_ppp.payroll_action_id    = paa_ppp.payroll_action_id
         and ppa_ppp.action_type            in ('U','P')
         and ppa_ppp.action_status        = 'C'
         and ppp.assignment_action_id     = paa_ppp.assignment_action_id;



 cursor chk_ppp ( l_ppp_pre_payment_id number) is
      select '1' found
        from pay_payroll_actions    ppa_chk,
             pay_assignment_actions paa_chk
       where paa_chk.pre_payment_id       = l_ppp_pre_payment_id
         and ppa_chk.payroll_action_id    = paa_chk.payroll_action_id
         and ppa_chk.action_type            in ('H','M','E')
         and ppa_chk.action_status        = 'C';


begin
     -- initialize the variables
     l_full_name            := null ;
     l_payment_method_name  := null ;
     l_account_type         := null ;
     l_account_number       := null ;
     l_routing_number       := null ;
     l_found                := null ;
     --
     open person_details;
     fetch person_details into l_full_name;
     close person_details;

      open ppp_action ;
      loop
         fetch ppp_action into l_ppp_pre_payment_id;
         hr_utility.trace('Number of PPP_ACTION Records fetched = '||to_char(ppp_action%ROWCOUNT));
         exit when ppp_action%notfound;
         /* ppp_action found */

         open chk_ppp(l_ppp_pre_payment_id);
         fetch chk_ppp into l_found;
         hr_utility.trace('Number of CHK_PPP Records fetched = '||to_char(chk_ppp%ROWCOUNT));
            if chk_ppp%notfound then

                 open nacha_details;
                 fetch nacha_details into l_payment_method_name, l_account_type,
                                          l_account_number, l_routing_number ;
                 close nacha_details;

                BEGIN

                 SELECT 'X'
                 INTO l_dummy_var
                 from pay_us_rpt_totals
                 where location_id = l_ppp_pre_payment_id
                 and   tax_unit_id = t_payroll_action_id
                 and   attribute4  = 'Unpaid Payments' ;

               EXCEPTION

                 WHEN NO_DATA_FOUND THEN


                     insert into pay_us_rpt_totals
                     (tax_unit_id, gre_name, organization_name, location_name,
                      attribute1,
                      value1,
                      attribute2,
                      attribute3,
                      attribute4,
                      attribute5,
                      attribute6,
                      attribute7,
                      attribute8,
                      attribute9,
                      attribute10,
                      attribute11,
                      value2,
                      organization_id,
                      location_id)
                     values
                     (l_payroll_action_id, l_gre_name, l_org_name, l_location_code,
                      'MESG-LINE',
                      l_payroll_action_id,
                      '10',
                      '2',
                      'Unpaid Payments',
                      'Incomplete Payments',
                      l_full_name,
                      l_assignment_number,
                      l_payment_method_name,
                      l_account_type,
                      l_account_number,
                      l_routing_number,
                      1,
                      l_assignment_action_id,
                      l_ppp_pre_payment_id);

               END;

            end if;  /* chk_ppp%notfound */
         close chk_ppp;
      end loop;

     if ppp_action%ROWCOUNT = 0 then

        BEGIN
/* bug 3774591 first change */
         select 'X'
          into l_dummy_var
          from pay_payroll_actions            ppa_ppp,
               pay_assignment_actions         paa_ppp,
               pay_action_interlocks          pai
         where pai.locked_action_id         = l_assignment_action_id
           and paa_ppp.assignment_action_id = pai.locking_action_id
           and paa_ppp.action_status        = 'C'
           and ppa_ppp.payroll_action_id    = paa_ppp.payroll_action_id
           and ppa_ppp.action_type            in ('U','P')
           and ppa_ppp.action_status        = 'C'
	   and rownum=1; -- Bug 5021468

         EXCEPTION

         WHEN NO_DATA_FOUND THEN

        insert into pay_us_rpt_totals
        (tax_unit_id, gre_name, organization_name, location_name,
         attribute1,
         value1,
         attribute2,
         attribute3,
         attribute4,
         attribute5,
         attribute6,
         attribute7,
         value2,
         organization_id)
        values
        (l_payroll_action_id, l_gre_name, l_org_name, l_location_code,
         'MESG-LINE',
         l_payroll_action_id,
         '10',
         '1',
         'Unprocessed Pre-Payments',
         'Number of runs w/o Pre-payments',
         l_full_name,
         l_assignment_number,
         1,l_assignment_action_id);

         end;
     end if;

     close ppp_action;

exception
          when others then
        hr_utility.trace('Error occurred load_mesg_line ...' ||SQLERRM);
        raise;
end load_mesg_line;



procedure load_prepay (p_assignment_action_id number ) is

 l_pre_pay_aaid number;
 l_void varchar2(1);
 l_pre_pay_id   number;
 l_dummy_val    varchar2(1);
 l_max_sequence_aaid NUMBER;

 cursor prepay   (p_max_seq_aaid number) is
    select  PAA_PPP.ASSIGNMENT_ACTION_ID PRE_PAY_AAID,
            POPM.ORG_PAYMENT_METHOD_NAME PMT_NAME,
            PPP.VALUE VALUE,
            PPP.PRE_PAYMENT_ID PMT_ID
    from    PAY_PAYROLL_ACTIONS    PPA_PPP,
            PAY_ASSIGNMENT_ACTIONS PAA_PPP,
            PAY_ACTION_INTERLOCKS  PAI_RUN,
            PAY_PAYROLL_ACTIONS    PPA_CHK,
            PAY_ASSIGNMENT_ACTIONS PAA_CHK,
            PAY_ACTION_INTERLOCKS  PAI_CHK,
            PAY_ORG_PAYMENT_METHODS_F POPM,
            PAY_PRE_PAYMENTS       PPP
    WHERE   PAI_RUN.LOCKED_ACTION_ID = p_max_seq_aaid
    AND     PAI_RUN.LOCKING_ACTION_ID = PAA_PPP.ASSIGNMENT_ACTION_ID
    AND     PAA_PPP.ACTION_STATUS     = 'C'
    AND     PAA_PPP.PAYROLL_ACTION_ID = PPA_PPP.PAYROLL_ACTION_ID
    AND     PPA_PPP.ACTION_STATUS     = 'C'
    AND     PAA_PPP.ASSIGNMENT_ACTION_ID = PPP.ASSIGNMENT_ACTION_ID
    AND     POPM.ORG_PAYMENT_METHOD_ID = PPP.ORG_PAYMENT_METHOD_ID
    AND     PPA_PPP.EFFECTIVE_DATE BETWEEN
              POPM.EFFECTIVE_START_DATE AND POPM.EFFECTIVE_END_DATE
 --   AND     POPM.DEFINED_BALANCE_ID IS NOT NULL  --Bug 3543649
    AND     PAI_CHK.LOCKED_ACTION_ID = PAA_PPP.ASSIGNMENT_ACTION_ID
    AND     PAI_CHK.LOCKING_ACTION_ID = PAA_CHK.ASSIGNMENT_ACTION_ID
    AND     PAA_CHK.ACTION_STATUS = 'C'
    AND     PAA_CHK.PRE_PAYMENT_ID = PPP.PRE_PAYMENT_ID
    AND     PPA_CHK.PAYROLL_ACTION_ID = PAA_CHK.PAYROLL_ACTION_ID
    AND     PPA_CHK.ACTION_STATUS = 'C'
    AND     PPA_CHK.ACTION_TYPE IN ('H', 'M')
    AND     NOT EXISTS
             (SELECT  NULL
              FROM PAY_PAYROLL_ACTIONS PPA_VOID,
                   PAY_ASSIGNMENT_ACTIONS PAA_VOID,
                   PAY_ACTION_INTERLOCKS PAI_VOID
              WHERE PAI_VOID.LOCKED_ACTION_ID = PAA_CHK.ASSIGNMENT_ACTION_ID
              AND PAA_VOID.ASSIGNMENT_ACTION_ID = PAI_VOID.LOCKING_ACTION_ID
              AND PAA_VOID.ACTION_STATUS = 'C'
              AND PPA_VOID.PAYROLL_ACTION_ID = PAA_VOID.PAYROLL_ACTION_ID
              AND PPA_VOID.ACTION_TYPE = 'D'
              AND PPA_VOID.ACTION_STATUS = 'C' )
;

           l_pmt_name  varchar2(60);
           l_pmt_value number(20,2);
begin
    hr_utility.trace('Payroll_id = '||to_char(t_payroll_id));
    hr_utility.trace('CONC_id    = '||to_char(t_consolidation_set_id));
    hr_utility.trace('GRE_id     = '||to_char(t_gre_id));
    hr_utility.trace('Start DT   = '||to_char(l_leg_start_date));
    hr_utility.trace('END DT     = '||to_char(l_leg_end_date));

--  Determine is this assignment_action is the max action sequence.

    select paa_outer.assignment_action_id
    into   l_max_sequence_aaid
    from   pay_assignment_actions paa_outer
    where  (paa_outer.payroll_action_id, paa_outer.action_sequence) =
           (select paa1.payroll_action_id,
                   max(paa1.action_sequence)
            from   pay_assignment_actions paa1,
                   pay_assignment_actions paa2
            where  paa1.payroll_action_id  = paa2.payroll_action_id
            and    paa2.assignment_action_id =p_assignment_action_id
            and    paa1.assignment_id = paa2.assignment_id
-- Bug No 4429173          and    paa1.source_action_id is not null
	    and ((paa1.run_type_id is not null and paa1.source_action_id is not null)
	         or(paa1.run_type_id is null and paa1.source_action_id is null))
	     and    exists (
		           select 'Y'
	                   from   pay_run_result_values rrv,
		           pay_input_values_F    iv,
			   pay_run_results       rr
		           where  nvl(rrv.result_value,0) <> to_char(0)
		           and    iv.input_value_id = rrv.input_value_id
		           and    iv.name = 'Pay Value'
		           and    rr.run_result_id = rrv.run_result_id
		           and    rr.assignment_action_id = paa1.assignment_action_id
			  )
            group by paa1.payroll_action_id);

    IF l_max_sequence_aaid = p_assignment_action_id THEN

          open prepay  (l_max_sequence_aaid);
          loop
             fetch prepay into l_pre_pay_aaid,
                               l_pmt_name,
                               l_pmt_value,
                               l_pre_pay_id;
          hr_utility.trace('Number of prepay Records fetched = '||to_char(prepay%ROWCOUNT));
             exit when prepay%notfound;

             BEGIN

                SELECT 'X'
                INTO   l_dummy_val
                FROM   pay_us_rpt_totals
                where  location_id = l_pre_pay_id
                and    tax_unit_id = t_payroll_action_id
                and    attribute4  = 'Disbursements';

             EXCEPTION
               WHEN NO_DATA_FOUND THEN
                 insert into pay_us_rpt_totals
                 (tax_unit_id, gre_name, organization_name, location_name,
                  attribute1,
                  value1,
                  attribute2,
                  attribute3,
                  attribute4,
                  attribute5,
                  value2,
                  organization_id,
                  location_id)
                 values
                 (t_payroll_action_id, l_gre_name, l_org_name, l_location_code,
                  'PREPAY',
                  t_payroll_action_id,
                  '8',
                  '1',
                  'Disbursements',
                  l_pmt_name,
                  l_pmt_value,
                  l_pre_pay_aaid,
                  l_pre_pay_id);

             END;

           end loop;

          close prepay;

    END IF;
exception
          when others then
        hr_utility.trace('Error occurred load_prepay ...' ||SQLERRM);
        raise;
end load_prepay;




procedure load_reversals(l_assignment_action_id number) is

        l_reverse_amt              number(12,2);

begin
         hr_utility.trace('Entered Reversals...');
         pay_balance_pkg.set_context('TAX_UNIT_ID',l_tax_unit_id);
         l_reverse_amt := nvl(pay_balance_pkg.get_value(
                                                    p_defined_balance_id => l_defined_balance_id,
                                                    p_assignment_action_id => l_assignment_action_id),0);

         insert into pay_us_rpt_totals
         (tax_unit_id, gre_name, organization_name, location_name,
          attribute1,
          value1,
          attribute2,
          attribute3,
          attribute4,
          attribute5,
          value2,organization_id)
         values
         (l_payroll_action_id, l_gre_name, l_org_name, l_location_code,
          'REVERSAL',
          l_payroll_action_id,
          '9',
          '1',
          'Reversals',
          'Reversals',
          l_reverse_amt, l_assignment_action_id);
          hr_utility.trace('Exited Reversals...');
exception
          when others then
        hr_utility.trace('Error occurred load_reversals ...' ||SQLERRM);
        raise;
end load_reversals;

-------------------------------------------------------------------------------------------
/*-- Bug#4942114 starts -- */
/*procedure load_wc_er_liab (l_business_group_id number,
                        l_assignment_action_id number,
                        l_wc_er_liab_where varchar2,
                        l_wc_er_liab_from varchar2
                        ) is
TYPE cv_typ IS REF CURSOR;
   cv cv_typ; */

procedure load_wc_er_liab (l_business_group_id number, l_assignment_action_id number, p_wc_er_liab_status_count number) is

   cursor csr_wc_er_liab_rbr is
         select pec.classification_name       classification_name,
                pbt.balance_name              balance_name,
                pet.element_name              element_name,
                pftr.sui_jurisdiction_code    jurisdiction_code,
                pst.state_name                state_name
           from
                pay_balance_types           pbt,
                pay_element_types_f         pet,
                pay_element_classifications pec,
                pay_assignment_actions      paa,
                per_all_assignments_f       paf,
                pay_us_emp_fed_tax_rules_F  pftr,
                pay_us_states               pst,
                pay_run_balances	    prb,
    		pay_balance_dimensions	    pbd,
    		pay_defined_balances        pdb
           where pec.classification_name     ='Employer Taxes'
                 and pec.legislation_code    ='US'
                 and pet.classification_id   = pec.classification_id
                 and l_effective_date between pet.effective_start_date
                                      and pet.effective_end_date
                 and pet.element_information10 = pbt.balance_type_id
                 and pet.element_name  in ('Workers Compensation',
                                           'Workers Compensation2 ER',
                                           'Workers Compensation3 ER')
                 and l_assignment_action_id = paa.assignment_action_id
		 and paa.assignment_id      = paf.assignment_id
		 and paf.assignment_id      = pftr.assignment_id
		 and l_effective_date between paf.effective_start_date
                                      and paf.effective_end_date
		 and l_business_group_id    = paf.business_group_id
		 and l_effective_date between pftr.effective_start_date
                                      and pftr.effective_end_date
		 and pst.state_code         = substr(pftr.sui_jurisdiction_code,1,2)
		 and prb.defined_balance_id = pdb.defined_balance_id
                 AND pdb.balance_type_id    = pbt.balance_type_id
                 AND pdb.balance_dimension_id = pbd.balance_dimension_id
                 AND pbd.legislation_code     = 'US'
                 AND pbd.database_item_suffix ='_ASG_JD_GRE_RUN'
                 AND (pdb.legislation_code    ='US'
                      OR pdb.business_group_id =l_business_group_id)
                 and prb.assignment_action_id = paa.assignment_action_id
                 and prb.tax_unit_id = paa.tax_unit_id
                 and prb.jurisdiction_code = pst.state_code
                 and prb.tax_unit_id  = paa.tax_unit_id;

    cursor csr_wc_er_liab is
         select pec.classification_name       classification_name,
                pbt.balance_name              balance_name,
                pet.element_name              element_name,
                pftr.sui_jurisdiction_code    jurisdiction_code,
                pst.state_name                state_name
           from
                pay_balance_types           pbt,
                pay_element_types_f         pet,
                pay_element_classifications pec,
                pay_assignment_actions      paa,
                per_all_assignments_f       paf,
                pay_us_emp_fed_tax_rules_F  pftr,
                pay_us_states               pst,
                pay_run_results		    prr
           where pec.classification_name     ='Employer Taxes'
                 and pec.legislation_code    ='US'
                 and pet.classification_id   = pec.classification_id
                 and l_effective_date between pet.effective_start_date
                                      and pet.effective_end_date
                 and pet.element_information10 = pbt.balance_type_id
                 and pet.element_name  in ('Workers Compensation',
                                           'Workers Compensation2 ER',
                                           'Workers Compensation3 ER')
                 and l_assignment_action_id = paa.assignment_action_id
		 and paa.assignment_id      = paf.assignment_id
		 and paf.assignment_id      = pftr.assignment_id
		 and l_effective_date between paf.effective_start_date
                                      and paf.effective_end_date
		 and l_business_group_id    = paf.business_group_id
		 and l_effective_date between pftr.effective_start_date
                                      and pftr.effective_end_date
		 and pst.state_code         = substr(pftr.sui_jurisdiction_code,1,2)
		 and prr.element_type_id +0 = pet.element_type_id
                 and prr.assignment_action_id = paa.assignment_action_id;
/*-- Bug#4942114 ends -- */
    l_classification_name varchar2(60);
    l_balance_name        varchar2(60);
    l_element_name        varchar2(60);
    l_jurisdiction_code     varchar2(11);
    l_run_val             number(20,2);
    l_state_name          varchar2(60);
    l_status  number;
BEGIN
   hr_utility.trace('entered load_wc_er_liab');

/*-- Bug#4942114 starts -- */
  /* hr_utility.trace('l_wc_er_liab_where ='|| l_wc_er_liab_where);
  OPEN cv FOR
    'select pec.classification_name       classification_name,
                pbt.balance_name              balance_name,
                pet.element_name              element_name,
                pftr.sui_jurisdiction_code    jurisdiction_code,
                pst.state_name                state_name
           from
                pay_balance_types           pbt,
                pay_element_types_f         pet,
                pay_element_classifications pec,
                pay_assignment_actions      paa,
                per_all_assignments_f       paf,
                pay_us_emp_fed_tax_rules_F  pftr,
                pay_us_states               pst,'
              ||l_wc_er_liab_from||
        '  where pec.classification_name     ='||'''Employer Taxes'''
       ||' and  pec.legislation_code        ='||'''US'''
       ||' and pet.classification_id       = pec.classification_id
           and '''||l_effective_date||''' between pet.effective_start_date
                                              and pet.effective_end_date
           and pet.element_information10 = pbt.balance_type_id
           and pet.element_name            in ('|| '''Workers Compensation'''||','
                                                || '''Workers Compensation2 ER'''||','
                                                || '''Workers Compensation3 ER'''||')
           and '||l_assignment_action_id ||' = paa.assignment_action_id
           and paa.assignment_id           = paf.assignment_id
           and paf.assignment_id           = pftr.assignment_id
           and '''||l_effective_date||''' between paf.effective_start_date
                                                 and paf.effective_end_date
           and '||l_business_group_id    ||'= paf.business_group_id
           and '''||l_effective_date||''' between pftr.effective_start_date
                                                  and pftr.effective_end_date
           and pst.state_code             = substr(pftr.sui_jurisdiction_code,1,2)
            and '|| l_wc_er_liab_where;
       loop
          fetch cv into l_classification_name,
                             l_balance_name,
                             l_element_name,
                             l_jurisdiction_code,
                             l_state_name ;
          hr_utility.trace('Number of WC ER LIAB Records fetched = '||to_char(cv%ROWCOUNT));
          exit when cv%notfound; */

   if p_wc_er_liab_status_count = 3 then
      open csr_wc_er_liab_rbr;
   else
      open csr_wc_er_liab;
   end if;

   loop

      if p_wc_er_liab_status_count = 3 then
	 fetch csr_wc_er_liab_rbr into  l_classification_name,
					l_balance_name,
					l_element_name,
					l_jurisdiction_code,
					l_state_name ;
         hr_utility.trace('Number of WC ER LIAB Records fetched = '||to_char(csr_wc_er_liab_rbr%ROWCOUNT));
         exit when csr_wc_er_liab_rbr%notfound;
      else
	 fetch csr_wc_er_liab into l_classification_name,
				   l_balance_name,
				   l_element_name,
				   l_jurisdiction_code,
				   l_state_name ;
         hr_utility.trace('Number of WC ER LIAB Records fetched = '||to_char(csr_wc_er_liab%ROWCOUNT));
         exit when csr_wc_er_liab%notfound;

      end if;

/*-- Bug#4942114 ends -- */
      l_bal_value := pay_us_taxbal_view_pkg.us_named_balance(
                     upper(l_balance_name),
                           'ASG_JD_GRE_RUN',
                           l_assignment_action_id,
                           null,
                           null,
                           'GRE',
                           l_tax_unit_id,
                           l_business_group_id,
                           l_jurisdiction_code);
      if l_asg_flag <> 'Y' THEN
         if l_index <>0 then
            l_status :=0;
            for l_temp_index in g_totals_table.first..g_totals_table.last LOOP
	       if g_totals_table(l_temp_index).attribute5 = l_element_name||' '||l_state_name and
		  g_totals_table(l_temp_index).gre_name = l_gre_name and
	          g_totals_table(l_temp_index).organization_name = l_org_name and
		  g_totals_table(l_temp_index).location_name = l_location_code then

		  hr_utility.trace('testing 1');
		  g_totals_table(l_temp_index).value2 := g_totals_table(l_temp_index).value2 +
			                                 to_number(l_bal_value);
		  l_status := 1;
		  hr_utility.trace('for wc er liab...l_index ='||l_index);
		  hr_utility.trace('element name ='||l_element_name||' '||l_state_name);
		  hr_utility.trace('payroll action='||to_char(g_totals_table(l_index).tax_unit_id));
		  hr_utility.trace('gre_name='||l_gre_name);
		  hr_utility.trace('org name='||l_org_name);
		  hr_utility.trace('location='||l_location_code);
		  hr_utility.trace('Toal Cash value ='||to_char(g_totals_table(l_temp_index).value2));
		  hr_utility.trace('Cash Value ='||l_bal_value);
               end if;
            end loop;
         end if;
         if l_status <> 1 or l_index = 0 then
            hr_utility.trace('testing 6');
	    l_index := l_index + 1;
	    g_totals_table(l_index).gre_name := l_gre_name;
	    g_totals_table(l_index).organization_name := l_org_name;
	    g_totals_table(l_index).location_name := l_location_code;
	    g_totals_table(l_index).tax_unit_id := l_payroll_action_id;
	    g_totals_table(l_index).attribute4 := 'Employer Taxes';
	    g_totals_table(l_index).attribute3 := '1';
	    g_totals_table(l_index).attribute5 := l_element_name||' '||l_state_name;
	    g_totals_table(l_index).value2 := to_number(l_bal_value);
	    g_totals_table(l_index).value3 := NULL;
	    g_totals_table(l_index).attribute1 := 'ER-TAX';
	    g_totals_table(l_index).attribute2 := '6';
	 end if;
	 hr_utility.trace('for wc er liab...l_index ='||l_index);
	 hr_utility.trace('element name ='||l_element_name||' '||l_state_name);
	 hr_utility.trace('payroll action='||to_char(g_totals_table(l_index).tax_unit_id));
	 hr_utility.trace('gre_name='||l_gre_name);
	 hr_utility.trace('org name='||l_org_name);
	 hr_utility.trace('location='||l_location_code);
	 hr_utility.trace('Cash Value ='||l_bal_value);
      else
         insert into pay_us_rpt_totals
          (tax_unit_id, gre_name, organization_name, location_name,
           attribute1,
           value1,
           attribute2,
           attribute3,
           attribute4,
           attribute5,
           value2,
           organization_id,
           business_group_id,
           attribute12)
         values
          (l_payroll_action_id, l_gre_name, l_org_name, l_location_code,
           'ER-TAX',
           l_payroll_action_id,
           '6',
           '1',
           'Employer Taxes',
           l_element_name||' '||l_state_name,
           l_bal_value,
           l_assignment_action_id,
           l_person_id,
           l_full_name);
      end if;
   end loop;
/*-- Bug#4942114 starts -- */
   if p_wc_er_liab_status_count = 3 then
      close csr_wc_er_liab_rbr;
   else
      close csr_wc_er_liab;
   end if;
/*-- Bug#4942114 ends -- */
 exception
    when others then
      hr_utility.trace('Error occurred load_wc_er_liab ...' ||SQLERRM);
      raise;
end load_wc_er_liab;
-----------------------------------------------------------------------------------
procedure load_data
(
   pactid     in     varchar2,     /* payroll action id */
   chnkno     in     number,
   ppa_finder in     varchar2
) is

cursor sel_aaid (l_pactid number,
                 l_chnkno number)
is
select
        ppa_arch.start_date          start_date,
        ppa_arch.effective_date      end_date,
        ppa_arch.business_group_id   business_group_id,
        ppa_arch.payroll_action_id   payroll_action_id,
        ppa.effective_date           effective_date,
        ppa.action_type              action_type,
        paa1.assignment_action_id    assignment_action_id,
        paa1.assignment_id           assignment_id,
        paa1.tax_unit_id             tax_unit_id,
        substr(hou.name,1,228)       gre_name,  /*bug6998211*/
        paf.organization_id          organization_id,
        substr(hou1.name,1,228)      organization_name,
        paf.location_id              location_id,
        hrl.location_code            location_code
       ,paf.assignment_number        assignment_number -- #1937448
       ,paf.person_id                person_id
from    hr_locations_all             hrl,
        hr_all_organization_units    hou1,
        hr_all_organization_units    hou,
        per_assignments_f            paf,
        pay_payroll_actions          ppa,
        pay_assignment_actions       paa1,
        pay_action_interlocks        pai,
        pay_assignment_actions       paa,
        pay_payroll_actions          ppa_arch
  where ppa_arch.payroll_action_id = l_pactid
    and paa.payroll_action_id      = ppa_arch.payroll_action_id
    and paa.chunk_number           = l_chnkno
    and pai.locking_action_id      = paa.assignment_action_id
    and paa1.assignment_action_id  = pai.locked_action_id
    and ppa.payroll_action_id      = paa1.payroll_action_id
    and paf.assignment_id          = paa1.assignment_id
    and ppa.effective_date between   paf.effective_start_date
                               and   paf.effective_end_date
    and hrl.location_id            = paf.location_id
    and hou1.organization_id       = paf.organization_id
    and hou.organization_id        = paa1.tax_unit_id;

l_ded_view_name varchar2(30);
l_earn_view_name varchar2(30);
l_fed_view_name varchar2(30);
l_state_view_name varchar2(30);
l_local_view_name varchar2(30);
l_fed_liab_view_name varchar2(30);
l_state_liab_view_name varchar2(30);
l_futa_where varchar2(2000);
l_futa_from varchar2(2000);
l_er_liab_where varchar2(2000);
l_er_liab_from varchar2(2000);
l_wc_er_liab_where varchar2(2000);
l_wc_er_liab_from varchar2(2000);
begin
  --   hr_utility.trace_on('Y','GTN');
    l_row_count := 0;
    hr_utility.trace('PACTID = '||pactid);
    hr_utility.trace('CHNKNO = '||to_char(chnkno));
    hr_utility.trace('PPA_FINDER = '||ppa_finder);
    begin
        select ppa.legislative_parameters,
               ppa.business_group_id,
               ppa.start_date,
               ppa.effective_date,
               pay_paygtn_pkg.get_parameter('TRANSFER_CONC_SET',ppa.legislative_parameters),
               pay_paygtn_pkg.get_parameter('TRANSFER_PAYROLL',ppa.legislative_parameters),
               pay_paygtn_pkg.get_parameter('TRANSFER_GRE',ppa.legislative_parameters),
               ppa.payroll_action_id
          into l_leg_param,
               l_business_group_id,
               l_leg_start_date,
               l_leg_end_date,
               t_consolidation_set_id,
               t_payroll_id,
               t_gre_id,
               t_payroll_action_id
          from pay_payroll_actions ppa
         where ppa.payroll_action_id = pactid;
    exception when no_data_found then
              hr_utility.trace('Legislative Details not found...');
              raise;
    end;

    begin
        select to_number(ue.creator_id)
          into l_defined_balance_id
          from ff_user_entities ue,
               ff_database_items di
         where di.user_name = 'PAYMENTS_ASG_GRE_RUN'
           and ue.user_entity_id = di.user_entity_id
           and ue.creator_type = 'B'
           and nvl(ue.legislation_code,'US') = 'US';
    exception when others then
         hr_utility.trace('Error getting defined balance id');
         raise;
    end;

-- #3270485: moved to range_cursor procedure.
--
--    if chnkno = 1 then
--       insert into pay_us_rpt_totals (tax_unit_id,attribute1,organization_id,
--                                      attribute2,attribute3,attribute4,attribute5)
--                              values (pactid,'GTN',ppa_finder,
--                                      l_leg_param, l_business_group_id,
--                                      to_char(l_leg_start_date,'MM/DD/YYYY'),
--                                      to_char(l_leg_end_date,'MM/DD/YYYY'));
--       commit;
--    end if;

    pay_us_balance_view_pkg.set_view_mode('ASG');
    pay_us_balance_view_pkg.set_calc_all_timetypes_flag(0);
    pay_us_balance_view_pkg.set_session_var('PTD',    'FALSE');
    pay_us_balance_view_pkg.set_session_var('PYDATE', 'FALSE');
    pay_us_balance_view_pkg.set_session_var('MONTH',  'FALSE');
    pay_us_balance_view_pkg.set_session_var('QTD',    'FALSE');
    pay_us_balance_view_pkg.set_session_var('CURRENT','FALSE');
    pay_us_balance_view_pkg.set_session_var('YTD',    'FALSE');

	l_ded_view_name        :=  'PAY_US_GTN_DEDUCT_V';
	l_earn_view_name       :=  'PAY_US_GTN_EARNINGS_V';
	l_fed_view_name        :=  'PAY_US_FED_TAXES_V';
	l_state_view_name      :=  'PAY_US_STATE_TAXES_V';
	l_local_view_name      :=  'PAY_US_LOCAL_TAXES_V';
	l_fed_liab_view_name   :=  'PAY_US_FED_LIABILITIES_V';
	l_state_liab_view_name :=  'PAY_US_STATE_LIABILITIES_V';
	l_futa_where           := ' prr.status in ('||'''P'''||','||'''PA'''||')
                                     and pet.element_type_id      = prr.element_type_id
            	                     and prr.assignment_action_id = ';
	l_futa_from            := ' pay_run_results prr ';

	l_er_liab_where        := ' prr.element_type_id +0 = pet.element_type_id
	                            and   prr.status in (' || '''P''' || ', ' || '''PA''' || ')
                                    and   prr.assignment_action_id = ';
	l_er_liab_from         := ' pay_run_results prr ';

	l_wc_er_liab_where     := ' prr.element_type_id +0   = pet.element_type_id
                                  and prr.assignment_action_id = ';
        l_wc_er_liab_from      := ' pay_run_results prr ';
        l_asg_flag := 'N';
    open sel_aaid (to_number(pactid),chnkno);
    loop
        fetch sel_aaid into  l_start_date,
                             l_end_date,
                             l_business_group_id,
                             l_payroll_action_id,
                             l_effective_date,
                             l_action_type,
                             l_assignment_action_id,
                             l_assignment_id,
                             l_tax_unit_id,
                             l_gre_name,
                             l_organization_id,
                             l_org_name,
                             l_location_id,
                             l_location_code,
                             l_assignment_number,
                             l_person_id;

    hr_utility.trace('Number of Records fetched = '||to_char(sel_aaid%ROWCOUNT));
        exit when sel_aaid%notfound;

        hr_utility.trace('Chunk No          = '||to_char(chnkno));
        hr_utility.trace('Start Date        = '||to_char(l_start_date));
        hr_utility.trace('End Date          = '||to_char(l_end_date));
        hr_utility.trace('BG ID             = '||to_char(l_business_group_id));
        hr_utility.trace('Payroll Action ID = '||to_char(l_payroll_action_id));
        hr_utility.trace('Effective Date    = '||to_char(l_effective_date));
        hr_utility.trace('Action Type       = '||l_action_type);
        hr_utility.trace('Asg Act ID        = '||to_char(l_assignment_action_id));
        hr_utility.trace('Asg ID            = '||to_char(l_assignment_id));
        hr_utility.trace('Tax Unit ID       = '||to_char(l_tax_unit_id));
        hr_utility.trace('GRE Name          = '||l_gre_name);
        hr_utility.trace('ORG ID            = '||to_char(l_organization_id));
        hr_utility.trace('ORG Name          = '||l_org_name);
        hr_utility.trace('Loc ID            = '||to_char(l_location_id));
        hr_utility.trace('Loc Code          = '||l_location_code);
/*--Bug#4942114 starts --*/
       /*load_deductions(l_assignment_action_id,l_ded_view_name);
        load_earnings  (l_assignment_action_id,l_earn_view_name);
   --   load_alien_earnings (l_assignment_action_id);
        load_ee_tax    (l_assignment_action_id,l_fed_view_name,l_state_view_name,l_local_view_name);
        load_er_tax    (l_assignment_action_id,l_fed_liab_view_name,l_state_liab_view_name,l_local_view_name);
        load_ee_credit (l_assignment_action_id,l_fed_view_name,l_state_view_name);
        load_er_credit (l_assignment_action_id,l_futa_where||l_assignment_action_id,l_futa_from);
        load_er_liab   (l_business_group_id,l_assignment_action_id,l_er_liab_where || l_assignment_action_id,l_er_liab_from);
        load_wc_er_liab   (l_business_group_id,l_assignment_action_id,l_wc_er_liab_where|| l_assignment_action_id,l_wc_er_liab_from); */
/*--Bug#4942114 starts --*/
        if l_action_type in ('R','Q') then
           load_mesg_line (l_assignment_action_id);
           load_prepay (l_assignment_action_id);
        end if;
        if l_action_type = 'V' then
           load_reversals (l_assignment_action_id);
        end if;
        l_row_count := l_row_count +1;
        if l_row_count = 200 then
           l_row_count := 0;
           commit;
        end if;
    end loop;
        hr_utility.trace('End of LOAD DATA');
    close sel_aaid;
if (l_index <>0) then
for x in g_totals_table.first..g_totals_table.last LOOP
INSERT INTO pay_us_rpt_totals(tax_unit_id, gre_name,
                              organization_name, location_name,
           attribute1,
           attribute2,
           attribute3,
           attribute4,
           attribute5,
           value2,
           value3
) values
 (g_totals_table(x).tax_unit_id, g_totals_table(x).gre_name,
  g_totals_table(x).organization_name, g_totals_table(x).location_name,
           g_totals_table(x).attribute1,
           g_totals_table(x).attribute2,
           g_totals_table(x).attribute3,
           g_totals_table(x).attribute4,
           g_totals_table(x).attribute5,
           g_totals_table(x).value2,
           g_totals_table(x).value3
);
END LOOP;
/*forall x in g_totals_table.first..g_totals_table.last
insert into pay_us_rpt_totals
           values
           g_totals_table(x);*/
l_index :=0;
g_totals_table.DELETE;
end if;
    commit;
exception
          when others then
        hr_utility.trace('Error occurred load_data ...' ||SQLERRM);
        raise;
end load_data;

procedure load_data
(
	p_payroll_action_id number ,
	p_chunk   number,
	ppa_finder number ,
        -- Bug#4942114 starts
     /* p_ded_view_name varchar2 ,
	p_earn_view_name varchar2 ,
	p_fed_view_name varchar2  ,
	p_state_view_name varchar2  ,
	p_local_view_name varchar2 ,
	p_fed_liab_view_name varchar2 ,
	p_state_liab_view_name varchar2 ,
	p_futa_where varchar2,
	p_futa_from varchar2,
	p_er_liab_where varchar2 ,
	p_er_liab_from varchar2,
	p_wc_er_liab_where varchar2 ,
	p_wc_er_liab_from varchar2,
	li-- Bug#4942114 ends */
	p_ded_bal_status1 varchar2,
	p_ded_bal_status2 varchar2,
	p_earn_bal_status varchar2,
	p_fed_bal_status varchar2,
	p_state_bal_status varchar2,
	p_local_bal_status varchar2,
	p_fed_liab_bal_status varchar2,
	p_state_liab_bal_status varchar2,
	p_futa_status_count number,
	p_futa_def_bal_id number,
	p_er_liab_status varchar2,
	p_wc_er_liab_status_count number,
	p_asg_flag varchar2
) is



cursor sel_aaid (l_pactid number,l_chunk_no number)
is
select
        ppa_arch.start_date          start_date,
        ppa_arch.effective_date      end_date,
        ppa_arch.business_group_id   business_group_id,
        ppa_arch.payroll_action_id   payroll_action_id,
        ppa.effective_date           effective_date,
        ppa.action_type              action_type,
        paa1.assignment_action_id    assignment_action_id,
        paa1.assignment_id           assignment_id,
        paa1.tax_unit_id             tax_unit_id,
        substr(hou.name,1,228)       gre_name,           /*bug6998211*/
        paf.organization_id          organization_id,
        substr(hou1.name,1,228)      organization_name,
        paf.location_id              location_id,
        hrl.location_code            location_code
       ,paf.assignment_number        assignment_number -- #1937448
       ,paf.person_id                person_id
       ,paa.chunk_number             chunk_number
from    hr_locations_all             hrl,
        hr_all_organization_units    hou1,
        hr_all_organization_units    hou,
        per_assignments_f            paf,
        pay_payroll_actions          ppa,
        pay_assignment_actions       paa1,
        pay_temp_object_actions       paa,
        pay_payroll_actions          ppa_arch
  where paa.payroll_action_id   =   l_pactid
    and paa.chunk_number        =   l_chunk_no
    and paa.payroll_action_id      = ppa_arch.payroll_action_id
    and paa.object_id = paa1.assignment_action_id
    and ppa.payroll_action_id      = paa1.payroll_action_id
    and paf.assignment_id          = paa1.assignment_id
    and ppa.effective_date between   paf.effective_start_date
                               and   paf.effective_end_date
    and hrl.location_id            = paf.location_id
    and hou1.organization_id       = paf.organization_id
    and hou.organization_id        = paa1.tax_unit_id;

cursor sel_empname(l_person_id number,l_effective_date date)
is
select
     ppf.full_name
from per_all_people_f ppf
where ppf.person_id = l_person_id
  and l_effective_date between ppf.effective_start_date and ppf.effective_end_date;
l_chnk_number number;
begin
  --  hr_utility.trace_on('Y','GTN');
    l_row_count := 0;
    hr_utility.trace('PPCTID = '||p_payroll_action_id);
    hr_utility.trace('PPA_FINDER = '||ppa_finder);
    hr_utility.trace('p_asg_flag  ='||p_asg_flag);

    begin
        select to_number(ue.creator_id)
          into l_defined_balance_id
          from ff_user_entities ue,
               ff_database_items di
         where di.user_name = 'PAYMENTS_ASG_GRE_RUN'
           and ue.user_entity_id = di.user_entity_id
           and ue.creator_type = 'B'
           and nvl(ue.legislation_code,'US') = 'US';
    exception when others then
         hr_utility.trace('Error getting defined balance id');
         raise;
    end;

-- #3270485: moved to range_cursor procedure.
--
--    if chnkno = 1 then
--       insert into pay_us_rpt_totals (tax_unit_id,attribute1,organization_id,
--                                      attribute2,attribute3,attribute4,attribute5)
--                              values (pactid,'GTN',ppa_finder,
--                                      l_leg_param, l_business_group_id,
--                                      to_char(l_leg_start_date,'MM/DD/YYYY'),
--                                      to_char(l_leg_end_date,'MM/DD/YYYY'));
--       commit;
--    end if;

    l_asg_flag := nvl(p_asg_flag,'N');
    hr_utility.trace('l_asg_flag  ='||l_asg_flag);
    pay_us_balance_view_pkg.set_view_mode('ASG');
    pay_us_balance_view_pkg.set_calc_all_timetypes_flag(0);
    pay_us_balance_view_pkg.set_session_var('PTD',    'FALSE');
    pay_us_balance_view_pkg.set_session_var('PYDATE', 'FALSE');
    pay_us_balance_view_pkg.set_session_var('MONTH',  'FALSE');
    pay_us_balance_view_pkg.set_session_var('QTD',    'FALSE');
    pay_us_balance_view_pkg.set_session_var('CURRENT','FALSE');
    pay_us_balance_view_pkg.set_session_var('YTD',    'FALSE');




    open sel_aaid (p_payroll_action_id,p_chunk);
    loop
        fetch sel_aaid into  l_start_date,
                             l_end_date,
                             l_business_group_id,
                             l_payroll_action_id,
                             l_effective_date,
                             l_action_type,
                             l_assignment_action_id,
                             l_assignment_id,
                             l_tax_unit_id,
                             l_gre_name,
                             l_organization_id,
                             l_org_name,
                             l_location_id,
                             l_location_code,
                             l_assignment_number,
                             l_person_id,
                             l_chnk_number;

    hr_utility.trace('Number of Records fetched = '||to_char(sel_aaid%ROWCOUNT));

        exit when sel_aaid%notfound;
    open sel_empname(l_person_id,l_effective_date);
    fetch sel_empname into l_full_name;
    close sel_empname;
    begin
        select ppa.legislative_parameters,
               ppa.start_date,
               ppa.effective_date,
               pay_paygtn_pkg.get_parameter('TRANSFER_CONC_SET',ppa.legislative_parameters),
               pay_paygtn_pkg.get_parameter('TRANSFER_PAYROLL',ppa.legislative_parameters),
               pay_paygtn_pkg.get_parameter('TRANSFER_GRE',ppa.legislative_parameters),
               ppa.payroll_action_id
          into l_leg_param,
               l_leg_start_date,
               l_leg_end_date,
               t_consolidation_set_id,
               t_payroll_id,
               t_gre_id,
               t_payroll_action_id
          from pay_payroll_actions ppa
         where ppa.payroll_action_id = l_payroll_action_id;
    exception when no_data_found then
              hr_utility.trace('Legislative Details not found...');
              raise;
    end;
        hr_utility.trace('Start Date        = '||to_char(l_start_date));
        hr_utility.trace('End Date          = '||to_char(l_end_date));
        hr_utility.trace('BG ID             = '||to_char(l_business_group_id));
        hr_utility.trace('Payroll Action ID = '||to_char(l_payroll_action_id));
        hr_utility.trace('Effective Date    = '||to_char(l_effective_date));
        hr_utility.trace('Action Type       = '||l_action_type);
        hr_utility.trace('Asg Act ID        = '||to_char(l_assignment_action_id));
        hr_utility.trace('Asg ID            = '||to_char(l_assignment_id));
        hr_utility.trace('Tax Unit ID       = '||to_char(l_tax_unit_id));
        hr_utility.trace('GRE Name          = '||l_gre_name);
        hr_utility.trace('ORG ID            = '||to_char(l_organization_id));
        hr_utility.trace('ORG Name          = '||l_org_name);
        hr_utility.trace('Loc ID            = '||to_char(l_location_id));
        hr_utility.trace('Loc Code          = '||l_location_code);
        hr_utility.trace('Chunk Number      = '||l_chnk_number);

	-- Bug#4942114 starts
	/*
        hr_utility.trace('p_futa_where       = '||p_futa_where);
        hr_utility.trace('p_futa_from       = '||p_futa_from);
        load_deductions(l_assignment_action_id,p_ded_view_name);
        load_earnings  (l_assignment_action_id,p_earn_view_name);
   --   load_alien_earnings (l_assignment_action_id);
        load_ee_tax    (l_assignment_action_id,p_fed_view_name,p_state_view_name,p_local_view_name);
        load_er_tax    (l_assignment_action_id,p_fed_liab_view_name,p_state_liab_view_name,p_local_view_name);
        load_ee_credit (l_assignment_action_id,p_fed_view_name,p_state_view_name);
        load_er_credit (l_assignment_action_id,p_futa_where||l_assignment_action_id,p_futa_from);
        load_er_liab   (l_business_group_id,l_assignment_action_id,p_er_liab_where || l_assignment_action_id,p_er_liab_from);
        load_wc_er_liab   (l_business_group_id,l_assignment_action_id,p_wc_er_liab_where,p_wc_er_liab_from);
        */

	load_deductions(l_assignment_action_id,p_ded_bal_status1,p_ded_bal_status2);
        load_earnings  (l_assignment_action_id,p_earn_bal_status);
        load_ee_tax    (l_assignment_action_id,p_fed_bal_status,p_state_bal_status,p_local_bal_status);
        load_er_tax    (l_assignment_action_id,p_fed_liab_bal_status,p_state_liab_bal_status,p_local_bal_status);
        load_ee_credit (l_assignment_action_id,p_fed_bal_status,p_state_bal_status);
        load_er_credit (l_assignment_action_id,p_futa_status_count,p_futa_def_bal_id);
        load_er_liab   (l_business_group_id,l_assignment_action_id,p_er_liab_status);
        load_wc_er_liab   (l_business_group_id,l_assignment_action_id,p_wc_er_liab_status_count);
        -- Bug#4942114 ends

        if l_action_type in ('R','Q') then
           load_mesg_line (l_assignment_action_id);
           load_prepay (l_assignment_action_id);
        end if;
        if l_action_type = 'V' then
           load_reversals (l_assignment_action_id);
        end if;
/*        l_row_count := l_row_count +1;
        if l_row_count = 200 then
           l_row_count := 0;
           commit;
        end if;*/
        end loop;
        hr_utility.trace('End of LOAD DATA');
    close sel_aaid;
if (l_index <>0) then
for x in g_totals_table.first..g_totals_table.last LOOP
INSERT INTO pay_us_rpt_totals(tax_unit_id, gre_name,
                              organization_name, location_name,
           attribute1,
           attribute2,
           attribute3,
           attribute4,
           attribute5,
           value2,
           value3
) values
 (g_totals_table(x).tax_unit_id, g_totals_table(x).gre_name,
  g_totals_table(x).organization_name, g_totals_table(x).location_name,
           g_totals_table(x).attribute1,
           g_totals_table(x).attribute2,
           g_totals_table(x).attribute3,
           g_totals_table(x).attribute4,
           g_totals_table(x).attribute5,
           g_totals_table(x).value2,
           g_totals_table(x).value3
);
END LOOP;
/*forall x in g_totals_table.first..g_totals_table.last
insert into pay_us_rpt_totals
           values
           g_totals_table(x);*/
                      commit;
l_index :=0;
g_totals_table.DELETE;
end if;
--    commit;
exception
        when others then
        hr_utility.trace('Error occurred load_data ...' ||SQLERRM);
        raise;
end load_data;
--
------------------------------ end load data -------------------------------
end pay_gtnlod_pkg;

/
