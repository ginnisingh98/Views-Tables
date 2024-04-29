--------------------------------------------------------
--  DDL for Package Body PAY_SA_GOSI_REPORTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_SA_GOSI_REPORTS" AS
 /* $Header: pysagosi.pkb 120.11.12010000.2 2009/07/30 11:39:19 bkeshary ship $ */
--
	lg_format_mask varchar2(50);
  PROCEDURE set_currency_mask(p_business_group_id IN NUMBER) IS
	/* Cursor to retrieve Currency */
    CURSOR csr_currency IS
    SELECT org_information10
    FROM   hr_organization_information
    WHERE  organization_id = p_business_group_id
    AND    org_information_context = 'Business Group Information';
    l_currency VARCHAR2(40);
  BEGIN
    OPEN csr_currency;
    FETCH csr_currency into l_currency;
    CLOSE csr_currency;
    lg_format_mask := FND_CURRENCY.GET_FORMAT_MASK(l_currency,40);
  END set_currency_mask;
	PROCEDURE populate_sum(
           p_request_id IN NUMBER
          ,p_from_date   IN varchar2
          ,p_to_date     IN varchar2
          ,p_output_fname OUT NOCOPY VARCHAR2)
        IS
        l_file_name varchar2(50);
        l_audit_log_dir varchar2(500);
        l_from_date date;
        l_to_date date;
        l_report varchar2(50);
        BEGIN
/*Msg in the temorary table*/
        -- To clear the PL/SQL Table values.
        vXMLTable.DELETE;
        vCtr := 1;
	l_from_date := fnd_date.canonical_to_date(p_from_date);
	l_to_date := fnd_date.canonical_to_date(p_to_date);
        -- Changing the date parameters from canonical format to date format.
        --l_from_date:= fnd_date.canonical_to_date(p_from_date);
        --l_to_date := fnd_date.canonical_to_date(p_to_date);
        -- Populate the Part 1 of 462 Report
        fnd_file.put_line(fnd_file.log,'Calling Procedure to Populate New and Terminated Report');
	/*Write message in temporary table*/
/* Hardcode The values for the call to report5*/
	--populate_new_and_term_wrks(2821,'JAN',2003);
/*End of call to report5*/
/*Write message in temporary table*/
        -- Write the values to XML File
        fnd_file.put_line(fnd_file.log,'Calling Procedure to write into XML File');
/*        WritetoXML(
        p_request_id,
        l_report,
        l_file_name);*/
        p_output_fname := l_file_name;
        fnd_file.put_line(fnd_file.log,'------------Output XML File----------------');
        fnd_file.put_line(fnd_file.log,'File' || l_file_name );
        fnd_file.put_line(fnd_file.log,'-------------------------------------------');
EXCEPTION
        WHEN utl_file.invalid_path then
                hr_utility.set_message(8301, 'GHR_38830_INVALID_UTL_FILE_PATH');
                fnd_file.put_line(fnd_file.log,HR_UTILITY.get_message);
                hr_utility.raise_error;
--
    WHEN utl_file.invalid_mode then
        hr_utility.set_message(8301, 'GHR_38831_INVALID_FILE_MODE');
        fnd_file.put_line(fnd_file.log,HR_UTILITY.get_message);
                hr_utility.raise_error;
--
    WHEN utl_file.invalid_filehandle then
        hr_utility.set_message(8301, 'GHR_38832_INVALID_FILE_HANDLE');
        fnd_file.put_line(fnd_file.log,HR_UTILITY.get_message);
                hr_utility.raise_error;
--
    WHEN utl_file.invalid_operation then
        hr_utility.set_message(8301, 'GHR_38833_INVALID_OPER');
        fnd_file.put_line(fnd_file.log,HR_UTILITY.get_message);
                hr_utility.raise_error;
--
    WHEN utl_file.read_error then
        hr_utility.set_message(8301, 'GHR_38834_FILE_READ_ERROR');
        fnd_file.put_line(fnd_file.log,HR_UTILITY.get_message);
                hr_utility.raise_error;
--
    WHEN others THEN
       hr_utility.set_message(800,'FFU10_GENERAL_ORACLE_ERROR');
       hr_utility.set_message_token('2',substr(sqlerrm,1,200));
       fnd_file.put_line(fnd_file.log,HR_UTILITY.get_message);
           hr_utility.raise_error;
END populate_sum;
--------------------------------------------
-- Procedure to populate the new and terminated report
PROCEDURE populate_new_and_term_wrks
  (p_request_id                number
   ,p_report                   varchar2
   ,p_business_group_id        number
   ,p_org_structure_version_id number DEFAULT NULL
   ,p_organisation_id          number
   ,p_effective_month          varchar2
   ,p_effective_year           varchar2
   ,l_xfdf_blob OUT NOCOPY BLOB)
IS
l_test_new 		number;
l_test_term 		number;
l_defined_balance_id 	number;
l_person_id 		number;
l_person_id_term 	number;
l_assact_id_new 	number;
l_assact_id_term 	number;
l_assign_id 		number;
l_temp 			number;
l_temp_term 		number;
l_sum_term 		number := 0;
l_sum 			number:= 0;
l_count_new 		number;
l_count_term 		number;
l_job 			varchar2(240);
l_join_date 		date;
l_name_new 		varchar2(240);
l_birth_date 		date;
l_nationality 		varchar2(240);
l_nationality_mn 	varchar2(240);
l_passport_number 	varchar2(240);
l_civil_id 		varchar2(240);
l_GOSI_number_new 	varchar2(240);
l_term_date 		date;
l_term_reason 		varchar2(240);
l_term_reason_mn 	varchar2(240);
l_name_term 		varchar2(240);
l_GOSI_number_term 	varchar2(240);
new_count 		number := 0;
term_count 		number := 0;
l_new_count 		number := 1;
l_term_count 		number := 1;
l_employer_GOSI_office 	varchar2(240);
l_employer_name 	varchar2(240);
l_employer_GOSI_code 	varchar2(240);
l_n 			number :=0;
l_t 			number :=0;
l_org_id 		number;
l_effective_date1 	date;
l_effective_date 	varchar2(40);
l_effective_date_p	date;
l_effective_month 	CONSTANT number(2) := p_effective_month;
l_effective_year 	CONSTANT number(4) := p_effective_year ;
l_parent_id 		number;
TYPE t_rec_gre IS RECORD(GRE_NAME varchar2(80), GRE_ID number);
TYPE t_tab_gre IS TABLE OF t_rec_gre INDEX BY BINARY_INTEGER;
t_legal_entity          t_tab_gre;
l_gre_present           number := 0;
i                       number := 0;
l_gre_name              varchar2(80);
l_gre_id                number := 0;
l_err                   number := 0;
l_tax_unit_id           number := 0;
l_gosi_office_id        number;
l_gosi_office           varchar2(260);
l_gosi_office_code      varchar2(20);
l_employer_gosi_number  varchar2(30);
l_leaver_this_month_flag varchar2(1) := 'Y' ;
l_joiner_this_month_flag varchar2(1) := 'Y';
l_nj_term_date date;
l_test_new_assact_id number;
l_test_term_assact_id number;
l_prev_date date;
l_test_prev_month_date varchar2(40);
l_test_curr_month_date varchar2(40);
l_prev_month varchar2(40);
l_last_prev_month_date varchar2(40);
l_last_curr_month_date varchar2(40);
l_last_prev_month_date1 date;
l_input_date varchar2(40);
l_temp_new_assgt_id number;
l_temp_term_assgt_id number;
l_assgt_id_new number;
l_assgt_id_term number;
l_employer_GOSI_office_name varchar2(240);
l_lower_base VARCHAR2(30);
l_upper_base VARCHAR2(30);
/*Cursor for fetching organizations in the hierarchy*/
  	cursor csr_org_hierarchy is
  	select pose.organization_id_child org
 	from   per_org_structure_elements pose
  	connect by pose.organization_id_parent = prior pose.organization_id_child
  	and pose.org_structure_version_id = p_org_structure_version_id
  	start with pose.organization_id_parent = p_organisation_id
  	and pose.org_structure_version_id = p_org_structure_version_id
  	union
  	select p_organisation_id org
  	from   dual;
	rec_org_id    csr_org_hierarchy%rowtype;
  	l_file_name varchar2(250);
  	l_audit_log_dir varchar2(500);
/*Cursor for fetching gosi office code*/
	cursor csr_gosi_code(p_GOSI_office_id number) is
	select org_information1
	from   hr_organization_information
	where  organization_id = p_GOSI_office_id
  	and    org_information_context = 'SA_GOSI_OFFICE_DETAILS';
-- Cursor to populate Part G5-A-01,G5-A-05
	cursor get_employer_GOSI (p_org_id number) is
	select org_information1,org_information2
	from hr_organization_information
	where organization_id = p_org_id
	and org_information_context = 'SA_EMPLOYER_GOSI_DETAILS';
--Cursor to get the name of the organization.
	cursor get_org_name (p_org_id number) is
	select name
	from hr_all_organization_units
	where organization_id = p_org_id;
/********************-- Cursor to get person ids of the newly hired employees
        cursor get_pid_new (p_org_id number,p_date date) is
  select distinct asg.person_id,paa.assignment_action_id
  from   per_all_assignments_f asg
         ,pay_assignment_actions paa
         ,pay_payroll_actions ppa
         ,hr_soft_coding_keyflex hscl
         ,per_periods_of_service pos
  where  asg.assignment_id = paa.assignment_id
  and    paa.payroll_action_id = ppa.payroll_action_id
  and    pos.period_of_service_id = asg.period_of_service_id
  and    ppa.action_type in ('R','Q')
  and    ppa.action_status = 'C'
  and    paa.action_status = 'C'
  and    trunc(ppa.date_earned,'MM') = TRUNC(to_date(l_effective_date,'DD-MM-YYYY'), 'MM')
  and    NVL(pos.actual_termination_date, to_date('31-12-4712','DD-MM-YYYY'))
           not between to_date(l_effective_date,'DD-MM-YYYY') and to_date(l_test_curr_month_date,'DD-MM-YYYY')
  and    trunc(pos.date_start, 'MM') = trunc(to_date(l_effective_date,'DD-MM-YYYY'), 'MM')
  and    trunc(to_date(l_effective_date,'DD-MM-YYYY'), 'MM') between asg.effective_start_date and asg.effective_end_date
  and    hscl.soft_coding_keyflex_id = asg.soft_coding_keyflex_id
  and    hscl.segment1 = to_char(p_org_id)
  ORDER BY asg.person_id;
-- Cursor to get person ids of terminated employees
        cursor get_pid_term (p_org_id number,p_date date) is
	--and trunc(pps.actual_termination_date,'MM') = p_date;
  select distinct asg.person_id, paa.assignment_action_id
  from   per_all_assignments_f asg
         ,pay_assignment_actions paa
         ,pay_payroll_actions ppa
         ,hr_soft_coding_keyflex hscl
         ,per_periods_of_service pos
  where  asg.assignment_id = paa.assignment_id
  and    paa.payroll_action_id = ppa.payroll_action_id
  and    pos.period_of_service_id = asg.period_of_service_id
  and    ppa.action_type in ('R','Q')
  and    ppa.action_status = 'C'
  and    paa.action_status = 'C'
  and    trunc(ppa.date_earned,'MM') = TRUNC(to_date(l_test_prev_month_date,'DD-MM-YYYY'), 'MM')
  and    (trunc(NVL(pos.actual_termination_date, to_date('31-12-4712','DD-MM-YYYY')))
           between to_date(l_test_prev_month_date,'DD-MM-YYYY') and to_date(l_last_prev_month_date,'DD-MM-YYYY')
         or
	  trunc(NVL(pos.actual_termination_date,to_date('31-12-4712','DD-MM-YYYY')))
	   between p_date and to_date(l_test_curr_month_date,'DD-MM-YYYY')
	)
 -- and    trunc(pos.date_start, 'MM') <> trunc(to_date(l_test_prev_month_date,'DD-MM-YYYY'), 'MM')
  and
  (trunc(to_date(l_effective_date,'DD-MM-YYYY'), 'MM') between asg.effective_start_date and asg.effective_end_date
  or
  trunc(to_date(l_test_prev_month_date,'DD-MM-YYYY'),'MM') between asg.effective_start_date and asg.effective_end_date
  )
  and    hscl.soft_coding_keyflex_id = asg.soft_coding_keyflex_id
  and    hscl.segment1 = to_char(p_org_id)
  ORDER BY asg.person_id;********************/
  /***Start of new code***/
-- Cursor to get person_ids,assignment_ids of newly joined emps
cursor get_pid_new (p_org_id number,p_date date) is
select  distinct asg.person_id,asg.assignment_id from per_all_assignments_f asg
         ,pay_assignment_actions paa
         ,pay_payroll_actions ppa
         ,hr_soft_coding_keyflex hscl
         ,per_periods_of_service pos
  where asg.assignment_id = paa.assignment_id
  and    paa.payroll_action_id = ppa.payroll_action_id
  and    pos.period_of_service_id = asg.period_of_service_id
  and    ppa.action_type in ('R','Q')
  and    ppa.action_status = 'C'
  and    paa.action_status = 'C'
  and    trunc(ppa.date_earned,'MM') = trunc(to_date(l_effective_date,'DD-MM-YYYY'), 'MM')
  and    trunc(pos.date_start, 'MM') = trunc(to_date(l_effective_date,'DD-MM-YYYY'), 'MM')
  and    trunc(to_date(l_effective_date,'DD-MM-YYYY'),'MM') between trunc(asg.effective_start_date,'MM') and asg.effective_end_date
  and    hscl.soft_coding_keyflex_id = asg.soft_coding_keyflex_id
  and    hscl.segment1 = to_char(p_org_id)
  order by asg.person_id;
--Cursor to get assignment_action_id of new emps
cursor get_assact_id_new (p_org_id number,p_date date,p_person_id number) is
select  paa.assignment_action_id from per_all_assignments_f asg
         ,pay_assignment_actions paa
         ,pay_payroll_actions ppa
         ,hr_soft_coding_keyflex hscl
         ,per_periods_of_service pos
  where rownum < 2
  and   asg.assignment_id = paa.assignment_id
  and   asg.person_id = p_person_id
  and    paa.payroll_action_id = ppa.payroll_action_id
  and    pos.period_of_service_id = asg.period_of_service_id
  and    ppa.action_type in ('R','Q')
  and    ppa.action_status = 'C'
  and    paa.action_status = 'C'
  and    trunc(ppa.date_earned,'MM') = trunc(to_date(l_effective_date,'DD-MM-YYYY'), 'MM')
  and    trunc(pos.date_start, 'MM') = trunc(to_date(l_effective_date,'DD-MM-YYYY'), 'MM')
  and    trunc(to_date(l_effective_date,'DD-MM-YYYY'),'MM') between trunc(asg.effective_start_date,'MM') and asg.effective_end_date
  and    hscl.soft_coding_keyflex_id = asg.soft_coding_keyflex_id
  and    hscl.segment1 = to_char(p_org_id)
  order by asg.person_id;


  -- Cursor to get person_ids,assignment_ids of terminated emps
   cursor get_pid_term (p_org_id number,p_date date) is
  	--and trunc(pps.actual_termination_date,'MM') = p_date;
    select /*+ INDEX(hscl, HR_SOFT_CODING_KEYFLEX_PK) */ distinct asg.person_id, asg.assignment_id
    from   per_all_assignments_f asg
           ,pay_assignment_actions paa
           ,pay_payroll_actions ppa
           ,hr_soft_coding_keyflex hscl
           ,per_periods_of_service pos
    where  asg.assignment_id = paa.assignment_id
    and    paa.payroll_action_id = ppa.payroll_action_id
    and    pos.period_of_service_id = asg.period_of_service_id
    and    ppa.action_type in ('R','Q')
    and    ppa.action_status = 'C'
    and    paa.action_status = 'C'
    and    trunc(ppa.date_earned,'MM') = TRUNC(to_date(l_test_prev_month_date,'DD-MM-YYYY'), 'MM')
    and    (
    		( trunc(NVL(pos.actual_termination_date, to_date('31-12-4712','DD-MM-YYYY')))
                 between to_date(l_test_prev_month_date,'DD-MM-YYYY') and to_date(l_last_prev_month_date,'DD-MM-YYYY')
                )
           or
	  	  trunc(NVL(pos.actual_termination_date,to_date('31-12-4712','DD-MM-YYYY')))
  		   between p_date and to_date(l_test_curr_month_date,'DD-MM-YYYY')
           or
           (
  	     trunc(NVL(pos.actual_termination_date,to_date('31-12-4712','DD-MM-YYYY')))
  	   between TRUNC(to_date(l_test_prev_month_date,'DD-MM-YYYY'),'MM') and to_date(l_last_prev_month_date,'DD-MM-YYYY')
  	   	AND
  	   trunc(pos.date_start, 'MM') = TRUNC(to_date(l_test_prev_month_date,'DD-MM-YYYY'), 'MM')
  	   )
         )
    and    trunc(pos.date_start, 'MM') <> trunc(to_date(l_test_curr_month_date,'DD-MM-YYYY'), 'MM')
    and
    (
       trunc(to_date(l_effective_date,'DD-MM-YYYY'), 'MM') between trunc(asg.effective_start_date,'MM') and asg.effective_end_date
    or
       trunc(to_date(l_test_prev_month_date,'DD-MM-YYYY'),'MM') between trunc(asg.effective_start_date,'MM') and asg.effective_end_date
    )
    and    hscl.soft_coding_keyflex_id = asg.soft_coding_keyflex_id
    and    hscl.segment1 = to_char(p_org_id)
    and    hscl.id_flex_num = 20
  ORDER BY asg.person_id;

 -- Cursor to get assignment_action_ids of terminated emps
 cursor get_assact_id_term (p_org_id number,p_date date,p_person_id number) is
 select paa.assignment_action_id
     from   per_all_assignments_f asg
            ,pay_assignment_actions paa
            ,pay_payroll_actions ppa
            ,hr_soft_coding_keyflex hscl
            ,per_periods_of_service pos
     where  rownum < 2
 	and    asg.assignment_id = paa.assignment_id
 	and    asg.person_id = p_person_id
     and    paa.payroll_action_id = ppa.payroll_action_id
     and    pos.period_of_service_id = asg.period_of_service_id
     and    ppa.action_type in ('R','Q')
     and    ppa.action_status = 'C'
     and    paa.action_status = 'C'
     and    trunc(ppa.date_earned,'MM') = TRUNC(to_date(l_test_prev_month_date,'DD-MM-YYYY'), 'MM')
    and    (
    		( trunc(NVL(pos.actual_termination_date, to_date('31-12-4712','DD-MM-YYYY')))
                 between to_date(l_test_prev_month_date,'DD-MM-YYYY') and to_date(l_last_prev_month_date,'DD-MM-YYYY')
                )
           or
  	  trunc(NVL(pos.actual_termination_date,to_date('31-12-4712','DD-MM-YYYY')))
  	   between p_date and to_date(l_test_curr_month_date,'DD-MM-YYYY')
           or
           (
  	     trunc(NVL(pos.actual_termination_date,to_date('31-12-4712','DD-MM-YYYY')))
  	   between TRUNC(to_date(l_test_prev_month_date,'DD-MM-YYYY'),'MM') and to_date(l_last_prev_month_date,'DD-MM-YYYY')
  	   	AND
  	   trunc(pos.date_start, 'MM') = TRUNC(to_date(l_test_prev_month_date,'DD-MM-YYYY'), 'MM')
  	   )
        )
     and    trunc(pos.date_start, 'MM') <> trunc(to_date(l_test_curr_month_date,'DD-MM-YYYY'), 'MM')
     and
     (
        trunc(to_date(l_effective_date,'DD-MM-YYYY'), 'MM') between trunc(asg.effective_start_date,'MM') and asg.effective_end_date
     or
        trunc(to_date(l_test_prev_month_date,'DD-MM-YYYY'),'MM') between trunc(asg.effective_start_date,'MM') and asg.effective_end_date
     )
     and    hscl.soft_coding_keyflex_id = asg.soft_coding_keyflex_id
     and    hscl.segment1 = to_char(p_org_id)
   ORDER BY asg.person_id;
 /*****end of new code*******/
--cursor to get job name for the newly hired employees
	cursor get_job(p_assignment_id number,p_date date) is
	select name
	from per_jobs pj, per_all_assignments_f paf
	where pj.job_id = paf.job_id
	and paf.assignment_id = p_assignment_id
	and trunc(p_date,'MM') between trunc(paf.effective_start_date,'MM') and paf.effective_end_date;
--cursor to get the passport number of the newly hired employees
	cursor get_passport_number (pn_person_id number,p_date date)  is
	SELECT	pei.pei_information1 FROM per_people_extra_info pei
	WHERE pei.person_id = pn_person_id
	AND pei.information_type = 'SA_PASSPORT' AND pei.pei_information_category = 'SA_PASSPORT'
	AND p_date between trunc(fnd_date.canonical_to_date(pei.pei_information3),'MM') and fnd_date.canonical_to_date(pei.pei_information4);
--cursor to get the Civil ID
	cursor get_civil_id (p_person_id number,p_date date) is
	SELECT NATIONAL_IDENTIFIER   from per_all_people_f pap WHERE pap.person_id = p_person_id
	and trunc(p_date,'MM') between trunc(pap.effective_start_date,'MM') and pap.effective_end_date;
--cursor to get the joining date of the newly hired employees
	cursor get_start_date(p_person_id number) is
	select date_start from per_periods_of_service where person_id = p_person_id and trunc(date_start,'MM') = to_date(l_effective_date,'DD-MM-YYYY');
--cursor to get leaving date for new joinee
	cursor get_term_date_new (p_person_id number)  is
	select actual_termination_date from per_periods_of_service where person_id = p_person_id;
--cursor to get the details of the newly hired employees
	cursor get_details_new (p_person_id number,p_date date) is
	select full_name,nationality,date_of_birth from per_all_people_f where person_id = p_person_id
	and trunc(p_date,'MM') between trunc(effective_start_date,'MM') and effective_end_date;
--cursor to get GOSI number of the employees
	cursor get_GOSI_number_new (p_person_id number) is
	select segment2
	from hr_soft_coding_keyflex hsc, per_all_assignments_f paf
	where hsc.soft_coding_keyflex_id = paf.soft_coding_keyflex_id
	and paf.person_id = p_person_id;
--cursor to get names of the terminated employees
	cursor get_name_term (p_person_id number,p_date date) is
	select full_name  from per_all_people_f where person_id = p_person_id
	and trunc(p_date,'MM') between trunc(effective_start_date,'MM') and effective_end_date;
--cursor to get GOSI numbers of the terminated  employees
	cursor get_GOSI_number_term(p_person_id number) is
	select segment2
	from hr_soft_coding_keyflex hsc, per_all_assignments_f paf
	 where hsc.soft_coding_keyflex_id = paf.soft_coding_keyflex_id
	and paf.person_id = p_person_id;
--cursor to get the termination details of the terminated employees
	cursor get_details_term (p_person_id number)  is
	select actual_termination_date,leaving_reason from per_periods_of_service where person_id = p_person_id;
/* Cursor to fetch lower limit of gosi base*/
	CURSOR get_lower_base(l_effective_date DATE) IS
	SELECT global_value
	FROM   ff_globals_f
	WHERE  global_name = 'SA_GOSI_BASE_LOWER_LIMIT'
	AND    legislation_code = 'SA'
	AND    business_group_id IS NULL
	AND    l_effective_date BETWEEN effective_start_date
		                    AND effective_end_date;
/* Cursor to fetch upper limit of gosi base*/
	CURSOR get_upper_base(l_effective_date DATE) IS
	SELECT global_value
	FROM   ff_globals_f
	WHERE  global_name = 'SA_GOSI_BASE_UPPER_LIMIT'
	AND    legislation_code = 'SA'
	AND    business_group_id IS NULL
	AND    l_effective_date BETWEEN effective_start_date
		                    AND effective_end_date;
  l_fm_temp      varchar2(250);
  l_fm_sum       varchar2(250);
  l_fm_temp_term varchar2(250);
  l_fm_sum_term  varchar2(250);
BEGIN
  set_currency_mask(p_business_group_id);
 	l_input_date := '01-'||l_effective_month||'-'||p_effective_year;
	l_effective_date1 := last_day(to_date(l_input_date,'DD-MM-YYYY'));
 	l_effective_date := '01-'||to_char(l_effective_date1,'MM-YYYY');
	l_effective_date_p := to_date(l_effective_date,'DD-MM-YYYY');
 	--l_effective_date := '01-01-2000';
        l_prev_date:=add_months(to_date(l_effective_date,'DD-MM-YYYY'),-1);
                         /*Following two lines changed for enhancement 5283457
	l_test_curr_month_date := '27-'||to_char(l_effective_date1,'MM-YYYY');
	l_test_prev_month_date := '28-'||to_char(l_prev_date,'MM')||to_char(l_prev_date,'YYYY');*/
	l_test_curr_month_date := TO_CHAR(l_effective_date1 - 1,'DD-MM-YYYY');
	l_test_prev_month_date := TO_CHAR(last_day(l_prev_date),'DD-MM-YYYY');
	--l_test_prev_month_date := '28-01-2000';
	l_last_prev_month_date1 := (last_day(to_date(l_test_prev_month_date,'DD-MM-YYYY')));
	l_last_prev_month_date := to_char(l_last_prev_month_date1,'DD-MM-YYYY');
	--l_last_prev_month_date := '27-12-1999';

        insert into fnd_sessions(session_id,effective_date) values(userenv('sessionid'),to_date(l_effective_date,'DD-MM-YYYY'));

        /*Commented the hierarchy part on 15-Jan-2004 */
	/*if p_org_structure_version_id is not null then
	      open csr_org_hierarchy;
	loop
	        fetch csr_org_hierarchy into rec_org_id;
	        exit when csr_org_hierarchy%notfound;
		hr_sa_org_info.get_employer_name(rec_org_id.org,l_gre_name,p_business_group_id,p_org_structure_version_id);
		hr_utility.set_location('Before Hierarchy logic',10);
	        begin
		          select organization_id
	        	  into   l_gre_id
	          	  from   hr_all_organization_units
	          	  where  name = l_gre_name
	          	  and business_group_id = p_business_group_id;
	        exception
		when others then
	            l_err := 1;
	        end;
	        i := 0;
	        IF t_legal_entity.count <> 0 then
		        --WHILE t_legal_entity.last
		        l_gre_present := 0;
		        FOR i in t_legal_entity.first..t_legal_entity.last
			LOOP
		            IF t_legal_entity(i).gre_id = l_gre_id THEN
		 	           l_gre_present := 1;
			           EXIT;
		            END IF;
		        END LOOP;
			IF l_gre_present = 0 THEN
			        i := t_legal_entity.count;
	    			t_legal_entity(i + 1).gre_id := l_gre_id;
	            		t_legal_entity(i + 1).gre_name := l_gre_name;
			END IF;
	        ELSE
			i := t_legal_entity.count;
			t_legal_entity(i + 1).gre_id := l_gre_id;
			t_legal_entity(i + 1).gre_name := l_gre_name;
	        END IF;
	END LOOP;
		CLOSE csr_org_hierarchy;
	end if; --if p_org_structure_version_id is not null then
        */
        /*Commented the hierarchy part on 15-Jan-2004 */
	  --Fetch defined_balance_id's
	if p_org_structure_version_id is null then
        /*Commented the hierarchy part on 15-Jan-2004 */
		/*l_gre_id := null;
		l_gre_name := null;
		hr_sa_org_info.get_employer_name(p_organisation_id,l_gre_name,p_business_group_id);
		begin
		select organization_id
		into   l_gre_id
		from   hr_all_organization_units
		where  name = l_gre_name
		and business_group_id =p_business_group_id;
		exception
			when others then
				l_err := 1;
		end;
		t_legal_entity(1).gre_id := l_gre_id;
		t_legal_entity(1).gre_name := l_gre_name;*/
        /*Commented the hierarchy part on 15-Jan-2004 */
