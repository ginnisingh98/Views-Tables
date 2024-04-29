--------------------------------------------------------
--  DDL for Package Body AR_RAXCBR_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_RAXCBR_XMLP_PKG" AS
/* $Header: RAXCBRB.pls 120.2 2008/01/08 15:17:39 abraghun noship $ */

function BeforeReport return boolean is
begin

     /*SRW.USER_EXIT('FND SRWINIT');*/null;


     /*srw.message ('100', 'BeforeReport: Get Source Code');*/null;




     oe_profile.get('SO_SOURCE_CODE', P_SO_SOURCE_CODE);

     /*srw.message ('100', 'BeforeReport:  Source Code:  ' || P_SO_SOURCE_CODE);*/null;




     get_boiler_plates ;





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
    SELECT substr(cp.user_concurrent_program_name, 1, 80)
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
    THEN RP_REPORT_NAME := 'Commitment Balance Report';
         RETURN('Commitment Balance Report');
END;
RETURN NULL; end;

function c_adjusted_amount_childformula(source in varchar2, trx_class in varchar2, child_customer_trx_id in number, commit_type in varchar2, customer_trx_id1 in number) return number is

	adjusted_amount	Number;
begin

/*srw.reference(customer_trx_id);*/null;

/*srw.reference(child_customer_trx_id);*/null;


IF source = 'PS' THEN
IF trx_class = 'CM' THEN
	select  nvl(sum(extended_amount),0)
	into    adjusted_amount
	from    ra_customer_trx trx, ra_customer_trx_lines line
	where   trx.customer_trx_id = line.customer_trx_id
	and     trx.customer_trx_id = child_customer_trx_id
	and     complete_flag = 'Y';

	RETURN( -adjusted_amount);

ELSE
	IF commit_type = 'GUAR' THEN
		select  nvl(sum(amount), 0)
		into    adjusted_amount
		from    ar_adjustments
		where   customer_trx_id = customer_trx_id1
		and     subsequent_trx_id = child_customer_trx_id
		and     adjustment_type = 'C';

		RETURN( -adjusted_amount);
	ELSE
		select  nvl(sum(amount),0)
		into    adjusted_amount
		from    ar_adjustments
		where   customer_trx_id = child_customer_trx_id
		and     subsequent_trx_id is null
		and     adjustment_type = 'C';

		RETURN( -adjusted_amount);
	END IF;
END IF;
END IF;
return(0);

end;

function c_oe_amountformula(customer_trx_id1 in number) return number is

	oe_amount	number;
        unbooked_amt    number;

begin



   /*srw.reference(customer_trx_id);*/null;



   oe_amount := NVL(OE_PAYMENTS_UTIL.Get_Uninvoiced_Commitment_Bal(customer_trx_id1), 0);



   if p_unbooked = 'N' then
      select
         nvl(sum(nvl(pay.commitment_applied_amount, 0) -
         nvl(pay.commitment_interfaced_amount,0)),0) om_commitment_amt
      into unbooked_amt
      from  oe_order_lines lin,
            oe_payments    pay
      where lin.header_id = pay.header_id(+)
        and lin.line_id    = pay.line_id(+)
        and lin.commitment_id = customer_trx_id1
        and NVL(lin.open_flag,'Y') = 'Y'
        and nvl(lin.booked_flag,'N') = 'N';

      oe_amount := oe_amount - unbooked_amt;

   end if;

   select NVL(oe_amount,0) +
          NVL( SUM(NVL(i.promised_commitment_amount,
                      i.amount)), 0)
   into   oe_amount
   from   ra_interface_lines i,
          ra_customer_trx_lines l
   where  nvl(interface_status,
             'A')                 <> 'P'
   and    i.line_type              = 'LINE'
   and    i.reference_line_id      = l.customer_trx_line_id
   and    l.customer_trx_id        = customer_trx_id1
   and    i.interface_line_context = p_so_source_code
   and    (EXISTS
           ( select 'valid_trx_type'
                     from ra_cust_trx_types ty
                     where (i.cust_trx_type_name = ty.name OR
                            i.cust_trx_type_id   = ty.cust_trx_type_id)
                     AND   ty.type = 'INV')
           OR EXISTS  (select 'valid sub_trx_type'
                       from   ra_customer_trx trx,
                              ra_cust_trx_types ty
                       where  trx.customer_trx_id = customer_trx_id1
                       and    trx.cust_trx_type_id = ty.cust_trx_type_id
                       and    (i.cust_trx_type_name is null AND
                               i.cust_trx_type_id is null AND
                               ty.subsequent_trx_type_id is not null)));
    return(oe_amount);
