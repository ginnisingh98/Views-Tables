--------------------------------------------------------
--  DDL for Package Body PAY_NZ_PAYSLIP_ARCHIVE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_NZ_PAYSLIP_ARCHIVE" AS
/* $Header: pynzparc.pkb 120.4.12010000.3 2008/10/23 04:49:46 skshin ship $ */

---------------------------------------------------------------------+
  -- This is a global variable used to store Archive assignment action id
--------------------------------------------------------------------+


g_archive_pact         NUMBER;


--------------------------------------------------------------------+
  -- This procedure returns a sql string to SELECT a range
  -- of assignments eligible for archival.
  -- It calls pay_apac_payslip_archive.range_code that archives the EIT
  -- definition and payroll level data (Messages, employer address details etc)
--------------------------------------------------------------------+

PROCEDURE range_code(p_payroll_action_id   IN pay_payroll_actions.payroll_action_id%TYPE,
                     p_sql                 OUT NOCOPY VARCHAR2) IS


BEGIN

  hr_utility.set_location('Start of range_code',1);


  --------------------------------------------------------------------------------+
      -- Call to range_code from common apac package 'pay_apac_payslip_archive'
      -- to archive the payroll action level data  and EIT defintions.
  --------------------------------------------------------------------------------+

  pay_apac_payslip_archive.range_code(p_payroll_action_id => p_payroll_action_id);


  --
  -- Bug 3580568
  --
  pay_core_payslip_utils.range_cursor(p_payroll_action_id,
                                        p_sql);

  hr_utility.set_location('End of range_code',2);

EXCEPTION
  WHEN OTHERS THEN
    hr_utility.set_location('Error in initialization_code',2);
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

  hr_utility.set_location('Start of initialization_code',1);

  g_archive_pact := p_payroll_action_id;

  ------------------------------------------------------------------+
  -- Call to common package procedure pay_apac_payslip_archive.
  -- initialization_code to to set the global tables for EIT
  -- that will be used by each thread in multi-threading.
  ------------------------------------------------------------------+

  pay_apac_payslip_archive.initialization_code(p_payroll_action_id => p_payroll_action_id);

  hr_utility.set_location('End of initialization_code',2);

EXCEPTION
  WHEN OTHERS THEN
    hr_utility.set_location('Error in initialization_code',2);
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
  -- work for NZ.
  -- The archive will not pickup already archived prepayments.
--------------------------------------------------------------------+

PROCEDURE assignment_action_code (p_payroll_action_id   IN pay_payroll_actions.payroll_action_id%TYPE,
                                  p_start_person        IN per_all_people_f.person_id%TYPE,
                                  p_end_person          IN per_all_people_f.person_id%TYPE,
                                  p_chunk               IN NUMBER)     IS

BEGIN

  hr_utility.trace('Start of  assignment action code');

  --
  -- Bug 3580568
  --
  pay_core_payslip_utils.action_creation (
                           p_payroll_action_id,
                           p_start_person,
                           p_end_person,
                           p_chunk,
                           'NZ_PAYSLIP_ARCHIVE',
                           'NZ');



  hr_utility.trace('End of  Assignment action code');

EXCEPTION
  WHEN OTHERS THEN
    hr_utility.trace('Error occured in Assignment action code');
    RAISE;

END assignment_action_code;



--------------------------------------------------------------------+
   -- This procedure archives the elements and run result values.
   -- It uses NZ Pay Advice view 'pay_nz_soe_run_elements_v'
   -- to get the elements and corresponding payments.
--------------------------------------------------------------------+

PROCEDURE archive_stat_elements(p_assignment_action_id  IN NUMBER,
                                p_assignment_id         IN NUMBER,
                                p_effective_date        IN DATE,
                                p_assact_id             IN NUMBER) IS

  -- Cursor to get all the elements processed for the assignment in the
  -- prepayment.

  CURSOR  csr_std_elements1(p_assignment_action_id NUMBER,
                            p_assignment_id        NUMBER)
  IS
  SELECT  element_reporting_name
         ,classification_name
         ,payment
    FROM  pay_nz_soe_run_elements_v1
   WHERE  assignment_action_id  = p_assignment_action_id
     AND  assignment_id         = p_assignment_id
     AND  classification_name IS NOT NULL
     AND  element_reporting_name NOT IN ('SSCWT Deduction','ESCT Deduction');  -- bug 7494658

  CURSOR  csr_std_elements2(p_assignment_action_id NUMBER,
                            p_assignment_id        NUMBER)
  IS
  SELECT  element_reporting_name
         ,classification_name
         ,payment
    FROM  pay_nz_soe_run_elements_v2
   WHERE  assignment_action_id  = p_assignment_action_id
     AND  assignment_id         = p_assignment_id
     AND  classification_name IS NOT NULL
     AND  element_reporting_name NOT IN ('SSCWT Deduction','ESCT Deduction');  -- bug 7494658

  l_action_info_id  NUMBER;
  l_ovn             NUMBER;
  l_procedure_name  CONSTANT VARCHAR2(80) := 'archive_stat_elements';

