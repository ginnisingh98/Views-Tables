--------------------------------------------------------
--  DDL for Package Body PAY_KR_BAL_INIT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_KR_BAL_INIT_PKG" as
/* $Header: pykrbini.pkb 120.1 2005/06/30 03:58:54 pdesu noship $ */
--
-- Constants
--
c_package	varchar2(31) := '  pay_kr_bal_init_pkg.';
c_sot		date := fnd_date.canonical_to_date('0001/01/01');
c_eot		date := fnd_date.canonical_to_date('4712/12/31');
c_iv_limit	number := 15;
------------------------------------------------------------------------
procedure create_structure(
		p_batch_id		in number,
		p_classification_id	in number,
		p_element_name_prefix	in varchar2)
------------------------------------------------------------------------
is
	l_proc			varchar2(61) := c_package || 'create_bal_init_struct';
	l_business_group_id	per_business_groups_perf.business_group_id%TYPE;
	l_business_group_name	per_business_groups_perf.name%TYPE;
	l_legislation_code	per_business_groups_perf.legislation_code%TYPE;
	l_currency_code		per_business_groups_perf.currency_code%TYPE;
	l_classification_name	pay_element_classifications.classification_name%TYPE;
	l_element_type_id	pay_element_types_f.element_type_id%TYPE;
	l_element_name		pay_element_types_f.element_name%TYPE;
	l_element_link_id	number;
	l_input_value_id	number;
	l_counter		number;
	l_dummy			varchar2(255);
	--
	-- Cursor to derive necessary parameters in later phase.
	--
	cursor csr_init is
		select	pbg.business_group_id,
			pbg.name,
			pbg.legislation_code,
			pec.classification_name,
			pbg.currency_code
		from	pay_element_classifications	pec,
			per_business_groups_perf	pbg,
			pay_balance_batch_headers	h
		where	h.batch_id = p_batch_id
		and	upper(pbg.name) = upper(h.business_group_name)
		and	pec.classification_id = p_classification_id
		and	pec.balance_initialization_flag = 'Y'
		and	nvl(pec.business_group_id, pbg.business_group_id) = pbg.business_group_id
		and	nvl(pec.legislation_code, pbg.legislation_code) = pbg.legislation_code;
	--
	-- Cursor to return balance types without balance initialization element feed
	-- for current batch_id
	--
	cursor csr_balance_wo_feed is
		select	pbt.balance_type_id,
			pbt.balance_name,
			pbt.balance_uom
		from	pay_balance_types	pbt
		where	upper(pbt.balance_name) IN
			(
				select	upper(balance_name)	balance_name
				from	pay_balance_batch_lines
				where	batch_id = p_batch_id
			)
		and	nvl(pbt.business_group_id, l_business_group_id) = l_business_group_id
		and	nvl(pbt.legislation_code, l_legislation_code) = l_legislation_code
		and	not exists(
				select	null
				from	pay_element_classifications	pec,
					pay_element_types_f		pet,
					pay_input_values_f		piv,
					pay_balance_feeds_f		pbf
				where	pbf.balance_type_id = pbt.balance_type_id
				and	pbf.effective_start_date = c_sot
				and	pbf.effective_end_date = c_eot
				and	nvl(pbf.business_group_id, l_business_group_id) = l_business_group_id
				and	nvl(pbf.legislation_code, l_legislation_code) = l_legislation_code
				and	piv.input_value_id = pbf.input_value_id
				and	piv.effective_start_date = c_sot
				and	piv.effective_end_date = c_eot
				and	pet.element_type_id = piv.element_type_id
				and	pet.effective_start_date = c_sot
				and	pet.effective_end_date = c_eot
				and	pec.classification_id = pet.classification_id
				and	pec.balance_initialization_flag = 'Y')
		order by pbt.balance_uom, pbt.balance_name;
	--------------------------------------------------------------
	procedure create_et_el(
			p_element_type_id	out NOCOPY number,
			p_element_name		out NOCOPY varchar2,
			p_element_link_id	out NOCOPY number)
	--------------------------------------------------------------
	is
		function element_name return varchar2
		is
			l_max_seq	number;
			l_seq		number;
			cursor csr_et is
				select	element_name
				from	pay_element_types_f
				where	element_name like replace(p_element_name, '_', '\_') || '%' escape '\';
		begin
			l_max_seq := 1;
			p_element_name := p_element_name_prefix || '_';
			--
			for l_rec in csr_et loop
				begin
					l_seq := to_number(replace(l_rec.element_name, p_element_name));
				exception
					when others then
						exit;
				end;
				--
				if l_seq >= l_max_seq then
					l_max_seq := l_seq + 1;
				end if;
			end loop;
			--
			return p_element_name || to_char(l_max_seq);
		end element_name;
	begin
		p_element_name := element_name;
		--
		p_element_type_id := pay_db_pay_setup.create_element(
					p_element_name		=> p_element_name,
					p_effective_start_date	=> c_sot,
					p_effective_end_date	=> c_eot,
					p_classification_name	=> l_classification_name,
					p_input_currency_code	=> l_currency_code,
					p_output_currency_code	=> l_currency_code,
					p_processing_type	=> 'N',
					p_adjustment_only_flag	=> 'Y',
					p_process_in_run_flag	=> 'Y',
					p_business_group_name	=> l_business_group_name,
					p_post_termination_rule	=> 'Final Close');
		--
		update	pay_element_types_f
		set	element_information1 = 'B'
		where	element_type_id = p_element_type_id;
		--
		p_element_link_id := pay_db_pay_setup.create_element_link(
					p_element_name          => p_element_name,
					p_link_to_all_pyrlls_fl => 'Y',
					p_standard_link_flag    => 'N',
					p_effective_start_date  => c_sot,
					p_effective_end_date    => c_eot,
					p_business_group_name   => l_business_group_name);
	end create_et_el;
	--------------------------------------------------------------
	procedure create_iv_ivl_bf(
			p_balance_type_id	in number,
			p_balance_uom		in varchar2,
			p_element_type_id	in number,
			p_element_name		in varchar2,
			p_element_link_id	in number,
			p_input_value_name	in varchar2,
			p_display_sequence	in number)
	--------------------------------------------------------------
	is
	begin
		l_input_value_id := pay_db_pay_setup.create_input_value(
					p_element_name		=> p_element_name,
					p_name			=> p_input_value_name,
					p_uom_code		=> p_balance_uom,
					p_business_group_name	=> l_business_group_name,
					p_effective_start_date	=> c_sot,
					p_effective_end_date	=> c_eot,
					p_display_sequence	=> p_display_sequence);
		--
		hr_input_values.create_link_input_value(
			p_insert_type		=> 'INSERT_INPUT_VALUE',
			p_element_link_id	=> p_element_link_id,
			p_input_value_id	=> l_input_value_id,
			p_input_value_name	=> p_input_value_name,
			p_costable_type		=> NULL,
			p_validation_start_date	=> c_sot,
			p_validation_end_date	=> c_eot,
			p_default_value		=> NULL,
			p_max_value		=> NULL,
			p_min_value		=> NULL,
			p_warning_or_error_flag	=> NULL,
			p_hot_default_flag	=> NULL,
			p_legislation_code	=> NULL,
			p_pay_value_name	=> NULL,
			p_element_type_id	=> p_element_type_id);
		--
		hr_balances.ins_balance_feed(
			p_option			=> 'INS_MANUAL_FEED',
			p_input_value_id		=> l_input_value_id,
			p_element_type_id		=> p_element_type_id,
			p_primary_classification_id	=> NULL,
			p_sub_classification_id		=> NULL,
			p_sub_classification_rule_id	=> NULL,
			p_balance_type_id		=> p_balance_type_id,
			p_scale				=> '1',
			p_session_date			=> c_sot,
			p_business_group		=> l_business_group_id,
			p_legislation_code		=> NULL,
			p_mode				=> 'USER');
	end create_iv_ivl_bf;