end;

function c_commitment_balanceformula(commitment_amount in number, customer_trx_id in number, commit_type in varchar2) return varchar2 is
begin

	/*srw.reference(customer_trx_id);*/null;

	/*srw.reference(commit_type);*/null;


    RETURN(  commitment_amount -
             arp_bal_util.calc_commitment_balance( customer_trx_id,
                                                   commit_type,
                                                   'N',
                                                   'N',
                                                   'XYZ' )
          );
 end;

function AfterPForm return boolean is
begin


BEGIN

	IF p_commitment_low   IS NOT NULL THEN
		lp_commitment_low     :=  ' and  trx.trx_number >=   :p_commitment_low  ';
	END IF;

	IF p_commitment_high  IS NOT NULL THEN
		lp_commitment_high    :=  ' and  trx.trx_number  <=   :p_commitment_high  ';
	END IF;

	IF p_currency_code_low IS NOT NULL THEN
		lp_currency_code_low   :=  ' and  trx.invoice_currency_code  >=   :p_currency_code_low ';
	END IF;

	IF p_currency_code_high IS NOT NULL THEN
		lp_currency_code_high    :=  ' and   trx.invoice_currency_code   <=   :p_currency_code_high  ';
	END IF;

	IF p_agreement_name_low  IS NOT NULL THEN
		lp_agreement_name_low    :=  ' and  agree.name is not null ' ||
                                              ' and  agree.name >=   :p_agreement_name_low  ';
	END IF;

	IF p_agreement_name_high  IS NOT NULL THEN
		lp_agreement_name_high    :=  ' and  agree.name is not null ' ||
                                               ' and  agree.name <=   :p_agreement_name_high  ';
	END IF;

	IF p_customer_number_low  IS NOT NULL THEN
		lp_customer_number_low    :=  ' and  cust.account_number >=   :p_customer_number_low  ';
	END IF;

	IF p_customer_number_high  IS NOT NULL THEN
		lp_customer_number_high    :=  ' and  cust.account_number  <=   :p_customer_number_high  ';
	END IF;

	IF p_customer_name_low  IS NOT NULL THEN
		lp_customer_name_low    :=  ' and   party.party_name >=   :p_customer_name_low  ';
	END IF;

	IF p_customer_name_high  IS NOT NULL THEN
		lp_customer_name_high    :=  ' and  party.party_name <=   :p_customer_name_high  ';
	END IF;

	IF p_commitment_type_low  IS NOT NULL THEN
		lp_commitment_type_low    :=  ' and  type.name >=   :p_commitment_type_low  ';
	END IF;

	IF p_commitment_type_high  IS NOT NULL THEN
		lp_commitment_type_high    :=  ' and  type.name  <=   :p_commitment_type_high  ';
	END IF;

	IF p_end_date_low IS NOT NULL THEN
	p_end_date_low_1:=to_char(to_date(p_end_date_low,'YYYY/MM/DD HH24:MI:SS'),'DD-MON-YY');
		lp_end_date_low    :=  ' and  nvl(trx.end_date_commitment,to_date(:p_end_date_low,''YYYY/MM/DD HH24:MI:SS''))  >=  to_date(:p_end_date_low,''YYYY/MM/DD HH24:MI:SS'')';
	END IF;


	IF p_end_date_high  IS NOT NULL THEN
	p_end_date_high_1:=to_char(to_date(p_end_date_high,'YYYY/MM/DD HH24:MI:SS'),'DD-MON-YY');
		lp_end_date_high    :=  ' and  nvl(trx.end_date_commitment,to_date(:p_end_date_high,''YYYY/MM/DD HH24:MI:SS'')) <=  to_date(:p_end_date_high,''YYYY/MM/DD HH24:MI:SS'') ';
	END IF;

	IF p_gl_date_low IS NOT NULL THEN
		lp_gl_date_low    :=  ' and  nvl(lgd.gl_date,:p_gl_date_low)  >=  :p_gl_date_low ';
	END IF;


	IF p_gl_date_high  IS NOT NULL THEN
		lp_gl_date_high    :=  ' and  nvl(lgd.gl_date,:p_gl_date_high) <=  :p_gl_date_high ';
	END IF;

	IF p_trx_date_low IS NOT NULL THEN
		lp_trx_date_low    :=  ' and  nvl(trx.trx_date,:p_trx_date_low)  >=  :p_trx_date_low ';
	END IF;


	IF p_trx_date_high  IS NOT NULL THEN
		lp_trx_date_high    :=  ' and  nvl(trx.trx_date,:p_trx_date_high) <=  :p_trx_date_high ';
	END IF;

                if p_unbooked = 'N' THEN
           lp_unbooked := ' and nvl(lin.booked_flag,''N'') = ''Y'' ';
        else
           lp_unbooked := ' ';
        end if;

