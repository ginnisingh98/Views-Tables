--------------------------------------------------------
--  DDL for Package Body PAY_JP_CREATE_CMA_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_JP_CREATE_CMA_PKG" as
/* $Header: pyjpcmap.pkb 120.2.12010000.4 2008/08/06 07:35:10 ubhat ship $ */
--
-- Constants
--
c_package		constant varchar2(31) := 'pay_jp_create_cma_pkg.';
c_cma_ele_name	constant pay_element_types_f.element_name%TYPE := 'SAL_CMA_PROC';
c_itax_elm_name		constant pay_element_types_f.element_name%TYPE := 'COM_ITX_INFO';
c_non_res_iv_name	constant pay_input_values_f.name%TYPE := 'NRES_FLAG';
-- need to set irregular def val except hr_api.g_varchar2 (entry_value_tbl exclude setting default value of parameter)
c_def_val varchar2(1000) := to_char(hr_api.g_number);
c_value_if_null_tbl	constant pay_jp_bee_utility_pkg.t_varchar2_tbl
  := pay_jp_bee_utility_pkg.entry_value_tbl(c_def_val,c_def_val,c_def_val,c_def_val,c_def_val,c_def_val,c_def_val,c_def_val,c_def_val,c_def_val,c_def_val,c_def_val,c_def_val,c_def_val,c_def_val);
c_non_taxable_GlbVal_name		constant varchar2(80) := 'G_SAL_CMA_PUBLIC_TRANSPORT_NTXBL_ERN_MAX';
c_non_res_elm_name	constant pay_element_types_f.element_name%TYPE := 'COM_NRES_INFO';
c_non_res_date_iv_name	constant pay_input_values_f.name%TYPE := 'NRES_START_DATE';
c_res_date_iv_name	constant pay_input_values_f.name%TYPE := 'PROJECTED_RES_DATE';
--
-- Global Variables
--
g_element_type_id	number;
g_non_res_iv_id		number;
g_non_taxable_limit_1mth	number;
g_non_res_date_iv_id	number;
g_res_date_iv_id	number;
-- ----------------------------------------------------------------------------
-- |----------------------------< insert_session >----------------------------|
-- ----------------------------------------------------------------------------
procedure insert_session(p_effective_date in date)
is
begin
	insert into fnd_sessions(
		session_id,
		effective_date)
	values(	userenv('sessionid'),
		p_effective_date);
	commit;
end insert_session;
-- ----------------------------------------------------------------------------
-- |----------------------------< delete_session >----------------------------|
-- ----------------------------------------------------------------------------
procedure delete_session
is
begin
	delete
	from	fnd_sessions
	where	session_id = userenv('sessionid');
	commit;
end delete_session;
-- ----------------------------------------------------------------------------
-- |-----------------------------< transfer_asg >-----------------------------|
-- ----------------------------------------------------------------------------
procedure transfer_asg(
	p_business_group_id				in number,
	p_payroll_id					in number,
	p_assignment_id					in number,
	p_payment_date					in date, -- bug 4029525
	p_effective_date				in date,
	p_upload_date					in date,
	p_assignment_number				in varchar2,
	p_full_name						in varchar2,
	p_batch_id						in number,
	p_create_entry_if_not_exist		in varchar2,
	p_create_asg_set_for_errored	in varchar2,
	p_assignment_set_id				in out nocopy number,
	p_assignment_set_name			in out nocopy varchar2)
is
	l_proc					varchar2(61);
	--
	l_non_res_flag			hr_lookups.lookup_code%TYPE;
	l_cma_rec				per_jp_cma_utility_pkg.cma_rec;
--	itax_type_is_null		exception;
	multiple_traffic_tool_rec		exception;
	--
	l_ee_rec				pay_jp_bee_utility_pkg.t_ee_rec;
	l_eev_rec				pay_jp_bee_utility_pkg.t_eev_rec;
	l_new_value_tbl			pay_jp_bee_utility_pkg.t_varchar2_tbl;
	--
	l_is_different			boolean := false;
	l_record_exist			boolean := false;
	l_change_type			hr_lookups.lookup_code%type;
	l_write_all				boolean := false;
	l_batch_line_id			number;
	l_batch_line_ovn		number;
	--
	l_index					number;
	--
	l_non_res_date		date;
	l_res_date		date;
	--
	procedure create_asg_set_amd
	is
	begin
		if p_create_asg_set_for_errored = 'Y' then
			if p_assignment_set_id is null then
				hr_jp_ast_utility_pkg.create_asg_set_with_request_id(
					p_prefix		=> 'REQUEST_ID_',
					p_business_group_id	=> p_business_group_id,
					p_payroll_id		=> p_payroll_id,
					p_assignment_set_id	=> p_assignment_set_id,
					p_assignment_set_name	=> p_assignment_set_name);
				commit;
			end if;
			--
			hr_jp_ast_utility_pkg.create_asg_set_amd(
				p_assignment_set_id	=> p_assignment_set_id,
				p_assignment_id		=> p_assignment_id,
				p_include_or_exclude	=> 'I');
			commit;
		end if;
	end create_asg_set_amd;
