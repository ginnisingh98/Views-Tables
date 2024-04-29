--------------------------------------------------------
--  DDL for Package Body AR_ARXBPH_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_ARXBPH_XMLP_PKG" AS
/* $Header: ARXBPHB.pls 120.1 2008/01/07 14:50:45 abraghun noship $ */

function BeforeReport return boolean is


begin


/*SRW.USER_EXIT('FND SRWINIT');*/null;




begin


  P_CONS_PROFILE_VALUE := AR_SETUP.value('AR_SHOW_BILLING_NUMBER',null);

     /*srw.message ('101', 'Consolidated Billing Profile:  ' || P_CONS_PROFILE_VALUE);*/null;


exception
     when others then
          /*srw.message ('101', 'Consolidated Billing Profile:  Failed.');*/null;

end;

     If    ( P_CONS_PROFILE_VALUE = 'N' ) then
           lp_query_show_bill        := 'to_char(NULL)';
           /* Commented by Raj lp_table_show_bill        := null;
           lp_where_show_bill        := null;*/
           lp_table_show_bill        := ' ';
           lp_where_show_bill        := ' ';
     Else  lp_query_show_bill        := 'ci.cons_billing_number';
           lp_table_show_bill        := 'ar_cons_inv ci, ';
           lp_where_show_bill        := 'and ps.cons_inv_id = ci.cons_inv_id(+)';
     End if;


     return (TRUE);

end;

function AfterReport return boolean is
begin

/*SRW.USER_EXIT('FND SRWEXIT');*/null;
  return (TRUE);
end;

function report_nameformula(Company_Name in varchar2) return varchar2 is
begin

DECLARE
    l_report_name  VARCHAR2(80);
BEGIN
    RP_Company_Name := Company_Name;
    SELECT substr(cp.user_concurrent_program_name,1,80)
    INTO   l_report_name
    FROM   FND_CONCURRENT_PROGRAMS_VL cp,
           FND_CONCURRENT_REQUESTS cr
    --Commented By Raj WHERE  cr.request_id = P_CONC_REQUEST_ID
    WHERE  cr.request_id = FND_GLOBAL.conc_request_id
    AND    cp.application_id = cr.program_application_id
    AND    cp.concurrent_program_id = cr.concurrent_program_id;

    RP_Report_Name := l_report_name;
     RP_REPORT_NAME := substr(RP_REPORT_NAME,1,instr(RP_REPORT_NAME,' (XML)'));
    RETURN(l_report_name);
EXCEPTION
    WHEN NO_DATA_FOUND
    THEN RP_REPORT_NAME := NULL;
         RETURN(NULL);
END;
RETURN NULL; end;

function Set_StatusFormula return VARCHAR2 is
begin

/*srw.reference(p_in_account_status_low_1);*/null;

/*srw.reference(p_in_account_status_high_1);*/null;


IF ( upper(p_in_account_status_low_1) <> 'ALL') THEN
	status_low := p_in_account_status_low_1;
END IF;

IF ( upper( p_in_account_status_high_1) <> 'ALL') THEN
	status_high := p_in_account_status_high_1;
END IF;




RETURN NULL; end;

function AfterPForm return boolean is
begin

DECLARE
	customer_name_high VARCHAR2(50);
	customer_name_low  VARCHAR2(50);
	invoice_number_high	   VARCHAR2(30);
	invoice_number_low	   VARCHAR2(30);
BEGIN

