--------------------------------------------------------
--  DDL for Package PAY_FI_GENERAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_FI_GENERAL" AUTHID CURRENT_USER AS
/* $Header: pyfigenr.pkh 120.11.12010000.1 2008/07/27 22:36:52 appldev ship $ */

 --
 TYPE fi_cache_rec IS RECORD
( cache_code   VARCHAR2(30),
   cache_value VARCHAR2(240) );

TYPE fi_cache_table IS TABLE OF
fi_cache_rec
INDEX BY BINARY_INTEGER;
g_fi_cache_table fi_cache_table;

 FUNCTION get_accrual_status
 (p_time_definition_id 	IN 	NUMBER
 ,p_balance_date			IN      DATE
 ,p_payroll_start_date		IN      DATE
 ,p_payroll_end_date		IN      DATE
 ) RETURN NUMBER;

   FUNCTION get_holiday_pay_accr_override
 (p_assignment_id 		NUMBER
 , p_effective_date             DATE
 , p_holiday_days			OUT NOCOPY NUMBER
 , p_holiday_compensation	OUT NOCOPY NUMBER
 , p_holiday_pay_reserve 	OUT NOCOPY NUMBER
 , p_working_days 	        OUT NOCOPY NUMBER
 , p_working_hours 	        OUT NOCOPY NUMBER
 ) RETURN NUMBER ;

 FUNCTION get_holiday_pay_entitle_over
 (p_assignment_id 		NUMBER
 , p_effective_date             DATE
 , p_summer_holiday_days			OUT NOCOPY NUMBER
 , p_winter_holiday_days	OUT NOCOPY NUMBER
 , p_holiday_pay 	OUT NOCOPY NUMBER
 , p_holiday_compensation 	        OUT NOCOPY NUMBER
 , p_carryover_holiday_days   OUT NOCOPY NUMBER
 , p_carryover_holiday_pay   OUT NOCOPY NUMBER
 , p_carryover_holiday_compen   OUT NOCOPY NUMBER
, p_average_hourly_pay  OUT NOCOPY NUMBER
, p_average_daily_pay  OUT NOCOPY NUMBER
 ) RETURN NUMBER ;

   function run_holiday_pay_entitlement
   (p_assignment_id         IN NUMBER
   ,p_date_earned           IN DATE
   ,p_business_group_id     IN NUMBER
   ,p_payroll_id            IN NUMBER
   ,p_payroll_action_id     IN NUMBER
   ,p_assignment_action_id  IN NUMBER
   ,p_tax_unit_id           IN NUMBER
   ,p_element_entry_id      IN NUMBER
   ,p_element_type_id       IN NUMBER
   ,p_original_entry_id     IN NUMBER
   ,p_balance_date      IN DATE
   , p_summer_holiday_days			OUT NOCOPY NUMBER
 , p_winter_holiday_days	OUT NOCOPY NUMBER
 , p_holiday_pay 	OUT NOCOPY NUMBER
 , p_holiday_compensation 	        OUT NOCOPY NUMBER
 , p_carryover_holiday_days   OUT NOCOPY NUMBER
 , p_carryover_holiday_pay   OUT NOCOPY NUMBER
 , p_carryover_holiday_compen   OUT NOCOPY NUMBER

   )
  return NUMBER;

   function run_holiday_pay_formula
   (p_assignment_id         IN NUMBER
   ,p_date_earned           IN DATE
   ,p_business_group_id     IN NUMBER
   ,p_payroll_id            IN NUMBER
   ,p_payroll_action_id     IN NUMBER
   ,p_assignment_action_id  IN NUMBER
   ,p_tax_unit_id           IN NUMBER
   ,p_element_entry_id      IN NUMBER
   ,p_element_type_id       IN NUMBER
   ,p_original_entry_id     IN NUMBER
   ,p_balance_date      IN DATE
   ,p_holiday_days      OUT NOCOPY NUMBER
   ,p_holiday_compensation      OUT NOCOPY NUMBER
   ,p_holiday_pay_reserve      OUT NOCOPY NUMBER
   ,p_working_days      OUT NOCOPY NUMBER
   ,p_working_hours      OUT NOCOPY NUMBER
   )
  return NUMBER ;

  function element_exist(p_assignment_id in number ,p_date_earned in date,p_element_name in varchar2 ) return number ;
   FUNCTION calc_sch_based_dur (  p_assignment_id IN NUMBER,
  			       p_days_or_hours IN VARCHAR2,
--          			           p_include_event IN VARCHAR2 DEFAULT 'Y',
                               p_date_start    IN DATE,
                               p_date_end      IN DATE,
                               p_time_start    IN VARCHAR2,
                               p_time_end      IN VARCHAR2,
                               p_duration      IN OUT NOCOPY NUMBER
                             ) RETURN NUMBER ;


