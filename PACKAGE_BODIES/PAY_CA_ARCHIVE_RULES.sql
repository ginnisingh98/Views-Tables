--------------------------------------------------------
--  DDL for Package Body PAY_CA_ARCHIVE_RULES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_CA_ARCHIVE_RULES" AS
/* $Header: paycaarcyema.pkb 120.4.12010000.5 2008/11/13 15:16:12 sneelapa ship $ */
/******************************************************************************

   ******************************************************************
   *                                                                *
   *  Copyright (C) 1996 Oracle Corporation.                        *
   *  All rights reserved.                                          *
   *                                                                *
   *  This material has been provided pursuant to an agreement      *
   *  containing restrictions on its use.  The material is also     *
   *  protected by copyright law.  No part of this material may     *
   *  be copied or distributed, transmitted or transcribed, in      *
   *  any form or by any means, electronic, mechanical, magnetic,   *
   *  manual, or otherwise, or disCLOSEd to third parties without   *
   *  the express written permission of Oracle Corporation,         *
   *  500 Oracle Parkway, Redwood City, CA, 94065.                  *
   *                                                                *
   ******************************************************************
   --
   Name        : PAY_CA_ARCHIVE_RULES
   Description : This package contains the rules for archiving
                 for missing assignment report specific to CA legislation
   --
   Change List
   -----------
   Date         Name        Vers   Bug       Description
   -----------  ----------  -----  --------  ----------------------------------
   30-NOV-2005  pganguly    115.0            Created
   19-JAN-2007  ydevi       115.1  4886285   adding the condition for
                                             RL1 and RL2 PRE in range_cursor
					     and action creation
					     adding the procedure archive_code
   08-OCT-2007 sapalani     115.3  6454571   Added condition in action_creation
                                             to include only Quebec location
                                             assignments for RL1 and RL2
   13-NOV-2007 sapalani     115.4  6454571   Modified condition in action_creation
                                             to include only Quebec location
                                             assignments for RL1 and RL2

   07-NOV-2008 sneelapa     115.5  7518875   Modified condition in action_creation
                                             to check whether Employee is in Quebec
                                             location in the Year for which
                                             Missing Assignments concurrent request
                                             is executed.
   07-NOV-2008 sneelapa     115.6  7518875   Modified condition in action_creation
                                             to check whether Employee is in Quebec
                                             location in the Year for which
                                             Missing Assignments concurrent request
                                             is executed.
   10-NOV-2008 sneelapa     115.7  7518875   Modified condition in action_creation
                                             to check whether Employee is in Quebec
                                             Comparing the STATE from
                                             pay_action_context table instead of
                                             per_all_assignments_f table.

   13-NOV-2008 sneelapa     115.8  7518875    Modified code to resolve QA reported issue
                                              during testing the bug 7518875.
                                              If QC check is present in ACTION_CREATION
                                              Procedure, it was validating the Employees
                                              for whom Quickpay is executed.
                                              This Validation was not working for Employees
                                              for whom Payroll RUN was executed.
                                              Commented the code in "action_creation"
                                              procedure and added the code to check
                                              QC in ARCHIVE_CODE procedure.
******************************************************************************/
gv_package_name        VARCHAR2(50) := 'pay_ca_archive_rules.';


----------------------------------- range_cursor ------------------------------
procedure range_cursor (pactid in number, sqlstr out nocopy varchar2) is

   l_proc               VARCHAR2(240);
   l_pre_organization_id  VARCHAR2(50);
   l_gre_id               VARCHAR2(50);
   lv_legislative_param   VARCHAR2(240);

