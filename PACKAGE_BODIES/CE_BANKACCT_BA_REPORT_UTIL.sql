--------------------------------------------------------
--  DDL for Package Body CE_BANKACCT_BA_REPORT_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CE_BANKACCT_BA_REPORT_UTIL" AS
/* $Header: cexmlb1b.pls 120.5.12010000.2 2008/12/18 10:44:43 csutaria ship $ */

function get_rate
  (
   p_from_curr       varchar2,
   p_to_curr         varchar2,
   p_exchange_rate_date   varchar2,
   p_exchange_rate_type   varchar2
  )
  return number
is
  xrate number;
begin

   -- no reporting currency
   if p_to_curr is null then
     return -1;
   end if;

   -- same currency
   if p_to_curr = p_from_curr then
      return 1;
   end if;

   xrate := GL_CURRENCY_API.get_rate(p_from_curr, p_to_curr, to_date(nvl(p_exchange_rate_date, to_char(sysdate, 'YYYY/MM/DD HH24:MI:SS')), 'YYYY/MM/DD HH24:MI:SS'), p_exchange_rate_type);

--fnd_file.put_line(fnd_file.log, p_from_curr);
--fnd_file.put_line(fnd_file.log, p_to_curr);
--fnd_file.put_line(fnd_file.log, xrate);


   return xrate;

exception
   WHEN OTHERS THEN
   xrate := -1;
   return xrate;
END;

function get_reporting_balance
  (
   p_balance         number,
   p_from_curr       varchar2,
   p_to_curr         varchar2,
   p_exchange_rate_date   varchar2,
   p_exchange_rate_type   varchar2
  )
  return varchar2
is
  v_rate number;
begin

  v_rate := get_rate(p_from_curr, p_to_curr, p_exchange_rate_date, p_exchange_rate_type);

  if v_rate = -1 then
    return null;
  else
      if p_balance is null then
         return null;
      else
         if p_balance >= 0 then
           return to_char(p_balance*v_rate, FND_CURRENCY.GET_FORMAT_MASK(p_to_curr, 30));      else
           return concat('-', to_char(-1*p_balance*v_rate, FND_CURRENCY.GET_FORMAT_MASK(p_to_curr, 30)));
         end if;
       end if;
  end if;

END;

function get_balance
  (
   p_balance         number,
   p_from_curr       varchar2
  )
  return varchar2
is

begin

   if p_from_curr is null then
      return null;
   end if;

   if p_balance is null then
      return null;
   else
      if p_balance >= 0 then
         return to_char(p_balance, FND_CURRENCY.GET_FORMAT_MASK(p_from_curr, 30));      else
         return concat('-', to_char(-1*p_balance, FND_CURRENCY.GET_FORMAT_MASK(p_from_curr, 30)));
      end if;
    end if;
END;

function get_variance
  (
   p_bank_acct_id  number,
   p_balance_date  date,
   p_actual_balance_type  varchar2
  )
  return number
is
  v_variance number :=0;
  v_record_num varchar2(30);
  v_currency_code ce_bank_accounts.currency_code%type;
begin

if p_actual_balance_type = 'L' then
  select count(1)
  into v_record_num
  from ce_bank_acct_balances bb, ce_projected_balances pb
  where bb.BANK_ACCOUNT_ID = p_bank_acct_id
    and pb.BANK_ACCOUNT_ID = p_bank_acct_id
    and bb.BALANCE_DATE = p_balance_date
    and pb.BALANCE_DATE = p_balance_date
    and bb.LEDGER_BALANCE is not null
    and pb.PROJECTED_BALANCE is not null;
  if v_record_num = 1 then
    select bb.LEDGER_BALANCE - pb.PROJECTED_BALANCE, ba.CURRENCY_CODE
    into v_variance, v_currency_code
    from ce_bank_acct_balances bb, ce_projected_balances pb, ce_bank_accounts ba
    where bb.BANK_ACCOUNT_ID = p_bank_acct_id
      and pb.BANK_ACCOUNT_ID = p_bank_acct_id
      and bb.BALANCE_DATE = p_balance_date
      and pb.BALANCE_DATE = p_balance_date
      and bb.LEDGER_BALANCE is not null
      and pb.PROJECTED_BALANCE is not null
      and ba.BANK_ACCOUNT_ID = bb.BANK_ACCOUNT_ID;

--    return to_char(v_variance, FND_CURRENCY.GET_FORMAT_MASK(v_currency_code, 30));
    return v_variance;
  end if;
end if;

