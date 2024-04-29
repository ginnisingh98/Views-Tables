--------------------------------------------------------
--  DDL for Package Body PAY_US_SQWL_ERROR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_US_SQWL_ERROR" as
/* $Header: pyusngpk.pkb 120.4 2006/09/19 08:48:12 sackumar noship $*/

/* Rmonge 30-NOV-2001                             */


  /************************************************************
  ** Local Package Variables
  ************************************************************/
  gv_title               VARCHAR2(100) := ' State Quaterly Error Report ';
  gc_csv_delimiter       VARCHAR2(1) := ',';
  gc_csv_data_delimiter  VARCHAR2(1) := '"';

  gv_package_name        VARCHAR2(50) := 'pay_us_sqwl_error';


  /******************************************************************
  ** Function Returns the formated input string based on the
  ** Output format. If the format is CSV then the values are returned
  ** seperated by comma (,).
  ******************************************************************/

  FUNCTION formated_data_string
             (p_input_string     in varchar2
             ,p_output_file_type in varchar2
             ,p_bold             in varchar2 default 'N'
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

    end if;

    hr_utility.set_location(gv_package_name || '.formated_data_string', 60);
    return lv_format;

  END formated_data_string;

  /*****************************************************************
  ** This procudure returns the Mandatory Static Labels and the
  ** Other Additional Static columns.
  *****************************************************************/

  FUNCTION formated_static_header(
              p_output_file_type  in varchar2
             )
 RETURN VARCHAR2
  IS

    lv_format1          varchar2(32000);
    lv_format2          varchar2(32000);

  BEGIN

      hr_utility.set_location(gv_package_name || '.formated_static_header', 10);
      lv_format1 :=
              formated_data_string (p_input_string => 'GRE'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => 'Organization'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => 'QTR Name'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string =>  'State Code'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => 'Assignment Number'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => 'Full Name'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => 'SUI Qtr Wages'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => 'SUI ER Taxable'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => 'SUI Excess '
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => 'SUI ER Subj Whable'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => 'SUI ER Pre Tax Redns'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => 'SIT Qtr Wages'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => 'SIT Withheld'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => 'SIT Gross'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => 'SIT Subj Whable'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => 'SIT Subj Nwhable'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => 'SIT Pre Tax Redns'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => 'Hours Worked'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => 'Weeks Worked'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ;

  RETURN (lv_format1);
  END;

  /* Bug # 5333916 */
FUNCTION formated_static_header_NM(
              p_output_file_type  in varchar2
             )
 RETURN VARCHAR2
  IS

    lv_format1          varchar2(32000);
    lv_format2          varchar2(32000);

  BEGIN

      hr_utility.set_location(gv_package_name || '.formated_static_header_NM', 10);
      lv_format1 :=
              formated_data_string (p_input_string => 'GRE'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => 'Organization'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => 'QTR Name'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string =>  'State Code'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => 'Assignment Number'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => 'Full Name'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => 'SUI Qtr Wages'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => 'SUI ER Taxable'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => 'SUI Excess '
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => 'SUI ER Subj Whable'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => 'SUI ER Pre Tax Redns'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => 'SIT Qtr Wages'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => 'SIT Withheld'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => 'SIT Gross'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => 'SIT Subj Whable'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => 'SIT Subj Nwhable'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => 'SIT Pre Tax Redns'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => 'Hours Worked'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => 'Weeks Worked'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type)  ||
              formated_data_string (p_input_string => 'Workers Compensation 2 ER'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type)  ||
              formated_data_string (p_input_string => 'Workers Compensation 2 EE'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type)  ||
              formated_data_string (p_input_string => 'Workers Compensation'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ;

  RETURN (lv_format1);
  END;

/* This function is used to write the headers for the State of California */

  FUNCTION formated_static_header_CA(
              p_output_file_type  in varchar2
             )
 RETURN VARCHAR2
  IS

    lv_format1          varchar2(32000);
    lv_format2          varchar2(32000);

  BEGIN

      hr_utility.set_location(gv_package_name || '.formated_static_header', 10);
      lv_format1 :=
              formated_data_string (p_input_string => 'GRE'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => 'Organization'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => 'QTR Name'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string =>  'State Code'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => 'Assignment Number'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => 'Full Name'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => 'SUI Qtr Wages'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => 'SUI ER Taxable'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => 'SUI Excess '
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => 'SUI ER Subj Whable'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => 'SUI ER Pre Tax Redns'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => 'SIT Qtr Wages'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => 'SIT Withheld'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => 'SIT Gross'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => 'SIT Subj Whable'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => 'SIT Subj Nwhable'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => 'SIT Pre Tax Redns'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => 'SDI EE QTR Wages'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => 'SDI EE Taxable'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => 'SDI EE Excess'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => 'SDI EE Subj Whable'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => 'SDI Pre Tax Redns'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => 'Hours Worked'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ;

  RETURN (lv_format1);
  END;



/* This function is used to write the headers for the State of New York */

  FUNCTION formated_static_header_NY(
              p_output_file_type  in varchar2
             )
 RETURN VARCHAR2
  IS

    lv_format1          varchar2(32000);
    lv_format2          varchar2(32000);

  BEGIN

      hr_utility.set_location(gv_package_name || '.formated_static_header', 10);
      lv_format1 :=
              formated_data_string (p_input_string => 'GRE'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => 'Organization'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => 'QTR Name'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string =>  'State Code'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => 'Assignment Number'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => 'Full Name'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => 'SUI Qtr Wages'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => 'SUI ER Taxable'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => 'SUI Excess '
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => 'SUI ER Subj Whable'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => 'SUI ER Pre Tax Redns'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => 'SIT Qtr Wages'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => 'SIT Withheld'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => 'SIT Gross'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => 'SIT Subj Whable'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => 'SIT Subj Nwhable'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => 'SIT Pre Tax Redns'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => 'Annual Gross Wages'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => 'Regular Earnings'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => 'Supp Earnings(FIT)'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => 'Supp Earnings(NWFIT)'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => 'Fit NW2 Pre Tax Redns'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => 'Fit Pre Tax Ded Sbj Tax'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => 'Pre Tax Deds GRE'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ;

  RETURN (lv_format1);
  END;



  FUNCTION formated_static_data (
                   p_tax_unit_name             in varchar2
                  ,p_organization_name         in varchar2
                  ,p_qtrname                   in varchar2
                  ,p_state_abbrev              in varchar2
                  ,p_assignment_number         in varchar2
                  ,p_full_name                 in varchar2
                  ,p_sui_qtr_wages             in varchar2
                  ,p_sui_er_taxable            in varchar2
                  ,p_sui_excess                in varchar2
                  ,p_sui_er_subjwh             in varchar2
                  ,p_sui_er_pre_tax_redns      in varchar2
                  ,p_sit_qtr_wages             in varchar2
                  ,p_sit_withheld              in varchar2
                  ,p_sit_gross                 in varchar2
                  ,p_sit_subjwh                in varchar2
                  ,p_sit_subjnwh               in varchar2
                  ,p_sit_pre_tax_redns         in varchar2
                  ,p_hours_worked              in varchar2
		  ,p_weeks_worked 		in varchar2
                  ,p_output_file_type          in varchar2
             )
RETURN VARCHAR2
  IS

    lv_format1 VARCHAR2(32000);
    lv_format2 VARCHAR2(32000);


  BEGIN

      hr_utility.set_location(gv_package_name || '.formated_static_data', 10);
      lv_format1 :=
              formated_data_string (p_input_string => p_tax_unit_name
                                   ,p_output_file_type => p_output_file_type)||
              formated_data_string (p_input_string => p_organization_name
                                   ,p_output_file_type => p_output_file_type)||
              formated_data_string (p_input_string => p_qtrname
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => p_state_abbrev
                                   ,p_output_file_type => p_output_file_type)||
              formated_data_string (p_input_string => p_assignment_number
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => p_full_name
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => p_sui_qtr_wages
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => p_sui_er_taxable
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => p_sui_excess
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => p_sui_er_subjwh
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => p_sui_er_pre_tax_redns
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => p_sit_qtr_wages
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => p_sit_withheld
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => p_sit_gross
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => p_sit_subjwh
                                   ,p_output_file_type => p_output_file_type)||
              formated_data_string (p_input_string => p_sit_subjnwh
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => p_sit_pre_tax_redns
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => p_hours_worked
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => p_weeks_worked
                                   ,p_output_file_type => p_output_file_type) ;

      hr_utility.set_location(gv_package_name || '.formated_static_data', 20);


  --    p_static_data1 := lv_format1;
  --     p_static_data2 := lv_format2;
      hr_utility.trace('Static Data1 = ' || lv_format1);
      hr_utility.trace('Static Data2 = ' || lv_format2);
      hr_utility.set_location(gv_package_name || '.formated_static_data', 40);

      return (lv_format1);
  END;



  FUNCTION formated_static_data_CA (
                   p_tax_unit_name             in varchar2
                  ,p_organization_name         in varchar2
                  ,p_qtrname                   in varchar2
                  ,p_state_abbrev              in varchar2
                  ,p_assignment_number         in varchar2
                  ,p_full_name                 in varchar2
                  ,p_sui_qtr_wages             in varchar2
                  ,p_sui_er_taxable            in varchar2
                  ,p_sui_excess                in varchar2
                  ,p_sui_er_subjwh             in varchar2
                  ,p_sui_er_pre_tax_redns      in varchar2
                  ,p_sit_qtr_wages             in varchar2
                  ,p_sit_withheld              in varchar2
                  ,p_sit_gross                 in varchar2
                  ,p_sit_subjwh                in varchar2
                  ,p_sit_subjnwh               in varchar2
                  ,p_sit_pre_tax_redns         in varchar2
                  ,p_sdi_qtr_wages             in varchar2
                  ,p_sdi_taxable               in varchar2
                  ,p_sdi_excess                in varchar2
                  ,p_sdi_subjwh                in varchar2
                  ,p_sdi_pre_tax_redns         in varchar2
                  ,p_hours_worked              in varchar2
                  ,p_output_file_type          in varchar2
             )
RETURN VARCHAR2
  IS

    lv_format1 VARCHAR2(32000);
    lv_format2 VARCHAR2(32000);


  BEGIN

      hr_utility.set_location(gv_package_name || '.formated_static_data', 10);
      lv_format1 :=
              formated_data_string (p_input_string => p_tax_unit_name
                                   ,p_output_file_type => p_output_file_type)||
              formated_data_string (p_input_string => p_organization_name
                                   ,p_output_file_type => p_output_file_type)||
              formated_data_string (p_input_string => p_qtrname
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => p_state_abbrev
                                   ,p_output_file_type => p_output_file_type)||
              formated_data_string (p_input_string => p_assignment_number
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => p_full_name
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => p_sui_qtr_wages
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => p_sui_er_taxable
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => p_sui_excess
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => p_sui_er_subjwh
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => p_sui_er_pre_tax_redns
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => p_sit_qtr_wages
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => p_sit_withheld
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => p_sit_gross
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => p_sit_subjwh
                                   ,p_output_file_type => p_output_file_type)||
              formated_data_string (p_input_string => p_sit_subjnwh
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => p_sit_pre_tax_redns
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => p_sdi_qtr_wages
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => p_sdi_taxable
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => p_sdi_excess
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => p_sdi_subjwh
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => p_sdi_pre_tax_redns
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => p_hours_worked
                                   ,p_output_file_type => p_output_file_type) ;

      hr_utility.set_location(gv_package_name || '.formated_static_data', 20);


      hr_utility.trace('Static Data1 = ' || lv_format1);
      hr_utility.trace('Static Data2 = ' || lv_format2);
      hr_utility.set_location(gv_package_name || '.formated_static_data', 40);

      return (lv_format1);
  END;

  FUNCTION formated_static_data_NM (
                   p_tax_unit_name             in varchar2
                  ,p_organization_name         in varchar2
                  ,p_qtrname                   in varchar2
                  ,p_state_abbrev              in varchar2
                  ,p_assignment_number         in varchar2
                  ,p_full_name                 in varchar2
                  ,p_sui_qtr_wages             in varchar2
                  ,p_sui_er_taxable            in varchar2
                  ,p_sui_excess                in varchar2
                  ,p_sui_er_subjwh             in varchar2
                  ,p_sui_er_pre_tax_redns      in varchar2
                  ,p_sit_qtr_wages             in varchar2
                  ,p_sit_withheld              in varchar2
                  ,p_sit_gross                 in varchar2
                  ,p_sit_subjwh                in varchar2
                  ,p_sit_subjnwh               in varchar2
                  ,p_sit_pre_tax_redns         in varchar2
                  ,p_sdi_qtr_wages             in varchar2
                  ,p_sdi_taxable               in varchar2
                  ,p_sdi_excess                in varchar2
                  ,p_sdi_subjwh                in varchar2
                  ,p_sdi_pre_tax_redns         in varchar2
                  ,p_hours_worked              in varchar2
  		  ,p_weeks_worked            in varchar2
                  ,p_workers_compensation2_er in varchar2
                  ,p_workers_comp2_withheld in varchar2
                  ,p_workers_comp_withheld in varchar2
                  ,p_output_file_type          in varchar2
             )
RETURN VARCHAR2
  IS

    lv_format1 VARCHAR2(32000);
    lv_format2 VARCHAR2(32000);


  BEGIN

      hr_utility.set_location(gv_package_name || '.formated_static_data_NM', 10);
      lv_format1 :=
              formated_data_string (p_input_string => p_tax_unit_name
                                   ,p_output_file_type => p_output_file_type)||
              formated_data_string (p_input_string => p_organization_name
                                   ,p_output_file_type => p_output_file_type)||
              formated_data_string (p_input_string => p_qtrname
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => p_state_abbrev
                                   ,p_output_file_type => p_output_file_type)||
              formated_data_string (p_input_string => p_assignment_number
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => p_full_name
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => p_sui_qtr_wages
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => p_sui_er_taxable
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => p_sui_excess
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => p_sui_er_subjwh
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => p_sui_er_pre_tax_redns
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => p_sit_qtr_wages
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => p_sit_withheld
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => p_sit_gross
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => p_sit_subjwh
                                   ,p_output_file_type => p_output_file_type)||
              formated_data_string (p_input_string => p_sit_subjnwh
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => p_sit_pre_tax_redns
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => p_sdi_qtr_wages
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => p_sdi_taxable
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => p_sdi_excess
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => p_sdi_subjwh
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => p_sdi_pre_tax_redns
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => p_hours_worked
                                   ,p_output_file_type => p_output_file_type)||
              formated_data_string (p_input_string => p_weeks_worked
                                   ,p_output_file_type => p_output_file_type)||
              formated_data_string (p_input_string => p_workers_compensation2_er
                                   ,p_output_file_type => p_output_file_type)||
              formated_data_string (p_input_string => p_workers_comp2_withheld
                                   ,p_output_file_type => p_output_file_type)||
              formated_data_string (p_input_string => p_workers_comp_withheld
                                   ,p_output_file_type => p_output_file_type) ;

      hr_utility.set_location(gv_package_name || '.formated_static_data', 20);

      hr_utility.trace('Static Data1 = ' || lv_format1);
      hr_utility.trace('Static Data2 = ' || lv_format2);
      hr_utility.set_location(gv_package_name || '.formated_static_data', 40);

      return (lv_format1);
  END;


  FUNCTION formated_static_data_NY (
                   p_tax_unit_name             in varchar2
                  ,p_organization_name         in varchar2
                  ,p_qtrname                   in varchar2
                  ,p_state_abbrev              in varchar2
                  ,p_assignment_number         in varchar2
                  ,p_full_name                 in varchar2
                  ,p_sui_qtr_wages             in varchar2
                  ,p_sui_er_taxable            in varchar2
                  ,p_sui_excess                in varchar2
                  ,p_sui_er_subjwh             in varchar2
                  ,p_sui_er_pre_tax_redns      in varchar2
                  ,p_sit_qtr_wages             in varchar2
                  ,p_sit_withheld              in varchar2
                  ,p_sit_gross                 in varchar2
                  ,p_sit_subjwh                in varchar2
                  ,p_sit_subjnwh               in varchar2
                  ,p_sit_pre_tax_redns         in varchar2
                  ,p_annual_gross_wages        in varchar2
                  ,p_regular_earnings_pgy      in varchar2
                  ,p_supp_fit_stt_pgy          in varchar2
                  ,p_supp_nwfit_stt_pgy        in varchar2
                  ,p_fit_non_w2_pre_tax_pgy    in varchar2
                  ,p_pre_tax_dedns_fit_stt_pgy in varchar2
                  ,p_pre_tax_dedns_pgy         in varchar2
                  ,p_output_file_type          in varchar2
             )
RETURN VARCHAR2
  IS

    lv_format1 VARCHAR2(32000);
    lv_format2 VARCHAR2(32000);


  BEGIN

      hr_utility.set_location(gv_package_name || '.formated_static_data', 10);
      lv_format1 :=
              formated_data_string (p_input_string => p_tax_unit_name
                                   ,p_output_file_type => p_output_file_type)||
              formated_data_string (p_input_string => p_organization_name
                                   ,p_output_file_type => p_output_file_type)||
              formated_data_string (p_input_string => p_qtrname
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => p_state_abbrev
                                   ,p_output_file_type => p_output_file_type)||
              formated_data_string (p_input_string => p_assignment_number
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => p_full_name
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => p_sui_qtr_wages
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => p_sui_er_taxable
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => p_sui_excess
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => p_sui_er_subjwh
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => p_sui_er_pre_tax_redns
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => p_sit_qtr_wages
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => p_sit_withheld
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => p_sit_gross
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => p_sit_subjwh
                                   ,p_output_file_type => p_output_file_type)||
              formated_data_string (p_input_string =>  p_sit_subjnwh
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => p_sit_pre_tax_redns
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => p_annual_gross_wages
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => p_regular_earnings_pgy
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => p_supp_fit_stt_pgy
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => p_supp_nwfit_stt_pgy
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => p_fit_non_w2_pre_tax_pgy
                                   ,p_output_file_type => p_output_file_type)||
              formated_data_string (p_input_string =>p_pre_tax_dedns_fit_stt_pgy
                                   ,p_output_file_type => p_output_file_type)||
              formated_data_string (p_input_string => p_pre_tax_dedns_pgy
                                   ,p_output_file_type => p_output_file_type);


      hr_utility.set_location(gv_package_name || '.formated_static_data', 20);


      hr_utility.trace('Static Data1 = ' || lv_format1);
      hr_utility.trace('Static Data2 = ' || lv_format2);
      hr_utility.set_location(gv_package_name || '.formated_static_data', 40);

      return (lv_format1);
  END;



PROCEDURE insert_error(errbuf               OUT nocopy    VARCHAR2,
                       retcode              OUT nocopy     NUMBER,
                       p_payroll_action_id  IN      NUMBER,
                       p_qtrname            IN      VARCHAR2) is

     cursor c_assignments (cp_payroll_action_id in number) is
     SELECT hou.name,
            full_name,
            paa.assignment_action_id,
            paa.assignment_id,
            paa.tax_unit_id,
            state_code,
            paf.assignment_number,
            hou1.name,
            pus.state_abbrev,
            ppa.report_category
     FROM   pay_us_states            pus,
            hr_organization_units    hou,
            hr_organization_units    hou1,
            per_people_f             ppf,
            per_assignments_f        paf,
            pay_assignment_actions   paa,
            pay_payroll_actions      ppa
    WHERE   ppa.payroll_action_id     = p_payroll_action_id
      AND   ppa.payroll_action_id     = paa.payroll_action_id
      AND   paa.assignment_id         = paf.assignment_id
      /* Added for bug 2506588 */
      AND   paf.effective_start_date =
                    (select max(paf2.effective_start_date)
                     from per_assignments_f paf2
                     where paf2.assignment_id = paf.assignment_id
                     and paf2.effective_start_date <= ppa.effective_date)
      AND paf.effective_end_date >= ppa.start_date
      AND paf.assignment_type = 'E'
      /* Commented for bug 2506588
      AND   ppa.effective_date          between paf.effective_start_date
                                            and paf.effective_end_date*/
      AND   paf.person_id             = ppf.person_id
      AND   ppa.effective_date          between ppf.effective_start_date
                                            and ppf.effective_end_date
      AND   paa.tax_unit_id           = hou.organization_id
      AND   report_qualifier          = pus.state_abbrev
      and   paf.organization_id       = hou1.organization_id;
/*sackumar*/
      cursor c_archive_dtls(cp_asg_act_id in number,
                            cp_tax_unit_id in number,
                            cp_state_code in varchar2) is
      select fdi.user_name,fai.value
        from ff_database_items fdi,
             ff_archive_items fai,
             ff_archive_item_contexts fac,
             ff_archive_item_contexts fac1,
             ff_contexts fc,
             ff_contexts fc1
        where fai.user_entity_id = fdi.user_entity_id
        and fai.context1 = to_char(cp_asg_act_id)
                /* context assignment action id */
        and fac.archive_item_id = fai.archive_item_id
        and fc.context_name = 'TAX_UNIT_ID'
        and fc.context_id = fac.context_id
        and ltrim(rtrim(fac.context)) = to_char(cp_tax_unit_id)
                /* 2nd context of tax_unit_id */
        and fac1.archive_item_id = fai.archive_item_id
        and fc1.context_name = 'JURISDICTION_CODE'
        and fc1.context_id = fac1.context_id
        and substr(fac1.context,1,2) = substr(cp_state_code,1,2)  ;

      cursor c_archive_dtls_fed(cp_asg_act_id in number,
                            cp_tax_unit_id in number) is
      select fdi.user_name,fai.value
        from ff_database_items fdi,
             ff_archive_items fai,
             ff_archive_item_contexts fac,
             ff_contexts fc
        where fai.user_entity_id = fdi.user_entity_id
        and fai.context1 = to_char(cp_asg_act_id)
                /* context assignment action id */
        and fc.context_name = 'TAX_UNIT_ID'
        and fc.context_id = fac.context_id
        and fac.archive_item_id = fai.archive_item_id
        and ltrim(rtrim(fac.context)) = to_char(cp_tax_unit_id);
                             /* 2nd context of tax_unit_id */

        cursor c_state (cp_payroll_action_id in number) is
        select report_qualifier,business_group_id
          from pay_payroll_actions
         where payroll_action_id = cp_payroll_action_id;

       cursor c_get_asg_details(p_asg_action_id in number,
					    p_asg_id in number) is
       select fdi.user_name,fai.value
        from ff_database_items fdi,
             ff_archive_items fai,
             ff_archive_item_contexts fac,
             ff_contexts fc
        where fai.user_entity_id = fdi.user_entity_id
        and fai.context1 = to_char(p_asg_action_id)
                /* context assignment action id */
        and fc.context_name = 'ASSIGNMENT_ID'
        and fc.context_id = fac.context_id
        and fac.archive_item_id = fai.archive_item_id
        and ltrim(rtrim(fac.context)) = to_char(p_asg_id)
        and user_name in ('A_SCL_ASG_US_WORK_SCHEDULE','A_ASG_HOURS','A_ASG_FREQ');

       /* Bug:3044939 */
       cursor c_get_hour_calc_method(p_tax_unit_id in number) is
       select org_information14
       from hr_organization_information hoi
       where org_information_context like 'SQWL GN Transmitter Rules%'
       and  hoi.organization_id = p_tax_unit_id;

      TYPE numeric_table IS TABLE OF number(20,2)
                           INDEX BY BINARY_INTEGER;

      TYPE text_table IS TABLE OF varchar2(2000)
                           INDEX BY BINARY_INTEGER;

      lv_tax_unit_name   varchar2(60);
      lv_full_name       varchar2(240);
      lv_full_name_wc    varchar2(240);
      ln_asg_act_id      number;
      ln_asg_id          number;
      ln_tax_unit_id     number;
      lv_state_code      varchar2(2);
      lv_user_name       varchar2(80);
      lv_value           varchar2(240) ;
      lv_gross_earnings  varchar2(240) ;
      lv_sui_er_gross    varchar2(240) ;
      lv_sui_er_125      varchar2(240) ;
      lv_sui_er_401      varchar2(240) ;
      lv_sui_er_depcare  varchar2(240) ;
      lv_sui_er_subjwh   varchar2(240) ;
      lv_sui_er_taxable  varchar2(240) ;
      lv_sui_ee_withheld varchar2(240) ;
      lv_sui_qtr_wages   varchar2(240) ;
      lv_sui_excess      varchar2(240) ;
      lv_sit_gross       varchar2(240) ;
      lv_sit_subjwh      varchar2(240) ;
      lv_sit_subjnwh     varchar2(240) ;
      lv_sit_125         varchar2(240) ;
      lv_sit_401         varchar2(240) ;
      lv_sit_depcare     varchar2(240) ;
      lv_sit_withheld    varchar2(240) ;
      lv_sit_qtr_wages   varchar2(240) ;
      lv_sdi_qtr_wages   varchar2(240) ;
      lv_sdi_taxable     varchar2(240) ;
      lv_sdi_excess      varchar2(240) ;
      lv_sdi_subjwh      varchar2(240) ;
      lv_sdi_125         varchar2(240) ;
      lv_sdi_401         varchar2(240) ;
      lv_sdi_depcare      varchar2(240);
      lv_annual_gross_wages  varchar2(240) ;
      lv_regular_earnings_pgy  varchar2(240) ;
      lv_supp_fit_stt_pgy  varchar2(240) ;
      lv_supp_nwfit_stt_pgy  varchar2(240) ;
      lv_def_comp_401_pry  varchar2(240) ;
      lv_sec_125_pgy  varchar2(240) ;
      lv_sit_withheld_pjgy  varchar2(240) ;
      lv_dep_care_pgy  varchar2(240) ;
      lv_hours_worked    varchar2(240) ;
      lv_regular_hrs_pgq varchar2(240) ;
      lv_organization_name varchar2(240):=null ;
      lv_assignment_number varchar2(240):=null ;
      ln_count_rpt_total   number:= 0;
      lv_state_abbrev    varchar2(2) :=null;
      lv_report_category varchar2(30):=null;
      lv_neg_asg_count      number :=0 ;

      lv_sui_er_pre_tax_redns   varchar2(240);
      lv_sit_pre_tax_redns      varchar2(240);
      lv_sdi_pre_tax_redns      varchar2(240);


      lv_pre_tax_dedns_fit_stt_pgy varchar2(240);
      lv_fit_non_w2_pre_tax_pgy    varchar2(240);
      lv_pre_tax_dedns_pgy         varchar2(240);

/*Bug# 5333916*/
      lv_workers_compensation2_er varchar2(240);
      lv_workers_comp2_withheld varchar2(240);
      lv_workers_comp_withheld varchar2(240);

      lv_char_value                number;
      lv_hours_worked_calc_method varchar2(240);
      lv_sui_sick_hours           varchar2(240);
      lv_sui_vacation_hours       varchar2(240);
      lv_sui_regular_hours        varchar2(240);
      lv_sui_overtime_hours       varchar2(240);
      lv_work_schedule            varchar2(240) := NULL;
      lv_hours_per_week           NUMBER := 40;
      lv_weeks_worked             NUMBER := 0;
      lv_asg_freq		  varchar2(240) := 'Week';
      lv_asg_hours		  varchar2(240) := NULL;
      lv_bgrp_id		  NUMBER;
      lv_add_days		  DATE;

BEGIN

     --hr_utility.trace_on (null, 'SQWLNEG');
     hr_utility.trace ('Entered Main package');
     hr_utility.trace ('Payroll Action Id = '||to_char(p_payroll_action_id));
     hr_utility.trace ('Qtrname = '||p_qtrname);


     open c_assignments(p_payroll_action_id);
     hr_utility.trace ('Opened c_assignment cursor');
     loop

     /* Initialixe variables */

      lv_user_name              := null;
      lv_value                  := null;
      lv_gross_earnings         := null ;
      lv_sui_er_gross           := null ;
      lv_sui_er_subjwh          := null ;
      lv_sui_er_taxable         := null ;
      lv_sui_ee_withheld        := null ;
      lv_sui_qtr_wages          := null ;
      lv_sui_excess             := null ;
      lv_sit_gross              := null ;
      lv_sit_subjwh             := null ;
      lv_sit_subjnwh            := null ;
      lv_sit_125                := null ;
      lv_sit_401                := null ;
      lv_sit_depcare            := null ;
      lv_sit_withheld           := null ;
      lv_sit_qtr_wages          := null ;
      lv_sdi_qtr_wages          := null ;
      lv_sdi_taxable            := null ;
      lv_sdi_excess             := null ;
      lv_annual_gross_wages     := null ;
      lv_regular_earnings_pgy   := null ;
      lv_supp_fit_stt_pgy       := null ;
      lv_supp_nwfit_stt_pgy     := null ;
      lv_def_comp_401_pry       := null ;
      lv_sec_125_pgy            := null ;
      lv_sit_withheld_pjgy      := null ;
      lv_dep_care_pgy           := null ;
      lv_hours_worked           := null ;
      lv_regular_hrs_pgq        := null ;

      lv_sdi_pre_tax_redns      := null;
      lv_sui_er_pre_tax_redns   := null;
      lv_sit_pre_tax_redns      := null;

      lv_pre_tax_dedns_fit_stt_pgy := null;
      lv_fit_non_w2_pre_tax_pgy    := null;
      lv_pre_tax_dedns_pgy         := null;

      lv_workers_compensation2_er := null ;
      lv_workers_comp2_withheld := null ;
      lv_workers_comp_withheld := null ;

      lv_char_value                := 0;


   /* rosie monge added the following */

      lv_hours_worked_calc_method := 'W';

      lv_sui_sick_hours       := null;
      lv_sui_vacation_hours   := null;
      lv_sui_regular_hours    := null;
      lv_sui_overtime_hours   := null;

/* end of code rosie monge added */

     fetch c_assignments into lv_tax_unit_name,
                              lv_full_name_wc,
                              ln_asg_act_id,
                              ln_asg_id,
                              ln_tax_unit_id,
                              lv_state_code,
                              lv_assignment_number,
                              lv_organization_name,
                              lv_state_abbrev,
                              lv_report_category;

      if c_assignments%NOTFOUND then
             if c_assignments%ROWCOUNT = 0  then
                hr_utility.trace('Into Row Count = 0 ');
                lv_state_abbrev := null;

                open c_state(p_payroll_action_id);
                fetch c_state into lv_state_abbrev,lv_bgrp_id;
                if c_state%notfound then
                   exit;
                end if;
                close c_state;

                if lv_state_abbrev = 'CA' then

                   insert into pay_us_rpt_totals (gre_name,
                                                  organization_name,
                                                  attribute2,
                                                  attribute3,
                                                  attribute30)
                   values(p_qtrname,lv_state_abbrev,
                         'No assignment actions have been created by the State quarterly Wage listing process.State Tax Rules may not have been defined properly','For California there could a setup issue related with Single/Multiple Wage plan',
                  'STATE_QUARTERLY_ERROR_REPORT');
                else

                   insert into pay_us_rpt_totals (gre_name,
                                                  organization_name,
                                                  attribute2,
                                                  attribute30)
                   values(p_qtrname,lv_state_abbrev,
                         'No assignment actions have been created by the State quarterly Wage listing process.State Tax Rules may not have been defined properly',
                  'STATE_QUARTERLY_ERROR_REPORT');

             end if;

             end if;
             exit;
       end if;
       lv_full_name := replace(lv_full_name_wc,',');

      hr_utility.trace('ln_asg_id ='||to_char(ln_asg_id));
      hr_utility.trace('ln_asg_act_id ='||to_char(ln_asg_act_id));
      hr_utility.trace('ln_tax_unit_id ='||to_char(ln_tax_unit_id));
      hr_utility.trace('lv_full_name ='||lv_full_name);
      hr_utility.trace('lv_full_name_wc ='||lv_full_name_wc);
      hr_utility.trace('lv_state_code ='||lv_state_code);
      hr_utility.trace('lv_report_category ='||lv_report_category);

     open c_archive_dtls(ln_asg_act_id,
                         ln_tax_unit_id,
                         lv_state_code);
     hr_utility.trace('Opened c_archive_dtls');
     loop
     fetch c_archive_dtls into lv_user_name
                              ,lv_value;

         if c_archive_dtls%NOTFOUND then
            exit;
         end if ;

         if lv_user_name = 'A_SUI_ER_GROSS_PER_JD_GRE_QTD' then
            lv_sui_er_gross := lv_value;
         elsif lv_user_name = 'A_SUI_ER_SUBJ_WHABLE_PER_JD_GRE_QTD' then
            lv_sui_er_subjwh := lv_value;
         elsif lv_user_name = 'A_SUI_ER_TAXABLE_PER_JD_GRE_QTD' then
            lv_sui_er_taxable := lv_value;
         elsif lv_user_name = 'A_SUI_EE_WITHHELD_PER_JD_GRE_QTD' then
            lv_sui_ee_withheld := lv_value;
         elsif lv_user_name = 'A_SUI_ER_PRE_TAX_REDNS_PER_JD_GRE_QTD' then
            lv_sui_er_pre_tax_redns := lv_value;
         elsif lv_user_name = 'A_SIT_GROSS_PER_JD_GRE_QTD' then
            lv_sit_gross := lv_value;
         elsif lv_user_name = 'A_SIT_SUBJ_WHABLE_PER_JD_GRE_QTD' then
            lv_sit_subjwh := lv_value;
         elsif lv_user_name = 'A_SIT_SUBJ_NWHABLE_PER_JD_GRE_QTD' then
            lv_sit_subjnwh := lv_value;

         elsif lv_user_name = 'A_SIT_WITHHELD_PER_JD_GRE_QTD' then
            lv_sit_withheld := lv_value;
         elsif lv_user_name = 'A_SIT_WITHHELD_PER_JD_GRE_YTD' then
            lv_sit_withheld_pjgy := lv_value;

         elsif lv_user_name = 'A_SIT_PRE_TAX_REDNS_PER_JD_GRE_QTD' then
            lv_sit_pre_tax_redns := lv_value;

         elsif lv_user_name = 'A_SDI_EE_PRE_TAX_REDNS_PER_JD_GRE_QTD' then
            lv_sdi_pre_tax_redns := lv_value;

         elsif lv_user_name = 'A_SDI_EE_SUBJ_WHABLE_PER_JD_GRE_QTD' then
            lv_sdi_subjwh := lv_value;

         elsif lv_user_name = 'A_SDI_EE_TAXABLE_PER_JD_GRE_QTD' then
            lv_sdi_taxable := lv_value;

/* rosie monge added the following code */

         elsif lv_user_name = 'A_SUI_SICK_HOURS_BY_STATE_PER_JD_GRE_QTD' then
            lv_sui_sick_hours := lv_value;

         elsif lv_user_name ='A_SUI_VACATION_HOURS_BY_STATE_PER_JD_GRE_QTD' then
            lv_sui_vacation_hours := lv_value;

         elsif lv_user_name ='A_SUI_REGULAR_HOURS_BY_STATE_PER_JD_GRE_QTD' then
            lv_sui_regular_hours := lv_value;

         elsif lv_user_name ='A_SUI_OVERTIME_HOURS_BY_STATE_PER_JD_GRE_QTD' then
            lv_sui_overtime_hours := lv_value;

         elsif lv_user_name ='A_WORKERS_COMPENSATION2_ER_PER_JD_GRE_QTD' then
            lv_workers_compensation2_er := lv_value;

         elsif lv_user_name ='A_WORKERS_COMP2_WITHHELD_PER_JD_GRE_QTD' then
            lv_workers_comp2_withheld := lv_value;

         elsif lv_user_name ='A_WORKERS_COMP_WITHHELD_PER_JD_GRE_QTD' then
            lv_workers_comp_withheld := lv_value;

         end if;

     end loop;
     close c_archive_dtls;


         open c_archive_dtls_fed(ln_asg_act_id,
                                 ln_tax_unit_id);
         hr_utility.trace('Opened c_archive_dtls_fed');
         loop
         fetch c_archive_dtls_fed into lv_user_name
                                      ,lv_value;

           if c_archive_dtls_fed%NOTFOUND then
              exit;
           end if ;

          if lv_user_name = 'A_REGULAR_EARNINGS_PER_GRE_YTD' then
             lv_regular_earnings_pgy := lv_value;
          elsif lv_user_name =  'A_SUPPLEMENTAL_EARNINGS_FOR_FIT_SUBJECT_TO_TAX_PER_GRE_YTD' then
             lv_supp_fit_stt_pgy := lv_value;
          elsif lv_user_name =  'A_SUPPLEMENTAL_EARNINGS_FOR_NWFIT_SUBJECT_TO_TAX_PER_GRE_YTD' then
              lv_supp_nwfit_stt_pgy := lv_value;
          elsif lv_user_name = 'A_DEF_COMP_401K_PER_GRE_YTD' then
              lv_def_comp_401_pry := lv_value;
          elsif lv_user_name = 'A_SECTION_125_PER_GRE_YTD' then
              lv_sec_125_pgy := lv_value;
          elsif lv_user_name = 'A_DEPENDENT_CARE_PER_GRE_YTD' then
              lv_dep_care_pgy := lv_value;
          elsif lv_user_name = 'A_REGULAR_HOURS_WORKED_PER_GRE_QTD' then
              lv_regular_hrs_pgq := lv_value;
          elsif lv_user_name = 'A_GROSS_EARNINGS_PER_GRE_QTD' then
            lv_gross_earnings := lv_value;
         elsif lv_user_name = 'A_PRE_TAX_DEDUCTIONS_FOR_FIT_SUBJECT_TO_TAX_PER_GRE_YTD' then
            lv_pre_tax_dedns_fit_stt_pgy := lv_value;
         elsif lv_user_name = 'A_FIT_NON_W2_PRE_TAX_DEDNS_PER_GRE_YTD' then
            lv_fit_non_w2_pre_tax_pgy := lv_value;
         elsif lv_user_name = 'A_PRE_TAX_DEDUCTIONS_PER_GRE_YTD' then
            lv_pre_tax_dedns_pgy := lv_value;
         end if;

     end loop;
     close c_archive_dtls_fed;

     FOR I in c_get_asg_details(ln_asg_act_id, ln_asg_id)
     LOOP
         IF I.user_name = 'A_SCL_ASG_US_WORK_SCHEDULE' THEN
          hr_utility.trace('Getting A_SCL_ASG_US_WORK_SCHEDULE ');
           lv_work_schedule := I.value;
         ELSIF I.user_name = 'A_ASG_HOURS' THEN
            lv_asg_hours := I.value;
         ELSIF I.user_name = 'A_ASG_FREQ' THEN
            lv_asg_freq := I.value;
         END IF;
     END LOOP;

        hr_utility.trace('A_SCL_ASG_US_WORK_SCHEDULE ' ||lv_work_schedule);
        hr_utility.trace('A_ASG_HOURS ' ||lv_asg_hours);
        hr_utility.trace('A_ASG_FREQ ' ||lv_asg_freq);

     /* Need business group id for calculating weeks worked */

     OPEN c_state(p_payroll_action_id);
     FETCH c_state INTO lv_state_abbrev,lv_bgrp_id;
     IF c_state%NOTFOUND THEN
           EXIT;
     END IF;
     CLOSE c_state;

      /* calculate the derived balances here */
         hr_utility.trace('Going to calculate derived balances');

         lv_sui_qtr_wages :=   lv_sui_er_subjwh - lv_sui_er_pre_tax_redns;
         lv_sui_excess  :=   lv_sui_qtr_wages - lv_sui_er_taxable;
         lv_sit_qtr_wages :=   lv_sit_subjwh + lv_sit_subjnwh - lv_sit_pre_tax_redns;
         lv_sdi_qtr_wages :=    lv_sdi_subjwh - lv_sdi_pre_tax_redns;
         lv_sdi_excess    :=    lv_sdi_subjwh - lv_sdi_pre_tax_redns - lv_sdi_taxable;

            hr_utility.trace('lv_tax_unit_name ='||lv_tax_unit_name);
            hr_utility.trace('lv_organization_name ='||lv_organization_name);
            hr_utility.trace('lv_state_abbrev ='||lv_state_abbrev);
            hr_utility.trace('Qtrname ='||p_qtrname);
            hr_utility.trace('lv_assignment_number ='||lv_assignment_number);
            hr_utility.trace('lv_full_name ='||lv_full_name);
            hr_utility.trace('lv_gross_earnings ='||lv_gross_earnings);
            hr_utility.trace('lv_sui_er_gross ='||lv_sui_er_gross);
            hr_utility.trace('lv_sui_er_125 ='||lv_sui_er_125);
            hr_utility.trace('lv_sui_er_401 ='||lv_sui_er_401);
            hr_utility.trace('lv_sui_er_depcare ='||lv_sui_er_depcare);
            hr_utility.trace('lv_sui_er_subjwh ='||lv_sui_er_subjwh);
            hr_utility.trace('lv_sui_er_taxable ='||lv_sui_er_taxable);
            hr_utility.trace('lv_sui_qtr_wages ='||lv_sui_qtr_wages);
            hr_utility.trace('lv_sui_excess ='||lv_sui_excess);
            hr_utility.trace('lv_sit_gross ='||lv_sit_gross);
            hr_utility.trace('lv_sit_subjwh ='||lv_sit_subjwh);
            hr_utility.trace('lv_sit_subjnwh ='||lv_sit_subjnwh);
            hr_utility.trace('lv_sit_125 ='||lv_sit_125);
            hr_utility.trace('lv_sit_401 ='||lv_sit_401);
            hr_utility.trace('lv_sit_depcare ='||lv_sit_depcare);
            hr_utility.trace('lv_sit_withheld ='||lv_sit_withheld);
            hr_utility.trace('lv_sit_qtr_wages ='||lv_sit_qtr_wages);
            hr_utility.trace('lv_hours_worked ='||lv_hours_worked);
            hr_utility.trace('lv_annual_gross_wages ='||lv_annual_gross_wages);
            hr_utility.trace('lv_regular_earngs_pgy='||lv_regular_earnings_pgy);
            hr_utility.trace('lv_supp_fit_stt_pgy ='||lv_supp_fit_stt_pgy);
            hr_utility.trace('lv_supp_fit_stt_pgy ='||lv_supp_fit_stt_pgy);
            hr_utility.trace('lv_supp_nwfit_stt_pgy ='||lv_supp_nwfit_stt_pgy);
            hr_utility.trace('lv_def_comp_401_pry ='||lv_def_comp_401_pry);
            hr_utility.trace('lv_sec_125_pgy ='||lv_sec_125_pgy);
            hr_utility.trace('lv_sit_withheld_pjgy ='||lv_sit_withheld_pjgy);
            hr_utility.trace('lv_dep_care_pgy ='||lv_dep_care_pgy);
            hr_utility.trace('lv_hours_worked_calculation_method='|| lv_hours_worked_calc_method );
            hr_utility.trace('lv_sui_sick_hours_by_state_per_jd_gre_qtd ='|| lv_sui_sick_hours);
            hr_utility.trace('lv_sui_vacation_hours_by_state_per_jd_gre_qtd =' || lv_sui_vacation_hours);
            hr_utility.trace('lv_sui_regular_hours_by_state_per_jd_gre_qtd =' || lv_sui_regular_hours);
            hr_utility.trace('lv_sui_overtime_hours_by_state_per_jd_gre_qtd =' || lv_sui_overtime_hours);
            hr_utility.trace('lv_work_schedule ='||lv_work_schedule);


         /* regular hours */

         IF lv_gross_earnings <> '0' then

         /* This query selects the value for the Flag Hours Worked Calculation Method  */

            OPEN c_get_hour_calc_method(ln_tax_unit_id);
            FETCH c_get_hour_calc_method INTO lv_Hours_Worked_Calc_Method;

            /* Bug:3044939 */
            IF c_get_hour_calc_method%NOTFOUND THEN

               lv_Hours_Worked_Calc_Method := 'W'; --Default Value
                hr_utility.trace('NO Data found. So setting c_get_hour_calc_method to default value');

           END IF;

           CLOSE c_get_hour_calc_method;

            hr_utility.trace('lv_hours_worked_calc_method '||lv_hours_worked_calc_method);

         /* We have the Calculation Method. Lets calculate the hours and weeks worked */

           IF nvl(lv_Hours_Worked_Calc_Method,'W') = 'W' then

                  lv_hours_worked :=
                  (lv_regular_hrs_pgq *
                  lv_sui_er_gross/lv_gross_earnings);

           ELSIF lv_Hours_Worked_Calc_Method ='B' then

                  lv_hours_worked := nvl(to_number(lv_sui_sick_hours),0)
               +  nvl(to_number(lv_sui_vacation_hours),0)
               +  nvl(to_number(lv_sui_regular_hours),0)
               +  nvl(to_number(lv_sui_overtime_hours),0);

           END IF;

           hr_utility.trace('lv_hours_worked =' || lv_hours_worked);
           hr_utility.trace('lv_work_schedule =' || lv_work_schedule);
           hr_utility.trace('lv_asg_freq =' || lv_asg_freq);
           hr_utility.trace('lv_asg_hours =' || lv_asg_hours);


          IF (lv_work_schedule is null ) then
              lv_add_days := fffunc.add_days(sysdate,6);
              lv_hours_per_week := hr_us_ff_udfs.standard_hours_worked( lv_asg_hours,
                                                    sysdate,
                                                    lv_add_days,
                                                    lv_asg_freq);
           hr_utility.trace('lv_add_days = '||lv_add_days);
           hr_utility.trace('lv_hours_per_week = '||to_char(lv_hours_per_week));
          ELSE
             lv_hours_per_week :=  hr_us_ff_udfs.work_schedule_total_hours(lv_bgrp_id,
                                                                       lv_work_schedule,
                                                                       null,
                                                                       null);
	      hr_utility.trace('Work Schedule found = '||lv_work_schedule);
              hr_utility.trace('lv_hours_per_week = '||to_char(lv_hours_per_week));
          END IF;

          /* calculating the Weeks Worked */
           IF nvl(lv_hours_per_week,0) <> 0 THEN
         	hr_utility.trace('lv_hours_per_week <> 0 ');
          	lv_weeks_worked := round(lv_hours_worked/lv_hours_per_week);
                hr_utility.trace('lv_weeks_worked = '||to_char(lv_weeks_worked));

           	IF lv_weeks_worked > 14 THEN
                  lv_weeks_worked := 14;
           	END IF;

           END IF;
         END IF;

        /* main */

         if (lv_state_abbrev in ( 'AL' ,'AZ' ,'CO' ,'IA' ,'IL' ,'IN'
                                ,'KS' ,'KY' ,'MA' ,'ME' ,'MN' ,'MO'
                                ,'MT' ,'NC' ,'NV' ,'OH' ,'OK' ,'SC'
                                ,'TN' ,'TX' ,'VT' ,'WV' ,'MS' ,'ND'
                                ,'AR' ,'DE' ,'LA' ,'NE' ,'NH' ,'OR'
                                ,'UT' ,'VA' ,'WI' ,'WY' ,'HI' ,'MI'
                                ,'RI' ,'CT'
                               )
            or (lv_state_abbrev = 'MD' and lv_report_category ='RT')
            or (lv_state_abbrev = 'SD' and lv_report_category ='RT')) then

         BEGIN

           lv_char_value :=   to_number(lv_sui_qtr_wages);
           lv_char_value :=   to_number(lv_sui_excess);
           lv_char_value :=   to_number(lv_sui_er_taxable);
           lv_char_value :=   to_number(lv_sit_qtr_wages);
           lv_char_value :=   to_number(lv_sit_gross);
           lv_char_value :=   to_number(lv_sit_withheld);
           lv_char_value :=   to_number(lv_hours_worked);

         if (lv_sui_qtr_wages   < 0 or
             lv_sui_excess      < 0 or
             lv_sui_er_taxable  < 0 or
             lv_sit_qtr_wages   < 0 or
             lv_sit_gross       < 0 or
             lv_sit_withheld    < 0 or
             (lv_state_abbrev in ('MN' ,'VT' ,'OR' ,'WA' ,'WY' ) and lv_hours_worked < 0) or
	     (lv_state_abbrev in ('MA','DE','OH') and lv_weeks_worked < 0)
            ) THEN

         hr_utility.trace('Entered negative reporting loop');

         lv_neg_asg_count :=lv_neg_asg_count + 1 ;

           if lv_neg_asg_count = 1 then

              fnd_file.put_line(fnd_file.output,formated_Static_header('CSV'));

           end if;


          fnd_file.put_line(fnd_file.output,formated_static_data (
            lv_tax_unit_name,
            lv_organization_name,
            p_qtrname,
            lv_state_abbrev,
            lv_assignment_number,
            lv_full_name,
            lv_sui_qtr_wages,
            lv_sui_er_taxable,
            lv_sui_excess,
            lv_sui_er_subjwh,
            lv_sui_er_pre_tax_redns,
            lv_sit_qtr_wages,
            lv_sit_withheld,
            lv_sit_gross,
            lv_sit_subjwh,
            lv_sit_subjnwh,
            lv_sit_pre_tax_redns,
            lv_hours_worked,
	    lv_weeks_worked,
            'CSV'));

         end if; /* if negative then */

         EXCEPTION
             when value_error then

             lv_neg_asg_count :=lv_neg_asg_count + 1 ;

              if lv_neg_asg_count = 1 then
                 fnd_file.put_line(fnd_file.output,formated_Static_header('CSV'));
              end if;

            fnd_file.put_line(fnd_file.output,formated_static_data (
            lv_tax_unit_name,
            lv_organization_name,
            p_qtrname,
            lv_state_abbrev,
            lv_assignment_number,
            lv_full_name,
            lv_sui_qtr_wages,
            lv_sui_er_taxable,
            lv_sui_excess,
            lv_sui_er_subjwh,
            lv_sui_er_pre_tax_redns,
            lv_sit_qtr_wages,
            lv_sit_withheld,
            lv_sit_gross,
            lv_sit_subjwh,
            lv_sit_subjnwh,
            lv_sit_pre_tax_redns,
            lv_hours_worked,
   	    lv_weeks_worked,
            'CSV'));

          END;

         end if; /* ICESA or SSA states */


         if lv_state_abbrev =  'PA' then

         BEGIN
           lv_char_value :=   to_number(lv_sui_qtr_wages);
           lv_char_value :=   to_number(lv_sui_er_taxable);
           lv_char_value :=   to_number(lv_sui_excess);
           lv_char_value :=   to_number(lv_sit_qtr_wages);
           lv_char_value :=   to_number(lv_sit_gross);
           lv_char_value :=   to_number(lv_sit_withheld);
           lv_char_value :=   to_number(lv_hours_worked);


            if (lv_sui_qtr_wages   < 0 or
                lv_sui_er_taxable  < 0 or
                lv_sui_excess      < 0 or
                lv_sit_qtr_wages   < 0 or
                lv_sit_gross       < 0 or
                lv_sit_withheld    < 0 or
	            lv_weeks_worked < 0) then

            hr_utility.trace('Entered negative reporting loop');

            lv_neg_asg_count :=lv_neg_asg_count + 1 ;
            if lv_neg_asg_count = 1 then
               fnd_file.put_line(fnd_file.output,formated_Static_header('CSV'));
            end if;

            fnd_file.put_line(fnd_file.output,formated_static_data (
            lv_tax_unit_name,
            lv_organization_name,
            p_qtrname,
            lv_state_abbrev,
            lv_assignment_number,
            lv_full_name,
            lv_sui_qtr_wages,
            lv_sui_er_taxable,
            lv_sui_excess,
            lv_sui_er_subjwh,
            lv_sui_er_pre_tax_redns,
            lv_sit_qtr_wages,
            lv_sit_withheld,
            lv_sit_gross,
            lv_sit_subjwh,
            lv_sit_subjnwh,
            lv_sit_pre_tax_redns,
            lv_hours_worked,
	  		lv_weeks_worked,
            'CSV'));

            end if; /* if negative then */

         EXCEPTION

            when value_error then

            lv_neg_asg_count :=lv_neg_asg_count + 1 ;

            if lv_neg_asg_count = 1 then

               fnd_file.put_line(fnd_file.output,formated_Static_header('CSV'));

            end if;


            fnd_file.put_line(fnd_file.output,formated_static_data (
            lv_tax_unit_name,
            lv_organization_name,
            p_qtrname,
            lv_state_abbrev,
            lv_assignment_number,
            lv_full_name,
            lv_sui_qtr_wages,
            lv_sui_er_taxable,
            lv_sui_excess,
            lv_sui_er_subjwh,
            lv_sui_er_pre_tax_redns,
            lv_sit_qtr_wages,
            lv_sit_withheld,
            lv_sit_gross,
            lv_sit_subjwh,
            lv_sit_subjnwh,
            lv_sit_pre_tax_redns,
            lv_hours_worked,
			lv_weeks_worked,
            'CSV'));

         END;

         end if; /* PA */

         if lv_state_abbrev in ( 'AK','DC','GA','PR','ID') then --Custom

         BEGIN
           lv_char_value :=   to_number(lv_sui_qtr_wages);
           lv_char_value :=   to_number(lv_sui_er_taxable);
           lv_char_value :=   to_number(lv_sui_excess);
           lv_char_value :=   to_number(lv_sit_qtr_wages);
           lv_char_value :=   to_number(lv_sit_withheld);

           if (lv_sui_qtr_wages   < 0 or
               lv_sui_er_taxable  < 0 or
               lv_sui_excess      < 0 or
               lv_sit_qtr_wages   < 0 or
               lv_sit_withheld    < 0 ) then

                hr_utility.trace('Entered negative reporting loop');

                lv_neg_asg_count :=lv_neg_asg_count + 1 ;

                if lv_neg_asg_count = 1 then

                   fnd_file.put_line(fnd_file.output,formated_Static_header('CSV'));

                end if;

		  fnd_file.put_line(fnd_file.output,formated_static_data (
		    lv_tax_unit_name,
		    lv_organization_name,
		    p_qtrname,
		    lv_state_abbrev,
		    lv_assignment_number,
		    lv_full_name,
		    lv_sui_qtr_wages,
		    lv_sui_er_taxable,
		    lv_sui_excess,
		    lv_sui_er_subjwh,
		    lv_sui_er_pre_tax_redns,
		    lv_sit_qtr_wages,
		    lv_sit_withheld,
		    lv_sit_gross,
		    lv_sit_subjwh,
		    lv_sit_subjnwh,
		    lv_sit_pre_tax_redns,
		    lv_hours_worked,
		    lv_weeks_worked,
		    'CSV'));
		END IF;

         EXCEPTION

           when value_error then

                lv_neg_asg_count :=lv_neg_asg_count + 1 ;

                if lv_neg_asg_count = 1 then
                   fnd_file.put_line(fnd_file.output,formated_Static_header('CSV'));
                end if;

		  fnd_file.put_line(fnd_file.output,formated_static_data (
		    lv_tax_unit_name,
		    lv_organization_name,
		    p_qtrname,
		    lv_state_abbrev,
		    lv_assignment_number,
		    lv_full_name,
		    lv_sui_qtr_wages,
		    lv_sui_er_taxable,
		    lv_sui_excess,
		    lv_sui_er_subjwh,
		    lv_sui_er_pre_tax_redns,
		    lv_sit_qtr_wages,
		    lv_sit_withheld,
		    lv_sit_gross,
		    lv_sit_subjwh,
		    lv_sit_subjnwh,
		    lv_sit_pre_tax_redns,
		    lv_hours_worked,
		    lv_weeks_worked,
		    'CSV'));
         END;

         end if; /* Custom */

         if lv_state_abbrev ='NM' then /*Bug # 5333916 */

         BEGIN
           lv_char_value :=   to_number(lv_sui_qtr_wages);
           lv_char_value :=   to_number(lv_sui_er_taxable);
           lv_char_value :=   to_number(lv_sui_excess);
           lv_char_value :=   to_number(lv_sit_qtr_wages);
           lv_char_value :=   to_number(lv_sit_withheld);
           lv_char_value :=   to_number(lv_workers_compensation2_er);
           lv_char_value :=   to_number(lv_workers_comp2_withheld);
           lv_char_value :=   to_number(lv_workers_comp_withheld);

           if ( lv_sui_qtr_wages   < 0 or
               lv_sui_er_taxable  < 0 or
               lv_sui_excess      < 0 or
               lv_sit_qtr_wages   < 0 or
               lv_sit_withheld    < 0 or
               lv_workers_compensation2_er < 0 or
               lv_workers_comp2_withheld < 0 or
               lv_workers_comp_withheld < 0
	       ) then

                hr_utility.trace('Entered negative reporting loop');

                lv_neg_asg_count :=lv_neg_asg_count + 1 ;

                if lv_neg_asg_count = 1 then

                   fnd_file.put_line(fnd_file.output,formated_Static_header_NM('CSV'));

                end if;

		  fnd_file.put_line(fnd_file.output,formated_static_data_NM (
		    lv_tax_unit_name,
		    lv_organization_name,
		    p_qtrname,
		    lv_state_abbrev,
		    lv_assignment_number,
		    lv_full_name,
		    lv_sui_qtr_wages,
		    lv_sui_er_taxable,
		    lv_sui_excess,
		    lv_sui_er_subjwh,
		    lv_sui_er_pre_tax_redns,
		    lv_sit_qtr_wages,
		    lv_sit_withheld,
		    lv_sit_gross,
		    lv_sit_subjwh,
		    lv_sit_subjnwh,
		    lv_sit_pre_tax_redns,
		    lv_sdi_qtr_wages,
                    lv_sdi_taxable,
                    lv_sdi_excess,
                    lv_sdi_subjwh,
                    lv_sdi_pre_tax_redns,
		    lv_hours_worked,
		    lv_weeks_worked,
                    lv_workers_compensation2_er,
                    lv_workers_comp2_withheld,
                    lv_workers_comp_withheld,
		    'CSV'));

		END IF;

	 EXCEPTION

           when value_error then

                lv_neg_asg_count :=lv_neg_asg_count + 1 ;

                if lv_neg_asg_count = 1 then
                   fnd_file.put_line(fnd_file.output,formated_Static_header_NM('CSV'));
                end if;

		  fnd_file.put_line(fnd_file.output,formated_static_data_NM (
		    lv_tax_unit_name,
		    lv_organization_name,
		    p_qtrname,
		    lv_state_abbrev,
		    lv_assignment_number,
		    lv_full_name,
		    lv_sui_qtr_wages,
		    lv_sui_er_taxable,
		    lv_sui_excess,
		    lv_sui_er_subjwh,
		    lv_sui_er_pre_tax_redns,
		    lv_sit_qtr_wages,
		    lv_sit_withheld,
		    lv_sit_gross,
		    lv_sit_subjwh,
		    lv_sit_subjnwh,
		    lv_sit_pre_tax_redns,
		    lv_sdi_qtr_wages,
                    lv_sdi_taxable,
                    lv_sdi_excess,
                    lv_sdi_subjwh,
                    lv_sdi_pre_tax_redns,
		    lv_hours_worked,
		    lv_weeks_worked,
                    lv_workers_compensation2_er,
                    lv_workers_comp2_withheld,
                    lv_workers_comp_withheld,
		    'CSV'));

	 END;

         end if; /* NM */

         if lv_state_abbrev =  'FL' then

         BEGIN
            lv_char_value := to_number(lv_sui_qtr_wages);
            lv_char_value := to_number(lv_sui_er_taxable);
            lv_char_value := to_number(lv_sui_excess);
            lv_char_value := to_number(lv_sit_qtr_wages);
            lv_char_value := to_number(lv_sit_withheld);
            lv_char_value := to_number(lv_hours_worked);


            if (lv_sui_qtr_wages   < 0 or
                lv_sui_er_taxable  < 0 or
                lv_sui_excess      < 0 or
                lv_sit_qtr_wages   < 0 or
                lv_sit_withheld    < 0  ) then

            hr_utility.trace('Entered negative reporting loop');

            lv_neg_asg_count :=lv_neg_asg_count + 1 ;

            if lv_neg_asg_count = 1 then

               fnd_file.put_line(fnd_file.output,formated_Static_header('CSV'));

            end if;

            fnd_file.put_line(fnd_file.output,formated_static_data (
            lv_tax_unit_name,
            lv_organization_name,
            p_qtrname,
            lv_state_abbrev,
            lv_assignment_number,
            lv_full_name,
            lv_sui_qtr_wages,
            lv_sui_er_taxable,
            lv_sui_excess,
            lv_sui_er_subjwh,
            lv_sui_er_pre_tax_redns,
            lv_sit_qtr_wages,
            lv_sit_withheld,
            lv_sit_gross,
            lv_sit_subjwh,
            lv_sit_subjnwh,
            lv_sit_pre_tax_redns,
            lv_hours_worked,
            lv_weeks_worked,
            'CSV'));

            end if; /* if negative then */

         EXCEPTION

            when value_error then

            lv_neg_asg_count :=lv_neg_asg_count + 1 ;

            if lv_neg_asg_count = 1 then

               fnd_file.put_line(fnd_file.output,formated_Static_header('CSV'));

            end if;


            fnd_file.put_line(fnd_file.output,formated_static_data (
            lv_tax_unit_name,
            lv_organization_name,
            p_qtrname,
            lv_state_abbrev,
            lv_assignment_number,
            lv_full_name,
            lv_sui_qtr_wages,
            lv_sui_er_taxable,
            lv_sui_excess,
            lv_sui_er_subjwh,
            lv_sui_er_pre_tax_redns,
            lv_sit_qtr_wages,
            lv_sit_withheld,
            lv_sit_gross,
            lv_sit_subjwh,
            lv_sit_subjnwh,
            lv_sit_pre_tax_redns,
            lv_hours_worked,
            lv_weeks_worked,
            'CSV'));

         END;

         end if; /* FL */


         if lv_state_abbrev = 'NJ' then

         BEGIN

            lv_char_value := to_number(lv_sui_qtr_wages);
            lv_char_value := to_number(lv_sui_excess);
            lv_char_value := to_number(lv_sui_er_taxable);
            lv_char_value := to_number(lv_sit_qtr_wages);
            lv_char_value := to_number(lv_sit_withheld);
            lv_char_value := to_number(lv_hours_worked);

            if (lv_sui_qtr_wages   < 0 or
                lv_sui_excess      < 0 or
                lv_sui_er_taxable  < 0 or
                lv_sit_qtr_wages   < 0 or
                lv_sit_withheld    < 0  or
                lv_weeks_worked < 0) then

            hr_utility.trace('Entered negative reporting loop');

            lv_neg_asg_count :=lv_neg_asg_count + 1 ;

            if lv_neg_asg_count = 1 then

            fnd_file.put_line(fnd_file.output,formated_Static_header('CSV'));

            end if;



            fnd_file.put_line(fnd_file.output,formated_static_data (
            lv_tax_unit_name,
            lv_organization_name,
            p_qtrname,
            lv_state_abbrev,
            lv_assignment_number,
            lv_full_name,
            lv_sui_qtr_wages,
            lv_sui_er_taxable,
            lv_sui_excess,
            lv_sui_er_subjwh,
            lv_sui_er_pre_tax_redns,
            lv_sit_qtr_wages,
            lv_sit_withheld,
            lv_sit_gross,
            lv_sit_subjwh,
            lv_sit_subjnwh,
            lv_sit_pre_tax_redns,
            lv_hours_worked,
            lv_weeks_worked,
            'CSV'));

            end if; /* if negative then */

         EXCEPTION

            when value_error then

            lv_neg_asg_count :=lv_neg_asg_count + 1 ;

            if lv_neg_asg_count = 1 then

            fnd_file.put_line(fnd_file.output,formated_Static_header('CSV'));

            end if;



            fnd_file.put_line(fnd_file.output,formated_static_data (
            lv_tax_unit_name,
            lv_organization_name,
            p_qtrname,
            lv_state_abbrev,
            lv_assignment_number,
            lv_full_name,
            lv_sui_qtr_wages,
            lv_sui_er_taxable,
            lv_sui_excess,
            lv_sui_er_subjwh,
            lv_sui_er_pre_tax_redns,
            lv_sit_qtr_wages,
            lv_sit_withheld,
            lv_sit_gross,
            lv_sit_subjwh,
            lv_sit_subjnwh,
            lv_sit_pre_tax_redns,
            lv_hours_worked,
            lv_weeks_worked,
            'CSV'));

         END;
         end if; /* NJ */

         if (lv_state_abbrev = 'SD' and lv_report_category ='PD') then

         BEGIN

            lv_char_value := to_number(lv_sui_qtr_wages);
            lv_char_value := to_number(lv_sui_excess);
            lv_char_value := to_number(lv_sui_er_taxable);
            lv_char_value := to_number(lv_sit_qtr_wages);
            lv_char_value := to_number(lv_sit_gross);

            if (lv_sui_qtr_wages   < 0 or
                lv_sui_excess      < 0 or
                lv_sui_er_taxable  < 0 or
                lv_sit_qtr_wages   < 0 or
                lv_sit_gross       < 0 ) then

            hr_utility.trace('Entered negative reporting loop');

            lv_neg_asg_count :=lv_neg_asg_count + 1 ;

            if lv_neg_asg_count = 1 then

                fnd_file.put_line(fnd_file.output,formated_Static_header('CSV'));

            end if;


            fnd_file.put_line(fnd_file.output,formated_static_data (
            lv_tax_unit_name,
            lv_organization_name,
            p_qtrname,
            lv_state_abbrev,
            lv_assignment_number,
            lv_full_name,
            lv_sui_qtr_wages,
            lv_sui_er_taxable,
            lv_sui_excess,
            lv_sui_er_subjwh,
            lv_sui_er_pre_tax_redns,
            lv_sit_qtr_wages,
            lv_sit_withheld,
            lv_sit_gross,
            lv_sit_subjwh,
            lv_sit_subjnwh,
            lv_sit_pre_tax_redns,
            lv_hours_worked,
            lv_weeks_worked,
            'CSV'));


            end if; /* if negative then */

         EXCEPTION

             when value_error then

            lv_neg_asg_count :=lv_neg_asg_count + 1 ;

            if lv_neg_asg_count = 1 then

                fnd_file.put_line(fnd_file.output,formated_Static_header('CSV'));

            end if;


            fnd_file.put_line(fnd_file.output,formated_static_data (
            lv_tax_unit_name,
            lv_organization_name,
            p_qtrname,
            lv_state_abbrev,
            lv_assignment_number,
            lv_full_name,
            lv_sui_qtr_wages,
            lv_sui_er_taxable,
            lv_sui_excess,
            lv_sui_er_subjwh,
            lv_sui_er_pre_tax_redns,
            lv_sit_qtr_wages,
            lv_sit_withheld,
            lv_sit_gross,
            lv_sit_subjwh,
            lv_sit_subjnwh,
            lv_sit_pre_tax_redns,
            lv_hours_worked,
            lv_weeks_worked,
            'CSV'));

         END;
         end if; /* South Dakota Doskette */


         if (lv_state_abbrev = 'WA') then

         BEGIN

            lv_char_value := to_number(lv_sui_qtr_wages);
            lv_char_value := to_number(lv_sui_excess);
            lv_char_value := to_number(lv_sui_er_taxable);
            lv_char_value := to_number(lv_sit_qtr_wages);
            lv_char_value := to_number(lv_sit_withheld);
            lv_char_value := to_number(lv_hours_worked);


               if (lv_sui_qtr_wages < 0 or
                lv_sui_excess       < 0 or
                lv_sui_er_taxable   < 0 or
                lv_sit_qtr_wages    < 0 or
                lv_sit_withheld     < 0 or
                lv_hours_worked     < 0 ) then

            hr_utility.trace('Entered negative reporting loop');

            lv_neg_asg_count :=lv_neg_asg_count + 1 ;

            if lv_neg_asg_count = 1 then

               fnd_file.put_line(fnd_file.output,formated_Static_header('CSV'));

            hr_utility.trace('Inserted header in pay_us_rpt_totals');

            end if;


            fnd_file.put_line(fnd_file.output,formated_static_data (
            lv_tax_unit_name,
            lv_organization_name,
            p_qtrname,
            lv_state_abbrev,
            lv_assignment_number,
            lv_full_name,
            lv_sui_qtr_wages,
            lv_sui_er_taxable,
            lv_sui_excess,
            lv_sui_er_subjwh,
            lv_sui_er_pre_tax_redns,
            lv_sit_qtr_wages,
            lv_sit_withheld,
            lv_sit_gross,
            lv_sit_subjwh,
            lv_sit_subjnwh,
            lv_sit_pre_tax_redns,
            lv_hours_worked,
            lv_weeks_worked,
            'CSV'));


            end if; /* if negative then */

         EXCEPTION

          when value_error then

            lv_neg_asg_count :=lv_neg_asg_count + 1 ;

            if lv_neg_asg_count = 1 then

               fnd_file.put_line(fnd_file.output,formated_Static_header('CSV'));

            hr_utility.trace('Inserted header in pay_us_rpt_totals');

            end if;


            fnd_file.put_line(fnd_file.output,formated_static_data (
            lv_tax_unit_name,
            lv_organization_name,
            p_qtrname,
            lv_state_abbrev,
            lv_assignment_number,
            lv_full_name,
            lv_sui_qtr_wages,
            lv_sui_er_taxable,
            lv_sui_excess,
            lv_sui_er_subjwh,
            lv_sui_er_pre_tax_redns,
            lv_sit_qtr_wages,
            lv_sit_withheld,
            lv_sit_gross,
            lv_sit_subjwh,
            lv_sit_subjnwh,
            lv_sit_pre_tax_redns,
            lv_hours_worked,
            lv_weeks_worked,
            'CSV'));

        END;

         end if; /* WA */

         if (lv_state_abbrev = 'CA') then

         BEGIN

            lv_char_value := to_number(lv_sui_qtr_wages);
            lv_char_value := to_number(lv_sui_excess);
            lv_char_value := to_number(lv_sui_er_taxable);
            lv_char_value := to_number(lv_sit_qtr_wages);
            lv_char_value := to_number(lv_sit_gross);
            lv_char_value := to_number(lv_sit_withheld);
            lv_char_value := to_number(lv_hours_worked);
            lv_char_value := to_number(lv_sdi_qtr_wages);
            lv_char_value := to_number(lv_sdi_taxable);
            lv_char_value := to_number(lv_sdi_excess);

            if (lv_sui_qtr_wages   < 0 or
                lv_sui_excess      < 0 or
                lv_sui_er_taxable  < 0 or
                lv_sit_qtr_wages   < 0 or
                lv_sit_gross       < 0 or
                lv_sit_withheld    < 0 or
                lv_hours_worked    < 0 or
                lv_sdi_qtr_wages   < 0 or
                lv_sdi_taxable     < 0 or
                lv_sdi_excess      < 0 ) then

            hr_utility.trace('Entered negative reporting loop');

            lv_neg_asg_count :=lv_neg_asg_count + 1 ;

            if lv_neg_asg_count = 1 then

              fnd_file.put_line(fnd_file.output,formated_Static_header_CA('CSV'));

            end if;


            fnd_file.put_line(fnd_file.output,formated_static_data_CA (
            lv_tax_unit_name,
            lv_organization_name,
            p_qtrname,
            lv_state_abbrev,
            lv_assignment_number,
            lv_full_name,
            lv_sui_qtr_wages,
            lv_sui_er_taxable,
            lv_sui_excess,
            lv_sui_er_subjwh,
            lv_sui_er_pre_tax_redns,
            lv_sit_qtr_wages,
            lv_sit_withheld,
            lv_sit_gross,
            lv_sit_subjwh,
            lv_sit_subjnwh,
            lv_sit_pre_tax_redns,
            lv_sdi_qtr_wages,
            lv_sdi_taxable,
            lv_sdi_excess,
            lv_sdi_subjwh,
            lv_sdi_pre_tax_redns,
            lv_hours_worked ,
            'CSV'));


            end if; /* if negative then */

         EXCEPTION

          when value_error then

            lv_neg_asg_count :=lv_neg_asg_count + 1 ;

            if lv_neg_asg_count = 1 then

              fnd_file.put_line(fnd_file.output,formated_Static_header_CA('CSV'));

            end if;


            fnd_file.put_line(fnd_file.output,formated_static_data_CA (
            lv_tax_unit_name,
            lv_organization_name,
            p_qtrname,
            lv_state_abbrev,
            lv_assignment_number,
            lv_full_name,
            lv_sui_qtr_wages,
            lv_sui_er_taxable,
            lv_sui_excess,
            lv_sui_er_subjwh,
            lv_sui_er_pre_tax_redns,
            lv_sit_qtr_wages,
            lv_sit_withheld,
            lv_sit_gross,
            lv_sit_subjwh,
            lv_sit_subjnwh,
            lv_sit_pre_tax_redns,
            lv_sdi_qtr_wages,
            lv_sdi_taxable,
            lv_sdi_excess,
            lv_sdi_subjwh,
            lv_sdi_pre_tax_redns,
            lv_hours_worked,
            'CSV'));
         END;

         end if; /* CA */

         if (lv_state_abbrev = 'NY') then

         BEGIN

            lv_annual_gross_wages := lv_regular_earnings_pgy +
                                     lv_supp_fit_stt_pgy +
                                     lv_supp_nwfit_stt_pgy +
                                     lv_fit_non_w2_pre_tax_pgy +
                                     lv_pre_tax_dedns_fit_stt_pgy -
                                     lv_pre_tax_dedns_pgy;


            lv_char_value := to_number(lv_sui_qtr_wages);
            lv_char_value := to_number(lv_sui_excess);
            lv_char_value := to_number(lv_sui_er_taxable);
            lv_char_value := to_number(lv_sit_qtr_wages);
            lv_char_value := to_number(lv_sit_withheld);
            lv_char_value := to_number(lv_sit_withheld_pjgy);
            lv_char_value := to_number(lv_annual_gross_wages);


            hr_utility.trace('lv_annual_gross_wages as cal = '||lv_annual_gross_wages);

            if (lv_sui_qtr_wages   < 0 or
                lv_sui_excess      < 0 or
                lv_sui_er_taxable  < 0 or
                lv_sit_qtr_wages   < 0 or
                lv_sit_withheld    < 0 or
                lv_sit_withheld_pjgy    < 0 or
                lv_annual_gross_wages   < 0 ) then

            hr_utility.trace('Entered negative reporting loop');


            lv_neg_asg_count :=lv_neg_asg_count + 1 ;

            if lv_neg_asg_count = 1 then


              fnd_file.put_line(fnd_file.output,formated_Static_header_NY('CSV'));


            end if;


            fnd_file.put_line(fnd_file.output,formated_static_data_NY (
            lv_tax_unit_name,
            lv_organization_name,
            p_qtrname,
            lv_state_abbrev,
            lv_assignment_number,
            lv_full_name,
            lv_sui_qtr_wages,
            lv_sui_er_taxable,
            lv_sui_excess,
            lv_sui_er_subjwh,
            lv_sui_er_pre_tax_redns,
            lv_sit_qtr_wages,
            lv_sit_withheld,
            lv_sit_gross,
            lv_sit_subjwh,
            lv_sit_subjnwh,
            lv_sit_pre_tax_redns,
            lv_annual_gross_wages,
            lv_regular_earnings_pgy,
            lv_supp_fit_stt_pgy,
            lv_supp_nwfit_stt_pgy,
            lv_fit_non_w2_pre_tax_pgy,
            lv_pre_tax_dedns_fit_stt_pgy,
            lv_pre_tax_dedns_pgy,
            'CSV'));



            end if; /* if negative then */
         EXCEPTION

           when value_error then

            lv_neg_asg_count :=lv_neg_asg_count + 1 ;

            if lv_neg_asg_count = 1 then


              fnd_file.put_line(fnd_file.output,formated_Static_header_NY('CSV'));


            end if;


            fnd_file.put_line(fnd_file.output,formated_static_data_NY (
            lv_tax_unit_name,
            lv_organization_name,
            p_qtrname,
            lv_state_abbrev,
            lv_assignment_number,
            lv_full_name,
            lv_sui_qtr_wages,
            lv_sui_er_taxable,
            lv_sui_excess,
            lv_sui_er_subjwh,
            lv_sui_er_pre_tax_redns,
            lv_sit_qtr_wages,
            lv_sit_withheld,
            lv_sit_gross,
            lv_sit_subjwh,
            lv_sit_subjnwh,
            lv_sit_pre_tax_redns,
            lv_annual_gross_wages,
            lv_regular_earnings_pgy,
            lv_supp_fit_stt_pgy,
            lv_supp_nwfit_stt_pgy,
            lv_fit_non_w2_pre_tax_pgy,
            lv_pre_tax_dedns_fit_stt_pgy,
            lv_pre_tax_dedns_pgy,
            'CSV'));

         END;

         end if; /* NY */
         end loop;

         close c_assignments;

end;
end pay_us_sqwl_error;

/
