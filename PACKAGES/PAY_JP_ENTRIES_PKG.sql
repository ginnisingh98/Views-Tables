--------------------------------------------------------
--  DDL for Package PAY_JP_ENTRIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_JP_ENTRIES_PKG" AUTHID CURRENT_USER as
/* $Header: pyjpetr.pkh 120.0.12010000.1 2008/07/27 22:58:43 appldev ship $ */
g_iv_max constant integer := 15;
type ev_rec is record(
	input_value_id			pay_input_values_f.input_value_id%TYPE,
	entry_value			pay_element_entry_values_f.screen_entry_value%TYPE,
	-- #2240838. Changed data type from hr_lookups.meaning%type
	-- to varchar2(240).
	d_entry_value			varchar2(240));
--
-- The following size_limit(=15) must be literal not variable.
--
--type ev_rec_tbl is varray(15) of ev_rec;
type ev_rec_tbl is table of ev_rec index by binary_integer;
--
-- For PAY_ELEMENT_ENTRIES_F descriptive_flexfield.
type t_attribute is table of varchar2(240) index by binary_integer;
type attribute_tbl is record(
        attribute_category              pay_element_entries_f.attribute_category%TYPE,
        attribute                       t_attribute);
--
-- For Forms cache.
-- <How to use>
-- elm_tbl(element_type_id).element_code
-- iv_tbl(input_value_id).display_sequence
--
type elm_code_tbl is table of pay_element_types_f.element_name%TYPE index by binary_integer;
type elm_rec is record(
	element_code			pay_element_types_f.element_name%TYPE,
	input_currency_code		pay_element_types_f.input_currency_code%TYPE,
	multiple_entries_allowed_flag	pay_element_types_f.multiple_entries_allowed_flag%TYPE);
type elm_rec_tbl is table of elm_rec index by binary_integer;
type iv_rec is record(
	element_type_id			pay_input_values_f.element_type_id%TYPE,
	display_sequence		pay_input_values_f.display_sequence%TYPE,
	uom				pay_input_values_f.uom%TYPE,
	mandatory_flag			pay_input_values_f.mandatory_flag%TYPE,
	max_length			number,
	format_mask			varchar2(80));
type iv_rec_tbl is table of iv_rec index by binary_integer;
--
-- ----------------------------------------------------------------------------
-- |------------------------< derive_attributes >-----------------------------|
-- ----------------------------------------------------------------------------
-- Call this procedure in the following triggers.
--   1) PRE-FORM
--   2) INIT_DATE_DEPENDENT
-- On Forms, set properties using output variables.
Procedure derive_attributes(
	p_elm_code_tbl		in     elm_code_tbl,
	p_effective_date	in     date,
	p_business_group_id	in     number,
	p_elm_rec_tbl		out nocopy    elm_rec_tbl,
	p_iv_rec_tbl		out nocopy    iv_rec_tbl);
--
-- ----------------------------------------------------------------------------
-- |------------------------< derive_format_mask >----------------------------|
-- ----------------------------------------------------------------------------
-- Call this procedure in the following triggers.
--   1) PRE-FORM
-- On Forms, set properties using output variables.
Procedure derive_format_mask(
	p_elm_rec_tbl		in     elm_rec_tbl,
	p_iv_rec_tbl		in out nocopy iv_rec_tbl);
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< chk_entry >--------------------------------|
-- ----------------------------------------------------------------------------
-- This procedure must be called "once" on the following Forms trigger.
--   1) WHEN-DATABASE-RECORD(when INSERTING)
-- Not necessary to call this procedure on WHEN-VALIDATE-ITEM trigger when
-- updating.
-- When deleting, this procedure is called in part of API.
-- Call derive_default_values procedure instead of this procedure chk_entry.
Procedure chk_entry(
	p_element_entry_id	in     number,
	p_assignment_id		in     number,
	p_element_link_id	in     number,
	p_entry_type		in     varchar2,
	p_original_entry_id	in     number   default null,
	p_target_entry_id	in     number   default null,
	p_effective_date	in     date,
	p_validation_start_date	in     date,
	p_validation_end_date	in     date,
	p_effective_start_date	in out nocopy date,
	p_effective_end_date	in out nocopy date,
	p_usage			in     varchar2,
	p_dt_update_mode	in     varchar2,
	p_dt_delete_mode	in     varchar2);
