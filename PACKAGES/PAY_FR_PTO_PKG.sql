--------------------------------------------------------
--  DDL for Package PAY_FR_PTO_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_FR_PTO_PKG" AUTHID CURRENT_USER as
/* $Header: pyfrhpto.pkh 120.1 2005/08/30 02:52:53 ayegappa noship $ */

Type g_fr_payslip_info_rec is record (
  Assignment_id                Number
 ,plan_name                    Varchar2(50)
 ,Accrual                      Number
 ,Entitlement                  Number
 ,Taken                        Number
 ,Balance                      Number
);

Type g_fr_payslip_inf_tab is table of g_fr_payslip_info_rec index by binary_integer;
g_fr_payslip_info g_fr_payslip_inf_tab;

Type g_fr_pay_info is record (
  pay_reg_element_id           Number
 ,pay_reg_payment_input_ID     Number
 ,pay_reg_plan_input_ID        Number
 ,pay_reg_date_input_ID        Number
 ,pay_element_id               Number
 ,pay_total_days_input_ID      Number
 ,pay_protected_days_input_ID  Number
 ,pay_accrual_date_input_ID    Number
 ,pay_payment_input_ID         Number
 ,pay_flag_input_ID            Number
 ,pay_plan_input_ID            Number
 ,pay_abs_attend_input_id      Number
);


Type g_fr_plan_info is record (
  accrual_plan_id           number
 ,accrual_date              date
 ,accrual_year_start        date
 ,accrual_year_end          date
 ,accrual_start_month       number
 ,entitlement_offset        number
 ,entitlement_duration      number
 ,working_days              Number
 ,protected_days            Number
 ,accounting_method         Varchar2(30)
 ,ent_accrual_date_iv_id    number
 ,ent_reference_sal_iv_id   number
 ,ent_reference_days_iv_id  number
 ,ent_m_iv_id               number
 ,ent_p_iv_id               number
 ,ent_c_iv_id               number
 ,ent_s_iv_id               number
 ,ent_y_iv_id               number
 ,ent_acp_iv_id             Number
 ,obs_accrual_date_iv_id    number
 ,obs_m_iv_id               number
 ,obs_p_iv_id               number
 ,obs_c_iv_id               number
 ,obs_s_iv_id               number
 ,obs_y_iv_id               number
 ,obs_acp_iv_id             Number
 ,adj_accrual_date_iv_id    number
 ,adj_m_iv_id               number
 ,adj_p_iv_id               number
 ,adj_c_iv_id               number
 ,adj_s_iv_id               number
 ,adj_y_iv_id               number
 ,adj_acp_iv_id             Number
 ,main_holiday_acc_plan_id  number
 ,holiday_element_id        Number
 ,accrual_plan_element_id   Number
 ,working_days_iv_id        Number
 ,protected_days_iv_id      Number
 ,business_Group_id         Number
 ,ent_element_id            Number
 ,obs_element_id            Number
 ,adj_element_id            Number
 -- added 3 parameters for termination processing
 ,term_element_id           Number
 ,term_accrual_date_iv_id   Number
 ,term_days_iv_id           Number);

type rate_rec is record (
     main_rate      number
    ,protected_rate number
    ,start_date     date
    ,end_date       date);
type rate_tab is table of rate_rec index by binary_integer;
g_rate_assignment_in_table number;
g_plan_in_table            number;

-------------------------------------------------------------------------------
-- LOAD_FR_PAYSLIP_ACCRUAL_DATA                                   Archiver Call
-------------------------------------------------------------------------------
Procedure load_fr_payslip_accrual_data
(P_assignment_id                  IN Number
,p_date_earned                    IN Date
,p_business_Group_id              IN Number);
--
-------------------------------------------------------------------------------
-- GET_FR_NET_ENTITLEMENT
-------------------------------------------------------------------------------
procedure get_fr_net_entitlement            /* gets the net entitlement per type of accrual for a given   */
                                            /* assignment / accrual plan.                                 */
