--------------------------------------------------------
--  DDL for Package Body PAY_ADVANCE_PAY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_ADVANCE_PAY_PKG" as
/* $Header: paywsahp.pkb 120.0 2005/05/29 02:44:29 appldev noship $ */
--
--------------------------------------------------------------------------------
/*
+==============================================================================+
|			Copyright (c) 1994 Oracle Corporation		       |
|			   Redwood Shores, California, USA		       |
|			        All rights reserved.			       |
+==============================================================================+
--
Name
	  PAY_ADVANCE_PAY_PKG

Purpose
          Server agent for PAYWSAHP form.

History

Date	  Ver   WW Bug  By		Comment
-----------------------------------------------------------------------------
18 Feb 97 40.00 	M.Lisiecki      Created
          40.1-40.3     M.Lisiecki      Pre release changes.
17 Jun 97 40.4          M.Lisiecki      Changed advanced_periods.
25 Jun 97 40.5          M.Lisiecki      Changed get_balance and advance_amount
					to return char values, without any
					formating.
25 Jun 97 40.6          M.Lisiecki      Changed get_balance return statement
					back to number value.
10 Feb 98 110.2 620296  T.Battoo        Added parameter to advance amount and
                                        get processed flag function

25 Mar 98 110.3 634019  M.Lisiecki      Changed advance_amount and get_processed_flag
					adding effective date conditions.
24 Mar 99 115.1         S.Doshi         Flexible Dates Conversion - to_date
06 Apr 99 115.2         S.Doshi         Flexible Dates Conversion - to_char
24 Nov 99 115.4         SuSivasu        Passed Extrernal Date value to the element
                                        entry api rather than canonical format.
20 Nov 04 115.5         SuSivasu        Fixed the get_balance procedure restrict
                                        the user entity to the given legislation.
21 Jul 04 115.6         SuSivasu        Fixes for GSCC errors.
17 Aug 04 115.7         SuSivasu        Added get_advance_period_start_date
                                        and get_advance_period_end_date.


-----------------------------------------------------------------------------
*/
function advance_amount
--
-- Returns calculated advance amount for the assignment based on
-- Advance element entry's Pay Value.
--
(
p_advance_pay_start_date   date,
p_target_entry_id          number,
p_assignment_id          number
) return varchar2
is
--
l_advance_amount   varchar2(60);

cursor advance_amount is
  select peevf.screen_entry_value
  from pay_element_entries_f peef,
       pay_element_entry_values_f peevf
  where peef.assignment_id = p_assignment_id and
        peef.target_entry_id = p_target_entry_id and
	peef.effective_start_date < p_advance_pay_start_date and
	peef.element_entry_id = peevf.element_entry_id and
	peef.effective_start_date = peevf.effective_start_date and
	peef.effective_end_date = peevf.effective_end_date;

--
begin
--
open advance_amount;
fetch advance_amount into l_advance_amount;
close advance_amount;

return l_advance_amount;

end advance_amount;
-------------------------------------------------------------------------------
function get_balance
(
p_legislation_code         varchar2,
p_balance_lookup_name      varchar2,
p_assignment_id            number,
p_session_date             date
) return number
is
--
-- Returns up to date balance amount for the assignment.
--
l_balance_value    number;
l_creator_id       number;

cursor creator_id is
  select fue.creator_id
  from   ff_user_entities fue,
  ff_database_items fdi,
  pay_legislation_rules plr
  where
  plr.rule_type = p_balance_lookup_name and
  plr.legislation_code = p_legislation_code and
  plr.rule_mode = fdi.user_name and
  fdi.user_entity_id = fue.user_entity_id and
  fue.creator_type = 'B' and
  ((fue.business_group_id is null and
    fue.legislation_code = plr.legislation_code) or
   (fue.business_group_id is not null and
    exists (select null
              from per_all_assignments_f asg
             where asg.assignment_id = p_assignment_id
               and fue.business_group_id = asg.business_group_id)));
--
begin
--
hr_utility.set_location('pay_advance_pay_pkg.get_balance', 5);

