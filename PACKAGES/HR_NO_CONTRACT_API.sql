--------------------------------------------------------
--  DDL for Package HR_NO_CONTRACT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_NO_CONTRACT_API" AUTHID CURRENT_USER as
/* $Header: pectcnoi.pkh 120.1 2005/10/02 02:39:58 aroussel $ */
/*#
 * This package contains contract APIs for Norway.
 * @rep:scope public
 * @rep:product PER
 * @rep:displayname Contract for Norway
*/
--
-- ----------------------------------------------------------------------------
-- |----------------------------< create_no_contract >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a new Norwegian contract.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The person record must exist in the same business group as that of the
 * contract being created.
 *
 * <p><b>Post Success</b><br>
 * The API creates a new contract.
 *
 * <p><b>Post Failure</b><br>
 * The API does not create the contract and raises an error.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_contract_id Identifies the contract record.
 * @param p_effective_start_date If p_validate is false, then set to the
 * earliest effective start date for the created contract. If p_validate is
 * true, then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date for the created contract. If p_validate is true, then set
 * to null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created contract. If p_validate is true, then the
 * value will be null.
 * @param p_person_id If p_validate is false, then this uniquely identifies the
 * person created. If p_validate is true, then set to null.
 * @param p_reference Reference code for the contract.
 * @param p_type Contract type.
 * @param p_status Contract status.
 * @param p_status_reason Contract status reason.
 * @param p_doc_status Contract user status.
 * @param p_doc_status_change_date Date the user status changed.
 * @param p_description Contract description.
 * @param p_duration Contract duration.
 * @param p_duration_units Units for contract duration.
 * @param p_contractual_job_title Contractual job title.
 * @param p_parties Parties to the contract.
 * @param p_start_reason Reason for starting the contract.
 * @param p_end_reason Reason for ending the contract.
 * @param p_number_of_extensions Number of contract extensions.
 * @param p_extension_reason Reason for extending the contract.
 * @param p_extension_period Extension period.
 * @param p_extension_period_units Units for extension period.
 * @param p_contract_end_date Contract end date - Descriptive Flexfield.
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
 * @rep:displayname Create Contract for Norway
 * @rep:category BUSINESS_ENTITY PER_EMPLOYMENT_CONTRACT
 * @rep:lifecycle active
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_no_contract
 (p_validate                        in boolean    default false
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
  ,p_contract_end_date		in  date  default null
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
-- |----------------------------< update_no_contract >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates an existing Norwegian contract.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The contract must exist.
 *
 * <p><b>Post Success</b><br>
 * The API successfully updates the contract.
 *
 * <p><b>Post Failure</b><br>
 * The API does not update the contract and raises an error.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_contract_id Identifies the contract record.
 * @param p_effective_start_date If p_validate is false, then set to the
 * effective start date on the updated contract row which now exists as of the
 * effective date. If p_validate is true, then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date on the updated contract row which now exists as of the
 * effective date. If p_validate is true, then set to null.
 * @param p_object_version_number Pass in the current version number of the
 * contract to be updated. When the API completes if p_validate is false, will
 * be set to the new version number of the updated contract. If p_validate is
 * true will be set to the same value which was passed in.
 * @param p_person_id Identifies the person record to modify.
 * @param p_reference Reference code for the contract.
 * @param p_type Contract type.
 * @param p_status Contract status.
 * @param p_status_reason Contract status reason.
 * @param p_doc_status Contract user reason.
 * @param p_doc_status_change_date Date the user status changed.
 * @param p_description Contract description.
 * @param p_duration Contract duration.
 * @param p_duration_units Units for contract duration.
 * @param p_contractual_job_title Contractual job title.
 * @param p_parties Parties to the contract.
 * @param p_start_reason Reason for starting the contract.
 * @param p_end_reason Reason for ending the contract.
 * @param p_number_of_extensions Number of contract extensions.
 * @param p_extension_reason Reason for extending the contract.
 * @param p_extension_period Extension period.
 * @param p_extension_period_units Units for extension period.
 * @param p_contract_end_date Contract end date - Descriptive Flexfield.
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
 * the record. You must set to either UPDATE, CORRECTION, UPDATE_OVERRIDE or
 * UPDATE_CHANGE_INSERT. Modes available for use with a particular record
 * depend on the dates of previous record changes and the effective date of
 * this change.
 * @rep:displayname Update Contract for Norway
 * @rep:category BUSINESS_ENTITY PER_EMPLOYMENT_CONTRACT
 * @rep:lifecycle active
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_no_contract
  (p_validate                       in boolean    default false
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
  ,p_contract_end_date              in  date  default hr_api.g_date
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
end hr_no_contract_api;

 

/
