--------------------------------------------------------
--  DDL for Package Body PAY_SG_PAYSLIP_ARCHIVE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_SG_PAYSLIP_ARCHIVE" AS
/* $Header: pysgparc.pkb 120.4 2006/12/27 21:39:57 jalin noship $ */

---------------------------------------------------------------------+
  -- This is a global variable used to store Archive assignment action id
--------------------------------------------------------------------+

g_archive_pact         NUMBER;

--------------------------------------------------------------------+
  -- This procedure returns a sql string to SELECT a range
  -- of assignments eligible for archival.
  -- It calls pay_apac_payslip_archive.range_code that archives the EIT
  -- definition and payroll level data (Messages, employer address details etc)
  -- Major changes were made to the procedure as part of
  -- fix for bug 3580587
--------------------------------------------------------------------+

PROCEDURE range_code(p_payroll_action_id   IN pay_payroll_actions.payroll_action_id%TYPE,
                     p_sql                 OUT NOCOPY VARCHAR2) IS


BEGIN

  hr_utility.set_location('Start of range_code',1);
  --------------------------------------------------------------------------------+
  -- Call to range_code from common apac package 'pay_apac_payslip_archive'
  -- to archive the payroll action level data  and EIT defintions.
  --------------------------------------------------------------------------------+
  pay_apac_payslip_archive.range_code( p_payroll_action_id => p_payroll_action_id );
  --
  pay_core_payslip_utils.range_cursor( p_payroll_action_id,
                                       p_sql
                                     );
  --
  hr_utility.set_location('End of range_code',2);
EXCEPTION
  WHEN OTHERS THEN
    hr_utility.set_location('Error in range code',2);
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
  -- work for SG.
  -- The archive will not pickup already archived prepayments.
  -- Major changes were made to the procedure as part of
  -- fix for bug 3580587
--------------------------------------------------------------------+

PROCEDURE assignment_action_code (p_payroll_action_id   IN pay_payroll_actions.payroll_action_id%TYPE,
                                  p_start_person        IN per_all_people_f.person_id%TYPE,
                                  p_end_person          IN per_all_people_f.person_id%TYPE,
                                  p_chunk               IN NUMBER)     IS
BEGIN
    hr_utility.set_location('Start of Assignment_Action_Code',1);
    pay_core_payslip_utils.action_creation (   p_payroll_action_id,
                                               p_start_person,
                                               p_end_person,
                                               p_chunk,
                                               'SG_PAYSLIP_ARCHIVE',
                                               'SG');
    hr_utility.set_location('End of Assignment_Action_Code',2);
EXCEPTION
    WHEN OTHERS THEN
        hr_utility.set_location('Error in Assignment_Action_Code',2);
        RAISE;
END assignment_action_code;


--------------------------------------------------------------------+
   -- This procedure archives the elements and run result values.
   -- It uses SG Pay Advice view 'pay_sg_asg_elements_v'
   -- to get the elements and corresponding payments.
--------------------------------------------------------------------+

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
         , classification_group
         , amount
         , foreign_currency_code
         , hours
         , exchange_rate
    FROM  pay_sg_asg_elements_v
   WHERE  run_assignment_action_id  = p_assignment_action_id
     AND  classification_group IS NOT NULL;


  l_action_info_id  NUMBER;
  l_ovn             NUMBER;
  l_foreign_currency_amount NUMBER;
  l_rate            NUMBER;
  l_procedure_name  VARCHAR2(80) ;

