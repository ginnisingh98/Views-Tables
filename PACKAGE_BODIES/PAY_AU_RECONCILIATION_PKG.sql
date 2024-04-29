--------------------------------------------------------
--  DDL for Package Body PAY_AU_RECONCILIATION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_AU_RECONCILIATION_PKG" as
/* $Header: pyaurecs.pkb 120.7.12010000.5 2009/12/22 07:14:01 dduvvuri ship $ */

g_debug boolean;
g_package  varchar2(26);

/* Bug 4036052
   Initalize variables for Archive model -- Start */

  g_arc_payroll_action_id           pay_payroll_actions.payroll_action_id%type;
  g_business_group_id		    hr_all_organization_units.organization_id%type;
  g_prev_assignment_id              number;
  g_def_bal_populted                varchar2(1);

  g_end_date                        date;
  g_start_date                        date;   --Bug#3662449

/*
    Bug 9113084 - Added Function range_person_on
--------------------------------------------------------------------
    Name  : range_person_on
    Type  : Function
    Access: Private
    Description: Checks if RANGE_PERSON_ID is enabled for
                 Archive process.
  --------------------------------------------------------------------
*/

FUNCTION range_person_on
RETURN BOOLEAN
IS

 CURSOR csr_action_parameter is
  select parameter_value
  from pay_action_parameters
  where parameter_name = 'RANGE_PERSON_ID';

 CURSOR csr_range_format_param is
  select par.parameter_value
  from   pay_report_format_parameters par,
         pay_report_format_mappings_f map
  where  map.report_format_mapping_id = par.report_format_mapping_id
  and    map.report_type = 'AU_REC_SUMM_ARCHIVE'
  and    map.report_format = 'AU_REC_SUMM_ARCHIVE'
  and    map.report_qualifier = 'AU'
  and    par.parameter_name = 'RANGE_PERSON_ID';

  l_return boolean;
  l_action_param_val varchar2(30);
  l_report_param_val varchar2(30);

BEGIN

    g_debug := hr_utility.debug_enabled;

  BEGIN

    open csr_action_parameter;
    fetch csr_action_parameter into l_action_param_val;
    close csr_action_parameter;

    open csr_range_format_param;
    fetch csr_range_format_param into l_report_param_val;
    close csr_range_format_param;

  EXCEPTION WHEN NO_DATA_FOUND THEN
     l_return := FALSE;
  END;
  --
  IF l_action_param_val = 'Y' AND l_report_param_val = 'Y' THEN
     l_return := TRUE;
     IF g_debug THEN
        hr_utility.set_location('Range Person = True',1);
     END IF;
  ELSE
     l_return := FALSE;
  END IF;
--
 RETURN l_return;
--
END range_person_on;

  /* Procedure to pass all the balance results back in one call from report */

procedure get_au_rec_balances
  (p_assignment_action_id      	in pay_assignment_actions.assignment_action_id%type,
   p_registered_employer        in NUMBER, --2610141
   p_gross_earnings             out NOCOPY number,  /*Bug 3953706*/
   p_non_taxable_earnings       out NOCOPY number,
   p_pre_tax_deductions         out NOCOPY number, /*Bug 3953706*/
   p_taxable_earnings           out NOCOPY number,
   p_tax    			out NOCOPY number,
   p_deductions			out NOCOPY number,
   p_direct_payments            out NOCOPY number, /*Bug 3953706*/
   p_net_payment        	out NOCOPY number,
   p_employer_charges 		out NOCOPY number)
is

/* start bug8682256 */
cursor get_aud_precision is
select nvl(precision,0) from fnd_currencies where currency_code = 'AUD' and enabled_flag = 'Y';

l_aud_precision number;
/* end bug8682256 */

begin

   IF g_debug THEN
      hr_utility.trace('Entering:' || g_package  || 'get_au_rec_balances');
      hr_utility.trace('Assignment action id value ===>' || p_assignment_action_id);
   END IF;

    /* Call to this function below implements Batch Balance Retrieval for better performance */

/*Changes made for bug 2610141 Start here*/
     g_context_table(1).tax_unit_id := p_registered_employer;

     pay_balance_pkg.get_value(p_assignment_action_id => p_assignment_action_id,
                               p_defined_balance_lst=>g_balance_value_tab,
                               p_context_lst =>g_context_table,
                               p_output_table=>g_result_table);

/*Changes made for bug 2610141 Ends here*/

/*   pay_balance_pkg.get_value ( p_assignment_action_id => p_assignment_action_id
                             , p_defined_balance_lst  => g_balance_value_tab );*/

   IF g_debug THEN
      hr_utility.trace('Balance values for RUN dimension');
      hr_utility.trace('-------------------------------------');
      hr_utility.trace('Earnings_Total        ===>' || g_result_table(1).balance_value);
      hr_utility.trace('Direct Payments       ===>' || g_result_table(2).balance_value);
      hr_utility.trace('Termination_Payments  ===>' || g_result_table(3).balance_value);
      hr_utility.trace('Involuntary Deductions===>' || g_result_table(4).balance_value);
      hr_utility.trace('Pre Tax Deductions    ===>' || g_result_table(5).balance_value);
      hr_utility.trace('Termination Deductions===>' || g_result_table(6).balance_value);
      hr_utility.trace('Voluntary Deductions  ===>' || g_result_table(7).balance_value);
      hr_utility.trace('Total_Tax_Deduction   ===>' || g_result_table(8).balance_value);
      hr_utility.trace('Earnings_Non_Taxable  ===>' || g_result_table(9).balance_value);
      hr_utility.trace('Employer_Charges      ===>' || g_result_table(10).balance_value);
   END IF;

   /* Bug 3953706 - Modified calculation of Earnings and deductions as given below:
      Calculations :-
      ===============
      Gross Earnings       = Earnings Total + Termination Payments + Pre Tax Deductions
      Taxable_earnings     = Gross Earnings - Pre_tax_deductions - Earnings_non_taxable
      Non_taxable_earnings = Earnings_non_taxable
      Post Tax Deductions  = Involuntary_deductions + Voluntary_deductions
      Tax Deductions       = Tax_deductions + Termination_deductions
      Net_payment          = Taxable_earnings + Non_taxable_earnings - Tax - Deductions + Direct_Payments
      Direct Payments      = Direct_Payments
      Employer_charges     = Employer_charges
      Pre Tax Deductions   = Pre_tax_deductions */



   p_gross_earnings       := g_result_table(1).balance_value + g_result_table(3).balance_value + g_result_table(5).balance_value;
   p_non_taxable_earnings := g_result_table(9).balance_value;
   p_pre_tax_deductions    := g_result_table(5).balance_value;
   p_taxable_earnings     := p_gross_earnings - p_pre_tax_deductions - p_non_taxable_earnings;
   p_tax                  := g_result_table(8).balance_value + g_result_table(6).balance_value;
   p_deductions           := g_result_table(4).balance_value + g_result_table(7).balance_value;
   p_direct_payments      := g_result_table(2).balance_value;
   p_net_payment          := p_taxable_earnings + p_non_taxable_earnings - p_tax - p_deductions + p_direct_payments;
   p_employer_charges     := g_result_table(10).balance_value;

/* start bug8682256 */
   open get_aud_precision;
   fetch get_aud_precision into l_aud_precision;
   close get_aud_precision;

   IF l_aud_precision > 2 THEN
      p_gross_earnings := round(p_gross_earnings,2);
      p_non_taxable_earnings := round(p_non_taxable_earnings,2);
      p_pre_tax_deductions := round(p_pre_tax_deductions,2);
      p_taxable_earnings := round(p_taxable_earnings,2);
      p_tax := round(p_tax,2);
      p_deductions := round(p_deductions,2);
      p_direct_payments := round(p_direct_payments,2);
      p_net_payment := round(p_net_payment,2);
      p_employer_charges := round(p_employer_charges,2);
   END IF;
/* end bug8682256 */

   IF g_debug THEN
      hr_utility.trace('p_taxable_earnings     ===>' || p_taxable_earnings);
      hr_utility.trace('p_non_taxable_earnings ===>' || p_non_taxable_earnings);
      hr_utility.trace('p_deductions           ===>' || p_deductions);
      hr_utility.trace('p_tax                  ===>' || p_tax);
      hr_utility.trace('p_net_payment          ===>' || p_net_payment);
      hr_utility.trace('p_employer_charges     ===>' || p_employer_charges);
      hr_utility.trace('p_gross_earnings     ===>' || p_gross_earnings);
      hr_utility.trace('p_pre_tax_deduction     ===>' || p_pre_tax_deductions);
      hr_utility.trace('p_direct_payments     ===>' || p_direct_payments);
   END IF;


end get_au_rec_balances;


  /* Procedure to pass all the YTD balance results back in one call from report */

procedure get_ytd_au_rec_balances
  (p_assignment_action_id      	in pay_assignment_actions.assignment_action_id%type,
   p_registered_employer        in NUMBER, --2610141
   p_ytd_gross_earnings         out NOCOPY number,   /*Bug 3953706*/
   p_ytd_non_taxable_earnings   out NOCOPY number,
   p_ytd_pre_tax_deductions     out NOCOPY number,   /*Bug 3953706*/
   p_ytd_taxable_earnings       out NOCOPY number,
   p_ytd_tax    		out NOCOPY number,
   p_ytd_deductions		out NOCOPY number,
   p_ytd_direct_payments        out NOCOPY number,   /*Bug 3953706*/
   p_ytd_net_payment        	out NOCOPY number,
   p_ytd_employer_charges 	out NOCOPY number)
is

/* start bug8682256 */
cursor get_aud_precision is
select nvl(precision,0) from fnd_currencies where currency_code = 'AUD' and enabled_flag = 'Y';

l_aud_precision number;
/* end bug8682256 */

begin

   IF g_debug THEN
      hr_utility.trace('Entering:' || g_package  || 'get_ytd_au_rec_balances');
      hr_utility.trace('Assignment action id value ===>' || p_assignment_action_id);
   END IF;

   /* Call to this function below implements Batch Balance Retrieval for better performance */

/*Changes made for bug 2610141 Start here*/
     g_context_table(1).tax_unit_id := p_registered_employer;

     pay_balance_pkg.get_value(p_assignment_action_id => p_assignment_action_id,
                               p_defined_balance_lst=>g_ytd_balance_value_tab, /*Bug 4040688*/
                               p_context_lst =>g_context_table,
                               p_output_table=>g_result_table);

/*Changes made for bug 2610141 Ends here*/

/*   pay_balance_pkg.get_value ( p_assignment_action_id => p_assignment_action_id
                             , p_defined_balance_lst  => g_balance_value_tab );*/

    IF g_debug THEN
      hr_utility.trace('Balance values for YTD dimension');
      hr_utility.trace('-------------------------------------');
      hr_utility.trace('Earnings_Total        ===>' || g_result_table(1).balance_value);
      hr_utility.trace('Direct Payments       ===>' || g_result_table(2).balance_value);
      hr_utility.trace('Termination_Payments  ===>' || g_result_table(3).balance_value);
      hr_utility.trace('Involuntary Deductions===>' || g_result_table(4).balance_value);
      hr_utility.trace('Pre Tax Deductions    ===>' || g_result_table(5).balance_value);
      hr_utility.trace('Termination Deductions===>' || g_result_table(6).balance_value);
      hr_utility.trace('Voluntary Deductions  ===>' || g_result_table(7).balance_value);
      hr_utility.trace('Total_Tax_Deduction   ===>' || g_result_table(8).balance_value);
      hr_utility.trace('Earnings_Non_Taxable  ===>' || g_result_table(9).balance_value);
      hr_utility.trace('Employer_Charges      ===>' || g_result_table(10).balance_value);
   END IF;

   /* Bug 3953706 - Modified calculation of Earnings and deductions as given below:
      Calculations :-
      ===============
      Gross Earnings       = Earnings Total + Termination Payments + Pre Tax Deductions
      Taxable_earnings     = Gross Earnings - Pre_tax_deductions - Earnings_non_taxable
      Non_taxable_earnings = Earnings_non_taxable
      Post Tax Deductions  = Involuntary_deductions + Voluntary_deductions
      Tax Deductions       = Tax_deductions + Termination_deductions
      Net_payment          = Taxable_earnings + Non_taxable_earnings - Tax - Deductions + Direct_Payments
      Direct Payments      = Direct_Payments
      Employer_charges     = Employer_charges
      Pre Tax Deductions   = Pre_tax_deductions */

   p_ytd_gross_earnings       := g_result_table(1).balance_value + g_result_table(3).balance_value + g_result_table(5).balance_value;
   p_ytd_non_taxable_earnings := g_result_table(9).balance_value;
   p_ytd_pre_tax_deductions    := g_result_table(5).balance_value;
   p_ytd_taxable_earnings     := p_ytd_gross_earnings - p_ytd_pre_tax_deductions - p_ytd_non_taxable_earnings;
   p_ytd_tax                  := g_result_table(8).balance_value + g_result_table(6).balance_value;
   p_ytd_deductions           := g_result_table(4).balance_value + g_result_table(7).balance_value;
   p_ytd_direct_payments      := g_result_table(2).balance_value;
   p_ytd_net_payment          := p_ytd_taxable_earnings + p_ytd_non_taxable_earnings - p_ytd_tax - p_ytd_deductions + p_ytd_direct_payments;
   p_ytd_employer_charges     := g_result_table(10).balance_value;

/* start bug8682256 */
   open get_aud_precision;
   fetch get_aud_precision into l_aud_precision;
   close get_aud_precision;

   IF l_aud_precision > 2 THEN
      p_ytd_gross_earnings := round(p_ytd_gross_earnings,2);
      p_ytd_non_taxable_earnings := round(p_ytd_non_taxable_earnings,2);
      p_ytd_pre_tax_deductions := round(p_ytd_pre_tax_deductions,2);
      p_ytd_taxable_earnings := round(p_ytd_taxable_earnings,2);
      p_ytd_tax := round(p_ytd_tax,2);
      p_ytd_deductions := round(p_ytd_deductions,2);
      p_ytd_direct_payments := round(p_ytd_direct_payments,2);
      p_ytd_net_payment := round(p_ytd_net_payment,2);
      p_ytd_employer_charges := round(p_ytd_employer_charges,2);
   END IF;
/* end bug8682256 */

   IF g_debug THEN
      hr_utility.trace('p_ytd_taxable_earnings     ===>' || p_ytd_taxable_earnings);
      hr_utility.trace('p_ytd_non_taxable_earnings ===>' || p_ytd_non_taxable_earnings);
      hr_utility.trace('p_ytd_deductions           ===>' || p_ytd_deductions);
      hr_utility.trace('p_ytd_tax                  ===>' || p_ytd_tax);
      hr_utility.trace('p_ytd_net_payment          ===>' || p_ytd_net_payment);
      hr_utility.trace('p_ytd_employer_charges     ===>' || p_ytd_employer_charges);
      hr_utility.trace('p_ytd_gross_earnings     ===>' || p_ytd_gross_earnings);
      hr_utility.trace('p_ytd_pre_tax_deduction     ===>' || p_ytd_pre_tax_deductions);
      hr_utility.trace('p_ytd_direct_payments     ===>' || p_ytd_direct_payments);
   END IF;

end get_ytd_au_rec_balances;


PROCEDURE populate_defined_balance_ids
          (p_ytd_totals varchar2,
	   p_registered_employer NUMBER)   IS --2610141

CURSOR   csr_defined_balance_id
          (c_database_item_suffix  pay_balance_dimensions.database_item_suffix%type)
IS
SELECT   decode(pbt.balance_name,'Earnings_Total',1,'Direct Payments',2,'Termination_Payments',3,
                'Involuntary Deductions',4,'Pre Tax Deductions',5,'Termination Deductions',6,
                'Voluntary Deductions',7,'Total_Tax_Deductions',8,'Earnings_Non_Taxable',9,
                'Employer_Charges',10) sort_index,
         pdb.defined_balance_id defined_balance_id
  FROM   pay_balance_types pbt,
         pay_balance_dimensions pbd,
         pay_defined_balances pdb
 WHERE   pbt.balance_name         IN ('Earnings_Total','Direct Payments','Termination_Payments','Involuntary Deductions',
                                      'Pre Tax Deductions','Termination Deductions','Voluntary Deductions','Total_Tax_Deductions',
                                      'Earnings_Non_Taxable','Employer_Charges')
   AND   pbd.database_item_suffix = c_database_item_suffix
   AND   pbt.balance_type_id      = pdb.balance_type_id
   AND   pbd.balance_dimension_id = pdb.balance_dimension_id
   AND   pbt.legislation_code     = 'AU'
ORDER BY sort_index;

i NUMBER := 0;
l_run_dimension_name VARCHAR2(15);--2610141
l_ytd_dimension_name VARCHAR2(15);--2610141

BEGIN

   IF g_debug THEN
      hr_utility.trace('Entering:' || g_package  || 'populate_defined_balance_ids');
      hr_utility.trace('Parameter p_ytd_totals value ===>' || p_ytd_totals);
   END IF;

   g_balance_value_tab.delete;

