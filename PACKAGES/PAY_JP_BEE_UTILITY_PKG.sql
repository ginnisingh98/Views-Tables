--------------------------------------------------------
--  DDL for Package PAY_JP_BEE_UTILITY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_JP_BEE_UTILITY_PKG" AUTHID CURRENT_USER as
/* $Header: pyjpbeeu.pkh 115.1 2002/12/06 11:52:00 ytohya noship $ */
--
-- Type Definitions
--
type t_number_tbl is table of number index by binary_integer;
type t_varchar2_tbl is table of varchar2(255) index by binary_integer;
type t_date_tbl is table of date index by binary_integer;
type t_ee_rec is record(
	element_entry_id		pay_element_entries_f.element_entry_id%TYPE,
	effective_start_date		pay_element_entries_f.effective_start_date%TYPE,
	effective_end_date		pay_element_entries_f.effective_end_date%TYPE,
	element_link_id			pay_element_entries_f.element_link_id%TYPE,
	cost_allocation_keyflex_id	pay_element_entries_f.cost_allocation_keyflex_id%TYPE,
	concatenated_segments		pay_cost_allocation_keyflex.concatenated_segments%TYPE,
	segment1			pay_cost_allocation_keyflex.segment1%TYPE,
	segment2			pay_cost_allocation_keyflex.segment2%TYPE,
	segment3			pay_cost_allocation_keyflex.segment3%TYPE,
	segment4			pay_cost_allocation_keyflex.segment4%TYPE,
	segment5			pay_cost_allocation_keyflex.segment5%TYPE,
	segment6			pay_cost_allocation_keyflex.segment6%TYPE,
	segment7			pay_cost_allocation_keyflex.segment7%TYPE,
	segment8			pay_cost_allocation_keyflex.segment8%TYPE,
	segment9			pay_cost_allocation_keyflex.segment9%TYPE,
	segment10			pay_cost_allocation_keyflex.segment10%TYPE,
	segment11			pay_cost_allocation_keyflex.segment11%TYPE,
	segment12			pay_cost_allocation_keyflex.segment12%TYPE,
	segment13			pay_cost_allocation_keyflex.segment13%TYPE,
	segment14			pay_cost_allocation_keyflex.segment14%TYPE,
	segment15			pay_cost_allocation_keyflex.segment15%TYPE,
	segment16			pay_cost_allocation_keyflex.segment16%TYPE,
	segment17			pay_cost_allocation_keyflex.segment17%TYPE,
	segment18			pay_cost_allocation_keyflex.segment18%TYPE,
	segment19			pay_cost_allocation_keyflex.segment19%TYPE,
	segment20			pay_cost_allocation_keyflex.segment20%TYPE,
	segment21			pay_cost_allocation_keyflex.segment21%TYPE,
	segment22			pay_cost_allocation_keyflex.segment22%TYPE,
	segment23			pay_cost_allocation_keyflex.segment23%TYPE,
	segment24			pay_cost_allocation_keyflex.segment24%TYPE,
	segment25			pay_cost_allocation_keyflex.segment25%TYPE,
	segment26			pay_cost_allocation_keyflex.segment26%TYPE,
	segment27			pay_cost_allocation_keyflex.segment27%TYPE,
	segment28			pay_cost_allocation_keyflex.segment28%TYPE,
	segment29			pay_cost_allocation_keyflex.segment29%TYPE,
	segment30			pay_cost_allocation_keyflex.segment30%TYPE,
	reason				pay_element_entries_f.reason%TYPE,
	attribute_category		pay_element_entries_f.attribute_category%TYPE,
	attribute1			pay_element_entries_f.attribute1%TYPE,
	attribute2			pay_element_entries_f.attribute2%TYPE,
	attribute3			pay_element_entries_f.attribute3%TYPE,
	attribute4			pay_element_entries_f.attribute4%TYPE,
	attribute5			pay_element_entries_f.attribute5%TYPE,
	attribute6			pay_element_entries_f.attribute6%TYPE,
	attribute7			pay_element_entries_f.attribute7%TYPE,
	attribute8			pay_element_entries_f.attribute8%TYPE,
	attribute9			pay_element_entries_f.attribute9%TYPE,
	attribute10			pay_element_entries_f.attribute10%TYPE,
	attribute11			pay_element_entries_f.attribute11%TYPE,
	attribute12			pay_element_entries_f.attribute12%TYPE,
	attribute13			pay_element_entries_f.attribute13%TYPE,
	attribute14			pay_element_entries_f.attribute14%TYPE,
	attribute15			pay_element_entries_f.attribute15%TYPE,
	attribute16			pay_element_entries_f.attribute16%TYPE,
	attribute17			pay_element_entries_f.attribute17%TYPE,
	attribute18			pay_element_entries_f.attribute18%TYPE,
	attribute19			pay_element_entries_f.attribute19%TYPE,
	attribute20			pay_element_entries_f.attribute20%TYPE,
	entry_information_category	pay_element_entries_f.entry_information_category%TYPE,
	entry_information1		pay_element_entries_f.entry_information1%TYPE,
	entry_information2		pay_element_entries_f.entry_information2%TYPE,
	entry_information3		pay_element_entries_f.entry_information3%TYPE,
	entry_information4		pay_element_entries_f.entry_information4%TYPE,
	entry_information5		pay_element_entries_f.entry_information5%TYPE,
	entry_information6		pay_element_entries_f.entry_information6%TYPE,
	entry_information7		pay_element_entries_f.entry_information7%TYPE,
	entry_information8		pay_element_entries_f.entry_information8%TYPE,
	entry_information9		pay_element_entries_f.entry_information9%TYPE,
	entry_information10		pay_element_entries_f.entry_information10%TYPE,
	entry_information11		pay_element_entries_f.entry_information11%TYPE,
	entry_information12		pay_element_entries_f.entry_information12%TYPE,
	entry_information13		pay_element_entries_f.entry_information13%TYPE,
	entry_information14		pay_element_entries_f.entry_information14%TYPE,
	entry_information15		pay_element_entries_f.entry_information15%TYPE,
	entry_information16		pay_element_entries_f.entry_information16%TYPE,
	entry_information17		pay_element_entries_f.entry_information17%TYPE,
	entry_information18		pay_element_entries_f.entry_information18%TYPE,
	entry_information19		pay_element_entries_f.entry_information19%TYPE,
	entry_information20		pay_element_entries_f.entry_information20%TYPE,
	entry_information21		pay_element_entries_f.entry_information21%TYPE,
	entry_information22		pay_element_entries_f.entry_information22%TYPE,
	entry_information23		pay_element_entries_f.entry_information23%TYPE,
	entry_information24		pay_element_entries_f.entry_information24%TYPE,
	entry_information25		pay_element_entries_f.entry_information25%TYPE,
	entry_information26		pay_element_entries_f.entry_information26%TYPE,
	entry_information27		pay_element_entries_f.entry_information27%TYPE,
	entry_information28		pay_element_entries_f.entry_information28%TYPE,
	entry_information29		pay_element_entries_f.entry_information29%TYPE,
	entry_information30		pay_element_entries_f.entry_information30%TYPE,
	date_earned			pay_element_entries_f.date_earned%TYPE,
	personal_payment_method_id	pay_element_entries_f.personal_payment_method_id%TYPE,
	subpriority			pay_element_entries_f.subpriority%TYPE);
