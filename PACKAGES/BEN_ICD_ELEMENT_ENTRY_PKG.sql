--------------------------------------------------------
--  DDL for Package BEN_ICD_ELEMENT_ENTRY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ICD_ELEMENT_ENTRY_PKG" AUTHID CURRENT_USER AS
/* $Header: beicdeleent.pkh 120.3 2007/06/13 21:03:44 ashrivas noship $ */

PROCEDURE icd_update_element_entry
  (p_validate                      in     number   default 0
  ,p_datetrack_update_mode         in     varchar2
  ,p_effective_date                in     date
  ,p_business_group_id             in     number
  ,p_element_entry_id              in     number
  ,p_object_version_number         in     number
  ,p_cost_allocation_keyflex_id    in     number
  ,p_attribute_category            in     varchar2
  ,p_attribute1                    in     varchar2
  ,p_attribute2                    in     varchar2
  ,p_attribute3                    in     varchar2
  ,p_attribute4                    in     varchar2
  ,p_attribute5                    in     varchar2
  ,p_attribute6                    in     varchar2
  ,p_attribute7                    in     varchar2
  ,p_attribute8                    in     varchar2
  ,p_attribute9                    in     varchar2
  ,p_attribute10                   in     varchar2
  ,p_attribute11                   in     varchar2
  ,p_attribute12                   in     varchar2
  ,p_attribute13                   in     varchar2
  ,p_attribute14                   in     varchar2
  ,p_attribute15                   in     varchar2
  ,p_attribute16                   in     varchar2
  ,p_attribute17                   in     varchar2
  ,p_attribute18                   in     varchar2
  ,p_attribute19                   in     varchar2
  ,p_attribute20                   in     varchar2
  ,p_input_value_id1               in     number
  ,p_input_value_id2               in     number
  ,p_input_value_id3               in     number
  ,p_input_value_id4               in     number
  ,p_input_value_id5               in     number
  ,p_input_value_id6               in     number
  ,p_input_value_id7               in     number
  ,p_input_value_id8               in     number
  ,p_input_value_id9               in     number
  ,p_input_value_id10              in     number
  ,p_input_value_id11              in     number
  ,p_input_value_id12              in     number
  ,p_input_value_id13              in     number
  ,p_input_value_id14              in     number
  ,p_input_value_id15              in     number
  ,p_entry_value1                  in     varchar2
  ,p_entry_value2                  in     varchar2
  ,p_entry_value3                  in     varchar2
  ,p_entry_value4                  in     varchar2
  ,p_entry_value5                  in     varchar2
  ,p_entry_value6                  in     varchar2
  ,p_entry_value7                  in     varchar2
  ,p_entry_value8                  in     varchar2
  ,p_entry_value9                  in     varchar2
  ,p_entry_value10                 in     varchar2
  ,p_entry_value11                 in     varchar2
  ,p_entry_value12                 in     varchar2
  ,p_entry_value13                 in     varchar2
  ,p_entry_value14                 in     varchar2
  ,p_entry_value15                 in     varchar2
  ,p_entry_information_category    in     varchar2
  ,p_entry_information1            in     varchar2
  ,p_entry_information2            in     varchar2
  ,p_entry_information3            in     varchar2
  ,p_entry_information4            in     varchar2
  ,p_entry_information5            in     varchar2
  ,p_entry_information6            in     varchar2
  ,p_entry_information7            in     varchar2
  ,p_entry_information8            in     varchar2
  ,p_entry_information9            in     varchar2
  ,p_entry_information10           in     varchar2
  ,p_entry_information11           in     varchar2
  ,p_entry_information12           in     varchar2
  ,p_entry_information13           in     varchar2
  ,p_entry_information14           in     varchar2
  ,p_entry_information15           in     varchar2
  ,p_entry_information16           in     varchar2
  ,p_entry_information17           in     varchar2
  ,p_entry_information18           in     varchar2
  ,p_entry_information19           in     varchar2
  ,p_entry_information20           in     varchar2
  ,p_entry_information21           in     varchar2
  ,p_entry_information22           in     varchar2
  ,p_entry_information23           in     varchar2
  ,p_entry_information24           in     varchar2
  ,p_entry_information25           in     varchar2
  ,p_entry_information26           in     varchar2
  ,p_entry_information27           in     varchar2
  ,p_entry_information28           in     varchar2
  ,p_entry_information29           in     varchar2
  ,p_entry_information30           in     varchar2
  ,p_effective_start_date          in     date
  ,p_effective_end_date            in     date
--  ,p_icd_effective_date            in     date
--  ,p_warning                      out  nocopy  number
  );

