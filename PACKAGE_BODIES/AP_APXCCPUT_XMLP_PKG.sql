--------------------------------------------------------
--  DDL for Package Body AP_APXCCPUT_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_APXCCPUT_XMLP_PKG" AS
/* $Header: APXCCPUTB.pls 120.0 2007/12/27 07:33:07 vjaganat noship $ */

function cf_masked_card_numberformula(C_TRX_CARD_NUMBER in varchar2) return char is
begin
  CP_MASKED_CARD_NUMBER := C_TRX_CARD_NUMBER;
  return null;
end;

function BeforeReport return boolean is
begin

LP_START_DATE := to_char(P_START_DATE, 'DD-MON-YYYY');
LP_END_DATE := to_char(P_END_DATE, 'DD-MON-YYYY');

DECLARE

  init_failure    EXCEPTION;


BEGIN

   IF p_org_id is not null then

      SELECT  NAME
      INTO    c_organization_name
      FROM    HR_OPERATING_UNITS
      WHERE   ORGANIZATION_ID = p_org_id;

   END IF;


   /*SRW.MESSAGE('1','INPUT PARAMETERS');*/null;

   /*SRW.MESSAGE('1','PROCESS                 :'||p_process);*/null;

   /*SRW.MESSAGE('1','POSTED START DATE       :'||p_start_date);*/null;

   /*SRW.MESSAGE('1','POSTED END DATE         :'||p_end_date);*/null;

   /*SRW.MESSAGE('1','OPERATING UNIT          :'||c_organization_name);*/null;

   /*SRW.MESSAGE('1','CARD ID                 :'||p_card_number);*/null;

   /*SRW.MESSAGE('1','TRANSACTION AMOUNT      :'||p_amount);*/null;



   IF p_org_id is null THEN
     c_organization_name := 'All';
   END IF;

  IF (p_trace_switch = 'Y') THEN
     /*SRW.MESSAGE('2','Trace On');*/null;

     /*SRW.DO_SQL('alter session set sql_trace TRUE');null;*/
     execute immediate 'alter session set sql_trace TRUE';

  END IF;


 /*SRW.USER_EXIT('FND SRWINIT');*/null;



  IF (p_debug_switch = 'Y') THEN
     /*SRW.MESSAGE('2','Before GET_NLS_STRINGS');*/null;

  END IF;

  IF (get_nls_strings() <> TRUE) THEN      RAISE init_failure;
  END IF;



  IF (p_debug_switch = 'Y') THEN
     /*SRW.MESSAGE('3','After Get_NLS_Strings');*/null;

  END IF;






  IF (p_debug_switch = 'Y') THEN
     /*SRW.BREAK;*/null;

  END IF;



  RETURN (TRUE);



EXCEPTION

  WHEN   OTHERS  THEN

    RAISE_application_error(-20101,null);/*SRW.PROGRAM_ABORT;*/null;


END;
  return (TRUE);
end;

FUNCTION  get_nls_strings     RETURN BOOLEAN IS
   nls_all       ap_lookup_codes.displayed_field%TYPE;    nls_yes       fnd_lookups.meaning%TYPE;     nls_no        fnd_lookups.meaning%TYPE;
BEGIN

   nls_all     := '';
   nls_yes     := '';
   nls_no      := '';

   SELECT  ly.meaning,
           ln.meaning,
           la.displayed_field
   INTO    nls_yes,  nls_no,  nls_all
   FROM    fnd_lookups ly,  fnd_lookups ln,  ap_lookup_codes la
   WHERE   ly.lookup_type = 'YES_NO'
     AND   ly.lookup_code = 'Y'
     AND   ln.lookup_type = 'YES_NO'
     AND   ln.lookup_code = 'N'
     AND   la.lookup_type = 'NLS REPORT PARAMETER'
     AND   la.lookup_code = 'ALL';

   c_nls_yes := nls_yes;
   c_nls_no  := nls_no;
   c_nls_all := nls_all;

   /*SRW.USER_EXIT('FND MESSAGE_NAME APPL="SQLAP" NAME="AP_APPRVL_NO_DATA"');*/null;

   /*SRW.USER_EXIT('FND MESSAGE_GET OUTPUT_FIELD=":c_nls_no_data_exists"');*/null;

   /*c_nls_no_data_exists := '*** '||c_nls_no_data_exists||' ***';*/
   c_nls_no_data_exists := 'No Data Found';

   /*SRW.USER_EXIT('FND MESSAGE_NAME APPL="SQLAP" NAME="AP_ALL_END_OF_REPORT"');*/null;

   /*SRW.USER_EXIT('FND MESSAGE_GET OUTPUT_FIELD=":c_nls_end_of_report"');*/null;

   /*c_nls_end_of_report := '*** '||c_nls_end_of_report||' ***';*/
   c_nls_end_of_report := 'End of Report';

RETURN (TRUE);

RETURN NULL; EXCEPTION
   WHEN OTHERS THEN
      RETURN (FALSE);
END;

function c_trx_amount_fformula(C_TRX_AMOUNT_F in varchar2) return char is
 l_trx_amount_f varchar2(20);
begin
  /*SRW.REFERENCE(C_TRX_AMOUNT);*/null;



  L_TRX_AMOUNT_F:=LTRIM(C_TRX_AMOUNT_F);

RETURN(L_TRX_AMOUNT_F);
end;

