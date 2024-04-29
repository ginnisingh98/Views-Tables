--------------------------------------------------------
--  DDL for Package Body PAY_IE_TAX_VAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_IE_TAX_VAL" as
/* $Header: pyietxvl.pkb 120.20.12010000.1 2008/07/27 22:51:50 appldev ship $ */

g_validate_count	NUMBER := 0;
TYPE error_rec is record
			(p_pps_number	VARCHAR2(11),
                   p_works_number	VARCHAR2(12),
			 p_err_msg		VARCHAR2(1000));

TYPE err_tab IS TABLE OF error_rec INDEX BY BINARY_INTEGER;

l_err_tab	err_tab;
err_cnt	number := 1;

PROCEDURE getparam(
   errbuf 		OUT NOCOPY VARCHAR2
 , retcode 		OUT NOCOPY VARCHAR2
 ,  p_data_file 	IN VARCHAR2
 , p_employer_number 	IN VARCHAR2
 , p_tax_year 		IN NUMBER
 , p_validate_mode 	IN VARCHAR2 :='IE_VALIDATE'
 , p_payroll_id	 	IN NUMBER := NULL)
IS
Begin
 Null;
/* Dummy Procedure created  to accept all the parameters once and share them
   later in the stages of request set */
 retcode := 0;
end;

PROCEDURE count_validation(
          errbuf        OUT NOCOPY VARCHAR2
        , retcode       OUT NOCOPY VARCHAR2
        , p_employer_number IN  VARCHAR2
        , p_tax_year    IN  pay_ie_tax_header_interface.tax_year%TYPE)  IS

  -- Cursor to get the total values form body
CURSOR c_body
IS
SELECT COUNT(PBS.MTH_TAX_CREDIT) 	count_mth_taxcredit
  , SUM (NVL(PBS.MTH_RATE_CUTOFF,0)) 	sum_mth_rate_cutoff
  , SUM (NVL(PBS.WK_RATE_CUTOFF,0)) 	sum_wk_rate_cutoff
  , SUM(NVL(PBS.MTH_TAX_CREDIT,0)) 	sum_mth_tax_credit
  , SUM(NVL(PBS.WK_TAX_CREDIT,0)) 	sum_wk_tax_credit
FROM PAY_IE_TAX_HEADER_INTERFACE phs
  , PAY_IE_TAX_BODY_INTERFACE pbs
WHERE PHS.EMPLOYER_NUMBER = PBS.EMPLOYER_NUMBER
AND PHS.TAX_YEAR = p_tax_year
AND PBS.EMPLOYER_NUMBER = p_employer_number;

  -- Cursor to get the total values from trailer table
CURSOR c_trailer
IS
SELECT PTS.RECORD_NO 			count_emp_recno
  , NVL(PTS.TOTAL_MTH_RATE_CUTOFF,0) 	total_mth_cutoff
  , NVL(PTS.TOTAL_WK_RATE_CUTOFF,0) 	total_wk_cutoff
  , NVL(PTS.TOTAL_MTH_TAX_CREDIT,0) 	total_mth_credit
  , NVL(PTS.TOTAL_WK_TAX_CREDIT,0) 	total_wk_credit
FROM PAY_IE_TAX_HEADER_INTERFACE phs
  , PAY_IE_TAX_TRAILER_INTERFACE pts
WHERE PTS.EMPLOYER_NUMBER = p_employer_number
AND PHS.TAX_YEAR = p_tax_year;

  l_error_stack 		VARCHAR2 (2000);
  l_error 			VARCHAR2 (80);
  l_request_id 			NUMBER;
  l_count_mth_taxcredit 	NUMBER ;
  l_sum_mth_rate_cutoff 	NUMBER;
  l_sum_wk_rate_cutoff 		NUMBER;
  l_sum_mth_tax_credit 		NUMBER;
  l_sum_wk_tax_credit 		NUMBER;
  l_count_emp_recno 		NUMBER;
  l_total_mth_cutoff 		NUMBER;
  l_total_wk_cutoff 		NUMBER;
  l_total_mth_credit 		NUMBER;
  l_total_wk_credit 		NUMBER;

  unequal_value 		EXCEPTION;
  BodyRec 			c_body%rowtype;
  TrailRec 			c_trailer%rowtype;

