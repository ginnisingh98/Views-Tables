--------------------------------------------------------
--  DDL for Package PAY_US_MMRF_SQWL_FORMAT_RECORD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_US_MMRF_SQWL_FORMAT_RECORD" AUTHID CURRENT_USER AS
/* $Header: pyussqfr.pkh 120.0.12010000.1 2008/07/27 23:56:30 appldev ship $  */

 /*===========================================================================+
 |               Copyright (c) 2001 Oracle Corporation                        |
 |                  Redwood Shores, California, USA                           |
 |                       All rights reserved.                                 |
 +============================================================================+

  Name
    pay_us_mmrf_sqwl_format_record

  Purpose
    The purpose of this package is to format reacord to support the
    generation of SQWL magnetic tape for US legilsative requirements.

  Notes
    Referenced By:  Package  pay_us_reporting_utils_pkg

  History

  28-AUG-2004 jgoswami    115.3       3830050  Added FUNCTION format_SQWL_RSSUMM_record
  14-Jul-03   ppanda      115.0                Created

*/


-- This function determines the required length for fields
-- in various data record. Derived lengh is then validated for various
-- records. This function is being referenced from DAT_VALIDATION f
-- unction in package pay_us_reporting_utils_pkg
--
FUNCTION set_req_field_length (p_report_type      IN  varchar2,
                               p_format           IN  varchar2,
                               p_report_qualifier IN  varchar2,
                               p_record_name      IN  varchar2,
                               p_input_1          IN  varchar2,
                               p_input_2          IN  varchar2,
                               p_input_3          IN  varchar2,
                               p_input_4          IN  varchar2,
                               p_input_5          IN  varchar2
                              ) return NUMBER;
--
-- Formatting Contact person information used for SQWL reporting
--
PROCEDURE format_sqwl_contact_prsn_info (
                p_report_qualifier         IN  varchar2,
                p_record_name              IN  varchar2,
                p_validate                 IN  varchar2,
                p_exclude_from_output      IN OUT nocopy varchar2,
                p_contact_prsn_name        IN OUT nocopy varchar2,
                p_contact_prsn_phone       IN OUT nocopy varchar2,
                p_contact_prsn_extension   IN OUT nocopy varchar2,
                p_contact_prsn_email       IN OUT nocopy varchar2,
                p_contact_prsn_fax         IN OUT nocopy varchar2,
                p_contact_prsn_first_name  IN OUT nocopy varchar2,
                p_contact_prsn_middle_name IN OUT nocopy varchar2,
                p_contact_prsn_last_name   IN OUT nocopy varchar2);

--
-- This function formats RA Record for SQWL reporting
--
/*----------------------------- Parameter mapping. -----------------------------
  Record Identifier,                                   -->   p_input_1
  Submitter''s Employer Identification Number (EIN),   -->   p_input_2
  Personal Identification Number (PIN)                 -->   p_input_3,
  Resub Indicator                                      -->   p_input_4,
-- This is  fix for bug # 2510920 to rename TLCN to WFID
  Resub WFID                                           -->   p_input_5,
  Software Code                                        -->   p_input_6,
  Company Name                                         -->   p_input_7,
  Location Address                                     -->   p_input_8,
  Delivery Address                                     -->   p_input_9,
  City                                                 -->   p_input_10,
  State Abbreviation                                   -->   p_input_11,
  Zip Code                                             -->   p_input_12,
  Zip Code Extension                                   -->   p_input_13,
  Foreign State / Province                             -->   p_input_14,
  Foreign Postal Code                                  -->   p_input_15,
  Country Code                                         -->   p_input_16,
  Submitter Name                                       -->   p_input_17,
  Location Address                                     -->   p_input_18,
  Delivery Address                                     -->   p_input_19,
  City                                                 -->   p_input_20,
  State Abbreviation                                   -->   p_input_21,
  Zip Code                                             -->   p_input_22,
  Zip Code Extension                                   -->   p_input_23,
  Foreign State / Province                             -->   p_input_24,
  Foreing Postal Code                                  -->   p_input_25,
  Country Code                                         -->   p_input_26,
  Contact Name                                         -->   p_input_27,
  Contact Phone Number                                 -->   p_input_28,
  Contact Phone Extension                              -->   p_input_29,
  Contact E-Mail                                       -->   p_input_30,
  Blank,Contact FAX                                    -->   p_input_31,
  Preferred Method Of Problem Notification Code        -->   p_input_32,
  Preparer Code                                        -->   p_input_33,
*/
FUNCTION format_SQWL_RA_record(
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
                   ret_str_len            OUT nocopy number,
                   p_error                OUT nocopy boolean
                 ) RETURN VARCHAR2;

