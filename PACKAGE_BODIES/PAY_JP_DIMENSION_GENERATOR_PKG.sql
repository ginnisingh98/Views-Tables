--------------------------------------------------------
--  DDL for Package Body PAY_JP_DIMENSION_GENERATOR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_JP_DIMENSION_GENERATOR_PKG" as
/* $Header: pyjpdimg.pkb 120.0 2006/04/24 00:02 ttagawa noship $ */
--
-- Constants
--
c_package	constant varchar2(31) := 'pay_jp_dimension_generator_pkg.';
-- ----------------------------------------------------------------------------
-- |------------------------------< start_date >------------------------------|
-- ----------------------------------------------------------------------------
function start_date(
	p_effective_date	in date,
	p_reset_date		in date,
	p_frequency_type	in varchar2,
	p_frequency		in number) return date
is
	l_start_date		date;
	l_start_date_temp	date;
begin
	if p_frequency_type = 'DAY' then
		l_start_date := p_reset_date + floor((p_effective_date - p_reset_date) / p_frequency) * p_frequency;
	elsif p_frequency_type = 'SMONTH' then
		if mod(p_frequency, 2) = 0 then
			l_start_date := start_date(p_effective_date, p_reset_date, 'MONTH', p_frequency / 2);
		else
			l_start_date := start_date(p_effective_date, p_reset_date, 'MONTH', p_frequency);
			l_start_date_temp := add_months(l_start_date, floor(p_frequency / 2)) + 15;
			if p_effective_date >= l_start_date_temp then
				l_start_date := l_start_date_temp;
			end if;
		end if;
	elsif p_frequency_type = 'MONTH' then
		l_start_date := add_months(p_reset_date, floor(months_between(p_effective_date, p_reset_date) / p_frequency) * p_frequency);
	else
		fnd_message.set_name('PAY', 'PAY_JP_DIM_INVALID_FREQ_TYPE');
		fnd_message.set_token('FREQUENCY_TYPE', p_frequency_type);
		fnd_message.raise_error;
	end if;
	--
	return l_start_date;
end start_date;
-- ----------------------------------------------------------------------------
-- |-------------------------------< end_date >-------------------------------|
-- ----------------------------------------------------------------------------
function end_date(
	p_effective_date	in date,
	p_reset_date		in date,
	p_frequency_type	in varchar2,
	p_frequency		in number) return date
is
	l_start_date	date;
	l_end_date	date;
begin
	if p_frequency_type = 'DAY' then
		l_end_date := start_date(p_effective_date, p_reset_date, p_frequency_type, p_frequency) + p_frequency - 1;
	elsif p_frequency_type = 'SMONTH' then
		if mod(p_frequency, 2) = 0 then
			l_end_date := end_date(p_effective_date, p_reset_date, 'MONTH', p_frequency / 2);
		else
			l_start_date := start_date(p_effective_date, p_reset_date, 'MONTH', p_frequency);
			l_end_date := add_months(l_start_date, floor(p_frequency / 2)) + 14;
			if p_effective_date > l_end_date then
				l_end_date := add_months(l_start_date, p_frequency) - 1;
			end if;
		end if;
	elsif p_frequency_type = 'MONTH' then
		l_end_date := add_months(start_date(p_effective_date, p_reset_date, p_frequency_type, p_frequency), p_frequency) - 1;
	else
		fnd_message.set_name('PAY', 'PAY_JP_DIM_INVALID_FREQ_TYPE');
		fnd_message.set_token('FREQUENCY_TYPE', p_frequency_type);
		fnd_message.raise_error;
	end if;
	--
	return l_end_date;
end end_date;
-- ----------------------------------------------------------------------------
-- |------------------------------< my_replace >------------------------------|
-- ----------------------------------------------------------------------------
function my_replace(
	p_src		in varchar2,
	p_old		in varchar2,
	p_new		in date) return varchar2
is
begin
	return replace(p_src, p_old, fnd_date.date_to_canonical(p_new));
end my_replace;
-- ----------------------------------------------------------------------------
-- |------------------------------< my_replace >------------------------------|
-- ----------------------------------------------------------------------------
function my_replace(
	p_src		in varchar2,
	p_old		in varchar2,
	p_new		in number) return varchar2
is
begin
	return replace(p_src, p_old, fnd_number.number_to_canonical(p_new));
end my_replace;
-- ----------------------------------------------------------------------------
-- |------------------------------< my_replace >------------------------------|
-- ----------------------------------------------------------------------------
function my_replace(
	p_src		in varchar2,
	p_old		in varchar2,
	p_new		in boolean) return varchar2
is
begin
	if p_new then
		return replace(p_src, p_old, 'Y');
	else
		return replace(p_src, p_old, 'N');
	end if;
end my_replace;
-- ----------------------------------------------------------------------------
-- |-------------------------< validate_parameters >--------------------------|
-- ----------------------------------------------------------------------------
procedure validate_parameters(
	p_date_type		in varchar2,
	p_reset_date		in date,
	p_frequency_type	in varchar2,
	p_frequency		in number)
is
	c_proc		constant varchar2(61) := c_package || 'validate_parameters';
begin
	hr_api.mandatory_arg_error(
		p_api_name		=> c_proc,
		p_argument		=> 'date_type',
		p_argument_value	=> p_date_type);
	hr_api.mandatory_arg_error(
		p_api_name		=> c_proc,
		p_argument		=> 'reset_date',
		p_argument_value	=> p_reset_date);
	hr_api.mandatory_arg_error(
		p_api_name		=> c_proc,
		p_argument		=> 'frequency_type',
		p_argument_value	=> p_frequency_type);
	hr_api.mandatory_arg_error(
		p_api_name		=> c_proc,
		p_argument		=> 'frequency',
		p_argument_value	=> p_frequency);
	--
	if p_date_type not in ('DP', 'DE') then
		fnd_message.set_name('PAY', 'PAY_JP_DIM_INVALID_DATE_TYPE');
		fnd_message.set_token('DATE_TYPE', p_date_type);
		fnd_message.raise_error;
	end if;
	--
	if p_reset_date <> trunc(p_reset_date) then
		fnd_message.set_name('PAY', 'PAY_JP_DIM_INVALID_RESET_DATE');
		fnd_message.set_token('RESET_DATE', fnd_date.date_to_chardt(p_reset_date));
		fnd_message.raise_error;
	end if;
	--
	if p_frequency_type not in ('DAY', 'SMONTH', 'MONTH') then
		fnd_message.set_name('PAY', 'PAY_JP_DIM_INVALID_FREQ_TYPE');
		fnd_message.set_token('FREQUENCY_TYPE', p_frequency_type);
		fnd_message.raise_error;
	end if;
	--
	if not (p_frequency between 1 and 99999)
	or p_frequency <> trunc(p_frequency) then
		fnd_message.set_name('PAY', 'PAY_JP_DIM_INVALID_FREQUENCY');
		fnd_message.set_token('FREQUENCY', p_frequency);
		fnd_message.raise_error;
	end if;
