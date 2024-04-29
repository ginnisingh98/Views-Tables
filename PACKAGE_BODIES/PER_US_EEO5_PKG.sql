--------------------------------------------------------
--  DDL for Package Body PER_US_EEO5_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_US_EEO5_PKG" AS
/* $Header: peuseeo5.pkb 120.6.12000000.3 2007/07/18 11:46:39 rpasumar noship $ */

g_debug_flag           VARCHAR2(1) := 'Y';
g_concurrent_flag      VARCHAR2(1) := 'Y';
g_salary_range         VARCHAR2(30);
g_start_salary         NUMBER := 0;
g_end_salary           NUMBER := 0;
g_lookup_code          NUMBER := 1;
g_meaning              VARCHAR2(80);
g_debug                BOOLEAN;

/****************************************************************************
  Name        : HR_UTILITY_TRACE
  Description : This function prints debug messages during diagnostics mode.
*****************************************************************************/
PROCEDURE hr_utility_trace(trc_data VARCHAR2) IS
BEGIN
    IF g_debug THEN
        hr_utility.trace(trc_data);
    END IF;
END hr_utility_trace;

/*****************************************************************************
 Name      : convert_into_xml
 Purpose   : function to convert the data into an XML String
*****************************************************************************/
FUNCTION convert_into_xml( p_name  IN VARCHAR2,
                           p_value IN VARCHAR2,
                           p_type  IN char)
RETURN VARCHAR2 IS
  l_convert_data VARCHAR2(300);
BEGIN
  IF p_type = 'D' THEN
   l_convert_data := '<'||p_name||'>'||p_value||'</'||p_name||'>';
  ELSE
     l_convert_data := '<'||p_name||'>';
  END IF;
  RETURN(l_convert_data);
END convert_into_xml;

/*****************************************************************************
 Name      : get_job_category_meaning
 Purpose   : function to fetch the job category meaning based on lookup_code
*****************************************************************************/
FUNCTION get_job_category_meaning( p_lookup_code IN NUMBER)
RETURN VARCHAR2 IS
BEGIN
IF p_lookup_code = 1 THEN
   RETURN '1. Officials, Administrators, Managers';
ELSIF p_lookup_code = 2 THEN
   RETURN '2. Principals';
ELSIF p_lookup_code = 3 THEN
   RETURN '3. Assistant Principal, Teaching';
ELSIF p_lookup_code = 4 THEN
   RETURN '4. Assistant Principals, Non teaching';
ELSIF p_lookup_code = 5 THEN
   RETURN '5. Elementary Classroom Teachers';
ELSIF p_lookup_code = 6 THEN
   RETURN '6. Secondary classroom Teachers';
ELSIF p_lookup_code = 7 THEN
   RETURN '7. Other Classroom Teachers';
ELSIF p_lookup_code = 8 THEN
   RETURN '8. Guidance';
ELSIF p_lookup_code = 9 THEN
   RETURN '9. Psychological';
ELSIF p_lookup_code = 10 THEN
   RETURN '10. Librarians /Audio Visual Staff';
ELSIF p_lookup_code = 11 THEN
   RETURN '11. Consultants &#38; Supervisors of Instruction';
ELSIF p_lookup_code = 12 THEN
   RETURN '12. Other Professional Staff';
ELSIF p_lookup_code = 13 THEN
   RETURN '13. Teachers Aids';
ELSIF p_lookup_code = 14 THEN
   RETURN '14. Technicians';
ELSIF p_lookup_code = 15 THEN
   RETURN '15. Clerical/Secretarial Staff';
ELSIF p_lookup_code = 16 THEN
   RETURN '16. Service Workers';
ELSIF p_lookup_code = 17 THEN
   RETURN '17. Skilled Crafts';
ELSIF p_lookup_code = 18 THEN
   RETURN '18. Laborers, Unskilled';
ELSIF p_lookup_code = 19 THEN
   RETURN '19. TOTAL (1-18)';
ELSIF p_lookup_code = 20 THEN
   RETURN '20. Professional Instructional';
ELSIF p_lookup_code = 21 THEN
   RETURN '21. All Other';
ELSIF p_lookup_code = 22 THEN
   RETURN '22. TOTAL (20-21)';
ELSIF p_lookup_code = 23 THEN
   RETURN '23. Officials, Administrators, Managers';
ELSIF p_lookup_code = 24 THEN
   RETURN '24. Principals/Asst. Principals';
ELSIF p_lookup_code = 25 THEN
   RETURN '25. Classroom Teachers';
ELSIF p_lookup_code = 26 THEN
   RETURN '26. Other Professional Staff';
ELSIF p_lookup_code = 27 THEN
   RETURN '27. Nonprofessional Staff';
ELSIF p_lookup_code = 28 THEN
   RETURN '28. TOTAL (23-27)';
ELSE
   RETURN NULL;
END IF;
END get_job_category_meaning;

/*****************************************************************************
 Name      : get_sum
 Purpose   : function to sum of the employees.
*****************************************************************************/
FUNCTION get_sum(p_no_cons_wmale_emps   IN NUMBER
                ,p_no_cons_bmale_emps   IN NUMBER
		,p_no_cons_hmale_emps   IN NUMBER
		,p_no_cons_amale_emps   IN NUMBER
		,p_no_cons_imale_emps   IN NUMBER
		,p_no_cons_wfemale_emps IN NUMBER
		,p_no_cons_bfemale_emps IN NUMBER
		,p_no_cons_hfemale_emps IN NUMBER
		,p_no_cons_afemale_emps IN NUMBER
		,p_no_cons_ifemale_emps IN NUMBER) RETURN NUMBER IS
BEGIN
  RETURN  NVL(p_no_cons_wmale_emps,0)
        + NVL(p_no_cons_bmale_emps,0)
	+ NVL(p_no_cons_hmale_emps,0)
	+ NVL(p_no_cons_amale_emps,0)
	+ NVL(p_no_cons_imale_emps,0)
	+ NVL(p_no_cons_wfemale_emps,0)
	+ NVL(p_no_cons_bfemale_emps,0)
	+ NVL(p_no_cons_hfemale_emps,0)
	+ NVL(p_no_cons_afemale_emps,0)
	+ NVL(p_no_cons_ifemale_emps,0);
END get_sum;

/*****************************************************************************
 Name      : write_to_concurrent_out
 Purpose   : writes to concurrent ouput.
*****************************************************************************/
PROCEDURE write_to_concurrent_out (p_text VARCHAR2) IS
BEGIN
  -- Write to the concurrent request log
  fnd_file.put_line(fnd_file.LOG, p_text);
  -- Write to the concurrent request out
  fnd_file.put_line(fnd_file.OUTPUT, p_text);
--  hr_utility_trace(p_text);
END write_to_concurrent_out;

/*****************************************************************************
 Name      : generate_xml_data
 Purpose   : Procedure is called from concurrent program EEO5 Reporting.
 Structure :
 <PQHEEO5>
-------------------------------------------------------------------------------
   <LIST_G_JURISDICTION_DETAIL>
     <G_JURISDICTION_DETAIL>
       <CITY_STATE_ZIP>San Francisco,San Francisco,CA,94100-1234</CITY_STATE_ZIP>
       <BUSINESS_NAME>MM_RT BG2</BUSINESS_NAME>
       <ADDRESS>314 Maple Street Suite 1000</ADDRESS>
     </G_JURISDICTION_DETAIL>
   </LIST_G_JURISDICTION_DETAIL>
------------------------------------------------------------------------------
   <LIST_G_CERT_OFFICER_NAME>
    <G_CERT_OFFICER_NAME>
     <SYSTEM_DISTRICT>DISTRICT</SYSTEM_DISTRICT>
     <TYPE_REPORT>DISTRICT SUMMARY</TYPE_REPORT>
     <CONTROL_NUMBER>1234567890</CONTROL_NUMBER>
     <CERT_OFFICER_NAME></CERT_OFFICER_NAME>
     <CERT_OFFICIAL_TITLE></CERT_OFFICIAL_TITLE>
     <CONTACT_TELEPHONE></CONTACT_TELEPHONE>
    </G_CERT_OFFICER_NAME>
  </LIST_G_CERT_OFFICER_NAME>
------------------------------------------------------------------------------
<LIST_G_EMPLOYMENT_CATEGORY>
  <G_EMPLOYMENT_CATEGORY>
  <EMPLOYEE_SALARY_EMPLOYMENT_CAT>A. FULL TIME STAFF</EMPLOYEE_SALARY_EMPLOYMENT_CAT>
  <LIST_G_JOB_CATEGORIES>
   <G_JOB_CATEGORIES>
  <JOB_CATEGORY_MEANING>2.PRIN</JOB_CATEGORY_MEANING>
  <LIST_G_JOB_INFORMATION>
  <G_JOB_INFORMATION>
  <CONS_TOTAL_CATEGORY_EMPS>2</CONS_TOTAL_CATEGORY_EMPS>
  <NO_CONS_WMALE_EMPS>1</NO_CONS_WMALE_EMPS>
  <NO_CONS_BMALE_EMPS>0</NO_CONS_BMALE_EMPS>
  <NO_CONS_HMALE_EMPS>0</NO_CONS_HMALE_EMPS>
  <NO_CONS_AMALE_EMPS>0</NO_CONS_AMALE_EMPS>
  <NO_CONS_IMALE_EMPS>0</NO_CONS_IMALE_EMPS>
  <NO_CONS_WFEMALE_EMPS>1</NO_CONS_WFEMALE_EMPS>
  <NO_CONS_BFEMALE_EMPS>0</NO_CONS_BFEMALE_EMPS>
  <NO_CONS_HFEMALE_EMPS>0</NO_CONS_HFEMALE_EMPS>
  <NO_CONS_AFEMALE_EMPS>0</NO_CONS_AFEMALE_EMPS>
  <NO_CONS_IFEMALE_EMPS>0</NO_CONS_IFEMALE_EMPS>
  </G_JOB_INFORMATION>
  </LIST_G_JOB_INFORMATION>
  </G_JOB_CATEGORIES>
  </LIST_G_JOB_CATEGORIES>
  </G_EMPLOYMENT_CATEGORY>
  <G_EMPLOYMENT_CATEGORY>
  <EMPLOYEE_SALARY_EMPLOYMENT_CAT>B. PART-TIME STAFF</EMPLOYEE_SALARY_EMPLOYMENT_CAT>
</LIST_G_EMPLOYMENT_CATEGORY>
------------------------------------------------------------------------------
  <CF_NO_OF_ANNEXES>3</CF_NO_OF_ANNEXES>
  <CP_REPORT_DATE>30-SEP-05</CP_REPORT_DATE>
  <CP_NO_OF_SCHOOLS>6</CP_NO_OF_SCHOOLS>
  <CP_FR>'FR'</CP_FR>
  <CP_FT>'FT'</CP_FT>
  <CP_PR>'PR'</CP_PR>
  <CP_PT>'PT'</CP_PT>
 </PQHEEO5>
*****************************************************************************/
PROCEDURE generate_xml_data(errbuf                   OUT NOCOPY VARCHAR2
                           ,retcode                  OUT NOCOPY NUMBER
                           ,p_reporting_year         IN NUMBER
                           ,p_type_agency            IN VARCHAR2
                           ,p_total_enrollments      IN NUMBER
                           ,p_business_group_id      IN NUMBER
                           ) IS

  l_xml_string     VARCHAR2(32767);

