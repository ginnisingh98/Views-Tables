--------------------------------------------------------
--  DDL for Package Body PAY_DK_SICKNESS_DP201
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_DK_SICKNESS_DP201" AS
/* $Header: pydkdp201.pkb 120.9.12000000.2 2007/05/08 07:01:23 saurai noship $ */
	g_debug   boolean   :=  hr_utility.debug_enabled;
	g_err_num		NUMBER;

-------------------------------------------------------------------------------------------------------

/*Function to get the defined balance id */
FUNCTION GET_DEFINED_BALANCE_ID
	(p_balance_name   		IN  VARCHAR2
	,p_dbi_suffix     		IN  VARCHAR2
	,p_business_group_id		IN NUMBER)
	RETURN NUMBER IS

l_defined_balance_id 		NUMBER;

BEGIN

SELECT
	pdb.defined_balance_id
INTO
	l_defined_balance_id
FROM
	pay_defined_balances      pdb
	,pay_balance_types         pbt
	,pay_balance_dimensions    pbd
WHERE
	pbd.database_item_suffix = p_dbi_suffix
	AND    (pbd.legislation_code = 'DK' OR pbt.business_group_id = p_business_group_id)
	AND    pbt.balance_name = p_balance_name
	AND    (pbt.legislation_code = 'DK' OR pbt.business_group_id = p_business_group_id)
	AND    pdb.balance_type_id = pbt.balance_type_id
	AND    pdb.balance_dimension_id = pbd.balance_dimension_id
	AND    (pdb.legislation_code = 'DK' OR pbt.business_group_id = p_business_group_id);

l_defined_balance_id := NVL(l_defined_balance_id,0);

RETURN l_defined_balance_id ;
END GET_DEFINED_BALANCE_ID;
---------------------------------------------------------------------------------------------------

/*Procedure which returns the last pay (after pre-Paymnents) of an assignment*/
PROCEDURE LAST_PAY
	( p_business_group_id IN NUMBER
	,p_assignment_id IN NUMBER
	,p_effective_date IN DATE
	,p_pay OUT NOCOPY VARCHAR2
	)
		   IS

CURSOR csr_asg_act_id IS
SELECT
*
FROM
(
SELECT
	paa1.assignment_action_id
FROM
	pay_assignment_actions paa1
	,pay_payroll_actions ppa1
	,pay_assignment_actions paa2
	,pay_payroll_actions ppa2
	,pay_action_interlocks  pai
	,pay_payrolls_f ppf
WHERE
	paa1.assignment_id = p_assignment_id
	AND paa1.action_status = 'C'
	AND paa1.payroll_action_id = ppa1.payroll_action_id
	AND ppa1.action_type IN ('R','Q')  -- Payroll Run or Quickpay Run
	AND ppa1.date_earned <= p_effective_date

	--for prepayments
	AND    paa2.action_status           = 'C' -- Completed
	AND    paa2.assignment_action_id    = pai.locking_action_id
	AND    paa2.payroll_action_id       = ppa2.payroll_action_id
	AND    ppa2.action_type            IN ('P','U')
	AND    ppa2.date_earned <= p_effective_date

	AND paa1.ASSIGNMENT_ACTION_ID = pai.locked_action_id

	AND ppf.payroll_id = ppa1.payroll_id
	ORDER BY ppa1.date_earned desc)
WHERE
	ROWNUM=1;

/*Cursor to fetch the balance values- Sum of balance values belonging to salary reporting category minus
Employee AMB Deduction balance value*/

CURSOR csr_pay(asg_act_id NUMBER ) IS
SELECT
	SUM (pay_balance_pkg.get_value(
	     get_defined_balance_id(pbt.balance_name,'_ASG_PTD',p_business_group_id)
		,asg_act_id)) - pay_balance_pkg.get_value(
	     get_defined_balance_id('Employee AMB Deduction','_ASG_PTD',p_business_group_id)
		,asg_act_id) pay_value
FROM
	pay_balance_types pbt
	,pay_balance_categories_f pbcf
WHERE
	pbcf.legislation_code = 'DK'
	AND pbcf.category_name = 'Salary Reporting'
	AND pbcf.balance_category_id = pbt.balance_category_id;

l_asg_act_id number;

BEGIN

OPEN csr_asg_act_id;
FETCH csr_asg_act_id INTO l_asg_act_id;
CLOSE csr_asg_act_id;

OPEN csr_pay(l_asg_act_id);
FETCH csr_pay INTO p_pay;
CLOSE csr_pay;

END LAST_PAY;
-------------------------------------------------------------------------------------------------------------------------
/*Function to return the working hours per week of an assignment*/
FUNCTION WORKING_HOURS_PER_WEEK
		(p_assignment_id IN NUMBER
		,p_leg_emp_id IN NUMBER
		,p_effective_date IN DATE)
		 RETURN NUMBER IS

