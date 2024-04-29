--------------------------------------------------------
--  DDL for Package Body PAY_AU_PAYSLIP_ARCHIVE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_AU_PAYSLIP_ARCHIVE" as
/*  $Header: pyauparc.pkb 120.8.12010000.2 2008/08/06 06:49:01 ubhat ship $ */
/* +===================================================================+
             Copyright (c) 2002 Oracle Corporation Australia Ltd
                       Melbourne, Australia
                        All Rights Reserved
 +=====================================================================+
 Description :       This package declares functions which are used
                     by the archiver when archiving AU payslip data.

 Change List
 -----------

 Name          Date        Version Bug     Text
 ------------- ----------- ------- ------- --------------------------
 sclarke       18-Mar-2002 115.0           Initial Version
 sclarke       06-May-2002 115.1           Changed parameters passed to get_personal_information
                                           p_curr_eff_date => latest pay run effetive_date
                                           p_curr_pymt_eff_date => latest pay run period end date
 sclarke       07-May-2002 115.2           csr_std_elements now checks for null classification
                                           archive_stat_elements now executed before archive_user_elements
                                           csr_chunk_number removed
                                           archiving rate into APAC_ELEMENTS
 kaverma       26-Jun-2002 115.3  2433842  added date check to csr_prepaid_assignments cursor to pick up
                                           prepayments in the date range
 kaverma       02-Jul-2002 115.4  2438495  date format for absences displayed on payslip.
 srrajago      01-Aug-2002 115.5  2491444  Removed the cursor csr_period_end_date from archive_employee_details procedure
                                           and placed it in archive_code.Added the parameter p_period_end_date
                                           to the procedure archive_employee_details.
                                           In archive_employee_details, correct time_period_id and period_end_date are
                                           passed to all other procedures.
 srrajago      05-Sep-2002 115.6  2525895  The check csr_annual_leave_plan%notfound and assigning balance to zero have
                                           been removed. Check for accrual_plan_name before creation of 'APAC ACCRUALS'
                                           has been included.
 Ragovind      03-Dec-2002 115.7  2689226  Added NOCOPY for the function range_code.
 srrajago      29-May-2003 115.8  2958735  In the cursor 'csr_annual_leave_plan', included an alias name for
                                           accrual_category. In the procedure 'archive_accruals', introduced a loop
                                           statment for fetching the cursor 'csr_annual_leave_plan'.
 apunekar      29-May-2003 115.9  2920725  Corrected base tables to support security model
 vgsriniv      17-Nov-2003 115.10 3260854  Done validation for divide by zero error in
                                           procedure archive_stat_elements
 punemhta      06-Feb-2004 115.11 3245909  Added a new condition to cursor csr_prepay_assignment_actions of
                                           archive_code to support Run Types.
 punemhta      25-Feb-2004 115.12 3466097  Added a new condition for archiving Elements
 punemhta      25-Mar-2004 115.13 3245909  called get_net_pay function multiple times to arcvhie child payment methods
 punemhta      26-Mar-2004 115.14 3245909  ROlled back changs made in ver. 115.13
 punemhta      26-Mar-2004 115.15 3513016  Modified for standalone patch 3513016 to archive payments process separate run type
 punemhta      01-Apr-2004 115.16 3363519  Modified to call core packages for functionality and removed the call to get_net_pay_distribution
 avenkatk      03-May-2004 115.17 3606558  Added new condition - NULL value check for archiving elements.
 avenkatk      03-May-2004 115.18 3606558  Resolved GSCC Errors.
 srrajago      05-May-2004 115.19 3604094  Converted all Number fields to Canonical format before archiving the same.
                                           Action Information Category    Column whose value is converted to Canonical
                                           ---------------------------    --------------------------------------------
                                            APAC ELEMENTS                 action_information5, action_information9
                                            APAC BALANCES                 action_information4
                                            APAC ACCRUALS                 action_information4
                                            APAC ABSENCES                 action_information6, action_information8
                                           ---------------------------    --------------------------------------------
 avenkatk      18-Oct-2004 115.20 3891564  Modified call to pay_au_soe.balance_totals for earnings reporting enhancement.
 srrajago      04-Nov-2004 115.21 3991308  Variable l_balance declaration modified from number(15,3) to number.
 ksingla       20-Dec-2004 115.22 3935483  Modified call to  balance_totals
 ksingla       29-Dec-2004 115.23 3935483  Modified call to pay_au_soe_pkg.balance_totals to include one more parameter.
 avenkatk      07-Dec-2004 115.24 4018490  Rounded the Hours component archived for Elements to 2 decimal places.
 avenkatk      19-Apr-2005 115.25 4169557  Introduced call to populate Defined Balance ID's in intialization_code
 abhargav      09-Jul-2005 115.26 4363057  Removed calls to pay_au_soe.balance_totals and replace it with pay_au_soe.final_balance_totals
 ksingla       09-Jan-2006 120.2  4753806  Modified cursor csr_std_elements to sum up hours and payment .
 ksingla       21-Feb-2006 120.3  5036580  Modified procedure archive_absences for performance.
 hnainani      08-Nov-2006 120.4  5599302  Added Trunc to l_rate
 priupadh      13-Feb-2006 120.5  5504354  Added cursors c_grade_step,c_pay_advice_date,c_get_bus_id in archive_employee_details
                                           Added code to Archive additional Employee Details (Workchoice)
 sclarke       23-Feb-2007 120.3.12000000.4
                                  5713447  Added new procedure archive_offset_payment_method(),it archives payment details for offset payrolls.
 hnainani     13-MAR-2007   120.3.1200000.5 5914696   Modified l_rate to get Rate from the view pay_au_asg_element_payments_v instead
 priupadh     02-JUL-2007   120.3.1200000.6 6032985  Modified csr_pay_advice_date , default direct entry (ptp.default_dd_date) needs to be displayed
                                                     as Payment Date in Payslip
 vamittal     29-APR-2008  120.3.12000000.7 69623336 Modified archive_offset_payment_method() to be based on Prepayment Effective Date

 ====================================================================
*/

  g_arc_payroll_action_id           pay_payroll_actions.payroll_action_id%type;          -- Global to store last archive payroll action id

  g_package                         constant varchar2(60) := 'pay_au_payslip_archive.';  -- Global to store package name for tracing.

  --------------------------------------------------------------------
  --
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
    l_procedure  :=  g_package||'range_code';
    hr_utility.set_location('Entering '||l_procedure,1);

    -- Archive the payroll action level data  and EIT defintions.
    pay_apac_payslip_archive.range_code( p_payroll_action_id  => p_payroll_action_id);
    /*Bug#3363519 */
    pay_core_payslip_utils.range_cursor(p_payroll_action_id,
                                        p_sql);

    hr_utility.set_location('Leaving '||l_procedure,1000);

  end range_code;

  --------------------------------------------------------------------
  --
  -- This procedure is used to set global contexts
  -- The globals used are PL/SQL tables i.e.(g_user_balance_table and g_element_table)
  -- It calls the procedure pay_apac_archive.initialization_code that
  -- actually sets the global variables and populates the global tables.
  --
  --------------------------------------------------------------------

  procedure initialization_code
  (p_payroll_action_id  in pay_payroll_actions.payroll_action_id%type)
  is
    l_procedure               varchar2(200) ;

  begin
    l_procedure :=  g_package||'initialization_code';
    hr_utility.set_location('Entering '||l_procedure,1);

    g_arc_payroll_action_id := p_payroll_action_id;
    hr_utility.set_location('g_arc_payroll_action_id......='||g_arc_payroll_action_id,10);

    -- initialization_code to to set the global tables for EIT
    -- that will be used by each thread in multi-threading.
    pay_apac_payslip_archive.initialization_code(p_payroll_action_id => p_payroll_action_id);

   /* Bug 4169557 - Introduced calls to populate defined balance ID's  */
     pay_au_soe_pkg.populate_defined_balances;

    hr_utility.set_location('Leaving '||l_procedure,1000);

  exception
    when others then
      hr_utility.set_location('Error in '||l_procedure,999999);
      raise;
  end initialization_code;

  --------------------------------------------------------------------
  --
  -- This procedure further restricts the assignment_id's
  -- returned by range_code.
  -- It creates the archive assignment actions and locks the prepayment
  -- actions and the latest payroll action.
  --
  --------------------------------------------------------------------

  procedure assignment_action_code
  (p_payroll_action_id in pay_payroll_actions.payroll_action_id%type
  ,p_start_person      in per_all_people_f.person_id%type
  ,p_end_person        in per_all_people_f.person_id%type
  ,p_chunk             in number
  ) is
    --
    l_procedure               varchar2(200) ;

  begin
    l_procedure := g_package||'assignment_action_code';
    hr_utility.set_location('Entering ' || l_procedure,1);
    /*Bug#3363519 */
    pay_core_payslip_utils.action_creation (
                           p_payroll_action_id,
                           p_start_person,
                           p_end_person,
                           p_chunk,
                           'AU_PAYSLIP_ARCHIVE',
                           'AU');

  exception
    when others then
      hr_utility.set_location('Error in '||l_procedure,999999);
      raise;
  end assignment_action_code;

  --------------------------------------------------------------------
  --
  -- This procedure archives the elements and corresponding payments
  -- that are required to be shown on payslip.
  --
  --------------------------------------------------------------------

  procedure archive_stat_elements
  (p_pre_assignment_action_id   in pay_assignment_actions.assignment_action_id%type
  ,p_pre_effective_date         in pay_payroll_actions.effective_date%type
  ,p_assignment_id              in pay_assignment_actions.assignment_id%type
  ,p_arc_assignment_action_id   in pay_assignment_actions.assignment_action_id%type
  ) is

    cursor csr_std_elements
    (p_assignment_action_id number
    ) is
    select element_reporting_name    /* Modified for bug 4753806 summed up hours and payment using group by */
    ,      classification_name
    ,      SUM(payment) payment
    ,     SUM( hours ) hours
    ,      rate /* 5914696 */
    from   pay_au_asg_element_payments_v
    where  assignment_action_id = p_assignment_action_id
    and    classification_name is not null
    group by element_reporting_name,rate,classification_name;

    l_action_info_id number;
    l_ovn  number;
    l_procedure         varchar2(200);

