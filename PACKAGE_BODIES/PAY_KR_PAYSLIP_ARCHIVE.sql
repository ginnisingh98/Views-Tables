--------------------------------------------------------
--  DDL for Package Body PAY_KR_PAYSLIP_ARCHIVE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_KR_PAYSLIP_ARCHIVE" AS
 /* $Header: pykrparc.pkb 120.2 2006/12/08 05:05:03 pdesu noship $ */

  g_debug   boolean   :=  hr_utility.debug_enabled;

/********************************************************************************
      -- This procedure returns a sql string to select a range
      -- of assignments eligible for archival.
      -- This range_code calls the APAC common procedure
      -- 'pay_apac_payslip_archive.range_code' to archive the EIT's balance and
      -- elements.And also this common procedure archives the payroll action
      -- level data(e.g. Messages etc),because as this KR legislative range_code is
      -- not multi-threaded procedure.
      -- This common  'pay_apac_payslip_archive.range_code' procedure takes
      -- care of the actual archival of EIT's data
 ********************************************************************************/

PROCEDURE range_code(p_payroll_action_id IN pay_payroll_actions.payroll_action_id%TYPE
       	            ,sqlstr   OUT NOCOPY VARCHAR2)
IS
BEGIN

  IF g_debug then
    hr_utility.trace(' Start of range_code');
  END IF;

  -- call to APAC common archive  procedure,which actually archives the EIT
  -- balances and elements values and also the payroll action level data(like messages..etc.)
  pay_apac_payslip_archive.range_code(p_payroll_action_id    => p_payroll_action_id);

  -- Bug No: 3580598
  pay_core_payslip_utils.range_cursor(p_payroll_action_id,
                                      sqlstr);

  IF g_debug THEN
    hr_utility.trace('End of range_code');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    hr_utility.trace('Error occured in range code');
    RAISE;
END range_code;

 /********************************************************************************
      -- This procedure is used to set global contexts
      -- This initialization_code calls the APAC common procedure
      -- 'pay_apac_payslip_archive.initialization_code' to populate the EIT's
      -- balance and elements values into global tables, because as it is multi-threaded
      -- procedure(actual archival of EIT's data is not done from this procedure)
  ********************************************************************************/

PROCEDURE initialization_code(p_payroll_action_id IN pay_payroll_actions.payroll_action_id%TYPE)
IS

  -- cursor to get the archival effective_date

  CURSOR csr_archive_effective_date(p_payroll_action_id NUMBER)
  IS
  SELECT ppa.effective_date
   FROM  pay_payroll_actions ppa
   WHERE ppa.payroll_action_id = p_payroll_action_id;

BEGIN

  if g_debug then
    hr_utility.trace(' Start of Initialization Code');
  end if;

  OPEN  csr_archive_effective_date(p_payroll_action_id);
  FETCH csr_archive_effective_date INTO g_archive_effective_date;
  CLOSE csr_archive_effective_date;

  g_archive_payroll_action_id :=p_payroll_action_id;

  if g_debug then
    hr_utility.trace(' g_archive_effective_date......:'||g_archive_effective_date);
    hr_utility.trace(' g_archive_payroll_action_id...:'||g_archive_payroll_action_id);
  end if;

  -- call to APAC common procedure "initilization_code" to populate the EIT's
  -- balances and elements values into global tables

  pay_apac_payslip_archive.initialization_code(
                p_payroll_action_id    => p_payroll_action_id );

  if g_debug then
    hr_utility.trace('Exiting from initliazation Code');
  end if;

EXCEPTION
  WHEN OTHERS THEN
    hr_utility.trace('Error occured in initialization code');
    RAISE;
END initialization_code;


/********************************************************************************
       -- This procedure further restricts the assignment_id's returned by
       -- range_code.
********************************************************************************/
PROCEDURE assignment_action_code(p_payroll_action_id IN NUMBER
                                ,p_start_person      IN NUMBER
                                ,p_end_person 	     IN NUMBER
                                ,p_chunk 	     IN NUMBER)
IS

BEGIN
  IF g_debug then
    hr_utility.trace(' Start of  assignment action code');
  END IF;
    -- Bug No: 3580598
	pay_core_payslip_utils.action_creation (
						   p_payroll_action_id,
						   p_start_person,
						   p_end_person,
						   p_chunk,
						   'KR_PAYSLIP_ARCHIVE',
						   'KR');
  IF g_debug then
    hr_utility.trace('End of  Assignment action code');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    hr_utility.trace('Error occured in Assignment action code');
    RAISE;
END assignment_action_code;

 /********************************************************************************
      -- This procedure archives all the standard earnings and deductions
      -- elements into pay_action_information with action_information_category
      -- as 'APAC ELEMENTS'.
 ********************************************************************************/

