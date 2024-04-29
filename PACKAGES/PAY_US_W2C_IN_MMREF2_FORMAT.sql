--------------------------------------------------------
--  DDL for Package PAY_US_W2C_IN_MMREF2_FORMAT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_US_W2C_IN_MMREF2_FORMAT" AUTHID CURRENT_USER as
/* $Header: payusw2cinmmref2.pkh 120.2 2007/01/10 12:59:20 sausingh noship $  */
 /*===========================================================================+
 |               Copyright (c) 2001 Oracle Corporation                        |
 |                  Redwood Shores, California, USA                           |
 |                       All rights reserved.                                 |
 +============================================================================+
  Name
    pay_us_w2c_in_mmref2_format

  File
    payusw2cinmmref2.pkh

  Purpose
    The purpose of this package is to support the generation of magnetic tape W-2c
    reports in MMREF-2 format for US legilsative requirements.

  Notes

  History

   Date      User Id       Version    Description
   24-OCT-03 ppanda        115.0      created
   26-OCT-04 meshah        115.1      added action_information21 to TYPE
                                      action_rcw_info_rec for ER Health
                                      Savings account. Bug# 3650105.
   10-Jan-07 sausingh      115.2      added action_information_24, action_information_25
                                      and p_output_51 to p_output_54 for the bug 5358272


 ============================================================================*/
 -- Global Variable

    g_number	NUMBER;


FUNCTION format_w2c_record(
                   p_effective_date       IN  varchar2,
                   p_report_type          IN  varchar2,
                   p_format               IN  varchar2,
                   p_report_qualifier     IN  varchar2,
                   p_record_name          IN  varchar2,
                   p_input_1              IN  varchar2,
                   p_input_2              IN  varchar2,
                   p_input_3              IN  varchar2,
                   p_input_4              IN  varchar2,
                   p_input_5              IN  varchar2,
                   p_input_6              IN  varchar2,
                   p_input_7              IN  varchar2,
                   p_input_8              IN  varchar2,
                   p_input_9              IN  varchar2,
                   p_input_10             IN  varchar2,
                   p_input_11             IN  varchar2,
                   p_input_12             IN  varchar2,
                   p_input_13             IN  varchar2,
                   p_input_14             IN  varchar2,
                   p_input_15             IN  varchar2,
                   p_input_16             IN  varchar2,
                   p_input_17             IN  varchar2,
                   p_input_18             IN  varchar2,
                   p_input_19             IN  varchar2,
                   p_input_20             IN  varchar2,
                   p_input_21             IN  varchar2,
                   p_input_22             IN  varchar2,
                   p_input_23             IN  varchar2,
                   p_input_24             IN  varchar2,
                   p_input_25             IN  varchar2,
                   p_input_26             IN  varchar2,
                   p_input_27             IN  varchar2,
                   p_input_28             IN  varchar2,
                   p_input_29             IN  varchar2,
                   p_input_30             IN  varchar2,
                   p_input_31             IN  varchar2,
                   p_input_32             IN  varchar2,
                   p_input_33             IN  varchar2,
                   p_input_34             IN  varchar2,
                   p_input_35             IN  varchar2,
                   p_input_36             IN  varchar2,
                   p_input_37             IN  varchar2,
                   p_input_38             IN  varchar2,
                   p_input_39             IN  varchar2,
                   p_input_40             IN  varchar2,
                   p_validate             IN  varchar2,
                   p_exclude_from_output  OUT nocopy varchar2,
                   sp_out_1               OUT nocopy varchar2,
                   sp_out_2               OUT nocopy varchar2,
                   sp_out_3               OUT nocopy varchar2,
                   sp_out_4               OUT nocopy varchar2,
                   sp_out_5               OUT nocopy varchar2,
                   ret_str_len            OUT nocopy number
                 )

return varchar2;

/* -------------------------------------------------------------
   Function Name : print_record_header
   Purpose       : Function will return the String for header
                   or title line for the Table or table heading
                   related to record for printing in audit files

   Error checking

   Special Note  :

  -------------------------------------------------------------- */