p_in_account_status_low_1:=p_in_account_status_low;
p_in_account_status_high_1:=p_in_account_status_high;
	IF (p_in_customer_low IS NOT NULL AND p_in_customer_high IS NULL) THEN
		P_WHERE_11 := ' And party.party_name  >=  :p_in_customer_low  ';
	END IF;

	IF (p_in_customer_high IS NOT NULL AND p_in_customer_low IS NULL) THEN
		P_WHERE_12 := ' And party.party_name  <=  :p_in_customer_high  ';
	END IF;

	IF (p_in_customer_low IS NOT NULL AND p_in_customer_high IS NOT NULL) THEN
          IF (p_in_customer_low = p_in_customer_high ) THEN
		P_WHERE_11 := ' And party.party_name  =  :p_in_customer_low  ';
          ELSE
		P_WHERE_11 := ' And party.party_name  >=  :p_in_customer_low  ';
		P_WHERE_12 := ' And party.party_name  <=  :p_in_customer_high  ';

          END IF;
        END IF;


	IF (p_in_customer_num_low IS NOT NULL  AND p_in_customer_num_high IS NULL ) THEN
		lp_customer_num_low := ' and cust_acct.account_number >=  :p_in_customer_num_low  ';
	END IF;

	IF (p_in_customer_num_high IS NOT NULL  AND p_in_customer_num_low IS NULL ) THEN
		lp_customer_num_high := ' and cust_acct.account_number <=  :p_in_customer_num_high  ';
	END IF;

	IF (p_in_customer_num_high IS NOT NULL  AND p_in_customer_num_low IS NOT NULL ) THEN
  	  IF (p_in_customer_num_high = p_in_customer_num_low) THEN
		lp_customer_num_low := ' and cust_acct.account_number =  :p_in_customer_num_low  ';
          ELSE
		lp_customer_num_low := ' and cust_acct.account_number >=  :p_in_customer_num_low  ';
		lp_customer_num_high := ' and cust_acct.account_number <=  :p_in_customer_num_high  ';

          END IF;
        END IF;

	IF (p_in_invoice_number_low IS  NOT NULL AND p_in_invoice_number_high IS NULL) THEN
		lp_invoice_number_low := ' and ps.trx_number >=  :p_in_invoice_number_low  ';
	END IF;

	IF (p_in_invoice_number_high IS  NOT NULL AND p_in_invoice_number_low IS NULL) THEN
		lp_invoice_number_high := ' and ps.trx_number <=  :p_in_invoice_number_high  ';
	END IF;

	IF (p_in_invoice_number_low IS  NOT NULL AND p_in_invoice_number_high IS NOT NULL) THEN
     	   IF (p_in_invoice_number_low = p_in_invoice_number_high ) THEN
		lp_invoice_number_low := ' and ps.trx_number =  :p_in_invoice_number_low  ';

            ELSE
		lp_invoice_number_low := ' and ps.trx_number >=  :p_in_invoice_number_low  ';
		lp_invoice_number_high := ' and ps.trx_number <=  :p_in_invoice_number_high  ';

            END IF;
        END IF;


	IF p_in_invoice_amount_low IS NOT NULL THEN
		lp_invoice_amount_low := ' and ps.amount_due_original >= :p_in_invoice_amount_low  ';
	END IF;

	IF p_in_invoice_amount_high IS NOT NULL THEN
		lp_invoice_amount_high := ' and ps.amount_due_original  <= :p_in_invoice_amount_high  ';
	END IF;


        IF (p_in_trx_date_low IS NOT NULL AND p_in_trx_date_high IS NULL) THEN
		lp_trx_date_low  := ' and ps.trx_date >=  :p_in_trx_date_low  ';
	END IF;

        IF (p_in_trx_date_low IS NOT NULL AND p_in_trx_date_high IS NULL)  THEN
		lp_r_trx_date_low  := ' and cr.receipt_date >= :p_in_trx_date_low  ';
	END IF;

        IF (p_in_trx_date_high IS NOT NULL AND p_in_trx_date_low IS NULL) THEN
		lp_trx_date_high  := ' and ps.trx_date <=  :p_in_trx_date_high  ';
	END IF;

        IF (p_in_trx_date_high IS NOT NULL AND p_in_trx_date_low IS NULL) THEN
		lp_r_trx_date_high  := ' and cr.receipt_date <= :p_in_trx_date_high  ' ;
	END IF;

        IF (p_in_trx_date_low IS NOT NULL AND p_in_trx_date_high IS NOT NULL) THEN

           IF (p_in_trx_date_low = p_in_trx_date_high ) THEN
		lp_trx_date_low  := ' and ps.trx_date =  :p_in_trx_date_low  ';
           ELSE
		lp_trx_date_low  := ' and ps.trx_date  >=  :p_in_trx_date_low  ';
		lp_trx_date_high  := ' and ps.trx_date <=  :p_in_trx_date_high  ';
           END IF;

        END IF;

        IF (p_in_trx_date_low IS NOT NULL AND p_in_trx_date_high IS NOT NULL) THEN

           IF (p_in_trx_date_low = p_in_trx_date_high ) THEN
		lp_r_trx_date_low  := ' and cr.receipt_date = :p_in_trx_date_low  ';
           ELSE
		lp_r_trx_date_low  := ' and cr.receipt_date  >= :p_in_trx_date_low  ';
		lp_r_trx_date_high  := ' and cr.receipt_date <= :p_in_trx_date_high  ' ;
           END IF;

        END IF;



        IF p_in_account_status_low_1 IS NULL THEN
		p_in_account_status_low_1 := 'All';
	END IF;

	IF p_in_account_status_high_1 IS NULL THEN
		p_in_account_status_high_1 := 'All';
	END IF;

	IF p_in_balance_due_low IS NOT NULL THEN
		lp_balance_due_low  := ' and ps.amount_due_remaining >=  :p_in_balance_due_low  ';
	END IF;

	IF p_in_balance_due_high IS NOT NULL THEN
		lp_balance_due_high  := ' and ps.amount_due_remaining <=  :p_in_balance_due_high  ';
	END IF;


	IF( ( p_in_customer_num_low IS NOT NULL )
            OR
	    ( p_in_customer_num_low IS NULL
              AND p_in_customer_num_high IS NOT NULL)
            OR
	    ( p_in_customer_low IS NOT NULL )
            OR
	    ( p_in_customer_low IS NULL
              AND p_in_customer_high IS NOT NULL)
            OR
	    ( p_in_customer_low IS NULL
              AND p_in_customer_high IS NULL
              AND p_in_customer_num_low IS NULL
              AND p_in_customer_num_high IS NULL
              AND p_in_trx_date_low IS NULL
              AND p_in_trx_date_high IS NULL) ) THEN
          IF    p_in_customer_num_low IS NULL AND p_in_customer_num_high IS NULL
            AND p_in_customer_low  IS NULL AND p_in_customer_high  IS NULL
            AND p_in_trx_date_low IS NULL AND p_in_trx_date_high IS NULL
            AND p_in_invoice_number_low IS NULL AND p_in_invoice_number_high IS NULL THEN

	    P_WHERE_1 := '  and ps.customer_id = cust_acct.cust_account_id ' ||
                          '  and ct.bill_to_customer_id = cust_acct.cust_account_id ' ||
                          '  and ct.customer_trx_id <= nvl(:p_max_id, 999999999999999) '     ;
          ELSE

	    P_WHERE_1 := '  and ps.customer_id = cust_acct.cust_account_id ' ||
                          '  and ct.bill_to_customer_id = cust_acct.cust_account_id ';

          END IF;
            P_WHERE_2 := '  and cust_acct.cust_account_id = cp_cust.cust_account_id ';
	ELSE
          IF    p_in_customer_num_low IS NULL AND p_in_customer_num_high IS NULL
            AND p_in_customer_low  IS NULL AND p_in_customer_high  IS NULL
            AND p_in_trx_date_low IS NULL AND p_in_trx_date_high IS NULL
            AND p_in_invoice_number_low IS NULL AND p_in_invoice_number_high IS NULL THEN

	    P_WHERE_1 := '  and ps.customer_id = cust_acct.cust_account_id+0 ' ||
                          '  and ct.bill_to_customer_id = cust_acct.cust_account_id ' ||
                          '  and ct.customer_trx_id <= nvl(:p_max_id, 999999999999999) '     ;
          ELSE

	    P_WHERE_1 := '  and ps.customer_id = cust_acct.cust_account_id ' ||
                          '  and ct.bill_to_customer_id = cust_acct.cust_account_id ';

          END IF;
	    P_WHERE_2 := '  and cust_acct.cust_account_id+0 = cp_cust.cust_account_id ';
	END IF;
