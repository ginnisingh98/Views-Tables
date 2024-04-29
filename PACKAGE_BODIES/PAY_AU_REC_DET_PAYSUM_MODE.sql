--------------------------------------------------------
--  DDL for Package Body PAY_AU_REC_DET_PAYSUM_MODE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_AU_REC_DET_PAYSUM_MODE" as
/* $Header: pyaureps.pkb 120.22.12010000.25 2010/01/13 09:04:38 pmatamsr ship $*/
/* ------------------------------------------------------------------------+
*** Program:     pay_au_rec_det_paysum_mode (Package Body)
***
*** Change History
***
*** Date       Changed By  Version Bug No   Description of Change
*** ---------  ----------  ------- ------   --------------------------------+
*** 22 DEC 04  avenkatk    1.0     3899641  Initial Version
*** 30 DEC 04  avenkatk    1.1     3899641  Changed Package Name
*** 31 DEC 04  avenkatk    1.2     3899641  Changed Flexfield context for Standard
***                                         Balances
*** 6  Jan 05  hnainani    1.3     4085496  Added Workplace Giving Deductions changes
*** 13 Jan 05  avenkatk    1.5     4116833  Set the Report Request number of copies to be read from Archive Request.
*** 20 Jan 05  avenkatk    1.6     4133326  Procedure get_fbt_balance - Added FBT Balance > 1000 check.
*** 07 Feb 05  abhkumar    1.7     4142159  Conditional deletion of generated actions.
*** 07 Feb 05  ksingla     1.8     4161460  Modified the cursor get_allowance_balances.
*** 11 Feb 05  avenkatk    1.9     4179109  Modified c_ps_element_details to check for Non Taxable Allowances
*** 11-FEB-05  abhkumar    1.10    4132149  Modified initialisation_code to initialise the global variables for legislative parameters.
*** 17 Feb 05  abhkumar    1.11    4161460  Rolled back changes made in version 115.8.
*** 24 Feb 05  avenkatk    1.12    4201894  Added check to Archive Retro Payments < $400 as Taxable Earnings.
*** 22 Apr 05  ksingla     1.13    4177679  Added a new paramter to the function call etp_prepost_ratios.
*** 05 May 05  ksingla     1.14    4353285  Removed to_char from fnd_request to payroll_id and assignment_id.
*** 05 May 05  abhkumar    1.15    4377367  Added join in the cursor csr_assignment_paysum to archive the end-dated employees.
*** 22 Jun 05  abhargav    1.16    4363057  Changes due to Retro Tax enhancement.
*** 04 Jul 05  avenkatk    1.17    3891577  Introduced Logic and procedures for Summary Report - Payment Summary Mode
***                                         (A) Parameter REP_MODE - to decide whether Report is Summary or Detail
*** 2 AUG 05 hnainani      1.18   Bug#4478752    Added quotes to -999 to allow for Character values in flexfield
*** 12-Sep-05 avenkatk     1.19    3891577  (A) Backed out template Name parameter from procedure spawn_summary_reports
***                                             Template Details not specified in this step of 2-step process.
*** 02-OCT-05 abhkumar     1.21    4688800   Modified assignment action code to pick those employees who do have payroll attached
                                             at start of the financial year but not at the end of financial year.
*** 05-DEC-05 abhkumar     1.22    4177630   Modified the get_allowance_balances procedure to get balance values in BBR mode.
*** 06-DEC-05 abhkumar     1.23    4177630   Modified the code to raise error message when there is no defined balance id for the allowance balance.
*** 15-DEC-05 ksingla      1.24    4872594   Modified code and put round off for total assessable income.
*** 28-DEC-05 avenkatk     1.25    4726352   Modified code to ensure Manual PS Details are archive for Summary Report.
*** 27-FEB-06 ksingla      1.26    5063359   Modified cursor c_ps_element_details for Employer Charges.
*** 27-MAR-06 avenkatk     1.27    5119734   Modified cursor c_ps_element_details for reporting Allowances.
*** 20-Jun-06 ksingla      1.28    5333143   Add_months included to fetch FBT_RATE and MEDICARE_LEVY
*** 29-Oct-06 hnainani    1.29    5603254   Added  Function get_element_payment_hours to fetch hours in c_element_details.
***29 OCT 06 hnainani     1.30    5603524  Removed function get_element_payment_hours - used function defined in pay_au_Rec_det_archive instead
*** 16-Nov-06 abhargav    115.31  5603254    Modified cursor c_ps_element_details to remove join for table pay_input_values_f piv2 and pay_run_result_values prrv2.
*** 19-Dec-06 ksingla     115.32  5708255   Added code to get value of global FBT_THRESHOLD
*** 22-Dec-06 ksingla     115.33  5708255   Changed 1000 to g_fbt_threshold in cursor csr_assignment_only_paysum
*** 27-Dec-06 ksingla     115.34  5708255   Added to_number to all occurrences of  g_fbt_threshold
*** 8-Jan-06 ksingla      115.35  Bug#5743196   Added nvl to cursor c_allowance_balance
*** 7-Feb-06 priupadh     115.36  5846278    In Cursor C_PS_ELEMENT_DETAILS added Lump Sum E Payments in not exists clause
*** 13-Feb-06 priupadh    115.37  N/A        Version for restoring Triple Maintanence between 11i-->R12(Branch) -->R12(MainLine)
*** 3-MAR-07  hnainani    115.38   5599310   Added  Function get_element_payment_rate to fetch rate in c_ps_element_details.
*** 26-FEB-08 vdabgar     115.39   6839263   Modified proc spawn_archive_reports,csr_params and csr_report_params cursors
***                                         to call the concurrent programs accordingly.
*** 13-MAR-08 avenkatk    115.40   6839263   Backed out changes in initialization_code and assignment_section_code
*** 21-Mar-08 avenkatk    115.41   6839263   Added Logic to set the OPP Template options for PDF output
*** 26-May-08 bkeshary    115.42   7030285   Modified the calculation for Assessable Income
*** 26-May-08 bkeshary    115.43   7030285   Added File Change History
*** 26-May-08 bkeshary    115.44   7030285   Modified the Comment lines
*** 18-Jun-08 avenkatk    115.45   7138494   Added Changes for RANGE_PERSON_ID
*** 18-Jun-08 avenkatk    115.46   7138494   Modified Allowance Cursor for peformance
*** 18-Dec-08 skshin      115.47   7571001   Modified archive_element_details, summary_rep_populate_allowance and get_allowance_balances
*** 27-Jan-09 skshin      115.48   7571001   Modified Cursor c_ps_element_details to have separate cursor c_ps_alw_details for allowances and removed summary_rep_populate_allowance procedure and p_allowance_exist in archive_element_details
*** 13-Feb-09 mdubasi     115.49   7590936   Replaced secure view hr_organization_units with hr_all_organization_units
***                                          in the cursor c_employee_details
*** 23-Feb-09 mdubasi     115.50   7590936   Replaced second secure view hr_organization_units with hr_all_organization_units
***                                          in the cursor c_employee_details
*** 28-Apr-09 pmatamsr    115.51   8441044   Cursor c_get_pay_effective_date is modified to consider Lump Sum E payments for payment summary gross calculation
***                                          for action types 'B' and 'I'.
*** 23-Jun-09 pmatamsr    115.52   8587013   Added changes to support the archival of new balances 'Reportable Employer Superannuation Contributions'
***                                          and 'Exempt Foreign Employment Income' introduced as part of PS Changes effective from 01-Jul-2009.
*** 25-Jun-09 pmatamsr    115.53   8587013   Resolved GSCC errors.
*** 08-Aug-09 pmatamsr    115.54   8760756   Added a join condition and removed hours and rate columns from c_ps_alw_details cursor query
***                                          for reporting of allowances in EOY Report.
*** 07-Sep-09 pmatamsr    115.55   8769345   Modified initialization_code,archive_code,archive_balance_details and archive_element_details procedures to support
***                                          the archival of new ETP Taxable and Tax Free balances introduced as part of statutory changes to Super Rollover.
*** 26-Nov-09 avenkatk    115.57   9146069   Modified the terms display in the ETP Payments section to be in sync with Validation Report
*** 26-Nov-09 avenkatk    115.58   9146069   Modified condition to check for Invalidity Balance
*** 19-Nov-09 skshin      115.60   8711855   Modifed Adjust_lumpsum_E_payments procedure to call pay_au_payment_summary.get_retro_lumpsumE_value
*** 19-Nov-09 skshin      115.61   9190980   Modified c_ps_element_details cursor to exclude retro gt12 balances
*** 15-Dec-09 pmatamsr    115.62   9190980   Added code to report Retro GT12 Pre Tax Deductions seperately under 'Lump Sum E Pre Tax' and 'Retro Pre Tax < $400'
*** 15-Dec-09 pmatamsr    115.63   9190980   Commented Retro Pre Tax GT 12 Mths Amount element in c_ps_element_details cursor so that the element is repoted
***                                          in Pre Tax Deductions section.
*** 15-Dec-09 pmatamsr    115.64   9190980   Uncommented Retro Pre Tax GT 12 Mths Amount element in c_ps_element_details cursor.
*** 13-Jan-09 pmatamsr    115.65   9226023   Added code to support the calculation of Taxable and Tax free portions of ETP for terminated employees processed
***                                          before applying 8769345 patch.
*** ------------------------------------------------------------------------+
*/
/* Package - Functional comments.
   This package is used to archive data in pay_action_information for TWO reports,
    i. End of Year Reconciliation Detail Report  (Bug 3899641)
   ii. End of Year Reconciliation Summary Report (Bug 3891577)

Parameter REP_MODE in legislative parameters is used to distinguish the type of Report.
For Detail report  - REP_MODE returns NULL
For Summary report - REP_MODE returns 'SUMM'
Based on the type of report,appropriate data is archived.

Any changes made to this package must be Functionally/Technically tested against both reports.
*/

g_arc_payroll_action_id           pay_payroll_actions.payroll_action_id%type;
  g_business_group_id           hr_all_organization_units.organization_id%type;

  g_debug boolean ;

  g_package                         constant varchar2(60) := 'pay_au_rec_det_paysum_mode.';  -- Global to store package name for tracing.

  g_end_date                        date;
  g_start_date                      date;
  g_tax_unit_id                     pay_assignment_actions.tax_unit_id%type;
  g_attribute_id                    pay_balance_attributes.attribute_id%type;  -- bug 7571101
  g_taxable_etp                     number; /* Start 9226023 - Global varaibles to store Taxable and Tax Free portions of ETP */
  g_tax_free_etp                    number; /* End 9226023 */

 g_fbt_threshold ff_globals_f.global_value%TYPE ; /* Bug 5708255 */
 p_lump_sum_E_ptd_tab pay_balance_pkg.t_balance_value_tab;  -- bug8711855

  --------------------------------------------------------------------
  -- Name  : range_code
  -- Type  : Proedure
  -- Access: Public
  -- This procedure returns a sql string to select a range
  -- of assignments eligible for archival.
  --
  --------------------------------------------------------------------

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

  --------------------------------------------------------------------
  -- Name  : initialization_code
  -- Type  : Proedure
  -- Access: Public
  -- This procedure builds a PL/SQL table with Defined Balance ID's
  -- of Balances which need to be fetched using
  --
  --------------------------------------------------------------------

/* Bug 8587013 - Added balances 'Reportable Employer Superannuation Contributions', 'Exempt Foreign Employment Income'
                 and removed 'Other Income' balance. */
/* Bug 8769345 - Added ETP Taxable and Tax Free balances to the cursor */

  procedure initialization_code
  (p_payroll_action_id  in pay_payroll_actions.payroll_action_id%type)
  is

    CURSOR   csr_defined_balance_id
    IS
    SELECT   decode(pbt.balance_name,'Earnings_Total',1,'Direct Payments',2,'Termination_Payments',3,
            'Involuntary Deductions',4,'Pre Tax Deductions',5,'Termination Deductions',6,
            'Voluntary Deductions',7,'Total_Tax_Deductions',8,'Earnings_Non_Taxable',9,
            'Employer_Charges',10,
                    'Lump Sum A Payments',11,'Lump Sum B Payments',12,'Lump Sum C Payments',13,
                'Lump Sum D Payments',14,'Lump Sum E Payments',15,'Invalidity Payments',16,'CDEP',17,
            'Leave Payments Marginal',18,'Reportable Employer Superannuation Contributions',19,'Union Fees',20,
                        'Workplace Giving Deductions' ,21,'Exempt Foreign Employment Income',22,
            'ETP Tax Free Payments Transitional Not Part of Prev Term',23,'ETP Tax Free Payments Transitional Part of Prev Term',24,
                        'ETP Tax Free Payments Life Benefit Not Part of Prev Term',25,'ETP Tax Free Payments Life Benefit Part of Prev Term',26,
                        'ETP Taxable Payments Transitional Not Part of Prev Term',27,'ETP Taxable Payments Transitional Part of Prev Term',28,
                        'ETP Taxable Payments Life Benefit Not Part of Prev Term',29,'ETP Taxable Payments Life Benefit Part of Prev Term',30, /*4085496 , 8587013 , 8769345*/
                        'Retro Earnings Leave Loading GT 12 Mths Amount',31, 'Retro Earnings Spread GT 12 Mths Amount',32,
                        'Retro Pre Tax GT 12 Mths Amount',33) sort_index, -- bug8711855
         pdb.defined_balance_id defined_balance_id,
             pbt.balance_name
      FROM   pay_balance_types pbt,
         pay_balance_dimensions pbd,
         pay_defined_balances pdb
     WHERE   pbt.balance_name         IN ('Earnings_Total','Direct Payments','Termination_Payments','Involuntary Deductions',
                          'Pre Tax Deductions','Termination Deductions','Voluntary Deductions','Total_Tax_Deductions',
                          'Earnings_Non_Taxable','Employer_Charges','Lump Sum A Payments','Lump Sum B Payments','Lump Sum C Payments',
                          'Lump Sum D Payments','Lump Sum E Payments','Invalidity Payments','CDEP','Leave Payments Marginal',
              'Reportable Employer Superannuation Contributions','Union Fees', 'Workplace Giving Deductions','Exempt Foreign Employment Income',
              'ETP Tax Free Payments Transitional Not Part of Prev Term','ETP Tax Free Payments Transitional Part of Prev Term',
                          'ETP Tax Free Payments Life Benefit Not Part of Prev Term','ETP Tax Free Payments Life Benefit Part of Prev Term',
                          'ETP Taxable Payments Transitional Not Part of Prev Term','ETP Taxable Payments Transitional Part of Prev Term',
                          'ETP Taxable Payments Life Benefit Not Part of Prev Term','ETP Taxable Payments Life Benefit Part of Prev Term', /*4085496 , 8587013 , 8769345*/
                          'Retro Earnings Leave Loading GT 12 Mths Amount', 'Retro Earnings Spread GT 12 Mths Amount', 'Retro Pre Tax GT 12 Mths Amount') -- bug8711855
       AND   pbd.database_item_suffix = '_ASG_LE_YTD'
       AND   pbt.balance_type_id      = pdb.balance_type_id
       AND   pbd.balance_dimension_id = pdb.balance_dimension_id
       AND   pbt.legislation_code     = 'AU'
    ORDER BY sort_index;

   /* bug8711855 - Fetching defined_balance_ids of Lump Sum E balances_PTD */
   CURSOR  c_single_lumpsum_E_payment  IS
   SELECT decode(pbt.balance_name,
                              'Lump Sum E Payments', 1
                             ,'Retro Earnings Leave Loading GT 12 Mths Amount', 2
                             ,'Retro Earnings Spread GT 12 Mths Amount', 3
                             ,'Retro Pre Tax GT 12 Mths Amount', 4) sort_index
               , pdb.defined_balance_id defined_balance_id
   FROM  pay_balance_types      pbt,
         pay_defined_balances   pdb,
         pay_balance_dimensions pbd
   WHERE pbt.legislation_code = 'AU'
   AND  pbt.balance_name in ( 'Lump Sum E Payments'
                             ,'Retro Earnings Leave Loading GT 12 Mths Amount'
                             ,'Retro Earnings Spread GT 12 Mths Amount'
                             ,'Retro Pre Tax GT 12 Mths Amount')
   AND  pbt.balance_type_id = pdb.balance_type_id
   AND  pbd.balance_dimension_id = pdb.balance_dimension_id
   AND  pbd.dimension_name = '_ASG_LE_PTD'
   order by sort_index;