--Step 1
  CURSOR csr_bg_details(p_business_group_id IN NUMBER) IS
  SELECT name  bg_name,
         location_id
   FROM	 hr_all_organization_units
  WHERE  business_group_id = p_business_group_id
    AND  organization_id = p_business_group_id;

  l_bg_name    VARCHAR2(200);
  l_location_id NUMBER;

  CURSOR csr_bg_location(l_location_id IN NUMBER) IS
  SELECT address_line_1||' '||address_line_2||' '||address_line_3  bg_address,
         town_or_city  city,
	 region_1      county,
	 region_2      state,
	 postal_code   zip_code
   FROM	 hr_locations
  WHERE  location_id = l_location_id;

  l_bg_address    VARCHAR2(2000);
  l_bg_city       VARCHAR2(2000);
  l_bg_county     VARCHAR2(2000);
  l_bg_state      VARCHAR2(2000);
  l_bg_zip_code   VARCHAR2(2000);


  --Step 2
  CURSOR csr_cert_officer_details(p_business_group_id IN NUMBER) IS
  SELECT org_information1	cert_officer_name,
         org_information2	cert_official_title,
         org_information10	contact_telephone,
         org_information12	control_number,
         org_information13	system_district,
         org_information13||' SUMMARY'  type_report
   FROM	 hr_organization_information
  WHERE	 org_information_context = 'EEO_REPORT'
    AND	 organization_id = p_business_group_id;

--Modified for bug 5437066
  l_fr   VARCHAR2(2000);
  l_ft   VARCHAR2(2000);
  l_pr   VARCHAR2(2000);
  l_pt   VARCHAR2(2000);

  --Step 3
  CURSOR csr_full_time_details(p_business_group_id IN NUMBER
                              ,p_fr                IN VARCHAR2
                              ,p_ft                IN VARCHAR2
                              ,p_pr                IN VARCHAR2
                              ,p_pt                IN VARCHAR2
                              ,p_report_date       IN DATE
                              ,p_report_year       IN NUMBER) IS
  SELECT  DECODE(pqh_employment_category.identify_empl_category(ass.employment_category,p_fr,p_ft,p_pr,p_pt),
          	'FR', 'A. FULL-TIME STAFF') employment_category,
          DECODE(pqh_employment_category.identify_empl_category(ass.employment_category,p_fr,p_ft,p_pr,p_pt),
     	        'FR',LPAD(hl.lookup_code,2,' ')||'.'||hl.meaning)          job_category_name,
       COUNT(DECODE(peo.per_information1,'1',1,'2',1,'3',1,'4',1,'5',1,'6',1,'7',1,NULL))  cons_total_category_emps,
       COUNT(DECODE(peo.per_information1,'1',DECODE(peo.sex,'M',1,NULL),NULL)) no_cons_wmale_emps,
       COUNT(DECODE(peo.per_information1,'2',DECODE(peo.sex,'M',1,NULL),NULL)) no_cons_bmale_emps,
       COUNT(DECODE(peo.per_information1,'3',DECODE(peo.sex,'M',1,NULL),NULL)) no_cons_hmale_emps,
       COUNT(DECODE(peo.per_information1,'4',DECODE(peo.sex,'M',1,NULL),'5',DECODE(peo.sex,'M',1,NULL),NULL)) no_cons_amale_emps,
       COUNT(DECODE(peo.per_information1,'6',DECODE(peo.sex,'M',1,NULL),'7',DECODE(peo.sex,'M',1,NULL),NULL)) no_cons_imale_emps,
       COUNT(DECODE(peo.per_information1,'1',DECODE(peo.sex,'F',1,NULL),NULL)) no_cons_wfemale_emps,
       COUNT(DECODE(peo.per_information1,'2',DECODE(peo.sex,'F',1,NULL),NULL)) no_cons_bfemale_emps,
       COUNT(DECODE(peo.per_information1,'3',DECODE(peo.sex,'F',1,NULL),NULL)) no_cons_hfemale_emps,
       COUNT(DECODE(peo.per_information1,'4',DECODE(peo.sex,'F',1,NULL),'5',DECODE(peo.sex,'F',1,NULL),NULL)) no_cons_afemale_emps,
       COUNT(DECODE(peo.per_information1,'6',DECODE(peo.sex,'F',1,NULL),'7',DECODE(peo.sex,'F',1,NULL),NULL)) no_cons_ifemale_emps
FROM   per_all_people_f  peo,
       per_all_assignments_f  ass,
       per_assignment_status_types     ast,
       per_jobs                        job,
       hr_lookups                      hl
WHERE  peo.person_id = ass.person_id
AND    peo.current_employee_flag = 'Y'
AND    hl.lookup_code = job.job_information1
AND    pqh_employment_category.identify_empl_category(ass.employment_category,p_fr,p_ft,p_pr,p_pt) IN ('FR')
AND    hl.lookup_type = 'US_EEO5_JOB_CATEGORIES'
AND    job.job_information_category = 'US'
AND    p_report_date BETWEEN peo.effective_start_date AND peo.effective_end_date
AND    p_report_date BETWEEN ass.effective_start_date AND ass.effective_end_date
AND    ass.primary_flag	= 'Y'
AND    ass.assignment_status_type_id = ast.assignment_status_type_id
AND    ast.per_system_status  <> 'TERM_ASSIGN'
AND    ass.job_id = job.job_id
AND    ass.assignment_type = 'E'
AND    ass.organization_id  IN (
     	SELECT organization_id
	FROM   hr_all_organization_units
     	WHERE  business_group_id = p_business_group_id)
GROUP BY
DECODE(pqh_employment_category.identify_empl_category(ass.employment_category,p_fr,p_ft,p_pr,p_pt),
          'FR', 'A. FULL-TIME STAFF') ,
DECODE(pqh_employment_category.identify_empl_category(ass.employment_category,p_fr,p_ft,p_pr,p_pt),
     'FR',LPAD(hl.lookup_code,2,' ')||'.'||hl.meaning)
ORDER BY 1,2;


--Step 4
CURSOR csr_part_time_details(p_business_group_id IN NUMBER
			    ,p_fr                IN VARCHAR2
			    ,p_ft                IN VARCHAR2
			    ,p_pr                IN VARCHAR2
			    ,p_pt                IN VARCHAR2
			    ,p_report_date       IN DATE
			    ,p_report_year       IN NUMBER) IS
  SELECT  DECODE(pqh_employment_category.identify_empl_category(ass.employment_category,p_fr,p_ft,p_pr,p_pt),
          	'FT','B. PART-TIME STAFF',
		'PR','B. PART-TIME STAFF',
		'PT','B. PART-TIME STAFF') employment_category,
          DECODE(pqh_employment_category.identify_empl_category(ass.employment_category,p_fr,p_ft,p_pr,p_pt),
     	        'PR',DECODE(job.job_information1,
                            '2','20.PROF. INSTR.',
                            '3','20.PROF. INSTR.',
                            '4','20.PROF. INSTR.',
                            '5','20.PROF. INSTR.',
                            '6','20.PROF. INSTR.',
                            '7','20.PROF. INSTR.',
                            '8','20.PROF. INSTR.',
                            '9','20.PROF. INSTR.',
                            '10','20.PROF. INSTR.',
                            '11','20.PROF. INSTR.',
                            '12','20.PROF. INSTR.',
                            '21.ALL OTHER'))          job_category_name,
       COUNT(DECODE(peo.per_information1,'1',1,'2',1,'3',1,'4',1,'5',1,'6',1,'7',1,NULL)) cons_total_category_emps,
       COUNT(DECODE(peo.per_information1,'1',DECODE(peo.sex,'M',1,NULL),NULL)) no_cons_wmale_emps,
       COUNT(DECODE(peo.per_information1,'2',DECODE(peo.sex,'M',1,NULL),NULL)) no_cons_bmale_emps,
       COUNT(DECODE(peo.per_information1,'3',DECODE(peo.sex,'M',1,NULL),NULL)) no_cons_hmale_emps,
       COUNT(DECODE(peo.per_information1,'4',DECODE(peo.sex,'M',1,NULL),'5',DECODE(peo.sex,'M',1,NULL),NULL)) no_cons_amale_emps,
       COUNT(DECODE(peo.per_information1,'6',DECODE(peo.sex,'M',1,NULL),'7',DECODE(peo.sex,'M',1,NULL),NULL)) no_cons_imale_emps,
       COUNT(DECODE(peo.per_information1,'1',DECODE(peo.sex,'F',1,NULL),NULL)) no_cons_wfemale_emps,
       COUNT(DECODE(peo.per_information1,'2',DECODE(peo.sex,'F',1,NULL),NULL)) no_cons_bfemale_emps,
       COUNT(DECODE(peo.per_information1,'3',DECODE(peo.sex,'F',1,NULL),NULL)) no_cons_hfemale_emps,
       COUNT(DECODE(peo.per_information1,'4',DECODE(peo.sex,'F',1,NULL),'5',DECODE(peo.sex,'F',1,NULL),NULL)) no_cons_afemale_emps,
       COUNT(DECODE(peo.per_information1,'6',DECODE(peo.sex,'F',1,NULL),'7',DECODE(peo.sex,'F',1,NULL),NULL)) no_cons_ifemale_emps
FROM   per_all_people_f  peo,
       per_all_assignments_f  ass,
       per_assignment_status_types     ast,
       per_jobs                        job,
       hr_lookups                      hl
WHERE  peo.person_id = ass.person_id
AND    peo.current_employee_flag = 'Y'
AND    hl.lookup_code = job.job_information1
AND    pqh_employment_category.identify_empl_category(ass.employment_category,p_fr,p_ft,p_pr,p_pt) IN ('PR')
AND    hl.lookup_type = 'US_EEO5_JOB_CATEGORIES'
AND    job.job_information_category = 'US'
AND    p_report_date BETWEEN peo.effective_start_date AND peo.effective_end_date
AND    p_report_date BETWEEN ass.effective_start_date AND ass.effective_end_date
AND    ass.primary_flag	= 'Y'
AND    ass.assignment_status_type_id = ast.assignment_status_type_id
AND    ast.per_system_status  <> 'TERM_ASSIGN'
AND    ass.job_id = job.job_id
AND    ass.assignment_type = 'E'
AND    ass.organization_id  IN (
     	SELECT organization_id
	FROM   hr_all_organization_units
     	WHERE  business_group_id = p_business_group_id)
GROUP BY
DECODE(pqh_employment_category.identify_empl_category(ass.employment_category,p_fr,p_ft,p_pr,p_pt),
      'FT','B. PART-TIME STAFF',
      'PR','B. PART-TIME STAFF',
      'PT','B. PART-TIME STAFF') ,
DECODE(pqh_employment_category.identify_empl_category(ass.employment_category,p_fr,p_ft,p_pr,p_pt),
      'PR', DECODE(job.job_information1,
          	'2','20.PROF. INSTR.',          '3','20.PROF. INSTR.',
          	'4','20.PROF. INSTR.',          '5','20.PROF. INSTR.',
          	'6','20.PROF. INSTR.',          '7','20.PROF. INSTR.',
          	'8','20.PROF. INSTR.',          '9','20.PROF. INSTR.',
         	'10','20.PROF. INSTR.',         '11','20.PROF. INSTR.',
          	'12','20.PROF. INSTR.',         '21.ALL OTHER'))
ORDER BY 1,2;


