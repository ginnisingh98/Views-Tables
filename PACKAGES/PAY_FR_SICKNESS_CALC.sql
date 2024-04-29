--------------------------------------------------------
--  DDL for Package PAY_FR_SICKNESS_CALC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_FR_SICKNESS_CALC" AUTHID CURRENT_USER AS
/* $Header: pyfrsick.pkh 120.0 2005/05/29 05:10:37 appldev noship $ */
-----------------------------------------------------------------------
-- Date     Ver         Author          Comments
-- 17-9-02  115.0       Aditya T.       Initial version of package with programs reqd by
--                                         Absence report and IJSS calc
-- 24-9-02              ASNELL          Added stubs for function calls
-- 30-9-02              Satyajit           Added procedure Calculate_Sickness_Deduction
--                                         and function Get_Open_Days
-- 01-10-02             ASNELL          modified stub calls
-- 07-10-02             ABhaduri        Modified functions for IJSS and
--                                        g_overlap declaration
-- 08-10-02             ABhaduri        Added procedure Get_abs_print_flg
--                                         For checking validity and eligibility
--                                         absences from the report.
-- 08-10-02             asnell          Added function get_sickness_skip
-- 09-10-02             jrhodes         Completed calc_sickness
--                                         get_sickness_skip
--                                         compare_guarantee
--                                       Get_backdated_payments
--                                       get_Reference_salary
-- 09-10-02 115.9       jrhodes          Completed calc_ijss_gross
--                                         Included temproray FR_ROLLING_BALANCE
-- 10-10-02 115.10      jrhodes          Added t_absence_calc
--                                      .parent_absence_start_date
-- 10-10-02             asnell          Added get_gi_payments_audit
-- 11-10-02 115.13      autiwari        Completed Calc_Legal_GI and changed order
--                                         of definitions of procs
-- 14-10-02 115.15      asnell          added ,p_absence_arch to calc_cagr_gi call
-- 05-11-02 115.17      autiwari        Modified Get_sickness_skip: added parameters
--                                        action_start_date and action_end_date
-- 24-12-02 115.20      abhaduri        Modifications for CPAM processing
--                                      Added 3 new functions/procedures.
--                                      Modified t_absence_calc.
-- 05-02-03 115.21      asnell          change for maternity extensions
-- 28-05-03 115.22      autiwari	Bug#2977789 - Parameter Subrogated dropped
--					from function get_sickness_cpam_skip
-- 05-08-03 115.23      asnell          added concatenated_inputs and
--                                      concatenated_result_values
-- 11-12-03 115.24      asnell          added set_global_ids
-- ---------------------------------------------------------------------
--
--


-- GLOBAL DATA STRUCTURES
TYPE G_overlap_rec IS RECORD(
Absence_day             Date,
IJSS_Gross              Number,
IJSS_Net                Number,
Holiday                 Varchar2(3));
--
TYPE t_absence_calc is RECORD
(element_entry_id number
,date_earned date
,ID number
,effective_start_date date
,effective_end_date date
,initiator varchar2(30)
,IJSS_payment_start_date date
,IJSS_payment_end_date date
,IJSS_estimated varchar2(30)
,IJSS_subrogated varchar2(30)
,parent_absence_id number
,parent_absence_start_date date
,parent_absence_inf_cat varchar2(30)
,work_incident varchar2(30)
,prior_linked_absence_duration number
-- added lines for CPAM processing
,ijss_net_daily_rate number
,ijss_gross_daily_rate number
,abs_ptd_start_date date
,abs_ptd_end_date date);

g_absence_calc t_absence_calc;

--
TYPE g_overlap_table IS TABLE OF g_overlap_rec INDEX BY BINARY_INTEGER;
g_overlap g_overlap_table;

-- PUBLIC FUNCTIONS
FUNCTION IJSS_Eligibility_Working_hours(
P_Legislation_code      IN      Varchar2 := 'FR',
P_Business_group_id     IN      Number,
P_Assignment_id         IN      Number,
P_Absence_start_date    IN      Date,
P_long_absence          IN      Boolean)
RETURN Varchar2;

FUNCTION IJSS_Eligibility_SMID(
P_Legislation_code      IN      Varchar2 := 'FR',
P_Business_group_id     IN      Number,
P_Assignment_id         IN      Number,
P_Absence_start_date    IN      Date,
P_long_absence          IN      Boolean)
RETURN Number;

-- Returns Amount of salary for a period
-- Sickness needs (Gross Salary - Professional Reductions)
-- Maternity needs (Gross Salary - New balance [Statutory deductions
--                      +Conventional deductions+CSG-Non mandatory])
FUNCTION Get_Reference_salary(
P_Business_group_id     IN      Number,
P_Assignment_id         IN      Number,
P_Period_end_date       IN      Date,
P_Absence_category      IN      Varchar2)
RETURN Number;

