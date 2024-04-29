--------------------------------------------------------
--  DDL for Package Body PAY_HK_PAYSLIP_ARCHIVE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_HK_PAYSLIP_ARCHIVE" AS
/* $Header: pyhkparc.pkb 120.4 2006/12/28 05:53:48 jalin noship $ */

---------------------------------------------------------------------+
  -- This is a global variable used to store Archive assignment action id
--------------------------------------------------------------------+


g_archive_pact         NUMBER;
g_debug                BOOLEAN;

--------------------------------------------------------------------+
  -- This procedure returns a sql string to SELECT a range
  -- of assignments eligible for archival.
  -- It calls pay_apac_payslip_archive.range_code that archives the EIT
  -- definition and payroll level data (Messages, employer address details etc)
--------------------------------------------------------------------+

PROCEDURE range_code(p_payroll_action_id   IN pay_payroll_actions.payroll_action_id%TYPE,
                     p_sql                 OUT nocopy VARCHAR2) IS


BEGIN

  g_debug := hr_utility.debug_enabled;

  IF g_debug THEN
     hr_utility.set_location('Start of range_code',1);
  END IF;


  --------------------------------------------------------------------------------+
      -- Call to range_code from common apac package 'pay_apac_payslip_archive'
      -- to archive the payroll action level data  and EIT defintions.
  --------------------------------------------------------------------------------+

  pay_apac_payslip_archive.range_code(p_payroll_action_id => p_payroll_action_id);

  -- Bug#3580617 Replaced Dynamic SQL with a function sql.
  pay_core_payslip_utils.range_cursor( p_payroll_action_id,
                                       p_sql
                                     );
  IF g_debug THEN
     hr_utility.set_location('End of range_code',2);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF g_debug THEN
       hr_utility.set_location('Error in initialization_code',2);
    END IF;
    RAISE;

END range_code;




--------------------------------------------------------------------+
  -- This procedure is used to set global contexts .
  -- The globals used are PL/SQL tables i.e.(g_user_balance_table and g_element_table)
  -- It calls the procedure pay_apac_archive.initialization_code that
  -- actually sets the global variables and populates the global tables.
--------------------------------------------------------------------+

PROCEDURE initialization_code (p_payroll_action_id  IN pay_payroll_actions.payroll_action_id%TYPE) IS


BEGIN
  IF g_debug THEN
     hr_utility.set_location('Start of initialization_code',1);
  END IF;

  g_archive_pact := p_payroll_action_id;

  ------------------------------------------------------------------+
  -- Call to common package procedure pay_apac_payslip_archive.
  -- initialization_code to to set the global tables for EIT
  -- that will be used by each thread in multi-threading.
  ------------------------------------------------------------------+

  pay_apac_payslip_archive.initialization_code(p_payroll_action_id => p_payroll_action_id);

  IF g_debug THEN
     hr_utility.set_location('End of initialization_code',2);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF g_debug THEN
       hr_utility.set_location('Error in initialization_code',2);
    END IF;
    RAISE;

END initialization_code;


--------------------------------------------------------------------+
  -- This procedure further restricts the assignment_id's
  -- returned by range_code
  -- It filters the assignments selected by range_code procedure

  -- Since the Payslip is given for each prepayment, the data should
  -- be archived for each prepayment.
  -- So, the successfully completed prepayments are selected and locked
  -- by the archival action.
  -- All the successfully completed runs under the prepayments are also
  -- selected and locked by archival to make the core 'Choose Payslip'
  -- work.
  -- The archive will not pickup already archived prepayments.
--------------------------------------------------------------------+

PROCEDURE assignment_action_code (p_payroll_action_id   IN pay_payroll_actions.payroll_action_id%TYPE,
                                  p_start_person        IN per_all_people_f.person_id%TYPE,
                                  p_end_person          IN per_all_people_f.person_id%TYPE,
                                  p_chunk               IN NUMBER)     IS

BEGIN
  IF g_debug THEN
     hr_utility.trace('Start of  assignment action code');
  END IF;

  -- Bug#3580617 Logic of generating Assignment actions has been replaced with the following
  --             Function Call.

  pay_core_payslip_utils.action_creation ( p_payroll_action_id,
                                           p_start_person,
                                           p_end_person,
                                           p_chunk,
                                           'HK_PAYSLIP_ARCHIVE',
                                           'HK');
  IF g_debug THEN
     hr_utility.trace('End of  Assignment action code');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF g_debug THEN
       hr_utility.trace('Error occured in Assignment action code');
    END IF;
    RAISE;

END assignment_action_code;

/*
 * Bug 3134158 - Added the following function to return the scheme name
 *
 */
FUNCTION get_scheme_name(p_run_result_id in pay_run_results.run_result_id%TYPE,
                         p_assignment_action_id in pay_assignment_actions.assignment_action_id%TYPE,
                         p_business_group_id in hr_organization_units.business_group_id%TYPE)
RETURN VARCHAR2
IS

  -- Cursor to get all the valid scheme names for this
  -- business_group_id

  CURSOR csr_scheme_names(c_business_group_id IN NUMBER)
  IS
  SELECT fnd_number.canonical_to_number(hoi.org_information20)  scheme_id,
         hoi.org_information2   scheme_name
   from  hr_organization_units hou,
         hr_organization_information  hoi
   where hoi.org_information_context = 'HK_MPF_SCHEMES'
   and   hou.business_group_id = c_business_group_id
   and   hou.organization_id = hoi.organization_id;

  -- Cursor to get the result_value for this run_result_id
  --

  CURSOR csr_result_value(c_run_result_id in NUMBER,
                          c_assignment_action_id IN NUMBER)
  IS
  SELECT fnd_number.canonical_to_number(prrv.result_value)
    FROM pay_assignment_actions paa,
         pay_run_results prr,
         pay_run_result_values prrv,
         pay_input_values_f pivf
   WHERE prr.run_result_id = c_run_result_id
     AND paa.assignment_action_id = c_assignment_action_id
     AND prr.run_result_id = prrv.run_result_id
     AND prrv.input_value_id = pivf.input_value_id
     AND pivf.legislation_code = 'HK'
     AND pivf.name = 'Source'
     AND prr.assignment_action_id = paa.assignment_action_id;
  --
  l_result_value pay_run_result_values.result_value%TYPE;
