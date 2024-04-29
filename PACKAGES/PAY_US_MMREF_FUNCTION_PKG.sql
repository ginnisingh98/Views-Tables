--------------------------------------------------------
--  DDL for Package PAY_US_MMREF_FUNCTION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_US_MMREF_FUNCTION_PKG" AUTHID CURRENT_USER as
/* $Header: pyusmrfn.pkh 120.0.12010000.1 2008/07/27 23:53:45 appldev ship $  */
 /*===========================================================================+
 |               Copyright (c) 2001 Oracle Corporation                        |
 |                  Redwood Shores, California, USA                           |
 |                       All rights reserved.                                 |
 +============================================================================+
  Name
    pay_us_mmref_function_pkg

  Purpose
    The purpose of this package is to support the generation of magnetic tape W2
    reports for US legilsative requirements incorporating magtape resilience
    and the new end-of-year design. New Functions will support the Year end
    reporting in MMREF format initially and will be extended to have more
    format.

  Notes

  History
   23-Jan-02 fusman        115.0       created
   09-feb-02 djoshi       115.1       changed for dbdrv
   14-may-02 fusman        115.2      Added Get_Hours_Worked function.
   02-Dec-02 ppanda        115.3      Nocopy hint added to OUT and IN OUT parameters
   19-FEB-03 sodhingr      115.4      Changed Get_hours_worked for bug
                                      2442629, to pass new balances for SUI
                                      hours by state
   23-Apr-03 fusman        115.5      Bug: 2873551 Created new function get_sqwl_extra_info
                                      to calculate the SUI_ER_SUBJ_WHABLE and SUI_ER_PRE_TAX.
   01-MAR-03 JGoswami      115.6      Bug:333497 Added IN OUT parameters to
                                      Get_Sqwl_Extra_Info function

 ===========================================================================*/

/* Function Name : Get_City_Values
   Purpose       :  Purpose of this function is to fetch the city codes
                    and names for the given jurisdiction_code.
   Error checking

   Special Note  :


*/

FUNCTION Get_City_Values(p_jurisdiction_code    IN  varchar2,
                         p_effective_date       IN  varchar2,
                         p_input_1              IN varchar2,
                         p_input_2              IN varchar2,
                         p_input_3              IN varchar2,
                         p_input_4              IN varchar2,
                         p_input_5              IN varchar2,
                         sp_out_1               OUT nocopy varchar2,
                         sp_out_2               OUT nocopy varchar2,
                         sp_out_3               OUT nocopy varchar2,
                         sp_out_4               OUT nocopy varchar2,
                         sp_out_5               OUT nocopy varchar2,
                         sp_out_6               OUT nocopy varchar2,
                         sp_out_7               OUT nocopy varchar2,
                         sp_out_8               OUT nocopy varchar2,
                         sp_out_9               OUT nocopy varchar2,
                         sp_out_10              OUT nocopy varchar2)

return varchar2;

FUNCTION Get_Hours_Worked(p_report_type          IN  varchar2,
                          p_report_qualifier     IN  varchar2,
                          p_record_name          IN varchar2,
                          p_regular_hours        IN number,
                          p_sui_er_gross         IN number,
                          p_gross_earnings       IN number,
                          p_asg_hours            IN number,
                          p_asg_freq             IN varchar2,
                          p_scl_asg_work_sch     IN  varchar2,
                          p_input_1              IN varchar2,
                          p_input_2              IN varchar2,
                          sp_out_1               IN OUT nocopy varchar2,
                          sp_out_2               IN OUT nocopy varchar2,
                          sp_out_3               IN OUT nocopy varchar2,
                          sp_out_4               IN OUT nocopy varchar2,
                          sp_out_5               IN OUT nocopy varchar2)


return varchar2;


FUNCTION Get_Sqwl_Extra_Info(p_payroll_action_id           NUMBER, --CONTEXT
                             p_tax_unit_id                 NUMBER, --CONTEXT
                             p_report_type          IN  varchar2,
                             p_report_qualifier     IN  varchar2,
                             p_input_1              IN  varchar2,
                             p_input_2              IN  varchar2,
                             p_input_3              IN  varchar2,
                             p_output_1             IN OUT nocopy varchar2,
                             p_output_2             IN OUT nocopy varchar2,
                             p_output_3             IN OUT nocopy varchar2)

return varchar2;


END pay_us_mmref_function_pkg;

/