-- New code begins
                l_gre_id := p_organisation_id;
		begin
		select name
		into   l_gre_name
		from   hr_all_organization_units
		where  organization_id= l_gre_id
		and business_group_id =p_business_group_id;
		exception
			when others then
				l_err := 1;
		end;
		t_legal_entity(1).gre_id := l_gre_id;
		t_legal_entity(1).gre_name := l_gre_name;
-- New code ends
	end if;
	vXMLTable.DELETE;
	vCtr := 1;
       hr_utility.set_location('Calling Procedure to Populate New and Terminated Report',20);
	FOR i in t_legal_entity.first..t_legal_entity.last
	LOOP
		l_org_id := t_legal_entity(i).gre_id;
	OPEN get_lower_base(l_effective_date_p);
	  FETCH get_lower_base INTO l_lower_base;
	CLOSE get_lower_base;
	OPEN get_upper_base(l_effective_date_p);
	  FETCH get_upper_base INTO l_upper_base;
        CLOSE get_upper_base;
	--Get the defined Balance id
		select  u.creator_id
		into    l_defined_balance_id
		from    ff_user_entities  u,
		ff_database_items d
		where   d.user_name = 'GOSI_REFERENCE_EARNINGS_ASG_YTD'
		and     u.user_entity_id = d.user_entity_id
		and     u.legislation_code = 'SA'
		and     u.business_group_id is null
		and     u.creator_type = 'B';
	--Get the First date of the current month.
	open get_pid_new(l_org_id,l_effective_date_p);
	fetch get_pid_new into l_test_new,l_temp_new_assgt_id;
	open get_pid_term(l_org_id,l_effective_date_p);
	fetch get_pid_term into l_test_term,l_temp_term_assgt_id;
	if ((get_pid_new%notfound) and (get_pid_term%notfound))  then
		close get_pid_term;
		close get_pid_new;
		open get_pid_new(l_org_id,l_effective_date_p);
		open get_pid_term(l_org_id,l_effective_date_p);
	else
		close get_pid_new;
		close get_pid_term;
		open get_pid_new(l_org_id,l_effective_date_p);
		open get_pid_term(l_org_id,l_effective_date_p);
		loop
			open get_employer_GOSI(l_org_id);
			fetch get_employer_GOSI into l_employer_GOSI_number,l_employer_GOSI_office;
			close get_employer_GOSI;
						begin
						  select name
						  into   l_employer_gosi_office_name
						  from   hr_organization_units
						  where  organization_id = l_employer_gosi_office;
						exception
						  when others then
						    l_employer_gosi_office_name := null;
						end;
						open csr_GOSI_code(l_employer_GOSI_office);
						fetch csr_GOSI_code into l_employer_GOSI_code;
						close csr_GOSI_code;
						vXMLTable(vCtr).TagName := 'INTO LOOP ORG';
						vXMLTable(vCtr).TagValue := null;
						vCtr := vCtr + 1;
						vXMLTable(vCtr).TagName := 'G5-A-01';
						vXMLTable(vCtr).TagValue := (l_employer_GOSI_office_name);
						vCtr := vCtr + 1;
						vXMLTable(vCtr).TagName := 'G5-A-01-1';
						vXMLTable(vCtr).TagValue := substr(l_employer_GOSI_code,1,1);
						vCtr := vCtr + 1;
						vXMLTable(vCtr).TagName := 'G5-A-01-2';
						vXMLTable(vCtr).TagValue := substr(l_employer_GOSI_code,2,1);
						vCtr := vCtr + 1;
			vXMLTable(vCtr).TagName := 'G5-A-05-1';
			vXMLTable(vCtr).TagValue := substr(l_employer_GOSI_number,9,1);
			vCtr := vCtr + 1;
			vXMLTable(vCtr).TagName := 'G5-A-05-2';
			vXMLTable(vCtr).TagValue := substr(l_employer_GOSI_number,8,1);
			vCtr := vCtr + 1;
			vXMLTable(vCtr).TagName := 'G5-A-05-3';
			vXMLTable(vCtr).TagValue := substr(l_employer_GOSI_number,7,1);
			vCtr := vCtr + 1;
			vXMLTable(vCtr).TagName := 'G5-A-05-4';
			vXMLTable(vCtr).TagValue := substr(l_employer_GOSI_number,6,1);
			vCtr := vCtr + 1;
			vXMLTable(vCtr).TagName := 'G5-A-05-5';
			vXMLTable(vCtr).TagValue := substr(l_employer_GOSI_number,5,1);
			vCtr := vCtr + 1;
			vXMLTable(vCtr).TagName := 'G5-A-05-6';
			vXMLTable(vCtr).TagValue := substr(l_employer_GOSI_number,4,1);
			vCtr := vCtr + 1;
			vXMLTable(vCtr).TagName := 'G5-A-05-7';
			vXMLTable(vCtr).TagValue := substr(l_employer_GOSI_number,3,1);
			vCtr := vCtr + 1;
			vXMLTable(vCtr).TagName := 'G5-A-05-8';
			vXMLTable(vCtr).TagValue := substr(l_employer_GOSI_number,2,1);
			vCtr := vCtr + 1;
			vXMLTable(vCtr).TagName := 'G5-A-05-9';
			vXMLTable(vCtr).TagValue := substr(l_employer_GOSI_number,1,1);
			vCtr := vCtr + 1;
			open get_org_name(l_org_id);
			fetch get_org_name into l_employer_name;
			close get_org_name;
			vXMLTable(vCtr).TagName := 'G5-A-04';
			vXMLTable(vCtr).TagValue := l_employer_name;
			vCtr := vCtr + 1;
			vXMLTable(vCtr).TagName := 'G5-A-02';
			--vXMLTable(vCtr).TagValue := l_effective_month;
                        vXMLTable(vCtr).TagValue := p_effective_month;
			vCtr := vCtr + 1;
			vXMLTable(vCtr).TagName := 'G5-A-03';
			vXMLTable(vCtr).TagValue := l_effective_year;
			vCtr := vCtr + 1;
			vXMLTable(vCtr).TagName := 'start_of_record';
			vXMLTable(vCtr).TagValue :=null;
			vCtr := vCtr + 1;
			loop
				/*Get person_id and assignment_action_id for new employees*/
				fetch get_pid_new into l_person_id,l_assgt_id_new;
					if (get_pid_new %notfound) then
						l_person_id := null;
						l_assgt_id_new := null;
					end if;
				vXMLTable(vCtr).TagName := 'start_of_B';
				vXMLTable(vCtr).TagValue := null;
				vCtr := vCtr + 1;
				if (get_pid_new%found and l_joiner_this_month_flag = 'Y' ) then

				open get_assact_id_new(l_org_id,l_effective_date_p,l_person_id);
				fetch get_assact_id_new into l_assact_id_new;
				close get_assact_id_new;
				/*Call the package to get the monthly contribution*/
				  if l_assact_id_new is not null then

					l_temp := pay_balance_pkg.get_value(l_defined_balance_id, l_assact_id_new);
					IF(l_temp > to_number(l_upper_base)) THEN
						l_temp := to_number(l_upper_base);
					ELSIF(l_temp < to_number(l_lower_base)) THEN
						l_temp := to_number(l_lower_base);
					END IF;
				  end if;
						if (l_temp >0 ) then
							l_n := l_n + 1;
						end if;
					l_sum := l_sum + l_temp;
				end if;
			IF (l_temp > 0) THEN

				vXMLTable(vCtr).TagName := 'G5-B-13'||'-'||l_new_count||'x10';
				if (get_pid_new %notfound or l_joiner_this_month_flag = 'N') then
				vXMLTable(vCtr).TagValue :=  null;
				else
                                l_fm_temp := null;
                                l_fm_temp := to_char(l_temp,lg_format_mask);
				--vXMLTable(vCtr).TagValue := trunc(l_temp);
                                vXMLTable(vCtr).TagValue := substr(l_fm_temp,1,length(l_fm_temp)-3);
				end if;
				vCtr := vCtr + 1;
				vXMLTable(vCtr).TagName := 'G5-B-12'||'-'||l_new_count||'x10';
				if (get_pid_new %notfound or l_joiner_this_month_flag = 'N') then
				vXMLTable(vCtr).TagValue :=  null;
				else
				--vXMLTable(vCtr).TagValue :=  l_temp - trunc(l_temp);
                                vXMLTable(vCtr).TagValue := substr(l_fm_temp,length(l_fm_temp)-1);
				end if;
				/*vXMLTable(vCtr).TagValue := l_temp - trunc(l_temp);*/
				vCtr := vCtr + 1;
				/* Details of the new hired employee*/
				open get_job (l_assgt_id_new,l_effective_date_p);
				fetch get_job into l_job;
				close get_job;
				vXMLTable(vCtr).TagName := 'G5-B-08'||'-'||l_new_count||'x10';
				if (get_pid_new %notfound or l_joiner_this_month_flag = 'N') then
				vXMLTable(vCtr).TagValue :=  null;
				else
				vXMLTable(vCtr).TagValue :=  l_job;
				end if;
				vCtr := vCtr + 1;
				open get_details_new(l_person_id,l_effective_date_p);
				fetch get_details_new into l_name_new,l_nationality,l_birth_date;
				close get_details_new;
				vXMLTable(vCtr).TagName := 'G5-B-01'||'-'||l_new_count||'x10';
				if (get_pid_new %notfound or l_joiner_this_month_flag = 'N') then
				vXMLTable(vCtr).TagValue :=  null;
				else
				vXMLTable(vCtr).TagValue := l_name_new;
				end if;
				vCtr := vCtr + 1;
				vXMLTable(vCtr).TagName := 'G5-B-03'||'-'||l_new_count||'x10';
				if (get_pid_new %notfound or l_joiner_this_month_flag = 'N') then
				vXMLTable(vCtr).TagValue :=  null;
				else
				begin
					SELECT meaning INTO l_nationality_mn
					FROM HR_LOOKUPS H, FND_SESSIONS S
					WHERE LOOKUP_TYPE = 'NATIONALITY'
					AND ENABLED_FLAG = 'Y'
					AND LOOKUP_CODE = l_nationality
					AND SESSION_ID = USERENV('SESSIONID')
					AND S.EFFECTIVE_DATE BETWEEN NVL(H.START_DATE_ACTIVE, S.EFFECTIVE_DATE)
					AND NVL(END_DATE_ACTIVE, S.EFFECTIVE_DATE)
					ORDER BY MEANING;
				exception
					when others then
						null;
				end;
				vXMLTable(vCtr).TagValue := l_nationality_mn;
				end if;
				vCtr := vCtr + 1;
				vXMLTable(vCtr).TagName := 'G5-B-07'||'-'||l_new_count||'x10';
				if (get_pid_new %notfound or l_joiner_this_month_flag = 'N') then
				vXMLTable(vCtr).TagValue :=  null;
				else
				vXMLTable(vCtr).TagValue :=substr(to_char(l_birth_date,'DD-MM-YYYY'),1,2);
				end if;
				vCtr := vCtr + 1;
				vXMLTable(vCtr).TagName := 'G5-B-06'||'-'||l_new_count||'x10';
				if (get_pid_new %notfound or l_joiner_this_month_flag = 'N') then
				vXMLTable(vCtr).TagValue :=  null;
				else
				vXMLTable(vCtr).TagValue :=substr(to_char(l_birth_date,'DD-MM-YYYY'),4,2);
				end if;
				vCtr := vCtr + 1;
				vXMLTable(vCtr).TagName := 'G5-B-05'||'-'||l_new_count||'x10';
				if (get_pid_new %notfound or l_joiner_this_month_flag = 'N') then
				vXMLTable(vCtr).TagValue :=  null;
				else
				vXMLTable(vCtr).TagValue :=substr(to_char(l_birth_date,'DD-MM-YYYY'),7,4);
				end if;
				vCtr := vCtr + 1;
				vXMLTable(vCtr).TagName := 'G5-B-04'||'-'||l_new_count||'x10';
/*Check for Civil Id for Saudi nationals and Passport Number for  Non Saudis.*/
				if (get_pid_new%found) then
					if (upper(l_nationality) = UPPER(FND_PROFILE.VALUE('PER_LOCAL_NATIONALITY'))) then
						l_civil_id := null;
						open get_civil_id(l_person_id,l_effective_date_p);
						fetch get_civil_id into l_civil_id;
						close get_civil_id;
						if (l_civil_id is not null) then
							vXMLTable(vCtr).TagValue :=  l_civil_id;
						else
							vXMLTable(vCtr).TagValue :=  null;
						end if;
					else
					l_passport_number := null;
						open get_passport_number(l_person_id,l_effective_date_p);
						fetch get_passport_number into l_passport_number;
						close get_passport_number;
						if (l_passport_number is not null) then
							vXMLTable(vCtr).TagValue :=  l_passport_number;
						else
							vXMLTable(vCtr).TagValue := null;
						end if;
					end if;
				end if;
/*ENd of Check for Civil Id for Saudi nationals and Passport Number for  Non Saudis.*/
				vCtr := vCtr + 1;
				open get_start_date(l_person_id);
				fetch get_start_date into l_join_date;
				close get_start_date;
				vXMLTable(vCtr).TagName := 'G5-B-11'||'-'||l_new_count||'x10';
				if (get_pid_new %notfound or l_joiner_this_month_flag = 'N') then
							vXMLTable(vCtr).TagValue :=  null;
				else
				vXMLTable(vCtr).TagValue :=  substr(to_char(l_join_date,'DD-MM-YYYY'),1,2);
				end if;
				vCtr := vCtr + 1;
				vXMLTable(vCtr).TagName := 'G5-B-10'||'-'||l_new_count||'x10';
				if (get_pid_new %notfound or l_joiner_this_month_flag = 'N') then
							vXMLTable(vCtr).TagValue :=  null;
				else
				vXMLTable(vCtr).TagValue :=  substr(to_char(l_join_date,'DD-MM-YYYY'),4,2);
				end if;
				vCtr := vCtr + 1;
				vXMLTable(vCtr).TagName := 'G5-B-09'||'-'||l_new_count||'x10';
				if (get_pid_new %notfound or l_joiner_this_month_flag = 'N') then
								vXMLTable(vCtr).TagValue :=  null;
				else
				vXMLTable(vCtr).TagValue := substr(to_char(l_join_date,'DD-MM-YYYY'),7,4);
				end if;
				vCtr := vCtr + 1;
				open get_GOSI_number_new(l_person_id);
				fetch get_GOSI_number_new into l_GOSI_number_new;
				close get_GOSI_number_new;
				vXMLTable(vCtr).TagName := 'G5-B-02'||'-'||l_new_count||'x10';
				if (get_pid_new %notfound or l_joiner_this_month_flag = 'N') then
							vXMLTable(vCtr).TagValue :=  null;
				else
				vXMLTable(vCtr).TagValue := l_GOSI_number_new;
				end if;
				vCtr := vCtr + 1;
				vXMLTable(vCtr).TagName := 'end_of_B';
				vXMLTable(vCtr).TagValue := null;
				vCtr := vCtr + 1;
				l_new_count := l_new_count + 1;
				new_count := new_count + 1;
			END IF;
				if (l_new_count = 11 or get_pid_new % notfound) then
						vXMLTable(vCtr).TagName := 'G5-B-10-11x11';
						if (l_n <>0) then
						vXMLTable(vCtr).TagValue := l_n;
						else
						vXMLTable(vCtr).TagValue := null;
						end if;
						vCtr := vCtr + 1;
						if (l_sum <>0 ) then
                                                  l_fm_sum := null;
                                                  l_fm_sum := to_char(l_sum,lg_format_mask);
					        vXMLTable(vCtr).TagName := 'G5-B-13-11x11';
						--vXMLTable(vCtr).TagValue := trunc(l_sum);
                                                vXMLTable(vCtr).TagValue := substr(l_fm_sum,1,length(l_fm_sum)-3);
						vCtr := vCtr + 1;
						vXMLTable(vCtr).TagName := 'G5-B-12-11x11';
						--vXMLTable(vCtr).TagValue := l_sum-trunc(l_sum);
                                                vXMLTable(vCtr).TagValue := substr(l_fm_sum,length(l_fm_sum)-1);
						vCtr := vCtr + 1;
						end if;
				end if;
				exit when (l_new_count = 11 or get_pid_new % notfound);
		end loop;
		loop
			fetch get_pid_term into l_person_id_term,l_assgt_id_term;
			if (get_pid_term %notfound) then
				l_person_id_term := null;
				l_assgt_id_term := null;
			end if;

			vXMLTable(vCtr).TagName := 'start_of_C';
			vXMLTable(vCtr).TagValue := null;
			vCtr := vCtr + 1;
			if(get_pid_term%found) then
			open get_assact_id_term(l_org_id,to_date(l_effective_date,'DD-MM-YYYY'),l_person_id_term);
			fetch get_assact_id_term into l_assact_id_term;
			close get_assact_id_term;
			if l_assact_id_term is not null then

				l_temp_term := pay_balance_pkg.get_value(l_defined_balance_id, l_assact_id_term);
					IF(l_temp_term > to_number(l_upper_base)) THEN
						l_temp_term := to_number(l_upper_base);
					ELSIF(l_temp_term < to_number(l_lower_base)) THEN
						l_temp_term := to_number(l_lower_base);
					END IF;
			end if;
			l_sum_term := l_sum_term + l_temp_term;
			end if;
		IF (l_temp_term >0 ) THEN

			open get_details_term(l_person_id_term);
			fetch get_details_term into l_term_date,l_term_reason;
			close get_details_term;
			vXMLTable(vCtr).TagName := 'G5-C-06'||'-'||l_term_count||'x10';
			if (get_pid_term %found and l_leaver_this_month_flag = 'Y' ) then
				l_t := l_t + 1;
			end if;
			if (get_pid_term %notfound or l_leaver_this_month_flag = 'N' ) then
						vXMLTable(vCtr).TagValue :=  null;
			else
			vXMLTable(vCtr).TagValue := substr(to_char(l_term_date,'DD-MM-YYYY'),1,2);
			end if;
			vCtr := vCtr + 1;
			vXMLTable(vCtr).TagName := 'G5-C-05'||'-'||l_term_count||'x10';
			if (get_pid_term %notfound or l_leaver_this_month_flag = 'N' ) then
						vXMLTable(vCtr).TagValue :=  null;
			else
			vXMLTable(vCtr).TagValue := substr(to_char(l_term_date,'DD-MM-YYYY'),4,2);
			end if;
			vCtr := vCtr + 1;
			vXMLTable(vCtr).TagName := 'G5-C-04'||'-'||l_term_count||'x10';
			if (get_pid_term %notfound or l_leaver_this_month_flag = 'N' ) then
						vXMLTable(vCtr).TagValue :=  null;
			else
			vXMLTable(vCtr).TagValue := substr(to_char(l_term_date,'DD-MM-YYYY'),7,4);
			end if;
			vCtr := vCtr + 1;
			/*call to the package to get monthly contribution*/
			vXMLTable(vCtr).TagName := 'G5-C-08'||'-'||l_term_count||'x10';
			if (get_pid_term %notfound or l_leaver_this_month_flag = 'N' ) then
						vXMLTable(vCtr).TagValue :=  null;
			else
                         l_fm_temp_term := null;
                         l_fm_temp_term := to_char(l_temp_term,lg_format_mask);
			--vXMLTable(vCtr).TagValue := l_temp_term;
                         vXMLTable(vCtr).TagValue := substr(l_fm_temp_term,1,length(l_fm_temp_term)-3);
			end if;
			vCtr := vCtr + 1;
			vXMLTable(vCtr).TagName := 'G5-C-07'||'-'||l_term_count||'x10';
			if (get_pid_term %notfound or l_leaver_this_month_flag = 'N' ) then
			vXMLTable(vCtr).TagValue :=  null;
			else
			--vXMLTable(vCtr).TagValue :=  l_temp_term - trunc(l_temp_term);
                         vXMLTable(vCtr).TagValue := substr(l_fm_temp_term,length(l_fm_temp_term)-1);
			end if;
			vCtr := vCtr + 1;
			open get_name_term(l_person_id_term,to_date(l_effective_date,'DD-MM-YYYY'));
			fetch get_name_term into l_name_term;
			close get_name_term;
			vXMLTable(vCtr).TagName := 'G5-C-01'||'-'||l_term_count||'x10';
			if (get_pid_term %notfound or l_leaver_this_month_flag = 'N' ) then
						vXMLTable(vCtr).TagValue :=  null;
			else
			vXMLTable(vCtr).TagValue := l_name_term;
			end if;
			vCtr := vCtr + 1;
			open get_GOSI_number_term (l_person_id_term);
			fetch get_GOSI_number_term into l_GOSI_number_term;
			close get_GOSI_number_term;
			vXMLTable(vCtr).TagName := 'G5-C-02'||'-'||l_term_count||'x10';
			if (get_pid_term %notfound or l_leaver_this_month_flag = 'N' ) then
						vXMLTable(vCtr).TagValue :=  null;
			else
			vXMLTable(vCtr).TagValue := l_GOSI_number_term;
			end if;
			vCtr := vCtr + 1;
			vXMLTable(vCtr).TagName := 'G5-C-03'||'-'||l_term_count||'x10';
			if (get_pid_term %notfound or l_leaver_this_month_flag = 'N' ) then
						vXMLTable(vCtr).TagValue :=  null;
			else
				/*SELECT meaning INTO l_term_reason_mn
				FROM hr_lookups hl
			        WHERE hl.lookup_type = 'LEAV_REAS'
			        AND to_date(l_effective_date'DD-MM-YYYY')
			        between nvl(hl.start_date_active,to_date( and hl.end_date_active
			        AND hl.lookup_code = l_term_reason;*/
                                                                                 BEGIN
			        SELECT meaning INTO l_term_reason_mn
			        FROM HR_LOOKUPS H, FND_SESSIONS S
			        WHERE LOOKUP_TYPE = 'LEAV_REAS'
				AND ENABLED_FLAG = 'Y'
				AND LOOKUP_CODE = l_term_reason
				AND SESSION_ID = USERENV('SESSIONID')
				AND S.EFFECTIVE_DATE BETWEEN NVL(H.START_DATE_ACTIVE, S.EFFECTIVE_DATE)
				AND NVL(END_DATE_ACTIVE, S.EFFECTIVE_DATE)
				ORDER BY MEANING;
                                                                                  EXCEPTION
                                                                                      WHEN OTHERS THEN
                                                                                         l_term_reason_mn := NULL;
                                                                                  END;
			vXMLTable(vCtr).TagValue := l_term_reason_mn;
			end if;
			vCtr := vCtr + 1;
			vXMLTable(vCtr).TagName := 'end_of_C';
			vXMLTable(vCtr).TagValue := null;
			vCtr := vCtr + 1;
			l_term_count := l_term_count + 1;
			term_count := term_count+1;
		END IF;
			if (l_term_count = 11 or get_pid_term % notfound or l_leaver_this_month_flag = 'N' ) then
				vXMLTable(vCtr).TagName := 'G5-C-09-11x11';
				if(l_t <>0) then
				vXMLTable(vCtr).TagValue := l_t;
				else
				vXMLTable(vCtr).TagValue := null;
				end if;
				vCtr := vCtr + 1;
				if (l_sum_term <> 0) then
                                 l_fm_sum_term := null;
                                 l_fm_sum_term := to_char(l_sum_term,lg_format_mask);
				vXMLTable(vCtr).TagName := 'G5-C-08-11x11';
				--vXMLTable(vCtr).TagValue := trunc(l_sum_term);
                                vXMLTable(vCtr).TagValue := substr(l_fm_sum_term,1,length(l_fm_sum_term)-3);
				vCtr := vCtr + 1;
				vXMLTable(vCtr).TagName := 'G5-C-07-11x11';
				--vXMLTable(vCtr).TagValue := l_sum_term-trunc(l_sum_term);
                                vXMLTable(vCtr).TagValue := substr(l_fm_sum_term,length(l_fm_sum_term)-1);
				vCtr := vCtr + 1;
				end if;
			end if;
			exit when (l_term_count = 11 or get_pid_term % notfound);
		end loop;
		l_n := 0;
		l_t := 0;
		l_sum :=0;
		l_sum_term:=0;
	hr_utility.set_location('Finished populating New and Terminated Report ',30);
		new_count := 0;
		term_count :=0;
		l_new_count := 1;
		l_term_count := 1;
		vXMLTable(vCtr).TagName := 'end_of_record';
		vXMLTable(vCtr).TagValue :=null;
		vCtr := vCtr + 1;
		exit when (get_pid_new%NOTFOUND and get_pid_term%NOTFOUND);
	end loop;
	end if;
	close get_pid_new;
	close get_pid_term;
END LOOP;
/*Msg in the temorary table*/
WritetoCLOB ( l_xfdf_blob );
        -- Write the values to XML File
     /*   fnd_file.put_line(fnd_file.log,'Calling Procedure to write into XML File');
        WritetoXML(
        p_request_id,
        p_report,
        p_output_fname);
        --p_output_fname := l_file_name;
        fnd_file.put_line(fnd_file.log,'------------Output XML File----------------');
        fnd_file.put_line(fnd_file.log,'File' || p_output_fname );
        fnd_file.put_line(fnd_file.log,'-------------------------------------------');*/