BEGIN
  l_procedure_name := 'archive_stat_elements';
  hr_utility.set_location('Entering Procedure pay_sg_payslip_archive.' || l_procedure_name,10);

  FOR csr_rec IN csr_std_elements(p_assignment_action_id,p_assignment_id)

  LOOP

    hr_utility.set_location('Archiving Standard Element Details',20);

    /* Start of Bug No : 2643038 */
    IF nvl(csr_rec.exchange_rate,0) <> 0 THEN
       l_foreign_currency_amount := csr_rec.amount / csr_rec.exchange_rate;
    ELSE
       l_foreign_currency_amount := NULL; /* Bug No : 2648763 */
    END IF;
    /* End of Bug No : 2643038*/

    l_rate                    := csr_rec.amount / csr_rec.hours;

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
       , p_action_information4          =>  csr_rec.classification_group
       , p_action_information5          =>  fnd_number.number_to_canonical(csr_rec.amount)            -- Bug 3604110
       , p_action_information7          =>  csr_rec.hours
       , p_action_information9          =>  fnd_number.number_to_canonical(l_rate)                    -- Bug 3604110
       , p_action_information10         =>  fnd_number.number_to_canonical(csr_rec.exchange_rate)     -- Bug 3604110
       , p_action_information11         =>  fnd_number.number_to_canonical(l_foreign_currency_amount) -- Bug 3604110
       , p_action_information12         =>  csr_rec.foreign_currency_code);


  END LOOP;
  hr_utility.trace('Closing Cursor csr_std_elements');
  hr_utility.set_location('End of archive Standard Element',4);
  hr_utility.set_location('Leaving Procedure pay_sg_payslip_archive.' || l_procedure_name,10);

EXCEPTION
  WHEN OTHERS THEN
    hr_utility.set_location('Error in archiving Standard Elements ',5);
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
  l_procedure_name   VARCHAR2(80);

BEGIN
  l_procedure_name := 'archive_balances';
  hr_utility.set_location('Entering Procedure pay_sg_payslip_archive.' || l_procedure_name,10);
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
      , p_action_information4          =>  fnd_number.number_to_canonical(p_ytd)            -- Bug 3604110
      );

  hr_utility.set_location('Leaving Procedure pay_sg_payslip_archive.' || l_procedure_name,10);


EXCEPTION
  WHEN OTHERS THEN
    hr_utility.set_location('Error in archiving balance :',11);
    RAISE;

END archive_balances;


--------------------------------------------------------------------+
   -- Procedure to archive the CPF balances
--------------------------------------------------------------------+

PROCEDURE archive_cpf_balances( p_effective_date IN DATE
                              , p_assact_id      IN NUMBER
                              , p_narrative      IN VARCHAR2
                              , p_curr           IN NUMBER
                              , p_ytd            IN NUMBER) IS

  l_action_info_id   NUMBER;
  l_ovn              NUMBER;
  l_procedure_name   VARCHAR2(80);

BEGIN
  l_procedure_name := 'archive_cpf_balances';
  hr_utility.set_location('Entering Procedure pay_sg_payslip_archive.' || l_procedure_name,10);
  hr_utility.set_location('archiving cpf balances :',10);

  -- Archive CPF balances

  pay_action_information_api.create_action_information
      ( p_action_information_id        =>  l_action_info_id
      , p_action_context_id            =>  p_assact_id
      , p_action_context_type          =>  'AAP'
      , p_object_version_number        =>  l_ovn
      , p_effective_date               =>  p_effective_date
      , p_source_id                    =>  NULL
      , p_source_text                  =>  NULL
      , p_action_information_category  =>  'APAC BALANCES 2'
      , p_action_information1          =>  p_narrative
      , p_action_information2          =>  NULL
      , p_action_information3          =>  NULL
      , p_action_information4          =>  fnd_number.number_to_canonical(p_curr)    -- Bug 3604110
      , p_action_information5          =>  fnd_number.number_to_canonical(p_ytd)     -- Bug 3604110
      );

  hr_utility.set_location('Leaving Procedure pay_sg_payslip_archive.' || l_procedure_name,10);


EXCEPTION
  WHEN OTHERS THEN
    hr_utility.set_location('Error in archiving CPF_balances :',11);
    RAISE;

END archive_cpf_balances;

--------------------------------------------------------------------+
   -- Procedure to calculate the balances values
   -- Calls procedure archive_balances and archive_cpf_balances to
   -- actually archives all the balance values
--------------------------------------------------------------------+

