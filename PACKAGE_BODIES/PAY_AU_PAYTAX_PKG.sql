--------------------------------------------------------
--  DDL for Package Body PAY_AU_PAYTAX_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_AU_PAYTAX_PKG" as
/* $Header: pyaupyt.pkb 120.21.12010000.3 2008/09/26 01:11:30 skshin ship $ */

/*
**
**  Copyright (C) 1999 Oracle Corporation
**  All Rights Reserved
**
**  AU HRMS Payroll Tax package
**
**  Change List
**  ===========
**
**  Date        Author   Reference Description
**  -----------+--------+---------+-------------
**  29 JAN 2001 SHOSKATT  N/A       Creation
**  20 Jun 2002 Ragovind  2272424   Modified the Get_Tax Function to handle the user given override threshold.
**  03 Dec 2002 Ragovind  2689226   Added NOCOPY for the function get_tax.
**  09 AUG 2004 abhkumar  2610141   Added tax_unit_id in function GET_BALANCE for Legal Employer enhancement

**  25 AUG 2005 hnainani  3541814   Added / Modified functions for Payroll Tax Grouping
**  03 NOV 2005 hnainani  4709766   Added Period to get_parameters function
**  06 Nov 2005 hnainani  4713372    Added an Extra Parameter and cursor to archive le_balances
**  06 Nov 2005 hnainani  4716254    Corrected Flexfields being archived for Org Developer DF
**  07 Nov 2005 hnainani  4718544    Changed Dimension from _LE_RUN to _ASG_LE_RUN
**  10 Nov 2005 Hnainani  4729052     Added Date checks to csr_get_ass_le_act_id to get Total Taxable Income
**  10 Nov 2005 Hnainani  4731692    Added new flexfield to archive State Code in Balance Details
**  05 May 2006 Hnainani  5139764    Added new Termination State Breakdown Balances
**  29-May-2006 Hnainani  5235423    Added new joins to Employee Details Cursor
**  21-FEB-2007 hnainani  5893671    Removed the full name information from c_employee_details cursor
**                                   instead added a new cursor c_get_employee_full_name
**  26-FEB-2008 vdabgar   6839263    Modified cursors,csr_params and csr_report_params to pick p_output_type
**                                   accordingly.
**  18-Mar-2008 avenkatk  6839263    Backed out changes in assignment_Action_code and initialization_code
**  21-Mar-2008 avenkatk  6839263    Added Logic to set the OPP Template options for PDF output
**  19-SEP-2008 skshin    7280733    Added c_session cursor to be able to use Global values in run_formula in get_tax function
*/


g_debug boolean;
g_package  varchar2(26);


  g_arc_payroll_action_id           pay_payroll_actions.payroll_action_id%type;
  g_business_group_id		    hr_all_organization_units.organization_id%type;
  g_prev_assignment_id              number;
  g_le_taxable_income              number;
  g_count                          number;
  g_prev_tax_state                  varchar2(3);
  g_def_bal_populted                varchar2(1);


  /* Procedure to pass all the balance results back in one call from report */

procedure get_balances
 (p_assignment_action_id  in pay_assignment_actions.assignment_action_id%type,
   p_registered_employer        in NUMBER,
   p_tax_state                  in varchar2,
   p_salaries_wages             out NOCOPY number,
   p_commission                 out NOCOPY number,
   p_bonus_allowances           out NOCOPY number,
   p_director_fees              out NOCOPY number,
   p_termination_payments       out NOCOPY number,
   p_eligible_term_payments     out NOCOPY number,
   p_Fringe_Benefits            out NOCOPY number,
   p_Superannuation             out NOCOPY number,
   p_Contractor_Payments        out NOCOPY number,
   p_Other_Taxable_Income       out NOCOPY number,
   p_taxable_income         out NOCOPY number)
is

begin

   IF g_debug THEN
      hr_utility.trace('Entering:' || g_package  || 'get_balances');
      hr_utility.trace('Assignment action id value ===>' || p_assignment_action_id);
      hr_utility.trace('p_registered_employer ===>' || p_registered_employer);
   END IF;

    /* Call to this function below implements Batch Balance Retrieval for better performance */

     g_context_table(1).tax_unit_id := p_registered_employer;
     pay_balance_pkg.get_value(p_assignment_action_id => p_assignment_action_id,
                               p_defined_balance_lst=>g_balance_value_tab,
                               p_context_lst =>g_context_table,
                               p_output_table=>g_result_table);



     hr_utility.trace('Balance values for RUN dimension');
      hr_utility.trace('-------------------------------------');
      hr_utility.trace('Salaries_Wages   ===>'               || g_result_table(1).balance_value);
      hr_utility.trace('Commission   ==>'                    || g_result_table(2).balance_value);
      hr_utility.trace('Bonus_Allowances ===>'               || g_result_table(3).balance_value);
      hr_utility.trace('Director_Fees    ===>'               || g_result_table(4).balance_value);
/*      hr_utility.trace('Termination_Payments===>'            || g_result_table(5).balance_value);
      hr_utility.trace('Elgiible_Termination_Payments  ===>' || g_result_table(6).balance_value); */
      hr_utility.trace('Fringe_Benefits   ===>'              || g_result_table(6).balance_value);
      hr_utility.trace('Superannuation  ===>'                || g_result_table(7).balance_value);
      hr_utility.trace('Contractor_Payments      ===>'       || g_result_table(8).balance_value);
      hr_utility.trace('Other_Taxable_Income      ===>'      || g_result_table(9).balance_value);
      hr_utility.trace('Payroll_Taxable_income    ===>'      || g_result_table(10).balance_value);




   p_Salaries_Wages             := nvl(g_result_table(1).balance_value,0);
   p_commission                 := nvl(g_result_table(2).balance_value,0);
   p_bonus_allowances           := nvl(g_result_table(3).balance_value,0);
   p_director_fees              := nvl(g_result_table(4).balance_value,0);
   p_termination_payments       := nvl(g_result_table(5).balance_value,0);
   p_eligible_term_payments     := nvl(g_result_table(6).balance_value,0);
   p_fringe_benefits            := nvl(g_result_table(7).balance_value,0);
   p_Superannuation             := nvl(g_result_table(8).balance_value,0);
   p_Contractor_payments        := nvl(g_result_table(9).balance_value,0);
   p_other_taxable_income       := nvl(g_result_table(10).balance_value,0);
   p_taxable_income             := nvl(g_result_table(11).balance_value,0);


end get_balances;


