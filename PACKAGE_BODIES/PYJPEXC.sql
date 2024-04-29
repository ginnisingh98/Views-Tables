--------------------------------------------------------
--  DDL for Package Body PYJPEXC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PYJPEXC" as
/* $Header: pyjpexc.pkb 120.2.12000000.2 2007/03/05 08:53:51 keyazawa noship $ */
--
-- Constants
--
c_package	constant varchar2(31) := 'pyjpexc.';
--
-- Global Variables
--
-- Fiscal Year Start Date Cache
--
type t_fy_cache is record(
	business_group_id	number,
	start_date		date);
g_fy_cache	t_fy_cache;
type t_pact_cache is record(
	payroll_action_id	number,
	business_group_id	number);
g_pact_cache		t_pact_cache;
--
function asg_run return varchar2 is begin return c_asg_run; end asg_run;
function asg_ptd return varchar2 is begin return c_asg_ptd; end asg_ptd;
function asg_mtd return varchar2 is begin return c_asg_mtd; end asg_mtd;
function asg_ytd return varchar2 is begin return c_asg_ytd; end asg_ytd;
function asg_aprtd return varchar2 is begin return c_asg_aprtd; end asg_aprtd;
function asg_jultd return varchar2 is begin return c_asg_jultd; end asg_jultd;
function asg_augtd return varchar2 is begin return c_asg_augtd; end asg_augtd;
function asg_fytd return varchar2 is begin return c_asg_fytd; end asg_fytd;
function asg_fytd_de return varchar2 is begin return c_asg_fytd_de; end asg_fytd_de;
function asg_ltd return varchar2 is begin return c_asg_ltd; end asg_ltd;
function element_ptd return varchar2 is begin return c_element_ptd; end element_ptd;
function element_ltd return varchar2 is begin return c_element_ltd; end element_ltd;
function asg_retro return varchar2 is begin return c_asg_retro; end asg_retro;
function payments return varchar2 is begin return c_payments; end payments;
-- ----------------------------------------------------------------------------
-- |--------------------------------< ptd_ec >--------------------------------|
-- ----------------------------------------------------------------------------
procedure ptd_ec(
	p_owner_payroll_action_id	in number,
	p_user_payroll_action_id	in number,
	p_owner_assignment_action_id	in number,
	p_user_assignment_action_id	in number,
	p_owner_effective_date		in date,
	p_user_effective_date		in date,
	p_dimension_name		in varchar2,
	p_expiry_information		out nocopy number)
is
	c_proc			constant varchar2(61) := c_package || 'ptd_ec';
	--
	l_owner_time_period_id	number;
	l_user_time_period_id	number;
begin
	hr_utility.set_location('Entering : ' || c_proc, 10);
	hr_utility.trace(p_dimension_name);
	--
	select	ppa_owner.time_period_id,
		ppa_user.time_period_id
	into	l_owner_time_period_id,
		l_user_time_period_id
	from	pay_payroll_actions	ppa_user,
		pay_payroll_actions	ppa_owner
	where	ppa_owner.payroll_action_id = p_owner_payroll_action_id
	and	ppa_user.payroll_action_id = p_user_payroll_action_id;
	--
	-- Note this expiry checking mechanism has bug.2646992
	--
	if l_user_time_period_id = l_owner_time_period_id then
		hr_utility.trace('NOT expired');
		p_expiry_information := 0;
	else
		hr_utility.trace('expired');
		p_expiry_information := 1;
	end if;
	--
	hr_utility.set_location('Leaving : ' || c_proc, 20);
end ptd_ec;
-- ----------------------------------------------------------------------------
-- |--------------------------< ptd_ec (date mode)>---------------------------|
-- ----------------------------------------------------------------------------
procedure ptd_ec(
	p_owner_payroll_action_id	in number,
	p_user_payroll_action_id	in number,
	p_owner_assignment_action_id	in number,
	p_user_assignment_action_id	in number,
	p_owner_effective_date		in date,
	p_user_effective_date		in date,
	p_dimension_name		in varchar2,
	p_expiry_information		out nocopy date)
is
	c_proc			constant varchar2(61) := c_package || 'ptd_ec (date mode)';
	--
--	l_owner_time_period_id	number;
--	l_user_time_period_id	number;
begin
	hr_utility.set_location('Entering : ' || c_proc, 10);
	--
	select	ptp.end_date
	into	p_expiry_information
	from	pay_payroll_actions	ppa,
		per_time_periods	ptp
	where	ppa.payroll_action_id = p_owner_payroll_action_id
	and	ptp.time_period_id = ppa.time_period_id;
