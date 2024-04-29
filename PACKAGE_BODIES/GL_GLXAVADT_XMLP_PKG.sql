--------------------------------------------------------
--  DDL for Package Body GL_GLXAVADT_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_GLXAVADT_XMLP_PKG" AS
/* $Header: GLXAVADTB.pls 120.3 2008/01/07 20:07:22 vijranga noship $ */

function BeforeReport return boolean is
errbuf  VARCHAR2(132);
  errbuf2 VARCHAR2(132);

  v_period_year 	NUMBER;
  v_quarter_num 	NUMBER;
  v_period_num  	NUMBER;
  v_start_period_name	VARCHAR2(15);
  v_start_date  	DATE;
begin

  /*srw.user_exit('FND SRWINIT');*/null;



  begin
    SELECT name, chart_of_accounts_id, period_set_name, accounted_period_type
  --  INTO   ACCESS_SET_NAME, STRUCT_NUM, PERIOD_SET_NAME, PERIOD_TYPE
    INTO   ACCESS_SET_NAME, STRUCT_NUM, PERIOD_SET_NAME_1, PERIOD_TYPE_1
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


 /* gl_get_period_info(P_LEDGER_ID,
                     P_REPORTING_DATE,
                     PERIOD_SET_NAME,
                     v_period_year,
                     v_quarter_num,
                     v_period_num,
                     errbuf);*/

gl_get_period_info(P_LEDGER_ID,
                     P_REPORTING_DATE,
                     PERIOD_SET_NAME_1,
                     v_period_year,
                     v_quarter_num,
                     v_period_num,
                     errbuf);
  if (errbuf is not null) then

    errbuf2 := gl_message.get_message(
                  		'GL_PLL_ROUTINE_ERROR', 'N',
                   		'ROUTINE','gl_get_period_info'
                 		);
    /*srw.message('00', errbuf2);*/null;

    /*srw.message('00', errbuf);*/null;

    raise_application_error(-20101,null);/*srw.program_abort;*/null;

  end if;

 -- PERIOD_YEAR := v_period_year;
  PERIOD_YEAR_1:= v_period_year;
  QUARTER_NUM := v_quarter_num;
  PERIOD_NUM := v_period_num;

  /*gl_get_first_date(P_LEDGER_ID,
                    P_BALANCE_TYPE,
                    PERIOD_YEAR,
                    QUARTER_NUM,
                    PERIOD_NUM,
		    v_start_period_name,
                    v_start_date,
                    errbuf);*/
gl_get_first_date(P_LEDGER_ID,
                    P_BALANCE_TYPE,
                    PERIOD_YEAR_1,
                    QUARTER_NUM,
                    PERIOD_NUM,
		    v_start_period_name,
                    v_start_date,
                    errbuf);

  if (errbuf is not null) then

    errbuf2 := gl_message.get_message(
                 		'GL_PLL_ROUTINE_ERROR', 'N',
                 		'ROUTINE','gl_get_first_date'
               			);
    /*srw.message('00', errbuf2);*/null;

    /*srw.message('00', errbuf);*/null;

    raise_application_error(-20101,null);/*srw.program_abort;*/null;

  end if;

  START_DATE := v_start_date;
  START_PERIOD_NAME := v_start_period_name;

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
                  'LEDGER_ID',
                  P_LEDGER_ID,
                  null,
                  'SEG_COLUMN',
                  null,
                  'CC',
                  null);

  IF (WHERE_DAS is not null) THEN
    WHERE_DAS := ' AND ' || WHERE_DAS;
    else
     WHERE_DAS:=' ';
  END IF;


  begin
    SELECT name, currency_code
    INTO   LEDGER_NAME, LEDGER_CURRENCY
    FROM   gl_ledgers
    WHERE  ledger_id = P_LEDGER_ID;

  exception
    WHEN OTHERS THEN
      errbuf := SQLERRM;
      /*srw.message('00', errbuf);*/null;

      raise_application_error(-20101,null);/*srw.program_abort;*/null;

  end;

  if (P_CURRENCY_TYPE = 'T') then
    REPORTING_CURR := LEDGER_CURRENCY;
  else
    REPORTING_CURR := P_ENTERED_CURRENCY;
  end if;

  return (TRUE);
end;

function opening_balformula(CCID in number) return number is
  min_startdate DATE;
  eod_bal NUMBER;
  open_bal NUMBER;