/*Bug 2610141 - Code added to pick up the right dimension on the basis of input parameters for the report*/
   IF p_registered_employer IS NULL THEN
	l_run_dimension_name := '_ASG_RUN';
	l_ytd_dimension_name := '_ASG_YTD';
   ELSE
        l_run_dimension_name := '_ASG_LE_RUN';
	l_ytd_dimension_name := '_ASG_LE_YTD';
   END IF;

  /* The Balance's defined balance id are stored in the following order
     -----------------------------------------------------
        Storage Location of
       Run Defined Balance Id      Balance Name
     -----------------------------------------------------
            1                   Earnings_Total
            2                   Direct Payments
            3                   Termination_Payments
            4                   Involuntary Deductions
            5                   Pre Tax Deductions
            6                   Termination Deductions
            7                   Voluntary Deductions
            8                   Total_Tax_Deduction
            9                   Earnings_Non_Taxable
            10                  Employer_Charges
     -----------------------------------------------------
     If required, YTD defined balance ids are stored for all the balances in the same order as mentioned above
     from location 10 to 19 */

   FOR csr_rec IN csr_defined_balance_id(l_run_dimension_name)
      LOOP
         g_balance_value_tab(csr_rec.sort_index).defined_balance_id := csr_rec.defined_balance_id;
      END LOOP;

   IF g_debug THEN
      hr_utility.trace('Defined Balance ids for RUN dimension');
      hr_utility.trace('-------------------------------------');
      hr_utility.trace('Earnings_Total        ===>' || g_balance_value_tab(1).defined_balance_id);
      hr_utility.trace('Direct Payments       ===>' || g_balance_value_tab(2).defined_balance_id);
      hr_utility.trace('Termination_Payments  ===>' || g_balance_value_tab(3).defined_balance_id);
      hr_utility.trace('Involuntary Deductions===>' || g_balance_value_tab(4).defined_balance_id);
      hr_utility.trace('Pre Tax Deductions    ===>' || g_balance_value_tab(5).defined_balance_id);
      hr_utility.trace('Termination Deductions===>' || g_balance_value_tab(6).defined_balance_id);
      hr_utility.trace('Voluntary Deductions  ===>' || g_balance_value_tab(7).defined_balance_id);
      hr_utility.trace('Total_Tax_Deduction   ===>' || g_balance_value_tab(8).defined_balance_id);
      hr_utility.trace('Earnings_Non_Taxable  ===>' || g_balance_value_tab(9).defined_balance_id);
      hr_utility.trace('Employer_Charges      ===>' || g_balance_value_tab(10).defined_balance_id);
   END IF;

   IF (p_ytd_totals = 'Y') THEN

      FOR csr_rec IN csr_defined_balance_id(l_ytd_dimension_name)
         LOOP
            g_ytd_balance_value_tab(csr_rec.sort_index).defined_balance_id := csr_rec.defined_balance_id; /*Bug 4040688*/
         END LOOP;

      IF g_debug THEN
         hr_utility.trace('Defined Balance ids for YTD dimension');
         hr_utility.trace('-------------------------------------');
         hr_utility.trace('Earnings_Total        ===>' || g_ytd_balance_value_tab(1).defined_balance_id);
         hr_utility.trace('Direct Payments       ===>' || g_ytd_balance_value_tab(2).defined_balance_id);
         hr_utility.trace('Termination_Payments  ===>' || g_ytd_balance_value_tab(3).defined_balance_id);
         hr_utility.trace('Involuntary Deductions===>' || g_ytd_balance_value_tab(4).defined_balance_id);
         hr_utility.trace('Pre Tax Deductions    ===>' || g_ytd_balance_value_tab(5).defined_balance_id);
         hr_utility.trace('Termination Deductions===>' || g_ytd_balance_value_tab(6).defined_balance_id);
         hr_utility.trace('Voluntary Deductionsn ===>' || g_ytd_balance_value_tab(7).defined_balance_id);
         hr_utility.trace('Total_Tax_Deduction   ===>' || g_ytd_balance_value_tab(8).defined_balance_id);
         hr_utility.trace('Earnings_Non_Taxable  ===>' || g_ytd_balance_value_tab(9).defined_balance_id);
         hr_utility.trace('Employer_Charges      ===>' || g_ytd_balance_value_tab(10).defined_balance_id);
      END IF;

   END IF;

END;

/* Bug 4036052
* Implemented the Horizontal Archive for Payroll Rec- Summary Report
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

    if g_debug then
     l_procedure := g_package||'range_code';
     hr_utility.set_location('Entering '||l_procedure,1);
    end if ;

    -- Archive the payroll action level data  and EIT defintions.
    --  sql string to SELECT a range of assignments eligible for archival.
    p_sql := ' select distinct p.person_id'                             ||
             ' from   per_people_f p,'                                  ||
                    ' pay_payroll_actions pa'                           ||
             ' where  pa.payroll_action_id = :payroll_action_id'        ||
             ' and    p.business_group_id = pa.business_group_id'       ||
             ' order by p.person_id';

    if g_debug then
      hr_utility.set_location('Leaving '||l_procedure,1000);
    end if;

  end range_code;

procedure initialization_code
  (p_payroll_action_id  in pay_payroll_actions.payroll_action_id%type)
  is
    l_procedure               varchar2(200) ;

/*Bug 4132149 - Modification begins here */
  --------------------------------------------------------------------+
  -- Cursor      : csr_params
  -- Description : Fetches User Parameters from Legislative_paramters
  --               column.
  --------------------------------------------------------------------+

   CURSOR csr_params(c_payroll_action_id  pay_payroll_actions.payroll_action_id%TYPE)
      IS
        SELECT pay_core_utils.get_parameter('PAY',legislative_parameters)        payroll_id,
                   pay_core_utils.get_parameter('ORG',legislative_parameters)           org_id,
                   pay_core_utils.get_parameter('BG',legislative_parameters)    business_group_id,
                   to_date(pay_core_utils.get_parameter('SDATE',legislative_parameters),'YYYY/MM/DD') start_date,
                   to_date(pay_core_utils.get_parameter('EDATE',legislative_parameters),'YYYY/MM/DD')   end_date,
                   pay_core_utils.get_parameter('PACTID',legislative_parameters)        pact_id,
                   pay_core_utils.get_parameter('LE',legislative_parameters) legal_employer,
                   pay_core_utils.get_parameter('ASG',legislative_parameters) assignment_id,
                   pay_core_utils.get_parameter('SO1',legislative_parameters)   sort_order_1,
                   pay_core_utils.get_parameter('SO2',legislative_parameters)   sort_order_2,
                   pay_core_utils.get_parameter('SO3',legislative_parameters)   sort_order_3,
                   pay_core_utils.get_parameter('SO4',legislative_parameters)   sort_order_4,
                   to_date(pay_core_utils.get_parameter('PEDATE',legislative_parameters),'YYYY/MM/DD') period_end_date,
                   pay_core_utils.get_parameter('YTD_TOT',legislative_parameters)      ytd_totals,
                   pay_core_utils.get_parameter('ZERO_REC',legislative_parameters)    zero_records,
                   pay_core_utils.get_parameter('NEG_REC',legislative_parameters)     negative_records,
                   decode(pay_core_utils.get_parameter('EMP_TYPE',legislative_parameters),'C','Y','T','N','%') employee_type,
                   pay_core_utils.get_parameter('DEL_ACT',legislative_parameters)     delete_actions /*Bug# 4142159*/
                   FROM pay_payroll_actions ppa
      WHERE ppa.payroll_action_id  =  c_payroll_action_id;

 --------------------------------------------------------------------+
  -- Cursor      : csr_period_date_earned
  -- Description : Fetches Date Earned for a given payroll
  --               run.
  --------------------------------------------------------------------+
      CURSOR csr_period_date_earned(c_payroll_action_id  pay_payroll_actions.payroll_action_id%TYPE)
      IS
        SELECT ppa.date_earned
	FROM pay_payroll_actions ppa
        WHERE
	ppa.payroll_action_id = c_payroll_action_id;

/*Bug 4132149 - Modification ends here */

  begin

    g_debug :=hr_utility.debug_enabled ;
    if g_debug then
        g_package := 'pay_au_reconciliation_pkg.' ;
        l_procedure := g_package||'initialization_code';
        hr_utility.set_location('Entering '||l_procedure,1);
    end if;

/*Bug 4132149 - Modification begins here */

    -- initialization_code to to set the global tables for EIT
        -- that will be used by each thread in multi-threading.

    g_arc_payroll_action_id := p_payroll_action_id;

    -- Fetch the parameters by user passed into global variable.

        OPEN csr_params(p_payroll_action_id);
     	FETCH csr_params into g_parameters;
       	CLOSE csr_params;


    if g_debug then
        hr_utility.set_location('p_payroll_action_id.........= ' || p_payroll_action_id,30);
        hr_utility.set_location('g_parameters.business_group_id.........= ' || g_parameters.business_group_id,30);
        hr_utility.set_location('g_parameters.payroll_id..............= ' || g_parameters.payroll_id,30);
        hr_utility.set_location('g_parameters.org_id................= ' || g_parameters.org_id,30);
        hr_utility.set_location('g_parameters.legal_employer.........= ' || g_parameters.legal_employer,30);
        hr_utility.set_location('g_parameters.start_date..............= ' || g_parameters.start_date,30);
        hr_utility.set_location('g_parameters.end_date................= ' || g_parameters.end_date,30);
        hr_utility.set_location('g_parameters.period_end_date.........= ' || g_parameters.period_end_date,30);
        hr_utility.set_location('g_parameters.pact_id..............= ' || g_parameters.pact_id,30);
        hr_utility.set_location('g_parameters.employee_type..........= '||g_parameters.employee_type,30);
        hr_utility.set_location('g_parameters.sort_order1..........= '||g_parameters.sort_order_1,30);
        hr_utility.set_location('g_parameters.sort_order2..........= '||g_parameters.sort_order_2,30);
        hr_utility.set_location('g_parameters.sort_order3..........= '||g_parameters.sort_order_3,30);
        hr_utility.set_location('g_parameters.sort_order4..........= '||g_parameters.sort_order_4,30);
	hr_utility.set_location('g_parameters.delete_actions..........= '||g_parameters.delete_actions,30);/*Bug# 4142159*/
    end if;


    g_business_group_id := g_parameters.business_group_id ;

    -- Set end date variable .This value is used to fetch latest assignment details of
    -- employee for archival.In case of archive start date/end date - archive end date
    -- taken and pact_id/period_end_date , period end date is picked.

    if g_parameters.end_date is not null
    then
        g_end_date := g_parameters.end_date;
	g_start_date := g_parameters.start_date; --Bug#3662449
    else
        if g_parameters.period_end_date is not null
        then
	    open csr_period_date_earned(g_parameters.pact_id); --Bug#3662449
	    fetch csr_period_date_earned into g_start_date;
            close csr_period_date_earned;
            g_end_date  := g_parameters.period_end_date;
        else
	    g_start_date := to_date('1900/01/01','YYYY/MM/DD');  --Bug#3662449
            g_end_date  := to_date('4712/12/31','YYYY/MM/DD');
        end if;
    end if; /* End of outer if loop */

/*Bug 4132149 - Modification ends here */

    pay_au_reconciliation_pkg.populate_defined_balance_ids('Y',g_parameters.legal_employer);
    if g_debug then
            hr_utility.set_location('Leaving '||l_procedure,1000);
    end if;

  exception
    when others then
      hr_utility.set_location('Error in '||l_procedure,999999);
      raise;
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

  --------------------------------------------------------------------+
  -- Cursor      : csr_assignment_org_period
  -- Description : Fetches assignments when Organization,Archive
  --               Start Date and End Date is specified
  --------------------------------------------------------------------+

  cursor csr_assignment_org_period
      (c_payroll_action_id  pay_payroll_actions.payroll_action_id%type
      ,c_start_person       per_all_people_f.person_id%type
      ,c_end_person         per_all_people_f.person_id%type
      ,c_employee_type      per_all_people_f.current_employee_flag%type
      ,c_business_group_id  hr_all_organization_units.organization_id%type
      ,c_organization_id    hr_all_organization_units.organization_id%type
      ,c_archive_start_date         date
      ,c_archive_end_date           date
       ) is
      select 	paa.assignment_action_id,
                paa.action_sequence,
      	   	paaf.assignment_id,
      	   	paa.tax_unit_id
       	from  	per_people_f pap,
  		per_assignments_f paaf,
  		pay_payroll_actions ppa,
  		pay_payroll_actions ppa1,
  		pay_assignment_actions paa,
  		hr_organization_units hou,
  		per_periods_of_service pps
  	where   ppa.payroll_action_id        = c_payroll_action_id
  	and     paa.assignment_id            = paaf.assignment_id
  	and     pap.person_id                between c_start_person and c_end_person
  	and     pap.person_id                = paaf.person_id
  	and     pap.person_id                = pps.person_id
  	and     pps.period_of_service_id     = paaf.period_of_service_id
  	and     ppa1.date_earned between pap.effective_start_date  and pap.effective_end_date
  	and    ppa1.payroll_action_id       = paa.payroll_action_id
	AND    paa.action_status ='C' /*Bug 4099317*/
  	and    ppa1.business_group_id       = ppa.business_group_id
  	and    ppa.business_group_id        = c_business_group_id
  	and    ppa1.action_type             in ('R','Q','I','B','V')
	and    paa.source_action_id is null
  	and    paaf.organization_id         = hou.organization_id
  	and    hou.business_group_id        = c_business_group_id
  	and    hou.organization_id          = c_organization_id
  	and    ppa1.effective_date   between c_archive_start_date and c_archive_end_date
       and   decode(pps.actual_termination_date,null,'Y',decode(sign(pps.actual_termination_date - (c_archive_end_date)),1,'Y','N')) LIKE c_employee_type  --Bug 4161540
        and   paaf.effective_end_date = (select max(effective_end_date) --Bug# 3538810
					From  per_assignments_f iipaf
					WHERE iipaf.assignment_id  = paaf.assignment_id
					and iipaf.effective_end_date >= c_archive_start_date
					and iipaf.effective_start_date <= c_archive_end_date)
  	order  by paaf.assignment_id, paa.assignment_action_id, paa.tax_unit_id;

  --------------------------------------------------------------------+
  -- Bug         : 9113084
  -- Cursor      : rg_csr_assignment_org_period
  -- Description : Fetches assignments when Organization,Archive
  --               Start Date and End Date is specified
  -- Usage       : When Range Person is enabled
  --------------------------------------------------------------------+
    cursor rg_csr_assignment_org_period
      (c_payroll_action_id  pay_payroll_actions.payroll_action_id%type
      ,c_chunk NUMBER
      ,c_employee_type      per_all_people_f.current_employee_flag%type
      ,c_business_group_id  hr_all_organization_units.organization_id%type
      ,c_organization_id    hr_all_organization_units.organization_id%type
      ,c_archive_start_date         date
      ,c_archive_end_date           date
       ) is
      select 	paa.assignment_action_id,
                paa.action_sequence,
      	   	paaf.assignment_id,
      	   	paa.tax_unit_id
       	from  	per_people_f pap,
  		per_assignments_f paaf,
  		pay_payroll_actions ppa,
  		pay_payroll_actions ppa1,
  		pay_assignment_actions paa,
  		hr_organization_units hou,
  		per_periods_of_service pps,
		pay_population_ranges ppr
  	where   ppa.payroll_action_id        = c_payroll_action_id
	and     ppr.payroll_action_id       = ppa.payroll_action_id
	and     ppr.chunk_number = c_chunk
  	and     paa.assignment_id            = paaf.assignment_id
  	and     pap.person_id                = ppr.person_id
  	and     pap.person_id                = paaf.person_id
  	and     pap.person_id                = pps.person_id
  	and     pps.period_of_service_id     = paaf.period_of_service_id
  	and     ppa1.date_earned between pap.effective_start_date  and pap.effective_end_date
  	and    ppa1.payroll_action_id       = paa.payroll_action_id
	AND    paa.action_status ='C'
  	and    ppa1.business_group_id       = ppa.business_group_id
  	and    ppa.business_group_id        = c_business_group_id
  	and    ppa1.action_type             in ('R','Q','I','B','V')
	and    paa.source_action_id is null
  	and    paaf.organization_id         = hou.organization_id
  	and    hou.business_group_id        = c_business_group_id
  	and    hou.organization_id          = c_organization_id
  	and    ppa1.effective_date   between c_archive_start_date and c_archive_end_date
       and   decode(pps.actual_termination_date,null,'Y',decode(sign(pps.actual_termination_date - (c_archive_end_date)),1,'Y','N')) LIKE c_employee_type  --Bug 4161540
        and   paaf.effective_end_date = (select max(effective_end_date)
					From  per_assignments_f iipaf
					WHERE iipaf.assignment_id  = paaf.assignment_id
					and iipaf.effective_end_date >= c_archive_start_date
					and iipaf.effective_start_date <= c_archive_end_date)
  	order  by paaf.assignment_id, paa.assignment_action_id, paa.tax_unit_id;

  --------------------------------------------------------------------+
  -- Cursor      : csr_assignment_org_run
  -- Description : Fetches assignments when Organization,Payroll Run
  --               and Period End Date is specified
  --------------------------------------------------------------------+

  cursor csr_assignment_org_run
      (c_payroll_action_id  pay_payroll_actions.payroll_action_id%type
      ,c_start_person       per_all_people_f.person_id%type
      ,c_end_person         per_all_people_f.person_id%type
      ,c_employee_type      per_all_people_f.current_employee_flag%type
      ,c_business_group_id  hr_all_organization_units.organization_id%type
      ,c_organization_id    hr_all_organization_units.organization_id%type
      ,c_period_end_date            date
      ,c_pact_id            pay_payroll_actions.payroll_action_id%type
      ) is
      select 	paa.assignment_action_id,
                paa.action_sequence,
          	   	paaf.assignment_id,
          	   	paa.tax_unit_id
           	from  	per_people_f pap,
      		per_assignments_f paaf,
      		pay_payroll_actions ppa,
      		pay_payroll_actions ppa1,
      		pay_assignment_actions paa,
      		hr_organization_units hou,
      		per_periods_of_service pps
      	where   ppa.payroll_action_id        = c_payroll_action_id
      	and     paa.assignment_id            = paaf.assignment_id
      	and     pap.person_id                between c_start_person and c_end_person
      	and     pap.person_id                = paaf.person_id
      	and     pap.person_id                = pps.person_id
      	and     pps.period_of_service_id     = paaf.period_of_service_id
  	and     ppa1.date_earned between paaf.effective_start_date and paaf.effective_end_date
  	and     ppa1.date_earned between pap.effective_start_date  and pap.effective_end_date
      	and    ppa1.payroll_action_id       = paa.payroll_action_id
	AND    paa.action_status ='C' /*Bug 4099317*/
      	and    ppa1.business_group_id       = ppa.business_group_id
      	and    ppa.business_group_id        = c_business_group_id
      	and    ppa1.action_type             in ('R','Q','I','B','V')
	and    paa.source_action_id is null
      	and    paaf.organization_id         = hou.organization_id
  	and    hou.business_group_id        = c_business_group_id
      	and    NVL(pap.current_employee_flag,'N') like c_employee_type
      	and    hou.organization_id          = c_organization_id
      	and    ppa1.payroll_action_id       = c_pact_id
      	order  by paaf.assignment_id, paa.assignment_action_id, paa.tax_unit_id;

  --------------------------------------------------------------------+
  -- Bug         : 9113084
  -- Cursor      : rg_csr_assignment_org_run
  -- Description : Fetches assignments when Organization,Payroll Run
  --               and Period End Date is specified
  -- Usage       : When Range Person is enabled
  --------------------------------------------------------------------+
  cursor rg_csr_assignment_org_run
      (c_payroll_action_id  pay_payroll_actions.payroll_action_id%type
      ,c_chunk NUMBER
      ,c_employee_type      per_all_people_f.current_employee_flag%type
      ,c_business_group_id  hr_all_organization_units.organization_id%type
      ,c_organization_id    hr_all_organization_units.organization_id%type
      ,c_period_end_date            date
      ,c_pact_id            pay_payroll_actions.payroll_action_id%type
      ) is
      select 	paa.assignment_action_id,
                paa.action_sequence,
          	   	paaf.assignment_id,
          	   	paa.tax_unit_id
           	from  	per_people_f pap,
      		per_assignments_f paaf,
      		pay_payroll_actions ppa,
      		pay_payroll_actions ppa1,
      		pay_assignment_actions paa,
      		hr_organization_units hou,
      		per_periods_of_service pps,
		pay_population_ranges ppr
      	where   ppa.payroll_action_id        = c_payroll_action_id
	and     ppr.payroll_action_id = ppa.payroll_action_id
	and     ppr.chunk_number = c_chunk
      	and     paa.assignment_id            = paaf.assignment_id
      	and     pap.person_id                = ppr.person_id
      	and     pap.person_id                = paaf.person_id
      	and     pap.person_id                = pps.person_id
      	and     pps.period_of_service_id     = paaf.period_of_service_id
  	and     ppa1.date_earned between paaf.effective_start_date and paaf.effective_end_date
  	and     ppa1.date_earned between pap.effective_start_date  and pap.effective_end_date
      	and    ppa1.payroll_action_id       = paa.payroll_action_id
	AND    paa.action_status ='C'
      	and    ppa1.business_group_id       = ppa.business_group_id
      	and    ppa.business_group_id        = c_business_group_id
      	and    ppa1.action_type             in ('R','Q','I','B','V')
	and    paa.source_action_id is null
      	and    paaf.organization_id         = hou.organization_id
  	and    hou.business_group_id        = c_business_group_id
      	and    NVL(pap.current_employee_flag,'N') like c_employee_type
      	and    hou.organization_id          = c_organization_id
      	and    ppa1.payroll_action_id       = c_pact_id
      	order  by paaf.assignment_id, paa.assignment_action_id, paa.tax_unit_id;

  --------------------------------------------------------------------+
  -- Cursor      : csr_assignment_legal_period
  -- Description : Fetches assignments when Legal Employer,Archive
  --               Start Date and End Date is specified
  --------------------------------------------------------------------+