/* 5914696 */
--    l_rate number;

  begin
    l_procedure := g_package||'archive_stat_elements';
    hr_utility.set_location('Entering ' || l_procedure,1);
    --
    -- Loop through the processed elements and archive the data
    -- into the flexfield structure APAC_ELEMENTS.
    --
    FOR csr_rec IN csr_std_elements(p_pre_assignment_action_id)
    LOOP
      hr_utility.set_location('Archiving APAC Element Details',20);
      /* Bug:3260854 Added the following check to avoid
         divide by zero error. */

/* Bug 5914696 */

   /*   If csr_rec.hours = 0 Then
         l_rate := 0;
      Else
         l_rate := trunc(csr_rec.payment / csr_rec.hours,2);
      End if; */


     /* Bug 3891564 - Modified the check for classification_name for Earnings Reporting enhancment.
     */
     /* Bug 4018490 - Rounded the Hours value archived for elements to 2 decimal places */
      If ( csr_rec.classification_name in ('Taxable Earnings','Pre Tax Deductions','Tax Deductions','Post Tax Deductions','Direct Payments','Non Taxable Earnings','Employer Superannuation Contributions')
           AND csr_rec.payment IS NULL) THEN
		 NULL; -- Bug:3466097,Bug:3606558 - Elements will not be archived in this case to make it similar to SOE
      ELSE
	      pay_action_information_api.create_action_information
	      ( p_action_information_id        => l_action_info_id
	      , p_action_context_id            => p_arc_assignment_action_id
	      , p_action_context_type          => 'AAP'
	      , p_object_version_number        => l_ovn
	      , p_effective_date               => p_pre_effective_date
	      , p_source_id                    => NULL
	      , p_source_text                  => NULL
	      , p_action_information_category  => 'APAC ELEMENTS'
	      , p_action_information1          => csr_rec.element_reporting_name
	      , p_action_information2          => NULL
	      , p_action_information3          => NULL
	      , p_action_information4          => csr_rec.classification_name
	      , p_action_information5          => fnd_number.number_to_canonical(csr_rec.payment) -- Bug: 3604094
	      , p_action_information7          => round(csr_rec.hours,2) -- Bug: 4018490
	      , p_action_information9          => fnd_number.number_to_canonical(csr_rec.rate) -- Bug: 3604094
	      );
	    END IF;
      END LOOP;
    hr_utility.set_location('Leaving ' || l_procedure,1000);
  exception
    when others
    then
      hr_utility.set_location('Error in '||l_procedure,999999);
      raise;
  end archive_stat_elements;

  --------------------------------------------------------------------
  --
  -- Procedure contains code which archives balance data
  -- into the flexfield structure APAC_BALANCES.
  --
  --------------------------------------------------------------------
  /* Bug 3891564 Added new parameter for archiving Current Amount value.
     Number formatting done under enhancement 3604094 handled for the new column also.
  */

  procedure archive_balances
  (p_arc_assignment_action_id       in pay_assignment_actions.assignment_action_id%type
  ,p_pre_effective_date             in pay_payroll_actions.effective_date%type
  ,p_narrative                      in varchar2
  ,p_ytd                            in number
  ,p_tp                             in number --Bug 3891564
  ) is
    l_action_info_id number;
    l_ovn number;
    l_procedure         varchar2(200) ;
  begin
    l_procedure := g_package||'archive_balances';
    hr_utility.set_location('Entering ' || l_procedure,1);

    pay_action_information_api.create_action_information
    (p_action_information_id        =>  l_action_info_id
    ,p_action_context_id            =>  p_arc_assignment_action_id
    ,p_action_context_type          =>  'AAP'
    ,p_object_version_number        =>  l_ovn
    ,p_effective_date               =>  p_pre_effective_date
    ,p_source_id                    =>  NULL
    ,p_source_text                  =>  NULL
    ,p_action_information_category  =>  'APAC BALANCES'
    ,p_action_information1          =>  p_narrative
    ,p_action_information2          =>  NULL
    ,p_action_information3          =>  NULL
    ,p_action_information4          =>  fnd_number.number_to_canonical(p_ytd) -- Bug: 3604094
    ,p_action_information5          =>  fnd_number.number_to_canonical(p_tp)  -- Bug 3891564, Bug: 3604094
    );

    hr_utility.set_location('Leaving ' || l_procedure,1000);
  exception
    when others then
      hr_utility.set_location('Error in '||l_procedure,999999);
      raise;
  end archive_balances;

  --------------------------------------------------------------------
  --
  -- This procedure calculates and archives the statutory balances
  -- that are required for display on payslip
  --
  --------------------------------------------------------------------

  procedure archive_stat_balances
  (p_pre_assignment_action_id      in pay_assignment_actions.assignment_action_id%type /*4363057*/
  ,p_pre_effective_date            in pay_payroll_actions.effective_date%type
  ,p_assignment_id                 in pay_assignment_actions.assignment_id%type
  ,p_arc_assignment_action_id      in pay_assignment_actions.assignment_action_id%type
  ,p_calculation_date              in pay_payroll_actions.effective_date%type
  ) is
    l_gross_this_pay               number;
    l_other_deductions_this_pay    number;
    l_tax_deductions_this_pay      number;
    l_gross_ytd                    number;
    l_other_deductions_ytd         number;
    l_tax_deductions_ytd           number;
    l_non_tax_allow_this_pay       number;
    l_non_tax_allow_ytd            number;
    l_pre_tax_deductions_this_pay  number;
    l_pre_tax_deductions_ytd       number;
    l_net_payment_this_pay         number;
    l_net_payment_ytd              number;
    l_super_run                    number;
    l_super_ytd                    number;
    l_narrative                    varchar2(1000);
    l_procedure                    varchar2(200) ;
  /* Bug 3891564 - Added four new parameters to the procedure call to return taxable income
     and direct Payments */
    l_tax_income_this_pay         number;
    l_tax_income_ytd              number;
    l_direct_pay_this_pay         number;
    l_direct_pay_ytd              number;
    l_get_le_level_bal            varchar2(1);    --3935483
    l_fetch_only_ytd_value            varchar2(1);      --3935483

  begin