/*
	--
	-- Note this expiry checking mechanism has bug.2646992
	--
	-- We do not support the payroll change and back to the same payroll
	-- within the same payroll period. For example,
	-- Payroll A --> Payroll B --> Payroll A in January for an assignment.
	-- If you do this, the latest balance will get corrupted.
	--
	-- Date mode expiry checking is called with the same payroll_action_id,
	-- assignment_action_id and effective_date, which means
	--   p_owner_payroll_action_id    = p_user_payroll_action_id
	--   p_owner_assignment_action_id = p_user_payroll_action_id
	--   p_owner_effective_date       = p_user_effective_date
	-- This expiry checking is called for both owner and user payroll action,
	-- then the expiry_date is compared.
	--
	hr_utility.trace(p_dimension_name);
	hr_utility.trace('owner_payroll_action_id    : ' || to_char(p_owner_payroll_action_id));
	hr_utility.trace('user_payroll_action_id     : ' || to_char(p_user_payroll_action_id));
	hr_utility.trace('owner_assignment_action_id : ' || to_char(p_owner_assignment_action_id));
	hr_utility.trace('user_assignment_action_id  : ' || to_char(p_user_assignment_action_id));
	hr_utility.trace('owner_effective_date       : ' || to_char(p_owner_effective_date));
	hr_utility.trace('user_effective_date        : ' || to_char(p_user_effective_date));
	--
	-- Following SQL will return period end date in general.
	-- But the payroll is changed in the middle of the payroll period,
	-- this returns the previous date of the date changed.
	--
	select	least(max(asg.effective_end_date), ptp_owner.end_date)
	into	p_expiry_information
	from	per_all_assignments_f	asg,
		per_time_periods	ptp_owner,
		pay_payroll_actions	ppa_owner,
		pay_assignment_actions	paa_owner
	where	paa_owner.assignment_action_id = p_owner_assignment_action_id
	and	ppa_owner.payroll_action_id = p_owner_payroll_action_id
	and	ptp_owner.time_period_id = ppa_owner.time_period_id
	and	asg.assignment_id = paa_owner.assignment_id
	and	asg.effective_end_date >= p_owner_effective_date
	and	asg.effective_start_date <= ptp_owner.end_date
	and	asg.payroll_id + 0 = ppa_owner.payroll_id
	group by ptp_owner.end_date;
*/
/*
	select	ppa_owner.time_period_id,
		ppa_user.time_period_id
	into	l_owner_time_period_id,
		l_user_time_period_id
	from	per_time_periods	ptp_user,
		pay_payroll_actions	ppa_user,
		per_time_periods	ptp_owner,
		pay_payroll_actions	ppa_owner
	where	ppa_owner.payroll_action_id = p_owner_payroll_action_id
	and	ptp_owner.time_period_id = ppa_owner.time_period_id
	and	ppa_user.payroll_action_id = p_user_payroll_action_id
	and	ptp_user.time_period_id = ppa_user.time_period_id;
	--
	-- We do not need to return the accurate expiry date here.
	-- This expiry_date is used as follows.
	-- 1) expiry_date is greater equal owner_effective_date, or less than owner_effective_date
	-- 2) expiry_date is greater equal user_effective_date, or less than user_effective_date
	-- Note always p_user_effective_date >= p_owner_effective_date.
	--
	if l_owner_time_period_id <> l_user_time_period_id then
		p_expiry_information := p_owner_effective_date;
	else
		p_expiry_information := p_user_effective_date;
	end if;
*/
	--
	hr_utility.trace('expiry_date : ' || to_char(p_expiry_information));
	hr_utility.set_location('Leaving : ' || c_proc, 20);
end ptd_ec;
-- ----------------------------------------------------------------------------
-- |--------------------------------< mtd_ec >--------------------------------|
-- ----------------------------------------------------------------------------
procedure mtd_ec(
	p_owner_payroll_action_id	in number,
	p_user_payroll_action_id	in number,
	p_owner_assignment_action_id	in number,
	p_user_assignment_action_id	in number,
	p_owner_effective_date		in date,
	p_user_effective_date		in date,
	p_dimension_name		in varchar2,
	p_expiry_information		out nocopy number)
is
	c_proc	constant varchar2(61) := c_package || 'mtd_ec';
begin
	hr_utility.set_location('Entering : ' || c_proc, 10);
	hr_utility.trace(p_dimension_name);
	--
	if trunc(p_user_effective_date, 'MM') > p_owner_effective_date then
		hr_utility.trace('expired');
		p_expiry_information := 1;
	else
		hr_utility.trace('NOT expired');
		p_expiry_information := 0;
	end if;
	--
	hr_utility.set_location('Leaving : ' || c_proc, 20);