BEGIN

  hr_utility.set_location('Entering procedure ' || l_procedure_name,10);

  FOR csr_rec IN csr_std_elements1(p_assignment_action_id,p_assignment_id)

  LOOP

    hr_utility.set_location('Archiving Standard Element Details',20);

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
       , p_action_information5          =>  fnd_number.number_to_canonical (csr_rec.payment) -- Bug 3604103
       );

  END LOOP;

  FOR csr_rec IN csr_std_elements2(p_assignment_action_id,p_assignment_id)

  LOOP

    hr_utility.set_location('Archiving Standard Element Details',20);

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
       , p_action_information5          =>  fnd_number.number_to_canonical (csr_rec.payment) -- Bug 3604103
       );

  END LOOP;

  hr_utility.set_location('End of archive Standard Element',4);
  hr_utility.set_location('Leaving procedure ' || l_procedure_name,10);

EXCEPTION
  WHEN OTHERS THEN
    hr_utility.set_location('Error raised in archiving Standard Elements ',5);
    RAISE;

END archive_stat_elements;




--------------------------------------------------------------------+
   -- Procedure to archive the Statutory balances
--------------------------------------------------------------------+

PROCEDURE archive_balances( p_effective_date IN DATE
                           ,p_assact_id      IN NUMBER
                           ,p_narrative      IN VARCHAR2
                           ,p_ytd            IN NUMBER) IS

  l_action_info_id   NUMBER;
  l_ovn              NUMBER;
  l_procedure_name   CONSTANT VARCHAR2(80)  := 'archive_balances';

BEGIN

  hr_utility.set_location('Entering procedure ' || l_procedure_name,10);
  hr_utility.set_location('archiving balances :',10);

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
      , p_action_information4          =>  fnd_number.number_to_canonical(p_ytd) -- Bug 3604103
      );


EXCEPTION
  WHEN OTHERS THEN
    hr_utility.set_location('Error in archiving balance :',11);
    RAISE;

END archive_balances;




--------------------------------------------------------------------+
   -- Procedure to calculate the Statutory balances values
   -- Calls procedure archive_balances to acutally archives
   -- the Statutory balance values
--------------------------------------------------------------------+

PROCEDURE archive_stat_balances(p_assignment_action_id  IN NUMBER
                               ,p_assignment_id         IN NUMBER
                               ,p_date_earned           IN DATE
                               ,p_effective_date        IN DATE
                               ,p_assact_id             IN NUMBER) IS

  l_gross_this_pay              NUMBER;
  l_other_deductions_this_pay   NUMBER;
  l_tax_deductions_this_pay     NUMBER;
  l_gross_ytd                   NUMBER;
  l_other_deductions_ytd        NUMBER;
  l_tax_deductions_ytd          NUMBER;
  l_non_tax_allow_this_pay      NUMBER;
  l_non_tax_allow_ytd           NUMBER;
  l_pre_tax_deductions_this_pay NUMBER;
  l_pre_tax_deductions_ytd      NUMBER;
  l_net_payment_ytd             NUMBER;
  l_narrative                   VARCHAR2(150);
  l_procedure_name              CONSTANT VARCHAR2(80) := 'archive_stat_balances';