BEGIN
  l_result_value := null; -- Bug: 3604131
  --
  IF g_debug THEN
     hr_utility.trace('Run Result ID: ' || p_run_result_id);
     hr_utility.trace('Assignment action ID: '||p_assignment_action_id);
     hr_utility.trace('Business_group_id: '||p_business_group_id);
  END IF;
  --
  -- If the pl/sql table is not populated previously. Populate
  -- the table with all the scheme names available in this business
  -- group.
  ---------------------------------------------------------------------
    IF g_sn_populated = FALSE THEN
       FOR csr_sn_rec IN csr_scheme_names(p_business_group_id) LOOP
         g_scheme_name_table(csr_sn_rec.scheme_id).scheme_name := csr_sn_rec.scheme_name;
	 IF g_debug THEN
            hr_utility.trace('Scheme Name: ' || csr_sn_rec.scheme_name);
            hr_utility.trace('Scheme ID: ' ||csr_sn_rec.scheme_id);
	 END IF;
       END LOOP;
       g_sn_populated := TRUE;
    END IF;
    --
    -- Check if the pl/sql table has any data
    --  If data doesn't exists --> then return null
    --  else --> 1. Get the result value
    --           2. If it is not null, get the scheme name and
    --           3. Return the scheme name or null
    ---------------------------------------------------------------------
    IF g_scheme_name_table.count > 0 THEN

       -- 1. Get the result value
       --------------------------
       OPEN csr_result_value(p_run_result_id, p_assignment_action_id);
       FETCH csr_result_value INTO l_result_value;
       CLOSE csr_result_value;

       IF g_debug THEN
          hr_utility.trace('Result Value: '||nvl(l_result_value, '<null>'));
       END IF;

       -- 2. If result value is not null
       --    Check if the scheme name exists.
       -------------------------------------------------
       IF l_result_value is not null AND g_scheme_name_table.exists(l_result_value) THEN
          IF g_debug THEN
             hr_utility.trace('Success : '||g_scheme_name_table(l_result_value).scheme_name);
	  END IF;
          -- 3. Return the scheme name
          ----------------------------
          return g_scheme_name_table(l_result_value).scheme_name;
       END IF;

    END IF;
  --
  IF g_debug THEN
     hr_utility.trace('Scheme name does not exists');
  END IF;

  -- Scheme Name doesn't exists
  -----------------------------
  RETURN null;
  --
END get_scheme_name;

PROCEDURE archive_stat_elements(p_assignment_action_id  IN NUMBER,
                                p_assignment_id         IN NUMBER,
                                p_effective_date        IN DATE,
                                p_assact_id             IN NUMBER) IS

  -- Cursor to get all the elements processed for the assignment in the
  -- prepayment.

  CURSOR  csr_std_elements(p_assignment_action_id NUMBER,
                           p_assignment_id        NUMBER)
  IS
  SELECT   element_reporting_name
         , classification_name
         , payment_amount
         , assessed_ri
         , fnd_date.date_to_canonical(to_date(period_start_date,'YYYY/MM/DD HH24:MI:SS')) period_start_date
         , fnd_date.date_to_canonical(to_date(period_end_date,'YYYY/MM/DD HH24:MI:SS')) period_end_date
    FROM  PAY_HK_ASG_ELEMENT_PAYMENTS_V
   WHERE  assignment_action_id  = p_assignment_action_id
     AND  classification_name IS NOT NULL;


  l_action_info_id  NUMBER;
  l_ovn             NUMBER;
  l_foreign_currency_amount NUMBER;
  l_rate            NUMBER;
  l_procedure_name  VARCHAR2(80);

