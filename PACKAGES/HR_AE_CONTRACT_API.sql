--------------------------------------------------------
--  DDL for Package HR_AE_CONTRACT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_AE_CONTRACT_API" AUTHID CURRENT_USER AS
/* $Header: pectcaei.pkh 120.2 2006/09/27 13:23:33 spendhar noship $ */
/*#
 * This package contains contract APIs for UAE.
 * @rep:scope public
 * @rep:product PER
 * @rep:displayname Contract for UAE
*/
--
-- ----------------------------------------------------------------------------
-- |----------------------------< create_ae_contract >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a new UAE contract.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Oracle Human Resources.
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
 * database will remain unchanged. if false and all validation checks pass,
 * then the database will be modified.
 * @param p_contract_id Identifies the contract record.
 * @param p_effective_start_date If p_validate is false, then set to the
 * earliest effective start date for the created contract. if p_validate is
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
 * @param p_employment_status Employment status.
 * @param p_expiry_date Expiry date.
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
 * @rep:displayname Create Contract for UAE
 * @rep:category BUSINESS_ENTITY PER_EMPLOYMENT_CONTRACT
 * @rep:lifecycle active
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
PROCEDURE create_ae_contract
 (p_validate                        IN BOOLEAN    DEFAULT FALSE
  ,p_contract_id                    OUT NOCOPY NUMBER
  ,p_effective_start_date           OUT NOCOPY DATE
  ,p_effective_end_date             OUT NOCOPY DATE
  ,p_object_version_number          OUT NOCOPY NUMBER
  ,p_person_id                      IN  NUMBER
  ,p_reference                      IN  VARCHAR2
  ,p_type                           IN  VARCHAR2
  ,p_status                         IN  VARCHAR2
  ,p_status_reason                  IN  VARCHAR2  DEFAULT NULL
  ,p_doc_status                     IN  VARCHAR2  DEFAULT NULL
  ,p_doc_status_change_date         IN  DATE      DEFAULT NULL
  ,p_description                    IN  VARCHAR2  DEFAULT NULL
  ,p_duration                       IN  NUMBER    DEFAULT NULL
  ,p_duration_units                 IN  VARCHAR2  DEFAULT NULL
  ,p_contractual_job_title          IN  VARCHAR2  DEFAULT NULL
  ,p_parties                        IN  VARCHAR2  DEFAULT NULL
  ,p_start_reason                   IN  VARCHAR2  DEFAULT NULL
  ,p_end_reason                     IN  VARCHAR2  DEFAULT NULL
  ,p_number_of_extensions           IN  NUMBER    DEFAULT NULL
  ,p_extension_reason               IN  VARCHAR2  DEFAULT NULL
  ,p_extension_period               IN  NUMBER    DEFAULT NULL
  ,p_extension_period_units         IN  VARCHAR2  DEFAULT NULL
  ,p_employment_status              IN  VARCHAR2  DEFAULT NULL
  ,p_expiry_date                    IN  VARCHAR2  DEFAULT NULL
  ,p_attribute_category             IN  VARCHAR2  DEFAULT NULL
  ,p_attribute1                     IN  VARCHAR2  DEFAULT NULL
  ,p_attribute2                     IN  VARCHAR2  DEFAULT NULL
  ,p_attribute3                     IN  VARCHAR2  DEFAULT NULL
  ,p_attribute4                     IN  VARCHAR2  DEFAULT NULL
  ,p_attribute5                     IN  VARCHAR2  DEFAULT NULL
  ,p_attribute6                     IN  VARCHAR2  DEFAULT NULL
  ,p_attribute7                     IN  VARCHAR2  DEFAULT NULL
  ,p_attribute8                     IN  VARCHAR2  DEFAULT NULL
  ,p_attribute9                     IN  VARCHAR2  DEFAULT NULL
  ,p_attribute10                    IN  VARCHAR2  DEFAULT NULL
  ,p_attribute11                    IN  VARCHAR2  DEFAULT NULL
  ,p_attribute12                    IN  VARCHAR2  DEFAULT NULL
  ,p_attribute13                    IN  VARCHAR2  DEFAULT NULL
  ,p_attribute14                    IN  VARCHAR2  DEFAULT NULL
  ,p_attribute15                    IN  VARCHAR2  DEFAULT NULL
  ,p_attribute16                    IN  VARCHAR2  DEFAULT NULL
  ,p_attribute17                    IN  VARCHAR2  DEFAULT NULL
  ,p_attribute18                    IN  VARCHAR2  DEFAULT NULL
  ,p_attribute19                    IN  VARCHAR2  DEFAULT NULL
  ,p_attribute20                    IN  VARCHAR2  DEFAULT NULL
  ,p_effective_date                 IN  DATE
 );