BEGIN

  hr_utility.set_location('Entering procedure ' || l_procedure_name,10);
  hr_utility.set_location('Calling balance_total from pay_nz_soe_pkg',20);

  -- Get the totals of the statutory balances

  pay_nz_soe_pkg.balance_totals(p_assignment_id,
                                p_assignment_action_id,
                                p_date_earned,
                                l_gross_this_pay,
                                l_other_deductions_this_pay,
                                l_tax_deductions_this_pay,
                                l_gross_ytd,
                                l_other_deductions_ytd,
                                l_tax_deductions_ytd,
                                l_non_tax_allow_this_pay,
                                l_non_tax_allow_ytd,
                                l_pre_tax_deductions_this_pay,
                                l_pre_tax_deductions_ytd);

  l_gross_ytd           := l_gross_ytd + l_pre_tax_deductions_ytd;

  l_net_payment_ytd     :=   l_gross_ytd
                           + l_non_tax_allow_ytd
                           - l_other_deductions_ytd
                           - l_tax_deductions_ytd;



  l_narrative := 'Taxable Earnings';

  hr_utility.set_location('Archiving value for  ' || l_narrative,30);

  archive_balances(p_effective_date =>p_effective_date
                  ,p_assact_id      =>p_assact_id
                  ,p_narrative      =>l_narrative
                  ,p_ytd            =>l_gross_ytd);



  l_narrative := 'Non Taxable Allowances';

  hr_utility.set_location('Archiving value for  ' || l_narrative,40);

  archive_balances(p_effective_date =>p_effective_date
                  ,p_assact_id      =>p_assact_id
                  ,p_narrative      =>l_narrative
                  ,p_ytd            =>l_non_tax_allow_ytd);



  l_narrative := 'Tax Deductions';

  hr_utility.set_location('Archiving value for  ' || l_narrative,50);

  archive_balances(p_effective_date =>p_effective_date
                  ,p_assact_id      =>p_assact_id
                  ,p_narrative      =>l_narrative
                  ,p_ytd            =>l_tax_deductions_ytd);



  l_narrative := 'Other Deductions ';

  hr_utility.set_location('Archiving value for  ' || l_narrative,60);

  archive_balances(p_effective_date =>p_effective_date
                  ,p_assact_id      =>p_assact_id
                  ,p_narrative      =>l_narrative
                  ,p_ytd            =>l_other_deductions_ytd);



  l_narrative := 'Net Payment ';

  hr_utility.set_location('Archiving value for  ' || l_narrative,70);

  archive_balances(p_effective_date =>p_effective_date
                  ,p_assact_id      => p_assact_id
                  ,p_narrative      => l_narrative
                  ,p_ytd            =>l_net_payment_ytd);


  hr_utility.set_location('End of Archiving Stat Balances ',80);

  hr_utility.set_location('Leaving procedure ' || l_procedure_name,90);

EXCEPTION
  WHEN OTHERS THEN
    hr_utility.set_location('error in calling archive balance code :',11);
    RAISE;

END archive_stat_balances;




--------------------------------------------------------------------------------------+
  -- This procedure calls 'pay_emp_action_arch.get_personal_information' that actually
  -- archives the employee details,employee address details, Employer Address Details
  -- and Net Pay Distribution inforamation. Procedure 'get_personal_informatio' is
  -- is passed tax_unit_id to make core provided 'Choose Payslip' work for us.
  -- The action DF structures used are -
  --        ADDRESS DETAILS
  --        EMPLOYEE DETAILS
  --        EMPLOYEE NET PAY DISTRIBUTION
  --        EMPLOYEE OTHER INFORMATION
  -- After core procedure completes the archival, the information stored for category
  -- EMPLOYEE_NET_PAY_DISTRIBUTION is updated with bank name specific to New Zealand
  -- using action_information5. Core procedure actually stores the bank branch number in
  -- action_information5.
  -- The NZ legsilative data (Tax Code) archival is also done in this procedure.
---------------------------------------------------------------------------------------+

PROCEDURE archive_employee_details (p_payroll_action_id        IN NUMBER
                                  , p_pay_assignment_action_id IN NUMBER
                                  , p_assactid                 IN NUMBER
                                  , p_assignment_id            IN NUMBER
                                  , p_curr_pymt_ass_act_id     IN NUMBER
                                  , p_date_earned              IN DATE
                                  , p_curr_pymt_eff_date       IN DATE
                                  , p_run_effective_date       IN DATE
                                  , p_time_period_id           IN NUMBER ) IS

  -- Cursor to select the archived information for category 'EMPLOYEE NET PAY DISTRIBUTION'
  -- by core package. Here actoin_information5 is the archived bank branch number

  CURSOR  csr_action_information_id(p_assact_id NUMBER)
  IS
  SELECT  action_information_id
         ,action_information5
    FROM  pay_action_information
   WHERE  action_information_category = 'EMPLOYEE NET PAY DISTRIBUTION'
     AND  action_context_id           =  p_assact_id
     AND  action_context_type         = 'AAP';



  -- Cursor to select the tax_unit_id of the prepayment needed for archival

  CURSOR csr_tax_unit_id(p_assignment_action_id NUMBER)
  IS
  SELECT tax_unit_id
    FROM pay_assignment_actions
   WHERE assignment_action_id         = p_assignment_action_id;



  -- Cursor to give the bank name for the bank code from the look up

  CURSOR csr_bank_name(p_bank_code VARCHAR2)
  IS
  SELECT hr_general_utilities.Get_lookup_Meaning('NZ_BANK',p_bank_code)
    FROM dual;


  l_action_info_id NUMBER;
  l_ovn            NUMBER;
  l_tax_code       VARCHAR2(5);
  l_tax_unit_id    NUMBER;
  l_procedure_name CONSTANT VARCHAR2(80) := 'archive_employee_details';
  l_bank_name      VARCHAR2(100);
  l_bank_code      VARCHAR2(2);

