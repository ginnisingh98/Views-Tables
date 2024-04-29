--------------------------------------------------------
--  DDL for Package Body PAY_LIVEARCHIVE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_LIVEARCHIVE_PKG" AS
/* $Header: pyuslvar.pkb 115.12 2004/01/22 05:40:41 ardsouza noship $ */
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

    Name        : pay_livearchive_pkg

    File        : pyuslvar.pkb

    Description : Package for the Elements Reports. The package
                  generated the output file in the specified user
                  format. The current formats supported are
                      - HTML
                      - CSV

    Change List
    -----------
     Date        Name      Vers    Bug No    Description
     ----        ----      ------  -------   -----------
     09-SEP-2002 djoshi    115.0             Created.
     11-oct-2002 djoshi    115.1             Added code to remove ','
     11-oct-2002 djoshi    115.2             Changed header from
                                             to Archive - Live
     05-nov-2002 djoshi    115.4             Changed for count
     05-nov-2002 djoshi    115.5             Corrected spelling Error
     21-nov-2002 djoshi    115.6             Changes for bug 2679192
                                             and 2679586
     21-nov-2002 djoshi    115.8             changed for message
     24-nov-2002 djoshi    115.9             now box3 = box3 - box 7.
     02-dec-2002 djoshi    115.10            Corrected out with nocopy
     25-sep-2003 ardsouza  115.11  2554865   Changes for Enhancement
                                             to reconcile 1099R specific
                                             balances
     22-jan-2004 ardsouza  115.12  3361925   Suppressed index on effective_date
                                             in pay_payroll_actions to improve
                                             performance.

