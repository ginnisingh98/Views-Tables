--------------------------------------------------------
--  DDL for Package BSC_INTEGRATION_APIS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BSC_INTEGRATION_APIS" AUTHID CURRENT_USER AS
/* $Header: BSCIAPIS.pls 115.3 2003/01/14 20:18:30 meastmon ship $ */

procedure Get_Calendar_Labels(
  x_cal_id		number,
  x_year_range		varchar2
);

function Get_Number_Of_Periods(
  x_current_fy		number,
  x_periodicity		number,
  x_calendar_id		number
  ) return number;

procedure Translate_EDW_Time(
  x_calendar_id         number,
  x_cal_range		varchar2,
  x_period_source       number,
  x_period_target       number
);

END BSC_INTEGRATION_APIS;

 

/
