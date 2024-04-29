--------------------------------------------------------
--  DDL for Package Body PQH_PQIPED6_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_PQIPED6_XMLP_PKG" AS
/* $Header: PQIPED6B.pls 120.4 2008/04/17 06:29:40 amakrish noship $ */

function line1Formula return Number is
temp_num number := 19;

begin

   if line_num < 50 then
     temp_num := line_num;
     line_num:= line_num + 1;
   elsif tmp_var between 49 and 54 then
     temp_num := tmp_var;
     tmp_var := tmp_var + 1;
   elsif tmp_var1 between 54 and 61 then
     temp_num := tmp_var1;
     tmp_var1 := tmp_var1 + 1;
   else
     temp_num := tmp_var2;
     tmp_var2 := tmp_var2 + 1;
   end if;

  if line_num = 26 then
     line_num := 27;
  elsif line_num = 34 then
     line_num := 35;
  elsif line_num = 42 then
     line_num := 43;

  end if;



  return temp_num;
end;

function CF_GroupTotTitleFormula(JobCode in number) return Char is
 l_total_title	VARCHAR2(200)	:= '';
 l_job_code	Number	:= JobCode;
begin
  IF 	l_job_code =  '5' THEN
	l_total_title	:= 'Total Exec/Administrative, and Managerial (sum of lines 19-25)';
  ELSIF l_job_code 	= '6' THEN
	l_total_title	:= 'Total Other Administrative (sum of lines 27-33)';
  ELSIF l_job_code 	= '7' THEN
	l_total_title	:= 'Total Other Professionals (sum of lines 35-41)';
  ELSIF l_job_code 	= '8' THEN
	l_total_title	:= 'Total Technical and Paraprofessionals (sum of lines 43-47)';
  ELSIF l_job_code 	= '9' THEN
	l_total_title	:= 'Total Clerical and Secretarial (sum of lines 49-53)';
  ELSIF l_job_code 	= '10' THEN
	l_total_title	:= 'Total Skilled Crafts (sum of lines 55-59)';
  ELSIF l_job_code 	= '11' THEN
	l_total_title	:= 'Total Service/Maintenance (sum of lines 61-65)';
  END IF;

  return l_total_title;
end;

function cf_group_linenoformula(JobCode in number) return number is
temp_num number;
begin
   if (JobCode = 5) then
         temp_num := 26;
   elsif (JobCode = 6) then
         temp_num := 34;
   elsif (JobCode = 7) then
         temp_num := 42;
   elsif (JobCode = 8) then
         temp_num := 48;
   elsif (JobCode = 9) then
         temp_num := 54;
   elsif (JobCode = 10) then
         temp_num := 60;
   elsif (JobCode = 11) then
         temp_num := 66;
   end if;

  return temp_num;

end;

function BeforeReport return boolean is
l_fr	varchar2(2000);
l_ft	varchar2(2000);
l_pr	varchar2(2000);
l_pt	varchar2(2000);
l_query_text VARCHAR2(2000);
                                  line VARCHAR2(32767);
                                  sc VARCHAR2(32767);
                                  salary_range VARCHAR2(32767);
                                  l_nr_men NUMBER(10) := 0;
                                  l_nr_wmen NUMBER(10) := 0;
                                  l_bnh_men NUMBER(10) := 0;
                                  l_bnh_wmen NUMBER(10) := 0;
                                  l_amai_men NUMBER(10) := 0;
                                  l_amai_wmen NUMBER(10) := 0;
                                  l_ap_men NUMBER(10) := 0;
                                  l_ap_wmen NUMBER(10) := 0;
                                  l_h_men NUMBER(10) := 0;
                                  l_h_wmen NUMBER(10) := 0;
                                  l_wnh_men NUMBER(10) := 0;
                                  l_wnh_wmen NUMBER(10) := 0;
                                  l_ur_men NUMBER(10) := 0;
                                  l_ur_wmen NUMBER(10) := 0;
                                  l_tot_men NUMBER(10) := 0;
                                  l_tot_wmen NUMBER(10) := 0;
                                  CURSOR get_line_counts IS
                                  SELECT 1 line,
                                    hl.lookup_code job_category_name,
