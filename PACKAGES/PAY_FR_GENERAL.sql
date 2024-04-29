--------------------------------------------------------
--  DDL for Package PAY_FR_GENERAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_FR_GENERAL" AUTHID CURRENT_USER as
/* $Header: pyfrgenr.pkh 115.31 2004/04/07 07:01:16 autiwari noship $ */

type band_tbl_type IS TABLE OF
   number
   INDEX BY BINARY_INTEGER;

type base_code_tbl_type IS TABLE OF
   varchar2(4)
   INDEX BY BINARY_INTEGER;

  TYPE t_summary_deduction IS RECORD
  (
     base_type                          VARCHAR2(80)
   , base                               NUMBER
   , Contribution_usage_id_type         VARCHAR2(1)
   , contribution_usage_id              NUMBER
   , rate_type                          VARCHAR2(80)
   , rate                               NUMBER
   , contribution_code                  VARCHAR2(30)
   , pay_value                          NUMBER
   , retro                              VARCHAR2(1));

  TYPE t_summary_deductions IS TABLE OF t_summary_deduction INDEX BY BINARY_INTEGER;

  TYPE t_deduction_rate IS RECORD
  (
     contribution_usage_id              NUMBER
   , tax_unit_id			NUMBER
   , contribution_code                  VARCHAR2(30)
   , rate                               NUMBER
   , user_column_instance_id            NUMBER
   , risk_code                          VARCHAR2(30));

  TYPE t_deduction_rates IS TABLE OF t_deduction_rate INDEX BY BINARY_INTEGER;


g_process_type	        varchar2(10);
g_monthly_hours	        number;
g_calendar_days_worked  number;

g_band_table            band_tbl_type;
g_base_code_table       base_code_tbl_type;

-- Added 115.14
g_payroll_action_id     number;
g_prev_start_date       date;
g_prev_end_date         date;

-- +********************************************************************+
-- |                        PUBLIC FUNCTIONS                            |
-- +********************************************************************+
------------------------------------------------------------------------
-- Function GET_CONTRIBUTION_USAGE
------------------------------------------------------------------------
function get_contribution_usage
			(p_process_type in varchar2
			,p_element_name in varchar2
			,p_usage_type	in varchar2
                       ,p_effective_date in date
                       ,p_business_group_id in number default null)
                               return pay_fr_contribution_usages%rowtype;

------------------------------------------------------------------------
-- Function GET_RATE_VALUE
------------------------------------------------------------------------
function get_rate_value(p_assignment_id in number
 			,p_business_group_id in number default null
                        ,p_date_earned in date
                        ,p_tax_unit_id in number
			,p_element_name in varchar2
			,p_usage_type	in varchar2
			,p_override_rate in number default null) return number;


------------------------------------------------------------------------
-- Function GET_FORMULA_INFO
------------------------------------------------------------------------
function get_formula_info
			(p_formula_name          in varchar2
			,p_effective_date        in date
                        ,p_business_group_id     in number default -1
                        ,p_effective_start_date  out nocopy date
                        ) return number;

------------------------------------------------------------------------
-- Function SUB_CONTRIB_CODE
------------------------------------------------------------------------
function sub_contrib_code(p_contribution_type in varchar2
                         ,p_contribution_code in varchar2) return varchar2;


------------------------------------------------------------------------
-- Function GET_PAYROLL_MESSAGE
------------------------------------------------------------------------
function get_payroll_message
			(p_message_name      in varchar2
			,p_token1       in varchar2 default null
                        ,p_token2       in varchar2 default null
                        ,p_token3       in varchar2 default null) return varchar2;

------------------------------------------------------------------------
-- Function INITIALIZE_PAYROLL
-- ver 115.15 Added params p_assignment_id and p_tax_unit_id
------------------------------------------------------------------------
function initialize_payroll
			(p_business_group_id in number
			,p_effective_date    in date
                        ,p_assignment_id     in number
                        ,p_tax_unit_id       in number
			,p_process_type      in varchar2
			,p_orig_entry_id     in number
			,p_asg_action_id     in number
			,p_payroll_id        in number
                   	,P_ASG_HOURS         in number
                   	,p_asg_frequency     in varchar2 ) return number;

------------------------------------------------------------------------
-- Function GET_URSSAF_BASE_CODE
-- 115.15 added params p_business_group_id and p_date_earned.
------------------------------------------------------------------------
function get_urssaf_base_code(P_ASSIGNMENT_ID             in number
                             ,P_BUSINESS_GROUP_ID         in number
                             ,p_date_earned               in date
                             ,P_ESTAB_FORMAT_NUMBER       in VARCHAR2
                             ,P_ESTAB_WORK_ACCIDENT_ORDER_NO in VARCHAR2
                                ) return varchar2;

