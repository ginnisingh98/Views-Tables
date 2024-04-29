--------------------------------------------------------
--  DDL for Package Body GL_GLXRCTRS_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_GLXRCTRS_XMLP_PKG" AS
/* $Header: GLXRCTRSB.pls 120.0 2007/12/27 15:07:36 vijranga noship $ */

function BeforeReport return boolean is
begin

/*srw.user_exit('FND SRWINIT');*/null;


declare
  coaid      NUMBER;
  ledgername    VARCHAR2(30);
  functcurr  VARCHAR2(15);
  errbuf     VARCHAR2(132);
  errbuf2    VARCHAR2(132);

BEGIN
  SELECT name,
	 chart_of_accounts_id,
	 currency_code
  INTO ledgername,coaid,functcurr
  FROM gl_ledgers
  WHERE ledger_id = P_LEDGER_ID;

  SELECT name
  INTO c_access_set_name
  FROM GL_ACCESS_SETS
  WHERE access_set_id = P_ACCESS_SET_ID;

  C_BASE_CURR := functcurr;



  C_STRUCT_NUM := coaid;
  C_LEDGER_NAME := ledgername;

EXCEPTION

WHEN OTHERS THEN
  errbuf:= SQLERRM;
 /*srw.message('00',errbuf);*/null;

  raise_application_error(-20101,null);/*srw.program_abort;*/null;


END;



	C_WHERE_DAS :='AND'||' '|| GL_ACCESS_SET_SECURITY_PKG.GET_SECURITY_CLAUSE (
             		P_ACCESS_SET_ID,'R','LEDGER_COLUMN','LEDGER_ID','l','SEG_COLUMN',
			null,'C',NULL);
 	IF C_WHERE_DAS is NULL THEN
    	C_WHERE_DAS := ' 1 = 1';
 	 END IF;





IF P_FLEX_FROM is null OR P_FLEX_TO is null then
    P_FLEX_FROM := null;
    P_FLEX_TO   := null;
END IF;

IF P_START_DATE is null OR P_END_DATE is null then
    P_START_DATE := null;
    P_END_DATE := null;
END IF;

IF P_PERIOD_FROM is null OR P_PERIOD_TO is null then
    P_PERIOD_FROM := null;
    P_PERIOD_TO   := null;
END IF;


/*srw.reference(C_STRUCT_NUM);*/null;


 null;





IF P_FLEX_FROM is not null then
	C_WHERE_FLEX := 'AND '||C_WHERE_FLEX;
ELSE
C_WHERE_FLEX:='';

END IF;



If (P_PERIOD_FROM is not null AND P_PERIOD_TO is not null) THEN
	SELECT start_date, effective_period_num
	INTO  cp_period_start, cp_eff_period_start
	FROM   gl_period_statuses
	WHERE  application_id =101
	AND    closing_status in ('C', 'O', 'P')
	AND    ledger_id = P_LEDGER_ID
	and 	period_name = P_PERIOD_FROM;

	SELECT end_date,effective_period_num
	INTO   cp_period_end,cp_eff_period_end
	FROM   gl_period_statuses
	WHERE  application_id = 101
	AND    closing_status in ('C', 'O', 'P')
	AND    ledger_id = P_LEDGER_ID
	AND  	period_name = P_PERIOD_TO ;


End if ;





	If (P_LEDGER_CURRENCY <> 'All Currencies')
	then
	C_WHERE_CURRENCY := 'AND h.currency_code = :P_LEDGER_CURRENCY';
        else
	C_WHERE_CURRENCY := 'AND h.currency_code <> ''STAT'' ';
	end if;



IF (P_LEDGER_CURRENCY  = 'All Currencies') THEN
    P_AMOUNT_TYPE := 'FUNCTIONAL';
ELSE
    P_AMOUNT_TYPE := 'FOREIGN';
END IF;



if p_rec_unrec ='U'  then
 /*srw.message(1000, 'In Unreconciled Trans...');*/null;

c_where_rec_status := 'AND r.jgzz_recon_status = ''U''
                       AND h.actual_flag =''A''';
C_JGZZ_RECON_FLAG := 'AND C.JGZZ_RECON_FLAG = ''Y'' ';
end if ;

if p_rec_unrec ='R' then
/*srw.message(1001,'In Reconciled Trans..');*/null;

c_where_rec_status := 'AND r.jgzz_recon_status =''R''';
end if;


if C_JGZZ_RECON_FLAG is null then C_JGZZ_RECON_FLAG:='and 1=1'; end if;


  return (TRUE);
end;

function AfterReport return boolean is
begin

/*srw.user_exit('FND SRWEXIT');*/null;

commit;
  return (TRUE);
end;

function P_AMOUNT_TYPEValidTrigger return boolean is
begin

if P_AMOUNT_TYPE NOT IN ('FUNCTIONAL', 'FOREIGN') THEN
    return (FALSE);
END IF;  return (TRUE);
end;

function CF_sysdate_dateFormula return Char is

begin
  return(fnd_date.date_to_chardt(sysdate));
end;

--Functions to refer Oracle report placeholders--

 Function CP_COUNT_REC_p return number is
	Begin
	 return CP_COUNT_REC;
	 END;
 Function C_WHERE_DATE_p return varchar2 is
	Begin
	 return C_WHERE_DATE;
	 END;
 Function C_WHERE_CURRENCY_p return varchar2 is
	Begin
	 return C_WHERE_CURRENCY;
	 END;
 Function C_WHERE_REF_p return varchar2 is
	Begin
	 return C_WHERE_REF;
	 END;
 Function C_RECON_ID_p return number is
	Begin
	 return C_RECON_ID;
	 END;
 Function C_LOGIN_ID_p return number is
	Begin
	 return C_LOGIN_ID;
	 END;
 Function CP_period_start_p return date is
	Begin
	 return CP_period_start;
	 END;
 Function CP_period_end_p return date is
	Begin
	 return CP_period_end;
	 END;
 Function CP_start_date_p return varchar2 is
	Begin
	 return P_start_date;
	 END;
 Function CP_end_date_p return varchar2 is
	Begin
	 return P_end_date;
	 END;
 Function CP_EFF_PERIOD_END_p return number is
	Begin
	 return CP_EFF_PERIOD_END;
	 END;
 Function COUNT_ROWS_p return number is
	Begin
	 return COUNT_ROWS;
	 END;
 Function C_WHERE_DAS_p return varchar2 is
	Begin
	 return C_WHERE_DAS;
	 END;
 Function C_JGZZ_RECON_FLAG_p return varchar2 is
	Begin
	 return C_JGZZ_RECON_FLAG;
	 END;
END GL_GLXRCTRS_XMLP_PKG ;


/
