--------------------------------------------------------
--  DDL for Package IRC_DEFAULT_POSTING_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_DEFAULT_POSTING_API" AUTHID CURRENT_USER as
/* $Header: iridpapi.pkh 120.2 2008/02/21 14:12:57 viviswan noship $ */
/*#
 * This package contains Default Posting APIs.
 * @rep:scope public
 * @rep:product irc
 * @rep:displayname Default Posting
*/
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_default_posting >----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a Default Posting.
 *
 * Default postings will be used to populate job postings when a vacancy is
 * created.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with iRecruitment.
 *
 * <p><b>Prerequisites</b><br>
 * The position, job or organization must already exist
 *
 * <p><b>Post Success</b><br>
 * The default posting will be created in the database
 *
 * <p><b>Post Failure</b><br>
 * The default posting will not be created in the database and an error will be
 * raised
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_language_code Specifies to which language the translation values
 * apply. You can set to the base or any installed language. The default value
 * of hr_api.userenv_lang is equivalent to the RDBMS userenv('LANG') function
 * value.
 * @param p_position_id The position which the default posting is for
 * @param p_job_id The job which the default posting is for
 * @param p_organization_id The organization which the default posting is for
 * @param p_org_name The default advertised organization name
 * @param p_org_description The default advertised organization description
 * @param p_job_title The default advertised job title
 * @param p_brief_description The default advertised brief description
 * @param p_detailed_description The default advertised detailed description
 * @param p_job_requirements The default advertised job requirements
 * @param p_additional_details The default advertised additional details
 * @param p_how_to_apply The default apply instructions
 * @param p_image_url The default URL for an image to accompany the advert
 * @param p_image_url_alt The default alternative text for an image to
 * accompany the advert
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
 * @param p_default_posting_id If p_validate is false, then this uniquely
 * identifies the default posting created. If p_validate is true, then set to
 * null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created default posting. If p_validate is true, then
 * the value will be null.
 * @rep:displayname Create Default Posting
 * @rep:category BUSINESS_ENTITY IRC_DEFAULT_JOB_POSTING
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_default_posting
(P_VALIDATE                   IN  BOOLEAN    default FALSE
,P_LANGUAGE_CODE              IN  VARCHAR2   default hr_api.userenv_lang
,P_POSITION_ID                IN  NUMBER     default NULL
,P_JOB_ID                     IN  NUMBER     default NULL
,P_ORGANIZATION_ID            IN  NUMBER     default NULL
,P_ORG_NAME                   IN  VARCHAR2   default NULL
,P_ORG_DESCRIPTION            IN  VARCHAR2   default NULL
,P_JOB_TITLE                  IN  VARCHAR2   default NULL
,P_BRIEF_DESCRIPTION          IN  VARCHAR2   default NULL
,P_DETAILED_DESCRIPTION       IN  VARCHAR2   default NULL
,P_JOB_REQUIREMENTS           IN  VARCHAR2   default NULL
,P_ADDITIONAL_DETAILS         IN  VARCHAR2   default NULL
,P_HOW_TO_APPLY               IN  VARCHAR2   default NULL
,P_IMAGE_URL                  IN  VARCHAR2   default NULL
,P_IMAGE_URL_ALT              IN  VARCHAR2   default NULL
,P_ATTRIBUTE_CATEGORY         IN  VARCHAR2   default NULL
,P_ATTRIBUTE1                 IN  VARCHAR2   default NULL
,P_ATTRIBUTE2                 IN  VARCHAR2   default NULL
,P_ATTRIBUTE3                 IN  VARCHAR2   default NULL
,P_ATTRIBUTE4                 IN  VARCHAR2   default NULL
,P_ATTRIBUTE5                 IN  VARCHAR2   default NULL
,P_ATTRIBUTE6                 IN  VARCHAR2   default NULL
,P_ATTRIBUTE7                 IN  VARCHAR2   default NULL
,P_ATTRIBUTE8                 IN  VARCHAR2   default NULL
,P_ATTRIBUTE9                 IN  VARCHAR2   default NULL
,P_ATTRIBUTE10                IN  VARCHAR2   default NULL
,P_ATTRIBUTE11                IN  VARCHAR2   default NULL
,P_ATTRIBUTE12                IN  VARCHAR2   default NULL
,P_ATTRIBUTE13                IN  VARCHAR2   default NULL
,P_ATTRIBUTE14                IN  VARCHAR2   default NULL
,P_ATTRIBUTE15                IN  VARCHAR2   default NULL
,P_ATTRIBUTE16                IN  VARCHAR2   default NULL
,P_ATTRIBUTE17                IN  VARCHAR2   default NULL
,P_ATTRIBUTE18                IN  VARCHAR2   default NULL
,P_ATTRIBUTE19                IN  VARCHAR2   default NULL
,P_ATTRIBUTE20                IN  VARCHAR2   default NULL
,P_ATTRIBUTE21                IN  VARCHAR2   default NULL
,P_ATTRIBUTE22                IN  VARCHAR2   default NULL
,P_ATTRIBUTE23                IN  VARCHAR2   default NULL
,P_ATTRIBUTE24                IN  VARCHAR2   default NULL
,P_ATTRIBUTE25                IN  VARCHAR2   default NULL
,P_ATTRIBUTE26                IN  VARCHAR2   default NULL
,P_ATTRIBUTE27                IN  VARCHAR2   default NULL
,P_ATTRIBUTE28                IN  VARCHAR2   default NULL
,P_ATTRIBUTE29                IN  VARCHAR2   default NULL
,P_ATTRIBUTE30                IN  VARCHAR2   default NULL
,P_DEFAULT_POSTING_ID         OUT NOCOPY NUMBER
,P_OBJECT_VERSION_NUMBER      OUT NOCOPY NUMBER
);
--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_default_posting >----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates a Default Posting.
 *
 * Default postings will be used to populate job postings when a vacancy is
 * created.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with iRecruitment.
 *
 * <p><b>Prerequisites</b><br>
 * The default posting must exist in the database
 *
 * <p><b>Post Success</b><br>
 * The default posting will be updated in the database
 *
 * <p><b>Post Failure</b><br>
 * The default posting will not be updated in the database and an error will be
 * raised
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_language_code Specifies to which language the translation values
 * apply. You can set to the base or any installed language. The default value
 * of hr_api.userenv_lang is equivalent to the RDBMS userenv('LANG') function
 * value.
 * @param p_default_posting_id Identifies the default posting to be modified
 * @param p_position_id The position which the default posting is for
 * @param p_job_id The job which the default posting is for
 * @param p_organization_id The organization which the default posting is for
 * @param p_org_name The default advertised organization name
 * @param p_org_description The default advertised organization description
 * @param p_job_title The default advertised job title
 * @param p_brief_description The default advertised brief description
 * @param p_detailed_description The default advertised detailed description
 * @param p_job_requirements The default advertised job requirements
 * @param p_additional_details The default advertised additional details
 * @param p_how_to_apply The default apply instructions
 * @param p_image_url The default URL for an image to accompany the advert
 * @param p_image_url_alt The default alternative text for an image to
 * accompany the advert
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
 * default posting to be updated. When the API completes if p_validate is
 * false, will be set to the new version number of the updated default posting.
 * If p_validate is true will be set to the same value which was passed in.
 * @rep:displayname Update Default Posting
 * @rep:category BUSINESS_ENTITY IRC_DEFAULT_JOB_POSTING
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_default_posting
(P_VALIDATE                   IN  BOOLEAN    default FALSE
,P_LANGUAGE_CODE              IN  VARCHAR2   default hr_api.userenv_lang
,P_DEFAULT_POSTING_ID         IN  NUMBER
,P_POSITION_ID                IN  NUMBER     default hr_api.g_number
,P_JOB_ID                     IN  NUMBER     default hr_api.g_number
,P_ORGANIZATION_ID            IN  NUMBER     default hr_api.g_number
,P_ORG_NAME                   IN  VARCHAR2   default hr_api.g_varchar2
,P_ORG_DESCRIPTION            IN  VARCHAR2   default hr_api.g_varchar2
,P_JOB_TITLE                  IN  VARCHAR2   default hr_api.g_varchar2
,P_BRIEF_DESCRIPTION          IN  VARCHAR2   default hr_api.g_varchar2
,P_DETAILED_DESCRIPTION       IN  VARCHAR2   default hr_api.g_varchar2
,P_JOB_REQUIREMENTS           IN  VARCHAR2   default hr_api.g_varchar2
,P_ADDITIONAL_DETAILS         IN  VARCHAR2   default hr_api.g_varchar2
,P_HOW_TO_APPLY               IN  VARCHAR2   default hr_api.g_varchar2
,P_IMAGE_URL                  IN  VARCHAR2   default hr_api.g_varchar2
,P_IMAGE_URL_ALT              IN  VARCHAR2   default hr_api.g_varchar2
,P_ATTRIBUTE_CATEGORY         IN  VARCHAR2   default hr_api.g_varchar2
,P_ATTRIBUTE1                 IN  VARCHAR2   default hr_api.g_varchar2
,P_ATTRIBUTE2                 IN  VARCHAR2   default hr_api.g_varchar2
,P_ATTRIBUTE3                 IN  VARCHAR2   default hr_api.g_varchar2
,P_ATTRIBUTE4                 IN  VARCHAR2   default hr_api.g_varchar2
,P_ATTRIBUTE5                 IN  VARCHAR2   default hr_api.g_varchar2
,P_ATTRIBUTE6                 IN  VARCHAR2   default hr_api.g_varchar2
,P_ATTRIBUTE7                 IN  VARCHAR2   default hr_api.g_varchar2
,P_ATTRIBUTE8                 IN  VARCHAR2   default hr_api.g_varchar2
,P_ATTRIBUTE9                 IN  VARCHAR2   default hr_api.g_varchar2
,P_ATTRIBUTE10                IN  VARCHAR2   default hr_api.g_varchar2
,P_ATTRIBUTE11                IN  VARCHAR2   default hr_api.g_varchar2
,P_ATTRIBUTE12                IN  VARCHAR2   default hr_api.g_varchar2
,P_ATTRIBUTE13                IN  VARCHAR2   default hr_api.g_varchar2
,P_ATTRIBUTE14                IN  VARCHAR2   default hr_api.g_varchar2
,P_ATTRIBUTE15                IN  VARCHAR2   default hr_api.g_varchar2
,P_ATTRIBUTE16                IN  VARCHAR2   default hr_api.g_varchar2
,P_ATTRIBUTE17                IN  VARCHAR2   default hr_api.g_varchar2
,P_ATTRIBUTE18                IN  VARCHAR2   default hr_api.g_varchar2
,P_ATTRIBUTE19                IN  VARCHAR2   default hr_api.g_varchar2
,P_ATTRIBUTE20                IN  VARCHAR2   default hr_api.g_varchar2
,P_ATTRIBUTE21                IN  VARCHAR2   default hr_api.g_varchar2
,P_ATTRIBUTE22                IN  VARCHAR2   default hr_api.g_varchar2
,P_ATTRIBUTE23                IN  VARCHAR2   default hr_api.g_varchar2
,P_ATTRIBUTE24                IN  VARCHAR2   default hr_api.g_varchar2
,P_ATTRIBUTE25                IN  VARCHAR2   default hr_api.g_varchar2
,P_ATTRIBUTE26                IN  VARCHAR2   default hr_api.g_varchar2
,P_ATTRIBUTE27                IN  VARCHAR2   default hr_api.g_varchar2
,P_ATTRIBUTE28                IN  VARCHAR2   default hr_api.g_varchar2
,P_ATTRIBUTE29                IN  VARCHAR2   default hr_api.g_varchar2
,P_ATTRIBUTE30                IN  VARCHAR2   default hr_api.g_varchar2
,P_OBJECT_VERSION_NUMBER      IN OUT NOCOPY NUMBER
);
--
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_default_posting >----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes a Default Posting.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with iRecruitment.
 *
 * <p><b>Prerequisites</b><br>
 * The default posting must exist in the database
 *
 * <p><b>Post Success</b><br>
 * The default posting will be deleted in the database
 *
 * <p><b>Post Failure</b><br>
 * The default posting will not be deleted in the database and an error will be
 * raised
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_default_posting_id Identifies the default posting to be deleted
 * @param p_object_version_number Current version number of the default posting
 * to be deleted.
 * @rep:displayname Delete Default Posting
 * @rep:category BUSINESS_ENTITY IRC_DEFAULT_JOB_POSTING
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_default_posting
  (P_VALIDATE                  in       BOOLEAN  default false
  ,P_DEFAULT_POSTING_ID        in       NUMBER
  ,P_OBJECT_VERSION_NUMBER     in       NUMBER
  );

--
end irc_default_posting_api;

/
