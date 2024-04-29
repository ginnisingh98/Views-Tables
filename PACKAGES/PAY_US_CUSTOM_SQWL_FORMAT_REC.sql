--------------------------------------------------------
--  DDL for Package PAY_US_CUSTOM_SQWL_FORMAT_REC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_US_CUSTOM_SQWL_FORMAT_REC" AUTHID CURRENT_USER AS
/* $Header: pyuscussqfr.pkh 120.0.12000000.1 2007/01/18 02:14:26 appldev noship $  */

 /*===========================================================================+
 |               Copyright (c) 2001 Oracle Corporation                        |
 |                  Redwood Shores, California, USA                           |
 |                       All rights reserved.                                 |
 +============================================================================+

  Name
    pay_us_custom_sqwl_format_rec

  Purpose
    The purpose of this package is to format reacord to support the
    generation of SQWL magnetic tape for US legilsative requirements.

  Notes
    Referenced By:  Package  pay_us_reporting_utils_pkg

  History

  24-feb-2004 jgoswami      115.0    3334497           Created

*/


--
-- This function formats Custom_Submitter Record for SQWL reporting
-- For Future Use

--
-- This function formats Custom Employer Record for SQWL reporting
--
--
FUNCTION FORMAT_SQWL_CUSTOM_EMPLOYER(
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
--
-- This function formats Custom Employee Record for SQWL reporting
--
*/

FUNCTION format_SQWL_CUSTOM_EMPLOYEE(
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
-- Formating Custom Employer Total record for SQWL reporting
--

--
-- Formatting CUSTOM_FILE_TOTAL_RECORD record for SQWL reporting
-- For Future Use

END pay_us_custom_sqwl_format_rec;

 

/