begin

   l_proc := gv_package_name||'range_cursor';
   hr_utility.set_location(l_proc, 10);

   hr_utility.trace('PACTID = '||to_char(pactid));
   select ppa.legislative_parameters
   into lv_legislative_param
   from pay_payroll_actions ppa
   where payroll_action_id = pactid;
   l_pre_organization_id := pay_core_utils.get_parameter('TRANSFER_PRE',lv_legislative_param);
   l_gre_id := pay_core_utils.get_parameter('TRANSFER_GRE',lv_legislative_param);

   if (l_gre_id is not null) then
      sqlstr := 'AND PAA.tax_unit_id = '||to_number(l_gre_id);
   elsif (l_pre_organization_id is not null) then
      sqlstr := 'AND exists
                     (   select 1
                         from hr_organization_information hoi
                         where hoi.org_information_context =  ''Canada Employer Identification''
                         and hoi.org_information2  = '''|| l_pre_organization_id||'''
                         and hoi.org_information5 in (''T4/RL1'',''T4A/RL1'',''T4A/RL2'')
                         and PAA.tax_unit_id=hoi.organization_id
                      )';

   end if;
   hr_utility.set_location(l_proc, 20);
   hr_utility.trace(sqlstr);

   exception when others then
      hr_utility.set_location(l_proc, 30);
end range_cursor;
---------------------------------- action_creation -----------------------------------
PROCEDURE action_creation(pactid    IN NUMBER,
                          stperson  IN NUMBER,
                          endperson IN NUMBER,
                          chunk     IN NUMBER,
                          sqlstr    OUT NOCOPY VARCHAR2) IS

   l_proc            VARCHAR2(240);
   ld_effective_date DATE;
   -- ld_year_start added by sneelapa for bug 7518875
   ld_year_start     DATE;
   ld_year_end       DATE;
   ln_tax_unit_id    NUMBER;
   l_report_type     VARCHAR2(30);
   l_pre_organization_id  VARCHAR2(50);

BEGIN
   l_proc := gv_package_name||'action_creation';
   hr_utility.set_location(l_proc, 10);
   hr_utility.trace('PACTID = '||to_char(pactid));
   SELECT effective_date,
          pay_core_utils.get_parameter('TRANSFER_GRE',legislative_parameters),
          pay_core_utils.get_parameter('TRANSFER_PRE',legislative_parameters),
          pay_core_utils.get_parameter('REPORT_TYPE',legislative_parameters)
     INTO ld_effective_date,
          ln_tax_unit_id,
          l_pre_organization_id,
          l_report_type
     FROM pay_payroll_actions
    WHERE payroll_action_id = pactid;

   ld_year_start := trunc(ld_effective_date, 'Y');
   hr_utility.trace('year start new '|| to_char(ld_year_start,'dd-mm-yyyy'));

   ld_year_end := add_months(trunc(ld_effective_date, 'Y'),12) -1;
   hr_utility.trace('year end '|| to_char(ld_year_end,'dd-mm-yyyy'));

   if (ln_tax_unit_id is not null) then
      sqlstr := 'AND PAA.tax_unit_id = '||to_number(ln_tax_unit_id);
   elsif (l_pre_organization_id is not null) then
       sqlstr := 'AND exists
                     (   select 1
                         from hr_organization_information hoi
                         where hoi.org_information_context =  ''Canada Employer Identification''
                         and hoi.org_information2  = '''|| l_pre_organization_id||'''
                         and hoi.org_information5 in (''T4/RL1'',''T4A/RL1'',''T4A/RL2'')
                         and PAA.tax_unit_id=hoi.organization_id
                      )';
   end if;
   sqlstr := sqlstr ||'AND not exists (SELECT 1
                            FROM pay_payroll_actions ppa,
                                 pay_assignment_actions paa
                           WHERE ppa.report_type = ''' || l_report_type ||
                             ''' AND ppa.action_status = ''C''
                             AND ppa.effective_date = '''|| ld_year_end ||'''
                             AND ppa.payroll_action_id = paa.payroll_action_id
                             AND paa.action_status = ''C''
                             AND ppa.business_group_id = paf.business_group_id
                             AND paa.serial_number = TO_CHAR(paf.person_id))';

   -- To include only Quebec location assignments for RL1 and RL2 (Bug: 6454571)

   -- modified for bug 7518875
   -- Same validation is carried out in "archive_code" procedure, hence commenting the code.
