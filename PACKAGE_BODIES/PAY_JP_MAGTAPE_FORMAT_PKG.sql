--------------------------------------------------------
--  DDL for Package Body PAY_JP_MAGTAPE_FORMAT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_JP_MAGTAPE_FORMAT_PKG" as
/* $Header: payjpmgf.pkb 120.0 2005/05/29 02:38:11 appldev noship $ */
--
-- Global variables.
--
g_bank_code		pay_jp_banks.bank_code%TYPE;
g_transaction_type	hr_lookups.lookup_code%TYPE;
--------------------------------------------------------------------------------
function header_record(
	p_data	in pay_jp_magtape_pkg.header) return varchar2
--------------------------------------------------------------------------------
is
begin
	--
	-- Set global variable G_BANK_CODE and G_TRANSACTION_TYPE.
	--
	g_bank_code		:= p_data.bank_code;
	g_transaction_type	:= p_data.transaction_type;
	--
	-- When source account is post office, not bank.
	--
	if g_bank_code = '9900' then
		return	'1' ||
			p_data.transaction_type ||
			' ' ||
/* Bug#2657901          p_data.character_set_code || */
			p_data.company_code ||
			rpad(p_data.company_name,40,' ') ||
			to_char(p_data.direct_deposit_date,'MMDD') ||
			p_data.bank_code ||
			rpad(p_data.bank_name_kana,15,' ') ||
			rpad(' ',20,' ') ||
			substr(p_data.account_number,-6,6) ||
			rpad(' ',17,' ');
	--
	-- When source account is bank.
	--
	else
		return	'1' ||
			p_data.transaction_type ||
			p_data.character_set_code ||
			p_data.company_code ||
			rpad(p_data.company_name,40,' ') ||
			to_char(p_data.direct_deposit_date,'MMDD') ||
			p_data.bank_code ||
			rpad(p_data.bank_name_kana,15,' ') ||
			p_data.branch_code ||
			rpad(p_data.branch_name_kana,15,' ') ||
			p_data.account_type ||
			p_data.account_number ||
			rpad(' ',17,' ');
	end if;
end header_record;
--------------------------------------------------------------------------------
function data_record(
	p_data	in pay_jp_magtape_pkg.data) return varchar2
--------------------------------------------------------------------------------
is
begin
	--
	-- When source account is post office, not bank.
	--
	if g_bank_code = '9900' then
		return	'2' ||
			p_data.bank_code ||
			rpad(p_data.bank_name_kana,15,' ') ||
			p_data.branch_code ||
			rpad(' ',17,' ') ||
			g_transaction_type ||
			' ' ||
			p_data.account_number ||
			rpad(p_data.account_name,30,' ') ||
			to_char(p_data.payment,'FM0000000000') ||
			lpad(' ',30,' ');
	--
	-- When source account is bank.
	--
	else
		if g_transaction_type = 21 then
			return	'2' ||
				p_data.bank_code ||
				rpad(p_data.bank_name_kana,15,' ') ||
				p_data.branch_code ||
				rpad(p_data.branch_name_kana,15,' ') ||
				rpad(' ',4,' ') ||
				p_data.account_type ||
				p_data.account_number ||
				rpad(p_data.account_name,30,' ') ||
				to_char(p_data.payment,'FM0000000000') ||
				'0' ||
				lpad('0',20,'0') ||
				' ' ||
				' ' ||
				rpad(' ',7,' ');
		else
			return	'2' ||
				p_data.bank_code ||
				rpad(p_data.bank_name_kana,15,' ') ||
				p_data.branch_code ||
				rpad(p_data.branch_name_kana,15,' ') ||
				rpad(' ',4,' ') ||
				p_data.account_type ||
				p_data.account_number ||
				rpad(p_data.account_name,30,' ') ||
				to_char(p_data.payment,'FM0000000000') ||
				'0' ||
				lpad('0',20,'0') ||
				rpad(' ',9,' ');
		end if;
	end if;
end data_record;
--------------------------------------------------------------------------------
function trailer_record(
	p_data	in pay_jp_magtape_pkg.trailer) return varchar2
--------------------------------------------------------------------------------
is
begin
	--
	-- When source account is post office, not bank.
	--
	if g_bank_code = '9900' then
		return	'8' ||
			to_char(p_data.total_count,'FM000000') ||
			to_char(p_data.total_payment,'FM000000000000') ||
			rpad(' ',36,' ') ||
			lpad('0',6,'0') ||
			rpad(' ',59,' ');
	--
	-- When source account is bank.
	--
	else
		return	'8' ||
			to_char(p_data.total_count,'FM000000') ||
			to_char(p_data.total_payment,'FM000000000000') ||
			rpad(' ',101,' ');
	end if;
end trailer_record;
--------------------------------------------------------------------------------
function end_record return varchar2
--------------------------------------------------------------------------------
is
begin
	return	'9' ||
		rpad(' ',119,' ');
end end_record;
--
end pay_jp_magtape_format_pkg;

/