FUNCTION GET_TAX(p_no_of_states number,
                   p_dge_state varchar2,
                   p_dge_group_name varchar2,
                   p_state_code varchar2,
                   p_taxable_income NUMBER,
                   p_le_taxable_income NUMBER,
                   p_message out NOCOPY varchar2,
                   p_ot_message out NOCOPY varchar2,
                   p_start_date date,
                   p_end_date date,
                   p_override_threshold NUMBER ) RETURN NUMBER IS

   l_tax number;
   l_formula_id NUMBER;
   l_inputs ff_exec.inputs_t;
   l_outputs ff_exec.outputs_t;
   l_session_flag varchar2(1);

   cursor c_formula is
        SELECT formula_id
        FROM   ff_formulas_f
        WHERE  formula_name = 'AU_PAYROLL_TAX'
        AND    p_start_date between effective_start_date  and effective_end_date
        ;
   /*bug7280733*/
   cursor c_session is
        SELECT 'X' INTO l_session_flag
        FROM fnd_sessions
        WHERE session_id = USERENV('SESSIONID');

  BEGIN


     l_inputs(1).name := 'STATE_CODE';
     l_inputs(1).value := p_state_code;
     l_inputs(2).name := 'TAXABLE_INCOME';
     l_inputs(2).value := p_taxable_income;
     l_inputs(3).name := 'OVERRIDE_THRESHOLD';
     l_inputs(3).value := p_override_threshold;
     l_inputs(4).name := 'DGE_STATE';
     l_inputs(4).value := p_dge_state;
     l_inputs(5).name := 'LE_TAXABLE_INCOME';
     l_inputs(5).value := p_le_taxable_income;
     l_inputs(6).name := 'NO_OF_STATES';
     l_inputs(6).value := p_no_of_states;
     l_inputs(7).name := 'GROUP_NAME';
     l_inputs(7).value := p_dge_group_name;
     l_outputs(1).name := 'MSG';
     l_outputs(2).name := 'PAYROLL_TAX';
     l_outputs(3).name := 'WARN_MSG';

     OPEN  c_formula;
     FETCH c_formula into l_formula_id;
     /* bug7280733 start */
     IF c_formula%FOUND THEN
        OPEN c_session;
        FETCH c_session into l_session_flag;
            IF c_session%NOTFOUND THEN
                    insert into fnd_sessions (SESSION_ID, EFFECTIVE_DATE) values (userenv('sessionid'),trunc(p_start_date));
            END IF;
        CLOSE c_session;
     END IF;
     /* bug7280733 end*/
    CLOSE c_formula;

     per_formula_functions.run_formula(p_formula_id => l_formula_id,
                        p_calculation_date => last_day(p_start_date),
                        p_inputs => l_inputs,
                        p_outputs => l_outputs);

     l_tax := l_outputs(2).value;
     hr_utility.trace('l_outputs(1).value :'||l_outputs(1).value);
     hr_utility.trace('l_outputs(2).value :'||l_outputs(2).value);
     hr_utility.trace('l_outputs(3).value :'||l_outputs(3).value);

     IF l_outputs(1).value = 'ZZZZ' THEN
        p_message:=null;
     ELSE
       p_message := l_outputs(1).value;
     END IF;

     IF l_outputs(3).value = 'ZZZZ' THEN
        p_ot_message := null;
     ELSE
        p_ot_message := l_outputs(3).value;
     END IF;

     hr_utility.trace('p_message :'||p_message);
     hr_utility.trace('l_tax :'||l_tax);
     return(l_tax);

     EXCEPTION when others THEN
       RAISE_APPLICATION_ERROR(-20001,'Function get_tax ' ||sqlerrm);

  END get_tax;



PROCEDURE populate_defined_balance_ids
          ( p_registered_employer NUMBER
            )   IS

/* 5139764 */
CURSOR   csr_defined_balance_id
          (c_database_item_suffix  pay_balance_dimensions.database_item_suffix%type)
IS
SELECT   decode(pbt.balance_name,'Payroll_Tax_Salaries_Wages',1,'Payroll_Tax_Commissions',2,
                'Payroll_Tax_Bonuses_Allowances',3,'Payroll_Tax_Director_Fees',4,
                'Payroll_Tax_Fringe_Benefits',7,'Payroll_Tax_Superannuation',8,
                'Payroll_Tax_Contractor_Payments',9, 'Payroll_Tax_Other_Taxable_Payments' , '10'
                 ) sort_index,
         pdb.defined_balance_id defined_balance_id
  FROM   pay_balance_types pbt,
         pay_balance_dimensions pbd,
         pay_defined_balances pdb
 WHERE   pbt.balance_name  IN ( 'Payroll_Tax_Salaries_Wages', 'Payroll_Tax_Commissions' ,
                               'Payroll_Tax_Bonuses_Allowances', 'Payroll_Tax_Director_Fees',
                               'Payroll_Tax_Fringe_Benefits', 'Payroll_Tax_Superannuation', 'Payroll_Tax_Contractor_Payments',
                               'Payroll_Tax_Other_Taxable_Payments' )
   AND   pbd.database_item_suffix = c_database_item_suffix
   AND   pbt.balance_type_id      = pdb.balance_type_id
   AND   pbd.balance_dimension_id = pdb.balance_dimension_id
   AND   pbt.legislation_code     = 'AU'
ORDER BY sort_index;

l_run_dimension_name VARCHAR2(15);
l_ytd_dimension_name VARCHAR2(15);

BEGIN

      hr_utility.trace('Entering:' || g_package  || 'populate_defined_balance_ids');

   g_balance_value_tab.delete;

	l_run_dimension_name := '_ASG_LE_RUN';

  /* The Balance's defined balance id are stored in the following order
     -----------------------------------------------------
        Storage Location of
       Run Defined Balance Id      Balance Name
     -----------------------------------------------------
            1                   Salaries_Wages
            2                   Commmission
            3                   Bonus_Allowances
            4                   Director_Fees
            7                   Fringe_Benefits
            8                   Superannaution
            9                   Contractor_Payments
            10                  Other_Taxable_Payments
            11                  Payroll_Taxable_Income
     -----------------------------------------------------
*/

 FOR csr_rec IN csr_defined_balance_id(l_run_dimension_name)
      LOOP
         g_balance_value_tab(csr_rec.sort_index).defined_balance_id := csr_rec.defined_balance_id;
      END LOOP;



END;

/*
* Implemented the Horizontal Archive for Payroll Tax Report
* Procedures
* 1. range_code
* 2. assignment_action_code
* 3. archive_code
* 4. spawn_archive_reports
*/

  procedure range_code
  (p_payroll_action_id  in  pay_payroll_actions.payroll_action_id%type
  ,p_sql                out NOCOPY varchar2
  ) is

  l_procedure         varchar2(200) ;

  begin

    g_debug :=hr_utility.debug_enabled ;

     l_procedure := g_package||'range_code';
     hr_utility.set_location('Entering '||l_procedure,1);

    -- Archive the payroll action level data  and EIT defintions.
    --  sql string to SELECT a range of assignments eligible for archival.
    p_sql := ' select distinct p.person_id'                             ||
             ' from   per_people_f p,'                                  ||
                    ' pay_payroll_actions pa'                           ||
             ' where  pa.payroll_action_id = :payroll_action_id'        ||
             ' and    p.business_group_id = pa.business_group_id'       ||
             ' order by p.person_id';

      hr_utility.set_location('Leaving '||l_procedure,1000);

  end range_code;

