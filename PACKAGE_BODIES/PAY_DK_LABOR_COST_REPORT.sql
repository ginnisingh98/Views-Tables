--------------------------------------------------------
--  DDL for Package Body PAY_DK_LABOR_COST_REPORT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_DK_LABOR_COST_REPORT" AS
/* $Header: pydkalcr.pkb 120.0.12010000.5 2010/01/20 09:56:58 abraghun noship $ */
  g_debug               BOOLEAN      :=  hr_utility.debug_enabled;
  g_package             VARCHAR2(33) := ' PAY_DK_LABOR_COST_REPORT.';
  EOL                   VARCHAR2(5)  := fnd_global.local_chr(10);
-------------------------------------------------------------------------------

PROCEDURE generate( p_legal_employer   NUMBER
                   ,p_payroll          NUMBER
                   ,p_year             NUMBER
                   ,p_template_name    VARCHAR2
                   ,p_xml   OUT NOCOPY CLOB) IS

  l_legal_employer_name        hr_organization_units.name%TYPE;
  l_payroll_name               pay_payrolls_f.payroll_name%TYPE;
  l_business_group_id          hr_organization_units.business_group_id%TYPE;
  l_string                     VARCHAR2(32767) := NULL;
  l_xml                        CLOB;

  l_value_0050                 NUMBER := 0;
  l_value_0051                 NUMBER := 0;
  l_value_0052                 NUMBER := 0;
  l_value_0120                 NUMBER := 0;
  l_start_date                 DATE;
  l_end_date                   DATE;
  l_first_end_date             DATE;       --9059957
  l_last_end_date              DATE;       --9059957
  l_end_date_before_age_change DATE;       --9059957

  l_employer_atp_balance_id    NUMBER :=0;
  l_employee_atp_balance_id    NUMBER :=0;
  l_worked_hours_id            NUMBER :=0;
  l_total_atp_hours_id         NUMBER :=0; --9059957

  l_full_atp_contribution      NUMBER :=0;
  l_employer_atp               NUMBER :=0;
  l_employee_atp               NUMBER :=0;
  l_total_atp                  NUMBER :=0;
  l_trainee_total_atp          NUMBER :=0;
  l_atp_employee_count         NUMBER :=0;
  l_atp_trainee_count          NUMBER :=0;
  l_aer_rate                   NUMBER :=0;
  l_total_employer_aer         NUMBER :=0;
  l_total_aer                  NUMBER :=0;
  l_normal_hours_per_year      NUMBER :=0;
  l_non_atp_worked_hours       NUMBER :=0;
  l_worked_hours               NUMBER :=0;
  l_non_atp_employee_count     NUMBER :=0;
  l_total_atp_hours            NUMBER :=0; --9059957
  l_full_atp_hours             NUMBER :=0; --9059957
  l_partial_atp_hours          NUMBER :=0; --9059957
  l_atp_employee_age_low       NUMBER :=0; --9059957
  l_atp_employee_age_high      NUMBER :=0; --9059957
  l_age_on_start               NUMBER :=0; --9059957
  l_age_on_end                 NUMBER :=0; --9059957
  l_assgid_before_change       NUMBER :=0; --9059957
  ---------------------
  CURSOR csr_legal_employer_details(p_legal_employer_id NUMBER) IS
   SELECT
     hou.name, hou.business_group_id
   FROM
     hr_organization_units hou
   WHERE hou.organization_id = p_legal_employer_id;
  ---------------------
  CURSOR csr_payroll_name(p_payroll_id NUMBER, p_effective_date DATE) IS
   SELECT
     pay.payroll_name
   FROM
     pay_payrolls_f pay
   WHERE pay.payroll_id = p_payroll_id
    AND p_effective_date BETWEEN pay.effective_start_date AND pay.effective_end_date;
  ---------------------
  CURSOR csr_global_value(p_global_name VARCHAR2,
                         p_effective_date DATE) IS
   SELECT
     global_value
    FROM
     ff_globals_f
    WHERE global_name = p_global_name
      AND legislation_code = 'DK'
      AND p_effective_date BETWEEN effective_start_date AND effective_end_date;
  ---------------------
  CURSOR cur_defined_balance_id(BAL_NAME VARCHAR2, DIM_NAME VARCHAR2)
   IS
  SELECT
   defined_balance_id
   FROM
    pay_balance_types pbt,
    pay_defined_balances pdb,
    pay_balance_dimensions pbd
   WHERE pdb.balance_type_id = pbt.balance_type_id
    AND pdb.balance_dimension_id = pbd.balance_dimension_id
    AND pbt.balance_name = bal_name
    AND pbd.database_item_suffix = dim_name
    AND pbt.legislation_code = 'DK'
    AND pdb.legislation_code = 'DK'
    AND pbd.legislation_code = 'DK';
  ---------------------
  CURSOR csr_atp_assignments
          ( p_date_from            DATE
           ,p_date_to              DATE
           ,p_business_group_id    NUMBER
           ,p_legal_employer_id    NUMBER
           ,p_payroll_id           NUMBER
           ) IS
   SELECT
    asg.assignment_id assignment_id,
    MAX(pap.per_information3) trainee,
    MAX(paa.assignment_action_id) assignment_action_id,
    MAX(pap.date_of_birth) date_of_birth, --9059957
    MAX(asg.payroll_id) payroll_id        --9059957
   FROM
    per_all_people_f pap,
    per_all_assignments_f asg,
    pay_payroll_actions ppa,
    pay_assignment_actions paa,
    pay_run_results prr,
    pay_element_types_f pet
   WHERE pap.person_id = asg.person_id
    AND asg.payroll_id = ppa.payroll_id
    AND asg.assignment_id = paa.assignment_id
    AND ppa.payroll_action_id = paa.payroll_action_id
    AND ppa.action_type IN ( 'R' , 'B' , 'I' , 'Q' , 'V' )
    AND paa.assignment_action_id = prr.assignment_action_id
    AND pet.element_type_id = prr.element_type_id
    AND pet.legislation_code = 'DK'
    AND asg.payroll_id=NVL(p_payroll_id,asg.payroll_id)
    AND ppa.business_group_id = p_business_group_id
    AND paa.tax_unit_id = p_legal_employer_id
    AND pet.element_name IN ( 'Employee ATP' , 'Employer ATP' )
    AND ppa.date_earned BETWEEN p_date_from AND p_date_to
    AND asg.assignment_status_type_id = 1
    AND pap.current_employee_flag = 'Y'
    AND ppa.date_earned BETWEEN pap.effective_start_date AND pap.effective_end_date
    AND ppa.date_earned BETWEEN asg.effective_start_date AND asg.effective_end_date
    AND ppa.date_earned BETWEEN pet.effective_start_date AND pet.effective_end_date
   GROUP BY
    asg.assignment_id;
  ---------------------
  CURSOR csr_non_atp_assignments
          ( p_date_from            DATE
           ,p_date_to              DATE
           ,p_business_group_id    NUMBER
           ,p_legal_employer_id    NUMBER
           ,p_payroll_id           NUMBER
           ) IS
   SELECT
    asg.assignment_id assignment_id,
    max(paa.assignment_action_id) assignment_action_id
   FROM
    per_all_people_f pap,
    per_all_assignments_f asg,
    pay_payroll_actions ppa,
    pay_assignment_actions paa,
    pay_run_results prr
   WHERE pap.person_id = asg.person_id
    AND pap.current_employee_flag = 'Y'
    AND asg.payroll_id = ppa.payroll_id
    AND asg.assignment_id = paa.assignment_id
    AND asg.payroll_id = nvl(p_payroll_id
                            ,asg.payroll_id)
    AND asg.assignment_status_type_id = 1
    AND ppa.payroll_action_id = paa.payroll_action_id
    AND ppa.action_type IN ( 'R' , 'B' , 'I' , 'Q' , 'V' )
    AND ppa.business_group_id = p_business_group_id
    AND ppa.date_earned BETWEEN p_date_from AND p_date_to
    AND ppa.date_earned BETWEEN pap.effective_start_date AND pap.effective_end_date
    AND ppa.date_earned BETWEEN asg.effective_start_date AND asg.effective_end_date
    AND paa.tax_unit_id = p_legal_employer_id
    AND paa.assignment_action_id = prr.assignment_action_id
    AND NOT EXISTS (
        SELECT
          1
        FROM
          pay_payroll_actions ppa1,
          pay_assignment_actions paa1,
          pay_run_results prr1,
          pay_element_types_f pet
        WHERE pet.legislation_code = 'DK'
          AND pet.element_name IN ( 'Employee ATP' , 'Employer ATP' )
          AND pet.element_type_id = prr1.element_type_id
          AND ppa1.payroll_action_id = paa1.payroll_action_id
          AND paa1.assignment_id = asg.assignment_id
          AND paa1.assignment_action_id = prr1.assignment_action_id
          AND paa1.tax_unit_id = p_legal_employer_id
          AND ppa1.action_type IN ( 'R' , 'B' , 'I' , 'Q' , 'V' )
          AND ppa1.business_group_id = p_business_group_id
          AND ppa1.date_earned BETWEEN p_date_from AND p_date_to
          AND ppa1.date_earned BETWEEN pet.effective_start_date AND pet.effective_end_date)
     GROUP BY
      asg.assignment_id;
   ---------------------
