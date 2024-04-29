--------------------------------------------------------
--  DDL for Package Body AR_RAXSKI_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_RAXSKI_XMLP_PKG" AS
/* $Header: RAXSKIB.pls 120.0 2007/12/27 14:33:11 abraghun noship $ */

function report_nameformula(Company_Name in varchar2) return varchar2 is
begin

DECLARE
    l_report_name  VARCHAR2(80);
BEGIN
    RP_Company_Name := Company_Name;
    SELECT SUBSTR(cp.user_concurrent_program_name, 1, 80)
    INTO   l_report_name
    FROM   FND_CONCURRENT_PROGRAMS_VL cp,
           FND_CONCURRENT_REQUESTS cr
    WHERE  cr.request_id = P_CONC_REQUEST_ID
    AND    cp.application_id = cr.program_application_id
    AND    cp.concurrent_program_id = cr.concurrent_program_id;

    RP_Report_Name := l_report_name;
    RP_Report_Name := substr(RP_Report_Name,1,instr(RP_Report_Name,' (XML)'));

    RETURN(l_report_name);
EXCEPTION
    WHEN NO_DATA_FOUND
    THEN RP_REPORT_NAME := 'Key Indicators for Revenue Accounting';
         RETURN('Key Indicators for Revenue Accounting');
END;
RETURN NULL; end;

function BeforeReport return boolean is
begin
begin


	null;


end;
  return (TRUE);
end;
function AfterPForm return boolean is
begin
  P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;

Begin
	SELECT
	TO_DATE(ARGUMENT3,'yyyy/mm/dd hh24:mi:ss'),TO_DATE(ARGUMENT4,'yyyy/mm/dd hh24:mi:ss') ,
	TO_DATE(ARGUMENT5,'yyyy/mm/dd hh24:mi:ss'),TO_DATE(ARGUMENT6,'yyyy/mm/dd hh24:mi:ss')
	INTO P_START_DATE,P_END_DATE,P_PRIOR_START_DATE,P_PRIOR_END_DATE
	FROM FND_CONCURRENT_REQUESTS
	WHERE REQUEST_ID = P_CONC_REQUEST_ID;
	EXCEPTION WHEN OTHERS THEN
	RETURN NULL;
end;

	/*SRW.USER_EXIT('FND SRWINIT');*/null;
    IF p_start_date IS NULL THEN
          p_start_date := to_date('01-01-1953','DD-MM-YYYY');
     END IF;
     IF p_prior_start_date IS NULL THEN
          p_prior_start_date := to_date('01-01-1953','DD-MM-YYYY');
     END IF;
     IF p_end_date IS NULL THEN
          p_end_date := to_date('31-12-4712','DD-MM-YYYY');
     END IF;
     IF p_prior_end_date IS NULL THEN
          p_prior_end_date := to_date('31-12-4712','DD-MM-YYYY');
     END IF;

	if p_start_currency_code is not null then
		lp_start_currency_code := ' and currency_code >= :p_start_currency_code ';
	end if;

	if p_end_currency_code is not null then
		lp_end_currency_code := ' and currency_code <= :p_end_currency_code ';
	end if;

	if p_prior_start_date <> to_date('01-01-1953','DD-MM-YYYY')
           AND p_start_date <> to_date('01-01-1953','DD-MM-YYYY')  then
		lp_start_date := ' and trx_date >= least(:p_prior_start_date,
								:p_start_date) ';
	end if;

	if p_prior_end_date <> to_date('31-12-4712','DD-MM-YYYY')
           AND p_end_date <> to_date('31-12-4712','DD-MM-YYYY') then
		lp_end_date := ' and trx_date <= greatest(:p_prior_end_date,
								:p_end_date) ';
	end if;

  return (TRUE);
end;

function Sub_TitleFormula return VARCHAR2 is
begin

begin
RP_SUB_TITLE := ' ';
return(' ');
end;

RETURN NULL; end;

function Sel_CustomersFormula return Number is
begin

