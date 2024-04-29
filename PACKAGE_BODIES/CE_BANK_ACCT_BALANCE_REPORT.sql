--------------------------------------------------------
--  DDL for Package Body CE_BANK_ACCT_BALANCE_REPORT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CE_BANK_ACCT_BALANCE_REPORT" AS
/*  $Header: cexmlbrb.pls 120.9.12010000.4 2010/02/24 07:21:24 talapati ship $	*/

-- if exchange rate is not available for all bank account currencies, return -1, else return 1
function get_total_balance_flag
  (
   p_branch_party_id      varchar2,
   p_bank_acct_id        varchar2,
   p_bank_acct_currency   VARCHAR2,
   p_legal_entity_id         number,
   l_date           date,
   p_reporting_currency   varchar2,
   p_exchange_rate_type   varchar2,
   p_exchange_rate_date   varchar2
  )
  return number
is
  cursor cursor_bank_currency_code is
    select  distinct ba.CURRENCY_CODE
     from ce_bank_accounts ba, ce_bank_branches_v bh, ce_bank_acct_balances bb
     where ba.BANK_BRANCH_ID = bh.BRANCH_PARTY_ID
       and ba.BANK_ACCOUNT_ID = bb.BANK_ACCOUNT_ID
       and bb.BALANCE_DATE = l_date
       and bh.BRANCH_PARTY_ID = nvl(p_branch_party_id, bh.BRANCH_PARTY_ID)
       and ba.BANK_ACCOUNT_ID = nvl(p_bank_acct_id, ba.BANK_ACCOUNT_ID)
       and ba.CURRENCY_CODE = nvl(p_bank_acct_currency, ba.CURRENCY_CODE)
       and ba.ACCOUNT_OWNER_ORG_ID = nvl(p_legal_entity_id, ba.ACCOUNT_OWNER_ORG_ID);
  l_total_balance_flag number;
  v_currency_code varchar2(10);

begin
  open cursor_bank_currency_code;
  loop
    fetch cursor_bank_currency_code into v_currency_code;
    exit when cursor_bank_currency_code%NOTFOUND;
    if -1 = CE_BANKACCT_BA_REPORT_UTIL.get_rate(v_currency_code,  p_reporting_currency, p_exchange_rate_date,p_exchange_rate_type) then
      close cursor_bank_currency_code;
      return -1;
    end if;
  end loop;
  close cursor_bank_currency_code;
  return 1;

end get_total_balance_flag;

procedure get_balance_near_date
 (p_bank_account_id varchar2,
  p_date date,
  p_BalanceAC OUT NOCOPY number,
  p_nearest_Date OUT NOCOPY date ,
  p_balance_type varchar2)
is
  v_date_offset number;
  v_date date;
  v_balance number;

begin

  v_date := p_date;
--fnd_file.put_line(FND_FILE.LOG, p_bank_account_id);
--fnd_file.put_line(fnd_file.log, 'as of date ' || to_char(p_date, 'YYYY/MM/DD HH24:MI:SS'));
--fnd_file.put_line(fnd_file.log,  'balance type ' || p_balance_type);
--fnd_file.put_line(fnd_file.log,  'exchange rate type ' || p_exchange_rate_type);

/*
  v_LegerBalanceAC number;
  v_AvailableBalanceAC number;
  v_IntCalBalanceAC number;
  v_OneDayFloatAC number;
  v_TwoDayFloatAC number;
  v_AvgLegerMTDAC number;
  v_AvgLegerYTDAC number;
  v_AvgAvailableMTDAC number;
  v_AvgAvailableYTDAC number;
*/

-- when balance type is LegerBalance
if p_balance_type = 'LegerBalance' then

  select min(abs(BALANCE_DATE - p_date))
	into v_date_offset
  from ce_bank_acct_balances bb
  where bb.BANK_ACCOUNT_ID = p_bank_account_id
      and bb.LEDGER_BALANCE is not null;

  if v_date_offset is not null then
     select min(balance_date)
       into v_date
     from ce_bank_acct_balances bb
     where bb.BANK_ACCOUNT_ID = p_bank_account_id
       and abs(BALANCE_DATE - p_date) = v_date_offset
       and bb.LEDGER_BALANCE is not null;

     select LEDGER_BALANCE
       into v_balance
     from ce_bank_acct_balances
     where BANK_ACCOUNT_ID = p_bank_account_id
       and BALANCE_DATE = v_date;

  end if;
end if;

-- when balance type is AvailableBalance
if p_balance_type = 'AvailableBalance' then

  select min(abs(BALANCE_DATE - p_date))
	into v_date_offset
  from ce_bank_acct_balances bb
  where bb.BANK_ACCOUNT_ID = p_bank_account_id
      and bb.AVAILABLE_BALANCE is not null;

  if v_date_offset is not null then
     select min(balance_date)
       into v_date
     from ce_bank_acct_balances bb
     where bb.BANK_ACCOUNT_ID = p_bank_account_id
       and abs(BALANCE_DATE - p_date) = v_date_offset
       and bb.AVAILABLE_BALANCE is not null;

     select AVAILABLE_BALANCE
       into v_balance
     from ce_bank_acct_balances
     where BANK_ACCOUNT_ID = p_bank_account_id
       and BALANCE_DATE = v_date;

--fnd_file.put_line(fnd_file.log,  'v balance ' || v_balance);

  end if;
end if;

-- when balance type is VALUE_DATED_BALANCE
if p_balance_type = 'IntCalBalance' then

  select min(abs(BALANCE_DATE - p_date))
	into v_date_offset
  from ce_bank_acct_balances bb
  where bb.BANK_ACCOUNT_ID = p_bank_account_id
      and bb.VALUE_DATED_BALANCE is not null;

  if v_date_offset is not null then
     select min(balance_date)
       into v_date
     from ce_bank_acct_balances bb
     where bb.BANK_ACCOUNT_ID = p_bank_account_id
       and abs(BALANCE_DATE - p_date) = v_date_offset
       and bb.VALUE_DATED_BALANCE is not null;

     select VALUE_DATED_BALANCE
       into v_balance
     from ce_bank_acct_balances
     where BANK_ACCOUNT_ID = p_bank_account_id
       and BALANCE_DATE = v_date;

  end if;
end if;

-- when balance type is ONE_DAY_FLOAT
if p_balance_type = 'OneDayFloat' then

  select min(abs(BALANCE_DATE - p_date))
	into v_date_offset
  from ce_bank_acct_balances bb
  where bb.BANK_ACCOUNT_ID = p_bank_account_id
      and bb.ONE_DAY_FLOAT is not null;

  if v_date_offset is not null then
     select min(balance_date)
       into v_date
     from ce_bank_acct_balances bb
     where bb.BANK_ACCOUNT_ID = p_bank_account_id
       and abs(BALANCE_DATE - p_date) = v_date_offset
       and bb.ONE_DAY_FLOAT is not null;

     select ONE_DAY_FLOAT
       into v_balance
     from ce_bank_acct_balances
     where BANK_ACCOUNT_ID = p_bank_account_id
       and BALANCE_DATE = v_date;

  end if;
end if;

-- when balance type is TWO_DAY_FLOAT
if p_balance_type = 'TwoDayFloat' then

  select min(abs(BALANCE_DATE - p_date))
	into v_date_offset
  from ce_bank_acct_balances bb
  where bb.BANK_ACCOUNT_ID = p_bank_account_id
      and bb.TWO_DAY_FLOAT is not null;

  if v_date_offset is not null then
     select min(balance_date)
       into v_date
     from ce_bank_acct_balances bb
     where bb.BANK_ACCOUNT_ID = p_bank_account_id
       and abs(BALANCE_DATE - p_date) = v_date_offset
       and bb.TWO_DAY_FLOAT is not null;

     select TWO_DAY_FLOAT
       into v_balance
     from ce_bank_acct_balances
     where BANK_ACCOUNT_ID = p_bank_account_id
       and BALANCE_DATE = v_date;

  end if;
end if;

-- when balance type is AVERAGE_CLOSE_LEDGER_MTD
if p_balance_type = 'AvgLegerMTD' then

  select min(abs(BALANCE_DATE - p_date))
	into v_date_offset
  from ce_bank_acct_balances bb
  where bb.BANK_ACCOUNT_ID = p_bank_account_id
      and bb.AVERAGE_CLOSE_LEDGER_MTD is not null;

  if v_date_offset is not null then
     select min(balance_date)
       into v_date
     from ce_bank_acct_balances bb
     where bb.BANK_ACCOUNT_ID = p_bank_account_id
       and abs(BALANCE_DATE - p_date) = v_date_offset
       and bb.AVERAGE_CLOSE_LEDGER_MTD is not null;

     select AVERAGE_CLOSE_LEDGER_MTD
       into v_balance
     from ce_bank_acct_balances
     where BANK_ACCOUNT_ID = p_bank_account_id
       and BALANCE_DATE = v_date;

  end if;
end if;

-- when balance type is AVERAGE_CLOSE_LEDGER_YTD
if p_balance_type = 'AvgLegerYTD' then

  select min(abs(BALANCE_DATE - p_date))
	into v_date_offset
  from ce_bank_acct_balances bb
  where bb.BANK_ACCOUNT_ID = p_bank_account_id
      and bb.AVERAGE_CLOSE_LEDGER_YTD is not null;

  if v_date_offset is not null then
     select min(balance_date)
       into v_date
     from ce_bank_acct_balances bb
     where bb.BANK_ACCOUNT_ID = p_bank_account_id
       and abs(BALANCE_DATE - p_date) = v_date_offset
       and bb.AVERAGE_CLOSE_LEDGER_YTD is not null;

     select AVERAGE_CLOSE_LEDGER_YTD
       into v_balance
     from ce_bank_acct_balances
     where BANK_ACCOUNT_ID = p_bank_account_id
       and BALANCE_DATE = v_date;

  end if;
