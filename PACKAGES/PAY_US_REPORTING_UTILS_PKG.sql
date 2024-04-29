--------------------------------------------------------
--  DDL for Package PAY_US_REPORTING_UTILS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_US_REPORTING_UTILS_PKG" AUTHID CURRENT_USER as
/* $Header: pyusmref.pkh 120.6.12010000.1 2008/07/27 23:53:36 appldev ship $  */
 /*===========================================================================+
 |               Copyright (c) 2001 Oracle Corporation                        |
 |                  Redwood Shores, California, USA                           |
 |                       All rights reserved.                                 |
 +============================================================================+
  Name
    pay_us_reporting_utils_pkg

  Purpose
    The purpose of this package is to support the generation of magnetic tape W2
    reports for US legilsative requirements incorporating magtape resilience
    and the new end-of-year design. New Functions will support the Year end
    reporting in MMREF format initially and will be extended to have more
    format.

  Notes

  History
   24-JUL-01 fusman        40.0       created
   02-Nov-01 fusman        40.1       Added two new functions
                                      Character_check and Formula_check.
   26-Nov-01 fusman        115.3      Added dbdrv command.
   10-feb-02 djoshi	   115.4      changed dbdrv command
   03-Sep-02 ppanda        115.6      function named get_file_name added to
                                      fix Bug # 2397313
   19-Jan-03 ppanda        115.7      A new function added to get live balance
                                      This function currently used for MA W2 Mag
                                      Function name is get_live_ee_contrib
   10-Nov-04 meshah        115.8      added function get_ff_archive_value
   07-Nov-05 sudedas       115.11     Added 2 optional input parameters to
                                      format_record function.
   17-Feb-06 sudedas       115.12     Added Functions Get_Employee_Count and Get_Total_Wages
  30-May-06 sackumar     115.113   Added Functions Get_Employee_Count_Monthwise and Get_Wages.
						    Bug 5089997.
   17-Aug-06 sudedas       115.14     Added 2 Optional Input Parameters to
                                      Format_Record : p_input_43, p_input_44
                                      (Bug# 5256745)
   22-Nov-06 sudedas       115.15     Added 2 Optional Input Parameters to
                                      Get_Total_Wages (p_report_type, p_balance_name)
                                      to use this Function in W2 as well (Bug# 5640748)
 ============================================================================*/
 -- Global Variable

    g_number	NUMBER;

 -- Used by Magnetic W2 (MMREF  format).
 /* ============================================================================ */
/* Function Name : calculate_balance
   Purpose       : Purpose of this function is is to provide calculation
                   of Derived balnces that are used in the formula
   Error checking

   Special Note  :


*/

FUNCTION calculate_balance(
                   p_effective_date         IN varchar2,
                   p_balance_name           IN varchar2,
                   p_report_type            IN varchar2,
                   p_format                 IN varchar2,
                   p_report_qualifier       IN varchar2,
                   p_record_name            IN varchar2,
                   p_input_1                IN varchar2,
                   p_input_2                IN varchar2,
                   p_input_3                IN varchar2,
                   p_input_4                IN varchar2,
                   p_input_5                IN varchar2,
                   p_input_6                IN varchar2,
                   p_input_7                IN varchar2,
                   p_input_8                IN varchar2,
                   p_input_9                IN varchar2,
                   p_input_10               IN varchar2,
                   p_input_11               IN varchar2,
                   p_input_12               IN varchar2,
                   p_input_13               IN varchar2,
                   p_input_14               IN varchar2,
                   p_input_15               IN varchar2,
                   p_validate               IN  varchar2,
                   p_exclude_from_output    out nocopy varchar2,
                   sp_out_1                 out nocopy varchar2,
                   sp_out_2                 out nocopy varchar2,
                   sp_out_3                 out nocopy varchar2,
                   sp_out_4                 out nocopy varchar2,
                   sp_out_5                 out nocopy varchar2)
RETURN number;

 -- Used by Magnetic W2 (MMREF  format).
 /* ============================================================================ */
/* Function Name : calculate_wages
   Purpose       : Purpose of this function is is to provide calculation
                   of wages that are used in the formula
   Error checking

   Special Note  :


*/


FUNCTION calculate_wages(
                   p_effective_date        IN varchar2,
                   p_wage_name             IN varchar2,
                   p_report_type           IN varchar2,
                   p_format                IN varchar2,
                   p_report_qualifier      IN varchar2,
                   p_record_name           IN varchar2,
                   p_input_1               IN varchar2,
                   p_gross                 IN varchar2,
                   p_subject               IN varchar2,
                   p_subject_nw            IN varchar2,
                   p_pretax_redns          IN varchar2,
                   p_taxable               IN varchar2,
                   p_validate              IN  varchar2,
                   p_exclude_from_output   out nocopy varchar2,
                   sp_exempt               out nocopy varchar2,
                   sp_reduced_sub          out nocopy varchar2,
                   sp_excess               out nocopy varchar2,
                   sp_reduced_sub_wh       out nocopy varchar2,
                   sp_out_1                out nocopy varchar2)
RETURN number;




/*
    Name       :   get_item_data

    Purpors    : Purpose of this function is  to get live
                 data from the System.This can be replace
                 Call to live database items where error
                 chekcing is required
   Error checking

   Special Note  :


*/