BEGIN

  hr_utility.set_location('Entering procedure '|| l_procedure_name,10);

  -- call generic procedure to retrieve and archive all data for
  -- EMPLOYEE DETAILS, ADDRESS DETAILS and EMPLOYEE NET PAY DISTRIBUTION


  OPEN  csr_tax_unit_id(p_curr_pymt_ass_act_id);
  FETCH csr_tax_unit_id INTO l_tax_unit_id;
  CLOSE csr_tax_unit_id;

  hr_utility.set_location('Calling pay_emp_action_arch.get_personal_information ',20);

  pay_emp_action_arch.get_personal_information
     (p_payroll_action_id    => p_payroll_action_id       -- archive payroll_action_id
    , p_assactid             => p_assactid                -- archive assignment_action_id
    , p_assignment_id        => p_assignment_id           -- current assignment_id
    , p_curr_pymt_ass_act_id => p_curr_pymt_ass_act_id    -- prepayment assignment_action_id
    , p_curr_eff_date        => p_run_effective_date      -- run effective_date
    , p_date_earned          => p_date_earned             -- payroll date_earned
    , p_curr_pymt_eff_date   => p_curr_pymt_eff_date      -- prepayment effective_date
    , p_tax_unit_id          => l_tax_unit_id             -- tax_unit_id needed for Choose Payslip region.
    , p_time_period_id       => p_time_period_id          -- payroll time_period_id
    , p_ppp_source_action_id => NULL
    , p_run_action_id        => p_pay_assignment_action_id
    );

  hr_utility.set_location('Returned from pay_emp_action_arch.csr_personal_information ',30);

  -- Retrieve and Archive the NZ specific(tax code) employee details

  l_tax_code := pay_nz_soe_pkg.get_tax_code(p_pay_assignment_action_id);

  hr_utility.set_location('Archiving NZ EMPLOYEE DETAILS',60);

  pay_action_information_api.create_action_information
      ( p_action_information_id        =>  l_action_info_id
      , p_action_context_id            =>  p_assactid
      , p_action_context_type          =>  'AAP'
      , p_object_version_number        =>  l_ovn
      , p_effective_date               =>  p_curr_pymt_eff_date
      , p_source_id                    =>  NULL
      , p_source_text                  =>  NULL
      , p_action_information_category  =>  'NZ EMPLOYEE DETAILS'
      , p_action_information1          =>  NULL
      , p_action_information2          =>  NULL
      , p_action_information3          =>  NULL
      , p_action_information21         =>  l_tax_code
      );


  hr_utility.set_location('Calling update Net Pay Distribution',80);

  -- Update Net Pay Distribution record with Bank name
  -- Since Core package puts the bank branch number in action_information5
  -- the bank name is obtained using this information

  FOR net_pay_rec in csr_action_information_id(p_assactid)

  LOOP

    l_bank_code := substr(net_pay_rec.action_information5,1,2);

    OPEN  csr_bank_name(l_bank_code);
    FETCH csr_bank_name INTO l_bank_name;
    CLOSE csr_bank_name;

    l_ovn := 1;

    pay_action_information_api.update_action_information
        ( p_action_information_id     =>  net_pay_rec.action_information_id
        , p_object_version_number     =>  l_ovn
        , p_action_information9       =>  l_bank_name
        );

  END LOOP;

  hr_utility.set_location('End of archive_employee_details',90);

EXCEPTION
  WHEN OTHERS THEN
    hr_utility.set_location('Error raised in archiving Employee details ',5);
    RAISE;

END archive_employee_details;




--------------------------------------------------------------------+
   -- Procedure to archive Accrual and Absence Details. It uses
   -- NZ Pay Advice views as
   -- pay_nz_asg_leave_taken_v - for leave details
--------------------------------------------------------------------+