/*Bug 4132149 - Modification begins here */
   cursor   get_ps_params(c_payroll_action_id  per_all_assignments_f.assignment_id%type)
   is
   select  pay_core_utils.get_parameter('BUSINESS_GROUP_ID',legislative_parameters) business_group_id
          ,pay_core_utils.get_parameter('REGISTERED_EMPLOYER',legislative_parameters) legal_employer
      ,decode(pay_core_utils.get_parameter('PAYROLL',legislative_parameters),null,'%',pay_core_utils.get_parameter('PAYROLL',legislative_parameters)) payroll_id
      ,decode(pay_core_utils.get_parameter('ASSIGNMENT_ID',legislative_parameters),null,'%',pay_core_utils.get_parameter('ASSIGNMENT_ID',legislative_parameters)) assignment_id
      ,decode(pay_core_utils.get_parameter('EMPLOYEE_TYPE',legislative_parameters),'C','Y','T','N','B','%') employee_type
      ,to_date('01-07-'||substr(pay_core_utils.get_parameter('FINANCIAL_YEAR',legislative_parameters),1,4),'DD-MM-YYYY') fin_year_state_date
      ,to_date('30-06-'||substr(pay_core_utils.get_parameter('FINANCIAL_YEAR',legislative_parameters),6,4),'DD-MM-YYYY') fin_year_end_date
      ,to_date('01-04-'||substr(pay_core_utils.get_parameter('FINANCIAL_YEAR',legislative_parameters),1,4),'DD-MM-YYYY') fbt_year_start_date
      ,to_date('30-06-'||substr(pay_core_utils.get_parameter('FINANCIAL_YEAR',legislative_parameters),1,4),'DD-MM-YYYY') fbt_year_end_date
      ,pay_core_utils.get_parameter('LST_YR_TERM',legislative_parameters) lst_year_term
      ,pay_core_utils.get_parameter('DEL_ACT',legislative_parameters) delete_actions /*Bug 4142159*/
      ,decode(pay_core_utils.get_parameter('REP_MODE',legislative_parameters),'SUMM','S','D') report_mode /*Bug 3891577*/
    from pay_payroll_actions
    where payroll_action_id = c_payroll_action_id;

  Cursor c_fbt_balance is
  select    pdb.defined_balance_id
  from      pay_balance_types            pbt,
        pay_defined_balances         pdb,
        pay_balance_dimensions       pbd
  where  pbt.balance_name               ='Fringe Benefits'
  and  pbt.balance_type_id            = pdb.balance_type_id
  and  pdb.balance_dimension_id       = pbd.balance_dimension_id /* Bug 2501105 */
  and  pbd.legislation_code           ='AU'
  and  pbd.dimension_name             ='_ASG_LE_FBT_YTD' --2610141
  and  pbd.legislation_code = pbt.legislation_code
  and  pbd.legislation_code = pdb.legislation_code;

  /*Bug 4132149 - Modification ends here */

  /* bug 7571001 - added get_balance_attribute cursor */
  CURSOR get_balance_attribute (c_attribute_name PAY_BAL_ATTRIBUTE_DEFINITIONS.attribute_name%type) IS
      select attribute_id
      from PAY_BAL_ATTRIBUTE_DEFINITIONS
      where attribute_name = c_attribute_name
      ;

    l_procedure               varchar2(200) ;

  begin

    g_debug :=hr_utility.debug_enabled ;
    if g_debug then
        l_procedure := g_package||'initialization_code';
        hr_utility.set_location('Entering '||l_procedure,1);
    end if;

     g_balance_value_tab.delete;

/*Bug 4132149 - Modification begins here */

    g_arc_payroll_action_id := p_payroll_action_id;

/* Fetch Params */
open get_ps_params(p_payroll_action_id);
fetch get_ps_params into g_parameters;
close get_ps_params;

g_business_group_id := g_parameters.business_group_id;
g_start_date        := g_parameters.fin_year_start_date;
g_end_date          := g_parameters.fin_year_end_date;
g_tax_unit_id       := g_parameters.legal_employer;

if g_debug
then
        hr_utility.set_location('p_payroll_action_id.........= ' || p_payroll_action_id,30);
        hr_utility.set_location('g_parameters.business_group_id.........= ' || g_parameters.business_group_id,30);
        hr_utility.set_location('g_parameters.payroll_id..............= ' || g_parameters.payroll_id,30);
        hr_utility.set_location('g_parameters.legal_employer.........= ' || g_parameters.legal_employer,30);
        hr_utility.set_location('g_parameters.assignment_id.........= ' || g_parameters.assignment_id,30);
        hr_utility.set_location('g_parameters.fin_year_start_date..............= ' || g_parameters.fin_year_start_date,30);
        hr_utility.set_location('g_parameters.fin_year_end_date................= ' || g_parameters.fin_year_end_date,30);
        hr_utility.set_location('g_parameters.fbt_year_start_date..............= ' || g_parameters.fbt_year_start_date,30);
        hr_utility.set_location('g_parameters.fbt_year_end_date................= ' || g_parameters.fbt_year_end_date,30);
        hr_utility.set_location('g_parameters.employee_type..........= '||g_parameters.employee_type,30);
        hr_utility.set_location('g_parameters.delete_actions..........= '||g_parameters.delete_actions,30); /*Bug 4142159*/
        hr_utility.set_location('g_parameters.report_mode..........= '||g_parameters.report_mode,30); /*Bug 3891577*/
end if;

    /* SET FBT Defined_balance ID */
  If g_fbt_defined_balance_id is null OR g_fbt_defined_balance_id =0 Then
       Open  c_fbt_balance;
       Fetch c_fbt_balance into  g_fbt_defined_balance_id;
       Close c_fbt_balance;
 End if;


 /*Bug 4132149 - Modification ends here */

      FOR csr_rec IN csr_defined_balance_id
      LOOP
         g_balance_value_tab(csr_rec.sort_index).defined_balance_id := csr_rec.defined_balance_id;
      END LOOP;


      IF g_debug THEN
         hr_utility.trace('Defined Balance ids for YTD dimension');
         hr_utility.trace('-------------------------------------');
         hr_utility.trace('Earnings_Total        ===>' || g_balance_value_tab(1).defined_balance_id);
         hr_utility.trace('Workplace Giving Deductions  ===>' || g_balance_value_tab(21).defined_balance_id);
         hr_utility.trace('Direct Payments       ===>' || g_balance_value_tab(2).defined_balance_id);
         hr_utility.trace('Termination_Payments  ===>' || g_balance_value_tab(3).defined_balance_id);
         hr_utility.trace('Involuntary Deductions===>' || g_balance_value_tab(4).defined_balance_id);
         hr_utility.trace('Pre Tax Deductions    ===>' || g_balance_value_tab(5).defined_balance_id);
         hr_utility.trace('Termination Deductions===>' || g_balance_value_tab(6).defined_balance_id);
         hr_utility.trace('Voluntary Deductionsn ===>' || g_balance_value_tab(7).defined_balance_id);
         hr_utility.trace('Total_Tax_Deduction   ===>' || g_balance_value_tab(8).defined_balance_id);
         hr_utility.trace('Earnings_Non_Taxable  ===>' || g_balance_value_tab(9).defined_balance_id);
         hr_utility.trace('Employer_Charges      ===>' || g_balance_value_tab(10).defined_balance_id);
         hr_utility.trace('Lump Sum A Payments ===>' || g_balance_value_tab(11).defined_balance_id);
         hr_utility.trace('Lump Sum B Payments ===>' || g_balance_value_tab(12).defined_balance_id);
         hr_utility.trace('Lump Sum C Payments ===>' || g_balance_value_tab(13).defined_balance_id);
         hr_utility.trace('Lump Sum D Payments ===>' || g_balance_value_tab(14).defined_balance_id);
         hr_utility.trace('Lump Sum E Payments ===>' || g_balance_value_tab(15).defined_balance_id);
         hr_utility.trace('Invalidity Payments ===>' || g_balance_value_tab(16).defined_balance_id);
         hr_utility.trace('CDEP                ===>' || g_balance_value_tab(17).defined_balance_id);
         hr_utility.trace('Leave Payments Marginal===>' || g_balance_value_tab(18).defined_balance_id);
         hr_utility.trace('Reportable Employer Superannuation Contributions      ===>' || g_balance_value_tab(19).defined_balance_id); /* Bug 8587013 */
         hr_utility.trace('Union Fees         ===>' || g_balance_value_tab(20).defined_balance_id);
         hr_utility.trace('Exempt Foreign Employment Income        ===>' || g_balance_value_tab(22).defined_balance_id); /* Bug 8587013 */
         hr_utility.trace('ETP Tax Free Payments Transitional Not Part of Prev Term  ===>' || g_balance_value_tab(23).defined_balance_id); /* Start 8769345 */
         hr_utility.trace('ETP Tax Free Payments Transitional Part of Prev Term      ===>' || g_balance_value_tab(24).defined_balance_id);
         hr_utility.trace('ETP Tax Free Payments Life Benefit Not Part of Prev Term  ===>' || g_balance_value_tab(25).defined_balance_id);
         hr_utility.trace('ETP Tax Free Payments Life Benefit Part of Prev Term      ===>' || g_balance_value_tab(26).defined_balance_id);
         hr_utility.trace('ETP Taxable Payments Transitional Not Part of Prev Term   ===>' || g_balance_value_tab(27).defined_balance_id);
         hr_utility.trace('ETP Taxable Payments Transitional Part of Prev Term       ===>' || g_balance_value_tab(28).defined_balance_id);
         hr_utility.trace('ETP Taxable Payments Life Benefit Not Part of Prev Term   ===>' || g_balance_value_tab(29).defined_balance_id);
         hr_utility.trace('ETP Taxable Payments Life Benefit Part of Prev Term       ===>' || g_balance_value_tab(30).defined_balance_id); /* End 8769345 */
         hr_utility.trace('Retro Earnings Leave Loading GT 12 Mths Amount     ===>' || g_balance_value_tab(31).defined_balance_id); -- start 8711855
         hr_utility.trace('Retro Earnings Spread GT 12 Mths Amount    ===>' || g_balance_value_tab(32).defined_balance_id);
         hr_utility.trace('Retro Pre Tax GT 12 Mths Amount     ===>' || g_balance_value_tab(33).defined_balance_id);  -- end 8711855
    end if;

  p_lump_sum_E_ptd_tab.delete;
  for csr_rec in c_single_lumpsum_E_payment loop
     p_lump_sum_E_ptd_tab(csr_rec.sort_index).defined_balance_id := csr_rec.defined_balance_id;
  end loop;

  if g_debug then
     hr_utility.set_location('Defined Balance Ids for Lump Sume E PTD are:' , 15);
     hr_utility.trace('--------------------------------------------');
     hr_utility.trace('Lump Sum E Payments   ===>' || p_lump_sum_E_ptd_tab(1).defined_balance_id);
     hr_utility.trace('Retro Earnings Leave Loading GT 12 Mths Amount   ===>' || p_lump_sum_E_ptd_tab(2).defined_balance_id);
     hr_utility.trace('Retro Earnings Spread GT 12 Mths Amount   ===>' || p_lump_sum_E_ptd_tab(3).defined_balance_id);
     hr_utility.trace('Retro Pre Tax GT 12 Mths Amount  ===>' || p_lump_sum_E_ptd_tab(4).defined_balance_id);
  end if;

  /* bug 7571001 - initialize g_attribute_id */
  open get_balance_attribute('AU_EOY_ALLOWANCE');
  fetch get_balance_attribute into g_attribute_id;
  close get_balance_attribute;

    if g_debug then
            hr_utility.set_location('Leaving '||l_procedure,1000);
    end if;

  exception
    when others then
      hr_utility.set_location('Error in '||l_procedure,999999);
      raise;
  end initialization_code;


/*
    Bug 7138494 - Added Function range_person_on
--------------------------------------------------------------------
    Name  : range_person_on
    Type  : Function
    Access: Private
    Description: Checks if RANGE_PERSON_ID is enabled for
                 Archive process.
  --------------------------------------------------------------------
*/

FUNCTION range_person_on
        (p_report_mode  IN VARCHAR2)
RETURN BOOLEAN
IS

 CURSOR csr_action_parameter is
  select parameter_value
  from pay_action_parameters
  where parameter_name = 'RANGE_PERSON_ID';

 CURSOR csr_range_format_param(c_report_type VARCHAR2)
 IS
  SELECT par.parameter_value
  FROM   pay_report_format_parameters par,
         pay_report_format_mappings_f map
  WHERE  map.report_format_mapping_id = par.report_format_mapping_id
  AND    map.report_type = c_report_type
  AND    map.report_format = c_report_type
  AND    map.report_qualifier = 'AU'
  AND    par.parameter_name = 'RANGE_PERSON_ID'; -- Bug fix 5567246

  l_return boolean;
  l_action_param_val varchar2(30);
  l_report_param_val varchar2(30);
  l_report_type      VARCHAR2(50);

BEGIN

    g_debug := hr_utility.debug_enabled;

    IF g_debug
    THEN
        hr_utility.set_location('range_person_on',10);
    END IF;

  BEGIN

    open csr_action_parameter;
    fetch csr_action_parameter into l_action_param_val;
    close csr_action_parameter;

    IF g_debug
    THEN
        hr_utility.set_location('range_person_on',20);
    END IF;

    IF p_report_mode   = 'S'
    THEN
        l_report_type   := 'AU_REC_PS_SUMM_ARCHIVE';
    ELSE
        l_report_type   := 'AU_REC_PS_DET_ARCHIVE';
    END IF;


    open csr_range_format_param(l_report_type);
    fetch csr_range_format_param into l_report_param_val;
    close csr_range_format_param;
    IF g_debug
    THEN
        hr_utility.set_location('range_person_on',30);
    END IF;
  EXCEPTION WHEN NO_DATA_FOUND THEN
     l_return := FALSE;
  END;
  --
    IF g_debug
    THEN
        hr_utility.set_location('range_person_on',40);
    END IF;

  IF l_action_param_val = 'Y' AND l_report_param_val = 'Y' THEN
     l_return := TRUE;

    IF g_debug
    THEN
             hr_utility.trace('Range Person = True');
    END IF;
  ELSE
     l_return := FALSE;
  END IF;
--
 RETURN l_return;
--
END range_person_on;

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
  --------------------------------------------------------------------+

procedure assignment_action_code
  (p_payroll_action_id in pay_payroll_actions.payroll_action_id%type
  ,p_start_person      in per_all_people_f.person_id%type
  ,p_end_person        in per_all_people_f.person_id%type
  ,p_chunk             in number
  ) is
  cursor   get_ps_params(c_payroll_action_id  per_all_assignments_f.assignment_id%type)
   is
   select  pay_core_utils.get_parameter('BUSINESS_GROUP_ID',legislative_parameters) business_group_id
          ,pay_core_utils.get_parameter('REGISTERED_EMPLOYER',legislative_parameters) legal_employer
      ,decode(pay_core_utils.get_parameter('PAYROLL',legislative_parameters),null,'%',pay_core_utils.get_parameter('PAYROLL',legislative_parameters)) payroll_id
      ,decode(pay_core_utils.get_parameter('ASSIGNMENT_ID',legislative_parameters),null,'%',pay_core_utils.get_parameter('ASSIGNMENT_ID',legislative_parameters)) assignment_id
      ,decode(pay_core_utils.get_parameter('EMPLOYEE_TYPE',legislative_parameters),'C','Y','T','N','B','%') employee_type
      ,to_date('01-07-'||substr(pay_core_utils.get_parameter('FINANCIAL_YEAR',legislative_parameters),1,4),'DD-MM-YYYY') fin_year_state_date
      ,to_date('30-06-'||substr(pay_core_utils.get_parameter('FINANCIAL_YEAR',legislative_parameters),6,4),'DD-MM-YYYY') fin_year_end_date
      ,to_date('01-04-'||substr(pay_core_utils.get_parameter('FINANCIAL_YEAR',legislative_parameters),1,4),'DD-MM-YYYY') fbt_year_start_date
      ,to_date('30-06-'||substr(pay_core_utils.get_parameter('FINANCIAL_YEAR',legislative_parameters),1,4),'DD-MM-YYYY') fbt_year_end_date
      ,pay_core_utils.get_parameter('LST_YR_TERM',legislative_parameters) lst_year_term
      ,pay_core_utils.get_parameter('DEL_ACT',legislative_parameters) delete_actions /*Bug 4142159*/
      ,decode(pay_core_utils.get_parameter('REP_MODE',legislative_parameters),'SUMM','S','D') report_mode /*Bug 3891577*/
    from pay_payroll_actions
    where payroll_action_id = c_payroll_action_id;

  --------------------------------------------------------------------+
  -- Cursor      : csr_assignment_paysum
  -- Description : Fetches assignments For Recconciling Payment Summary
  --               Returns DISTINCT assignment_id
  --
  --------------------------------------------------------------------+
 cursor csr_assignment_paysum
      (c_payroll_action_id  pay_payroll_actions.payroll_action_id%type
      ,c_start_person       per_all_people_f.person_id%type
      ,c_end_person         per_all_people_f.person_id%type
      ,c_employee_type      per_all_people_f.current_employee_flag%type
      ,c_business_group_id  hr_all_organization_units.organization_id%type
      ,c_legal_employer     pay_assignment_actions.tax_unit_id%type
      ,c_payroll_id         varchar2
      ,c_fin_year_start date
      ,c_fin_year_end  date
      ,c_lst_fbt_yr_start date
      ,c_fbt_year_start date
      ,c_fbt_year_end  date
      ,c_lst_year_start  date
      ,c_fbt_defined_balance_id pay_defined_balances.defined_balance_id%type
      ,c_assignment_id varchar2
      ) is
  SELECT /*+ INDEX(pap per_people_f_pk)
             INDEX(paa per_assignments_f_fk1)
             INDEX(paa per_assignments_f_N12)
             INDEX(rppa pay_payroll_actions_pk)
             INDEX(pps per_periods_of_service_n3)
        */      distinct paa.assignment_id
   from           per_people_f              pap
                 ,per_assignments_f         paa
                 ,pay_payroll_actions           rppa
                 ,per_periods_of_service        pps
   where rppa.payroll_action_id       = c_payroll_action_id
   and   pap.person_id                between c_start_person and c_end_person
   and   pap.person_id                = paa.person_id
   and   decode(pps.actual_termination_date,null,'Y',decode(sign(pps.actual_termination_date - (c_fin_year_end)),1,'Y','N')) LIKE c_employee_type
   and  pps.period_of_service_id = paa.period_of_service_id
   and  pap.person_id         = pps.person_id
   and  rppa.business_group_id=paa.business_group_id
   and  nvl(pps.actual_termination_date, c_lst_year_start) >= c_lst_year_start
   and  c_fin_year_end between pap.effective_start_date and pap.effective_end_date