l_hours per_all_assignments_f.normal_hours%TYPE;
l_freq per_all_assignments_f.frequency%TYPE;
l_default_work_pattern VARCHAR2(30);
l_work_days_week NUMBER ;
l_value NUMBER ;

CURSOR csr_asg_freq_hours IS
SELECT
	paaf.frequency
	,paaf.normal_hours
	,hsck.segment10 default_work_pattern
 FROM
	 per_all_assignments_f paaf
	,hr_soft_coding_keyflex hsck
WHERE
	paaf.assignment_id = p_assignment_id
	AND paaf.assignment_status_type_id = 1
	AND p_effective_date BETWEEN paaf.effective_start_date AND paaf.effective_end_date
	AND hsck.soft_coding_keyflex_id = paaf.soft_coding_keyflex_id;


CURSOR csr_le_freq_hours IS
SELECT
	hoi1.org_information4
	,hoi1.org_information3
	,hoi2.org_information1
FROM
	hr_organization_information hoi1
	,hr_organization_information hoi2
WHERE
	hoi1.organization_id = p_leg_emp_id
	AND hoi2.organization_id = hoi1.organization_id
	AND hoi1.org_information_context =  'DK_EMPLOYMENT_DEFAULTS'
	AND hoi2.org_information_context(+) =  'DK_HOLIDAY_ENTITLEMENT_INFO';

BEGIN
l_work_days_week := 5; -- By default the work pattern will be 5 days

/*To fetch the assignment hours*/
OPEN csr_asg_freq_hours;
FETCH csr_asg_freq_hours INTO l_freq,l_hours,l_default_work_pattern;
CLOSE csr_asg_freq_hours;

/* If assignment hours not present then to take the hours from the legal employer EIT 'Work hours'*/
IF l_hours IS NULL THEN
open csr_le_freq_hours;
FETCH csr_le_freq_hours INTO l_freq,l_hours,l_default_work_pattern;
CLOSE csr_le_freq_hours;
END IF ;

IF (l_default_work_pattern = '5DAY') THEN
l_work_days_week := 5;
ELSIF  (l_default_work_pattern = '6DAY') THEN
l_work_days_week := 6;
END IF ;

IF (l_freq = 'D') THEN
l_value := ROUND (l_hours * l_work_days_week,2);
ELSIF (l_freq = 'W') THEN
l_value := l_hours;
ELSIF (l_freq = 'M') THEN
l_value := ROUND (l_hours * (l_work_days_week/22),2);
ELSIF (l_freq = 'Y') THEN
l_value := ROUND (l_hours * (l_work_days_week/260),2);
END IF;

RETURN l_value;

END WORKING_HOURS_PER_WEEK;


----------------------------------------------------------------------------------
/*Procudure to get the sick leave details for reporting*/
/*Bug 5059274 fix- Added p_start_date and p_end_Date parameters*/
PROCEDURE POPULATE_DETAILS
	(p_template_name in VARCHAR2
	,p_assignment_id NUMBER DEFAULT NULL
	,p_person_id NUMBER
	,p_start_date IN VARCHAR2
	,p_end_date IN VARCHAR2
	,p_le_phone_number IN VARCHAR2
	,p_le_email_addr IN varchar2
	,p_business_group_id NUMBER
	, p_xml out nocopy clob) IS

/*Parameters to store the start and end dates, in order to provide date validation the parameters
  are accepeted as varchar2 and converted into date type*/
l_start_date DATE;
l_end_date DATE;

--Cursor to fetch employee details
CURSOR csr_emp(p_effective_date DATE) IS
SELECT
/*	papf.first_name first_name
	,papf.middle_names middle_name
	,papf.last_name last_name*/
	/*Bug 5049222 fix- Employee name formatting*/
	--SUBSTR (papf.first_name,1,40)||NVL2(papf.middle_names,','||SUBSTR(papf.middle_names,1,40),NULL)||','||SUBSTR(papf.last_name,1,40) ename
	/*Reopened Bug 5049222 fix*/
     SUBSTR (papf.last_name,1,40)||', '||SUBSTR(papf.first_name,1,40)||NVL2(papf.middle_names,' '||SUBSTR(papf.middle_names,1,40),NULL) ename
	,papf.national_identifier national_identifier
	,papf.start_date person_start_date
	,pa.address_line1 address_line1
	,pa.address_line2 address_line2
	,pa.postal_code postal_code
FROM
	per_all_people_f papf
	,per_addresses   pa
