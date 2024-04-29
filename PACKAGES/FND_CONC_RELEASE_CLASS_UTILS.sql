--------------------------------------------------------
--  DDL for Package FND_CONC_RELEASE_CLASS_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_CONC_RELEASE_CLASS_UTILS" AUTHID CURRENT_USER as
/* $Header: AFCPCRCS.pls 115.6 2003/10/16 11:24:20 nkagrawa noship $ */


-- Name
--  calc_specific_startdate
-- Purpose
--  Given a requested start date and the class info for a Specific schedule,
--  return the next date that a request should run according to this schedule.
--  May return null if no valid date found.
--
function calc_specific_startdate(req_sdate  in date,
                                 class_info in varchar2) return date;


-- Name
--  parse_named_periodic_schedule
-- Purpose
--  Given an application name and a Periodic schedule name,
--  return the interval, interval unit, interval type, start_date and end date
--  for this schedule.
--  Values will be null if the schedule is not found or an error occurs.
--
procedure parse_named_periodic_schedule(p_application 	 in varchar2,
			                p_class_name 	 in varchar2,
                                        p_repeat_interval      out nocopy number,
                                        p_repeat_interval_unit out nocopy varchar2,
                                        p_repeat_interval_type out nocopy varchar2,
                                        p_start_date           out nocopy date,
                                        p_repeat_end           out nocopy date);


-- Name
--  parse_periodic_schedule
-- Purpose
--  Given an application id and a Periodic schedule id,
--  return the interval, interval unit, interval type, start_date and end date
--  for this schedule.
--  Values will be null if the schedule is not found or an error occurs.
--
procedure parse_periodic_schedule(p_rel_class_app_id in number,
                                  p_rel_class_id     in number,
                                  p_repeat_interval      out nocopy number,
                                  p_repeat_interval_unit out nocopy varchar2,
                                  p_repeat_interval_type out nocopy varchar2,
                                  p_start_date           out nocopy date,
                                  p_repeat_end           out nocopy date);


-- Name
--  assign_specific_sch
-- Purpose
--  this function assigns specific schedule to a request
--  return true if successful
--  May return false if unsuccessful
--
function assign_specific_sch (req_id in number,
                              class_info in varchar2,
                              start_date in date,
                              end_date in date) return boolean;


end FND_CONC_RELEASE_CLASS_UTILS;


 

/
