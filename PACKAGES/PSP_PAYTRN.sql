--------------------------------------------------------
--  DDL for Package PSP_PAYTRN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSP_PAYTRN" AUTHID CURRENT_USER AS
/* $Header: PSPPIPLS.pls 120.3.12010000.1 2008/07/28 08:09:26 appldev ship $ */
--
--
--
TYPE work_calendar_tab IS TABLE OF CHAR(1)
     INDEX BY BINARY_INTEGER;

TYPE daily_calendar_tab IS TABLE OF NUMBER
     INDEX BY BINARY_INTEGER;	-- Corrected the dataype to NUMBER from NUMBER(22, 4) for bug fix 2916848

work_calendar 			work_calendar_tab;
daily_calendar 			daily_calendar_tab;
g_start_date			date;
g_end_date			date;
g_no_of_days			number(9);
g_no_of_work_days		number(9);
g_no_of_person_work_days	number(9);

--Bug 1994421 - Zero Work Days Build : Added new variables -lveerubh
g_non_active_flag		VARCHAR2(1);
g_hire_zero_work_days		VARCHAR2(1);
g_all_holiday_zero_work_days	VARCHAR2(1);


PROCEDURE import_paytrans ( errbuf out NOCOPY varchar2,
			    retcode out NOCOPY varchar2,
			    p_period_type in varchar2,
			    p_time_period_id in number,
			p_business_group_id	IN	NUMBER,		-- Introduced for bug fix 3098050
			p_set_of_books_id	IN	NUMBER);	-- Introduced for bug fix 3098050

PROCEDURE create_working_calendar(p_assignment_id	IN	NUMBER);

PROCEDURE update_wcal_asg_end_date(x_assignment_id in number,
				   x_return_status out NOCOPY varchar2);

--The following procedure added by PVELAMUR 02/07/199

PROCEDURE update_wcal_asg_begin_date(x_assignment_id in number,
                                   x_return_status out NOCOPY varchar2);
PROCEDURE update_wcal_asg_status(x_assignment_id in number,
                                 x_return_status out NOCOPY varchar2);

PROCEDURE create_daily_rate_calendar(x_assignment_id     in number,
				     x_time_period_id    in number,
				     x_element_type_id   in number,
                                     x_return_status out NOCOPY varchar2);

PROCEDURE CALCULATE_BALANCE_AMOUNT(x_pay_amount in number,
			           x_balance_amount out NOCOPY number,
                                   x_return_status OUT NOCOPY VARCHAR2);

/*Bug 5642002: Added parameters x_start_date and x_end_date */
PROCEDURE CREATE_SLINE_SALARY_CHANGE (x_payroll_line_id IN NUMBER,
				      x_start_date      IN DATE,
				      x_end_date        IN DATE,
                                      x_return_status OUT NOCOPY VARCHAR2);


PROCEDURE CREATE_SLINE_ASG_CHANGE (x_payroll_line_id IN NUMBER,
				   x_assignment_id   IN NUMBER,
                                   x_return_status OUT NOCOPY VARCHAR2);

PROCEDURE CREATE_SLINE_ASG_STATUS_CHANGE (x_payroll_line_id IN NUMBER,
				   x_assignment_id   IN NUMBER,
				   x_balance_amount  IN NUMBER,
                                   x_return_status OUT NOCOPY VARCHAR2);

PROCEDURE CREATE_SLINE_EMP_END_DATE (x_payroll_line_id IN NUMBER,
				     x_person_id       IN NUMBER,
                                     x_return_status OUT NOCOPY VARCHAR2);


PROCEDURE  CREATE_SLINE_ORG_CHANGE(x_payroll_line_id IN NUMBER,
				   x_assignment_id   IN NUMBER,
				   X_BALANCE_AMOUNT  IN NUMBER,
                                   x_return_status OUT NOCOPY VARCHAR2);

PROCEDURE  CREATE_SLINE_JOB_CHANGE(x_payroll_line_id IN NUMBER,
				   X_ASSIGNMENT_ID   IN NUMBER,
				   X_BALANCE_AMOUNT  IN NUMBER,
                                   x_return_status OUT NOCOPY VARCHAR2);

PROCEDURE  CREATE_SLINE_POSITION_CHANGE(x_payroll_line_id IN NUMBER,
				   X_ASSIGNMENT_ID   IN NUMBER,
				   X_BALANCE_AMOUNT  IN NUMBER,
                                   x_return_status OUT NOCOPY VARCHAR2);

PROCEDURE  CREATE_SLINE_GRADE_CHANGE(x_payroll_line_id IN NUMBER,
				   X_ASSIGNMENT_ID   IN NUMBER,
				   X_BALANCE_AMOUNT  IN NUMBER,
                                   x_return_status OUT NOCOPY VARCHAR2);

PROCEDURE  CREATE_SLINE_PPGROUP_CHANGE(x_payroll_line_id IN NUMBER,
				   X_ASSIGNMENT_ID   IN NUMBER,
				   X_BALANCE_AMOUNT  IN NUMBER,
                                   x_return_status OUT NOCOPY VARCHAR2);

PROCEDURE  CREATE_SLINE_FTE_CHANGE(x_payroll_line_id IN NUMBER,
				   X_ASSIGNMENT_ID   IN NUMBER,
				   X_BALANCE_AMOUNT  IN NUMBER,
                                   x_return_status OUT NOCOPY VARCHAR2);

PROCEDURE  CREATE_SLINE_BUDGET_CHANGE(x_payroll_line_id IN NUMBER,
				   X_ASSIGNMENT_ID   IN NUMBER,
				   X_BALANCE_AMOUNT  IN NUMBER,
                                   x_return_status OUT NOCOPY VARCHAR2);
--

PROCEDURE CHECK_ZERO_WORK_DAYS(x_assignment_id IN NUMBER,
				x_costed_value IN NUMBER,
				x_start_date   IN DATE,		-- Bug 5642002: Added parameter
				x_end_date     IN DATE,		-- Bug 5642002: Added parameter
				x_return_status OUT NOCOPY varchar2);

--Bug 1994421 - Zero Work Days Build : Added the new procedure  :lveerubh
PROCEDURE  CREATE_SLINE_TERM_EMP(	x_payroll_line_id	IN 	NUMBER,
					x_reason	  	IN 	VARCHAR2,
	                                x_return_status		OUT NOCOPY 	VARCHAR2);


--	Introduced the following for bug fix 2916848
PROCEDURE create_prorate_calendar
		(
               p_start_date            IN DATE,
               p_end_date   IN DATE,
		p_pay_amount		IN	NUMBER,
                p_payroll_line_id       IN NUMBER,
		p_balance_amount	OUT NOCOPY NUMBER,
		p_return_status		OUT NOCOPY VARCHAR2);
--	End of bug fix 2916848

END PSP_PAYTRN;

/
