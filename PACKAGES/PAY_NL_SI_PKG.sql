--------------------------------------------------------
--  DDL for Package PAY_NL_SI_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_NL_SI_PKG" AUTHID CURRENT_USER AS
/* $Header: pynlsoci.pkh 120.7.12000000.2 2007/02/19 06:16:02 shmittal noship $ */
--
-- Returns the SI Status
-- are entered for a employee
FUNCTION get_si_status
	  ( p_assignment_id  in number,
	    p_date_earned    in date,
	    p_si_class       in    varchar2
	  ) return number;
FUNCTION is_ami
	  ( p_assignment_id  in number,
	    p_date_earned    in date
	   ) return number;
FUNCTION get_payroll_type
  (p_payroll_id      in   number
  ) return varchar2;

--
-- Determines the Number if Week Days(Monday to Friday )
-- between two dates
FUNCTION Get_Week_Days(	P_Start_Date Date,
	                P_End_Date Date) return NUMBER;

--
-- Determines the Maximum SI Days between two dates
--  based on the method of 5 days per week
FUNCTION Get_Max_SI_Days(P_Assignment_Id Number,
                         P_Start_Date Date,
	                 P_End_Date Date) return NUMBER;

--
-- Determines the Number of Unpaid absence Days that reduce
-- SI Days indicated by the segment on the Absence
FUNCTION Get_Non_SI_Days(P_Assignment_Id Number,
                         P_Start_Date Date,
	                 P_End_Date Date) return NUMBER;

--
-- Determines the Total Number of days a Work pattern has been
-- setup for regardless of the work pattern start date on
-- employee assignment or dates of payroll period.

FUNCTION Get_Total_Work_Pattern_days(P_Assignment_Id Number) return NUMBER;
--
-- Determines the Total Number of days markd as Working Days in a
-- work pattern regardless of the work pattern start date on
-- employee assignment or dates of payroll period.

FUNCTION Get_Working_Work_Pattern_days(P_Assignment_Id Number) return NUMBER;

FUNCTION get_part_time_perc (p_assignment_id IN NUMBER
            		    ,p_date_earned IN DATE
            		    ,p_business_group_id IN NUMBER
	                ,p_assignment_action_id IN NUMBER) RETURN NUMBER;

FUNCTION get_day_of_week(p_date date) return number;


-------------------------------------------------------------------------------
-- Function : get_standard_si_part_time_perc
-- To get the Standard SI Part time Percentage  using
-- Assignment Id,Date Earned, Business Group Id and Assignment action Id.
---------------------------------------------------------------------------------
FUNCTION get_standard_si_part_time_perc (p_assignment_id IN NUMBER
                                   ,p_date_earned IN DATE
                                   ,p_business_group_id IN NUMBER
                                   ,p_assignment_action_id IN NUMBER) RETURN number;
-------------------------------------------------------------------------------
-- Function : get_pseudo_si_part_time_perc
-- To get the Standard SI Part time Percentage using
-- Assignment Id,Date Earned, Business Group Id and Assignment action Id.
---------------------------------------------------------------------------------
FUNCTION get_pseudo_si_part_time_perc (p_assignment_id IN NUMBER
                                   ,p_date_earned IN DATE
                                   ,p_business_group_id IN NUMBER
                                   ,p_assignment_action_id IN NUMBER) RETURN number;
-------------------------------------------------------------------------------
-- Function : get_std_si_rep_part_time_perc
-- To get the Standard SI Part time Percentage for Reporting using
-- Assignment Id,Date Earned, Business Group Id and Assignment action Id.
---------------------------------------------------------------------------------
FUNCTION get_std_si_rep_part_time_perc (p_assignment_id IN NUMBER
                                   ,p_date_earned IN DATE
                                   ,p_business_group_id IN NUMBER
                                   ,p_assignment_action_id IN NUMBER) RETURN number;
-------------------------------------------------------------------------------
-- Function : get_pse_si_rep_part_time_perc
-- To get the Pseudo SI Part time Percentage for Reporting using
-- Assignment Id,Date Earned, Business Group Id and Assignment action Id.
---------------------------------------------------------------------------------
FUNCTION get_pse_si_rep_part_time_perc (p_assignment_id IN NUMBER
                                   ,p_date_earned IN DATE
                                   ,p_business_group_id IN NUMBER
                                   ,p_assignment_action_id IN NUMBER) RETURN number ;

-----------------------------------------------------------------------------------------------
-- Function : get_avg_part_time_percentage
-- To get the average Pseudo SI Part time Percentage
-- Assignment Id,Period Start Date,Period End Date
-----------------------------------------------------------------------------------------------
FUNCTION get_avg_part_time_percentage
	(	p_assignment_id		IN	per_all_assignments_f.assignment_id%type 	,
		p_period_start_date	IN	DATE	,
		p_period_end_date	IN	DATE
	)
	RETURN NUMBER;

-----------------------------------------------------------------------------------------------
-- Function : get_real_si_days
-- To get the override for Real SI Days
-- Assignment Id,Date Earned, Business Group Id and Assignment action Id.
-----------------------------------------------------------------------------------------------
FUNCTION get_real_si_days
	(       p_assignment_id 	IN 	NUMBER
	       ,p_date_earned 		IN	DATE
	       ,p_business_group_id 	IN 	NUMBER
	       ,p_assignment_action_id 	IN 	NUMBER
	       ,p_payroll_action_id 	IN 	NUMBER
	)
	 RETURN number ;


