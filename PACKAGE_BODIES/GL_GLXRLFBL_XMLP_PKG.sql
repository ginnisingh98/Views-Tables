--------------------------------------------------------
--  DDL for Package Body GL_GLXRLFBL_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_GLXRLFBL_XMLP_PKG" AS
/* $Header: GLXRLFBLB.pls 120.0 2007/12/27 15:13:16 vijranga noship $ */

function BeforeReport return boolean is
errbuf  VARCHAR2(132);
begin
  /*srw.user_exit('FND SRWINIT');*/null;



  begin
    SELECT name, chart_of_accounts_id
    INTO   ACCESS_SET_NAME, STRUCT_NUM
    FROM   gl_access_sets
    WHERE  access_set_id = P_ACCESS_SET_ID;

  exception
    WHEN NO_DATA_FOUND THEN
      errbuf := gl_message.get_message('GL_PLL_INVALID_DATA_ACCESS_SET', 'Y',
                                       'DASID', to_char(P_ACCESS_SET_ID));
      /*srw.message('00', errbuf);*/null;

      raise_application_error(-20101,null);/*srw.program_abort;*/null;


    WHEN OTHERS THEN
      errbuf := SQLERRM;
      /*srw.message('00', errbuf);*/null;

      raise_application_error(-20101,null);/*srw.program_abort;*/null;

  end;


  begin
    SELECT name
    INTO   LEDGER_NAME
    FROM   gl_ledgers
    WHERE  ledger_id = P_LEDGER_ID;

  exception
    WHEN OTHERS THEN
      errbuf := SQLERRM;
      /*srw.message('00', errbuf);*/null;

      raise_application_error(-20101,null);/*srw.program_abort;*/null;

  end;

  /*srw.reference( STRUCT_NUM );*/null;

  /*srw.user_exit( 'FND FLEXRSQL
                  CODE = "GL#"
                  NUM = ":STRUCT_NUM"
                  APPL_SHORT_NAME = "SQLGL"
                  OUTPUT = ":FLEX_SELECT_ALL"
                  TABLEALIAS = "gbfr" ');*/null;


  return (TRUE);
end;

function AfterReport return boolean is
begin
  /*srw.user_exit('FND SRWEXIT');*/null;

  return (TRUE);
end;

function flex_field_all_lowformula(FLEX_FIELD_ALL_LOW in varchar2) return varchar2 is
begin
  /*srw.reference( STRUCT_NUM );*/null;

  /*srw.reference( FLEX_DATA_ALL_LOW);*/null;

  /*srw.user_exit( 'FND FLEXRIDVAL
                  CODE = "GL#"
                  NUM = ":STRUCT_NUM"
                  APPL_SHORT_NAME = "SQLGL"
                  DATA = ":FLEX_DATA_ALL_LOW"
                  VALUE = ":FLEX_FIELD_ALL_LOW"' );*/null;

  return( FLEX_FIELD_ALL_LOW );
end;

function flex_field_all_highformula(FLEX_FIELD_ALL_HIGH in varchar2) return varchar2 is
begin
  /*srw.reference( STRUCT_NUM );*/null;

  /*srw.reference( FLEX_DATA_ALL_HIGH);*/null;

  /*srw.user_exit( 'FND FLEXRIDVAL
                  CODE = "GL#"
                  NUM = ":STRUCT_NUM"
                  APPL_SHORT_NAME = "SQLGL"
                  DATA = ":FLEX_DATA_ALL_HIGH"
                  VALUE = ":FLEX_FIELD_ALL_HIGH"' );*/null;

  return( FLEX_FIELD_ALL_HIGH );
end;

--Functions to refer Oracle report placeholders--

 Function STRUCT_NUM_p return varchar2 is
	Begin
	 return STRUCT_NUM;
	 END;
 Function LEDGER_NAME_p return varchar2 is
	Begin
	 return LEDGER_NAME;
	 END;
 Function FLEX_SELECT_ALL_LOW_p return varchar2 is
	Begin
	 return FLEX_SELECT_ALL_LOW;
	 END;
 Function FLEX_SELECT_ALL_HIGH_p return varchar2 is
	Begin
	 return FLEX_SELECT_ALL_HIGH;
	 END;
 Function ACCESS_SET_NAME_p return varchar2 is
	Begin
	 return ACCESS_SET_NAME;
	 END;
END GL_GLXRLFBL_XMLP_PKG ;


/