--    and   least(nvl(pps.actual_termination_date,v_fin_year_end),v_fin_year_end) between a.effective_start_date and a.effective_end_date
    and   paa.effective_end_date = (select max(effective_end_date) /*4377367*/
                                    From  per_assignments_f iipaf
                                    WHERE iipaf.assignment_id  = paa.assignment_id
                                    and iipaf.effective_end_date >= c_fbt_year_start
                                    and iipaf.effective_start_date <= c_fin_year_end
                                    AND iipaf.payroll_id IS NOT NULL) /*Bug 4688800*/
   and   paa.payroll_id like c_payroll_id
   and   paa.assignment_id like c_assignment_id
   AND EXISTS  (SELECT  /*+ INDEX(rpac PAY_ASSIGNMENT_ACTIONS_N51)
                            INDEX(rpac pay_assignment_actions_n1)
                            INDEX(rppa  PAY_PAYROLL_ACTIONS_N51)
                            INDEX(rppa  PAY_PAYROLL_ACTIONS_PK) */''
           FROM  per_assignments_f             paaf
                ,pay_payroll_actions           rppa
                ,pay_assignment_actions        rpac
           where (rppa.effective_date      between  c_fin_year_start and c_fin_year_end   /*Bug3048962 */
                  or ( pps.actual_termination_date between c_lst_fbt_yr_start and c_fbt_year_end /*Bug3263659 */
                        and rppa.effective_date between c_fbt_year_start and c_fbt_year_end
                        and  pay_balance_pkg.get_value(c_fbt_defined_balance_id, rpac.assignment_action_id
                                        + decode(rppa.payroll_id,  0, 0, 0),c_legal_employer,null,null,null,null) > to_number(g_fbt_threshold)) /* Bug 5708255 */
                    )
           and rppa.action_type            in ('R','Q','B','I')
           and rpac.tax_unit_id = c_legal_employer
           and rppa.payroll_action_id = rpac.payroll_action_id
           and rpac.action_status = 'C'
           and rpac.assignment_id = paaf.assignment_id
           and paaf.assignment_id  = paa.assignment_id
           and rppa.effective_date between paaf.effective_start_date and paaf.effective_end_date
           and  rppa.payroll_id = paaf.payroll_id );

  --------------------------------------------------------------------+
  -- Cursor      : csr_assignment_only_paysum
  -- Description : Fetches assignments For Recconciling Payment Summary
  --               Returns DISTINCT assignment_id for Distinct
  --               Assignment.
  --------------------------------------------------------------------+

 cursor csr_assignment_only_paysum
      (c_payroll_action_id  pay_payroll_actions.payroll_action_id%type
      ,c_start_person       per_all_people_f.person_id%type
      ,c_end_person         per_all_people_f.person_id%type
      ,c_employee_type      per_all_people_f.current_employee_flag%type
      ,c_business_group_id  hr_all_organization_units.organization_id%type
      ,c_legal_employer     pay_assignment_actions.tax_unit_id%type
      ,c_payroll_id         varchar2
      ,c_fin_year_start date
      ,c_fin_year_end  date
      ,c_lst_fbt_yr_start date
      ,c_fbt_year_start date
      ,c_fbt_year_end  date
      ,c_lst_year_start  date
      ,c_fbt_defined_balance_id pay_defined_balances.defined_balance_id%type
      ,c_assignment_id varchar2
      ) is
  SELECT /*+ INDEX(pap per_people_f_pk)
             INDEX(paa per_assignments_f_fk1)
             INDEX(paa per_assignments_f_N12)
             INDEX(rppa pay_payroll_actions_pk)
             INDEX(pps per_periods_of_service_n3)
        */      distinct paa.assignment_id
   from           per_people_f              pap
                 ,per_assignments_f         paa
                 ,pay_payroll_actions           rppa
                 ,per_periods_of_service        pps
   where rppa.payroll_action_id       = c_payroll_action_id
   and   pap.person_id                between c_start_person and c_end_person
   and   pap.person_id                = paa.person_id
   and   decode(pps.actual_termination_date,null,'Y',decode(sign(pps.actual_termination_date - (c_fin_year_end)),1,'Y','N')) LIKE c_employee_type
   and  pps.period_of_service_id = paa.period_of_service_id
   and  pap.person_id         = pps.person_id
   and  rppa.business_group_id=paa.business_group_id
   and  nvl(pps.actual_termination_date, c_lst_year_start) >= c_lst_year_start
   and  c_fin_year_end between pap.effective_start_date and pap.effective_end_date
--    and   least(nvl(pps.actual_termination_date,v_fin_year_end),v_fin_year_end) between a.effective_start_date and a.effective_end_date
    and   paa.effective_end_date = (select max(effective_end_date) /*4377367*/
                                                           From  per_assignments_f iipaf
                                                           WHERE iipaf.assignment_id  = paa.assignment_id
                                                           and iipaf.effective_end_date >= c_fbt_year_start
                                                           and iipaf.effective_start_date <= c_fin_year_end
                                  AND iipaf.payroll_id IS NOT NULL) /*Bug 4688800*/
   and   paa.payroll_id like c_payroll_id
   and   paa.assignment_id = c_assignment_id
   AND EXISTS  (SELECT  /*+ INDEX(rpac PAY_ASSIGNMENT_ACTIONS_N51)
                            INDEX(rpac pay_assignment_actions_n1)
                            INDEX(rppa  PAY_PAYROLL_ACTIONS_N51)
                            INDEX(rppa  PAY_PAYROLL_ACTIONS_PK) */''
           FROM  per_assignments_f             paaf
                ,pay_payroll_actions           rppa
                ,pay_assignment_actions        rpac
           where (rppa.effective_date      between  c_fin_year_start and c_fin_year_end   /*Bug3048962 */
                  or ( pps.actual_termination_date between c_lst_fbt_yr_start and c_fbt_year_end /*Bug3263659 */
                        and rppa.effective_date between c_fbt_year_start and c_fbt_year_end
                        and  pay_balance_pkg.get_value(c_fbt_defined_balance_id, rpac.assignment_action_id
                                        + decode(rppa.payroll_id,  0, 0, 0),c_legal_employer,null,null,null,null) > to_number(g_fbt_threshold)) /* Bug 5708255 */
                    )
           and rppa.action_type            in ('R','Q','B','I')
           and rpac.tax_unit_id = c_legal_employer
           and rppa.payroll_action_id = rpac.payroll_action_id
           and rpac.action_status = 'C'
           and rpac.assignment_id = paaf.assignment_id
                   and paaf.assignment_id  = paa.assignment_id
                   and rppa.effective_date between paaf.effective_start_date and paaf.effective_end_date
           and  rppa.payroll_id = paaf.payroll_id );

/*
   Bug 7138494 - Added Cursor for Range Person
               - Uses person_id in pay_population_ranges
  --------------------------------------------------------------------+
  -- Cursor      : csr_range_assignment_paysum
  -- Description : Fetches assignments For Recconciling Payment Summary
  --               Returns DISTINCT assignment_id
  --               Used when RANGE_PERSON_ID feature is enabled
  --------------------------------------------------------------------+
*/

 CURSOR csr_range_assignment_paysum
      (c_payroll_action_id  pay_payroll_actions.payroll_action_id%type
      ,c_chunk              NUMBER
      ,c_employee_type      per_all_people_f.current_employee_flag%type
      ,c_business_group_id  hr_all_organization_units.organization_id%type
      ,c_legal_employer     pay_assignment_actions.tax_unit_id%type
      ,c_payroll_id         varchar2
      ,c_fin_year_start date
      ,c_fin_year_end  date
      ,c_lst_fbt_yr_start date
      ,c_fbt_year_start date
      ,c_fbt_year_end  date
      ,c_lst_year_start  date
      ,c_fbt_defined_balance_id pay_defined_balances.defined_balance_id%type
      ,c_assignment_id varchar2
      )
 IS
 SELECT  /*+ INDEX(pap per_people_f_pk)
             INDEX(rppa pay_payroll_actions_pk)
             INDEX(ppr PAY_POPULATION_RANGES_N4)
             INDEX(paa per_assignments_f_N12)
             INDEX(pps per_periods_of_service_PK)
        */        paa.assignment_id
   from           per_people_f              pap
                 ,per_assignments_f         paa
                 ,pay_payroll_actions           rppa
                 ,per_periods_of_service        pps
                 ,pay_population_ranges         ppr
   WHERE rppa.payroll_action_id         = c_payroll_action_id
   AND   rppa.payroll_action_id         = ppr.payroll_action_id
   AND   ppr.chunk_number               = c_chunk
   AND   pap.person_id                  = ppr.person_id
   AND   pap.person_id                  = paa.person_id
   AND   decode(pps.actual_termination_date,null,'Y',decode(sign(pps.actual_termination_date - (c_fin_year_end)),1,'Y','N')) LIKE c_employee_type
   AND  pps.period_of_service_id = paa.period_of_service_id
   AND  pap.person_id         = pps.person_id
   AND  rppa.business_group_id=paa.business_group_id
   AND  nvl(pps.actual_termination_date, c_lst_year_start) >= c_lst_year_start
   AND  c_fin_year_end between pap.effective_start_date AND pap.effective_end_date
   AND   paa.effective_end_date = (SELECT MAX(effective_end_date) /*4377367*/
                                    FROM  per_assignments_f iipaf
                                    WHERE iipaf.assignment_id  = paa.assignment_id
                                    AND iipaf.effective_end_date >= c_fbt_year_start
                                    AND iipaf.effective_start_date <= c_fin_year_end
                                    AND iipaf.payroll_id IS NOT NULL) /*Bug 4688800*/
   AND   paa.payroll_id like c_payroll_id
   AND   paa.assignment_id like c_assignment_id
   AND EXISTS  (SELECT  /*+ INDEX(rpac PAY_ASSIGNMENT_ACTIONS_N51)
                            INDEX(rppa  PAY_PAYROLL_ACTIONS_N51)
                         */''
                   FROM  per_assignments_f             paaf
                        ,pay_payroll_actions           rppa
                        ,pay_assignment_actions        rpac
                   WHERE (rppa.effective_date      between  c_fin_year_start AND c_fin_year_end   /*Bug3048962 */
                          or ( pps.actual_termination_date between c_lst_fbt_yr_start AND c_fbt_year_end /*Bug3263659 */
                                AND rppa.effective_date between c_fbt_year_start AND c_fbt_year_end
                                AND  pay_balance_pkg.get_value(c_fbt_defined_balance_id, rpac.assignment_action_id
                                                + decode(rppa.payroll_id,  0, 0, 0),c_legal_employer,null,null,null,null) > to_number(g_fbt_threshold)) /* Bug 5708255 */
                            )
                   AND rppa.action_type            in ('R','Q','B','I')
                   AND rpac.tax_unit_id = c_legal_employer
                   AND rppa.payroll_action_id = rpac.payroll_action_id
                   AND rpac.action_status = 'C'
                   AND rpac.assignment_id = paaf.assignment_id
                   AND paaf.assignment_id  = paa.assignment_id
                   AND rppa.effective_date between paaf.effective_start_date AND paaf.effective_end_date
                   AND  rppa.payroll_id = paaf.payroll_id );

Cursor c_fbt_balance is
  select        pdb.defined_balance_id
  from          pay_balance_types            pbt,
                pay_defined_balances         pdb,
                pay_balance_dimensions       pbd
  where  pbt.balance_name               ='Fringe Benefits'
  and  pbt.balance_type_id            = pdb.balance_type_id
  and  pdb.balance_dimension_id       = pbd.balance_dimension_id /* Bug 2501105 */
  and  pbd.legislation_code           ='AU'
  and  pbd.dimension_name             ='_ASG_LE_FBT_YTD' --2610141
  and  pbd.legislation_code = pbt.legislation_code
  and  pbd.legislation_code = pdb.legislation_code;

    cursor csr_next_action_id is
    select pay_assignment_actions_s.nextval
    from   dual;

    /* Bug 5708255 */
  -------------------------------------------
  -- Added cursor to get value of global FBT_THRESHOLD
  --------------------------------------------
CURSOR  c_get_fbt_global(c_year_end DATE)
       IS
   SELECT  global_value
   FROM   ff_globals_f
    WHERE  global_name = 'FBT_THRESHOLD'
    AND    legislation_code = 'AU'
    AND    c_year_end BETWEEN effective_start_date
                          AND effective_end_date ;


    l_next_assignment_action_id       pay_assignment_actions.assignment_action_id%type;
    l_procedure                       varchar2(200) ;
    i                     number;

   l_lst_yr_start date;
   l_lst_fbt_yr_start date;

begin

  g_debug :=hr_utility.debug_enabled;
  if g_debug
  then
    l_procedure := '.assignment_action_code';
        hr_utility.set_location('Entering '||l_procedure,1);
  end if;

  g_arc_payroll_action_id := p_payroll_action_id;

/* Fetch Params */
open get_ps_params(p_payroll_action_id);
fetch get_ps_params into g_parameters;
close get_ps_params;


g_business_group_id := g_parameters.business_group_id;
g_start_date        := g_parameters.fin_year_start_date;
g_end_date          := g_parameters.fin_year_end_date;
g_tax_unit_id       := g_parameters.legal_employer;

/* Bug 5708255 */
open c_get_fbt_global (add_months(g_end_date,-3));
 fetch c_get_fbt_global into g_fbt_threshold;
 close c_get_fbt_global;


if (g_parameters.lst_year_term ='Y' or g_parameters.lst_year_term is NULL )
then
     l_lst_yr_start     :=  add_months(g_parameters.fin_year_start_date,-12);
     l_lst_fbt_yr_start :=  g_parameters.fbt_year_start_date;
else
     l_lst_yr_start     :=  TO_DATE('01-01-1900','DD-MM-YYYY');
     l_lst_fbt_yr_start :=  TO_DATE('01-01-1900','DD-MM-YYYY');
end if;