PROCEDURE archive_kr_standard_elements
           (p_pre_assignment_action_id   IN  pay_assignment_actions.assignment_action_id%TYPE
           ,p_pre_effective_date         IN  DATE
           ,p_arch_assignment_action_id  IN  NUMBER)
IS

  -- cursor to fetch the run result values of earnings and deduction
  -- elements.
  CURSOR csr_std_elements(p_pre_assignment_action_id NUMBER)
  IS
  SELECT element_reporting_name
         ,classification_name
         ,amount
         ,round(hours,2) hours
    FROM pay_kr_asg_elements_v
   WHERE assignment_action_id = p_pre_assignment_action_id
   ORDER BY element_reporting_name;

  l_action_info_id      NUMBER;
  l_ovn                 NUMBER;

BEGIN

  if g_debug then
    hr_utility.trace('Entering the archive_kr_standard_elements procedure');
  end if;

  FOR csr_record IN csr_std_elements(p_pre_assignment_action_id)
  LOOP

    pay_action_information_api.create_action_information
                  (p_action_information_id      => l_action_info_id
                  ,p_action_context_id          => p_arch_assignment_action_id
                  ,p_action_context_type        => 'AAP'
                  ,p_object_version_number      => l_ovn
                  ,p_effective_date             => p_pre_effective_date
                  ,p_source_id                  => NULL
                  ,p_source_text                => NULL
                  ,p_action_information_category=> 'APAC ELEMENTS'
                  ,p_action_information1        => csr_record.element_reporting_name
                  ,p_action_information2        => NULL
                  ,p_action_information3        => NULL
                  ,p_action_information4        => csr_record.classification_name
                  ,p_action_information5        => fnd_number.number_to_canonical(csr_record.amount) --3604142
                  ,p_action_information7        => csr_record.hours
                  );

  END LOOP;

  if g_debug then
    hr_utility.trace('Exiting the archive_kr_standard_elements procedure');
  end if;

EXCEPTION
 WHEN OTHERS THEN
   hr_utility.trace('Error raised in Archiving KR Standard Elements');
   RAISE;

END archive_kr_standard_elements;

/********************************************************************************
      -- This procedure archives Annual Leave information of an employee into
      -- pay_action_information with action_information_category as
      -- 'APAC ABSENCES'.
  ********************************************************************************/

PROCEDURE archive_leave_balances
           (p_arch_assignment_action_id  IN NUMBER
           ,p_run_assignment_action_id   IN NUMBER
           ,p_run_payroll_action_id      IN NUMBER
           ,p_assignment_id              IN NUMBER
           ,p_period_end_date            IN DATE
           ,p_pre_effective_date         IN DATE)
IS
  -- cursor to fetch the accrual plan id and the accruals UOM
  -- and latest runs effective date info

  CURSOR csr_leave_bal(
             p_run_assignment_action_id NUMBER
            ,p_assignment_id            NUMBER )
  IS
  SELECT  pap.accrual_plan_id               accrual_plan_id
         ,pap.business_group_id             business_group_id
         ,pap.accrual_plan_element_type_id  accrual_plan_element_type_id
         ,pap.accrual_plan_name             accrual_plan_name
         ,pap.accrual_category              accrual_category
         ,pap.accrual_start                 accrual_start_date
         ,ppa.payroll_id                    payroll_id
         ,pap.accrual_units_of_measure      accrual_units_of_measure
         ,hoi.org_information13             leave_taken_dim
         ,pac.assignment_id
   FROM   pay_accrual_plans            pap
         ,pay_assignment_actions       pac
         ,pay_payroll_actions          ppa
         ,hr_organization_information  hoi
         ,pay_element_links_f          pel
         ,pay_element_entries_f        pee
         ,pay_element_types_f          pet
  WHERE  pac.assignment_action_id    =  p_run_assignment_action_id
    AND  pac.assignment_id           =  p_assignment_id
    AND  pac.payroll_action_id       =  ppa.payroll_action_id
  /*  AND  pel.payroll_id              =  ppa.payroll_id */ -- Bug 2891590
    AND  ppa.action_type             IN ('R','Q')
    AND  ppa.action_status           =  'C'
    AND  pel.element_type_id         =  pet.element_type_id
    AND  pee.element_link_id         =  pel.element_link_id
    AND  pee.assignment_id           =  pac.assignment_id
    AND  pet.element_type_id         =  pap. accrual_plan_element_type_id
    AND  pac.tax_unit_id             =  hoi.organization_id
    AND  hoi.org_information_context =  'KR_BUSINESS_PLACE_REGISTRATION'
    AND  ppa.effective_date BETWEEN pet.effective_start_date AND pet.effective_end_date
    AND  ppa.effective_date BETWEEN pel.effective_start_date AND pel.effective_end_date
    AND  ppa.effective_date BETWEEN pee.effective_start_date AND pee.effective_end_date;

  l_from_date            DATE;
  l_leave_taken          NUMBER;
  l_leave_balance        NUMBER;
  l_start_date           DATE;
  l_end_date             DATE;
  l_current_start_date   VARCHAR2(20);
  l_current_end_date     VARCHAR2(20);
  l_accrual_end_date     DATE;
  l_accrual              NUMBER;
  l_net_entilement       NUMBER;
  l_action_info_id       NUMBER;
  l_ovn                  NUMBER;

