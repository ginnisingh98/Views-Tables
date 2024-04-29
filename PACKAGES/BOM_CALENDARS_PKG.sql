--------------------------------------------------------
--  DDL for Package BOM_CALENDARS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BOM_CALENDARS_PKG" AUTHID CURRENT_USER as
/* $Header: bompbcls.pls 115.1 99/07/16 05:47:13 porting ship $ */


FUNCTION Workday_Pattern_Exist (x_calendar_code VARCHAR2,
				x_shift_num NUMBER,
			     	x_calendar_or_shift NUMBER) RETURN NUMBER;

PROCEDURE Calendar_Check_Unique (x_calendar_code VARCHAR2);

PROCEDURE Check_Exception_Range (x_calendar_code 	       VARCHAR2,
				 x_lo_except_date	IN OUT DATE,
				 x_hi_except_date	IN OUT DATE);

PROCEDURE Cal_Exception_Check_Unique (x_calendar_Code   VARCHAR2,
				      x_exception_date	DATE);

PROCEDURE Shift_Check_Unique (x_calendar_code VARCHAR2,
	 		      x_shift_num     NUMBER);

PROCEDURE Shift_Exception_Check_Unique (x_calendar_code	  VARCHAR2,
					x_shift_num	  NUMBER,
				 	x_exception_date  DATE);

PROCEDURE Times_Check_Unique (x_calendar_code VARCHAR2,
			      x_row_id        VARCHAR2,
			      x_shift_num     NUMBER,
			      x_start_time    NUMBER,
			      x_end_time      NUMBER);

FUNCTION Shift_Times_Overlap (x_calendar_code	VARCHAR2,
			      x_shift_num	NUMBER,
			      x_start_time	NUMBER,
			      x_end_time	NUMBER,
			      x_rowid		VARCHAR2,
			      x_flag		NUMBER) RETURN NUMBER;

END BOM_CALENDARS_PKG;

 

/