/*
EXCEPTION
        WHEN utl_file.invalid_path then
                hr_utility.set_message(8301, 'GHR_38830_INVALID_UTL_FILE_PATH');
                fnd_file.put_line(fnd_file.log,HR_UTILITY.get_message);
                hr_utility.raise_error;
--
    WHEN utl_file.invalid_mode then
        hr_utility.set_message(8301, 'GHR_38831_INVALID_FILE_MODE');
        fnd_file.put_line(fnd_file.log,HR_UTILITY.get_message);
                hr_utility.raise_error;
--
    WHEN utl_file.invalid_filehandle then
        hr_utility.set_message(8301, 'GHR_38832_INVALID_FILE_HANDLE');
        fnd_file.put_line(fnd_file.log,HR_UTILITY.get_message);
                hr_utility.raise_error;
--
    WHEN utl_file.invalid_operation then
        hr_utility.set_message(8301, 'GHR_38833_INVALID_OPER');
        fnd_file.put_line(fnd_file.log,HR_UTILITY.get_message);
                hr_utility.raise_error;
--
    WHEN utl_file.read_error then
        hr_utility.set_message(8301, 'GHR_38834_FILE_READ_ERROR');
        fnd_file.put_line(fnd_file.log,HR_UTILITY.get_message);
                hr_utility.raise_error;
--
    WHEN others THEN
       hr_utility.set_message(800,'FFU10_GENERAL_ORACLE_ERROR');
       hr_utility.set_message_token('2',substr(sqlerrm,1,200));
       fnd_file.put_line(fnd_file.log,HR_UTILITY.get_message);
           hr_utility.raise_error;
*/
END populate_new_and_term_wrks;
-------------------------------------------
----------------------------------------------
procedure populate_monthly_contributions
  (p_request_id                number
   ,p_report                   varchar2
   ,p_business_group_id        number
   ,p_org_structure_version_id number   default null
   ,p_organisation_id          number
   ,p_effective_month          varchar2
   ,p_effective_year           varchar2
   ,p_arrears                  number   default 0
   ,p_penalty_charge           number   default 0
   ,p_discount                 number   default 0
   ,p_payment_method           varchar2 default null
   ,l_xfdf_blob OUT NOCOPY BLOB) as
  l_input_date              varchar2(30);
  l_parent_id               number;
  l_payroll_id              number;
  l_payroll_name            number;
  l_effective_date          date;
  l_eff_term_date          date;
  l_prev_mon_date           date;
  l_prev_term_date          date;
  l_prev2_mon_date           date;
  l_prev2_term_date          date;
  --l_payroll_action_id       number;
  --l_assignment_action_id    number;
  --l_saudi_national          varchar2(1) := 'N';
  l_def_nationality_cd      VARCHAR2(80);
  l_def_nationality         VARCHAR2(80);
  --l_per_nationality         VARCHAR2(80);
  l_haz_month_db            number;
  l_ann_month_db            number;
  --l_g_annu_db               number;
  --l_g_haz_db                number;
  --l_hazards                 number := 0;
  l_hazards_new             number := 0;
  l_hazards_ter             number := 0;
  --l_non_hazards             number := 0;
  --l_non_hazards_new         number := 0;
  --l_non_hazards_ter         number := 0;
  l_hazards_new_all         number := 0;
  l_hazards_ter_all         number := 0;
  --l_annuities_saudi         number := 0;
  --l_hazards_saudi           number := 0;
  l_annuities_saudi_new     number := 0;
  l_hazards_saudi_new       number := 0;
  l_annuities_saudi_ter     number := 0;
  l_hazards_saudi_ter       number := 0;
  --l_haz_ann_saudi           number := 0;
  l_haz_ann_saudi_new       number := 0;
  l_haz_ann_saudi_ter       number := 0;
  l_hc_haz                  number := 0;
  l_hc_haz_new              number := 0;
  l_hc_haz_ter              number := 0;
  l_hc_ann_saudi            number := 0;
  l_hc_haz_saudi            number := 0;
  l_hc_ann_saudi_new        number := 0;
  l_hc_haz_saudi_new        number := 0;
  l_hc_ann_saudi_ter        number := 0;
  l_hc_haz_saudi_ter        number := 0;
  l_hc_haz_ann_saudi        number := 0;
  l_hc_haz_ann_saudi_new    number := 0;
  l_hc_haz_ann_saudi_ter    number := 0;
  l_hc_haz_non              number := 0;
  l_hc_haz_non_new          number := 0;
  l_hc_haz_non_ter          number := 0;
  --l_curr_ann                number := 0;
  l_curr_ann_saudi          number := 0;
  l_curr_ann_saudi_new      number := 0;
  l_curr_ann_saudi_new_ter  number := 0;
  l_curr_ann_saudi_ter      number := 0;
  l_curr_haz                number := 0;
  l_curr_haz_saudi          number := 0;
  l_curr_haz_saudi_new      number := 0;
  l_curr_haz_new            number := 0;
  l_curr_haz_new_all        number := 0;
  l_curr_haz_saudi_ter      number := 0;
  l_curr_haz_saudi_new_ter  number := 0;
  l_curr_haz_ter            number := 0;
  l_curr_haz_ter_all        number := 0;
  l_curr_haz_new_ter        number := 0;
  l_curr_haz_new_ter_all    number := 0;
  l_curr_haz_all            number := 0;
  l_curr_annuities          number := 0;
  l_curr_hazards            number := 0;
  l_curr_haz_ann            number := 0;
  l_curr_haz_ann_saudi      number := 0;
  l_curr_haz_ann_saudi_new  number := 0;
  l_curr_haz_ann_saudi_ter  number := 0;
  l_curr_haz_ann_saudi_new_ter  number := 0;
  l_tot_curr_ann_saudi      number := 0;
  l_tot_curr_haz_all        number := 0;
  l_tot_curr_haz_ann_saudi  number := 0;
  l_tot_prev_ann_saudi      number := 0;
  l_tot_prev_haz_all        number := 0;
  l_tot_prev_haz_ann_saudi  number := 0;
  l_prev_ann_saudi          number := 0;
  l_prev_ann_saudi_new      number := 0;
  l_prev_ann_saudi_ter      number := 0;
  l_prev_haz_all            number := 0;
  l_prev_haz_new_all        number := 0;
  l_prev_haz_ter_all        number := 0;
  l_prev_haz_ann_saudi      number := 0;
  l_prev_haz_ann_saudi_new  number := 0;
  l_prev_haz_ann_saudi_ter  number := 0;
  l_prev_haz_saudi          number := 0;
  l_prev_haz                number := 0;
  l_prev_haz_saudi_new      number := 0;
  l_prev_haz_new            number := 0;
  l_prev_haz_saudi_ter      number := 0;
  l_prev_haz_ter            number := 0;
  l_prev_ann_saudi_new_ter  number := 0;
  l_prev_haz_saudi_new_ter  number := 0;
  l_prev_haz_ann_saudi_new_ter  number := 0;
  l_prev_haz_new_ter        number := 0;
  l_prev_haz_new_ter_all    number := 0;
  l_annuities_saudi_new_ter number := 0;
  l_hazards_saudi_new_ter   number := 0;
  l_hazards_new_ter         number := 0;
  --l_hazards_saudi_new_ter   number := 0;
  l_tot_ann_saudi           number := 0;
  l_tot_haz_all             number := 0;
  l_tot_haz_ann_saudi       number := 0;
  l_hc_prev_ann_saudi_nn    number := 0;
  l_hc_prev_ann_saudi_ny    number := 0;
  l_hc_prev_ann_saudi_yn    number := 0;
  l_hc_prev_ann_saudi_yy    number := 0;
  l_hc_prev_haz_saudi_nn    number := 0;
  l_hc_prev_haz_saudi_ny    number := 0;
  l_hc_prev_haz_saudi_yn    number := 0;
  l_hc_prev_haz_saudi_yy    number := 0;
  l_hc_prev_haz_non_nn      number := 0;
  l_hc_prev_haz_non_ny      number := 0;
  l_hc_prev_haz_non_yn      number := 0;
  l_hc_prev_haz_non_yy      number := 0;
  l_hc_prev_haz_ann_saudi_nn number := 0;
  l_hc_prev_haz_ann_saudi_yn number := 0;
  l_hc_prev_haz_ann_saudi_yy number := 0;
  l_hc_prev_haz_ann_saudi_ny number := 0;
  l_hc_curr_ann_saudi_nn    number := 0;
  l_hc_curr_ann_saudi_ny    number := 0;
  l_hc_curr_ann_saudi_yn    number := 0;
  l_hc_curr_ann_saudi_yy    number := 0;
  l_hc_curr_haz_saudi_nn    number := 0;
  l_hc_curr_haz_saudi_ny    number := 0;
  l_hc_curr_haz_saudi_yn    number := 0;
  l_hc_curr_haz_saudi_yy    number := 0;
  l_hc_curr_haz_non_nn      number := 0;
  l_hc_curr_haz_non_ny      number := 0;
  l_hc_curr_haz_non_yn      number := 0;
  l_hc_curr_haz_non_yy      number := 0;
  l_hc_curr_haz_ann_saudi_nn number := 0;
  l_hc_curr_haz_ann_saudi_yn number := 0;
  l_hc_curr_haz_ann_saudi_yy number := 0;
  l_hc_curr_haz_ann_saudi_ny number := 0;
  l_hc_haz_new_all          number := 0;
  l_hc_haz_ter_all          number := 0;
  l_hc_tot_ann_saudi        number := 0;
  l_hc_tot_haz              number := 0;
  l_hc_tot_haz_ann_saudi    number := 0;
  TYPE t_rec_gre IS RECORD(GRE_NAME varchar2(80), GRE_ID number);
  /*Table type for variable for storing legal entities within the hierarchy*/
  TYPE t_tab_gre IS TABLE OF t_rec_gre
      INDEX BY BINARY_INTEGER;
  t_legal_entity            t_tab_gre;
  l_gre_present             number := 0;
  i                         number := 0;
  l_gre_name                varchar2(80);
  l_gre_id                  number := 0;
  l_err                     number := 0;
  l_tax_unit_id             number := 0;
  l_gosi_office_id          number;
  l_gosi_office             varchar2(260);
  l_gosi_office_code        varchar2(30);
  l_employer_gosi_number    varchar2(30);
  /*p_l_fp1 UTL_FILE.FILE_TYPE;
  l_audit_log_dir1 varchar2(500) := '/sqlcom/outbound';
  l_file_name1 varchar2(50);
  l_check_flag1 number;
  l_file_created            number := 0;*/
  /*Cursor for fetching organizations in the hierarchy*/
  cursor csr_org_hierarchy is
  select pose.organization_id_child org
  from   per_org_structure_elements pose
  connect by pose.organization_id_parent = prior pose.organization_id_child
  and pose.org_structure_version_id = p_org_structure_version_id
  start with pose.organization_id_parent = (nvl(p_organisation_id,l_parent_id))
  and pose.org_structure_version_id = p_org_structure_version_id
  union
  select (nvl(p_organisation_id,l_parent_id)) org
  from   dual;
  rec_org_id    csr_org_hierarchy%rowtype;
  /*Cursor for fetching gosi office details*/
  cursor csr_gosi_office_details is
  select org_information1
         ,org_information2
  from   hr_organization_information
  where  organization_id = l_tax_unit_id
  and    org_information_context = 'SA_EMPLOYER_GOSI_DETAILS';
  rec_gosi_office_details  csr_gosi_office_details%rowtype;
  /*Cursor for fetching gosi office code*/
  cursor csr_gosi_code is
  select org_information1
  from   hr_organization_information
  where  organization_id = l_gosi_office_id
  and    org_information_context = 'SA_GOSI_OFFICE_DETAILS';
  rec_gosi_code  csr_gosi_code%rowtype;
        l_file_name varchar2(50);
        l_audit_log_dir varchar2(500);
  /*Variables required for amount formatting*/
  l_fm_tot_prev_ann_saudi        varchar2(50) := null;
  l_fm_tot_prev_haz_all          varchar2(50) := null;
  l_fm_tot_prev_haz_ann_saudi    varchar2(50) := null;
  l_fm_annuities_saudi_new       varchar2(50) := null;
  l_fm_hazards_new_all           varchar2(50) := null;
  l_fm_haz_ann_saudi_new         varchar2(50) := null;
  l_fm_annuities_saudi_ter       varchar2(50) := null;
  l_fm_hazards_ter_all           varchar2(50) := null;
  l_fm_haz_ann_saudi_ter         varchar2(50) := null;
  l_fm_tot_curr_ann_saudi        varchar2(50) := null;
  l_fm_tot_curr_haz_all          varchar2(50) := null;
  l_fm_tot_curr_haz_ann_saudi    varchar2(50) := null;
  l_fm_curr_annuities            varchar2(50) := null;
  l_fm_curr_hazards              varchar2(50) := null;
  l_fm_curr_haz_ann              varchar2(50) := null;
  l_fm_arrears                   varchar2(50) := null;
  l_fm_penalty_charge            varchar2(50) := null;
  l_fm_discount                  varchar2(50) := null;
  l_fm_total                     varchar2(50) := null;
  l_p_saudi_ann                  number := 0;
  l_p_saudi_ann_haz              number := 0;
  l_p_haz                        number := 0;
  l_p_joiner_saudi_ann           number := 0;
  l_p_joiner_saudi_ann_haz       number := 0;
  l_p_joiner_haz                 number := 0;
  l_p_leaver_saudi_ann           number := 0;
  l_p_leaver_saudi_ann_haz       number := 0;
  l_p_leaver_haz                 number := 0;
  l_c_saudi_ann                  number := 0;
  l_c_saudi_ann_haz              number := 0;
  l_c_haz                        number := 0;
  l_c_joiner_saudi_ann           number := 0;
  l_c_joiner_saudi_ann_haz       number := 0;
  l_c_joiner_haz                 number := 0;
  l_c_leaver_saudi_ann           number := 0;
  l_c_leaver_saudi_ann_haz       number := 0;
  l_c_leaver_haz                 number := 0;
  l_gosi_id                      number := null;
  l_employer_gosi_haz_id         number := null;
  l_employee_gosi_ann_id         number := null;
  l_p_joiner_nonsaudi_haz        number := 0;   /*Added for enhancement*/
  l_c_joiner_nonsaudi_haz        number := 0;   /*Added for enhancement*/
  l_p_leaver_nonsaudi_haz        number := 0;   /*Added for enhancement*/
  l_c_leaver_nonsaudi_haz        number := 0;   /*Added for enhancement*/
  l_p_nonsaudi_haz               number := 0;   /*Added for enhancement*/
  l_c_nonsaudi_haz               number := 0;   /*Added for enhancement*/
  l_hc_haz_nonsaudi_ter          number := 0;   /*Added for enhancement*/
  l_hazards_pct                  number := 0;   /*Added for enhancement*/
  l_ee_annuities_pct             number := 0;   /*Added for enhancement*/
  l_er_annuities_pct             number := 0;   /*Added for enhancement*/
  l_gosi_ref_saudi_new           number := 0;   /*Added for enhancement*/
  l_gosi_ref_nonsaudi_new        number := 0;   /*Added for enhancement*/
  l_gosi_ref_saudi_ter           number := 0;   /*Added for enhancement*/
  l_gosi_ref_nonsaudi_ter        number := 0;   /*Added for enhancement*/
  l_sum_saudi_hazards_t          number := 0;  /*Copied for enhancement*/
  l_fm_gosi_ref_saudi_new        varchar2(50) := null; /*Added for enhancement*/
  l_fm_gosi_ref_nonsaudi_new     varchar2(50) := null; /*Added for enhancement*/
  l_fm_gosi_ref_saudi_ter        varchar2(50) := null; /*Added for enhancement*/
  l_fm_gosi_ref_nonsaudi_ter     varchar2(50) := null; /*Added for enhancement*/
  l_emp_annuity                  number := 0; /*Added for enhancement*/
  l_tot_l_emp_annuity            number := 0; /*Added for enhancement*/
  l_tot_j_emp_annuity            number := 0; /*Added for enhancement*/
begin
  set_currency_mask(p_business_group_id);
  l_input_date := '01-'||p_effective_month||'-'||p_effective_year;
  l_effective_date := last_day(to_date(l_input_date,'DD-MM-YYYY'));
  /*Following 1 line changed for enhancement 5283457
  l_eff_term_date := to_date('28-'||to_char(l_effective_date,'MM-YYYY'),'DD-MM-YYYY');*/
  l_eff_term_date := l_effective_date;
  insert into fnd_sessions(session_id,effective_date) values(userenv('sessionid'),l_effective_date);
        -- To clear the PL/SQL Table values.
        vXMLTable.DELETE;
        vCtr := 1;
      hr_utility.set_location('Before hierarchy logic ',40);
        /*Commented the hierarchy part on 15-Jan-2004 */
/*
  if p_org_structure_version_id is not null then
    if p_organisation_id is null then
      begin
        select distinct pose.organization_id_parent
        into   l_parent_id
        from   per_org_structure_elements pose
        where  pose.org_structure_version_id = p_org_structure_version_id
        and pose.organization_id_parent not in (select pose1.organization_id_child
                                                from per_org_structure_elements pose1
                                                where pose1.org_structure_version_id = p_org_structure_version_id);
      exception
        when others then
          l_err := 1;
      end;
    end if;
    if l_err = 0 then
      open csr_org_hierarchy;
      loop
        fetch csr_org_hierarchy into rec_org_id;
        exit when csr_org_hierarchy%notfound;
        hr_sa_org_info.get_employer_name(rec_org_id.org,l_gre_name,p_business_group_id,p_org_structure_version_id);
        begin
          select organization_id
          into   l_gre_id
          from   hr_all_organization_units
          where  name = l_gre_name
          and business_group_id = p_business_group_id;
        exception
          when others then
            l_err := 1;
        end;
        i := 0;
        IF t_legal_entity.count <> 0 then
        --WHILE t_legal_entity.last
        l_gre_present := 0;
        FOR i in t_legal_entity.first..t_legal_entity.last
          LOOP
            IF t_legal_entity(i).gre_id = l_gre_id THEN
              l_gre_present := 1;
              EXIT;
            END IF;
            --i := i + 1;
          END LOOP;
          IF l_gre_present = 0 THEN
            i := t_legal_entity.count;
            t_legal_entity(i + 1).gre_id := l_gre_id;
            t_legal_entity(i + 1).gre_name := l_gre_name;
          END IF;
        ELSE
          i := t_legal_entity.count;
            t_legal_entity(i + 1).gre_id := l_gre_id;
            t_legal_entity(i + 1).gre_name := l_gre_name;
        END IF;
      END LOOP;
      CLOSE csr_org_hierarchy;
    end if;
 end if;*/
  select add_months(l_effective_date,-1)
  into   l_prev_mon_date
  from   dual;
  /* Following one line changed for enhancement 5283457
  l_prev_term_date := to_date('28-'||to_char(l_prev_mon_date,'MM-YYYY'),'DD-MM-YYYY');*/
  l_prev_term_date := last_day(l_prev_mon_date);
  select add_months(l_prev_mon_date,-1)
  into   l_prev2_mon_date
  from   dual;
  /* Following one line changed for enhancement 5283457
  l_prev2_term_date := to_date('28-'||to_char(l_prev2_mon_date,'MM-YYYY'),'DD-MM-YYYY');*/
  l_prev2_term_date := last_day(l_prev2_mon_date);
  l_def_nationality_cd := UPPER(FND_PROFILE.VALUE('PER_LOCAL_NATIONALITY')); --'AM'; -- UPPER(FND_PROFILE.VALUE('PER_LOCAL_NATIONALITY'));
  BEGIN
    SELECT meaning INTO l_def_nationality
    FROM hr_lookups
    WHERE lookup_type = 'NATIONALITY'
    AND lookup_code = l_def_nationality_cd;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      NULL;
  END;
  --l_def_nationality :='American';
  --Fetch defined_balance_id's
  select  u.creator_id
  into    l_ann_month_db
  from    ff_user_entities  u,
          ff_database_items d
  where   d.user_name = 'GOSI_ANNUITIES_NAT_JOINER_LEAVER_TU_MONTH'
  and     u.user_entity_id = d.user_entity_id
  and     u.legislation_code = 'SA'
  and     u.business_group_id is null
  and     u.creator_type = 'B';
  select  u.creator_id
  into    l_haz_month_db
  from    ff_user_entities  u,
          ff_database_items d
  where   d.user_name = 'GOSI_HAZARDS_NAT_JOINER_LEAVER_TU_MONTH'
  and     u.user_entity_id = d.user_entity_id
  and     u.legislation_code = 'SA'
  and     u.business_group_id is null
  and     u.creator_type = 'B';
  if p_org_structure_version_id is null then
        /*Commented the hierarchy part on 15-Jan-2004 */
/*
    l_gre_id := null;
    l_gre_name := null;
    hr_sa_org_info.get_employer_name(p_organisation_id,l_gre_name,p_business_group_id);
    begin
      select organization_id
      into   l_gre_id
      from   hr_all_organization_units
      where  name = l_gre_name
      and business_group_id = p_business_group_id;
    exception
      when others then
        l_err := 1;
    end;
    t_legal_entity(1).gre_id := l_gre_id;
    t_legal_entity(1).gre_name := l_gre_name;*/
        /*Commented the hierarchy part on 15-Jan-2004 */
-- New code begins
                l_gre_id := p_organisation_id;
		begin
		select name
		into   l_gre_name
		from   hr_all_organization_units
		where  organization_id= l_gre_id
		and business_group_id =p_business_group_id;
		exception
			when others then
				l_err := 1;
		end;
		t_legal_entity(1).gre_id := l_gre_id;
		t_legal_entity(1).gre_name := l_gre_name;
-- New code ends
  end if;
