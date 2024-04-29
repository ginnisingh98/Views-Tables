--------------------------------------------------------
--  DDL for Package Body AR_ARXRJR_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_ARXRJR_XMLP_PKG" AS
/* $Header: ARXRJRB.pls 120.1 2008/06/04 10:53:16 npannamp noship $ */

function BeforeReport return boolean is

l_ld_sp varchar2(1);


h_sob_id number;
h_rep_type varchar2(1);
begin
/*SRW.USER_EXIT('FND SRWINIT');*/null;
/*ADDED AS FIX*/
P_REPORT_MODE_T:=NVL(P_REPORT_MODE,'Transaction');
P_ORDER_BY_T:= NVL(P_ORDER_BY,'Accounting Flexfield');
/*FIX ENDS*/

rp_message:=null;
IF to_number(p_reporting_level) = 1000 THEN
l_ld_sp:= mo_utils.check_ledger_in_sp(TO_NUMBER(p_reporting_entity_id));

IF l_ld_sp = 'N' THEN
     FND_MESSAGE.SET_NAME('FND','FND_MO_RPT_PARTIAL_LEDGER');
     rp_message := FND_MESSAGE.get;
END IF;
END IF;



FND_MESSAGE.SET_NAME('AR','AR_REPORT_ACC_NOT_GEN');
cp_acc_message := FND_MESSAGE.get;



if p_reporting_level = 1000 then
  h_sob_id := p_reporting_context;
elsif p_reporting_level = 3000 then
select set_of_books_id into h_sob_id from ar_system_parameters_all
where org_id  = p_reporting_context;
end if;

h_rep_type:='P';



p_hist:= 'ar_cash_receipt_history_all';
p_dist:='ar_xla_ard_lines_v';
p_gl:='gl_code_combinations';
p_batch:= 'ar_batches_all';
p_cash:='ar_cash_receipts_all';
p_cust:='hz_cust_accounts_all';
p_party:='hz_parties';
p_site:='hz_cust_site_uses_all';
p_rm:='ar_receipt_methods';
p_rc:='ar_receipt_classes';
p_look:='ar_lookups';

begin
    p_reporting_entity_id:=p_reporting_context;
    xla_mo_reporting_api.initialize(p_reporting_level,p_reporting_entity_id,'AUTO');
    reporting_context_name:=substrb(xla_mo_reporting_api.get_reporting_entity_name,1,80);
    reporting_entity_level_name:=reporting_context_name;
    reporting_level_name:=substrb(xla_mo_reporting_api.get_reporting_level_name,1,30);
    p_cr_where:=xla_mo_reporting_api.get_predicate('cr',null);
    p_site_where:=xla_mo_reporting_api.get_predicate('site_uses',null);
    p_cust_where:=xla_mo_reporting_api.get_predicate('cust_acct',null);
    select replace(p_cr_where,':p_reporting_entity_id',p_reporting_context),
     replace(p_cust_where,':p_reporting_entity_id',p_reporting_context),
     replace(p_site_where,':p_reporting_entity_id',p_reporting_context)
    into p_cr_where,p_cust_where,p_site_where from dual;

    If p_reporting_level <>3000 then
      begin
      select substrb(meaning,1,10) into reporting_context_name from ar_lookups
      where lookup_code='ALL' and lookup_type='ALL';
      exception
          when others then
	      reporting_context_name:=null;
      end;
    end if;
end;

declare
begin





SELECT sob.name, nvl(p_currency, sob.currency_code)
INTO   p_company_name, p_currency_disp
FROM    gl_sets_of_books sob
WHERE   sob.set_of_books_id  = h_sob_id;



 if p_in_customer_name_low is not null then
      lp_customer_name_low := ' and party.party_name >=' || ''':p_in_customer_name_low''';
      select replace(lp_customer_name_low,':p_in_customer_name_low',p_in_customer_name_low)
        into lp_customer_name_low from dual;
   end if;

   if p_in_customer_name_high is not null then
      lp_customer_name_high := ' and party.party_name <= '|| ''':p_in_customer_name_high''';
      select replace(lp_customer_name_high,':p_in_customer_name_high',p_in_customer_name_high)
        into lp_customer_name_high from dual;
   end if;


   if p_in_customer_num_low is not null then
      lp_customer_num_low := ' and cust_acct.account_number>='||''':p_in_customer_num_low''';
        select replace(lp_customer_num_low,':p_in_customer_num_low',p_in_customer_num_low)
        into lp_customer_num_low from dual;
   end if;

   if p_in_customer_num_high is not null then
      lp_customer_num_high := ' and cust_acct.account_number<='||''':p_in_customer_num_high''';
      select replace(lp_customer_num_high,':p_in_customer_num_high',p_in_customer_num_high)
       into lp_customer_num_high from dual;
   end if;


 null;


 null;

if p_in_company_low IS NOT NULL then

 null;