end if;

-- when balance type is AVERAGE_CLOSE_AVAILABLE_MTD
if p_balance_type = 'AvgAvailableMTD' then

  select min(abs(BALANCE_DATE - p_date))
	into v_date_offset
  from ce_bank_acct_balances bb
  where bb.BANK_ACCOUNT_ID = p_bank_account_id
      and bb.AVERAGE_CLOSE_AVAILABLE_MTD is not null;

  if v_date_offset is not null then
     select min(balance_date)
       into v_date
     from ce_bank_acct_balances bb
     where bb.BANK_ACCOUNT_ID = p_bank_account_id
       and abs(BALANCE_DATE - p_date) = v_date_offset
       and bb.AVERAGE_CLOSE_AVAILABLE_MTD is not null;

     select AVERAGE_CLOSE_AVAILABLE_MTD
       into v_balance
     from ce_bank_acct_balances
     where BANK_ACCOUNT_ID = p_bank_account_id
       and BALANCE_DATE = v_date;

  end if;
end if;

-- when balance type is AVERAGE_CLOSE_AVAILABLE_YTD
if p_balance_type = 'AvgAvailableYTD' then

  select min(abs(BALANCE_DATE - p_date))
	into v_date_offset
  from ce_bank_acct_balances bb
  where bb.BANK_ACCOUNT_ID = p_bank_account_id
      and bb.AVERAGE_CLOSE_AVAILABLE_YTD is not null;

  if v_date_offset is not null then
     select min(balance_date)
       into v_date
     from ce_bank_acct_balances bb
     where bb.BANK_ACCOUNT_ID = p_bank_account_id
       and abs(BALANCE_DATE - p_date) = v_date_offset
       and bb.AVERAGE_CLOSE_AVAILABLE_YTD is not null;

     select AVERAGE_CLOSE_AVAILABLE_YTD
       into v_balance
     from ce_bank_acct_balances
     where BANK_ACCOUNT_ID = p_bank_account_id
       and BALANCE_DATE = v_date;

  end if;
end if;

p_BalanceAC := v_balance;
p_nearest_Date := v_date;

end get_balance_near_date;


procedure single_day_balance_report
  (errbuf OUT NOCOPY      VARCHAR2,
   retcode OUT NOCOPY     NUMBER,
   p_branch_party_id      varchar2,
   p_bank_acct_id        varchar2,
   p_bank_acct_currency   VARCHAR2,
   p_legal_entity_id         number,
   p_as_of_date           varchar2,
   p_reporting_currency   varchar2,
   p_exchange_rate_type   varchar2,
   p_exchange_rate_date   varchar2
  )
is

  l_length number;
  l_offset number;
  l_amount number;
  l_buffer varchar2(32767);
  l_xml_doc clob;
  l_xml xmltype;
  l_date   date;
  l_date_offset number;
  l_exchange_rate number;
  xrate number;
  l_total_balance_flag number;
  l_Bank_Branch_Name varchar2(100);
  l_Bank_ACCT_NAME varchar2(100);
  l_exchange_rate_date  varchar2(200);
  l_legal_entity_name varchar2(200);

  v_currency_code varchar2(15);
  v_bank_account_id number;
  v_date date;

  v_LegerBalanceAC number;
  v_AvailableBalanceAC number;
  v_IntCalBalanceAC number;
  v_OneDayFloatAC number;
  v_TwoDayFloatAC number;
  v_AvgLegerMTDAC number;
  v_AvgLegerYTDAC number;
  v_AvgAvailableMTDAC number;
  v_AvgAvailableYTDAC number;

  v_LegerBalance_Date date;
  v_AvailableBalance_Date date;
  v_IntCalBalance_Date date;
  v_OneDayFloat_Date date;
  v_TwoDayFloat_Date date;
  v_AvgLegerMTD_Date date;
  v_AvgLegerYTD_Date date;
  v_AvgAvailableMTD_Date date;
  v_AvgAvailableYTD_Date date;

  v_LegerBalanceSubTAC number;
  v_AvailableBalanceSubTAC number;
  v_IntCalBalanceSubTAC number;
  v_OneDayFloatSubTAC number;
  v_TwoDayFloatSubTAC number;
  v_AvgLegerMTDSubTAC number;
  v_AvgLegerYTDSubTAC number;
  v_AvgAvailableMTDSubTAC number;
  v_AvgAvailableYTDSubTAC number;

  v_LegerBalanceRC number;
  v_AvailableBalanceRC number;
  v_IntCalBalanceRC number;
  v_OneDayFloatRC number;
  v_TwoDayFloatRC number;
  v_AvgLegerMTDRC number;
  v_AvgLegerYTDRC number;
  v_AvgAvailableMTDRC number;
  v_AvgAvailableYTDRC number;

  v_LegerBalanceSubTRC number;
  v_AvailableBalanceSubTRC number;
  v_IntCalBalanceSubTRC number;
  v_OneDayFloatSubTRC number;
  v_TwoDayFloatSubTRC number;
  v_AvgLegerMTDSubTRC number;
  v_AvgLegerYTDSubTRC number;
  v_AvgAvailableMTDSubTRC number;
  v_AvgAvailableYTDSubTRC number;

  v_LegerBalanceTotal number;
  v_AvailableBalanceTotal number;
  v_IntCalBalanceTotal number;
  v_OneDayFloatTotal number;
  v_TwoDayFloatTotal number;
  v_AvgLegerMTDTotal number;
  v_AvgLegerYTDTotal number;
  v_AvgAvailableMTDTotal number;
  v_AvgAvailableYTDTotal number;
  counterflag number; -- Bug 8620223

  cursor cursor_bank_currency_code is
    select  distinct ba.CURRENCY_CODE
     from ce_bank_accounts ba, ce_bank_branches_v bh, ce_bank_acct_balances bb
     where ba.BANK_BRANCH_ID = bh.BRANCH_PARTY_ID
       and ba.BANK_ACCOUNT_ID = bb.BANK_ACCOUNT_ID
  --  Bug 8620223 and bb.BALANCE_DATE = l_date
       and bh.BRANCH_PARTY_ID = nvl(p_branch_party_id, bh.BRANCH_PARTY_ID)
       and ba.BANK_ACCOUNT_ID = nvl(p_bank_acct_id, ba.BANK_ACCOUNT_ID)
       and ba.CURRENCY_CODE = nvl(p_bank_acct_currency, ba.CURRENCY_CODE)
       and ba.ACCOUNT_OWNER_ORG_ID = nvl(p_legal_entity_id, ba.ACCOUNT_OWNER_ORG_ID);

  --  Bug 8620223
  cursor cursor_bank_account_id (currency varchar2) is
    select distinct ba.bank_account_id
     --from ce_bank_accounts ba, ce_bank_branches_v bh, ce_bank_acct_balances bb
     from CE_BANK_ACCTS_GT_V ba, ce_bank_branches_v bh, ce_bank_acct_balances bb
     where ba.BANK_BRANCH_ID = bh.BRANCH_PARTY_ID
       and ba.BANK_ACCOUNT_ID = bb.BANK_ACCOUNT_ID
       --and bb.BALANCE_DATE = l_date
       and bh.BRANCH_PARTY_ID = nvl(p_branch_party_id, bh.BRANCH_PARTY_ID)
       and ba.BANK_ACCOUNT_ID = nvl(p_bank_acct_id, ba.BANK_ACCOUNT_ID)
       and ba.CURRENCY_CODE = currency
       and ba.ACCOUNT_OWNER_ORG_ID = nvl(p_legal_entity_id, ba.ACCOUNT_OWNER_ORG_ID);

  v_xml_1 xmltype;
  v_xml_2 xmltype;
  v_xml_3 xmltype;
  v_exchange_rate number;
  v_dummy number;

  v_xml_seg1 xmltype;
  v_xml_seg2 xmltype;
  v_xml_seg3 xmltype;

  n_loop number :=0;

begin
--fnd_file.put_line(FND_FILE.LOG, 'start single day reporting processing');
--fnd_file.put_line(fnd_file.log, 'as of date ' || to_char(to_date(p_as_of_date, 'YYYY/MM/DD HH24:MI:SS')));
--fnd_file.put_line(fnd_file.log,  'reportint currency ' || p_reporting_currency);
--fnd_file.put_line(fnd_file.log,  'exchange rate type ' || p_exchange_rate_type);

 -- populate ce_security_profiles_gt table with ce_security_procfiles_v
-- CEP_STANDARD.init_security;

--if p_exchange_rate_date is not null then
--  p_exchange_rate_date := to_char(sysdate, 'YYYY/MM/DD HH24:MI:SS');
--end if;

-- set l_date to p_as_of_date
l_date := to_date(p_as_of_date, 'YYYY/MM/DD HH24:MI:SS');

-- get total_balance_flag, 1 when exchange rate exists for all currencies for query conditions
l_total_balance_flag :=  get_total_balance_flag(p_branch_party_id,p_bank_acct_id,p_bank_acct_currency,p_legal_entity_id,l_date,p_reporting_currency,p_exchange_rate_type,nvl(p_exchange_rate_date,to_char(sysdate, 'YYYY/MM/DD HH24:MI:SS')));
--fnd_file.put_line(fnd_file.log, 'l_total_balance_flag '||to_char(l_total_balance_flag));

-- get bank branch name
if p_branch_party_id is not null then
   select BANK_BRANCH_NAME
   into l_Bank_Branch_Name
   from ce_bank_branches_v
   where BRANCH_PARTY_ID = p_branch_party_id;
end if;

-- get bank account name
if p_bank_acct_id is not null then
   select BANK_ACCOUNT_NAME
   into l_Bank_ACCT_NAME
   from ce_bank_accounts
   where BANK_ACCOUNT_ID = p_bank_acct_id;