FUNCTION print_w2c_record_header(
                   p_effective_date       IN  varchar2,
                   p_report_type          IN  varchar2,
                   p_format               IN  varchar2,
                   p_report_qualifier     IN  varchar2,
                   p_record_name          IN  varchar2,
                   p_input_1              IN  varchar2,
                   p_input_2              IN  varchar2,
                   p_input_3              IN  varchar2,
                   p_input_4              IN  varchar2,
                   p_input_5              IN  varchar2,
                   p_validate             IN  varchar2,
                   p_exclude_from_output  OUT nocopy varchar2,
                   sp_out_1               OUT nocopy varchar2,
                   sp_out_2               OUT nocopy varchar2,
                   sp_out_3               OUT nocopy varchar2,
                   sp_out_4               OUT nocopy varchar2,
                   sp_out_5               OUT nocopy varchar2,
                   sp_out_6               OUT nocopy varchar2,
                   sp_out_7               OUT nocopy varchar2,
                   sp_out_8               OUT nocopy varchar2,
                   sp_out_9               OUT nocopy varchar2,
                   sp_out_10              OUT nocopy varchar2
                 )  RETURN VARCHAR2;

 /* ******************************************************************
  ** PL/SQL Record to store the archived values for RCW Record
  ****************************************************************** */
  TYPE action_rcw_info_rec IS RECORD
   ( assignment_Action_id      NUMBER
    ,SSN                       varchar2(200)
    ,first_name                varchar2(200)
    ,middle_name               varchar2(200)
    ,last_name                 varchar2(200)
    ,action_information1       NUMBER(14,2) := 0    -- wages, tips and other compensation
    ,action_information2       NUMBER(14,2) := 0    -- FIT withheld
    ,action_information3       NUMBER(14,2) := 0    -- SS Wages
    ,action_information4       NUMBER(14,2) := 0    -- SS Tax withheld
    ,action_information5       NUMBER(14,2) := 0    -- Medicare Wages/Tips
    ,action_information6       NUMBER(14,2) := 0    -- Medicare Tax withheld
    ,action_information7       NUMBER(14,2) := 0    -- Social Security Tips
    ,action_information8       NUMBER(14,2) := 0    -- Advanced EIC
    ,action_information9       NUMBER(14,2) := 0    -- Dependent Care benefits
    ,action_information10      NUMBER(14,2) := 0    -- deferred compensation contributions to section 401(K)
    ,action_information11      NUMBER(14,2) := 0    -- deferred compensation contributions to section 403(b)
    ,action_information12      NUMBER(14,2) := 0    -- deferred compensation contributions to section 408(K)(6)
    ,action_information13      NUMBER(14,2) := 0    -- deferred compensation contributions to section 457(b)
    ,action_information14      NUMBER(14,2) := 0    -- deferred compensation contributions to section 501(c)(18)(D)
    ,action_information15      NUMBER(14,2) := 0    -- Deferred compensation contributions
    ,action_information16      NUMBER(14,2) := 0    -- Military employees basic quarters, subsistence and combat pay
    ,action_information17      NUMBER(14,2) := 0    -- nonqualified plan section 457 distributions or contributions
    ,action_information18      NUMBER(14,2) := 0    -- nonqualified plan not section 457 distributions or contributions
    ,action_information19      NUMBER(14,2) := 0    -- employer cost of premiums for GTL over $50000
    ,action_information20      NUMBER(14,2) := 0    -- income from the exercise of nonstatutory stock options
    ,action_information21      NUMBER(14,2) := 0    -- ER Health Savings Account
    ,action_information22      NUMBER(14,2) := 0    -- Nontaxable Combat Pay
    ,action_information23      NUMBER(14,2) := 0    -- 409A deferrals
    ,action_information24      NUMBER(14,2) := 0    -- Designed ROTH contributio-- ns to a 401(k) plan /* 5358272 */
    ,action_information25      NUMBER(14,2) := 0    -- Designed ROTH contributio-- ns to a 403(b) plan /* 5358272 */
    ,statutory_emp_indicator   VARCHAR2(200) := ' '
    ,retirement_plan_indicator VARCHAR2(200) := ' '
    ,sick_pay_indicator        VARCHAR2(200) := ' '
    );