BEGIN
  l_request_id := FND_GLOBAL.CONC_REQUEST_ID;


 Begin
   Delete from pay_ie_tax_error;
   if sql%rowcount > 0 then
      commit;
   end if;
 exception
   when others then
   FND_FILE.PUT_LINE(fnd_file.log,'Error occured while deleting exisiting rows in
    			PAY_IE_TAX_ERROR table');
 end;

 UPDATE PAY_IE_TAX_BODY_INTERFACE
  SET EMPLOYER_NUMBER =
  		(SELECT EMPLOYER_NUMBER
  		FROM PAY_IE_TAX_HEADER_INTERFACE);

  OPEN c_body;

  FETCH c_body into BodyRec;
  	IF (c_body%NOTFOUND) THEN
  		RAISE NO_DATA_FOUND;
  	END IF;
  l_count_mth_taxcredit := BodyRec.count_mth_taxcredit;
  l_sum_mth_rate_cutoff := BodyRec.sum_mth_rate_cutoff;
  l_sum_wk_rate_cutoff := BodyRec.sum_wk_rate_cutoff;
  l_sum_mth_tax_credit := BodyRec.sum_mth_tax_credit;
  l_sum_wk_tax_credit := BodyRec.sum_wk_tax_credit;


  OPEN c_trailer;

  FETCH c_trailer into TrailRec;
  	IF (c_trailer%NOTFOUND) THEN
  		RAISE NO_DATA_FOUND;
  	END IF;
  l_count_emp_recno := TrailRec.count_emp_recno;
  l_total_mth_cutoff := TrailRec.total_mth_cutoff;
  l_total_wk_cutoff := TrailRec.total_wk_cutoff;
  l_total_mth_credit := TrailRec.total_mth_credit;
  l_total_wk_credit := TrailRec.total_wk_credit;

  IF (BodyRec.count_mth_taxcredit = TrailRec.count_emp_recno
  	AND BodyRec.sum_mth_rate_cutoff = TrailRec.total_mth_cutoff
  	AND BodyRec.sum_wk_rate_cutoff = TrailRec.total_wk_cutoff
  	AND BodyRec.sum_mth_tax_credit = TrailRec.total_mth_credit
  	AND BodyRec.sum_wk_tax_credit = TrailRec.total_wk_credit)
  THEN
  	retcode := 0;
  	fnd_file.put_line( fnd_file.log, 'FND - CONC-COMPLETION TEXT:NORMAL');

  	update pay_ie_tax_body_interface
  	set process_flag = 'Y'
  	where EMPLOYER_NUMBER = p_employer_number;
  	Commit;

  ELSE
  	RAISE unequal_value;
  END IF;

  close c_body;
  close c_trailer;

  EXCEPTION
  WHEN NO_DATA_FOUND THEN
  	l_error := SQLERRM;
  	retcode := 2;
  	FND_FILE.PUT_LINE(fnd_file.log,'No data found');
  WHEN unequal_value THEN
  	errbuf := fnd_message.get;
  	l_error_stack := errbuf;
  	l_error := SQLERRM;
        retcode := 2;
  	IF l_count_mth_taxcredit <> l_count_emp_recno THEN
  		FND_FILE.NEW_LINE(fnd_file.log, 1);
	  	FND_FILE.PUT_LINE(fnd_file.log,
		'The total number of record in pay_ie_tax_body_interface is '
			|| TO_CHAR (l_count_mth_taxcredit));
		FND_FILE.PUT_LINE (fnd_file.log,
			'The value in pay_ie_tax_trailer_interface.record_no is '
			||  TO_CHAR(l_count_emp_recno));
		FND_FILE.PUT_LINE(fnd_file.log,
			'Error - Retcode = 2, total number of record in pay_ie_tax_body_interface');
		FND_FILE.PUT_LINE(fnd_file.log,
			'does not match the value in pay_ie_tax_trailer_interface.record_no');
	END IF;

  	IF l_sum_mth_rate_cutoff <> l_total_mth_cutoff THEN
  		FND_FILE.NEW_LINE(fnd_file.log, 1);
  		FND_FILE.PUT_LINE(fnd_file.log,
		'The sum of pay_ie_tax_body_interface.mth_rate_cutoff is '
			|| TO_CHAR (l_sum_mth_rate_cutoff));
		FND_FILE.PUT_LINE (fnd_file.log,
			'The total monthly cutoff in pay_ie_tax_trailer_interface.total_mth_rate_cutoff is '
			||  TO_CHAR(l_total_mth_cutoff));
		FND_FILE.PUT_LINE(fnd_file.log,
			'Error - Retcode = 2, the sum of pay_ie_tax_body_interface.mth_rate_cutoff');
		FND_FILE.PUT_LINE(fnd_file.log,
			'does not match the total monthly cutoff in pay_ie_tax_trailer_interface.total_mth_rate_cutoff');
	END IF;
	IF l_sum_wk_rate_cutoff <> l_total_wk_cutoff THEN
		FND_FILE.NEW_LINE(fnd_file.log, 1);
		FND_FILE.PUT_LINE(fnd_file.log,
			'The sum of pay_ie_tax_body_interface.wk_rate_cutoff is '
			|| TO_CHAR(l_sum_wk_rate_cutoff));
		FND_FILE.PUT_LINE(fnd_file.log,
			'The total weekly cutoff in pay_ie_tax_trailer_interface.total_wk_rate_cutoff is '
			|| TO_CHAR(l_total_wk_cutoff));
		FND_FILE.PUT_LINE(fnd_file.log,
			'Error - Retcode = 2, the sum of pay_ie_tax_body_interface.wk_rate_cutoff');
		FND_FILE.PUT_LINE(fnd_file.log,
			'does not match the the total weekly cutoff in pay_ie_tax_trailer_interface.total_wk_rate_cutoff');
	END IF;
	IF l_sum_mth_tax_credit <> l_total_mth_credit THEN
		FND_FILE.NEW_LINE(fnd_file.log, 1);
		FND_FILE.PUT_LINE(fnd_file.log,
			'The sum of pay_ie_tax_body_interface.mth_tax_credit is '
			|| TO_CHAR(l_sum_mth_tax_credit));
		FND_FILE.PUT_LINE(fnd_file.log,
			'The total monthly credit in pay_ie_tax_trailer_interface.total_mth_tax_credit is '
			|| TO_CHAR(l_total_mth_credit));
		FND_FILE.PUT_LINE(fnd_file.log,
			'Error - Retcode = 2, the sum of pay_ie_tax_body_interface.mth_tax_credit');
		FND_FILE.PUT_LINE(fnd_file.log,
			'does not match the total monthly credit in pay_ie_tax_trailer_interface.total_mth_tax_credit');
	END IF;
	IF BodyRec.sum_wk_tax_credit <> TrailRec.total_wk_credit THEN
		FND_FILE.NEW_LINE(fnd_file.log, 1);
		FND_FILE.PUT_LINE(fnd_file.log,
			'The sum of pay_ie_tax_body_interface.wk_tax_credit is '
			|| TO_CHAR(l_sum_wk_tax_credit));
		FND_FILE.PUT_LINE(fnd_file.log,
			'The total weekly credit in pay_ie_tax_trailer_interface.total_wk_tax_credit is '
			|| TO_CHAR(l_total_wk_credit));
		FND_FILE.PUT_LINE(fnd_file.log,
			'Error - Retcode = 2 because the sum of pay_ie_tax_body_interface.wk_tax_credit');
		FND_FILE.PUT_LINE(fnd_file.log,
			'does not match the total weekly credit in pay_ie_tax_trailer_interface.total_wk_tax_credit');
	END IF;

INSERT INTO pay_ie_tax_error ( pps_number
  , employee_number
  , full_name
  , payroll_name
  , error_stack_message
  , error_message
  , request_id
  , error_date)
  VALUES (0
  , NULL
  , NULL
  , NULL
  , l_error_stack
  , l_error
  , l_request_id
  , sysdate);
  COMMIT;

  WHEN OTHERS THEN
  errbuf := fnd_message.get;
  l_error_stack := errbuf;
  l_error := SQLERRM;
  retcode := 2;
FND_FILE.PUT_LINE (fnd_file.log, 'Error raised in loading data into one or all of the follo
wing tables: pay_ie_tax_header_interface, pay_ie_tax_body_interface, pay_ie_tax_trailer_interface');

INSERT INTO pay_ie_tax_error ( pps_number
  , employee_number
  , full_name
  , payroll_name
  , error_stack_message
  , error_message
  , request_id
  , error_date)
  VALUES (0
  , NULL
  , NULL
  , NULL
  , l_error_stack
  , l_error
  , l_request_id
  , sysdate);
  COMMIT;
END count_validation;

-- Procedure to validate every row from the interface table and update
-- PAY_IE_PAYE_DETAILS_F table if required.

PROCEDURE valinsupd (
 errbuf 		OUT NOCOPY VARCHAR2
, retcode 		OUT NOCOPY VARCHAR2
, p_employer_number 	IN VARCHAR2
, p_tax_year 		IN NUMBER
, p_validate_mode 	IN VARCHAR2 :='IE_VALIDATE'
, p_payroll_id	 	IN NUMBER := NULL
) AS
--bug 6376140
--BUG 6652299 ADDED DISTINCT KEY WORD TO THE CURSOR C_NO_OF_ASSG
/*Declare cursor to retrieve no.of assignments  from person
and interface tables based on input parameters*/
cursor c_no_of_assg IS
select per.person_id   person_id
,per.NATIONAL_IDENTIFIER pps_number
,count(distinct(asg.ASSIGNMENT_NUMBER)) no_of_assg
from per_all_assignments_f asg,
per_all_people_f per,
pay_all_payrolls_f pay,
pay_ie_tax_body_interface tbi,
per_periods_of_service pps
where per.national_identifier = tbi.pps_number
--AND pay.payroll_id = nvl(p_payroll_id,pay.payroll_id)
--AND asg.payroll_id = pay.payroll_id
AND per.person_id = asg.person_id
AND tbi.process_flag = 'Y'
AND asg.effective_start_date <= to_date('31/12/'||to_char(tbi.cert_start_date,'YYYY'),'dd/mm/yyyy')
AND asg.effective_end_date >= trunc(tbi.cert_start_date)
AND per.effective_start_date <= to_date('31/12/'||to_char(tbi.cert_start_date,'YYYY'),'dd/mm/yyyy')
AND per.effective_end_date >= trunc(tbi.cert_start_date)
and asg.period_of_service_id=pps.period_of_service_id
and pps.person_id=per.person_id
--and pps.date_start <= to_date('31/12/'||to_char(tbi.cert_start_date,'YYYY'),'dd/mm/yyyy')
and pps.period_of_service_id in (select max(pps1.period_of_service_id) from per_periods_of_service pps1 where pps1.person_id=pps.person_id and pps1.date_start <= to_date('31/12/'||to_char(tbi.cert_start_date,'YYYY'),'dd/mm/yyyy'))
--AND pay.effective_start_date <= to_date('31/12/'||to_char(tbi.cert_start_date,'YYYY'),'dd/mm/yyyy')
--AND pay.effective_end_date >= trunc(tbi.cert_start_date)
group by per.person_id,per.NATIONAL_IDENTIFIER;

/* Cursor check_pps(p_pps_no varchar) is
    Select  1  from per_all_people_f per
                ,pay_ie_tax_body_interface tbi
        Where  per.effective_start_date <= to_date('31/12/'||to_char(tbi.cert_start_date,'YYYY'),'dd/mm/yyyy')
        AND per.effective_end_date >= trunc(tbi.cert_start_date)
        and per.national_identifier=p_pps_no
	AND tbi.process_flag = 'Y'
	and tbi.pps_number=per.national_identifier;
	p_check_pps check_pps%rowtype; */

/*Declare cursor to retrieve all employee details from payroll
and interface tables based on input parameters for a multiple assignments*/
CURSOR c_pay(p_pps_number varchar) IS
SELECT distinct per.employee_number 		employee_no_hr
, per.national_identifier 		pps_number_hr
, per.last_name 			last_name_hr
, per.first_name 			first_name_hr
, asg.assignment_id 			assignment_id
--, asg.effective_start_date 		effective_start_date
, hoi.org_information1 			tax_district
, pay.payroll_name 			payroll_name_hr
, pay.payroll_id				payroll_id		-- 4878630
--, ppd.paye_details_id 			paye_details_id  --4878630
--, ppd.object_version_number 		object_version_no --4878630
--, ppd.effective_start_date 		ppd_effective_start_date
, tbi.pps_number 			pps_number_int
, asg.assignment_number 			employee_no_int   --5724436
, tbi.first_name 			first_name_int
, tbi.last_name 			last_name_int
, tbi.cert_start_date 			cert_start_date
, tbi.cert_end_date 			cert_end_date
, tbi.cert_date 			cert_date
, tbi.wk_tax_credit/100			wk_tax_credit
, tbi.mth_tax_credit/100 		mth_tax_credit
, tbi.wk_rate_cutoff/100 		wk_rate_cutoff
, tbi.mth_rate_cutoff/100 		mth_rate_cutoff
-- Bug Fix 3500192
, tbi.wk_mth_indicator			wk_mth_indicator
-- Bug Fix 4618981
, tbi.exemption_indicator		exemption_indicator
, tbi.tot_tax_to_date/100		tot_tax_to_date
, tbi.tot_pay_to_date/100		tot_pay_to_date
, tbi.std_rate_of_tax			std_rate_of_tax
, tbi.higher_rate_of_tax		higher_rate_of_tax
FROM hr_organization_information hoi
, hr_organization_units hou
, per_all_assignments_f asg
, per_all_people_f per
, pay_all_payrolls_f pay
--, pay_ie_paye_details_f ppd
, pay_ie_tax_body_interface tbi
, pay_ie_tax_header_interface thi
WHERE per.person_id = asg.person_id
AND per.national_identifier = tbi.pps_number
AND asg.business_group_id = hou.business_group_id
AND hou.organization_id   = hoi.organization_id
AND hoi.org_information_context = 'IE_EMPLOYER_INFO' -- For Employer changes 4369280
AND hoi.org_information2 = p_employer_number
AND pay.payroll_id = nvl(p_payroll_id,pay.payroll_id)
AND asg.payroll_id = pay.payroll_id
--AND asg.assignment_id = ppd.assignment_id
AND per.national_identifier = p_pps_number
-- Bug Fix 3500192
-- added for multiple assignment issue 5894942
AND asg.assignment_number = tbi.works_number
AND thi.employer_number = p_employer_number
AND thi.tax_year = p_tax_year
AND tbi.employer_number = thi.employer_number
AND tbi.process_flag = 'Y'
AND asg.effective_start_date <= to_date('31/12/'||to_char(tbi.cert_start_date,'YYYY'),'dd/mm/yyyy')
AND asg.effective_end_date >= trunc(tbi.cert_start_date)
AND per.effective_start_date <= to_date('31/12/'||to_char(tbi.cert_start_date,'YYYY'),'dd/mm/yyyy')
AND per.effective_end_date >= trunc(tbi.cert_start_date)
AND pay.effective_start_date <= to_date('31/12/'||to_char(tbi.cert_start_date,'YYYY'),'dd/mm/yyyy')
AND pay.effective_end_date >= trunc(tbi.cert_start_date);
--bug 6376140
/*Declare cursor to retrieve all employee details from payroll
and interface tables based on input parameters for a single assignment*/
CURSOR c_pay1(p_pps_number varchar) IS
SELECT distinct per.employee_number 		employee_no_hr
, per.national_identifier 		pps_number_hr
, per.last_name 			last_name_hr
, per.first_name 			first_name_hr
, asg.assignment_id 			assignment_id
--, asg.effective_start_date 		effective_start_date
, hoi.org_information1 			tax_district
, pay.payroll_name 			payroll_name_hr
, pay.payroll_id				payroll_id		-- 4878630
--, ppd.paye_details_id 			paye_details_id  --4878630
--, ppd.object_version_number 		object_version_no --4878630
--, ppd.effective_start_date 		ppd_effective_start_date
, tbi.pps_number 			pps_number_int
, asg.assignment_number 			employee_no_int   --5724436
, tbi.first_name 			first_name_int
, tbi.last_name 			last_name_int
, tbi.cert_start_date 			cert_start_date
, tbi.cert_end_date 			cert_end_date
, tbi.cert_date 			cert_date
, tbi.wk_tax_credit/100			wk_tax_credit
, tbi.mth_tax_credit/100 		mth_tax_credit
, tbi.wk_rate_cutoff/100 		wk_rate_cutoff
, tbi.mth_rate_cutoff/100 		mth_rate_cutoff
-- Bug Fix 3500192
, tbi.wk_mth_indicator			wk_mth_indicator
-- Bug Fix 4618981
, tbi.exemption_indicator		exemption_indicator
, tbi.tot_tax_to_date/100		tot_tax_to_date
, tbi.tot_pay_to_date/100		tot_pay_to_date
, tbi.std_rate_of_tax			std_rate_of_tax
, tbi.higher_rate_of_tax		higher_rate_of_tax
FROM hr_organization_information hoi
, hr_organization_units hou
, per_all_assignments_f asg
, per_all_people_f per
, pay_all_payrolls_f pay
--, pay_ie_paye_details_f ppd
, pay_ie_tax_body_interface tbi
, pay_ie_tax_header_interface thi,
per_periods_of_service pps
WHERE per.person_id = asg.person_id
AND per.national_identifier = tbi.pps_number
AND asg.business_group_id = hou.business_group_id
AND hou.organization_id   = hoi.organization_id
AND hoi.org_information_context = 'IE_EMPLOYER_INFO' -- For Employer changes 4369280
AND hoi.org_information2 = p_employer_number
AND pay.payroll_id = nvl(p_payroll_id,pay.payroll_id)
AND asg.payroll_id = pay.payroll_id
--AND asg.assignment_id = ppd.assignment_id
AND per.national_identifier = p_pps_number
-- Bug Fix 3500192
-- added for multiple assignment issue 5894942
--AND asg.assignment_number = tbi.works_number
AND thi.employer_number = p_employer_number
AND thi.tax_year = p_tax_year
AND tbi.employer_number = thi.employer_number
AND tbi.process_flag = 'Y'
and asg.period_of_service_id=pps.period_of_service_id
and pps.person_id=per.person_id
--and pps.date_start <= to_date('31/12/'||to_char(tbi.cert_start_date,'YYYY'),'dd/mm/yyyy')
and pps.period_of_service_id in (select max(pps1.period_of_service_id) from per_periods_of_service pps1 where pps1.person_id=pps.person_id and pps1.date_start <= to_date('31/12/'||to_char(tbi.cert_start_date,'YYYY'),'dd/mm/yyyy'))
AND asg.effective_start_date <= to_date('31/12/'||to_char(tbi.cert_start_date,'YYYY'),'dd/mm/yyyy')
AND asg.effective_end_date >= trunc(tbi.cert_start_date)
AND per.effective_start_date <= to_date('31/12/'||to_char(tbi.cert_start_date,'YYYY'),'dd/mm/yyyy')
AND per.effective_end_date >= trunc(tbi.cert_start_date)
AND pay.effective_start_date <= to_date('31/12/'||to_char(tbi.cert_start_date,'YYYY'),'dd/mm/yyyy')
AND pay.effective_end_date >= trunc(tbi.cert_start_date);

-- cursor get the skipped assignments. Assignments that didnt get processed
-- in the process
--bug 6376140 cursor modified for processing single assg
/* cursor csr_skipped_asg is
select pps_number, works_number from pay_ie_tax_body_interface
minus
SELECT distinct per.national_identifier pps_number, asg.assignment_number works_number
FROM hr_organization_information hoi
, hr_organization_units hou
, per_all_assignments_f asg
, per_all_people_f per
, pay_all_payrolls_f pay
--, pay_ie_paye_details_f ppd
, pay_ie_tax_body_interface tbi
, pay_ie_tax_header_interface thi
WHERE per.person_id = asg.person_id
AND asg.business_group_id = hou.business_group_id
AND hou.organization_id   = hoi.organization_id
AND hoi.org_information_context = 'IE_EMPLOYER_INFO'
AND hoi.org_information2 = p_employer_number
AND pay.payroll_id = nvl(p_payroll_id,pay.payroll_id)
AND asg.payroll_id = pay.payroll_id
AND per.national_identifier = tbi.pps_number
AND asg.assignment_number = tbi.works_number
AND thi.employer_number = p_employer_number
AND thi.tax_year = p_tax_year
AND tbi.employer_number = thi.employer_number
AND tbi.process_flag = 'Y'
AND asg.effective_start_date <= to_date('31/12/'||to_char(tbi.cert_start_date,'YYYY'),'dd/mm/yyyy')
AND asg.effective_end_date >= trunc(tbi.cert_start_date)
AND per.effective_start_date <= to_date('31/12/'||to_char(tbi.cert_start_date,'YYYY'),'dd/mm/yyyy')
AND per.effective_end_date >= trunc(tbi.cert_start_date)
AND pay.effective_start_date <= to_date('31/12/'||to_char(tbi.cert_start_date,'YYYY'),'dd/mm/yyyy')
AND pay.effective_end_date >= trunc(tbi.cert_start_date); */

cursor csr_skipped_assignments is
select distinct pps_number pps_number,works_number,last_name,first_name
from pay_ie_tax_body_interface;

/* check to see if any single paye details exists */
cursor get_paye_details (p_assignment_id number) is
select count(*) from pay_ie_paye_details_f where
assignment_id = p_assignment_id;

-- For Bug 5724436
-- Cursor to get the max assignment action id, to fetch the P45 details.
cursor get_p45_details (p_assignment_id	number) is
select fnd_number.canonical_to_number(substr(max(lpad(paa.action_sequence,15,'0')||paa.assignment_action_id),16)) aa
from   pay_assignment_actions paa,
       pay_payroll_actions ppa
where  ppa.payroll_action_id = paa.payroll_action_id
and    paa.assignment_id = p_assignment_id
and    to_number(to_char(ppa.effective_date,'YYYY')) = p_tax_year;

-- Cursor to fetch existing PAYE details.
cursor c_get_paye_details(p_assignment_id	number
				 ,p_ppsn		varchar2
				 ,p_cert_start_date	date
				 ,p_assignment_number varchar2) is
select distinct ppd.*
from  per_all_people_f papf,
      per_all_assignments_f paaf,
      pay_ie_paye_details_f ppd
where papf.national_identifier = p_ppsn
and   papf.person_id = paaf.person_id
and   paaf.assignment_id = p_assignment_id
and   paaf.assignment_id = ppd.assignment_id
and   paaf.assignment_number = p_assignment_number
AND paaf.effective_start_date <= to_date('31/12/'||to_char(p_cert_start_date,'YYYY'),'dd/mm/yyyy')
AND paaf.effective_end_date >= trunc(p_cert_start_date)
AND papf.effective_start_date <= to_date('31/12/'||to_char(p_cert_start_date,'YYYY'),'dd/mm/yyyy')
AND papf.effective_end_date >= trunc(p_cert_start_date)
AND ppd.effective_start_date <= to_date('31/12/'||to_char(p_cert_start_date,'YYYY'),'dd/mm/yyyy')
AND ppd.effective_end_date >= trunc(p_cert_start_date);

-- Cursor to see if payroll exists for an assignment.
CURSOR csr_pay_freq (p_assignment_id NUMBER,
			   p_effective_date DATE) IS
   SELECT pp.period_type
   FROM pay_payrolls_f pp, per_assignments_f pa
   WHERE pa.assignment_id = p_assignment_id
   AND   p_effective_date BETWEEN pa.effective_start_date AND pa.effective_end_date
   AND   pp.payroll_id = pa.payroll_id
   AND   p_effective_date BETWEEN pp.effective_start_date AND pp.effective_end_date;

pay_freq_rec csr_pay_freq%ROWTYPE;

-- cursor get values from globals bug 5766334
cursor csr_get_global_value(p_global_name varchar2,
                            p_cert_date date) is
select global_value
from   ff_globals_f
where  global_name = p_global_name
and    p_cert_date between effective_start_date and effective_end_date;

l_tax_rate_exempt	ff_globals_f.global_value%TYPE;
l_tax_rate_high	ff_globals_f.global_value%TYPE;
--bug 6376140
--follw variables are added
r_pay  c_pay%rowtype;
TYPE t_pps_number IS TABLE OF varchar2(30) INDEX BY Binary_Integer;
l_pps_number	t_pps_number;
ppsno_cnt number :=0;
flag char :='N';
--end of bug 6376140
-- End bug 5766334

--Declare variables
l_error 				VARCHAR2(2000);
l_error_stack 			VARCHAR2(2000) := NULL;
l_request_id 			NUMBER;
l_program_application_id 	NUMBER;
l_program_id 			NUMBER;
l_comm_period_no 			NUMBER;
l_pps_number_hr 			VARCHAR2(9);
l_employee_number_hr 		per_all_people_F.employee_number%TYPE;  -- bug 5766372
l_last_name_hr 			per_people_f.last_name%TYPE;
l_first_name_hr 			per_people_f.first_name%TYPE;
l_last_name_int 			VARCHAR2(20);
l_first_name_int 			VARCHAR2(20);
l_payroll_name_hr 		VARCHAR2(80);
l_tax_district 			NUMBER;
l_pps_number_int 			VARCHAR2(9);
l_employee_number_int 		per_all_assignments_f.assignment_number%TYPE; -- bug 5766372
l_validate				BOOLEAN   := FALSE;
-- Bug Fix 3500192
l_datetrack_mode              VARCHAR2(12);
l_tax_basis                   pay_ie_paye_details_f.tax_basis%TYPE; -- bug 5766372
l_header_count			NUMBER := 0;
l_record_count			NUMBER := 0;
l_std_rate_of_tax			pay_ie_tax_body_interface.std_rate_of_tax%TYPE;
l_higher_rate_of_tax		pay_ie_tax_body_interface.higher_rate_of_tax%TYPE;

--Declare output parameters from api row handlersb
l_ins_paye_details_id 		NUMBER;
l_ins_object_version_no 	NUMBER;
l_ins_effective_start_date 	DATE;
l_ins_effective_end_date 	DATE;
l_upd_effective_start_date 	DATE;
l_upd_effective_end_date 	DATE;
l_flag number;

-- Bug Fix 3500192
-- name_not_equal 		EXCEPTION;
-- same_day 			EXCEPTION;
future_day 				EXCEPTION;
std_rate_of_tax_is_null		EXCEPTION;
higher_rate_of_tax_is_null	EXCEPTION;
exemption_is_null			EXCEPTION;
exemption_mismatch		EXCEPTION;
normal_tax_mismatch		EXCEPTION;
pay_to_date				EXCEPTION;
l_paye_count			NUMBER(3);
o_paye_details_id			NUMBER;
o_ovn					NUMBER;
o_effective_start_date		DATE;
o_effective_end_date		DATE;
l_effective_date DATE; -- Bug 6929566

l_tax_to_date			NUMBER;
l_pay_to_date			NUMBER;
l_max_action_id			NUMBER := 0;
r_paye_details			c_get_paye_details%ROWTYPE;
r_empty_details			c_get_paye_details%ROWTYPE;

BEGIN
l_request_id 	:= FND_GLOBAL.CONC_REQUEST_ID;
retcode 	:= 1;
-- Bug 5724436, the audit report will be called only in mode="Validate"
IF p_validate_mode <> 'IE_VALIDATE' THEN
	fnd_file.put_line(fnd_file.output,lpad('PPS Number',11, ' ')||lpad('Works Number',15,' ')||lpad('Status',30,' ')); --4878630
	fnd_file.put_line(fnd_file.output,lpad('----------',11, ' ')||lpad('------------',15,' ')||lpad('------',30,' '));
ELSE
-- bug 5724436
-- This is called only once to set the report fields.
	fnd_file.put_line(fnd_file.output,'Index');
	fnd_file.put_line(fnd_file.output,'I    :- Week1/Month1 Indicator');
	fnd_file.put_line(fnd_file.output,'F    :- Exemption Flag');
	fnd_file.put_line(fnd_file.output,'Tax1 :- Standard Rate of Tax');
	fnd_file.put_line(fnd_file.output,'Tax2 :- Higher Rate of Tax');
	fnd_file.put_line(fnd_file.output,' ');

	fnd_file.put_line(fnd_file.output,lpad('PAYE Details in Oracle Payroll',70,' ')||lpad('PAYE Details from Revenue',105,' '));
	fnd_file.put_line(fnd_file.output,lpad('==============================',70,' ')||lpad('=========================',105,' '));
	fnd_file.put_line(fnd_file.output,' ');
	fnd_file.put_line(fnd_file.output,lpad('PPS Number',11,' ')
						   -- for previous PAYE Details
						   || lpad('Works',13,' ')
						   || lpad('Last Name',16,' ')
						   || lpad('I',3,' ')||lpad('F',3,' ')
	                                 || lpad('Mth Std',9,' ')||lpad('Mth Tax',9,' ')
						   || lpad('Week Std',10,' ')||lpad('Week Tax',10,' ')
						   || lpad('Cert Issue',12,' ')||lpad('Tot Pay',12,' ')
						   || lpad('Tot Tax',12,' ')||lpad('Tax1',6,' ')
						   || lpad('Tax2',6,' ')|| lpad(' ',10,' ')
						   -- for Current PAYE Details
						   || lpad('I',3,' ')||lpad('F',3,' ')
	                                 || lpad('Mth Std',9,' ')||lpad('Mth Tax',9,' ')
						   || lpad('Week Std',10,' ')||lpad('Week Tax',10,' ')
						   || lpad('Cert Issue',12,' ')||lpad('Tot Pay',12,' ')
						   || lpad('Tot Tax',12,' ')||lpad('Tax1',6,' ')
						   || lpad('Tax2',6,' '));

	fnd_file.put_line(fnd_file.output,  lpad('Number',24,' ')
	                                 || lpad('Cutoff',30,' ')||lpad('Credit',9,' ')
						   || lpad('Cutoff',10,' ')||lpad('Credit',10,' ')
						   || lpad('Date',10,' ')||lpad('to Date',15,' ')
						   || lpad('to Date',12,' ') ||lpad(' ',28,' ')
						   -- for Current PAYE Details
						   || lpad('Cutoff',8,' ')||lpad('Credit',9,' ')
						   || lpad('Cutoff',10,' ')||lpad('Credit',10,' ')
						   || lpad('Date',10,' ')||lpad('to Date',15,' ')
						   || lpad('to Date',12,' '));

	fnd_file.put_line(fnd_file.output,lpad('----------',11,' ')
						   -- for previous PAYE Details
						   || lpad('----------',13,' ')
						   || lpad('---------',16,' ')
						   || lpad('-',3,' ')||lpad('-',3,' ')
	                                 || lpad('-------',9,' ')||lpad('-------',9,' ')
						   || lpad('--------',10,' ')||lpad('--------',10,' ')
						   || lpad('----------',12,' ')||lpad('-------',12,' ')
						   || lpad('-------',12,' ')||lpad('----',6,' ')
						   || lpad('----',6,' ')|| lpad(' ',10,' ')
						   -- for Current PAYE Details
						   || lpad('-',3,' ')||lpad('-',3,' ')
	                                 || lpad('-------',9,' ')||lpad('-------',9,' ')
						   || lpad('--------',10,' ')||lpad('--------',10,' ')
						   || lpad('----------',12,' ')||lpad('-------',12,' ')
						   || lpad('-------',12,' ')||lpad('----',6,' ')
						   || lpad('----',6,' '));

	g_validate_count := 1;
END IF;
-- END 5724436
--BUG 6652299 ADDED L_FLAG
    FOR r_no_of_assg IN c_no_of_assg
    LOOP
    BEGIN
    l_flag :=0;
--bug 6376140
        IF r_no_of_assg.no_of_assg =1
            THEN OPEN c_pay1(r_no_of_assg.pps_number);
                    FETCH c_pay1 INTO r_pay;
                        IF c_pay1%FOUND THEN
                            l_flag:=1;
                        END IF;
                 CLOSE c_pay1;
        ELSIF  r_no_of_assg.no_of_assg >1
            THEN OPEN c_pay(r_no_of_assg.pps_number);
                    FETCH c_pay INTO r_pay;
                        IF c_pay%FOUND THEN
                            l_flag:=1;
                        END IF;
            CLOSE c_pay;
        END IF;
--end if;

--end of bug 6376140


-- Bug 6929566 Start
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'r_pay.cert_date is ' || r_pay.cert_date);
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'r_pay.cert_start_date is ' || r_pay.cert_start_date);
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'r_pay.cert_end_date is ' || r_pay.cert_end_date);
		IF r_pay.cert_date < r_pay.cert_start_date THEN
            l_effective_date := r_pay.cert_start_date;
        ELSIF r_pay.cert_date >= r_pay.cert_start_date THEN
            l_effective_date := r_pay.cert_date;
        END IF;
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'l_effective_date is ' || l_effective_date);
        --