declare
	/*v_customers		number(10);
	prior_v_customers	number(10);
	cust_total_number	number(10);
	prior_v_inactive_count	number(10);
	v_inactive_count	number(10);
	v_addresses		number(10);
	prior_v_addresses	number(10);
	address_total_number	number(10);
	inactive_count_total_number number(10);
	customer_change		VARCHAR2(10);
	address_change		VARCHAR2(10);
	inactive_count_change	VARCHAR2(10);*/
	v_customers_t		number(10);
	prior_v_customers_t	number(10);
	cust_total_number_t	number(10);
	prior_v_inactive_count_t	number(10);
	v_inactive_count_t	number(10);
	v_addresses_t		number(10);
	prior_v_addresses_t	number(10);
	address_total_number_t	number(10);
	inactive_count_total_number_t number(10);
	customer_change_t	VARCHAR2(10);
	address_change_t		VARCHAR2(10);
	inactive_count_change_t	VARCHAR2(10);
begin
        select  count(*)
        into    v_customers_t
        from    hz_cust_accounts
        where   creation_date between p_start_date
                                  and p_end_date + (86399/86400);


        select  count(*)
        into    prior_v_customers_t
        from    hz_cust_accounts
        where   creation_date between p_prior_start_date
                                  and p_prior_end_date + (86399/86400);


        select  count(*),
                NVL(sum(decode(status,'I',1,0)),0)
        into    cust_total_number_t,
                inactive_count_total_number_t
        from    hz_cust_accounts;


        select  NVL(sum(decode(status,'I',1,0)),0)
        into    prior_v_inactive_count_t
        from    hz_cust_accounts
        where   last_update_date between
                                    p_prior_start_date
                                  and p_prior_end_date + (86399/86400);


        select  NVL(sum(decode(status,'I',1,0)),0)
        into    v_inactive_count_t
        from    hz_cust_accounts
        where   last_update_date between p_start_date
                                     and p_end_date + (86399/86400);



        select  count(*)
        into    v_addresses_t
        from    hz_cust_acct_sites acct_site,
                hz_party_sites party_site,
		hz_loc_assignments loc_assign
        where   acct_site.party_site_id = party_site.party_site_id
          and   party_site.location_id  = loc_assign.location_id
          and   nvl(acct_site.org_id, -99) = nvl(loc_assign.org_id,-99)
          and    acct_site.creation_date between p_start_date
                                  and p_end_date + (86399/86400);


        select  count(*)
        into    prior_v_addresses_t
        from    hz_cust_acct_sites acct_site,
                hz_party_sites party_site,
		hz_loc_assignments loc_assign
        where   acct_site.party_site_id = party_site.party_site_id
          and   party_site.location_id = loc_assign.location_id
          and   nvl(acct_site.org_id, -99) = nvl(loc_assign.org_id,-99)
          and   acct_site.creation_date between p_prior_start_date
                                  and p_prior_end_date + (86399/86400);


        select  count(*)
        into    address_total_number_t
        from    hz_cust_acct_sites acct_site,
                hz_party_sites party_site,
		hz_loc_assignments loc_assign
        where   acct_site.party_site_id = party_site.party_site_id
          and   party_site.location_id  = loc_assign.location_id
          and   nvl(acct_site.org_id, -99) = nvl(loc_assign.org_id,-99);


	/*v_customers		:= v_customers;
	prior_v_customers	:= prior_v_customers;
	cust_total_number	:= cust_total_number;
	prior_v_inactive_count	:= prior_v_inactive_count;
	v_inactive_count	:= v_inactive_count;
	v_addresses		:= v_addresses;
	prior_v_addresses	:= prior_v_addresses;
	address_total_number	:= address_total_number;
	inactive_count_total_number := inactive_count_total_number;*/
	v_customers		:= v_customers_t;
	prior_v_customers	:= prior_v_customers_t;
	cust_total_number	:= cust_total_number_t;
	prior_v_inactive_count	:= prior_v_inactive_count_t;
	v_inactive_count	:= v_inactive_count_t;
	v_addresses		:= v_addresses_t;
	prior_v_addresses	:= prior_v_addresses_t;
	address_total_number	:= address_total_number_t;
	inactive_count_total_number := inactive_count_total_number_t;

	if (prior_v_customers <> 0 ) then
		customer_change := to_char(round(((v_customers - prior_v_customers)/prior_v_customers * 100),2),'999D99');
	else
		customer_change :=  TO_CHAR(0, '0D00');
	end if;

	if (prior_v_addresses <> 0 ) then
		address_change := to_char(round(((v_addresses - prior_v_addresses)/prior_v_addresses * 100),2),'999D99') ;
	else
		address_change := TO_CHAR(0, '0D00');
	end if;

	if (prior_v_inactive_count <> 0 ) then
		inactive_count_change := to_char(round(((v_inactive_count - prior_v_inactive_count)/prior_v_inactive_count * 100),2),'999D99') ;
	else
		inactive_count_change := TO_CHAR(0, '0D00') ;
	end if;

	return(1);