function AfterReport return boolean is
begin

DECLARE

  init_failure    EXCEPTION;

BEGIN

  IF(custom_init() <> TRUE) THEN
     RAISE init_failure;
  END IF;

  IF (p_debug_switch = 'Y') THEN
     /*SRW.MESSAGE('7','After Custom_Init');*/null;

  END IF;


  /*SRW.USER_EXIT('FND SRWEXIT');*/null;


  IF (P_DEBUG_SWITCH = 'Y') THEN
      /*SRW.MESSAGE('20','After SRWEXIT');*/null;

  END IF;

EXCEPTION
WHEN OTHERS THEN
   RAISE_application_error(-20101,null);/*SRW.PROGRAM_ABORT;*/null;

END;

  return (TRUE);
end;

FUNCTION CUSTOM_INIT RETURN BOOLEAN IS
l_user_id   NUMBER;
BEGIN

l_user_id := FND_GLOBAL.user_id;

IF p_process = 'DEACTIVATE' THEN

                update ap_credit_card_trxns
                set CATEGORY = 'DEACTIVATED',
                    REPORT_HEADER_ID =  -1,
                    LAST_UPDATE_DATE = sysdate,
                    LAST_UPDATED_BY = l_user_id
                WHERE REPORT_HEADER_ID IS NULL
                AND CATEGORY IS NULL
                AND ORG_ID = NVL(p_org_id, ORG_ID)
                AND TRANSACTION_AMOUNT = NVL(p_amount, TRANSACTION_AMOUNT)
                AND POSTED_DATE between  (nvl(p_start_date, POSTED_DATE-1))
                          and p_end_date
                AND CARD_ID = NVL(p_card_number, CARD_ID)
                AND INACTIVE_EMP_WF_ITEM_KEY is NULL;

        ELSE


                update ap_credit_card_trxns
                set CATEGORY = NULL,
                    REPORT_HEADER_ID =  NULL,
                    LAST_UPDATE_DATE = sysdate,
                    LAST_UPDATED_BY = l_user_id
                WHERE REPORT_HEADER_ID = -1
                AND CATEGORY = 'DEACTIVATED'
                AND ORG_ID = NVL(p_org_id, ORG_ID)
                AND TRANSACTION_AMOUNT = NVL(p_amount, TRANSACTION_AMOUNT)
                AND POSTED_DATE between  (nvl(p_start_date, POSTED_DATE-1))
                          and p_end_date
                AND CARD_ID = NVL(p_card_number, CARD_ID)
                AND INACTIVE_EMP_WF_ITEM_KEY is NULL;
        END IF;

   IF p_send_notifications = 'Y' THEN
      senddeactivated() ;
   END IF;
RETURN TRUE;

END;

PROCEDURE SendDeactivated IS
v_employee_id       ap_cards.employee_id%type;
v_card_program_id   ap_cards.card_program_id%type;

cursor cur_sendDeactivated is
select distinct card.employee_id, card.card_program_id
from   ap_credit_card_trxns txn,
       ap_cards card
where  txn.report_header_id = -1
and    txn.category = 'DEACTIVATED'
and    txn.org_id = nvl(p_org_id, txn.org_id)
and    txn.card_id = nvl(p_card_number, txn.card_id)
and    txn.transaction_amount = nvl(p_amount, txn.transaction_amount)
and    txn.posted_date between  (nvl(p_start_date, txn.posted_date-1))
           and p_end_date
and    txn.card_program_id = card.card_program_id
and    txn.card_id = card.card_id
and    card.org_id = nvl(p_org_id, card.org_id)
and    txn.org_id  = card.org_id;


BEGIN
   open cur_sendDeactivated;
   loop

      fetch cur_sendDeactivated into v_employee_id, v_card_program_id;
      exit when cur_sendDeactivated%notfound;

      /*srw.message(999, 'Deactivated transactions for employee: ' || to_char(v_employee_id) ||
                ' card program: ' || to_char(v_card_program_id) );*/null;


      AP_WEB_CREDIT_CARD_WF.SendDeactivatedNotif(v_employee_id,
                                              v_card_program_id,
                                              p_end_date);
   end loop;

   close cur_sendDeactivated;

EXCEPTION
   WHEN OTHERS THEN
   RAISE_application_error(-20101,null);/*SRW.PROGRAM_ABORT;*/null;


END;

--Functions to refer Oracle report placeholders--

 Function CP_MASKED_CARD_NUMBER_p return varchar2 is
	Begin
	 return CP_MASKED_CARD_NUMBER;
	 END;
 Function C_NLS_YES_p return varchar2 is
	Begin
	 return C_NLS_YES;
	 END;
 Function C_NLS_NO_p return varchar2 is
	Begin
	 return C_NLS_NO;
	 END;
 Function C_NLS_ALL_p return varchar2 is
	Begin
	 return C_NLS_ALL;
	 END;
 Function C_NLS_NO_DATA_EXISTS_p return varchar2 is
	Begin
	 return C_NLS_NO_DATA_EXISTS;
	 END;
 Function C_NLS_END_OF_REPORT_p return varchar2 is
	Begin
	 return C_NLS_END_OF_REPORT;
	 END;
 Function C_ORGANIZATION_NAME_p return varchar2 is
	Begin
	 return C_ORGANIZATION_NAME;
	 END;
END AP_APXCCPUT_XMLP_PKG ;



/
