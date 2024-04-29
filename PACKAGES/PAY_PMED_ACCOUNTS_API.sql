--------------------------------------------------------
--  DDL for Package PAY_PMED_ACCOUNTS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_PMED_ACCOUNTS_API" AUTHID CURRENT_USER as
/* $Header: pypmaapi.pkh 120.1 2005/10/02 02:32:53 aroussel $ */
/*#
 * This package contains Proincial Medical Accounts APIs.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Provincial Medical Account
*/
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_pmed_accounts >-----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates Provincial medical Account for an organization.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The organization must exist under a Canadian business group.
 *
 * <p><b>Restricted Usage Notes</b><br>
 * The organization must be under a Canadian business group.
 *
 * <p><b>Post Success</b><br>
 * It will create a Provincial Medical account number for that organization.
 *
 * <p><b>Post Failure</b><br>
 * It will not create a PMED account number for that organization.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_organization_id Organization Id for which the Provincial Medical
 * account number is created
 * @param p_source_id Source ID for which the Provincial Medical account number
 * is created
 * @param p_account_number Provincial Medical Account Number that is to
 * becreated by this API
 * @param p_enabled If 'Y' then the Provincial Medical Account Number is
 * enabled and will be used in other processes. If 'N' it is disabled and will
 * not be used in other processes
 * @param p_description Description of the Provincial Medical Account Number
 * @param p_business_group_id Business Group of Record
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
 * @param p_attribute21 Descriptive flexfield segment.
 * @param p_attribute22 Descriptive flexfield segment.
 * @param p_attribute23 Descriptive flexfield segment.
 * @param p_attribute24 Descriptive flexfield segment.
 * @param p_attribute25 Descriptive flexfield segment.
 * @param p_attribute26 Descriptive flexfield segment.
 * @param p_attribute27 Descriptive flexfield segment.
 * @param p_attribute28 Descriptive flexfield segment.
 * @param p_attribute29 Descriptive flexfield segment.
 * @param p_attribute30 Descriptive flexfield segment.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created Provincial Medical account. If p_validate is
 * true, then the value will be null.
 * @rep:displayname Create Provincial Medical Account
 * @rep:category BUSINESS_ENTITY PAY_PROVINCIAL_MEDICAL
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_pmed_accounts
(
   p_validate                       in            boolean    default false
  ,p_organization_id                in            number    default null
  ,p_source_id                      out nocopy    number
  ,p_account_number                 in            varchar2  default null
  ,p_enabled                        in            varchar2  default null
  ,p_description                    in            varchar2  default null
  ,p_business_group_id              in            number    default null
  ,p_attribute_category             in            varchar2  default null
  ,p_attribute1                     in            varchar2  default null
  ,p_attribute2                     in            varchar2  default null
  ,p_attribute3                     in            varchar2  default null
  ,p_attribute4                     in            varchar2  default null
  ,p_attribute5                     in            varchar2  default null
  ,p_attribute6                     in            varchar2  default null
  ,p_attribute7                     in            varchar2  default null
  ,p_attribute8                     in            varchar2  default null
  ,p_attribute9                     in            varchar2  default null
  ,p_attribute10                    in            varchar2  default null
  ,p_attribute11                    in            varchar2  default null
  ,p_attribute12                    in            varchar2  default null
  ,p_attribute13                    in            varchar2  default null
  ,p_attribute14                    in            varchar2  default null
  ,p_attribute15                    in            varchar2  default null
  ,p_attribute16                    in            varchar2  default null
  ,p_attribute17                    in            varchar2  default null
  ,p_attribute18                    in            varchar2  default null
  ,p_attribute19                    in            varchar2  default null
  ,p_attribute20                    in            varchar2  default null
  ,p_attribute21                    in            varchar2  default null
  ,p_attribute22                    in            varchar2  default null
  ,p_attribute23                    in            varchar2  default null
  ,p_attribute24                    in            varchar2  default null
  ,p_attribute25                    in            varchar2  default null
  ,p_attribute26                    in            varchar2  default null
  ,p_attribute27                    in            varchar2  default null
  ,p_attribute28                    in            varchar2  default null
  ,p_attribute29                    in            varchar2  default null
  ,p_attribute30                    in            varchar2  default null
  ,p_object_version_number          out nocopy    number
 );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_pmed_accounts >-----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * Updates information about a Provincial Medical Account number for an
 * organization.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The Provincial Medical Account number must exist for the organization
 *
 * <p><b>Post Success</b><br>
 * The Provincial Medical Account number information will be updated for the
 * organization
 *
 * <p><b>Post Failure</b><br>
 * The Provincial Medical Account Number information will remain same for the
 * organization
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_organization_id Organization Id for which the Provincial Medical
 * account number is updated
 * @param p_source_id PK of record
 * @param p_account_number The Provincial Medical Account number which is
 * updated
 * @param p_enabled If 'Y' then the Provincial Medical Account Number is
 * enabled and will be used in other processes. If 'N' it is disabled and will
 * not be used in other processes
 * @param p_description Description of the PMED Account Number
 * @param p_business_group_id Business Group of Record
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
 * @param p_attribute21 Descriptive flexfield segment.
 * @param p_attribute22 Descriptive flexfield segment.
 * @param p_attribute23 Descriptive flexfield segment.
 * @param p_attribute24 Descriptive flexfield segment.
 * @param p_attribute25 Descriptive flexfield segment.
 * @param p_attribute26 Descriptive flexfield segment.
 * @param p_attribute27 Descriptive flexfield segment.
 * @param p_attribute28 Descriptive flexfield segment.
 * @param p_attribute29 Descriptive flexfield segment.
 * @param p_attribute30 Descriptive flexfield segment.
 * @param p_object_version_number Pass in the current version number of the
 * Provincial Medical account to be updated. When the API completes if
 * p_validate is false, will be set to the new version number of the updated
 * Provincial Medical account. If p_validate is true will be set to the same
 * value which was passed in.
 * @rep:displayname Update Provincial Medical Account
 * @rep:category BUSINESS_ENTITY PAY_PROVINCIAL_MEDICAL
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_pmed_accounts
  (
   p_validate                       in            boolean    default false
  ,p_organization_id                in            number    default hr_api.g_number
  ,p_source_id                      in            number
  ,p_account_number                 in            varchar2  default hr_api.g_varchar2
  ,p_enabled                        in            varchar2  default hr_api.g_varchar2
  ,p_description                    in            varchar2  default hr_api.g_varchar2
  ,p_business_group_id              in            number    default hr_api.g_number
  ,p_attribute_category             in            varchar2  default hr_api.g_varchar2
  ,p_attribute1                     in            varchar2  default hr_api.g_varchar2
  ,p_attribute2                     in            varchar2  default hr_api.g_varchar2
  ,p_attribute3                     in            varchar2  default hr_api.g_varchar2
  ,p_attribute4                     in            varchar2  default hr_api.g_varchar2
  ,p_attribute5                     in            varchar2  default hr_api.g_varchar2
  ,p_attribute6                     in            varchar2  default hr_api.g_varchar2
  ,p_attribute7                     in            varchar2  default hr_api.g_varchar2
  ,p_attribute8                     in            varchar2  default hr_api.g_varchar2
  ,p_attribute9                     in            varchar2  default hr_api.g_varchar2
  ,p_attribute10                    in            varchar2  default hr_api.g_varchar2
  ,p_attribute11                    in            varchar2  default hr_api.g_varchar2
  ,p_attribute12                    in            varchar2  default hr_api.g_varchar2
  ,p_attribute13                    in            varchar2  default hr_api.g_varchar2
  ,p_attribute14                    in            varchar2  default hr_api.g_varchar2
  ,p_attribute15                    in            varchar2  default hr_api.g_varchar2
  ,p_attribute16                    in            varchar2  default hr_api.g_varchar2
  ,p_attribute17                    in            varchar2  default hr_api.g_varchar2
  ,p_attribute18                    in            varchar2  default hr_api.g_varchar2
  ,p_attribute19                    in            varchar2  default hr_api.g_varchar2
  ,p_attribute20                    in            varchar2  default hr_api.g_varchar2
  ,p_attribute21                    in            varchar2  default hr_api.g_varchar2
  ,p_attribute22                    in            varchar2  default hr_api.g_varchar2
  ,p_attribute23                    in            varchar2  default hr_api.g_varchar2
  ,p_attribute24                    in            varchar2  default hr_api.g_varchar2
  ,p_attribute25                    in            varchar2  default hr_api.g_varchar2
  ,p_attribute26                    in            varchar2  default hr_api.g_varchar2
  ,p_attribute27                    in            varchar2  default hr_api.g_varchar2
  ,p_attribute28                    in            varchar2  default hr_api.g_varchar2
  ,p_attribute29                    in            varchar2  default hr_api.g_varchar2
  ,p_attribute30                    in            varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_pmed_accounts >-----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes an existing PMED Account Number for an organization.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The Provincial Medical Account number must exist for the organization
 *
 * <p><b>Post Success</b><br>
 * The Provincial Medical Account Number will be deleted for the organization.
 *
 * <p><b>Post Failure</b><br>
 * The Provincial Medical Account Number will not be deleted for the
 * organization
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_source_id PK of record
 * @param p_object_version_number Current version number of the Provincial
 * Medical account to be deleted.
 * @rep:displayname Delete Provincial Medical Account
 * @rep:category BUSINESS_ENTITY PAY_PROVINCIAL_MEDICAL
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_pmed_accounts
  (
   p_validate                       in                 boolean        default false
  ,p_source_id                      in                 number
  ,p_object_version_number          in out nocopy      number
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
--   p_source_id                 Yes  number   PK of record
--   p_object_version_number        Yes  number   OVN of record
--
-- Post Success:
--
--   Name                           Type     Description
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
    p_source_id                 in number
   ,p_object_version_number        in number
  );
--
end pay_pmed_accounts_api;

 

/
