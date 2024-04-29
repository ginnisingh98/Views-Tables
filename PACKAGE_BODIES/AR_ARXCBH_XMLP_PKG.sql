--------------------------------------------------------
--  DDL for Package Body AR_ARXCBH_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_ARXCBH_XMLP_PKG" AS
/* $Header: ARXCBHB.pls 120.0 2007/12/27 13:36:52 abraghun noship $ */

function BeforeReport return boolean is
begin
	P_CONC_REQUEST_ID:=FND_GLOBAL.conc_request_id;
/*SRW.USER_EXIT('FND SRWINIT');*/null;
P_IN_TRX_DATE_LOW_T:= to_char(P_IN_TRX_DATE_LOW,'DD-MON-YY');
P_IN_TRX_DATE_HIGH_T:= to_char(P_IN_TRX_DATE_HIGH,'DD-MON-YY');

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
    WHERE  cr.request_id = P_CONC_REQUEST_ID
    AND    cp.application_id = cr.program_application_id
    AND    cp.concurrent_program_id = cr.concurrent_program_id;

    RP_Report_Name := l_report_name;
    RETURN(l_report_name);
EXCEPTION
    WHEN NO_DATA_FOUND
    THEN RP_REPORT_NAME := NULL;
         RETURN(NULL);
END;
RETURN NULL; end;

function AfterPForm return boolean is
begin

declare
	terms_name_low 	VARCHAR2(20);
	terms_name_high 	VARCHAR2(20);
begin


        IF p_in_customer_num_high IS NOT NULL and  p_in_customer_num_low IS NULL THEN
		lp_in_customer_num_high := ' and cust.account_number <=  :p_in_customer_num_high ' ;
	END IF;

	IF p_in_customer_num_low IS NOT NULL and  p_in_customer_num_high IS NULL THEN
		lp_in_customer_num_low := ' and cust.account_number >=  :p_in_customer_num_low ';
	END IF;

	IF p_in_customer_num_high IS NOT NULL and  p_in_customer_num_low IS NOT NULL THEN

         IF p_in_customer_num_high = p_in_customer_num_low THEN
		lp_in_customer_num_high := ' and cust.account_number =  :p_in_customer_num_high ' ;
         ELSE
		lp_in_customer_num_high := ' and cust.account_number <=  :p_in_customer_num_high ' ;
		lp_in_customer_num_low := ' and cust.account_number >=  :p_in_customer_num_low ';
         END IF;
        END IF;

	IF p_in_invoice_number_low IS NOT NULL THEN
		lp_in_invoice_number_low := ' and  ps.trx_number >=  :p_in_invoice_number_low  ' ;
	END IF;

	IF p_in_invoice_number_high IS NOT NULL THEN
		lp_in_invoice_number_high := ' and  ps.trx_number <=  :p_in_invoice_number_high ' ;
	END IF;

        IF p_in_trx_date_low IS NOT NULL THEN
		lp_in_trx_date_low  := ' and ps.trx_date >=  :p_in_trx_date_low ';
	END IF;


        IF p_in_trx_date_high IS NOT NULL THEN
		lp_in_trx_date_high  := ' and ps.trx_date <=  :p_in_trx_date_high ' ;
	END IF;


        IF (p_in_collector_low IS NOT NULL) or
           (P_in_collector_high IS NOT NULL ) THEN

       		P_FROM_1 := ' hz_customer_profiles cp_cust, ' ||
               		'hz_customer_profiles cp_site, '  ||
                        'ar_collectors col, ';

		P_WHERE_2 := '   And  cust.cust_account_id = cp_cust.cust_account_id ' ||
			' and      NVL(cp_site.collector_id,cp_cust.collector_id) = col.collector_id ' ||
			' and     cp_cust.site_use_id is null  ' ||
			' and     su.site_use_id      = cp_site.site_use_id(+) ' ;
	END IF;

        IF p_in_collector_low IS NOT NULL THEN
		lp_in_collector_low  := ' and col.name >=  :p_in_collector_low ';
	END IF;

        IF p_in_collector_high IS NOT NULL THEN
		lp_in_collector_high  := ' and col.name <=  :p_in_collector_high  ';
	END IF;

	SELECT MIN(name),
               MAX(name)
	INTO terms_name_low,
             terms_name_high
	FROM ra_terms;

	p_terms_name_low := terms_name_low;
        p_terms_name_high := terms_name_high;


        IF (p_in_customer_low IS  NOT NULL) THEN
                P_WHERE_11 := ' and party.party_name >=  :p_in_customer_low  ';
        END IF;

        IF (p_in_customer_high IS  NOT NULL) THEN
                P_WHERE_12 := ' and party.party_name <=  :p_in_customer_high ';
	END IF;

        IF (p_in_terms_high IS NOT NULL) THEN

                p_terms_name := ' and ter.name <= :p_in_terms_high ' ;
        END IF;

        IF (p_in_terms_low IS NOT NULL) THEN

                p_terms_name1 := ' and ter.name >= :p_in_terms_low ';
        END IF;

        IF ((p_in_terms_high IS  NULL)  AND (p_in_terms_low IS NULL)) THEN
                p_terms_name := ' and  nvl(ter.name, :p_terms_name_low)  between
					:p_terms_name_low   and  :p_terms_name_high ' ;
        END IF;


end;
   return (TRUE);
end;

function set_prn_flagformula(address_id in number) return number is
begin

begin
/*srw.reference(address_id);*/null;

/*srw.reference(previous_addr_id);*/null;


if previous_addr_id <> address_id then
	addr_prn_flag := 'Y' ;
else
	addr_prn_flag := 'N' ;
end if;
	previous_addr_id := address_id ;

return(1);
end;

RETURN NULL; end;

function cf_currency_flagformula(p_payment_schedule_id in number) return char is
l_num number;

cursor C_CROSS_CUR is
select decode(app.amount_applied_from,NULL,NULL,'*') flag
from ar_receivable_applications app, ar_payment_schedules_all pay
where app.reversal_gl_date IS NULL
and app.applied_customer_trx_id (+) = pay.customer_trx_id
and pay.payment_schedule_id = p_payment_schedule_id;

l_char varchar2(10);

begin

  l_num :=0;
  l_char := NUll;

for c_rec in C_CROSS_CUR loop

	IF c_rec.flag = '*' then
		l_num := 1;
		exit;
	End If;

  END LOOP;


   IF l_num =1 then
	return('*');
    else return(NULL);
   end if;

end;

--Functions to refer Oracle report placeholders--

 Function Addr_Prn_Flag_p return varchar2 is
	Begin
	 return Addr_Prn_Flag;
	 END;
 Function Previous_Addr_Id_p return number is
	Begin
	 return Previous_Addr_Id;
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
 function D_INVOICE_AMOUNTFormula(customer_name in varchar2) return VARCHAR2 is
	begin
	RP_DATA_FOUND := customer_name;
	return null;
	end;
END AR_ARXCBH_XMLP_PKG ;


/