pqh_salary_class_intervals_pkg.get_job_sal_interval(pqh_employment_category.identify_empl_category(ass.employment_category,
cp_fr,   cp_ft,   cp_pr,   cp_pt),   hl.lookup_code,   nvl(ppp.proposed_salary_n,   0) * ppb.pay_annualization_factor) salary_range,
COUNT(decode(pqh_nr_alien_pkg.get_count_nr_alien(peo.person_id,   p_report_date),   '1',   decode(peo.sex,   'M',   1,   NULL),   NULL)) nrmen,
COUNT(decode(pqh_nr_alien_pkg.get_count_nr_alien(peo.person_id,   p_report_date),   '1',   decode(peo.sex,   'F',   1,   NULL),   NULL)) nrwmen,
COUNT(decode(pqh_nr_alien_pkg.get_count_nr_alien(peo.person_id,   p_report_date),   NULL,  (decode(peo.per_information1,   '2',   decode(peo.sex,   'M',   1,   NULL),   NULL)))) bnhmen,
COUNT(decode(pqh_nr_alien_pkg.get_count_nr_alien(peo.person_id,   p_report_date),   NULL,  (decode(peo.per_information1,   '2',   decode(peo.sex,   'F',   1,   NULL),   NULL)))) bnhwmen,
COUNT(decode(pqh_nr_alien_pkg.get_count_nr_alien(peo.person_id,   p_report_date),   NULL,  (decode(peo.per_information1,   '6',   decode(peo.sex,   'M',   1,   NULL),   NULL)))) am_almen,
COUNT(decode(pqh_nr_alien_pkg.get_count_nr_alien(peo.person_id,   p_report_date),   NULL,  (decode(peo.per_information1,   '6',   decode(peo.sex,   'F',   1,   NULL),   NULL)))) am_alwmen,
COUNT(decode(pqh_nr_alien_pkg.get_count_nr_alien(peo.person_id,   p_report_date),   NULL,  (decode(peo.per_information1,   '4',   decode(peo.sex,   'M',   1,   NULL),   '5',   decode(peo.sex,   'M',   1,   NULL),   NULL)))) a_pmen,
COUNT(decode(pqh_nr_alien_pkg.get_count_nr_alien(peo.person_id,   p_report_date),   NULL,  (decode(peo.per_information1,   '4',   decode(peo.sex,   'F',   1,   NULL),   '5',   decode(peo.sex,   'F',   1,   NULL),   NULL)))) a_pwmen,
COUNT(decode(pqh_nr_alien_pkg.get_count_nr_alien(peo.person_id,   p_report_date),   NULL,  (decode(peo.per_information1,   '3',   decode(peo.sex,   'M',   1,   NULL),   '9',   decode(peo.sex,   'M',   1,   NULL),   NULL)))) hmen,
COUNT(decode(pqh_nr_alien_pkg.get_count_nr_alien(peo.person_id,   p_report_date),   NULL,  (decode(peo.per_information1,   '3',   decode(peo.sex,   'F',   1,   NULL),   '9',   decode(peo.sex,   'F',   1,   NULL),   NULL)))) hwmen,
COUNT(decode(pqh_nr_alien_pkg.get_count_nr_alien(peo.person_id,   p_report_date),   NULL,  (decode(peo.per_information1,   '1',   decode(peo.sex,   'M',   1,   NULL),   NULL)))) wnhmen,
COUNT(decode(pqh_nr_alien_pkg.get_count_nr_alien(peo.person_id,   p_report_date),   NULL,  (decode(peo.per_information1,   '1',   decode(peo.sex,   'F',   1,   NULL),   NULL)))) wnhwmen,
COUNT(decode(pqh_nr_alien_pkg.get_count_nr_alien(peo.person_id,   p_report_date),   NULL,  (decode(peo.per_information1,   NULL,   decode(peo.sex,   'M',   1,   NULL),   NULL)),   NULL)) urmen,
COUNT(decode(pqh_nr_alien_pkg.get_count_nr_alien(peo.person_id,   p_report_date),   NULL,  (decode(peo.per_information1,   NULL,   decode(peo.sex,   'F',   1,   NULL),   NULL)),   NULL)) urwmen
FROM per_all_people_f peo,
  per_all_assignments_f ass,
  per_assignment_status_types ast,
  per_jobs job,
  per_pay_proposals ppp,
  per_pay_bases ppb,
  hr_lookups hl