BEGIN

  if g_debug then
    hr_utility.trace(' Start of Archive Leave Balances');
  end if;

  FOR leave_rec IN csr_leave_bal(p_run_assignment_action_id
                                ,p_assignment_id)
  LOOP
    if g_debug then
      hr_utility.trace('..l_taken_dimension..:'||leave_rec.leave_taken_dim);
    end if;

    IF leave_rec.leave_taken_dim= 'KRCTD' THEN

      l_from_date := to_date('01-01-'||to_char(p_period_end_date,'RRRR'),'DD-MM-YYYY');

    ELSIF leave_rec.leave_taken_dim = 'KRFTD' THEN

      l_from_date := to_date('01-04-'||to_char(p_period_end_date,'RRRR'),'DD-MM-YYYY');

    END IF;

    if g_debug then
      hr_utility.trace('....l_from_date........:'||l_from_date);
    end if;

    l_leave_taken:=per_accrual_calc_functions.get_absence(
                                 p_assignment_id    => p_assignment_id
                                ,p_plan_id          => leave_rec.accrual_plan_id
                                ,p_calculation_date => p_period_end_date
                                ,p_start_date       => l_from_date );

    if g_debug then
      hr_utility.trace(' .......Leaves Taken...:'||l_leave_taken);
    end if;

    l_current_start_date:=fnd_date.date_to_canonical(l_from_date);
    l_current_end_date  :=fnd_date.date_to_canonical(p_period_end_date);

    if g_debug then
      hr_utility.trace('....l_current_start_date....:'|| l_current_start_date);
      hr_utility.trace('....l_current_end_date......:'|| l_current_end_date);
    end if;

    per_accrual_calc_functions.get_net_accrual(
                   p_assignment_id             => p_assignment_id
                  ,p_plan_id                   => leave_rec.accrual_plan_id
                  ,p_payroll_id                => leave_rec.payroll_id
                  ,p_business_group_id         => leave_rec.business_group_id
                  ,p_assignment_action_id      => p_run_assignment_action_id
                  ,p_calculation_date          => p_period_end_date
                  ,p_accrual_start_date        => l_from_date
                  ,p_start_date                => l_start_date
                  ,p_end_date                  => l_end_date
                  ,p_accrual_end_date          => l_accrual_end_date
                  ,p_accrual                   => l_accrual
                  ,p_net_entitlement           => l_net_entilement
                  );

    l_leave_balance := l_accrual - l_leave_taken;

    if g_debug then
      hr_utility.trace('..Leave Balances...........:'|| l_leave_balance);
      hr_utility.trace('..archiving the ABSENCES Info');
    end if;

    pay_action_information_api.create_action_information (
                   p_action_information_id      => l_action_info_id
                  ,p_action_context_id          => p_arch_assignment_action_id
  	       	  ,p_action_context_type        => 'AAP'
  	       	  ,p_object_version_number      => l_ovn
  	       	  ,p_effective_date             => p_pre_effective_date
  	       	  ,p_source_id                  => NULL
  	       	  ,p_source_text                => NULL
  	       	  ,p_action_information_category=> 'APAC ABSENCES'
  	       	  ,p_action_information1        => NULL
  	       	  ,p_action_information2        => NULL
  	       	  ,p_action_information4        => l_current_start_date
  	       	  ,p_action_information5        => l_current_end_date
  	       	  ,p_action_information6        => fnd_number.number_to_canonical(l_leave_balance) --3604142
  	       	  ,p_action_information7        => leave_rec.accrual_units_of_measure
  	       	  ,p_action_information8        => fnd_number.number_to_canonical(l_leave_taken) --3604142
  	       	  );

  END LOOP;

EXCEPTION
  WHEN OTHERS THEN
    hr_utility.trace('Error occured in archive_leave_balances');
    RAISE;
END archive_leave_balances;

/********************************************************************************
      -- This procedure populates the message  saying
      -- 'Multiple Run types exists for this Pay Advice' into
      -- pay_message_lines table for the assignment which have more than one
      -- Run type for the current payment.
      -- This is the seeded message.
 ********************************************************************************/

PROCEDURE populate_multiple_runtypes_msg(
            p_line_sequence             IN     NUMBER
           ,p_payroll_id                IN     NUMBER
           ,p_message_level             IN     CHAR
           ,p_arch_assignment_action_id IN     NUMBER
           ,p_source_type               IN     CHAR)