PROCEDURE archive_accrual_details(p_payroll_action_id    IN NUMBER
                                 ,p_time_period_id       IN NUMBER
                                 ,p_assignment_id        IN NUMBER
                           ,p_date_earned          IN DATE
                           ,p_effective_date       IN DATE
                                 ,p_assact_id            IN NUMBER
                                 ,p_assignment_action_id IN NUMBER
                                 ,p_period_end_date      IN DATE) IS

  -- Cursor to get the absence details based on NZ Pay Advice leaves view.

  CURSOR  csr_leave_taken1(p_time_period_id NUMBER
                          ,p_assignment_id  NUMBER
                          ,p_date_earned    DATE)
  IS
  SELECT  element_reporting_name
         ,start_date
         ,end_date
         ,absence_duration
    FROM  pay_nz_asg_leave_taken_v1
   WHERE  time_period_id          = p_time_period_id
     AND  assignment_id           = p_assignment_id
     AND  date_earned             = p_date_earned;


  CURSOR  csr_leave_taken2(p_time_period_id NUMBER
                          ,p_assignment_id  NUMBER
                          ,p_date_earned    DATE)
  IS
  SELECT  element_reporting_name
         ,start_date
         ,end_date
         ,absence_duration
    FROM  pay_nz_asg_leave_taken_v2
   WHERE  time_period_id          = p_time_period_id
     AND  assignment_id           = p_assignment_id
     AND  date_earned             = p_date_earned;

  CURSOR  csr_leave_taken3(p_time_period_id NUMBER
                          ,p_assignment_id  NUMBER
                          ,p_date_earned    DATE)
  IS
  SELECT  element_reporting_name
         ,start_date
         ,end_date
         ,absence_duration
    FROM  pay_nz_asg_leave_taken_v3
   WHERE  time_period_id          = p_time_period_id
     AND  assignment_id           = p_assignment_id
     AND  date_earned             = p_date_earned;

  CURSOR  csr_leave_taken4(p_time_period_id NUMBER
                          ,p_assignment_id  NUMBER
                          ,p_date_earned    DATE)
  IS
  SELECT  element_reporting_name
         ,start_date
         ,end_date
         ,absence_duration
    FROM  pay_nz_asg_leave_taken_v4
   WHERE  time_period_id          = p_time_period_id
     AND  assignment_id           = p_assignment_id
     AND  date_earned             = p_date_earned;

  -- Cursor to get the accrual details

  CURSOR  csr_leave_balance(p_assignment_action_id  NUMBER
                           ,p_assignment_id         NUMBER)
  IS
  SELECT  pap.accrual_plan_name
         ,hr_general_utilities.get_lookup_meaning('US_PTO_ACCRUAL',pap.accrual_category)
         ,pap.accrual_units_of_measure
         ,ppa.payroll_id
         ,pap.business_group_id
         ,pap.accrual_plan_id
   FROM  pay_accrual_plans             pap,
         pay_element_types_f           pet,
         pay_element_links_f           pel,
         pay_element_entries_f         pee,
         pay_assignment_actions        paa,
         pay_payroll_actions           ppa
  WHERE  pet.element_type_id      = pap.accrual_plan_element_type_id
    AND  pel.element_type_id      = pet.element_type_id
    AND  pee.element_link_id      = pel.element_link_id
    AND  paa.assignment_id        = pee.assignment_id
    AND  ppa.payroll_action_id    = paa.payroll_action_id
    AND  pap.accrual_category     = 'NZAL'
    AND  ppa.action_type          IN('R','Q')
    AND  ppa.action_status        = 'C'
    AND  ppa.date_earned BETWEEN pet.effective_start_date
                             AND pet.effective_end_date
    AND  ppa.date_earned BETWEEN pel.effective_start_date
                             AND pel.effective_end_date
    AND  ppa.date_earned BETWEEN pee.effective_start_date
                             AND pee.effective_end_date
    AND  paa.assignment_id        = p_assignment_id
    AND  paa.assignment_action_id = p_assignment_action_id;

  l_accrual_uom                  pay_accrual_plans.accrual_units_of_measure%TYPE;
  l_action_info_id               NUMBER;
  l_accrual_plan_name            pay_accrual_plans.accrual_plan_name%TYPE;
  l_accrual_category             pay_accrual_plans.accrual_category%TYPE;
  l_annual_leave_balance         NUMBER;
  l_ovn                          NUMBER;
  l_payroll_id                   NUMBER;
  l_bg_id                        NUMBER;
  l_annual_leave_accrual_plan_id NUMBER;
  l_start_date                   VARCHAR2(20);
  l_end_date                     VARCHAR2(20);