end if;


-- get exchange rate date
if p_reporting_currency is null then
  l_exchange_rate_date := null;
else
  l_exchange_rate_date := to_char(to_date(nvl(p_exchange_rate_date, to_char(sysdate, 'YYYY/MM/DD HH24:MI:SS')), 'YYYY/MM/DD HH24:MI:SS'));
end if;

-- get legal entity name
if p_legal_entity_id is not null then
  select name
  into l_legal_entity_name
  from CE_LE_BG_OU_VS_V
  where legal_entity_id = p_legal_entity_id and organization_type = 'LEGAL_ENTITY';
end if;
CEP_STANDARD.init_security; -- Bug 8620223
-- loop through all currencies to generate the XML node BankAccttGroupByCurrency
open cursor_bank_currency_code;
  loop
    fetch cursor_bank_currency_code into v_currency_code;
    exit when cursor_bank_currency_code%NOTFOUND;

-- reset xml_seg varialble to null
  v_xml_seg1 := null;
  v_xml_seg2 := null;
  v_xml_seg3 := null;
  counterflag:=0;

    -- get exchange rate, if exchange rate is -1, set all RC subtotal to XXX
    v_exchange_rate := CE_BANKACCT_BA_REPORT_UTIL.get_rate(v_currency_code,  p_reporting_currency, nvl(p_exchange_rate_date,to_char(sysdate, 'YYYY/MM/DD HH24:MI:SS')) ,p_exchange_rate_type);

   -- set all subtotals to null

  v_LegerBalanceSubTAC := null;
  v_AvailableBalanceSubTAC := null;
  v_IntCalBalanceSubTAC := null;
  v_OneDayFloatSubTAC := null;
  v_TwoDayFloatSubTAC := null;
  v_AvgLegerMTDSubTAC := null;
  v_AvgLegerYTDSubTAC := null;
  v_AvgAvailableMTDSubTAC := null;
  v_AvgAvailableYTDSubTAC := null;

  v_LegerBalanceSubTRC := null;
  v_AvailableBalanceSubTRC := null;
  v_IntCalBalanceSubTRC := null;
  v_OneDayFloatSubTRC := null;
  v_TwoDayFloatSubTRC := null;
  v_AvgLegerMTDSubTRC := null;
  v_AvgLegerYTDSubTRC := null;
  v_AvgAvailableMTDSubTRC := null;
  v_AvgAvailableYTDSubTRC := null;

  n_loop := n_loop+1;
fnd_file.put_line(FND_FILE.LOG, 'n_loop  ' || n_loop);
fnd_file.put_line(FND_FILE.LOG, 'currency  ' || v_currency_code);

   open cursor_bank_account_id(v_currency_code);
     loop
	fetch cursor_bank_account_id into v_bank_account_id;
	exit when cursor_bank_account_id%NOTFOUND;

	counterflag:= counterflag+1;


fnd_file.put_line(FND_FILE.LOG, 'bank account id  ' || v_bank_account_id);

        -- get the xml segment containing only the current account id info
-- Bug 8620223
begin
	select bb.LEDGER_BALANCE, bb.AVAILABLE_BALANCE, bb.VALUE_DATED_BALANCE, bb.ONE_DAY_FLOAT, bb.TWO_DAY_FLOAT, bb.AVERAGE_CLOSE_LEDGER_MTD, bb.AVERAGE_CLOSE_LEDGER_YTD, bb.AVERAGE_CLOSE_AVAILABLE_MTD, bb.AVERAGE_CLOSE_AVAILABLE_YTD
        into v_LegerBalanceAC, v_AvailableBalanceAC, v_IntCalBalanceAC, v_OneDayFloatAC, v_TwoDayFloatAC, v_AvgLegerMTDAC, v_AvgLegerYTDAC, v_AvgAvailableMTDAC, v_AvgAvailableYTDAC
        from ce_bank_acct_balances bb
        where bb.BALANCE_DATE = l_date
        and bb.BANK_ACCOUNT_ID = v_bank_account_id;
Exception
  when no_data_found THEN
  v_LegerBalanceAC:=null;
  v_AvailableBalanceAC:=null;
  v_IntCalBalanceAC:=null;
  v_OneDayFloatAC:=null;
  v_TwoDayFloatAC:=null;
  v_AvgLegerMTDAC:=null;
  v_AvgLegerYTDAC:=null;
  v_AvgAvailableMTDAC:=null;
  v_AvgAvailableYTDAC:=null;
end;

-- reset all dates to today

  v_LegerBalance_Date := l_date;
  v_AvailableBalance_Date := l_date;
  v_IntCalBalance_Date := l_date;
  v_OneDayFloat_Date := l_date;
  v_TwoDayFloat_Date := l_date;
  v_AvgLegerMTD_Date := l_date;
  v_AvgLegerYTD_Date := l_date;
  v_AvgAvailableMTD_Date := l_date;
  v_AvgAvailableYTD_Date := l_date;



	  -- get v_LegerBalanceAC from the nearest date
        if v_LegerBalanceAC is null then
           get_balance_near_date(v_bank_account_id, l_date, v_LegerBalanceAC, v_LegerBalance_Date, 'LegerBalance');
	end if;

	-- set the v_LegerBalanceRC
	select decode(v_exchange_rate, -1, v_dummy, v_LegerBalanceAC*CE_BANKACCT_BA_REPORT_UTIL.get_rate(v_currency_code,  p_reporting_currency, nvl(p_exchange_rate_date, to_char(sysdate, 'YYYY/MM/DD HH24:MI:SS')),p_exchange_rate_type))
        into v_LegerBalanceRC
        from dual;

	-- get v_AvailableBalanceAC from the nearest date
	if v_AvailableBalanceAC is null then
           get_balance_near_date(v_bank_account_id, l_date, v_AvailableBalanceAC, v_AvailableBalance_Date, 'AvailableBalance');
	end if;

