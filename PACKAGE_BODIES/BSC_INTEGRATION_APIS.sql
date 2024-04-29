--------------------------------------------------------
--  DDL for Package Body BSC_INTEGRATION_APIS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BSC_INTEGRATION_APIS" AS
/* $Header: BSCIAPIB.pls 115.3 2003/01/14 20:15:49 meastmon ship $ */

procedure Get_Calendar_Labels(
  x_cal_id		number,
  x_year_range		varchar2) IS
begin
  null;
end Get_Calendar_Labels;

function Get_Number_Of_Periods(
  x_current_fy		number,
  x_periodicity		number,
  x_calendar_id		number
  ) return number IS
begin
  return 0;
end Get_Number_Of_Periods;

procedure Translate_EDW_Time(
  x_calendar_id         number,
  x_cal_range		varchar2,
  x_period_source       number,
  x_period_target       number) IS
begin
  null;
end Translate_EDW_Time;

END BSC_INTEGRATION_APIS;

/
