--------------------------------------------------------
--  DDL for Package Body HRI_BPL_TIME
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRI_BPL_TIME" AS
/* $Header: hribtime.pkb 115.1 2003/12/08 07:11:08 knarula noship $ */
--
g_start_date	    DATE;
g_end_date	    DATE;
g_ip_start_date     DATE;
g_ip_end_date 	    DATE;
g_ip_start_period   varchar2(30);
g_ip_end_period     varchar2(30);
--

/**************************************************************************
Description   : For a given date, this function finds the start date of the
		period in which the date lies.
		The period can be 'YEAR','SEMIYEAR','QUARTERYEAR',
		'BIMONTH','MONTH'.
Preconditions : None
In Parameters : p_start_date 	IN DATE
		p_period 	IN VARCHAR2
Post Sucess   : Returns the start date of the period
Post Failure  : Raise error no_data_found
***************************************************************************/

FUNCTION get_period_start_date(p_start_date 	IN DATE,
			       p_period 	IN VARCHAR2)
RETURN 	 DATE IS
  	--
  	-- Cursors
  	--
  	cursor 	c_year is
  	select 	start_date
  	from 	FII_TIME_YEAR_V
  	where 	p_start_date between start_date and end_date;
  	--
  	cursor 	c_semi_year is
	select 	start_date
	from 	FII_TIME_SEMIYEAR_V
	where 	p_start_date between start_date and end_date;
  	--
  	cursor 	c_quarter_year is
	select 	start_date
	from 	FII_TIME_QTR_V
  	where 	p_start_date between start_date and end_date;
  	--
  	cursor 	c_bimonth is
	select 	start_date
	from 	FII_TIME_BIMONTH_V
  	where 	p_start_date between start_date and end_date;
  	--
  	cursor 	c_month is
	select 	start_date
	from 	FII_TIME_MONTH_V
  	where 	p_start_date between start_date and end_date;
  	--
BEGIN
	--
	IF (p_start_date is NULL or p_period IS NULL) THEN
		--
		raise NO_DATA_FOUND;
		--
       	ELSIF p_start_date = g_ip_start_date and p_period = g_ip_start_period THEN
       		--
       		return nvl(g_start_date,p_start_date);
       		--
       	ELSE
		-- Flush out the values in the cache
		g_start_date	  := null;
		g_ip_start_date   := null;
		g_ip_start_period := null;
		--
		if upper(p_period)='YEAR' then
			open  c_year;
			fetch c_year into g_start_date;
			close c_year;
		elsif upper(p_period)='SEMIYEAR' then
			open c_semi_year;
			fetch c_semi_year into g_start_date;
			close c_semi_year;
		elsif upper(p_period)='QUARTERYEAR' then
			open c_quarter_year;
			fetch c_quarter_year into g_start_date;
			close c_quarter_year;
		elsif upper(p_period)='BIMONTH' then
			open c_bimonth;
			fetch c_bimonth into g_start_date;
			close c_bimonth;
		elsif upper(p_period)='MONTH' then
			open c_month;
			fetch c_month into g_start_date;
			close c_month;
		else
			raise no_data_found;
		end if;
		--
		g_ip_start_date   := p_start_date;
		g_ip_start_period := p_period ;
		--
	END IF;
	--
	return nvl(g_start_date,p_start_date);
EXCEPTION
	WHEN OTHERS THEN
		raise NO_DATA_FOUND;
END get_period_start_date;
--


/**************************************************************************
Description   : For a given date, this function finds the end date of the
		period in which the date lies.
		The period can be 'YEAR','SEMIYEAR','QUARTERYEAR',
		'BIMONTH','MONTH'.
Preconditions : None
In Parameters : p_end_date 	IN DATE
		p_period 	IN VARCHAR2
Post Sucess   : Returns the end date fo the period
Post Failure  : Raise error no_data_found
***************************************************************************/

FUNCTION get_period_end_date(p_end_date 	IN  DATE,
		      	     p_period 		IN VARCHAR2)
RETURN DATE IS
	--
	-- Cursors
  	--
  	cursor 	c_year is
	select 	end_date
	from 	FII_TIME_YEAR_V
	where 	p_end_date between start_date and end_date;
	--
	cursor 	c_semi_year is
	select 	end_date
	from 	FII_TIME_SEMIYEAR_V
	where 	p_end_date between start_date and end_date;
	--
	cursor 	c_quarter_year is
	select 	end_date
	from 	FII_TIME_QTR_V
	where 	p_end_date between start_date and end_date;
	--
	cursor 	c_bimonth is
	select 	end_date
	from 	FII_TIME_BIMONTH_V
	where 	p_end_date between start_date and end_date;
	--
	cursor 	c_month is
	select 	end_date
	from 	FII_TIME_MONTH_V
  	where 	p_end_date between start_date and end_date;
  	--
BEGIN
	--
  	IF (p_end_date is NULL or p_period IS NULL) THEN
  		--
		raise NO_DATA_FOUND;
		--
       	ELSIF p_end_date = g_ip_end_date and p_period = g_ip_end_period THEN
       		return nvl(g_end_date,p_end_date);
       	ELSE
		-- Flush out the values in the cache
		g_end_date	  := null;
		g_ip_end_date 	  := null;
		g_ip_end_period   := null;
       		--
		if upper(p_period)='YEAR' then
			open c_year;
			fetch c_year into g_end_date;
			close c_year;
		elsif upper(p_period)='SEMIYEAR' then
			open c_semi_year;
			fetch c_semi_year into g_end_date;
			close c_semi_year;
 		elsif upper(p_period)='QUARTERYEAR' then
			open c_quarter_year;
			fetch c_quarter_year into g_end_date;
			close c_quarter_year;
 		elsif upper(p_period)='BIMONTH' then
			open c_bimonth;
			fetch c_bimonth into g_end_date;
			close c_bimonth;
 		elsif upper(p_period)='MONTH' then
			open c_month;
			fetch c_month into g_end_date;
			close c_month;
		else
			raise no_data_found;
 		end if;
 		--
 		g_ip_end_date    := p_end_date;
 		g_ip_end_period  := p_period;
 		--
	END IF;
	--
	return nvl(g_end_date, p_end_date);
	--
EXCEPTION
	WHEN OTHERS THEN
		raise NO_DATA_FOUND;
END get_period_end_date;
--
END hri_bpl_time;

/
