--------------------------------------------------------
--  DDL for Package Body GL_GLYRLJGE_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_GLYRLJGE_XMLP_PKG" AS
/* $Header: GLYRLJGEB.pls 120.2 2008/06/25 11:44:46 vijranga noship $ */
function BeforeReport return boolean is
coaid         NUMBER;
  ledgername    VARCHAR2(30);
  func_curr     VARCHAR2(15);
  currency_name VARCHAR2(30);
  errbuf        VARCHAR2(132);
  errbuf2       VARCHAR2(132);
  start_date    DATE;
  end_date      DATE;
  dummy		DATE;
  fiscal_year_s VARCHAR2(15) :='1900';
  fiscal_year_e VARCHAR2(15) :='1900';
  per_type      VARCHAR2(15);
  per_set       VARCHAR2(15);
begin
  /*SRW.USER_EXIT('FND SRWINIT');*/null;
  begin
    SELECT name, chart_of_accounts_id
    INTO   C_ACCESS_SET_NAME, C_CHART_OF_ACCTS_ID
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
  C_START_DATE := to_date(substr(P_START_PERIOD,1,10),'yyyy/mm/dd');
  C_END_DATE := to_date(substr(P_END_PERIOD,1,10),'yyyy/mm/dd');
  C_START_DATE1 := to_char(C_START_DATE,'DD-MON-YYYY');
  C_END_DATE1 := to_char(C_END_DATE,'DD-MON-YYYY');
  P_STRUCT_NUM := C_CHART_OF_ACCTS_ID;
    C_ACCESS_WHERE := GL_ACCESS_SET_SECURITY_PKG.GET_SECURITY_CLAUSE(
                  P_ACCESS_SET_ID,
                  'R',
                  'LEDGER_COLUMN',
                  'LEDGER_ID',
                  'T2',                    'SEG_COLUMN',
                  null,
                  'T4',                    null);
  IF (C_ACCESS_WHERE is not null) THEN
    C_ACCESS_WHERE := ' AND ' || C_ACCESS_WHERE;
  END IF;
  C_LEDGER_FROM := '';
  C_LEDGER_WHERE := '';
  IF P_LEDGER_ID IS NOT NULL THEN
    begin
      SELECT name, currency_code, object_type_code, consolidation_ledger_flag,
             period_set_name, accounted_period_type
      INTO   PARAM_LEDGER_NAME, PARAM_LEDGER_CURR,
             PARAM_LEDGER_TYPE, CONSOLIDATION_LEDGER_FLAG,
             per_set, per_type
      FROM   gl_ledgers
      WHERE  ledger_id = P_LEDGER_ID;
    exception
      WHEN OTHERS THEN
        errbuf := SQLERRM;
        /*srw.message('00', errbuf);*/null;
        raise_application_error(-20101,null);/*srw.program_abort;*/null;
    end;
    IF (PARAM_LEDGER_TYPE = 'S') THEN        C_LEDGER_FROM := 'GL_LEDGER_SET_ASSIGNMENTS LS,';
      C_LEDGER_WHERE := ' AND LS.ledger_set_id = ' || to_char(P_LEDGER_ID) || ' AND ' ||
                       'T2.ledger_id = LS.ledger_id';
    ELSE
      C_LEDGER_FROM := '';
      C_LEDGER_WHERE := ' AND T2.ledger_id = ' || to_char(P_LEDGER_ID);
    END IF;
  ELSE
    BEGIN
      SELECT PERIOD_SET_NAME, ACCOUNTED_PERIOD_TYPE
      INTO per_set, per_type
      FROM GL_ACCESS_SETS
      WHERE ACCESS_SET_ID = P_ACCESS_SET_ID;
    exception
      WHEN NO_DATA_FOUND THEN
        errbuf := gl_message.get_message('GL_PLL_INVALID_DATA_ACCESS_SET', 'Y',
                                              'DASID', to_char(P_ACCESS_SET_ID));          /*srw.message('00', errbuf);*/null;
        raise_application_error(-20101,null);/*srw.program_abort;*/null;
      WHEN OTHERS THEN
        errbuf := SQLERRM;
        /*srw.message('00', errbuf);*/null;
        raise_application_error(-20101,null);/*srw.program_abort;*/null;
    END;
  END IF;
	IF (C_LEDGER_FROM IS NULL) THEN
		C_LEDGER_FROM := ' ';
	END IF;
  IF (PARAM_LEDGER_TYPE = 'S') THEN
    begin
      SELECT consolidation_ledger_flag
      INTO CONSOLIDATION_LEDGER_FLAG
      FROM gl_system_usages;
    exception
      WHEN OTHERS THEN
        errbuf := SQLERRM;
        /*srw.message('00', errbuf);*/null;
        raise_application_error(-20101,null);/*srw.program_abort;*/null;
    end;
  END IF;
  IF (PARAM_LEDGER_TYPE = 'S') THEN
    begin
      SELECT substr(ltrim(to_char(11, '9G9')), 2, 1)
      INTO   THOUSANDS_SEPARATOR
      FROM   dual;
    exception
      WHEN OTHERS THEN
        errbuf := SQLERRM;
        /*srw.message('00', errbuf);*/null;
        raise_application_error(-20101,null);/*srw.program_abort;*/null;
    end;
    MIXED_PRECISION := to_number(FND_PROFILE.value('CURRENCY:MIXED_PRECISION'));
    FND_CURRENCY.build_format_mask(CURR_FORMAT_MASK, 38, MIXED_PRECISION, null);
    CURR_FORMAT_MASK := REPLACE(CURR_FORMAT_MASK, 'FM');
    CURR_FORMAT_MASK := REPLACE(CURR_FORMAT_MASK, 'FX');
  END IF;
  C_MESSAGE := '';
  if (P_END_PERIOD is null) then
    C_END_DATE := C_START_DATE;
  end if;
  begin
        select t.period_year
        into   fiscal_year_s
        from   gl_periods t
        where  t.period_set_name = per_set
        and    t.period_type = per_type
        and    C_START_DATE between t.start_date and t.end_date
        and    t.adjustment_period_flag like
			decode(P_ADJUSTMENT_PERIODS,'N','N',
							 '%')
        and    rownum = 1;
        select t.period_year
        into   fiscal_year_e
        from   gl_periods t
        where  t.period_set_name = per_set
        and    t.period_type = per_type
        and    C_END_DATE between t.start_date and t.end_date
        and    t.adjustment_period_flag like
			decode(P_ADJUSTMENT_PERIODS,'N','N',
							 '%')
        and    rownum = 1;
  exception
       when no_data_found
          then
       errbuf2 := gl_message.get_message(
                 'GL_PLL_ROUTINE_ERROR', 'N',
                 'ROUTINE','Check dates available'
              );
       /*srw.message('00', errbuf2);*/null;
       raise_application_error(-20101,null);/*srw.program_abort;*/null;
  end;
  C_WHERE_PERIOD := '';
  if P_ADJUSTMENT_PERIODS = 'N' then
    if (fiscal_year_s <> fiscal_year_e) then
       C_MESSAGE := 'This report was run across a fiscal year';
    end if;
    C_WHERE_PERIOD := ' and T6.adjustment_period_flag = ''N''';
  end if;
	IF (C_WHERE_PERIOD IS NULL) THEN
		C_WHERE_PERIOD := ' ';
	END IF;
  C_WHERE := '';
  /*SRW.REFERENCE(P_STRUCT_NUM);*/null;
 null;
  /*srw.reference(P_STRUCT_NUM);*/null;
 null;
  /*srw.reference(P_STRUCT_NUM);*/null;
 null;
  if P_COMPANY is not null then
     /*SRW.REFERENCE(P_STRUCT_NUM);*/null;
 null;
    -- C_WHERE := ' AND ' || C_WHERE;
  end if;
  if P_JOURNAL_CAT is not null then
     	P_JOURNAL_CAT_1 := replace(P_JOURNAL_CAT,'''');
	C_WHERE := C_WHERE||' and replace(T2.je_category,'''''''') like '''||P_JOURNAL_CAT_1||'''';
  end if;
  if P_CURRENCY_CODE is not null then
       C_WHERE := C_WHERE||' and T2.currency_code = '''||P_CURRENCY_CODE||'''';
  else
       C_WHERE := C_WHERE||' and T2.currency_code <> ''STAT''';
  end if;
   get_industry_code ;
return (TRUE);
end;
function AfterReport return boolean is
begin
  /*SRW.USER_EXIT('FND SRWEXIT');*/null;
  return (TRUE);
end;
function c_curr_nameformula(currency1 in varchar2) return varchar2 is
begin
declare
  cursor get_curr_name is
  select name
  from fnd_currencies_vl
  where currency_code = currency1;
  curr_name varchar(80);
begin
  open get_curr_name;
  fetch get_curr_name into curr_name;
  close get_curr_name;
  return(curr_name);
end;
RETURN NULL; end;
function c_bal_lpromptformula(C_Bal_lprompt in varchar2) return varchar2 is
begin
/*srw.reference(C_Company_name) ;*/null;
declare
    temp_char   varchar2 (60) ;
begin
    temp_char := initcap(substr(C_Bal_lprompt, 1,16))||':' ;
    return(temp_char) ;
end ;
RETURN NULL; end;
function set_display_for_core return boolean is
begin
if c_industry_code = 'C' then
   return(TRUE);
else
   return(FALSE);
end if;
RETURN NULL; end;
function set_display_for_gov return boolean is
begin
if c_industry_code = 'C' then
   return(FALSE);
else
   return(TRUE);
end if;
RETURN NULL; end ;
procedure get_industry_code is
w_industry_code varchar2(20);
w_industry_stat varchar2(20);
begin
if fnd_installation.get(0, 0,
                        w_industry_stat,
	    	        w_industry_code) then
   if w_industry_code = 'C' then
      c_industry_code :=   w_industry_code ;
   end if;
end if;
end ;
function c_entryformula(doc_sequence in number, entry_name in varchar2) return varchar2 is
begin
if doc_sequence is NOT NULL then
   return(substr(to_char(doc_sequence),1,7));
else
   return(substr(entry_name,1,7));
end if;
RETURN NULL; end;
function g_journalgroupfilter(FLEX_SECURE in varchar2, ACCOUNTED_CR in number, ACCOUNTED_DR in number, ENTERED_DR in number, ENTERED_CR in number) return boolean is
begin
  /*srw.reference(P_STRUCT_NUM);*/null;
  /*srw.reference(C_FLEXDATA);*/null;
  if(FLEX_SECURE = 'S') then
     return(FALSE);
  else
     return (TRUE);
  end if;
  IF ACCOUNTED_CR <> 0 OR
     ACCOUNTED_DR <> 0 OR
     ENTERED_DR <> 0 OR
     ENTERED_CR <> 0 THEN
     RETURN(TRUE);
  ELSE
     RETURN(FALSE);
  END IF;
  return (TRUE);
end;
function g_company_mastergroupfilter(BAL_SECURE in varchar2) return boolean is
begin
  /*SRW.REFERENCE(Company);*/null;
  if(BAL_SECURE = 'S') then
     return(FALSE);
  else
     return (TRUE);
  end if;
end;
function BetweenPage return boolean is
begin
  return (TRUE);
end;
--function gl_format_currency(amount number)(Amount  NUMBER) return varchar2 is
function gl_format_currency(amount number)return varchar2 is
  num_amount   NUMBER;
  dsp_amount   VARCHAR2(100);
BEGIN
  num_amount := ROUND(Amount, MIXED_PRECISION);
  dsp_amount := LTRIM(TO_CHAR(num_amount, CURR_FORMAT_MASK));
  IF (LENGTH(dsp_amount) > WIDTH) THEN
    dsp_amount := REPLACE(dsp_amount, ' ');
    IF (LENGTH(dsp_amount) > WIDTH) THEN
      dsp_amount := REPLACE(dsp_amount, THOUSANDS_SEPARATOR);
      IF (LENGTH(dsp_amount) > WIDTH) THEN
        dsp_amount := RPAD('*', WIDTH, '*');
      END IF;
    END IF;
  END IF;
  RETURN dsp_amount;
END;
function company_lprompt_ndformula(COMPANY_LPROMPT_ND in varchar2) return char is
begin
/*srw.reference(COMPANY_NAME_ND);*/null;
declare
    temp_char  VARCHAR2(240);
begin
    temp_char := COMPANY_LPROMPT_ND||':' ;
    return(temp_char) ;
end ;
RETURN NULL; end;
function zero_indicatorformula(ACCOUNTED_CR in number, ACCOUNTED_DR in number, ENTERED_DR in number, ENTERED_CR in number) return number is
begin
  IF (ACCOUNTED_CR <> 0 OR
     ACCOUNTED_DR <> 0 OR
     ENTERED_DR <> 0 OR
     ENTERED_CR <> 0) THEN
     RETURN(1);
  ELSE
     RETURN(0);
  END IF;
 return null;
end;
function C_MESSAGEFormula return Char is
begin
 return('Period is across the year');
end;
function g_journal_entriesgroupfilter(ACCOUNTED_CR in number, ACCOUNTED_DR in number, ENTERED_DR in number, ENTERED_CR in number) return boolean is
begin
  IF ACCOUNTED_CR <> 0 OR
     ACCOUNTED_DR <> 0 OR
     ENTERED_DR <> 0 OR
     ENTERED_CR <> 0 THEN
     RETURN(TRUE);
  ELSE
     RETURN(FALSE);
  END IF;
  return (TRUE);
end;
function g_batchesgroupfilter(ACCOUNTED_CR in number, ACCOUNTED_DR in number, ENTERED_DR in number, ENTERED_CR in number) return varchar2 is
begin
  IF ACCOUNTED_CR <> 0 OR
     ACCOUNTED_DR <> 0 OR
     ENTERED_DR <> 0 OR
     ENTERED_CR <> 0 THEN
     RETURN('TRUE');
  ELSE
     RETURN('FALSE');
  END IF;
  return ('TRUE');
end;
--Functions to refer Oracle report placeholders--
 Function C_WHERE_p return varchar2 is
	Begin
	 return C_WHERE;
	 END;
 Function C_CHART_OF_ACCTS_ID_p return varchar2 is
	Begin
	 return C_CHART_OF_ACCTS_ID;
	 END;
 Function C_START_DATE_p return date is
	Begin
	 return C_START_DATE;
	 END;
 Function C_END_DATE_p return date is
	Begin
	 return C_END_DATE;
	 END;
 Function C_MESSAGE_p return varchar2 is
	Begin
	 return C_MESSAGE;
	 END;
 Function C_industry_code_p return varchar2 is
	Begin
	 return C_industry_code;
	 END;
 Function C_WHERE_PERIOD_p return varchar2 is
	Begin
	 return C_WHERE_PERIOD;
	 END;
 Function C_ACCESS_SET_NAME_p return varchar2 is
	Begin
	 return C_ACCESS_SET_NAME;
	 END;
 Function C_ACCESS_WHERE_p return varchar2 is
	Begin
	 return C_ACCESS_WHERE;
	 END;
 Function C_LEDGER_FROM_p return varchar2 is
	Begin
	 return C_LEDGER_FROM;
	 END;
 Function C_LEDGER_WHERE_p return varchar2 is
	Begin
	 return C_LEDGER_WHERE;
	 END;
 Function PARAM_LEDGER_TYPE_p return varchar2 is
	Begin
	 return PARAM_LEDGER_TYPE;
	 END;
 Function PARAM_LEDGER_NAME_p return varchar2 is
	Begin
	 return PARAM_LEDGER_NAME;
	 END;
 Function PARAM_LEDGER_CURR_p return varchar2 is
	Begin
	 return PARAM_LEDGER_CURR;
	 END;
 Function CONSOLIDATION_LEDGER_FLAG_p return varchar2 is
	Begin
	 return CONSOLIDATION_LEDGER_FLAG;
	 END;
 Function CURR_FORMAT_MASK_p return varchar2 is
	Begin
	 return CURR_FORMAT_MASK;
	 END;
 Function MIXED_PRECISION_p return number is
	Begin
	 return MIXED_PRECISION;
	 END;
 Function THOUSANDS_SEPARATOR_p return varchar2 is
	Begin
	 return THOUSANDS_SEPARATOR;
	 END;
 Function WIDTH_p return number is
	Begin
	 return WIDTH;
	 END;
END GL_GLYRLJGE_XMLP_PKG ;


/
