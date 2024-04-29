--------------------------------------------------------
--  DDL for Package GMO_SWORKBENCH_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMO_SWORKBENCH_GRP" AUTHID CURRENT_USER AS
/* $Header: GMOGSWBS.pls 120.1 2007/06/21 06:10:52 rvsingh noship $ */

G_PKG_NAME CONSTANT VARCHAR2(40) := 'GMO_SWORKBENCH_GRP';
FUNCTION GET_TASK_PERCENTAGE(area_id number,max_no_of_tasks number,date_value Date) RETURN Number;
FUNCTION GET_TASK_PERCENTAGE(area_id number,max_no_of_tasks number,date_value Date,oper number) RETURN Number;
FUNCTION GET_WEEKLY_TASK_PERCENTAGE(area_id number,max_no_of_tasks number,week_start_date Date,week_end_date Date) RETURN Number;
FUNCTION GET_WEEKLY_TASK_PERCENTAGE(area_id number,max_no_of_tasks number,week_start_date Date,week_end_date Date,oper number) RETURN Number;


function get_days(timevalue varchar2)return number;
FUNCTION GET_HOURS(timevalue varchar2)return number;
FUNCTION get_MINUTES(timevalue varchar2)return number;




END;

/
