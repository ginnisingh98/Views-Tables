--------------------------------------------------------
--  DDL for Package Body GL_GLXDALST_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_GLXDALST_XMLP_PKG" AS
/* $Header: GLXDALSTB.pls 120.0 2007/12/27 14:52:53 vijranga noship $ */
function BeforeReport return boolean is
errbuf VARCHAR2(300);
begin
  /*srw.user_exit('FND SRWINIT');*/null;
P_CONC_REQUEST_ID := fnd_global.CONC_REQUEST_ID;
  begin
    SELECT a.name, a.description, f.id_flex_structure_name,
           a.period_set_name, p.user_period_type,
           a.security_segment_code, l.name
    INTO data_as_name, description, coa, calendar,
         --period_type, type, default_ledger
	 period_type, l_type, default_ledger
    FROM gl_access_sets a,
         gl_ledgers l,
         fnd_id_flex_structures_tl f,
         gl_period_types p
    WHERE a.access_set_id = P_ACCESS_SET_ID
    AND   l.ledger_id (+) = a.default_ledger_id
    AND   f.application_id = 101
    AND   f.id_flex_code = 'GL#'
    AND   f.id_flex_num = a.chart_of_accounts_id
    AND   f.language = userenv('LANG')
    AND   p.period_type = a.accounted_period_type;
  exception
    WHEN OTHERS THEN
      errbuf := SQLERRM;
      /*srw.message('00', errbuf);*/null;
      raise_application_error(-20101,null);/*srw.program_abort;*/null;
  end;
  return (TRUE);
end;
function AfterReport return boolean is
begin
  /*srw.user_exit('FND SRWEXIT');*/null;
  return (TRUE);
end;
--Functions to refer Oracle report placeholders--
 Function DATA_AS_NAME_p return varchar2 is
	Begin
	 return DATA_AS_NAME;
	 END;
 Function DESCRIPTION_p return varchar2 is
	Begin
	 return DESCRIPTION;
	 END;
 Function COA_p return varchar2 is
	Begin
	 return COA;
	 END;
 Function CALENDAR_p return varchar2 is
	Begin
	 return CALENDAR;
	 END;
 Function PERIOD_TYPE_p return varchar2 is
	Begin
	 return PERIOD_TYPE;
	 END;
 Function TYPE_p return varchar2 is
	Begin
	 --return TYPE;
	 return L_TYPE;
	 END;
 Function DEFAULT_LEDGER_p return varchar2 is
	Begin
	 return DEFAULT_LEDGER;
	 END;
 Function SECURITY_SEGMENT_CODE_p return varchar2 is
	Begin
	 return SECURITY_SEGMENT_CODE;
	 END;
END GL_GLXDALST_XMLP_PKG ;


/