IS

  l_message_text   fnd_new_messages.message_text%TYPE;

BEGIN

  if g_debug then
    hr_utility.trace(' Start Of populate_multiple_runtypes_msg');
  end if;

  fnd_message.set_name('PAY','PAY_KR_RUN_TYPE_WARNING_MESG');

  l_message_text := fnd_message.get;

  if g_debug then
    hr_utility.trace(' l_message_text..:'||l_message_text);
    hr_utility.trace(' Inserting the multiple run types message into PAY_MESSAGE_LINES table');
  end if;

  INSERT INTO pay_message_lines(line_sequence,
                                payroll_id,
                                message_level,
                                source_id,
                                source_type,
                                line_text)
                         VALUES(
                                p_line_sequence
                               ,p_payroll_id
                               ,p_message_level
                               ,p_arch_assignment_action_id
                               ,p_source_type
                               ,l_message_text
                              );


  if g_debug then
    hr_utility.trace(' End  Of populate_multiple_runtypes_msg');
  end if;

EXCEPTION
  WHEN OTHERS THEN
    hr_utility.trace('Error occured in archive_leave_balances');
    RAISE;

END populate_multiple_runtypes_msg;

/********************************************************************************
      -- This procedure archives the Employee Other information like
      -- Second Grade, Grade Point , Job Title, Seniority and Run Type Name
      -- into  pay_action_information  with action_information_category as
      -- 'KR EMPLOYEE DETAILS'.
 ********************************************************************************/

PROCEDURE archive_employee_other_info(
            p_arch_assignment_action_id  IN NUMBER
           ,p_assignment_id              IN NUMBER
           ,p_run_effective_date         IN DATE
           ,p_pre_effective_date         IN DATE
           ,p_run_type_id                IN NUMBER )
IS


  -- cursor to fetch the KR Additional Information like
  -- KR Job title, KR Seniority ,Second Grade , and Grade Point

  CURSOR csr_additional_info(p_assignment_id      NUMBER
                            ,p_run_effective_date DATE)
  IS
  SELECT paa.assignment_id
        ,hr_general.decode_lookup('KR_JOB_TITLE',hsck.segment2) kr_job_title
        ,hr_general.decode_lookup('KR_SENIORITY',hsck.segment3) kr_seniority
        ,pkg.grade_name                                         second_grade
        ,pgp.grade_point_name                                   grade_point
   FROM  hr_soft_coding_keyflex  hsck
        ,per_assignments_f       paa
        ,per_kr_grades           pkg
        ,per_kr_g_points         pgp
   WHERE hsck.soft_coding_keyflex_id(+) = paa.soft_coding_keyflex_id
     AND paa.assignment_id              = p_assignment_id
     AND pkg.grade_id (+)               = hsck.segment4       -- This segement4 stores the grade_id
     AND pgp.grade_point_id (+)         = hsck.segment5       -- This segement5 stores the grade point id
     AND p_run_effective_date BETWEEN paa.effective_start_date AND paa.effective_end_date;

  -- cursor to fetch the run type name

  CURSOR csr_run_type_name(p_run_type_id NUMBER)
  IS
  SELECT prtl.run_type_name
    FROM pay_run_types_f_vl prtl
   WHERE prtl.run_type_id = p_run_type_id;

  l_kr_job_title       VARCHAR2(150):=null;
  l_kr_seniority       VARCHAR2(150):=null;
  l_second_grade       per_kr_grades.grade_name%TYPE;
  l_grade_point        per_kr_g_points.grade_point_name%TYPE;
  l_kr_run_type_name   pay_run_types_f_vl.run_type_name%TYPE;
  l_action_info_id     NUMBER;
  l_ovn                NUMBER;

BEGIN

  if g_debug then
    hr_utility.trace(' Start Of archive_kr_employee_details');
  end if;

  FOR csr_record IN  csr_additional_info(p_assignment_id,p_run_effective_date)
  LOOP

    l_kr_job_title := csr_record.kr_job_title;
    l_kr_seniority := csr_record.kr_seniority;
    l_second_grade := csr_record.second_grade;
    l_grade_point  := csr_record.grade_point;

  END LOOP;

  if g_debug then
    hr_utility.trace(' l_kr_job_title ...:'||l_kr_job_title);
    hr_utility.trace(' l_kr_seniority....:'||l_kr_seniority);
    hr_utility.trace(' l_second_grade....:'||l_second_grade);
    hr_utility.trace(' l_grade_point.....:'||l_grade_point);
  end if;

  OPEN  csr_run_type_name(p_run_type_id);
  FETCH csr_run_type_name INTO l_kr_run_type_name;
  CLOSE csr_run_type_name;

  if g_debug then
    hr_utility.trace('l_kr_run_type_name...:'|| l_kr_run_type_name);
  end if;

  pay_action_information_api.create_action_information (
                   p_action_information_id      => l_action_info_id
                  ,p_action_context_id          => p_arch_assignment_action_id
                  ,p_action_context_type        => 'AAP'
                  ,p_object_version_number      => l_ovn
                  ,p_effective_date             => p_pre_effective_date
                  ,p_source_id                  => NULL
                  ,p_source_text                => NULL
                  ,p_action_information_category=> 'KR EMPLOYEE DETAILS'
                  ,p_action_information21       => l_second_grade
                  ,p_action_information22       => l_kr_run_type_name
                  ,p_action_information23       => l_kr_job_title
                  ,p_action_information24       => l_kr_seniority
                  ,p_action_information25       => l_grade_point
                  );

  if g_debug then
    hr_utility.trace(' End  Of archive_kr_employee_details');
  end if;

