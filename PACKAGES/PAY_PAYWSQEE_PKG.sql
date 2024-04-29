--------------------------------------------------------
--  DDL for Package PAY_PAYWSQEE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_PAYWSQEE_PKG" AUTHID CURRENT_USER as
/* $Header: paywsqee.pkh 120.1.12010000.1 2008/07/27 21:58:00 appldev ship $ */
--------------------------------------------------------------------------------
procedure get_batch_element_type (
	--
p_batch_id              	number,
p_element_type_id       	in out nocopy number,
p_element_name          	in out nocopy varchar2);
--------------------------------------------------------------------------------
function paylink_request_id (
--
	p_business_group_id      number,
	p_mode            	 varchar2,
	p_batch_id	 	 number,
        p_wait                   varchar2 default 'N',
        p_act_parameter_group_id number   default null) return number;
--------------------------------------------------------------------------------
procedure check_name_uniqueness (
--
p_business_group_id	number,
p_batch_name		varchar2,
p_batch_id		number);
--------------------------------------------------------------------------------
function next_batch_sequence (p_batch_id number) return number;
--------------------------------------------------------------------------------
function batch_overall_status (p_batch_id number) return varchar2;
--------------------------------------------------------------------------------
function assignment_number (p_assignment_id number) return varchar2;
--------------------------------------------------------------------------------
procedure GET_INPUT_VALUE_DETAILS (
--
-- Returns the input value details for the element selected by an LOV
--
p_element_type_id	number,
p_effective_date	date,
p_input_value_id1	in out nocopy number,
p_input_value_id2	in out nocopy number,
p_input_value_id3	in out nocopy number,
p_input_value_id4	in out nocopy number,
p_input_value_id5	in out nocopy number,
p_input_value_id6	in out nocopy number,
p_input_value_id7	in out nocopy number,
p_input_value_id8	in out nocopy number,
p_input_value_id9	in out nocopy number,
p_input_value_id10	in out nocopy number,
p_input_value_id11	in out nocopy number,
p_input_value_id12	in out nocopy number,
p_input_value_id13	in out nocopy number,
p_input_value_id14	in out nocopy number,
p_input_value_id15	in out nocopy number,
p_name1			in out nocopy varchar2,
p_name2			in out nocopy varchar2,
p_name3			in out nocopy varchar2,
p_name4			in out nocopy varchar2,
p_name5			in out nocopy varchar2,
p_name6			in out nocopy varchar2,
p_name7			in out nocopy varchar2,
p_name8			in out nocopy varchar2,
p_name9			in out nocopy varchar2,
p_name10		in out nocopy varchar2,
p_name11		in out nocopy varchar2,
p_name12		in out nocopy varchar2,
p_name13		in out nocopy varchar2,
p_name14		in out nocopy varchar2,
p_name15		in out nocopy varchar2,
p_lookup_type1		in out nocopy varchar2,
p_lookup_type2		in out nocopy varchar2,
p_lookup_type3		in out nocopy varchar2,
p_lookup_type4		in out nocopy varchar2,
p_lookup_type5		in out nocopy varchar2,
p_lookup_type6		in out nocopy varchar2,
p_lookup_type7		in out nocopy varchar2,
p_lookup_type8		in out nocopy varchar2,
p_lookup_type9		in out nocopy varchar2,
p_lookup_type10		in out nocopy varchar2,
p_lookup_type11		in out nocopy varchar2,
p_lookup_type12		in out nocopy varchar2,
p_lookup_type13		in out nocopy varchar2,
p_lookup_type14		in out nocopy varchar2,
p_lookup_type15		in out nocopy varchar2);
---------------------------------
procedure GET_INPUT_VALUE_DETAILS (
--
-- Returns the input value details for the element selected by an LOV
--
p_element_type_id	number,
p_effective_date	date,
p_input_value_id1	in out nocopy number,
p_input_value_id2	in out nocopy number,
p_input_value_id3	in out nocopy number,
p_input_value_id4	in out nocopy number,
p_input_value_id5	in out nocopy number,
p_input_value_id6	in out nocopy number,
p_input_value_id7	in out nocopy number,
p_input_value_id8	in out nocopy number,
p_input_value_id9	in out nocopy number,
p_input_value_id10	in out nocopy number,
p_input_value_id11	in out nocopy number,
p_input_value_id12	in out nocopy number,
p_input_value_id13	in out nocopy number,
p_input_value_id14	in out nocopy number,
p_input_value_id15	in out nocopy number,
p_name1			in out nocopy varchar2,
p_name2			in out nocopy varchar2,
p_name3			in out nocopy varchar2,
p_name4			in out nocopy varchar2,
p_name5			in out nocopy varchar2,
p_name6			in out nocopy varchar2,
p_name7			in out nocopy varchar2,
p_name8			in out nocopy varchar2,
p_name9			in out nocopy varchar2,
p_name10		in out nocopy varchar2,
p_name11		in out nocopy varchar2,
p_name12		in out nocopy varchar2,
p_name13		in out nocopy varchar2,
p_name14		in out nocopy varchar2,
p_name15		in out nocopy varchar2,
p_lookup_type1		in out nocopy varchar2,
p_lookup_type2		in out nocopy varchar2,
p_lookup_type3		in out nocopy varchar2,
p_lookup_type4		in out nocopy varchar2,
p_lookup_type5		in out nocopy varchar2,
p_lookup_type6		in out nocopy varchar2,
p_lookup_type7		in out nocopy varchar2,
p_lookup_type8		in out nocopy varchar2,
p_lookup_type9		in out nocopy varchar2,
p_lookup_type10		in out nocopy varchar2,
p_lookup_type11		in out nocopy varchar2,
p_lookup_type12		in out nocopy varchar2,
p_lookup_type13		in out nocopy varchar2,
p_lookup_type14		in out nocopy varchar2,
p_lookup_type15		in out nocopy varchar2,
-- UOM
p_uom1			in out nocopy varchar2,
p_uom2			in out nocopy varchar2,
p_uom3			in out nocopy varchar2,
p_uom4			in out nocopy varchar2,
p_uom5			in out nocopy varchar2,
p_uom6			in out nocopy varchar2,
p_uom7			in out nocopy varchar2,
p_uom8			in out nocopy varchar2,
p_uom9			in out nocopy varchar2,
p_uom10			in out nocopy varchar2,
p_uom11			in out nocopy varchar2,
p_uom12			in out nocopy varchar2,
p_uom13			in out nocopy varchar2,
p_uom14			in out nocopy varchar2,
p_uom15			in out nocopy varchar2,
-- Value Set Id
p_value_set_id1  in out nocopy number,
p_value_set_id2  in out nocopy number,
p_value_set_id3  in out nocopy number,
p_value_set_id4  in out nocopy number,
p_value_set_id5  in out nocopy number,
p_value_set_id6  in out nocopy number,
p_value_set_id7  in out nocopy number,
p_value_set_id8  in out nocopy number,
p_value_set_id9  in out nocopy number,
p_value_set_id10  in out nocopy number,
p_value_set_id11  in out nocopy number,
p_value_set_id12  in out nocopy number,
p_value_set_id13  in out nocopy number,
p_value_set_id14  in out nocopy number,
p_value_set_id15  in out nocopy number
);
--------------------------------------------------------------------------------
procedure populate_context_items (
--
--******************************************************************************
-- Populate form initialisation information
--******************************************************************************
--
p_business_group_id		in number,             -- User's business group
p_cost_allocation_structure 	in out nocopy varchar2 -- Keyflex structure
);
--------------------------------------------------------------------------------
function create_batches_request_id (
--
p_header_name                varchar2,
p_header_id                  number,
p_reason                     varchar2,
p_business_group_id          number,
p_effective_start_date       date,
p_effective_s_date       date,
p_effective_e_date       date,
p_element_type_id            number,
p_payroll_id                 number,
p_assignment_set_id          number,
p_cost_allocation_keyflex_id number,
p_mix_transfer_flag          varchar2,
p_value_1                    varchar2,
p_value_2                    varchar2,
p_value_3                    varchar2,
p_value_4                    varchar2,
p_value_5                    varchar2,
p_value_6                    varchar2,
p_value_7                    varchar2,
p_value_8                    varchar2,
p_value_9                    varchar2,
p_value_10                   varchar2,
p_value_11                   varchar2,
p_value_12                   varchar2,
p_value_13                   varchar2,
p_value_14                   varchar2,
p_value_15                   varchar2,
p_attribute_category         varchar2,
p_attribute1                 varchar2,
p_attribute2                 varchar2,
p_attribute3                 varchar2,
p_attribute4                 varchar2,
p_attribute5                 varchar2,
p_attribute6                 varchar2,
p_attribute7                 varchar2,
p_attribute8                 varchar2,
p_attribute9                 varchar2,
p_attribute10                varchar2,
p_attribute11                varchar2,
p_attribute12                varchar2,
p_attribute13                varchar2,
p_attribute14                varchar2,
p_attribute15                varchar2,
p_attribute16                varchar2,
p_attribute17                varchar2,
p_attribute18                varchar2,
p_attribute19                varchar2,
p_attribute20                varchar2,
p_entry_information_category varchar2,
p_entry_information1         varchar2,
p_entry_information2         varchar2,
p_entry_information3         varchar2,
p_entry_information4         varchar2,
p_entry_information5         varchar2,
p_entry_information6         varchar2,
p_entry_information7         varchar2,
p_entry_information8         varchar2,
p_entry_information9         varchar2,
p_entry_information10        varchar2,
p_entry_information11        varchar2,
p_entry_information12        varchar2,
p_entry_information13        varchar2,
p_entry_information14        varchar2,
p_entry_information15        varchar2,
p_entry_information16        varchar2,
p_entry_information17        varchar2,
p_entry_information18        varchar2,
p_entry_information19        varchar2,
p_entry_information20        varchar2,
p_entry_information21        varchar2,
p_entry_information22        varchar2,
p_entry_information23        varchar2,
p_entry_information24        varchar2,
p_entry_information25        varchar2,
p_entry_information26        varchar2,
p_entry_information27        varchar2,
p_entry_information28        varchar2,
p_entry_information29        varchar2,
p_entry_information30        varchar2,
p_date_earned                date,
p_subpriority                number,
p_element_set_id	     number default null,
p_customized_restriction_id  number default null,
p_act_parameter_group_id     number default null
)
return number;
--------------------------------------------------------------------------------
--
function convert_internal_to_display
  (p_element_type_id               in     varchar2,
   p_input_value                   in     varchar2,
   p_input_value_number            in     number,
   p_session_date                  in     date,
   p_batch_id                      in     number
  ) return varchar2;
--
end PAY_PAYWSQEE_PKG;

/
