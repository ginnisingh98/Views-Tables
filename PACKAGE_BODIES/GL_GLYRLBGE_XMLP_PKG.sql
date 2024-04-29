--------------------------------------------------------
--  DDL for Package Body GL_GLYRLBGE_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_GLYRLBGE_XMLP_PKG" AS
/* $Header: GLYRLBGEB.pls 120.0 2007/12/27 15:25:39 vijranga noship $ */

function BeforeReport return boolean is
begin

/*SRW.USER_EXIT('FND SRWINIT');*/null;


declare
t_ledger_id            NUMBER;
t_chart_of_accounts_id NUMBER;
t_ledger_name          VARCHAR2(30);
t_func_curr            VARCHAR2(15);
t_period_name          VARCHAR2(15);
t_first_period_name    VARCHAR2(15);
t_segment_num          NUMBER;
t_errorbuffer          VARCHAR2(132);
t_currency_name        VARCHAR2(80);
t_ledger_currency       VARCHAR2(15);

t_target_ledger_id       number:= NULL;

begin

t_ledger_id := to_number(P_LEDGER_ID);
SELECT NAME, CHART_OF_ACCOUNTS_ID
INTO ACCESS_NAME, STRUCT_NUM
FROM GL_ACCESS_SETS
WHERE ACCESS_SET_ID = P_ACCESS_SET_ID;

t_ledger_currency := P_LEDGER_CURRENCY;

gl_ledger_utils_pkg.Get_First_Ledger_Id_From_Set(t_ledger_id,
                                                 t_ledger_currency,
                                                 t_target_ledger_id,
                                                 t_errorbuffer);
if (t_errorbuffer is not NULL) then
   /*SRW.MESSAGE(0,t_errorbuffer);*/null;

   raise_application_error(-20101,null);/*SRW.PROGRAM_ABORT;*/null;

end if;

t_period_name := P_PERIOD_NAME;
gl_get_first_period(t_target_ledger_id,
                    t_period_name,
                    t_first_period_name,
                    t_errorbuffer);
if (t_errorbuffer is not NULL) then
   /*SRW.MESSAGE(0,t_errorbuffer);*/null;

   raise_application_error(-20101,null);/*SRW.PROGRAM_ABORT;*/null;

else
   FIRST_PERIOD_NAME := t_first_period_name;
end if;



/*SRW.REFERENCE(STRUCT_NUM);*/null;


 null;


/*SRW.REFERENCE(STRUCT_NUM);*/null;


 null;


/*SRW.REFERENCE(STRUCT_NUM);*/null;

/*SRW.REFERENCE(P_START_ACCOUNT);*/null;

/*SRW.REFERENCE(P_END_ACCOUNT);*/null;


 null;
   ACCOUNTING_SEGMENT_WHERE := ''||ACCOUNTING_SEGMENT_WHERE;

IF (P_COMPANY IS NOT NULL)
  THEN
  /*SRW.REFERENCE(STRUCT_NUM);*/null;

  /*SRW.REFERENCE(P_COMPANY);*/null;


 null;
   BALANCING_SEGMENT_WHERE := ''||BALANCING_SEGMENT_WHERE;

END IF;

/*SRW.REFERENCE(STRUCT_NUM);*/null;


 null;


/*SRW.REFERENCE(STRUCT_NUM);*/null;


 null;



IF P_CURRENCY_TYPE = 'E' THEN
    CURRENCY_WHERE := 'NVL(BL.TRANSLATED_FLAG,''R'') = ''R''';
    ACTUAL_CURRENCY := P_ENTERED_CURRENCY;
ELSIF P_CURRENCY_TYPE = 'T' THEN
    CURRENCY_WHERE := 'NVL(BL.TRANSLATED_FLAG,''x'') <> ''R''';
    ACTUAL_CURRENCY := P_LEDGER_CURRENCY;
ELSIF P_CURRENCY_TYPE = 'S' THEN
    CURRENCY_WHERE := '(BL.TRANSLATED_FLAG is null)';
    ACTUAL_CURRENCY := P_ENTERED_CURRENCY;
END IF;

ACCESS_WHERE := gl_access_set_security_pkg.get_security_clause
                 (P_ACCESS_SET_ID,
                  'R',
                  'LEDGER_COLUMN',
                  'LEDGER_ID', 'BL',
                  'SEG_COLUMN',
                  null, 'CC', NULL);
IF ACCESS_WHERE is NULL THEN
   ACCESS_WHERE := '1 = 1';
END IF;