/*FUNCTION get_working_time
 (p_time_definition_id 	IN 	NUMBER
, p_assignment_id  in number
 ,p_payroll_start_date	IN      DATE
 ,p_payroll_end_date		IN      DATE
,p_working_days out number
,p_working_hours out number
 ) RETURN NUMBER;

 */
 FUNCTION get_input_value_in_varchar
 (p_assignment_id 	in	NUMBER
 ,p_effective_date    in   DATE
 ,p_element_name	in	varchar2
 ,p_input_value_name  in varchar2
 ,p_input_value    out nocopy varchar2
) RETURN NUMBER;
FUNCTION GET_BALANCE_DATE(p_BALANCE_DATE IN DATE)RETURN DATE ;

FUNCTION set_value_cache(p_cache_code in varchar2, p_cache_value in varchar2) RETURN NUMBER;
FUNCTION get_value_cache(p_cache_code in varchar2, p_cache_value out nocopy varchar2)RETURN NUMBER;
FUNCTION delete_cache_table_row(p_cache_code in varchar2)RETURN NUMBER;
FUNCTION clear_cache RETURN NUMBER;

FUNCTION PRINT1(P_LEVEL IN NUMBER,P_TEXT IN VARCHAR2,P_VALUE IN VARCHAR2) RETURN NUMBER;

function get_hourly_salaried_type(p_assignment_id in number,
p_date_earned in date
) return varchar2 ;


FUNCTION good_time_format ( p_time IN VARCHAR2 ) RETURN BOOLEAN;

 FUNCTION get_tax_card_details
 (p_assignment_id         IN      NUMBER
 ,p_effective_date        in      date
 ,p_julian_effective_date OUT NOCOPY NUMBER
 ,p_tax_card_type         OUT NOCOPY VARCHAR2
 ,p_base_rate             OUT NOCOPY NUMBER
 ,p_additional_rate       OUT NOCOPY NUMBER
 ,p_yearly_income_limit   OUT NOCOPY NUMBER
 ,p_previous_income       OUT NOCOPY NUMBER
 ,p_lower_income_Percentage OUT NOCOPY NUMBER ) RETURN NUMBER;
 --
 FUNCTION get_tax_days_override
 (p_assignment_id 		IN 	NUMBER
 ,p_effective_date              IN      DATE
 ,p_tax_days			OUT NOCOPY NUMBER
 ,p_ref_tax_days		OUT NOCOPY NUMBER
 ) RETURN NUMBER;
 --
function run_tax_days_formula
   (p_assignment_id         IN NUMBER
   ,p_date_earned           IN DATE
   ,p_business_group_id     IN NUMBER
   ,p_payroll_id            IN NUMBER
   ,p_payroll_action_id     IN NUMBER
   ,p_assignment_action_id  IN NUMBER
   ,p_tax_unit_id           IN NUMBER
   ,p_element_entry_id      IN NUMBER
   ,p_element_type_id       IN NUMBER
   ,p_original_entry_id     IN NUMBER
   )
  return NUMBER;
 --

 FUNCTION get_tax_details
 (p_assignment_id		IN NUMBER
 ,p_effective_date		IN DATE
 ) RETURN NUMBER;

 --
 FUNCTION get_tax_calendar_days
 ( p_business_group_id		IN NUMBER
  , p_tax_unit_id		IN NUMBER
 ) RETURN NUMBER ;