BEGIN
  l_procedure_name := 'archive_stat_elements'; -- Bug: 3604131

  IF g_debug THEN
     hr_utility.set_location('Entering Procedure pay_hk_payslip_archive.' || l_procedure_name,10);

     hr_utility.trace('Opening Cursor csr_std_elements');
  END IF;

  FOR csr_rec IN csr_std_elements(p_assignment_action_id,p_assignment_id)

  LOOP

    IF g_debug THEN
       hr_utility.set_location('Archiving Standard Element Details',20);
    END IF;


    if csr_rec.classification_name<>'Employer Liabilities' then

      pay_action_information_api.create_action_information
       ( p_action_information_id        =>  l_action_info_id
       , p_action_context_id            =>  p_assact_id
       , p_action_context_type          =>  'AAP'
       , p_object_version_number        =>  l_ovn
       , p_effective_date               =>  p_effective_date
       , p_source_id                    =>  NULL
       , p_source_text                  =>  NULL
       , p_action_information_category  =>  'APAC ELEMENTS'
       , p_action_information1          =>  csr_rec.element_reporting_name
       , p_action_information2          =>  NULL
       , p_action_information3          =>  NULL
       , p_action_information4          =>  csr_rec.classification_name
       , p_action_information5          =>  fnd_number.number_to_canonical(csr_rec.payment_amount) -- Bug: 3604131
       , p_action_information11         =>  fnd_number.number_to_canonical(csr_rec.assessed_ri)    -- Bug: 3604131
       , p_action_information13         =>  csr_rec.period_start_date
       , p_action_information14         =>  csr_rec.period_end_date);

     else

      pay_action_information_api.create_action_information
       ( p_action_information_id        =>  l_action_info_id
       , p_action_context_id            =>  p_assact_id
       , p_action_context_type          =>  'AAP'
       , p_object_version_number        =>  l_ovn
       , p_effective_date               =>  p_effective_date
       , p_source_id                    =>  NULL
       , p_source_text                  =>  NULL
       , p_action_information_category  =>  'APAC BALANCES 2'
       , p_action_information1          =>  csr_rec.element_reporting_name
       , p_action_information2          =>  NULL
       , p_action_information3          =>  NULL
       , p_action_information4          =>  fnd_number.number_to_canonical(csr_rec.payment_amount) -- Bug: 3604131
       , p_action_information6         =>   csr_rec.period_start_date
       , p_action_information7         =>   csr_rec.period_end_date
       , p_action_information8         =>   fnd_number.number_to_canonical(csr_rec.assessed_ri)); -- Bug: 3604131

   end if;


  END LOOP;
  IF g_debug THEN
     hr_utility.trace('Closing Cursor csr_std_elements');
     hr_utility.set_location('End of archive Standard Element',4);
     hr_utility.set_location('Leaving Procedure pay_hk_payslip_archive.' || l_procedure_name,10);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF g_debug THEN
       hr_utility.set_location('Error in archiving Standard Elements ',5);
    END IF;
    RAISE;

END archive_stat_elements;



--------------------------------------------------------------------+
   -- Procedure to archive the Statutory balances
--------------------------------------------------------------------+

PROCEDURE archive_balances( p_effective_date IN DATE
                           ,p_assact_id      IN NUMBER
                           ,p_narrative      IN VARCHAR2
                           ,p_ytd            IN NUMBER
                           ,p_curr           IN NUMBER) IS

  l_action_info_id   NUMBER;
  l_ovn              NUMBER;
  l_procedure_name   VARCHAR2(80);

BEGIN

  l_procedure_name := 'archive_balances'; -- Bug: 3604131

  IF g_debug THEN
     hr_utility.set_location('Entering procedure ' || l_procedure_name,10);
     hr_utility.set_location('archiving balances :',10);
  END IF;

  -- Archive Statutory balances

  pay_action_information_api.create_action_information
      ( p_action_information_id        =>  l_action_info_id
      , p_action_context_id            =>  p_assact_id
      , p_action_context_type          =>  'AAP'
      , p_object_version_number        =>  l_ovn
      , p_effective_date               =>  p_effective_date
      , p_source_id                    =>  NULL
      , p_source_text                  =>  NULL
      , p_action_information_category  =>  'APAC BALANCES'
      , p_action_information1          =>  p_narrative
      , p_action_information2          =>  NULL
      , p_action_information3          =>  NULL
      , p_action_information4          =>  fnd_number.number_to_canonical(p_ytd)  -- Bug: 3604131
      , p_action_information5          =>  fnd_number.number_to_canonical(p_curr) -- Bug: 3604131
      );


EXCEPTION
  WHEN OTHERS THEN
    IF g_debug THEN
       hr_utility.set_location('Error in archiving balance :',11);
    END IF;
    RAISE;

END archive_balances;



--------------------------------------------------------------------+
   -- Procedure to calculate the balances values
   -- Calls procedure archive_balances and actually archives all the balance values
--------------------------------------------------------------------+


PROCEDURE archive_stat_balances(p_assignment_action_id  IN NUMBER
                               ,p_assignment_id         IN NUMBER
                               ,p_date_earned           IN DATE
                               ,p_effective_date        IN DATE
                               ,p_assact_id             IN NUMBER) IS


l_Total_Earnings_This_Pay   NUMBER;
l_Total_Earnings_YTD        NUMBER;
l_Total_Deductions_This_pay NUMBER;
l_Total_Deductions_YTD      NUMBER;
l_Net_Pay_This_pay          NUMBER;
l_Net_Pay_YTD               NUMBER;
l_Direct_Payments_This_Pay  NUMBER;
l_Direct_Payments_YTD       NUMBER;
l_Total_Payment_This_Pay    NUMBER;
l_Total_Payment_YTD         NUMBER;
l_tax_unit_id               NUMBER;
l_narrative                 VARCHAR2(150);
l_procedure_name            VARCHAR2(80);


CURSOR csr_tax_unit_id(p_assignment_action_id NUMBER)
IS
  SELECT tax_unit_id
  FROM pay_assignment_actions
  WHERE assignment_action_id = p_assignment_action_id;

BEGIN

  l_procedure_name := 'Archive_Stat_Balances'; -- Bug: 3604131

  IF g_debug THEN
     hr_utility.set_location('Entering Procedure pay_hk_payslip_archive.' || l_procedure_name,10);
     hr_utility.set_location('Calling balance_total from pay_hk_soe_pkg',20);
  END IF;

  -- Get the totals of all the balances

OPEN  csr_tax_unit_id(p_assignment_action_id);
FETCH csr_tax_unit_id INTO l_tax_unit_id;
CLOSE csr_tax_unit_id;

pay_hk_soe_pkg.balance_totals(p_assignment_action_id,
         		      l_tax_unit_id,
                              l_Total_Earnings_This_Pay,
			      l_Total_Earnings_YTD,
                              l_Total_Deductions_This_pay,
			      l_Total_Deductions_YTD,
			      l_Net_Pay_This_pay,
                              l_Net_Pay_YTD,
                              l_Direct_Payments_This_Pay,
                              l_Direct_Payments_YTD,
                              l_Total_Payment_This_Pay,
                 	      l_Total_Payment_YTD);


  l_narrative := 'Total Earnings';

  IF g_debug THEN
     hr_utility.set_location('Archiving value for  ' || l_narrative,30);
  END IF;

