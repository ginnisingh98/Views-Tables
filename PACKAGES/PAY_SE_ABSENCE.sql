--------------------------------------------------------
--  DDL for Package PAY_SE_ABSENCE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_SE_ABSENCE" AUTHID CURRENT_USER AS
/* $Header: pysesick.pkh 120.2 2007/08/03 16:02:08 rravi noship $ */

FUNCTION GET_HOURLY_RATE(
   p_assignment_id			 IN         NUMBER
  ,p_effective_date			 IN         DATE
  ,p_abs_start_date			 IN         DATE
  ,p_abs_end_date			 IN         DATE
  ,p_Monthly_Pay			 IN         NUMBER
  ,p_hourly_rate_option1		 OUT	    NOCOPY VARCHAR
  ,p_hourly_rate_option2		 OUT	    NOCOPY VARCHAR
  ,p_hourly_rate_option3		 OUT	    NOCOPY VARCHAR
  ,p_hourly_rate_option4		 OUT	    NOCOPY VARCHAR
  ,p_hourly_rate_option5		 OUT	    NOCOPY VARCHAR
  ,p_hourly_rate_option6		 OUT	    NOCOPY VARCHAR
  ,p_hourly_rate_option7		 OUT	    NOCOPY VARCHAR
  ,p_hourly_rate_option8		 OUT	    NOCOPY VARCHAR
  ,p_hourly_rate_option9		 OUT	    NOCOPY VARCHAR
  ,p_hourly_rate_option10		 OUT	    NOCOPY VARCHAR
  ,p_hourly_rate			 OUT        NOCOPY NUMBER
  ,p_normal_hours			 OUT        NOCOPY NUMBER
  ,p_working_perc			 OUT        NOCOPY NUMBER
  ,p_salary_rate_option1		 OUT	    NOCOPY VARCHAR
  ,p_salary_rate_option2		 OUT	    NOCOPY VARCHAR
  ,p_salary_rate_option3		 OUT	    NOCOPY VARCHAR
  ,p_salary_rate_option4		 OUT	    NOCOPY VARCHAR
  ,p_salary_rate_option5		 OUT	    NOCOPY VARCHAR
  ,p_salary_rate_option6		 OUT	    NOCOPY VARCHAR
  ,p_salary_rate_option7		 OUT	    NOCOPY VARCHAR
  ,p_salary_rate_option8		 OUT	    NOCOPY VARCHAR
  ,p_salary_rate_option9		 OUT	    NOCOPY VARCHAR
  ,p_salary_rate_option10		 OUT	    NOCOPY VARCHAR
  ,p_salary_rate			 OUT	    NOCOPY NUMBER
  ,p_hour_sal				 OUT        NOCOPY VARCHAR
  )
  RETURN NUMBER;

FUNCTION GET_GROUP(
   p_assignment_id               IN         NUMBER
  ,p_effective_date              IN         DATE
  ,p_abs_start_date              IN         DATE
  ,p_abs_end_date                IN         DATE
  ,p_group_start_date1		 OUT	    NOCOPY DATE
  ,p_group_start_date2		 OUT	    NOCOPY DATE
  ,p_group_start_date3		 OUT	    NOCOPY DATE
  ,p_group_start_date4		 OUT	    NOCOPY DATE
  ,p_group_start_date5		 OUT	    NOCOPY DATE
  ,p_group_start_date6		 OUT	    NOCOPY DATE
  ,p_group_start_date7		 OUT	    NOCOPY DATE
  ,p_group_start_date8		 OUT	    NOCOPY DATE
  ,p_group_start_date9		 OUT	    NOCOPY DATE
  ,p_group_start_date10		 OUT	    NOCOPY DATE
  ,p_group_start_date11		 OUT	    NOCOPY DATE
  ,p_group_end_date1		 OUT	    NOCOPY DATE
  ,p_group_end_date2		 OUT	    NOCOPY DATE
  ,p_group_end_date3		 OUT	    NOCOPY DATE
  ,p_group_end_date4		 OUT	    NOCOPY DATE
  ,p_group_end_date5		 OUT	    NOCOPY DATE
  ,p_group_end_date6		 OUT	    NOCOPY DATE
  ,p_group_end_date7		 OUT	    NOCOPY DATE
  ,p_group_end_date8		 OUT	    NOCOPY DATE
  ,p_group_end_date9		 OUT	    NOCOPY DATE
  ,p_group_end_date10		 OUT	    NOCOPY DATE
  ,p_group_end_date11		 OUT	    NOCOPY DATE
  ,p_group_option1		 OUT	    NOCOPY VARCHAR2
  ,p_group_option2		 OUT	    NOCOPY VARCHAR2
  ,p_group_option3		 OUT	    NOCOPY VARCHAR2
  ,p_group_option4		 OUT	    NOCOPY VARCHAR2
  ,p_group_option5		 OUT	    NOCOPY VARCHAR2
  ,p_group_option6		 OUT	    NOCOPY VARCHAR2
  ,p_group_option7		 OUT	    NOCOPY VARCHAR2
  ,p_group_option8		 OUT	    NOCOPY VARCHAR2
  ,p_group_option9		 OUT	    NOCOPY VARCHAR2
  ,p_group_option10		 OUT	    NOCOPY VARCHAR2
  ,p_group_option11		 OUT	    NOCOPY VARCHAR2
  ,p_asg_hour_sal		 OUT        NOCOPY VARCHAR2
  )
RETURN NUMBER;

