--------------------------------------------------------
--  DDL for Package Body GL_GLXAVTRB_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_GLXAVTRB_XMLP_PKG" AS
/* $Header: GLXAVTRBB.pls 120.0 2007/12/27 14:44:24 vijranga noship $ */
function BeforeReport return boolean is
errbuf       VARCHAR2(133);
begin
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
    SELECT
      dpm.period_name,
      prd.start_date,
      prd.quarter_start_date,
      prd.year_start_date
    INTO
      PERIOD_NAME,
      PERIOD_START_DATE,
      QUARTER_START_DATE,
      YEAR_START_DATE
    FROM
      gl_access_sets       acc,
      gl_date_period_map   dpm,
      gl_periods           prd
    WHERE
        acc.access_set_id	= P_ACCESS_SET_ID
    AND dpm.period_set_name	= acc.period_set_name
    AND dpm.period_type		= acc.accounted_period_type
    AND dpm.accounting_date	= P_REPORTING_DATE
    AND prd.period_set_name	= dpm.period_set_name
    AND prd.period_name		= dpm.period_name
    AND prd.period_type		= dpm.period_type;
  exception
    WHEN NO_DATA_FOUND THEN
      errbuf := gl_message.get_message(
		'GL_AVG_INVALID_DATE', 'Y',
		'DATE', to_char(P_Reporting_Date));
      /*srw.message('00', errbuf);*/null;
      raise_application_error(-20101,errbuf);/*srw.program_abort;*/null;
    WHEN OTHERS THEN
      errbuf := SQLERRM;
      /*srw.message('00', errbuf);*/null;
      raise_application_error(-20101,errbuf);/*srw.program_abort;*/null;
  end;
  IF (P_CURRENCY_TYPE = 'T') THEN
    CURR_TYPE := 'dbs.currency_type in (''U'', ''T'', ''O'')';
    RESULTING_CURRENCY := P_LEDGER_CURRENCY;
  ELSIF (P_CURRENCY_TYPE = 'E') THEN
    CURR_TYPE := 'dbs.currency_type = ''E''';
    RESULTING_CURRENCY := P_ENTERED_CURRENCY;
  ELSIF (P_CURRENCY_TYPE = 'S') THEN
    CURR_TYPE := 'dbs.currency_type = ''U''';
    RESULTING_CURRENCY := P_ENTERED_CURRENCY;
  END IF;
  if P_CURRENCY_TYPE is null then
	  P_CURRENCY_TYPE:='1=1';
  end if;
  begin
    SELECT
	PRECISION,
	MINIMUM_ACCOUNTABLE_UNIT
    INTO
	PRECISION,
	MAU
    FROM
	FND_CURRENCIES
    WHERE
	CURRENCY_CODE = RESULTING_CURRENCY;
  exception
    WHEN NO_DATA_FOUND THEN
      errbuf := gl_message.get_message(
                'GL invalid currency code', 'Y');
      /*srw.message('00', errbuf);*/null;
      raise_application_error(-20101,null);/*srw.program_abort;*/null;
    WHEN OTHERS THEN
      errbuf := SQLERRM;
      /*srw.message('00', errbuf);*/null;
      raise_application_error(-20101,errbuf);/*srw.program_abort;*/null;
  end;
  /*SRW.USER_EXIT('FND SRWINIT');*/null;
  /*SRW.REFERENCE(STRUCT_NUM);*/null;
 null;
  /*SRW.REFERENCE(STRUCT_NUM);*/null;
 null;
  /*SRW.REFERENCE(STRUCT_NUM);*/null;
 null;
  /*SRW.REFERENCE(STRUCT_NUM);*/null;
 null;
  WHERE_DAS := GL_ACCESS_SET_SECURITY_PKG.GET_SECURITY_CLAUSE(
                  P_ACCESS_SET_ID,
                  'R',
                  'LEDGER_COLUMN',
                  'LEDGER_ID',
                  'DBS',
                  'SEG_COLUMN',
                  null,
                  'CC',
                  null);
  IF (WHERE_DAS is not null) THEN
    WHERE_DAS := ' AND ' || WHERE_DAS;
  else
     WHERE_DAS:='and 1=1';
  END IF;
  PTD_POSITION := trunc(P_Reporting_Date) -
		   trunc(PERIOD_START_DATE) + 1;
  IF (PTD_POSITION = 1) THEN
    P_ENDING_BALANCE := 'dbs.Period_Aggregate1';
  ELSE
    P_ENDING_BALANCE := '(dbs.Period_Aggregate' || to_char(PTD_POSITION) || ' - ' ||
			 'dbs.Period_Aggregate' || to_char(PTD_POSITION - 1) || ')';
  END IF;
  IF (P_CURRENCY_TYPE = 'T') THEN
    P_ENDING_BALANCE := 'decode(dbs.currency_type, ''U'', ' ||
                         P_ENDING_BALANCE ||
                         ', dbs.end_of_day' || to_char(PTD_POSITION) || ')';
  END IF;
  P_PTD_AGGREGATE := 'dbs.Period_Aggregate' || to_char(PTD_POSITION);
  IF (MAU IS NULL) THEN
    P_PATD := 'round((dbs.Period_Aggregate' || to_char(PTD_POSITION) ||
			' / ' || to_char(PTD_POSITION) || '), ' ||
		to_char(PRECISION) || ')';
  ELSE
    P_PATD := 'round((dbs.Period_Aggregate' || to_char(PTD_POSITION) ||
			' / (' || to_char(PTD_POSITION) ||
			' * ' || to_char(MAU) || ') ) )' ||
		' * ' || to_char(MAU);
  END IF;
  QTD_POSITION := trunc(P_Reporting_Date) -
		   trunc(QUARTER_START_DATE) + 1;
  P_QTD_AGGREGATE := 'dbs.Opening_Quarter_Aggregate + dbs.Period_Aggregate' ||
		      to_char(PTD_POSITION);
  IF (P_CURRENCY_TYPE = 'T') THEN
    P_QTD_AGGREGATE := 'decode(dbs.currency_type, ''U'', ' ||
			P_QTD_AGGREGATE ||
			', dbs.Quarter_Aggregate' || to_char(PTD_POSITION) || ')';
  END IF;
  IF (MAU IS NULL) THEN
    P_QATD := 'round(((dbs.Opening_Quarter_Aggregate + dbs.Period_Aggregate' ||
			to_char(PTD_POSITION) ||
			') / ' || to_char(QTD_POSITION) || '), ' ||
		to_char(PRECISION) || ')';
    IF (P_CURRENCY_TYPE = 'T') THEN
      P_QATD := 'decode(dbs.currency_type, ''U'', ' ||
		 P_QATD ||
		 ', round((dbs.Quarter_Aggregate' || to_char(PTD_POSITION) ||
			' / ' || to_char(QTD_POSITION) || '), ' ||
		 to_char(PRECISION) || ') )';
    END IF;
  ELSE
    P_QATD := 'round(((dbs.Opening_Quarter_Aggregate + dbs.Period_Aggregate' ||
			to_char(PTD_POSITION) ||
			') / (' || to_char(QTD_POSITION) ||
			' * ' || to_char(MAU) || ') ) )' ||
		' * ' || to_char(MAU);
    IF (P_CURRENCY_TYPE = 'T') THEN
      P_QATD := 'decode(dbs.currency_type, ''U'', ' ||
		 P_QATD ||
		 ', round((dbs.Quarter_Aggregate' || to_char(PTD_POSITION) ||
			' / (' || to_char(QTD_POSITION) ||
			' * ' || to_char(MAU) || ') ) )' ||
		 ' * ' || to_char(MAU) || ')';
    END IF;
  END IF;
  YTD_POSITION := trunc(P_Reporting_Date) -
		   trunc(YEAR_START_DATE) + 1;
  P_YTD_AGGREGATE := 'dbs.Opening_Year_Aggregate + dbs.Period_Aggregate' ||
		      to_char(PTD_POSITION);
  IF (P_CURRENCY_TYPE = 'T') THEN
    P_YTD_AGGREGATE := 'decode(dbs.currency_type, ''U'', ' ||
			P_YTD_AGGREGATE ||
			', dbs.Year_Aggregate' || to_char(PTD_POSITION) || ')';
  END IF;
  IF (MAU IS NULL) THEN
    P_YATD := 'round(((dbs.Opening_Year_Aggregate + dbs.Period_Aggregate' ||
			to_char(PTD_POSITION) ||
			') / ' || to_char(YTD_POSITION) || '), ' ||
		to_char(PRECISION) || ')';
    IF (P_CURRENCY_TYPE = 'T') THEN
      P_YATD := 'decode(dbs.currency_type, ''U'', ' ||
		 P_YATD ||
		 ', round((dbs.Year_Aggregate' || to_char(PTD_POSITION) ||
			   ' / ' || to_char(YTD_POSITION) || '), ' ||
		 to_char(PRECISION) || ') )';
    END IF;
  ELSE
    P_YATD := 'round(((dbs.Opening_Year_Aggregate + dbs.Period_Aggregate' ||
			to_char(PTD_POSITION) ||
			') / (' || to_char(YTD_POSITION) ||
			' * ' || to_char(MAU) || ') ) )' ||
		' * ' || to_char(MAU);
    IF (P_CURRENCY_TYPE = 'T') THEN
      P_YATD := 'decode(dbs.currency_type, ''U'', ' ||
		 P_YATD ||
		 ', round((dbs.Year_Aggregate' || to_char(PTD_POSITION) ||
			' / (' || to_char(YTD_POSITION) ||
			' * ' || to_char(MAU) || ') ) )' ||
		 ' * ' || to_char(MAU) || ')';
    END IF;
  END IF;
  return (TRUE);
