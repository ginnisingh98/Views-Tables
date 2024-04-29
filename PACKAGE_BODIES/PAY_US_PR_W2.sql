--------------------------------------------------------
--  DDL for Package Body PAY_US_PR_W2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_US_PR_W2" AS
/* $Header: pyusprw2.pkb 120.7.12010000.3 2008/11/13 06:41:35 skpatil ship $*/
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

    Name        : pay_us_pr_w2
    Description : This package is called by the Puerto Rico W2 Totals and
                  Exceptions Report

                   - CSV

   Change List
    -----------
     Date        Name      Vers   Bug No  Description
     ----        ----      ------ ------- -----------
     22-AUG-2002 Fusman    115.0          Created.
     27-AUG-2002 Fusman    115.1          Changed the seq number.
     16-SEP-2002 ahanda    115.2          Changed report titles to use gv_title
                                          and gv_title2.
     19-SEP-2002 Fusman    115.3          Fix for bug:2585617. Added sum to the totals.
     20-SEP-2002 Fusman    115.4          Fix for bug:2585617. Changed header for SS Tips.
     22-SEP-2002 JGoswami  115.5
     14-AUG-2003 Jgoswami  115.6  2778370 Added code for
                                          Puerto Rico W2 Register Report
                                          Modified code for Total Report.
     15-AUG-2003 Jgoswami  115.7          Added Pension to the Total Report.
     25-AUG-2003 JGoswami  115.8          Changed the Total Report format
                                          from csv to html.
                                          Removed employer header and
                                          employer data functions.
     03-sep-2003 JGoswami  115.9 3097463  added r_type to store datatype of r_value.
                                 3125120  added ername, ein and year to register and exception report.
                                 3122224  modified to show the correct totals for
                                          Medicare Wages & Tips ,Medicare Taxes Withheld and
                                          Social Security Tips.
     09-sep-2003 JGoswami 115.10 3125120  Modified Format for Number to 999,999,999,999,990.00
     12-JAN-2003 JGoswami 115.11 3347535  Modified the package to report Employeer's and Employee Address on Register, Exception and Totals Report
     07-JAN-2008 PSUGUMAR 115.12 5855662  Modified the package to include employee number,compensation code,location
     11-Jan-2008 vmkulkar 115.15	  Added escape symbol before nbsp
     30-Jan-2008 psugumar 115.17 6782741  Uncommented all the fields to display the missing fields
     30-Jan-2008 jgoswami 115.18 6782741  Modified package to remove extra SSN
     13-Nov-2008 skpatil  115.19 7566756  Modified employee_data() to format Employer ID#
*/


  /************************************************************
  ** Local Package Variables
  ************************************************************/
  gv_title               VARCHAR2(100) := 'W-3 PR Transmittal of Withholding Statements';
  gv_title2              VARCHAR2(100) := 'Puerto Rico W2 Exceptions Report ';
  gv_title3              VARCHAR2(100) := 'Puerto Rico W2 Register Report ';
  gc_csv_delimiter       VARCHAR2(1) := ',';
  gc_csv_data_delimiter  VARCHAR2(1) := '"';

  gv_html_start_data     VARCHAR2(50) := '<td>'  ;
  gv_html_end_data       VARCHAR2(5) := '</td>' ;

  gv_package_name        VARCHAR2(50) := 'pay_us_pr_w2';

  total_rec_tab  tab_rec_total;



  /******************************************************************
  ** Function Returns the formated input string based on the
  ** Output format. If the format is CSV then the values are returned
  ** seperated by comma (,).
  ******************************************************************/

  FUNCTION formated_data_string
             (p_input_string     in varchar2
              ,p_bold            in varchar2 default 'N'
              ,p_type           in varchar2
             ,p_output_file_type in varchar2
             )
  RETURN VARCHAR2
  IS

    lv_format          varchar2(32000);

  BEGIN
    hr_utility.set_location(gv_package_name || '.formated_data_string', 10);

    if p_output_file_type = 'CSV' then


       hr_utility.set_location(gv_package_name || '.formated_data_string', 20);

         lv_format := gc_csv_data_delimiter || p_input_string ||
                           gc_csv_data_delimiter || gc_csv_delimiter;

    elsif p_output_file_type = 'HTML' then

     if p_type = 'C' then
             gv_html_start_data := '<td align="left">';
     elsif p_type = 'N' then
             gv_html_start_data := '<td align="right">';

     else
             gv_html_start_data := '<td align="left">';

     end if;

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
       lv_format := '<HTML><HEAD> <H1> <B>' || p_input_string ||
                             '</B></H1></HEAD>';
    end if;


    hr_utility.set_location(gv_package_name || '.formated_header_string', 40);
    return lv_format;

  END formated_header_string;

  /*****************************************************************
  ** This procudure returns the Mandatory Static Labels and the
  ** Other Additional Static columns.
  *****************************************************************/

/* This function is used to write the headers for Puerto Rico W2 Exception */

  FUNCTION employee_header(
              p_output_file_type  in varchar2,
              p_header            in varchar2,
              p_report_type       in varchar2
             )
 RETURN VARCHAR2
  IS

    lv_format1          varchar2(32000);
    lv_format2          varchar2(32000);

  BEGIN

      hr_utility.set_location(gv_package_name || '.formated_static_header', 10);
      IF p_header = 'Header1' THEN


       if p_report_type = 'PRW2EXCEPTION' then
         lv_format1 := formated_data_string (p_input_string => gv_title2
                                   ,p_bold         => 'Y'
                                   ,p_type         => 'C'
                                   ,p_output_file_type => p_output_file_type);

       elsif p_report_type = 'PRW2REGISTER' then
         lv_format1 := formated_data_string (p_input_string => gv_title3
                                   ,p_bold         => 'Y'
                                   ,p_type         => 'C'
                                   ,p_output_file_type => p_output_file_type);

       end if;

      ELSE