--
-- ----------------------------------------------------------------------------
-- |----------------------------< update_ae_contract >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates an existing UAE contract.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Oracle Human Resources.
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
 * database will remain unchanged. if false and all validation checks pass,
 * then the database will be modified.
 * @param p_contract_id Identifies the contract record.
 * @param p_effective_start_date If p_validate is false, then set to the
 * effective start date on the updated contract row which now exists as of the
 * effective date. If p_validate is true, then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date on the updated contract row which now exists as of the
 * effective date. If p_validate is true, then set to null.
 * @param p_object_version_number Pass in the current version number of the
 * contract to be updated. when the api completes if p_validate is false, will
 * be set to the new version number of the updated contract. If p_validate is
 * true will be set to the same value which was passed in.
 * @param p_person_id Identifies the person record to be modified.
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
 * @param p_employment_status Employment status.
 * @param p_expiry_date Expiry date.
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
 * @param p_effective_date Determines when the datetrack operation comes into
 * force.
 * @param p_datetrack_mode Indicates which datetrack mode to use when updating
 * the record. you must set to either UPDATE, CORRECTION, UPDATE_OVERRIDE or
 * UPDATE_CHANGE_INSERT. Modes available for use with a particular record
 * depend on the dates of previous record changes and the effective DATE of
 * this change.
 * @rep:displayname Update Contract for UAE
 * @rep:category BUSINESS_ENTITY PER_EMPLOYMENT_CONTRACT
 * @rep:lifecycle active
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
PROCEDURE update_ae_contract
  (p_validate                       IN BOOLEAN    DEFAULT FALSE
  ,p_contract_id                    IN  NUMBER
  ,p_effective_start_date           OUT NOCOPY DATE
  ,p_effective_end_date             OUT NOCOPY DATE
  ,p_object_version_number          IN OUT NOCOPY NUMBER
  ,p_person_id                      IN  NUMBER
  ,p_reference                      IN  VARCHAR2
  ,p_type                           IN  VARCHAR2
  ,p_status                         IN  VARCHAR2
  ,p_status_reason                  IN  VARCHAR2  DEFAULT hr_api.g_VARCHAR2
  ,p_doc_status                     IN  VARCHAR2  DEFAULT hr_api.g_VARCHAR2
  ,p_doc_status_change_date         IN  DATE      DEFAULT hr_api.g_DATE
  ,p_description                    IN  VARCHAR2  DEFAULT hr_api.g_VARCHAR2
  ,p_duration                       IN  NUMBER    DEFAULT hr_api.g_NUMBER
  ,p_duration_units                 IN  VARCHAR2  DEFAULT hr_api.g_VARCHAR2
  ,p_contractual_job_title          IN  VARCHAR2  DEFAULT hr_api.g_VARCHAR2
  ,p_parties                        IN  VARCHAR2  DEFAULT hr_api.g_VARCHAR2
  ,p_start_reason                   IN  VARCHAR2  DEFAULT hr_api.g_VARCHAR2
  ,p_end_reason                     IN  VARCHAR2  DEFAULT hr_api.g_VARCHAR2
  ,p_number_of_extensions           IN  NUMBER    DEFAULT hr_api.g_NUMBER
  ,p_extension_reason               IN  VARCHAR2  DEFAULT hr_api.g_VARCHAR2
  ,p_extension_period               IN  NUMBER    DEFAULT hr_api.g_NUMBER
  ,p_extension_period_units         IN  VARCHAR2  DEFAULT hr_api.g_VARCHAR2
  ,p_employment_status              IN  VARCHAR2  DEFAULT hr_api.g_VARCHAR2
  ,p_expiry_date                    IN  VARCHAR2  DEFAULT hr_api.g_VARCHAR2
  ,p_attribute_category             IN  VARCHAR2  DEFAULT hr_api.g_VARCHAR2
  ,p_attribute1                     IN  VARCHAR2  DEFAULT hr_api.g_VARCHAR2
  ,p_attribute2                     IN  VARCHAR2  DEFAULT hr_api.g_VARCHAR2
  ,p_attribute3                     IN  VARCHAR2  DEFAULT hr_api.g_VARCHAR2
  ,p_attribute4                     IN  VARCHAR2  DEFAULT hr_api.g_VARCHAR2
  ,p_attribute5                     IN  VARCHAR2  DEFAULT hr_api.g_VARCHAR2
  ,p_attribute6                     IN  VARCHAR2  DEFAULT hr_api.g_VARCHAR2
  ,p_attribute7                     IN  VARCHAR2  DEFAULT hr_api.g_VARCHAR2
  ,p_attribute8                     IN  VARCHAR2  DEFAULT hr_api.g_VARCHAR2
  ,p_attribute9                     IN  VARCHAR2  DEFAULT hr_api.g_VARCHAR2
  ,p_attribute10                    IN  VARCHAR2  DEFAULT hr_api.g_VARCHAR2
  ,p_attribute11                    IN  VARCHAR2  DEFAULT hr_api.g_VARCHAR2
  ,p_attribute12                    IN  VARCHAR2  DEFAULT hr_api.g_VARCHAR2
  ,p_attribute13                    IN  VARCHAR2  DEFAULT hr_api.g_VARCHAR2
  ,p_attribute14                    IN  VARCHAR2  DEFAULT hr_api.g_VARCHAR2
  ,p_attribute15                    IN  VARCHAR2  DEFAULT hr_api.g_VARCHAR2
  ,p_attribute16                    IN  VARCHAR2  DEFAULT hr_api.g_VARCHAR2
  ,p_attribute17                    IN  VARCHAR2  DEFAULT hr_api.g_VARCHAR2
  ,p_attribute18                    IN  VARCHAR2  DEFAULT hr_api.g_VARCHAR2
  ,p_attribute19                    IN  VARCHAR2  DEFAULT hr_api.g_VARCHAR2
  ,p_attribute20                    IN  VARCHAR2  DEFAULT hr_api.g_VARCHAR2
  ,p_effective_date                 IN  DATE
  ,p_datetrack_mode                 IN  VARCHAR2
  );
--
end hr_ae_contract_api;

/