/* bug 3935483 2 new parameters   p_get_le_level_bal passed as Y  and p_fetch_only_ytd_value passed as N to balance_totals
    to fetch the LE level balances both , run and ytd balances, from the modified pay_au soe package */


    l_get_le_level_bal :='Y';               --3935483
    l_fetch_only_ytd_value :='N';                 --3935483
    l_procedure :=  g_package||'archive_stat_balances';
    hr_utility.set_location('Entering ' || l_procedure,1);
    --
    -- Get the balance values
    --
  /* Bug 3891564 - Added four new parameters to the procedure call to return taxable income
     and direct Payments */
    /*Bug 4363057 - Removed call to balance_totals and added call to final_balance_totals*/
     pay_au_soe_pkg.final_balance_totals
      (   p_assignment_id                => p_assignment_id
         ,p_assignment_action_id         => p_pre_assignment_action_id
         ,p_effective_date               => p_calculation_date
         ,p_gross_this_pay               => l_gross_this_pay
         ,p_other_deductions_this_pay    => l_other_deductions_this_pay
         ,p_tax_deductions_this_pay      => l_tax_deductions_this_pay
         ,p_gross_ytd                    => l_gross_ytd
         ,p_other_deductions_ytd         => l_other_deductions_ytd
         ,p_tax_deductions_ytd           => l_tax_deductions_ytd
         ,p_non_tax_allow_this_pay       => l_non_tax_allow_this_pay
         ,p_non_tax_allow_ytd       => l_non_tax_allow_ytd
         ,p_pre_tax_deductions_this_pay       => l_pre_tax_deductions_this_pay
         ,p_pre_tax_deductions_ytd       => l_pre_tax_deductions_ytd
         ,p_super_this_pay                    => l_super_run
         ,p_super_ytd                    => l_super_ytd
         ,p_taxable_income_this_pay      => l_tax_income_this_pay
         ,p_taxable_income_ytd           => l_tax_income_ytd
         ,p_direct_payments_this_pay          => l_direct_pay_this_pay
         ,p_direct_payments_ytd          => l_direct_pay_ytd
         ,p_get_le_level_bal              =>l_get_le_level_bal
         ,p_fetch_only_ytd_value                =>l_fetch_only_ytd_value
      );

    -- Calculate net_payment figure
    l_net_payment_ytd       := l_gross_ytd - l_pre_tax_deductions_ytd - l_other_deductions_ytd - l_tax_deductions_ytd + l_direct_pay_ytd;
    l_net_payment_this_pay  := l_gross_this_pay - l_pre_tax_deductions_this_pay - l_other_deductions_this_pay - l_tax_deductions_this_pay + l_direct_pay_this_pay;


    l_narrative            := 'Gross Earnings';
    hr_utility.set_location(l_narrative||' = '||l_gross_ytd,30);

    -- Archive Gross Earnings
    archive_balances
    (p_arc_assignment_action_id     => p_arc_assignment_action_id
    ,p_pre_effective_date           => p_pre_effective_date
    ,p_narrative                    => l_narrative
    ,p_ytd                          => l_gross_ytd
    ,p_tp                           => l_gross_this_pay
    );

    l_narrative := 'Non Taxable Earnings';
    hr_utility.set_location(l_narrative||' = '||l_non_tax_allow_ytd,40);

    -- Archive Non Taxable Earnings
    archive_balances
    (p_arc_assignment_action_id => p_arc_assignment_action_id
    ,p_pre_effective_date           => p_pre_effective_date
    ,p_narrative                => l_narrative
    ,p_ytd                      => l_non_tax_allow_ytd
    ,p_tp                       => l_non_tax_allow_this_pay
    );

    l_narrative            := 'Pre Tax Deductions';
    hr_utility.set_location(l_narrative||' = '||l_pre_tax_deductions_ytd,50);

    -- Archive Pre Tax Deductions
    archive_balances
    (p_arc_assignment_action_id     => p_arc_assignment_action_id
    ,p_pre_effective_date           => p_pre_effective_date
    ,p_narrative                    => l_narrative
    ,p_ytd                          => l_pre_tax_deductions_ytd
    ,p_tp                           => l_pre_tax_deductions_this_pay
    );

    l_narrative            := 'Taxable Gross';
    hr_utility.set_location(l_narrative||' = '||l_tax_income_ytd,60);

    -- Archive Taxable Earnings
    archive_balances
    (p_arc_assignment_action_id     => p_arc_assignment_action_id
    ,p_pre_effective_date           => p_pre_effective_date
    ,p_narrative                    => l_narrative
    ,p_ytd                          => l_tax_income_ytd
    ,p_tp                           => l_tax_income_this_pay
    );

    l_narrative := 'Tax Deductions';
    hr_utility.set_location(l_narrative||' = '||l_tax_deductions_ytd,70);

    -- Archive Tax Deductions
    archive_balances
    (p_arc_assignment_action_id => p_arc_assignment_action_id
    ,p_pre_effective_date           => p_pre_effective_date
    ,p_narrative                => l_narrative
    ,p_ytd                      => l_tax_deductions_ytd
    ,p_tp                       => l_tax_deductions_this_pay
    );

    l_narrative := 'Post Tax Deductions';
    hr_utility.set_location(l_narrative||' = '||l_other_deductions_ytd,80);


    -- Archive Post Tax Deductions
    archive_balances
    (p_arc_assignment_action_id => p_arc_assignment_action_id
    ,p_pre_effective_date           => p_pre_effective_date
    ,p_narrative                => l_narrative
    ,p_ytd                      => l_other_deductions_ytd
    ,p_tp                       => l_other_deductions_this_pay
    );

    l_narrative := 'Direct Payments';
    hr_utility.set_location(l_narrative||' = '||l_direct_pay_ytd,90);


    -- Archive Direct Payments
    archive_balances
    (p_arc_assignment_action_id => p_arc_assignment_action_id
    ,p_pre_effective_date       => p_pre_effective_date
    ,p_narrative                => l_narrative
    ,p_ytd                      => l_direct_pay_ytd
    ,p_tp                       => l_direct_pay_this_pay
    );

    l_narrative := 'Net Payment';
    hr_utility.set_location(l_narrative||' = '||l_net_payment_ytd,100);

    -- Archive Net Payment
    archive_balances
    (p_arc_assignment_action_id => p_arc_assignment_action_id
    ,p_pre_effective_date       => p_pre_effective_date
    ,p_narrative                => l_narrative
    ,p_ytd                      => l_net_payment_ytd
    ,p_tp                       => l_net_payment_this_pay
    );

    hr_utility.set_location('Leaving ' || l_procedure,1000);

  exception
    when others then
      hr_utility.set_location('Error in '||l_procedure,999999);
      raise;
  end archive_stat_balances;

  ---------------------------------------------------------------------------
  --
  -- This procedure archives the required information for Annual Leave
  -- Accrual Plans into the Action Information DF structure 'APAC ACCRUALS'
  --
  -- Parameters:
  --   p_assignment_id is required to calculate the plan balance
  --   p_run_assignment_action_id is required to get accrual plan information
  --   p_archive_assignment_action_id is used for archiving the data
  --   p_archive_effective_date is used for archiving the data
  --   p_calculation_date is used as the date to calculate the balance up to
  --
  ---------------------------------------------------------------------------

  procedure archive_accruals
  (p_assignment_id            in pay_assignment_actions.assignment_id%type
  ,p_pre_effective_date       in pay_payroll_actions.effective_date%type
  ,p_run_assignment_action_id in pay_assignment_actions.assignment_action_id%type
  ,p_arc_assignment_action_id in pay_assignment_actions.assignment_action_id%type
  ,p_calculation_date         in date
  ) is
    --
    l_assignment_id       per_all_assignments_f.assignment_id%type;
    --
    l_balance number; -- Bug: 3991308
    l_action_info_id        pay_action_information.action_information_id%type;
    l_ovn                         pay_action_information.object_version_number%type;
    --
    -- Cursor to retrieve the Annual Leave accrual plan
    -- information.
    --
    cursor csr_annual_leave_plan
    (p_assignment_action_id pay_assignment_actions.assignment_action_id%type)
    is
    select ap.accrual_plan_id
    ,      ap.accrual_plan_name
    ,      hr_general_utilities.get_lookup_meaning('US_PTO_ACCRUAL',ap.accrual_category) accrual_category
    ,      ap.accrual_units_of_measure
    ,      pa.payroll_id payroll_id
    ,      ap.business_group_id business_group_id
    from   pay_accrual_plans ap
    ,      pay_element_types_f et
    ,      pay_element_links_f el
    ,      pay_element_entries_f ee
    ,      pay_assignment_actions aa
    ,      pay_payroll_actions pa
    where  et.element_type_id      = ap.accrual_plan_element_type_id    -- select the accrual plan elements
    and    el.element_type_id      = et.element_type_id                 -- select accrual plan element entries
    and    aa.assignment_id        = ee.assignment_id                   -- select element entries for this assignment
    and    ee.element_link_id      = el.element_link_id                 -- join element to element entries via element links
    and    pa.payroll_action_id    = aa.payroll_action_id               -- need the payroll action to check the action_type
    and    pa.action_type          in ('R','Q')                         -- select only payroll/quikpay runs
    and    pa.action_status        = 'C'                                -- select only successfully completed runs
    and    pa.date_earned          between et.effective_start_date and et.effective_end_date
    and    pa.date_earned          between el.effective_start_date and el.effective_end_date
    and    pa.date_earned          between ee.effective_start_date and ee.effective_end_date
    and    ap.accrual_category     = 'AUAL'                             -- select only annual leave accrual plans
    and    aa.assignment_action_id = p_assignment_action_id
    ;
    l_procedure                    varchar2(200) ;
    --
  begin
    l_procedure := g_package||'archive_accruals';
    hr_utility.set_location('Entering ' || l_procedure,1);
    --
    -- 1. Get the accrual_plan_id for this assignment action
    --

   /* Bug No : 2958735 - Introduced a loop statement for the cursor csr_annual_leave_plan */

    FOR csr_rec IN csr_annual_leave_plan(p_run_assignment_action_id)
       LOOP
          --
          --  Get the balance of leave for this accrual plan at the period_end_date
          --
          --
          hr_utility.set_location('p_assignment_id.............= '||to_char(p_assignment_id),20);
          hr_utility.set_location('l_payroll_id................= '||to_char(csr_rec.payroll_id),20);
          hr_utility.set_location('l_business_group_id.........= '||to_char(csr_rec.business_group_id),20);
          hr_utility.set_location('l_accrual_plan_id...........= '||to_char(csr_rec.accrual_plan_id),20);
          hr_utility.set_location('p_calculation_date..........= '||to_char(p_calculation_date,'DD-MON-YYYY'),20);

          l_balance :=  hr_au_holidays.get_net_accrual
                       (p_assignment_id      => p_assignment_id
                       ,p_payroll_id         => csr_rec.payroll_id
                       ,p_business_group_id  => csr_rec.business_group_id
                       ,p_plan_id            => csr_rec.accrual_plan_id
                       ,p_calculation_date   => p_calculation_date
                       );

          hr_utility.set_location('annual leave balance..........= '||to_char(l_balance),30);

          IF csr_rec.accrual_plan_name IS NOT NULL THEN  /* Bug No : 2525895 */

             pay_action_information_api.create_action_information
                ( p_action_information_id        => l_action_info_id
                , p_action_context_id            => p_arc_assignment_action_id
                , p_action_context_type          => 'AAP'
                , p_object_version_number        => l_ovn
                , p_effective_date               => p_pre_effective_date
                , p_source_id                    => NULL
                , p_source_text                  => NULL
                , p_action_information_category  => 'APAC ACCRUALS'
                , p_action_information1          => csr_rec.accrual_plan_name
                , p_action_information2          => csr_rec.accrual_category
                , p_action_information3          => NULL
                , p_action_information4          => fnd_number.number_to_canonical(l_balance)  -- Bug: 3604094
                , p_action_information5          => csr_rec.accrual_units_of_measure
                 );

          END IF; /* Bug No : 2525895 */
       END LOOP;

    hr_utility.set_location('Leaving '|| l_procedure,1000);

  exception
    when others then
      hr_utility.set_location('Error in '||l_procedure,999999);
      raise;
  end archive_accruals;

  ------------------------------------------------------------------------------
  --
  -- This procedure archives the information for Leave Taken into the Action
  -- Information DF structure 'APAC ABSENCES'
  --
  -- Parameters:
  --   p_assignment_id is required to retrieve leave taken information
  --   p_time_period_id is required to retrieve leave taken information
  --   p_arc_effective_date is used for archiving the data
  --   p_arc_assignment_action_id is used for archiving the data
  --   p_run_assignment_action_id is used for retrieving leave taken information

  ------------------------------------------------------------------------------
  /* Bug 5036580- Modified procedure to fetch and insert values for absence based on split views .
     l_exists and tab_row declared to ensure duplicate rows fetched from different views are not inserted again
     into pay_action_information */

  procedure archive_absences
  (p_assignment_id              in pay_assignment_actions.assignment_id%type
  ,p_pre_effective_date         in pay_payroll_actions.effective_date%type
  ,p_time_period_id             in per_time_periods.time_period_id%type
  ,p_arc_assignment_action_id   in pay_assignment_actions.assignment_action_id%type
  ,p_run_assignment_action_id   in pay_assignment_actions.assignment_action_id%type
  ) is


    cursor csr_leave_taken1
    (p_time_period_id   per_time_periods.time_period_id%type
    ,p_assignment_id    pay_assignment_actions.assignment_id%type
    ) is
    select row_id
     ,     element_reporting_name
    ,      start_date
    ,      end_date
    ,      absence_hours
    ,      payment
    from   pay_au_asg_leave_taken_v1
    where  time_period_id = p_time_period_id
    and    assignment_id  = p_assignment_id;


    cursor csr_leave_taken2
    (p_time_period_id   per_time_periods.time_period_id%type
    ,p_assignment_id    pay_assignment_actions.assignment_id%type
    ) is
    select row_id,
    element_reporting_name
    ,      start_date
    ,      end_date
    ,      absence_hours
    ,      payment
    from   pay_au_asg_leave_taken_v2
    where  time_period_id = p_time_period_id
    and    assignment_id  = p_assignment_id;


    cursor csr_leave_taken3
    (p_time_period_id   per_time_periods.time_period_id%type
    ,p_assignment_id    pay_assignment_actions.assignment_id%type
    ) is
    select row_id,element_reporting_name
    ,      start_date
    ,      end_date
    ,      absence_hours
    ,      payment
    from   pay_au_asg_leave_taken_v3
    where  time_period_id = p_time_period_id
    and    assignment_id  = p_assignment_id;


    cursor csr_leave_taken4
    (p_time_period_id   per_time_periods.time_period_id%type
    ,p_assignment_id    pay_assignment_actions.assignment_id%type
    ) is
    select row_id,element_reporting_name
    ,      start_date
    ,      end_date
    ,      absence_hours
    ,      payment
    from   pay_au_asg_leave_taken_v4
    where  time_period_id = p_time_period_id
    and    assignment_id  = p_assignment_id;


       cursor csr_leave_taken5
    (p_time_period_id   per_time_periods.time_period_id%type
    ,p_assignment_id    pay_assignment_actions.assignment_id%type
    ) is
    select row_id,element_reporting_name
    ,      start_date
    ,      end_date
    ,      absence_hours
    ,      payment
    from   pay_au_asg_leave_taken_v5
    where  time_period_id = p_time_period_id
    and    assignment_id  = p_assignment_id;


