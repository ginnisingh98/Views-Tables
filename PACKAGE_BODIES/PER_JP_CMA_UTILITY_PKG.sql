--------------------------------------------------------
--  DDL for Package Body PER_JP_CMA_UTILITY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_JP_CMA_UTILITY_PKG" as
/* $Header: pejpcmau.pkb 120.3.12000000.4 2007/04/25 09:37:10 ttagawa ship $ */
--
-- Constants
--
c_package                       constant varchar2(31) := 'per_jp_cma_utility_pkg.';
--
c_car_element_name		constant pay_element_types_f.element_name%type := 'SAL_CMA_PRIVATE_TRANSPORT_INFO';
c_train_element_name		constant pay_element_types_f.element_name%type := 'SAL_CMA_PUBLIC_TRANSPORT_INFO';
--
c_non_taxable_udt_name          constant varchar2(80) := 'T_SAL_CMA_PRIVATE_TRANSPORT_NTXBL_ERN_MAX';
c_non_taxable_udt_col_name      constant varchar2(80) := 'MAX';
c_equivalent_cost_udt_col_name  constant varchar2(80) := 'FARE_EQUIVALENT_AMT_PRIORITY_FLAG';
--
c_means_udt_name                constant varchar2(80) := 'T_SAL_CMA_METHOD_INFO';
c_means_udt_col_name            constant varchar2(80) := 'TXBL_FLAG';
c_parking_fees                  constant varchar2(30) := 'PARKING_FEE';
--
-- Global Variables
--
type t_bg_cma_formula_rec is record(
	business_group_id	number,
	ref_type		varchar2(150));
g_bg_cma_formula_rec t_bg_cma_formula_rec;
-- ----------------------------------------------------------------------------
-- |-------------------------< bg_cma_formula_id >----------------------------|
-- ----------------------------------------------------------------------------
function bg_cma_formula_id(p_business_group_id in number) return varchar2
is
	cursor csr_bg is
		select	org_information3
		from	hr_organization_information
		where	organization_id = p_business_group_id
		and	org_information_context = 'JP_BUSINESS_GROUP_INFO';
begin
	--
	-- Use cache if available
	--
	if (g_bg_cma_formula_rec.business_group_id is null)
	or (g_bg_cma_formula_rec.business_group_id <> p_business_group_id) then
		g_bg_cma_formula_rec.business_group_id := p_business_group_id;
		--
		open csr_bg;
		fetch csr_bg into g_bg_cma_formula_rec.ref_type;
/*
		if (csr_bg%notfound) or (g_bg_cma_formula_rec.ref_type is null) then
			g_bg_cma_formula_rec.ref_type := c_default_itax_dpnt_ref_type;
		end if;
*/
		close csr_bg;
	end if;
	--
	return g_bg_cma_formula_rec.ref_type;
end bg_cma_formula_id;
-- ----------------------------------------------------------------------------
-- |---------------------------< calc_car_amount >----------------------------|
-- ----------------------------------------------------------------------------
--
-- This procedure is called from PAYJPCMA form.
--
-- ----------------------------------------------------------------------------
procedure calc_car_amount(
	p_formula_id		in number,
	p_business_group_id	in number,
	p_assignment_id		in number,
	p_effective_date	in date,
	p_ev_rec_tbl		in pay_jp_entries_pkg.ev_rec_tbl,
	p_attribute_tbl		in pay_jp_entries_pkg.attribute_tbl,
	p_outputs		out nocopy varchar2,
	p_val_returned		out nocopy boolean)
is
	c_proc		constant varchar2(61) := c_package || 'calc_car_amount';
	--
	l_inputs	ff_exec.inputs_t;
	l_outputs	ff_exec.outputs_t;
begin
	--
	-- Initialize formula informations.
	--
	ff_exec.init_formula(
		p_formula_id		=> p_formula_id,
		p_effective_date	=> p_effective_date,
		p_inputs		=> l_inputs,
		p_outputs		=> l_outputs);
	--
	-- Setup input variables.
	--
	for i in 1..l_inputs.count loop
		if l_inputs(i).name = 'BUSINESS_GROUP_ID' then
			l_inputs(i).value := to_char(p_business_group_id);
		elsif l_inputs(i).name = 'ASSIGNMENT_ID' then
			l_inputs(i).value := to_char(p_assignment_id);
		elsif l_inputs(i).name = 'DATE_EARNED' then
			l_inputs(i).value := fnd_date.date_to_canonical(p_effective_date);
		elsif l_inputs(i).name like 'ENTRY_VALUE%' then
			for l_counter in 1..15 loop
				if l_inputs(i).name = 'ENTRY_VALUE' || to_char(l_counter) then
					l_inputs(i).value := p_ev_rec_tbl(l_counter).entry_value;
				end if;
			end loop;
		elsif l_inputs(i).name like 'ATTRIBUTE%' then
			for l_counter in 1..20 loop
				if l_inputs(i).name = 'ATTRIBUTE' || to_char(l_counter) then
					l_inputs(i).value := p_attribute_tbl.attribute(l_counter);
				end if;
			end loop;
		end if;
	end loop;
	--
	-- Execute formula. Formula unexpected error is raised by ffexec,
	-- so not necessary to handle error.
	--
	ff_exec.run_formula(
		p_inputs	=> l_inputs,
		p_outputs	=> l_outputs,
		p_use_dbi_cache	=> TRUE);
	--
	-- Setup output variables.
	--
	p_val_returned := False;
	for i in 1..l_outputs.count loop
		if l_outputs(i).name = 'RETURN_AMOUNT' then
			p_outputs := l_outputs(i).value;
			p_val_returned := True;
			exit;
		end if;
	end loop;