--5855662 Changed for employee file header format
         lv_format1 :=
              formated_data_string (p_input_string => 'Social Security Number'
                                   ,p_bold         => 'Y'
                                   ,p_type         => 'C'
                                   ,p_output_file_type => p_output_file_type) ||

/*
              formated_data_string (p_input_string => 'Social Security Number'
                                   ,p_bold         => 'Y'
                                   ,p_type         => 'C'
                                   ,p_output_file_type => p_output_file_type) ||

*/
              formated_data_string (p_input_string => 'Employee Number'
                                   ,p_bold         => 'Y'
                                   ,p_type         => 'C'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => 'Inactive'
                                   ,p_bold         => 'Y'
                                   ,p_type         => 'C'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => 'First Name'
                                   ,p_bold         => 'Y'
                                   ,p_type         => 'C'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => 'Last Name'
                                   ,p_bold         => 'Y'
                                   ,p_type         => 'C'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => 'Address Line1'
                                   ,p_bold         => 'Y'
                                   ,p_type         => 'C'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => 'Address Line2'
                                   ,p_bold         => 'Y'
                                   ,p_type         => 'C'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => 'Address Line3'
                                   ,p_bold         => 'Y'
                                   ,p_type         => 'C'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => 'City'
                                   ,p_bold         => 'Y'
                                   ,p_type         => 'C'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => 'State'
                                   ,p_bold         => 'Y'
                                   ,p_type         => 'C'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => 'ZIP'
                                   ,p_bold         => 'Y'
                                   ,p_type         => 'C'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => 'Country'
                                   ,p_bold         => 'Y'
                                   ,p_type         => 'C'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => 'Marital Status'
                                   ,p_bold         => 'Y'
                                   ,p_type         => 'C'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => 'Chauffeur Insurance'
                                   ,p_bold         => 'Y'
                                   ,p_type         => 'C'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => 'Household Employee'
                                   ,p_bold         => 'Y'
                                   ,p_type         => 'C'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => 'Driver''s License'
                                   ,p_bold         => 'Y'
                                   ,p_type         => 'C'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => 'Blank'
                                   ,p_bold         => 'Y'
                                   ,p_type         => 'C'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => 'Prior Retirement'
                                   ,p_bold         => 'Y'
                                   ,p_type         => 'C'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => 'Workmen''s Compensation Code'
                                   ,p_bold         => 'Y'
                                   ,p_type         => 'C'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => 'Agricultural'
                                   ,p_bold         => 'Y'
                                   ,p_type         => 'C'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => 'Blank'
                                   ,p_bold         => 'Y'
                                   ,p_type         => 'C'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => 'Location'
                                   ,p_bold         => 'Y'
                                   ,p_type         => 'C'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => 'Whole Name'
                                   ,p_bold         => 'Y'
                                   ,p_type         => 'C'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => 'Pension Date'
                                   ,p_bold         => 'Y'
                                   ,p_type         => 'C'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => 'Employer Name'
                                   ,p_bold         => 'Y'
                                   ,p_type         => 'C'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => 'Employer''s Identification Number'
                                   ,p_bold         => 'Y'
                                   ,p_type         => 'C'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => 'Employer''s Address Line1'
                                   ,p_bold         => 'Y'
                                   ,p_type         => 'C'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => 'Employer''s Address Line2'
                                   ,p_bold         => 'Y'
                                   ,p_type         => 'C'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => 'Employer''s Address Line3'
                                   ,p_bold         => 'Y'
                                   ,p_type         => 'C'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => 'Employer''s City'
                                   ,p_bold         => 'Y'
                                   ,p_type         => 'C'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => 'Employer''s State'
                                   ,p_bold         => 'Y'
                                   ,p_type         => 'C'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => 'Employer''s ZIP'
                                   ,p_bold         => 'Y'
                                   ,p_type         => 'C'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => 'Employer''s Phone'
                                   ,p_bold         => 'Y'
                                   ,p_type         => 'C'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => 'Year'
                                   ,p_bold         => 'Y'
                                   ,p_type         => 'C'
                                   ,p_output_file_type => p_output_file_type) ||

              formated_data_string (p_input_string => 'Surnames'
                                   ,p_bold         => 'Y'
                                   ,p_type         => 'C'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => 'Civil Status'
                                   ,p_bold         => 'Y'
                                   ,p_type         => 'C'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => 'Spouse''s Social Security Number'
                                   ,p_bold         => 'Y'
                                   ,p_type         => 'C'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => 'Pension'
                                   ,p_bold         => 'Y'
                                   ,p_type         => 'C'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => 'Wages'
                                   ,p_bold         => 'Y'
                                   ,p_type         => 'C'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string =>  'Commissions'
                                   ,p_bold         => 'Y'
                                   ,p_type         => 'C'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => 'Allowances'
                                   ,p_bold         => 'Y'
                                   ,p_type         => 'C'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => 'Tips'
                                   ,p_bold         => 'Y'
                                   ,p_type         => 'C'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => 'Total'
                                   ,p_bold         => 'Y'
                                   ,p_type         => 'C'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => 'Reimbursed Expenses'
                                   ,p_bold         => 'Y'
                                   ,p_type         => 'C'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => 'Tax Withheld '
                                   ,p_bold         => 'Y'
                                   ,p_type         => 'C'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => 'Retirement Fund'
                                   ,p_bold         => 'Y'
                                   ,p_type         => 'C'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => 'Contributions to CODA PLANS'
                                   ,p_bold         => 'Y'
                                   ,p_type         => 'C'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => 'Soc.Security Wages'
                                   ,p_bold         => 'Y'
                                   ,p_type         => 'C'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => 'Soc. Sec Tax Withheld'
                                   ,p_bold         => 'Y'
                                   ,p_type         => 'C'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => 'Medicare Wages and Tips'
                                   ,p_bold         => 'Y'
                                   ,p_type         => 'C'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => 'Medicare Tax Withheld'
                                   ,p_bold         => 'Y'
                                   ,p_type         => 'C'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => 'Social Security Tips'
                                   ,p_bold         => 'Y'
                                   ,p_type         => 'C'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => 'Soc. Sec. Tax on Tips'
                                   ,p_bold         => 'Y'
                                   ,p_type         => 'C'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => 'Medicare Tax on Tips'
                                   ,p_bold         => 'Y'
                                   ,p_type         => 'C'
                                   ,p_output_file_type => p_output_file_type) ;

      END IF;



  RETURN (lv_format1);
  END;

  FUNCTION get_blanks(p_length in number)
  RETURN VARCHAR2
  IS
  BEGIN
   return(lpad(' ',p_length,' '));
  END;
  FUNCTION format_data(p_data in varchar2,p_length in number)
  RETURN VARCHAR2
  IS
  BEGIN
   return(lpad(substr(p_data,1,p_length),p_length,' '));
  END;

  FUNCTION employee_data (
                   p_tax_unit_name             in varchar2
                  ,p_ein                       in varchar2
                  ,p_er_addr_line_1            in varchar2
                  ,p_er_addr_line_2            in varchar2
                  ,p_er_addr_line_3            in varchar2
                  ,p_er_addr_city              in varchar2
                  ,p_er_addr_state             in varchar2
                  ,p_er_addr_zip               in varchar2
                  ,p_er_phone                  in varchar2
                  ,p_year                      in varchar2
                  ,p_first_name                in varchar2
                  ,p_surname                   in varchar2
                  ,p_ee_addr_line_1            in varchar2
                  ,p_ee_addr_line_2            in varchar2
                  ,p_ee_addr_line_3            in varchar2
                  ,p_ee_addr_city              in varchar2
                  ,p_ee_addr_state             in varchar2
                  ,p_ee_addr_zip               in varchar2
                  ,p_ee_addr_country           in varchar2
                  ,p_een                       in varchar2
                  ,p_eewc                      in varchar2
                  ,p_eeloc                     in varchar2
                  ,p_ssn                       in varchar2
                  ,p_status                    in varchar2
                  ,p_spouse_ssn                in varchar2
                  ,p_Pension                   in number
                  ,p_Wages                     in number
                  ,p_Commissions               in number
                  ,p_Allowances                in number
                  ,p_Tips                      in number
                  ,p_Total                     in number
                  ,p_Reimb_exp                 in number
                  ,p_Tax_wh                    in number
                  ,p_Retir_fund                in number
                  ,p_Coda_plan                 in number
                  ,p_SS_Wages                  in number
                  ,p_SS_tax                    in number
                  ,p_Med_wages                 in number
                  ,p_Med_tax                   in number
                  ,p_SS_Tips                   in number
                  ,p_SS_Tax_on_tips            in number
                  ,p_Med_Tax_on_tips           in number
                  ,p_output_file_type          in varchar2 )