end mtd_ec;
-- ----------------------------------------------------------------------------
-- |--------------------------< mtd_ec (date mode)>---------------------------|
-- ----------------------------------------------------------------------------
procedure mtd_ec(
	p_owner_payroll_action_id	in number,
	p_user_payroll_action_id	in number,
	p_owner_assignment_action_id	in number,
	p_user_assignment_action_id	in number,
	p_owner_effective_date		in date,
	p_user_effective_date		in date,
	p_dimension_name		in varchar2,
	p_expiry_information		out nocopy date)
is
	c_proc	constant varchar2(61) := c_package || 'mtd_ec (date mode)';
begin
	hr_utility.set_location('Entering : ' || c_proc, 10);
	hr_utility.trace(p_dimension_name);
	--
	p_expiry_information := last_day(p_owner_effective_date);
	hr_utility.trace('owner_date  : ' || to_char(p_owner_effective_date));
	hr_utility.trace('expiry_date : ' || to_char(p_expiry_information));
	--
	hr_utility.set_location('Leaving : ' || c_proc, 20);
end mtd_ec;
-- ----------------------------------------------------------------------------
-- |--------------------------------< qtd_ec >--------------------------------|
-- ----------------------------------------------------------------------------
procedure qtd_ec(
	p_owner_payroll_action_id	in number,
	p_user_payroll_action_id	in number,
	p_owner_assignment_action_id	in number,
	p_user_assignment_action_id	in number,
	p_owner_effective_date		in date,
	p_user_effective_date		in date,
	p_dimension_name		in varchar2,
	p_expiry_information		out nocopy number)
is
	c_proc	constant varchar2(61) := c_package || 'qtd_ec';
begin
	hr_utility.set_location('Entering : ' || c_proc, 10);
	hr_utility.trace(p_dimension_name);
	--
	if trunc(p_user_effective_date, 'Q') > p_owner_effective_date then
		hr_utility.trace('expired');
		p_expiry_information := 1;
	else
		hr_utility.trace('NOT expired');
		p_expiry_information := 0;
	end if;
	--
	hr_utility.set_location('Leaving : ' || c_proc, 20);
end qtd_ec;
-- ----------------------------------------------------------------------------
-- |--------------------------< qtd_ec (date mode)>---------------------------|
-- ----------------------------------------------------------------------------
procedure qtd_ec(
	p_owner_payroll_action_id	in number,
	p_user_payroll_action_id	in number,
	p_owner_assignment_action_id	in number,
	p_user_assignment_action_id	in number,
	p_owner_effective_date		in date,
	p_user_effective_date		in date,
	p_dimension_name		in varchar2,
	p_expiry_information		out nocopy date)
is
	c_proc	constant varchar2(61) := c_package || 'qtd_ec (date mode)';
begin
	hr_utility.set_location('Entering : ' || c_proc, 10);
	hr_utility.trace(p_dimension_name);
	--
	p_expiry_information := add_months(trunc(p_owner_effective_date, 'Q'), 3) - 1;
	hr_utility.trace('owner_date  : ' || to_char(p_owner_effective_date));
	hr_utility.trace('expiry_date : ' || to_char(p_expiry_information));
	--
	hr_utility.set_location('Leaving : ' || c_proc, 20);
end qtd_ec;
-- ----------------------------------------------------------------------------
-- |--------------------------------< ytd_ec >--------------------------------|
-- ----------------------------------------------------------------------------
procedure ytd_ec(
	p_owner_payroll_action_id	in number,
	p_user_payroll_action_id	in number,
	p_owner_assignment_action_id	in number,
	p_user_assignment_action_id	in number,
	p_owner_effective_date		in date,
	p_user_effective_date		in date,
	p_dimension_name		in varchar2,
	p_expiry_information		out nocopy number)
is
	c_proc	constant varchar2(61) := c_package || 'ytd_ec';
begin
	hr_utility.set_location('Entering : ' || c_proc, 10);
	hr_utility.trace(p_dimension_name);
	--
	if trunc(p_user_effective_date, 'YYYY') > p_owner_effective_date then
		hr_utility.trace('expired');
		p_expiry_information := 1;
	else
		hr_utility.trace('NOT expired');
		p_expiry_information := 0;
	end if;
	--
	hr_utility.set_location('Leaving : ' || c_proc, 20);