end;

  return (TRUE);
end;

function net_crformula(NET in number) return number is
begin

return(-NET);
end;

function comp_net_crformula(COMP_NET in number) return number is
begin

return(-COMP_NET);
end;

function cl_net_crformula(CL_NET in number) return number is
begin

return(-CL_NET);
end;

function sc_net_crformula(SC_NET in number) return number is
begin

return(-SC_NET);
end;

function gr_net_crformula(GR_NET in number) return number is
begin

return(-GR_NET);
end;

procedure gl_get_ledger_info ( ledgerid in number,
                                coaid out NOCOPY number,
                                ledgername out NOCOPY varchar2,
                                func_curr out NOCOPY varchar2,
                                errbuf out NOCOPY varchar2)
  is
  BEGIN
    select name, chart_of_accounts_id, currency_code
    into ledgername, coaid, func_curr
    from gl_ledgers
    where ledger_id = ledgerid;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
     errbuf := gl_message.get_message('GL_PLL_INVALID_LEDGER', 'Y',
                                  'LEDGERID', to_char(ledgerid));

    WHEN OTHERS THEN
      errbuf := SQLERRM;
  END;

procedure gl_get_first_period(tledger_id      in number,
                                tperiod_name   in varchar2,
                                tfirst_period  out NOCOPY varchar2,
                                errbuf         out NOCOPY varchar2)

  is
  BEGIN
    SELECT  a.period_name
    INTO    tfirst_period
    FROM    gl_period_statuses a, gl_period_statuses b
    WHERE   a.application_id = 101
    AND     b.application_id = 101
    AND     a.ledger_id = tledger_id
    AND     b.ledger_id = tledger_id
    AND     a.period_type = b.period_type
    AND     a.period_year = b.period_year
    AND     b.period_name = tperiod_name
    AND     a.period_num =
     (SELECT min(c.period_num)
                   FROM gl_period_statuses c
             WHERE c.application_id = 101
               AND c.ledger_id = tledger_id
               AND c.period_year = a.period_year
               AND c.period_type = a.period_type
          GROUP BY c.period_year);
EXCEPTION
  WHEN NO_DATA_FOUND THEN
        errbuf := gl_message.get_message('GL_PLL_INVALID_FIRST_PERIOD', 'Y',
                                 'PERIOD', tperiod_name,
                                 'LEDGERID', to_char(tledger_id));
  WHEN OTHERS THEN

       errbuf := SQLERRM;


  END;

function grand_net_crformula(GRAND_NET in number) return number is
begin

return(-GRAND_NET);
end;

function c_bal_lpromptformula(C_BAL_LPROMPT in varchar2) return varchar2 is
begin

/*srw.reference(COMPANY_NAME);*/null;

declare
    temp_char  VARCHAR2(240);
begin
    temp_char := C_BAL_LPROMPT||':' ;
    return(temp_char) ;
end ;
RETURN NULL; end;

procedure get_industry_code is

w_industry_code varchar2(20);
w_industry_stat varchar2(20);

begin

if fnd_installation.get(0, 0,
                        w_industry_stat,
	    	        w_industry_code) then
 c_industry_code :=   w_Industry_code ;

end if;

end ;

function set_display_for_gov return boolean is

begin


if c_industry_code = 'C' then
   return(FALSE);
else
   return(TRUE);
end if;

RETURN NULL; end ;

function set_display_for_core return boolean is

begin

if c_industry_code = 'C' then
   return(TRUE);
else
   return(FALSE);
end if;

RETURN NULL; end;

function g_maingroupfilter(ACCT_SECURE in varchar2, BEGIN_CR in number, BEGIN_DR in number, PER_DR in number, PER_CR in number) return boolean is
begin

  /*SRW.REFERENCE(STRUCT_NUM);*/null;

  /*SRW.REFERENCE(ACCOUNT);*/null;



  if(ACCT_SECURE = 'S' ) then
      return (FALSE);
  else
      return (TRUE);
  end if;
  IF (BEGIN_CR <> 0 OR
     BEGIN_DR <> 0 OR
     PER_DR <> 0 OR
     PER_CR <> 0 ) THEN
     RETURN(TRUE);
  ELSE
     RETURN(FALSE);
  END IF;

RETURN NULL; end;

function g_companygroupfilter(BAL_SECURE in varchar2) return boolean is
begin

  /*SRW.REFERENCE(STRUCT_NUM);*/null;

  /*SRW.REFERENCE(COMPANY);*/null;



  if(BAL_SECURE ='S') then
     return (FALSE);
  else
     return (TRUE);
  END IF;