end validate_parameters;
-- ----------------------------------------------------------------------------
-- |------------------------------< utilities >-------------------------------|
-- ----------------------------------------------------------------------------
function get_description(
	p_date_type		in varchar2,
	p_reset_date		in date,
	p_frequency_type	in varchar2,
	p_frequency		in number,
	p_exclude_reversal	in boolean) return varchar2
is
	l_description		varchar2(255);
begin
	l_description := 'DATE_TYPE=<DATE_TYPE> RESET_DATE=<RESET_DATE> FREQUENCY_TYPE=<FREQUENCY_TYPE> FREQUENCY=<FREQUENCY> EXCLUDE_REVERSAL=<EXCLUDE_REVERSAL>';
	l_description := replace(l_description, '<DATE_TYPE>', p_date_type);
	l_description := my_replace(l_description, '<RESET_DATE>', p_reset_date);
	l_description := replace(l_description, '<FREQUENCY_TYPE>', p_frequency_type);
	l_description := my_replace(l_description, '<FREQUENCY>', p_frequency);
	l_description := my_replace(l_description, '<EXCLUDE_REVERSAL>', p_exclude_reversal);
	--
--	dbms_output.put_line(l_description);
	--
	return l_description;
end get_description;
--
function get_expiry_checking_code(
	p_date_type		in varchar2,
	p_reset_date		in date,
	p_frequency_type	in varchar2,
	p_frequency		in number) return varchar2
is
	l_expiry_checking_code	varchar2(255);
begin
	l_expiry_checking_code := 'PAY_JP_DYNAMIC_DIMENSION_PKG.<DATE_TYPE>_<RESET_DATE>_<FREQUENCY_TYPE>_<FREQUENCY>_EC';
	l_expiry_checking_code := replace(l_expiry_checking_code, '<DATE_TYPE>', p_date_type);
	l_expiry_checking_code := replace(l_expiry_checking_code, '<RESET_DATE>', to_char(p_reset_date, 'YYYYMMDD'));
	l_expiry_checking_code := replace(l_expiry_checking_code, '<FREQUENCY_TYPE>', p_frequency_type);
	l_expiry_checking_code := my_replace(l_expiry_checking_code, '<FREQUENCY>', p_frequency);
	--
--	dbms_output.put_line(l_expiry_checking_code);
	--
	return l_expiry_checking_code;
end get_expiry_checking_code;
--
function get_start_date_code(
	p_date_type		in varchar2,
	p_reset_date		in date,
	p_frequency_type	in varchar2,
	p_frequency		in number) return varchar2
is
	l_start_date_code	varchar2(255);
begin
	l_start_date_code := 'PAY_JP_DYNAMIC_DIMENSION_PKG.<DATE_TYPE>_<RESET_DATE>_<FREQUENCY_TYPE>_<FREQUENCY>_SD';
	l_start_date_code := replace(l_start_date_code, '<DATE_TYPE>', p_date_type);
	l_start_date_code := replace(l_start_date_code, '<RESET_DATE>', to_char(p_reset_date, 'YYYYMMDD'));
	l_start_date_code := replace(l_start_date_code, '<FREQUENCY_TYPE>', p_frequency_type);
	l_start_date_code := my_replace(l_start_date_code, '<FREQUENCY>', p_frequency);
	--
--	dbms_output.put_line(l_start_date_code);
	--
	return l_start_date_code;
end get_start_date_code;
--
function get_route_name(
	p_route_type		in varchar2,
	p_date_type		in varchar2,
	p_reset_date		in date,
	p_frequency_type	in varchar2,
	p_frequency		in number,
	p_exclude_reversal	in boolean) return varchar2
is
	l_route_name		varchar2(255);
begin
	l_route_name := 'JP_ASG_<DATE_TYPE>_<RESET_DATE>_<FREQUENCY_TYPE>_<FREQUENCY>_<ROUTE_TYPE>_BALANCE_DIMENSION';
	l_route_name := replace(l_route_name, '<DATE_TYPE>', p_date_type);
	l_route_name := replace(l_route_name, '<RESET_DATE>', to_char(p_reset_date, 'YYYYMMDD'));
	l_route_name := replace(l_route_name, '<FREQUENCY_TYPE>', p_frequency_type);
	l_route_name := my_replace(l_route_name, '<FREQUENCY>', p_frequency);
	l_route_name := replace(l_route_name, '<ROUTE_TYPE>', p_route_type);
	if p_exclude_reversal then
		l_route_name := l_route_name || '_EXC_REV';
	end if;
	--
--	dbms_output.put_line(l_route_name);
	--
	return l_route_name;
end get_route_name;
--
function get_template_route_name(
	p_route_type		in varchar2,
	p_date_type		in varchar2,
	p_exclude_reversal	in boolean) return varchar2
is
	l_template_route_name	varchar2(255);
begin
	l_template_route_name := 'JP_ASG_<DATE_TYPE>_<ROUTE_TYPE>_BALANCE_DIMENSION';
	l_template_route_name := replace(l_template_route_name, '<DATE_TYPE>', p_date_type);
	l_template_route_name := replace(l_template_route_name, '<ROUTE_TYPE>', p_route_type);
	if p_exclude_reversal then
		l_template_route_name := l_template_route_name || '_EXC_REV';
	end if;
	l_template_route_name := l_template_route_name || '_TEMPLATE';
	--
--	dbms_output.put_line(l_template_route_name);
	--
	return l_template_route_name;
end get_template_route_name;

function get_route_id(
	p_route_name			in varchar2,
	p_raise_when_no_data_found	boolean default true) return number
is
	l_route_id	number;
begin
	select	route_id
	into	l_route_id
	from	ff_routes
	where	route_name = p_route_name;
	--
	return l_route_id;
exception
	when no_data_found then
		if not p_raise_when_no_data_found then
			return null;
		else
			raise;
		end if;
end get_route_id;
-- ----------------------------------------------------------------------------
-- |-----------------------< upload_balance_dimension >-----------------------|
-- ----------------------------------------------------------------------------
procedure upload_balance_dimension(
	p_balance_dimension_id	in out nocopy number,
	p_dimension_name	in varchar2,
	p_database_item_suffix	in varchar2,
	p_business_group_id	in number,
	p_date_type		in varchar2,
	p_reset_date		in date,
	p_frequency_type	in varchar2,
	p_frequency		in number,
	p_exclude_reversal	in boolean)
is
	l_route_id		number;
	l_description		pay_balance_dimensions.description%type;
	l_dimension_type	pay_balance_dimensions.dimension_type%type;
	l_expiry_checking_level	pay_balance_dimensions.expiry_checking_level%type;
	l_expiry_checking_code	pay_balance_dimensions.expiry_checking_code%type;
	l_period_type		pay_balance_dimensions.period_type%type;
	l_start_date_code	pay_balance_dimensions.start_date_code%type;