(p_accrual_plan_id                IN Number
,p_effective_date                 IN Date   /* a date in the ACCRUAL year                                 */
,p_assignment_id                  IN Number
,p_ignore_ent_adjustments         IN Varchar2 default 'N' /* used by entitlement storage CM program */
-- adding extra parameter for additional holidays
-- to get correct accrual dates
,p_accrual_type                   IN varchar2 default null
,p_legal_period_end               IN date default null
--
,p_remaining                     OUT NOCOPY Number  /* the total of the remaining net entitlement                */
,p_net_main                      OUT NOCOPY Number
,p_net_protected                 OUT NOCOPY Number
,p_net_young_mothers             OUT NOCOPY Number
,p_net_seniority                 OUT NOCOPY Number
,p_net_conventional              OUT NOCOPY Number
,p_ent_main                      OUT NOCOPY Number
,p_ent_protected                 OUT NOCOPY Number
,p_ent_young_mothers             OUT NOCOPY Number
,p_ent_seniority                 OUT NOCOPY Number
,p_ent_conventional              OUT NOCOPY Number
,p_accrual_start_date            OUT NOCOPY Date
,p_accrual_end_date              OUT NOCOPY Date
,p_type_calculation              IN Varchar2 default 'N' /* Normal, Y=Payslip A=Archive */
,p_paid_days_to                  IN Date     default null
);
-------------------------------------------------------------------------------
-- FUNCTION                                             GET_REG_PAYMENT_GLOBALS
-------------------------------------------------------------------------------
function get_payment_globals
return g_fr_pay_info;
-------------------------------------------------------------------------------
-- FUNCTION                                           FR_LATEST_PLAN_START_DATE
-------------------------------------------------------------------------------
function fr_latest_plan_start_date (p_element_entry_id  in number)
return date;
-------------------------------------------------------------------------------
-- FUNCTION                                             GET_PAYMENT_GLOBALS_R
-------------------------------------------------------------------------------
function get_payment_globals_r
return g_fr_pay_info;
-------------------------------------------------------------------------------
-- Get FR_HOLIDAY_REG_DETAILS                                  REG Fast Formula
-------------------------------------------------------------------------------
function Get_fr_holiday_reg_details
(P_assignment_id                  IN Number
,p_date_earned                    IN Date
,P_accrual_plan_id                IN Number
,P_accrual_date                   IN Date
,P_accrue_start_Date             OUT NOCOPY Date     /* period start date of accrual year   */
,P_accrue_end_date               OUT NOCOPY Date     /* period start date of accrual year   */
,P_reference_entitlement         OUT NOCOPY Number   /* The main days of entitlement in the accrual year    */
,p_reference_salary              OUT NOCOPY Number   /* the salary (stored on entitlement element)    */
,p_session_date                  OUT NOCOPY Date     /* The sesssion date */
,p_regularization_possible       OUT NOCOPY Varchar2 /* flag if this accrual period is not yet closed as at effective date */
,p_total_days_paid               OUT NOCOPY Number   /* The number of days paid in this accrual year      */
,p_total_payment_made            OUT NOCOPY Number   /*The original payment made for those days           */
,p_previous_reg_payments         OUT NOCOPY Number   /* Any previous regularization payments made         */
)
return number;
--
-------------------------------------------------------------------------------
-- Get NEW Accrual PLAN INFO
-------------------------------------------------------------------------------
Function get_fr_accrual_plan_info(
 p_accrual_plan_id           IN number
,p_element_entry_id          IN number default null
,p_accrual_date              IN date   default null
)  return g_fr_plan_info;
--
-------------------------------------------------------------------------------
-- Write Regularization Payments
-------------------------------------------------------------------------------
Function write_regularization_payment
(p_accrual_plan_id  number,
 p_y0_reg_payment number,
 p_y0_accrual_date date,
 p_y1_reg_payment number,
 p_y1_accrual_date date,
 p_y2_reg_payment number,
 p_y2_accrual_date date,
 p_y3_reg_payment number,
 p_y3_accrual_date date
) return number;
--
-------------------------------------------------------------------------------
-- FUNCTION                 READ_REGULARIZATION_PAYMENT                     --
-------------------------------------------------------------------------------
Function read_regularization_payment
(p_accrual_plan_id       IN number,
 p_index                 IN  number,
 p_reg_payment       OUT NOCOPY number,
 p_accrual_date      OUT NOCOPY date,
 p_next_payment      OUT NOCOPY number)
 return number;
 --