--Step 5
CURSOR csr_new_hires_details(p_business_group_id IN NUMBER
			    ,p_fr                IN VARCHAR2
			    ,p_ft                IN VARCHAR2
			    ,p_pr                IN VARCHAR2
			    ,p_pt                IN VARCHAR2
			    ,p_report_date       IN DATE
			    ,p_report_year       IN NUMBER) IS
SELECT	'C. NEW HIRES (JULY THRU SEPT. '||p_report_year||')'  employment_category,
         DECODE(job.job_information1,
               '1','23.0/A/M',         '2','24.PRIN/ASST.PR',
               '3','24.PRIN/ASST.PR',  '4','24.PRIN/ASST.PR',
               '5','25.CLSRM. TCHRS',  '6','25.CLSRM. TCHRS',
               '7','25.CLSRM. TCHRS',  '8','26.OTHER PROF.',
               '9','26.OTHER PROF.',   '10','26.OTHER PROF.',
               '11','26.OTHER PROF.',  '12','26.OTHER PROF.',
               '13','27.NONPROF.',     '14','27.NONPROF.',
               '15','27.NONPROF.',     '16','27.NONPROF.',
               '17','27.NONPROF.',     '18','27.NONPROF.')  job_category_name,
      COUNT(DECODE(peo.per_information1,'1',1,'2',1,'3',1,'4',1,'5',1,'6',1,'7',1,NULL)) cons_total_category_emps,
      COUNT(DECODE(peo.per_information1,'1',DECODE(peo.sex,'M',1,NULL),NULL)) no_cons_wmale_emps,
      COUNT(DECODE(peo.per_information1,'2',DECODE(peo.sex,'M',1,NULL),NULL)) no_cons_bmale_emps,
      COUNT(DECODE(peo.per_information1,'3',DECODE(peo.sex,'M',1,NULL),NULL)) no_cons_hmale_emps,
      COUNT(DECODE(peo.per_information1,'4',DECODE(peo.sex,'M',1,NULL),'5',DECODE(peo.sex,'M',1,NULL),NULL)) no_cons_amale_emps,
      COUNT(DECODE(peo.per_information1,'6',DECODE(peo.sex,'M',1,NULL),'7',DECODE(peo.sex,'M',1,NULL),NULL)) no_cons_imale_emps,
      COUNT(DECODE(peo.per_information1,'1',DECODE(peo.sex,'F',1,NULL),NULL)) no_cons_wfemale_emps,
      COUNT(DECODE(peo.per_information1,'2',DECODE(peo.sex,'F',1,NULL),NULL)) no_cons_bfemale_emps,
      COUNT(DECODE(peo.per_information1,'3',DECODE(peo.sex,'F',1,NULL),NULL)) no_cons_hfemale_emps,
      COUNT(DECODE(peo.per_information1,'4',DECODE(peo.sex,'F',1,NULL),'5',DECODE(peo.sex,'F',1,NULL),NULL)) no_cons_afemale_emps,
      COUNT(DECODE(peo.per_information1,'6',DECODE(peo.sex,'F',1,NULL),'7',DECODE(peo.sex,'F',1,NULL),NULL)) no_cons_ifemale_emps
FROM  per_all_people_f      peo,
      per_all_assignments_f ass,
      per_jobs              job,
      hr_lookups            hl
WHERE peo.person_id = ass.person_id
AND   peo.current_employee_flag  = 'Y'
AND   hl.lookup_code = job.job_information1
AND   hl.lookup_type = 'US_EEO5_JOB_CATEGORIES'
AND   job.job_information_category = 'US'
AND   ass.job_id  = job.job_id
AND   ass.assignment_type = 'E'
AND   (SELECT   date_start
       FROM      per_periods_of_service
       WHERE    period_of_service_id = ass.period_of_service_id)
       BETWEEN ADD_MONTHS(p_report_date,-3) +1  AND p_report_date
AND   ass.primary_flag	= 'Y'
AND   pqh_employment_category.identify_empl_category(ass.employment_category,p_fr,p_ft,p_pr,p_pt) = 'FR'	-- Only full-time regular no temporaries
AND   ass.organization_id  IN (
          	SELECT 	organization_id
          	FROM	hr_all_organization_units
          	WHERE	business_group_id = p_business_group_id  )
GROUP BY DECODE(job.job_information1,
                '1','23.0/A/M',         '2','24.PRIN/ASST.PR',
                '3','24.PRIN/ASST.PR',  '4','24.PRIN/ASST.PR',
                '5','25.CLSRM. TCHRS',  '6','25.CLSRM. TCHRS',
                '7','25.CLSRM. TCHRS',  '8','26.OTHER PROF.',
                '9','26.OTHER PROF.',   '10','26.OTHER PROF.',
                '11','26.OTHER PROF.',  '12','26.OTHER PROF.',
                '13','27.NONPROF.',     '14','27.NONPROF.',
                '15','27.NONPROF.',     '16','27.NONPROF.',
                '17','27.NONPROF.',     '18','27.NONPROF.')
ORDER BY 1,2;

CURSOR csr_tmr_ft_details(p_business_group_id IN NUMBER
                                             ,p_fr                          IN VARCHAR2
			                     ,p_ft                          IN VARCHAR2
                  			     ,p_pr                        IN VARCHAR2
			                     ,p_pt                        IN VARCHAR2
                                             ,p_employment_category IN VARCHAR2
			                     ,p_job_category_name IN VARCHAR2
                                             ,p_report_date IN DATE
                                             ,p_report_year IN NUMBER) IS
  SELECT  count(decode(pei.pei_information5,'1',decode(peo.sex,'M',1,null),null)) no_tmraces_wmale_emps,
                  count(decode(pei.pei_information5,'2',decode(peo.sex,'M',1,null),null)) no_tmraces_bmale_emps,
                  count(decode(pei.pei_information5,'3',decode(peo.sex,'M',1,null),'9',decode(peo.sex,'M',1,null),null)) no_tmraces_hmale_emps,
                  count(decode(pei.pei_information5,'4',decode(peo.sex,'M',1,null),'5',decode(peo.sex,'M',1,null),null)) no_tmraces_amale_emps,
                  count(decode(pei.pei_information5,'6',decode(peo.sex,'M',1,null),null)) no_tmraces_imale_emps,
                  count(decode(pei.pei_information5,'1',decode(peo.sex,'F',1,null),null)) no_tmraces_wfemale_emps,
                  count(decode(pei.pei_information5,'2',decode(peo.sex,'F',1,null),null)) no_tmraces_bfemale_emps,
                  count(decode(pei.pei_information5,'3',decode(peo.sex,'F',1,null),'9',decode(peo.sex,'F',1,null),null)) no_tmraces_hfemale_emps,
                  count(decode(pei.pei_information5,'4',decode(peo.sex,'F',1,null),'5',decode(peo.sex,'F',1,null),null)) no_tmraces_afemale_emps,
                  count(decode(pei.pei_information5,'6',decode(peo.sex,'F',1,null),null)) no_tmraces_ifemale_emps
FROM   per_all_people_f  peo,
       per_all_assignments_f  ass,
       per_assignment_status_types     ast,
       per_jobs                        job,
       hr_lookups                      hl,
       per_people_extra_info pei
WHERE  peo.person_id = ass.person_id
AND    peo.per_information1 = '13'
AND    peo.person_id = pei.person_id(+)
AND    pei.information_type = 'PER_US_ADDL_ETHNIC_CAT'
AND    pei.pei_information5 is not null
AND    peo.current_employee_flag = 'Y'
AND    hl.lookup_code = job.job_information1
AND    hl.lookup_type = 'US_EEO5_JOB_CATEGORIES'
AND    job.job_information_category = 'US'
AND    p_report_date BETWEEN peo.effective_start_date AND peo.effective_end_date
AND    p_report_date BETWEEN ass.effective_start_date AND ass.effective_end_date
AND    ass.primary_flag	= 'Y'
AND    pqh_employment_category.identify_empl_category(ass.employment_category,p_fr,p_ft,p_pr,p_pt) IN ('FR')
AND    ass.assignment_status_type_id = ast.assignment_status_type_id
AND    ast.per_system_status  <> 'TERM_ASSIGN'
AND    ass.job_id = job.job_id
AND    ass.assignment_type = 'E'
AND    ass.organization_id  IN (
     	SELECT organization_id
	FROM   hr_all_organization_units
     	WHERE  business_group_id = p_business_group_id)
AND DECODE(pqh_employment_category.identify_empl_category(ass.employment_category,p_fr,p_ft,p_pr,p_pt),'FR', 'A. FULL-TIME STAFF') = p_employment_category
AND DECODE(pqh_employment_category.identify_empl_category(ass.employment_category,p_fr,p_ft,p_pr,p_pt),'FR',LPAD(hl.lookup_code,2,' ')||'.'||hl.meaning)  = p_job_category_name;



--Step 4
CURSOR csr_tmr_pt_details(p_business_group_id        IN NUMBER
                                              ,p_fr                                IN VARCHAR2
			                      ,p_ft                                IN VARCHAR2
                  			      ,p_pr                               IN VARCHAR2
			                      ,p_pt                               IN VARCHAR2
			                      ,p_employment_category IN VARCHAR2
			                      ,p_job_category_name    IN VARCHAR2
			                      ,p_report_date                IN DATE
			                      ,p_report_year                IN NUMBER) IS
  SELECT  count(decode(pei.pei_information5,'1',decode(peo.sex,'M',1,null),null)) no_tmraces_wmale_emps,
                  count(decode(pei.pei_information5,'2',decode(peo.sex,'M',1,null),null)) no_tmraces_bmale_emps,
                  count(decode(pei.pei_information5,'3',decode(peo.sex,'M',1,null),'9',decode(peo.sex,'M',1,null),null)) no_tmraces_hmale_emps,
                  count(decode(pei.pei_information5,'4',decode(peo.sex,'M',1,null),'5',decode(peo.sex,'M',1,null),null)) no_tmraces_amale_emps,
                  count(decode(pei.pei_information5,'6',decode(peo.sex,'M',1,null),null)) no_tmraces_imale_emps,
                  count(decode(pei.pei_information5,'1',decode(peo.sex,'F',1,null),null)) no_tmraces_wfemale_emps,
                  count(decode(pei.pei_information5,'2',decode(peo.sex,'F',1,null),null)) no_tmraces_bfemale_emps,
                  count(decode(pei.pei_information5,'3',decode(peo.sex,'F',1,null),'9',decode(peo.sex,'F',1,null),null)) no_tmraces_hfemale_emps,
                  count(decode(pei.pei_information5,'4',decode(peo.sex,'F',1,null),'5',decode(peo.sex,'F',1,null),null)) no_tmraces_afemale_emps,
                  count(decode(pei.pei_information5,'6',decode(peo.sex,'F',1,null),null)) no_tmraces_ifemale_emps
FROM   per_all_people_f  peo,
       per_all_assignments_f  ass,
       per_assignment_status_types     ast,
       per_jobs                        job,
       hr_lookups                      hl,
       per_people_extra_info pei
