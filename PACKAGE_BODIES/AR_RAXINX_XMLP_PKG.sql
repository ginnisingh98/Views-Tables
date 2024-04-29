--------------------------------------------------------
--  DDL for Package Body AR_RAXINX_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_RAXINX_XMLP_PKG" AS
/* $Header: RAXINXB.pls 120.0 2007/12/27 14:28:34 abraghun noship $ */

function AfterReport return boolean is
begin

/*srw.user_exit('FND SRWEXIT');*/null;
  return (TRUE);
end;

function AfterPForm return boolean is
begin
if sortname is not null then
	lp_sortname:=sortname;
end if;
/*srw.user_exit('FND SRWINIT');*/null;



BEGIN

XLA_MO_REPORTING_API.Initialize(p_reporting_level, p_reporting_entity_id, 'AUTO');
p_reporting_entity_name := substrb(XLA_MO_REPORTING_API.get_reporting_entity_name,1,200) ;
p_reporting_level_name :=  substrb(XLA_MO_REPORTING_API.get_reporting_level_name,1,30);
P_ORG_WHERE_CUST := XLA_MO_REPORTING_API.Get_Predicate('CUST', null);
P_ORG_WHERE_DIST := XLA_MO_REPORTING_API.Get_Predicate('DIST', null);
P_ORG_WHERE_TRX  := XLA_MO_REPORTING_API.Get_Predicate('TRX', null);
P_ORG_WHERE_TYPE := XLA_MO_REPORTING_API.Get_Predicate('TYPE',null);


if p_start_gl_date  is NOT NULL then
  lp_start_gl_date  := ' AND dist.gl_date >= :p_start_gl_date ';
  lp_start_trx_date2 := ' AND trx.trx_date >= :p_start_gl_date ';
end if ;
if p_end_gl_date is NOT NULL then
  lp_end_gl_date  := ' and dist.gl_date <= :p_end_gl_date ';
  lp_end_trx_date2 := ' and trx.trx_date <= :p_end_gl_date ';
end if ;

if  p_start_trx_date is NOT NULL then
   lp_start_trx_date := ' AND trx.trx_date >= :p_start_trx_date  ';
end if ;
if  p_end_trx_date  is NOT NULL then
   lp_end_trx_date := ' AND trx.trx_date <= :p_end_trx_date ';
end if ;

if start_currency_code is NOT NULL then
   lp_start_currency := ' AND money.currency_code >= :start_currency_code ';
end if;
if end_currency_code is NOT NULL then
   lp_end_currency := ' AND  money.currency_code <= :end_currency_code ';
end if;

if invoice_type_low is NOT NULL then
   lp_start_trx := ' AND type.name >= :invoice_type_low ';
end if;
if invoice_type_high is NOT NULL then
   lp_end_trx := 'AND type.name <= :invoice_type_high ';
end if;
END;  return (TRUE);
end;

function c_populateformula(COMPANY_NAME in varchar2, c_functional_currency in varchar2) return varchar2 is
begin

BEGIN
   D_COMPANY_NAME := COMPANY_NAME;
   RP_FUNC_CURR   := c_functional_currency;
   RETURN('1');
END;
RETURN NULL; end;

function REPORT_NAMEFormula return varChar is


l_report_name  VARCHAR2(240);

BEGIN
    SELECT cp.user_concurrent_program_name
    INTO   l_report_name
    FROM   FND_CONCURRENT_PROGRAMS_VL cp,
           FND_CONCURRENT_REQUESTS cr
    WHERE  cr.request_id = P_CONC_REQUEST_ID
    AND    cp.application_id = cr.program_application_id
    AND    cp.concurrent_program_id = cr.concurrent_program_id;

    RP_Report_Name := l_report_name;

    RETURN(l_report_name);
EXCEPTION
    WHEN NO_DATA_FOUND
    THEN
     RP_REPORT_NAME := 'Invoice Exception Report';
     RETURN('Invoice Exception Report');

END;

function BeforeReport return boolean is
L_LD_SP VARCHAR2(1);
begin

	P_CONC_REQUEST_ID:=FND_GLOBAL.conc_request_id;
	CP_START_GL_DATE := to_char(P_START_GL_DATE,'DD-MON-YY');
	CP_END_GL_DATE := to_char(P_END_GL_DATE,'DD-MON-YY');
	CP_START_TRX_DATE := TO_CHAR(P_START_TRX_DATE,'DD-MON-YY');
	CP_END_TRX_DATE := TO_CHAR(P_END_TRX_DATE,'DD-MON-YY');
FND_MESSAGE.SET_NAME('AR','AR_REPORT_ACC_NOT_GEN');
cp_acc_message := FND_MESSAGE.get;


/*SRW.REFERENCE(p_coaid);*/null;
	RP_MESSAGE := NULL;
    IF TO_NUMBER(P_REPORTING_LEVEL) = 1000 THEN
      L_LD_SP := MO_UTILS.CHECK_LEDGER_IN_SP(TO_NUMBER(P_REPORTING_ENTITY_ID));
      IF L_LD_SP = 'N' THEN
        FND_MESSAGE.SET_NAME('FND'
                            ,'FND_MO_RPT_PARTIAL_LEDGER');
        RP_MESSAGE := FND_MESSAGE.GET;
      END IF;
    END IF;



if p_in_bal_segment_low is NOT NULL  then

 null;
lp_bal_seg_low := 'and '|| lp_bal_seg_low || '||'''' >= ''' || p_in_bal_segment_low || ''' ';
end if ;
if p_in_bal_segment_high is NOT NULL then

 null;
lp_bal_seg_high := 'and '|| lp_bal_seg_high || '||'''' <= ''' || p_in_bal_segment_high || ''' ';
end if ;

  return (TRUE);
end;

--Functions to refer Oracle report placeholders--

 Function RP_REPORT_NAME_p return varchar2 is
	Begin
	 return substr(RP_REPORT_NAME,1,instr(RP_REPORT_NAME,' (XML)'));
	 END;
 Function CP_ACC_MESSAGE_p return varchar2 is
	Begin
	 return CP_ACC_MESSAGE;
	 END;
  FUNCTION RP_MESSAGE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_MESSAGE;
  END RP_MESSAGE_P;

END AR_RAXINX_XMLP_PKG ;


/