FUNCTION get_item_data(
                   p_assignment_id            number, -- context
                   p_date_earned              date, -- context
                   p_tax_unit_id              number,-- context
                   p_effective_date       IN  varchar2,
                   p_item_name            IN  varchar2,
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
                 )
RETURN varchar2;

/* Function Name : print_record_header
   Purpose       : Function will return the String for header
                   or title line for the Table or table heading
                   related to record for printing in audit files

   Error checking

   Special Note  :


*/

FUNCTION print_record_header(
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
                 )
RETURN varchar2;



/*
   Name            : data_validation
                   : Function will validate data for any
                     database items or can change the data
                     based on the parameters. It should
                     be capable of having special data
                     validation and change function.

   Error checking

   Special Note  :

*/

FUNCTION data_validation(
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
                   sp_out_2               OUT nocopy varchar2
                 )
return varchar2;



/* Function Name : format_record
   Purpose       : Function will return formating of the record
                   there will be one function per record
   Error checking

   Special Note  :


*/


FUNCTION format_record(
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
                   p_input_41             IN  varchar2 default null,
                   p_input_42             IN  varchar2 default null,
                   p_input_43             IN  varchar2 default null,
                   p_input_44             IN  varchar2 default null
                 )

return varchar2;
/* End of Function format_record */



/* Function Name : Get_Territory_Values
   Purpose       :  Purpose of this function is to fetch the balances as well
                    as the data related to territory.
   Error checking

   Special Note  :


*/


FUNCTION Get_Territory_Values(
                   p_assignment_action_id     number, -- context
                   p_tax_unit_id              number,-- context
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
                   sp_out_10              OUT nocopy varchar2)
return varchar2;

FUNCTION CHARACTER_CHECK(p_value IN varchar2)
return varchar2;

FUNCTION Formula_Check(p_report_format IN VARCHAR2,
                       p_formula_name  IN VARCHAR2)
return varchar2;
--
-- Purpose: This function used to derive the Mag file Name for following Magnetic media report
--          processes.
--               1. Federal W-2 Magnetic Media
--               2. State W-2 Magnetic Media
--               3. State Quarterly Wage Listing
--
FUNCTION get_file_name
   ( p_bus_group_id       IN Number,    -- Business Group Id
     p_report_type        IN Varchar2,  -- W2, SQWL
     p_state_code         IN Varchar2,  -- FED or State Code
     p_mag_effective_date IN Varchar2,  -- This would be used to derive period
     p_format_type        IN Varchar2   -- I=ICESA, M=MMREF, T=TIB4, S=State
   ) RETURN varchar2;
--PRAGMA RESTRICT_REFERENCES(get_file_name, WNDS,WNPS);

FUNCTION get_live_ee_contrib( p_assignment_action_id      number,      --context
                              p_tax_unit_id               number       --context
                            ) RETURN VARCHAR2;

FUNCTION get_ff_archive_value (
      p_action_id           NUMBER,   -- context
      p_jurisdiction_code   VARCHAR2, -- context
      p_tax_unit_id         NUMBER,   -- context
      p_data_type           VARCHAR2
   )
      RETURN NUMBER;

/* Function Name : Get_Employee_Count
   Purpose       : Purpose of this function is to get the Number of Employees
                   for each Employer (Tax Unit ID). Created for getting data in SQWL Output.

   Special Note  :

*/

FUNCTION get_employee_count( p_payroll_action_id   number,  --context
                             p_tax_unit_id         number,  --context
                             p_state               varchar2 default null
                            ) RETURN number ;

/* Function Name : Get_Total_Wages
   Purpose       : Purpose of this function is to get the Total Wages (State Specific)
                   to be reported in SQWL Magtape.

   Special Note  :

*/

FUNCTION get_total_wages( p_payroll_action_id   number,  --context
                          p_tax_unit_id         number,  --context
                          p_state               varchar2,
                          -- Following Parameters have been Added later to use it in SQWL as well as W2
                          p_report_type         varchar2 default 'SQWL',
                          p_balance_name        varchar2 default null
                         ) RETURN number ;

/* Function Name : get_wages
   Purpose       : Purpose of this function is to get the Excess Wages (State Specific),
                   total withholding, total workers compensation.

   Special Note  :

*/

function get_wages(p_payroll_action_id   number,  --context
                   p_tax_unit_id         number,  --context
                   p_state               varchar2,
                   p_excess_wages out nocopy number,
                   p_withholding out nocopy number,
                   p_workerscomp out nocopy number
                  )return number;

/* Function Name : get_sui_wages
   Purpose       : this will return the SUI wages
*/

function get_sui_wages(p_payroll_action_id   number,  --context
                   p_tax_unit_id         number,  --context
                   p_state               varchar2,
                   p_sui_gross out nocopy number,
                   p_sui_subj out nocopy number,
                   p_sui_pre_tax out nocopy number,
                   p_sui_taxable out nocopy number
                  )return number;

/* Function Name : Get_Employee_Count_Monthwise
   Purpose       : Purpose of this function is to get the Number of Employees
                   for each Employer (Tax Unit ID). Created for getting data in SQWL Output.

   Special Note  :

*/
FUNCTION get_employee_count_monthwise( p_payroll_action_id   number,  --context
                             p_tax_unit_id         number,  --context
                             p_database_item_name             varchar2
                            ) RETURN number ;

END pay_us_reporting_utils_pkg;

/