procedure initialization_code
  (p_payroll_action_id  in pay_payroll_actions.payroll_action_id%type)
  is
    l_procedure               varchar2(200) ;
     l_defined_balance_id number;
     l_term_defined_balance_id number;
     l_elig_term_defined_balance_id number;
     l_balance_Value number;
     l_term_balance_Value number;
     l_elig_term_balance_Value number;

  --------------------------------------------------------------------+
  -- Cursor      : csr_params
  -- Description : Fetches User Parameters from Legislative_paramters
  --               column.
  --------------------------------------------------------------------+

   CURSOR csr_params(c_payroll_action_id  pay_payroll_actions.payroll_action_id%TYPE)
      IS
        SELECT pay_core_utils.get_parameter('BG',legislative_parameters)    business_group_id,
                   pay_core_utils.get_parameter('LE',legislative_parameters) legal_employer,
              to_date(pay_core_utils.get_parameter('PERIOD',legislative_parameters),'YYYY/MM/DD') period, /*4709766 */
                   to_date(pay_core_utils.get_parameter('SDATE',legislative_parameters),'YYYY/MM/DD') start_date,
                   to_date(pay_core_utils.get_parameter('EDATE',legislative_parameters),'YYYY/MM/DD')   end_date,
                   pay_core_utils.get_parameter('TAX_STATE',legislative_parameters) Tax_state,
                   pay_core_utils.get_parameter('REP_TYPE',legislative_parameters)report_type,
                   pay_core_utils.get_parameter('REP_NAME',legislative_parameters)report_name,
                   pay_core_utils.get_parameter('ACTT',legislative_parameters)act_override_threshold,
                   pay_core_utils.get_parameter('VICT',legislative_parameters)vic_override_threshold,
                   pay_core_utils.get_parameter('NSWT',legislative_parameters)nsw_override_threshold,
                   pay_core_utils.get_parameter('QLDT',legislative_parameters)qld_override_threshold,
                   pay_core_utils.get_parameter('WAT',legislative_parameters)wa_override_threshold,
                   pay_core_utils.get_parameter('NTT',legislative_parameters)nt_override_threshold,
                   pay_core_utils.get_parameter('SAT',legislative_parameters)sa_override_threshold,
                   pay_core_utils.get_parameter('TAST',legislative_parameters)tas_override_threshold
                   FROM pay_payroll_actions ppa
      WHERE ppa.payroll_action_id  =  c_payroll_action_id;


/* 4713372 */
CURSOR   csr_Paytax_defined_balance_id
          (c_database_item_suffix  pay_balance_dimensions.database_item_suffix%type,
           c_state_code    varchar2)
IS
SELECT  pdb.defined_balance_id defined_balance_id
  FROM   pay_balance_types pbt,
         pay_balance_dimensions pbd,
         pay_defined_balances pdb
 WHERE   pbt.balance_name  = 'Payroll_Tax_' || c_state_code
   AND   pbd.database_item_suffix = c_database_item_suffix
   AND   pbt.balance_type_id      = pdb.balance_type_id
   AND   pbd.balance_dimension_id = pdb.balance_dimension_id
   AND   pbt.legislation_code     = 'AU';

/* 5139764 */
CURSOR   csr_TPaytax_defined_balance_id
          (c_database_item_suffix  pay_balance_dimensions.database_item_suffix%type,
           c_state_code    varchar2)
IS
SELECT  pdb.defined_balance_id defined_balance_id
  FROM   pay_balance_types pbt,
         pay_balance_dimensions pbd,
         pay_defined_balances pdb
 WHERE   pbt.balance_name  = 'Payroll_Tax_' || c_state_code || '_Termination_Payments'
   AND   pbd.database_item_suffix = c_database_item_suffix
   AND   pbt.balance_type_id      = pdb.balance_type_id
   AND   pbd.balance_dimension_id = pdb.balance_dimension_id
   AND   pbt.legislation_code     = 'AU';


/* 5139764 */

CURSOR   csr_ETPaytax_defined_balance
          (c_database_item_suffix  pay_balance_dimensions.database_item_suffix%type,
           c_state_code    varchar2)
IS
SELECT  pdb.defined_balance_id defined_balance_id
  FROM   pay_balance_types pbt,
         pay_balance_dimensions pbd,
         pay_defined_balances pdb
 WHERE   pbt.balance_name  = 'Payroll_Tax_' || c_state_code || '_Eligible_Termination_Payments'
   AND   pbd.database_item_suffix = c_database_item_suffix
   AND   pbt.balance_type_id      = pdb.balance_type_id
   AND   pbd.balance_dimension_id = pdb.balance_dimension_id
   AND   pbt.legislation_code     = 'AU';

/* 4713372 */
cursor csr_get_ass_le_act_id (c_business_group_id hr_all_organization_units.organization_id%TYPE,
                          c_registered_employer hr_all_organization_units.organization_id%TYPE,
                          c_start_date date,
                          c_end_date date)
is
select distinct per_information2, paa.tax_unit_id,
assignment_action_id assignment_action_id
from pay_payroll_actions ppa,
pay_assignment_actions paa,
per_people_f pap,
per_assignments_f paf
where paa.payroll_action_id = ppa.payroll_action_id
and pap.person_id = paf.person_id
and paa.assignment_id = paf.assignment_id
and paa.tax_unit_id=nvl(c_registered_employer, paa.tax_unit_id)
and paf.business_group_id=c_business_group_id
and ppa.action_status='C'
and    (pap.per_information3 = 'N' or pap.per_information3 is null)
and      ppa.action_type             in ('R','Q','I','B','V')
and ppa.effective_date between c_start_date and c_end_date
and ppa.effective_date between pap.effective_start_date and pap.effective_end_date /* 4729052 */
 AND (paa.source_action_id IS NULL
                     OR (paa.source_action_id IS NOT NULL AND ppa.run_type_id IS NULL))
and   paf.effective_end_date = (select max(effective_end_date) /* 4729052 */
                                        From  per_assignments_f iipaf
                                        WHERE iipaf.assignment_id  = paf.assignment_id
                                        and iipaf.effective_end_date >= c_start_date
                                        and iipaf.effective_start_date <= c_end_date)

order by per_information2;


Begin
    g_debug :=hr_utility.debug_enabled ;
        g_package := 'pay_au_tax_report_pkg.' ;
        l_procedure := g_package||'initialization_code';
        hr_utility.set_location('Entering '||l_procedure,1);


    -- initialization_code to to set the global tables for EIT
        -- that will be used by each thread in multi-threading.

    g_arc_payroll_action_id := p_payroll_action_id;

    -- Fetch the parameters by user passed into global variable.

        OPEN csr_params(p_payroll_action_id);
     	FETCH csr_params into g_parameters;
       	CLOSE csr_params;


   IF g_debug THEN
        hr_utility.set_location('p_payroll_action_id.........= ' || p_payroll_action_id,30);
        hr_utility.set_location('g_parameters.business_group_id.........= ' || g_parameters.business_group_id,30);
        hr_utility.set_location('g_parameters.legal_employer.........= ' || g_parameters.legal_employer,30);
        hr_utility.set_location('g_parameters.start_date..............= ' || g_parameters.start_date,30);
        hr_utility.set_location('g_parameters.end_date................= ' || g_parameters.end_date,30);
        hr_utility.set_location('g_parameters.tax_state.........= ' || g_parameters.tax_state,30);
        hr_utility.set_location('g_parameters.report_type..........= '||g_parameters.report_type,30);
        hr_utility.set_location('g_parameters.act_threshold..........= '||g_parameters.act_override_threshold,30);
        hr_utility.set_location('g_parameters.vic_threshold..........= '||g_parameters.vic_override_threshold,30);
        hr_utility.set_location('g_parameters.qld_threshold..........= '||g_parameters.qld_override_threshold,30);
        hr_utility.set_location('g_parameters.nsw_threshold..........= '||g_parameters.nsw_override_threshold,30);
        hr_utility.set_location('g_parameters.tas_threshold..........= '||g_parameters.tas_override_threshold,30);
        hr_utility.set_location('g_parameters.wa_threshold..........= '||g_parameters.wa_override_threshold,30);
        hr_utility.set_location('g_parameters.sa_threshold..........= '||g_parameters.sa_override_threshold,30);
        hr_utility.set_location('g_parameters.nt_threshold..........= '||g_parameters.nt_override_threshold,30);
  end if;

    g_business_group_id := g_parameters.business_group_id ;


    populate_defined_balance_ids(g_parameters.legal_employer);
/* 4713372 */

