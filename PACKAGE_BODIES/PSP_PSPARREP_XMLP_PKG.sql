--------------------------------------------------------
--  DDL for Package Body PSP_PSPARREP_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSP_PSPARREP_XMLP_PKG" AS
/* $Header: PSPARREPB.pls 120.5 2007/10/29 07:19:48 amakrish noship $ */

function BeforeReport return boolean is
begin

	--hr_standard.event('BEFORE REPORT');
  	return (TRUE);
end;

function CF_Begin_period_nameFormula return Char is

 l_period_name	CHAR(70);
l_time_period_id NUMBER(15);

	Cursor c_begin_period_id IS
	SELECT min(PTP1.time_period_id)	time_period_id
	FROM 	PER_TIME_PERIODS PTP1
	WHERE	PTP1.payroll_id	=  nvl(p_payroll_id,PTP1.payroll_id);

	 x_period_id	c_begin_period_id%ROWTYPE;

	Cursor c_period IS
	SELECT  PTP.period_name	period_name
	FROM	PER_TIME_PERIODS PTP
	WHERE	PTP.time_period_id	= 	l_time_period_id;

	 x_period_name	c_period%ROWTYPE;

begin

  IF p_begin_period IS NULL THEN
	BEGIN
		OPEN c_begin_period_id;
		FETCH c_begin_period_id  INTO x_period_id;
		l_time_period_id	:=	x_period_id.time_period_id;
		CLOSE c_begin_period_id;

		OPEN c_period;
		FETCH c_period INTO x_period_name;
		l_period_name		:=	x_period_name.period_name;
		CLOSE	c_period;

	return(l_period_name);
	END ;
  ELSE
	BEGIN
	l_time_period_id	:=	p_begin_period;
		OPEN c_period;
		FETCH c_period INTO x_period_name;
		l_period_name		:=	x_period_name.period_name;
		CLOSE	c_period;

	return(l_period_name);
	END;
  END IF;

 EXCEPTION
	When no_data_found Then
	 return(NULL);
end;

function CF_End_period_nameFormula return Char is
l_period_name	CHAR(70);
l_time_period_id NUMBER(15);

	Cursor c_end_period_id IS
	SELECT max(PTP1.time_period_id)	time_period_id
	FROM 	PER_TIME_PERIODS PTP1
	WHERE	PTP1.payroll_id	=  nvl(p_payroll_id,PTP1.payroll_id);

	 x_period_id	c_end_period_id%ROWTYPE;

	Cursor c_period IS
	SELECT  PTP.period_name	period_name
	FROM	PER_TIME_PERIODS PTP
	WHERE	PTP.time_period_id	= 	l_time_period_id;

	 x_period_name	c_period%ROWTYPE;

begin

  IF p_end_period IS NULL THEN
	BEGIN
		OPEN c_end_period_id;
		FETCH c_end_period_id  INTO x_period_id;
		l_time_period_id	:=	x_period_id.time_period_id;
		CLOSE c_end_period_id;

		OPEN c_period;
		FETCH c_period INTO x_period_name;
		l_period_name		:=	x_period_name.period_name;
		CLOSE	c_period;

	return(l_period_name);
	END ;
  ELSE
	BEGIN
	l_time_period_id	:=	p_end_period;
		OPEN c_period;
		FETCH c_period INTO x_period_name;
		l_period_name		:=	x_period_name.period_name;
		CLOSE	c_period;

	return(l_period_name);
	END;
  END IF;

 EXCEPTION
	When no_data_found Then
	 return(NULL);
 end;

function CF_No_data_foundFormula return Number is
 l_no_lines	 	 NUMBER(15);
 l_no_dist_lines	 NUMBER(15);
 l_no_enc_lines 	 NUMBER(15);

CURSOR c_distribution IS
SELECT	COUNT(*)	no_dist_lines
FROM	PSP_PAYROLL_CONTROLS PPC,
	PER_TIME_PERIODS PTP,
	PAY_PAYROLLS_F	PPF
WHERE	PPC.payroll_id		=	PPF.payroll_id
and	PPC.time_period_id	=	PTP.time_period_id
and	PPC.payroll_id		=	nvl(p_payroll_id,PPF.payroll_id)
and	PTP.time_period_id	>=	nvl(p_begin_period,PTP.time_period_id)
and	PTP.time_period_id	<=	nvl(p_end_period,PTP.time_period_id)
and	PPC.archive_flag	=	'Y';

l_distribution	c_distribution%ROWTYPE;

CURSOR c_encumbrance IS
SELECT	COUNT(*)	no_enc_lines
FROM	PSP_ENC_CONTROLS PEC,
	PER_TIME_PERIODS PTP,
	PAY_PAYROLLS_F	PPF
WHERE	PEC.payroll_id		=	PPF.payroll_id
and	PEC.time_period_id	=	PTP.time_period_id
and	PEC.payroll_id		=	nvl(p_payroll_id,PPF.payroll_id)
and	PTP.time_period_id	>=	nvl(p_begin_period,PTP.time_period_id)
and	PTP.time_period_id	<=	nvl(p_end_period,PTP.time_period_id)
and	PEC.archive_flag	=	'Y';

l_encumbrance	c_encumbrance%ROWTYPE;
begin
	OPEN	c_distribution;
	FETCH	c_distribution INTO l_distribution;
	l_no_dist_lines		:=	l_distribution.no_dist_lines;
	CLOSE 	c_distribution;

	OPEN	c_encumbrance;
	FETCH	c_encumbrance INTO l_encumbrance;
	l_no_enc_lines		:=	l_encumbrance.no_enc_lines;
	CLOSE 	c_encumbrance;

	l_no_lines :=	l_no_dist_lines + l_no_enc_lines;
	return(l_no_lines);
end;

function BeforePForm return boolean is
begin
  --ORIENTATION	:= 'LANDSCAPE';
  return (TRUE);
end;

function AfterReport return boolean is
begin
	--hr_standard.event('AFTER REPORT');
  return (TRUE);
end;

--Functions to refer Oracle report placeholders--

END PSP_PSPARREP_XMLP_PKG ;

/