RETURN VARCHAR2
  IS

    lv_format1 VARCHAR2(32000);
    lv_format2 VARCHAR2(32000);


  BEGIN

      hr_utility.set_location(gv_package_name || '.formated_static_data', 10);
      hr_utility.trace('ER Name = '||p_tax_unit_name);
      hr_utility.trace('EIN = '||p_ein);
      hr_utility.trace('Year = '||p_year);
      hr_utility.trace('EE Name = '||p_first_name);
--5855662 Changed for employee file format
--7566756 Formatted p_ein
      lv_format1 :=
              formated_data_string (p_input_string => format_data(replace(p_ssn,'-',''),9)
                                   ,p_type         => 'C'
                                   ,p_output_file_type => p_output_file_type)||
/*
              formated_data_string (p_input_string => format_data(p_ssn,9)
                                   ,p_type         => 'C'
                                   ,p_output_file_type => p_output_file_type)||
*/
              formated_data_string (p_input_string => format_data(p_een,30)
                                   ,p_type         => 'C'
                                   ,p_output_file_type => p_output_file_type)||
              formated_data_string (p_input_string => get_blanks(1)
                                   ,p_type         => 'C'
                                   ,p_output_file_type => p_output_file_type)||
              formated_data_string (p_input_string => format_data(p_first_name,14)
                                   ,p_type         => 'C'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => format_data(p_surname,20)
                                   ,p_type         => 'C'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => format_data(p_ee_addr_line_1,35)
                                   ,p_type         => 'N'
                                   ,p_output_file_type => p_output_file_type)||
              formated_data_string (p_input_string => format_data(p_ee_addr_line_2,35)
                                   ,p_type         => 'N'
                                   ,p_output_file_type => p_output_file_type)||
              formated_data_string (p_input_string => p_er_addr_line_3
                                   ,p_type         => 'N'
                                   ,p_output_file_type => p_output_file_type)||
              formated_data_string (p_input_string => format_data(p_ee_addr_city,24)
                                   ,p_type         => 'N'
                                   ,p_output_file_type => p_output_file_type)||
              formated_data_string (p_input_string => format_data(p_ee_addr_state,2)
                                   ,p_type         => 'N'
                                   ,p_output_file_type => p_output_file_type)||
              formated_data_string (p_input_string => format_data(p_ee_addr_zip,10)
                                   ,p_type         => 'N'
                                   ,p_output_file_type => p_output_file_type)||
              formated_data_string (p_input_string => p_ee_addr_country
                                   ,p_type         => 'N'
                                   ,p_output_file_type => p_output_file_type)||
              formated_data_string (p_input_string => p_status
                                   ,p_type         => 'C'
                                   ,p_output_file_type => p_output_file_type)||
              formated_data_string (p_input_string => get_blanks(1)
                                   ,p_type         => 'C'
                                   ,p_output_file_type => p_output_file_type)||
              formated_data_string (p_input_string => get_blanks(1)
                                   ,p_type         => 'C'
                                   ,p_output_file_type => p_output_file_type)||
              formated_data_string (p_input_string => get_blanks(10)
                                   ,p_type         => 'C'
                                   ,p_output_file_type => p_output_file_type)||
              formated_data_string (p_input_string => get_blanks(1)
                                   ,p_type         => 'C'
                                   ,p_output_file_type => p_output_file_type)||
              formated_data_string (p_input_string => get_blanks(9)
                                   ,p_type         => 'N'
                                   ,p_output_file_type => p_output_file_type)||
              formated_data_string (p_input_string => format_data(p_eewc,4)
                                   ,p_type         => 'C'
                                   ,p_output_file_type => p_output_file_type)||
              formated_data_string (p_input_string => get_blanks(1)
                                   ,p_type         => 'C'
                                   ,p_output_file_type => p_output_file_type)||
              formated_data_string (p_input_string => get_blanks(1)
                                   ,p_type         => 'C'
                                   ,p_output_file_type => p_output_file_type)||
              formated_data_string (p_input_string =>  format_data(p_eeloc,20)
                                   ,p_type         => 'C'
                                   ,p_output_file_type => p_output_file_type)||
              formated_data_string (p_input_string =>  format_data(p_first_name||','||p_surname,35)
                                   ,p_type         => 'C'
                                   ,p_output_file_type => p_output_file_type)||
              formated_data_string (p_input_string =>  format_data(' ',8)
                                   ,p_type         => 'C'
                                   ,p_output_file_type => p_output_file_type)||
              formated_data_string (p_input_string => p_tax_unit_name
                                   ,p_type         => 'C'
                                   ,p_output_file_type => p_output_file_type)||
   -- 7566756  formatted employer id # to 9 characters with no hyphen
              formated_data_string (p_input_string => format_data(replace(p_ein,'-',''),9)
                                   ,p_type         => 'N'
                                   ,p_output_file_type => p_output_file_type)||
              formated_data_string (p_input_string => p_er_addr_line_1
                                   ,p_type         => 'N'
                                   ,p_output_file_type => p_output_file_type)||
              formated_data_string (p_input_string => p_er_addr_line_2
                                   ,p_type         => 'N'
                                   ,p_output_file_type => p_output_file_type)||
              formated_data_string (p_input_string => p_er_addr_line_3
                                   ,p_type         => 'N'
                                   ,p_output_file_type => p_output_file_type)||
              formated_data_string (p_input_string => p_er_addr_city
                                   ,p_type         => 'N'
                                   ,p_output_file_type => p_output_file_type)||
              formated_data_string (p_input_string => p_er_addr_state
                                   ,p_type         => 'N'
                                   ,p_output_file_type => p_output_file_type)||
              formated_data_string (p_input_string => p_er_addr_zip
                                   ,p_type         => 'N'
                                   ,p_output_file_type => p_output_file_type)||
              formated_data_string (p_input_string => p_er_phone
                                   ,p_type         => 'N'
                                   ,p_output_file_type => p_output_file_type)||
              formated_data_string (p_input_string => p_year
                                   ,p_type         => 'N'
                                   ,p_output_file_type => p_output_file_type)||
              formated_data_string (p_input_string => p_surname
                                   ,p_type         => 'C'
                                   ,p_output_file_type => p_output_file_type)||
              formated_data_string (p_input_string => p_status
                                   ,p_type         => 'C'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => p_spouse_ssn
                                   ,p_type         => 'C'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => to_char(p_pension,'999,999,999,999,990.00')
                                   ,p_type         => 'N'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => to_char(p_Wages,'999,999,999,999,990.00')
                                   ,p_type         => 'N'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => to_char(p_Commissions,'999,999,999,999,990.00')
                                   ,p_type         => 'N'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => to_char(p_Allowances,'999,999,999,999,990.00')
                                   ,p_type         => 'N'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => to_char(p_Tips,'999,999,999,999,990.00')
                                   ,p_type         => 'N'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => to_char(p_Total,'999,999,999,999,990.00')
                                   ,p_type         => 'N'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => to_char(p_Reimb_exp,'999,999,999,999,990.00')
                                   ,p_type         => 'N'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => to_char(p_Tax_wh,'999,999,999,999,990.00')
                                   ,p_type         => 'N'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => to_char(p_Retir_fund,'999,999,999,999,990.00')
                                   ,p_type         => 'N'
                                   ,p_output_file_type => p_output_file_type)||
              formated_data_string (p_input_string => to_char(p_Coda_plan,'999,999,999,999,990.00')
                                   ,p_type         => 'N'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => to_char(p_SS_Wages ,'999,999,999,999,990.00')
                                   ,p_type         => 'N'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => to_char(p_SS_tax,'999,999,999,999,990.00')
                                   ,p_type         => 'N'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => to_char(p_Med_wages,'999,999,999,999,990.00')
                                   ,p_type         => 'N'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => to_char(p_Med_tax ,'999,999,999,999,990.00')
                                   ,p_type         => 'N'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => to_char(p_SS_Tips ,'999,999,999,999,990.00')
                                   ,p_type         => 'N'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => to_char(p_SS_Tax_on_tips,'999,999,999,999,990.00')
                                   ,p_type         => 'N'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => to_char(p_Med_Tax_on_tips,'999,999,999,999,990.00')
                                   ,p_type         => 'N'
                                   ,p_output_file_type => p_output_file_type) ;

      hr_utility.set_location(gv_package_name || '.formated_static_data', 20);


      hr_utility.trace('Static Data1 = ' || lv_format1);
      hr_utility.set_location(gv_package_name || '.formated_static_data', 40);

      return (lv_format1);
  END;