WHERE
	papf.person_id = p_person_id
	AND p_effective_date between papf.effective_start_date and papf.effective_end_date
	AND papf.current_employee_flag = 'Y'
	AND pa.person_id(+) = papf.person_id
	AND pa.primary_flag(+) = 'Y'
	AND p_effective_date BETWEEN pa.date_from(+) AND nvl(pa.date_to(+),TO_DATE('31/12/4712','DD/MM/YYYY'));

/*Bug fix- 5059274 cursor to get the assignment details based on p_start_date and p_end_date*/
CURSOR csr_asg IS
SELECT
	paaf.person_id person_id
	,paaf.assignment_id asg_id
	,paaf.assignment_number asg_num
	,pj.name job_title
	,MIN(paaf.effective_start_date) asg_start_date
	,MAX(paaf.effective_end_date) asg_end_date
	,peef.effective_start_date absence_start_date
	,peef.effective_end_date absence_end_date
	,peevf.screen_entry_value absence_reason
	,paaf.payroll_id payroll_id
	,ppf.period_type period_type
FROM
	per_all_assignments_f  paaf
	,pay_element_entries_f peef
	,pay_element_types_f petf
	,per_jobs pj
	,pay_element_entry_values_f peevf
	,pay_input_values_f pivf
	,pay_payrolls_f ppf
WHERE
    paaf.person_id = p_person_id
	AND paaf.assignment_id = NVL(p_assignment_id,paaf.assignment_id)
	AND paaf.assignment_status_type_id = 1
	AND petf.element_name LIKE 'Absent Sick' -- To check for the Sickness element
	AND petf.legislation_code ='DK'
    AND peef.element_type_id = petf.element_type_id
    AND peef.assignment_id = paaf.assignment_id

    AND peef.effective_start_date BETWEEN l_start_date and l_end_date

	AND pivf.element_type_id = peef.element_type_id
	AND pivf.NAME = 'Absent Reason'
	AND peevf.element_entry_id= peef.element_entry_id
	AND peevf.input_value_id = pivf.input_value_id
	AND pj.job_id(+) = paaf.job_id
	AND ppf.payroll_id(+) = paaf.payroll_id
	GROUP BY paaf.person_id
	,paaf.assignment_id
	,paaf.assignment_number
	,pj.name
	,peef.effective_start_date
	,peef.effective_end_date
	,peevf.screen_entry_value
	,paaf.payroll_id
    ,ppf.period_type;

/*Cursor to pick up the legal employer details*/
CURSOR csr_le(p_le_id NUMBER) IS
SELECT
--	haou.organization_id le_id
	 SUBSTR(haou.NAME,1,30) le_name
	,substr(hl.address_line_1,1,30) le_address1
	,decode(hl.postal_code,NULL,' ',','||substr(hl.postal_code,1,5)) le_postalcode
	,substr(p_le_phone_number,1,30) le_phone
	,substr(p_le_email_addr,1,30) le_email
FROM
--	per_all_assignments_f paaf
--	,hr_soft_coding_keyflex hsck
	hr_all_organization_units haou
	,hr_locations hl
WHERE
--	paaf.assignment_id = p_assignment_id
--	AND l_run_date BETWEEN paaf.effective_start_date AND paaf.effective_end_date
--	AND paaf.assignment_status_type_id = 1
--	AND hsck.soft_coding_keyflex_id = paaf.soft_coding_keyflex_id
	haou.organization_id = p_le_id
	AND hl.location_id(+) = haou.location_id;

/*Bug 5049222 fix- Cursor to get the cvr number*/
CURSOR csr_le_cvr(p_le_id NUMBER) IS
SELECT
hoi.org_information1 le_cvr_num
FROM
hr_organization_information hoi
WHERE
hoi.organization_id = p_le_id
AND hoi.org_information_context = 'DK_LEGAL_ENTITY_DETAILS';

/*Bug fix- 5059274 cursor to get the payroll period start date in which the
absence start date falls*/
CURSOR csr_payroll_start_date(p_payroll_id NUMBER,p_absence_start_date DATE)
IS
SELECT
    ptp.start_date
FROM
    per_time_periods ptp
WHERE
    ptp.payroll_id = p_payroll_id
    AND p_absence_start_date BETWEEN ptp.start_date AND ptp.end_Date;

/*Bug fix- 5059274 cursor to get the soft coded details based on the payroll period start date*/
CURSOR csr_soft_coded_details(p_assignment_id IN NUMBER,p_effective_date DATE) IS
SELECT
    NVL(hsck.segment18,'N') section28
   	,hsck.segment4 employee_group
	,hsck.segment1 le_id
	,hsck.segment10 asg_work_pattern
FROM
	per_all_assignments_f paaf
	,hr_soft_coding_keyflex hsck
WHERE
	paaf.assignment_id = p_assignment_id
	AND p_effective_date BETWEEN paaf.effective_start_date AND paaf.effective_end_date
	AND hsck.soft_coding_keyflex_id = paaf.soft_coding_keyflex_id;