l_exists varchar2(10) ;

    l_action_info_id              pay_action_information.action_information_id%type;
    l_ovn                         pay_action_information.object_version_number%type;

    l_procedure                   varchar2(200);
    l_start_date                  VARCHAR2(20);
    l_end_date                    VARCHAR2(20);

 type tab_row is table of pay_au_asg_leave_taken_v.row_id%type index by binary_integer;

tab_row_id tab_row;

 i number ;



  begin

  l_exists := 'N' ;
  i := 1 ;
    l_procedure  := g_package||'archive_leave_details';
    hr_utility.set_location('Entering '||l_procedure,1);
    --
    -- Get all leave taken for this assignment for the given time period
    --
    FOR csr_rec IN csr_leave_taken1(p_time_period_id, p_assignment_id)
    LOOP

if i = 1 then
l_exists := 'N';

else

for j in tab_row_id.first..tab_row_id.last
loop

if tab_row_id(j) = csr_rec.row_id then
  l_exists := 'Y';
  exit;
else
  l_exists := 'N';
end if;

end loop;

end if;

if l_exists = 'N' then

tab_row_id(i) := csr_rec.row_id ;
i := i + 1 ;

      hr_utility.trace('Entering csr_leave_taken1');
      hr_utility.set_location('csr_rec.element_reporting_name.= '||csr_rec.element_reporting_name,50);
      hr_utility.set_location('csr_rec.start_date.............= '||to_char(csr_rec.start_date,'DD-MON-YYYY'),50);
      hr_utility.set_location('csr_rec.end_date...............= '||to_char(csr_rec.end_date,'DD-MON-YYYY'),50);
      hr_utility.set_location('csr_rec.absence_hours..........= '||csr_rec.absence_hours,50);
      hr_utility.set_location('csr_rec.payment................= '||csr_rec.payment,50);

      l_start_date := fnd_date.date_to_canonical(csr_rec.start_date); /*Bug 2438495*/
      l_end_date   := fnd_date.date_to_canonical(csr_rec.end_date);

      pay_action_information_api.create_action_information
      (p_action_information_id         => l_action_info_id
      , p_action_context_id            => p_arc_assignment_action_id
      , p_action_context_type          => 'AAP'
      , p_object_version_number        => l_ovn
      , p_effective_date               => p_pre_effective_date
      , p_source_id                    => NULL
      , p_source_text                  => NULL
      , p_action_information_category  => 'APAC ABSENCES'
      , p_action_information1          => NULL
      , p_action_information2          => csr_rec.element_reporting_name
      , p_action_information3          => NULL
      , p_action_information4          => l_start_date
      , p_action_information5          => l_end_date
      , p_action_information6          => fnd_number.number_to_canonical(csr_rec.absence_hours) -- Bug: 3604094
      , p_action_information7          => NULL
      , p_action_information8          => fnd_number.number_to_canonical(csr_rec.payment) -- Bug: 3604094
      );

  --  l_exists := 'N';

    end if;

    END LOOP;


 FOR csr_rec IN csr_leave_taken2(p_time_period_id, p_assignment_id)
    LOOP


if i = 1 then
l_exists := 'N';

else

for j in tab_row_id.first..tab_row_id.last
loop

if tab_row_id(j) = csr_rec.row_id then
  l_exists := 'Y';
  exit;
else
  l_exists := 'N';
end if;

end loop;

end if;


if l_exists = 'N' then

tab_row_id(i) := csr_rec.row_id ;
i := i + 1 ;

      hr_utility.trace('Entering csr_leave_taken1');
      hr_utility.set_location('csr_rec.element_reporting_name.= '||csr_rec.element_reporting_name,50);
      hr_utility.set_location('csr_rec.start_date.............= '||to_char(csr_rec.start_date,'DD-MON-YYYY'),50);
      hr_utility.set_location('csr_rec.end_date...............= '||to_char(csr_rec.end_date,'DD-MON-YYYY'),50);
      hr_utility.set_location('csr_rec.absence_hours..........= '||csr_rec.absence_hours,50);
      hr_utility.set_location('csr_rec.payment................= '||csr_rec.payment,50);

      l_start_date := fnd_date.date_to_canonical(csr_rec.start_date); /*Bug 2438495*/
      l_end_date   := fnd_date.date_to_canonical(csr_rec.end_date);

      pay_action_information_api.create_action_information
      (p_action_information_id         => l_action_info_id
      , p_action_context_id            => p_arc_assignment_action_id
      , p_action_context_type          => 'AAP'
      , p_object_version_number        => l_ovn
      , p_effective_date               => p_pre_effective_date
      , p_source_id                    => NULL
      , p_source_text                  => NULL
      , p_action_information_category  => 'APAC ABSENCES'
      , p_action_information1          => NULL
      , p_action_information2          => csr_rec.element_reporting_name
      , p_action_information3          => NULL
      , p_action_information4          => l_start_date
      , p_action_information5          => l_end_date
      , p_action_information6          => fnd_number.number_to_canonical(csr_rec.absence_hours) -- Bug: 3604094
      , p_action_information7          => NULL
      , p_action_information8          => fnd_number.number_to_canonical(csr_rec.payment) -- Bug: 3604094
       );


    end if;

    END LOOP;



    FOR csr_rec IN csr_leave_taken3(p_time_period_id, p_assignment_id)
    LOOP