WHERE peo.person_id = ass.person_id
 AND peo.current_employee_flag = 'Y'
 AND hl.lookup_code = job.job_information8
 AND job.job_information8 NOT IN('1',   '2',   '3',   '4')
 AND pqh_employment_category.identify_empl_category(ass.employment_category,   cp_fr,   cp_ft,   cp_pr,   cp_pt) IN('FR')
 AND ppp.change_date =
  (SELECT MAX(change_date)
   FROM per_pay_proposals PRO
  WHERE ppp.assignment_id = PRO.ASSIGNMENT_ID
  AND PRO.CHANGE_DATE <= P_REPORT_DATE
  AND PRO.APPROVED = 'Y' )
  AND ass.pay_basis_id = ppb.pay_basis_id
   AND ass.assignment_id = ppp.assignment_id
   AND nvl(ppp.proposed_salary_n,    0) * ppb.pay_annualization_factor > 0
   AND hl.lookup_type = 'US_IPEDS_JOB_CATEGORIES'
   AND job.job_information_category = 'US'
   AND p_report_date BETWEEN peo.effective_start_date
   AND peo.effective_end_date
   AND p_report_date BETWEEN ass.effective_start_date
   AND ass.effective_end_date
   AND ass.primary_flag = 'Y'
   AND ass.assignment_status_type_id = ast.assignment_status_type_id
   AND ast.per_system_status <> 'TERM_ASSIGN'
   AND ass.job_id = job.job_id
   AND ass.assignment_type = 'E'
   AND ass.organization_id IN
    (SELECT org.organization_id
     FROM hr_all_organization_units org
     WHERE business_group_id = p_business_group_id
     AND pqh_inst_type_pkg.get_inst_type(org.organization_id) = 'NON-MED')
  GROUP BY
  pqh_salary_class_intervals_pkg.get_job_sal_interval(pqh_employment_category.identify_empl_category(ass.employment_category,
  cp_fr,    cp_ft,    cp_pr,    cp_pt),    hl.lookup_code,    nvl(ppp.proposed_salary_n,    0) * ppb.pay_annualization_factor),
     hl.lookup_code;