exception
	when OTHERS then
		p_val_returned := False;
end calc_car_amount;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< get_cma_info >-----------------------------|
-- ----------------------------------------------------------------------------
-- The amount for transportation and traffic tool are got from commutation
-- information, and taxable amount, non-taxable amount etc. are calculated.
-- Strictly speaking, p_non_taxable_limit_1mth shouldn't be passed into
-- because this limit is p_effective_date dependent.
-- But this amount is currently 100,000 yen and has never been changed.
-- We leave this issue until this limit will be datetracked in the future.
-- ----------------------------------------------------------------------------
-- p_payment_date was added by bug.4029525, but this parameter is not required
-- from coding point of view, which can be derived using si_month and p_effective_date.
-- There are some potential issues when SI month is set to "Next Month".
-- For example, car is set to "Current Month" and train is set to "Next Month".
-- In this case, which date should be set to p_effective_date?
-- For car, p_effective_date is this month, and p_effective_date is next month for train.
-- In general, there will be no datetrack records in the future,
-- p_effective_date(=next month) for cars will be OK for most cases.
procedure get_cma_info(
	p_business_group_id		in number,
	p_assignment_id			in number,
	p_payment_date			in date, -- bug 4029525
	p_effective_date		in date,
	p_non_taxable_limit_1mth	in number,
	p_cma_rec			out nocopy cma_rec,
	p_record_exist			out nocopy boolean)
