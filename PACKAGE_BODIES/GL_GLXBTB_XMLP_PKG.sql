--------------------------------------------------------
--  DDL for Package Body GL_GLXBTB_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_GLXBTB_XMLP_PKG" AS
/* $Header: GLXBTBB.pls 120.0 2007/12/27 14:47:46 vijranga noship $ */
function period_act_balformula(END_BAL in number, BEGIN_BAL in number) return number is
begin
 return (END_BAL - BEGIN_BAL);
end;
function BUDGET_NAMEFormula return VARCHAR2 is
begin
declare
  name     VARCHAR2(15);
  errbuf   VARCHAR2(132);
  errbuf2  VARCHAR2(132);
begin
  gl_info.gl_get_bud_or_enc_name('B',
                                 P_BUDGET_VERSION_ID,
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
  return(name);
end;
RETURN NULL;
end;
function disp_bal_lprompt_w_colonformul(DISP_BAL_LPROMPT in varchar2) return varchar2 is
begin
 return (DISP_BAL_LPROMPT || ':');
end;
function AfterReport return boolean is
begin
  /*srw.user_exit('FND SRWEXIT');*/null;
  return (TRUE);
end;
function BeforeReport return boolean is
begin
/*srw.user_exit('FND SRWINIT');*/null;
declare
  errbuf            VARCHAR2(132);
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
end;
/*srw.reference(STRUCT_NUM);*/null;
 null;
/*srw.reference(STRUCT_NUM);*/null;
 null;
/*srw.reference(STRUCT_NUM);*/null;
 null;
/*srw.reference(STRUCT_NUM);*/null;
 null;
/*srw.reference(STRUCT_NUM);*/null;
 null;
/*srw.reference(STRUCT_NUM);*/null;
 null;
WHERE_DAS := GL_ACCESS_SET_SECURITY_PKG.GET_SECURITY_CLAUSE(
                P_ACCESS_SET_ID,
                'R',
                'LEDGER_COLUMN',
                'LEDGER_ID',
                'BE',
                'SEG_COLUMN',
                null,
                'CC',
                null);
if (WHERE_DAS is not null) then
  WHERE_DAS := ' and ' || WHERE_DAS ;
end if;
if (P_CURRENCY_TYPE = 'T') then
  TRANS_CHECK_BB := ' (bb.translated_flag in (''Y'', ''N'') or' ||
                     ' bb.translated_flag is null) ';
  TRANS_CHECK_BE := ' (be.translated_flag in (''Y'', ''N'') or' ||
                     ' be.translated_flag is null) ';
  RESULTING_CURRENCY := P_LEDGER_CURRENCY;
elsif (P_CURRENCY_TYPE = 'E') then
  TRANS_CHECK_BB := ' (nvl(bb.translated_flag (+), ''R'') = ''R'') ';
  TRANS_CHECK_BE := ' (be.translated_flag is null OR be.translated_flag = ''R'') ';
  RESULTING_CURRENCY := P_ENTERED_CURRENCY;
else
  TRANS_CHECK_BB := ' bb.translated_flag (+) is null ';
  TRANS_CHECK_BE := ' be.translated_flag is null ';
  RESULTING_CURRENCY := P_ENTERED_CURRENCY;
end if;
  return (TRUE);
end;
function g_balancesgroupfilter(FLEX_SECURE in varchar2, BEGIN_BAL in number, END_BAL in number) return boolean is
begin
  /*srw.reference(STRUCT_NUM);*/null;
  /*srw.reference(FLEXDATA);*/null;
  if (FLEX_SECURE ='S') then
   return (FALSE);
  end if;
  IF (NVL(BEGIN_BAL, 0) <> 0) THEN
    RETURN(TRUE);
  ELSIF (NVL(END_BAL, 0) <> 0) THEN
    RETURN(TRUE);
  ELSE
    RETURN(FALSE);
END IF;  return (TRUE);
end;
function g_page_breakgroupfilter(BAL_SECURE in varchar2) return boolean is
begin
  /*srw.reference(BAL_DATA);*/null;
  if(BAL_SECURE = 'S') then
      return (FALSE);
  else
      return (TRUE);
  end if;
RETURN NULL; end;
function g_acct_datagroupfilter(ACCT_SECURE in varchar2) return boolean is
begin
  /*srw.reference(ACCTDATA);*/null;
  if (ACCT_SECURE = 'S') then
     return(FALSE);
  else
     return (TRUE);
  end if;
RETURN NULL; end;
function LEDGER_NAMEFormula return VARCHAR2 is
ledgername VARCHAR2(30);
  errbuf     VARCHAR2(132);
begin
  SELECT target_ledger_name
  INTO   ledgername
  FROM   gl_ledger_relationships
  WHERE  source_ledger_id = P_LEDGER_ID
  AND    target_ledger_id = P_LEDGER_ID
  AND    target_currency_code = P_LEDGER_CURRENCY;
  return (ledgername);
exception
  WHEN OTHERS THEN
    errbuf := SQLERRM;
    /*srw.message('00', errbuf);*/null;
    raise_application_error(-20101,null);/*srw.program_abort;*/null;
end;
--Functions to refer Oracle report placeholders--
 Function STRUCT_NUM_p return varchar2 is
	Begin
	 return STRUCT_NUM;
	 END;
 Function ACCESS_SET_NAME_p return varchar2 is
	Begin
	 return ACCESS_SET_NAME;
	 END;
 Function SELECT_BAL_p return varchar2 is
	Begin
	 return SELECT_BAL;
	 END;
 Function SELECT_ALL_p return varchar2 is
	Begin
	 return SELECT_ALL;
	 END;
 Function ORDERBY_BAL_p return varchar2 is
	Begin
	 return ORDERBY_BAL;
	 END;
 Function ORDERBY_ACCT_p return varchar2 is
	Begin
	 return ORDERBY_ACCT;
	 END;
 Function ORDERBY_ALL_p return varchar2 is
	Begin
	 return ORDERBY_ALL;
	 END;
 Function SELECT_ACCT_p return varchar2 is
	Begin
	 return SELECT_ACCT;
	 END;
 Function TRANS_CHECK_BB_p return varchar2 is
	Begin
	 return TRANS_CHECK_BB;
	 END;
 Function TRANS_CHECK_BE_p return varchar2 is
	Begin
	 return TRANS_CHECK_BE;
	 END;
 Function WHERE_DAS_p return varchar2 is
	Begin
	 return WHERE_DAS;
	 END;
 Function RESULTING_CURRENCY_p return varchar2 is
	Begin
	 return RESULTING_CURRENCY;
	 END;
END GL_GLXBTB_XMLP_PKG ;


/
