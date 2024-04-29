--------------------------------------------------------
--  DDL for Package Body PAY_CA_YEPP_MISS_ASSIGN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_CA_YEPP_MISS_ASSIGN_PKG" AS
/* $Header: pycayema.pkb 120.0 2005/05/29 03:55 appldev noship $ */
/*
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
    Name        : pay_ca_yepp_miss_assign_pkg
    File        : pycayema.pkb
    Description : Package for the YEPP missing assignments report.
                  The package generates the output file in the specified
                  user format. The current formats supported are
                      - HTML
                      - CSV
    Change List
    -----------
     Date         Name         Vers    Bug No       Description
     ----         ----         ------  -------      -----------
     11-OCT-2004  ssouresr     115.0   3562508       Created.
     06-NOV-2004  ssouresr     115.1                 Using tables instead of
                                                     restricted views

/************************************************************
  ** Local Package Variables
  ************************************************************/

  gv_title        VARCHAR2(100);
  gv_package_name VARCHAR2(50)  := 'pay_ca_yepp_miss_assign_pkg';

/**********************************************************************
 Function to fetch the Parameter Value from Legislative Parameter
 *********************************************************************/

  function get_parameter(name in varchar2,
                         parameter_list varchar2) return varchar2
  is
    start_ptr number;
    end_ptr   number;
    token_val pay_payroll_actions.legislative_parameters%type;
    par_value pay_payroll_actions.legislative_parameters%type;
  begin

     token_val := name||'=';

     start_ptr := instr(parameter_list, token_val) + length(token_val);
     end_ptr := instr(parameter_list, ' ', start_ptr);

     /* if there is no spaces use then length of the string */
     if end_ptr = 0 then
        end_ptr := length(parameter_list)+1;
     end if;

     /* Did we find the token */
     if instr(parameter_list, token_val) = 0 then
       par_value := NULL;
     else
       par_value := substr(parameter_list, start_ptr, end_ptr - start_ptr);
     end if;

     return par_value;

  end get_parameter;

