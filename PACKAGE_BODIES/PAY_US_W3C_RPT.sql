--------------------------------------------------------
--  DDL for Package Body PAY_US_W3C_RPT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_US_W3C_RPT" AS
/* $Header: pyusw3cr.pkb 120.1.12010000.2 2009/12/30 12:33:20 svannian ship $*/
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

   Name        : pay_us_w3c_rpt
   Description : This package is called by Employee W-2c Report

   Change List
    -----------
    Date        Name       Vers     Bug No     Description
    ----        ----       ------   ---------- -----------
    24-FEB-2003 Asasthan   115.0               Created.
    16-NOV-2006 Saurugpt   115.1    5562494    Change the box 14 value variables to varchar2.
                                               This is needed as NJ Plan ID can be alphanumeric also.

  ************************************************************
  ** Local Package Variables
  ************************************************************/
  gv_title               VARCHAR2(100) := 'W-2c Audit Information';
  gv_title2              VARCHAR2(100) := '';
  gc_csv_delimiter       VARCHAR2(1) := ',';
  gc_csv_data_delimiter  VARCHAR2(1) := '"';

  gv_package_name        VARCHAR2(50) := 'pay_us_w3c_rpt';


  /******************************************************************
  ** Function Returns the formated input string based on the
  ** Output format. If the format is CSV then the values are returned
  ** seperated by comma (,).
  ******************************************************************/

  FUNCTION data_string
             (p_input_string     in varchar2
              ,p_bold            in varchar2 default 'N'
             ,p_output_file_type in varchar2
             )
  RETURN VARCHAR2
  IS

    lv_format          varchar2(32000);

  BEGIN
    hr_utility.set_location(gv_package_name || '.data_string', 10);

    if p_output_file_type = 'CSV' then


       hr_utility.set_location(gv_package_name || '.data_string', 20);

       lv_format := gc_csv_data_delimiter || p_input_string ||
                           gc_csv_data_delimiter || gc_csv_delimiter;

    end if;

    hr_utility.set_location(gv_package_name || '.data_string', 60);

    return lv_format;

  END data_string;

  /*****************************************************************
  ** This procudure returns the Mandatory Static Labels and the
  ** Other Additional Static columns.
  *****************************************************************/

  FUNCTION report_header(
              p_output_file_type  in varchar2,
              p_header            in varchar2
             )
 RETURN VARCHAR2
  IS

    lv_format1          varchar2(32000);
    lv_format2          varchar2(32000);

  BEGIN

      hr_utility.set_location(gv_package_name || '.formated_static_header', 10);

      IF p_header = 'Header1' THEN

         lv_format1 := data_string (p_input_string => gv_title
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type);

      ELSE

      lv_format1 :=
      data_string (p_input_string => 'GRE'
                  ,p_bold         => 'Y'
                  ,p_output_file_type => p_output_file_type) ||
      data_string (p_input_string => 'Employer''s Federal EIN '
                  ,p_bold         => 'Y'
                  ,p_output_file_type => p_output_file_type) ||
      data_string (p_input_string => 'Employee''s Name '
                  ,p_bold         => 'Y'
                  ,p_output_file_type => p_output_file_type) ||
      data_string (p_input_string => 'Incorrect Employee Name'
                  ,p_bold         => 'Y'
                  ,p_output_file_type => p_output_file_type) ||
      data_string (p_input_string => 'SSN '
                  ,p_bold         => 'Y'
                  ,p_output_file_type => p_output_file_type) ||
      data_string (p_input_string => 'Incorrect SSN'
                  ,p_bold         => 'Y'
                  ,p_output_file_type => p_output_file_type) ||
      data_string (p_input_string => 'Record Type'
                  ,p_bold         => 'Y'
                  ,p_output_file_type => p_output_file_type) ||
      data_string (p_input_string => 'Tax Year'
                  ,p_bold         => 'Y'
                  ,p_output_file_type => p_output_file_type) ||
      data_string (p_input_string => '''Wages, tips, other compensation (previous values)'''
                  ,p_bold         => 'Y'
                  ,p_output_file_type => p_output_file_type) ||
      data_string (p_input_string => '''Wages, tips, other compensation (corrected values)'''
                  ,p_bold         => 'Y'
                  ,p_output_file_type => p_output_file_type) ||
      data_string (p_input_string => 'Federal Income tax withheld (previous values)'
                  ,p_bold         => 'Y'
                  ,p_output_file_type => p_output_file_type) ||
      data_string (p_input_string => 'Federal Income tax withheld (corrected values)'
                  ,p_bold         => 'Y'
                  ,p_output_file_type => p_output_file_type) ||
      data_string (p_input_string => 'Social security wages (previous values)'
                  ,p_bold         => 'Y'
                  ,p_output_file_type => p_output_file_type) ||
      data_string (p_input_string => 'Social security wages (corrected values)'
                  ,p_bold         => 'Y'
                  ,p_output_file_type => p_output_file_type) ||
      data_string (p_input_string => 'Social security tax withheld (previous values)'
                  ,p_bold         => 'Y'
                  ,p_output_file_type => p_output_file_type) ||
      data_string (p_input_string => 'Social security tax withheld (corrected values)'
                  ,p_bold         => 'Y'
                  ,p_output_file_type => p_output_file_type) ||
      data_string (p_input_string => 'Medicare wages and tips (previous values)'
                  ,p_bold         => 'Y'
                  ,p_output_file_type => p_output_file_type) ||
      data_string (p_input_string => 'Medicare wages and tips (corrected values)'
                  ,p_bold         => 'Y'
                  ,p_output_file_type => p_output_file_type) ||
      data_string (p_input_string => 'Medicare tax withheld (previous values)'
                  ,p_bold         => 'Y'
                  ,p_output_file_type => p_output_file_type) ||
      data_string (p_input_string => 'Medicare tax withheld (corrected values)'
                  ,p_bold         => 'Y'
                  ,p_output_file_type => p_output_file_type) ||
      data_string (p_input_string => 'Social security tips (previous values)'
                  ,p_bold         => 'Y'
                  ,p_output_file_type => p_output_file_type) ||
      data_string (p_input_string => 'Social security tips (corrected values)'
                  ,p_bold         => 'Y'
                  ,p_output_file_type => p_output_file_type) ||
      data_string (p_input_string => 'Allocated tips (previous values)'
                  ,p_bold         => 'Y'
                  ,p_output_file_type => p_output_file_type) ||
      data_string (p_input_string => 'Allocated tips (corrected values)'
                  ,p_bold         => 'Y'
                  ,p_output_file_type => p_output_file_type) ||
      data_string (p_input_string => 'Advance EIC payments (previous values)'
                  ,p_bold         => 'Y'
                  ,p_output_file_type => p_output_file_type) ||
      data_string (p_input_string => 'Advance EIC payments (corrected values)'
                  ,p_bold         => 'Y'
                  ,p_output_file_type => p_output_file_type) ||
      data_string (p_input_string => 'Dependent care benefits (previous values)'
                  ,p_bold         => 'Y'
                  ,p_output_file_type => p_output_file_type) ||
      data_string (p_input_string => 'Dependent care benefits (corrected values)'
                  ,p_bold         => 'Y'
                  ,p_output_file_type => p_output_file_type) ||
      data_string (p_input_string => 'Nonqualified plans (previous values)'
                  ,p_bold         => 'Y'
                  ,p_output_file_type => p_output_file_type) ||
      data_string (p_input_string => 'Nonqualified plans (corrected values)'
                  ,p_bold         => 'Y'
                  ,p_output_file_type => p_output_file_type) ||
      data_string (p_input_string => 'Inc. tax W/H by 3rd party sick pay payer (previous values)'
                  ,p_bold         => 'Y'
                  ,p_output_file_type => p_output_file_type) ||
      data_string (p_input_string => 'Inc. tax W/H by 3rd party sick pay payer (corrected values)'
                  ,p_bold         => 'Y'
                  ,p_output_file_type => p_output_file_type) ||
      data_string (p_input_string => 'Box 12 Code'
                  ,p_bold         => 'Y'
                  ,p_output_file_type => p_output_file_type) ||
      data_string (p_input_string => 'Box 12 (previous values)'
                  ,p_bold         => 'Y'
                  ,p_output_file_type => p_output_file_type) ||
      data_string (p_input_string => 'Box 12 (corrected values)'
                  ,p_bold         => 'Y'
                  ,p_output_file_type => p_output_file_type) ||
      data_string (p_input_string => 'Box 14 Code'
                  ,p_bold         => 'Y'
                  ,p_output_file_type => p_output_file_type) ||
      data_string (p_input_string => 'Box 14 (previous values)'
                  ,p_bold         => 'Y'
                  ,p_output_file_type => p_output_file_type) ||
      data_string (p_input_string => 'Box 14 (corrected values)'
                  ,p_bold         => 'Y'
                  ,p_output_file_type => p_output_file_type) ||
      data_string (p_input_string => 'State'
                  ,p_bold         => 'Y'
                  ,p_output_file_type => p_output_file_type) ||
      data_string (p_input_string => 'State EIN'
                  ,p_bold         => 'Y'
                  ,p_output_file_type => p_output_file_type) ||
      data_string (p_input_string => 'State Incorrect EIN'
                  ,p_bold         => 'Y'
                  ,p_output_file_type => p_output_file_type) ||
      data_string (p_input_string => '''State wages, tips, etc. (previous values)'''
                  ,p_bold         => 'Y'
                  ,p_output_file_type => p_output_file_type) ||
      data_string (p_input_string => '''State wages, tips, etc. (corrected values)'''
                  ,p_bold         => 'Y'
                  ,p_output_file_type => p_output_file_type) ||
      data_string (p_input_string => 'State income tax (previous values)'
                  ,p_bold         => 'Y'
                  ,p_output_file_type => p_output_file_type) ||
      data_string (p_input_string => 'State income tax (corrected values)'
                  ,p_bold         => 'Y'
                  ,p_output_file_type => p_output_file_type) ||
      data_string (p_input_string => 'State-Locality'
                  ,p_bold         => 'Y'
                  ,p_output_file_type => p_output_file_type) ||
      data_string (p_input_string => '''Local wages, tips, etc. (previous values)'''
                  ,p_bold         => 'Y'
                  ,p_output_file_type => p_output_file_type) ||
      data_string (p_input_string => '''Local wages, tips, etc. (corrected values)'''
                  ,p_bold         => 'Y'
                  ,p_output_file_type => p_output_file_type) ||
      data_string (p_input_string => 'Local income tax (previous values)'
                  ,p_bold         => 'Y'
                  ,p_output_file_type => p_output_file_type) ||
      data_string (p_input_string => 'Local income tax (corrected values)'
                  ,p_bold         => 'Y'
                  ,p_output_file_type => p_output_file_type) ;

      END IF;

  RETURN (lv_format1);
  END;


  FUNCTION report_data (
                   p_employer_name           in varchar2,
                   p_federal_ein             in varchar2,
                   p_employee_name           in varchar2,
                   p_incorrect_name          in varchar2,
                   p_ssn                     in varchar2,
                   p_incorrect_ssn           in varchar2,
                   p_record_type             in varchar2,
                   p_tax_year                in varchar2,
                   p_wages_old               in number,
                   p_wages_new               in number,
                   p_fit_old                 in number,
                   p_fit_new                 in number,
                   p_ss_wages_old            in number,
                   p_ss_wages_new            in number,
                   p_ss_withheld_old         in number,
                   p_ss_withheld_new         in number,
                   p_medi_wages_old          in number,
                   p_medi_wages_new          in number,
                   p_medi_withheld_old       in number,
                   p_medi_withheld_new       in number,
                   p_ss_tips_old             in number,
                   p_ss_tips_new             in number,
                   p_alloc_tips_old          in number,
                   p_alloc_tips_new          in number,
                   p_eic_old                 in number,
                   p_eic_new                 in number,
                   p_depcare_old             in number,
                   p_depcare_new             in number,
                   p_nonqual_old             in number,
                   p_nonqual_new             in number,
                   p_third_party_sick_old    in number,
                   p_third_party_sick_new    in number,
                   p_box_12_code             in varchar2,
                   p_box_12_value_old        in number,
                   p_box_12_value_new        in number,
                   p_box_14_code             in varchar2,
                   p_box_14_value_old        in varchar2,  --number, Bug 5562494
                   p_box_14_value_new        in varchar2,  --number,
                   p_state_abbrev            in varchar2,
                   p_state_id_number         in varchar2,
                   p_state_inco_id_number    in varchar2,
                   p_ss_wages_tips_old       in varchar2,
                   p_ss_wages_tips_new       in varchar2,
                   p_sit_old                 in varchar2,
                   p_sit_new                 in varchar2,
                   p_state_local_name        in varchar2,
                   p_local_wages_old         in number,
                   p_local_wages_new         in number,
                   p_local_withheld_old      in number,
                   p_local_withheld_new      in number,
                   p_output_file_type        in varchar2
             )