end ytd_ec;
-- ----------------------------------------------------------------------------
-- |--------------------------< ytd_ec (date mode)>---------------------------|
-- ----------------------------------------------------------------------------
procedure ytd_ec(
	p_owner_payroll_action_id	in number,
	p_user_payroll_action_id	in number,
	p_owner_assignment_action_id	in number,
	p_user_assignment_action_id	in number,
	p_owner_effective_date		in date,
	p_user_effective_date		in date,
	p_dimension_name		in varchar2,
	p_expiry_information		out nocopy date)
is
	c_proc	constant varchar2(61) := c_package || 'ytd_ec (date mode)';
begin
	hr_utility.set_location('Entering : ' || c_proc, 10);
	hr_utility.trace(p_dimension_name);
	--
	p_expiry_information := add_months(trunc(p_owner_effective_date, 'YYYY'), 12) - 1;
	hr_utility.trace('owner_date  : ' || to_char(p_owner_effective_date));
	hr_utility.trace('expiry_date : ' || to_char(p_expiry_information));
	--
	hr_utility.set_location('Leaving : ' || c_proc, 20);
end ytd_ec;
-- ----------------------------------------------------------------------------
-- |-------------------------------< aprtd_ec >-------------------------------|
-- ----------------------------------------------------------------------------
procedure aprtd_ec(
	p_owner_payroll_action_id	in number,
	p_user_payroll_action_id	in number,
	p_owner_assignment_action_id	in number,
	p_user_assignment_action_id	in number,
	p_owner_effective_date		in date,
	p_user_effective_date		in date,
	p_dimension_name		in varchar2,
	p_expiry_information		out nocopy number)
is
	c_proc		constant varchar2(61) := c_package || 'aprtd_ec';
begin
	hr_utility.set_location('Entering : ' || c_proc, 10);
	hr_utility.trace(p_dimension_name);
	--
	if add_months(trunc(add_months(p_user_effective_date, 9), 'YYYY'), -9) > p_owner_effective_date then
		hr_utility.trace('expired');
		p_expiry_information := 1;
	else
		hr_utility.trace('NOT expired');
		p_expiry_information := 0;
	end if;
	--
	hr_utility.set_location('Leaving : ' || c_proc, 20);
end aprtd_ec;
-- ----------------------------------------------------------------------------
-- |-------------------------< aprtd_ec (date mode)>--------------------------|
-- ----------------------------------------------------------------------------
procedure aprtd_ec(
	p_owner_payroll_action_id	in number,
	p_user_payroll_action_id	in number,
	p_owner_assignment_action_id	in number,
	p_user_assignment_action_id	in number,
	p_owner_effective_date		in date,
	p_user_effective_date		in date,
	p_dimension_name		in varchar2,
	p_expiry_information		out nocopy date)
is
	c_proc		constant varchar2(61) := c_package || 'aprtd_ec (date mode)';
begin
	hr_utility.set_location('Entering : ' || c_proc, 10);
	hr_utility.trace(p_dimension_name);
	--
	p_expiry_information := add_months(trunc(add_months(p_owner_effective_date, 9), 'YYYY'), 3) - 1;
	hr_utility.trace('owner_date  : ' || to_char(p_owner_effective_date));
	hr_utility.trace('expiry_date : ' || to_char(p_expiry_information));
	--
	hr_utility.set_location('Leaving : ' || c_proc, 20);
end aprtd_ec;
-- ----------------------------------------------------------------------------
-- |-------------------------------< aprtd_sd >-------------------------------|
-- ----------------------------------------------------------------------------
procedure aprtd_sd(
	p_effective_date		in date,
	p_start_date			out nocopy date,
	p_payroll_id			in number,
	p_bus_grp			in number,
	p_asg_action			in number)
is
	c_proc		constant varchar2(61) := c_package || 'aprtd_sd';
begin
	hr_utility.set_location('Entering : ' || c_proc, 10);
	--
	p_start_date := add_months(trunc(add_months(p_effective_date, 9), 'YYYY'), -9);
	hr_utility.trace('start_date : ' || to_char(p_start_date));
	--
	hr_utility.set_location('Leaving : ' || c_proc, 20);
end aprtd_sd;
-- ----------------------------------------------------------------------------
-- |-------------------------------< jultd_ec >-------------------------------|
-- ----------------------------------------------------------------------------
procedure jultd_ec(
	p_owner_payroll_action_id	in number,
	p_user_payroll_action_id	in number,
	p_owner_assignment_action_id	in number,
	p_user_assignment_action_id	in number,
	p_owner_effective_date		in date,
	p_user_effective_date		in date,
	p_dimension_name		in varchar2,
	p_expiry_information		out nocopy number)
is
	c_proc		constant varchar2(61) := c_package || 'jultd_ec';
