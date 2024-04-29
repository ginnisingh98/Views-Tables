--------------------------------------------------------
--  DDL for Package Body FA_FAS420_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_FAS420_XMLP_PKG" AS
/* $Header: FAS420B.pls 120.0.12010000.1 2008/07/28 13:14:20 appldev ship $ */
function Report_NameFormula return VARCHAR2 is
begin
DECLARE
  l_report_name VARCHAR2(80);
  l_conc_program_id NUMBER;
BEGIN
  SELECT cr.concurrent_program_id
  INTO l_conc_program_id
  FROM FND_CONCURRENT_REQUESTS cr
  WHERE cr.program_application_id = 140
  AND   cr.request_id = P_CONC_REQUEST_ID;
  SELECT cp.user_concurrent_program_name
  INTO   l_report_name
  FROM    FND_CONCURRENT_PROGRAMS_VL cp
  WHERE
      cp.concurrent_program_id= l_conc_program_id
  and cp.application_id = 140;
l_report_name := substr(l_report_name,1,instr(l_report_name,' (XML)'));
  RETURN(l_report_name);
EXCEPTION
  WHEN OTHERS THEN
   RETURN(':Asset Additions Report:');
END;
RETURN NULL; end;
function BeforeReport return boolean is
begin
P_CONC_REQUEST_ID := fnd_global.CONC_REQUEST_ID;
/*SRW.USER_EXIT('FND SRWINIT');*/null;
IF upper(p_mrcsobtype) = 'R'
THEN
  fnd_client_info.set_currency_context(p_ca_set_of_books_id);
END IF;
  return (TRUE);
end;
function AfterReport return boolean is
begin
/*SRW.USER_EXIT('FND SRWEXIT');*/null;
  return (TRUE);
end;
function Period1_PCFormula return Number is
begin
DECLARE
  l_period_POD  DATE;
  l_period_PCD  DATE;
  l_period_PC   NUMBER(15);
  l_period_FY   NUMBER(15);
BEGIN
IF upper(p_mrcsobtype) = 'R'  then
  SELECT period_counter,
         period_open_date,
         nvl(period_close_date, sysdate),
         fiscal_year
  INTO   l_period_PC,
         l_period_POD,
         l_period_PCD,
         l_period_FY
  FROM   FA_DEPRN_PERIODS_MRC_V
  WHERE  book_type_code = P_BOOK
  AND    period_name    = P_PERIOD1;
else
  SELECT period_counter,
         period_open_date,
         nvl(period_close_date, sysdate),
         fiscal_year
  INTO   l_period_PC,
         l_period_POD,
         l_period_PCD,
         l_period_FY
  FROM   FA_DEPRN_PERIODS
  WHERE  book_type_code = P_BOOK
  AND    period_name    = P_PERIOD1;
end if;
  Period1_POD := l_period_POD;
  Period1_PCD := l_period_PCD;
  Period1_FY  := l_period_FY;
  return(l_period_PC);
END;
RETURN NULL; end;
function Period2_PCFormula return Number is
begin
DECLARE
  l_period_POD  DATE;
  l_period_PCD  DATE;
  l_period_PC   NUMBER(15);
  l_period_FY   NUMBER(15);
BEGIN
IF upper(p_mrcsobtype) = 'R'  then
  SELECT period_counter,
         period_open_date,
         nvl(period_close_date, sysdate),
         fiscal_year
  INTO   l_period_PC,
         l_period_POD,
         l_period_PCD,
         l_period_FY
  FROM   FA_DEPRN_PERIODS_MRC_V
  WHERE  book_type_code = P_BOOK
  AND    period_name    = P_PERIOD2;
else
  SELECT period_counter,
         period_open_date,
         nvl(period_close_date, sysdate),
         fiscal_year
  INTO   l_period_PC,
         l_period_POD,
         l_period_PCD,
         l_period_FY
  FROM   FA_DEPRN_PERIODS
  WHERE  book_type_code = P_BOOK
  AND    period_name    = P_PERIOD2;
end if;
  Period2_POD := l_period_POD;
  Period2_PCD := l_period_PCD;
  Period2_FY  := l_period_FY;
  return(l_period_PC);
END;
RETURN NULL; end;
function d_lifeformula(life in number, adj_rate in number, bonus_rate in number, prod in number) return varchar2 is
begin
return (fadolif(life, adj_rate, bonus_rate, prod));
end;
function AfterPForm return boolean is
begin
IF p_ca_set_of_books_id <> -1999
THEN
  BEGIN
   select mrc_sob_type_code, currency_code
   into p_mrcsobtype, lp_currency_code
   from gl_sets_of_books
   where set_of_books_id = p_ca_set_of_books_id;
  EXCEPTION
    WHEN OTHERS THEN
     p_mrcsobtype := 'P';
  END;