WHERE  peo.person_id = ass.person_id
AND    peo.per_information1 = '13'
AND    peo.person_id = pei.person_id(+)
AND    pei.information_type = 'PER_US_ADDL_ETHNIC_CAT'
AND    pei.pei_information5 is not null
AND    peo.current_employee_flag = 'Y'
AND    hl.lookup_code = job.job_information1
AND    hl.lookup_type = 'US_EEO5_JOB_CATEGORIES'
AND    job.job_information_category = 'US'
AND    p_report_date BETWEEN peo.effective_start_date AND peo.effective_end_date
AND    p_report_date BETWEEN ass.effective_start_date AND ass.effective_end_date
AND    ass.primary_flag	= 'Y'
AND    pqh_employment_category.identify_empl_category(ass.employment_category,p_fr,p_ft,p_pr,p_pt) IN ('PR')
AND    ass.assignment_status_type_id = ast.assignment_status_type_id
AND    ast.per_system_status  <> 'TERM_ASSIGN'
AND    ass.job_id = job.job_id
AND    ass.assignment_type = 'E'
AND    ass.organization_id  IN (
     	SELECT organization_id
	FROM   hr_all_organization_units
     	WHERE  business_group_id = p_business_group_id)
AND DECODE(pqh_employment_category.identify_empl_category(ass.employment_category,p_fr,p_ft,p_pr,p_pt),
          	'FT','B. PART-TIME STAFF',
		'PR','B. PART-TIME STAFF',
		'PT','B. PART-TIME STAFF') = p_employment_category
AND DECODE(pqh_employment_category.identify_empl_category(ass.employment_category,p_fr,p_ft,p_pr,p_pt),
     	        'PR',DECODE(job.job_information1,
                            '2','20.PROF. INSTR.',
                            '3','20.PROF. INSTR.',
                            '4','20.PROF. INSTR.',
                            '5','20.PROF. INSTR.',
                            '6','20.PROF. INSTR.',
                            '7','20.PROF. INSTR.',
                            '8','20.PROF. INSTR.',
                            '9','20.PROF. INSTR.',
                            '10','20.PROF. INSTR.',
                            '11','20.PROF. INSTR.',
                            '12','20.PROF. INSTR.',
                            '21.ALL OTHER')) = p_job_category_name;


--Step 5
CURSOR csr_tmr_nh_details(p_business_group_id        IN NUMBER
                                              ,p_fr                                IN VARCHAR2
			                      ,p_ft                                IN VARCHAR2
                  			      ,p_pr                               IN VARCHAR2
			                      ,p_pt                               IN VARCHAR2
			                      ,p_employment_category IN VARCHAR2
			                      ,p_job_category_name    IN VARCHAR2
			                      ,p_report_date                IN DATE
			                      ,p_report_year                IN NUMBER) IS
SELECT	count(decode(pei.pei_information5,'1',decode(peo.sex,'M',1,null),null)) no_tmraces_wmale_emps,
                  count(decode(pei.pei_information5,'2',decode(peo.sex,'M',1,null),null)) no_tmraces_bmale_emps,
                  count(decode(pei.pei_information5,'3',decode(peo.sex,'M',1,null),'9',decode(peo.sex,'M',1,null),null)) no_tmraces_hmale_emps,
                  count(decode(pei.pei_information5,'4',decode(peo.sex,'M',1,null),'5',decode(peo.sex,'M',1,null),null)) no_tmraces_amale_emps,
                  count(decode(pei.pei_information5,'6',decode(peo.sex,'M',1,null),null)) no_tmraces_imale_emps,
                  count(decode(pei.pei_information5,'1',decode(peo.sex,'F',1,null),null)) no_tmraces_wfemale_emps,
                  count(decode(pei.pei_information5,'2',decode(peo.sex,'F',1,null),null)) no_tmraces_bfemale_emps,
                  count(decode(pei.pei_information5,'3',decode(peo.sex,'F',1,null),'9',decode(peo.sex,'F',1,null),null)) no_tmraces_hfemale_emps,
                  count(decode(pei.pei_information5,'4',decode(peo.sex,'F',1,null),'5',decode(peo.sex,'F',1,null),null)) no_tmraces_afemale_emps,
                  count(decode(pei.pei_information5,'6',decode(peo.sex,'F',1,null),null)) no_tmraces_ifemale_emps
FROM  per_all_people_f      peo,
      per_all_assignments_f ass,
      per_jobs              job,
      hr_lookups            hl,
      per_people_extra_info pei
WHERE peo.person_id = ass.person_id
AND    peo.per_information1 = '13'
AND    peo.person_id = pei.person_id(+)
AND    pei.information_type = 'PER_US_ADDL_ETHNIC_CAT'
AND    pei.pei_information5 is not null
AND   peo.current_employee_flag  = 'Y'
AND   hl.lookup_code = job.job_information1
AND   hl.lookup_type = 'US_EEO5_JOB_CATEGORIES'
AND   job.job_information_category = 'US'
AND   ass.job_id  = job.job_id
AND   ass.assignment_type = 'E'
AND   (SELECT   date_start
       FROM      per_periods_of_service
       WHERE    period_of_service_id = ass.period_of_service_id)
       BETWEEN ADD_MONTHS(p_report_date,-3) +1  AND p_report_date
AND   ass.primary_flag	= 'Y'
AND    pqh_employment_category.identify_empl_category(ass.employment_category,p_fr,p_ft,p_pr,p_pt) IN ('FR')
AND   ass.organization_id  IN (
          	SELECT 	organization_id
          	FROM	hr_all_organization_units
          	WHERE	business_group_id = p_business_group_id  )
and 'C. NEW HIRES (JULY THRU SEPT. '||p_report_year||')'  = p_employment_category
and DECODE(job.job_information1,
               '1','23.0/A/M',         '2','24.PRIN/ASST.PR',
               '3','24.PRIN/ASST.PR',  '4','24.PRIN/ASST.PR',
               '5','25.CLSRM. TCHRS',  '6','25.CLSRM. TCHRS',
               '7','25.CLSRM. TCHRS',  '8','26.OTHER PROF.',
               '9','26.OTHER PROF.',   '10','26.OTHER PROF.',
               '11','26.OTHER PROF.',  '12','26.OTHER PROF.',
               '13','27.NONPROF.',     '14','27.NONPROF.',
               '15','27.NONPROF.',     '16','27.NONPROF.',
               '17','27.NONPROF.',     '18','27.NONPROF.')  = p_job_category_name;


  l_start_code   NUMBER := 1;
  l_end_code     NUMBER := 1;
  l_current_code NUMBER := 1;
  l_sum_cons_total_category_emps NUMBER := 0;
  l_sum_no_cons_wmale_emps       NUMBER := 0;
  l_sum_no_cons_bmale_emps       NUMBER := 0;
  l_sum_no_cons_hmale_emps       NUMBER := 0;
  l_sum_no_cons_amale_emps       NUMBER := 0;
  l_sum_no_cons_imale_emps       NUMBER := 0;
  l_sum_no_cons_wfemale_emps     NUMBER := 0;
  l_sum_no_cons_bfemale_emps     NUMBER := 0;
  l_sum_no_cons_hfemale_emps     NUMBER := 0;
  l_sum_no_cons_afemale_emps     NUMBER := 0;
  l_sum_no_cons_ifemale_emps     NUMBER := 0;
  l_total_category_employees NUMBER := 0;
  l_report_date    DATE;
  l_job_category_name_main VARCHAR2(200);
  l_new_hires_heading          VARCHAR2(200);


  --Final Step
  CURSOR csr_annexes(p_report_date IN DATE,p_business_group_id  IN NUMBER) IS
    SELECT COUNT(1)
     FROM (
           SELECT ass.location_id
             FROM per_all_assignments_f ass,
                  hr_organization_units_v hou,
                  per_all_people_f  peo
           WHERE  ass.organization_id = hou.organization_id
             AND  ass.person_id       = peo.person_id
             AND  p_report_date between ass.effective_start_date and ass.effective_end_date
             AND  p_report_date between peo.effective_start_date and peo.effective_end_date
             AND  hou.business_group_id = p_business_group_id
           UNION
          SELECT location_id
           FROM  hr_all_organization_units
          WHERE  business_group_id = p_business_group_id
            AND  NVL(date_to,p_report_date + 1) >= p_report_date );
   l_count_annexes NUMBER := 0;


  CURSOR csr_schools(p_business_group_id IN NUMBER) IS
    SELECT COUNT(1)
      FROM hr_organization_units_v  hou
     WHERE hou.business_group_id = p_business_group_id;
   l_count_schools NUMBER := 0;

  CURSOR csr_district_id(p_business_group_id IN NUMBER) IS
  SELECT org_information12 district_id
    FROM hr_organization_information
   WHERE org_information_context = 'EEO_REPORT'
     AND org_information11 = 'EEO5'
     AND organization_id = p_business_group_id;

  l_district_name  VARCHAR2(200);
  l_district_id    VARCHAR2(200);
  l_char_report_date  VARCHAR2(20);

no_tmraces_wmale_emps NUMBER := 0;
no_tmraces_bmale_emps NUMBER := 0;
no_tmraces_hmale_emps NUMBER := 0;
no_tmraces_amale_emps NUMBER := 0;
no_tmraces_imale_emps NUMBER := 0;
no_tmraces_wfemale_emps NUMBER := 0;
no_tmraces_bfemale_emps NUMBER := 0;
no_tmraces_hfemale_emps NUMBER := 0;
no_tmraces_afemale_emps NUMBER := 0;
no_tmraces_ifemale_emps NUMBER := 0;

--Local Procedure
PROCEDURE create_record(p_start_code               IN NUMBER
                       ,p_end_code                 IN NUMBER
                       ,p_current_code             IN NUMBER
                       ,p_job_category_name        IN VARCHAR2
		       ,p_cons_total_category_emps IN NUMBER
		       ,p_no_cons_wmale_emps       IN NUMBER
		       ,p_no_cons_bmale_emps       IN NUMBER
		       ,p_no_cons_hmale_emps       IN NUMBER
		       ,p_no_cons_amale_emps       IN NUMBER
		       ,p_no_cons_imale_emps       IN NUMBER
		       ,p_no_cons_wfemale_emps     IN NUMBER
		       ,p_no_cons_bfemale_emps     IN NUMBER
		       ,p_no_cons_hfemale_emps     IN NUMBER
		       ,p_no_cons_afemale_emps     IN NUMBER
		       ,p_no_cons_ifemale_emps     IN NUMBER
		       ) IS

  CURSOR  csr_lookup_code(p_counter IN NUMBER) IS
  SELECT  LPAD(hl.lookup_code,2,' ')||'.'||hl.meaning
    FROM  hr_lookups hl
   WHERE  lookup_type = 'US_EEO5_JOB_CATEGORIES'
     AND  TO_NUMBER(lookup_code) = p_counter
     AND  application_id = 800;
  l_job_category_name VARCHAR2(200);