open creator_id;
fetch creator_id into l_creator_id;
--
if creator_id%found then
 l_balance_value := pay_balance_pkg.get_value(l_creator_id,
					      p_assignment_id,
				    	      p_session_date);
  --
end if;
--
close creator_id;

return l_balance_value;

hr_utility.set_location('pay_advance_pay_pkg.get_balance', 80);

end get_balance;
-------------------------------------------------------------------------------
function get_processed_flag
  (
  p_advance_pay_start_date      date,
  p_target_entry_id            number,
  p_assignment_id          number
  ) return varchar2
is
--
-- Returns the processed flag for advance payment.
-- This flag is 'Y' after the advance pay process
-- has been run.
--
l_processed_flag    varchar2(30);

cursor processed_flag is
  select 'Y'
  from pay_element_entries_f peef,
       pay_element_entry_values_f peevf
  where peef.assignment_id = p_assignment_id and
        peef.target_entry_id = p_target_entry_id and
	peef.effective_start_date < p_advance_pay_start_date and
	peef.element_entry_id = peevf.element_entry_id and
	peef.effective_start_date = peevf.effective_start_date and
	peef.effective_end_date = peevf.effective_end_date;
--
begin
--
  l_processed_flag := 'N';
--
  open processed_flag;
  fetch processed_flag into l_processed_flag;
  close processed_flag;

  return l_processed_flag;

end get_processed_flag;
-------------------------------------------------------------------------------
function advanced_periods
   (
   p_assignment_id             number,
   p_advance_pay_start_date    date,
   p_advance_pay_end_date      date
   )
   return number
is
--
-- Returns number of periods within advanced payment dates.
--
l_advanced_periods    number;

cursor advanced_periods is
  select count(ptp.time_period_id)
  from per_time_periods ptp,
       per_assignments_f paf
  where paf.assignment_id = p_assignment_id and
	p_advance_pay_start_date between paf.effective_start_date
				     and paf.effective_end_date and
        ptp.payroll_id = paf.payroll_id and
	ptp.start_date >= p_advance_pay_start_date and
	ptp.end_date <= p_advance_pay_end_date;
--
begin
--
open advanced_periods;
fetch advanced_periods into l_advanced_periods;
if advanced_periods%notfound then
  l_advanced_periods := 0;
end if;
close advanced_periods;
--
return l_advanced_periods;
--
end advanced_periods;
------------------------------------------------------------------------
function get_period_end_date
   (
   p_assignment_id             number,
   p_session_date              date
   )
   return date
is
--
-- Returns payroll period end date based on the session date.
--
l_period_end_date    date;

cursor period_end_date is
select ptp.end_date
from
  per_time_periods ptp,
  pay_payrolls_f ppf,
  per_assignments_f paf
where
  paf.assignment_id = p_assignment_id and
  p_session_date between paf.effective_start_date
		     and paf.effective_end_date and
  ppf.payroll_id = paf.payroll_id and
  p_session_date between ppf.effective_start_date
		     and ppf.effective_end_date and
  ptp.payroll_id = ppf.payroll_id and
  ptp.start_date <= p_session_date and
  ptp.end_date >= p_session_date;
--
begin
--
hr_utility.set_location('pay_advance_pay_pkg.get_period_end_date'   , 5);

open period_end_date;
fetch period_end_date into l_period_end_date;

if period_end_date%notfound then
  hr_utility.trace('session_date'|| fnd_date.date_to_canonical(p_session_date));
  hr_utility.set_message (801,'PAY_52103_PERIOD_NOT_EXIST');
  hr_utility.raise_error;
end if;
--
close period_end_date;
--
return l_period_end_date;
--
hr_utility.set_location('pay_advance_pay_pkg.get_period_end_date'   , 80);
--
end get_period_end_date;
------------------------------------------------------------------------
function get_period_start_date
   (
   p_assignment_id             number,
   p_session_date            date
   )
   return date
is
--
-- Returns payroll period start date based on the session date.
--
l_period_start_date    date;

cursor period_start_date is
select ptp.start_date
from
  per_time_periods ptp,
  pay_payrolls_f ppf,
  per_assignments_f paf