ELSE
   p_mrcsobtype := 'P';
END IF;
IF upper(p_mrcsobtype) = 'R'
THEN
  lp_fa_book_controls  := 'FA_BOOK_CONTROLS_MRC_V';
  lp_fa_books		:= 'FA_BOOKS_MRC_V';
  lp_fa_adjustments	:= 'FA_ADJUSTMENTS_MRC_V';
  lp_fa_deprn_periods	:= 'FA_DEPRN_PERIODS_MRC_V';
  lp_fa_deprn_summary	:= 'FA_DEPRN_SUMMARY_MRC_V';
  lp_fa_deprn_detail	:= 'FA_DEPRN_DETAIL_MRC_V';
ELSE
  lp_fa_book_controls  := 'FA_BOOK_CONTROLS';
  lp_fa_books		:= 'FA_BOOKS';
  lp_fa_adjustments	:= 'FA_ADJUSTMENTS';
  lp_fa_deprn_periods	:= 'FA_DEPRN_PERIODS';
  lp_fa_deprn_summary	:= 'FA_DEPRN_SUMMARY';
  lp_fa_deprn_detail	:= 'FA_DEPRN_DETAIL';
END IF;
  return (TRUE);
end;
--Functions to refer Oracle report placeholders--
 Function ACCT_BAL_APROMPT_p return varchar2 is
	Begin
	 return ACCT_BAL_APROMPT;
	 END;
 Function ACCT_CC_APROMPT_p return varchar2 is
	Begin
	 return ACCT_CC_APROMPT;
	 END;
 Function CAT_MAJ_RPROMPT_p return varchar2 is
	Begin
	 return CAT_MAJ_RPROMPT;
	 END;
 Function Period1_POD_p return date is
	Begin
	 return Period1_POD;
	 END;
 Function Period1_PCD_p return date is
	Begin
	 return Period1_PCD;
	 END;
 Function Period1_FY_p return number is
	Begin
	 return Period1_FY;
	 END;
 Function Period2_POD_p return date is
	Begin
	 return Period2_POD;
	 END;
 Function Period2_PCD_p return date is
	Begin
	 return Period2_PCD;
	 END;
 Function Period2_FY_p return number is
	Begin
	 return Period2_FY;
	 END;
 Function PERIOD_FROM_p return varchar2 is
	Begin
	 return PERIOD_FROM;
	 END;
 Function PERIOD_TO_p return varchar2 is
	Begin
	 return PERIOD_TO;
	 END;
	 --added
 Function LP_CURRENCY_CODE_p return varchar2 is
	Begin
	 return LP_CURRENCY_CODE;
	 END;
	 --end
FUNCTION fadolif(life NUMBER,
		adj_rate NUMBER,
		bonus_rate NUMBER,
		prod NUMBER)
RETURN CHAR IS
   retval CHAR(7);
   num_chars NUMBER;
   temp_retval number;
BEGIN
   IF life IS NOT NULL
   THEN
      -- Fix for bug 601202 -- added substrb after lpad.  changed '90' to '999'
      temp_retval := fnd_number.canonical_to_number((LPAD(SUBSTR(TO_CHAR(TRUNC(life/12, 0), '999'), 2, 3),3,' ') || '.' ||
		SUBSTR(TO_CHAR(MOD(life, 12), '00'), 2, 2)) );
      retval := to_char(temp_retval,'999D99');
   ELSIF adj_rate IS NOT NULL
   THEN
      /* Bug 1744591
         Changed 90D99 to 990D99 */
           retval := SUBSTR(TO_CHAR(ROUND((adj_rate + NVL(bonus_rate, 0))*100, 2), '990.99'),2,6) || '%';
   ELSIF prod IS NOT NULL
   THEN
	--test for length of production_capacity; if it's longer
	--than 7 characters, then display in exponential notation
      --IF prod <= 9999999
      --THEN
      --   retval := TO_CHAR(prod);
      --ELSE
      --   retval := SUBSTR(LTRIM(TO_CHAR(prod, '9.9EEEE')), 1, 7);
      --END IF;
	--display nothing for UOP assets
	retval := '';
   ELSE
	--should not occur
      retval := ' ';
   END IF;
   return(retval);
END;
END FA_FAS420_XMLP_PKG ;


/
