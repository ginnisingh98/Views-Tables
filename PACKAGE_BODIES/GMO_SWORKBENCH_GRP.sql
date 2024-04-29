--------------------------------------------------------
--  DDL for Package Body GMO_SWORKBENCH_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMO_SWORKBENCH_GRP" AS
/* $Header: GMOGSWBB.pls 120.1 2007/06/21 06:10:23 rvsingh noship $ */
PKG_NAME CONSTANT VARCHAR2(40) := 'GMO_SWORKBENCH_GRP';
FUNCTION GET_TASK_PERCENTAGE(area_id number,max_no_of_tasks number,date_value Date) RETURN Number
as
percentage number default 0;
begin
percentage := GMO_SWORKBENCH_PVT.GET_TASK_PERCENTAGE(area_id, max_no_of_tasks,date_value);
return percentage;
end;
FUNCTION GET_TASK_PERCENTAGE(area_id number,max_no_of_tasks number,date_value Date,oper number) RETURN Number
as
percentage number default 0;
begin
percentage := GMO_SWORKBENCH_PVT.GET_TASK_PERCENTAGE(area_id, max_no_of_tasks, date_value, oper);
return percentage;
end;
FUNCTION GET_WEEKLY_TASK_PERCENTAGE(area_id number,max_no_of_tasks number,week_start_date Date,week_end_date Date) RETURN Number
as
percentage number default 0;
begin
percentage := GMO_SWORKBENCH_PVT.GET_WEEKLY_TASK_PERCENTAGE(area_id, max_no_of_tasks, week_start_date, week_end_date);
return percentage;
end;
FUNCTION GET_WEEKLY_TASK_PERCENTAGE(area_id number,max_no_of_tasks number,week_start_date Date,week_end_date Date,oper number) RETURN Number
as
percentage number default 0;
begin
percentage := GMO_SWORKBENCH_PVT.GET_WEEKLY_TASK_PERCENTAGE(area_id, max_no_of_tasks, week_start_date, week_end_date, oper);
return percentage;
end;



function get_days(timevalue varchar2)return number
as
begin
return gmo_sworkbench_pvt.get_days(timevalue);
end;

FUNCTION GET_HOURS(timevalue varchar2)return number
as
begin
return gmo_sworkbench_pvt.get_hours(timevalue);
end;

FUNCTION get_MINUTES(timevalue varchar2)return number
as
begin
return gmo_sworkbench_pvt.get_minutes(timevalue);
END;



END;

/
