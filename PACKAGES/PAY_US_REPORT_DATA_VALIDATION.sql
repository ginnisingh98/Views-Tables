--------------------------------------------------------
--  DDL for Package PAY_US_REPORT_DATA_VALIDATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_US_REPORT_DATA_VALIDATION" AUTHID CURRENT_USER AS
/* $Header: payusdatavalid.pkh 115.2 2003/10/30 15:27 ppanda noship $  */

 /*===========================================================================+
 |               Copyright (c) 2001 Oracle Corporation                        |
 |                  Redwood Shores, California, USA                           |
 |                       All rights reserved.                                 |
 +============================================================================+

  Name
    pay_us_report_data_validation

  Purpose
    The purpose of this package is to validate EIN, SSN etc
    to support the generation of magnetic tape W2 / SQWL reports
    for US legilsative requirements.

   Notes
    Referenced By:  Package  pay_us_reporting_utils_pkg

   Notes

   History
   15-Jul-03  ppanda      115.0                Created

*/

/* Following is to validate EIN to support SQWL Reporting */
FUNCTION validate_SQWL_EIN( p_report_qualifier IN  varchar2,
                            p_record_name      IN  varchar2,
                            p_input_2          IN  varchar2,
                            p_input_4          IN  varchar2,
                            p_validate         IN  varchar2,
                            p_err              OUT nocopy boolean
                          ) return varchar2;

/* Following is to validate EIN to support W2 Reporting */
FUNCTION validate_W2_EIN( p_report_qualifier IN  varchar2,
                          p_record_name      IN  varchar2,
                          p_input_2          IN  varchar2,
                          p_input_4          IN  varchar2,
                          p_validate         IN  varchar2,
                          p_err              OUT nocopy boolean
                        ) return varchar2;

/* Following is to validate EIN to support SQWL Reporting */
FUNCTION validate_SQWL_SSN(p_effective_date       IN  varchar2,
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
                           p_err                  OUT nocopy boolean
                          ) return varchar2;

/* Following is to validate EIN to support W2 Reporting */
FUNCTION validate_W2_SSN(p_effective_date       IN  varchar2,
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
                         p_err                  OUT nocopy  boolean
                        ) return varchar2;

END pay_us_report_data_validation;

 

/
