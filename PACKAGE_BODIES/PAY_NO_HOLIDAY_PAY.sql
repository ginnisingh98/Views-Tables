--------------------------------------------------------
--  DDL for Package Body PAY_NO_HOLIDAY_PAY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_NO_HOLIDAY_PAY" AS
  /* $Header: pynoholp.pkb 120.0.12010000.2 2010/03/28 11:15:56 vijranga ship $ */
  -- Function to get the G value.
  FUNCTION get_grate(p_business_group_id IN NUMBER,   p_effective_date IN DATE) RETURN NUMBER IS l_g_rate NUMBER;
  BEGIN
    -- Get the daily rate value
    BEGIN

      -- Bug Fix 5566622 : Value of G (National Insurance Base Rate) to be taken from Global and not user table.

      -- l_g_rate := to_number(hruserdt.get_table_value(p_business_group_id,   'NO_GLOBAL_CONSTANTS',   'Value',   'NATIONAL_INSURANCE_BASE_RATE',   p_effective_date));

     select to_number(GLOBAL_VALUE)
     into l_g_rate
     from ff_globals_f
     where global_name = 'NO_NATIONAL_INSURANCE_BASE_RATE'
     and LEGISLATION_CODE = 'NO'
     and BUSINESS_GROUP_ID IS NULL
     and p_effective_date between EFFECTIVE_START_DATE and EFFECTIVE_END_DATE ;


    EXCEPTION
    WHEN no_data_found THEN
      l_g_rate := NULL;
    END;

    RETURN l_g_rate;
  END get_grate;

  --Function to get the age of a person as on 31-AUG of the holiday year.
  FUNCTION get_age(p_payroll_proc_start_date IN DATE,   p_date_of_birth IN DATE) RETURN NUMBER IS l_age NUMBER;
  l_effective_date DATE;
  BEGIN
    --l_effective_date := to_date('31/08/' || to_char(p_payroll_proc_start_date,   'YYYY'),   'DD/MM/YYYY');
    l_effective_date := to_date('31/12/' || to_char(p_payroll_proc_start_date,   'YYYY'),   'DD/MM/YYYY'); -- Bug#9529805 fix
    l_age := FLOOR(months_between(l_effective_date,   p_date_of_birth) / 12);
    RETURN l_age;
  END get_age;

  /* Function to whether the payroll run is the last payroll run of the year in order
 recalulate the holiday pay over 60*/ FUNCTION get_last_payroll(p_payroll_id IN NUMBER,   p_pay_proc_period_end_date IN DATE) RETURN VARCHAR2 IS l_next_period_start_date DATE;
  l_next_period_end_date DATE;
  l_flag VARCHAR2(1);

  CURSOR csr_next_pay_proc_end_date(p_start_date DATE) IS
  SELECT end_date
  FROM per_time_periods ptp
  WHERE ptp.payroll_id = p_payroll_id
   AND ptp.start_date = p_start_date;

  BEGIN
    l_next_period_start_date := p_pay_proc_period_end_date + 1;

    OPEN csr_next_pay_proc_end_date(l_next_period_start_date);
    FETCH csr_next_pay_proc_end_date
    INTO l_next_period_end_date;
    CLOSE csr_next_pay_proc_end_date;

    IF(to_char(p_pay_proc_period_end_date,   'YYYY') <> to_char(l_next_period_start_date,   'YYYY')) THEN
      l_flag := 'Y';
      RETURN l_flag;
      ELSIF(to_char(l_next_period_start_date,   'YYYY') <> to_char(l_next_period_end_date,   'YYYY')) THEN
        l_flag := 'Y';
        RETURN l_flag;
      ELSE
        l_flag := 'N';
        RETURN l_flag;
      END IF;

    END;

    -- Function to get the assignments status.
    FUNCTION get_assg_status(p_business_group_id IN NUMBER,   p_asg_id IN NUMBER,   p_pay_proc_period_start_date IN DATE,   p_pay_proc_period_end_date IN DATE) RETURN VARCHAR2 IS

     CURSOR csr_asg IS
    SELECT MIN(paaf.effective_start_date) effective_start_date
    FROM per_all_assignments_f paaf
    WHERE paaf.business_group_id = p_business_group_id
     AND paaf.assignment_id = p_asg_id
     AND paaf.assignment_status_type_id = 3;

    l_flag VARCHAR2(1);
    l_asg_status csr_asg % rowtype;

    BEGIN

      OPEN csr_asg;
      FETCH csr_asg
      INTO l_asg_status;
      CLOSE csr_asg;

      IF l_asg_status.effective_start_date >= p_pay_proc_period_start_date
       AND l_asg_status.effective_start_date <=(p_pay_proc_period_end_date + 1) THEN
        l_flag := 'T';
      ELSE
        l_flag := 'A';
      END IF;

      RETURN l_flag;

    END get_assg_status;

    -- Function to get the entitlement days as years last payroll run end date.
    FUNCTION get_entitlement_days(p_business_group_id IN NUMBER,   p_asg_id IN NUMBER,   p_tax_unit_id IN NUMBER,   p_effective_date IN DATE,   p_above_60 IN VARCHAR2,   p_entit_days OUT nocopy NUMBER,
             p_entit_days_over_60 OUT nocopy NUMBER) RETURN NUMBER IS CURSOR csr_assig_details IS
    SELECT hsck.segment15 holiday_entitlement,
      hsck.segment16 holiday_pay_calc_basis
    FROM per_all_assignments_f paaf,
      hr_soft_coding_keyflex hsck
    WHERE paaf.business_group_id = p_business_group_id
     AND paaf.assignment_id = p_asg_id
     AND p_effective_date BETWEEN paaf.effective_start_date
     AND paaf.effective_end_date
     AND hsck.soft_coding_keyflex_id = paaf.soft_coding_keyflex_id;

    CURSOR csr_person_details IS
    SELECT papf.per_information16 holiday_entitlement,
      papf.per_information17 holiday_pay_calc_basis
    FROM per_all_people_f papf,
      per_all_assignments_f paaf
    WHERE paaf.business_group_id = p_business_group_id
     AND paaf.assignment_id = p_asg_id
     AND papf.person_id = paaf.person_id
     AND p_effective_date BETWEEN papf.effective_start_date
     AND papf.effective_end_date;

    --Added Cursor to get the legal employer details
    CURSOR csr_le_details IS
    SELECT hoi.org_information1 holiday_entitlement,
      hoi.org_information2 holiday_pay_calc_basis
    FROM hr_organization_information hoi
    WHERE hoi.organization_id = p_tax_unit_id
     AND hoi.org_information_context = 'NO_HOLIDAY_PAY_DETAILS';

    CURSOR csr_globals(p_global_name VARCHAR2) IS
    SELECT fgf.global_value
    FROM ff_globals_f fgf
    WHERE fgf.global_name = p_global_name
     AND fgf.legislation_code = 'NO'
     AND p_effective_date BETWEEN fgf.effective_start_date
     AND fgf.effective_end_date;

    l_holiday_entitlement VARCHAR2(150);
    l_holiday_pay_calc_basis VARCHAR2(150);
    l_entit_days NUMBER;
    l_entit_days_over_60 NUMBER;
    l_assig_details csr_assig_details % rowtype;
    l_person_details csr_person_details % rowtype;
    l_le_details csr_le_details % rowtype;
    l_global_name ff_globals_f.global_name%TYPE;
    BEGIN

      /*Bug 5346834 fix*/

      OPEN csr_assig_details;
      FETCH csr_assig_details
      INTO l_assig_details;
      CLOSE csr_assig_details;

      OPEN csr_person_details;
      FETCH csr_person_details
      INTO l_person_details;
      CLOSE csr_person_details;

      OPEN csr_le_details;
      FETCH csr_le_details
      INTO l_le_details;
      CLOSE csr_le_details;

      IF(l_assig_details.holiday_entitlement IS NOT NULL) THEN
        l_holiday_entitlement := l_assig_details.holiday_entitlement;
        ELSIF(l_person_details.holiday_entitlement IS NOT NULL) THEN
          l_holiday_entitlement := l_person_details.holiday_entitlement;
          ELSIF(l_person_details.holiday_entitlement IS NOT NULL) THEN
            l_holiday_entitlement := l_person_details.holiday_entitlement;
            ELSIF(l_le_details.holiday_entitlement IS NOT NULL) THEN
              l_holiday_entitlement := l_le_details.holiday_entitlement;
            ELSE
              l_holiday_entitlement := 'HA';
            END IF;

            IF(l_assig_details.holiday_pay_calc_basis IS NOT NULL) THEN
              l_holiday_pay_calc_basis := l_assig_details.holiday_pay_calc_basis;
              ELSIF(l_person_details.holiday_pay_calc_basis IS NOT NULL) THEN
                l_holiday_pay_calc_basis := l_person_details.holiday_pay_calc_basis;
                ELSIF(l_le_details.holiday_pay_calc_basis IS NOT NULL) THEN
                  l_holiday_pay_calc_basis := l_le_details.holiday_pay_calc_basis;
                ELSE
                  l_holiday_pay_calc_basis := '5DAY';
                END IF;

                IF(l_holiday_entitlement = 'HA'
                 AND l_holiday_pay_calc_basis = '5DAY') THEN
                  l_global_name := 'NO_HOLACT_5DAY_ENTITLMENT';

                  ELSIF(l_holiday_entitlement = 'HA'
                   AND l_holiday_pay_calc_basis = '6DAY') THEN
                    l_global_name := 'NO_HOLACT_6DAY_ENTITLMENT';
                    ELSIF(l_holiday_entitlement = 'CA'
                     AND l_holiday_pay_calc_basis = '5DAY') THEN
                      l_global_name := 'NO_COLAGR_5DAY_ENTITLMENT';
                      ELSIF(l_holiday_entitlement = 'CA'
                       AND l_holiday_pay_calc_basis = '6DAY') THEN
                        l_global_name := 'NO_COLAGR_6DAY_ENTITLMENT';
                      END IF;

                      OPEN csr_globals(l_global_name);
                      FETCH csr_globals
                      INTO p_entit_days;
                      CLOSE csr_globals;

                      IF p_above_60 = 'Y' THEN

                        IF(l_holiday_pay_calc_basis = '5DAY') THEN
	                  l_global_name := 'NO_HOL_5DAY_OVER60_ENTITLEMENT';
                        ELSE
			  l_global_name := 'NO_HOL_6DAY_OVER60_ENTITLEMENT';
                        END IF;
			  OPEN csr_globals(l_global_name);
			  FETCH csr_globals
			  INTO p_entit_days_over_60;
			  CLOSE csr_globals;

                      ELSE
                        p_entit_days_over_60 := 0;
                      END IF;

                      RETURN 1;
                    END get_entitlement_days;

    -- Function to get the fixed period for a payroll.
    FUNCTION get_fixed_period(p_payroll_id IN NUMBER,   p_start_date IN DATE) RETURN NUMBER IS l_fixed_period NUMBER;

    CURSOR csr_fixed_period IS
    SELECT period_num
    FROM per_time_periods
    WHERE payroll_id = p_payroll_id
     AND to_char(start_date,   'YYYY') = to_char(p_start_date,   'YYYY')
     AND prd_information2 = 'Y';
    BEGIN

      OPEN csr_fixed_period;
      FETCH csr_fixed_period
      INTO l_fixed_period;
      CLOSE csr_fixed_period;

      RETURN l_fixed_period;

    END get_fixed_period;

    -- Function to get the previous employer details.
    FUNCTION get_prev_employer_days(p_business_group_id IN NUMBER,   p_assg_id IN NUMBER,   p_emp_hire_date IN DATE,   p_asg_start_date IN DATE) RETURN NUMBER IS

     l_person_id per_all_people_f.person_id%TYPE;

    CURSOR csr_person_id IS
    SELECT paaf.person_id
    FROM per_all_assignments_f paaf
    WHERE paaf.business_group_id = p_business_group_id
     AND paaf.assignment_id = p_assg_id;
    /*Bug 5344736 fix - getting the previous employer days */
    /* Bug 5344736 fix - added condition to check the assignment start year*/
    CURSOR csr_prev_employer_days(p_person_id NUMBER) IS
    SELECT SUM(to_number(ppe.pem_information2))
    FROM per_previous_employers ppe
    WHERE ppe.business_group_id = p_business_group_id
     AND ppe.person_id = p_person_id
     AND to_char(ppe.end_date,   'YYYY') = to_char(p_emp_hire_date,   'YYYY')
     AND to_char(ppe.end_date,   'YYYY') = to_char(p_asg_start_date,   'YYYY');

    l_prev_employer_days per_previous_employers.pem_information2%TYPE;
    BEGIN

      OPEN csr_person_id;
      FETCH csr_person_id
      INTO l_person_id;
      CLOSE csr_person_id;

      OPEN csr_prev_employer_days(l_person_id);
      FETCH csr_prev_employer_days
      INTO l_prev_employer_days;
      CLOSE csr_prev_employer_days;
      RETURN nvl(l_prev_employer_days,   0);
    END get_prev_employer_days;

