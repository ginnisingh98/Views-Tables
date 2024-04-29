--------------------------------------------------------
--  DDL for Package MRP_CALENDAR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MRP_CALENDAR" AUTHID CURRENT_USER AS
/* $Header: MRPCALDS.pls 115.4 2002/12/01 05:41:23 rashteka ship $ */

  FUNCTION NEXT_WORK_DAY(arg_org_id IN NUMBER,
                         arg_bucket IN NUMBER,
                         arg_date IN DATE) RETURN DATE;
  FUNCTION PREV_WORK_DAY(arg_org_id IN NUMBER,
                         arg_bucket IN NUMBER,
                         arg_date IN DATE) RETURN DATE;
  FUNCTION DATE_OFFSET(  arg_org_id IN NUMBER,
                         arg_bucket IN NUMBER,
                         arg_date IN DATE,
                         arg_offset IN NUMBER) RETURN DATE;
  FUNCTION DAYS_BETWEEN( arg_org_id IN NUMBER,
                         arg_bucket IN NUMBER,
                         arg_date1 IN DATE,
                         arg_date2 IN DATE) RETURN NUMBER;
  PROCEDURE SELECT_CALENDAR_DEFAULTS( arg_org_id IN NUMBER,
                                      arg_calendar_code OUT NOCOPY VARCHAR2,
                                      arg_exception_set_id OUT NOCOPY NUMBER);

END MRP_CALENDAR;

 

/