EXCEPTION
  WHEN OTHERS THEN
    hr_utility.trace('Error occured in archive_kr_employee_details');
    RAISE;
END archive_employee_other_info;

/********************************************************************************
     -- This procedure calls 'pay_emp_action_arch.get_personal_information' that actually
     -- archives the employee details,employee address details, Employer Address Details
     -- and Net Pay Distribution inforamation.  Procedure 'get_personal_informatio' is
     -- is passed tax_unit_id to make core provided 'Choose Payslip' work for us.
     -- The action DF structures used are -
     --        ADDRESS DETAILS
     --        EMPLOYEE DETAILS
     --        EMPLOYEE NET PAY DISTRIBUTION
     --        EMPLOYEE OTHER INFORMATION
     -- After core procedure completes the archival, the information stored for category
     -- EMPLOYEE_NET_PAY_DISTRIBUTION is updated with bank name specific to Korea
     -- using action_information5. Core procedure actually stores the bank branch number in
     -- action_information5
     -- And also updates action_information18 with the  'KR Business Place'  for the
     -- EMPLOYEE DETAILS action_information_category.Core procedure actually stores the
     -- Oragnization Name.
 ********************************************************************************/

PROCEDURE archive_employee_details (
            p_assignment_action_id     IN NUMBER
           ,p_assignment_id            IN NUMBER
           ,p_current_pymt_ass_act_id  IN NUMBER
           ,p_date_earned              IN DATE
           ,p_current_pymt_eff_date    IN DATE
           ,p_time_period_id           IN NUMBER
           ,p_tax_unit_id              IN NUMBER
           ,p_run_action_id            IN NUMBER
           ,p_run_effective_date       IN DATE)
IS
  -- cursor for getting the KR Bank Name

  CURSOR csr_net_pay(p_assignment_action_id IN NUMBER)
  IS
  SELECT pai.action_information_id
        ,pai.action_information5
        ,nvl(hr_general_utilities.get_lookup_Meaning('KR_BANK',substr(pai.action_information5,1,2)),' ') bank_name
   FROM  pay_action_information   pai
  WHERE  action_information_category  = 'EMPLOYEE NET PAY DISTRIBUTION'
    AND  action_context_id            =  p_assignment_action_id
    AND  action_context_type          =  'AAP';

  -- cursor for getting the Employer Address archived by core package

  CURSOR csr_emp_details(p_assignment_action_id IN NUMBER)
  IS
  SELECT  pai.action_information_id
         ,pai.action_information18
    FROM  pay_action_information pai
   WHERE  action_information_category = 'EMPLOYEE DETAILS'
     AND  action_context_id           =  p_assignment_action_id
     AND  action_context_type         =  'AAP';

  -- cursor for retrieving the Business Place for Korea

  CURSOR csr_business_place(p_tax_unit_id NUMBER)
  IS
  SELECT hoi.org_information1 business_place
    FROM hr_organization_information hoi
   WHERE hoi.organization_id         =  p_tax_unit_id
     AND hoi.org_information_context = 'KR_BUSINESS_PLACE_REGISTRATION';


  l_ovn                NUMBER;
  l_kr_business_place  hr_organization_information.org_information1%TYPE;