hr_utility.set_location('Calling Procedure to Populate Monthly Contribution Report ',50);
  FOR i in t_legal_entity.first..t_legal_entity.last
    LOOP
      l_tax_unit_id := t_legal_entity(i).gre_id;
      /*Get details for section A*/
      open csr_gosi_office_details;
        fetch csr_gosi_office_details into rec_gosi_office_details;
        l_employer_gosi_number := rec_gosi_office_details.org_information1;
        l_gosi_office_id := rec_gosi_office_details.org_information2;
      close csr_gosi_office_details;
      /*Fetch gosi_office name and gosi office code*/
      open csr_gosi_code;
        fetch csr_gosi_code into rec_gosi_code;
        l_gosi_office_code := rec_gosi_code.org_information1;
      close csr_gosi_code;
      begin
        select name
        into   l_gosi_office
        from   hr_all_organization_units
        where  organization_id = l_gosi_office_id;
        exception
          when others then
            l_err := 1;
        end;
  --vXMLTable.DELETE;
  --vCtr := 1;
  vXMLTable(vCtr).TagName := 'G4-A-01-1';
  vXMLTable(vCtr).TagValue := l_gosi_office_code||'     '||l_gosi_office;
  vctr := vctr + 1;
  /*vXMLTable(vCtr).TagName := 'G4-A-01-2-1';
  vXMLTable(vCtr).TagValue := SUBSTR(l_gosi_office_code,2,1);
  vctr := vctr + 1;
  vXMLTable(vCtr).TagName := 'G4-A-01-2-2';
  vXMLTable(vCtr).TagValue := SUBSTR(l_gosi_office_code,1,1);
  vctr := vctr + 1;*/
  vXMLTable(vCtr).TagName := 'G4-A-02';
  vXMLTable(vCtr).TagValue := p_effective_month;
  vctr := vctr + 1;
  vXMLTable(vCtr).TagName := 'G4-A-03';
  vXMLTable(vCtr).TagValue := p_effective_year;
  vctr := vctr + 1;
  vXMLTable(vCtr).TagName := 'G4-A-04';
  vXMLTable(vCtr).TagValue := t_legal_entity(i).gre_name;
  vctr := vctr + 1;
  vXMLTable(vCtr).TagName := 'G4-A-05-1';
  vXMLTable(vCtr).TagValue := SUBSTR(l_employer_gosi_number,9,1);
  vctr := vctr + 1;
  vXMLTable(vCtr).TagName := 'G4-A-05-2';
  vXMLTable(vCtr).TagValue := SUBSTR(l_employer_gosi_number,8,1);
  vctr := vctr + 1;
  vXMLTable(vCtr).TagName := 'G4-A-05-3';
  vXMLTable(vCtr).TagValue := SUBSTR(l_employer_gosi_number,7,1);
  vctr := vctr + 1;
  vXMLTable(vCtr).TagName := 'G4-A-05-4';
  vXMLTable(vCtr).TagValue := SUBSTR(l_employer_gosi_number,6,1);
  vctr := vctr + 1;
  vXMLTable(vCtr).TagName := 'G4-A-05-5';
  vXMLTable(vCtr).TagValue := SUBSTR(l_employer_gosi_number,5,1);
  vctr := vctr + 1;
  vXMLTable(vCtr).TagName := 'G4-A-05-6';
  vXMLTable(vCtr).TagValue := SUBSTR(l_employer_gosi_number,4,1);
  vctr := vctr + 1;
  vXMLTable(vCtr).TagName := 'G4-A-05-7';
  vXMLTable(vCtr).TagValue := SUBSTR(l_employer_gosi_number,3,1);
  vctr := vctr + 1;
  vXMLTable(vCtr).TagName := 'G4-A-05-8';
  vXMLTable(vCtr).TagValue := SUBSTR(l_employer_gosi_number,2,1);
  vctr := vctr + 1;
  vXMLTable(vCtr).TagName := 'G4-A-05-9';
  vXMLTable(vCtr).TagValue := SUBSTR(l_employer_gosi_number,1,1);
  vctr := vctr + 1;
  pay_balance_pkg.set_context('TAX_UNIT_ID',l_tax_unit_id);
  pay_balance_pkg.set_context('DATE_EARNED',FND_DATE.DATE_TO_CANONICAL(l_prev_mon_date));
  /***To fetch for pprevious months, using existing emp + new + terminated after 28th  *****/
  pay_balance_pkg.set_context('SOURCE_NUMBER',1);
  pay_balance_pkg.set_context('SOURCE_TEXT','N');
  pay_balance_pkg.set_context('SOURCE_TEXT2','N');
  l_prev_ann_saudi := pay_balance_pkg.get_value(l_ann_month_db,null);
  l_prev_haz_saudi := pay_balance_pkg.get_value(l_haz_month_db,null);
  l_prev_haz_ann_saudi := l_prev_ann_saudi + l_prev_haz_saudi;
  pay_balance_pkg.set_context('SOURCE_NUMBER',2);
  pay_balance_pkg.set_context('SOURCE_TEXT','N');
  pay_balance_pkg.set_context('SOURCE_TEXT2','N');
  l_prev_haz := pay_balance_pkg.get_value(l_haz_month_db,null);
  l_prev_haz_all := l_prev_haz_saudi + l_prev_haz;
  pay_balance_pkg.set_context('SOURCE_NUMBER',1);
  pay_balance_pkg.set_context('SOURCE_TEXT','Y');
  pay_balance_pkg.set_context('SOURCE_TEXT2','N');
  l_prev_ann_saudi_new := pay_balance_pkg.get_value(l_ann_month_db,null);
  l_prev_haz_saudi_new := pay_balance_pkg.get_value(l_haz_month_db,null);
  l_prev_haz_ann_saudi_new := l_prev_ann_saudi_new + l_prev_haz_saudi_new;
  pay_balance_pkg.set_context('SOURCE_NUMBER',2);
  pay_balance_pkg.set_context('SOURCE_TEXT','Y');
  pay_balance_pkg.set_context('SOURCE_TEXT2','N');
  l_prev_haz_new := pay_balance_pkg.get_value(l_haz_month_db,null);
  l_prev_haz_new_all := l_prev_haz_saudi_new + l_prev_haz_new;
  pay_balance_pkg.set_context('SOURCE_NUMBER',1);
  pay_balance_pkg.set_context('SOURCE_TEXT','N');
  pay_balance_pkg.set_context('SOURCE_TEXT2','Y');
  l_prev_ann_saudi_ter := pay_balance_pkg.get_value(l_ann_month_db,null);
  l_prev_haz_saudi_ter := pay_balance_pkg.get_value(l_haz_month_db,null);
  l_prev_haz_ann_saudi_ter := l_prev_ann_saudi_ter + l_prev_haz_saudi_ter;
  pay_balance_pkg.set_context('SOURCE_NUMBER',2);
  pay_balance_pkg.set_context('SOURCE_TEXT','N');
  pay_balance_pkg.set_context('SOURCE_TEXT2','Y');
  l_prev_haz_ter := pay_balance_pkg.get_value(l_haz_month_db,null);
  l_prev_haz_ter_all := l_prev_haz_saudi_ter + l_prev_haz_ter;
  /*Following code for joiner-leaver (after 28th) in same month*/
  pay_balance_pkg.set_context('SOURCE_NUMBER',1);
  pay_balance_pkg.set_context('SOURCE_TEXT','Y');
  pay_balance_pkg.set_context('SOURCE_TEXT2','Y');
  l_prev_ann_saudi_new_ter := pay_balance_pkg.get_value(l_ann_month_db,null);
  l_prev_haz_saudi_new_ter := pay_balance_pkg.get_value(l_haz_month_db,null);
  l_prev_haz_ann_saudi_new_ter := l_prev_ann_saudi_new_ter + l_prev_haz_saudi_new_ter;
  pay_balance_pkg.set_context('SOURCE_NUMBER',2);
  pay_balance_pkg.set_context('SOURCE_TEXT','Y');
  pay_balance_pkg.set_context('SOURCE_TEXT2','Y');
  l_prev_haz_new_ter := pay_balance_pkg.get_value(l_haz_month_db,null);
  l_prev_haz_new_ter_all := l_prev_haz_saudi_new_ter + l_prev_haz_new_ter;
  l_tot_prev_ann_saudi := l_prev_ann_saudi + l_prev_ann_saudi_new + l_prev_ann_saudi_ter + l_prev_ann_saudi_new_ter;
  l_tot_prev_haz_all := l_prev_haz_all + l_prev_haz_new_all + l_prev_haz_ter_all + l_prev_haz_new_ter_all;
  l_tot_prev_haz_ann_saudi := l_prev_haz_ann_saudi + l_prev_haz_ann_saudi_new + l_prev_haz_ann_saudi_ter + l_prev_haz_ann_saudi_new_ter;
  /*******************************************************/
  pay_balance_pkg.set_context('DATE_EARNED',FND_DATE.DATE_TO_CANONICAL(l_effective_date));
  pay_balance_pkg.set_context('SOURCE_NUMBER',1);
  pay_balance_pkg.set_context('SOURCE_TEXT','N');
  pay_balance_pkg.set_context('SOURCE_TEXT2','N');
  l_curr_ann_saudi := pay_balance_pkg.get_value(l_ann_month_db,null);
  l_curr_haz_saudi := pay_balance_pkg.get_value(l_haz_month_db,null);
  l_curr_haz_ann_saudi := l_curr_ann_saudi + l_curr_haz_saudi;
  pay_balance_pkg.set_context('SOURCE_NUMBER',2);
  pay_balance_pkg.set_context('SOURCE_TEXT','N');
  pay_balance_pkg.set_context('SOURCE_TEXT2','N');
  l_curr_haz := pay_balance_pkg.get_value(l_haz_month_db,null);
  l_curr_haz_all := l_curr_haz_saudi + l_curr_haz;
  pay_balance_pkg.set_context('SOURCE_NUMBER',1);
  pay_balance_pkg.set_context('SOURCE_TEXT','Y');
  pay_balance_pkg.set_context('SOURCE_TEXT2','N');
  l_curr_ann_saudi_new := pay_balance_pkg.get_value(l_ann_month_db,null);
  l_curr_haz_saudi_new := pay_balance_pkg.get_value(l_haz_month_db,null);
  l_curr_haz_ann_saudi_new := l_curr_ann_saudi_new + l_curr_haz_saudi_new;
  pay_balance_pkg.set_context('SOURCE_NUMBER',2);
  pay_balance_pkg.set_context('SOURCE_TEXT','Y');
  pay_balance_pkg.set_context('SOURCE_TEXT2','N');
  l_curr_haz_new := pay_balance_pkg.get_value(l_haz_month_db,null);
  l_curr_haz_new_all := l_curr_haz_saudi_new + l_curr_haz_new;
  pay_balance_pkg.set_context('SOURCE_NUMBER',1);
  pay_balance_pkg.set_context('SOURCE_TEXT','N');
  pay_balance_pkg.set_context('SOURCE_TEXT2','Y');
  l_curr_ann_saudi_ter := pay_balance_pkg.get_value(l_ann_month_db,null);
  l_curr_haz_saudi_ter := pay_balance_pkg.get_value(l_haz_month_db,null);
  l_curr_haz_ann_saudi_ter := l_curr_ann_saudi_ter + l_curr_haz_saudi_ter;
  pay_balance_pkg.set_context('SOURCE_NUMBER',2);
  pay_balance_pkg.set_context('SOURCE_TEXT','N');
  pay_balance_pkg.set_context('SOURCE_TEXT2','Y');
  l_curr_haz_ter := pay_balance_pkg.get_value(l_haz_month_db,null);
  l_curr_haz_ter_all := l_curr_haz_saudi_ter + l_curr_haz_ter;
  pay_balance_pkg.set_context('SOURCE_NUMBER',1);
  pay_balance_pkg.set_context('SOURCE_TEXT','Y');
  pay_balance_pkg.set_context('SOURCE_TEXT2','Y');
  l_curr_ann_saudi_new_ter := pay_balance_pkg.get_value(l_ann_month_db,null);
  l_curr_haz_saudi_new_ter := pay_balance_pkg.get_value(l_haz_month_db,null);
  l_curr_haz_ann_saudi_new_ter := l_curr_ann_saudi_new_ter + l_curr_haz_saudi_new_ter;
  pay_balance_pkg.set_context('SOURCE_NUMBER',2);
  pay_balance_pkg.set_context('SOURCE_TEXT','Y');
  pay_balance_pkg.set_context('SOURCE_TEXT2','Y');
  l_curr_haz_new_ter := pay_balance_pkg.get_value(l_haz_month_db,null);
  l_curr_haz_new_ter_all := l_curr_haz_saudi_new_ter + l_curr_haz_new_ter;
  l_tot_curr_ann_saudi := l_curr_ann_saudi + l_curr_ann_saudi_new + l_curr_ann_saudi_ter + l_curr_ann_saudi_new_ter;
  l_tot_curr_haz_all := l_curr_haz_all + l_curr_haz_new_all + l_curr_haz_ter_all + l_curr_haz_new_ter_all;
  l_tot_curr_haz_ann_saudi := l_curr_haz_ann_saudi + l_curr_haz_ann_saudi_new + l_curr_haz_ann_saudi_ter + l_curr_haz_ann_saudi_new_ter;
  /********************************************************/
  --New Joiners
  --for Saudi Annuities
  l_annuities_saudi_new := l_curr_ann_saudi_new + l_curr_ann_saudi_new_ter;
  --for all hazards
  l_hazards_new_all := l_curr_haz_new_all + l_curr_haz_new_ter_all;
  --for saudi annuities and hazards
  l_haz_ann_saudi_new := l_annuities_saudi_new + l_curr_haz_saudi_new + l_curr_haz_saudi_new_ter;
  /*Computation of leavers data */
  /******** Computation done after calculating leavers headcout
  l_annuities_saudi_ter := (l_tot_prev_ann_saudi) + (l_annuities_saudi_new) - (l_tot_curr_ann_saudi);
  l_hazards_ter_all := (l_tot_prev_haz_all) + (l_hazards_new_all) - (l_tot_curr_haz_all);
  l_haz_ann_saudi_ter := (l_tot_prev_haz_ann_saudi) + (l_haz_ann_saudi_new) - (l_tot_curr_haz_ann_saudi);********/
  /*For Section C*/
  l_curr_annuities := l_tot_curr_ann_saudi;
  l_curr_hazards := l_tot_curr_haz_all;
  l_curr_haz_ann := l_curr_annuities + l_curr_hazards;
  /****Fetch headcounts****/
  /*Fetch element_type_id for elements GOSI, Employee GOSI Annuities, Employee GOSI Hazards*/
  SELECT element_type_id
  INTO   l_gosi_id
  FROM   pay_element_types_f
  WHERE  element_name = 'GOSI'
  AND    legislation_code = 'SA'
  AND    l_effective_date BETWEEN effective_start_date AND effective_end_date;
  SELECT element_type_id
  INTO   l_employer_gosi_haz_id
  FROM   pay_element_types_f
  WHERE  element_name = 'Employer GOSI Hazards'
  AND    legislation_code = 'SA'
  AND    l_effective_date BETWEEN effective_start_date AND effective_end_date;
  SELECT element_type_id
  INTO   l_employee_gosi_ann_id
  FROM   pay_element_types_f
  WHERE  element_name = 'Employee GOSI Annuities'
  AND    legislation_code = 'SA'
  AND    l_effective_date BETWEEN effective_start_date AND effective_end_date;
  /*Query for fetching headcount modified after the enhacement*/
  /*Head counts for previous month*/
  SELECT SUM(DECODE(ac1.context_value
                   ,'1' ,DECODE(rr3.run_result_id
                               ,NULL, 0
                               ,1)
                   ,0)) SAUDI_ANNUITIES
        ,SUM(DECODE(ac1.context_value
                   ,'1', DECODE(rr3.run_result_id
                                ,NULL, DECODE(rr2.run_result_id
                                           ,NULL, 0
                                           ,1)
                              ,1)
                   ,0)) SAUDI_ANNUITIES_HAZARDS
        ,SUM(DECODE(rr2.run_result_id
                   ,NULL, 0
                   ,1)) HAZARDS
        ,SUM(DECODE(ac2.context_value
                   ,'Y', DECODE(ac1.context_value
                               ,'1' ,DECODE(rr3.run_result_id
                                           ,NULL, 0
                                           ,1)
                               ,0)
                   ,0)) JOINER_SAUDI_ANNUITIES
        ,SUM(DECODE(ac2.context_value
                   ,'Y', DECODE(ac1.context_value
                               ,'1', DECODE(rr3.run_result_id
                                           ,NULL, DECODE(rr2.run_result_id
                                                        ,NULL, 0
                                                        ,1)
                                           ,1)
                               ,0)
                   ,0)) JOINER_SAUDI_ANNUITIES_HAZARDS
        ,SUM(DECODE(ac2.context_value
                   ,'Y', DECODE(ac1.context_value
                               ,'2' ,DECODE(rr2.run_result_id
                                           ,NULL, 0
                                           ,1)
                               ,0)
                   ,0)) JOINER_NONSAUDI_HAZARDS
        ,SUM(DECODE(ac3.context_value
                   ,'Y', DECODE(ac1.context_value
                               ,'2' ,DECODE(rr2.run_result_id
                                           ,NULL, 0
                                           ,1)
                               ,0)
                   ,0)) LEAVER_NONSAUDI_HAZARDS
        ,SUM(DECODE(ac1.context_value
                   ,'2' ,DECODE(rr2.run_result_id
                               ,NULL, 0
                               ,1)
                   ,0)) NONSAUDI_HAZARDS
        ,SUM(DECODE(ac2.context_value
                   ,'Y', DECODE(rr2.run_result_id
                               ,NULL, 0
                               ,1)
                   ,0)) JOINER_HAZARDS
        ,SUM(DECODE(ac3.context_value
                   ,'Y', DECODE(ac1.context_value
                               ,'1' ,DECODE(rr3.run_result_id
                                           ,NULL, 0
                                           ,1)
                               ,0)
                   ,0)) LEAVER_SAUDI_ANNUITIES
        ,SUM(DECODE(ac3.context_value
                   ,'Y', DECODE(ac1.context_value
                               ,'1', DECODE(rr3.run_result_id
                                           ,NULL, DECODE(rr2.run_result_id
                                                        ,NULL, 0
                                                        ,1)
                                           ,1)
                               ,0)
                   ,0)) LEAVER_SAUDI_ANNUITIES_HAZARDS
        ,SUM(DECODE(ac3.context_value
                   ,'Y', DECODE(rr2.run_result_id
                               ,NULL, 0
                               ,1)
                   ,0)) LEAVER_HAZARDS
  INTO  l_p_saudi_ann
        ,l_p_saudi_ann_haz
        ,l_p_haz
        ,l_p_joiner_saudi_ann
        ,l_p_joiner_saudi_ann_haz
        ,l_p_joiner_nonsaudi_haz   /*Added for enhancement*/
        ,l_p_leaver_nonsaudi_haz   /*Added for enhancement*/
        ,l_p_nonsaudi_haz          /*Added for enhancement*/
        ,l_p_joiner_haz
        ,l_p_leaver_saudi_ann
        ,l_p_leaver_saudi_ann_haz
        ,l_p_leaver_haz
  FROM   pay_assignment_actions paa
        ,pay_action_contexts    ac1
        ,ff_contexts            ct1
        ,pay_action_contexts    ac2
        ,ff_contexts            ct2
        ,pay_action_contexts    ac3
        ,ff_contexts            ct3
        ,pay_payroll_actions    ppa
        ,pay_run_results        rr1
        ,pay_run_results        rr2
        ,pay_run_results        rr3
  WHERE  ppa.business_group_id        = p_business_group_id
  AND  ppa.action_type              IN ('R','Q')
  AND  ppa.action_status            = 'C'
  AND  ppa.date_earned              BETWEEN TRUNC(l_prev_mon_date,'MM')
                                        AND l_prev_mon_date
  AND  paa.payroll_action_id        = ppa.payroll_action_id
  AND  paa.tax_unit_id              = l_tax_unit_id  -- Employer
  AND  ct1.context_name             = 'SOURCE_NUMBER'
  AND  ac1.context_id               = ct1.context_id
  AND  ac1.assignment_action_id     = paa.assignment_action_id
  AND  ct2.context_name             = 'SOURCE_TEXT'
  AND  ac2.context_id               = ct2.context_id
  AND  ac2.assignment_action_id     = paa.assignment_action_id
  AND  ct3.context_name             = 'SOURCE_TEXT2'
  AND  ac3.context_id               = ct3.context_id
  AND  ac3.assignment_action_id     = paa.assignment_action_id
  AND  rr1.assignment_action_id     = paa.assignment_action_id
  AND  rr1.element_type_id          = l_gosi_id
  AND  rr2.assignment_action_id (+) = rr1.assignment_action_id
  AND  rr2.source_id            (+) = rr1.element_entry_id
  AND  rr2.source_type          (+) = 'I'
  AND  rr2.element_type_id      (+) = l_employer_gosi_haz_id
  AND  rr3.assignment_action_id (+) = rr1.assignment_action_id
  AND  rr3.source_id            (+) = rr1.element_entry_id
  AND  rr3.source_type          (+) = 'I'
  AND  rr3.element_type_id      (+) = l_employee_gosi_ann_id;
  /*Head counts for current month*/
  SELECT SUM(DECODE(ac1.context_value
                   ,'1' ,DECODE(rr3.run_result_id
                               ,NULL, 0
                               ,1)
                   ,0)) SAUDI_ANNUITIES
        ,SUM(DECODE(ac1.context_value
                   ,'1', DECODE(rr3.run_result_id
                                ,NULL, DECODE(rr2.run_result_id
                                           ,NULL, 0
                                           ,1)
                              ,1)
                   ,0)) SAUDI_ANNUITIES_HAZARDS
        ,SUM(DECODE(rr2.run_result_id
                   ,NULL, 0
                   ,1)) HAZARDS
        ,SUM(DECODE(ac2.context_value
                   ,'Y', DECODE(ac1.context_value
                               ,'1' ,DECODE(rr3.run_result_id
                                           ,NULL, 0
                                           ,1)
                               ,0)
                   ,0)) JOINER_SAUDI_ANNUITIES
        ,SUM(DECODE(ac2.context_value
                   ,'Y', DECODE(ac1.context_value
                               ,'1', DECODE(rr3.run_result_id
                                           ,NULL, DECODE(rr2.run_result_id
                                                        ,NULL, 0
                                                        ,1)
                                           ,1)
                               ,0)
                   ,0)) JOINER_SAUDI_ANNUITIES_HAZARDS
        ,SUM(DECODE(ac2.context_value
                   ,'Y', DECODE(ac1.context_value
                               ,'2' ,DECODE(rr2.run_result_id
                                           ,NULL, 0
                                           ,1)
                               ,0)
                   ,0)) JOINER_NONSAUDI_HAZARDS
        ,SUM(DECODE(ac3.context_value
                   ,'Y', DECODE(ac1.context_value
                               ,'2' ,DECODE(rr2.run_result_id
                                           ,NULL, 0
                                           ,1)
                               ,0)
                   ,0)) LEAVER_NONSAUDI_HAZARDS
        ,SUM(DECODE(ac1.context_value
                   ,'2' ,DECODE(rr2.run_result_id
                               ,NULL, 0
                               ,1)
                   ,0)) NONSAUDI_HAZARDS
        ,SUM(DECODE(ac2.context_value
                   ,'Y', DECODE(rr2.run_result_id
                               ,NULL, 0
                               ,1)
                   ,0)) JOINER_HAZARDS
        ,SUM(DECODE(ac3.context_value
                   ,'Y', DECODE(ac1.context_value
                               ,'1' ,DECODE(rr3.run_result_id
                                           ,NULL, 0
                                           ,1)
                               ,0)
                   ,0)) LEAVER_SAUDI_ANNUITIES
        ,SUM(DECODE(ac3.context_value
                   ,'Y', DECODE(ac1.context_value
                               ,'1', DECODE(rr3.run_result_id
                                           ,NULL, DECODE(rr2.run_result_id
                                                        ,NULL, 0
                                                        ,1)
                                           ,1)
                               ,0)
                   ,0)) LEAVER_SAUDI_ANNUITIES_HAZARDS
        ,SUM(DECODE(ac3.context_value
                   ,'Y', DECODE(rr2.run_result_id
                               ,NULL, 0
                               ,1)
                   ,0)) LEAVER_HAZARDS
  INTO  l_c_saudi_ann
        ,l_c_saudi_ann_haz
        ,l_c_haz
        ,l_c_joiner_saudi_ann
        ,l_c_joiner_saudi_ann_haz
        ,l_c_joiner_nonsaudi_haz   /*Added for enhancement*/
        ,l_c_leaver_nonsaudi_haz   /*Added for enhancement*/
        ,l_c_nonsaudi_haz          /*Added for enhancement*/
        ,l_c_joiner_haz
        ,l_c_leaver_saudi_ann
        ,l_c_leaver_saudi_ann_haz
        ,l_c_leaver_haz
  FROM   pay_assignment_actions paa
        ,pay_action_contexts    ac1
        ,ff_contexts            ct1
        ,pay_action_contexts    ac2
        ,ff_contexts            ct2
        ,pay_action_contexts    ac3
        ,ff_contexts            ct3
        ,pay_payroll_actions    ppa
        ,pay_run_results        rr1
        ,pay_run_results        rr2
        ,pay_run_results        rr3
  WHERE  ppa.business_group_id        = p_business_group_id
  AND  ppa.action_type              IN ('R','Q')
  AND  ppa.action_status            = 'C'
  AND  ppa.date_earned              BETWEEN TRUNC(l_effective_date,'MM')
                                        AND l_effective_date
  AND  paa.payroll_action_id        = ppa.payroll_action_id
  AND  paa.tax_unit_id              = l_tax_unit_id  -- Employer
  AND  ct1.context_name             = 'SOURCE_NUMBER'
  AND  ac1.context_id               = ct1.context_id
  AND  ac1.assignment_action_id     = paa.assignment_action_id
  AND  ct2.context_name             = 'SOURCE_TEXT'
  AND  ac2.context_id               = ct2.context_id
  AND  ac2.assignment_action_id     = paa.assignment_action_id
  AND  ct3.context_name             = 'SOURCE_TEXT2'
  AND  ac3.context_id               = ct3.context_id
  AND  ac3.assignment_action_id     = paa.assignment_action_id
  AND  rr1.assignment_action_id     = paa.assignment_action_id
  AND  rr1.element_type_id          = l_gosi_id
  AND  rr2.assignment_action_id (+) = rr1.assignment_action_id
  AND  rr2.source_id            (+) = rr1.element_entry_id
  AND  rr2.source_type          (+) = 'I'
  AND  rr2.element_type_id      (+) = l_employer_gosi_haz_id
  AND  rr3.assignment_action_id (+) = rr1.assignment_action_id
  AND  rr3.source_id            (+) = rr1.element_entry_id
  AND  rr3.source_type          (+) = 'I'
  AND  rr3.element_type_id      (+) = l_employee_gosi_ann_id;
  l_hc_ann_saudi_ter := l_p_leaver_saudi_ann + (l_p_saudi_ann + l_c_joiner_saudi_ann - l_p_leaver_saudi_ann - l_c_saudi_ann);
  l_hc_haz_ter_all := l_p_leaver_haz + (l_p_haz + l_c_joiner_haz - l_p_leaver_haz - l_c_haz);
  l_hc_haz_ann_saudi_ter := l_p_leaver_saudi_ann_haz + (l_p_saudi_ann_haz + l_c_joiner_saudi_ann_haz
                            - l_p_leaver_saudi_ann_haz - l_c_saudi_ann_haz);
  l_hc_haz_nonsaudi_ter := l_p_leaver_nonsaudi_haz + (l_p_nonsaudi_haz + l_c_joiner_nonsaudi_haz
                            - l_p_leaver_nonsaudi_haz - l_c_nonsaudi_haz);
  l_sum_saudi_hazards_t    := 0;
  declare
    /******Code for fetching contribution of leavers******/
    cursor csr_get_leav_assact is
    select distinct paa.assignment_action_id, paf.person_id
    from   pay_assignment_actions paa
           ,pay_payroll_actions ppa
           ,per_all_assignments_f paf
           ,per_periods_of_service pps
           ,hr_soft_coding_keyflex hscl
           ,per_time_periods ptp
           ,pay_run_results prr
    where  paf.period_of_service_id = pps.period_of_service_id
    and    nvl(pps.actual_termination_date,to_date('31/12/4712','DD/MM/YYYY'))
    between trunc(l_effective_date,'MM') and trunc(l_eff_term_date-1)
           /*****between trunc(l_effective_date,'MM') and trunc(l_eff_term_date-1)********* CHECK THIS*/
           --between l_prev_term_date and trunc(l_eff_term_date-1)
    and    paf.assignment_id = paa.assignment_id
    and    paa.payroll_action_id = ppa.payroll_action_id
    and    ppa.action_type in ('R','Q')
    and    ppa.action_status = 'C'
    and    paa.action_status = 'C'
    and    prr.assignment_action_id     = paa.assignment_action_id
    and    prr.element_type_id          = l_gosi_id
    and    paf.soft_coding_keyflex_id = hscl.soft_coding_keyflex_id
    and    ppa.time_period_id = ptp.time_period_id
    and    ptp.end_date = l_prev_mon_date
    and    trunc(l_prev_mon_date,'MM') between trunc(paf.effective_start_date,'MM') and paf.effective_end_date
    and    hscl.segment1 = to_char(l_tax_unit_id);
    rec_leav_assact  csr_get_leav_assact%ROWTYPE;
    /******Code for fetching contribution of saudi leaver employees paying only annuities*****/
    cursor csr_saudi_l_ann_assact is
    select distinct paa.assignment_action_id, paf.person_id
    from   pay_assignment_actions paa
           ,pay_payroll_actions ppa
           ,per_all_assignments_f paf
           ,per_periods_of_service pps
           ,hr_soft_coding_keyflex hscl
           ,per_time_periods ptp
           ,pay_run_results prr
    where  paf.period_of_service_id = pps.period_of_service_id
    and    nvl(pps.actual_termination_date,to_date('31/12/4712','DD/MM/YYYY'))
           between l_prev_term_date and trunc(l_eff_term_date-1)
    and    paf.assignment_id = paa.assignment_id
    and    paa.payroll_action_id = ppa.payroll_action_id
    and    ppa.action_type in ('R','Q')
    and    ppa.action_status = 'C'
    and    paa.action_status = 'C'
    and    prr.assignment_action_id     = paa.assignment_action_id
    and    prr.element_type_id          = l_gosi_id
    and    paf.soft_coding_keyflex_id = hscl.soft_coding_keyflex_id
    and    ppa.time_period_id = ptp.time_period_id
    and    ptp.end_date = l_prev_mon_date
    and    trunc(l_prev_mon_date,'MM') between trunc(paf.effective_start_date,'MM') and paf.effective_end_date
    and    hscl.segment1 = to_char(l_tax_unit_id)
    and    hscl.segment3 = 'Y'
    and    hscl.segment5 = 'N';
    rec_l_ann_assact  csr_saudi_l_ann_assact%ROWTYPE;
    /******Code for fetching contribution of saudi joiner employees paying only annuities*****/
    cursor csr_saudi_j_ann_assact is
    select distinct paa.assignment_action_id, paf.person_id
    from   pay_assignment_actions paa
           ,pay_payroll_actions ppa
           ,per_all_assignments_f paf
           ,per_periods_of_service pps
           ,hr_soft_coding_keyflex hscl
           ,per_time_periods ptp
           ,pay_run_results prr
    where  paf.period_of_service_id = pps.period_of_service_id
    and    nvl(pps.actual_termination_date,to_date('31/12/4712','DD/MM/YYYY'))
           not between trunc(l_effective_date,'MM') and trunc(l_eff_term_date-1)
    and    trunc(pps.date_start, 'MM') = trunc(l_effective_date,'MM')
    and    paf.assignment_id = paa.assignment_id
    and    paa.payroll_action_id = ppa.payroll_action_id
    and    ppa.action_type in ('R','Q')
    and    ppa.action_status = 'C'
    and    paa.action_status = 'C'
    and    prr.assignment_action_id     = paa.assignment_action_id
    and    prr.element_type_id          = l_gosi_id
    and    paf.soft_coding_keyflex_id = hscl.soft_coding_keyflex_id
    and    ppa.time_period_id = ptp.time_period_id
    and    ptp.end_date = l_effective_date
    and    trunc(l_effective_date,'MM') between trunc(paf.effective_start_date,'MM') and paf.effective_end_date
    and    hscl.segment1 = to_char(l_tax_unit_id)
    and    hscl.segment3 = 'Y'
    and    hscl.segment5 = 'N';
    rec_j_ann_assact  csr_saudi_j_ann_assact%ROWTYPE;
    l_assact_haz               number := 0;
    l_sum_hazards_t            number := 0;
    l_sum_saudi_annuities_t    number := 0;
    ----l_sum_saudi_hazards_t      number := 0;*** THIS VARIABLE MOVED OUTSIDE THE BLOCK*********
    l_loc_nat                  number := 0;
    l_gosi_haz_asg_tu_mth_db   number := 0;
    l_emp_gosi_ann_asg_ptd_db  number := 0;
  begin
    select  u.creator_id
    into    l_gosi_haz_asg_tu_mth_db
    from    ff_user_entities  u,
            ff_database_items d
    where   d.user_name = 'GOSI_HAZARDS_ASG_TU_MONTH'
    and     u.user_entity_id = d.user_entity_id
    and     u.legislation_code = 'SA'
    and     u.business_group_id is null
    and     u.creator_type = 'B';
    select  u.creator_id
    into    l_emp_gosi_ann_asg_ptd_db
    from    ff_user_entities  u,
            ff_database_items d
    where   d.user_name = 'GOSI_ANNUITIES_ASG_TU_MONTH'
    and     u.user_entity_id = d.user_entity_id
    and     u.legislation_code = 'SA'
    and     u.business_group_id is null
    and     u.creator_type = 'B';
    pay_balance_pkg.set_context('TAX_UNIT_ID',l_tax_unit_id);
    pay_balance_pkg.set_context('DATE_EARNED',FND_DATE.DATE_TO_CANONICAL(l_prev_mon_date));
    /*Fetch contribution of employees who got terminated after 28th of previous month*/
    open csr_get_leav_assact;
    loop
      fetch csr_get_leav_assact into rec_leav_assact;
      exit when csr_get_leav_assact%notfound;
        l_assact_haz := 0;
        if nvl(l_hc_haz_ter_all,0) > 0 then
          l_assact_haz := pay_balance_pkg.get_value(l_gosi_haz_asg_tu_mth_db,rec_leav_assact.assignment_action_id);
        end if;
        l_sum_hazards_t := l_sum_hazards_t + l_assact_haz;
        if nvl(l_hc_ann_saudi_ter,0) > 0 then
          l_sum_saudi_annuities_t := l_sum_saudi_annuities_t +
                          (pay_balance_pkg.get_value(l_emp_gosi_ann_asg_ptd_db,rec_leav_assact.assignment_action_id));
        end if;
        select count(*)
        into   l_loc_nat
        from   per_all_people_f
        where  person_id = rec_leav_assact.person_id
        and    upper(nationality) = FND_PROFILE.VALUE('PER_LOCAL_NATIONALITY')
        and    trunc(l_prev_mon_date,'MM') between trunc(effective_start_date,'MM') and effective_end_date;
        if l_loc_nat > 0 then
            l_sum_saudi_hazards_t := l_sum_saudi_hazards_t + l_assact_haz;
        end if;
    end loop;
    close csr_get_leav_assact;
    if nvl(l_hc_ann_saudi_ter,0) = 0 then
      l_annuities_saudi_ter := 0;
    else
      l_annuities_saudi_ter := l_prev_ann_saudi_ter + l_prev_ann_saudi_new_ter + l_sum_saudi_annuities_t;
    end if;
    if nvl(l_hc_haz_ter_all,0) = 0 then
      l_hazards_ter_all := 0;
    else
      l_hazards_ter_all := l_prev_haz_ter_all + l_prev_haz_new_ter_all + l_sum_hazards_t;
    end if;
    if nvl(l_hc_haz_ann_saudi_ter,0) = 0 then
      l_haz_ann_saudi_ter := 0;
    else
      l_haz_ann_saudi_ter := l_prev_haz_ann_saudi_ter + l_prev_haz_ann_saudi_new_ter +
                           l_sum_saudi_annuities_t + l_sum_saudi_hazards_t;
    end if;
    --Fetch the total amount paid by employees who pay only annuities
    l_emp_annuity := 0;
    l_tot_l_emp_annuity := 0;
    open csr_saudi_l_ann_assact;
    loop
      fetch csr_saudi_l_ann_assact into rec_l_ann_assact;
      exit when csr_saudi_l_ann_assact%notfound;
      l_emp_annuity := pay_balance_pkg.get_value(l_emp_gosi_ann_asg_ptd_db,rec_l_ann_assact.assignment_action_id);
      l_tot_l_emp_annuity := l_tot_l_emp_annuity + l_emp_annuity;
    end loop;
    close csr_saudi_l_ann_assact;
    l_emp_annuity := 0;
    l_tot_j_emp_annuity := 0;
    open csr_saudi_j_ann_assact;
    loop
      fetch csr_saudi_j_ann_assact into rec_j_ann_assact;
      exit when csr_saudi_j_ann_assact%notfound;
      l_emp_annuity := pay_balance_pkg.get_value(l_emp_gosi_ann_asg_ptd_db,rec_j_ann_assact.assignment_action_id);
      l_tot_j_emp_annuity := l_tot_j_emp_annuity + l_emp_annuity;
    end loop;
    close csr_saudi_j_ann_assact;
  end;
