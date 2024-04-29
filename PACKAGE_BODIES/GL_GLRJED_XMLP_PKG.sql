--------------------------------------------------------
--  DDL for Package Body GL_GLRJED_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_GLRJED_XMLP_PKG" AS
/* $Header: GLRJEDB.pls 120.0 2007/12/27 14:38:48 vijranga noship $ */

function AfterReport return boolean is
begin
  /*srw.user_exit('FND SRWEXIT');*/null;

  return (TRUE);
end;

function begin_balformula(BEGIN_DR in number, BEGIN_CR in number) return number is
begin

 return (abs(BEGIN_DR - BEGIN_CR));
end;

function end_balformula(END_DR in number, END_CR in number) return number is
begin
 return (abs(END_DR - END_CR));
end;

function BUD_ENC_TYPE_NAMEFormula return VARCHAR2 is
name     VARCHAR2(30);
  errbuf   VARCHAR2(132);
  errbuf2  VARCHAR2(132);
begin

  gl_info.gl_get_bud_or_enc_name(P_ACTUAL_FLAG,
                                 P_BUD_ENC_TYPE_ID,
                                 name, errbuf);

  if (errbuf is not null) then

    errbuf2 := gl_message.get_message(
                 'GL_PLL_ROUTINE_ERROR', 'N',
                 'ROUTINE','gl_get_bud_enc_name'
               );
    /*srw.message('00', errbuf2);*/null;


    /*srw.message('00', errbuf);*/null;


    raise_application_error(-20101,null);/*srw.program_abort;*/null;

  end if;

  return(name);
end;

function DISP_ACTUAL_FLAGFormula return VARCHAR2 is
name     VARCHAR2(240);
  errbuf   VARCHAR2(132);
  errbuf2  VARCHAR2(132);
begin

  gl_info.gl_get_lookup_value(
                      'D', P_ACTUAL_FLAG, 'BATCH_TYPE',
                      name, errbuf);

  if (errbuf is not null) then


    errbuf2 := gl_message.get_message(
                 'GL_PLL_ROUTINE_ERROR', 'N',
                 'ROUTINE','gl_get_lookup_value'
               );
    /*srw.message('00', errbuf2);*/null;


    /*srw.message('00', errbuf);*/null;


    raise_application_error(-20101,null);/*srw.program_abort;*/null;

  end if;

  return(name);
end;

function START_EFFECTIVE_PERIOD_NUMForm return Number is
effective_period_num  NUMBER;
  errbuf                VARCHAR2(132);
  errbuf2               VARCHAR2(132);
begin

  gl_get_effective_num(P_LEDGER_ID,
                       P_START_PERIOD,
                       effective_period_num,
                       errbuf);

  if (errbuf is not null) then
    errbuf2 := gl_message.get_message(
                 'GL_PLL_ROUTINE_ERROR', 'N',
                 'ROUTINE','gl_get_period_dates'
               );
    /*srw.message('00', errbuf2);*/null;


    /*srw.message('00', errbuf);*/null;


    raise_application_error(-20101,null);/*srw.program_abort;*/null;

  end if;

  return(effective_period_num);
end;

function END_EFFECTIVE_PERIOD_NUMFormul return Number is
effective_period_num    NUMBER;
  errbuf                  VARCHAR2(132);
  errbuf2                 VARCHAR2(132);
begin

  gl_get_effective_num(P_LEDGER_ID,
                       P_END_PERIOD,
                       effective_period_num,
                       errbuf);

  if (errbuf is not null) then
    errbuf2 := gl_message.get_message(
                 'GL_PLL_ROUTINE_ERROR', 'N',
                 'ROUTINE','gl_get_period_dates'
               );
    /*srw.message('00', errbuf2);*/null;


    /*srw.message('00', errbuf);*/null;


    raise_application_error(-20101,null);/*srw.program_abort;*/null;

  end if;

  return(effective_period_num);
end;

function BeforeReport return boolean is
security_mode VARCHAR2(1);
  errbuf        VARCHAR2(132);
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

/*srw.reference(STRUCT_NUM);*/null;


 null;



WHERE_DAS_BAL := gl_access_set_security_pkg.get_security_clause(
			P_ACCESS_SET_ID,
			'R',
			'LEDGER_COLUMN',
			'LEDGER_ID',
			'bal',
			'SEG_COLUMN',
			null,
			'cc',
			null);
IF (WHERE_DAS_BAL IS NOT NULL) THEN
  WHERE_DAS_BAL := ' AND ' || WHERE_DAS_BAL;
END IF;

