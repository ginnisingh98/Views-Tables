--------------------------------------------------------
--  DDL for Package HR_CONTRACT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_CONTRACT_API" AUTHID CURRENT_USER as
/* $Header: hrctcapi.pkh 120.1 2005/10/02 02:01:33 aroussel $ */
/*#
 * This package contains APIs that maintain contract information for an
 * employee.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Employment Contract
*/
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< create_contract >--------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a new contract for an employee.
 *
 * Use this API to create contract information details for an employee. The
 * contract record stores date information, such as expiration. You can also
 * track the status of physical documents produced as a result of signing the
 * contract. There is no restriction on the number of contracts a person can
 * have at a given time.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * An employee record must exist. Lookup values must be created for the lookup
 * types of CONTRACT_STATUS and CONTRACT_TYPE.
 *
 * <p><b>Post Success</b><br>
 * A contract will have been created for the employee
 *
 * <p><b>Post Failure</b><br>
 * The contract will not be created and an error will be raised.
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
 * @param p_ctr_information_category This context value determines which
 * flexfield structure to use with the Developer Descriptive Flexfield
 * segments.
 * @param p_ctr_information1 Developer descriptive flexfield segment.
 * @param p_ctr_information2 Developer descriptive flexfield segment.
 * @param p_ctr_information3 Developer descriptive flexfield segment.
 * @param p_ctr_information4 Developer descriptive flexfield segment.
 * @param p_ctr_information5 Developer descriptive flexfield segment.
 * @param p_ctr_information6 Developer descriptive flexfield segment.
 * @param p_ctr_information7 Developer descriptive flexfield segment.
 * @param p_ctr_information8 Developer descriptive flexfield segment.
 * @param p_ctr_information9 Developer descriptive flexfield segment.
 * @param p_ctr_information10 Developer descriptive flexfield segment.
 * @param p_ctr_information11 Developer descriptive flexfield segment.
 * @param p_ctr_information12 Developer descriptive flexfield segment.
 * @param p_ctr_information13 Developer descriptive flexfield segment.
 * @param p_ctr_information14 Developer descriptive flexfield segment.
 * @param p_ctr_information15 Developer descriptive flexfield segment.
 * @param p_ctr_information16 Developer descriptive flexfield segment.
 * @param p_ctr_information17 Developer descriptive flexfield segment.
 * @param p_ctr_information18 Developer descriptive flexfield segment.
 * @param p_ctr_information19 Developer descriptive flexfield segment.
 * @param p_ctr_information20 Developer descriptive flexfield segment.
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
 * @rep:displayname Create Employment Contract
 * @rep:category BUSINESS_ENTITY PER_EMPLOYMENT_CONTRACT
 * @rep:category MISC_EXTENSIONS HR_DATAPUMP
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_contract
(
   p_validate                       in boolean    default false
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
  ,p_ctr_information_category       in  varchar2  default null
  ,p_ctr_information1               in  varchar2  default null
  ,p_ctr_information2               in  varchar2  default null
  ,p_ctr_information3               in  varchar2  default null
  ,p_ctr_information4               in  varchar2  default null
  ,p_ctr_information5               in  varchar2  default null
  ,p_ctr_information6               in  varchar2  default null
  ,p_ctr_information7               in  varchar2  default null
  ,p_ctr_information8               in  varchar2  default null
  ,p_ctr_information9               in  varchar2  default null
  ,p_ctr_information10              in  varchar2  default null
  ,p_ctr_information11              in  varchar2  default null
  ,p_ctr_information12              in  varchar2  default null
  ,p_ctr_information13              in  varchar2  default null
  ,p_ctr_information14              in  varchar2  default null
  ,p_ctr_information15              in  varchar2  default null
  ,p_ctr_information16              in  varchar2  default null
  ,p_ctr_information17              in  varchar2  default null
  ,p_ctr_information18              in  varchar2  default null
  ,p_ctr_information19              in  varchar2  default null
  ,p_ctr_information20              in  varchar2  default null
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
-- |-----------------------------< update_contract >--------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates an existing contract for an employee.
 *
 * Use this API to update contract information details for an employee. The
 * contract record stores date information, such as expiration. You can also
 * track the status of physical documents produced as a result of signing the
 * contract. This is no restriction on how many contracts a person can have at
 * a given time.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * A contract must have been created for the employee.
 *
 * <p><b>Post Success</b><br>
 * The contract will have been updated for the employee
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
 * @param p_ctr_information_category This context value determines which
 * Flexfield Structure to use with the Developer Descriptive flexfield
 * segments.
 * @param p_ctr_information1 Developer descriptive flexfield segment.
 * @param p_ctr_information2 Developer descriptive flexfield segment.
 * @param p_ctr_information3 Developer descriptive flexfield segment.
 * @param p_ctr_information4 Developer descriptive flexfield segment.
 * @param p_ctr_information5 Developer descriptive flexfield segment.
 * @param p_ctr_information6 Developer descriptive flexfield segment.
 * @param p_ctr_information7 Developer descriptive flexfield segment.
 * @param p_ctr_information8 Developer descriptive flexfield segment.
 * @param p_ctr_information9 Developer descriptive flexfield segment.
 * @param p_ctr_information10 Developer descriptive flexfield segment.
 * @param p_ctr_information11 Developer descriptive flexfield segment.
 * @param p_ctr_information12 Developer descriptive flexfield segment.
 * @param p_ctr_information13 Developer descriptive flexfield segment.
 * @param p_ctr_information14 Developer descriptive flexfield segment.
 * @param p_ctr_information15 Developer descriptive flexfield segment.
 * @param p_ctr_information16 Developer descriptive flexfield segment.
 * @param p_ctr_information17 Developer descriptive flexfield segment.
 * @param p_ctr_information18 Developer descriptive flexfield segment.
 * @param p_ctr_information19 Developer descriptive flexfield segment.
 * @param p_ctr_information20 Developer descriptive flexfield segment.
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
 * @rep:displayname Update Employment Contract
 * @rep:category BUSINESS_ENTITY PER_EMPLOYMENT_CONTRACT
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_contract
  (
   p_validate                       in boolean    default false
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
  ,p_ctr_information_category       in  varchar2  default hr_api.g_varchar2
  ,p_ctr_information1               in  varchar2  default hr_api.g_varchar2
  ,p_ctr_information2               in  varchar2  default hr_api.g_varchar2
  ,p_ctr_information3               in  varchar2  default hr_api.g_varchar2
  ,p_ctr_information4               in  varchar2  default hr_api.g_varchar2
  ,p_ctr_information5               in  varchar2  default hr_api.g_varchar2
  ,p_ctr_information6               in  varchar2  default hr_api.g_varchar2
  ,p_ctr_information7               in  varchar2  default hr_api.g_varchar2
  ,p_ctr_information8               in  varchar2  default hr_api.g_varchar2
  ,p_ctr_information9               in  varchar2  default hr_api.g_varchar2
  ,p_ctr_information10              in  varchar2  default hr_api.g_varchar2
  ,p_ctr_information11              in  varchar2  default hr_api.g_varchar2
  ,p_ctr_information12              in  varchar2  default hr_api.g_varchar2
  ,p_ctr_information13              in  varchar2  default hr_api.g_varchar2
  ,p_ctr_information14              in  varchar2  default hr_api.g_varchar2
  ,p_ctr_information15              in  varchar2  default hr_api.g_varchar2
  ,p_ctr_information16              in  varchar2  default hr_api.g_varchar2
  ,p_ctr_information17              in  varchar2  default hr_api.g_varchar2
  ,p_ctr_information18              in  varchar2  default hr_api.g_varchar2
  ,p_ctr_information19              in  varchar2  default hr_api.g_varchar2
  ,p_ctr_information20              in  varchar2  default hr_api.g_varchar2
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
-- ----------------------------------------------------------------------------
-- |-----------------------------< delete_contract >--------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes employee's contract information.
 *
 * Use this API to delete contract information for an employee. The contract
 * record stores date information, such as expiration. You can also track the
 * status of physical documents produced as a result of signing the contract.
 * There is no restriction on the number of contracts a person can have at a
 * given time.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * A contract must have been created for the employee.
 *
 * <p><b>Post Success</b><br>
 * Depending on the DateTrack mode used, some of all of the contract
 * information for the employee will be deleted.
 *
 * <p><b>Post Failure</b><br>
 * The API does not delete the contract and raises an error.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_contract_id Identifies the contract record to be deleted
 * @param p_effective_start_date If p_validate is false, then set to the
 * effective start date for the deleted contract row which now exists as of the
 * effective date. If p_validate is true or all row instances have been deleted
 * then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date for the deleted contract row which now exists as of the
 * effective date. If p_validate is true or all row instances have been deleted
 * then set to null.
 * @param p_object_version_number Current version number of the contract to be
 * deleted
 * @param p_effective_date Determines when the DateTrack operation comes into
 * force
 * @param p_datetrack_mode Indicates which DateTrack mode to use when deleting
 * the record. You must set to either ZAP, DELETE, FUTURE_CHANGE or
 * DELETE_NEXT_CHANGE. Modes available for use with a particular record depend
 * on the dates of previous record changes and the effective date of this
 * change.
 * @rep:displayname Delete Employment Contract
 * @rep:category BUSINESS_ENTITY PER_EMPLOYMENT_CONTRACT
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_contract
  (
   p_validate                       in boolean        default false
  ,p_contract_id                    in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in date
  ,p_datetrack_mode                 in varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------------------< lck >---------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_contract_id                 Yes  number   PK of record
--   p_object_version_number        Yes  number   OVN of record
--   p_effective_date               Yes  date     Session Date.
--   p_datetrack_mode               Yes  varchar2 Datetrack mode.
--
-- Post Success:
--
--   Name                           Type     Description
--   p_validation_start_date        Yes      Derived Effective Start Date.
--   p_validation_end_date          Yes      Derived Effective End Date.
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure lck
  (
    p_contract_id                 in number
   ,p_object_version_number        in number
   ,p_effective_date              in date
   ,p_datetrack_mode              in varchar2
   ,p_validation_start_date        out nocopy date
   ,p_validation_end_date          out nocopy date
  );
--
procedure maintain_contracts
  (
  p_person_id      number,
  p_new_start_date date,
  p_old_start_date date
  );
--
function get_pps_start_date
  (p_person_id in number,
   p_active_date in date) return date;
-- pragma restrict_references(get_pps_start_date, WNPS, WNDS);
--
function get_pps_end_date
  (p_person_id in number,
   p_active_date in date) return date;
pragma restrict_references(get_pps_end_date, WNPS, WNDS);
--
function get_meaning
  (p_lookup_code in varchar2,
   p_lookup_type in varchar2) return varchar2;
-- pragma restrict_references(get_meaning, WNPS, WNDS);
--
function get_active_start_date
  (p_contract_id in number,
   p_effective_date in date,
   p_status in varchar2) return date;
pragma restrict_references(get_active_start_date, WNPS, WNDS);
--
function get_active_end_date
  (p_contract_id in number,
   p_effective_date in date,
   p_status in varchar2) return date;
pragma restrict_references(get_active_end_date, WNPS, WNDS);
--
end hr_contract_api;

 

/