is
	c_proc				constant varchar2(61) := c_package || 'get_cma_info';
	--
	-- Type Definitions
	--
	type deemed_income_rec is record(
		sal_taxable_amount		number := 0,
		sal_non_taxable_amount		number := 0,
		mtr_taxable_amount		number := 0,
		mtr_non_taxable_amount		number := 0,
		paid_sal_non_taxable_amount	number := 0,
		paid_mtr_non_taxable_amount	number := 0);
	type deemed_income_tbl is table of deemed_income_rec index by binary_integer;
	l_deemed_income			deemed_income_tbl;
	---- bug 4029525 ----
	l_payment_date			date;
	---------------------
	l_enforced_taxable_flag		number;
	l_parking_taxable_flag		number;
	l_equivalent_cost_priority	number;
	l_mod				number;
	l_non_taxable_limit		number;
	l_lcm				number;
	l_amount			number;
	i				number;
	--
	l_prev_payment_date		date;
	l_payment_date_offset		number;
	l_si_date			date;
	l_index				number;
	--
	l_sal_taxable_amount		number;
	l_sal_non_taxable_amount	number;
	l_mtr_taxable_amount		number;
	l_mtr_non_taxable_amount	number;
	--
	l_sal_taxable_flag		boolean := false;
	l_sal_non_taxable_flag		boolean := false;
	l_mtr_taxable_flag		boolean := false;
	l_mtr_non_taxable_flag		boolean := false;
	l_sal_income			number := 0;
	l_mtr_income			number := 0;
	--
	l_sal_si_flag			boolean := false;
	l_mtr_si_flag			boolean := false;
	l_sal_si_wage			number := 0;
	l_mtr_si_wage			number := 0;
	--
	l_car_sal_taxable_amount	number;
	l_car_sal_non_taxable_amount	number;
	--
	-- si_month is not supported for cars.
	-- The storage is just created for future enhancement.
	-- There's no specification/usage available for car si_month at the moment.
	--
	cursor csr_car is
	select	car.element_entry_id,
		car.tranpo_type,
		car.period,
		car.distance,
		car.amount,
		car.parking_fees,
		car.equivalent_cost,
		car.pay_start,
		car.pay_end
	from	(
			select	v.element_entry_id,
				v.tranpo_type,
				v.period,
				v.distance,
				v.amount,
				v.parking_fees,
				v.equivalent_cost,
				nvl(to_date(v.pay_start, 'YYYYMM'), trunc(v.effective_start_date, 'MM'))	pay_start,
				nvl(to_date(v.pay_end, 'YYYYMM'), trunc(v.effective_end_date, 'MM'))		pay_end
			from	(
					select	/*+ ORDERED USE_NL(PEL PEE PEEV PIV) INDEX (PEE PAY_ELEMENT_ENTRIES_F_N51) */
						pee.element_entry_id,
						pee.effective_start_date,
						pee.effective_end_date,
						substrb(min(decode(piv.display_sequence, 1, peev.screen_entry_value, NULL)), 1, 30)					tranpo_type,
						nvl(fnd_number.canonical_to_number(substr(min(decode(piv.display_sequence, 3, peev.screen_entry_value, NULL)), 5)), 1)	period, -- MTH_x(x=1,3,6)
						-- Value needs to truncated to avoid no_data_found in get_table_value
						trunc(nvl(fnd_number.canonical_to_number(min(decode(piv.display_sequence, 4, peev.screen_entry_value, NULL))), 0) * 1000)	distance,
						-- amount and parking_fees can be null values.
						fnd_number.canonical_to_number(min(decode(piv.display_sequence, 6, peev.screen_entry_value, NULL)))			amount,
						fnd_number.canonical_to_number(min(decode(piv.display_sequence, 7, peev.screen_entry_value, NULL)))			parking_fees,
						nvl(fnd_number.canonical_to_number(min(decode(piv.display_sequence, 8, peev.screen_entry_value, NULL))), 0)		equivalent_cost,
						substrb(min(decode(piv.display_sequence, 9, peev.screen_entry_value, NULL)), 1, 6)					pay_start,
						substrb(min(decode(piv.display_sequence, 10, peev.screen_entry_value, NULL)), 1, 6)					pay_end
					from	pay_element_types_f		pet,
						pay_element_links_f		pel,
						pay_element_entries_f		pee,
						pay_element_entry_values_f	peev,
						pay_input_values_f		piv
					where	pet.element_name = c_car_element_name
					and	pet.legislation_code = 'JP'
					and	p_effective_date
						between pet.effective_start_date and pet.effective_end_date
					and	pel.element_type_id = pet.element_type_id
					and	p_effective_date
						between pel.effective_start_date and pel.effective_end_date
					and	pel.business_group_id = p_business_group_id
					and	pee.assignment_id = p_assignment_id
					and	pee.element_link_id = pel.element_link_id
					and	p_effective_date
						between pee.effective_start_date and pee.effective_end_date
					and	pee.entry_type = 'E'
					and	peev.element_entry_id = pee.element_entry_id
					and	peev.effective_start_date = pee.effective_start_date
					and	peev.effective_end_date = pee.effective_end_date
					and	piv.input_value_id = peev.input_value_id
					and	p_effective_date
						between piv.effective_start_date and piv.effective_end_date
					group by
						pee.element_entry_id,
						pee.effective_start_date,
						pee.effective_end_date
				) v
			where	v.tranpo_type is not null
		)	car
	where	l_payment_date
		between car.pay_start and car.pay_end;
	--
	type t_car_tbl is table of csr_car%rowtype;
	l_cars	t_car_tbl;
	l_car	csr_car%rowtype;
	--
	-- Only in case of trains entries which do not exist as of p_effective_date
	-- can contribute to si_wages (we need to take si_month into consideration).
	--
	cursor csr_train is
	select	train.element_entry_id,
		train.effective_start_date,
		train.effective_end_date,
		train.tranpo_type,
		train.period,
		train.amount_type,
		train.amount,
		train.pay_start,
		train.pay_end,
		train.si_start,
		train.si_end,
		train.si_month
	from	(
			select	v.element_entry_id,
				v.effective_start_date,
				v.effective_end_date,
				v.tranpo_type,
				v.period,
				v.amount_type,
				v.amount,
				--
				-- When pay_start is null, pay_start is
				-- 1. 1 month before effective_start_date month when si_month = "Next Month"
				-- 2. effective_start_date month when si_month = "This Month"
				--
				nvl(to_date(v.pay_start, 'YYYYMM'), trunc(add_months(v.effective_start_date, - v.si_month), 'MM'))	pay_start,
				nvl(to_date(v.pay_end, 'YYYYMM'), trunc(add_months(v.effective_end_date, - v.si_month), 'MM'))		pay_end,
				nvl(add_months(to_date(v.pay_start, 'YYYYMM'), v.si_month), trunc(v.effective_start_date, 'MM'))	si_start,
				nvl(add_months(to_date(v.pay_end, 'YYYYMM'), v.si_month), trunc(v.effective_end_date, 'MM'))		si_end,
				v.si_month
			from	(
					select	/*+ ORDERED USE_NL(PEL PEE PEEV PIV) INDEX (PEE PAY_ELEMENT_ENTRIES_F_N51) */
						pee.element_entry_id,
						pee.effective_start_date,
						pee.effective_end_date,
						substrb(min(decode(piv.display_sequence, 1, peev.screen_entry_value, NULL)), 1, 30)					tranpo_type,
						nvl(fnd_number.canonical_to_number(substr(min(decode(piv.display_sequence, 5, peev.screen_entry_value, NULL)), 5)), 1)	period, -- MTH_x(x=1,3,6)
						nvl(substrb(min(decode(piv.display_sequence, 6, peev.screen_entry_value, NULL)), 1, 30), 'SALARY')			amount_type, -- SALARY/MATERIAL
						nvl(fnd_number.canonical_to_number(min(decode(piv.display_sequence,7, peev.screen_entry_value, NULL))), 0)		amount,
						substrb(min(decode(piv.display_sequence, 8, peev.screen_entry_value, NULL)), 1, 6)					pay_start,
						substrb(min(decode(piv.display_sequence, 9, peev.screen_entry_value, NULL)), 1, 6)					pay_end,
						nvl(fnd_number.canonical_to_number(min(decode(piv.display_sequence, 10, peev.screen_entry_value, NULL))), 0)		si_month
					from	pay_element_types_f		pet,
						pay_element_links_f		pel,
						pay_element_entries_f		pee,
						pay_element_entry_values_f	peev,
						pay_input_values_f		piv
					where	pet.element_name = c_train_element_name
					and	pet.legislation_code = 'JP'
					and	p_effective_date
						between pet.effective_start_date and pet.effective_end_date
					and	pel.element_type_id = pet.element_type_id
					and	p_effective_date
						between pel.effective_start_date and pel.effective_end_date
					and	pel.business_group_id = p_business_group_id
					and	pee.assignment_id = p_assignment_id
					and	pee.element_link_id = pel.element_link_id
					-- This date range check is loose, and will exact range check be done outside this inline SQL.
					-- We take si_month into consideration only for train tranpo, not car tranpo.
					and	pee.effective_start_date <= p_effective_date
					and	pee.entry_type = 'E'
					and	peev.element_entry_id = pee.element_entry_id
					and	peev.effective_start_date = pee.effective_start_date
					and	peev.effective_end_date = pee.effective_end_date
					and	piv.input_value_id = peev.input_value_id
					and	p_effective_date
						between piv.effective_start_date and piv.effective_end_date
					group by
						pee.element_entry_id,
						pee.effective_start_date,
						pee.effective_end_date
				) v
			where	v.tranpo_type is not null
		)	train
	where
		--
		-- Taxable Check
		--
		(
			train.effective_end_date >= p_effective_date
		and	l_payment_date
			between train.pay_start and train.pay_end
		)
		or
		--
		-- SI Wage Check (Already paid before l_payment_date)
		--
		(
			train.si_month <> 0
		and	train.effective_end_date >= add_months(p_effective_date, - train.si_month)
		and	train.si_end >= l_payment_date
/*
		and	add_months(p_effective_date, - train.si_month)
			between train.effective_start_date and train.effective_end_date
		and	l_payment_date
			between train.si_start and train.si_end
*/
		);
	--
	type t_train_tbl is table of csr_train%rowtype;
	l_trains	t_train_tbl;
	l_train		csr_train%rowtype;
	--
	procedure chk_non_taxable_limit(
		p_taxable_amount		in out nocopy number,
		p_non_taxable_amount		in out nocopy number,
		p_non_taxable_limit		in number,
		p_paid_non_taxable_amount	in number default null)
	is
		l_non_taxable_limit	number;
	begin
		if p_non_taxable_amount is not null and p_non_taxable_limit is not null then
			l_non_taxable_limit := greatest(p_non_taxable_limit - nvl(p_paid_non_taxable_amount, 0), 0);
			if p_non_taxable_amount > l_non_taxable_limit then
				p_taxable_amount := nvl(p_taxable_amount, 0) + (p_non_taxable_amount - l_non_taxable_limit);
				p_non_taxable_amount := l_non_taxable_limit;
			end if;
		end if;
	end chk_non_taxable_limit;
	--
	procedure init_deemed_income(p_index in number)
	is
	begin
		if not l_deemed_income.exists(p_index) then
			l_deemed_income(p_index).sal_taxable_amount := 0;
		end if;
	end init_deemed_income;
