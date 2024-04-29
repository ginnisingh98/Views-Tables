--------------------------------------------------------
--  DDL for Package HR_BE_CONTRACT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_BE_CONTRACT_API" AUTHID CURRENT_USER as
/* $Header: hrctcbei.pkh 120.1 2005/10/02 02:01:43 aroussel $ */
/*#
 * This package contains contract APIs for Belgium.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Employment Contract for Belgium
*/
--
-- ----------------------------------------------------------------------------
-- |----------------------------< create_be_contract >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a new Belgian contract for the person.
 *
 * See the create_contract API for further documentation as this API is
 * essentially an alternative.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * Person record must exists in the same Business Group as that of the contract
 * being created.
 *
 * <p><b>Post Success</b><br>
 * The contract is successfully inserted into the database.
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
 * @param p_contract_category The contract category. Valid values exist in the
 * 'BE_CONTRACT_CATEGORY' lookup type.
 * @param p_first_date_worked The date first worked
 * @param p_last_date_worked The last date worked
 * @param p_payment_start_date The payment start date
 * @param p_payment_end_date The payment end date
 * @param p_notice_period The notice period
 * @param p_notice_period_units The units of the notice period. Valid values
 * exist in the 'BE_NOTICE_PERIOD_UNITS' lookup type.
 * @param p_replacing_employee The employee being replaced by this contract
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
 * @rep:displayname Create Employment Contract for Belgium
 * @rep:category BUSINESS_ENTITY PER_EMPLOYMENT_CONTRACT
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_be_contract
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
,p_contract_category	          in  varchar2  default null
,p_first_date_worked              in  varchar2  default null
,p_last_date_worked               in  varchar2  default null
,p_payment_start_date		  in  varchar2  default null
,p_payment_end_date               in  varchar2  default null
,p_notice_period                  in  varchar2  default null
,p_notice_period_units            in  varchar2  default null
,p_replacing_employee             in  varchar2  default null
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
,p_effective_date                 in  date);
--
-- ----------------------------------------------------------------------------
-- |----------------------------< update_be_contract >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates an existing Belgian contract for the person.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The contract must exist.
 *
 * <p><b>Post Success</b><br>
 * The contract is successfully updated in the database.
 *
 * <p><b>Post Failure</b><br>
 * The API does not update the contract and raises an error.
 * @param p_validate hr_contract_api.update_contract
 * @param p_contract_id hr_contract_api.update_contract
 * @param p_effective_start_date hr_contract_api.update_contract
 * @param p_effective_end_date hr_contract_api.update_contract
 * @param p_object_version_number hr_contract_api.update_contract
 * @param p_person_id hr_contract_api.update_contract
 * @param p_reference hr_contract_api.update_contract
 * @param p_type hr_contract_api.update_contract
 * @param p_status hr_contract_api.update_contract
 * @param p_status_reason hr_contract_api.update_contract
 * @param p_description hr_contract_api.update_contract
 * @param p_duration hr_contract_api.update_contract
 * @param p_duration_units hr_contract_api.update_contract
 * @param p_contractual_job_title hr_contract_api.update_contract
 * @param p_parties hr_contract_api.update_contract
 * @param p_start_reason hr_contract_api.update_contract
 * @param p_end_reason hr_contract_api.update_contract
 * @param p_number_of_extensions hr_contract_api.update_contract
 * @param p_extension_reason hr_contract_api.update_contract
 * @param p_extension_period hr_contract_api.update_contract
 * @param p_extension_period_units hr_contract_api.update_contract
 * @param p_contract_category The contract category. Valid values exist in the
 * 'BE_CONTRACT_CATEGORY' lookup type.
 * @param p_first_date_worked The date first worked
 * @param p_last_date_worked The last date worked
 * @param p_payment_start_date The payment start date
 * @param p_payment_end_date The payment end date
 * @param p_notice_period The notice period
 * @param p_notice_period_units The units of the notice period. Valid values
 * exist in the 'BE_NOTICE_PERIOD_UNITS' lookup type.
 * @param p_replacing_employee The employee being replaced by this contract
 * @param p_attribute_category hr_contract_api.update_contract
 * @param p_attribute1 hr_contract_api.update_contract
 * @param p_attribute2 hr_contract_api.update_contract
 * @param p_attribute3 hr_contract_api.update_contract
 * @param p_attribute4 hr_contract_api.update_contract
 * @param p_attribute5 hr_contract_api.update_contract
 * @param p_attribute6 hr_contract_api.update_contract
 * @param p_attribute7 hr_contract_api.update_contract
 * @param p_attribute8 hr_contract_api.update_contract
 * @param p_attribute9 hr_contract_api.update_contract
 * @param p_attribute10 hr_contract_api.update_contract
 * @param p_attribute11 hr_contract_api.update_contract
 * @param p_attribute12 hr_contract_api.update_contract
 * @param p_attribute13 hr_contract_api.update_contract
 * @param p_attribute14 hr_contract_api.update_contract
 * @param p_attribute15 hr_contract_api.update_contract
 * @param p_attribute16 hr_contract_api.update_contract
 * @param p_attribute17 hr_contract_api.update_contract
 * @param p_attribute18 hr_contract_api.update_contract
 * @param p_attribute19 hr_contract_api.update_contract
 * @param p_attribute20 hr_contract_api.update_contract
 * @param p_effective_date hr_contract_api.update_contract
 * @param p_datetrack_mode hr_contract_api.update_contract
 * @rep:displayname Update Employment Contract for Belgium
 * @rep:category BUSINESS_ENTITY PER_EMPLOYMENT_CONTRACT
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_be_contract
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
,p_contract_category	          in  varchar2  default hr_api.g_varchar2
,p_first_date_worked              in  varchar2  default hr_api.g_varchar2
,p_last_date_worked               in  varchar2  default hr_api.g_varchar2
,p_payment_start_date		  in  varchar2  default hr_api.g_varchar2
,p_payment_end_date               in  varchar2  default hr_api.g_varchar2
,p_notice_period                  in  varchar2  default hr_api.g_varchar2
,p_notice_period_units            in  varchar2  default hr_api.g_varchar2
,p_replacing_employee             in  varchar2  default hr_api.g_varchar2
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
,p_datetrack_mode                 in  varchar2);
--
end hr_be_contract_api;

 

/