g_count := 0;
g_le_taxable_income := 0;
g_prev_tax_state := 'ZZZ';


for  csr_le_rec in csr_get_ass_le_act_id(g_business_group_id, g_parameters.legal_employer , g_parameters.start_date, g_parameters.end_date)
LOOP

open csr_paytax_defined_balance_id('_ASG_LE_RUN', csr_le_rec.per_information2); /* 4718544 */
fetch  csr_paytax_defined_balance_id into l_defined_balance_id;
close csr_paytax_defined_balance_id;

/* 5139764 */

open csr_tpaytax_defined_balance_id('_ASG_LE_RUN', csr_le_rec.per_information2); /* 4718544 */
fetch  csr_tpaytax_defined_balance_id into l_term_defined_balance_id;
close csr_tpaytax_defined_balance_id;

/* 5139764 */

open csr_etpaytax_defined_balance('_ASG_LE_RUN', csr_le_rec.per_information2); /* 4718544 */
fetch  csr_etpaytax_defined_balance into l_elig_term_defined_balance_id;
close csr_etpaytax_defined_balance;

hr_utility.set_location('l_term_defined ' || l_term_defined_balance_id,99);
hr_utility.set_location('per_information ' || csr_le_rec.per_information2,99);

l_balance_value :=    pay_balance_pkg.get_value(l_defined_balance_id,
                             csr_le_rec.assignment_action_id, csr_le_rec.tax_unit_id, null,null,null,null);

/* 5139764 */

l_term_balance_value :=    pay_balance_pkg.get_value(l_term_defined_balance_id,
                             csr_le_rec.assignment_action_id, csr_le_rec.tax_unit_id, null,null,null,null);

/* 5139764 */

l_elig_term_balance_value :=    pay_balance_pkg.get_value(l_elig_term_defined_balance_id,
                             csr_le_rec.assignment_action_id, csr_le_rec.tax_unit_id, null,null,null,null);

hr_utility.set_location('l_balanace_value ' || l_balance_value,999);

g_le_taxable_income := nvl(g_le_taxable_income,0) + l_balance_value;

if g_prev_tax_state <> csr_le_rec.per_information2
then

g_count := g_count + 1;
g_prev_tax_state := csr_le_rec.per_information2;

end if;

END LOOP;
/* 4713372 */
    if g_debug then
            hr_utility.set_location('Leaving '||l_procedure,1000);
    end if;

  end initialization_code;

  --------------------------------------------------------------------+
  -- Name  : assignment_Action_code
  -- Type  : Procedure
  -- Access: Public
  -- This procedure further restricts the assignment_id's
  -- returned by range_code
  -- This procedure gets the parameters given by user and restricts
  -- the assignments to be archived.
  -- it then calls hr_nonrun.insact to create an assignment action id
  -- it then archives Payroll Run assignment action id  details
  -- in pay_Action_information with context 'AU_ARCHIVE_ASG_DETAILS'
  -- for each assignment.
  -- There are 10 different cursors for choosing the assignment ids.
  -- Depending on the parameters passed,the appropriate cursor is used.
  --------------------------------------------------------------------+

procedure assignment_action_code
  (p_payroll_action_id in pay_payroll_actions.payroll_action_id%type
  ,p_start_person      in per_all_people_f.person_id%type
  ,p_end_person        in per_all_people_f.person_id%type
  ,p_chunk             in number
  ) is



   cursor csr_assignment_period
      (p_payroll_action_id  pay_payroll_actions.payroll_action_id%type
      ,p_start_person       per_all_people_f.person_id%type
      ,p_end_person         per_all_people_f.person_id%type
      ,p_report_type        varchar2
      ,p_business_group_id  hr_all_organization_units.organization_id%type
      ,p_legal_employer     hr_all_organization_units.organization_id%type
      ,p_archive_start_date         date
      ,p_archive_end_date           date
      ,p_tax_state            varchar2
      ) is
        select  paa.assignment_action_id,
                paa.action_sequence,
                paaf.assignment_id,
                paa.tax_unit_id,
                paa.source_action_id master_action_id,
               paa2.tax_unit_id master_tax_unit_id
        from    per_people_f pap,
                per_assignments_f paaf,
                pay_payroll_actions ppa,
                pay_payroll_actions ppa1,
                pay_assignment_actions paa,
                pay_assignment_actions paa2,
                per_periods_of_service pps
        where   ppa.payroll_action_id        = p_payroll_action_id
        and     paa.assignment_id            = paaf.assignment_id
        and     paa2.assignment_id            = paaf.assignment_id
        AND     paa2.assignment_id           = paa.assignment_id
        and     pap.person_id                between p_start_person and p_end_person
        and     pap.person_id                = paaf.person_id
        and     pap.person_id                = pps.person_id
        and     pps.period_of_service_id     = paaf.period_of_service_id
        and     ppa1.date_earned between pap.effective_start_date  and pap.effective_end_date
        and    ppa1.payroll_action_id       = paa.payroll_action_id
        and    ppa1.payroll_action_id       = paa2.payroll_action_id
        AND    paa2.action_status ='C'
        AND    paa.action_status ='C'
        and    (pap.per_information3 = 'N' or pap.per_information3 is null)
        AND   (pap.per_information2  = p_tax_state or p_tax_state is null)
        AND    paa2.assignment_action_id = nvl(paa.source_action_id, paa.assignment_action_id)
         AND (paa.source_action_id IS NULL)
        --             OR (paa.source_action_id IS NOT NULL AND ppa.run_type_id IS NULL))
        and    ppa1.business_group_id       = ppa.business_group_id
        and    ppa.business_group_id        = p_business_group_id
        and    ppa1.action_type             in ('R','Q','I','B','V')
        and   ( paa.tax_unit_id              = p_legal_employer or p_legal_employer is null)
        and    ppa1.effective_date  between p_archive_start_date and p_archive_end_date
   and   paaf.effective_end_date = (select max(effective_end_date)
                                        From  per_assignments_f iipaf
                                        WHERE iipaf.assignment_id  = paaf.assignment_id
                                        and iipaf.effective_end_date >= p_archive_start_date
                                        and iipaf.effective_start_date <= p_archive_end_date)
        order  by paaf.assignment_id, paa.assignment_action_id, paa.tax_unit_id, paa.source_action_id, paa2.tax_unit_id;


  --------------------------------------------------------------------+
  -- Cursor      : csr_params
  -- Description : Fetches User Parameters from Legislative_paramters
  --               column.
  --------------------------------------------------------------------+

 CURSOR csr_params(c_payroll_action_id  pay_payroll_actions.payroll_action_id%TYPE)
      IS
      SELECT pay_core_utils.get_parameter('BG',legislative_parameters)    business_group_id,
                   pay_core_utils.get_parameter('LE',legislative_parameters) legal_employer,
                   to_date(pay_core_utils.get_parameter('PERIOD',legislative_parameters),'YYYY/MM/DD') period,
                   to_date(pay_core_utils.get_parameter('SDATE',legislative_parameters),'YYYY/MM/DD') start_date,
                   to_date(pay_core_utils.get_parameter('EDATE',legislative_parameters),'YYYY/MM/DD')   end_date,
                   pay_core_utils.get_parameter('TAX_STATE',legislative_parameters) Tax_state,
                   pay_core_utils.get_parameter('REP_TYPE',legislative_parameters)report_type,
                   pay_core_utils.get_parameter('REP_NAME',legislative_parameters)report_name,
                   pay_core_utils.get_parameter('ACTT',legislative_parameters)act_override_threshold,
                   pay_core_utils.get_parameter('VICT',legislative_parameters)vic_override_threshold,
                   pay_core_utils.get_parameter('NSWT',legislative_parameters)nsw_override_threshold,
                   pay_core_utils.get_parameter('QLDT',legislative_parameters)qld_override_threshold,
                   pay_core_utils.get_parameter('WAT',legislative_parameters)wa_override_threshold,
                   pay_core_utils.get_parameter('NTT',legislative_parameters)nt_override_threshold,
                   pay_core_utils.get_parameter('SAT',legislative_parameters)sa_override_threshold,
                   pay_core_utils.get_parameter('TAST',legislative_parameters)tas_override_threshold
                   FROM pay_payroll_actions ppa
      WHERE ppa.payroll_action_id  =  c_payroll_action_id;



    cursor csr_next_action_id is
    select pay_assignment_actions_s.nextval
    from   dual;

    l_next_assignment_action_id       pay_assignment_actions.assignment_action_id%type;
    l_procedure               	      varchar2(200) ;
    i 				      number;

    l_action_information_id 	 	number;
    l_object_version_number		number;