/*   if (l_report_type in ('RL1', 'RL2')) then
   -- Modified the logic for checking QC state.
   -- Comparing the pay_action_context data instead of per_all_assignments_f
   --   table location id.
	sqlstr := sqlstr ||' AND exists
				( select 1
				  from  pay_action_contexts pac, ff_contexts fc,
          pay_assignment_actions paa1
				  where paa1.payroll_action_id = ppa.payroll_action_id
          and   pac.context_id = fc.context_id
          and   paa1.assignment_action_id = pac.assignment_action_id
          and   ppa.effective_date BETWEEN '''||ld_year_start||''' and '''
              || ld_year_end ||'''
          and   fc.context_name = ''JURISDICTION_CODE''
          and   pac.context_value = ''QC'') ';
   end if;
*/
   hr_utility.set_location(l_proc, 20);
   hr_utility.trace(sqlstr);

   EXCEPTION WHEN OTHERS THEN
      hr_utility.set_location(l_proc, 30);
END action_creation;

PROCEDURE archive_code (pactid    IN NUMBER,
                        sqlstr    OUT NOCOPY VARCHAR2) IS

   l_pre_organization_id  VARCHAR2(50);
   l_gre_id               VARCHAR2(50);
   lv_legislative_param   VARCHAR2(240);
   l_proc            VARCHAR2(240);

   -- fix for bug 7518875 starts here.
   ld_effective_date DATE;
   ld_year_start     DATE;
   ld_year_end       DATE;
   l_report_type     VARCHAR2(30);
   -- fix for bug 7518875 ends here.

BEGIN
   l_proc := gv_package_name||'archive_code';
   hr_utility.set_location(l_proc, 10);

   hr_utility.trace('PACTID = '||to_char(pactid));
   select ppa.legislative_parameters
   into lv_legislative_param
   from pay_payroll_actions ppa
   where payroll_action_id = pactid;
   l_pre_organization_id := pay_core_utils.get_parameter('TRANSFER_PRE',lv_legislative_param);
   l_gre_id := pay_core_utils.get_parameter('TRANSFER_GRE',lv_legislative_param);

   -- fix for bug 7518875 starts here.

   SELECT effective_date,
          pay_core_utils.get_parameter('REPORT_TYPE',legislative_parameters)
   INTO ld_effective_date,
        l_report_type
   FROM pay_payroll_actions
   WHERE payroll_action_id = pactid;

   ld_year_start := trunc(ld_effective_date, 'Y');
   hr_utility.trace('year start new '|| to_char(ld_year_start,'dd-mm-yyyy'));

   ld_year_end := add_months(trunc(ld_effective_date, 'Y'),12) -1;
   hr_utility.trace('year end '|| to_char(ld_year_end,'dd-mm-yyyy'));

   -- fix for bug 7518875 ends here.

   if (l_gre_id is not null) then
      sqlstr := 'AND PAA.tax_unit_id = '||to_number(l_gre_id);
   elsif (l_pre_organization_id is not null) then
       sqlstr := 'AND exists
                     (   select 1
                         from hr_organization_information hoi
                         where hoi.org_information_context =  ''Canada Employer Identification''
                         and hoi.org_information2  = '''|| l_pre_organization_id||'''
                         and hoi.org_information5 in (''T4/RL1'',''T4A/RL1'',''T4A/RL2'')
                         and PAA.tax_unit_id=hoi.organization_id
                      )';
   end if;

  -- fix for bug 7518875 starts here.

   if (l_report_type in ('RL1', 'RL2')) then
  	sqlstr := sqlstr ||' AND exists
				( select 1
				  from  pay_action_contexts pac, ff_contexts fc--,pay_assignment_actions paa1
				  where pac.context_id = fc.context_id
          and   paa.assignment_action_id = pac.assignment_action_id
          and   ppa.effective_date BETWEEN '''||ld_year_start||''' and '''
              || ld_year_end ||'''
          and   fc.context_name = ''JURISDICTION_CODE''
          and   pac.context_value = ''QC'') ';

   end if;

   -- fix for bug 7518875 ends here.

   hr_utility.set_location(l_proc, 20);
   hr_utility.trace(sqlstr);

   EXCEPTION WHEN OTHERS THEN
      hr_utility.set_location(l_proc, 30);
 END archive_code;

--begin
--hr_utility.trace_on(null,'YREND_YEMA');

END PAY_CA_ARCHIVE_RULES;

/