PROCEDURE insert_pr_w2_totals(errbuf        OUT nocopy    VARCHAR2,
                       retcode              OUT nocopy    NUMBER,
                       p_seq_num            IN      VARCHAR2,
                       p_report_type        IN      VARCHAR2) is

     cursor c_er_total (c_seq_num in VARCHAR2,p_report_type in VARCHAR2) is
     SELECT
            attribute8 er_name,
            attribute9 ein,
            attribute11 er_addr_line_1,
            attribute12 er_addr_line_2,
            attribute13 er_addr_line_3,
            attribute14 er_addr_city,
            attribute15 er_addr_state,
            attribute16 er_addr_zip,
            attribute17 er_phone,
            attribute10 year,
            sum(value1) pension,
            sum(value2) wages,
            sum(value3) commissions,
            sum(value4) allowances,
            sum(value5) tips,
            sum(value6) total,
            sum(value7) reimb,
            sum(value8) tax,
            sum(value9) ret_fund,
            sum(value10) coda,
            sum(value11) ss_wages,
            sum(value12) ss_tax,
            sum(value13) med_wages,
            sum(value14) med_tax,
            sum(value15) ss_tips,
            sum(value16) ss_tax_on_tips,
            sum(value17) med_tax_on_tips
     FROM   pay_us_rpt_totals
     WHERE  attribute2 = p_report_type
     AND   session_id = to_number(p_seq_num)
     GROUP BY attribute8,attribute9, attribute11,attribute12,attribute13,attribute14,attribute15,attribute16,attribute17,attribute10;


     cursor c_ee_exception (c_seq_num in VARCHAR2,p_report_type in VARCHAR2) is
     SELECT
            attribute8 er_name,
            attribute9 ein,
            attribute11 er_addr_line_1,
            attribute12 er_addr_line_2,
            attribute13 er_addr_line_3,
            attribute14 er_addr_city,
            attribute15 er_addr_state,
            attribute16 er_addr_zip,
            attribute17 er_phone,
            attribute10 year,
            attribute3 ee_name,
            attribute4 ee_last_name,
            attribute18 ee_addr_line_1,
            attribute19 ee_addr_line_2,
            attribute20 ee_addr_line_3,
            attribute21 ee_addr_city,
            attribute22 ee_addr_state,
            attribute23 ee_addr_zip,
            attribute24 ee_addr_country,
            attribute25 ee_number,
            attribute26 ee_wc,
            attribute27 ee_loc,
            attribute5 ssn, --Change 5855662
            attribute6 status,
            attribute7 spouse_ssn,
            value1 pension,
            value2 wages,
            value3 commissions,
            value4 allowances,
            value5 tips,
            value6 total,
            value7 reimb,
            value8 tax,
            value9 ret_fund,
            value10 coda,
            value11 ss_wages,
            value12 ss_tax,
            value13 med_wages,
            value14 med_tax,
            value15 ss_tips,
            value16 ss_tax_on_tips,
            value17 med_tax_on_tips
     FROM   pay_us_rpt_totals
     WHERE  attribute2 = p_report_type
     AND    session_id = to_number(p_seq_num);

      TYPE numeric_table IS TABLE OF number(20,2)
                           INDEX BY BINARY_INTEGER;

      TYPE text_table IS TABLE OF varchar2(2000)
                           INDEX BY BINARY_INTEGER;

     ee_first_name       varchar2(240);
     ee_last_name        varchar2(240);
     ee_ssn              varchar2(240);
     ee_n                varchar2(240);
     ee_status           varchar2(240);
     ee_spouse_ssn       varchar2(240);
     ee_wages            number(22,2) := 0.00;
     ee_pension          number(22,2) := 0.00;
     ee_commissions      number(22,2) := 0.00;
     ee_allowances       number(22,2) := 0.00;
     ee_tips             number(22,2) := 0.00;
     ee_total            number(22,2) := 0.00;
     ee_reimb            number(22,2) := 0.00;
     ee_tax              number(22,2) := 0.00;
     ee_ret_fund         number(22,2) := 0.00;
     ee_coda             number(22,2) := 0.00;
     ee_ss_wages         number(22,2) := 0.00;
     ee_ss_Tax           number(22,2) := 0.00;
     ee_ss_tips          number(22,2) := 0.00;
     ee_med_Wages        number(22,2) := 0.00;
     ee_med_tax          number(22,2) := 0.00;
     ee_ss_tax_on_tips   number(22,2) := 0.00;
     ee_med_tax_on_tips  number(22,2) := 0.00;
     er_name             varchar2(240);
     er_ein              varchar2(240);
     year                varchar2(240);
     er_addr_line_1       varchar2(50);
     er_addr_line_2       varchar2(50);
     er_addr_line_3       varchar2(50);
     er_addr_city       varchar2(50);
     er_addr_state       varchar2(50);
     er_addr_zip       varchar2(50);
     er_phone       varchar2(50);
     ee_addr_line_1       varchar2(50);
     ee_addr_line_2       varchar2(50);
     ee_addr_line_3       varchar2(50);
     ee_addr_city       varchar2(50);
     ee_addr_state       varchar2(50);
     ee_addr_zip       varchar2(50);
     ee_addr_country       varchar2(50);
     ee_wc             varchar2(20);
     ee_loc            varchar2(60);
     l_output_file_type  varchar2(10);
     i number(2);
     j number(2);
     ln_count number(2);