if g_debug
then
        hr_utility.set_location('p_payroll_action_id.........= ' || p_payroll_action_id,30);
        hr_utility.set_location('p_start_person..............= ' || p_start_person,30);
        hr_utility.set_location('p_end_person................= ' || p_end_person,30);
        hr_utility.set_location('g_parameters.business_group_id.........= ' || g_parameters.business_group_id,30);
        hr_utility.set_location('g_parameters.payroll_id..............= ' || g_parameters.payroll_id,30);
        hr_utility.set_location('g_parameters.legal_employer.........= ' || g_parameters.legal_employer,30);
        hr_utility.set_location('g_parameters.assignment_id.........= ' || g_parameters.assignment_id,30);
        hr_utility.set_location('g_parameters.fin_year_start_date..............= ' || g_parameters.fin_year_start_date,30);
        hr_utility.set_location('g_parameters.fin_year_end_date................= ' || g_parameters.fin_year_end_date,30);
        hr_utility.set_location('g_parameters.fbt_year_start_date..............= ' || g_parameters.fbt_year_start_date,30);
        hr_utility.set_location('g_parameters.fbt_year_end_date................= ' || g_parameters.fbt_year_end_date,30);
        hr_utility.set_location('g_parameters.employee_type..........= '||g_parameters.employee_type,30);
        hr_utility.set_location('g_parameters.delete_actions..........= '||g_parameters.delete_actions,30); /*Bug 4142159*/
        hr_utility.set_location('l_lst_yr_start.........................='||l_lst_yr_start,30);
        hr_utility.set_location('l_lst_fbt_yr_start.....................='||l_lst_fbt_yr_start,30);
        hr_utility.set_location('g_parameters.report_mode..........= '||g_parameters.report_mode,30); /*Bug 3891577*/
end if;

    /* SET FBT Defined_balance ID */
  If g_fbt_defined_balance_id is null OR g_fbt_defined_balance_id =0 Then
       Open  c_fbt_balance;
       Fetch c_fbt_balance into  g_fbt_defined_balance_id;
       Close c_fbt_balance;
 End if;

 IF (g_parameters.payroll_id <> '%' and g_parameters.assignment_id <> '%')
 THEN

            FOR csr_rec in  csr_assignment_only_paysum(p_payroll_action_id,
                                                         p_start_person,
                                                         p_end_person,
                                                         g_parameters.employee_type,
                                                         g_parameters.business_group_id,
                                                         g_parameters.legal_employer,
                                                         g_parameters.payroll_id,
                                                         g_parameters.fin_year_start_date,
                                                         g_parameters.fin_year_end_date,
                                                         l_lst_fbt_yr_start,
                                                         g_parameters.fbt_year_start_date,
                                                         g_parameters.fbt_year_end_date,
                                                         l_lst_yr_start,
                                                         g_fbt_defined_balance_id,
                                                         g_parameters.assignment_id)
            LOOP /* LOOP FOR Payment Summary - Archives for each Assignment ID*/

                     open csr_next_action_id;
                     fetch  csr_next_action_id into l_next_assignment_action_id;
                     close csr_next_action_id;

             IF g_debug THEN
                hr_utility.set_location('Calling hr_nonrun_asact.insact for assignment id :'||csr_rec.assignment_id,2);
             END if;

              hr_nonrun_asact.insact(l_next_assignment_action_id,
                                     csr_rec.assignment_id,
                                     p_payroll_action_id,
                                     p_chunk,
                                     null);

            END LOOP;
 ELSE

   /* Bug 7138494 - Added Changes for Range Person
       - Call Cursor using pay_population_ranges if Range Person Enabled
         Else call Old Cursor
   */

  IF range_person_on(g_parameters.report_mode)
  THEN

            FOR csr_rec in  csr_range_assignment_paysum(p_payroll_action_id,
                                                         p_chunk,
                                                         g_parameters.employee_type,
                                                         g_parameters.business_group_id,
                                                         g_parameters.legal_employer,
                                                         g_parameters.payroll_id,
                                                         g_parameters.fin_year_start_date,
                                                         g_parameters.fin_year_end_date,
                                                         l_lst_fbt_yr_start,
                                                         g_parameters.fbt_year_start_date,
                                                         g_parameters.fbt_year_end_date,
                                                         l_lst_yr_start,
                                                         g_fbt_defined_balance_id,
                                                         g_parameters.assignment_id)
            LOOP /* LOOP FOR Payment Summary - Archives for each Assignment ID*/

                     open csr_next_action_id;
                     fetch  csr_next_action_id into l_next_assignment_action_id;
                     close csr_next_action_id;

             IF g_debug THEN
                hr_utility.set_location('Calling hr_nonrun_asact.insact for assignment id :'||csr_rec.assignment_id,2);
             END if;

              hr_nonrun_asact.insact(l_next_assignment_action_id,
                                     csr_rec.assignment_id,
                                     p_payroll_action_id,
                                     p_chunk,
                                     null);

            END LOOP;

  ELSE /* Old Code - No Range Person */


        FOR csr_rec in  csr_assignment_paysum(p_payroll_action_id,
                                                 p_start_person,
                                                 p_end_person,
                                                 g_parameters.employee_type,
                                                 g_parameters.business_group_id,
                                                 g_parameters.legal_employer,
                                                 g_parameters.payroll_id,
                                                 g_parameters.fin_year_start_date,
                                                 g_parameters.fin_year_end_date,
                                                 l_lst_fbt_yr_start,
                                                 g_parameters.fbt_year_start_date,
                                                 g_parameters.fbt_year_end_date,
                                                 l_lst_yr_start,
                                                 g_fbt_defined_balance_id,
                                                 g_parameters.assignment_id)
            LOOP /* LOOP FOR Payment Summary - Arcbives for each Assignment ID*/

                     open csr_next_action_id;
                     fetch  csr_next_action_id into l_next_assignment_action_id;
                     close csr_next_action_id;

             IF g_debug THEN
                hr_utility.set_location('Calling hr_nonrun_asact.insact for assignment id :'||csr_rec.assignment_id,2);
             END if;

              hr_nonrun_asact.insact(l_next_assignment_action_id,
                                     csr_rec.assignment_id,
                                     p_payroll_action_id,
                                     p_chunk,
                                     null);

        END LOOP;
  END IF; /* End Range Person Check */
 END IF;

    if g_debug then
      hr_utility.set_location('Leaving '||l_procedure,1000);
    end if;
exception
    when others then
      hr_utility.set_location('Error in '||l_procedure,999999);
      raise;
end assignment_action_code;

  --------------------------------------------------------------------+
  -- Name  : Archive_code
  -- Type  : Procedure
  -- Access: Public
  -- This procedure archives employee details for Assignment in
  -- pay_action_information.
  -- Identifies if Assignment is an FBT or Normal Employee and
  -- fetches appropriate Balance values using BBR.
  --------------------------------------------------------------------+

procedure archive_code
(p_assignment_action_id     in pay_assignment_actions.assignment_action_id%type
,p_effective_date           in pay_payroll_actions.effective_date%type
)
is

  --------------------------------------------------------------------+
  -- Cursor      : c_employee_details
  -- Description : Fetches employee details to be displayed on Report.
  --               Latest Values as on End Date is fetched.
  --------------------------------------------------------------------+
cursor c_employee_details
( c_business_group_id hr_all_organization_units.organization_id%TYPE,
  c_archive_assignment_action_id number,
  c_start_date date,
  c_end_date date)
is
  select pap.full_name,
         paa.assignment_number,
             paa.assignment_id,
         to_number(pro.proposed_salary_n) actual_salary,
         paa.normal_hours,
         pps.actual_termination_date,
         pps.date_start,
         pgr.name grade,
             paa.organization_id,
         paa.payroll_id,
         hsc.segment1 tax_unit_id,
         hou.NAME organization_name,
         hou1.name legal_employer
--             papf.payroll_name                 /*Bug 4688800*/
  from  per_people_f pap,
        per_assignments_f paa,
    per_grades_tl pgr,
        per_periods_of_service pps,
        per_pay_bases ppb,
    per_pay_proposals pro,
    per_assignment_status_types past,
    hr_all_organization_units hou,
        pay_assignment_actions paa1
    ,hr_soft_coding_keyflex hsc
    ,hr_all_organization_units hou1
--  ,pay_payrolls_f        papf  /*Bug 4688800*/
  where  pap.person_id = paa.person_id
  and    paa.assignment_id = paa1.assignment_id
  and    paa1.assignment_action_id = c_archive_assignment_action_id
  and    paa.business_group_id = c_business_group_id
  and    paa.grade_id     = pgr.grade_id(+)
  and    pgr.language(+)  = userenv('LANG')
  and    paa.pay_basis_id  = ppb.pay_basis_id(+)
  and    paa.assignment_id = pro.assignment_id(+)
  AND    hou.organization_id = paa.organization_id
  and    hsc.soft_coding_keyflex_id = paa.soft_coding_keyflex_id
  and    hou1.organization_id       = hsc.segment1
--  and    papf.payroll_id            = paa.payroll_id /*Bug 4688800*/
--  and    c_end_date     between    papf.effective_start_date and papf.effective_end_date  /*Bug 4688800*/
  and    pps.period_of_service_id = paa.period_of_service_id
  and    paa.assignment_status_type_id = past.assignment_status_type_id
  and    paa.effective_end_date = ( select max(effective_end_date)
                                    from  per_assignments_f
                                    WHERE assignment_id  =  paa.assignment_id
                                    and effective_end_date >= c_start_date
                                    and effective_start_date <= c_end_date)
  and   c_end_date between pap.effective_start_date and pap.effective_end_date
  and   pps.person_id = pap.person_id
  and   pro.change_date(+) <= c_end_date
  and   nvl(pro.approved,'Y') = 'Y'
  and   nvl(pro.change_date,to_date('4712/12/31','YYYY/MM/DD')) = (select nvl(max(pro1.change_date),to_date('4712/12/31','YYYY/MM/DD'))
                             from per_pay_proposals pro1
                              where pro1.assignment_id(+) = paa.assignment_id
                              and pro1.change_date(+) <=  c_end_date
                              and nvl(pro1.approved,'Y')='Y');


/*Bug 4688800 - Introduced a new cursor to get the payroll name for the employee. This has been done to take care of cases
                    where assignment has payroll attached to it for few months but is not attached at the end of year*/
 CURSOR c_get_payroll_name(c_assignment_id number,
                           c_start_date date,
                           c_end_date date)
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

/* Bug 3891577 - Employee details cursor */
  --------------------------------------------------------------------+
  -- Cursor      : c_summary_employee_details
  -- Description : Fetches employee details to be displayed on
  --               Summary Report - Pay Sum Mode
  --               Latest Values as on End Date is fetched.
  --------------------------------------------------------------------+
cursor c_summary_employee_details
( c_business_group_id hr_all_organization_units.organization_id%TYPE,
  c_archive_assignment_action_id number,
  c_start_date date,
  c_end_date date)
is
 select  pap.full_name,
         paf.assignment_number,
         paf.assignment_id,
         pps.date_start,
         pps.actual_termination_date
  from  per_people_f pap,
        per_assignments_f paf,
        per_periods_of_service pps,
        pay_assignment_actions paa
  where  pap.person_id = paf.person_id
  and    paf.assignment_id = paa.assignment_id
  and    pps.person_id     = pap.person_id
  and    pps.period_of_service_id = paf.period_of_service_id
  and    paf.business_group_id = c_business_group_id
  and    paa.assignment_action_id = c_archive_assignment_action_id
  and    paf.effective_end_date = ( select max(effective_end_date)
                                    from  per_assignments_f
                                    WHERE assignment_id  =  paf.assignment_id
                                    and effective_end_date >= c_start_date
                                    and effective_start_date <= c_end_date)
  and   c_end_date between pap.effective_start_date and pap.effective_end_date;

  --------------------------------------------------------------------+
  -- Cursor      : get_max_action
  -- Description : Fetches Maximum Assignment Action Processed for
  --               Assignment between Start/End Dates
  --------------------------------------------------------------------+

  cursor get_max_action(c_assignment_id number
                     ,c_start_date date,c_end_date date
             ,c_tax_unit_id varchar2)
  is
    select  to_number(substr(max(lpad(paa.action_sequence,15,'0')||paa.assignment_action_id),16)) assignment_action_id
            ,max(paa.action_sequence) action_sequence
    from    pay_assignment_actions      paa
          , pay_payroll_actions         ppa
      , per_assignments_f           paf
    where   paa.assignment_id           = paf.assignment_id
    and     paf.assignment_id           = c_assignment_id
            and ppa.payroll_action_id   = paa.payroll_action_id
            and ppa.effective_date      between c_start_date and c_end_date
        and ppa.payroll_id        =  paf.payroll_id
            and ppa.action_type        in ('R', 'Q', 'I', 'V', 'B')
        and ppa.effective_date between paf.effective_start_date and paf.effective_end_date
            and paa.action_status='C'
        AND paa.tax_unit_id = c_tax_unit_id;

  --------------------------------------------------------------------+
  -- Cursor      : c_payment_summary_details
  -- Description : Fetches Manual PS Issued for Fin Year.
  --               Supports Legal Employer segment to have
  --               NULL,All,Legal Employer
  --------------------------------------------------------------------+

  cursor c_payment_summary_details(c_assignment_id number,
                                   c_fin_date date,
                   c_tax_unit_id pay_assignment_actions.tax_unit_id%TYPE)
  is
  select hr.meaning fin_year
  from per_assignment_extra_info pae,
       hr_lookups    hr
  where pae.aei_information_category = 'HR_PS_ISSUE_DATE_AU'
   and   pae.information_type   = 'HR_PS_ISSUE_DATE_AU'
   and   pae.assignment_id      = c_assignment_id
   and   pae.aei_information1   = to_char(c_fin_date,'YY')
   and   nvl(aei_information2,c_tax_unit_id) = decode(aei_information2,'-999',aei_information2,c_tax_unit_id)
   and   pae.aei_information1   = hr.lookup_code
   and   hr.lookup_type         = 'AU_PS_FINANCIAL_YEAR';


l_procedure                       varchar2(200) ;

l_employee_details  c_employee_details%ROWTYPE;
l_fin_year varchar2(80);

l_action_sequence number;
l_assignment_action_id number;
l_dummy_action_sequence number;

  e_prepost_error exception;
  l_pre01jul1983_days            NUMBER;
  l_post30jun1983_days           NUMBER;
  l_pre01jul1983_ratio           NUMBER;
  l_post30jun1983_ratio          NUMBER;
  l_pre01jul1983_value           NUMBER;
  l_post30jun1983_value          NUMBER;
  l_etp_service_date             date;
  l_le_etp_service_date          date;     /* Bug 4177679 */
  l_result                       NUMBER;

/* Set Archive Check Date */
l_lst_fbt_yr_start date;
l_payroll_id           number;    /*Bug 4688800*/
l_payroll_name         pay_payrolls_f.payroll_name%type;    /*Bug 4688800*/
l_etp_new_bal_total number ;  /* Bug 9226023 - Variable declared to hold the sum of Taxable and Tax Free portions of
                                                 ETP balances introduced as part of bug 8769345*/
begin

    g_debug :=hr_utility.debug_enabled ;

    if g_debug then
      l_procedure  := g_package||'archive_code';
      hr_utility.set_location('Entering '||l_procedure,300);
      hr_utility.set_location('p_assignment_action_id......= '|| p_assignment_action_id,10);
      hr_utility.set_location('p_effective_date............= '|| to_char(p_effective_date,'DD-MON-YYYY'),10);
    end if;

    if (g_parameters.lst_year_term ='Y' or g_parameters.lst_year_term is NULL )
    then
         l_lst_fbt_yr_start :=  g_parameters.fbt_year_start_date;
    else
         l_lst_fbt_yr_start :=  TO_DATE('01-01-1900','DD-MM-YYYY');
    end if;

/* Bug 3891577 - Checks added for Summary/Detail Report.
   Based on Report Mode flag,appropriate cursors will be called and employee details fetched
   Start Bug 3891577 */
   if g_parameters.report_mode = 'D' /* Detail Report */
   then
       open  c_employee_details(g_business_group_id,p_assignment_action_id,add_months(g_start_date,-3),g_end_date);
       fetch c_employee_details into l_employee_details;
       if c_employee_details%notfound
       then
           if g_debug then
            hr_utility.set_location('No Employee details found!!',3002);
           end if;
       end if;
       close c_employee_details;

    else /* Summary Report */

       open  c_summary_employee_details(g_business_group_id,p_assignment_action_id,add_months(g_start_date,-3),g_end_date);
       fetch c_summary_employee_details into l_employee_details.full_name,
                                             l_employee_details.assignment_number,
                                             l_employee_details.assignment_id,
                                             l_employee_details.date_start,
                                             l_employee_details.actual_termination_date;
       close c_summary_employee_details;

    end if;
/* End Bug 3891577*/