/***************************************************Removed as part of enhancement
  vXMLTable(vCtr).TagName := 'G4-B-01-1';
  --vXMLTable(vCtr).TagValue := l_hc_ann_saudi;
  vXMLTable(vCtr).TagValue := nvl(l_p_saudi_ann,0);
  vctr := vctr + 1;
  vXMLTable(vCtr).TagName := 'G4-B-01-2';
  --vXMLTable(vCtr).TagValue := l_hc_haz;
  vXMLTable(vCtr).TagValue := nvl(l_p_haz,0);
  vctr := vctr + 1;
  vXMLTable(vCtr).TagName := 'G4-B-01-3';
  --vXMLTable(vCtr).TagValue := l_hc_haz_ann_saudi;
  vXMLTable(vCtr).TagValue := nvl(l_p_saudi_ann_haz,0);
  vctr := vctr + 1;
  l_fm_tot_prev_ann_saudi := null;
  l_fm_tot_prev_ann_saudi := to_char(l_tot_prev_ann_saudi,lg_format_mask);
  vXMLTable(vCtr).TagName := 'G4-B-01-4';
  --vXMLTable(vCtr).TagValue := l_tot_prev_ann_saudi - trunc(l_tot_prev_ann_saudi);
  vXMLTable(vCtr).TagValue := substr(l_fm_tot_prev_ann_saudi,length(l_fm_tot_prev_ann_saudi)-1);
  vctr := vctr + 1;
  vXMLTable(vCtr).TagName := 'G4-B-01-5';
  --vXMLTable(vCtr).TagValue := trunc(l_tot_prev_ann_saudi);
  vXMLTable(vCtr).TagValue := substr(l_fm_tot_prev_ann_saudi,1,length(l_fm_tot_prev_ann_saudi)-3);
  vctr := vctr + 1;
  l_fm_tot_prev_haz_all := null;
  l_fm_tot_prev_haz_all := to_char(l_tot_prev_haz_all,lg_format_mask);
  vXMLTable(vCtr).TagName := 'G4-B-01-6';
  --vXMLTable(vCtr).TagValue := l_tot_prev_haz_all - trunc(l_tot_prev_haz_all);
  vXMLTable(vCtr).TagValue := substr(l_fm_tot_prev_haz_all,length(l_fm_tot_prev_haz_all)-1);
  vctr := vctr + 1;
  vXMLTable(vCtr).TagName := 'G4-B-01-7';
  --vXMLTable(vCtr).TagValue := trunc(l_tot_prev_haz_all);
  vXMLTable(vCtr).TagValue := substr(l_fm_tot_prev_haz_all,1,length(l_fm_tot_prev_haz_all)-3);
  vctr := vctr + 1;
  l_fm_tot_prev_haz_ann_saudi := null;
  l_fm_tot_prev_haz_ann_saudi := to_char(l_tot_prev_haz_ann_saudi,lg_format_mask);
  vXMLTable(vCtr).TagName := 'G4-B-01-8';
  --vXMLTable(vCtr).TagValue := l_tot_prev_haz_ann_saudi - trunc(l_tot_prev_haz_ann_saudi);
  vXMLTable(vCtr).TagValue := substr(l_fm_tot_prev_haz_ann_saudi,length(l_fm_tot_prev_haz_ann_saudi)-1);
  vctr := vctr + 1;
  vXMLTable(vCtr).TagName := 'G4-B-01-9';
  --vXMLTable(vCtr).TagValue := trunc(l_tot_prev_haz_ann_saudi);
  vXMLTable(vCtr).TagValue := substr(l_fm_tot_prev_haz_ann_saudi,1,length(l_fm_tot_prev_haz_ann_saudi)-3);
  vctr := vctr + 1;
  ************************************************************/
  --For determining the GOSI reference salary use hazards value and apply the hazards percent
  BEGIN
    SELECT global_value
    INTO   l_hazards_pct
    FROM   ff_globals_f
    WHERE  legislation_code='SA'
    AND    business_group_id IS NULL
    AND    global_name = 'SA_ER_HAZARDS_PCT';
  EXCEPTION
    WHEN OTHERS THEN
      l_hazards_pct := 0;
  END;
  --Annuities percent is used for determining reference salaries of employees who have only annuities flag enabled
  BEGIN
    SELECT global_value
    INTO   l_ee_annuities_pct
    FROM   ff_globals_f
    WHERE  legislation_code='SA'
    AND    business_group_id IS NULL
    AND    global_name = 'SA_EE_ANNUITIES_PCT';
  EXCEPTION
    WHEN OTHERS THEN
      l_ee_annuities_pct := 0;
  END;
  BEGIN
    SELECT global_value
    INTO   l_er_annuities_pct
    FROM   ff_globals_f
    WHERE  legislation_code='SA'
    AND    business_group_id IS NULL
    AND    global_name = 'SA_ER_ANNUITIES_PCT';
  EXCEPTION
    WHEN OTHERS THEN
      l_er_annuities_pct := 0;
  END;
  vXMLTable(vCtr).TagName := 'G4-B-02-1';
  vXMLTable(vCtr).TagValue := nvl(l_c_joiner_saudi_ann_haz,0);
  vctr := vctr + 1;
  /**********************************
  vXMLTable(vCtr).TagName := 'G4-B-02-2';
  vXMLTable(vCtr).TagValue := nvl(l_c_joiner_haz,0);
  vctr := vctr + 1;
  vXMLTable(vCtr).TagName := 'G4-B-02-3';
  --vXMLTable(vCtr).TagValue := l_hc_haz_ann_saudi_new;
  vXMLTable(vCtr).TagValue := nvl(l_c_joiner_saudi_ann_haz,0);
  vctr := vctr + 1;
  ***********************************/
  l_gosi_ref_saudi_new := (((l_curr_haz_saudi_new + l_curr_haz_saudi_new_ter)* 100)/l_hazards_pct) +
                          ((l_tot_j_emp_annuity * 100)/(l_ee_annuities_pct + l_er_annuities_pct))   ;
  l_fm_gosi_ref_saudi_new := to_char(l_gosi_ref_saudi_new,lg_format_mask);
  vXMLTable(vCtr).TagName := 'G4-B-02-2';
  vXMLTable(vCtr).TagValue := substr(l_fm_gosi_ref_saudi_new,length(l_fm_gosi_ref_saudi_new)-1);
  vctr := vctr + 1;
  vXMLTable(vCtr).TagName := 'G4-B-02-3';
  vXMLTable(vCtr).TagValue := substr(l_fm_gosi_ref_saudi_new,1,length(l_fm_gosi_ref_saudi_new)-3);
  vctr := vctr + 1;
  vXMLTable(vCtr).TagName := 'G4-B-02-4';
  vXMLTable(vCtr).TagValue := nvl(l_c_joiner_nonsaudi_haz ,0);
  vctr := vctr + 1;
  l_gosi_ref_nonsaudi_new := ((l_curr_haz_new + l_curr_haz_new_ter) * 100)/l_hazards_pct;
  l_fm_gosi_ref_nonsaudi_new := to_char(l_gosi_ref_nonsaudi_new,lg_format_mask);
  vXMLTable(vCtr).TagName := 'G4-B-02-5';
  vXMLTable(vCtr).TagValue := substr(l_fm_gosi_ref_nonsaudi_new,length(l_fm_gosi_ref_nonsaudi_new)-1);
  vctr := vctr + 1;
  vXMLTable(vCtr).TagName := 'G4-B-02-6';
  vXMLTable(vCtr).TagValue := substr(l_fm_gosi_ref_nonsaudi_new,1,length(l_fm_gosi_ref_nonsaudi_new)-3);
  vctr := vctr + 1;
  vXMLTable(vCtr).TagName := 'G4-B-03-1';
  vXMLTable(vCtr).TagValue := nvl(l_hc_haz_ann_saudi_ter,0);
  vctr := vctr + 1;
  l_gosi_ref_saudi_ter := ((l_sum_saudi_hazards_t + l_prev_haz_saudi_ter + l_prev_haz_saudi_new_ter) * 100)/l_hazards_pct +
                          ((l_tot_l_emp_annuity * 100)/(l_ee_annuities_pct + l_er_annuities_pct));
  l_fm_gosi_ref_saudi_ter := to_char(l_gosi_ref_saudi_ter ,lg_format_mask);
  vXMLTable(vCtr).TagName := 'G4-B-03-2';
  vXMLTable(vCtr).TagValue := substr(l_fm_gosi_ref_saudi_ter,length(l_fm_gosi_ref_saudi_ter)-1);
  vctr := vctr + 1;
  vXMLTable(vCtr).TagName := 'G4-B-03-3';
  vXMLTable(vCtr).TagValue := substr(l_fm_gosi_ref_saudi_ter,1,length(l_fm_gosi_ref_saudi_ter)-3);
  vctr := vctr + 1;
  vXMLTable(vCtr).TagName := 'G4-B-03-4';
  vXMLTable(vCtr).TagValue :=nvl(l_hc_haz_nonsaudi_ter ,0);
  vctr := vctr + 1;
  l_gosi_ref_nonsaudi_ter := ((l_hazards_ter_all - (l_sum_saudi_hazards_t + l_prev_haz_saudi_ter + l_prev_haz_saudi_new_ter)) * 100)/l_hazards_pct;
  l_fm_gosi_ref_nonsaudi_ter := to_char(l_gosi_ref_nonsaudi_ter,lg_format_mask);
  vXMLTable(vCtr).TagName := 'G4-B-03-5';
  vXMLTable(vCtr).TagValue := substr(l_fm_gosi_ref_nonsaudi_ter,length(l_fm_gosi_ref_nonsaudi_ter)-1);
  vctr := vctr + 1;
  vXMLTable(vCtr).TagName := 'G4-B-03-6';
  vXMLTable(vCtr).TagValue := substr(l_fm_gosi_ref_nonsaudi_ter,1,length(l_fm_gosi_ref_nonsaudi_ter)-3);
  vctr := vctr + 1;
  l_fm_total := to_char((l_curr_haz_ann + nvl(p_arrears,0) + nvl(p_penalty_charge,0) - nvl(p_discount,0)),lg_format_mask);
  vXMLTable(vCtr).TagName := 'G4-C-05-1';
  vXMLTable(vCtr).TagValue := substr(l_fm_total,length(l_fm_total)-1);
  vctr := vctr + 1;
  vXMLTable(vCtr).TagName := 'G4-C-05-2';
  vXMLTable(vCtr).TagValue := substr(l_fm_total,1,length(l_fm_total)-3);
  vctr := vctr + 1;
  IF p_payment_method IS NOT NULL THEN
    IF p_payment_method = '1' THEN
      vXMLTable(vCtr).TagName := 'G4-D-01';
      vXMLTable(vCtr).TagValue := 'X';
      vctr := vctr + 1;
    ELSIF p_payment_method = '2' THEN
      vXMLTable(vCtr).TagName := 'G4-D-02';
      vXMLTable(vCtr).TagValue := 'X';
      vctr := vctr + 1;
    ELSIF p_payment_method = '3' THEN
      vXMLTable(vCtr).TagName := 'G4-D-03';
      vXMLTable(vCtr).TagValue := 'X';
      vctr := vctr + 1;
    ELSIF p_payment_method = '4' THEN
      vXMLTable(vCtr).TagName := 'G4-D-04';
      vXMLTable(vCtr).TagValue := 'X';
      vctr := vctr + 1;
    END IF;
  END IF;
  /***********************************************************************
  l_fm_annuities_saudi_new := null;
  l_fm_annuities_saudi_new := to_char(l_annuities_saudi_new,lg_format_mask);
  vXMLTable(vCtr).TagName := 'G4-B-02-4';
  vXMLTable(vCtr).TagValue := substr(l_fm_annuities_saudi_new,length(l_fm_annuities_saudi_new)-1);
  vctr := vctr + 1;
  vXMLTable(vCtr).TagName := 'G4-B-02-5';
  vXMLTable(vCtr).TagValue := substr(l_fm_annuities_saudi_new,1,length(l_fm_annuities_saudi_new)-3);
  vctr := vctr + 1;
  l_fm_hazards_new_all := null;
  l_fm_hazards_new_all := to_char(l_hazards_new_all,lg_format_mask);
  vXMLTable(vCtr).TagName := 'G4-B-02-6';
  vXMLTable(vCtr).TagValue := substr(l_fm_hazards_new_all,length(l_fm_hazards_new_all)-1);
  vctr := vctr + 1;
  vXMLTable(vCtr).TagName := 'G4-B-02-7';
  vXMLTable(vCtr).TagValue := substr(l_fm_hazards_new_all,1,length(l_fm_hazards_new_all)-3);
  vctr := vctr + 1;
  l_fm_haz_ann_saudi_new := null;
  l_fm_haz_ann_saudi_new := to_char(l_haz_ann_saudi_new,lg_format_mask);
  vXMLTable(vCtr).TagName := 'G4-B-02-8';
  vXMLTable(vCtr).TagValue := substr(l_fm_haz_ann_saudi_new,length(l_fm_haz_ann_saudi_new)-1);
  vctr := vctr + 1;
  vXMLTable(vCtr).TagName := 'G4-B-02-9';
  vXMLTable(vCtr).TagValue := substr(l_fm_haz_ann_saudi_new,1,length(l_fm_haz_ann_saudi_new)-3);
  vctr := vctr + 1;
  vXMLTable(vCtr).TagName := 'G4-B-03-1';
  vXMLTable(vCtr).TagValue := nvl(l_hc_ann_saudi_ter,0);
  vctr := vctr + 1;
  vXMLTable(vCtr).TagName := 'G4-B-03-2';
  vXMLTable(vCtr).TagValue := nvl(l_hc_haz_ter_all,0);
  vctr := vctr + 1;
  vXMLTable(vCtr).TagName := 'G4-B-03-3';
  vXMLTable(vCtr).TagValue := nvl(l_hc_haz_ann_saudi_ter,0);
  vctr := vctr + 1;
  l_fm_annuities_saudi_ter := null;
  l_fm_annuities_saudi_ter := to_char(l_annuities_saudi_ter,lg_format_mask);
  vXMLTable(vCtr).TagName := 'G4-B-03-4';
  vXMLTable(vCtr).TagValue := substr(l_fm_annuities_saudi_ter,length(l_fm_annuities_saudi_ter)-1);
  vctr := vctr + 1;
  vXMLTable(vCtr).TagName := 'G4-B-03-5';
  vXMLTable(vCtr).TagValue := substr(l_fm_annuities_saudi_ter,1,length(l_fm_annuities_saudi_ter)-3);
  vctr := vctr + 1;
  l_fm_hazards_ter_all := null;
  l_fm_hazards_ter_all := to_char(l_hazards_ter_all,lg_format_mask);
  vXMLTable(vCtr).TagName := 'G4-B-03-6';
  vXMLTable(vCtr).TagValue := substr(l_fm_hazards_ter_all,length(l_fm_hazards_ter_all)-1);
  vctr := vctr + 1;
  vXMLTable(vCtr).TagName := 'G4-B-03-7';
  vXMLTable(vCtr).TagValue := substr(l_fm_hazards_ter_all,1,length(l_fm_hazards_ter_all)-3);
  vctr := vctr + 1;
  l_fm_haz_ann_saudi_ter := null;
  l_fm_haz_ann_saudi_ter := to_char(l_haz_ann_saudi_ter,lg_format_mask);
  vXMLTable(vCtr).TagName := 'G4-B-03-8';
  vXMLTable(vCtr).TagValue := substr(l_fm_haz_ann_saudi_ter,length(l_fm_haz_ann_saudi_ter)-1);
  vctr := vctr + 1;
  vXMLTable(vCtr).TagName := 'G4-B-03-9';
  vXMLTable(vCtr).TagValue := substr(l_fm_haz_ann_saudi_ter,1,length(l_fm_haz_ann_saudi_ter)-3);
  vctr := vctr + 1;
  vXMLTable(vCtr).TagName := 'G4-B-04-1';
  vXMLTable(vCtr).TagValue := nvl(l_c_saudi_ann,0);
  vctr := vctr + 1;
  vXMLTable(vCtr).TagName := 'G4-B-04-2';
  vXMLTable(vCtr).TagValue := nvl(l_c_haz,0);
  vctr := vctr + 1;
  vXMLTable(vCtr).TagName := 'G4-B-04-3';
  vXMLTable(vCtr).TagValue := nvl(l_c_saudi_ann_haz,0);
  vctr := vctr + 1;
  l_fm_tot_curr_ann_saudi := null;
  l_fm_tot_curr_ann_saudi := to_char(l_tot_curr_ann_saudi,lg_format_mask);
  vXMLTable(vCtr).TagName := 'G4-B-04-4';
  vXMLTable(vCtr).TagValue := substr(l_fm_tot_curr_ann_saudi,length(l_fm_tot_curr_ann_saudi)-1);
  vctr := vctr + 1;
  vXMLTable(vCtr).TagName := 'G4-B-04-5';
  vXMLTable(vCtr).TagValue := substr(l_fm_tot_curr_ann_saudi,1,length(l_fm_tot_curr_ann_saudi)-3);
  vctr := vctr + 1;
  l_fm_tot_curr_haz_all := null;
  l_fm_tot_curr_haz_all := to_char(l_tot_curr_haz_all,lg_format_mask);
  vXMLTable(vCtr).TagName := 'G4-B-04-6';
  vXMLTable(vCtr).TagValue := substr(l_fm_tot_curr_haz_all,length(l_fm_tot_curr_haz_all)-1);
  vctr := vctr + 1;
  vXMLTable(vCtr).TagName := 'G4-B-04-7';
  vXMLTable(vCtr).TagValue := substr(l_fm_tot_curr_haz_all,1,length(l_fm_tot_curr_haz_all)-3);
  l_fm_tot_curr_haz_ann_saudi := null;
  l_fm_tot_curr_haz_ann_saudi := to_char(l_tot_curr_haz_ann_saudi,lg_format_mask);
  vctr := vctr + 1;
  vXMLTable(vCtr).TagName := 'G4-B-04-8';
  vXMLTable(vCtr).TagValue := substr(l_fm_tot_curr_haz_ann_saudi,length(l_fm_tot_curr_haz_ann_saudi)-1);
  vctr := vctr + 1;
  vXMLTable(vCtr).TagName := 'G4-B-04-9';
  vXMLTable(vCtr).TagValue := substr(l_fm_tot_curr_haz_ann_saudi,1,length(l_fm_tot_curr_haz_ann_saudi)-3);
  vctr := vctr + 1;
  -----************* Section C************
  l_fm_curr_annuities := null;
  l_fm_curr_annuities := to_char(l_curr_annuities,lg_format_mask);
  vXMLTable(vCtr).TagName := 'G4-C-01-1';
  vXMLTable(vCtr).TagValue := substr(l_fm_curr_annuities,length(l_fm_curr_annuities)-1);
  vctr := vctr + 1;
  vXMLTable(vCtr).TagName := 'G4-C-01-2';
  vXMLTable(vCtr).TagValue := substr(l_fm_curr_annuities,1,length(l_fm_curr_annuities)-3);
  vctr := vctr + 1;
  l_fm_curr_hazards := null;
  l_fm_curr_hazards := to_char(l_curr_hazards,lg_format_mask);
  vXMLTable(vCtr).TagName := 'G4-C-01-3';
  vXMLTable(vCtr).TagValue := substr(l_fm_curr_hazards,length(l_fm_curr_hazards)-1);
  vctr := vctr + 1;
  vXMLTable(vCtr).TagName := 'G4-C-01-4';
  vXMLTable(vCtr).TagValue := substr(l_fm_curr_hazards,1,length(l_fm_curr_hazards)-3);
  vctr := vctr + 1;
  l_fm_curr_haz_ann := null;
  l_fm_curr_haz_ann := to_char(l_curr_haz_ann,lg_format_mask);
  vXMLTable(vCtr).TagName := 'G4-C-01-5';
  vXMLTable(vCtr).TagValue := substr(l_fm_curr_haz_ann,length(l_fm_curr_haz_ann)-1);
  vctr := vctr + 1;
  vXMLTable(vCtr).TagName := 'G4-C-01-6';
  vXMLTable(vCtr).TagValue := substr(l_fm_curr_haz_ann,1,length(l_fm_curr_haz_ann)-3);
  vctr := vctr + 1;
  l_fm_arrears := null;
  l_fm_arrears := to_char(nvl(p_arrears,0),lg_format_mask);
  vXMLTable(vCtr).TagName := 'G4-C-02-1';
  vXMLTable(vCtr).TagValue := substr(l_fm_arrears,length(l_fm_arrears)-1);
  vctr := vctr + 1;
  vXMLTable(vCtr).TagName := 'G4-C-02-2';
  vXMLTable(vCtr).TagValue := substr(l_fm_arrears,1,length(l_fm_arrears)-3);
  vctr := vctr + 1;
  l_fm_penalty_charge := null;
  l_fm_penalty_charge := to_char(nvl(p_penalty_charge,0),lg_format_mask);
  vXMLTable(vCtr).TagName := 'G4-C-03-1';
  vXMLTable(vCtr).TagValue := substr(l_fm_penalty_charge,length(l_fm_penalty_charge)-1);
  vctr := vctr + 1;
  vXMLTable(vCtr).TagName := 'G4-C-03-2';
  vXMLTable(vCtr).TagValue := substr(l_fm_penalty_charge,1,length(l_fm_penalty_charge)-3);
  vctr := vctr + 1;
  l_fm_discount := null;
  l_fm_discount := to_char(nvl(p_discount,0),lg_format_mask);
  vXMLTable(vCtr).TagName := 'G4-C-04-1';
  vXMLTable(vCtr).TagValue := substr(l_fm_discount,length(l_fm_discount)-1);
  vctr := vctr + 1;
  vXMLTable(vCtr).TagName := 'G4-C-04-2';
  vXMLTable(vCtr).TagValue := substr(l_fm_discount,1,length(l_fm_discount)-3);
  vctr := vctr + 1;
  l_fm_total := null;
  l_fm_total := to_char((l_curr_haz_ann + nvl(p_arrears,0) + nvl(p_penalty_charge,0) - nvl(p_discount,0)),lg_format_mask);
  vXMLTable(vCtr).TagName := 'G4-C-05-1';
  vXMLTable(vCtr).TagValue := substr(l_fm_total,length(l_fm_total)-1);
  vctr := vctr + 1;
  vXMLTable(vCtr).TagName := 'G4-C-05-2';
  vXMLTable(vCtr).TagValue := substr(l_fm_total,1,length(l_fm_total)-3);
  vctr := vctr + 1;
***********************************************************************/
/*Msg in the temorary table*/
hr_utility.set_location('Finished Procedure Populate Monthly Contribution Report ',60);
      /*  -----------------------------------------------------------------------------
        -- Writing into XML File
        -----------------------------------------------------------------------------
        -- Assigning the File name.
        l_file_name1 :=  to_char(p_request_id) || '.xml';
        -- Getting the Util file directory name.mostly it'll be /sqlcom/outbound )
        BEGIN
                SELECT value
                INTO l_audit_log_dir1
                FROM v$parameter
                WHERE LOWER(name) = 'utl_file_dir';
                -- Check whether more than one util file directory is found
                IF INSTR(l_audit_log_dir1,',') > 0 THEN
                   l_audit_log_dir1 := substr(l_audit_log_dir1,1,instr(l_audit_log_dir1,',')-1);
                END IF;
        EXCEPTION
                when no_data_found then
              null;
        END;
        -- Find out whether the OS is MS or Unix based
        -- If it's greater than 0, it's unix based environment
        IF INSTR(l_audit_log_dir1,'/') > 0 THEN
                p_output_fname := l_audit_log_dir1 || '/' || l_file_name1;
        ELSE
        p_output_fname := l_audit_log_dir1 || '\' || l_file_name1;
        END IF;
        -- getting Agency name
        p_l_fp1 := utl_file.fopen(l_audit_log_dir1,l_file_name1,'A');
        IF L_FILE_CREATED = 0 THEN
          utl_file.put_line(p_l_fp1,'<?xml version="1.0" encoding="UTF-8"?>');
          utl_file.put_line(p_l_fp1,'<xfdf xmlns="http://ns.adobe.com/xfdf/" xml:space="preserve">');
        END IF;
        -- Writing from and to dates
        utl_file.put_line(p_l_fp1,'<fields>');
        -- Write the header fields to XML File.
        --WriteXMLvalues(p_l_fp,'P0_from_date',to_char(p_from_date,'dd') || ' ' || trim(to_char(p_from_date,'Month')) || ' ' || to_char(p_from_date,'yyyy') );
        --WriteXMLvalues(p_l_fp,'P0_to_date',to_char(p_to_date,'dd') || ' ' ||to_char(p_to_date,'Month') || ' ' || to_char(p_to_date,'yyyy') );
        -- Loop through PL/SQL Table and write the values into the XML File.
        -- Need to try FORALL instead of FOR
        FOR ctr_table IN vXMLTable.FIRST .. vXMLTable.LAST LOOP
                WriteXMLvalues(p_l_fp1,vXMLTable(ctr_table).TagName ,vXMLTable(ctr_table).TagValue);
        END LOOP;
        -- Write the end tag and close the XML File.
        utl_file.put_line(p_l_fp1,'</fields>');
        --utl_file.put_line(p_l_fp1,'</xfdf>');
        utl_file.fclose(p_l_fp1);
        l_file_created := 1;  */