BEGIN

  hr_utility.set_location('Start of accrual archival code',1);

  OPEN  csr_leave_balance(p_assignment_action_id,p_assignment_id);
  FETCH csr_leave_balance INTO
          l_accrual_plan_name,
          l_accrual_category,
          l_accrual_uom,
          l_payroll_id,
          l_bg_id,
          l_annual_leave_accrual_plan_id;
  CLOSE csr_leave_balance;

  -- Call to get annual leave balance

  l_annual_leave_balance := hr_nz_holidays.get_net_accrual(p_assignment_id
                                                          ,l_payroll_id
                                                          ,l_bg_id
                                                          ,l_annual_leave_accrual_plan_id
                                                          ,p_period_end_date);


  hr_utility.set_location('Archiving Annual leave information',2);

  IF l_accrual_plan_name IS NOT NULL AND l_annual_leave_balance IS NULL THEN
    l_annual_leave_balance := 0;
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
        , p_action_information4          =>  fnd_number.number_to_canonical(round(l_annual_leave_balance,2))  -- Bug 3604103
        , p_action_information5          =>  l_accrual_uom
        );

  END IF;

  hr_utility.set_location('End of accrual archival ',1);

  hr_utility.set_location('Start of leave archival code',1);

  FOR csr_rec IN csr_leave_taken1(p_time_period_id,p_assignment_id,p_date_earned)

  LOOP

    l_start_date := fnd_date.date_to_canonical(csr_rec.start_date);
    l_end_date   := fnd_date.date_to_canonical(csr_rec.end_date);

    pay_action_information_api.create_action_information
        ( p_action_information_id        =>  l_action_info_id
        , p_action_context_id            =>  p_assact_id
        , p_action_context_type          =>  'AAP'
        , p_object_version_number        =>  l_ovn
        , p_effective_date               =>  p_effective_date
        , p_source_id                    =>  NULL
        , p_source_text                  =>  NULL
        , p_action_information_category  =>  'APAC ABSENCES'
        , p_action_information1          =>  NULL
        , p_action_information2          =>  csr_rec.element_reporting_name
        , p_action_information4          =>  l_start_date
        , p_action_information5          =>  l_end_date
        , p_action_information6          =>  fnd_number.number_to_canonical(csr_rec.absence_duration)  -- Bug 3604103
        , p_action_information7          =>  NULL
        );

  END LOOP;

  FOR csr_rec IN csr_leave_taken2(p_time_period_id,p_assignment_id,p_date_earned)

  LOOP

    l_start_date := fnd_date.date_to_canonical(csr_rec.start_date);
    l_end_date   := fnd_date.date_to_canonical(csr_rec.end_date);

    pay_action_information_api.create_action_information
        ( p_action_information_id        =>  l_action_info_id
        , p_action_context_id            =>  p_assact_id
        , p_action_context_type          =>  'AAP'
        , p_object_version_number        =>  l_ovn
        , p_effective_date               =>  p_effective_date
        , p_source_id                    =>  NULL
        , p_source_text                  =>  NULL
        , p_action_information_category  =>  'APAC ABSENCES'
        , p_action_information1          =>  NULL
        , p_action_information2          =>  csr_rec.element_reporting_name
        , p_action_information4          =>  l_start_date
        , p_action_information5          =>  l_end_date
        , p_action_information6          =>  fnd_number.number_to_canonical(csr_rec.absence_duration)  -- Bug 3604103
        , p_action_information7          =>  NULL
        );

  END LOOP;

  FOR csr_rec IN csr_leave_taken3(p_time_period_id,p_assignment_id,p_date_earned)

  LOOP

    l_start_date := fnd_date.date_to_canonical(csr_rec.start_date);
    l_end_date   := fnd_date.date_to_canonical(csr_rec.end_date);

    pay_action_information_api.create_action_information
        ( p_action_information_id        =>  l_action_info_id
        , p_action_context_id            =>  p_assact_id
        , p_action_context_type          =>  'AAP'
        , p_object_version_number        =>  l_ovn
        , p_effective_date               =>  p_effective_date
        , p_source_id                    =>  NULL
        , p_source_text                  =>  NULL
        , p_action_information_category  =>  'APAC ABSENCES'
        , p_action_information1          =>  NULL
        , p_action_information2          =>  csr_rec.element_reporting_name
        , p_action_information4          =>  l_start_date
        , p_action_information5          =>  l_end_date
        , p_action_information6          =>  fnd_number.number_to_canonical(csr_rec.absence_duration)  -- Bug 3604103
        , p_action_information7          =>  NULL
        );

  END LOOP;

  FOR csr_rec IN csr_leave_taken4(p_time_period_id,p_assignment_id,p_date_earned)

  LOOP

    l_start_date := fnd_date.date_to_canonical(csr_rec.start_date);
    l_end_date   := fnd_date.date_to_canonical(csr_rec.end_date);

    pay_action_information_api.create_action_information
        ( p_action_information_id        =>  l_action_info_id
        , p_action_context_id            =>  p_assact_id
        , p_action_context_type          =>  'AAP'
        , p_object_version_number        =>  l_ovn
        , p_effective_date               =>  p_effective_date
        , p_source_id                    =>  NULL
        , p_source_text                  =>  NULL
        , p_action_information_category  =>  'APAC ABSENCES'
        , p_action_information1          =>  NULL
        , p_action_information2          =>  csr_rec.element_reporting_name
        , p_action_information4          =>  l_start_date
        , p_action_information5          =>  l_end_date
        , p_action_information6          =>  fnd_number.number_to_canonical(csr_rec.absence_duration)  -- Bug 3604103
        , p_action_information7          =>  NULL
        );

  END LOOP;

  hr_utility.set_location('End of archive Leaves Taken',4);

