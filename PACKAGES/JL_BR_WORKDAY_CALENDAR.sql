--------------------------------------------------------
--  DDL for Package JL_BR_WORKDAY_CALENDAR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JL_BR_WORKDAY_CALENDAR" AUTHID CURRENT_USER AS
/* $Header: jlbrscds.pls 120.4 2006/08/25 17:52:18 amohiudd ship $ */

PROCEDURE JL_BR_CHECK_DATE (
	p_date		IN 	varchar2,
	p_calendar  	IN	varchar2,
	p_city		IN	varchar2,
	p_action	IN	varchar2,
	p_new_date	IN OUT NOCOPY	varchar2,
	p_status	IN OUT NOCOPY	number);

PROCEDURE JL_BR_CHECK_DATE (
	p_date		IN 	varchar2,
	p_calendar  	IN	varchar2,
	p_city		IN	varchar2,
	p_action	IN	varchar2,
	p_new_date	IN OUT NOCOPY	varchar2,
	p_status	IN OUT NOCOPY	number,
        p_state         IN      varchar2);  --Bug 2319552

PROCEDURE JL_BR_PAY_DATE_BDC (
        p_date            IN    date,
        p_new_date        IN OUT NOCOPY date,
        p_status          IN OUT NOCOPY number);

END JL_BR_WORKDAY_CALENDAR;

 

/