PROCEDURE archive_stat_balances(p_assignment_action_id  IN NUMBER
                               ,p_assignment_id         IN NUMBER
                               ,p_date_earned           IN DATE
                               ,p_effective_date        IN DATE
                               ,p_assact_id             IN NUMBER) IS

  l_gross_pay_current			NUMBER;
  l_statutory_deductions_current	NUMBER;
  l_other_deductions_current		NUMBER;
  l_net_pay_current			NUMBER;
  l_non_payroll_current			NUMBER;
  l_gross_pay_ytd			NUMBER;
  l_statutory_deductions_ytd		NUMBER;
  l_other_deductions_ytd		NUMBER;
  l_net_pay_ytd				NUMBER;
  l_non_payroll_ytd			NUMBER;
  l_employee_cpf_current		NUMBER;
  l_employer_cpf_current		NUMBER;
  l_cpf_total_current			NUMBER;
  l_employee_cpf_ytd			NUMBER;
  l_employer_cpf_ytd			NUMBER;
  l_cpf_total_ytd			NUMBER;
  l_person_id                           NUMBER;
  l_narrative                   	VARCHAR2(150);
  l_procedure_name              	VARCHAR2(80);

/* Bug 2824397 */
/* Bug:2824397. Removed distinct and added rownum join */
  cursor c_person_id(c_assignment_id per_all_assignments.assignment_id%type) is
    select person_id
    from   per_assignments_f    /* Bug# 2920732 */
    where assignment_id = c_assignment_id
    and   rownum = 1;
/* Bug 2824397 */

BEGIN
  l_procedure_name := 'archive_stat_balances';
  hr_utility.set_location('Entering Procedure pay_sg_payslip_archive.' || l_procedure_name,10);
  hr_utility.set_location('Calling balance_total from pay_sg_soe_pkg',20);

/* Bug 2824397 */
  open c_person_id(p_assignment_id);
  fetch c_person_id into l_person_id;
  close c_person_id;

/* Bug 2824397 */
  -- Get the totals of all the balances

  pay_sg_soe.balance_totals(    'Y',
   				p_assignment_action_id,
                                l_person_id,
                                l_gross_pay_current,
				l_statutory_deductions_current,
				l_other_deductions_current,
				l_net_pay_current,
				l_non_payroll_current,
				l_gross_pay_ytd,
				l_statutory_deductions_ytd,
				l_other_deductions_ytd,
				l_net_pay_ytd,
				l_non_payroll_ytd,
				l_employee_cpf_current,
				l_employer_cpf_current,
				l_cpf_total_current,
				l_employee_cpf_ytd,
				l_employer_cpf_ytd,
				l_cpf_total_ytd
		           );

  l_narrative := 'Gross Income';

  hr_utility.set_location('Archiving value for  ' || l_narrative,30);

  archive_balances(p_effective_date =>p_effective_date
                  ,p_assact_id      =>p_assact_id
                  ,p_narrative      =>l_narrative
                  ,p_ytd            =>l_gross_pay_ytd);


  l_narrative := 'Statutory Deductions';

  hr_utility.set_location('Archiving value for  ' || l_narrative,40);

  archive_balances(p_effective_date => p_effective_date
                  ,p_assact_id      => p_assact_id
                  ,p_narrative      => l_narrative
                  ,p_ytd            => l_statutory_deductions_ytd);


  l_narrative := 'Other Deductions';

  hr_utility.set_location('Archiving value for  ' || l_narrative,50);

  archive_balances(p_effective_date => p_effective_date
                  ,p_assact_id      => p_assact_id
                  ,p_narrative      => l_narrative
                  ,p_ytd            => l_other_deductions_ytd);


  l_narrative := 'Net Payment';

  hr_utility.set_location('Archiving value for  ' || l_narrative,60);

  archive_balances(p_effective_date => p_effective_date
                  ,p_assact_id      => p_assact_id
                  ,p_narrative      => l_narrative
                  ,p_ytd            => l_net_pay_ytd);


  l_narrative := 'Non Payroll Payments';

  hr_utility.set_location('Archiving value for  ' || l_narrative,70);

  archive_balances(p_effective_date => p_effective_date
                  ,p_assact_id      => p_assact_id
                  ,p_narrative      => l_narrative
                  ,p_ytd            => l_non_payroll_ytd);


  l_narrative := 'Employee';

  hr_utility.set_location('Archiving value for  ' || l_narrative,70);

  archive_cpf_balances(p_effective_date => p_effective_date
                      ,p_assact_id      => p_assact_id
                      ,p_narrative      => l_narrative
                      ,p_curr           => l_employee_cpf_current
                      ,p_ytd            => l_employee_cpf_ytd);



  l_narrative := 'Employer';

  hr_utility.set_location('Archiving value for  ' || l_narrative,70);

  archive_cpf_balances(p_effective_date => p_effective_date
                      ,p_assact_id      => p_assact_id
                      ,p_narrative      => l_narrative
                      ,p_curr           => l_employer_cpf_current
                      ,p_ytd            => l_employer_cpf_ytd);


  hr_utility.set_location('End of Archiving Stat Balances ',100);

  hr_utility.set_location('Leaving Procedure pay_sg_payslip_archive.' || l_procedure_name,110);