/*Bug 3935471 - modified cursor to return the assignment action id and
                tax unit of the master wherever there is a master-child
                relationship*/

  cursor csr_assignment_legal_period
      (c_payroll_action_id  pay_payroll_actions.payroll_action_id%type
      ,c_start_person       per_all_people_f.person_id%type
      ,c_end_person         per_all_people_f.person_id%type
      ,c_employee_type      per_all_people_f.current_employee_flag%type
      ,c_business_group_id  hr_all_organization_units.organization_id%type
      ,c_legal_employer     hr_all_organization_units.organization_id%type
      ,c_archive_start_date         date
      ,c_archive_end_date           date
      ) is
      select 	paa.assignment_action_id,
                paa.action_sequence,
      	   	paaf.assignment_id,
      	   	paa.tax_unit_id,
           		paa.source_action_id master_action_id, /*Bug# 3935471*/
         		paa2.tax_unit_id master_tax_unit_id /*Bug# 3935471*/
       	from  	per_people_f pap,
  		per_assignments_f paaf,
  		pay_payroll_actions ppa,
  		pay_payroll_actions ppa1,
  		pay_assignment_actions paa,
		pay_assignment_actions paa2, /*Bug# 3935471*/
  		per_periods_of_service pps
	where   ppa.payroll_action_id        = c_payroll_action_id
  	and     paa.assignment_id            = paaf.assignment_id /*Bug# 3935471*/
   AND     paa2.assignment_id           = paa.assignment_id
  	and     pap.person_id                between c_start_person and c_end_person
  	and     pap.person_id                = paaf.person_id
  	and     pap.person_id                = pps.person_id
  	and     pps.period_of_service_id     = paaf.period_of_service_id
  	and     ppa1.date_earned between pap.effective_start_date  and pap.effective_end_date
  	and    ppa1.payroll_action_id       = paa.payroll_action_id
  	and    ppa1.payroll_action_id       = paa2.payroll_action_id /*Bug# 3935471*/
	AND    paa2.action_status ='C' /*Bug# 3935471*/
	AND    paa.action_status ='C' /*Bug 4099317*/
	AND    paa2.assignment_action_id = nvl(paa.source_action_id, paa.assignment_action_id) /*Bug# 3935471*/
  	and    ppa1.business_group_id       = ppa.business_group_id
  	and    ppa.business_group_id        = c_business_group_id
  	and    ppa1.action_type             in ('R','Q','I','B','V')
  	and    paa.tax_unit_id              = c_legal_employer
  	and    ppa1.effective_date  between c_archive_start_date and c_archive_end_date
        and   decode(pps.actual_termination_date,null,'Y',decode(sign(pps.actual_termination_date - (c_archive_end_date)),1,'Y','N')) LIKE c_employee_type  --Bug 4161540
        and   paaf.effective_end_date = (select max(effective_end_date) --Bug# 3538810
					From  per_assignments_f iipaf
					WHERE iipaf.assignment_id  = paaf.assignment_id
					and iipaf.effective_end_date >= c_archive_start_date
					and iipaf.effective_start_date <= c_archive_end_date)
  	order  by paaf.assignment_id, paa.assignment_action_id, paa.tax_unit_id, paa.source_action_id, paa2.tax_unit_id; /*Bug# 3935471*/

  --------------------------------------------------------------------+
  -- Bug         : 9113084
  -- Cursor      : rg_csr_assignment_legal_period
  -- Description : Fetches assignments when Legal Employer,Archive
  --               Start Date and End Date is specified
  -- Usage       : When Range Person is enabled
  --------------------------------------------------------------------+
  cursor rg_csr_assignment_legal_period
      (c_payroll_action_id  pay_payroll_actions.payroll_action_id%type
       ,c_chunk NUMBER
      ,c_employee_type      per_all_people_f.current_employee_flag%type
      ,c_business_group_id  hr_all_organization_units.organization_id%type
      ,c_legal_employer     hr_all_organization_units.organization_id%type
      ,c_archive_start_date         date
      ,c_archive_end_date           date
      ) is
      select 	paa.assignment_action_id,
                paa.action_sequence,
      	   	paaf.assignment_id,
      	   	paa.tax_unit_id,
           		paa.source_action_id master_action_id,
         		paa2.tax_unit_id master_tax_unit_id
       	from  	per_people_f pap,
  		per_assignments_f paaf,
  		pay_payroll_actions ppa,
  		pay_payroll_actions ppa1,
  		pay_assignment_actions paa,
		pay_assignment_actions paa2,
  		per_periods_of_service pps,
		pay_population_ranges ppr
	where   ppa.payroll_action_id        = c_payroll_action_id
	and     ppr.payroll_action_id = ppa.payroll_action_id
	and     ppr.chunk_number = c_chunk
  	and     paa.assignment_id            = paaf.assignment_id
   AND     paa2.assignment_id           = paa.assignment_id
  	and     pap.person_id                = ppr.person_id
  	and     pap.person_id                = paaf.person_id
  	and     pap.person_id                = pps.person_id
  	and     pps.period_of_service_id     = paaf.period_of_service_id
  	and     ppa1.date_earned between pap.effective_start_date  and pap.effective_end_date
  	and    ppa1.payroll_action_id       = paa.payroll_action_id
  	and    ppa1.payroll_action_id       = paa2.payroll_action_id
	AND    paa2.action_status ='C'
	AND    paa.action_status ='C'
	AND    paa2.assignment_action_id = nvl(paa.source_action_id, paa.assignment_action_id)
  	and    ppa1.business_group_id       = ppa.business_group_id
  	and    ppa.business_group_id        = c_business_group_id
  	and    ppa1.action_type             in ('R','Q','I','B','V')
  	and    paa.tax_unit_id              = c_legal_employer
  	and    ppa1.effective_date  between c_archive_start_date and c_archive_end_date
        and   decode(pps.actual_termination_date,null,'Y',decode(sign(pps.actual_termination_date - (c_archive_end_date)),1,'Y','N')) LIKE c_employee_type  --Bug 4161540
        and   paaf.effective_end_date = (select max(effective_end_date)
					From  per_assignments_f iipaf
					WHERE iipaf.assignment_id  = paaf.assignment_id
					and iipaf.effective_end_date >= c_archive_start_date
					and iipaf.effective_start_date <= c_archive_end_date)
  	order  by paaf.assignment_id, paa.assignment_action_id, paa.tax_unit_id, paa.source_action_id, paa2.tax_unit_id; /*Bug# 3935471*/


  --------------------------------------------------------------------+
  -- Cursor      : csr_assignment_legal_run
  -- Description : Fetches assignments when Legal Employer,Payroll Run
  --               and Period End Date is specified
  --------------------------------------------------------------------+
