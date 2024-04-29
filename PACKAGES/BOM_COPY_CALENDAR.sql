--------------------------------------------------------
--  DDL for Package BOM_COPY_CALENDAR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BOM_COPY_CALENDAR" AUTHID CURRENT_USER AS
/* $Header: BOMPCPCS.pls 115.1 99/07/16 05:14:59 porting ship $ */


PROCEDURE Copy_Calendar ( copy_type			IN  NUMBER,
			  x_calendar_code_from 	 	IN  VARCHAR2,
			  x_calendar_code_to		IN  VARCHAR2,
			  x_shift_num_from		IN  NUMBER,
			  x_shift_num_to		IN  NUMBER,
			  x_exception_set_name		IN  VARCHAR2,
			  x_start_date			IN  DATE,
			  x_end_date			IN  DATE,
			  x_userid			IN  NUMBER );

PROCEDURE Drop_Cal_Cancelled_Excepts;

PROCEDURE Drop_Shift_Cancelled_Excepts;


END BOM_COPY_CALENDAR;

 

/
