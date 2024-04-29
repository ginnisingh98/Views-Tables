--------------------------------------------------------
--  DDL for Package Body AR_ARXTDR_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_ARXTDR_XMLP_PKG" AS
/* $Header: ARXTDRB.pls 120.0 2007/12/27 14:10:31 abraghun noship $ */

function report_nameformula(Company_Name in varchar2) return varchar2 is
begin

DECLARE
        l_report_name   VARCHAR2(80);
BEGIN
        RP_Company_Name := Company_Name;
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
        WHEN OTHERS THEN
        RP_Report_Name := NULL;
        RETURN(NULL);
END;

RETURN NULL; end;

function YES_MEANINGFormula return VARCHAR2 is
begin

DECLARE
        l_meaning  VARCHAR2(80);
BEGIN
        SELECT MEANING
        INTO   l_meaning
        FROM   AR_LOOKUPS
        WHERE  LOOKUP_TYPE = 'YES/NO'
        AND    LOOKUP_CODE = 'Y';

        RETURN(l_meaning);
END;
RETURN NULL; end;

function NO_MEANINGFormula return VARCHAR2 is
begin

DECLARE
        l_meaning  VARCHAR2(80);
BEGIN
        SELECT MEANING
        INTO   l_meaning
        FROM   AR_LOOKUPS
        WHERE  LOOKUP_TYPE = 'YES/NO'
        AND    LOOKUP_CODE = 'N';

        RETURN(l_meaning);
END;
RETURN NULL; end;

function TRX_FLEX_DELIMFormula return VARCHAR2 is
begin

DECLARE
           delimiter   VARCHAR2(2);
BEGIN


           return('.');
END;
RETURN NULL; end;

function LOC_FLEX_ALL_SEGFormula return VARCHAR2 is
begin


RETURN null;
end;

function BeforeReport return boolean is
begin
    P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
/*SRW.USER_EXIT('FND SRWINIT');*/null;
/* ADDED AS A FIX */
P_TRANSACTION_TYPE_DUMMY := NVL(P_TRANSACTION_TYPE,'ALL');
/* FIX ENDS */


begin

     /*srw.message ('100', 'BeforeReport:  Get Consolidated Billing Number Profile');*/null;


 P_CONS_PROFILE_VALUE := AR_SETUP.value('AR_SHOW_BILLING_NUMBER',null);


exception
     when others then
          /*srw.message ('101', 'Consolidated Billing Profile:  ' || P_CONS_PROFILE_VALUE);*/null;

end;


If    ( P_CONS_PROFILE_VALUE = 'N' ) then
      lp_query_show_bill        := 'to_char(NULL)';
      --lp_table_show_bill        := null;
      --lp_where_show_bill        := null;

lp_table_show_bill        := ' ';
lp_where_show_bill        := ' ';

Else  lp_query_show_bill        := 'ci.cons_billing_number';
      lp_table_show_bill        := 'ar_cons_inv ci,';
      lp_where_show_bill        := 'and arps.cons_inv_id = ci.cons_inv_id(+)';

End if;

select language_code
into p_base_lang
from fnd_languages
where installed_flag  = 'B';

/*srw.message('102','Base language = ' || p_base_lang);*/null;




  RP_TX_CUST_TRX_ID := 0;

  return (TRUE);
end;

function AfterReport return boolean is
begin

/*SRW.USER_EXIT('FND SRWEXIT');*/null;
  return (TRUE);
end;

function ship_to_address5formula(ship_to_city in varchar2, ship_to_state in varchar2, ship_to_postal_code in varchar2, ship_to_country in varchar2) return varchar2 is
begin

/*srw.reference(ship_to_city);*/null;

/*srw.reference(ship_to_state);*/null;

/*srw.reference(ship_to_postal_code);*/null;

return(ship_to_city|| ' ' || ship_to_state || ' ' || ship_to_postal_code || ' ' ||ship_to_country);
end;

function bill_to_address5formula(bill_to_city in varchar2, bill_to_state in varchar2, bill_to_postal_code in varchar2, bill_to_country in varchar2) return varchar2 is
begin