EXCEPTION
  WHEN OTHERS THEN
    hr_utility.set_location('error in calling archive balance code :',11);
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
  -- EMPLOYEE_NET_PAY_DISTRIBUTION is updated with bank name,percentage,currency code
  -- specific to Singapore using action_information9,action_information12 and
  -- action_information13 respectively.
---------------------------------------------------------------------------------------+

PROCEDURE archive_employee_details (p_payroll_action_id            IN NUMBER
                                  , p_pay_assignment_action_id     IN NUMBER
                                  , p_assactid                     IN NUMBER
                                  , p_assignment_id                IN NUMBER
                                  , p_curr_pymt_ass_act_id         IN NUMBER
                                  , p_date_earned                  IN DATE
                                  , p_latest_period_payment_date   IN DATE  /* Bug No : 2470554 */
                                  , p_run_effective_date           IN DATE
                                  , p_time_period_id               IN NUMBER
                                  , p_pre_effective_date           IN DATE /* Bug 5730336 */ ) IS

 -- Cursor to select the archived information for category 'EMPLOYEE NET PAY DISTRIBUTION'
 -- by core package.

 CURSOR  csr_action_information_id(p_assact_id NUMBER)
 IS
 SELECT  action_information_id
       , action_information1  /* Bug No : 2672510 */
       , action_information2  /* Bug No : 2538781 */
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


  -- Cursor to get the bank name,percentage and currency code using the view
  -- pay_sg_asg_net_payments_v


  /* Start of Bug No : 2538781 */

  CURSOR csr_bank_details(p_curr_pymt_ass_act_id NUMBER, l_personal_payment_method_id NUMBER, l_org_payment_method_id NUMBER) /* Bug No : 2672510 */
  IS
  SELECT  hl.meaning account_type  /* Bug 5435029 */
        , pea.segment5 bank_name
        , ppm.percentage
        , pop.currency_code
   FROM   pay_external_accounts pea
        , pay_personal_payment_methods_f ppm
        , pay_org_payment_methods_f pop
        , pay_pre_payments ppp
        , hr_lookups hl
  WHERE   ppm.personal_payment_method_id(+) =  ppp.personal_payment_method_id
    AND   pop.org_payment_method_id         =  ppp.org_payment_method_id
    AND   pea.segment3                      =  hl.lookup_code (+)
    AND   hl.lookup_type(+)                 =  'SG_ACCOUNT_TYPE'
    AND   pea.external_account_id(+)        =  ppm.external_account_id
    AND   ppp.assignment_action_id          =  p_curr_pymt_ass_act_id
    AND  ((ppp.personal_payment_method_id   =  l_personal_payment_method_id) or
          (ppp.org_payment_method_id        =  l_org_payment_method_id and ppp.personal_payment_method_id is null)) /* Bug No : 2672510 */
    AND  p_pre_effective_date BETWEEN pop.effective_start_date
                              AND     pop.effective_end_date
    AND  p_pre_effective_date BETWEEN nvl(ppm.effective_start_date, p_pre_effective_date)
                              AND     nvl(ppm.effective_end_date, p_pre_effective_date); /* Bug 5730336 */

  /* End of Bug No : 2538781 */

  l_action_info_id NUMBER;
  l_ovn            NUMBER;
  l_tax_code       VARCHAR2(5);
  l_tax_unit_id    NUMBER;
  l_procedure_name VARCHAR2(80);
  l_account_type   VARCHAR2(100);
  l_bank_name      VARCHAR2(100);
  l_percentage     NUMBER;
  l_currency_code  VARCHAR2(15);