begin
	hr_utility.set_location('Entering: ' || c_proc, 10);
	---- bug 4029525 ----
	l_payment_date   := trunc(p_payment_date, 'MM');
	---------------------
	hr_utility.trace('p_payment_date  : ' || p_payment_date);
	hr_utility.trace('p_effective_date: ' || p_effective_date);
	hr_utility.trace('l_payment_date  : ' || l_payment_date);
	--
	open csr_car;
	fetch csr_car bulk collect into l_cars;
	close csr_car;
	--
	-- Exit when multiple car transportation subject to taxation is found
	-- for one of the months.
	--
	if l_cars.count > 1 then
		p_record_exist := true;
		p_cma_rec.multiple_entry_warning := true;
		return;
	end if;
	--
	open csr_train;
	fetch csr_train bulk collect into l_trains;
	close csr_train;
	--
	-- Derive "Least Common Multiple" of "period" of all transportations.
	-- This is used to split "transportation fees * l_lcm" into subject month
	-- to avoid each month amount to be decimal number.
	--
	l_lcm := 1;
	for i in 1..l_cars.count loop
		hr_utility.trace('car period: ' || l_cars(i).period);
		p_record_exist := true;
		l_lcm := hr_jp_standard_pkg.lcm(l_lcm, l_cars(i).period);
	end loop;
	--
	for i in 1..l_trains.count loop
		hr_utility.trace('train period: ' || l_trains(i).period);
		p_record_exist := true;
		l_lcm := hr_jp_standard_pkg.lcm(l_lcm, l_trains(i).period);
	end loop;
	--
	hr_utility.trace('lcm: ' || l_lcm);
	--
	-- Split transportation fee for cars into each month.
	--
	for i in 1..l_cars.count loop
		l_car := l_cars(i);
		l_car_sal_taxable_amount	:= 0;
		l_car_sal_non_taxable_amount	:= 0;
		l_enforced_taxable_flag		:= null;
		l_parking_taxable_flag		:= null;
		--
		hr_utility.trace('***** Car Info: ' || to_char(l_car.element_entry_id));
		hr_utility.trace('amount      : ' || l_car.amount);
		hr_utility.trace('parking_fees: ' || l_car.parking_fees);
		hr_utility.trace('period      : ' || l_car.period);
		hr_utility.trace('pay_start   : ' || l_car.pay_start);
		hr_utility.trace('pay_end     : ' || l_car.pay_end);
		--
		if l_car.amount is not null then
			--
			-- Strictly speaking, following flag should be checked
			-- as of the date of each month subject to SI.
			-- Currently, we leave this issue.
			--
			l_enforced_taxable_flag := to_number(pay_jp_formula_function_pkg.get_table_value_with_default(
							p_business_group_id,
							c_means_udt_name,
							c_means_udt_col_name,
							hr_general.decode_lookup('JP_CMA_CAR_MEANS', l_car.tranpo_type),
							---- bug 4029525 ----
							p_payment_date,
							---------------------
							'0',
							'N'));
			if l_enforced_taxable_flag = 1 then
				l_car_sal_taxable_amount := l_car_sal_taxable_amount + l_car.amount;
			else
				l_car_sal_non_taxable_amount := l_car_sal_non_taxable_amount + l_car.amount;
			end if;
		end if;
		--
		if l_car.parking_fees is not null then
			--
			-- Strictly speaking, following flag should be checked
			-- as of the date of each month subject to SI.
			-- Currently, we leave this issue.
			--
			l_parking_taxable_flag := to_number(pay_jp_formula_function_pkg.get_table_value_with_default(
							p_business_group_id,
							c_means_udt_name,
							c_means_udt_col_name,
							c_parking_fees,
							---- bug 4029525 ----
							p_payment_date,
							---------------------
							'0',
							'N'));
			if l_parking_taxable_flag = 1 then
				l_car_sal_taxable_amount := l_car_sal_taxable_amount + l_car.parking_fees;
			else
				l_car_sal_non_taxable_amount := l_car_sal_non_taxable_amount + l_car.parking_fees;
			end if;
		end if;
		--
		if l_car_sal_non_taxable_amount > 0 then
			l_non_taxable_limit := null;
			--
			if l_car.equivalent_cost > 0 then
				l_equivalent_cost_priority :=
					to_number(hruserdt.get_table_value(
							p_business_group_id,
							c_non_taxable_udt_name,
							c_equivalent_cost_udt_col_name,
							-- Pass truncated value to avoid no_data_found
							l_car.distance,
							---- bug 4077909 ----
							p_payment_date
							---------------------
						));
				--
				if l_equivalent_cost_priority = 1 then
					l_non_taxable_limit := l_car.equivalent_cost;
				end if;
			end if;
			--
			if l_non_taxable_limit is null then
				l_non_taxable_limit :=
					to_number(hruserdt.get_table_value(
							p_business_group_id,
							c_non_taxable_udt_name,
							c_non_taxable_udt_col_name,
							-- Pass truncated value to avoid no_data_found
							l_car.distance,
							---- bug 4077909 ----
							p_payment_date
							---------------------
						));
			end if;
			--
			-- Non-taxable limit will be checked later,
			-- so the following check is not required here.
			--