BEGIN

--   hr_utility.trace_on(null, 'PRW2');
     hr_utility.trace('Entered Main package');
     hr_utility.trace('p_seq_num = '||p_seq_num);
     hr_utility.trace('p_report_type = '||p_report_type);

/*  report_type
    PRW2REGISTER - Register Report
    PRW2TOTAL - Total Report
    PRW2EXCEPTION - Exception Report
*/

  If p_report_type = 'PRW2TOTAL' then

     l_output_file_type := 'HTML';

     /* Modified report to insert records with
        report_type of 'PRW2REGISTER' for employee
        detail and we can have the Total as a SUM
        from the detail records. So now we are not
        inserting seperate SUM and hence passing the
        report type of 'PRW2REGISTER'
     */

         i := 0;

     open c_er_total(p_seq_num,'PRW2REGISTER');
     hr_utility.trace ('Opened c_er_total cursor');

     fetch c_er_total into    er_name,
                              er_ein,
                              er_addr_line_1,
                              er_addr_line_2,
                              er_addr_line_3,
                              er_addr_city,
                              er_addr_state,
                              er_addr_zip,
                              er_phone,
                              year,
                              ee_pension,
                              ee_wages,
                              ee_commissions,
                              ee_allowances,
                              ee_tips,
                              ee_total,
                              ee_reimb,
                              ee_tax,
                              ee_ret_fund,
                              ee_coda,
                              ee_ss_wages,
                              ee_ss_Tax,
                              ee_med_Wages,
                              ee_med_tax,
                              ee_ss_tips,
                              ee_ss_tax_on_tips,
                              ee_med_tax_on_tips;

       if c_er_total%NOTFOUND then

          hr_utility.trace('No total information found for seq num = '||p_seq_num);

       else

          er_name := replace(er_name,',');

          hr_utility.trace('wages ='||ee_wages);
          hr_utility.trace('commissions ='||ee_commissions);
          hr_utility.trace('allowances ='||ee_allowances);
          hr_utility.trace('tips ='||ee_tips);
          hr_utility.trace('total ='||ee_total);
          hr_utility.trace('reimb ='||ee_reimb);
          hr_utility.trace('tax ='||ee_tax);
          hr_utility.trace('ret_fund ='||ee_ret_fund);
          hr_utility.trace('coda ='||ee_coda);
          hr_utility.trace('ss_wages ='||ee_ss_wages);
          hr_utility.trace('ss_Tax ='||ee_ss_Tax);
          hr_utility.trace('ss_tips ='||ee_ss_tips);
          hr_utility.trace('med_Wages ='||ee_med_Wages);
          hr_utility.trace('med_tax ='||ee_med_tax);
          hr_utility.trace('ss_tax_on_tips ='||ee_ss_tax_on_tips);
          hr_utility.trace('med_tax_on_tips='||ee_med_tax_on_tips);


                                 i := i+1;
          total_rec_tab(i).r_label := 'Employer Name';
          total_rec_tab(i).r_value := er_name;
          total_rec_tab(i).r_type  := 'C';
                                 i := i+1;
          total_rec_tab(i).r_label := 'Employer''s Address Line1';
          total_rec_tab(i).r_value := er_addr_line_1;
          total_rec_tab(i).r_type  := 'C';
                                 i := i+1;
          total_rec_tab(i).r_label := 'Employer''s Address Line2';
          total_rec_tab(i).r_value := er_addr_line_2;
          total_rec_tab(i).r_type  := 'C';
                                 i := i+1;
          total_rec_tab(i).r_label := 'Employer''s Address Line3';
          total_rec_tab(i).r_value := er_addr_line_3;
          total_rec_tab(i).r_type  := 'C';
                                 i := i+1;
          total_rec_tab(i).r_label := 'Employer''s City';
          total_rec_tab(i).r_value := er_addr_city;
          total_rec_tab(i).r_type  := 'C';
                                 i := i+1;
          total_rec_tab(i).r_label := 'Employer''s State';
          total_rec_tab(i).r_value := er_addr_state;
          total_rec_tab(i).r_type  := 'C';
                                 i := i+1;
          total_rec_tab(i).r_label := 'Employer''s ZIP';
          total_rec_tab(i).r_value := er_addr_zip;
          total_rec_tab(i).r_type  := 'C';
                                 i := i+1;
          total_rec_tab(i).r_label := 'Employer''s Phone';
          total_rec_tab(i).r_value := er_phone;
          total_rec_tab(i).r_type  := 'C';
                                 i := i+1;
          total_rec_tab(i).r_label := 'Year';
          total_rec_tab(i).r_value := year;
          total_rec_tab(i).r_type  := 'N';
                                 i := i+1;
          total_rec_tab(i).r_label := 'Employer''s Identification Number';
          total_rec_tab(i).r_value := er_ein;
          total_rec_tab(i).r_type  := 'N';
                                 i := i+1;
          total_rec_tab(i).r_label := 'Pension';
          total_rec_tab(i).r_value := to_char(ee_pension,'999,999,999,999,990.00');
          total_rec_tab(i).r_type  := 'N';
                                 i := i+1;
          total_rec_tab(i).r_label := 'Wages';
          total_rec_tab(i).r_value := to_char(ee_wages,'999,999,999,999,990.00');
          total_rec_tab(i).r_type  := 'N';
                                 i := i+1;
          total_rec_tab(i).r_label := 'Commissions';
          total_rec_tab(i).r_value := to_char(ee_commissions,'999,999,999,999,990.00');
          total_rec_tab(i).r_type  := 'N';
                                 i := i+1;
          total_rec_tab(i).r_label := 'Allowances';
          total_rec_tab(i).r_value := to_char(ee_allowances,'999,999,999,999,990.00');
          total_rec_tab(i).r_type  := 'N';
                                 i := i+1;
          total_rec_tab(i).r_label := 'Tips';
          total_rec_tab(i).r_value := to_char(ee_tips,'999,999,999,999,990.00');
          total_rec_tab(i).r_type  := 'N';
                                 i := i+1;
          total_rec_tab(i).r_label := 'Total';
          total_rec_tab(i).r_value := to_char(ee_total,'999,999,999,999,990.00');
          total_rec_tab(i).r_type  := 'N';
                                 i := i+1;
          total_rec_tab(i).r_label := 'Reimbursed Expenses';
          total_rec_tab(i).r_value := to_char(ee_reimb,'999,999,999,999,990.00');
          total_rec_tab(i).r_type  := 'N';
                                 i := i+1;
          total_rec_tab(i).r_label := 'Tax Withheld';
          total_rec_tab(i).r_value := to_char(ee_tax,'999,999,999,999,990.00');
          total_rec_tab(i).r_type  := 'N';
                                 i := i+1;
          total_rec_tab(i).r_label := 'Retirement Fund';
          total_rec_tab(i).r_value := to_char(ee_ret_fund,'999,999,999,999,990.00');
          total_rec_tab(i).r_type  := 'N';
                                 i := i+1;
          total_rec_tab(i).r_label := 'Contributions to CODA PLANS';
          total_rec_tab(i).r_value := to_char(ee_coda,'999,999,999,999,990.00');
          total_rec_tab(i).r_type  := 'N';
                                 i := i+1;
          total_rec_tab(i).r_label := 'Soc.Security Wages';
          total_rec_tab(i).r_value := to_char(ee_ss_wages,'999,999,999,999,990.00');
          total_rec_tab(i).r_type  := 'N';
                                 i := i+1;
          total_rec_tab(i).r_label := 'Soc. Sec Tax Withheld';
          total_rec_tab(i).r_value := to_char(ee_ss_Tax,'999,999,999,999,990.00');
          total_rec_tab(i).r_type  := 'N';
                                 i := i+1;
          total_rec_tab(i).r_label := 'Medicare Wages and Tips';
          total_rec_tab(i).r_value := to_char(ee_med_Wages,'999,999,999,999,990.00');
          total_rec_tab(i).r_type  := 'N';
                                 i := i+1;
          total_rec_tab(i).r_label := 'Medicare Tax Withheld';
          total_rec_tab(i).r_value := to_char(ee_med_tax,'999,999,999,999,990.00');
          total_rec_tab(i).r_type  := 'N';
                                 i := i+1;
          total_rec_tab(i).r_label := 'Social Security Tips';
          total_rec_tab(i).r_value := to_char(ee_ss_tips,'999,999,999,999,990.00');
          total_rec_tab(i).r_type  := 'N';
                                 i := i+1;
          total_rec_tab(i).r_label := 'Soc. Sec. Tax on Tips';
          total_rec_tab(i).r_value := to_char(ee_ss_tax_on_tips,'999,999,999,999,990.00');
          total_rec_tab(i).r_type  := 'N';
                                 i := i+1;
          total_rec_tab(i).r_label := 'Medicare Tax on Tips';
          total_rec_tab(i).r_value := to_char(ee_med_tax_on_tips,'999,999,999,999,990.00');
          total_rec_tab(i).r_type  := 'N';