/* Archive This Pay values and YTD Values  accordingly*/

  archive_balances(p_effective_date =>p_effective_date
                  ,p_assact_id      =>p_assact_id
                  ,p_narrative      =>l_narrative
                  ,p_ytd            =>l_Total_Earnings_YTD
                  ,p_curr           =>l_Total_Earnings_This_Pay);



  l_narrative := 'Total Deductions';

  IF g_debug THEN
     hr_utility.set_location('Archiving value for  ' || l_narrative,40);
  END IF;

  archive_balances(p_effective_date => p_effective_date
                  ,p_assact_id      => p_assact_id
                  ,p_narrative      => l_narrative
                  ,p_ytd            => l_Total_Deductions_YTD
                  ,p_curr           => l_Total_Deductions_This_pay);



  l_narrative := 'Net Pay';

  IF g_debug THEN
     hr_utility.set_location('Archiving value for  ' || l_narrative,50);
  END IF;

  archive_balances(p_effective_date => p_effective_date
                  ,p_assact_id      => p_assact_id
                  ,p_narrative      => l_narrative
                  ,p_ytd            => l_Net_Pay_YTD
                  ,p_curr           => l_Net_Pay_This_pay);



  l_narrative := 'Direct Payments';

  IF g_debug THEN
     hr_utility.set_location('Archiving value for  ' || l_narrative,60);
  END IF;

  archive_balances(p_effective_date => p_effective_date
                  ,p_assact_id      => p_assact_id
                  ,p_narrative      => l_narrative
                  ,p_curr           => l_Direct_Payments_This_Pay
               	,p_ytd            => l_Direct_Payments_YTD);


  l_narrative := 'Total Payment';

  IF g_debug THEN
     hr_utility.set_location('Archiving value for  ' || l_narrative,70);
  END IF;

  archive_balances(p_effective_date => p_effective_date
                  ,p_assact_id      => p_assact_id
                  ,p_narrative      => l_narrative
                  ,p_curr           => l_Total_Payment_This_Pay
                  ,p_ytd            => l_Total_Payment_YTD);



  IF g_debug THEN
     hr_utility.set_location('End of Archiving Stat Balances ',80);

     hr_utility.set_location('Leaving Procedure pay_hk_payslip_archive.' || l_procedure_name,90);
  END IF;


EXCEPTION
  WHEN OTHERS THEN
    IF g_debug THEN
       hr_utility.set_location('Error in calling archive balance code :',11);
    END IF;
    RAISE;

END archive_stat_balances;





--------------------------------------------------------------------------------------+
  -- This procedure calls 'pay_emp_action_arch.get_personal_information' that actually
  -- archives the employee details,employee address details, Employer Address Details
  -- and Net Pay Distribution information. Procedure 'get_personal_information' is
  -- is passed tax_unit_id to make core provided 'Choose Payslip' work for us.
  -- The action DF structures used are -
  --        ADDRESS DETAILS
  --        EMPLOYEE DETAILS
  --        EMPLOYEE NET PAY DISTRIBUTION
  --        EMPLOYEE OTHER INFORMATION
  -- After core procedure completes the archival, the information stored for category
  -- EMPLOYEE_NET_PAY_DISTRIBUTION is updated with currency code
---------------------------------------------------------------------------------------+

PROCEDURE archive_employee_details (p_payroll_action_id        IN NUMBER
                                  , p_pay_assignment_action_id IN NUMBER
                                  , p_assactid                 IN NUMBER
                                  , p_assignment_id            IN NUMBER
                                  , p_curr_pymt_ass_act_id     IN NUMBER
                                  , p_date_earned              IN DATE
                                  , p_latest_period_end_date   IN DATE
                                  , p_run_effective_date       IN DATE
                                  , p_time_period_id           IN NUMBER
                                  , p_pre_effective_date       IN DATE /* Bug 5736815 */) IS

 -- Cursor to select the archived information for category 'EMPLOYEE NET PAY DISTRIBUTION'
 -- by core package.

 CURSOR  csr_action_information_id(p_assact_id NUMBER)
 IS
 SELECT  action_information_id
         ,action_information1
         ,action_information2
   FROM  pay_action_information
  WHERE  action_information_category = 'EMPLOYEE NET PAY DISTRIBUTION'
    AND  action_context_id           =  p_assact_id
    AND  action_context_type         = 'AAP';

  -- Cursor to select the tax_unit_id of the prepayment needed for archival

  CURSOR csr_payment_runs(p_assignment_action_id NUMBER)
  IS
  SELECT tax_unit_id,mailstop
    FROM pay_hk_asg_payment_runs_v
    WHERE assignment_action_id         = p_assignment_action_id;


  -- Cursor to get the bank name,percentage and currency code using the view
  -- pay_sg_asg_net_payments_v

  -- Cursor to get MPF Due Date

  CURSOR csr_get_mpf_date(p_payroll_action_id NUMBER)
 IS
 SELECT pay_core_utils.get_parameter('MPF_DUE_DATE',legislative_parameters)
 FROM   pay_payroll_actions ppa
 WHERE  ppa.payroll_action_id = p_payroll_action_id;

 CURSOR csr_bank_details(p_curr_pymt_ass_act_id NUMBER, l_personal_payment_method_id NUMBER, l_org_payment_method_id NUMBER) /* Bug No : 2672510 */
 IS
 SELECT   pea.segment2 branch_code
        , pea.segment3 account_number
        , pop.currency_code
   FROM   pay_external_accounts pea
        , pay_personal_payment_methods_f ppm
        , pay_org_payment_methods_f pop
        , pay_pre_payments ppp
        , hr_lookups hl
  WHERE   ppm.personal_payment_method_id(+) =  ppp.personal_payment_method_id
    AND   pop.org_payment_method_id         =  ppp.org_payment_method_id
    AND   pea.segment3                      =  hl.lookup_code (+)
    AND   hl.lookup_type(+)                 =  'HK_ACCOUNT_TYPE'
    AND   pea.external_account_id(+)        =  ppm.external_account_id
    AND   ppp.assignment_action_id          =  p_curr_pymt_ass_act_id
    AND  ((ppp.personal_payment_method_id   =  l_personal_payment_method_id) or
          (ppp.org_payment_method_id        =  l_org_payment_method_id and ppp.personal_payment_method_id is null)) /* Bug No : 2672510 */
    AND  p_pre_effective_date BETWEEN pop.effective_start_date
                              AND     pop.effective_end_date
    AND  p_pre_effective_date BETWEEN nvl(ppm.effective_start_date, p_pre_effective_date)
                              AND     nvl(ppm.effective_end_date, p_pre_effective_date); /* Bug 5736815 */

  l_action_info_id NUMBER;
  l_ovn            NUMBER;
  l_tax_unit_id    NUMBER;
  l_branch_code   varchar2(100);
  l_account        varchar2(100);

  l_procedure_name VARCHAR2(80);

  l_bank_account_name pay_hk_asg_payment_meth_v.BANK_ACCOUNT_NAME%TYPE;
  l_percentage     NUMBER;
  l_bank_account pay_hk_asg_payment_meth_v.BANK_ACCOUNT%TYPE;
  l_payment_method pay_hk_asg_payment_meth_v.PAYMENT_METHOD%TYPE;
  l_currency pay_hk_asg_payment_meth_v.CURRENCY%TYPE;
  l_payment_amount  NUMBER;
  l_mail_stop pay_hk_asg_payment_runs_v.MAILSTOP%TYPE;

  l_mpf_due_date VARCHAR2(100);


