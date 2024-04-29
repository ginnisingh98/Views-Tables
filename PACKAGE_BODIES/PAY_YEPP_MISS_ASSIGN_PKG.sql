--------------------------------------------------------
--  DDL for Package Body PAY_YEPP_MISS_ASSIGN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_YEPP_MISS_ASSIGN_PKG" AS
/* $Header: pyyeppma.pkb 120.2 2007/01/19 13:52:01 ydevi noship $ */

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

    Name        : pay_yepp_miss_assign_pkg

    File        : pyyeppma.pkb

    Description : Package for the YEPP missing assignments report.
                  The package generates the output file in the specified
                  user format. The current formats supported are
                      - HTML
                      - CSV

    Change List
    -----------
     Date         Name        Vers     Bug No    Description
     -----------  ----------  -------  -------   ------------------------------
     25-OCT-2005  rdhingra    115.0    4674183   Code transferred from
                                                 pyusyema.pkb. US specific
                                                 calls removed from PROCEDURE
                                                 select_employee to make the
                                                 pkg global. Removed display of
                                                 input values from the report
     22-dec-2005  rdhingra    115.1    4779018   Updated Function
                                                 formated_header_string to
                                                 make column headings global
     19-JAN-2007  ydevi       115.2    4886285   adding p_pre_or_gre in the
                                                 definition of
						 formated_header_string
						 Change the code of
						 select_employees to deal with
						 the employees of RL1 and RL2
						 PRE.
******************************************************************************/

/************************************************************
  ** Local Package Variables
  ************************************************************/
  gv_title    VARCHAR2(100) := ' Year End Archive Missing Assignments Report';

  gv_package_name        VARCHAR2(50) := 'pay_yepp_miss_assign_pkg';