-------------------------------------------------------------------------------
-- FUNCTION                 GET_FR_REG_PAYMENTS                              --
-------------------------------------------------------------------------------
function Get_fr_reg_payments
(p_assignment_id       IN Number
,p_date_earned         IN Date
,p_accrual_plan_id     IN Number
,p_calculation_date    IN Date
,p_y0_term_payments    IN Number
,p_y1_term_payments    IN Number
,p_global_reg_sal_pct  IN Number
,p_daily_rate          IN Number
,p_y0_regularized_amt  OUT NOCOPY Number
,p_y1_regularized_amt  OUT NOCOPY Number
,p_y2_regularized_amt  OUT NOCOPY Number
,p_y3_regularized_amt  OUT NOCOPY Number
,p_y0_accrual_date     OUT NOCOPY Date
,p_y1_accrual_date     OUT NOCOPY Date
,p_y2_accrual_date     OUT NOCOPY Date
,p_y3_accrual_date     OUT NOCOPY Date
,p_reg_option_flg      OUT NOCOPY Varchar2
) return number;
--
-------------------------------------------------------------------------------
-- FR_CREATE_ENTITLEMENT                             CONCURRENT MANAGER PROGRAM
-------------------------------------------------------------------------------
procedure fr_create_entitlement
(ERRBUF               OUT NOCOPY varchar2
,RETCODE              OUT NOCOPY number
,P_business_group_id  IN  number
,p_assignment_id      IN  number DEFAULT Null
,P_calculation_date   IN  varchar2
,P_accrual_date       IN  varchar2
,P_plan_id            IN  number
,P_type               IN  varchar2);

--
-------------------------------------------------------------------------------
-- FR_GET_ACCRUAL                                                          HIGH
-------------------------------------------------------------------------------
procedure FR_Get_Accrual
(P_Assignment_ID                  IN  Number
,P_Calculation_Date               IN  Date   /* as at date, also identifies the accrual plan */
,p_accrual_start_date             IN  Date   /* extra date parameter for now */
,P_Plan_ID                        IN  Number
,P_Business_Group_ID              IN  Number
,P_Payroll_ID                     IN  Number
,P_Assignment_Action_ID           IN  Number default null
,P_Accrual_Latest_Balance         IN Number default null
,p_create_all                     IN Varchar2 default 'N' /* inicator to show if all types should be created */
                                                          /* if set to 'N' default will be to just return  */
                                                          /* main and protected, but user implementation can */
                                                          /* change this */
,p_reprocess_whole_period         IN Varchar2 default 'N' /* indicates if the accrual should be evaluaed from the */
                                                          /* last entitlement storage date, or from accrual year start */
                                                          /* This will be set yo 'Y' for entitlement creation process */
                                                          /* which must reevaluate the entire accrual to overcome */
                                                          /* rounding errors */
,p_payslip_process                IN Varchar2 default 'N' /* indicates if called via payslip - if so do not deduct holidays */
                                                          /* as they wil be shown against entitlements */
-- Added extra inputs for additional days requirements
,p_legal_period_start_date	      IN Date     default null
,p_entitlement_offset	          IN Number   default null
,p_main_holiday_acc_plan_id       IN Number   default null
,p_type			                  IN Varchar2 default null
--
,P_Start_Date                     OUT NOCOPY Date                /* accrual year start date */
,P_End_Date                       OUT NOCOPY Date                /* calculation date   */
,P_Accrual_End_Date               OUT NOCOPY Date                /* accrual end date        */
,P_total_accrued_pto              OUT NOCOPY number
,P_total_Accrued_protected        OUT NOCOPY number
,P_total_Accrued_seniority        OUT NOCOPY number
,P_total_Accrued_mothers          OUT NOCOPY number
,P_total_Accrued_conventional     OUT NOCOPY number
) ;
--
-------------------------------------------------------------------------------
-- FR_CALCULATE_ACRUAL                                                      LOW
-------------------------------------------------------------------------------
procedure FR_Calculate_Accrual
(P_Assignment_ID                  IN Number
,P_Plan_ID                        IN Number
,P_Payroll_ID                     IN Number
,P_Business_Group_ID              IN Number
,P_Accrual_formula_ID             IN Number
,P_Assignment_Action_ID           IN Number default null
,P_Calculation_Date               IN Date
,p_accrual_START_date             IN Date
-- Added extra inputs for additional days requirements
,p_legal_period_start_date	      IN Date default null
,p_entitlement_offset	          IN Number default null
,p_main_holiday_acc_plan_id       IN Number default null
,p_type			                  IN Varchar2 default null
--
,P_Accrual_Latest_Balance         IN Number default null
,P_Total_Accrued_PTO              OUT NOCOPY Number
,p_total_accrued_protected        OUT NOCOPY Number
,p_total_accrued_seniority        OUT NOCOPY Number
,p_total_accrued_mothers          OUT NOCOPY Number
,p_total_accrued_conventional     OUT NOCOPY Number
,P_Effective_Start_Date           OUT NOCOPY Date      /* returned by formula */
,P_Effective_End_Date             OUT NOCOPY Date      /* returned by formula */
,P_Accrual_End_date               OUT NOCOPY Date) ;   /* returned by formula */
--

