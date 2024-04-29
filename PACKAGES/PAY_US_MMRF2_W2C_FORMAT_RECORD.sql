--------------------------------------------------------
--  DDL for Package PAY_US_MMRF2_W2C_FORMAT_RECORD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_US_MMRF2_W2C_FORMAT_RECORD" AUTHID CURRENT_USER AS
/* $Header: payusw2cmagfreco.pkh 120.1.12000000.1 2007/01/17 14:59:16 appldev noship $  */

 /*===========================================================================+
 |               Copyright (c) 2001 Oracle Corporation                        |
 |                  Redwood Shores, California, USA                           |
 |                       All rights reserved.                                 |
 +============================================================================+

  Name
    pay_us_mmrf2_w2c_format_record

  File Name:
    payusw2cmagfreco.pkh

  Purpose
    The purpose of this package is to format reacord to support the
    generation of W-2c magnetic tape for US legilsative requirements.

  Notes
    Refers By:  Package  pay_us_reporting_utils_pkg

  History

  14-OCT-03  ppanda      115.0                Created

*/

--
--
-- This function is used for formatting RCA Record in MMREF-2 Format
--
FUNCTION format_W2C_RCA_record(
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
-- This function is used for formatting RCE Record
--
FUNCTION format_W2C_RCE_record(
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
-- This function is used for formatting RCF Record in MMREF-2 format
--
FUNCTION format_W2C_RCF_record( p_effective_date       IN  varchar2,
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
                                ret_str_len            OUT nocopy number,
                                p_error                OUT nocopy boolean
                               ) RETURN VARCHAR2;
--
-- This function is used for formatting RCT Record in MMREF-2 format
--

FUNCTION format_W2C_RCT_record(
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
                   ret_str_len            OUT nocopy number,
                   p_error                OUT nocopy boolean
                 ) RETURN VARCHAR2;
--
-- This function is used for formatting RCU Record in MMREF-2 format
--

FUNCTION format_W2C_RCU_record(
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
                   ret_str_len            OUT nocopy number,
                   p_error                OUT nocopy boolean
                 ) RETURN VARCHAR2;
--
-- This function is used for formatting RCW Record in MMREF-2 format
--

FUNCTION format_W2C_RCW_record (  p_effective_date               IN varchar2,
                                  p_report_type                  IN varchar2,
                                  p_format                       IN varchar2,
                                  p_report_qualifier             IN varchar2,
                                  p_record_name                  IN varchar2,
                                  p_tax_unit_id                  IN varchar2,
                                  p_record_identifier            IN varchar2,
                                  p_ssn_old                      IN varchar2,
                                  p_ssn_new                      IN varchar2,
                                  p_first_name_old               IN varchar2,
                                  p_middle_name_old              IN varchar2,
                                  p_last_name_old                IN varchar2,
                                  p_first_name_old_raw           IN varchar2,
                                  p_middle_name_old_raw          IN varchar2,
                                  p_last_name_old_raw            IN varchar2,
                                  p_first_name_new               IN varchar2,
                                  p_middle_name_new              IN varchar2,
                                  p_last_name_new                IN varchar2,
                                  p_location_address             IN varchar2,
                                  p_delivery_address             IN varchar2,
                                  p_city                         IN varchar2,
                                  p_state                        IN varchar2,
                                  p_zip                          IN varchar2,
                                  p_zip_extension                IN varchar2,
                                  p_foreign_state                IN varchar2,
                                  p_foreign_postal_code          IN varchar2,
                                  p_country_code                 IN varchar2,
                                  p_statutory_emp_indicator_old  IN varchar2,
                                  p_statutory_emp_indicator_new  IN varchar2,
                                  p_retire_plan_indicator_old    IN varchar2,
                                  p_retire_plan_indicator_new    IN varchar2,
                                  p_sickpay_indicator_old        IN varchar2,
                                  p_sickpay_indicator_new        IN varchar2,
                                  p_orig_assignment_actid        IN varchar2,
                                  p_correct_assignment_actid     IN varchar2,
                                  p_employee_number              IN varchar2,
                                  rcw_wage_rec                   IN OUT nocopy pay_us_w2c_in_mmref2_format.table_wage_record,
                                  p_format_type                  IN varchar2,
                                  p_validate                     IN varchar2,
                                  p_exclude_from_output          OUT nocopy varchar2,
                                  ret_str_len                    OUT nocopy varchar2,
                                  p_error                        OUT nocopy boolean
                               ) return varchar2;

-- This function is used for formatting RCO Record in MMREF-2 format
--
FUNCTION format_W2C_RCO_record (  p_effective_date               IN varchar2,
                                  p_report_type                  IN varchar2,
                                  p_format                       IN varchar2,
                                  p_report_qualifier             IN varchar2,
                                  p_record_name                  IN varchar2,
                                  p_tax_unit_id                  IN varchar2,
                                  p_record_identifier            IN varchar2,
                                  p_ssn_new                      IN varchar2,
                                  p_first_name_new               IN varchar2,
                                  p_middle_name_new              IN varchar2,
                                  p_last_name_new                IN varchar2,
                                  p_orig_assignment_actid        IN varchar2,
                                  p_correct_assignment_actid     IN varchar2,
                                  p_employee_number              IN varchar2,
                                  rco_wage_rec                   IN OUT nocopy pay_us_w2c_in_mmref2_format.table_wage_record,
                                  p_format_type                  IN varchar2,
                                  p_validate                     IN varchar2,
                                  p_exclude_from_output          OUT nocopy varchar2,
                                  ret_str_len                    OUT nocopy varchar2,
                                  p_error                        OUT nocopy boolean
                               )
                               return varchar2;


END pay_us_mmrf2_w2c_format_record; -- End of Package Specification

 

/