begin
	l_route_id := get_route_id('Core Balance Route No Contexts');
	l_description := get_description(p_date_type, p_reset_date, p_frequency_type, p_frequency, p_exclude_reversal);
	--
	if p_date_type = 'DE' then
		--
		-- It is possible to support balance feeding of in-memory run results while running payroll run
		-- for DATE_EARNED dimension using feed_checking_type = 'F'(Full PL/SQL feed checking).
		-- But full PL/SQL feed checking will cause severe performance loss against whole Payroll Run,
		-- so balance feeding for DATE_EARNED dimension is de-supported at the moment.
		--
		-- Expiry checking for DATE_EARNED is supported by PYUGEN using expiry_checking_level = 'E'(Enhanced).
		-- New expiry_information "Previous Period"(2), "Current Period"(3) and "Rollover Expiry"(4)
		-- can be used in this case. But feed checking is not supported for DATE_EARNED,
		-- it is meaningless to support these expiry checking because current run results
		-- are not added up to latest balance, which means latest balance is never expired.
		--
		-- Run balance mechanism is not supported for the following reasons.
		--   1. Current run results are not added up while running Payroll Run,
		--      so PYUGEN cannot derive ASG_RUN value until in-memory run results
		--      are flashed into DB.
		--   2. PAY_RUN_BALANCES table does not have DATE_EARNED column.
		--      To derive DATE_EARNED, it is required to join additional
		--      PAY_ASSIGNMENT_ACTIONS and PAY_PAYROLL_ACTIONS, which is
		--      similar to Run Result route. This is nonsense.
		--   3. Validation using PAY_BALANCE_VALIDATION is not DATE_EARNED compliant
		--      (pay_balance_pkg).
		-- For these reasons, run balance is not supported for DATE_EARNED dimensions.
		-- Intead of than, bulk get_value mechanism (RR route) is supported.
		--
		l_dimension_type	:= 'N';
	else
		l_dimension_type	:= 'A';
		l_expiry_checking_level	:= 'P';
		l_expiry_checking_code	:= get_expiry_checking_code(p_date_type, p_reset_date, p_frequency_type, p_frequency);
	end if;
	--
	-- Following columns are populated not only for DP but also DE dimensions.
	-- The reason to populate these columns for DE dimensions is to support get_value date mode
	-- in pay_jp_balance_view_pkg.get_value. No SRW route is available for DE dimensions,
	-- so there's no impact for run balance functionality.
	--
	l_period_type		:= 'DYNAMIC';
	l_start_date_code	:= get_start_date_code(p_date_type, p_reset_date, p_frequency_type, p_frequency);
	--
	if p_balance_dimension_id is null then
		select	pay_balance_dimensions_s.nextval
		into	p_balance_dimension_id
		from	dual;
		--
		insert into pay_balance_dimensions(
			BALANCE_DIMENSION_ID,
			DIMENSION_NAME,
			DATABASE_ITEM_SUFFIX,
			BUSINESS_GROUP_ID,
			LEGISLATION_CODE,
			DESCRIPTION,
			PAYMENTS_FLAG,
			DIMENSION_TYPE,
			EXPIRY_CHECKING_LEVEL,
			EXPIRY_CHECKING_CODE,
			FEED_CHECKING_TYPE,
			FEED_CHECKING_CODE,
			ROUTE_ID,
			DATABASE_ITEM_FUNCTION,
			DIMENSION_LEVEL,
			ASG_ACTION_BALANCE_DIM_ID,
			SAVE_RUN_BALANCE_ENABLED,
			PERIOD_TYPE,
			START_DATE_CODE)
		values(	p_balance_dimension_id,
			p_dimension_name,
			p_database_item_suffix,
			p_business_group_id,
			null,
			l_description,
			'N',
			l_dimension_type,
			l_expiry_checking_level,
			l_expiry_checking_code,
			null,
			null,
			l_route_id,
			'Y',
			'ASG',
			null,
			'N',
			l_period_type,
			l_start_date_code);
	else
		update	pay_balance_dimensions
		set	description			= l_description,
			payments_flag			= 'N',
			dimension_type			= l_dimension_type,
			expiry_checking_level		= l_expiry_checking_level,
			expiry_checking_code		= l_expiry_checking_code,
			feed_checking_type		= null,
			feed_checking_code		= null,
			route_id			= l_route_id,
			database_item_function		= 'Y',
			dimension_level			= 'ASG',
			asg_action_balance_dim_id	= null,
			save_run_balance_enabled	= 'N',
			period_type			= l_period_type,
			start_date_code			= l_start_date_code
		where	balance_dimension_id = p_balance_dimension_id;
		--
		if sql%rowcount <> 1 then
			raise no_data_found;
		end if;
	end if;
end upload_balance_dimension;
-- ----------------------------------------------------------------------------
-- |-----------------------------< create_route >-----------------------------|
-- ----------------------------------------------------------------------------
procedure create_route(
	p_route_type		in varchar2,
	p_date_type		in varchar2,
	p_reset_date		in date,
	p_frequency_type	in varchar2,
	p_frequency		in number,
	p_exclude_reversal	in boolean,
	p_route_id		out nocopy number)
is
	l_route_name		varchar2(255);
	l_template_route_name	varchar2(255);
	l_template_route_id	number;
	l_optimizer_hint	ff_routes.optimizer_hint%type;
	l_text			varchar2(32767);
	l_description		ff_routes.description%type;
begin
	l_route_name := get_route_name(p_route_type, p_date_type, p_reset_date, p_frequency_type, p_frequency, p_exclude_reversal);
	p_route_id := get_route_id(l_route_name, false);
	--
	if p_route_id is not null then
		return;
	end if;
	--
	l_template_route_name := get_template_route_name(p_route_type, p_date_type, p_exclude_reversal);
	--
	select	route_id,
		optimizer_hint,
		text
	into	l_template_route_id,
		l_optimizer_hint,
		l_text
	from	ff_routes
	where	route_name = l_template_route_name;
	--
	l_text := my_replace(l_text, '<RESET_DATE>', p_reset_date);
	l_text := replace(l_text, '<FREQUENCY_TYPE>', p_frequency_type);
	l_text := my_replace(l_text, '<FREQUENCY>', p_frequency);
	--
	l_description := p_route_type || ' Balance Dimension Route for ' ||
		get_description(p_date_type, p_reset_date, p_frequency_type, p_frequency, p_exclude_reversal);
	--
	select	ff_routes_s.nextval
	into	p_route_id
	from	dual;
	--
	-- Set user_defined_flag = 'Y'
	--
	insert into ff_routes(
		ROUTE_ID,
		ROUTE_NAME,
		USER_DEFINED_FLAG,
		DESCRIPTION,
		OPTIMIZER_HINT,
		TEXT)
	values(	p_route_id,
		l_route_name,
		'Y',
		l_description,
		l_optimizer_hint,
		l_text);
	--
	insert into ff_route_context_usages(
		ROUTE_ID,
		CONTEXT_ID,
		SEQUENCE_NO)
	select	p_route_id,
		context_id,
		sequence_no
	from	ff_route_context_usages
	where	route_id = l_template_route_id;
	--
	insert into ff_route_parameters(
		ROUTE_PARAMETER_ID,
		ROUTE_ID,
		DATA_TYPE,
		PARAMETER_NAME,
		SEQUENCE_NO)
	select	ff_route_parameters_s.nextval,
		p_route_id,
		data_type,
		parameter_name,
		sequence_no
	from	ff_route_parameters
	where	route_id = l_template_route_id;