begin
	--
	l_proc := c_package || 'transfer_asg';
	--
	hr_utility.set_location('Entering : ' || l_proc, 10);
	--
	hr_utility.trace('********************');
	hr_utility.trace('assignment_id     : ' || to_char(p_assignment_id));
	hr_utility.trace('assignment_number : ' || p_assignment_number);
	hr_utility.trace('upload_date       : ' || to_char(p_upload_date));
	--
	-- Derive commutation allowance information from PAY_ELEMENT_ENTRIES_F.
	--
	pay_jp_bee_utility_pkg.get_ee(
		p_assignment_id		=> p_assignment_id,
		p_element_type_id	=> g_element_type_id,
		p_effective_date	=> p_upload_date,
		p_ee_rec			=> l_ee_rec,
		p_eev_rec			=> l_eev_rec);
	--
	-- BEE line is created
	-- 1. When element entry exists and one of input values to be transfered needs to be updated.
	-- 2. When element entry does not exist and p_create_entry_if_not_exist is set to 'Y'.
	--
--	if (l_ee_rec.element_entry_id is not null)
--	or (p_create_entry_if_not_exist = 'Y') then

	--
	-- Derive Non-resident flag as of Upload Date
	--
	l_non_res_date := pay_jp_balance_pkg.get_entry_value_date(
				p_input_value_id	=> g_non_res_date_iv_id,
				p_assignment_id		=> p_assignment_id,
				p_effective_date	=> p_upload_date);
	l_res_date := nvl(pay_jp_balance_pkg.get_entry_value_date(
				p_input_value_id	=> g_res_date_iv_id,
				p_assignment_id		=> p_assignment_id,
				p_effective_date	=> p_upload_date), TO_DATE('47121231','YYYYMMDD'));

	if l_non_res_date is not null then
		if (l_non_res_date <= p_upload_date) and (p_upload_date < l_res_date) then
			l_non_res_flag := 'Y';
		else
			l_non_res_flag := 'N';
		end if;
	else
		l_non_res_flag := nvl(pay_jp_balance_pkg.get_entry_value_char(
				p_input_value_id	=> g_non_res_iv_id,
				p_assignment_id		=> p_assignment_id,
				p_effective_date	=> p_upload_date), 'N');
	end if;

	--
	hr_utility.trace('non_res_flag : ' || l_non_res_flag);
	--
	-- Derive commutation allowance information from element entries.
	--
	per_jp_cma_utility_pkg.get_cma_info(
		p_business_group_id			=> p_business_group_id,
		p_assignment_id				=> p_assignment_id,
		p_payment_date				=> p_payment_date, -- bug 4029525
		p_effective_date			=> p_effective_date,
		p_non_taxable_limit_1mth	=> g_non_taxable_limit_1mth,
		p_cma_rec					=> l_cma_rec,
		p_record_exist				=> l_record_exist);
	--
	-- If there're multiple traffic tool record, skip processing for current assignment and output log.
	--
	if l_cma_rec.multiple_entry_warning then
		hr_utility.trace('Multiple car. Skip processing');
		raise multiple_traffic_tool_rec;
	end if;
	--
	if (l_ee_rec.element_entry_id is not null) or (l_record_exist) then
		--
		-- value_if_null is like value used as "default for" clause in FastFormula.
		--
		l_new_value_tbl(1)	:= to_char(l_cma_rec.non_taxable_amount);
		l_new_value_tbl(2)	:= to_char(l_cma_rec.mtr_non_taxable_amount);
		if l_non_res_flag = 'N' then
			l_new_value_tbl(3)	:= to_char(l_cma_rec.taxable_amount);
			l_new_value_tbl(4)	:= to_char(l_cma_rec.mtr_taxable_amount);
			-- bug.5438168. Changed to set null instead of '0'.
			l_new_value_tbl(5)	:= null;
			l_new_value_tbl(6)	:= null;
		else
			-- bug.5438168. Changed to set null instead of '0'.
			l_new_value_tbl(3)	:= null;
			l_new_value_tbl(4)	:= null;
			l_new_value_tbl(5)	:= to_char(l_cma_rec.taxable_amount);
			l_new_value_tbl(6)	:= to_char(l_cma_rec.mtr_taxable_amount);
		end if;
		l_new_value_tbl(7)	:= to_char(l_cma_rec.si_wage);
		l_new_value_tbl(8)	:= to_char(l_cma_rec.mtr_si_wage);
		l_new_value_tbl(9)	:= to_char(l_cma_rec.si_wage_adj);
		l_new_value_tbl(10)	:= to_char(l_cma_rec.mtr_si_wage_adj);
		l_new_value_tbl(11)	:= to_char(l_cma_rec.si_fixed_wage);
		l_new_value_tbl(12)	:= to_char(l_cma_rec.ui_wage_adj);
		--
		-- Check whether the new_value_tbl is different from eev_rec.entry_value_tbl.
		-- The following procedure changes new_value_tbl based on eev.
		--
		-- bug.5438168. c_value_if_null_tbl is changed to use hr_api.g_varchar2
		-- because new behavior sets null values for unnecessary input values.
		--
		pay_jp_bee_utility_pkg.set_eev(
			p_ee_rec				=> l_ee_rec,
			p_eev_rec				=> l_eev_rec,
			p_value_if_null_tbl		=> c_value_if_null_tbl,
			p_new_value_tbl			=> l_new_value_tbl,
			p_is_different			=> l_is_different);
		--
		if l_is_different then
			--
			-- Write to output file
			--
			if l_ee_rec.element_entry_id is null then
				hr_utility.trace('EE not exist. Create EE.');
				--
				-- If element does not exist, "Insert" mode.
				-- Also output all entry values to be transfered.
				--
				l_change_type	:= 'I';
				l_write_all	:= true;
			else
				hr_utility.trace('EE exists. Compare Start.');
				--
				-- Since the element is nonrecurring type, "Correction" mode.
				-- In this case, only the entry values to be changed are shown in output file.
				--
				l_change_type := 'C';
			end if;
			pay_jp_bee_utility_pkg.out(
				p_full_name		=> p_full_name,
				p_assignment_number	=> p_assignment_number,
				p_effective_date	=> p_upload_date,
				p_change_type		=> l_change_type,
				p_eev_rec		=> l_eev_rec,
				p_new_value_tbl		=> l_new_value_tbl,
				p_write_all		=> l_write_all);
			--
			-- Create BEE Line
			--