if i = 1 then
l_exists := 'N';

else

for j in tab_row_id.first..tab_row_id.last
loop

if tab_row_id(j) = csr_rec.row_id then
  l_exists := 'Y';
  exit;
else
  l_exists := 'N';
end if;

end loop;

end if;


if l_exists = 'N' then

tab_row_id(i) := csr_rec.row_id ;
i := i + 1 ;

      hr_utility.trace('Entering csr_leave_taken1');
      hr_utility.set_location('csr_rec.element_reporting_name.= '||csr_rec.element_reporting_name,50);
      hr_utility.set_location('csr_rec.start_date.............= '||to_char(csr_rec.start_date,'DD-MON-YYYY'),50);
      hr_utility.set_location('csr_rec.end_date...............= '||to_char(csr_rec.end_date,'DD-MON-YYYY'),50);
      hr_utility.set_location('csr_rec.absence_hours..........= '||csr_rec.absence_hours,50);
      hr_utility.set_location('csr_rec.payment................= '||csr_rec.payment,50);

      l_start_date := fnd_date.date_to_canonical(csr_rec.start_date); /*Bug 2438495*/
      l_end_date   := fnd_date.date_to_canonical(csr_rec.end_date);

      pay_action_information_api.create_action_information
      (p_action_information_id         => l_action_info_id
      , p_action_context_id            => p_arc_assignment_action_id
      , p_action_context_type          => 'AAP'
      , p_object_version_number        => l_ovn
      , p_effective_date               => p_pre_effective_date
      , p_source_id                    => NULL
      , p_source_text                  => NULL
      , p_action_information_category  => 'APAC ABSENCES'
      , p_action_information1          => NULL
      , p_action_information2          => csr_rec.element_reporting_name
      , p_action_information3          => NULL
      , p_action_information4          => l_start_date
      , p_action_information5          => l_end_date
      , p_action_information6          => fnd_number.number_to_canonical(csr_rec.absence_hours) -- Bug: 3604094
      , p_action_information7          => NULL
      , p_action_information8          => fnd_number.number_to_canonical(csr_rec.payment) -- Bug: 3604094
       );


    end if;

    END LOOP;



    FOR csr_rec IN csr_leave_taken4(p_time_period_id, p_assignment_id)
    LOOP

if i = 1 then
l_exists := 'N';

else

for j in tab_row_id.first..tab_row_id.last
loop

if tab_row_id(j) = csr_rec.row_id then
  l_exists := 'Y';
  exit;
else
  l_exists := 'N';
end if;

end loop;

end if;


if l_exists = 'N' then

tab_row_id(i) := csr_rec.row_id ;
i := i + 1 ;

      hr_utility.trace('Entering csr_leave_taken1');
      hr_utility.set_location('csr_rec.element_reporting_name.= '||csr_rec.element_reporting_name,50);
      hr_utility.set_location('csr_rec.start_date.............= '||to_char(csr_rec.start_date,'DD-MON-YYYY'),50);
      hr_utility.set_location('csr_rec.end_date...............= '||to_char(csr_rec.end_date,'DD-MON-YYYY'),50);
      hr_utility.set_location('csr_rec.absence_hours..........= '||csr_rec.absence_hours,50);
      hr_utility.set_location('csr_rec.payment................= '||csr_rec.payment,50);

      l_start_date := fnd_date.date_to_canonical(csr_rec.start_date); /*Bug 2438495*/
      l_end_date   := fnd_date.date_to_canonical(csr_rec.end_date);

      pay_action_information_api.create_action_information
      (p_action_information_id         => l_action_info_id
      , p_action_context_id            => p_arc_assignment_action_id
      , p_action_context_type          => 'AAP'
      , p_object_version_number        => l_ovn
      , p_effective_date               => p_pre_effective_date
      , p_source_id                    => NULL
      , p_source_text                  => NULL
      , p_action_information_category  => 'APAC ABSENCES'
      , p_action_information1          => NULL
      , p_action_information2          => csr_rec.element_reporting_name
      , p_action_information3          => NULL
      , p_action_information4          => l_start_date
      , p_action_information5          => l_end_date
      , p_action_information6          => fnd_number.number_to_canonical(csr_rec.absence_hours) -- Bug: 3604094
      , p_action_information7          => NULL
      , p_action_information8          => fnd_number.number_to_canonical(csr_rec.payment) -- Bug: 3604094
      );


    end if;

    END LOOP;


 FOR csr_rec IN csr_leave_taken5(p_time_period_id, p_assignment_id)
    LOOP

if i = 1 then
l_exists := 'N';

else

for j in tab_row_id.first..tab_row_id.last
loop

if tab_row_id(j) = csr_rec.row_id then
  l_exists := 'Y';
  exit;
else
  l_exists := 'N';
end if;

end loop;

end if;


if l_exists = 'N' then

tab_row_id(i) := csr_rec.row_id ;
i := i + 1 ;

      hr_utility.trace('Entering csr_leave_taken1');
      hr_utility.set_location('csr_rec.element_reporting_name.= '||csr_rec.element_reporting_name,50);
      hr_utility.set_location('csr_rec.start_date.............= '||to_char(csr_rec.start_date,'DD-MON-YYYY'),50);
      hr_utility.set_location('csr_rec.end_date...............= '||to_char(csr_rec.end_date,'DD-MON-YYYY'),50);
      hr_utility.set_location('csr_rec.absence_hours..........= '||csr_rec.absence_hours,50);
      hr_utility.set_location('csr_rec.payment................= '||csr_rec.payment,50);

      l_start_date := fnd_date.date_to_canonical(csr_rec.start_date); /*Bug 2438495*/
      l_end_date   := fnd_date.date_to_canonical(csr_rec.end_date);

      pay_action_information_api.create_action_information
      (p_action_information_id         => l_action_info_id
      , p_action_context_id            => p_arc_assignment_action_id
      , p_action_context_type          => 'AAP'
      , p_object_version_number        => l_ovn
      , p_effective_date               => p_pre_effective_date
      , p_source_id                    => NULL
      , p_source_text                  => NULL
      , p_action_information_category  => 'APAC ABSENCES'
      , p_action_information1          => NULL
      , p_action_information2          => csr_rec.element_reporting_name
      , p_action_information3          => NULL
      , p_action_information4          => l_start_date
      , p_action_information5          => l_end_date
      , p_action_information6          => fnd_number.number_to_canonical(csr_rec.absence_hours) -- Bug: 3604094
      , p_action_information7          => NULL
      , p_action_information8          => fnd_number.number_to_canonical(csr_rec.payment) -- Bug: 3604094
      );


    end if;

    END LOOP;

    hr_utility.set_location('Leaving '||l_procedure,1000);

  exception
    when others
    then
      hr_utility.set_location('Error in '||l_procedure,999999);
      raise;
  END archive_absences;

--
-- Bug#5681819
-- Procedure archives payment details of the payment methods which get skipped in core procedure
-- pay_emp_action_arch.get_net_pay_distribution() , this procedure archives payment methods
-- for which effective start date is between period end date and payment date(+ve offset payroll)
-- or payment method end date is after payment date and before period end date(-ve offset payroll).
--
 PROCEDURE archive_offset_payment_method(
                    p_pre_pay_action_id     in number
                   ,p_assignment_id         in number
                   ,p_curr_pymt_eff_date    in date
                   ,p_ppp_source_action_id  in number
		   ,p_action_context_id   in number
                   ,p_action_context_type in varchar2
                   ,p_tax_unit_id         in number
		   ,p_period_end_date     in date
               )
  IS