/* Bug 4726352 - Manual PS Details fetched for both Summary and Detail Report
Get Manual PS Issued and store in l_fin_year */

        OPEN c_payment_summary_details(l_employee_details.assignment_id,g_start_date,g_tax_unit_id);
        FETCH c_payment_summary_details into l_fin_year;
        CLOSE c_payment_summary_details;


   /*Bug 4688800*/
    OPEN c_get_payroll_name(l_employee_details.assignment_id,g_start_date,g_end_date);
    FETCH c_get_payroll_name INTO l_payroll_id, l_payroll_name;
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
                assignment_id)
            values(
                    pay_action_information_s.nextval,
                    g_arc_payroll_action_id,
                    'PA',
                    p_effective_date,
                    null,
                    l_employee_details.tax_unit_id,
                    'AU_EMPLOYEE_RECON_DETAILS',
                    l_employee_details.full_name,
                    l_employee_details.assignment_number,
                    l_employee_details.actual_salary,
                    l_employee_details.grade,
                    l_employee_details.normal_hours,
                    l_employee_details.actual_termination_date,
                    l_fin_year,
                    l_employee_details.organization_id,
                    g_tax_unit_id,
                    l_employee_details.payroll_id,
                    l_employee_details.organization_name,
                    l_employee_details.legal_employer,
                    l_payroll_name,      /*Bug 4688800*/
                    l_employee_details.assignment_id);


/* Reset all Global Values */
  g_fbt_balance_value := 0;
  g_allowance_balance_value := 0;


  if g_debug then
     hr_utility.set_location('Assignment_id' ||l_employee_details.assignment_id,300);
  end if;

open get_max_action(l_employee_details.assignment_id,g_start_date,g_end_date,g_tax_unit_id);
fetch get_max_action into l_assignment_action_id,l_action_sequence;

if get_max_action%notfound then
     /* No Runs in the Financial Year - FBT Employee*/
     l_assignment_action_id := null;
     l_action_sequence      := null;
end if;
close get_max_action;

  if g_debug then
     hr_utility.set_location('Assignment_ACTION_id ' ||l_assignment_action_id,300);
  end if;

if ( l_employee_details.actual_termination_date is NOT NULL
    and l_employee_details.actual_termination_date
         between l_lst_fbt_yr_start and g_parameters.fbt_year_end_date
    and l_assignment_action_id IS NULL)
then
/* Employee is FBT employee */
/* Archive only FBT Balance - Set all other Balance Values to 0 */

      if g_debug
      then
    hr_utility.set_location('FBT Employee Assignment ID======.....'||l_employee_details.assignment_id,300);
      end if;

    get_fbt_balance(p_assignment_id => l_employee_details.assignment_id
                    ,p_start_date   => add_months(g_start_date,-3)
            ,p_end_date     => g_start_date-1
            ,p_action_sequence => l_action_sequence
            );

      if g_debug
      then
    hr_utility.set_location('FBT Balance Value ======.....'||g_fbt_balance_value,300);
      end if;

        g_result_table.delete;
    FOR i in 1..22
    LOOP
    g_result_table(i).balance_value := 0;
    END LOOP;

    l_pre01jul1983_ratio  := 0;
    l_post30jun1983_ratio := 0;
else
/* Not an FBT Employee - Set all Balances */
    get_fbt_balance(p_assignment_id => l_employee_details.assignment_id
                    ,p_start_date   => add_months(g_start_date,-3)
            ,p_end_date     => add_months(g_end_date,-3)
            ,p_action_sequence => l_dummy_action_sequence
            );

        g_result_table.delete;
    g_context_table.delete;

    g_context_table(1).tax_unit_id := g_tax_unit_id;

    if (l_assignment_action_id is NOT NULL)
        then
        pay_balance_pkg.get_value(p_assignment_action_id => l_assignment_action_id,
                       p_defined_balance_lst=>g_balance_value_tab,
                       p_context_lst =>g_context_table,
                       p_output_table=>g_result_table);

    else
        if g_debug then
        hr_utility.set_location('Assingment Action ID not found for Run in Year!!',300);
            end if;
    end if;

      if g_debug
      then
    hr_utility.set_location('FBT Balance Value ======.....'||g_fbt_balance_value,100);
    hr_utility.trace('Balance values for YTD dimension');
    hr_utility.trace('-------------------------------------');
    hr_utility.trace('Earnings_Total          ===>'||g_result_table(1).balance_value);
        hr_utility.trace('Workplace Giving Deductions  ===>' || g_balance_value_tab(21).defined_balance_id);
    hr_utility.trace('Direct Payments         ===>'||g_result_table(2).balance_value);
    hr_utility.trace('Termination_Payments    ===>'||g_result_table(3).balance_value);
    hr_utility.trace('Involuntary Deductions  ===>'||g_result_table(4).balance_value);
    hr_utility.trace('Pre Tax Deductions      ===>'||g_result_table(5).balance_value);
    hr_utility.trace('Termination Deductions  ===>'||g_result_table(6).balance_value);
    hr_utility.trace('Voluntary Deductions    ===>'||g_result_table(7).balance_value);
    hr_utility.trace('Total_Tax_Deduction     ===>'||g_result_table(8).balance_value);
    hr_utility.trace('Earnings_Non_Taxable    ===>'||g_result_table(9).balance_value);
    hr_utility.trace('Employer_Charges        ===>'||g_result_table(10).balance_value);
    hr_utility.trace('Lump Sum A Payments     ===>'||g_result_table(11).balance_value);
    hr_utility.trace('Lump Sum B Payments     ===>'||g_result_table(12).balance_value);
    hr_utility.trace('Lump Sum C Payments     ===>'||g_result_table(13).balance_value);
    hr_utility.trace('Lump Sum D Payments     ===>'||g_result_table(14).balance_value);
    hr_utility.trace('Lump Sum E Payments     ===>'||g_result_table(15).balance_value);
    hr_utility.trace('Invalidity Payments     ===>'||g_result_table(16).balance_value);
    hr_utility.trace('CDEP            ===>'||g_result_table(17).balance_value);
    hr_utility.trace('Leave Payments Marginal ===>'||g_result_table(18).balance_value);
    hr_utility.trace('Reportable Employer Superannuation Contributions        ===>'||g_result_table(19).balance_value); /* Bug 8587013 */
    hr_utility.trace('Union Fees          ===>'||g_result_table(20).balance_value);
    hr_utility.trace('Exempt Foreign Employment Income  ===>'||g_result_table(22).balance_value);    /* Bug 8587013 */
    hr_utility.trace('ETP Tax Free Payments Transitional Not Part of Prev Term  ===>' || g_result_table(23).balance_value); /* Start 8769345 */
    hr_utility.trace('ETP Tax Free Payments Transitional Part of Prev Term      ===>' || g_result_table(24).balance_value);
    hr_utility.trace('ETP Tax Free Payments Life Benefit Not Part of Prev Term  ===>' || g_result_table(25).balance_value);
    hr_utility.trace('ETP Tax Free Payments Life Benefit Part of Prev Term      ===>' || g_result_table(26).balance_value);
    hr_utility.trace('ETP Taxable Payments Transitional Not Part of Prev Term   ===>' || g_result_table(27).balance_value);
    hr_utility.trace('ETP Taxable Payments Transitional Part of Prev Term       ===>' || g_result_table(28).balance_value);
    hr_utility.trace('ETP Taxable Payments Life Benefit Not Part of Prev Term   ===>' || g_result_table(29).balance_value);
    hr_utility.trace('ETP Taxable Payments Life Benefit Part of Prev Term       ===>' || g_result_table(30).balance_value); /* End 8769345 */
    hr_utility.trace('Retro Earnings Leave Loading GT 12 Mths Amount     ===>' || g_result_table(31).balance_value); -- start 8711855
    hr_utility.trace('Retro Earnings Spread GT 12 Mths Amount    ===>' || g_result_table(32).balance_value);
    hr_utility.trace('Retro Pre Tax GT 12 Mths Amount     ===>' || g_result_table(33).balance_value);        -- end 8711855
     end if;

    /* Call procedure to Adjust Lump SUM E Payments Value
    */
       /* Bug 4201894 - Initialize the g_adjusted_lump_sum_e_pay Value */
       /* Bug 9190980 - Initialize g_adj_lump_sum_pre_tax global variable */
        g_adjusted_lump_sum_e_pay := 0;
        g_adj_lump_sum_pre_tax    := 0;

       Adjust_lumpsum_E_payments(l_employee_details.assignment_id);

       if g_debug
       then
        hr_utility.trace('Lump Sum E Payments     ===>'||g_result_table(15).balance_value);
       end if;

    /* If Lump Sum C Payments get Pre-Post Ratios
    */

      if (g_result_table(13).balance_value > 0)
      then
         l_result := pay_au_terminations.etp_prepost_ratios(
                     l_employee_details.assignment_id              -- number                  in
                    ,l_employee_details.date_start                 -- date                    in
                    ,l_employee_details.actual_termination_date    -- date                    in
                    ,'N'                          -- Bug#2819479 Flag to check whether this function called by Termination Form.
                    ,l_pre01jul1983_days          -- number                  out
                    ,l_post30jun1983_days         -- number                  out
                    ,l_pre01jul1983_ratio         -- number                  out
                    ,l_post30jun1983_ratio        -- number                  out
                    ,l_etp_service_date            -- date                    out
                    ,l_le_etp_service_date
                     );         -- date                    out   /* Bug 4177679 */

         if l_result = 0 then
                raise e_prepost_error;
         end if;
     else
        l_pre01jul1983_ratio  := 0;
        l_post30jun1983_ratio := 0;
     end if;

     /* Start 9226023 - Added logic to support the calculation Taxable and Tax Free portions of ETP
	                 for terminated employees processed before applying the patch 8769345 */
      if (g_result_table(13).balance_value > 0 OR g_result_table(16).balance_value > 0)
      then
           l_etp_new_bal_total := g_result_table(23).balance_value + g_result_table(24).balance_value +
                                  g_result_table(25).balance_value + g_result_table(26).balance_value +
                                  g_result_table(27).balance_value + g_result_table(28).balance_value +
                                  g_result_table(29).balance_value + g_result_table(30).balance_value ;

	  if (l_etp_new_bal_total > 0)
	  then
	     if ((g_result_table(13).balance_value - l_etp_new_bal_total) = 0)
             then
                 g_tax_free_etp := g_result_table(23).balance_value + g_result_table(24).balance_value +
                                   g_result_table(25).balance_value + g_result_table(26).balance_value +
                                   g_result_table(16).balance_value;

                 g_taxable_etp :=  g_result_table(27).balance_value + g_result_table(28).balance_value +
                                   g_result_table(29).balance_value + g_result_table(30).balance_value;

	     elsif ((g_result_table(13).balance_value - l_etp_new_bal_total ) > 0)
	     then
                 g_tax_free_etp:= ((g_result_table(13).balance_value - l_etp_new_bal_total) * l_pre01jul1983_ratio) +
		                   g_result_table(23).balance_value + g_result_table(24).balance_value +
                                   g_result_table(25).balance_value + g_result_table(26).balance_value +
                                   g_result_table(16).balance_value ;

                 g_taxable_etp := ((g_result_table(13).balance_value - l_etp_new_bal_total) * l_post30jun1983_ratio) +
 	                           g_result_table(27).balance_value + g_result_table(28).balance_value +
                                   g_result_table(29).balance_value + g_result_table(30).balance_value;

	     end if;
	   else
	         g_tax_free_etp:= (g_result_table(13).balance_value * l_pre01jul1983_ratio) + g_result_table(16).balance_value ;
                 g_taxable_etp := (g_result_table(13).balance_value * l_post30jun1983_ratio);
	   end if;
       end if;
      /* End 9226023 */
/* Bug 3891577 -
   1) Element details archived only for Detail Report
 Start Bug 3891577
*/
    if g_parameters.report_mode ='D' /* Detail Report */
    then
        archive_element_details(p_assignment_action_id
                              ,l_employee_details.assignment_id
                              ,p_effective_date
                              ,l_pre01jul1983_ratio
                              ,l_post30jun1983_ratio);
    end if;
/* End Bug 3891577 */

   /*bug 7571001 - Call get_allowance_balances for detail and summary reports */
    get_allowance_balances(l_employee_details.assignment_id,l_assignment_action_id);

end if; /* End of Not an FBT Employee */


       archive_balance_details(p_assignment_action_id
                              ,l_employee_details.assignment_id
                  ,p_effective_date
                  ,l_pre01jul1983_ratio
                  ,l_post30jun1983_ratio
                  ,l_action_sequence);

    if g_debug then
         hr_utility.set_location('Leaving '||l_procedure,300);
    end if;

end archive_code;

  --------------------------------------------------------------------+
  -- Name  : Get_fbt_balance
  -- Type  : Procedure
  -- Access: Public
  -- This procedure archives sets the FBT Balance Value for an
  -- Assignment. Based in Input Start/End Dates Max Assignment Action
  -- is fetched. FBT Balance Value computed using Globals FBT_Rate
  -- and Medicare Levy
  --------------------------------------------------------------------+


procedure get_fbt_balance(p_assignment_id in pay_assignment_actions.assignment_id%type
                         ,p_start_date in date
             ,p_end_date in date
             ,p_action_sequence out nocopy number)
is
   cursor c_max_assignment_action_id(
    c_assignment_id pay_assignment_actions.assignment_id%TYPE,
    c_tax_unit_id pay_assignment_actions.tax_unit_id%TYPE,
    c_start_date date,
    c_end_date date)
    IS
    select  to_number(substr(max(lpad(paa.action_sequence,15,'0')||paa.assignment_action_id),16)) assignment_action_id
            ,max(paa.action_sequence) action_sequence
    from    pay_assignment_actions      paa
          , pay_payroll_actions         ppa
      , per_assignments_f           paf
    where   paa.assignment_id           = paf.assignment_id
    and     paf.assignment_id           = c_assignment_id
            and ppa.payroll_action_id   = paa.payroll_action_id
            and ppa.effective_date      between c_start_date and c_end_date
        and ppa.payroll_id        =  paf.payroll_id
            and ppa.action_type        in ('R', 'Q', 'I', 'V', 'B')
        and ppa.effective_date between paf.effective_start_date and paf.effective_end_date
            and paa.action_status='C'
        AND paa.tax_unit_id = c_tax_unit_id;

  CURSOR  c_get_global(c_name     VARCHAR2
                       ,c_year_end DATE)
  IS
  SELECT  global_value
  FROM   ff_globals_f
  WHERE  global_name = c_name
  AND    legislation_code = 'AU'
  AND    c_year_end BETWEEN effective_start_date
                          AND effective_end_date ;

  r_global c_get_global%ROWTYPE;
  l_bal_value number;
  l_max_assignment_action_id  pay_assignment_actions.assignment_action_id%type;
  l_max_action_sequence       pay_assignment_actions.action_sequence%type;
  l_med_levy number;
  l_fbt_rate number;

  l_procedure varchar2(240);

begin

     g_debug := hr_utility.debug_enabled;

     if g_debug then
         l_procedure := g_package||'.Get_fbt_balance' ;
     hr_utility.set_location('Entering '||l_procedure,400);
     end if;

     open c_max_assignment_action_id(p_assignment_id,g_tax_unit_id,p_start_date,p_end_date);
     fetch c_max_assignment_action_id into l_max_assignment_action_id,l_max_action_sequence;
     close c_max_assignment_action_id;

     if (l_max_assignment_action_id is NOT null)
     then
     l_bal_value := pay_balance_pkg.get_value(g_fbt_defined_balance_id
                                    ,l_max_assignment_action_id
                    ,g_tax_unit_id
                    ,null,null,null,null,null);

     /* Bug 4133326 - Added FBT Balance > 1000 Check */
          if (l_bal_value <= to_number(g_fbt_threshold))  /* Bug 5708255 */
          then
              l_bal_value := 0;
          end if;
     else
     l_bal_value := 0;
     end if;

     open c_get_global('FBT_RATE',add_months(g_end_date,-3));  /* Add_months included for bug 5333143 */
     fetch c_get_global into r_global;
     close c_get_global;

     l_fbt_rate := to_number(r_global.global_value);

     open c_get_global('MEDICARE_LEVY',add_months(g_end_date,-3));  /* Add_months included for bug 5333143 */
     fetch c_get_global into r_global;
     close c_get_global;

     l_med_levy := to_number(r_global.global_value);

     g_fbt_balance_value := l_bal_value / (1 - (l_fbt_rate + l_med_levy));

     if g_debug then
            hr_utility.set_location('Fringe Balance Value got := '||l_bal_value,302);
        hr_utility.set_location('Value to be archived     := '||g_fbt_balance_value,302);
     end if;

     p_action_sequence :=  l_max_action_sequence;

     if g_debug then
     hr_utility.set_location('Leaving '||l_procedure,400);
     end if;

end;

  --------------------------------------------------------------------+
  -- Name  : Archive_element_details
  -- Type  : Procedure
  -- Access: Public
  -- This procedure identifies all Elements processed for Assignment
  -- in Financial Year.
  -- Archives all The Lump Sum Payments and ETP payments.
  -- In case of Allowance elements,builds a PL/SQL table with
  -- the Allowance Balance_Type_ID's
  --------------------------------------------------------------------+

