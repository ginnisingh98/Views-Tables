--------------------------------------------------------
--  DDL for Package Body GL_GLXETB_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_GLXETB_XMLP_PKG" AS
/* $Header: GLXETBB.pls 120.0 2007/12/27 14:58:02 vijranga noship $ */

function ENCUMBRANCE_TYPEFormula return VARCHAR2 is
name     VARCHAR2(30);
  errbuf   VARCHAR2(132);
  errbuf2  VARCHAR2(132);
begin

  gl_info.gl_get_bud_or_enc_name('E',
                                 P_ENCUMBRANCE_TYPE_ID,
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

function AfterReport return boolean is
begin
  /*srw.user_exit('FND SRWEXIT');*/null;

  return (TRUE);
end;

function end_balformula(BEGIN_BAL in number, DEBITS in number, CREDITS in number) return number is
begin
  return (BEGIN_BAL + DEBITS - CREDITS);
end;

function BeforeReport return boolean is
errbuf      VARCHAR2(132);
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

  WHERE_DAS := GL_ACCESS_SET_SECURITY_PKG.GET_SECURITY_CLAUSE(
                  P_ACCESS_SET_ID,
                  'R',
                  'LEDGER_COLUMN',
                  'LEDGER_ID',
                  'BAL',
                  'SEG_COLUMN',
                  null,
                  'CC',
                  null);

  if (WHERE_DAS is not null) then
    WHERE_DAS := ' and ' || WHERE_DAS;
  end if;

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

  /*srw.reference(STRUCT_NUM);*/null;


 null;


  begin
    SELECT currency_code, object_type_code
    INTO   PARAM_LEDGER_CURR, PARAM_LEDGER_TYPE
    FROM   gl_ledgers
    WHERE  ledger_id = P_LEDGER_ID;
  exception
    WHEN OTHERS THEN
      errbuf := SQLERRM;
      /*srw.message('00', errbuf);*/null;

      raise_application_error(-20101,null);/*srw.program_abort;*/null;

  end;

  IF (PARAM_LEDGER_TYPE = 'S') THEN
    FROM_LEDGER := ', GL_LEDGER_SET_ASSIGNMENTS LS';
    WHERE_LEDGER := 'AND LS.ledger_set_id = ' || to_char(P_LEDGER_ID) ||
                     ' AND BAL.ledger_id = LS.ledger_id ';


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
  ELSE
    FROM_LEDGER := ' ';
    WHERE_LEDGER := 'AND BAL.ledger_id = ' || to_char(P_LEDGER_ID) || ' ';
  END IF;

  return (TRUE);
end;

function g_page_breakgroupfilter(BAL_SECURE in varchar2) return boolean is
begin
  /*srw.reference(BAL_DATA);*/null;



  if (BAL_SECURE ='S') then
    return(FALSE);
  else
    return (TRUE);
  end if;

  RETURN NULL;
end;

function g_acct_datagroupfilter(ACCT_SECURE in varchar2) return boolean is
begin
  /*srw.reference(ACCTDATA);*/null;



  if (ACCT_SECURE = 'S') then
    return (FALSE);
  else
    return (TRUE);
  end if;

  RETURN NULL;
end;

function g_balancesgroupfilter(FLEX_SECURE in varchar2) return boolean is
begin
  /*srw.reference(STRUCT_NUM);*/null;

  /*srw.reference(FLEXDATA);*/null;



  if (FLEX_SECURE = 'S') then
    return(FALSE);
  else
    return (TRUE);
  end if;

  RETURN NULL;
end;

function gl_format_currency(Amount  NUMBER) return varchar2 is
  num_amount   NUMBER;
  dsp_amount   VARCHAR2(100);
  WIDTH        NUMBER := 19;
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

 Function STRUCT_NUM_p return varchar2 is
	Begin
	 return STRUCT_NUM;
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
 Function ORDERBY_BAL2_p return varchar2 is
	Begin
	 return ORDERBY_BAL2;
	 END;
 Function ORDERBY_ACCT2_p return varchar2 is
	Begin
	 return ORDERBY_ACCT2;
	 END;
 Function ACCESS_SET_NAME_p return varchar2 is
	Begin
	 return ACCESS_SET_NAME;
	 END;
 Function WHERE_DAS_p return varchar2 is
	Begin
	 return WHERE_DAS;
	 END;
 Function PARAM_LEDGER_CURR_p return varchar2 is
	Begin
	 return PARAM_LEDGER_CURR;
	 END;
 Function PARAM_LEDGER_TYPE_p return varchar2 is
	Begin
	 return PARAM_LEDGER_TYPE;
	 END;
 Function MIXED_PRECISION_p return number is
	Begin
	 return MIXED_PRECISION;
	 END;
 Function THOUSANDS_SEPARATOR_p return varchar2 is
	Begin
	 return THOUSANDS_SEPARATOR;
	 END;
 Function CURR_FORMAT_MASK_p return varchar2 is
	Begin
	 return CURR_FORMAT_MASK;
	 END;
 Function FROM_LEDGER_p return varchar2 is
	Begin
	 return FROM_LEDGER;
	 END;
 Function WHERE_LEDGER_p return varchar2 is
	Begin
	 return WHERE_LEDGER;
	 END;
END GL_GLXETB_XMLP_PKG ;


/