-------------------------------------------------------------------------------
-- OBSOLETION_PROCEDURE
-------------------------------------------------------------------------------
procedure obsoletion_procedure
(p_business_group_id              IN  number
,p_assignment_id                  IN  number default null
,p_accrual_plan_id                IN  number
,p_effective_date                 IN  date
,p_accrual_date                   IN  date
,p_formula_id                     IN  number
,p_payroll_id                     IN  number
,p_net_entitlement                IN  number
,p_net_main_days                  IN  number
,p_net_conven_days                IN  number
,p_net_seniority_days             IN  number
,p_net_protected_days             IN  number
,p_net_youngmother_days           IN  number
,p_new_main_days                  OUT NOCOPY number
,p_new_conven_days                OUT NOCOPY number
,p_new_seniority_days              OUT NOCOPY number
,p_new_protected_days             OUT NOCOPY number
,p_new_youngmother_days           OUT NOCOPY number) ;
--
-------------------------------------------------------------------------------
-- GET_FR_HOLIDAYS_BOOKED_LIST
-------------------------------------------------------------------------------
function Get_fr_holidays_booked_list
(P_assignment_id                  IN Number   /* the assignment */
,p_business_Group_id              IN Number
,P_accrual_plan_id                IN Number
,p_accrual_start_date             IN Date
,p_accrual_end_date               IN Date
,p_holiday_element_id             IN Number
,p_total_m                       OUT NOCOPY Number
,p_total_p                       OUT NOCOPY Number
,p_total_c                       OUT NOCOPY Number
,p_total_s                       OUT NOCOPY Number
,p_total_y                       OUT NOCOPY Number
) return number;
--
-------------------------------------------------------------------------------
-- GET_FR_HOLIDAYS_BOOKED                                      FORMULA FUNCTION
-------------------------------------------------------------------------------
function Get_fr_holidays_booked
(P_assignment_id                  IN Number   /* the assignment */
,p_business_Group_id              IN Number
,P_accrual_plan_id                IN Number
,p_accrual_start_date             IN Date
,p_total_booked                  OUT NOCOPY Number
) return number;
--
-------------------------------------------------------------------------------
-- GET_FR_YOUNG_MOTHERS_DAYS
-------------------------------------------------------------------------------
function Get_fr_young_mothers_days
(P_assignment_id                  IN Number   /* the assignment */
,p_business_Group_id              IN Number
,P_child_age_date                 IN Date     /* CHILD COMPARISON DATE        */
,p_child_age                      IN Number   /* max age of eligible children */
,p_no_of_children                OUT NOCOPY Number   /* number of children below age */
                                              /* p_child_age on p_effective_date */
) return number;                             /* 1 = true */
-------------------------------------------------------------------------------
-- SET_FR_ACCRUAL_RATE_CHANGES                        ACCRUALS FORMULA FUNCTION
-------------------------------------------------------------------------------
function set_fr_Accrual_rate_changes
(p_assignment_id              IN Number
,p_plan_id                    IN Number
,p_start_date                 IN Date
,p_end_date                   IN Date )
return number ;
-------------------------------------------------------------------------------
-- GET_FR_ACCRUAL_RATE_CHANGES                        ACCRUALS FORMULA FUNCTION
-------------------------------------------------------------------------------
function get_fr_accrual_rate_changes
(p_assignment_id              IN Number
,p_plan_id                    IN Number
,p_month_in_date              IN Date
,p_main_rate                 OUT NOCOPY Number
,p_protected_rate            OUT NOCOPY Number)
return number ;
-------------------------------------------------------------------------------
-- Get GET_FR_LATEST_ENT_DATE                              SUPORTS ACCRUAL FORM
-------------------------------------------------------------------------------
function get_fr_latest_ent_date
(p_assignment_id              IN Number
,p_accrual_plan_id            IN Number
,p_effective_date             IN Date    /* a date in the accrual plan */
,p_latest_date               OUT NOCOPY Date    /* out - the latest date of storage, or null */
,p_entitlement_start_date    OUT NOCOPY Date    /* out - the ent start relative to effective_date */
,p_accrual_start_date        OUT NOCOPY Date
,p_accrual_end_date          OUT NOCOPY Date )
return number ;
-------------------------------------------------------------------------------
-- Get Accrual PLAN INFO
-------------------------------------------------------------------------------
procedure get_accrual_plan_info(
 p_accrual_plan_id           IN OUT NOCOPY number
,p_element_entry_id          IN number default null
,p_accrual_date              IN date   default null
,p_accrual_year_start       OUT NOCOPY date
,p_accrual_year_end         OUT NOCOPY date
,p_accrual_start_month      OUT NOCOPY number
,p_entitlement_offset       OUT NOCOPY number
,p_entitlement_duration     OUT NOCOPY number
,p_working_days             OUT NOCOPY Number
,p_protected_days           OUT NOCOPY Number
,p_accounting_method        OUT NOCOPY Varchar2
,p_ent_accrual_date_iv_id   OUT NOCOPY number
,p_ent_reference_sal_iv_id  OUT NOCOPY number
,p_ent_reference_days_iv_id OUT NOCOPY number
,p_ent_m_iv_id              OUT NOCOPY number
,p_ent_p_iv_id              OUT NOCOPY number
,p_ent_c_iv_id              OUT NOCOPY number
,p_ent_s_iv_id              OUT NOCOPY number
,p_ent_y_iv_id              OUT NOCOPY number
,p_ent_acp_iv_id            OUT NOCOPY Number
,p_obs_accrual_date_iv_id   OUT NOCOPY number
,p_obs_m_iv_id              OUT NOCOPY number
,p_obs_p_iv_id              OUT NOCOPY number
,p_obs_c_iv_id              OUT NOCOPY number
,p_obs_s_iv_id              OUT NOCOPY number
,p_obs_y_iv_id              OUT NOCOPY number
,p_obs_acp_iv_id            OUT NOCOPY Number
,p_adj_accrual_date_iv_id   OUT NOCOPY number
,p_adj_m_iv_id              OUT NOCOPY number
,p_adj_p_iv_id              OUT NOCOPY number
,p_adj_c_iv_id              OUT NOCOPY number
,p_adj_s_iv_id              OUT NOCOPY number
,p_adj_y_iv_id              OUT NOCOPY number
,p_adj_acp_iv_id            OUT NOCOPY Number
,p_main_holiday_acc_plan_id OUT NOCOPY number
,p_holiday_element_id       OUT NOCOPY Number
,p_accrual_plan_element_id  OUT NOCOPY Number
,p_working_days_iv_id       OUT NOCOPY Number
,p_protected_days_iv_id     OUT NOCOPY Number
,p_business_Group_id        OUT NOCOPY Number
,p_ent_element_id           OUT NOCOPY Number
,P_obs_element_id           OUT NOCOPY Number
,P_adj_element_id           OUT NOCOPY Number) ;
--
-------------------------------------------------------------------------------
-- Get_Payment_info
-------------------------------------------------------------------------------
procedure get_payment_info(
 p_days_input_id             OUT NOCOPY number
,p_protected_days_input_id   OUT NOCOPY number
,p_element_type_id           OUT NOCOPY number
,p_absence_input_id          OUT NOCOPY Number);
-------------------------------------------------------------------------------
-- GET_REFERENCE_ENTITLEMENT                        --
-------------------------------------------------------------------------------
procedure get_reference_entitlement
(p_accrual_plan_id                IN Number
,p_accrual_start_date             IN Date
,p_accrual_end_date               IN Date
,p_assignment_id                  IN Number
,p_ent_ref_days_id                IN Number default null
,p_ent_ref_salary_id              IN Number default null
,p_ent_accrual_date_iv_id         IN Number default null
,p_ref_main_days                 OUT NOCOPY Number
,p_ref_salary                    OUT NOCOPY Number ) ;

