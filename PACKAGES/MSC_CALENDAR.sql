--------------------------------------------------------
--  DDL for Package MSC_CALENDAR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_CALENDAR" AUTHID CURRENT_USER AS
/* $Header: MSCCALDS.pls 120.4 2008/01/04 11:01:56 sbnaik ship $ */

--------PROFILE OPTION VALUES ------------------------------------------
G_VAR_BKT_REFERENCE_CALENDAR VARCHAR2(14) := NVL(FND_PROFILE.Value('MSC_BKT_REFERENCE_CALENDAR'),'-23453');

FUNCTION NEXT_WORK_DAY(arg_org_id IN NUMBER,
		       arg_instance_id IN NUMBER,
		       arg_bucket IN NUMBER,
		       arg_date IN DATE) RETURN DATE;
FUNCTION PREV_WORK_DAY(arg_org_id IN NUMBER,
		       arg_instance_id IN NUMBER,
		       arg_bucket IN NUMBER,
		       arg_date IN DATE) RETURN DATE;
FUNCTION DATE_OFFSET(  arg_org_id IN NUMBER,
		       arg_instance_id IN NUMBER,
		       arg_bucket IN NUMBER,
		       arg_date IN DATE,
		       arg_offset IN NUMBER) RETURN DATE;
FUNCTION DAYS_BETWEEN( arg_org_id IN NUMBER,
		       arg_instance_id IN NUMBER,
		       arg_bucket IN NUMBER,
		       arg_date1 IN DATE,
		       arg_date2 IN DATE) RETURN NUMBER;
PROCEDURE SELECT_CALENDAR_DEFAULTS( arg_org_id IN NUMBER,
				    arg_instance_id IN NUMBER,
				    arg_calendar_code OUT NOCOPY VARCHAR2,
				    arg_exception_set_id OUT NOCOPY NUMBER);

FUNCTION PREV_DELIVERY_CALENDAR_DAY (arg_calendar_code IN VARCHAR2,
				     arg_instance_id IN NUMBER,
				     arg_exception_set_id IN NUMBER,
				     arg_date IN DATE,
				     arg_bucket IN NUMBER) RETURN DATE;

FUNCTION CALENDAR_NEXT_WORK_DAY(arg_instance_id IN NUMBER,
			arg_calendar_code IN VARCHAR2,
                       arg_bucket IN NUMBER,
                       arg_date IN DATE) RETURN DATE;

FUNCTION CALENDAR_DAYS_BETWEEN( arg_instance_id IN NUMBER,
		       arg_calendar_code IN VARCHAR2,
                       arg_bucket IN NUMBER,
                       arg_date1 IN DATE,
                       arg_date2 IN DATE) RETURN NUMBER;

TYPE_DAILY_BUCKET      CONSTANT NUMBER := 1;
TYPE_WEEKLY_BUCKET     CONSTANT NUMBER := 2;
TYPE_MONTHLY_BUCKET    CONSTANT NUMBER := 3;

/* Global Variables added for ship_rec_cal project */
SMC		CONSTANT INTEGER := 1;
SSC		CONSTANT INTEGER := 2;
ORC		CONSTANT INTEGER := 3;
OMC		CONSTANT INTEGER := 4;
OSC		CONSTANT INTEGER := 5;
CRC		CONSTANT INTEGER := 6;
VIC		CONSTANT INTEGER := 7;
FOC		CONSTANT VARCHAR2(3) := '@@@';
G_RETAIN_DATE	VARCHAR2(1)	:= NVL(FND_PROFILE.VALUE('MRP_RETAIN_DATES_WTIN_CAL_BOUNDARY'), 'N');

-- New functions added for ship_rec_cal project.
FUNCTION Get_Calendar_Code(
			p_instance_id		IN number,
			p_plan_id		IN number,
			p_inventory_item_id	IN number,
			p_partner_id		IN number,
			p_partner_site_id	IN number,
			p_partner_type		IN number,
			p_organization_id	IN number,
			p_ship_method_code	IN varchar2,
			p_calendar_type  	IN integer
			) RETURN VARCHAR2;

FUNCTION Get_Calendar_Code(
			p_instance_id		IN      number,
			p_plan_id		IN      number,
			p_inventory_item_id	IN      number,
			p_partner_id		IN      number,
			p_partner_site_id	IN      number,
			p_partner_type		IN      number,
			p_organization_id	IN      number,
			p_ship_method_code	IN      varchar2,
			p_calendar_type  	IN      integer,
			p_association_type      OUT     NOCOPY NUMBER
			) RETURN VARCHAR2;

FUNCTION Get_Calendar_Code(
			p_instance_id		IN      number,
			p_plan_id		IN      number,
			p_inventory_item_id	IN      number,
			p_partner_id		IN      number,
			p_partner_site_id	IN      number,
			p_partner_type		IN      number,
			p_organization_id	IN      number,
			p_ship_method_code	IN      varchar2,
			p_calendar_type  	IN      integer,
			p_from_cal_window       IN      integer,
			p_association_type      OUT     NOCOPY NUMBER
			) RETURN VARCHAR2;

-- New Overloaded Functions added for ship_rec_cal project driven by calendar_code rather than org_id
FUNCTION NEXT_WORK_DAY(
			p_calendar_code		IN varchar2,
			p_instance_id		IN number,
			p_calendar_date		IN date
			) RETURN DATE;

FUNCTION PREV_WORK_DAY(
			p_calendar_code		IN varchar2,
			p_instance_id		IN number,
			p_calendar_date		IN date
			) RETURN DATE;

FUNCTION DATE_OFFSET(
			p_calendar_code		IN varchar2,
			p_instance_id		IN number,
			p_calendar_date		IN date,
			p_days_offset		IN number,
			p_offset_type           IN number
			) RETURN DATE;

FUNCTION THREE_STEP_CAL_OFFSET_DATE(
			p_input_date			IN Date,
			p_first_cal_code		IN VARCHAR2,
			p_first_cal_validation_type	IN NUMBER,
			p_second_cal_code		IN VARCHAR2,
			p_offset_days			IN NUMBER,
			p_second_cal_validation_type	IN NUMBER,
			p_third_cal_code		IN VARCHAR2,
			p_third_cal_validation_type	IN NUMBER,
			p_instance_id			IN NUMBER
			) RETURN DATE;


END MSC_CALENDAR;

/
