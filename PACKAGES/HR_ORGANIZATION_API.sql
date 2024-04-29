--------------------------------------------------------
--  DDL for Package HR_ORGANIZATION_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_ORGANIZATION_API" AUTHID CURRENT_USER AS
/* $Header: hrorgapi.pkh 120.13.12010000.4 2009/04/14 09:46:26 sathkris ship $ */
/*#
 * This package contains APIs that create and manage HR Organizations.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Organization
*/
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_hr_organization >----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates an organization with the classification HR Organization.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * None
 *
 * <p><b>Post Success</b><br>
 * Organization with the classification of hr organization is created.
 *
 * <p><b>Post Failure</b><br>
 * Organization is not created and error is raised.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_business_group_id Uniquely identifies the business group associated
 * with the organization the process creates.
 * @param p_name The name of the organization the process creates.
 * @param p_date_from Date the organization takes effect.
 * @param p_language_code Specifies to which language the translation values
 * apply. You can set to the base or any installed language. The default value
 * of hr_api.userenv_lang is equivalent to the RDBMS userenv('LANG') function
 * value.
 * @param p_location_id Uniquely identifies the location of the organization.
 * @param p_date_to Date the organization is no longer in effect.
 * @param p_internal_external_flag Flag specifying if the organization is an
 * internal or external organization.
 * @param p_internal_address_line Internal Address Line.
 * @param p_type The organization type associated with the organization the
 * process creates. Valid values are determined by the ORG_TYPE lookup type.
 * @param p_enabled_flag Flag specifying if the organization information is
 * enabled. The default value is 'N'.
 * @param p_segment1 Cost allocation key flexfield segment
 * @param p_segment2 Cost allocation key flexfield segment
 * @param p_segment3 Cost allocation key flexfield segment
 * @param p_segment4 Cost allocation key flexfield segment
 * @param p_segment5 Cost allocation key flexfield segment
 * @param p_segment6 Cost allocation key flexfield segment
 * @param p_segment7 Cost allocation key flexfield segment
 * @param p_segment8 Cost allocation key flexfield segment
 * @param p_segment9 Cost allocation key flexfield segment
 * @param p_segment10 Cost allocation key flexfield segment
 * @param p_segment11 Cost allocation key flexfield segment
 * @param p_segment12 Cost allocation key flexfield segment
 * @param p_segment13 Cost allocation key flexfield segment
 * @param p_segment14 Cost allocation key flexfield segment
 * @param p_segment15 Cost allocation key flexfield segment
 * @param p_segment16 Cost allocation key flexfield segment
 * @param p_segment17 Cost allocation key flexfield segment
 * @param p_segment18 Cost allocation key flexfield segment
 * @param p_segment19 Cost allocation key flexfield segment
 * @param p_segment20 Cost allocation key flexfield segment
 * @param p_segment21 Cost allocation key flexfield segment
 * @param p_segment22 Cost allocation key flexfield segment
 * @param p_segment23 Cost allocation key flexfield segment
 * @param p_segment24 Cost allocation key flexfield segment
 * @param p_segment25 Cost allocation key flexfield segment
 * @param p_segment26 Cost allocation key flexfield segment
 * @param p_segment27 Cost allocation key flexfield segment
 * @param p_segment28 Cost allocation key flexfield segment
 * @param p_segment29 Cost allocation key flexfield segment
 * @param p_segment30 Cost allocation key flexfield segment
 * @param p_concat_segments Cost Allocation Flexfield concatenated segments.
 * @param p_object_version_number_inf If p_validate is false, then set to the
 * version number of the created organization information row. If p_validate is
 * true, then the value will be null.
 * @param p_object_version_number_org If p_validate is false, then set to the
 * version number of the created organization row. If p_validate is true, then
 * the value will be null.
 * @param p_organization_id If p_validate is false, then this uniquely
 * identifies the organization created. If p_validate is true, then set to
 * null..
 * @param p_org_information_id If p_validate is false, this uniquely identifies
 * the organization information created. If p_validate is true, then set to
 * null.
 * @param p_duplicate_org_warning The value is 'true' if an organization
 * already exists with the same name in a different business group. (If the
 * duplicate is in the same business group, the process raises an error.)
 * @rep:displayname Create HR Organization
 * @rep:category BUSINESS_ENTITY HR_ORGANIZATION
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
    procedure create_hr_organization
    (p_validate                    in  boolean default false
    ,p_effective_date              in  date
    ,p_business_group_id           in  number
    ,p_name                        in  varchar2
    ,p_date_from                   in  date
    ,p_language_code               in  varchar2 default hr_api.userenv_lang
    ,p_location_id                 in  number   default null
    ,p_date_to                     in  date     default null
    ,p_internal_external_flag      in  varchar2 default null
    ,p_internal_address_line       in  varchar2 default null
    ,p_type                        in  varchar2 default null
    ,p_enabled_flag                in  varchar2 default 'N'
    ,p_segment1                    in  varchar2 default null
    ,p_segment2                    in  varchar2 default null
    ,p_segment3                    in  varchar2 default null
    ,p_segment4                    in  varchar2 default null
    ,p_segment5                    in  varchar2 default null
    ,p_segment6                    in  varchar2 default null
    ,p_segment7                    in  varchar2 default null
    ,p_segment8                    in  varchar2 default null
    ,p_segment9                    in  varchar2 default null
    ,p_segment10                   in  varchar2 default null
    ,p_segment11                   in  varchar2 default null
    ,p_segment12                   in  varchar2 default null
    ,p_segment13                   in  varchar2 default null
    ,p_segment14                   in  varchar2 default null
    ,p_segment15                   in  varchar2 default null
    ,p_segment16                   in  varchar2 default null
    ,p_segment17                   in  varchar2 default null
    ,p_segment18                   in  varchar2 default null
    ,p_segment19                   in  varchar2 default null
    ,p_segment20                   in  varchar2 default null
    ,p_segment21                   in  varchar2 default null
    ,p_segment22                   in  varchar2 default null
    ,p_segment23                   in  varchar2 default null
    ,p_segment24                   in  varchar2 default null
    ,p_segment25                   in  varchar2 default null
    ,p_segment26                   in  varchar2 default null
    ,p_segment27                   in  varchar2 default null
    ,p_segment28                   in  varchar2 default null
    ,p_segment29                   in  varchar2 default null
    ,p_segment30                   in  varchar2 default null
    ,p_concat_segments             in  varchar2 default null
    ,p_object_version_number_inf   out nocopy  number
    ,p_object_version_number_org   out nocopy  number
    ,p_organization_id             out nocopy  number
    ,p_org_information_id          out nocopy  number
    ,p_duplicate_org_warning       out nocopy  boolean
    );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_organization >------------------------|
-- ----------------------------------------------------------------------------
--
-- This version of the API is now out-of-date however it has been provided to
-- you for backward compatibility support and will be removed in the future.
-- Oracle recommends you to modify existing calling programs in advance of the
-- support being withdrawn thus avoiding any potential disruption.
--
PROCEDURE create_organization
   (  p_validate                      IN  BOOLEAN   DEFAULT false
     ,p_effective_date                IN  DATE
     ,p_language_code                 IN  VARCHAR2  DEFAULT hr_api.userenv_lang
     ,p_business_group_id             IN  NUMBER
     ,p_date_from                     IN  DATE
     ,p_name                          IN  VARCHAR2
     ,p_location_id                   in  number   default null
     ,p_date_to                       in  date     default null
     ,p_internal_external_flag        in  varchar2 default null
     ,p_internal_address_line         in  varchar2 default null
     ,p_type                          in  varchar2 default null
     ,p_comments                      in  varchar2 default null
     ,p_attribute_category            in  varchar2 default null
     ,p_attribute1                    in  varchar2 default null
     ,p_attribute2                    in  varchar2 default null
     ,p_attribute3                    in  varchar2 default null
     ,p_attribute4                    in  varchar2 default null
     ,p_attribute5                    in  varchar2 default null
     ,p_attribute6                    in  varchar2 default null
     ,p_attribute7                    in  varchar2 default null
     ,p_attribute8                    in  varchar2 default null
     ,p_attribute9                    in  varchar2 default null
     ,p_attribute10                   in  varchar2 default null
     ,p_attribute11                   in  varchar2 default null
     ,p_attribute12                   in  varchar2 default null
     ,p_attribute13                   in  varchar2 default null
     ,p_attribute14                   in  varchar2 default null
     ,p_attribute15                   in  varchar2 default null
     ,p_attribute16                   in  varchar2 default null
     ,p_attribute17                   in  varchar2 default null
     ,p_attribute18                   in  varchar2 default null
     ,p_attribute19                   in  varchar2 default null
     ,p_attribute20                   in  varchar2 default null
     --Enhancement 4040086
     --Begin of Add 10 additional segments
     ,p_attribute21                   in  varchar2 default null
     ,p_attribute22                   in  varchar2 default null
     ,p_attribute23                   in  varchar2 default null
     ,p_attribute24                   in  varchar2 default null
     ,p_attribute25                   in  varchar2 default null
     ,p_attribute26                   in  varchar2 default null
     ,p_attribute27                   in  varchar2 default null
     ,p_attribute28                   in  varchar2 default null
     ,p_attribute29                   in  varchar2 default null
     ,p_attribute30                   in  varchar2 default null
     --End of Add 10 additional segments
     ,p_organization_id               OUT NOCOPY NUMBER
     ,p_object_version_number         OUT NOCOPY NUMBER
 );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_organization >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a new organization within the scope of an existing business
 * group.
 *
 * The API is MLS enabled, and there is one translated column (NAME).
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources and HR Foundation.
 *
 * <p><b>Prerequisites</b><br>
 * None
 *
 * <p><b>Post Success</b><br>
 * Organization is created.
 *
 * <p><b>Post Failure</b><br>
 * Organization not created and error returned.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_language_code Specifies to which language the translation values
 * apply. You can set to the base or any installed language. The default value
 * of hr_api.userenv_lang is equivalent to the RDBMS userenv('LANG') function
 * value.
 * @param p_business_group_id Uniquely identifies the business group associated
 * with the organization the process creates.
 * @param p_date_from Date the organization takes effect.
 * @param p_name The name of the organization the process creates (translated).
 * @param p_location_id Uniquely identifies the location of the organization.
 * @param p_date_to Date when the organization is no longer in effect.
 * @param p_internal_external_flag Internal or external organization flag.
 * @param p_internal_address_line Internal address Line.
 * @param p_type The organization type associated with the organization the
 * process creates. Valid values are determined by the ORG_TYPE lookup type.
 * @param p_comments Comment text
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
 * @param p_organization_id If p_validate is false, then this uniquely
 * identifies the Organization created. If p_validate is true, then set to
 * null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the organization created. If p_validate is true, then set
 * to null..
 * @param p_duplicate_org_warning The value is 'true' if an organization
 * already exists with the same name in a different business group. (If the
 * duplicate is in the same business group, the process raises an error.)
 * @rep:displayname Create Organization
 * @rep:category BUSINESS_ENTITY HR_ORGANIZATION
 * @rep:category MISC_EXTENSIONS HR_DATAPUMP
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--

