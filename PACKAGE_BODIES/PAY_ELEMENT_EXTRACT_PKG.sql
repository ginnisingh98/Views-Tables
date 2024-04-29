--------------------------------------------------------
--  DDL for Package Body PAY_ELEMENT_EXTRACT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_ELEMENT_EXTRACT_PKG" AS
/* $Header: pyelerep.pkb 120.7.12010000.3 2008/08/29 10:20:46 keyazawa ship $ */
--
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
   *  manual, or otherwise, or disclosed to third parties without   *
   *  the express written permission of Oracle Corporation,         *
   *  500 Oracle Parkway, Redwood City, CA, 94065.                  *
   *                                                                *
   ******************************************************************

    Name        : pay_element_extract_pkg

    Description : Package for the Elements Reports. The package
                  generated the output file in the specified user
                  format. The current formats supported are
                      - HTML
                      - CSV

    Change List
    -----------
     Date        Name      Vers    Bug No    Description
     ----        ----      ------  -------   -----------
     04-AUG-2000 ahanda    115.0             Created.
     14-SEP-2000 ahanda    115.1   1407284   Corrected package name.
     25-SEP-2000 ahanda    115.2   1416995   Adding delete for PL/SQL
                                             table.
     10-OCT-2000 ahanda    115.3             Added check to pick only the
                                             selected employee if employee
                                             ID is passed and only not null
                                             run results.
     02-FEB-2001 ahanda    115.4   1625762   Added check for business group
     26-APR-2001 ahanda    115.5   1755126   Changed logic for Elment Sets.
     22-MAY-2001 ahanda    115.6             Changed parameter in cursor
                                             c_element_results to
                                             cp_element_set_id from
                                             cp_element_type_id when joining
                                             to element_Set_id
     26-JUN-2001 ahanda    115.7   1855697   Changed logic for populate PL/SQL
                                             table with result_value to take
                                             care of multiple element entries.
     17-AUG-2001 ahanda    115.8   1918074   Changed cursor c_element_results
                                             for performance.
     04-DEC-2002 dsaxby    115.13  2692195   Nocopy changes.
     18-DEC-2002 tclewis   115.12  2390994   Modifications to the element_extract
                                             procedure, c_assignments cursor.
                                             Broke out the cursor into 2 querries
                                             to Reduce High Buffer gets.

     05-AUG-2003 trugless  115.13            Replaced hardcoded text for
                                             report headings and
                                             gv_title with lookup to
                                             FND_COMMON_LOOKUPS table using
                                             hr_general.decode_fnd_comm_lookup
                                             function

                                             Modified c_element_results,
                                             c_class_elements,c_set_elements,
                                             and c_elements cursors to use the
                                             PAY_ELELMENT_TYPES_F_TL table
                                             instead of
                                             PAY_ELELMENT_TYPES_F for reporting
                                             name so translated value will be
                                             used.

                                             modified the c_element_results
                                             to query the
                                             PAY_INPUT_VALUES_F_TL table for
     25-FEB-2003 ssmukher 115.14 2007614     Added a new cursor c_legislation_code
                                             for handling the
                                             changing of  SSN to SIN in case
                                             of CA legislation in the procedure
                                             formated_static_header
     16-JUN-2004 ahanda   115.15 3433727     Changed code to use ref cursor.
                                 2007614     Changed cursor c_legislation_code to
                                             use base table instead of view.
    16-JUL-2004  schauhan 115.16 3731178     Changed cursor c_class_elements,c_set_elements
                                             c_elements and query string
                                             lv_element_result_query.
					     Now element name shall be shown if reporting
                                             name is null. Also made changes to
                                             lv_element_result_query so that new
					     garnishment elements are also processed.
    19-JUL-2004  schauhan  115.18 3731178    Reverted back to version 115.16
    20-JUL-2004  ahanda    115.19 3778025    Changes query lv_element_result_query
                                             to use bind parameters. Also, removed
                                             special login for Invol Calculator element.
    10-SEP-2004  schauhan  115.20 3650988    Changed the size of the variable lv_employment_category_code
                                             from Varchar2(10) to per_assignments_f.employment_category%type.
    10-MAR-2005  rajeesha  115.21 4214739    Used Status Column in ltr_elements in Extract_element
					     to avoid the entries which are Replace
    24-APR-2006  ppanda    115.23 5167072    Element Register Report was not picking up
                                             any data for Secondary classification.
    26-APR-2006  ppanda    115.23 5179163    Element Register Report was not having correct
    28-JUN-2006  asasthan  115.24 5231257    Performance tuning added hints
    08-AUG-2006  jdevasah  115.25 5229191    Added two parameters to cursors c_class_elements and
    		 	   	  	     c_set_elements and added conditions to filter elements that are not
                                               eligible for the given Element Report period.
    13-DEC-2006  saurgupt  115.27 5684493    Changed the union clause to union all in lv_element_result_query.
                                             With this the report will now sum up the values for multiple entries
                                             of same report.
    01-AUG-2007 vaprakas 115.29  6075462 Added a distinct clause and selected pay_run_results.run_result_id
                                                       in the cursor lv_element_result_query.
    28-AUG-2008  keyazawa  115.30 7264010    Fixed lv_element_result_query to work properly
                                             multiple entry, same reporting name, secondary class parameter
    29-AUG-2008  keyazawa  115.31            Fixed lv_element_result_query to work properly
                                             additional entry, retro pay entry
                                             Fixed lv_element_status condition to exclude R, O, U
                                             due to work properly override entry
