--------------------------------------------------------
--  DDL for Package PAY_US_MMRF_PRINT_REC_HEADER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_US_MMRF_PRINT_REC_HEADER" AUTHID CURRENT_USER AS
/* $Header: pyusprhd.pkh 120.0.12000000.1 2007/01/18 02:49:46 appldev noship $  */

 /*===========================================================================+
 |               Copyright (c) 2001 Oracle Corporation                        |
 |                  Redwood Shores, California, USA                           |
 |                       All rights reserved.                                 |
 +============================================================================+

  Name
    pay_us_mmrf_print_rec_header_pkg

  Purpose
    The purpose of this package is to format reacord header
    to support the generation of magnetic tape W2 / SQWL reports
    for US legilsative requirements. These record headers are
    mainly used for CSV

   Notes
    Referenced By:  Package  pay_us_reporting_utils_pkg

   Notes

   History
   28-AUG-2004 jgoswami   115.3       3830050  added mmrf_format_rssumm_rec_header
   10-Nov-03  ppanda      115.2       2587381  Two new function added to format
                                               W-2c record headers for audit reporting purpose
   27-Oct-03  fusman      115.1       3220001  Parameter order was changed.
   14-Jul-03  ppanda      115.0                Created

*/
 -- Global Variable
    g_number	NUMBER;
    l_return    varchar2(100);
    end_date    date := to_date('31/12/4712','DD/MM/YYYY');
--
-- This function format submitter Record (i.e. RA) record header
--
FUNCTION mmrf_format_ra_record_header(
                   p_report_type          IN  varchar2,
                   p_format               IN  varchar2,
                   p_report_qualifier     IN  varchar2,
                   p_record_name          IN  varchar2
                 )  RETURN VARCHAR2;
--
-- This function format Employer Record (i.e. RE) record header
--
FUNCTION mmrf_format_re_record_header(
                                      p_report_type          IN  varchar2,
                                      p_format               IN  varchar2,
                                      p_report_qualifier     IN  varchar2,
                                      p_record_name          IN  varchar2
                 )  RETURN VARCHAR2;
--
-- This function formats Wage Record (i.e. RW) record header
--
FUNCTION mmrf_format_rw_record_header(
                                      p_report_type          IN  varchar2,
                                      p_format               IN  varchar2,
                                      p_report_qualifier     IN  varchar2,
                                      p_record_name          IN  varchar2
                                     ) RETURN VARCHAR2;
--
-- This function formats Puertorico based Wage Record (i.e. RO) record header
--
FUNCTION mmrf_format_ro_record_header(
                   p_report_type          IN  varchar2,
                   p_format               IN  varchar2,
                   p_report_qualifier     IN  varchar2,
                   p_record_name          IN  varchar2
                 )  RETURN VARCHAR2;
--
-- This function formats State Wage Record (i.e. RS) record header
--
FUNCTION mmrf_format_w2_rs_rec_header(
                   p_report_type          IN  varchar2,
                   p_format               IN  varchar2,
                   p_report_qualifier     IN  varchar2,
                   p_record_name          IN  varchar2,
                   p_input_1              IN  varchar2
                 )  RETURN VARCHAR2;
--
-- This function formats State Wage Record (i.e. RO) record header
--
FUNCTION mmrf_format_sqwl_rs_rec_header(
                                           p_report_type          IN  varchar2,
                                           p_format               IN  varchar2,
                                           p_report_qualifier     IN  varchar2,
                                           p_record_name          IN  varchar2,
                                           p_input_1              IN  varchar2
                                          )  RETURN VARCHAR2;
--
-- This function formats Total Wage Record (i.e. RSSUMM) record header
--
FUNCTION mmrf_format_rssumm_rec_header(
                                      p_report_type          IN  varchar2,
                                      p_format               IN  varchar2,
                                      p_report_qualifier     IN  varchar2,
                                      p_record_name          IN  varchar2
                                     )  RETURN VARCHAR2;
--
-- This function formats Total Wage Record (i.e. RT) record header
--
FUNCTION mmrf_format_rt_record_header(
                                      p_report_type          IN  varchar2,
                                      p_format               IN  varchar2,
                                      p_report_qualifier     IN  varchar2,
                                      p_record_name          IN  varchar2
                                     )  RETURN VARCHAR2;
--
-- This function formats Total Puertorico Wage Record (i.e. RU) record header
--
FUNCTION mmrf_format_ru_record_header(
                                      p_report_type          IN  varchar2,
                                      p_format               IN  varchar2,
                                      p_report_qualifier     IN  varchar2,
                                      p_record_name          IN  varchar2
                                     )  RETURN VARCHAR2;
--
-- This function formats File Total Record (i.e. RF) record header
--
FUNCTION mmrf_format_rf_record_header(
                                      p_report_type          IN  varchar2,
                                      p_format               IN  varchar2,
                                      p_report_qualifier     IN  varchar2,
                                      p_record_name          IN  varchar2
                                     )  RETURN VARCHAR2;
--
-- This function formats Wage Record (i.e. RCW) record header
--
FUNCTION mmrf2_format_rcw_record_header(
                                      p_report_type          IN  varchar2,
                                      p_format               IN  varchar2,
                                      p_report_qualifier     IN  varchar2,
                                      p_record_name          IN  varchar2
                                     ) RETURN VARCHAR2;
--
-- This function formats Puertorico based Wage Record (i.e. RCO) record header
--
FUNCTION mmrf2_format_rco_record_header(
                   p_report_type          IN  varchar2,
                   p_format               IN  varchar2,
                   p_report_qualifier     IN  varchar2,
                   p_record_name          IN  varchar2
                 )  RETURN VARCHAR2;
--
--BEGIN
--hr_utility.trace_on(null,'PRNHEAD');
END pay_us_mmrf_print_rec_header;
--End of Package specification

 

/