/*Bug fix- 5059274 cursor to get the section 27 details based on the payroll period start date*/
CURSOR csr_section27(p_effective_date DATE, p_le_id NUMBER) IS
SELECT
    hoi.org_information1
FROM
    hr_organization_information hoi
WHERE
    hoi.organization_id = p_le_id
    AND hoi.org_information_context = 'DK_SICKPAY_DEFAULTS'
    AND p_effective_date BETWEEN fnd_date.canonical_to_date(hoi.org_information2) and fnd_date.canonical_to_date(hoi.org_information3)
ORDER  BY hoi.org_information2;

CURSOR csr_le_work_pattern(p_org_id NUMBER) is
SELECT
    org_information1 le_work_pattern
FROM
    hr_organization_information
WHERE
    organization_id = p_org_id
    AND org_information_context = 'DK_HOLIDAY_ENTITLEMENT_INFO';

  /* Bug 5045710 fix- cursor to get the global values*/
CURSOR csr_get_global_values(p_global_name VARCHAR2,p_effective_date DATE ) IS
 SELECT
       fgf.global_value
 FROM
       ff_globals_f fgf
 WHERE
 fgf.legislation_code = 'DK'
 AND fgf.GLOBAL_NAME = p_global_name
 AND p_effective_date BETWEEN fgf.effective_start_date AND fgf.effective_end_date;

-- Variable declaration
l_var_work_hrs NUMBER ;
l_8weeks_work_hrs NUMBER ;
emp_rec csr_emp%ROWTYPE ;
asg_rec csr_asg%ROWTYPE ;
le_rec csr_le%ROWTYPE ;
xml_ctr  number;
l_pay VARCHAR2(150);
--l_period_type pay_payrolls_f.period_type%TYPE;
l_check VARCHAR2(1);
le_cvr_rec csr_le_cvr%ROWTYPE; --Bug 5049222 fix
l_absence_days NUMBER ;
l_section27 hr_organization_information.org_information1%TYPE;
--l_section28 VARCHAR2(10) ;
soft_coded_rec csr_soft_coded_details%ROWTYPE;
l_payroll_proc_start_date DATE ;
l_74hrs VARCHAR2(150);
l_worked_hours NUMBER ;
l_worked_days NUMBER ;


l_dk_max_sick_days_allowed NUMBER ;
l_dk_5day_pattern_min_days NUMBER ;
l_dk_6day_pattern_min_days NUMBER ;
l_dk_sickpay_min_work_hours NUMBER ;
le_work_pattern_rec csr_le_work_pattern%ROWTYPE ;
l_work_pattern VARCHAR2(150);


BEGIN
l_check := 'X';
xml_ctr := 0;
l_work_pattern := '5DAY'; -- By default work pattern is 5 days
l_start_date :=FND_DATE.CANONICAL_TO_DATE(p_start_date);
l_end_date   :=FND_DATE.CANONICAL_TO_DATE(p_end_date);


FOR asg_rec IN csr_asg LOOP
l_absence_days := NVL(asg_rec.absence_end_date,l_end_date) - asg_rec.absence_start_date+1;

OPEN csr_payroll_start_date(asg_rec.payroll_id,asg_rec.absence_start_date);
FETCH csr_payroll_start_date INTO l_payroll_proc_start_date;
CLOSE csr_payroll_start_date;

IF csr_asg%ROWCOUNT = 1 THEN
OPEN csr_emp(l_payroll_proc_start_date);
FETCH csr_emp INTO emp_rec;
CLOSE csr_emp;
END IF ;

OPEN csr_soft_coded_details(asg_rec.asg_id,l_payroll_proc_start_date);
FETCH csr_soft_coded_details INTO soft_coded_rec;
CLOSE csr_soft_coded_details;

OPEN csr_section27(l_payroll_proc_start_date,soft_coded_rec.le_id);
FETCH csr_section27 INTO l_section27;
CLOSE csr_section27;

/* Bug 5045710 fix- Getting the global values*/
OPEN csr_get_global_values('DK_MAX_SICK_DAYS_ALLOWED',l_payroll_proc_start_date);
FETCH csr_get_global_values INTO l_dk_max_sick_days_allowed;
CLOSE csr_get_global_values;

OPEN csr_get_global_values('DK_5DAY_PATTERN_MIN_DAYS',l_payroll_proc_start_date);
FETCH csr_get_global_values INTO l_dk_5day_pattern_min_days;
CLOSE csr_get_global_values;

OPEN csr_get_global_values('DK_6DAY_PATTERN_MIN_DAYS',l_payroll_proc_start_date);
FETCH csr_get_global_values INTO l_dk_6day_pattern_min_days;
CLOSE csr_get_global_values;