RP_DATA_FOUND := 'YES';
/*srw.reference(bill_to_city);*/null;

/*srw.reference(bill_to_state);*/null;

/*srw.reference(bill_to_postal_code);*/null;

return(bill_to_city|| ' ' || bill_to_state || ' ' || bill_to_postal_code || ' ' || bill_to_country);

end;

function d_sold_toformula(sold_to_customer_number in varchar2,sold_to_customer_name in varchar2) return varchar2 is
begin

/*srw.reference(sold_to_customer_number);*/null;

/*srw.reference(sold_to_customer_name);*/null;


return(sold_to_customer_number ||sold_to_customer_name);
end;

function d_remit_toformula(remit_to_address1 in varchar2, remit_to_address2 in varchar2, remit_to_address3 in varchar2, remit_to_address4 in varchar2,
remit_to_city in varchar2, remit_to_state in varchar2, remit_to_postal_code in varchar2, remit_to_country in varchar2) return varchar2 is

begin

/*srw.reference(remit_to_address1);*/null;

/*srw.reference(remit_to_address2);*/null;

/*srw.reference(remit_to_address3);*/null;

/*srw.reference(remit_to_address4);*/null;

/*srw.reference(remit_to_city);*/null;

/*srw.reference(remit_to_state);*/null;

/*srw.reference(remit_to_postal_code);*/null;

/*srw.reference(remit_to_country);*/null;



return(remit_to_address1||' '||remit_to_address2||' '||remit_to_address3||' '||remit_to_address4||' '||
              remit_to_city||' ' ||
              remit_to_state||' '||
              remit_to_postal_code||' '||
              remit_to_country);
end;

function D_LOCATIONFormula return VARCHAR2 is
begin


RETURN null;
end;

function ITEM_FLEX_STRUCTUREFormula return Number is
   l_item_flex    VARCHAR2(50);
    l_item_flex_structure NUMBER ;
 begin

   /* srw.message ('100', 'ITEM_FLEX_STRUCTUREFormula');*/null;

     oe_profile.get('SO_ORGANIZATION_ID', l_item_flex_structure );

     l_item_flex := l_item_flex_structure ;
     /*srw.message ('100', 'ITEM_FLEX_STRUCTUREFormula:  Item Flex Structure:  ' || l_item_flex);*/null;

     RETURN(l_item_flex_structure );
end;
function RP_INV_RANGEFormula return VARCHAR2 is
begin

RETURN(' ' || P_INVOICE_NUM_LOW || ' - '
       || P_INVOICE_NUM_HIGH);
end;

function tr_inv_amountformula(TR_LN_EXTD_AMOUNT in number, TR_TX_EXTD_AMOUNT in number, TR_FR_EXTD_AMOUNT in number) return number is
begin

/*SRW.REFERENCE(TR_LN_EXTD_AMOUNT);*/null;

/*SRW.REFERENCE(TR_TX_EXTD_AMOUNT);*/null;

/*SRW.REFERENCE(TR_FR_EXTD_AMOUNT);*/null;

RETURN( NVL(TR_LN_EXTD_AMOUNT, 0) + NVL(TR_TX_EXTD_AMOUNT,0) +
        NVL(TR_FR_EXTD_AMOUNT,0));
end;

function ln_additional_infoformula(LN_ORDER_NUMBER in varchar2, LN_ORDER_DATE in date, LN_ORDER_REVISION in number, LN_SALES_CHANNEL in varchar2,
LN_DURATION in number, LN_ACCOUNTING_RULE in varchar2, LN_RULE_START_DATE in date) return varchar2 is
begin

DECLARE
         l_additional_info     VARCHAR2(100);
