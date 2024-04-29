--------------------------------------------------------
--  DDL for Package PY_ELEMENT_ENTRY_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PY_ELEMENT_ENTRY_API" AUTHID CURRENT_USER as
/* $Header: pyeleapi.pkh 120.2.12010000.1 2008/07/27 22:30:34 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_element_entry >-------------------------|
-- ----------------------------------------------------------------------------
-- Description:
--
-- This version of the API is now out-of-date however it has been provided to
-- you for backward compatibility support and will be removed in the future.
-- Oracle recommends you to modify existing calling programs in advance of the
-- support being withdrawn thus avoiding any potential disruption.
--
procedure create_element_entry
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_business_group_id             in     number
  ,p_original_entry_id             in     number   default null
  ,p_assignment_id                 in     number
  ,p_element_link_id               in     number
  ,p_entry_type                    in     varchar2
  ,p_creator_type                  in     varchar2 default 'F'
  ,p_cost_allocation_keyflex_id    in     number   default null
  ,p_updating_action_id            in     number   default null
  ,p_updating_action_type          in     varchar2 default null
  ,p_comment_id                    in     number   default null
  ,p_reason                        in     varchar2 default null
  ,p_target_entry_id               in     number   default null
  ,p_subpriority                   in     number   default null
  ,p_date_earned                   in     date     default null
  ,p_personal_payment_method_id    in     number   default null
  ,p_attribute_category            in     varchar2 default null
  ,p_attribute1                    in     varchar2 default null
  ,p_attribute2                    in     varchar2 default null
  ,p_attribute3                    in     varchar2 default null
  ,p_attribute4                    in     varchar2 default null
  ,p_attribute5                    in     varchar2 default null
  ,p_attribute6                    in     varchar2 default null
  ,p_attribute7                    in     varchar2 default null
  ,p_attribute8                    in     varchar2 default null
  ,p_attribute9                    in     varchar2 default null
  ,p_attribute10                   in     varchar2 default null
  ,p_attribute11                   in     varchar2 default null
  ,p_attribute12                   in     varchar2 default null
  ,p_attribute13                   in     varchar2 default null
  ,p_attribute14                   in     varchar2 default null
  ,p_attribute15                   in     varchar2 default null
  ,p_attribute16                   in     varchar2 default null
  ,p_attribute17                   in     varchar2 default null
  ,p_attribute18                   in     varchar2 default null
  ,p_attribute19                   in     varchar2 default null
  ,p_attribute20                   in     varchar2 default null
  ,p_input_value_id1               in     number   default null
  ,p_input_value_id2               in     number   default null
  ,p_input_value_id3               in     number   default null
  ,p_input_value_id4               in     number   default null
  ,p_input_value_id5               in     number   default null
  ,p_input_value_id6               in     number   default null
  ,p_input_value_id7               in     number   default null
  ,p_input_value_id8               in     number   default null
  ,p_input_value_id9               in     number   default null
  ,p_input_value_id10              in     number   default null
  ,p_input_value_id11              in     number   default null
  ,p_input_value_id12              in     number   default null
  ,p_input_value_id13              in     number   default null
  ,p_input_value_id14              in     number   default null
  ,p_input_value_id15              in     number   default null
  ,p_entry_value1                  in     varchar2 default null
  ,p_entry_value2                  in     varchar2 default null
  ,p_entry_value3                  in     varchar2 default null
  ,p_entry_value4                  in     varchar2 default null
  ,p_entry_value5                  in     varchar2 default null
  ,p_entry_value6                  in     varchar2 default null
  ,p_entry_value7                  in     varchar2 default null
  ,p_entry_value8                  in     varchar2 default null
  ,p_entry_value9                  in     varchar2 default null
  ,p_entry_value10                 in     varchar2 default null
  ,p_entry_value11                 in     varchar2 default null
  ,p_entry_value12                 in     varchar2 default null
  ,p_entry_value13                 in     varchar2 default null
  ,p_entry_value14                 in     varchar2 default null
  ,p_entry_value15                 in     varchar2 default null
  ,p_entry_information_category    in     varchar2 default null
  ,p_entry_information1            in     varchar2 default null
  ,p_entry_information2            in     varchar2 default null
  ,p_entry_information3            in     varchar2 default null
  ,p_entry_information4            in     varchar2 default null
  ,p_entry_information5            in     varchar2 default null
  ,p_entry_information6            in     varchar2 default null
  ,p_entry_information7            in     varchar2 default null
  ,p_entry_information8            in     varchar2 default null
  ,p_entry_information9            in     varchar2 default null
  ,p_entry_information10           in     varchar2 default null
  ,p_entry_information11           in     varchar2 default null
  ,p_entry_information12           in     varchar2 default null
  ,p_entry_information13           in     varchar2 default null
  ,p_entry_information14           in     varchar2 default null
  ,p_entry_information15           in     varchar2 default null
  ,p_entry_information16           in     varchar2 default null
  ,p_entry_information17           in     varchar2 default null
  ,p_entry_information18           in     varchar2 default null
  ,p_entry_information19           in     varchar2 default null
  ,p_entry_information20           in     varchar2 default null
  ,p_entry_information21           in     varchar2 default null
  ,p_entry_information22           in     varchar2 default null
  ,p_entry_information23           in     varchar2 default null
  ,p_entry_information24           in     varchar2 default null
  ,p_entry_information25           in     varchar2 default null
  ,p_entry_information26           in     varchar2 default null
  ,p_entry_information27           in     varchar2 default null
  ,p_entry_information28           in     varchar2 default null
  ,p_entry_information29           in     varchar2 default null
  ,p_entry_information30           in     varchar2 default null
  ,p_override_user_ent_chk         in     varchar2 default 'N'
  ,p_effective_start_date             out nocopy date
  ,p_effective_end_date               out nocopy date
  ,p_element_entry_id                 out nocopy number
  ,p_object_version_number            out nocopy number
  ,p_create_warning                   out nocopy boolean
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_element_entry >-------------------------|
-- ----------------------------------------------------------------------------
--
-- This version of the API is now out-of-date however it has been provided to
-- you for backward compatibility support and will be removed in the future.
-- Oracle recommends you to modify existing calling programs in advance of the
-- support being withdrawn thus avoiding any potential disruption.
--
procedure delete_element_entry
  (p_validate                      in            boolean  default false
  ,p_datetrack_delete_mode         in            varchar2
  ,p_effective_date                in            date
  ,p_element_entry_id              in            number
  ,p_object_version_number         in out nocopy number
  ,p_effective_start_date             out nocopy date
  ,p_effective_end_date               out nocopy date
  ,p_delete_warning                   out nocopy boolean
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_element_entry >-------------------------|
-- ----------------------------------------------------------------------------
--
-- This version of the API is now out-of-date however it has been provided to
-- you for backward compatibility support and will be removed in the future.
-- Oracle recommends you to modify existing calling programs in advance of the
-- support being withdrawn thus avoiding any potential disruption.
--
procedure update_element_entry
  (p_validate                      in     boolean   default false
  ,p_datetrack_update_mode         in     varchar2
  ,p_effective_date                in     date
  ,p_business_group_id             in     number
  ,p_element_entry_id              in     number
  ,p_object_version_number         in out nocopy number
  ,p_cost_allocation_keyflex_id    in     number    default hr_api.g_number
  ,p_updating_action_id            in     number    default hr_api.g_number
  ,p_updating_action_type          in     varchar2  default hr_api.g_varchar2
  ,p_original_entry_id             in     number    default hr_api.g_number
  ,p_creator_type                  in     varchar2  default hr_api.g_varchar2
  ,p_comment_id                    in     number    default hr_api.g_number
  ,p_creator_id                    in     number    default hr_api.g_number
  ,p_reason                        in     varchar2  default hr_api.g_varchar2
  ,p_subpriority                   in     number    default hr_api.g_number
  ,p_date_earned                   in     date      default hr_api.g_date
  ,p_personal_payment_method_id    in     number    default hr_api.g_number
  ,p_attribute_category            in     varchar2  default hr_api.g_varchar2
  ,p_attribute1                    in     varchar2  default hr_api.g_varchar2
  ,p_attribute2                    in     varchar2  default hr_api.g_varchar2
  ,p_attribute3                    in     varchar2  default hr_api.g_varchar2
  ,p_attribute4                    in     varchar2  default hr_api.g_varchar2
  ,p_attribute5                    in     varchar2  default hr_api.g_varchar2
  ,p_attribute6                    in     varchar2  default hr_api.g_varchar2
  ,p_attribute7                    in     varchar2  default hr_api.g_varchar2
  ,p_attribute8                    in     varchar2  default hr_api.g_varchar2
  ,p_attribute9                    in     varchar2  default hr_api.g_varchar2
  ,p_attribute10                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute11                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute12                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute13                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute14                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute15                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute16                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute17                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute18                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute19                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute20                   in     varchar2  default hr_api.g_varchar2
  ,p_input_value_id1               in     number    default null
  ,p_input_value_id2               in     number    default null
  ,p_input_value_id3               in     number    default null
  ,p_input_value_id4               in     number    default null
  ,p_input_value_id5               in     number    default null
  ,p_input_value_id6               in     number    default null
  ,p_input_value_id7               in     number    default null
  ,p_input_value_id8               in     number    default null
  ,p_input_value_id9               in     number    default null
  ,p_input_value_id10              in     number    default null
  ,p_input_value_id11              in     number    default null
  ,p_input_value_id12              in     number    default null
  ,p_input_value_id13              in     number    default null
  ,p_input_value_id14              in     number    default null
  ,p_input_value_id15              in     number    default null
  ,p_entry_value1                  in     varchar2  default null
  ,p_entry_value2                  in     varchar2  default null
  ,p_entry_value3                  in     varchar2  default null
  ,p_entry_value4                  in     varchar2  default null
  ,p_entry_value5                  in     varchar2  default null
  ,p_entry_value6                  in     varchar2  default null
  ,p_entry_value7                  in     varchar2  default null
  ,p_entry_value8                  in     varchar2  default null
  ,p_entry_value9                  in     varchar2  default null
  ,p_entry_value10                 in     varchar2  default null
  ,p_entry_value11                 in     varchar2  default null
  ,p_entry_value12                 in     varchar2  default null
  ,p_entry_value13                 in     varchar2  default null
  ,p_entry_value14                 in     varchar2  default null
  ,p_entry_value15                 in     varchar2  default null
  ,p_entry_information_category    in     varchar2  default hr_api.g_varchar2
  ,p_entry_information1            in     varchar2  default hr_api.g_varchar2
  ,p_entry_information2            in     varchar2  default hr_api.g_varchar2
  ,p_entry_information3            in     varchar2  default hr_api.g_varchar2
  ,p_entry_information4            in     varchar2  default hr_api.g_varchar2
  ,p_entry_information5            in     varchar2  default hr_api.g_varchar2
  ,p_entry_information6            in     varchar2  default hr_api.g_varchar2
  ,p_entry_information7            in     varchar2  default hr_api.g_varchar2
  ,p_entry_information8            in     varchar2  default hr_api.g_varchar2
  ,p_entry_information9            in     varchar2  default hr_api.g_varchar2
  ,p_entry_information10           in     varchar2  default hr_api.g_varchar2
  ,p_entry_information11           in     varchar2  default hr_api.g_varchar2
  ,p_entry_information12           in     varchar2  default hr_api.g_varchar2
  ,p_entry_information13           in     varchar2  default hr_api.g_varchar2
  ,p_entry_information14           in     varchar2  default hr_api.g_varchar2
  ,p_entry_information15           in     varchar2  default hr_api.g_varchar2
  ,p_entry_information16           in     varchar2  default hr_api.g_varchar2
  ,p_entry_information17           in     varchar2  default hr_api.g_varchar2
  ,p_entry_information18           in     varchar2  default hr_api.g_varchar2
  ,p_entry_information19           in     varchar2  default hr_api.g_varchar2
  ,p_entry_information20           in     varchar2  default hr_api.g_varchar2
  ,p_entry_information21           in     varchar2  default hr_api.g_varchar2
  ,p_entry_information22           in     varchar2  default hr_api.g_varchar2
  ,p_entry_information23           in     varchar2  default hr_api.g_varchar2
  ,p_entry_information24           in     varchar2  default hr_api.g_varchar2
  ,p_entry_information25           in     varchar2  default hr_api.g_varchar2
  ,p_entry_information26           in     varchar2  default hr_api.g_varchar2
  ,p_entry_information27           in     varchar2  default hr_api.g_varchar2
  ,p_entry_information28           in     varchar2  default hr_api.g_varchar2
  ,p_entry_information29           in     varchar2  default hr_api.g_varchar2
  ,p_entry_information30           in     varchar2  default hr_api.g_varchar2
  ,p_override_user_ent_chk         in     varchar2  default 'N'
  ,p_effective_start_date             out nocopy date
  ,p_effective_end_date               out nocopy date
  ,p_update_warning                   out nocopy boolean
  );
--
end py_element_entry_api;

/