OPEN csr_get_global_values('DK_SICKPAY_MIN_WORK_HOURS',l_payroll_proc_start_date);
FETCH csr_get_global_values INTO l_dk_sickpay_min_work_hours;
CLOSE csr_get_global_values;

--IF asg_rec.person_id <> l_person_id THEN
IF l_absence_days >=l_dk_max_sick_days_allowed OR soft_coded_rec.section28 ='Y' OR l_section27 = 'Y' OR asg_rec.absence_reason ='ABS_WA' THEN
--END IF;

OPEN csr_le(soft_coded_rec.le_id);
FETCH csr_le INTO le_rec;
close csr_le;

OPEN csr_le_cvr(soft_coded_rec.le_id);
FETCH csr_le_cvr INTO le_cvr_rec;
CLOSE csr_le_cvr;
       /*Bug 5049222 fix*/
	xml_tab(xml_ctr).tagname  := 'emp_name';
	xml_tab(xml_ctr).tagvalue := hr_dk_utility.REPLACE_SPECIAL_CHARS(emp_rec.ename);
	xml_ctr := xml_ctr +1;

	xml_tab(xml_ctr).tagname  := 'address_line1';
	xml_tab(xml_ctr).tagvalue := hr_dk_utility.REPLACE_SPECIAL_CHARS(substr(emp_rec.address_line1,1,40));
	xml_ctr := xml_ctr +1;

	xml_tab(xml_ctr).tagname  := 'address_line2';
	xml_tab(xml_ctr).tagvalue := hr_dk_utility.REPLACE_SPECIAL_CHARS(substr(emp_rec.address_line2,1,40));
	xml_ctr := xml_ctr +1;

	xml_tab(xml_ctr).tagname  := 'postal_code';
	xml_tab(xml_ctr).tagvalue := hr_dk_utility.REPLACE_SPECIAL_CHARS(substr(emp_rec.postal_code,1,40));
	xml_ctr := xml_ctr +1;

	xml_tab(xml_ctr).tagname  := 'asg_num';
	xml_tab(xml_ctr).tagvalue := asg_rec.asg_num;
	xml_ctr := xml_ctr +1;

       /*Bug 5049222 fix*/
	xml_tab(xml_ctr).tagname  := 'le_cvr_number';
	xml_tab(xml_ctr).tagvalue := le_cvr_rec.le_cvr_num;
	xml_ctr := xml_ctr +1;

	xml_tab(xml_ctr).tagname  := 'national_identifier';
	xml_tab(xml_ctr).tagvalue := emp_rec.national_identifier;
	xml_ctr := xml_ctr +1;

	xml_tab(xml_ctr).tagname  := 'job_title';
	xml_tab(xml_ctr).tagvalue := hr_dk_utility.REPLACE_SPECIAL_CHARS(asg_rec.job_title);
	xml_ctr := xml_ctr +1;

	IF ((asg_rec.absence_start_date - asg_rec.asg_start_date) >= 90) THEN
	xml_tab(xml_ctr).tagname  := '13_weeks_yes';
	xml_tab(xml_ctr).tagvalue := l_check;
	xml_ctr := xml_ctr +1;
	ELSE
	xml_tab(xml_ctr).tagname  := '13_weeks_no';
	xml_tab(xml_ctr).tagvalue := l_check;
	xml_ctr := xml_ctr +1;
	xml_tab(xml_ctr).tagname  := 'asg_start_date';
	xml_tab(xml_ctr).tagvalue := asg_rec.asg_start_date;
	xml_ctr := xml_ctr +1;
	END IF ;

	xml_tab(xml_ctr).tagname  := 'last_day_at_work';
	xml_tab(xml_ctr).tagvalue := asg_rec.absence_start_date - 1;
	xml_ctr := xml_ctr +1;

	/*Has the employee resume work*/
	IF (asg_rec.absence_end_date <= l_end_date) THEN
	xml_tab(xml_ctr).tagname := 'absence_end_yes';
	xml_tab(xml_ctr).tagvalue := l_check;
	xml_ctr := xml_ctr +1;

	xml_tab(xml_ctr).tagname := 'absence_end_date';
	/*asg_rec.absence_end_date + 1 to get the date on which the employee resumed work*/
	xml_tab(xml_ctr).tagvalue := asg_rec.absence_end_date + 1;
	xml_ctr := xml_ctr +1;
	ELSE
	xml_tab(xml_ctr).tagname := 'absence_end_no';
	xml_tab(xml_ctr).tagvalue := l_check;
	xml_ctr := xml_ctr +1;
	END IF;

	/*check whether the absence reason is work accident*/
	IF (asg_rec.absence_reason = 'ABS_WA') THEN
	xml_tab(xml_ctr).tagname := 'work_accident_yes';
	xml_tab(xml_ctr).tagvalue := l_check;
	xml_ctr := xml_ctr +1;
	ELSE
	xml_tab(xml_ctr).tagname := 'work_accident_no';
	xml_tab(xml_ctr).tagvalue := l_check;
	xml_ctr := xml_ctr +1;
	END IF;