------------------------------------------------------------------------
-- Function GET_ASSEDIC_BASE_CODE
-- 115.15 added params p_business_group_id and p_date_earned.
------------------------------------------------------------------------

function get_assedic_base_code(p_assignment_id            in number
                             ,P_BUSINESS_GROUP_ID         in number
                             ,p_date_earned               in date
                              ,P_ESTAB_ASSEDIC_ORDER_NUMBER in varchar2
                             )  return varchar2;

------------------------------------------------------------------------
-- Function GET_PENSION_BASE_CODE
-- 115.15 added params p_business_group_id and p_date_earned.
------------------------------------------------------------------------
function get_pension_base_code(p_establishment_id  in number
                     ,p_assignment_id              in number
                     ,P_BUSINESS_GROUP_ID          in number
                     ,p_date_earned                in date
                     ,p_emp_pension_provider_id    in number
                     ,p_provider_type              in varchar2
	             ,p_emp_pension_category       in varchar2
   	             ) return varchar2;

------------------------------------------------------------------------
-- Function GET_CONTRIBUTION_BAND
-- 115.15 added params p_business_group_id
------------------------------------------------------------------------
function get_contribution_band(
                 p_business_group_id in number
		,p_band_type       in varchar2
   		,p_ytd_ss_ceiling  in number
   		,p_ytd_base        in number
		,p_ytd_band        in number
   		) return number;


------------------------------------------------------------------------
-- Function GET_GMP_BAND
------------------------------------------------------------------------
function get_gmp_band(p_ytd_gmp_ceiling in number,
                         p_ytd_gmp_band       in number,
                         p_ytd_p3_band        in number,
                         p_run_p3_band        in number) return number;


------------------------------------------------------------------------
-- Function GET_SALARY_TAX_BAND
-- 115.15 added params p_business_group_id
------------------------------------------------------------------------
function get_salary_tax_band(p_business_group_id    in number,
                                p_band_type         in varchar2,
                                p_ptd_base          in number,
                                p_ptd_band          in number) return number;


------------------------------------------------------------------------
-- Function WRITE_BASE_BAND
------------------------------------------------------------------------
function WRITE_BASE_BANDS(p_name in varchar2
                            ,p_value in number) return number;

------------------------------------------------------------------------
-- Function WRITE_CALENDAR_DAYS_WORKED
------------------------------------------------------------------------
function WRITE_CALENDAR_DAYS_WORKED(p_calendar_days_worked in number) return number;

------------------------------------------------------------------------
-- Function READ_CALENDAR_DAYS_WORKED
------------------------------------------------------------------------
function READ_CALENDAR_DAYS_WORKED return number;
------------------------------------------------------------------------
-- Function GET_DAYS_OVER_PENSION_LIMIT
------------------------------------------------------------------------
function get_days_over_pension_limit(p_assignment_id          in number
                                     ,p_business_group_id     in number
                                     ,p_pay_period_start_date in date
                                     ,p_pay_period_end_date   in date
                                     ,p_abs_days_limit        in number) return number;