CURSOR get_line_tmraces_counts(c_salary_range IN VARCHAR2,    c_lookup_code IN NUMBER) IS
SELECT COUNT(decode(pei.pei_information5,    '2',    decode(peo.sex,    'M',    1,    NULL),    NULL)) bnhmen,
COUNT(decode(pei.pei_information5,    '2',    decode(peo.sex,    'F',    1,    NULL),    NULL)) bnhwmen,
COUNT(decode(pei.pei_information5,    '6',    decode(peo.sex,    'M',    1,    NULL),    NULL)) am_almen,
COUNT(decode(pei.pei_information5,    '6',    decode(peo.sex,    'F',    1,    NULL),    NULL)) am_alwmen,
COUNT(decode(pei.pei_information5,    '4',    decode(peo.sex,    'M',    1,    NULL),    '5',    decode(peo.sex,    'M',    1,    NULL),    NULL)) a_pmen,
COUNT(decode(pei.pei_information5,    '4',    decode(peo.sex,    'F',    1,    NULL),    '5',    decode(peo.sex,    'F',    1,    NULL),    NULL)) a_pwmen,
COUNT(decode(pei.pei_information5,    '3',    decode(peo.sex,    'M',    1,    NULL),    '9',    decode(peo.sex,    'M',    1,    NULL),    NULL)) hmen,
COUNT(decode(pei.pei_information5,    '3',    decode(peo.sex,    'F',    1,    NULL),    '9',    decode(peo.sex,    'F',    1,    NULL),    NULL)) hwmen,
COUNT(decode(pei.pei_information5,    '1',    decode(peo.sex,    'M',    1,    NULL),    NULL)) wnhmen,
COUNT(decode(pei.pei_information5,    '1',    decode(peo.sex,    'F',    1,    NULL),    NULL)) wnhwmen,
COUNT(decode(pei.pei_information5,    NULL,    decode(peo.sex,    'M',    1,    NULL),    NULL)) urmen,
COUNT(decode(pei.pei_information5,    NULL,    decode(peo.sex,    'F',    1,    NULL),    NULL)) urwmen
  FROM per_all_people_f peo,
    per_all_assignments_f ass,
    per_assignment_status_types ast,
    per_jobs job,
    per_pay_proposals ppp,
    per_pay_bases ppb,
    hr_lookups hl,
    per_people_extra_info pei
  WHERE peo.person_id = ass.person_id
  AND peo.current_employee_flag = 'Y'
  AND peo.per_information1 = '13'
  AND peo.person_id = pei.person_id(+)
  AND(pei.information_type = 'PER_US_ADDL_ETHNIC_CAT' OR(pei.information_type <> 'PER_US_ADDL_ETHNIC_CAT'
  AND NOT EXISTS
   (SELECT 1
    FROM per_people_extra_info pei2
    WHERE pei2.information_type = 'PER_US_ADDL_ETHNIC_CAT'
    AND pei2.person_id = pei.person_id)
    AND pei.person_extra_info_id =
     (SELECT MAX(pei1.person_extra_info_id)
      FROM per_people_extra_info pei1
      WHERE pei1.person_id = pei.person_id))
   OR(NOT EXISTS
     (SELECT person_extra_info_id
      FROM per_people_extra_info pei3
      WHERE pei3.person_id = pei.person_id))
   )
 AND hl.lookup_code = job.job_information8
  AND job.job_information8 NOT IN('1',    '2',    '3',    '4')
  AND pqh_employment_category.identify_empl_category(ass.employment_category,    cp_fr,    cp_ft,    cp_pr,    cp_pt) IN('FR')
  AND ppp.change_date =
   (SELECT MAX(change_date)
    FROM per_pay_proposals PRO
   WHERE ppp.assignment_id = PRO.ASSIGNMENT_ID
   AND PRO.CHANGE_DATE <= P_REPORT_DATE
   AND PRO.APPROVED = 'Y' )
   AND ass.pay_basis_id = ppb.pay_basis_id
    AND ass.assignment_id = ppp.assignment_id
    AND nvl(ppp.proposed_salary_n,    0) * ppb.pay_annualization_factor > 0
    AND hl.lookup_type = 'US_IPEDS_JOB_CATEGORIES'
    AND job.job_information_category = 'US'
    AND p_report_date BETWEEN peo.effective_start_date
    AND peo.effective_end_date
    AND p_report_date BETWEEN ass.effective_start_date
    AND ass.effective_end_date
    AND ass.primary_flag = 'Y'
    AND ass.assignment_status_type_id = ast.assignment_status_type_id
    AND ast.per_system_status <> 'TERM_ASSIGN'
    AND ass.job_id = job.job_id
    AND ass.assignment_type = 'E'
    AND ass.organization_id IN
     (SELECT org.organization_id
     FROM hr_all_organization_units org
     WHERE business_group_id = p_business_group_id
     AND pqh_inst_type_pkg.get_inst_type(org.organization_id) = 'NON-MED')
  AND pqh_salary_class_intervals_pkg.get_job_sal_interval(pqh_employment_category.identify_empl_category(ass.employment_category,    cp_fr,    cp_ft,    cp_pr,    cp_pt),    hl.lookup_code,
	 nvl(ppp.proposed_salary_n,    0) * ppb.pay_annualization_factor) = c_salary_range
   AND hl.lookup_code = c_lookup_code;

begin
   --hr_standard.event('BEFORE REPORT');
   LP_REPORT_DATE := to_Char(P_REPORT_DATE,'DD-MON-YYYY');

   pqh_employment_category.fetch_empl_categories(p_business_group_id,l_fr,l_ft,l_pr,l_pt);

   	cp_fr  := l_fr;
	cp_ft	:= l_ft;
	cp_pr	:= l_pr;
	cp_pt	:= l_pt;