lp_company_low := ' and  nvl(' || lp_company_low  || ',''NULL'') >= ''' || p_in_company_low || ''' ';
end if ;

if p_in_company_high IS NOT NULL then

 null;
lp_company_high := ' and  nvl(' || lp_company_high || ',''NULL'') <= ''' || p_in_company_high || ''' ';
end if ;



if p_in_account_low IS NOT NULL then

 null;
lp_account_low := ' and  '|| lp_account_low1;

end if ;

if p_in_account_high IS NOT NULL then

 null;
lp_account_high := ' and  ' || lp_account_high1;

end if ;



LP_NAME := 'b.name';
LP_TRXDATE := 'crh.trx_date';
LP_GLDATE := 'crh.gl_date';

--if p_report_mode = 'Balance' then
if p_report_mode_t = 'Balance' then
	LP_NAME := 'NULL';
	LP_TRXDATE := 'NULL';
	LP_GLDATE := 'NULL';
end if;


C_BAL_OR_TRANS_AMOUNT := 'DECODE(d.amount_dr, null,
                DECODE(:p_currency, null,
                        -d.acctd_amount_cr, -d.amount_cr),
                DECODE(:p_currency, null,
                        d.acctd_amount_dr,  d.amount_dr) ) ';


--if p_report_mode = 'Balance' then
if p_report_mode_t = 'Balance' then
C_BAL_OR_TRANS_AMOUNT := 'SUM (DECODE(d.amount_cr, null,
                DECODE(:p_currency, null,
                	d.acctd_amount_dr, d.amount_dr),
                DECODE(:p_currency, null,
                	-d.acctd_amount_cr, -d.amount_cr))) ';
end if;


--LP_GROUP_BY := NULL;
LP_GROUP_BY := ' ';

--if p_report_mode = 'Balance' then
if p_report_mode_t = 'Balance' then
   LP_GROUP_BY := ' GROUP BY'||
		' '||lp_company_seg||','||
		' '||'cr.cash_receipt_id,'||
		' '||'st.meaning,'||
		' '||lp_accounting_flex||','||
		' '||'rc.name,'||
		' '||'rm.name,'||
		' '||'cr.receipt_number,'||
		' '||'party.party_name,'||
		' '||'cust_acct.account_number,'||
		' '||'site_uses.location ';
end if;


--C_HAVING := NULL;
--lp_order_by := NULL;
C_HAVING := ' ';
lp_order_by := ' ';

--if p_report_mode = 'Balance' then
if p_report_mode_t = 'Balance' then
   C_HAVING :=	' '||
			'HAVING'||' '||'SUM 			        (DECODE(d.amount_cr, null,
                DECODE(:p_currency, null,
                	d.acctd_amount_dr, d.amount_dr),
                DECODE(:p_currency, null,
                	-d.acctd_amount_cr,-d.amount_cr))) <> 0';
ELSE
    lp_order_by := ', cr.cash_receipt_id, crh.cash_receipt_history_id';
end if;

end;
  return (TRUE);
end;

function AfterReport return boolean is
begin

/*SRW.USER_EXIT('FND SRWEXIT');*/null;
  return (TRUE);
end;

function AfterPForm return boolean is
begin

BEGIN
IF p_gl_date_low IS NOT  NULL  THEN
	lp_gl_date_low := ' and  crh.gl_date >= :p_gl_date_low ';
END IF;

IF p_gl_date_high IS NOT  NULL  THEN
	lp_gl_date_high := ' and  crh.gl_date <= :p_gl_date_high ';
END IF;


IF p_status IS NOT  NULL  THEN
	lp_source_type := ' AND d.source_type = :p_status ';
END IF;

IF p_receipt_class IS NOT  NULL  THEN
	lp_receipt_class := ' AND rc.name = :p_receipt_class ';
END IF;

IF p_payment_method  IS NOT  NULL  THEN
	lp_payment_method := ' AND rm.name = :p_payment_method ';
END IF;

IF p_currency  IS NOT  NULL  THEN
	lp_currency := ' AND cr.currency_code = :p_currency ';
END IF;


END;

  return (TRUE);
end;


/*added as fix*/
function F_ACC_MESSAGEFormatTrigger return VARCHAR2 is
temp boolean;
begin
  temp:=(arp_util.open_period_exists(p_reporting_level,p_reporting_entity_id,p_gl_date_low,p_gl_date_high));
  if temp then
      FACCMSG:='TRUE';
  else
      FACCMSG:='FALSE';
  end if;
  RETURN (FACCMSG);

end;

--Functions to refer Oracle report placeholders--

 Function RP_DATA_FOUND_p return varchar2 is
	Begin
	 return RP_DATA_FOUND;
	 END;
 Function C_BAL_OR_TRANS_AMOUNT_p return varchar2 is
	Begin
	 return C_BAL_OR_TRANS_AMOUNT;
	 END;
 Function C_HAVING_p return varchar2 is
	Begin
	 return C_HAVING;
	 END;
 Function reporting_level_name_p return varchar2 is
	Begin
	 return reporting_level_name;
	 END;
 Function reporting_context_name_p return varchar2 is
	Begin
	 return reporting_context_name;
	 END;
 Function Reporting_entity_level_name_p return varchar2 is
	Begin
	 return Reporting_entity_level_name;
	 END;
 Function rp_message_p return varchar2 is
	Begin
	 return rp_message;
	 END;
 Function CP_ACC_MESSAGE_p return varchar2 is
	Begin
	 return CP_ACC_MESSAGE;
	 END;
END AR_ARXRJR_XMLP_PKG ;


/
