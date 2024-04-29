--------------------------------------------------------
--  DDL for Package Body PAY_HK_IR56
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_HK_IR56" 
/* $Header: pyhkir56.pkb 120.3.12010000.6 2009/04/16 14:18:46 avenkatk ship $
**
**  Copyright (C) 2001 Oracle Corporation
**  All Rights Reserved
**
**  Change List
**
**  Date        Author   Bug     Ver    Description
**  ===============================================================================
**  06-MAR-2001 sclarke  N/A     115.0  Created
**  14-MAR-2001 sclarke          115.1  fix start date returned when less than 01-apr
**  16-MAR-2001 sclarke          115.2  added new function for tax year start, removed
**                                      return of zero values for emolument amounts.
**  22-Jul-2002 srrajago 2461715 115.3  Included the column 'actual_termination_date'
**                                      in the cursor 'csr_balance'and
**                                      modified p_periods to return actual_termination_date
**                                      instead of period_end_date.
**  12-Sep-2002 nsinghal 2563375 115.5  Create the New Cursor csr_Hire_date to get Start
**                                      date oF employmnet,If the period start date is
**                                      prior to employee's hire date.
**  15-Sep-2002 nsinghal 2563375 115.6  Create the New Cursor csr_Hire_date to get Start
**                                      date oF employmnet,If the period start date is
**                                      prior to employee's hire date,function get_emoluments
**                                      will return hire_date.
**  18-Sep-2002 nsinghal 2563375 115.7  Assign the Greatest of maximum of period start and
**                                      financial start dateto Start date ,before Comparing
**                                      with hire date to Check whether Hire Date is Greater
**                                      then Start date or not.
**  22-Nov-2002 nanuradh 2678084 115.8  Period end date is taken if the termination date is null.
**  02-Dec-2002 puchil   2689191 115.9  Changed the select statement for Cursor 'csr_Hire_date'.
**  02-Dec-2002 srrajago 2689229 115.10 Included 'nocopy' option in all the 'out' parameters of the
**                                      function get_emoluments.
**  14-Mar-2003 srrajago 2850738 115.11 Included the join paa.period_of_service_id = pps.period_of_service_id
**                                      in the cursor csr_hire_date so as to pick up the correct hire date
**                                      incase of rehire.
**  30-May-2003 kaverma  2920731 115.12 Replaced tables per_all_assignments_f and per_all_people_f by secured views
**                                      per_assignments_f and per_people_f respectively form the queries
**  24-Jul-2003 srrajago 3062419 115.13 Added two variables l_fin_start_date and l_fin_end_date for storing the
**                                      financial year start and end date respectively. p_periods value ( end_date
**                                      value only) modified so that it returns different values for IR56B and
**                                      IR56F and IR56G.
**  12-Dec-2003 srrajago 3193217 115.14 Modified the entire logic in the function 'get_emoluments'. Introduced a new
**                                      procedure 'populate_defined_balance_ids'.
**  12-Dec-2003 srrajago 3193217 115.15 Function 'get_emoluments' modified. Check for assignment_action_id passed being 0 or NULL
**                                      has been included.
**  17-Dec-2003 srrajago 3193217 115.16 In the function 'get_emoluments' -> IF check -> Replaced '!=' with '<>' to remove GSCC error.
**  09-Feb-2003 avenkatk 3417275 115.17 In the procedure 'populate_defined_balance_ids',removed references to the 4 IR56_Q quarter balances.
**  14-JUN-2004 abhkumar 3626489 115.18 Removed gscc warnings.
**  15-JUN-2004 abhkumar 3626489 115.19 Added hr_utility.debug_enabled to each of three functions.
**  15-JUN-2004 abhkumar 3626489 115.20 Commented hr_utility.debug_enabled and initialised g_debug to FALSE.
**  31-JAN-2005 JLin     3609072 115.21 Modified to be able to run the balance retrieval batch mode.
**  14-Dec-2005 snimmala 4864213 115.22 Added a new function get_quarters_start_date and is used in the view
**                                      pay_hk_ir56_quarters_info_v.
**  09-Jan-2005 vborhade 4688776 115.23 Modified procedure get_emoluments for period end date.
**  27-Sep-2007 skshin   6432592 115.24 Modified function get_emoluments to display indirect result for IR56_B
**  20-Mar-2009 pmatamsr 8348781 115.25 Added condition in 'get_emoluments' function to fetch null into period dates when IR56 balance
**                                      contains a zero value.
**  03-Apr-2009 pmatamsr 8406450 115.26 Removed code fix done as part of bug 4688776 for non-recurring processing type in 'get_emoluments' function.
**  04-Apr-2009 pmatamsr 8406450 115.27 Modified the code fix comments.
**  16-Apr-2009 avenkatk 8406450 115.28 Added check for Balance Adjustments. If any IR56 is Balance adjusted, the periods dates are fetched
**                                      like Non recurring entries.
**  16-Apr-2009 avenkatk 8406450 115.29 Resolved gscc failure
**
**
*/
as