BEGIN

  l_procedure_name := 'archive_employee_details'; -- Bug: 3604131

  IF g_debug THEN
     hr_utility.set_location('Entering Procedure pay_hk_payslip_archive.'|| l_procedure_name,10);


  -- call generic procedure to retrieve and archive all data for
  -- EMPLOYEE DETAILS, ADDRESS DETAILS and EMPLOYEE NET PAY DISTRIBUTION

     hr_utility.trace('Opening Cursor csr_payment_runs');
  END IF;

  OPEN  csr_payment_runs(p_curr_pymt_ass_act_id);
  FETCH csr_payment_runs INTO l_tax_unit_id,l_mail_stop;
  CLOSE csr_payment_runs;

  IF g_debug THEN
     hr_utility.trace('Closing Cursor csr_payment_runs');

     hr_utility.trace('Opening Cursor csr_get mpf date');
  END IF;

  OPEN  csr_get_mpf_date(p_payroll_action_id);
  FETCH csr_get_mpf_date into l_mpf_due_date;
  CLOSE csr_get_mpf_date;
  IF g_debug THEN
     hr_utility.trace('Closing Cursor csr get mpf date');
  END IF;

 l_mpf_due_date:=to_char(to_date(l_mpf_due_date,'YYYY/MM/DD'),'DD-Mon-YYYY');

  IF g_debug THEN
     hr_utility.set_location('Calling pay_emp_action_arch.get_personal_information ',20);
  END IF;

  pay_emp_action_arch.get_personal_information
     (p_payroll_action_id    => p_payroll_action_id       -- archive payroll_action_id
    , p_assactid             => p_assactid                -- archive assignment_action_id
    , p_assignment_id        => p_assignment_id           -- current assignment_id
    , p_curr_pymt_ass_act_id => p_curr_pymt_ass_act_id    -- prepayment assignment_action_id
    , p_curr_eff_date        => p_run_effective_date      -- run effective_date
    , p_date_earned          => p_date_earned             -- payroll date_earned
    , p_curr_pymt_eff_date   => p_latest_period_end_date  -- latest period payment date
    , p_tax_unit_id          => l_tax_unit_id             -- tax_unit_id needed for Choose Payslip region.
    , p_time_period_id       => p_time_period_id          -- payroll time_period_id
    , p_ppp_source_action_id => NULL
    , p_run_action_id        => p_pay_assignment_action_id
    );

  IF g_debug THEN
     hr_utility.set_location('Returned from pay_emp_action_arch.csr_personal_information ',30);

  -- Retrieve and Archive the HK specific employee details (mailstop)

     hr_utility.set_location('Archiving HK EMPLOYEE DETAILS',60);
  END IF;

  pay_action_information_api.create_action_information
      ( p_action_information_id        =>  l_action_info_id
      , p_action_context_id            =>  p_assactid
      , p_action_context_type          =>  'AAP'
      , p_object_version_number        =>  l_ovn
      , p_effective_date               =>  p_latest_period_end_date
      , p_source_id                    =>  NULL
      , p_source_text                  =>  NULL
      , p_action_information_category  =>  'HK EMPLOYEE DETAILS'
      , p_action_information1          =>  NULL
      , p_action_information2          =>  NULL
      , p_action_information3          =>  NULL
      , p_action_information21         =>  l_mpf_due_date
      , p_action_information22         =>  l_mail_stop
      );


  IF g_debug THEN
     hr_utility.trace('Opening Cursor csr_action_information_id');
  END IF;

  FOR net_pay_rec in csr_action_information_id(p_assactid)

  LOOP
    IF g_debug THEN
       hr_utility.trace('Opening Cursor csr_bank_details');
    END IF;
    OPEN  csr_bank_details(p_curr_pymt_ass_act_id,net_pay_rec.action_information2,net_pay_rec.action_information1); /* Bug No : 2672510 */
    FETCH csr_bank_details INTO  l_branch_code
                                ,l_bank_account
                                ,l_currency;


    CLOSE csr_bank_details;
    IF g_debug THEN
       hr_utility.trace('Closing Cursor csr_bank_details');
    END IF;

    l_ovn := 1;
    l_account:=null;

    if (l_branch_code is not null) and (l_bank_account is not null) then
    l_account:=l_branch_code||'-'||l_bank_account;
    end if;

    IF g_debug THEN
       hr_utility.trace('branch code:'||l_branch_code);
       hr_utility.trace('account number: '||l_bank_account);
       hr_utility.trace('action information 2:'||net_pay_rec.action_information2);
       hr_utility.trace('assignment_action_id:'||p_curr_pymt_ass_act_id);
       hr_utility.trace('Account:'||l_account);
    END IF;


    pay_action_information_api.update_action_information
        ( p_action_information_id     =>  net_pay_rec.action_information_id
        , p_object_version_number     =>  l_ovn
        , p_action_information9      =>   l_account
        , p_action_information10      =>  l_currency
        );

  END LOOP;

  IF g_debug THEN

     hr_utility.trace('Closing Cursor csr_action_information_id');

     hr_utility.set_location('Leaving Procedure pay_hk_payslip_archive.' || l_procedure_name,10);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF g_debug THEN
       hr_utility.set_location('Error in archiving Employee details ',5);
    END IF;
    RAISE;