IF ((asg_rec.absence_start_date - asg_rec.asg_start_date)>=29 ) THEN
/*call to get the varying working hours for the last four weeks*/
l_var_work_hrs := pay_dk_sickpay_pkg.get_worked_hours(
					   asg_rec.asg_id
					  ,asg_rec.absence_start_date - 29
					  ,asg_rec.absence_start_date - 1) / 4;

/*If work schedule is not present then call working_hours_per_week which returns the working_hours
based on the details present at the assignment level if not at the LE level*/
IF( l_var_work_hrs = -1) THEN
l_var_work_hrs:= working_hours_per_week(asg_rec.asg_id,soft_coded_rec.le_id,l_payroll_proc_start_date);
END IF ;
END IF ;
	xml_tab(xml_ctr).tagname := 'var_work_hrs';
	xml_tab(xml_ctr).tagvalue := l_var_work_hrs;
	xml_ctr := xml_ctr +1;


/*Special Employment Arrangement*/

IF (soft_coded_rec.employee_group = 7) THEN
	xml_tab(xml_ctr).tagname := 'special_job';
	xml_tab(xml_ctr).tagvalue := l_check;
	xml_ctr := xml_ctr +1;
ELSIF (soft_coded_rec.employee_group = 8) THEN
 	xml_tab(xml_ctr).tagname := 'job_training';
	xml_tab(xml_ctr).tagvalue := l_check;
	xml_ctr := xml_ctr +1;
ELSIF (soft_coded_rec.employee_group = 6) THEN
	xml_tab(xml_ctr).tagname := 'flexible_job_sec1';
	xml_tab(xml_ctr).tagvalue := l_check;
    xml_ctr := xml_ctr +1;
	xml_tab(xml_ctr).tagname := 'flexible_job_sec3'; --Bug 5049222 fix
	xml_tab(xml_ctr).tagvalue := l_check;
	xml_ctr := xml_ctr +1;
END IF ;



/* call to get the last pay for the assignment*/
IF asg_rec.absence_end_date IS  NOT  NULL  AND asg_rec.absence_end_date <= l_end_date THEN
    last_pay(p_business_group_id,asg_rec.asg_id,asg_rec.absence_end_date,l_pay);
ELSE
    last_pay(p_business_group_id,asg_rec.asg_id,l_end_date,l_pay);
END IF ;
--l_pay := TRIM(TO_CHAR(ROUND(l_pay,2),'99g99g99g990d99','NLS_NUMERIC_CHARACTERS = '',.'''));
--l_pay := TRIM(TO_CHAR(ROUND(NVL(FND_NUMBER.canonical_to_number(l_pay),0),2),'999G999G990D99'));
l_pay := TRIM(TO_CHAR(ROUND(FND_NUMBER.canonical_to_number(l_pay),2),'999G999G990D99'));
	/*The employee's pay condition*/
	/* Changes for Lunar Payroll*/
	IF (asg_rec.period_type in ('Calendar Month','Lunar Month')) THEN
	xml_tab(xml_ctr).tagname := 'sal_per_month';
	xml_tab(xml_ctr).tagvalue := l_pay;
	xml_ctr := xml_ctr +1;
	xml_tab(xml_ctr).tagname := 'monthly_payroll';
	xml_tab(xml_ctr).tagvalue := l_check;
	xml_ctr := xml_ctr +1;

	ELSIF(asg_rec.period_type = 'Bi-Week') THEN
	xml_tab(xml_ctr).tagname := 'sal_per_bi_week';
	xml_tab(xml_ctr).tagvalue := l_pay;
	xml_ctr := xml_ctr +1;
	xml_tab(xml_ctr).tagname := 'bi_weekly_payroll';
	xml_tab(xml_ctr).tagvalue := l_check;
	xml_ctr := xml_ctr +1;

	ELSIF(asg_rec.period_type = 'Week') THEN
	xml_tab(xml_ctr).tagname := 'sal_per_week';
	xml_tab(xml_ctr).tagvalue := l_pay;
	xml_ctr := xml_ctr +1;
	xml_tab(xml_ctr).tagname := 'weekly_payroll';
	xml_tab(xml_ctr).tagvalue := l_check;
	xml_ctr := xml_ctr +1;
	END IF;

	xml_tab(xml_ctr).tagname := 'last_salary';
	xml_tab(xml_ctr).tagvalue := l_pay;
	xml_ctr := xml_ctr +1;