procedure archive_element_details(p_assignment_action_id in pay_assignment_actions.assignment_action_id%TYPE
                                  ,p_assignment_id in pay_assignment_actions.assignment_id%TYPE
                  ,p_effective_date in date
                  ,p_pre01jul1983_ratio in number
                  ,p_post30jun1983_ratio in number)
is

  --------------------------------------------------------------------+
  -- Cursor      : c_ps_element_details
  -- Description : Fetches all Elements processed for Assignment.
  --               Ignores elements feeding Lump Sum Payment Balances
  --               and Invalidity Payments.
  --------------------------------------------------------------------+
  /* Bug 4179109 - Check for Non Taxable Allowances included */
  /* Bug 5063359 - Modified decode for Employer Charges to return classification as Employer Charges rather than Employer Superannuation Contribution */
  /* Bug 5119734 - Modified decode to check for Allowances if classifcation is Earnings */
/*Bug 5603254 -  Removed tables piv2 and prrv2  and their joins from cursor , added a call to function pay_au_rec_det_archive.get_element_payment_hours to get the value for hours and rate */
/*Bug 5846278 - Added Lump Sum E Payments in Not exists Clause */
/* bug 7571001 - Removed Allowance classification from the existing cursor */
/*bug 9190980 - Added Retro Earnings Leave Loading GT 12 Mths Amount, Retro Earnings Spread GT 12 Mths Amount for Lump Sum E in Not Exist clause
                Retro Pre Tax GT 12 Mths Amount is commented out because it is to be reported in Pre Tax Deductions section*/
/* Bug 9190980 - Uncommented Retro Pre Tax GT 12 Mths Amount element such that it is not reported */
  cursor c_ps_element_details
  (c_assignment_id pay_assignment_actions.assignment_id%TYPE,
   c_business_group_id hr_all_organization_units.organization_id%TYPE,
   c_tax_unit_id pay_assignment_actions.tax_unit_id%TYPE,
   c_start_date date,
   c_end_date date)
  is
  select element_name,label classification_name,sum(amount) payment,sum(hours) hours,rate
  from
  (select distinct
      nvl(pet.reporting_name, pet.element_name) element_name,
          decode(instr(pec.classification_name,  'Earnings'),  0,  null,
          decode(pec2.classification_name,  'Non Taxable', 'Non Taxable Earnings','Taxable Earnings'))|| /* Bug 4179109, 5119734, 7571001*/
          decode(instr(pec.classification_name,  'Payments'),  0,  null,
          decode(instr(pec.classification_name,  'Direct'),  0,  'Taxable Earnings',  'Direct Payments')) ||
          decode(instr(pec.classification_name,  'Deductions'),  0,  null,
          decode(pec.classification_name , 'Termination Deductions' , 'Tax Deductions'
                                          , 'Involuntary Deductions' , 'Post Tax Deductions'
                                          , 'Voluntary Deductions' , 'Post Tax Deductions'
                                              , pec.classification_name )) ||
          decode(instr(pec.classification_name, 'Employer Charges'), 0,null,'Employer Charges') label,
          prrv1.result_value amount,
pay_au_rec_det_archive.get_element_payment_hours(prr.assignment_action_id,pet.element_type_id,prr.run_result_id,ppa.effective_date) hours, /*Bug 5603254 */
decode(pay_au_rec_det_archive.get_element_payment_rate(prr.assignment_action_id,pet.element_type_id,prr.run_result_id,ppa.effective_date), null,
       (prrv1.result_value/pay_au_rec_det_archive.get_element_payment_hours(prr.assignment_action_id,pet.element_type_id,prr.run_result_id, ppa.effective_date)),
    pay_au_rec_det_archive.get_element_payment_rate(prr.assignment_action_id,pet.element_type_id,prr.run_result_id,ppa.effective_date)) rate, /* 5599310 */
      prr.run_result_id,
      paa.source_action_id
   from   pay_element_types_f pet
     ,pay_input_values_f piv1
     ,pay_element_classifications pec
     ,pay_assignment_actions paa
     ,pay_payroll_actions ppa
     ,per_assignments_f paaf
     ,pay_run_results prr
     ,pay_run_result_values prrv1
     ,pay_element_classifications pec2
     ,pay_sub_classification_rules_f pscr
  where   pet.element_type_id    = piv1.element_type_id
   and   pet.element_type_id      = prr.element_type_id
  and   prr.assignment_action_id = paa.assignment_action_id
  and   paaf.assignment_id       = paa.assignment_id
  and   paaf.business_group_id   = c_business_group_id
  and   prr.run_result_id        = prrv1.run_result_id
  and   prrv1.input_value_id      = piv1.input_value_id
  and   pet.classification_id    = pec.classification_id
  and   pec.legislation_code = 'AU'
  and   paaf.assignment_id        = c_assignment_id
  and   paaf.payroll_id = ppa.payroll_id
  and   ppa.effective_date between c_start_date and c_end_date
  and   ppa.action_type in ('Q','R','I','B','V')
  and   paa.action_status = 'C'
  and   paa.tax_unit_id like c_tax_unit_id
  and   paa.payroll_action_id    = ppa.payroll_action_id
  and   piv1.name = 'Pay Value'
  and    pet.classification_id = pec.classification_id
  and    (instr(pec.classification_name, 'Earnings') > 0
  or     instr(pec.classification_name, 'Payments') > 0
  or     instr(pec.classification_name, 'Deductions') > 0
  or     instr(pec.classification_name, 'Employer Charges' ) > 0 )
  and    pet.element_type_id = pscr.element_type_id (+)
  and    ppa.effective_date between nvl(pscr.effective_start_date, ppa.effective_date)
  and    nvl(pscr.effective_end_date, ppa.effective_date)
  and    pscr.classification_id = pec2.classification_id(+)
  and   ppa.date_earned between pet.effective_start_date and pet.effective_end_date
  and   ppa.effective_date between paaf.effective_start_date and paaf.effective_end_date
  and   prr.status in ('P','PA')
  and   NOT EXISTS
         (
            select 1
            from pay_run_results prr1,
                 pay_element_types_f pet1
            where prr1.assignment_action_id = paa.assignment_action_id
            and   prr1.element_type_id      = pet1.element_type_id
            and   pet1.element_name in ('Retropay GT 12 Mths Amount',
                                        'Retro Pre Tax GT 12 Mths Amount', /*start 9190980*/
                                        'Retropay Earnings Spread GT 12 Mths Amount',
                                        'Retropay Earnings Leave Loading GT 12 Mths Amount') /*end 9190980*/
            and   prr1.source_id = prr.source_id
                        and   prr.source_type='E'    /*Bug 4363057 */
         )
  and   NOT EXISTS
        (
        select 1
        from pay_balance_feeds_f pbf,
             pay_balance_types pbt
        where pbt.balance_type_id = pbf.balance_type_id
        and   pbt.balance_name in ('Invalidity Payments','Lump Sum A Payments',
                                   'Lump Sum B Payments','Lump Sum C Payments',
                                   'Lump Sum D Payments','Lump Sum E Payments',/*Bug 5846278 */
                                   'Retro Pre Tax GT 12 Mths Amount',                /*start 9190980*/
                                   'Retro Earnings Leave Loading GT 12 Mths Amount',
                                   'Retro Earnings Spread GT 12 Mths Amount') /*end 9190980*/
        and   pbf.input_value_id = piv1.input_value_id
       )
  and not exists  /* added for bug 7571001 */
      (
      select 1
      from
        PAY_BALANCE_ATTRIBUTES pba
       ,pay_defined_balances pdb
       ,pay_balance_dimensions pbd
       ,PAY_BALANCE_FEEDS_F pbf
       where pba.attribute_id = g_attribute_id
     AND pba.defined_balance_id = pdb.defined_balance_id
     AND pbd.balance_dimension_id = pdb.balance_dimension_id
     AND pbd.dimension_name = '_ASG_LE_YTD'
     AND pdb.balance_type_id = pbf.balance_type_id
     AND pbf.input_value_id = piv1.input_value_id
      )
 )
 group by element_name,label,rate;

 /* bug 7571001 - Added the new cursor for Allowance classification */
 /* Bug 8760756 - Added join between pay_run_result_values and pay_input_values_f tables and
                  a condition to fetch amount value only if the element input value is of 'Pay Value'.
                  Removed references to hours and rate columns from the cursor ,as they are not displayed anywhere in EOY reports. */
cursor c_ps_alw_details
  (c_assignment_id pay_assignment_actions.assignment_id%TYPE,
   c_business_group_id hr_all_organization_units.organization_id%TYPE,
   c_tax_unit_id pay_assignment_actions.tax_unit_id%TYPE,
   c_start_date date,
   c_end_date date) is
   select element_name,label, sum(amount) payment
  from
  (select distinct
      nvl(pet.reporting_name, pet.element_name) element_name,
          'Allowance' label,  -- bug 7571001 Allowance only
          prrv.result_value amount,
      prr.run_result_id,
      pac.source_action_id
FROM
     pay_balance_attributes pba
     ,pay_defined_balances   pdb
     ,pay_balance_dimensions pbd
     ,pay_balance_feeds_f pbf
     ,pay_element_types_f pet
     ,pay_input_values_f piv
     ,per_all_assignments_f paa
     ,pay_assignment_actions pac
     ,pay_payroll_actions ppa
     ,pay_run_results prr
     ,pay_run_result_values prrv
WHERE pba.attribute_id         = g_attribute_id
AND   pdb.defined_balance_id   = pba.defined_balance_id
AND pbd.balance_dimension_id = pdb.balance_dimension_id
AND pbd.dimension_name = '_ASG_LE_YTD'
AND pbd.legislation_code = 'AU'
AND   pdb.balance_type_id = pbf.balance_type_id
AND   pbf.input_value_id = piv.input_value_id
and   piv.name ='Pay Value' -- Bug 8760756
AND   piv.element_type_id = pet.element_type_id
AND   pac.assignment_id               = c_assignment_id
and    pac.tax_unit_id                 = c_tax_unit_id
and    paa.assignment_id               = pac.assignment_id
and    pac.payroll_action_id           = ppa.payroll_Action_id
and    ppa.payroll_id                  = paa.payroll_id
and    ppa.action_type                 in ('Q','R','B','I','V')
and    pac.assignment_action_id        = prr.assignment_Action_id
and    prr.element_type_id             = pet.element_type_id
and    prr.run_result_id = prrv.run_result_id
and    prrv.input_value_id = piv.input_value_id  -- Bug 8760756
AND   prr.status in ('P','PA')
AND   pac.action_status ='C'
and    ppa.effective_date between c_start_date and c_end_date
and    ppa.effective_date between paa.effective_start_date and paa.effective_end_date
and    ppa.effective_date between piv.effective_start_date and piv.effective_end_date
and    ppa.effective_date between pet.effective_start_date and pet.effective_end_date
and    ppa.effective_date between pbf.effective_start_date and pbf.effective_end_date
 )
 group by element_name,label
 ;

  TYPE char_tab_type      IS TABLE OF VARCHAR2(350)  INDEX BY BINARY_INTEGER;
  TYPE num_tab_type       IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

  l_prev_bal_type_id number;
  l_procedure    varchar2(240);

  l_ele_name char_tab_type;
  l_ele_pay_value num_tab_type;
  l_ele_classification_name char_tab_type;

  counter number;

begin

     g_debug := hr_utility.debug_enabled;
     l_prev_bal_type_id := 0;

     if g_debug
     then
        l_procedure := g_package||'Element_Details';
        hr_utility.set_location('Entering ' || l_procedure,500);
     end if;

    FOR csr_ele_det IN c_ps_element_details(p_assignment_id,g_business_group_id,g_tax_unit_id,g_start_date,g_end_date)
    LOOP

        if g_debug
        then
        hr_utility.set_location('Element Name '||csr_ele_det.element_name,500);
        hr_utility.set_location('Classification Name '||csr_ele_det.classification_name,500);
        end if;

        insert into pay_action_information (
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
                    action_information4,
                    action_information5,
                    action_information6,
                    assignment_id)
                values (
                      pay_action_information_s.nextval,
                      p_assignment_action_id,
                      'AAP',
                      p_effective_date,
                      null,
                      g_tax_unit_id,
                      'AU_ELEMENT_RECON_DETAILS',
                      csr_ele_det.element_name,
                      csr_ele_det.classification_name,
                      null,
                      csr_ele_det.hours,
                      csr_ele_det.rate,
                      csr_ele_det.payment,
                      p_assignment_id);

        if g_debug then
           hr_utility.set_location('After Inserting Element Values ',500);
            end if;
     END LOOP;

   FOR csr_alw_det IN c_ps_alw_details(p_assignment_id,g_business_group_id,g_tax_unit_id,g_start_date,g_end_date)  LOOP

        if g_debug
        then
        hr_utility.set_location('Element Name '||csr_alw_det.element_name,600);
        end if;

/* Bug 8760756 -  As hours and rate columns are removed from c_ps_alw_details cursor query ,
                  the corresponding column values in pay_action_information table are made null */

        insert into pay_action_information (
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
                    action_information4,
                    action_information5,
                    action_information6,
                    assignment_id)
                values (
                      pay_action_information_s.nextval,
                      p_assignment_action_id,
                      'AAP',
                      p_effective_date,
                      null,
                      g_tax_unit_id,
                      'AU_ELEMENT_RECON_DETAILS',
                      csr_alw_det.element_name,
                      'Allowance',
                      null,
                      null, -- Bug 8760756
                      null, -- Bug 8760756
                      csr_alw_det.payment,
                      p_assignment_id);

        if g_debug then
           hr_utility.set_location('After Inserting Allowance Element Values ',600);
            end if;
     END LOOP;

/* Now Archive Lump Sum Payments and Invalidity */
/* Use g_result_values_tab to get the Values
    'Lump Sum A Payments      ===>'  g_result_table(11).balance_value
    'Lump Sum B Payments      ===>'  g_result_table(12).balance_value
    'Lump Sum C Payments      ===>'  g_result_table(13).balance_value
    'Lump Sum D Payments      ===>'  g_result_table(14).balance_value
    'Lump Sum E Payments      ===>'  g_result_table(15).balance_value
    'Invalidity Payments      ===>'  g_result_table(16).balance_value
*/

            if g_debug then
           hr_utility.set_location('p_pre01jul1983_ratio........=>'||p_pre01jul1983_ratio,200);
           hr_utility.set_location('p_post30jun1983_ratio........=>'||p_post30jun1983_ratio,200);
        end if;

            counter := 0;
        if (g_result_table(11).balance_value > 0)
        then
               counter := counter + 1;
           l_ele_name(counter)                := 'Lump Sum A Payment';
           l_ele_pay_value(counter)           := g_result_table(11).balance_value;
           l_ele_classification_name(counter) := 'Lump Sum A Payments';
            end if;
        if (g_result_table(12).balance_value > 0)
        then
               counter := counter + 1;
           l_ele_name(counter)                := 'Lump Sum B Payment';
           l_ele_pay_value(counter)           := g_result_table(12).balance_value;
           l_ele_classification_name(counter) := 'Lump Sum B Payments';
            end if;
        /* Bug 8769345 - The sum of all ETP Tax Free balances constitue pre 83 ETP component and
                         the sum of all ETP Taxable balances constitute post 83 ETP component */
        /* Bug 9146069 - Changed the terms for Lump Sum C Payments */
        /* Bug 9226023 - Added global variables to store Taxable and Tax Free values */
	if (g_result_table(13).balance_value > 0 OR g_result_table(16).balance_value > 0)
	then
	     counter := counter + 1;
           l_ele_name(counter)                := 'Tax Free Component';
	   l_ele_pay_value(counter)           := g_tax_free_etp;
           l_ele_classification_name(counter) := 'Lump Sum C Payments';

	      counter := counter + 1;
           l_ele_name(counter)                := 'Taxable Component';
           l_ele_pay_value(counter)           := g_taxable_etp;
	   l_ele_classification_name(counter) := 'Lump Sum C Payments';
        end if;
	/* End 9226023 */

        if (g_result_table(14).balance_value > 0)
        then
               counter := counter + 1;
           l_ele_name(counter)                := 'Lump Sum D Payment';
           l_ele_pay_value(counter)           := g_result_table(14).balance_value;
           l_ele_classification_name(counter) := 'Lump Sum D Payments';
            end if;
         /* Bug 9190980 - Added code to report Lump Sum E Payments sum after adjdusment of Retro GT12 Pre Tax < $400 payments */
        if ((g_result_table(15).balance_value + (g_result_table(33).balance_value - g_adj_lump_sum_pre_tax)) > 0)
        then
               counter := counter + 1;
           l_ele_name(counter)                := 'Lump Sum E Payment';
           l_ele_pay_value(counter)           := g_result_table(15).balance_value + (g_result_table(33).balance_value - g_adj_lump_sum_pre_tax);
           l_ele_classification_name(counter) := 'Lump Sum E Payments';
        end if;

        /* Bug 4201894 - Archive Adjusted Lump Sum E Amount (< $400 in a period)
           as Taxable Earnings*/
            if (g_adjusted_lump_sum_e_pay <> 0)  -- bug8711855 condition is changed to <> due to Retro Pre Tax GT12 balance
        then
               counter := counter + 1;
           l_ele_name(counter)                := 'Retro Payment < $400';
           l_ele_pay_value(counter)           := g_adjusted_lump_sum_e_pay ;
           l_ele_classification_name(counter) := 'Taxable Earnings';
        end if;
        /* End Bug 4201894 */

        /* Start 9190980 - Added code to report Lump Sum E Payments > $400 under 'Lump Sum E Pre Tax'
	                   and if Lump Sum E Payments < $400 ,the corresponding Retro GT 12 Pre Tax Deductions
			   are reported under Retro Pre Tax < $400 */

        if ((g_result_table(33).balance_value - g_adj_lump_sum_pre_tax) <> 0)
        then
               counter := counter + 1;
           l_ele_name(counter)                := 'Lump Sum E Pre Tax';
           l_ele_pay_value(counter)           := g_result_table(33).balance_value - g_adj_lump_sum_pre_tax ;
           l_ele_classification_name(counter) := 'Pre Tax Deductions';
        end if;

        if (g_adj_lump_sum_pre_tax <> 0)
        then
               counter := counter + 1;
           l_ele_name(counter)                := 'Retro Pre Tax < $400';
           l_ele_pay_value(counter)           := g_adj_lump_sum_pre_tax ;
           l_ele_classification_name(counter) := 'Pre Tax Deductions';
        end if;
       /*End 9190980*/

        if (counter >= 1)
        then
             for i in 1..counter
         loop

            insert into pay_action_information (
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
                        action_information4,
                        action_information5,
                        action_information6,
                        assignment_id)
                values (
                          pay_action_information_s.nextval,
                          p_assignment_action_id,
                          'AAP',
                          p_effective_date,
                          null,
                          g_tax_unit_id,
                          'AU_ELEMENT_RECON_DETAILS',
                          l_ele_name(i),
                          l_ele_classification_name(i),
                          null,
                          null,
                          null,
                          l_ele_pay_value(i),
                          p_assignment_id);
         end loop;
       end if;

    if g_debug then
        hr_utility.set_location('Leaving       '||l_procedure,700 );
    end if;

