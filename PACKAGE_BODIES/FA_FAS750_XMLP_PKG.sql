--------------------------------------------------------
--  DDL for Package Body FA_FAS750_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_FAS750_XMLP_PKG" AS
/* $Header: FAS750B.pls 120.0.12010000.1 2008/07/28 13:15:27 appldev ship $ */
function report_nameformula(Company_Name in varchar2) return varchar2 is
begin
DECLARE
  l_report_name VARCHAR2(80);
  l_conc_program_id NUMBER;
BEGIN
  RP_Company_Name := Company_Name;
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
  RP_Report_Name := l_report_name;
  RETURN(l_report_name);
EXCEPTION
  WHEN OTHERS THEN
    RP_Report_Name := ':Asset Category Listing:';
    RETURN(RP_Report_Name);
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
function d_lifeformula(LIFE in number, ADJ_RATE in number, PROD in number) return varchar2 is
begin
/*SRW.REFERENCE(LIFE);*/null;
DECLARE
   l_life	number;
   l_adj_rate	number;
   l_bonus_rate	number;
   l_prod	number;
   l_d_life	varchar2(7);
BEGIN
	l_life := LIFE;
	l_adj_rate := ADJ_RATE;
	l_bonus_rate := NULL;
	l_prod := PROD;
  l_d_life := fadolif(l_life, l_adj_rate, l_bonus_rate, l_prod);
return(l_d_life);
END;
RETURN NULL; end;
--Functions to refer Oracle report placeholders--
 Function CAT_MAJ_APROMPT_p return varchar2 is
	Begin
	 return CAT_MAJ_APROMPT;
	 END;
 Function RP_COMPANY_NAME_p return varchar2 is
	Begin
	 return RP_COMPANY_NAME;
	 END;
 Function RP_REPORT_NAME_p return varchar2 is
	Begin
	 return RP_REPORT_NAME;
	 END;
	 --added by valli--
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
      temp_retval := fnd_number.canonical_to_number((LPAD(SUBSTR(TO_CHAR(TRUNC(life/12, 0), '999'), 2, 3),3,' ') || '.' ||
		SUBSTR(TO_CHAR(MOD(life, 12), '00'), 2, 2)) );
      retval := to_char(temp_retval,'999D99');
   ELSIF adj_rate IS NOT NULL
   THEN
           retval := SUBSTR(TO_CHAR(ROUND((adj_rate + NVL(bonus_rate, 0))*100, 2), '990.99'),2,6) || '%';
   ELSIF prod IS NOT NULL
   THEN
	retval := '';
   ELSE
      retval := ' ';
   END IF;
   return(retval);
END;
PROCEDURE VERSION IS
  FDRCSID VARCHAR2(100);
  BEGIN
     FDRCSID := '$Header: FAS750B.pls 120.0.12010000.1 2008/07/28 13:15:27 appldev ship $';
  END VERSION;
END FA_FAS750_XMLP_PKG ;


/
