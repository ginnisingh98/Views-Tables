--------------------------------------------------------
--  DDL for Package Body PAY_JP_BALANCE_VIEW_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_JP_BALANCE_VIEW_PKG" as
/* $Header: pyjpbalv.pkb 120.0 2006/04/24 00:03 ttagawa noship $ */
--
-- Global Variables
--
type t_assignment_rec is record(
	assignment_id		number,
	effective_date		date,
	business_group_id	number,
	payroll_id		number,
	time_period_id		number);
g_assignment_rec	t_assignment_rec;
--
type t_defined_balance_rec is record(
	defined_balance_id	number,
	balance_type_id		number,
	dimension_name		pay_balance_dimensions.dimension_name%type,
	business_group_id	number,
	dimension_level		pay_balance_dimensions.dimension_level%type,
	date_type		varchar2(30),
	period_type		pay_balance_dimensions.period_type%type,
	start_date_code		pay_balance_dimensions.start_date_code%type);
g_defined_balance_rec	t_defined_balance_rec;
-- ----------------------------------------------------------------------------
-- |-------------------------< get_assignment_info >--------------------------|
-- ----------------------------------------------------------------------------
procedure get_assignment_info(
	p_assignment_id		in number,
	p_effective_date	in date,
	p_assignment_rec	out nocopy t_assignment_rec)
is
	l_assignment_rec	t_assignment_rec;
begin
	if  g_assignment_rec.assignment_id = p_assignment_id
	and g_assignment_rec.effective_date = p_effective_date then
		null;
	else
		select	asg.business_group_id,
			asg.payroll_id,
			ptp.time_period_id
		into	l_assignment_rec.business_group_id,
			l_assignment_rec.payroll_id,
			l_assignment_rec.time_period_id
		from	per_all_assignments_f	asg,
			per_time_periods	ptp
		where	asg.assignment_id = p_assignment_id
		and	p_effective_date
			between asg.effective_start_date and asg.effective_end_date
		and	ptp.payroll_id(+) = asg.payroll_id
		and	p_effective_date
			between ptp.start_date(+) and ptp.end_date(+);
		--
		l_assignment_rec.assignment_id	:= p_assignment_id;
		l_assignment_rec.effective_date	:= p_effective_date;
		g_assignment_rec := l_assignment_rec;
	end if;
	--
	p_assignment_rec := g_assignment_rec;
end get_assignment_info;
-- ----------------------------------------------------------------------------
-- |-----------------------< get_defined_balance_info >-----------------------|
-- ----------------------------------------------------------------------------
procedure get_defined_balance_info(
	p_balance_type_id	in number,
	p_dimension_name	in varchar2,
	p_business_group_id	in number,
	p_defined_balance_rec	out nocopy t_defined_balance_rec)
is
	l_legislation_code	pay_defined_balances.legislation_code%type;
	l_defined_balance_rec	t_defined_balance_rec;
begin
	l_legislation_code := hr_api.return_legislation_code(p_business_group_id);
	--
	if  g_defined_balance_rec.balance_type_id = p_balance_type_id
	and g_defined_balance_rec.dimension_name = p_dimension_name
	and g_defined_balance_rec.business_group_id = p_business_group_id then
		null;
	else
		begin
			select	def.defined_balance_id,
				dim.dimension_level,
				pay_core_utils.get_parameter('DATE_TYPE', dim.description),
				dim.period_type,
				dim.start_date_code
			into	l_defined_balance_rec.defined_balance_id,
				l_defined_balance_rec.dimension_level,
				l_defined_balance_rec.date_type,
				l_defined_balance_rec.period_type,
				l_defined_balance_rec.start_date_code
			from	pay_defined_balances	def,
				pay_balance_dimensions	dim
			where	def.balance_type_id = p_balance_type_id
			and	nvl(def.business_group_id, p_business_group_id) = p_business_group_id
			and	nvl(def.legislation_code, l_legislation_code) = l_legislation_code
			and	dim.balance_dimension_id = def.balance_dimension_id
			and	dim.dimension_name = p_dimension_name;
			--
			l_defined_balance_rec.balance_type_id	:= p_balance_type_id;
			l_defined_balance_rec.dimension_name	:= p_dimension_name;
			l_defined_balance_rec.business_group_id	:= p_business_group_id;
			--
			g_defined_balance_rec := l_defined_balance_rec;
		exception
			when no_data_found then
				return;
		end;
	end if;
	--
	p_defined_balance_rec := g_defined_balance_rec;
