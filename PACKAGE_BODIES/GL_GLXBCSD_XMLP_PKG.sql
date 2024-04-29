--------------------------------------------------------
--  DDL for Package Body GL_GLXBCSD_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_GLXBCSD_XMLP_PKG" AS
/* $Header: GLXBCSDB.pls 120.3 2008/01/07 20:08:28 vijranga noship $ */
function AfterReport return boolean is
begin
  /*SRW.USER_EXIT('FND SRWEXIT');*/null;

  return (TRUE);
end;

function BeforeReport return boolean is
errbuf             VARCHAR2(132);
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
    select name, currency_code
    INTO   LEDGER_NAME, FUNCT_CURR_CODE
    from   gl_ledgers
    where  ledger_id = P_LEDGER_ID;

    select budget_name
    INTO   BUDGET_NAME
    from   gl_budget_versions
    where  budget_version_id = P_BUDGET_VERSION_ID;

  exception
    WHEN OTHERS THEN
      errbuf := SQLERRM;
      /*SRW.MESSAGE(0,errbuf);*/null;

      raise_application_error(-20101,null);/*SRW.PROGRAM_ABORT;*/null;

  end;

  /*SRW.REFERENCE(STRUCT_NUM);*/null;


 null;

  /*SRW.REFERENCE(STRUCT_NUM);*/null;


 null;

  /*SRW.REFERENCE(STRUCT_NUM);*/null;


 null;

  DAS_WHERE := GL_ACCESS_SET_SECURITY_PKG.GET_SECURITY_CLAUSE(
                  P_ACCESS_SET_ID,
                  'R',
                  'LEDGER_ID',
                  P_LEDGER_ID,
                  null,
                  'SEG_COLUMN',
                  null,
                  'CC',
                  null);

  if (DAS_WHERE is not null) then
    DAS_WHERE := ' and ' || DAS_WHERE;
  else
    DAS_WHERE := ' ';
  end if;

  return (TRUE);
end;

--Functions to refer Oracle report placeholders--

 Function STRUCT_NUM_p return number is
	Begin
	 return STRUCT_NUM;
	 END;
 Function LEDGER_NAME_p return varchar2 is
	Begin
	 return LEDGER_NAME;
	 END;
 Function BUDGET_NAME_p return varchar2 is
	Begin
	 return BUDGET_NAME;
	 END;
 Function FLEXDATA_p return varchar2 is
	Begin
	 return FLEXDATA;
	 END;
 Function FLEX_ORDERBY_p return varchar2 is
	Begin
	 return FLEX_ORDERBY;
	 END;
 Function FLEX_WHERE_p return varchar2 is
	Begin
	 return FLEX_WHERE;
	 END;
 Function ACCESS_SET_NAME_p return varchar2 is
	Begin
	 return ACCESS_SET_NAME;
	 END;
 Function FUNCT_CURR_CODE_p return varchar2 is
	Begin
	 return FUNCT_CURR_CODE;
	 END;
 Function DAS_WHERE_p return varchar2 is
	Begin
	 return DAS_WHERE;
	 END;
END GL_GLXBCSD_XMLP_PKG ;

/