BEGIN /*create_record*/

  FOR i IN p_start_code..p_end_code LOOP

    --Need to fetch the job_categroy_name from hr_lookups based on the variable 1.

    l_job_category_name := get_job_category_meaning(i);


    l_xml_string := l_xml_string ||'<LIST_G_JOB_CATEGORIES>';
    l_xml_string := l_xml_string ||'<G_JOB_CATEGORIES>';
    l_xml_string := l_xml_string ||convert_into_xml('JOB_CATEGORY_MEANING',l_job_category_name,'D');
    l_xml_string := l_xml_string ||'<LIST_G_JOB_INFORMATION>';
    l_xml_string := l_xml_string ||'<G_JOB_INFORMATION>';
    l_xml_string := l_xml_string ||convert_into_xml('CONS_TOTAL_CATEGORY_EMPS',0,'D');
    l_xml_string := l_xml_string ||convert_into_xml('NO_CONS_WMALE_EMPS',0,'D');
    l_xml_string := l_xml_string ||convert_into_xml('NO_CONS_BMALE_EMPS',0,'D');
    l_xml_string := l_xml_string ||convert_into_xml('NO_CONS_HMALE_EMPS',0,'D');
    l_xml_string := l_xml_string ||convert_into_xml('NO_CONS_AMALE_EMPS',0,'D');
    l_xml_string := l_xml_string ||convert_into_xml('NO_CONS_IMALE_EMPS',0,'D');
    l_xml_string := l_xml_string ||convert_into_xml('NO_CONS_WFEMALE_EMPS',0,'D');
    l_xml_string := l_xml_string ||convert_into_xml('NO_CONS_BFEMALE_EMPS',0,'D');
    l_xml_string := l_xml_string ||convert_into_xml('NO_CONS_HFEMALE_EMPS',0,'D');
    l_xml_string := l_xml_string ||convert_into_xml('NO_CONS_AFEMALE_EMPS',0,'D');
    l_xml_string := l_xml_string ||convert_into_xml('NO_CONS_IFEMALE_EMPS',0,'D');
    l_xml_string := l_xml_string ||'</G_JOB_INFORMATION>';
    l_xml_string := l_xml_string ||'</LIST_G_JOB_INFORMATION>';
    l_xml_string := l_xml_string ||'</G_JOB_CATEGORIES>';
    l_xml_string := l_xml_string ||'</LIST_G_JOB_CATEGORIES>';

  END LOOP;

  IF p_current_code <> 0 THEN
    l_job_category_name := get_job_category_meaning(p_current_code);
    l_xml_string := l_xml_string ||'<LIST_G_JOB_CATEGORIES>';
    l_xml_string := l_xml_string ||'<G_JOB_CATEGORIES>';
    l_xml_string := l_xml_string ||convert_into_xml('JOB_CATEGORY_MEANING',l_job_category_name,'D');
    l_xml_string := l_xml_string ||'<LIST_G_JOB_INFORMATION>';
    l_xml_string := l_xml_string ||'<G_JOB_INFORMATION>';
    l_xml_string := l_xml_string ||convert_into_xml('CONS_TOTAL_CATEGORY_EMPS',p_cons_total_category_emps,'D');
    l_xml_string := l_xml_string ||convert_into_xml('NO_CONS_WMALE_EMPS',p_no_cons_wmale_emps,'D');
    l_xml_string := l_xml_string ||convert_into_xml('NO_CONS_BMALE_EMPS',p_no_cons_bmale_emps,'D');
    l_xml_string := l_xml_string ||convert_into_xml('NO_CONS_HMALE_EMPS',p_no_cons_hmale_emps,'D');
    l_xml_string := l_xml_string ||convert_into_xml('NO_CONS_AMALE_EMPS',p_no_cons_amale_emps,'D');
    l_xml_string := l_xml_string ||convert_into_xml('NO_CONS_IMALE_EMPS',p_no_cons_imale_emps,'D');
    l_xml_string := l_xml_string ||convert_into_xml('NO_CONS_WFEMALE_EMPS',p_no_cons_wfemale_emps,'D');
    l_xml_string := l_xml_string ||convert_into_xml('NO_CONS_BFEMALE_EMPS',p_no_cons_bfemale_emps,'D');
    l_xml_string := l_xml_string ||convert_into_xml('NO_CONS_HFEMALE_EMPS',p_no_cons_hfemale_emps,'D');
    l_xml_string := l_xml_string ||convert_into_xml('NO_CONS_AFEMALE_EMPS',p_no_cons_afemale_emps,'D');
    l_xml_string := l_xml_string ||convert_into_xml('NO_CONS_IFEMALE_EMPS',p_no_cons_ifemale_emps,'D');
    l_xml_string := l_xml_string ||'</G_JOB_INFORMATION>';
    l_xml_string := l_xml_string ||'</LIST_G_JOB_INFORMATION>';
    l_xml_string := l_xml_string ||'</G_JOB_CATEGORIES>';
    l_xml_string := l_xml_string ||'</LIST_G_JOB_CATEGORIES>';
  END IF;

END create_record;

BEGIN /* generate_xml_data */
  l_xml_string := '<?xml version="1.0"?> <PQHEEO5>';


--Step 1 : Write Business Group Details
/*
   <LIST_G_JURISDICTION_DETAIL>
     <G_JURISDICTION_DETAIL>
       <CITY_STATE_ZIP>San Francisco,San Francisco,CA,94100-1234</CITY_STATE_ZIP>
       <BUSINESS_NAME>MM_RT BG2</BUSINESS_NAME>
       <ADDRESS>314 Maple Street Suite 1000</ADDRESS>
     </G_JURISDICTION_DETAIL>
   </LIST_G_JURISDICTION_DETAIL>
*/

  l_xml_string := l_xml_string ||'<LIST_G_JURISDICTION_DETAIL>';
  l_xml_string := l_xml_string ||'<G_JURISDICTION_DETAIL>';

  OPEN csr_district_id(p_business_group_id);
  FETCH csr_district_id INTO l_district_id;
  CLOSE csr_district_id;

  OPEN csr_bg_details(p_business_group_id);
  FETCH csr_bg_details INTO l_bg_name,l_location_id;
  CLOSE csr_bg_details;

  OPEN csr_bg_location(l_location_id);
  FETCH csr_bg_location INTO l_bg_address,l_bg_city, l_bg_county,l_bg_state,l_bg_zip_code;
  CLOSE csr_bg_location;


   l_district_name := l_bg_name;
   l_xml_string := l_xml_string ||convert_into_xml('BUSINESS_NAME',l_bg_name,'D');
   l_xml_string := l_xml_string ||convert_into_xml('BUSINESS_DISTRICT_ID',l_district_id,'D');
   l_xml_string := l_xml_string ||convert_into_xml('ADDRESS',l_bg_address,'D');
   l_xml_string := l_xml_string ||convert_into_xml('CITY',l_bg_city,'D');
   l_xml_string := l_xml_string ||convert_into_xml('COUNTY',l_bg_county,'D');
   l_xml_string := l_xml_string ||convert_into_xml('STATE',l_bg_state,'D');
   l_xml_string := l_xml_string ||convert_into_xml('ZIP_CODE',l_bg_zip_code,'D');

  l_xml_string := l_xml_string ||'</G_JURISDICTION_DETAIL>';
  l_xml_string := l_xml_string ||'</LIST_G_JURISDICTION_DETAIL>';
  write_to_concurrent_out(l_xml_string);


--Step 2 :
/*
   <LIST_G_CERT_OFFICER_NAME>
    <G_CERT_OFFICER_NAME>
     <SYSTEM_DISTRICT>DISTRICT</SYSTEM_DISTRICT>
     <TYPE_REPORT>DISTRICT SUMMARY</TYPE_REPORT>
     <CONTROL_NUMBER>1234567890</CONTROL_NUMBER>
     <CERT_OFFICER_NAME></CERT_OFFICER_NAME>
     <CERT_OFFICIAL_TITLE></CERT_OFFICIAL_TITLE>
     <CONTACT_TELEPHONE></CONTACT_TELEPHONE>
    </G_CERT_OFFICER_NAME>
  </LIST_G_CERT_OFFICER_NAME>
*/

  /* Resetting l_xml_string */
  l_xml_string := '<LIST_G_CERT_OFFICER_NAME>';
  l_xml_string := l_xml_string||'<G_CERT_OFFICER_NAME>';

  FOR i IN csr_cert_officer_details(p_business_group_id) LOOP
   l_xml_string := l_xml_string ||convert_into_xml('SYSTEM_DISTRICT',i.system_district,'D');
   l_xml_string := l_xml_string ||convert_into_xml('TYPE_REPORT',i.type_report,'D');
   l_xml_string := l_xml_string ||convert_into_xml('CONTROL_NUMBER',i.control_number,'D');
   IF ((i.cert_officer_name IS NOT NULL) AND (i.cert_official_title IS NOT NULL) ) THEN
   l_xml_string := l_xml_string ||convert_into_xml('CERT_OFFICER_NAME',i.cert_officer_name||'/','D');
   l_xml_string := l_xml_string ||convert_into_xml('CERT_OFFICIAL_TITLE',i.cert_official_title,'D');
   ELSE
   l_xml_string := l_xml_string ||convert_into_xml('CERT_OFFICER_NAME',i.cert_officer_name,'D');
   l_xml_string := l_xml_string ||convert_into_xml('CERT_OFFICIAL_TITLE',i.cert_official_title,'D');
   END IF;
   l_xml_string := l_xml_string ||convert_into_xml('CONTACT_TELEPHONE',i.contact_telephone,'D');
--   l_xml_string := l_xml_string||convert_into_xml('CP_REPORT_DATE',l_report_date,'D');
  END LOOP;

  l_xml_string := l_xml_string||'</G_CERT_OFFICER_NAME>';
  l_xml_string := l_xml_string||'</LIST_G_CERT_OFFICER_NAME>';
  write_to_concurrent_out(l_xml_string);