begin
	hr_utility.set_location('Entering : ' || c_proc, 10);
	hr_utility.trace(p_dimension_name);
	--
	if add_months(trunc(add_months(p_user_effective_date, 6), 'YYYY'), -6) > p_owner_effective_date then
		hr_utility.trace('expired');
		p_expiry_information := 1;
	else
		hr_utility.trace('NOT expired');
		p_expiry_information := 0;
	end if;
	--
	hr_utility.set_location('Leaving : ' || c_proc, 20);
end jultd_ec;
-- ----------------------------------------------------------------------------
-- |-------------------------< jultd_ec (date mode)>--------------------------|
-- ----------------------------------------------------------------------------
procedure jultd_ec(
	p_owner_payroll_action_id	in number,
	p_user_payroll_action_id	in number,
	p_owner_assignment_action_id	in number,
	p_user_assignment_action_id	in number,
	p_owner_effective_date		in date,
	p_user_effective_date		in date,
	p_dimension_name		in varchar2,
	p_expiry_information		out nocopy date)
is
	c_proc		constant varchar2(61) := c_package || 'jultd_ec (date mode)';
begin
	hr_utility.set_location('Entering : ' || c_proc, 10);
	hr_utility.trace(p_dimension_name);
	--
	p_expiry_information := add_months(trunc(add_months(p_owner_effective_date, 6), 'YYYY'), 6) - 1;
	hr_utility.trace('owner_date  : ' || to_char(p_owner_effective_date));
	hr_utility.trace('expiry_date : ' || to_char(p_expiry_information));
	--
	hr_utility.set_location('Leaving : ' || c_proc, 20);
end jultd_ec;
-- ----------------------------------------------------------------------------
-- |-------------------------------< jultd_sd >-------------------------------|
-- ----------------------------------------------------------------------------
procedure jultd_sd(
	p_effective_date		in date,
	p_start_date			out nocopy date,
	p_payroll_id			in number,
	p_bus_grp			in number,
	p_asg_action			in number)
is
	c_proc		constant varchar2(61) := c_package || 'jultd_sd';
begin
	hr_utility.set_location('Entering : ' || c_proc, 10);
	--
	p_start_date := add_months(trunc(add_months(p_effective_date, 6), 'YYYY'), -6);
	hr_utility.trace('start_date : ' || to_char(p_start_date));
	--
	hr_utility.set_location('Leaving : ' || c_proc, 20);
end jultd_sd;
-- ----------------------------------------------------------------------------
-- |-------------------------------< augtd_ec >-------------------------------|
-- ----------------------------------------------------------------------------
procedure augtd_ec(
	p_owner_payroll_action_id	in number,
	p_user_payroll_action_id	in number,
	p_owner_assignment_action_id	in number,
	p_user_assignment_action_id	in number,
	p_owner_effective_date		in date,
	p_user_effective_date		in date,
	p_dimension_name		in varchar2,
	p_expiry_information		out nocopy number)
is
	c_proc		constant varchar2(61) := c_package || 'augtd_ec';
begin
	hr_utility.set_location('Entering : ' || c_proc, 10);
	hr_utility.trace(p_dimension_name);
	--
	if add_months(trunc(add_months(p_user_effective_date, 5), 'YYYY'), -5) > p_owner_effective_date then
		hr_utility.trace('expired');
		p_expiry_information := 1;
	else
		hr_utility.trace('NOT expired');
		p_expiry_information := 0;
	end if;
	--
	hr_utility.set_location('Leaving : ' || c_proc, 20);
end augtd_ec;
-- ----------------------------------------------------------------------------
-- |-------------------------< augtd_ec (date mode)>--------------------------|
-- ----------------------------------------------------------------------------
procedure augtd_ec(
	p_owner_payroll_action_id	in number,
	p_user_payroll_action_id	in number,
	p_owner_assignment_action_id	in number,
	p_user_assignment_action_id	in number,
	p_owner_effective_date		in date,
	p_user_effective_date		in date,
	p_dimension_name		in varchar2,
	p_expiry_information		out nocopy date)
is
	c_proc		constant varchar2(61) := c_package || 'augtd_ec (date mode)';
begin
	hr_utility.set_location('Entering : ' || c_proc, 10);
	hr_utility.trace(p_dimension_name);
	--
	p_expiry_information := add_months(trunc(add_months(p_owner_effective_date, 5), 'YYYY'), 7) - 1;
	hr_utility.trace('owner_date  : ' || to_char(p_owner_effective_date));
	hr_utility.trace('expiry_date : ' || to_char(p_expiry_information));
	--
	hr_utility.set_location('Leaving : ' || c_proc, 20);