/*Bug 3935471 - modified cursor to return the assignment action id and
                tax unit of the master wherever there is a master-child
                relationship*/

    cursor csr_assignment_legal_run
      (c_payroll_action_id  pay_payroll_actions.payroll_action_id%type
      ,c_start_person       per_all_people_f.person_id%type
      ,c_end_person         per_all_people_f.person_id%type
      ,c_employee_type      per_all_people_f.current_employee_flag%type
      ,c_business_group_id  hr_all_organization_units.organization_id%type
      ,c_legal_employer     hr_all_organization_units.organization_id%type
      ,c_period_end_date            date
      ,c_pact_id            pay_payroll_actions.payroll_action_id%type
      ) is
      select 	paa.assignment_action_id,
                paa.action_sequence,
      	   	paaf.assignment_id,
      	   	paa.tax_unit_id,
         		paa.source_action_id master_action_id, /*Bug# 3935471*/
         		paa2.tax_unit_id master_tax_unit_id /*Bug# 3935471*/
       	from  	per_people_f pap,
              		per_assignments_f paaf,
              		pay_payroll_actions ppa,
              		pay_payroll_actions ppa1,
              		pay_assignment_actions paa,
            		pay_assignment_actions paa2, /*Bug# 3935471*/
              		per_periods_of_service pps
         where   ppa.payroll_action_id        = c_payroll_action_id
         and     paa.assignment_id            = paaf.assignment_id
         AND     paa2.assignment_id           = paa.assignment_id /*Bug# 3935471*/
         and     pap.person_id                between c_start_person and c_end_person
         and     pap.person_id                = paaf.person_id
         and     pap.person_id                = pps.person_id
         and     pps.period_of_service_id     = paaf.period_of_service_id
         and     ppa1.date_earned between paaf.effective_start_date and paaf.effective_end_date
         and     ppa1.date_earned between pap.effective_start_date  and pap.effective_end_date
         and    ppa1.payroll_action_id       = paa.payroll_action_id
         AND    ppa1.payroll_action_id       = paa2.payroll_action_id /*Bug# 3935471*/
         AND    paa2.assignment_action_id = nvl(paa.source_action_id, paa.assignment_action_id) /*Bug# 3935471*/
         AND    paa.action_status ='C' /*Bug 4099317*/
         AND    paa2.action_status = 'C' /*Bug# 3935471*/
         and    ppa1.business_group_id       = ppa.business_group_id
         and    ppa.business_group_id        = c_business_group_id
         and    ppa1.action_type             in ('R','Q','I','B','V')
         and    NVL(pap.current_employee_flag,'N') like c_employee_type
         and    paa.tax_unit_id              = c_legal_employer
         and    ppa1.payroll_action_id       = c_pact_id
         order  by paaf.assignment_id, paa.assignment_action_id, paa.tax_unit_id, paa.source_action_id, paa2.tax_unit_id; /*Bug# 3935471*/

  --------------------------------------------------------------------+
  -- Bug         : 9113084
  -- Cursor      : rg_csr_assignment_legal_run
  -- Description : Fetches assignments when Legal Employer,Payroll Run
  --               and Period End Date is specified
  -- Usage       : When Range Person is enabled
  --------------------------------------------------------------------+
    cursor rg_csr_assignment_legal_run
      (c_payroll_action_id  pay_payroll_actions.payroll_action_id%type
      ,c_chunk NUMBER
      ,c_employee_type      per_all_people_f.current_employee_flag%type
      ,c_business_group_id  hr_all_organization_units.organization_id%type
      ,c_legal_employer     hr_all_organization_units.organization_id%type
      ,c_period_end_date            date
      ,c_pact_id            pay_payroll_actions.payroll_action_id%type
      ) is
      select 	paa.assignment_action_id,
                paa.action_sequence,
      	   	paaf.assignment_id,
      	   	paa.tax_unit_id,
         		paa.source_action_id master_action_id,
         		paa2.tax_unit_id master_tax_unit_id
       	from  	per_people_f pap,
              		per_assignments_f paaf,
              		pay_payroll_actions ppa,
              		pay_payroll_actions ppa1,
              		pay_assignment_actions paa,
            		pay_assignment_actions paa2,
              		per_periods_of_service pps,
			pay_population_ranges ppr
         where   ppa.payroll_action_id        = c_payroll_action_id
	 and     ppr.payroll_action_id = ppa.payroll_action_id
	 and     ppr.chunk_number = c_chunk
         and     paa.assignment_id            = paaf.assignment_id
         AND     paa2.assignment_id           = paa.assignment_id
         and     pap.person_id                = ppr.person_id
         and     pap.person_id                = paaf.person_id
         and     pap.person_id                = pps.person_id
         and     pps.period_of_service_id     = paaf.period_of_service_id
         and     ppa1.date_earned between paaf.effective_start_date and paaf.effective_end_date
         and     ppa1.date_earned between pap.effective_start_date  and pap.effective_end_date
         and    ppa1.payroll_action_id       = paa.payroll_action_id
         AND    ppa1.payroll_action_id       = paa2.payroll_action_id
         AND    paa2.assignment_action_id = nvl(paa.source_action_id, paa.assignment_action_id)
         AND    paa.action_status ='C'
         AND    paa2.action_status = 'C'
         and    ppa1.business_group_id       = ppa.business_group_id
         and    ppa.business_group_id        = c_business_group_id
         and    ppa1.action_type             in ('R','Q','I','B','V')
         and    NVL(pap.current_employee_flag,'N') like c_employee_type
         and    paa.tax_unit_id              = c_legal_employer
         and    ppa1.payroll_action_id       = c_pact_id
         order  by paaf.assignment_id, paa.assignment_action_id, paa.tax_unit_id, paa.source_action_id, paa2.tax_unit_id; /*Bug# 3935471*/

    --------------------------------------------------------------------+
    -- Cursor      : csr_assignment_payroll_period
    -- Description : Fetches assignments when Payroll,Archive Start
    --               Date and End Date is specified
    --------------------------------------------------------------------+

    cursor csr_assignment_payroll_period
      (c_payroll_action_id  pay_payroll_actions.payroll_action_id%type
      ,c_start_person       per_all_people_f.person_id%type
      ,c_end_person         per_all_people_f.person_id%type
      ,c_employee_type      per_all_people_f.current_employee_flag%type
      ,c_business_group_id  hr_all_organization_units.organization_id%type
      ,c_payroll_id         pay_payroll_actions.payroll_id%type
      ,c_archive_start_date         date
      ,c_archive_end_date           date
      ) is
       select 	paa.assignment_action_id,
                paa.action_sequence,
      	   	paaf.assignment_id,
      	   	paa.tax_unit_id
       	from  	per_people_f pap,
  		per_assignments_f paaf,
  		pay_payroll_actions ppa,
  		pay_payroll_actions ppa1,
  		pay_assignment_actions paa,
  		per_periods_of_service pps
  	where   ppa.payroll_action_id        = c_payroll_action_id
  	and     paa.assignment_id            = paaf.assignment_id
  	and     pap.person_id                between c_start_person and c_end_person
  	and     pap.person_id                = paaf.person_id
  	and     pap.person_id                = pps.person_id
  	and     pps.period_of_service_id     = paaf.period_of_service_id
  	and     ppa1.date_earned between pap.effective_start_date  and pap.effective_end_date
  	and    ppa1.payroll_action_id       = paa.payroll_action_id
	AND    paa.action_status ='C' /*Bug 4099317*/
  	and    ppa1.business_group_id       = ppa.business_group_id
  	and    ppa.business_group_id        = c_business_group_id
  	and    ppa1.action_type             in ('R','Q','I','B','V')
	and    paa.source_action_id is null
  	and    ppa1.effective_date  between c_archive_start_date and c_archive_end_date
        AND    paaf.payroll_id              = c_payroll_id /*Bug 4040688*/
        and   decode(pps.actual_termination_date,null,'Y',decode(sign(pps.actual_termination_date - (c_archive_end_date)),1,'Y','N')) LIKE c_employee_type  --Bug 4161540
        and   paaf.effective_end_date = (select max(effective_end_date) --Bug# 3538810
					From  per_assignments_f iipaf
					WHERE iipaf.assignment_id  = paaf.assignment_id
					and iipaf.effective_end_date >= c_archive_start_date
					and iipaf.effective_start_date <= c_archive_end_date
               AND iipaf.payroll_id IS NOT NULL) /*Bug#4688800*/
  	order  by paaf.assignment_id, paa.assignment_action_id, paa.tax_unit_id;

    --------------------------------------------------------------------+
    -- Bug         : 9113084
    -- Cursor      : rg_assignment_payroll_period
    -- Description : Fetches assignments when Payroll,Archive Start
    --               Date and End Date is specified
    -- Usage       : When Range Person is enabled
    --------------------------------------------------------------------+
    cursor rg_assignment_payroll_period
      (c_payroll_action_id  pay_payroll_actions.payroll_action_id%type
      , c_chunk NUMBER
      ,c_employee_type      per_all_people_f.current_employee_flag%type
      ,c_business_group_id  hr_all_organization_units.organization_id%type
      ,c_payroll_id         pay_payroll_actions.payroll_id%type
      ,c_archive_start_date         date
      ,c_archive_end_date           date
      ) is
       select 	paa.assignment_action_id,
                paa.action_sequence,
      	   	paaf.assignment_id,
      	   	paa.tax_unit_id
       	from  	per_people_f pap,
  		per_assignments_f paaf,
  		pay_payroll_actions ppa,
  		pay_payroll_actions ppa1,
  		pay_assignment_actions paa,
  		per_periods_of_service pps,
		pay_population_ranges ppr
  	where   ppa.payroll_action_id        = c_payroll_action_id
	and     ppr.payroll_action_id = ppa.payroll_action_id
	and ppr.chunk_number = c_chunk
  	and     paa.assignment_id            = paaf.assignment_id
  	and     pap.person_id                = ppr.person_id
  	and     pap.person_id                = paaf.person_id
  	and     pap.person_id                = pps.person_id
  	and     pps.period_of_service_id     = paaf.period_of_service_id
  	and     ppa1.date_earned between pap.effective_start_date  and pap.effective_end_date
  	and    ppa1.payroll_action_id       = paa.payroll_action_id
	AND    paa.action_status ='C'
  	and    ppa1.business_group_id       = ppa.business_group_id
  	and    ppa.business_group_id        = c_business_group_id
  	and    ppa1.action_type             in ('R','Q','I','B','V')
	and    paa.source_action_id is null
  	and    ppa1.effective_date  between c_archive_start_date and c_archive_end_date
        AND    paaf.payroll_id              = c_payroll_id
        and   decode(pps.actual_termination_date,null,'Y',decode(sign(pps.actual_termination_date - (c_archive_end_date)),1,'Y','N')) LIKE c_employee_type  --Bug 4161540
        and   paaf.effective_end_date = (select max(effective_end_date)
					From  per_assignments_f iipaf
					WHERE iipaf.assignment_id  = paaf.assignment_id
					and iipaf.effective_end_date >= c_archive_start_date
					and iipaf.effective_start_date <= c_archive_end_date
               AND iipaf.payroll_id IS NOT NULL)
  	order  by paaf.assignment_id, paa.assignment_action_id, paa.tax_unit_id;


  --------------------------------------------------------------------+
  -- Cursor      : csr_assignment_payroll_run
  -- Description : Fetches assignments when Payroll,Payroll Run
  --               and Period End Date is specified
  --------------------------------------------------------------------+

  cursor csr_assignment_payroll_run
      (c_payroll_action_id  pay_payroll_actions.payroll_action_id%type
      ,c_start_person       per_all_people_f.person_id%type
      ,c_end_person         per_all_people_f.person_id%type
      ,c_employee_type      per_all_people_f.current_employee_flag%type
      ,c_business_group_id  hr_all_organization_units.organization_id%type
      ,c_payroll_id         pay_payroll_actions.payroll_id%type
      ,c_period_end_date            date
      ,c_pact_id            pay_payroll_actions.payroll_action_id%type
      ) is
      select      paa.assignment_action_id,
                paa.action_sequence,
          	   	paaf.assignment_id,
          	   	paa.tax_unit_id
           	from  	per_people_f pap,
      		per_assignments_f paaf,
      		pay_payroll_actions ppa,
      		pay_payroll_actions ppa1,
      		pay_assignment_actions paa,
       		per_periods_of_service pps
      	where   ppa.payroll_action_id        = c_payroll_action_id
      	and     paa.assignment_id            = paaf.assignment_id
      	and     pap.person_id                between c_start_person and c_end_person
      	and     pap.person_id                = paaf.person_id
      	and     pap.person_id                = pps.person_id
      	and     pps.period_of_service_id     = paaf.period_of_service_id
  	and     ppa1.date_earned between paaf.effective_start_date and paaf.effective_end_date
  	and     ppa1.date_earned between pap.effective_start_date  and pap.effective_end_date
      	and    ppa1.payroll_action_id       = paa.payroll_action_id
	AND    paa.action_status ='C' /*Bug 4099317*/
      	and    ppa1.business_group_id       = ppa.business_group_id
      	and    ppa.business_group_id        = c_business_group_id
      	and    ppa1.action_type             in ('R','Q','I','B','V')
	and    paa.source_action_id is null
      	and    NVL(pap.current_employee_flag,'N') like c_employee_type
      	and    ppa1.payroll_id              = c_payroll_id
      	and    ppa1.payroll_action_id       = c_pact_id
      	order  by paaf.assignment_id, paa.assignment_action_id, paa.tax_unit_id;

  --------------------------------------------------------------------+
  -- Bug         : 9113084
  -- Cursor      : rg_csr_assignment_payroll_run
  -- Description : Fetches assignments when Payroll,Payroll Run
  --               and Period End Date is specified
  -- Usage       : When Range Person is enabled
  --------------------------------------------------------------------+
  cursor rg_csr_assignment_payroll_run
      (c_payroll_action_id  pay_payroll_actions.payroll_action_id%type
      , c_chunk number
      ,c_employee_type      per_all_people_f.current_employee_flag%type
      ,c_business_group_id  hr_all_organization_units.organization_id%type
      ,c_payroll_id         pay_payroll_actions.payroll_id%type
      ,c_period_end_date            date
      ,c_pact_id            pay_payroll_actions.payroll_action_id%type
      ) is
      select      paa.assignment_action_id,
                paa.action_sequence,
          	   	paaf.assignment_id,
          	   	paa.tax_unit_id
           	from  	per_people_f pap,
      		per_assignments_f paaf,
      		pay_payroll_actions ppa,
      		pay_payroll_actions ppa1,
      		pay_assignment_actions paa,
       		per_periods_of_service pps,
		pay_population_ranges ppr
      	where   ppa.payroll_action_id        = c_payroll_action_id
	and     ppr.payroll_action_id = ppa.payroll_action_id
	and     ppr.chunk_number = c_chunk
      	and     paa.assignment_id            = paaf.assignment_id
      	and     pap.person_id                = ppr.person_id
      	and     pap.person_id                = paaf.person_id
      	and     pap.person_id                = pps.person_id
      	and     pps.period_of_service_id     = paaf.period_of_service_id
  	and     ppa1.date_earned between paaf.effective_start_date and paaf.effective_end_date
  	and     ppa1.date_earned between pap.effective_start_date  and pap.effective_end_date
      	and    ppa1.payroll_action_id       = paa.payroll_action_id
	AND    paa.action_status ='C'
      	and    ppa1.business_group_id       = ppa.business_group_id
      	and    ppa.business_group_id        = c_business_group_id
      	and    ppa1.action_type             in ('R','Q','I','B','V')
	and    paa.source_action_id is null
      	and    NVL(pap.current_employee_flag,'N') like c_employee_type
      	and    ppa1.payroll_id              = c_payroll_id
      	and    ppa1.payroll_action_id       = c_pact_id
      	order  by paaf.assignment_id, paa.assignment_action_id, paa.tax_unit_id;


  --------------------------------------------------------------------+
  -- Cursor      : csr_assignment_period
  -- Description : Fetches assignments when Assignment,Archive Start
  --               Date and End Date is specified
  --------------------------------------------------------------------+

   cursor csr_assignment_period
      (c_payroll_action_id  pay_payroll_actions.payroll_action_id%type
      ,c_start_person       per_all_people_f.person_id%type
      ,c_end_person         per_all_people_f.person_id%type
      ,c_employee_type      per_all_people_f.current_employee_flag%type
      ,c_business_group_id  hr_all_organization_units.organization_id%type
      ,c_assignment_id      per_all_assignments_f.assignment_id%type
      ,c_archive_start_date         date
      ,c_archive_end_date           date
      ) is
      select 	paa.assignment_action_id,
                paa.action_sequence,
      	   	paaf.assignment_id,
      	   	paa.tax_unit_id
       	from  	per_people_f pap,
  		per_assignments_f paaf,
  		pay_payroll_actions ppa,
  		pay_payroll_actions ppa1,
  		pay_assignment_actions paa,
  		per_periods_of_service pps
  	where   ppa.payroll_action_id        = c_payroll_action_id
  	and     paa.assignment_id            = paaf.assignment_id
  	and     pap.person_id                between c_start_person and c_end_person
  	and     pap.person_id                = paaf.person_id
  	and     pap.person_id                = pps.person_id
  	and     pps.period_of_service_id     = paaf.period_of_service_id
  	and     ppa1.date_earned between pap.effective_start_date  and pap.effective_end_date
  	and    ppa1.payroll_action_id       = paa.payroll_action_id
	AND    paa.action_status ='C' /*Bug 4099317*/
  	and    ppa1.business_group_id       = ppa.business_group_id
  	and    ppa.business_group_id        = c_business_group_id
  	and    ppa1.action_type             in ('R','Q','I','B','V')
	and    paa.source_action_id is null
  	and    paa.assignment_id            = c_assignment_id
  	and    ppa1.effective_date between c_archive_start_date and c_archive_end_date
       and   decode(pps.actual_termination_date,null,'Y',decode(sign(pps.actual_termination_date - (c_archive_end_date)),1,'Y','N')) LIKE c_employee_type  --Bug 4161540
        and   paaf.effective_end_date = (select max(effective_end_date) --Bug# 3538810
					From  per_assignments_f iipaf
					WHERE iipaf.assignment_id  = paaf.assignment_id
					and iipaf.effective_end_date >= c_archive_start_date
					and iipaf.effective_start_date <= c_archive_end_date)
	order  by paaf.assignment_id, paa.assignment_action_id, paa.tax_unit_id;

  --------------------------------------------------------------------+
  -- Bug         : 9113084
  -- Cursor      : rg_csr_assignment_period
  -- Description : Fetches assignments when Assignment,Archive Start
  --               Date and End Date is specified
  -- Usage       : When Range Person is enabled
  --------------------------------------------------------------------+
   cursor rg_csr_assignment_period
      (c_payroll_action_id  pay_payroll_actions.payroll_action_id%type
      ,c_chunk number
      ,c_employee_type      per_all_people_f.current_employee_flag%type
      ,c_business_group_id  hr_all_organization_units.organization_id%type
      ,c_assignment_id      per_all_assignments_f.assignment_id%type
      ,c_archive_start_date         date
      ,c_archive_end_date           date
      ) is
      select 	paa.assignment_action_id,
                paa.action_sequence,
      	   	paaf.assignment_id,
      	   	paa.tax_unit_id
       	from  	per_people_f pap,
  		per_assignments_f paaf,
  		pay_payroll_actions ppa,
  		pay_payroll_actions ppa1,
  		pay_assignment_actions paa,
  		per_periods_of_service pps,
		pay_population_ranges ppr
  	where   ppa.payroll_action_id        = c_payroll_action_id
	and     ppr.payroll_action_id = ppa.payroll_action_id
	and     ppr.chunk_number = c_chunk
  	and     paa.assignment_id            = paaf.assignment_id
  	and     pap.person_id                = ppr.person_id
  	and     pap.person_id                = paaf.person_id
  	and     pap.person_id                = pps.person_id
  	and     pps.period_of_service_id     = paaf.period_of_service_id
  	and     ppa1.date_earned between pap.effective_start_date  and pap.effective_end_date
  	and    ppa1.payroll_action_id       = paa.payroll_action_id
	AND    paa.action_status ='C'
  	and    ppa1.business_group_id       = ppa.business_group_id
  	and    ppa.business_group_id        = c_business_group_id
  	and    ppa1.action_type             in ('R','Q','I','B','V')
	and    paa.source_action_id is null
  	and    paa.assignment_id            = c_assignment_id
  	and    ppa1.effective_date between c_archive_start_date and c_archive_end_date
       and   decode(pps.actual_termination_date,null,'Y',decode(sign(pps.actual_termination_date - (c_archive_end_date)),1,'Y','N')) LIKE c_employee_type  --Bug 4161540
        and   paaf.effective_end_date = (select max(effective_end_date)
					From  per_assignments_f iipaf
					WHERE iipaf.assignment_id  = paaf.assignment_id
					and iipaf.effective_end_date >= c_archive_start_date
					and iipaf.effective_start_date <= c_archive_end_date)
	order  by paaf.assignment_id, paa.assignment_action_id, paa.tax_unit_id;


  -------------------------------------------------------------------+
  -- Cursor      : csr_assignment_run
  -- Description : Fetches assignments when Assignment,Payroll Run
  --               and Period End Date is specified
  --------------------------------------------------------------------+

      cursor csr_assignment_run
      (c_payroll_action_id  pay_payroll_actions.payroll_action_id%type
      ,c_start_person       per_all_people_f.person_id%type
      ,c_end_person         per_all_people_f.person_id%type
      ,c_employee_type      per_all_people_f.current_employee_flag%type
      ,c_business_group_id  hr_all_organization_units.organization_id%type
      ,c_assignment_id      per_all_assignments_f.assignment_id%type
      ,c_period_end_date            date
      ,c_pact_id            pay_payroll_actions.payroll_action_id%type
      ) is
      select 	paa.assignment_action_id,
                paa.action_sequence,
      	   	paaf.assignment_id,
      	   	paa.tax_unit_id
       	from  	per_people_f pap,
  		per_assignments_f paaf,
  		pay_payroll_actions ppa,
  		pay_payroll_actions ppa1,
  		pay_assignment_actions paa,
    		per_periods_of_service pps
  	where   ppa.payroll_action_id        = c_payroll_action_id
  	and     paa.assignment_id            = paaf.assignment_id
  	and     pap.person_id                between c_start_person and c_end_person
  	and     pap.person_id                = paaf.person_id
  	and     pap.person_id                = pps.person_id
  	and     pps.period_of_service_id     = paaf.period_of_service_id
  	and     ppa1.date_earned between paaf.effective_start_date and paaf.effective_end_date
  	and     ppa1.date_earned between pap.effective_start_date  and pap.effective_end_date
  	and    ppa1.payroll_action_id       = paa.payroll_action_id
	AND    paa.action_status ='C' /*Bug 4099317*/
  	and    ppa1.business_group_id       = ppa.business_group_id
  	and    ppa.business_group_id        = c_business_group_id
  	and    ppa1.action_type             in ('R','Q','I','B','V')
	and    paa.source_action_id is null
  	and    NVL(pap.current_employee_flag,'N') like c_employee_type
  	and    paa.assignment_id            = c_assignment_id
  	and    ppa1.payroll_action_id       = c_pact_id
  	order  by paaf.assignment_id, paa.assignment_action_id, paa.tax_unit_id;

  -------------------------------------------------------------------+
  -- Bug         : 9113084
  -- Cursor      : rg_csr_assignment_run
  -- Description : Fetches assignments when Assignment,Payroll Run
  --               and Period End Date is specified
  -- Usage       : When Range Person is enabled
  --------------------------------------------------------------------+
      cursor rg_csr_assignment_run
      (c_payroll_action_id  pay_payroll_actions.payroll_action_id%type
      , c_chunk number
      ,c_employee_type      per_all_people_f.current_employee_flag%type
      ,c_business_group_id  hr_all_organization_units.organization_id%type
      ,c_assignment_id      per_all_assignments_f.assignment_id%type
      ,c_period_end_date            date
      ,c_pact_id            pay_payroll_actions.payroll_action_id%type
      ) is
      select 	paa.assignment_action_id,
                paa.action_sequence,
      	   	paaf.assignment_id,
      	   	paa.tax_unit_id
       	from  	per_people_f pap,
  		per_assignments_f paaf,
  		pay_payroll_actions ppa,
  		pay_payroll_actions ppa1,
  		pay_assignment_actions paa,
    		per_periods_of_service pps,
		pay_population_ranges ppr
  	where   ppa.payroll_action_id        = c_payroll_action_id
	and     ppr.payroll_action_id = ppa.payroll_action_id
	and     ppr.chunk_number = c_chunk
  	and     paa.assignment_id            = paaf.assignment_id
  	and     pap.person_id                = ppr.person_id
  	and     pap.person_id                = paaf.person_id
  	and     pap.person_id                = pps.person_id
  	and     pps.period_of_service_id     = paaf.period_of_service_id
  	and     ppa1.date_earned between paaf.effective_start_date and paaf.effective_end_date
  	and     ppa1.date_earned between pap.effective_start_date  and pap.effective_end_date
  	and    ppa1.payroll_action_id       = paa.payroll_action_id
	AND    paa.action_status ='C'
  	and    ppa1.business_group_id       = ppa.business_group_id
  	and    ppa.business_group_id        = c_business_group_id
  	and    ppa1.action_type             in ('R','Q','I','B','V')
	and    paa.source_action_id is null
  	and    NVL(pap.current_employee_flag,'N') like c_employee_type
  	and    paa.assignment_id            = c_assignment_id
  	and    ppa1.payroll_action_id       = c_pact_id
  	order  by paaf.assignment_id, paa.assignment_action_id, paa.tax_unit_id;


    --------------------------------------------------------------------+
    -- Cursor      : csr_assignment_default_period
    -- Description : Fetches assignments when Archive Start date
    --               and End Date is specified
    --------------------------------------------------------------------+

      cursor csr_assignment_default_period
      (c_payroll_action_id  pay_payroll_actions.payroll_action_id%type
      ,c_start_person       per_all_people_f.person_id%type
      ,c_end_person         per_all_people_f.person_id%type
      ,c_employee_type      per_all_people_f.current_employee_flag%type
      ,c_business_group_id  hr_all_organization_units.organization_id%type
      ,c_archive_start_date         date
      ,c_archive_end_date           date
      ) is
      select 	paa.assignment_action_id,
                paa.action_sequence,
      	   	paaf.assignment_id,
      	   	paa.tax_unit_id
       	from  	per_people_f pap,
  		per_assignments_f paaf,
  		pay_payroll_actions ppa,
  		pay_payroll_actions ppa1,
  		pay_assignment_actions paa,
  		per_periods_of_service pps
  	where   ppa.payroll_action_id        = c_payroll_action_id
  	and     paa.assignment_id            = paaf.assignment_id
  	and     pap.person_id                between c_start_person and c_end_person
  	and     pap.person_id                = paaf.person_id
  	and     pap.person_id                = pps.person_id
  	and     pps.period_of_service_id     = paaf.period_of_service_id
  	and     ppa1.date_earned between pap.effective_start_date  and pap.effective_end_date
  	and    ppa1.payroll_action_id       = paa.payroll_action_id
	AND    paa.action_status ='C' /*Bug 4099317*/
  	and    ppa1.business_group_id       = ppa.business_group_id
  	and    ppa.business_group_id        = c_business_group_id
  	and    ppa1.action_type             in ('R','Q','I','B','V')
	and    paa.source_action_id is null
  	and    ppa1.effective_date   between c_archive_start_date and c_archive_end_date
        and   decode(pps.actual_termination_date,null,'Y',decode(sign(pps.actual_termination_date - (c_archive_end_date)),1,'Y','N')) LIKE c_employee_type  --Bug 4161540
        and   paaf.effective_end_date = (select max(effective_end_date) --Bug# 3538810
					From  per_assignments_f iipaf
					WHERE iipaf.assignment_id  = paaf.assignment_id
					and iipaf.effective_end_date >= c_archive_start_date
					and iipaf.effective_start_date <= c_archive_end_date)
  	order  by paaf.assignment_id, paa.assignment_action_id, paa.tax_unit_id;

    --------------------------------------------------------------------+
    -- Bug         : 9113084
    -- Cursor      : rg_assignment_default_period
    -- Description : Fetches assignments when Archive Start date
    --               and End Date is specified
    -- Usage       : When Range Person is enabled
    --------------------------------------------------------------------+
      cursor rg_assignment_default_period
      (c_payroll_action_id  pay_payroll_actions.payroll_action_id%type
      , c_chunk NUMBER
      ,c_employee_type      per_all_people_f.current_employee_flag%type
      ,c_business_group_id  hr_all_organization_units.organization_id%type
      ,c_archive_start_date         date
      ,c_archive_end_date           date
      ) is
      select 	paa.assignment_action_id,
                paa.action_sequence,
      	   	paaf.assignment_id,
      	   	paa.tax_unit_id
       	from  	per_people_f pap,
  		per_assignments_f paaf,
  		pay_payroll_actions ppa,
  		pay_payroll_actions ppa1,
  		pay_assignment_actions paa,
  		per_periods_of_service pps,
		pay_population_ranges ppr
  	where   ppa.payroll_action_id        = c_payroll_action_id
	and     ppr.payroll_action_id = ppa.payroll_action_id
	and     ppr.chunk_number = c_chunk
  	and     paa.assignment_id            = paaf.assignment_id
  	and     pap.person_id                = ppr.person_id
  	and     pap.person_id                = paaf.person_id
  	and     pap.person_id                = pps.person_id
  	and     pps.period_of_service_id     = paaf.period_of_service_id
  	and     ppa1.date_earned between pap.effective_start_date  and pap.effective_end_date
  	and    ppa1.payroll_action_id       = paa.payroll_action_id
	AND    paa.action_status ='C'
  	and    ppa1.business_group_id       = ppa.business_group_id
  	and    ppa.business_group_id        = c_business_group_id
  	and    ppa1.action_type             in ('R','Q','I','B','V')
	and    paa.source_action_id is null
  	and    ppa1.effective_date   between c_archive_start_date and c_archive_end_date
        and   decode(pps.actual_termination_date,null,'Y',decode(sign(pps.actual_termination_date - (c_archive_end_date)),1,'Y','N')) LIKE c_employee_type  --Bug 4161540
        and   paaf.effective_end_date = (select max(effective_end_date)
					From  per_assignments_f iipaf
					WHERE iipaf.assignment_id  = paaf.assignment_id
					and iipaf.effective_end_date >= c_archive_start_date
					and iipaf.effective_start_date <= c_archive_end_date)
  	order  by paaf.assignment_id, paa.assignment_action_id, paa.tax_unit_id;


  --------------------------------------------------------------------+
  -- Cursor      : csr_assignment_default_run
  -- Description : Fetches assignments when Payroll Run
  --               and Period End Date is specified
  --------------------------------------------------------------------+

      cursor csr_assignment_default_run
      (c_payroll_action_id  pay_payroll_actions.payroll_action_id%type
      ,c_start_person       per_all_people_f.person_id%type
      ,c_end_person         per_all_people_f.person_id%type
      ,c_employee_type      per_all_people_f.current_employee_flag%type
      ,c_business_group_id  hr_all_organization_units.organization_id%type
      ,c_period_end_date            date
      ,c_pact_id            pay_payroll_actions.payroll_action_id%type
      ) is
      select 	paa.assignment_action_id,
                paa.action_sequence,
      	   	paaf.assignment_id,
      	   	paa.tax_unit_id
       	from  	per_people_f pap,
  		per_assignments_f paaf,
  		pay_payroll_actions ppa,
  		pay_payroll_actions ppa1,
  		pay_assignment_actions paa,
  		per_periods_of_service pps
  	where   ppa.payroll_action_id        = c_payroll_action_id
  	and     paa.assignment_id            = paaf.assignment_id
  	and     pap.person_id                between c_start_person and c_end_person
  	and     pap.person_id                = paaf.person_id
  	and     pap.person_id                = pps.person_id
  	and     pps.period_of_service_id     = paaf.period_of_service_id
  	and     ppa1.date_earned between paaf.effective_start_date and paaf.effective_end_date
  	and     ppa1.date_earned between pap.effective_start_date  and pap.effective_end_date
  	and    ppa1.payroll_action_id       = paa.payroll_action_id
	AND    paa.action_status ='C' /*Bug 4099317*/
  	and    ppa1.business_group_id       = ppa.business_group_id
  	and    ppa.business_group_id        = c_business_group_id
  	and    ppa1.action_type             in ('R','Q','I','B','V')
	and    paa.source_action_id is null
  	and    NVL(pap.current_employee_flag,'N') like c_employee_type
  	and    ppa1.payroll_action_id       = c_pact_id
  	order  by paaf.assignment_id, paa.assignment_action_id, paa.tax_unit_id;


  --------------------------------------------------------------------+
  -- Bug         : 9113084
  -- Cursor      : rg_csr_assignment_default_run
  -- Description : Fetches assignments when Payroll Run
  --               and Period End Date is specified
  -- Usage       : When Range Person is enabled
  --------------------------------------------------------------------+
      cursor rg_csr_assignment_default_run
      (c_payroll_action_id  pay_payroll_actions.payroll_action_id%type
      , c_chunk number
      ,c_employee_type      per_all_people_f.current_employee_flag%type
      ,c_business_group_id  hr_all_organization_units.organization_id%type
      ,c_period_end_date            date
      ,c_pact_id            pay_payroll_actions.payroll_action_id%type
      ) is
      select 	paa.assignment_action_id,
                paa.action_sequence,
      	   	paaf.assignment_id,
      	   	paa.tax_unit_id
       	from  	per_people_f pap,
  		per_assignments_f paaf,
  		pay_payroll_actions ppa,
  		pay_payroll_actions ppa1,
  		pay_assignment_actions paa,
  		per_periods_of_service pps,
		pay_population_ranges ppr
  	where   ppa.payroll_action_id        = c_payroll_action_id
	and     ppr.payroll_action_id = ppa.payroll_action_id
	and     ppr.chunk_number = c_chunk
  	and     paa.assignment_id            = paaf.assignment_id
  	and     pap.person_id                = ppr.person_id
  	and     pap.person_id                = paaf.person_id
  	and     pap.person_id                = pps.person_id
  	and     pps.period_of_service_id     = paaf.period_of_service_id
  	and     ppa1.date_earned between paaf.effective_start_date and paaf.effective_end_date
  	and     ppa1.date_earned between pap.effective_start_date  and pap.effective_end_date
  	and    ppa1.payroll_action_id       = paa.payroll_action_id
	AND    paa.action_status ='C'
  	and    ppa1.business_group_id       = ppa.business_group_id
  	and    ppa.business_group_id        = c_business_group_id
  	and    ppa1.action_type             in ('R','Q','I','B','V')
	and    paa.source_action_id is null
  	and    NVL(pap.current_employee_flag,'N') like c_employee_type
  	and    ppa1.payroll_action_id       = c_pact_id
  	order  by paaf.assignment_id, paa.assignment_action_id, paa.tax_unit_id;

  --------------------------------------------------------------------+
  -- Cursor      : csr_params
  -- Description : Fetches User Parameters from Legislative_paramters
  --               column.
  --------------------------------------------------------------------+

   CURSOR csr_params(c_payroll_action_id  pay_payroll_actions.payroll_action_id%TYPE)
      IS
        SELECT pay_core_utils.get_parameter('PAY',legislative_parameters)        payroll_id,
                   pay_core_utils.get_parameter('ORG',legislative_parameters)           org_id,
                   pay_core_utils.get_parameter('BG',legislative_parameters)    business_group_id,
                   to_date(pay_core_utils.get_parameter('SDATE',legislative_parameters),'YYYY/MM/DD') start_date,
                   to_date(pay_core_utils.get_parameter('EDATE',legislative_parameters),'YYYY/MM/DD')   end_date,
                   pay_core_utils.get_parameter('PACTID',legislative_parameters)        pact_id,
                   pay_core_utils.get_parameter('LE',legislative_parameters) legal_employer,
                   pay_core_utils.get_parameter('ASG',legislative_parameters) assignment_id,
                   pay_core_utils.get_parameter('SO1',legislative_parameters)   sort_order_1,
                   pay_core_utils.get_parameter('SO2',legislative_parameters)   sort_order_2,
                   pay_core_utils.get_parameter('SO3',legislative_parameters)   sort_order_3,
                   pay_core_utils.get_parameter('SO4',legislative_parameters)   sort_order_4,
                   to_date(pay_core_utils.get_parameter('PEDATE',legislative_parameters),'YYYY/MM/DD') period_end_date,
                   pay_core_utils.get_parameter('YTD_TOT',legislative_parameters)      ytd_totals,
                   pay_core_utils.get_parameter('ZERO_REC',legislative_parameters)    zero_records,
                   pay_core_utils.get_parameter('NEG_REC',legislative_parameters)     negative_records,
                   decode(pay_core_utils.get_parameter('EMP_TYPE',legislative_parameters),'C','Y','T','N','%') employee_type,
                   pay_core_utils.get_parameter('DEL_ACT',legislative_parameters)     delete_actions /*Bug# 4142159*/
                   FROM pay_payroll_actions ppa
      WHERE ppa.payroll_action_id  =  c_payroll_action_id;

 --------------------------------------------------------------------+
  -- Cursor      : csr_period_date_earned
  -- Description : Fetches Date Earned for a given payroll
  --               run.
  --------------------------------------------------------------------+
      /*Bug#3662449 *********/
      CURSOR csr_period_date_earned(c_payroll_action_id  pay_payroll_actions.payroll_action_id%TYPE)
      IS
        SELECT ppa.date_earned
	FROM pay_payroll_actions ppa
        WHERE
	ppa.payroll_action_id = c_payroll_action_id;


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
    g_debug :=hr_utility.debug_enabled ;
    if g_debug then
        g_package := 'pay_au_reconciliation_pkg.' ;
        l_procedure := g_package||'assignment_action_code';
        hr_utility.set_location('Entering ' || l_procedure,1);
        hr_utility.set_location('Entering assignment_Action_code',302);
    end if;

    -- initialization_code to to set the global tables for EIT
        -- that will be used by each thread in multi-threading.

    g_arc_payroll_action_id := p_payroll_action_id;

    -- Fetch the parameters by user passed into global variable.

        OPEN csr_params(p_payroll_action_id);
     	FETCH csr_params into g_parameters;
       	CLOSE csr_params;


    if g_debug then
        hr_utility.set_location('p_payroll_action_id.........= ' || p_payroll_action_id,30);
        hr_utility.set_location('p_start_person..............= ' || p_start_person,30);
        hr_utility.set_location('p_end_person................= ' || p_end_person,30);
        hr_utility.set_location('g_parameters.business_group_id.........= ' || g_parameters.business_group_id,30);
        hr_utility.set_location('g_parameters.payroll_id..............= ' || g_parameters.payroll_id,30);
        hr_utility.set_location('g_parameters.org_id................= ' || g_parameters.org_id,30);
        hr_utility.set_location('g_parameters.legal_employer.........= ' || g_parameters.legal_employer,30);
        hr_utility.set_location('g_parameters.start_date..............= ' || g_parameters.start_date,30);
        hr_utility.set_location('g_parameters.end_date................= ' || g_parameters.end_date,30);
        hr_utility.set_location('g_parameters.period_end_date.........= ' || g_parameters.period_end_date,30);
        hr_utility.set_location('g_parameters.pact_id..............= ' || g_parameters.pact_id,30);
        hr_utility.set_location('g_parameters.employee_type..........= '||g_parameters.employee_type,30);
        hr_utility.set_location('g_parameters.sort_order1..........= '||g_parameters.sort_order_1,30);
        hr_utility.set_location('g_parameters.sort_order2..........= '||g_parameters.sort_order_2,30);
        hr_utility.set_location('g_parameters.sort_order3..........= '||g_parameters.sort_order_3,30);
        hr_utility.set_location('g_parameters.sort_order4..........= '||g_parameters.sort_order_4,30);
	hr_utility.set_location('g_parameters.delete_actions..........= '||g_parameters.delete_actions,30);/*Bug# 4142159*/
    end if;


    g_business_group_id := g_parameters.business_group_id ;

    -- Set end date variable .This value is used to fetch latest assignment details of
    -- employee for archival.In case of archive start date/end date - archive end date
    -- taken and pact_id/period_end_date , period end date is picked.

    if g_parameters.end_date is not null
    then
        g_end_date := g_parameters.end_date;
        g_start_date := g_parameters.start_date; --Bug#3662449
    else
        if g_parameters.period_end_date is not null
        then
            open csr_period_date_earned(g_parameters.pact_id); --Bug#3662449
            fetch csr_period_date_earned into g_start_date;
            close csr_period_date_earned;
            g_end_date  := g_parameters.period_end_date;
        else
            g_start_date := to_date('1900/01/01','YYYY/MM/DD');  --Bug#3662449
            g_end_date  := to_date('4712/12/31','YYYY/MM/DD');
        end if;
    end if; /* End of outer if loop */