begin
    i := 1;
        g_package := 'pay_au_tax_rep_pkg.' ;
        l_procedure := g_package||'assignment_action_code';
        hr_utility.set_location('Entering ' || l_procedure,1);
        hr_utility.set_location('Entering assignment_Action_code',302);


    -- initialization_code to to set the global tables for EIT
        -- that will be used by each thread in multi-threading.
    g_arc_payroll_action_id := p_payroll_action_id;
     hr_utility.set_location('p_payroll_Action' || p_payroll_Action_id, 777);

    -- Fetch the parameters by user passed into global variable.

        OPEN csr_params(p_payroll_action_id);
     	FETCH csr_params into g_parameters;
       	CLOSE csr_params;


   IF g_debug THEN

        hr_utility.set_location('p_payroll_action_id.........= ' || p_payroll_action_id,30);
        hr_utility.set_location('g_parameters.business_group_id.........= ' || g_parameters.business_group_id,30);
        hr_utility.set_location('g_parameters.legal_employer.........= ' || g_parameters.legal_employer,30);
        hr_utility.set_location('g_parameters.start_date..............= ' || g_parameters.start_date,30);
        hr_utility.set_location('g_parameters.end_date................= ' || g_parameters.end_date,30);
        hr_utility.set_location('g_parameters.tax_state.........= ' || g_parameters.tax_state,30);
        hr_utility.set_location('g_parameters.report_type..........= '||g_parameters.report_type,30);
        hr_utility.set_location('g_parameters.act_threshold..........= '||g_parameters.act_override_threshold,30);
        hr_utility.set_location('g_parameters.vic_threshold..........= '||g_parameters.vic_override_threshold,30);
        hr_utility.set_location('g_parameters.qld_threshold..........= '||g_parameters.qld_override_threshold,30);
        hr_utility.set_location('g_parameters.nsw_threshold..........= '||g_parameters.nsw_override_threshold,30);
        hr_utility.set_location('g_parameters.tas_threshold..........= '||g_parameters.tas_override_threshold,30);
        hr_utility.set_location('g_parameters.wa_threshold..........= '||g_parameters.wa_override_threshold,30);
        hr_utility.set_location('g_parameters.sa_threshold..........= '||g_parameters.sa_override_threshold,30);
        hr_utility.set_location('g_parameters.nt_threshold..........= '||g_parameters.nt_override_threshold,30);

 end if;

    g_business_group_id := g_parameters.business_group_id ;





                 FOR csr_rec in csr_assignment_period(p_payroll_action_id,
                 					 p_start_person,
                 					 p_end_person,
                 					 g_parameters.report_type,
                 					 g_parameters.business_group_id,
                                                         g_parameters.legal_employer,
                 					 g_parameters.start_date,
                 					 g_parameters.end_date,
                                                         g_parameters.tax_state)
                 LOOP
                        hr_utility.set_location('in loop' , 555);
                      open csr_next_action_id;
         	     fetch  csr_next_action_id into l_next_assignment_action_id;
         	     close csr_next_action_id;

         	    -- Create the archive assignment actions
         	     hr_nonrun_asact.insact(l_next_assignment_action_id, csr_rec.assignment_id, p_payroll_action_id, p_chunk, csr_rec.tax_unit_id);

                  	insert into pay_action_information(
                  	              action_information_id,
                  	              action_context_id,
                  	              action_context_type,
                  	              effective_date,
                  	              source_id,
                  	              tax_unit_id,
                  	              action_information_category,
                  	              action_information1,
                  	              action_information2,
                  	              action_information3,
                  	              assignment_id
                  	              )
                  	              values(
                  	              pay_action_information_s.nextval,
                  	              l_next_assignment_action_id,
                  	              'AAP',
                  	              null,
                  	              null,
                  	              csr_rec.tax_unit_id,
                  	              'AU_ARCHIVE_ASG_DETAILS',
                  	              csr_rec.assignment_action_id,
                  	              p_payroll_action_id,
                  	              csr_rec.action_sequence,
                  	              csr_rec.assignment_id
                  	              );


                 END LOOP;
                 if g_debug then
                 hr_utility.set_location('Leaving............Loop7. Asg + Period...' || l_procedure,1000);
                 end if;

exception
    when others then
      hr_utility.set_location('Error in '||l_procedure,999999);
      raise;
end assignment_action_code;

procedure archive_code
  (p_assignment_action_id  in pay_assignment_actions.assignment_action_id%type
  ,p_effective_date        in pay_payroll_actions.effective_date%type
  ) is

/*  5893671*/
cursor c_get_employee_full_name (c_person_id number, c_end_date date, c_start_date date)
is
select full_name
from per_people_f pap
where person_id= c_person_id
and pap.effective_end_date =
(select max(effective_end_date)
from per_people_f pap1
where pap1.person_id = pap.person_id
and pap1.effective_end_date >= c_start_date
and pap1.effective_start_date <= c_end_date
);

 cursor c_employee_details(c_business_group_id hr_all_organization_units.organization_id%TYPE,
   	                    c_assignment_id number,c_end_date date, c_start_date date,
                            c_assignment_action_id number,
                            c_payroll_action_id number)
  is /* 5893671 - commented out full name*/