end create_route;
-- ----------------------------------------------------------------------------
-- |------------------------< create_dimension_route >------------------------|
-- ----------------------------------------------------------------------------
procedure create_dimension_route(
	p_balance_dimension_id	in number,
	p_priority		in number,
	p_route_type		in varchar2,
	p_date_type		in varchar2,
	p_reset_date		in date,
	p_frequency_type	in varchar2,
	p_frequency		in number,
	p_exclude_reversal	in boolean)
is
	l_route_id		number;
	l_balance_type_column	pay_dimension_routes.balance_type_column%type;
	l_run_dimension_id	number;
begin
	if p_route_type = 'SRB' and p_date_type = 'DE' then
		fnd_message.set_name('PAY', 'PAY_JP_DIM_DE_SRB_NOT_SUPPORT');
		fnd_message.raise_error;
	end if;
	--
	create_route(
		p_route_type		=> p_route_type,
		p_date_type		=> p_date_type,
		p_reset_date		=> p_reset_date,
		p_frequency_type	=> p_frequency_type,
		p_frequency		=> p_frequency,
		p_exclude_reversal	=> p_exclude_reversal,
		p_route_id		=> l_route_id);
	--
	if p_route_type = 'RR' then
		l_balance_type_column := 'FEED.balance_type_id';
	else
		select	balance_dimension_id
		into	l_run_dimension_id
		from	pay_balance_dimensions
		where	dimension_name = '_ASG_RUN'
		and	legislation_code = 'JP';
	end if;
	--
	insert into pay_dimension_routes(
		BALANCE_DIMENSION_ID,
		PRIORITY,
		ROUTE_TYPE,
		ROUTE_ID,
		BALANCE_TYPE_COLUMN,
		RUN_DIMENSION_ID,
		OBJECT_VERSION_NUMBER)
	values(	p_balance_dimension_id,
		p_priority,
		p_route_type,
		l_route_id,
		l_balance_type_column,
		l_run_dimension_id,
		1);
end create_dimension_route;
-- ----------------------------------------------------------------------------
-- |--------------------------< chk_dimension_name >--------------------------|
-- ----------------------------------------------------------------------------
procedure chk_dimension_name(
	p_dimension_name	in varchar2,
	p_business_group_id	in number)
is
	c_proc		constant varchar2(61) := c_package || 'chk_dimension_name';
	l_count		number;
begin
	hr_api.mandatory_arg_error(
		p_api_name		=> c_proc,
		p_argument		=> 'dimension_name',
		p_argument_value	=> p_dimension_name);
	--
	select	count(*)
	into	l_count
	from	pay_balance_dimensions
	where	replace(upper(dimension_name), ' ', '_') = replace(upper(p_dimension_name), ' ', '_')
	and	nvl(business_group_id, p_business_group_id) = p_business_group_id
	and	nvl(legislation_code, 'JP') = 'JP';
	--
	if l_count > 0 then
		fnd_message.set_name('PAY', 'PAY_JP_DIM_DUP_DIM_NAME');
		fnd_message.set_token('DIMENSION_NAME', p_dimension_name);
		fnd_message.raise_error;
	end if;
end chk_dimension_name;
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_database_item_suffix >-----------------------|
-- ----------------------------------------------------------------------------
procedure chk_database_item_suffix(
	p_database_item_suffix	in varchar2,
	p_business_group_id	in number)
is
	c_proc			constant varchar2(61) := c_package || 'chk_database_item_suffix';
	l_database_item_suffix	pay_balance_dimensions.database_item_suffix%type;
	l_dummy			varchar2(1);
	l_count			number;
begin
	hr_api.mandatory_arg_error(
		p_api_name		=> c_proc,
		p_argument		=> 'database_item_suffix',
		p_argument_value	=> p_database_item_suffix);
	--
	-- If suffix starts with "_", checkformat will fail.
	-- Following code is to remove preceding underscores.
	--
	l_database_item_suffix := replace(p_database_item_suffix, '_');
	--
	hr_chkfmt.checkformat(
		value		=> l_database_item_suffix,
		format		=> 'PAY_NAME',
		output		=> l_database_item_suffix,
		minimum		=> null,
		maximum		=> null,
		nullok		=> 'N',
		rgeflg		=> l_dummy,
		curcode		=> null);
	--
	select	count(*)
	into	l_count
	from	pay_balance_dimensions
	where	replace(upper(database_item_suffix), ' ', '_') = replace(upper(p_database_item_suffix), ' ', '_')
	and	nvl(business_group_id, p_business_group_id) = p_business_group_id
	and	nvl(legislation_code, 'JP') = 'JP';
	--
	if l_count > 0 then
		fnd_message.set_name('PAY', 'PAY_JP_DIM_DUP_DBI_SUFFIX');
		fnd_message.set_token('DATABASE_ITEM_SUFFIX', p_database_item_suffix);
		fnd_message.raise_error;
	end if;
end chk_database_item_suffix;
-- ----------------------------------------------------------------------------
-- |-----------------------< create_balance_dimension >-----------------------|
-- ----------------------------------------------------------------------------
procedure create_balance_dimension(
	p_dimension_name	in varchar2,
	p_database_item_suffix	in varchar2,
	p_business_group_id	in number,
	p_date_type		in varchar2,
	p_reset_date		in date,
	p_frequency_type	in varchar2,
	p_frequency		in number,
	p_exclude_reversal	in boolean,
	p_balance_dimension_id	out nocopy number,
	p_rebuild_package	in boolean default true)
is
	c_proc			constant varchar2(61) := c_package || 'create_balance_dimension';