--
--
--
    /* Bug 6962336 - Added a NOT EXISTS Clause to ensure the same
                     payment is not archived twice
    */
    cursor c_net_pay(cp_pre_pay_action_id    in number
                    ,cp_assignment_id        in number
                    ,cp_curr_pymt_eff_date   in date
                    ,cp_ppp_source_action_id in number
                    ,cp_action_context_id    in number
                    ) is
      select pea.segment1  seg1,
             pea.segment2  seg2,
             pea.segment3  seg3,
             pea.segment4  seg4,
             pea.segment5  seg5,
             pea.segment6  seg6,
             pea.segment7  seg7,
             pea.segment8  seg8,
             pea.segment9  seg9,
             pea.segment10 seg10,
             ppp.value     amount,
             ppp.pre_payment_id,
             popm.org_payment_method_id,
             popm.org_payment_method_name,
             pppm.personal_payment_method_id
        from pay_assignment_actions paa,
             pay_pre_payments ppp,
             pay_org_payment_methods_f popm ,
             pay_personal_payment_methods_f pppm,
             pay_external_accounts pea
       where paa.assignment_action_id = cp_pre_pay_action_id
         and ppp.assignment_action_id = paa.assignment_action_id
         and paa.assignment_id = cp_assignment_id
         and ( (    ppp.source_action_id is null
                and cp_ppp_source_action_id is null)
              or
               -- is it a Normal or Process Separate specific
               -- Payments should be included in the Standard
               -- SOE. Only Separate Payments should be in
               -- a Separate SOE.
               (ppp.source_action_id is not null
                and cp_ppp_source_action_id is null
                and exists (
                       select ''
                         from pay_run_types_f prt,
                              pay_assignment_actions paa_run,
                              pay_payroll_actions    ppa_run
                        where paa_run.assignment_action_id
                                               = ppp.source_action_id
                          and paa_run.payroll_action_id
                                               = ppa_run.payroll_action_id
                          and paa_run.run_type_id = prt.run_type_id
                          and prt.run_method in ('P', 'N')
                          and ppa_run.effective_date
                                      between prt.effective_start_date
                                          and prt.effective_end_date
                             )
                )
              or
                (cp_ppp_source_action_id is not null
                 and ppp.source_action_id = cp_ppp_source_action_id)
             )
         and ppp.org_payment_method_id = popm.org_payment_method_id
         and popm.defined_balance_id is not null
         and pppm.personal_payment_method_id(+)
                            = ppp.personal_payment_method_id
         and pea.external_account_id(+) = pppm.external_account_id
         and cp_curr_pymt_eff_date between popm.effective_start_date
                                       and popm.effective_end_date
         and cp_curr_pymt_eff_date between nvl(pppm.effective_start_date,
                                               cp_curr_pymt_eff_date)
                                       and nvl(pppm.effective_end_date,
                                               cp_curr_pymt_eff_date)
	 /* Bug 6962336 - Add NOT EXISTS Clause */
         AND NOT EXISTS
                ( SELECT pai.action_information_id
                  FROM   pay_action_information pai
                  WHERE  pai.action_context_id = cp_action_context_id
                  AND    pai.action_information_category = 'EMPLOYEE NET PAY DISTRIBUTION'
                  AND    pai.action_context_type = 'AAP'
                  AND    pai.action_information15 = ppp.pre_payment_id
                );

    ln_index                   NUMBER;
    lv_segment1                VARCHAR2(300);
    lv_segment2                VARCHAR2(300);
    lv_segment3                VARCHAR2(300);
    lv_segment4                VARCHAR2(300);
    lv_segment5                VARCHAR2(300);
    lv_segment6                VARCHAR2(300);
    lv_segment7                VARCHAR2(300);
    lv_segment8                VARCHAR2(300);
    lv_segment9                VARCHAR2(300);
    lv_segment10               VARCHAR2(300);
    ln_value                   NUMBER(15,2);
    ln_pre_payment_id          NUMBER;
    ln_org_payment_method_id   NUMBER;
    lv_org_payment_method_name VARCHAR2(300);
    ln_emp_payment_method_id   NUMBER;
    lv_procedure_name          VARCHAR2(100);
     l_action_information_id_1 NUMBER ;
     l_object_version_number_1 NUMBER ;

   BEGIN
     lv_procedure_name := '.archive_offset_payment_method';
     hr_utility.set_location('pay_au_payslip_archive' || lv_procedure_name,10);
     hr_utility.trace('p_pre_pay_action_id   = ' || p_pre_pay_action_id);
     hr_utility.trace('p_curr_pymt_eff_date = '  || p_curr_pymt_eff_date);
     hr_utility.trace('p_ppp_source_action_id = '|| p_ppp_source_action_id);

     open  c_net_pay(p_pre_pay_action_id
                    ,p_assignment_id
                    ,p_curr_pymt_eff_date
                    ,p_ppp_source_action_id
		    ,p_action_context_id);
     hr_utility.trace('Opened cursor c_net_pay ');

     loop
        fetch c_net_pay into lv_segment1
                            ,lv_segment2
                            ,lv_segment3
                            ,lv_segment4
                            ,lv_segment5
                            ,lv_segment6
                            ,lv_segment7
                            ,lv_segment8
                            ,lv_segment9
                            ,lv_segment10
                            ,ln_value
                            ,ln_pre_payment_id
                            ,ln_org_payment_method_id
                            ,lv_org_payment_method_name
                            ,ln_emp_payment_method_id;
        hr_utility.trace('Fetched c_net_pay ');
        if c_net_pay%notfound then
           exit;
        end if;

          pay_action_information_api.create_action_information(
                p_action_information_id => l_action_information_id_1,
                p_object_version_number => l_object_version_number_1,
                p_action_information_category  => 'EMPLOYEE NET PAY DISTRIBUTION',
                p_action_context_id    => p_action_context_id,
                p_action_context_type  => p_action_context_type,
                p_jurisdiction_code    => '00-000-0000',
                p_assignment_id        => p_assignment_id,
                p_tax_unit_id          => p_tax_unit_id,
                p_effective_date       => p_period_end_date,
                p_action_information1  => ln_org_payment_method_id,
                p_action_information2  => ln_emp_payment_method_id,
                p_action_information3  => null,
                p_action_information4  => null,
                p_action_information5  => lv_segment1,
                p_action_information6  => lv_segment2,
                p_action_information7  => lv_segment3,
                p_action_information8  => lv_segment4,
                p_action_information9  => lv_segment5,
                p_action_information10 => lv_segment6,
                p_action_information11 => lv_segment7,
                p_action_information12 => lv_segment8,
                p_action_information13 => lv_segment9,
                p_action_information14 => lv_segment10,
                p_action_information15 => ln_pre_payment_id,
                p_action_information16 => fnd_number.number_to_canonical(ln_value),
                p_action_information17 => p_pre_pay_action_id,
                p_action_information18 => lv_org_payment_method_name,
                p_action_information19 => null,
                p_action_information20 => null,
                p_action_information21 => null,
                p_action_information22 => null,
                p_action_information23 => null,
                p_action_information24 => null,
                p_action_information25 => null,
                p_action_information26 => null,
                p_action_information27 => null,
                p_action_information28 => null,
                p_action_information29 => null,
                p_action_information30 => null
                );
     end loop;
     close c_net_pay;
     hr_utility.set_location('Leaving pay_au_payslip_archive'|| lv_procedure_name,100);
  END archive_offset_payment_method;
  --
  --------------------------------------------------------------------------------------
  --
  -- archive_employee_details
  --
  -- Calls 'pay_emp_action_arch.get_personal_information' that actually
  -- archives the employee details,employee address details, Employer Address Details
  -- and Net Pay Distribution inforamation.
  -- tax_unit_id must be passed as a parameter to this procedure to make core provided
  -- 'Choose Payslip' view return appropriate rows.
  -- The action DF structures used are -
  --        ADDRESS DETAILS
  --        EMPLOYEE DETAILS
  --        EMPLOYEE NET PAY DISTRIBUTION
  --        EMPLOYEE OTHER INFORMATION
  -- Additionally required fields for Australia which have not already been archived
  -- are archived into the structure 'AU EMPLOYEE DETAILS'
  ---------------------------------------------------------------------------------------

  procedure archive_employee_details
  (p_assignment_id            in pay_assignment_actions.assignment_id%type
  ,p_arc_assignment_action_id in pay_assignment_actions.assignment_action_id%type   -- assignment action for archive run
  ,p_run_assignment_action_id in pay_assignment_actions.assignment_action_id%type   -- assignment action for payroll run
  ,p_pre_assignment_action_id in pay_assignment_actions.assignment_action_id%type   -- assignment action for prepayment run
  ,p_pre_effective_date       in pay_payroll_actions.effective_date%type            -- effective date of prepayment run
  ,p_run_effective_date       in pay_payroll_actions.effective_date%type            -- effective date of payroll run
  ,p_run_date_earned          in pay_payroll_actions.date_earned%type
  ,p_time_period_id           in per_time_periods.time_period_id%type
  ,p_period_end_date          in per_time_periods.end_date%type /* Bug No : 2491444 */
  ,p_regular_payment_date     in per_time_periods.regular_payment_date%type /* Bug# 5681819*/
  ) is

    l_action_info_id        pay_action_information.action_information_id%type;
    l_ovn                   pay_action_information.object_version_number%type;
    l_date_earned           pay_payroll_actions.date_earned%type;
    l_procedure             varchar2(80) ;
    l_abn                   number;
    l_tax_unit_id           pay_assignment_actions.tax_unit_id%type;

    cursor csr_tax_unit
    (p_assignment_action_id pay_assignment_actions.assignment_action_id%type) is
    select tax_unit_id
    from pay_assignment_actions
    where assignment_action_id = p_assignment_action_id;

    --
    -- Get the Employer ABN which is stored
    -- in the organization EIT strucutre AU_LEGAL_EMPLOYER
    --
    /*Bug2920725   Corrected base tables to support security model*/
    cursor csr_abn
    (p_assignment_id    pay_assignment_actions.assignment_id%type
    ,p_effective_date   pay_payroll_actions.effective_date%type
    ) is
    select org.org_information12        abn
    from   per_assignments_f        paaf
    ,      hr_soft_coding_keyflex       flex
    ,      hr_organization_information  org
    where  paaf.soft_coding_keyflex_id  = flex.soft_coding_keyflex_id
    and    to_char(org.organization_id) = flex.segment1
    and    org.org_information_context  = 'AU_LEGAL_EMPLOYER'
    and    paaf.assignment_id           = p_assignment_id
    and    p_effective_date             between paaf.effective_start_date and paaf.effective_end_date;

    CURSOR csr_child_action
    (p_prepay_action_id pay_assignment_actions.assignment_action_id%type,
     p_source_action_id pay_assignment_actions.assignment_action_id%type) IS
	SELECT paa.assignment_action_id
	FROM   pay_assignment_actions paa,
		pay_action_interlocks pai,
		pay_run_types_f prt
	WHERE  pai.locking_action_id  = p_prepay_action_id
	and   paa.assignment_action_id = pai.locked_action_id
	and   paa.source_action_id = p_source_action_id
	and   paa.run_type_id =  prt.run_type_id;

 /* Bug 5504354   - Added cursor to get pay_advice_date */
 /* Bug 6032985   - Added ptp.default_dd_date in place of pay_advice_date ,in case where
                       ptp.default_dd_date is null use effective date of Pre Payment */
  cursor  csr_pay_advice_date(p_run_assignment_action_id pay_assignment_actions.assignment_action_id%type ,
                        p_run_date_earned pay_payroll_actions.date_earned%type,
        		p_pre_effective_date pay_payroll_actions.effective_date%type)