/**********************************************************************
 Function to display the Titles of the columns of the employee details
**********************************************************************/
 FUNCTION  formated_header_string(
               p_legislation_code  IN VARCHAR2
              ,p_output_file_type  IN VARCHAR2
	      ,p_pre_or_gre   IN  VARCHAR2 default null
             )RETURN VARCHAR2
  IS

    -- Get National Identifier Name
    CURSOR get_national_id_name(lv_legislation_code IN VARCHAR2) IS
    SELECT message_text
      FROM fnd_new_messages
     WHERE message_name = 'HR_NATIONAL_ID_NUMBER_'|| lv_legislation_code
       AND language_code = USERENV('LANG');

    lv_format1          VARCHAR2(32000);
    lv_ni_name          fnd_new_messages.message_text%TYPE;

  BEGIN

      hr_utility.set_location(gv_package_name || '.formated_header_string', 10);

      lv_ni_name := NULL;
      OPEN get_national_id_name(p_legislation_code);
      FETCH get_national_id_name INTO lv_ni_name;
      CLOSE get_national_id_name;

      lv_ni_name := NVL(lv_ni_name, 'Employee SS #');


      lv_format1 :=
              pay_us_payroll_utils.formated_data_string (p_input_string => 'Year '
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ;
      if (p_pre_or_gre is not null) then
        if p_pre_or_gre= 'PRE' then
           lv_format1 := lv_format1 ||pay_us_payroll_utils.formated_data_string
	                                     (p_input_string => 'PRE '
                                              ,p_bold         => 'Y'
                                              ,p_output_file_type => p_output_file_type);
        elsif p_pre_or_gre = 'GRE' then
	    lv_format1 := lv_format1 ||pay_us_payroll_utils.formated_data_string
	                           (p_input_string => 'GRE '
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type);
	 end if;
      else
         lv_format1 := lv_format1 ||pay_us_payroll_utils.formated_data_string
	                                     (p_input_string => 'GRE '
                                              ,p_bold         => 'Y'
                                              ,p_output_file_type => p_output_file_type);
      end if;

       lv_format1 :=  lv_format1 || pay_us_payroll_utils.formated_data_string
                                        (p_input_string => 'Employee Name '
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||
              pay_us_payroll_utils.formated_data_string (p_input_string => lv_ni_name||' '
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||
              pay_us_payroll_utils.formated_data_string (p_input_string => 'Employee #'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ;

            hr_utility.trace('Static Label1 = ' || lv_format1);


      return lv_format1 ;

      hr_utility.set_location(gv_package_name || '.formated_header_string', 30);

  END formated_header_string;



/***************************************************************
 Function to display the details of the selected employee
***************************************************************/

 FUNCTION  formated_detail_string(
              p_output_file_type  in VARCHAR2
             ,p_year                 VARCHAR2
             ,p_gre                  VARCHAR2
             ,p_Employee_name        VARCHAR2
             ,p_employee_ssn         VARCHAR2
             ,p_emplyee_number       VARCHAR2

             ) RETURN VARCHAR2
  IS

    lv_format1          VARCHAR2(22000);

  BEGIN

      hr_utility.set_location(gv_package_name || '.formated_detail_string', 10);
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
        pay_us_payroll_utils.formated_data_string (p_input_string => P_employee_ssn
                                   ,p_bold         => 'N'
                                   ,p_output_file_type => p_output_file_type) ||
        pay_us_payroll_utils.formated_data_string (p_input_string => p_emplyee_number
                                   ,p_bold         => 'N'
                                   ,p_output_file_type => p_output_file_type);


      hr_utility.trace('Static Label1 = ' || lv_format1);
      return lv_format1;

      hr_utility.set_location(gv_package_name || '.formated_detail_string', 30);



  END formated_detail_string;


/**************************************************************************
   Procedure to display message if no employees are selected
 *************************************************************************/

 PROCEDURE  formated_zero_count(output_file_type VARCHAR2)
       IS
      lvc_message VARCHAR2(200);
      lvc_return_message VARCHAR2(400);
 BEGIN
      null;
          lvc_message :=   'No person was picked up based on selection parameters.' ||
         ' The YEPP Archive for the GRE has no missing assignments.';
          hr_utility.set_location(gv_package_name || '.formated_zero_count', 10);
          FND_FILE.PUT_LINE(FND_FILE.OUTPUT,
                            pay_us_payroll_utils.formated_data_string (p_input_string => lvc_message
                                              ,p_bold         => 'N'
                                              ,p_output_file_type => output_file_type));
          hr_utility.set_location(gv_package_name || '.formated_zero_count', 20);
 END;

 /**************************************************************************
   Procedure to display the name of the assignment set to which the selected
   assignments are added
   ************************************************************************/

 PROCEDURE formated_assign_count(assignment_set_name in VARCHAR2,
                                 assignment_set_id in number,
                                 record_count in number,
                                 assign_set_created in number,
                                 output_file_type in VARCHAR2)
 is
 lvc_message1 VARCHAR2(400);
 lvc_message2 VARCHAR2(400);
 lvc_message3 VARCHAR2(400);
 BEGIN
        IF assign_set_created=1 THEN
 	 lvc_message1 := 'Assignment Set Created : ' || assignment_set_name ;
 	ELSE
 	 lvc_message1 := 'Assignment Set Name : ' || assignment_set_name ;
 	END IF;
        lvc_message2 := 'Assignment Set ID : ' || to_char(assignment_set_id);
        lvc_message3 := 'Number of employees added to the assignment set : ' ||
                         to_char(record_count);
 	hr_utility.set_location(gv_package_name || '.formated_assign_count', 10);

         IF output_file_type ='HTML' THEN
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
         ELSE
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
         END IF;

	hr_utility.set_location(gv_package_name || '.formated_assign_count', 20);
 END;

/**************************************************************************
Procedure to display the Elements having input values of type Money
and not feeding the YE Balances
************************************************************************/

PROCEDURE formated_element_header(
                                  p_output_file_type in VARCHAR2
                                 ,p_static_label    out nocopy VARCHAR2
                                 )
IS

lv_format          VARCHAR2(32000);

BEGIN
hr_utility.set_location(gv_package_name || '.formated_element_header.',10);
lv_format:=  pay_us_payroll_utils.formated_data_string(p_input_string=>'Element Name'
                                                        ,p_output_file_type=>p_output_file_type
                                                        ,p_bold=>'Y')||
             pay_us_payroll_utils.formated_data_string(p_input_string=>'Classification'
                                                        ,p_output_file_type=>p_output_file_type
                                                        ,p_bold=>'Y');
                                                        /*||
             pay_us_payroll_utils.formated_data_string(p_input_string=>'Input Value Name'
                                                        ,p_output_file_type=>p_output_file_type
                                                        ,p_bold=>'Y')*/

p_static_label := lv_format;
hr_utility.trace('Static Label = ' || p_static_label);
hr_utility.set_location(gv_package_name || '.formated_element_header', 20);

END formated_element_header;

/************************************************************
  ** Procedure: formated_element_row
  ** Returns  : Formatted Element Row
  ************************************************************/

PROCEDURE formated_element_row (
                    p_element_name              in varchar2
                   ,p_classification            in varchar2
                   --,p_input_value_name          in VARCHAR2
                   ,p_output_file_type          in VARCHAR2
                   ,p_static_data             out nocopy VARCHAR2
              )
   IS

lv_format VARCHAR2(32000);

BEGIN

hr_utility.set_location(gv_package_name || '.formated_element_row', 10);

lv_format :=
            pay_us_payroll_utils.formated_data_string (p_input_string=>p_element_name
                                                      ,p_output_file_type=>p_output_file_type
                                                      ,p_bold=>'N'
                                                      )||
            pay_us_payroll_utils.formated_data_string (p_input_string=>p_classification
                                                      ,p_output_file_type=>p_output_file_type
                                                      ,p_bold=>'N'
                                                      );
                                                      /*||
            pay_us_payroll_utils.formated_data_string (p_input_string=>p_input_value_name
                                                      ,p_output_file_type=>p_output_file_type
                                                      ,p_bold=>'N'
                                                      );*/

hr_utility.set_location(gv_package_name || '.formated_element_row', 20);

p_static_data := lv_format;
hr_utility.trace('Static Data = ' || lv_format);
hr_utility.set_location(gv_package_name || '.formated_element_row', 30);

END formated_element_row;

/* ******************************************************
   Name: select_employee
   Description: This procedure fetches the assignments
                archived in PAY_US_RPT_TOTALS by the
                package PAY_ARCHIVE_MISSING_ASG_PKG
                and generates the report in the specified
                format.
   *****************************************************/


PROCEDURE select_employee(p_payroll_action_id IN NUMBER,
                          p_effective_date IN VARCHAR2,
                          p_tax_unit_id IN NUMBER,
                          p_session_id in NUMBER)

is


CURSOR c_gre_or_pre_name(p_tax_unit_id number)
IS
   SELECT name
     FROM hr_organization_units
    WHERE  organization_id  = p_tax_unit_id;

CURSOR c_person_id (c_assign_id number)
IS
   SELECT person_id,business_group_id
     FROM per_all_assignments_f
    WHERE assignment_id=c_assign_id;

/* Cursor to get Employee details */

CURSOR c_employee_details ( c_person_id number )
IS
   SELECT employee_number,full_name,national_identifier
     FROM per_people_f
    WHERE  person_id   = c_person_id;

CURSOR c_assignment_set_id
IS
   SELECT hr_assignment_sets_s.nextval
     FROM dual;

CURSOR c_assignment_set_exists(assign_set_name VARCHAR2)
IS
   SELECT assignment_set_id
     FROM hr_assignment_sets
    WHERE assignment_set_name=assign_set_name;

CURSOR c_assignment_amd_exists(c_assignment_id number,c_assignment_set_id number)
IS
   SELECT 1
     FROM hr_assignment_set_amendments
    WHERE assignment_set_id=c_assignment_set_id
      AND assignment_id=c_assignment_id;

CURSOR c_get_business_group_id(c_tax_unit_id number
          )
IS
   SELECT business_group_id
     FROM hr_organization_units
    WHERE organization_id = c_tax_unit_id;

CURSOR c_get_missing_assignments(cp_payroll_action_id NUMBER,
                                 cp_tax_unit_id       NUMBER)
 IS
   SELECT distinct value1
     FROM PAY_US_RPT_TOTALS
    WHERE location_id = cp_payroll_action_id
      AND tax_unit_id = cp_tax_unit_id
      AND attribute1 = 'YEAR END MISSING ASSIGNMENTS';

CURSOR c_get_legislation_code(cp_business_group_id NUMBER
                        ) IS
   SELECT legislation_code
     FROM per_business_groups
    WHERE business_group_id = cp_business_group_id;

CURSOR c_get_elements(cp_business_group_id NUMBER,
                      cp_legislation_code VARCHAR2
                     )
IS
   select /*+ USE_NL(pet, pec)
              INDEX( pet PAY_ELEMENT_TYPES_F_PK) */
          distinct pet.element_name, pec.classification_name
     from pay_element_types_f pet,
          pay_element_classifications pec
   where pet.classification_id = pec.classification_id
      and pet.business_group_id = cp_business_group_id
      and hr_api.return_legislation_code(cp_business_group_id) = cp_legislation_code
      and ((pec.legislation_code = cp_legislation_code and pec.business_group_id is null) or
           (pec.business_group_id = cp_business_group_id and pec.legislation_code is null)
          )
     and not exists
      (
      select 1
        from pay_input_values_f piv,
             pay_balance_feeds_f pbf,
             pay_balance_types pbt,
             pay_defined_balances pdb,
             pay_balance_attributes pba,
             pay_bal_attribute_definitions pbad
       where piv.element_type_id = pet.element_type_id
         and piv.uom = 'M'
         and piv.input_value_id = pbf.input_value_id
         and pbf.balance_type_id = pbt.balance_type_id
         and pbt.balance_type_id = pdb.balance_type_id
         and pdb.defined_balance_id = pba.defined_balance_id
         and pba.attribute_id = pbad.attribute_id
         and pbad.legislation_code = cp_legislation_code
         and pbad.attribute_name in
             (select distinct fcl.lookup_code
                from fnd_common_lookups fcl,
                     fnd_lookup_values flv
               where fcl.lookup_type = 'YE_ARCH_REPORTS_BAL_ATTRIBUTES'
                 and fcl.lookup_type = flv.lookup_type
                 and flv.tag = '+' || cp_legislation_code
                 and fcl.lookup_code = flv.lookup_code
             )
      );

lv_result_value number:=0;
lv_person_id per_people_f.person_id%type;
lv_gre_or_pre_name hr_organization_units.name%type;
lv_emp_name per_people_f.full_name%type;
lv_emp_no per_people_f.employee_number%type;
lv_emp_ssn per_people_f.national_identifier%type;
lv_data_row VARCHAR2(4000);
row_id VARCHAR2(100);
lv_miss_assignments NUMBER :=0;
lv_effective_date date;
lv_assignment_set_id number :=0;
lv_payroll_id number :=NULL;
lv_formula_id number :=NULL;
lv_assign_set_created number :=0;
lv_assignment_amd_exists number:=0;
lv_business_group_id per_all_assignments_f.business_group_id%TYPE;
lv_run_balance_status varchar2(1) := 'N';
lv_balance_attribute_id NUMBER;
lv_assignment_set VARCHAR2(100);
lv_legislative_param varchar2(240);
lv_assignment_id NUMBER(15);
lv_output_file_type VARCHAR2(100);
l_pre_organization_id varchar2(50);

lv_title VARCHAR2(1000);
lv_header_label VARCHAR2(1000);
lv_element_name PAY_ELEMENT_TYPES_F.ELEMENT_NAME%TYPE;
lv_classification_name PAY_ELEMENT_CLASSIFICATIONS.CLASSIFICATION_NAME%TYPE;
--lv_input_value_name PAY_INPUT_VALUES_F.NAME%TYPE;
lv_element_row VARCHAR2(1000);
lv_element_count NUMBER;
lv_legislation_code varchar2(100);
lv_element_info varchar2(200);
lv_element_count_info varchar2(200);
l_pre_or_gre    varchar2(4);
--lv_legislative_parameters  varchar2(500);

BEGIN
--hr_utility.trace_on(null,'rdhingra_PYUSYEMA');
hr_utility.set_location(gv_package_name || '.select_employee', 10);
hr_utility.trace('p_payroll_action_id = ' || p_payroll_action_id);
hr_utility.trace('p_effective_date = ' || p_effective_date);
hr_utility.trace('p_tax_unit_id = ' || p_tax_unit_id);
hr_utility.trace('p_session_id = ' || p_session_id);

lv_effective_date := fnd_date.canonical_to_date(FND_DATE.date_to_canonical(p_effective_date));

select legislative_parameters
  into lv_legislative_param
  from pay_payroll_actions
 where payroll_action_id = p_payroll_action_id;

select pay_us_payroll_utils.get_parameter(
                                          'ASSIGNMENT_SET',
                                          lv_legislative_param),
       pay_us_payroll_utils.get_parameter(
                                          'OUTPUT_TYPE',
                                          lv_legislative_param)
  into lv_assignment_set, lv_output_file_type
  from dual;

l_pre_organization_id := pay_core_utils.get_parameter('TRANSFER_PRE',lv_legislative_param);

if l_pre_organization_id is not null then
	 l_pre_or_gre := 'PRE';
elsif p_tax_unit_id is not null then
	 l_pre_or_gre := 'GRE';
end if;

hr_utility.set_location(gv_package_name || '.select_employee', 20);
hr_utility.trace('lv_assignment_set = ' || lv_assignment_set);
hr_utility.trace('lv_output_file_type = ' || lv_output_file_type);

FND_FILE.PUT_LINE(FND_FILE.OUTPUT,
pay_us_payroll_utils.formated_header_string(gv_title || ':- Tax Year: ' ||
                    to_char(lv_effective_date,'YYYY'),lv_output_file_type ));

open c_get_business_group_id(nvl(p_tax_unit_id,l_pre_organization_id));
fetch c_get_business_group_id into lv_business_group_id;
close c_get_business_group_id;

open c_get_legislation_code(lv_business_group_id);
fetch c_get_legislation_code into lv_legislation_code;
close c_get_legislation_code;
/* Report assignments picked up from PAY_US_RPT_TOTALS*/

hr_utility.set_location(gv_package_name || '.select_employee', 30);

OPEN c_get_missing_assignments(p_payroll_action_id, nvl(p_tax_unit_id,0));
LOOP
   FETCH c_get_missing_assignments into lv_assignment_id;
   hr_utility.trace('lv_assignment_id = ' || lv_assignment_id);
   EXIT when c_get_missing_assignments%NOTFOUND;

   lv_assignment_amd_exists:=0;
   hr_utility.set_location(gv_package_name || '.select_employee', 40);
   IF lv_assignment_id IS NOT NULL THEN
      OPEN c_gre_or_pre_name(nvl(p_tax_unit_id,l_pre_organization_id));
      hr_utility.trace('hhh');
      FETCH c_gre_or_pre_name into lv_gre_or_pre_name;
      CLOSE c_gre_or_pre_name;


      OPEN c_person_id(lv_assignment_id);
      FETCH c_person_id into lv_person_id,lv_business_group_id;
      CLOSE c_person_id;

      OPEN c_employee_details(lv_person_id);
      FETCH c_employee_details into lv_emp_no,lv_emp_name,lv_emp_ssn;
      CLOSE c_employee_details;

      /*create assignment set only when the first row is fetched*/
      hr_utility.set_location(gv_package_name || '.select_employee', 50);
      IF lv_miss_assignments=0 THEN
         IF lv_output_file_type ='HTML' THEN
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '<body>');
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '<table border=1 align=center>');
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '<tr>');
         END IF;


       FND_FILE.PUT_LINE(FND_FILE.OUTPUT,formated_header_string(lv_legislation_code,
                                                                  lv_output_file_type,
								  l_pre_or_gre
                                                                 )
                          );

         IF lv_output_file_type ='HTML' THEN
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '</tr>');
         END IF;

         hr_utility.set_location(gv_package_name || '.select_employee', 60);

         OPEN c_assignment_set_exists(lv_assignment_set);
         FETCH c_assignment_set_exists into lv_assignment_set_id;
         CLOSE c_assignment_set_exists;
         hr_utility.trace('lv_assignment_set_id='||lv_assignment_set_id);
         /*if assignment set does not exist,create a new one*/
         IF lv_assignment_set_id=0 THEN
	    hr_utility.trace('assignment set not exists');
            OPEN c_assignment_set_id;
            FETCH c_assignment_set_id into lv_assignment_set_id;
            CLOSE c_assignment_set_id;
            hr_assignment_sets_pkg.insert_row(row_id,
                                               lv_assignment_set_id,
                                               lv_business_group_id,
                                               lv_payroll_id,
                                               lv_assignment_set,
                                               lv_formula_id);
            lv_assign_set_created:=1;
	    hr_utility.trace('lv_assignment_set_id='||lv_assignment_set_id);
          END IF;

          hr_utility.set_location(gv_package_name || '.select_employee', 70);

      END IF; /*lv_miss_assignments = 0 */

      IF lv_assign_set_created=0 THEN
         hr_utility.trace('assignment set newly created');
         hr_utility.set_location(gv_package_name || '.select_employee', 80);
         OPEN c_assignment_amd_exists(lv_assignment_id,lv_assignment_set_id);
         FETCH c_assignment_amd_exists into lv_assignment_amd_exists;
         CLOSE c_assignment_amd_exists;
	 hr_utility.trace('lv_assignment_amd_exists='||lv_assignment_amd_exists);

         IF lv_assignment_amd_exists=0 THEN
	    hr_utility.trace('lv_assignment_amd_exists='||lv_assignment_amd_exists);
	    /*** inserting into HR_ASSIGNMENT_SET_AMENDMENTS **/
            hr_assignment_set_amds_pkg.insert_row(row_id,lv_assignment_id,lv_assignment_set_id,'I');
         END IF;
      ELSE
         hr_utility.trace('assignment set already exists');
         hr_assignment_set_amds_pkg.insert_row(row_id,lv_assignment_id,lv_assignment_set_id,'I');
      END IF; /*lv_assign_set_created=0 */

      lv_miss_assignments  := lv_miss_assignments  + 1;
      hr_utility.set_location(gv_package_name || '.select_employee', 90);

        hr_utility.trace('lv_gre_or_pre_name ='||lv_gre_or_pre_name);
      lv_data_row :=   formated_detail_string(
                                    lv_output_file_type
                                   ,to_char(lv_effective_date,'YYYY')
                                   ,lv_gre_or_pre_name
                                   ,lv_emp_name
                                   ,lv_emp_ssn
                                   ,lv_emp_no);
      IF lv_output_file_type ='HTML' THEN
         lv_data_row := '<tr>' || lv_data_row || '</tr>' ;
      END IF;
      hr_utility.set_location(gv_package_name || '.select_employee', 40);
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, lv_data_row);
      hr_utility.trace('10');
   END IF; /* lv_assignment_id IS NOT NULL */