IF range_person_on THEN /* 9113084 - Use Range Person Cursors when RANGE_PERSON_ID is enabled */

    if g_parameters.org_id is not null
    then
       if g_parameters.start_date is not null and g_parameters.end_date is not null
       then
                 IF g_debug THEN
                   hr_utility.set_location('Using Range Person Cursor for fetching assignments',30);
                 END IF;
            FOR csr_rec in rg_csr_assignment_org_period(p_payroll_action_id,
                                                 p_chunk,
                                                 g_parameters.employee_type,
                                                 g_parameters.business_group_id,
                                                 g_parameters.org_id,
                                                 g_parameters.start_date,
                                                 g_parameters.end_date)
            LOOP /*Loop 1 Org,Archive start date,end date */
             open csr_next_action_id;
             fetch  csr_next_action_id into l_next_assignment_action_id;
             close csr_next_action_id;

              if g_debug then

                   hr_utility.set_location('p_payroll_action_id.........= '||p_payroll_action_id,20);
                   hr_utility.set_location('l_next_assignment_action_id.= '||l_next_assignment_action_id,20);
                   hr_utility.set_location('csr_rec.assignment_id.......= '||csr_rec.assignment_id,20);
                   hr_utility.set_location('csr_rec.tax_unit_id.........= '||csr_rec.tax_unit_id,20);

              end if;



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


            END LOOP;/* Loop 1 */
            if g_debug then
            hr_utility.set_location('Leaving............Loop1 Org+Period....' || l_procedure,1000);
            end if;

       else
                  IF g_debug THEN
                   hr_utility.set_location('Using Range Person Cursor for fetching assignments',30);
                 END IF;
               FOR csr_rec in rg_csr_assignment_org_run(p_payroll_action_id,
                                                 p_chunk,
                                                 g_parameters.employee_type,
                                                 g_parameters.business_group_id,
                                                 g_parameters.org_id,
                                                 g_parameters.period_end_date,
                                                 g_parameters.pact_id)
               LOOP /*Loop 2 Org,Pact_id and period end date*/
                 open csr_next_action_id;
             fetch  csr_next_action_id into l_next_assignment_action_id;
             close csr_next_action_id;

             if g_debug then
             hr_utility.set_location('p_payroll_action_id.........= '||p_payroll_action_id,20);
             hr_utility.set_location('l_next_assignment_action_id.= '||l_next_assignment_action_id,20);
             hr_utility.set_location('csr_rec.assignment_id.......= '||csr_rec.assignment_id,20);
             hr_utility.set_location('csr_rec.tax_unit_id.........= '||csr_rec.tax_unit_id,20);
             end if;

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


               END LOOP; /* Loop 2 */
            if g_debug then
            hr_utility.set_location('Leaving............Loop2 ,Org + Run....' || l_procedure,1000);
            end if;
        end if; /* End of Inner Organization  */
    else      /* Not Org,check for others */

    if g_parameters.legal_employer is not null
    then
       if g_parameters.start_date is not null and g_parameters.end_date is not null
       then
                 IF g_debug THEN
                   hr_utility.set_location('Using Range Person Cursor for fetching assignments',30);
                 END IF;
            FOR csr_rec in rg_csr_assignment_legal_period(p_payroll_action_id,
                                                 p_chunk,
                                                 g_parameters.employee_type,
                                                 g_parameters.business_group_id,
                                                 g_parameters.legal_employer,
                                                 g_parameters.start_date,
                                                 g_parameters.end_date)
            LOOP /*Loop 3 Leg Employer,Archive Start date,archive end date*/
            /*Bug 3935471 - IF Condition used to archive all master actions and only those child actions which have tax unit id not same as master*/

                 IF csr_rec.master_action_id IS NULL OR (csr_rec.tax_unit_id <> csr_rec.master_tax_unit_id AND csr_rec.master_action_id IS NOT NULL) THEN
               open csr_next_action_id;
                 fetch  csr_next_action_id into l_next_assignment_action_id;
                 close csr_next_action_id;
                 if g_debug then
                 hr_utility.set_location('p_payroll_action_id.........= '||p_payroll_action_id,20);
                 hr_utility.set_location('l_next_assignment_action_id.= '||l_next_assignment_action_id,20);
                 hr_utility.set_location('csr_rec.assignment_id.......= '||csr_rec.assignment_id,20);
                 hr_utility.set_location('csr_rec.tax_unit_id.........= '||csr_rec.tax_unit_id,20);
                 end if;

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

            END IF;
            END LOOP;/* Loop 3 */
            if g_debug then
            hr_utility.set_location('Leaving............Loop3.Legal Emp + period...' || l_procedure,1000);
            end if;

       else
                 IF g_debug THEN
                   hr_utility.set_location('Using Range Person Cursor for fetching assignments',30);
                 END IF;
               FOR csr_rec in rg_csr_assignment_legal_run(p_payroll_action_id,
                                                 p_chunk,
                                                 g_parameters.employee_type,
                                                 g_parameters.business_group_id,
                                                 g_parameters.legal_employer,
                                                 g_parameters.period_end_date,
                                                 g_parameters.pact_id)
               LOOP /*Loop 4 Leg employer,pact_id + period end date */
            /*Bug 3935471 - IF Condition used to archive all master actions and only those child actions which have tax unit id not same as master*/

                 IF csr_rec.master_action_id IS NULL OR (csr_rec.tax_unit_id <> csr_rec.master_tax_unit_id AND csr_rec.master_action_id IS NOT NULL) THEN
                     open csr_next_action_id;
                    fetch  csr_next_action_id into l_next_assignment_action_id;
                    close csr_next_action_id;

                     if g_debug then
                             hr_utility.set_location('p_payroll_action_id.........= '||p_payroll_action_id,20);
                      hr_utility.set_location('l_next_assignment_action_id.= '||l_next_assignment_action_id,20);
                        hr_utility.set_location('csr_rec.assignment_id.......= '||csr_rec.assignment_id,20);
                      hr_utility.set_location('csr_rec.tax_unit_id.........= '||csr_rec.tax_unit_id,20);
                     end if;

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

                  END IF;
               END LOOP; /* Loop 4 */
            if g_debug then
            hr_utility.set_location('Leaving............Loop4.Legal Emp + Run...' || l_procedure,1000);
            end if;
        end if; /* End of Inner Legal Employer  */
    else /* Not Org,Legal Emp Check others */

    if g_parameters.payroll_id is not null
    then
       if g_parameters.start_date is not null and g_parameters.end_date is not null
       then
                 IF g_debug THEN
                   hr_utility.set_location('Using Range Person Cursor for fetching assignments',30);
                 END IF;
            FOR csr_rec in rg_assignment_payroll_period(p_payroll_action_id,
                                                 p_chunk,
                                                 g_parameters.employee_type,
                                                 g_parameters.business_group_id,
                                                 g_parameters.payroll_id,
                                                 g_parameters.start_date,
                                                 g_parameters.end_date)
            LOOP /*Loop 5 Payroll, Archive start date,end date */
                 open csr_next_action_id;
             fetch  csr_next_action_id into l_next_assignment_action_id;
             close csr_next_action_id;

             if g_debug then
             hr_utility.set_location('p_payroll_action_id.........= '||p_payroll_action_id,20);
             hr_utility.set_location('l_next_assignment_action_id.= '||l_next_assignment_action_id,20);
             hr_utility.set_location('csr_rec.assignment_id.......= '||csr_rec.assignment_id,20);
             hr_utility.set_location('csr_rec.tax_unit_id.........= '||csr_rec.tax_unit_id,20);
             end if;

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


            END LOOP;/* Loop 5 */

            if g_debug then
            hr_utility.set_location('Leaving............Loop5 Payroll + Period....' || l_procedure,1000);
            end if;

       else
                 IF g_debug THEN
                   hr_utility.set_location('Using Range Person Cursor for fetching assignments',30);
                 END IF;
               FOR csr_rec in rg_csr_assignment_payroll_run(p_payroll_action_id,
                                                 p_chunk,
                                                 g_parameters.employee_type,
                                                 g_parameters.business_group_id,
                                                 g_parameters.payroll_id,
                                                 g_parameters.period_end_date,
                                                 g_parameters.pact_id)
               LOOP /*Loop 6 Payroll, pact_id + period end date*/
                 open csr_next_action_id;
             fetch  csr_next_action_id into l_next_assignment_action_id;
             close csr_next_action_id;

             if g_debug then
             hr_utility.set_location('p_payroll_action_id.........= '||p_payroll_action_id,20);
             hr_utility.set_location('l_next_assignment_action_id.= '||l_next_assignment_action_id,20);
             hr_utility.set_location('csr_rec.assignment_id.......= '||csr_rec.assignment_id,20);
             hr_utility.set_location('csr_rec.tax_unit_id.........= '||csr_rec.tax_unit_id,20);
             end if;

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


               END LOOP; /* Loop 6 */
            if g_debug then
            hr_utility.set_location('Leaving............Loop6 Payroll+ Run....' || l_procedure,1000);
            end if;
        end if; /* End of Inner Payroll */
    else /* Not Org,Legal,Payroll check others */

    if g_parameters.assignment_id is not null
    then
         if g_parameters.start_date is not null and g_parameters.end_date is not null
            then
                   IF g_debug THEN
                     hr_utility.set_location('Using Range Person Cursor for fetching assignments',30);
                   END IF;
                 FOR csr_rec in rg_csr_assignment_period(p_payroll_action_id,
                                                         p_chunk,
                                                         g_parameters.employee_type,
                                                         g_parameters.business_group_id,
                                                         g_parameters.assignment_id,
                                                         g_parameters.start_date,
                                                         g_parameters.end_date)
                 LOOP /*Loop 7 Assignment ,Archive start date,end date*/
                      open csr_next_action_id;
                     fetch  csr_next_action_id into l_next_assignment_action_id;
                     close csr_next_action_id;

                  if g_debug then
                     hr_utility.set_location('p_payroll_action_id.........= '||p_payroll_action_id,20);
                     hr_utility.set_location('l_next_assignment_action_id.= '||l_next_assignment_action_id,20);
                     hr_utility.set_location('csr_rec.assignment_id.......= '||csr_rec.assignment_id,20);
                     hr_utility.set_location('csr_rec.tax_unit_id.........= '||csr_rec.tax_unit_id,20);
                  end if;

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


                 END LOOP;/* Loop 7 */
                 if g_debug then
                 hr_utility.set_location('Leaving............Loop7. Asg + Period...' || l_procedure,1000);
                 end if;

            else
                    IF g_debug THEN
                      hr_utility.set_location('Using Range Person Cursor for fetching assignments',30);
                     END IF;
                    FOR csr_rec in rg_csr_assignment_run(p_payroll_action_id,
                                                         p_chunk,
                                                         g_parameters.employee_type,
                                                         g_parameters.business_group_id,
                                                         g_parameters.assignment_id,
                                                         g_parameters.period_end_date,
                                                         g_parameters.pact_id)
                    LOOP /*Loop 8 Assignment Pact_id,Period end date */
                     open csr_next_action_id;
                     fetch  csr_next_action_id into l_next_assignment_action_id;
                     close csr_next_action_id;

                     if g_debug then
                     hr_utility.set_location('p_payroll_action_id.........= '||p_payroll_action_id,20);
                     hr_utility.set_location('l_next_assignment_action_id.= '||l_next_assignment_action_id,20);
                     hr_utility.set_location('csr_rec.assignment_id.......= '||csr_rec.assignment_id,20);
                     hr_utility.set_location('csr_rec.tax_unit_id.........= '||csr_rec.tax_unit_id,20);
                     end if;

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


                    END LOOP; /* Loop 8 */
                 if g_debug then
                 hr_utility.set_location('Leaving............Loop8.Asg + Run...' || l_procedure,1000);
                 end if;
             end if; /* End of Inner Assignment */

    else

    /* Default Begins */

       if g_parameters.start_date is not null and g_parameters.end_date is not null
       then
                 IF g_debug THEN
                   hr_utility.set_location('Using Range Person Cursor for fetching assignments',30);
                 END IF;
            FOR csr_rec in rg_assignment_default_period(p_payroll_action_id,
                                                 p_chunk,
                                                 g_parameters.employee_type,
                                                 g_parameters.business_group_id,
                                                 g_parameters.start_date,
                                                 g_parameters.end_date)
            LOOP /*Loop 9*/
             open csr_next_action_id;
             fetch  csr_next_action_id into l_next_assignment_action_id;
             close csr_next_action_id;

             if g_debug then
             hr_utility.set_location('p_payroll_action_id.........= '||p_payroll_action_id,20);
             hr_utility.set_location('l_next_assignment_action_id.= '||l_next_assignment_action_id,20);
             hr_utility.set_location('csr_rec.assignment_id.......= '||csr_rec.assignment_id,20);
             hr_utility.set_location('csr_rec.tax_unit_id.........= '||csr_rec.tax_unit_id,20);
             end if;

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


            END LOOP;/* Loop 9 */
            if g_debug then
            hr_utility.set_location('Leaving............Loop9..Default + Period..' || l_procedure,1000);
            end if;

       else
                 IF g_debug THEN
                   hr_utility.set_location('Using Range Person Cursor for fetching assignments',30);
                 END IF;
               FOR csr_rec in rg_csr_assignment_default_run(p_payroll_action_id,
                                                 p_chunk,
                                                 g_parameters.employee_type,
                                                 g_parameters.business_group_id,
                                                 g_parameters.period_end_date,
                                                 g_parameters.pact_id)
               LOOP /*Loop 10 */
                 open csr_next_action_id;
             fetch  csr_next_action_id into l_next_assignment_action_id;
             close csr_next_action_id;

             if g_debug then
             hr_utility.set_location('p_payroll_action_id.........= '||p_payroll_action_id,20);
             hr_utility.set_location('l_next_assignment_action_id.= '||l_next_assignment_action_id,20);
             hr_utility.set_location('csr_rec.assignment_id.......= '||csr_rec.assignment_id,20);
             hr_utility.set_location('csr_rec.tax_unit_id.........= '||csr_rec.tax_unit_id,20);
             end if;

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


               END LOOP; /* Loop 10 */
            if g_debug then
            hr_utility.set_location('Leaving............Loop10 Default + Run....' || l_procedure,1000);
            end if;
        end if; /* End of Inner Default */


    end if ;/*End Assignment id */
    end if ; /* End Payroll */
    end if; /* End Legal */