RETURN VARCHAR2
  IS

    lv_format1 VARCHAR2(32000);
    lv_format2 VARCHAR2(32000);


  BEGIN

      hr_utility.set_location(gv_package_name || '.formated_static_data', 10);
      lv_format1 :=
              data_string (p_input_string => p_employer_name
                                   ,p_output_file_type => p_output_file_type)||
              data_string (p_input_string => p_federal_ein
                                   ,p_output_file_type => p_output_file_type)||
              data_string (p_input_string => p_employee_name
                                   ,p_output_file_type => p_output_file_type)||
              data_string (p_input_string => p_incorrect_name
                                   ,p_output_file_type => p_output_file_type)||
              data_string (p_input_string => p_ssn
                                   ,p_output_file_type => p_output_file_type)||
              data_string (p_input_string => p_incorrect_ssn
                                   ,p_output_file_type => p_output_file_type)||
              data_string (p_input_string => p_record_type
                                   ,p_output_file_type => p_output_file_type)||
              data_string (p_input_string => p_tax_year
                                   ,p_output_file_type => p_output_file_type)||
              data_string (p_input_string => p_wages_old
                                   ,p_output_file_type => p_output_file_type)||
              data_string (p_input_string => p_wages_new
                                   ,p_output_file_type => p_output_file_type)||
              data_string (p_input_string => p_fit_old
                                   ,p_output_file_type => p_output_file_type)||
              data_string (p_input_string => p_fit_new
                                   ,p_output_file_type => p_output_file_type)||
              data_string (p_input_string => p_ss_wages_old
                                   ,p_output_file_type => p_output_file_type)||
              data_string (p_input_string => p_ss_wages_new
                                   ,p_output_file_type => p_output_file_type)||
              data_string (p_input_string => p_ss_withheld_old
                                   ,p_output_file_type => p_output_file_type)||
              data_string (p_input_string => p_ss_withheld_new
                                   ,p_output_file_type => p_output_file_type)||
              data_string (p_input_string => p_medi_wages_old
                                   ,p_output_file_type => p_output_file_type)||
              data_string (p_input_string => p_medi_wages_new
                                   ,p_output_file_type => p_output_file_type)||
              data_string (p_input_string => p_medi_withheld_old
                                   ,p_output_file_type => p_output_file_type)||
              data_string (p_input_string => p_medi_withheld_new
                                   ,p_output_file_type => p_output_file_type)||
              data_string (p_input_string => p_ss_tips_old
                                   ,p_output_file_type => p_output_file_type)||
              data_string (p_input_string => p_ss_tips_new
                                   ,p_output_file_type => p_output_file_type)||
              data_string (p_input_string => p_alloc_tips_old
                                   ,p_output_file_type => p_output_file_type)||
              data_string (p_input_string => p_alloc_tips_new
                                   ,p_output_file_type => p_output_file_type)||
              data_string (p_input_string => p_eic_old
                                   ,p_output_file_type => p_output_file_type)||
              data_string (p_input_string => p_eic_new
                                   ,p_output_file_type => p_output_file_type)||
              data_string (p_input_string => p_depcare_old
                                   ,p_output_file_type => p_output_file_type)||
              data_string (p_input_string => p_depcare_new
                                   ,p_output_file_type => p_output_file_type)||
              data_string (p_input_string => p_nonqual_old
                                   ,p_output_file_type => p_output_file_type)||
              data_string (p_input_string => p_nonqual_new
                                   ,p_output_file_type => p_output_file_type)||
              data_string (p_input_string => p_third_party_sick_old
                                   ,p_output_file_type => p_output_file_type)||
              data_string (p_input_string => p_third_party_sick_new
                                   ,p_output_file_type => p_output_file_type)||
              data_string (p_input_string => p_box_12_code
                                   ,p_output_file_type => p_output_file_type)||
              data_string (p_input_string => p_box_12_value_old
                                   ,p_output_file_type => p_output_file_type)||
              data_string (p_input_string => p_box_12_value_new
                                   ,p_output_file_type => p_output_file_type)||
              data_string (p_input_string => p_box_14_code
                                   ,p_output_file_type => p_output_file_type)||
              data_string (p_input_string => p_box_14_value_old
                                   ,p_output_file_type => p_output_file_type)||
              data_string (p_input_string => p_box_14_value_new
                                   ,p_output_file_type => p_output_file_type)||
              data_string (p_input_string => p_state_abbrev
                                   ,p_output_file_type => p_output_file_type)||
              data_string (p_input_string => p_state_id_number
                                   ,p_output_file_type => p_output_file_type)||
              data_string (p_input_string => p_state_inco_id_number
                                   ,p_output_file_type => p_output_file_type)||
              data_string (p_input_string => p_ss_wages_tips_old
                                   ,p_output_file_type => p_output_file_type)||
              data_string (p_input_string => p_ss_wages_tips_new
                                   ,p_output_file_type => p_output_file_type)||
              data_string (p_input_string => p_sit_old
                                   ,p_output_file_type => p_output_file_type)||
              data_string (p_input_string => p_sit_new
                                   ,p_output_file_type => p_output_file_type)||
              data_string (p_input_string => p_state_local_name
                                   ,p_output_file_type => p_output_file_type)||
              data_string (p_input_string => p_local_wages_old
                                   ,p_output_file_type => p_output_file_type)||
              data_string (p_input_string => p_local_wages_new
                                   ,p_output_file_type => p_output_file_type)||
              data_string (p_input_string => p_local_withheld_old
                                   ,p_output_file_type => p_output_file_type)||
              data_string (p_input_string => p_local_withheld_new
                                   ,p_output_file_type => p_output_file_type);



      hr_utility.set_location(gv_package_name || '.formated_static_data', 20);


      hr_utility.trace('Static Data1 = ' || lv_format1);
      hr_utility.set_location(gv_package_name || '.formated_static_data', 40);

      return (lv_format1);
  END;


