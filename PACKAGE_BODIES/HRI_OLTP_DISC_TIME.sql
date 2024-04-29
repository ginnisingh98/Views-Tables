--------------------------------------------------------
--  DDL for Package Body HRI_OLTP_DISC_TIME
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRI_OLTP_DISC_TIME" AS
/* $Header: hriodtim.pkb 115.1 2003/12/08 07:11:13 knarula noship $ */
--
/**************************************************************************
Description   : For a given date, this function finds the start date of the
		period in which the date lies.
		The period can be 'YEAR','SEMIYEAR','QUARTERYEAR',
		'BIMONTH','MONTH'.
		This is a wrapper function for function GET_PERIOD_START_DATE
		in the package HRI_BPL_TIME
Preconditions : None
In Parameters : p_start_date 	IN DATE
		p_period 	IN VARCHAR2
Post Sucess   : It returns the start date for the period
Post Failure  : Returns p_start_date being sent as input
***************************************************************************/
FUNCTION get_period_start_date(p_start_date	IN DATE,
			       p_period		IN VARCHAR2)
RETURN DATE IS
--
l_start_date		DATE;
--
begin
	--
	l_start_date := hri_bpl_time.get_period_start_date(p_start_date,p_period);
	return l_start_date;
	--
exception
	--
	when others then
		return (p_start_date);
	--
END get_period_start_date;

--
-- get_period_end_date
--
/**************************************************************************
Description   : For a given date, this function finds the end date of the
		period in which the date lies.
		The period can be 'YEAR','SEMIYEAR','QUARTERYEAR',
		'BIMONTH','MONTH'.
		This is a wrapper function for function GET_PERIOD_END_DATE
		in the package HRI_BPL_TIME
Preconditions : None
In Parameters : p_end_date 	IN DATE
		p_period 	IN VARCHAR2
Post Sucess   : It returns the end date for the period
Post Failure  : Returns p_end_date being sent as input
***************************************************************************/
FUNCTION get_period_end_date(p_end_date		IN DATE,
			     p_period		IN VARCHAR2)
RETURN DATE IS
--
l_end_date		DATE;
--
begin
	--
	l_end_date := hri_bpl_time.get_period_end_date(p_end_date,p_period);
	return l_end_date;
	--
exception
	when others then
		return (p_end_date);
--
END get_period_end_date;
--
END hri_oltp_disc_time;

/
