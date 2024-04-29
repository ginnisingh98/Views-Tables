--------------------------------------------------------
--  DDL for Package Body PER_US_EEO4_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_US_EEO4_PKG" AS
/* $Header: peruseeo4.pkb 120.5.12010000.5 2009/10/09 10:09:29 lbodired ship $ */
/*
   ******************************************************************
   *                                                                *
   *  Copyright (C) 1993 Oracle Corporation.                        *
   *  All rights reserved.                                          *
   *                                                                *
   *  This material has been provided pursuant to an agreement      *
   *  containing restrictions on its use.  The material is also     *
   *  protected by copyright law.  No part of this material may     *
   *  be copied or distributed, transmitted or transcribed, IN      *
   *  any form or by any means, electronic, mechanical, magnetic,   *
   *  manual, or otherwise, or disclosed to third parties without   *
   *  the express written permission of Oracle Corporation,         *
   *  500 Oracle Parkway, Redwood City, CA, 94065.                  *
   *                                                                *
   ******************************************************************

    Name        : PER_US_EEO4_PKG

    Description : This package is used by 'EEO4 Report (XML)' concurrent
                  program.

    Change List
    -----------
    Date                 Name       Vers     Bug No    Description
    -----------       ---------- ------    -------     --------------------------
    27-JUN-2006 rpasumar   115.0                   Created.
    19-JUL-2006 rpasumar    115.1                   Fixed GSCC Errors.
    21-JUL-2006 rpasumar    115.2   5402332  Fixed Issues 13 and 22.
    26-JUL-2006 rpasumar    115.3   5410233  Reset the g_line_number for each report.
                                                         5410130  Commented out the code which populates
				                                          the functions into first order table
					                                  for the condition full time emp count
					                                  > 999.
			                                5397638    Commented out the code which populates
							    	          the functions into first order table
					                                  for the condition number of emp for
					                                  function > 99.
    28-JUL-2006 rpasumar    115.4  5415136    Added the function get_function_number
                                                                         and generated XML for control number
					                                 and function numbers (1-15).
				                       5409988    Added the function check_function to
				                                         check appropriate function check box.
    31-JUL-2006 rpasumar   115.5  5415136     Removed the reporting type EEO4 condition
                                                                          in get_cert_details cursor of
					                                  generate_juris_cert_xml_data procedure.
    31-JUL-2006 rpasumar   115.6  5414756     Modified the procedure generate_sql and
                                                                          populate_ft_emp_data to handle the salaries
					                                  more than 70000 per annum.
    01-AUG-2006 rpasumar 115.7  5437076      To generate XML when there are no functions.
    07-AUG-2006 rpasumar 115.8                      To display correct function numbers.
    08-JUN-2007  rpasumar  115.9  5593259      To fetch ethnic code from per_people_extra_info table
                                                                            for the persons whose ethnic code is Two or more races.
    15-JUL-2007   rpasumar  115.9   6200441      Modified not to report employees whose ethnic origin is
                                                                             blank or whose ethnic origin is 'Two or more races' and
									     additional ethnic category is blank.
    28-AUG-2009  lbodired  115.14   8812609     Modified the API 'populate_ft_emp_data' to correct the salary ranges
    18-SEP-2009  lbodired  115.15   7218995     Replaced the hard coded employee categories with the categories
                           115.16 115.17       getting from the API 'pqh.employment_category.fetch_empl_categories'
    ****************************************************************************/

    -- Added for bug 7218995
    g_fp_regulars VARCHAR2(2000);
    g_fp_temps VARCHAR2(2000);

    l_xml_string     VARCHAR2(32767);

    l_query_text VARCHAR2(32767);

    g_select_clause VARCHAR2(10000);
    g_from_where_clause VARCHAR2(10000);
    g_ft_effective_dates VARCHAR2(1000);
    g_nh_effective_dates VARCHAR2(1000);
    g_group_order_by VARCHAR2(1000) := ' GROUP BY hl.lookup_code,hl.meaning
			                 ORDER BY hl.lookup_code,hl.meaning';
    g_nh_sql VARCHAR2(32767);
    g_ft_emp_sql VARCHAR2(32767);
    g_oft_sql VARCHAR2(32767);

    --Bug# 5593259
    g_tmraces_select_clause VARCHAR2(10000);
    g_tmraces_where_clause VARCHAR2(10000);

    g_tmr_nh_sql VARCHAR2(32767);
    g_tmr_ft_emp_sql VARCHAR2(32767);
    g_tmr_oft_sql VARCHAR2(32767);

    g_business_group_id VARCHAR2(32767);

    -- Bug# 5415136
    g_control_number VARCHAR2(1000);
    g_function_numbers VARCHAR2(1000);

    g_salary_range VARCHAR2(30);
    g_start_salary NUMBER := 0;
    g_end_salary NUMBER := 0;
    g_lookup_code VARCHAR2(30) := ' ';
    g_meaning VARCHAR2(80) := ' ';

    g_for_all_emp VARCHAR2(1) := 'F';

    g_job_code VARCHAR2(4000) := ' ''XX'' ';
    g_func_desc VARCHAR2(4000);

    g_dynamic_where VARCHAR2(4000) := ' ''XX'' ';
    g_line_number NUMBER := 0 ;

    l_counter1 NUMBER := 0;
    l_counter2 NUMBER := 0;
    l_counter3 NUMBER := 0;

    l_function_code VARCHAR2(32767);

     -- DBMS Cursor Variables
    source_cursor INTEGER;
    rows_processed INTEGER;

    -- PL/SQL table variables
    ft_emp_table full_time_emp_data;
    other_ft_emp_table other_full_time_emp_data;
    new_hire_table new_hire_emp_data;

    -- Functions whose data to be displayed first
    first_order_func_table function_data;
    -- Functions whose data to be displayed later
    second_order_func_table function_data;
    -- All functions to populate data
    func_table function_data;


  -- variables to hold total number of employees in each category (65th line)
   /*****************************************************************************
   Name      : convert_into_xml
   Purpose   : function to convert the data into an XML String
  *****************************************************************************/

  FUNCTION convert_into_xml( p_name  IN VARCHAR2,
                             p_value IN VARCHAR2,
                             p_type  IN char)
  RETURN VARCHAR2 IS

    l_convert_data VARCHAR2(32767);

  BEGIN

    IF p_type = 'D' THEN

       l_convert_data := '<'||p_name||'>'||p_value||'</'||p_name||'>';

    ELSE

       l_convert_data := '<'||p_name||'>';

    END IF;

    RETURN(l_convert_data);

  END convert_into_xml;

  /*****************************************************************************
   Name      : get_lookup_meaning
   Purpose   : To display the meaning of job categories on the report.
  *****************************************************************************/

  FUNCTION get_lookup_meaning(p_emp_category IN NUMBER, p_lookup_code IN NUMBER)
  RETURN VARCHAR2 IS
  l_meaning VARCHAR2(80);

  BEGIN
  IF p_lookup_code = 2 THEN
    l_meaning := 'PROFESSIONALS';
  ELSIF p_lookup_code = 3 THEN
    l_meaning := 'TECHNICIANS';
  ELSIF p_lookup_code = 4 THEN
    l_meaning := 'PROTECTIVE SERVICE';
  ELSIF p_lookup_code = 5 THEN
  -- Bug# 5402332 (Issue 22)
    IF p_emp_category = 1 THEN
          l_meaning := 'PARA-PROFESSIONALS';
        ELSE
          l_meaning := 'PARA-PROFESSIONAL';
        END IF;
  ELSIF p_lookup_code = 1 THEN
        IF p_emp_category = 1 THEN
          l_meaning := 'OFFICIALS ADMINISTRATORS';
        ELSE
          l_meaning := 'OFFICIALS/ADMIN';
        END IF;
  ELSIF p_lookup_code = 6 THEN
        IF p_emp_category = 1 THEN
          l_meaning := 'ADMINISTRATIVE SUPPORT';
        ELSE
          l_meaning := 'ADMIN.SUPPORT';
        END IF;
  ELSIF p_lookup_code = 7 THEN
        IF p_emp_category = 1 THEN
          l_meaning := 'SKILLEDCRAFT';
        ELSE
          l_meaning := 'SKILLED CRAFT';
        END IF;
  ELSIF p_lookup_code = 8 THEN
        IF p_emp_category = 1 THEN
          l_meaning := 'SERVICE MAINTENANCE';
        ELSE
          l_meaning := 'SERVICE/MAINTENANCE';
        END IF;
  END IF;

  RETURN l_meaning;
  END get_lookup_meaning;

  -- Added this method for the Bug# 5409988

  /*****************************************************************************
   Name      : check_function
   Purpose   : To generate XML for those functions which have to be checked
               in the first page of the report.
  *****************************************************************************/
  PROCEDURE check_function(p_function_code IN NUMBER) IS
  BEGIN
	IF p_function_code = 10 THEN
		l_xml_string := convert_into_xml('G_FUN_1_CHECK_VAL','true','D');
	ELSIF p_function_code = 20 THEN
		l_xml_string := convert_into_xml('G_FUN_2_CHECK_VAL','true','D');
	ELSIF p_function_code = 30 THEN
		l_xml_string := convert_into_xml('G_FUN_3_CHECK_VAL','true','D');
	ELSIF p_function_code = 40 THEN
		l_xml_string := convert_into_xml('G_FUN_4_CHECK_VAL','true','D');
	ELSIF p_function_code = 50 THEN
		l_xml_string := convert_into_xml('G_FUN_5_CHECK_VAL','true','D');
	ELSIF p_function_code = 60 THEN
		l_xml_string := convert_into_xml('G_FUN_6_CHECK_VAL','true','D');
	ELSIF p_function_code = 70 THEN
		l_xml_string := convert_into_xml('G_FUN_7_CHECK_VAL','true','D');
	ELSIF p_function_code = 80 THEN
		l_xml_string := convert_into_xml('G_FUN_8_CHECK_VAL','true','D');
	ELSIF p_function_code = 90 THEN
		l_xml_string := convert_into_xml('G_FUN_9_CHECK_VAL','true','D');
	ELSIF p_function_code = 100 THEN
		l_xml_string := convert_into_xml('G_FUN_10_CHECK_VAL','true','D');
	ELSIF p_function_code = 110 THEN
		l_xml_string := convert_into_xml('G_FUN_11_CHECK_VAL','true','D');
	ELSIF p_function_code = 120 THEN
		l_xml_string := convert_into_xml('G_FUN_12_CHECK_VAL','true','D');
	ELSIF p_function_code = 130 THEN
		l_xml_string := convert_into_xml('G_FUN_13_CHECK_VAL','true','D');
	ELSIF p_function_code = 140 THEN
		l_xml_string := convert_into_xml('G_FUN_14_CHECK_VAL','true','D');
	ELSIF p_function_code = 150 THEN
		l_xml_string := convert_into_xml('G_FUN_15_CHECK_VAL','true','D');
	END IF;

        --FND_FILE.PUT_LINE(FND_FILE.LOG,l_xml_string);
	FND_FILE.PUT_LINE(FND_FILE.OUTPUT,l_xml_string);
  END check_function;

  -- Added Bug# 5415136
  /*****************************************************************************
   Name      : get_function_number
   Purpose   : To return the function number with the function code as input.
  *****************************************************************************/
  FUNCTION get_function_number(p_function_code IN NUMBER)
  RETURN NUMBER IS
  l_function_number NUMBER := 0;
  BEGIN
	IF p_function_code = 10 THEN
		l_function_number := 1;
	ELSIF p_function_code = 20 THEN
		l_function_number := 2;
	ELSIF p_function_code = 30 THEN
		l_function_number := 3;
	ELSIF p_function_code = 40 THEN
		l_function_number := 4;
	ELSIF p_function_code = 50 THEN
		l_function_number := 5;
	ELSIF p_function_code = 60 THEN
		l_function_number := 6;
	ELSIF p_function_code = 70 THEN
		l_function_number := 7;
	ELSIF p_function_code = 80 THEN
		l_function_number := 8;
	ELSIF p_function_code = 90 THEN
		l_function_number := 9;
	ELSIF p_function_code = 100 THEN
		l_function_number := 10;
	ELSIF p_function_code = 110 THEN
		l_function_number := 11;
	ELSIF p_function_code = 120 THEN
		l_function_number := 12;
	ELSIF p_function_code = 130 THEN
		l_function_number := 13;
	ELSIF p_function_code = 140 THEN
		l_function_number := 14;
	ELSIF p_function_code = 150 THEN
		l_function_number := 15;
	END IF;
	RETURN l_function_number;
  END get_function_number;



 /*****************************************************************************
   Name      : write_to_concurrent_out
   Purpose   : writes to concurrent ouput.
  *****************************************************************************/
  PROCEDURE write_to_concurrent_out (p_text VARCHAR2) IS
  --
  BEGIN
    -- Write to the concurrent request log
    --fnd_file.put_line(fnd_file.log, p_text);
    -- Write to the concurrent request out
    fnd_file.put_line(fnd_file.OUTPUT, p_text);

  END write_to_concurrent_out;

PROCEDURE generate_sql(p_job_codes IN VARCHAR2 , p_dynamic_where IN VARCHAR2) IS
BEGIN
  g_nh_sql := 'SELECT   hl.lookup_code  job_category_code,
                        hl.meaning	job_category_name,'
                   || g_select_clause || g_from_where_clause || g_nh_effective_dates
                   ||' AND job.job_information7 in (' || p_job_codes || ')'
                   ||' AND hl.lookup_code = :1 '
                --   ||' AND  ass.employment_category in (''FR'')'
		 ||' AND  ass.employment_category in ('|| g_fp_regulars ||')'
		|| g_group_order_by;

  --FND_FILE.PUT_LINE(FND_FILE.LOG,'g_nh_sql: '|| g_nh_sql);

  g_ft_emp_sql := 'SELECT hl.lookup_code      job_category_code,
                          hl.meaning	      job_category_name,'
                  ||g_select_clause || g_from_where_clause|| g_ft_effective_dates
                  ||' AND job.job_information7 in ( ' || p_job_codes || ' ) '
                  ||' AND hl.lookup_code = :1 '
                  || p_dynamic_where
                --  ||' AND  ass.employment_category in (''FR'')'
		  ||' AND  ass.employment_category in ('|| g_fp_regulars ||')'
                  || g_group_order_by;

 --FND_FILE.PUT_LINE(FND_FILE.LOG,'g_ft_emp_sql: '|| g_ft_emp_sql);

  g_oft_sql := 'SELECT   hl.lookup_code	    job_category_code,
                         hl.meaning	    job_category_name,'
                      ||g_select_clause||g_from_where_clause||g_ft_effective_dates
                      ||' AND job.job_information7 in ( ' || p_job_codes || ' )'
                      ||' AND hl.lookup_code = :1 '
                  --    ||' AND  ass.employment_category NOT IN (''FR'')'
		  ||' AND  ass.employment_category NOT IN ('|| g_fp_regulars ||')'
                      ||g_group_order_by;

  --FND_FILE.PUT_LINE(FND_FILE.LOG,'g_oft_sql: '|| g_oft_sql);


  --Bug# 5593259
  g_tmr_nh_sql := 'SELECT   hl.lookup_code  job_category_code,
                        hl.meaning	job_category_name,'
                   || g_tmraces_select_clause || g_tmraces_where_clause || g_nh_effective_dates
                   ||' AND job.job_information7 in (' || p_job_codes || ')'
                   ||' AND hl.lookup_code = :1 '
                 --  ||' AND  ass.employment_category in (''FR'')'
		 ||' AND  ass.employment_category in ('||g_fp_regulars ||')'
		 || g_group_order_by;