END LOOP; /*loop c_get_missing_assignments */
CLOSE c_get_missing_assignments;
hr_utility.set_location(gv_package_name || '.select_employee', 100);

IF lv_output_file_type='HTML' THEN
   FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '</table>');

END IF;

IF lv_miss_assignments=0 THEN
   formated_zero_count(lv_output_file_type);
   hr_utility.set_location(gv_package_name || '.select_employee', 110);
ELSE
   formated_assign_count(lv_assignment_set,
                         lv_assignment_set_id,
                         lv_miss_assignments,
                         lv_assign_set_created,
                         lv_output_file_type);
   hr_utility.set_location(gv_package_name || '.select_employee', 120);

END IF;

IF lv_output_file_type ='HTML' THEN
   UPDATE fnd_concurrent_requests
   SET output_file_type = 'HTML'
   WHERE request_id = FND_GLOBAL.CONC_REQUEST_ID ;
   FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '</table>');
   FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '</body>');
   FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '</HTML>');

   COMMIT;
END IF;
hr_utility.set_location(gv_package_name || '.select_employee', 130);

/* Code to Display Element List */


 lv_element_count := 0;

lv_title := 'Element Information';
FND_FILE.PUT_LINE(fnd_file.output,pay_us_payroll_utils.formated_header_string(
                                                 lv_title
                                                ,lv_output_file_type
                                                ));