/*
          for j in total_rec_tab.first .. total_rec_tab.last  loop
              hr_utility.trace( 'J = '|| j );
              hr_utility.trace( 'label = '||total_rec_tab(j).r_label);
              hr_utility.trace( 'value = '||total_rec_tab(j).r_value);
              hr_utility.trace( 'type = '||total_rec_tab(j).r_type);
          end loop;
*/

          hr_utility.trace( 'B4 formated header string ');
          fnd_file.put_line(fnd_file.output,
                            formated_header_string(gv_title,'HTML'));
          fnd_file.new_line(fnd_file.output,1);
          hr_utility.trace( 'A4 formated header string new line ');
         /****************************************************************
          ** Print the Header Information. If the format is HTML then open
          ** the body and table before printing the header info, otherwise
          ** just print the header information.
          ****************************************************************/
          if l_output_file_type ='HTML' then

             FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '<body>');
             FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '<table border=1>');

          for i in total_rec_tab.first .. total_rec_tab.last loop


            FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '<tr>');
            fnd_file.put_line(fnd_file.output
               ,formated_data_string(p_input_string => total_rec_tab(i).r_label
               ,p_bold         => 'Y'
               ,p_type         => 'C'
               ,p_output_file_type => l_output_file_type));

            fnd_file.put_line(fnd_file.output
               ,formated_data_string(p_input_string => total_rec_tab(i).r_value
               ,p_bold         => 'N'
               ,p_type         => total_rec_tab(i).r_type
               ,p_output_file_type => l_output_file_type));

            FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '</tr>');
            hr_utility.trace( 'label 0 = '||total_rec_tab(i).r_label);
            hr_utility.trace( 'value 0 = '||total_rec_tab(i).r_value);
            hr_utility.trace( 'value 0 = '||total_rec_tab(i).r_type);
          end loop ;

            FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '</table>');
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '</body>');
          end if;