BEGIN

  if g_debug then
    hr_utility.trace(' Start Of archive_employee_details');
  end if;

  pay_emp_action_arch.get_personal_information(
                   p_payroll_action_id         => g_archive_payroll_action_id  -- arch payroll action id
                  ,p_assactid                  => p_assignment_action_id       -- arch assignment action id
                  ,p_assignment_id             => p_assignment_id              -- current assignment id
                  ,p_curr_pymt_ass_act_id      => p_current_pymt_ass_act_id    -- prepay ass_act_id
                  ,p_curr_eff_date             => p_run_effective_date         -- Latest payroll runs effective_date
                  ,p_date_earned               => p_date_earned                -- payroll date earned
                  ,p_curr_pymt_eff_date        => p_current_pymt_eff_date      -- payment_date
                  ,p_tax_unit_id               => p_tax_unit_id                -- Business place id
                  ,p_time_period_id            => p_time_period_id             -- payroll time_period_id
                  ,p_ppp_source_action_id      => NULL
                  ,p_run_action_id             => p_run_action_id              -- Latest run asst_act_id
                  );

  if g_debug then
    hr_utility.trace(' Updating the Bank Details..');
  end if;

  FOR net_pay_rec IN csr_net_pay(p_assignment_action_id)
  LOOP
    l_ovn :=1;

    if g_debug then
      hr_utility.trace(' Bank Name....:'||net_pay_rec.bank_name);
    end if;

    pay_action_information_api.update_action_information (
                   p_action_information_id     => net_pay_rec.action_information_id
                  ,p_object_version_number     => l_ovn
                  ,p_action_information9       => net_pay_rec.bank_name );
  END LOOP;

  if g_debug then
    hr_utility.trace(' Updating the Employer Name with Business Place');
  end if;

  OPEN  csr_business_place(p_tax_unit_id);
  FETCH csr_business_place INTO l_kr_business_place;
  CLOSE csr_business_place;

  if g_debug then
    hr_utility.trace('  Business Place  ..:'|| l_kr_business_place);
  end if;

  FOR  emp_rec IN csr_emp_details(p_assignment_action_id)
  LOOP

    l_ovn :=1;

    if g_debug then
      hr_utility.trace(' Updating the Employer Name..:'||emp_rec.action_information18);
      hr_utility.trace('    with Business Place    ..:'||l_kr_business_place);
    end if;

    pay_action_information_api.update_action_information (
                   p_action_information_id     => emp_rec.action_information_id
                  ,p_object_version_number     => l_ovn
                  ,p_action_information18      => l_kr_business_place);

  END LOOP;

  if g_debug then
    hr_utility.trace(' End Of archive_employee_details');
  end if;

EXCEPTION
  WHEN OTHERS THEN
    hr_utility.trace('Error occured in archive_employee_details');
    RAISE;
END archive_employee_details;

/********************************************************************************
     -- archive_code code calls the following procedures to archive the
     -- information required for the Korea Self service Online-Payslip

     -- archive_employee_details      : Which archives the employee details
     -- archive_kr_standard_elements  : archives the standards elements that
                                        are processed by payroll run.
     -- archive_leave_balances	      : archives the anuual leave information
      					and also the accrual plan information
     -- archive_employee_other_info   : archive other info like KR job title,
                                        KR Grade and KR Seniority.
     -- populate_multiple_runtypes_msg: Inserts the message into pay_message_lines
                                        if there are more then one run type exists
                                        for the current payment.
     -- pay_apac_payslip_archive.
          archive_user_elements       : This is the APAC common package is used to
                                        archive the user Configurable elments
                                        information.
     -- pay_apac_payslip_archive.
          archive_user_balances       : This is the APAC common package is used to
                                        archive the user Configurable Balances
                                        information.
 ********************************************************************************/

PROCEDURE archive_code (p_assignment_action_id  IN NUMBER
   		       ,p_effective_date 	IN DATE)