RETURN NULL; end;

function G_ClassGroupFilter return boolean is
begin


  return (TRUE);
end;

function zero_indicatorformula(BEGIN_CR in number, BEGIN_DR in number, PER_DR in number, PER_CR in number) return number is
begin
  IF (BEGIN_CR <> 0 OR
     BEGIN_DR <> 0 OR
     PER_DR <> 0 OR
     PER_CR <> 0) THEN
     RETURN(1);
  ELSE
     RETURN(0);
  END IF;


 return null;
end;

function g_sub_classgroupfilter(BEGIN_CR in number, BEGIN_DR in number, PER_DR in number, PER_CR in number) return boolean is
begin

  IF (BEGIN_CR <> 0 OR
     BEGIN_DR <> 0 OR
     PER_DR <> 0 OR
     PER_CR <> 0 ) THEN
     RETURN(TRUE);
  ELSE
     RETURN(FALSE);
  END IF;

  return (TRUE);
end;

function g_groupsgroupfilter(BEGIN_CR in number, BEGIN_DR in number, PER_DR in number, PER_CR in number) return boolean is
begin

  IF (BEGIN_CR <> 0 OR
     BEGIN_DR <> 0 OR
     PER_DR <> 0 OR
     PER_CR <> 0 ) THEN
     RETURN(TRUE);
  ELSE
     RETURN(FALSE);
  END IF;

  return (TRUE);
end;

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

function AfterReport return boolean is
begin

  /*SRW.USER_EXIT('FND SRWEXIT');*/null;

  return (TRUE);
end;

--Functions to refer Oracle report placeholders--

 Function BEGIN_CR_SELECT_p return varchar2 is
	Begin
	 return BEGIN_CR_SELECT;
	 END;
 Function CURRENCY_NAME_p return varchar2 is
	Begin
	 return CURRENCY_NAME;
	 END;
 Function ACCOUNTING_SEGMENT_WHERE_p return varchar2 is
	Begin
	 return ACCOUNTING_SEGMENT_WHERE;
	 END;
 Function BEGIN_DR_SELECT_p return varchar2 is
	Begin
	 return BEGIN_DR_SELECT;
	 END;
 Function END_DR_SELECT_p return varchar2 is
	Begin
	 return END_DR_SELECT;
	 END;
 Function FIRST_PERIOD_NAME_p return varchar2 is
	Begin
	 return FIRST_PERIOD_NAME;
	 END;
 Function ACCOUNTING_ORDERBY_p return varchar2 is
	Begin
	 return ACCOUNTING_ORDERBY;
	 END;
 Function BALANCING_ORDERBY_p return varchar2 is
	Begin
	 return BALANCING_ORDERBY;
	 END;
 Function BALANCING_SEGMENT_WHERE_p return varchar2 is
	Begin
	 return BALANCING_SEGMENT_WHERE;
	 END;
 Function STRUCT_NUM_p return varchar2 is
	Begin
	 return STRUCT_NUM;
	 END;
 Function BALANCING_SEGMENT_p return varchar2 is
	Begin
	 return BALANCING_SEGMENT;
	 END;
 Function PER_DR_SELECT_p return varchar2 is
	Begin
	 return PER_DR_SELECT;
	 END;
 Function ACCOUNTING_SEGMENT_p return varchar2 is
	Begin
	 return ACCOUNTING_SEGMENT;
	 END;
 Function END_CR_SELECT_p return varchar2 is
	Begin
	 return END_CR_SELECT;
	 END;
 Function PER_CR_SELECT_p return varchar2 is
	Begin
	 return PER_CR_SELECT;
	 END;
 Function TRANSLATE_WHERE_p return varchar2 is
	Begin
	 return TRANSLATE_WHERE;
	 END;
 Function C_industry_code_p return varchar2 is
	Begin
	 return C_industry_code;
	 END;
 Function CURRENCY_WHERE_p return varchar2 is
	Begin
	 return CURRENCY_WHERE;
	 END;
 Function ACCESS_WHERE_p return varchar2 is
	Begin
	 return ACCESS_WHERE;
	 END;
 Function ACTUAL_CURRENCY_p return varchar2 is
	Begin
	 return ACTUAL_CURRENCY;
	 END;
 Function ACCESS_NAME_p return varchar2 is
	Begin
	 return ACCESS_NAME;
	 END;
END GL_GLYRLBGE_XMLP_PKG ;



/
