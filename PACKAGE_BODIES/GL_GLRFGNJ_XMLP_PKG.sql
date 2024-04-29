--------------------------------------------------------
--  DDL for Package Body GL_GLRFGNJ_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_GLRFGNJ_XMLP_PKG" AS
/* $Header: GLRFGNJB.pls 120.0 2007/12/27 14:35:21 vijranga noship $ */
function BeforeReport return boolean is
t_debit                VARCHAR2(240);
  t_credit               VARCHAR2(240);
  t_errorbuffer          VARCHAR2(132);
begin
  /*srw.user_exit('FND SRWINIT');*/null;
      INV_FLEX_MSG      := gl_message.get_message(
                       'GL_PLL_INVALID_FLEXFIELD','N');
      STAT:= FND_CURRENCY.GET_FORMAT_MASK('STAT',19);
  begin
    SELECT name, chart_of_accounts_id
    INTO   ACCESS_SET_NAME, STRUCT_NUM
    FROM   gl_access_sets
    WHERE  access_set_id = P_ACCESS_SET_ID;
  exception
    WHEN NO_DATA_FOUND THEN
      t_errorbuffer := gl_message.get_message('GL_PLL_INVALID_DATA_ACCESS_SET', 'Y',
                                              'DASID', to_char(P_ACCESS_SET_ID));
      /*srw.message('00', t_errorbuffer);*/null;
      raise_application_error(-20101,null);/*srw.program_abort;*/null;
    WHEN OTHERS THEN
      t_errorbuffer := SQLERRM;
      /*srw.message('00', t_errorbuffer);*/null;
      raise_application_error(-20101,null);/*srw.program_abort;*/null;
  end;
  gl_info.gl_get_lookup_value('D',
                      'D',
                      'DR_CR',
                      t_debit,
                      t_errorbuffer);
  if (t_errorbuffer is not NULL) then
     /*SRW.MESSAGE(0,t_errorbuffer);*/null;
     raise_application_error(-20101,null);/*SRW.PROGRAM_ABORT;*/null;
  else
     DEBIT_DSP := t_debit;
  end if;
  gl_info.gl_get_lookup_value('D',
                      'C',
                      'DR_CR',
                      t_credit,
                      t_errorbuffer);
  if (t_errorbuffer is not NULL) then
     /*SRW.MESSAGE(0,t_errorbuffer);*/null;
     raise_application_error(-20101,null);/*SRW.PROGRAM_ABORT;*/null;
  else
     CREDIT_DSP := t_credit;
  end if;
          /*SRW.REFERENCE(STRUCT_NUM);*/null;
 null;
      IF (P_KIND = 'S') THEN
     POSTING_STATUS_SELECT := 'J.reference_4';
  ELSE
     POSTING_STATUS_SELECT := 'J.reference_1';
  END IF;
      IF (P_POSTING_STATUS = 'E') THEN
     POSTING_STATUS_WHERE := 'B.status NOT in (''S'',''I'',''U'',''P'')';
  ELSE
     POSTING_STATUS_WHERE :=
     'B.status = ' || '''' || P_POSTING_STATUS || '''';
  END IF;
        IF (P_PERIOD_NAME IS NOT NULL) THEN
   PERIOD_WHERE := 'B.default_period_name = ''' || P_PERIOD_NAME || '''';
  ELSE
    IF (P_POSTING_STATUS = 'P') THEN
      IF (P_START_DATE IS NOT NULL AND P_END_DATE IS NOT NULL) THEN
        PERIOD_WHERE := 'trunc(B.posted_date) between to_date(' || '''' || to_char(P_START_DATE,'DD-MON-YYYY') || '''' || ',''DD-MON-YYYY'') AND to_date(' || '''' || to_char(P_END_DATE,'DD-MON-YYYY') || '''' || ',''DD-MON-YYYY'')';
      ELSIF (P_START_DATE IS NOT NULL) THEN
        PERIOD_WHERE := 'trunc(B.posted_date) >= to_date(' || '''' || to_char(P_START_DATE,'DD-MON-YYYY') || '''' || ',''DD-MON-YYYY'')';
      ELSIF (P_END_DATE IS NOT NULL) THEN
        PERIOD_WHERE := 'trunc(B.posted_date) <= to_date(' || '''' || to_char(P_END_DATE,'DD-MON-YYYY') || '''' || ',''DD-MON-YYYY'')';
      END IF;
    ELSE
      IF (P_START_DATE IS NOT NULL AND P_END_DATE IS NOT NULL) THEN
      PERIOD_WHERE := 'trunc(D.DEFAULT_EFFECTIVE_DATE) between to_date(' || '''' || to_char(P_START_DATE,'DD-MON-YYYY') || '''' || ',''DD-MON-YYYY'') and to_date(' || '''' || to_char(P_END_DATE,'DD-MON-YYYY') || '''' || ',''DD-MON-YYYY'')';
      ELSIF (P_START_DATE IS NOT NULL) THEN
         PERIOD_WHERE := 'trunc(D.DEFAULT_EFFECTIVE_DATE) >= to_date(' || '''' || to_char(P_START_DATE,'DD-MON-YYYY') || '''' || ',''DD-MON-YYYY'')';
      ELSIF (P_END_DATE IS NOT NULL) THEN
         PERIOD_WHERE := 'trunc(D.DEFAULT_EFFECTIVE_DATE) <= to_date(' || '''' || to_char(P_END_DATE,'DD-MON-YYYY') || '''' || ',''DD-MON-YYYY'')';
      END IF;
    END IF;
  END IF;
    DAS_WHERE := GL_ACCESS_SET_SECURITY_PKG.GET_SECURITY_CLAUSE(
                  P_ACCESS_SET_ID,
                  'R',
                  'LEDGER_COLUMN',
                  'LEDGER_ID',
                  'D',
                  'SEG_COLUMN',
                  null,
                  'CC',
                  null);
  IF (DAS_WHERE is not null) THEN
    DAS_WHERE := ' AND ' || DAS_WHERE;
  END IF;
  IF P_PAGESIZE = 180 THEN
    WIDTH := 19;
  ELSE
    WIDTH := 16;
  END IF;
  IF (P_LEDGER_ID IS NOT NULL) THEN
    begin
      SELECT name, currency_code, object_type_code, consolidation_ledger_flag
      INTO   PARAM_LEDGER_NAME, PARAM_LEDGER_CURR,
             PARAM_LEDGER_TYPE, CONSOLIDATION_LEDGER_FLAG
      FROM   gl_ledgers
      WHERE  ledger_id = P_LEDGER_ID;
    exception
      WHEN OTHERS THEN
        t_errorbuffer := SQLERRM;
        /*srw.message('00', t_errorbuffer);*/null;
        raise_application_error(-20101,null);/*srw.program_abort;*/null;
    end;
    IF (PARAM_LEDGER_TYPE = 'S') THEN
      LEDGER_FROM := 'GL_LEDGER_SET_ASSIGNMENTS LS,';
      LEDGER_WHERE := 'LS.ledger_set_id = ' || to_char(P_LEDGER_ID) || ' AND ' ||
                       'D.ledger_id = LS.ledger_id AND ';
    ELSE
      --LEDGER_FROM :=  '';
      LEDGER_FROM :=' ';
      LEDGER_WHERE := 'D.ledger_id = ' || to_char(P_LEDGER_ID) || ' AND ';
    END IF;
  END IF;
  IF (PARAM_LEDGER_TYPE = 'S') THEN
    begin
      SELECT consolidation_ledger_flag
      INTO CONSOLIDATION_LEDGER_FLAG
      FROM gl_system_usages;
    exception
      WHEN OTHERS THEN
        t_errorbuffer := SQLERRM;
        /*srw.message('00', t_errorbuffer);*/null;
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
        t_errorbuffer := SQLERRM;
        /*srw.message('00', t_errorbuffer);*/null;
        raise_application_error(-20101,null);/*srw.program_abort;*/null;
    end;
    MIXED_PRECISION := to_number(FND_PROFILE.value('CURRENCY:MIXED_PRECISION'));
    FND_CURRENCY.build_format_mask(CURR_FORMAT_MASK, 38, MIXED_PRECISION, null);
    CURR_FORMAT_MASK := REPLACE(CURR_FORMAT_MASK, 'FM');
    CURR_FORMAT_MASK := REPLACE(CURR_FORMAT_MASK, 'FX');
  END IF;
  return (TRUE);
end;
function AfterReport return boolean is
begin
  /*SRW.USER_EXIT('FND SRWEXIT');*/null;
  return (TRUE);
end;
function ent_x_drcrformula(DR_CR in number, ENTERED_AMOUNT in number) return number is
begin
  RETURN(DR_CR * ENTERED_AMOUNT);
end;
function acct_x_drcrformula(DR_CR in number, ACCOUNTED_AMOUNT in varchar2) return number is
begin
  RETURN(DR_CR * ACCOUNTED_AMOUNT);
end;
function dr_cr_dspformula(DR_CR in number) return varchar2 is
begin
  IF (DR_CR in (0,1)) THEN
    RETURN(DEBIT_DSP);
  ELSE
    RETURN(CREDIT_DSP);
  END IF;
  RETURN NULL;
end;
function g_linesgroupfilter(FLEXDATA_SECURE in varchar2) return boolean is
begin
  /*SRW.REFERENCE(STRUCT_NUM);*/null;
  /*SRW.REFERENCE(FLEXDATA_H);*/null;
  if (FLEXDATA_SECURE = 'S') then
    return (FALSE);
  else
    return (TRUE);
  end if;
  return (TRUE);
end;
--function gl_format_currency(amount number)(Amount  NUMBER) return varchar2 is
function gl_format_currency(amount IN number) return varchar2 is
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
--Functions to refer Oracle report placeholders--
 Function FLEXDATA_p return varchar2 is
	Begin
	 return FLEXDATA;
	 END;
 Function POSTING_STATUS_SELECT_p return varchar2 is
	Begin
	 return POSTING_STATUS_SELECT;
	 END;
 Function POSTING_STATUS_WHERE_p return varchar2 is
	Begin
	 return POSTING_STATUS_WHERE;
	 END;
 Function PERIOD_WHERE_p return varchar2 is
	Begin
	 return PERIOD_WHERE;
	 END;
 Function STRUCT_NUM_p return varchar2 is
	Begin
	 return STRUCT_NUM;
	 END;
 Function PARAM_LEDGER_NAME_p return varchar2 is
	Begin
	 return PARAM_LEDGER_NAME;
	 END;
 Function INV_FLEX_MSG_p return varchar2 is
	Begin
	 return INV_FLEX_MSG;
	 END;
 Function DEBIT_DSP_p return varchar2 is
	Begin
	 return DEBIT_DSP;
	 END;
 Function CREDIT_DSP_p return varchar2 is
	Begin
	 return CREDIT_DSP;
	 END;
 Function WIDTH_p return number is
	Begin
	 return WIDTH;
	 END;
 Function DAS_WHERE_p return varchar2 is
	Begin
	 return DAS_WHERE;
	 END;
 Function ACCESS_SET_NAME_p return varchar2 is
	Begin
	 return ACCESS_SET_NAME;
	 END;
 Function PARAM_LEDGER_TYPE_p return varchar2 is
	Begin
	 return PARAM_LEDGER_TYPE;
	 END;
 Function CURR_FORMAT_MASK_p return varchar2 is
	Begin
	 return CURR_FORMAT_MASK;
	 END;
 Function THOUSANDS_SEPARATOR_p return varchar2 is
	Begin
	 return THOUSANDS_SEPARATOR;
	 END;
 Function MIXED_PRECISION_p return number is
	Begin
	 return MIXED_PRECISION;
	 END;
 Function LEDGER_WHERE_p return varchar2 is
	Begin
	 return LEDGER_WHERE;
	 END;
 Function LEDGER_FROM_p return varchar2 is
	Begin
	 return LEDGER_FROM;
	 END;
 Function CONSOLIDATION_LEDGER_FLAG_p return varchar2 is
	Begin
	 return CONSOLIDATION_LEDGER_FLAG;
	 END;
 Function PARAM_LEDGER_CURR_p return varchar2 is
	Begin
	 return PARAM_LEDGER_CURR;
	 END;
END GL_GLRFGNJ_XMLP_PKG ;



/