end get_defined_balance_info;
-- ----------------------------------------------------------------------------
-- |-----------------------< get_defined_balance_info >-----------------------|
-- ----------------------------------------------------------------------------
procedure get_defined_balance_info(
	p_defined_balance_id	in number,
	p_defined_balance_rec	out nocopy t_defined_balance_rec)
is
	l_defined_balance_rec	t_defined_balance_rec;
begin
	if  g_defined_balance_rec.defined_balance_id = p_defined_balance_id then
		null;
	else
		begin
			select	def.balance_type_id,
				dim.dimension_name,
				def.business_group_id,
				dim.dimension_level,
				pay_core_utils.get_parameter('DATE_TYPE', dim.description),
				dim.period_type,
				dim.start_date_code
			into	l_defined_balance_rec.balance_type_id,
				l_defined_balance_rec.dimension_name,
				l_defined_balance_rec.business_group_id,
				l_defined_balance_rec.dimension_level,
				l_defined_balance_rec.date_type,
				l_defined_balance_rec.period_type,
				l_defined_balance_rec.start_date_code
			from	pay_defined_balances	def,
				pay_balance_dimensions	dim
			where	def.defined_balance_id = p_defined_balance_id
			and	dim.balance_dimension_id = def.balance_dimension_id;
			--
			l_defined_balance_rec.defined_balance_id := p_defined_balance_id;
			--
			g_defined_balance_rec := l_defined_balance_rec;
		exception
			when no_data_found then
				null;
		end;
	end if;
	--
	p_defined_balance_rec := g_defined_balance_rec;
end get_defined_balance_info;
-- ----------------------------------------------------------------------------
-- |-------------------------< get_latest_action_id >-------------------------|
-- ----------------------------------------------------------------------------
function get_latest_action_id(
	p_assignment_id		in number,
	p_effective_date	in date,
	p_start_date		in date default null,
	p_dimension_level	in varchar2 default 'ASG',
	p_date_type		in varchar2 default 'DP') return number
is
	l_assignment_action_id	number;
begin
	if p_dimension_level = 'ASG' then
		if p_date_type = 'DE' then
			select	/*+ ORDERED USE_NL(PPA) */
				to_number(substr(
					max(
						to_char(ppa.date_earned, 'YYYYMMDD') ||
						to_char(paa.action_sequence, 'FM099999999999999') ||
						to_char(paa.assignment_action_id)
					)
				, 24))
			into	l_assignment_action_id
			from	pay_assignment_actions	paa,
				pay_payroll_actions	ppa
			where	paa.assignment_id = p_assignment_id
			and	paa.action_status = 'C'
			and	ppa.payroll_action_id = paa.payroll_action_id
			and	ppa.date_earned
				between nvl(p_start_date, ppa.date_earned) and p_effective_date
			and	ppa.action_type in ('R', 'Q', 'B', 'I', 'V');
		else
			select	/*+ ORDERED USE_NL(PPA) */
				to_number(substr(
					max(
						to_char(paa.action_sequence, 'FM099999999999999') ||
						to_char(paa.assignment_action_id)
					)
				, 16))
			into	l_assignment_action_id
			from	pay_assignment_actions	paa,
				pay_payroll_actions	ppa
			where	paa.assignment_id = p_assignment_id
			and	paa.action_status = 'C'
			and	ppa.payroll_action_id = paa.payroll_action_id
			and	ppa.effective_date
				between nvl(p_start_date, ppa.effective_date) and p_effective_date
			and	ppa.action_type in ('R', 'Q', 'B', 'I', 'V');
		end if;
	--
	-- This PER level dimension works only when "Independent Time Period"(I)
	-- legislation rule is set to "N".
	--
	elsif p_dimension_level = 'PER' then
		if p_date_type = 'DE' then
			select	/*+ ORDERED USE_NL(PAA PPA) NO_EXPAND */
				to_number(substr(
					max(
						to_char(ppa.date_earned, 'YYYYMMDD') ||
						to_char(paa.action_sequence, 'FM099999999999999') ||
						to_char(paa.assignment_action_id)
					)
				, 24))
			into	l_assignment_action_id
			from	(
					select	asg2.assignment_id
					from	per_all_assignments_f	asg,
						per_all_assignments_f	asg2
					where	asg.assignment_id = p_assignment_id
					and	p_effective_date
						between asg.effective_start_date and asg.effective_end_date
					and	asg2.person_id = asg.person_id
					group by asg2.assignment_id
				)			v,
				pay_assignment_actions	paa,
				pay_payroll_actions	ppa
			where	paa.assignment_id = v.assignment_id
			and	paa.action_status = 'C'
			and	ppa.payroll_action_id = paa.payroll_action_id
			and	ppa.date_earned
				between nvl(p_start_date, ppa.date_earned) and p_effective_date
			and	ppa.action_type in ('R', 'Q', 'B', 'I', 'V');
		else
			select	/*+ ORDERED USE_NL(PAA PPA) NO_EXPAND */
				to_number(substr(
					max(
						to_char(paa.action_sequence, 'FM099999999999999') ||
						to_char(paa.assignment_action_id)
					)
				, 16))
			into	l_assignment_action_id
			from	(
					select	asg2.assignment_id
					from	per_all_assignments_f	asg,
						per_all_assignments_f	asg2
					where	asg.assignment_id = p_assignment_id
					and	p_effective_date
						between asg.effective_start_date and asg.effective_end_date
					and	asg2.person_id = asg.person_id
					group by asg2.assignment_id
				)			v,
				pay_assignment_actions	paa,
				pay_payroll_actions	ppa
			where	paa.assignment_id = v.assignment_id
			and	paa.action_status = 'C'
			and	ppa.payroll_action_id = paa.payroll_action_id
			and	ppa.effective_date
				between nvl(p_start_date, ppa.effective_date) and p_effective_date
			and	ppa.action_type in ('R', 'Q', 'B', 'I', 'V');
		end if;
	else
		fnd_message.set_name('PAY', 'PAY_JP_INV_DIMENSION_LEVEL');
		fnd_message.set_token('DIMENSION_LEVEL', p_dimension_level);
		fnd_message.raise_error;
	end if;
	--
	return l_assignment_action_id;