PROCEDURE icd_create_element_entry
  (p_validate                      in     number  default 0
  ,p_effective_date                in     date
  ,p_business_group_id             in     number
  ,p_assignment_id                 in     number
  ,p_element_link_id               in     number
  ,p_entry_type                    in     varchar2
  ,p_cost_allocation_keyflex_id    in     number
  ,p_attribute_category            in     varchar2
  ,p_attribute1                    in     varchar2
  ,p_attribute2                    in     varchar2
  ,p_attribute3                    in     varchar2
  ,p_attribute4                    in     varchar2
  ,p_attribute5                    in     varchar2
  ,p_attribute6                    in     varchar2
  ,p_attribute7                    in     varchar2
  ,p_attribute8                    in     varchar2
  ,p_attribute9                    in     varchar2
  ,p_attribute10                   in     varchar2
  ,p_attribute11                   in     varchar2
  ,p_attribute12                   in     varchar2
  ,p_attribute13                   in     varchar2
  ,p_attribute14                   in     varchar2
  ,p_attribute15                   in     varchar2
  ,p_attribute16                   in     varchar2
  ,p_attribute17                   in     varchar2
  ,p_attribute18                   in     varchar2
  ,p_attribute19                   in     varchar2
  ,p_attribute20                   in     varchar2
  ,p_input_value_id1               in     number
  ,p_input_value_id2               in     number
  ,p_input_value_id3               in     number
  ,p_input_value_id4               in     number
  ,p_input_value_id5               in     number
  ,p_input_value_id6               in     number
  ,p_input_value_id7               in     number
  ,p_input_value_id8               in     number
  ,p_input_value_id9               in     number
  ,p_input_value_id10              in     number
  ,p_input_value_id11              in     number
  ,p_input_value_id12              in     number
  ,p_input_value_id13              in     number
  ,p_input_value_id14              in     number
  ,p_input_value_id15              in     number
  ,p_entry_value1                  in     varchar2
  ,p_entry_value2                  in     varchar2
  ,p_entry_value3                  in     varchar2
  ,p_entry_value4                  in     varchar2
  ,p_entry_value5                  in     varchar2
  ,p_entry_value6                  in     varchar2
  ,p_entry_value7                  in     varchar2
  ,p_entry_value8                  in     varchar2
  ,p_entry_value9                  in     varchar2
  ,p_entry_value10                 in     varchar2
  ,p_entry_value11                 in     varchar2
  ,p_entry_value12                 in     varchar2
  ,p_entry_value13                 in     varchar2
  ,p_entry_value14                 in     varchar2
  ,p_entry_value15                 in     varchar2
  ,p_entry_information_category    in     varchar2
  ,p_entry_information1            in     varchar2
  ,p_entry_information2            in     varchar2
  ,p_entry_information3            in     varchar2
  ,p_entry_information4            in     varchar2
  ,p_entry_information5            in     varchar2
  ,p_entry_information6            in     varchar2
  ,p_entry_information7            in     varchar2
  ,p_entry_information8            in     varchar2
  ,p_entry_information9            in     varchar2
  ,p_entry_information10           in     varchar2
  ,p_entry_information11           in     varchar2
  ,p_entry_information12           in     varchar2
  ,p_entry_information13           in     varchar2
  ,p_entry_information14           in     varchar2
  ,p_entry_information15           in     varchar2
  ,p_entry_information16           in     varchar2
  ,p_entry_information17           in     varchar2
  ,p_entry_information18           in     varchar2
  ,p_entry_information19           in     varchar2
  ,p_entry_information20           in     varchar2
  ,p_entry_information21           in     varchar2
  ,p_entry_information22           in     varchar2
  ,p_entry_information23           in     varchar2
  ,p_entry_information24           in     varchar2
  ,p_entry_information25           in     varchar2
  ,p_entry_information26           in     varchar2
  ,p_entry_information27           in     varchar2
  ,p_entry_information28           in     varchar2
  ,p_entry_information29           in     varchar2
  ,p_entry_information30           in     varchar2
  ,p_effective_start_date          in     date
  ,p_effective_end_date            in     date
--  ,p_icd_effective_date            in     date
--  ,p_warning                      out  nocopy  number
  );

PROCEDURE ICD_DELETE_ELEMENT_ENTRY(
   p_validate			in number default 0
   ,p_datetrack_delete_mode	in varchar2
   ,p_effective_date		in date
   ,p_element_entry_id		in number
   ,p_object_version_number	in number
  ,p_effective_start_date          in     date
  ,p_effective_end_date            in     date
--   ,p_icd_effective_date    in date
--   ,p_warning                      out  nocopy  number
   );

procedure GET_HR_TRANSACTION_ID
(
	p_item_type                     in varchar2
	,p_item_key                     in varchar2
	,p_activity_id                  in number
	,p_login_person_id              in number
	,p_person_id			in number
	,p_transaction_id		out nocopy number
	,p_transaction_step_id		out nocopy number
);

Procedure process_api(
  p_validate                    in boolean default false,
  p_transaction_step_id         in number,
  p_effective_date              in varchar2 default null
  );

procedure unsuspend_enrollment(p_icd_transaction_id in number, p_effective_Date in date);

END BEN_ICD_ELEMENT_ENTRY_PKG;

/