type t_eev_rec is record(
	name_tbl			t_varchar2_tbl,
	mandatory_flag_tbl		t_varchar2_tbl,
	hot_default_flag_tbl		t_varchar2_tbl,
	lookup_type_tbl			t_varchar2_tbl,
	default_value_tbl		t_varchar2_tbl,
	liv_default_value_tbl		t_varchar2_tbl,
	entry_value_tbl			t_varchar2_tbl);
--
-- Global Variables
--
g_num_of_logs	number := 0;
g_num_of_outs	number := 0;
-- ----------------------------------------------------------------------------
-- |---------------------------< entry_value_tbl >----------------------------|
-- ----------------------------------------------------------------------------
function entry_value_tbl(
	p_value1	varchar2 default hr_api.g_varchar2,
	p_value2	varchar2 default hr_api.g_varchar2,
	p_value3	varchar2 default hr_api.g_varchar2,
	p_value4	varchar2 default hr_api.g_varchar2,
	p_value5	varchar2 default hr_api.g_varchar2,
	p_value6	varchar2 default hr_api.g_varchar2,
	p_value7	varchar2 default hr_api.g_varchar2,
	p_value8	varchar2 default hr_api.g_varchar2,
	p_value9	varchar2 default hr_api.g_varchar2,
	p_value10	varchar2 default hr_api.g_varchar2,
	p_value11	varchar2 default hr_api.g_varchar2,
	p_value12	varchar2 default hr_api.g_varchar2,
	p_value13	varchar2 default hr_api.g_varchar2,
	p_value14	varchar2 default hr_api.g_varchar2,
	p_value15	varchar2 default hr_api.g_varchar2) return t_varchar2_tbl;
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_upload_date >----------------------------|
-- ----------------------------------------------------------------------------
procedure chk_upload_date(
	p_time_period_id		in number,
	p_upload_date			in date,
	p_period_start_date	 out nocopy date,
	p_period_end_date	 out nocopy date);