exception
	when NO_DATA_FOUND then
		return(0);
end;
RETURN NULL; end;

--function sel_invoicesformula(inv_type in number, invoice_currency_code in varchar2, inv_sum in number) return number is
function sel_invoicesformula(inv_type in number, invoice_currency_code_t in varchar2, inv_sum in number) return number is
begin

declare
--	current_inv_sum		number(38,2);
--	current_inv_period	number(10);



	current_inv_sum1	number(38,2);
	current_inv_period1	number(10);
	current_inv_sum2	number(38,2);
	current_inv_period2	number(10);

--  	prior_inv_sum		number(38,2);
--	prior_inv_period	number(10);



  	prior_inv_sum1		number(38,2);
	prior_inv_period1	number(10);
  	prior_inv_sum2		number(38,2);
	prior_inv_period2	number(10);

--  	inv_sum_tf		number(38,2);

	current_inv_sum_t		number(38,2);
	current_inv_period_t	number(10);
  	prior_inv_sum_t		number(38,2);
	prior_inv_period_t	number(10);
  	inv_sum_tf_t		number(38,2);


begin

	/*srw.reference(invoice_currency_code);*/null;

	/*srw.reference(inv_type);*/null;

	/*srw.reference(inv_sum);*/null;





     IF   p_start_date = to_date('01-01-1953','DD-MM-YYYY')
        AND p_end_date = to_date('31-12-4712','DD-MM-YYYY') THEN

        select  sum(nvl(b.acctd_amount,0)),
                NVL( count( distinct ( a.customer_trx_id )), 0 )
        into    current_inv_sum_t, current_inv_period_t
        from    ra_cust_trx_line_gl_dist b,
                ra_customer_trx a,
                ra_cust_trx_types c
        where   complete_flag = 'Y'
        and     c.type in ('INV','DM','DEP','CB')
        and     a.cust_trx_type_id = inv_type
        and     a.customer_trx_id = b.customer_trx_id
        and     b.account_class   = 'REC'
        and     b.latest_rec_flag = 'Y'
        and     a.cust_trx_type_id = c.cust_trx_type_id
        and     nvl(b.gl_date,a.trx_date) between p_start_date
                                    and p_end_date + (86399/86400)
       -- and     a.invoice_currency_code = invoice_currency_code;
        and     a.invoice_currency_code = invoice_currency_code_t;

      ELSE



        select  sum(nvl(b.acctd_amount,0)) amount,
                nvl(count(distinct(a.customer_trx_id)),0) trx_id
        into    current_inv_sum1, current_inv_period1
        from    ra_cust_trx_line_gl_dist b,
                ra_customer_trx a,
                ra_cust_trx_types c
        where   complete_flag = 'Y'
        and     c.type in ('INV','DM','DEP','CB')
        and     a.cust_trx_type_id = inv_type
        and     a.customer_trx_id = b.customer_trx_id
        and     b.account_class   = 'REC'
        and     b.latest_rec_flag = 'Y'
        and     a.cust_trx_type_id = c.cust_trx_type_id
        and     b.gl_date is not null
        and     b.gl_date   between p_start_date
                                and p_end_date + (86399/86400)
        --and     a.invoice_currency_code = invoice_currency_code ;
        and     a.invoice_currency_code = invoice_currency_code_t ;


        select  sum(nvl(b.acctd_amount,0)) amount,
                nvl(count(distinct(a.customer_trx_id)),0) trx_id
        into    current_inv_sum2, current_inv_period2
        from    ra_cust_trx_line_gl_dist b,
                ra_customer_trx a,
                ra_cust_trx_types c
        where   complete_flag = 'Y'
        and     c.type in ('INV','DM','DEP','CB')
        and     a.cust_trx_type_id = inv_type
        and     a.customer_trx_id = b.customer_trx_id
        and     b.account_class   = 'REC'
        and     b.latest_rec_flag = 'Y'
        and     a.cust_trx_type_id = c.cust_trx_type_id
        and     b.gl_date is null
        and     a.trx_date between p_start_date
                               and p_end_date + (86399/86400)
        --and     a.invoice_currency_code = invoice_currency_code   ;
        and     a.invoice_currency_code = invoice_currency_code_t   ;

        current_inv_sum_t := nvl(current_inv_sum1,0) + nvl(current_inv_sum2,0) ;
        current_inv_period_t := nvl(current_inv_period1,0) + nvl(current_inv_period2,0);



        IF current_inv_sum1 IS NULL and current_inv_sum2 is null THEN
           current_inv_sum := null;
        END IF;

     END IF;


       IF   p_prior_start_date = to_date('01-01-1953','DD-MM-YYYY')
        AND p_prior_end_date =  to_date('31-12-4712','DD-MM-YYYY') THEN


        select  sum(nvl(b.acctd_amount,0)),
                NVL( count( distinct ( a.customer_trx_id )), 0 )
        into    prior_inv_sum_t, prior_inv_period_t
        from    ra_cust_trx_line_gl_dist b,
                ra_customer_trx a,
                ra_cust_trx_types c
        where   complete_flag = 'Y'
        and     c.type in ('INV','DM','DEP','CB')
        and     a.cust_trx_type_id = inv_type
        and     a.customer_trx_id  = b.customer_trx_id
        and     b.account_class    = 'REC'
        and     b.latest_rec_flag = 'Y'
        and     a.cust_trx_type_id = c.cust_trx_type_id
        and     nvl(b.gl_date,a.trx_date) between p_prior_start_date
                                    and p_prior_end_date + (86399/86400)
        --and    a.invoice_currency_code = invoice_currency_code;
        and    a.invoice_currency_code = invoice_currency_code_t;

      ELSE


        select  sum(nvl(b.acctd_amount,0)) amount,
                nvl(count(distinct(a.customer_trx_id)),0) trx_id
        into    prior_inv_sum1, prior_inv_period1
        from    ra_cust_trx_line_gl_dist b,
                ra_customer_trx a,
                ra_cust_trx_types c
        where   complete_flag = 'Y'
        and     c.type in ('INV','DM','DEP','CB')
        and     a.cust_trx_type_id = inv_type
        and     a.customer_trx_id = b.customer_trx_id
        and     b.account_class   = 'REC'
        and     b.latest_rec_flag = 'Y'
        and     a.cust_trx_type_id = c.cust_trx_type_id
        and     b.gl_date is not null
        and     b.gl_date   between p_prior_start_date
                                and p_prior_end_date + (86399/86400)
        --and     a.invoice_currency_code = invoice_currency_code ;
        and     a.invoice_currency_code = invoice_currency_code_t ;


        select  sum(nvl(b.acctd_amount,0)) amount,
                nvl(count(distinct(a.customer_trx_id)),0) trx_id
        into    prior_inv_sum2, prior_inv_period2
        from    ra_cust_trx_line_gl_dist b,
                ra_customer_trx a,
                ra_cust_trx_types c
        where   complete_flag = 'Y'
        and     c.type in ('INV','DM','DEP','CB')
        and     a.cust_trx_type_id = inv_type
        and     a.customer_trx_id = b.customer_trx_id
        and     b.account_class   = 'REC'
        and     b.latest_rec_flag = 'Y'
        and     a.cust_trx_type_id = c.cust_trx_type_id
        and     b.gl_date is null
        and     a.trx_date between p_prior_start_date
                               and p_prior_end_date + (86399/86400)
        --and     a.invoice_currency_code = invoice_currency_code   ;
        and     a.invoice_currency_code = invoice_currency_code_t   ;

           prior_inv_sum_t := nvl(prior_inv_sum1,0) + nvl(prior_inv_sum2,0);
           prior_inv_period_t :=  nvl(prior_inv_period1,0) + nvl(prior_inv_period2,0) ;



        IF prior_inv_sum1 is null and  prior_inv_sum2 is null THEN
           prior_inv_sum_t := null;
        END IF;



      END IF;

	/*current_inv_period := current_inv_period;
	prior_inv_period   := prior_inv_period;*/
	current_inv_period := current_inv_period_t;
	prior_inv_period   := prior_inv_period_t;

	if prior_inv_period <> 0 then
		p_percent_change := round(((current_inv_period - prior_inv_period)/prior_inv_period * 100),2);
	else
		p_percent_change := 0.00;
	end if;