begin
	hr_utility.set_location(l_proc, 10);
	--
	hr_api.mandatory_arg_error(
		p_api_name		=> l_proc,
		p_argument		=> 'batch_id',
		p_argument_value	=> p_batch_id);
	hr_api.mandatory_arg_error(
		p_api_name		=> l_proc,
		p_argument		=> 'classification_id',
		p_argument_value	=> p_classification_id);
	l_dummy := p_element_name_prefix;
	hr_chkfmt.checkformat(
		value	=> l_dummy,
		format	=> 'PAY_NAME',
		output	=> l_dummy,
		minimum	=> null,
		maximum	=> null,
		nullok	=> 'N',
		rgeflg	=> l_dummy,
		curcode	=> null);
	--
	-- Derives necessary local variables and checks the input variables
	-- are correct or not at the same time.
	-- The following SQL will raise NO_DATA_FOUND if input variables
	-- are not correct.
	--
	open csr_init;
	fetch csr_init into
		l_business_group_id,
		l_business_group_name,
		l_legislation_code,
		l_classification_name,
		l_currency_code;
	if csr_init%NOTFOUND then
		close csr_init;
		fnd_message.set_name('PAY', 'PAY_KR_BAL_INIT_INV_PARAM');
		fnd_message.raise_error;
	end if;
	close csr_init;
	--
	-- Loop of balances without initial balance feed for current batch_id.
	--
	for l_rec in csr_balance_wo_feed loop
		if l_counter is null or l_counter >= c_iv_limit then
			l_counter := 1;
			--
			-- Create element type and element link.
			--
			create_et_el(
				p_element_type_id	=> l_element_type_id,
				p_element_name		=> l_element_name,
				p_element_link_id	=> l_element_link_id);
		else
			l_counter := l_counter + 1;
		end if;
		--
		-- Create input_value, link_input_value and balance_feed.
		--
		create_iv_ivl_bf(
			p_balance_type_id	=> l_rec.balance_type_id,
			p_balance_uom		=> l_rec.balance_uom,
			p_element_type_id	=> l_element_type_id,
			p_element_name		=> l_element_name,
			p_element_link_id	=> l_element_link_id,
			p_input_value_name	=> rtrim(substr(l_rec.balance_name, 1, 27)) || '_' || to_char(l_counter),
			p_display_sequence	=> l_counter);
	end loop;
end create_structure;
------------------------------------------------------------------------
procedure create_structure(
		errbuf			out NOCOPY varchar2,
		retcode			out NOCOPY number,
		p_batch_id		in number,
		p_classification_id	in number,
		p_element_name_prefix	in varchar2)
------------------------------------------------------------------------
is
begin
	--
	-- errbuf and retcode are special parameters needed for the SRS.
	-- retcode = 0 means no error and retcode = 2 means an error occurred.
	--
	create_structure(
		p_batch_id		=> p_batch_id,
		p_classification_id	=> p_classification_id,
		p_element_name_prefix	=> p_element_name_prefix);
	--
	commit;
end create_structure;
--
end pay_kr_bal_init_pkg;

/