select  /*  pap.full_name, */
         paaf.assignment_number employee_number,
         ppa1.effective_date,
         paa2.assignment_action_id,
         paaf.assignment_id,
         paaf.organization_id,
         hou.NAME organization_name,
         hsc.segment1 tax_unit_id,
         hou1.NAME Legal_Employer ,
         pap.person_id,
         pap.per_information2 state_code ,
         hoi.org_information1 business_group_id,
 /* 4716254 ,4718544 */
         decode(pap.per_information2 , 'VIC', hoi.org_information4,
                                       'WA' , hoi.org_information11,
                                       'QLD' , hoi.org_information7,
                                       'SA' , hoi.org_information8,
                                       'NSW' , hoi.org_information5,
                                       'ACT' , hoi.org_information10,
                                       'NT' , hoi.org_information9,
                                       'TAS' , hoi.org_information6) dge_state,
 /* 4716254 ,4718544 */

         hoi.org_information2 dge_legal_employer,
         hoi.org_information3 dge_group_name,
         hl.meaning state_desc
   from    per_people_f pap,
           per_assignments_f paaf,
           pay_payroll_actions ppa,
           pay_payroll_actions ppa1,
           pay_assignment_actions paa,
           pay_assignment_actions paa2,
           hr_soft_coding_keyflex hsc,
           hr_organization_units hou,
           hr_organization_units hou1,
           hr_organization_information hoi,
           hr_lookups  hl,
           per_periods_of_service pps
    where   ppa.payroll_action_id        = c_payroll_action_id
       and  paa.assignment_Action_id = c_assignment_Action_id /*5235423 */
       and     paa.assignment_id            = paaf.assignment_id
       and    pap.person_id = paaf.person_id
       and    paa.assignment_id = c_assignment_id
       AND    pap.per_information2 = hl.lookup_code
       AND    hl.lookup_type = 'AU_STATE'
       AND    hsc.soft_coding_keyflex_id = paaf.soft_coding_keyflex_id
       AND    hou.organization_id = paaf.organization_id
       and    hoi.org_information_context(+) = 'AU_PAYROLL_TAX_DGE'
       AND    hou1.organization_id = hoi.organization_id(+)
       AND    hou1.organization_id = hsc.segment1
       AND     paa2.assignment_id           = paa.assignment_id
       and     pap.person_id                = pps.person_id
       and     pps.period_of_service_id     = paaf.period_of_service_id
       and     ppa1.date_earned between pap.effective_start_date  and pap.effective_end_date
       and    ppa1.payroll_action_id       = paa.payroll_action_id
       and    ppa1.payroll_action_id       = paa2.payroll_action_id
        AND    paa2.action_status ='C'
        AND    paa.action_status ='C'
        and    (pap.per_information3 = 'N' or pap.per_information3 is null)
        AND    paa2.assignment_action_id = nvl(paa.source_action_id, paa.assignment_action_id)
         AND paa.source_action_id IS NULL /* 5235423 */
        and    ppa1.business_group_id       = ppa.business_group_id
        and    ppa.business_group_id        = c_business_group_id
        and    ppa1.action_type             in ('R','Q','I','B','V')
        and    ppa1.effective_date  between c_start_date and c_end_date
        and paaf.effective_end_date = (select max(effective_end_date)
                                        From  per_assignments_f iipaf
                                        WHERE iipaf.assignment_id  = paaf.assignment_id
                                        and iipaf.effective_end_date >= c_start_date
                                        and iipaf.effective_start_date <= c_end_date)
 /* and   c_end_date between pap.effective_start_date and pap.effective_end_date */
        order  by paaf.assignment_id, paa2.assignment_action_id, hsc.segment1;



    cursor csr_get_data (c_arc_ass_act_id number)
    is
    select pai.action_information1, pai.action_information2, pai.tax_unit_id, pai.assignment_id,pai.action_information3
    from pay_action_information pai
    where action_information_category = 'AU_ARCHIVE_ASG_DETAILS'
    and  pai.action_context_id = c_arc_ass_act_id;


 CURSOR   csr_Paytax_defined_balance_id
          (c_database_item_suffix  pay_balance_dimensions.database_item_suffix%type,
           c_state_code    varchar2)
IS
SELECT  pdb.defined_balance_id defined_balance_id
  FROM   pay_balance_types pbt,
         pay_balance_dimensions pbd,
         pay_defined_balances pdb
 WHERE   pbt.balance_name  = 'Payroll_Tax_' || c_state_code
   AND   pbd.database_item_suffix = c_database_item_suffix
   AND   pbt.balance_type_id      = pdb.balance_type_id
   AND   pbd.balance_dimension_id = pdb.balance_dimension_id
   AND   pbt.legislation_code     = 'AU';


/* 5139764 */

CURSOR   csr_TPaytax_defined_balance_id
          (c_database_item_suffix  pay_balance_dimensions.database_item_suffix%type,
           c_state_code    varchar2)
IS
SELECT  pdb.defined_balance_id defined_balance_id
  FROM   pay_balance_types pbt,
         pay_balance_dimensions pbd,
         pay_defined_balances pdb
 WHERE   pbt.balance_name  = 'Payroll_Tax_' || c_state_code || '_Termination_Payments'
   AND   pbd.database_item_suffix = c_database_item_suffix
   AND   pbt.balance_type_id      = pdb.balance_type_id
   AND   pbd.balance_dimension_id = pdb.balance_dimension_id
   AND   pbt.legislation_code     = 'AU';


/* 5139764 */

CURSOR   csr_ETPaytax_defined_balance
          (c_database_item_suffix  pay_balance_dimensions.database_item_suffix%type,
           c_state_code    varchar2)
IS
SELECT  pdb.defined_balance_id defined_balance_id
  FROM   pay_balance_types pbt,
         pay_balance_dimensions pbd,
         pay_defined_balances pdb
 WHERE   pbt.balance_name  = 'Payroll_Tax_' || c_state_code || '_Eligible_Termination_Payments'
   AND   pbd.database_item_suffix = c_database_item_suffix
   AND   pbt.balance_type_id      = pdb.balance_type_id
   AND   pbd.balance_dimension_id = pdb.balance_dimension_id
   AND   pbt.legislation_code     = 'AU';


    l_procedure                       varchar2(200);
    l_action_information_id    	    number;
    l_object_version_number	    number;

    l_SALARIES_WAGES		    number :=0;
    l_COMMISSION                    number:=0;
    l_BONUS_ALLOWANCES              number:=0;
    l_DIRECTOR_FEES                 number :=0;
    l_TERMINATION_PAYMENTS          number :=0;
    l_ELIGIBLE_TERM_PAYMENTS        number :=0;
    l_FRINGE_BENEFITS               number :=0;
    l_SUPERANNUATION                number :=0;
    l_CONTRACTOR_PAYMENTS           number :=0;
    l_OTHER_TAXABLE_INCOME          number :=0;
    L_TAXABLE_INCOME            number :=0;
    L_LE_TAXABLE_INCOME            number :=0;
    L_NSW_TAXABLE_INCOME            number :=0;
    L_QLD_TAXABLE_INCOME            number :=0;
    L_ACT_TAXABLE_INCOME            number :=0;
    L_NT_TAXABLE_INCOME            number :=0;
    L_SA_TAXABLE_INCOME            number :=0;
    L_WA_TAXABLE_INCOME            number :=0;
    L_TAS_TAXABLE_INCOME            number :=0;
    l_count                         number    :=0;
    l_run_dimension_name            varchar2(15);
      l_ass_act_id 		    number;
    l_payroll_action_id 		    number;
    l_tax_unit_id 	   number;
    l_assignment_id 		number;
    l_full_name          varchar2(100);

    l_action_sequence      number;
    l_max_asg_action_id number;
    l_max_action_sequence  number;
     l_defined_balance_id number;

begin

    g_debug :=hr_utility.debug_enabled ;
    g_package := 'pay_au_tax_rep_pkg.' ;
    l_procedure  := g_package||'archive_code';
  l_run_dimension_name := '_ASG_LE_RUN';



    OPEN csr_get_data(p_assignment_action_id);
    FETCH csr_get_data into l_ass_act_id, l_payroll_Action_id,l_tax_unit_id, l_assignment_id,l_action_sequence;
    CLOSE csr_get_data;


 FOR csr_rec in c_employee_details(g_business_group_id,l_assignment_id,g_parameters.end_date,g_parameters.start_date,l_ass_act_id,l_payroll_action_id)
 LOOP
    /* 5893671 */


     OPEN c_get_employee_full_name(csr_rec.person_id, g_parameters.end_date, g_parameters.start_date);
     FETCH c_get_employee_full_name into l_full_name;
     CLOSE c_get_employee_full_name;

     	g_prev_assignment_id := csr_rec.assignment_id;
        g_prev_tax_state := csr_rec.state_code;