/*Bug 5059274 fix- Continuos payment details not displayed*/
/*	IF (asg_rec.asg_end_date <> TO_DATE('31/12/4712','DD/MM/YYYY')) THEN
	xml_tab(xml_ctr).tagname := 'cont_payment_no';
	xml_tab(xml_ctr).tagvalue := l_check;
	xml_ctr := xml_ctr +1;
	xml_tab(xml_ctr).tagname := 'asg_end_date';
	xml_tab(xml_ctr).tagvalue := asg_rec.asg_end_date;
	xml_ctr := xml_ctr +1;

	ELSIF  (asg_rec.asg_end_date = TO_DATE('31/12/4712','DD/MM/YYYY')) THEN
	xml_tab(xml_ctr).tagname := 'cont_payment_yes';
	xml_tab(xml_ctr).tagvalue := l_check;
	xml_ctr := xml_ctr +1;
	END IF;*/
	xml_tab(xml_ctr).tagname := 'abs_start_date';
	xml_tab(xml_ctr).tagvalue := asg_rec.absence_start_date;
	xml_ctr := xml_ctr +1;

        /*Bug 5040140 fix- if the end date is null then absence end date field in the report
	   should be blank*/
	xml_tab(xml_ctr).tagname := 'abs_end_date';
	IF asg_rec.absence_end_date = TO_DATE('31/12/4712','DD/MM/YYYY') THEN
	xml_tab(xml_ctr).tagvalue := NULL ;
	ELSE
	xml_tab(xml_ctr).tagvalue := asg_rec.absence_end_date;
	END IF ;
	xml_ctr := xml_ctr +1;

	/*xml_tab(xml_ctr).tagname := 'abs_end_date';
	xml_tab(xml_ctr).tagvalue := asg_rec.absence_end_date;
	xml_ctr := xml_ctr +1;*/

	xml_tab(xml_ctr).tagname := 'le_name';
	xml_tab(xml_ctr).tagvalue := hr_dk_utility.REPLACE_SPECIAL_CHARS(le_rec.le_name);
	xml_ctr := xml_ctr +1;

	xml_tab(xml_ctr).tagname := 'le_address_pcode';
	xml_tab(xml_ctr).tagvalue := hr_dk_utility.REPLACE_SPECIAL_CHARS(le_rec.le_address1)||hr_dk_utility.REPLACE_SPECIAL_CHARS(le_rec.le_postalcode);
	xml_ctr := xml_ctr +1;

	xml_tab(xml_ctr).tagname := 'le_phone';
	xml_tab(xml_ctr).tagvalue := hr_dk_utility.REPLACE_SPECIAL_CHARS(le_rec.le_phone);
	xml_ctr := xml_ctr +1;

	xml_tab(xml_ctr).tagname := 'le_email';
	xml_tab(xml_ctr).tagvalue := hr_dk_utility.REPLACE_SPECIAL_CHARS(le_rec.le_email);
	xml_ctr := xml_ctr +1;

/*Before 8 weeks*/
/*IF  ((asg_rec.absence_start_date - asg_rec.asg_start_date) < 57) THEN
IF  ((asg_rec.absence_start_date - emp_rec.person_start_date ) <57) THEN
	xml_tab(xml_ctr).tagname := 'before_8_weeks';
	xml_tab(xml_ctr).tagvalue := l_check;
	xml_ctr := xml_ctr +1;
END IF ;
END IF ;*/

/*call to get the  working hours for the last eight weeks*/
/*l_8weeks_work_hrs := pay_dk_sickpay_pkg.get_worked_hours(
					   asg_rec.asg_id
					  ,asg_rec.absence_start_date - 57
					  ,asg_rec.absence_start_date - 1) ;


IF( l_8weeks_work_hrs = -1) THEN
l_8weeks_work_hrs:= working_hours_per_week(asg_rec.asg_id,soft_coded_rec.le_id,l_payroll_proc_start_date) * 8;
END IF ;*/

/*Bug 5045710 fix*/

IF (soft_coded_rec.asg_work_pattern IS NULL) THEN
/*if work pattern not defined at the assignment level, get from the legal employer level*/
    OPEN csr_le_work_pattern(soft_coded_rec.le_id);
    FETCH csr_le_work_pattern INTO le_work_pattern_rec;
    l_work_pattern := le_work_pattern_rec.le_work_pattern;
    CLOSE csr_le_work_pattern;
ELSE
    l_work_pattern := soft_coded_rec.asg_work_pattern;
END IF;

/*Call to get the worked days*/
l_worked_days := pay_dk_sickpay_pkg.get_worked_days
			(asg_rec.asg_id
			,asg_rec.asg_start_date
			,asg_rec.absence_start_date-1);