exception
	when no_data_found then
		return null;
end get_latest_action_id;
-- ----------------------------------------------------------------------------
-- |---------------------< get_period_latest_action_id >----------------------|
-- ----------------------------------------------------------------------------
function get_period_latest_action_id(
	p_assignment_id		in number,
	p_effective_date	in date,
	p_dimension_level	in varchar2 default 'ASG') return number
is
	l_assignment_rec	t_assignment_rec;
	l_assignment_action_id	number;
begin
	get_assignment_info(
		p_assignment_id		=> p_assignment_id,
		p_effective_date	=> p_effective_date,
		p_assignment_rec	=> l_assignment_rec);
	--
	if l_assignment_rec.time_period_id is not null then
		begin
			--
			-- DATE_EARNED is not supported for PTD dimensions.
			--
			if p_dimension_level = 'ASG' then
				select	/*+ ORDERED USE_NL(PPA) */
					to_number(substr(
						max(
							to_char(paa.action_sequence, 'FM099999999999999') ||
							to_char(paa.assignment_action_id)
						)
					, 16))
				into	l_assignment_action_id
				from	pay_assignment_actions	paa,
					pay_payroll_actions	ppa
				where	paa.assignment_id = p_assignment_id
				and	paa.action_status = 'C'
				and	ppa.payroll_action_id = paa.payroll_action_id
				and	ppa.time_period_id = l_assignment_rec.time_period_id
				and	ppa.effective_date <= p_effective_date
				and	ppa.action_type in ('R', 'Q', 'B', 'I', 'V');
			--
			-- This PER level dimension works only when "Independent Time Period"(I)
			-- legislation rule is set to "N".
			--
			elsif p_dimension_level = 'PER' then
				select	/*+ ORDERED USE_NL(PAA PPA) */
					to_number(substr(
						max(
							to_char(paa.action_sequence, 'FM099999999999999') ||
							to_char(paa.assignment_action_id)
						)
					, 16))
				into	l_assignment_action_id
				from	(
						select	asg2.assignment_id
						from	per_all_assignments_f	asg,
							per_all_assignments_f	asg2
						where	asg.assignment_id = p_assignment_id
						and	p_effective_date
							between asg.effective_start_date and asg.effective_end_date
						and	asg2.person_id = asg.person_id
						group by asg2.assignment_id
					)			v,
					pay_assignment_actions	paa,
					pay_payroll_actions	ppa
				where	paa.assignment_id = v.assignment_id
				and	paa.action_status = 'C'
				and	ppa.payroll_action_id = paa.payroll_action_id
				and	ppa.time_period_id = l_assignment_rec.time_period_id
				and	ppa.effective_date <= p_effective_date
				and	ppa.action_type in ('R', 'Q', 'B', 'I', 'V');
			else
				fnd_message.set_name('PAY', 'PAY_JP_INV_DIMENSION_LEVEL');
				fnd_message.set_token('DIMENSION_LEVEL', p_dimension_level);
				fnd_message.raise_error;
			end if;
		exception
			when no_data_found then
				return null;
		end;
	end if;
	--
	return l_assignment_action_id;