-- Bug 6929566 End

--FOR r_pay IN c_pay
--LOOP
--BEGIN
--IF r_pay.pps_number_hr IS NOT NULL THEN
	--Initialize local variables on each loop pass to pass to outer exception handler
   IF l_flag=1 THEN
	l_pps_number_hr		:= r_pay.pps_number_hr;
	l_employee_number_hr	:= r_pay.employee_no_hr;
	l_first_name_hr		:= r_pay.first_name_hr;
	l_last_name_hr		:= r_pay.last_name_hr;
	l_payroll_name_hr		:= r_pay.payroll_name_hr;
	l_tax_district		:= r_pay.tax_district;
	l_pps_number_int		:= r_pay.pps_number_int;
	l_employee_number_int	:= r_pay.employee_no_int;
	--l_ins_object_version_no := r_pay.object_version_no;
	l_std_rate_of_tax		:= r_pay.std_rate_of_tax;
	l_higher_rate_of_tax	:= r_pay.higher_rate_of_tax;
	--bug 6376140
	--ppsno_cnt := ppsno_cnt+1;
	  IF l_pps_number_hr IS NOT NULL THEN
	 ppsno_cnt := ppsno_cnt+1;
	l_pps_number(ppsno_cnt)	:=r_pay.pps_number_hr;
	--fnd_file.put_line(l_pps_number(ppsno_cnt));
	hr_utility.set_location('PPS Number..'||l_pps_number_hr,420);
	-- checks for standard rate tax to be mandatory
	IF l_std_rate_of_tax IS NULL  THEN
		raise std_rate_of_tax_is_null;
	END IF; --l_std_rate_of_tax
	-- checks for higher rate of tax to be mandatory
	IF l_higher_rate_of_tax IS NULL  THEN
		raise higher_rate_of_tax_is_null;
	END IF;--l_higher_rate_of_tax
	-- checks for exemption indicator to be mandatory
	IF r_pay.exemption_indicator is null  then
		raise exemption_is_null; --r_pay.exemption_indicator
	END IF;
	-- checks for exact rate of tax bug 5766334
	open csr_get_global_value('IE_TAX_RATE_EXEMPT',l_effective_date);  -- Bug 6929566
	FETCH csr_get_global_value into l_tax_rate_exempt;
	CLOSE csr_get_global_value;

	open csr_get_global_value('IE_TAX_RATE2', l_effective_date); -- Bug 6929566
	FETCH csr_get_global_value into l_tax_rate_high;
	CLOSE csr_get_global_value;

	-- end bug 5766334


	IF r_pay.exemption_indicator='Y' AND r_pay.higher_rate_of_tax <> l_tax_rate_exempt then
		raise exemption_mismatch;
	END IF; --r_pay.exemption_indicator
	-- checks for exact rate of tax
	IF r_pay.exemption_indicator='N' AND r_pay.higher_rate_of_tax <> l_tax_rate_high then
		raise normal_tax_mismatch;
	END IF;  --r_pay.exemption_indicator
      hr_utility.set_location('PPS Number..Initial check'||l_pps_number_hr,421);
	hr_utility.set_location('Assignment Number..'||r_pay.employee_no_int,101);
	--
	IF r_pay.tot_pay_to_date is null and r_pay.tot_pay_to_date is null and
	   (r_pay.wk_mth_indicator = 0 or (r_pay.wk_mth_indicator=1 and r_pay.exemption_indicator='Y')) then
	   raise pay_to_date;
	END IF;
	hr_utility.set_location('PPS Number..Second check'||l_pps_number_hr,422);