--fnd_file.put_line(FND_FILE.LOG, 'available balance ' || v_AvailableBalanceAC );

	-- set the v_AvailableBalanceRC
	select decode(v_exchange_rate, -1, v_dummy, v_AvailableBalanceAC*CE_BANKACCT_BA_REPORT_UTIL.get_rate(v_currency_code,  p_reporting_currency, nvl(p_exchange_rate_date, to_char(sysdate, 'YYYY/MM/DD HH24:MI:SS')) ,p_exchange_rate_type))
        into v_AvailableBalanceRC
        from dual;

	-- get v_IntCalBalanceAC from the nearest date
	if v_IntCalBalanceAC is null then
           get_balance_near_date(v_bank_account_id, l_date, v_IntCalBalanceAC, v_IntCalBalance_Date, 'IntCalBalance');
	end if;

	-- set the v_IntCalBalanceRC
	select decode(v_exchange_rate, -1, v_dummy, v_IntCalBalanceAC*CE_BANKACCT_BA_REPORT_UTIL.get_rate(v_currency_code,  p_reporting_currency, nvl(p_exchange_rate_date, to_char(sysdate, 'YYYY/MM/DD HH24:MI:SS')),p_exchange_rate_type))
        into v_IntCalBalanceRC
        from dual;

	-- get v_OneDayFloatAC from the nearest date
	if v_OneDayFloatAC is null then
           get_balance_near_date(v_bank_account_id, l_date, v_OneDayFloatAC, v_OneDayFloat_Date, 'OneDayFloat');
	end if;

	-- set the v_OneDayFloatRC
	select decode(v_exchange_rate, -1, v_dummy, v_OneDayFloatAC*CE_BANKACCT_BA_REPORT_UTIL.get_rate(v_currency_code,  p_reporting_currency, nvl(p_exchange_rate_date,to_char(sysdate, 'YYYY/MM/DD HH24:MI:SS')) ,p_exchange_rate_type))
        into v_OneDayFloatRC
        from dual;

	-- get v_TwoDayFloatAC from the nearest date
	if v_TwoDayFloatAC is null then
           get_balance_near_date(v_bank_account_id, l_date, v_TwoDayFloatAC, v_TwoDayFloat_Date, 'TwoDayFloat');
	end if;

	-- set the v_TwoDayFloatRC
	select decode(v_exchange_rate, -1, v_dummy, v_TwoDayFloatAC*CE_BANKACCT_BA_REPORT_UTIL.get_rate(v_currency_code,  p_reporting_currency, nvl(p_exchange_rate_date, to_char(sysdate, 'YYYY/MM/DD HH24:MI:SS')), p_exchange_rate_type))
        into v_TwoDayFloatRC
        from dual;

	-- get v_AvgLegerMTDAC from the nearest date
	if v_AvgLegerMTDAC is null then
           get_balance_near_date(v_bank_account_id, l_date, v_AvgLegerMTDAC, v_AvgLegerMTD_Date, 'AvgLegerMTD');
	end if;

	-- set the v_AvgLegerMTDRC
	select decode(v_exchange_rate, -1, v_dummy, v_AvgLegerMTDAC*CE_BANKACCT_BA_REPORT_UTIL.get_rate(v_currency_code,  p_reporting_currency, nvl(p_exchange_rate_date,to_char(sysdate, 'YYYY/MM/DD HH24:MI:SS')), p_exchange_rate_type))
        into v_AvgLegerMTDRC
        from dual;

	-- get v_AvgLegerYTDAC from the nearest date
	if v_AvgLegerYTDAC is null then
           get_balance_near_date(v_bank_account_id, l_date, v_AvgLegerYTDAC, v_AvgLegerYTD_Date, 'AvgLegerYTD');
	end if;

	-- set the v_AvgLegerYTDRC
	select decode(v_exchange_rate, -1, v_dummy, v_AvgLegerYTDAC*CE_BANKACCT_BA_REPORT_UTIL.get_rate(v_currency_code,  p_reporting_currency, nvl(p_exchange_rate_date, to_char(sysdate, 'YYYY/MM/DD HH24:MI:SS')), p_exchange_rate_type))
        into v_AvgLegerYTDRC
        from dual;

	-- get v_AvgAvailableMTDAC from the nearest date
	if v_AvgAvailableMTDAC is null then
           get_balance_near_date(v_bank_account_id, l_date, v_AvgAvailableMTDAC, v_AvgAvailableMTD_Date, 'AvgAvailableMTD');
	end if;

	-- set the v_AvgAvailableMTDRC
	select decode(v_exchange_rate, -1, v_dummy, v_AvgAvailableMTDAC*CE_BANKACCT_BA_REPORT_UTIL.get_rate(v_currency_code,  p_reporting_currency, nvl(p_exchange_rate_date, to_char(sysdate, 'YYYY/MM/DD HH24:MI:SS')),  p_exchange_rate_type))
        into v_AvgAvailableMTDRC
        from dual;

	-- get v_AvgAvailableYTDAC from the nearest date
	if v_AvgAvailableYTDAC is null then
           get_balance_near_date(v_bank_account_id, l_date, v_AvgAvailableYTDAC, v_AvgAvailableYTD_Date, 'AvgAvailableYTD');
	end if;

	-- set the v_AvgAvailableYTDRC
	select decode(v_exchange_rate, -1, v_dummy, v_AvgAvailableYTDAC*CE_BANKACCT_BA_REPORT_UTIL.get_rate(v_currency_code,  p_reporting_currency, nvl(p_exchange_rate_date,to_char(sysdate, 'YYYY/MM/DD HH24:MI:SS')), p_exchange_rate_type))
        into v_AvgAvailableYTDRC
        from dual;

	-- set the subtotal values

	-- ledgeBalance Sub Total
	if v_LegerBalanceSubTAC is null AND v_LegerBalanceAC is not null then
		v_LegerBalanceSubTAC := 0;
		if v_exchange_rate <> -1 then
			v_LegerBalanceSubTRC := 0;
		end if;
        end if;

	if v_LegerBalanceSubTAC is not null AND v_LegerBalanceAC is not null then
	  	v_LegerBalanceSubTAC := v_LegerBalanceSubTAC + v_LegerBalanceAC;
		if v_exchange_rate <> -1 then
			v_LegerBalanceSubTRC := v_LegerBalanceSubTRC + v_LegerBalanceRC;
		end if;
		if l_total_balance_flag = 1 then
			if v_LegerBalanceTotal is null then
				v_LegerBalanceTotal := 0;
			end if;
  	  		v_LegerBalanceTotal := v_LegerBalanceTotal + v_LegerBalanceRC;
		end if;
        end if;

	-- Available balance sub total
	if v_AvailableBalanceSubTAC is null AND v_AvailableBalanceAC is not null then
		v_AvailableBalanceSubTAC := 0;
		if v_exchange_rate <> -1 then
			v_AvailableBalanceSubTRC := 0;
		end if;
        end if;

	if v_AvailableBalanceSubTAC is not null AND v_AvailableBalanceAC is not null then
	  	v_AvailableBalanceSubTAC := v_AvailableBalanceSubTAC + v_AvailableBalanceAC;
		if v_exchange_rate <> -1 then
			v_AvailableBalanceSubTRC := v_AvailableBalanceSubTRC + v_AvailableBalanceRC;
		end if;
		if l_total_balance_flag = 1 then
			if v_AvailableBalanceTotal is null then
				v_AvailableBalanceTotal	:= 0;
			end if;
  	  		v_AvailableBalanceTotal := v_AvailableBalanceTotal + v_AvailableBalanceRC;
		end if;
        end if;

	-- Int calculated balance sub total
	if v_IntCalBalanceSubTAC is null AND v_IntCalBalanceAC is not null then
		v_IntCalBalanceSubTAC := 0;
		if v_exchange_rate <> -1 then
			 v_IntCalBalanceSubTRC:= 0;
		end if;
        end if;

	if v_IntCalBalanceSubTAC is not null AND v_IntCalBalanceAC is not null then
		v_IntCalBalanceSubTAC := v_IntCalBalanceSubTAC + v_IntCalBalanceAC;
		if v_exchange_rate <> -1 then
			v_IntCalBalanceSubTRC := v_IntCalBalanceSubTRC + v_IntCalBalanceRC;
		end if;
		if l_total_balance_flag = 1 then
			if v_IntCalBalanceTotal is null then
				v_IntCalBalanceTotal	:= 0;
			end if;
  	  		v_IntCalBalanceTotal := v_IntCalBalanceTotal + v_IntCalBalanceRC;
		end if;
        end if;

	-- One Day Folat sub total
	if v_OneDayFloatSubTAC is null AND v_OneDayFloatAC is not null then
		v_OneDayFloatSubTAC := 0;
		if v_exchange_rate <> -1 then
			 v_OneDayFloatSubTRC := 0;
		end if;
        end if;

	if v_OneDayFloatSubTAC is not null AND v_OneDayFloatAC is not null then
		v_OneDayFloatSubTAC := v_OneDayFloatSubTAC + v_OneDayFloatAC;
		if v_exchange_rate <> -1 then
			v_OneDayFloatSubTRC := v_OneDayFloatSubTRC + v_OneDayFloatRC;
		end if;
		if l_total_balance_flag = 1 then
			if v_OneDayFloatTotal is null then
				v_OneDayFloatTotal	:= 0;
			end if;
  	  		v_OneDayFloatTotal := v_OneDayFloatTotal + v_OneDayFloatRC;
		end if;
        end if;

	-- Two Day Folat sub total
	if v_TwoDayFloatSubTAC is null AND v_TwoDayFloatAC is not null then
		v_TwoDayFloatSubTAC := 0;
		if v_exchange_rate <> -1 then
			 v_TwoDayFloatSubTRC := 0;
		end if;
        end if;

	if v_TwoDayFloatSubTAC is not null AND v_TwoDayFloatAC is not null then
		v_TwoDayFloatSubTAC := v_TwoDayFloatSubTAC + v_TwoDayFloatAC;
		if v_exchange_rate <> -1 then
			v_TwoDayFloatSubTRC := v_TwoDayFloatSubTRC + v_TwoDayFloatRC;
		end if;
		if l_total_balance_flag = 1 then
			if v_TwoDayFloatTotal is null then
				v_TwoDayFloatTotal	:= 0;
			end if;
  	  		v_TwoDayFloatTotal := v_TwoDayFloatTotal + v_TwoDayFloatRC;
		end if;
        end if;

	-- Avg Leger MTD Sub Total
	if v_AvgLegerMTDSubTAC is null AND v_AvgLegerMTDAC is not null then
		v_AvgLegerMTDSubTAC := 0;
		if v_exchange_rate <> -1 then
			 v_AvgLegerMTDSubTRC := 0;
		end if;
        end if;

	if v_AvgLegerMTDSubTAC is not null AND v_AvgLegerMTDAC is not null then
		v_AvgLegerMTDSubTAC := v_AvgLegerMTDSubTAC + v_AvgLegerMTDAC;
		if v_exchange_rate <> -1 then
			v_AvgLegerMTDSubTRC := v_AvgLegerMTDSubTRC + v_AvgLegerMTDRC;
		end if;
		if l_total_balance_flag = 1 then
			if v_AvgLegerMTDTotal is null then
				v_AvgLegerMTDTotal := 0;
			end if;
  	  		v_AvgLegerMTDTotal := v_AvgLegerMTDTotal + v_AvgLegerMTDRC;
		end if;
        end if;

	-- Avg Leger YTD Sub Total
	if v_AvgLegerYTDSubTAC is null AND v_AvgLegerYTDAC is not null then
		v_AvgLegerYTDSubTAC := 0;
		if v_exchange_rate <> -1 then
			 v_AvgLegerYTDSubTRC := 0;
		end if;
        end if;

	if v_AvgLegerYTDSubTAC is not null AND v_AvgLegerYTDAC is not null then
		v_AvgLegerYTDSubTAC := v_AvgLegerYTDSubTAC + v_AvgLegerYTDAC;
		if v_exchange_rate <> -1 then
			v_AvgLegerYTDSubTRC := v_AvgLegerYTDSubTRC + v_AvgLegerYTDRC;
		end if;
		if l_total_balance_flag = 1 then
			if v_AvgLegerYTDTotal is null then
				v_AvgLegerYTDTotal := 0;
			end if;
  	  		v_AvgLegerYTDTotal := v_AvgLegerYTDTotal + v_AvgLegerYTDRC;
		end if;
        end if;

	-- Avg Available MTD Sub T
	if v_AvgAvailableMTDSubTAC is null AND v_AvgAvailableMTDAC is not null then
		v_AvgAvailableMTDSubTAC:= 0;
		if v_exchange_rate <> -1 then
			 v_AvgAvailableMTDSubTRC := 0;
		end if;
        end if;

	if v_AvgAvailableMTDSubTAC is not null AND v_AvgAvailableMTDAC is not null then
		v_AvgAvailableMTDSubTAC := v_AvgAvailableMTDSubTAC + v_AvgAvailableMTDAC;
		if v_exchange_rate <> -1 then
			v_AvgAvailableMTDSubTRC := v_AvgAvailableMTDSubTRC + v_AvgAvailableMTDRC;
		end if;
		if l_total_balance_flag = 1 then
			if v_AvgAvailableMTDTotal is null then
				v_AvgAvailableMTDTotal := 0;
			end if;
  	  		v_AvgAvailableMTDTotal := v_AvgAvailableMTDTotal + v_AvgAvailableMTDRC;
		end if;
        end if;

	-- Avg Available YTD Sub T
	if v_AvgAvailableYTDSubTAC is null AND v_AvgAvailableYTDAC is not null then
		v_AvgAvailableYTDSubTAC:= 0;
		if v_exchange_rate <> -1 then
			 v_AvgAvailableYTDSubTRC := 0;
		end if;
        end if;

	if v_AvgAvailableYTDSubTAC is not null AND v_AvgAvailableYTDAC is not null then
		v_AvgAvailableYTDSubTAC := v_AvgAvailableYTDSubTAC + v_AvgAvailableYTDAC;
		if v_exchange_rate <> -1 then
			v_AvgAvailableYTDSubTRC := v_AvgAvailableYTDSubTRC + v_AvgAvailableYTDRC;
		end if;
		if l_total_balance_flag = 1 then
			if v_AvgAvailableYTDTotal is null then
				v_AvgAvailableYTDTotal := 0;
			end if;
  	  		v_AvgAvailableYTDTotal := v_AvgAvailableYTDTotal + v_AvgAvailableYTDRC;
		end if;
        end if;