/*
           select count(*)
           into ln_count
           FROM pay_us_rpt_totals
           WHERE attribute2 = 'PRW2REGISTER'
           AND session_id = to_number(p_seq_num);

           hr_utility.trace('Total# of Records ='||to_char(ln_count));
*/
           DELETE from pay_us_rpt_totals
           WHERE attribute2 = 'PRW2REGISTER'
           AND session_id = to_number(p_seq_num);

   end if;


     close c_er_total;

  Else
           /* Employer Totals ends and Exception employees begin. */

           OPEN c_ee_exception(p_seq_num,p_report_type);

           LOOP

           ee_pension         := 0.00;
           ee_wages           := 0.00;
           ee_commissions     := 0.00;
           ee_allowances      := 0.00;
           ee_tips            := 0.00;
           ee_total           := 0.00;
           ee_reimb           := 0.00;
           ee_tax             := 0.00;
           ee_ret_fund        := 0.00;
           ee_coda            := 0.00;
           ee_ss_wages        := 0.00;
           ee_ss_Tax          := 0.00;
           ee_ss_tips         := 0.00;
           ee_med_Wages       := 0.00;
           ee_med_tax         := 0.00;
           ee_ss_tax_on_tips  := 0.00;
           ee_med_tax_on_tips := 0.00;

           ee_first_name      := 0.00;
           ee_last_name       := 0.00;
           ee_wc              := 0.00;
           ee_ssn             := 0.00;
           ee_loc             := 0.00;
           ee_status          := 0.00;
           ee_spouse_ssn      := 0.00;
           ee_n               := 0.00;
           er_addr_line_1     := 0.00;
           er_addr_line_2     := 0.00;
           er_addr_line_3     := 0.00;
           er_addr_city       := 0.00;
           er_addr_state      := 0.00;
           er_addr_zip        := 0.00;
           er_phone           := 0.00;
           ee_addr_line_1     := 0.00;
           ee_addr_line_2     := 0.00;
           ee_addr_line_3     := 0.00;
           ee_addr_city       := 0.00;
           ee_addr_state      := 0.00;
           ee_addr_zip        := 0.00;
           ee_addr_country    := 0.00;



           FETCH c_ee_exception INTO
                 er_name,
                 er_ein,
                 er_addr_line_1,
                 er_addr_line_2,
                 er_addr_line_3,
                 er_addr_city,
                 er_addr_state,
                 er_addr_zip,
                 er_phone,
                 year,
                 ee_first_name,
                 ee_last_name,
                 ee_addr_line_1,
                 ee_addr_line_2,
                 ee_addr_line_3,
                 ee_addr_city,
                 ee_addr_state,
                 ee_addr_zip,
                 ee_addr_country,
                 ee_n,
                 ee_wc,
                 ee_loc,
                 ee_ssn,
                 ee_status,
                 ee_spouse_ssn,
                 ee_pension,
                 ee_wages,
                 ee_commissions,
                 ee_allowances,
                 ee_tips,
                 ee_total,
                 ee_reimb,
                 ee_tax,
                 ee_ret_fund,
                 ee_coda,
                 ee_ss_wages,
                 ee_ss_Tax,
                 ee_ss_tips,
                 ee_med_Wages,
                 ee_med_tax,
                 ee_ss_tax_on_tips,
                 ee_med_tax_on_tips;

           EXIT WHEN c_ee_exception%notfound;

               hr_utility.trace('Exception value found for '||ee_last_name);

               IF c_ee_exception%ROWCOUNT =1 THEN

                  fnd_file.put_line(fnd_file.output
                     ,employee_header('CSV','Header1',p_report_type));

                  fnd_file.new_line(fnd_file.output,1);

                  fnd_file.put_line(fnd_file.output
                     ,employee_header('CSV','Header2',p_report_type));

               END IF;

                  fnd_file.put_line(fnd_file.output
                     ,employee_data (
                                    er_name,
                                    er_ein,
                                    er_addr_line_1,
                                    er_addr_line_2,
                                    er_addr_line_3,
                                    er_addr_city,
                                    er_addr_state,
                                    er_addr_zip,
                                    er_phone,
                                    year,
                                    ee_first_name,
                                    ee_last_name,
                                    ee_addr_line_1,
                                    ee_addr_line_2,
                                    ee_addr_line_3,
                                    ee_addr_city,
                                    ee_addr_state,
                                    ee_addr_zip,
                                    ee_addr_country,
                                    ee_n,
                                    ee_wc,
                                    ee_loc,
                                    ee_ssn,
                                    ee_status,
                                    ee_spouse_ssn,
                                    ee_pension,
                                    ee_wages,
                                    ee_commissions,
                                    ee_allowances,
                                    ee_tips,
                                    ee_total,
                                    ee_reimb,
                                    ee_tax,
                                    ee_ret_fund,
                                    ee_coda,
                                    ee_ss_wages,
                                    ee_ss_Tax,
                                    ee_ss_tips,
                                    ee_med_Wages,
                                    ee_med_tax,
                                    ee_ss_tax_on_tips,
                                    ee_med_tax_on_tips,
                                    'CSV'));


           END LOOP;

   if p_report_type = 'PRW2EXCEPTION' then

/*
           select count(*)
           into ln_count
           FROM pay_us_rpt_totals
           WHERE attribute2 = p_report_type
           AND session_id = to_number(p_seq_num);

           hr_utility.trace('Total# of Records ='||to_char(ln_count));
*/
           DELETE FROM pay_us_rpt_totals
           WHERE attribute2 = p_report_type
           AND session_id = to_number(p_seq_num);

   end if;

           CLOSE c_ee_exception;
  End If;  --  End of Report Type

end;
end pay_us_pr_w2;

/
