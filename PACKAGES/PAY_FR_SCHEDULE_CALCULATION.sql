--------------------------------------------------------
--  DDL for Package PAY_FR_SCHEDULE_CALCULATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_FR_SCHEDULE_CALCULATION" AUTHID CURRENT_USER as
/* $Header: pyfrwktm.pkh 115.1 2002/05/27 09:45:19 pkm ship       $ */
--
procedure initialise(p_assignment_id number
                    ,p_effective_date date);
procedure derive_schedule(p_assignment_id number
                         ,p_date_start date
                         ,p_date_end date);
function holiday_days(p_assignment_id number
                         ,p_effective_date date
                         ,p_date_start date
                         ,p_date_end date
                         ) return number;
function protected_days(p_assignment_id number
                         ,p_effective_date date
                         ,p_date_start date
                         ,p_date_end date
                         ) return number;
function scheduled_working_days(p_assignment_id number
                         ,p_effective_date date
                         ,p_date_start date
                         ,p_date_end date
                         ) return number;
function scheduled_working_hours(p_assignment_id number
                         ,p_effective_date date
                         ,p_date_start date
                         ,p_date_end date
                         ) return number;
function get_last_working_day(p_assignment_id number
                         ,p_effective_date date
                         ,p_date date
                         ,p_limit_date date default null
                         ) return date;
function get_next_working_day(p_assignment_id number
                         ,p_effective_date date
                         ,p_date date
                         ,p_limit_date date default null
                         ) return date;
end pay_fr_schedule_calculation;

 

/