END archive_employee_details;



--------------------------------------------------------------------+
   -- Procedure to archive Accrual Details.

--------------------------------------------------------------------+

--------------------------------------------------------------------+
   -- Procedure to archive Accruals
--------------------------------------------------------------------+

PROCEDURE archive_accrual_details ( p_payroll_action_id    IN NUMBER
                                  , p_time_period_id       IN NUMBER
                                  , p_assignment_id        IN NUMBER
 	                          , p_date_earned          IN DATE
 	                          , p_effective_date       IN DATE
                                  , p_assact_id            IN NUMBER
                                  , p_assignment_action_id IN NUMBER
                                  , p_period_end_date      IN DATE
                                  , p_period_start_date    IN DATE       ) IS


 -- Cursor to get the Leave Balance Details .

  CURSOR  csr_leave_balance(  p_assignment_action_id  NUMBER
                            , p_assignment_id         NUMBER)
  IS
  SELECT   pap.accrual_plan_name
         , hr_general_utilities.get_lookup_meaning('US_PTO_ACCRUAL',pap.accrual_category)
         , pap.accrual_units_of_measure
         , ppa.payroll_id
         , pap.business_group_id
         , pap.accrual_plan_id
   FROM    pay_accrual_plans             pap,
           pay_element_types_f           pet,
           pay_element_links_f           pel,
           pay_element_entries_f         pee,
           pay_assignment_actions        paa,
           pay_payroll_actions           ppa
  WHERE    pet.element_type_id      = pap.accrual_plan_element_type_id
    AND    pel.element_type_id      = pet.element_type_id
    AND    pee.element_link_id      = pel.element_link_id
    AND    paa.assignment_id        = pee.assignment_id
    AND    ppa.payroll_action_id    = paa.payroll_action_id
    AND    pap.accrual_category     = 'HKAL'
    AND    ppa.action_type          IN('R','Q')
    AND    ppa.action_status        = 'C'
    AND    ppa.date_earned BETWEEN pet.effective_start_date
                               AND pet.effective_end_date
    AND    ppa.date_earned BETWEEN pel.effective_start_date
                               AND pel.effective_end_date
    AND    ppa.date_earned BETWEEN pee.effective_start_date
                               AND pee.effective_end_date
    AND    paa.assignment_id        = p_assignment_id
    AND    paa.assignment_action_id = p_assignment_action_id;


  l_action_info_id               NUMBER;
  l_accrual_plan_id		 pay_accrual_plans.accrual_plan_id%type;
  l_accrual_plan_name		 pay_accrual_plans.accrual_plan_name%type;
  l_accrual_category             pay_accrual_plans.accrual_category%type;
  l_accrual_uom                  pay_accrual_plans.accrual_units_of_measure%type;
  l_payroll_id                   pay_payrolls_f.payroll_id%type;
  l_procedure_name               VARCHAR2(80);
  l_business_group_id		 NUMBER;
  l_effective_date               DATE;
  l_annual_leave_balance         NUMBER;
  l_ovn                          NUMBER;
  l_leave_taken			 NUMBER;

  l_start_date        DATE;
  l_end_date          DATE;
  l_net_entitlement   NUMBER;
  l_accrual_end_date  DATE;
  l_accrual           NUMBER;


BEGIN

  l_procedure_name := 'archive_employee_details'; -- Bug: 3604131

  IF g_debug THEN
     hr_utility.set_location('Start of accrual archival code',1);

     hr_utility.set_location('Entering Procedure pay_sg_payslip_archive.' || l_procedure_name,10);

     hr_utility.trace('Opening Cursor csr_leave_balance');
  END IF;

  OPEN  csr_leave_balance(p_assignment_action_id,p_assignment_id);
  FETCH csr_leave_balance INTO
          l_accrual_plan_name,
          l_accrual_category,
          l_accrual_uom,
          l_payroll_id,
          l_business_group_id,
          l_accrual_plan_id;

  CLOSE csr_leave_balance;

  IF g_debug THEN
     hr_utility.trace('Closing Cursor csr_leave_balance');

   -- Call to get annual leave balance

     hr_utility.set_location('Archiving Annual leave Balance information',2);
  END IF;