end augtd_ec;
-- ----------------------------------------------------------------------------
-- |-------------------------------< augtd_sd >-------------------------------|
-- ----------------------------------------------------------------------------
procedure augtd_sd(
	p_effective_date		in date,
	p_start_date			out nocopy date,
	p_payroll_id			in number,
	p_bus_grp			in number,
	p_asg_action			in number)
is
	c_proc		constant varchar2(61) := c_package || 'augtd_sd';
begin
	hr_utility.set_location('Entering : ' || c_proc, 10);
	--
	p_start_date := add_months(trunc(add_months(p_effective_date, 5), 'YYYY'), -5);
	hr_utility.trace('start_date : ' || to_char(p_start_date));
	--
	hr_utility.set_location('Leaving : ' || c_proc, 20);
end augtd_sd;
-- ----------------------------------------------------------------------------
-- |----------------------------< fy_start_date >-----------------------------|
-- ----------------------------------------------------------------------------
function fy_start_date(p_business_group_id in number) return date
is
	c_proc		constant varchar2(61) := c_package || 'fy_start_date';
	--
	l_fy_start_date	date;
	cursor csr_fy_start_date(p_business_group_id number) is
		select	fnd_date.canonical_to_date(org_information11)
		from	hr_organization_information
		where	organization_id = p_business_group_id
		and	org_information_context = 'Business Group Information';
begin
	hr_utility.set_location('Entering : ' || c_proc, 10);
	--
	-- Once the fiscal year is derived from BG, the value is stored
	-- in global variables to reduce the overhead.
	--
	if p_business_group_id = g_fy_cache.business_group_id then
		hr_utility.trace('cache available');
		l_fy_start_date := g_fy_cache.start_date;
	else
		hr_utility.trace('cache NOT available');
		--
		open csr_fy_start_date(p_business_group_id);
		fetch csr_fy_start_date into l_fy_start_date;
		close csr_fy_start_date;
		--
		-- Cache the fiscal year start date of current business group
		--
		if l_fy_start_date is not null then
			g_fy_cache.business_group_id	:= p_business_group_id;
			g_fy_cache.start_date		:= l_fy_start_date;
		end if;
	end if;
	--
	hr_utility.trace('fy_start_date : ' || to_char(l_fy_start_date));
	hr_utility.set_location('Leaving : ' || c_proc, 20);
	--
	return l_fy_start_date;
end fy_start_date;
-- ----------------------------------------------------------------------------
-- |--------------------------< business_group_id >---------------------------|
-- ----------------------------------------------------------------------------
function business_group_id(p_payroll_action_id in number) return number
is
	c_proc			constant varchar2(61) := c_package || 'business_group_id';
	--
	l_business_group_id	number;
begin
	hr_utility.set_location('Entering : ' || c_proc, 10);
	--
	if p_payroll_action_id = g_pact_cache.payroll_action_id then
		hr_utility.trace('cache available');
		l_business_group_id := g_pact_cache.business_group_id;
	else
		hr_utility.trace('cache NOT available');
		--
		select	business_group_id
		into	l_business_group_id
		from	pay_payroll_actions
		where	payroll_action_id = p_payroll_action_id;
		--
		-- Cache the business_group_id of current payroll action
		--
		g_pact_cache.payroll_action_id	:= p_payroll_action_id;
		g_pact_cache.business_group_id	:= l_business_group_id;
	end if;
	--
	hr_utility.set_location('Leaving : ' || c_proc, 20);
	--
	return l_business_group_id;
end business_group_id;
-- ----------------------------------------------------------------------------
-- |-------------------------------< fqtd_ec >--------------------------------|
-- ----------------------------------------------------------------------------
procedure fqtd_ec(
	p_owner_payroll_action_id	in number,
	p_user_payroll_action_id	in number,
	p_owner_assignment_action_id	in number,
	p_user_assignment_action_id	in number,
	p_owner_effective_date		in date,
	p_user_effective_date		in date,
	p_dimension_name		in varchar2,
	p_expiry_information		out nocopy number)
is
	c_proc		constant varchar2(61) := c_package || 'fqtd_ec';
	--
	l_fy_start_date	date;
	l_start_date	date;
begin
	hr_utility.set_location('Entering : ' || c_proc, 10);
	hr_utility.trace(p_dimension_name);
	--
	-- Bind p_user_payroll_action_id not p_owner_payroll_action_id
	-- to use cache as much as possible.
	--
	l_fy_start_date := fy_start_date(business_group_id(p_user_payroll_action_id));
	l_start_date := add_months(l_fy_start_date, floor(months_between(p_user_effective_date, l_fy_start_date) / 3) * 3);
	--
	if l_start_date > p_owner_effective_date then
		hr_utility.trace('expired');
		p_expiry_information := 1;
	else
		hr_utility.trace('NOT expired');
		p_expiry_information := 0;
	end if;
	--
	hr_utility.set_location('Leaving : ' || c_proc, 20);