IF (l_work_pattern = '6DAY') THEN
/* Reopened bug 5045710 fix- checking the flag if the worked days is less than 48 days*/
    IF l_worked_days < l_dk_6day_pattern_min_days THEN -- check if the worked days < 48 days
	xml_tab(xml_ctr).tagname := 'before_8_weeks';
	xml_tab(xml_ctr).tagvalue := l_check;
	xml_ctr := xml_ctr +1;
    ELSE
	l_worked_days:= l_dk_6day_pattern_min_days;
    END IF ;
ELSE
    /*By default work pattern will be 5 days*/
    /* Reopened bug 5045710 fix- checking the flag if the worked days is less than 40 days*/
    IF l_worked_days < l_dk_5day_pattern_min_days THEN -- check if the worked days < 40 days
	xml_tab(xml_ctr).tagname := 'before_8_weeks';
	xml_tab(xml_ctr).tagvalue := l_check;
	xml_ctr := xml_ctr +1;
    ELSE
       l_worked_days:= l_dk_5day_pattern_min_days;
    END IF ;
END IF ;

l_74hrs := pay_dk_sickpay_pkg.get_worked_hours_flag
                    (asg_rec.asg_id
                     ,l_worked_days
                     ,l_dk_sickpay_min_work_hours
                     ,asg_rec.absence_start_date-1);

--IF l_8weeks_work_hrs < 74 THEN

IF l_74hrs = 'N' THEN
	xml_tab(xml_ctr).tagname := '8weeks_work_hrs';
	xml_tab(xml_ctr).tagvalue := l_check;
	xml_ctr := xml_ctr +1;

END IF ;

IF (l_section27 = 'Y') THEN
	xml_tab(xml_ctr).tagname := 'section27';
	xml_tab(xml_ctr).tagvalue := l_check;
	xml_ctr := xml_ctr +1;
END IF;

IF (soft_coded_rec.section28 = 'Y') THEN
	xml_tab(xml_ctr).tagname := 'section28';
	xml_tab(xml_ctr).tagvalue := l_check;
	xml_ctr := xml_ctr +1;
END IF;

	xml_tab(xml_ctr).tagname := 'se_nr';
	xml_tab(xml_ctr).tagvalue := '   ';
	xml_ctr := xml_ctr +1;
END IF ;
--l_person_id := asg_rec.person_id;
END LOOP ;

write_to_clob(p_xml);

EXCEPTION WHEN OTHERS THEN
NULL ;
END POPULATE_DETAILS;

------------------------------------------------------------------------------------------------------------

procedure WRITE_TO_CLOB (p_xml out nocopy clob) is
l_xfdf_string clob;
l_str1 varchar2(240);
l_str2 varchar2(240);
l_str3 varchar2(240);
l_str4 varchar2(240);
l_str5 varchar2(240);
l_IANA_charset VARCHAR2 (50);

BEGIN

l_str1 := '<field name="';
l_str2 := '">';
l_str3 := '<value>';
l_str4 := '</value></field>';
l_str5 := '</xfdf>';
l_IANA_charset :=PAY_DK_GENERAL.get_IANA_charset ;


dbms_lob.createtemporary(p_xml,false,dbms_lob.call);

/*Setting the Character Set Dynamically*/
--p_xml := '<?xml version = "1.0" encoding = "UTF-8"?>';
p_xml := '<?xml version = "1.0" encoding = "'||l_IANA_charset||'"?>';
p_xml := p_xml || '<xfdf xmlns="http://ns.adobe.com/xfdf/" xml:space="preserve">';
dbms_lob.open(p_xml,dbms_lob.lob_readwrite);
if xml_tab.count > 0 then
 for xml_ctr in xml_tab.first .. xml_tab.last LOOP
 dbms_lob.writeappend( p_xml, length(l_str1),l_str1 );
 dbms_lob.writeappend( p_xml, length(xml_tab(xml_ctr).tagname), xml_tab(xml_ctr).tagname);
 dbms_lob.writeappend( p_xml, length(l_str2),l_str2 );
 dbms_lob.writeappend( p_xml, length(l_str3),l_str3 );
 dbms_lob.writeappend( p_xml, length(nvl(xml_tab(xml_ctr).tagvalue,' ')),nvl(xml_tab(xml_ctr).tagvalue,' '));
 dbms_lob.writeappend( p_xml, length(l_str4),l_str4 );
 end loop;
end if;
dbms_lob.writeappend( p_xml, length(l_str5),l_str5 );
--dbms_lob.createtemporary(p_xml,true);
--clob_to_blob(l_xfdf_string,p_xml);
exception
when others then
hr_utility.trace('sqleerm ' || sqlerrm);
hr_utility.raise_error;
end write_to_clob;
-------------------------------------------------------------------------------------------------------------------------
 END PAY_DK_SICKNESS_DP201;

/