--
-------------------------------------------------------------------------------
-- Get Accrual Plan Data
-------------------------------------------------------------------------------
procedure get_accrual_plan_data(
 p_accrual_plan_id           IN OUT NOCOPY number
,p_element_entry_id          IN number default null
,p_accrual_date              IN date default null
,p_accrual_year_start       OUT NOCOPY date
,p_accrual_year_end         OUT NOCOPY date
,p_accounting_method        OUT NOCOPY varchar2
,p_entitlement_offset       OUT NOCOPY Number
,p_ent_ref_days_id          OUT NOCOPY number
,p_ent_ref_salary_id        OUT NOCOPY number
,p_ent_accrual_date_iv_id   OUT NOCOPY Number
,p_holiday_element_id       OUT NOCOPY Number
);
-------------------------------------------------------------------------------
-- Get Accrual Plan Overrides
-------------------------------------------------------------------------------
procedure get_accrual_plan_overrides(
 p_accrual_plan_id               IN number
,p_accrual_plan_element_id      OUT NOCOPY Number
,p_working_days_iv_id           OUT NOCOPY Number
,p_protected_days_iv_id         OUT NOCOPY Number
,p_main_rate_defualt_value      OUT NOCOPY Number
,p_protected_rate_defualt_value OUT NOCOPY Number
);
-------------------------------------------------------------------------------
-- GET_PREVIOUS_HOLIDAY_ABSENCE
-------------------------------------------------------------------------------
procedure get_previous_holiday_absence(
 p_absence_attendance_id       IN Number
,p_assignment_id               IN Number
,p_paid_element_type_id        IN Number default null
,p_days_input_id               IN Number default null
,p_protected_days_input_id     IN Number default null
,p_absence_attendance_input_ID IN Number default null
,p_total_days_paid            OUT NOCOPY Number
,p_protected_days_paid        OUT NOCOPY Number ) ;
--
-------------------------------------------------------------------------------
-- GET_FR_HOLIDAY_DETAILS
-------------------------------------------------------------------------------
function Get_fr_holiday_details
(P_ELEMENT_ENTRY_ID               IN Number
,p_date_earned                    IN Date
,p_prorate_end                    IN Date     /* the proration period end date - may be null              */
,P_Absence_attendance_ID         OUT NOCOPY Number   /* Identifier of the Absence Record                         */
,P_accrual_plan_id               OUT NOCOPY Number   /* Identifier of the Accrual plan                           */
,P_Entry_Start_Date              OUT NOCOPY Date     /* The element entry start date of the keyed absence        */
,P_Entry_End_Date                OUT NOCOPY Date     /* The element entry end   date of the keyed absence        */
,P_Date_Accrued                  OUT NOCOPY Date     /* keyed absence ddf accrued date                           */
,P_total_Main_Days               OUT NOCOPY Number   /* keyed absence ddf main days in whole absence             */
,P_total_Seniority_Days          OUT NOCOPY Number   /* keyed absence ddf seniority days in whole absence        */
,P_total_Young_Mothers_Days      OUT NOCOPY Number   /* keyed absence ddf YM days in whole absence               */
,P_total_Conventional_Days       OUT NOCOPY Number   /* keyed absence ddf Conventional days in whole absence     */
,P_total_Protected_Days          OUT NOCOPY Number   /* keyed absence ddf Protected days in whole absence        */
,P_taken_total_days              OUT NOCOPY Number   /* total days paid for this absence in previous periods     */
,P_taken_protected_Days          OUT NOCOPY Number   /* protected days paid for this absence in previous periods */
,P_proration_period              OUT NOCOPY Varchar2 /* LAST -  This is the last of proration period             */
,p_regularize_possible           OUT NOCOPY Varchar2 /* if reference values are stored (Y/N) if can do a reg payt*/
,p_session_date                  OUT NOCOPY Date     /* the session date applicable to this session              */
,p_accrue_start_date             OUT NOCOPY Date     /* The accrual start date, relative to the DDF date_accrued */
,p_accrue_end_date               OUT NOCOPY Date     /* The accrual end date, relative to the accrual start date */
,P_Assignment_id                 OUT NOCOPY Number   /* The assignment ID owning the absence                     */
,p_ref_total_accrued             OUT NOCOPY Number   /* The total accrued in the period, for main and protected  */
,p_reference_salary              OUT NOCOPY Number   /* The reference salary for the accrual period - if available */
,p_accounting_method             OUT NOCOPY Varchar2 /* The accounting method from the accrual plan ddf          */
) return number;
--
-------------------------------------------------------------------------------
-- GET_ACCRUAL_RATE_PERCENTAGE
-------------------------------------------------------------------------------
function Get_accrual_rate_percentage
(P_DATE_EARNED 	       IN  Date
,P_ASSIGNMENT_ID       IN  Number
,P_PROCESS_TYPE        IN  Varchar2
,P_CHARGES_PERCENTAGE  OUT NOCOPY Number
) return number;
-------------------------------------------------------------------------------
-- GET_ACCOUNTING_DETAILS
-------------------------------------------------------------------------------
function Get_accounting_details
(P_ELEMENT_ENTRY_ID               IN Number
,P_PAYROLL_ID                     IN NUMBER
,P_ASSIGNMENT_ID                  IN NUMBER
-- added 2 new parameters and modified 1 parameter for termination
,P_ACCOUNTING_DATE                IN DATE            /* Replaced with new date parameter for termination*/
,p_accounting_plan_id            OUT NOCOPY Number   /* the accrual plan id*/
,p_accrual_start_month           OUT NOCOPY Number   /* the accrual plan's start month*/
--
,p_accounting_method             OUT NOCOPY Varchar2 /* the accrual plan's accounting method                     */
,p_y0_net_days                   OUT NOCOPY Number   /* the assignment's net days to pay for this year           */
,P_y0_ref_salary                 OUT NOCOPY Number   /* the assignment's reference salary for this year          */
,P_y0_ref_days                   OUT NOCOPY Number   /* the assignment's reference days accrued for this year    */
,p_y1_net_days                   OUT NOCOPY Number   /* the assignment's net days to pay for this year           */
,P_y1_ref_salary                 OUT NOCOPY Number   /* the assignment's reference salary for this year          */
,P_y1_ref_days                   OUT NOCOPY Number   /* the assignment's reference days accrued for this year    */
,p_y2_net_days                   OUT NOCOPY Number   /* the assignment's net days to pay for this year           */
,P_y2_ref_salary                 OUT NOCOPY Number   /* the assignment's reference salary for this year          */
,P_y2_ref_days                   OUT NOCOPY Number   /* the assignment's reference days accrued for this year    */
,p_y3_net_days                   OUT NOCOPY Number   /* the assignment's net days to pay for this year           */
,P_y3_ref_salary                 OUT NOCOPY Number   /* the assignment's reference salary for this year          */
,P_y3_ref_days                   OUT NOCOPY Number   /* the assignment's reference days accrued for this year    */
) return number;
--