--9059957--begin
  CURSOR csr_end_date_before_birthday
          ( p_date_of_birth        DATE
           ,p_report_year          NUMBER
           ,p_payroll_id           NUMBER
           ) IS
   SELECT
     start_date-1 before_date
   FROM
     per_time_periods
   WHERE payroll_id = p_payroll_id
     AND to_date(to_char(p_date_of_birth,'ddmm')||p_report_year,'ddmmyyyy')
         BETWEEN start_date AND end_date;
   ---------------------
  CURSOR csr_end_dates
          ( p_report_year          NUMBER
           ,p_payroll_id           NUMBER
           ) IS
   SELECT
     min(end_date) first_end_date,
     max(end_date) last_end_date
   FROM
     per_time_periods
   WHERE payroll_id = p_payroll_id
     AND to_char(end_date,'yyyy') = p_report_year;
   ---------------------
  CURSOR csr_assgid_before_change
            ( p_assignment_id        NUMBER
             ,p_business_group_id    NUMBER
             ,p_legal_employer_id    NUMBER
             ,p_payroll_id           NUMBER
             ,p_date_from            DATE
             ,p_date_to              DATE
             ) IS
   SELECT
    max(paa.assignment_action_id) assignment_action_id
  FROM
    pay_payroll_actions ppa,
    pay_assignment_actions paa
  WHERE paa.assignment_id = p_assignment_id
    AND paa.tax_unit_id = p_legal_employer_id
    AND ppa.payroll_action_id = paa.payroll_action_id
    AND ppa.action_type IN ( 'R' , 'B' , 'I' , 'Q' , 'V' )
    AND ppa.business_group_id = p_business_group_id
    AND ppa.payroll_id = p_payroll_id
    AND ppa.date_earned BETWEEN p_date_from AND p_date_to;