*/

  /************************************************************
  ** Local Package Variables
  ************************************************************/
  gv_title               VARCHAR2(100);
  --gv_title               VARCHAR2(100) := ' Element Register ';
  gc_csv_delimiter       VARCHAR2(1) := ',';
  gc_csv_data_delimiter  VARCHAR2(1) := '"';

  gv_html_start_data     VARCHAR2(5) := '<td>'  ;
  gv_html_end_data       VARCHAR2(5) := '</td>' ;

  gv_package_name        VARCHAR2(50) := 'pay_element_extract_pkg';


  /******************************************************************
  ** Function Returns the formated input string based on the
  ** Output format. If the format is CSV then the values are returned
  ** seperated by comma (,). If the format is HTML then the returned
  ** string as the HTML tags. The parameter p_bold only works for
  ** the HTML format.
  ******************************************************************/
  FUNCTION formated_data_string
             (p_input_string     in varchar2
             ,p_output_file_type in varchar2
             ,p_bold             in varchar2 default 'N'
             )
  RETURN VARCHAR2
  IS

    lv_format          varchar2(1000);

  BEGIN
    hr_utility.set_location(gv_package_name || '.formated_data_string', 10);
    if p_output_file_type = 'CSV' then
       hr_utility.set_location(gv_package_name || '.formated_data_string', 20);
       lv_format := gc_csv_data_delimiter || p_input_string ||
                           gc_csv_data_delimiter || gc_csv_delimiter;
    elsif p_output_file_type = 'HTML' then
       if p_input_string is null then
          hr_utility.set_location(gv_package_name || '.formated_data_string', 30);
          lv_format := gv_html_start_data || '&nbsp;' || gv_html_end_data;
       else
          if p_bold = 'Y' then
             hr_utility.set_location(gv_package_name || '.formated_data_string', 40);
             lv_format := gv_html_start_data || '<b> ' || p_input_string
                             || '</b>' || gv_html_end_data;
          else
             hr_utility.set_location(gv_package_name || '.formated_data_string', 50);
             lv_format := gv_html_start_data || p_input_string || gv_html_end_data;
          end if;
       end if;
    end if;

    hr_utility.set_location(gv_package_name || '.formated_data_string', 60);
    return lv_format;

  END formated_data_string;


  /************************************************************
  ** Function returns the string with the HTML Header tags
  ************************************************************/
  FUNCTION formated_header_string
             (p_input_string     in varchar2
             ,p_output_file_type in varchar2
             )
  RETURN VARCHAR2
  IS

    lv_format          varchar2(1000);

  BEGIN
    hr_utility.set_location(gv_package_name || '.formated_header_string', 10);
    if p_output_file_type = 'CSV' then
       hr_utility.set_location(gv_package_name || '.formated_header_string', 20);
       lv_format := p_input_string;
    elsif p_output_file_type = 'HTML' then
       hr_utility.set_location(gv_package_name || '.formated_header_string', 30);
       lv_format := '<HTML><HEAD> <CENTER> <H1> <B>' || p_input_string ||
                             '</B></H1></CENTER></HEAD>';
    end if;

    hr_utility.set_location(gv_package_name || '.formated_header_string', 40);
    return lv_format;

  END formated_header_string;


  /*****************************************************************
  ** This procudure returns the Mandatory Static Labels and the
  ** Other Additional Static columns. The other static columns are
  ** printed after all the Element Information is printed for each
  ** employee assignment.
  ** The users can add hooks to this package to print more additional
  ** data which they require for this report.
  ** The package prints the user data from a PL/SQL table. The users
  ** can insert data and the label in this PL/SQL table which will
  ** be printed at the end of the report.
  ** The PL/SQL table which needs to be populated is
  ** LTR_ELEMENT_EXTRACT_DATA. This PL/SQL table is defined in the
  ** Package pay_element_extract_data_pkg (pyelerpd.pkh/pkb).
  *****************************************************************/
  PROCEDURE formated_static_header(
              p_output_file_type  in varchar2
             ,p_static_label1    out nocopy varchar2
             ,p_static_label2    out nocopy varchar2
             ,p_business_group_id in varchar2 -- Bug No : 2007614
             )
  IS
    -- Bug No : 2007614
    -- changed call to per_business_groups to the base table
    cursor c_legislation_code is
      select hoi_bg.org_information9
        from hr_organization_information hoi_bg
       where organization_id = p_business_group_id
         and org_information_context =  'Business Group Information';

    lv_legislation_code varchar2(150); --Bug No :2007614
    lv_ssl_number       varchar2(150); -- Bug No :2007614 and 5179163 (Size changed from 3 to 150)
    lv_format1          varchar2(32000);
    lv_format2          varchar2(32000);

  BEGIN