BEGIN
         /*SRW.REFERENCE(LN_ORDER_NUMBER);*/null;

         /*SRW.REFERENCE(LN_ORDER_DATE);*/null;

         /*SRW.REFERENCE(LN_ORDER_REVISION);*/null;

         /*SRW.REFERENCE(LN_SALES_CHANNEL);*/null;

         /*SRW.REFERENCE(LN_DURATION);*/null;

         /*SRW.REFERENCE(LN_ACCOUNTING_RULE);*/null;

         /*SRW.REFERENCE(LN_RULE_START_DATE);*/null;


         l_additional_info := LN_ORDER_NUMBER ||
                              to_char(LN_ORDER_DATE, 'DD-MON-YYYY') ||
                              to_char(LN_ORDER_REVISION) ||
                              LN_SALES_CHANNEL ||
                              to_char(LN_DURATION) ||
                              LN_ACCOUNTING_RULE ||
                              to_char(LN_RULE_START_DATE,
                                      'DD-MON-YYYY');
RETURN(l_additional_info);
END;
RETURN NULL; end;

function trx_transaction_flexformula(customer_trx_id in number) return varchar2 is
begin

/*srw.reference(customer_trx_id);*/null;


declare
   context varchar2(100);
   concatenated_segments  varchar2(1000);

begin
    arp_descr_flex.get_concatenated_segments('RA_INTERFACE_HEADER',
                                             'RA_CUSTOMER_TRX',
                                             to_number(customer_trx_id),
                                             0,
                                             concatenated_segments,
                                             context);

    return(concatenated_segments);
end;
RETURN NULL; end;

function line_transaction_flexformula(tf_customer_trx_line_id in number) return varchar2 is
begin

/*srw.reference(tf_customer_trx_line_id);*/null;


declare
   context varchar2(100);
   concatenated_segments  varchar2(1000);

begin
    arp_descr_flex.get_concatenated_segments('RA_INTERFACE_LINES',
                                             'RA_CUSTOMER_TRX_LINES',
                                             0,
                                             to_number(tf_customer_trx_line_id),
                                             concatenated_segments,
                                             context);

    return(concatenated_segments);
end;
RETURN NULL; end;

FUNCTION COMP_TX_CUST_TRX_ID (P_CUST_TRX_ID number) RETURN boolean IS
BEGIN
  IF RP_TX_CUST_TRX_ID = P_CUST_TRX_ID
    THEN RETURN (FALSE);
    ELSE RP_TX_CUST_TRX_ID := P_CUST_TRX_ID;
         RETURN (TRUE);
  END IF;
  RETURN(TRUE);
END;

function cf_acc_messageformula(acc_gl_date in date) return number is
l_msg VARCHAR2(2000);
begin
  IF acc_gl_date IS NOT NULL THEN
     FND_MESSAGE.SET_NAME('AR','AR_REPORT_ACC_NOT_GEN');
     l_msg := FND_MESSAGE.get;
     CP_ACC_MESSAGE := l_msg;
  ELSE
     CP_ACC_MESSAGE := NULL;
  END IF;
return 0;
end;

--Functions to refer Oracle report placeholders--

 Function RP_COMPANY_NAME_p return varchar2 is
	Begin
	 return RP_COMPANY_NAME;
	 END;
 Function RP_REPORT_NAME_p return varchar2 is
	Begin
	 return RP_REPORT_NAME;
	 END;
 Function RP_DATA_FOUND_p return varchar2 is
	Begin
	 return RP_DATA_FOUND;
	 END;
 Function RP_LINES_p return number is
	Begin
	 return RP_LINES;
	 END;
 Function RP_FR_LINES_p return number is
	Begin
	 return RP_FR_LINES;
	 END;
 Function RP_TX_LINES_p return number is
	Begin
	 return RP_TX_LINES;
	 END;
 Function RP_SALESREPS_p return number is
	Begin
	 return RP_SALESREPS;
	 END;
 Function RP_REV_ACCTS_p return number is
	Begin
	 return RP_REV_ACCTS;
	 END;
 Function RP_TX_CUST_TRX_ID_p return number is
	Begin
	 return RP_TX_CUST_TRX_ID;
	 END;
 Function CP_ACC_MESSAGE_p return varchar2 is
	Begin
	 return CP_ACC_MESSAGE;
	 END;
END AR_ARXTDR_XMLP_PKG ;


/
