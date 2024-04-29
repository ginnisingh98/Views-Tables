--------------------------------------------------------
--  DDL for Package PER_JP_CTR_UTILITY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_JP_CTR_UTILITY_PKG" AUTHID CURRENT_USER as
/* $Header: pejpctru.pkh 115.1 2002/12/12 11:36:28 ytohya noship $ */
--
-- Type Definitions
--
type t_varchar2_tbl is table of varchar2(255) index by binary_integer;
type t_itax_dpnt_rec is record(
	assignment_id			number,
	itax_type			hr_lookups.lookup_code%TYPE,
	effective_date			date,
	spouse_type			hr_lookups.lookup_code%TYPE	:= '0',
	dpnt_spouse_dsbl_type		hr_lookups.lookup_code%TYPE	:= '0',
	dpnts				number				:= 0,
	aged_dpnts			number				:= 0,
	aged_dpnt_parents_lt		number				:= 0,
	young_dpnts			number				:= 0,
	minor_dpnts			number				:= 0,
	dsbl_dpnts			number				:= 0,
	svr_dsbl_dpnts			number				:= 0,
	svr_dsbl_dpnts_lt		number				:= 0,
/*
	dpnt_spouse_type		hr_lookups.lookup_code%TYPE	:= '0',
	dpnt_spouse_dsbl_type		hr_lookups.lookup_code%TYPE	:= '0',
	dpnts				number				:= 0,
	aged_dpnts			number				:= 0,
	cohab_aged_asc_dpnts		number				:= 0,
	major_dpnts			number				:= 0,
	minor_dpnts			number				:= 0,
	dsbl_dpnts			number				:= 0,
	svr_dsbl_dpnts			number				:= 0,
*/
	cohab_svr_dsbl_dpnts		number				:= 0,
	multiple_spouses_warning	boolean				:= false,
	contact_type_tbl		t_varchar2_tbl,
	d_contact_type_kanji_tbl	t_varchar2_tbl,
	d_contact_type_kana_tbl		t_varchar2_tbl,
	last_name_kanji_tbl		t_varchar2_tbl,
	first_name_kanji_tbl		t_varchar2_tbl,
	last_name_kana_tbl		t_varchar2_tbl,
	first_name_kana_tbl		t_varchar2_tbl);
-- ----------------------------------------------------------------------------
-- |------------------------< bg_itax_dpnt_ref_type >-------------------------|
-- ----------------------------------------------------------------------------
function bg_itax_dpnt_ref_type(p_business_group_id in number) return varchar2;
-- ----------------------------------------------------------------------------
-- |--------------------------< get_itax_dpnt_info >--------------------------|
-- ----------------------------------------------------------------------------
procedure get_itax_dpnt_info(
	p_assignment_id			in number,
	p_itax_type			in varchar2,
	p_effective_date		in date,
	p_itax_dpnt_rec		 out nocopy t_itax_dpnt_rec,
	p_use_cache			in boolean default TRUE);
-------------------------------------------------------------------------------
procedure get_itax_dpnt_info(
	p_assignment_id			in number,
	p_itax_type			in varchar2,
	p_effective_date		in date,
	p_spouse_type		 out nocopy varchar2,
	p_dpnt_spouse_dsbl_type	 out nocopy varchar2,
	p_dpnts			 out nocopy number,
	p_aged_dpnts		 out nocopy number,
	p_aged_dpnt_parents_lt	 out nocopy number,
	p_young_dpnts		 out nocopy number,
	p_minor_dpnts		 out nocopy number,
	p_dsbl_dpnts		 out nocopy number,
	p_svr_dsbl_dpnts	 out nocopy number,
	p_svr_dsbl_dpnts_lt	 out nocopy number,
	p_multiple_spouses_warning out nocopy boolean,
	p_use_cache			in boolean default TRUE);
-------------------------------------------------------------------------------
procedure get_itax_dpnt_info(
	p_assignment_id			in number,
	p_itax_type			in varchar2,
	p_effective_date		in date,
	p_dpnt_spouse_type	 out nocopy varchar2,
	p_dpnt_spouse_dsbl_type	 out nocopy varchar2,
	p_dpnts			 out nocopy number,
	p_aged_dpnts		 out nocopy number,
	p_cohab_aged_asc_dpnts	 out nocopy number,
	p_major_dpnts		 out nocopy number,
	p_minor_dpnts		 out nocopy number,
	p_dsbl_dpnts		 out nocopy number,
	p_svr_dsbl_dpnts	 out nocopy number,
	p_cohab_svr_dsbl_dpnts	 out nocopy number,
	p_multiple_spouses_warning out nocopy boolean,
	p_use_cache			in boolean default TRUE);
-------------------------------------------------------------------------------
function get_itax_spouse_type(
	p_assignment_id		in number,
	p_itax_type		in varchar2,
	p_effective_date	in date default null) return varchar2;
-------------------------------------------------------------------------------
function get_itax_dpnt_spouse_type(
	p_assignment_id		in number,
	p_itax_type		in varchar2,
	p_effective_date	in date default null) return varchar2;
-------------------------------------------------------------------------------
function get_itax_dpnt_spouse_dsbl_type(
	p_assignment_id		in number,
	p_itax_type		in varchar2,
	p_effective_date	in date default null) return varchar2;
-------------------------------------------------------------------------------
function get_itax_dpnts(
	p_assignment_id		in number,
	p_itax_type		in varchar2,
	p_effective_date	in date default null) return varchar2;
-------------------------------------------------------------------------------
function get_itax_aged_dpnts(
	p_assignment_id		in number,
	p_itax_type		in varchar2,
	p_effective_date	in date default null) return varchar2;
-------------------------------------------------------------------------------
function get_itax_aged_dpnt_parents_lt(
	p_assignment_id		in number,
	p_itax_type		in varchar2,
	p_effective_date	in date default null) return varchar2;
-------------------------------------------------------------------------------
function get_itax_cohab_aged_asc_dpnts(
	p_assignment_id		in number,
	p_itax_type		in varchar2,
	p_effective_date	in date default null) return varchar2;
-------------------------------------------------------------------------------
function get_itax_young_dpnts(
	p_assignment_id		in number,
	p_itax_type		in varchar2,
	p_effective_date	in date default null) return varchar2;
-------------------------------------------------------------------------------
function get_itax_major_dpnts(
	p_assignment_id		in number,
	p_itax_type		in varchar2,
	p_effective_date	in date default null) return varchar2;
-------------------------------------------------------------------------------
function get_itax_minor_dpnts(
	p_assignment_id		in number,
	p_itax_type		in varchar2,
	p_effective_date	in date default null) return varchar2;
-------------------------------------------------------------------------------
function get_itax_dsbl_dpnts(
	p_assignment_id		in number,
	p_itax_type		in varchar2,
	p_effective_date	in date default null) return varchar2;
-------------------------------------------------------------------------------
function get_itax_svr_dsbl_dpnts(
	p_assignment_id		in number,
	p_itax_type		in varchar2,
	p_effective_date	in date default null) return varchar2;
-------------------------------------------------------------------------------
function get_itax_svr_dsbl_dpnts_lt(
	p_assignment_id		in number,
	p_itax_type		in varchar2,
	p_effective_date	in date default null) return varchar2;
-------------------------------------------------------------------------------
function get_itax_cohab_svr_dsbl_dpnts(
	p_assignment_id		in number,
	p_itax_type		in varchar2,
	p_effective_date	in date default null) return varchar2;
--
end per_jp_ctr_utility_pkg;

 

/