per_accrual_calc_functions.get_net_accrual(  p_assignment_id => p_assignment_id,
					     p_plan_id => l_accrual_plan_id,
					     p_payroll_id => l_payroll_id,
					     p_business_group_id => l_business_group_id,
					     p_calculation_date => p_effective_date,
					     p_start_date => l_start_date,
					     p_end_date => l_end_date,
					     p_accrual_end_date => l_accrual_end_date,
					     p_accrual => l_accrual,
					     p_net_entitlement => l_net_entitlement);

  IF g_debug THEN
     hr_utility.set_location('Archiving Leave Taken information',2);
  END IF;


  IF l_accrual_plan_name IS NOT NULL THEN

      pay_action_information_api.create_action_information
          ( p_action_information_id        =>  l_action_info_id
          , p_action_context_id            =>  p_assact_id
          , p_action_context_type          =>  'AAP'
          , p_object_version_number        =>  l_ovn
          , p_effective_date               =>  p_effective_date
          , p_source_id                    =>  NULL
          , p_source_text                  =>  NULL
          , p_action_information_category  =>  'APAC ACCRUALS'
          , p_action_information1          =>  l_accrual_plan_name
          , p_action_information2          =>  l_accrual_category
          , p_action_information4          =>  fnd_number.number_to_canonical(l_net_entitlement) -- Bug: 3604131
          , p_action_information5          =>  l_accrual_uom
          );

  END IF;

  IF g_debug THEN
     hr_utility.set_location('Leaving Procedure pay_hk_payslip_archive.' || l_procedure_name,10);
  END IF;


EXCEPTION
  WHEN OTHERS THEN
    IF g_debug THEN
       hr_utility.set_location('Error raised in archiving Accruals and Leave Taken ',5);
    END IF;
    RAISE;

END archive_accrual_details;




--------------------------------------------------------------------+
   -- Procedure to call the internal procedures to actually
   -- the archive the data. The procedure called are -
   -- archive_accrual_details
   -- archive_employee_details
   -- pay_apac_payslip_archive.archive_user_elements
   -- archive_stat_balances
   -- archive_stat_elements
   -- pay_apac_payslip_archive.archive_user_balances
--------------------------------------------------------------------+

PROCEDURE archive_code (p_assignment_action_id  IN pay_assignment_actions.assignment_action_id%TYPE,
	        	p_effective_date        IN DATE) IS


  -- Cursor to select all the locked prepayment and payrolls by the archive
  -- assignment action. The records are ordered descending as we only need
  -- latest payroll run in the prepayment.
  -- Bug# 3580617  Modified the SQL query of the cursor get_payslip_aa.

cursor get_payslip_aa(p_master_aa_id number)
  is
  select paa_arch_chd.assignment_action_id   chld_arc_assignment_action_id,
         paa_pre.assignment_action_id        pre_assignment_action_id,
         paa_run.assignment_action_id        run_assignment_action_id,
         ppa_pre.effective_date              pre_effective_date,
         paa_arch_chd.assignment_id,
         ppa_run.payroll_action_id,
         ppa_run.effective_date              run_effective_date,
         ppa_run.date_earned                 run_date_earned,
         ptp.start_date                      period_start_date,
         ptp.end_date                        period_end_date,
         ptp.regular_payment_date,
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
                                     where pai_run2.locking_action_id = paa_arch_chd.assignment_action_id
                                       and pai_run2.locked_action_id  = paa_run2.assignment_action_id
                                   );

     /* Added for the bug#5671633
        This cursor returns actual termination date if it falls in the pay period */

     CURSOR csr_payment_date(p_assignment_action_id  NUMBER)
     IS
     SELECT pps.actual_termination_date
     FROM   pay_payroll_actions ppa,
            pay_assignment_actions paa,
            per_time_periods ptp,
            per_all_assignments_f paf,
            per_periods_of_service pps
     WHERE  paa.assignment_action_id = p_assignment_action_id
     AND    ppa.payroll_action_id = paa.payroll_action_id
     AND    ptp.payroll_id = ppa.payroll_id
     AND    paf.assignment_id = paa.assignment_id
     AND    pps.period_of_service_id = paf.period_of_service_id
     AND    ppa.date_earned between ptp.start_date AND ptp.end_date
     AND    pps.actual_termination_date between paf.effective_start_date and paf.effective_end_date
     AND    pps.actual_termination_date between ptp.start_date AND ptp.end_date;

     l_pre_pay_assact_id               NUMBER;
     l_payment_date                    DATE   :=NULL;