PROCEDURE create_organization
   (  p_validate                      IN  BOOLEAN   DEFAULT false
     ,p_effective_date                IN  DATE
     ,p_language_code                 IN  VARCHAR2  DEFAULT hr_api.userenv_lang
     ,p_business_group_id             IN  NUMBER
     ,p_date_from                     IN  DATE
     ,p_name                          IN  VARCHAR2
     ,p_location_id                   in  number   default null
     ,p_date_to                       in  date     default null
     ,p_internal_external_flag        in  varchar2 default null
     ,p_internal_address_line         in  varchar2 default null
     ,p_type                          in  varchar2 default null
     ,p_comments                      in  varchar2 default null
     ,p_attribute_category            in  varchar2 default null
     ,p_attribute1                    in  varchar2 default null
     ,p_attribute2                    in  varchar2 default null
     ,p_attribute3                    in  varchar2 default null
     ,p_attribute4                    in  varchar2 default null
     ,p_attribute5                    in  varchar2 default null
     ,p_attribute6                    in  varchar2 default null
     ,p_attribute7                    in  varchar2 default null
     ,p_attribute8                    in  varchar2 default null
     ,p_attribute9                    in  varchar2 default null
     ,p_attribute10                   in  varchar2 default null
     ,p_attribute11                   in  varchar2 default null
     ,p_attribute12                   in  varchar2 default null
     ,p_attribute13                   in  varchar2 default null
     ,p_attribute14                   in  varchar2 default null
     ,p_attribute15                   in  varchar2 default null
     ,p_attribute16                   in  varchar2 default null
     ,p_attribute17                   in  varchar2 default null
     ,p_attribute18                   in  varchar2 default null
     ,p_attribute19                   in  varchar2 default null
     ,p_attribute20                   in  varchar2 default null
    --Enhancement 4040086
    --Begin of Add 10 additional segments
     ,p_attribute21                   in  varchar2 default null
     ,p_attribute22                   in  varchar2 default null
     ,p_attribute23                   in  varchar2 default null
     ,p_attribute24                   in  varchar2 default null
     ,p_attribute25                   in  varchar2 default null
     ,p_attribute26                   in  varchar2 default null
     ,p_attribute27                   in  varchar2 default null
     ,p_attribute28                   in  varchar2 default null
     ,p_attribute29                   in  varchar2 default null
     ,p_attribute30                   in  varchar2 default null
     --End of Add 10 additional segments
     ,p_organization_id               OUT NOCOPY NUMBER
     ,p_object_version_number         OUT NOCOPY NUMBER
     ,p_duplicate_org_warning         OUT NOCOPY BOOLEAN
 );

--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_organization >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API Updates an existing Organization.
 *
 * You cannot update the name or business_group_id attributes. The process
 * stores organizations in the table HR_ALL_ORGANIZATION_UNITS.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources and HR Foundation.
 *
 * <p><b>Prerequisites</b><br>
 * Organization must exist.
 *
 * <p><b>Post Success</b><br>
 * When the location has been successfully inserted, the following OUT
 * parameters are set:
 *
 * <p><b>Post Failure</b><br>
 * The API does not update the organization, and raises an error
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_language_code Specifies to which language the translation values
 * apply. You can set to the base or any installed language. The default value
 * of hr_api.userenv_lang is equivalent to the RDBMS userenv('LANG') function
 * value.
 * @param p_name Name of the organization (translated).
 * @param p_organization_id Uniquely identifies the organization record to
 * modify.
 * @param p_cost_allocation_keyflex_id Cost Allocation Key Flex ID
 * @param p_location_id Uniquely identifies the location of the organization.
 * @param p_date_from Date the organization takes effect.
 * @param p_date_to Date till when the organization is in effect.
 * @param p_internal_external_flag Internal External Flag
 * @param p_internal_address_line Internal Address Line.
 * @param p_type The organization type associated with the organization the
 * process creates. Valid values are determined by the ORG_TYPE lookup type.
 * @param p_comments Comment Text
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
 * @param p_segment1 Cost allocation key flexfield segment
 * @param p_segment2 Cost allocation key flexfield segment
 * @param p_segment3 Cost allocation key flexfield segment
 * @param p_segment4 Cost allocation key flexfield segment
 * @param p_segment5 Cost allocation key flexfield segment
 * @param p_segment6 Cost allocation key flexfield segment
 * @param p_segment7 Cost allocation key flexfield segment
 * @param p_segment8 Cost allocation key flexfield segment
 * @param p_segment9 Cost allocation key flexfield segment
 * @param p_segment10 Cost allocation key flexfield segment
 * @param p_segment11 Cost allocation key flexfield segment
 * @param p_segment12 Cost allocation key flexfield segment
 * @param p_segment13 Cost allocation key flexfield segment
 * @param p_segment14 Cost allocation key flexfield segment
 * @param p_segment15 Cost allocation key flexfield segment
 * @param p_segment16 Cost allocation key flexfield segment
 * @param p_segment17 Cost allocation key flexfield segment
 * @param p_segment18 Cost allocation key flexfield segment
 * @param p_segment19 Cost allocation key flexfield segment
 * @param p_segment20 Cost allocation key flexfield segment
 * @param p_segment21 Cost allocation key flexfield segment
 * @param p_segment22 Cost allocation key flexfield segment
 * @param p_segment23 Cost allocation key flexfield segment
 * @param p_segment24 Cost allocation key flexfield segment
 * @param p_segment25 Cost allocation key flexfield segment
 * @param p_segment26 Cost allocation key flexfield segment
 * @param p_segment27 Cost allocation key flexfield segment
 * @param p_segment28 Cost allocation key flexfield segment
 * @param p_segment29 Cost allocation key flexfield segment
 * @param p_segment30 Cost allocation key flexfield segment
 * @param p_concat_segments Cost allocation key flexfield segment
 * @param p_object_version_number Pass in the current version number of the
 * Organization to be updated. When the API completes if p_validate is false,
 * will be set to the new version number of the updated Organization. If
 * p_validate is true will be set to the same value which was passed in.
 * @param p_duplicate_org_warning The value is 'true' if an organization
 * already exists with the same name in a different business group. (If the
 * duplicate is in the same business group, the process raises an error).
 * @rep:displayname Update Organization
 * @rep:category BUSINESS_ENTITY HR_ORGANIZATION
 * @rep:category MISC_EXTENSIONS HR_DATAPUMP
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
PROCEDURE update_organization
  (   p_validate                       IN  BOOLEAN   DEFAULT false
     ,p_effective_date                 IN  DATE
     ,p_language_code                  IN  VARCHAR2  DEFAULT hr_api.userenv_lang
--
     ,p_name                           IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_organization_id                IN  NUMBER
     ,p_cost_allocation_keyflex_id     IN  NUMBER    DEFAULT hr_api.g_number
     ,p_location_id                    IN  NUMBER    DEFAULT hr_api.g_number
     -- Bug 3040119
     --,p_soft_coding_keyflex_id         IN  NUMBER    DEFAULT hr_api.g_number
     ,p_date_from                      IN  DATE      DEFAULT hr_api.g_date
     ,p_date_to                        IN  DATE      DEFAULT hr_api.g_date
     ,p_internal_external_flag         IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_internal_address_line          IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_type                           IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_comments                       IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute_category             IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute1                     IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute2                     IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute3                     IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute4                     IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute5                     IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute6                     IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute7                     IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute8                     IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute9                     IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute10                    IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute11                    IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute12                    IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute13                    IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute14                    IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute15                    IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute16                    IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute17                    IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute18                    IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute19                    IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute20                    IN  VARCHAR2  DEFAULT hr_api.g_varchar2
    --Enhancement 4040086
    --Begin of Add 10 additional segments
     ,p_attribute21                    IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute22                    IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute23                    IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute24                    IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute25                    IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute26                    IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute27                    IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute28                    IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute29                    IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute30                    IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     --End of Add 10 additional segments
     -- Bug 3039046
     ,p_segment1                       IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_segment2                       IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_segment3                       IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_segment4                       IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_segment5                       IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_segment6                       IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_segment7                       IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_segment8                       IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_segment9                       IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_segment10                      IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_segment11                      IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_segment12                      IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_segment13                      IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_segment14                      IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_segment15                      IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_segment16                      IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_segment17                      IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_segment18                      IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_segment19                      IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_segment20                      IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_segment21                      IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_segment22                      IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_segment23                      IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_segment24                      IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_segment25                      IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_segment26                      IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_segment27                      IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_segment28                      IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_segment29                      IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_segment30                      IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_concat_segments                IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     --
     ,p_object_version_number          IN OUT NOCOPY NUMBER
     ,p_duplicate_org_warning          OUT NOCOPY BOOLEAN
 );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_organization >------------------------|
