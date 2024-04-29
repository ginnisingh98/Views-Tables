--------------------------------------------------------
--  DDL for Package AP_WEB_DB_SCHLINE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_WEB_DB_SCHLINE_PKG" AUTHID CURRENT_USER AS
/* $Header: apwdbscs.pls 120.2.12010000.2 2009/12/18 12:45:05 meesubra ship $ */

TYPE ScheduleLinesCursor	IS REF CURSOR;

TYPE Schedule_Line_Rec IS RECORD (
        RANGE_HIGH			AP_POL_LINES.RANGE_HIGH%TYPE,
        RANGE_LOW			AP_POL_LINES.RANGE_LOW%TYPE,
        START_DATE			AP_POL_SCHEDULE_PERIODS.START_DATE%TYPE,
        END_DATE			AP_POL_SCHEDULE_PERIODS.END_DATE%TYPE,
        RATE				AP_POL_LINES.RATE%TYPE,
        RATE_PER_PASSENGER              AP_POL_SCHEDULE_PERIODS.RATE_PER_PASSENGER%TYPE);

TYPE Schedule_Line_Array IS TABLE OF Schedule_Line_Rec
        INDEX BY BINARY_INTEGER;


FUNCTION GetScheduleLinesCursor(
	p_policy_id		IN	NUMBER,
	p_vehicle_category_code	IN	VARCHAR2,
	p_vehicle_type		IN	VARCHAR2,
	p_fuel_type		IN	VARCHAR2,
	p_currency_code		IN	VARCHAR2,
	p_employee_id		IN	NUMBER,
	p_start_expense_date	IN	DATE,
	p_schedule_lines_cursor OUT NOCOPY ScheduleLinesCursor)
RETURN BOOLEAN;
-------------------------------------------------------------------------------
PROCEDURE getSchHeaderInfo(
	p_policy_id	   IN  ap_pol_headers.policy_id%TYPE,
	p_sh_distance_uom  OUT NOCOPY ap_pol_headers.distance_uom%TYPE,
	p_sh_currency_code OUT NOCOPY ap_pol_headers.currency_code%TYPE,
        p_sh_distance_thresholds_flag OUT NOCOPY ap_pol_headers.DISTANCE_THRESHOLDS_FLAG%TYPE);
--------------------------------------------------------------------------------

FUNCTION GetRoleId(
	p_policy_id		IN	NUMBER,
	p_employee_id		IN	NUMBER,
	p_start_expense_date	IN	DATE)
RETURN NUMBER;

END AP_WEB_DB_SCHLINE_PKG;

/