is
select nvl(ptp.default_dd_date,p_pre_effective_date)
from pay_payroll_actions ppa,
     per_time_periods ptp,
     pay_assignment_actions paa
where  p_run_date_earned between ptp.start_date and ptp.end_date
and    paa.assignment_action_id=p_run_assignment_action_id
and    paa.payroll_action_id=ppa.payroll_action_id
and    ppa.payroll_id=ptp.payroll_id;

	/* Bug 5504354 c_get_bus_id */
	cursor   c_get_bus_id ( p_assignment_id     pay_assignment_actions.assignment_id%type
	                        ,p_effective_date date ) is
select distinct business_group_id
from per_all_assignments_f
where assignment_id=p_assignment_id
and p_effective_date between effective_start_date and effective_end_date;


/* Bug 5504354 - Cursor c_grade_step added to get the grade step of an assignment */

    cursor c_grade_step(p_assignment_id     pay_assignment_actions.assignment_id%type
    ,p_effective_date   pay_payroll_actions.effective_date%type,
    p_business_group_id per_all_assignments_f.business_group_id%type
    ) is
    select count(*)
from  per_spinal_point_steps_f psp,
per_spinal_point_placements_f pspp,
per_spinal_point_steps_f psp2
where psp.sequence>= psp2.sequence
and pspp.step_id=psp.step_id
and pspp.assignment_id=p_assignment_id
and psp.grade_spine_id=psp2.grade_spine_id
and pspp.business_group_id=p_business_group_id
and psp.business_group_id=p_business_group_id
and psp2.business_group_id=p_business_group_id
and p_effective_date between
      psp.effective_start_date and  psp.effective_end_date
and p_effective_date between
      psp2.effective_start_date and  psp2.effective_end_date
 and p_effective_date between
       pspp.effective_start_date and  pspp.effective_end_date;

        l_business_group_id per_all_assignments_f.business_group_id%type;

    l_step varchar2(10); /*  Bug 5504354 */

    l_pay_advice_date date ; /* Bug 5504354 */

    l_child_action_id pay_assignment_actions.assignment_action_id%type;

  begin
    l_procedure := g_package||'archive_employee_details';
    hr_utility.set_location('Entering '|| l_procedure,1);

      l_step := null ; /*  Bug 5504354 Initializing l_step */

    -- Need to get the end date of the latest runs period.
    -- Leave is calculated up to the end of the period and the EMPLOYEE DETAILS
    -- must be archived with the latest period end date
    --

    -- call generic procedure to retrieve and archive all data for
    -- EMPLOYEE DETAILS, ADDRESS DETAILS and EMPLOYEE NET PAY DISTRIBUTION

    open csr_tax_unit(p_pre_assignment_action_id);
    fetch csr_tax_unit
    into l_tax_unit_id;
    close csr_tax_unit;

    hr_utility.set_location('p_payroll_action_id........'||g_arc_payroll_action_id,10);
    hr_utility.set_location('p_arc_assignment_action_id '||p_arc_assignment_action_id,10);
    hr_utility.set_location('p_assignment_id............'||p_assignment_id,10);
    hr_utility.set_location('p_pre_assignment_action_id.'||p_pre_assignment_action_id,10);
    hr_utility.set_location('p_pre_effective_date.......'||to_char(p_pre_effective_date,'DD-MON-YYYY'),10);
    hr_utility.set_location('p_time_period_id...........'||p_time_period_id,10);
    hr_utility.set_location('p_period_end_date..........'||p_period_end_date,10); /* Bug No : 2491444 */
    hr_utility.set_location('Calling pay_emp_action_arch.get_personal_information',10);

    /* Bug No : 2491444 -- Value passed for p_time_period_id changed */

    pay_emp_action_arch.get_personal_information
    ( p_payroll_action_id    => g_arc_payroll_action_id     -- archive run payroll_action_id
    , p_assactid             => p_arc_assignment_action_id  -- archive run assignment_action_id
    , p_assignment_id        => p_assignment_id             -- current assignment_id
    , p_curr_pymt_ass_act_id => p_pre_assignment_action_id  -- prepayment run assignment_action_id
    , p_curr_eff_date        => p_run_effective_date        -- payroll run effective_date
    , p_date_earned          => p_run_date_earned           -- payroll date_earned
    , p_curr_pymt_eff_date   => p_period_end_date           -- latest run period end date, needed for core choose payslip
    , p_tax_unit_id          => l_tax_unit_id               -- GRE contained in tax_unit_id for assignment_action
    , p_time_period_id       => p_time_period_id            -- time_period_id from per_time_periods /* Bug No : 2491444 */
    , p_ppp_source_action_id => NULL
    );

    hr_utility.set_location('AU Finished get_personal_information',15);


    /* Bug#5681819  Call procedure only incase of offset payroll
       Bug#6962336  Modified Date from Regular Payment Date to Prepayment Effective Date
                    Payments must be checked as on Prepayment Effective date, the Core Method archives all
                    payments active on Period End Date, the following call will archive any payments missed
                    out by Core function.
    */
    if ( p_period_end_date <> p_pre_effective_date) then
       /*
            Bug#5681819
        --  For positive or negative offset payroll if payment method dates do not fall in payroll period these
        --  payment method details get archive by this Procedure.
        --
        */

        archive_offset_payment_method(
          p_pre_pay_action_id    => p_pre_assignment_action_id
         ,p_assignment_id        => p_assignment_id
         ,p_curr_pymt_eff_date   => p_pre_effective_date              /* Bug 6962336 */
         ,p_ppp_source_action_id => NULL
         ,p_action_context_id    => p_arc_assignment_action_id
         ,p_action_context_type  => 'AAP'
         ,p_tax_unit_id          =>l_tax_unit_id
         ,p_period_end_date      => p_period_end_date
          );
   end if;

    -- Get the annual leave balance
    hr_utility.set_location('p_payroll_action_id.........'||g_arc_payroll_action_id,20);
    hr_utility.set_location('p_time_period_id............'||p_time_period_id,20);
    hr_utility.set_location('p_assignment_id.............'||p_assignment_id,20);
    hr_utility.set_location('p_run_date_earned...........'||to_char(p_run_date_earned,'DD-MON-YYYY'),20);
    hr_utility.set_location('p_arc_assignment_action_id..'||p_arc_assignment_action_id,20);
    hr_utility.set_location('p_run_assignment_action_id..'||p_run_assignment_action_id,20);
    hr_utility.set_location('Calling pay_apac_payslip_archive.archive_leave_details',20);

   /* Bug No : 2491444 -- In all the procedure calls below the value passed for time_period_id changed */

    archive_accruals
    (p_assignment_id            => p_assignment_id
    ,p_pre_effective_date       => p_pre_effective_date
    ,p_run_assignment_action_id => p_run_assignment_action_id
    ,p_arc_assignment_action_id => p_arc_assignment_action_id
    ,p_calculation_date         => p_period_end_date              -- Calculate the balance as at period end date
    );

    hr_utility.set_location(l_procedure,21);

    archive_absences
    (p_assignment_id            => p_assignment_id
    ,p_pre_effective_date       => p_pre_effective_date
    ,p_time_period_id           => p_time_period_id
    ,p_arc_assignment_action_id => p_arc_assignment_action_id
    ,p_run_assignment_action_id => p_run_assignment_action_id
    );

    hr_utility.set_location(l_procedure,22);

  /* Bug# 4363057 - Modified call to archive_stat_balances passing prepayment run action_id*/
    archive_stat_balances
    (p_pre_assignment_action_id   => p_pre_assignment_action_id     -- prepayment run assignment action, latest
    ,p_pre_effective_date         => p_pre_effective_date           -- prepayment run effective date used to archive
    ,p_assignment_id              => p_assignment_id
    ,p_arc_assignment_action_id   => p_arc_assignment_action_id     -- archive run assignment action
    ,p_calculation_date           => p_period_end_date              -- date to calculate the balances at
    );


    hr_utility.set_location(l_procedure,23);

    pay_apac_payslip_archive.archive_user_balances
    (p_arch_assignment_action_id  => p_arc_assignment_action_id     -- archive run assignment action
    ,p_run_assignment_action_id   => p_run_assignment_action_id     -- payroll run assignment action
    ,p_pre_effective_date         => p_pre_effective_date           -- prepayment run effective_date
    );

    hr_utility.set_location(l_procedure,24);

    archive_stat_elements
    (p_pre_assignment_action_id   => p_pre_assignment_action_id     -- prepayment run assignment action
    ,p_pre_effective_date         => p_pre_effective_date           -- prepayment run effective date used to archive
    ,p_assignment_id              => p_assignment_id                -- assignment id
    ,p_arc_assignment_action_id   => p_arc_assignment_action_id     -- archive run assignment action
    );

    hr_utility.set_location(l_procedure,25);

    pay_apac_payslip_archive.archive_user_elements
    (p_arch_assignment_action_id  => p_arc_assignment_action_id     -- archive run assignment action
    ,p_pre_assignment_action_id   => p_pre_assignment_action_id     -- prepayment run assignment action
    ,p_latest_run_assact_id       => p_run_assignment_action_id     -- payroll run assignment action
    ,p_pre_effective_date         => p_pre_effective_date           -- prepayment run effective_date
    );

    hr_utility.set_location(l_procedure,26);

