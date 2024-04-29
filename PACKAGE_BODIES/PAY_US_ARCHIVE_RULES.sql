--------------------------------------------------------
--  DDL for Package Body PAY_US_ARCHIVE_RULES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_US_ARCHIVE_RULES" AS
/* $Header: payusarcyema.pkb 120.1 2007/01/23 09:28:33 ydevi noship $ */
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
   Name        : PAY_US_ARCHIVE_RULES
   Description : This package contains the rules for archiving
                 for missing assignment report specific to US legislation
   --
   Change List
   -----------
   Date         Name        Vers   Bug       Description
   -----------  ----------  -----  --------  ----------------------------------
   24-Oct-2005  rdhingra    115.0            Created
   19-JAN-2007  ydevi       115.1  4886285   adding the condition for
                                             GRE in range_cursor
					     and action creation
					     adding the procedure archive_code.
					     added procedure archive_code

******************************************************************************/
gv_package_name        VARCHAR2(50) := 'pay_us_archive_rules.';


----------------------------------- range_cursor ------------------------------
procedure range_cursor (pactid in number, sqlstr out nocopy varchar2) is

   l_proc               VARCHAR2(240);
   l_gre_id             VARCHAR2(50);
   lv_legislative_param   VARCHAR2(240);
begin

   l_proc := gv_package_name||'range_cursor';
   hr_utility.set_location(l_proc, 10);
   hr_utility.trace('PACTID = '||to_char(pactid));
   hr_utility.trace('PACTID = '||to_char(pactid));
   select ppa.legislative_parameters
   into lv_legislative_param
   from pay_payroll_actions ppa
   where payroll_action_id = pactid;
   l_gre_id := pay_core_utils.get_parameter('TRANSFER_GRE',lv_legislative_param);
   sqlstr := 'AND PAA.tax_unit_id = '||to_number(l_gre_id);

   hr_utility.set_location(l_proc, 20);
   hr_utility.trace(sqlstr);

   exception when others then
      hr_utility.set_location(l_proc, 30);
end range_cursor;

---------------------------------- action_creation ----------------------------------
--
PROCEDURE action_creation(pactid    IN NUMBER,
                          stperson  IN NUMBER,
                          endperson IN NUMBER,
                          chunk     IN NUMBER,
                          sqlstr    OUT NOCOPY VARCHAR2) IS

   l_proc            VARCHAR2(240);
   ld_effective_date DATE;
   ld_year_end       DATE;
   ln_tax_unit_id    NUMBER;
BEGIN
   l_proc := gv_package_name||'range_cursor';
   hr_utility.set_location(l_proc, 10);

   hr_utility.trace('PACTID = '||to_char(pactid));

   SELECT effective_date,
          pay_core_utils.get_parameter('TRANSFER_GRE',legislative_parameters)
     INTO ld_effective_date,
          ln_tax_unit_id
     FROM pay_payroll_actions
    WHERE payroll_action_id = pactid;

   ld_year_end := add_months(trunc(ld_effective_date, 'Y'),12) -1;
   hr_utility.trace('year end '|| to_char(ld_year_end,'dd-mm-yyyy'));
   sqlstr := ' AND PAA.tax_unit_id = '||to_number(ln_tax_unit_id);
   sqlstr := sqlstr ||' AND not exists (SELECT 1
                            FROM pay_payroll_actions ppa,
                                 pay_assignment_actions paa
                           WHERE ppa.report_type = ''YREND''
                             AND ppa.action_status = ''C''
                             AND ppa.effective_date = '''|| ld_year_end ||'''
                             AND pay_core_utils.get_parameter(
                                 ''TRANSFER_GRE'',
                                 legislative_parameters) = '|| ln_tax_unit_id ||'
                             AND ppa.payroll_action_id = paa.payroll_action_id
                             AND paa.action_status = ''C''
                             AND ppa.business_group_id = paf.business_group_id
                             AND paa.serial_number = TO_CHAR(paf.person_id))';

   hr_utility.set_location(l_proc, 20);
   hr_utility.trace(sqlstr);

   EXCEPTION WHEN OTHERS THEN
      hr_utility.set_location(l_proc, 30);
END action_creation;

PROCEDURE archive_code (pactid    IN NUMBER,
                        sqlstr    OUT NOCOPY VARCHAR2) IS

   l_gre_id               VARCHAR2(50);
   lv_legislative_param   VARCHAR2(240);
   l_proc            VARCHAR2(240);

BEGIN
   l_proc := gv_package_name||'archive_code';
   hr_utility.set_location(l_proc, 10);

   hr_utility.trace('PACTID = '||to_char(pactid));

   select ppa.legislative_parameters
   into lv_legislative_param
   from pay_payroll_actions ppa
   where payroll_action_id = pactid;

   l_gre_id := pay_core_utils.get_parameter('TRANSFER_GRE',lv_legislative_param);
   sqlstr := 'AND PAA.tax_unit_id = '||to_number(l_gre_id);
   hr_utility.set_location(l_proc, 20);
   hr_utility.trace(sqlstr);

   EXCEPTION WHEN OTHERS THEN
      hr_utility.set_location(l_proc, 30);
 END archive_code;

--begin
--hr_utility.trace_on(null,'YREND_YEMA');

END PAY_US_ARCHIVE_RULES;

/