--Step 3 :
/*
<LIST_G_EMPLOYMENT_CATEGORY>
  <G_EMPLOYMENT_CATEGORY>
  <EMPLOYEE_SALARY_EMPLOYMENT_CAT>A. FULL TIME STAFF</EMPLOYEE_SALARY_EMPLOYMENT_CAT>
  <LIST_G_JOB_CATEGORIES>
   <G_JOB_CATEGORIES>
    <JOB_CATEGORY_MEANING>2.PRIN</JOB_CATEGORY_MEANING>
     <LIST_G_JOB_INFORMATION>
      <G_JOB_INFORMATION>
       <CONS_TOTAL_CATEGORY_EMPS>2</CONS_TOTAL_CATEGORY_EMPS>
        <NO_CONS_WMALE_EMPS>1</NO_CONS_WMALE_EMPS>
        <NO_CONS_BMALE_EMPS>0</NO_CONS_BMALE_EMPS>
        <NO_CONS_HMALE_EMPS>0</NO_CONS_HMALE_EMPS>
        <NO_CONS_AMALE_EMPS>0</NO_CONS_AMALE_EMPS>
        <NO_CONS_IMALE_EMPS>0</NO_CONS_IMALE_EMPS>
        <NO_CONS_WFEMALE_EMPS>1</NO_CONS_WFEMALE_EMPS>
        <NO_CONS_BFEMALE_EMPS>0</NO_CONS_BFEMALE_EMPS>
        <NO_CONS_HFEMALE_EMPS>0</NO_CONS_HFEMALE_EMPS>
        <NO_CONS_AFEMALE_EMPS>0</NO_CONS_AFEMALE_EMPS>
        <NO_CONS_IFEMALE_EMPS>0</NO_CONS_IFEMALE_EMPS>
       </G_JOB_INFORMATION>
      </LIST_G_JOB_INFORMATION>
    </G_JOB_CATEGORIES>
  </LIST_G_JOB_CATEGORIES>
  <LIST_G_JOB_CATEGORIES>
   <G_JOB_CATEGORIES>
    <JOB_CATEGORY_MEANING>3.</JOB_CATEGORY_MEANING>
     <LIST_G_JOB_INFORMATION>
      <G_JOB_INFORMATION>
       .....
       .....
       </G_JOB_INFORMATION>
      </LIST_G_JOB_INFORMATION>
    </G_JOB_CATEGORIES>
  </LIST_G_JOB_CATEGORIES>
  <CF_TOTAL_TITLE>19.TOTAL</CF_TOTAL_TITLE>
  <CS_NO_WMALE_EMPS>1</CS_NO_WMALE_EMPS>
  <CS_NO_BMALE_EMPS>1</CS_NO_BMALE_EMPS>
  <CS_NO_HMALE_EMPS>0</CS_NO_HMALE_EMPS>
  <CS_NO_AMALE_EMPS>1</CS_NO_AMALE_EMPS>
  <CS_NO_IMALE_EMPS>0</CS_NO_IMALE_EMPS>
  <CS_NO_WFEMALE_EMPS>1</CS_NO_WFEMALE_EMPS>
  <CS_NO_BFEMALE_EMPS>0</CS_NO_BFEMALE_EMPS>
  <CS_NO_HFEMALE_EMPS>0</CS_NO_HFEMALE_EMPS>
  <CS_NO_AFEMALE_EMPS>2</CS_NO_AFEMALE_EMPS>
  <CS_NO_IFEMALE_EMPS>1</CS_NO_IFEMALE_EMPS>
  <CS_TOTAL_CATEGORY_EMPS>7</CS_TOTAL_CATEGORY_EMPS>
  </G_EMPLOYMENT_CATEGORY>
  <G_EMPLOYMENT_CATEGORY>
  <EMPLOYEE_SALARY_EMPLOYMENT_CAT>B. PART-TIME STAFF</EMPLOYEE_SALARY_EMPLOYMENT_CAT>
</LIST_G_EMPLOYMENT_CATEGORY>
*/


  /* Resetting l_xml_string */
  l_xml_string := '<LIST_G_EMPLOYMENT_CATEGORY>';
  l_xml_string := l_xml_string||'<G_EMPLOYMENT_CATEGORY>';

  pqh_employment_category.fetch_empl_categories(p_business_group_id
                                               ,l_fr
                                               ,l_ft
                                               ,l_pr
                                               ,l_pt);

   hr_utility.set_location('=======in EEO5 per_us_eeo5_pkg==========='||l_fr, 5);
   hr_utility.set_location('l_fr -> '||l_fr, 5);
   hr_utility.set_location('l_fr -> '||l_ft, 5);
   hr_utility.set_location('l_fr -> '||l_pr, 5);
   hr_utility.set_location('l_fr -> '||l_pt, 5);
   hr_utility.set_location('=======in EEO5 per_us_eeo5_pkg==========='||l_fr, 5);

  --l_report_date is always for September.
  l_report_date := TO_DATE('30-09'||'-'||p_reporting_year,'DD-MM-RRRR');
  l_xml_string := l_xml_string ||convert_into_xml('EMPLOYEE_SALARY_EMPLOYMENT_CAT','A. FULL-TIME STAFF','D');
  l_start_code   := 1;
  l_end_code     := 1;
  l_current_code := 1;

  FOR i IN csr_full_time_details(p_business_group_id,l_fr,l_ft,l_pr,l_pt,l_report_date,p_reporting_year) LOOP
  --employment_category = 'A. FULL TIME STAFF' THEN
    l_current_code := TO_NUMBER(SUBSTR(i.job_category_name,1,2));
    l_end_code     := l_current_code - 1;

    -- Get the person counts with ethnic code 'Two or more races'
    OPEN csr_tmr_ft_details(p_business_group_id,l_fr,l_ft,l_pr,l_pt,i.employment_category,i.job_category_name,l_report_date,p_reporting_year);
    FETCH csr_tmr_ft_details INTO no_tmraces_wmale_emps,
                                                        no_tmraces_bmale_emps,
						        no_tmraces_hmale_emps,
							no_tmraces_amale_emps,
							no_tmraces_imale_emps,
							no_tmraces_wfemale_emps,
							no_tmraces_bfemale_emps,
							no_tmraces_hfemale_emps,
							no_tmraces_afemale_emps,
							no_tmraces_ifemale_emps;
    CLOSE csr_tmr_ft_details;

    l_total_category_employees := i.cons_total_category_emps +
                                                   no_tmraces_wmale_emps +
						   no_tmraces_bmale_emps +
						   no_tmraces_hmale_emps +
						   no_tmraces_amale_emps +
						   no_tmraces_imale_emps +
						   no_tmraces_wfemale_emps +
						   no_tmraces_bfemale_emps +
						   no_tmraces_hfemale_emps +
						   no_tmraces_afemale_emps +
						   no_tmraces_ifemale_emps;


       --Current record needs to be written as XML to FND OUT.
       create_record(l_start_code
                    ,l_end_code
                    ,l_current_code
                    ,i.job_category_name
		    ,l_total_category_employees
		    ,i.no_cons_wmale_emps + no_tmraces_wmale_emps
		    ,i.no_cons_bmale_emps + no_tmraces_bmale_emps
		    ,i.no_cons_hmale_emps + no_tmraces_hmale_emps
		    ,i.no_cons_amale_emps + no_tmraces_amale_emps
		    ,i.no_cons_imale_emps + no_tmraces_imale_emps
		    ,i.no_cons_wfemale_emps + no_tmraces_wfemale_emps
		    ,i.no_cons_bfemale_emps + no_tmraces_bfemale_emps
		    ,i.no_cons_hfemale_emps + no_tmraces_hfemale_emps
		    ,i.no_cons_afemale_emps + no_tmraces_afemale_emps
		    ,i.no_cons_ifemale_emps + no_tmraces_ifemale_emps);
      -- Bug# 6242997
      l_sum_cons_total_category_emps   :=  l_sum_cons_total_category_emps + l_total_category_employees;
      l_sum_no_cons_wmale_emps         :=  l_sum_no_cons_wmale_emps       + i.no_cons_wmale_emps + no_tmraces_wmale_emps;
      l_sum_no_cons_bmale_emps         :=  l_sum_no_cons_bmale_emps       + i.no_cons_bmale_emps + no_tmraces_bmale_emps;
      l_sum_no_cons_hmale_emps         :=  l_sum_no_cons_hmale_emps       + i.no_cons_hmale_emps + no_tmraces_hmale_emps;
      l_sum_no_cons_amale_emps         :=  l_sum_no_cons_amale_emps       + i.no_cons_amale_emps + no_tmraces_amale_emps;
      l_sum_no_cons_imale_emps         :=  l_sum_no_cons_imale_emps       + i.no_cons_imale_emps + no_tmraces_imale_emps;
      l_sum_no_cons_wfemale_emps       :=  l_sum_no_cons_wfemale_emps     + i.no_cons_wfemale_emps + no_tmraces_wfemale_emps;
      l_sum_no_cons_bfemale_emps       :=  l_sum_no_cons_bfemale_emps     + i.no_cons_bfemale_emps + no_tmraces_bfemale_emps;
      l_sum_no_cons_hfemale_emps       :=  l_sum_no_cons_hfemale_emps     + i.no_cons_hfemale_emps + no_tmraces_hfemale_emps;
      l_sum_no_cons_afemale_emps       :=  l_sum_no_cons_afemale_emps     + i.no_cons_afemale_emps + no_tmraces_afemale_emps;
      l_sum_no_cons_ifemale_emps       :=  l_sum_no_cons_ifemale_emps     + i.no_cons_ifemale_emps + no_tmraces_ifemale_emps;
      hr_utility_trace('==================================================');
      hr_utility_trace(' i.job_category_name -> ' || i.job_category_name);
      hr_utility_trace(' l_start_code -> ' || l_start_code);
      hr_utility_trace(' l_end_code -> ' || l_end_code);
      hr_utility_trace(' l_current_code -> ' || l_current_code);
      hr_utility_trace('==================================================');
      l_start_code := l_current_code+1;
  END LOOP;/* csr_full_time_details */

      hr_utility_trace('==================================================');
      hr_utility_trace(' Out of the Loop -> ');
      hr_utility_trace(' length(l_xml_string) -> ' || length(l_xml_string));
      hr_utility_trace(' l_start_code -> ' || l_start_code);
      hr_utility_trace(' l_end_code -> ' || l_end_code);
      hr_utility_trace(' l_current_code -> ' || l_current_code);
      hr_utility_trace('==================================================');

      IF l_start_code = 1 THEN
      -- Cursor csr_full_time_details did not fetch any records.
       l_end_code := 18;
       create_record(l_start_code
                    ,l_end_code
                    ,0
                    ,0
		    ,0
		    ,0
		    ,0
		    ,0
		    ,0
		    ,0
		    ,0
		    ,0
		    ,0
		    ,0
		    ,0);
         l_sum_cons_total_category_emps := 0;
         l_sum_no_cons_wmale_emps       := 0;
         l_sum_no_cons_bmale_emps       := 0;
         l_sum_no_cons_hmale_emps       := 0;
         l_sum_no_cons_amale_emps       := 0;
         l_sum_no_cons_imale_emps       := 0;
         l_sum_no_cons_wfemale_emps     := 0;
         l_sum_no_cons_bfemale_emps     := 0;
         l_sum_no_cons_hfemale_emps     := 0;
         l_sum_no_cons_afemale_emps     := 0;
         l_sum_no_cons_ifemale_emps     := 0;

      ELSIF l_start_code > 1 THEN

      --Cursor has fetched some data.
      l_end_code := 18;
       create_record(l_start_code
                    ,l_end_code
                    ,0
                    ,0
		    ,0
		    ,0
		    ,0
		    ,0
		    ,0
		    ,0
		    ,0
		    ,0
		    ,0
		    ,0
		    ,0);
     END IF; /* l_start_code = 1 */

     l_job_category_name_main := get_job_category_meaning(19);
     l_xml_string := l_xml_string ||'<LIST_G_JOB_CATEGORIES>';
     l_xml_string := l_xml_string ||'<G_JOB_CATEGORIES>';
     l_xml_string := l_xml_string ||convert_into_xml('JOB_CATEGORY_MEANING',l_job_category_name_main,'D');
     l_xml_string := l_xml_string ||'<LIST_G_JOB_INFORMATION>';
     l_xml_string := l_xml_string ||'<G_JOB_INFORMATION>';
     l_xml_string := l_xml_string || convert_into_xml('NO_CONS_WMALE_EMPS',l_sum_no_cons_wmale_emps,'D');
     l_xml_string := l_xml_string || convert_into_xml('NO_CONS_BMALE_EMPS',l_sum_no_cons_bmale_emps,'D');
     l_xml_string := l_xml_string || convert_into_xml('NO_CONS_HMALE_EMPS',l_sum_no_cons_hmale_emps,'D');
     l_xml_string := l_xml_string || convert_into_xml('NO_CONS_AMALE_EMPS',l_sum_no_cons_amale_emps,'D');
     l_xml_string := l_xml_string || convert_into_xml('NO_CONS_IMALE_EMPS',l_sum_no_cons_imale_emps,'D');
     l_xml_string := l_xml_string || convert_into_xml('NO_CONS_WFEMALE_EMPS',l_sum_no_cons_wfemale_emps,'D');
     l_xml_string := l_xml_string || convert_into_xml('NO_CONS_BFEMALE_EMPS',l_sum_no_cons_bfemale_emps,'D');
     l_xml_string := l_xml_string || convert_into_xml('NO_CONS_HFEMALE_EMPS',l_sum_no_cons_hfemale_emps,'D');
     l_xml_string := l_xml_string || convert_into_xml('NO_CONS_AFEMALE_EMPS',l_sum_no_cons_afemale_emps,'D');
     l_xml_string := l_xml_string || convert_into_xml('NO_CONS_IFEMALE_EMPS',l_sum_no_cons_ifemale_emps,'D');
     l_xml_string := l_xml_string || convert_into_xml('CONS_TOTAL_CATEGORY_EMPS',l_sum_cons_total_category_emps,'D');
     l_xml_string := l_xml_string ||'</G_JOB_INFORMATION>';
     l_xml_string := l_xml_string ||'</LIST_G_JOB_INFORMATION>';
     l_xml_string := l_xml_string ||'</G_JOB_CATEGORIES>';
     l_xml_string := l_xml_string ||'</LIST_G_JOB_CATEGORIES>';
     l_xml_string := l_xml_string||'</G_EMPLOYMENT_CATEGORY>';

     write_to_concurrent_out(l_xml_string);

