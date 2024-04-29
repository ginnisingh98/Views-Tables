--------------------------------------------------------
--  DDL for Package PAY_JP_WIC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_JP_WIC_PKG" AUTHID CURRENT_USER as
/* $Header: pyjpwic.pkh 120.6.12010000.2 2009/11/09 08:53:02 keyazawa ship $ */
--
g_valid_term_taxable_amt number;
--
type t_tax_info is record(
	taxable_income			number := 0,
	mutual_aid_prem			number,
	si_prem				number := 0,
	itax				number := 0,
	itax_adjustment			number := 0,
	withholding_itax		number := 0,
	disaster_tax_reduction		number);
type t_certificate_info is record(
	tax_info			t_tax_info,
	net_taxable_income		number,
	spouse_sp_exempt		number,
	spouse_net_taxable_income	number,
	li_prem_exempt			number,
	pp_prem				number,
	ai_prem_exempt			number,
	long_ai_prem			number,
	total_income_exempt		number,
	housing_tax_reduction		number,
	housing_residence_date		date,
	unclaimed_housing_tax_reduct	number,
	fixed_rate_tax_reduction	number,
	national_pens_prem		number,
	dep_spouse_exists_kou		varchar2(1) := 'N',
	dep_spouse_not_exist_kou	varchar2(1) := 'N',
	dep_spouse_exists_otsu		varchar2(1) := 'N',
	dep_spouse_not_exist_otsu	varchar2(1) := 'N',
	aged_spouse_exists		varchar2(1) := 'N',
	num_specifieds_kou		number,
	num_specifieds_otsu		number,
	num_aged_parents_lt		number,
	num_ageds_kou			number,
	num_ageds_otsu			number,
	num_deps_kou			number,
	num_deps_otsu			number,
	num_svr_disableds_lt		number,
	num_svr_disableds		number,
	num_disableds			number,
	husband_exists			varchar2(1) := 'N',
	minor_flag			varchar2(1) := 'N',
	otsu_flag			varchar2(1) := 'N',
	svr_disabled_flag		varchar2(1) := 'N',
	disabled_flag			varchar2(1) := 'N',
	aged_flag			varchar2(1) := 'N',
	widow_flag			varchar2(1) := 'N',
	sp_widow_flag			varchar2(1) := 'N',
	widower_flag			varchar2(1) := 'N',
	working_student_flag		varchar2(1) := 'N',
	deceased_termination_flag	varchar2(1) := 'N',
	disastered_flag			varchar2(1) := 'N',
	foreigner_flag			varchar2(1) := 'N',
	description_kanji		varchar2(32767),
	description_kana		varchar2(32767),
	desc_line1_kanji		varchar2(32767),
	desc_line1_kana			varchar2(32767));
--
type t_prev_job_info is record(
	itax_organization_id		number,
	taxable_income			number := 0,
	mutual_aid_prem			number,
	si_prem				number := 0,
	itax				number := 0,
	foreign_address_flag		varchar2(1) := 'N',
	salary_payer_address_kanji	varchar2(2000),
	salary_payer_address_kana	varchar2(2000),
	salary_payer_name_kanji		varchar2(2000),
	salary_payer_name_kana		varchar2(2000),
	termination_date		date);
type t_prev_jobs is table of t_prev_job_info index by binary_integer;
--
type t_dpnt_info is record(
	contact_type_kanji	hr_lookups.meaning%type,
	contact_type_kana	hr_lookups.meaning%type,
	last_name_kanji		per_all_people_f.per_information18%type,
	last_name_kana		per_all_people_f.last_name%type,
	first_name_kanji	per_all_people_f.per_information19%type,
	first_name_kana		per_all_people_f.first_name%type);
type t_dpnts is table of t_dpnt_info index by binary_integer;
--
type t_description_info is record(
	description_type		varchar2(30),
	description_kanji		varchar2(32767),
	description_kana		varchar2(32767));
type t_descriptions is table of t_description_info index by binary_integer;
--
type t_housing_rec is record(
  residence_date date,
  loan_type      varchar2(60),
  loan_balance   number);
type t_housing_tbl is table of t_housing_rec index by binary_integer;
--
type t_housing_info is record(
  payable_loan     number,
  loan_count       number,
  residence_date_1 date,
  loan_type_1      varchar2(60),
  loan_balance_1   number,
  residence_date_2 date,
  loan_type_2      varchar2(60),
  loan_balance_2   number);
