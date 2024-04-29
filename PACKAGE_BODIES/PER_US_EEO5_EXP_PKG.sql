--------------------------------------------------------
--  DDL for Package Body PER_US_EEO5_EXP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_US_EEO5_EXP_PKG" AS
/* $Header: peruseeo5exp.pkb 120.0.12000000.1 2007/06/27 07:19:49 jdevasah noship $ */
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

    Name        : PER_US_EEO5_EXP_PKG
    File Name   : peruseeo5exp.pkb

    Description : This package creates XML file for EEO5 exception Report.

    Change List
    -----------
    Date                 Name       Vers     Bug No    Description
    -----------       ---------- ------    -------     --------------------------
    26-JUN-2007       jdevasah   115.0                 Created.

    ****************************************************************************/


procedure generate_exception_report( errbuf OUT NOCOPY VARCHAR2
                                         ,retcode OUT NOCOPY NUMBER
                                         ,p_business_group_id varchar2
                                         , p_reporting_year number) is

 qryCtx DBMS_XMLGEN.ctxHandle;
  l_result CLOB;
  l_query varchar2(10000);
  l_report_date date;
  l_xml_string varchar2(32000);
  l_business_group_name varchar2(240);

  l_fr   VARCHAR2(2000);
  l_ft   VARCHAR2(2000);
  l_pr   VARCHAR2(2000);
  l_pt   VARCHAR2(2000);
begin
  l_report_date := to_date ('30-09'|| p_reporting_year,'dd-mm-yyyy');
  pqh_employment_category.fetch_empl_categories(p_business_group_id
                                               ,l_fr
                                               ,l_ft
                                               ,l_pr
                                               ,l_pt);

  l_query := 'SELECT peo.full_name name,
                     peo.employee_number employee_number,
                     decode(peo.per_information1,
                                              13, ''Ethnic Origin is "Two or More Races" and "Additional Ethnic Code" is missing'',
                                            null, ''Ethnic Origin is missing'') exception_reason
              FROM   per_all_people_f                peo,
                     per_all_assignments_f           ass,
                     per_assignment_status_types     ast,
                     per_jobs                        job,
                     hr_lookups                      hl
              WHERE  peo.person_id = ass.person_id
                AND  peo.current_employee_flag = ''Y''
                AND  hl.lookup_code = job.job_information1
                AND  pqh_employment_category.identify_empl_category(ass.employment_category,
		                                                    ' || l_fr || ',' || l_ft || ','
								    || l_pr ||',' || l_pt || ') IN (''FR'',''PR'')
                AND  hl.lookup_type = ''US_EEO5_JOB_CATEGORIES''
                AND  job.job_information_category = ''US''
                AND  ''' || to_char(l_report_date) || ''' BETWEEN peo.effective_start_date AND peo.effective_end_date
                AND  ''' || to_char(l_report_date) || ''' BETWEEN ass.effective_start_date AND ass.effective_end_date
                AND  ass.primary_flag	= ''Y''
                AND  ass.assignment_status_type_id = ast.assignment_status_type_id
                AND  ast.per_system_status  <> ''TERM_ASSIGN''
                AND  ass.job_id = job.job_id
                AND  ass.assignment_type = ''E''
                AND  ass.organization_id  IN (
                     	SELECT organization_id
                	FROM   hr_all_organization_units
     	                WHERE  business_group_id = '||p_business_group_id || ')
                AND (peo.per_information1 is null
	             OR (peo.per_information1 =''13''
		         AND not EXISTS (SELECT 1
			                 FROM   per_people_extra_info ppei
                                         WHERE  ppei.information_type=''PER_US_ADDL_ETHNIC_CAT''
				           AND ppei.pei_information5 IS not NULL
				           AND ppei.person_id=peo.person_id)
                         )
	            )';

FND_FILE.PUT_LINE(FND_FILE.LOG,l_query);

  qryCtx :=  dbms_xmlgen.newContext (l_query);

l_xml_string := '<?xml version="1.0"?>';
FND_FILE.PUT_LINE(FND_FILE.LOG,l_xml_string);
FND_FILE.PUT_LINE(FND_FILE.OUTPUT,l_xml_string);

l_xml_string := '<ROWSET>';
FND_FILE.PUT_LINE(FND_FILE.LOG,l_xml_string);
FND_FILE.PUT_LINE(FND_FILE.OUTPUT,l_xml_string);

--Load 5 records at a time
DBMS_XMLGEN.setMaxRows(qryCtx, 5);
LOOP
--save the XML into the CLOB field
 l_result :=  DBMS_XMLGEN.getXML(qryCtx);
 l_xml_string := substr( l_result, instr(l_result,'<ROW>',1),instr(l_result,'</ROWSET>',-1) - instr(l_result,'<ROW>',1));
 --insert into tab_clob values (to_char(l_xml_string));
 EXIT WHEN DBMS_XMLGEN.getNumRowsProcessed(qryCtx) = 0;
 FND_FILE.PUT_LINE(FND_FILE.LOG,l_xml_string);
 FND_FILE.PUT_LINE(FND_FILE.OUTPUT,l_xml_string);

END LOOP;

-- Get Name of the business group.
SELECT name into l_business_group_name from hr_organization_units
  WHERE organization_id = p_business_group_id
  AND business_group_id = p_business_group_id;

-- Load Header tags
l_xml_string := '<C_BUSINESS_GROUP_NAME> '|| l_business_group_name ||' </C_BUSINESS_GROUP_NAME>
<C_REPORT_DATE> ' || to_char(l_report_date, 'dd-Mon-yyyy') ||' </C_REPORT_DATE>
<C_REPORT_YEAR> ' || p_reporting_year ||' </C_REPORT_YEAR>
</ROWSET>';
FND_FILE.PUT_LINE(FND_FILE.LOG,l_xml_string);
FND_FILE.PUT_LINE(FND_FILE.OUTPUT,l_xml_string);

end generate_exception_report;

END PER_US_EEO5_EXP_PKG;



/