--End of full time employees. End of Step 3.


--Step 4.
  l_xml_string := '<G_EMPLOYMENT_CATEGORY>';
  l_sum_cons_total_category_emps := 0;
  l_sum_no_cons_wmale_emps       := 0;
  l_sum_no_cons_bmale_emps       := 0;
  l_sum_no_cons_hmale_emps       := 0;
  l_sum_no_cons_amale_emps       := 0;
  l_sum_no_cons_imale_emps       := 0;
  l_sum_no_cons_wfemale_emps     := 0;
  l_sum_no_cons_bfemale_emps     := 0;
  l_sum_no_cons_hfemale_emps     := 0;
  l_sum_no_cons_afemale_emps     := 0;
  l_sum_no_cons_ifemale_emps     := 0;
  l_start_code := 20;
  l_xml_string := l_xml_string ||convert_into_xml('EMPLOYEE_SALARY_EMPLOYMENT_CAT','B. PART-TIME STAFF','D');

  FOR i IN csr_part_time_details(p_business_group_id,l_fr,l_ft,l_pr,l_pt,l_report_date,p_reporting_year) LOOP
    l_current_code := TO_NUMBER(SUBSTR(i.job_category_name,1,2));
    l_end_code     := l_current_code - 1;
       -- Get the person counts with ethnic code 'Two or more races'
    OPEN csr_tmr_pt_details(p_business_group_id,l_fr,l_ft,l_pr,l_pt,i.employment_category,i.job_category_name,l_report_date,p_reporting_year);
    FETCH csr_tmr_pt_details INTO no_tmraces_wmale_emps,
                                                        no_tmraces_bmale_emps,
						        no_tmraces_hmale_emps,
							no_tmraces_amale_emps,
							no_tmraces_imale_emps,
							no_tmraces_wfemale_emps,
							no_tmraces_bfemale_emps,
							no_tmraces_hfemale_emps,
							no_tmraces_afemale_emps,
							no_tmraces_ifemale_emps;
    CLOSE csr_tmr_pt_details;

    l_total_category_employees := i.cons_total_category_emps +
                                                   no_tmraces_wmale_emps +
						   no_tmraces_bmale_emps +
						   no_tmraces_hmale_emps +
						   no_tmraces_amale_emps +
						   no_tmraces_imale_emps +
						   no_tmraces_wfemale_emps +
						   no_tmraces_bfemale_emps +
						   no_tmraces_hfemale_emps +
						   no_tmraces_afemale_emps +
						   no_tmraces_ifemale_emps;

       --Current record needs to be written as XML to FND OUT.
       create_record(l_start_code
                    ,l_end_code
                    ,l_current_code
                    ,i.job_category_name
		    ,l_total_category_employees
		    ,i.no_cons_wmale_emps + no_tmraces_wmale_emps
		    ,i.no_cons_bmale_emps + no_tmraces_bmale_emps
		    ,i.no_cons_hmale_emps + no_tmraces_hmale_emps
		    ,i.no_cons_amale_emps + no_tmraces_amale_emps
		    ,i.no_cons_imale_emps + no_tmraces_imale_emps
		    ,i.no_cons_wfemale_emps + no_tmraces_wfemale_emps
		    ,i.no_cons_bfemale_emps + no_tmraces_bfemale_emps
		    ,i.no_cons_hfemale_emps + no_tmraces_hfemale_emps
		    ,i.no_cons_afemale_emps + no_tmraces_afemale_emps
		    ,i.no_cons_ifemale_emps + no_tmraces_ifemale_emps);
      -- Bug# 6242997
      l_sum_cons_total_category_emps   :=  l_sum_cons_total_category_emps + l_total_category_employees;
      l_sum_no_cons_wmale_emps         :=  l_sum_no_cons_wmale_emps       + i.no_cons_wmale_emps + no_tmraces_wmale_emps;
      l_sum_no_cons_bmale_emps         :=  l_sum_no_cons_bmale_emps       + i.no_cons_bmale_emps + no_tmraces_bmale_emps;
      l_sum_no_cons_hmale_emps         :=  l_sum_no_cons_hmale_emps       + i.no_cons_hmale_emps + no_tmraces_hmale_emps;
      l_sum_no_cons_amale_emps         :=  l_sum_no_cons_amale_emps       + i.no_cons_amale_emps + no_tmraces_amale_emps;
      l_sum_no_cons_imale_emps         :=  l_sum_no_cons_imale_emps       + i.no_cons_imale_emps + no_tmraces_imale_emps;
      l_sum_no_cons_wfemale_emps       :=  l_sum_no_cons_wfemale_emps     + i.no_cons_wfemale_emps + no_tmraces_wfemale_emps;
      l_sum_no_cons_bfemale_emps       :=  l_sum_no_cons_bfemale_emps     + i.no_cons_bfemale_emps + no_tmraces_bfemale_emps;
      l_sum_no_cons_hfemale_emps       :=  l_sum_no_cons_hfemale_emps     + i.no_cons_hfemale_emps + no_tmraces_hfemale_emps;
      l_sum_no_cons_afemale_emps       :=  l_sum_no_cons_afemale_emps     + i.no_cons_afemale_emps + no_tmraces_afemale_emps;
      l_sum_no_cons_ifemale_emps       :=  l_sum_no_cons_ifemale_emps     + i.no_cons_ifemale_emps + no_tmraces_ifemale_emps;
      l_start_code := l_current_code+1;
  END LOOP; /* csr_part_time_details */

      l_end_code := 21;
        IF l_start_code = 20 THEN
	    --Cursor has not fetched any data.
	       create_record(l_start_code  --20
                            ,l_end_code    --21
                            ,0
                            ,0
		            ,0
         		    ,0
	        	    ,0
		            ,0
                 	    ,0
		            ,0
         		    ,0
	        	    ,0
         		    ,0
        		    ,0
         		    ,0);
              l_sum_cons_total_category_emps := 0;
              l_sum_no_cons_wmale_emps       := 0;
              l_sum_no_cons_bmale_emps       := 0;
              l_sum_no_cons_hmale_emps       := 0;
              l_sum_no_cons_amale_emps       := 0;
              l_sum_no_cons_imale_emps       := 0;
              l_sum_no_cons_wfemale_emps     := 0;
              l_sum_no_cons_bfemale_emps     := 0;
              l_sum_no_cons_hfemale_emps     := 0;
              l_sum_no_cons_afemale_emps     := 0;
              l_sum_no_cons_ifemale_emps     := 0;

	ELSIF l_start_code = 21 THEN
	       l_job_category_name_main := '21.ALL OTHER';
               create_record(l_start_code  --21
                            ,l_end_code    --21
                            ,0
                            ,0
		            ,0
         		    ,0
	        	    ,0
		            ,0
                 	    ,0
		            ,0
         		    ,0
	        	    ,0
         		    ,0
        		    ,0
         		    ,0);
        END IF;


     l_job_category_name_main := get_job_category_meaning(22);
     l_xml_string := l_xml_string ||'<LIST_G_JOB_CATEGORIES>';
     l_xml_string := l_xml_string ||'<G_JOB_CATEGORIES>';
     l_xml_string := l_xml_string ||convert_into_xml('JOB_CATEGORY_MEANING',l_job_category_name_main,'D');
     l_xml_string := l_xml_string ||'<LIST_G_JOB_INFORMATION>';
     l_xml_string := l_xml_string ||'<G_JOB_INFORMATION>';
     l_xml_string := l_xml_string || convert_into_xml('NO_CONS_WMALE_EMPS',l_sum_no_cons_wmale_emps,'D');
     l_xml_string := l_xml_string || convert_into_xml('NO_CONS_BMALE_EMPS',l_sum_no_cons_bmale_emps,'D');
     l_xml_string := l_xml_string || convert_into_xml('NO_CONS_HMALE_EMPS',l_sum_no_cons_hmale_emps,'D');
     l_xml_string := l_xml_string || convert_into_xml('NO_CONS_AMALE_EMPS',l_sum_no_cons_amale_emps,'D');
     l_xml_string := l_xml_string || convert_into_xml('NO_CONS_IMALE_EMPS',l_sum_no_cons_imale_emps,'D');
     l_xml_string := l_xml_string || convert_into_xml('NO_CONS_WFEMALE_EMPS',l_sum_no_cons_wfemale_emps,'D');
     l_xml_string := l_xml_string || convert_into_xml('NO_CONS_BFEMALE_EMPS',l_sum_no_cons_bfemale_emps,'D');
     l_xml_string := l_xml_string || convert_into_xml('NO_CONS_HFEMALE_EMPS',l_sum_no_cons_hfemale_emps,'D');
     l_xml_string := l_xml_string || convert_into_xml('NO_CONS_AFEMALE_EMPS',l_sum_no_cons_afemale_emps,'D');
     l_xml_string := l_xml_string || convert_into_xml('NO_CONS_IFEMALE_EMPS',l_sum_no_cons_ifemale_emps,'D');
     l_xml_string := l_xml_string || convert_into_xml('CONS_TOTAL_CATEGORY_EMPS',l_sum_cons_total_category_emps,'D');
     l_xml_string := l_xml_string ||'</G_JOB_INFORMATION>';
     l_xml_string := l_xml_string ||'</LIST_G_JOB_INFORMATION>';
     l_xml_string := l_xml_string ||'</G_JOB_CATEGORIES>';
     l_xml_string := l_xml_string ||'</LIST_G_JOB_CATEGORIES>';
     l_xml_string := l_xml_string||'</G_EMPLOYMENT_CATEGORY>';
--     l_xml_string := l_xml_string||'</LIST_G_EMPLOYMENT_CATEGORY> </PQHEEO5>';

     write_to_concurrent_out(l_xml_string);