/*******************************************************************
  ** PL/SQL table of record to store the archived values of RCW Record
  *******************************************************************/
  TYPE action_rcw_info_tab IS TABLE OF  action_rcw_info_rec
  INDEX BY BINARY_INTEGER;

  ltr_rcw_info action_rcw_info_tab;


 /*******************************************************************
  ** PL/SQL Record to store the archived values for RCO Record
  *******************************************************************/
  TYPE action_rco_info_rec IS RECORD
   ( action_information1       NUMBER(14,2) := 0    -- allocated tips
    ,action_information2       NUMBER(14,2) := 0    -- uncollected employee tax on tips
    ,action_information3       NUMBER(14,2) := 0    -- Medical Savings Account
    ,action_information4       NUMBER(14,2) := 0    -- Simple Retirement Account
    ,action_information5       NUMBER(14,2) := 0    -- Qualified adoption expenses
    ,action_information6       NUMBER(14,2) := 0    -- uncollected social security or RRTA tax on GTL insurance over $50000
    ,action_information7       NUMBER(14,2) := 0    -- uncollected medicare tax on GTL insurance over $50,000
    ,action_information8       NUMBER(14,2) := 0    -- 409A income
    );

  /*******************************************************************
  ** PL/SQL table of record to store the archived values of RCO Record
  *******************************************************************/
  TYPE action_rco_info_tab IS TABLE OF  action_rco_info_rec
  INDEX BY BINARY_INTEGER;

  ltr_rco_info action_rco_info_tab;

 /*******************************************************************
  ** PL/SQL Record to store the archived values for RCT Record
  *******************************************************************/
  TYPE rct_info_rec IS RECORD
   ( rct_wage_old          NUMBER(14,2) := 0    -- Old RCW Wage Total
    ,rct_wage_old_formated varchar2(15) := ' '  -- Old RCW Wage Total reported on RCT
    ,rct_wage_new          NUMBER(14,2) := 0    -- New RCW Wage Total reported on RCT
    ,rct_wage_new_formated varchar2(15) := ' '
    ,rct_identical_flag    varchar2(10) := 'Y'
   );

  /*******************************************************************
  ** PL/SQL table of record to store the archived values of RCT Record
  *******************************************************************/
  TYPE rct_info_tab IS TABLE OF  rct_info_rec
  INDEX BY BINARY_INTEGER;

  ltr_rct_info rct_info_tab;

 /*******************************************************************
  ** PL/SQL Record to store the archived values for RCU Record
  *******************************************************************/
  TYPE rcu_info_rec IS RECORD
   ( rcu_wage_old           NUMBER(14,2) := 0    -- Old RCO Wage Total
    ,rcu_wage_old_formated  varchar2(15) := ' '  -- OLD RCO Wage Total reported on RCU
    ,rcu_wage_new           NUMBER(14,2) := 0    -- New RCO Wage Total
    ,rcu_wage_new_formated  varchar2(15) := ' '  -- New RCO Wage Total reported on RCU
    ,rcu_identical_flag     varchar2(10) := 'Y'
   );

  /*******************************************************************
  ** PL/SQL table of record to store the archived values of RCO Record
  *******************************************************************/
  TYPE rcu_info_tab IS TABLE OF  rcu_info_rec
  INDEX BY BINARY_INTEGER;

  ltr_rcu_info rcu_info_tab;

 /*******************************************************************
  ** PL/SQL Record to store the column of Formatted RCW record
  *******************************************************************/

  TYPE format_rcw_rec IS RECORD
   (
     ssn                   varchar2(100),
     first_name            varchar2(100),
     middle_name           varchar2(100),
     last_name             varchar2(100),
     location_address      varchar2(100),
     delivery_address      varchar2(100),
     city                  varchar2(100),
     state                 varchar2(100),
     zip                   varchar2(100),
     zip_extension         varchar2(100),
     foreign_state         varchar2(100),
     foreign_postal        varchar2(100),
     country_code          varchar2(100),
     wage_1                varchar2(100),
     wage_2                varchar2(100),
     wage_3                varchar2(100),
     wage_4                varchar2(100),
     wage_5                varchar2(100),
     wage_6                varchar2(100),
     wage_7                varchar2(100),
     wage_8                varchar2(100),
     wage_9                varchar2(100),
     wage_10               varchar2(100),
     wage_11               varchar2(100),
     wage_12               varchar2(100),
     wage_13               varchar2(100),
     wage_14               varchar2(100),
     wage_15               varchar2(100),
     wage_16               varchar2(100),
     wage_17               varchar2(100),
     wage_18               varchar2(100),
     wage_19               varchar2(100),
     wage_20               varchar2(100),
     stat_emp_indicator    varchar2(100),
     retire_plan_indicator varchar2(100),
     sick_pay_indicator    varchar2(100)
   );

  /*******************************************************************
  ** PL/SQL table of record to store the archived values of RCT Record
  *******************************************************************/

  TYPE rcw_format_rec IS TABLE OF  format_rcw_rec
  INDEX BY BINARY_INTEGER;

  rcw_record rcw_format_rec;

  rcw_exclude_flag            varchar2(10) := 'N';
  rco_exclude_flag            varchar2(10) := 'N';
  rcw_number_of_correction    number       := 0;
  rco_number_of_correction    number       := 0;


  number_of_valid_rcw_rct     number       := 0;      -- Number of Valid RCW Record to be reported in RCT
  number_of_valid_rco_rcu     number       := 0;      -- Number of Valid RCO Record to be reported in RCU

  number_of_error_rcw_rct     number       := 0;      -- Number of Error RCW Record to be reported in RCT
  number_of_error_rco_rcu     number       := 0;      -- Number of Error RCO Record to be reported in RCU

  number_of_error_rcw_rcf     number       := 0;      -- Number of Error RCW Record to be reported in RCF
  number_of_error_rco_rcf     number       := 0;      -- Number of Error RCO Record to be reported in RCF

  number_of_valid_rcw_rcf     number       := 0;      -- Number of Valid RCW Record to be reported in RCF
  number_of_valid_rco_rcf     number       := 0;      -- Number of Valid RCO Record to be reported in RCF

  rcw_mf_record                varchar2(32767) := '';
  rcw_csv_record               varchar2(32767) := '';
  rcw_blank_csv_record         varchar2(32767) := '';
  rco_mf_record                varchar2(32767) := '';
  rco_csv_record               varchar2(32767) := '';
  rco_blank_csv_record         varchar2(32767) := '';

  TYPE wage_rec IS RECORD(identical_flag           varchar2(3)   := 'Y',
                          wage_old_value           number        := 0,
                          wage_old_value_formated  varchar2(100) := '0',
                          wage_new_value           number        := 0,
                          wage_new_value_formated  varchar2(100) := '0'
                         );