--
-- |-------------------------------------------------------------------|
-- |----------------------< get_ee_description >-----------------------|
-- |-------------------------------------------------------------------|
procedure get_ee_description(
	p_assignment_id		in number,
	p_business_group_id	in number,
	p_effective_date	in date,
	p_itw_override_flag	out nocopy varchar2,
	p_itw_description	out nocopy varchar2,
	p_wtm_override_flag	out nocopy varchar2,
	p_wtm_description	out nocopy varchar2);
-- |-------------------------------------------------------------------|
-- |-----------------------< get_descriptions >------------------------|
-- |-------------------------------------------------------------------|
procedure get_descriptions(
  p_assignment_id     in number,
  p_person_id         in number,
  p_effective_date    in date,
  p_itax_yea_category in varchar2,
  p_certificate_info  in t_certificate_info,
  p_last_name_kanji   in varchar2,
  p_last_name_kana    in varchar2,
  p_dpnts             in t_dpnts,
  p_prev_jobs         in t_prev_jobs,
  p_housing_tbl       in t_housing_tbl,
  p_report_type       in varchar2, --> ITW/WTM
  p_descriptions      out nocopy t_descriptions);
--
procedure get_descriptions(
  p_assignment_id     in number,
  p_person_id         in number,
  p_effective_date    in date,
  p_itax_yea_category in varchar2,
  p_certificate_info  in t_certificate_info,
  p_last_name_kanji   in varchar2,
  p_last_name_kana    in varchar2,
  p_dpnts             in t_dpnts,
  p_prev_jobs         in t_prev_jobs,
  p_report_type       in varchar2, --> ITW/WTM
  p_descriptions      out nocopy t_descriptions);
--
-- |-------------------------------------------------------------------|
-- |---------------------< get_certificate_info >----------------------|
-- |-------------------------------------------------------------------|
-- Wrapper function for ITT
procedure get_certificate_info(
	p_assignment_action_id		in number,
	p_assignment_id			in number,
	p_action_sequence		in number,
	p_effective_date		in date,
	p_itax_organization_id		in number,
	p_itax_category			in varchar2,
	p_itax_yea_category		in varchar2,
	p_employment_category		in varchar2,
	p_person_id			in number,
	p_business_group_id		in number,
	p_date_earned			in date,
	p_certificate_info		out nocopy t_tax_info,
	p_submission_required_flag	out nocopy varchar2,
	p_withholding_tax_info		out nocopy t_tax_info);
--
-- Following is deprecated.
--
procedure get_certificate_info(
	p_assignment_action_id		in number,
	p_assignment_id			in number,
	p_action_sequence		in number,
	p_effective_date		in date,
	p_itax_organization_id		in number,
	p_itax_category			in varchar2,
	p_itax_yea_category		in varchar2,
	p_employment_category		in varchar2,
	p_person_id			in number,
	p_business_group_id		in number,
	p_date_earned			in date,
	p_certificate_info		out nocopy t_tax_info,
	p_submission_required_flag	out nocopy varchar2,
	p_withholding_tax_info		out nocopy t_tax_info,
	p_prev_jobs			out nocopy t_prev_jobs);
-- |-------------------------------------------------------------------|
-- |---------------------< get_certificate_info >----------------------|
-- |-------------------------------------------------------------------|
--
-- Wrapper function for the wrapper function for WTM, ITW (called from gci_wtm, gci_itw_b : gci_b)
--
procedure get_certificate_info(
  p_assignment_action_id     in number,
  p_assignment_id            in number,
  p_action_sequence          in number,
  p_business_group_id        in number,
  p_effective_date           in date,
  p_date_earned              in date,
  p_itax_organization_id     in number,
  p_itax_category            in varchar2,
  p_itax_yea_category        in varchar2,
  p_dpnt_ref_type            in varchar2,
  p_dpnt_effective_date      in date,
  p_person_id                in number,
  p_sex                      in varchar2,
  p_date_of_birth            in date,
  p_leaving_reason           in varchar2,
  p_last_name_kanji          in varchar2,
  p_last_name_kana           in varchar2,
  p_employment_category      in varchar2,
  p_magnetic_media_flag      in varchar2 default 'N',
  p_certificate_info         out nocopy t_certificate_info,
  p_submission_required_flag out nocopy varchar2,
  p_prev_jobs                out nocopy t_prev_jobs,
  p_housing_tbl              out nocopy t_housing_tbl);