IS
   CURSOR get_payslip_aa(p_master_aa_id number)    -- Bug No: 3580598
   IS
	  SELECT paa_arch_chd.assignment_action_id 	chld_arc_assignment_action_id,
			 paa_pre.assignment_action_id 		pre_assignment_action_id,
			 paa_run.assignment_action_id 		run_assignment_action_id,
			 ppa_pre.effective_date 			prepayment_effective_date,
			 paa_arch_chd.assignment_id 		assignment_id,
			 ppa_run.effective_date 			run_effective_date,
			 ppa_run.date_earned 				date_earned,
			 ptp.end_date 						period_end_date,
			 ptp.time_period_id 				time_period_id,
			 paa_run.payroll_action_id 			run_payroll_action_id,
			 ppa_run.payroll_id 				payroll_id,
			 ppa_run.run_type_id 				run_type_id,
			 paa_run.tax_unit_id 				tax_unit_id
		FROM pay_assignment_actions paa_arch_chd,
			 pay_assignment_actions paa_arch_mst,
			 pay_assignment_actions paa_pre,
			 pay_action_interlocks  pai_pre,
			 pay_assignment_actions paa_run,
			 pay_action_interlocks  pai_run,
			 pay_payroll_actions    ppa_pre,
			 pay_payroll_actions    ppa_run,
			 per_time_periods       ptp
	   WHERE paa_arch_mst.assignment_action_id = p_master_aa_id
		 AND paa_arch_chd.source_action_id = paa_arch_mst.assignment_action_id
		 AND paa_arch_chd.payroll_action_id = paa_arch_mst.payroll_action_id
		 AND paa_arch_chd.assignment_id = paa_arch_mst.assignment_id
		 AND pai_pre.locking_action_id = paa_arch_mst.assignment_action_id
		 AND pai_pre.locked_action_id = paa_pre.assignment_action_id
		 AND pai_run.locking_action_id = paa_arch_chd.assignment_action_id
		 AND pai_run.locked_action_id = paa_run.assignment_action_id
		 AND ppa_pre.payroll_action_id = paa_pre.payroll_action_id
		 AND ppa_pre.action_type in ('P','U')
		 AND ppa_run.payroll_action_id = paa_run.payroll_action_id
		 AND ppa_run.action_type in ('R','Q')
		 AND ptp.payroll_id = ppa_run.payroll_id
		 AND ppa_run.date_earned between ptp.start_date
									 AND ptp.end_date
		 -- Get the highest in sequence for this payslip
		 AND paa_run.action_sequence = (SELECT max(paa_run2.action_sequence)
										  FROM pay_assignment_actions paa_run2,
											   pay_action_interlocks  pai_run2
										 WHERE pai_run2.locking_action_id =
												 paa_arch_chd.assignment_action_id
										   AND pai_run2.locked_action_id =
												 paa_run2.assignment_action_id
									   );
  -- cursor to fetch the period end date ,regular_payment_date
  CURSOR csr_period_end_date(p_assignment_action_id  NUMBER)
      IS
  SELECT ptp.end_date             end_date,
         ptp.regular_payment_date  regular_payment_date,
         ptp.time_period_id        time_period_id
   FROM  per_time_periods    ptp
        ,pay_payroll_actions ppa
  WHERE  ptp.payroll_id        = ppa.payroll_id
    AND  ppa.payroll_action_id = ( SELECT payroll_action_id
                                     FROM pay_assignment_actions
                                    WHERE assignment_action_id =p_assignment_action_id)
     AND ppa.date_earned BETWEEN ptp.start_date AND ptp.end_date;

   -- Bug 5600114
   CURSOR csr_get_termination_date(p_assignment_action_id  NUMBER)
       IS
   SELECT pps.actual_termination_date
     FROM   per_all_assignments_f paf,
            per_periods_of_service pps,
            pay_assignment_actions paa,
            per_time_periods ptp,
            pay_payroll_actions ppa
     WHERE  paa.assignment_action_id = p_assignment_action_id
       AND  ptp.payroll_id = ppa.payroll_id
       AND  paf.assignment_id = paa.assignment_id
       AND  ppa.payroll_action_id = paa.payroll_action_id
       AND  pps.period_of_service_id = paf.period_of_service_id
       AND  pps.actual_termination_date between paf.effective_start_date and paf.effective_end_date
       AND  pps.actual_termination_date between ptp.start_date AND ptp.end_date;

  -- cursor to fetch the sequence_number for populating the message
  -- for multiple run types
  CURSOR csr_msg_sequence
  IS
  SELECT  pay_message_lines_s.nextval
  FROM  dual;

  l_run_type_id               NUMBER:=0;
  l_run_type_count            NUMBER:=0;
  l_pre_assignment_action_id  NUMBER:=0;
  l_latest_run_type_id        NUMBER;
  l_payroll_id                NUMBER;
  l_line_sequence             NUMBER;
  l_period_end_date           DATE;
  l_payment_date              DATE;
  l_regular_payment_date      DATE;
  l_time_period_id            per_time_periods.time_period_id%TYPE;