/* 5139764 */

FOR csr_pt IN csr_Paytax_defined_balance_id(l_run_dimension_name, csr_rec.state_code)
      LOOP
         g_balance_value_tab(11).defined_balance_id := csr_pt.defined_balance_id;
      END LOOP;

/* 5139764 */

FOR csr_ptt IN csr_TPaytax_defined_balance_id(l_run_dimension_name, csr_rec.state_code)
      LOOP
         g_balance_value_tab(5).defined_balance_id := csr_ptt.defined_balance_id;
      END LOOP;


FOR csr_eptt IN csr_ETPaytax_defined_balance(l_run_dimension_name, csr_rec.state_code)
      LOOP
         g_balance_value_tab(6).defined_balance_id := csr_eptt.defined_balance_id;
      END LOOP;

          -- Balances Coding for BBR

            -- Get The Action Sequence for the Assignment_Action_Id.

            GET_BALANCES(
                 P_ASSIGNMENT_ACTION_ID         => csr_rec.assignment_action_id,
                 P_REGISTERED_EMPLOYER          => l_tax_unit_id,
                 P_TAX_STATE                     => csr_rec.state_code,
                 P_SALARIES_WAGES               => l_SALARIES_WAGES,
                 P_COMMISSION                   => l_COMMISSION,
                 P_BONUS_ALLOWANCES             => l_BONUS_ALLOWANCES    ,
                 P_DIRECTOR_FEES                => l_DIRECTOR_FEES,
                 P_TERMINATION_PAYMENTS         => l_TERMINATION_PAYMENTS,
                 P_ELIGIBLE_TERM_PAYMENTS       => l_ELIGIBLE_TERM_PAYMENTS,
                 P_FRINGE_BENEFITS              => l_FRINGE_BENEFITS,
                 P_SUPERANNUATION               => l_SUPERANNUATION,
                 P_CONTRACTOR_PAYMENTS          => l_CONTRACTOR_PAYMENTS,
                 P_OTHER_TAXABLE_INCOME         => l_OTHER_TAXABLE_INCOME,
                 P_TAXABLE_INCOME               => l_TAXABLE_INCOME);

            hr_utility.set_location('in BBR loop', 300);
               insert into pay_action_information(
                            action_information_id,
                            action_context_id,
                            action_context_type,
                            effective_date,
                            source_id,
                            tax_unit_id,
                            action_information_category,
                            assignment_id,
                            action_information1,
                            action_information2,
                            action_information3,
                            action_information4,
                            action_information5,
                            action_information6,
                            action_information7,
                            action_information8,
                            action_information9)
                    values(
                            pay_action_information_s.nextval,
                            g_arc_payroll_action_id,
                            'PA',
                            p_effective_date,
                            null,
                            l_tax_unit_id,
                            'AU_PAYROLL_TAX_EMPLOYEE_DETAILS',
                            l_assignment_id,
                            csr_rec.employee_number,
                            csr_rec.person_id,
                            l_full_name,
                            csr_rec.state_desc,
                            csr_rec.legal_employer,
                            csr_rec.state_code,
                            csr_rec.dge_state,
                            csr_rec.dge_legal_employer,
                            csr_rec.dge_group_name);




           --
           -- Insert the balance data into pay_action_information table
           -- This Direct Insert statement is for Performance Reasons.
           --
             insert into pay_action_information (
                                      action_information_id,
                                      action_context_id,
                                      action_context_type,
             			       effective_date,
             			       source_id,
                                      tax_unit_id,
                                      assignment_id,
                                      action_information_category,
                                      action_information1,
                                      action_information2,
                                      action_information3,
                                      action_information4,
                                      action_information5,
                                      action_information6,
                                      action_information7,
                                      action_information8,
                                      action_information9,
                                      action_information10,
                                      action_information11,
                                      action_information12,
                                      action_information13,
                                      action_information14,
                                      action_information15) /* 4731692 */
                          values (
                                pay_action_information_s.nextval,
                                p_assignment_action_id,
             			 'AAP',
                                p_effective_date,
                                null,
             			 l_tax_unit_id,
             			 l_assignment_id,
             			 'AU_PAYROLL_TAX_BALANCE_DETAILS',
             			 l_salaries_wages,
             			 l_commission,
             			 l_bonus_allowances,
             			 l_director_fees,
             			 l_termination_payments,
                                 l_eligible_term_payments,
             			 l_Fringe_Benefits,
				 l_Superannuation,
				 l_Contractor_payments,
				 l_Other_taxable_Income,
                                 l_Taxable_Income,
                                 l_max_action_sequence,
                                 g_le_taxable_income, /* 4713372 */
                                 g_count,
                                  csr_rec.state_code); /* 4731692 */

 END LOOP; /* End of assignments r employee */

end archive_code;

procedure spawn_archive_reports
(p_payroll_action_id in pay_payroll_actions.payroll_action_id%type)
  is
 l_count                number;
 ps_request_id          NUMBER;
 l_print_style          VARCHAR2(2);
 l_report_name          VARCHAR2(30);
 l_short_report_name          VARCHAR2(30);
 l_print_together       VARCHAR2(80);
 l_print_return         BOOLEAN;
 l_procedure         varchar2(50);
 request_error        varchar2(2000);
e_submit_error        exception;
err_num number;
err_msg varchar2(2000);
 l_xml_options          BOOLEAN;      /* Bug 6839263 */
  --------------------------------------------------------------------+
  -- Cursor      : csr_params
  -- Description : Fetches User Parameters from Legislative_paramters
  --               column.
  --------------------------------------------------------------------+

   CURSOR csr_report_params(c_payroll_action_id  pay_payroll_actions.payroll_action_id%TYPE)
      IS
    SELECT pay_core_utils.get_parameter('BG',legislative_parameters)    business_group_id,
                   pay_core_utils.get_parameter('LE',legislative_parameters) legal_employer,
                   to_date(pay_core_utils.get_parameter('PERIOD',legislative_parameters),'YYYY/MM/DD') period,
                   to_date(pay_core_utils.get_parameter('SDATE',legislative_parameters),'YYYY/MM/DD') start_date,
                   to_date(pay_core_utils.get_parameter('EDATE',legislative_parameters),'YYYY/MM/DD')   end_date,
                   pay_core_utils.get_parameter('TAX_STATE',legislative_parameters) Tax_state,
                   pay_core_utils.get_parameter('REP_TYPE',legislative_parameters)report_type,
                   pay_core_utils.get_parameter('REP_NAME',legislative_parameters)report_name,
                   pay_core_utils.get_parameter('ACTT',legislative_parameters)act_override_threshold,
                   pay_core_utils.get_parameter('VICT',legislative_parameters)vic_override_threshold,
                   pay_core_utils.get_parameter('NSWT',legislative_parameters)nsw_override_threshold,
                   pay_core_utils.get_parameter('QLDT',legislative_parameters)qld_override_threshold,
                   pay_core_utils.get_parameter('WAT',legislative_parameters)wa_override_threshold,
                   pay_core_utils.get_parameter('NTT',legislative_parameters)nt_override_threshold,
                   pay_core_utils.get_parameter('SAT',legislative_parameters)sa_override_threshold,
                   pay_core_utils.get_parameter('TAST',legislative_parameters)tas_override_threshold,
                   pay_core_utils.get_parameter('OUTPUT_TYPE',legislative_parameters) p_output_type
      FROM pay_payroll_actions ppa
      WHERE ppa.payroll_action_id  =  c_payroll_action_id;



 cursor csr_get_report_name(c_payroll_Action_id pay_payroll_actions.payroll_action_id%TYPE) is
 select  pay_core_utils.get_parameter('REP_NAME',legislative_parameters)
  from pay_payroll_actions ppa
  where ppa.payroll_Action_id = c_payroll_Action_id;

 cursor csr_get_print_options(p_payroll_action_id NUMBER) IS
 SELECT printer,
          print_style,
          decode(save_output_flag, 'Y', 'TRUE', 'N', 'FALSE') save_output
	  ,number_of_copies
    FROM  pay_payroll_actions pact,
          fnd_concurrent_requests fcr
    WHERE fcr.request_id = pact.request_id
    AND   pact.payroll_action_id = p_payroll_action_id;


 rec_print_options  csr_get_print_options%ROWTYPE;

 l_parameters csr_report_params%ROWTYPE; /* Bug 6839263 */

  Begin
    l_count           :=0;
    ps_request_id     :=-1;
    g_debug :=hr_utility.debug_enabled ;


             if g_debug then
	     g_package := 'pay_au_tax_rep_pkg.' ;
             l_procedure := g_package||' spawn_archive_reports';
             hr_utility.set_location('Entering '||l_procedure,999);
             end if;