--9059957--end
-------------------------------------------------------------------------------
BEGIN
  IF g_debug THEN
    hr_utility.set_location(' Entering Procedure GENERATE',1);
  END IF;

  l_start_date := TO_DATE('01/01/'||TO_CHAR(P_YEAR), 'DD/MM/YYYY');
  l_end_date   := TO_DATE('31/12/'||TO_CHAR(P_YEAR), 'DD/MM/YYYY');

  OPEN csr_legal_employer_details(p_legal_employer);
    FETCH csr_legal_employer_details INTO l_legal_employer_name,l_business_group_id;
  CLOSE csr_legal_employer_details;

  OPEN csr_payroll_name(p_payroll,l_end_date);
    FETCH csr_payroll_name INTO l_payroll_name;
  CLOSE csr_payroll_name;

 /* Balance Fetches */
  OPEN cur_defined_balance_id('Employer ATP Deductions', '_ASG_LE_YTD');
   FETCH cur_defined_balance_id INTO l_employer_atp_balance_id;
  CLOSE cur_defined_balance_id;

  OPEN cur_defined_balance_id('Employee ATP Deductions', '_ASG_LE_YTD');
    FETCH cur_defined_balance_id INTO l_employee_atp_balance_id;
  CLOSE cur_defined_balance_id;

  OPEN cur_defined_balance_id('Worked Hours', '_ASG_LE_YTD');
    FETCH cur_defined_balance_id INTO l_worked_hours_id;
  CLOSE cur_defined_balance_id;