end if; /* End Organization */

ELSE /* 9113084 - Use Old Logic when RANGE_PERSON_ID is disabled */

    if g_parameters.org_id is not null
    then
       if g_parameters.start_date is not null and g_parameters.end_date is not null
       then
            FOR csr_rec in csr_assignment_org_period(p_payroll_action_id,
            					 p_start_person,
            					 p_end_person,
            					 g_parameters.employee_type,
            					 g_parameters.business_group_id,
            					 g_parameters.org_id,
            					 g_parameters.start_date,
            					 g_parameters.end_date)
            LOOP /*Loop 1 Org,Archive start date,end date */
             open csr_next_action_id;
    	     fetch  csr_next_action_id into l_next_assignment_action_id;
    	     close csr_next_action_id;

    	      if g_debug then

    	           hr_utility.set_location('p_payroll_action_id.........= '||p_payroll_action_id,20);
	           hr_utility.set_location('l_next_assignment_action_id.= '||l_next_assignment_action_id,20);
	           hr_utility.set_location('csr_rec.assignment_id.......= '||csr_rec.assignment_id,20);
	           hr_utility.set_location('csr_rec.tax_unit_id.........= '||csr_rec.tax_unit_id,20);

	      end if;



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


            END LOOP;/* Loop 1 */
            if g_debug then
            hr_utility.set_location('Leaving............Loop1 Org+Period....' || l_procedure,1000);
            end if;

       else
               FOR csr_rec in csr_assignment_org_run(p_payroll_action_id,
               					 p_start_person,
               					 p_end_person,
               					 g_parameters.employee_type,
               					 g_parameters.business_group_id,
               					 g_parameters.org_id,
               					 g_parameters.period_end_date,
               					 g_parameters.pact_id)
               LOOP /*Loop 2 Org,Pact_id and period end date*/
                 open csr_next_action_id;
       	     fetch  csr_next_action_id into l_next_assignment_action_id;
       	     close csr_next_action_id;

       	     if g_debug then
       	     hr_utility.set_location('p_payroll_action_id.........= '||p_payroll_action_id,20);
       	     hr_utility.set_location('l_next_assignment_action_id.= '||l_next_assignment_action_id,20);
       	     hr_utility.set_location('csr_rec.assignment_id.......= '||csr_rec.assignment_id,20);
       	     hr_utility.set_location('csr_rec.tax_unit_id.........= '||csr_rec.tax_unit_id,20);
       	     end if;

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


               END LOOP; /* Loop 2 */
            if g_debug then
            hr_utility.set_location('Leaving............Loop2 ,Org + Run....' || l_procedure,1000);
            end if;
        end if; /* End of Inner Organization  */
    else      /* Not Org,check for others */

    if g_parameters.legal_employer is not null
    then
       if g_parameters.start_date is not null and g_parameters.end_date is not null
       then
            FOR csr_rec in csr_assignment_legal_period(p_payroll_action_id,
            					 p_start_person,
            					 p_end_person,
            					 g_parameters.employee_type,
            					 g_parameters.business_group_id,
            					 g_parameters.legal_employer,
            					 g_parameters.start_date,
            					 g_parameters.end_date)
            LOOP /*Loop 3 Leg Employer,Archive Start date,archive end date*/
            /*Bug 3935471 - IF Condition used to archive all master actions and only those child actions which have tax unit id not same as master*/

 	         IF csr_rec.master_action_id IS NULL OR (csr_rec.tax_unit_id <> csr_rec.master_tax_unit_id AND csr_rec.master_action_id IS NOT NULL) THEN
               open csr_next_action_id;
    	         fetch  csr_next_action_id into l_next_assignment_action_id;
    	         close csr_next_action_id;
    	         if g_debug then
    	         hr_utility.set_location('p_payroll_action_id.........= '||p_payroll_action_id,20);
    	         hr_utility.set_location('l_next_assignment_action_id.= '||l_next_assignment_action_id,20);
    	         hr_utility.set_location('csr_rec.assignment_id.......= '||csr_rec.assignment_id,20);
    	         hr_utility.set_location('csr_rec.tax_unit_id.........= '||csr_rec.tax_unit_id,20);
    	         end if;

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

            END IF;
            END LOOP;/* Loop 3 */
            if g_debug then
            hr_utility.set_location('Leaving............Loop3.Legal Emp + period...' || l_procedure,1000);
            end if;

       else
               FOR csr_rec in csr_assignment_legal_run(p_payroll_action_id,
               					 p_start_person,
               					 p_end_person,
               					 g_parameters.employee_type,
               					 g_parameters.business_group_id,
               					 g_parameters.legal_employer,
               					 g_parameters.period_end_date,
               					 g_parameters.pact_id)
               LOOP /*Loop 4 Leg employer,pact_id + period end date */
            /*Bug 3935471 - IF Condition used to archive all master actions and only those child actions which have tax unit id not same as master*/

       	         IF csr_rec.master_action_id IS NULL OR (csr_rec.tax_unit_id <> csr_rec.master_tax_unit_id AND csr_rec.master_action_id IS NOT NULL) THEN
                     open csr_next_action_id;
       	            fetch  csr_next_action_id into l_next_assignment_action_id;
       	            close csr_next_action_id;

             	     if g_debug then
                 	     hr_utility.set_location('p_payroll_action_id.........= '||p_payroll_action_id,20);
       	              hr_utility.set_location('l_next_assignment_action_id.= '||l_next_assignment_action_id,20);
              	        hr_utility.set_location('csr_rec.assignment_id.......= '||csr_rec.assignment_id,20);
       	              hr_utility.set_location('csr_rec.tax_unit_id.........= '||csr_rec.tax_unit_id,20);
             	     end if;

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

                  END IF;
               END LOOP; /* Loop 4 */
            if g_debug then
            hr_utility.set_location('Leaving............Loop4.Legal Emp + Run...' || l_procedure,1000);
            end if;
        end if; /* End of Inner Legal Employer  */
    else /* Not Org,Legal Emp Check others */

    if g_parameters.payroll_id is not null
    then
       if g_parameters.start_date is not null and g_parameters.end_date is not null
       then
            FOR csr_rec in csr_assignment_payroll_period(p_payroll_action_id,
            					 p_start_person,
            					 p_end_person,
            					 g_parameters.employee_type,
            					 g_parameters.business_group_id,
            					 g_parameters.payroll_id,
            					 g_parameters.start_date,
            					 g_parameters.end_date)
            LOOP /*Loop 5 Payroll, Archive start date,end date */
                 open csr_next_action_id;
    	     fetch  csr_next_action_id into l_next_assignment_action_id;
    	     close csr_next_action_id;

    	     if g_debug then
    	     hr_utility.set_location('p_payroll_action_id.........= '||p_payroll_action_id,20);
    	     hr_utility.set_location('l_next_assignment_action_id.= '||l_next_assignment_action_id,20);
    	     hr_utility.set_location('csr_rec.assignment_id.......= '||csr_rec.assignment_id,20);
    	     hr_utility.set_location('csr_rec.tax_unit_id.........= '||csr_rec.tax_unit_id,20);
    	     end if;

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


            END LOOP;/* Loop 5 */

            if g_debug then
            hr_utility.set_location('Leaving............Loop5 Payroll + Period....' || l_procedure,1000);
            end if;

       else
               FOR csr_rec in csr_assignment_payroll_run(p_payroll_action_id,
               					 p_start_person,
               					 p_end_person,
               					 g_parameters.employee_type,
               					 g_parameters.business_group_id,
               					 g_parameters.payroll_id,
               					 g_parameters.period_end_date,
               					 g_parameters.pact_id)
               LOOP /*Loop 6 Payroll, pact_id + period end date*/
                 open csr_next_action_id;
       	     fetch  csr_next_action_id into l_next_assignment_action_id;
       	     close csr_next_action_id;

       	     if g_debug then
	     hr_utility.set_location('p_payroll_action_id.........= '||p_payroll_action_id,20);
       	     hr_utility.set_location('l_next_assignment_action_id.= '||l_next_assignment_action_id,20);
       	     hr_utility.set_location('csr_rec.assignment_id.......= '||csr_rec.assignment_id,20);
       	     hr_utility.set_location('csr_rec.tax_unit_id.........= '||csr_rec.tax_unit_id,20);
       	     end if;

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


               END LOOP; /* Loop 6 */
            if g_debug then
            hr_utility.set_location('Leaving............Loop6 Payroll+ Run....' || l_procedure,1000);
            end if;
        end if; /* End of Inner Payroll */
    else /* Not Org,Legal,Payroll check others */

    if g_parameters.assignment_id is not null
    then
         if g_parameters.start_date is not null and g_parameters.end_date is not null
            then
                 FOR csr_rec in csr_assignment_period(p_payroll_action_id,
                 					 p_start_person,
                 					 p_end_person,
                 					 g_parameters.employee_type,
                 					 g_parameters.business_group_id,
                 					 g_parameters.assignment_id,
                 					 g_parameters.start_date,
                 					 g_parameters.end_date)
                 LOOP /*Loop 7 Assignment ,Archive start date,end date*/
                      open csr_next_action_id;
         	     fetch  csr_next_action_id into l_next_assignment_action_id;
         	     close csr_next_action_id;

		  if g_debug then
         	     hr_utility.set_location('p_payroll_action_id.........= '||p_payroll_action_id,20);
         	     hr_utility.set_location('l_next_assignment_action_id.= '||l_next_assignment_action_id,20);
         	     hr_utility.set_location('csr_rec.assignment_id.......= '||csr_rec.assignment_id,20);
         	     hr_utility.set_location('csr_rec.tax_unit_id.........= '||csr_rec.tax_unit_id,20);
         	  end if;

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


                 END LOOP;/* Loop 7 */
                 if g_debug then
                 hr_utility.set_location('Leaving............Loop7. Asg + Period...' || l_procedure,1000);
                 end if;

            else
                    FOR csr_rec in csr_assignment_run(p_payroll_action_id,
                    					 p_start_person,
                    					 p_end_person,
                    					 g_parameters.employee_type,
                    					 g_parameters.business_group_id,
                    					 g_parameters.assignment_id,
                    					 g_parameters.period_end_date,
                    					 g_parameters.pact_id)
                    LOOP /*Loop 8 Assignment Pact_id,Period end date */
                     open csr_next_action_id;
            	     fetch  csr_next_action_id into l_next_assignment_action_id;
            	     close csr_next_action_id;

            	     if g_debug then
            	     hr_utility.set_location('p_payroll_action_id.........= '||p_payroll_action_id,20);
            	     hr_utility.set_location('l_next_assignment_action_id.= '||l_next_assignment_action_id,20);
            	     hr_utility.set_location('csr_rec.assignment_id.......= '||csr_rec.assignment_id,20);
            	     hr_utility.set_location('csr_rec.tax_unit_id.........= '||csr_rec.tax_unit_id,20);
            	     end if;

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


                    END LOOP; /* Loop 8 */
                 if g_debug then
                 hr_utility.set_location('Leaving............Loop8.Asg + Run...' || l_procedure,1000);
                 end if;
             end if; /* End of Inner Assignment */

    else

    /* Default Begins */

       if g_parameters.start_date is not null and g_parameters.end_date is not null
       then
            FOR csr_rec in csr_assignment_default_period(p_payroll_action_id,
            					 p_start_person,
            					 p_end_person,
            					 g_parameters.employee_type,
            					 g_parameters.business_group_id,
            					 g_parameters.start_date,
            					 g_parameters.end_date)
            LOOP /*Loop 9*/
             open csr_next_action_id;
    	     fetch  csr_next_action_id into l_next_assignment_action_id;
    	     close csr_next_action_id;

    	     if g_debug then
    	     hr_utility.set_location('p_payroll_action_id.........= '||p_payroll_action_id,20);
    	     hr_utility.set_location('l_next_assignment_action_id.= '||l_next_assignment_action_id,20);
    	     hr_utility.set_location('csr_rec.assignment_id.......= '||csr_rec.assignment_id,20);
    	     hr_utility.set_location('csr_rec.tax_unit_id.........= '||csr_rec.tax_unit_id,20);
    	     end if;

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


            END LOOP;/* Loop 9 */
            if g_debug then
            hr_utility.set_location('Leaving............Loop9..Default + Period..' || l_procedure,1000);
            end if;

       else
               FOR csr_rec in csr_assignment_default_run(p_payroll_action_id,
               					 p_start_person,
               					 p_end_person,
               					 g_parameters.employee_type,
               					 g_parameters.business_group_id,
               					 g_parameters.period_end_date,
               					 g_parameters.pact_id)
               LOOP /*Loop 10 */
                 open csr_next_action_id;
       	     fetch  csr_next_action_id into l_next_assignment_action_id;
       	     close csr_next_action_id;

       	     if g_debug then
       	     hr_utility.set_location('p_payroll_action_id.........= '||p_payroll_action_id,20);
       	     hr_utility.set_location('l_next_assignment_action_id.= '||l_next_assignment_action_id,20);
       	     hr_utility.set_location('csr_rec.assignment_id.......= '||csr_rec.assignment_id,20);
       	     hr_utility.set_location('csr_rec.tax_unit_id.........= '||csr_rec.tax_unit_id,20);
       	     end if;

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


               END LOOP; /* Loop 10 */
            if g_debug then
            hr_utility.set_location('Leaving............Loop10 Default + Run....' || l_procedure,1000);
            end if;
        end if; /* End of Inner Default */


    end if ;/*End Assignment id */
    end if ; /* End Payroll */
    end if; /* End Legal */