--Bug No : 2007614 New cursor for fetching the Legislation code
--         based on which the value will be  SIN for CA legislation code or SSN
--         for other legislation code in the header part
      open c_legislation_code;
      fetch c_legislation_code into lv_legislation_code;
      /* commented for Bug # 5179163
      if lv_legislation_code = 'CA' then
         lv_ssl_number  := 'SIN';
      else
         lv_ssl_number := 'SSN';
      end if;
      */
      /* This is added to fix Bug # 5179163 */
      fnd_message.set_name('PER','HR_NATIONAL_ID_NUMBER_'||lv_legislation_code);
      lv_ssl_number := fnd_message.get;
      if lv_ssl_number IS NULL
      then
         lv_ssl_number := 'National Identifier';
      end if;
      hr_utility.trace('HR_NATIONAL_ID_NUMBER_'||lv_legislation_code ||' = ' || lv_ssl_number);

      hr_utility.set_location(gv_package_name || '.formated_static_header', 10);
      lv_format1 :=
              formated_data_string (p_input_string =>
                                    hr_general.decode_fnd_comm_lookup
                                    ('PAYROLL_REPORTS',  --lookup_type
                                     'L_NAME')--lookup_code
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||

              formated_data_string (p_input_string =>
                                     hr_general.decode_fnd_comm_lookup
                                       ('PAYROLL_REPORTS',  --lookup_type
                                        'F_NAME')--lookup_code
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string =>
                                     hr_general.decode_fnd_comm_lookup
                                       ('PAYROLL_REPORTS',  --lookup_type
                                        'MI_NAME')--lookup_code
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||

              formated_data_string (p_input_string =>
                                     hr_general.decode_fnd_comm_lookup
                                       ('PAYROLL_REPORTS',  --lookup_type
                                        'EMP_NO')--lookup_code
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||

              formated_data_string (p_input_string =>
                                     hr_general.decode_fnd_comm_lookup
                                       ('PAYROLL_REPORTS',  --lookup_type
                                        'ASSIGN_NO')--lookup_code
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||

              formated_data_string (p_input_string =>
                                     hr_general.decode_fnd_comm_lookup
                                       ('PAYROLL_REPORTS',  --lookup_type
                                        'ORG_NAME')--lookup_code
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||

              formated_data_string (p_input_string =>
                                     hr_general.decode_fnd_comm_lookup
                                       ('PAYROLL_REPORTS',  --lookup_type
                                        'ACT_TYP')--lookup_code
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||

              formated_data_string (p_input_string =>
                                     hr_general.decode_fnd_comm_lookup
                                       ('PAYROLL_REPORTS',  --lookup_type
                                        'EFF_DT')--lookup_code
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type)
              ;

      hr_utility.set_location(gv_package_name || '.formated_static_header', 20);
      lv_format2 :=
              formated_data_string (p_input_string =>
                                     hr_general.decode_fnd_comm_lookup
                                       ('PAYROLL_REPORTS',  --lookup_type
                                        'PR_NAME')--lookup_code
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||

              formated_data_string (p_input_string =>
                                     hr_general.decode_fnd_comm_lookup
                                       ('PAYROLL_REPORTS',  --lookup_type
                                        'GRE')--lookup_code
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||

              formated_data_string (p_input_string =>
                                     hr_general.decode_fnd_comm_lookup
                                       ('PAYROLL_REPORTS',  --lookup_type
                                        'LOC_NAME')--lookup_code
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||
              --
              -- Lookup Code defaulted if meaning is not found for the lookup_code
	      -- This is to fix bug # 5179163
	      --
              formated_data_string (p_input_string =>
                                     NVL(hr_general.decode_fnd_comm_lookup
                                       ('PAYROLL_REPORTS',  --lookup_type
                                        lv_ssl_number),
					lv_ssl_number)--lookup_code  Bug No : 2007614
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||

              formated_data_string (p_input_string =>
                                     hr_general.decode_fnd_comm_lookup
                                       ('PAYROLL_REPORTS',  --lookup_type
                                        'DOB')--lookup_code
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||

              formated_data_string (p_input_string =>
                                     hr_general.decode_fnd_comm_lookup
                                       ('PAYROLL_REPORTS',  --lookup_type
                                        'GENDER')--lookup_code
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||

              formated_data_string (p_input_string =>
                                     hr_general.decode_fnd_comm_lookup
                                       ('PAYROLL_REPORTS',  --lookup_type
                                        'DT_FIRST_HIRED')
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||

              formated_data_string (p_input_string =>
                                     hr_general.decode_fnd_comm_lookup
                                       ('PAYROLL_REPORTS',  --lookup_type
                                        'LT_HIRE_DT')--lookup_code
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||

              formated_data_string (p_input_string =>
                                     hr_general.decode_fnd_comm_lookup
                                       ('PAYROLL_REPORTS',  --lookup_type
                                        'EMP_TYP')--lookup_code
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||

              formated_data_string (p_input_string =>
                                     hr_general.decode_fnd_comm_lookup
                                       ('PAYROLL_REPORTS',  --lookup_type
                                        'ASSIGN_STAT')--lookup_code
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||

              formated_data_string (p_input_string =>
                                     hr_general.decode_fnd_comm_lookup
                                       ('PAYROLL_REPORTS',  --lookup_type
                                        'EMP_CAT')--lookup_code
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type)
              ;

      /*******************************************************************
      ** Print the User Defined data for each Employee Assignment at the
      ** end of the report
      *******************************************************************/
      hr_utility.set_location(gv_package_name || '.formated_static_header', 30);

      /*******************************************************************
      ** Only do this if there is some configuration data present
      *******************************************************************/
      if pay_element_extract_data_pkg.ltt_element_extract_label.count > 0 then
         for i in pay_element_extract_data_pkg.ltt_element_extract_label.first ..
                  pay_element_extract_data_pkg.ltt_element_extract_label.last
         loop

            lv_format2 := lv_format2 ||
                             formated_data_string (
                               p_input_string =>
                                 pay_element_extract_data_pkg.ltt_element_extract_label(i)
                              ,p_bold         => 'Y'
                              ,p_output_file_type => p_output_file_type);

         end loop;
      end if;

      p_static_label1 := lv_format1;
      p_static_label2 := lv_format2;
      hr_utility.trace('Static Label1 = ' || lv_format1);
      hr_utility.trace('Static Label2 = ' || lv_format2);
      hr_utility.set_location(gv_package_name || '.formated_static_header', 40);

  END;


  /*****************************************************************
  ** This procudure returns the Mandatory Static Labels and the
  ** Other Additional Static columns. The other static columns are
  ** printed after all the Element Information is printed for each
  ** employee assignment.
  ** The users can add hooks to this package to print more additional
  ** data which they require for this report.
  ** The package prints the user data from a PL/SQL table. The users
  ** can insert data and the label in this PL/SQL table which will
  ** be printed at the end of the report.
  ** The PL/SQL table which needs to be populated is
  ** LTR_ELEMENT_EXTRACT_DATA. This PL/SQL table is defined in the
  ** Package pay_element_extract_data_pkg (pyelerpd.pkh/pkb).
  *****************************************************************/
  PROCEDURE formated_static_data (
                   p_action_type               in varchar2
                  ,p_action_effective_date     in date
                  ,p_payroll_name              in varchar2
                  ,p_gre_name                  in varchar2
                  ,p_org_name                  in varchar2
                  ,p_location_code             in varchar2
                  ,p_emp_last_name             in varchar2
                  ,p_emp_first_name            in varchar2
                  ,p_emp_middle_names          in varchar2
                  ,p_emp_employee_number       in varchar2
                  ,p_emp_national_identifier   in varchar2
                  ,p_emp_date_of_birth         in date
                  ,p_gender                    in varchar2
                  ,p_emp_original_date_of_hire in date
                  ,p_emp_projected_start_date  in date
                  ,p_emp_user_person_type      in varchar2
                  ,p_assignment_number         in varchar2
                  ,p_assignment_status         in varchar2
                  ,p_employment_category       in varchar2
                  ,p_output_file_type          in varchar2
                  ,p_static_data1             out nocopy varchar2
                  ,p_static_data2             out nocopy varchar2
             )
  IS

    lv_format1 VARCHAR2(32000);
    lv_format2 VARCHAR2(32000);

    lv_emp_date_of_birth         varchar2(20)
                 := to_char(p_emp_date_of_birth, 'dd-MON-yyyy');
    lv_emp_original_date_of_hire varchar2(20)
                 := to_char(p_emp_original_date_of_hire, 'dd-MON-yyyy');
    lv_emp_projected_start_date  varchar2(20)
                 := to_char(p_emp_projected_start_date, 'dd-MON-yyyy');
    lv_action_effective_date     varchar2(20)
                 := to_char(p_action_effective_date, 'dd-MON-yyyy');

  BEGIN

      hr_utility.set_location(gv_package_name || '.formated_static_data', 10);
      lv_format1 :=
              formated_data_string (p_input_string => p_emp_last_name
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => p_emp_first_name
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => p_emp_middle_names
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => p_emp_employee_number
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => p_assignment_number
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => p_org_name
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => p_action_type
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => lv_action_effective_date
                                   ,p_output_file_type => p_output_file_type)
              ;

      hr_utility.set_location(gv_package_name || '.formated_static_data', 20);
      lv_format2 :=
              formated_data_string (p_input_string => p_payroll_name
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => p_gre_name
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => p_location_code
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => p_emp_national_identifier
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => lv_emp_date_of_birth
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => p_gender
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => lv_emp_original_date_of_hire
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => lv_emp_projected_start_date
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => p_emp_user_person_type
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => p_assignment_status
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => p_employment_category
                                   ,p_output_file_type => p_output_file_type)
              ;

      /*******************************************************************
      ** Print the User Defined data for each Employee Assignment at the
      ** end of the report
      *******************************************************************/
      hr_utility.set_location(gv_package_name || '.formated_static_data', 30);

      /*******************************************************************
      ** Only do this if there is some configuration data present
      *******************************************************************/
      if pay_element_extract_data_pkg.ltt_element_extract_label.count > 0 then
         for i in pay_element_extract_data_pkg.ltt_element_extract_data.first ..
                  pay_element_extract_data_pkg.ltt_element_extract_data.last
         loop

            lv_format2 := lv_format2 ||
                             formated_data_string (
                               p_input_string =>
                                 pay_element_extract_data_pkg.ltt_element_extract_data(i)
                              ,p_output_file_type => p_output_file_type);
         end loop;
      end if;

      p_static_data1 := lv_format1;
      p_static_data2 := lv_format2;
      hr_utility.trace('Static Data1 = ' || lv_format1);
      hr_utility.trace('Static Data2 = ' || lv_format2);
      hr_utility.set_location(gv_package_name || '.formated_static_data', 40);

  END;

  FUNCTION get_element_set_where_clause (p_element_set_id in number)
  RETURN varchar2
  IS

     cursor c_element_set (cp_element_set_id in number) is
        select petr.element_type_id
          from pay_element_type_rules petr
         where petr.element_set_id = cp_element_set_id
           and petr.include_or_exclude = 'I'
        union all
        select pet1.element_type_id
          from pay_element_types_f pet1
         where pet1.classification_id in
                     (select classification_id
                        from pay_ele_classification_rules
                       where element_set_id = cp_element_set_id)
           and pet1.element_name not like '%Special Features'
           and pet1.element_name not like '%Special Inputs'
           and pet1.element_name not like '%Withholding'
           and pet1.element_name not like '%Verifier'
           and pet1.element_name not like '%Fees'
           and pet1.element_name not like '%Priority'
        minus
        select petr.element_type_id
          from pay_element_type_rules petr
         where petr.element_set_id = cp_element_set_id
           and petr.include_or_exclude = 'E';

      ln_set_element_type_id NUMBER;
      lv_where_clause        VARCHAR2(32000);

   BEGIN

     open c_element_set(p_element_set_id);
     loop
        fetch c_element_set into ln_set_element_type_id;
        if c_element_set%notfound then
           lv_where_clause := substr(lv_where_clause,2);
           exit;
        end if;

        lv_where_clause := lv_where_clause || ',' || ln_set_element_type_id;

     end loop;
     close c_element_set;

     lv_where_clause := 'pet.element_type_id in (' || lv_where_clause
                                           || ')';


     return (lv_where_clause);

   END get_element_set_where_clause;

  /*****************************************************************
  ** This is the main procedure which is called from the Concurrent
  ** Request. All the paramaters are passed based on which it will
  ** either print a CSV format or an HTML format file.
  *****************************************************************/
  PROCEDURE element_extract
             (errbuf                      out nocopy varchar2
             ,retcode                     out nocopy number
             ,p_business_group_id         in  number
             ,p_start_date                in  varchar2
             ,p_end_date                  in  varchar2
             ,p_selection_criteria        in  varchar2
             ,p_is_ele_set                in  varchar2
             ,p_element_set_id            in  number
             ,p_is_ele_class              in  varchar2
             ,p_element_classification_id in  number
             ,p_is_ele                    in  varchar2
             ,p_element_type_id           in  number
             ,p_payroll_id                in  number
             ,p_consolidation_set_id      in  number
             ,p_tax_unit_id               in  number
             ,p_organization_id           in  number
             ,p_location_id               in  number
             ,p_person_id                 in  number
             ,p_assignment_set_id         in  number
             ,p_output_file_type          in  varchar2
             )
  IS


    /************************************************************
    ** Cursor to get all the employee and assignment data.
    ** This cursor will return one row for each Assignment Action
    ** for the Selection parameter entered by the user in the SRS.
    ** the Assignment Action returned by this cursor is used to
    ** retreive the Elements processed and its Pay Value.
    ************************************************************/
    cursor c_assignments (
                       cp_start_date           in date
                      ,cp_end_date             in date
                      ,cp_payroll_id           in number
                      ,cp_consolidation_set_id in number
                      ,cp_organization_id      in number
                      ,cp_tax_unit_id          in number
                      ,cp_location_id          in number
                      ,cp_person_id            in number
                      ,cp_business_group_id    in number
                      ) is
      select paa.assignment_action_id
            ,paa.tax_unit_id
            ,paf.assignment_id
            ,ppa.payroll_action_id
            ,ppf.person_id
            ,ppa.effective_date
            ,fcl.meaning
            ,pf.payroll_name
            ,ppf.last_name
            ,ppf.first_name
            ,ppf.middle_names
            ,ppf.employee_number
            ,ppf.national_identifier
            ,ppf.date_of_birth
            ,ppf.sex
            ,ppf.original_date_of_hire
            ,ppf.projected_start_date
            ,paf.assignment_number
            ,paf.employment_category
        from pay_payroll_actions ppa,
             pay_assignment_actions paa,
             per_assignments_f paf,
             per_people_f ppf,
             pay_payrolls_f pf,
             fnd_common_lookups fcl
       where ppa.action_type in ('R', 'Q', 'B', 'I', 'V')
         and ppa.business_group_id = cp_business_group_id
--
         and pf.payroll_id = ppa.payroll_id
         and ppa.effective_date between pf.effective_start_date
                                    and pf.effective_end_date
         and pf.payroll_id like nvl(to_char(cp_payroll_id), '%')
         and (cp_consolidation_set_id is null
             or ppa.consolidation_set_id = cp_consolidation_set_id )
--
         and ppa.effective_date between cp_start_date
                                    and cp_end_date
         and fcl.lookup_code = ppa.action_type
         and fcl.lookup_type = 'ACTION_TYPE'
         and fcl.application_id = 800
         and fcl.enabled_flag = 'Y'
         and paa.payroll_action_id = ppa.payroll_action_id
         and (cp_tax_unit_id is null
             or paa.tax_unit_id = cp_tax_unit_id)
         and paf.assignment_id = paa.assignment_id
         and ppa.effective_date between paf.effective_start_date
                                    and paf.effective_end_date
         and (cp_organization_id is null
             or paf.organization_id = cp_organization_id)
         and (cp_location_id is null
             or paf.location_id = cp_location_id)
         and ppf.person_id = paf.person_id
         and ppa.effective_date between ppf.effective_start_date
                                    and ppf.effective_end_date
         and (cp_person_id is null
              or ppf.person_id = cp_person_id)
      order by ppf.last_name, ppf.first_name,
               ppf.middle_names, ppa.effective_date;


    /*************************************************************
    ** This cursor returns the elements processed for a particular
    ** assignment action and the Pay Value for that element. The
    ** cursor also accepts element set, element type and
    ** classification id as an input. Only one of these will have
    ** a value. Only the Pay Value of elements in the element set
    ** or classification or just the element is returned.
    **************************************************************/
    --Element Register Report changes delivered with bug 3039097
    --August 2003
/*
    cursor c_element_results (cp_assignment_action_id in number
                             ,cp_classification_id    in number
                             ,cp_element_set_id       in number
                             ,cp_element_type_id      in number
                             ,cp_effective_date       in date) is
      select pet.reporting_name,
             prrv.result_value
        from pay_element_types_f      pet,
             pay_element_types_f_tl   pettl,
             pay_input_values_f       piv,
             pay_run_result_values    prrv,
             pay_run_results          prr,
             pay_input_values_f_tl    pivtl
       where pivtl.name               = 'Pay Value'
         and pivtl.language           = 'US'
         and pivtl.input_value_id     = piv.input_value_id
         and prrv.input_value_id      = piv.input_value_id
         and piv.element_type_id      = pet.element_type_id
         and prrv.result_value        is not null
         and prr.run_result_id        = prrv.run_result_id
         and prr.assignment_action_id = cp_assignment_action_id
         and pet.element_type_id      = prr.element_type_id
         and pettl.language           = userenv('LANG')
         and pettl.element_type_id    = pet.element_type_id
         and cp_effective_date between pet.effective_start_date
                                   and pet.effective_end_date
         and pet.classification_id like nvl(to_char(cp_classification_id), '%')
         and pet.element_type_id like nvl(to_char(cp_element_type_id), '%')
         and (cp_element_set_id is null
             or (cp_element_set_id is not null
                 and prr.element_type_id in
                     (select petr.element_type_id
                        from pay_element_type_rules petr
                        where petr.element_set_id = cp_element_set_id
                          and petr.include_or_exclude = 'I'
                      union all
                       select pet1.element_type_id
                         from pay_element_types_f pet1
                        where pet1.classification_id in
                                     (select classification_id
                                        from pay_ele_classification_rules
                                       where element_set_id = cp_element_set_id)
                      minus
                       select petr.element_type_id
                         from pay_element_type_rules petr
                        where petr.element_set_id = cp_element_set_id
                          and petr.include_or_exclude = 'E'
                     )
                )
             );
*/
/*
    cursor c_element_results (cp_assignment_action_id in number
                             ,cp_classification_id    in number
                             ,cp_element_set_id       in number
                             ,cp_element_type_id      in number
                             ,cp_effective_date       in date) is
      select pet.reporting_name,
             prrv.result_value
        from pay_element_types_f pet,
             pay_input_values_f piv,
             pay_run_result_values prrv,
             pay_run_results prr
       where piv.name = 'Pay Value'
         and prrv.input_value_id = piv.input_value_id
         and piv.element_type_id = pet.element_type_id
         and prrv.result_value is not null
         and prr.run_result_id = prrv.run_result_id
         and prr.assignment_action_id = cp_assignment_action_id
         and pet.element_type_id = prr.element_type_id
         and cp_effective_date between pet.effective_start_date
                                   and pet.effective_end_date
         and pet.classification_id like nvl(to_char(cp_classification_id), '%')
         and pet.element_type_id like nvl(to_char(cp_element_type_id), '%')
         and (cp_element_set_id is null
             or (cp_element_set_id is not null
                 and prr.element_type_id in
                     (select petr.element_type_id
                        from pay_element_type_rules petr
                        where petr.element_set_id = cp_element_set_id
                          and petr.include_or_exclude = 'I'
                      union all
                       select pet1.element_type_id
                         from pay_element_types_f pet1
                        where pet1.classification_id in
                                     (select classification_id
                                        from pay_ele_classification_rules
                                       where element_set_id = cp_element_set_id)
                      minus
                       select petr.element_type_id
                         from pay_element_type_rules petr
                        where petr.element_set_id = cp_element_set_id
                          and petr.include_or_exclude = 'E'
                     )
                )
             );

*/
    /*************************************************************
    ** Cursor returns all the valid element names for the input
    ** Element Classification.
    *************************************************************/
    --Element Register Report changes delivered with bug 3039097
    --August 2003

    --Bug 3731178
    -- Added NVL in the select of c_class_elements,c_set_elements,
    -- c_elements so that reporting name is displayed if element
    -- name is null. %Priotiry Elements will not be shown

    -- Bug 5229191
    -- Added parameters cp_start_date and cp_end_date
    -- Added two where conditions to filter elements not eligible for
    -- the Element Report period

    cursor c_class_elements( cp_element_classification_id in number
                            ,cp_business_group_id         in number
			    ,cp_start_date		  in date
			    ,cp_end_date		  in date
			   ) is
      select distinct nvl(pettl.reporting_name,pettl.element_name)
        from pay_element_types_f    pet,
             pay_element_types_f_tl pettl
       where pet.classification_id = cp_element_classification_id
         and cp_business_group_id = nvl(pet.business_group_id, cp_business_group_id)
         and pet.element_name not like '%Special Features'
         and pet.element_name not like '%Special Inputs'
         and pet.element_name not like '%Withholding'
         and pet.element_name not like '%Verifier'
	 and pet.element_name not like '%Fees'
	 and pet.element_name not like '%Priority'
         and pettl.language           = userenv('LANG')
         and pettl.element_type_id    = pet.element_type_id
	 and pet.effective_start_date <= cp_end_date  --bug # 5229191
	 and pet.effective_end_date >= cp_start_date
      /* Added to fix Bug # 5167072
         START */
      UNION ALL
      select distinct nvl(pettl.reporting_name,pettl.element_name)
        from pay_element_types_f            pet,
             pay_element_types_f_tl         pettl,
             PAY_SUB_CLASSIFICATION_RULES_F scr,
             pay_element_classifications    pec
       where scr.element_type_id   = pet.element_type_id
	 and pec.classification_id = cp_element_classification_id
	 and pec.classification_id = scr.classification_id
         and cp_business_group_id  = nvl(pet.business_group_id,
				         cp_business_group_id)
         and pet.element_name not  like '%Special Features'
         and pet.element_name not  like '%Special Inputs'
         and pet.element_name not  like '%Withholding'
         and pet.element_name not  like '%Verifier'
	 and pet.element_name not  like '%Fees'
	 and pet.element_name not  like '%Priority'
         and pettl.language        = userenv('LANG')
         and pettl.element_type_id = pet.element_type_id
	 and pet.effective_start_date <= cp_end_date  --bug # 5229191
	 and pet.effective_end_date >= cp_start_date
      /* END of fix Bug # 5167072 */
   order by 1;

    /*************************************************************
    ** Cursor returns all the valid element names for the input
    ** Element Set.
    *************************************************************/
    --Element Register Report changes delivered with bug 3039097
    --August 2003

    -- Bug 5229191
    -- Added parameters cp_start_date and cp_end_date
    -- Added two where conditions to filter elements not eligible for
    -- the Element Report period

    cursor c_set_elements (cp_ele_set_id         in number
                           ,cp_business_group_id in number
 			   ,cp_start_date        in date
			   ,cp_end_date		 in date
                          ) is
      select distinct nvl(pettl.reporting_name,pettl.element_name)
        from pay_element_type_rules petr,
             pay_element_types_f    pet,
             pay_element_types_f_tl  pettl
       where pet.element_type_id = petr.element_type_id
         and petr.element_set_id = cp_ele_set_id
         and petr.include_or_exclude = 'I'
         and pettl.language           = userenv('LANG')
         and pettl.element_type_id    = pet.element_type_id
	 and pet.effective_start_date <= cp_end_date --bug # 5229191
	 and pet.effective_end_date >= cp_start_date
     union all
      select distinct nvl(pettl1.reporting_name,pettl1.element_name)
        from pay_element_types_f    pet1,
             pay_element_types_f_tl pettl1
       where cp_business_group_id = nvl(pet1.business_group_id, cp_business_group_id)
         and pet1.classification_id in
                       (select classification_id
                          from pay_ele_classification_rules
                         where element_set_id = cp_ele_set_id)
         and pet1.element_name not like '%Special Features'
         and pet1.element_name not like '%Special Inputs'
         and pet1.element_name not like '%Withholding'
         and pet1.element_name not like '%Verifier'
	 and pet1.element_name not like '%Fees'
	 and pet1.element_name not like '%Priority'
         and pettl1.language           = userenv('LANG')
         and pettl1.element_type_id    = pet1.element_type_id
	 and pet1.effective_start_date <= cp_end_date --bug # 5229191
	 and pet1.effective_end_date >= cp_start_date
     minus
      select distinct nvl(pettl.reporting_name,pettl.element_name)
        from pay_element_type_rules petr,
             pay_element_types_f_tl  pettl
       where pettl.element_type_id   = petr.element_type_id
         and petr.element_set_id     = cp_ele_set_id
         and petr.include_or_exclude = 'E'
         and pettl.language          = userenv('LANG')
   order by 1; -- reporting_name;


    /*************************************************************
    ** Cursor returns valid element names for the input Element ID
    *************************************************************/
    --Element Register Report changes delivered with bug 3039097
    --August 2003

    cursor c_elements (cp_ele_type_id in number) is
      select distinct nvl(pettl.reporting_name,pettl.element_name)
        from pay_element_types_f_tl pettl
       where pettl.element_type_id = cp_ele_type_id
         and pettl.language        = userenv('LANG');

    /*************************************************************
    ** Cursor to return the Employement Category from Lookups
    *************************************************************/
    cursor c_employment_category (cp_lookup_code in varchar2) is
      select fcl.meaning
        from fnd_common_lookups fcl
       where fcl.lookup_type = 'EMP_CAT'
         and fcl.lookup_code = cp_lookup_code;

    /*************************************************************
    ** Local Variables
    *************************************************************/
    TYPE cur_type is REF CURSOR;
    c_element_results cur_type;

    lv_element_set_where_clause    VARCHAR2(32000);
    lv_element_cls_where_clause    VARCHAR2(32000);
    lv_element_id_where_clause     VARCHAR2(32000);
    lv_element_result_query        VARCHAR2(32000);
    lv_element_cls_where_clause2   VARCHAR2(32000); -- Bug # 5167072
    ln_assignment_action_id        NUMBER;
    ln_assignment_id               NUMBER;
    ln_person_id                   NUMBER;
    ld_effective_date              DATE;
    lv_action_type                 VARCHAR2(100);

    lv_tax_unit_id                 number;
    ln_payroll_action_id           NUMBER;
    lv_gre_name                    VARCHAR2(240);
    lv_emp_last_name               VARCHAR2(150);
    lv_emp_first_name              VARCHAR2(150);
    lv_emp_middle_names            VARCHAR2(100);
    lv_emp_employee_number         VARCHAR2(100);
    lv_emp_national_identifier     VARCHAR2(100);
    ld_emp_date_of_birth           DATE;
    lv_gender                      VARCHAR2(100);
    ld_emp_original_date_of_hire   DATE;
    ld_emp_projected_start_date    DATE;
    lv_emp_user_person_type        VARCHAR2(100);
    lv_assignment_number           VARCHAR2(100);
    lv_org_name                    VARCHAR2(240);
    lv_payroll_name                VARCHAR2(100);
    lv_location_code               VARCHAR2(60);
    lv_assignment_status           VARCHAR2(100);
    lv_employment_category_code    per_assignments_f.employment_category%type; --Bug 3650988
    lv_employment_category         VARCHAR2(100);

    lv_element_name                VARCHAR2(100);
    lv_element_value               VARCHAR2(100);
    lv_element_status		   VARCHAR2(2);   --Bug 4214739 Added to get value of status
    ln_run_result_id           NUMBER(15,0);

    lb_print_row                   BOOLEAN := FALSE;

    lv_header_label                VARCHAR2(32000);
    lv_header_label1               VARCHAR2(32000);
    lv_header_label2               VARCHAR2(32000);

    lv_data_row                    VARCHAR2(32000);
    lv_data_row1                   VARCHAR2(32000);
    lv_data_row2                   VARCHAR2(32000);

    ln_count                       NUMBER := 0;

    ltr_elements tab_element;

BEGIN
--   hr_utility.trace_on (null,'pyelerep');

   hr_utility.set_location(gv_package_name || '.element_extract', 10);

   formated_static_header( p_output_file_type
                          ,lv_header_label1
                          ,lv_header_label2
                          ,p_business_group_id); -- Bug No : 2007614

   lv_header_label := lv_header_label1;

   if p_element_set_id is not null then
      hr_utility.set_location(gv_package_name || '.element_extract', 20);
      open c_set_elements( p_element_set_id
                          ,p_business_group_id
			  ,fnd_date.canonical_to_date(p_start_date)
			  ,fnd_date.canonical_to_date(p_end_date)
			  );
   elsif p_element_classification_id is not null then
      hr_utility.set_location(gv_package_name || '.element_extract', 30);
      open c_class_elements( p_element_classification_id
                            ,p_business_group_id
			    ,fnd_date.canonical_to_date(p_start_date)
			    ,fnd_date.canonical_to_date(p_end_date)
			   );
   elsif p_element_type_id is not null then
      hr_utility.set_location(gv_package_name || '.element_extract', 40);
      open c_elements(p_element_type_id);
   end if;

   hr_utility.set_location(gv_package_name || '.element_extract', 50);
   loop
      if p_element_set_id is not null then
         fetch c_set_elements into lv_element_name;
         hr_utility.trace(' lv_element_name 1 : ' || lv_element_name );
         if c_set_elements%notfound then
            exit;
         end if;
      elsif p_element_classification_id is not null then
         fetch c_class_elements into lv_element_name;
         hr_utility.trace(' lv_element_name 2 : ' || lv_element_name );
         if c_class_elements%notfound then
            exit;
         end if;
      elsif p_element_type_id is not null then
         fetch c_elements into lv_element_name;
         hr_utility.trace(' lv_element_name 3 : ' || lv_element_name );
         if c_elements%notfound then
            exit;
         end if;
      end if;

      ln_count := ln_count + 1;
      ltr_elements(ln_count).element_name := lv_element_name;

      lv_header_label := lv_header_label ||
                            formated_data_string(
                                         lv_element_name
                                        ,p_output_file_type
                                        ,'Y');

   end loop;
   hr_utility.set_location(gv_package_name || '.element_extract', 60);

   if p_element_set_id is not null then
      close c_set_elements;
   elsif p_element_classification_id is not null then
      close c_class_elements;
   elsif p_element_type_id is not null then
      close c_elements;
   end if;

   hr_utility.set_location(gv_package_name || '.element_extract', 70);
   /****************************************************************
   ** Concatnating the second Header Label which includes the User
   ** Defined data set so that it is printed at the end of the
   ** report.
   ****************************************************************/
   lv_header_label := lv_header_label || lv_header_label2;

   hr_utility.set_location(gv_package_name || '.element_extract', 80);
   hr_utility.trace('Static and Element Label = ' || lv_header_label);

   gv_title := hr_general.decode_fnd_comm_lookup
                 ('PAYROLL_REPORTS',
                  'ELEMENT_REGISTER_TITLE');

   fnd_file.put_line(fnd_file.output, formated_header_string(
                                          gv_title
                                         ,p_output_file_type
                                         ));

   hr_utility.set_location(gv_package_name || '.element_extract', 90);
   /****************************************************************
   ** Print the Header Information. If the format is HTML then open
   ** the body and table before printing the header info, otherwise
   ** just print the header information.
   ****************************************************************/
   if p_output_file_type ='HTML' then
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '<body>');
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '<table border=1>');
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '<tr>');
   end if;

   fnd_file.put_line(fnd_file.output, lv_header_label);

   if p_output_file_type ='HTML' then
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '</tr>');
   end if;

   hr_utility.set_location(gv_package_name || '.element_extract', 100);
   /*****************************************************
   ** Start of the Data Section of the Report
   *****************************************************/
   hr_utility.trace('Assignment Set ID = ' || p_assignment_set_id);

   if p_element_classification_id is not null then
      lv_element_cls_where_clause
               := 'pet.classification_id =  ' || p_element_classification_id;
   else
      lv_element_cls_where_clause := '1 = 1';
   end if;

   /* Added for Bug # 5167072  START */
   if p_element_classification_id is not null then
      lv_element_cls_where_clause2
               := 'pec.classification_id =  ' || p_element_classification_id;
   else
      lv_element_cls_where_clause2 := '1 = 1';
   end if;
   /* Bug # 5167072  END */

   if p_element_type_id is not null then
      lv_element_id_where_clause
               := 'pet.element_type_id =  ' || p_element_type_id;
   else
      lv_element_id_where_clause := '1 = 1';
   end if;

   if p_element_set_id is not null then
      lv_element_set_where_clause := get_element_set_where_clause(
                                            p_element_set_id => p_element_set_id);
   else
      lv_element_set_where_clause := '1 = 1';
   end if;

   open c_assignments( to_date(p_start_date, 'YYYY/MM/DD HH24:MI:SS')
                      ,to_date(p_end_date, 'YYYY/MM/DD HH24:MI:SS')
                      ,p_payroll_id
                      ,p_consolidation_set_id
                      ,p_organization_id
                      ,p_tax_unit_id
                      ,p_location_id
                      ,p_person_id
                      ,p_business_group_id
                     );

   loop
      fetch c_assignments into ln_assignment_action_id
                              ,lv_tax_unit_id
                              ,ln_assignment_id
                              ,ln_payroll_action_id
                              ,ln_person_id
                              ,ld_effective_date
                              ,lv_action_type
                              ,lv_payroll_name
                              ,lv_emp_last_name
                              ,lv_emp_first_name
                              ,lv_emp_middle_names
                              ,lv_emp_employee_number
                              ,lv_emp_national_identifier
                              ,ld_emp_date_of_birth
                              ,lv_gender
                              ,ld_emp_original_date_of_hire
                              ,ld_emp_projected_start_date
                              ,lv_assignment_number
                              ,lv_employment_category_code;

      if c_assignments%notfound then
         hr_utility.set_location(gv_package_name || '.element_extract', 105);
         exit;
      end if;
/*
      hr_utility.trace(' ln_assignment_action_id : ' || ln_assignment_action_id );
      hr_utility.trace(' lv_tax_unit_id : ' || lv_tax_unit_id );
      hr_utility.trace(' ln_assignment_id : ' || ln_assignment_id );
      hr_utility.trace(' ln_payroll_action_id : ' || ln_payroll_action_id );
      hr_utility.trace(' ln_person_id : ' || ln_person_id );
      hr_utility.trace(' ld_effective_date : ' || ld_effective_date );
      hr_utility.trace(' lv_action_type : ' || lv_action_type );
      hr_utility.trace(' lv_payroll_name : ' || lv_payroll_name );
      hr_utility.trace(' lv_emp_last_name : ' || lv_emp_last_name );
      hr_utility.trace(' lv_emp_first_name : ' || lv_emp_first_name );
      hr_utility.trace(' lv_emp_middle_names : ' || lv_emp_middle_names );
      hr_utility.trace(' lv_emp_employee_number : ' || lv_emp_employee_number );
      hr_utility.trace(' lv_emp_national_identifier : ' || lv_emp_national_identifier );
      hr_utility.trace(' ld_emp_date_of_birth : ' || ld_emp_date_of_birth );
      hr_utility.trace(' lv_gender : ' || lv_gender );
      hr_utility.trace(' ld_emp_original_date_of_hire : ' || ld_emp_original_date_of_hire );
      hr_utility.trace(' ld_emp_projected_start_date : ' || ld_emp_projected_start_date );
      hr_utility.trace(' lv_assignment_number : ' || lv_assignment_number );
      hr_utility.trace(' lv_employment_category_code : ' || lv_employment_category_code );
*/
      BEGIN

      select hou_org.name
            ,hl.location_code
            ,ppt.user_person_type
            ,past.user_status
        into lv_org_name
            ,lv_location_code
            ,lv_emp_user_person_type
            ,lv_assignment_status
        from per_person_types ppt,
             per_people_f ppf,
             hr_locations_all hl,
             hr_organization_units hou_org,
             per_assignment_status_types past,
             per_assignments_f paf
       where paf.assignment_id = ln_assignment_id
         and ld_effective_date between paf.effective_start_date
                                    and paf.effective_end_date
         and hou_org.organization_id = paf.organization_id
         and past.assignment_status_type_id = paf.assignment_status_type_id
         and hl.location_id = paf.location_id
         and ppf.person_id = paf.person_id
         and ld_effective_date between ppf.effective_start_date
                                    and ppf.effective_end_date
         and ppt.person_type_id = ppf.person_type_id;

       EXCEPTION

          WHEN NO_DATA_FOUND THEN
             lv_org_name             := null;
             lv_location_code        := null;
             lv_emp_user_person_type := null;
             lv_assignment_status    := null;
       END;

       BEGIN

       select hou_gre.name
         into lv_gre_name
         from hr_organization_units hou_gre
        where hou_gre.organization_id = lv_tax_unit_id;

       EXCEPTION
          WHEN NO_DATA_FOUND THEN
             lv_gre_name := null;
       END;

      /************************************************************
      ** If Assignment Set is used, pick up only those employee
      ** assignments which are part of the Assignment Set - STATIC
      ** or DYNAMIC.
      ************************************************************/
      hr_utility.set_location(gv_package_name || '.element_extract', 110);
      hr_utility.trace('Assignment ID = '     || ln_assignment_id);
      hr_utility.trace('Assignment Action ID = ' || ln_assignment_action_id);

      if hr_assignment_set.assignment_in_set(
                            p_assignment_set_id
                           ,ln_assignment_id)    = 'Y' then


         hr_utility.set_location(gv_package_name || '.element_extract', 120);
         /********************************************************************
         ** Populate the user defined PL/SQL table to print the additional
         ** columns in the report.
         ********************************************************************/
         pay_element_extract_data_pkg.populate_table(
                             p_assignment_id => ln_assignment_id
                            ,p_person_id     => ln_person_id
                            ,p_assignment_action_id => ln_assignment_action_id
                            ,p_effective_date=> ld_effective_date
                            );
         lv_employment_category := ''; -- Initialise to Blank Bug 4255046
         open c_employment_category(lv_employment_category_code);
         fetch c_employment_category into lv_employment_category;
         close c_employment_category;

         hr_utility.set_location(gv_package_name || '.element_extract', 125);
         formated_static_data(
                               lv_action_type
                              ,ld_effective_date
                              ,lv_payroll_name
                              ,lv_gre_name
                              ,lv_org_name
                              ,lv_location_code
                              ,lv_emp_last_name
                              ,lv_emp_first_name
                              ,lv_emp_middle_names
                              ,lv_emp_employee_number
                              ,lv_emp_national_identifier
                              ,ld_emp_date_of_birth
                              ,lv_gender
                              ,ld_emp_original_date_of_hire
                              ,ld_emp_projected_start_date
                              ,lv_emp_user_person_type
                              ,lv_assignment_number
                              ,lv_assignment_status
                              ,lv_employment_category
                              ,p_output_file_type
                              ,lv_data_row1
                              ,lv_data_row2);

         lv_data_row := lv_data_row1;
         hr_utility.set_location(gv_package_name || '.element_extract', 130);
         hr_utility.trace('Effective Date = '    || to_char(ld_effective_date,'dd-mon-yyyy'));
         hr_utility.trace('Assignment Action ID = ' || ln_assignment_action_id);
         hr_utility.trace('Classification ID = ' ||
                           nvl(to_char(p_element_classification_id), 'NULL'));
         hr_utility.trace('Element Set ID = '    || nvl(to_char(p_element_set_id), 'NULL'));
         hr_utility.trace('Element Type ID = '   || nvl(to_char(p_element_type_id), 'NULL'));

         -- Bug 3731178 -- Added NVL in select so that element
         -- name is fetched if reporting name is NULL.
	 -- Also added a decode for garn elements.

	 --Bug 4214739 added column prr.status in below query

	 lv_element_result_query :=
                   ' select /*+ leading(pet) */
                            distinct
                            nvl(pet.reporting_name,pet.element_name),
                            prrv.result_value,
			    prr.Status,
                            decode(prr.entry_type,''E'',decode(pet.multiple_entries_allowed_flag,''Y'',prr.run_result_id,-1),prr.run_result_id) run_result_id
                       from pay_element_types_f      pet,
                            pay_element_types_f_tl   pettl,
                            pay_input_values_f       piv,
                            pay_run_result_values    prrv,
                            pay_run_results          prr,
                            pay_input_values_f_tl    pivtl,
			    pay_element_classifications pec
                      where pivtl.name               = ''Pay Value''
                        and pivtl.language           = ''US''
                        and pivtl.input_value_id     = piv.input_value_id
                        and prrv.input_value_id      = piv.input_value_id
                        and piv.element_type_id      = pet.element_type_id
                        and prrv.result_value        is not null
                        and prr.run_result_id        = prrv.run_result_id
                        and prr.assignment_action_id = :cp_assignment_action_id
                      	and pet.classification_id    = pec.classification_id
                        and pet.element_type_id      = prr.element_type_id
			and pettl.language           = userenv(''LANG'')
                        and pettl.element_type_id    = pet.element_type_id
                        and :cp_effective_date between pet.effective_start_date
                                                  and pet.effective_end_date
                        and pet.element_name not like ''%Special Features''
                        and pet.element_name not like ''%Special Inputs''
                        and pet.element_name not like ''%Withholding''
                        and pet.element_name not like ''%Fees''
                        and pet.element_name not like ''%Verifier''
	                and pet.element_name not like ''%Priority''
                        and '
			|| lv_element_cls_where_clause
                        || ' and ' || lv_element_id_where_clause
                        || ' and ' || lv_element_set_where_clause
                        || '
                      UNION
		     select /*+ leading(pet) */
                            distinct
                            nvl(pet.reporting_name,pet.element_name),
                            prrv.result_value,
		   	    prr.Status,
                            decode(prr.entry_type,''E'',decode(pet.multiple_entries_allowed_flag,''Y'',prr.run_result_id,-1),prr.run_result_id) run_result_id
                       from pay_element_types_f            pet,
                            pay_element_types_f_tl         pettl,
                            pay_input_values_f             piv,
                            pay_run_result_values          prrv,
                            pay_run_results                prr,
                            pay_input_values_f_tl          pivtl,
       			    pay_element_classifications    pec,
       			    pay_sub_classification_rules_f scr
                      where pivtl.name               = ''Pay Value''
                        and pivtl.language           = ''US''
                        and pivtl.input_value_id     = piv.input_value_id
                        and prrv.input_value_id      = piv.input_value_id
                        and piv.element_type_id      = pet.element_type_id
                        and prrv.result_value        is not null
                        and prr.run_result_id        = prrv.run_result_id
                        and prr.assignment_action_id = :cp_assignment_action_id
                      	and scr.classification_id    = pec.classification_id
                      	and scr.element_type_id      = pet.element_type_id
                        and pet.element_type_id      = prr.element_type_id
			and pettl.language           = userenv(''LANG'')
                        and pettl.element_type_id    = pet.element_type_id
                        and :cp_effective_date between pet.effective_start_date
                                                  and pet.effective_end_date
                        and pet.element_name not like ''%Special Features''
                        and pet.element_name not like ''%Special Inputs''
                        and pet.element_name not like ''%Withholding''
                        and pet.element_name not like ''%Fees''
                        and pet.element_name not like ''%Verifier''
	                and pet.element_name not like ''%Priority''
                        and '
                        || lv_element_cls_where_clause2
                        || ' and ' || lv_element_id_where_clause
                        || ' and ' || lv_element_set_where_clause
                     ;
         open c_element_results FOR lv_element_result_query USING
                                    ln_assignment_action_id
                                   ,ld_effective_date
	                           ,ln_assignment_action_id
                                   ,ld_effective_date;

         hr_utility.set_location(gv_package_name || '.element_extract', 140);
         loop
            fetch c_element_results into lv_element_name
                                        ,lv_element_value
					,lv_element_status
                                        ,ln_run_result_id;
            if c_element_results%notfound then
               hr_utility.set_location(gv_package_name || '.element_extract', 150);
               exit;
            end if;

	    hr_utility.trace('Element Name = ' || lv_element_name ||
                             ' Value = '       || lv_element_value);
            for i in ltr_elements.first .. ltr_elements.last loop
                hr_utility.trace('Element Name PL/SQL = ' || ltr_elements(i).element_name);
                if ltr_elements(i).element_name = lv_element_name then
                   hr_utility.set_location(gv_package_name || '.element_extract', 155);

		   /*******************************************************************
		   Bug 4214739 Checked if element status is 'R' - Replaced then there is no need to
		   add the value so made lv_element_value 0
		   ********************************************************************/
                   --
                   -- changed condition from lv_element_status = 'R', due to support eclusive O, U also
                   --
		   if lv_element_status not in ('P','PA') then
		      lv_element_value := 0;
		   end if;

                   if ltr_elements(i).value is not null then
                      ltr_elements(i).value := ltr_elements(i).value + nvl(lv_element_value,0);
                   else
                      ltr_elements(i).value := lv_element_value;
                   end if;
                   exit ;
                end if;
            end loop ;

         end loop;
         close c_element_results;

         /*******************************************************************
         ** Do Not Print records of an employee, if the employee has non of
         ** the elements which are picked up by the report.
         *******************************************************************/
         hr_utility.set_location(gv_package_name || '.element_extract', 160);
         if ltr_elements.count > 0 then
            for i in ltr_elements.first .. ltr_elements.last loop
                if ltr_elements(i).value is not null then
                   hr_utility.set_location(gv_package_name || '.element_extract', 165);
                   lb_print_row := TRUE;
                   exit;
                end if;
            end loop;
         end if;

         /*******************************************************************
         ** If there is atleast one column which needs to be printed, print
         ** the entire row.
         *******************************************************************/
         if lb_print_row then
            hr_utility.set_location(gv_package_name || '.element_extract', 170);
            for i in ltr_elements.first .. ltr_elements.last loop
                   lv_data_row := lv_data_row ||
                                     formated_data_string (
                                          p_input_string => ltr_elements(i).value
                                         ,p_output_file_type => p_output_file_type);

            end loop ;

            /****************************************************************
            ** Concatnating the second Header Label which includes the User
            ** Defined data set so that it is printed at the end of the
            ** report.
            ****************************************************************/
            lv_data_row := lv_data_row || lv_data_row2;

            if p_output_file_type ='HTML' then
               lv_data_row := '<tr>' || lv_data_row || '</tr>' ;
            end if;

            FND_FILE.PUT_LINE(FND_FILE.OUTPUT, lv_data_row);
         end if; /************** End of Print Row *************************/

      end if;   /********** End of Assignment Set ************************/

      /*****************************************************************
      ** initialize Print Row valiable again
      *****************************************************************/
      lb_print_row := FALSE;

      /*****************************************************************
      ** initialize Data varaibles
      *****************************************************************/
      lv_data_row  := null;
      lv_data_row1 := null;
      lv_data_row2 := null;
      if ltr_elements.count > 0 then
         for i in ltr_elements.first .. ltr_elements.last loop
             ltr_elements(i).value := null ;
         end loop ;
      end if;

   end loop;
   close c_assignments;

   /*****************************************************
   ** Close of the Data Section of the Report
   *****************************************************/

   if p_output_file_type ='HTML' then
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '</table></body></html>');
   end if;
   hr_utility.trace('Concurrent Request ID = ' || FND_GLOBAL.CONC_REQUEST_ID);


   /**********************************************************
   ** Not Required as the output file type is HTML by default
   ***********************************************************
   if p_output_file_type ='HTML' then
      update fnd_concurrent_requests
         set output_file_type = 'HTML'
       where request_id = FND_GLOBAL.CONC_REQUEST_ID ;

      commit;
   end if;
   **********************************************************/


  END element_extract;

--begin
--hr_utility.trace_on(null, 'ELE');
end pay_element_extract_pkg;

/