g_debug boolean;
/* Bug # 3609072 */
p_balance_value_tab         pay_balance_pkg.t_balance_value_tab;
p_context_table             pay_balance_pkg.t_context_tab;
p_result_table              pay_balance_pkg.t_detailed_bal_out_tab;


FUNCTION  get_emoluments
  ( p_assignment_id         in per_assignments_f.assignment_id%TYPE
  , p_assignment_action_id  in pay_assignment_actions.assignment_action_id%TYPE
  , p_tax_unit_id           in pay_assignment_actions.tax_unit_id%TYPE
  , p_reporting_year        in number) RETURN g_emol_details_tab IS

   l_start_date               DATE;
   l_end_date                 DATE;
   l_fin_start_date           DATE;
   l_fin_end_date             DATE;
   l_processing_type          pay_element_types_f.processing_type%TYPE;
   l_particulars              hr_lookups.description%TYPE;
   l_hire_date                per_periods_of_service.date_start%TYPE;
   l_actual_termination_date  per_periods_of_service.actual_termination_date%TYPE;
   i                  NUMBER := 1;

   l_exists           NUMBER  := 0;

   CURSOR  csr_element_entry_dates
           (p_balance_name   pay_balance_types.balance_name%TYPE,
            p_fin_start_date date,
            p_fin_end_date   date)
       IS
   SELECT  min(pee.effective_start_date),
           max(pee.effective_end_date),
           min(pet.processing_type)
     FROM  pay_element_types_f     pet,
           pay_element_entries_f   pee,
           pay_element_links_f     pel,
           pay_balance_types       pbt,
           pay_balance_feeds_f     pbf,
           pay_input_values_f      piv
    WHERE  pee.assignment_id       = p_assignment_id
      AND  pee.element_link_id     = pel.element_link_id
      AND  pbf.balance_type_id     = pbt.balance_type_id
      AND  pbf.input_value_id      = piv.input_value_id
      AND  piv.element_type_id     = pel.element_type_id
      AND  pel.element_type_id     = pet.element_type_id
      AND  pbt.balance_name        = p_balance_name
      AND  ((pbf.legislation_code  = 'HK' and pbf.business_group_id IS NULL) OR
            (pbf.business_group_id = piv.business_group_id AND pbf.legislation_code IS NULL))
      AND  pee.effective_start_date <= p_fin_end_date
      AND  pee.effective_end_date   >= p_fin_start_date;

   CURSOR  csr_particulars(p_balance_name pay_balance_types.balance_name%TYPE)
       IS
   SELECT  hrl.description
     FROM  hr_lookups  hrl
    WHERE  hrl.lookup_type  = 'HK_IR56_BOX_DESC'
      AND  hrl.lookup_code  = p_balance_name
      AND  to_date('3103'||p_reporting_year,'DDMMYYYY')
           BETWEEN nvl(start_date_active,to_date('01010001','DDMMYYYY'))
           AND     nvl(end_date_active,to_date('31124712','DDMMYYYY'));

   CURSOR  csr_hire_date
       IS
   SELECT  pps.date_start,
           pps.actual_termination_date
     FROM  per_periods_of_service pps,
           per_people_f           ppf,
           per_assignments_f      paf
    WHERE  paf.person_id             = ppf.person_id
      AND  pps.person_id             = paf.person_id
      AND  paf.assignment_id         = p_assignment_id
      AND  paf.period_of_service_id  = pps.period_of_service_id;   /* Bug No : 2850738 */

    /* Bug 8406450 - Check if any Balance Ajdustments have been done for balance */

   CURSOR csr_balance_adj_exist
           (p_balance_name   pay_balance_types.balance_name%TYPE,
            p_fin_start_date date,
            p_fin_end_date   date)
   IS
   SELECT  COUNT(pivf.input_value_id)
     FROM  pay_element_entries_f   pee,
           pay_element_types_f     pet,
           pay_input_values_f      pivf,
           pay_balance_types       pbt,
           pay_balance_feeds_f     pbf
    WHERE  pee.assignment_id       = p_assignment_id
      AND  pee.entry_type          = 'B'
      AND  pee.element_type_id     = pet.element_type_id
      AND  pet.element_type_id     = pivf.element_type_id
      AND  pbf.input_value_id      = pivf.input_value_id
      AND  pbf.balance_type_id     = pbt.balance_type_id
      AND  pbt.balance_name        = p_balance_name
      AND  pbt.legislation_code    = 'HK'
      AND  ((pbf.legislation_code  = 'HK' and pbf.business_group_id IS NULL) OR
            (pbf.business_group_id = pivf.business_group_id AND pbf.legislation_code IS NULL))
      AND  pee.effective_start_date <= p_fin_end_date
      AND  pee.effective_end_date   >= p_fin_start_date;

