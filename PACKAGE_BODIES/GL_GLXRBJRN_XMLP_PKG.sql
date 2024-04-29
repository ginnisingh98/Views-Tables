--------------------------------------------------------
--  DDL for Package Body GL_GLXRBJRN_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_GLXRBJRN_XMLP_PKG" AS
/* $Header: GLXRBJRNB.pls 120.0 2007/12/27 15:04:04 vijranga noship $ */

function BeforeReport return boolean is
begin

declare
  t_ledger_id            NUMBER;
  t_chart_of_accounts_id NUMBER;
  t_ledger_name          VARCHAR2(30);
  t_func_curr            VARCHAR2(15);
  t_budget_version_id    NUMBER(15);
  t_budget_name          VARCHAR2(15);
  t_errorbuffer          VARCHAR2(132);

begin

  /*srw.user_exit('FND SRWINIT');*/null;


          t_ledger_id   := to_number(P_LEDGER_ID);
  gl_info.gl_get_ledger_info (t_ledger_id,
                            t_chart_of_accounts_id,
                            t_ledger_name,
                            t_func_curr,
                            t_errorbuffer);
  if (t_errorbuffer is not NULL) then
     /*SRW.MESSAGE(0,t_errorbuffer);*/null;

     raise_application_error(-20101,null);/*SRW.PROGRAM_ABORT;*/null;

  else
     STRUCT_NUM  := to_char(t_chart_of_accounts_id);
     LEDGER_NAME := t_ledger_name;
  end if;

  t_budget_version_id := P_BUDGET_VERSION_ID;

  begin
    select budget_name
    INTO t_budget_name
    from gl_budget_versions
    where budget_version_id = t_budget_version_id;

    BUDGET_NAME := t_budget_name;

    EXCEPTION
    WHEN OTHERS THEN
       t_errorbuffer := SQLERRM;
       /*SRW.MESSAGE(0,t_errorbuffer);*/null;

       raise_application_error(-20101,null);/*SRW.PROGRAM_ABORT;*/null;

  end;

  begin
    SELECT name
    INTO   DAS_NAME
    FROM   gl_access_sets
    WHERE  access_set_id = P_DAS_ID;

  exception
    WHEN NO_DATA_FOUND THEN
       t_errorbuffer := gl_message.get_message('GL_PLL_INVALID_DATA_ACCESS_SET', 'Y',
                              'DASID', to_char(P_DAS_ID));
       /*srw.message('00', t_errorbuffer);*/null;

       raise_application_error(-20101,null);/*srw.program_abort;*/null;


    WHEN OTHERS THEN
       t_errorbuffer := SQLERRM;
       /*srw.message('00', t_errorbuffer);*/null;

       raise_application_error(-20101,null);/*srw.program_abort;*/null;

  end;
  /*SRW.REFERENCE(DAS_NAME);*/null;


  /*SRW.REFERENCE(STRUCT_NUM);*/null;


 null;

WHERE_DAS := GL_ACCESS_SET_SECURITY_PKG.GET_SECURITY_CLAUSE(
                P_DAS_ID,
                'R',
                'LEDGER_ID',
                to_char(P_LEDGER_ID),
                null,
                'SEG_COLUMN',
                null,
                'CC',
                null);

if (WHERE_DAS is not null) then
  WHERE_DAS := ' and ' || WHERE_DAS ;
else
  where_das := ' ';
end if;


END;
  return (TRUE);
end;

function AfterReport return boolean is
begin

/*SRW.USER_EXIT('FND SRWEXIT');*/null;
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
 Function FLEXDATA_p return varchar2 is
	Begin
	 return FLEXDATA;
	 END;
 Function BUDGET_NAME_p return varchar2 is
	Begin
	 return BUDGET_NAME;
	 END;
 Function DAS_NAME_p return varchar2 is
	Begin
	 return DAS_NAME;
	 END;
 Function WHERE_DAS_p return varchar2 is
	Begin
	 return WHERE_DAS;
	 END;
END GL_GLXRBJRN_XMLP_PKG ;


/