EXCEPTION
  WHEN OTHERS THEN
    hr_utility.set_location('Error raised in archiving Accruals and Leave Taken ',5);
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

  --
  -- Bug 3580568
  -- Changed cursor to csr_get_payslip_aa
  --
 cursor csr_get_payslip_aa(p_master_aa_id number)
  is
    SELECT paa_arch_chd.assignment_action_id   chld_arc_assignment_action_id
          ,paa_arch_chd.payroll_action_id      arch_payroll_action_id
          ,paa_pre.assignment_action_id        pre_assignment_action_id
          ,paa_run.assignment_action_id        run_assignment_action_id
          ,paa_run.payroll_action_id           run_payroll_action_id
          ,ppa_pre.effective_date              pre_effective_date
          ,paa_arch_chd.assignment_id
          ,ppa_run.effective_date              run_effective_date
          ,ppa_run.date_earned                 run_date_earned
          ,ptp.end_date                        period_end_date
          ,ptp.time_period_id
          ,ptp.start_date
          ,ptp.regular_payment_date
    FROM   pay_assignment_actions              paa_arch_chd
          ,pay_assignment_actions              paa_arch_mst
          ,pay_assignment_actions              paa_pre
          ,pay_action_interlocks               pai_pre
          ,pay_assignment_actions              paa_run
          ,pay_action_interlocks               pai_run
          ,pay_payroll_actions                 ppa_pre
          ,pay_payroll_actions                 ppa_run
          ,per_time_periods                    ptp
	  ,per_business_groups                 pbg
    WHERE  paa_arch_mst.assignment_action_id = p_master_aa_id
    AND    paa_arch_chd.source_action_id     = paa_arch_mst.assignment_action_id
    AND    paa_arch_chd.payroll_action_id    = paa_arch_mst.payroll_action_id
    AND    ppa_pre.business_group_id         = pbg.business_group_id
    AND    pbg.business_group_id             = ppa_run.business_group_id
    AND    ppa_pre.payroll_id                = ppa_run.payroll_id
    AND    paa_arch_chd.assignment_id        = paa_arch_mst.assignment_id
    AND    pai_pre.locking_action_id         = paa_arch_mst.assignment_action_id
    AND    pai_pre.locked_action_id          = paa_pre.assignment_action_id
    AND    pai_run.locking_action_id         = paa_arch_chd.assignment_action_id
    AND    pai_run.locked_action_id          = paa_run.assignment_action_id
    AND    ppa_pre.payroll_action_id         = paa_pre.payroll_action_id
    AND    ppa_pre.action_type              IN ('P','U')
    AND    ppa_run.payroll_action_id         = paa_run.payroll_action_id
    AND    ppa_run.action_type              IN ('R','Q')
    AND    ptp.payroll_id                    = ppa_run.payroll_id
    AND    ppa_run.date_earned         BETWEEN ptp.start_date
                                       AND     ptp.end_date
     -- Get the highest in sequence for this payslip
     AND paa_run.action_sequence             =
             (
               SELECT MAX(paa_run2.action_sequence)
               FROM  pay_assignment_actions paa_run2
                    ,pay_action_interlocks  pai_run2
               WHERE pai_run2.locking_action_id = paa_arch_chd.assignment_action_id
               AND   pai_run2.locked_action_id  = paa_run2.assignment_action_id
             );

   /* Bug No:5634580
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
     AND    pps.actual_termination_date between ptp.start_date AND ptp.end_date;


  l_pre_pay_assact_id               NUMBER;
  l_period_end_date                 DATE;
  l_time_period_id                  per_time_periods.time_period_id%type; /* Bug No : 2491444 */
  l_payment_date                    DATE   :=NULL;