FOR i IN get_line_counts
 LOOP
   line := i.line;
   sc := i.job_category_name;
   salary_range := i.salary_range;
   l_nr_men := i.nrmen;
   l_nr_wmen := i.nrwmen;
   l_bnh_men := i.bnhmen;
   l_bnh_wmen := i.bnhwmen;
   l_amai_men := i.am_almen;
   l_amai_wmen := i.am_alwmen;
   l_ap_men := i.a_pmen;
   l_ap_wmen := i.a_pwmen;
   l_h_men := i.hmen;
   l_h_wmen := i.hwmen;
   l_wnh_men := i.wnhmen;
   l_wnh_wmen := i.wnhwmen;
   l_ur_men := i.urmen;
   l_ur_wmen := i.urwmen;
   l_tot_men := l_nr_men + l_bnh_men + l_amai_men + l_ap_men + l_h_men + l_wnh_men + l_ur_men;
   l_tot_wmen := l_nr_wmen + l_bnh_wmen + l_amai_wmen + l_ap_wmen + l_h_wmen + l_wnh_wmen + l_ur_wmen;
   FOR j IN get_line_tmraces_counts(salary_range,sc)
    LOOP
     l_bnh_men := l_bnh_men + j.bnhmen;
     l_bnh_wmen := l_bnh_wmen + j.bnhwmen;
     l_amai_men := l_amai_men + j.am_almen;
     l_amai_wmen := l_amai_wmen + j.am_alwmen;
     l_ap_men := l_ap_men + j.a_pmen;
     l_ap_wmen := l_ap_wmen + j.a_pwmen;
     l_h_men := l_h_men + j.hmen;
     l_h_wmen := l_h_wmen + j.hwmen;
     l_wnh_men := l_wnh_men + j.wnhmen;
     l_wnh_wmen := l_wnh_wmen + j.wnhwmen;
     l_ur_men := l_ur_men + j.urmen;
     l_ur_wmen := l_ur_wmen + j.urwmen;
     l_tot_men := l_tot_men + j.bnhmen + j.am_almen + j.a_pmen + j.hmen + j.wnhmen + j.urmen;
     l_tot_wmen := l_tot_wmen + j.bnhwmen + j.am_alwmen + j.a_pwmen + j.hwmen + j.wnhwmen + j.urwmen;
   END LOOP;

   INSERT
    INTO pay_us_rpt_totals(session_id,    attribute1,    attribute2,    value1,    value2,    value3,    value4,
	   value5,    value6,    value7,    value8,    value9,    value10,    value11,    value12,    value13,    value14,    value15,    value16,    value17,    value18)
    VALUES(userenv('sessionid'),    'IPED6',    salary_range,    line,    sc,
	   l_nr_men,    l_nr_wmen,    l_bnh_men,    l_bnh_wmen,    l_amai_men,    l_amai_wmen,    l_ap_men,    l_ap_wmen,    l_h_men,    l_h_wmen,    l_wnh_men,
	   l_wnh_wmen,    l_ur_men,    l_ur_wmen,    l_tot_men,    l_tot_wmen);
   COMMIT;
 END LOOP;

   return true;
end;

function AfterReport return boolean is
begin
  --hr_standard.event('AFTER REPORT');
EXECUTE IMMEDIATE 'DELETE FROM pay_us_rpt_totals
                    WHERE attribute1 = ''IPED6''';
  return (TRUE);
end;

--Functions to refer Oracle report placeholders--

 Function line_num_p return number is
	Begin
	 return line_num;
	 END;
 Function CP_FR_p return varchar2 is
	Begin
	 return CP_FR;
	 END;
 Function CP_FT_p return varchar2 is
	Begin
	 return CP_FT;
	 END;
 Function CP_PR_p return varchar2 is
	Begin
	 return CP_PR;
	 END;
 Function CP_PT_p return varchar2 is
	Begin
	 return CP_PT;
	 END;
 Function CP_lastLineNo_p return number is
	Begin
	 return CP_lastLineNo;
	 END;
 Function CP_ReportTotTitle_p return varchar2 is
	Begin
	 return CP_ReportTotTitle;
	 END;
 Function tmp_var_p return number is
	Begin
	 return tmp_var;
	 END;
 Function tmp_var1_p return number is
	Begin
	 return tmp_var1;
	 END;
 Function tmp_var2_p return number is
	Begin
	 return tmp_var2;
	 END;
END PQH_PQIPED6_XMLP_PKG ;

/