--  check if cerificate start date is before or equal to certificate end date

	pay_ipd_bus.chk_cert_start_end_dates(
	  p_certificate_start_date    =>  	r_pay.cert_start_date
	, p_certificate_end_date      =>  	r_pay.cert_end_date
	);
	hr_utility.set_location('PPS Number..third check'||l_pps_number_hr,423);
	hr_utility.set_location('Assignment Number..'||r_pay.employee_no_int,102);
-- Bug Fix 3500192
-- tax basis is set as per the value of week month indicator in the interface table
    IF (r_pay.wk_mth_indicator = 1) THEN
        l_tax_basis := 'IE_WEEK1_MONTH1';
    ELSE
        l_tax_basis := 'IE_CUMULATIVE';
    END IF;
    -- Bug Fix 4618981
    IF r_pay.exemption_indicator='Y' then
	IF r_pay.wk_mth_indicator = 1 THEN
	  l_tax_basis := 'IE_EXEMPT_WEEK_MONTH';
	ELSE
    	  l_tax_basis := 'IE_EXEMPTION';
	END IF;
    END IF;

	hr_utility.set_location('l_tax_basis'||l_tax_basis,424);
	hr_utility.set_location('Assignment Number..'||r_pay.employee_no_int,103);
--    check if amounts are valid for the given tax basis, for 'Emergency'
--    tax basis weekly and monthly tax credits ans std rate cut-off amounts must
--    be null and for other values of tax basis weekly or monthly amounts
--    (depending on payroll frequency) must be not null.

	/*pay_ipd_bus.chk_tax_basis_amounts(
	  p_effective_date 			  =>	r_pay.cert_start_date
	, p_assignment_id  		  	  =>	r_pay.assignment_id
	-- Bug Fix 3500192
	--, p_tax_basis				  =>	'IE_CUMULATIVE'
	, p_tax_basis				  =>	l_tax_basis
	, p_weekly_tax_credit		  =>    r_pay.wk_tax_credit
	, p_weekly_std_rate_cut_off	  =>	r_pay.wk_rate_cutoff
	, p_monthly_tax_credit		  => 	r_pay.mth_tax_credit
	, p_monthly_std_rate_cut_off	  => 	r_pay.mth_rate_cutoff
	);*/

	hr_utility.set_location('pay_ipd_bus.chk_tax_basis_amounts'||l_pps_number_hr,424);
	hr_utility.set_location('Assignment Number..'||r_pay.employee_no_int,104);
	/* If the validate mode is 'Validate and Rollback' then set the validation input paramter
	to true else for all modes it is set to false*/

	IF p_validate_mode = 'IE_VALIDATE_ROLLBACK' THEN
		l_validate := TRUE;
	ELSE
		l_validate := FALSE;
	END IF;