--			l_non_taxable_limit := least(l_non_taxable_limit, p_non_taxable_limit_1mth);
			--
			chk_non_taxable_limit(l_car_sal_taxable_amount, l_car_sal_non_taxable_amount, l_non_taxable_limit * l_car.period);
		end if;
		--
		l_mod := mod(months_between(l_payment_date, l_car.pay_start), l_car.period);
		--
		-- When actually paid.
		--
		if l_mod = 0 then
			if l_enforced_taxable_flag = 1 or l_parking_taxable_flag = 1 then
				l_sal_taxable_flag := true;
			else
				l_sal_non_taxable_flag := true;
			end if;
			--
			l_sal_income := l_sal_income + nvl(l_car.amount, 0) + nvl(l_car.parking_fees, 0);
			--
			-- Store <periodic amount> * <Least Common Multiple> into pl/sql table.
			-- This is to avoid losing errors of decimal points.
			--
			for j in 1..l_car.period loop
				init_deemed_income(j);
				l_deemed_income(j).sal_taxable_amount		:= l_deemed_income(j).sal_taxable_amount + l_car_sal_taxable_amount * l_lcm / l_car.period;
				l_deemed_income(j).sal_non_taxable_amount	:= l_deemed_income(j).sal_non_taxable_amount + l_car_sal_non_taxable_amount * l_lcm / l_car.period;
			end loop;
		--
		-- When no payment, but need to calculate deemed amount.
		--
		else
			for j in 1..(l_car.period - l_mod) loop
				--
				-- Derive the already paid amount for from month of SRS effective_date,
				-- so that make adjustments to non-taxable amount which is going to paid.
				-- We do not have to care about Taxable amount which has no limit.
				--
				init_deemed_income(j);
				l_deemed_income(j).paid_sal_non_taxable_amount	:= l_deemed_income(j).paid_sal_non_taxable_amount + l_car_sal_non_taxable_amount * l_lcm / l_car.period;
			end loop;
		end if;
		--
		l_sal_si_flag := true;
		l_sal_si_wage := l_sal_si_wage + (l_car_sal_taxable_amount + l_car_sal_non_taxable_amount) * l_lcm / l_car.period;
	end loop;
	--
	-- Split transportation fee for trains into each month.
	--
	for i in 1..l_trains.count loop
		l_train := l_trains(i);
		l_amount := l_train.amount * l_lcm / l_train.period;
		--
		hr_utility.trace('***** Train Info: ' || to_char(l_train.element_entry_id));
		hr_utility.trace('amount       : ' || l_train.amount);
		hr_utility.trace('period       : ' || l_train.period);
		hr_utility.trace('pay_start    : ' || l_train.pay_start);
		hr_utility.trace('pay_end      : ' || l_train.pay_end);
		hr_utility.trace('si_start     : ' || l_train.si_start);
		hr_utility.trace('si_end       : ' || l_train.si_end);
		hr_utility.trace('si_month     : ' || l_train.si_month);
		hr_utility.trace('m_amount(lcm): ' || l_amount);
		--
		-- Taxable/Non-taxable
		--
		if  p_effective_date between l_train.effective_start_date and l_train.effective_end_date
		and l_payment_date between l_train.pay_start and l_train.pay_end then
			l_mod := mod(months_between(l_payment_date, l_train.pay_start), l_train.period);
			--
			-- Only when actually paid.
			--
			if l_mod = 0 then
				--
				-- Strictly speaking, following flag should be checked
				-- as of the date of each month subject to SI.
				-- Currently, we leave this issue.
				--
				l_enforced_taxable_flag := to_number(pay_jp_formula_function_pkg.get_table_value_with_default(
								p_business_group_id,
								c_means_udt_name,
								c_means_udt_col_name,
								hr_general.decode_lookup('JP_CMA_TRAIN_MEANS', l_train.tranpo_type),
								---- bug 4029525 ----
								p_payment_date,
								---------------------
								'0',
								'N'));
				--
				if l_train.amount_type = 'SALARY' then
					if l_enforced_taxable_flag = 1 then
						l_sal_taxable_flag := true;
					else
						l_sal_non_taxable_flag := true;
					end if;
					--
					l_sal_income := l_sal_income + l_train.amount;
				else
					if l_enforced_taxable_flag = 1 then
						l_mtr_taxable_flag := true;
					else
						l_mtr_non_taxable_flag := true;
					end if;
					--
					l_mtr_income := l_mtr_income + l_train.amount;
				end if;
				--
				for j in (1 + l_train.si_month)..(l_train.period + l_train.si_month) loop
					--
					-- Stores already paid amount in the month to which l_payment_date belongs
					-- for SI.
					--
					if j = 1 then
						if l_train.amount_type = 'SALARY' then
							l_sal_si_flag := true;
							l_sal_si_wage := l_sal_si_wage + l_amount;
						else
							l_mtr_si_flag := true;
							l_mtr_si_wage := l_mtr_si_wage + l_amount;
						end if;
					end if;
					--
					init_deemed_income(j);
					if l_train.amount_type = 'SALARY' then
						if l_enforced_taxable_flag = 1 then
							l_deemed_income(j).sal_taxable_amount := l_deemed_income(j).sal_taxable_amount + l_amount;
						else
							l_deemed_income(j).sal_non_taxable_amount := l_deemed_income(j).sal_non_taxable_amount + l_amount;
						end if;
					else
						if l_enforced_taxable_flag = 1 then
							l_deemed_income(j).mtr_taxable_amount := l_deemed_income(j).mtr_taxable_amount + l_amount;
						else
							l_deemed_income(j).mtr_non_taxable_amount := l_deemed_income(j).mtr_non_taxable_amount + l_amount;
						end if;
					end if;
				end loop;
			end if;
		end if;
		--
		-- SI Wages
		--
		if  l_train.effective_end_date >= add_months(p_effective_date, - l_train.si_month)
		and l_train.si_end >= l_payment_date then
			--
			-- Derive already paid amount in the past before l_payment_date.
			-- Derive first payment_date from (si_month + period - 1) months before
			-- to add_months(l_payment_date, -1).
			--
			l_prev_payment_date := greatest(add_months(l_payment_date, - (l_train.period - 1 + l_train.si_month)), l_train.pay_start);
			l_prev_payment_date := add_months(l_train.pay_start, ceil(months_between(l_prev_payment_date, l_train.pay_start) / l_train.period) * l_train.period);
			l_payment_date_offset := months_between(l_prev_payment_date, l_payment_date);
			--
			while l_prev_payment_date < l_payment_date
			and   add_months(p_effective_date, l_payment_date_offset)
			      between l_train.effective_start_date and l_train.effective_end_date
			and   l_prev_payment_date <= l_train.pay_end loop
				--
				-- Strictly speaking, following flag should be checked
				-- as of the date of each month subject to SI.
				-- Currently, we leave this issue.
				--
				l_enforced_taxable_flag := to_number(pay_jp_formula_function_pkg.get_table_value_with_default(
								p_business_group_id,
								c_means_udt_name,
								c_means_udt_col_name,
								hr_general.decode_lookup('JP_CMA_TRAIN_MEANS', l_train.tranpo_type),
								---- bug 4029525 ----
								add_months(p_payment_date, l_payment_date_offset),
								---------------------
								'0',
								'N'));
				--
				for j in 1..l_train.period loop
					l_si_date := add_months(l_prev_payment_date, l_train.si_month + j - 1);
					--
					if l_si_date >= l_payment_date then
						l_index := months_between(l_si_date, l_payment_date) + 1;
						--
						-- Stores already paid amount in the month to which l_payment_date belongs
						-- for SI.
						--
						if l_index = 1 then
							if l_train.amount_type = 'SALARY' then
								l_sal_si_flag := true;
								l_sal_si_wage := l_sal_si_wage + l_amount;
							else
								l_mtr_si_flag := true;
								l_mtr_si_wage := l_mtr_si_wage + l_amount;
							end if;
						end if;
						--
						if l_enforced_taxable_flag <> 1 then
							init_deemed_income(l_index);
							if l_train.amount_type = 'SALARY' then
								l_deemed_income(l_index).paid_sal_non_taxable_amount := l_deemed_income(l_index).paid_sal_non_taxable_amount + l_amount;
							else
								l_deemed_income(l_index).paid_mtr_non_taxable_amount := l_deemed_income(l_index).paid_mtr_non_taxable_amount + l_amount;
							end if;
						end if;
					end if;
				end loop;
				--
				l_prev_payment_date := add_months(l_prev_payment_date, l_train.period);
				l_payment_date_offset := l_payment_date_offset + l_train.period;
			end loop;
		end if;
	end loop;
	--
	-- Check non-taxable maximum for each month.
	--
	l_non_taxable_limit := p_non_taxable_limit_1mth * l_lcm;
	--
	l_sal_taxable_amount	:= 0;
	l_sal_non_taxable_amount:= 0;
	l_mtr_taxable_amount	:= 0;
	l_mtr_non_taxable_amount:= 0;
	--
	i := l_deemed_income.first;
	while i is not null  loop
		chk_non_taxable_limit(	l_deemed_income(i).mtr_taxable_amount,
					l_deemed_income(i).mtr_non_taxable_amount,
					l_non_taxable_limit,
					l_deemed_income(i).paid_sal_non_taxable_amount
				      + l_deemed_income(i).paid_mtr_non_taxable_amount);
		chk_non_taxable_limit(	l_deemed_income(i).sal_taxable_amount,
					l_deemed_income(i).sal_non_taxable_amount,
					l_non_taxable_limit,
					l_deemed_income(i).paid_sal_non_taxable_amount
				      + l_deemed_income(i).paid_mtr_non_taxable_amount
				      + l_deemed_income(i).mtr_non_taxable_amount);
		--
		hr_utility.trace('***** i = ' || i || ' *****');
		hr_utility.trace('d.sal_taxable_amount         : ' || l_deemed_income(i).sal_taxable_amount);
		hr_utility.trace('d.sal_non_taxable_amount     : ' || l_deemed_income(i).sal_non_taxable_amount);
		hr_utility.trace('d.mtr_taxable_amount         : ' || l_deemed_income(i).mtr_taxable_amount);
		hr_utility.trace('d.mtr_non_taxable_amount     : ' || l_deemed_income(i).mtr_non_taxable_amount);
		hr_utility.trace('d.paid_sal_non_taxable_amount: ' || l_deemed_income(i).paid_sal_non_taxable_amount);
		hr_utility.trace('d.paid_mtr_non_taxable_amount: ' || l_deemed_income(i).paid_mtr_non_taxable_amount);
		--
		l_sal_taxable_amount	:= l_sal_taxable_amount     + l_deemed_income(i).sal_taxable_amount;
		l_sal_non_taxable_amount:= l_sal_non_taxable_amount + l_deemed_income(i).sal_non_taxable_amount;
		l_mtr_taxable_amount	:= l_mtr_taxable_amount     + l_deemed_income(i).mtr_taxable_amount;
		l_mtr_non_taxable_amount:= l_mtr_non_taxable_amount + l_deemed_income(i).mtr_non_taxable_amount;
		--
		i := l_deemed_income.next(i);
	end loop;
	--
	hr_utility.trace('***** before devide by ' || l_lcm || ' *****');
	hr_utility.trace('l_sal_taxable_amount    : ' || l_sal_taxable_amount);
	hr_utility.trace('l_sal_non_taxable_amount: ' || l_sal_non_taxable_amount);
	hr_utility.trace('l_mtr_taxable_amount    : ' || l_mtr_taxable_amount);
	hr_utility.trace('l_mtr_non_taxable_amount: ' || l_mtr_non_taxable_amount);
	hr_utility.trace('l_sal_si_wage           : ' || l_sal_si_wage);
	hr_utility.trace('l_mtr_si_wage           : ' || l_mtr_si_wage);
	--
	-- Adjust errors of non-taxable into taxable.
	-- mtr_non_taxable_amount/mtr_taxable_amount must be integer values, no rounding required.
	-- If there's decimal fraction, it is coding bug and should be fixed.
	--
	l_mod := mod(l_mtr_non_taxable_amount, l_lcm);
	l_mtr_non_taxable_amount:= (l_mtr_non_taxable_amount - l_mod) / l_lcm;
	l_mtr_taxable_amount	:= (l_mtr_taxable_amount + l_mod) / l_lcm;
	--
	-- Never carry over above fractional material non-taxable "l_mod" to salary non-taxable,
	-- which could cause issue for "Enforce Taxable" udt values.
	-- non_taxable_amount/taxable_amount must be integer values, no rounding required.
	--
	l_mod := mod(l_sal_non_taxable_amount, l_lcm);
	l_sal_non_taxable_amount:= (l_sal_non_taxable_amount - l_mod) / l_lcm;
	l_sal_taxable_amount	:= (l_sal_taxable_amount + l_mod) / l_lcm;
	--
	-- Truncated amount is returned for SI wages.
	--
	l_sal_si_wage := trunc(l_sal_si_wage / l_lcm);
	l_mtr_si_wage := trunc(l_mtr_si_wage / l_lcm);
	--
	hr_utility.trace('***** after devide by ' || l_lcm || ' *****');
	hr_utility.trace('l_sal_taxable_amount    : ' || l_sal_taxable_amount);
	hr_utility.trace('l_sal_non_taxable_amount: ' || l_sal_non_taxable_amount);
	hr_utility.trace('l_mtr_taxable_amount    : ' || l_mtr_taxable_amount);
	hr_utility.trace('l_mtr_non_taxable_amount: ' || l_mtr_non_taxable_amount);
	hr_utility.trace('l_sal_si_wage           : ' || l_sal_si_wage);
	hr_utility.trace('l_mtr_si_wage           : ' || l_mtr_si_wage);
	hr_utility.trace('l_sal_income            : ' || l_sal_income);
	hr_utility.trace('l_mtr_income            : ' || l_mtr_income);
	--
	-- This is just to ensure that payment is split correctly.
	-- Errors will never be raised.
	--
	if (l_sal_taxable_amount + l_sal_non_taxable_amount) <> l_sal_income
	or (l_mtr_taxable_amount + l_mtr_non_taxable_amount) <> l_mtr_income then
		fnd_message.set_name('PAY', 'PAY_JP_CMA_INV_TOTAL_PAY');
		fnd_message.raise_error;
	end if;
	--
	-- This is just to ensure each amount is integer amount.
	-- Errors will never be raised.
	--
	if hr_jp_standard_pkg.is_integer(l_sal_taxable_amount)     = 'N'
	or hr_jp_standard_pkg.is_integer(l_sal_non_taxable_amount) = 'N'
	or hr_jp_standard_pkg.is_integer(l_mtr_taxable_amount)     = 'N'
	or hr_jp_standard_pkg.is_integer(l_mtr_non_taxable_amount) = 'N' then
		fnd_message.set_name('PAY', 'PAY_JP_CMA_INVALID_AMOUNT');
		fnd_message.raise_error;
	end if;
	--
	-- Initialization for cma_rec.
	-- Unnecessary values are returned by null values.
	--
	if l_sal_taxable_flag or l_sal_non_taxable_flag then
		if l_sal_taxable_amount = 0 and l_sal_non_taxable_amount = 0 then
			if l_sal_taxable_flag then
				p_cma_rec.taxable_amount := l_sal_taxable_amount;
			else
				p_cma_rec.non_taxable_amount := l_sal_non_taxable_amount;
			end if;
		else
			if l_sal_taxable_amount <> 0 then
				p_cma_rec.taxable_amount := l_sal_taxable_amount;
			end if;
			--
			if l_sal_non_taxable_amount <> 0 then
				p_cma_rec.non_taxable_amount := l_sal_non_taxable_amount;
			end if;
		end if;
	end if;
	--
	if l_mtr_taxable_flag or l_mtr_non_taxable_flag then
		if l_mtr_taxable_amount = 0 and l_mtr_non_taxable_amount = 0 then
			if l_mtr_taxable_flag then
				p_cma_rec.mtr_taxable_amount := l_mtr_taxable_amount;
			else
				p_cma_rec.mtr_non_taxable_amount := l_mtr_non_taxable_amount;
			end if;
		else
			if l_mtr_taxable_amount <> 0 then
				p_cma_rec.mtr_taxable_amount := l_mtr_taxable_amount;
			end if;
			--
			if l_mtr_non_taxable_amount <> 0 then
				p_cma_rec.mtr_non_taxable_amount := l_mtr_non_taxable_amount;
			end if;
		end if;
	end if;
	--
	if l_sal_si_flag then
		p_cma_rec.si_wage := l_sal_si_wage;
		--
		-- Return null when 0 for adjustment values.
		--
		if l_sal_si_wage <> 0 then
			p_cma_rec.si_wage_adj := - l_sal_si_wage;
		end if;
	end if;
	--
	if l_mtr_si_flag then
		p_cma_rec.mtr_si_wage := l_mtr_si_wage;
		--
		-- Return null when 0 for adjustment values.
		--
		if l_mtr_si_wage <> 0 then
			p_cma_rec.mtr_si_wage_adj := - l_mtr_si_wage;
		end if;
	end if;
	--
	if l_sal_si_flag or l_mtr_si_flag then
		p_cma_rec.si_fixed_wage		:= l_sal_si_wage + l_mtr_si_wage;
		p_cma_rec.ui_wage_adj		:= l_sal_si_wage + l_mtr_si_wage
						 - l_sal_income - l_mtr_income;
		--
		-- Return null when 0 for adjustment values.
		--
		if p_cma_rec.ui_wage_adj = 0 then
			p_cma_rec.ui_wage_adj := null;
		end if;
	end if;
	--
	hr_utility.trace('***** output *****');
	hr_utility.trace('p.taxable_amount         : ' || p_cma_rec.taxable_amount);
	hr_utility.trace('p.non_taxable_amount     : ' || p_cma_rec.non_taxable_amount);
	hr_utility.trace('p.mtr_taxable_amount     : ' || p_cma_rec.mtr_taxable_amount);
	hr_utility.trace('p.mtr_non_taxable_amount : ' || p_cma_rec.mtr_non_taxable_amount);
	hr_utility.trace('p.si_wage                : ' || p_cma_rec.si_wage);
	hr_utility.trace('p.si_wage_adj            : ' || p_cma_rec.si_wage_adj);
	hr_utility.trace('p.mtr_si_wage            : ' || p_cma_rec.mtr_si_wage);
	hr_utility.trace('p.mtr_si_wage_adj        : ' || p_cma_rec.mtr_si_wage_adj);
	hr_utility.trace('p.si_fixed_wage          : ' || p_cma_rec.si_fixed_wage);
	hr_utility.trace('p.ui_wage_adj            : ' || p_cma_rec.ui_wage_adj);
	if p_record_exist then
		hr_utility.trace('p_record_exist           : TRUE');
	else
		hr_utility.trace('p_record_exist           : FALSE');
	end if;
	--
	hr_utility.set_location('Leaving: ' || c_proc, 100);
end get_cma_info;
--
end per_jp_cma_utility_pkg;

/