--
-- This function formats RE Record for SQWL reporting
--
   /* Record Identifier              --> p_input_1,
      Tax Year                       --> p_input_2,
      Agent Indicator Code           --> p_input_3,
      Employer / Agent Employer Identification Number (EIN) -->p_input_4,
      Agent For EIN                  --> p_input_5,
      Terminating Business Indicator --> p_input_6,
      Establishment Number           --> p_input_7,
      Other EIN                      --> p_input_8,
      Employer Name                  --> p_input_9,
      Location Address               --> p_input_10,
      Delivery Address               --> p_input_11,
      City                           --> p_input_12,
      State Abbreviation             --> p_input_13,
      Zip Code                       --> p_input_14,
      Zip Code Extension             --> p_input_15,
      Blank,
      Foreign State / Provinc        --> p_input_16
      Foreign Postal Code            --> p_input_17,
      Country Code                   --> p_input_18,
      Employment Code                --> p_input_19,
      Tax Jurisdiction Code          --> p_input_20,
      Third Party Sick Pay Indicator --> p_input_21
   */
--
FUNCTION format_SQWL_RE_record(
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
                   ret_str_len            OUT nocopy number,
                   p_error                OUT nocopy boolean
                 ) RETURN VARCHAR2;

/*
  Record Identifier                                   --> p_input_1
  State Code                                          --> p_input_2
  Taxing Entity Code                                  --> p_input_3
  Social Security Number (SSN)                        --> p_input_4
  Employee First Name                                 --> p_input_5
  Employee Middle Name or Initial                     --> p_input_6
  Employee Last Name                                  --> p_input_7
  Suffix                                              --> p_input_8
  Location Address                                    --> p_input_0
  Delivery Address                                    --> p_input_10
  City                                                --> p_input_11
  State Abbreviation                                  --> p_input_12
  Zip Code                                            --> p_input_13
  Zip Code Extension                                  --> p_input_14
  Foreign State / Province                            --> p_input_15
  Foreign Postal Code                                 --> p_input_16
  Country Code                                        --> p_input_17
  Optional Code                                       --> p_input_18
  Reporting Period                                    --> p_input_19
  State Quarterly Unemployment Insurance Total Wages  --> p_input_20
  State Quarterly Unemployment Total Taxable Wages    --> p_input_21
  Number of Weeks Worked                              --> p_input_22
  Date First Employed                                 --> p_input_23
  Date of Separation                                  --> p_input_24
  State Employer Account Number                       --> p_input_25
  State Code                                          --> p_input_26
  State Taxable Wages                                 --> p_input_27
  SIT Withheld                                        --> p_input_28
  Other State Data                                    --> p_input_29
  Tax Type Code                                       --> p_input_30
  Local Taxable Wages                                 --> p_input_31
  Local Income Tax Withheld                           --> p_input_32
  State Control Number                                --> p_input_33
  Supplemental Data 1                                 --> p_input_34
  Supplemental Data 2                                 --> p_input_35
*/

FUNCTION format_SQWL_RS_record(
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
                   ret_str_len            OUT nocopy number,
                   p_error                OUT nocopy boolean
                 ) RETURN VARCHAR2;

--
-- Formating RT record for SQWL reporting
--
FUNCTION format_SQWL_RT_record(
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
                   ret_str_len            OUT nocopy number,
                   p_error                OUT nocopy boolean
                 ) RETURN VARCHAR2;
--
-- Formating RSSUMM record for SQWL reporting
--
FUNCTION format_SQWL_RSSUMM_record(
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
                   ret_str_len            OUT nocopy number,
                   p_error                OUT nocopy boolean
                 ) RETURN VARCHAR2;
