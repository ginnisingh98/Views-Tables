--------------------------------------------------------
--  DDL for Package Body PAY_CE_SUPPORT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_CE_SUPPORT_PKG" as
/* $Header: pyceinsp.pkb 120.1 2005/12/09 07:09:12 adkumar noship $ */

function bank_segment_value(
  p_external_account_id in number,
  p_lookup_type         in varchar2,
  p_legislation_code    in varchar2) return varchar2 is

  l_segment_name  varchar2(9);
  l_segment_value varchar2(150);

cursor c_bank_flex_segment is
  select decode(decode(substr(hrl.meaning,1,3),hrl.lookup_code||'_',substr(hrl.meaning,4),hrl.meaning),
                'SEGMENT1',pea.segment1,
		'SEGMENT2',pea.segment2,
		'SEGMENT3',pea.segment3,
		'SEGMENT4',pea.segment4,
		'SEGMENT5',pea.segment5,
		'SEGMENT6',pea.segment6,
		'SEGMENT7',pea.segment7,
		'SEGMENT8',pea.segment8,
		'SEGMENT9',pea.segment9,
		'SEGMENT10',pea.segment10,
		'SEGMENT11',pea.segment11,
		'SEGMENT12',pea.segment12,
		'SEGMENT13',pea.segment13,
		'SEGMENT14',pea.segment14,
		'SEGMENT15',pea.segment15,
		'SEGMENT16',pea.segment16,
		'SEGMENT17',pea.segment17,
		'SEGMENT18',pea.segment18,
		'SEGMENT19',pea.segment19,
		'SEGMENT20',pea.segment20,
		'SEGMENT21',pea.segment21,
		'SEGMENT22',pea.segment22,
		'SEGMENT23',pea.segment23,
		'SEGMENT24',pea.segment24,
		'SEGMENT25',pea.segment25,
		'SEGMENT26',pea.segment26,
		'SEGMENT27',pea.segment27,
		'SEGMENT28',pea.segment28,
		'SEGMENT29',pea.segment29,
		'SEGMENT30',pea.segment30,
		'EMPTY')
  from   pay_external_accounts pea,
         hr_lookups hrl
  where  external_account_id = p_external_account_id
  and    hrl.lookup_type = p_lookup_type
  and    hrl.lookup_code = p_legislation_code;
--
l_bank_name varchar2(80);
--
begin

  if p_external_account_id is null then
     return null;
  end if;

  open c_bank_flex_segment;
  fetch c_bank_flex_segment into l_segment_value;
  close c_bank_flex_segment;

  if l_segment_value = 'EMPTY' then

    return null;

  else
  --
  -- Bug 1532646 - the error in the bug is that Sort Code is being returned
  -- where Bank Name should be. This is easily fixed by updating the lookup/
  -- segment mappings. However, this then causes the following problem:
  -- The valueset for Bank Name on the GB Bank key flex stores
  -- the lookup_code, rather than the meaning. So, if the legislation is GB
  -- and the lookup_type is BANK_NAME, then go get the meaning from hr_lookups
  -- so the bank name is inserted into the Cash Management table.
  --
  if p_legislation_code = 'GB' then
  --
    if p_lookup_type = 'BANK_NAME' then
    --
      select meaning
      into   l_bank_name
      from   hr_lookups
      where  lookup_code = l_segment_value
      and    lookup_type = 'GB_BANKS'
      and    application_id between 800 and 899;
      --
      l_segment_value := l_bank_name;
      --
    end if;
    --
  end if;

  --
  -- Ensure that returned segment value <= 30 bytes in length and that it
  -- does not contain the trailing blanks to replace a 'broken' multi-byte
  -- character.
  --
    l_segment_value := rtrim(substrb(l_segment_value, 1, 60));

  return l_segment_value;

  end if;

exception
  when others then

    raise;

end bank_segment_value;


function pay_and_ce_licensed return boolean is

  l_ret_var       boolean;
  l_status_ce     varchar2(1);
  l_status_pay    varchar2(1);
  l_industry      varchar2(1);
  l_oracle_schema varchar2(30);

begin

  hr_utility.set_location('pay_ce_support_pkg.pay_and_ce_licensed', 10);

  l_ret_var := fnd_installation.get_app_info('PAY',
					     l_status_pay,
					     l_industry,
					     l_oracle_schema);

  l_ret_var := fnd_installation.get_app_info('CE',
					     l_status_ce,
					     l_industry,
					     l_oracle_schema);

  if (l_status_pay = 'I' and l_status_ce = 'I') then

    return true;

  else

    return false;

  end if;

end pay_and_ce_licensed;


function session_date return date is

  l_session_date date;

cursor c_session_date is
  select effective_date
  from fnd_sessions
  where session_id = userenv('sessionid');

begin

  open c_session_date;
  fetch c_session_date into l_session_date;
  if c_session_date%notfound then

    l_session_date := trunc(sysdate);

  end if;

  return l_session_date;

end session_date;


function payment_status(p_payment_id number) return varchar2 is

cursor c_payment_status is
  select
    hrl.meaning
  from
    hr_lookups hrl,
    pay_ce_reconciled_payments pcrp
  where
    hrl.lookup_code = pcrp.status_code
    and pcrp.assignment_action_id = p_payment_id
    and hrl.lookup_type = 'RECON_STATUS';

l_payment_status varchar2(80);

begin

  open c_payment_status;
  fetch c_payment_status into l_payment_status;
  if c_payment_status%found then

    close c_payment_status;
    return l_payment_status;

  else

    close c_payment_status;
    return (hr_general.decode_lookup('RECON_STATUS', 'U'));

  end if;

end payment_status;

function lookup_meaning(p_meaning varchar2,p_code varchar2)  return varchar2 is
   l_meaning hr_lookups.meaning%type;
begin
   --
   select decode(substr(p_meaning,1,3),p_code||'_',substr(p_meaning,4),p_meaning)
     into l_meaning
     from dual;
   --
   return l_meaning;
   --
end lookup_meaning;

end pay_ce_support_pkg;

/