-------------------------------------------------------------------------------
-- WRITE_TERMINATION_PAYMENT
-------------------------------------------------------------------------------

Function write_termination_payment
(p_accrual_plan_id  number,
 p_y0_payment       number,
 p_y0_payment_days  number,
 p_y0_payment_rate  number,
 p_y0_accrual_year  date,
 p_y1_payment       number,
 p_y1_payment_days  number,
 p_y1_payment_rate  number,
 p_y1_accrual_year  date,
 p_y2_payment       number,
 p_y2_payment_days  number,
 p_y2_payment_rate  number,
 p_y2_accrual_year  date,
 p_y3_payment       number,
 p_y3_payment_days  number,
 p_y3_payment_rate  number,
 p_y3_accrual_year  date
) return number;
--
-------------------------------------------------------------------------------
-- READ_TERMINATION_PAYMENT
-------------------------------------------------------------------------------

Function read_termination_payment
(p_accrual_plan_id IN NUMBER,
 p_index IN number,
 p_payment     OUT NOCOPY number,
 p_days        OUT NOCOPY number,
 p_daily_rate  OUT NOCOPY number,
 p_accrual_date OUT NOCOPY date,
 p_next_payment OUT NOCOPY number)
 return number;
--
-------------------------------------------------------------------------------
-- VALID_FIXED_TERM_CONTRACT_REF
-- Used by FR_FIXED_TERM_CONTRACT_INDEMNITY_REFERENCE Element Input Validation
-------------------------------------------------------------------------------
function Valid_Fixed_Term_Contract_Ref
(p_assignment_id                  in number
,p_date_earned                    in date
,p_reference                      in varchar2) return varchar2;
--
-------------------------------------------------------------------------------
-- CONTRACT_ACTIVE_END_DATE
-- Used by FR_FIXED_TERM_CONTRACT_INDEMNITY formula
-------------------------------------------------------------------------------
function contract_active_end_date
  (p_assignment_id      in number
  ,p_date_earned        in date
  ,p_reference          in varchar2) /* entry ref input value */
