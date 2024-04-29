--------------------------------------------------------
--  DDL for Package Body GL_GLXRBCR_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_GLXRBCR_XMLP_PKG" AS
/* $Header: GLXRBCRB.pls 120.0 2007/12/27 15:01:37 vijranga noship $ */

function AfterReport return boolean is
begin
  /*srw.user_exit('FND SRWEXIT');*/null;

  return (TRUE);
end;

function available_budgetformula(MASTER_BUDGET_BAL in number, TOTAL_DETAIL_BAL in number) return number is
begin
  return (MASTER_BUDGET_BAL - TOTAL_DETAIL_BAL);
end;

function MASTER_BUDGET_NAMEFormula return VARCHAR2 is
name     VARCHAR2(15);
  errbuf   VARCHAR2(132);
  errbuf2  VARCHAR2(132);
begin
  gl_info.gl_get_bud_or_enc_name('B', P_BUDGET_VERSION_ID,
                                 name, errbuf);

  if (errbuf is not null) then

    errbuf2 := gl_message.get_message(
                 'GL_PLL_ROUTINE_ERROR', 'N',
                 'ROUTINE','gl_get_bud_or_enc_name'
               );
    /*srw.message('00', errbuf2);*/null;

    /*srw.message('00', errbuf);*/null;

    raise_application_error(-20101,null);/*srw.program_abort;*/null;

  end if;

  return (name);
end;

function BeforeReport return boolean is
out_ptd_ytd            VARCHAR2(240);
  errbuf                 VARCHAR2(132);
begin
  /*srw.user_exit('FND SRWINIT');*/null;


  begin
    SELECT name, chart_of_accounts_id
    INTO   ACCESS_SET_NAME, CHART_OF_ACCOUNTS_ID
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

    gl_info.gl_get_lookup_value('D',
                      P_PERIOD_TYPE,
                      'PTD_YTD',
                      out_ptd_ytd,
                      errbuf);
  if (errbuf is not NULL) then
    /*SRW.MESSAGE(0, errbuf);*/null;

    raise_application_error(-20101,null);/*SRW.PROGRAM_ABORT;*/null;

  else
    PTD_YTD_DSP := out_ptd_ytd;
  end if;

  /*srw.reference(CHART_OF_ACCOUNTS_ID);*/null;


 null;


 null;

  IF P_PERIOD_TYPE = 'PTD' THEN
    SELECT_MASTER_BUDGET :=
      'nvl(bm.period_net_dr, 0) - nvl(bm.period_net_cr, 0)';
    SELECT_DETAIL_BUDGET :=
      'nvl(bd.period_net_dr, 0) - nvl(bd.period_net_cr, 0)';

  ELSIF P_PERIOD_TYPE = 'YTD' THEN
    SELECT_MASTER_BUDGET :=
      'nvl(bm.begin_balance_dr, 0) + nvl(bm.period_net_dr, 0) -
       nvl(bm.begin_balance_cr, 0) - nvl(bm.period_net_cr, 0)';
    SELECT_DETAIL_BUDGET :=
      'nvl(bd.begin_balance_dr, 0) + nvl(bd.period_net_dr, 0) -
       nvl(bd.begin_balance_cr, 0) - nvl(bd.period_net_cr, 0)';

  ELSIF P_PERIOD_TYPE = 'QTD' THEN
    SELECT_MASTER_BUDGET :=
      'nvl(bm.quarter_to_date_dr, 0) + nvl(bm.period_net_dr, 0) -
       nvl(bm.quarter_to_date_cr, 0) - nvl(bm.period_net_cr, 0)';
    SELECT_DETAIL_BUDGET :=
      'nvl(bd.quarter_to_date_dr, 0) + nvl(bd.period_net_dr, 0) -
       nvl(bd.quarter_to_date_cr, 0) - nvl(bd.period_net_cr, 0)';

  ELSE
    SELECT_MASTER_BUDGET :=
      'nvl(bm.project_to_date_dr, 0) + nvl(bm.period_net_dr, 0) -
       nvl(bm.project_to_date_cr, 0) - nvl(bm.period_net_cr, 0)';
    SELECT_DETAIL_BUDGET :=
      'nvl(bd.project_to_date_dr, 0) + nvl(bd.period_net_dr, 0) -
       nvl(bd.project_to_date_cr, 0) - nvl(bd.period_net_cr, 0)';

  END IF;

  WHERE_DAS := GL_ACCESS_SET_SECURITY_PKG.GET_SECURITY_CLAUSE(
                  P_ACCESS_SET_ID,
                  'R',
                  'LEDGER_ID',
                  P_LEDGER_ID,
                  null,
                  'SEG_COLUMN',
                  null,
                  'CC',
                  null);

  if (WHERE_DAS is not null) then
    WHERE_DAS := ' and ' || WHERE_DAS;
  end if;
  if (WHERE_DAS is null) then
    WHERE_DAS := 'AND 1=1';
  end if;

  return (TRUE);
end;

--Functions to refer Oracle report placeholders--

 Function CHART_OF_ACCOUNTS_ID_p return varchar2 is
	Begin
	 return CHART_OF_ACCOUNTS_ID;
	 END;
 Function ORDERBY_FLEX_p return varchar2 is
	Begin
	 return ORDERBY_FLEX;
	 END;
 Function SELECT_FLEX_p return varchar2 is
	Begin
	 return SELECT_FLEX;
	 END;
 Function LEDGER_NAME_p return varchar2 is
	Begin
	 return LEDGER_NAME;
	 END;
 Function SELECT_MASTER_BUDGET_p return varchar2 is
	Begin
	 return SELECT_MASTER_BUDGET;
	 END;
 Function SELECT_DETAIL_BUDGET_p return varchar2 is
	Begin
	 return SELECT_DETAIL_BUDGET;
	 END;
 Function ACCESS_SET_NAME_p return varchar2 is
	Begin
	 return ACCESS_SET_NAME;
	 END;
 Function WHERE_DAS_p return varchar2 is
	Begin
	 return WHERE_DAS;
	 END;
 Function PTD_YTD_DSP_p return varchar2 is
	Begin
	 return PTD_YTD_DSP;
	 END;
END GL_GLXRBCR_XMLP_PKG ;


/