-- Bug 8620223
        select xmlelement("BankAccount",
          xmlforest(ba.BANK_ACCOUNT_ID   as    "BankAccountID",
                ba.BANK_ACCOUNT_NAME as    "BankAccountName",
                ba.BANK_ACCOUNT_NUM  as    "BankAccountNum",
                ba.ACCOUNT_OWNER_ORG_ID as "LegalEntity",
                bh.BANK_NAME         as    "BankName",
                bh.BANK_BRANCH_NAME  as    "BankBranchName",
                ba.CURRENCY_CODE     as    "BankAccountCurrency",
		p_reporting_currency as    "ReportingCurrency",
                ba.MIN_TARGET_BALANCE as   "TargetBalanceMinimum",
                ba.MAX_TARGET_BALANCE as   "TargetBalanceMaximum",
                l_date       as   "BalanceDate"),
         xmlelement("LedgerBalanceAC", xmlattributes(v_LegerBalance_Date as "BalanceDate",
                    decode(v_LegerBalance_Date - l_date, 0, '', '*') as "Flag"), CE_BANKACCT_BA_REPORT_UTIL.get_balance(v_LegerBalanceAC, ba.CURRENCY_CODE)),
          xmlelement("LedgerBalanceRC", CE_BANKACCT_BA_REPORT_UTIL.get_balance(v_LegerBalanceRC, p_reporting_currency)),
	  xmlelement("AvailableBalanceAC", xmlattributes(v_AvailableBalance_Date as "BalanceDate", decode(v_AvailableBalance_Date - l_date, 0, '', '*') as "Flag"), CE_BANKACCT_BA_REPORT_UTIL.get_balance(v_AvailableBalanceAC, ba.CURRENCY_CODE)),
          xmlelement("AvailableBalanceRC", CE_BANKACCT_BA_REPORT_UTIL.get_balance(v_AvailableBalanceRC, p_reporting_currency)),
	  xmlelement("IntCalBalanceAC", xmlattributes(v_IntCalBalance_Date as "BalanceDate", decode(v_IntCalBalance_Date - l_date, 0, '', '*') as "Flag"), CE_BANKACCT_BA_REPORT_UTIL.get_balance(v_IntCalBalanceAC, ba.CURRENCY_CODE)),
          xmlelement("IntCalBalanceRC", CE_BANKACCT_BA_REPORT_UTIL.get_balance(v_IntCalBalanceRC, p_reporting_currency)),
	  xmlelement("OneDayFloatAC", xmlattributes(v_OneDayFloat_Date as "BalanceDate", decode(v_OneDayFloat_Date - l_date, 0, '', '*') as "Flag"), CE_BANKACCT_BA_REPORT_UTIL.get_balance(v_OneDayFloatAC, ba.CURRENCY_CODE)),
          xmlelement("OneDayFloatRC", CE_BANKACCT_BA_REPORT_UTIL.get_balance(v_OneDayFloatRC, p_reporting_currency)),
	  xmlelement("TwoDayFloatAC", xmlattributes(v_TwoDayFloat_Date as "BalanceDate", decode(v_TwoDayFloat_Date - l_date, 0, '', '*') as "Flag"), CE_BANKACCT_BA_REPORT_UTIL.get_balance(v_TwoDayFloatAC, ba.CURRENCY_CODE)),
          xmlelement("TwoDayFloatRC", CE_BANKACCT_BA_REPORT_UTIL.get_balance(v_TwoDayFloatRC, p_reporting_currency)),
	  xmlelement("AvgLegerMTDAC", xmlattributes(v_AvgLegerMTD_Date as "BalanceDate", decode(v_AvgLegerMTD_Date - l_date, 0, '', '*') as "Flag"), CE_BANKACCT_BA_REPORT_UTIL.get_balance(v_AvgLegerMTDAC, ba.CURRENCY_CODE)),
          xmlelement("AvgLegerMTDRC", CE_BANKACCT_BA_REPORT_UTIL.get_balance(v_AvgLegerMTDRC, p_reporting_currency)),
	  xmlelement("AvgLegerYTDAC", xmlattributes(v_AvgLegerYTD_Date as "BalanceDate", decode(v_AvgLegerYTD_Date - l_date, 0, '', '*') as "Flag"), CE_BANKACCT_BA_REPORT_UTIL.get_balance(v_AvgLegerYTDAC, ba.CURRENCY_CODE)),
          xmlelement("AvgLegerYTDRC", CE_BANKACCT_BA_REPORT_UTIL.get_balance(v_AvgLegerYTDRC, p_reporting_currency)),
	  xmlelement("AvgAvailableMTDAC", xmlattributes(v_AvgAvailableMTD_Date as "BalanceDate", decode(v_AvgAvailableMTD_Date - l_date, 0, '', '*') as "Flag"), CE_BANKACCT_BA_REPORT_UTIL.get_balance(v_AvgAvailableMTDAC, ba.CURRENCY_CODE)),
          xmlelement("AvgAvailableMTDRC", CE_BANKACCT_BA_REPORT_UTIL.get_balance(v_AvgAvailableMTDRC, p_reporting_currency)),
	  xmlelement("AvgAvailableYTDAC", xmlattributes(v_AvgAvailableYTD_Date as "BalanceDate", decode(v_AvgAvailableYTD_Date - l_date, 0, '', '*') as "Flag"), CE_BANKACCT_BA_REPORT_UTIL.get_balance(v_AvgAvailableYTDAC, ba.CURRENCY_CODE)),
          xmlelement("AvgAvailableYTDRC", CE_BANKACCT_BA_REPORT_UTIL.get_balance(v_AvgAvailableYTDRC, p_reporting_currency))
	)
     	into v_xml_seg1
     	from ce_bank_accounts ba, ce_bank_branches_v bh -- , ce_bank_acct_balances bb
      	  where ba.BANK_BRANCH_ID = bh.BRANCH_PARTY_ID
      --and ba.BANK_ACCOUNT_ID = bb.BANK_ACCOUNT_ID
     -- and bb.BALANCE_DATE = l_date
     and ba.BANK_ACCOUNT_ID = v_bank_account_id;


    -- concat all xml nodes
    select xmlconcat(v_xml_seg1, v_xml_seg2)
      into v_xml_seg3
    from dual;

    v_xml_seg2 := v_xml_seg3;
  end loop;
  close cursor_bank_account_id;
if counterflag >0 then
  select
      xmlelement("BankAcctGroupByCurrency", xmlattributes(v_currency_code as "AccountCurrency", v_exchange_rate as "ExchangeRate"),
      v_xml_seg2,
      xmlforest(CE_BANKACCT_BA_REPORT_UTIL.get_balance(v_LegerBalanceSubTAC, v_currency_code) as "SubTotalLedgerBalanceAC",
         	CE_BANKACCT_BA_REPORT_UTIL.get_balance(v_AvailableBalanceSubTAC, v_currency_code) as "SubTotalAvailableBalanceAC",
  		CE_BANKACCT_BA_REPORT_UTIL.get_balance(v_IntCalBalanceSubTAC, v_currency_code) as "SubTotalIntCalBalanceAC",
  		CE_BANKACCT_BA_REPORT_UTIL.get_balance(v_OneDayFloatSubTAC, v_currency_code) as "SubTotalOneDayFloatAC",
  		CE_BANKACCT_BA_REPORT_UTIL.get_balance(v_TwoDayFloatSubTAC, v_currency_code) as "SubtotalTwoDayFloatAC",
  		CE_BANKACCT_BA_REPORT_UTIL.get_balance(v_AvgLegerMTDSubTAC, v_currency_code) as "SubTotalAvgLegerMTDAC",
  		CE_BANKACCT_BA_REPORT_UTIL.get_balance(v_AvgLegerYTDSubTAC, v_currency_code) as "SubTotalAvgLegerYTDAC",
  		CE_BANKACCT_BA_REPORT_UTIL.get_balance(v_AvgAvailableMTDSubTAC, v_currency_code) as "SubTotalAvgAvailableMTDAC",
  		CE_BANKACCT_BA_REPORT_UTIL.get_balance(v_AvgAvailableYTDSubTAC, v_currency_code) as "SubTotalAvgAvailableYTDAC",
	 	CE_BANKACCT_BA_REPORT_UTIL.get_balance(v_LegerBalanceSubTRC, p_reporting_currency) as "SubTotalLedgerBalanceRC",
         	CE_BANKACCT_BA_REPORT_UTIL.get_balance(v_AvailableBalanceSubTRC, p_reporting_currency) as "SubTotalAvailableBalanceRC",
  		CE_BANKACCT_BA_REPORT_UTIL.get_balance(v_IntCalBalanceSubTRC, p_reporting_currency) as "SubTotalIntCalBalanceRC",
  		CE_BANKACCT_BA_REPORT_UTIL.get_balance(v_OneDayFloatSubTRC, p_reporting_currency) as "SubTotalOneDayFloatRC",
  		CE_BANKACCT_BA_REPORT_UTIL.get_balance(v_TwoDayFloatSubTRC, p_reporting_currency) as "SubtotalTwoDayFloatRC",
  		CE_BANKACCT_BA_REPORT_UTIL.get_balance(v_AvgLegerMTDSubTRC, p_reporting_currency) as "SubTotalAvgLegerMTDRC",
  		CE_BANKACCT_BA_REPORT_UTIL.get_balance(v_AvgLegerYTDSubTRC, p_reporting_currency) as "SubTotalAvgLegerYTDRC",
  		CE_BANKACCT_BA_REPORT_UTIL.get_balance(v_AvgAvailableMTDSubTRC, p_reporting_currency) as "SubTotalAvgAvailableMTDRC",
  		CE_BANKACCT_BA_REPORT_UTIL.get_balance(v_AvgAvailableYTDSubTRC, p_reporting_currency) as "SubTotalAvgAvailableYTDRC"
		)
       )
   into v_xml_1
   from dual;

    -- concat all xml nodes
    select xmlconcat(v_xml_1, v_xml_2)
      into v_xml_3
    from dual;

    v_xml_2 := v_xml_3;
   end if;
  end loop;
  close cursor_bank_currency_code;