PROCEDURE insert_w3c_dtls(errbuf               OUT nocopy     VARCHAR2,
                          retcode              OUT nocopy     NUMBER,
                          p_seq_num            IN      VARCHAR2) is

     cursor c_get_data(c_seq_num in VARCHAR2) is
     SELECT tax_unit_id                 tax_unit_id,
            nvl(attribute6,' ')         employer_name,
            nvl(attribute7,' ')         federal_ein,
            nvl(attribute4,' ')         employee_name,
            nvl(attribute5,' ')         ssn,
            nvl(attribute3,' ')         record_type,
            nvl(attribute2,' ')             tax_year,
            nvl(value1,0)                   wages_old,
            nvl(value2,0)                   wages_new,
            nvl(value3,0)                   fit_old,
            nvl(value4,0)                   fit_new,
            nvl(value5,0)                   ss_wages_old,
            nvl(value6,0)                   ss_wages_new,
            nvl(value7,0)                   ss_withheld_old,
            nvl(value8,0)                   ss_withheld_new,
            nvl(value9,0)                   medi_wages_old,
            nvl(value10,0)                  medi_wages_new,
            nvl(value11,0)                  medi_withheld_old,
            nvl(value12,0)                  medi_withheld_new,
            nvl(value13,0)                  ss_tips_old,
            nvl(value14,0)                  ss_tips_new,
            nvl(value15,0)                  alloc_tips_old,
            nvl(value16,0)                  alloc_tips_new,
            nvl(value17,0)                  eic_old,
            nvl(value18,0)                  eic_new,
            nvl(value19,0)                  depcare_old,
            nvl(value20,0)                  depcare_new,
            nvl(value21,0)                  nonqual_old,
            nvl(value22,0)                  nonqual_new,
            nvl(value23,0)                  third_party_sick_old,
            nvl(value24,0)                  third_party_sick_new,
            nvl(attribute9,' ')             box_12_code,
            to_number(nvl(attribute10,0))   box_12_value_old,
            to_number(nvl(attribute11,0))   box_12_value_new,
            nvl(attribute12,' ')            box_14_code ,
            nvl(attribute13,0)              box_14_value_old,   -- Bug 5562494 to_number(nvl(attribute13,0))
            nvl(attribute14,0)              box_14_value_new,   -- to_number(nvl(attribute14,0))
            nvl(attribute15,' ')            state_abbrev,
            nvl(attribute16,' ')            state_id_number,
            nvl(attribute17,' ')            state_inco_id_number,
            (nvl(attribute18,' '))   ss_wages_tips_old,
            (nvl(attribute19,' '))   ss_wages_tips_new,
            (nvl(attribute20,' '))   sit_old,
            (nvl(attribute21,' '))   sit_new,
            nvl(attribute22,' ')             state_local_name,
            to_number(nvl(attribute23,0))   local_wages_old,
            to_number(nvl(attribute24,0))   local_wages_new,
            to_number(nvl(attribute25,0))   local_withheld_old,
            to_number(nvl(attribute26,0))   local_withheld_new,
            nvl(attribute27,' ')            incorrect_name,
            nvl(attribute28,' ')            incorrect_ssn
     FROM   pay_us_rpt_totals
     WHERE  session_id = to_number(c_seq_num)
     AND    attribute3 in ('FEDERAL','BOX 12','BOX 14','STATE','LOCAL')
     order by attribute4,
              attribute5,
              decode(attribute3,'FEDERAL','1',
                                'BOX 12','2',
                                'BOX 14','3',
                                'STATE','4',
                                'LOCAL','5','6') ;


      TYPE numeric_table IS TABLE OF number(20,2)
                           INDEX BY BINARY_INTEGER;

      TYPE text_table IS TABLE OF varchar2(2000)
                           INDEX BY BINARY_INTEGER;

     l_tax_unit_id           pay_us_rpt_totals.tax_unit_id%TYPE := 9999999;
     l_wages_old             pay_us_rpt_totals.value1%TYPE := 0;
     l_wages_new             pay_us_rpt_totals.value2%TYPE := 0;
     l_fit_old               pay_us_rpt_totals.value3%TYPE := 0;
     l_fit_new               pay_us_rpt_totals.value4%TYPE := 0;
     l_ss_wages_old          pay_us_rpt_totals.value5%TYPE := 0;
     l_ss_wages_new          pay_us_rpt_totals.value6%TYPE := 0;
     l_ss_withheld_old       pay_us_rpt_totals.value7%TYPE := 0;
     l_ss_withheld_new       pay_us_rpt_totals.value8%TYPE := 0;
     l_medi_wages_old        pay_us_rpt_totals.value9%TYPE := 0;
     l_medi_wages_new        pay_us_rpt_totals.value10%TYPE := 0;
     l_medi_withheld_old     pay_us_rpt_totals.value11%TYPE := 0;
     l_medi_withheld_new     pay_us_rpt_totals.value12%TYPE := 0;
     l_ss_tips_old           pay_us_rpt_totals.value13%TYPE := 0;
     l_ss_tips_new           pay_us_rpt_totals.value14%TYPE := 0;
     l_alloc_tips_old        pay_us_rpt_totals.value15%TYPE := 0;
     l_alloc_tips_new        pay_us_rpt_totals.value16%TYPE := 0;
     l_eic_old               pay_us_rpt_totals.value17%TYPE := 0;
     l_eic_new               pay_us_rpt_totals.value18%TYPE := 0;
     l_depcare_old           pay_us_rpt_totals.value19%TYPE := 0;
     l_depcare_new           pay_us_rpt_totals.value20%TYPE :=0 ;
     l_nonqual_old           pay_us_rpt_totals.value21%TYPE :=0 ;
     l_nonqual_new           pay_us_rpt_totals.value22%TYPE :=0 ;
     l_third_party_sick_old  pay_us_rpt_totals.value23%TYPE := 0;
     l_third_party_sick_new  pay_us_rpt_totals.value24%TYPE := 0;
     l_report_type           pay_us_rpt_totals.attribute1%TYPE := ' ' ;
     l_tax_year              pay_us_rpt_totals.attribute2%TYPE := ' ';
     l_record_type           pay_us_rpt_totals.attribute3%TYPE := ' ';
     l_employee_name         pay_us_rpt_totals.attribute4%TYPE := ' ';
     l_ssn                   pay_us_rpt_totals.attribute5%TYPE := ' ';
     l_employer_name         pay_us_rpt_totals.attribute6%TYPE := ' ';
     l_federal_ein           pay_us_rpt_totals.attribute7%TYPE := ' ';
     l_fed_ein               pay_us_rpt_totals.attribute7%TYPE := ' ';
     l_box_12_code           pay_us_rpt_totals.attribute9%TYPE := ' ';
     l_box_12_value_old      pay_us_rpt_totals.attribute10%TYPE := ' ';
     l_box_12_value_new      pay_us_rpt_totals.attribute11%TYPE := ' ';
     l_box_14_code           pay_us_rpt_totals.attribute12%TYPE := ' ';
     l_box_14_value_old      pay_us_rpt_totals.attribute13%TYPE := ' ';
     l_box_14_value_new      pay_us_rpt_totals.attribute14%TYPE := ' ';
     l_state_abbrev          pay_us_rpt_totals.attribute15%TYPE := ' ';
     l_state_id_number       pay_us_rpt_totals.attribute16%TYPE := ' ';
     l_state_id_sring        pay_us_rpt_totals.attribute16%TYPE := ' ';
     l_state_inco_id_number  pay_us_rpt_totals.attribute17%TYPE := ' ';
     l_state_inco_id_string  pay_us_rpt_totals.attribute17%TYPE := ' ';
     l_ss_wages_tips_old     pay_us_rpt_totals.attribute18%TYPE := ' ';
     l_ss_wages_tips_new     pay_us_rpt_totals.attribute19%TYPE := ' ';
     l_sit_old               pay_us_rpt_totals.attribute20%TYPE := ' ';
     l_sit_new               pay_us_rpt_totals.attribute21%TYPE := ' ';
     l_state_local_name      pay_us_rpt_totals.attribute22%TYPE := ' ';
     l_local_wages_old       pay_us_rpt_totals.attribute23%TYPE := ' ';
     l_local_wages_new       pay_us_rpt_totals.attribute24%TYPE := ' ';
     l_local_withheld_old    pay_us_rpt_totals.attribute25%TYPE := ' ';
     l_local_withheld_new    pay_us_rpt_totals.attribute26%TYPE := ' ';
     l_incorrect_name        pay_us_rpt_totals.attribute27%TYPE := ' ';
     l_incorrect_ssn         pay_us_rpt_totals.attribute28%TYPE := ' ';