---------------------------------------------------------------------------------------
-- Function : get_asg_ind_work_hours
-- To get the total individual work hours
-- Assignment Id,Period Start Date,Period End Date
---------------------------------------------------------------------------------------
 FUNCTION get_asg_ind_work_hours
	(	p_assignment_id		IN	per_all_assignments_f.assignment_id%type ,
		p_period_start_date	IN	DATE	,
		p_period_end_date	IN	DATE
	)
	RETURN NUMBER ;

---------------------------------------------------------------------------------------
-- Function : get_period_si_days
-- To get the period si days
---------------------------------------------------------------------------------------
FUNCTION get_period_si_days( p_assignment_id 	NUMBER
			,p_payroll_id		NUMBER
			,p_effective_date       DATE
			,p_source_text          VARCHAR2
			,p_override_day_method 	VARCHAR2
			,p_override_day_value   VARCHAR2
			,p_avg_ws_si_days	NUMBER
			,p_override_si_days	NUMBER
 			,p_real_si_days		NUMBER
			,p_si_day_method	VARCHAR2
			,p_max_si_method	VARCHAR2
			,p_multi_asg_si_days	NUMBER
			,p_year_calc 		VARCHAR2
			,p_override_real_si_days NUMBER
			,p_override   OUT NOCOPY VARCHAR2
			,p_period_si_days_year_calc NUMBER
						    )
			 RETURN NUMBER;

---------------------------------------------------------------------------------------
-- Function : get_ret_real_si_days
-- To get return real si days
---------------------------------------------------------------------------------------
FUNCTION get_ret_real_si_days( p_assignment_id 		NUMBER
				,p_payroll_id			NUMBER
				,p_effective_date 		DATE
				,p_source_text			VARCHAR2
				,p_source_text2			VARCHAR2
				,p_real_si_days			NUMBER
				,p_override_real_si_days	NUMBER
				,p_max_si_method		VARCHAR2
				,p_real_si_sit_ytd		NUMBER
				,p_real_si_sit_ptd		NUMBER
				,p_ret_real_si_sit_ytd		NUMBER
				,p_real_si_per_pay_sitp_ptd	NUMBER
				 )
				 RETURN NUMBER ;

---------------------------------------------------------------------------------------
-- Function : get_thres_or_max_si
-- To calculate threshold and max si days
---------------------------------------------------------------------------------------
FUNCTION get_thres_or_max_si  ( 	 p_assignment_id 	NUMBER
					,p_payroll_id		NUMBER
					,p_effective_date	DATE
					,p_calc_code		NUMBER
					,p_part_time_perc	NUMBER
					,p_si_days		NUMBER
					,p_thre_max_si		NUMBER
				  )
				  RETURN NUMBER;


---------------------------------------------------------------------------------------
-- Function : get_si_proration_days
-- To return number of SI Days for proration
---------------------------------------------------------------------------------------

FUNCTION get_si_proration_days (p_assignment_id NUMBER
                               ,p_period_start_date DATE
                               ,p_period_end_date DATE
                               ,p_proration_start_date DATE
                               ,p_proration_end_date DATE
                               ,p_period_si_days NUMBER
                               )
                               RETURN NUMBER;

-----------------------------------------------------------------------------------------------
-- Function : get_override_si_days
-- To get the override for SI Days
-- Assignment Id,Date Earned, Business Group Id and Assignment action Id.
-----------------------------------------------------------------------------------------------
FUNCTION get_override_si_days
	(       p_assignment_id 	IN 	NUMBER
	       ,p_date_earned 		IN	DATE
	       ,p_business_group_id 	IN 	NUMBER
	       ,p_assignment_action_id 	IN 	NUMBER
	       ,p_payroll_action_id 	IN 	NUMBER
	)
	 RETURN number ;

-----------------------------------------------------------------------------------------------
-- Function : get_tax_proration_days
-- To get the number of days for tax proration by executing user formula
-- Assignment Id,Date Earned, Business Group Id and Assignment action Id.
-----------------------------------------------------------------------------------------------
Function get_tax_proration_days
	(       p_assignment_id 	IN 	NUMBER
	       ,p_date_earned 		IN	DATE
	       ,p_assignment_action_id 	IN 	NUMBER
	       ,p_payroll_action_id 	IN 	NUMBER
	       ,p_business_group_id 	IN 	NUMBER
	)
	 RETURN number ;

-----------------------------------------------------------------------------------------------
-- Function : get_tax_proration_flag
-- To return the flag to determine whether proration is required or not by executing user formula
-- Assignment Id,Date Earned, Business Group Id and Assignment action Id.
-----------------------------------------------------------------------------------------------
Function get_tax_proration_flag
	(       p_assignment_id 	IN 	NUMBER
	       ,p_date_earned 		IN	DATE
	       ,p_assignment_action_id 	IN 	NUMBER
	       ,p_payroll_action_id 	IN 	NUMBER
	       ,p_business_group_id 	IN 	NUMBER
	)
         RETURN varchar2 ;

---------------------------------------------------------------------------------------
-- Function : get_tax_proration_cal_days
-- To return number of Tax Days for proration based on calender days
---------------------------------------------------------------------------------------

FUNCTION get_tax_proration_cal_days
	(	p_assignment_id		IN	NUMBER
                ,p_period_start_date	IN	DATE
                ,p_period_end_date	IN	DATE
                ,p_proration_start_date IN	DATE
                ,p_proration_end_date	IN	DATE
        )
        RETURN NUMBER;

END pay_nl_si_pkg;

 

/
