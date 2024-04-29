--------------------------------------------------------
--  DDL for Package PAY_NO_ABSENCE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_NO_ABSENCE" AUTHID CURRENT_USER AS
/* $Header: pynoabsence.pkh 120.0.12000000.1 2007/05/22 05:53:22 rajesrin noship $ */
    -- Cursor to fetch global values
    CURSOR GLB_VALUE(GLB_NAME VARCHAR2, ABS_DATE DATE)
    IS
    SELECT TRIM(GLOBAL_VALUE)
    FROM  FF_GLOBALS_F GLB
    WHERE ABS_DATE BETWEEN GLB.EFFECTIVE_START_DATE AND GLB.EFFECTIVE_END_DATE
      AND GLB.GLOBAL_NAME = GLB_NAME
      AND GLB.LEGISLATION_CODE = 'NO';

Function CALCULATE_PAYMENT
 ( p_assignment_id               IN         NUMBER
  ,p_effective_date              IN         DATE
--  ,p_absence_category            IN         VARCHAR2
  ,p_abs_categorycode            IN         VARCHAR
  ,p_abs_start_date              IN         DATE
  ,p_abs_end_date                IN         DATE
  ,p_prorate_start               IN         DATE
  ,p_prorate_end                 IN         DATE
  ,p_abs_attendance_id           IN         NUMBER
-- Balance Variables
  ,p_sickabs_paybase             IN         NUMBER
  ,p_sickabs_totaldays           IN         NUMBER
-- Sickness Benefit variables
  ,p_abs_empr_days               OUT NOCOPY NUMBER
  ,p_abs_ss_days                 OUT NOCOPY NUMBER
  ,p_abs_total_days              OUT NOCOPY NUMBER
  ,p_abs_daily_rate              OUT NOCOPY NUMBER
  ,p_abs_sick_days               OUT NOCOPY NUMBER
-- Earnings adjustment values
  ,p_ear_value                   OUT NOCOPY NUMBER
  ,p_ear_startdt                 OUT NOCOPY DATE
  ,p_ear_enddt                   OUT NOCOPY DATE
-- Global values
  ,p_abs_link_period             IN         NUMBER
  ,p_abs_min_gap                 IN         NUMBER
  ,p_abs_month                   IN         NUMBER
  ,p_abs_annual_days             IN         NUMBER
  ,p_abs_work_days               IN         NUMBER
  ,p_abs_cal_days                IN         NUMBER
-- pay earned start and end date
  ,p_pay_start_date              IN         DATE
  ,p_pay_end_date                IN         DATE
-- To determine actual payroll period. Mainly for proration calculation.
  ,p_hourly_paid                 IN         Varchar2
-- Balance Variables
  ,p_4weeks_paybase              IN         NUMBER
  ,p_3years_paybase              IN         NUMBER
-- Reclaimable benefit output variables
  ,p_rec_empr_days               OUT NOCOPY NUMBER
  ,p_rec_ss_days                 OUT NOCOPY NUMBER
  ,p_rec_total_days              OUT NOCOPY NUMBER
  ,p_rec_daily_rate              OUT NOCOPY NUMBER
  ,p_ss_daily_rate               OUT NOCOPY NUMBER
-- User defined daily rate calculation logic option
  ,p_rate_option1                OUT NOCOPY VARCHAR
  ,p_rate_option2                OUT NOCOPY VARCHAR
  ,p_rate_option3                OUT NOCOPY VARCHAR
  ,p_rate_option4                OUT NOCOPY VARCHAR
  ,p_rate_option5                OUT NOCOPY VARCHAR
  ,p_rate_option6                OUT NOCOPY VARCHAR
  ,p_rate_option7                OUT NOCOPY VARCHAR
  ,p_rate_option8                OUT NOCOPY VARCHAR
  ,p_rate_option9                OUT NOCOPY VARCHAR
  ,p_rate_option10               OUT NOCOPY VARCHAR
--  ,p_abs_categorycode            OUT NOCOPY VARCHAR
  ,p_abs_error                   OUT NOCOPY VARCHAR
  ,p_adopt_bal_days              IN NUMBER
  ,p_parental_bal_days           IN NUMBER
  ,p_abs_child_emp_days_limit    IN NUMBER
  ,p_child_emp_days              IN NUMBER
  ,p_child_ss_days               IN NUMBER
  ,p_pts_percentage              OUT NOCOPY NUMBER
  ,p_abs_total_cal_days          OUT NOCOPY NUMBER
  ,p_sickbal_total_caldays       IN NUMBER
  ,p_abs_ear_adj_base            IN NUMBER
   ) RETURN NUMBER;