--
-- Wrapper function for WTM (used this in efile PAYJPWTM, PAYJPSPE : gci_wtm)
--
procedure get_certificate_info(
  p_assignment_action_id     in number,
  p_assignment_id            in number,
  p_action_sequence          in number,
  p_business_group_id        in number,
  p_effective_date           in date,
  p_date_earned              in date,
  p_itax_organization_id     in number,
  p_itax_category            in varchar2,
  p_itax_yea_category        in varchar2,
  p_dpnt_ref_type            in varchar2,
  p_dpnt_effective_date      in date,
  p_person_id                in number,
  p_sex                      in varchar2,
  p_date_of_birth            in date,
  p_leaving_reason           in varchar2,
  p_last_name_kanji          in varchar2,
  p_last_name_kana           in varchar2,
  p_employment_category      in varchar2,
  p_magnetic_media_flag      in varchar2 default 'N',
  p_certificate_info         out nocopy t_certificate_info,
  p_submission_required_flag out nocopy varchar2,
  p_prev_job_info            out nocopy t_prev_job_info,
  p_housing_info             out nocopy t_housing_info);
--
-- Wrapper function for existing user program (call gci_wtm for previous behavior : gci_wtm_usr)
--
procedure get_certificate_info(
  p_assignment_action_id     in number,
  p_assignment_id            in number,
  p_action_sequence          in number,
  p_business_group_id        in number,
  p_effective_date           in date,
  p_date_earned              in date,
  p_itax_organization_id     in number,
  p_itax_category            in varchar2,
  p_itax_yea_category        in varchar2,
  p_dpnt_ref_type            in varchar2,
  p_dpnt_effective_date      in date,
  p_person_id                in number,
  p_sex                      in varchar2,
  p_date_of_birth            in date,
  p_leaving_reason           in varchar2,
  p_last_name_kanji          in varchar2,
  p_last_name_kana           in varchar2,
  p_employment_category      in varchar2,
  p_magnetic_media_flag      in varchar2 default 'N',
  p_certificate_info         out nocopy t_certificate_info,
  p_submission_required_flag out nocopy varchar2,
  p_prev_job_info            out nocopy t_prev_job_info);
--
-- |-------------------------------------------------------------------|
-- |---------------------< get_certificate_info >----------------------|
-- |-------------------------------------------------------------------|
--
-- Wrapper function for ITW (called from gci_itw : gci_itw_b)
--
procedure get_certificate_info(
  p_assignment_action_id     in number,
  p_assignment_id            in number,
  p_action_sequence          in number,
  p_business_group_id        in number,
  p_effective_date           in date,
  p_date_earned              in date,
  p_itax_organization_id     in number,
  p_itax_category            in varchar2,
  p_itax_yea_category        in varchar2,
  p_dpnt_ref_type            in varchar2,
  p_dpnt_effective_date      in date,
  p_person_id                in number,
  p_sex                      in varchar2,
  p_date_of_birth            in date,
  p_leaving_reason           in varchar2,
  p_last_name_kanji          in varchar2,
  p_last_name_kana           in varchar2,
  p_employment_category      in varchar2,
  p_magnetic_media_flag      in varchar2 default 'N',
  p_certificate_info         out nocopy t_certificate_info,
  p_submission_required_flag out nocopy varchar2,
  p_prev_jobs                out nocopy t_prev_jobs,
  p_withholding_tax_info     out nocopy t_tax_info);
--
-- |-------------------------------------------------------------------|
-- |---------------------< get_certificate_info >----------------------|
-- |-------------------------------------------------------------------|
--
-- Wrapper function for Archive  (used this in PAYJPITW_ARCHIVE : gci_itw_arc)
--
procedure get_certificate_info(
  p_assignment_action_id     in number,
  p_assignment_id            in number,
  p_action_sequence          in number,
  p_business_group_id        in number,
  p_effective_date           in date,
  p_date_earned              in date,
  p_itax_organization_id     in number,
  p_itax_category            in varchar2,
  p_itax_yea_category        in varchar2,
  p_dpnt_ref_type            in varchar2,
  p_dpnt_effective_date      in date,
  p_person_id                in number,
  p_sex                      in varchar2,
  p_date_of_birth            in date,
  p_leaving_reason           in varchar2,
  p_last_name_kanji          in varchar2,
  p_last_name_kana           in varchar2,
  p_employment_category      in varchar2,
  p_certificate_info         out nocopy t_certificate_info,
  p_submission_required_flag out nocopy varchar2,
  p_prev_job_info            out nocopy t_prev_job_info,
  p_housing_info             out nocopy t_housing_info,
  p_withholding_tax_info     out nocopy t_tax_info,
  p_itw_description          out nocopy varchar2,
  p_itw_descriptions         out nocopy t_descriptions,
  p_wtm_description          out nocopy varchar2,
  p_wtm_descriptions         out nocopy t_descriptions);