WHERE_DAS_JE := gl_access_set_security_pkg.get_security_clause(
			P_ACCESS_SET_ID,
			'R',
			'LEDGER_COLUMN',
			'LEDGER_ID',
			'jeh',
			'SEG_COLUMN',
			null,
			'cc',
			null);
IF (WHERE_DAS_JE IS NOT NULL) THEN
  WHERE_DAS_JE := ' AND ' || WHERE_DAS_JE;
END IF;



if (P_KIND = 'L') then
  SELECT_REFERENCE := 'jel.reference_1';
elsif (P_KIND = 'H') then
  SELECT_REFERENCE := 'jeh.external_reference';
elsif (P_KIND = 'S') then
  SELECT_REFERENCE := 'jel.reference_4';
else
  SELECT_REFERENCE := 'jel.reference_1';
end if;



IF (P_CURRENCY_TYPE = 'T') THEN
  RESULTING_CURRENCY := P_LEDGER_CURRENCY;
ELSE
  RESULTING_CURRENCY := P_ENTERED_CURRENCY;
END IF;




WHERE_CURRENCY_BAL := 'bal.translated_flag is null';
SELECT_BEGIN_DR := 'sum(nvl(bal.begin_balance_dr,0))';
SELECT_BEGIN_CR := 'sum(nvl(bal.begin_balance_cr,0))';
SELECT_END_DR := 'sum(nvl(bal.begin_balance_dr,0) + nvl(bal.period_net_dr,0))';
SELECT_END_CR := 'sum(nvl(bal.begin_balance_cr,0) + nvl(bal.period_net_cr,0))';

IF (P_CURRENCY_TYPE = 'E') THEN

  IF (P_ACTUAL_FLAG = 'A') THEN
    SELECT_BEGIN_DR := 'sum(nvl(decode(bal.translated_flag, ''R'', bal.begin_balance_dr, bal.begin_balance_dr_beq),0))';
    SELECT_BEGIN_CR := 'sum(nvl(decode(bal.translated_flag, ''R'', bal.begin_balance_cr, bal.begin_balance_cr_beq),0))';
    SELECT_END_DR := 'sum(nvl(decode(bal.translated_flag, ''R'', bal.begin_balance_dr, bal.begin_balance_dr_beq),0)' ||
                      ' + nvl(decode(bal.translated_flag, ''R'', bal.period_net_dr, bal.period_net_dr_beq),0))';
    SELECT_END_CR := 'sum(nvl(decode(bal.translated_flag, ''R'', bal.begin_balance_cr, bal.begin_balance_cr_beq),0)' ||
                      ' + nvl(decode(bal.translated_flag, ''R'', bal.period_net_cr, bal.period_net_cr_beq),0))';
  END IF;


  WHERE_CURRENCY_BAL := '(bal.translated_flag = ''R'' or bal.translated_flag is null)';
END IF;



if (P_ACTUAL_FLAG = 'A') then
  WHERE_ACTUAL_TYPE := '1 = 1';
elsif (P_ACTUAL_FLAG = 'B') then
  WHERE_ACTUAL_TYPE := 'budget_version_id = ' || to_char(P_BUD_ENC_TYPE_ID);
else
  WHERE_ACTUAL_TYPE := 'encumbrance_type_id = ' || to_char(P_BUD_ENC_TYPE_ID);
end if;



IF (P_CURRENCY_TYPE = 'S') THEN
  WHERE_CURRENCY_CODE :=
    '(   jeh.currency_code = ''STAT''' ||
    ' OR jel.stat_amount is NOT NULL)';
  SELECT_DR :=
    'decode(jeh.currency_code, ''STAT'',' ||
      'decode(nvl(jel.stat_amount,0),' ||
        '0, jel.accounted_dr,' ||
        'decode(sign(nvl(jel.stat_amount,0)),' ||
          '-1, jel.accounted_dr,' ||
          ' 1, (nvl(jel.accounted_dr,0) + ' ||
                   'jel.stat_amount),' ||
          'jel.accounted_dr)),' ||
      'decode(sign(nvl(jel.stat_amount,0)),' ||
        '1, nvl(jel.stat_amount,0), ' ||
        'NULL))';

  SELECT_CR :=
    'decode(jeh.currency_code, ''STAT'',' ||
      'decode(nvl(jel.stat_amount,0),' ||
        '0, jel.accounted_cr,' ||
        'decode(sign(nvl(jel.stat_amount,0)),' ||
          '-1, (nvl(jel.accounted_cr,0) - ' ||
                   'jel.stat_amount),' ||
          ' 1, jel.accounted_cr,' ||
           'jel.accounted_cr)),' ||
      'decode(sign(nvl(jel.stat_amount,0)),' ||
        '-1, (0 - nvl(jel.stat_amount,0)), ' ||
        'NULL))';

