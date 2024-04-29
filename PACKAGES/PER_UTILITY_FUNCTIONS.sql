--------------------------------------------------------
--  DDL for Package PER_UTILITY_FUNCTIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_UTILITY_FUNCTIONS" AUTHID CURRENT_USER as
/* $Header: peutlfnc.pkh 120.1 2006/10/10 12:48:45 agolechh noship $ */
--
/* =====================================================================
   Name    : Get_Payroll_Period
   Purpose : To determine the payroll period spanning a given date and
             to set global variables containg the start and end dates and the
             period number
   Returns : 0 if successful, 1 otherwise
   ---------------------------------------------------------------------*/
function Get_Payroll_Period
(P_Payroll_ID                     IN  Number
,P_Date_In_Period                 IN  Date) return number;
--
/* =====================================================================
   Name    : Get_Accrual_Band
   Purpose : To determine the accrual band that spans the specified number of
             years and to set global variables containing the ANNUAL_RATE,
             UPPER_LIMIT and CEILING values.
   Returns : 0 if successful, 1 otherwise
   ---------------------------------------------------------------------*/
function Get_Accrual_Band
(P_Plan_ID                        IN  Number
,P_Number_Of_Years                IN  Number) return number;
--
/* =====================================================================
   Name    : Get_Period_Dates
   Purpose : To determine the start and end dates of a period of time that
             spans a given date, which is of a given duration (e.g. Month) and
             which is a mulitple of that duration from a given Start date
             (e.g. 6 months on from 01/01/90)
             The globals PERIOD_START_DATE and PERIOD_END_DATE are populated
   Returns : 0 if successful, 1 otherwise
   ---------------------------------------------------------------------*/
function Get_Period_Dates
(P_Date_In_Period                 IN  Date
,P_Period_Unit                    IN  Varchar2
,P_Base_Start_Date                IN  Date
,P_Unit_Multiplier                IN  Number) RETURN Number;
--
/* =====================================================================
   Name    : Get_Assignment_Status
   Purpose : To determine assignment status spanning a given date
             The globals ASSIGNMENT_EFFECTIVE_SD, ASSIGNMENT_EFFECTIVE_ED and
             ASSIGNMENT_SYSTEM_STATUS are populated
   Returns : 0 if successful, 1 otherwise
   ---------------------------------------------------------------------*/
function Get_Assignment_Status
(P_Assignment_ID                  IN  Number
,P_Effective_Date                 IN  Date) return Number;
--
/* =====================================================================
   Name    : Calculate_Payroll_Periods
   Purpose : Calculates number of periods in one year for the payroll
             indicated by payroll_id, and the first day of the calendar
             year on which there exists a valid payroll period.
   Returns : 0 if successful, 1 otherwise
   ---------------------------------------------------------------------*/
function Calculate_Payroll_Periods
(P_Payroll_ID                  IN  Number,
 P_Calculation_Date            IN  Date) return number;
--
/* =====================================================================
   Name    : Get_Start_Date
   Purpose : Calculates the adjusted start date for accruals, by checking
             for element entries attached to an accrual plan which have not
             yet been processed in a payroll run.
   Returns : Effective start date of payroll period.
   ---------------------------------------------------------------------*/
function Get_Start_Date
(P_Assignment_ID               IN  Number,
 P_Accrual_Plan_ID             IN  Number,
 P_Assignment_Action_Id        IN  Number,
 P_Accrual_Start_Date          IN  Date,
 P_Turn_Of_Year_Date           IN  Date) return Date;
--
/* =====================================================================
   Name    : Get_Net_Accrual
   Purpose : Wrapper function for per_accrual_calc_functions.get_net_accrual.
             Only returns accrued time figure.
   Returns : 0 if successful, 1 otherwise
   ---------------------------------------------------------------------*/
function Get_Net_Accrual
(P_Assignment_ID                  IN  Number
,P_Payroll_ID                     IN  Number
,P_Business_Group_ID              IN  Number
,P_Assignment_Action_ID           IN  Number default null
,P_Calculation_Date               IN  Date
,P_Plan_ID                        IN  Number
,P_Accrual_Start_Date             IN  Date default null
,P_Accrual_Latest_Balance         IN  Number default null) return number;
--
/* =====================================================================
   Name    : Get_Element_Entry
   Purpose : Assigns value of element entry id context to a
             global variable.
   Returns : 1
   ---------------------------------------------------------------------*/
function Get_Element_Entry
 (P_Element_Entry_Id            IN  Number,
  P_Assignment_ID               IN  Number,
  P_Assignment_Action_Id        IN  Number) return Number;
--
--
/* =====================================================================
   Name    : Get_Retro_Element
   Purpose : Retrieves retrospective elements in order for them to be
             tagged as processed.
             Overloaded version of function for use where element_entry_id
             context is unavailable.
   Returns : Element Entry ID
   ---------------------------------------------------------------------*/
function Get_Retro_Element return Number;
--
--
/* =====================================================================
   Name    : Calculate_Hours_Worked
   Purpose : Calculates the total number of hours worked in a given date
             range.  Moved here to create global version as previously
	     only localised versions existed (Bug 2720878).
   Returns : Number of hours
   ---------------------------------------------------------------------*/
FUNCTION Calculate_Hours_Worked
  (p_std_hrs	  in NUMBER,
   p_range_start  in DATE,
   p_range_end	  in DATE,
   p_std_freq	  in VARCHAR2) RETURN NUMBER;
--
function Get_Payroll_ID
(P_asg_ID		IN  Number
,P_Payroll_Id           IN  Number
,P_Date_In_Period	IN  Date) return number;
--
function Get_Payroll_Details
(P_payroll_ID		IN  Number
,P_Date_In_Period	IN  Date) return number;
--
/* ========================================================================
   Name    : get_action_parameter
   Purpose : Gets the Action Parameter from a cached pl/sql table to prevent
             same table scans on pay_action_parameters view.
   Returns : parameter value.
   -----------------------------------------------------------------------*/
function get_action_parameter(p_prm_name   in varchar2) return varchar2;

--
/* =====================================================================
   Name    : Reset_PTO_Accruals
   Purpose : Determines whether the PTO accruals for an assignment
             should be recalculated from the beginning.
             This is based on RESET_PTO_ACCRUALS action parameter
   Returns : 'FALSE' or 'TRUE'
   ---------------------------------------------------------------------*/
function Reset_PTO_Accruals return varchar2;
--
/* =====================================================================
   Name    : Get_Earliest_AsgChange_Date
   Purpose : Determines the earliest assignment status change recorded
             by the Payroll Events Model.
   Returns : Date
   ---------------------------------------------------------------------*/
FUNCTION Get_Earliest_AsgChange_Date(p_business_group_id NUMBER
                                    ,p_assignment_id     NUMBER
                                    ,p_event_group       VARCHAR2
                                    ,p_start_date        DATE
                                    ,p_end_date          DATE
                                    ,p_recalc_date       DATE)
   RETURN DATE;
--
/* =====================================================================
   Name    : Get_Legislation
   =====================================================================
   Purpose : Retrieves the legislation code associated with
             business group.
   Returns : Legislation code.
   ---------------------------------------------------------------------*/
function get_legislation (p_business_group_id number)
   return varchar2;
--
FUNCTION GET_PAYROLL_DTRANGE(P_Payroll_ID Number)
  return NUMBER;
--
FUNCTION GET_PER_TERMINATION_DATE (P_Assignment_id  Number)
  return NUMBER;
--
end per_utility_functions;

/