BEGIN

/*Bug# 3626489 g_debug := hr_utility.debug_enabled;*/
g_debug := FALSE;

   IF g_debug THEN
      hr_utility.trace('Leaving:' || 'pay_hk_ir56.get_emoluments');
      hr_utility.trace('Values of the input parameters');
      hr_utility.trace('------------------------------');
      hr_utility.trace('Assignment id' || '       =>' || p_assignment_id);
      hr_utility.trace('Assignment Action Id' || '=>' || p_assignment_action_id);
      hr_utility.trace('Tax Unit Id' || '         =>' || p_tax_unit_id);
      hr_utility.trace('Reporting Year' || '      =>' || p_reporting_year);
   END IF;

   populate_defined_balance_ids;

   IF g_debug THEN
      hr_utility.trace('Balance Name              Balance Value');
      hr_utility.trace('----------------------------------------------');
   END IF;

   IF ((p_assignment_action_id IS NOT NULL) AND (p_assignment_action_id <> 0)) THEN


      /* Bug 3609072 */
      p_context_table(1).tax_unit_id := p_tax_unit_id;

      hr_utility.trace('Jay get_value');
      pay_balance_pkg.get_value(p_assignment_action_id => p_assignment_action_id
                               ,p_defined_balance_lst  => p_balance_value_tab
                               ,p_context_lst          => p_context_table
                               ,p_output_table         => p_result_table);


      FOR i IN p_balance_value_tab.FIRST..p_balance_value_tab.LAST
      LOOP
         g_emol_details(i).balance_value := p_result_table(i).balance_value; /* Bug 3609072 */
      END LOOP;

   ELSE

      FOR i IN p_balance_value_tab.FIRST..p_balance_value_tab.LAST
      LOOP
         IF (g_emol_details.EXISTS(i)) THEN
            g_emol_details(i).balance_value := 0;
         END IF;
      END LOOP;

   END IF;

   /* Bug No : 3062419 => Financial Year Start Date and End Date are found from the Reporting Year as below */

   l_fin_start_date := to_date('01/04/' || (p_reporting_year - 1),'DD/MM/YYYY');
   l_fin_end_date   := to_date('31/03/' || p_reporting_year,'DD/MM/YYYY');

   OPEN  csr_hire_date;
   FETCH csr_hire_date INTO l_hire_date,l_actual_termination_date;
   CLOSE csr_hire_date;

   IF g_debug THEN
      hr_utility.trace('Financial Year Start Date' || '=>' || l_fin_start_date);
      hr_utility.trace('Financial Year End Date'   || '=>' || l_fin_end_date);
      hr_utility.trace('Hire Date' || '                =>' || l_hire_date);
      hr_utility.trace('Actual Termination Date' || '  =>' || l_actual_termination_date);
      hr_utility.trace(' ');
      hr_utility.trace('Balance name    Period Dates            Particulars');
      hr_utility.trace('------------------------------------------------------------------');
   END IF;

   FOR i IN g_emol_details.FIRST..g_emol_details.LAST
   LOOP
      IF (g_emol_details.exists(i)) THEN
         OPEN  csr_particulars(g_emol_details(i).balance_name);
         FETCH csr_particulars INTO l_particulars;
            IF csr_particulars%NOTFOUND THEN
               g_emol_details(i).particulars := g_emol_details(i).balance_name;
            ELSE
               g_emol_details(i).particulars := l_particulars;
            END IF;
         CLOSE csr_particulars;

         OPEN  csr_element_entry_dates(g_emol_details(i).balance_name,l_fin_start_date,l_fin_end_date);
         FETCH csr_element_entry_dates INTO l_start_date,l_end_date,l_processing_type;
            /* bug 6432592 */
            IF (l_start_date IS NULL) AND (g_emol_details(i).balance_value > 0) THEN
                  g_emol_details(i).period_dates := to_char(greatest(l_hire_date,l_fin_start_date),'DD/MM/YYYY')||' - '||
                                                    to_char(least(nvl(l_actual_termination_date,l_fin_end_date),
                                                                  l_fin_end_date,
                                                                  nvl(l_end_date,l_fin_end_date)),
                                                            'DD/MM/YYYY');
            ELSIF (l_start_date IS NULL) THEN
               g_emol_details(i).balance_value := NULL;
               g_emol_details(i).period_dates  := NULL;
            /*Start of bug# 8348781 - If IR56 balance is zero,null is fetched to period dates*/
           ELSIF (g_emol_details(i).balance_value = 0) THEN
               g_emol_details(i).period_dates  := NULL;
          /*End of bug# 8348781*/
           ELSE
               -- Bug# 4688776
             /*8406450 - Period end date should be least of either termination date or tax year end date
                       - Fix done for non-recurring processing type as part of bug 4688776 is removed */
               IF (l_processing_type = 'N') THEN
                  g_emol_details(i).period_dates := to_char(greatest(l_hire_date,l_fin_start_date),'DD/MM/YYYY')||' - '||
                                                    to_char(least(nvl(l_actual_termination_date,l_fin_end_date),
                                                                  l_fin_end_date),'DD/MM/YYYY');
               ELSE
              /* 8406450 - Added Check to see if any Balance Adjustments have been done.
                           Bal Adjustment entries should be treated as NR entries irrespective of processing type */

                  l_exists := 0;
                  OPEN csr_balance_adj_exist(g_emol_details(i).balance_name,l_fin_start_date,l_fin_end_date);
                  FETCH csr_balance_adj_exist INTO l_exists;
                  CLOSE csr_balance_adj_exist;

                  IF (l_exists <> 0)
                  THEN
                      g_emol_details(i).period_dates := to_char(greatest(l_hire_date,l_fin_start_date),'DD/MM/YYYY')||' - '||
                                                        to_char(least(nvl(l_actual_termination_date,l_fin_end_date),
                                                                  l_fin_end_date),'DD/MM/YYYY');
                  ELSE
                      g_emol_details(i).period_dates := to_char(greatest(l_fin_start_date,
                                                                nvl(l_start_date,l_fin_start_date)),'DD/MM/YYYY')  ||' - '||
                                                        to_char(least(nvl(l_actual_termination_date,l_fin_end_date),l_fin_end_date,
                                                                  nvl(l_end_date,l_fin_end_date)),'DD/MM/YYYY');
                  END IF;
               END IF;
            END IF;
         CLOSE csr_element_entry_dates;

         IF g_debug THEN
            hr_utility.trace(g_emol_details(i).balance_name || '  ' || g_emol_details(i).period_dates || '  ' ||
                             g_emol_details(i).particulars || ' ' || g_emol_details(i).balance_value);
         END IF;
      END IF;
   END LOOP;

   RETURN g_emol_details;

   IF g_debug THEN
       hr_utility.trace('Leaving:' || 'pay_hk_ir56.get_emoluments');
   END IF;