BEGIN


  hr_utility.set_location('Start of archive code',20);

  --
  -- Bug 3580568
  --
  pay_core_payslip_utils.generate_child_actions(p_assignment_action_id,
                                                  p_effective_date);

  --
  -- Bug 3580568
  -- Changed cursor to csr_get_payslip_aa
  --
  FOR csr_rec IN csr_get_payslip_aa(p_assignment_action_id)

  LOOP

    hr_utility.set_location('csr_rec.master_assignment_action_id = ' || csr_rec.run_assignment_action_id,20);
    hr_utility.set_location('csr_rec.pre_assignment_action_id    = ' || csr_rec.pre_assignment_action_id,30);

     /*Bug No:5634580
     This cursor returns actual termination date if it falls in the pay period */

     open csr_payment_date(csr_rec.run_assignment_action_id);
      fetch csr_payment_date into l_payment_date;
      if csr_payment_date%NOTFOUND then
         l_payment_date := csr_rec.period_end_date;
      end if;
      close csr_payment_date;



    -- Loop to be executed only once for a prepayment with latest payroll run details
    -- in the prepayment

    -- Call to procedure to archive User Configurable Balnaces
    pay_apac_payslip_archive.archive_user_balances
          ( p_arch_assignment_action_id  => csr_rec.chld_arc_assignment_action_id -- archive assignment action id
          , p_run_assignment_action_id   => csr_rec.run_assignment_action_id      -- payroll assignment action id
          , p_pre_effective_date         => csr_rec.pre_effective_date            -- prepayment effecive date
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
          ( p_assignment_action_id       => csr_rec.run_assignment_action_id   -- payroll assignment action id
          , p_assignment_id              => csr_rec.assignment_id              -- assignment id
          , p_date_earned                => csr_rec.run_date_earned            -- payroll date earned
          , p_effective_date             => csr_rec.pre_effective_date         -- prepayment effective date
          , p_assact_id                  => csr_rec.chld_arc_assignment_action_id -- archive assignment action id
          );

      -- Call to procedure to archive User Configurable Elements

      pay_apac_payslip_archive.archive_user_elements
          ( p_arch_assignment_action_id  => csr_rec.chld_arc_assignment_action_id -- archive assignment action
          , p_pre_assignment_action_id   => csr_rec.pre_assignment_action_id      -- prepayment assignment action id
          , p_latest_run_assact_id       => csr_rec.run_assignment_action_id      -- payroll assignment action id
          , p_pre_effective_date         => csr_rec.pre_effective_date            -- prepayment effective date
          );



      /* Bug No : 2491444 -- Changed the value passed for time_period_id for all the procedures below.*/

      -- Call to procedure to archive Employee Details

      archive_employee_details
          ( p_payroll_action_id          => csr_rec.arch_payroll_action_id           -- archive payroll action id
          , p_assactid                   => csr_rec.chld_arc_assignment_action_id    -- archive action id
          , p_pay_assignment_action_id   => csr_rec.run_assignment_action_id         -- payroll run action id
          , p_assignment_id              => csr_rec.assignment_id                    -- assignment_id
          , p_curr_pymt_ass_act_id       => csr_rec.pre_assignment_action_id         -- prepayment assignment_action_id
          , p_date_earned                => csr_rec.run_date_earned                  -- payroll date_earned
          , p_curr_pymt_eff_date         => l_payment_date                           -- latest payment period end date
          , p_run_effective_date         => csr_rec.run_effective_date               -- run effective Date
          , p_time_period_id             => csr_rec.time_period_id                   -- time_period_id of per_time_periods
          );


      -- Call to procedure to archive accrual and absennce details

      archive_accrual_details
          ( p_payroll_action_id          => csr_rec.run_payroll_action_id         -- latest payroll action id
          , p_time_period_id             => csr_rec.time_period_id                -- latest period time period id
          , p_assignment_id              => csr_rec.assignment_id                 -- assignment id
          , p_date_earned                => csr_rec.run_date_earned               -- latest payroll date earned
          , p_effective_date             => csr_rec.pre_effective_date            -- prepayment effective date
          , p_assact_id                  => csr_rec.chld_arc_assignment_action_id -- archive assignment action id
          , p_assignment_action_id       => csr_rec.run_assignment_action_id      -- payroll run action id
          , p_period_end_date            => csr_rec.period_end_date               -- latest period end date
          );


    l_pre_pay_assact_id := csr_rec.pre_assignment_action_id;


  END LOOP;

  hr_utility.set_location('End of archive code',37);

EXCEPTION
  WHEN OTHERS THEN
    hr_utility.set_location('Error in archive code :',11);
    RAISE;

END archive_code;

END pay_nz_payslip_archive;

/