ELSIF (P_CURRENCY_TYPE = 'T') THEN
  WHERE_CURRENCY_CODE := 'jeh.currency_code <> ''STAT''';
  SELECT_DR := 'jel.accounted_dr';
  SELECT_CR := 'jel.accounted_cr';

ELSE
  WHERE_CURRENCY_CODE := 'jeh.currency_code = ''' || P_ENTERED_CURRENCY || '''';
  SELECT_DR := 'jel.entered_dr';
  SELECT_CR := 'jel.entered_cr';
END IF;



if (P_ORDER_TYPE = 'A') then
  ORDER_BY := ORDERBY_ACCT || ', ' ||
	       ORDERBY_ACCT2 || ', ' ||
               ORDERBY_BAL || ', ' ||
	       ORDERBY_BAL2 || ', ' ||
               ORDERBY_ALL || ', ' ||
               'src.user_je_source_name, ' ||
               'cat.user_je_category_name, ' ||
               'jeb.name, jeh.name, jel.je_line_num';
elsif (P_ORDER_TYPE = 'B') then
  ORDER_BY := ORDERBY_BAL || ', ' ||
	       ORDERBY_BAL2 || ', ' ||
               ORDERBY_ACCT || ', ' ||
	       ORDERBY_ACCT2 || ', ' ||
               ORDERBY_ALL || ', ' ||
               'src.user_je_source_name, ' ||
               'cat.user_je_category_name, ' ||
               'jeb.name, jeh.name, jel.je_line_num';
else
  ORDER_BY := 'src.user_je_source_name, ' ||
               'cat.user_je_category_name, ' ||
               'jeb.name, jeh.name, ' ||
               ORDERBY_BAL || ', ' ||
	       ORDERBY_BAL2 || ', ' ||
               ORDERBY_ACCT || ', ' ||
	       ORDERBY_ACCT2 || ', ' ||
               ORDERBY_ALL || ', ' ||
               'jel.je_line_num';
end if;



  begin
    fnd_profile.get('GL_STD_ANALYSIS_REPORT_BALANCE_SECURITY', security_mode);
  exception
    WHEN OTHERS THEN
      security_mode := 'N';
  end;

  if( nvl(security_mode,'N') = 'Y') then

    gl_security_pkg.init_segval;

    SECURITY_FILTER_STR :=
          'AND gl_security_pkg.validate_access(' || P_LEDGER_ID ||
              ', cc.code_combination_id) = ''TRUE'' ';
  else
    SECURITY_FILTER_STR := ' ';
  end if;



    PARAM_ACCT_FROM := P_MIN_FLEX;
  PARAM_ACCT_TO := P_MAX_FLEX;
  PARAM_PERIOD_FROM := P_START_PERIOD;
  PARAM_PERIOD_TO := P_END_PERIOD;
  PARAM_CURRENCY_TYPE := P_CURRENCY_TYPE;

    gl_info.gl_get_lookup_value('M', P_KIND, 'ACCOUNT_RPT_KIND',
                              PARAM_REFERENCE_TYPE, errbuf);
  if (errbuf IS NOT NULL) then
    /*srw.message('00', errbuf);*/null;

  end if;

    gl_info.gl_get_lookup_value('M', 'DR', 'GL_DR_CR', DR_MEANING, errbuf);
  if (errbuf IS NOT NULL) then
    /*srw.message('00', errbuf);*/null;

  end if;

  gl_info.gl_get_lookup_value('M', 'CR', 'GL_DR_CR', CR_MEANING, errbuf);
  if (errbuf IS NOT NULL) then
    /*srw.message('00', errbuf);*/null;

  end if;


  return (TRUE);
end;

procedure gl_get_effective_num (tledger_id       in number,
                                tperiod_name     in varchar2,
                                teffnum          out NOCOPY number,
                                errbuf           out NOCOPY varchar2)
is
  ledger_obj_type  VARCHAR2(1);
  single_ledger_id NUMBER;
BEGIN
  select object_type_code
  into   ledger_obj_type
  from   gl_ledgers
  where  ledger_id = tledger_id;

  if (ledger_obj_type = 'L') then
    single_ledger_id := tledger_id;
  else
    select l.ledger_id
    into   single_ledger_id
    from   gl_ledger_set_assignments ls, gl_ledgers l
    where  ls.ledger_set_id = tledger_id
    and    l.ledger_id = ls.ledger_id
    and    l.object_type_code = 'L'
    and    rownum = 1;
  end if;

  select effective_period_num
  into   teffnum
  from   gl_period_statuses
  where  period_name = tperiod_name
  and    ledger_id = single_ledger_id
  and    application_id = 101;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    errbuf := gl_message.get_message('GL_PLL_INVALID_PERIOD', 'Y',
                                 'PERIOD', tperiod_name,
                                 'LDGID', to_char(tledger_id));

  WHEN OTHERS THEN
    errbuf := SQLERRM;

END;

function g_maingroupfilter(FLEX_SECURE in varchar2) return boolean is
begin
  /*srw.reference(STRUCT_NUM);*/null;

  /*srw.reference(FLEXDATA);*/null;



  if(FLEX_SECURE ='S') then
     return (FALSE);
  else
     return (TRUE);
  end if;

  RETURN NULL;
end;

function begin_bal_dr_crformula(BEGIN_DR in number, BEGIN_CR in number) return char is
begin
  if (BEGIN_DR >= BEGIN_CR) then
    return (DR_MEANING);
  else
    return (CR_MEANING);
  end if;
end;

function end_bal_dr_crformula(END_DR in number, END_CR in number) return char is
begin
  if (END_DR >= END_CR) then
    return (DR_MEANING);
  else
    return (CR_MEANING);
  end if;
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
 Function SELECT_ALL_p return varchar2 is
	Begin
	 return SELECT_ALL;
	 END;
 Function WHERE_FLEX_p return varchar2 is
	Begin
	 return WHERE_FLEX;
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
 Function WHERE_ACTUAL_TYPE_p return varchar2 is
	Begin
	 return WHERE_ACTUAL_TYPE;
	 END;
 Function WHERE_CURRENCY_CODE_p return varchar2 is
	Begin
	 return WHERE_CURRENCY_CODE;
	 END;
 Function SELECT_REFERENCE_p return varchar2 is
	Begin
	 return SELECT_REFERENCE;
	 END;
 Function SELECT_CR_p return varchar2 is
	Begin
	 return SELECT_CR;
	 END;
 Function SELECT_DR_p return varchar2 is
	Begin
	 return SELECT_DR;
	 END;
 Function ORDER_BY_p return varchar2 is
	Begin
	 return ORDER_BY;
	 END;
 Function ORDERBY_BAL2_p return varchar2 is
	Begin
	 return ORDERBY_BAL2;
	 END;
 Function ORDERBY_ACCT2_p return varchar2 is
	Begin
	 return ORDERBY_ACCT2;
	 END;
 Function WHERE_CURRENCY_BAL_p return varchar2 is
	Begin
	 return WHERE_CURRENCY_BAL;
	 END;
 Function SECURITY_FILTER_STR_p return varchar2 is
	Begin
	 return SECURITY_FILTER_STR;
	 END;
 Function RESULTING_CURRENCY_p return varchar2 is
	Begin
	 return RESULTING_CURRENCY;
	 END;
 Function WHERE_DAS_BAL_p return varchar2 is
	Begin
	 return WHERE_DAS_BAL;
	 END;
 Function WHERE_DAS_JE_p return varchar2 is
	Begin
	 return WHERE_DAS_JE;
	 END;
 Function SELECT_BEGIN_DR_p return varchar2 is
	Begin
	 return SELECT_BEGIN_DR;
	 END;
 Function SELECT_BEGIN_CR_p return varchar2 is
	Begin
	 return SELECT_BEGIN_CR;
	 END;
 Function SELECT_END_DR_p return varchar2 is
	Begin
	 return SELECT_END_DR;
	 END;
 Function SELECT_END_CR_p return varchar2 is
	Begin
	 return SELECT_END_CR;
	 END;
 Function PARAM_ACCT_FROM_p return varchar2 is
	Begin
	 return PARAM_ACCT_FROM;
	 END;
 Function PARAM_ACCT_TO_p return varchar2 is
	Begin
	 return PARAM_ACCT_TO;
	 END;
 Function PARAM_PERIOD_FROM_p return varchar2 is
	Begin
	 return PARAM_PERIOD_FROM;
	 END;
 Function PARAM_PERIOD_TO_p return varchar2 is
	Begin
	 return PARAM_PERIOD_TO;
	 END;
 Function PARAM_REFERENCE_TYPE_p return varchar2 is
	Begin
	 return PARAM_REFERENCE_TYPE;
	 END;
 Function DR_MEANING_p return varchar2 is
	Begin
	 return DR_MEANING;
	 END;
 Function CR_MEANING_p return varchar2 is
	Begin
	 return CR_MEANING;
	 END;
 Function PARAM_CURRENCY_TYPE_p return varchar2 is
	Begin
	 return PARAM_CURRENCY_TYPE;
	 END;
END GL_GLRJED_XMLP_PKG ;



/
