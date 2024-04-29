--------------------------------------------------------
--  DDL for Package PAY_DK_HOLIDAY_PAY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_DK_HOLIDAY_PAY_PKG" AUTHID CURRENT_USER AS
/* $Header: pydkholp.pkh 120.3.12010000.3 2010/04/02 11:18:03 abraghun ship $ */

/* Bug Fix 4961994 , Added Record variable */
TYPE l_type IS RECORD (date1 date, date2 date, value varchar2(5));
TYPE l_rec IS VARRAY(20) OF l_type;

FUNCTION get_allowance_perc(p_payroll_id  NUMBER
                           ,p_date_earned DATE ) RETURN NUMBER;


FUNCTION get_prev_bal(p_assignment_id NUMBER
                    , p_balance_name  VARCHAR2
                    , p_balance_dim   VARCHAR2
                    , p_virtual_date  DATE) RETURN NUMBER ;

/* Bug Fix 4950983 Added parameter p_work_pattern to function get_le_holiday_details */
FUNCTION get_le_holiday_details
	(p_org_id IN NUMBER,
	 p_sal_accrual_rate     OUT NOCOPY NUMBER,
	 p_hourly_accrual_rate  OUT NOCOPY NUMBER,
	 p_use_holiday_card     OUT NOCOPY VARCHAR2,
	 p_work_pattern         OUT NOCOPY VARCHAR2,
	 p_hol_all_reduction   OUT NOCOPY VARCHAR2) RETURN NUMBER;

FUNCTION get_le_employment_details
	  (p_org_id                     IN         NUMBER
	  ,p_le_work_hours              OUT NOCOPY NUMBER
	  ,p_freq                       OUT NOCOPY VARCHAR2)RETURN NUMBER;

/* Bug Fix 4961994 , Added function get_eligible_days */
FUNCTION get_eligible_days(p_assignment_id     IN NUMBER
			  ,p_org_id            IN NUMBER
			  ,p_period_start_date IN DATE
			  ,p_period_end_date   IN DATE
			  ,p_5days             OUT NOCOPY NUMBER
			  ,p_6days             OUT NOCOPY NUMBER) RETURN NUMBER;

/* Bug Fix 4947637 , Added function get_weekdays */
FUNCTION get_weekdays(p_period_start_date IN DATE
		     ,p_period_end_date   IN DATE
		     ,p_work_pattern      IN VARCHAR) RETURN NUMBER;

/* Bug Fix 5185910, Added function get_day_of_week */
FUNCTION  get_day_of_week(p_date DATE) RETURN NUMBER;

/* Added for Public Holiday Pay */
FUNCTION get_pub_hol_pay_details(p_assignment_id IN NUMBER
                                    ,p_organization_id IN NUMBER
                                    ,p_effective_date IN DATE
                                    ,p_sh_payment_rate OUT NOCOPY NUMBER) RETURN NUMBER;

/*9495504 - To get number of maximum carry over days - abraghun*/
FUNCTION get_max_carryover_days(p_assignment_id IN NUMBER
                               ,p_organization_id IN NUMBER
                               ,p_effective_date IN DATE) RETURN NUMBER;


END PAY_DK_HOLIDAY_PAY_PKG;


/
