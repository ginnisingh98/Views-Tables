--------------------------------------------------------
--  DDL for Package Body GL_GLRGNJ_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_GLRGNJ_XMLP_PKG" AS
/* $Header: GLRGNJB.pls 120.0 2007/12/27 14:36:50 vijranga noship $ */
function BeforeReport return boolean is
cursor get_to_period(T_END_DATE DATE, T_PERIOD_SET_NAME VARCHAR) is
      SELECT PERIOD_NAME
      FROM GL_PERIODS
      WHERE PERIOD_SET_NAME = T_PERIOD_SET_NAME
      AND END_DATE = T_END_DATE
      ORDER BY PERIOD_NUM DESC;
 cursor get_from_period(T_START_DATE DATE, T_PERIOD_SET_NAME VARCHAR) is
      SELECT PERIOD_NAME
      FROM GL_PERIODS
      WHERE PERIOD_SET_NAME = T_PERIOD_SET_NAME
      AND START_DATE = T_START_DATE
      ORDER BY PERIOD_NUM DESC;
  t_p_start_date         DATE;
  t_p_end_date           DATE;
  t_period_from          VARCHAR2(15);
  t_period_to            VARCHAR2(15);
  t_errorbuffer          VARCHAR2(132);
  t_period_set_name      VARCHAR(15);
