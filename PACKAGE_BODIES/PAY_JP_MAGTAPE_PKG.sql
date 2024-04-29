--------------------------------------------------------
--  DDL for Package Body PAY_JP_MAGTAPE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_JP_MAGTAPE_PKG" as
/* $Header: payjpmag.pkb 120.0 2005/05/29 02:37:56 appldev noship $ */
--
-- Global variables and Constants.
--
g_character_set		varchar2(80);
g_header_sql		varchar2(2000);
g_data_sql		varchar2(2000);
g_trailer_sql		varchar2(2000);
g_end_sql		varchar2(2000);
g_package_name		varchar2(30) := 'pay_jp_magtape_pkg';
c_default_package_name	constant varchar2(30) := 'pay_jp_magtape_format_pkg';
--------------------------------------------------------------------------------
-- This function returns latest request_id for specified payroll_action_id.
--------------------------------------------------------------------------------
function latest_request_id(
	p_payroll_action_id	in number) return number
--------------------------------------------------------------------------------
is
	l_request_id	number;
	--
	-- Pay attention that this cursor never raise %NOTFOUND error
	-- because of using MAX function.
	--
	cursor csr_request_id is
		select	max(request_id)
		from	fnd_concurrent_requests	fcr,
			fnd_concurrent_programs	fcp
		where	fcp.application_id = 801
		and	fcp.concurrent_program_name = 'PAYJPMAG'
		and	fcr.program_application_id = fcp.application_id
		and	fcr.concurrent_program_id = fcp.concurrent_program_id
		and	fcr.argument1 = to_char(p_payroll_action_id);
begin
	open csr_request_id;
	fetch csr_request_id into l_request_id;
	close csr_request_id;
	--
	return l_request_id;
end latest_request_id;
--------------------------------------------------------------------------------
-- Debug purpose.
--------------------------------------------------------------------------------
function show_sql(
	p_record_type		in varchar2) return varchar2
--------------------------------------------------------------------------------
is
begin
	if p_record_type = 'H' then
		return g_header_sql;
	elsif p_record_type = 'D' then
		return g_data_sql;
	elsif p_record_type = 'T' then
		return g_trailer_sql;
	elsif p_record_type = 'E' then
		return g_end_sql;
	else
		return null;
	end if;
end show_sql;
--------------------------------------------------------------------------------
-- This procedure initializes dynamic sql string which is kicked for each
-- header, data, trailer and end record of direct deposit file.
--------------------------------------------------------------------------------
procedure init(
	p_package_name		in varchar2,
	p_character_set		in varchar2)
--------------------------------------------------------------------------------
is
	l_api_name	varchar2(61) := g_package_name || '.init';
	l_package_name	varchar2(30) := nvl(p_package_name,c_default_package_name);
begin
	--
	-- Check mandatory argument.
	--
	hr_api.mandatory_arg_error(
		p_api_name		=> l_api_name,
		p_argument		=> 'p_character_set',
		p_argument_value	=> p_character_set);
	--
	-- Initialize global variables.
	--
	g_character_set := p_character_set;
	--
	g_header_sql :=
'declare
	l_data	pay_jp_magtape_pkg.header;
begin
	l_data.org_payment_method_id	:= :v1;
	l_data.transaction_type		:= :v2;
	l_data.character_set_code	:= :v3;
	l_data.direct_deposit_date	:= :v4;
	l_data.company_code		:= :v5;
	l_data.company_name		:= :v6;
	l_data.external_account_id	:= :v7;
	l_data.bank_code		:= :v8;
	l_data.bank_name_kana		:= :v9;
	l_data.branch_code		:= :v10;
	l_data.branch_name_kana		:= :v11;
	l_data.account_type		:= :v12;
	l_data.account_number		:= :v13;
	l_data.account_name		:= :v14;
	l_data.description1		:= :v15;
	l_data.description2		:= :v16;
	:v17 := ' || l_package_name || '.header_record(l_data);
end;';
	--
	g_data_sql :=
'declare
	l_data	pay_jp_magtape_pkg.data;
begin
	l_data.person_id		:= :v1;
	l_data.employee_number		:= :v2;
	l_data.external_account_id	:= :v3;
	l_data.bank_code		:= :v4;
	l_data.bank_name_kana		:= :v5;
	l_data.branch_code		:= :v6;
	l_data.branch_name_kana		:= :v7;
	l_data.account_type		:= :v8;
	l_data.account_number		:= :v9;
	l_data.account_name		:= :v10;
	l_data.description1		:= :v11;
	l_data.description2		:= :v12;
	l_data.payment			:= :v13;
	:v14 := ' || l_package_name || '.data_record(l_data);
end;';
	--
	g_trailer_sql :=
'declare
	l_data	pay_jp_magtape_pkg.trailer;
begin
	l_data.total_count		:= :v1;
	l_data.total_payment		:= :v2;
	:v3 := ' || l_package_name || '.trailer_record(l_data);
end;';
	--
	g_end_sql :=
'begin
	:v1 := ' || l_package_name || '.end_record;