END LOOP;
	/*End of call to report5*/
        WritetoCLOB ( l_xfdf_blob );
        -- Write the values to XML File
/*        fnd_file.put_line(fnd_file.log,'Calling Procedure to write into XML File');
        WritetoXML(
        p_request_id,
        p_report,
        l_file_name);
        p_output_fname := l_file_name;
        fnd_file.put_line(fnd_file.log,'------------Output XML File----------------');
        fnd_file.put_line(fnd_file.log,'File' || l_file_name );
        fnd_file.put_line(fnd_file.log,'-------------------------------------------');
p_output_fname := l_file_name;*/
/*
EXCEPTION
        WHEN utl_file.invalid_path then
                hr_utility.set_message(8301, 'GHR_38830_INVALID_UTL_FILE_PATH');
                fnd_file.put_line(fnd_file.log,HR_UTILITY.get_message);
                hr_utility.raise_error;
--
    WHEN utl_file.invalid_mode then
        hr_utility.set_message(8301, 'GHR_38831_INVALID_FILE_MODE');
        fnd_file.put_line(fnd_file.log,HR_UTILITY.get_message);
                hr_utility.raise_error;
--
    WHEN utl_file.invalid_filehandle then
        hr_utility.set_message(8301, 'GHR_38832_INVALID_FILE_HANDLE');
        fnd_file.put_line(fnd_file.log,HR_UTILITY.get_message);
                hr_utility.raise_error;
--
    WHEN utl_file.invalid_operation then
        hr_utility.set_message(8301, 'GHR_38833_INVALID_OPER');
        fnd_file.put_line(fnd_file.log,HR_UTILITY.get_message);
                hr_utility.raise_error;
--
    WHEN utl_file.read_error then
        hr_utility.set_message(8301, 'GHR_38834_FILE_READ_ERROR');
        fnd_file.put_line(fnd_file.log,HR_UTILITY.get_message);
                hr_utility.raise_error;
--
    WHEN others THEN
       hr_utility.set_message(800,'FFU10_GENERAL_ORACLE_ERROR');
       hr_utility.set_message_token('2',substr(sqlerrm,1,200));
       fnd_file.put_line(fnd_file.log,HR_UTILITY.get_message);
           hr_utility.raise_error;
*/
end populate_monthly_contributions;
----------------------------------------------
----------------------------------------------
/*SA Worker Movement Report*/
	procedure populate_workers_movement
	(   p_request_id               in  number,
	    p_report                   in  varchar2,
	    p_business_group_id        in  number,
	    p_org_structure_version_id in  number DEFAULT NULL,
	    p_organisation_id          in  number,
	    p_form_type		in	varchar2  DEFAULT NULL,
	    p_effective_date	in	varchar2,
	    p_assignment_id	in	number    DEFAULT NULL,
	    p_assignment_set_id in      number    DEFAULT NULL,
	    l_xfdf_blob  OUT NOCOPY BLOB)
	is
	l_person_id number;
	l_employer_gosi_number varchar2(40);
	l_employee_gosi_number number;
	l_employee_monthly_cont number;
	l_post_box varchar2(250);
	l_defined_balance_id number;
	l_assignment_set_id number;
	l_assignment_action_id number;
	l_payroll_id number;
	l_first_name varchar2(250);
	l_father_name varchar2(250);
	l_grandfather_name varchar2(250);
	l_family_name varchar2(250);
	l_gosi_office varchar2(250);
	l_employer_name varchar2(250);
	l_city varchar2(250);
	l_city_mn varchar2(80);
	l_area varchar2(250);
	l_id_card_number varchar2(50);
	l_civ_id_num	number;
    	l_gender varchar2(50);
	l_gender_male varchar2(50);
    	l_gender_female varchar2(50);
	l_marital_status varchar2(50);
    	l_married varchar2(50);
    	l_single  varchar2(50);
	l_date_of_birth date;
	l_occupation varchar2(250);
	l_termination_reason varchar2(200);
	l_employee_joining_date date;
	l_annuities_join_date varchar2(100);
	l_hazards_join_date varchar2(100);
	l_termination_date date;
	l_effective_date date;
    	l_day varchar2(10);
    	l_month varchar2(10);
    	l_year  varchar2(10);
	l_employer_GOSI_code varchar2(240);
	l_employer_GOSI_office varchar2(240);
        l_employer_GOSI_office_name varchar2(240);
	l_org_id number;
	l_hz_date date;
    	l_form_new_unreg varchar2(30);
    	l_form_new_reg   varchar2(30);
    	l_form_term      varchar2(30);
	type t_varchar is table of varchar2(20)
	  index by binary_integer;
	t_form_type      t_varchar;
	m  number := 0;
	l_nationality		varchar2(30);
	l_nationality_mn		varchar2(80);
	l_hafiza_number		varchar2(30);
	l_hafiza_date		date;
	l_hafiza_place		varchar2(260);
	l_passport_number	varchar2(150);
	l_passport_issue_date	date;
	l_passport_issue_place	varchar2(250);
	l_qualification_type	varchar2(150);
	l_employee_number	varchar2(80);
	l_work_location		varchar2(240);
	l_street		varchar2(150);
	l_email_id		varchar2(240);
	l_zip_code		varchar2(80);
/*Cursor to pick up GOSI Code for the GOSI Office */
  	cursor csr_gosi_code (p_Gosi_Office_Id Number) is
	select	org_information1
	from	hr_organization_information
	where	organization_id = p_Gosi_Office_Id
	and	org_information_context = 'SA_GOSI_OFFICE_DETAILS';
  	 -- Cursor to populate Part G5-A-01,G5-A-05
/*Cursor to pick up Gosi Number and Gosi office for the employer (GRE)*/
    cursor	get_employer_GOSI (p_gre_id number) is
	select	org_information1,org_information2
	from	hr_organization_information
	where	organization_id = p_gre_id
	and	org_information_context = 'SA_EMPLOYER_GOSI_DETAILS';
/*Cursor to select personal information for employee*/
	cursor get_info_per (l_assignment_id number, l_effective_date date) is
	select	first_name,
		per_information1,
		per_information2,
		per_information10,
		last_name
	from	per_all_people_f peo
		,per_all_assignments_f paa
	where	peo.person_id = paa.person_id
	and 	paa.assignment_id = l_assignment_id;
	--and 	l_effective_date between paa.effective_start_date and paa.effective_end_date
        --and     l_effective_date between peo.effective_start_date and peo.effective_end_date;
/*Cursor to select assignments from a given GRE*/
	cursor csr_get_gre_assignments (l_employer_id number, l_business_group_id number, l_effective_date date,l_form_type varchar2)  is
	select /*+ INDEX(hsck, HR_SOFT_CODING_KEYFLEX_PK) */ distinct assignment_id
	from	per_all_assignments_f paa,
	hr_soft_coding_keyflex hsck,
	per_periods_of_service pos
	where hsck.soft_coding_keyflex_id = paa.soft_coding_keyflex_id
	and (nvl(hsck.segment3,'N') = 'Y' OR nvl(hsck.segment5,'N') = 'Y')
	and paa.business_group_id = l_business_group_id
	--and l_effective_date between paa.effective_start_date and paa.effective_end_date
	and hsck.ID_FLEX_NUM = 20
	and hsck.segment1= to_char(l_employer_id)
	and paa.period_of_service_id = pos.period_of_service_id
	and ((l_form_type = 'NU'
	     and trunc(pos.date_start,'MM') = trunc(l_effective_date,'MM')
             and trunc(pos.date_start) <= trunc(l_effective_date)
	     and hsck.segment2 is null)
	     or (l_form_type = 'NR'
	         and trunc(pos.date_start,'MM') = trunc(l_effective_date,'MM')
                 and trunc(pos.date_start) <= trunc(l_effective_date)
	         and hsck.segment2 is not null)
	     or (l_form_type = 'TM'
	         and trunc(pos.actual_termination_date,'MM') = trunc(l_effective_date,'MM')
                 and trunc(pos.actual_termination_date) <= trunc(l_effective_date)));
/*Cursor to select assignments for a given assignment set*/
    cursor csr_get_assignment(l_assignment_set_id number, l_form_type varchar2) is
	select	distinct has.assignment_id
	from	hr_assignment_set_amendments has
	        ,per_all_assignments_f paa
	        ,per_periods_of_service pos
	        ,hr_soft_coding_keyflex hsck
	where	assignment_set_id = l_assignment_set_id
	and	include_or_exclude = 'I'
	and     has.assignment_id = paa.assignment_id
	--and     p_effective_date between paa.effective_start_date and paa.effective_end_date
	and     hsck.soft_coding_keyflex_id = paa.soft_coding_keyflex_id
	and     hsck.ID_FLEX_NUM = 20
	and     hsck.segment1= to_char(p_organisation_id)
	and (nvl(hsck.segment3,'N') = 'Y' OR nvl(hsck.segment5,'N') = 'Y')
	and     paa.period_of_service_id = pos.period_of_service_id
	and ((l_form_type = 'NU'
	     and trunc(pos.date_start,'MM') = trunc(l_effective_date,'MM')
             and trunc(pos.date_start) <= trunc(l_effective_date)
	     and hsck.segment2 is null)
	     or (l_form_type = 'NR'
	         and trunc(pos.date_start,'MM') = trunc(l_effective_date,'MM')
                 and trunc(pos.date_start) <= trunc(l_effective_date)
	         and hsck.segment2 is not null)
	     or (l_form_type = 'TM'
	         and trunc(pos.actual_termination_date,'MM') = trunc(l_effective_date,'MM')
                 and trunc(pos.actual_termination_date) <= trunc(l_effective_date)));
/* Cursor to select Employee GOSI Number */
	cursor get_emp_gosi (l_assignment_id NUMBER, l_effective_date Date) is
	select	hscl.segment2
	from	hr_soft_coding_keyflex hscl
		   ,per_all_assignments_f paa
	where	hscl.SOFT_CODING_KEYFLEX_ID = paa.soft_CODING_KEYFLEX_ID
	and	paa.assignment_id = l_assignment_id
	and	hscl.id_flex_num = 20;
	--and	l_effective_date between paa.effective_start_date and paa.effective_end_date;
/* Cursor to pick up Employee's Organization address */
	cursor get_town_old (l_assignment_id NUMBER, l_effective_date Date) is
	select	hla.town_or_city
		,hla.region_2
		,hla.region_3
	from	hr_locations_all hla
		,hr_organization_units hou
		,per_all_assignments_f paa
	where	paa.organization_id = hou.organization_id
	and	hou.location_id = hla.location_id
	and	paa.assignment_id = l_assignment_id
	--and	l_effective_date between paa.effective_start_date and paa.effective_end_date
	and	paa.business_group_id = hou.business_group_id;
/* Cursor to get person_id*/
   CURSOR get_person_id (l_assignment_id NUMBER) IS
   SELECT person_id
   FROM per_all_assignments_f
   WHERE assignment_id = l_assignment_id;
/*Cursor to pick up employee primary address*/
   CURSOR get_town(l_person_id NUMBER, l_effective_date DATE) IS
   SELECT pa.town_or_city city,
	  pa.region_1 R1,
   	  pa.region_2 R2,
   	  pa.region_3 R3,
	  pa.postal_code ZIP
   FROM   per_addresses pa
   WHERE  pa.primary_flag = 'Y'
   AND    pa.person_id = l_person_id
   AND    l_effective_date BETWEEN trunc(pa.date_from,'MM')
   			       AND nvl(pa.date_to,to_date('31-12-4712','DD-MM-YYYY'));
/*Cursor to pick up person details*/
	cursor get_infos (l_assignment_id NUMBER, l_effective_date Date) is
	select	peo.national_identifier
		,peo.sex
		,peo.marital_status
		,peo.date_of_birth
	from	per_all_people_f peo
		,per_all_assignments_f paa
	where	peo.person_id = paa.person_id
	and 	paa.assignment_id = l_assignment_id;
	--and 	l_effective_date between paa.effective_start_date and paa.effective_end_date
	--and 	l_effective_date between peo.effective_start_date and peo.effective_end_date;
/*Cursor to pick up Employee's Job Name*/
	cursor get_job (l_assignment_id NUMBER, l_effective_date Date) is
	select	name
	from	per_jobs pj,
		per_all_assignments_f paa
	where 	pj.job_id =  paa.job_id
	and paa.business_group_id = pj.business_group_id
	and 	paa.assignment_id = l_assignment_id;
	--and	l_effective_date between paa.effective_start_date and paa.effective_end_date;
/*Cursor to pick up Employee's Work Location*/
	cursor get_work_location (l_assignment_id NUMBER) is
	select	hlp.meaning --distinct TOWN_OR_CITY
	from	hr_locations hl,
		hr_lookups hlp,
		per_all_assignments_f paa
	where 	hl.location_id =  paa.location_id
	and 	paa.assignment_id = l_assignment_id
	and	hlp.lookup_type = 'SA_CITY'
	and hlp.lookup_code = hl.TOWN_OR_CITY;
/* Cursor to fetch nationality, employee_number , e-mail address*/
CURSOR get_nationality (l_person_id NUMBER , l_date date) IS
select nationality,employee_number,email_address
from per_all_people_f ppf
where ppf.person_id = l_person_id
and l_date between ppf.effective_start_date and ppf.effective_end_date;
--cursor to get the passport number and other details
cursor get_passport_number (l_person_id number,l_date date)  is
SELECT	pei.pei_information1 , fnd_date.canonical_to_date(pei.pei_information3) , pei.pei_information5
FROM per_people_extra_info pei
WHERE pei.person_id = l_person_id
AND pei.information_type = 'SA_PASSPORT' AND pei.pei_information_category = 'SA_PASSPORT'
AND l_date between trunc(fnd_date.canonical_to_date(pei.pei_information3),'MM') and fnd_date.canonical_to_date(pei.pei_information4);
--cursor to get the hafiza number
cursor get_hafiza_number (l_person_id number)  is
SELECT	pei.pei_information1,fnd_date.canonical_to_date(pei.pei_information2),pei.pei_information3
FROM per_people_extra_info pei
WHERE pei.person_id = l_person_id
AND pei.information_type = 'SA_HAFIZA' AND pei.pei_information_category = 'SA_HAFIZA'
AND rowid = (select max(rowid) from per_people_extra_info where person_id = l_person_id )   ;
--cursor to get employers town or city
CURSOR csr_get_work_location (l_organization_id number) IS
select town_or_city
from hr_locations hl, hr_all_organization_units hau
where hau.organization_id = l_organization_id
and hau.location_id = hl.location_id;
/*Cursor to get Start and Termination date of employee*/
	cursor get_start_date (l_assignment_id NUMBER, l_effective_date Date) is
	select pps.date_start
		,pps.actual_termination_date
		,pps.leaving_reason
	from	per_periods_of_service pps
		,per_all_assignments_f paa
	where /*pps.person_id = paa.person_id*/
                pps.period_of_service_id = paa.period_of_service_id
	and paa.business_group_id = pps.business_group_id
	and paa.assignment_id = l_assignment_id;
	--and l_effective_date between paa.effective_start_date and paa.effective_end_date;
/*Cursor to pick up GOSI hazards date*/
	cursor get_hazards_date (l_assignment_id NUMBER, l_effective_date Date) is
	select	hscl.segment4,
		hscl.segment6
	from	hr_soft_coding_keyflex hscl
    		,per_all_assignments_f paa
	where	hscl.SOFT_CODING_KEYFLEX_ID = paa.soft_CODING_KEYFLEX_ID
	and	paa.assignment_id = l_assignment_id
	and	hscl.id_flex_num = 20;
	--and	l_effective_date between paa.effective_start_date and paa.effective_end_date;
/*Cursor to get employer for the employee*/
	cursor get_employer (l_assignment_id NUMBER, l_effective_date Date) is
	select	hscl.segment1
	from	hr_soft_coding_keyflex hscl
		,per_all_assignments_f paa
	where	hscl.SOFT_CODING_KEYFLEX_ID = paa.soft_CODING_KEYFLEX_ID
	and	paa.assignment_id = l_assignment_id
	and	hscl.id_flex_num = 20;
	--and	l_effective_date between paa.effective_start_date and paa.effective_end_date;
	  --get employee monthly contribution
        --get defined_balance_id
/*Cursor to pick up assignment actions*/
	cursor	get_assact_id (l_assignment_id NUMBER, l_effective_date Date) is
	select	paa.assignment_action_id
	from	pay_assignment_actions paa
		,per_all_assignments_f paf
		,pay_payroll_actions ppa
	where	paa.assignment_id = paf.assignment_id
	and	paf.assignment_id = l_assignment_id
	and     ppa.payroll_id = paf.payroll_id
	and     ppa.payroll_action_id = paa.payroll_action_id
        and     ppa.action_type in ('R','Q')
        and     ppa.action_status = 'C'
        and     paa.action_status = 'C'
	and     trunc(ppa.date_earned,'MM') = trunc(l_effective_date,'MM');
	--and	l_effective_date between paf.effective_start_date and paf.effective_end_date;
/*Cursor to get nodes from hierarchy*/
	cursor csr_org_hierarchy(p_organisation_id number) is
	select	pose.organization_id_child org
	from	per_org_structure_elements pose
	connect by pose.organization_id_parent = prior pose.organization_id_child
	and pose.org_structure_version_id = p_org_structure_version_id
	start with pose.organization_id_parent = p_organisation_id
	and pose.org_structure_version_id = p_org_structure_version_id
	union
	select	p_organisation_id org
	from	dual;
	rec_org_id	csr_org_hierarchy%rowtype;
/* Cursor to fetch lower limit of gosi base*/
	CURSOR get_lower_base(l_effective_date DATE) IS
	SELECT global_value
	FROM   ff_globals_f
	WHERE  global_name = 'SA_GOSI_BASE_LOWER_LIMIT'
	AND    legislation_code = 'SA'
	AND    business_group_id IS NULL
	AND    l_effective_date BETWEEN effective_start_date
		                    AND effective_end_date;
/* Cursor to fetch upper limit of gosi base*/
	CURSOR get_upper_base(l_effective_date DATE) IS
	SELECT global_value
	FROM   ff_globals_f
	WHERE  global_name = 'SA_GOSI_BASE_UPPER_LIMIT'
	AND    legislation_code = 'SA'
	AND    business_group_id IS NULL
	AND    l_effective_date BETWEEN effective_start_date
		                    AND effective_end_date;
/* Cursor to fetch Phone types for employee*/
CURSOR get_phone_type (l_bus_grp_id NUMBER) IS
SELECT hoi.org_information3 mob_type
      ,hoi.org_information4 tel_type
FROM   hr_organization_information hoi
WHERE  hoi.organization_id = l_bus_grp_id
AND    hoi.org_information_context = 'SA_HR_BG_INFO';
/* Cursor to fetch phone numbers of employee */
CURSOR get_phone_number (l_phone_type VARCHAR2, l_person_id NUMBER, l_effective_date DATE) IS
SELECT phone_number
FROM   per_phones pp,
       per_all_people_f pap
WHERE  pp.parent_id = pap.person_id
AND    pp.phone_type = l_phone_type
AND    pap.person_id = l_person_id
AND    l_effective_date BETWEEN pp.date_from
		            AND nvl(date_to,to_date('31-12-4712','DD-MM-YYYY'));
  /*Table type for variable for storing legal entities within the hierarchy*/
  TYPE t_rec_gre IS RECORD(GRE_NAME varchar2(80), GRE_ID number);
  TYPE t_tab_gre IS TABLE OF t_rec_gre
  INDEX BY BINARY_INTEGER;
  t_legal_entity            t_tab_gre;
  TYPE t_rec_emp IS RECORD(emp_id number);
  TYPE t_tab_emp is TABLE of t_rec_emp
  INDEX BY BINARY_INTEGER;
  t_emp    t_tab_emp;
  i NUMBER(15);
  l_gre_name HR_ORGANIZATION_UNITS.NAME%TYPE;
  l_gre_id   HR_ORGANIZATION_UNITS.ORGANIZATION_ID%TYPE;
  l_gre_present NUMBER;
  l_person_id_new number;
  l_lower_base VARCHAR2(10) := NULL;
  l_upper_base VARCHAR2(10) := NULL;
  l_form     VARCHAR2(20):= NULL;
  l_fm_employee_monthly_cont   varchar2(50) := null;
  l_mobile_number VARCHAR2(30) := null;
  l_tel_number VARCHAR2(30) := null;
  l_mob_type VARCHAR2(10);
  l_tel_type VARCHAR2(10);
begin
  set_currency_mask(p_business_group_id);
  if p_form_type is not null then
    t_form_type(0) := p_form_type;
  else
    t_form_type(0) := 'NU';
    t_form_type(1) := 'NR';
    t_form_type(2) := 'TM';
  end if;
    vXMLTable.DELETE;
    vCtr := 1;
  --l_effective_date := last_day(fnd_date.canonical_to_date(p_effective_date));
  l_effective_date := fnd_date.canonical_to_date(p_effective_date);
  insert into fnd_sessions(session_id,effective_date) values (userenv('sessionid'), l_effective_date);
  for m in t_form_type.first .. t_form_type.last
  loop
  l_form := t_form_type(m);
  T_EMP.DELETE;
  T_LEGAL_ENTITY.DELETE;
 	hr_utility.set_location('Before hierarchy logic',70);
	If p_assignment_id is not null then
	if p_assignment_set_id is not null then
		begin
        		select	1 into i
			from	hr_assignment_set_amendments haa
                                ,per_all_assignments_f paa
                                ,hr_soft_coding_keyflex hscl
     	                        ,per_periods_of_service pos
			where	assignment_set_id = p_assignment_set_id
			and	include_or_exclude = 'I'
                        and     hscl.soft_coding_keyflex_id = paa.soft_coding_keyflex_id
                        and     paa.assignment_id = haa.assignment_id
        		and     haa.assignment_id = p_assignment_id
                        --and     l_effective_date between paa.effective_start_date and paa.effective_end_date
                        and     hscl.segment1 = to_char(p_organisation_id)
                        and     hscl.id_flex_num = 20
                        and (nvl(hscl.segment3,'N') = 'Y' OR nvl(hscl.segment5,'N') = 'Y')
	                and     paa.period_of_service_id = pos.period_of_service_id
        	        and ((l_form = 'NU'
	                    and trunc(pos.date_start,'MM') = trunc(l_effective_date,'MM')
                            and trunc(pos.date_start) <= trunc(l_effective_date)
	                    and hscl.segment2 is null)
	                    or (l_form = 'NR'
	                       and trunc(pos.date_start,'MM') = trunc(l_effective_date,'MM')
                               and trunc(pos.date_start) <= trunc(l_effective_date)
	                       and hscl.segment2 is not null)
	                    or (l_form = 'TM'
	                        and trunc(pos.actual_termination_date,'MM') = trunc(l_effective_date,'MM')
                                and trunc(pos.actual_termination_date) <= trunc(l_effective_date)))
                        and rownum < 2;
        		t_emp(0).emp_id := p_assignment_id;
        		exception
       			when no_data_found then
        	        null;
        	end;
     	else
     	    begin
     	        select distinct paa.assignment_id
     	        into  t_emp(0).emp_id
     	        from  per_all_assignments_f paa,
     	              per_periods_of_service pos,
	              hr_soft_coding_keyflex hsck
                where paa.assignment_id = p_assignment_id
	        --and   p_effective_date between paa.effective_start_date and paa.effective_end_date
	        and   hsck.soft_coding_keyflex_id = paa.soft_coding_keyflex_id
	        and     hsck.ID_FLEX_NUM = 20
                and hsck.segment1= to_char(p_organisation_id)
		and (nvl(hsck.segment3,'N') = 'Y' OR nvl(hsck.segment5,'N') = 'Y')
	        and     paa.period_of_service_id = pos.period_of_service_id
        	and ((l_form = 'NU'
	              and trunc(pos.date_start,'MM') = trunc(l_effective_date,'MM')
                      and trunc(pos.date_start) <= trunc(l_effective_date)
	              and hsck.segment2 is null)
	              or (l_form = 'NR'
	                  and trunc(pos.date_start,'MM') = trunc(l_effective_date,'MM')
                          and trunc(pos.date_start) <= trunc(l_effective_date)
	                  and hsck.segment2 is not null)
	                  or (l_form = 'TM'
	                      and trunc(pos.actual_termination_date,'MM') = trunc(l_effective_date,'MM')
                              and trunc(pos.actual_termination_date) <= trunc(l_effective_date)));
	      exception
	        when others then
	          null;
	      end;
        	--t_emp(0).emp_id := p_assignment_id;
     	end if;
	elsif p_assignment_set_id is not null then
   		i := 0;
	for valid_assignments in csr_get_assignment(p_assignment_set_id,l_form)loop
		t_emp(i).emp_id := valid_assignments.assignment_id;
		i := i + 1;
   	end loop;
	else