end archive_element_details;

  --------------------------------------------------------------------+
  -- Name  : Adjust_lumpsum_E_payments
  -- Type  : Procedure
  -- Access: Public
  -- This procedure identifies all Runs in a period for the Assignment
  -- in Financial Year and check is Lump Sum E Payment PTD < $400.In
  -- that case the YTD value is adjusted for the same.
  --------------------------------------------------------------------+
  /* Bug 4201894 - Adjusted Amount will be cumulatively stored in
     g_adjusted_lump_sum_e_pay and displayed in Taxable Earnings
     element section */
  /*bug8711855 - p_assignment_action_id and p_registered_employer parameter are added to call
               pay_au_payment_summary.get_retro_lumpsumE_value function */
  --------------------------------------------------------------------+
procedure Adjust_lumpsum_E_payments(p_assignment_id in pay_assignment_actions.assignment_id%type)
is

l_procedure varchar2(240);
v_lump_sum_E_ytd number;
v_adj_lump_sum_E_ptd number; /* Bug 4201894 */
v_adj_lump_sum_pre_tax number;
l_assignment_action_id pay_assignment_actions.assignment_action_id%type;


begin

g_debug := hr_utility.debug_enabled;

    if g_debug then
    l_procedure := 'Adjust_lumpsum_E_payments';
    hr_utility.set_location('In procedure '||g_package||l_procedure,600);
    end if;

         /*bug8711855 - The calculation logic is changed to add retro GT12 and call
            pay_au_payment_summary.get_lumpsumE_value function to adjust by single Lump Sum E paymetns */
         /* bug 9190980 - Added argument v_adj_lump_sum_pre_tax in call to the function for fetching adjusted Retro GT12 Pre Tax Deductions*/
         v_lump_sum_E_ytd := g_result_table(15).balance_value + g_result_table(31).balance_value
                             + g_result_table(32).balance_value - g_result_table(33).balance_value;

         if v_lump_sum_E_ytd <> 0 then

               v_lump_sum_E_ytd := pay_au_payment_summary.get_lumpsumE_value(g_tax_unit_id, p_assignment_id, g_start_date,
                                                           g_end_date, p_lump_sum_E_ptd_tab, v_lump_sum_E_ytd, v_adj_lump_sum_E_ptd
                                                           ,v_adj_lump_sum_pre_tax); -- Bug 9190980
         end if;

g_result_table(15).balance_value := v_lump_sum_E_ytd;
g_adjusted_lump_sum_e_pay  := v_adj_lump_sum_E_ptd; /* Bug 4201894*/
g_adj_lump_sum_pre_tax           := v_adj_lump_sum_pre_tax;

    if g_debug then
    hr_utility.set_location('In procedure '||g_package||l_procedure,600);
    end if;
end;

  --------------------------------------------------------------------+
  -- Name  : Get_allowance_balances
  -- Type  : Procedure
  -- Access: Public
  -- Reads the PL/SQL table populated by Elements procedure for
  -- Allowances. Procedure Fetches the balance values and adjusts any
  -- Retro Payments.
  --------------------------------------------------------------------+

/* bug 7571001 - the way to retrieve allowance is based on Balance Attribute */
procedure get_allowance_balances(p_assignment_id in pay_assignment_actions.assignment_id%type
                                 ,p_run_assignment_action_id in pay_assignment_actions.assignment_action_id%type)
is


CURSOR c_allowance_balances IS
SELECT  pdb.defined_balance_id
       ,NVL(pbt.reporting_name,pbt.balance_name) balance_name
       ,pay_balance_pkg.get_value(pdb.defined_balance_id
                                  ,p_run_assignment_action_id
                                  ,g_tax_unit_id
                                  ,NULL,NULL,NULL,NULL,NULL,NULL,NULL) balance_value
FROM  pay_balance_attributes pba
     ,pay_defined_balances   pdb
     ,pay_balance_types      pbt
     ,pay_balance_dimensions pbd
WHERE pba.attribute_id         = g_attribute_id
AND   pdb.defined_balance_id   = pba.defined_balance_id
AND   pbt.balance_type_id      = pdb.balance_type_id
AND   pdb.balance_type_id = pbt.balance_type_id
AND pdb.business_group_id = g_business_group_id
and   pbd.balance_dimension_id = pdb.balance_dimension_id
and   pbd.dimension_name = '_ASG_LE_YTD'
and   pbd.legislation_code = 'AU'
;

  t_allowance_balance pay_au_payment_summary.t_allowance_balance%TYPE;
  counter number := 1;

l_YTD_allowance number := 0;
l_result number;
l_procedure varchar2(240);


begin

   g_debug := hr_utility.debug_enabled;

   if g_debug then
      l_procedure :=  g_package||'.Get_allowance_balances';
      hr_utility.set_location('Entering '||l_procedure,700);
   end if;


  for rec_allowance_balances in c_allowance_balances loop

      if nvl(rec_allowance_balances.balance_value,0) >0 then
       t_allowance_balance(counter).balance_name  := rec_allowance_balances.balance_name;
       t_allowance_balance(counter).balance_value := rec_allowance_balances.balance_value;

        if g_debug then
          hr_utility.set_location(l_procedure, 3);
          hr_utility.trace('t_allowance_ balance name ('||counter||') = '|| t_allowance_balance(counter).balance_name);
          hr_utility.trace('t_allowance_balance value ('||counter||') = '||t_allowance_balance(counter).balance_value);
        end if;

        counter := counter +1;

      end if;
  end loop;

  IF t_allowance_balance.count > 0 THEN

    l_result := pay_au_payment_summary.adjust_retro_allowances(t_allowance_balance,
                                                                g_start_date,
                                                               g_end_date,
                                                                       p_assignment_id,
                                                                       g_tax_unit_id);

         for i in t_allowance_balance.FIRST..t_allowance_balance.LAST
          loop
           l_YTD_allowance := l_YTD_allowance + nvl(t_allowance_balance(i).balance_value,0);
          end loop;

  END IF;

      g_allowance_balance_value := l_YTD_allowance;

      if g_debug then
    hr_utility.set_location('Set the Global Balance Value '||l_YTD_allowance,700);
    hr_utility.set_location('Leaving '||l_procedure,700);
      end if;
end;

  --------------------------------------------------------------------+
  -- Name  : Archive_balance_details
  -- Type  : Procedure
  -- Access: Public
  -- Computes and Archives all the Balances in table
  -- pay_action_information with context,
  -- Normal Balances - AU_BALANCE_RECON_DETAILS_YTD
  -- Payment Summary Balances - AU_PS_BALANCE_RECON_DETAILS
  --------------------------------------------------------------------+

procedure archive_balance_details(p_assignment_action_id in pay_assignment_actions.assignment_action_id%TYPE
                                  ,p_assignment_id in pay_assignment_actions.assignment_id%TYPE
                  ,p_effective_date in date
                  ,p_pre01jul1983_ratio in number
                  ,p_post30jun1983_ratio in number
                  ,p_run_action_sequence in pay_assignment_actions.action_sequence%type)
is
l_procedure varchar2(80);

    l_YTD_TAXABLE_EARNINGS            number;
    l_YTD_NON_TAXABLE_EARNINGS        number;
    l_YTD_GROSS_EARNINGS            number;
    l_YTD_PRE_TAX_DEDUCTIONS            number;
    l_YTD_DIRECT_PAYMENTS               number;
    l_YTD_DEDUCTIONS                number;
    l_YTD_TAX                         number;
    l_YTD_NET_PAYMENT                   number;
    l_YTD_EMPLOYER_CHARGES      number;

    l_YTD_PAYSUM_GROSS number;
    l_YTD_LUMPSUM_PAY number ;
    l_YTD_ALLOWANCE number;
    l_YTD_RFB number;
    l_ETP_PAY number;
    l_ASSESSABLE_ETP number;
    l_YTD_CDEP number;
    l_YTD_UNION_FEES number;
    l_YTD_WORKPLACE_GIVING_DED number; /*4085496 */
 /* Begin 8587013 */
    l_YTD_RESC number;
    l_YTD_FOREIGN_INCOME number;
 /* End 8587013 */

begin

 g_debug := hr_utility.debug_enabled;
 if g_debug then
     l_procedure := 'archive_balance_details';
     hr_utility.set_location('In procedure '||g_package||l_procedure,800);
 end if;
/*
===============================================================================================
Balances for Archive are computed in the following manner,

l_YTD_GROSS_EARNINGS          = Earnings Total + Termination Payments + Pre Tax Deductions
l_YTD_TAXABLE_EARNINGS        = Gross Earnings - Pre_tax_deductions - Earnings_non_taxable
l_YTD_NON_TAXABLE_EARNINGS    = Earnings_non_taxable
l_YTD_PRE_TAX_DEDUCTIONS      = Pre_tax_deductions
l_YTD_DIRECT_PAYMENTS         = Direct_Payments
l_YTD_DEDUCTIONS              = Involuntary_deductions + Voluntary_deductions
l_YTD_TAX                     = Tax_deductions + Termination_deductions
l_YTD_NET_PAYMENT             = Taxable_earnings + Non_taxable_earnings - Tax - Deductions + Direct_Payments
l_YTD_EMPLOYER_CHARGES        = Employer_charges

l_YTD_PAYSUM_GROSS            = Earnings_Total + Leave Payments Marginal - (All Allowance) - CDEP - Lump Sum E Payments + Workplace Giving Deductions. - 4085496
l_YTD_LUMPSUM_PAY             = Lump Sum A Payments + Lump Sum B Payments + Lump Sum D Payments
                                + Lump Sum E Payments
l_YTD_ALLOWANCE               = Allowances YTD
l_YTD_RFB                     = Fringe Benefits /(1 - (FBT Rate + Med Levy))
l_ETP_PAY                     = (Lump Sum  C Payments + p_pre01jul1983_ratio) +
                                (Lump Sum  C Payments + p_post30jun1983_ratio) +
                                Invalidity Payments
l_ASSESSABLE_ETP              = (Lump Sum  C Payments + p_post30jun1983_ratio) +
l_YTD_CDEP                   = CDEP
l_YTD_UNION_FEES             = Union Fees
l_YTD_WORKPLACE_GIVING_DED   = Workplace Giving Deductions  - 4085496
l_YTD_RESC                   = Reportable Employer Superannuation Contributions - 8587013
l_YTD_FOREIGN_INCOME         = Exempt Foreign Employment Income - 8587013
===============================================================================================
*/


l_YTD_GROSS_EARNINGS       := g_result_table(1).balance_value + g_result_table(3).balance_value + g_result_table(5).balance_value;
l_YTD_TAXABLE_EARNINGS     := l_YTD_GROSS_EARNINGS - g_result_table(5).balance_value - g_result_table(9).balance_value ;
l_YTD_NON_TAXABLE_EARNINGS := g_result_table(9).balance_value;
l_YTD_PRE_TAX_DEDUCTIONS   := g_result_table(5).balance_value;
l_YTD_DIRECT_PAYMENTS      := g_result_table(2).balance_value;
l_YTD_DEDUCTIONS           := g_result_table(4).balance_value + g_result_table(7).balance_value ;
l_YTD_TAX                  := g_result_table(8).balance_value + g_result_table(6).balance_value ;
l_YTD_NET_PAYMENT          := l_YTD_TAXABLE_EARNINGS + l_YTD_NON_TAXABLE_EARNINGS - l_YTD_TAX - l_YTD_DEDUCTIONS + l_YTD_DIRECT_PAYMENTS ;
l_YTD_EMPLOYER_CHARGES     := g_result_table(10).balance_value ;

l_YTD_PAYSUM_GROSS         := g_result_table(1).balance_value + g_result_table(18).balance_value
                              + g_result_table(21).balance_value
                              - g_allowance_balance_value
                  - g_result_table(17).balance_value
                  - g_result_table(15).balance_value ;/* $400 Check Adjusted Value */
l_YTD_LUMPSUM_PAY          := g_result_table(11).balance_value + g_result_table(12).balance_value + g_result_table(14).balance_value
                              + g_result_table(15).balance_value ;
l_YTD_ALLOWANCE            := g_allowance_balance_value;
l_YTD_RFB                  := g_fbt_balance_value ;
l_ETP_PAY                  := (g_result_table(13).balance_value * p_pre01jul1983_ratio)
                             +(g_result_table(13).balance_value * p_post30jun1983_ratio)
                 + g_result_table(16).balance_value;
/* Bug 8769345 - The Assessible ETP value will be sum of all the ETP Taxable balances */
/* Bug 9226023 - The Assessible ETP value will be the taxable etp stored in global value */
l_ASSESSABLE_ETP           := round(g_taxable_etp,2);    /* Bug 4872594 - Added round off */
                                                                                                      /* Bug No : 7030285 - Assessable Income modified */
l_YTD_CDEP                 := g_result_table(17).balance_value;
l_YTD_UNION_FEES           := g_result_table(20).balance_value;
l_YTD_WORKPLACE_GIVING_DED := g_result_table(21).balance_value; /*  4085496 */

/* Begin 8587013 - Added code to hold the values of RESC and Exempt Foreign Employment Income balances*/
l_YTD_RESC                 := g_result_table(19).balance_value;
l_YTD_FOREIGN_INCOME       := g_result_table(22).balance_value;
/* End 8587013 */

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
                                      action_information10
                      )
                          values (
                                pay_action_information_s.nextval,
                                p_assignment_action_id,
                         'AAP',
                                p_effective_date,
                                null,
                         g_tax_unit_id,
                         p_assignment_id,
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
                         p_run_action_sequence);