--	current_inv_sum := current_inv_sum;
--	prior_inv_sum   := prior_inv_sum;
	current_inv_sum := current_inv_sum_t;
	prior_inv_sum   := prior_inv_sum_t;


	if prior_inv_sum <> 0 then
		a_percent_change := round(((current_inv_sum - prior_inv_sum)/prior_inv_sum * 100),2);
	else
		a_percent_change := 0.00;
	end if;

	inv_sum_tf_t := inv_sum;
	inv_sum_tf := inv_sum_tf_t;
	/*	inv_sum_tf := inv_sum;
	inv_sum_tf := inv_sum_tf;*/


	return(1);

exception
	when NO_DATA_FOUND then
		return(0);
end;

RETURN NULL; end;

--function sel_trxformula(reason in varchar2, invoice_currency_code in varchar2, all_sum in number) return number is
function sel_trxformula(reason in varchar2, invoice_currency_code_t in varchar2, all_sum_t in number) return number is
begin

declare

	--current_period		number(10);
	--current_sum		number(38,2);

	--prior_period		number(10);

  	--prior_sum		number(38,2);

        --all_sum_ctf		number(38,2);
/* added as fix*/
current_period_t          number(10);
current_sum_t		number(38,2);
prior_period_t		number(10);
prior_sum_t		number(38,2);
all_sum_ctf_t		number(38,2);
/* fix ends */

       current_period1		number(10);
       current_sum1		number(38,2);
       current_period2		number(10);
       current_sum2		number(38,2);

	prior_period1		number(10);
  	prior_sum1		number(38,2);
	prior_period2		number(10);
  	prior_sum2   	        number(38,2);