--
--
-- Formatting RST record for SQWL reporting
--
/*
  Effective Date                               --> p_effective_date
  Report Type  (i.e.W2 )                       --> p_report_type
  Report Format                                --> p_format
  Report Qualifier                             --> p_report_qualifier
  Record Name (i.e. RST)                       --> p_record_name
  Record Identifier                            --> p_record_identifier
  Number of Employee                           --> p_total_no_employee
  SIT Wages                                    --> p_sit_wages
  SIT Taxes                                    --> p_sit_taxes
  1st Month employed no of employee            --> p_month1_no_employee
  2nd Month employed no of employee            --> p_month1_no_employee
  3rd Month employed no of employee            --> p_month1_no_employee
  Report Format Mode (FLAT, CSV)               --> p_format_mode
  Validation Flag                              --> p_validate
  Exclude Record from mag file                 --> p_exclude_from_output
  Return Record Length                         --> ret_str_len
*/

FUNCTION format_SQWL_RST_record(
                   p_effective_date        IN  varchar2,
                   p_report_type           IN  varchar2,
                   p_format                IN  varchar2,
                   p_report_qualifier      IN  varchar2,
                   p_record_name           IN  varchar2,
                   p_record_identifier     IN  varchar2,
                   p_total_no_of_employee  IN  varchar2,
                   p_state_code            IN  varchar2,
                   p_sui_reduction_wages   IN  varchar2,
                   p_sit_wages             IN  varchar2,
                   p_sit_tax               IN  varchar2,
                   p_month1_no_employee    IN  varchar2,
                   p_month2_no_employee    IN  varchar2,
                   p_month3_no_employee    IN  varchar2,
                   p_format_mode           IN  varchar2,
                   p_validate              IN  varchar2,
                   p_exclude_from_output   OUT nocopy varchar2,
                   ret_str_len             OUT nocopy number
                 ) RETURN VARCHAR2;

/* Formatting RU record for SQWL reporting
   --------------------------------- Parameter mapping ---------------------
   Effective Date                                 --> p_effective_date
   Report Type     (i.e. SQWL)                    --> p_report_type
   Report Format                                  --> p_format
   Report Qualifier                               --> p_report_qualifier
   Record Name (i.e. RU)                          --> p_record_name
   Record Identifier                              --> p_record_identifier
   Number of RS Records                           --> p_number_of_RS_record
   Record Format Mode   (FLAT, CSV etc.)          --> p_record_format_mode
   Exclude RU record from .mf file                --> p_exclude_from_output
*/
FUNCTION format_SQWL_RU_record(
                   p_effective_date       IN  varchar2,
                   p_report_type          IN  varchar2,
                   p_format               IN  varchar2,
                   p_report_qualifier     IN  varchar2,
                   p_record_name          IN  varchar2,
                   p_record_identifier    IN  varchar2,
                   p_number_of_RS_record  IN  varchar2,
                   p_record_format_mode   IN  varchar2,
                   p_exclude_from_output  OUT nocopy varchar2,
                   ret_str_len            OUT nocopy number
                 ) RETURN VARCHAR2;

--
-- Formatting RF record for SQWL reporting
--
/*
  Effective Date                               --> p_effective_date
  Report Type     (i.e. SQWL)                  --> p_report_type
  Report Format                                --> p_format
  Report Qualifier                             --> p_report_qualifier
  Record Name (i.e. RF)                        --> p_record_name
  Record Identifier                            --> p_record_identifier
  Number of RW Records                         --> p_total_no_of_record
  Wages, Tips and other Compensation           --> p_total_wages
  Federal Income Tax Withheld                  --> p_tal_taxes
  Report Format Mode (FLAT, CSV)               --> p_format_mode
  Validation Flag                              --> p_validate
  Exclude Record from mag file                 --> p_exclude_from_output
  Return Record Length                         --> ret_str_len
*/
FUNCTION format_SQWL_RF_record(
                               p_effective_date       IN  varchar2,
                               p_report_type          IN  varchar2,
                               p_format               IN  varchar2,
                               p_report_qualifier     IN  varchar2,
                               p_record_name          IN  varchar2,
                               p_record_identifier    IN  varchar2,
                               p_total_no_of_record   IN  varchar2,
                               p_total_wages          IN  varchar2,
                               p_total_taxes          IN  varchar2,
                               p_format_mode          IN  varchar2,
                               p_validate             IN  varchar2,
                               p_exclude_from_output  OUT nocopy varchar2,
                               ret_str_len            OUT nocopy number
                              ) RETURN VARCHAR2;

END pay_us_mmrf_sqwl_format_record;

/