if p_actual_balance_type = 'I' then
  select count(1)
  into v_record_num
  from ce_bank_acct_balances bb, ce_projected_balances pb
  where bb.BANK_ACCOUNT_ID = p_bank_acct_id
    and pb.BANK_ACCOUNT_ID = p_bank_acct_id
    and bb.BALANCE_DATE = p_balance_date
    and pb.BALANCE_DATE = p_balance_date
    and bb.VALUE_DATED_BALANCE is not null
    and pb.PROJECTED_BALANCE is not null;

   if v_record_num = 1 then
    select bb.VALUE_DATED_BALANCE - pb.PROJECTED_BALANCE, ba.CURRENCY_CODE
    into v_variance, v_currency_code
    from ce_bank_acct_balances bb, ce_projected_balances pb, ce_bank_accounts ba
    where bb.BANK_ACCOUNT_ID = p_bank_acct_id
      and pb.BANK_ACCOUNT_ID = p_bank_acct_id
      and bb.BALANCE_DATE = p_balance_date
      and pb.BALANCE_DATE = p_balance_date
      and bb.VALUE_DATED_BALANCE is not null
      and pb.PROJECTED_BALANCE is not null
      and ba.BANK_ACCOUNT_ID = bb.BANK_ACCOUNT_ID;
--    return to_char(v_variance, FND_CURRENCY.GET_FORMAT_MASK(v_currency_code, 30));
    return v_variance;
  end if;
end if;

if p_actual_balance_type = 'C' then
  select count(1)
  into v_record_num
  from ce_bank_acct_balances bb, ce_projected_balances pb
  where bb.BANK_ACCOUNT_ID = p_bank_acct_id
    and pb.BANK_ACCOUNT_ID = p_bank_acct_id
    and bb.BALANCE_DATE = p_balance_date
    and pb.BALANCE_DATE = p_balance_date
    and bb.AVAILABLE_BALANCE is not null
    and pb.PROJECTED_BALANCE is not null;
   if v_record_num = 1 then
    select bb.AVAILABLE_BALANCE - pb.PROJECTED_BALANCE, ba.currency_code
    into v_variance, v_currency_code
    from ce_bank_acct_balances bb, ce_projected_balances pb, ce_bank_accounts ba
    where bb.BANK_ACCOUNT_ID = p_bank_acct_id
      and pb.BANK_ACCOUNT_ID = p_bank_acct_id
      and bb.BALANCE_DATE = p_balance_date
      and pb.BALANCE_DATE = p_balance_date
      and bb.AVAILABLE_BALANCE is not null
      and pb.PROJECTED_BALANCE is not null
      and ba.BANK_ACCOUNT_ID = bb.BANK_ACCOUNT_ID;
--    return to_char(v_variance, FND_CURRENCY.GET_FORMAT_MASK(v_currency_code, 30));
    return v_variance;
  end if;
end if;

if p_actual_balance_type = 'O' then
  select count(1)
  into v_record_num
  from ce_bank_acct_balances bb, ce_projected_balances pb
  where bb.BANK_ACCOUNT_ID = p_bank_acct_id
    and pb.BANK_ACCOUNT_ID = p_bank_acct_id
    and bb.BALANCE_DATE = p_balance_date
    and pb.BALANCE_DATE = p_balance_date
    and bb.ONE_DAY_FLOAT is not null
    and pb.PROJECTED_BALANCE is not null;
   if v_record_num = 1 then
    select bb.ONE_DAY_FLOAT - pb.PROJECTED_BALANCE, ba.currency_code
    into v_variance, v_currency_code
    from ce_bank_acct_balances bb, ce_projected_balances pb, ce_bank_accounts ba
    where bb.BANK_ACCOUNT_ID = p_bank_acct_id
      and pb.BANK_ACCOUNT_ID = p_bank_acct_id
      and bb.BALANCE_DATE = p_balance_date
      and pb.BALANCE_DATE = p_balance_date
      and bb.ONE_DAY_FLOAT is not null
      and pb.PROJECTED_BALANCE is not null
      and ba.BANK_ACCOUNT_ID = bb.BANK_ACCOUNT_ID;
--    return to_char(v_variance, FND_CURRENCY.GET_FORMAT_MASK(v_currency_code, 30));
    return v_variance;
  end if;
end if;