begin




       IF   p_start_date = to_date('01-01-1953','DD-MM-YYYY')
        AND p_end_date =  to_date('31-12-4712','DD-MM-YYYY') THEN

        select  NVL( count( distinct( a.customer_trx_id )), 0),
                sum(gld.acctd_amount)
        --into    current_period, current_sum
        into    current_period_t, current_sum_t
        from    ra_cust_trx_line_gl_dist gld,
                ra_customer_trx   a,
                ra_cust_trx_types c
        where   complete_flag = 'Y'
        and     c.type = 'CM'
        and     nvl(a.reason_code,'0') = reason
        and     a.customer_trx_id  = gld.customer_trx_id
        and     gld.account_class = 'REC'
        and     gld.latest_rec_flag = 'Y'
        and     a.cust_trx_type_id = c.cust_trx_type_id
        and     nvl(gld.gl_date,a.trx_date) between p_start_date
                                    and p_end_date + (86399/86400)
        --and     a.invoice_currency_code = invoice_currency_code;
        and     a.invoice_currency_code = invoice_currency_code_t;

       ELSE


        select  nvl(count( distinct (a.customer_trx_id)),0) cust_trx_id,
                sum(nvl(gld.acctd_amount,0))  amount
        into    current_period1, current_sum1
        from    ra_cust_trx_line_gl_dist gld,
                ra_customer_trx   a,
                ra_cust_trx_types c
        where   complete_flag = 'Y'
        and     c.type = 'CM'
        and     nvl(a.reason_code,'0') = reason
        and     a.customer_trx_id  = gld.customer_trx_id
        and     gld.account_class = 'REC'
        and     gld.latest_rec_flag = 'Y'
        and     a.cust_trx_type_id = c.cust_trx_type_id
        and     gld.gl_date is not null
        and     gld.gl_date between p_start_date
                                and p_end_date + (86399/86400)
        --and     a.invoice_currency_code = invoice_currency_code ;
        and     a.invoice_currency_code = invoice_currency_code_t ;


        select  nvl(count( distinct (a.customer_trx_id)),0) cust_trx_id,
                sum(nvl(gld.acctd_amount,0))  amount
        into    current_period2, current_sum2
        from    ra_cust_trx_line_gl_dist gld,
                ra_customer_trx   a,
                ra_cust_trx_types c
        where   complete_flag = 'Y'
        and     c.type = 'CM'
        and     nvl(a.reason_code,'0') = reason
        and     a.customer_trx_id  = gld.customer_trx_id
        and     gld.account_class = 'REC'
        and     gld.latest_rec_flag = 'Y'
        and     a.cust_trx_type_id = c.cust_trx_type_id
        and     gld.gl_date is null
        and     a.trx_date between p_start_date
                               and p_end_date + (86399/86400)
        --and     a.invoice_currency_code = invoice_currency_code ;
        and     a.invoice_currency_code = invoice_currency_code_t ;

              current_period_t := nvl(current_period1,0) + nvl(current_period2,0) ;
              current_sum_t  := nvl(current_sum1,0) + nvl(current_sum2 ,0);



        IF current_sum1 is null and current_sum2 is null  THEN
            current_sum_t := null;
        END IF;
      END IF;




       IF   p_prior_start_date = to_date('01-01-1953','DD-MM-YYYY')
        AND p_prior_end_date =  to_date('31-12-4712','DD-MM-YYYY') THEN

        select  NVL( count( distinct( a.customer_trx_id )), 0),
                sum(gld.acctd_amount)
        --into    prior_period, prior_sum
        into    prior_period_t, prior_sum_t
        from    ra_cust_trx_line_gl_dist gld,
                ra_customer_trx   a,
                ra_cust_trx_types c
        where   complete_flag = 'Y'
        and     c.type = 'CM'
        and     nvl(a.reason_code,'0') = reason
        and     a.customer_trx_id  = gld.customer_trx_id
        and     gld.account_class = 'REC'
        and     gld.latest_rec_flag = 'Y'
        and     a.cust_trx_type_id = c.cust_trx_type_id
        and     nvl(gld.gl_date,a.trx_date) between p_prior_start_date
                                    and p_prior_end_date + (86399/86400)
        --and     a.invoice_currency_code = invoice_currency_code;
        and     a.invoice_currency_code = invoice_currency_code_t;

       ELSE



        select  nvl(count(distinct(a.customer_trx_id)),0)  cust_trx_id,
                sum(nvl(gld.acctd_amount ,0))  amount
        into    prior_period1, prior_sum1
        from    ra_cust_trx_line_gl_dist gld,
                ra_customer_trx   a,
                ra_cust_trx_types c
        where   complete_flag = 'Y'
        and     c.type = 'CM'
        and     nvl(a.reason_code,'0') = reason
        and     a.customer_trx_id  = gld.customer_trx_id
        and     gld.account_class = 'REC'
        and     gld.latest_rec_flag = 'Y'
        and     a.cust_trx_type_id = c.cust_trx_type_id
        and     gld.gl_date is not null
        and     gld.gl_date between p_prior_start_date
                                and p_prior_end_date + (86399/86400)
        --and     a.invoice_currency_code = invoice_currency_code ;
        and     a.invoice_currency_code = invoice_currency_code_t ;

        select  nvl(count(distinct(a.customer_trx_id)),0)  cust_trx_id,
                sum(nvl(gld.acctd_amount,0))   amount
        into    prior_period2, prior_sum2
        from    ra_cust_trx_line_gl_dist gld,
                ra_customer_trx   a,
                ra_cust_trx_types c
        where   complete_flag = 'Y'
        and     c.type = 'CM'
        and     nvl(a.reason_code,'0') = reason
        and     a.customer_trx_id  = gld.customer_trx_id
        and     gld.account_class = 'REC'
        and     gld.latest_rec_flag = 'Y'
        and     a.cust_trx_type_id = c.cust_trx_type_id
        and     gld.gl_date is null
        and     a.trx_date between p_prior_start_date
                               and p_prior_end_date + (86399/86400)
        --and     a.invoice_currency_code = invoice_currency_code ;
        and     a.invoice_currency_code = invoice_currency_code_t ;

          prior_period_t := nvl(prior_period1,0) + nvl(prior_period2,0) ;
          prior_sum_t  := nvl(prior_sum1,0) + nvl(prior_sum2,0) ;



        IF prior_sum1 is null and  prior_sum2 is null THEN
            prior_sum_t := null;
        END IF;

       END IF;

	current_period := current_period_t;
	prior_period   := prior_period_t;

	if prior_period <> 0 then
		c_percent_change  := round(((current_period - prior_period)/prior_period * 100),2);
	else
		c_percent_change  := 0.00;
	end if;

	current_sum :=  current_sum_t;
	prior_sum   :=  prior_sum_t;

	if prior_sum <> 0 then
		s_percent_change  := round(((current_sum - prior_sum)/prior_sum * 100),2);
	else
		s_percent_change  := 0.00;
	end if;

	all_sum_ctf_t := all_sum_t;
	--all_sum_ctf := all_sum_ctf;
	all_sum_ctf := all_sum_ctf_t;

	return(1);