--9059957--begin
  OPEN cur_defined_balance_id('Total ATP Hours', '_ASG_LE_YTD');
    FETCH cur_defined_balance_id INTO l_total_atp_hours_id;
  CLOSE cur_defined_balance_id;
--9059957--end


 /* Global Fetches */
  OPEN csr_global_value('DK_AER_ATPAMOUNT_QUARTER',l_end_date);
    FETCH csr_global_value INTO l_full_atp_contribution;
  CLOSE csr_global_value;
  l_full_atp_contribution := l_full_atp_contribution*4; -- QTR x 4 = YEAR

  OPEN csr_global_value('DK_AER_RATE',l_end_date);
    FETCH csr_global_value INTO l_aer_rate;
  CLOSE csr_global_value;
  l_aer_rate := l_aer_rate*4; -- QTR x 4 = Year

  OPEN csr_global_value('DK_HOURS_IN_WEEK',l_end_date);
    FETCH csr_global_value INTO l_normal_hours_per_year;
  CLOSE csr_global_value;
  l_normal_hours_per_year := l_normal_hours_per_year*52; -- Week x 52 = Year

--9059957--begin
  OPEN csr_global_value('DK_ATP_AGE_LOW',l_end_date);
    FETCH csr_global_value INTO l_atp_employee_age_low;
  CLOSE csr_global_value;

  OPEN csr_global_value('DK_ATP_AGE_HIGH',l_end_date);
    FETCH csr_global_value INTO l_atp_employee_age_high;
  CLOSE csr_global_value;
--9059957--end

  FOR c_atp_assignments IN csr_atp_assignments(l_start_date,l_end_date,
                            l_business_group_id,p_legal_employer,p_payroll)
   LOOP
    l_employer_atp := pay_balance_pkg.get_value(
          p_defined_balance_id   => l_employer_atp_balance_id,
          p_assignment_action_id => c_atp_assignments.assignment_action_id,
          p_tax_unit_id          => p_legal_employer,
          p_jurisdiction_code    => NULL,
          p_source_id            => NULL,
          p_tax_group            => NULL,
          p_date_earned          => NULL);

    l_employee_atp := pay_balance_pkg.get_value(
          p_defined_balance_id   => l_employee_atp_balance_id,
          p_assignment_action_id => c_atp_assignments.assignment_action_id,
          p_tax_unit_id          => p_legal_employer,
          p_jurisdiction_code    => NULL,
          p_source_id            => NULL,
          p_tax_group            => NULL,
          p_date_earned          => NULL);

    l_total_atp := l_total_atp + NVL(l_employer_atp,0)+ NVL(l_employee_atp,0);

    IF NVL(c_atp_assignments.trainee,'N') = 'Y' THEN
       l_trainee_total_atp := l_trainee_total_atp
                             + NVL(l_employer_atp,0)+ NVL(l_employee_atp,0);
    END IF;