/*Bug 8587013 - The balances RESC and Exempt Foreign Employment Income are inserted into next available two columns
                of PAY_ACTION_INFORMATION table and the Other Income balance is removed from archival*/

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
                                      action_information9,
                                      action_information10,
                                      action_information11,
                                      action_information12,
                      action_information13
                          )
                          values (
                                pay_action_information_s.nextval,
                                p_assignment_action_id,
                         'AAP',
                                p_effective_date,
                                null,
                         g_tax_unit_id,
                         p_assignment_id,
                         'AU_PS_BALANCE_RECON_DETAILS',
                         l_YTD_PAYSUM_GROSS,
                                 l_YTD_LUMPSUM_PAY,
                         l_YTD_ALLOWANCE,
                         l_YTD_RFB,
                         l_ETP_PAY,
                         l_ASSESSABLE_ETP,
                 l_YTD_CDEP,
                 l_YTD_UNION_FEES,
                                 p_run_action_sequence,
                                 L_YTD_WORKPLACE_GIVING_DED,
                             l_YTD_RESC,
                             l_YTD_FOREIGN_INCOME
                 ); /* 4015082 , 8587013 */

 if g_debug then
     hr_utility.set_location('Leaving '||g_package||l_procedure,800);
 end if;

end archive_balance_details;

  --------------------------------------------------------------------+
  -- Name  : spawn_archive_reports
  -- Type  : Procedure
  -- Access: Public
  -- This procedure calls the Detail report
  -- Using the parameters passed, this proc calls the Reconciliation
  -- Detail report.
  -- This proc is called as deinitialization code of archive process.

  --------------------------------------------------------------------+

procedure spawn_archive_reports
(p_payroll_action_id in pay_payroll_actions.payroll_action_id%type)
is
 l_count                number;
 ps_request_id          NUMBER;
 l_print_style          VARCHAR2(2);
 l_print_together       VARCHAR2(80);
 l_print_return         BOOLEAN;
 l_procedure         varchar2(50);
 l_short_report_name    VARCHAR2(30);  /* 6839263 */
 l_xml_options          BOOLEAN     ;  /* 6839263 */
  --------------------------------------------------------------------+
  -- Cursor      : csr_params
  -- Description : Fetches User Parameters from Legislative_paramters
  --               column.
  --------------------------------------------------------------------+

   CURSOR csr_report_params(c_payroll_action_id  pay_payroll_actions.payroll_action_id%TYPE)
      IS
      select  pay_core_utils.get_parameter('BUSINESS_GROUP_ID',legislative_parameters) business_group_id
       ,pay_core_utils.get_parameter('REGISTERED_EMPLOYER',legislative_parameters) legal_employer
      ,pay_core_utils.get_parameter('PAYROLL',legislative_parameters) payroll_id
      ,pay_core_utils.get_parameter('ASSIGNMENT_ID',legislative_parameters) assignment_id
      ,pay_core_utils.get_parameter('EMPLOYEE_TYPE',legislative_parameters) employee_type
      ,to_date('01-07-'||substr(pay_core_utils.get_parameter('FINANCIAL_YEAR',legislative_parameters),1,4),'DD-MM-YYYY') fin_year_start_date
      ,to_date('30-06-'||substr(pay_core_utils.get_parameter('FINANCIAL_YEAR',legislative_parameters),6,4),'DD-MM-YYYY') fin_year_end_date
      ,to_date('01-04-'||substr(pay_core_utils.get_parameter('FINANCIAL_YEAR',legislative_parameters),1,4),'DD-MM-YYYY') fbt_year_start_date
      ,to_date('30-06-'||substr(pay_core_utils.get_parameter('FINANCIAL_YEAR',legislative_parameters),1,4),'DD-MM-YYYY') fbt_year_end_date
      ,pay_core_utils.get_parameter('LST_YR_TERM',legislative_parameters) lst_year_term
      ,pay_core_utils.get_parameter('DEL_ACT',legislative_parameters) delete_actions /*Bug 4142159*/
      ,decode(pay_core_utils.get_parameter('REP_MODE',legislative_parameters),'SUMM','S','D') report_mode /* Bug 3891577*/
      ,pay_core_utils.get_parameter('OUTPUT_TYPE',legislative_parameters)p_output_type
    from pay_payroll_actions
    where payroll_action_id = c_payroll_action_id;


 cursor csr_get_print_options(p_payroll_action_id NUMBER) IS
 SELECT printer,
          print_style,
          decode(save_output_flag, 'Y', 'TRUE', 'N', 'FALSE') save_output
          ,number_of_copies /* Bug 4116833 */
    FROM  pay_payroll_actions pact,
          fnd_concurrent_requests fcr
    WHERE fcr.request_id = pact.request_id
    AND   pact.payroll_action_id = p_payroll_action_id;

/* Declaration - Report Flags to be SET */
l_paysum_flag varchar2(2);
l_ytd_totals  varchar2(2);
l_negative_records varchar2(2);
l_zero_records varchar2(2);

l_dummy varchar2(240);

 rec_print_options  csr_get_print_options%ROWTYPE;

 l_parameters csr_report_params%ROWTYPE; /* Bug 6839263 */

begin
    l_count           :=0;
    ps_request_id     :=-1;
    g_debug :=hr_utility.debug_enabled ;

             if g_debug then
             l_procedure := g_package||' spawn_archive_reports';
             hr_utility.set_location('Entering '||l_procedure,999);
             end if;

-- Set User Parameters for Report.

             open csr_report_params(p_payroll_action_id);
             fetch csr_report_params into l_parameters;
             close csr_report_params;

          /* Start Bug 6839263 */
          IF  l_parameters.p_output_type = 'XML_PDF'
          THEN
                  l_short_report_name := 'PYAUREPSR_XML';

                  l_xml_options      := fnd_request.add_layout
                                        (template_appl_name => 'PAY',
                                         template_code      => 'PYAUREPSR_XML',
                                         template_language  => 'en',
                                         template_territory => 'US',
                                         output_format      => 'PDF');

          ELSE
                  l_short_report_name := 'PYAUREPSR';
          END IF;
         /* End Bug 6839263 */


--Set REPORT FLAGS values.
l_paysum_flag := 'Y'; /*Indicate Payment Summary Report*/
l_ytd_totals  := 'Y'; /* YTD Balances to be displayed */
l_negative_records := 'N'; /* Do not Suppress Records with Negative Earnings */
l_zero_records:= 'N'; /* Do not Suppress Records with Zero Earnings */

          if g_debug then
                   hr_utility.set_location('payroll_parameters.action '||p_payroll_action_id,900);
                   hr_utility.set_location('in BG_ID '||l_parameters.business_group_id,901);
                   hr_utility.set_location('in payroll_parameters.id '||l_parameters.payroll_id,903);
                   hr_utility.set_location('in asg_id '||l_parameters.assignment_id,904);
                   hr_utility.set_location('in legal employer '||l_parameters.legal_employer,908);
                   hr_utility.set_location('in YTD totals '||l_ytd_totals,910);
                   hr_utility.set_location('in zero records'||l_zero_records,911);
                   hr_utility.set_location('in Negative records'||l_negative_records,912);
                   hr_utility.set_location('in emp_type '||l_parameters.employee_type,914);
                   hr_utility.set_location('In Start Date '||l_parameters.fin_year_start_date,916);
                   hr_utility.set_location('In End Date '||l_parameters.fin_year_end_date,917);
                   hr_utility.set_location('In Last Year Term'||l_parameters.lst_year_term,918);
                   hr_utility.set_location('In Delete Actions'||l_parameters.delete_actions,919); /*Bug 4142159*/
                   hr_utility.set_location('In Output Type   '||l_parameters.p_output_type,920);
            end if;

     if g_debug then
      hr_utility.set_location('Afer payroll action ' || p_payroll_action_id , 900);
      hr_utility.set_location('Before calling report',900);
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
                            copies         => rec_print_options.number_of_copies, /*Bug 4116833 */
                            save_output    => hr_general.char_to_bool(rec_print_options.save_output),
                            print_together => l_print_together);
    -- Submit report
      if g_debug then
      hr_utility.set_location('payroll_action id    '|| p_payroll_action_id,900);
      end if;

ps_request_id := fnd_request.submit_request
 ('PAY',
  l_short_report_name,                                          /* Bug 6839263 */
   null,
   null,
   false,
   'P_PAYROLL_ACTION_ID='||to_char(p_payroll_action_id),
   'P_BUSINESS_GROUP_ID='||to_char(l_parameters.business_group_id),
   'P_ORGANIZATION_ID='||l_dummy,
   'P_PAYROLL_ID='||l_parameters.payroll_id,                      /* Bug 4353285 removed the to_char */
   'P_REGISTERED_EMPLOYER='||to_char(l_parameters.legal_employer),
   'P_ASSIGNMENT_ID='||l_parameters.assignment_id,                /* Bug 4353285 removed the to_char */
   'P_START_DATE='||to_char(l_parameters.fin_year_start_date,'YYYY/MM/DD'),
   'P_END_DATE='||to_char(l_parameters.fin_year_end_date,'YYYY/MM/DD'),
   'P_PAYROLL_RUN_ID='||l_dummy,
   'P_PERIOD_END_DATE='||l_dummy,
   'P_EMPLOYEE_TYPE='||l_parameters.employee_type,
   'P_YTD_TOTALS='||l_ytd_totals,
   'P_ZERO_RECORDS='||l_zero_records,
   'P_NEGATIVE_RECORDS='||l_negative_records,
   'P_SORT_ORDER_1='||l_dummy,
   'P_SORT_ORDER_2='||l_dummy,
   'P_SORT_ORDER_3='||l_dummy,
   'P_SORT_ORDER_4='||l_dummy,
   'P_PAYSUM_FLAG='||l_paysum_flag,
   'P_LST_YEAR_TERM='||l_parameters.lst_year_term,
   'P_DELETE_ACTIONS='||l_parameters.delete_actions, /*Bug 4142159*/
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
      hr_utility.set_location('After calling report',900);
      end if;

end;

procedure spawn_summary_reports
(p_payroll_action_id in pay_payroll_actions.payroll_action_id%type)
is
 l_count                number;
 ps_request_id          NUMBER;
 l_print_style          VARCHAR2(2);
 l_print_together       VARCHAR2(80);
 l_print_return         BOOLEAN;
 l_procedure         varchar2(50);

  --------------------------------------------------------------------+
  -- Cursor      : csr_params
  -- Description : Fetches User Parameters from Legislative_paramters
  --               column.
  --------------------------------------------------------------------+

   CURSOR csr_report_params(c_payroll_action_id  pay_payroll_actions.payroll_action_id%TYPE)
      IS
       select  pay_core_utils.get_parameter('BUSINESS_GROUP_ID',legislative_parameters) business_group_id
      ,pay_core_utils.get_parameter('REGISTERED_EMPLOYER',legislative_parameters) legal_employer
      ,pay_core_utils.get_parameter('PAYROLL',legislative_parameters) payroll_id
      ,pay_core_utils.get_parameter('ASSIGNMENT_ID',legislative_parameters) assignment_id
      ,pay_core_utils.get_parameter('EMPLOYEE_TYPE',legislative_parameters) employee_type
      ,to_date('01-07-'||substr(pay_core_utils.get_parameter('FINANCIAL_YEAR',legislative_parameters),1,4),'DD-MM-YYYY') fin_year_start_date
      ,to_date('30-06-'||substr(pay_core_utils.get_parameter('FINANCIAL_YEAR',legislative_parameters),6,4),'DD-MM-YYYY') fin_year_end_date
      ,to_date('01-04-'||substr(pay_core_utils.get_parameter('FINANCIAL_YEAR',legislative_parameters),1,4),'DD-MM-YYYY') fbt_year_start_date
      ,to_date('30-06-'||substr(pay_core_utils.get_parameter('FINANCIAL_YEAR',legislative_parameters),1,4),'DD-MM-YYYY') fbt_year_end_date
      ,pay_core_utils.get_parameter('LST_YR_TERM',legislative_parameters) lst_year_term
      ,pay_core_utils.get_parameter('DEL_ACT',legislative_parameters) delete_actions
      ,decode(pay_core_utils.get_parameter('REP_MODE',legislative_parameters),'SUMM','S','D') report_mode
    from pay_payroll_actions
    where payroll_action_id = c_payroll_action_id;


 cursor csr_get_print_options(p_payroll_action_id NUMBER) IS
 SELECT printer,
          print_style,
          decode(save_output_flag, 'Y', 'TRUE', 'N', 'FALSE') save_output
         ,number_of_copies
    FROM  pay_payroll_actions pact,
          fnd_concurrent_requests fcr
    WHERE fcr.request_id = pact.request_id
    AND   pact.payroll_action_id = p_payroll_action_id;

/* Declaration - Report Flags to be SET */
l_paysum_flag varchar2(2);
l_ytd_totals  varchar2(2);
l_negative_records varchar2(2);
l_zero_records varchar2(2);

l_dummy varchar2(240);

 rec_print_options  csr_get_print_options%ROWTYPE;

 l_parameters csr_report_params%ROWTYPE;

begin
    l_count           :=0;
    ps_request_id     :=-1;
    g_debug :=hr_utility.debug_enabled ;

             if g_debug then
             l_procedure := g_package||' spawn_summary_archive_reports';
             hr_utility.set_location('Entering '||l_procedure,999);
             end if;

-- Set User Parameters for Report.

             open csr_report_params(p_payroll_action_id);
             fetch csr_report_params into l_parameters;
             close csr_report_params;

--Set REPORT FLAGS values.
l_paysum_flag := 'Y'; /*Indicate Payment Summary Report*/
l_ytd_totals  := 'Y'; /* YTD Balances to be displayed */
l_negative_records := 'N'; /* Do not Suppress Records with Negative Earnings */
l_zero_records:= 'N'; /* Do not Suppress Records with Zero Earnings */

          if g_debug then
           hr_utility.set_location('payroll_parameters.action '||p_payroll_action_id,900);
           hr_utility.set_location('in BG_ID '||l_parameters.business_group_id,901);
           hr_utility.set_location('in payroll_parameters.id '||l_parameters.payroll_id,903);
           hr_utility.set_location('in asg_id '||l_parameters.assignment_id,904);
           hr_utility.set_location('in legal employer '||l_parameters.legal_employer,908);
           hr_utility.set_location('in YTD totals '||l_ytd_totals,910);
           hr_utility.set_location('in zero records'||l_zero_records,911);
           hr_utility.set_location('in Negative records'||l_negative_records,912);
           hr_utility.set_location('in emp_type '||l_parameters.employee_type,914);
           hr_utility.set_location('In Start Date '||l_parameters.fin_year_start_date,916);
           hr_utility.set_location('In End Date '||l_parameters.fin_year_end_date,917);
           hr_utility.set_location('In Last Year Term'||l_parameters.lst_year_term,918);
           hr_utility.set_location('In Delete Actions'||l_parameters.delete_actions,919);
           hr_utility.set_location('In Report Mode'||l_parameters.report_mode,920);
            end if;

     if g_debug then
      hr_utility.set_location('Afer payroll action ' || p_payroll_action_id , 900);
      hr_utility.set_location('Before calling report',900);
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
                            copies         => rec_print_options.number_of_copies, /*Bug 4116833 */
                            save_output    => hr_general.char_to_bool(rec_print_options.save_output),
                            print_together => l_print_together);
    -- Submit report
      if g_debug then
      hr_utility.set_location('payroll_action id    '|| p_payroll_action_id,900);
      end if;

ps_request_id := fnd_request.submit_request
 ('PAY',
  'PYAUPSSAR',
   null,
   null,
   false,
   'P_PAYROLL_ACTION_ID='||to_char(p_payroll_action_id),
   'P_BUSINESS_GROUP_ID='||l_parameters.business_group_id,
   'P_ORGANIZATION_ID='||l_dummy,
   'P_PAYROLL_ID='||l_parameters.payroll_id,
   'P_REGISTERED_EMPLOYER='||l_parameters.legal_employer,
   'P_ASSIGNMENT_ID='||l_parameters.assignment_id,
   'P_START_DATE='||to_char(l_parameters.fin_year_start_date,'YYYY/MM/DD'),
   'P_END_DATE='||to_char(l_parameters.fin_year_end_date,'YYYY/MM/DD'),
   'P_PAYROLL_RUN_ID='||l_dummy,
   'P_PERIOD_END_DATE='||l_dummy,
   'P_EMPLOYEE_TYPE='||l_parameters.employee_type,
   'P_YTD_TOTALS='||l_ytd_totals,
   'P_ZERO_RECORDS='||l_zero_records,
   'P_NEGATIVE_RECORDS='||l_negative_records,
   'P_SORT_ORDER_1='||l_dummy,
   'P_SORT_ORDER_2='||l_dummy,
   'P_SORT_ORDER_3='||l_dummy,
   'P_SORT_ORDER_4='||l_dummy,
   'P_PAYSUM_FLAG='||l_paysum_flag,
   'P_LST_YEAR_TERM='||l_parameters.lst_year_term,
   'P_DELETE_ACTIONS='||l_parameters.delete_actions, /*Bug 4142159*/
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
      hr_utility.set_location('After calling report',900);
      end if;

end spawn_summary_reports;


end pay_au_rec_det_paysum_mode;

/