BEGIN
  l_procedure_name := 'archive_employee_details';
  hr_utility.set_location('Entering Procedure pay_sg_payslip_archive.'|| l_procedure_name,10);


  -- call generic procedure to retrieve and archive all data for
  -- EMPLOYEE DETAILS, ADDRESS DETAILS and EMPLOYEE NET PAY DISTRIBUTION

  hr_utility.trace('Opening Cursor csr_tax_unit_id');
  OPEN  csr_tax_unit_id(p_curr_pymt_ass_act_id);
  FETCH csr_tax_unit_id INTO l_tax_unit_id;
  CLOSE csr_tax_unit_id;
  hr_utility.trace('Closing Cursor csr_tax_unit_id');
  hr_utility.set_location('Calling pay_emp_action_arch.get_personal_information ',20);

  pay_emp_action_arch.get_personal_information
     (p_payroll_action_id    => p_payroll_action_id           -- archive payroll_action_id
    , p_assactid             => p_assactid                    -- archive assignment_action_id
    , p_assignment_id        => p_assignment_id               -- current assignment_id
    , p_curr_pymt_ass_act_id => p_curr_pymt_ass_act_id        -- prepayment assignment_action_id
    , p_curr_eff_date        => p_run_effective_date          -- run effective_date
    , p_date_earned          => p_date_earned                 -- payroll date_earned
    , p_curr_pymt_eff_date   => p_latest_period_payment_date  -- latest payment date /* Bug No : 2470554 */
    , p_tax_unit_id          => l_tax_unit_id                 -- tax_unit_id needed for Choose Payslip region.
    , p_time_period_id       => p_time_period_id              -- time_period_id from per_time_periods /* Bug No:2496783 */
    , p_ppp_source_action_id => NULL
    , p_run_action_id        => p_pay_assignment_action_id
    );

  hr_utility.set_location('Returned from pay_emp_action_arch.csr_personal_information ',30);

  hr_utility.set_location('Calling update Net Pay Distribution',80);

  hr_utility.trace('Opening Cursor csr_action_information_id');

  FOR net_pay_rec in csr_action_information_id(p_assactid)

  LOOP

    hr_utility.trace('Opening Cursor csr_bank_details');
    OPEN  csr_bank_details(p_curr_pymt_ass_act_id , net_pay_rec.action_information2, net_pay_rec.action_information1); /* Bug No : 2538781,2672510 */
    FETCH csr_bank_details INTO   l_account_type  /* Bug 5435029 */
                                , l_bank_name
                                , l_percentage
                                , l_currency_code;
    CLOSE csr_bank_details;
    hr_utility.trace('Closing Cursor csr_bank_details');

    l_ovn := 1;

    pay_action_information_api.update_action_information
        ( p_action_information_id     =>  net_pay_rec.action_information_id
        , p_object_version_number     =>  l_ovn
        , p_action_information6       =>  l_account_type /* Bug 5435029 */
        , p_action_information9       =>  l_bank_name
        , p_action_information12      =>  l_percentage
        , p_action_information13      =>  l_currency_code
        );

  END LOOP;

hr_utility.trace('Closing Cursor csr_action_information_id');

hr_utility.set_location('Leaving Procedure pay_sg_payslip_archive.' || l_procedure_name,10);

EXCEPTION
  WHEN OTHERS THEN
    hr_utility.set_location('Error in archiving Employee details ',5);
    RAISE;

END archive_employee_details;


