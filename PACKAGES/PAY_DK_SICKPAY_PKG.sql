--------------------------------------------------------
--  DDL for Package PAY_DK_SICKPAY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_DK_SICKPAY_PKG" AUTHID CURRENT_USER AS
/* $Header: pydksckp.pkh 120.0 2006/03/23 04:02:46 knelli noship $ */

TYPE l_type IS TABLE OF varchar2(50) INDEX BY binary_integer;
l_rec l_type;

FUNCTION get_worked_hours(p_assignment_id      IN number
			  ,p_period_start_date IN date
			  ,p_period_end_date   IN date)RETURN number;

/*Bug 5047360 fix- Passing p_abs_start_time and p_abs_end_time*/
FUNCTION get_sickness_dur_details
	 (p_assignment_id               IN      NUMBER
	 ,p_effective_date              IN      DATE
	 ,p_abs_start_date              IN      DATE
	 ,p_abs_end_date                IN      DATE
	 ,p_abs_start_time              IN      VARCHAR2 --Bug 5047360 fix
	 ,p_abs_end_time                IN      VARCHAR2 --Bug 5047360 fix
	 ,p_start_date                  OUT NOCOPY DATE
	 ,p_end_date                    OUT NOCOPY DATE
	 ,p_sick_days                   OUT NOCOPY NUMBER
	 ,p_sick_hours                  OUT NOCOPY NUMBER
	 ) RETURN NUMBER;

FUNCTION get_le_sickpay_details
	(p_effective_date IN DATE,
	 p_org_id         IN NUMBER,
	 p_section27      OUT NOCOPY VARCHAR2
	 ) RETURN NUMBER;

/*Bug 5020916 fix - Fucntion to get the section 28 value based on the payroll processing start date*/
FUNCTION get_section28_details
     (p_assignment_id  IN NUMBER
     ,p_effective_date IN DATE --payroll processing start date
     ) RETURN VARCHAR2;

/* Bug fix 5045710, added function get_worked_days */
FUNCTION get_worked_days(p_assignment_id     IN number
			,p_period_start_date IN date
			,p_period_end_date   IN date)RETURN number;

/*  Bug fix 5045710, added function get_74hours_flag */
FUNCTION get_worked_hours_flag(p_assignment_id      IN number
			      ,p_worked_days_limit  IN number
			      ,p_worked_hours_limit IN number
			      ,p_period_end_date    IN date) RETURN varchar2;

END pay_dk_sickpay_pkg;


 

/