end fqtd_ec;
-- ----------------------------------------------------------------------------
-- |--------------------------< fqtd_ec (date mode)>--------------------------|
-- ----------------------------------------------------------------------------
procedure fqtd_ec(
	p_owner_payroll_action_id	in number,
	p_user_payroll_action_id	in number,
	p_owner_assignment_action_id	in number,
	p_user_assignment_action_id	in number,
	p_owner_effective_date		in date,
	p_user_effective_date		in date,
	p_dimension_name		in varchar2,
	p_expiry_information		out nocopy date)
is
	c_proc		constant varchar2(61) := c_package || 'fqtd_ec (date mode)';
	--
	l_fy_start_date	date;
begin
	hr_utility.set_location('Entering : ' || c_proc, 10);
	hr_utility.trace(p_dimension_name);
	--
	l_fy_start_date := fy_start_date(business_group_id(p_owner_payroll_action_id));
	p_expiry_information := add_months(l_fy_start_date, (floor(months_between(p_owner_effective_date, l_fy_start_date) / 3) + 1) * 3) - 1;
	--
	hr_utility.trace('owner_date  : ' || to_char(p_owner_effective_date));
	hr_utility.trace('expiry_date : ' || to_char(p_expiry_information));
	--
	hr_utility.set_location('Leaving : ' || c_proc, 20);
end fqtd_ec;
-- ----------------------------------------------------------------------------
-- |-------------------------------< fytd_ec >--------------------------------|
-- ----------------------------------------------------------------------------
procedure fytd_ec(
	p_owner_payroll_action_id	in number,
	p_user_payroll_action_id	in number,
	p_owner_assignment_action_id	in number,
	p_user_assignment_action_id	in number,
	p_owner_effective_date		in date,
	p_user_effective_date		in date,
	p_dimension_name		in varchar2,
	p_expiry_information		out nocopy number)
is
	c_proc		constant varchar2(61) := c_package || 'fytd_ec';
	--
	l_fy_start_date	date;
	l_start_date	date;
begin
	hr_utility.set_location('Entering : ' || c_proc, 10);
	hr_utility.trace(p_dimension_name);
	--
	l_fy_start_date := fy_start_date(business_group_id(p_user_payroll_action_id));
	l_start_date := add_months(l_fy_start_date, floor(months_between(p_user_effective_date, l_fy_start_date) / 12) * 12);
	--
	if l_start_date > p_owner_effective_date then
		hr_utility.trace('expired');
		p_expiry_information := 1;
	else
		hr_utility.trace('NOT expired');
		p_expiry_information := 0;
	end if;
	--
	hr_utility.set_location('Leaving : ' || c_proc, 20);
end fytd_ec;
-- ----------------------------------------------------------------------------
-- |--------------------------< fytd_ec (date mode)>--------------------------|
-- ----------------------------------------------------------------------------
procedure fytd_ec(
	p_owner_payroll_action_id	in number,
	p_user_payroll_action_id	in number,
	p_owner_assignment_action_id	in number,
	p_user_assignment_action_id	in number,
	p_owner_effective_date		in date,
	p_user_effective_date		in date,
	p_dimension_name		in varchar2,
	p_expiry_information		out nocopy date)
is
	c_proc		constant varchar2(61) := c_package || 'fytd_ec (date mode)';
	--
	l_fy_start_date	date;
begin
	hr_utility.set_location('Entering : ' || c_proc, 10);
	hr_utility.trace(p_dimension_name);
	--
	l_fy_start_date := fy_start_date(business_group_id(p_owner_payroll_action_id));
	p_expiry_information := add_months(l_fy_start_date, (floor(months_between(p_owner_effective_date, l_fy_start_date) / 12) + 1) * 12) - 1;
	--
	hr_utility.trace('owner_date  : ' || to_char(p_owner_effective_date));
	hr_utility.trace('expiry_date : ' || to_char(p_expiry_information));
	--
	hr_utility.set_location('Leaving : ' || c_proc, 20);
