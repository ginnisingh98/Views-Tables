--------------------------------------------------------
--  DDL for Package PAY_JP_MAGTAPE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_JP_MAGTAPE_PKG" AUTHID CURRENT_USER as
/* $Header: payjpmag.pkh 120.0 2005/05/29 02:38:04 appldev noship $ */
--
-- TYPE definitions.
--
type header is record(
	org_payment_method_id	pay_org_payment_methods_f.org_payment_method_id%TYPE,
	transaction_type	hr_lookups.lookup_code%TYPE,
	character_set_code	hr_lookups.lookup_code%TYPE,
	direct_deposit_date	pay_payroll_actions.overriding_dd_date%TYPE,
	company_code		pay_org_payment_methods_f.pmeth_information1%TYPE,
	company_name		pay_org_payment_methods_f.pmeth_information2%TYPE,
	external_account_id	pay_external_accounts.external_account_id%TYPE,
	bank_code		pay_jp_banks.bank_code%TYPE,
	bank_name_kana		pay_jp_banks.bank_name_kana%TYPE,
	branch_code		pay_jp_bank_branches.branch_code%TYPE,
	branch_name_kana	pay_jp_bank_branches.branch_name_kana%TYPE,
	account_type		pay_external_accounts.segment7%TYPE,
	account_number		pay_external_accounts.segment8%TYPE,
	account_name		pay_external_accounts.segment9%TYPE,
	description1		pay_external_accounts.segment10%TYPE,
	description2		pay_external_accounts.segment11%TYPE);
type data is record(
	person_id		per_all_people_f.person_id%TYPE,
	employee_number		per_all_people_f.employee_number%TYPE,
	external_account_id	pay_external_accounts.external_account_id%TYPE,
	bank_code		pay_jp_banks.bank_code%TYPE,
	bank_name_kana		pay_jp_banks.bank_name_kana%TYPE,
	branch_code		pay_jp_bank_branches.branch_code%TYPE,
	branch_name_kana	pay_jp_bank_branches.branch_name_kana%TYPE,
	account_type		pay_external_accounts.segment7%TYPE,
	account_number		pay_external_accounts.segment8%TYPE,
	account_name		pay_external_accounts.segment9%TYPE,
	description1		pay_external_accounts.segment10%TYPE,
	description2		pay_external_accounts.segment11%TYPE,
	payment			number);
type trailer is record(
	total_count		number,
	total_payment		number);
--
function latest_request_id(
	p_payroll_action_id	in number) return number;
function show_sql(
	p_record_type		in varchar2) return varchar2;
--
-- Changed to return converted characters because of Reports'
-- convert function bug.
-- When running Reports, user have to run in the environment
-- without character conversion, that is, nls_characterset
-- must always be the same as DB characterset.
-- But user do not have to care about this because Reports runs
-- by Concurrent Manager whose nls_characterset is always be the
-- same as DB characterset.
--
procedure init(
	p_package_name		in varchar2,
	p_character_set		in varchar2);
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
	p_description2		in varchar2) return varchar2;
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
	p_payment		in number) return varchar2;
function trailer_record(
	p_total_count		in number,
	p_total_payment		in number) return varchar2;
function end_record return varchar2;
--
end pay_jp_magtape_pkg;

 

/