end get_period_latest_action_id;
-- ----------------------------------------------------------------------------
-- |------------------------< get_value (date mode) >-------------------------|
-- ----------------------------------------------------------------------------
function get_value(
	p_assignment_id		in number,
	p_effective_date	in date,
	p_defined_balance_id	in number,
	p_dimension_level	in varchar2,
	p_date_type		in varchar2,
	p_period_type		in varchar2,
	p_start_date_code	in varchar2,
	p_dimension_name	in varchar2,
	p_original_entry_id	in number default null) return number
is
	l_assignment_action_id	number;
	l_balance_value		number;
	--
	l_assignment_rec	t_assignment_rec;
	l_start_date		date;
	l_date_type		varchar2(30);
begin
	if p_period_type is not null then
		if p_period_type = 'PAYMENT' then
			l_assignment_action_id := null;
		--
		-- In case of RUN, pick up latest assignment_action_id within the payroll period.
		--
		elsif p_period_type in ('RUN', 'PERIOD') then
			l_assignment_action_id := get_period_latest_action_id(
							p_assignment_id		=> p_assignment_id,
							p_effective_date	=> p_effective_date,
							p_dimension_level	=> p_dimension_level);
		elsif p_period_type = 'LIFETIME' then
			l_assignment_action_id := get_latest_action_id(
							p_assignment_id		=> p_assignment_id,
							p_effective_date	=> p_effective_date,
							p_start_date		=> null,
							p_dimension_level	=> p_dimension_level,
							p_date_type		=> p_date_type);
		else
			get_assignment_info(
				p_assignment_id		=> p_assignment_id,
				p_effective_date	=> p_effective_date,
				p_assignment_rec	=> l_assignment_rec);
			--
			pay_balance_pkg.get_period_type_start(
				p_period_type		=> p_period_type,
				p_effective_date	=> p_effective_date,
				p_start_date		=> l_start_date,
				p_start_date_code	=> p_start_date_code,
				p_payroll_id		=> l_assignment_rec.payroll_id,
				p_bus_grp		=> l_assignment_rec.business_group_id);
			--
			l_assignment_action_id := get_latest_action_id(
							p_assignment_id		=> p_assignment_id,
							p_effective_date	=> p_effective_date,
							p_start_date		=> l_start_date,
							p_dimension_level	=> p_dimension_level,
							p_date_type		=> p_date_type);
		end if;
	else
		--
		-- Old User Defined Dimensions
		--
		if substr(rpad(p_dimension_name, 68), -8) = 'USER-REG' then
			l_start_date := hr_jprts.dimension_reset_date(p_dimension_name, p_effective_date);
			--
			l_date_type := rtrim(substr(rpad(p_dimension_name, 44), -14));
			if l_date_type = 'DATE_EARNED' then
				l_date_type := 'DE';
			else
				l_date_type := 'DP';
			end if;
			--
			l_assignment_action_id := get_latest_action_id(
							p_assignment_id		=> p_assignment_id,
							p_effective_date	=> p_effective_date,
							p_start_date		=> l_start_date,
							p_dimension_level	=> 'ASG',
							p_date_type		=> l_date_type);
		else
			--
			-- Unknown Balance Dimension
			-- pay_balance_pkg.get_value(date mode) cannot be called
			-- which will raise error if this function is called in SQL statement
			-- because of "rollback to savepoint" call exists in get_value(date mode).
			--
			l_assignment_action_id := -1;
		end if;
	end if;
	--
	if l_assignment_action_id > 0 then
		l_balance_value := pay_balance_pkg.get_value(
					p_defined_balance_id	=> p_defined_balance_id,
					p_assignment_action_id	=> l_assignment_action_id,
					p_tax_unit_id		=> null,
					p_jurisdiction_code	=> null,
					p_source_id		=> null,
					p_source_text		=> null,
					p_tax_group		=> null,
					p_original_entry_id	=> p_original_entry_id,
					p_date_earned		=> null);
	elsif l_assignment_action_id = -1 then
		l_balance_value := null;
	else
		l_balance_value := 0;
	end if;
	--
	return l_balance_value;
