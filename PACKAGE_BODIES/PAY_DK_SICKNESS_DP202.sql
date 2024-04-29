--------------------------------------------------------
--  DDL for Package Body PAY_DK_SICKNESS_DP202
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_DK_SICKNESS_DP202" AS
/* $Header: pydkdp202.pkb 120.7.12000000.2 2007/05/08 07:02:59 saurai noship $ */
	g_debug   boolean   :=  hr_utility.debug_enabled;
	g_err_num		NUMBER;
	l_run_date DATE ;
	l_person_id NUMBER ;

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
END get_defined_balance_id;
---------------------------------------------------------------------------------------------------

/*Procedure to get the last pay for an assignment*/
PROCEDURE LAST_PAY
	( p_business_group_id IN NUMBER
	,p_assignment_id IN NUMBER
	,p_effective_date IN DATE
	,p_pay OUT NOCOPY VARCHAR2
	,p_period_type OUT NOCOPY VARCHAR2
	)
		   IS

CURSOR csr_asg_act_id IS
SELECT
*
FROM
(
SELECT
	paa1.assignment_action_id,ppf.period_type
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

CURSOR csr_pay(asg_act_id NUMBER ) IS
SELECT
	sum(pay_balance_pkg.get_value(
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
FETCH csr_asg_act_id INTO l_asg_act_id,p_period_type;
CLOSE csr_asg_act_id;

OPEN csr_pay(l_asg_act_id);
FETCH csr_pay INTO p_pay;
CLOSE csr_pay;

END last_pay;
-------------------------------------------------------------------------------------------------------------------------

/*Procudure to get the sick leave details for reporting*/
/*Bug 5059274 fix- Added p_start_date and p_end_Date parameters*/
PROCEDURE POPULATE_DETAILS
		(p_template_name in VARCHAR2
		,p_assignment_id NUMBER
		,p_person_id NUMBER
		,p_start_date IN VARCHAR2
		,p_end_date IN VARCHAR2
		,p_le_phone_number IN VARCHAR2
		,p_le_email_addr IN varchar2
		,p_business_group_id NUMBER
		, p_xml out nocopy clob)
		IS

/*Parameters to store the start and end dates, in order to provide date validation the parameters
  are accepeted as varchar2 and converted into date type*/
l_start_date DATE;
l_end_date DATE;

--cursor to fetch employee details
CURSOR csr_emp(p_effective_date DATE)IS
SELECT
*
FROM
(
SELECT
	/*papf.first_name first_name
	,papf.middle_names middle_name
	,papf.last_name last_name*/
	/*Bug 5049222 fix- Employee name formatting*/
	--SUBSTR (papf.first_name,1,40)||NVL2(papf.middle_names,','||SUBSTR(papf.middle_names,1,40),NULL)||','||SUBSTR(papf.last_name,1,40) ename
	/*Reopened Bug 5049222 fix*/
        SUBSTR (papf.last_name,1,40)||', '||SUBSTR(papf.first_name,1,40)||NVL2(papf.middle_names,' '||SUBSTR(papf.middle_names,1,40),NULL) ename
	,papf.national_identifier national_identifier
FROM
     per_all_people_f papf
WHERE
	papf.person_id = p_person_id
	AND p_effective_date between papf.effective_start_date and papf.effective_end_date
	AND papf.current_employee_flag = 'Y')
GROUP BY ename,national_identifier;


/*Bug 5039491fix -cursor to fetch address*/
CURSOR csr_address(p_effective_date DATE) IS
SELECT
    pa.address_line1 address_line1
    ,pa.address_line2 address_line2
    ,pa.postal_code postal_code
FROM
    per_addresses   pa
WHERE
    pa.person_id = p_person_id
	AND pa.primary_flag = 'Y'
    AND p_effective_date BETWEEN pa.date_from AND nvl(pa.date_to,TO_DATE('31/12/4712','dd/mm/yyyy'));


/*Bug fix- 5059274 cursor to get the assignment details based on p_start_date and p_end_date*/
CURSOR csr_asg IS
SELECT
	paaf.person_id person_id
    ,paaf.assignment_id asg_id
	,paaf.assignment_number asg_num
	,MIN (paaf.effective_start_date) asg_start_date
	,MAX(paaf.effective_end_date) asg_end_date
	,peef.effective_start_date absence_start_date
	,peef.effective_end_date absence_end_date
	,paaf.payroll_id payroll_id
FROM
	per_all_assignments_f  paaf
	,pay_element_types_f petf
	,pay_element_entries_f peef
WHERE
    paaf.person_id = p_person_id
	AND paaf.assignment_id = NVL(p_assignment_id,paaf.assignment_id)
--	AND l_run_date BETWEEN paaf.effective_start_date AND paaf.effective_end_date
	AND paaf.assignment_status_type_id = 1
	AND petf.element_name LIKE 'Absent Sick' -- To check for the Sickness element
--	AND l_run_date BETWEEN petf.effective_start_date AND petf.effective_end_date

	AND peef.assignment_id = paaf.assignment_id
	AND peef.element_type_id = petf.element_type_id
    AND peef.effective_start_date BETWEEN l_start_date and l_end_date
    GROUP BY
    paaf.person_id
    ,paaf.assignment_id
    ,paaf.assignment_number
	,peef.effective_start_date
	,peef.effective_end_date
	,paaf.payroll_id;
--	AND peef.effective_start_date = l_run_date; -- To Check whether the leave started on Run Date(i/p Paramter - 1)



CURSOR csr_le(p_effective_date DATE) IS
SELECT
	haou.organization_id le_id
	,SUBSTR(haou.NAME,1,30) le_name
	,SUBSTR(hl.address_line_1,1,30) le_address1
	,DECODE(hl.postal_code,NULL,' ',','||substr(hl.postal_code,1,5)) le_postalcode
	,SUBSTR (p_le_phone_number,1,30) le_phone
	,substr(p_le_email_addr,1,30) le_email
FROM
	per_all_assignments_f paaf
	,hr_soft_coding_keyflex hsck
	,hr_all_organization_units haou
	,hr_locations hl
WHERE
	paaf.assignment_id = p_assignment_id
	AND p_effective_date BETWEEN paaf.effective_start_date AND paaf.effective_end_date
	AND paaf.assignment_status_type_id = 1
	AND hsck.soft_coding_keyflex_id = paaf.soft_coding_keyflex_id
	AND haou.organization_id = hsck.segment1
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


-- Variable declaration
l_var_work_hrs NUMBER ;
emp_rec csr_emp%ROWTYPE ;
asg_rec csr_asg%ROWTYPE ;
le_rec csr_le%ROWTYPE ;
addr_rec csr_address%ROWTYPE ;
xml_ctr  number;
l_pay VARCHAR2(150);
l_period_type pay_payrolls_f.period_type%TYPE;
l_check VARCHAR2(1);
le_cvr_rec csr_le_cvr%ROWTYPE; --Bug 5049222 fix
l_payroll_proc_start_date DATE ;

BEGIN
l_check := 'X';
xml_ctr := 0;
l_start_date :=FND_DATE.CANONICAL_TO_DATE(p_start_date);
l_end_date   :=FND_DATE.CANONICAL_TO_DATE(p_end_date);

FOR asg_rec IN  csr_asg LOOP

OPEN csr_payroll_start_date(asg_rec.payroll_id,asg_rec.absence_start_date);
FETCH csr_payroll_start_date INTO l_payroll_proc_start_date;
CLOSE csr_payroll_start_date;

IF (csr_asg%ROWCOUNT = 1) THEN
OPEN csr_emp(l_payroll_proc_start_date);
FETCH csr_emp INTO emp_rec;
CLOSE csr_emp;
END IF ;

OPEN csr_address(l_payroll_proc_start_date);
FETCH csr_address INTO addr_rec;
CLOSE csr_address;

OPEN csr_le(l_payroll_proc_start_date);
FETCH csr_le INTO le_rec;
CLOSE csr_le;

OPEN csr_le_cvr(le_rec.le_id);
FETCH csr_le_cvr INTO le_cvr_rec;
CLOSE csr_le_cvr;

       /*Bug 5049222 fix*/
	xml_tab(xml_ctr).tagname  := 'emp_name';
	xml_tab(xml_ctr).tagvalue := hr_dk_utility.REPLACE_SPECIAL_CHARS(emp_rec.ename);
	xml_ctr := xml_ctr +1;

	xml_tab(xml_ctr).tagname  := 'address_line1';
	xml_tab(xml_ctr).tagvalue := hr_dk_utility.REPLACE_SPECIAL_CHARS(substr(addr_rec.address_line1,1,40));
	xml_ctr := xml_ctr +1;

	xml_tab(xml_ctr).tagname  := 'address_line2';
	xml_tab(xml_ctr).tagvalue := hr_dk_utility.REPLACE_SPECIAL_CHARS(substr(addr_rec.address_line2,1,40));
	xml_ctr := xml_ctr +1;

	xml_tab(xml_ctr).tagname  := 'postal_code';
	xml_tab(xml_ctr).tagvalue := substr(addr_rec.postal_code,1,40);
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

       /* call to get the last pay for the assignment*/
IF asg_rec.absence_end_date IS  NOT  NULL  AND asg_rec.absence_end_date <= l_end_date THEN
    last_pay(p_business_group_id,asg_rec.asg_id,asg_rec.absence_end_date,l_pay,l_period_type);
ELSE
    last_pay(p_business_group_id,asg_rec.asg_id,l_end_date,l_pay,l_period_type);
END IF ;

   --    l_pay := TRIM(TO_CHAR(ROUND(l_pay,2),'99g99g99g990d99','NLS_NUMERIC_CHARACTERS = '',.'''));
--        l_pay := TRIM(TO_CHAR(ROUND(NVL(FND_NUMBER.canonical_to_number(l_pay),0),2),'999G999G990D99'));
        l_pay := TRIM(TO_CHAR(ROUND(FND_NUMBER.canonical_to_number(l_pay),2),'999G999G990D99'));

	/*The employee's pay condition*/
	/* Changes for Lunar Payroll*/
	IF l_period_type in ('Calendar Month','Lunar Month') THEN
	xml_tab(xml_ctr).tagname := 'sal_per_month';
	xml_tab(xml_ctr).tagvalue := l_pay;
	xml_ctr := xml_ctr +1;

	ELSIF(l_period_type = 'Bi-Week') THEN
	xml_tab(xml_ctr).tagname := 'sal_per_bi_week';
	xml_tab(xml_ctr).tagvalue := l_pay;
	xml_ctr := xml_ctr +1;

	ELSIF(l_period_type = 'Week') THEN
	xml_tab(xml_ctr).tagname := 'sal_per_week';
	xml_tab(xml_ctr).tagvalue := l_pay;
	xml_ctr := xml_ctr +1;
	END IF;

	xml_tab(xml_ctr).tagname := 'last_salary';
	xml_tab(xml_ctr).tagvalue := l_pay;
	xml_ctr := xml_ctr +1;

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

IF (le_rec.le_phone IS NOT NULL AND le_rec.le_email IS NOT NULL ) THEN
	xml_tab(xml_ctr).tagname := 'le_phone_email';
	xml_tab(xml_ctr).tagvalue := hr_dk_utility.REPLACE_SPECIAL_CHARS(le_rec.le_phone) ||','||hr_dk_utility.REPLACE_SPECIAL_CHARS(le_rec.le_email);
	xml_ctr := xml_ctr +1;
ELSE
	xml_tab(xml_ctr).tagname := 'le_phone_email';
	xml_tab(xml_ctr).tagvalue := hr_dk_utility.REPLACE_SPECIAL_CHARS(le_rec.le_phone) ||hr_dk_utility.REPLACE_SPECIAL_CHARS(le_rec.le_email);
	xml_ctr := xml_ctr +1;


END IF ;

END LOOP ;

write_to_clob(p_xml);

EXCEPTION WHEN OTHERS THEN
NULL;
END  populate_details;

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
END PAY_DK_SICKNESS_DP202;

/