wage_record  wage_rec;
TYPE table_wage_record IS TABLE OF wage_record%TYPE
                            INDEX BY BINARY_INTEGER;

PROCEDURE  GET_ARCHIVED_VALUES ( p_action_type            varchar2 -- O Originally Reported,  C Corrected
                                ,p_record_type            varchar2 -- RCW, RCO
                                ,p_assignment_action_id   number
                                ,p_tax_unit_id            number);

FUNCTION  pay_us_w2c_RCW_record ( p_effective_date            IN varchar2,
                                  p_report_type               IN varchar2,
                                  p_format                    IN varchar2,
                                  p_report_qualifier          IN varchar2,
                                  p_record_name               IN varchar2,
                                  p_tax_unit_id               IN varchar2,
                                  p_record_identifier         IN varchar2,
                                  p_ssn                       IN varchar2,
                                  p_first_name                IN varchar2,
                                  p_middle_name               IN varchar2,
                                  p_last_name                 IN varchar2,
                                  p_sufix                     IN varchar2,
                                  p_location_address          IN varchar2,
                                  p_delivery_address          IN varchar2,
                                  p_city                      IN varchar2,
                                  p_state                     IN varchar2,
                                  p_zip                       IN varchar2,
                                  p_zip_extension             IN varchar2,
                                  p_foreign_state             IN varchar2,
                                  p_foreign_postal_code       IN varchar2,
                                  p_country_code              IN varchar2,
                                  p_orig_assignment_actid     IN varchar2,
                                  p_correct_assignment_actid  IN varchar2,
                                  p_employee_number           IN varchar2,
                                  p_format_type               IN varchar2,
                                  p_validate                  IN varchar2,
                                  p_exclude_from_output       OUT nocopy varchar2,
                                  sp_out_1                    OUT nocopy varchar2,
                                  sp_out_2                    OUT nocopy varchar2,
                                  sp_out_3                    OUT nocopy varchar2,
                                  sp_out_4                    OUT nocopy varchar2,
                                  sp_out_5                    OUT nocopy varchar2,
                                  ret_str_len                 OUT nocopy varchar2,
                                  p_error                     OUT nocopy boolean
                                  ) return varchar2;