end if; /* End Organization */

END IF;

exception
    when others then
      hr_utility.set_location('Error in '||l_procedure,999999);
      raise;
end assignment_action_code;

procedure archive_code
  (p_assignment_action_id  in pay_assignment_actions.assignment_action_id%type
  ,p_effective_date        in pay_payroll_actions.effective_date%type
  ) is

 /* Bug 3873942
    Cursor c_employee_details - Added join with table per_grades_tl to fetch and archive the grade name.
    Outer Join introduced between per_grades_tl and per_assignments_f based on grade_id.
 */

 cursor c_employee_details(c_business_group_id hr_all_organization_units.organization_id%TYPE,
   	                    c_assignment_id number,c_end_date date, c_start_date date) /*Bug#3662449 c_start_date parameter added*/
  is
  select pap.full_name,
    	 paa.assignment_number,
	 paa.assignment_id,
	 paa.organization_id,
	 hou.NAME organization_name, /*Bug 4132525*/
--	 paa.payroll_id, /*Bug 4688800*/
--	 papf.payroll_name, /*Bug 4132525, Bug 4688800*/
	 hsc.segment1 tax_unit_id, /*Bug 4040688*/
	 hou1.NAME Legal_Employer /*Bug 4132525*/
  from  per_people_f pap,
       	per_assignments_f paa,
	hr_soft_coding_keyflex hsc, /*Bug 4040688*/
	hr_all_organization_units hou, /*Bug 4132525*/
	hr_all_organization_units hou1 /*Bug 4132525*/
--        pay_payrolls_f papf /*Bug 4132525, Bug 4688800*/
  where  pap.person_id = paa.person_id
  and    paa.assignment_id = c_assignment_id
  and    paa.business_group_id = c_business_group_id
  AND    hsc.soft_coding_keyflex_id = paa.soft_coding_keyflex_id   /*Bug 4040688*/
  AND    hou.organization_id = paa.organization_id /*Bug 4132525*/
  AND    hou1.organization_id = hsc.segment1 /*Bug 4132525*/
--  AND    papf.payroll_id = paa.payroll_id /*Bug 4132525, Bug 4688800*/
--  AND    c_end_date BETWEEN papf.effective_start_date AND papf.effective_end_date /*Bug 4132525, Bug 4688800*/
  and    paa.effective_end_date = ( select max(effective_end_date) /*Bug#3662449 sub query added*/
                                    from  per_assignments_f
                                    WHERE assignment_id  =  c_assignment_id
                                    and effective_end_date >= c_start_date
                                    and effective_start_date <= c_end_date)
  and   c_end_date between pap.effective_start_date and pap.effective_end_date;


/*Bug# 4688800 - Introduced a new cursor to get the payroll name for the employee. This has been done to take care of cases
                    where assignment has payroll attached to it for few months but is not attached at the end of year*/
 CURSOR c_get_payroll_name(c_assignment_id number,c_end_date date, c_start_date date)
 IS
 SELECT paaf.payroll_id, pay.payroll_name
 FROM per_all_assignments_f        paaf,
      pay_payrolls_f               pay
 WHERE paaf.assignment_id = c_assignment_id
 and   paaf.effective_end_date = (select max(effective_end_date)
   	                           From  per_assignments_f iipaf
				                     WHERE iipaf.assignment_id  = c_assignment_id
				                     and iipaf.effective_end_date >= c_start_date
				                     and iipaf.effective_start_date <= c_end_date
                                 AND iipaf.payroll_id IS NOT NULL)
 AND  pay.payroll_id = paaf.payroll_id
 AND  paaf.effective_end_date BETWEEN pay.effective_start_date AND pay.effective_end_date;

    cursor csr_get_data (c_arc_ass_act_id number)
    is
    select pai.action_information1, pai.tax_unit_id, pai.assignment_id,pai.action_information3
    from pay_action_information pai
    where action_information_category = 'AU_ARCHIVE_ASG_DETAILS'
    and  pai.action_context_id = c_arc_ass_act_id;

/*Bug 4040688 - Two cursors introduced to get the maximum assignment action id for the assignment*/
    cursor csr_get_max_asg_dates (c_assignment_id number,
                                   c_start_date DATE,
				   c_end_date DATE,
				   c_tax_unit_id number)
    is
    select  to_number(substr(max(lpad(paa.action_sequence,15,'0')||paa.assignment_action_id),16))
            ,max(paa.action_sequence)
    from    pay_assignment_actions      paa
    ,       pay_payroll_actions         ppa
	,       per_assignments_f           paf
    where   paa.assignment_id           = paf.assignment_id
	and     paf.assignment_id           = c_assignment_id
            and ppa.payroll_action_id   = paa.payroll_action_id
            and ppa.effective_date      between c_start_date and c_end_date
	    and ppa.payroll_id        =  paf.payroll_id
            and ppa.action_type        in ('R', 'Q', 'I', 'V', 'B')
	    and ppa.effective_date between paf.effective_start_date and paf.effective_end_date
            and paa.action_status='C'
	    AND paa.tax_unit_id = nvl(c_tax_unit_id, paa.tax_unit_id);


    cursor csr_get_max_asg_action (c_assignment_id number,
                                   c_payroll_action_id number,
				   c_tax_unit_id number)
    is
    select  to_number(substr(max(lpad(paa.action_sequence,15,'0')||paa.assignment_action_id),16))
            ,max(paa.action_sequence)
    from    pay_assignment_actions      paa
    ,       pay_payroll_actions         ppa
	,       per_assignments_f           paf
    where   paa.assignment_id           = paf.assignment_id
	and     paf.assignment_id           = c_assignment_id
            and ppa.payroll_action_id   = paa.payroll_action_id
            and ppa.payroll_action_id      = c_payroll_action_id
	    and ppa.payroll_id        =  paf.payroll_id
            and ppa.action_type        in ('R', 'Q', 'I', 'V', 'B')
	    and ppa.effective_date between paf.effective_start_date and paf.effective_end_date
            and paa.action_status='C'
	    AND paa.tax_unit_id = nvl(c_tax_unit_id, paa.tax_unit_id);

/*Bug 4040688 - end of modification*/

    l_procedure                       varchar2(200);
    l_action_information_id    	    number;
    l_object_version_number	    number;

    l_TAXABLE_EARNINGS                number;
    l_GROSS_EARNINGS		    number;
    l_PRE_TAX_DEDUCTIONS            number;
    l_DIRECT_PAYMENTS               number;
    l_NON_TAXABLE_EARNINGS    	    number;
    l_DEDUCTIONS          	    number;
    l_TAX                             number;
    l_NET_PAYMENT           	    number;
    l_EMPLOYER_CHARGES		    number;

    l_YTD_TAXABLE_EARNINGS            number;
    l_YTD_NON_TAXABLE_EARNINGS        number;
    l_YTD_GROSS_EARNINGS		    number;
    l_YTD_PRE_TAX_DEDUCTIONS            number;
    l_YTD_DIRECT_PAYMENTS               number;
    l_YTD_DEDUCTIONS          	    number;
    l_YTD_TAX                         number;
    l_YTD_NET_PAYMENT           	    number;
    l_YTD_EMPLOYER_CHARGES	    number;

    l_ass_act_id 		    number;
    l_tax_unit_id 	   number;
    l_assignment_id 		number;

    l_action_sequence      number;
    l_max_asg_action_id number; /*Bug 4040688*/
    l_max_action_sequence  number; /*Bug 4040688*/

    l_payroll_id           number;     /*Bug 4688800*/
    l_payroll_name         pay_payrolls_f.payroll_name%type;     /*Bug 4688800*/