begin
  /*srw.user_exit('FND SRWINIT');*/null;
      INV_FLEX_MSG      := gl_message.get_message(
                       'GL_PLL_INVALID_FLEXFIELD','N');
	STAT:= FND_CURRENCY.GET_FORMAT_MASK('STAT',19);
  begin
    SELECT name, chart_of_accounts_id, period_set_name
    INTO   ACCESS_SET_NAME, STRUCT_NUM, T_PERIOD_SET_NAME
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
  /*SRW.REFERENCE(STRUCT_NUM);*/null;
 null;
      IF (P_KIND = 'S') THEN
     POSTING_STATUS_SELECT := 'J.reference_4';
  ELSE
     POSTING_STATUS_SELECT := 'J.reference_1';
  END IF;
      IF (P_CURRENCY_CODE = 'STAT') THEN
    CURRENCY_WHERE := 'D.currency_code = ''STAT''';
  ELSE
    CURRENCY_WHERE := 'D.currency_code <> ''STAT'' AND L.currency_code = ''' ||
                       P_CURRENCY_CODE || '''';
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
      ELSIF (P_START_DATE IS NULL  AND P_END_DATE IS NOT NULL) THEN
        PERIOD_WHERE := 'trunc(B.posted_date) <= to_date(' || '''' || to_char(P_END_DATE,'DD-MON-YYYY') || '''' || ',''DD-MON-YYYY'')';
      ELSIF (P_START_DATE IS NOT NULL AND P_END_DATE IS NULL) THEN
        PERIOD_WHERE := 'trunc(B.posted_date) >= to_date(' || '''' || to_char(P_START_DATE,'DD-MON-YYYY') || '''' || ',''DD-MON-YYYY'')';
      END IF;
    ELSE
      IF (P_START_DATE IS NOT NULL AND P_END_DATE IS NOT NULL) THEN
      PERIOD_WHERE := 'trunc(D.DEFAULT_EFFECTIVE_DATE) between to_date(' || '''' || to_char(P_START_DATE,'DD-MON-YYYY') || '''' || ',''DD-MON-YYYY'') and to_date(' || '''' || to_char(P_END_DATE,'DD-MON-YYYY') || '''' || ',''DD-MON-YYYY'')';
      ELSIF (P_START_DATE IS NULL AND P_END_DATE IS NOT NULL) THEN
         PERIOD_WHERE := 'trunc(D.DEFAULT_EFFECTIVE_DATE) <= to_date(' || '''' || to_char(P_END_DATE,'DD-MON-YYYY') || '''' || ',''DD-MON-YYYY'')';
      ELSIF (P_START_DATE IS NOT NULL AND P_END_DATE IS NULL) THEN
         PERIOD_WHERE := 'trunc(D.DEFAULT_EFFECTIVE_DATE) >= to_date(' || '''' || to_char(P_START_DATE,'DD-MON-YYYY') || '''' || ',''DD-MON-YYYY'')';
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
      IF (P_PAGESIZE = 180) THEN
    WIDTH := 19;
  ELSE
    WIDTH := 16;
  END IF;
  IF (P_LEDGER_ID IS NOT NULL) THEN
    begin
      SELECT name, object_type_code, consolidation_ledger_flag
      INTO   PARAM_LEDGER_NAME, PARAM_LEDGER_TYPE, CONSOLIDATION_LEDGER_FLAG
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
      LEDGER_FROM := ' ';
      LEDGER_WHERE := 'D.ledger_id = ' || to_char(P_LEDGER_ID) || ' AND ';
    END IF;
  END IF;
IF(LEDGER_FROM IS NULL) THEN
LEDGER_FROM := ' ';
END IF;
  IF (PARAM_LEDGER_TYPE = 'S') THEN
    begin
      SELECT consolidation_ledger_flag
      INTO CONSOLIDATION_LEDGER_FLAG
      FROM gl_system_usages
      WHERE rownum = 1;
    exception
      WHEN OTHERS THEN
        t_errorbuffer := SQLERRM;
        /*srw.message('00', t_errorbuffer);*/null;
        raise_application_error(-20101,null);/*srw.program_abort;*/null;
    end;
  END IF;
  /*SRW.REFERENCE(P_JE_SOURCE_NAME);*/null;
  IF (P_JE_SOURCE_NAME IS NOT NULL) THEN
    SELECT USER_JE_SOURCE_NAME
    INTO JE_USER_SOURCE_DSP
    FROM GL_JE_SOURCES
    WHERE JE_SOURCE_NAME =  P_JE_SOURCE_NAME;
  END IF;
 IF (p_period_name IS NULL AND (p_start_date IS NULL OR p_end_date IS NULL)) THEN
   IF (p_ledger_id is null) THEN
     SELECT min(a.start_date),max(a.end_date)
     INTO   t_p_start_date, t_p_end_date
     FROM   gl_period_statuses a,
            gl_access_set_assignments b
     WHERE  b.access_set_id = p_access_set_id
     AND    a.application_id = 101
     AND    a.closing_status <> 'N'
     AND    a.ledger_id = b.ledger_id;
   ELSIF (p_ledger_id is not null and param_ledger_type = 'S') THEN
     SELECT min(a.start_date),max(a.end_date)
     INTO   t_p_start_date, t_p_end_date
     FROM   gl_period_statuses a,
            gl_ledger_set_assignments b
     WHERE  b.ledger_set_id = p_ledger_id
     AND    a.application_id = 101
     AND    a.closing_status <> 'N'
     AND    a.ledger_id = b.ledger_id;
   ELSE
     SELECT min(start_date),max(end_date)
     INTO   t_p_start_date, t_p_end_date
     FROM   gl_period_statuses
     WHERE  application_id = 101
     AND    ledger_id = p_ledger_id
     AND    closing_status <> 'N';
  END IF;
  IF (p_start_date IS NULL AND p_end_date IS NULL) THEN
       OPEN get_from_period(t_p_start_date, t_period_set_name);
       FETCH get_from_period INTO T_PERIOD_FROM;
       IF (get_from_period%FOUND) THEN
          CLOSE get_from_period;
       ELSE
          CLOSE get_from_period;
       END IF;
       OPEN get_to_period(t_p_end_date, t_period_set_name);
       FETCH get_to_period INTO T_PERIOD_TO;
       IF (get_to_period%FOUND) THEN
          CLOSE get_to_period;
       ELSE
          CLOSE get_to_period;
       END IF;
       PERIOD_FROM := T_PERIOD_FROM;
       PERIOD_TO := T_PERIOD_TO;
    ELSIF (p_start_date IS NULL AND p_end_date IS NOT NULL) THEN
       p_start_date := t_p_start_date;
    ELSIF (P_START_DATE IS NOT NULL AND P_END_DATE IS NULL) THEN
       p_end_date := t_p_end_date;
    END IF;
 END IF ;
    PARAM_CURRENCY := P_CURRENCY_CODE;
  PARAM_PERIOD_NAME := P_PERIOD_NAME;
  PARAM_START_DATE := P_START_DATE;
  PARAM_END_DATE := P_END_DATE;
    gl_info.gl_get_lookup_value('M', P_POSTING_STATUS, 'JOURNAL_REPORT_TYPE',
                              PARAM_POSTING_STATUS, t_errorbuffer);
  if (t_errorbuffer IS NOT NULL) then
     /*SRW.MESSAGE('00', t_errorbuffer);*/null;
  end if;
    gl_info.gl_get_lookup_value('M', P_KIND, 'ACCOUNT_RPT_KIND',
                              PARAM_REFERENCE_TYPE, t_errorbuffer);
  if (t_errorbuffer IS NOT NULL) then
    /*srw.message('00', t_errorbuffer);*/null;
  end if;
  return (TRUE);
end;
function AfterReport return boolean is
begin
  /*SRW.USER_EXIT('FND SRWEXIT');*/null;
  return (TRUE);
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
 Function CURRENCY_WHERE_p return varchar2 is
	Begin
	 return CURRENCY_WHERE;
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
 Function WIDTH_p return number is
	Begin
	 return WIDTH;
	 END;
 Function JE_USER_SOURCE_DSP_p return varchar2 is
	Begin
	 return JE_USER_SOURCE_DSP;
	 END;
 Function ACCESS_SET_NAME_p return varchar2 is
	Begin
	 return ACCESS_SET_NAME;
	 END;
 Function DAS_WHERE_p return varchar2 is
	Begin
	 return DAS_WHERE;
	 END;
 Function LEDGER_FROM_p return varchar2 is
	Begin
	 return LEDGER_FROM;
	 END;
 Function LEDGER_WHERE_p return varchar2 is
	Begin
	 return LEDGER_WHERE;
	 END;
 Function PARAM_LEDGER_TYPE_p return varchar2 is
	Begin
	 return PARAM_LEDGER_TYPE;
	 END;
 Function CONSOLIDATION_LEDGER_FLAG_p return varchar2 is
	Begin
	 return CONSOLIDATION_LEDGER_FLAG;
	 END;
 Function PARAM_CURRENCY_p return varchar2 is
	Begin
	 return PARAM_CURRENCY;
	 END;
 Function PARAM_PERIOD_NAME_p return varchar2 is
	Begin
	 return PARAM_PERIOD_NAME;
	 END;
 Function PARAM_START_DATE_p return date is
	Begin
	 return PARAM_START_DATE;
	 END;
 Function PARAM_END_DATE_p return date is
	Begin
	 return PARAM_END_DATE;
	 END;
 Function PARAM_REFERENCE_TYPE_p return varchar2 is
	Begin
	 return PARAM_REFERENCE_TYPE;
	 END;
 Function PARAM_POSTING_STATUS_p return varchar2 is
	Begin
	 return PARAM_POSTING_STATUS;
	 END;
 Function PERIOD_FROM_p return varchar2 is
	Begin
	 return PERIOD_FROM;
	 END;
 Function PERIOD_TO_p return varchar2 is
	Begin
	 return PERIOD_TO;
	 END;
END GL_GLRGNJ_XMLP_PKG ;


/