-- New code begins
l_gre_id := p_organisation_id;
-- New code ends
       i := 0;
l_form := t_form_type(m);
       for valid_assignments in csr_get_gre_assignments(l_gre_id, p_business_group_id, l_effective_date,l_form) loop
		  t_emp(i).emp_id := valid_assignments.assignment_id;
						i := i + 1;
	  end loop;
end if;
	hr_utility.set_location('Entering procedure workers movement Report ',80);
	if t_emp.count > 0 then
		for j in t_emp.first..t_emp.last loop
		/*Reset the local variables */
		l_employer_GOSI_office_name := null;
		l_employer_GOSI_code := null;
		l_employer_name := null;
		l_employer_GOSI_number := null;
		l_first_name := null;
		l_father_name := null;
		l_grandfather_name := null;
		l_family_name := null;
                l_employee_gosi_number := null;
	        l_city := null;
	        l_area := null;
	        l_post_box := null;
		l_id_card_number := null;
		l_gender := null;
		l_gender_female := null;
		l_gender_male := null;
		l_marital_status := null;
		l_single := null;
		l_married := null;
		l_date_of_birth := null;
		l_year := null;
		l_month := null;
		l_day := null;
		l_occupation := null;
		l_employee_joining_date := null;
		l_termination_date := null;
		l_termination_reason := null;
		l_annuities_join_date := null;
		l_hazards_join_date := null;
		l_assignment_action_id := null;
		l_employee_monthly_cont := null;
		open get_employer (t_emp(j).emp_id, l_effective_date);
		fetch get_employer into l_org_id;
		close get_employer;
		begin
		  select name
		  into   l_employer_name
		  from   hr_organization_units
		  where  organization_id = l_org_id;
		exception
		  when others then
		    l_employer_name := null;
		end;
		open get_employer_GOSI(l_org_id);
		fetch get_employer_GOSI into l_employer_GOSI_number,l_employer_GOSI_office;
		close get_employer_GOSI;
		begin
		  select name
		  into   l_employer_gosi_office_name
		  from   hr_organization_units
		  where  organization_id = l_employer_gosi_office;
		exception
		  when others then
		    l_employer_gosi_office_name := null;
		end;
		open csr_GOSI_code(l_employer_GOSI_office);
		fetch csr_GOSI_code into l_employer_GOSI_code;
		close csr_GOSI_code;
		vXMLTable(vCtr).TagName := 'G3-A-01';
	        vXMLTable(vCtr).TagValue := l_employer_gosi_code||'     '||(l_employer_GOSI_office_name);
	        vCtr := vCtr + 1;
		/*vXMLTable(vCtr).TagName := 'G3-A-01-1';
	        vXMLTable(vCtr).TagValue := substr(l_employer_GOSI_code,1,1);
	        vCtr := vCtr + 1;
	        vXMLTable(vCtr).TagName := 'G3-A-01-2';
	        vXMLTable(vCtr).TagValue := substr(l_employer_GOSI_code,2,1);
	        vCtr := vCtr + 1;*/
	        if t_form_type(m) = 'NU' then
    		    	l_form_new_unreg := 'X';
    		    	l_form_new_reg   := null;
    		    	l_form_term      := null;
    		elsif t_form_type(m) = 'NR' then
    		    	l_form_new_unreg := null;
    		    	l_form_new_reg   := 'X';
    		    	l_form_term      := null;
    		elsif t_form_type(m) = 'TM' then
    		    	l_form_new_unreg := null;
        		l_form_new_reg   := null;
        		l_form_term      := 'X';
    end if;
	vXMLTable(vCtr).TagName := 'G3-A-02-1';
        vXMLTable(vCtr).TagValue := l_form_new_unreg;
        vCtr := vCtr + 1;
    vXMLTable(vCtr).TagName := 'G3-A-02-2';
        vXMLTable(vCtr).TagValue := l_form_new_reg;
        vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'G3-A-02-3';
        vXMLTable(vCtr).TagValue := l_form_term;
        vCtr := vCtr + 1;
      vXMLTable(vCtr).TagName := 'G3-A-03';
      vXMLTable(vCtr).TagValue := l_employer_name;
      vCtr := vCtr + 1;
      vXMLTable(vCtr).TagName := 'G3-A-04-9';
      vXMLTable(vCtr).TagValue := substr(l_employer_GOSI_number,9,1);
      vCtr := vCtr + 1;
      vXMLTable(vCtr).TagName := 'G3-A-04-8';
      vXMLTable(vCtr).TagValue := substr(l_employer_GOSI_number,8,1);
      vCtr := vCtr + 1;
      vXMLTable(vCtr).TagName := 'G3-A-04-7';
      vXMLTable(vCtr).TagValue := substr(l_employer_GOSI_number,7,1);
      vCtr := vCtr + 1;
      vXMLTable(vCtr).TagName := 'G3-A-04-6';
      vXMLTable(vCtr).TagValue := substr(l_employer_GOSI_number,6,1);
      vCtr := vCtr + 1;
      vXMLTable(vCtr).TagName := 'G3-A-04-5';
      vXMLTable(vCtr).TagValue := substr(l_employer_GOSI_number,5,1);
      vCtr := vCtr + 1;
      vXMLTable(vCtr).TagName := 'G3-A-04-4';
      vXMLTable(vCtr).TagValue := substr(l_employer_GOSI_number,4,1);
      vCtr := vCtr + 1;
      vXMLTable(vCtr).TagName := 'G3-A-04-3';
      vXMLTable(vCtr).TagValue := substr(l_employer_GOSI_number,3,1);
      vCtr := vCtr + 1;
      vXMLTable(vCtr).TagName := 'G3-A-04-2';
      vXMLTable(vCtr).TagValue := substr(l_employer_GOSI_number,2,1);
      vCtr := vCtr + 1;
  	vXMLTable(vCtr).TagName := 'G3-A-04-1';
      vXMLTable(vCtr).TagValue := substr(l_employer_GOSI_number,1,1);
      vCtr := vCtr + 1;
      --get personal info - all names of person
	open get_info_per(t_emp(j).emp_id, l_effective_date);
	fetch get_info_per into l_first_name,l_father_name ,l_grandfather_name ,l_qualification_type , l_family_name;
	close get_info_per;
     --get employee gosi number
	open get_emp_gosi(t_emp(j).emp_id, l_effective_date);
	fetch get_emp_gosi into l_employee_gosi_number;
	close get_emp_gosi;
      --get city, area and post box of employee
        /* To get person_id from assignment_id*/
        OPEN get_person_id(t_emp(j).emp_id);
        FETCH get_person_id INTO l_person_id_new;
        CLOSE get_person_id;
	open get_town(l_person_id_new, l_effective_date);
	fetch get_town  into   l_city,l_street, l_area, l_post_box,l_zip_code;
	close get_town;
	If l_city is not null then
		BEGIN
			SELECT hl.meaning
			INTO l_city_mn
			FROM hr_lookups hl
			WHERE hl.lookup_type = 'SA_CITY'
			AND hl.lookup_code = l_city
			AND hl.enabled_flag = 'Y';
		END;
	End if;
	OPEN get_phone_type (p_business_group_id);
	  FETCH get_phone_type INTO l_mob_type, l_tel_type;
	CLOSE get_phone_type;
	OPEN get_phone_number(l_mob_type,l_person_id_new,l_effective_date);
	  FETCH get_phone_number INTO l_mobile_number;
	CLOSE get_phone_number;
	OPEN get_phone_number(l_tel_type,l_person_id_new,l_effective_date);
 	  FETCH get_phone_number INTO l_tel_number;
	CLOSE get_phone_number;
	vXMLTable(vCtr).TagName := 'G3-B-01';
      vXMLTable(vCtr).TagValue := l_first_name;
      vCtr := vCtr + 1;
      vXMLTable(vCtr).TagName := 'G3-B-02';
      vXMLTable(vCtr).TagValue := l_father_name;
      vCtr := vCtr + 1;
      vXMLTable(vCtr).TagName := 'G3-B-03';
      vXMLTable(vCtr).TagValue := l_grandfather_name;
      vCtr := vCtr + 1;
      vXMLTable(vCtr).TagName := 'G3-B-04';
      vXMLTable(vCtr).TagValue := l_family_name;
      vCtr := vCtr + 1;
      vXMLTable(vCtr).TagName := 'G3-B-05-1';
      vXMLTable(vCtr).TagValue := substr(l_employee_gosi_number,1,1);
      vCtr := vCtr + 1;
      vXMLTable(vCtr).TagName := 'G3-B-05-2';
      vXMLTable(vCtr).TagValue := substr(l_employee_gosi_number,2,1);
      vCtr := vCtr + 1;
      vXMLTable(vCtr).TagName := 'G3-B-05-3';
      vXMLTable(vCtr).TagValue := substr(l_employee_gosi_number,3,1);
      vCtr := vCtr + 1;
      vXMLTable(vCtr).TagName := 'G3-B-05-4';
      vXMLTable(vCtr).TagValue := substr(l_employee_gosi_number,4,1);
      vCtr := vCtr + 1;
      vXMLTable(vCtr).TagName := 'G3-B-05-5';
      vXMLTable(vCtr).TagValue := substr(l_employee_gosi_number,5,1);
      vCtr := vCtr + 1;
      vXMLTable(vCtr).TagName := 'G3-B-05-6';
      vXMLTable(vCtr).TagValue := substr(l_employee_gosi_number,6,1);
      vCtr := vCtr + 1;
      vXMLTable(vCtr).TagName := 'G3-B-05-7';
      vXMLTable(vCtr).TagValue :=substr(l_employee_gosi_number,7,1);
      vCtr := vCtr + 1;
      vXMLTable(vCtr).TagName := 'G3-B-05-8';
      vXMLTable(vCtr).TagValue := substr(l_employee_gosi_number,8,1);
      vCtr := vCtr + 1;
      vXMLTable(vCtr).TagName := 'G3-B-05-9';
      vXMLTable(vCtr).TagValue := substr(l_employee_gosi_number,9,1);
      vCtr := vCtr + 1;
      vXMLTable(vCtr).TagName := 'G3-B-06';
      vXMLTable(vCtr).TagValue := l_city_mn;
      vCtr := vCtr + 1;
      vXMLTable(vCtr).TagName := 'G3-B-07';
      vXMLTable(vCtr).TagValue := l_area;
      vCtr := vCtr + 1;
      vXMLTable(vCtr).TagName := 'G3-B-08';
      vXMLTable(vCtr).TagValue := l_post_box;
      vCtr := vCtr + 1;
      vXMLTable(vCtr).TagName := 'G3-B-09';
      vXMLTable(vCtr).TagValue := l_tel_number;
      vCtr := vCtr + 1;
      vXMLTable(vCtr).TagName := 'G3-B-10';
      vXMLTable(vCtr).TagValue := l_mobile_number;
      vCtr := vCtr + 1;
      --get id card num, gender, marital status, dob
	open get_infos(t_emp(j).emp_id, l_effective_date);
	fetch get_infos into l_id_card_number, l_gender, l_marital_status, l_date_of_birth;
	close get_infos ;
	l_civ_id_num := to_number(replace(l_id_card_number,'-',''));
	If length(l_civ_id_num) > 10 then
	      vXMLTable(vCtr).TagName := 'G3-C-01-0';
--	      vXMLTable(vCtr).TagValue := substr(l_civ_id_num,11,1);
	      vXMLTable(vCtr).TagValue := ' ';
	      vCtr := vCtr + 1;
	end if;
      vXMLTable(vCtr).TagName := 'G3-C-01-1';
      vXMLTable(vCtr).TagValue := substr(l_civ_id_num,1,1);
      vCtr := vCtr + 1;
      vXMLTable(vCtr).TagName := 'G3-C-01-2';
      vXMLTable(vCtr).TagValue := substr(l_civ_id_num,2,1);
      vCtr := vCtr + 1;
      vXMLTable(vCtr).TagName := 'G3-C-01-3';
      vXMLTable(vCtr).TagValue := substr(l_civ_id_num,3,1);
      vCtr := vCtr + 1;
      vXMLTable(vCtr).TagName := 'G3-C-01-4';
      vXMLTable(vCtr).TagValue := substr(l_civ_id_num,4,1);
      vCtr := vCtr + 1;
      vXMLTable(vCtr).TagName := 'G3-C-01-5';
      vXMLTable(vCtr).TagValue := substr(l_civ_id_num,5,1);
      vCtr := vCtr + 1;
      vXMLTable(vCtr).TagName := 'G3-C-01-6';
      vXMLTable(vCtr).TagValue := substr(l_civ_id_num,6,1);
      vCtr := vCtr + 1;
      vXMLTable(vCtr).TagName := 'G3-C-01-7';
      vXMLTable(vCtr).TagValue := substr(l_civ_id_num,7,1);
      vCtr := vCtr + 1;
      vXMLTable(vCtr).TagName := 'G3-C-01-8';
      vXMLTable(vCtr).TagValue := substr(l_civ_id_num,8,1);
      vCtr := vCtr + 1;
      vXMLTable(vCtr).TagName := 'G3-C-01-9';
      vXMLTable(vCtr).TagValue := substr(l_civ_id_num,9,1);
      vCtr := vCtr + 1;
      vXMLTable(vCtr).TagName := 'G3-C-01-10';
      vXMLTable(vCtr).TagValue := substr(l_civ_id_num,10,1);
      vCtr := vCtr + 1;
      if(l_gender = 'M') then
      l_gender_male := 'X';
      l_gender_female := NULL;
      elsif l_gender ='F' then
      l_gender_male := NULL;
      l_gender_female := 'X';
      end if;
      vXMLTable(vCtr).TagName := 'G3-C-02-2';
      vXMLTable(vCtr).TagValue := l_gender_female;
      vCtr := vCtr + 1;
      vXMLTable(vCtr).TagName := 'G3-C-02-1';
      vXMLTable(vCtr).TagValue := l_gender_male;
      vCtr := vCtr + 1;
      if(l_marital_status = 'M') then
      l_married := 'X';
      l_single := NULL;
      else
      l_married := NULL;
      l_single := 'X';
      end if;
 	vXMLTable(vCtr).TagName := 'G3-C-03-2';
      	vXMLTable(vCtr).TagValue := l_single;
      	vCtr := vCtr + 1;
      	vXMLTable(vCtr).TagName := 'G3-C-03-1';
      	vXMLTable(vCtr).TagValue := l_married;
      	vCtr := vCtr + 1;
    	l_day := to_char(l_date_of_birth,'DD');
    	l_month := to_char(l_date_of_birth,'MM');
    	l_year := to_char(l_date_of_birth,'YYYY');
      	vXMLTable(vCtr).TagName := 'G3-C-04-1';
      	vXMLTable(vCtr).TagValue := substr(to_char(l_date_of_birth,'DD-MM-YYYY'),7,1);
      	vCtr := vCtr + 1;
       	vXMLTable(vCtr).TagName := 'G3-C-04-2';
      	vXMLTable(vCtr).TagValue := substr(to_char(l_date_of_birth,'DD-MM-YYYY'),8,1);
      	vCtr := vCtr + 1;
        vXMLTable(vCtr).TagName := 'G3-C-04-3';
      	vXMLTable(vCtr).TagValue := substr(to_char(l_date_of_birth,'DD-MM-YYYY'),9,1);
      	vCtr := vCtr + 1;
        vXMLTable(vCtr).TagName := 'G3-C-04-4';
      	vXMLTable(vCtr).TagValue := substr(to_char(l_date_of_birth,'DD-MM-YYYY'),10,1);
      	vCtr := vCtr + 1;
        vXMLTable(vCtr).TagName := 'G3-C-04-5';
      	vXMLTable(vCtr).TagValue := substr(to_char(l_date_of_birth,'DD-MM-YYYY'),4,1);
      	vCtr := vCtr + 1;
        vXMLTable(vCtr).TagName := 'G3-C-04-6';
      	vXMLTable(vCtr).TagValue := substr(to_char(l_date_of_birth,'DD-MM-YYYY'),5,1);
      	vCtr := vCtr + 1;
        vXMLTable(vCtr).TagName := 'G3-C-04-7';
      	vXMLTable(vCtr).TagValue := substr(to_char(l_date_of_birth,'DD-MM-YYYY'),1,1);
      	vCtr := vCtr + 1;
        vXMLTable(vCtr).TagName := 'G3-C-04-8';
      	vXMLTable(vCtr).TagValue := substr(to_char(l_date_of_birth,'DD-MM-YYYY'),2,1);
      	vCtr := vCtr + 1;
        vXMLTable(vCtr).TagName := 'G3-C-04-9';
      	vXMLTable(vCtr).TagValue := 'G';
      	vCtr := vCtr + 1;
      --get occupation name
      	open get_job(t_emp(j).emp_id, l_effective_date);
	fetch get_job into l_occupation;
	close get_job;
      	vXMLTable(vCtr).TagName := 'G3-C-05';
     	vXMLTable(vCtr).TagValue := l_occupation;
      	vCtr := vCtr + 1;
      --get joining date, termination date, termination reason
      	open get_start_date(t_emp(j).emp_id, l_effective_date);
	fetch get_start_date into l_employee_joining_date,l_termination_date,l_termination_reason;
	close get_start_date;
        if t_form_type(m) <> 'TM' then
          l_termination_date := null;
          l_termination_reason := null;
        end if;
      -- get anuuities join date and hazards join date
	open get_hazards_date(t_emp(j).emp_id, l_effective_date);
	fetch get_hazards_date into l_annuities_join_date,l_hazards_join_date;
	close get_hazards_date;
      --get employee monthly contribution
      OPEN get_lower_base(l_effective_date);
      	FETCH get_lower_base INTO l_lower_base;
      CLOSE get_lower_base;
      OPEN get_upper_base(l_effective_date);
        FETCH get_upper_base INTO l_upper_base;
      CLOSE get_upper_base;
      --get defined_balance_id
         select  u.creator_id
	     into    l_defined_balance_id
	     from    ff_user_entities  u,
	             ff_database_items d
	     where   d.user_name = 'GOSI_REFERENCE_EARNINGS_ASG_YTD'
	     and     u.user_entity_id = d.user_entity_id
	     and     u.legislation_code = 'SA'
	     and     u.business_group_id is null
	     and     u.creator_type = 'B';
	        --get assignment_action_id
	open get_assact_id(t_emp(j).emp_id, l_effective_date);
	fetch get_assact_id into l_assignment_action_id;
	close get_assact_id;
          --get monthly contribution
          if l_assignment_action_id is not null then
	    l_employee_monthly_cont := pay_balance_pkg.get_value(l_defined_balance_id, l_assignment_action_id);
	    IF (l_employee_monthly_cont > to_number(l_upper_base)) THEN
	    	l_employee_monthly_cont := to_number(l_upper_base);
	    ELSIF ( l_employee_monthly_cont < to_number(l_lower_base)) THEN
	    	l_employee_monthly_cont := to_number(l_lower_base);
	    END IF;
	  else
	    l_employee_monthly_cont := null;
	  end if;
     	l_day := to_char(l_employee_joining_date,'DD');
     	l_month := to_char(l_employee_joining_date,'MM');
     	l_year := to_char(l_employee_joining_date,'YYYY');
	    vXMLTable(vCtr).TagName := 'G3-C-06-1';
	    vXMLTable(vCtr).TagValue := substr(to_char(l_employee_joining_date,'DD-MM-YYYY'),7,1);
	    vCtr := vCtr + 1;
   	    vXMLTable(vCtr).TagName := 'G3-C-06-2';
	    vXMLTable(vCtr).TagValue := substr(to_char(l_employee_joining_date,'DD-MM-YYYY'),8,1);
	    vCtr := vCtr + 1;
	    vXMLTable(vCtr).TagName := 'G3-C-06-3';
	    vXMLTable(vCtr).TagValue := substr(to_char(l_employee_joining_date,'DD-MM-YYYY'),9,1);
	    vCtr := vCtr + 1;
	    vXMLTable(vCtr).TagName := 'G3-C-06-4';
	    vXMLTable(vCtr).TagValue := substr(to_char(l_employee_joining_date,'DD-MM-YYYY'),10,1);
	    vCtr := vCtr + 1;
	    vXMLTable(vCtr).TagName := 'G3-C-06-5';
	    vXMLTable(vCtr).TagValue := substr(to_char(l_employee_joining_date,'DD-MM-YYYY'),4,1);
	    vCtr := vCtr + 1;
	    vXMLTable(vCtr).TagName := 'G3-C-06-6';
	    vXMLTable(vCtr).TagValue := substr(to_char(l_employee_joining_date,'DD-MM-YYYY'),5,1);
	    vCtr := vCtr + 1;
	    vXMLTable(vCtr).TagName := 'G3-C-06-7';
	    vXMLTable(vCtr).TagValue := substr(to_char(l_employee_joining_date,'DD-MM-YYYY'),1,1);
	    vCtr := vCtr + 1;
	    vXMLTable(vCtr).TagName := 'G3-C-06-8';
	    vXMLTable(vCtr).TagValue := substr(to_char(l_employee_joining_date,'DD-MM-YYYY'),2,1);
	    vCtr := vCtr + 1;
     l_day := to_char(fnd_date.canonical_to_date(l_annuities_join_date),'DD');
     l_month := to_char(fnd_date.canonical_to_date(l_annuities_join_date),'MM');
     l_year := to_char(fnd_date.canonical_to_date(l_annuities_join_date),'YYYY');
