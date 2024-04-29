--------------------------------------------------------
--  DDL for Package PAY_ELEMENT_ENTRY_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_ELEMENT_ENTRY_API" AUTHID CURRENT_USER as
/* $Header: pyeleapi.pkh 120.2.12010000.1 2008/07/27 22:30:34 appldev ship $ */
/*#
 * This package contains element entry APIs.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Element Entry
*/
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_element_entry >-----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates element entries and element entry values.
 *
 * The number of element entry values created always equals the number of input
 * values for the corresponding element type.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The assignment and element link must exist and the assignment must be
 * eligible for that link.
 *
 * <p><b>Post Success</b><br>
 * The element entry and element entry values will be created.
 *
 * <p><b>Post Failure</b><br>
 * The element entry and element entry values will not be created and an error
 * will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Determines when the DateTrack operation comes into
 * force.
 * @param p_business_group_id Obsolete parameter, do not use.
 * @param p_original_entry_id Obsolete parameter, do not use.
 * @param p_assignment_id Identifies the assignment for which you create the
 * Element Entry record.
 * @param p_element_link_id Foreign key to PAY_ELEMENT_LINKS
 * @param p_entry_type Entry type. Valid values are defined by the
 * 'ENTRY_VALUE' lookup type.
 * @param p_creator_type Describes the creator of the element entry. Valid
 * values are defined by the 'CREATOR_TYPE' lookup type.
 * @param p_cost_allocation_keyflex_id Identifier for the Cost Allocation
 * Keyflex
 * @param p_updating_action_id Reserved parameter, do not use.
 * @param p_updating_action_type Reserved parameter, do not use.
 * @param p_comment_id Identifier for the comment
 * @param p_reason Reason attached to element entry. Values validated by user
 * extensible 'REASON' lookup type.
 * @param p_target_entry_id When creating and adjustment element entry, is the
 * element_entry_id of the target of the adjustment.
 * @param p_subpriority Sub priority value used in payroll processing of the
 * element entry.
 * @param p_date_earned Date earned.
 * @param p_personal_payment_method_id Foreign key to
 * PAY_PERSONAL_PAYMENT_METHODS
 * @param p_attribute_category This context value determines which flexfield
 * structure to use with the descriptive flexfield segments.
 * @param p_attribute1 Descriptive flexfield segment.
 * @param p_attribute2 Descriptive flexfield segment.
 * @param p_attribute3 Descriptive flexfield segment.
 * @param p_attribute4 Descriptive flexfield segment.
 * @param p_attribute5 Descriptive flexfield segment.
 * @param p_attribute6 Descriptive flexfield segment.
 * @param p_attribute7 Descriptive flexfield segment.
 * @param p_attribute8 Descriptive flexfield segment.
 * @param p_attribute9 Descriptive flexfield segment.
 * @param p_attribute10 Descriptive flexfield segment.
 * @param p_attribute11 Descriptive flexfield segment.
 * @param p_attribute12 Descriptive flexfield segment.
 * @param p_attribute13 Descriptive flexfield segment.
 * @param p_attribute14 Descriptive flexfield segment.
 * @param p_attribute15 Descriptive flexfield segment.
 * @param p_attribute16 Descriptive flexfield segment.
 * @param p_attribute17 Descriptive flexfield segment.
 * @param p_attribute18 Descriptive flexfield segment.
 * @param p_attribute19 Descriptive flexfield segment.
 * @param p_attribute20 Descriptive flexfield segment.
 * @param p_input_value_id1 Indentifier for the Input Value
 * @param p_input_value_id2 Indentifier for the Input Value
 * @param p_input_value_id3 Indentifier for the Input Value
 * @param p_input_value_id4 Indentifier for the Input Value
 * @param p_input_value_id5 Indentifier for the Input Value
 * @param p_input_value_id6 Indentifier for the Input Value
 * @param p_input_value_id7 Indentifier for the Input Value
 * @param p_input_value_id8 Indentifier for the Input Value
 * @param p_input_value_id9 Indentifier for the Input Value
 * @param p_input_value_id10 Indentifier for the Input Value
 * @param p_input_value_id11 Indentifier for the Input Value
 * @param p_input_value_id12 Indentifier for the Input Value
 * @param p_input_value_id13 Indentifier for the Input Value
 * @param p_input_value_id14 Indentifier for the Input Value
 * @param p_input_value_id15 Indentifier for the Input Value
 * @param p_entry_value1 Element entry value.
 * @param p_entry_value2 Element entry value.
 * @param p_entry_value3 Element entry value.
 * @param p_entry_value4 Element entry value.
 * @param p_entry_value5 Element entry value.
 * @param p_entry_value6 Element entry value.
 * @param p_entry_value7 Element entry value.
 * @param p_entry_value8 Element entry value.
 * @param p_entry_value9 Element entry value.
 * @param p_entry_value10 Element entry value.
 * @param p_entry_value11 Element entry value.
 * @param p_entry_value12 Element entry value.
 * @param p_entry_value13 Element entry value.
 * @param p_entry_value14 Element entry value.
 * @param p_entry_value15 Element entry value.
 * @param p_entry_information_category Obsolete parameter, do not use.
 * @param p_entry_information1 Developer Descriptive flexfield segment.
 * @param p_entry_information2 Developer Descriptive flexfield segment.
 * @param p_entry_information3 Developer Descriptive flexfield segment.
 * @param p_entry_information4 Developer Descriptive flexfield segment.
 * @param p_entry_information5 Developer Descriptive flexfield segment.
 * @param p_entry_information6 Developer Descriptive flexfield segment.
 * @param p_entry_information7 Developer Descriptive flexfield segment.
 * @param p_entry_information8 Developer Descriptive flexfield segment.
 * @param p_entry_information9 Developer Descriptive flexfield segment.
 * @param p_entry_information10 Developer Descriptive flexfield segment.
 * @param p_entry_information11 Developer Descriptive flexfield segment.
 * @param p_entry_information12 Developer Descriptive flexfield segment.
 * @param p_entry_information13 Developer Descriptive flexfield segment.
 * @param p_entry_information14 Developer Descriptive flexfield segment.
 * @param p_entry_information15 Developer Descriptive flexfield segment.
 * @param p_entry_information16 Developer Descriptive flexfield segment.
 * @param p_entry_information17 Developer Descriptive flexfield segment.
 * @param p_entry_information18 Developer Descriptive flexfield segment.
 * @param p_entry_information19 Developer Descriptive flexfield segment.
 * @param p_entry_information20 Developer Descriptive flexfield segment.
 * @param p_entry_information21 Developer Descriptive flexfield segment.
 * @param p_entry_information22 Developer Descriptive flexfield segment.
 * @param p_entry_information23 Developer Descriptive flexfield segment.
 * @param p_entry_information24 Developer Descriptive flexfield segment.
 * @param p_entry_information25 Developer Descriptive flexfield segment.
 * @param p_entry_information26 Developer Descriptive flexfield segment.
 * @param p_entry_information27 Developer Descriptive flexfield segment.
 * @param p_entry_information28 Developer Descriptive flexfield segment.
 * @param p_entry_information29 Developer Descriptive flexfield segment.
 * @param p_entry_information30 Developer Descriptive flexfield segment.
 * @param p_override_user_ent_chk Controls whether the user enterable status of
 * an entry value should be checked on creation or update of an element entry
 * value.Valid values are defined by 'YES_NO' lookup type.
 * @param p_effective_start_date If p_validate is false, then set to the
 * earliest effective start date for the created element entry. If p_validate
 * is true, then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date for the created element entry. If p_validate is true,
 * then set to null.
 * @param p_element_entry_id If p_validate is false, then this uniquely
 * identifies the created element entry. If p_validate is true, then set to
 * null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created element entry. If p_validate is true, then the
 * value will be null.
 * @param p_create_warning If set to true, the value set for an element entry
 * value is outside the allowable range as specified on the input value and the
 * warning flag is set.
 * @rep:displayname Create Element Entry
 * @rep:category BUSINESS_ENTITY PAY_ELEMENT_ENTRY
 * @rep:category MISC_EXTENSIONS HR_DATAPUMP
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
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
-- |---------------------------< delete_element_entry >-----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes an existing element entry and element entry values.
 *
 * The role of this process is to perform a validated delete of an existing row
 * in the pay_element_entries_f table of the HR schema
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The element entry must exist at the deletion date.
 *
 * <p><b>Post Success</b><br>
 * The element entry and the element entry values will have been deleted.
 *
 * <p><b>Post Failure</b><br>
 * The element entry and element entry values will not have been deleted and an
 * error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_datetrack_delete_mode Indicates which DateTrack mode to use when
 * deleting the record. You must set to either ZAP, DELETE, FUTURE_CHANGE or
 * DELETE_NEXT_CHANGE. Modes available for use with a particular record depend
 * on the dates of previous record changes and the effective date of this
 * change.
 * @param p_effective_date Determines when the DateTrack operation comes into
 * force.
 * @param p_element_entry_id The element entry to delete.
 * @param p_object_version_number Pass in the current version number of the
 * element entry to be deleted. When the API completes if p_validate is false,
 * will be set to the new version number of the deleted element entry. If
 * p_validate is true will be set to the same value which was passed in.
 * @param p_effective_start_date If p_validate is false, then set to the
 * effective start date for the deleted element entry row which now exists as
 * of the effective date. If p_validate is true or all row instances have been
 * deleted then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date for the deleted element entry row which now exists as of
 * the effective date. If p_validate is true or all row instances have been
 * deleted then set to null.
 * @param p_delete_warning Always set to null.
 * @rep:displayname Delete Element Entry
 * @rep:category BUSINESS_ENTITY PAY_ELEMENT_ENTRY
 * @rep:category MISC_EXTENSIONS HR_DATAPUMP
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
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
-- |---------------------------< update_element_entry >-----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API will update an existing element entry and element entry values.
 *
 * This API updates the element description or any of its input values for the
 * given element.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The element entry to update must exist at the update date.
 *
 * <p><b>Post Success</b><br>
 * The element entry and the element entry values will have been updated.
 *
 * <p><b>Post Failure</b><br>
 * The element entry and the element entry values will not have been updated
 * and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_datetrack_update_mode Indicates which DateTrack mode to use when
 * updating the record. You must set to either UPDATE, CORRECTION,
 * UPDATE_OVERRIDE or UPDATE_CHANGE_INSERT. Modes available for use with a
 * particular record depend on the dates of previous record changes and the
 * effective date of this change.
 * @param p_effective_date Determines when the DateTrack operation comes into
 * force.
 * @param p_business_group_id Obsolete parameter, do not use.
 * @param p_element_entry_id Identifies the element entry to update.
 * @param p_object_version_number Pass in the current version number of the
 * element to be updated. When the API completes if p_validate is false, will
 * be set to the new version number of the updated element entry. If p_validate
 * is true will be set to the same value which was passed in
 * @param p_cost_allocation_keyflex_id Identifier for the Cost Allocation
 * Keyflex
 * @param p_updating_action_id Reserved parameter, do not use.
 * @param p_updating_action_type Reserved parameter, do not use.
 * @param p_original_entry_id Reserved parameter, do not use.
 * @param p_creator_type Describes the creator of the element entry. Valid
 * values are defined by the 'CREATOR_TYPE' lookup type.
 * @param p_comment_id Identifier for the comment
 * @param p_creator_id Appropriate identifier associated with the creator type.
 * @param p_reason Reason attached to element entry. Values validated by user
 * extensible 'REASON' lookup type.
 * @param p_subpriority Sub priority value used in payroll processing of the
 * element entry.
 * @param p_date_earned Date earned.
 * @param p_personal_payment_method_id Foreign key to
 * PAY_PERSONAL_PAYMENT_METHODS
 * @param p_attribute_category This context value determines which flexfield
 * structure to use with the descriptive flexfield segments.
 * @param p_attribute1 Descriptive flexfield segment.
 * @param p_attribute2 Descriptive flexfield segment.
 * @param p_attribute3 Descriptive flexfield segment.
 * @param p_attribute4 Descriptive flexfield segment.
 * @param p_attribute5 Descriptive flexfield segment.
 * @param p_attribute6 Descriptive flexfield segment.
 * @param p_attribute7 Descriptive flexfield segment.
 * @param p_attribute8 Descriptive flexfield segment.
 * @param p_attribute9 Descriptive flexfield segment.
 * @param p_attribute10 Descriptive flexfield segment.
 * @param p_attribute11 Descriptive flexfield segment.
 * @param p_attribute12 Descriptive flexfield segment.
 * @param p_attribute13 Descriptive flexfield segment.
 * @param p_attribute14 Descriptive flexfield segment.
 * @param p_attribute15 Descriptive flexfield segment.
 * @param p_attribute16 Descriptive flexfield segment.
 * @param p_attribute17 Descriptive flexfield segment.
 * @param p_attribute18 Descriptive flexfield segment.
 * @param p_attribute19 Descriptive flexfield segment.
 * @param p_attribute20 Descriptive flexfield segment.
 * @param p_input_value_id1 Indentifier for the Input Value
 * @param p_input_value_id2 Indentifier for the Input Value
 * @param p_input_value_id3 Indentifier for the Input Value
 * @param p_input_value_id4 Indentifier for the Input Value
 * @param p_input_value_id5 Indentifier for the Input Value
 * @param p_input_value_id6 Indentifier for the Input Value
 * @param p_input_value_id7 Indentifier for the Input Value
 * @param p_input_value_id8 Indentifier for the Input Value
 * @param p_input_value_id9 Indentifier for the Input Value
 * @param p_input_value_id10 Indentifier for the Input Value
 * @param p_input_value_id11 Indentifier for the Input Value
 * @param p_input_value_id12 Indentifier for the Input Value
 * @param p_input_value_id13 Indentifier for the Input Value
 * @param p_input_value_id14 Indentifier for the Input Value
 * @param p_input_value_id15 Indentifier for the Input Value
 * @param p_entry_value1 Element entry value.
 * @param p_entry_value2 Element entry value.
 * @param p_entry_value3 Element entry value.
 * @param p_entry_value4 Element entry value.
 * @param p_entry_value5 Element entry value.
 * @param p_entry_value6 Element entry value.
 * @param p_entry_value7 Element entry value.
 * @param p_entry_value8 Element entry value.
 * @param p_entry_value9 Element entry value.
 * @param p_entry_value10 Element entry value.
 * @param p_entry_value11 Element entry value.
 * @param p_entry_value12 Element entry value.
 * @param p_entry_value13 Element entry value.
 * @param p_entry_value14 Element entry value.
 * @param p_entry_value15 Element entry value.
 * @param p_entry_information_category Obsolete parameter, do not use.
 * @param p_entry_information1 Developer Descriptive flexfield segment.
 * @param p_entry_information2 Developer Descriptive flexfield segment.
 * @param p_entry_information3 Developer Descriptive flexfield segment.
 * @param p_entry_information4 Developer Descriptive flexfield segment.
 * @param p_entry_information5 Developer Descriptive flexfield segment.
 * @param p_entry_information6 Developer Descriptive flexfield segment.
 * @param p_entry_information7 Developer Descriptive flexfield segment.
 * @param p_entry_information8 Developer Descriptive flexfield segment.
 * @param p_entry_information9 Developer Descriptive flexfield segment.
 * @param p_entry_information10 Developer Descriptive flexfield segment.
 * @param p_entry_information11 Developer Descriptive flexfield segment.
 * @param p_entry_information12 Developer Descriptive flexfield segment.
 * @param p_entry_information13 Developer Descriptive flexfield segment.
 * @param p_entry_information14 Developer Descriptive flexfield segment.
 * @param p_entry_information15 Developer Descriptive flexfield segment.
 * @param p_entry_information16 Developer Descriptive flexfield segment.
 * @param p_entry_information17 Developer Descriptive flexfield segment.
 * @param p_entry_information18 Developer Descriptive flexfield segment.
 * @param p_entry_information19 Developer Descriptive flexfield segment.
 * @param p_entry_information20 Developer Descriptive flexfield segment.
 * @param p_entry_information21 Developer Descriptive flexfield segment.
 * @param p_entry_information22 Developer Descriptive flexfield segment.
 * @param p_entry_information23 Developer Descriptive flexfield segment.
 * @param p_entry_information24 Developer Descriptive flexfield segment.
 * @param p_entry_information25 Developer Descriptive flexfield segment.
 * @param p_entry_information26 Developer Descriptive flexfield segment.
 * @param p_entry_information27 Developer Descriptive flexfield segment.
 * @param p_entry_information28 Developer Descriptive flexfield segment.
 * @param p_entry_information29 Developer Descriptive flexfield segment.
 * @param p_entry_information30 Developer Descriptive flexfield segment.
 * @param p_override_user_ent_chk Controls whether the user enterable status of
 * an entry value should be checked on creation or update of an element entry
 * value.Valid values are defined by 'YES_NO' lookup type.
 * @param p_effective_start_date If p_validate is false, then set to the
 * effective start date on the updated element entry row which now exists as of
 * the effective date. If p_validate is true, then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date on the updated element entry row which now exists as of
 * the effective date. If p_validate is true, then set to null.
 * @param p_update_warning If set to true, the value set for an element entry
 * value is outside the allowable range as specified on the input value and the
 * warning flag is set.
 * @rep:displayname Update Element Entry
 * @rep:category BUSINESS_ENTITY PAY_ELEMENT_ENTRY
 * @rep:category MISC_EXTENSIONS HR_DATAPUMP
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
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
  ,p_override_user_ent_chk         in     varchar2 default 'N'
  ,p_effective_start_date             out nocopy date
  ,p_effective_end_date               out nocopy date
  ,p_update_warning                   out nocopy boolean
  );
--
end pay_element_entry_api;

/