begin
	hr_api.mandatory_arg_error(
		p_api_name		=> c_proc,
		p_argument		=> 'business_group_id',
		p_argument_value	=> p_business_group_id);
	--
	chk_dimension_name(p_dimension_name, p_business_group_id);
	chk_database_item_suffix(p_database_item_suffix, p_business_group_id);
	--
	validate_parameters(
		p_date_type		=> p_date_type,
		p_reset_date		=> p_reset_date,
		p_frequency_type	=> p_frequency_type,
		p_frequency		=> p_frequency);
	--
	upload_balance_dimension(
		p_balance_dimension_id	=> p_balance_dimension_id,
		p_dimension_name	=> p_dimension_name,
		p_database_item_suffix	=> p_database_item_suffix,
		p_business_group_id	=> p_business_group_id,
		p_date_type		=> p_date_type,
		p_reset_date		=> p_reset_date,
		p_frequency_type	=> p_frequency_type,
		p_frequency		=> p_frequency,
		p_exclude_reversal	=> p_exclude_reversal);
	--
	if p_date_type = 'DP' then
		create_dimension_route(
			p_balance_dimension_id	=> p_balance_dimension_id,
			p_priority		=> 1,
			p_route_type		=> 'SRB',
			p_date_type		=> p_date_type,
			p_reset_date		=> p_reset_date,
			p_frequency_type	=> p_frequency_type,
			p_frequency		=> p_frequency,
			p_exclude_reversal	=> p_exclude_reversal);
		--
		create_dimension_route(
			p_balance_dimension_id	=> p_balance_dimension_id,
			p_priority		=> 2,
			p_route_type		=> 'RR',
			p_date_type		=> p_date_type,
			p_reset_date		=> p_reset_date,
			p_frequency_type	=> p_frequency_type,
			p_frequency		=> p_frequency,
			p_exclude_reversal	=> p_exclude_reversal);
	else
		create_dimension_route(
			p_balance_dimension_id	=> p_balance_dimension_id,
			p_priority		=> 1,
			p_route_type		=> 'RR',
			p_date_type		=> p_date_type,
			p_reset_date		=> p_reset_date,
			p_frequency_type	=> p_frequency_type,
			p_frequency		=> p_frequency,
			p_exclude_reversal	=> p_exclude_reversal);
	end if;
	--
	-- Rebuild Package of expiry_checking_code/start_date_code.
	--
	if p_rebuild_package then
		rebuild_package;
	end if;
end create_balance_dimension;
--
procedure create_balance_dimension(
	errbuf			out nocopy varchar2,
	retcode			out nocopy varchar2,
	p_dimension_name	in varchar2,
	p_database_item_suffix	in varchar2,
	p_business_group_id	in varchar2,
	p_date_type		in varchar2,
	p_reset_date		in varchar2,
	p_frequency_type	in varchar2,
	p_frequency		in varchar2,
	p_exclude_reversal	in varchar2)
is
	l_balance_dimension_id	number;
begin
	retcode := 0;
	--
	create_balance_dimension(
		p_dimension_name	=> p_dimension_name,
		p_database_item_suffix	=> p_database_item_suffix,
		p_business_group_id	=> p_business_group_id,
		p_date_type		=> p_date_type,
		p_reset_date		=> fnd_date.canonical_to_date(p_reset_date),
		p_frequency_type	=> p_frequency_type,
		p_frequency		=> fnd_number.canonical_to_number(p_frequency),
		p_exclude_reversal	=> (p_exclude_reversal = 'Y'),
		p_balance_dimension_id	=> l_balance_dimension_id);
exception
	when others then
		retcode := 2;
		errbuf := sqlerrm;
		rollback;
end create_balance_dimension;
-- ----------------------------------------------------------------------------
-- |------------------------------< delete_dbi >------------------------------|
-- ----------------------------------------------------------------------------
procedure delete_dbi(
	p_defined_balance_id	in number,
	p_business_group_id	in number)
is
begin
	delete
	from	ff_fdi_usages_f
	where	formula_id in (
			select	distinct
				ff.formula_id
			from	ff_user_entities	u,
				ff_database_items	d,
				ff_fdi_usages_f		fdi,
				ff_formulas_f		ff
			where	u.creator_id = p_defined_balance_id
			and	u.creator_type in ('B', 'RB')
			and	d.user_entity_id = u.user_entity_id
			and	fdi.item_name = d.user_name
			and	fdi.usage = 'D'
			and	ff.formula_id = fdi.formula_id
			and	ff.effective_start_date = fdi.effective_start_date
			and	ff.effective_end_date = fdi.effective_end_date
			and	ff.business_group_id = p_business_group_id);
	--
	delete
	from	ff_compiled_info_f
	where	formula_id in (
			select	distinct
				ff.formula_id
			from	ff_user_entities	u,
				ff_database_items	d,
				ff_fdi_usages_f		fdi,
				ff_formulas_f		ff
			where	u.creator_id = p_defined_balance_id
			and	u.creator_type in ('B', 'RB')
			and	d.user_entity_id = u.user_entity_id
			and	fdi.item_name = d.user_name
			and	fdi.usage = 'D'
			and	ff.formula_id = fdi.formula_id
			and	ff.effective_start_date = fdi.effective_start_date
			and	ff.effective_end_date = fdi.effective_end_date
			and	ff.business_group_id = p_business_group_id);
	--
	delete
	from	ff_user_entities
	where	creator_id = p_defined_balance_id
	and	creator_type in ('B', 'RB');
end delete_dbi;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_latest_balances >------------------------|
-- ----------------------------------------------------------------------------
procedure delete_latest_balances(p_defined_balance_id in number)
is
begin
	delete
	from	pay_balance_context_values
	where	latest_balance_id in (
			select	latest_balance_id
			from	pay_assignment_latest_balances
			where	defined_balance_id = p_defined_balance_id
			union all
			select	latest_balance_id
			from	pay_assignment_latest_balances
			where	defined_balance_id = p_defined_balance_id
			union all
			select	latest_balance_id
			from	pay_latest_balances
			where	defined_balance_id = p_defined_balance_id);
	--
	delete
	from	pay_assignment_latest_balances
	where	defined_balance_id = p_defined_balance_id;
	--
	delete
	from	pay_person_latest_balances
	where	defined_balance_id = p_defined_balance_id;
	--
	delete
	from	pay_latest_balances
	where	defined_balance_id = p_defined_balance_id;
end delete_latest_balances;
-- ----------------------------------------------------------------------------
-- |-----------------------< update_balance_dimension >-----------------------|
-- ----------------------------------------------------------------------------
procedure update_balance_dimension(
	p_balance_dimension_id	in number,
	p_date_type		in varchar2,
	p_reset_date		in date,
	p_frequency_type	in varchar2,
	p_frequency		in number,
	p_exclude_reversal	in boolean,
	p_rebuild_package	in boolean default true)
is
	l_balance_dimension_id	number := p_balance_dimension_id;
	l_business_group_id	number;
	l_dimension_name	pay_balance_dimensions.dimension_name%type;
	l_database_item_suffix	pay_balance_dimensions.database_item_suffix%type;
	--
	type t_number_tbl is table of number index by binary_integer;
	l_defined_balance_ids	t_number_tbl;
	l_balance_type_ids	t_number_tbl;
	l_route_ids		t_number_tbl;