END;  return (TRUE);
end;

procedure get_lookup_meaning(p_lookup_type	in VARCHAR2,
			     p_lookup_code	in VARCHAR2,
			     p_lookup_meaning  	in out NOCOPY VARCHAR2)
			    is

w_meaning varchar2(80);

begin

select meaning
  into w_meaning
  from fnd_lookups
 where lookup_type = p_lookup_type
   and lookup_code = p_lookup_code ;

p_lookup_meaning := w_meaning ;

exception
   when no_data_found then
        		p_lookup_meaning := null ;

end ;

procedure get_boiler_plates is

w_industry_code varchar2(20);
w_industry_stat varchar2(20);

begin

if fnd_installation.get(0, 0,
                        w_industry_stat,
	    	        w_industry_code) then
   if w_industry_code = 'C' then
      c_salesrep_title   := null ;
      c_salesorder_title := null ;
   else
      get_lookup_meaning('IND_SALES_REP',
                       	 w_industry_code,
			 c_salesrep_title);
      get_lookup_meaning('IND_SALES_ORDER',
                       	 w_industry_code,
			 c_salesorder_title);
   end if;
end if;

c_industry_code :=   w_Industry_code ;

end ;

function set_display_for_core(p_field_name in VARCHAR2)
         return boolean is

begin

if c_industry_code = 'C' then
   return(TRUE);
elsif p_field_name = 'SALESREP' then
   if c_salesrep_title is not null then
      return(FALSE);
   else
      return(TRUE);
   end if;
elsif p_field_name = 'SALESORDER' then
   if c_salesorder_title is not null then
      return(FALSE);
   else
      return(TRUE);
   end if;
end if;

RETURN NULL; end;

function set_display_for_gov(p_field_name in VARCHAR2)
         return boolean is

begin


if c_industry_code = 'C' then
   return(FALSE);
elsif p_field_name = 'SALESREP' then
   if c_salesrep_title is not null then
      return(TRUE);
   else
      return(FALSE);
   end if;
elsif p_field_name = 'SALESORDER' then
   if c_salesorder_title is not null then
      return(TRUE);
   else
      return(FALSE);
   end if;
end if;

RETURN NULL; end ;

function C_Order_ByFormula return Char is
   order_meaning AR_LOOKUPS.MEANING%TYPE;
begin

  SELECT
    MEANING
  INTO order_meaning
  FROM AR_LOOKUPS
  WHERE LOOKUP_TYPE = 'SORT_BY_RAXCBR'
        AND UPPER(LOOKUP_CODE) = UPPER(P_SORT_BY);

  RETURN (ORDER_MEANING);

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN(P_SORT_BY);

end;

function c_commitment_remformula(commitment_amount in number, c_commitment_balance in varchar2, c_oe_amount in number) return number is
	commitment_remaining	Number;
begin

	/*srw.reference(commitment_amount);*/null;

	/*srw.reference(c_commitment_balance);*/null;

	/*srw.reference(c_oe_amount);*/null;


	commitment_remaining := nvl(commitment_amount,0)
	                     - nvl(c_commitment_balance,0)
	                     - nvl(c_oe_amount,0);

	RETURN(commitment_remaining);
end;