end;
FUNCTION AfterReportTrigger return boolean is
begin
	/*SRW.USER_EXIT('FND SRWEXIT');*/null;
	return(TRUE);
end;
function patd(PTD_Aggregate_Total in number) return number is
  Average NUMBER;
begin
  IF (MAU IS NULL) THEN
	Average	:= round(PTD_Aggregate_Total /
		   PTD_POSITION, PRECISION);
  ELSE
	Average	:= round(PTD_Aggregate_Total /
		   (PTD_POSITION * MAU))
		   * MAU ;
  END IF;
  RETURN(Average);
end;
function qatd(QTD_Aggregate_Total in number) return number is
  Average NUMBER;
begin
  IF (MAU IS NULL) THEN
	Average	:= round(QTD_Aggregate_Total /
		   QTD_POSITION, PRECISION);
  ELSE
	Average	:= round(QTD_Aggregate_Total /
		   (QTD_POSITION * MAU))
		   * MAU ;
  END IF;
  RETURN(Average);
end;
function yatd(YTD_Aggregate_Total in number) return number is
  Average NUMBER;
begin
  IF (MAU IS NULL) THEN
	Average	:= round(YTD_Aggregate_Total /
		   YTD_POSITION, PRECISION);
  ELSE
	Average	:= round(YTD_Aggregate_Total /
		   (YTD_POSITION * MAU))
		   * MAU ;
  END IF;
  RETURN(Average);