-- generate the xml as a whole
select
  xmlelement("BankAccountList",
    xmlelement("BankBranchName", l_Bank_Branch_Name),
    xmlelement("BankAcctNum", l_Bank_ACCT_NAME),
    xmlelement("BankAC", p_bank_acct_currency),
    xmlelement("LegalEntity", l_legal_entity_name),
    xmlelement("ReportingCurrency", p_reporting_currency),
    xmlelement("ReportDate", sysdate),
    xmlelement("AsOfDate",   to_char(l_date)),
    xmlelement("ExchangeRateType", p_exchange_rate_type),
    xmlelement("ExchangeRateDate",  l_exchange_rate_date),
    xmlelement("TotalBalanceSummationFlag", l_total_balance_flag),
    v_xml_2,                     -- xml node 'BankAccttGroupByCurrency'
    xmlelement("LegerBalanceTotal", CE_BANKACCT_BA_REPORT_UTIL.get_balance(v_LegerBalanceTotal, p_reporting_currency)),
    xmlelement("AvailableBalanceTotal", CE_BANKACCT_BA_REPORT_UTIL.get_balance(v_AvailableBalanceTotal, p_reporting_currency)),
    xmlelement("IntCalBalanceTotal", CE_BANKACCT_BA_REPORT_UTIL.get_balance(v_IntCalBalanceTotal, p_reporting_currency)),
    xmlelement("OneDayFloatTotal", CE_BANKACCT_BA_REPORT_UTIL.get_balance(v_OneDayFloatTotal, p_reporting_currency)),
    xmlelement("TwoDayFloatTotal", CE_BANKACCT_BA_REPORT_UTIL.get_balance(v_TwoDayFloatTotal, p_reporting_currency)),
    xmlelement("AvgLegerMTDTotal", CE_BANKACCT_BA_REPORT_UTIL.get_balance(v_AvgLegerMTDTotal, p_reporting_currency)),
    xmlelement("AvgLegerYTDTotal", CE_BANKACCT_BA_REPORT_UTIL.get_balance(v_AvgLegerYTDTotal, p_reporting_currency)),
    xmlelement("AvgAvailableMTDTotal", CE_BANKACCT_BA_REPORT_UTIL.get_balance(v_AvgAvailableMTDTotal, p_reporting_currency)),
    xmlelement("AvgAvailableYTDTotal", CE_BANKACCT_BA_REPORT_UTIL.get_balance(v_AvgAvailableYTDTotal, p_reporting_currency))
)
into l_xml
from dual;

  l_xml_doc := l_xml.getClobVal();

  CE_BANKACCT_BA_REPORT_UTIL.printClobOut(l_xml_doc);

/*
  l_length := nvl(DBMS_LOB.getlength(l_xml_doc), 0);
  l_offset := 1;
  l_amount := 32767;

  loop
    exit when l_length <= 0;
    dbms_lob.read(l_xml_doc, l_amount, l_offset, l_buffer);
    fnd_file.put(FND_FILE.OUTPUT, l_buffer);
    l_length := l_length-l_amount;
    l_offset := l_offset + l_amount;
  end loop;
*/
/*
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            dbms_output.put_line('End of data');
*/
--    dbms_output.put_line(to_char(l_amount));

exception
   WHEN OTHERS THEN
   xrate := -1;

fnd_file.put_line(fnd_file.log, xrate);

end single_day_balance_report;



procedure range_day_balance_report
  (errbuf OUT NOCOPY      VARCHAR2,
   retcode OUT NOCOPY     NUMBER,
   p_branch_party_id      varchar2,
   p_bank_acct_id         varchar2,
   p_bank_acct_currency   VARCHAR2,
   p_legal_entity_id      varchar2,
   p_from_date            varchar2,
   p_to_date              varchar2,
   p_reporting_currency   varchar2,
   p_exchange_rate_type   varchar2,
   p_exchange_rate_date   varchar2
  )
is
  l_length number;
  l_offset number;
  l_amount number;
  l_buffer varchar2(32767);
  l_xml_doc clob;
  l_xml xmltype;
  l_exchange_rate number;
  xrate number;
  l_Bank_Branch_Name varchar2(100);
  l_Bank_ACCT_NAME varchar2(100);
  l_exchange_rate_date  varchar2(200);
  l_legal_entity_name varchar2(200);
  l_Bank_Name varchar2(100);
  l_from_date varchar2(100);
  l_to_date   varchar2(100);
  e_date_exp EXCEPTION;

begin
--fnd_file.put_line(FND_FILE.LOG, 'hello world');
--fnd_file.put_line(FND_FILE.LOG, p_as_of_date);
--fnd_file.put_line(fnd_file.log, to_char(to_date(p_as_of_date, 'YYYY/MM/DD HH24:MI:SS')));
--fnd_file.put_line(fnd_file.log, p_branch_name);

-- populate ce_security_profiles_gt table with ce_security_procfiles_v
-- CEP_STANDARD.init_security;

if p_branch_party_id is not null then
   select BANK_BRANCH_NAME, BANK_NAME
   into l_Bank_Branch_Name, l_Bank_Name
   from ce_bank_branches_v
   where BRANCH_PARTY_ID = p_branch_party_id;
end if;

if p_bank_acct_id is not null then
   select BANK_ACCOUNT_NAME
   into l_Bank_ACCT_NAME
   from ce_bank_accounts
   where BANK_ACCOUNT_ID = p_bank_acct_id;
end if;

if p_reporting_currency is null then
  l_exchange_rate_date := null;
else
  l_exchange_rate_date := to_char(to_date(nvl(p_exchange_rate_date, to_char(sysdate, 'YYYY/MM/DD HH24:MI:SS')), 'YYYY/MM/DD HH24:MI:SS'));
end if;

if p_legal_entity_id is not null then
  select name
  into l_legal_entity_name
  from CE_LE_BG_OU_VS_V
  where legal_entity_id = p_legal_entity_id and organization_type = 'LEGAL_ENTITY';
end if;

if (p_from_date is not null) and p_to_date is not null and p_from_date > p_to_date then
  RAISE e_date_exp;
end if;