--IF (r_pay.paye_details_id IS NOT NULL AND
  IF 	(p_validate_mode = 'IE_VALIDATE_ROLLBACK' OR p_validate_mode = 'IE_VALIDATE_COMMIT') THEN
	hr_utility.set_location('PPS Number..'||l_pps_number_hr,425);
 	hr_utility.set_location('Assignment Number..'||r_pay.employee_no_int,105);
	OPEN get_paye_details(r_pay.assignment_id);
	FETCH get_paye_details INTO l_paye_count;
	CLOSE get_paye_details;
	-- to check if the payroll is attached to the assignment as of certificate
	-- issue date. This is called irrespective of whether PAYE details exists
	-- or not.
	pay_ipd_bus.chk_tax_basis_amounts(
			 p_effective_date 		  =>	l_effective_date -- Bug 6929566 -- r_pay.cert_date -- 5396580
			,p_assignment_id  		  =>	r_pay.assignment_id
			-- Bug Fix 3500192
			--	, p_tax_basis		  =>	'IE_CUMULATIVE'
			,p_tax_basis			  =>	l_tax_basis
			,p_weekly_tax_credit		  =>  r_pay.wk_tax_credit
			,p_weekly_std_rate_cut_off	  =>	r_pay.wk_rate_cutoff
			,p_monthly_tax_credit		  => 	r_pay.mth_tax_credit
			,p_monthly_std_rate_cut_off	  => 	r_pay.mth_rate_cutoff
			);
	IF l_paye_count <> 0 THEN
		hr_utility.set_location('l_paye_count <> 0'||l_pps_number_hr,426);


  hr_utility.set_location(r_pay.cert_date, 10);

		pay_ie_paye_pkg.update_paye_change_freq --4878630
			(p_assignment_id			=> r_pay.assignment_id
			,p_effective_date			=> l_effective_date -- Bug 6929566 -- r_pay.cert_date -- 5724436
			,p_payroll_id			=> r_pay.payroll_id
			,P_DATETRACK_UPDATE_MODE	=> 'UPDATE'
			,p_tax_upload_flag		=> 'TU'
			,p_tax_basis			=> l_tax_basis
			,p_cert_start_date		=> r_pay.cert_start_date -- 17140460.6
			,p_cert_end_date			=> r_pay.cert_end_date
			,p_weekly_tax_credit		=> r_pay.wk_tax_credit
			,p_monthly_tax_credit		=> r_pay.mth_tax_credit
			,p_weekly_std_rate_cut_off	=> r_pay.wk_rate_cutoff
			,p_monthly_std_rate_cut_off	=> r_pay.mth_rate_cutoff
			,p_tax_deducted_to_date		=> r_pay.tot_tax_to_date
			,p_pay_to_date			=> r_pay.tot_pay_to_date
			,p_cert_date                    =>r_pay.cert_date);

		 hr_utility.set_location(r_pay.cert_date, 20);
		hr_utility.set_location('l_paye_count <> 0'||l_pps_number_hr,427);
	ELSE
		hr_utility.set_location('l_paye_count = 0'||l_pps_number_hr,428);
		 hr_utility.set_location(r_pay.cert_date, 30);
		pay_ie_paye_api.create_ie_paye_details --4878630
			(p_validate                      => false
			,p_effective_date                => l_effective_date -- Bug 6929566
			,p_assignment_id                 => r_pay.assignment_id
			,p_info_source                   => 'IE_ELECTRONIC'
			,p_tax_basis                     => l_tax_basis
			,p_certificate_start_date        => r_pay.cert_start_date -- For bug 5396549
			,p_tax_assess_basis              => 'IE_SEP_TREAT'
			,p_certificate_issue_date        => r_pay.cert_date
			,p_certificate_end_date          => r_pay.cert_end_date
			,p_weekly_tax_credit             => r_pay.wk_tax_credit
			,p_weekly_std_rate_cut_off       => r_pay.wk_rate_cutoff
			,p_monthly_tax_credit            => r_pay.mth_tax_credit
			,p_monthly_std_rate_cut_off      => r_pay.mth_rate_cutoff
			,p_tax_deducted_to_date          => r_pay.tot_tax_to_date
			,p_pay_to_date                   => r_pay.tot_pay_to_date
			,p_disability_benefit            => null
			,p_lump_sum_payment              => null
			,p_paye_details_id               => o_paye_details_id
			,p_object_version_number         => o_ovn
			,p_effective_start_date          => o_effective_start_date
			,p_effective_end_date            => o_effective_end_date);
		 hr_utility.set_location(r_pay.cert_date, 40);
  		hr_utility.set_location('l_paye_count = 0'||l_pps_number_hr,429);
	END IF;
END IF;
hr_utility.set_location('Assignment Number..'||r_pay.employee_no_int,106);
retcode := 0;


/*Update interface table and set processed flag to 'Yes' to record that record has been updated or
inserted into payroll tables successfully using the row handler APIs.*/

IF (p_validate_mode = 'IE_VALIDATE_COMMIT') THEN
	UPDATE pay_ie_tax_body_interface
	SET processed_flag = 'Y'
	WHERE pps_number  = r_pay.pps_number_int;
END IF;
hr_utility.set_location('Assignment Number..'||r_pay.employee_no_int,107);
IF p_validate_mode <> 'IE_VALIDATE' THEN
	fnd_file.put_line(fnd_file.output,lpad(r_pay.pps_number_int,11,' ')||lpad(substr(r_pay.employee_no_int,1,12),13,' ')||lpad(' ',20,' ')||'Success');
ELSE
	IF g_validate_count =1 then
		hr_utility.set_location('PPS Number..Second check'||l_pps_number_hr,841);
		hr_utility.set_location('Assignment Number..'||r_pay.employee_no_int,108);
		OPEN c_get_paye_details(r_pay.assignment_id,
						r_pay.pps_number_int,
						l_effective_date, -- Bug 6929566 -- r_pay.cert_date,
						r_pay.employee_no_int);
		FETCH c_get_paye_details INTO r_paye_details;
		-- IF no PAYE details exists then set the default values for PAYE.
		IF c_get_paye_details%ROWCOUNT = 0 then
			r_paye_details.tax_basis := 'IE_EMERGENCY';
			r_paye_details.certificate_issue_date := to_date('01/01/0001','dd/mm/yyyy');
			r_paye_details.WEEKLY_TAX_CREDIT := 0;
			r_paye_details.WEEKLY_STD_RATE_CUT_OFF := 0;
			r_paye_details.MONTHLY_TAX_CREDIT := 0;
			r_paye_details.MONTHLY_STD_RATE_CUT_OFF := 0;
			-- bug 5837091
		ELSIF r_paye_details.tax_basis in ('IE_EMERGENCY','IE_EMERGENCY_NO_PPS') then
			r_paye_details.certificate_issue_date := nvl(to_date(to_char(r_paye_details.certificate_issue_date,'dd-mm-yyyy'),'dd-mm-yyyy'),to_date('01/01/0001','dd/mm/yyyy'));
			r_paye_details.WEEKLY_TAX_CREDIT := 0;
			r_paye_details.WEEKLY_STD_RATE_CUT_OFF := 0;
			r_paye_details.MONTHLY_TAX_CREDIT := 0;
			r_paye_details.MONTHLY_STD_RATE_CUT_OFF := 0;
		else
			r_paye_details.certificate_issue_date := nvl(to_date(to_char(r_paye_details.certificate_issue_date,'dd-mm-yyyy'),'dd-mm-yyyy'),to_date('01/01/0001','dd/mm/yyyy'));
			r_paye_details.WEEKLY_TAX_CREDIT := nvl(r_paye_details.WEEKLY_TAX_CREDIT,0);
			r_paye_details.WEEKLY_STD_RATE_CUT_OFF := nvl(r_paye_details.WEEKLY_STD_RATE_CUT_OFF,0);
			r_paye_details.MONTHLY_TAX_CREDIT := nvl(r_paye_details.MONTHLY_TAX_CREDIT,0);
			r_paye_details.MONTHLY_STD_RATE_CUT_OFF := nvl(r_paye_details.MONTHLY_STD_RATE_CUT_OFF,0);
		END IF;
		-- end bug 5837091
		CLOSE c_get_paye_details;
		hr_utility.set_location('PPS Number..Second check'||l_pps_number_hr,842);

		OPEN csr_pay_freq (r_pay.assignment_id,l_effective_date); -- Bug 6929566 --r_pay.cert_date);
		FETCH csr_pay_freq INTO pay_freq_rec;
		   --
	      IF csr_pay_freq%NOTFOUND THEN
			CLOSE csr_pay_freq;
			hr_utility.set_message(801, 'HR_IE_ASG_NOT_IN_PAYROLL');
			hr_utility.raise_error;
		END IF;
   --
		CLOSE csr_pay_freq;
		hr_utility.set_location('PPS Number..Second check'||l_pps_number_hr,843);

		hr_utility.set_location('Assignment Number..'||r_pay.employee_no_int,109);
		OPEN get_p45_details(r_pay.assignment_id);
		FETCH get_p45_details INTO l_max_action_id;
		CLOSE get_p45_details;

		hr_utility.set_location('Assignment Number..'||r_pay.employee_no_int,110);
		hr_utility.set_location('Assignment Action ID..'||l_max_action_id,110);
		-- This will be called only if has any assignment actions.
		IF l_max_action_id <> 0 THEN
			hr_utility.set_location('Assignment Action ID is not null',112);
			l_pay_to_date := NVL (
						ROUND (
							TO_NUMBER (
								pay_balance_pkg.get_value (
									pay_ie_p35.get_defined_balance_id (
											'_ASG_YTD',
											'IE P45 Pay'
														    ),
										l_max_action_id
												  )
									),
								2
							  ),
							0
						    );
			l_tax_to_date := NVL (
						ROUND (
							TO_NUMBER (
								pay_balance_pkg.get_value (
									pay_ie_p35.get_defined_balance_id (
											'_ASG_YTD',
											'IE P45 Tax Deducted'
														    ),
										l_max_action_id
												  )
									),
								2
							  ),
							0
						    );
		ELSE
			hr_utility.set_location('Assignment Action ID is null',113);
			l_pay_to_date := 0;
			l_tax_to_date := 0;
		END IF;
	-- print the values.
	fnd_file.put_line(fnd_file.output,lpad(r_pay.pps_number_int,11,' ')
							   -- for previous PAYE Details
							   || lpad(substr(r_pay.employee_no_int,1,12),13,' ')
							   || lpad(substr(r_pay.last_name_hr,1,15),16,' ')
							   || lpad(pay_ie_paye_pkg.decode_value_char(r_paye_details.tax_basis='IE_WEEK1_MONTH1','1','0'),3,' ')
							   || lpad(pay_ie_paye_pkg.decode_value_char(r_paye_details.tax_basis='IE_EXEMPT_WEEK_MONTH' or r_paye_details.tax_basis='IE_EXEMPTION' ,'Y','N'),3,' ')
		                                 || lpad(r_paye_details.MONTHLY_STD_RATE_CUT_OFF,9,' ')||lpad(r_paye_details.MONTHLY_TAX_CREDIT,9,' ')
							   || lpad(r_paye_details.WEEKLY_STD_RATE_CUT_OFF,10,' ')||lpad(r_paye_details.WEEKLY_TAX_CREDIT,10,' ')
							   || lpad(pay_ie_paye_pkg.decode_value_char(to_char(r_paye_details.CERTIFICATE_ISSUE_DATE,'DDMMRRRR')=to_char(to_date('01/01/0001','dd/mm/yyyy'),'DDMMRRRR'),'NIL',to_char(r_paye_details.CERTIFICATE_ISSUE_DATE,'DD-mm-RRRR')),12,' ')
							   || lpad(to_char(l_pay_to_date),12,' ')
							   || lpad(to_char(l_tax_to_date),12,' ')||lpad('20',6,' ')
							   || lpad(pay_ie_paye_pkg.decode_value_char(r_paye_details.tax_basis='IE_EXEMPT_WEEK_MONTH' or r_paye_details.tax_basis='IE_EXEMPTION',l_tax_rate_exempt,l_tax_rate_high),6,' ')
							   || lpad(' ',10,' ')
							   -- for Current PAYE Details
							   || lpad(r_pay.wk_mth_indicator,3,' ')||lpad(r_pay.exemption_indicator,3,' ')
		                                 || lpad(r_pay.mth_rate_cutoff,9,' ')||lpad(r_pay.mth_tax_credit,9,' ')
							   || lpad(r_pay.wk_rate_cutoff,10,' ')||lpad(r_pay.wk_tax_credit,10,' ')
							   || lpad(to_char(r_pay.cert_date,'dd-mm-yyyy'),12,' ')||lpad(r_pay.tot_pay_to_date,12,' ')
							   || lpad(r_pay.tot_tax_to_date,12,' ')||lpad(r_pay.std_rate_of_tax,6,' ')
							   || lpad(r_pay.higher_rate_of_tax,6,' '));


	END IF;
	r_paye_details := r_empty_details;
  END IF;
 END IF;
    END IF;