begin
  IF (gl_code_combinations_pkg.check_net_income_account(CCID)) THEN


    IF (P_balance_type = 'YATD') THEN
      return(0);

    ELSE
      SELECT min(start_date)
      INTO min_startdate
      FROM GL_PERIOD_STATUSES
      WHERE application_id = 101
      AND ledger_id = P_LEDGER_ID
     -- AND period_year = PERIOD_YEAR
      AND period_year = PERIOD_YEAR_1
      AND closing_status || '' in ('P', 'C', 'O')
      AND adjustment_period_flag = 'N';



      IF (min_startdate = START_DATE) THEN
        return(0);
      ELSE
        SELECT nvl(end_of_date_balance_num, 0)
        INTO eod_bal
        FROM GL_DAILY_BALANCES_V DBAL
       -- WHERE dbal.period_set_name = PERIOD_SET_NAME
        WHERE dbal.period_set_name = PERIOD_SET_NAME_1
       -- AND dbal.period_type = PERIOD_TYPE
       AND dbal.period_type = PERIOD_TYPE_1
        AND dbal.ledger_id = P_LEDGER_ID
        AND dbal.currency_code = REPORTING_CURR
        AND dbal.currency_type = decode(P_CURRENCY_TYPE, 'E', 'E', 'U')
        AND dbal.code_combination_id = CCID
        AND dbal.accounting_date =
             (SELECT ps.end_date
              FROM gl_period_statuses ps,
                   gl_date_period_map dpm
              WHERE dpm.accounting_date = (START_DATE -1)
             -- AND dpm.period_set_name = PERIOD_SET_NAME
	      AND dpm.period_set_name = PERIOD_SET_NAME_1
             -- AND dpm.period_type = PERIOD_TYPE
	     AND dpm.period_type = PERIOD_TYPE_1
              AND ps.period_name = dpm.period_name
              AND ps.application_id = 101
              AND ps.ledger_id = P_LEDGER_ID);
        return(eod_bal);
      END IF;
    END IF ;

  ELSE


    SELECT nvl(begin_balance_dr, 0) - nvl(begin_balance_cr, 0)
    INTO open_bal
    FROM GL_BALANCES
    WHERE code_combination_id  = CCID
    AND period_name = START_PERIOD_NAME
    AND ledger_id = P_LEDGER_ID
    AND currency_code = REPORTING_CURR
    AND actual_flag = 'A'
    AND nvl(translated_flag, 'R') = 'R';

    return(open_bal);
  END IF;

EXCEPTION
  when NO_DATA_FOUND then
    return(0);

end;

function last_ccidformula(last_ccid in number, ccid in number, opening_bal in number) return number is
begin
  IF ((last_ccid IS NULL) OR (last_ccid <> ccid)) THEN
    last_eod := opening_bal;
     return(ccid);
  ELSE
    return(ccid);
  end if;

  RETURN NULL;
end;

function daily_activityformula(end_of_date_balance in number) return number is
  da NUMBER;
begin
  /*srw.reference(last_ccid);*/null;

  da := end_of_date_balance - last_eod;
  last_eod := end_of_date_balance;
  return(da);
end;

function AfterReport return boolean is
begin
  /*srw.user_exit('FND SRWEXIT');*/null;

  return (TRUE);
end;

procedure gl_get_period_info (ldgrid 		   in number,
                                reporting_date     in date,
                                calendar_name      in varchar2,
                                v_period_year      out NOCOPY number,
                                v_quarter_num      out NOCOPY number,
                                v_period_num       out NOCOPY number,
				errbuf	   	   out NOCOPY varchar2 )
  is

  BEGIN

 	select ps.period_year, ps.quarter_num, ps.period_num
 	into   v_period_year, v_quarter_num, v_period_num
 	from gl_period_statuses ps, gl_date_period_map dpm
 	where dpm.accounting_date  = reporting_date
        and dpm.period_set_name = calendar_name
       -- and dpm.period_type = PERIOD_TYPE
       and dpm.period_type = PERIOD_TYPE_1
       and dpm.period_name = ps.period_name
        and ps.application_id = 101
        and ps.ledger_id = ldgrid;

  EXCEPTION

  WHEN NO_DATA_FOUND THEN

	errbuf := gl_message.get_message('GL_PLL_INVALID_DATE', 'Y');

  WHEN OTHERS THEN

	errbuf := SQLERRM;

  END;

