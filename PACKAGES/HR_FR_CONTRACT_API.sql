--------------------------------------------------------
--  DDL for Package HR_FR_CONTRACT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_FR_CONTRACT_API" AUTHID CURRENT_USER as
/* $Header: hrctcfri.pkh 120.3 2006/07/06 06:23:27 nmuthusa noship $ */
/*#
 * This package contains contract APIs for France.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Employment Contract for France
*/
--
-- ----------------------------------------------------------------------------
-- |----------------------------< create_fr_contract >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a new contract for the person record for France.
 *
 * This API is an alternative API to the create_contract generic API. See
 * create_contract API for further details.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * Person record must exist in the same Business Group as that of the contract
 * being created. Lookup values have been created for user extensible lookup
 * types of CONTRACT_STATUS and CONTRACT_TYPE.
 *
 * <p><b>Post Success</b><br>
 * The contract is successfully created for the person record in France.
 *
 * <p><b>Post Failure</b><br>
 * The API does not create the contract and raises an error.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_contract_id If p_validate is false then this uniquely identifies
 * the contract created. If p_validate is true, then the the value will be
 * null.
 * @param p_effective_start_date If p_validate is false, then set to the
 * earliest effective start date for the created contract. If p_validate is
 * true, then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date for the created contract. If p_validate is true, then set
 * to null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created contract. If p_validate is true, then set to
 * null.
 * @param p_person_id Identifies the person for whom you create the contract
 * record.
 * @param p_reference Reference code for the contract
 * @param p_type The type of the contract. Valid values are defined by the
 * CONTRACT_TYPE lookup type.
 * @param p_status The status of the contract. Valid values are defined by the
 * CONTRACT_STATUS lookup type.
 * @param p_status_reason The reason why the contract has its current status.
 * Valid values are defined by the CONTRACT_STATUS_REASON lookup type.
 * @param p_doc_status The status of the physical document associated with the
 * contract. Valid values are defined by the DOCUMENT_STATUS lookup type.
 * @param p_doc_status_change_date Date the document status changed.
 * @param p_description Contract description
 * @param p_duration The length of time during which the contract is active.
 * @param p_duration_units Units for contract duration, e.g., Weeks, Months,
 * Years. Valid values are defined by the QUALIFYING_UNITS lookup type.
 * @param p_contractual_job_title Contractual job title
 * @param p_parties Parties to the contract
 * @param p_start_reason Reason for starting the contract. Valid values are
 * defined by the CONTRACT_START_REASON lookup type.
 * @param p_end_reason Reason for ending the contract. Valid values are defined
 * by the CONTRACT_END_REASON lookup type.
 * @param p_number_of_extensions How many times the contract has been extended.
 * @param p_extension_reason Reason for extending the contract
 * @param p_extension_period How long the contract has been extended.
 * @param p_extension_period_units Units for extension period, e.g., Weeks,
 * Months, Years. Valid values are defined by the QUALIFYING_UNITS lookup type.
 * @param p_employee_type Employee type. Valid values exist in the
 * 'FR_LEVEL_OF_WORKER' lookup type.
 * @param p_contract_category Contract Category. Valid values exist in the
 * 'FR_CONTRACT_CATEGORY' lookup type.
 * @param p_proposed_end_date Proposed end date
 * @param p_end_event End Event
 * @param p_person_replaced Person replaced
 * @param p_probation_period Probation period
 * @param p_probation_period_units Probation period units. Valid values exist
 * in the 'QUALIFYING_UNITS' lookup type.
 * @param p_probation_end_date Probation end date
 * @param p_smic_adjusted_duration_days SMIC adjusted duration days
 * @param p_fixed_working_time Fixed working time indicator. Valid values exist
 * in the 'YES_NO' lookup type.
 * @param p_amount The length of fixed working time.
 * @param p_units Units for fixed working time, e.g., Hours,Days. Valid values
 * exist in the 'FR_FIXED_TIME_UNITS' lookup type.
 * @param p_frequency Frequency for fixed working time, e.g., Weeks,Months,Years.
 * Valid values exist in the 'FR_FIXED_TIME_FREQUENCY' lookup type.
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
 * @param p_effective_date Determines when the DateTrack operation comes into
 * force.
 * @rep:displayname Create Employment Contract for France
 * @rep:category BUSINESS_ENTITY PER_EMPLOYMENT_CONTRACT
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_fr_contract
  (p_validate                       in  boolean   default false
  ,p_contract_id                    out nocopy number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_object_version_number          out nocopy number
  ,p_person_id                      in  number
  ,p_reference                      in  varchar2
  ,p_type                           in  varchar2
  ,p_status                         in  varchar2
  ,p_status_reason                  in  varchar2  default null
  ,p_doc_status                     in  varchar2  default null
  ,p_doc_status_change_date         in  date      default null
  ,p_description                    in  varchar2  default null
  ,p_duration                       in  number    default null
  ,p_duration_units                 in  varchar2  default null
  ,p_contractual_job_title          in  varchar2  default null
  ,p_parties                        in  varchar2  default null
  ,p_start_reason                   in  varchar2  default null
  ,p_end_reason                     in  varchar2  default null
  ,p_number_of_extensions           in  number    default null
  ,p_extension_reason               in  varchar2  default null
  ,p_extension_period               in  number    default null
  ,p_extension_period_units         in  varchar2  default null
  ,p_employee_type	            in  varchar2  default null
  ,p_contract_category              in  varchar2  default null
  ,p_proposed_end_date              in  varchar2  default null
  ,p_end_event		            in  varchar2  default null
  ,p_person_replaced                in  varchar2  default null
  ,p_probation_period               in  varchar2  default null
  ,p_probation_period_units         in  varchar2  default null
  ,p_probation_end_date             in  varchar2  default null
  ,p_smic_adjusted_duration_days    in  number    default null
  ,p_fixed_working_time		    in  varchar2  default null
  ,p_amount			    in	number    default null
  ,p_units			    in  varchar2  default null
  ,p_frequency			    in  varchar2  default null
  ,p_attribute_category             in  varchar2  default null
  ,p_attribute1                     in  varchar2  default null
  ,p_attribute2                     in  varchar2  default null
  ,p_attribute3                     in  varchar2  default null
  ,p_attribute4                     in  varchar2  default null
  ,p_attribute5                     in  varchar2  default null
  ,p_attribute6                     in  varchar2  default null
  ,p_attribute7                     in  varchar2  default null
  ,p_attribute8                     in  varchar2  default null
  ,p_attribute9                     in  varchar2  default null
  ,p_attribute10                    in  varchar2  default null
  ,p_attribute11                    in  varchar2  default null
  ,p_attribute12                    in  varchar2  default null
  ,p_attribute13                    in  varchar2  default null
  ,p_attribute14                    in  varchar2  default null
  ,p_attribute15                    in  varchar2  default null
  ,p_attribute16                    in  varchar2  default null
  ,p_attribute17                    in  varchar2  default null
  ,p_attribute18                    in  varchar2  default null
  ,p_attribute19                    in  varchar2  default null
  ,p_attribute20                    in  varchar2  default null
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------------< update_fr_contract >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates a contract for a person in a business group for France.
 *
 * This API calls the generic API update_contract. See update_contract for
 * further details.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * Contract must exist.
 *
 * <p><b>Post Success</b><br>
 * The contract is successfully updated for the person.
 *
 * <p><b>Post Failure</b><br>
 * The API does not update the contract and raises an error.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_contract_id Identifies the contract record to be modified.
 * @param p_effective_start_date If p_validate is false, then set to the
 * effective start date in the updated contract row as of the effective date.
 * If p_validate is true, then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date in the updated contract row as of the effective date. If
 * p_validate is true, then set to null.
 * @param p_object_version_number Passes the current version number of the
 * contract to be updated. If p_validate is false on completion, set to the new
 * version number of the updated contract. If p_validate is true set to the
 * input value.
 * @param p_person_id Identifies the employee for whom the contract was created
 * @param p_reference Reference code for the contract
 * @param p_type The type of the contract. Valid values are defined by the
 * CONTRACT_TYPE lookup type.
 * @param p_status The status of the contract. Valid values are defined by the
 * CONTRACT_STATUS lookup type.
 * @param p_status_reason The reason why the contract has its current status.
 * Valid values are defined by the CONTRACT_STATUS_REASON lookup type.
 * @param p_doc_status The status of the physical document associated with the
 * contract. Valid values are defined by the DOCUMENT_STATUS lookup type.
 * @param p_doc_status_change_date Date the document status changed.
 * @param p_description Contract description
 * @param p_duration The length of time during which the contract is active.
 * @param p_duration_units Units for contract duration, e.g., Weeks, Months,
 * Years. Valid values are defined by the QUALIFYING_UNITS lookup type.
 * @param p_contractual_job_title Contractual job title
 * @param p_parties Parties to the contract
 * @param p_start_reason Reason for starting the contract. Valid values are
 * defined by the CONTRACT_START_REASON lookup type.
 * @param p_end_reason Reason for ending the contract. Valid values are defined
 * by the CONTRACT_END_REASON lookup type.
 * @param p_number_of_extensions How many times the contract has been extended.
 * @param p_extension_reason Reason for extending the contract
 * @param p_extension_period How long the contract has been extended.
 * @param p_extension_period_units Units for extension period, e.g., Weeks,
 * Months, Years. Valid values are defined by the QUALIFYING_UNITS lookup type.
 * @param p_employee_type Employee type. Valid values exist in the
 * 'FR_LEVEL_OF_WORKER' lookup type.
 * @param p_contract_category Contract category. Valid values exist in the
 * 'FR_CONTRACT_CATEGORY' lookup type.
 * @param p_proposed_end_date Proposed end date
 * @param p_end_event End Event
 * @param p_person_replaced Person replaced
 * @param p_probation_period Probation period
 * @param p_probation_period_units Probation period units. Valid values exist
 * in the 'QUALIFYING_UNITS' lookup type.
 * @param p_probation_end_date Probation end date
 * @param p_smic_adjusted_duration_days SMIC adjusted duration days
 * @param p_fixed_working_time Fixed working time indicator. Valid values exist
 * in the 'YES_NO' lookup type.
 * @param p_amount The length of fixed working time.
 * @param p_units Units for fixed working time, e.g., Hours,Days. Valid values
 * exist in the 'FR_FIXED_TIME_UNITS' lookup type.
 * @param p_frequency Frequency for fixed working time, e.g., Weeks,Months,Years.
 * Valid values exist in the 'FR_FIXED_TIME_FREQUENCY' lookup type.
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
 * @param p_effective_date Determines when the DateTrack operation comes into
 * force.
 * @param p_datetrack_mode Indicates which DateTrack mode to use when updating
 * the record. You must set to UPDATE, CORRECTION, UPDATE_OVERRIDE or
 * UPDATE_CHANGE_INSERT. Modes available for use with a particular record
 * depend on the dates of previous record changes and the effective date of
 * this change.
 * @rep:displayname Update Employment Contract for France
 * @rep:category BUSINESS_ENTITY PER_EMPLOYMENT_CONTRACT
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_fr_contract
  (p_validate                       in  boolean   default false
  ,p_contract_id                    in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_object_version_number          in out nocopy number
  ,p_person_id                      in  number
  ,p_reference                      in  varchar2
  ,p_type                           in  varchar2
  ,p_status                         in  varchar2
  ,p_status_reason                  in  varchar2  default hr_api.g_varchar2
  ,p_doc_status                     in  varchar2  default hr_api.g_varchar2
  ,p_doc_status_change_date         in  date      default hr_api.g_date
  ,p_description                    in  varchar2  default hr_api.g_varchar2
  ,p_duration                       in  number    default hr_api.g_number
  ,p_duration_units                 in  varchar2  default hr_api.g_varchar2
  ,p_contractual_job_title          in  varchar2  default hr_api.g_varchar2
  ,p_parties                        in  varchar2  default hr_api.g_varchar2
  ,p_start_reason                   in  varchar2  default hr_api.g_varchar2
  ,p_end_reason                     in  varchar2  default hr_api.g_varchar2
  ,p_number_of_extensions           in  number    default hr_api.g_number
  ,p_extension_reason               in  varchar2  default hr_api.g_varchar2
  ,p_extension_period               in  number    default hr_api.g_number
  ,p_extension_period_units         in  varchar2  default hr_api.g_varchar2
  ,p_employee_type	            in  varchar2  default hr_api.g_varchar2
  ,p_contract_category              in  varchar2  default hr_api.g_varchar2
  ,p_proposed_end_date              in  varchar2  default hr_api.g_varchar2
  ,p_end_event		            in  varchar2  default hr_api.g_varchar2
  ,p_person_replaced                in  varchar2  default hr_api.g_varchar2
  ,p_probation_period               in  varchar2  default hr_api.g_varchar2
  ,p_probation_period_units         in  varchar2  default hr_api.g_varchar2
  ,p_probation_end_date             in  varchar2  default hr_api.g_varchar2
  ,p_smic_adjusted_duration_days    in  number    default hr_api.g_number
  ,p_fixed_working_time		    in  varchar2  default hr_api.g_varchar2
  ,p_amount			    in	number    default hr_api.g_number
  ,p_units			    in  varchar2  default hr_api.g_varchar2
  ,p_frequency			    in  varchar2  default hr_api.g_varchar2
  ,p_attribute_category             in  varchar2  default hr_api.g_varchar2
  ,p_attribute1                     in  varchar2  default hr_api.g_varchar2
  ,p_attribute2                     in  varchar2  default hr_api.g_varchar2
  ,p_attribute3                     in  varchar2  default hr_api.g_varchar2
  ,p_attribute4                     in  varchar2  default hr_api.g_varchar2
  ,p_attribute5                     in  varchar2  default hr_api.g_varchar2
  ,p_attribute6                     in  varchar2  default hr_api.g_varchar2
  ,p_attribute7                     in  varchar2  default hr_api.g_varchar2
  ,p_attribute8                     in  varchar2  default hr_api.g_varchar2
  ,p_attribute9                     in  varchar2  default hr_api.g_varchar2
  ,p_attribute10                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute11                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute12                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute13                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute14                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute15                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute16                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute17                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute18                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute19                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute20                    in  varchar2  default hr_api.g_varchar2
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
--
end hr_fr_contract_api;

/