end;
function end_bal(END_BAL_Total in number) return number is
  Average NUMBER;
begin
  IF (MAU IS NULL) THEN
	Average	:= round(END_BAL_Total, PRECISION);
  ELSE
	Average	:= round(END_BAL_Total / MAU)
		   * MAU ;
  END IF;
  RETURN(Average);
end;
function g_headergroupfilter(BAL_SECURE in varchar2) return boolean is
begin
       /*SRW.REFERENCE(STRUCT_NUM);*/null;
       /*SRW.REFERENCE(C_FLEXDATA_MASTER);*/null;
  if (BAL_SECURE = 'S') then
     return (FALSE);
  else
     return (TRUE);
  end if;
  RETURN NULL;
end;
function g_detailgroupfilter(FLEX_SECURE in varchar2) return boolean is
begin
        /*SRW.REFERENCE(STRUCT_NUM);*/null;
	/*SRW.REFERENCE(C_FLEXDATA_MASTER);*/null;
  if (FLEX_SECURE ='S') then
     return (FALSE);
  else
     return (TRUE);
  end if;
  RETURN NULL;
end;
--Functions to refer Oracle report placeholders--
 Function WHERE_p return varchar2 is
	Begin
	 return WHERE_lexical;
	 END;
 Function CURR_TYPE_p return varchar2 is
	Begin
	 return CURR_TYPE;
	 END;
 Function WHERE_DAS_p return varchar2 is
	Begin
	 return WHERE_DAS;
	 END;
 Function ACCESS_SET_NAME_p return varchar2 is
	Begin
	 return ACCESS_SET_NAME;
	 END;
 Function STRUCT_NUM_p return varchar2 is
	Begin
	 return STRUCT_NUM;
	 END;
 Function RESULTING_CURRENCY_p return varchar2 is
	Begin
	 return RESULTING_CURRENCY;
	 END;
 Function SELECT_BAL_p return varchar2 is
	Begin
	 return SELECT_BAL;
	 END;
 Function SELECT_FLEXDATA_p return varchar2 is
	Begin
	 return SELECT_FLEXDATA;
	 END;
 Function ORDERBY_p return varchar2 is
	Begin
	 return ORDERBY;
	 END;
 Function PERIOD_NAME_p return varchar2 is
	Begin
	 return PERIOD_NAME;
	 END;
 Function PERIOD_START_DATE_p return date is
	Begin
	 return PERIOD_START_DATE;
	 END;
 Function QUARTER_START_DATE_p return date is
	Begin
	 return QUARTER_START_DATE;
	 END;
 Function YEAR_START_DATE_p return date is
	Begin
	 return YEAR_START_DATE;
	 END;
 Function PTD_POSITION_p return number is
	Begin
	 return PTD_POSITION;
	 END;
 Function QTD_POSITION_p return number is
	Begin
	 return QTD_POSITION;
	 END;
 Function YTD_POSITION_p return number is
	Begin
	 return YTD_POSITION;
	 END;
 Function MAU_p return number is
	Begin
	 return MAU;
	 END;
 Function PRECISION_p return number is
	Begin
	 return PRECISION;
	 END;
 Function P_ENDING_BALANCE_p return varchar2 is
	Begin
	 return P_ENDING_BALANCE;
	 END;
 Function P_PATD_p return varchar2 is
	Begin
	 return P_PATD;
	 END;
 Function P_QATD_p return varchar2 is
	Begin
	 return P_QATD;
	 END;
 Function P_YATD_p return varchar2 is
	Begin
	 return P_YATD;
	 END;
 Function P_PTD_AGGREGATE_p return varchar2 is
	Begin
	 return P_PTD_AGGREGATE;
	 END;
 Function P_QTD_AGGREGATE_p return varchar2 is
	Begin
	 return P_QTD_AGGREGATE;
	 END;
 Function P_YTD_AGGREGATE_p return varchar2 is
	Begin
	 return P_YTD_AGGREGATE;
	 END;
END GL_GLXAVTRB_XMLP_PKG ;



/