--Step 5: Codes 23 to 27
    l_sum_cons_total_category_emps := 0;
    l_sum_no_cons_wmale_emps       := 0;
    l_sum_no_cons_bmale_emps       := 0;
    l_sum_no_cons_hmale_emps       := 0;
    l_sum_no_cons_amale_emps       := 0;
    l_sum_no_cons_imale_emps       := 0;
    l_sum_no_cons_wfemale_emps     := 0;
    l_sum_no_cons_bfemale_emps     := 0;
    l_sum_no_cons_hfemale_emps     := 0;
    l_sum_no_cons_afemale_emps     := 0;
    l_sum_no_cons_ifemale_emps     := 0;
    l_xml_string := '<G_EMPLOYMENT_CATEGORY>';
    l_start_code := 23;
    l_new_hires_heading := 'C. NEW HIRES (JULY THRU SEPT. '|| p_reporting_year ||')';
    l_xml_string := l_xml_string ||convert_into_xml('EMPLOYEE_SALARY_EMPLOYMENT_CAT',l_new_hires_heading,'D');

    FOR i IN csr_new_hires_details(p_business_group_id,l_fr,l_ft,l_pr,l_pt,l_report_date,p_reporting_year) LOOP
       l_current_code := TO_NUMBER(SUBSTR(i.job_category_name,1,2));
       l_end_code     := l_current_code - 1;

       -- Get the person counts with ethnic code 'Two or more races'
    OPEN csr_tmr_nh_details(p_business_group_id,l_fr,l_ft,l_pr,l_pt,i.employment_category,i.job_category_name,l_report_date,p_reporting_year);
    FETCH csr_tmr_nh_details INTO no_tmraces_wmale_emps,
                                                        no_tmraces_bmale_emps,
						        no_tmraces_hmale_emps,
							no_tmraces_amale_emps,
							no_tmraces_imale_emps,
							no_tmraces_wfemale_emps,
							no_tmraces_bfemale_emps,
							no_tmraces_hfemale_emps,
							no_tmraces_afemale_emps,
							no_tmraces_ifemale_emps;
    CLOSE csr_tmr_nh_details;

    l_total_category_employees := i.cons_total_category_emps +
                                                   no_tmraces_wmale_emps +
						   no_tmraces_bmale_emps +
						   no_tmraces_hmale_emps +
						   no_tmraces_amale_emps +
						   no_tmraces_imale_emps +
						   no_tmraces_wfemale_emps +
						   no_tmraces_bfemale_emps +
						   no_tmraces_hfemale_emps +
						   no_tmraces_afemale_emps +
						   no_tmraces_ifemale_emps;

       --Current record needs to be written as XML to FND OUT.
       create_record(l_start_code
                    ,l_end_code
                    ,l_current_code
                    ,i.job_category_name
		    ,l_total_category_employees
		    ,i.no_cons_wmale_emps + no_tmraces_wmale_emps
		    ,i.no_cons_bmale_emps + no_tmraces_bmale_emps
		    ,i.no_cons_hmale_emps + no_tmraces_hmale_emps
		    ,i.no_cons_amale_emps + no_tmraces_amale_emps
		    ,i.no_cons_imale_emps + no_tmraces_imale_emps
		    ,i.no_cons_wfemale_emps + no_tmraces_wfemale_emps
		    ,i.no_cons_bfemale_emps + no_tmraces_bfemale_emps
		    ,i.no_cons_hfemale_emps + no_tmraces_hfemale_emps
		    ,i.no_cons_afemale_emps + no_tmraces_afemale_emps
		    ,i.no_cons_ifemale_emps + no_tmraces_ifemale_emps);
      -- Bug# 6242997
      l_sum_cons_total_category_emps   :=  l_sum_cons_total_category_emps + l_total_category_employees;
      l_sum_no_cons_wmale_emps         :=  l_sum_no_cons_wmale_emps       + i.no_cons_wmale_emps + no_tmraces_wmale_emps;
      l_sum_no_cons_bmale_emps         :=  l_sum_no_cons_bmale_emps       + i.no_cons_bmale_emps + no_tmraces_bmale_emps;
      l_sum_no_cons_hmale_emps         :=  l_sum_no_cons_hmale_emps       + i.no_cons_hmale_emps + no_tmraces_hmale_emps;
      l_sum_no_cons_amale_emps         :=  l_sum_no_cons_amale_emps       + i.no_cons_amale_emps + no_tmraces_amale_emps;
      l_sum_no_cons_imale_emps         :=  l_sum_no_cons_imale_emps       + i.no_cons_imale_emps + no_tmraces_imale_emps;
      l_sum_no_cons_wfemale_emps       :=  l_sum_no_cons_wfemale_emps     + i.no_cons_wfemale_emps + no_tmraces_wfemale_emps;
      l_sum_no_cons_bfemale_emps       :=  l_sum_no_cons_bfemale_emps     + i.no_cons_bfemale_emps + no_tmraces_bfemale_emps;
      l_sum_no_cons_hfemale_emps       :=  l_sum_no_cons_hfemale_emps     + i.no_cons_hfemale_emps + no_tmraces_hfemale_emps;
      l_sum_no_cons_afemale_emps       :=  l_sum_no_cons_afemale_emps     + i.no_cons_afemale_emps + no_tmraces_afemale_emps;
      l_sum_no_cons_ifemale_emps       :=  l_sum_no_cons_ifemale_emps     + i.no_cons_ifemale_emps + no_tmraces_ifemale_emps;
      l_start_code := l_current_code+1;
    END LOOP; /* csr_new_hires_details */

      l_end_code := 27;
      IF l_start_code = 23 THEN
	    --Cursor has not fetched any data.
	       create_record(l_start_code
                            ,l_end_code
                            ,0
                            ,0
		            ,0
         		    ,0
	        	    ,0
		            ,0
                 	    ,0
		            ,0
         		    ,0
	        	    ,0
         		    ,0
        		    ,0
         		    ,0);
              l_sum_cons_total_category_emps := 0;
              l_sum_no_cons_wmale_emps       := 0;
              l_sum_no_cons_bmale_emps       := 0;
              l_sum_no_cons_hmale_emps       := 0;
              l_sum_no_cons_amale_emps       := 0;
              l_sum_no_cons_imale_emps       := 0;
              l_sum_no_cons_wfemale_emps     := 0;
              l_sum_no_cons_bfemale_emps     := 0;
              l_sum_no_cons_hfemale_emps     := 0;
              l_sum_no_cons_afemale_emps     := 0;
              l_sum_no_cons_ifemale_emps     := 0;

      ELSIF l_start_code > 23 THEN
      --Cursor has fetched some data.
      l_end_code := 27;
       create_record(l_start_code
                    ,l_end_code
                    ,0
                    ,0
		    ,0
		    ,0
		    ,0
		    ,0
		    ,0
		    ,0
		    ,0
		    ,0
		    ,0
		    ,0
		    ,0);
      END IF;

     l_job_category_name_main := get_job_category_meaning(28);
     l_xml_string := l_xml_string ||'<LIST_G_JOB_CATEGORIES>';
     l_xml_string := l_xml_string ||'<G_JOB_CATEGORIES>';
     l_xml_string := l_xml_string ||convert_into_xml('JOB_CATEGORY_MEANING',l_job_category_name_main,'D');
     l_xml_string := l_xml_string ||'<LIST_G_JOB_INFORMATION>';
     l_xml_string := l_xml_string ||'<G_JOB_INFORMATION>';
     l_xml_string := l_xml_string || convert_into_xml('NO_CONS_WMALE_EMPS',l_sum_no_cons_wmale_emps,'D');
     l_xml_string := l_xml_string || convert_into_xml('NO_CONS_BMALE_EMPS',l_sum_no_cons_bmale_emps,'D');
     l_xml_string := l_xml_string || convert_into_xml('NO_CONS_HMALE_EMPS',l_sum_no_cons_hmale_emps,'D');
     l_xml_string := l_xml_string || convert_into_xml('NO_CONS_AMALE_EMPS',l_sum_no_cons_amale_emps,'D');
     l_xml_string := l_xml_string || convert_into_xml('NO_CONS_IMALE_EMPS',l_sum_no_cons_imale_emps,'D');
     l_xml_string := l_xml_string || convert_into_xml('NO_CONS_WFEMALE_EMPS',l_sum_no_cons_wfemale_emps,'D');
     l_xml_string := l_xml_string || convert_into_xml('NO_CONS_BFEMALE_EMPS',l_sum_no_cons_bfemale_emps,'D');
     l_xml_string := l_xml_string || convert_into_xml('NO_CONS_HFEMALE_EMPS',l_sum_no_cons_hfemale_emps,'D');
     l_xml_string := l_xml_string || convert_into_xml('NO_CONS_AFEMALE_EMPS',l_sum_no_cons_afemale_emps,'D');
     l_xml_string := l_xml_string || convert_into_xml('NO_CONS_IFEMALE_EMPS',l_sum_no_cons_ifemale_emps,'D');
     l_xml_string := l_xml_string || convert_into_xml('CONS_TOTAL_CATEGORY_EMPS',l_sum_cons_total_category_emps,'D');
     l_xml_string := l_xml_string ||'</G_JOB_INFORMATION>';
     l_xml_string := l_xml_string ||'</LIST_G_JOB_INFORMATION>';
     l_xml_string := l_xml_string ||'</G_JOB_CATEGORIES>';
     l_xml_string := l_xml_string ||'</LIST_G_JOB_CATEGORIES>';
     l_xml_string := l_xml_string||'</G_EMPLOYMENT_CATEGORY>';
     l_xml_string := l_xml_string||'</LIST_G_EMPLOYMENT_CATEGORY>';

     write_to_concurrent_out(l_xml_string);

--End of Step 5.
/*Final Step :
  <CF_NO_OF_ANNEXES>3</CF_NO_OF_ANNEXES>
  <CP_REPORT_DATE>30-SEP-05</CP_REPORT_DATE>
  <CP_NO_OF_SCHOOLS>6</CP_NO_OF_SCHOOLS>
  <CP_FR>'FR'</CP_FR>
  <CP_FT>'FT'</CP_FT>
  <CP_PR>'PR'</CP_PR>
  <CP_PT>'PT'</CP_PT>
 </PQHEEO5>  */

 OPEN csr_annexes( l_report_date , p_business_group_id);
 FETCH csr_annexes INTO l_count_annexes;
 CLOSE csr_annexes;

 OPEN csr_schools( p_business_group_id);
 FETCH csr_schools INTO l_count_schools;
 CLOSE csr_schools;

 l_char_report_date := '30-SEP'||'-'||p_reporting_year;

 l_xml_string := convert_into_xml('CF_NO_OF_ANNEXES',l_count_annexes,'D');
 l_xml_string := l_xml_string||convert_into_xml('CP_REPORT_DATE',l_char_report_date,'D');
 l_xml_string := l_xml_string||convert_into_xml('CP_NO_OF_SCHOOLS',l_count_schools,'D');
 --Added for bug 5404884
 l_xml_string := l_xml_string||convert_into_xml('P_TOTAL_ENROLLMENTS',p_total_enrollments,'D');
 --End of changes done for bug 5404884.
 --Added for bug 5415393
 l_xml_string := l_xml_string||convert_into_xml('DISTRICT_NAME',l_district_name,'D');
 l_xml_string := l_xml_string||convert_into_xml('DISTRICT_ID',l_district_id,'D');
 --End bug 5415393
 l_xml_string := l_xml_string||convert_into_xml('CP_FR','FR','D');
 l_xml_string := l_xml_string||convert_into_xml('CP_FT','FT','D');
 l_xml_string := l_xml_string||convert_into_xml('CP_PR','PR','D');
 l_xml_string := l_xml_string||convert_into_xml('CP_PT','PT','D');
 l_xml_string := l_xml_string||'</PQHEEO5>';

 write_to_concurrent_out(l_xml_string);


END generate_xml_data;


--To put the trace just uncomment the below three lines.
--BEGIN
--  hr_utility.trace_on(null,'EEO5');
--  g_debug := hr_utility.debug_enabled;
END per_us_eeo5_pkg;

/