exception
	when NO_DATA_FOUND then
		return(0);
end;





RETURN NULL; end;

function CF_NO_REASONFormula return VARCHAR2 is
   no_reason  VARCHAR2(80);
begin
   select meaning
     into no_reason
     from ar_lookups
    where lookup_code = 'NO REASON'
      and lookup_type = 'CREDIT_MEMO_REASON';
   return(no_reason);
end;

function sum_p_percent_change1formula(sum_prior_inv_period in number, sum_current_inv_period in number) return number is
begin

  /*srw.reference(sum_current_inv_period);*/null;

  /*srw.reference(sum_prior_inv_period);*/null;

  IF nvl(sum_prior_inv_period,0) <> 0
  THEN
    return(round(((sum_current_inv_period - sum_prior_inv_period)/sum_prior_inv_period ) * 100, 2)) ;
  ELSE
    return(0);
  END IF;
end;

function sum_c_percent_change1formula(sum_prior_period in number, sum_current_period in number) return number is
begin

  /*srw.reference(sum_current_period);*/null;

  /*srw.reference(sum_prior_period);*/null;

  IF nvl(sum_prior_period,0) <> 0
  THEN
    return(round(((sum_current_period - sum_prior_period)/sum_prior_period ) * 100, 2)) ;
  ELSE
    return(0);
  END IF;