end get_value;
-- ----------------------------------------------------------------------------
-- |------------------------< get_value (date mode) >-------------------------|
-- ----------------------------------------------------------------------------
function get_value(
	p_assignment_id		in number,
	p_effective_date	in date,
	p_defined_balance_id	in number,
	p_original_entry_id	in number default null) return number
is
	l_defined_balance_rec	t_defined_balance_rec;
	l_balance_value		number;
begin
	get_defined_balance_info(
		p_defined_balance_id	=> p_defined_balance_id,
		p_defined_balance_rec	=> l_defined_balance_rec);
	--
	l_balance_value := get_value(
				p_assignment_id		=> p_assignment_id,
				p_effective_date	=> p_effective_date,
				p_defined_balance_id	=> l_defined_balance_rec.defined_balance_id,
				p_dimension_level	=> l_defined_balance_rec.dimension_level,
				p_date_type		=> l_defined_balance_rec.date_type,
				p_period_type		=> l_defined_balance_rec.period_type,
				p_start_date_code	=> l_defined_balance_rec.start_date_code,
				p_dimension_name	=> l_defined_balance_rec.dimension_name,
				p_original_entry_id	=> p_original_entry_id);
	--
	return l_balance_value;
end get_value;
-- ----------------------------------------------------------------------------
-- |------------------------< get_value (date mode) >-------------------------|
-- ----------------------------------------------------------------------------
function get_value(
	p_assignment_id		in number,
	p_effective_date	in date,
	p_balance_type_id	in number,
	p_dimension_name	in varchar2,
	p_business_group_id	in number,
	p_original_entry_id	in number default null) return number
is
	l_defined_balance_rec	t_defined_balance_rec;
	l_balance_value		number;
begin
	get_defined_balance_info(
		p_balance_type_id	=> p_balance_type_id,
		p_dimension_name	=> p_dimension_name,
		p_business_group_id	=> p_business_group_id,
		p_defined_balance_rec	=> l_defined_balance_rec);
	--
	if l_defined_balance_rec.defined_balance_id is not null then
/*
		--
		-- This is to pick up latest assignment_action_id within the payroll period.
		-- If RUN is passed, then balance value is always "0" in date mode.
		--
		if l_defined_balance_rec.period_type = 'RUN' then
			l_defined_balance_rec.period_type := 'PERIOD';
		end if;
*/
		--
		l_balance_value := get_value(
					p_assignment_id		=> p_assignment_id,
					p_effective_date	=> p_effective_date,
					p_defined_balance_id	=> l_defined_balance_rec.defined_balance_id,
					p_dimension_level	=> l_defined_balance_rec.dimension_level,
					p_date_type		=> l_defined_balance_rec.date_type,
					p_period_type		=> l_defined_balance_rec.period_type,
					p_start_date_code	=> l_defined_balance_rec.start_date_code,
					p_dimension_name	=> l_defined_balance_rec.dimension_name,
					p_original_entry_id	=> p_original_entry_id);
	end if;
	--
	return l_balance_value;
end get_value;
-- ----------------------------------------------------------------------------
-- |-----------------------< get_value (action mode) >------------------------|
-- ----------------------------------------------------------------------------
function get_value(
	p_assignment_action_id	in number,
	p_balance_type_id	in number,
	p_dimension_name	in varchar2,
	p_business_group_id	in number,
	p_original_entry_id	in number default null) return number
is
	l_defined_balance_rec	t_defined_balance_rec;
	l_balance_value		number;
begin
	get_defined_balance_info(
		p_balance_type_id	=> p_balance_type_id,
		p_dimension_name	=> p_dimension_name,
		p_business_group_id	=> p_business_group_id,
		p_defined_balance_rec	=> l_defined_balance_rec);
	--
	if l_defined_balance_rec.defined_balance_id is not null then
		l_balance_value := pay_balance_pkg.get_value(
					p_defined_balance_id	=> l_defined_balance_rec.defined_balance_id,
					p_assignment_action_id	=> p_assignment_action_id,
					p_tax_unit_id		=> null,
					p_jurisdiction_code	=> null,
					p_source_id		=> null,
					p_source_text		=> null,
					p_tax_group		=> null,
					p_original_entry_id	=> p_original_entry_id,
					p_date_earned		=> null);
	end if;
	--
	return l_balance_value;
end get_value;
--
end pay_jp_balance_view_pkg;

/