END;

  return (TRUE);
end;

--Functions to refer Oracle report placeholders--

 Function Credits_Dummy_p return varchar2 is
	Begin
	 return Credits_Dummy;
	 END;
 Function Adjusts_Dummy_p return varchar2 is
	Begin
	 return Adjusts_Dummy;
	 END;
 Function Payment_no_dummy_cr_p return varchar2 is
	Begin
	 return Payment_no_dummy_cr;
	 END;
 Function Payments_Dummy_p return varchar2 is
	Begin
	 return Payments_Dummy;
	 END;
 Function Adjusts_Dummy_Cr_p return varchar2 is
	Begin
	 return Adjusts_Dummy_Cr;
	 END;
 Function payment_no_dummy_adj_p return varchar2 is
	Begin
	 return payment_no_dummy_adj;
	 END;
 Function Payments_Dummy_adj_p return varchar2 is
	Begin
	 return Payments_Dummy_adj;
	 END;
 Function Credits_Dummy_Adj_p return varchar2 is
	Begin
	 return Credits_Dummy_Adj;
	 END;
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
 Function Status_Low_p return varchar2 is
	Begin
	 return Status_Low;
	 END;
 Function Status_high_p return varchar2 is
	Begin
	 return Status_high;
	 END;

/*added as fix*/
function D_INVOICE_AMOUNTFormula(customer_name in varchar2) return VARCHAR2 is
begin

/*srw.reference(:Invoice_Amt);
srw.reference(:Currency_Code);
srw.user_exit('FND FORMAT_CURRENCY
		CODE=":Currency_Code"
		DISPLAY_WIDTH="13"
		AMOUNT=":Invoice_amt"
		DISPLAY=":D_Invoice_Amount"');
	RETURN(:D_Invoice_Amount);*/

	RP_DATA_FOUND := customer_name;
return (' ');
end;
END AR_ARXBPH_XMLP_PKG ;


/