-- Returns Amount received as backdated retro payments for the previous calendar year
-- Or for the calendar year before previous in a period,
-- Depending on the parameter 'calendar_year_before' either '1' or '2'
--
PROCEDURE Get_backdated_payments(
P_Business_group_id     IN      Number,
P_Assignment_id         IN      Number,
P_Period_end_date       IN      Date,
P_Absence_category      IN      Varchar2 default 'S',
p_payment_backyr_1      OUT NOCOPY Number,
p_payment_backyr_2      OUT NOCOPY Number) ;

-- CALC_SICKNESS_DEDUCTION
-- fires legislative or user formula as indicated on the establishment
-- to calculate the deduction for sickness absence

PROCEDURE Calculate_Sickness_Deduction
(p_absence_start_date IN date,
 p_absence_end_date   IN date,
 p_asg                IN pay_fr_sick_pay_processing.t_asg,
 p_absence_arch       IN OUT NOCOPY pay_fr_sick_pay_processing.t_absence_arch);

-- GET_OPEN_DAYS
-- Function to calculate open days between two dates
FUNCTION Get_Open_Days
                (p_start_date         IN  Date,
                 p_end_date           IN  Date ) RETURN Number;


-- CALC_IJSS
-- calculates IJSS gross and net and populates on the g_overlap table
PROCEDURE Calc_IJSS(
p_business_group_id     IN  Number,
p_assignment_id         IN  Number,
p_absence_id            IN  Number,
p_start_date            IN  Date,
p_end_date              IN  Date,
p_absence_duration      IN  Number,
p_work_inc_class        IN  Varchar2);

-- Checks for IJSS eligibility
PROCEDURE IJSS_Eligibility_Check(
P_legislation_code       IN      Varchar2,
P_business_group_id      IN     Number,
P_assignment_id          IN     Number,
P_absence_id             IN     Number,
P_abs_start_date         IN     Date,
P_short_term_eligibility OUT NOCOPY Varchar2,
P_long_term_eligibility  OUT NOCOPY Varchar2,
P_Message                OUT NOCOPY Varchar2);
--
-----------------------------------------------------------------------
-- Common Functions for LEGI / CAGR
--
PROCEDURE Get_GI_Bands_Audit
        (p_GI_id                IN      Number,
         p_asg                  IN      pay_fr_sick_pay_processing.t_asg,
         p_date_to              IN      Date,
         p_band_expiry_duration IN      Varchar2,
         p_band1_days    OUT NOCOPY Number,
         p_band2_days    OUT NOCOPY Number,
         p_band3_days    OUT NOCOPY Number,
         p_band4_days    OUT NOCOPY Number);

--
-----------------------------------------------------------------------
-- Procedure GET_GI_PAYMENTS_AUDIT
-----------------------------------------------------------------------
-- fetch results from element FR_SICKNESS_GI_INFO for a particular
-- absence and guarantee
--

PROCEDURE Get_GI_Payments_Audit
        (p_GI_id                IN      Number,
         p_asg                  IN      pay_fr_sick_pay_processing.t_asg,
         p_parent_absence_id    IN      Number,
         p_current_date         IN      Date,
         p_GI_Previous_Net OUT NOCOPY   Number,
         p_GI_Previous_Payment OUT NOCOPY       Number,
         p_GI_Previous_Adjustment OUT NOCOPY    Number,
         p_GI_Previous_IJSS_Gross OUT NOCOPY    Number,
         p_GI_Best_Method        OUT NOCOPY     Varchar2);
-----------------------------------------------------------------------

PROCEDURE Get_abs_print_flg(p_business_group_id  IN Number,
                           p_parent_abs_id  IN Number,
                           p_period_end_date IN Date, -- for subrogation date
                           p_person_id IN Number,
                           p_abs_duration OUT NOCOPY Number,-- for eligibility
                           p_invalid_start_date OUT NOCOPY Date, -- for comparison
                           p_subr_start_date OUT NOCOPY Date,
                           p_subr_end_date OUT NOCOPY Date,
                           p_last_absence_date OUT NOCOPY Date,
                           p_maternity_related OUT NOCOPY varchar2) ;

FUNCTION Get_Sickness_skip(
P_Assignment_id         IN      Number,
P_element_entry_id      IN      Number,
P_date_earned           IN      Date,
P_action_start_date     IN      Date,
P_action_end_date       IN      Date)
RETURN Varchar2;
--
FUNCTION Get_Sickness_skip_result
RETURN Varchar2;
--