where
  paf.assignment_id = p_assignment_id and
  p_session_date between paf.effective_start_date
		     and paf.effective_end_date and
  ppf.payroll_id = paf.payroll_id and
  p_session_date between ppf.effective_start_date
		     and ppf.effective_end_date and
  ptp.payroll_id = ppf.payroll_id and
  ptp.start_date <= p_session_date and
  ptp.end_date >= p_session_date;

begin

hr_utility.set_location('pay_advance_pay_pkg.get_period_start_date'   , 5);

open period_start_date;
fetch period_start_date into l_period_start_date;

if period_start_date%notfound then
  hr_utility.set_message (801, 'PAY_52103_PERIOD_NOT_EXIST');
  hr_utility.raise_error;
end if;
--
close period_start_date;
--
return l_period_start_date;
--
hr_utility.set_location('pay_advance_pay_pkg.get_period_start_date'   , 80);
--
end get_period_start_date;
------------------------------------------------------------------------
function get_advance_period_start_date
   (
   p_assignment_id             number,
   p_session_date            date,
   p_flag                    varchar2
   )
   return date
is
--
-- Returns payroll period start date based on the session date.
--
l_period_start_date    date;

cursor period_start_date is
select aptp.start_date
from
  per_time_periods ptp,
  pay_payrolls_f ppf,
  per_assignments_f paf,
  per_time_periods aptp
where
  paf.assignment_id = p_assignment_id and
  p_session_date between paf.effective_start_date
		     and paf.effective_end_date and
  ppf.payroll_id = paf.payroll_id and
  p_session_date between ppf.effective_start_date
		     and ppf.effective_end_date and
  ptp.payroll_id = ppf.payroll_id and
  ptp.start_date <= p_session_date and
  ptp.end_date >= p_session_date and
  aptp.payroll_id = ppf.payroll_id and
  ptp.start_date <= aptp.regular_payment_date and
  ptp.end_date >= aptp.regular_payment_date;
--
cursor r_period_start_date is
select aptp.start_date
from
  per_time_periods ptp,
  pay_payrolls_f ppf,
  per_assignments_f paf,
  per_time_periods aptp
where
  paf.assignment_id = p_assignment_id and
  p_session_date between paf.effective_start_date
		     and paf.effective_end_date and
  ppf.payroll_id = paf.payroll_id and
  p_session_date between ppf.effective_start_date
		     and ppf.effective_end_date and
  ptp.payroll_id = ppf.payroll_id and
  ptp.start_date <= p_session_date and
  ptp.end_date >= p_session_date and
  aptp.payroll_id = ppf.payroll_id and
  aptp.start_date <= ptp.regular_payment_date and
  aptp.end_date >= ptp.regular_payment_date;

begin

hr_utility.set_location('pay_advance_pay_pkg.get_advance_period_start_date'   , 5);
if p_flag = 'N' then
   open period_start_date;
   fetch period_start_date into l_period_start_date;

   if period_start_date%notfound then
     hr_utility.set_message (801, 'PAY_52103_PERIOD_NOT_EXIST');
     hr_utility.raise_error;
   end if;
   --
   close period_start_date;
   --
else
   open r_period_start_date;
   fetch r_period_start_date into l_period_start_date;

   if r_period_start_date%notfound then
     hr_utility.set_message (801, 'PAY_52103_PERIOD_NOT_EXIST');
     hr_utility.raise_error;
   end if;
   --
   close r_period_start_date;
   --
end if;
--
return l_period_start_date;
--
hr_utility.set_location('pay_advance_pay_pkg.get_advance_period_start_date'   , 80);
--
end get_advance_period_start_date;
------------------------------------------------------------------------
function get_advance_period_end_date
   (
   p_assignment_id             number,
   p_session_date            date,
   p_flag                    varchar2
   )
   return date
is
--
-- Returns payroll period end date based on the session date.
--
l_period_start_date    date;

cursor period_start_date is
select aptp.end_date
from
  per_time_periods ptp,
  pay_payrolls_f ppf,
  per_assignments_f paf,
  per_time_periods aptp