procedure gl_get_first_date(ldgrid            in number,
			      balance_type     in varchar2,
                              v_period_year    in number,
                              v_quarter_num    in number,
                              v_period_num     in number,
                              v_period_name    out NOCOPY varchar2,
                              v_start_date     out NOCOPY date,
			      errbuf           out NOCOPY varchar2)
  is

  BEGIN
    select ps.period_name, ps.start_date
    into v_period_name, v_start_date
    from gl_period_statuses ps
    where ps.application_id = 101
    and ps.ledger_id = ldgrid
    and ps.adjustment_period_flag = 'N'
    and ps.start_date =
                      (select min(ps1.start_date)
                       from gl_period_statuses ps1
                       where ps1.application_id = 101
                       and ps1.ledger_id = ldgrid
                       and ps1.period_year = v_period_year
                       and ps1.quarter_num = decode(balance_type,
                                                    'QATD', v_quarter_num,
                                                    ps1.quarter_num)
                       and ps1.period_num = decode(balance_type,
                                                   'PATD', v_period_num,
                                                   ps1.period_num)
                       and ps1.closing_status in ('P', 'C', 'O')
                       and ps1.adjustment_period_flag = 'N');

  EXCEPTION

  WHEN NO_DATA_FOUND THEN

	null;

  WHEN OTHERS THEN

	errbuf := SQLERRM;

  END;

function g_balancing_seggroupfilter(BAL_SECURE in varchar2) return boolean is
begin
  /*srw.reference(STRUCT_NUM);*/null;

  /*srw.reference(BAL_DATA);*/null;



  if(BAL_SECURE ='S') then
    return (FALSE);
  else
    return (TRUE);
  end if;

  RETURN NULL;
end;

function g_opening_balgroupfilter(ACCT_SECURE in varchar2) return boolean is
begin
  /*srw.reference(FLEXDATA);*/null;



  if(ACCT_SECURE ='S') then
     return (FALSE);
  else
     return (TRUE);
  end if;

  RETURN NULL;
end;

--Functions to refer Oracle report placeholders--

 Function last_eod_p return number is
	Begin
	 return last_eod;
	 END;
 Function STRUCT_NUM_p return number is
	Begin
	 return STRUCT_NUM;
	 END;
 Function LEDGER_NAME_p return varchar2 is
	Begin
	 return LEDGER_NAME;
	 END;
 Function PERIOD_SET_NAME_p return varchar2 is
	Begin
	-- return PERIOD_SET_NAME;
	 return PERIOD_SET_NAME_1;
	 END;
 Function PERIOD_YEAR_p return number is
	Begin
	 --return PERIOD_YEAR;
	 return PERIOD_YEAR_1;
	 END;
 Function QUARTER_NUM_p return number is
	Begin
	 return QUARTER_NUM;
	 END;
 Function PERIOD_NUM_p return number is
	Begin
	 return PERIOD_NUM;
	 END;
 Function REPORTING_CURR_p return varchar2 is
	Begin
	 return REPORTING_CURR;
	 END;
 Function START_DATE_p return date is
	Begin
	 return START_DATE;
	 END;
 Function START_PERIOD_NAME_p return varchar2 is
	Begin
	 return START_PERIOD_NAME;
	 END;
 Function SELECT_BAL_p return varchar2 is
	Begin
	 return SELECT_BAL;
	 END;
 Function WHERE_FLEX_RANGE_p return varchar2 is
	Begin
	 return WHERE_FLEX_RANGE;
	 END;
 Function SELECT_ALL_p return varchar2 is
	Begin
	 return SELECT_ALL;
	 END;
 Function ORDERBY_BAL_p return varchar2 is
	Begin
	 return ORDERBY_BAL;
	 END;
 Function ORDERBY_ALL_p return varchar2 is
	Begin
	 return ORDERBY_ALL;
	 END;
 Function ORDERBY_ACCT_p return varchar2 is
	Begin
	 return ORDERBY_ACCT;
	 END;
 Function PERIOD_TYPE_p return varchar2 is
	Begin
	-- return PERIOD_TYPE;
	return PERIOD_TYPE_1;
	 END;
 Function ACCESS_SET_NAME_p return varchar2 is
	Begin
	 return ACCESS_SET_NAME;
	 END;
 Function WHERE_DAS_p return varchar2 is
	Begin
	 return WHERE_DAS;
	 END;
 Function LEDGER_CURRENCY_p return varchar2 is
	Begin
	 return LEDGER_CURRENCY;
	 END;
END GL_GLXAVADT_XMLP_PKG ;

/
