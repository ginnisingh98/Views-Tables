--------------------------------------------------------
--  DDL for Package PAY_CALC_HOURS_WORKED
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_CALC_HOURS_WORKED" AUTHID CURRENT_USER as
/* $Header: paycalchrswork.pkh 120.0 2005/05/29 11:19 appldev noship $ */
/*
+======================================================================+
|                Copyright (c) 1994 Oracle Corporation                 |
|                   Redwood Shores, California, USA                    |
|                        All rights reserved.                          |
+======================================================================+

    Name        : PAY_CALC_HOURS_WORKED
    Filename	: paycalchrswork.pkh
    Change List
    -----------
    Date        Name          	Vers    Bug No	Description
    ----        ----          	----	------	-----------
    28-APR-2005 sodhingr        115.0   4338404 Package to deliver new
                                                functioanlity to calculate
                                                hours worked
*/
FUNCTION calculate_actual_hours_worked
          (assignment_action_id   IN number   --Context
           ,assignment_id         IN number   --Context
           ,business_group_id     IN number   --Context
           ,element_entry_id      IN number   --Context
           ,date_earned           IN date     --Context
           ,p_period_start_date   IN date
           ,p_period_end_date     IN date
           ,p_schedule_category   IN varchar2  -- 'WORK'/'PAGER'
           ,p_include_exceptions  IN varchar2
           ,p_busy_tentative_as   IN varchar2   -- 'BUSY'/FREE/NULL
           ,p_legislation_code    IN varchar2
           ,p_schedule_source     IN OUT nocopy varchar2 -- 'PER_ASG' for asg
           ,p_schedule            IN OUT nocopy varchar2 -- schedule
           ,p_return_status       OUT nocopy number
           ,p_return_message      OUT nocopy varchar2)
 RETURN NUMBER;

 FUNCTION standard_hours_worked(
				p_std_hrs	in NUMBER,
				p_range_start	in DATE,
				p_range_end	in DATE,
				p_std_freq	in VARCHAR2) RETURN NUMBER;

END pay_calc_hours_worked;


 

/