return date;
--
-------------------------------------------------------------------------------
-- GET_FIXED_TERM_CTR_ENTRY_INFO
-- Used by FR_FIXED_TERM_CONTRACT_INDEMNITY formula
-------------------------------------------------------------------------------
function Get_Fixed_Term_Ctr_Entry_info
  (p_assignment_id      in number
  ,p_date_earned        in date
  ,p_reference          in varchar2 /* the ref of the entry value */
  ,p_deferred_payment   out nocopy varchar2 /* payment to be deferred? */
) return number;
--
-------------------------------------------------------------------------
-- Check booked holidays for a given plan and period
-- Used by FR_HOLIDAY_PAY_ACCOUNTING_ACCRUAL_SAMPLE formula
-------------------------------------------------------------------------
function Check_fr_holidays_booked
(P_assignment_id                  IN Number   /* the assignment */
,P_accrual_plan_id                IN Number
,p_start_date                     IN Date
,p_end_date        		  IN Date
) return number;
-------------------------------------------------------------------------

--
--------------------------------------------------------------------
-- Function Check_fr_consecutive_holidays_booked
-- Function will return 1 if successful otherewise
-- will return 0. Bug#3030610
--------------------------------------------------------------------------
function Check_fr_cons_holidays_booked
        (P_assignment_id                  IN Number   /* the assignment */
        ,P_accrual_plan_id                IN Number
        ,p_start_date                     IN Date
        ,p_end_date                       IN Date
        ) return number ;