EXCEPTION
   WHEN others THEN
      raise;
END;

PROCEDURE populate_defined_balance_ids
         IS
/*Bug #3417275 - Removed references to 4 IR56_Q quarters balances from cursor csr_defined_balance_id */
  CURSOR  csr_defined_balance_id
      IS
  SELECT  decode(pbt.balance_name,'IR56_A',1,'IR56_B',2,'IR56_C',3,'IR56_D',4,'IR56_E',5,
                                  'IR56_F',6,'IR56_G',7,'IR56_H',8,'IR56_I',9,'IR56_J',10,
                                  'IR56_K1',11,'IR56_K2',12,'IR56_K3',13,'IR56_L',14,'IR56_M',15
                                  ) sort_index,
          pbt.balance_name,
          pdb.defined_balance_id defined_balance_id
   FROM   pay_balance_types pbt,
          pay_balance_dimensions pbd,
          pay_defined_balances pdb
  WHERE   pbt.balance_name IN ('IR56_A','IR56_B','IR56_C','IR56_D','IR56_E','IR56_F','IR56_G','IR56_H',
                               'IR56_I','IR56_J','IR56_K1','IR56_K2','IR56_K3','IR56_L','IR56_M')
    AND   pbd.database_item_suffix = '_ASG_LE_YTD'
    AND   pbt.balance_type_id      = pdb.balance_type_id
    AND   pbd.balance_dimension_id = pdb.balance_dimension_id
    AND   pbt.legislation_code     = 'HK'
  ORDER BY sort_index;

  i NUMBER := 0;