--
-- ----------------------------------------------------------------------------
-- |---------------------< derive_default_values >----------------------------|
-- ----------------------------------------------------------------------------
-- This procedure must be called in the following trigger.
--   1) WHEN-DATABASE-RECORD(when INSERTING)
-- This procedure includes chk_entry procedure.
Procedure derive_default_values(
	p_assignment_id		in     number,
	p_element_code		in     varchar2,
	p_business_group_id	in     varchar2,
	p_entry_type            in     varchar2,
	p_element_link_id	out nocopy    number,
	p_ev_rec_tbl		out nocopy    ev_rec_tbl,
	p_effective_date	in     date,
	p_effective_start_date	in out nocopy date,
	p_effective_end_date	in out nocopy date);
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_entry_value >----------------------------|
-- ----------------------------------------------------------------------------
-- This procedure must be called every time before dtcsapi call.
Procedure chk_entry_value(
	p_element_link_id	in     number,
	p_input_value_id	in     number,
	p_effective_date	in     date,
	p_business_group_id     in     number,
	p_assignment_id         in     number,
	p_user_value		in out nocopy varchar2,
	p_canonical_value	out nocopy    varchar2,
	p_hot_defaulted		out nocopy    boolean,
	p_min_max_warning	out nocopy    boolean,
	p_user_min_value	out nocopy    varchar2,
	p_user_max_value	out nocopy    varchar2,
	p_formula_warning	out nocopy    boolean,
	p_formula_message	out nocopy    varchar2);
--
-- ----------------------------------------------------------------------------
-- |--------------------------< find_dt_upd_modes >---------------------------|
-- ----------------------------------------------------------------------------
Procedure find_dt_upd_modes
	(p_effective_date	in  date,
	 p_base_key_value	in  number,
	 p_correction	 	out nocopy boolean,
	 p_update	 	out nocopy boolean,
	 p_update_override 	out nocopy boolean,
	 p_update_change_insert out nocopy boolean);
--
-- ----------------------------------------------------------------------------
-- |--------------------------< find_dt_del_modes >---------------------------|
-- ----------------------------------------------------------------------------
Procedure find_dt_del_modes
	(p_effective_date	in  date,
	 p_base_key_value	in  number,
	 p_zap		 	out nocopy boolean,
	 p_delete	 	out nocopy boolean,
	 p_future_change 	out nocopy boolean,
	 p_delete_next_change 	out nocopy boolean);
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< ins_lck >--------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins_lck
	(p_effective_date	 in  date,
	 p_datetrack_mode	 in  varchar2,
	 p_rec	 		 in  pay_element_entries_f%ROWTYPE,
	 p_validation_start_date out nocopy date,
	 p_validation_end_date	 out nocopy date);
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< lck >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure lck
	(p_effective_date	 in  date,
	 p_datetrack_mode	 in  varchar2,
	 p_element_entry_id	 in  number,
	 p_object_version_number in  number,
	 p_validation_start_date out nocopy date,
	 p_validation_end_date	 out nocopy date);
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< ins >------------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins(
	p_validate		in  boolean,
	p_effective_date	in  date,
	p_assignment_id		in  number,
	p_element_link_id	in  number,
	p_ev_rec_tbl		in  ev_rec_tbl,
	p_attribute_tbl		in  attribute_tbl,
	p_business_group_id	in  number,
	p_element_entry_id	out nocopy number,
	p_effective_start_date	out nocopy date,
	p_effective_end_date	out nocopy date,
	p_object_version_number out nocopy number);
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< upd >------------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd(
	p_validate		in     boolean,
	p_effective_date	in     date,
	p_datetrack_update_mode	in     varchar2,
	p_element_entry_id	in     number,
	p_object_version_number	in out nocopy number,
	p_ev_rec_tbl		in     ev_rec_tbl,
	p_attribute_tbl		in     attribute_tbl,
	p_business_group_id	in     number,
	p_effective_start_date	out nocopy    date,
	p_effective_end_date	out nocopy    date);
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< del >------------------------------------|
-- ----------------------------------------------------------------------------
Procedure del(
	p_validate		in     boolean,
	p_effective_date	in     date,
	p_datetrack_delete_mode	in     varchar2,
	p_element_entry_id	in     number,
	p_object_version_number	in out nocopy number,
	p_effective_start_date	out nocopy    date,
	p_effective_end_date	out nocopy    date);
--
End pay_jp_entries_pkg;

/