/* bug.5438168. commented out.
			l_index		:= l_new_value_tbl.first;
			while l_index is not null loop
				hr_utility.trace('Set zero' || to_char(l_index));
				--
				if l_new_value_tbl(l_index) is null then
					l_new_value_tbl(l_index) := c_value_if_null_tbl(l_index);
				end if;
				--
				l_index := l_new_value_tbl.next(l_index);
			end loop;
*/
			l_eev_rec.entry_value_tbl := l_new_value_tbl;
			pay_jp_bee_utility_pkg.create_batch_line(
				p_batch_id			=> p_batch_id,
				p_assignment_id			=> p_assignment_id,
				p_assignment_number		=> p_assignment_number,
				p_element_type_id		=> g_element_type_id,
				p_element_name			=> c_cma_ele_name,
				p_effective_date		=> p_upload_date,
				p_ee_rec			=> l_ee_rec,
				p_eev_rec			=> l_eev_rec,
				p_batch_line_id			=> l_batch_line_id,
				p_object_version_number		=> l_batch_line_ovn);
			commit;
		end if;
	end if;
	--
	hr_utility.set_location('Leaving : ' || l_proc, 20);
exception
	when multiple_traffic_tool_rec then
		pay_jp_bee_utility_pkg.log(
			p_full_name					=> p_full_name,
			p_assignment_number			=> p_assignment_number,
			p_application_short_name	=> 'PAY',
			p_message_name				=> '',
			p_token1					=> 'EFFECTIVE_DATE',
			p_value1					=> fnd_date.date_to_chardate(p_effective_date));
		create_asg_set_amd;
		--
		hr_utility.set_location('Leaving : ' || l_proc, 26);
  --
  when others then
  --
    pay_jp_bee_utility_pkg.log(
      p_full_name              => p_full_name,
      p_assignment_number      => p_assignment_number,
      p_application_short_name => 'PAY',
      p_message_name           => '',
      p_token1                 => 'ERROR',
      p_value1                 => to_char(sqlcode)||':'||substrb(sqlerrm,1,100));
  --
		hr_utility.trace('transfer_asg ass num   : ' || p_assignment_number);
  --
		hr_utility.trace('transfer_asg erro code : ' || to_char(sqlcode));
		hr_utility.trace('transfer_asg erro msg  : ' || substrb(sqlerrm,1,100));
  --
    hr_utility.set_location('Leaving : ' || l_proc, 30);
  --