-- Set User Parameters for Report.
open csr_get_report_name(p_payroll_action_id);
   fetch csr_get_report_name into l_report_name;
 close csr_get_report_name;

             open csr_report_params(p_payroll_action_id);
             fetch csr_report_params into l_parameters;
             close csr_report_params;

        /* Start 6839263 */
         IF  l_parameters.p_output_type = 'XML_PDF'
         THEN
                  l_short_report_name := 'PYAUPYL_XML';

                  l_xml_options      := fnd_request.add_layout
                                        (template_appl_name => 'PAY',
                                         template_code      => 'PYAUPYL_XML',
                                         template_language  => 'en',
                                         template_territory => 'US',
                                         output_format      => 'PDF');

         ELSE
                  l_short_report_name := 'PYAUPYL';
         END IF;
        /* End 6839263 */

 if g_debug then
        hr_utility.set_location('p_payroll_action_id.........= ' || p_payroll_action_id,30);
        hr_utility.set_location('g_parameters.business_group_id.........= ' || l_parameters.business_group_id,30);
        hr_utility.set_location('g_parameters.legal_employer.........= ' || l_parameters.legal_employer,30);
        hr_utility.set_location('g_parameters.start_date..............= ' || l_parameters.start_date,30);
        hr_utility.set_location('g_parameters.end_date................= ' || l_parameters.end_date,30);
        hr_utility.set_location('g_parameters.tax_state.........= ' || l_parameters.tax_state,30);
        hr_utility.set_location('g_parameters.report_type..........= '||l_parameters.report_type,30);
        hr_utility.set_location('g_parameters.act_threshold..........= '||l_parameters.act_override_threshold,30);
        hr_utility.set_location('g_parameters.vic_threshold..........= '||l_parameters.vic_override_threshold,30);
        hr_utility.set_location('g_parameters.qld_threshold..........= '||l_parameters.qld_override_threshold,30);
        hr_utility.set_location('g_parameters.nsw_threshold..........= '||l_parameters.nsw_override_threshold,30);
        hr_utility.set_location('g_parameters.tas_threshold..........= '||l_parameters.tas_override_threshold,30);
        hr_utility.set_location('g_parameters.wa_threshold..........= '||l_parameters.wa_override_threshold,30);
        hr_utility.set_location('g_parameters.sa_threshold..........= '||l_parameters.sa_override_threshold,30);
        hr_utility.set_location('g_parameters.nt_threshold..........= '||l_parameters.nt_override_threshold,30);
        hr_utility.set_location('Output Type                        = '||l_parameters.p_output_type,30);
  end if;


    OPEN csr_get_print_options(p_payroll_action_id);
       FETCH csr_get_print_options INTO rec_print_options;
       CLOSE csr_get_print_options;
       --
       l_print_together := nvl(fnd_profile.value('CONC_PRINT_TOGETHER'), 'N');
       --
       -- Set printer options
       l_print_return := fnd_request.set_print_options
                           (printer        => rec_print_options.printer,
                            style          => rec_print_options.print_style,
                            copies         => rec_print_options.number_of_copies,/* Bug 4116833*/
                            save_output    => hr_general.char_to_bool(rec_print_options.save_output),
                            print_together => l_print_together);
    -- Submit report
      if g_debug then
      hr_utility.set_location('payroll_action id    '|| p_payroll_action_id,25);
      end if;

ps_request_id := fnd_request.submit_request
 ('PAY',
  l_short_report_name,
   null,
   null,
   false,
   'P_PAYROLL_ACTION_ID=' || to_char(p_payroll_action_id),
   'P_BUSINESS_GROUP_ID='||to_char(l_parameters.business_group_id),
   'P_LEGAL_EMPLOYER='||to_char(l_parameters.legal_employer),
   'P_PERIOD='||to_char(l_parameters.period,'YYYY/MM/DD'),
   'P_START_DATE='||to_char(l_parameters.start_date,'YYYY/MM/DD'),
   'P_END_DATE='||to_char(l_parameters.end_date,'YYYY/MM/DD'),
   'P_TAX_STATE=' || l_parameters.tax_state,
   'P_ACT=' || l_parameters.act_override_threshold,
   'P_QLD=' || l_parameters.qld_override_threshold,
   'P_SA=' || l_parameters.sa_override_threshold,
   'P_TAS=' || l_parameters.tas_override_threshold,
   'P_VIC=' || l_parameters.vic_override_threshold,
   'P_WA=' || l_parameters.wa_override_threshold,
   'P_NSW=' || l_parameters.nsw_override_threshold,
   'P_NT='  || l_parameters.nt_override_threshold,
   'P_REPORT_TYPE='||l_parameters.report_type,
   'P_REPORT_NAME=' || l_report_name,
   'BLANKPAGES=NO',NULL,NULL,
   NULL,   NULL,   NULL,   NULL,   NULL,   NULL,
   NULL,   NULL,   NULL,   NULL,   NULL,   NULL,
   NULL,   NULL,   NULL,   NULL,   NULL,   NULL,
   NULL,   NULL,   NULL,   NULL,   NULL,   NULL,
   NULL,   NULL,   NULL,   NULL,   NULL,   NULL,
   NULL,   NULL,   NULL,   NULL,   NULL,   NULL,
   NULL,   NULL,   NULL,   NULL,   NULL,   NULL,
   NULL,   NULL,   NULL,   NULL,   NULL,   NULL,
   NULL,   NULL,   NULL,   NULL,   NULL,   NULL,
   NULL,   NULL,   NULL,   NULL,   NULL,   NULL,
   NULL,   NULL,   NULL,   NULL,   NULL,   NULL,
   NULL,   NULL,   NULL,   NULL,   NULL,   NULL,
   NULL,   NULL,   NULL,   NULL
);


request_error := fnd_message.get;

      if g_debug then
      hr_utility.set_location('ps_request ' || ps_request_id, 35);

      hr_utility.set_location('After calling report',24);

      end if;
exception
when others then
  err_num := SQLCODE;
 err_msg := substr(sqlerrm,1,100);

hr_utility.set_location('erro_msg ' || err_msg, 200);

end spawn_archive_reports;




end pay_au_paytax_pkg;

/