begin
	select	business_group_id,
		dimension_name,
		database_item_suffix
	into	l_business_group_id,
		l_dimension_name,
		l_database_item_suffix
	from	pay_balance_dimensions
	where	balance_dimension_id = p_balance_dimension_id;
	--
	-- Only user defined dimension is allowed to be updated.
	--
	if l_business_group_id is null then
		fnd_message.set_name('PAY', 'PAY_JP_DIM_SEEDUPD_NOT_ALLOWED');
		fnd_message.raise_error;
	end if;
	--
	validate_parameters(
		p_date_type		=> p_date_type,
		p_reset_date		=> p_reset_date,
		p_frequency_type	=> p_frequency_type,
		p_frequency		=> p_frequency);
	--
	-- Delete current DBIs
	--
	select	defined_balance_id,
		balance_type_id
	bulk collect
	into	l_defined_balance_ids,
		l_balance_type_ids
	from	pay_defined_balances
	where	balance_dimension_id = p_balance_dimension_id;
	--
	for i in 1..l_defined_balance_ids.count loop
		--
		-- Delete compiled info and DBIs.
		--
		delete_dbi(l_defined_balance_ids(i), l_business_group_id);
		--
		-- Delete latest balances.
		-- No need to trash run balances which is not affected
		-- because those are ASG_RUN level balances.
		--
		delete_latest_balances(l_defined_balance_ids(i));
	end loop;
	--
	delete
	from	pay_dimension_routes
	where	balance_dimension_id = p_balance_dimension_id;
	--
	upload_balance_dimension(
		p_balance_dimension_id	=> l_balance_dimension_id,
		p_dimension_name	=> l_dimension_name,
		p_database_item_suffix	=> l_database_item_suffix,
		p_business_group_id	=> l_business_group_id,
		p_date_type		=> p_date_type,
		p_reset_date		=> p_reset_date,
		p_frequency_type	=> p_frequency_type,
		p_frequency		=> p_frequency,
		p_exclude_reversal	=> p_exclude_reversal);
	--
	if p_date_type = 'DP' then
		create_dimension_route(
			p_balance_dimension_id	=> p_balance_dimension_id,
			p_priority		=> 1,
			p_route_type		=> 'SRB',
			p_date_type		=> p_date_type,
			p_reset_date		=> p_reset_date,
			p_frequency_type	=> p_frequency_type,
			p_frequency		=> p_frequency,
			p_exclude_reversal	=> p_exclude_reversal);
		--
		create_dimension_route(
			p_balance_dimension_id	=> p_balance_dimension_id,
			p_priority		=> 2,
			p_route_type		=> 'RR',
			p_date_type		=> p_date_type,
			p_reset_date		=> p_reset_date,
			p_frequency_type	=> p_frequency_type,
			p_frequency		=> p_frequency,
			p_exclude_reversal	=> p_exclude_reversal);
	else
		create_dimension_route(
			p_balance_dimension_id	=> p_balance_dimension_id,
			p_priority		=> 1,
			p_route_type		=> 'RR',
			p_date_type		=> p_date_type,
			p_reset_date		=> p_reset_date,
			p_frequency_type	=> p_frequency_type,
			p_frequency		=> p_frequency,
			p_exclude_reversal	=> p_exclude_reversal);
	end if;
	--
	-- Rebuild DBIs
	--
	for i in 1..l_defined_balance_ids.count loop
		hrdyndbi.new_defined_balance(
			p_defined_balance_id	=> l_defined_balance_ids(i),
			p_balance_dimension_id	=> p_balance_dimension_id,
			p_balance_type_id	=> l_balance_type_ids(i),
			p_business_group_id	=> l_business_group_id,
			p_legislation_code	=> null);
	end loop;
	--
	-- Rebuild Package of expiry_checking_code/start_date_code.
	--
	if p_rebuild_package then
		rebuild_package;
	end if;
	--
	-- Compile FF needs to be performed by user manually.
	--
end update_balance_dimension;
--
procedure update_balance_dimension(
	errbuf			out nocopy varchar2,
	retcode			out nocopy varchar2,
	p_balance_dimension_id	in varchar2,
	p_date_type		in varchar2,
	p_reset_date		in varchar2,
	p_frequency_type	in varchar2,
	p_frequency		in varchar2,
	p_exclude_reversal	in varchar2)
is
begin
	retcode := 0;
	--
	update_balance_dimension(
		p_balance_dimension_id	=> fnd_number.canonical_to_number(p_balance_dimension_id),
		p_date_type		=> p_date_type,
		p_reset_date		=> fnd_date.canonical_to_date(p_reset_date),
		p_frequency_type	=> p_frequency_type,
		p_frequency		=> fnd_number.canonical_to_number(p_frequency),
		p_exclude_reversal	=> (p_exclude_reversal = 'Y'));
exception
	when others then
		retcode := 2;
		errbuf := sqlerrm;
		rollback;
