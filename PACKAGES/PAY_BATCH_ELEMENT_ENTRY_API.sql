--------------------------------------------------------
--  DDL for Package PAY_BATCH_ELEMENT_ENTRY_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_BATCH_ELEMENT_ENTRY_API" AUTHID CURRENT_USER as
/* $Header: pybthapi.pkh 120.4 2005/10/28 05:44:22 adkumar noship $ */
/*#
 * This package contains Batch Element Entry APIs.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Batch Element Entry
*/
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_batch_header >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a batch header record.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * A valid business group should exists.
 *
 * <p><b>Post Success</b><br>
 * The batch header will be successfully inserted into the database.
 *
 * <p><b>Post Failure</b><br>
 * The API does not create the batch header and raises an error.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_session_date Applications effective date.
 * @param p_batch_name Name of the batch header.
 * @param p_batch_status Status of the batch. (BATCH_SOURCE lookup type of
 * HR_LOOKUPS, default 'U')
 * @param p_business_group_id Business group of record.
 * @param p_action_if_exists Type of action performed if a batch with that name
 * exists. (ACTION_IF_EXISTS lookup type of HR_LOOKUPS, Default value of 'R'.)
 * @param p_batch_reference Reference for the batch.
 * @param p_batch_source Source for the batch.
 * @param p_comments Batch header comment text.
 * @param p_date_effective_changes Creation type for the batch.
 * (DATE_EFFECTIVE_CHANGES lookup type of HR_LOOKUPS, Default value of 'C'.)
 * @param p_purge_after_transfer Purge-batch-after-transfer flag. (YES_NO
 * lookup type of HR_LOOKUPS, default 'N')
 * @param p_reject_if_future_changes Reject-if-future-change flag. (YES_NO
 * lookup type of HR_LOOKUPS, default 'Y')
 * @param p_batch_id If p_validate is false, this uniquely identifies the
 * Batch Header created. If p_validate is set to true, this parameter will be
 * null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created batch header. If p_validate is true, then the
 * value will be null.
 * @param p_reject_if_results_exists Rejects the rollback if there are run
 * results exist for the transferred line. (YES_NO lookup type of HR_LOOKUPS,
 * default 'Y')
 * @param p_purge_after_rollback Purges the batch after the rollback. (YES_NO
 * lookup type of HR_LOOKUPS, default 'Y')
 * @param p_batch_type Batch type for the given batch. This is based on
 * the lookup type PAY_BEE_BATCH_TYPE.
 * @param p_reject_entry_not_removed If this is selected and if the entry is
 * not found or not removed then the batch line status of all batch lines
 * for the given assignment will remain as 'Transferred'.
 * @param p_rollback_entry_updates Allows the option to rollback entry
 * updates other than correction and update override.
 * @rep:displayname Create Batch Header
 * @rep:category BUSINESS_ENTITY PAY_BATCH_ELEMENT_ENTRY
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_batch_header
  (p_validate                      in     boolean  default false
  ,p_session_date                  in     date
  ,p_batch_name                    in     varchar2
  ,p_batch_status                  in     varchar2 default 'U'
  ,p_business_group_id             in     number
  ,p_action_if_exists              in     varchar2 default 'R'
  ,p_batch_reference               in     varchar2 default null
  ,p_batch_source                  in     varchar2 default null
  ,p_comments                      in     varchar2 default null
  ,p_date_effective_changes        in     varchar2 default null
  ,p_purge_after_transfer          in     varchar2 default 'N'
  ,p_reject_if_future_changes      in     varchar2 default 'Y'
  ,p_batch_id                         out nocopy number
  ,p_object_version_number            out nocopy number
  ,p_reject_if_results_exists      in     varchar2 default 'Y'
  ,p_purge_after_rollback          in     varchar2 default 'N'
  ,p_batch_type                    in     varchar2 default null
  ,p_REJECT_ENTRY_NOT_REMOVED      in     varchar2 default 'N'
  ,p_ROLLBACK_ENTRY_UPDATES        in     varchar2 default 'N'
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------------< create_batch_line >-------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a batch line record.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * A Batch Header.
 *
 * <p><b>Post Success</b><br>
 * The batch line will be successfully inserted into the database.
 *
 * <p><b>Post Failure</b><br>
 * The API does not create the batch line and raises an error.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_session_date Applications effective date.
 * @param p_batch_id Foreign Key to the Batch Header.
 * @param p_batch_line_status Status of the batch. (BATCH_SOURCE lookup type of
 * HR_LOOKUPS, default 'U')
 * @param p_assignment_id {@rep:casecolumn PER_ALL_ASSIGNMENTS_F.ASSIGNMENT_ID}
 * @param p_assignment_number Assignment Number
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
 * @param p_entry_information_category Further Element Entry Info.
 * @param p_entry_information1 Further Element Entry Info.
 * @param p_entry_information2 Further Element Entry Info.
 * @param p_entry_information3 Further Element Entry Info.
 * @param p_entry_information4 Further Element Entry Info.
 * @param p_entry_information5 Further Element Entry Info.
 * @param p_entry_information6 Further Element Entry Info.
 * @param p_entry_information7 Further Element Entry Info.
 * @param p_entry_information8 Further Element Entry Info.
 * @param p_entry_information9 Further Element Entry Info.
 * @param p_entry_information10 Further Element Entry Info.
 * @param p_entry_information11 Further Element Entry Info.
 * @param p_entry_information12 Further Element Entry Info.
 * @param p_entry_information13 Further Element Entry Info.
 * @param p_entry_information14 Further Element Entry Info.
 * @param p_entry_information15 Further Element Entry Info.
 * @param p_entry_information16 Further Element Entry Info.
 * @param p_entry_information17 Further Element Entry Info.
 * @param p_entry_information18 Further Element Entry Info.
 * @param p_entry_information19 Further Element Entry Info.
 * @param p_entry_information20 Further Element Entry Info.
 * @param p_entry_information21 Further Element Entry Info.
 * @param p_entry_information22 Further Element Entry Info.
 * @param p_entry_information23 Further Element Entry Info.
 * @param p_entry_information24 Further Element Entry Info.
 * @param p_entry_information25 Further Element Entry Info.
 * @param p_entry_information26 Further Element Entry Info.
 * @param p_entry_information27 Further Element Entry Info.
 * @param p_entry_information28 Further Element Entry Info.
 * @param p_entry_information29 Further Element Entry Info.
 * @param p_entry_information30 Further Element Entry Info.
 * @param p_date_earned Date Earned
 * @param p_personal_payment_method_id Personal Payment Method
 * @param p_subpriority Sub priority
 * @param p_batch_sequence Sequence order of the line within the batch.
 * @param p_concatenated_segments Concatenated Costing Segments
 * @param p_cost_allocation_keyflex_id Identifier for the Cost Allocation
 * Keyflex
 * @param p_effective_date Determines when the DateTrack operation comes into
 * force.
 * @param p_effective_start_date This will be used as the absence start date or
 * the effective start date for certain elements.
 * @param p_effective_end_date This will be used as the absence end date or the
 * effective end date for certain elements.
 * @param p_element_name Element Name
 * @param p_element_type_id Identifier for the Element Type
 * @param p_entry_type Entry Type (ENTRY_TYPE lookup type of HR_LOOKUPS)
 * @param p_reason Reason
 * @param p_segment1 Key flexfield segment for Element Entry Info.
 * @param p_segment2 Key flexfield segment for Element Entry Info.
 * @param p_segment3 Key flexfield segment for Element Entry Info.
 * @param p_segment4 Key flexfield segment for Element Entry Info.
 * @param p_segment5 Key flexfield segment for Element Entry Info.
 * @param p_segment6 Key flexfield segment for Element Entry Info.
 * @param p_segment7 Key flexfield segment for Element Entry Info.
 * @param p_segment8 Key flexfield segment for Element Entry Info.
 * @param p_segment9 Key flexfield segment for Element Entry Info.
 * @param p_segment10 Key flexfield segment for Element Entry Info.
 * @param p_segment11 Key flexfield segment for Element Entry Info.
 * @param p_segment12 Key flexfield segment for Element Entry Info.
 * @param p_segment13 Key flexfield segment for Element Entry Info.
 * @param p_segment14 Key flexfield segment for Element Entry Info.
 * @param p_segment15 Key flexfield segment for Element Entry Info.
 * @param p_segment16 Key flexfield segment for Element Entry Info.
 * @param p_segment17 Key flexfield segment.
 * @param p_segment18 Key flexfield segment.
 * @param p_segment19 Key flexfield segment.
 * @param p_segment20 Key flexfield segment.
 * @param p_segment21 Key flexfield segment.
 * @param p_segment22 Key flexfield segment.
 * @param p_segment23 Key flexfield segment.
 * @param p_segment24 Key flexfield segment.
 * @param p_segment25 Key flexfield segment.
 * @param p_segment26 Key flexfield segment.
 * @param p_segment27 Key flexfield segment.
 * @param p_segment28 Key flexfield segment.
 * @param p_segment29 Key flexfield segment.
 * @param p_segment30 Key flexfield segment.
 * @param p_value_1 Input Value
 * @param p_value_2 Input Value
 * @param p_value_3 Input Value
 * @param p_value_4 Input Value
 * @param p_value_5 Input Value
 * @param p_value_6 Input Value
 * @param p_value_7 Input Value
 * @param p_value_8 Input Value
 * @param p_value_9 Input Value
 * @param p_value_10 Input Value
 * @param p_value_11 Input Value
 * @param p_value_12 Input Value
 * @param p_value_13 Input Value
 * @param p_value_14 Input Value
 * @param p_value_15 Input Value
 * @param p_canonical_date_format (Y/N) To indicate whether the date format of
 * the input values is in internal or display format.
 * @param p_iv_all_internal_format (Y/N) Internal format for all input values.
 * If set to 'Y' then it overrides the p_canonical_date_format flag.
 * @param p_batch_line_id If p_validate is false, this uniquely identifies the
 * Batch Line created. If p_validate is set to true, this parameter will be
 * null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created batch line. If p_validate is true, then the
 * value will be null.
 * @rep:displayname Create Batch Line
 * @rep:category BUSINESS_ENTITY PAY_BATCH_ELEMENT_ENTRY
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_batch_line
  (p_validate                      in     boolean  default false
  ,p_session_date                  in     date
  ,p_batch_id                      in     number
  ,p_batch_line_status             in     varchar2 default 'U'
  ,p_assignment_id                 in     number   default null
  ,p_assignment_number             in     varchar2 default null
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
  ,p_date_earned                   in     date     default null
  ,p_personal_payment_method_id    in     number   default null
  ,p_subpriority                   in     number   default null
  ,p_batch_sequence                in     number   default null
  ,p_concatenated_segments         in     varchar2 default null
  ,p_cost_allocation_keyflex_id    in     number   default null
  ,p_effective_date                in     date     default null
  ,p_effective_start_date          in     date     default null
  ,p_effective_end_date            in     date     default null
  ,p_element_name                  in     varchar2 default null
  ,p_element_type_id               in     number   default null
  ,p_entry_type                    in     varchar2 default null
  ,p_reason                        in     varchar2 default null
  ,p_segment1                      in     varchar2 default null
  ,p_segment2                      in     varchar2 default null
  ,p_segment3                      in     varchar2 default null
  ,p_segment4                      in     varchar2 default null
  ,p_segment5                      in     varchar2 default null
  ,p_segment6                      in     varchar2 default null
  ,p_segment7                      in     varchar2 default null
  ,p_segment8                      in     varchar2 default null
  ,p_segment9                      in     varchar2 default null
  ,p_segment10                     in     varchar2 default null
  ,p_segment11                     in     varchar2 default null
  ,p_segment12                     in     varchar2 default null
  ,p_segment13                     in     varchar2 default null
  ,p_segment14                     in     varchar2 default null
  ,p_segment15                     in     varchar2 default null
  ,p_segment16                     in     varchar2 default null
  ,p_segment17                     in     varchar2 default null
  ,p_segment18                     in     varchar2 default null
  ,p_segment19                     in     varchar2 default null
  ,p_segment20                     in     varchar2 default null
  ,p_segment21                     in     varchar2 default null
  ,p_segment22                     in     varchar2 default null
  ,p_segment23                     in     varchar2 default null
  ,p_segment24                     in     varchar2 default null
  ,p_segment25                     in     varchar2 default null
  ,p_segment26                     in     varchar2 default null
  ,p_segment27                     in     varchar2 default null
  ,p_segment28                     in     varchar2 default null
  ,p_segment29                     in     varchar2 default null
  ,p_segment30                     in     varchar2 default null
  ,p_value_1                       in     varchar2 default null
  ,p_value_2                       in     varchar2 default null
  ,p_value_3                       in     varchar2 default null
  ,p_value_4                       in     varchar2 default null
  ,p_value_5                       in     varchar2 default null
  ,p_value_6                       in     varchar2 default null
  ,p_value_7                       in     varchar2 default null
  ,p_value_8                       in     varchar2 default null
  ,p_value_9                       in     varchar2 default null
  ,p_value_10                      in     varchar2 default null
  ,p_value_11                      in     varchar2 default null
  ,p_value_12                      in     varchar2 default null
  ,p_value_13                      in     varchar2 default null
  ,p_value_14                      in     varchar2 default null
  ,p_value_15                      in     varchar2 default null
  ,p_canonical_date_format         in     varchar2 default 'Y'
  ,p_iv_all_internal_format        in     varchar2 default 'N'
  ,p_batch_line_id                    out nocopy number
  ,p_object_version_number            out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------------< create_batch_total >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a batch control total record.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * A Batch Header.
 *
 * <p><b>Post Success</b><br>
 * The batch control total will be successfully inserted into the database.
 *
 * <p><b>Post Failure</b><br>
 * The API does not create the batch control total and raises an error.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_session_date Applications effective date.
 * @param p_batch_id Foreign Key to the Batch Header.
 * @param p_control_status Status of the batch control total. (BATCH_SOURCE
 * lookup type of HR_LOOKUPS, default 'U')
 * @param p_control_total Control total value.
 * @param p_control_type Type of rows to be summed. (Lookup type of
 * 'CONTROL_TYPE' within HR_LOOKUPS)
 * @param p_batch_control_id If p_validate is false, this uniquely identifies
 * the Batch Control Total created. If p_validate is set to true, this
 * parameter will be null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created batch control total. If p_validate is true,
 * then the value will be null.
 * @rep:displayname Create Batch Total
 * @rep:category BUSINESS_ENTITY PAY_BATCH_ELEMENT_ENTRY
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_batch_total
  (p_validate                      in     boolean  default false
  ,p_session_date                  in     date
  ,p_batch_id                      in     number
  ,p_control_status                in     varchar2 default 'U'
  ,p_control_total                 in     varchar2 default null
  ,p_control_type                  in     varchar2 default null
  ,p_batch_control_id                 out nocopy number
  ,p_object_version_number            out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_batch_header >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates the batch header information.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * A valid batch header should exists.
 *
 * <p><b>Post Success</b><br>
 * The batch header will be successfully updated into the database.
 *
 * <p><b>Post Failure</b><br>
 * The API does not update the batch header and raises an error.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_session_date Applications effective date.
 * @param p_batch_id Primary Key of the record.
 * @param p_object_version_number Pass in the current version number of the
 * batch header to be updated. When the API completes if p_validate is false,
 * will be set to the new version number of the updated batch header. If
 * p_validate is true will be set to the same value which was passed in.
 * @param p_action_if_exists Type of action performed if a batch with that name
 * exists. (ACTION_IF_EXISTS lookup type of HR_LOOKUPS)
 * @param p_batch_name Name of the batch header.
 * @param p_batch_reference Reference for the batch.
 * @param p_batch_source Source for the batch.
 * @param p_batch_status Status of the batch.
 * @param p_comments Batch header comment text.
 * @param p_date_effective_changes Creation type for the batch.
 * (DATE_EFFECTIVE_CHANGES lookup type of HR_LOOKUPS)
 * @param p_purge_after_transfer Purge-batch-after-transfer flag. (YES_NO
 * lookup type of HR_LOOKUPS)
 * @param p_reject_if_future_changes Reject-if-future-change flag. (YES_NO
 * lookup type of HR_LOOKUPS)
 * @param p_reject_if_results_exists Rejects the rollback if there are run
 * results exist for the transferred line. (YES_NO lookup type of HR_LOOKUPS,
 * default 'Y')
 * @param p_purge_after_rollback Purges the batch after the rollback. (YES_NO
 * lookup type of HR_LOOKUPS, default 'Y')
 * @param p_batch_type Batch type for the given batch. This is based on
 * the lookup type PAY_BEE_BATCH_TYPE.
 * @param p_reject_entry_not_removed If this is selected and if the entry is
 * not found or not removed then the batch line status of all batch lines
 * for the given assignment will remain as 'Transferred'.
 * @param p_rollback_entry_updates Allows the option to rollback entry
 * updates other than correction and update override.
 * @rep:displayname Update Batch Header
 * @rep:category BUSINESS_ENTITY PAY_BATCH_ELEMENT_ENTRY
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_batch_header
  (p_validate                      in     boolean  default false
  ,p_session_date                  in     date
  ,p_batch_id                      in     number
  ,p_object_version_number         in out nocopy number
  ,p_action_if_exists              in     varchar2 default hr_api.g_varchar2
  ,p_batch_name                    in     varchar2 default hr_api.g_varchar2
  ,p_batch_reference               in     varchar2 default hr_api.g_varchar2
  ,p_batch_source                  in     varchar2 default hr_api.g_varchar2
  ,p_batch_status                  in     varchar2 default hr_api.g_varchar2
  ,p_comments                      in     varchar2 default hr_api.g_varchar2
  ,p_date_effective_changes        in     varchar2 default hr_api.g_varchar2
  ,p_purge_after_transfer          in     varchar2 default hr_api.g_varchar2
  ,p_reject_if_future_changes      in     varchar2 default hr_api.g_varchar2
  ,p_reject_if_results_exists      in     varchar2 default hr_api.g_varchar2
  ,p_purge_after_rollback          in     varchar2 default hr_api.g_varchar2
  ,p_batch_type                    in     varchar2 default hr_api.g_varchar2
  ,p_REJECT_ENTRY_NOT_REMOVED      in     varchar2 default hr_api.g_varchar2
  ,p_ROLLBACK_ENTRY_UPDATES        in     varchar2 default hr_api.g_varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------------< update_batch_line >-------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates the batch line information.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * A Batch Header.
 *
 * <p><b>Post Success</b><br>
 * The batch line will be successfully updated into the database.
 *
 * <p><b>Post Failure</b><br>
 * The API does not update the batch line and raises an error.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_session_date Applications effective date.
 * @param p_batch_line_id Primary Key of the record.
 * @param p_batch_line_status Line's status. (BATCH_STATUS lookup value)
 * @param p_object_version_number Pass in the current version number of the
 * batch line to be updated. When the API completes if p_validate is false,
 * will be set to the new version number of the updated batch line. If
 * p_validate is true will be set to the same value which was passed in.
 * @param p_assignment_id {@rep:casecolumn PER_ALL_ASSIGNMENTS_F.ASSIGNMENT_ID}
 * @param p_assignment_number Assignment Number
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
 * @param p_entry_information_category Further Element Entry Info.
 * @param p_entry_information1 Further Element Entry Info.
 * @param p_entry_information2 Further Element Entry Info.
 * @param p_entry_information3 Further Element Entry Info.
 * @param p_entry_information4 Further Element Entry Info.
 * @param p_entry_information5 Further Element Entry Info.
 * @param p_entry_information6 Further Element Entry Info.
 * @param p_entry_information7 Further Element Entry Info.
 * @param p_entry_information8 Further Element Entry Info.
 * @param p_entry_information9 Further Element Entry Info.
 * @param p_entry_information10 Further Element Entry Info.
 * @param p_entry_information11 Further Element Entry Info.
 * @param p_entry_information12 Further Element Entry Info.
 * @param p_entry_information13 Further Element Entry Info.
 * @param p_entry_information14 Further Element Entry Info.
 * @param p_entry_information15 Further Element Entry Info.
 * @param p_entry_information16 Further Element Entry Info.
 * @param p_entry_information17 Further Element Entry Info.
 * @param p_entry_information18 Further Element Entry Info.
 * @param p_entry_information19 Further Element Entry Info.
 * @param p_entry_information20 Further Element Entry Info.
 * @param p_entry_information21 Further Element Entry Info.
 * @param p_entry_information22 Further Element Entry Info.
 * @param p_entry_information23 Further Element Entry Info.
 * @param p_entry_information24 Further Element Entry Info.
 * @param p_entry_information25 Further Element Entry Info.
 * @param p_entry_information26 Further Element Entry Info.
 * @param p_entry_information27 Further Element Entry Info.
 * @param p_entry_information28 Further Element Entry Info.
 * @param p_entry_information29 Further Element Entry Info.
 * @param p_entry_information30 Further Element Entry Info.
 * @param p_date_earned Date Earned
 * @param p_personal_payment_method_id Personal Payment Method
 * @param p_subpriority Sub priority
 * @param p_batch_sequence Sequence order of the line within the batch.
 * @param p_concatenated_segments Concatenated Costing Segments
 * @param p_cost_allocation_keyflex_id Identifier for the Cost Allocation
 * Keyflex
 * @param p_effective_date Determines when the DateTrack operation comes into
 * force.
 * @param p_effective_start_date This will be used as the absence start date or
 * the effective start date for certain elements.
 * @param p_effective_end_date This will be used as the absence end date or the
 * effective end date for certain elements.
 * @param p_element_name Element Name
 * @param p_element_type_id Identifier for the Element Type
 * @param p_entry_type Entry Type (ENTRY_TYPE lookup type of HR_LOOKUPS)
 * @param p_reason Reason
 * @param p_segment1 Key flexfield segment.
 * @param p_segment2 Key flexfield segment.
 * @param p_segment3 Key flexfield segment.
 * @param p_segment4 Key flexfield segment.
 * @param p_segment5 Key flexfield segment.
 * @param p_segment6 Key flexfield segment.
 * @param p_segment7 Key flexfield segment.
 * @param p_segment8 Key flexfield segment.
 * @param p_segment9 Key flexfield segment.
 * @param p_segment10 Key flexfield segment.
 * @param p_segment11 Key flexfield segment.
 * @param p_segment12 Key flexfield segment.
 * @param p_segment13 Key flexfield segment.
 * @param p_segment14 Key flexfield segment.
 * @param p_segment15 Key flexfield segment.
 * @param p_segment16 Key flexfield segment.
 * @param p_segment17 Key flexfield segment.
 * @param p_segment18 Key flexfield segment.
 * @param p_segment19 Key flexfield segment.
 * @param p_segment20 Key flexfield segment.
 * @param p_segment21 Key flexfield segment.
 * @param p_segment22 Key flexfield segment.
 * @param p_segment23 Key flexfield segment.
 * @param p_segment24 Key flexfield segment.
 * @param p_segment25 Key flexfield segment.
 * @param p_segment26 Key flexfield segment.
 * @param p_segment27 Key flexfield segment.
 * @param p_segment28 Key flexfield segment.
 * @param p_segment29 Key flexfield segment.
 * @param p_segment30 Key flexfield segment.
 * @param p_value_1 Input Value
 * @param p_value_2 Input Value
 * @param p_value_3 Input Value
 * @param p_value_4 Input Value
 * @param p_value_5 Input Value
 * @param p_value_6 Input Value
 * @param p_value_7 Input Value
 * @param p_value_8 Input Value
 * @param p_value_9 Input Value
 * @param p_value_10 Input Value
 * @param p_value_11 Input Value
 * @param p_value_12 Input Value
 * @param p_value_13 Input Value
 * @param p_value_14 Input Value
 * @param p_value_15 Input Value
 * @param p_canonical_date_format (Y/N) To indicate whether the date format of
 * the input values is in internal or display format.
 * @param p_iv_all_internal_format (Y/N) Internal format for all input values.
 * If set to 'Y' then it overrides the p_canonical_date_format flag.
 * @rep:displayname Update Batch Line
 * @rep:category BUSINESS_ENTITY PAY_BATCH_ELEMENT_ENTRY
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_batch_line
  (p_validate                      in     boolean  default false
  ,p_session_date                  in     date
  ,p_batch_line_id                 in     number
  ,p_batch_line_status             in     varchar2 default hr_api.g_varchar2
  ,p_object_version_number         in out nocopy number
  ,p_assignment_id                 in     number   default hr_api.g_number
  ,p_assignment_number             in     varchar2 default hr_api.g_varchar2
  ,p_attribute_category            in     varchar2 default hr_api.g_varchar2
  ,p_attribute1                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute2                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute3                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute4                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute5                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute6                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute7                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute8                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute9                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute10                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute11                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute12                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute13                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute14                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute15                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute16                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute17                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute18                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute19                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute20                   in     varchar2 default hr_api.g_varchar2
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
  ,p_date_earned                   in     date      default hr_api.g_date
  ,p_personal_payment_method_id    in     number    default hr_api.g_number
  ,p_subpriority                   in     number    default hr_api.g_number
  ,p_batch_sequence                in     number   default hr_api.g_number
  ,p_concatenated_segments         in     varchar2 default hr_api.g_varchar2
  ,p_cost_allocation_keyflex_id    in     number   default hr_api.g_number
  ,p_effective_date                in     date     default hr_api.g_date
  ,p_effective_start_date          in     date     default hr_api.g_date
  ,p_effective_end_date            in     date     default hr_api.g_date
  ,p_element_name                  in     varchar2 default hr_api.g_varchar2
  ,p_element_type_id               in     number   default hr_api.g_number
  ,p_entry_type                    in     varchar2 default hr_api.g_varchar2
  ,p_reason                        in     varchar2 default hr_api.g_varchar2
  ,p_segment1                      in     varchar2 default hr_api.g_varchar2
  ,p_segment2                      in     varchar2 default hr_api.g_varchar2
  ,p_segment3                      in     varchar2 default hr_api.g_varchar2
  ,p_segment4                      in     varchar2 default hr_api.g_varchar2
  ,p_segment5                      in     varchar2 default hr_api.g_varchar2
  ,p_segment6                      in     varchar2 default hr_api.g_varchar2
  ,p_segment7                      in     varchar2 default hr_api.g_varchar2
  ,p_segment8                      in     varchar2 default hr_api.g_varchar2
  ,p_segment9                      in     varchar2 default hr_api.g_varchar2
  ,p_segment10                     in     varchar2 default hr_api.g_varchar2
  ,p_segment11                     in     varchar2 default hr_api.g_varchar2
  ,p_segment12                     in     varchar2 default hr_api.g_varchar2
  ,p_segment13                     in     varchar2 default hr_api.g_varchar2
  ,p_segment14                     in     varchar2 default hr_api.g_varchar2
  ,p_segment15                     in     varchar2 default hr_api.g_varchar2
  ,p_segment16                     in     varchar2 default hr_api.g_varchar2
  ,p_segment17                     in     varchar2 default hr_api.g_varchar2
  ,p_segment18                     in     varchar2 default hr_api.g_varchar2
  ,p_segment19                     in     varchar2 default hr_api.g_varchar2
  ,p_segment20                     in     varchar2 default hr_api.g_varchar2
  ,p_segment21                     in     varchar2 default hr_api.g_varchar2
  ,p_segment22                     in     varchar2 default hr_api.g_varchar2
  ,p_segment23                     in     varchar2 default hr_api.g_varchar2
  ,p_segment24                     in     varchar2 default hr_api.g_varchar2
  ,p_segment25                     in     varchar2 default hr_api.g_varchar2
  ,p_segment26                     in     varchar2 default hr_api.g_varchar2
  ,p_segment27                     in     varchar2 default hr_api.g_varchar2
  ,p_segment28                     in     varchar2 default hr_api.g_varchar2
  ,p_segment29                     in     varchar2 default hr_api.g_varchar2
  ,p_segment30                     in     varchar2 default hr_api.g_varchar2
  ,p_value_1                       in     varchar2 default hr_api.g_varchar2
  ,p_value_2                       in     varchar2 default hr_api.g_varchar2
  ,p_value_3                       in     varchar2 default hr_api.g_varchar2
  ,p_value_4                       in     varchar2 default hr_api.g_varchar2
  ,p_value_5                       in     varchar2 default hr_api.g_varchar2
  ,p_value_6                       in     varchar2 default hr_api.g_varchar2
  ,p_value_7                       in     varchar2 default hr_api.g_varchar2
  ,p_value_8                       in     varchar2 default hr_api.g_varchar2
  ,p_value_9                       in     varchar2 default hr_api.g_varchar2
  ,p_value_10                      in     varchar2 default hr_api.g_varchar2
  ,p_value_11                      in     varchar2 default hr_api.g_varchar2
  ,p_value_12                      in     varchar2 default hr_api.g_varchar2
  ,p_value_13                      in     varchar2 default hr_api.g_varchar2
  ,p_value_14                      in     varchar2 default hr_api.g_varchar2
  ,p_value_15                      in     varchar2 default hr_api.g_varchar2
  ,p_canonical_date_format         in     varchar2 default 'Y'
  ,p_iv_all_internal_format        in     varchar2 default 'N'
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------------< update_batch_total >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates the batch control total information.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * Batch Header.
 *
 * <p><b>Post Success</b><br>
 * The batch control total will be successfully updated into the database.
 *
 * <p><b>Post Failure</b><br>
 * The API does not update the batch control total and raises an error.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_session_date Applications effective date.
 * @param p_batch_control_id Primary Key of the record.
 * @param p_object_version_number Pass in the current version number of the
 * batch control total to be updated. When the API completes if p_validate is
 * false, will be set to the new version number of the updated batch control
 * total. If p_validate is true will be set to the same value which was passed
 * in.
 * @param p_control_status Status of the batch control total.(BATCH_STATUS
 * lookup type of HR_LOOKUPS)
 * @param p_control_total Control total value.
 * @param p_control_type Type of rows to be summed. (Lookup type of
 * 'CONTROL_TYPE' within HR_LOOKUPS)
 * @rep:displayname Update Batch Total
 * @rep:category BUSINESS_ENTITY PAY_BATCH_ELEMENT_ENTRY
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_batch_total
  (p_validate                      in     boolean  default false
  ,p_session_date                  in     date
  ,p_batch_control_id              in     number
  ,p_object_version_number         in out nocopy number
  ,p_control_status                in     varchar2 default hr_api.g_varchar2
  ,p_control_total                 in     varchar2 default hr_api.g_varchar2
  ,p_control_type                  in     varchar2 default hr_api.g_varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_batch_header >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes the batch header.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The batch should exists.
 *
 * <p><b>Post Success</b><br>
 * The batch header will be successfully deleted from the database.
 *
 * <p><b>Post Failure</b><br>
 * The API does not delete the batch header and raises an error.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_batch_id Primary Key of the record.
 * @param p_object_version_number Pass in the current version number of the
 * batch header to be deleted. When the API completes if p_validate is false,
 * will be set to the new version number of the deleted batch header. If
 * p_validate is true will be set to the same value which was passed in.
 * @rep:displayname Delete Batch Header
 * @rep:category BUSINESS_ENTITY PAY_BATCH_ELEMENT_ENTRY
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_batch_header
  (p_validate                      in     boolean  default false
  ,p_batch_id                      in     number
  ,p_object_version_number         in     number
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------------< delete_batch_line >-------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes the batch line.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * A Batch Header.
 *
 * <p><b>Post Success</b><br>
 * The batch line will be successfully deleted from the database.
 *
 * <p><b>Post Failure</b><br>
 * The API does not delete the batch line and raises an error.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_batch_line_id Primary Key of the record.
 * @param p_object_version_number Pass in the current version number of the
 * batch line to be deleted. When the API completes if p_validate is false,
 * will be set to the new version number of the deleted batch line. If
 * p_validate is true will be set to the same value which was passed in.
 * @rep:displayname Delete Batch Line
 * @rep:category BUSINESS_ENTITY PAY_BATCH_ELEMENT_ENTRY
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_batch_line
  (p_validate                      in     boolean  default false
  ,p_batch_line_id                 in     number
  ,p_object_version_number         in     number
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------------< delete_batch_total >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes the batch control total.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * Batch Header.
 *
 * <p><b>Post Success</b><br>
 * The batch control total will be successfully deleted from the database.
 *
 * <p><b>Post Failure</b><br>
 * The API does not delete the batch control total and raises an error.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_batch_control_id Primary Key of the record.
 * @param p_object_version_number Pass in the current version number of the
 * batch control total to be deleted. When the API completes if p_validate is
 * false, will be set to the new version number of the deleted batch control
 * total. If p_validate is true will be set to the same value which was passed
 * in.
 * @rep:displayname Delete Batch Total
 * @rep:category BUSINESS_ENTITY PAY_BATCH_ELEMENT_ENTRY
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_batch_total
  (p_validate                      in     boolean  default false
  ,p_batch_control_id              in     number
  ,p_object_version_number         in     number
  );
--
end PAY_BATCH_ELEMENT_ENTRY_API;

 

/