Function Initialize_GRE_Level_Total return number;

FUNCTION format_w2c_total_record(
                   p_effective_date        IN  varchar2,
                   p_report_type           IN  varchar2,
                   p_format                IN  varchar2,
                   p_report_qualifier      IN  varchar2,
                   p_record_name           IN  varchar2,
                   p_input_1               IN  varchar2,
                   p_input_2               IN  varchar2,
                   p_input_3               IN  varchar2,
                   p_input_4               IN  varchar2,
                   p_input_5               IN  varchar2,
                   p_output_1              OUT nocopy  varchar2,
                   p_output_2              OUT nocopy  varchar2,
                   p_output_3              OUT nocopy  varchar2,
                   p_output_4              OUT nocopy  varchar2,
                   p_output_5              OUT nocopy  varchar2,
                   p_output_6              OUT nocopy  varchar2,
                   p_output_7              OUT nocopy  varchar2,
                   p_output_8              OUT nocopy  varchar2,
                   p_output_9              OUT nocopy  varchar2,
                   p_output_10             OUT nocopy  varchar2,
                   p_output_11             OUT nocopy  varchar2,
                   p_output_12             OUT nocopy  varchar2,
                   p_output_13             OUT nocopy  varchar2,
                   p_output_14             OUT nocopy  varchar2,
                   p_output_15             OUT nocopy  varchar2,
                   p_output_16             OUT nocopy  varchar2,
                   p_output_17             OUT nocopy  varchar2,
                   p_output_18             OUT nocopy  varchar2,
                   p_output_19             OUT nocopy  varchar2,
                   p_output_20             OUT nocopy  varchar2,
                   p_output_21             OUT nocopy  varchar2,
                   p_output_22             OUT nocopy  varchar2,
                   p_output_23             OUT nocopy  varchar2,
                   p_output_24             OUT nocopy  varchar2,
                   p_output_25             OUT nocopy  varchar2,
                   p_output_26             OUT nocopy  varchar2,
                   p_output_27             OUT nocopy  varchar2,
                   p_output_28             OUT nocopy  varchar2,
                   p_output_29             OUT nocopy  varchar2,
                   p_output_30             OUT nocopy  varchar2,
                   p_output_31             OUT nocopy  varchar2,
                   p_output_32             OUT nocopy  varchar2,
                   p_output_33             OUT nocopy  varchar2,
                   p_output_34             OUT nocopy  varchar2,
                   p_output_35             OUT nocopy  varchar2,
                   p_output_36             OUT nocopy  varchar2,
                   p_output_37             OUT nocopy  varchar2,
                   p_output_38             OUT nocopy  varchar2,
                   p_output_39             OUT nocopy  varchar2,
                   p_output_40             OUT nocopy  varchar2,
                   p_output_41             OUT nocopy  varchar2,
                   p_output_42             OUT nocopy  varchar2,
                   p_output_43             OUT nocopy  varchar2,
                   p_output_44             OUT nocopy  varchar2,
                   p_output_45             OUT nocopy  varchar2,
                   p_output_46             OUT nocopy  varchar2,
                   p_output_51             OUT nocopy  varchar2, /* 5358272 */
                   p_output_52             OUT nocopy  varchar2, /* 5358272 */
                   p_output_53             OUT nocopy  varchar2, /* 5358272 */
                   p_output_54             OUT nocopy  varchar2, /* 5358272 */
                   p_validate              IN  varchar2,
                   p_exclude_from_output   OUT nocopy varchar2,
                   sp_out_1                OUT nocopy varchar2,
                   sp_out_2                OUT nocopy varchar2,
                   sp_out_3                OUT nocopy varchar2,
                   sp_out_4                OUT nocopy varchar2,
                   sp_out_5                OUT nocopy varchar2,
                   ret_str_len             OUT nocopy varchar2,
                   p_output_47             OUT nocopy  varchar2,
                   p_output_48             OUT nocopy  varchar2,
                   p_output_49             OUT nocopy  varchar2,
                   p_output_50             OUT nocopy  varchar2


                 ) RETURN VARCHAR2;


END pay_us_w2c_in_mmref2_format;

/