BEGIN

     --hr_utility.trace_on(null, 'W3CAUDIT');
     hr_utility.trace ('Entered Main package');
     hr_utility.trace ('p_seq_num = '||p_seq_num);


     open c_get_data(p_seq_num);

     hr_utility.trace('Opened c_get_data cursor');

     loop

                           l_tax_unit_id :=0;
                           l_employer_name := ' ';
                           l_federal_ein := ' ';
                           l_employee_name := ' ';
                           l_ssn := ' ';
                           l_record_type := ' ';
                           l_tax_year := ' ';
                           l_wages_old :=0;
                           l_wages_new :=0;
                           l_fit_old :=0;
                           l_fit_new :=0;
                           l_ss_wages_old :=0;
                           l_ss_wages_new :=0;
                           l_ss_withheld_old :=0;
                           l_ss_withheld_new :=0;
                           l_medi_wages_old :=0;
                           l_medi_wages_new :=0;
                           l_medi_withheld_old :=0;
                           l_medi_withheld_new :=0;
                           l_ss_tips_old :=0;
                           l_ss_tips_new :=0;
                           l_alloc_tips_old :=0;
                           l_alloc_tips_new :=0;
                           l_eic_old :=0;
                           l_eic_new :=0;
                           l_depcare_old :=0;
                           l_depcare_new :=0;
                           l_nonqual_old :=0;
                           l_nonqual_new :=0;
                           l_third_party_sick_old :=0;
                           l_third_party_sick_new :=0;
                           l_box_12_code :=' ';
                           l_box_12_value_old := 0;
                           l_box_12_value_new := 0;
                           l_box_14_code := ' ';
                           l_box_14_value_old := 0;
                           l_box_14_value_new := 0;
                           l_state_abbrev := ' ';
                           l_state_id_number := ' ';
                           l_state_inco_id_number := ' ';
                           l_ss_wages_tips_old := ' ';
                           l_ss_wages_tips_new := ' ';
                           l_sit_old := ' ';
                           l_sit_new := ' ';
                           l_state_local_name := ' ';
                           l_local_wages_old := 0;
                           l_local_wages_new := 0;
                           l_local_withheld_old := 0;
                           l_local_withheld_new := 0;
                           l_incorrect_name := ' ';
                           l_incorrect_ssn := ' ';

     fetch c_get_data into l_tax_unit_id,
                           l_employer_name,
                           l_federal_ein,
                           l_employee_name,
                           l_ssn,
                           l_record_type,
                           l_tax_year,
                           l_wages_old,
                           l_wages_new,
                           l_fit_old,
                           l_fit_new,
                           l_ss_wages_old,
                           l_ss_wages_new,
                           l_ss_withheld_old,
                           l_ss_withheld_new,
                           l_medi_wages_old,
                           l_medi_wages_new,
                           l_medi_withheld_old,
                           l_medi_withheld_new,
                           l_ss_tips_old,
                           l_ss_tips_new,
                           l_alloc_tips_old,
                           l_alloc_tips_new,
                           l_eic_old,
                           l_eic_new,
                           l_depcare_old,
                           l_depcare_new,
                           l_nonqual_old,
                           l_nonqual_new,
                           l_third_party_sick_old,
                           l_third_party_sick_new,
                           l_box_12_code,
                           l_box_12_value_old,
                           l_box_12_value_new,
                           l_box_14_code,
                           l_box_14_value_old,
                           l_box_14_value_new,
                           l_state_abbrev,
                           l_state_id_number,
                           l_state_inco_id_number,
                           l_ss_wages_tips_old,
                           l_ss_wages_tips_new,
                           l_sit_old,
                           l_sit_new,
                           l_state_local_name,
                           l_local_wages_old,
                           l_local_wages_new,
                           l_local_withheld_old,
                           l_local_withheld_new,
                           l_incorrect_name,
                           l_incorrect_ssn
                           ;

       if l_record_type = 'FEDERAL' then
           l_fed_ein := ''''||l_federal_ein||'''';
       else
           l_fed_ein := l_federal_ein;
       end if;

       if l_record_type ='STATE' then
           l_state_id_sring := ''''||l_state_id_number||'''';
           l_state_inco_id_string := ''''||l_state_inco_id_number||'''';
       else
           l_state_id_sring := l_state_id_number;
           l_state_inco_id_string := l_state_inco_id_number;
       end if;


       l_employer_name := replace(l_employer_name,',');
       l_employee_name := replace(l_employee_name,',');


       hr_utility.trace('l_employer_name = '||l_employer_name);
       hr_utility.trace('l_employee_name = '||l_employee_name);

       hr_utility.trace('l_record_type = '||l_record_type);
       hr_utility.trace('l_federal_ein = '||l_federal_ein);
       hr_utility.trace('l_fed_ein = '||l_fed_ein);
       hr_utility.trace('l_employee_name = '||l_employee_name);
       hr_utility.trace('l_ssn = '||l_ssn);
       hr_utility.trace('l_record_type = '||l_record_type);
       hr_utility.trace('l_tax_year = '||l_tax_year);
       hr_utility.trace('l_wages_old = '||to_char(l_wages_old));
       hr_utility.trace('l_wages_new = '||to_char(l_wages_new));
       hr_utility.trace('l_fit_old = '||to_char(l_fit_old));
       hr_utility.trace('l_fit_new = '||to_char(l_fit_new));
       hr_utility.trace('l_ss_wages_old = '||to_char(l_ss_wages_old));
       hr_utility.trace('l_ss_wages_new = '||to_char(l_ss_wages_new));
       hr_utility.trace('l_ss_withheld_old = '||to_char(l_ss_withheld_old));
       hr_utility.trace('l_ss_withheld_new = '||to_char(l_ss_withheld_new));
       hr_utility.trace('l_medi_wages_old = '||to_char(l_medi_wages_old));
       hr_utility.trace('l_medi_wages_new = '||to_char(l_medi_wages_new));
       hr_utility.trace('l_medi_withheld_old = '||to_char(l_medi_withheld_old));
       hr_utility.trace('l_medi_withheld_new = '||to_char(l_medi_withheld_new));
       hr_utility.trace('l_ss_tips_old = '||to_char(l_ss_tips_old));
       hr_utility.trace('l_ss_tips_new = '||to_char(l_ss_tips_new));
       hr_utility.trace('l_alloc_tips_old = '||to_char(l_alloc_tips_old));
       hr_utility.trace('l_alloc_tips_new = '||to_char(l_alloc_tips_new));
       hr_utility.trace('l_eic_old = '||to_char(l_eic_old));
       hr_utility.trace('l_eic_new = '||to_char(l_eic_new));
       hr_utility.trace('l_depcare_old = '||to_char(l_depcare_old));
       hr_utility.trace('l_depcare_new = '||to_char(l_depcare_new));
       hr_utility.trace('l_nonqual_old = '||to_char(l_nonqual_old));
       hr_utility.trace('l_nonqual_new = '||to_char(l_nonqual_new));
       hr_utility.trace('l_third_party_sick_old = '||to_char(l_third_party_sick_old));
       hr_utility.trace('l_third_party_sick_new = '||to_char(l_third_party_sick_new));
       hr_utility.trace('l_box_12_code = '||l_box_12_code);
       hr_utility.trace('l_box_12_value_old = '||l_box_12_value_old);
       hr_utility.trace('l_box_12_value_new = '||l_box_12_value_new);
       hr_utility.trace('l_box_14_code = '||l_box_14_code);
       hr_utility.trace('l_box_14_value_old = '||l_box_14_value_old);
       hr_utility.trace('l_box_14_value_new = '||l_box_14_value_new);
       hr_utility.trace('l_state_abbrev = '||l_state_abbrev);
       hr_utility.trace('l_state_id_number = '||l_state_id_number);
       hr_utility.trace('l_state_id_sring = '||l_state_id_sring);
       hr_utility.trace('l_state_inco_id_number = '||l_state_inco_id_number);
       hr_utility.trace('l_state_inco_id_string = '||l_state_inco_id_string);
       hr_utility.trace('l_ss_wages_tips_old = '||l_ss_wages_tips_old);
       hr_utility.trace('l_ss_wages_tips_new = '||l_ss_wages_tips_new);
       hr_utility.trace('l_sit_old = '||l_sit_old);
       hr_utility.trace('l_sit_new = '||l_sit_new);
       hr_utility.trace('l_state_local_name = '||l_state_local_name);
       hr_utility.trace('l_local_wages_old = '||l_local_wages_old);
       hr_utility.trace('l_local_wages_new = '||l_local_wages_new);
       hr_utility.trace('l_local_withheld_old = '||l_local_withheld_old);
       hr_utility.trace('l_local_withheld_new = '||l_local_withheld_new);
       hr_utility.trace('l_incorrect_name = '||l_incorrect_name);
       hr_utility.trace('l_incorrect_ssn = '||l_incorrect_ssn);

       exit when  c_get_data%NOTFOUND;

           if c_get_data%ROWCOUNT =1 THEN


            hr_utility.trace('row_count = 1');

            fnd_file.put_line(fnd_file.output,report_header('CSV','Header1'));
            fnd_file.put_line(fnd_file.output,report_header('CSV','Header2'));

           end if;

          hr_utility.trace ('Writing report data = ');

          fnd_file.put_line(fnd_file.output,report_data(
            l_employer_name,
            l_fed_ein,
            l_employee_name,
            l_incorrect_name,
            l_ssn,
            l_incorrect_ssn,
            l_record_type,
            l_tax_year,
            l_wages_old,
            l_wages_new,
            l_fit_old,
            l_fit_new,
            l_ss_wages_old,
            l_ss_wages_new,
            l_ss_withheld_old,
            l_ss_withheld_new,
            l_medi_wages_old,
            l_medi_wages_new,
            l_medi_withheld_old,
            l_medi_withheld_new,
            l_ss_tips_old,
            l_ss_tips_new,
            l_alloc_tips_old,
            l_alloc_tips_new,
            l_eic_old,
            l_eic_new,
            l_depcare_old,
            l_depcare_new,
            l_nonqual_old,
            l_nonqual_new,
            l_third_party_sick_old,
            l_third_party_sick_new,
            l_box_12_code,
            l_box_12_value_old,
            l_box_12_value_new,
            l_box_14_code,
            l_box_14_value_old,
            l_box_14_value_new,
            l_state_abbrev,
            l_state_id_sring,
            l_state_inco_id_string,
            l_ss_wages_tips_old,
            l_ss_wages_tips_new,
            l_sit_old,
            l_sit_new,
            l_state_local_name,
            l_local_wages_old,
            l_local_wages_new,
            l_local_withheld_old,
            l_local_withheld_new,
            'CSV'));

       end loop;


       hr_utility.trace ('out of loop = ');

           DELETE FROM pay_us_rpt_totals
           WHERE session_id = p_seq_num ;



     close c_get_data;

end;
end pay_us_w3c_rpt;

/