/* Bug 5504354 - Archive Pay Advice Date */
/* Bug 6032985 - added parameter p_pre_effective_date */
	open csr_pay_advice_date(p_run_assignment_action_id,p_run_date_earned,p_pre_effective_date);
	fetch csr_pay_advice_date into l_pay_advice_date;
	close csr_pay_advice_date;

    -- Get the ABN number
    open csr_abn(p_assignment_id, p_pre_effective_date);
    fetch csr_abn into l_abn;
    close csr_abn;

    hr_utility.set_location('Archiving AU EMPLOYEE DETAILS',30);

    pay_action_information_api.create_action_information
    ( p_action_information_id        =>  l_action_info_id
    , p_action_context_id            =>  p_arc_assignment_action_id
    , p_action_context_type          =>  'AAP'
    , p_object_version_number        =>  l_ovn
    , p_effective_date               =>  p_pre_effective_date
    , p_source_id                    =>  NULL
    , p_source_text                  =>  NULL
    , p_action_information_category  =>  'AU EMPLOYEE DETAILS'
    , p_action_information1          =>  NULL
    , p_action_information2          =>  NULL
    , p_action_information3          =>  NULL
    , p_action_information21         =>  l_abn
    , p_action_information22         =>  l_pay_advice_date    -- Added for pay advice date /*Bug 5504354 */
    );


open c_get_bus_id(p_assignment_id,p_pre_effective_date);
fetch c_get_bus_id into l_business_group_id;
close c_get_bus_id;

/* bug 5504354	Get the Grade Step  */

    open c_grade_step(p_assignment_id, p_pre_effective_date,l_business_group_id);
    fetch c_grade_step into l_step;
    close c_grade_step;

/* If Step is 0 then l_step is null i.e no grade step is attached */

    if l_step = 0 then

       l_step :=null;

    end if;

/* Bug 5504354- This grade step will be mapped to an additional person information
  detail item in Payslip. Grade step will be mapped to Action Information9
  and will be archived with action_information_category as ADDL EMPLOYEE DETAILS */

 hr_utility.set_location('Archiving ADDL EMPLOYEE DETAILS',30);

hr_utility.trace('Value of l_action_info_id is '||l_action_info_id);
hr_utility.trace('Value of p_arc_assignment_action_id is '||p_arc_assignment_action_id);
hr_utility.trace('Value of p_pre_effective_date is '||p_pre_effective_date);
hr_utility.trace('Value of l_step is '||l_step);
hr_utility.trace('Value of p_assignment_id is '||p_assignment_id);


pay_action_information_api.create_action_information (
	    p_action_information_id        => l_action_info_id
	   ,p_action_context_id            => p_arc_assignment_action_id
	   ,p_action_context_type          => 'AAP'
	   ,p_object_version_number        => l_ovn
	   ,p_effective_date               => p_pre_effective_date
	   ,p_source_id                    => NULL
	   ,p_source_text                  => NULL
	   ,p_action_information_category  => 'ADDL EMPLOYEE DETAILS'
	   ,p_action_information9          => l_step
	   );

    hr_utility.set_location('Leaving '|| l_procedure,1000);
  exception
    when others
    then
      hr_utility.set_location('Error in '||l_procedure,999999);
      raise;
  END archive_employee_details;

  ----------------------------
  --
  --
  --
  ----------------------------
  ----------------------------
  --
  --
  --
  ----------------------------
  procedure archive_code
  (p_assignment_action_id  in pay_assignment_actions.assignment_action_id%type
  ,p_effective_date        in pay_payroll_actions.effective_date%type
  ) is

  cursor get_payslip_aa(p_master_aa_id number)
  is
  select paa_arch_chd.assignment_action_id chld_arc_assignment_action_id,
         paa_pre.assignment_action_id pre_assignment_action_id,
         paa_run.assignment_action_id run_assignment_action_id,
         ppa_pre.effective_date pre_effective_date,
         paa_arch_chd.assignment_id,
         ppa_run.effective_date run_effective_date,
         ppa_run.date_earned run_date_earned,
         ptp.regular_payment_date, /* 5681819 */ptp.end_date period_end_date,
         ptp.time_period_id
    from pay_assignment_actions paa_arch_chd,
         pay_assignment_actions paa_arch_mst,
         pay_assignment_actions paa_pre,
         pay_action_interlocks  pai_pre,
         pay_assignment_actions paa_run,
         pay_action_interlocks  pai_run,
         pay_payroll_actions    ppa_pre,
         pay_payroll_actions    ppa_run,
         per_time_periods       ptp
   where paa_arch_mst.assignment_action_id = p_master_aa_id
     and paa_arch_chd.source_action_id = paa_arch_mst.assignment_action_id
     and paa_arch_chd.payroll_action_id = paa_arch_mst.payroll_action_id
     and paa_arch_chd.assignment_id = paa_arch_mst.assignment_id
     and pai_pre.locking_action_id = paa_arch_mst.assignment_action_id
     and pai_pre.locked_action_id = paa_pre.assignment_action_id
     and pai_run.locking_action_id = paa_arch_chd.assignment_action_id
     and pai_run.locked_action_id = paa_run.assignment_action_id
     and ppa_pre.payroll_action_id = paa_pre.payroll_action_id
     and ppa_pre.action_type in ('P','U')
     and ppa_run.payroll_action_id = paa_run.payroll_action_id
     and ppa_run.action_type in ('R','Q')
     and ptp.payroll_id = ppa_run.payroll_id
     and ppa_run.date_earned between ptp.start_date
                                 and ptp.end_date
     -- Get the highest in sequence for this payslip
     and paa_run.action_sequence = (select max(paa_run2.action_sequence)
                                      from pay_assignment_actions paa_run2,
                                           pay_action_interlocks  pai_run2
                                     where pai_run2.locking_action_id =
                                             paa_arch_chd.assignment_action_id
                                       and pai_run2.locked_action_id =
                                             paa_run2.assignment_action_id
                                   );

    l_procedure                       varchar2(200);


  begin
    l_procedure := g_package||'archive_code';
    hr_utility.set_location('Entering '||l_procedure,1);

    hr_utility.set_location('p_assignment_action_id......= '|| p_assignment_action_id,10);
    hr_utility.set_location('p_effective_date............= '|| to_char(p_effective_date,'DD-MON-YYYY'),10);
    /*Bug#3363519 */
    pay_core_payslip_utils.generate_child_actions(p_assignment_action_id,
                                                  p_effective_date);

    -- For each payslip to be generated
    for payslip_rec in get_payslip_aa(p_assignment_action_id) loop
--
      hr_utility.set_location(l_procedure,50);

      archive_employee_details
      (p_assignment_id              => payslip_rec.assignment_id
      ,p_arc_assignment_action_id   => payslip_rec.chld_arc_assignment_action_id     -- archive run assignment action
      ,p_run_assignment_action_id   => payslip_rec.run_assignment_action_id          -- payroll run assignment action
      ,p_pre_assignment_action_id   => payslip_rec.pre_assignment_action_id          -- prepayment run assignment action
      ,p_pre_effective_date         => payslip_rec.pre_effective_date                -- prepayment run effective date
      ,p_run_effective_date         => payslip_rec.run_effective_date                -- payroll run effective_date
      ,p_run_date_earned            => payslip_rec.run_date_earned                   -- payroll run date_earned
      ,p_time_period_id             => payslip_rec.time_period_id                    -- time_period_id from per_time_periods
      ,p_period_end_date            => payslip_rec.period_end_date                   -- end date from per_time_periods
      ,p_regular_payment_date       => payslip_rec.regular_payment_date              -- Regular payment date from per_time_periods /* 5681819 */
      );

      hr_utility.set_location(l_procedure,60);
--
    end loop;

    hr_utility.set_location('Leaving '||l_procedure,1000);

  exception
    when others then
      hr_utility.set_location('Error in '||l_procedure,999999);
      raise;
  end archive_code;
end pay_au_payslip_archive;

/