---------------------------------------------------------------------------
--
----------------------------------------------------------------------------
-- Procedure get_fr_add_net_ent
-- called from HREMEA.pld to calculate net additional entitlement
---------------------------------------------------------------------------
PROCEDURE get_fr_add_net_ent(
          p_absence_attendance_type_id in  number,
          p_abs_date_start             in  date,
          p_abs_date_end               in date,
          p_person_id                  in  number,
          p_accrual_plan_id            in  number,
          p_total_ent                  out nocopy number,
          p_net_ent                    out nocopy number);
---------------------------------------------------------------------------
function get_contr_dates(p_assignment_id in number,
                         p_calculation_start_date in date,
                         p_contract_start_date  out nocopy date,
                         p_contract_end_date out nocopy date,
                         p_contract_category out nocopy varchar2)return number;
 ------------------------------------------------------------
 -- Function called from the DIF sub accrual formula
 -- to get the working time values.
 -- Added for bugs 4099667 and 4103779.
 ------------------------------------------------------------
 function get_time_values(p_business_group_id in number,
                          p_assignment_id in number,
                          p_effective_date in date,
                          p_working_hours out nocopy number,
                          p_working_frequency out nocopy varchar2,
                          p_cipdz_catg out nocopy varchar2) return number;
 -------------------------------------------------------
 --Function to retreive the first Rate value for termiantion payments
 --Bug 4538139
 -------------------------------------------------------
 Function read_termination_payment_rate(p_accrual_plan_id IN         NUMBER,
                                        p_days            OUT NOCOPY NUMBER)
				return number;
 -------------------------------------------------------
end;

 

/