PROCEDURE Compare_Guarantee
(p_absence_arch   IN OUT NOCOPY pay_fr_sick_pay_processing.t_absence_arch
,p_coverages      IN OUT NOCOPY pay_fr_sick_pay_processing.t_coverages);
--
-- CALC_SICKNESS
-- initiates all sickness calculations and performs comparison of
-- most beneficial guarantee over the whole absence period.
--
PROCEDURE calc_sickness(
P_mode         IN OUT NOCOPY VARCHAR2 ,
p_asg           IN OUT NOCOPY pay_fr_sick_pay_processing.t_asg,
p_absence_arch  IN OUT NOCOPY pay_fr_sick_pay_processing.t_absence_arch,
p_coverages     IN OUT NOCOPY pay_fr_sick_pay_processing.t_coverages);
--
-----------------------------------------------------------------------
-- Function FR_ROLLING_BALANCE
----------------------------------------------------------------------
Function fr_rolling_balance (p_assignment_id in number,
                             p_balance_name in varchar2,
                             p_balance_start_date in date,
                             p_balance_end_date in date) return number;

--
-----------------------------------------------------------------------
-- CALC_LEGAL_GI
-----------------------------------------------------------------------
-- Calculate Legal Guaranteed Income
--
PROCEDURE Calc_LEGAL_GI
   (p_asg               IN pay_fr_sick_pay_processing.t_asg
   ,p_coverages         IN OUT NOCOPY pay_fr_sick_pay_processing.t_coverages
   ,p_absence_arch      IN OUT NOCOPY pay_fr_sick_pay_processing.t_absence_arch);

-- CALC_CAGR_GI
PROCEDURE Calc_CAGR_GI
   (p_asg               IN pay_fr_sick_pay_processing.t_asg
   ,p_coverages         IN OUT NOCOPY pay_fr_sick_pay_processing.t_coverages
   ,p_absence_arch      IN OUT NOCOPY pay_fr_sick_pay_processing.t_absence_arch);

-- Addded functions and procedures for CPAM processing
FUNCTION get_sickness_cpam_skip(
p_business_group_id     IN      Number,
P_Assignment_id         IN      Number,
P_element_entry_id      IN      Number,
P_date_earned           IN      Date,
P_payment_start_date    IN      Date,
P_payment_end_date      IN      Date,
--P_subrogated            IN      Varchar2,
P_net_daily_rate        IN      Number,
P_gross_daily_rate      IN      Number) RETURN Varchar2;

PROCEDURE Get_CPAM_Ref_salary(
P_Business_group_id     IN      Number,
P_Assignment_id         IN      Number,
P_Absence_arch          IN OUT NOCOPY pay_fr_sick_pay_processing.t_asg);

PROCEDURE get_sickness_CPAM_IJSS(
p_business_group_id     IN  Number,
p_assignment_id         IN  Number,
p_absence_id            IN  Number,
p_start_date            IN  Date,
p_end_date              IN  Date,
p_work_inc_class        IN  Varchar2);

-----------------------------------------------------------------------------
--  CONCATENATED_INPUTS
--  returns a string that is a concatenation of the entry values for a given
--  element entry. For use in reports when presenting the inputs for an
--  entry on a single line of information.
-----------------------------------------------------------------------------
FUNCTION concatenated_inputs(
            p_element_entry_id in number
           ,p_effective_date in DATE
           ,p_delimiter in varchar2 DEFAULT '|'
           )
RETURN varchar2;
PRAGMA RESTRICT_REFERENCES (concatenated_inputs ,WNDS,WNPS );

-----------------------------------------------------------------------------
--  CONCATENATED_RESULT_VALUES
--  returns a string that is a concatenation of the entry values for a given
--  element entry. For use in reports when presenting the inputs for a
--  result on a single line of information.
-----------------------------------------------------------------------------
FUNCTION concatenated_result_values(
            p_run_result_id in number
           ,p_delimiter in varchar2 DEFAULT '|'
           )
RETURN varchar2;
PRAGMA RESTRICT_REFERENCES (concatenated_result_values ,WNDS,WNPS );

-----------------------------------------------------------------------------
--  CONCATENATED_INPUT_NAMES
--  returns a string that is a concatenation of the input names for a given
--  element type. For use in reports when providing a key to interpret
--  concatenated_inputs string.
-----------------------------------------------------------------------------
FUNCTION concatenated_input_names(
            p_element_type_id in number
           ,p_effective_date in DATE
           ,p_delimiter in varchar2 DEFAULT '|'
           )
RETURN varchar2;
PRAGMA RESTRICT_REFERENCES (concatenated_input_names ,WNDS,WNPS );

-----------------------------------------------------------------------------

PROCEDURE set_global_ids( p_effective_date IN date);

END PAY_FR_SICKNESS_CALC;

 

/