FUNCTION get_override_details
 (p_assignment_id               IN         NUMBER
 ,p_effective_date              IN         DATE
 ,p_abs_start_date              IN         DATE
 ,p_abs_end_date                IN         DATE
 ,p_abs_categorycode            IN         VARCHAR2
 ,p_start_date                  OUT NOCOPY DATE
 ,p_end_date                    OUT NOCOPY DATE
 ,p_over_empr_rate              OUT NOCOPY NUMBER
 ,p_over_ss_rate                OUT NOCOPY NUMBER
 ,p_over_reclaim_rate           OUT NOCOPY NUMBER
 ,p_over_empr_days              OUT NOCOPY NUMBER
 ,p_over_ss_days                OUT NOCOPY NUMBER ) RETURN NUMBER;

PROCEDURE GET_SICKPAY
 ( p_person_id                   IN         NUMBER
  ,p_assignment_id               IN         NUMBER
  ,p_effective_date              IN         DATE
  ,p_dateofjoin                  IN         DATE
   );


FUNCTION get_weekdays(p_period_start_date IN DATE
		     ,p_period_end_date   IN DATE
		     ,p_work_pattern      IN VARCHAR) RETURN NUMBER ;

FUNCTION get_sick_unpaid
 (p_assignment_id               IN      NUMBER
 ,p_effective_date              IN      DATE
 ,p_start_date                  OUT NOCOPY DATE
 ,p_end_date                    OUT NOCOPY DATE ) RETURN NUMBER;

FUNCTION GET_GRATE ( p_effective_date              IN         DATE
                     ,p_assignment_id              IN         NUMBER
                     ,p_business_group_id          IN         NUMBER) RETURN NUMBER;
FUNCTION GET_SOURCEID (p_source_id        IN         NUMBER) return number;

FUNCTION GET_26WEEK (p_assignment_action_id        IN         NUMBER) return date;

FUNCTION GET_USERTABLE (p_effective_date        IN         DATE
                        ,p_business_group_id    IN         NUMBER
                        ,p_usertable_name       IN         VARCHAR2
                        ,p_usertable_colname    IN         VARCHAR2
                        ,p_exact_text           IN         VARCHAR2 ) return number;

FUNCTION get_months_employed(p_person_id             IN         NUMBER
			    ,p_check_start_date      IN         DATE
			    ,p_check_end_date        IN         DATE   ) return number;

FUNCTION get_parental_ben_sd(p_assignment_action_id        IN         NUMBER
                            ,p_element_entry_id            IN         NUMBER) return date;

/* Added function get_day_of_week */
FUNCTION  get_day_of_week(p_date DATE) RETURN NUMBER;

/* Added function get_adoption_ben_sd */
FUNCTION get_adoption_ben_sd(p_assignment_action_id        IN         NUMBER
                            ,p_element_entry_id            IN         NUMBER) return date;

/*Added funtion get_initial_abs_sd*/
FUNCTION get_initial_abs_sd(p_org_entry_id IN NUMBER, p_elem_entry_id IN NUMBER) RETURN  DATE;

/* 5261223 Added function for get the Assignment termination date */
 FUNCTION get_assg_trem_date(p_business_group_id IN NUMBER,
                             p_asg_id IN NUMBER,
                             p_pay_proc_period_start_date IN DATE,
                             p_pay_proc_period_end_date IN DATE) RETURN DATE;

FUNCTION get_restrict_hol_to_6g(p_business_group_id in number ,
                                p_assignment_id in NUMBER,
				p_effective_date IN DATE ,
                                p_restrict_hol_to_6G OUT nocopy VARCHAR2) RETURN NUMBER;

FUNCTION get_holiday_days (p_abs_category in varchar2,
                           p_abs_attendance_id IN NUMBER,
			   p_hol_days OUT nocopy NUMBER ) RETURN NUMBER;

FUNCTION get_cms_contact_date(p_assignment_id IN NUMBER, p_abs_start_date IN DATE,
         p_cms_contact_start_date OUT nocopy DATE, p_cms_contact_end_date OUT nocopy DATE,
	 p_cms_contact_count OUT nocopy NUMBER) RETURN NUMBER ;

FUNCTION get_init_abs_st_date (p_abs_attendance_id IN NUMBER) RETURN DATE;

FUNCTION get_abs_st_date (p_abs_attendance_id IN NUMBER) RETURN DATE ;

END PAY_NO_ABSENCE;

 

/