--9059957--begin

    OPEN csr_end_dates(p_year,c_atp_assignments.payroll_id);
      FETCH csr_end_dates INTO l_first_end_date,l_last_end_date;
    CLOSE csr_end_dates;
    --9127531-- TRUNC added
    l_age_on_start := TRUNC(MONTHS_BETWEEN(l_first_end_date,c_atp_assignments.date_of_birth)/12);
    l_age_on_end   := TRUNC(MONTHS_BETWEEN(l_last_end_date,c_atp_assignments.date_of_birth)/12);

    -- If age of the Assignment is below ATP LOW at year end
    -- or  above ATP HIGH at the beginning of the year
    -- Completely no ATP condition
    IF (l_age_on_end < l_atp_employee_age_low) OR
       (l_age_on_start > l_atp_employee_age_high)
    THEN
          l_full_atp_hours := pay_balance_pkg.get_value(
          p_defined_balance_id   => l_total_atp_hours_id,
          p_assignment_action_id => c_atp_assignments.assignment_action_id,
          p_tax_unit_id          => p_legal_employer,
          p_jurisdiction_code    => NULL,
          p_source_id            => NULL,
          p_tax_group            => NULL,
          p_date_earned          => NULL);

          l_total_atp_hours := l_total_atp_hours + NVL(l_full_atp_hours,0); --9258608
          l_full_atp_hours :=0;
    ELSIF
    -- If reached age ATP LOW or ATP HIGH during the year.
    -- Partially No ATP condition
      (l_age_on_start = (l_atp_employee_age_low -1) AND
       l_age_on_end = l_atp_employee_age_low)
      OR
      (l_age_on_start = (l_atp_employee_age_high) AND
       l_age_on_end = l_atp_employee_age_high + 1) --9127531

    THEN

      OPEN csr_end_date_before_birthday(c_atp_assignments.date_of_birth,
                                          p_year,c_atp_assignments.payroll_id);
        FETCH csr_end_date_before_birthday INTO l_end_date_before_age_change;
      CLOSE csr_end_date_before_birthday;

      OPEN csr_assgid_before_change(c_atp_assignments.assignment_action_id
                                   ,l_business_group_id,p_legal_employer
                                   ,c_atp_assignments.payroll_id
                                   ,l_start_date,l_end_date_before_age_change);
        FETCH csr_assgid_before_change INTO l_assgid_before_change;
      CLOSE csr_assgid_before_change;

      l_partial_atp_hours := pay_balance_pkg.get_value(
          p_defined_balance_id   => l_total_atp_hours_id,
          p_assignment_action_id => l_assgid_before_change,
          p_tax_unit_id          => p_legal_employer,
          p_jurisdiction_code    => NULL,
          p_source_id            => NULL,
          p_tax_group            => NULL,
          p_date_earned          => NULL);

      --If Age reached ATP LOW during the year.
      IF (l_age_on_start = (l_atp_employee_age_low -1) AND
          l_age_on_end = l_atp_employee_age_low) --9127531
       THEN
          l_total_atp_hours := l_total_atp_hours + NVL(l_partial_atp_hours,0); --9258608

      --If Age crossed ATP HIGH during the year.
      ELSIF (l_age_on_start = (l_atp_employee_age_high) AND
             l_age_on_end = l_atp_employee_age_high + 1) --9127531
       THEN
          l_full_atp_hours := pay_balance_pkg.get_value(
          p_defined_balance_id   => l_total_atp_hours_id,
          p_assignment_action_id => c_atp_assignments.assignment_action_id,
          p_tax_unit_id          => p_legal_employer,
          p_jurisdiction_code    => NULL,
          p_source_id            => NULL,
          p_tax_group            => NULL,
          p_date_earned          => NULL);

          l_total_atp_hours := l_total_atp_hours + (NVL(l_full_atp_hours,0)
	                       - NVL(l_partial_atp_hours,0)); --9258608
          l_full_atp_hours := 0;
      END IF;
      l_partial_atp_hours :=0;
    END IF;