where
  paf.assignment_id = p_assignment_id and
  p_session_date between paf.effective_start_date
		     and paf.effective_end_date and
  ppf.payroll_id = paf.payroll_id and
  p_session_date between ppf.effective_start_date
		     and ppf.effective_end_date and
  ptp.payroll_id = ppf.payroll_id and
  ptp.start_date <= p_session_date and
  ptp.end_date >= p_session_date and
  aptp.payroll_id = ppf.payroll_id and
  ptp.start_date <= aptp.regular_payment_date and
  ptp.end_date >= aptp.regular_payment_date;
--
cursor r_period_start_date is
select aptp.end_date
from
  per_time_periods ptp,
  pay_payrolls_f ppf,
  per_assignments_f paf,
  per_time_periods aptp
where
  paf.assignment_id = p_assignment_id and
  p_session_date between paf.effective_start_date
		     and paf.effective_end_date and
  ppf.payroll_id = paf.payroll_id and
  p_session_date between ppf.effective_start_date
		     and ppf.effective_end_date and
  ptp.payroll_id = ppf.payroll_id and
  ptp.start_date <= p_session_date and
  ptp.end_date >= p_session_date and
  aptp.payroll_id = ppf.payroll_id and
  aptp.start_date <= ptp.regular_payment_date and
  aptp.end_date >= ptp.regular_payment_date;

begin

hr_utility.set_location('pay_advance_pay_pkg.get_advance_period_end_date'   , 5);

if p_flag = 'N' then
   --
   open period_start_date;
   fetch period_start_date into l_period_start_date;

   if period_start_date%notfound then
     hr_utility.set_message (801, 'PAY_52103_PERIOD_NOT_EXIST');
     hr_utility.raise_error;
   end if;
   --
   close period_start_date;
   --
else
   --
   open r_period_start_date;
   fetch r_period_start_date into l_period_start_date;

   if r_period_start_date%notfound then
     hr_utility.set_message (801, 'PAY_52103_PERIOD_NOT_EXIST');
     hr_utility.raise_error;
   end if;
   --
   close r_period_start_date;
   --
end if;
--
return l_period_start_date;
--
hr_utility.set_location('pay_advance_pay_pkg.get_advance_period_end_date'   , 80);
--
end get_advance_period_end_date;
------------------------------------------------------------------------
procedure insert_indicator_entries
  (
   p_defer_flag in varchar2,
   p_assignment_id in number,
   p_session_date in out nocopy date,
   p_pai_element_entry_id in out nocopy number,
   p_pai_element_type_id  in number,
   p_pai_sd_input_value_id in number,
   p_pai_ed_input_value_id in number,
   p_pai_start_date in date,
   p_pai_end_date in date,
   p_advance_pay_start_date in date,
   p_advance_pay_end_date in date,
   p_arrears_flag in varchar2,
   p_periods_advanced in number,
   p_ai_element_type_id in number,
   p_ai_af_input_value_id in number,
   p_ai_dpf_input_value_id in number
  )
is
--
-- Inserts entry for Pay Advance Indicator and corresponding entries
-- for Advance Indicator.
--
  l_element_entry_start_date date;
  l_element_entry_end_date date; --to be worked out by entry API
  l_ai_element_entry_id number;
  l_pay_periods number;
  l_arrears_offset number;
  l_advance_pay varchar2(30);
  l_defer_pay varchar2(30);
  --
  l_session_date date;
  l_pai_element_entry_id number;