end fytd_ec;
-- ----------------------------------------------------------------------------
-- |---------------------------< show_dim_periods >---------------------------|
-- ----------------------------------------------------------------------------
-- This procedure checks the period in which the date from p_start_date to
-- p_end_date falls is continuous and date is really within the period.
-- This is for debugging purpose.
-- Currently, this procedure support the following dimensions.
--   1) FYTD
--   2) User Defined Dimensions
--
/*
procedure show_dim_periods(
	p_business_group_id		in number,
	p_dimension_name		in varchar2,
	p_start_date			in date,
	p_end_date			in date)
is
	l_date			date;
	l_start_date		date;
	l_end_date		date;
	l_text			varchar2(255);
	l_first_period		boolean := true;
	l_prev_start_date	date;
	l_prev_end_date		date;
begin
	fnd_file.put_line(fnd_file.output, 'Dimension :' || p_dimension_name);
	fnd_file.put_line(fnd_file.output, 'Start Date:' || to_char(p_start_date));
	fnd_file.put_line(fnd_file.output, 'End Date  :' || to_char(p_end_date));
	fnd_file.new_line(fnd_file.output);
	fnd_file.put_line(fnd_file.output, 'Year Start Date  End Date');
	fnd_file.put_line(fnd_file.output, '---- ----------- -----------');
	--
	l_date := p_start_date;
	while l_date <= p_end_date loop
		if p_dimension_name = c_fytd then
			--
			-- Here does not use cache which is easier to debug in the same session.
			--
			fiscal_year_period(l_date, fiscal_year_start_date(p_business_group_id, false), l_start_date, l_end_date);
		else
			user_reg_period(p_dimension_name, l_date, l_start_date, l_end_date);
		end if;
		--
		-- Validate whether the effective_date is really within the period
		-- and the period is continuous or not.
		--
		if (l_start_date is null) or (l_end_date is null) then
			fnd_message.set_name('PAY', 'PAY_JP_DIM_PERIOD_NULL');
			fnd_message.set_token('DIMENSION_NAME', p_dimension_name);
			fnd_message.set_token('EFFECTIVE_DATE', fnd_date.date_to_chardate(l_date));
			fnd_message.set_token('START_DATE', fnd_date.date_to_chardate(l_start_date));
			fnd_message.set_token('END_DATE', fnd_date.date_to_chardate(l_end_date));
			fnd_message.raise_error;
		elsif l_date not between l_start_date and l_end_date then
			fnd_message.set_name('PAY', 'PAY_JP_DIM_DATE_OUT_OF_PERIOD');
			fnd_message.set_token('DIMENSION_NAME', p_dimension_name);
			fnd_message.set_token('EFFECTIVE_DATE', fnd_date.date_to_chardate(l_date));
			fnd_message.set_token('START_DATE', fnd_date.date_to_chardate(l_start_date));
			fnd_message.set_token('END_DATE', fnd_date.date_to_chardate(l_end_date));
			fnd_message.raise_error;
		elsif ((l_prev_start_date <> l_start_date) or (l_prev_end_date <> l_end_date))
		  and ((l_start_date <> l_prev_end_date + 1) or (l_start_date <> l_date)) then
			fnd_message.set_name('PAY', 'PAY_JP_DIM_PERIOD_NOT_CONT');
			fnd_message.set_token('DIMENSION_NAME', p_dimension_name);
			fnd_message.set_token('EFFECTIVE_DATE', fnd_date.date_to_chardate(l_date));
			fnd_message.set_token('START_DATE', fnd_date.date_to_chardate(l_start_date));
			fnd_message.set_token('END_DATE', fnd_date.date_to_chardate(l_end_date));
			fnd_message.set_token('PREV_START_DATE', fnd_date.date_to_chardate(l_prev_start_date));
			fnd_message.set_token('PREV_END_DATE', fnd_date.date_to_chardate(l_prev_end_date));
			fnd_message.raise_error;
		end if;
		--
		-- Output period date range if the current date is in the end of the period
		--
		if (l_date = l_end_date)
		or (l_date = p_end_date) then
			--
			-- Write down "Year" if the period is the first period in the year.
			--
			if (l_first_period)
			or (trunc(l_start_date, 'YYYY') = l_start_date)
			or (to_char(l_start_date, 'YYYY') <> to_char(l_end_date, 'YYYY')) then
				l_text := to_char(l_end_date, 'YYYY');
			else
				l_text := '    ';
			end if;
			l_first_period := false;
			--
			l_text := l_text || ' ' || rpad(to_char(l_start_date), 11) || ' ' || to_char(l_end_date);
			--
			fnd_file.put_line(fnd_file.output, l_text);
		end if;
		--
		l_prev_start_date	:= l_start_date;
		l_prev_end_date		:= l_end_date;
		l_date			:= l_date + 1;
	end loop;
end show_dim_periods;
*/
--
--begin
--	hr_utility.trace_on('F', 'TTAGAWA');
end pyjpexc;

/