select
  xmlelement("BankAccountList",
    xmlelement("BankName", l_Bank_Name),
    xmlelement("BankBranchName", l_Bank_Branch_Name),
    xmlelement("BankAcctName", l_Bank_ACCT_NAME),
    xmlelement("BankAC", p_bank_acct_currency),
    xmlelement("LegalEntity", l_legal_entity_name),
    xmlelement("ReportingCurrency", p_reporting_currency),
    xmlelement("ReportDate", sysdate),
    xmlelement("FromDate",   to_char(to_date(p_from_date, 'YYYY/MM/DD HH24:MI:SS'))),
    xmlelement("ToDate",   to_char(to_date(p_to_date, 'YYYY/MM/DD HH24:MI:SS'))),
    xmlelement("ExchangeRateType", p_exchange_rate_type),
    xmlelement("ExchangeRateDate",  l_exchange_rate_date),
    xmlagg(xmlelement("BankAccount",
      xmlforest(ba.BANK_ACCOUNT_ID   as    "BankAccountID",
                ba.BANK_ACCOUNT_NAME as    "BankAccountName",
                ba.BANK_ACCOUNT_NUM  as    "BankAccountNum",
                ba.ACCOUNT_OWNER_ORG_ID as "LegalEntity",
                bh.BANK_NAME         as    "BankName",
                bh.BANK_BRANCH_NAME  as    "BankBranchName",
                ba.CURRENCY_CODE     as    "BankAccountCurrency",
		p_reporting_currency as    "ReportingCurrency",
                CE_BANKACCT_BA_REPORT_UTIL.get_rate(ba.CURRENCY_CODE,  p_reporting_currency, p_exchange_rate_date,p_exchange_rate_type)        as    "ExchangeRate",
                to_char(ba.MIN_TARGET_BALANCE, FND_CURRENCY.GET_FORMAT_MASK(ba.CURRENCY_CODE, 30)) as   "TargetBalanceMinimum",
                to_char(ba.MAX_TARGET_BALANCE, FND_CURRENCY.GET_FORMAT_MASK(ba.CURRENCY_CODE, 30)) as   "TargetBalanceMaximum",
                bb.BALANCE_DATE       as   "BalanceDate",
                CE_BANKACCT_BA_REPORT_UTIL.get_balance(bb.LEDGER_BALANCE, ba.CURRENCY_CODE)     as   "LedgerBalanceAC",
                CE_BANKACCT_BA_REPORT_UTIL.get_reporting_balance(bb.LEDGER_BALANCE, ba.CURRENCY_CODE,  p_reporting_currency, p_exchange_rate_date,p_exchange_rate_type) as "LedgerBalanceRC",
                CE_BANKACCT_BA_REPORT_UTIL.get_balance(bb.AVAILABLE_BALANCE, ba.CURRENCY_CODE)  as   "AvailableBalanceAC",
		CE_BANKACCT_BA_REPORT_UTIL.get_reporting_balance(bb.AVAILABLE_BALANCE, ba.CURRENCY_CODE,  p_reporting_currency, p_exchange_rate_date,p_exchange_rate_type) as "AvailableBalanceRC",
                CE_BANKACCT_BA_REPORT_UTIL.get_balance(bb.VALUE_DATED_BALANCE, ba.CURRENCY_CODE)           as "InterestCalBalAC",
		CE_BANKACCT_BA_REPORT_UTIL.get_reporting_balance(bb.VALUE_DATED_BALANCE, ba.CURRENCY_CODE,  p_reporting_currency, p_exchange_rate_date,p_exchange_rate_type) as "InterestCalBalRC",
                CE_BANKACCT_BA_REPORT_UTIL.get_balance(bb.ONE_DAY_FLOAT, ba.CURRENCY_CODE)                         as   "OneDayFloatAC",
		CE_BANKACCT_BA_REPORT_UTIL.get_reporting_balance(bb.ONE_DAY_FLOAT, ba.CURRENCY_CODE,  p_reporting_currency, p_exchange_rate_date,p_exchange_rate_type) as "OneDayFloatRC",
                CE_BANKACCT_BA_REPORT_UTIL.get_balance(bb.TWO_DAY_FLOAT, ba.CURRENCY_CODE)                         as   "TwoDayFloatAC",
		CE_BANKACCT_BA_REPORT_UTIL.get_reporting_balance(bb.TWO_DAY_FLOAT, ba.CURRENCY_CODE,  p_reporting_currency, p_exchange_rate_date,p_exchange_rate_type) as "TwoDayFloatRC",
                CE_BANKACCT_BA_REPORT_UTIL.get_balance(bb.AVERAGE_CLOSE_LEDGER_MTD, ba.CURRENCY_CODE)              as "AvgCloseLedgerMTDAC",
		CE_BANKACCT_BA_REPORT_UTIL.get_reporting_balance(bb.AVERAGE_CLOSE_LEDGER_MTD, ba.CURRENCY_CODE,  p_reporting_currency, p_exchange_rate_date,p_exchange_rate_type) as "AvgCloseLedgerMTDRC",
                CE_BANKACCT_BA_REPORT_UTIL.get_balance(bb.AVERAGE_CLOSE_LEDGER_YTD, ba.CURRENCY_CODE)              as "AvgCloseLedgerYTDAC",
		CE_BANKACCT_BA_REPORT_UTIL.get_reporting_balance(bb.AVERAGE_CLOSE_LEDGER_YTD, ba.CURRENCY_CODE,  p_reporting_currency, p_exchange_rate_date,p_exchange_rate_type) as "AvgCloseLedgerYTDRC",
                CE_BANKACCT_BA_REPORT_UTIL.get_balance(bb.AVERAGE_CLOSE_AVAILABLE_MTD, ba.CURRENCY_CODE)           as "AvgCloseAvailableMTDAC",
		CE_BANKACCT_BA_REPORT_UTIL.get_reporting_balance(bb.AVERAGE_CLOSE_AVAILABLE_MTD, ba.CURRENCY_CODE,  p_reporting_currency, p_exchange_rate_date,p_exchange_rate_type) as "AvgCloseAvailableMTDRC",
                CE_BANKACCT_BA_REPORT_UTIL.get_balance(bb.AVERAGE_CLOSE_AVAILABLE_YTD, ba.CURRENCY_CODE)           as "AvgCloseAvailableYTDAC",
		CE_BANKACCT_BA_REPORT_UTIL.get_reporting_balance(bb.AVERAGE_CLOSE_AVAILABLE_YTD, ba.CURRENCY_CODE,  p_reporting_currency, p_exchange_rate_date,p_exchange_rate_type) as "AvgCloseAvailableYTDRC"
))ORDER BY bb.BALANCE_DATE)) -- Bug 6632931
into l_xml
from ce_bank_accounts ba, ce_bank_branches_v bh, ce_bank_acct_balances bb
where ba.BANK_BRANCH_ID = bh.BRANCH_PARTY_ID
      and ba.BANK_ACCOUNT_ID = bb.BANK_ACCOUNT_ID
      and bb.BALANCE_DATE between nvl(to_date(p_from_date, 'YYYY/MM/DD HH24:MI:SS'),bb.BALANCE_DATE) and nvl(to_date(p_to_date, 'YYYY/MM/DD HH24:MI:SS'),bb.BALANCE_DATE)
      and bh.BRANCH_PARTY_ID = nvl(p_branch_party_id, bh.BRANCH_PARTY_ID)
      and ba.BANK_ACCOUNT_ID = nvl(p_bank_acct_id, ba.BANK_ACCOUNT_ID)
      and ba.CURRENCY_CODE = nvl(p_bank_acct_currency, ba.CURRENCY_CODE)
      and ba.ACCOUNT_OWNER_ORG_ID = nvl(p_legal_entity_id, ba.ACCOUNT_OWNER_ORG_ID)
      and (bb.LEDGER_BALANCE is not null
           or bb.AVAILABLE_BALANCE is not null
           or bb.VALUE_DATED_BALANCE is not null
           or bb.ONE_DAY_FLOAT is not null
           or bb.TWO_DAY_FLOAT is not null
           or bb.AVERAGE_CLOSE_LEDGER_MTD is not null
           or bb.AVERAGE_CLOSE_LEDGER_YTD is not null
           or bb.AVERAGE_CLOSE_AVAILABLE_MTD is not null
           or bb.AVERAGE_CLOSE_AVAILABLE_YTD is not null);


--select c.accountBalance
--into l_xml
--from ce_balance_reporting_xml_v c;

fnd_file.put_line(fnd_file.log, 'xml query end');

  l_xml_doc := l_xml.getClobVal();
  CE_BANKACCT_BA_REPORT_UTIL.printClobOut(l_xml_doc);

/*
  l_length := nvl(DBMS_LOB.getlength(l_xml_doc), 0);
  l_offset := 1;
  l_amount := 32767;

fnd_file.put_line(fnd_file.log, concat('clob length is ', l_length));

  loop
    exit when l_length <= 0;
    dbms_lob.read(l_xml_doc, l_amount, l_offset, l_buffer);
--    fnd_file.put_line(fnd_file.log, 'buffer read');
    fnd_file.put(FND_FILE.OUTPUT, l_buffer);
--    fnd_file.put_line(fnd_file.log, 'buffer write');
    l_length := l_length-l_amount;
    l_offset := l_offset + l_amount;
  end loop;
*/
/*
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            dbms_output.put_line('End of data');

--    dbms_output.put_line(to_char(l_amount));
*/

exception

   WHEN e_date_exp then
     fnd_file.put_line(fnd_file.log, 'ERROR:from date can not be later than to date');

   WHEN OTHERS THEN
   xrate := -1;

fnd_file.put_line(fnd_file.log, xrate);
fnd_file.put_line(fnd_file.log, SQLCODE);
fnd_file.put_line(fnd_file.log, SQLERRM);
end;


procedure act_proj_balance_report
  (errbuf OUT NOCOPY      VARCHAR2,
   retcode OUT NOCOPY     NUMBER,
   p_branch_party_id      varchar2,
   p_bank_acct_id         varchar2,
   p_bank_acct_currency   VARCHAR2,
   p_legal_entity_id      varchar2,
   p_from_date            varchar2,
   p_to_date              varchar2,
   p_actual_balance_type  varchar2
  )
is
  l_length number;
  l_offset number;
  l_amount number;
  l_buffer varchar2(32767);
  l_xml_doc clob;
  l_xml xmltype;
  l_exchange_rate number;
  xrate number;
  l_Bank_Branch_Name varchar2(100);
  l_Bank_ACCT_NAME varchar2(100);
  l_exchange_rate_date  varchar2(200);
  l_legal_entity_name varchar2(200);
  l_Bank_Name varchar2(100);
  l_balance_type_meaning varchar2(200);
  e_date_exp EXCEPTION;
begin
--fnd_file.put_line(FND_FILE.LOG, 'hello world');
--fnd_file.put_line(FND_FILE.LOG, p_as_of_date);
--fnd_file.put_line(fnd_file.log, to_char(to_date(p_as_of_date, 'YYYY/MM/DD HH24:MI:SS')));
--fnd_file.put_line(fnd_file.log, p_branch_name);

 -- populate ce_security_profiles_gt table with ce_security_procfiles_v
-- CEP_STANDARD.init_security;

if p_branch_party_id is not null then
   select BANK_BRANCH_NAME, BANK_NAME
   into l_Bank_Branch_Name, l_Bank_Name
   from ce_bank_branches_v
   where BRANCH_PARTY_ID = p_branch_party_id;
end if;

if p_bank_acct_id is not null then
   select BANK_ACCOUNT_NAME
   into l_Bank_ACCT_NAME
   from ce_bank_accounts
   where BANK_ACCOUNT_ID = p_bank_acct_id;
end if;

if p_legal_entity_id is not null then
  select name
  into l_legal_entity_name
  from CE_LE_BG_OU_VS_V
  where legal_entity_id = p_legal_entity_id and organization_type = 'LEGAL_ENTITY';
end if;

if (p_from_date is not null) and p_to_date is not null and p_from_date > p_to_date then
  RAISE e_date_exp;
end if;

select meaning
into l_balance_type_meaning
from ce_lookups
where lookup_code = p_actual_balance_type
  and lookup_type = 'BANK_ACC_BAL_TYPE';