--
begin
  --
  hr_utility.set_location('pay_advance_pay_pkg.insert_indicator_entries', 5);
  --
  l_arrears_offset := 0;
  l_advance_pay := 'Y';
  l_defer_pay := p_defer_flag;
  --
  l_session_date := p_session_date;
  l_pai_element_entry_id :=  p_pai_element_entry_id;
  --
  -- Pay Advance Indicator Entry.
  --
  -- entry start and end dates are both end of the period. If assignment starts
  -- or finishes in the middle of the period, entry will still be created.
  l_element_entry_start_date := pay_advance_pay_pkg.get_period_end_date
     			        (
				 p_assignment_id,
			         l_session_date
				);
  --
  l_element_entry_end_date := l_element_entry_start_date;

  hr_utility.set_location('pay_advance_pay_pkg.insert_indicator_entries', 60);
  --
  hr_entry_api.insert_element_entry
    (
     p_effective_start_date       => l_element_entry_start_date,
     p_effective_end_date         => l_element_entry_end_date,
     p_element_entry_id           => l_pai_element_entry_id,
     p_assignment_id              => p_assignment_id,
     p_element_link_id            => hr_entry_api.get_link
			             (
		       		      p_assignment_id,
				      p_pai_element_type_id,
				      l_session_date
			             ),
     p_creator_type	          => 'DF',
     p_entry_type	          => 'E',
     p_input_value_id1            => p_pai_sd_input_value_id,
     p_input_value_id2            => p_pai_ed_input_value_id,
     p_entry_value1               => fnd_date.date_to_displaydate(p_pai_start_date),
     p_entry_value2               => fnd_date.date_to_displaydate(p_pai_end_date)
   );

  -- set out value
  l_session_date := l_element_entry_start_date;

  --
  -- Advance Indicator entries.
  --

  -- In case of arrears payroll there will be one additional entry.

  if p_arrears_flag = 'Y' then
       l_arrears_offset := 1;
  end if;
  --
  -- dates changed in the loop to fall within each pay period

  l_element_entry_start_date := p_advance_pay_start_date;

  hr_utility.trace('l_element_entry_start_date (1): ' ||
	fnd_date.date_to_canonical(l_element_entry_start_date));

  l_element_entry_end_date := pay_advance_pay_pkg.get_period_end_date
  			        (
			         p_assignment_id,
			         l_element_entry_start_date
			        );
    --
  for l_pay_periods in 1..(p_periods_advanced + l_arrears_offset) loop
    --
    -- set advance pay flag to 'N' for 1st period in arrears

    if p_arrears_flag = 'Y' and l_pay_periods = 1 then
      l_advance_pay := 'N';
    else
      l_advance_pay := 'Y';
    end if;

    -- set defer pay flag to 'N' for last period in arrears
    if p_arrears_flag = 'Y' and
       l_pay_periods = (p_periods_advanced + l_arrears_offset) then
      l_defer_pay := 'N';
    end if;
    --
    hr_utility.set_location('pay_advance_pay_pkg.insert_indicator_entries', 70);
    --
    hr_entry_api.insert_element_entry
    (
     p_effective_start_date	=> l_element_entry_start_date,
     p_effective_end_date       => l_element_entry_end_date,
     p_element_entry_id         => l_ai_element_entry_id,
     p_assignment_id		=> p_assignment_id,
     p_element_link_id          => hr_entry_api.get_link
				   (
				    p_assignment_id,
				    p_ai_element_type_id,
				    l_element_entry_start_date
				   ),
     p_creator_type		=> 'DF',
     p_entry_type		=> 'E',
     p_input_value_id1          => p_ai_af_input_value_id,
     p_input_value_id2          => p_ai_dpf_input_value_id,
     p_entry_value1		=> hr_general.decode_lookup
				   ('YES_NO',l_advance_pay),
     p_entry_value2		=> hr_general.decode_lookup
				   ('YES_NO',l_defer_pay)
    );
    --
    -- move to the next pay period
    --
    hr_utility.trace('l_element_entry_start_date (2): ' ||
	    fnd_date.date_to_canonical(l_element_entry_start_date));
    l_element_entry_start_date := pay_advance_pay_pkg.get_period_end_date
				  (
				   p_assignment_id,
				   l_element_entry_start_date
				  ) + 1;
    --
    hr_utility.trace('l_element_entry_start_date (3): ' ||
	fnd_date.date_to_canonical(l_element_entry_start_date));
    --
    l_element_entry_end_date := pay_advance_pay_pkg.get_period_end_date
				(
				 p_assignment_id,
				 l_element_entry_start_date
				);
  --
  end loop;
  --
  p_session_date := l_session_date;
  p_pai_element_entry_id := l_pai_element_entry_id;
  --
  hr_utility.set_location('pay_advance_pay_pkg.insert_indicator_entries', 80);
  --