end transfer_asg;
-- ----------------------------------------------------------------------------
-- |---------------------< transfer_from_cma_info_to_bee >--------------------|
-- ----------------------------------------------------------------------------
procedure transfer_from_cma_info_to_bee(
	p_errbuf		 out nocopy varchar2,
	p_retcode		 out nocopy varchar2,
	p_business_group_id		in number,
	p_payroll_id			in number,
	p_time_period_id		in number,
	---- bug 4029525 ----
	-- changed parameter order
	p_payment_date			in varchar2,
	p_upload_date			in varchar2,
	p_effective_date		in varchar2,
	---------------------
	p_batch_name			in varchar2,
	p_action_if_exists		in varchar2,
	p_reject_if_future_changes	in varchar2,
	p_date_effective_changes	in varchar2,
	p_purge_after_transfer		in varchar2,
	p_assignment_set_id		in number,
	p_create_entry_if_not_exist	in varchar2,
	p_create_asg_set_for_errored	in varchar2)
is
	l_proc				varchar2(61);
	--
	l_payment_date			date; -- bug 4029525
	l_effective_date		date;
	l_upload_date			date;
	l_period_start_date		date;
	l_period_end_date		date;
	--
	l_date_effective_changes	pay_batch_headers.date_effective_changes%TYPE;
	l_batch_id			number;
	l_batch_ovn			number;
	--
	l_asg_rec			hr_jp_ast_utility_pkg.t_asg_rec;
	l_assignment_set_id		number;
	l_assignment_set_name		hr_assignment_sets.assignment_set_name%type;
begin
	--
	l_proc := c_package || 'transfer_process_main';
	--
	l_payment_date   := fnd_date.canonical_to_date(p_payment_date); -- bug 4029525
	l_effective_date := fnd_date.canonical_to_date(p_effective_date);
	l_upload_date    := fnd_date.canonical_to_date(p_upload_date);
	--
	l_date_effective_changes := p_date_effective_changes;
	--
	hr_utility.set_location('Entering : ' || l_proc, 10);
	--
	-- Validate p_time_period_id and p_upload_date
	--
	pay_jp_bee_utility_pkg.chk_upload_date(
		p_time_period_id	=> p_time_period_id,
		p_upload_date		=> l_upload_date,
		p_period_start_date	=> l_period_start_date,
		p_period_end_date	=> l_period_end_date);
	--
	-- Create BEE Header
	-- Batch Source    : <Request ID>
	-- Batch Reference : <Element Name>
	--
	-- Validate Date Effective Changes
	--
	pay_jp_bee_utility_pkg.chk_date_effective_changes(
		p_action_if_exists		=> p_action_if_exists,
		p_reject_if_future_changes	=> p_reject_if_future_changes,
		p_date_effective_changes	=> l_date_effective_changes);
	--
	-- Bug.2760646
	-- Need to populate record into fnd_sessions
	-- because the formula with this assignment set possibly calls
	-- dbis which includes fnd_sessions table, e.g. PER_EMP_NUMBER.
	-- If no records in fnd_sessions, PER_EMP_NUMBER will raise error
	-- because FF_USER_ENTITIES.NOTFOUND_ALLOWED_FLAG is "N".
	-- Note FND_SESSIONS.EFFECTIVE_DATE is not changed during the processing
	-- while the context DATE_EARNED changes for each assignment.
	--
	---- bug 4029525 ----