-- ----------------------------------------------------------------------------
-- |----------------------< chk_date_effective_changes >----------------------|
-- ----------------------------------------------------------------------------
procedure chk_date_effective_changes(
	p_action_if_exists		in varchar2,
	p_reject_if_future_changes	in varchar2,
	p_date_effective_changes	in out nocopy varchar2);
-- ----------------------------------------------------------------------------
-- |--------------------------------< get_iv >--------------------------------|
-- ----------------------------------------------------------------------------
procedure get_iv(
	p_element_type_id		in number,
	p_effective_date		in date,
	p_eev_rec		 out nocopy t_eev_rec);
-- ----------------------------------------------------------------------------
-- |--------------------------------< get_ee >--------------------------------|
-- ----------------------------------------------------------------------------
procedure get_ee(
	p_assignment_id			in number,
	p_element_type_id		in number,
	p_effective_date		in date,
	p_ee_rec		 out nocopy t_ee_rec,
	p_eev_rec		 out nocopy t_eev_rec);
-- ----------------------------------------------------------------------------
-- |-------------------------------< set_eev >--------------------------------|
-- ----------------------------------------------------------------------------
procedure set_eev(
	p_ee_rec			in t_ee_rec,
	p_eev_rec			in t_eev_rec,
	p_value_if_null_tbl		in t_varchar2_tbl,
	p_new_value_tbl			in out nocopy t_varchar2_tbl,
	p_is_different		 out nocopy boolean);
-- ----------------------------------------------------------------------------
-- |---------------------------------< log >----------------------------------|
-- ----------------------------------------------------------------------------
procedure log(
	p_full_name			in varchar2,
	p_assignment_number		in varchar2,
	p_application_short_name	in varchar2,
	p_message_name			in varchar2,
	p_token1			in varchar2 default null,
	p_value1			in varchar2 default null,
	p_token2			in varchar2 default null,
	p_value2			in varchar2 default null,
	p_token3			in varchar2 default null,
	p_value3			in varchar2 default null,
	p_token4			in varchar2 default null,
	p_value4			in varchar2 default null,
	p_token5			in varchar2 default null,
	p_value5			in varchar2 default null);
-- ----------------------------------------------------------------------------
-- |---------------------------------< out >----------------------------------|
-- ----------------------------------------------------------------------------
procedure out(
	p_full_name			in varchar2,
	p_assignment_number		in varchar2,
	p_effective_date		in date,
	p_change_type			in varchar2,
	p_eev_rec			in t_eev_rec,
	p_new_value_tbl			in t_varchar2_tbl,
	p_write_all			in boolean);
-- ----------------------------------------------------------------------------
-- |--------------------------< create_batch_line >---------------------------|
-- ----------------------------------------------------------------------------
procedure create_batch_line(
	p_batch_id			in number,
	p_assignment_id			in number,
	p_assignment_number		in varchar2,
	p_element_type_id		in number,
	p_element_name			in varchar2,
	p_effective_date		in date,
	p_ee_rec			in t_ee_rec,
	p_eev_rec			in t_eev_rec,
	p_batch_line_id		 out nocopy number,
	p_object_version_number	 out nocopy number);
--
end pay_jp_bee_utility_pkg;

 

/
