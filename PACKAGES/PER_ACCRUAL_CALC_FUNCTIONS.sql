--------------------------------------------------------
--  DDL for Package PER_ACCRUAL_CALC_FUNCTIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_ACCRUAL_CALC_FUNCTIONS" AUTHID CURRENT_USER as
/* $Header: peaclcal.pkh 120.4.12010000.1 2008/07/28 04:02:01 appldev ship $ */
--
-- Record type specification
--
Type g_accrual_plan_rec_type is record (
  accrual_formula_id           number,
  accrual_plan_element_type_id number
  );

--
-- Procedure and Function Specifications
--

/* =====================================================================
   Name    : Calculate_Accrual
   Purpose : Determines whether an assignment is enrolled in a plan, and
	     if so, executes the formula to calculate the accrual for
	     the plan(s).
   ---------------------------------------------------------------------*/
procedure Calculate_Accrual
(P_Assignment_ID                  IN Number
,P_Plan_ID                        IN Number
,P_Payroll_ID                     IN Number
,P_Business_Group_ID              IN Number
,P_Accrual_formula_ID             IN Number
,P_Assignment_Action_ID           IN Number default null
,P_Calculation_Date               IN Date
,P_Accrual_Start_Date             IN Date default null
,P_Accrual_Latest_Balance         IN Number default null
,P_Total_Accrued_PTO              OUT NOCOPY Number
,P_Effective_Start_Date           OUT NOCOPY Date
,P_Effective_End_Date             OUT NOCOPY Date
,P_Accrual_End_Date               OUT NOCOPY Date);
--
/* =====================================================================
   Name    : Get_Accrual
   Purpose :
   Returns : Total Accrual
   ---------------------------------------------------------------------*/
Procedure Get_Accrual
(P_Assignment_ID               IN  Number
,P_Calculation_Date            IN  Date
,P_Plan_ID                     IN  Number
,P_Business_Group_ID           IN  Number
,P_Payroll_ID                  IN  Number
,P_Assignment_Action_ID        IN  Number default null
,P_Accrual_Start_Date          IN  Date default null
,P_Accrual_Latest_Balance      IN Number default null
,P_Start_Date                  OUT NOCOPY Date
,P_End_Date                    OUT NOCOPY Date
,P_Accrual_End_Date            OUT NOCOPY Date
,P_Accrual                     OUT NOCOPY number);
--
/* =====================================================================
   Name    : Get_Accrual_Plan
   Purpose :
   Returns : Table of Accrual Plan Details
   ---------------------------------------------------------------------*/
function Get_Accrual_Plan
(P_Plan_ID                IN  Number) RETURN g_accrual_plan_rec_type;
--
/* =====================================================================
   Name    : Check_Assignment_Enrollment
   Purpose :
   Returns : True if assignment is enrolled, otherwise false.
   ---------------------------------------------------------------------*/
function Check_Assignment_Enrollment
(P_Assignment_ID                  IN  Number
,P_Accrual_Plan_Element_Type_ID   IN  Number
,P_Calculation_Date               IN  Date) return Boolean;
--
/* =====================================================================
   Name    : Get_Carry_Over_Values
   Purpose :
   Returns : Max Carry over and effective date of carry over. Used by
	     carry over process.
   ---------------------------------------------------------------------*/
procedure Get_Carry_Over_Values
(P_CO_Formula_ID             IN   Number
,P_Assignment_ID             IN   Number
,P_Accrual_Plan_ID           IN   Number
,P_Business_Group_ID         IN   Number
,P_Payroll_ID                IN   Number
,P_Calculation_Date          IN   Date
,P_Session_Date              IN   Date
,P_Accrual_Term              IN   Varchar2
,P_Effective_Date            OUT NOCOPY  Date
,P_Expiry_Date               OUT NOCOPY  Date
,P_Max_Carry_Over            OUT NOCOPY  Number);
--
/* =====================================================================
   Name    : Get_Absence
   Purpose :
   Returns : Total Absence
   ---------------------------------------------------------------------*/
function Get_Absence
(P_Assignment_ID                  IN  Number
,P_Plan_ID                        IN  Number
,P_Calculation_Date               IN  Date
,P_Start_Date                     IN  Date
,p_absence_attendance_type_id     IN  NUMBER default NULL
,p_pto_input_value_id             IN  NUMBER default NULL) return Number;
--
/* =====================================================================
   Name    : Get_Carry_Over
   Purpose :
   Returns : Total Carry Over amount
   ---------------------------------------------------------------------*/
function Get_Carry_Over
(P_Assignment_ID                  IN  Number
,P_Plan_ID                        IN  Number
,P_Calculation_Date               IN  Date
,P_Start_Date                     IN  Date) return Number;
--
/* =====================================================================
   Name    : Get_Other_Net_Contribution
   Purpose :
   Returns :
   ---------------------------------------------------------------------*/
function Get_Other_Net_Contribution
(P_Assignment_ID                  IN  Number
,P_Plan_ID                        IN  Number
,P_Calculation_Date               IN  Date
,P_Start_Date                     IN  Date
,P_Input_Value_ID                 IN  Number default null) return Number;
--
/* =====================================================================
   Name    : Get_Net_Accrual
   Purpose :
   Returns : Total Absence
   ---------------------------------------------------------------------*/
Procedure Get_Net_Accrual
(P_Assignment_ID                  IN  Number
,P_Plan_ID                        IN  Number
,P_Payroll_ID                     IN  Number
,P_Business_Group_ID              IN  Number
,P_Assignment_Action_ID           IN  Number default -1
,P_Calculation_Date               IN  Date
,P_Accrual_Start_Date             IN  Date default null
,P_Accrual_Latest_Balance         IN Number default null
,P_Calling_Point                  IN Varchar2 default 'FRM'
,P_Start_Date                     OUT NOCOPY Date
,P_End_Date                       OUT NOCOPY Date
,P_Accrual_End_Date               OUT NOCOPY Date
,P_Accrual                        OUT NOCOPY Number
,P_Net_Entitlement                OUT NOCOPY Number);
--
/* =====================================================================
   Name    : get_asg_inactive_days
   Purpose : Gets the number of days in a period where the assignment
             status is not 'Active'.
   Returns : Number of inactive days in the period.
   ---------------------------------------------------------------------*/
FUNCTION get_asg_inactive_days
  (p_assignment_id      IN    NUMBER,
   p_period_sd          IN    DATE,
   p_period_ed          IN    DATE) RETURN NUMBER;
--
/* =====================================================================
   Name    : get_working_days
   Purpose : Gets the number of working days in a given period.
   Returns : Number of working days in the period.
   ---------------------------------------------------------------------*/
FUNCTION get_working_days
  (p_start_date  IN    DATE,
   p_end_date    IN    DATE) RETURN NUMBER;
--
end per_accrual_calc_functions;

/