end;';
end init;
--------------------------------------------------------------------------------
-- Function to return HEADER record of direct deposit file.
-- This function is interface between PAYJPMAG.rdf and pay_jp_magtape_format_pkg
-- (default format package. user can override format package on Org Paymeth
-- form).
--------------------------------------------------------------------------------
function header_record(
	p_org_payment_method_id	in number,
	p_transaction_type	in varchar2,
	p_character_set_code	in varchar2,
	p_direct_deposit_date	in date,
	p_company_code		in varchar2,
	p_company_name		in varchar2,
	p_external_account_id	in number,
	p_bank_code		in varchar2,
	p_bank_name_kana	in varchar2,
	p_branch_code		in varchar2,
	p_branch_name_kana	in varchar2,
	p_account_type		in varchar2,
	p_account_number	in varchar2,
	p_account_name		in varchar2,
	p_description1		in varchar2,
	p_description2		in varchar2) return varchar2
--------------------------------------------------------------------------------
is
	l_api_name	varchar2(61) := g_package_name || '.header_record';
	l_buffer	varchar2(2000);
begin
	--
	-- Check mandatory argument.
	--
	hr_api.mandatory_arg_error(
		p_api_name		=> l_api_name,
		p_argument		=> 'p_org_payment_method_id',
		p_argument_value	=> p_org_payment_method_id);
	hr_api.mandatory_arg_error(
		p_api_name		=> l_api_name,
		p_argument		=> 'p_transaction_type',
		p_argument_value	=> p_transaction_type);
	hr_api.mandatory_arg_error(
		p_api_name		=> l_api_name,
		p_argument		=> 'p_character_set_code',
		p_argument_value	=> p_character_set_code);
	hr_api.mandatory_arg_error(
		p_api_name		=> l_api_name,
		p_argument		=> 'p_direct_deposit_date',
		p_argument_value	=> p_direct_deposit_date);
	hr_api.mandatory_arg_error(
		p_api_name		=> l_api_name,
		p_argument		=> 'p_company_code',
		p_argument_value	=> p_company_code);
	hr_api.mandatory_arg_error(
		p_api_name		=> l_api_name,
		p_argument		=> 'p_company_name',
		p_argument_value	=> p_company_name);
	hr_api.mandatory_arg_error(
		p_api_name		=> l_api_name,
		p_argument		=> 'p_external_account_id',
		p_argument_value	=> p_external_account_id);
	hr_api.mandatory_arg_error(
		p_api_name		=> l_api_name,
		p_argument		=> 'p_bank_code',
		p_argument_value	=> p_bank_code);
	hr_api.mandatory_arg_error(
		p_api_name		=> l_api_name,
		p_argument		=> 'p_bank_name_kana',
		p_argument_value	=> p_bank_name_kana);
	hr_api.mandatory_arg_error(
		p_api_name		=> l_api_name,
		p_argument		=> 'p_branch_code',
		p_argument_value	=> p_branch_code);
	hr_api.mandatory_arg_error(
		p_api_name		=> l_api_name,
		p_argument		=> 'p_branch_name_kana',
		p_argument_value	=> p_branch_name_kana);
	hr_api.mandatory_arg_error(
		p_api_name		=> l_api_name,
		p_argument		=> 'p_account_type',
		p_argument_value	=> p_account_type);
	hr_api.mandatory_arg_error(
		p_api_name		=> l_api_name,
		p_argument		=> 'p_account_number',
		p_argument_value	=> p_account_number);
	hr_api.mandatory_arg_error(
		p_api_name		=> l_api_name,
		p_argument		=> 'p_account_name',
		p_argument_value	=> p_account_name);
	--
	-- Get formatted record.
	--
	execute immediate g_header_sql using
		p_org_payment_method_id,
		p_transaction_type,
		p_character_set_code,
		p_direct_deposit_date,
		p_company_code,
		p_company_name,
		p_external_account_id,
		p_bank_code,
		p_bank_name_kana,
		p_branch_code,
		p_branch_name_kana,
		p_account_type,
		p_account_number,
		p_account_name,
		p_description1,
		p_description2,
		out l_buffer;
	--
	-- Return value.
	--
	return convert(l_buffer,g_character_set);
exception
	when others then
		fnd_message.set_name('PER','HR_ERROR');
		fnd_message.set_token('SQL',g_header_sql);
		fnd_message.raise_error;
end header_record;
--------------------------------------------------------------------------------
-- Function to return DATA record of direct deposit file.
-- This function is interface between PAYJPMAG.rdf and pay_jp_magtape_format_pkg
-- (default format package. user can override format package on Org Paymeth
-- form).
--------------------------------------------------------------------------------
function data_record(
	p_person_id		in number,
	p_employee_number	in varchar2,
	p_external_account_id	in number,
	p_bank_code		in varchar2,
	p_bank_name_kana	in varchar2,
	p_branch_code		in varchar2,
	p_branch_name_kana	in varchar2,
	p_account_type		in varchar2,
	p_account_number	in varchar2,
	p_account_name		in varchar2,
	p_description1		in varchar2,
	p_description2		in varchar2,
	p_payment		in number) return varchar2