*/

 /************************************************************
  ** Local Package Variables
  ************************************************************/
  gv_title               VARCHAR2(100) := ' Year End Archive Reconciliation Report';
  gc_csv_delimiter       VARCHAR2(1) := ',';
  gc_csv_data_delimiter  VARCHAR2(1) := '"';

  gv_html_start_data     VARCHAR2(5) := '<td>'  ;
  gv_html_end_data       VARCHAR2(5) := '</td>' ;

  gv_package_name        VARCHAR2(50) := 'pay_livearchive_pkg';

  gvr_balance live_bal_tab;


 /***************************************************************
  Name      : bal_db_item
  Purpose   : For a balance DB item name
              it returns the defined_balance_id of the balance.
  Arguments :
  Notes     : A defined balance_id is required by the PLSQL
              balance function.
 ****************************************************************/

 FUNCTION bal_db_item ( p_db_item_name varchar2)
   RETURN number
 IS

 /* Get the defined_balance_id for the specified balance DB item. */

   CURSOR   csr_defined_balance is
   SELECT   to_number(UE.creator_id)
     FROM   ff_user_entities  UE,
            ff_database_items DI
     WHERE  DI.user_name            = p_db_item_name
       AND  UE.user_entity_id       = DI.user_entity_id
       AND  Ue.creator_type         = 'B'
       AND  UE.legislation_code     = 'US';

   l_defined_balance_id pay_defined_balances.defined_balance_id%TYPE;


 BEGIN

    --hr_utility.trace('p_db_item_name is '||p_db_item_name);

   OPEN csr_defined_balance;
   FETCH csr_defined_balance INTO l_defined_balance_id;
   IF csr_defined_balance%notfound THEN
     CLOSE csr_defined_balance;
     RAISE hr_utility.hr_error;
   ELSE
     CLOSE csr_defined_balance;
   END IF;

   --hr_utility.trace('l_defined_balance_id is '||to_char(l_defined_balance_id));
   RETURN (l_defined_balance_id);

  END bal_db_item;

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
             ,p_bold             in varchar2
             )
  RETURN VARCHAR2
  IS

    lv_format          varchar2(1000);
    lv_bold           varchar2(10);
  BEGIN
    lv_bold := nvl(p_bold,'N');
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
          if lv_bold = 'Y' then
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


 FUNCTION  formated_header_state(
              p_output_file_type  in varchar2
             )RETURN VARCHAR2
  IS

    lv_format1          varchar2(32000);
    lv_format2          varchar2(32000);

  BEGIN

      hr_utility.set_location(gv_package_name || '.formated_header_state', 10);
      lv_format1 :=
              formated_data_string (p_input_string => 'Year '
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => 'GRE '
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||

              formated_data_string (p_input_string => 'State '
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||

              formated_data_string (p_input_string => 'JD Code '
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => 'Employee Name '
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => 'Employee SS # '
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => 'Employee #'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => 'Box name '
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => 'Archive '
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type)
              ;

       hr_utility.set_location(gv_package_name || '.formated_header_state', 20);
       lv_format2 :=
              formated_data_string (p_input_string => 'Live '
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => 'Archive - Live'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type)
              ;

      hr_utility.trace('Static Label1 = ' || lv_format1);
      hr_utility.trace('Static Label2 = ' || lv_format2);

      return lv_format1 || lv_format2;

      hr_utility.set_location(gv_package_name || '.formated_header_state', 40);

  END formated_header_state;


 FUNCTION  formated_header_federal(
              p_output_file_type  in varchar2
             ) RETURN varchar2
  IS

    lv_format1          varchar2(32000);
    lv_format2          varchar2(32000);

  BEGIN

      hr_utility.set_location(gv_package_name || '.formated_header_federal', 10);
      lv_format1 :=
              formated_data_string (p_input_string => 'Year '
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => 'GRE '
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => 'Employee Name '
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => 'Employee SS # '
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => 'Employee #'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => 'Box name '
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => 'Archive '
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type)
              ;

       hr_utility.set_location(gv_package_name || '.formated_header_federal', 20);
       lv_format2 :=
              formated_data_string (p_input_string => 'Live '
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => 'Archive - Live '
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type)
              ;

      hr_utility.trace('Static Label1 = ' || lv_format1);
      hr_utility.trace('Static Label2 = ' || lv_format2);
      return lv_format1 || lv_format2;

      hr_utility.set_location(gv_package_name || '.formated_header_federal', 40);

  END formated_header_federal;



 FUNCTION  formated_detail_state(
              p_output_file_type  in varchar2
             ,p_year                 varchar2
             ,p_gre                  varchar2
             ,p_state                varchar2
             ,p_jd_code              varchar2
             ,p_Employee_name        varchar2
             ,p_employee_ssn        varchar2
             ,p_emplyee_number       varchar2
             ,p_box_name             varchar2
             ,p_live_balance         varchar2
             ,p_archive_balance      varchar2
             ,p_diff                 varchar2
             ) RETURN varchar2
  IS

    lv_format1          varchar2(22000);
    lv_format2          varchar2(10000);

  BEGIN

      hr_utility.set_location(gv_package_name || '.formated_detail_state', 10);
      lv_format1 :=
              formated_data_string (p_input_string => p_year
                                   ,p_bold         => 'N'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => p_gre
                                   ,p_bold         => 'N'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => p_state
                                   ,p_bold         => 'N'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => p_jd_code
                                   ,p_bold         => 'N'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => p_employee_name
                                   ,p_bold         => 'N'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => P_employee_ssn
                                   ,p_bold         => 'N'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => p_emplyee_number
                                   ,p_bold         => 'N'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => p_box_name
                                   ,p_bold         => 'N'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => p_archive_balance
                                   ,p_bold         => 'N'
                                   ,p_output_file_type => p_output_file_type)
              ;

       hr_utility.set_location(gv_package_name || '.formated_detail_state', 20);
       lv_format2 :=
              formated_data_string (p_input_string => p_live_balance
                                   ,p_bold         => 'N'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => p_Diff
                                   ,p_bold         => 'N'
                                   ,p_output_file_type => p_output_file_type)
              ;

      hr_utility.trace('Static Label1 = ' || lv_format1);
      hr_utility.trace('Static Label2 = ' || lv_format2);

      hr_utility.set_location(gv_package_name || '.formated_detail_state', 30);

      return lv_format1 || lv_format2;

  END formated_detail_state;


 function  formated_detail_federaL(
              p_output_file_type  in varchar2
             ,p_year                 varchar2
             ,p_gre                  varchar2
             ,p_Employee_name        varchar2
             ,p_employee_ssn         varchar2
             ,p_emplyee_number       varchar2
             ,p_box_name             varchar2
             ,p_live_balance         varchar2
             ,p_archive_balance      varchar2
             ,p_diff                 varchar2
             ) RETURN VARCHAR2
  IS

    lv_format1          varchar2(22000);
    lv_format2          varchar2(10000);

  BEGIN

      hr_utility.set_location(gv_package_name || '.formated_detail_federal', 10);
      lv_format1 :=
              formated_data_string (p_input_string => p_year
                                   ,p_bold         => 'N'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => p_gre
                                   ,p_bold         => 'N'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => p_employee_name
                                   ,p_bold         => 'N'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => P_employee_ssn
                                   ,p_bold         => 'N'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => p_emplyee_number
                                   ,p_bold         => 'N'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => p_box_name
                                   ,p_bold         => 'N'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => p_archive_balance
                                   ,p_bold         => 'N'
                                   ,p_output_file_type => p_output_file_type)
              ;

       hr_utility.set_location(gv_package_name || '.formated_detail_federal', 20);
       lv_format2 :=
              formated_data_string (p_input_string => p_live_balance
                                   ,p_bold         => 'N'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => p_diff
                                   ,p_bold         => 'N'
                                   ,p_output_file_type => p_output_file_type)
              ;

      hr_utility.trace('Static Label1 = ' || lv_format1);
      hr_utility.trace('Static Label2 = ' || lv_format2);

      hr_utility.set_location(gv_package_name || '.formated_detail_federal', 30);

      return lv_format1 || lv_format2;

  END formated_detail_federal;


 PROCEDURE  formated_no_diff(output_file_type varchar2,  p_lookup_description varchar2,
                             p_employee_count number, p_diff_count number)
       IS
       lvc_message varchar2(200);
       lvc_return_message varchar2(400);
 BEGIN
      null;
      /* Bug 2554865 - Modified Employee's to Employees */
       IF output_file_type = 'CSV' THEN
          lvc_message :=   'For ' || substr(p_lookup_description,1,30) || ', Number of Employees compared = '
                          || to_char(p_employee_count)
                          || ' Number of Employees with difference = '
                          || to_char(p_diff_count);
          hr_utility.set_location(gv_package_name || '.formated_no_diff', 10);
          fnd_file.put_line(fnd_file.output,formated_data_string (p_input_string =>  lvc_message
                                   ,p_bold         => 'N'
                                   ,p_output_file_type => output_file_type));
        END IF;
 END;



 PROCEDURE  formated_zero_count(output_file_type varchar2)
       IS
      lvc_message varchar2(200);
      lvc_return_message varchar2(400);
 BEGIN
      null;
 --      IF output_file_type = 'CSV' THEN
          lvc_message :=   'No person was picked up for comparision based on selection parameters.' ||
         ' Ensure GRE has employees and all employees were successfully archived in the YEPP for the GRE.';
          hr_utility.set_location(gv_package_name || '.formated_zero_count', 10);
          fnd_file.put_line(fnd_file.output, formated_data_string (p_input_string =>  lvc_message
                                   ,p_bold         => 'N'
                                   ,p_output_file_type => output_file_type));
  --     END IF;
      hr_utility.set_location(gv_package_name || '.formated_zero_count', 20);
 END;

  /* get the archive value */

function  get_archive_value ( p_assignment_action_id number,
                               p_balance_name varchar2,
                               p_tax_unit_id number,
                               p_jurisdiction   varchar2,
                               p_jurisdiction_level number
                             ) return number
IS

BEGIN

 hr_utility.set_location(gv_package_name || '.get_archive_value', 10);



  /* Set jurisdiction value */

 return hr_us_w2_rep.get_w2_arch_bal(p_assignment_action_id,p_balance_name,p_tax_unit_id, p_jurisdiction,p_jurisdiction_level);

 hr_utility.set_location(gv_package_name || '.get_archive_value', 20);

END; /* get_archive_value */


procedure populate_balance_id  (
                                  p_balance_name varchar2
                               )
IS
BEGIN
  /* Populate value for balance_name balance id */

    IF p_balance_name = 'A_WAGES' THEN

         gvr_balance(1).bal_name :=  'A_REGULAR_EARNINGS_PER_GRE_YTD';
         gvr_balance(2).bal_name :=  'A_SUPPLEMENTAL_EARNINGS_FOR_FIT_SUBJECT_TO_TAX_PER_GRE_YTD';
         gvr_balance(3).bal_name :=  'A_SUPPLEMENTAL_EARNINGS_FOR_NWFIT_SUBJECT_TO_TAX_PER_GRE_YTD';
         gvr_balance(4).bal_name :=  'A_PRE_TAX_DEDUCTIONS_FOR_FIT_SUBJECT_TO_TAX_PER_GRE_YTD';
         gvr_balance(5).bal_name :=  'A_FIT_NON_W2_PRE_TAX_DEDNS_PER_GRE_YTD';
         gvr_balance(6).bal_name :=  'A_PRE_TAX_DEDUCTIONS_PER_GRE_YTD';


         /* get the defined balance id for the given balance used for balance call */

         gvr_balance(1).bal_id := bal_db_item(substr('A_REGULAR_EARNINGS_PER_GRE_YTD',3));
         gvr_balance(2).bal_id := bal_db_item(substr('A_SUPPLEMENTAL_EARNINGS_FOR_FIT_SUBJECT_TO_TAX_PER_GRE_YTD',3));
         gvr_balance(3).bal_id := bal_db_item(substr('A_SUPPLEMENTAL_EARNINGS_FOR_NWFIT_SUBJECT_TO_TAX_PER_GRE_YTD',3));
         gvr_balance(4).bal_id := bal_db_item(substr('A_PRE_TAX_DEDUCTIONS_FOR_FIT_SUBJECT_TO_TAX_PER_GRE_YTD',3));
         gvr_balance(5).bal_id := bal_db_item(substr('A_FIT_NON_W2_PRE_TAX_DEDNS_PER_GRE_YTD',3));
         gvr_balance(6).bal_id := bal_db_item(substr('A_PRE_TAX_DEDUCTIONS_PER_GRE_YTD',3));

     ELSIF  /* if it is state */
         p_balance_name = 'A_W2_STATE_WAGES' THEN

         gvr_balance(1).bal_name :=  'A_SIT_SUBJ_WHABLE_PER_JD_GRE_YTD';
         gvr_balance(2).bal_name :=  'A_SIT_SUBJ_NWHABLE_PER_JD_GRE_YTD';
         gvr_balance(3).bal_name :=  'A_SIT_PRE_TAX_REDNS_PER_JD_GRE_YTD';

         gvr_balance(1).bal_id := bal_db_item(substr(gvr_balance(1).bal_name,3));
         gvr_balance(2).bal_id := bal_db_item(substr(gvr_balance(2).bal_name,3));
         gvr_balance(3).bal_id := bal_db_item(substr(gvr_balance(3).bal_name,3));

     ELSIF p_balance_name = 'A_SS_EE_TAXABLE_PER_GRE_YTD' THEN

         gvr_balance(1).bal_name :=  'A_SS_EE_TAXABLE_PER_GRE_YTD';
         gvr_balance(2).bal_name :=  'A_W2_BOX_7_PER_GRE_YTD';

         gvr_balance(1).bal_id := bal_db_item(substr(gvr_balance(1).bal_name,3));
         gvr_balance(2).bal_id := bal_db_item(substr(gvr_balance(2).bal_name,3));

	/* Bug 2554865 -  Modified populate_balance_id to map 'A_W2_GROSS_1099R'
                          to 'A_GROSS_EARNINGS_PER_GRE_YTD'.                  */

     ELSIF p_balance_name = 'A_W2_GROSS_1099R' THEN

         gvr_balance(1).bal_name :=  'A_GROSS_EARNINGS_PER_GRE_YTD';

         gvr_balance(1).bal_id := bal_db_item(substr(gvr_balance(1).bal_name,3));

     ELSE
         gvr_balance(1).bal_name := p_balance_name;
         /* populate balance id */
         gvr_balance(1).bal_id := bal_db_item(substr(gvr_balance(1).bal_name,3));

     END IF;

END populate_balance_id;



procedure  populate_balance_value (
                                p_assignment_action_id number
                              , p_balance_name varchar2
                             )
IS
BEGIN

    IF p_balance_name = 'A_WAGES' THEN

         gvr_balance(1).bal_value :=  nvl(pay_balance_pkg.get_value
                            (p_defined_balance_id   => gvr_balance(1).bal_id,
                             p_assignment_action_id => p_assignment_action_id),0);

         gvr_balance(2).bal_value :=  nvl(pay_balance_pkg.get_value
                            (p_defined_balance_id   => gvr_balance(2).bal_id,
                             p_assignment_action_id => p_assignment_action_id),0);

         gvr_balance(3).bal_value :=  nvl(pay_balance_pkg.get_value
                            (p_defined_balance_id   => gvr_balance(3).bal_id,
                             p_assignment_action_id => p_assignment_action_id),0);

         gvr_balance(4).bal_value :=  nvl(pay_balance_pkg.get_value
                            (p_defined_balance_id   => gvr_balance(4).bal_id,
                             p_assignment_action_id => p_assignment_action_id),0);

         gvr_balance(5).bal_value :=  nvl(pay_balance_pkg.get_value
                            (p_defined_balance_id   => gvr_balance(5).bal_id,
                             p_assignment_action_id => p_assignment_action_id),0);
         gvr_balance(6).bal_value :=  nvl(pay_balance_pkg.get_value
                            (p_defined_balance_id   => gvr_balance(6).bal_id,
                             p_assignment_action_id => p_assignment_action_id),0);

        ELSIF
           p_balance_name = 'A_W2_STATE_WAGES' THEN

           gvr_balance(1).bal_value :=  nvl(pay_balance_pkg.get_value
                            (p_defined_balance_id   => gvr_balance(1).bal_id,
                             p_assignment_action_id => p_assignment_action_id),0);
           gvr_balance(2).bal_value :=  nvl(pay_balance_pkg.get_value
                            (p_defined_balance_id   => gvr_balance(2).bal_id,
                             p_assignment_action_id => p_assignment_action_id),0);
           gvr_balance(3).bal_value :=  nvl(pay_balance_pkg.get_value
                            (p_defined_balance_id   => gvr_balance(3).bal_id,
                             p_assignment_action_id => p_assignment_action_id),0);

        ELSIF p_balance_name = 'A_SS_EE_TAXABLE_PER_GRE_YTD' THEN

           gvr_balance(1).bal_value :=  nvl(pay_balance_pkg.get_value
                            (p_defined_balance_id   => gvr_balance(1).bal_id,
                             p_assignment_action_id => p_assignment_action_id),0);
           gvr_balance(2).bal_value :=  nvl(pay_balance_pkg.get_value
                            (p_defined_balance_id   => gvr_balance(2).bal_id,
                             p_assignment_action_id => p_assignment_action_id),0);
        ELSE
         /* get the value of the dbi */
         gvr_balance(1).bal_value :=  nvl(pay_balance_pkg.get_value
                            (p_defined_balance_id   => gvr_balance(1).bal_id,
                             p_assignment_action_id => p_assignment_action_id),0);

        END IF;  /* A_WAGES */


END populate_balance_value;

/* This procedure assigns Zeros to all the values */

procedure  zero_balance_value
IS
BEGIN


         gvr_balance(1).bal_value := 0;
         gvr_balance(2).bal_value := 0;
         gvr_balance(3).bal_value := 0;
         gvr_balance(4).bal_value := 0;
         gvr_balance(5).bal_value := 0;
         gvr_balance(6).bal_value := 0;

END Zero_balance_value;


/************************************************************
** Following Function will will calculate the value of
**   balance based on balance name and return the calculated
**   value  for federal and state Wages
**   For all other balances the values would be
**   single defined value.
**
***************************************************************/

FUNCTION  get_live_value (
                            p_balance_name varchar2
                          ) return number
IS
 lvn_cal_value number ;
BEGIN
 hr_utility.set_location(gv_package_name || '.get_live_value', 10);
 hr_utility.trace('balance_name = ' || p_balance_name );
 IF p_balance_name = 'A_WAGES' THEN
     lvn_cal_value :=       gvr_balance(1).bal_value
                         +  gvr_balance(2).bal_value
                         +  gvr_balance(3).bal_value
                         +  gvr_balance(4).bal_value
                         +  gvr_balance(5).bal_value
                         -  gvr_balance(6).bal_value;

  ELSIF p_balance_name = 'A_W2_STATE_WAGES' THEN
     lvn_cal_value :=       gvr_balance(1).bal_value
                         +  gvr_balance(2).bal_value
                         -  gvr_balance(3).bal_value ;
   ELSIF p_balance_name =  'A_SS_EE_TAXABLE_PER_GRE_YTD' THEN

     lvn_cal_value :=       gvr_balance(1).bal_value
                         -  gvr_balance(2).bal_value ;
   ELSE

     lvn_cal_value :=       gvr_balance(1).bal_value ;
   END IF;
      return lvn_cal_value;
      hr_utility.set_location(gv_package_name || '.get_live_value', 20);
END;   /* Get Live value fucntion call */


  /*****************************************************************
  ** This procedure is called from the Concurrent Request. Based on
  ** paramaters selected in SRS the report will compare the the
  ** the Values and print the the values for the assignment that
  ** have diffrent live and archive balances. The output format of
  ** the report will be either a CSV format or an HTML format.
  *****************************************************************/

  PROCEDURE select_employee
           (errbuf                OUT nocopy    varchar2,
            retcode               OUT nocopy    number,
            p_year                IN      VARCHAR2,
            p_tax_unit_id         IN      NUMBER,
            p_fed_state           IN      VARCHAR2,
            p_is_state            IN      VARCHAR2,
            p_state_code          IN      VARCHAR2,
            p_box_type            IN      VARCHAR2,  -- Bug 2554865
            p_box_name            IN      VARCHAR2,
            p_output_file_type    IN      VARCHAR2
           )
  IS


    /************************************************************
    ** Cursor to get all the employee and assignment data.
    ** This cursor will return one row for each Assignment Action
    ** based on the Selection parameter entered by the user
    ** in the SRS.
    ************************************************************/
   /**************************************************************
     Parameter for the Cursor :c_select_assignment
     c_end_of_year      --  31st Dec.  of the Year in date format
     c_state_of_year    --  1st of Jan of Year   in date format
     c_gre_id           --  GRE id in character Format
   **************************************************************/

    CURSOR c_select_assignment(c_end_of_year date,
                               c_start_of_year date,
                               c_gre_id varchar2  )
    IS
    SELECT  assignment_action_id ,
            serial_number ,
            tax_unit_id
     FROM   pay_payroll_actions ppa,  -- Year End
            pay_assignment_actions paa,  -- Year End
            per_assignments_f paf
    WHERE   ppa.report_type = 'YREND'
      AND   ppa.action_status = 'C'
      AND   ppa.effective_date =  c_end_of_year
      AND   ppa.legislative_parameters like c_gre_id || ' TRANSFER%'
      AND   ppa.payroll_action_id = paa.payroll_action_id
      AND   paa.action_status = 'C'
      AND   paf.assignment_id = paa.assignment_id
      AND   paf.effective_start_date = ( SELECT max(paf2.effective_start_date)
                                        FROM per_assignments_f paf2
                                       WHERE paf2.assignment_id = paf.assignment_id
                                         AND paf2.effective_start_date <= c_end_of_year )
      AND   paf.effective_end_date >= c_start_of_year;



     -- Bug 3361925 - Suppressed index on ppa.effective_date to improve performance
     --

             CURSOR c_live_ass_action_id(c_person_id number, c_tax_unit_id number,
                                         c_start_of_year date, c_end_of_year date )
                IS
            SELECT   paa.assignment_action_id
              FROM
                     pay_assignment_actions     paa,
                     per_assignments_f      paf,
                     pay_payroll_actions        ppa,
                     pay_action_classifications pac
             WHERE   paf.person_id     = c_person_id
               AND   paa.assignment_id = paf.assignment_id
               AND   paa.tax_unit_id   = c_tax_unit_id
               AND   paa.payroll_action_id = ppa.payroll_action_id
               AND   ppa.action_type = pac.action_type
               AND   pac.classification_name = 'SEQUENCED'
               AND   ppa.effective_date +0 BETWEEN paf.effective_start_date
                                               AND paf.effective_end_date
               AND   ppa.effective_date +0 BETWEEN c_start_of_year and
                                                c_end_of_year
             order by paa.action_sequence desc;


    /*************************************************************
     Cursor to get state Abbrevaiation for the Selected State
    *************************************************************/

     Cursor c_selected_state
        IS  SELECT state_abbrev
              FROM pay_us_states
            where  state_code = p_state_code;


    /*************************************************************
     Cursor to get Box Meaning
    *************************************************************/

     CURSOR c_box_description( c_lookup_type varchar2,
                           c_meaning varchar2
                         )
        IS  SELECT description,to_char(sysdate,'mm/dd/yyyy HH:MI')
              FROM fnd_common_lookups
             WHERE application_id = 801
               AND lookup_type = c_lookup_type
               AND meaning = c_meaning;

    /*************************************************************
     Cursor to get GRE name
    *************************************************************/

     CURSOR c_gre_name
        IS  SELECT name
              FROM hr_organization_units
             WHERE  organization_id  = p_tax_unit_id;

    /*************************************************************
     Cursor to get Employee Number
    *************************************************************/

     CURSOR c_employee_number ( c_person_id number )
        IS  SELECT employee_number
              FROM per_people_f
             WHERE  person_id   = c_person_id;

    /*************************************************************
    ** Local Variables
    *************************************************************/
    lvc_last_name               VARCHAR2(150);
    lvc_first_name              VARCHAR2(150);

    lb_print_row                   BOOLEAN := FALSE;

    lv_header_label                VARCHAR2(32000);
    /* Changed from 32000 to 22000 and 100000 */
    lv_header_label1               VARCHAR2(22000);
    lv_header_label2               VARCHAR2(10000);

    lv_report_asgn                 VARCHAR2(1) := 'N';
    lv_                    VARCHAR2(32000);
    lv_data_row                   VARCHAR2(32000);

    lvc_name                       VARCHAR2(300);
    lvc_label1                     VARCHAR2(32000);
    lvc_national_identifier     VARCHAR2(100);
    lvc_employee_number         VARCHAR2(100);
    lvn_person_id                   NUMBER;
    lvc_gre_name                   hr_organization_units.name%type;
    lvc_state_abbrev  pay_us_states.state_abbrev%type := null;
    lvc_jurisdiction  varchar2(11) := '00-000-0000';
    lvn_tax_unit_id   number := -1;
    lvc_tax_unit_id   varchar2(15);
    lvc_date_time     varchar2(50);
    lvd_effective_date date ;
    lvd_end_of_year date;
    lvd_start_of_year date;
    lvc_year          varchar2(4);
    lvn_level         number := 0;
    lvn_archive_value  number := 0;
    lvn_live_value number := 0;
    lvc_lookup_type      fnd_common_lookups.lookup_type%type;
    lvc_lookup_meaning   fnd_common_lookups.meaning%type;
    lvc_lookup_description fnd_common_lookups.description%type;
    lvn_diff_value number := 0;
    lvc_balance_name varchar2(240);
    lvn_employee_count number := 0;
    lvn_diff_count number := 0;
    lvn_live_aaid  number := 0;
    lvc_message    varchar2(32000);
BEGIN

    hr_utility.set_location(gv_package_name || '.select_employee', 10);
    /* build the jurisdiction code based on State Code */
    IF p_fed_state =  'Federal'  THEN
    /* Bug 2554865 - Modified to handle 1099R specific Federal lookup */
       IF p_box_type = 'W-2' THEN
          lvc_lookup_type := 'US_FEDERAL_LIVE_ARCHIVE';
       ELSIF p_box_type = '1099-R' THEN
          lvc_lookup_type := 'US_FEDERAL_1099R_LIVE_ARCHIVE';
       ELSE
          null;
       END IF;
       lvc_jurisdiction  := '00-000-0000';
       lvc_lookup_meaning := p_box_name;
       lvn_level := 0;
    ELSIF p_fed_state = 'State' THEN
    /* Bug 2554865 - Modified to handle 1099R specific State lookup */
       IF p_box_type = 'W-2' THEN
          lvc_lookup_type := 'US_STATE_LIVE_ARCHIVE';
       ELSIF p_box_type = '1099-R' THEN
          lvc_lookup_type := 'US_STATE_1099R_LIVE_ARCHIVE';
       ELSE
          null;
       END IF;
       lvc_jurisdiction :=  p_state_code || '-000-0000' ;
       lvc_lookup_meaning := p_box_name;
       lvn_level        :=  2;
    ELSE
       null;
    END IF;

    lvc_balance_name := p_box_name ;

    gvr_balance.delete;

     populate_balance_id(p_box_name);


    /* Build the tax Unit Id */
      lvn_tax_unit_id := p_tax_unit_id;
      lvc_tax_unit_id := to_char(lvn_tax_unit_id);

   /* Builiding Date and Year */
    lvd_start_of_year := fnd_date.canonical_to_date(p_year);
    lvd_end_of_year   := add_months(fnd_date.canonical_to_date(p_year),12) -1;
    lvc_year := to_char(fnd_date.canonical_to_date(p_year),'YYYY');


     BEGIN


        OPEN c_box_description( lvc_lookup_type,
                                lvc_Lookup_meaning
                         );
       FETCH c_box_description INTO lvc_lookup_description,lvc_date_time;
       CLOSE c_box_description;

        OPEN c_selected_state;
       FETCH c_selected_state INTO lvc_state_abbrev;
       CLOSE c_selected_state;

        OPEN  c_gre_name;
       FETCH  c_gre_name INTO lvc_gre_name;
       CLOSE  c_gre_name;
        lvc_gre_name := replace(lvc_gre_name, ',',' ');


     EXCEPTION
     WHEN OTHERS THEN
          hr_utility.trace(' State Abbereviation or GRE Name cursor failed');
     END;

    hr_utility.set_location(gv_package_name || '.select_employee', 20);
    -- code is hard coded to get only one value dJoshi will change and will be based on value


    /* set the context for the give Tax unit_id and jurisdiction only once in report */

       pay_balance_pkg.set_context ('JURISDICTION_CODE',lvc_jurisdiction);
       pay_balance_pkg.set_context ('TAX_UNIT_ID',lvn_tax_unit_id);


    -- djoshi write the utility trace over here
    /* get the assignment */

     for i in  c_select_assignment(lvd_end_of_year,
                              lvd_start_of_year,
                              lvc_tax_unit_id )  loop
       lvn_person_id := to_number(i.serial_number);




    hr_utility.set_location(gv_package_name || '.select_employee', 30);
   /* Get the assignment action id for the live call */

    open c_live_ass_action_id(lvn_person_id, lvn_tax_unit_id,
                              lvd_start_of_year , lvd_end_of_year  );

    FETCH c_live_ass_action_id INTO lvn_live_aaid;
    close c_live_ass_action_id;


   /* Get archive balance */



       lvn_archive_value := get_archive_value ( i.assignment_action_id,
                           lvc_balance_name,
                           lvn_tax_unit_id,
                           lvc_jurisdiction,
                           lvn_level
                          ) ;

   /* Get Live Balance */
            populate_balance_value(lvn_live_aaid,p_box_name);

    hr_utility.set_location(gv_package_name || '.select_employee', 40);
       lvn_live_value := get_live_value (
                           lvc_balance_name
                                            ) ;

    hr_utility.set_location(gv_package_name || '.select_employee', 50);
   /* Compare the Balances  */
       IF lvn_live_value <> lvn_archive_value THEN
                 /* Get the value of person */
            null;
         /* get person Value */

         hr_utility.set_location(gv_package_name || '.select_employee', 60);
         lvc_last_name := hr_us_w2_rep.get_per_item(i.assignment_action_id,'A_PER_LAST_NAME' );
         lvc_first_name  :=hr_us_w2_rep.get_per_item(i.assignment_action_id,'A_PER_FIRST_NAME' );
         lvc_national_identifier := nvl(hr_us_w2_rep.get_per_item(i.assignment_action_id, 'A_PER_NATIONAL_IDENTIFIER'),'Applied For');
         open c_employee_number(i.serial_number);
         FETCH c_employee_number INTO lvc_employee_number ;
         close c_employee_number ;

         lvc_name := lvc_first_name || ' ' || lvc_last_name ;
         lvc_name := replace(lvc_name,',',' ');

         hr_utility.set_location(gv_package_name || '.select_employee', 70);

        /* Print header for the first time  for Federal or state comparision*/
        if lvn_diff_count = 0 THEN

           fnd_file.put_line(fnd_file.output, formated_header_string(
                                          gv_title || ':- Tax Year: ' || lvc_year  || ' (  ' || lvc_date_time || ' ) '
                                         ,p_output_file_type
                                         ));

           IF p_output_file_type ='HTML' THEN
               FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '<body>');
               FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '<table border=1>');
               FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '<tr>');
            END IF;


           IF p_fed_state =  'Federal'  AND lvn_diff_count = 0 THEN
              fnd_file.put_line(fnd_file.output,formated_header_federal( p_output_file_type));
              lvc_label1 := formated_header_federal( p_output_file_type);

            ELSIF p_fed_state = 'State' and lvn_diff_count = 0 THEN
             fnd_file.put_line(fnd_file.output,formated_header_state( p_output_file_type));
             lvc_label1 :=  formated_header_state ( p_output_file_type);
             END IF;    /* p_fed_state =  Federal */

            IF p_output_file_type ='HTML' THEN
                FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '</tr>');
            END IF;
        END IF;
        lvn_diff_value := lvn_archive_value - lvn_live_value ;

        /* print details based on record */

         hr_utility.set_location(gv_package_name || '.select_employee', 80);
        IF p_fed_state =  'Federal' THEN


            lv_data_row :=  formated_detail_federal(
                                    p_output_file_type
                                   ,lvc_year
                                   ,lvc_gre_name
                                   ,lvc_name
                                   ,lvc_national_identifier
                                   ,lvc_employee_number
                                   ,lvc_lookup_description
                                   ,lvn_live_value
                                   ,lvn_archive_value
                                   ,lvn_diff_value );

            if p_output_file_type ='HTML' then
               lv_data_row := '<tr>' || lv_data_row || '</tr>' ;
            end if;

            FND_FILE.PUT_LINE(FND_FILE.OUTPUT, lv_data_row);


            hr_utility.set_location(gv_package_name || '.select_employee', 90);
        ELSIF p_fed_state = 'State' THEN


             lv_data_row :=   formated_detail_state(
                                    p_output_file_type
                                   ,lvc_year
                                   ,lvc_gre_name
                                   ,lvc_state_abbrev
                                   ,lvc_jurisdiction
                                   ,lvc_name
                                   ,lvc_national_identifier
                                   ,lvc_employee_number
                                   ,lvc_lookup_description
                                   ,lvn_live_value
                                   ,lvn_archive_value
                                   ,lvn_diff_value
                                    );

            IF p_output_file_type ='HTML' THEN
               lv_data_row := '<tr>' || lv_data_row || '</tr>' ;
            end if;

            FND_FILE.PUT_LINE(FND_FILE.OUTPUT, lv_data_row);

         hr_utility.set_location(gv_package_name || '.select_employee', 100);

        END IF; /* to print the details */

         /* increament the count of Imployee */

         lvn_diff_count := lvn_diff_count + 1;

       END IF;  /* if balance dont match */

        lvn_employee_count := lvn_employee_count + 1;

        /* re-initalizing value to zero */
        lvn_live_value := 0;
        lvn_archive_value := 0;
        zero_balance_value();
    end loop; /* for assignment picked up */

    /* Zero Employee were compared up by Report */


    IF lvn_employee_count = 0 THEN
        formated_zero_count(p_output_file_type);
        hr_utility.set_location(gv_package_name || '.select_employee', 110);
    END IF ;

    /* If there was anything written then clsoe for HTML format */

   /* Bug 2554865 - Modified Employee's to Employees */
   lvc_message := 'For ' || lvc_lookup_description ||  ', Number of Employees compared = '
                   || to_char(lvn_employee_count) || ',  Number of Employees with difference = '
                   || to_char(lvn_diff_count);

    IF  lvn_employee_count > 0 THEN
      IF lvn_diff_count > 0 THEN
          IF p_output_file_type ='HTML' THEN
          --        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '</table></body></html>');
                  FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '</table>');
                  FND_FILE.PUT_LINE(FND_FILE.OUTPUT, lvc_message);
                  FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '</body></html>');
          ELSE
                  formated_no_diff(p_output_file_type,lvc_lookup_description,
                                   lvn_employee_count, lvn_diff_count);
          END IF;
      ELSE
         IF p_output_file_type = 'HTML' THEN
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT, lvc_message);
         ELSE
           formated_no_diff(p_output_file_type,lvc_lookup_description,
                            lvn_employee_count, lvn_diff_count);
         END IF; /* if html */

       END IF; /* count > 0 */
          hr_utility.set_location(gv_package_name || '.select_employee', 130);
    END IF; /* IF employee Count > 0 */


   IF p_output_file_type ='HTML' THEN
      UPDATE fnd_concurrent_requests
         SET output_file_type = 'HTML'
       WHERE request_id = FND_GLOBAL.CONC_REQUEST_ID ;

      COMMIT;
   END IF;

    hr_utility.set_location(gv_package_name || '.select_employee', 160);

  END select_employee;



--begin
--hr_utility.trace_on(null, 'ORACLE');
end pay_livearchive_pkg;

/
