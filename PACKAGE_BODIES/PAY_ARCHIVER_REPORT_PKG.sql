--------------------------------------------------------
--  DDL for Package Body PAY_ARCHIVER_REPORT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_ARCHIVER_REPORT_PKG" AS
/* $Header: pyempdtl.pkb 120.1.12010000.2 2008/12/15 20:53:42 tclewis ship $ */
--
/*
 +========================================================================+
 |            Copyright (c) 1997 Oracle Corporation                       |
 |                    All rights reserved.                                |
 +========================================================================+

 Name        : pay_archive_report_pkg

 Description : Package for Employee Periodic Detail Report which drives data
               from External Process Archive.  Output file is in the format
               specificed by the user.
               The current formats supported are
                 - HTML
                 - CSV

 Change List
 -----------
 Date        Name      Vers    Bug No    Description
 ----        ----      ------  -------   -----------
 24-JAN-2002 ekim      115.0             Created.
 17-MAR-2002 ekim      115.1             Made changes for Summary.
 19-MAR-2002 ekim      115.2             Added tax_unit_id check for summary.
 19-MAR-2002 ekim      115.3             Uncommented exit
 24-MAR-2002 ahanda    115.4             Fixed GSCC warnings.
 29-Mar-2002 ekim      115.5             1)Added emp_sum_static_header
                                           procedure.  emp_sum_static_data
                                         2)Changed emp_static_header to
                                           emp_detail_static_header.
                               2294299   3)Added EIC_ADVANCE for federal
                                           balance.
                                         4)Removed p_is_city_mandatory
                                           parameter from archiver_extract
                                           procedure.
                                         5)Re-ordered balance in the following
                                           order:
                                           Gross, Subject, Reduced Subject,
                                           Taxable, Withheld, Liability
                                           (EE and then ER)
                               2294432   6)Changed the cursor to supress all
                                           zero balances.
 02-Apr-2002 ekim      115.6   2294135   Formatted data returned to
                                         999999990.00.
 04-Apr-2002 ekim      115.7             Added null value check.
                                         Commented c_employee_count.
                                         Added sum by jurisdiction_code in case
                                         of multiple assignments, only one row
                                         will be displayed summing up the
                                         totals for the person for the
                                         jurisdiction.
 04-Apr-2002 ekim      115.8             Added nvl for all balances retrieved.
 08-Apr-2002 ekim      115.9             Added jurisdiction check on top of 0
                                         and null check. Added nvl to convert
                                         null values to 0.
 10-Apr-2002 ekim      115.10            Removed lv_school_id.
 15-Apr-2002 ekim      115.11            Removed p_is_county_mandatory, changed
                                         c_city_balance to accomodate null
                                         county_id.
 15-Apr-2002 ekim      115.12            Changed all cursors to check for the
                                         jurisdiction code for 115.11 change.
 13-Jun-2003 ekim      115.13  2974109   Removed setting of ln_prev_person
                                         to ln_person_id that is done before
                                         the end of employee fetch loop
 13-Jun-2003 ekim      115.14            Made GSCC warning change.
 30-Oct-2003           115.15  3217369   Modified the c_state_balances cursor
                                         to use sum(nvl(field,0)) and removed
                                         subquerychecking for null or zero.
 07-Nov-2003           115.16  3217369   removed sub-queries from
                                         c_federal_balances, c_county_balances,
                                         c_city_balances, c_school_balances
                                         cursors
 23-Jan-2004 schauhan  115.17  3369315   Changed the query for the cursors
                                         c_state_balances,c_school_balances,
                                         c_city_balances and
                                         forced the index pay_action_information_n2
                                         to avoid FTS on pay_action_information.
 23-Jan-2004 schauhan  115.18  3395312   Changed the type for the local variable
                                         lv_address_line to the same type as column
                                         address_line of pay_us_employee_action_info_v
                                         The cursor c_employee populates this variable
 12-APR-2005 ahanda    115.19  4294918   Changed local variable length to make sure
                                         it matches the db coulmn length.
 23-aug-2005 sackumar  115.20  4559897   Introduce the missing "if lv_found = 'N' then"
					 condition for federal balance to show the multiple
					 GREs in summary report.
*/

  /***********************************************************
  ** Local Package Variables
  ************************************************************/
  gv_title               VARCHAR2(100) := ' Employee Periodic Details Report ';
  gc_csv_delimiter       VARCHAR2(1) := ',';
  gc_csv_data_delimiter  VARCHAR2(1) := '"';

  gv_html_start_data     VARCHAR2(5) := '<td>'  ;
  gv_html_end_data       VARCHAR2(5) := '</td>' ;

  gv_package_name        VARCHAR2(50) := 'pay_archive_report_pkg';

  /******************************************************************
  ** Function Returns the formated input string based on the
  ** Output format. If the format is CSV then the values are returned
  ** seperated by comma (,). If the format is HTML then the returned
  ** string as the HTML tags. The parameter p_bold only works for
  ** the HTML format.
  ******************************************************************/
  FUNCTION data_string
             (p_input_string     in varchar2
             ,p_format           in varchar2 default 'N'
             ,p_output_file_type in varchar2
             ,p_bold             in varchar2 default 'N'
             )
  RETURN VARCHAR2
  IS

    lv_format          varchar2(5000);
    p_display_string   varchar2(100);

  BEGIN

    if p_format = 'Y' then
      p_display_string := ltrim(to_char(to_number(p_input_string),'999999990.00'));
    else
      p_display_string := p_input_string;
    end if;

    if p_output_file_type = 'CSV' then
       lv_format := gc_csv_data_delimiter || p_display_string ||
                           gc_csv_data_delimiter || gc_csv_delimiter;
    elsif p_output_file_type = 'HTML' then
       if p_display_string is null then
          lv_format := gv_html_start_data || '&nbsp;' || gv_html_end_data;
       else
          if p_bold = 'Y' then
             lv_format := gv_html_start_data || '<b> ' || p_display_string
                             || '</b>' || gv_html_end_data;
          else
             lv_format := gv_html_start_data || p_display_string || gv_html_end_data;
          end if;
       end if;
    end if;
    return lv_format;
  END data_string;


  /************************************************************
  ** Function returns the string with the HTML Header tags
  ************************************************************/
  FUNCTION title_string
             (p_input_string     in varchar2
             ,p_output_file_type in varchar2
             )
  RETURN VARCHAR2
  IS

    lv_format          varchar2(1000);

  BEGIN
    if p_output_file_type = 'CSV' then
       lv_format := p_input_string;
    elsif p_output_file_type = 'HTML' then
       lv_format := '<HTML><HEAD> <CENTER> <H1> <B>' || p_input_string ||
                             '</B></H1></CENTER></HEAD>';
    end if;

    return lv_format;

  END title_string;

  FUNCTION f_state_ein
             (pv_tax_unit_id     in number
             ,pv_state_id         in varchar2)
  RETURN VARCHAR2
  IS

    l_state_ein hr_organization_information.org_information3%type;

  BEGIN

    SELECT hoi.org_information3
      INTO l_state_ein
      FROM hr_organization_information hoi,
           pay_us_states pus
     WHERE pus.state_code = pv_state_id
       and hoi.organization_id = pv_tax_unit_id
       and hoi.org_information_context = 'State Tax Rules'
       and hoi.org_information1 = pus.state_abbrev;

    return l_state_ein;

  exception
    when no_data_found then
       return l_state_ein;

    when others then
       raise;

  END f_state_ein;


  PROCEDURE emp_detail_static_header(
              p_output_file_type    in varchar2
             ,p_emp_static_label    out nocopy varchar2
             )
  IS
    l_emp_detail_format       varchar2(32000);
  BEGIN

    l_emp_detail_format :=
              data_string (p_input_string => 'Last Name'
                              ,p_bold     => 'Y'
                              ,p_output_file_type => p_output_file_type) ||
              data_string (p_input_string => 'First Name'
                              ,p_bold     => 'Y'
                              ,p_output_file_type => p_output_file_type) ||
              data_string (p_input_string => 'Middle Name'
                              ,p_bold     => 'Y'
                              ,p_output_file_type => p_output_file_type) ||
              data_string (p_input_string => 'Employee Number'
                              ,p_bold     => 'Y'
                              ,p_output_file_type => p_output_file_type) ||
              data_string (p_input_string => 'Assignment Number'
                              ,p_bold     => 'Y'
                              ,p_output_file_type => p_output_file_type) ||
              data_string (p_input_string => 'SSN'
                              ,p_bold     => 'Y'
                              ,p_output_file_type => p_output_file_type) ||
              data_string (p_input_string => 'Address'
                              ,p_bold     => 'Y'
                              ,p_output_file_type => p_output_file_type) ||
              data_string (p_input_string => 'City'
                              ,p_bold     => 'Y'
                              ,p_output_file_type => p_output_file_type) ||
              data_string (p_input_string => 'County'
                              ,p_bold     => 'Y'
                              ,p_output_file_type => p_output_file_type) ||
              data_string (p_input_string => 'State'
                              ,p_bold     => 'Y'
                              ,p_output_file_type => p_output_file_type) ||
              data_string (p_input_string => 'Zip'
                              ,p_bold     => 'Y'
                              ,p_output_file_type => p_output_file_type) ||
              data_string (p_input_string => 'Country'
                              ,p_bold     => 'Y'
                              ,p_output_file_type => p_output_file_type) ||
              data_string (p_input_string => 'Fed EIN'
                              ,p_bold     => 'Y'
                              ,p_output_file_type => p_output_file_type) ||
              data_string (p_input_string => 'Organization'
                              ,p_bold     => 'Y'
                              ,p_output_file_type => p_output_file_type) ||
              data_string (p_input_string => 'Location'
                              ,p_bold     => 'Y'
                              ,p_output_file_type => p_output_file_type) ||
              data_string (p_input_string => 'Action Type'
                              ,p_bold     => 'Y'
                              ,p_output_file_type => p_output_file_type) ||
              data_string (p_input_string => 'Effective Date'
                              ,p_bold     => 'Y'
                              ,p_output_file_type => p_output_file_type)
              ;

    p_emp_static_label := l_emp_detail_format;
    hr_utility.set_location(gv_package_name||'.emp_detail_static_header',20);
  END;

  PROCEDURE emp_sum_static_header(
              p_output_file_type    in varchar2
             ,p_emp_static_label    out nocopy varchar2
             )
  IS
    l_emp_sum_format       varchar2(32000);
  BEGIN

    l_emp_sum_format :=
              data_string (p_input_string => 'Last Name'
                              ,p_bold         => 'Y'
                              ,p_output_file_type => p_output_file_type) ||
              data_string (p_input_string => 'First Name'
                              ,p_bold         => 'Y'
                              ,p_output_file_type => p_output_file_type) ||
              data_string (p_input_string => 'Middle Name'
                              ,p_bold         => 'Y'
                              ,p_output_file_type => p_output_file_type) ||
              data_string (p_input_string => 'Employee Number'
                              ,p_bold         => 'Y'
                              ,p_output_file_type => p_output_file_type) ||
              data_string (p_input_string => 'SSN'
                              ,p_bold         => 'Y'
                              ,p_output_file_type => p_output_file_type) ||
              data_string (p_input_string => 'Fed EIN'
                              ,p_bold         => 'Y'
                              ,p_output_file_type => p_output_file_type)
              ;

    p_emp_static_label := l_emp_sum_format;
    hr_utility.set_location(gv_package_name||'.emp_sum_static_header',20);
  END;

  PROCEDURE fed_static_header(
              p_output_file_type  in varchar2
             ,p_fed_static_label  out nocopy varchar2
             )
  IS
    l_fed_format          varchar2(32000);
  BEGIN

     -- hr_utility.set_location(gv_package_name || '.fed_static_header', 10);
      l_fed_format :=
              data_string (p_input_string => 'GRE Name'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||
              data_string (p_input_string => 'FIT Gross'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||
              data_string (p_input_string => 'FIT Wages'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||
              data_string (p_input_string => 'FIT Withheld'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||
              data_string (p_input_string => 'FUTA Taxable'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||
              data_string (p_input_string => 'FUTA Liability'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||
              data_string (p_input_string => 'SS EE Taxable'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||
              data_string (p_input_string => 'SS EE Withheld'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||
              data_string (p_input_string => 'SS ER Taxable'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||
              data_string (p_input_string => 'SS ER Liability'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||
              data_string (p_input_string => 'Med EE Taxable'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||
              data_string (p_input_string => 'Med EE Withheld'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||
              data_string (p_input_string => 'Med ER Taxable'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||
              data_string (p_input_string => 'Med ER Liability'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||
              data_string (p_input_string => 'Advance EIC'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type)
              ;

       p_fed_static_label := l_fed_format;
       hr_utility.set_location(gv_package_name||'.fed_static_header',20);

  END;

  PROCEDURE state_static_header ( p_output_file_type    in varchar2
                                 ,p_state_static_label out nocopy varchar2)
  IS
    l_state_format        varchar2(32000);
  BEGIN
   -- hr_utility.set_location(gv_package_name||'.state_static_header',10);

    l_state_format :=
              data_string (p_input_string => 'GRE Name'
                              ,p_bold         => 'Y'
                              ,p_output_file_type => p_output_file_type) ||
              data_string (p_input_string => 'State EIN'
                              ,p_bold         => 'Y'
                              ,p_output_file_type => p_output_file_type) ||
              data_string (p_input_string => 'Jurisdiction'
                              ,p_bold         => 'Y'
                              ,p_output_file_type => p_output_file_type) ||
              data_string (p_input_string => 'State'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||
              data_string (p_input_string => 'SIT Gross'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||
              data_string (p_input_string => 'SIT wages'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||
              data_string (p_input_string => 'SIT Withheld'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||
              data_string (p_input_string => 'SUI EE Taxable'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||
              data_string (p_input_string => 'SUI EE Withheld'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||
              data_string (p_input_string => 'SUI ER Taxable'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||
              data_string (p_input_string => 'SUI ER Liability'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||
              data_string (p_input_string => 'SDI EE Taxable'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||
              data_string (p_input_string => 'SDI EE Withheld'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||
              data_string (p_input_string => 'SDI ER Taxable'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||
              data_string (p_input_string => 'SDI ER Liability'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||
              data_string (p_input_string => 'Workers Comp Withheld'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||
              data_string (p_input_string => 'Workers Comp2 Withheld'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||
              data_string (p_input_string => 'SDI1 EE Withheld'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type)
              ;

       p_state_static_label := l_state_format;
       hr_utility.set_location(gv_package_name||'.state_static_header',20);

  END;

  PROCEDURE county_static_header ( p_output_file_type in varchar2
                                    ,p_county_static_label out nocopy varchar2)
  IS
       l_county_format   varchar2(32000);
  BEGIN
    --   hr_utility.set_location(gv_package_name||'.county_static_header',10);

       l_county_format :=
              data_string (p_input_string => 'GRE Name'
                              ,p_bold         => 'Y'
                              ,p_output_file_type => p_output_file_type) ||
              data_string (p_input_string => 'Jurisdiction'
                              ,p_bold         => 'Y'
                              ,p_output_file_type => p_output_file_type) ||
              data_string (p_input_string => 'County Name'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||
              data_string (p_input_string => 'County Gross'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||
              data_string (p_input_string => 'County Wage'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||
              data_string (p_input_string => 'County Withheld'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||
              data_string (p_input_string => 'County Head Tax Withheld'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type)||
              data_string (p_input_string => 'Non Resident Flag'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type)
              ;

       p_county_static_label := l_county_format;
       --hr_utility.trace('Static County label = '||l_county_format);
       hr_utility.set_location(gv_package_name||'.county_static_header',20);

  END;

  PROCEDURE city_static_header ( p_output_file_type in varchar2
                                ,p_city_static_label out nocopy varchar2)
  IS
       l_city_format    varchar2(32000);
  BEGIN
     --  hr_utility.set_location(gv_package_name||'.city_static_header',10);

       l_city_format :=
              data_string (p_input_string => 'GRE Name'
                              ,p_bold         => 'Y'
                              ,p_output_file_type => p_output_file_type) ||
              data_string (p_input_string => 'Jurisdiction'
                              ,p_bold         => 'Y'
                              ,p_output_file_type => p_output_file_type) ||
              data_string (p_input_string => 'City Name'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||
              data_string (p_input_string => 'City Gross'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||
              data_string (p_input_string => 'City Wages'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||
              data_string (p_input_string => 'City Withheld'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||
              data_string (p_input_string => 'City Head Tax Withheld'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type)||
              data_string (p_input_string => 'Non Resident flag'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type)
              ;

       p_city_static_label := l_city_format;
       --hr_utility.trace('Static City label = '||l_city_format);
       hr_utility.set_location(gv_package_name||'.city_static_header',20);
  END;

  PROCEDURE school_static_header ( p_output_file_type in varchar2
                                  ,p_school_static_label out nocopy varchar2)
  IS
       l_school_format    varchar2(32000);
  BEGIN
      -- hr_utility.set_location(gv_package_name||'.school_static_header',10);

       l_school_format :=
              data_string (p_input_string => 'GRE Name'
                              ,p_bold         => 'Y'
                              ,p_output_file_type => p_output_file_type) ||
              data_string (p_input_string => 'Jurisdiction'
                              ,p_bold         => 'Y'
                              ,p_output_file_type => p_output_file_type) ||
              data_string (p_input_string => 'School Dist Name'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||
              data_string (p_input_string => 'School Gross'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||
              data_string (p_input_string => 'School Wages'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||
              data_string (p_input_string => 'School Withheld'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type)
              ;

       p_school_static_label := l_school_format;
       --hr_utility.trace('Static school label = '||l_school_format);
       hr_utility.set_location(gv_package_name||'.school_static_header',20);
  END;

 /*******  Done with creating Static Header *****/

 /*  Create format for data  */

  PROCEDURE emp_static_data (
                   p_last_name                 in varchar2
                  ,p_first_name                in varchar2
                  ,p_middle_name               in varchar2
                  ,p_employee_number           in varchar2
                  ,p_assignment_number         in varchar2
                  ,p_ssn                       in varchar2
                  ,p_address                   in varchar2
                  ,p_city                      in varchar2
                  ,p_county                    in varchar2
                  ,p_state                     in varchar2
                  ,p_zip                       in varchar2
                  ,p_country                   in varchar2
                  ,p_fed_ein                   in varchar2
                  ,p_organization              in varchar2
                  ,p_location                  in varchar2
                  ,p_action_type               in varchar2
                  ,p_effective_date            in varchar2
                  ,p_output_file_type          in varchar2
                  ,p_employee_data           out nocopy varchar2
             )
  IS

    l_emp_static_data VARCHAR2(32000);

  BEGIN

    hr_utility.set_location(gv_package_name || '.emp_static_data', 10);
      l_emp_static_data :=
              data_string (p_input_string => p_last_name
                          ,p_output_file_type => p_output_file_type) ||
              data_string (p_input_string => p_first_name
                          ,p_output_file_type => p_output_file_type) ||
              data_string (p_input_string => p_middle_name
                          ,p_output_file_type => p_output_file_type) ||
              data_string (p_input_string => p_employee_number
                          ,p_output_file_type => p_output_file_type) ||
              data_string (p_input_string => p_assignment_number
                          ,p_output_file_type => p_output_file_type) ||
              data_string (p_input_string => p_ssn
                          ,p_output_file_type => p_output_file_type) ||
              data_string (p_input_string => p_address
                          ,p_output_file_type => p_output_file_type) ||
              data_string (p_input_string => p_city
                          ,p_output_file_type => p_output_file_type) ||
              data_string (p_input_string => p_county
                          ,p_output_file_type => p_output_file_type) ||
              data_string (p_input_string => p_state
                          ,p_output_file_type => p_output_file_type) ||
              data_string (p_input_string => p_zip
                          ,p_output_file_type => p_output_file_type) ||
              data_string (p_input_string => p_country
                          ,p_output_file_type => p_output_file_type) ||
              data_string (p_input_string => p_fed_ein
                          ,p_output_file_type => p_output_file_type) ||
              data_string (p_input_string => p_organization
                          ,p_output_file_type => p_output_file_type) ||
              data_string (p_input_string => p_location
                          ,p_output_file_type => p_output_file_type) ||
              data_string (p_input_string => p_action_type
                          ,p_output_file_type => p_output_file_type) ||
              data_string (p_input_string => p_effective_date
                          ,p_output_file_type => p_output_file_type)
              ;

      p_employee_data := l_emp_static_data;

      --hr_utility.trace('Employee Header = '||l_emp_static_data);
      hr_utility.set_location(gv_package_name || '.emp_static_data', 20);
  END;

  PROCEDURE emp_sum_static_data (
                   p_last_name                 in varchar2
                  ,p_first_name                in varchar2
                  ,p_middle_name               in varchar2
                  ,p_employee_number           in varchar2
                  ,p_ssn                       in varchar2
                  ,p_fed_ein                   in varchar2
                  ,p_output_file_type          in varchar2
                  ,p_employee_data           out nocopy varchar2
             )
  IS

    l_emp_sum_static_data VARCHAR2(32000);

  BEGIN

    hr_utility.set_location(gv_package_name || '.emp_static_data', 10);
      l_emp_sum_static_data :=
              data_string (p_input_string => p_last_name
                          ,p_output_file_type => p_output_file_type) ||
              data_string (p_input_string => p_first_name
                          ,p_output_file_type => p_output_file_type) ||
              data_string (p_input_string => p_middle_name
                          ,p_output_file_type => p_output_file_type) ||
              data_string (p_input_string => p_employee_number
                          ,p_output_file_type => p_output_file_type) ||
              data_string (p_input_string => p_ssn
                          ,p_output_file_type => p_output_file_type) ||
              data_string (p_input_string => p_fed_ein
                          ,p_output_file_type => p_output_file_type)
              ;

      p_employee_data := l_emp_sum_static_data;

      --hr_utility.trace('Employee Header = '||l_emp_static_data);
      hr_utility.set_location(gv_package_name || '.emp_static_data', 20);
  END;

  PROCEDURE fed_static_data (
                   p_gre_name             in varchar2
                  ,p_fit_gross            in number
                  ,p_fit_reduced_subject  in number
                  ,p_fit_withheld         in number
                  ,p_futa_taxable         in number
                  ,p_futa_liability       in number
                  ,p_ss_ee_taxable        in number
                  ,p_ss_ee_withheld       in number
                  ,p_ss_er_taxable        in number
                  ,p_ss_er_liability      in number
                  ,p_med_ee_taxable       in number
                  ,p_med_ee_withheld      in number
                  ,p_med_er_taxable       in number
                  ,p_med_er_liability     in number
                  ,p_eic_advance          in number
                  ,p_output_file_type     in varchar2
                  ,p_federal_data       out nocopy varchar2
                )
  IS
     l_fed_static_data     varchar2(32000);

  BEGIN
     --hr_utility.set_location(gv_package_name || '.fit_static_data', 10);
     l_fed_static_data :=
              data_string (p_input_string => p_gre_name
                          ,p_output_file_type => p_output_file_type) ||
              data_string (p_input_string => p_fit_gross
                          ,p_format       => 'Y'
                          ,p_output_file_type => p_output_file_type) ||
              data_string (p_input_string => p_fit_reduced_subject
                          ,p_format       => 'Y'
                          ,p_output_file_type => p_output_file_type) ||
              data_string (p_input_string => p_fit_withheld
                          ,p_format       => 'Y'
                          ,p_output_file_type => p_output_file_type) ||
              data_string (p_input_string => p_futa_taxable
                          ,p_format       => 'Y'
                          ,p_output_file_type => p_output_file_type) ||
              data_string (p_input_string => p_futa_liability
                          ,p_format       => 'Y'
                          ,p_output_file_type => p_output_file_type) ||
              data_string (p_input_string => p_ss_ee_taxable
                          ,p_format       => 'Y'
                          ,p_output_file_type => p_output_file_type) ||
              data_string (p_input_string => p_ss_ee_withheld
                          ,p_format       => 'Y'
                          ,p_output_file_type => p_output_file_type) ||
              data_string (p_input_string => p_ss_er_taxable
                          ,p_format       => 'Y'
                          ,p_output_file_type => p_output_file_type) ||
              data_string (p_input_string => p_ss_er_liability
                          ,p_format       => 'Y'
                          ,p_output_file_type => p_output_file_type) ||
              data_string (p_input_string => p_med_ee_taxable
                          ,p_format       => 'Y'
                          ,p_output_file_type => p_output_file_type) ||
              data_string (p_input_string => p_med_ee_withheld
                          ,p_format       => 'Y'
                          ,p_output_file_type => p_output_file_type) ||
              data_string (p_input_string => p_med_er_taxable
                          ,p_format       => 'Y'
                          ,p_output_file_type => p_output_file_type) ||
              data_string (p_input_string => p_med_er_liability
                          ,p_format       => 'Y'
                          ,p_output_file_type => p_output_file_type) ||
              data_string (p_input_string => p_eic_advance
                          ,p_format       => 'Y'
                          ,p_output_file_type => p_output_file_type)
             ;


     p_federal_data := l_fed_static_data;
--     hr_utility.trace('Federal Data = '||p_federal_data);
     hr_utility.set_location(gv_package_name || '.fit_static_data', 20);
  END;

  PROCEDURE state_static_data(
                   p_gre_name         in varchar2
                  ,p_state_ein        in varchar2
                  ,p_jurisdiction     in varchar2
                  ,p_state            in varchar2
                  ,p_sit_gross        in number
                  ,p_sit_wages        in number
                  ,p_sit_withheld     in number
                  ,p_sui_ee_taxable   in number
                  ,p_sui_ee_withheld  in number
                  ,p_sui_er_taxable   in number
                  ,p_sui_er_liability in number
                  ,p_sdi_ee_taxable   in number
                  ,p_sdi_ee_withheld  in number
                  ,p_sdi_er_taxable   in number
                  ,p_sdi_er_liability in number
                  ,p_workers_comp_wh  in number
                  ,p_workers_comp2_wh in number
                  ,p_sdi1_ee_withheld  in number
                  ,p_output_file_type in varchar2
                  ,p_state_data         out nocopy varchar2
                 )
  IS
    l_state_static_data        varchar2(32000);

  BEGIN
    --hr_utility.set_location(gv_package_name || '.state_static_data', 10);
    l_state_static_data :=
              data_string (p_input_string => p_gre_name
                          ,p_output_file_type => p_output_file_type) ||
              data_string (p_input_string => p_state_ein
                          ,p_output_file_type => p_output_file_type) ||
              data_string (p_input_string => p_jurisdiction
                          ,p_output_file_type => p_output_file_type) ||
              data_string (p_input_string => p_state
                          ,p_output_file_type => p_output_file_type) ||
              data_string (p_input_string => p_sit_gross
                          ,p_format       => 'Y'
                          ,p_output_file_type => p_output_file_type) ||
              data_string (p_input_string => p_sit_wages
                          ,p_format       => 'Y'
                          ,p_output_file_type => p_output_file_type) ||
              data_string (p_input_string => p_sit_withheld
                          ,p_format       => 'Y'
                          ,p_output_file_type => p_output_file_type) ||
              data_string (p_input_string => p_sui_ee_taxable
                          ,p_format       => 'Y'
                          ,p_output_file_type => p_output_file_type) ||
              data_string (p_input_string => p_sui_ee_withheld
                          ,p_format       => 'Y'
                          ,p_output_file_type => p_output_file_type) ||
              data_string (p_input_string => p_sui_er_taxable
                          ,p_format       => 'Y'
                          ,p_output_file_type => p_output_file_type) ||
              data_string (p_input_string => p_sui_er_liability
                          ,p_format       => 'Y'
                          ,p_output_file_type => p_output_file_type) ||
              data_string (p_input_string => p_sdi_ee_taxable
                          ,p_format       => 'Y'
                          ,p_output_file_type => p_output_file_type) ||
              data_string (p_input_string => p_sdi_ee_withheld
                          ,p_format       => 'Y'
                          ,p_output_file_type => p_output_file_type) ||
              data_string (p_input_string => p_sdi_er_taxable
                          ,p_format       => 'Y'
                          ,p_output_file_type => p_output_file_type) ||
              data_string (p_input_string => p_sdi_er_liability
                          ,p_format       => 'Y'
                          ,p_output_file_type => p_output_file_type) ||
              data_string (p_input_string => p_workers_comp_wh
                          ,p_format       => 'Y'
                          ,p_output_file_type => p_output_file_type) ||
              data_string (p_input_string => p_workers_comp2_wh
                          ,p_format       => 'Y'
                          ,p_output_file_type => p_output_file_type) ||
              data_string (p_input_string => p_sdi1_ee_withheld
                          ,p_format       => 'Y'
                          ,p_output_file_type => p_output_file_type)
              ;

    p_state_data := l_state_static_data;

 --   hr_utility.trace('State data = '||p_state_data);
    hr_utility.set_location(gv_package_name || '.state__static_data', 20);
  END;


  PROCEDURE county_static_data(
                   p_gre_name         in varchar2
                  ,p_jurisdiction       in varchar2
                  ,p_county_name        in varchar2
                  ,p_county_gross       in number
                  ,p_county_wage        in number
                  ,p_county_withheld    in number
                  ,p_co_head_tax_wh     in number
                  ,p_non_resident_flag  in varchar2
                  ,p_output_file_type   in varchar2
                  ,p_county_data        out nocopy varchar2
                 )
  IS
    l_county_static_data        varchar2(32000);

  BEGIN
   -- hr_utility.set_location(gv_package_name || '.county_static_data', 10);
    l_county_static_data :=
              data_string (p_input_string => p_gre_name
                          ,p_output_file_type => p_output_file_type) ||
              data_string (p_input_string => p_jurisdiction
                          ,p_output_file_type => p_output_file_type) ||
              data_string (p_input_string => p_county_name
                          ,p_output_file_type => p_output_file_type) ||
              data_string (p_input_string => p_county_gross
                          ,p_format       => 'Y'
                          ,p_output_file_type => p_output_file_type) ||
              data_string (p_input_string => p_county_wage
                          ,p_format       => 'Y'
                          ,p_output_file_type => p_output_file_type) ||
              data_string (p_input_string => p_county_withheld
                          ,p_format       => 'Y'
                          ,p_output_file_type => p_output_file_type) ||
              data_string (p_input_string => p_co_head_tax_wh
                          ,p_format       => 'Y'
                          ,p_output_file_type => p_output_file_type) ||
              data_string (p_input_string => p_non_resident_flag
                          ,p_output_file_type => p_output_file_type)
              ;
    p_county_data := l_county_static_data;
--    hr_utility.trace('County data = '||p_county_data);
    hr_utility.set_location(gv_package_name || '.county_static_data', 20);
  END;


  PROCEDURE city_static_data(
                   p_gre_name         in varchar2
                  ,p_jurisdiction     in varchar2
                  ,p_city_name        in varchar2
                  ,p_city_gross       in number
                  ,p_city_wage        in number
                  ,p_city_withheld    in number
                  ,p_cty_head_tax_wh  in number
                  ,p_non_resident_flag in varchar2
                  ,p_output_file_type in varchar2
                  ,p_city_data        out nocopy varchar2
                 )
  IS
    l_city_static_data        varchar2(32000);
  BEGIN
    --hr_utility.set_location(gv_package_name || '.city_static_data', 10);
    l_city_static_data :=
              data_string (p_input_string => p_gre_name
                          ,p_output_file_type => p_output_file_type) ||
              data_string (p_input_string => p_jurisdiction
                          ,p_output_file_type => p_output_file_type) ||
              data_string (p_input_string => p_city_name
                          ,p_output_file_type => p_output_file_type) ||
              data_string (p_input_string => p_city_gross
                          ,p_format       => 'Y'
                          ,p_output_file_type => p_output_file_type) ||
              data_string (p_input_string => p_city_wage
                          ,p_format       => 'Y'
                          ,p_output_file_type => p_output_file_type) ||
              data_string (p_input_string => p_city_withheld
                          ,p_format       => 'Y'
                          ,p_output_file_type => p_output_file_type) ||
              data_string (p_input_string => p_cty_head_tax_wh
                          ,p_format       => 'Y'
                          ,p_output_file_type => p_output_file_type) ||
              data_string (p_input_string => p_non_resident_flag
                          ,p_output_file_type => p_output_file_type)
              ;

    p_city_data := l_city_static_data;
--    hr_utility.trace('City data = '||p_city_data);
    hr_utility.set_location(gv_package_name || '.city_static_data', 20);
  END;

  PROCEDURE school_static_data(
                   p_gre_name           in varchar2
                  ,p_jurisdiction       in varchar2
                  ,p_school_dist_name   in varchar2
                  ,p_school_gross       in number
                  ,p_school_reduced_subject in number
                  ,p_school_withheld    in number
                  ,p_output_file_type   in varchar2
                  ,p_school_data        out nocopy varchar2
                 )
  IS
    l_school_static_data        varchar2(32000);

  BEGIN
   -- hr_utility.set_location(gv_package_name || '.school_static_data', 10);
    l_school_static_data :=
              data_string (p_input_string => p_gre_name
                          ,p_output_file_type => p_output_file_type) ||
              data_string (p_input_string => p_jurisdiction
                          ,p_output_file_type => p_output_file_type) ||
              data_string (p_input_string => p_school_dist_name
                          ,p_output_file_type => p_output_file_type) ||
              data_string (p_input_string => p_school_gross
                          ,p_format       => 'Y'
                          ,p_output_file_type => p_output_file_type) ||
              data_string (p_input_string => p_school_reduced_subject
                          ,p_format       => 'Y'
                          ,p_output_file_type => p_output_file_type) ||
              data_string (p_input_string => p_school_withheld
                          ,p_format       => 'Y'
                          ,p_output_file_type => p_output_file_type)
              ;

    p_school_data := l_school_static_data;
--    hr_utility.trace('School data = '||p_school_data);
    hr_utility.set_location(gv_package_name || '.school_static_data', 20);
  END;


  /*****************************************************************
  ** This is the main procedure which is called from the Concurrent
  ** Request. All the paramaters are passed based on which it will
  ** either print a CSV format or an HTML format file.
  *****************************************************************/

  PROCEDURE archiver_extract
             (errbuf                      out nocopy varchar2
             ,retcode                     out nocopy number
             ,p_business_group_id         in  number
             ,p_beginning_date            in  varchar2
             ,p_end_date                  in  varchar2
             ,p_jurisdiction_level        in  varchar2
             ,p_detail_level              in  varchar2
             ,p_is_byRun                  in  varchar2
             ,p_organization_id           in  number
             ,p_location_id               in  number
             ,p_is_summary                in  varchar2
             ,p_is_state                  in  varchar2
             ,p_state_id                  in  varchar2
             ,p_is_county                 in  varchar2
             ,p_is_state_mandatory        in  varchar2
             ,p_county_id                 in  varchar2
             ,p_is_city                   in  varchar2
             ,p_city_id                   in  varchar2
             ,p_is_school                 in  varchar2
             ,p_school_id                 in  varchar2
             ,p_payroll_id                in  number
             ,p_consolidation_set_id      in  number
             ,p_tax_unit_id               in  varchar2
             ,p_assignment_set_id         in  number
             ,p_output_file_type          in  varchar2
             )
  IS

    /************************************************************
    ** Cursor to get all the employee and assignment data.
    ** This cursor will return one row for each tax type
    ** for the Selection parameter entered by the user in the SRS.
    ** the action_context_id returned by this cursor is used to
    ** retreive the jurisdiction specific level tax information.
    ************************************************************/

    cursor c_employee (
                       cp_beginning_date           in date
                      ,cp_end_date             in date
                      ,cp_payroll_id           in number
                      ,cp_consolidation_set_id in number
                      ,cp_organization_id      in number
                      ,cp_tax_unit_id          in number
                      ,cp_location_id          in number
                      ,cp_business_group_id    in number
                      ) is
       SELECT action_number, last_name, first_name, middle_names,
              employee_number,
              assignment_number,
              assignment_id,
              national_identifier,
              address_line, town_or_city, county, state,
              postal_code,country,
              tax_unit_id, gre_name, fed_ein, org_name, location_code,
              action_type, person_id, effective_date
         FROM pay_us_employee_action_info_v peav
        WHERE peav.effective_date between cp_beginning_date and cp_end_date
          and nvl(cp_business_group_id,peav.business_group_id)
              = peav.business_group_id
          and nvl(cp_location_id,peav.location_id) = peav.location_id
          and nvl(cp_organization_id, peav.organization_id)
              = peav.organization_id
          and nvl(cp_payroll_id, peav.payroll_id) = peav.payroll_id
          and nvl(cp_tax_unit_id, peav.tax_unit_id) = peav.tax_unit_id
          and nvl(cp_consolidation_set_id, peav.consolidation_set_id)
              = peav.consolidation_set_id
         order by person_id, effective_date asc;

    cursor c_employee_count (
                       cp_beginning_date           in date
                      ,cp_end_date             in date
                      ,cp_payroll_id           in number
                      ,cp_consolidation_set_id in number
                      ,cp_organization_id      in number
                      ,cp_tax_unit_id          in number
                      ,cp_location_id          in number
                      ,cp_business_group_id    in number
                      ) is
       SELECT person_id, last_name, action_number
         FROM pay_us_employee_action_info_v peav
        WHERE peav.effective_date between cp_beginning_date and cp_end_date
          and nvl(cp_business_group_id,peav.business_group_id)
              = peav.business_group_id
          and nvl(cp_location_id,peav.location_id) = peav.location_id
          and nvl(cp_organization_id, peav.organization_id)
              = peav.organization_id
          and nvl(cp_payroll_id, peav.payroll_id) = peav.payroll_id
          and nvl(cp_tax_unit_id, peav.tax_unit_id) = peav.tax_unit_id
          and nvl(cp_consolidation_set_id, peav.consolidation_set_id)
              = peav.consolidation_set_id;



    /****************************************************************
    ** This cursor returns Federal Level Balances for the selected **
    ** assignments from the archiver.                              **
    ****************************************************************/
    CURSOR c_federal_balances(cp_action_number in number) is
        select action_number, sum(fit_gross),
               sum(fit_reduced_subject),
               sum(fit_withheld),
               sum(futa_taxable),
               sum(futa_liability),
               sum(ss_ee_taxable),
               sum(ss_ee_withheld),
               sum(ss_er_taxable),
               sum(ss_er_liability),
               sum(medicare_ee_taxable),
               sum(medicare_ee_withheld),
               sum(medicare_er_taxable),
               sum(medicare_er_liability),
               sum(eic_advance)
          FROM pay_us_federal_action_info_v fed
          WHERE fed.action_number = cp_action_number
/*            and cp_action_number not in
                      (select fed2.action_number
                       from pay_us_federal_action_info_v fed2
                       where (fed2.fit_gross = 0
                              or fed2.fit_gross is null)
                         and (fed2.fit_withheld = 0
                              or fed2.fit_withheld is null)
                         and (fed2.fit_reduced_subject = 0
                              or fed2.fit_reduced_subject is null)
                         and (fed2.futa_liability = 0
                              or fed2.futa_liability is null)
                         and (fed2.futa_taxable = 0
                              or fed2.futa_taxable is null)
                         and (fed2.ss_ee_withheld = 0
                              or fed2.ss_ee_withheld is null)
                         and (fed2.ss_ee_taxable = 0
                              or fed2.ss_ee_taxable is null)
                         and (fed2.ss_er_liability = 0
                              or fed2.ss_er_liability is null)
                         and (fed2.ss_er_taxable = 0
                              or fed2.ss_er_taxable is null)
                         and (fed2.medicare_ee_withheld = 0
                              or fed2.medicare_ee_withheld is null)
                         and (fed2.medicare_ee_taxable = 0
                              or fed2.medicare_ee_taxable is null)
                         and (fed2.medicare_er_taxable = 0
                              or fed2.medicare_er_taxable is null)
                         and (fed2.medicare_er_liability = 0
                              or fed2.medicare_er_liability is null)
                         and (fed2.eic_advance = 0
                              or fed2.eic_advance is null))  */
          GROUP BY action_number;

--Bug3369315  --Changed the cursor query for c_state_balances and forced the index pay_action_information_n2
              -- to remove FTS from pay_action_information on HRPPG2.

   CURSOR c_state_balances(cp_action_number in number,
                           cp_state_id      in varchar2) IS
       select /*+ index(state.pai pay_action_information_n2) */ jurisdiction_code,
              jurisdiction_name,
              sum(nvl(sit_gross,0)),
              sum(nvl(sit_reduced_subject,0)),
              sum(nvl(sit_withheld,0)),
              sum(nvl(sui_ee_taxable,0)),
              sum(nvl(sui_ee_withheld,0)),
              sum(nvl(sui_er_taxable,0)),
              sum(nvl(sui_er_liability,0)),
              sum(nvl(sdi_ee_taxable,0)),
              sum(nvl(sdi_ee_withheld,0)),
              sum(nvl(sdi_er_taxable,0)),
              sum(nvl(sdi_er_liability,0)),
              sum(nvl(workers_comp_withheld,0)),
              sum(nvl(workers_comp2_withheld,0)),
              sum(nvl(SDI1_EE_Withheld,0))
         from pay_us_state_action_info_v state
        where state.action_number = cp_action_number
          and state.jurisdiction_code like nvl(cp_state_id,'%')||'-000-0000'
           group by jurisdiction_code, jurisdiction_name;


   CURSOR c_county_balances(cp_action_number in number,
                            cp_state_id      in varchar2,
                            cp_county_id     in varchar2) IS
       select jurisdiction_code,
              jurisdiction_name,
              sum(county_gross),
              sum(county_reduced_subject),
              sum(county_withheld),
              sum(head_tax_withheld),
              decode(non_resident_flag,'NR','WK','R','RS',non_resident_flag)
         from pay_us_county_action_info_v county
        where county.action_number = cp_action_number
          and county.jurisdiction_code
              like cp_state_id||'-'||nvl(cp_county_id,'%')||'-0000'
/*          and cp_action_number not in (select county2.action_number
                            from pay_us_county_action_info_v county2
                           where (county2.county_gross = 0
                                  or county2.county_gross is null)
                             and (county2.county_reduced_subject = 0
                                  or county2.county_reduced_subject is null)
                             and (county2.county_withheld = 0
                                  or county2.county_withheld is null)
                             and (county2.head_tax_withheld = 0
                                  or county2.head_tax_withheld is null)
                             and county2.jurisdiction_code
                                 = county.jurisdiction_code)  */
        GROUP BY jurisdiction_code, jurisdiction_name,
                 decode(non_resident_flag,'NR','WK','R','RS',non_resident_flag);


--Bug3369315 --Changed the cursor query for c_city_balances and forced the index pay_action_information_n2
             -- to remove FTS from pay_action_information on HRPPG2.

   CURSOR c_city_balances(cp_action_number in number,
                          cp_state_id      in varchar2,
                          cp_county_id     in varchar2,
                          cp_city_id       in varchar2) IS
     select /*+ index(city.pai pay_action_information_n2) */ jurisdiction_code,
            jurisdiction_name,
            sum(city_gross),
            sum(city_reduced_subject),
            sum(city_withheld),
            sum(head_tax_withheld),
            decode(non_resident_flag,'NR','WK','R','RS',non_resident_flag)
       from pay_us_city_action_info_v city
      where city.action_number = cp_action_number
        and city.jurisdiction_code
         like cp_state_id||'-'||nvl(cp_county_id,'%')||'-'||nvl(cp_city_id,'%')
/*        and cp_action_number not in (select city2.action_number
                          from pay_us_city_action_info_v city2
                         where (city2.city_gross = 0
                                or city2.city_gross is null)
                           and (city2.city_reduced_subject = 0
                                or city2.city_reduced_subject is null)
                           and (city2.city_withheld = 0
                                or city2.city_withheld is null)
                           and (city2.head_tax_withheld = 0
                                or city2.head_tax_withheld is null)
                           and city2.jurisdiction_code
                               = city.jurisdiction_code) */
       GROUP BY jurisdiction_code, jurisdiction_name,
                 decode(non_resident_flag,'NR','WK','R','RS',non_resident_flag);

--Bug3369315 ---Changed the cursor query for c_school_balances and forced the index pay_action_information_n2
             -- to remove FTS from pay_action_information on HRPPG2.

   CURSOR c_school_balances(cp_action_number in number,
                            cp_state_id      in varchar2,
                            cp_school_id     in varchar2) IS
      select /*+ index(school.pai pay_action_information_n2) */ jurisdiction_code,
             jurisdiction_name,
             sum(school_gross),
             sum(school_reduced_subject),
             sum(School_Withheld)
       from  pay_us_school_action_info_v school
      where  school.action_number = cp_action_number
         and school.jurisdiction_code like
             cp_state_id||'-'||nvl(cp_school_id,'%')
/*         and cp_action_number not in (select school2.action_number
                           from pay_us_school_action_info_v school2
                          where (school2.school_gross = 0
                                 or school2. school_gross is null)
                            and (school2.school_reduced_subject = 0
                                 or school2.school_reduced_subject is null)
                            and (school2.School_Withheld = 0
                                 or school2.School_Withheld is null)
                            and school2.jurisdiction_code
                                 = school.jurisdiction_code)*/
      GROUP BY jurisdiction_code, jurisdiction_name;

    /*************************************************************
    ** Local Variables
    *************************************************************/

    ln_person_id                   NUMBER;
    ln_assignment_id               NUMBER;
    ln_prev_person                 NUMBER;
    ln_prev_gre                    NUMBER;
    lv_found                       VARCHAR2(1);
    ln_next_tab                    NUMBER;
    lv_county_id                   VARCHAR2(4);
    lv_city_id                     VARCHAR2(4);

    ld_beginning_date              DATE;
    ld_end_date                    DATE;
    ld_effective_date              DATE;

    ln_action_number               NUMBER;
    ln_tax_unit_id                 NUMBER;
    lv_last_name                   per_all_people_f.last_name%type;
    lv_first_name                  per_all_people_f.first_name%type;
    lv_middle_name                 per_all_people_f.middle_names%type;
    lv_employee_number             per_all_people_f.employee_number%type;
    lv_assignment_number           per_all_assignments_f.assignment_number%type;
    lv_national_identifier         per_all_people_f.national_identifier%type;
    lv_address_line                pay_us_employee_action_info_v.address_line%type;

    lv_town_or_city                varchar2(150);
    lv_county                      varchar2(150);
    lv_state                       varchar2(150);
    lv_postal_code                 varchar2(150);
    lv_country                     varchar2(150);
    lv_gre_name                    hr_all_organization_units.name%type;
    lv_fed_ein                     hr_organization_information.org_information2%type;
    lv_org_name                    hr_all_organization_units.name%type;
    lv_location_code               hr_locations_all.location_code%type;
    lv_action_type                 varchar2(150);

    ln_fit_gross                   number;
    ln_fit_withheld                number;
    ln_fit_reduced_subject         number;
    ln_futa_liability              number;
    ln_futa_taxable                number;
    ln_ss_ee_withheld              number;
    ln_ss_ee_taxable               number;
    ln_ss_er_liability             number;
    ln_ss_er_taxable               number;
    ln_medicare_ee_withheld        number;
    ln_medicare_ee_taxable         number;
    ln_medicare_er_taxable         number;
    ln_medicare_er_liability       number;
    ln_eic_advance                 number;

    ln_fit_gross_sum               number := 0 ;
    ln_fit_withheld_sum            number := 0 ;
    ln_fit_reduced_subject_sum     number := 0 ;
    ln_futa_liability_sum          number := 0 ;
    ln_futa_taxable_sum            number := 0 ;
    ln_ss_ee_withheld_sum          number := 0 ;
    ln_ss_ee_taxable_sum           number := 0 ;
    ln_ss_er_liability_sum         number := 0 ;
    ln_ss_er_taxable_sum           number := 0 ;
    ln_medicare_ee_withheld_sum    number := 0 ;
    ln_medicare_ee_taxable_sum     number := 0 ;
    ln_medicare_er_taxable_sum     number := 0 ;
    ln_medicare_er_liability_sum   number := 0 ;

    lv_jurisdiction                varchar2(15);
    lv_jurisdiction_name           varchar2(150);

    lv_state_id                    varchar2(150);
    lv_state_ein                   varchar2(150);
    ln_sit_gross                   number;
    ln_sit_reduced_subject         number;
    ln_sit_withheld                number;
    ln_sui_ee_taxable              number;
    ln_sui_ee_withheld             number;
    ln_sui_er_taxable              number;
    ln_sui_er_liability            number;
    ln_sdi_ee_taxable              number;
    ln_sdi_ee_withheld             number;
    ln_sdi_er_taxable              number;
    ln_sdi_er_liability            number;
    ln_workers_comp_withheld       number;
    ln_workers_comp2_withheld      number;
    ln_sdi1_ee_withheld             number;

    ln_county_gross                number;
    ln_county_reduced_subject      number;
    ln_county_withheld             number;
    ln_head_tax_withheld           number;
    lv_non_resident_flag           varchar2(5);

    ln_city_gross                  number;
    ln_city_reduced_subject        number;
    ln_city_withheld               number;
    ln_city_gross_sum              number;
    ln_city_reduced_subject_sum    number;
    ln_city_withheld_sum           number;

    ln_school_withheld             number;
    ln_school_gross                number;
    ln_school_reduced_subject      number;

    lv_header_label                VARCHAR2(32000);
    lv_emp_detail_header           VARCHAR2(32000);
    lv_emp_sum_header              VARCHAR2(32000);
    lv_fed_header                  VARCHAR2(32000);
    lv_state_header                VARCHAR2(32000);
    lv_county_header               VARCHAR2(32000);
    lv_city_header                 VARCHAR2(32000);
    lv_school_header               VARCHAR2(32000);

    lv_employee_data               varchar2(32000);
    lv_federal_data                varchar2(32000);
    lv_state_data                  varchar2(32000);
    lv_county_data                 varchar2(32000);
    lv_city_data                   varchar2(32000);
    lv_school_data                 varchar2(32000);
    lv_data_row                    varchar2(32000) := '';
    lv_prev_emp_data_row           varchar2(32000) := '';
    lv_emp_data_row                varchar2(32000) := '';

    lv_federal_data_sum            varchar2(32000);
    lv_state_data_sum              varchar2(32000);
    lv_county_data_sum             varchar2(32000);
    lv_city_data_sum               varchar2(32000);
    lv_school_data_sum             varchar2(32000);

  type federal_rec IS RECORD
       (tax_unit_id           number,
        gre_name              varchar2(240),
        fit_gross             number,
        fit_reduced_subject   number,
        fit_withheld          number,
        futa_taxable          number,
        futa_liability        number,
        ss_ee_taxable         number,
        ss_ee_withheld        number,
        ss_er_taxable         number,
        ss_er_liability       number,
        medicare_ee_taxable   number,
        medicare_ee_withheld  number,
        medicare_er_taxable   number,
        medicare_er_liability number,
        eic_advance           number);

  type state_rec IS RECORD
       (tax_unit_id           number,
        gre_name              varchar2(240),
        state_ein             varchar2(150),
        jurisdiction_code     varchar2(150),
        jurisdiction_name     varchar2(150),
        sit_gross             number,
        sit_reduced_subject   number,
        sit_withheld          number,
        sui_ee_taxable        number,
        sui_ee_withheld       number,
        sui_er_taxable        number,
        sui_er_liability      number,
        sdi_ee_taxable        number,
        sdi_ee_withheld       number,
        sdi_er_taxable        number,
        sdi_er_liability      number,
        workers_comp_withheld number,
        workers_comp2_withheld number,
	    sdi1_ee_withheld      number );

  type county_rec IS RECORD
       (tax_unit_id           number,
        gre_name              varchar2(240),
        jurisdiction_code     varchar2(150),
        jurisdiction_name     varchar2(150),
        county_gross                number,
        county_reduced_subject      number,
        county_withheld             number,
        county_head_tax_withheld    number );

  type city_rec IS RECORD
       (tax_unit_id           number,
        gre_name              varchar2(240),
        jurisdiction_code     varchar2(150),
        jurisdiction_name     varchar2(150),
        city_gross            number,
        city_reduced_subject  number,
        city_withheld         number,
        head_tax_withheld     number);

  type school_rec IS RECORD
       (tax_unit_id           number,
        gre_name              varchar2(240),
        jurisdiction_code     varchar2(150),
        jurisdiction_name     varchar2(150),
        school_gross          number,
        school_reduced_subject number,
        school_withheld       number);

  type federal_tab is table of federal_rec index by binary_integer;
  type state_tab is table of state_rec index by binary_integer;
  type county_tab is table of county_rec index by binary_integer;
  type city_tab is table of city_rec index by binary_integer;
  type school_tab is table of school_rec index by binary_integer;

  federal_bal  federal_tab;
  state_bal  state_tab;
  county_bal county_tab;
  city_bal   city_tab;
  school_bal school_tab;

  BEGIN
   hr_utility.set_location(gv_package_name || '.archiver_extract', 10);
   ld_beginning_date := fnd_date.canonical_to_date(p_beginning_date);
   ld_end_date := fnd_date.canonical_to_date(p_end_date);

   /*  Create Headers for each column */

   emp_detail_static_header( p_output_file_type ,lv_emp_detail_header);
   emp_sum_static_header( p_output_file_type ,lv_emp_sum_header);
   fed_static_header(p_output_file_type, lv_fed_header);
   state_static_header(p_output_file_type, lv_state_header);
   county_static_header(p_output_file_type, lv_county_header);
   city_static_header(p_output_file_type, lv_city_header);
   school_static_header(p_output_file_type, lv_school_header);

   hr_utility.trace('----------Done with Static Header Lables ------------');

   IF p_detail_level = '01' THEN
     if p_jurisdiction_level = '01' -- Federal
     then
       lv_header_label := lv_emp_detail_header||lv_fed_header;
     elsif p_jurisdiction_level = '02' -- State
     then
       lv_header_label := lv_emp_detail_header||lv_state_header;
     elsif p_jurisdiction_level = '03' -- County
     then
       lv_header_label := lv_emp_detail_header||lv_county_header;
     elsif p_jurisdiction_level = '04' -- City
     then
       lv_header_label := lv_emp_detail_header||lv_city_header;
     elsif p_jurisdiction_level = '05' -- school
     then
       lv_header_label := lv_emp_detail_header||lv_school_header;
     end if;
  ELSIF p_detail_level = '02' THEN
     if p_jurisdiction_level = '01' -- Federal
     then
       lv_header_label := lv_emp_sum_header||lv_fed_header;
     elsif p_jurisdiction_level = '02' -- State
     then
       lv_header_label := lv_emp_sum_header||lv_state_header;
     elsif p_jurisdiction_level = '03' -- County
     then
       lv_header_label := lv_emp_sum_header||lv_county_header;
     elsif p_jurisdiction_level = '04' -- City
     then
       lv_header_label := lv_emp_sum_header||lv_city_header;
     elsif p_jurisdiction_level = '05' -- school
     then
       lv_header_label := lv_emp_sum_header||lv_school_header;
     end if;
  END IF;

   hr_utility.set_location(gv_package_name || '.archiver_extract', 70);

   /* write the title of the report based on the output file type */

   fnd_file.put_line(fnd_file.output,
                     title_string( gv_title
                                  ,p_output_file_type));

   hr_utility.set_location(gv_package_name || '.archiver_extract', 90);
   /****************************************************************
   ** Print the Header Information. If the format is HTML then open
   ** the body and table before printing the header info, otherwise
   ** just print the header information.
   ****************************************************************/
   hr_utility.trace('Output File Type = '||p_output_file_type);

   if p_output_file_type ='HTML' then
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '<body>');
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '<table border=1>');
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '<tr>');
   end if;

   fnd_file.put_line(fnd_file.output, lv_header_label);

   if p_output_file_type ='HTML' then
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '</tr>');
   end if;

   hr_utility.set_location(gv_package_name || '.archiver_extract', 100);

   /*****************************************************
   ** Start of the Data Section of the Report
   *****************************************************/
   hr_utility.trace('Assignment Set ID = ' || p_assignment_set_id);
   hr_utility.trace('Beginning Date = '||ld_beginning_date);
   hr_utility.trace('Ending Date = '||ld_end_date);
   hr_utility.trace('Payroll id = '||p_payroll_id);
   hr_utility.trace('Consolidation Set id = '||p_consolidation_set_id);
   hr_utility.trace('Organization id = '||p_organization_id);
   hr_utility.trace('Tax Unit Id = '||p_tax_unit_id);
   hr_utility.trace('Location id = '||p_location_id);
   hr_utility.trace('Business Group id = '||p_business_group_id);
   hr_utility.trace('State Id = '||p_state_id);
   hr_utility.trace('County Id = '||p_county_id);
   hr_utility.trace('City Id = '||p_city_id);
   hr_utility.trace('School Id = '||p_school_id);

   ln_prev_person := -1;
   ln_prev_gre := -1;
/*
   open c_employee_count( ld_beginning_date
                   ,ld_end_date
                   ,p_payroll_id
                   ,p_consolidation_set_id
                   ,p_organization_id
                   ,p_tax_unit_id
                   ,p_location_id
                   ,p_business_group_id);

   LOOP
     fetch c_employee_count into ln_person_id, lv_last_name, ln_action_number;
     hr_utility.trace('ln_person_id = '||ln_person_id);
     hr_utility.trace('lv_last_name = '||lv_last_name);
     hr_utility.trace('ln_action_number = '||ln_action_number);
     exit when c_employee_count%NOTFOUND;
   END LOOP;
   close c_employee_count;
*/

   open c_employee( ld_beginning_date
                   ,ld_end_date
                   ,p_payroll_id
                   ,p_consolidation_set_id
                   ,p_organization_id
                   ,p_tax_unit_id
                   ,p_location_id
                   ,p_business_group_id);

   LOOP
    fetch c_employee into ln_action_number,
                          lv_last_name,
                          lv_first_name,
                          lv_middle_name,
                          lv_employee_number,
                          lv_assignment_number,
                          ln_assignment_id,
                          lv_national_identifier,
                          lv_address_line,
                          lv_town_or_city,
                          lv_county,
                          lv_state,
                          lv_postal_code,
                          lv_country,
                          ln_tax_unit_id,
                          lv_gre_name,
                          lv_fed_ein,
                          lv_org_name,
                          lv_location_code,
                          lv_action_type,
                          ln_person_id,
                          ld_effective_date;
    EXIT WHEN c_employee%NOTFOUND;
    hr_utility.trace('-----------------------------------------------');
    hr_utility.trace('C_EMPLOYEE CURSOR');
    hr_utility.trace('ln_action_number = '||ln_action_number);
    hr_utility.trace('lv_last_name = '||lv_last_name);
    hr_utility.trace('ln_person_id = '||ln_person_id);
    hr_utility.trace('-----------------------------------------------');

    if ln_prev_person = -1 then
       ln_prev_person := ln_person_id;
    end if;
    if ln_prev_gre = -1 then
       ln_prev_gre := ln_tax_unit_id;
    end if;

    if c_employee%notfound then
         hr_utility.trace('EMPLOYEE NOT FOUND');
         hr_utility.set_location(gv_package_name || '.archiver_extract', 105);
         exit;
    else
         hr_utility.trace('EMPLOYEE FOUND');
    --     hr_utility.trace('Employee action_number = '||ln_action_number);
    --     hr_utility.trace('Employee Last Name = '||lv_last_name);
    --     hr_utility.trace('Employee First Name = '||lv_first_name);
    end if;

      /*----------------------------------------------------------
      -- If Assignment Set is used, pick up only those employee
      -- assignments which are part of the Assignment Set
      -----------------------------------------------------------*/
    hr_utility.set_location(gv_package_name || '.archiver_extract', 110);

    if hr_assignment_set.assignment_in_set(p_assignment_set_id
                                            ,ln_assignment_id)    = 'Y' then

       hr_utility.set_location(gv_package_name || '.archiver_extract', 120);

       /************************************/
       /***      FEDERAL balances        ***/
       /************************************/

       IF p_jurisdiction_level = '01' THEN
         open c_federal_balances( ln_action_number );
         LOOP

           fetch c_federal_balances into ln_action_number,
                                         ln_fit_gross,
                                         ln_fit_reduced_subject,
                                         ln_fit_withheld,
                                         ln_futa_taxable,
                                         ln_futa_liability,
                                         ln_ss_ee_taxable,
                                         ln_ss_ee_withheld,
                                         ln_ss_er_taxable,
                                         ln_ss_er_liability,
                                         ln_medicare_ee_taxable,
                                         ln_medicare_ee_withheld,
                                         ln_medicare_er_taxable,
                                         ln_medicare_er_liability,
                                         ln_eic_advance;
           EXIT WHEN c_federal_balances%NOTFOUND;

           hr_utility.trace('Fetched FEDERAL balance ---------------');
           hr_utility.trace('Detail Level in FED = '||p_detail_level);
           hr_utility.trace('ln_action_number = '||ln_action_number);
           hr_utility.trace('ln_fit_gross = '||ln_fit_gross);
           hr_utility.trace('ln_fit_withheld = '||ln_fit_withheld);

           IF p_detail_level = '01' THEN -- By Run
             emp_static_data(
                          lv_last_name,
                          lv_first_name,
                          lv_middle_name,
                          lv_employee_number,
                          lv_assignment_number,
                          lv_national_identifier,
                          lv_address_line,
                          lv_town_or_city,
                          lv_county,
                          lv_state,
                          lv_postal_code,
                          lv_country,
                          lv_fed_ein,
                          lv_org_name,
                          lv_location_code,
                          lv_action_type,
                          ld_effective_date,
                          p_output_file_type,
                          lv_employee_data);

             lv_data_row := lv_employee_data;

              fed_static_data( lv_gre_name,
                               nvl(ln_fit_gross,0),
                               nvl(ln_fit_reduced_subject,0),
                               nvl(ln_fit_withheld,0),
                               nvl(ln_futa_taxable,0),
                               nvl(ln_futa_liability,0),
                               nvl(ln_ss_ee_taxable,0),
                               nvl(ln_ss_ee_withheld,0),
                               nvl(ln_ss_er_taxable,0),
                               nvl(ln_ss_er_liability,0),
                               nvl(ln_medicare_ee_taxable,0),
                               nvl(ln_medicare_ee_withheld,0),
                               nvl(ln_medicare_er_taxable,0),
                               nvl(ln_medicare_er_liability,0),
                               nvl(ln_eic_advance,0),
                               p_output_file_type,
                               lv_federal_data);
              lv_data_row := lv_data_row||lv_federal_data;
              --hr_utility.trace('FED static data = '||lv_federal_data);
              --hr_utility.trace('Data Row = '||lv_data_row);

              if p_output_file_type = 'HTML' then
                lv_data_row := '<tr>'||lv_data_row||'</tr>';
              end if;

              FND_FILE.PUT_LINE(FND_FILE.OUTPUT,lv_data_row);
              lv_data_row := lv_employee_data;
            END IF;

            /*******   Federal Summary Level     ********/

            IF p_detail_level = '02' THEN
              hr_utility.trace('------------------------------------------');
              hr_utility.trace('Federal by summary.......................');
              hr_utility.trace('ln_prev_person = '||ln_prev_person);
              hr_utility.trace('ln_person_id = '||ln_person_id);

            IF ln_prev_person = ln_person_id then
                 emp_sum_static_data( lv_last_name,
                                  lv_first_name,
                                  lv_middle_name,
                                  lv_employee_number,
                                  lv_national_identifier,
                                  lv_fed_ein,
                                  p_output_file_type,
                                  lv_employee_data);

                 lv_data_row := lv_employee_data;

                 lv_found := 'N';

                 hr_utility.trace('ln_fit_gross = '||ln_fit_gross);
                 hr_utility.trace('ln_fit_gross_sum BEFORE adding = '||
                                   ln_fit_gross_sum);
                 hr_utility.trace('ln_prev_gre = '||ln_prev_gre);
                 hr_utility.trace('ln_tax_unit_id = '||ln_tax_unit_id);

                 IF federal_bal.count > 0 THEN
                   FOR k in federal_bal.first..federal_bal.last LOOP
                     IF federal_bal(k).tax_unit_id = ln_tax_unit_id THEN
                       lv_found := 'Y';
                       federal_bal(k).tax_unit_id := ln_tax_unit_id;
                       federal_bal(k).gre_name := lv_gre_name;
                       federal_bal(k).fit_gross := federal_bal(k).fit_gross +
                                                   nvl(ln_fit_gross,0);
                       federal_bal(k).fit_reduced_subject := nvl(ln_fit_reduced_subject,0)+
                                            federal_bal(k).fit_reduced_subject;
                       federal_bal(k).fit_withheld := nvl(ln_fit_withheld,0) +
                                                      federal_bal(k).fit_withheld;
                       federal_bal(k).futa_taxable := nvl(ln_futa_taxable,0) +
                                            federal_bal(k).futa_taxable;
                       federal_bal(k).futa_liability := nvl(ln_futa_liability,0) +
                                            federal_bal(k).futa_liability;
                       federal_bal(k).ss_ee_taxable := nvl(ln_ss_ee_taxable,0) +
                                            federal_bal(k).ss_ee_taxable;
                       federal_bal(k).ss_ee_withheld := nvl(ln_ss_ee_withheld,0) +
                                            federal_bal(k).ss_ee_withheld;
                       federal_bal(k).ss_er_taxable := nvl(ln_ss_er_taxable,0) +
                                            federal_bal(k).ss_er_taxable;
                       federal_bal(k).ss_er_liability := nvl(ln_ss_er_liability,0) +
                                            federal_bal(k).ss_er_liability;
                       federal_bal(k).medicare_ee_taxable := nvl(ln_medicare_ee_taxable,0) +
                                            federal_bal(k).medicare_ee_taxable;
                       federal_bal(k).medicare_ee_withheld :=
                                            nvl(ln_medicare_ee_withheld,0) +
                                            federal_bal(k).medicare_ee_withheld;
                       federal_bal(k).medicare_er_taxable := nvl(ln_medicare_er_taxable,0) +
                                            federal_bal(k).medicare_er_taxable;
                       federal_bal(k).medicare_er_liability :=
                                            nvl(ln_medicare_er_liability,0) +
                                            federal_bal(k).medicare_er_liability;
                       federal_bal(k).eic_advance := nvl(ln_eic_advance,0) +
                                            federal_bal(k).eic_advance;
                     END IF;
                   END LOOP;
                /* sackumar(Bug 4559897) for multiple GREs */
                    if lv_found = 'N' then
                      ln_next_tab := federal_bal.count + 1;
                      federal_bal(ln_next_tab).tax_unit_id := ln_tax_unit_id;
                      federal_bal(ln_next_tab).gre_name := lv_gre_name;
                      federal_bal(ln_next_tab).fit_gross := nvl(ln_fit_gross,0);
                      federal_bal(ln_next_tab).fit_reduced_subject := nvl(ln_fit_reduced_subject,0);
                      federal_bal(ln_next_tab).fit_withheld := nvl(ln_fit_withheld,0) ;
                      federal_bal(ln_next_tab).futa_taxable := nvl(ln_futa_taxable,0) ;
                      federal_bal(ln_next_tab).futa_liability := nvl(ln_futa_liability,0) ;
                      federal_bal(ln_next_tab).ss_ee_taxable := nvl(ln_ss_ee_taxable,0) ;
                      federal_bal(ln_next_tab).ss_ee_withheld := nvl(ln_ss_ee_withheld,0) ;
                      federal_bal(ln_next_tab).ss_er_taxable := nvl(ln_ss_er_taxable,0) ;
                      federal_bal(ln_next_tab).ss_er_liability := nvl(ln_ss_er_liability,0) ;
                      federal_bal(ln_next_tab).medicare_ee_taxable := nvl(ln_medicare_ee_taxable,0) ;
                      federal_bal(ln_next_tab).medicare_ee_withheld := nvl(ln_medicare_ee_withheld,0);
                      federal_bal(ln_next_tab).medicare_er_taxable := nvl(ln_medicare_er_taxable,0) ;
                      federal_bal(ln_next_tab).medicare_er_liability := nvl(ln_medicare_er_liability,0) ;
                      federal_bal(ln_next_tab).eic_advance := nvl(ln_eic_advance,0);
                    end if;
                ELSE /* Federal_bal.count = 0, first fetch */
                  federal_bal(1).tax_unit_id := ln_tax_unit_id;
                  federal_bal(1).gre_name := lv_gre_name;
                  federal_bal(1).fit_gross := nvl(ln_fit_gross,0);
                  federal_bal(1).fit_reduced_subject := nvl(ln_fit_reduced_subject,0);
                  federal_bal(1).fit_withheld := nvl(ln_fit_withheld,0) ;
                  federal_bal(1).futa_taxable := nvl(ln_futa_taxable,0) ;
                  federal_bal(1).futa_liability := nvl(ln_futa_liability,0) ;
                  federal_bal(1).ss_ee_taxable := nvl(ln_ss_ee_taxable,0) ;
                  federal_bal(1).ss_ee_withheld := nvl(ln_ss_ee_withheld,0) ;
                  federal_bal(1).ss_er_taxable := nvl(ln_ss_er_taxable,0) ;
                  federal_bal(1).ss_er_liability := nvl(ln_ss_er_liability,0) ;
                  federal_bal(1).medicare_ee_taxable := nvl(ln_medicare_ee_taxable,0) ;
                  federal_bal(1).medicare_ee_withheld := nvl(ln_medicare_ee_withheld,0);
                  federal_bal(1).medicare_er_taxable := nvl(ln_medicare_er_taxable,0) ;
                  federal_bal(1).medicare_er_liability := nvl(ln_medicare_er_liability,0) ;
                  federal_bal(1).eic_advance := nvl(ln_eic_advance,0);
                END IF; /* federal_bal.count check */

              ELSE /* New person fetched */
                 hr_utility.trace('Inside FED ELSE...........');
                 hr_utility.trace('New Person fetched ..........');

                 lv_prev_emp_data_row := lv_data_row;
                 IF federal_bal.count>0 THEN
                   FOR k in federal_bal.first..federal_bal.last LOOP

                      fed_static_data(federal_bal(k).gre_name,
                                      federal_bal(k).fit_gross,
                                      federal_bal(k).fit_reduced_subject,
                                      federal_bal(k).fit_withheld,
                                      federal_bal(k).futa_taxable,
                                      federal_bal(k).futa_liability,
                                      federal_bal(k).ss_ee_taxable,
                                      federal_bal(k).ss_ee_withheld,
                                      federal_bal(k).ss_er_taxable,
                                      federal_bal(k).ss_er_liability,
                                      federal_bal(k).medicare_ee_taxable,
                                      federal_bal(k).medicare_ee_withheld,
                                      federal_bal(k).medicare_er_taxable,
                                      federal_bal(k).medicare_er_liability,
                                      federal_bal(k).eic_advance,
                                      p_output_file_type,
                                      lv_federal_data_sum);

                      lv_data_row := lv_prev_emp_data_row||lv_federal_data_sum;

                      if p_output_file_type = 'HTML' then
                        lv_data_row := '<tr>'||lv_data_row||'</tr>';
                      end if;
                      FND_FILE.PUT_LINE(FND_FILE.OUTPUT,lv_data_row);
                   END LOOP;
                 END IF; -- federal_bal.count
                 /* Now Build employee static header with the new fetched person */
                  emp_sum_static_data( lv_last_name,
                                   lv_first_name,
                                   lv_middle_name,
                                   lv_employee_number,
                                   lv_national_identifier,
                                   lv_fed_ein,
                                   p_output_file_type,
                                   lv_employee_data);
                   lv_data_row := lv_employee_data;
                   ln_prev_person := ln_person_id;

                  /******* rest sum to currently fetched person *****/

                 hr_utility.trace('resetting summary for Federal ...........');
                 IF federal_bal.count > 0 THEN
                   FOR k in federal_bal.first..federal_bal.last LOOP
                     federal_bal(k).tax_unit_id := -1;
                     federal_bal(k).gre_name := '';
                     federal_bal(k).fit_gross := 0;
                     federal_bal(k).fit_reduced_subject := 0;
                     federal_bal(k).fit_withheld := 0;
                     federal_bal(k).futa_taxable := 0;
                     federal_bal(k).futa_liability := 0;
                     federal_bal(k).ss_ee_taxable := 0;
                     federal_bal(k).ss_ee_withheld := 0;
                     federal_bal(k).ss_er_taxable := 0;
                     federal_bal(k).ss_er_liability := 0;
                     federal_bal(k).medicare_ee_taxable := 0;
                     federal_bal(k).medicare_ee_withheld := 0;
                     federal_bal(k).medicare_er_taxable := 0;
                     federal_bal(k).medicare_er_liability := 0;
                     federal_bal(k).eic_advance := 0;
                   END LOOP;
                 END IF;
                 federal_bal.delete;

                  federal_bal(1).tax_unit_id := ln_tax_unit_id;
                  federal_bal(1).gre_name := lv_gre_name;
                  federal_bal(1).fit_gross := nvl(ln_fit_gross,0);
                  federal_bal(1).fit_reduced_subject := nvl(ln_fit_reduced_subject,0);
                  federal_bal(1).fit_withheld := nvl(ln_fit_withheld,0) ;
                  federal_bal(1).futa_taxable := nvl(ln_futa_taxable,0) ;
                  federal_bal(1).futa_liability := nvl(ln_futa_liability,0) ;
                  federal_bal(1).ss_ee_taxable := nvl(ln_ss_ee_taxable,0) ;
                  federal_bal(1).ss_ee_withheld := nvl(ln_ss_ee_withheld,0) ;
                  federal_bal(1).ss_er_taxable := nvl(ln_ss_er_taxable,0) ;
                  federal_bal(1).ss_er_liability := nvl(ln_ss_er_liability,0) ;
                  federal_bal(1).medicare_ee_taxable := nvl(ln_medicare_ee_taxable,0) ;
                  federal_bal(1).medicare_ee_withheld := nvl(ln_medicare_ee_withheld,0);
                  federal_bal(1).medicare_er_taxable := nvl(ln_medicare_er_taxable,0) ;
                  federal_bal(1).medicare_er_liability := nvl(ln_medicare_er_liability,0) ;
                  federal_bal(1).eic_advance := nvl(ln_eic_advance,0);

               END IF; /* Person Check */
             END IF; /* Detail Level check */
           END LOOP; -- Federal balance loop
             CLOSE c_federal_balances;
          END IF; -- jurisdiction level check



       /****************************************/
       /***          STATE balances          ***/
       /****************************************/

       IF p_jurisdiction_level = '02' THEN
        hr_utility.trace('-------------------------------------');
        hr_utility.trace('.......... In STATE..................');
        hr_utility.trace('ln_tax_unit_id = '||ln_tax_unit_id);
        hr_utility.trace('p_state_id = '||p_state_id);
        hr_utility.trace('ln_action_number = '||ln_action_number);
        hr_utility.trace('-------------------------------------');

         open c_state_balances(ln_action_number,
                               p_state_id);
          hr_utility.trace('State first cursor OPEN ');

         LOOP

         hr_utility.trace('Fetching STATE balance ...............');

          fetch c_state_balances into lv_jurisdiction,
                                  lv_jurisdiction_name,
                                  ln_sit_gross,
                                  ln_sit_reduced_subject,
                                  ln_sit_withheld,
                                  ln_sui_ee_taxable,
                                  ln_sui_ee_withheld,
                                  ln_sui_er_taxable,
                                  ln_sui_er_liability,
                                  ln_sdi_ee_taxable,
                                  ln_sdi_ee_withheld,
                                  ln_sdi_er_taxable,
                                  ln_sdi_er_liability,
                                  ln_workers_comp_withheld,
                                  ln_workers_comp2_withheld,
								  ln_sdi1_ee_withheld;

          EXIT WHEN c_state_balances%NOTFOUND;

          lv_state_ein := f_state_ein(ln_tax_unit_id,
                                      substr(lv_jurisdiction,1,2));

          hr_utility.trace('----------------------------------------');
          hr_utility.trace('Fetched STATE record...............');
          hr_utility.trace('ln_sit_gross = '||ln_sit_gross);
          hr_utility.trace('ln_sit_withheld = '||ln_sit_withheld);
          hr_utility.trace('----------------------------------------');

          /******* State Balance By Run *****/

          IF p_detail_level = '01' THEN

          hr_utility.trace('----------------------------------------');
          hr_utility.trace('State by run out put....................');
          hr_utility.trace('ln_action_number = '||ln_action_number);
          hr_utility.trace('----------------------------------------');

             emp_static_data(
                          lv_last_name,
                          lv_first_name,
                          lv_middle_name,
                          lv_employee_number,
                          lv_assignment_number,
                          lv_national_identifier,
                          lv_address_line,
                          lv_town_or_city,
                          lv_county,
                          lv_state,
                          lv_postal_code,
                          lv_country,
                          lv_fed_ein,
                          lv_org_name,
                          lv_location_code,
                          lv_action_type,
                          ld_effective_date,
                          p_output_file_type,
                          lv_employee_data);

             lv_data_row := lv_employee_data;

             state_static_data(lv_gre_name,
                               lv_state_ein,
                               lv_jurisdiction,
                               lv_jurisdiction_name,
                               nvl(ln_sit_gross,0),
                               nvl(ln_sit_reduced_subject,0),
                               nvl(ln_sit_withheld,0),
                               nvl(ln_sui_ee_taxable,0),
                               nvl(ln_sui_ee_withheld,0),
                               nvl(ln_sui_er_taxable,0),
                               nvl(ln_sui_er_liability,0),
                               nvl(ln_sdi_ee_taxable,0),
                               nvl(ln_sdi_ee_withheld,0),
                               nvl(ln_sdi_er_taxable,0),
                               nvl(ln_sdi_er_liability,0),
                               nvl(ln_workers_comp_withheld,0),
                               nvl(ln_workers_comp2_withheld,0),
                               nvl(ln_sdi1_ee_withheld,0),
                               p_output_file_type,
                               lv_state_data);
             lv_data_row := lv_data_row||lv_state_data;

             if p_output_file_type = 'HTML' then
                lv_data_row := '<tr>'||lv_data_row||'</tr>';
             end if;
             FND_FILE.PUT_LINE(FND_FILE.OUTPUT,lv_data_row);
           END IF;


           /********* State Balance by Summary(by jurisdiction level) *****/

           hr_utility.trace('---------State by Summary --------------');
           hr_utility.trace('ln_prev_person = '||ln_prev_person);
           hr_utility.trace('ln_person_id = '||ln_person_id);
           hr_utility.trace('----------------------------------------');

           IF p_detail_level = '02' then

            IF ln_prev_person = ln_person_id Then
                   emp_sum_static_data( lv_last_name,
                                    lv_first_name,
                                    lv_middle_name,
                                    lv_employee_number,
                                    lv_national_identifier,
                                    lv_fed_ein,
                                    p_output_file_type,
                                    lv_employee_data);
                     lv_data_row := lv_employee_data;

                IF p_state_id is null THEN
                   lv_state_id := substr(lv_jurisdiction,1,2);
                ELSE
                   lv_state_id := p_state_id;
                END IF;

                hr_utility.trace('lv_state_id = '||lv_state_id);

                lv_found := 'N';
                hr_utility.trace('state_bal.count = '||state_bal.count);
                hr_utility.trace('lv_jurisdiction = '||lv_jurisdiction);
                IF state_bal.count > 0 THEN
                   FOR k in state_bal.first..state_bal.last LOOP
                      IF (state_bal(k).jurisdiction_code = lv_jurisdiction
                          AND
                          state_bal(k).tax_unit_id = ln_tax_unit_id) THEN
                         lv_found := 'Y';
                         state_bal(k).tax_unit_id := ln_tax_unit_id;
                         state_bal(k).gre_name := lv_gre_name;
                         state_bal(k).state_ein := lv_state_ein;
                         state_bal(k).sit_gross := nvl(ln_sit_gross,0) +
                                         state_bal(k).sit_gross;
                         state_bal(k).sit_reduced_subject :=
                                         nvl(ln_sit_reduced_subject,0) +
                                         state_bal(k).sit_reduced_subject;
                         state_bal(k).sit_withheld := nvl(ln_sit_withheld,0) +
                                            state_bal(k).sit_withheld;
                         state_bal(k).sui_ee_taxable := nvl(ln_sui_ee_taxable,0) +
                                          state_bal(k).sui_ee_taxable;
                         state_bal(k).sui_ee_withheld := nvl(ln_sui_ee_withheld,0) +
                                        state_bal(k).sui_ee_withheld ;
                         state_bal(k).sui_er_taxable := nvl(ln_sui_er_taxable,0) +
                                         state_bal(k).sui_er_taxable ;
                         state_bal(k).sui_er_liability := nvl(ln_sui_er_liability,0) +
                                         state_bal(k).sui_er_liability;
                         state_bal(k).sdi_ee_taxable := nvl(ln_sdi_ee_taxable,0) +
                                         state_bal(k).sdi_ee_taxable;
                         state_bal(k).sdi_ee_withheld := nvl(ln_sdi_ee_withheld,0) +
                                         state_bal(k).sdi_ee_withheld;
                         state_bal(k).sdi_er_taxable := nvl(ln_sdi_er_taxable,0) +
                                         state_bal(k).sdi_er_taxable;
                         state_bal(k).sdi_er_liability := nvl(ln_sdi_er_liability,0) +
                                      state_bal(k).sdi_er_liability ;
                         state_bal(k).workers_comp_withheld :=
                                          nvl(ln_workers_comp_withheld,0) +
                                state_bal(k).workers_comp_withheld ;
                         state_bal(k).workers_comp2_withheld:=
                                          nvl(ln_workers_comp2_withheld ,0)+
                                          state_bal(k).workers_comp2_withheld;
                         state_bal(k).sdi1_ee_withheld := nvl(ln_sdi1_ee_withheld,0) +
                                        state_bal(k).sdi1_ee_withheld ;

                      END IF;
                   END LOOP;
                  hr_utility.trace('end of Loop');
                  hr_utility.trace('lv_found := '||lv_found);
                   IF lv_found = 'N' THEN
                      ln_next_tab := state_bal.count + 1;
                      state_bal(ln_next_tab).tax_unit_id := ln_tax_unit_id;
                      state_bal(ln_next_tab).gre_name := lv_gre_name;
                      state_bal(ln_next_tab).state_ein := lv_state_ein;
                      state_bal(ln_next_tab).jurisdiction_code :=
                                                 lv_jurisdiction;
                      state_bal(ln_next_tab).jurisdiction_name :=
                                                 lv_jurisdiction_name;
                      state_bal(ln_next_tab).sit_gross := nvl(ln_sit_gross,0) ;
                      state_bal(ln_next_tab).sit_reduced_subject :=
                                                 nvl(ln_sit_reduced_subject,0) ;
                      state_bal(ln_next_tab).sit_withheld := nvl(ln_sit_withheld,0) ;
                      state_bal(ln_next_tab).sui_ee_taxable :=
                                                 nvl(ln_sui_ee_taxable,0) ;
                      state_bal(ln_next_tab).sui_ee_withheld :=
                                                 nvl(ln_sui_ee_withheld,0) ;
                      state_bal(ln_next_tab).sui_er_taxable :=
                                                 nvl(ln_sui_er_taxable,0) ;
                      state_bal(ln_next_tab).sui_er_liability :=
                                                 nvl(ln_sui_er_liability,0) ;
                      state_bal(ln_next_tab).sdi_ee_taxable :=
                                                 nvl(ln_sdi_ee_taxable,0) ;
                      state_bal(ln_next_tab).sdi_ee_withheld :=
                                                 nvl(ln_sdi_ee_withheld,0) ;
                      state_bal(ln_next_tab).sdi_er_taxable :=
                                                 nvl(ln_sdi_er_taxable,0) ;
                      state_bal(ln_next_tab).sdi_er_liability :=
                                                 nvl(ln_sdi_er_liability,0) ;
                      state_bal(ln_next_tab).workers_comp_withheld :=
                                                 nvl(ln_workers_comp_withheld,0) ;
                      state_bal(ln_next_tab).workers_comp2_withheld:=
                                                 nvl(ln_workers_comp2_withheld,0) ;
                      state_bal(ln_next_tab).sdi1_ee_withheld :=
                                                 nvl(ln_sdi1_ee_withheld,0) ;
                    END IF;

                 ELSE /* state_bal.count = 0, first fetch **/
                   hr_utility.trace('STATE first fetch .................');
                   state_bal(1).tax_unit_id := ln_tax_unit_id;
                   state_bal(1).gre_name := lv_gre_name;
                   state_bal(1).state_ein := lv_state_ein;
                   state_bal(1).jurisdiction_code := lv_jurisdiction;
                   state_bal(1).jurisdiction_name := lv_jurisdiction_name;
                   state_bal(1).sit_gross := nvl(ln_sit_gross,0) ;
                   state_bal(1).sit_reduced_subject := nvl(ln_sit_reduced_subject,0) ;
                   state_bal(1).sit_withheld := nvl(ln_sit_withheld,0) ;
                   state_bal(1).sui_ee_taxable := nvl(ln_sui_ee_taxable,0) ;
                   state_bal(1).sui_ee_withheld := nvl(ln_sui_ee_withheld,0) ;
                   state_bal(1).sui_er_taxable := nvl(ln_sui_er_taxable,0) ;
                   state_bal(1).sui_er_liability := nvl(ln_sui_er_liability,0) ;
                   state_bal(1).sdi_ee_taxable := nvl(ln_sdi_ee_taxable,0) ;
                   state_bal(1).sdi_ee_withheld := nvl(ln_sdi_ee_withheld,0) ;
                   state_bal(1).sdi_er_taxable := nvl(ln_sdi_er_taxable,0) ;
                   state_bal(1).sdi_er_liability := nvl(ln_sdi_er_liability,0) ;
                   state_bal(1).workers_comp_withheld :=
                                                 nvl(ln_workers_comp_withheld,0) ;
                   state_bal(1).workers_comp2_withheld:=
                                                 nvl(ln_workers_comp2_withheld,0);
                   state_bal(1).sdi1_ee_withheld := nvl(ln_sdi1_ee_withheld,0) ;
                 END IF;
              ELSE /** New Person Fetched, write out prev person **/
                hr_utility.trace('.....State ELSE New Person Fetched .......');
                hr_utility.trace('Write out the previous person.............');

                lv_prev_emp_data_row := lv_data_row;

                IF state_bal.count > 0 THEN
                 FOR i in state_bal.first..state_bal.last LOOP
                     state_static_data( state_bal(i).gre_name
                                  ,state_bal(i).state_ein
                                  ,state_bal(i).jurisdiction_code
                                  ,state_bal(i).jurisdiction_name
                                  ,state_bal(i).sit_gross
                                  ,state_bal(i).sit_reduced_subject
                                  ,state_bal(i).sit_withheld
                                  ,state_bal(i).sui_ee_taxable
                                  ,state_bal(i).sui_ee_withheld
                                  ,state_bal(i).sui_er_taxable
                                  ,state_bal(i).sui_er_liability
                                  ,state_bal(i).sdi_ee_taxable
                                  ,state_bal(i).sdi_ee_withheld
                                  ,state_bal(i).sdi_er_taxable
                                  ,state_bal(i).sdi_er_liability
                                  ,state_bal(i).workers_comp_withheld
                                  ,state_bal(i).workers_comp2_withheld
                                  ,state_bal(i).sdi1_ee_withheld
                                  ,p_output_file_type
                                  ,lv_state_data_sum);

                        lv_data_row := lv_prev_emp_data_row||lv_state_data_sum;

                        if p_output_file_type = 'HTML' then
                          lv_data_row := '<tr>'||lv_data_row||'</tr>';
                        end if;
                       FND_FILE.PUT_LINE(FND_FILE.OUTPUT,lv_data_row);
                   END LOOP;
                 END IF; /* state_bal.count */
                 hr_utility.trace('Before building new emp header');

                  /** Now, build employee static header with the new
                      fetched record                         **/

                 emp_sum_static_data( lv_last_name,
                                  lv_first_name,
                                  lv_middle_name,
                                  lv_employee_number,
                                  lv_national_identifier,
                                  lv_fed_ein,
                                  p_output_file_type,
                                  lv_employee_data);
                  lv_data_row := lv_employee_data;
                  /* Set the prev person to this fetched person */
                  ln_prev_person := ln_person_id;

                  /******** reset Sum to currently fetched record *******/

                  hr_utility.trace('Resetting Summary for State .............');
                  IF state_bal.count > 0 THEN
                    FOR i in state_bal.first..state_bal.last LOOP
                       state_bal(i).tax_unit_id             := -1;
                       state_bal(i).gre_name                := null;
                       state_bal(i).state_ein               := null;
                       state_bal(i).jurisdiction_code       := null;
                       state_bal(i).jurisdiction_name       := null;
                       state_bal(i).sit_gross               := 0;
                       state_bal(i).sit_reduced_subject     := 0;
                       state_bal(i).sit_withheld            := 0;
                       state_bal(i).sui_ee_taxable          := 0;
                       state_bal(i).sui_ee_withheld         := 0;
                       state_bal(i).sui_er_taxable          := 0;
                       state_bal(i).sui_er_liability        := 0;
                       state_bal(i).sdi_ee_taxable          := 0;
                       state_bal(i).sdi_ee_withheld         := 0;
                       state_bal(i).sdi_er_taxable          := 0;
                       state_bal(i).sdi_er_liability        := 0;
                       state_bal(i).workers_comp_withheld   := 0;
                       state_bal(i).workers_comp2_withheld  := 0;
                       state_bal(i).sdi1_ee_withheld         := 0;
                     END LOOP;
                   END IF;
                   state_bal.delete;

                   state_bal(1).tax_unit_id := ln_tax_unit_id;
                   state_bal(1).gre_name := lv_gre_name;
                   state_bal(1).state_ein := lv_state_ein;
                   state_bal(1).jurisdiction_code := lv_jurisdiction;
                   state_bal(1).jurisdiction_name := lv_jurisdiction_name;
                   state_bal(1).sit_gross := nvl(ln_sit_gross,0) ;
                   state_bal(1).sit_reduced_subject := nvl(ln_sit_reduced_subject,0) ;
                   state_bal(1).sit_withheld := nvl(ln_sit_withheld,0) ;
                   state_bal(1).sui_ee_taxable := nvl(ln_sui_ee_taxable,0) ;
                   state_bal(1).sui_ee_withheld := nvl(ln_sui_ee_withheld,0) ;
                   state_bal(1).sui_er_taxable := nvl(ln_sui_er_taxable,0) ;
                   state_bal(1).sui_er_liability := nvl(ln_sui_er_liability,0) ;
                   state_bal(1).sdi_ee_taxable := nvl(ln_sdi_ee_taxable,0) ;
                   state_bal(1).sdi_ee_withheld := nvl(ln_sdi_ee_withheld,0) ;
                   state_bal(1).sdi_er_taxable := nvl(ln_sdi_er_taxable,0) ;
                   state_bal(1).sdi_er_liability := nvl(ln_sdi_er_liability,0) ;
                   state_bal(1).workers_comp_withheld :=
                                                 nvl(ln_workers_comp_withheld,0) ;
                   state_bal(1).workers_comp2_withheld:=
                                                 nvl(ln_workers_comp2_withheld,0);
                   state_bal(1).sdi1_ee_withheld := nvl(ln_sdi1_ee_withheld,0) ;

                   hr_utility.trace('New state summary for '||
                                     ln_person_id|| ' sit_gross = '||
                                     state_bal(1).sit_gross);
             END IF; /* Person Check */
            END IF; /* detail level check */

       END LOOP;
         close c_state_balances;
       END IF;  /* Jurisdiction Level Check */

       /******************************************/
       /***            County Balances         ***/
       /******************************************/

       IF p_jurisdiction_level = '03' THEN

         hr_utility.trace('----------------------------------------');
         hr_utility.trace('.............In COUNTY..................');
         hr_utility.trace('p_state_id = '||p_state_id);
         hr_utility.trace('p_county_id = '||p_county_id);
         hr_utility.trace('ln_action_number = '||ln_action_number);
         hr_utility.trace('jurisdiction = '||p_state_id||'-'||
                          nvl(p_county_id,'%')||'-0000');
         hr_utility.trace('----------------------------------------');

         OPEN c_county_balances(ln_action_number, p_state_id, p_county_id);
         LOOP
          hr_utility.trace('Fetching COUNTY records .................');
          fetch c_county_balances into lv_jurisdiction,
                                   lv_jurisdiction_name,
                                   ln_county_gross,
                                   ln_county_reduced_subject,
                                   ln_county_withheld,
                                   ln_head_tax_withheld,
                                   lv_non_resident_flag;

          EXIT WHEN c_county_balances%NOTFOUND;

          hr_utility.trace('Fetched records are .................');
          hr_utility.trace('                                     ');
          hr_utility.trace('lv_jurisdiction = '||lv_jurisdiction);
          hr_utility.trace('lv_jurisdiction_name = '||lv_jurisdiction_name);
          hr_utility.trace('ln_county_gross = '||ln_county_gross);
          hr_utility.trace('ln_county_reduced_subject = '||
                            ln_county_reduced_subject);
          hr_utility.trace('ln_county_withheld = '||ln_county_withheld);
          hr_utility.trace('ln_head_tax_withheld = '||ln_head_tax_withheld);
          hr_utility.trace('----------------------------------------');

          /******** County Balances by run  *******/

          IF p_detail_level = '01' THEN

          hr_utility.trace('----------------------------------------');
          hr_utility.trace('County by run output....................');
          hr_utility.trace('ln_action_number = '||ln_action_number);
          hr_utility.trace('----------------------------------------');

             emp_static_data(
                          lv_last_name,
                          lv_first_name,
                          lv_middle_name,
                          lv_employee_number,
                          lv_assignment_number,
                          lv_national_identifier,
                          lv_address_line,
                          lv_town_or_city,
                          lv_county,
                          lv_state,
                          lv_postal_code,
                          lv_country,
                          lv_fed_ein,
                          lv_org_name,
                          lv_location_code,
                          lv_action_type,
                          ld_effective_date,
                          p_output_file_type,
                          lv_employee_data);

             lv_data_row := lv_employee_data;

             county_static_data( lv_gre_name,
                                 lv_jurisdiction,
                                 lv_jurisdiction_name,
                                 nvl(ln_county_gross,0),
                                 nvl(ln_county_reduced_subject,0),
                                 nvl(ln_county_withheld,0),
                                 nvl(ln_head_tax_withheld,0),
                                 lv_non_resident_flag,
                                 p_output_file_type,
                                 lv_county_data);

              lv_data_row := lv_data_row||lv_county_data;

              if p_output_file_type = 'HTML' then
                 lv_data_row := '<tr>'||lv_data_row||'</tr>';
              end if;
              FND_FILE.PUT_LINE(FND_FILE.OUTPUT,lv_data_row);
          END IF;

          /******* County Balances by Summary (by Jurisdiction) ******/

          IF p_detail_level = '02' THEN

          hr_utility.trace('----------------------------------------');
          hr_utility.trace('County by Summary....................');
          hr_utility.trace('ln_action_number = '||ln_action_number);
          hr_utility.trace('ln_prev_person = '||ln_prev_person);
          hr_utility.trace('ln_person_id = '||ln_person_id);
          hr_utility.trace('----------------------------------------');

           IF ln_prev_person = ln_person_id THEN
                 emp_sum_static_data( lv_last_name,
                                  lv_first_name,
                                  lv_middle_name,
                                  lv_employee_number,
                                  lv_national_identifier,
                                  lv_fed_ein,
                                  p_output_file_type,
                                  lv_employee_data);
                 lv_data_row := lv_employee_data;

             IF p_county_id is null THEN
                lv_county_id := substr(lv_jurisdiction,4,3);
             ELSE
                lv_county_id := p_county_id;
             END IF;

             hr_utility.trace('p_state_id = '||p_state_id);
             hr_utility.trace('lv_county_id = '||lv_county_id);
             hr_utility.trace('county_bal.count = '||county_bal.count);

             lv_found := 'N';

             IF county_bal.count > 0 THEN
               FOR k in county_bal.first..county_bal.last LOOP
                 IF (county_bal(k).jurisdiction_code = lv_jurisdiction
                     AND
                     county_bal(k).tax_unit_id = ln_tax_unit_id ) THEN
                    lv_found := 'Y';
                    county_bal(k).county_gross := county_bal(k).county_gross +
                                                 nvl(ln_county_gross,0);
                    county_bal(k).county_reduced_subject :=
                                 nvl(ln_county_reduced_subject,0) +
                                 county_bal(k).county_reduced_subject;
                    county_bal(k).county_withheld := nvl(ln_county_withheld,0) +
                                 county_bal(k).county_withheld;
                    county_bal(k).county_head_tax_withheld :=
                                   nvl(ln_head_tax_withheld,0) +
                                   county_bal(k).county_head_tax_withheld;
                 END IF;
                END LOOP;
                hr_utility.trace('lv_found := '||lv_found);
                IF lv_found = 'N' THEN
                    ln_next_tab := county_bal.count +1;
                    county_bal(ln_next_tab).tax_unit_id := ln_tax_unit_id;
                    county_bal(ln_next_tab).gre_name := lv_gre_name;
                    county_bal(ln_next_tab).jurisdiction_code :=
                                               lv_jurisdiction;
                    county_bal(ln_next_tab).jurisdiction_name :=
                                               lv_jurisdiction_name;
                    county_bal(ln_next_tab).county_gross :=
                                               nvl(ln_county_gross,0);
                    county_bal(ln_next_tab).county_reduced_subject :=
                                              nvl(ln_county_reduced_subject,0);
                    county_bal(ln_next_tab).county_withheld :=
                                              nvl(ln_county_withheld,0);
                    county_bal(ln_next_tab).county_head_tax_withheld :=
                                              nvl(ln_head_tax_withheld,0);
                END IF;


             ELSE /** county_bal = 0, first fetch **/
                 hr_utility.trace('COUNTY first fetch ..........');
                    county_bal(1).tax_unit_id := ln_tax_unit_id;
                    county_bal(1).gre_name := lv_gre_name;
                    county_bal(1).jurisdiction_code :=
                                               lv_jurisdiction;
                    county_bal(1).jurisdiction_name :=
                                               lv_jurisdiction_name;
                    county_bal(1).county_gross :=
                                               nvl(ln_county_gross,0);
                    county_bal(1).county_reduced_subject :=
                                              nvl(ln_county_reduced_subject,0);
                    county_bal(1).county_withheld :=
                                              nvl(ln_county_withheld,0);
                    county_bal(1).county_head_tax_withheld :=
                                              nvl(ln_head_tax_withheld,0);

             END IF;

         ELSE /**  New Person Fetched, write out prev person **/
            hr_utility.trace('.......County ELSE New Person Fetched .......');
            hr_utility.trace('Write out the previous person................');

            lv_prev_emp_data_row := lv_data_row;

            IF county_bal.count>0 THEN
              FOR k in county_bal.first..county_bal.last LOOP
                county_static_data( county_bal(k).gre_name,
                                    county_bal(k).jurisdiction_code,
                                    county_bal(k).jurisdiction_name,
                                    county_bal(k).county_gross,
                                    county_bal(k).county_reduced_subject,
                                    county_bal(k).county_withheld,
                                    county_bal(k).county_head_tax_withheld,
                                    '', --Non resident flag
                                    p_output_file_type,
                                    lv_county_data_sum);
                 lv_data_row := lv_prev_emp_data_row||lv_county_data_sum;
                 if p_output_file_type = 'HTML' then
                     lv_data_row := '<tr>'||lv_data_row||'</tr>';
                 end if;
                 FND_FILE.PUT_LINE(FND_FILE.OUTPUT,lv_data_row);
              END LOOP;
            END IF; --county_bal.count
            hr_utility.trace('End of printing COUNTY sum.....');

            /**** Now, build employee static header with the new fetched ***/
            /**** Person record                                          ***/

            emp_sum_static_data( lv_last_name,
                             lv_first_name,
                             lv_middle_name,
                             lv_employee_number,
                             lv_national_identifier,
                             lv_fed_ein,
                             p_output_file_type,
                             lv_employee_data);

            lv_data_row := lv_employee_data;
            /* Set the prev person to this fetched person */
            ln_prev_person := ln_person_id;

            /*** Reset sum to currently Fetched Record ***/

            hr_utility.trace('Resetting Summary for county................');
            IF county_bal.count > 0 THEN
              FOR k in county_bal.first..county_bal.last LOOP
               county_bal(k).tax_unit_id := -1;
               county_bal(k).gre_name := '';
               county_bal(k).jurisdiction_code:='';
               county_bal(k).jurisdiction_name:='';
               county_bal(k).county_gross:=0;
               county_bal(k).county_reduced_subject:=0;
               county_bal(k).county_withheld:=0;
               county_bal(k).county_head_tax_withheld:=0;
              END LOOP;
            END IF;
            county_bal.delete;

            county_bal(1).tax_unit_id := ln_tax_unit_id;
            county_bal(1).gre_name := lv_gre_name;
            county_bal(1).jurisdiction_code := lv_jurisdiction;
            county_bal(1).jurisdiction_name := lv_jurisdiction_name;
            county_bal(1).county_gross := nvl(ln_county_gross,0);
            county_bal(1).county_reduced_subject := nvl(ln_county_reduced_subject,0);
            county_bal(1).county_withheld := nvl(ln_county_withheld,0);
            county_bal(1).county_head_tax_withheld := nvl(ln_head_tax_withheld,0);

            hr_utility.trace('New County summary for '||
                             ln_person_id||' county_gross = '||
                             county_bal(1).county_gross);

          END IF;  /** Person Check **/
       END IF; /** Detail Level Check **/

       END LOOP;
            close c_county_balances;
       END IF;  /* Jurisdiction Level Check for County */

       /*************************************************/
       /***             City Balances                 ***/
       /*************************************************/

       IF p_jurisdiction_level = '04' THEN

       hr_utility.trace('-----------------------------------------');
       hr_utility.trace('.........In CITY balances ...............');
       hr_utility.trace('ln_action_number = '||ln_action_number);
       hr_utility.trace('Jurisdiction Code = '||
                        p_state_id||'-'||p_county_id||'-'||nvl(p_city_id,'%'));
       hr_utility.trace('-----------------------------------------');

         open c_city_balances(ln_action_number,
                              p_state_id,
                              p_county_id,
                              p_city_id);
         LOOP
          hr_utility.trace('Fetching CITY balance.............');
          fetch c_city_balances into lv_jurisdiction,
                                   lv_jurisdiction_name,
                                   ln_city_gross,
                                   ln_city_reduced_subject,
                                   ln_city_withheld,
                                   ln_head_tax_withheld,
                                   lv_non_resident_flag;

          EXIT WHEN c_city_balances%NOTFOUND;

         hr_utility.trace('-----------------------------------------');
         hr_utility.trace('Fetched CITY balance.............');
         hr_utility.trace('ln_city_gross = '||ln_city_gross);
         hr_utility.trace('ln_city_reduced_subject = '||ln_city_reduced_subject);
         hr_utility.trace('ln_city_withheld = '||ln_city_withheld);
         hr_utility.trace('ln_head_tax_withheld = '||ln_head_tax_withheld);
         hr_utility.trace('-----------------------------------------');

          /****** City Balances By Run  ********/

          IF p_detail_level = '01' THEN

          hr_utility.trace('-----------------------------------------');
          hr_utility.trace('City by Run output.......................');
          hr_utility.trace('ln_action_number = '||ln_action_number);
          hr_utility.trace('-----------------------------------------');

             emp_static_data( lv_last_name,
                          lv_first_name,
                          lv_middle_name,
                          lv_employee_number,
                          lv_assignment_number,
                          lv_national_identifier,
                          lv_address_line,
                          lv_town_or_city,
                          lv_county,
                          lv_state,
                          lv_postal_code,
                          lv_country,
                          lv_fed_ein,
                          lv_org_name,
                          lv_location_code,
                          lv_action_type,
                          ld_effective_date,
                          p_output_file_type,
                          lv_employee_data);

             lv_data_row := lv_employee_data;

             city_static_data(lv_gre_name,
                              lv_jurisdiction,
                              lv_jurisdiction_name,
                              nvl(ln_city_gross,0),
                              nvl(ln_city_reduced_subject,0),
                              nvl(ln_city_withheld,0),
                              nvl(ln_head_tax_withheld,0),
                              lv_non_resident_flag,
                              p_output_file_type,
                              lv_city_data);

             lv_data_row := lv_data_row||lv_city_data;

             if p_output_file_type = 'HTML' then
                lv_data_row := '<tr>'||lv_data_row||'</tr>';
             end if;
             FND_FILE.PUT_LINE(FND_FILE.OUTPUT,lv_data_row);
           END IF;

           /********* City Balances by Summary (by Jurisdiction) *******/

           IF p_detail_level = '02' THEN

           hr_utility.trace('----------------------------------------');
           hr_utility.trace('City by Summary....................');
           hr_utility.trace('ln_action_number = '||ln_action_number);
           hr_utility.trace('ln_prev_person = '||ln_prev_person);
           hr_utility.trace('ln_person_id = '||ln_person_id);
           hr_utility.trace('----------------------------------------');

            IF ln_prev_person = ln_person_id THEN
                  emp_sum_static_data( lv_last_name,
                                   lv_first_name,
                                   lv_middle_name,
                                   lv_employee_number,
                                   lv_national_identifier,
                                   lv_fed_ein,
                                   p_output_file_type,
                                   lv_employee_data);

                    lv_data_row := lv_employee_data;

              IF p_city_id is null THEN
                 lv_city_id := substr(lv_jurisdiction,8,4);
              ELSE
                  lv_city_id := p_city_id;
              END IF;
              hr_utility.trace('city_bal.count = '||city_bal.count);

              lv_found := 'N';
              IF city_bal.count > 0 THEN
               FOR k in city_bal.first..city_bal.last LOOP
                 IF (city_bal(k).jurisdiction_code = lv_jurisdiction
                     AND
                     city_bal(k).tax_unit_id = ln_tax_unit_id) THEN
                    lv_found := 'Y';
                    city_bal(k).city_gross := city_bal(k).city_gross +
                                                 nvl(ln_city_gross,0);
                    city_bal(k).city_reduced_subject :=
                                 nvl(ln_city_reduced_subject,0) +
                                 city_bal(k).city_reduced_subject;
                    city_bal(k).city_withheld := nvl(ln_city_withheld,0) +
                                 city_bal(k).city_withheld;
                    city_bal(k).head_tax_withheld :=
                                   nvl(ln_head_tax_withheld,0) +
                                   city_bal(k).head_tax_withheld;
                 END IF;
                END LOOP;
                hr_utility.trace('lv_found := '||lv_found);
                IF lv_found = 'N' THEN
                  ln_next_tab := city_bal.count +1;
                  city_bal(ln_next_tab).tax_unit_id := ln_tax_unit_id;
                  city_bal(ln_next_tab).gre_name := lv_gre_name;
                  city_bal(ln_next_tab).jurisdiction_code :=
                                                   lv_jurisdiction;
                  city_bal(ln_next_tab).jurisdiction_name :=
                                                   lv_jurisdiction_name;
                  city_bal(ln_next_tab).city_gross := nvl(ln_city_gross,0);
                  city_bal(ln_next_tab).city_reduced_subject :=
                                                   nvl(ln_city_reduced_subject,0);
                  city_bal(ln_next_tab).city_withheld := nvl(ln_city_withheld,0);
                  city_bal(ln_next_tab).head_tax_withheld :=
                                                   nvl(ln_head_tax_withheld,0);
                END IF;

               ELSE /** city_bal = 0, first fetch **/
                 hr_utility.trace('CITY first fetch ..........');
                    city_bal(1).tax_unit_id := ln_tax_unit_id;
                    city_bal(1).gre_name := lv_gre_name;
                    city_bal(1).jurisdiction_code := lv_jurisdiction;
                    city_bal(1).jurisdiction_name := lv_jurisdiction_name;
                    city_bal(1).city_gross := nvl(ln_city_gross,0);
                    city_bal(1).city_reduced_subject := nvl(ln_city_reduced_subject,0);
                    city_bal(1).city_withheld := nvl(ln_city_withheld,0);
                    city_bal(1).head_tax_withheld := nvl(ln_head_tax_withheld,0);
               END IF;
             ELSE /*** New person fetched, write out prev person **/
             hr_utility.trace('.......City ELSE New Person Fetched .......');
             hr_utility.trace('Write out the previous person................');

               lv_prev_emp_data_row := lv_data_row;

               IF city_bal.count>0 THEN
                FOR k in city_bal.first..city_bal.last LOOP
                  city_static_data( city_bal(k).gre_name,
                                    city_bal(k).jurisdiction_code,
                                    city_bal(k).jurisdiction_name,
                                    city_bal(k).city_gross,
                                    city_bal(k).city_reduced_subject,
                                    city_bal(k).city_withheld,
                                    city_bal(k).head_tax_withheld,
                                    '', --Non resident flag
                                    p_output_file_type,
                                    lv_city_data_sum);
                 lv_data_row := lv_prev_emp_data_row||lv_city_data_sum;
                 if p_output_file_type = 'HTML' then
                     lv_data_row := '<tr>'||lv_data_row||'</tr>';
                 end if;
                 FND_FILE.PUT_LINE(FND_FILE.OUTPUT,lv_data_row);
               END LOOP;
              END IF; -- city_bal.count
              hr_utility.trace('End of printing COUNTY sum.....');

            /**** Now, build employee static header with the new fetched ***/
            /**** Person record                                          ***/

              emp_sum_static_data( lv_last_name,
                               lv_first_name,
                               lv_middle_name,
                               lv_employee_number,
                               lv_national_identifier,
                               lv_fed_ein,
                               p_output_file_type,
                               lv_employee_data);
               lv_data_row := lv_employee_data;
               /* Set the prev person to this fetched person */
               ln_prev_person := ln_person_id;

               /*** Reset sum to currently Fetched Record ***/

               hr_utility.trace('Resetting Summary for city................');
               IF city_bal.count > 0 THEN
                 FOR k in city_bal.first..city_bal.last LOOP
                  city_bal(k).tax_unit_id := -1;
                  city_bal(k).gre_name := '';
                  city_bal(k).jurisdiction_code:='';
                  city_bal(k).jurisdiction_name:='';
                  city_bal(k).city_gross:=0;
                  city_bal(k).city_reduced_subject:=0;
                  city_bal(k).city_withheld:=0;
                  city_bal(k).head_tax_withheld:=0;
                 END LOOP;
               END IF;
               city_bal.delete;

               city_bal(1).tax_unit_id := ln_tax_unit_id;
               city_bal(1).gre_name := lv_gre_name;
               city_bal(1).jurisdiction_code := lv_jurisdiction;
               city_bal(1).jurisdiction_name := lv_jurisdiction_name;
               city_bal(1).city_gross := nvl(ln_city_gross,0);
               city_bal(1).city_reduced_subject := nvl(ln_city_reduced_subject,0);
               city_bal(1).city_withheld := nvl(ln_city_withheld,0);
               city_bal(1).head_tax_withheld := nvl(ln_head_tax_withheld,0);

               hr_utility.trace('New City summary for '||
                             ln_person_id||' city_gross = '||
                             city_bal(1).city_gross);

          END IF;  /** Person Check **/
       END IF; /** Detail Level Check **/

        END LOOP;
        close c_city_balances;
       END IF;  -- Jurisdiction Level Check for city

       /*********************************************/
       /***        School District Balances      ****/
       /*********************************************/

       IF p_jurisdiction_level = '05' THEN

         hr_utility.trace('-------------------------------------');
         hr_utility.trace('............In SCHOOL DIST...........');
         hr_utility.trace('p_city_id = '||p_city_id);
         hr_utility.trace('Jurisdiction Code = '||
                          p_state_id||'-'||nvl(p_school_id,'%'));

         open c_school_balances(ln_action_number,
                                p_state_id,
                                p_school_id);
         LOOP

          hr_utility.trace('Fetching SCHOOL balance ................');
          fetch c_school_balances into lv_jurisdiction,
                                       lv_jurisdiction_name,
                                       ln_school_gross,
                                       ln_school_reduced_subject,
                                       ln_school_withheld;

          EXIT WHEN c_school_balances%NOTFOUND;

          hr_utility.trace('Fetched SCHOOL balance.............');
          hr_utility.trace('----------------------------------------');
          hr_utility.trace('ln_school_gross = '||ln_school_gross);
          hr_utility.trace('ln_school_withheld = '||ln_school_withheld);
          hr_utility.trace('----------------------------------------');

          /******* School Balance By Run *****/

          IF p_detail_level = '01' THEN

          hr_utility.trace('-----------------------------------');
          hr_utility.trace('School Dist by Run output..........');
          hr_utility.trace('ln_action_number = '||ln_action_number);
          hr_utility.trace('-----------------------------------');

                  emp_static_data( lv_last_name,
                                    lv_first_name,
                                    lv_middle_name,
                                    lv_employee_number,
                                    lv_assignment_number,
                                    lv_national_identifier,
                                    lv_address_line,
                                    lv_town_or_city,
                                    lv_county,
                                    lv_state,
                                    lv_postal_code,
                                    lv_country,
                                    lv_fed_ein,
                                    lv_org_name,
                                    lv_location_code,
                                    lv_action_type,
                                    ld_effective_date,
                                    p_output_file_type,
                                    lv_employee_data);

             lv_data_row := lv_employee_data;

             school_static_data(lv_gre_name,
                                lv_jurisdiction,
                                lv_jurisdiction_name,
                                nvl(ln_school_gross,0),
                                nvl(ln_school_reduced_subject,0),
                                nvl(ln_school_withheld,0),
                                p_output_file_type,
                                lv_school_data);

             lv_data_row := lv_data_row||lv_school_data;

             if p_output_file_type = 'HTML' then
                lv_data_row := '<tr>'||lv_data_row||'</tr>';
             end if;
             FND_FILE.PUT_LINE(FND_FILE.OUTPUT,lv_data_row);
          END IF;

          /***** School balance by Summary (by jurisdiction) *****/

          IF p_detail_level = '02' THEN
           hr_utility.trace('----------------------------------------');
           hr_utility.trace('City by Summary....................');
           hr_utility.trace('ln_action_number = '||ln_action_number);
           hr_utility.trace('ln_prev_person = '||ln_prev_person);
           hr_utility.trace('ln_person_id = '||ln_person_id);
           hr_utility.trace('----------------------------------------');
            IF ln_prev_person = ln_person_id THEN
                  emp_sum_static_data( lv_last_name,
                                    lv_first_name,
                                    lv_middle_name,
                                    lv_employee_number,
                                    lv_national_identifier,
                                    lv_fed_ein,
                                    p_output_file_type,
                                    lv_employee_data);

                 lv_data_row := lv_employee_data;
              hr_utility.trace('p_state_id = '||p_state_id);
              hr_utility.trace('p_county_id = '||p_county_id);
              hr_utility.trace('p_city_id = '||p_city_id);
              hr_utility.trace('school_bal.count = '||school_bal.count);

              lv_found := 'N';
              IF school_bal.count > 0 THEN
               FOR k in school_bal.first..school_bal.last LOOP
                 IF (school_bal(k).jurisdiction_code = lv_jurisdiction
                     AND
                     school_bal(k).tax_unit_id = ln_tax_unit_id) THEN
                    lv_found := 'Y';
                    school_bal(k).school_gross := nvl(ln_school_gross,0) +
                                              school_bal(k).school_gross;
                    school_bal(k).school_reduced_subject := nvl(ln_school_reduced_subject,0)
                                            + school_bal(k).school_reduced_subject;
                    school_bal(k).school_withheld := nvl(ln_school_withheld,0) +
                                              school_bal(k).school_withheld;
                 END IF;
               END LOOP;

               hr_utility.trace('lv_found := '||lv_found);
               IF lv_found = 'N' THEN
                  ln_next_tab := school_bal.count +1;
                  school_bal(ln_next_tab).tax_unit_id := ln_tax_unit_id;
                  school_bal(ln_next_tab).gre_name := lv_gre_name;
                  school_bal(ln_next_tab).jurisdiction_code := lv_jurisdiction;
                  school_bal(ln_next_tab).jurisdiction_name :=
                                                       lv_jurisdiction_name;
                  school_bal(ln_next_tab).school_gross := nvl(ln_school_gross,0);
                  school_bal(ln_next_tab).school_reduced_subject :=
                                                       nvl(ln_school_reduced_subject,0);
                  school_bal(ln_next_tab).school_withheld := nvl(ln_school_withheld,0);
               END IF;

             ELSE /** city_bal = 0, first fetch **/
                 hr_utility.trace('SCHOOL first fetch ..........');
                    school_bal(1).tax_unit_id := ln_tax_unit_id;
                    school_bal(1).gre_name := lv_gre_name;
                    school_bal(1).jurisdiction_code := lv_jurisdiction;
                    school_bal(1).jurisdiction_name := lv_jurisdiction_name;
                    school_bal(1).school_gross := nvl(ln_school_gross,0);
                    school_bal(1).school_reduced_subject :=
                                                  nvl(ln_school_reduced_subject,0);
                    school_bal(1).school_withheld := nvl(ln_school_withheld,0);
              END IF;
           ELSE /*** New person fetched, write out prev person **/
             hr_utility.trace('.......School ELSE New Person Fetched .......');
             hr_utility.trace('Write out the previous person................');

             lv_prev_emp_data_row := lv_data_row;

             IF school_bal.count>0 THEN
               FOR k in school_bal.first..school_bal.last LOOP
                  school_static_data( school_bal(k).gre_name,
                                      school_bal(k).jurisdiction_code,
                                      school_bal(k).jurisdiction_name,
                                      school_bal(k).school_gross,
                                      school_bal(k).school_reduced_subject,
                                      school_bal(k).school_withheld,
                                      p_output_file_type,
                                      lv_school_data_sum);
                 lv_data_row := lv_prev_emp_data_row||lv_school_data_sum;
                 if p_output_file_type = 'HTML' then
                     lv_data_row := '<tr>'||lv_data_row||'</tr>';
                 end if;
                 FND_FILE.PUT_LINE(FND_FILE.OUTPUT,lv_data_row);
               END LOOP;
             END IF; -- school_bal.count
              hr_utility.trace('End of printing SCHOOL sum.....');
            /**** Now, build employee static header with the new fetched ***/
            /**** Person record                                          ***/

              emp_sum_static_data( lv_last_name,
                               lv_first_name,
                               lv_middle_name,
                               lv_employee_number,
                               lv_national_identifier,
                               lv_fed_ein,
                               p_output_file_type,
                               lv_employee_data);
               lv_data_row := lv_employee_data;
               /* Set the prev person to this fetched person */
               ln_prev_person := ln_person_id;
               /*** Reset sum to currently Fetched Record ***/

               hr_utility.trace('Resetting Summary for school................');
               IF school_bal.count > 0 THEN
                 FOR k in school_bal.first..school_bal.last LOOP
                  school_bal(k).tax_unit_id := -1;
                  school_bal(k).gre_name := '';
                  school_bal(k).jurisdiction_code:='';
                  school_bal(k).jurisdiction_name:='';
                  school_bal(k).school_gross := 0;
                  school_bal(k).school_reduced_subject := 0;
                  school_bal(k).school_withheld:=0;
                 END LOOP;
               END IF;
               school_bal.delete;

               school_bal(1).tax_unit_id := ln_tax_unit_id;
               school_bal(1).gre_name := lv_gre_name;
               school_bal(1).jurisdiction_code := lv_jurisdiction;
               school_bal(1).jurisdiction_name := lv_jurisdiction_name;
               school_bal(1).school_gross := nvl(ln_school_gross,0);
               school_bal(1).school_reduced_subject := nvl(ln_school_reduced_subject,0);
               school_bal(1).school_withheld := nvl(ln_school_withheld,0);

               hr_utility.trace('New School summary for '||
                             ln_person_id||' school_withheld = '||
                             school_bal(1).school_withheld);

          END IF;  /** Person Check **/
       END IF; /** Detail Level Check **/

       END LOOP;
         close c_school_balances;
       END IF; /** School Jurisdiction Level check */
    END IF;   /**** End of Assignment Set ****/

    /** Reset the previous person to the current person
       before fetching another person **/
   hr_utility.trace('Getting Next employee ........ ');

   --ln_prev_person := ln_person_id; /* 2974109 fix */

   END LOOP; /** End of Employee Loop */
   CLOSE c_employee;

   /**** Write out the last fetched record ****/

   IF (p_jurisdiction_level = '01' and p_detail_level = '02') then
     hr_utility.trace('Inside FINAL write out for FED');

     lv_emp_data_row := lv_data_row;
     IF federal_bal.count > 0 THEN
       FOR k in federal_bal.first..federal_bal.last LOOP
            fed_static_data( federal_bal(k).gre_name,
                             federal_bal(k).fit_gross ,
                             federal_bal(k).fit_reduced_subject,
                             federal_bal(k).fit_withheld,
                             federal_bal(k).futa_taxable ,
                             federal_bal(k).futa_liability ,
                             federal_bal(k).ss_ee_taxable ,
                             federal_bal(k).ss_ee_withheld,
                             federal_bal(k).ss_er_taxable,
                             federal_bal(k).ss_er_liability ,
                             federal_bal(k).medicare_ee_taxable,
                             federal_bal(k).medicare_ee_withheld,
                             federal_bal(k).medicare_er_taxable ,
                             federal_bal(k).medicare_er_liability,
                             federal_bal(k).eic_advance,
                             p_output_file_type,
                             lv_federal_data_sum);

             lv_data_row := lv_emp_data_row||lv_federal_data_sum;

             if p_output_file_type = 'HTML' then
               lv_data_row := '<tr>'||lv_data_row||'</tr>';
             end if;

             FND_FILE.PUT_LINE(FND_FILE.OUTPUT,lv_data_row);
        END LOOP;
      END IF;
   END IF;

   IF (p_jurisdiction_level = '02' and p_detail_level = '02') then
     hr_utility.trace('Inside FINAL write out for STATE');

               lv_emp_data_row := lv_data_row;

               IF state_bal.count > 0 THEN
                 FOR i in state_bal.first..state_bal.last LOOP
                      state_static_data(state_bal(i).gre_name
                                        ,state_bal(i).state_ein
                                        ,state_bal(i).jurisdiction_code
                                        ,state_bal(i).jurisdiction_name
                                        ,state_bal(i).sit_gross
                                        ,state_bal(i).sit_reduced_subject
                                        ,state_bal(i).sit_withheld
                                        ,state_bal(i).sui_ee_taxable
                                        ,state_bal(i).sui_ee_withheld
                                        ,state_bal(i).sui_er_taxable
                                        ,state_bal(i).sui_er_liability
                                        ,state_bal(i).sdi_ee_taxable
                                        ,state_bal(i).sdi_ee_withheld
                                        ,state_bal(i).sdi_er_taxable
                                        ,state_bal(i).sdi_er_liability
                                        ,state_bal(i).workers_comp_withheld
                                        ,state_bal(i).workers_comp2_withheld
                                        ,state_bal(i).sdi1_ee_withheld
                                        ,p_output_file_type
                                        ,lv_state_data_sum);

                       lv_data_row := lv_emp_data_row||lv_state_data_sum;

                       if p_output_file_type = 'HTML' then
                           lv_data_row := '<tr>'||lv_data_row||'</tr>';
                       end if;
                       FND_FILE.PUT_LINE(FND_FILE.OUTPUT,lv_data_row);
                   END LOOP;
                END IF;

   END IF;

   IF (p_jurisdiction_level = '03' and p_detail_level = '02') then
     hr_utility.trace('Inside FINAL write out for COUNTY');
     lv_emp_data_row := lv_data_row;

     IF county_bal.count>0 THEN
       FOR j in county_bal.first..county_bal.last LOOP
          county_static_data(county_bal(j).gre_name,
                             county_bal(j).jurisdiction_code,
                             county_bal(j).jurisdiction_name,
                             county_bal(j).county_gross,
                             county_bal(j).county_reduced_subject,
                             county_bal(j).county_withheld,
                             county_bal(j).county_head_tax_withheld,
                             '',
                             p_output_file_type,
                             lv_county_data_sum);

              lv_data_row := lv_emp_data_row||lv_county_data_sum;

              if p_output_file_type = 'HTML' then
                 lv_data_row := '<tr>'||lv_data_row||'</tr>';
              end if;
              FND_FILE.PUT_LINE(FND_FILE.OUTPUT,lv_data_row);
       END LOOP;
     END IF; -- county_bal.count
    END IF;

    IF (p_jurisdiction_level = '04' and p_detail_level = '02') then
     hr_utility.trace('Inside FINAL write out for CITY');
      lv_emp_data_row := lv_data_row;

      IF city_bal.count>0 THEN
        FOR j in city_bal.first..city_bal.last LOOP
           city_static_data(city_bal(j).gre_name,
                            city_bal(j).jurisdiction_code,
                            city_bal(j).jurisdiction_name,
                            city_bal(j).city_gross,
                            city_bal(j).city_reduced_subject,
                            city_bal(j).city_withheld,
                            city_bal(j).head_tax_withheld,
                            '',
                            p_output_file_type,
                            lv_city_data_sum);

           lv_data_row := lv_emp_data_row||lv_city_data_sum;

           if p_output_file_type = 'HTML' then
             lv_data_row := '<tr>'||lv_data_row||'</tr>';
           end if;
           FND_FILE.PUT_LINE(FND_FILE.OUTPUT,lv_data_row);
        END LOOP;
      END IF; -- city_bal.count
    END IF;

   IF (p_jurisdiction_level = '05' and p_detail_level = '02') then
     hr_utility.trace('Inside FINAL write out for SCHOOL');
     lv_emp_data_row := lv_data_row;

     IF school_bal.count>0 THEN
       FOR j in school_bal.first..school_bal.last LOOP
          school_static_data(school_bal(j).gre_name,
                             school_bal(j).jurisdiction_code,
                             school_bal(j).jurisdiction_name,
                             school_bal(j).school_gross,
                             school_bal(j).school_reduced_subject,
                             school_bal(j).school_withheld,
                             p_output_file_type,
                             lv_school_data_sum);

          lv_data_row := lv_emp_data_row||lv_school_data_sum;

          if p_output_file_type = 'HTML' then
              lv_data_row := '<tr>'||lv_data_row||'</tr>';
          end if;
          FND_FILE.PUT_LINE(FND_FILE.OUTPUT,lv_data_row);
       END LOOP;
     END IF; -- school_bal.count
    END IF;

   if p_output_file_type ='HTML' then
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '</table></body></html>');
   end if;
   hr_utility.trace('Concurrent Request ID = ' || FND_GLOBAL.CONC_REQUEST_ID);

   /**********************************************************
   ** Not Required as the output file type is HTML by default
   ***********************************************************/

   if p_output_file_type ='HTML' then
      update fnd_concurrent_requests
         set output_file_type = 'HTML'
       where request_id = FND_GLOBAL.CONC_REQUEST_ID ;

      commit;
   end if;

 END ;

--BEGIN
--  hr_utility.trace_on('Y', 'EMPPDTL');
END pay_archiver_report_pkg;

/