end;

function sum_a_percent_change1formula(sum_prior_inv_sum in number, sum_current_inv_sum in number) return number is
begin

  /*srw.reference(sum_current_inv_sum);*/null;

  /*srw.reference(sum_prior_inv_sum);*/null;

  IF nvl(sum_prior_inv_sum,0) <> 0
  THEN
    return(round(((sum_current_inv_sum - sum_prior_inv_sum)/sum_prior_inv_sum ) * 100, 2)) ;
  ELSE
    return(0);
  END IF;
end;

function sum_s_percent_change1formula(sum_prior_sum in number, sum_current_sum in number) return number is
begin

  /*srw.reference(sum_current_sum);*/null;

  /*srw.reference(sum_prior_sum);*/null;

  IF nvl(sum_prior_sum,0) <> 0
  THEN
    return(round(((sum_current_sum - sum_prior_sum)/sum_prior_sum ) * 100, 2)) ;
  ELSE
    return(0);
  END IF;
end;

function AfterReport return boolean is
begin
  /*srw.user_exit('FND SRWEXIT');*/null;

  return (TRUE);
end;

--Functions to refer Oracle report placeholders--

 Function Current_Inv_Period_p return number is
	Begin
	 return Current_Inv_Period;
	 END;
 Function Prior_Inv_Period_p return number is
	Begin
	 return Prior_Inv_Period;
	 END;
 Function P_Percent_Change_p return number is
	Begin
	 return P_Percent_Change;
	 END;
 Function Current_Inv_Sum_p return number is
	Begin
	 return Current_Inv_Sum;
	 END;
 Function Prior_Inv_Sum_p return number is
	Begin
	 return Prior_Inv_Sum;
	 END;
 Function A_Percent_Change_p return number is
	Begin
	 return A_Percent_Change;
	 END;
 Function Inv_Sum_TF_p return number is
	Begin
	 return Inv_Sum_TF;
	 END;
 Function Current_Period_p return number is
	Begin
	 return Current_Period;
	 END;
 Function Prior_Period_p return number is
	Begin
	 return Prior_Period;
	 END;
 Function C_Percent_Change_p return number is
	Begin
	 return C_Percent_Change;
	 END;
 Function Current_Sum_p return number is
	Begin
	 return Current_Sum;
	 END;
 Function Prior_Sum_p return number is
	Begin
	 return Prior_Sum;
	 END;
 Function S_Percent_Change_p return number is
	Begin
	 return S_Percent_Change;
	 END;
 Function All_Sum_CTF_p return number is
	Begin
	 return All_Sum_CTF;
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
 Function RP_SUB_TITLE_p return varchar2 is
	Begin
	 return RP_SUB_TITLE;
	 END;
 Function V_Addresses_p return number is
	Begin
	 return V_Addresses;
	 END;
 Function Prior_V_Addresses_p return number is
	Begin
	 return Prior_V_Addresses;
	 END;
 Function Address_Total_Number_p return number is
	Begin
	 return Address_Total_Number;
	 END;
 Function V_Customers_p return number is
	Begin
	 return V_Customers;
	 END;
 Function Prior_V_Customers_p return number is
	Begin
	 return Prior_V_Customers;
	 END;
 Function Cust_Total_Number_p return number is
	Begin
	 return Cust_Total_Number;
	 END;
 Function V_Inactive_Count_p return number is
	Begin
	 return V_Inactive_Count;
	 END;
 Function Customer_Change_p return varchar2 is
	Begin
	 return Customer_Change;
	 END;
 Function Address_Change_p return varchar2 is
	Begin
	 return Address_Change;
	 END;
 Function Prior_V_Inactive_Count_p return number is
	Begin
	 return Prior_V_Inactive_Count;
	 END;
 Function Inactive_Count_Total_Number_p return number is
	Begin
	 return Inactive_Count_Total_Number;
	 END;
 Function Inactive_Count_Change_p return varchar2 is
	Begin
	 return Inactive_Count_Change;
	 END;
END AR_RAXSKI_XMLP_PKG ;


/