end insert_indicator_entries;
------------------------------------------------------------------------
procedure delete_indicator_entries
  (
    p_assignment_id in number,
    p_legislation_code in varchar2,
    p_session_date in date,
    p_pai_element_entry_id in number,
    p_arrears_flag in varchar2
  )
is
--
-- Deletes entry for Pay Advance Indicator and corresponding
-- entries for Advance Indicator.

  l_ai_element_entry_id number;
  l_effective_start_date date;
  l_indicators_start_date date;
  l_indicators_end_date date;
  --
  cursor advance_dates is
    select
    -- min of two input values - advance pay period start date
    min(fnd_date.canonical_to_date(peevf.screen_entry_value)),
    -- max of two input values - advance pay period end date
    max(fnd_date.canonical_to_date(peevf.screen_entry_value))
      from pay_element_entry_values_f peevf
      where peevf.element_entry_id = p_pai_element_entry_id;
  --
  cursor corresponding_ai_entries is
  --returns element_entry_ids of all Advance Indicator entries that
  --correspond to the Pay Advance Indicator in question.
  --
    select peef.element_entry_id, peef.effective_start_date
      from
	   pay_legislation_rules plr,
	   pay_element_types_f petf,
	   pay_element_links_f pelf,
	   pay_element_entries_f peef
      where
	   -- entry belongs to this assignment
	   peef.assignment_id = p_assignment_id and
	   -- entry is of Advance Indicator type
	   peef.element_link_id = pelf.element_link_id and
	   pelf.element_type_id = petf.element_type_id and
	   petf.element_type_id = plr.rule_mode and
	   plr.legislation_code = p_legislation_code and
	   plr.rule_type = 'ADVANCE_INDICATOR' and
	   -- entry exists within advance period for the assignment
	   peef.effective_start_date between l_indicators_start_date
	                                 and l_indicators_end_date;

begin
--
hr_utility.set_location('pay_advance_pay_pkg.delete_indicator_entries' , 5);
--
-- fetch advance dates
open advance_dates;
fetch advance_dates into l_indicators_start_date,
                         l_indicators_end_date;
close advance_dates;

-- delete Pay Advance Indicator.

hr_entry_api.delete_element_entry
(
  p_dt_delete_mode              => 'ZAP',
  p_session_date                => p_session_date,
  p_element_entry_id            => p_pai_element_entry_id
);
--
-- for arrears payroll, there will be an aditional Advance Indicator entry
if p_arrears_flag = 'Y' then
  l_indicators_start_date := pay_advance_pay_pkg.get_period_start_date
				  (
				  p_assignment_id,
				  l_indicators_start_date - 1
				  );
end if;

-- trace dates used to remove Advance Indicators
hr_utility.trace('p_pai_element_entry_id: ' || to_char(p_pai_element_entry_id));
hr_utility.trace('l_indicators_start_date: ' || fnd_date.date_to_canonical(l_indicators_start_date));
hr_utility.trace('l_indicators_end_date: ' || fnd_date.date_to_canonical(l_indicators_end_date));

-- Advance Indicator(s)

-- first Advance Indicator element_entry_id

open corresponding_ai_entries;
fetch corresponding_ai_entries into l_ai_element_entry_id,
				    l_effective_start_date;

while corresponding_ai_entries%found loop

hr_utility.set_location('pay_advance_pay_pkg.delete_indicator_entries' , 10);

  hr_entry_api.delete_element_entry
  (
    p_dt_delete_mode		=>'ZAP',
    p_session_date		=>l_effective_start_date,
    p_element_entry_id		=>l_ai_element_entry_id
   );

-- fetch next Advance Indicator
fetch corresponding_ai_entries into l_ai_element_entry_id,
				    l_effective_start_date;

end loop;

close corresponding_ai_entries;

hr_utility.set_location('pay_advance_pay_pkg.delete_indicator_entries' , 80);

end delete_indicator_entries;
------------------------------------------------------------------------
end pay_advance_pay_pkg;

/