--------------------------------------------------------------------+
   -- Procedure to archive Accrual and Absence Details.
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
    AND    pap.accrual_category     = 'SGAL'
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
  l_payroll_id                   pay_all_payrolls_f.payroll_id%type;
  l_procedure_name               VARCHAR2(80);
  l_business_group_id		 NUMBER;
  l_effective_date               DATE;
  l_annual_leave_balance         NUMBER;
  l_ovn                          NUMBER;
  l_leave_taken			 NUMBER;

BEGIN
  l_procedure_name := 'archive_employee_details';
  hr_utility.set_location('Start of accrual archival code',1);

  hr_utility.set_location('Entering Procedure pay_sg_payslip_archive.' || l_procedure_name,10);

  OPEN  csr_leave_balance(p_assignment_action_id,p_assignment_id);
  FETCH csr_leave_balance INTO
          l_accrual_plan_name,
          l_accrual_category,
          l_accrual_uom,
          l_payroll_id,
          l_business_group_id,
          l_accrual_plan_id;

  CLOSE csr_leave_balance;

   -- Call to get annual leave balance

  hr_utility.set_location('Archiving Annual leave Balance information',2);

  l_annual_leave_balance := pay_sg_soe.net_accrual( p_assignment_id
  						  , l_accrual_plan_id
                                                  , l_payroll_id
                                                  , l_business_group_id
                                                  , p_date_earned);  /* Bug No : 2538781 */


  IF l_annual_leave_balance IS NULL THEN
    l_annual_leave_balance := 0;
  END IF;

  hr_utility.set_location('Archiving Leave Taken information',2);

  l_leave_taken   :=  per_accrual_calc_functions.get_absence
                       (p_assignment_id,
 			l_accrual_plan_id,
                        p_period_end_date,
                        p_period_start_date);


  IF l_leave_taken IS NULL THEN
      l_leave_taken := 0;
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
          , p_action_information_category  =>  'APAC ABSENCES'
          , p_action_information1          =>  l_accrual_plan_name
          , p_action_information2          =>  l_accrual_category
          , p_action_information6          =>  fnd_number.number_to_canonical(l_leave_taken)           -- Bug 3604110
          , p_action_information7          =>  l_accrual_uom
	  , p_action_information8          =>  fnd_number.number_to_canonical(l_annual_leave_balance)  -- Bug 3604110
          );

  END IF;

  hr_utility.set_location('Leaving Procedure pay_sg_payslip_archive.' || l_procedure_name,10);


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
   -- archive_cpf_balances
   -- archive_stat_elements
   -- pay_apac_payslip_archive.archive_user_balances
   -- Major changes were made to the procedure as part of
   -- fix for bug 3580587
--------------------------------------------------------------------+