lv_element_info := 'Elements which have an Input Value of Type Money' ||
                    ' and are Not Feeding Year End Balances';

IF lv_output_file_type ='HTML' THEN
   FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '<p align=center>');
   FND_FILE.PUT_LINE(FND_FILE.OUTPUT,
               pay_us_payroll_utils.formated_data_string (p_input_string =>lv_element_info,
               p_bold         => 'N',
               p_output_file_type => lv_output_file_type)||'</p>');
ELSE
   FND_FILE.PUT_LINE(FND_FILE.OUTPUT,
               pay_us_payroll_utils.formated_data_string (p_input_string =>lv_element_info,
 			      p_bold         => 'N',
 				   p_output_file_type => lv_output_file_type));
END IF;


hr_utility.set_location(gv_package_name || '.select_employee', 140);

open c_get_elements(lv_business_group_id,
                    lv_legislation_code);
LOOP
   FETCH c_get_elements INTO lv_element_name,
                             lv_classification_name;
   IF c_get_elements%NOTFOUND THEN
   EXIT;
   END IF;

   -- Display Table for HTML and only for 1st record
   IF lv_element_count = 0 THEN
      IF lv_output_file_type ='HTML' THEN

        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '<table border=1 align=CENTER>');
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '<tr>');
      END IF;

      formated_element_header(lv_output_file_type
                       ,lv_header_label);

      FND_FILE.PUT_LINE(fnd_file.output, lv_header_label);
   END IF;

   hr_utility.set_location(gv_package_name || '.select_employee', 150);

   lv_element_count := lv_element_count + 1;
   formated_element_row(lv_element_name
                       ,lv_classification_name
                       ,lv_output_file_type
                       ,lv_element_row);

   hr_utility.trace('lv_element_row = ' || lv_element_row);

   IF lv_output_file_type ='HTML' THEN
      lv_element_row := '<tr>' || lv_element_row || '</tr>' ;
   END IF;

   FND_FILE.PUT_LINE(FND_FILE.OUTPUT, lv_element_row);
END LOOP;
CLOSE c_get_elements;

hr_utility.set_location(gv_package_name || '.select_employee', 160);

IF lv_output_file_type='HTML' and lv_element_count > 0 THEN
   FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '</table>');
--ELSIF lv_element_count = 0 THEN

  -- hr_utility.set_location(gv_package_name || '.select_employee', 170);
END IF;

lv_element_count_info := pay_us_payroll_utils.formated_data_string
                        (p_input_string =>'Number of Elements Found = '|| lv_element_count
                        ,p_bold         => 'N'
                        ,p_output_file_type => lv_output_file_type);

IF lv_output_file_type='HTML' THEN
   FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'<p align="center">');
   FND_FILE.PUT_LINE(FND_FILE.OUTPUT, lv_element_count_info ||'</p>');
ELSE
   FND_FILE.PUT_LINE(FND_FILE.OUTPUT, lv_element_count_info);
END IF;


hr_utility.set_location(gv_package_name || '.select_employee', 180);

END select_employee;

END pay_yepp_miss_assign_pkg;

/
