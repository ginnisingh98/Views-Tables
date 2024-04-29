--------------------------------------------------------
--  DDL for Package Body GL_GLXRLHST_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_GLXRLHST_XMLP_PKG" AS
/* $Header: GLXRLHSTB.pls 120.0 2007/12/27 15:14:09 vijranga noship $ */

function BeforeReport return boolean is
errbuf  VARCHAR2(132);
  errbuf2 VARCHAR2(132);
begin
  /*srw.user_exit('FND SRWINIT');*/null;



  declare
    coa_id       NUMBER;
    --ledger_name  VARCHAR2( 30 );
    l_ledger_name  VARCHAR2( 30 );
    func_curr    VARCHAR2( 15 );
  begin
    gl_info.gl_get_ledger_info( P_LEDGER_ID,
                                coa_id,
                                --ledger_name,
				l_ledger_name,
                                func_curr,
                                errbuf );


    if (errbuf is not null) then
      errbuf2 := gl_message.get_message(
                 'GL_PLL_ROUTINE_ERROR',
                 'N',
                 'ROUTINE',
                 'gl_info.gl_get_ledger_info' );
      /*srw.message('00', errbuf2);*/null;

      /*srw.message('00', errbuf);*/null;

      raise_application_error(-20101,null);/*srw.program_abort;*/null;

    end if;

    STRUCT_NUM := coa_id;
    --LEDGER_NAME := ledger_name;
    LEDGER_NAME := l_ledger_name;
    FUNCTIONAL_CURRENCY := func_curr;

    select enable_average_balances_flag
    into AVERAGE_BALANCES_FLAG
    from gl_ledgers
    where ledger_id = P_LEDGER_ID;

  end;


  begin
    SELECT effective_period_num
    INTO   FROM_EFF_PERIOD_NUM
    FROM   gl_period_statuses
    WHERE  application_id = 101
    AND    ledger_id = P_LEDGER_ID
    AND    period_name = P_FROM_PERIOD;

    SELECT effective_period_num
    INTO   TO_EFF_PERIOD_NUM
    FROM   gl_period_statuses
    WHERE  application_id = 101
    AND    ledger_id = P_LEDGER_ID
    AND    period_name = P_TO_PERIOD;
  exception
    WHEN OTHERS THEN
      errbuf := SQLERRM;
      /*srw.message('00', errbuf);*/null;

      raise_application_error(-20101,null);/*srw.program_abort;*/null;

  end;


  WHERE_DAS := GL_ACCESS_SET_SECURITY_PKG.GET_SECURITY_CLAUSE(
                  P_ACCESS_SET_ID,
                  'R',
                  'LEDGER_ID',
                  P_LEDGER_ID,
                  null,
                  'SEG_COLUMN',
                  null,
                  'GCC',
                  null);

  if (WHERE_DAS is not null) then
    WHERE_DAS := ' and ' || WHERE_DAS;
  end if;

  if (WHERE_DAS is null) then
    WHERE_DAS := ' ';
  end if;

  /*srw.reference( STRUCT_NUM );*/null;


 null;

  /*srw.reference( STRUCT_NUM );*/null;


 null;

  /*srw.reference( STRUCT_NUM );*/null;


 null;

  /*srw.reference( STRUCT_NUM );*/null;


 null;

  /*srw.reference( STRUCT_NUM );*/null;


 null;

  /*srw.reference( STRUCT_NUM );*/null;


 null;

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
 Function FLEX_SELECT_BAL_p return varchar2 is
	Begin
	 return FLEX_SELECT_BAL;
	 END;
 Function FLEX_ORDERBY_BAL_D_p return varchar2 is
	Begin
	 return FLEX_ORDERBY_BAL_D;
	 END;
 Function FLEX_SELECT_ACCT_p return varchar2 is
	Begin
	 return FLEX_SELECT_ACCT;
	 END;
 Function FLEX_ORDERBY_ACCT_D_p return varchar2 is
	Begin
	 return FLEX_ORDERBY_ACCT_D;
	 END;
 Function FLEX_ORDERBY_BAL_I_p return varchar2 is
	Begin
	 return FLEX_ORDERBY_BAL_I;
	 END;
 Function FLEX_ORDERBY_ACCT_I_p return varchar2 is
	Begin
	 return FLEX_ORDERBY_ACCT_I;
	 END;
 Function AVERAGE_BALANCES_FLAG_p return varchar2 is
	Begin
	 return AVERAGE_BALANCES_FLAG;
	 END;
 Function WHERE_DAS_p return varchar2 is
	Begin
	 return WHERE_DAS;
	 END;
 Function FROM_EFF_PERIOD_NUM_p return number is
	Begin
	 return FROM_EFF_PERIOD_NUM;
	 END;
 Function TO_EFF_PERIOD_NUM_p return number is
	Begin
	 return TO_EFF_PERIOD_NUM;
	 END;
 Function FUNCTIONAL_CURRENCY_p return varchar2 is
	Begin
	 return FUNCTIONAL_CURRENCY;
	 END;
END GL_GLXRLHST_XMLP_PKG ;


/