-- Function to get the holiday details required for hoiliday pay calculation.
FUNCTION get_hol_parameters(p_bus_group_id IN NUMBER,   p_assignment_id IN NUMBER,   p_date_earned IN DATE,   p_tax_unit_id IN NUMBER,   p_hourly_salaried_code IN OUT nocopy VARCHAR2,
	     p_holiday_entitlement IN OUT nocopy VARCHAR2,   p_holiday_pay_calc_basis IN OUT nocopy VARCHAR2,   p_holiday_pay_in_fixed_period IN OUT nocopy VARCHAR2,
	     p_hol_pay_over60_in_fix_period IN OUT nocopy VARCHAR2,   p_holiday_pay_to_be_adjusted IN OUT nocopy VARCHAR2,   p_res_hol_pay_to_6g_for_over60 IN OUT nocopy VARCHAR2) RETURN NUMBER IS

     CURSOR csr_assg_details IS
    SELECT paaf.hourly_salaried_code hourly_salaried_code,
      hsck.segment15 holiday_entitlement,
      hsck.segment16 holiday_pay_calc_basis,
      hsck.segment17 holiday_pay_in_fixed_period,
      hsck.segment18 hol_pay_over60_in_fix_period,
      hsck.segment19 holiday_pay_to_be_adjusted
    FROM per_all_assignments_f paaf,
      hr_soft_coding_keyflex hsck
    WHERE paaf.business_group_id = p_bus_group_id
     AND paaf.assignment_id = p_assignment_id
     AND p_date_earned BETWEEN paaf.effective_start_date
     AND paaf.effective_end_date
     AND hsck.soft_coding_keyflex_id = paaf.soft_coding_keyflex_id;

    CURSOR csr_person_details IS
    SELECT papf.per_information6 hourly_salaried_code,
      papf.per_information16 holiday_entitlement,
      papf.per_information17 holiday_pay_calc_basis,
      papf.per_information18 holiday_pay_in_fixed_period,
      papf.per_information19 hol_pay_over60_in_fix_period,
      papf.per_information20 holiday_pay_to_be_adjusted,
      papf.per_information21 res_hol_pay_to_6g_for_over60
    FROM per_all_people_f papf,
      per_all_assignments_f paaf
    WHERE paaf.business_group_id = p_bus_group_id
     AND paaf.assignment_id = p_assignment_id
     AND papf.person_id = paaf.person_id
     AND p_date_earned BETWEEN papf.effective_start_date
     AND papf.effective_end_date;

    --Added Cursor to get the legal employer details
    CURSOR csr_le_details IS
    SELECT hoi.org_information1 holiday_entitlement,
      hoi.org_information2 holiday_pay_calc_basis,
      hoi.org_information3 holiday_pay_in_fixed_period,
      hoi.org_information4 hol_pay_over60_in_fix_period,
      hoi.org_information5 holiday_pay_to_be_adjusted,
      hoi.org_information6 res_hol_pay_to_6g_for_over60
    FROM hr_organization_information hoi
    WHERE hoi.organization_id = p_tax_unit_id
     AND hoi.org_information_context = 'NO_HOLIDAY_PAY_DETAILS';

    CURSOR csr_le_hourly_sal IS
    SELECT hoi.org_information5 hourly_salaried_code
    FROM hr_organization_information hoi
    WHERE hoi.organization_id = p_tax_unit_id
     AND hoi.org_information_context = 'NO_ABSENCE_PAYMENT_DETAILS';

    l_person_details csr_person_details % rowtype;
    l_le_details csr_le_details % rowtype;
    l_le_hourly_sal csr_le_hourly_sal % rowtype;

    BEGIN

      OPEN csr_assg_details;
      FETCH csr_assg_details
      INTO p_hourly_salaried_code,
	p_holiday_entitlement,
	p_holiday_pay_calc_basis,
	p_holiday_pay_in_fixed_period,
	p_hol_pay_over60_in_fix_period,
	p_holiday_pay_to_be_adjusted;
      CLOSE csr_assg_details;

      OPEN csr_person_details;
      FETCH csr_person_details
      INTO l_person_details;
      CLOSE csr_person_details;

      OPEN csr_le_details;
      FETCH csr_le_details
      INTO l_le_details;
      CLOSE csr_le_details;

      OPEN csr_le_hourly_sal;
      FETCH csr_le_hourly_sal
      INTO l_le_hourly_sal;
      CLOSE csr_le_hourly_sal;

      IF(p_hourly_salaried_code IS NULL) THEN

	IF(l_person_details.hourly_salaried_code IS NOT NULL) THEN
	  p_hourly_salaried_code := l_person_details.hourly_salaried_code;
	  ELSIF(l_le_hourly_sal.hourly_salaried_code IS NOT NULL) THEN
	    p_hourly_salaried_code := l_le_hourly_sal.hourly_salaried_code;
	  ELSE
	    p_hourly_salaried_code := 'S';
	  END IF;

	END IF;

	IF p_holiday_entitlement IS NULL THEN

	  IF(l_person_details.holiday_entitlement IS NOT NULL) THEN
	    p_holiday_entitlement := l_person_details.holiday_entitlement;
	    ELSIF(l_le_details.holiday_entitlement IS NOT NULL) THEN
	      p_holiday_entitlement := l_le_details.holiday_entitlement;
	    ELSE
	      p_holiday_entitlement := 'HA';
	    END IF;

	  END IF;

	  IF p_holiday_pay_calc_basis IS NULL THEN

	    IF(l_person_details.holiday_pay_calc_basis IS NOT NULL) THEN
	      p_holiday_pay_calc_basis := l_person_details.holiday_pay_calc_basis;
	      ELSIF(l_le_details.holiday_pay_calc_basis IS NOT NULL) THEN
		p_holiday_pay_calc_basis := l_le_details.holiday_pay_calc_basis;
	      ELSE
		p_holiday_pay_calc_basis := '5DAY';
	      END IF;

	    END IF;

	    IF p_holiday_pay_in_fixed_period IS NULL THEN

	      IF(l_person_details.holiday_pay_in_fixed_period IS NOT NULL) THEN
		p_holiday_pay_in_fixed_period := l_person_details.holiday_pay_in_fixed_period;
		p_hol_pay_over60_in_fix_period := l_person_details.hol_pay_over60_in_fix_period;
		p_holiday_pay_to_be_adjusted := l_person_details.holiday_pay_to_be_adjusted;
		ELSIF(l_le_details.holiday_pay_in_fixed_period IS NOT NULL) THEN
		  p_holiday_pay_in_fixed_period := l_le_details.holiday_pay_in_fixed_period;
		  p_hol_pay_over60_in_fix_period := l_le_details.hol_pay_over60_in_fix_period;
		  p_holiday_pay_to_be_adjusted := l_le_details.holiday_pay_to_be_adjusted;

		ELSE
		  p_holiday_pay_in_fixed_period := 'N';
		  p_hol_pay_over60_in_fix_period := 'N';
		  p_holiday_pay_to_be_adjusted := 'N';
		END IF;

	      END IF;

	      IF(l_person_details.res_hol_pay_to_6g_for_over60 IS NOT NULL) THEN
		p_res_hol_pay_to_6g_for_over60 := l_person_details.res_hol_pay_to_6g_for_over60;
		ELSIF(l_le_details.res_hol_pay_to_6g_for_over60 IS NOT NULL) THEN
		  p_res_hol_pay_to_6g_for_over60 := l_le_details.res_hol_pay_to_6g_for_over60;
		ELSE
		  p_res_hol_pay_to_6g_for_over60 := 'Y';
		END IF;

		RETURN 1;
	      END get_hol_parameters;

      -- Function to get the assignment start date.

      /*Bug 5334894 fix- Added a new function to get the assignment start date*/
 FUNCTION get_asg_start_date(p_business_group_id IN NUMBER,   p_assignment_id IN NUMBER,   p_asg_start_date OUT nocopy DATE) RETURN NUMBER IS CURSOR csr_asg_start_date IS
      SELECT MIN(paaf.effective_start_date)
      FROM per_all_assignments_f paaf
      WHERE paaf.business_group_id = p_business_group_id
       AND paaf.assignment_id = p_assignment_id
       AND paaf.assignment_status_type_id = 1;

      BEGIN

	OPEN csr_asg_start_date;
	FETCH csr_asg_start_date
	INTO p_asg_start_date;
	CLOSE csr_asg_start_date;
	RETURN 1;
      END get_asg_start_date;

