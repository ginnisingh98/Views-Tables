--------------------------------------------------------
--  DDL for Package Body GL_GLXLSLST_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_GLXLSLST_XMLP_PKG" AS
/* $Header: GLXLSLSTB.pls 120.0 2007/12/27 14:59:52 vijranga noship $ */

function BeforeReport return boolean is
errbuf VARCHAR2(300);
begin
  /*srw.user_exit('FND SRWINIT');*/null;


  begin
     SELECT g.chart_of_accounts_id, g.period_set_name,
            p.user_period_type, g.name, g.description
     INTO    C_STRUCT_NUM, C_CALENDAR, C_PERIOD_TYPE,
             C_LEDGER_SET_NAME, C_DESCRIPTION
     FROM  gl_ledgers g, gl_period_types p
     WHERE g.ledger_id = P_LEDGER_ID
     AND   p.period_type = g.accounted_period_type;

  exception
    WHEN NO_DATA_FOUND THEN
      errbuf := SQLERRM;
      /*srw.message('00', errbuf);*/null;

      raise_application_error(-20101,null);/*srw.program_abort;*/null;

    WHEN OTHERS THEN
      errbuf := SQLERRM;
      /*srw.message('00', errbuf);*/null;

      raise_application_error(-20101,null);/*srw.program_abort;*/null;

  end;
  C_LANGUAGE := userenv('LANG');
  begin
     SELECT id_flex_structure_name
     INTO    C_COA_NAME
     FROM  fnd_id_flex_structures_tl
     WHERE application_id = 101
     AND   id_flex_code = 'GL#'
     AND   language = C_LANGUAGE
     AND   id_flex_num = C_STRUCT_NUM;

  exception
    WHEN NO_DATA_FOUND THEN
      errbuf := SQLERRM;
      /*srw.message('00', errbuf);*/null;

      raise_application_error(-20101,null);/*srw.program_abort;*/null;

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

 Function C_CALENDAR_p return varchar2 is
	Begin
	 return C_CALENDAR;
	 END;
 Function C_PERIOD_TYPE_p return varchar2 is
	Begin
	 return C_PERIOD_TYPE;
	 END;
 Function C_STRUCT_NUM_p return number is
	Begin
	 return C_STRUCT_NUM;
	 END;
 Function C_DESCRIPTION_p return varchar2 is
	Begin
	 return C_DESCRIPTION;
	 END;
 Function C_COA_NAME_p return varchar2 is
	Begin
	 return C_COA_NAME;
	 END;
 Function C_LEDGER_SET_NAME_p return varchar2 is
	Begin
	 return C_LEDGER_SET_NAME;
	 END;
 Function C_LANGUAGE_p return varchar2 is
	Begin
	 return C_LANGUAGE;
	 END;
END GL_GLXLSLST_XMLP_PKG ;


/