begin

    g_debug :=hr_utility.debug_enabled ;

    l_YTD_GROSS_EARNINGS := 0;
    l_YTD_NON_TAXABLE_EARNINGS := 0;
    l_YTD_PRE_TAX_DEDUCTIONS := 0;
    l_YTD_TAXABLE_EARNINGS := 0;
    l_YTD_TAX		 := 0;
    l_YTD_DEDUCTIONS := 0;
    l_YTD_DIRECT_PAYMENTS := 0;
    l_YTD_NET_PAYMENT := 0;
    l_YTD_EMPLOYER_CHARGES := 0;

    if g_debug then
    g_package := 'pay_au_reconciliation_pkg.' ;
    l_procedure  := g_package||'archive_code';
    hr_utility.set_location('Entering '||l_procedure,1);
    hr_utility.set_location('p_assignment_action_id......= '|| p_assignment_action_id,10);
    hr_utility.set_location('p_effective_date............= '|| to_char(p_effective_date,'DD-MON-YYYY'),10);
    end if;

    OPEN csr_get_data(p_assignment_action_id);
    FETCH csr_get_data into l_ass_act_id, l_tax_unit_id, l_assignment_id,l_action_sequence;
    CLOSE csr_get_data;

    if g_debug then
    hr_utility.set_location('l_ass_act_id......= '|| l_ass_act_id,10);
    hr_utility.set_location('l_tax_unit_id............= '|| l_tax_unit_id,10);
    hr_utility.set_location('l_assignment_id......= '|| l_assignment_id,10);
    end if;

 FOR csr_rec in c_employee_details(g_business_group_id,l_assignment_id,g_end_date,g_start_date) --Bug#3662449
 LOOP

     if g_debug then
     hr_utility.set_location('csr_rec.full_name............= '|| csr_rec.full_name,10);
     end if;


     IF (NVL(g_prev_assignment_id,0) <> csr_rec.assignment_id) THEN
     	g_prev_assignment_id := csr_rec.assignment_id;

/*Bug 4040688 - Calling the cursor to get maximum assignment action id*/
	IF g_parameters.pact_id IS NULL THEN
	  OPEN csr_get_max_asg_dates(csr_rec.assignment_id, g_start_date, g_end_date, g_parameters.legal_employer);
          FETCH csr_get_max_asg_dates INTO l_max_asg_action_id, l_max_action_sequence;
	  CLOSE csr_get_max_asg_dates;
	ELSE
  	  OPEN csr_get_max_asg_action(csr_rec.assignment_id, g_parameters.pact_id, g_parameters.legal_employer);
          FETCH csr_get_max_asg_action INTO l_max_asg_action_id, l_max_action_sequence;
	  CLOSE csr_get_max_asg_action;
	END IF ;

 -- Archive YTD balance details
       	   /*Bug 3953706 - Modfied the call to procedure introduce new parameters*/
	   /*Bug 4040688 - YTD Balances will be called for the maximum assignment action id of the assignment*/

	 IF l_max_asg_action_id IS NOT NULL THEN
            pay_au_reconciliation_pkg.GET_YTD_AU_REC_BALANCES(
                 P_ASSIGNMENT_ACTION_ID         => l_max_asg_action_id,
		 P_REGISTERED_EMPLOYER          => g_parameters.legal_employer, --2610141
		 P_YTD_GROSS_EARNINGS		=> l_YTD_GROSS_EARNINGS,
              	 P_YTD_NON_TAXABLE_EARNINGS	=> l_YTD_NON_TAXABLE_EARNINGS,
		 P_YTD_PRE_TAX_DEDUCTIONS	=> l_YTD_PRE_TAX_DEDUCTIONS,
             	 P_YTD_TAXABLE_EARNINGS		=> l_YTD_TAXABLE_EARNINGS,
              	 P_YTD_TAX			=> l_YTD_TAX		,
              	 P_YTD_DEDUCTIONS		=> l_YTD_DEDUCTIONS	,
		 P_YTD_DIRECT_PAYMENTS		=> l_YTD_DIRECT_PAYMENTS,
                 P_YTD_NET_PAYMENT		=> l_YTD_NET_PAYMENT	,
       	         P_YTD_EMPLOYER_CHARGES		=> l_YTD_EMPLOYER_CHARGES);
          END IF ;

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
                                      action_information10)
                          values (
                                pay_action_information_s.nextval,
                                p_assignment_action_id,
             			 'AAP',
                                p_effective_date,
                                null,
             			 null,
             			 l_assignment_id,
             			 'AU_BALANCE_RECON_DETAILS_YTD',
             			 l_YTD_TAXABLE_EARNINGS,
             			 l_YTD_NON_TAXABLE_EARNINGS,
             			 l_YTD_DEDUCTIONS,
             			 l_YTD_TAX,
             			 l_YTD_NET_PAYMENT,
             			 l_YTD_EMPLOYER_CHARGES,
				 l_YTD_GROSS_EARNINGS,
				 l_YTD_PRE_TAX_DEDUCTIONS,
				 l_YTD_DIRECT_PAYMENTS,
                                 l_max_action_sequence);

/*Bug 4040688 - end of modification*/


        /*Bug 4688800*/
        OPEN c_get_payroll_name(l_assignment_id,g_end_date,g_start_date);
        FETCH c_get_payroll_name INTO l_payroll_id,l_payroll_name;
        CLOSE c_get_payroll_name;

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
			    action_information8,
			    action_information9,
			    action_information10,
			    assignment_id)
		    values(
		            pay_action_information_s.nextval,
		            g_arc_payroll_action_id,
		            'PA',
		            p_effective_date,
		            null,
		            l_tax_unit_id,
		            'AU_EMPLOYEE_RECON_DETAILS',
		            csr_rec.full_name,
		            csr_rec.assignment_number,
		            csr_rec.organization_name, /*Bug 4132525*/
		            csr_rec.Legal_Employer, /*Bug 4040688, Bug 4132525*/
		            l_payroll_name, /*Bug 4132525,  Bug 4688800*/
		            l_assignment_id);
     END IF;
          -- Balances Coding for BBR

            -- Get The Action Sequence for the Assignment_Action_Id.

	   /*Bug 3891564 - Modfied the call to procedure introduce new parameters*/
            pay_au_reconciliation_pkg.GET_AU_REC_BALANCES(
                 P_ASSIGNMENT_ACTION_ID         => l_ass_act_id,
		 P_REGISTERED_EMPLOYER          => g_parameters.legal_employer,
		 P_GROSS_EARNINGS		=> l_GROSS_EARNINGS,
             	 P_NON_TAXABLE_EARNINGS         => l_NON_TAXABLE_EARNINGS,
		 P_PRE_TAX_DEDUCTIONS		=> l_PRE_TAX_DEDUCTIONS,
                 P_TAXABLE_EARNINGS             => l_TAXABLE_EARNINGS    ,
             	 P_TAX                          => l_TAX                 ,
             	 P_DEDUCTIONS                   => l_DEDUCTIONS          ,
		 P_DIRECT_PAYMENTS		=> l_DIRECT_PAYMENTS,
             	 P_NET_PAYMENT                  => l_NET_PAYMENT         ,
             	 P_EMPLOYER_CHARGES             => l_EMPLOYER_CHARGES);

           --
           -- Insert the balance data into pay_action_information table
           -- This Direct Insert statement is for Performance Reasons.
           --
             /*Bug 4040688 - Modified contexts which will store only the run balance values.*/
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
                                      action_information10)
                          values (
                                pay_action_information_s.nextval,
                                p_assignment_action_id,
             			 'AAP',
                                p_effective_date,
                                null,
             			 l_tax_unit_id,
             			 l_assignment_id,
             			 'AU_BALANCE_RECON_DETAILS_RUN',
             			 l_taxable_earnings,
             			 l_NON_TAXABLE_EARNINGS,
             			 l_DEDUCTIONS,
             			 l_TAX,
             			 l_NET_PAYMENT,
             			 l_EMPLOYER_CHARGES,
				 l_GROSS_EARNINGS,
				 l_PRE_TAX_DEDUCTIONS,
				 l_DIRECT_PAYMENTS,
                                 l_action_sequence);

 END LOOP; /* End of assignments for employee */

end archive_code;

procedure spawn_archive_reports
(p_payroll_action_id in pay_payroll_actions.payroll_action_id%type)
  is
 l_count                number;
 ps_request_id          NUMBER;
 l_print_style          VARCHAR2(2);
 l_print_together       VARCHAR2(80);
 l_print_return         BOOLEAN;
 l_procedure         varchar2(50);
 l_program_name      varchar2(50);   /* Bug 4947424 */

  --------------------------------------------------------------------+
  -- Cursor      : csr_params
  -- Description : Fetches User Parameters from Legislative_paramters
  --               column.
  --------------------------------------------------------------------+

   CURSOR csr_report_params(c_payroll_action_id  pay_payroll_actions.payroll_action_id%TYPE)
      IS
        SELECT pay_core_utils.get_parameter('PAY',legislative_parameters)        payroll_id,
                   pay_core_utils.get_parameter('ORG',legislative_parameters)           org_id,
                   pay_core_utils.get_parameter('BG',legislative_parameters)    business_group_id,
                   to_date(pay_core_utils.get_parameter('SDATE',legislative_parameters),'YYYY/MM/DD') start_date,
                   to_date(pay_core_utils.get_parameter('EDATE',legislative_parameters),'YYYY/MM/DD')   end_date,
                   pay_core_utils.get_parameter('PACTID',legislative_parameters)        pact_id,
                   pay_core_utils.get_parameter('LE',legislative_parameters) legal_employer,
                   pay_core_utils.get_parameter('ASG',legislative_parameters) assignment_id,
                   pay_core_utils.get_parameter('SO1',legislative_parameters)   sort_order_1,
                   pay_core_utils.get_parameter('SO2',legislative_parameters)   sort_order_2,
                   pay_core_utils.get_parameter('SO3',legislative_parameters)   sort_order_3,
                   pay_core_utils.get_parameter('SO4',legislative_parameters)   sort_order_4,
                   to_date(pay_core_utils.get_parameter('PEDATE',legislative_parameters),'YYYY/MM/DD') period_end_date,
                   pay_core_utils.get_parameter('YTD_TOT',legislative_parameters)      ytd_totals,
                   pay_core_utils.get_parameter('ZERO_REC',legislative_parameters)    zero_records,
                   pay_core_utils.get_parameter('NEG_REC',legislative_parameters)     negative_records,
                   pay_core_utils.get_parameter('EMP_TYPE',legislative_parameters) employee_type,
                   pay_core_utils.get_parameter('DEL_ACT',legislative_parameters) delete_actions,  /*Bug# 4142159*/
                   pay_core_utils.get_parameter('OUTPUT_TYPE',legislative_parameters) output_type  /*Bug# 4947424*/
                   FROM pay_payroll_actions ppa
      WHERE ppa.payroll_action_id  =  c_payroll_action_id;


 cursor csr_get_print_options(p_payroll_action_id NUMBER) IS
 SELECT printer,
          print_style,
          decode(save_output_flag, 'Y', 'TRUE', 'N', 'FALSE') save_output
      ,number_of_copies /* Bug 4116833*/
    FROM  pay_payroll_actions pact,
          fnd_concurrent_requests fcr
    WHERE fcr.request_id = pact.request_id
    AND   pact.payroll_action_id = p_payroll_action_id;


 rec_print_options  csr_get_print_options%ROWTYPE;

 l_parameters csr_report_params%ROWTYPE; /* Bug 3891577*/

  Begin
    l_count           :=0;
    ps_request_id     :=-1;
    g_debug :=hr_utility.debug_enabled ;


             if g_debug then
             g_package := 'pay_au_reconciliation_pkg.' ;
             l_procedure := g_package||' spawn_archive_reports';
             hr_utility.set_location('Entering '||l_procedure,999);
             end if;

-- Set User Parameters for Report.

             open csr_report_params(p_payroll_action_id);
             fetch csr_report_params into l_parameters;
             close csr_report_params;

             /*Bug 4040688 -- Moved the call to check parameters validations from report to archive code.*/
             check_report_parameters(l_parameters.start_date
                                    ,l_parameters.end_date
                                    ,l_parameters.period_end_date);

          if g_debug then
                   hr_utility.set_location('payroll_parameters.action '||p_payroll_action_id,0);
                   hr_utility.set_location('in BG_ID '||l_parameters.business_group_id,1);
                   hr_utility.set_location('in org_id '||l_parameters.org_id,2);
                   hr_utility.set_location('in payroll_parameters.id '||l_parameters.payroll_id,3);
                   hr_utility.set_location('in asg_id '||l_parameters.assignment_id,4);
                   hr_utility.set_location('in archive start date '||to_char(l_parameters.start_date,'YYYY/MM/DD'),5);
                   hr_utility.set_location('in archive end date '||to_char(l_parameters.end_date,'YYYY/MM/DD'),6);
                   hr_utility.set_location('in pact_id '||l_parameters.pact_id,7);
                   hr_utility.set_location('in legal employer '||l_parameters.legal_employer,8);
                   hr_utility.set_location('in PERIOD END DATE '||to_char(l_parameters.period_end_date,'YYYY/MM/DD'),9);
                   hr_utility.set_location('in YTD totals '||l_parameters.ytd_totals,10);
                   hr_utility.set_location('in zero records'||l_parameters.zero_records,11);
                   hr_utility.set_location('in Negative records'||l_parameters.negative_records,12);
                   hr_utility.set_location('in emp_type '||l_parameters.employee_type,14);
                   hr_utility.set_location('in sort order 1'||l_parameters.sort_order_1,15);
                   hr_utility.set_location('in sort order 2'||l_parameters.sort_order_2,16);
                   hr_utility.set_location('in sort order 3'||l_parameters.sort_order_3,17);
                   hr_utility.set_location('in sort order 4'||l_parameters.sort_order_4,18);
                   hr_utility.set_location('in delete action'||l_parameters.delete_actions,19); /*Bug# 4142159*/
                   hr_utility.set_location('in Output Type '||l_parameters.output_type,20);     /*Bug# 4947424*/
            end if;

     if g_debug then
      hr_utility.set_location('Afer payroll action ' || p_payroll_action_id , 125);

      hr_utility.set_location('Before calling report',24);
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

/* Bug 4947424 - Check for Report Output Type and choose appropriate
                 concurrent program to submit
*/
       if l_parameters.output_type = 'TEXT'
       then
            l_program_name := 'PYAURECSR_TXT';
       else
            l_program_name := 'PYAURECSR';
       end if;

/* Bug 3891577 - Added the Template Name parameter to Report.
                 This is done to enable the PDF Output for report.
    Backed out this parameter as template name is not specified here in 2-setp process.*/
ps_request_id := fnd_request.submit_request
 ('PAY',
  l_program_name,                                   /* Bug 4947424 */
   null,
   null,
   false,
   'P_PAYROLL_ACTION_ID='||to_char(p_payroll_action_id),
   'P_BUSINESS_GROUP_ID='||l_parameters.business_group_id,
   'P_ORGANIZATION_ID='||l_parameters.org_id,
   'P_PAYROLL_ID='||l_parameters.payroll_id,
   'P_REGISTERED_EMPLOYER='||l_parameters.legal_employer,
   'P_ASSIGNMENT_ID='||l_parameters.assignment_id,
   'P_START_DATE='||to_char(l_parameters.start_date,'YYYY/MM/DD'),
   'P_END_DATE='||to_char(l_parameters.end_date,'YYYY/MM/DD'),
   'P_PAYROLL_RUN_ID='||l_parameters.pact_id,
   'P_PERIOD_END_DATE='||to_char(l_parameters.period_end_date,'YYYY/MM/DD'),
   'P_EMPLOYEE_TYPE='||l_parameters.employee_type,
   'P_YTD_TOTALS='||l_parameters.ytd_totals,
   'P_ZERO_RECORDS='||l_parameters.zero_records,
   'P_NEGATIVE_RECORDS='||l_parameters.negative_records,
   'P_SORT_ORDER_1='||l_parameters.sort_order_1,
   'P_SORT_ORDER_2='||l_parameters.sort_order_2,
   'P_SORT_ORDER_3='||l_parameters.sort_order_3,
   'P_SORT_ORDER_4='||l_parameters.sort_order_4,
   'P_DELETE_ACTIONS='||l_parameters.delete_actions, /*Bug# 4142159*/
   'BLANKPAGES=NO',
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
      if g_debug then
      hr_utility.set_location('After calling report',24);
      end if;

end spawn_archive_reports;

procedure check_report_parameters
          (p_start_date        IN date,
           p_end_date          IN date,
           p_period_end_date   IN date) is

    e_bad_end_date                    exception ;
    e_bad_combination_date            exception ;

begin

   IF g_debug THEN
      hr_utility.trace('Entering:' || g_package  || 'check_report_parameters');
   END IF;

   if p_start_date is not null and p_end_date is null then
     raise e_bad_end_date;
   end if;

   if p_start_date is null and p_period_end_date is null then
     raise e_bad_combination_date;
   end if;


exception
   when e_bad_end_date
   then
     hr_utility.set_message(801, 'HR_AU_REC_MISSING_END_DATE');
     hr_utility.raise_error;
   when e_bad_combination_date
   then
     hr_utility.set_message(801, 'HR_AU_REC_COMBINATION_DATES');
     hr_utility.raise_error;

end check_report_parameters;

BEGIN
/*Bug 2610141 - Code added to remove the gscc warnings */
g_debug := hr_utility.debug_enabled;
g_package := 'pay_au_reconciliation_pkg.';

end pay_au_reconciliation_pkg;

/
