--------------------------------------------------------
--  DDL for Package Body FA_FASASSBS_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_FASASSBS_XMLP_PKG" AS
/* $Header: FASASSBSB.pls 120.0.12010000.1 2008/07/28 13:16:22 appldev ship $ */
function BookFormula return VARCHAR2 is
begin
DECLARE
  l_book       VARCHAR2(15);
  l_accounting_flex_structure NUMBER(15);
  l_currency_code VARCHAR2(15);
  l_precision  number(15);
  l_distribution_source_book VARCHAR2(15);
BEGIN
  SELECT bc.book_type_code,
         bc.accounting_flex_structure,
         sob.currency_code,
         cur.precision,
	 bc.distribution_source_book
  INTO   l_book,
         l_accounting_flex_Structure,
         l_currency_code,
         l_precision,
	 l_distribution_source_book
  FROM   FA_BOOK_CONTROLS bc,
         GL_SETS_OF_BOOKS sob,
         FND_CURRENCIES cur
  WHERE  bc.book_type_code = P_BOOK
  AND    sob.set_of_books_id = bc.set_of_books_id
  AND    sob.currency_code = cur.currency_code;
  Accounting_Flex_Structure:=l_accounting_flex_structure;
  Currency_Code := l_currency_code;
  precision := l_precision;
  distribution_source_book := l_distribution_source_book;
  return(l_book);
END;
RETURN NULL; end;
function Period1Formula return VARCHAR2 is
begin
DECLARE
  l_period_name VARCHAR2(15);
  l_period_POD  DATE;
  l_period_pc	NUMBER;
BEGIN
  SELECT period_name,
         period_open_date,
	period_counter
  INTO   l_period_name,
         l_period_POD,
	l_period_pc
  FROM   FA_DEPRN_PERIODS
  WHERE  book_type_code = P_BOOK
  AND    period_name    = P_PERIOD1;
  Period1_POD := l_period_POD;
  PERIOD1_PC := l_period_pc;
  return(l_period_name);
END;
RETURN NULL; end;
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
    RETURN(':Additions By Source Report:');
END;
RETURN NULL; end;
function Period2Formula return VARCHAR2 is
begin
DECLARE
  l_period_name  VARCHAR2(15);
  l_period_PCD   DATE;
  l_period_pc	NUMBER;
BEGIN
      select period_name,
             nvl(period_close_date, sysdate),
		period_counter
      into   l_period_name,
             l_period_pcd,
		l_period_pc
      from   fa_deprn_periods
      where  book_type_code = P_BOOK
      and    period_name = P_PERIOD2;
      period2_pcd := l_period_pcd;
	period2_pc := l_period_pc;
      return(l_period_name);
END;
RETURN NULL; end;
function BeforeReport return boolean is
begin
 P_CONC_REQUEST_ID := fnd_global.CONC_REQUEST_ID;
/*SRW.USER_EXIT('FND SRWINIT');*/null;
  return (TRUE);
end;
function AfterReport return boolean is
begin
/*SRW.USER_EXIT('FND SRWEXIT');*/null;
  return (TRUE);
end;
function c_unbalformula(AS_INV_COST in number, AS_ASS_COST in number, ASSET_TYPE in varchar2) return varchar2 is
begin
IF ((AS_INV_COST <> AS_ASS_COST) AND (ASSET_TYPE = 'CIP'))THEN
    RETURN('*');
END IF;
RETURN NULL; end;
function c_cc_unbalformula(CC_INV_COST in number, CC_ASS_COST in number, ASSET_TYPE in varchar2) return varchar2 is
begin
IF ((CC_INV_COST <> CC_ASS_COST) AND (ASSET_TYPE = 'CIP'))THEN
    RETURN('*');
END IF;
RETURN NULL; end;
function c_ac_unbalformula(AC_INV_COST in number, AC_ASS_COST in number, ASSET_TYPE in varchar2) return varchar2 is
begin
IF ((AC_INV_COST <> AC_ASS_COST) AND (ASSET_TYPE = 'CIP'))THEN
    RETURN('*');
END IF;
RETURN NULL; end;
function c_at_unbalformula(AT_INV_COST in number, AT_ASS_COST in number, ASSET_TYPE in varchar2) return varchar2 is
begin
IF ((AT_INV_COST <> AT_ASS_COST) AND (ASSET_TYPE = 'CIP'))THEN
    RETURN('*');
END IF;
RETURN NULL; end;
--Functions to refer Oracle report placeholders--
 Function Accounting_Flex_Structure_p return number is
	Begin
	 return Accounting_Flex_Structure;
	 END;
 Function DISTRIBUTION_SOURCE_BOOK_p return varchar2 is
	Begin
	 return DISTRIBUTION_SOURCE_BOOK;
	 END;
 Function Precision_p return number is
	Begin
	 return Precision;
	 END;
 Function Currency_Code_p return varchar2 is
	Begin
	 return Currency_Code;
	 END;
 Function Period1_POD_p return date is
	Begin
	 return Period1_POD;
	 END;
 Function PERIOD1_PC_p return number is
	Begin
	 return PERIOD1_PC;
	 END;
 Function Period2_PCD_p return date is
	Begin
	 return Period2_PCD;
	 END;
 Function PERIOD2_PC_p return number is
	Begin
	 return PERIOD2_PC;
	 END;
END FA_FASASSBS_XMLP_PKG ;


/