function c_adj_amt_cmformula(source1 in varchar2, commit_type in varchar2, child_customer_trx_id in number, child_cm_customer_trx_id in number, customer_trx_id1 in number) return number is
	adjusted_amount	Number;
begin

/*srw.reference(customer_trx_id);*/null;

/*srw.reference(child_customer_trx_id);*/null;


IF source1 = 'PS' THEN
	IF commit_type = 'DEP' THEN
		select  nvl(sum(amount),0)
		into    adjusted_amount
		from    ar_adjustments
		where   customer_trx_id = child_customer_trx_id
		and     subsequent_trx_id = child_cm_customer_trx_id
		and     adjustment_type = 'C';


		RETURN( -adjusted_amount);
	ELSE
		select  nvl(sum(amount), 0)
		into    adjusted_amount
		from    ar_adjustments
		where   customer_trx_id = customer_trx_id1
		and     subsequent_trx_id = child_cm_customer_trx_id
		and     adjustment_type = 'C';

		RETURN( -adjusted_amount);
	END IF;
ELSE
     return(0);
END IF;


end;

function c_sum_invoiced_amount_arformul(sum_invoiced_amount_inv in number, sum_invoiced_amount_cm in number) return number is
begin
 /*srw.reference(sum_invoiced_amount_inv);*/null;

 /*srw.reference(sum_invoiced_amount_cm);*/null;

 return(nvl(sum_invoiced_amount_inv,0) + nvl(sum_invoiced_amount_cm,0) );
end;

function c_sum_tax_amount_arformula(sum_tax_amount_inv in number, sum_tax_amount_cm in number) return number is
begin
  /*srw.reference(sum_tax_amount_inv);*/null;

 /*srw.reference(sum_tax_amount_cm);*/null;

 return(nvl(sum_tax_amount_inv,0) + nvl(sum_tax_amount_cm,0) );
end;

function c_sum_freight_amount_arformula(sum_freight_amount_inv in number, sum_freight_amount_cm in number) return number is
begin
 /*srw.reference(sum_freight_amount_inv);*/null;

 /*srw.reference(sum_freight_amount_cm);*/null;

 return(nvl(sum_freight_amount_inv,0) + nvl(sum_freight_amount_cm,0) );
end;

function c_sum_line_amount_arformula(sum_line_amount_inv in number, sum_line_amount_cm in number) return number is
begin
 /*srw.reference(sum_line_amount_inv);*/null;

 /*srw.reference(sum_line_amount_cm);*/null;

 return(nvl(sum_line_amount_inv,0) + nvl(sum_line_amount_cm,0) );
end;

function c_sum_adjusted_amount_arformul(sum_adjusted_amount_inv in number, sum_adjusted_amount_cm in number) return number is
begin
 /*srw.reference(sum_adjusted_amount_inv);*/null;

 /*srw.reference(sum_adjusted_amount_cm);*/null;

 return(nvl(sum_adjusted_amount_inv,0) + nvl(sum_adjusted_amount_cm,0) );
end;

function c_sum_bal_amount_arformula(sum_bal_amount_inv in number, sum_bal_amount_cm in number) return number is
begin
 /*srw.reference(sum_bal_amount_inv);*/null;

 /*srw.reference(sum_bal_amount_cm);*/null;

 return(nvl(sum_bal_amount_inv,0) + nvl(sum_bal_amount_cm,0));
end;

function C_FORMAT_LEVELFormula return Char is
   meaning FND_LOOKUP_VALUES_VL.meaning%TYPE;
begin

  SELECT
    MEANING
  INTO meaning
  FROM FND_LOOKUP_VALUES_VL
  WHERE LOOKUP_TYPE = 'RAXCBR_FORMAT'
        AND UPPER(LOOKUP_CODE) = UPPER(P_LEVEL);

  RETURN (meaning);

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN(P_Level);




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
 Function c_industry_code_p return varchar2 is
	Begin
	 return c_industry_code;
	 END;
 Function c_salesrep_title_p return varchar2 is
	Begin
	 return c_salesrep_title;
	 END;
 Function c_salesorder_title_p return varchar2 is
	Begin
	 return c_salesorder_title;
	 END;
END AR_RAXCBR_XMLP_PKG ;

/