-- end bug 5724436.
EXCEPTION
-- Bug Fix 3500192
--	WHEN name_not_equal THEN
--		l_error := SQLERRM;
--		retcode := 1;
--		FND_FILE.NEW_LINE(fnd_file.log, 1);
--		FND_FILE.PUT_LINE(fnd_file.log, 'The first name and last name in the interface body table does not match
--		the first and last name in the payroll tables');
--
--		FND_FILE.NEW_LINE(fnd_file.log, 1);
--		FND_FILE.PUT_LINE(fnd_file.output, r_pay.pps_number_hr ||','||
--		r_pay.employee_no_hr ||', '||
--		r_pay.last_name_hr ||' '||
--		r_pay.first_name_hr ||', '||
--		r_pay.last_name_int ||' '||
--		r_pay.first_name_int||', '||
--		r_pay.payroll_name_hr
--		);
--
--		-- The exception details are written to an error table
--
--		INSERT INTO pay_ie_tax_error ( pps_number
--		, employee_number
--		, full_name
--		, payroll_name
--		, tax_district
--		, error_stack_message
--		, error_message
--		, request_id
--		, error_date )
--		VALUES (r_pay.pps_number_hr
--		, r_pay.employee_no_hr
--		, r_pay.last_name_hr ||' '|| r_pay.first_name_hr
--		, r_pay.payroll_name_hr
--		, r_pay.tax_district
--		, l_error_stack
--		, l_error
--		, l_request_id
--		, sysdate);
--		COMMIT;
--
--	WHEN same_day THEN
--		l_error := SQLERRM;
--		retcode := 1;
--		FND_FILE.PUT_LINE(fnd_file.log, 'This record has already been updated today with changes to the
--		PAY_IE_PAYE_DETAILS_F table');
--
--
--		FND_FILE.NEW_LINE(fnd_file.log, 1);
--		FND_FILE.PUT_LINE(fnd_file.output, r_pay.pps_number_hr ||','||
--		r_pay.employee_no_hr ||', '||
--		r_pay.last_name_hr ||' '||
--		r_pay.first_name_hr ||', '||
--		r_pay.ppd_effective_start_date ||', '||
--		r_pay.payroll_name_hr
--		);
--
--		-- The exception details are written to an error table
--
--		INSERT INTO pay_ie_tax_error ( pps_number
--		, employee_number
--		, full_name
--		, payroll_name
--		, tax_district
--		, error_stack_message
--		, error_message
--		, request_id
--		, error_date )
--		VALUES (r_pay.pps_number_hr
--		, r_pay.employee_no_hr
--		, r_pay.last_name_hr ||' '|| r_pay.first_name_hr
--		, r_pay.payroll_name_hr
--		, r_pay.tax_district
--		, l_error_stack
--		, l_error
--		, l_request_id
--		, sysdate);
--		COMMIT;

	/*WHEN future_day THEN
		l_error := SQLERRM;
		retcode := 1;
		FND_FILE.PUT_LINE(fnd_file.log, 'This record has been updated to a future date');

		FND_FILE.NEW_LINE(fnd_file.log, 1);
		FND_FILE.PUT_LINE(fnd_file.output, r_pay.pps_number_hr ||','||
		r_pay.employee_no_hr ||', '||
		r_pay.last_name_hr ||' '||
		r_pay.first_name_hr ||', '||
		r_pay.payroll_name_hr
		);
		-- The exception details are written to an error table

		INSERT INTO pay_ie_tax_error ( pps_number
		, employee_number
		, full_name
		, payroll_name
		, tax_district
		, error_stack_message
		, error_message
		, request_id
		, error_date )
		VALUES (r_pay.pps_number_hr
		, r_pay.employee_no_hr
		, r_pay.last_name_hr ||' '|| r_pay.first_name_hr
		, r_pay.payroll_name_hr
		, r_pay.tax_district
		, l_error_stack
		, l_error
		, l_request_id
		, sysdate);
		COMMIT;*/

	WHEN std_rate_of_tax_is_null THEN
		l_error := 'Standard Rate of Tax cannot be Null';--SQLERRM;
		retcode := 1;
		FND_FILE.PUT_LINE(fnd_file.log, 'Standard Rate of Tax cannot be Null');

		FND_FILE.NEW_LINE(fnd_file.log, 1);
		/*FND_FILE.PUT_LINE(fnd_file.output, r_pay.pps_number_hr ||','||
		r_pay.employee_no_hr ||', '||
		r_pay.last_name_hr ||' '||
		r_pay.first_name_hr ||', '||
		r_pay.payroll_name_hr
		);*/
		--IF p_validate_mode in ('IE_VALIDATE') THEN
			l_err_tab(err_cnt).p_pps_number := r_pay.pps_number_int;
			l_err_tab(err_cnt).p_works_number := substr(r_pay.employee_no_int,1,12);
			l_err_tab(err_cnt).p_err_msg := 'Failed : Standard Rate of Tax cannot be Null';
			err_cnt := err_cnt + 1;
		--ELSE
		--	fnd_file.put_line(fnd_file.output,lpad(r_pay.pps_number_int,11,' ')||lpad(substr(r_pay.employee_no_int,1,12),13,' ')||lpad(' ',20,' ')||'Failed : Standard Rate of Tax cannot be Null');
		--END IF;
		-- The exception details are written to an error table

		INSERT INTO pay_ie_tax_error ( pps_number
		, employee_number
		, full_name
		, payroll_name
		, tax_district
		, error_stack_message
		, error_message
		, request_id
		, error_date )
		VALUES (r_pay.pps_number_hr
		, substr(r_pay.employee_no_int,1,12)
		, r_pay.last_name_hr ||' '|| r_pay.first_name_hr
		, r_pay.payroll_name_hr
		, r_pay.tax_district
		, l_error_stack
		, l_error
		, l_request_id
		, sysdate);
		COMMIT;

	WHEN higher_rate_of_tax_is_null THEN
		l_error := 'Higher Rate of Tax cannot be Null';--SQLERRM;
		retcode := 1;
		FND_FILE.PUT_LINE(fnd_file.log, 'Higher Rate of Tax cannot be Null');

		FND_FILE.NEW_LINE(fnd_file.log, 1);
		/*FND_FILE.PUT_LINE(fnd_file.output, r_pay.pps_number_hr ||','||
		r_pay.employee_no_hr ||', '||
		r_pay.last_name_hr ||' '||
		r_pay.first_name_hr ||', '||
		r_pay.payroll_name_hr
		);*/

		--IF p_validate_mode = 'IE_VALIDATE' THEN
			l_err_tab(err_cnt).p_pps_number := r_pay.pps_number_int;
			l_err_tab(err_cnt).p_works_number := substr(r_pay.employee_no_int,1,12);
			l_err_tab(err_cnt).p_err_msg := 'Failed : Higher Rate of Tax cannot be Null';
			err_cnt := err_cnt + 1;
		--ELSE
		--	fnd_file.put_line(fnd_file.output,lpad(r_pay.pps_number_int,11,' ')||lpad(substr(r_pay.employee_no_int,1,12),13,' ')||lpad(' ',20,' ')||'Failed : Higher Rate of Tax cannot be Null');
		--END IF;

		-- The exception details are written to an error table
		INSERT INTO pay_ie_tax_error ( pps_number
		, employee_number
		, full_name
		, payroll_name
		, tax_district
		, error_stack_message
		, error_message
		, request_id
		, error_date )
		VALUES (r_pay.pps_number_hr
		, substr(r_pay.employee_no_int,1,12)
		, r_pay.last_name_hr ||' '|| r_pay.first_name_hr
		, r_pay.payroll_name_hr
		, r_pay.tax_district
		, l_error_stack
		, l_error
		, l_request_id
		, sysdate);
		COMMIT;

	WHEN exemption_is_null THEN

		l_error := 'Exemption Indicator cannot be Null';--SQLERRM;
		retcode := 1;
		FND_FILE.PUT_LINE(fnd_file.log, 'Exemption Indicator cannot be Null');

		FND_FILE.NEW_LINE(fnd_file.log, 1);
		/*FND_FILE.PUT_LINE(fnd_file.output, r_pay.pps_number_hr ||','||
		r_pay.employee_no_hr ||', '||
		r_pay.last_name_hr ||' '||
		r_pay.first_name_hr ||', '||
		r_pay.payroll_name_hr
		);*/

		--IF p_validate_mode = 'IE_VALIDATE' THEN
			l_err_tab(err_cnt).p_pps_number := r_pay.pps_number_int;
			l_err_tab(err_cnt).p_works_number := substr(r_pay.employee_no_int,1,12);
			l_err_tab(err_cnt).p_err_msg := 'Failed : Exemption Indicator cannot be Null';
			err_cnt := err_cnt + 1;
		--ELSE
		--	fnd_file.put_line(fnd_file.output,lpad(r_pay.pps_number_int,11,' ')||lpad(substr(r_pay.employee_no_int,1,12),13,' ')||lpad(' ',20,' ')||'Failed : Exemption Indicator cannot be Null');
		--END IF;

		-- The exception details are written to an error table
		INSERT INTO pay_ie_tax_error ( pps_number
		, employee_number
		, full_name
		, payroll_name
		, tax_district
		, error_stack_message
		, error_message
		, request_id
		, error_date )
		VALUES (r_pay.pps_number_hr
		, substr(r_pay.employee_no_int,1,12)
		, r_pay.last_name_hr ||' '|| r_pay.first_name_hr
		, r_pay.payroll_name_hr
		, r_pay.tax_district
		, l_error_stack
		, l_error
		, l_request_id
		, sysdate);
		COMMIT;

	WHEN exemption_mismatch THEN
		l_error := 'The higher rate of tax for Exemption should be '||l_tax_rate_exempt||'%';--SQLERRM;
		retcode := 1;
		FND_FILE.PUT_LINE(fnd_file.log, 'The higher rate of tax for Exemption should be '||l_tax_rate_exempt||'%');

		FND_FILE.NEW_LINE(fnd_file.log, 1);
		/*FND_FILE.PUT_LINE(fnd_file.output, r_pay.pps_number_hr ||','||
		r_pay.employee_no_hr ||', '||
		r_pay.last_name_hr ||' '||
		r_pay.first_name_hr ||', '||
		r_pay.payroll_name_hr
		);*/

		--IF p_validate_mode = 'IE_VALIDATE' THEN
			l_err_tab(err_cnt).p_pps_number := r_pay.pps_number_int;
			l_err_tab(err_cnt).p_works_number := substr(r_pay.employee_no_int,1,12);
			l_err_tab(err_cnt).p_err_msg := 'Failed : The higher rate of tax for Exemption should be '||l_tax_rate_exempt||'%';
			err_cnt := err_cnt + 1;
		--ELSE
		--	fnd_file.put_line(fnd_file.output,lpad(r_pay.pps_number_int,11,' ')||lpad(substr(r_pay.employee_no_int,1,12),13,' ')||lpad(' ',20,' ')||'Failed : The higher rate of tax for Exemption should be '||l_tax_rate_exempt||'%');
		--END IF;

		-- The exception details are written to an error table
		INSERT INTO pay_ie_tax_error ( pps_number
		, employee_number
		, full_name
		, payroll_name
		, tax_district
		, error_stack_message
		, error_message
		, request_id
		, error_date )
		VALUES (r_pay.pps_number_hr
		, substr(r_pay.employee_no_int,1,12)
		, r_pay.last_name_hr ||' '|| r_pay.first_name_hr
		, r_pay.payroll_name_hr
		, r_pay.tax_district
		, l_error_stack
		, l_error
		, l_request_id
		, sysdate);
		COMMIT;

	WHEN normal_tax_mismatch THEN
		l_error := 'The higher rate of tax for Cumulative or Week1/Month1 Tax Basis should be '||l_tax_rate_high||'%';--SQLERRM;
		retcode := 1;
		FND_FILE.PUT_LINE(fnd_file.log, 'The higher rate of tax for Cumulative or Week1/Month1 Tax Basis should be '||l_tax_rate_high||'%');

		FND_FILE.NEW_LINE(fnd_file.log, 1);
		/*FND_FILE.PUT_LINE(fnd_file.output, r_pay.pps_number_hr ||','||
		r_pay.employee_no_hr ||', '||
		r_pay.last_name_hr ||' '||
		r_pay.first_name_hr ||', '||
		r_pay.payroll_name_hr
		);*/
		-- The exception details are written to an error table
		--IF p_validate_mode = 'IE_VALIDATE' THEN
			l_err_tab(err_cnt).p_pps_number := r_pay.pps_number_int;
			l_err_tab(err_cnt).p_works_number := substr(r_pay.employee_no_int,1,12);
			l_err_tab(err_cnt).p_err_msg := 'Failed : The higher rate of tax for Cumulative or Week1/Month1 Tax Basis should be '||l_tax_rate_high||'%';
			err_cnt := err_cnt + 1;
		--ELSE
		--	fnd_file.put_line(fnd_file.output,lpad(r_pay.pps_number_int,11,' ')||lpad(substr(r_pay.employee_no_int,1,12),13,' ')||lpad(' ',20,' ')||'Failed : The higher rate of tax for Cumulative or Week1/Month1 Tax Basis should be '||l_tax_rate_high||'%');
		--END IF;

		-- The exception details are written to an error table
		INSERT INTO pay_ie_tax_error ( pps_number
		, employee_number
		, full_name
		, payroll_name
		, tax_district
		, error_stack_message
		, error_message
		, request_id
		, error_date )
		VALUES (r_pay.pps_number_hr
		, substr(r_pay.employee_no_int,1,12)
		, r_pay.last_name_hr ||' '|| r_pay.first_name_hr
		, r_pay.payroll_name_hr
		, r_pay.tax_district
		, l_error_stack
		, l_error
		, l_request_id
		, sysdate);
		COMMIT;

	WHEN pay_to_date THEN
		l_error := 'Total Pay to Date and Total Tax to Date can be null only for Week1/Month1 basis.';--SQLERRM;
		retcode := 1;
		FND_FILE.PUT_LINE(fnd_file.log, 'Total Pay to Date and Total Tax to Date can be null only for Week1/Month1 basis.');

		FND_FILE.NEW_LINE(fnd_file.log, 1);
		/*FND_FILE.PUT_LINE(fnd_file.output, r_pay.pps_number_hr ||','||
		r_pay.employee_no_hr ||', '||
		r_pay.last_name_hr ||' '||
		r_pay.first_name_hr ||', '||
		r_pay.payroll_name_hr
		);*/

		--IF p_validate_mode = 'IE_VALIDATE' THEN
			l_err_tab(err_cnt).p_pps_number := r_pay.pps_number_int;
			l_err_tab(err_cnt).p_works_number := substr(r_pay.employee_no_int,1,12);
			l_err_tab(err_cnt).p_err_msg := 'Failed : Total Pay to Date and Total Tax to Date can be null only for Week1/Month1 basis';
			err_cnt := err_cnt + 1;
		--ELSE
		--	fnd_file.put_line(fnd_file.output,lpad(r_pay.pps_number_int,11,' ')||lpad(substr(r_pay.employee_no_int,1,12),13,' ')||lpad(' ',20,' ')||'Failed : Total Pay to Date and Total Tax to Date can be null only for Week1/Month1 basis');
		--END IF;

		-- The exception details are written to an error table
		INSERT INTO pay_ie_tax_error ( pps_number
		, employee_number
		, full_name
		, payroll_name
		, tax_district
		, error_stack_message
		, error_message
		, request_id
		, error_date )
		VALUES (r_pay.pps_number_hr
		, substr(r_pay.employee_no_int,1,12)
		, r_pay.last_name_hr ||' '|| r_pay.first_name_hr
		, r_pay.payroll_name_hr
		, r_pay.tax_district
		, l_error_stack
		, l_error
		, l_request_id
		, sysdate);
		COMMIT;

	WHEN OTHERS THEN
		errbuf := fnd_message.get;
		l_error_stack := errbuf;
		l_error := SQLERRM;

		/*Update interface table and set processed flag to 'No' to record that record has not been updated
		or inserted into payroll tables*/

		IF p_validate_mode = 'IE_VALIDATE_COMMIT' THEN
		UPDATE pay_ie_tax_body_interface
		SET processed_flag = 'N'
		WHERE pps_number  = r_pay.pps_number_int;
		END IF;
		-- The following command will be used to output the exception details to an output file:

		/*FND_FILE.PUT_LINE(fnd_file.output, r_pay.pps_number_hr ||','||
		r_pay.pps_number_int ||', '||
		r_pay.employee_no_hr ||', '||
		r_pay.pps_number_int  ||', '||
		r_pay.last_name_hr ||' '||
		r_pay.first_name_hr ||', '||
		r_pay.pps_number_int  ||', '||
		r_pay.payroll_name_hr ||', '||
		r_pay.pps_number_int
		);*/
		--IF p_validate_mode = 'IE_VALIDATE' THEN
			l_err_tab(err_cnt).p_pps_number := r_pay.pps_number_int;
			l_err_tab(err_cnt).p_works_number := substr(r_pay.employee_no_int,1,12);
			l_err_tab(err_cnt).p_err_msg := 'Failed : '||l_error;
			err_cnt := err_cnt + 1;
		--ELSE
		--	fnd_file.put_line(fnd_file.output,lpad(r_pay.pps_number_int,11,' ')||lpad(substr(r_pay.employee_no_int,1,12),13,' ')||lpad(' ',20,' ')||'Failed : '||l_error);
		--END IF;
		-- The exception details are written to an error table

		INSERT INTO pay_ie_tax_error ( pps_number
		, employee_number
		, full_name
		, payroll_name
		, tax_district
		, error_stack_message
		, error_message
		, request_id
		, error_date )
		VALUES (r_pay.pps_number_hr
		, substr(r_pay.employee_no_int,1,12)
		, r_pay.last_name_hr ||' '|| r_pay.first_name_hr
		, r_pay.payroll_name_hr
		, r_pay.tax_district
		, l_error_stack
		, l_error
		, l_request_id
		, sysdate);
		COMMIT;

	retcode := 1; -- 6215901

END;
--end if;
END LOOP;


IF l_err_tab.COUNT <> 0 then
	for i in l_err_tab.first..l_err_tab.last
	loop
		fnd_file.put_line(fnd_file.output,lpad(l_err_tab(i).p_pps_number,11,' ')||lpad(l_err_tab(i).p_works_number,13,' ')||lpad(' ',20,' ')||l_err_tab(i).p_err_msg);
	end loop;
END IF;
--bug 6376140
/*  for i in csr_skipped_asg
loop
	fnd_file.put_line(fnd_file.output,lpad(i.pps_number,11,' ')||lpad(i.works_number,13,' ')||lpad(' ',20,' ') || 'Please check the employee''s works number and/or PPS number');
end loop;
*/
FOR i in csr_skipped_assignments
   LOOP
	flag	:='N';
	  IF(l_pps_number.count<>0) then
	       FOR j in l_pps_number.first..l_pps_number.last
	       LOOP
		   IF l_pps_number(j)=i.pps_number THEN
			flag :='Y';
		   END IF;
	           EXIT WHEN flag='Y';
	        END LOOP;
	   END IF;
           IF flag='N' THEN
        --  open check_pps(i.pps_number);
         -- FETCH check_pps INTO p_check_pps
          -- if check_pps%found then
           fnd_file.put_line(fnd_file.output,lpad(i.pps_number,11,' ')||lpad(substr(nvl(i.works_number,' '),1,12),13,' ')
							   || lpad(substr(nvl(i.last_name,' '),1,20),16,' ')||lpad(substr(nvl(i.first_name,' '),1,20),16,' ')||'Please check the employee''s PPS number/works number');
          -- else
          -- else
         --fnd_file.put_line(fnd_file.output,lpad(i.pps_number,11,' ')||'Please check the employee''s PPS number');
        -- end if;
        -- close check_pps;
           END IF;
    END LOOP;
--end of bug 6376140

-- Bug Fix 3500192
-- Writes the trailer record in the log file
IF l_header_count = 1 THEN
  log_ie_paye_footer(l_record_count);
END IF;

/* If user selects the mode to be 'Validate and Commit' then
p_validate_mode = 'IE_VALIDATE_COMMIT' then records are committed else records are rolled back */

IF (p_validate_mode = 'IE_VALIDATE_COMMIT') THEN
	COMMIT;
ELSE
	ROLLBACK;
END IF;


EXCEPTION
WHEN NO_DATA_FOUND THEN
	l_error := SQLERRM;
	retcode := 1;
	FND_FILE.PUT_LINE(fnd_file.log, 'No data found');

	INSERT INTO pay_ie_tax_error ( pps_number
	, employee_number
	, full_name
	, payroll_name
	, tax_district
	, error_stack_message
	, error_message
	, request_id
	, error_date)
	VALUES (l_pps_number_hr
	, substr(l_employee_number_hr,1,12)
	, l_last_name_hr ||' '|| l_first_name_hr
	, l_payroll_name_hr
	, l_tax_district
	, l_error_stack
	, l_error
	, l_request_id
	, sysdate
	);
	COMMIT;

WHEN OTHERS THEN

	errbuf := fnd_message.get;
	l_error_stack := errbuf;
	l_error := SQLERRM;
	retcode := 2;
	/* The following command will be used to output the exception details to an output file*/

	/*FND_FILE.PUT_LINE(fnd_file.output, l_pps_number_hr   ||', '||
	l_pps_number_int  ||', '||
	l_employee_number_hr ||', '||
	l_employee_number_int ||', '||
	l_last_name_hr  ||' '||l_first_name_hr ||', '||
	l_last_name_int ||' '|| l_first_name_int ||', '||
	l_payroll_name_hr  ||', '||
	l_tax_district
	);*/
	--IF p_validate_mode = 'IE_VALIDATE' THEN
		l_err_tab(err_cnt).p_pps_number := l_pps_number_int;
		l_err_tab(err_cnt).p_works_number := substr(l_employee_number_int,1,12);
		l_err_tab(err_cnt).p_err_msg := 'Failed : OTHER in Main..'||l_error;
		err_cnt := err_cnt + 1;
	--ELSE
	--	fnd_file.put_line(fnd_file.output,lpad(l_pps_number_int,20,' ')||lpad(substr(l_employee_number_int,1,12),13,' ')||lpad(' ',20,' ')||'Failed : OTHER in Main..'||l_error);
	--END IF;
	/* The exception details are written to an error table */
	INSERT INTO pay_ie_tax_error ( pps_number
	, employee_number
	, full_name
	, payroll_name
	, tax_district
	, error_stack_message
	, error_message
	, request_id
	, error_date)
	VALUES (l_pps_number_hr
	, substr(l_employee_number_hr,1,12)
	, l_last_name_hr ||' '||l_first_name_hr
	, l_payroll_name_hr
	, l_tax_district
	, l_error_stack
	, l_error
	, l_request_id
	, sysdate);
	COMMIT;
END valinsupd;

-- Bug Fix 3500192
-- This procedures writes the Paye Details of the employee in the log file
PROCEDURE log_ie_paye_header
AS
  l_line_1  varchar2(1000)  := ' ';
  l_line_2  varchar2(1000)  := ' ';
  l_line_3  varchar2(1000)  := ' ';
BEGIN
  l_line_1 := rpad('Assignment',10)
	|| ' '
	|| rpad('Employee',15)
	|| ' '
	|| rpad('PPS',62)
	|| ' '
	|| rpad(lpad('Tax Credit',18-length('Tax Credit')/2),17)
	|| ' '
	|| rpad('Std Rate Cut Off',17);

  l_line_2 := rpad('Number',10)
	|| ' '
	|| rpad('Number',15)
	|| ' '
	|| rpad('Number',10)
	|| ' '
	|| rpad('Information Source',30)
	|| ' '
	|| rpad('Tax Basis',20)
	|| ' '
	|| rpad('Weekly',8)
	|| ' '
	|| rpad('Monthly',8)
	|| ' '
	|| rpad('Weekly',8)
	|| ' '
	|| rpad('Monthly',8);

  l_line_3 := rpad('-',10,'-')
	|| ' '
	|| rpad('-',15,'-')
	|| ' '
	|| rpad('-',10,'-')
	|| ' '
	|| rpad('-',30,'-')
	|| ' '
	|| rpad('-',20,'-')
	|| ' '
	|| rpad('-',8,'-')
	|| ' '
	|| rpad('-',8,'-')
	|| ' '
	|| rpad('-',8,'-')
	|| ' '
	|| rpad('-',8,'-');

  FND_FILE.NEW_LINE(fnd_file.log, 1);
  FND_FILE.PUT_LINE(fnd_file.log,l_line_1);
  FND_FILE.PUT_LINE(fnd_file.log,l_line_2);
  FND_FILE.PUT_LINE(fnd_file.log,l_line_3);

END log_ie_paye_header;

PROCEDURE log_ie_paye_body(
		  p_paye_details_id  IN NUMBER
		, p_pps_number	     IN VARCHAR2
		, p_employee_number  IN VARCHAR2
		)
AS
CURSOR c_paye_details(p_paye_details_id NUMBER)
IS
SELECT assignment_id
  , tax_basis
  , info_source
  , weekly_tax_credit
  , weekly_std_rate_cut_off
  , monthly_tax_credit
  , monthly_std_rate_cut_off
FROM pay_ie_paye_details_f
WHERE paye_details_id = p_paye_details_id;

CURSOR c_lookup_meaning(p_lookup_type VARCHAR2,p_lookup_code VARCHAR2)
IS
SELECT meaning
FROM hr_lookups
where lookup_type = p_lookup_type
and lookup_code = p_lookup_code;

  r_paye_details c_paye_details%ROWTYPE;
  l_line varchar2(1000);
  l_info_source varchar2(30);
  l_tax_basis varchar2(20);

BEGIN
  OPEN c_paye_details(p_paye_details_id);
  FETCH c_paye_details INTO r_paye_details;
  CLOSE c_paye_details;
  --
  OPEN c_lookup_meaning('IE_PAYE_INFO_SOURCE',r_paye_details.info_source);
  FETCH c_lookup_meaning INTO l_info_source;
  CLOSE c_lookup_meaning;
  --
  OPEN c_lookup_meaning('IE_PAYE_TAX_BASIS',r_paye_details.tax_basis);
  FETCH c_lookup_meaning INTO l_tax_basis;
  CLOSE c_lookup_meaning;
  --
  l_line := rpad(nvl(r_paye_details.assignment_id,0),10,' ')
  || ' '
  || rpad(nvl(p_employee_number,0),15,' ')
  || ' '
  || rpad(nvl(p_pps_number,' '),10,' ')
  || ' '
  || rpad(nvl(l_info_source,' '),30,' ')
  || ' '
  || rpad(nvl(l_tax_basis,' '),20,' ')
  || ' '
  || rpad(nvl(to_char(r_paye_details.weekly_tax_credit),'-'),8,' ')
  || ' '
  || rpad(nvl(to_char(r_paye_details.monthly_tax_credit),'-'),8,' ')
  || ' '
  || rpad(nvl(to_char(r_paye_details.weekly_std_rate_cut_off),'-'),8,' ')
  || ' '
  || rpad(nvl(to_char(r_paye_details.monthly_std_rate_cut_off),'-'),8,' ');

  FND_FILE.PUT_LINE(fnd_file.log,l_line);

END log_ie_paye_body;

PROCEDURE log_ie_paye_footer(p_total IN NUMBER)
AS
l_line varchar2(100);
BEGIN
l_line := 'Number of Records: '
	|| p_total;
  FND_FILE.NEW_LINE(fnd_file.log, 1);
  FND_FILE.PUT_LINE(fnd_file.log,l_line);
  FND_FILE.NEW_LINE(fnd_file.log, 1);
END log_ie_paye_footer;

END PAY_IE_TAX_VAL;

/
