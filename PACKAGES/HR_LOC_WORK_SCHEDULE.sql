--------------------------------------------------------
--  DDL for Package HR_LOC_WORK_SCHEDULE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_LOC_WORK_SCHEDULE" AUTHID CURRENT_USER AS
/* $Header: hrlocwks.pkh 120.0.12000000.1 2007/01/21 17:14:28 appldev ship $ */

-- Function to retrieve time duration between given 2 dates for given assignment
--
--parameter p_days_or_hours 'D' to calculate duration in days
--  			    'H' to calculate duration in hours
--parameter p_include_event 'Y' to consider calendar events
--			    'N' to not to consider calendar events
--


FUNCTION calc_sch_based_dur  ( p_assignment_id IN NUMBER,
    			           p_days_or_hours IN VARCHAR2,
			           p_include_event IN VARCHAR2,
                               p_date_start    IN DATE,
                               p_date_end      IN DATE,
                               p_time_start    IN VARCHAR2,
                               p_time_end      IN VARCHAR2,
                               p_duration      IN OUT NOCOPY NUMBER
                             ) RETURN NUMBER;

-- Function to check whether given parameter is in proper time format

FUNCTION good_time_format ( p_time IN VARCHAR2 ) RETURN BOOLEAN;

END hr_loc_work_schedule;


 

/