BEGIN

  l_pre_pay_assact_id  := 0; -- Bug: 3604131

  IF g_debug THEN
     hr_utility.set_location('Start of archive code',20);
     hr_utility.trace('Opening Cursor get_payslip_aa');
  END IF;

  -- Bug# 3580617 Included the following function call pay_core_payslip_utils.generate_child_actions.

  pay_core_payslip_utils.generate_child_actions( p_assignment_action_id,
                                                 p_effective_date
                                               );

  FOR csr_rec IN get_payslip_aa(p_assignment_action_id)
  LOOP
    /* Added for the bug#5671633 */
    open  csr_payment_date(csr_rec.run_assignment_action_id);
    fetch csr_payment_date into l_payment_date;
    if csr_payment_date%NOTFOUND then
       l_payment_date := csr_rec.regular_payment_date;
    end if;
    close csr_payment_date;

    IF g_debug THEN
       hr_utility.set_location('csr_rec.run_assignment_action_id = ' || csr_rec.run_assignment_action_id,20);
       hr_utility.set_location('csr_rec.pre_assignment_action_id = ' || csr_rec.pre_assignment_action_id,30);
    END IF;


    -- Loop to be executed only once for a prepayment with latest payroll run details
    -- in the prepayment

    IF l_pre_pay_assact_id <> csr_rec.pre_assignment_action_id THEN

      -- Call to procedure to archive User Configurable Balnaces

      pay_apac_payslip_archive.archive_user_balances
          ( p_arch_assignment_action_id  => csr_rec.chld_arc_assignment_action_id  -- archive assignment action id
          , p_run_assignment_action_id   => csr_rec.run_assignment_action_id       -- payroll assignment action id
          , p_pre_effective_date         => csr_rec.pre_effective_date             -- prepayment effecive date
          );


      -- Call to procedure to archive Statutory Elements

      archive_stat_elements
          ( p_assignment_action_id       => csr_rec.pre_assignment_action_id      -- prepayment assignment action id
          , p_assignment_id              => csr_rec.assignment_id                 -- assignment id
          , p_effective_date             => csr_rec.pre_effective_date            -- prepayment effective date
          , p_assact_id                  => csr_rec.chld_arc_assignment_action_id -- archive assignment action id
          );

      -- Call to procedure to archive Statutory balances

      archive_stat_balances
          ( p_assignment_action_id       => csr_rec.pre_assignment_action_id       -- prepayment assignment action id
          , p_assignment_id              => csr_rec.assignment_id                  -- assignment id
          , p_date_earned                => csr_rec.run_date_earned                -- payroll date earned
          , p_effective_date             => csr_rec.pre_effective_date             -- prepayment effective date
          , p_assact_id                  => csr_rec.chld_arc_assignment_action_id  -- archive assignment action id
          );



      -- Call to procedure to archive User Configurable Elements

      pay_apac_payslip_archive.archive_user_elements
          ( p_arch_assignment_action_id  => csr_rec.chld_arc_assignment_action_id  -- archive assignment action
          , p_pre_assignment_action_id   => csr_rec.pre_assignment_action_id       -- prepayment assignment action id
          , p_latest_run_assact_id       => csr_rec.run_assignment_action_id       -- payroll assignment action id
          , p_pre_effective_date         => csr_rec.pre_effective_date             -- prepayment effective date
          );


      -- Call to procedure to archive Employee Details

      archive_employee_details
          ( p_payroll_action_id          => g_archive_pact                         -- archive payroll action id
          , p_assactid                   => csr_rec.chld_arc_assignment_action_id  -- archive action id
          , p_pay_assignment_action_id   => csr_rec.run_assignment_action_id       -- payroll run action id
          , p_assignment_id              => csr_rec.assignment_id                  -- assignment_id
          , p_curr_pymt_ass_act_id       => csr_rec.pre_assignment_action_id       -- prepayment assignment_action_id
          , p_date_earned                => csr_rec.run_date_earned                -- payroll date_earned
          , p_latest_period_end_date     => l_payment_date                         -- latest payment date
          , p_run_effective_date         => csr_rec.run_effective_date             -- run effective Date
          , p_time_period_id             => csr_rec.time_period_id                 -- time_period_id from per_time_periods
          , p_pre_effective_date         => csr_rec.pre_effective_date
   -- prepayment effective date, bug 5736815
          );

        -- Call to procedure to archive accrual and absennce details

      archive_accrual_details
          ( p_payroll_action_id          => csr_rec.payroll_action_id              -- latest payroll action id
          , p_time_period_id             => csr_rec.time_period_id                 -- latest period time period id
          , p_assignment_id              => csr_rec.assignment_id                  -- assignment id
          , p_date_earned                => csr_rec.run_date_earned                -- latest payroll date earned
          , p_effective_date             => csr_rec.pre_effective_date             -- prepayment effective date
          , p_assact_id                  => csr_rec.chld_arc_assignment_action_id  -- archive assignment action id
          , p_assignment_action_id       => csr_rec.run_assignment_action_id       -- payroll run action id
          , p_period_end_date            => csr_rec.period_end_date                -- latest period end date
          , p_period_start_date          => csr_rec.period_start_date              -- latest period start date
          );



    END IF;

    l_pre_pay_assact_id := csr_rec.pre_assignment_action_id;


  END LOOP;

  IF g_debug THEN
     hr_utility.trace('Opening Cursor csr_assignment_actions');

     hr_utility.set_location('End of archive code',37);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF g_debug THEN
       hr_utility.set_location('Error in archive code :',11);
    END IF;
    RAISE;

END archive_code;

/*
 * Bug 4260143 - Added the following function to return the assessed ri value
 */


FUNCTION get_assessed_ri(p_run_result_id in pay_run_results.run_result_id%TYPE)
RETURN VARCHAR2 IS

  l_assessed_ri  pay_run_result_values.result_value%TYPE;
  CURSOR csr_get_accessed_ri
  IS
  SELECT prrv.result_value
  FROM   pay_input_values_f pivf,
         pay_run_result_values  prrv
  WHERE  prrv.run_result_id = p_run_result_id
  AND    pivf.input_value_id = prrv.input_value_id
  AND    pivf.name = 'Assessed RI';
BEGIN
  l_assessed_ri := null;

  OPEN  csr_get_accessed_ri;
  FETCH csr_get_accessed_ri into l_assessed_ri;
  CLOSE csr_get_accessed_ri;

 IF l_assessed_ri IS NOT NULL THEN
   RETURN l_assessed_ri;
 END IF;

 RETURN null;
END get_assessed_ri;



END pay_hk_payslip_archive;

/