/**********************************************************************
 Function to display the Titles of the columns of the employee details
**********************************************************************/
 FUNCTION  formated_header_string (p_output_file_type  in VARCHAR2)
 RETURN VARCHAR2
 IS
    lv_format1          VARCHAR2(32000);
    lv_year_heading     VARCHAR2(200);
    lv_emp_sin_heading  VARCHAR2(200);
    lv_emp_name_heading VARCHAR2(200);
    lv_emp_num_heading  VARCHAR2(200);
    lv_gre_heading      VARCHAR2(200);

  BEGIN

      lv_year_heading     := hr_general.decode_lookup('PAY_CA_MISSING_ASG','YEAR');
      lv_emp_sin_heading  := hr_general.decode_lookup('PAY_CA_MISSING_ASG','EMP_SIN');
      lv_emp_num_heading  := hr_general.decode_lookup('PAY_CA_MISSING_ASG','EMP_NUM');
      lv_emp_name_heading := hr_general.decode_lookup('PAY_CA_MISSING_ASG','EMP_NAME');
      lv_gre_heading      := hr_general.decode_lookup('PAY_CA_MISSING_ASG','GRE');

      lv_format1 :=
              pay_us_payroll_utils.formated_data_string (p_input_string => lv_year_heading
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||
              pay_us_payroll_utils.formated_data_string (p_input_string => lv_gre_heading
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||
              pay_us_payroll_utils.formated_data_string (p_input_string => lv_emp_name_heading
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||
              pay_us_payroll_utils.formated_data_string (p_input_string => lv_emp_sin_heading
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||
              pay_us_payroll_utils.formated_data_string (p_input_string => lv_emp_num_heading
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ;

      return lv_format1 ;

  END formated_header_string;

/**********************************************************************
 Function to display the Titles of the columns of the employee details
**********************************************************************/
 FUNCTION  formated_header_string_rl(p_output_file_type  in VARCHAR2)
 RETURN VARCHAR2
 IS
    lv_format1           VARCHAR2(32000);
    lv_year_heading      VARCHAR2(200);
    lv_emp_sin_heading   VARCHAR2(200);
    lv_emp_name_heading  VARCHAR2(200);
    lv_emp_num_heading   VARCHAR2(200);
    lv_pre_heading       VARCHAR2(200);

  BEGIN

      lv_year_heading     := hr_general.decode_lookup('PAY_CA_MISSING_ASG','YEAR');
      lv_emp_sin_heading  := hr_general.decode_lookup('PAY_CA_MISSING_ASG','EMP_SIN');
      lv_emp_num_heading  := hr_general.decode_lookup('PAY_CA_MISSING_ASG','EMP_NUM');
      lv_emp_name_heading := hr_general.decode_lookup('PAY_CA_MISSING_ASG','EMP_NAME');
      lv_pre_heading      := hr_general.decode_lookup('PAY_CA_MISSING_ASG','PRE');

      lv_format1 :=
              pay_us_payroll_utils.formated_data_string (p_input_string => lv_year_heading
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||
              pay_us_payroll_utils.formated_data_string (p_input_string => lv_pre_heading
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||
              pay_us_payroll_utils.formated_data_string (p_input_string => lv_emp_name_heading
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||
              pay_us_payroll_utils.formated_data_string (p_input_string => lv_emp_sin_heading
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||
              pay_us_payroll_utils.formated_data_string (p_input_string => lv_emp_num_heading
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ;

      return lv_format1 ;

  END formated_header_string_rl;

/*******************************************************************************
 Function to display the details of the selected employee for T4/T4A Report Type
********************************************************************************/
 FUNCTION  formated_detail_string(
              p_output_file_type  in VARCHAR2
             ,p_year                 VARCHAR2
             ,p_gre                  VARCHAR2
             ,p_employee_name        VARCHAR2
             ,p_employee_sin         VARCHAR2
             ,p_employee_number      VARCHAR2
             ) RETURN VARCHAR2
  IS
    lv_format1          VARCHAR2(22000);
  BEGIN

      lv_format1 :=
        pay_us_payroll_utils.formated_data_string (p_input_string => p_year
                                   ,p_bold         => 'N'
                                   ,p_output_file_type => p_output_file_type) ||
        pay_us_payroll_utils.formated_data_string (p_input_string => p_gre
                                   ,p_bold         => 'N'
                                   ,p_output_file_type => p_output_file_type) ||
        pay_us_payroll_utils.formated_data_string (p_input_string => p_employee_name
                                   ,p_bold         => 'N'
                                   ,p_output_file_type => p_output_file_type) ||
        pay_us_payroll_utils.formated_data_string (p_input_string => p_employee_sin
                                   ,p_bold         => 'N'
                                   ,p_output_file_type => p_output_file_type) ||
        pay_us_payroll_utils.formated_data_string (p_input_string => p_employee_number
                                   ,p_bold         => 'N'
                                   ,p_output_file_type => p_output_file_type);

      return lv_format1;

  END formated_detail_string;

/*******************************************************************************
 Function to display the details of the selected employee for RL1/RL2 Report Type
********************************************************************************/
 FUNCTION  formated_detail_string_rl(
              p_output_file_type  in VARCHAR2
             ,p_year                 VARCHAR2
             ,p_pre                  VARCHAR2
             ,p_employee_name        VARCHAR2
             ,p_employee_sin         VARCHAR2
             ,p_employee_number      VARCHAR2
             ) RETURN VARCHAR2
  IS
    lv_format1          VARCHAR2(22000);
  BEGIN

      lv_format1 :=
        pay_us_payroll_utils.formated_data_string (p_input_string => p_year
                                   ,p_bold         => 'N'
                                   ,p_output_file_type => p_output_file_type) ||
        pay_us_payroll_utils.formated_data_string (p_input_string => p_pre
                                   ,p_bold         => 'N'
                                   ,p_output_file_type => p_output_file_type) ||
        pay_us_payroll_utils.formated_data_string (p_input_string => p_employee_name
                                   ,p_bold         => 'N'
                                   ,p_output_file_type => p_output_file_type) ||
        pay_us_payroll_utils.formated_data_string (p_input_string => p_employee_sin
                                   ,p_bold         => 'N'
                                   ,p_output_file_type => p_output_file_type) ||
        pay_us_payroll_utils.formated_data_string (p_input_string => p_employee_number
                                   ,p_bold         => 'N'
                                   ,p_output_file_type => p_output_file_type);

      return lv_format1;

  END formated_detail_string_rl;

/**************************************************************************
   Procedure to display message if no employees are selected
 *************************************************************************/
 PROCEDURE  formated_zero_count(output_file_type VARCHAR2)
 IS
      lvc_message VARCHAR2(200);
 BEGIN
    -- lvc_message := 'The Year End Preprocess Archive has no missing assignments';
     lvc_message := hr_general.decode_lookup ('PAY_CA_MISSING_ASG','NO_MISSING_ASG');

     hr_utility.set_location(gv_package_name || '.formated_zero_count', 10);

     FND_FILE.PUT_LINE(FND_FILE.OUTPUT,
                       pay_us_payroll_utils.formated_data_string (p_input_string     => lvc_message
                                                                 ,p_bold             => 'N'
                                                                 ,p_output_file_type => output_file_type));
 END;

 /**************************************************************************
   Procedure to display the name of the assignment set to which the selected
   assignments are added
   ************************************************************************/
 PROCEDURE formated_assign_count(assignment_set_name in varchar2,
                                 assignment_set_id   in number,
                                 record_count        in number,
                                 assign_set_created  in number,
                                 output_file_type    in varchar2)
 IS

 lvc_message1 VARCHAR2(400);
 lvc_message2 VARCHAR2(400);
 lvc_message3 VARCHAR2(400);

 BEGIN
      if assign_set_created = 1 then
	 lvc_message1 := hr_general.decode_lookup('PAY_CA_MISSING_ASG','ASG_SET_CREATED')||': '||assignment_set_name;
      else
 	 lvc_message1 := hr_general.decode_lookup('PAY_CA_MISSING_ASG','ASG_SET_NAME')||': '||assignment_set_name;
      end if;

      lvc_message2 := hr_general.decode_lookup('PAY_CA_MISSING_ASG','ASG_SET_ID')||': '||to_char(assignment_set_id);
      lvc_message3 := hr_general.decode_lookup('PAY_CA_MISSING_ASG','NUMBER_OF_ASG')||': '||to_char(record_count);

      if output_file_type ='HTML' then
               FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '<br>');
               FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '<br>');
               FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '<table align=center>');
 	   FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'<tr>'||
 	       pay_us_payroll_utils.formated_data_string (p_input_string =>lvc_message1,
 			             p_bold         => 'N',
 				     p_output_file_type => output_file_type)||'</tr>');
           FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'<tr>'||
               pay_us_payroll_utils.formated_data_string (p_input_string =>lvc_message2,
 				     p_bold         => 'N',
 				     p_output_file_type => output_file_type)||'</tr>');
           FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'<tr>'||
               pay_us_payroll_utils.formated_data_string (p_input_string =>lvc_message3,
 				     p_bold         => 'N',
 				     p_output_file_type => output_file_type)||'</tr>');
      else
           FND_FILE.PUT_LINE(FND_FILE.OUTPUT,
               pay_us_payroll_utils.formated_data_string (p_input_string =>lvc_message1,
 			             p_bold         => 'N',
 				     p_output_file_type => output_file_type));
           FND_FILE.PUT_LINE(FND_FILE.OUTPUT,
               pay_us_payroll_utils.formated_data_string (p_input_string =>lvc_message2,
 				     p_bold         => 'N',
 				     p_output_file_type => output_file_type));
           FND_FILE.PUT_LINE(FND_FILE.OUTPUT,
               pay_us_payroll_utils.formated_data_string (p_input_string =>lvc_message3,
 				     p_bold         => 'N',
 			             p_output_file_type => output_file_type));
      end if;

 END;

/* ******************************************************
   The PROCEDURE called FROM the concurrent program.
   Name: select_employee
   Description: The input parameters for the procedure are
   Date,GRE/PRE,Assignment Set and output file type from
   the concurrent program. The procedure identifies the
   missing assignments , adds them to the assignment
   set entered and generates the report in the specified
   format.
   *****************************************************/

PROCEDURE select_employee(errbuf             OUT NOCOPY  VARCHAR2,
                          retcode            OUT NOCOPY  NUMBER,
                          p_effective_date   IN          VARCHAR2,
                          p_bus_grp          IN          NUMBER,
                          p_report_type      IN          VARCHAR2,
                          p_dummy1           IN          VARCHAR2,
                          p_gre_id           IN          NUMBER,
                          p_dummy2           IN          VARCHAR2,
                          p_pre_id           IN          NUMBER,
                          p_assign_set       IN          VARCHAR2,
			  p_output_file_type IN          VARCHAR2)
IS

/* Cursor to select primary assignments that are not archived by the
  YEPP in the given year for the given GRE */

     CURSOR c_missing_assignments(cp_effective_date date,
                                  cp_bus_grp        number,
                                  cp_report_type    varchar2,
                                  cp_tax_unit_id    number) is
     SELECT DISTINCT asg.assignment_id  ass_id
     FROM   per_all_assignments_f  asg,
            pay_assignment_actions paa,
            pay_payroll_actions    ppa,
            per_all_people_f       ppf
     WHERE ppa.effective_date BETWEEN cp_effective_date
                                  AND add_months(cp_effective_date, 12) - 1
     AND  ppa.action_type in ('R','Q','V','B','I')
     AND  ppa.payroll_action_id = paa.payroll_action_id
     AND  paa.tax_unit_id = cp_tax_unit_id
     AND  paa.assignment_id = asg.assignment_id
     AND  ppa.business_group_id+0 = cp_bus_grp
     AND  ppa.business_group_id = asg.business_group_id +0
     AND  asg.person_id = ppf.person_id
     AND  asg.assignment_type  = 'E'
     AND  ppa.effective_date between asg.effective_start_date AND  asg.effective_end_date
     AND  ppa.effective_date between ppf.effective_start_date AND  ppf.effective_end_date
     AND NOT EXISTS ( SELECT 1
                      FROM pay_payroll_actions ppa1,
                           pay_assignment_actions paa1
                      WHERE ppa1.report_type = cp_report_type
		      AND ppa1.report_qualifier = 'CAEOY'
                      AND ppa1.effective_date = add_months(cp_effective_date, 12) - 1
                      AND get_parameter('TRANSFER_GRE',ppa1.legislative_parameters) = to_char(cp_tax_unit_id)
                      AND ppa1.payroll_action_id = paa1.payroll_action_id
                      AND ppa1.business_group_id+0 = cp_bus_grp
                      AND paa1.serial_number = to_char(ppf.person_id))
     ORDER  BY asg.assignment_id DESC;

/* Cursor to select primary assignments that are not archived by the
  YEPP in the given year for the given PRE of Report Type RL1*/

     CURSOR c_missing_assignments_rl1(cp_effective_date date,
                                      cp_bus_grp        number,
                                      cp_report_type    varchar2,
                                      cp_pre_id         number) is
     SELECT DISTINCT ASG.assignment_id      ass_id
     FROM   per_all_assignments_f  ASG,
            pay_all_payrolls_f     PPY,
            hr_soft_coding_keyflex SCL
     WHERE  ASG.business_group_id + 0  =  cp_bus_grp
     AND  ASG.assignment_type        = 'E'
     AND  ASG.effective_start_date  <= add_months(cp_effective_date, 12) - 1
     AND  ASG.effective_end_date    >= cp_effective_date
     AND  SCL.soft_coding_keyflex_id = ASG.soft_coding_keyflex_id
     AND  (
              (rtrim(ltrim(SCL.segment1))  in
               (select to_char(hoi.organization_id)
                from  hr_organization_information hoi
                where hoi.org_information_context =  'Canada Employer Identification'
                and   hoi.org_information2  = to_char(cp_pre_id) ))
            or
              (rtrim(ltrim(SCL.segment11))  in
                (select to_char(hoi.organization_id)
                from    hr_organization_information hoi
                where   hoi.org_information_context =  'Canada Employer Identification'
                and hoi.org_information2  = to_char(cp_pre_id) ))
            )
     AND  PPY.payroll_id           = ASG.payroll_id
     AND EXISTS    (select 'X'
                    from  pay_action_contexts pac, ff_contexts fc
                    where pac.assignment_id = asg.assignment_id
                    and   pac.context_id = fc.context_id
                    and   fc.context_name = 'JURISDICTION_CODE'
                    and   pac.context_value = 'QC')
     AND NOT EXISTS (SELECT 1
                     FROM   pay_payroll_actions ppa,
                            pay_assignment_actions paa
                     WHERE ppa.report_type = cp_report_type
	    	     AND   ppa.report_qualifier = 'CAEOYRL1'
                     AND   ppa.effective_date = add_months(cp_effective_date, 12) - 1
                     AND   get_parameter('PRE_ORGANIZATION_ID',ppa.legislative_parameters) = to_char(cp_pre_id)
                     AND   ppa.payroll_action_id = paa.payroll_action_id
                     AND   ppa.business_group_id+0 = cp_bus_grp
                     AND   paa.serial_number = to_char(ASG.person_id))
     ORDER  BY asg.assignment_id DESC;

/* Cursor to select primary assignments that are not archived by the
  YEPP in the given year for the given PRE of Report Type RL2 */

     CURSOR c_missing_assignments_rl2(cp_effective_date date,
                                      cp_bus_grp        number,
                                      cp_report_type    varchar2,
                                      cp_pre_id         number) is
     SELECT DISTINCT ASG.assignment_id      ass_id
     FROM   per_all_assignments_f  ASG,
            pay_all_payrolls_f     PPY,
            hr_soft_coding_keyflex SCL
     WHERE  ASG.business_group_id + 0  = cp_bus_grp
       AND  ASG.assignment_type        = 'E'
       AND  ASG.effective_start_date  <= add_months(cp_effective_date, 12) - 1
       AND  ASG.effective_end_date    >= cp_effective_date
       AND  SCL.soft_coding_keyflex_id = ASG.soft_coding_keyflex_id
       AND  rtrim(ltrim(SCL.segment12))  in
            (select to_char(hoi.organization_id)
             from   hr_organization_information hoi
             where  hoi.org_information_context =  'Canada Employer Identification'
              and   hoi.org_information2  = to_char(cp_pre_id)
              and   hoi.org_information5 = 'T4A/RL2')
       AND  PPY.payroll_id             = ASG.payroll_id
       AND  EXISTS (select 'X' from pay_action_contexts pac, ff_contexts fc
                    where pac.assignment_id = asg.assignment_id
                    and   pac.context_id = fc.context_id
                    and   fc.context_name = 'JURISDICTION_CODE'
                    and   pac.context_value = 'QC')
       AND NOT EXISTS (SELECT 1
                       FROM pay_payroll_actions ppa,
                            pay_assignment_actions paa
                       WHERE ppa.report_type = cp_report_type
		       AND ppa.report_qualifier = 'CAEOYRL2'
                       AND ppa.effective_date = add_months(cp_effective_date, 12) - 1
                       AND get_parameter('PRE_ORGANIZATION_ID',ppa.legislative_parameters)= to_char(cp_pre_id)
                       AND ppa.payroll_action_id = paa.payroll_action_id
                       AND ppa.business_group_id+0 = cp_bus_grp
                       AND paa.serial_number = to_char(ASG.person_id))
     ORDER  BY asg.assignment_id DESC;

/* Cursor to check if the assignment selected has atleast a single
   non zero run result value with an input value of Money in the
   entered year */

  CURSOR c_non_zero_run_result(cp_business_group number,
                             cp_assignment_id  number,
                             cp_effective_date date,
                             cp_tax_unit_id    number) is
  SELECT 1 FROM dual
  WHERE EXISTS (SELECT 1
                  FROM pay_run_results prr,
                       pay_run_result_values prrv,
                       pay_input_values_f piv,
                       pay_assignment_actions paa,
                       pay_payroll_actions ppa,
                       pay_all_payrolls_f ppf
                 WHERE ppa.business_group_id+0 = cp_business_group
                   AND paa.assignment_id = cp_assignment_id
                   AND paa.tax_unit_id = cp_tax_unit_id
                   AND prr.assignment_action_id = paa.assignment_action_id
                   AND ppa.payroll_action_id = paa.payroll_action_id
                   AND ppa.action_type in ('R','B','Q','V','I')
                   AND ppa.effective_date between cp_effective_date
                                       AND add_months(cp_effective_date, 12) - 1
                   AND ppa.payroll_id = ppf.payroll_id
                   AND ppa.effective_date between ppf.effective_start_date
                       AND ppf.effective_end_date
                   AND ppf.payroll_id > 0
                   AND prrv.run_result_id = prr.run_result_id
                   AND prrv.result_value <> '0'
                   AND piv.input_value_id = prrv.input_value_id
                   AND ppa.effective_date between piv.effective_Start_date
                                              AND piv.effective_end_date
                   AND piv.uom = 'M'
                   AND EXISTS (SELECT '1'
                               FROM pay_balance_feeds_f pbf
                               WHERE piv.input_value_id = pbf.input_value_id
                               AND   ppa.effective_date BETWEEN pbf.effective_Start_date
                                                            AND pbf.effective_end_date));

CURSOR c_name(p_org_id number) IS
SELECT name
FROM hr_all_organization_units_tl
WHERE  organization_id  = p_org_id
AND    language         = userenv('LANG');

CURSOR c_person_id(c_assign_id number) IS
SELECT person_id
FROM per_all_assignments_f
WHERE assignment_id       = c_assign_id
AND   business_group_id+0 = p_bus_grp;

CURSOR c_assignment_no(c_assign_id number) IS
SELECT assignment_number
FROM per_all_assignments_f
WHERE  assignment_id   = c_assign_id;

CURSOR c_employee_details(c_person_id number) IS
SELECT full_name,national_identifier
FROM per_all_people_f
WHERE  person_id   = c_person_id;

CURSOR c_assignment_set_id IS
SELECT hr_assignment_sets_s.nextval
FROM dual;

CURSOR c_assignment_set_exists(assign_set_name VARCHAR2) IS
SELECT assignment_set_id
FROM hr_assignment_sets
WHERE assignment_set_name=assign_set_name;

CURSOR c_assignment_amd_exists(c_assignment_id     number,
                               c_assignment_set_id number) IS
SELECT 1
FROM hr_assignment_set_amendments
WHERE assignment_set_id = c_assignment_set_id
AND assignment_id       = c_assignment_id;

CURSOR c_all_gres(cp_pre_id    number) IS
SELECT hoi.organization_id gre_id
FROM  hr_organization_information hoi,
      hr_all_organization_units   hou
WHERE hoi.org_information_context =  'Canada Employer Identification'
AND hoi.org_information2  = to_char(cp_pre_id)
AND hou.business_group_id = p_bus_grp
AND hou.organization_id   = hoi.organization_id;


/* Local variables */

lv_assn_id             per_all_assignments_f.assignment_id%type;
lv_result_value        number;
lv_person_id           per_all_people_f.person_id%type;
lv_gre_name            hr_all_organization_units_tl.name%type;
lv_pre_name            hr_all_organization_units_tl.name%type;
lv_emp_name            per_all_people_f.full_name%type;
lv_emp_no              per_all_people_f.employee_number%type;
lv_emp_sin             per_all_people_f.national_identifier%type;
lv_data_row            varchar2(4000);
row_id                 varchar2(100);
lv_miss_assignments    number;
lv_effective_date      date;
lv_assignment_set_id   number;
lv_payroll_id          number;
lv_formula_id          number;
lv_assign_set_created  number ;
lv_assignment_amd_exists number;


BEGIN

 lv_result_value          :=0;
 lv_miss_assignments      :=0;
 lv_assignment_set_id     :=0;
 lv_payroll_id            :=NULL;
 lv_formula_id            :=NULL;
 lv_assign_set_created    :=0;
 lv_assignment_amd_exists :=0;
 lv_effective_date        := FND_DATE.canonical_to_date(p_effective_date);

 -- 'Year End Archive Missing Assignments Report'
 gv_title          := hr_general.decode_lookup('PAY_CA_MISSING_ASG','MISSING_REPORT_HEADING');

 FND_FILE.PUT_LINE(FND_FILE.OUTPUT,
    pay_us_payroll_utils.formated_header_string(gv_title || ' - '|| p_report_type ||' '||
                to_char(lv_effective_date,'YYYY'), p_output_file_type ));

 IF  p_report_type IN ('T4','T4A') THEN
        hr_utility.trace('The value of gre is '||p_gre_id);
        OPEN  c_missing_assignments(lv_effective_date,p_bus_grp,p_report_type,p_gre_id) ;

 ELSIF p_report_type = 'RL1' THEN
        hr_utility.trace('The value of pre is '||p_pre_id);
        OPEN  c_missing_assignments_rl1(lv_effective_date,p_bus_grp,p_report_type,p_pre_id) ;
 ELSE
        hr_utility.trace('The value of pre is '||p_pre_id);
        OPEN  c_missing_assignments_rl2(lv_effective_date,p_bus_grp,p_report_type,p_pre_id) ;

 END IF;

 LOOP
     IF p_report_type IN ('T4','T4A') THEN

        FETCH c_missing_assignments INTO lv_assn_id;
        EXIT WHEN c_missing_assignments%notfound ;

     ELSIF p_report_type = 'RL1' THEN

        FETCH c_missing_assignments_rl1 INTO lv_assn_id;
        EXIT WHEN c_missing_assignments_rl1%notfound ;

     ELSE

        FETCH c_missing_assignments_rl2 INTO lv_assn_id;
        EXIT WHEN c_missing_assignments_rl2%notfound ;

     END IF;

     lv_result_value := 0;

   /* Check for nonzero run_result_value for assignments picked up*/

     IF p_report_type IN ('T4','T4A') THEN

         OPEN  c_non_zero_run_result(p_bus_grp,
                                     lv_assn_id,
                                     lv_effective_date,
                                     p_gre_id);

         FETCH c_non_zero_run_result into lv_result_value;
         CLOSE c_non_zero_run_result;

     ELSE

     /* If the report type is RL1/RL2 we need to fetch the GRE's which are under this
        PRE and then we need to check for the run result values of these GRE's */

        FOR i IN c_all_gres(p_pre_id)
        LOOP

          OPEN  c_non_zero_run_result(p_bus_grp,
                                      lv_assn_id,
                                      lv_effective_date,
                                      i.gre_id);

          FETCH c_non_zero_run_result into lv_result_value;
          CLOSE c_non_zero_run_result;

          IF lv_result_value = 1 THEN
             EXIT;
          END IF;

        END LOOP;

     END IF;

     lv_assignment_amd_exists := 0;

     IF lv_result_value = 1 THEN

        IF p_report_type IN ('T4','T4A') THEN

	    OPEN c_name(p_gre_id);
            FETCH c_name into lv_gre_name;
            CLOSE c_name;

        ELSE

            OPEN c_name(p_pre_id);
 	    FETCH c_name into lv_pre_name;
            CLOSE c_name;

        END IF;

 	OPEN c_person_id(lv_assn_id);
     	FETCH c_person_id into lv_person_id;
 	CLOSE c_person_id;

 	OPEN c_assignment_no(lv_assn_id);
     	FETCH c_assignment_no into lv_emp_no;
 	CLOSE c_assignment_no;

     	OPEN c_employee_details(lv_person_id);
     	FETCH c_employee_details into lv_emp_name,lv_emp_sin;
     	CLOSE c_employee_details;

        /*create assignment set only when the first row is fetched*/

         IF lv_miss_assignments=0 THEN

              IF p_output_file_type ='HTML' THEN
                 FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '<body>');
                 FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '<table border=1 align=center>');
                 FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '<tr>');
              END IF;

              IF p_report_type in ('T4','T4A') THEN

                 FND_FILE.PUT_LINE(FND_FILE.OUTPUT,formated_header_string(p_output_file_type));
              ELSE
                 FND_FILE.PUT_LINE(FND_FILE.OUTPUT,formated_header_string_rl(p_output_file_type));
              END IF;

              IF p_output_file_type ='HTML' THEN
                 FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '</tr>');
              END IF;

              OPEN c_assignment_set_exists(p_assign_set);
              FETCH c_assignment_set_exists into lv_assignment_set_id;
              CLOSE c_assignment_set_exists;

          /*if assignment set does not exist,create a new one*/

              IF lv_assignment_set_id = 0 THEN

                 OPEN c_assignment_set_id;
                 FETCH c_assignment_set_id into lv_assignment_set_id;
                 CLOSE c_assignment_set_id;

              /* Inserting the New Assignment set into hr_assignment_sets table */
                 hr_assignment_sets_pkg.insert_row(row_id,
                                                   lv_assignment_set_id,
                                                   p_bus_grp,
                                                   lv_payroll_id,
                                                   p_assign_set,
                                                   lv_formula_id);
                 lv_assign_set_created := 1;

              END IF;

         END IF;

	 IF lv_assign_set_created = 0 THEN

         /*Checking for the Existence of the Assignment Set */

	    OPEN c_assignment_amd_exists(lv_assn_id,lv_assignment_set_id);
	    FETCH c_assignment_amd_exists into lv_assignment_amd_exists;
	    CLOSE c_assignment_amd_exists;

	    IF lv_assignment_amd_exists=0 THEN
               hr_assignment_set_amds_pkg.insert_row(row_id,lv_assn_id,lv_assignment_set_id,'I');
            END IF;

         ELSE
            hr_assignment_set_amds_pkg.insert_row(row_id,lv_assn_id,lv_assignment_set_id,'I');
         END IF;

         lv_miss_assignments  := lv_miss_assignments  + 1;

         IF p_report_type IN ('T4','T4A') THEN
	     lv_data_row := formated_detail_string(p_output_file_type
                                                  ,to_char(lv_effective_date,'YYYY')
                                                  ,lv_gre_name
	     	                                  ,lv_emp_name
	                                          ,lv_emp_sin
	                                          ,lv_emp_no);
         ELSE
             lv_data_row := formated_detail_string_rl(p_output_file_type
                                                     ,to_char(lv_effective_date,'YYYY')
                                                     ,lv_pre_name
	     	                                     ,lv_emp_name
	                                             ,lv_emp_sin
	                                             ,lv_emp_no);
         END IF;

         IF p_output_file_type ='HTML' THEN
             lv_data_row := '<tr>' || lv_data_row || '</tr>' ;
         END IF;

         FND_FILE.PUT_LINE(FND_FILE.OUTPUT, lv_data_row);

     END IF; /*non zero run result value for the assignment*/

 END LOOP; /*loop for checking the nonzero run_result values for selected assignments*/

 IF p_output_file_type='HTML' THEN
   FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '</table>');
 END IF;

 /* If No Assignments are fetched */
 IF lv_miss_assignments = 0 THEN

 	formated_zero_count(p_output_file_type);
 ELSE
 	formated_assign_count(p_assign_set,
                              lv_assignment_set_id,
 	                      lv_miss_assignments,
                              lv_assign_set_created,
                              p_output_file_type);
 END IF;

 IF p_output_file_type ='HTML' THEN

     UPDATE fnd_concurrent_requests
     SET output_file_type = 'HTML'
     WHERE request_id = FND_GLOBAL.CONC_REQUEST_ID ;
     FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '</table>');
     FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '</body>');
     FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '</HTML>');

     COMMIT;

 END IF;

END select_employee;

END pay_ca_yepp_miss_assign_pkg;

/
