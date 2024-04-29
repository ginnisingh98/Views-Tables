--------------------------------------------------------
--  DDL for Package Body PER_US_EEO4_EXP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_US_EEO4_EXP_PKG" AS
/* $Header: peruseeo4exp.pkb 120.0.12000000.1 2007/06/27 07:18:43 jdevasah noship $ */
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

    Name        : PER_US_EEO4_EXP_PKG
    File Name   : peruseeo4exp.pkb

    Description : This package creates XML file for EEO4 exception Report.

    Change List
    -----------
    Date                 Name       Vers     Bug No    Description
    -----------       ---------- ------    -------     --------------------------
    18-JUN-2007       jdevasah   115.0                 Created.

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
  --l_report_end_date date;
begin
  l_report_date := to_date ('30-06'|| p_reporting_year,'dd-mm-yyyy');

  l_query := 'SELECT peo.full_name name,
                     peo.employee_number employee_number,
                     decode(peo.per_information1,
                                              13, ''Ethnic Origin is "Two or More Races" and "Additional Ethnic Code" is missing'',
                                            null, ''Ethnic Origin is missing'') exception_reason
             FROM per_all_people_f             	peo,
                 per_all_assignments_f        	ass,
                 per_assignment_status_types    past,
                 per_pay_proposals		ppp,
                 per_jobs                      	job,
                 per_pay_bases			ppb,
                 hr_lookups			hl
             WHERE peo.person_id = ass.person_id
               AND ass.pay_basis_id = ppb.pay_basis_id
               AND ass.assignment_id = ppp.assignment_id
               AND hl.lookup_code = job.job_information1
               AND job.job_information1 IS NOT NULL
               AND job.job_information_category = ''US''
               AND hl.lookup_type = ''US_EEO4_JOB_CATEGORIES''
               AND ass.job_id = job.job_id
               AND ass.primary_flag = ''Y''
               AND ppp.change_date  = ( SELECT  MAX(change_date)
                                          FROM	per_pay_proposals  pro
                                         WHERE	ppp.assignment_id = pro.assignment_id
                                           AND	pro.change_date <= ''' || to_char(l_report_date) || '''
                                           AND     pro.approved = ''Y'' )
               AND ass.organization_id IN (SELECT	organization_id
                                             FROM	hr_all_organization_units
                                            WHERE	business_group_id = ' || p_business_group_id || '
                                              AND	SYSDATE BETWEEN  date_from AND NVL(date_to,SYSDATE) )
               AND ass.assignment_status_type_id = past.assignment_status_type_id
               AND peo.current_employee_flag = ''Y''
               AND ass.assignment_type = ''E''
               AND ''' || to_char(l_report_date) || ''' BETWEEN peo.effective_start_date AND peo.effective_end_date
               AND ''' || to_char(l_report_date) || ''' BETWEEN ass.effective_start_date AND ass.effective_end_date
               AND past.per_system_status <> ''TERM_ASSIGN''
               AND (peo.per_information1 is null
	            OR (peo.per_information1 =''13''
		        AND not EXISTS (SELECT 1
			              FROM per_people_extra_info ppei
                                     WHERE ppei.information_type=''PER_US_ADDL_ETHNIC_CAT''
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

END PER_US_EEO4_EXP_PKG;



/