--FND_FILE.PUT_LINE(FND_FILE.LOG,'g_tmr_nh_sql: '|| g_tmr_nh_sql);

  g_tmr_ft_emp_sql := 'SELECT hl.lookup_code      job_category_code,
                          hl.meaning	      job_category_name,'
                  || g_tmraces_select_clause || g_tmraces_where_clause|| g_ft_effective_dates
                  ||' AND job.job_information7 in ( ' || p_job_codes || ' ) '
                  ||' AND hl.lookup_code = :1 '
                  || p_dynamic_where
              --    ||' AND  ass.employment_category in (''FR'')'
	          ||' AND  ass.employment_category in ('|| g_fp_regulars ||')'
                  || g_group_order_by;

 --FND_FILE.PUT_LINE(FND_FILE.LOG,'g_tmr_ft_emp_sql: '|| g_tmr_ft_emp_sql);

  g_tmr_oft_sql := 'SELECT   hl.lookup_code	    job_category_code,
                         hl.meaning	    job_category_name,'
                      || g_tmraces_select_clause || g_tmraces_where_clause ||g_ft_effective_dates
                      ||' AND job.job_information7 in ( ' || p_job_codes || ' )'
                      ||' AND hl.lookup_code = :1 '
                   --   ||' AND  ass.employment_category NOT IN (''FR'')'
		       ||' AND  ass.employment_category NOT IN ('|| g_fp_regulars ||')'
                      ||g_group_order_by;

--FND_FILE.PUT_LINE(FND_FILE.LOG,'g_tmr_oft_sql: '|| g_tmr_oft_sql);

END generate_sql;