/**	Added as per the GOSI Report 3+4 enhancement	*/
	    vXMLTable(vCtr).TagName := 'G3-N-08';
	    vXMLTable(vCtr).TagValue := l_street;
	    vCtr := vCtr + 1;
	    vXMLTable(vCtr).TagName := 'G3-N-10';
	    vXMLTable(vCtr).TagValue := l_zip_code;
	    vCtr := vCtr + 1;
	open get_work_location(t_emp(j).emp_id);
	fetch get_work_location into l_work_location;
	close get_work_location;
	If l_work_location is null then
		BEGIN
			select	distinct TOWN_OR_CITY
			into l_work_location
			from	hr_locations hl,
			per_all_assignments_f paa
			where 	hl.location_id =  paa.location_id
			And 	paa.assignment_id = t_emp(j).emp_id;
		exception
			WHEN OTHERS THEN NULL;
		end ;
	end if;
	    vXMLTable(vCtr).TagName := 'G3-N-07';
	    vXMLTable(vCtr).TagValue := l_work_location;
	    vCtr := vCtr + 1;
	open get_nationality(l_person_id_new,l_effective_date);
	fetch get_nationality into l_nationality,l_employee_number,l_email_id;
	close get_nationality;
	l_nationality_mn := null;
	If l_nationality is not null then
		SELECT hl.meaning
		INTO l_nationality_mn
		FROM hr_lookups hl
		WHERE hl.lookup_type = 'NATIONALITY'
		and hl.lookup_code = l_nationality
		and hl.enabled_flag = 'Y';
	End If;
	    vXMLTable(vCtr).TagName := 'G3-N-01';
	    vXMLTable(vCtr).TagValue := l_nationality_mn;
	    vCtr := vCtr + 1;
	    vXMLTable(vCtr).TagName := 'G3-N-06-1';
	    vXMLTable(vCtr).TagValue := substr(l_employee_number,1,1);
	    vCtr := vCtr + 1;
	    vXMLTable(vCtr).TagName := 'G3-N-06-2';
	    vXMLTable(vCtr).TagValue := nvl(substr(l_employee_number,2,1),' ');
	    vCtr := vCtr + 1;
	    vXMLTable(vCtr).TagName := 'G3-N-06-3';
	    vXMLTable(vCtr).TagValue := nvl(substr(l_employee_number,3,1),' ');
	    vCtr := vCtr + 1;
	    vXMLTable(vCtr).TagName := 'G3-N-06-4';
	    vXMLTable(vCtr).TagValue := nvl(substr(l_employee_number,4,1),' ');
	    vCtr := vCtr + 1;
	    vXMLTable(vCtr).TagName := 'G3-N-06-5';
	    vXMLTable(vCtr).TagValue := nvl(substr(l_employee_number,5,1),' ');
	    vCtr := vCtr + 1;
	    vXMLTable(vCtr).TagName := 'G3-N-06-6';
	    vXMLTable(vCtr).TagValue := nvl(substr(l_employee_number,6,1),' ');
	    vCtr := vCtr + 1;
	    vXMLTable(vCtr).TagName := 'G3-N-06-7';
	    vXMLTable(vCtr).TagValue := nvl(substr(l_employee_number,7,1),' ');
	    vCtr := vCtr + 1;
	    vXMLTable(vCtr).TagName := 'G3-N-06-8';
	    vXMLTable(vCtr).TagValue := nvl(substr(l_employee_number,8,1),' ');
	    vCtr := vCtr + 1;
	    vXMLTable(vCtr).TagName := 'G3-N-06-9';
	    vXMLTable(vCtr).TagValue := nvl(substr(l_employee_number,9,1),' ');
	    vCtr := vCtr + 1;
	    vXMLTable(vCtr).TagName := 'G3-N-09';
	    vXMLTable(vCtr).TagValue := l_email_id;
	    vCtr := vCtr + 1;
	IF upper(l_nationality) <> FND_PROFILE.VALUE('PER_LOCAL_NATIONALITY') then
		open get_passport_number(l_person_id_new,l_effective_date);
		fetch get_passport_number into l_passport_number,l_passport_issue_date,l_passport_issue_place;
		close get_passport_number;
		    vXMLTable(vCtr).TagName := 'G3-N-02-1';
		    vXMLTable(vCtr).TagValue := nvl(substr(l_passport_number,1,1),' ');
		    vCtr := vCtr + 1;
		    vXMLTable(vCtr).TagName := 'G3-N-02-2';
		    vXMLTable(vCtr).TagValue := nvl(substr(l_passport_number,2,1),' ');
		    vCtr := vCtr + 1;
		    vXMLTable(vCtr).TagName := 'G3-N-02-3';
		    vXMLTable(vCtr).TagValue := nvl(substr(l_passport_number,3,1),' ');
		    vCtr := vCtr + 1;
		    vXMLTable(vCtr).TagName := 'G3-N-02-4';
		    vXMLTable(vCtr).TagValue := nvl(substr(l_passport_number,4,1),' ');
		    vCtr := vCtr + 1;
		    vXMLTable(vCtr).TagName := 'G3-N-02-5';
		    vXMLTable(vCtr).TagValue := nvl(substr(l_passport_number,5,1),' ');
		    vCtr := vCtr + 1;
		    vXMLTable(vCtr).TagName := 'G3-N-02-6';
		    vXMLTable(vCtr).TagValue := nvl(substr(l_passport_number,6,1),' ');
		    vCtr := vCtr + 1;
		    vXMLTable(vCtr).TagName := 'G3-N-02-7';
		    vXMLTable(vCtr).TagValue := nvl(substr(l_passport_number,7,1),' ');
		    vCtr := vCtr + 1;
		    vXMLTable(vCtr).TagName := 'G3-N-02-8';
		    vXMLTable(vCtr).TagValue := nvl(substr(l_passport_number,8,1),' ');
		    vCtr := vCtr + 1;
		    vXMLTable(vCtr).TagName := 'G3-N-02-9';
		    vXMLTable(vCtr).TagValue := nvl(substr(l_passport_number,9,1),' ');
		    vCtr := vCtr + 1;
		    vXMLTable(vCtr).TagName := 'G3-N-02-10';
		    vXMLTable(vCtr).TagValue := nvl(substr(l_passport_number,10,1),' ');
		    vCtr := vCtr + 1;
		    vXMLTable(vCtr).TagName := 'G3-N-03-1';
		    vXMLTable(vCtr).TagValue := substr(to_char(l_passport_issue_date,'DD-MM-YYYY'),7,1);
		    vCtr := vCtr + 1;
		    vXMLTable(vCtr).TagName := 'G3-N-03-2';
		    vXMLTable(vCtr).TagValue := substr(to_char(l_passport_issue_date,'DD-MM-YYYY'),8,1);
		    vCtr := vCtr + 1;
		    vXMLTable(vCtr).TagName := 'G3-N-03-3';
		    vXMLTable(vCtr).TagValue := substr(to_char(l_passport_issue_date,'DD-MM-YYYY'),9,1);
		    vCtr := vCtr + 1;
		    vXMLTable(vCtr).TagName := 'G3-N-03-4';
		    vXMLTable(vCtr).TagValue := substr(to_char(l_passport_issue_date,'DD-MM-YYYY'),10,1);
		    vCtr := vCtr + 1;
		    vXMLTable(vCtr).TagName := 'G3-N-03-5';
		    vXMLTable(vCtr).TagValue := substr(to_char(l_passport_issue_date,'DD-MM-YYYY'),4,1);
		    vCtr := vCtr + 1;
		    vXMLTable(vCtr).TagName := 'G3-N-03-6';
		    vXMLTable(vCtr).TagValue := substr(to_char(l_passport_issue_date,'DD-MM-YYYY'),5,1);
		    vCtr := vCtr + 1;
		    vXMLTable(vCtr).TagName := 'G3-N-03-7';
		    vXMLTable(vCtr).TagValue := substr(to_char(l_passport_issue_date,'DD-MM-YYYY'),1,1);
		    vCtr := vCtr + 1;
		    vXMLTable(vCtr).TagName := 'G3-N-03-8';
		    vXMLTable(vCtr).TagValue := substr(to_char(l_passport_issue_date,'DD-MM-YYYY'),2,1);
		    vCtr := vCtr + 1;
		    vXMLTable(vCtr).TagName := 'G3-N-04';
		    vXMLTable(vCtr).TagValue := l_passport_issue_place;
		    vCtr := vCtr + 1;
	Else
		open get_hafiza_number(l_person_id_new);
		fetch get_hafiza_number into l_hafiza_number,l_hafiza_date,l_hafiza_place;
		close get_hafiza_number;
		    vXMLTable(vCtr).TagName := 'G3-N-02-1';
		    vXMLTable(vCtr).TagValue := nvl(substr(l_hafiza_number,1,1),' ');
		    vCtr := vCtr + 1;
		    vXMLTable(vCtr).TagName := 'G3-N-02-2';
		    vXMLTable(vCtr).TagValue := nvl(substr(l_hafiza_number,2,1),' ');
		    vCtr := vCtr + 1;
		    vXMLTable(vCtr).TagName := 'G3-N-02-3';
		    vXMLTable(vCtr).TagValue := nvl(substr(l_hafiza_number,3,1),' ');
		    vCtr := vCtr + 1;
		    vXMLTable(vCtr).TagName := 'G3-N-02-4';
		    vXMLTable(vCtr).TagValue := nvl(substr(l_hafiza_number,4,1),' ');
		    vCtr := vCtr + 1;
		    vXMLTable(vCtr).TagName := 'G3-N-02-5';
		    vXMLTable(vCtr).TagValue := nvl(substr(l_hafiza_number,5,1),' ');
		    vCtr := vCtr + 1;
		    vXMLTable(vCtr).TagName := 'G3-N-02-6';
		    vXMLTable(vCtr).TagValue := nvl(substr(l_hafiza_number,6,1),' ');
		    vCtr := vCtr + 1;
		    vXMLTable(vCtr).TagName := 'G3-N-02-7';
		    vXMLTable(vCtr).TagValue := nvl(substr(l_hafiza_number,7,1),' ');
		    vCtr := vCtr + 1;
		    vXMLTable(vCtr).TagName := 'G3-N-02-8';
		    vXMLTable(vCtr).TagValue := nvl(substr(l_hafiza_number,8,1),' ');
		    vCtr := vCtr + 1;
		    vXMLTable(vCtr).TagName := 'G3-N-02-9';
		    vXMLTable(vCtr).TagValue := nvl(substr(l_hafiza_number,9,1),' ');
		    vCtr := vCtr + 1;
		    vXMLTable(vCtr).TagName := 'G3-N-02-10';
		    vXMLTable(vCtr).TagValue := nvl(substr(l_hafiza_number,10,1),' ');
		    vCtr := vCtr + 1;
		    vXMLTable(vCtr).TagName := 'G3-N-03-1';
		    vXMLTable(vCtr).TagValue := substr(to_char(l_hafiza_date,'DD-MM-YYYY'),7,1);
		    vCtr := vCtr + 1;
		    vXMLTable(vCtr).TagName := 'G3-N-03-2';
		    vXMLTable(vCtr).TagValue := substr(to_char(l_hafiza_date,'DD-MM-YYYY'),8,1);
		    vCtr := vCtr + 1;
		    vXMLTable(vCtr).TagName := 'G3-N-03-3';
		    vXMLTable(vCtr).TagValue := substr(to_char(l_hafiza_date,'DD-MM-YYYY'),9,1);
		    vCtr := vCtr + 1;
		    vXMLTable(vCtr).TagName := 'G3-N-03-4';
		    vXMLTable(vCtr).TagValue := substr(to_char(l_hafiza_date,'DD-MM-YYYY'),10,1);
		    vCtr := vCtr + 1;
		    vXMLTable(vCtr).TagName := 'G3-N-03-5';
		    vXMLTable(vCtr).TagValue := substr(to_char(l_hafiza_date,'DD-MM-YYYY'),4,1);
		    vCtr := vCtr + 1;
		    vXMLTable(vCtr).TagName := 'G3-N-03-6';
		    vXMLTable(vCtr).TagValue := substr(to_char(l_hafiza_date,'DD-MM-YYYY'),5,1);
		    vCtr := vCtr + 1;
		    vXMLTable(vCtr).TagName := 'G3-N-03-7';
		    vXMLTable(vCtr).TagValue := substr(to_char(l_hafiza_date,'DD-MM-YYYY'),1,1);
		    vCtr := vCtr + 1;
		    vXMLTable(vCtr).TagName := 'G3-N-03-8';
		    vXMLTable(vCtr).TagValue := substr(to_char(l_hafiza_date,'DD-MM-YYYY'),2,1);
		    vCtr := vCtr + 1;
		    vXMLTable(vCtr).TagName := 'G3-N-04';
		    vXMLTable(vCtr).TagValue := substr(l_hafiza_place,1,60);
		    vCtr := vCtr + 1;
	END If;
	    if l_qualification_type is not null then
	    	if l_qualification_type = '1' then
		    vXMLTable(vCtr).TagName := 'G3-N-05-1';
		    vXMLTable(vCtr).TagValue := 'X';
	            vCtr := vCtr + 1;
	        elsif l_qualification_type = '2' then
		    vXMLTable(vCtr).TagName := 'G3-N-05-2';
		    vXMLTable(vCtr).TagValue := 'X';
	            vCtr := vCtr + 1;
	        elsif l_qualification_type = '3' then
		    vXMLTable(vCtr).TagName := 'G3-N-05-3';
		    vXMLTable(vCtr).TagValue := 'X';
	            vCtr := vCtr + 1;
	        elsif l_qualification_type = '4' then
		    vXMLTable(vCtr).TagName := 'G3-N-05-4';
		    vXMLTable(vCtr).TagValue := 'X';
	            vCtr := vCtr + 1;
	        elsif l_qualification_type = '5' then
		    vXMLTable(vCtr).TagName := 'G3-N-05-5';
		    vXMLTable(vCtr).TagValue := 'X';
	            vCtr := vCtr + 1;
	        elsif l_qualification_type = '6' then
		    vXMLTable(vCtr).TagName := 'G3-N-05-6';
		    vXMLTable(vCtr).TagValue := 'X';
	            vCtr := vCtr + 1;
	        elsif l_qualification_type = '7' then
		    vXMLTable(vCtr).TagName := 'G3-N-05-7';
		    vXMLTable(vCtr).TagValue := 'X';
	            vCtr := vCtr + 1;
	        end if;
	     end if;
/*	Added as per the GOSI Report 3+4 enhancement	**/
/* Cancelled as per the GOSI Report 3+4 enhancement.
	    vXMLTable(vCtr).TagName := 'G3-C-07-1';
	    vXMLTable(vCtr).TagValue := l_year;
	    vCtr := vCtr + 1;
   	    vXMLTable(vCtr).TagName := 'G3-C-07-2';
	    vXMLTable(vCtr).TagValue := l_month;
	    vCtr := vCtr + 1;
	    vXMLTable(vCtr).TagName := 'G3-C-07-3';
	    vXMLTable(vCtr).TagValue := l_day;
	    vCtr := vCtr + 1;
*/
     l_day := to_char(fnd_date.canonical_to_date(l_hazards_join_date),'DD');
     l_month := to_char(fnd_date.canonical_to_date(l_hazards_join_date),'MM');
     l_year := to_char(fnd_date.canonical_to_date(l_hazards_join_date),'YYYY');
/* Cancelled as per the GOSI Report 3+4 enhancement.
        vXMLTable(vCtr).TagName := 'G3-C-08-1';
        vXMLTable(vCtr).TagValue := l_year;
	    vCtr := vCtr + 1;
        vXMLTable(vCtr).TagName := 'G3-C-08-2';
        vXMLTable(vCtr).TagValue := l_month;
	    vCtr := vCtr + 1;
        vXMLTable(vCtr).TagName := 'G3-C-08-3';
        vXMLTable(vCtr).TagValue := l_day;
	    vCtr := vCtr + 1;
*/
        l_fm_employee_monthly_cont := null;
        l_fm_employee_monthly_cont := to_char(l_employee_monthly_cont,lg_format_mask);
	vXMLTable(vCtr).TagName := 'G3-C-09-6';
        vXMLTable(vCtr).TagValue := substr(l_fm_employee_monthly_cont,length(l_fm_employee_monthly_cont)-1,1);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'G3-C-09-7';
        vXMLTable(vCtr).TagValue := substr(l_fm_employee_monthly_cont,length(l_fm_employee_monthly_cont),1);
	vCtr := vCtr + 1;
	If length(trunc(l_employee_monthly_cont)) = 3 then
        	vXMLTable(vCtr).TagName := 'G3-C-09-3';
        	vXMLTable(vCtr).TagValue := substr(l_employee_monthly_cont,1,1);
		vCtr := vCtr + 1;
		vXMLTable(vCtr).TagName := 'G3-C-09-4';
	        vXMLTable(vCtr).TagValue := substr(l_employee_monthly_cont,2,1);
		vCtr := vCtr + 1;
		vXMLTable(vCtr).TagName := 'G3-C-09-5';
	        vXMLTable(vCtr).TagValue := substr(l_employee_monthly_cont,3,1);
		vCtr := vCtr + 1;
	End If;
	If length(trunc(l_employee_monthly_cont)) = 4 then
		vXMLTable(vCtr).TagName := 'G3-C-09-5';
        	vXMLTable(vCtr).TagValue := substr(l_employee_monthly_cont,4,1);
		vCtr := vCtr + 1;
               vXMLTable(vCtr).TagName := 'G3-C-09-4';
                vXMLTable(vCtr).TagValue := substr(l_employee_monthly_cont,3,1);
                vCtr := vCtr + 1;
               vXMLTable(vCtr).TagName := 'G3-C-09-3';
                vXMLTable(vCtr).TagValue := substr(l_employee_monthly_cont,2,1);
                vCtr := vCtr + 1;
               vXMLTable(vCtr).TagName := 'G3-C-09-2';
                vXMLTable(vCtr).TagValue := substr(l_employee_monthly_cont,1,1);
                vCtr := vCtr + 1;
	end if;
	If length(trunc(l_employee_monthly_cont)) = 5 then
		vXMLTable(vCtr).TagName := 'G3-C-09-5';
        	vXMLTable(vCtr).TagValue := substr(l_employee_monthly_cont,5,1);
		vCtr := vCtr + 1;
               vXMLTable(vCtr).TagName := 'G3-C-09-4';
                vXMLTable(vCtr).TagValue := substr(l_employee_monthly_cont,4,1);
                vCtr := vCtr + 1;
               vXMLTable(vCtr).TagName := 'G3-C-09-3';
                vXMLTable(vCtr).TagValue := substr(l_employee_monthly_cont,3,1);
                vCtr := vCtr + 1;
               vXMLTable(vCtr).TagName := 'G3-C-09-2';
                vXMLTable(vCtr).TagValue := substr(l_employee_monthly_cont,2,1);
                vCtr := vCtr + 1;
               vXMLTable(vCtr).TagName := 'G3-C-09-1';
                vXMLTable(vCtr).TagValue := substr(l_employee_monthly_cont,1,1);
                vCtr := vCtr + 1;
	end if;
     l_day := to_char(l_termination_date,'DD');
     l_month := to_char(l_termination_date,'MM');
     l_year := to_char(l_termination_date,'YYYY');
        vXMLTable(vCtr).TagName := 'G3-D-01-1';
	    vXMLTable(vCtr).TagValue := substr(to_char(l_termination_date,'DD-MM-YYYY'),7,1);
	    vCtr := vCtr + 1;
        vXMLTable(vCtr).TagName := 'G3-D-01-2';
	    vXMLTable(vCtr).TagValue := substr(to_char(l_termination_date,'DD-MM-YYYY'),8,1);
	    vCtr := vCtr + 1;
        vXMLTable(vCtr).TagName := 'G3-D-01-3';
	    vXMLTable(vCtr).TagValue := substr(to_char(l_termination_date,'DD-MM-YYYY'),9,1);
	    vCtr := vCtr + 1;
        vXMLTable(vCtr).TagName := 'G3-D-01-4';
	    vXMLTable(vCtr).TagValue := substr(to_char(l_termination_date,'DD-MM-YYYY'),10,1);
	    vCtr := vCtr + 1;
        vXMLTable(vCtr).TagName := 'G3-D-01-5';
	    vXMLTable(vCtr).TagValue := substr(to_char(l_termination_date,'DD-MM-YYYY'),4,1);
	    vCtr := vCtr + 1;
        vXMLTable(vCtr).TagName := 'G3-D-01-6';
	    vXMLTable(vCtr).TagValue := substr(to_char(l_termination_date,'DD-MM-YYYY'),5,1);
	    vCtr := vCtr + 1;
        vXMLTable(vCtr).TagName := 'G3-D-01-7';
	    vXMLTable(vCtr).TagValue := substr(to_char(l_termination_date,'DD-MM-YYYY'),1,1);
	    vCtr := vCtr + 1;
        vXMLTable(vCtr).TagName := 'G3-D-01-8';
	    vXMLTable(vCtr).TagValue := substr(to_char(l_termination_date,'DD-MM-YYYY'),2,1);
	    vCtr := vCtr + 1;
	    vXMLTable(vCtr).TagName := 'G3-D-02';
	    vXMLTable(vCtr).TagValue := hr_general.decode_lookup('LEAV_REAS',l_termination_reason);
	    vCtr := vCtr + 1;
	    vXMLTable(vCtr).TagName := 'dummy';
	    vXMLTable(vCtr).TagValue := ' ';
	    vCtr := vCtr + 1;
	/*Write the values to xml file*/
end loop; --t_emp
end if;
end loop; --(t_form_type);
	WritetoCLOB ( l_xfdf_blob );
	hr_utility.set_location('Finished Procedure Workers movement Report ',90);
	/*Write the values to xml file*/
/*
	EXCEPTION
	        WHEN utl_file.invalid_path then
	                hr_utility.set_message(8301, 'GHR_38830_INVALID_UTL_FILE_PATH');
	                fnd_file.put_line(fnd_file.log,HR_UTILITY.get_message);
	                hr_utility.raise_error;
	--
	    WHEN utl_file.invalid_mode then
	        hr_utility.set_message(8301, 'GHR_38831_INVALID_FILE_MODE');
	        fnd_file.put_line(fnd_file.log,HR_UTILITY.get_message);
	                hr_utility.raise_error;
	--
	    WHEN utl_file.invalid_filehandle then
	        hr_utility.set_message(8301, 'GHR_38832_INVALID_FILE_HANDLE');
	        fnd_file.put_line(fnd_file.log,HR_UTILITY.get_message);
	                hr_utility.raise_error;
	--
	    WHEN utl_file.invalid_operation then
	        hr_utility.set_message(8301, 'GHR_38833_INVALID_OPER');
	        fnd_file.put_line(fnd_file.log,HR_UTILITY.get_message);
	                hr_utility.raise_error;
	--
	    WHEN utl_file.read_error then
	        hr_utility.set_message(8301, 'GHR_38834_FILE_READ_ERROR');
	        fnd_file.put_line(fnd_file.log,HR_UTILITY.get_message);
	                hr_utility.raise_error;
	--
	    WHEN others THEN
	       hr_utility.set_message(800,'FFU10_GENERAL_ORACLE_ERROR');
	       hr_utility.set_message_token('2',substr(sqlerrm,1,200));
	       fnd_file.put_line(fnd_file.log,HR_UTILITY.get_message);
	           hr_utility.raise_error;
*/
	end populate_workers_movement;
	/*End of SA Worker Movement Report*/
----------------------------------------------
PROCEDURE WritetoCLOB (
        p_xfdf_blob out nocopy blob)
IS
l_xfdf_string clob;
l_str1 varchar2(1000);
l_str2 varchar2(20);
l_str3 varchar2(20);
l_str4 varchar2(20);
l_str5 varchar2(20);
l_str6 varchar2(30);
l_str7 varchar2(1000);
l_str8 varchar2(240);
l_str9 varchar2(240);
begin
hr_utility.set_location('Entered Procedure Write to clob ',100);
	l_str1 := '<?xml version="1.0" encoding="UTF-8"?>
	       		 <xfdf xmlns="http://ns.adobe.com/xfdf/" xml:space="preserve">
       			 <fields> ' ;
	l_str2 := '<field name="';
	l_str3 := '">';
	l_str4 := '<value>' ;
	l_str5 := '</value> </field>' ;
	l_str6 := '</fields> </xfdf>';
	l_str7 := '<?xml version="1.0" encoding="UTF-8"?>
		       		 <xfdf xmlns="http://ns.adobe.com/xfdf/" xml:space="preserve">
       			 <fields>
       			 </fields> </xfdf>';
	dbms_lob.createtemporary(l_xfdf_string,FALSE,DBMS_LOB.CALL);
	dbms_lob.open(l_xfdf_string,dbms_lob.lob_readwrite);
	if vXMLTable.count > 0 then
		dbms_lob.writeAppend( l_xfdf_string, length(l_str1), l_str1 );
        	FOR ctr_table IN vXMLTable.FIRST .. vXMLTable.LAST LOOP
        		l_str8 := vXMLTable(ctr_table).TagName;
        		l_str9 := vXMLTable(ctr_table).TagValue;
        		if (l_str9 is not null) then
			        /* Added CDATA to handle special characters Bug No:8741752 */
	                        l_str9 := '<![CDATA['||l_str9||']]>';
				dbms_lob.writeAppend( l_xfdf_string, length(l_str2), l_str2 );
				dbms_lob.writeAppend( l_xfdf_string, length(l_str8),l_str8);
				dbms_lob.writeAppend( l_xfdf_string, length(l_str3), l_str3 );
				dbms_lob.writeAppend( l_xfdf_string, length(l_str4), l_str4 );
				dbms_lob.writeAppend( l_xfdf_string, length(l_str9), l_str9);
				dbms_lob.writeAppend( l_xfdf_string, length(l_str5), l_str5 );
			elsif (l_str9 is null and l_str8 is not null) then
				dbms_lob.writeAppend(l_xfdf_string,length(l_str2),l_str2);
				dbms_lob.writeAppend(l_xfdf_string,length(l_str8),l_str8);
				dbms_lob.writeAppend(l_xfdf_string,length(l_str3),l_str3);
				dbms_lob.writeAppend(l_xfdf_string,length(l_str4),l_str4);
				dbms_lob.writeAppend(l_xfdf_string,length(l_str5),l_str5);
			else
			null;
			end if;
		END LOOP;
		dbms_lob.writeAppend( l_xfdf_string, length(l_str6), l_str6 );
	else
		dbms_lob.writeAppend( l_xfdf_string, length(l_str7), l_str7 );
	end if;
	DBMS_LOB.CREATETEMPORARY(p_xfdf_blob,TRUE);
	clob_to_blob(l_xfdf_string,p_xfdf_blob);
	hr_utility.set_location('Finished Procedure Write to CLOB ,Before clob to blob ',110);
	--return p_xfdf_blob;
	EXCEPTION
		WHEN OTHERS then
	        HR_UTILITY.TRACE('sqleerm ' || SQLERRM);
	        HR_UTILITY.RAISE_ERROR;
END WritetoCLOB;
----------------------------------------------------------------
Procedure  clob_to_blob(p_clob clob,
                          p_blob IN OUT NOCOPY Blob)
  is
    l_length_clob number;
    l_offset pls_integer;
    l_varchar_buffer varchar2(32767);
    l_raw_buffer raw(32767);
    l_buffer_len number:= 20000;
    l_chunk_len number;
    l_blob blob;
    g_nls_db_char varchar2(60);
    l_raw_buffer_len pls_integer;
    l_blob_offset    pls_integer := 1;
  begin
  	hr_utility.set_location('Entered Procedure clob to blob',120);
	select userenv('LANGUAGE') into g_nls_db_char from dual;
  	l_length_clob := dbms_lob.getlength(p_clob);
	l_offset := 1;
	while l_length_clob > 0 loop
		hr_utility.trace('l_length_clob '|| l_length_clob);
		if l_length_clob < l_buffer_len then
			l_chunk_len := l_length_clob;
		else
                        l_chunk_len := l_buffer_len;
		end if;
		DBMS_LOB.READ(p_clob,l_chunk_len,l_offset,l_varchar_buffer);
        	--l_raw_buffer := utl_raw.cast_to_raw(l_varchar_buffer);
                l_raw_buffer := utl_raw.convert(utl_raw.cast_to_raw(l_varchar_buffer),'American_America.UTF8',g_nls_db_char);
                l_raw_buffer_len := utl_raw.length(utl_raw.convert(utl_raw.cast_to_raw(l_varchar_buffer),'American_America.UTF8',g_nls_db_char));
        	hr_utility.trace('l_varchar_buffer '|| l_varchar_buffer);
                --dbms_lob.write(p_blob,l_chunk_len, l_offset, l_raw_buffer);
                dbms_lob.write(p_blob,l_raw_buffer_len, l_blob_offset, l_raw_buffer);
            	l_blob_offset := l_blob_offset + l_raw_buffer_len;
            	l_offset := l_offset + l_chunk_len;
	        l_length_clob := l_length_clob - l_chunk_len;
                hr_utility.trace('l_length_blob '|| dbms_lob.getlength(p_blob));
	end loop;
	hr_utility.set_location('Finished Procedure clob to blob ',130);
  end;
------------------------------------------------------------------
Procedure fetch_pdf_blob
	(p_report in varchar2,
	 p_pdf_blob OUT NOCOPY blob)
IS
	BEGIN
		IF	 (p_report='Form 3') THEN
			Select file_data
			Into p_pdf_blob
			From fnd_lobs
			Where file_id = (select max(file_id) from per_gb_xdo_templates where file_name like '%PAY_G32003_ar_SA.pdf');
		ELSIF	(p_report = 'Form 4') THEN
			Select file_data
			Into p_pdf_blob
			From fnd_lobs
			Where file_id = (select max(file_id) from per_gb_xdo_templates where file_name like '%PAY_G42003_ar_SA.pdf');
		ELSIF	(p_report ='Form 5') THEN
			Select file_data
			Into p_pdf_blob
			From fnd_lobs
			Where file_id = (select max(file_id) from per_gb_xdo_templates where file_name like '%PAY_G52003_ar_SA.pdf');
		END IF;
	EXCEPTION
        	when no_data_found then
              	null;
END fetch_pdf_blob;
-----------------------------------------------------------------
END PAY_SA_GOSI_REPORTS;

/