if p_actual_balance_type = 'T' then
  select count(1)
  into v_record_num
  from ce_bank_acct_balances bb, ce_projected_balances pb
  where bb.BANK_ACCOUNT_ID = p_bank_acct_id
    and pb.BANK_ACCOUNT_ID = p_bank_acct_id
    and bb.BALANCE_DATE = p_balance_date
    and pb.BALANCE_DATE = p_balance_date
    and bb.TWO_DAY_FLOAT is not null
    and pb.PROJECTED_BALANCE is not null;
   if v_record_num = 1 then
    select bb.TWO_DAY_FLOAT - pb.PROJECTED_BALANCE, ba.currency_code
    into v_variance, v_currency_code
    from ce_bank_acct_balances bb, ce_projected_balances pb, ce_bank_accounts ba
    where bb.BANK_ACCOUNT_ID = p_bank_acct_id
      and pb.BANK_ACCOUNT_ID = p_bank_acct_id
      and bb.BALANCE_DATE = p_balance_date
      and pb.BALANCE_DATE = p_balance_date
      and bb.TWO_DAY_FLOAT is not null
      and pb.PROJECTED_BALANCE is not null
      and ba.BANK_ACCOUNT_ID = bb.BANK_ACCOUNT_ID;
--    return to_char(v_variance, FND_CURRENCY.GET_FORMAT_MASK(v_currency_code, 30));
    return v_variance;
  end if;
end if;

if p_actual_balance_type = 'CLM' then
  select count(1)
  into v_record_num
  from ce_bank_acct_balances bb, ce_projected_balances pb
  where bb.BANK_ACCOUNT_ID = p_bank_acct_id
    and pb.BANK_ACCOUNT_ID = p_bank_acct_id
    and bb.BALANCE_DATE = p_balance_date
    and pb.BALANCE_DATE = p_balance_date
    and bb.AVERAGE_CLOSE_LEDGER_MTD is not null
    and pb.PROJECTED_BALANCE is not null;
   if v_record_num = 1 then
    select bb.AVERAGE_CLOSE_LEDGER_MTD - pb.PROJECTED_BALANCE, ba.currency_code
    into v_variance, v_currency_code
    from ce_bank_acct_balances bb, ce_projected_balances pb, ce_bank_accounts ba
    where bb.BANK_ACCOUNT_ID = p_bank_acct_id
      and pb.BANK_ACCOUNT_ID = p_bank_acct_id
      and bb.BALANCE_DATE = p_balance_date
      and pb.BALANCE_DATE = p_balance_date
      and bb.AVERAGE_CLOSE_LEDGER_MTD is not null
      and pb.PROJECTED_BALANCE is not null
      and ba.BANK_ACCOUNT_ID = bb.BANK_ACCOUNT_ID;
--    return to_char(v_variance, FND_CURRENCY.GET_FORMAT_MASK(v_currency_code, 30));
    return v_variance;
  end if;
end if;

if p_actual_balance_type = 'CLY' then
  select count(1)
  into v_record_num
  from ce_bank_acct_balances bb, ce_projected_balances pb
  where bb.BANK_ACCOUNT_ID = p_bank_acct_id
    and pb.BANK_ACCOUNT_ID = p_bank_acct_id
    and bb.BALANCE_DATE = p_balance_date
    and pb.BALANCE_DATE = p_balance_date
    and bb.AVERAGE_CLOSE_LEDGER_YTD is not null
    and pb.PROJECTED_BALANCE is not null;
  if v_record_num = 1 then
    select bb.AVERAGE_CLOSE_LEDGER_YTD - pb.PROJECTED_BALANCE, ba.currency_code
    into v_variance, v_currency_code
    from ce_bank_acct_balances bb, ce_projected_balances pb, ce_bank_accounts ba
    where bb.BANK_ACCOUNT_ID = p_bank_acct_id
      and pb.BANK_ACCOUNT_ID = p_bank_acct_id
      and bb.BALANCE_DATE = p_balance_date
      and pb.BALANCE_DATE = p_balance_date
      and bb.AVERAGE_CLOSE_LEDGER_YTD is not null
      and pb.PROJECTED_BALANCE is not null
      and ba.BANK_ACCOUNT_ID = bb.BANK_ACCOUNT_ID;
--    return to_char(v_variance, FND_CURRENCY.GET_FORMAT_MASK(v_currency_code, 30));
    return v_variance;
  end if;
end if;

