--------------------------------------------------------
--  DDL for Package Body GL_GLXRLVAT_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_GLXRLVAT_XMLP_PKG" AS
/* $Header: GLXRLVATB.pls 120.1 2007/12/28 10:47:44 vijranga noship $ */

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

  WHERE_DAS := GL_ACCESS_SET_SECURITY_PKG.GET_SECURITY_CLAUSE(
                  P_ACCESS_SET_ID,
                  'R',
                  'LEDGER_COLUMN',
                  'LEDGER_ID',
                  'GJL',
                  'SEG_COLUMN',
                  null,
                  'GCC',
                  null);

  if (WHERE_DAS is not null) then
    WHERE_DAS := ' and ' || WHERE_DAS;
  end if;

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


 null;

  /*srw.reference( STRUCT_NUM );*/null;


 null;

  return (TRUE);
end;

function AfterReport return boolean is
begin
  /*srw.user_exit('FND SRWEXIT');*/null;

  return (TRUE);
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
 Function FLEX_SELECT_ALL_p return varchar2 is
	Begin
	 return FLEX_SELECT_ALL;
	 END;
 Function FLEX_ORDERBY_ALL_p return varchar2 is
	Begin
	 return FLEX_ORDERBY_ALL;
	 END;
 Function ACCESS_SET_NAME_p return varchar2 is
	Begin
	 return ACCESS_SET_NAME;
	 END;
 Function WHERE_DAS_p return varchar2 is
	Begin
	 return WHERE_DAS;
	 END;
END GL_GLXRLVAT_XMLP_PKG ;


/
