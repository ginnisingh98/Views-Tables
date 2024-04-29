--------------------------------------------------------
--  DDL for Package HR_CALENDAR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_CALENDAR_PKG" AUTHID CURRENT_USER as
/* $Header: hrcalapi.pkh 120.2.12010000.2 2008/11/07 11:00:49 pbalu noship $ */
--------------------------------------------------------------------------------
/*
+==============================================================================+
|                       Copyright (c) 1994 Oracle Corporation                  |
|                          Redwood Shores, California, USA                     |
|                               All rights reserved.                           |
+==============================================================================+
--
Name
	Calendars Business Process
Purpose
	To provide routines to give information about calendars
History
	05 sep 95       N Simpson       Created
	07 sep 95       N Simpson       Added function purpose_usage_id

Version Date	    BugNo     Author	Comment
-------+-----------+---------+---------+--------------------------------------
40.3    18-Jul_97   513292    RThirlby  Created another overload of procedure
                                        denormalise_calendar. Altered function
                                        total_availability to accept parameters
                                        for both bg and person pattern in the
                                        same (linked) absence.
40.4    01-JUL--98  655707    A.Myers   Altered function total_availability to
                                        accept another parameter which, if
                                        supplied, means it has been called by
                                        package ssp_ssp_pkg and it is used to
                                        dictate the amount of processing to do.
*/
--------------------------------------------------------------------------------
function end_date (row_number integer) return date;
pragma restrict_references (end_date, WNDS,WNPS);

function start_date (row_number integer) return date;
pragma restrict_references (start_date, WNDS,WNPS);

function availability_value (row_number integer) return varchar2;
pragma restrict_references (availability_value, WNDS, WNPS);

function schedule_level_value (row_number integer) return number;
pragma restrict_references (schedule_level_value, WNDS, WNPS);

function schedule_rowcount return number;
pragma restrict_references (schedule_rowcount, WNDS, WNPS);

-- Bug 513292 - new overloaded version of this procedure
-- Bug 655707 - parameter p_called_from_SSP added to control further processing.
--              This will have been set to true in SSP_SSP_PKG.
procedure denormalise_calendar (
	p_person_purpose_usage_id   number,
	p_person_primary_key_value  number,
	p_bg_purpose_usage_id       number,
	p_bg_primary_key_value      number,
	p_period_from               date,
	p_period_to                 date,
        p_called_from_SSP           boolean default false);

procedure denormalise_calendar (
	p_calendar_id               number,
	p_calendar_start_time       date,
	p_period_from               date,
	p_period_to                 date);

procedure denormalise_calendar (
	p_purpose_usage_id          number,
	p_primary_key_value         number,
	p_period_from               date,
	p_period_to                 date);
--
-- Bug 513292 - new parameters added so that both BG and Person patterns can
-- be returned for same (linked) absence.
-- Bug 701750 - new parameter p_processing_level used in SSP processing.
--
function total_availability (
	p_availability              varchar2,
	p_person_purpose_usage_id   number,
        p_person_primary_key_value  number,
 	p_bg_purpose_usage_id       number,
	p_bg_primary_key_value      number,
	p_period_from               date,
	p_period_to                 date,
        p_processing_level          number default 0) return number;

function availability (
	p_date_and_time		date,
        p_purpose_usage_id      number,
	p_primary_key_value     number) return varchar2;

function purpose_usage_id (
	p_entity_name		varchar2,
	p_pattern_purpose	varchar2) return number;
pragma restrict_references (purpose_usage_id, WNDS, WNPS);

end hr_calendar_pkg;

/