end update_balance_dimension;
-- ----------------------------------------------------------------------------
-- |---------------------------< rebuild_package >----------------------------|
-- ----------------------------------------------------------------------------
procedure rebuild_package(p_rebuild_dimension in boolean default false)
is
	l_header		dbms_sql.varchar2a;
	l_body			dbms_sql.varchar2a;
	l_csr			number;
	l_dummy			number;
	l_reset_date		varchar2(30);
	l_frequency_type	varchar2(30);
	l_frequency		varchar2(30);
	--
	cursor csr_def is
		select	def.defined_balance_id,
			def.business_group_id
		from	per_business_groups_perf	bg,
			pay_balance_dimensions		dim,
			pay_defined_balances		def
		where	bg.legislation_code = 'JP'
		and	dim.business_group_id = bg.business_group_id
		and	pay_core_utils.get_parameter('DATE_TYPE', dim.description) is not null
		and	pay_core_utils.get_parameter('RESET_DATE', dim.description) is not null
		and	pay_core_utils.get_parameter('FREQUENCY_TYPE', dim.description) is not null
		and	pay_core_utils.get_parameter('FREQUENCY', dim.description) is not null
		and	def.balance_dimension_id = dim.balance_dimension_id;
	--
	cursor csr_dim is
		select	dim.balance_dimension_id,
			dim.description
		from	per_business_groups_perf	bg,
			pay_balance_dimensions		dim
		where	bg.legislation_code = 'JP'
		and	dim.business_group_id = bg.business_group_id
		and	pay_core_utils.get_parameter('DATE_TYPE', dim.description) is not null
		and	pay_core_utils.get_parameter('RESET_DATE', dim.description) is not null
		and	pay_core_utils.get_parameter('FREQUENCY_TYPE', dim.description) is not null
		and	pay_core_utils.get_parameter('FREQUENCY', dim.description) is not null;
	--
	cursor csr_code is
		--
		-- Do not group by description because expiry_checking_code and
		-- start_date_code are the same name for both reversal include type and
		-- reversal exclude type dimensions.
		--
		select	upper(dim.expiry_checking_code)	expiry_checking_code,
			upper(dim.start_date_code)	start_date_code,
			min(dim.description)		description
		from	per_business_groups_perf	bg,
			pay_balance_dimensions		dim
		where	bg.legislation_code = 'JP'
		and	dim.business_group_id = bg.business_group_id
		and	(dim.expiry_checking_code is not null or dim.start_date_code is not null)
		and	pay_core_utils.get_parameter('DATE_TYPE', dim.description) is not null
		and	pay_core_utils.get_parameter('RESET_DATE', dim.description) is not null
		and	pay_core_utils.get_parameter('FREQUENCY_TYPE', dim.description) is not null
		and	pay_core_utils.get_parameter('FREQUENCY', dim.description) is not null
		group by
			dim.expiry_checking_code,
			dim.start_date_code;
	--
	procedure add_header(p_str in varchar2)
	is
	begin
		if l_header.count = 0 then
			l_header(1) := 'create or replace package pay_jp_dynamic_dimension_pkg as';
			add_header('--');
			add_header('function start_date(');
			add_header('	p_effective_date	in date,');
			add_header('	p_reset_date		in date,');
			add_header('	p_frequency_type	in varchar2,');
			add_header('	p_frequency		in number) return date;');
			add_header('--');
			add_header('function end_date(');
			add_header('	p_effective_date	in date,');
			add_header('	p_reset_date		in date,');
			add_header('	p_frequency_type	in varchar2,');
			add_header('	p_frequency		in number) return date;');
		end if;
		--
		l_header(l_header.count + 1) := p_str;
	end add_header;
	--
	procedure add_body(p_str in varchar2)
	is
	begin
		if l_body.count = 0 then
			l_body(1) := 'create or replace package body pay_jp_dynamic_dimension_pkg as';
			add_body('--');
			add_body('-- ----------------------------------------------------------------------------');
			add_body('-- |------------------------------< start_date >------------------------------|');
			add_body('-- ----------------------------------------------------------------------------');
			add_body('function start_date(');
			add_body('	p_effective_date	in date,');
			add_body('	p_reset_date		in date,');
			add_body('	p_frequency_type	in varchar2,');
			add_body('	p_frequency		in number) return date');
			add_body('is');
			add_body('	l_start_date		date;');
			add_body('	l_start_date_temp	date;');
			add_body('begin');
			add_body('	if p_frequency_type = ''DAY'' then');
			add_body('		l_start_date := p_reset_date + floor((p_effective_date - p_reset_date) / p_frequency) * p_frequency;');
			add_body('	elsif p_frequency_type = ''SMONTH'' then');
			add_body('		if mod(p_frequency, 2) = 0 then');
			add_body('			l_start_date := start_date(p_effective_date, p_reset_date, ''MONTH'', p_frequency / 2);');
			add_body('		else');
			add_body('			l_start_date := start_date(p_effective_date, p_reset_date, ''MONTH'', p_frequency);');
			add_body('			l_start_date_temp := add_months(l_start_date, floor(p_frequency / 2)) + 15;');
			add_body('			if p_effective_date >= l_start_date_temp then');
			add_body('				l_start_date := l_start_date_temp;');
			add_body('			end if;');
			add_body('		end if;');
			add_body('	elsif p_frequency_type = ''MONTH'' then');
			add_body('		l_start_date := add_months(p_reset_date, floor(months_between(p_effective_date, p_reset_date) / p_frequency) * p_frequency);');
			add_body('	else');
			add_body('		fnd_message.set_name(''PAY'', ''PAY_JP_DIM_INVALID_FREQ_TYPE'');');
			add_body('		fnd_message.set_token(''FREQUENCY_TYPE'', p_frequency_type);');
			add_body('		fnd_message.raise_error;');
			add_body('	end if;');
			add_body('	--');
			add_body('	return l_start_date;');
			add_body('end start_date;');
			add_body('-- ----------------------------------------------------------------------------');
			add_body('-- |-------------------------------< end_date >-------------------------------|');
			add_body('-- ----------------------------------------------------------------------------');
			add_body('function end_date(');
			add_body('	p_effective_date	in date,');
			add_body('	p_reset_date		in date,');
			add_body('	p_frequency_type	in varchar2,');
			add_body('	p_frequency		in number) return date');
			add_body('is');
			add_body('	l_start_date	date;');
			add_body('	l_end_date	date;');
			add_body('begin');
			add_body('	if p_frequency_type = ''DAY'' then');
			add_body('		l_end_date := start_date(p_effective_date, p_reset_date, p_frequency_type, p_frequency) + p_frequency - 1;');
			add_body('	elsif p_frequency_type = ''SMONTH'' then');
			add_body('		if mod(p_frequency, 2) = 0 then');
			add_body('			l_end_date := end_date(p_effective_date, p_reset_date, ''MONTH'', p_frequency / 2);');
			add_body('		else');
			add_body('			l_start_date := start_date(p_effective_date, p_reset_date, ''MONTH'', p_frequency);');
			add_body('			l_end_date := add_months(l_start_date, floor(p_frequency / 2)) + 14;');
			add_body('			if p_effective_date > l_end_date then');
			add_body('				l_end_date := add_months(l_start_date, p_frequency) - 1;');
			add_body('			end if;');
			add_body('		end if;');
			add_body('	elsif p_frequency_type = ''MONTH'' then');
			add_body('		l_end_date := add_months(start_date(p_effective_date, p_reset_date, p_frequency_type, p_frequency), p_frequency) - 1;');
			add_body('	else');
			add_body('		fnd_message.set_name(''PAY'', ''PAY_JP_DIM_INVALID_FREQ_TYPE'');');
			add_body('		fnd_message.set_token(''FREQUENCY_TYPE'', p_frequency_type);');
			add_body('		fnd_message.raise_error;');
			add_body('	end if;');
			add_body('	--');
			add_body('	return l_end_date;');
			add_body('end end_date;');
		end if;
		--
		l_body(l_body.count + 1) := p_str;
	end add_body;