select
  xmlelement("BankAccountList",
    xmlelement("BankName", l_Bank_Name),
    xmlelement("BankBranchName", l_Bank_Branch_Name),
    xmlelement("BankAcctName", l_Bank_ACCT_NAME),
    xmlelement("BankAC", p_bank_acct_currency),
    xmlelement("LegalEntity", l_legal_entity_name),
    xmlelement("ReportDate", sysdate),
    xmlelement("FromDate",   to_char(to_date(p_from_date, 'YYYY/MM/DD HH24:MI:SS'))),
    xmlelement("ToDate",   to_char(to_date(p_to_date, 'YYYY/MM/DD HH24:MI:SS'))),
    xmlelement("ActualBalanceType", l_balance_type_meaning),
    xmlagg(xmlelement("BankAccount",
      xmlforest(a.BANK_ACCOUNT_ID   as    "BankAccountID",
                a.BANK_ACCOUNT_NAME as    "BankAccountName",
                a.BANK_ACCOUNT_NUM  as    "BankAccountNum",
                a.ACCOUNT_OWNER_ORG_ID as "LegalEntity",
                a.BANK_NAME         as    "BankName",
                a.BANK_BRANCH_NAME  as    "BankBranchName",
                a.CURRENCY_CODE     as    "BankAccountCurrency",
                CE_BANKACCT_BA_REPORT_UTIL.get_balance(a.MIN_TARGET_BALANCE, a.CURRENCY_CODE) as   "TargetBalanceMinimum",
                CE_BANKACCT_BA_REPORT_UTIL.get_balance(a.MAX_TARGET_BALANCE, a.CURRENCY_CODE) as   "TargetBalanceMaximum",
                a.BALANCE_DATE      as   "BalanceDate",
                CE_BANKACCT_BA_REPORT_UTIL.get_balance(a.LEDGER_BALANCE, a.CURRENCY_CODE)     as   "LedgerBalanceAC",
                CE_BANKACCT_BA_REPORT_UTIL.get_balance(a.AVAILABLE_BALANCE, a.CURRENCY_CODE)  as   "AvailableBalanceAC",
                CE_BANKACCT_BA_REPORT_UTIL.get_balance(a.VALUE_DATED_BALANCE, a.CURRENCY_CODE) as "InterestCalBalAC",
                CE_BANKACCT_BA_REPORT_UTIL.get_balance(a.ONE_DAY_FLOAT, a.CURRENCY_CODE)      as   "OneDayFloatAC",
                CE_BANKACCT_BA_REPORT_UTIL.get_balance(a.TWO_DAY_FLOAT, a.CURRENCY_CODE)      as   "TwoDayFloatAC",
                CE_BANKACCT_BA_REPORT_UTIL.get_balance(a.AVERAGE_CLOSE_LEDGER_MTD, a.CURRENCY_CODE) as "AvgCloseLedgerMTDAC",
                CE_BANKACCT_BA_REPORT_UTIL.get_balance(a.AVERAGE_CLOSE_LEDGER_YTD, a.CURRENCY_CODE) as "AvgCloseLedgerYTDAC",
                CE_BANKACCT_BA_REPORT_UTIL.get_balance(a.AVERAGE_CLOSE_AVAILABLE_MTD, a.CURRENCY_CODE) as "AvgCloseAvailableMTDAC",
                CE_BANKACCT_BA_REPORT_UTIL.get_balance(a.AVERAGE_CLOSE_AVAILABLE_YTD, a.CURRENCY_CODE) as "AvgCloseAvailableYTDAC",
                CE_BANKACCT_BA_REPORT_UTIL.get_balance(CE_BANKACCT_BA_REPORT_UTIL.get_variance(a.BANK_ACCOUNT_ID, a.BALANCE_DATE, p_actual_balance_type),a.CURRENCY_CODE) as "Variance",
                l_balance_type_meaning as "ActualBalanceType",
                CE_BANKACCT_BA_REPORT_UTIL.get_balance(a.PROJECTED_BALANCE, a.CURRENCY_CODE) as "ProjectedBalance"
))))
into l_xml   -- 5501252
from
(
select
ba.BANK_ACCOUNT_ID,
ba.BANK_ACCOUNT_NAME,
ba.BANK_ACCOUNT_NUM,
ba.ACCOUNT_OWNER_ORG_ID,
bh.BANK_NAME,
bh.BANK_BRANCH_NAME,
ba.CURRENCY_CODE,
ba.MIN_TARGET_BALANCE,
ba.MAX_TARGET_BALANCE,
bb.BALANCE_DATE,
bb.LEDGER_BALANCE,
bb.AVAILABLE_BALANCE,
bb.VALUE_DATED_BALANCE,
bb.ONE_DAY_FLOAT,
bb.TWO_DAY_FLOAT,
bb.AVERAGE_CLOSE_LEDGER_MTD,
bb.AVERAGE_CLOSE_LEDGER_YTD,
bb.AVERAGE_CLOSE_AVAILABLE_MTD,
bb.AVERAGE_CLOSE_AVAILABLE_YTD,
pb.PROJECTED_BALANCE
from ce_bank_accounts ba, ce_bank_branches_v bh, ce_bank_acct_balances bb, ce_projected_balances pb
where ba.BANK_BRANCH_ID = bh.BRANCH_PARTY_ID
      and ba.BANK_ACCOUNT_ID = bb.BANK_ACCOUNT_ID
      and bb.BALANCE_DATE between nvl(to_date(p_from_date, 'YYYY/MM/DD HH24:MI:SS'),bb.BALANCE_DATE) and nvl(to_date(p_to_date, 'YYYY/MM/DD HH24:MI:SS'),bb.BALANCE_DATE)
      and bh.BRANCH_PARTY_ID = nvl(p_branch_party_id, bh.BRANCH_PARTY_ID)
      and ba.BANK_ACCOUNT_ID = nvl(p_bank_acct_id, ba.BANK_ACCOUNT_ID)
      and ba.CURRENCY_CODE = nvl(p_bank_acct_currency, ba.CURRENCY_CODE)
      and ba.ACCOUNT_OWNER_ORG_ID = nvl(p_legal_entity_id, ba.ACCOUNT_OWNER_ORG_ID)
      and pb.BANK_ACCOUNT_ID  (+) =  bb.BANK_ACCOUNT_ID
      and pb.BALANCE_DATE (+) = bb.BALANCE_DATE

UNION

select
ba.BANK_ACCOUNT_ID,
ba.BANK_ACCOUNT_NAME,
ba.BANK_ACCOUNT_NUM,
ba.ACCOUNT_OWNER_ORG_ID,
bh.BANK_NAME,
bh.BANK_BRANCH_NAME,
ba.CURRENCY_CODE,
ba.MIN_TARGET_BALANCE,
ba.MAX_TARGET_BALANCE,
pb.BALANCE_DATE,
bb.LEDGER_BALANCE,
bb.AVAILABLE_BALANCE,
bb.VALUE_DATED_BALANCE,
bb.ONE_DAY_FLOAT,
bb.TWO_DAY_FLOAT,
bb.AVERAGE_CLOSE_LEDGER_MTD,
bb.AVERAGE_CLOSE_LEDGER_YTD,
bb.AVERAGE_CLOSE_AVAILABLE_MTD,
bb.AVERAGE_CLOSE_AVAILABLE_YTD,
pb.PROJECTED_BALANCE
from ce_bank_accounts ba, ce_bank_branches_v bh, ce_bank_acct_balances bb, ce_projected_balances pb
where ba.BANK_BRANCH_ID = bh.BRANCH_PARTY_ID
      and ba.BANK_ACCOUNT_ID = pb.BANK_ACCOUNT_ID
      and pb.BALANCE_DATE between nvl(to_date(p_from_date, 'YYYY/MM/DD HH24:MI:SS'),bb.BALANCE_DATE) and nvl(to_date(p_to_date, 'YYYY/MM/DD HH24:MI:SS'),bb.BALANCE_DATE)
      and bh.BRANCH_PARTY_ID = nvl(p_branch_party_id, bh.BRANCH_PARTY_ID)
      and ba.BANK_ACCOUNT_ID = nvl(p_bank_acct_id, ba.BANK_ACCOUNT_ID)
      and ba.CURRENCY_CODE = nvl(p_bank_acct_currency, ba.CURRENCY_CODE)
      and ba.ACCOUNT_OWNER_ORG_ID = nvl(p_legal_entity_id, ba.ACCOUNT_OWNER_ORG_ID)
      and pb.BANK_ACCOUNT_ID   =  bb.BANK_ACCOUNT_ID (+)
      and pb.BALANCE_DATE = bb.BALANCE_DATE (+)
)a;



--select c.accountBalance
--into l_xml
--from ce_balance_reporting_xml_v c;

  l_xml_doc := l_xml.getClobVal();

  CE_BANKACCT_BA_REPORT_UTIL.printClobOut(l_xml_doc);
/*
  l_length := nvl(DBMS_LOB.getlength(l_xml_doc), 0);
  l_offset := 1;
  l_amount := 32767;

  loop
    exit when l_length <= 0;
    dbms_lob.read(l_xml_doc, l_amount, l_offset, l_buffer);
    fnd_file.put(FND_FILE.OUTPUT, l_buffer);
    l_length := l_length-l_amount;
    l_offset := l_offset + l_amount;
  end loop;
*/
/*
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            dbms_output.put_line('End of data');
*/
--    dbms_output.put_line(to_char(l_amount));

exception

   WHEN e_date_exp then
     fnd_file.put_line(fnd_file.log, 'ERROR: from date can not be later than to date');

   WHEN OTHERS THEN
   xrate := -1;

fnd_file.put_line(fnd_file.log, xrate);
fnd_file.put_line(fnd_file.log, SQLCODE);
fnd_file.put_line(fnd_file.log, SQLERRM);

end;


END CE_BANK_ACCT_BALANCE_REPORT;

/
