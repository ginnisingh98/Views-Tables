--------------------------------------------------------
--  DDL for Package Body FA_FASLSCAL_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_FASLSCAL_XMLP_PKG" AS
/* $Header: FASLSCALB.pls 120.0.12010000.1 2008/07/28 13:16:51 appldev ship $ */

function BeforeReport return boolean is
begin

/*SRW.USER_EXIT('FND SRWINIT');*/null;
  return (TRUE);
end;

function AfterReport return boolean is
begin

/*SRW.USER_EXIT('FND SRWEXIT');*/null;
  return (TRUE);
end;

function RP_REPORT_NAMEFormula return VARCHAR2 is
begin
 P_CONC_REQUEST_ID := fnd_global.CONC_REQUEST_ID;

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
    RETURN(':CALENDAR LISTING:');
END;
RETURN NULL; end;

function RP_COMPANY_NAMEFormula return VARCHAR2 is
begin

DECLARE
  l_comp_name 	VARCHAR2(30);
BEGIN
  select company_name
  into l_comp_name
  from fa_system_controls;

  RETURN(l_comp_name);

EXCEPTION
  WHEN OTHERS THEN
    RETURN(NULL);

END;
RETURN NULL; end;

--Functions to refer Oracle report placeholders--

END FA_FASLSCAL_XMLP_PKG ;


/