------------------------------------------------------------------------
-- Function GET_CONTRIBUTION_INFO
-- 115.15 added params p_business_group_id and p_date_earned.
-- 115.27 p_contribution_code now IN OUT; value passed in used only if
--        contribution_code on the contribution usage is null (extra
--        validation is performed on the template code in this case)
--        Overloaded with no p_contribution_code param to cater for those
--        contributions with none (can't pass in null from formula)
------------------------------------------------------------------------
function get_contribution_info( p_assignment_id		 in number
				,p_business_group_id     in number
                                ,p_date_earned           in date
                                ,p_tax_unit_id           in number
                                ,p_element_name 	 IN varchar2
				,p_usage_type    	 IN varchar2
				,p_base 		 OUT NOCOPY number
				,p_rate 		 OUT NOCOPY number
				,p_contribution_code 	 IN OUT NOCOPY varchar2
				,p_contribution_usage_id OUT NOCOPY number
                                ,p_override_rate        in number default null) return number;

function get_contribution_info( p_assignment_id		 in number
				,p_business_group_id     in number
                                ,p_date_earned           in date
                                ,p_tax_unit_id           in number
                                ,p_element_name 	 IN varchar2
				,p_usage_type    	 IN varchar2
				,p_base 		 OUT NOCOPY number
				,p_rate 		 OUT NOCOPY number
				,p_contribution_usage_id OUT NOCOPY number
                                ,p_override_rate        in number default null) return number;

------------------------------------------------------------------------
-- Function GET_WORK_ACCIDENT_CONTRIBUTION
-- 115.15 added params p_assignment_id, p_business_group_id and p_date_earned.
------------------------------------------------------------------------
function GET_WORK_ACCIDENT_CONTRIBUTION(P_ASSIGNMENT_ID            in number
                                       ,P_BUSINESS_GROUP_ID        in number
                                       ,P_DATE_EARNED              in date
                                       ,P_TAX_UNIT_ID              in number
                                       ,P_ELEMENT_NAME             IN varchar2
                                       ,P_USAGE_TYPE               IN varchar2
                                       ,P_RISK_CODE                in Varchar2
                                       ,P_BASE                     out nocopy number
                                       ,P_RATE                     out nocopy number
                                       ,P_RATE_TYPE                out nocopy varchar2
                                       ,P_CONTRIBUTION_CODE        out nocopy varchar2
                                       ,P_CONTRIBUTION_USAGE_ID    out nocopy number
                                       ,P_REDUCTION_PERCENT        in number default null) return number;

------------------------------------------------------------------------
-- Function GET_TRANSPORT_TAX_CONTRIBUTION
-- 115.15 added params p_business_group_id and p_date_earned.
------------------------------------------------------------------------
function GET_TRANSPORT_TAX_CONTRIBUTION(P_ASSIGNMENT_ID        in number
				       ,P_BUSINESS_GROUP_ID    in number
                                       ,p_date_earned          in date
                                       ,P_TAX_UNIT_ID          in number
                                       ,P_ELEMENT_NAME         in varchar2
                                       ,P_USAGE_TYPE           IN varchar2
                                       ,P_TRANSPORT_TAX_REGION in varchar2
                                       ,P_REDUCTION            in number
                                       ,P_BASE                 out nocopy number
                                       ,P_RATE                 out nocopy number
                                       ,P_CONTRIBUTION_CODE     out nocopy varchar2
                                       ,P_CONTRIBUTION_USAGE_ID out nocopy number) return number;

------------------------------------------------------------------------
-- Generic Function GET_FIXED_VALUE_CONTRIBUTION (replaces get_annual_apec_contribution)
------------------------------------------------------------------------
function get_fixed_value_contribution(P_BUSINESS_GROUP_ID    in number
                                ,p_date_earned           in date
                                ,p_element_name          IN varchar2
                                ,p_usage_type    	 IN varchar2
				,p_contribution_code 	 OUT NOCOPY varchar2
				,p_contribution_usage_id OUT NOCOPY number) return number;

------------------------------------------------------------------------
-- Function GET_REDUCED_CONTRIBUTION
-- 115.15 added params p_business_group_id and p_date_earned.
-- 115.27 p_contribution_code now IN OUT; value passed in used only if
--        contribution_code on the contribution usage is null (extra
--        validation is performed on the template code in this case)
--        Overloaded with no p_contribution_code param to cater for those
--        contributions with none (can't pass in null from formula)
------------------------------------------------------------------------
function get_reduced_contribution(P_BUSINESS_GROUP_ID    in number
                                ,p_date_earned          in date
                                ,P_ELEMENT_NAME IN varchar2
				,P_USAGE_TYPE IN varchar2
                                ,p_reduction  in number
                                ,P_BASE out nocopy number
                                ,P_RATE out nocopy number
                                ,P_CONTRIBUTION_CODE in out nocopy varchar2
                                ,P_CONTRIBUTION_USAGE_ID out nocopy number)
return number;

function get_reduced_contribution(P_BUSINESS_GROUP_ID    in number
                                ,p_date_earned          in date
                                ,P_ELEMENT_NAME IN varchar2
				,P_USAGE_TYPE IN varchar2
                                ,p_reduction  in number
                                ,P_BASE out nocopy number
                                ,P_RATE out nocopy number
                                ,P_CONTRIBUTION_USAGE_ID out nocopy number)
return number;

------------------------------------------------------------------------
-- Function CONVERT_HOURS
------------------------------------------------------------------------
function convert_hours(p_effective_date        in date
                      ,p_business_group_id     in number
                      ,p_assignment_id          in number
                      ,p_hours          	in number
                      ,p_from_freq_code 	in varchar2
                      ,p_to_freq_code   	in varchar2) return number;

------------------------------------------------------------------------
-- Function GET_PAY_RATE
------------------------------------------------------------------------
function get_pay_rate(p_assignment_id in number
                     ,p_business_group_id in number
                     ,p_effective_date in date
                     ,p_formula varchar2 default 'FR_USER_HOURLY_RATE'
                     ,p_parameter_list varchar2 default null) return number;

------------------------------------------------------------------------
-- Function GET_MONTHLY_HOURS
------------------------------------------------------------------------
function get_monthly_hours return number;

------------------------------------------------------------------------
-- Function GET_PREV_START_END
------------------------------------------------------------------------
function get_prev_start_end (p_payroll_action_id in     number
                            ,p_start_date        in out nocopy date
                            ,p_end_date          in out nocopy date) return number;

------------------------------------------------------------------------
-- Function SUBSTITUTE_CODE
------------------------------------------------------------------------
function substitute_code(p_contribution_code in varchar2) return varchar2;

------------------------------------------------------------------------
-- Function FORMAT_NAME
------------------------------------------------------------------------
Function format_name(p_employee_id in number) RETURN VARCHAR2;

-----------------------------------------------------------------------
-- Function FR_ROLLING_BALANCE
----------------------------------------------------------------------
Function fr_rolling_balance (p_assignment_id in number,
    		             p_balance_name in varchar2,
    		             p_balance_start_date in date,
    		             p_balance_end_date in date) return number;
-----------------------------------------------------------------------
-- Function GET_BASE_NAME
----------------------------------------------------------------------
function get_base_name (
                            p_business_group_id in number
                           ,p_group_code in varchar2)
         return varchar2;
-----------------------------------------------------------------------
-- Function GET_BASE_NAME_CU
----------------------------------------------------------------------
function get_base_name_CU (
                            p_business_group_id in number
                           ,p_cu_id             in number)
         return varchar2;
-----------------------------------------------------------------------
-- Function GET_GROUP_CODE
----------------------------------------------------------------------
function get_group_code(
                            p_cu_id             in number)
         return varchar2;
-----------------------------------------------------------------------
-- Function GET_SUMMARY_DEDUCTION
----------------------------------------------------------------------
FUNCTION get_summary_deduction
  (
     p_rate                     OUT NOCOPY NUMBER
   , p_base                     OUT NOCOPY NUMBER
   , p_contribution_code        OUT NOCOPY VARCHAR2
   , p_contribution_usage_id    OUT NOCOPY NUMBER
   , p_pay_value                OUT NOCOPY NUMBER
  )  return varchar2;

-----------------------------------------------------------------------
-- Function MAINTAIN_SUMMARY_DEDUCTION
----------------------------------------------------------------------
PROCEDURE maintain_summary_deduction
  (
     p_rate                     IN NUMBER
   , p_base_type                IN VARCHAR2
   , p_base                     IN NUMBER
   , p_contribution_code        IN VARCHAR2
   , p_contribution_usage_id    IN NUMBER
   , p_rate_type                IN VARCHAR2
   , p_pay_value                IN NUMBER
   , p_rate_category            IN VARCHAR2
   , p_user_column_instance_id  IN NUMBER
   , p_code_rate_id             IN NUMBER
   , p_element_name             IN VARCHAR2
  ) ;

-----------------------------------------------------------------------
-- Function MAINTAIN_RATE_CACHE
----------------------------------------------------------------------
PROCEDURE maintain_rate_cache
  (
     p_contribution_usage_id    IN NUMBER
   , p_tax_unit_id              IN NUMBER
   , p_contribution_code        IN VARCHAR2
   , p_rate_value               IN NUMBER
   , p_user_column_instance_id  IN NUMBER
   , p_risk_code                IN VARCHAR2
  );

-----------------------------------------------------------------------
-- Function GET_CACHED_RATE
----------------------------------------------------------------------
FUNCTION GET_CACHED_RATE
  (
     p_assignment_id            IN NUMBER
   , p_contribution_usage_id    IN NUMBER
   , p_tax_unit_id              IN NUMBER
   , p_contribution_code        IN OUT nocopy VARCHAR2
   , p_user_column_instance_id  IN OUT nocopy NUMBER
   , p_risk_code                IN OUT nocopy VARCHAR2
  ) return number;

-----------------------------------------------------------------------
-- Function GET_TABLE_RATE
----------------------------------------------------------------------
Function get_table_rate (p_bus_group_id in number,
                         p_table_name in varchar2,
                         p_row_value in varchar2,
                         p_user_row_id             out NOCOPY number,
                         p_user_column_instance_id out NOCOPY number )
                         return number;

-----------------------------------------------------------------------
-- Function CHECK_SUMMARY_DEDUCTION_CLEAR
----------------------------------------------------------------------
FUNCTION count_summary_deductions return number;
-----------------------------------------------------------------------
END PAY_FR_GENERAL;

 

/
