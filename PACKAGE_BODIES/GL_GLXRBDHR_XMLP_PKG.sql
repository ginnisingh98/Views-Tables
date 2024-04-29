--------------------------------------------------------
--  DDL for Package Body GL_GLXRBDHR_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_GLXRBDHR_XMLP_PKG" AS
/* $Header: GLXRBDHRB.pls 120.0 2007/12/27 15:02:33 vijranga noship $ */

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

  return (TRUE);
end;

function AfterReport return boolean is
begin
  /*srw.user_exit('FND SRWEXIT');*/null;

  return (TRUE);
end;

--Functions to refer Oracle report placeholders--

 Function LEDGER_NAME_p return varchar2 is
	Begin
	 return LEDGER_NAME;
	 END;
 Function STRUCT_NUM_p return number is
	Begin
	 return STRUCT_NUM;
	 END;
 Function ACCESS_SET_NAME_p return varchar2 is
	Begin
	 return ACCESS_SET_NAME;
	 END;
END GL_GLXRBDHR_XMLP_PKG ;


/