BEGIN

   /* Bug# 3626489 g_debug := hr_utility.debug_enabled;*/
   g_debug := FALSE;

   IF g_debug THEN
      hr_utility.trace('Entering:' || 'pay_hk_ir56.populate_defined_balance_ids');
   END IF;

/* Bug 3609072 */
   p_balance_value_tab.delete;
   g_emol_details.delete;

/*   Note :-
     ------------------------------------------------------------
       Storage Location of
       Defined Balance ids             Balance Name
       with dimension '_ASG_LE_YTD'
     ------------------------------------------------------------
            1                          IR56_A
            2                          IR56_B
            3                          IR56_C
            4                          IR56_D
            5                          IR56_E
            6                          IR56_F
            7                          IR56_G
            8                          IR56_H
            9                          IR56_I
            10                         IR56_J
            11                         IR56_K1
            12                         IR56_K2
            13                         IR56_K3
            14                         IR56_L
            15                         IR56_M
     ------------------------------------------------------------ */

   IF g_debug THEN
      hr_utility.trace('Balance Name and its Defined Balance ids for IR56% Balances with dimension _ASG_LE_YTD');
      hr_utility.trace('--------------------------------------------------------------------------------------');
   END IF;

   FOR csr_rec IN csr_defined_balance_id
      LOOP
         /* Bug 3609072 */
         p_balance_value_tab(csr_rec.sort_index).defined_balance_id := csr_rec.defined_balance_id;
         g_emol_details(csr_rec.sort_index).balance_name            := csr_rec.balance_name;

         IF g_debug THEN
            hr_utility.trace(g_emol_details(csr_rec.sort_index).balance_name || '  ===>' ||
                             p_balance_value_tab(csr_rec.sort_index).defined_balance_id);
         END IF;

      END LOOP;
   IF g_debug THEN
      hr_utility.trace('---------------------------------------------------------------------------------------');
      hr_utility.trace('Leaving:' || 'pay_hk_ir56.populate_defined_balance_ids');
   END IF;

END populate_defined_balance_ids;

   --
  -- Get the start of the tax year
  --
  function get_tax_year_start
  (p_assignment_id        in number
  ,p_calculation_date     in date)
  return date is
    l_proc            varchar2(72);
    l_tax_year_start  date := null;
  begin

    /* Bug# 3626489 g_debug := hr_utility.debug_enabled;*/
    g_debug := FALSE;

    l_proc := 'pay_hk_ir56.get_last_anniversary'; --3626489
    hr_utility.trace('In: ' || l_proc) ;
    hr_utility.trace('  p_assignment_id: ' || to_char(p_assignment_id)) ;
    hr_utility.trace('  p_calculation_date: ' || to_char(p_calculation_date,'DD-MON-YYYY')) ;

    l_tax_year_start := to_date('0104'||to_char(p_calculation_date,'YYYY'),'DDMMYYYY');
    if (l_tax_year_start > p_calculation_date) then
      l_tax_year_start := add_months(l_tax_year_start,-12);
    end if;
    hr_utility.trace('  return: ' || to_char(l_tax_year_start,'DD-MON-YYYY')) ;
    hr_utility.trace('Out: ' || l_proc) ;
    return l_tax_year_start;
  end;

/*
 * Bug 4864213 - Added the following function get_quarters_start_date to return the quaters start date
 */

    FUNCTION get_quarters_start_date(p_assignment_id  in per_assignments_f.assignment_id%TYPE,
                                     p_source_id      in pay_hk_ir56_quarters_actions_v.l_source_id%TYPE)
    RETURN DATE IS

       l_quarters_start_date  pay_hk_ir56_quarters_actions_v.start_date%TYPE;

       CURSOR csr_get_quarters_start_date
       IS
       select min(start_date)
       from   pay_hk_ir56_quarters_actions_v
       where  assignment_id = p_assignment_id
       and    l_source_id   = p_source_id;

    BEGIN
       l_quarters_start_date := null;

       OPEN  csr_get_quarters_start_date;
       FETCH csr_get_quarters_start_date into l_quarters_start_date;
       CLOSE csr_get_quarters_start_date;

       IF l_quarters_start_date IS NOT NULL THEN
          RETURN l_quarters_start_date;
       END IF;

       RETURN null;
    END get_quarters_start_date;


end pay_hk_ir56;

/