--
-- Wrapper function for wage ledger (used this in PAYJPWL_ARCHIVE : gci_wl_arc)
--
procedure get_certificate_info(
  p_assignment_action_id     in number,
  p_assignment_id            in number,
  p_action_sequence          in number,
  p_business_group_id        in number,
  p_effective_date           in date,
  p_date_earned              in date,
  p_itax_organization_id     in number,
  p_itax_category            in varchar2,
  p_itax_yea_category        in varchar2,
  p_dpnt_ref_type            in varchar2,
  p_dpnt_effective_date      in date,
  p_person_id                in number,
  p_sex                      in varchar2,
  p_date_of_birth            in date,
  p_leaving_reason           in varchar2,
  p_last_name_kanji          in varchar2,
  p_last_name_kana           in varchar2,
  p_employment_category      in varchar2,
  p_certificate_info         out nocopy t_certificate_info,
  p_submission_required_flag out nocopy varchar2,
  p_prev_job_info            out nocopy t_prev_job_info,
  p_withholding_tax_info     out nocopy t_tax_info,
  p_itw_description          out nocopy varchar2,
  p_itw_descriptions         out nocopy t_descriptions,
  p_wtm_description          out nocopy varchar2,
  p_wtm_descriptions         out nocopy t_descriptions);
--
-- |-------------------------------------------------------------------|
-- |---------------------< set_valid_term_taxable_amt >----------------|
-- |-------------------------------------------------------------------|
procedure set_valid_term_taxable_amt(
  p_valid_term_taxable_amt in number);
--
-- |-------------------------------------------------------------------|
-- |---------------------< spr_term_valid >----------------------------|
-- |-------------------------------------------------------------------|
-- Use in Summary Payment Report and ITW with Term Validation
function spr_term_valid(
  p_assignment_action_id  in number,
  p_assignment_id         in number,
  p_action_sequence       in number,
  p_effective_date        in date,
  p_itax_organization_id  in number,
  p_itax_category         in varchar2,
  p_itax_yea_category     in varchar2,
  p_employment_category   in varchar2,
  p_termination_date      in date,
  p_certificate_info      in t_certificate_info default null)
return number;
--
-- |-------------------------------------------------------------------|
-- |---------------------< get_certificate_info >----------------------|
-- |-------------------------------------------------------------------|
--
-- Wrapper for ITW with Term Validation (used this in PAYJPITW : gci_itw)
--
procedure get_certificate_info(
  p_assignment_action_id     in number,
  p_assignment_id            in number,
  p_action_sequence          in number,
  p_business_group_id        in number,
  p_effective_date           in date,
  p_date_earned              in date,
  p_itax_organization_id     in number,
  p_itax_category            in varchar2,
  p_itax_yea_category        in varchar2,
  p_dpnt_ref_type            in varchar2,
  p_dpnt_effective_date      in date,
  p_person_id                in number,
  p_sex                      in varchar2,
  p_date_of_birth            in date,
  p_leaving_reason           in varchar2,
  p_last_name_kanji          in varchar2,
  p_last_name_kana           in varchar2,
  p_employment_category      in varchar2,
  p_magnetic_media_flag      in varchar2 default 'N',
  p_termination_date         in date,
  p_certificate_info         out nocopy t_certificate_info,
  p_submission_required_flag out nocopy varchar2,
  p_prev_jobs                out nocopy t_prev_jobs,
  p_withholding_tax_info     out nocopy t_tax_info,
  p_spr_term_valid           out nocopy number);
--
-- |-------------------------------------------------------------------|
-- |---------------------< get_certificate_info >----------------------|
-- |-------------------------------------------------------------------|
-- For debugging purpose. NEVER USE THIS in your product code.
procedure get_certificate_info(
	p_assignment_action_id		in number,
	p_magnetic_media_flag		in varchar2 default 'N',
	p_certificate_info		out nocopy t_certificate_info,
	p_submission_required_flag	out nocopy varchar2,
	p_prev_jobs			out nocopy t_prev_jobs,
	p_withholding_tax_info		out nocopy t_tax_info);
--
-- Deprecated
--
FUNCTION ass_set_validation(
	p_assignment_set_id	in NUMBER,
	p_assignment_id		in NUMBER,
	p_effective_date	in DATE) RETURN NUMBER;
--
end pay_jp_wic_pkg;

/