-- ----------------------------------------------------------------------------
--
-- This version of the API is now out-of-date however it has been provided to
-- you for backward compatibility support and will be removed in the future.
-- Oracle recommends you to modify existing calling programs in advance of the
-- support being withdrawn thus avoiding any potential disruption.
--

PROCEDURE update_organization
  (   p_validate                       IN  BOOLEAN   DEFAULT false
     ,p_effective_date                 IN  DATE
     ,p_language_code                  IN  VARCHAR2  DEFAULT hr_api.userenv_lang
--
     ,p_organization_id                IN  NUMBER
     ,p_cost_allocation_keyflex_id     IN  NUMBER    DEFAULT hr_api.g_number
     ,p_location_id                    IN  NUMBER    DEFAULT hr_api.g_number
     -- Bug 3040119
     --,p_soft_coding_keyflex_id         IN  NUMBER    DEFAULT hr_api.g_number
     ,p_date_from                      IN  DATE      DEFAULT hr_api.g_date
     ,p_date_to                        IN  DATE      DEFAULT hr_api.g_date
     ,p_internal_external_flag         IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_internal_address_line          IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_type                           IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_comments                       IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute_category             IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute1                     IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute2                     IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute3                     IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute4                     IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute5                     IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute6                     IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute7                     IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute8                     IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute9                     IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute10                    IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute11                    IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute12                    IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute13                    IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute14                    IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute15                    IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute16                    IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute17                    IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute18                    IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute19                    IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute20                    IN  VARCHAR2  DEFAULT hr_api.g_varchar2
    --Enhancement 4040086
    --Begin of Add 10 additional segments
     ,p_attribute21                    IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute22                    IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute23                    IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute24                    IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute25                    IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute26                    IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute27                    IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute28                    IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute29                    IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute30                    IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     -- Bug 3039046
     ,p_segment1                       IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_segment2                       IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_segment3                       IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_segment4                       IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_segment5                       IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_segment6                       IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_segment7                       IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_segment8                       IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_segment9                       IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_segment10                      IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_segment11                      IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_segment12                      IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_segment13                      IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_segment14                      IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_segment15                      IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_segment16                      IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_segment17                      IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_segment18                      IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_segment19                      IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_segment20                      IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_segment21                      IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_segment22                      IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_segment23                      IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_segment24                      IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_segment25                      IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_segment26                      IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_segment27                      IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_segment28                      IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_segment29                      IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_segment30                      IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_concat_segments                IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     --
     ,p_object_version_number          IN OUT NOCOPY NUMBER
 );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_organization >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes an organization.
 *
 * This API deletes an organization from the HR_ALL_ORGANIZATION_UNITS table,
 * and its associated translated rows from the HR_ALL_ORGANIZATION_UNITS_TL
 * table.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources and HR Foundation.
 *
 * <p><b>Prerequisites</b><br>
 * Organization should exist.
 *
 * <p><b>Post Success</b><br>
 * Organization is deleted.
 *
 * <p><b>Post Failure</b><br>
 * Organization is not deleted and error is returned.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_organization_id Identifies the organization record to deleted.
 * @param p_object_version_number Current version number of the Organization to
 * be deleted.
 * @rep:displayname Delete Organization
 * @rep:category BUSINESS_ENTITY HR_ORGANIZATION
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
PROCEDURE delete_organization
  (  p_validate                     IN BOOLEAN DEFAULT false
    ,p_organization_id              IN hr_all_organization_units.organization_id%TYPE
    ,p_object_version_number        IN hr_all_organization_units.object_version_number%TYPE
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_org_classification >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates organization classification for an existing organization.
 *
 * Classifications are stored in the table HR_ORGANIZATION_INFORMATION.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources and HR Foundation.
 *
 * <p><b>Prerequisites</b><br>
 * Organization should exist.
 *
 * <p><b>Post Success</b><br>
 * Classification will be added to the organization.
 *
 * <p><b>Post Failure</b><br>
 * Classification is not added to the organization and error is returned.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_organization_id Uniquely identifies the organization for which the
 * process adds a new classification.
 * @param p_org_classif_code The organization classification code
 * @param p_org_information_id If p_validate is false, then this uniquely
 * identifies the classification created. If p_validate is true, then set to
 * null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the organization classification created. If p_validate is
 * true, then set to null..
 * @rep:displayname Create Organization Classification
 * @rep:category BUSINESS_ENTITY HR_ORGANIZATION
 * @rep:category MISC_EXTENSIONS HR_DATAPUMP
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
PROCEDURE create_org_classification
   (  p_validate                       IN  BOOLEAN   DEFAULT false
     ,p_effective_date                 IN  DATE
--
     ,p_organization_id                IN  NUMBER
     ,p_org_classif_code               IN  VARCHAR2
     ,p_org_information_id             OUT NOCOPY NUMBER
     ,p_object_version_number          OUT NOCOPY NUMBER
 );
--
-- ----------------------------------------------------------------------------
-- |------------------------< enable_org_classification >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API enables a classification of an organization.
 *
 * Classifications are stored in the table HR_ORGANIZATION_INFORMATION.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources and HR Foundation.
 *
 * <p><b>Prerequisites</b><br>
 * Classification of the organization should already exist.
 *
 * <p><b>Post Success</b><br>
 * Classification of the organization will be enabled.
 *
 * <p><b>Post Failure</b><br>
 * Classifcation is not enabled and error is returned.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_org_information_id Identifies the organization classification
 * record to be enabled.
 * @param p_org_info_type_code Organization information type code.
 * @param p_object_version_number Pass in the current version number of the
 * organization classification to be enabled. When the API completes if
 * p_validate is false, will be set to the new version number of the enabled
 * organization classification. If p_validate is true will be set to the same
 * value which was passed in.
 * @rep:displayname Enable Organization Classification
 * @rep:category BUSINESS_ENTITY HR_ORGANIZATION
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
PROCEDURE enable_org_classification
   (  p_validate                       IN  BOOLEAN   DEFAULT false
     ,p_effective_date                 IN  DATE
--
     ,p_org_information_id             IN  NUMBER
     ,p_org_info_type_code             IN  VARCHAR2
     ,p_object_version_number          IN OUT NOCOPY NUMBER
 );
--
-- ----------------------------------------------------------------------------
-- |------------------------< disable_org_classification >--------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API disables the classifcation of an organization.
 *
 * Classifications are stored on the table HR_ORGANIZATION_INFORMATION.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources and HR Foundation.
 *
 * <p><b>Prerequisites</b><br>
 * Classification of the organization should already exist.
 *
 * <p><b>Post Success</b><br>
 * Classification of the organization will be disabled.
 *
 * <p><b>Post Failure</b><br>
 * The classification of the organization will not be disbaled and error is
 * returned.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_org_information_id Identifies the organization classification
 * record to be disabled.
 * @param p_org_info_type_code Organization information type code.
 * @param p_object_version_number Pass in the current version number of the
 * oragnization classification to be updated. When the API completes if
 * p_validate is false, will be set to the new version number of the updated
 * organization classification If p_validate is true will be set to the same
 * value which was passed in.
 * @rep:displayname Disable Organization Classification
 * @rep:category BUSINESS_ENTITY HR_ORGANIZATION
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--

PROCEDURE disable_org_classification
   (  p_validate                       IN  BOOLEAN   DEFAULT false
     ,p_effective_date                 IN  DATE
--
     ,p_org_information_id             IN  NUMBER
     ,p_org_info_type_code             IN  VARCHAR2
     ,p_object_version_number          IN OUT NOCOPY NUMBER
 );
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_org_information >----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates organization information.
 *
 * Information types are stored in the table HR_ORGANIZATION_INFORMATION.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources and HR Foundation.
 *
 * <p><b>Prerequisites</b><br>
 * A valid organization must exist.
 *
 * <p><b>Post Success</b><br>
 * When the information type has been successfully inserted, the process
 * creates an organization information record.
 *
 * <p><b>Post Failure</b><br>
 * The API does not create the information type, and raises an error
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_organization_id Uniquely identifies the organization for which the
 * process creates organization information.
 * @param p_org_info_type_code The Information Type Code.
 * @param p_org_information1 Segment1 for p_org_info_type_code.
 * @param p_org_information2 Segment2 for p_org_info_type_code.
 * @param p_org_information3 Segment3 for p_org_info_type_code.
 * @param p_org_information4 Segment4 for p_org_info_type_code.
 * @param p_org_information5 Segment5 for p_org_info_type_code.
 * @param p_org_information6 Segment6 for p_org_info_type_code.
 * @param p_org_information7 Segment7 for p_org_info_type_code.
 * @param p_org_information8 Segment8 for p_org_info_type_code.
 * @param p_org_information9 Segment9 for p_org_info_type_code.
 * @param p_org_information10 Segment10 for p_org_info_type_code.
 * @param p_org_information11 Segment11 for p_org_info_type_code.
 * @param p_org_information12 Segment12 for p_org_info_type_code.
 * @param p_org_information13 Segment13 for p_org_info_type_code.
 * @param p_org_information14 Segment14 for p_org_info_type_code.
 * @param p_org_information15 Segment15 for p_org_info_type_code.
 * @param p_org_information16 Segment16 for p_org_info_type_code.
 * @param p_org_information17 Segment17 for p_org_info_type_code.
 * @param p_org_information18 Segment18 for p_org_info_type_code.
 * @param p_org_information19 Segment19 for p_org_info_type_code.
 * @param p_org_information20 Segment20 for p_org_info_type_code.
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
 * @param p_org_information_id If p_validate is false, then this uniquely
 * identifies the information type created. If p_validate is true, then set to
 * null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created organization information. If p_validate is
 * true, then the value will be null.
 * @rep:displayname Create Organization Information
 * @rep:category BUSINESS_ENTITY HR_ORGANIZATION
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
PROCEDURE create_org_information
   (  p_validate                       IN  BOOLEAN   DEFAULT false
     ,p_effective_date                 IN  DATE
--
     ,p_organization_id                IN  NUMBER
     ,p_org_info_type_code             IN  VARCHAR2
     ,p_org_information1               IN  VARCHAR2 DEFAULT null
     ,p_org_information2               IN  VARCHAR2 DEFAULT null
     ,p_org_information3               IN  VARCHAR2 DEFAULT null
     ,p_org_information4               IN  VARCHAR2 DEFAULT null
     ,p_org_information5               IN  VARCHAR2 DEFAULT null
     ,p_org_information6               IN  VARCHAR2 DEFAULT null
     ,p_org_information7               IN  VARCHAR2 DEFAULT null
     ,p_org_information8               IN  VARCHAR2 DEFAULT null
     ,p_org_information9               IN  VARCHAR2 DEFAULT null
     ,p_org_information10              IN  VARCHAR2 DEFAULT null
     ,p_org_information11              IN  VARCHAR2 DEFAULT null
     ,p_org_information12              IN  VARCHAR2 DEFAULT null
     ,p_org_information13              IN  VARCHAR2 DEFAULT null
     ,p_org_information14              IN  VARCHAR2 DEFAULT null
     ,p_org_information15              IN  VARCHAR2 DEFAULT null
     ,p_org_information16              IN  VARCHAR2 DEFAULT null
     ,p_org_information17              IN  VARCHAR2 DEFAULT null
     ,p_org_information18              IN  VARCHAR2 DEFAULT null
     ,p_org_information19              IN  VARCHAR2 DEFAULT null
     ,p_org_information20              IN  VARCHAR2 DEFAULT null
     ,p_attribute_category             IN  VARCHAR2 DEFAULT null
     ,p_attribute1                     IN  VARCHAR2 DEFAULT null
     ,p_attribute2                     IN  VARCHAR2 DEFAULT null
     ,p_attribute3                     IN  VARCHAR2 DEFAULT null
     ,p_attribute4                     IN  VARCHAR2 DEFAULT null
     ,p_attribute5                     IN  VARCHAR2 DEFAULT null
     ,p_attribute6                     IN  VARCHAR2 DEFAULT null
     ,p_attribute7                     IN  VARCHAR2 DEFAULT null
     ,p_attribute8                     IN  VARCHAR2 DEFAULT null
     ,p_attribute9                     IN  VARCHAR2 DEFAULT null
     ,p_attribute10                    IN  VARCHAR2 DEFAULT null
     ,p_attribute11                    IN  VARCHAR2 DEFAULT null
     ,p_attribute12                    IN  VARCHAR2 DEFAULT null
     ,p_attribute13                    IN  VARCHAR2 DEFAULT null
     ,p_attribute14                    IN  VARCHAR2 DEFAULT null
     ,p_attribute15                    IN  VARCHAR2 DEFAULT null
     ,p_attribute16                    IN  VARCHAR2 DEFAULT null
     ,p_attribute17                    IN  VARCHAR2 DEFAULT null
     ,p_attribute18                    IN  VARCHAR2 DEFAULT null
     ,p_attribute19                    IN  VARCHAR2 DEFAULT null
     ,p_attribute20                    IN  VARCHAR2 DEFAULT null
     ,p_org_information_id             OUT NOCOPY NUMBER
     ,p_object_version_number          OUT NOCOPY NUMBER
 );
--
-- ----------------------------------------------------------------------------
-- |----------------------------< create_org_manager >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates cost center manager information.
 *
 * This API creates a new cost center manager information type for an existing
 * organization. Information types are stored in the table
 * HR_ORGANIZATION_INFORMATION.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources and HR Foundation.
 *
 * <p><b>Prerequisites</b><br>
 * Organization should exist.
 *
 * <p><b>Post Success</b><br>
 * Organization manager relationship gets created.
 *
 * <p><b>Post Failure</b><br>
 * The API does not create the organization manager relationship, and raises an
 * error
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_organization_id Uniquely identifies the organization associated
 * with the organization manager relationship the process creates.
 * @param p_org_info_type_code The organization information type code -
 * 'Organization Name Alias'
 * @param p_org_information1 Segment1 for p_org_info_type_code.
 * @param p_org_information2 Uniquely identifies the person associated with the
 * cost center manager information.
 * @param p_org_information3 The date the organization manager relationship
 * takes effect.
 * @param p_org_information4 The date the organization manager relationship is
 * no longer in effect.
 * @param p_org_information5 Segment5 for p_org_info_type_code.
 * @param p_org_information6 Segment6 for p_org_info_type_code.
 * @param p_org_information7 Segment7 for p_org_info_type_code.
 * @param p_org_information8 Segment8 for p_org_info_type_code.
 * @param p_org_information9 Segment9 for p_org_info_type_code.
 * @param p_org_information10 Segment10 for p_org_info_type_code.
 * @param p_org_information11 Segment11 for p_org_info_type_code.
 * @param p_org_information12 Segment12 for p_org_info_type_code.
 * @param p_org_information13 Segment13 for p_org_info_type_code.
 * @param p_org_information14 Segment14 for p_org_info_type_code.
 * @param p_org_information15 Segment15 for p_org_info_type_code.
 * @param p_org_information16 Segment16 for p_org_info_type_code.
 * @param p_org_information17 Segment17 for p_org_info_type_code.
 * @param p_org_information18 Segment18 for p_org_info_type_code.
 * @param p_org_information19 Segment19 for p_org_info_type_code.
 * @param p_org_information20 Segment20 for p_org_info_type_code.
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
 * @param p_org_information_id If p_validate is false, then this uniquely
 * identifies the information type created. If p_validate is true, then set to
 * null.
 * @param p_object_version_number If p_validate is false, then it is set to
 * the version number of the created organization manager relationship. If
 * p_validate is true, then the value will be null.
 * @param p_warning Set if there is a overlap in the organization manager
 * relationship..
 * @rep:displayname Create Cost Center Manager
 * @rep:category BUSINESS_ENTITY HR_COST_CENTER
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
PROCEDURE create_org_manager
   (  p_validate                       IN  BOOLEAN   DEFAULT false
     ,p_effective_date                 IN  DATE
     ,p_organization_id                IN  NUMBER
     ,p_org_info_type_code             IN  VARCHAR2
     ,p_org_information1               IN  VARCHAR2 DEFAULT null
     ,p_org_information2               IN  VARCHAR2 DEFAULT null
     ,p_org_information3               IN  VARCHAR2 DEFAULT null
     ,p_org_information4               IN  VARCHAR2 DEFAULT null
     ,p_org_information5               IN  VARCHAR2 DEFAULT null
     ,p_org_information6               IN  VARCHAR2 DEFAULT null
     ,p_org_information7               IN  VARCHAR2 DEFAULT null
     ,p_org_information8               IN  VARCHAR2 DEFAULT null
     ,p_org_information9               IN  VARCHAR2 DEFAULT null
     ,p_org_information10              IN  VARCHAR2 DEFAULT null
     ,p_org_information11              IN  VARCHAR2 DEFAULT null
     ,p_org_information12              IN  VARCHAR2 DEFAULT null
     ,p_org_information13              IN  VARCHAR2 DEFAULT null
     ,p_org_information14              IN  VARCHAR2 DEFAULT null
     ,p_org_information15              IN  VARCHAR2 DEFAULT null
     ,p_org_information16              IN  VARCHAR2 DEFAULT null
     ,p_org_information17              IN  VARCHAR2 DEFAULT null
     ,p_org_information18              IN  VARCHAR2 DEFAULT null
     ,p_org_information19              IN  VARCHAR2 DEFAULT null
     ,p_org_information20              IN  VARCHAR2 DEFAULT null
     ,p_attribute_category             IN  VARCHAR2 DEFAULT null
     ,p_attribute1                     IN  VARCHAR2 DEFAULT null
     ,p_attribute2                     IN  VARCHAR2 DEFAULT null
     ,p_attribute3                     IN  VARCHAR2 DEFAULT null
     ,p_attribute4                     IN  VARCHAR2 DEFAULT null
     ,p_attribute5                     IN  VARCHAR2 DEFAULT null
     ,p_attribute6                     IN  VARCHAR2 DEFAULT null
     ,p_attribute7                     IN  VARCHAR2 DEFAULT null
     ,p_attribute8                     IN  VARCHAR2 DEFAULT null
     ,p_attribute9                     IN  VARCHAR2 DEFAULT null
     ,p_attribute10                    IN  VARCHAR2 DEFAULT null
     ,p_attribute11                    IN  VARCHAR2 DEFAULT null
     ,p_attribute12                    IN  VARCHAR2 DEFAULT null
     ,p_attribute13                    IN  VARCHAR2 DEFAULT null
     ,p_attribute14                    IN  VARCHAR2 DEFAULT null
     ,p_attribute15                    IN  VARCHAR2 DEFAULT null
     ,p_attribute16                    IN  VARCHAR2 DEFAULT null
     ,p_attribute17                    IN  VARCHAR2 DEFAULT null
     ,p_attribute18                    IN  VARCHAR2 DEFAULT null
     ,p_attribute19                    IN  VARCHAR2 DEFAULT null
     ,p_attribute20                    IN  VARCHAR2 DEFAULT null
     ,p_org_information_id             OUT NOCOPY NUMBER
     ,p_object_version_number          OUT NOCOPY NUMBER
     ,p_warning                        OUT NOCOPY BOOLEAN);
--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_org_information >----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates an information type of an Organization.
 *
 * Information types are stored in the table HR_ORGANIZATION_INFORMATION.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources and HR Foundation.
 *
 * <p><b>Prerequisites</b><br>
 * Organization should exist.
 *
 * <p><b>Post Success</b><br>
 * Organization information gets created.
 *
 * <p><b>Post Failure</b><br>
 * The API does not create the information type, and raises an error
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_org_information_id Uniquely identifies the organization information
 * record to modify.
 * @param p_org_info_type_code The organization information type code.
 * @param p_org_information1 Segment1 for p_org_info_type_code.
 * @param p_org_information2 Segment2 for p_org_info_type_code.
 * @param p_org_information3 Segment3 for p_org_info_type_code.
 * @param p_org_information4 Segment4 for p_org_info_type_code.
 * @param p_org_information5 Segment5 for p_org_info_type_code.
 * @param p_org_information6 Segment6 for p_org_info_type_code.
 * @param p_org_information7 Segment7 for p_org_info_type_code.
 * @param p_org_information8 Segment8 for p_org_info_type_code.
 * @param p_org_information9 Segment9 for p_org_info_type_code.
 * @param p_org_information10 Segment10 for p_org_info_type_code.
 * @param p_org_information11 Segment11 for p_org_info_type_code.
 * @param p_org_information12 Segment12 for p_org_info_type_code.
 * @param p_org_information13 Segment13 for p_org_info_type_code.
 * @param p_org_information14 Segment14 for p_org_info_type_code.
 * @param p_org_information15 Segment15 for p_org_info_type_code.
 * @param p_org_information16 Segment16 for p_org_info_type_code.
 * @param p_org_information17 Segment17 for p_org_info_type_code.
 * @param p_org_information18 Segment18 for p_org_info_type_code.
 * @param p_org_information19 Segment19 for p_org_info_type_code.
 * @param p_org_information20 Segment20 for p_org_info_type_code.
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
 * @param p_object_version_number Pass in the current version number of the
 * organization information record to be updated. When the API completes if
 * p_validate is false, will be set to the new version number of the updated
 * organization information record. If p_validate is true will be set to the
 * same value which was passed in.
 * @rep:displayname Update Organization Information
 * @rep:category BUSINESS_ENTITY HR_ORGANIZATION
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
PROCEDURE update_org_information
  (p_validate                       IN  BOOLEAN   DEFAULT false
  ,p_effective_date                 IN  DATE
  ,p_org_information_id             IN  NUMBER
  ,p_org_info_type_code             IN  VARCHAR2
  ,p_org_information1               IN  VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_org_information2               IN  VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_org_information3               IN  VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_org_information4               IN  VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_org_information5               IN  VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_org_information6               IN  VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_org_information7               IN  VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_org_information8               IN  VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_org_information9               IN  VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_org_information10              IN  VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_org_information11              IN  VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_org_information12              IN  VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_org_information13              IN  VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_org_information14              IN  VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_org_information15              IN  VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_org_information16              IN  VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_org_information17              IN  VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_org_information18              IN  VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_org_information19              IN  VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_org_information20              IN  VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_attribute_category             IN  VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_attribute1                     IN  VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_attribute2                     IN  VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_attribute3                     IN  VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_attribute4                     IN  VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_attribute5                     IN  VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_attribute6                     IN  VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_attribute7                     IN  VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_attribute8                     IN  VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_attribute9                     IN  VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_attribute10                    IN  VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_attribute11                    IN  VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_attribute12                    IN  VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_attribute13                    IN  VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_attribute14                    IN  VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_attribute15                    IN  VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_attribute16                    IN  VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_attribute17                    IN  VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_attribute18                    IN  VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_attribute19                    IN  VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_attribute20                    IN  VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_object_version_number          IN OUT NOCOPY NUMBER
 );
--
-- ----------------------------------------------------------------------------
-- |----------------------------< update_org_manager >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates an organization manager relationship.
 *
 * This API updates an information type for a Cost Center Manager Relationship
 * of an existing organization. Information types are stored in the table
 * HR_ORGANIZATION_INFORMATION.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources and HR Foundation.
 *
 * <p><b>Prerequisites</b><br>
 * Organization should exist.
 *
 * <p><b>Post Success</b><br>
 * Organization manager relationship gets updated.
 *
 * <p><b>Post Failure</b><br>
 * The API does not update the organization manager relationship, and raises an
 * error
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_organization_id Uniquely identifies the organization associated
 * with the organization manager relationship the process updates.
 * @param p_org_information_id Uniquely identifies the organization
 * information.
 * @param p_org_info_type_code The organization information type code -
 * 'Organization Name Alias
 * @param p_org_information1 Segment1 for p_org_info_type_code.
 * @param p_org_information2 Uniquely identifies the person (manager) for whom
 * the process updates cost center manager information.
 * @param p_org_information3 The date the organization manager relationship
 * takes effect.
 * @param p_org_information4 The date the organization manager relationship is
 * no longer in effect.
 * @param p_org_information5 Segment5 for p_org_info_type_code.
 * @param p_org_information6 Segment6 for p_org_info_type_code.
 * @param p_org_information7 Segment7 for p_org_info_type_code.
 * @param p_org_information8 Segment8 for p_org_info_type_code.
 * @param p_org_information9 Segment9 for p_org_info_type_code.
 * @param p_org_information10 Segment10 for p_org_info_type_code.
 * @param p_org_information11 Segment11 for p_org_info_type_code.
 * @param p_org_information12 Segment12 for p_org_info_type_code.
 * @param p_org_information13 Segment13 for p_org_info_type_code.
 * @param p_org_information14 Segment14 for p_org_info_type_code.
 * @param p_org_information15 Segment15 for p_org_info_type_code.
 * @param p_org_information16 Segment16 for p_org_info_type_code.
 * @param p_org_information17 Segment17 for p_org_info_type_code.
 * @param p_org_information18 Segment18 for p_org_info_type_code.
 * @param p_org_information19 Segment19 for p_org_info_type_code.
 * @param p_org_information20 Segment20 for p_org_info_type_code.
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
 * @param p_object_version_number Pass in the current version number of the
 * organization manager relationship record to be updated. When the API
 * completes if p_validate is false, will be set to the new version number of
 * the updated organization manager relationship. If p_validate is true will be
 * set to the same value which was passed in.
 * @param p_warning Set to true if a gap exists in the continuity of effective
 * dates for associated Cost Center Manager Relationships.
 * @rep:displayname Update Cost Center Manager
 * @rep:category BUSINESS_ENTITY HR_COST_CENTER
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
PROCEDURE update_org_manager
   (  p_validate                       IN  BOOLEAN   DEFAULT false
     ,p_effective_date                 IN  DATE
     ,p_organization_id                IN  NUMBER
     ,p_org_information_id             IN  NUMBER
     ,p_org_info_type_code             IN  VARCHAR2
     ,p_org_information1               IN  VARCHAR2 DEFAULT hr_api.g_varchar2
     ,p_org_information2               IN  VARCHAR2 DEFAULT hr_api.g_varchar2
     ,p_org_information3               IN  VARCHAR2 DEFAULT hr_api.g_varchar2
     ,p_org_information4               IN  VARCHAR2 DEFAULT hr_api.g_varchar2
     ,p_org_information5               IN  VARCHAR2 DEFAULT hr_api.g_varchar2
     ,p_org_information6               IN  VARCHAR2 DEFAULT hr_api.g_varchar2
     ,p_org_information7               IN  VARCHAR2 DEFAULT hr_api.g_varchar2
     ,p_org_information8               IN  VARCHAR2 DEFAULT hr_api.g_varchar2
     ,p_org_information9               IN  VARCHAR2 DEFAULT hr_api.g_varchar2
     ,p_org_information10              IN  VARCHAR2 DEFAULT hr_api.g_varchar2
     ,p_org_information11              IN  VARCHAR2 DEFAULT hr_api.g_varchar2
     ,p_org_information12              IN  VARCHAR2 DEFAULT hr_api.g_varchar2
     ,p_org_information13              IN  VARCHAR2 DEFAULT hr_api.g_varchar2
     ,p_org_information14              IN  VARCHAR2 DEFAULT hr_api.g_varchar2
     ,p_org_information15              IN  VARCHAR2 DEFAULT hr_api.g_varchar2
     ,p_org_information16              IN  VARCHAR2 DEFAULT hr_api.g_varchar2
     ,p_org_information17              IN  VARCHAR2 DEFAULT hr_api.g_varchar2
     ,p_org_information18              IN  VARCHAR2 DEFAULT hr_api.g_varchar2
     ,p_org_information19              IN  VARCHAR2 DEFAULT hr_api.g_varchar2
     ,p_org_information20              IN  VARCHAR2 DEFAULT hr_api.g_varchar2
     ,p_attribute_category             IN  VARCHAR2 DEFAULT hr_api.g_varchar2
     ,p_attribute1                     IN  VARCHAR2 DEFAULT hr_api.g_varchar2
     ,p_attribute2                     IN  VARCHAR2 DEFAULT hr_api.g_varchar2
     ,p_attribute3                     IN  VARCHAR2 DEFAULT hr_api.g_varchar2
     ,p_attribute4                     IN  VARCHAR2 DEFAULT hr_api.g_varchar2
     ,p_attribute5                     IN  VARCHAR2 DEFAULT hr_api.g_varchar2
     ,p_attribute6                     IN  VARCHAR2 DEFAULT hr_api.g_varchar2
     ,p_attribute7                     IN  VARCHAR2 DEFAULT hr_api.g_varchar2
     ,p_attribute8                     IN  VARCHAR2 DEFAULT hr_api.g_varchar2
     ,p_attribute9                     IN  VARCHAR2 DEFAULT hr_api.g_varchar2
     ,p_attribute10                    IN  VARCHAR2 DEFAULT hr_api.g_varchar2
     ,p_attribute11                    IN  VARCHAR2 DEFAULT hr_api.g_varchar2
     ,p_attribute12                    IN  VARCHAR2 DEFAULT hr_api.g_varchar2
     ,p_attribute13                    IN  VARCHAR2 DEFAULT hr_api.g_varchar2
     ,p_attribute14                    IN  VARCHAR2 DEFAULT hr_api.g_varchar2
     ,p_attribute15                    IN  VARCHAR2 DEFAULT hr_api.g_varchar2
     ,p_attribute16                    IN  VARCHAR2 DEFAULT hr_api.g_varchar2
     ,p_attribute17                    IN  VARCHAR2 DEFAULT hr_api.g_varchar2
     ,p_attribute18                    IN  VARCHAR2 DEFAULT hr_api.g_varchar2
     ,p_attribute19                    IN  VARCHAR2 DEFAULT hr_api.g_varchar2
     ,p_attribute20                    IN  VARCHAR2 DEFAULT hr_api.g_varchar2
     ,p_object_version_number          IN OUT NOCOPY NUMBER
     ,p_warning                        OUT NOCOPY BOOLEAN);
--
-- ----------------------------------------------------------------------------
-- |----------------------------< delete_org_manager >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes an organization manager relationship.
 *
 * This API deletes an information type for a Cost Center Manager Relationship
 * of an existing organization. Information types are stored in the table
 * HR_ORGANIZATION_INFORMATION.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources and HR Foundation.
 *
 * <p><b>Prerequisites</b><br>
 * Organization manager relationship should exist.
 *
 * <p><b>Post Success</b><br>
 * Organization manager relationship is successfully deleted.
 *
 * <p><b>Post Failure</b><br>
 * The API does not delete the organization manager relationship, and raises an
 * error
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_org_information_id Identifies the organization manager relationship
 * record to delete.
 * @param p_object_version_number Current version number of the organization
 * manager relationship to be deleted.
 * @rep:displayname Delete Cost Center Manager
 * @rep:category BUSINESS_ENTITY HR_COST_CENTER
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
PROCEDURE delete_org_manager
   (  p_validate                       IN  BOOLEAN   DEFAULT false
     ,p_org_information_id             IN  NUMBER
     ,p_object_version_number          IN OUT NOCOPY NUMBER);
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_business_group >-----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a business group.
 *
 * This API creates a new business group. This API is MLS enabled, and there is
 * one translated column (NAME). Organizations are stored in the table
 * HR_ALL_ORGANIZATION_UNITS. The translated columns are stored in the table
 * HR_ALL_ORGANIZATION_UNITS_TL.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources and HR Foundation.
 *
 * <p><b>Prerequisites</b><br>
 * None
 *
 * <p><b>Post Success</b><br>
 * Organization with the classification of Business Group is created.
 *
 * <p><b>Post Failure</b><br>
 * The API does not create the organization, and raises an error
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_language_code Specifies to which language the translation values
 * apply. You can set to the base or any installed language. The default value
 * of hr_api.userenv_lang is equivalent to the RDBMS userenv('LANG') function
 * value.
 * @param p_date_from Date the organization takes effect.
 * @param p_name The business group name (translated).
 * @param p_type The organization type associated with the organization the
 * process creates. Valid values are determined by the ORG_TYPE lookup type.
 * @param p_internal_external_flag Flag specifying if the organization is an
 * internal or external organization.
 * @param p_location_id Uniquely identifies the location of the organization.
 * @param p_short_name The business group short name
 * @param p_emp_gen_method Employee number generation method. Valid values are
 * 'A' (Automatic) and 'M' (Manual).
 * @param p_app_gen_method Applicant number generation method. Valid values are
 * 'A' (Automatic) and 'M' (Manual).
 * @param p_cwk_gen_method Contingent Worker number generation method. Valid
 * values are 'A' (Automatic), 'M' (Manual), and 'E' (same as employee number).
 * @param p_grade_flex_id Uniquely identifies the Grade key flexfield.
 * @param p_group_flex_id Uniquely identifies the People Group key flexfield.
 * @param p_job_flex_id Uniquely identifies the Job key flexfield.
 * @param p_cost_flex_id Uniquely identifies the Cost Allocation key flexfield.
 * @param p_position_flex_id Uniquely identifies the Position key flexfield.
 * @param p_legislation_code The Legislation Code
 * @param p_currency_code The Currency Code
 * @param p_fiscal_year_start Start of Fiscal year
 * @param p_min_work_age Minimum Work Age
 * @param p_max_work_age Maximum Working Age
 * @param p_sec_group_id Security group ID
 * @param p_competence_flex_id Uniquely identifies the Competence key
 * flexfield.
 * @param p_organization_id If p_validate is false, then this uniquely
 * identifies the business group created. If p_validate is true, then set to
 * null..
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created business group. If p_validate is true, then
 * the value will be null.
 * @rep:displayname Create Business Group
 * @rep:category BUSINESS_ENTITY HR_BUSINESS_GROUP
 * @rep:category MISC_EXTENSIONS HR_DATAPUMP
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
PROCEDURE create_business_group
   (  p_validate                       IN  BOOLEAN   DEFAULT false
     ,p_effective_date                 IN  DATE
     ,p_language_code                  IN  VARCHAR2  DEFAULT hr_api.userenv_lang
--
     ,p_date_from                      IN  DATE
     ,p_name                           IN  VARCHAR2
     ,p_type                           IN  VARCHAR2
     ,p_internal_external_flag         IN  VARCHAR2
     ,p_location_id                    IN  NUMBER
     ,p_short_name                     IN  VARCHAR2
     ,p_emp_gen_method                 IN  VARCHAR2
     ,p_app_gen_method                 IN  VARCHAR2
     ,p_cwk_gen_method                 IN  VARCHAR2
     ,p_grade_flex_id                  IN  VARCHAR2
     ,p_group_flex_id                  IN  VARCHAR2
     ,p_job_flex_id                    IN  VARCHAR2
     ,p_cost_flex_id                   IN  VARCHAR2
     ,p_position_flex_id               IN  VARCHAR2
     ,p_legislation_code               IN  VARCHAR2
     ,p_currency_code                  IN  VARCHAR2
     ,p_fiscal_year_start              IN  VARCHAR2
     ,p_min_work_age                   IN  VARCHAR2
     ,p_max_work_age                   IN  VARCHAR2
     ,p_sec_group_id                   IN  VARCHAR2
     ,p_competence_flex_id             IN  VARCHAR2
     ,p_organization_id                OUT NOCOPY NUMBER
     ,p_object_version_number          OUT NOCOPY NUMBER
 );
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_operating_unit >-----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a new Operating Unit within an existing Business group.
 *
 * The API is MLS enabled, and there is one translated column (NAME).
 * Organizations are stored in the table HR_ALL_ORGANIZATION_UNITS. The
 * translated columns are stored in the table HR_ALL_ORGANIZATION_UNITS_TL.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources and HR Foundation.
 *
 * <p><b>Prerequisites</b><br>
 * Business group should exist.
 *
 * <p><b>Post Success</b><br>
 * Operating unit gets successfully created.
 *
 * <p><b>Post Failure</b><br>
 * Operating unit is not created and returns an error.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_language_code Specifies to which language the translation values
 * apply. You can set to the base or any installed language. The default value
 * of hr_api.userenv_lang is equivalent to the RDBMS userenv('LANG') function
 * value.
 * @param p_business_group_id Uniquely identifies the business group associated
 * with the operating unit the process creates.
 * @param p_date_from Date the operating unit takes effect.
 * @param p_name The name of the operating unit.
 * @param p_type The organization type associated with the operating unit the
 * process creates. Valid values are determined by the ORG_TYPE lookup type.
 * @param p_internal_external_flag Flag specifying if the organization is an
 * internal or external organization.
 * @param p_location_id Uniquely identifies the location of the operating unit
 * the process creates.
 * @param p_set_of_books_id Uniquely identifies the ledger associated
 * with the operating unit the process creates.
 * @param p_organization_id If p_validate is false, then this uniquely
 * identifies the operating unit created. If p_validate is true, then set to
 * null..
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the operating unit created. If p_validate is true, then
 * set to null..
 * @param p_legal_entity_id Uniquely identifies the legal entity associated
 * with the operating unit.
 * @param p_short_code Operating unit short code.
 * @rep:displayname Create Operating Unit
 * @rep:category BUSINESS_ENTITY HR_OPERATING_UNIT
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--

PROCEDURE create_operating_unit
   (  p_validate                       IN  BOOLEAN   DEFAULT false
     ,p_effective_date                 IN  DATE
     ,p_language_code                  IN  VARCHAR2  DEFAULT hr_api.userenv_lang
--
     ,p_business_group_id              IN  NUMBER
     ,p_date_from                      IN  DATE
     ,p_name                           IN  VARCHAR2
     ,p_type                           IN  VARCHAR2
     ,p_internal_external_flag         IN  VARCHAR2
     ,p_location_id                    IN  NUMBER
     ,p_set_of_books_id                IN  VARCHAR2
-- Added p_legal_entity_id for bug 41281871
     ,p_legal_entity_id                IN  VARCHAR2 DEFAULT null
-- Added p_short_code for bug 4526439
     ,p_short_code                     IN  VARCHAR2 DEFAULT null
     ,p_organization_id                OUT NOCOPY NUMBER
     ,p_object_version_number          OUT NOCOPY NUMBER
 );
--
--
-- ----------------------------------------------------------------------------
-- |---------------------------< get_operating_unit >----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--    This function returns operating unit for a given person when provided
--    with only one of the following parameters of person_id,assignment_id
--    or organization_id.
--
--
function get_operating_unit
(
   p_effective_date                 IN  DATE
  ,p_person_id                      IN  NUMBER DEFAULT NULL
  ,p_assignment_id                  IN  NUMBER DEFAULT NULL
  ,p_organization_id                IN  NUMBER DEFAULT NULL
 ) return number;
--
--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_operating_unit >-----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates a new operating unit starting with existing
 * business group.  The API is MLS enabled, and there is
 * one translated column: NAME.
 *
 * Organizations are updated on the HR_ALL_ORGANIZATION_UNITS table.
 * The translated columns are stored on the
 * HR_ALL_ORGANIZATION_UNITS_TL table.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources and HR Foundation.
 *
 * <p><b>Prerequisites</b><br>
 * Operating should exists for the Business group
 *
 * <p><b>Post Success</b><br>
 * Operating unit gets successfully Updated.
 *
 * <p><b>Post Failure</b><br>
 * Operating unit is not updated and returns an error.
 *
 * @param p_validate If true, then validation alone will be performed and
 * the database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_organization_id Uniquely identifies the operating unit.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range and used for
 * date_track validation.
 * @param p_language_code Specifies to which language the translation
 * values apply. You can set to the base or any installed language. The default
 * value of hr_api.userenv_lang is equivalent to the RDBMS userenv('LANG')
 * function value.
 * @param p_date_from Date the operating unit takes effect.
 * @param p_name The name of the operating unit.
 * @param p_type The organization type associated with the operating unit the
 * process creates. Valid values are determined by the ORG_TYPE lookup type.
 * @param p_internal_external_flag Flag specifying if the organization is an
 * internal or external organization.
 * @param p_location_id Uniquely identifies the location of the operating unit.
 * @param p_set_of_books_id Uniquely identifies the ledger associated
 * with the operating unit.
 * @param p_usable_flag Marks the operating unit usable when null is passed.
 * @param p_short_code Operating unit short code.
 * @param p_legal_entity_id Uniquely identifies the legal entity associated
 * with the operating unit.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the operating unit updated. If p_validate is true, then
 * set to the same value which was passed in.
 * @param p_update_prim_ledger_warning Used to raise warning.
 * @param p_duplicate_org_warning The value is 'true' if an organization
 * already exists with the same name in a different business group. (If the
 * duplicate is in the same business group, the process raises an error.)
 * @rep:displayname Update Operating Unit
 * @rep:category BUSINESS_ENTITY HR_OPERATING_UNIT
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
PROCEDURE update_operating_unit
(
      p_validate                          IN  BOOLEAN  DEFAULT false
     ,p_organization_id                   IN  NUMBER
     ,p_effective_date                    IN  DATE
     ,p_language_code                     IN  VARCHAR2 DEFAULT hr_api.userenv_lang
     ,p_date_from                         IN  DATE     DEFAULT hr_api.g_date
     ,p_name                              IN  VARCHAR2 DEFAULT hr_api.g_varchar2
     ,p_type                              IN  VARCHAR2 DEFAULT hr_api.g_varchar2
     ,p_internal_external_flag            IN  VARCHAR2 DEFAULT hr_api.g_varchar2
     ,p_location_id                       IN  NUMBER   DEFAULT hr_api.g_number
     ,p_set_of_books_id                   IN  VARCHAR2 DEFAULT hr_api.g_varchar2
     ,p_usable_flag                       IN  VARCHAR2 DEFAULT hr_api.g_varchar2
-- Added p_short_code for bug 4526439
     ,p_short_code                        IN  VARCHAR2 DEFAULT hr_api.g_varchar2
     ,p_legal_entity_id                   IN  VARCHAR2 DEFAULT hr_api.g_varchar2
     ,p_object_version_number		  IN  OUT NOCOPY NUMBER
     ,p_update_prim_ledger_warning        OUT NOCOPY BOOLEAN
     ,p_duplicate_org_warning             OUT NOCOPY BOOLEAN
 );

--
--
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_legal_entity >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates an organization with a classification of legal entity.
 *
 * The API is MLS enabled, and there is one translated column (NAME).
 * Organizations are stored in the table HR_ALL_ORGANIZATION_UNITS. The
 * translated columns are stored in the table HR_ALL_ORGANIZATION_UNITS_TL.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources and HR Foundation.
 *
 * <p><b>Prerequisites</b><br>
 * Business group should exist.
 *
 * <p><b>Post Success</b><br>
 * An organization with a classification of legal entity is created.
 *
 * <p><b>Post Failure</b><br>
 * The API does not create the organization, and raises an error.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_language_code Specifies to which language the translation values
 * apply. You can set to the base or any installed language. The default value
 * of hr_api.userenv_lang is equivalent to the RDBMS userenv('LANG') function
 * value.
 * @param p_business_group_id Uniquely identifies the business group associated
 * with the legal entity the process creates.
 * @param p_date_from Date the legal entity takes effect.
 * @param p_name Name of the legal entity
 * @param p_type The organization type associated with the legal entity the
 * process creates. Valid values are determined by the ORG_TYPE lookup type.
 * @param p_internal_external_flag Flag specifying if the organization is an
 * internal or external organization.
 * @param p_location_id Uniquely identifies the location of the legal entity
 * the process creates.
 * @param p_set_of_books_id ledger id.
 * @param p_organization_id If p_validate is false, then this uniquely
 * identifies the legal entity created. If p_validate is true, then set to
 * null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the legal entity created. If p_validate is true, then set
 * to null..
 * @rep:displayname Create Legal Entity
 * @rep:category BUSINESS_ENTITY HR_LEGAL_ENTITY
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--

PROCEDURE create_legal_entity
   (  p_validate                       IN  BOOLEAN   DEFAULT false
     ,p_effective_date                 IN  DATE
     ,p_language_code                  IN  VARCHAR2  DEFAULT hr_api.userenv_lang
--
     ,p_business_group_id              IN  NUMBER
     ,p_date_from                      IN  DATE
     ,p_name                           IN  VARCHAR2
     ,p_type                           IN  VARCHAR2
     ,p_internal_external_flag         IN  VARCHAR2
     ,p_location_id                    IN  NUMBER
     ,p_set_of_books_id                IN  VARCHAR2
     ,p_organization_id                OUT NOCOPY NUMBER
     ,p_object_version_number          OUT NOCOPY NUMBER
 );
--
-- ----------------------------------------------------------------------------
-- |----------------------------< create_bgr_classif >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a new classification for an existing business group, namely
 * operating unit and legal entity accounting.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources and HR Foundation.
 *
 * <p><b>Prerequisites</b><br>
 * Business group exists.
 *
 * <p><b>Post Success</b><br>
 * operating unit and legal entity accounting classification added to an
 * existing business group.
 *
 * <p><b>Post Failure</b><br>
 * operating unit and legal entity accounting classification not added to an
 * existing business group, and raises an error.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_business_group_id Uniquely identifies the business group associated
 * with the business group classification the process creates.
 * @param p_set_of_books_id Uniquely identifies the ledger associated
 * with the business group classification the process creates.
 * @rep:displayname Create Business Group Classification
 * @rep:category BUSINESS_ENTITY HR_ORGANIZATION
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
PROCEDURE create_bgr_classif
   (  p_validate                       IN  BOOLEAN   DEFAULT false
     ,p_effective_date                 IN  DATE
--
     ,p_business_group_id              IN  NUMBER
     ,p_set_of_books_id                IN  VARCHAR2
 );
--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_legal_entity_classif >--------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a Legal Entity Classification for an existing Organization
 * and populates information type data.
 *
 * Organizations are stored in the table HR_ALL_ORGANIZATION_UNITS.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources and HR Foundation.
 *
 * <p><b>Prerequisites</b><br>
 * Organization ID should exist.
 *
 * <p><b>Post Success</b><br>
 * The process successfully inserts the legal entity classification.
 *
 * <p><b>Post Failure</b><br>
 * The API does not create the legal entity classification and raises an error.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_organization_id Uniquely identifies the organization associated
 * with the legal entity classification the process creates.
 * @param p_set_of_books_id Uniquely identifies the ledger associated
 * with the legal entity classification the process creates.
 * @rep:displayname Create Legal Entity Classification
 * @rep:category BUSINESS_ENTITY HR_ORGANIZATION
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--

PROCEDURE create_legal_entity_classif
   (  p_validate                       IN  BOOLEAN   DEFAULT false
     ,p_effective_date                 IN  DATE
--
     ,p_organization_id                IN  NUMBER
     ,p_set_of_books_id                IN  VARCHAR2
 );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_oper_unit_classif >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates an Operating Unit classification for an existing
 * organization.
 *
 * This API creates new classification for existing organization and populates
 * information type data. Organizations are stored in the table
 * HR_ALL_ORGANIZATION_UNITS.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources and HR Foundation.
 *
 * <p><b>Prerequisites</b><br>
 * Organization should exist.
 *
 * <p><b>Post Success</b><br>
 * When the process has successfully inserted the operating unit
 * classification, the process sets the OUT parameters.
 *
 * <p><b>Post Failure</b><br>
 * The API does not create the operating unit classification and raises error.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_organization_id Uniquely identifies the organization associated
 * with the operating unit classification the process creates.
 * @param p_legal_entity_id Uniquely identifies the legal entity associated
 * with the operating unit classification the process creates.
 * @param p_set_of_books_id Uniquely identifies the ledger associated
 * with the operating unit classification the process creates.
 * @param p_oper_unit_short_code Operating Unit Short Code.
 * @rep:displayname Create Operating Unit Classification
 * @rep:category BUSINESS_ENTITY HR_ORGANIZATION
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
PROCEDURE create_oper_unit_classif
   (  p_validate                       IN  BOOLEAN   DEFAULT false
     ,p_effective_date                 IN  DATE
--
     ,p_organization_id                IN  NUMBER
     ,p_legal_entity_id                IN  VARCHAR2
     ,p_set_of_books_id                IN  VARCHAR2
     ,p_oper_unit_short_code           IN  VARCHAR2 DEFAULT null  --- Fix For Bug # 7439707
 );
--
-- ----------------------------------------------------------------------------
-- |------------------------------< trans_org_name >--------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API translates an organization name.
 *
 * This API translates an organization name into a specified language. The API
 * is MLS enabled, and there is one translated column (NAME). The translated
 * column is stored in the table HR_ALL_ORGANIZATION_UNITS_TL.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with HR Foundation.
 *
 * <p><b>Prerequisites</b><br>
 * Oragnization should exist.
 *
 * <p><b>Post Success</b><br>
 * When the organization name has been successfully translated, the following
 * OUT parameters are set:
 *
 * <p><b>Post Failure</b><br>
 * The API does not translate the organization name, and raises an error
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_language_code Specifies to which language the translation values
 * apply. You can set to the base or any installed language. The default value
 * of hr_api.userenv_lang is equivalent to the RDBMS userenv('LANG') function
 * value.
 * @param p_organization_id Uniquely identifies the organization whose name the
 * process translates.
 * @param p_name The organization name (translated)
 * @rep:displayname Translate Organization Name
 * @rep:category BUSINESS_ENTITY HR_ORGANIZATION
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
PROCEDURE trans_org_name
   (  p_validate                       IN  BOOLEAN   DEFAULT false
     ,p_effective_date                 IN  DATE
     ,p_language_code                  IN  VARCHAR2  DEFAULT hr_api.userenv_lang
--
     ,p_organization_id                IN  NUMBER
     ,p_name                           IN  VARCHAR2
 );
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_company_cost_center >--------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API adds an organization classification of Company Cost Center.
 *
 * This API creates new Company Cost Center classification for an existing
 * organization and populates information type data. Organizations are stored
 * in the table HR_ALL_ORGANIZATION_UNITS.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * Organization should exist.
 *
 * <p><b>Post Success</b><br>
 * Company cost center is successfully created.
 *
 * <p><b>Post Failure</b><br>
 * The API does not create the organization classification and org information
 * and raises an error
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_organization_id Uniquely identifies the organization associated
 * with the classification and information the process creates.
 * @param p_company_valueset_id maps onto org_information2
 * @param p_company maps onto org_information3
 * @param p_costcenter_valueset_id maps onto org_information4
 * @param p_costcenter maps onto org_information5
 * @param p_ori_org_information_id Uniquely identifies the org classification
 * of 'CC'.
 * @param p_ori_object_version_number If p_validate is false, then set to the
 * version number of the organization classification ('CC') record created. If
 * p_validate is true, then the value will be null.
 * @param p_org_information_id Uniquely identifies the 'Company Cost Center'
 * organization information the process creates.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the Organization Classification created. If p_validate is
 * true, then set to null.
 * @rep:displayname Create Company Cost Center
 * @rep:category BUSINESS_ENTITY HR_COST_CENTER
 * @rep:category MISC_EXTENSIONS HR_DATAPUMP
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--

PROCEDURE create_company_cost_center
   (  p_validate                       IN  BOOLEAN   DEFAULT false
     ,p_effective_date                 IN  DATE
     ,p_organization_id                IN  NUMBER
     ,p_company_valueset_id            IN  NUMBER DEFAULT null
     ,p_company                        IN  VARCHAR2 DEFAULT null
     ,p_costcenter_valueset_id         IN  NUMBER DEFAULT null
     ,p_costcenter                     IN  VARCHAR2 DEFAULT null
     ,p_ori_org_information_id         OUT NOCOPY NUMBER
     ,p_ori_object_version_number      OUT NOCOPY NUMBER
     ,p_org_information_id             OUT NOCOPY NUMBER
     ,p_object_version_number          OUT NOCOPY NUMBER
   );
--
--
--------------------------------------------------------------------------------
PROCEDURE set_translation_globals(p_business_group_id IN NUMBER,
              p_legislation_code IN VARCHAR2);
--------------------------------------------------------------------------------
--
--
PROCEDURE create_org_class_internal
  (   p_validate                       IN  BOOLEAN   DEFAULT false
     ,p_effective_date                 IN  DATE
     ,p_organization_id                IN  NUMBER
     ,p_org_classif_code               IN  VARCHAR2
     ,p_classification_enabled         IN  VARCHAR2  DEFAULT 'Y' -- Bug 3456540
     ,p_org_information_id        OUT nocopy NUMBER
     ,p_object_version_number          OUT nocopy NUMBER
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------< create_not_usable_ou_internal >-------------------|
-- ----------------------------------------------------------------------------
-- This API creates a default or not usable Operating Unit.
PROCEDURE create_not_usable_ou_internal
          (p_validate               IN        BOOLEAN  DEFAULT FALSE
          ,p_effective_date         IN        DATE
          ,p_language_code          IN        VARCHAR2 DEFAULT HR_API.userenv_lang
          ,p_business_group_id      IN        NUMBER
          ,p_date_from              IN        DATE
          ,p_name                   IN        VARCHAR2
          ,p_type                   IN        VARCHAR2
          ,p_internal_external_flag IN        VARCHAR2
          ,p_location_id            IN        NUMBER
          ,p_ledger_id              IN        VARCHAR2 DEFAULT NULL
          ,p_default_legal_context  IN        VARCHAR2 DEFAULT NULL
          ,p_short_code             IN        VARCHAR2 DEFAULT NULL
          ,p_organization_id       OUT NOCOPY NUMBER
          ,p_object_version_number OUT NOCOPY NUMBER );
--
END hr_organization_api;
--
--

/