if p_actual_balance_type = 'CAM' then
  select count(1)
  into v_record_num
  from ce_bank_acct_balances bb, ce_projected_balances pb
  where bb.BANK_ACCOUNT_ID = p_bank_acct_id
    and pb.BANK_ACCOUNT_ID = p_bank_acct_id
    and bb.BALANCE_DATE = p_balance_date
    and pb.BALANCE_DATE = p_balance_date
    and bb.AVERAGE_CLOSE_AVAILABLE_MTD is not null
    and pb.PROJECTED_BALANCE is not null;
  if v_record_num = 1 then
    select bb.AVERAGE_CLOSE_AVAILABLE_MTD - pb.PROJECTED_BALANCE, ba.currency_code
    into v_variance, v_currency_code
    from ce_bank_acct_balances bb, ce_projected_balances pb, ce_bank_accounts ba
    where bb.BANK_ACCOUNT_ID = p_bank_acct_id
      and pb.BANK_ACCOUNT_ID = p_bank_acct_id
      and bb.BALANCE_DATE = p_balance_date
      and pb.BALANCE_DATE = p_balance_date
      and bb.AVERAGE_CLOSE_AVAILABLE_MTD is not null
      and pb.PROJECTED_BALANCE is not null
      and ba.BANK_ACCOUNT_ID = bb.BANK_ACCOUNT_ID;
--    return to_char(v_variance, FND_CURRENCY.GET_FORMAT_MASK(v_currency_code, 30));
    return v_variance;
  end if;
end if;

if p_actual_balance_type = 'CAY' then
  select count(1)
  into v_record_num
  from ce_bank_acct_balances bb, ce_projected_balances pb
  where bb.BANK_ACCOUNT_ID = p_bank_acct_id
    and pb.BANK_ACCOUNT_ID = p_bank_acct_id
    and bb.BALANCE_DATE = p_balance_date
    and pb.BALANCE_DATE = p_balance_date
    and bb.AVERAGE_CLOSE_AVAILABLE_YTD is not null
    and pb.PROJECTED_BALANCE is not null;
  if v_record_num = 1 then
    select bb.AVERAGE_CLOSE_AVAILABLE_YTD - pb.PROJECTED_BALANCE, ba.currency_code
    into v_variance, v_currency_code
    from ce_bank_acct_balances bb, ce_projected_balances pb, ce_bank_accounts ba
    where bb.BANK_ACCOUNT_ID = p_bank_acct_id
      and pb.BANK_ACCOUNT_ID = p_bank_acct_id
      and bb.BALANCE_DATE = p_balance_date
      and pb.BALANCE_DATE = p_balance_date
      and bb.AVERAGE_CLOSE_AVAILABLE_YTD is not null
      and pb.PROJECTED_BALANCE is not null
      and ba.BANK_ACCOUNT_ID = bb.BANK_ACCOUNT_ID;
--    return to_char(v_variance, FND_CURRENCY.GET_FORMAT_MASK(v_currency_code, 30));
    return v_variance;
  end if;
end if;

return null;

end;

PROCEDURE printClobOut(
                      aResult       IN OUT NOCOPY  CLOB
                      )
IS

  l_posn_mark NUMBER := 1;
  l_posn      NUMBER := 1;
  l_length    NUMBER := 0;

  l_max_linesize   CONSTANT NUMBER := 32766;
  l_buffer         VARCHAR2(4000);

  aSqlcode NUMBER;
  aSqlerrm VARCHAR2(1000);
  l_encoding VARCHAR2(300);

BEGIN

  FND_FILE.PUT_LINE( FND_FILE.LOG,'BEGIN printClobOut');
   -- Bug 7629651 added encoding information at the start of xml file
  l_encoding  := fnd_profile.value('ICX_CLIENT_IANA_ENCODING');
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'<?xml version="1.0" encoding="'||l_encoding ||'"?>' );
  l_length:= dbms_lob.getlength(aResult);
  l_posn_mark:= l_posn;

  WHILE l_posn_mark < l_length LOOP

    l_posn:= dbms_lob.instr(lob_loc => aResult,
                            pattern => '</',
                            offset => l_posn,
                            nth => 1
                         );

    l_posn:= dbms_lob.instr(lob_loc => aResult,
                            pattern => '>',
                            offset => l_posn,
                            nth => 1
                         );


    l_buffer:= dbms_lob.SUBSTR(lob_loc => aResult,
                               amount => l_posn - l_posn_mark + 1,
                               offset => l_posn_mark);

    l_posn_mark:= l_posn + 1;
    l_posn:=      l_posn_mark;

    FND_FILE.PUT_LINE( FND_FILE.OUTPUT,l_buffer);
  END LOOP;
  FND_FILE.PUT_LINE( FND_FILE.LOG,'  END printClobOut');

EXCEPTION
WHEN OTHERS
THEN
     aSqlcode := SQLCODE;
     aSqlerrm := SUBSTR(SQLERRM,1,300);
  FND_FILE.PUT_LINE( FND_FILE.LOG,aSqlerrm);
END;


END CE_BANKACCT_BA_REPORT_UTIL;

/