FUNCTION CALCULATE_PAYMENT(
   p_assignment_id               IN         NUMBER
  ,p_effective_date              IN         DATE
  ,p_assignment_action_id	 IN	    NUMBER
  ,p_pay_start_date		 IN	    DATE
  ,p_pay_end_date		 IN	    DATE
  ,p_abs_start_date              IN         DATE
  ,p_abs_end_date                IN         DATE
  ,p_monthly_pay		 IN	    NUMBER
  ,p_hourly_rate		 IN OUT     NOCOPY NUMBER
  ,p_tot_waiting_day_hours	 OUT        NOCOPY NUMBER
  ,p_tot_waiting_day		 OUT	    NOCOPY NUMBER
  ,p_total_sickness_deduction    OUT	    NOCOPY NUMBER
  ,p_tot_sickness_ded_14_above   OUT	    NOCOPY NUMBER
  ,p_total_sick_pay		 OUT	    NOCOPY NUMBER
  ,p_total_sick_pay_14_above     OUT	    NOCOPY NUMBER
  ,p_tot_waiting_day_ded	 OUT	    NOCOPY NUMBER
  ,p_sickness_14_below_days      OUT	    NOCOPY NUMBER
  ,p_sickness_above_14_days      OUT	    NOCOPY NUMBER
  ,p_sickness_pay_hours_14_below OUT        NOCOPY NUMBER
  ,p_sickness_pay_hours_above_14 OUT        NOCOPY  NUMBER
  ,p_sex			 OUT	    NOCOPY VARCHAR2
  ,p_tot_sick_pay_days		 OUT	    NOCOPY NUMBER
  ,p_asg_hour_sal		 OUT	    NOCOPY VARCHAR2
  ,p_waiting_date		 OUT	    NOCOPY DATE
  ,p_salary_rate		 IN OUT	    NOCOPY   NUMBER
  ,p_fourteenth_date		 OUT	    NOCOPY DATE
  ,p_full_days			 OUT	    NOCOPY NUMBER
  ,p_override_monthly_basic	 OUT	    NOCOPY NUMBER
  ,p_override_monthly_basic_day  OUT	    NOCOPY NUMBER
  ,p_exceeds_14_days		 OUT	    NOCOPY VARCHAR2
  ,p_sickness_after_14_days_month	 OUT	    NOCOPY NUMBER
  ,p_group_calendar_days          OUT       NOCOPY NUMBER
  ,p_group_working_days           OUT       NOCOPY NUMBER
  ,p_group_working_hours          OUT       NOCOPY NUMBER

  )
RETURN NUMBER;

FUNCTION get_waiting_hours(
p_abs_hours IN VARCHAR2,
p_normal_hours IN VARCHAR2
)RETURN NUMBER;

FUNCTION GET_SICKPAY_DETAILS(
p_assignment_id			IN	NUMBER,
p_abs_start_date		IN	DATE,
p_abs_end_date			IN	DATE,
p_sickness_14_below_days	IN	NUMBER,
--p_sickness_above_14_days	IN	NUMBER,
p_sickness_after_14_days_month IN NUMBER,
p_sickness_pay_hours_14_below   IN	NUMBER,
p_sickness_pay_hours_above_14   IN	NUMBER,
p_monthly_pay			IN	NUMBER,
p_asg_hour_sal			IN	varchar2,
p_working_percentage		IN	NUMBER,
p_normal_hours			IN	NUMBER,
p_hourly_rate			IN	NUMBER,
p_waiting_day_hours		IN OUT  NOCOPY NUMBER,
p_waiting_day_deduction		OUT	NOCOPY NUMBER,
p_waiting_day			OUT	NOCOPY NUMBER,
p_sickness_deduction_14_above   OUT	NOCOPY NUMBER,
p_sickness_deduction_14_less    OUT	NOCOPY NUMBER,
p_sick_pay_14_above		OUT	NOCOPY NUMBER,
p_sick_pay_14_less		OUT	NOCOPY NUMBER,
p_salary_rate			IN	NUMBER,
p_effective_date		IN	DATE,
p_assignment_action_id		IN	NUMBER,
p_override_monthly_basic	OUT	NOCOPY NUMBER,
p_override_monthly_basic_day	OUT	NOCOPY NUMBER
)
RETURN NUMBER;

FUNCTION GET_WAITING_DAY(
p_assignment_id NUMBER,
p_abs_start_date DATE,
p_abs_end_date date
)
RETURN DATE;

FUNCTION Get_Entitlement_Days(
p_assignment_id in NUMBER,
p_effective_date IN DATE,
p_absence_start_date IN DATE,
p_absence_end_date IN DATE,
p_entitlement_days OUT NOCOPY NUMBER,
p_sickness_days OUT NOCOPY NUMBER
)
RETURN NUMBER;

FUNCTION GET_SICKNESS_AFTER_14_PERIOD(p_person_id IN NUMBER,
p_assignment_id IN NUMBER,
p_payroll_start IN DATE,
p_payroll_end IN DATE,
p_fourteenth_date IN DATE)
RETURN NUMBER;

FUNCTION Get_Sickness_Group_Details(p_person_id IN NUMBER,
					p_assignment_id IN NUMBER,
					p_pay_start_date IN DATE,
					p_pay_end_date IN DATE,
					p_abs_group_start_date IN DATE,
					p_abs_group_end_date IN DATE,
			                p_group_calendar_days OUT NOCOPY NUMBER,
					p_group_working_days OUT NOCOPY NUMBER,
					p_group_working_hours OUT NOCOPY NUMBER )
RETURN NUMBER;

END PAY_SE_ABSENCE;


/