PROCEDURE archive_code (p_assignment_action_id  IN pay_assignment_actions.assignment_action_id%TYPE,
	        	p_effective_date        IN DATE) IS


  -- Cursor to select all the locked prepayment and payrolls by the archive
  -- assignment action. The records are ordered descending as we only need
  -- latest payroll run in the prepayment.
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

     /* Added for the bug#5495382
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

  l_pre_pay_assact_id               NUMBER :=0;
  l_payment_date                    DATE   :=NULL;

BEGIN
  hr_utility.set_location('Start of archive code',20);
  --
  pay_core_payslip_utils.generate_child_actions( p_assignment_action_id,
                                                 p_effective_date
                                               );
  --
  FOR csr_rec IN get_payslip_aa( p_assignment_action_id )
  LOOP
      /* Added for the bug#5495382 */
      open csr_payment_date(csr_rec.run_assignment_action_id);
      fetch csr_payment_date into l_payment_date;
      if csr_payment_date%NOTFOUND then
         l_payment_date := csr_rec.regular_payment_date;
      end if;
      close csr_payment_date;

      -- Loop to be executed only once for a prepayment with latest payroll run details
      -- in the prepayment
      IF l_pre_pay_assact_id <> csr_rec.pre_assignment_action_id THEN
            -- Call to procedure to archive User Configurable Balnaces
            pay_apac_payslip_archive.archive_user_balances(
                    p_arch_assignment_action_id  => csr_rec.chld_arc_assignment_action_id,  -- archive assignment action id
                    p_run_assignment_action_id   => csr_rec.run_assignment_action_id,       -- payroll assignment action id
                    p_pre_effective_date         => csr_rec.pre_effective_date              -- prepayment effecive date
            );
            -- Call to procedure to archive Statutory Elements
            archive_stat_elements (
                     p_assignment_action_id      => csr_rec.pre_assignment_action_id,       -- prepayment assignment action id
                     p_assignment_id             => csr_rec.assignment_id,                  -- assignment id
                     p_effective_date            => csr_rec.pre_effective_date,             -- prepayment effective date
                     p_assact_id                 => csr_rec.chld_arc_assignment_action_id   -- archive assignment action id
            );
            -- Call to procedure to archive Statutory balances
            archive_stat_balances(
                     p_assignment_action_id       => csr_rec.run_assignment_action_id,      -- payroll assignment action id
                     p_assignment_id              => csr_rec.assignment_id,                 -- assignment id
                     p_date_earned                => csr_rec.run_date_earned,               -- payroll date earned
                     p_effective_date             => csr_rec.pre_effective_date,            -- prepayment effective date
                     p_assact_id                  => csr_rec.chld_arc_assignment_action_id  -- archive assignment action id
            );
            -- Call to procedure to archive User Configurable Elements
            pay_apac_payslip_archive.archive_user_elements (
                     p_arch_assignment_action_id  => csr_rec.chld_arc_assignment_action_id, -- archive assignment action
                     p_pre_assignment_action_id   => csr_rec.pre_assignment_action_id,      -- prepayment assignment action id
                     p_latest_run_assact_id       => csr_rec.run_assignment_action_id,      -- payroll assignment action id
                     p_pre_effective_date         => csr_rec.pre_effective_date             -- prepayment effective date
            );
            -- Call to procedure to archive Employee Details
            -- Bug No : 2496783 Correct time_period_id is passed to the following procedure calls
            archive_employee_details (
                     p_payroll_action_id          => g_archive_pact,                        -- archive payroll action id
                     p_assactid                   => csr_rec.chld_arc_assignment_action_id, -- archive action id
                     p_pay_assignment_action_id   => csr_rec.run_assignment_action_id,      -- payroll run action id
                     p_assignment_id              => csr_rec.assignment_id,                 -- assignment_id
                     p_curr_pymt_ass_act_id       => csr_rec.pre_assignment_action_id,      -- prepayment assignment_action_id
                     p_date_earned                => csr_rec.run_date_earned,               -- payroll date_earned
                     p_latest_period_payment_date => l_payment_date,                        -- latest payment date /*BugNo:5495382*/
                     p_run_effective_date         => csr_rec.run_effective_date,            -- run effective Date
                     p_time_period_id             => csr_rec.time_period_id,                -- time_period_id from per_time_periods
                     p_pre_effective_date         => csr_rec.pre_effective_date
            -- prepayment effective date, bug 5730336
            );
            -- Call to procedure to archive accrual and absennce details
            archive_accrual_details (
                     p_payroll_action_id          => csr_rec.payroll_action_id,             -- latest payroll action id
                     p_time_period_id             => csr_rec.time_period_id,                -- latest period time period id
                     p_assignment_id              => csr_rec.assignment_id,                 -- assignment id
                     p_date_earned                => csr_rec.run_date_earned,               -- latest payroll date earned
                     p_effective_date             => csr_rec.pre_effective_date,            -- prepayment effective date
                     p_assact_id                  => csr_rec.chld_arc_assignment_action_id, -- archive assignment action id
                     p_assignment_action_id       => csr_rec.run_assignment_action_id,      -- payroll run action id
                     p_period_end_date            => csr_rec.period_end_date,               -- latest period end date
                     p_period_start_date          => csr_rec.period_start_date              -- latest period start date
            );
    END IF;
    l_pre_pay_assact_id := csr_rec.pre_assignment_action_id;
  END LOOP;
  --
  hr_utility.set_location('End of archive code',37);
EXCEPTION
  WHEN OTHERS THEN
    hr_utility.set_location('Error in archive code :',11);
    RAISE;
END archive_code;


END pay_sg_payslip_archive;

/