FUNCTION get_social_security_info
 ( p_business_group_id		IN NUMBER
  ,p_tax_unit_id		IN NUMBER
  ,p_social_security_category	OUT NOCOPY NUMBER
  ,p_social_security_exempt     OUT NOCOPY VARCHAR2
 ) RETURN NUMBER;

 FUNCTION get_accident_insurance_info
 ( p_business_group_id		IN NUMBER
  ,p_tax_unit_id		IN NUMBER
  ,p_effective_date		IN DATE
 ) RETURN NUMBER;

 FUNCTION get_accident_insurance_rate
 ( p_business_group_id		IN NUMBER
  ,p_tax_unit_id		IN NUMBER
  ,p_effective_date		IN DATE
  ,p_assignment_id		IN NUMBER
  ,p_rate_type			IN VARCHAR2
  ,p_accident_insurance_id	OUT NOCOPY NUMBER
  ,p_rate			OUT NOCOPY NUMBER
 ) RETURN NUMBER ;

 FUNCTION get_person_pension_info
 ( p_business_group_id		IN NUMBER
  ,p_tax_unit_id		IN NUMBER
  ,p_assignment_id		IN NUMBER
  ,p_effective_date		IN DATE
  ,p_pension_type		OUT NOCOPY VARCHAR2
  ,p_pension_group		OUT NOCOPY NUMBER
  ,p_pension_provider		OUT NOCOPY NUMBER
  ,p_pension_rate		OUT NOCOPY NUMBER
 ) RETURN NUMBER;

 FUNCTION get_retirement_date
 (p_assignment_id 		IN NUMBER
 , p_effective_date             IN DATE
 ) RETURN DATE;

 FUNCTION xml_parser
 (p_data		IN VARCHAR2
 ) RETURN VARCHAR2;

PROCEDURE INSERT_OR_UPDATE_PERSON_EIT
 (p_person_id 		IN NUMBER,
  p_new_PENSION_JOINING_DATE   IN VARCHAR2,
  p_old_PENSION_JOINING_DATE  in  VARCHAR2,
  p_new_PENSION_TYPES   IN VARCHAR2,
  p_old_PENSION_TYPES  in  VARCHAR2,
  p_new_PENSION_INS_NUM   IN VARCHAR2,
  p_old_PENSION_INS_NUM  in  VARCHAR2,
  p_new_PENSION_GROUP   IN VARCHAR2,
  p_old_PENSION_GROUP  in  VARCHAR2,
  p_new_LOCAL_UNIT   IN VARCHAR2,
  p_old_LOCAL_UNIT  in  VARCHAR2,
  p_Session_Date in VARCHAR2,
  p_dt_update_mode in varchar2,
  p_where IN VARCHAR2 default NULL

 );
 PROCEDURE INS_OR_UPD_PERSON_EIT_COLUMN
 ( p_person_id 		IN NUMBER
  ,p_new_value  in VARCHAR2
  ,p_Session_Date in VARCHAR2
  ,p_COLUMN_NAME  in  per_people_extra_info.PEI_INFORMATION3%TYPE
  ,p_dt_update_mode in varchar2
 );

 FUNCTION get_payroll_period_info
 (p_payroll_id               IN NUMBER
 ,p_payroll_start_date          IN      DATE
 ,p_payroll_end_date          IN      DATE
 ,p_S_hp_pcent                    OUT  NOCOPY NUMBER
 ,p_W_hp_pcent                    OUT  NOCOPY NUMBER
 ,p_S_hb_pcent                    OUT  NOCOPY NUMBER
 ,p_W_hb_pcent                    OUT  NOCOPY NUMBER
 ,p_hc_pcent                    OUT  NOCOPY NUMBER
 ) RETURN NUMBER;

END pay_fi_general;

/