--9059957--end
    l_employer_atp := 0;
    l_employee_atp := 0;

   END LOOP;

  FOR c_non_atp_assignments IN csr_non_atp_assignments(l_start_date,l_end_date,
                                l_business_group_id,p_legal_employer,p_payroll)
   LOOP
    l_worked_hours := pay_balance_pkg.get_value(
          p_defined_balance_id   => l_worked_hours_id,
          p_assignment_action_id => c_non_atp_assignments.assignment_action_id,
          p_tax_unit_id          => p_legal_employer,
          p_jurisdiction_code    => NULL,
          p_source_id            => NULL,
          p_tax_group            => NULL,
          p_date_earned          => NULL);

    l_non_atp_worked_hours := l_non_atp_worked_hours + NVL(l_worked_hours,0);
    l_worked_hours := 0;
   END LOOP;

  /* Computations*/
   l_atp_employee_count := 0 + round((l_total_atp/l_full_atp_contribution),0);
   l_atp_trainee_count :=  0 + round((l_trainee_total_atp/l_full_atp_contribution),0);
   l_non_atp_employee_count := 0 + round(((l_non_atp_worked_hours
                             + l_total_atp_hours)/l_normal_hours_per_year),0); --9059957
   l_total_employer_aer := l_atp_employee_count - l_atp_trainee_count;

      IF l_total_employer_aer < 0 OR NVL(l_total_atp,0) = 0 THEN
        l_total_aer := 0;
         hr_utility.set_message (801, 'PAY_377056_DK_NEGATIVE_ERR');
      ELSE
         l_total_aer := round((l_total_employer_aer * l_aer_rate),2);
      END IF;

  /* Final Values */
   l_value_0050 := l_atp_employee_count;
   l_value_0051 := l_atp_trainee_count;
   l_value_0052 := l_non_atp_employee_count;
   l_value_0120 := l_total_aer;

  /* Build XML Structure */
  l_string := l_string || '<PYDKALCR>'||EOL;
  l_string := l_string || '<LEGAL_EMPLOYER>'|| l_legal_employer_name ||'</LEGAL_EMPLOYER>'||EOL;
  l_string := l_string || '<PAYROLL>'|| l_payroll_name ||'</PAYROLL>'||EOL;
  l_string := l_string || '<YEAR>'|| p_year ||'</YEAR>'||EOL;
  l_string := l_string || '<VALUE0050>'|| l_value_0050 ||'</VALUE0050>'||EOL;
  l_string := l_string || '<VALUE0051>'|| l_value_0051 ||'</VALUE0051>'||EOL;
  l_string := l_string || '<VALUE0052>'|| l_value_0052 ||'</VALUE0052>'||EOL;
  l_string := l_string || '<VALUE0120>'|| l_value_0120 ||'</VALUE0120>'||EOL;
  l_string := l_string || '</PYDKALCR>';

  /* Writing XML File */
  dbms_lob.createtemporary(l_xml,FALSE,DBMS_LOB.CALL);
  dbms_lob.open(l_xml,dbms_lob.lob_readwrite);
  dbms_lob.writeAppend( l_xml, length(l_string), l_string);
  p_xml := l_xml;
  dbms_lob.freeTemporary(l_xml);

  IF g_debug THEN
    hr_utility.set_location(' Leaving Procedure GENERATE',2);
  END IF;

EXCEPTION
  WHEN others THEN
   IF g_debug THEN
     hr_utility.set_location('error raised in GENERATE ',9);
   END IF;
  RAISE;
END generate;

-------------------------------------------------------------------------------

END pay_dk_labor_cost_report;

/