--------------------------------------------------------------------------------
is
	l_api_name	varchar2(61) := g_package_name || '.data_record';
	l_buffer	varchar2(2000);
begin
	--
	-- Check mandatory argument.
	--
	hr_api.mandatory_arg_error(
		p_api_name		=> l_api_name,
		p_argument		=> 'p_person_id',
		p_argument_value	=> p_person_id);
	hr_api.mandatory_arg_error(
		p_api_name		=> l_api_name,
		p_argument		=> 'p_employee_number',
		p_argument_value	=> p_employee_number);
	hr_api.mandatory_arg_error(
		p_api_name		=> l_api_name,
		p_argument		=> 'p_external_account_id',
		p_argument_value	=> p_external_account_id);
	hr_api.mandatory_arg_error(
		p_api_name		=> l_api_name,
		p_argument		=> 'p_bank_code',
		p_argument_value	=> p_bank_code);
	hr_api.mandatory_arg_error(
		p_api_name		=> l_api_name,
		p_argument		=> 'p_bank_name_kana',
		p_argument_value	=> p_bank_name_kana);
	hr_api.mandatory_arg_error(
		p_api_name		=> l_api_name,
		p_argument		=> 'p_branch_code',
		p_argument_value	=> p_branch_code);
	hr_api.mandatory_arg_error(
		p_api_name		=> l_api_name,
		p_argument		=> 'p_branch_name_kana',
		p_argument_value	=> p_branch_name_kana);
	hr_api.mandatory_arg_error(
		p_api_name		=> l_api_name,
		p_argument		=> 'p_account_type',
		p_argument_value	=> p_account_type);
	hr_api.mandatory_arg_error(
		p_api_name		=> l_api_name,
		p_argument		=> 'p_account_number',
		p_argument_value	=> p_account_number);
	hr_api.mandatory_arg_error(
		p_api_name		=> l_api_name,
		p_argument		=> 'p_account_name',
		p_argument_value	=> p_account_name);
	hr_api.mandatory_arg_error(
		p_api_name		=> l_api_name,
		p_argument		=> 'p_payment',
		p_argument_value	=> p_payment);
	--
	-- Get formatted record.
	--
	execute immediate g_data_sql using
		p_person_id,
		p_employee_number,
		p_external_account_id,
		p_bank_code,
		p_bank_name_kana,
		p_branch_code,
		p_branch_name_kana,
		p_account_type,
		p_account_number,
		p_account_name,
		p_description1,
		p_description2,
		p_payment,
		out l_buffer;
	--
	-- Return value.
	--
	return convert(l_buffer,g_character_set);
exception
	when others then
		fnd_message.set_name('PER','HR_ERROR');
		fnd_message.set_token('SQL',g_data_sql);
		fnd_message.raise_error;
end data_record;
--------------------------------------------------------------------------------
-- Function to return TRAILER record of direct deposit file.
-- This function is interface between PAYJPMAG.rdf and pay_jp_magtape_format_pkg
-- (default format package. user can override format package on Org Paymeth
-- form).
--------------------------------------------------------------------------------
function trailer_record(
	p_total_count		in number,
	p_total_payment		in number) return varchar2
--------------------------------------------------------------------------------
is
	l_api_name	varchar2(61) := g_package_name || '.trailer_record';
	l_buffer	varchar2(2000);
begin
	--
	-- Check mandatory argument.
	--
	hr_api.mandatory_arg_error(
		p_api_name		=> l_api_name,
		p_argument		=> 'p_total_count',
		p_argument_value	=> p_total_count);
	hr_api.mandatory_arg_error(
		p_api_name		=> l_api_name,
		p_argument		=> 'p_total_payment',
		p_argument_value	=> p_total_payment);
	--
	-- Get formatted record.
	--
	execute immediate g_trailer_sql using
		p_total_count,
		p_total_payment,
		out l_buffer;
	--
	-- Return value.
	--
	return convert(l_buffer,g_character_set);
exception
	when others then
		fnd_message.set_name('PER','HR_ERROR');
		fnd_message.set_token('SQL',g_trailer_sql);
		fnd_message.raise_error;
end trailer_record;
--------------------------------------------------------------------------------
-- Function to return END record of direct deposit file.
-- This function is interface between PAYJPMAG.rdf and pay_jp_magtape_format_pkg
-- (default format package. user can override format package on Org Paymeth
-- form).
--------------------------------------------------------------------------------
function end_record return varchar2
--------------------------------------------------------------------------------
is
	l_api_name	varchar2(61) := g_package_name || '.end_record';
	l_buffer	varchar2(2000);
begin
	--
	-- Get formatted record.
	--
	execute immediate g_end_sql using out l_buffer;
	--
	-- Return value.
	--
	return convert(l_buffer,g_character_set);
exception
	when others then
		fnd_message.set_name('PER','HR_ERROR');
		fnd_message.set_token('SQL',g_end_sql);
		fnd_message.raise_error;
end end_record;
--
end pay_jp_magtape_pkg;

/