--Function to get the accrual act information from absence details
 FUNCTION get_abs_hol_accr_entitl (p_bus_group_id IN NUMBER,   p_assignment_id IN NUMBER,   p_date_earned IN DATE,   p_tax_unit_id IN NUMBER
                                     , p_hol_accrual_entit OUT nocopy VARCHAR2) RETURN NUMBER IS

	    CURSOR csr_person_details IS
	    SELECT
	      papf.per_information13 hol_accrual_entit
	    FROM per_all_people_f papf,
	      per_all_assignments_f paaf
	    WHERE paaf.business_group_id = p_bus_group_id
	     AND paaf.assignment_id = p_assignment_id
	     AND papf.person_id = paaf.person_id
	     AND p_date_earned BETWEEN papf.effective_start_date
	     AND papf.effective_end_date;

	    --Added Cursor to get the legal employer details
	    CURSOR csr_le_details IS
	    SELECT hoi.org_information9 hol_accrual_entit
	    FROM hr_organization_information hoi
	    WHERE hoi.organization_id = p_tax_unit_id
	     AND hoi.org_information_context = 'NO_ABSENCE_PAYMENT_DETAILS';

	    l_person_details csr_person_details % rowtype;
	    l_le_details csr_le_details % rowtype;

	    BEGIN


	      OPEN csr_person_details;
	      FETCH csr_person_details
	      INTO l_person_details;
	      CLOSE csr_person_details;

	      OPEN csr_le_details;
	      FETCH csr_le_details
	      INTO l_le_details;
	      CLOSE csr_le_details;

	     p_hol_accrual_entit := NVL(NVL(l_person_details.hol_accrual_entit,l_le_details.hol_accrual_entit),'HA');

	     RETURN 1;

	    EXCEPTION WHEN OTHERS THEN
	    RETURN 0 ;

	END get_abs_hol_accr_entitl;

END;

/