PROCEDURE generate_xml_data(errbuf                    OUT NOCOPY VARCHAR2
                              ,retcode                  OUT NOCOPY NUMBER
			      ,p_reporting_year         IN NUMBER
			      ,p_add_message1           IN VARCHAR2
			      ,p_add_message2           IN VARCHAR2
			      ,p_add_message3           IN VARCHAR2
			      ,p_add_message4           IN VARCHAR2
			      ,p_add_message5           IN VARCHAR2
			      ,p_add_message6           IN VARCHAR2
			      ,p_add_message7           IN VARCHAR2
			      ,p_business_group_id      IN VARCHAR2
			      ,p_full_time_emp_count    IN NUMBER
			      ,p_emp_count_for_function IN NUMBER
			      ) IS

  l_ft_emp_count NUMBER;

  l_fr VARCHAR2(2000);
  l_ft VARCHAR2(2000);
  l_pr VARCHAR2(2000);
  l_pt VARCHAR2(2000);

  l_profile_option    VARCHAR2(10);

  l_function_name     VARCHAR2(240);
  l_function_count    NUMBER := 0;
  l_function_desc     VARCHAR2(80);
  l_cur_function_desc VARCHAR2(260);

  l_report_command    VARCHAR2(500);


  l_row_count         NUMBER := 0;
  l_frc               VARCHAR2(2000);

  -- counters for PL/SQL tables
  l_counter  NUMBER := 0;
  l_fo_funct_counter NUMBER := 0;
  l_so_funct_counter NUMBER := 0;
  l_funct_counter NUMBER := 0;

  l_current_function VARCHAR2(30);
  l_cur_lookup_code VARCHAR2(30);
  l_prev_lookup_code VARCHAR2(30);
  l_function VARCHAR2(30);

  l_start_salary NUMBER;
  l_end_salary NUMBER;

  l_lookup_code VARCHAR2(30);
  l_meaning VARCHAR2(80);

   l_report_day_month VARCHAR2(20) := '30-06';
   l_report_year VARCHAR2(4) := p_reporting_year;
   l_report_date DATE := to_date(l_report_day_month || '-' || l_report_year, 'DD-MM-YYYY');

  -- Dynamic SQL Variables
  CURSOR get_eeo4_lookup_details IS
  SELECT lookup_code, meaning, description
  FROM hr_lookups
  WHERE lookup_type = 'US_EEO4_JOB_CATEGORIES'
  ORDER BY lookup_code;

  CURSOR func_desc_cur(l_lookup_code VARCHAR) IS
  SELECT meaning
  FROM hr_lookups
  WHERE lookup_type = 'US_EEO4_JOB_FUNCTIONS'
  AND lookup_code = l_lookup_code;

  BEGIN

  g_business_group_id := p_business_group_id;

  g_select_clause := ' count(decode(peo.per_information1,''1'',decode(peo.sex,''M'',1,null),null)) no_cons_wmale_emps,
                                count(decode(peo.per_information1,''2'',decode(peo.sex,''M'',1,null),null)) no_cons_bmale_emps,
                                count(decode(peo.per_information1,''3'',decode(peo.sex,''M'',1,null),null)) no_cons_hmale_emps,
                                count(decode(peo.per_information1,''4'',decode(peo.sex,''M'',1,null),''5'',decode(peo.sex,''M'',1,null),null)) no_cons_amale_emps,
                                count(decode(peo.per_information1,''6'',decode(peo.sex,''M'',1,null),null)) no_cons_imale_emps,
                                count(decode(peo.per_information1,''1'',decode(peo.sex,''F'',1,null),null)) no_cons_wfemale_emps,
                                count(decode(peo.per_information1,''2'',decode(peo.sex,''F'',1,null),null)) no_cons_bfemale_emps,
                                count(decode(peo.per_information1,''3'',decode(peo.sex,''F'',1,null),null)) no_cons_hfemale_emps,
                                count(decode(peo.per_information1,''4'',decode(peo.sex,''F'',1,null),''5'',decode(peo.sex,''F'',1,null),null)) no_cons_afemale_emps,
                                count(decode(peo.per_information1,''6'',decode(peo.sex,''F'',1,null),null)) no_cons_ifemale_emps ';

  g_from_where_clause := ' FROM per_all_people_f             	peo,
                              per_all_assignments_f        	ass,
                              per_assignment_status_types       past,
                              per_pay_proposals		        ppp,
                              per_jobs                      	job,
                              per_pay_bases			ppb,
                              hr_lookups			hl
                            WHERE peo.person_id = ass.person_id
                            AND	ass.pay_basis_id = ppb.pay_basis_id
                            AND	ass.assignment_id = ppp.assignment_id
                            AND	hl.lookup_code = job.job_information1
                            AND	job.job_information1 IS NOT NULL
                            AND job.job_information_category = ''US''
                            AND	hl.lookup_type = ''US_EEO4_JOB_CATEGORIES''
                            AND ass.job_id = job.job_id
                            AND ass.primary_flag = ''Y''
                            AND	ppp.change_date	= ( SELECT  MAX(change_date)
                                                    FROM	per_pay_proposals  pro
                                                    WHERE	ppp.assignment_id = pro.assignment_id
                                                    AND	pro.change_date <= ''' || to_char(l_report_date) || '''
                                                    AND     pro.approved = ''Y'' )
                            AND ass.organization_id IN (SELECT	organization_id
                                                        FROM	hr_all_organization_units
                                                        WHERE	business_group_id = ' || p_business_group_id || '
                                                        AND	SYSDATE BETWEEN  date_from AND NVL(date_to,SYSDATE) )
                            AND	ass.assignment_status_type_id = past.assignment_status_type_id
                            AND peo.current_employee_flag = ''Y''
                            AND ass.assignment_type = ''E''';

--Bug# 5593259
  g_tmraces_select_clause := ' count(decode(pei.pei_information5,''1'',decode(peo.sex,''M'',1,null),null)) no_tmraces_wmale_emps,
                                              count(decode(pei.pei_information5,''2'',decode(peo.sex,''M'',1,null),null)) no_tmraces_bmale_emps,
                                              count(decode(pei.pei_information5,''3'',decode(peo.sex,''M'',1,null),''9'',decode(peo.sex,''M'',1,null),null)) no_tmraces_hmale_emps,
                                              count(decode(pei.pei_information5,''4'',decode(peo.sex,''M'',1,null),''5'',decode(peo.sex,''M'',1,null),null)) no_tmraces_amale_emps,
                                              count(decode(pei.pei_information5,''6'',decode(peo.sex,''M'',1,null),null)) no_tmraces_imale_emps,
                                              count(decode(pei.pei_information5,''1'',decode(peo.sex,''F'',1,null),null)) no_tmraces_wfemale_emps,
                                              count(decode(pei.pei_information5,''2'',decode(peo.sex,''F'',1,null),null)) no_tmraces_bfemale_emps,
                                              count(decode(pei.pei_information5,''3'',decode(peo.sex,''F'',1,null),''9'',decode(peo.sex,''F'',1,null),null)) no_tmraces_hfemale_emps,
                                              count(decode(pei.pei_information5,''4'',decode(peo.sex,''F'',1,null),''5'',decode(peo.sex,''F'',1,null),null)) no_tmraces_afemale_emps,
                                              count(decode(pei.pei_information5,''6'',decode(peo.sex,''F'',1,null),null)) no_tmraces_ifemale_emps';


  g_tmraces_where_clause := '  FROM per_all_people_f peo,
                              per_all_assignments_f        	         ass,
                              per_assignment_status_types       past,
                              per_pay_proposals		        ppp,
                              per_jobs                      	        job,
                              per_pay_bases			        ppb,
                              hr_lookups			                hl,
			      per_people_extra_info                pei
                            WHERE peo.person_id = ass.person_id
			    AND      peo.per_information1 = ''13''
			     AND     peo.person_id = pei.person_id(+)
			     AND     pei.information_type = ''PER_US_ADDL_ETHNIC_CAT''
			     AND     pei.pei_information5 is not null
                            AND	   ass.pay_basis_id = ppb.pay_basis_id
                            AND	   ass.assignment_id = ppp.assignment_id
                            AND	   hl.lookup_code = job.job_information1
                            AND	   job.job_information1 IS NOT NULL
                            AND       job.job_information_category = ''US''
                            AND	   hl.lookup_type = ''US_EEO4_JOB_CATEGORIES''
                            AND       ass.job_id = job.job_id
                            AND       ass.primary_flag  = ''Y''
                            AND	   ppp.change_date = ( SELECT  MAX(change_date)
                                                                            FROM	per_pay_proposals  pro
                                                                            WHERE	ppp.assignment_id = pro.assignment_id
                                                                             AND	pro.change_date <= ''' || to_char(l_report_date) || '''
                                                                             AND     pro.approved = ''Y'' )
                            AND ass.organization_id IN (SELECT	organization_id
                                                                          FROM	hr_all_organization_units
                                                                          WHERE	business_group_id = ' || p_business_group_id || '
                                                                           AND	SYSDATE BETWEEN  date_from AND NVL(date_to,SYSDATE) )
                            AND	ass.assignment_status_type_id = past.assignment_status_type_id
                            AND peo.current_employee_flag = ''Y''
                            AND ass.assignment_type = ''E''';

  l_query_text := 'select count(1) l_ft_emp_count ' || g_from_where_clause
                  || g_ft_effective_dates || ' AND  ass.employment_category in (''FR'')';


  -- Status and Hire/Fire condition for Full-Time employees
  -- different from New-Hires.

  g_ft_effective_dates := ' AND 	''' || to_char(l_report_date) || ''' BETWEEN peo.effective_start_date AND peo.effective_end_date
                            AND	''' || to_char(l_report_date) || ''' BETWEEN ass.effective_start_date AND ass.effective_end_date
                            AND     past.per_system_status <> ''TERM_ASSIGN''';
  -- Not a terminated assignment.
  --condition for checking that the assignment status not corresponds to TERM_ASSIGN

  --criteria for deriving new-hire records modified by kgowripe
  g_nh_effective_dates := '  AND 	''' || to_char(l_report_date) || ''' BETWEEN peo.effective_start_date AND peo.effective_end_date
                                         AND	''' || to_char(l_report_date) || ''' BETWEEN ass.effective_start_date AND ass.effective_end_date
                                         AND (SELECT date_start
                                         FROM   per_periods_of_service
                                         WHERE  period_of_service_id = ass.period_of_service_id) BETWEEN ''' || to_char(add_months(l_report_date,   -12) + 1) || ''' AND ''' || to_char(l_report_date) || ''' ';

  -- write Header line

  -- Fetch the list of employment categories
  pqh_employment_category.fetch_empl_categories(p_business_group_id, l_fr, l_ft, l_pr, l_pt);

   -- Added for bug 7218995
   g_fp_regulars := replace(replace(l_fr,'''',''''),',',''',''');
   g_fp_temps    := replace(replace(l_ft,'''',''''),',',''',''')||',' ||replace(replace(l_pt,'''',''''),',',''',''') ||',' ||replace(replace(l_pr,'''',''''),',',''',''');

  source_cursor := dbms_sql.open_cursor;
  dbms_sql.parse(source_cursor,l_query_text,1);
  dbms_sql.define_column(source_cursor,1,l_ft_emp_count);

  rows_processed := dbms_sql.EXECUTE(source_cursor);

  IF dbms_sql.fetch_rows(source_cursor) > 0 THEN
    dbms_sql.column_value(source_cursor,   1,   l_ft_emp_count);
    --FND_FILE.PUT_LINE(FND_FILE.LOG,'l_ft_emp_count: ' || l_ft_emp_count);

  END IF;

  dbms_sql.close_cursor(source_cursor);

  l_query_text := 'Select job.job_information7  l_function_code,
                   count(1) l_function_count ' || g_from_where_clause || g_ft_effective_dates || ' group by job.job_information7 ';
  --FND_FILE.PUT_LINE(FND_FILE.LOG,'l_query_text: '||l_query_text);
  source_cursor := dbms_sql.open_cursor;
  dbms_sql.parse(source_cursor,l_query_text,2);
  dbms_sql.define_column_char(source_cursor,1,l_function_code,30);
  dbms_sql.define_column(source_cursor,2,l_function_count);
  rows_processed := dbms_sql.EXECUTE(source_cursor);

  LOOP
    IF dbms_sql.fetch_rows(source_cursor) > 0 THEN
      dbms_sql.column_value_char(source_cursor,1,l_function_code);
      dbms_sql.column_value(source_cursor,2,l_function_count);
      l_function_code := RTRIM(l_function_code);

      -- Fetch the function description
      IF l_function_code IS NOT NULL THEN

          OPEN func_desc_cur(l_function_code);
          FETCH func_desc_cur INTO l_function_desc;
          CLOSE func_desc_cur;

          /* If full time employee count is more than 999 Then
             a) Populate first_order_func_table, for first 14 functions
             b) Populate second_order_func_table for the rest
          */

            IF (l_ft_emp_count >= p_full_time_emp_count AND l_row_count <= 14) THEN
              --FND_FILE.PUT_LINE(FND_FILE.LOG,' i AM IN IF (l_ft_emp_count >= p_full_time_emp_count AND l_row_count <= 14)');
              g_dynamic_where := g_dynamic_where || ',' || l_function_code;

	      -- Commented the folowing to fix the bug# 5410130
	      /*
              l_fo_funct_counter := l_fo_funct_counter + 1;
              first_order_func_table(l_fo_funct_counter).job_function := l_function_code;
              first_order_func_table(l_fo_funct_counter).description := l_function_desc;
	      */

              l_so_funct_counter := l_so_funct_counter + 1;
              second_order_func_table(l_so_funct_counter).job_function := l_function_code;
              second_order_func_table(l_so_funct_counter).description := l_function_desc;

            -- Commented the folowing to fix the bug# 5410130
	    /*
            ELSIF (l_ft_emp_count >= p_full_time_emp_count AND l_row_count > 14) THEN
              --FND_FILE.PUT_LINE(FND_FILE.LOG,' i AM IN ELSIF (l_ft_emp_count >= p_full_time_emp_count AND l_row_count > 14) THEN');
              l_fo_funct_counter := l_fo_funct_counter + 1;
              first_order_func_table(l_fo_funct_counter).job_function := l_function_code;
              first_order_func_table(l_fo_funct_counter).description := l_function_desc;
	    */

            END IF;

            /* If full time employee count is less than 1000 Then
               a) Populate first_order_func_table, if the function has more than 100 employees
               b) Populate second_order_func_table for all functions
            */
            IF (l_ft_emp_count < p_full_time_emp_count AND l_function_count >= p_emp_count_for_function) THEN
              --FND_FILE.PUT_LINE(FND_FILE.LOG,' i AM IN IF (l_ft_emp_count < p_full_time_emp_count AND l_function_count >= p_emp_count_for_function) THEN ');
              g_dynamic_where := g_dynamic_where || ',' || l_function_code;
              -- Commented the folowing to fix the bug# 5397638
	      /*
              l_fo_funct_counter := l_fo_funct_counter + 1;
              first_order_func_table(l_fo_funct_counter).job_function := l_function_code;
              first_order_func_table(l_fo_funct_counter).description := l_function_desc;
	      */
              l_so_funct_counter := l_so_funct_counter + 1;
              second_order_func_table(l_so_funct_counter).job_function := l_function_code;
              second_order_func_table(l_so_funct_counter).description := l_function_desc;
            ELSIF (l_ft_emp_count < p_full_time_emp_count AND l_function_count < p_emp_count_for_function) THEN
              --FND_FILE.PUT_LINE(FND_FILE.LOG,' i AM IN ELSIF (l_ft_emp_count < p_full_time_emp_count AND l_function_count < p_emp_count_for_function) THEN');
              l_fo_funct_counter := l_fo_funct_counter + 1;
              first_order_func_table(l_fo_funct_counter).job_function := l_function_code;
              first_order_func_table(l_fo_funct_counter).description := l_function_desc;
            END IF;
          END IF; -- IF l_function_code IS NOT NULL THEN

        l_row_count := l_row_count + 1;
      ELSE
        EXIT;
      END IF;
    END LOOP;

   dbms_sql.close_cursor(source_cursor);

   -- Bug# 5437076
   IF l_fo_funct_counter = 0 AND l_so_funct_counter = 0 THEN
	l_fo_funct_counter := l_fo_funct_counter + 1;
	first_order_func_table(l_fo_funct_counter).job_function := 'X';
        first_order_func_table(l_fo_funct_counter).description := 'X';
   END IF;

    l_current_function := ' ';

    g_job_code := '''X''';
    g_func_desc := '''X''';

    -- Populate PL/SQL tables

    FOR i IN 1 .. first_order_func_table.count LOOP -- For Each Function
        l_function := first_order_func_table(i).job_function;
        l_function_desc := first_order_func_table(i).description;
          IF l_function <> l_current_function THEN
            --FND_FILE.PUT_LINE(FND_FILE.LOG,' I am in  FOR i IN 1 .. first_order_func_table.count LOOP');
            l_current_function := l_function;

            IF g_job_code = '''X''' THEN
              g_job_code := ''''|| l_current_function ||'''';
              g_func_desc := l_function_desc;
	    ELSE
              g_job_code := g_job_code|| ', ''' ||l_current_function||'''';
              g_func_desc := g_func_desc|| ' , ' ||l_function_desc;
	    END IF;
         END IF;
    END LOOP; -- For Each Function

    --FND_FILE.PUT_LINE(FND_FILE.LOG,'g_job_code: '||g_job_code);
    --FND_FILE.PUT_LINE(FND_FILE.LOG,'g_func_desc: '||g_func_desc);

    g_for_all_emp := 'T';

    -- Bug# 5410130
    --IF g_job_code <> '''X''' THEN
	--generate_sql(g_job_code);
        --FND_FILE.PUT_LINE(FND_FILE.LOG,'g_nh_sql : '|| g_nh_sql);
	--FND_FILE.PUT_LINE(FND_FILE.LOG,'g_ft_emp_sql : ' || g_ft_emp_sql);
	--FND_FILE.PUT_LINE(FND_FILE.LOG,'g_oft_sql : ' || g_oft_sql);
	populate_ft_emp_data(g_job_code);
        populate_oft_emp_data(g_job_code);
        populate_nh_emp_data(g_job_code);
    --END IF;

    g_for_all_emp := 'F';

    FOR i IN 1 .. second_order_func_table.count LOOP
      --FND_FILE.PUT_LINE(FND_FILE.LOG,'FOR i IN 1 .. second_order_func_table.count LOOP');
      l_function := second_order_func_table(i).job_function;
      l_function_desc := second_order_func_table(i).description;
      IF l_function <> l_current_function THEN
        l_current_function := l_function;
        l_funct_counter := l_funct_counter + 1;
        --generate_sql(l_current_function);
	--FND_FILE.PUT_LINE(FND_FILE.LOG,'g_nh_sql : '|| g_nh_sql);
	--FND_FILE.PUT_LINE(FND_FILE.LOG,'g_ft_emp_sql : ' || g_ft_emp_sql);
	--FND_FILE.PUT_LINE(FND_FILE.LOG,'g_oft_sql : ' || g_oft_sql);
        populate_ft_emp_data(l_current_function);
        populate_oft_emp_data(l_current_function);
        populate_nh_emp_data(l_current_function);
        --FND_FILE.PUT_LINE(FND_FILE.LOG,'l_function : '||l_function ||' inserted into func_table');
      END IF;
    END LOOP; -- end of second_order_func_table */

   -- Show the functions data whose data should be displayed first
    generate_header_xml_data();
    --generate_juris_cert_xml_data();
    -- create a report for all the functions in the first order table.
    -- Bug# 5410130
    IF first_order_func_table.count <> 0 THEN
	create_report(1);
    END IF;

    -- create a separate report for each function in the second order table.
    create_report(2);
    generate_footer_xml_data();

END generate_xml_data;

PROCEDURE create_report(report_type NUMBER) IS
l_current_function VARCHAR2(30);
l_function VARCHAR2(30);
l_function_desc VARCHAR2(80);

BEGIN

  IF report_type = 1 THEN

      -- Show the functions data whose data should be displayed first
      l_xml_string := '<G_REPORT>';

      --FND_FILE.PUT_LINE(FND_FILE.LOG,l_xml_string);
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT,l_xml_string);
      --FND_FILE.PUT_LINE(FND_FILE.LOG,' Calling create_xml for the function: '||g_job_code||' with description: '||g_func_desc);

      -- Bug# 5415136
      g_function_numbers := '''X''';

      --FND_FILE.PUT_LINE(FND_FILE.LOG,'g_function_numbers: ' || g_function_numbers);

      FOR i IN 1 .. first_order_func_table.count LOOP

	l_current_function := first_order_func_table(i).job_function;

	IF g_function_numbers = '''X''' THEN
	        IF l_current_function = 'X' THEN
			g_function_numbers := 0;
                ELSE
			g_function_numbers := get_function_number(l_current_function);
		END IF;
	ELSE
		g_function_numbers := g_function_numbers || ', ' || get_function_number(l_current_function);
	END IF;
      END LOOP;

      generate_juris_cert_xml_data();

      l_xml_string := convert_into_xml('CONTROL_NUMBER',g_control_number,'D');
      l_xml_string := l_xml_string || convert_into_xml('FUNCTION_NUMBERS',g_function_numbers,'D');

      --FND_FILE.PUT_LINE(FND_FILE.LOG,l_xml_string);
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT,l_xml_string);


      -- Bug# 5409988
      FOR i IN 1 .. first_order_func_table.count LOOP
	l_current_function := first_order_func_table(i).job_function;
	IF l_current_function <> 'X' THEN
		check_function(to_number(l_current_function));
	END IF;
      END LOOP;

      l_xml_string := '<LIST_G_JOB_FUNCTION>';
      --FND_FILE.PUT_LINE(FND_FILE.LOG,l_xml_string);
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT,l_xml_string);

      -- Bug# 5410233.
      g_line_number := 0;

      g_for_all_emp := 'T';
      create_xml(g_job_code);
      g_for_all_emp := 'F';

      l_xml_string := '</LIST_G_JOB_FUNCTION></G_REPORT>';

      --FND_FILE.PUT_LINE(FND_FILE.LOG,l_xml_string);
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT,l_xml_string);

    ELSIF report_type = 2 THEN

      -- Show the functions data whose data should be displayed later

      FOR i IN 1 .. second_order_func_table.count LOOP -- For Each Function

        l_current_function := second_order_func_table(i).job_function;
        g_func_desc := second_order_func_table(i).description;

        -- Bug# 5415136
	g_function_numbers := get_function_number(l_current_function);

        l_xml_string := '<G_REPORT>';
        --FND_FILE.PUT_LINE(FND_FILE.LOG,l_xml_string);
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT,l_xml_string);
        generate_juris_cert_xml_data();

        -- Bug# 5415136
	l_xml_string := convert_into_xml('CONTROL_NUMBER',g_control_number,'D');
        l_xml_string := l_xml_string || convert_into_xml('FUNCTION_NUMBERS',g_function_numbers,'D');

	--FND_FILE.PUT_LINE(FND_FILE.LOG,l_xml_string);
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT,l_xml_string);

	-- Bug# 5409988
        check_function(to_number(l_current_function));

        l_xml_string := '<LIST_G_JOB_FUNCTION>';
        --FND_FILE.PUT_LINE(FND_FILE.LOG,l_xml_string);
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT,l_xml_string);

	-- Bug# 5410233.
        g_line_number := 0;

        g_for_all_emp := 'F';
        create_xml(l_current_function);

        l_xml_string := '</LIST_G_JOB_FUNCTION></G_REPORT>';

        --FND_FILE.PUT_LINE(FND_FILE.LOG,l_xml_string);
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT,l_xml_string);
      END LOOP; -- For Each Function
    END IF;

END create_report;

PROCEDURE generate_header_xml_data IS

  BEGIN

  l_xml_string := '<?xml version="1.0"?> <PQHEEO4>';

  --FND_FILE.PUT_LINE(FND_FILE.LOG,l_xml_string);
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,l_xml_string);

END generate_header_xml_data;

PROCEDURE generate_footer_xml_data IS

  l_bg_name VARCHAR2(100);

  CURSOR get_bg_name IS
  SELECT name from hr_organization_units
  WHERE organization_id = g_business_group_id
  AND business_group_id = g_business_group_id;

  BEGIN

  l_bg_name := ' ';

  OPEN get_bg_name;
  FETCH get_bg_name INTO l_bg_name;
  CLOSE get_bg_name;

  l_xml_string :=  convert_into_xml('C_BUSINESS_GROUP_NAME',l_bg_name,'D')
                   || convert_into_xml('C_REPORT_TYPE','2006 EEO-4 REPORT','D')
                   || '<C_ORGANIZATION_HIERARCHY></C_ORGANIZATION_HIERARCHY>
                       <C_EEO1_ORGANIZATION></C_EEO1_ORGANIZATION>
                       <C_END_OF_TIME></C_END_OF_TIME>
                       </PQHEEO4>';
  --FND_FILE.PUT_LINE(FND_FILE.LOG,l_xml_string);
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,l_xml_string);

END generate_footer_xml_data;

PROCEDURE generate_juris_cert_xml_data IS

  CURSOR get_jurisdiction_details IS

  -- Bug# 5437076

         SELECT NVL(hou.name,' ')                                             jurisdiction_name,
		NVL(hl.address_line_1,' ')||' '||NVL(hl.address_line_2,' ')
                ||' '||NVL(hl.address_line_3,' ') 	                      address,
		NVL(hl.town_or_city,' ')                                      town_or_city,
                NVL(hl.region_1,' ')                                          county,
                NVL(hl.region_2,' ')||' '||NVL(hl.postal_code,' ')	      state_zip
	FROM	 hr_all_organization_units hou,
		 hr_locations hl
	WHERE  hou.location_id = hl.location_id
	AND  hou.business_group_id = g_business_group_id
	AND  hou.organization_id = g_business_group_id;

 /* This query is replaced with the above query for the bug# 5437076

	SELECT 	NVL(name,' ')                                             jurisdiction_name,
		NVL(address_line_1,' ')||' '||NVL(address_line_2,' ')
                ||' '||NVL(address_line_3,' ') 	                          address,
		NVL(town_or_city,' ')                                     town_or_city,
                NVL(region_1,' ')                                         county,
                NVL(region_2,' ')||' '||NVL(postal_code,' ')		  state_zip
        FROM hr_all_organization_units
        WHERE business_group_id = g_business_group_id
        and organization_id = g_business_group_id;
  */

   CURSOR get_cert_details IS

	SELECT 	NVL(org_information1,' ')         cert_officer_name,
		NVL(org_information2,' ')	  cert_officer_title,
		NVL(org_information3,' ')	  contact_name,
		NVL(org_information4,' ')	  contact_title,
		NVL(org_information5,' ')
                ||' '|| NVL(org_information6,' ') contact_address,
		NVL(org_information7,' ')
                ||' '|| NVL(org_information8,' ')
                ||' '|| NVL(org_information9,' ') contact_city_state_zip,
		NVL(org_information10,' ')	  contact_telephone,
		NVL(org_information12,' ')	  control_number,
		NVL(org_information15, ' ')       email,
		NVL(org_information14, ' ')       fax
	FROM	hr_organization_information
	WHERE	org_information_context	= 'EEO_REPORT'
	AND	organization_id		= g_business_group_id;
	--AND	org_information11	= 'EEO4';

  BEGIN

    l_xml_string := '<LIST_G_CERT_OFFICER_NAME>';

    FOR rec IN get_cert_details LOOP

          l_xml_string := l_xml_string || '<G_CERT_OFFICER_NAME>';
          l_xml_string := l_xml_string || convert_into_xml('CERT_OFFICIAL_NAME',rec.cert_officer_name,'D');
          l_xml_string := l_xml_string || convert_into_xml('CERT_OFFICIAL_TITLE',rec.cert_officer_title,'D');
          l_xml_string := l_xml_string || convert_into_xml('CONTACT_NAME',rec.contact_name,'D');
          l_xml_string := l_xml_string || convert_into_xml('CONTACT_TITLE',rec.contact_title,'D');
          l_xml_string := l_xml_string || convert_into_xml('CONTACT_ADDRESS',rec.contact_address,'D');
          l_xml_string := l_xml_string || convert_into_xml('CONTACT_CITY_STATE_ZIP',rec.contact_city_state_zip,'D');
          l_xml_string := l_xml_string || convert_into_xml('CONTACT_TELEPHONE',rec.contact_telephone,'D');
	  -- Bug# 5415136
	  g_control_number := rec.control_number;
	  l_xml_string := l_xml_string || convert_into_xml('CONTACT_FAX',rec.fax,'D');
	  l_xml_string := l_xml_string || convert_into_xml('CONTACT_EMAIL',rec.email,'D');
          l_xml_string := l_xml_string || convert_into_xml('CONTROL_NUMBER',rec.control_number,'D');
	  l_xml_string := l_xml_string || convert_into_xml('FUNCTION_NUMBERS',g_function_numbers,'D');
          l_xml_string := l_xml_string || '</G_CERT_OFFICER_NAME>';

    END LOOP;

    l_xml_string := l_xml_string || '</LIST_G_CERT_OFFICER_NAME>';

    --FND_FILE.PUT_LINE(FND_FILE.LOG,l_xml_string);
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,l_xml_string);


    l_xml_string := '<LIST_G_JURISDICTION_DETAIL>';

    FOR rec IN get_jurisdiction_details LOOP
          l_xml_string := l_xml_string || '<G_JURISDICTION_DETAIL>';
          l_xml_string := l_xml_string || convert_into_xml('BUSINESS_NAME',rec.jurisdiction_name,'D');
          l_xml_string := l_xml_string || convert_into_xml('ADDRESS',rec.address,'D');
          l_xml_string := l_xml_string || convert_into_xml('CITY_TOWN',rec.town_or_city,'D');
          l_xml_string := l_xml_string || convert_into_xml('COUNTY',rec.county,'D');
          l_xml_string := l_xml_string || convert_into_xml('STATE_ZIP',rec.state_zip,'D');

	  -- Bug# 5415136
	  l_xml_string := l_xml_string || convert_into_xml('CONTROL_NUMBER',g_control_number,'D');
	  l_xml_string := l_xml_string || convert_into_xml('FUNCTION_NUMBERS',g_function_numbers,'D');

          l_xml_string := l_xml_string || '</G_JURISDICTION_DETAIL>';
    END LOOP;

    l_xml_string := l_xml_string || '</LIST_G_JURISDICTION_DETAIL>';

    --FND_FILE.PUT_LINE(FND_FILE.LOG,l_xml_string);
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,l_xml_string);

END generate_juris_cert_xml_data;


PROCEDURE create_xml(p_current_function IN VARCHAR2) IS

BEGIN
      l_xml_string := '<G_JOB_FUNCTION><JOB_FUNCTION_CODE>';
      -- Bug# 5415136
      -- Replaced p_current_function with g_function_numbers.
      l_xml_string := l_xml_string || g_function_numbers;
      l_xml_string := l_xml_string || '</JOB_FUNCTION_CODE><LIST_G_EMPLOYMENT_CATEGORY>';

      --FND_FILE.PUT_LINE(FND_FILE.LOG,l_xml_string);
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT,l_xml_string);

      g_line_number := g_line_number + 1;

      -- Genarate full time emp xml data
      generate_ft_xml_data(p_current_function);

      g_line_number := g_line_number + 1;

      -- Genarate other than full time emp xml data
      generate_oft_xml_data(p_current_function);

      g_line_number := g_line_number + 1;

       -- Genarate new hires emp xml data
      generate_nh_xml_data(p_current_function);

      l_xml_string :=  ' </LIST_G_EMPLOYMENT_CATEGORY>'
                       || convert_into_xml('CF_SET_FUNCTION_DESC',g_func_desc,'D')
                       || '</G_JOB_FUNCTION>';
      --FND_FILE.PUT_LINE(FND_FILE.LOG,l_xml_string);
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT,l_xml_string);
END create_xml;


 -- This method populates ft_emp_table

 PROCEDURE populate_ft_emp_data(p_function_code IN VARCHAR2) IS

  l_function_code  VARCHAR2(32767);
  l_job_category_code VARCHAR2(30);
  l_job_category_name VARCHAR2(80);
  l_cons_total_category_emps NUMBER := 0;
  l_no_cons_wmale_emps NUMBER := 0;
  l_no_cons_bmale_emps NUMBER := 0;
  l_no_cons_hmale_emps NUMBER := 0;
  l_no_cons_amale_emps NUMBER := 0;
  l_no_cons_imale_emps NUMBER := 0;
  l_no_cons_wfemale_emps NUMBER := 0;
  l_no_cons_bfemale_emps NUMBER := 0;
  l_no_cons_hfemale_emps NUMBER := 0;
  l_no_cons_afemale_emps NUMBER := 0;
  l_no_cons_ifemale_emps NUMBER := 0;

   -- Bug# 5593259
   l_no_tmr_wmale_emps NUMBER := 0;
  l_no_tmr_bmale_emps NUMBER := 0;
  l_no_tmr_hmale_emps NUMBER := 0;
  l_no_tmr_amale_emps NUMBER := 0;
  l_no_tmr_imale_emps NUMBER := 0;
  l_no_tmr_wfemale_emps NUMBER := 0;
  l_no_tmr_bfemale_emps NUMBER := 0;
  l_no_tmr_hfemale_emps NUMBER := 0;
  l_no_tmr_afemale_emps NUMBER := 0;
  l_no_tmr_ifemale_emps NUMBER := 0;



  CURSOR get_eeo4_lookup_details IS
  SELECT lookup_code, meaning, description
  FROM hr_lookups
  WHERE lookup_type = 'US_EEO4_JOB_CATEGORIES'
  ORDER BY lookup_code;


  BEGIN

    l_function_code := p_function_code;

    FOR i IN get_eeo4_lookup_details LOOP -- for each job category

        g_lookup_code := i.lookup_code;
        g_meaning := i.meaning;


        FOR j IN 1 .. 8 LOOP -- for each salary range

            /* CASE j
             WHEN 1 THEN g_start_salary := 100;
                         g_end_salary := 15900;
                         g_salary_range := '$0.1-15.9';
             WHEN 2 THEN g_start_salary := 16000;
                         g_end_salary := 19900;
                         g_salary_range := '16.0-19.9';
             WHEN 3 THEN g_start_salary := 20000;
                         g_end_salary := 24900;
                         g_salary_range := '20.0-24.9';
             WHEN 4 THEN g_start_salary := 25000;
                         g_end_salary := 32900;
                         g_salary_range := '25.0-32.9';
             WHEN 5 THEN g_start_salary := 33000;
                         g_end_salary := 42900;
                         g_salary_range := '33.0-42.9';
             WHEN 6 THEN g_start_salary := 43000;
                         g_end_salary := 54900;
                         g_salary_range := '43.0-54.9';
             WHEN 7 THEN g_start_salary := 55000;
                         g_end_salary := 64900;
                         g_salary_range := '55.0-69.9';
             WHEN 8 THEN g_start_salary := 70000;
                         g_end_salary := 99900;
                         g_salary_range := '70.0 PLUS';
             END CASE;  */
             --  Fix for Bug#8812609
             CASE j
             WHEN 1 THEN g_start_salary := 100;
                         g_end_salary := 15999;
                         g_salary_range := '$0.1-15.999';
             WHEN 2 THEN g_start_salary := 16000;
                         g_end_salary := 19999;
                         g_salary_range := '16.0-19.999';
             WHEN 3 THEN g_start_salary := 20000;
                         g_end_salary := 24999;
                         g_salary_range := '20.0-24.999';
             WHEN 4 THEN g_start_salary := 25000;
                         g_end_salary := 32999;
                         g_salary_range := '25.0-32.999';
             WHEN 5 THEN g_start_salary := 33000;
                         g_end_salary := 42999;
                         g_salary_range := '33.0-42.999';
             WHEN 6 THEN g_start_salary := 43000;
                         g_end_salary := 54999;
                         g_salary_range := '43.0-54.999';
             WHEN 7 THEN g_start_salary := 55000;
                         g_end_salary := 69999;
                         g_salary_range := '55.0-69.999';
             WHEN 8 THEN g_start_salary := 70000;
                         g_end_salary := 99900;
                         g_salary_range := '70.0 PLUS';
             END CASE;

             source_cursor := dbms_sql.open_cursor;

             -- Bug# 5414756
	     IF J = 8 THEN
		g_dynamic_where := ' AND round(NVL(ppp.proposed_salary_n * ppb.pay_annualization_factor,0)) >= 70000 ';
	     ELSE
		g_dynamic_where := ' AND round(NVL(ppp.proposed_salary_n * ppb.pay_annualization_factor,0)) BETWEEN ' || g_start_salary || ' AND ' || g_end_salary;
	     END IF;

             generate_sql(p_function_code, g_dynamic_where);


            dbms_sql.parse(source_cursor,g_ft_emp_sql,2);
            dbms_sql.BIND_VARIABLE(source_cursor,':1',g_lookup_code);
            --dbms_sql.BIND_VARIABLE(source_cursor,':2',g_start_salary);
            --dbms_sql.BIND_VARIABLE(source_cursor,':3',g_end_salary);

            dbms_sql.define_column_char(source_cursor,1,l_job_category_code,4000);
            dbms_sql.define_column_char(source_cursor,2,l_job_category_name,4000);
	    --Bug# 6200441
            --dbms_sql.define_column(source_cursor,3,l_cons_total_category_emps);
            dbms_sql.define_column(source_cursor,3,l_no_cons_wmale_emps);
            dbms_sql.define_column(source_cursor,4,l_no_cons_bmale_emps);
            dbms_sql.define_column(source_cursor,5,l_no_cons_hmale_emps);
            dbms_sql.define_column(source_cursor,6,l_no_cons_amale_emps);
            dbms_sql.define_column(source_cursor,7,l_no_cons_imale_emps);
            dbms_sql.define_column(source_cursor,8,l_no_cons_wfemale_emps);
            dbms_sql.define_column(source_cursor,9,l_no_cons_bfemale_emps);
            dbms_sql.define_column(source_cursor,10,l_no_cons_hfemale_emps);
            dbms_sql.define_column(source_cursor,11,l_no_cons_afemale_emps);
            dbms_sql.define_column(source_cursor,12,l_no_cons_ifemale_emps);

            rows_processed := dbms_sql.EXECUTE(source_cursor);

            IF dbms_sql.fetch_rows(source_cursor) > 0 THEN

                  dbms_sql.column_value_char(source_cursor,1,l_job_category_code);
                  dbms_sql.column_value_char(source_cursor,2,l_job_category_name);
		  --Bug# 6200441
                  --dbms_sql.column_value(source_cursor,3,l_cons_total_category_emps);
                  dbms_sql.column_value(source_cursor,3,l_no_cons_wmale_emps);
                  dbms_sql.column_value(source_cursor,4,l_no_cons_bmale_emps);
                  dbms_sql.column_value(source_cursor,5,l_no_cons_hmale_emps);
                  dbms_sql.column_value(source_cursor,6,l_no_cons_amale_emps);
                  dbms_sql.column_value(source_cursor,7,l_no_cons_imale_emps);
                  dbms_sql.column_value(source_cursor,8,l_no_cons_wfemale_emps);
                  dbms_sql.column_value(source_cursor,9,l_no_cons_bfemale_emps);
                  dbms_sql.column_value(source_cursor,10,l_no_cons_hfemale_emps);
                  dbms_sql.column_value(source_cursor,11,l_no_cons_afemale_emps);
                  dbms_sql.column_value(source_cursor,12,l_no_cons_ifemale_emps);

                  l_counter1 := l_counter1 + 1;

                  IF g_for_all_emp = 'T' THEN
                    ft_emp_table(l_counter1).job_function             := 'AF';
                  ELSIF g_for_all_emp = 'F' THEN
                     ft_emp_table(l_counter1).job_function             := ltrim(rtrim(l_function_code));
                  END IF;

                  ft_emp_table(l_counter1).lookup_code              := ltrim(rtrim(l_job_category_code));
                  ft_emp_table(l_counter1).salary_range             := ltrim(rtrim(g_salary_range));
		  -- Bug# 6200441
                  ft_emp_table(l_counter1).cons_total_category_emps := ltrim(rtrim(l_no_cons_wmale_emps)) +
		                                                                                       ltrim(rtrim(l_no_cons_bmale_emps)) +
												       ltrim(rtrim(l_no_cons_hmale_emps)) +
												       ltrim(rtrim(l_no_cons_amale_emps)) +
												       ltrim(rtrim(l_no_cons_imale_emps)) +
												       ltrim(rtrim(l_no_cons_wfemale_emps)) +
												       ltrim(rtrim(l_no_cons_bfemale_emps)) +
												       ltrim(rtrim(l_no_cons_hfemale_emps)) +
												       ltrim(rtrim(l_no_cons_afemale_emps)) +
												       ltrim(rtrim(l_no_cons_ifemale_emps));
                  ft_emp_table(l_counter1).no_cons_wmale_emps       := ltrim(rtrim(l_no_cons_wmale_emps));
                  ft_emp_table(l_counter1).no_cons_bmale_emps       := ltrim(rtrim(l_no_cons_bmale_emps));
                  ft_emp_table(l_counter1).no_cons_hmale_emps       := ltrim(rtrim(l_no_cons_hmale_emps));
                  ft_emp_table(l_counter1).no_cons_amale_emps       := ltrim(rtrim(l_no_cons_amale_emps));
                  ft_emp_table(l_counter1).no_cons_imale_emps       := ltrim(rtrim(l_no_cons_imale_emps));
                  ft_emp_table(l_counter1).no_cons_wfemale_emps     := ltrim(rtrim(l_no_cons_wfemale_emps));
                  ft_emp_table(l_counter1).no_cons_bfemale_emps     := ltrim(rtrim(l_no_cons_bfemale_emps));
                  ft_emp_table(l_counter1).no_cons_hfemale_emps     := ltrim(rtrim(l_no_cons_hfemale_emps));
                  ft_emp_table(l_counter1).no_cons_afemale_emps     := ltrim(rtrim(l_no_cons_afemale_emps));
                  ft_emp_table(l_counter1).no_cons_ifemale_emps     := ltrim(rtrim(l_no_cons_ifemale_emps));

            ELSE

                  l_counter1 := l_counter1 + 1;

                  IF g_for_all_emp = 'T' THEN
                    ft_emp_table(l_counter1).job_function             := 'AF';
                  ELSIF g_for_all_emp = 'F' THEN
                     ft_emp_table(l_counter1).job_function             := ltrim(rtrim(l_function_code));
                  END IF;
                  ft_emp_table(l_counter1).lookup_code              := ltrim(rtrim(g_lookup_code));
                  ft_emp_table(l_counter1).salary_range             := ltrim(rtrim(g_salary_range));
                  ft_emp_table(l_counter1).cons_total_category_emps := 0;
                  ft_emp_table(l_counter1).no_cons_wmale_emps       := 0;
                  ft_emp_table(l_counter1).no_cons_bmale_emps       := 0;
                  ft_emp_table(l_counter1).no_cons_hmale_emps       := 0;
                  ft_emp_table(l_counter1).no_cons_amale_emps       := 0;
                  ft_emp_table(l_counter1).no_cons_imale_emps       := 0;
                  ft_emp_table(l_counter1).no_cons_wfemale_emps     := 0;
                  ft_emp_table(l_counter1).no_cons_bfemale_emps     := 0;
                  ft_emp_table(l_counter1).no_cons_hfemale_emps     := 0;
                  ft_emp_table(l_counter1).no_cons_afemale_emps     := 0;
                  ft_emp_table(l_counter1).no_cons_ifemale_emps     := 0;
          END IF;
          dbms_sql.close_cursor(source_cursor); -- Closing the cursor

          -- Bug# 5593259
	  /* For Two or more races:
	      If the employee's ethnic code is 'Two or more races',
	      select pei_information5 from per_people_extra_info table
	   */

	   source_cursor := dbms_sql.open_cursor;
	   dbms_sql.parse(source_cursor,g_tmr_ft_emp_sql,2);
	   dbms_sql.BIND_VARIABLE(source_cursor,':1',g_lookup_code);

	   dbms_sql.define_column_char(source_cursor,1,l_job_category_code,4000);
            dbms_sql.define_column_char(source_cursor,2,l_job_category_name,4000);
            dbms_sql.define_column(source_cursor,3,l_no_tmr_wmale_emps);
            dbms_sql.define_column(source_cursor,4,l_no_tmr_bmale_emps);
            dbms_sql.define_column(source_cursor,5,l_no_tmr_hmale_emps);
            dbms_sql.define_column(source_cursor,6,l_no_tmr_amale_emps);
            dbms_sql.define_column(source_cursor,7,l_no_tmr_imale_emps);
            dbms_sql.define_column(source_cursor,8,l_no_tmr_wfemale_emps);
            dbms_sql.define_column(source_cursor,9,l_no_tmr_bfemale_emps);
            dbms_sql.define_column(source_cursor,10,l_no_tmr_hfemale_emps);
            dbms_sql.define_column(source_cursor,11,l_no_tmr_afemale_emps);
            dbms_sql.define_column(source_cursor,12,l_no_tmr_ifemale_emps);

            rows_processed := dbms_sql.EXECUTE(source_cursor);

            IF dbms_sql.fetch_rows(source_cursor) > 0 THEN

                  dbms_sql.column_value_char(source_cursor,1,l_job_category_code);
                  dbms_sql.column_value_char(source_cursor,2,l_job_category_name);
                  dbms_sql.column_value(source_cursor,3,l_no_tmr_wmale_emps);
                  dbms_sql.column_value(source_cursor,4,l_no_tmr_bmale_emps);
                  dbms_sql.column_value(source_cursor,5,l_no_tmr_hmale_emps);
                  dbms_sql.column_value(source_cursor,6,l_no_tmr_amale_emps);
                  dbms_sql.column_value(source_cursor,7,l_no_tmr_imale_emps);
                  dbms_sql.column_value(source_cursor,8,l_no_tmr_wfemale_emps);
                  dbms_sql.column_value(source_cursor,9,l_no_tmr_bfemale_emps);
                  dbms_sql.column_value(source_cursor,10,l_no_tmr_hfemale_emps);
                  dbms_sql.column_value(source_cursor,11,l_no_tmr_afemale_emps);
                  dbms_sql.column_value(source_cursor,12,l_no_tmr_ifemale_emps);

		  ft_emp_table(l_counter1).no_cons_wmale_emps       := ft_emp_table(l_counter1).no_cons_wmale_emps +
		                                                                                       ltrim(rtrim(l_no_tmr_wmale_emps));
                  ft_emp_table(l_counter1).no_cons_bmale_emps        := ft_emp_table(l_counter1).no_cons_bmale_emps +
		                                                                                       ltrim(rtrim(l_no_tmr_bmale_emps));
                  ft_emp_table(l_counter1).no_cons_hmale_emps        := ft_emp_table(l_counter1).no_cons_hmale_emps +
		                                                                                       ltrim(rtrim(l_no_tmr_hmale_emps));
                  ft_emp_table(l_counter1).no_cons_amale_emps        := ft_emp_table(l_counter1).no_cons_amale_emps +
		                                                                                       ltrim(rtrim(l_no_tmr_amale_emps));
                  ft_emp_table(l_counter1).no_cons_imale_emps         := ft_emp_table(l_counter1).no_cons_imale_emps +
		                                                                                       ltrim(rtrim(l_no_tmr_imale_emps));
                  ft_emp_table(l_counter1).no_cons_wfemale_emps    := ft_emp_table(l_counter1).no_cons_wfemale_emps +
		                                                                                       ltrim(rtrim(l_no_tmr_wfemale_emps));
                  ft_emp_table(l_counter1).no_cons_bfemale_emps     := ft_emp_table(l_counter1).no_cons_bfemale_emps +
		                                                                                       ltrim(rtrim(l_no_tmr_bfemale_emps));
                  ft_emp_table(l_counter1).no_cons_hfemale_emps     := ft_emp_table(l_counter1).no_cons_hfemale_emps +
		                                                                                       ltrim(rtrim(l_no_tmr_hfemale_emps));
                  ft_emp_table(l_counter1).no_cons_afemale_emps     := ft_emp_table(l_counter1).no_cons_afemale_emps +
		                                                                                      ltrim(rtrim(l_no_tmr_afemale_emps));
                  ft_emp_table(l_counter1).no_cons_ifemale_emps      := ft_emp_table(l_counter1).no_cons_ifemale_emps +
		                                                                                       ltrim(rtrim(l_no_tmr_ifemale_emps));
                  -- Bug# 6200441
                  ft_emp_table(l_counter1).cons_total_category_emps := ft_emp_table(l_counter1).cons_total_category_emps +
		                                                                                       ltrim(rtrim(l_no_tmr_wmale_emps)) +
		                                                                                       ltrim(rtrim(l_no_tmr_bmale_emps)) +
												       ltrim(rtrim(l_no_tmr_hmale_emps)) +
												       ltrim(rtrim(l_no_tmr_amale_emps)) +
												       ltrim(rtrim(l_no_tmr_imale_emps)) +
												       ltrim(rtrim(l_no_tmr_wfemale_emps)) +
												       ltrim(rtrim(l_no_tmr_bfemale_emps)) +
												       ltrim(rtrim(l_no_tmr_hfemale_emps)) +
												       ltrim(rtrim(l_no_tmr_afemale_emps)) +
												       ltrim(rtrim(l_no_tmr_ifemale_emps));

	   END IF;

	   dbms_sql.close_cursor(source_cursor); -- Closing the cursor

         END LOOP; -- for each salary range
      END LOOP; -- for each job category
  END populate_ft_emp_data; -- End of the procedure populate_ft_emp_data

  PROCEDURE populate_oft_emp_data(p_function_code IN VARCHAR2) IS

  l_function_code  VARCHAR2(32767);
  l_job_category_code VARCHAR2(30);
  l_job_category_name VARCHAR2(80);
  l_cons_total_category_emps NUMBER := 0;
  l_no_cons_wmale_emps NUMBER := 0;
  l_no_cons_bmale_emps NUMBER := 0;
  l_no_cons_hmale_emps NUMBER := 0;
  l_no_cons_amale_emps NUMBER := 0;
  l_no_cons_imale_emps NUMBER := 0;
  l_no_cons_wfemale_emps NUMBER := 0;
  l_no_cons_bfemale_emps NUMBER := 0;
  l_no_cons_hfemale_emps NUMBER := 0;
  l_no_cons_afemale_emps NUMBER := 0;
  l_no_cons_ifemale_emps NUMBER := 0;

 -- Bug# 5593259
   l_no_tmr_wmale_emps NUMBER := 0;
  l_no_tmr_bmale_emps NUMBER := 0;
  l_no_tmr_hmale_emps NUMBER := 0;
  l_no_tmr_amale_emps NUMBER := 0;
  l_no_tmr_imale_emps NUMBER := 0;
  l_no_tmr_wfemale_emps NUMBER := 0;
  l_no_tmr_bfemale_emps NUMBER := 0;
  l_no_tmr_hfemale_emps NUMBER := 0;
  l_no_tmr_afemale_emps NUMBER := 0;
  l_no_tmr_ifemale_emps NUMBER := 0;


  CURSOR get_eeo4_lookup_details IS
  SELECT lookup_code, meaning, description
  FROM hr_lookups
  WHERE lookup_type = 'US_EEO4_JOB_CATEGORIES'
  ORDER BY lookup_code;

  BEGIN

  l_function_code := p_function_code;

   FOR i IN get_eeo4_lookup_details LOOP -- for each job category

      g_lookup_code := i.lookup_code;
      g_meaning := i.meaning;

      source_cursor := dbms_sql.open_cursor;
      dbms_sql.parse(source_cursor,g_oft_sql,2);
      dbms_sql.BIND_VARIABLE(source_cursor,':1',g_lookup_code);

      dbms_sql.define_column_char(source_cursor,1,l_job_category_code,4000);
      dbms_sql.define_column_char(source_cursor,2,l_job_category_name,4000);
      -- Bug# 6200441
      --dbms_sql.define_column(source_cursor,3,l_cons_total_category_emps);
      dbms_sql.define_column(source_cursor,3,l_no_cons_wmale_emps);
      dbms_sql.define_column(source_cursor,4,l_no_cons_bmale_emps);
      dbms_sql.define_column(source_cursor,5,l_no_cons_hmale_emps);
      dbms_sql.define_column(source_cursor,6,l_no_cons_amale_emps);
      dbms_sql.define_column(source_cursor,7,l_no_cons_imale_emps);
      dbms_sql.define_column(source_cursor,8,l_no_cons_wfemale_emps);
      dbms_sql.define_column(source_cursor,9,l_no_cons_bfemale_emps);
      dbms_sql.define_column(source_cursor,10,l_no_cons_hfemale_emps);
      dbms_sql.define_column(source_cursor,11,l_no_cons_afemale_emps);
      dbms_sql.define_column(source_cursor,12,l_no_cons_ifemale_emps);

      rows_processed := dbms_sql.EXECUTE(source_cursor);

      IF dbms_sql.fetch_rows(source_cursor) > 0 THEN

        dbms_sql.column_value_char(source_cursor,1,l_job_category_code);
        dbms_sql.column_value_char(source_cursor,2,l_job_category_name);
	-- Bug# 6200441
        --dbms_sql.column_value(source_cursor,3,l_cons_total_category_emps);
        dbms_sql.column_value(source_cursor,3,l_no_cons_wmale_emps);
        dbms_sql.column_value(source_cursor,4,l_no_cons_bmale_emps);
        dbms_sql.column_value(source_cursor,5,l_no_cons_hmale_emps);
        dbms_sql.column_value(source_cursor,6,l_no_cons_amale_emps);
        dbms_sql.column_value(source_cursor,7,l_no_cons_imale_emps);
        dbms_sql.column_value(source_cursor,8,l_no_cons_wfemale_emps);
        dbms_sql.column_value(source_cursor,9,l_no_cons_bfemale_emps);
        dbms_sql.column_value(source_cursor,10,l_no_cons_hfemale_emps);
        dbms_sql.column_value(source_cursor,11,l_no_cons_afemale_emps);
        dbms_sql.column_value(source_cursor,12,l_no_cons_ifemale_emps);

        l_counter2 := l_counter2 + 1;

        IF g_for_all_emp = 'T' THEN
           other_ft_emp_table(l_counter2).job_function             := 'AF';
        ELSIF g_for_all_emp = 'F' THEN
           other_ft_emp_table(l_counter2).job_function             := ltrim(rtrim(l_function_code));
        END IF;

        other_ft_emp_table(l_counter2).lookup_code              := ltrim(rtrim(g_lookup_code));
        -- Bug# 6200441
	other_ft_emp_table(l_counter2).cons_total_category_emps := ltrim(rtrim(l_no_cons_wmale_emps)) +
												       ltrim(rtrim(l_no_cons_bmale_emps)) +
												       ltrim(rtrim(l_no_cons_hmale_emps)) +
												       ltrim(rtrim(l_no_cons_amale_emps)) +
												       ltrim(rtrim(l_no_cons_imale_emps)) +
												       ltrim(rtrim(l_no_cons_wfemale_emps)) +
												       ltrim(rtrim(l_no_cons_bfemale_emps)) +
												       ltrim(rtrim(l_no_cons_hfemale_emps)) +
												       ltrim(rtrim(l_no_cons_afemale_emps)) +
												       ltrim(rtrim(l_no_cons_ifemale_emps));
        other_ft_emp_table(l_counter2).no_cons_wmale_emps       := ltrim(rtrim(l_no_cons_wmale_emps));
        other_ft_emp_table(l_counter2).no_cons_bmale_emps       := ltrim(rtrim(l_no_cons_bmale_emps));
        other_ft_emp_table(l_counter2).no_cons_hmale_emps       := ltrim(rtrim(l_no_cons_hmale_emps));
        other_ft_emp_table(l_counter2).no_cons_amale_emps       := ltrim(rtrim(l_no_cons_amale_emps));
        other_ft_emp_table(l_counter2).no_cons_imale_emps       := ltrim(rtrim(l_no_cons_imale_emps));
        other_ft_emp_table(l_counter2).no_cons_wfemale_emps     := ltrim(rtrim(l_no_cons_wfemale_emps));
        other_ft_emp_table(l_counter2).no_cons_bfemale_emps     := ltrim(rtrim(l_no_cons_bfemale_emps));
        other_ft_emp_table(l_counter2).no_cons_hfemale_emps     := ltrim(rtrim(l_no_cons_hfemale_emps));
        other_ft_emp_table(l_counter2).no_cons_afemale_emps     := ltrim(rtrim(l_no_cons_afemale_emps));
        other_ft_emp_table(l_counter2).no_cons_ifemale_emps     := ltrim(rtrim(l_no_cons_ifemale_emps));
   ELSE

        l_counter2 := l_counter2 + 1;

        IF g_for_all_emp = 'T' THEN
           other_ft_emp_table(l_counter2).job_function             := 'AF';
        ELSIF g_for_all_emp = 'F' THEN
           other_ft_emp_table(l_counter2).job_function             := ltrim(rtrim(l_function_code));
        END IF;

        other_ft_emp_table(l_counter2).lookup_code              := ltrim(rtrim(g_lookup_code));
        other_ft_emp_table(l_counter2).cons_total_category_emps := 0;
        other_ft_emp_table(l_counter2).no_cons_wmale_emps       := 0;
        other_ft_emp_table(l_counter2).no_cons_bmale_emps       := 0;
        other_ft_emp_table(l_counter2).no_cons_hmale_emps       := 0;
        other_ft_emp_table(l_counter2).no_cons_amale_emps       := 0;
        other_ft_emp_table(l_counter2).no_cons_imale_emps       := 0;
        other_ft_emp_table(l_counter2).no_cons_wfemale_emps     := 0;
        other_ft_emp_table(l_counter2).no_cons_bfemale_emps     := 0;
        other_ft_emp_table(l_counter2).no_cons_hfemale_emps     := 0;
        other_ft_emp_table(l_counter2).no_cons_afemale_emps     := 0;
        other_ft_emp_table(l_counter2).no_cons_ifemale_emps     := 0;
     END IF;
      dbms_sql.close_cursor(source_cursor); -- Close the cursor

       -- Bug# 5593259
	  /* For Two or more races:
	      If the employee's ethnic code is 'Two or more races',
	      select pei_information5 from per_people_extra_info table
	   */

	   source_cursor := dbms_sql.open_cursor;
	   dbms_sql.parse(source_cursor,g_tmr_oft_sql,2);
	   dbms_sql.BIND_VARIABLE(source_cursor,':1',g_lookup_code);

	   dbms_sql.define_column_char(source_cursor,1,l_job_category_code,4000);
            dbms_sql.define_column_char(source_cursor,2,l_job_category_name,4000);
            dbms_sql.define_column(source_cursor,3,l_no_tmr_wmale_emps);
            dbms_sql.define_column(source_cursor,4,l_no_tmr_bmale_emps);
            dbms_sql.define_column(source_cursor,5,l_no_tmr_hmale_emps);
            dbms_sql.define_column(source_cursor,6,l_no_tmr_amale_emps);
            dbms_sql.define_column(source_cursor,7,l_no_tmr_imale_emps);
            dbms_sql.define_column(source_cursor,8,l_no_tmr_wfemale_emps);
            dbms_sql.define_column(source_cursor,9,l_no_tmr_bfemale_emps);
            dbms_sql.define_column(source_cursor,10,l_no_tmr_hfemale_emps);
            dbms_sql.define_column(source_cursor,11,l_no_tmr_afemale_emps);
            dbms_sql.define_column(source_cursor,12,l_no_tmr_ifemale_emps);

            rows_processed := dbms_sql.EXECUTE(source_cursor);

            IF dbms_sql.fetch_rows(source_cursor) > 0 THEN

                  dbms_sql.column_value_char(source_cursor,1,l_job_category_code);
                  dbms_sql.column_value_char(source_cursor,2,l_job_category_name);
                  dbms_sql.column_value(source_cursor,3,l_no_tmr_wmale_emps);
                  dbms_sql.column_value(source_cursor,4,l_no_tmr_bmale_emps);
                  dbms_sql.column_value(source_cursor,5,l_no_tmr_hmale_emps);
                  dbms_sql.column_value(source_cursor,6,l_no_tmr_amale_emps);
                  dbms_sql.column_value(source_cursor,7,l_no_tmr_imale_emps);
                  dbms_sql.column_value(source_cursor,8,l_no_tmr_wfemale_emps);
                  dbms_sql.column_value(source_cursor,9,l_no_tmr_bfemale_emps);
                  dbms_sql.column_value(source_cursor,10,l_no_tmr_hfemale_emps);
                  dbms_sql.column_value(source_cursor,11,l_no_tmr_afemale_emps);
                  dbms_sql.column_value(source_cursor,12,l_no_tmr_ifemale_emps);

		  other_ft_emp_table(l_counter2).no_cons_wmale_emps       := other_ft_emp_table(l_counter2).no_cons_wmale_emps +
		                                                                                       ltrim(rtrim(l_no_tmr_wmale_emps));
                  other_ft_emp_table(l_counter2).no_cons_bmale_emps        := other_ft_emp_table(l_counter2).no_cons_bmale_emps +
		                                                                                       ltrim(rtrim(l_no_tmr_bmale_emps));
                  other_ft_emp_table(l_counter2).no_cons_hmale_emps        := other_ft_emp_table(l_counter2).no_cons_hmale_emps +
		                                                                                       ltrim(rtrim(l_no_tmr_hmale_emps));
                  other_ft_emp_table(l_counter2).no_cons_amale_emps        := other_ft_emp_table(l_counter2).no_cons_amale_emps +
		                                                                                       ltrim(rtrim(l_no_tmr_amale_emps));
                  other_ft_emp_table(l_counter2).no_cons_imale_emps         := other_ft_emp_table(l_counter2).no_cons_imale_emps +
		                                                                                       ltrim(rtrim(l_no_tmr_imale_emps));
                  other_ft_emp_table(l_counter2).no_cons_wfemale_emps    := other_ft_emp_table(l_counter2).no_cons_wfemale_emps +
		                                                                                       ltrim(rtrim(l_no_tmr_wfemale_emps));
                  other_ft_emp_table(l_counter2).no_cons_bfemale_emps     := other_ft_emp_table(l_counter2).no_cons_bfemale_emps +
		                                                                                       ltrim(rtrim(l_no_tmr_bfemale_emps));
                  other_ft_emp_table(l_counter2).no_cons_hfemale_emps     := other_ft_emp_table(l_counter2).no_cons_hfemale_emps +
		                                                                                       ltrim(rtrim(l_no_tmr_hfemale_emps));
                  other_ft_emp_table(l_counter2).no_cons_afemale_emps     := other_ft_emp_table(l_counter2).no_cons_afemale_emps +
		                                                                                      ltrim(rtrim(l_no_tmr_afemale_emps));
                  other_ft_emp_table(l_counter2).no_cons_ifemale_emps      := other_ft_emp_table(l_counter2).no_cons_ifemale_emps +
		                                                                                       ltrim(rtrim(l_no_tmr_ifemale_emps));
                  -- Bug# 6200441
                  other_ft_emp_table(l_counter2).cons_total_category_emps := other_ft_emp_table(l_counter2).cons_total_category_emps +
														 ltrim(rtrim(l_no_tmr_wmale_emps)) +
														 ltrim(rtrim(l_no_tmr_bmale_emps)) +
														 ltrim(rtrim(l_no_tmr_hmale_emps)) +
														 ltrim(rtrim(l_no_tmr_amale_emps)) +
														 ltrim(rtrim(l_no_tmr_imale_emps)) +
														 ltrim(rtrim(l_no_tmr_wfemale_emps)) +
														 ltrim(rtrim(l_no_tmr_bfemale_emps)) +
														 ltrim(rtrim(l_no_tmr_hfemale_emps)) +
														 ltrim(rtrim(l_no_tmr_afemale_emps)) +
														 ltrim(rtrim(l_no_tmr_ifemale_emps));

	   END IF;

	   dbms_sql.close_cursor(source_cursor); -- Closing the cursor

    END LOOP; -- for each job category
  END;

  PROCEDURE populate_nh_emp_data(p_function_code IN VARCHAR2) IS

  l_function_code  VARCHAR2(32767);
  l_job_category_code VARCHAR2(30);
  l_job_category_name VARCHAR2(80);
  l_cons_total_category_emps NUMBER := 0;
  l_no_cons_wmale_emps NUMBER := 0;
  l_no_cons_bmale_emps NUMBER := 0;
  l_no_cons_hmale_emps NUMBER := 0;
  l_no_cons_amale_emps NUMBER := 0;
  l_no_cons_imale_emps NUMBER := 0;
  l_no_cons_wfemale_emps NUMBER := 0;
  l_no_cons_bfemale_emps NUMBER := 0;
  l_no_cons_hfemale_emps NUMBER := 0;
  l_no_cons_afemale_emps NUMBER := 0;
  l_no_cons_ifemale_emps NUMBER := 0;

  -- Bug# 5593259
   l_no_tmr_wmale_emps NUMBER := 0;
  l_no_tmr_bmale_emps NUMBER := 0;
  l_no_tmr_hmale_emps NUMBER := 0;
  l_no_tmr_amale_emps NUMBER := 0;
  l_no_tmr_imale_emps NUMBER := 0;
  l_no_tmr_wfemale_emps NUMBER := 0;
  l_no_tmr_bfemale_emps NUMBER := 0;
  l_no_tmr_hfemale_emps NUMBER := 0;
  l_no_tmr_afemale_emps NUMBER := 0;
  l_no_tmr_ifemale_emps NUMBER := 0;

  CURSOR get_eeo4_lookup_details IS
  SELECT lookup_code, meaning, description
  FROM hr_lookups
  WHERE lookup_type = 'US_EEO4_JOB_CATEGORIES'
  ORDER BY lookup_code;

  BEGIN

  l_function_code := p_function_code;
  --FND_FILE.PUT_LINE(FND_FILE.LOG,'l_function in populate_nh_emp_data: ' || l_function_code);

  FOR i IN get_eeo4_lookup_details LOOP -- for each job category

        g_lookup_code := i.lookup_code;
        g_meaning := i.meaning;

        source_cursor := dbms_sql.open_cursor;

        dbms_sql.parse(source_cursor,g_nh_sql,2);
        dbms_sql.BIND_VARIABLE(source_cursor,':1',g_lookup_code);

        dbms_sql.define_column_char(source_cursor,1,l_job_category_code,4000);
        dbms_sql.define_column_char(source_cursor,2,l_job_category_name,4000);
	-- Bug# 6200441
        --dbms_sql.define_column(source_cursor,3,l_cons_total_category_emps);
        dbms_sql.define_column(source_cursor,3,l_no_cons_wmale_emps);
        dbms_sql.define_column(source_cursor,4,l_no_cons_bmale_emps);
        dbms_sql.define_column(source_cursor,5,l_no_cons_hmale_emps);
        dbms_sql.define_column(source_cursor,6,l_no_cons_amale_emps);
        dbms_sql.define_column(source_cursor,7,l_no_cons_imale_emps);
        dbms_sql.define_column(source_cursor,8,l_no_cons_wfemale_emps);
        dbms_sql.define_column(source_cursor,9,l_no_cons_bfemale_emps);
        dbms_sql.define_column(source_cursor,10,l_no_cons_hfemale_emps);
        dbms_sql.define_column(source_cursor,11,l_no_cons_afemale_emps);
        dbms_sql.define_column(source_cursor,12,l_no_cons_ifemale_emps);

        rows_processed := dbms_sql.EXECUTE(source_cursor);

        IF dbms_sql.fetch_rows(source_cursor) > 0 THEN

            dbms_sql.column_value_char(source_cursor,1,l_job_category_code);
            dbms_sql.column_value_char(source_cursor,2,l_job_category_name);
	    -- Bug# 6200441
            --dbms_sql.column_value(source_cursor,3,l_cons_total_category_emps);
            dbms_sql.column_value(source_cursor,3,l_no_cons_wmale_emps);
            dbms_sql.column_value(source_cursor,4,l_no_cons_bmale_emps);
            dbms_sql.column_value(source_cursor,5,l_no_cons_hmale_emps);
            dbms_sql.column_value(source_cursor,6,l_no_cons_amale_emps);
            dbms_sql.column_value(source_cursor,7,l_no_cons_imale_emps);
            dbms_sql.column_value(source_cursor,8,l_no_cons_wfemale_emps);
            dbms_sql.column_value(source_cursor,9,l_no_cons_bfemale_emps);
            dbms_sql.column_value(source_cursor,10,l_no_cons_hfemale_emps);
            dbms_sql.column_value(source_cursor,11,l_no_cons_afemale_emps);
            dbms_sql.column_value(source_cursor,12,l_no_cons_ifemale_emps);

            l_counter3 := l_counter3 + 1;

            IF g_for_all_emp = 'T' THEN
               new_hire_table(l_counter3).job_function             := 'AF';
            ELSIF g_for_all_emp = 'F' THEN
               new_hire_table(l_counter3).job_function             := ltrim(rtrim(l_function_code));
            END IF;
            new_hire_table(l_counter3).lookup_code              := ltrim(rtrim(g_lookup_code));
            --new_hire_table(l_counter3).meaning                  := ltrim(rtrim(l_job_category_name));
            -- Bug# 6200441
	    new_hire_table(l_counter3).cons_total_category_emps := ltrim(rtrim(l_no_cons_wmale_emps)) +
												    ltrim(rtrim(l_no_cons_bmale_emps)) +
												    ltrim(rtrim(l_no_cons_hmale_emps)) +
												    ltrim(rtrim(l_no_cons_amale_emps)) +
												    ltrim(rtrim(l_no_cons_imale_emps)) +
												    ltrim(rtrim(l_no_cons_wfemale_emps)) +
												    ltrim(rtrim(l_no_cons_bfemale_emps)) +
												    ltrim(rtrim(l_no_cons_hfemale_emps)) +
												    ltrim(rtrim(l_no_cons_afemale_emps)) +
												    ltrim(rtrim(l_no_cons_ifemale_emps));
            new_hire_table(l_counter3).no_cons_wmale_emps       := ltrim(rtrim(l_no_cons_wmale_emps));
            new_hire_table(l_counter3).no_cons_bmale_emps       := ltrim(rtrim(l_no_cons_bmale_emps));
            new_hire_table(l_counter3).no_cons_hmale_emps       := ltrim(rtrim(l_no_cons_hmale_emps));
            new_hire_table(l_counter3).no_cons_amale_emps       := ltrim(rtrim(l_no_cons_amale_emps));
            new_hire_table(l_counter3).no_cons_imale_emps       := ltrim(rtrim(l_no_cons_imale_emps));
            new_hire_table(l_counter3).no_cons_wfemale_emps     := ltrim(rtrim(l_no_cons_wfemale_emps));
            new_hire_table(l_counter3).no_cons_bfemale_emps     := ltrim(rtrim(l_no_cons_bfemale_emps));
            new_hire_table(l_counter3).no_cons_hfemale_emps     := ltrim(rtrim(l_no_cons_hfemale_emps));
            new_hire_table(l_counter3).no_cons_afemale_emps     := ltrim(rtrim(l_no_cons_afemale_emps));
            new_hire_table(l_counter3).no_cons_ifemale_emps     := ltrim(rtrim(l_no_cons_ifemale_emps));

        ELSE
            l_counter3 := l_counter3 + 1;

            IF g_for_all_emp = 'T' THEN
               new_hire_table(l_counter3).job_function             := 'AF';
            ELSIF g_for_all_emp = 'F' THEN
               new_hire_table(l_counter3).job_function             := ltrim(rtrim(l_function_code));
            END IF;
            new_hire_table(l_counter3).lookup_code              := ltrim(rtrim(g_lookup_code));
            --new_hire_table(l_counter3).meaning                  := g_meaning;
            new_hire_table(l_counter3).cons_total_category_emps := 0;
            new_hire_table(l_counter3).no_cons_wmale_emps       := 0;
            new_hire_table(l_counter3).no_cons_bmale_emps       := 0;
            new_hire_table(l_counter3).no_cons_hmale_emps       := 0;
            new_hire_table(l_counter3).no_cons_amale_emps       := 0;
            new_hire_table(l_counter3).no_cons_imale_emps       := 0;
            new_hire_table(l_counter3).no_cons_wfemale_emps     := 0;
            new_hire_table(l_counter3).no_cons_bfemale_emps     := 0;
            new_hire_table(l_counter3).no_cons_hfemale_emps     := 0;
            new_hire_table(l_counter3).no_cons_afemale_emps     := 0;
            new_hire_table(l_counter3).no_cons_ifemale_emps     := 0;
        END IF;
        dbms_sql.close_cursor(source_cursor); -- Close the cursor

	 -- Bug# 5593259
	  /* For Two or more races:
	      If the employee's ethnic code is 'Two or more races',
	      select pei_information5 from per_people_extra_info table
	   */

	   source_cursor := dbms_sql.open_cursor;
	   dbms_sql.parse(source_cursor,g_tmr_nh_sql,2);
	   dbms_sql.BIND_VARIABLE(source_cursor,':1',g_lookup_code);

	   dbms_sql.define_column_char(source_cursor,1,l_job_category_code,4000);
            dbms_sql.define_column_char(source_cursor,2,l_job_category_name,4000);
            dbms_sql.define_column(source_cursor,3,l_no_tmr_wmale_emps);
            dbms_sql.define_column(source_cursor,4,l_no_tmr_bmale_emps);
            dbms_sql.define_column(source_cursor,5,l_no_tmr_hmale_emps);
            dbms_sql.define_column(source_cursor,6,l_no_tmr_amale_emps);
            dbms_sql.define_column(source_cursor,7,l_no_tmr_imale_emps);
            dbms_sql.define_column(source_cursor,8,l_no_tmr_wfemale_emps);
            dbms_sql.define_column(source_cursor,9,l_no_tmr_bfemale_emps);
            dbms_sql.define_column(source_cursor,10,l_no_tmr_hfemale_emps);
            dbms_sql.define_column(source_cursor,11,l_no_tmr_afemale_emps);
            dbms_sql.define_column(source_cursor,12,l_no_tmr_ifemale_emps);

            rows_processed := dbms_sql.EXECUTE(source_cursor);

            IF dbms_sql.fetch_rows(source_cursor) > 0 THEN

                  dbms_sql.column_value_char(source_cursor,1,l_job_category_code);
                  dbms_sql.column_value_char(source_cursor,2,l_job_category_name);
                  dbms_sql.column_value(source_cursor,3,l_no_tmr_wmale_emps);
                  dbms_sql.column_value(source_cursor,4,l_no_tmr_bmale_emps);
                  dbms_sql.column_value(source_cursor,5,l_no_tmr_hmale_emps);
                  dbms_sql.column_value(source_cursor,6,l_no_tmr_amale_emps);
                  dbms_sql.column_value(source_cursor,7,l_no_tmr_imale_emps);
                  dbms_sql.column_value(source_cursor,8,l_no_tmr_wfemale_emps);
                  dbms_sql.column_value(source_cursor,9,l_no_tmr_bfemale_emps);
                  dbms_sql.column_value(source_cursor,10,l_no_tmr_hfemale_emps);
                  dbms_sql.column_value(source_cursor,11,l_no_tmr_afemale_emps);
                  dbms_sql.column_value(source_cursor,12,l_no_tmr_ifemale_emps);

		  new_hire_table(l_counter3).no_cons_wmale_emps       := new_hire_table(l_counter3).no_cons_wmale_emps +
		                                                                                       ltrim(rtrim(l_no_tmr_wmale_emps));
                  new_hire_table(l_counter3).no_cons_bmale_emps        := new_hire_table(l_counter3).no_cons_bmale_emps +
		                                                                                       ltrim(rtrim(l_no_tmr_bmale_emps));
                  new_hire_table(l_counter3).no_cons_hmale_emps        := new_hire_table(l_counter3).no_cons_hmale_emps +
		                                                                                       ltrim(rtrim(l_no_tmr_hmale_emps));
                  new_hire_table(l_counter3).no_cons_amale_emps        := new_hire_table(l_counter3).no_cons_amale_emps +
		                                                                                       ltrim(rtrim(l_no_tmr_amale_emps));
                  new_hire_table(l_counter3).no_cons_imale_emps         := new_hire_table(l_counter3).no_cons_imale_emps +
		                                                                                       ltrim(rtrim(l_no_tmr_imale_emps));
                  new_hire_table(l_counter3).no_cons_wfemale_emps    := new_hire_table(l_counter3).no_cons_wfemale_emps +
		                                                                                       ltrim(rtrim(l_no_tmr_wfemale_emps));
                  new_hire_table(l_counter3).no_cons_bfemale_emps     := new_hire_table(l_counter3).no_cons_bfemale_emps +
		                                                                                       ltrim(rtrim(l_no_tmr_bfemale_emps));
                  new_hire_table(l_counter3).no_cons_hfemale_emps     := new_hire_table(l_counter3).no_cons_hfemale_emps +
		                                                                                       ltrim(rtrim(l_no_tmr_hfemale_emps));
                  new_hire_table(l_counter3).no_cons_afemale_emps     := new_hire_table(l_counter3).no_cons_afemale_emps +
		                                                                                      ltrim(rtrim(l_no_tmr_afemale_emps));
                  new_hire_table(l_counter3).no_cons_ifemale_emps      := new_hire_table(l_counter3).no_cons_ifemale_emps +
		                                                                                       ltrim(rtrim(l_no_tmr_ifemale_emps));
                  -- Bug# 6200441
                 new_hire_table(l_counter3).cons_total_category_emps := new_hire_table(l_counter3).cons_total_category_emps +
													ltrim(rtrim(l_no_tmr_wmale_emps)) +
													ltrim(rtrim(l_no_tmr_bmale_emps)) +
													ltrim(rtrim(l_no_tmr_hmale_emps)) +
													ltrim(rtrim(l_no_tmr_amale_emps)) +
													ltrim(rtrim(l_no_tmr_imale_emps)) +
													ltrim(rtrim(l_no_tmr_wfemale_emps)) +
													ltrim(rtrim(l_no_tmr_bfemale_emps)) +
													ltrim(rtrim(l_no_tmr_hfemale_emps)) +
													ltrim(rtrim(l_no_tmr_afemale_emps)) +
													ltrim(rtrim(l_no_tmr_ifemale_emps));

	   END IF;

	   dbms_sql.close_cursor(source_cursor); -- Closing the cursor

     END LOOP; -- End of get_eeo4_lookup_details

  END populate_nh_emp_data; -- End of populate_oft_emp_data

  PROCEDURE generate_ft_xml_data(p_function_code VARCHAR2) IS

  l_function_code  VARCHAR2(32767);
  l_job_category_code VARCHAR2(30);
  l_job_category_name VARCHAR2(80);
  l_cons_total_category_emps NUMBER := 0;
  l_no_cons_wmale_emps NUMBER := 0;
  l_no_cons_bmale_emps NUMBER := 0;
  l_no_cons_hmale_emps NUMBER := 0;
  l_no_cons_amale_emps NUMBER := 0;
  l_no_cons_imale_emps NUMBER := 0;
  l_no_cons_wfemale_emps NUMBER := 0;
  l_no_cons_bfemale_emps NUMBER := 0;
  l_no_cons_hfemale_emps NUMBER := 0;
  l_no_cons_afemale_emps NUMBER := 0;
  l_no_cons_ifemale_emps NUMBER := 0;

  l_cs_no_wmale_emps NUMBER := 0;
  l_cs_no_bmale_emps NUMBER := 0;
  l_cs_no_hmale_emps NUMBER := 0;
  l_cs_no_amale_emps NUMBER := 0;
  l_cs_no_imale_emps NUMBER := 0;
  l_cs_no_wfemale_emps NUMBER := 0;
  l_cs_no_bfemale_emps NUMBER := 0;
  l_cs_no_hfemale_emps NUMBER := 0;
  l_cs_no_afemale_emps NUMBER := 0;
  l_cs_no_ifemale_emps NUMBER := 0;
  l_cs_total_category_emps NUMBER := 0;

  l_lookup_code VARCHAR2(30);
  l_meaning VARCHAR2(80);


  CURSOR get_eeo4_lookup_details IS
  SELECT lookup_code, meaning, description
  FROM hr_lookups
  WHERE lookup_type = 'US_EEO4_JOB_CATEGORIES'
  ORDER BY lookup_code;

  BEGIN

  IF g_for_all_emp = 'T' THEN
    l_function_code := 'AF';
  ELSIF g_for_all_emp = 'F' THEN
    l_function_code := p_function_code;
  END IF;
    -- 1. FULL-TIME EMPLOYEES (Temporary employees are not included)
   l_xml_string := '<G_EMPLOYMENT_CATEGORY>';
   l_xml_string := l_xml_string || convert_into_xml('EMPLOYEE_SALARY_EMPLOYMENT_CAT','1. FULL-TIME EMPLOYEES (Temporary employees are not included)','D');
   l_xml_string := l_xml_string || '<LIST_G_JOB_CATEGORIES>';

   --FND_FILE.PUT_LINE(FND_FILE.LOG,l_xml_string);
   FND_FILE.PUT_LINE(FND_FILE.OUTPUT,l_xml_string);

      FOR i IN get_eeo4_lookup_details LOOP -- for each job category

        l_lookup_code := i.lookup_code;
        l_meaning := i.meaning;



        FOR sal_range in 1.. 8 LOOP
        -- This fix is for the bug#8812609
        CASE sal_range
           WHEN 1 THEN g_salary_range := '$0.1-15.999';
           WHEN 2 THEN g_salary_range := '16.0-19.999';
           WHEN 3 THEN g_salary_range := '20.0-24.999';
           WHEN 4 THEN g_salary_range := '25.0-32.999';
           WHEN 5 THEN g_salary_range := '33.0-42.999';
           WHEN 6 THEN g_salary_range := '43.0-54.999';
           WHEN 7 THEN g_salary_range := '55.0-69.999';
           WHEN 8 THEN g_salary_range := '70.0 PLUS';
       END CASE;


         FOR counter in 1 .. ft_emp_table.count LOOP -- Fetch from ft_emp_table

          IF (ltrim(trim(ft_emp_table(counter).job_function)) = ltrim(rtrim(l_function_code)))
              AND (ltrim(rtrim(ft_emp_table(counter).lookup_code)) = ltrim(rtrim(l_lookup_code)))
              AND (ltrim(rtrim(ft_emp_table(counter).salary_range)) = ltrim(rtrim(g_salary_range)))

          THEN

            IF sal_range = 1 THEN

              l_xml_string := '<G_JOB_CATEGORIES>';
              l_xml_string := l_xml_string || convert_into_xml('JOB_CATEGORY_CODE',ft_emp_table(counter).lookup_code,'D');
              l_xml_string := l_xml_string || convert_into_xml('JOB_CATEGORY_NAME',get_lookup_meaning(1,ltrim(rtrim(to_number(ft_emp_table(counter).lookup_code)))),'D');

	      -- Bug# 5402332 (Issue:13 )
	      IF ltrim(rtrim(l_lookup_code)) = '1' OR ltrim(rtrim(l_lookup_code)) = '7' THEN
	        -- Bug# 5415136
		-- l_xml_string := l_xml_string || convert_into_xml('CF_SET_FUNCTION_DESC',g_func_desc,'D');
		l_xml_string := l_xml_string || convert_into_xml('CONTROL_NUMBER',g_control_number,'D');
		l_xml_string := l_xml_string || convert_into_xml('FUNCTION_NUMBERS',g_function_numbers,'D');
	      END IF;

              l_xml_string := l_xml_string || '<LIST_G_JOB_INFORMATION>';

              --FND_FILE.PUT_LINE(FND_FILE.LOG,l_xml_string);
              FND_FILE.PUT_LINE(FND_FILE.OUTPUT,l_xml_string);

            END IF;


             l_xml_string := '<G_JOB_INFORMATION>';

             l_cs_no_wmale_emps := l_cs_no_wmale_emps + ft_emp_table(counter).no_cons_wmale_emps ;
             l_cs_no_bmale_emps := l_cs_no_bmale_emps + ft_emp_table(counter).no_cons_bmale_emps;
             l_cs_no_hmale_emps := l_cs_no_hmale_emps + ft_emp_table(counter).no_cons_hmale_emps;
             l_cs_no_amale_emps := l_cs_no_amale_emps + ft_emp_table(counter).no_cons_amale_emps;
             l_cs_no_imale_emps := l_cs_no_imale_emps + ft_emp_table(counter).no_cons_imale_emps;
             l_cs_no_wfemale_emps := l_cs_no_wfemale_emps + ft_emp_table(counter).no_cons_wfemale_emps;
             l_cs_no_bfemale_emps := l_cs_no_bfemale_emps + ft_emp_table(counter).no_cons_bfemale_emps;
             l_cs_no_hfemale_emps := l_cs_no_hfemale_emps + ft_emp_table(counter).no_cons_hfemale_emps;
             l_cs_no_afemale_emps := l_cs_no_afemale_emps + ft_emp_table(counter).no_cons_afemale_emps;
             l_cs_no_ifemale_emps := l_cs_no_ifemale_emps + ft_emp_table(counter).no_cons_ifemale_emps;
             l_cs_total_category_emps := l_cs_total_category_emps + ft_emp_table(counter).cons_total_category_emps;

             l_xml_string := l_xml_string || convert_into_xml('EMPLOYEE_SALARY_SALARY_RANGE_A',g_line_number||'. '||ft_emp_table(counter).salary_range,'D');
             l_xml_string := l_xml_string || convert_into_xml('CONS_TOTAL_CATEGORY_EMPS',ft_emp_table(counter).cons_total_category_emps,'D');
             l_xml_string := l_xml_string || convert_into_xml('NO_CONS_WMALE_EMPS',ft_emp_table(counter).no_cons_wmale_emps,'D');
             l_xml_string := l_xml_string || convert_into_xml('NO_CONS_BMALE_EMPS',ft_emp_table(counter).no_cons_bmale_emps,'D');
             l_xml_string := l_xml_string || convert_into_xml('NO_CONS_HMALE_EMPS',ft_emp_table(counter).no_cons_hmale_emps,'D');
             l_xml_string := l_xml_string || convert_into_xml('NO_CONS_AMALE_EMPS',ft_emp_table(counter).no_cons_amale_emps,'D');
             l_xml_string := l_xml_string || convert_into_xml('NO_CONS_IMALE_EMPS',ft_emp_table(counter).no_cons_imale_emps,'D');
             l_xml_string := l_xml_string || convert_into_xml('NO_CONS_WFEMALE_EMPS',ft_emp_table(counter).no_cons_wfemale_emps,'D');
             l_xml_string := l_xml_string || convert_into_xml('NO_CONS_BFEMALE_EMPS',ft_emp_table(counter).no_cons_bfemale_emps,'D');
             l_xml_string := l_xml_string || convert_into_xml('NO_CONS_HFEMALE_EMPS',ft_emp_table(counter).no_cons_hfemale_emps,'D');
             l_xml_string := l_xml_string || convert_into_xml('NO_CONS_AFEMALE_EMPS',ft_emp_table(counter).no_cons_afemale_emps,'D');
             l_xml_string := l_xml_string || convert_into_xml('NO_CONS_IFEMALE_EMPS',ft_emp_table(counter).no_cons_ifemale_emps,'D');

             l_xml_string := l_xml_string || '</G_JOB_INFORMATION>';

             --FND_FILE.PUT_LINE(FND_FILE.LOG,l_xml_string);
             FND_FILE.PUT_LINE(FND_FILE.OUTPUT,l_xml_string);
            -- Increment the line number
            g_line_number := g_line_number + 1 ;
           END IF; -- End of qualifying condition
        END LOOP; -- End of Fetch from ft_emp_table
      END LOOP; -- End of for each salary range
      l_xml_string := '</LIST_G_JOB_INFORMATION></G_JOB_CATEGORIES>';
      --FND_FILE.PUT_LINE(FND_FILE.LOG,l_xml_string);
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT,l_xml_string);
    END LOOP; -- for each job category

      l_xml_string := '</LIST_G_JOB_CATEGORIES>';
      l_xml_string := l_xml_string || convert_into_xml('CF_TOTAL_TITLE',g_line_number||'. TOTAL FULL-TIME (LINES 1-64)','D');
      l_xml_string := l_xml_string || convert_into_xml('CS_NO_WMALE_EMPS', l_cs_no_wmale_emps,'D');
      l_xml_string := l_xml_string || convert_into_xml('CS_NO_BMALE_EMPS', l_cs_no_bmale_emps,'D');
      l_xml_string := l_xml_string || convert_into_xml('CS_NO_HMALE_EMPS', l_cs_no_hmale_emps,'D');
      l_xml_string := l_xml_string || convert_into_xml('CS_NO_AMALE_EMPS', l_cs_no_amale_emps,'D');
      l_xml_string := l_xml_string || convert_into_xml('CS_NO_IMALE_EMPS', l_cs_no_imale_emps,'D');
      l_xml_string := l_xml_string || convert_into_xml('CS_NO_WFEMALE_EMPS', l_cs_no_wfemale_emps,'D');
      l_xml_string := l_xml_string || convert_into_xml('CS_NO_BFEMALE_EMPS', l_cs_no_bfemale_emps,'D');
      l_xml_string := l_xml_string || convert_into_xml('CS_NO_HFEMALE_EMPS', l_cs_no_hfemale_emps,'D');
      l_xml_string := l_xml_string || convert_into_xml('CS_NO_AFEMALE_EMPS', l_cs_no_afemale_emps,'D');
      l_xml_string := l_xml_string || convert_into_xml('CS_NO_IFEMALE_EMPS', l_cs_no_ifemale_emps,'D');
      l_xml_string := l_xml_string || convert_into_xml('CS_TOTAL_CATEGORY_EMPS', l_cs_total_category_emps,'D');
      l_xml_string := l_xml_string || '</G_EMPLOYMENT_CATEGORY>';

      --FND_FILE.PUT_LINE(FND_FILE.LOG,l_xml_string);
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT,l_xml_string);
  END;

  PROCEDURE generate_oft_xml_data(p_function_code VARCHAR2) IS

  l_function_code  VARCHAR2(32767);
  l_job_category_code VARCHAR2(30);
  l_job_category_name VARCHAR2(80);
  l_cons_total_category_emps NUMBER := 0;
  l_no_cons_wmale_emps NUMBER := 0;
  l_no_cons_bmale_emps NUMBER := 0;
  l_no_cons_hmale_emps NUMBER := 0;
  l_no_cons_amale_emps NUMBER := 0;
  l_no_cons_imale_emps NUMBER := 0;
  l_no_cons_wfemale_emps NUMBER := 0;
  l_no_cons_bfemale_emps NUMBER := 0;
  l_no_cons_hfemale_emps NUMBER := 0;
  l_no_cons_afemale_emps NUMBER := 0;
  l_no_cons_ifemale_emps NUMBER := 0;

  l_cs_no_wmale_emps NUMBER := 0;
  l_cs_no_bmale_emps NUMBER := 0;
  l_cs_no_hmale_emps NUMBER := 0;
  l_cs_no_amale_emps NUMBER := 0;
  l_cs_no_imale_emps NUMBER := 0;
  l_cs_no_wfemale_emps NUMBER := 0;
  l_cs_no_bfemale_emps NUMBER := 0;
  l_cs_no_hfemale_emps NUMBER := 0;
  l_cs_no_afemale_emps NUMBER := 0;
  l_cs_no_ifemale_emps NUMBER := 0;
  l_cs_total_category_emps NUMBER := 0;

  BEGIN

      IF g_for_all_emp = 'T' THEN
        l_function_code := 'AF';
      ELSIF g_for_all_emp = 'F' THEN
        l_function_code := p_function_code;
      END IF;
    -- 2. OTHER THAN FULL-TIME EMPLOYEES (Including temporary employees)
     l_xml_string := '<G_EMPLOYMENT_CATEGORY>';
     l_xml_string := l_xml_string || convert_into_xml('EMPLOYEE_SALARY_EMPLOYMENT_CAT','2. OTHER THAN FULL-TIME EMPLOYEES (Including temporary employees)','D');
     l_xml_string := l_xml_string || '<LIST_G_JOB_CATEGORIES>';
     --FND_FILE.PUT_LINE(FND_FILE.LOG,l_xml_string);
     FND_FILE.PUT_LINE(FND_FILE.OUTPUT,l_xml_string);


        FOR counter in 1 .. other_ft_emp_table.count LOOP -- Fetch from other_ft_emp_table


	       IF (ltrim(rtrim(other_ft_emp_table(counter).job_function)) = ltrim(rtrim(l_function_code)))
               THEN

		   l_cs_no_wmale_emps := l_cs_no_wmale_emps + other_ft_emp_table(counter).no_cons_wmale_emps ;
		   l_cs_no_bmale_emps := l_cs_no_bmale_emps + other_ft_emp_table(counter).no_cons_bmale_emps;
		   l_cs_no_hmale_emps := l_cs_no_hmale_emps + other_ft_emp_table(counter).no_cons_hmale_emps;
		   l_cs_no_amale_emps := l_cs_no_amale_emps + other_ft_emp_table(counter).no_cons_amale_emps;
		   l_cs_no_imale_emps := l_cs_no_imale_emps + other_ft_emp_table(counter).no_cons_imale_emps;
		   l_cs_no_wfemale_emps := l_cs_no_wfemale_emps + other_ft_emp_table(counter).no_cons_wfemale_emps;
		   l_cs_no_bfemale_emps := l_cs_no_bfemale_emps + other_ft_emp_table(counter).no_cons_bfemale_emps;
		   l_cs_no_hfemale_emps := l_cs_no_hfemale_emps + other_ft_emp_table(counter).no_cons_hfemale_emps;
		   l_cs_no_afemale_emps := l_cs_no_afemale_emps + other_ft_emp_table(counter).no_cons_afemale_emps;
		   l_cs_no_ifemale_emps := l_cs_no_ifemale_emps + other_ft_emp_table(counter).no_cons_ifemale_emps;
		   l_cs_total_category_emps := l_cs_total_category_emps + other_ft_emp_table(counter).cons_total_category_emps;

		 l_xml_string := '<G_JOB_CATEGORIES>';
		 l_xml_string := l_xml_string || convert_into_xml('JOB_CATEGORY_CODE',other_ft_emp_table(counter).lookup_code,'D');
		 l_xml_string := l_xml_string || convert_into_xml('JOB_CATEGORY_NAME',g_line_number||'. '||get_lookup_meaning(2,to_number(other_ft_emp_table(counter).lookup_code)),'D');
		 l_xml_string := l_xml_string || '<LIST_G_JOB_INFORMATION> <G_JOB_INFORMATION>';

		 l_xml_string := l_xml_string || convert_into_xml('CONS_TOTAL_CATEGORY_EMPS',other_ft_emp_table(counter).cons_total_category_emps,'D');
		 l_xml_string := l_xml_string || convert_into_xml('NO_CONS_WMALE_EMPS',other_ft_emp_table(counter).no_cons_wmale_emps,'D');
		 l_xml_string := l_xml_string || convert_into_xml('NO_CONS_BMALE_EMPS',other_ft_emp_table(counter).no_cons_bmale_emps,'D');
		 l_xml_string := l_xml_string || convert_into_xml('NO_CONS_HMALE_EMPS',other_ft_emp_table(counter).no_cons_hmale_emps,'D');
		 l_xml_string := l_xml_string || convert_into_xml('NO_CONS_AMALE_EMPS',other_ft_emp_table(counter).no_cons_amale_emps,'D');
		 l_xml_string := l_xml_string || convert_into_xml('NO_CONS_IMALE_EMPS',other_ft_emp_table(counter).no_cons_imale_emps,'D');
		 l_xml_string := l_xml_string || convert_into_xml('NO_CONS_WFEMALE_EMPS',other_ft_emp_table(counter).no_cons_wfemale_emps,'D');
		 l_xml_string := l_xml_string || convert_into_xml('NO_CONS_BFEMALE_EMPS',other_ft_emp_table(counter).no_cons_bfemale_emps,'D');
		 l_xml_string := l_xml_string || convert_into_xml('NO_CONS_HFEMALE_EMPS',other_ft_emp_table(counter).no_cons_hfemale_emps,'D');
		 l_xml_string := l_xml_string || convert_into_xml('NO_CONS_AFEMALE_EMPS',other_ft_emp_table(counter).no_cons_afemale_emps,'D');
		 l_xml_string := l_xml_string || convert_into_xml('NO_CONS_IFEMALE_EMPS',other_ft_emp_table(counter).no_cons_ifemale_emps,'D');
		 l_xml_string := l_xml_string || '</G_JOB_INFORMATION></LIST_G_JOB_INFORMATION></G_JOB_CATEGORIES>';
		 --FND_FILE.PUT_LINE(FND_FILE.LOG,l_xml_string);
		 FND_FILE.PUT_LINE(FND_FILE.OUTPUT,l_xml_string);
		 g_line_number := g_line_number + 1;
	       END IF;
	     END LOOP; -- Fetch other than full emp table


      l_xml_string := '</LIST_G_JOB_CATEGORIES>';
      l_xml_string := l_xml_string || convert_into_xml('CF_TOTAL_TITLE',g_line_number||'. '||'TOTAL OTHER THAN FULL TIME(LINES 66 - 73)','D');
      l_xml_string := l_xml_string || convert_into_xml('CS_NO_WMALE_EMPS', l_cs_no_wmale_emps,'D');
      l_xml_string := l_xml_string || convert_into_xml('CS_NO_BMALE_EMPS', l_cs_no_bmale_emps,'D');
      l_xml_string := l_xml_string || convert_into_xml('CS_NO_HMALE_EMPS', l_cs_no_hmale_emps,'D');
      l_xml_string := l_xml_string || convert_into_xml('CS_NO_AMALE_EMPS', l_cs_no_amale_emps,'D');
      l_xml_string := l_xml_string || convert_into_xml('CS_NO_IMALE_EMPS', l_cs_no_imale_emps,'D');
      l_xml_string := l_xml_string || convert_into_xml('CS_NO_WFEMALE_EMPS', l_cs_no_wfemale_emps,'D');
      l_xml_string := l_xml_string || convert_into_xml('CS_NO_BFEMALE_EMPS', l_cs_no_bfemale_emps,'D');
      l_xml_string := l_xml_string || convert_into_xml('CS_NO_HFEMALE_EMPS', l_cs_no_hfemale_emps,'D');
      l_xml_string := l_xml_string || convert_into_xml('CS_NO_AFEMALE_EMPS', l_cs_no_afemale_emps,'D');
      l_xml_string := l_xml_string || convert_into_xml('CS_NO_IFEMALE_EMPS', l_cs_no_ifemale_emps,'D');
      l_xml_string := l_xml_string || convert_into_xml('CS_TOTAL_CATEGORY_EMPS', l_cs_total_category_emps,'D');
      l_xml_string := l_xml_string || '</G_EMPLOYMENT_CATEGORY>';
      --FND_FILE.PUT_LINE(FND_FILE.LOG,l_xml_string);
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT,l_xml_string);
  END;

  PROCEDURE generate_nh_xml_data(p_function_code IN VARCHAR2) IS

  l_job_category_code VARCHAR2(30);
  l_job_category_name VARCHAR2(80);
  l_cons_total_category_emps NUMBER := 0;
  l_no_cons_wmale_emps NUMBER := 0;
  l_no_cons_bmale_emps NUMBER := 0;
  l_no_cons_hmale_emps NUMBER := 0;
  l_no_cons_amale_emps NUMBER := 0;
  l_no_cons_imale_emps NUMBER := 0;
  l_no_cons_wfemale_emps NUMBER := 0;
  l_no_cons_bfemale_emps NUMBER := 0;
  l_no_cons_hfemale_emps NUMBER := 0;
  l_no_cons_afemale_emps NUMBER := 0;
  l_no_cons_ifemale_emps NUMBER := 0;

  l_cs_no_wmale_emps NUMBER := 0;
  l_cs_no_bmale_emps NUMBER := 0;
  l_cs_no_hmale_emps NUMBER := 0;
  l_cs_no_amale_emps NUMBER := 0;
  l_cs_no_imale_emps NUMBER := 0;
  l_cs_no_wfemale_emps NUMBER := 0;
  l_cs_no_bfemale_emps NUMBER := 0;
  l_cs_no_hfemale_emps NUMBER := 0;
  l_cs_no_afemale_emps NUMBER := 0;
  l_cs_no_ifemale_emps NUMBER := 0;
  l_cs_total_category_emps NUMBER := 0;

  BEGIN

      IF g_for_all_emp = 'T' THEN
        l_function_code := 'AF';
      ELSIF g_for_all_emp = 'F' THEN
        l_function_code := p_function_code;
      END IF;

     -- 3. NEW HIRES DURING FISCAL YEAR - Permanent full time only JULY 1 - JUNE 30

     l_xml_string := '<G_EMPLOYMENT_CATEGORY>';
     l_xml_string := l_xml_string || convert_into_xml('EMPLOYEE_SALARY_EMPLOYMENT_CAT','3. NEW HIRES DURING FISCAL YEAR - Permanent full time only JULY 1 - JUNE 30','D');
     l_xml_string := l_xml_string || '<LIST_G_JOB_CATEGORIES>';
     --FND_FILE.PUT_LINE(FND_FILE.LOG,l_xml_string);
     FND_FILE.PUT_LINE(FND_FILE.OUTPUT,l_xml_string);

    FOR counter in 1 .. new_hire_table.count LOOP -- Fetch from other_ft_emp_table


       IF (ltrim(rtrim(new_hire_table(counter).job_function)) = ltrim(rtrim(l_function_code)))THEN

           l_cs_no_wmale_emps := l_cs_no_wmale_emps + new_hire_table(counter).no_cons_wmale_emps ;
           l_cs_no_bmale_emps := l_cs_no_bmale_emps + new_hire_table(counter).no_cons_bmale_emps;
           l_cs_no_hmale_emps := l_cs_no_hmale_emps + new_hire_table(counter).no_cons_hmale_emps;
           l_cs_no_amale_emps := l_cs_no_amale_emps + new_hire_table(counter).no_cons_amale_emps;
           l_cs_no_imale_emps := l_cs_no_imale_emps + new_hire_table(counter).no_cons_imale_emps;
           l_cs_no_wfemale_emps := l_cs_no_wfemale_emps + new_hire_table(counter).no_cons_wfemale_emps;
           l_cs_no_bfemale_emps := l_cs_no_bfemale_emps + new_hire_table(counter).no_cons_bfemale_emps;
           l_cs_no_hfemale_emps := l_cs_no_hfemale_emps + new_hire_table(counter).no_cons_hfemale_emps;
           l_cs_no_afemale_emps := l_cs_no_afemale_emps + new_hire_table(counter).no_cons_afemale_emps;
           l_cs_no_ifemale_emps := l_cs_no_ifemale_emps + new_hire_table(counter).no_cons_ifemale_emps;
           l_cs_total_category_emps := l_cs_total_category_emps + new_hire_table(counter).cons_total_category_emps;

         l_xml_string := '<G_JOB_CATEGORIES>';
         l_xml_string := l_xml_string || convert_into_xml('JOB_CATEGORY_CODE',new_hire_table(counter).lookup_code,'D');
         l_xml_string := l_xml_string || convert_into_xml('JOB_CATEGORY_NAME',g_line_number||'. '||get_lookup_meaning(3,ltrim(rtrim(new_hire_table(counter).lookup_code))),'D');
         l_xml_string := l_xml_string || '<LIST_G_JOB_INFORMATION> <G_JOB_INFORMATION>';

         l_xml_string := l_xml_string || convert_into_xml('CONS_TOTAL_CATEGORY_EMPS',new_hire_table(counter).cons_total_category_emps,'D');
         l_xml_string := l_xml_string || convert_into_xml('NO_CONS_WMALE_EMPS',new_hire_table(counter).no_cons_wmale_emps,'D');
         l_xml_string := l_xml_string || convert_into_xml('NO_CONS_BMALE_EMPS',new_hire_table(counter).no_cons_bmale_emps,'D');
         l_xml_string := l_xml_string || convert_into_xml('NO_CONS_HMALE_EMPS',new_hire_table(counter).no_cons_hmale_emps,'D');
         l_xml_string := l_xml_string || convert_into_xml('NO_CONS_AMALE_EMPS',new_hire_table(counter).no_cons_amale_emps,'D');
         l_xml_string := l_xml_string || convert_into_xml('NO_CONS_IMALE_EMPS',new_hire_table(counter).no_cons_imale_emps,'D');
         l_xml_string := l_xml_string || convert_into_xml('NO_CONS_WFEMALE_EMPS',new_hire_table(counter).no_cons_wfemale_emps,'D');
         l_xml_string := l_xml_string || convert_into_xml('NO_CONS_BFEMALE_EMPS',new_hire_table(counter).no_cons_bfemale_emps,'D');
         l_xml_string := l_xml_string || convert_into_xml('NO_CONS_HFEMALE_EMPS',new_hire_table(counter).no_cons_hfemale_emps,'D');
         l_xml_string := l_xml_string || convert_into_xml('NO_CONS_AFEMALE_EMPS',new_hire_table(counter).no_cons_afemale_emps,'D');
         l_xml_string := l_xml_string || convert_into_xml('NO_CONS_IFEMALE_EMPS',new_hire_table(counter).no_cons_ifemale_emps,'D');
         l_xml_string := l_xml_string || '</G_JOB_INFORMATION></LIST_G_JOB_INFORMATION></G_JOB_CATEGORIES>';

         --FND_FILE.PUT_LINE(FND_FILE.LOG,l_xml_string);
         FND_FILE.PUT_LINE(FND_FILE.OUTPUT,l_xml_string);

         g_line_number := g_line_number + 1;
       END IF;
     END LOOP; -- End of Fetch from other_ft_emp_table

      l_xml_string := '</LIST_G_JOB_CATEGORIES>';
      l_xml_string := l_xml_string || convert_into_xml('CF_TOTAL_TITLE',g_line_number||'. '||'TOTAL NEW HIRES (LINES 75 - 82)','D');
      l_xml_string := l_xml_string || convert_into_xml('CS_NO_WMALE_EMPS', l_cs_no_wmale_emps,'D');
      l_xml_string := l_xml_string || convert_into_xml('CS_NO_BMALE_EMPS', l_cs_no_bmale_emps,'D');
      l_xml_string := l_xml_string || convert_into_xml('CS_NO_HMALE_EMPS', l_cs_no_hmale_emps,'D');
      l_xml_string := l_xml_string || convert_into_xml('CS_NO_AMALE_EMPS', l_cs_no_amale_emps,'D');
      l_xml_string := l_xml_string || convert_into_xml('CS_NO_IMALE_EMPS', l_cs_no_imale_emps,'D');
      l_xml_string := l_xml_string || convert_into_xml('CS_NO_WFEMALE_EMPS', l_cs_no_wfemale_emps,'D');
      l_xml_string := l_xml_string || convert_into_xml('CS_NO_BFEMALE_EMPS', l_cs_no_bfemale_emps,'D');
      l_xml_string := l_xml_string || convert_into_xml('CS_NO_HFEMALE_EMPS', l_cs_no_hfemale_emps,'D');
      l_xml_string := l_xml_string || convert_into_xml('CS_NO_AFEMALE_EMPS', l_cs_no_afemale_emps,'D');
      l_xml_string := l_xml_string || convert_into_xml('CS_NO_IFEMALE_EMPS', l_cs_no_ifemale_emps,'D');
      l_xml_string := l_xml_string || convert_into_xml('CS_TOTAL_CATEGORY_EMPS', l_cs_total_category_emps,'D');
      l_xml_string := l_xml_string || '</G_EMPLOYMENT_CATEGORY>';

      --FND_FILE.PUT_LINE(FND_FILE.LOG,l_xml_string);
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT,l_xml_string);

  END;
  END PER_US_EEO4_PKG;


/