begin
	if p_rebuild_dimension then
		--
		-- Delete fdi/compiled/DBI info which references DBI with user defined dimension.
		--
		for l_rec in csr_def loop
			delete_dbi(l_rec.defined_balance_id, l_rec.business_group_id);
		end loop;
		--
		-- Delete PAY_DIMENSION_ROUTES
		--
		for l_rec in csr_dim loop
			delete
			from	pay_dimension_routes
			where	balance_dimension_id = l_rec.balance_dimension_id;
		end loop;
		--
		-- Delete FF_ROUTES
		--
		delete
		from	ff_routes
		where	(	route_name like 'JP\_ASG\_DP\_%\_BALANCE_DIMENSION%' escape '\'
			or	route_name like 'JP\_ASG\_DE\_%\_BALANCE_DIMENSION%' escape '\')
		and	user_defined_flag = 'Y';
		--
		for l_rec in csr_dim loop
			--
			-- Rebuild Balance Dimension
			--
			update_balance_dimension(
				p_balance_dimension_id	=> l_rec.balance_dimension_id,
				p_date_type		=> pay_core_utils.get_parameter('DATE_TYPE', l_rec.description),
				p_reset_date		=> fnd_date.canonical_to_date(pay_core_utils.get_parameter('RESET_DATE', l_rec.description)),
				p_frequency_type	=> pay_core_utils.get_parameter('FREQUENCY_TYPE', l_rec.description),
				p_frequency		=> fnd_number.canonical_to_number(pay_core_utils.get_parameter('FREQUENCY', l_rec.description)),
				p_exclude_reversal	=> (pay_core_utils.get_parameter('EXCLUDE_REVERSAL', l_rec.description) = 'Y'),
				p_rebuild_package	=> false);
		end loop;
	end if;
	--
	for l_rec in csr_code loop
		l_reset_date		:= pay_core_utils.get_parameter('RESET_DATE', l_rec.description);
		l_frequency_type	:= pay_core_utils.get_parameter('FREQUENCY_TYPE', l_rec.description);
		l_frequency		:= pay_core_utils.get_parameter('FREQUENCY', l_rec.description);
		--
		if l_rec.expiry_checking_code is not null then
			l_rec.expiry_checking_code := substr(l_rec.expiry_checking_code, instr(l_rec.expiry_checking_code, '.') + 1);
			--
			add_header('--');
			add_header('procedure ' || l_rec.expiry_checking_code || '(');
			add_header('	p_owner_payroll_action_id	in number,');
			add_header('	p_user_payroll_action_id	in number,');
			add_header('	p_owner_assignment_action_id	in number,');
			add_header('	p_user_assignment_action_id	in number,');
			add_header('	p_owner_effective_date		in date,');
			add_header('	p_user_effective_date		in date,');
			add_header('	p_dimension_name		in varchar2,');
			add_header('	p_expiry_information		out nocopy number);');
			--
			add_body('--');
			add_body('procedure ' || l_rec.expiry_checking_code || '(');
			add_body('	p_owner_payroll_action_id	in number,');
			add_body('	p_user_payroll_action_id	in number,');
			add_body('	p_owner_assignment_action_id	in number,');
			add_body('	p_user_assignment_action_id	in number,');
			add_body('	p_owner_effective_date		in date,');
			add_body('	p_user_effective_date		in date,');
			add_body('	p_dimension_name		in varchar2,');
			add_body('	p_expiry_information		out nocopy number)');
			add_body('is');
			add_body('begin');
			add_body('	if start_date(p_user_effective_date, fnd_date.canonical_to_date(''' ||
						l_reset_date || '''), ''' || l_frequency_type || ''', ' || l_frequency || ') > p_owner_effective_date then');
			add_body('		p_expiry_information := 1;');
			add_body('	else');
			add_body('		p_expiry_information := 0;');
			add_body('	end if;');
			add_body('end ' || l_rec.expiry_checking_code || ';');
			--
			add_header('--');
			add_header('procedure ' || l_rec.expiry_checking_code || '(');
			add_header('	p_owner_payroll_action_id	in number,');
			add_header('	p_user_payroll_action_id	in number,');
			add_header('	p_owner_assignment_action_id	in number,');
			add_header('	p_user_assignment_action_id	in number,');
			add_header('	p_owner_effective_date		in date,');
			add_header('	p_user_effective_date		in date,');
			add_header('	p_dimension_name		in varchar2,');
			add_header('	p_expiry_information		out nocopy date);');
			--
			add_body('--');
			add_body('procedure ' || l_rec.expiry_checking_code || '(');
			add_body('	p_owner_payroll_action_id	in number,');
			add_body('	p_user_payroll_action_id	in number,');
			add_body('	p_owner_assignment_action_id	in number,');
			add_body('	p_user_assignment_action_id	in number,');
			add_body('	p_owner_effective_date		in date,');
			add_body('	p_user_effective_date		in date,');
			add_body('	p_dimension_name		in varchar2,');
			add_body('	p_expiry_information		out nocopy date)');
			add_body('is');
			add_body('begin');
			add_body('	p_expiry_information := end_date(p_owner_effective_date, fnd_date.canonical_to_date(''' ||
						l_reset_date || '''), ''' || l_frequency_type || ''', ' || l_frequency || ');');
			add_body('end ' || l_rec.expiry_checking_code || ';');
		end if;
		--
		if l_rec.start_date_code is not null then
			l_rec.start_date_code := substr(l_rec.start_date_code, instr(l_rec.start_date_code, '.') + 1);
			--
			add_header('--');
			add_header('procedure ' || l_rec.start_date_code || '(');
			add_header('	p_effective_date		in date,');
			add_header('	p_start_date			out nocopy date,');
			add_header('	p_payroll_id			in number,');
			add_header('	p_bus_grp			in number,');
			add_header('	p_asg_action			in number);');
			--
			add_body('--');
			add_body('procedure ' || l_rec.start_date_code || '(');
			add_body('	p_effective_date		in date,');
			add_body('	p_start_date			out nocopy date,');
			add_body('	p_payroll_id			in number,');
			add_body('	p_bus_grp			in number,');
			add_body('	p_asg_action			in number)');
			add_body('is');
			add_body('begin');
			add_body('	p_start_date := start_date(p_effective_date, fnd_date.canonical_to_date(''' ||
						l_reset_date || '''), ''' || l_frequency_type || ''', ' || l_frequency || ');');
			add_body('end ' || l_rec.start_date_code || ';');
		end if;
	end loop;
	--
	if l_header.count > 0 then
		add_header('--');
		add_header('end pay_jp_dynamic_dimension_pkg;');
		--
		add_body('--');
		add_body('end pay_jp_dynamic_dimension_pkg;');
		--
		l_csr := dbms_sql.open_cursor;
		--
		dbms_sql.parse(l_csr, l_header, 1, l_header.count, true, dbms_sql.native);
		l_dummy := dbms_sql.execute(l_csr);
		--
		dbms_sql.parse(l_csr, l_body, 1, l_body.count, true, dbms_sql.native);
		l_dummy := dbms_sql.execute(l_csr);
		--
		dbms_sql.close_cursor(l_csr);
	end if;
end rebuild_package;
--
procedure rebuild_package(
	errbuf			out nocopy varchar2,
	retcode			out nocopy varchar2,
	p_rebuild_dimension	in varchar2)
is
begin
	retcode := 0;
	--
	rebuild_package(p_rebuild_dimension = 'Y');
exception
	when others then
		retcode := 2;
		errbuf := sqlerrm;
		rollback;
end rebuild_package;
--
end pay_jp_dimension_generator_pkg;

/