--	insert_session(l_effective_date);
	insert_session(l_payment_date);
	---------------------
	--
	pay_batch_element_entry_api.create_batch_header(
		p_validate			=> false,
		---- bug 4029525 ----
	--	p_session_date			=> l_effective_date,
		p_session_date			=> l_payment_date,
		---------------------
		p_batch_name			=> substrb(p_batch_name, 1, 30),
		p_business_group_id		=> p_business_group_id,
		p_action_if_exists		=> p_action_if_exists,
		p_batch_reference		=> substrb(c_cma_ele_name, 1, 30),
		p_batch_source			=> substrb(to_char(fnd_global.conc_request_id), 1, 30),
		p_date_effective_changes	=> l_date_effective_changes,
		p_purge_after_transfer		=> p_purge_after_transfer,
		p_reject_if_future_changes	=> p_reject_if_future_changes,
		p_batch_id			=> l_batch_id,
		p_object_version_number 	=> l_batch_ovn);
	commit;
	--
	hr_utility.trace('batch_id : ' || to_char(l_batch_id));
	--
	-- Initialize Global Variables
	--
	g_element_type_id	:= hr_jp_id_pkg.element_type_id(c_cma_ele_name, p_business_group_id);
	g_non_res_iv_id		:= hr_jp_id_pkg.input_value_id(c_itax_elm_name, c_non_res_iv_name, p_business_group_id);
	--
	g_non_res_date_iv_id	:= hr_jp_id_pkg.input_value_id(c_non_res_elm_name, c_non_res_date_iv_name, p_business_group_id);
	g_res_date_iv_id	:= hr_jp_id_pkg.input_value_id(c_non_res_elm_name, c_res_date_iv_name, p_business_group_id);
	--
	select	to_number(global_value)
	into	g_non_taxable_limit_1mth
	from	ff_globals_f
	where
	---- bug 4029525 ----
	--	l_effective_date
		l_payment_date
	---------------------
			between effective_start_date and effective_end_date
	and		global_name = c_non_taxable_GlbVal_name;
	--
	-- Derive payroll assignments to be processed
	--
	hr_jp_ast_utility_pkg.pay_asgs(
		p_payroll_id			=> p_payroll_id,
		---- bug 4029525 ----
	--	p_effective_date		=> l_effective_date,
		p_effective_date		=> l_payment_date,
		---------------------
		p_start_date			=> l_upload_date,
		p_end_date				=> l_period_end_date,
		p_assignment_set_id		=> p_assignment_set_id,
		p_asg_rec				=> l_asg_rec);
	--
	-- Assignment to be transfered Loop
	--
	for i in 1..l_asg_rec.assignment_id_tbl.count loop
		transfer_asg(
			p_business_group_id		=> p_business_group_id,
			p_payroll_id			=> p_payroll_id,
			p_assignment_id			=> l_asg_rec.assignment_id_tbl(i),
			p_payment_date			=> l_payment_date, -- bug 4029525
			p_effective_date		=> l_effective_date,
			p_upload_date			=> l_asg_rec.effective_date_tbl(i),
			p_assignment_number		=> l_asg_rec.assignment_number_tbl(i),
			p_full_name				=> l_asg_rec.full_name_tbl(i),
			p_batch_id				=> l_batch_id,
			p_create_entry_if_not_exist	=> p_create_entry_if_not_exist,
			p_create_asg_set_for_errored	=> p_create_asg_set_for_errored,
			p_assignment_set_id		=> l_assignment_set_id,
			p_assignment_set_name		=> l_assignment_set_name);
	end loop;
	--
	-- Write the assignment_set_name created into log file
	--
	if l_assignment_set_id is not null then
		fnd_message.set_name('PAY', 'PAY_JP_BEE_UTIL_ASG_SET_CREATE');
		fnd_message.set_token('ASSIGNMENT_SET_NAME', l_assignment_set_name);
		fnd_file.put_line(fnd_file.log, fnd_message.get);
	end if;
	--
	-- When no batch lines are created, delete batch header and set message as errbuf.
	--
	if pay_jp_bee_utility_pkg.g_num_of_outs = 0 then
		hr_utility.trace('BEE Header deleted');
		--
		pay_batch_element_entry_api.delete_batch_header(
			p_validate		=> false,
			p_batch_id		=> l_batch_id,
			p_object_version_number	=> l_batch_ovn);
		commit;
		--
		fnd_message.set_name('PAY', 'PAY_JP_BEE_UTIL_NO_ASGS');
		p_errbuf := fnd_message.get;
		fnd_file.put_line(fnd_file.log, p_errbuf);
	end if;
	--
	-- If at least 1 assignment failed to process, set concurrent request status "Incomplete".
	--
	if pay_jp_bee_utility_pkg.g_num_of_logs > 0 then
		p_retcode := 1;
	else
		p_retcode := 0;
	end if;
	--
	delete_session;
	--
	hr_utility.trace('retcode : ' || p_retcode);
	hr_utility.trace('errbuf  : ' || p_errbuf);
	hr_utility.set_location('Leaving : ' || l_proc, 20);
end transfer_from_cma_info_to_bee;
--
end pay_jp_create_cma_pkg;

/