BEGIN

  if g_debug then
    hr_utility.trace('Entering the archive_code');
  end if;
  -- Bug No: 3580598
  pay_core_payslip_utils.generate_child_actions(p_assignment_action_id,
                                                p_effective_date);
  l_pre_assignment_action_id:=0;

  FOR csr_master_record IN  get_payslip_aa(p_assignment_action_id) LOOP
    IF g_debug then
      hr_utility.trace(' ..for master  assignment action id..:'||csr_master_record.run_assignment_action_id);
      hr_utility.trace(' ..for assignment_id..:'||csr_master_record.assignment_id);
    END IF;

    -- This condition is for to archive the data once for each prepayment
    -- So for the case of two payroll runs under the single prepayment we have to archive
    -- employee information based on the latest payroll runs action id
    --
    IF l_pre_assignment_action_id <> csr_master_record.pre_assignment_action_id THEN

      OPEN  csr_period_end_date(csr_master_record.run_assignment_action_id);
      FETCH csr_period_end_date INTO l_period_end_date , l_regular_payment_date,l_time_period_id;
      CLOSE csr_period_end_date;

      -- Bug 5600114
      OPEN csr_get_termination_date(csr_master_record.run_assignment_action_id);
      FETCH csr_get_termination_date into l_payment_date;
      IF csr_get_termination_date%NOTFOUND then
          l_payment_date := l_regular_payment_date;
      END IF;
      CLOSE csr_get_termination_date;

      if g_debug then
        hr_utility.trace(' ..l_period_end_date...:'||l_period_end_date);
        hr_utility.trace(' ..l_payment_date   ...:'||l_payment_date);
      end if;

      archive_employee_details (
                   -- 3580598
                   p_assignment_action_id      => csr_master_record.chld_arc_assignment_action_id  -- arch ass_action_id
                  ,p_assignment_id             => csr_master_record.assignment_id             -- assignment_id
                  ,p_current_pymt_ass_act_id   => csr_master_record.pre_assignment_action_id  -- prepay ass_action_id
                  ,p_date_earned               => csr_master_record.date_earned               -- payroll date_earned
                  ,p_current_pymt_eff_date     => l_payment_date                              -- payment date
                  ,p_time_period_id            => l_time_period_id
                  ,p_tax_unit_id               => csr_master_record.tax_unit_id               -- business place id
                  ,p_run_action_id             => csr_master_record.run_assignment_action_id
                  ,p_run_effective_date        => csr_master_record.run_effective_date);

      archive_kr_standard_elements(
                   p_pre_assignment_action_id  => csr_master_record.pre_assignment_action_id
                  ,p_pre_effective_date        => csr_master_record.prepayment_effective_date
                   -- 3580598
                  ,p_arch_assignment_action_id => csr_master_record.chld_arc_assignment_action_id   --archival ass_action_id
                  );

      pay_apac_payslip_archive.archive_user_elements(
                   -- 3580598
                   p_arch_assignment_action_id => csr_master_record.chld_arc_assignment_action_id
                  ,p_pre_assignment_action_id  => csr_master_record.pre_assignment_action_id
                  ,p_latest_run_assact_id      => csr_master_record.run_assignment_action_id
                  ,p_pre_effective_date        => csr_master_record.prepayment_effective_date
                  );

      pay_apac_payslip_archive.archive_user_balances(
                   -- 3580598
                   p_arch_assignment_action_id => csr_master_record.chld_arc_assignment_action_id
                  ,p_run_assignment_action_id  => csr_master_record.run_assignment_action_id
                  ,p_pre_effective_date        => csr_master_record.prepayment_effective_date
                  );

      archive_leave_balances(
                   -- 3580598
                   p_arch_assignment_action_id => csr_master_record.chld_arc_assignment_action_id
                  ,p_run_assignment_action_id  => csr_master_record.run_assignment_action_id
                  ,p_run_payroll_action_id     => csr_master_record.run_payroll_action_id
                  ,p_assignment_id             => csr_master_record.assignment_id
                  ,p_period_end_date           => l_period_end_date
                  ,p_pre_effective_date        => csr_master_record.prepayment_effective_date
                  );

      archive_employee_other_info(
                   -- 3580598
                   p_arch_assignment_action_id => csr_master_record.chld_arc_assignment_action_id
                  ,p_assignment_id             => csr_master_record.assignment_id
                  ,p_run_effective_date        => csr_master_record.run_effective_date
                  ,p_pre_effective_date        => csr_master_record.prepayment_effective_date
                  ,p_run_type_id               => csr_master_record.run_type_id
                  );

      l_latest_run_type_id := csr_master_record.run_type_id;
      l_payroll_id         := csr_master_record.payroll_id;

    END IF;

    l_pre_assignment_action_id := csr_master_record.pre_assignment_action_id;

    IF l_run_type_id <> csr_master_record.run_type_id THEN
      l_run_type_count :=l_run_type_count + 1;
    END IF;
    l_run_type_id :=csr_master_record.run_type_id;

  END LOOP;   /* End of the csr_run_assignment_actions(p_assignment_action_id) Loop */
  if g_debug then
    hr_utility.trace(' l_run_type_count ....:'||l_run_type_count);
  end if;
  IF  l_run_type_count > 1    THEN
    OPEN  csr_msg_sequence;
    FETCH csr_msg_sequence INTO l_line_sequence;
    CLOSE csr_msg_sequence;

    populate_multiple_runtypes_msg(
                   p_line_sequence             => l_line_sequence
                  ,p_payroll_id                => l_payroll_id
                  ,p_message_level             => 'W'
                  ,p_arch_assignment_action_id => p_assignment_action_id
                  ,p_source_type               => 'A'
                  );
  END IF;
  if g_debug then
    hr_utility.trace('Exiting from the archive_code');
  end if;
EXCEPTION
  WHEN OTHERS THEN
    hr_utility.trace('Error raised in archive_code');
    RAISE;
END archive_code;
END pay_kr_payslip_archive;  /* End Of the Package Body  */

/
