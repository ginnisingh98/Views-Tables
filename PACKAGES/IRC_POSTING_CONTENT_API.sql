--------------------------------------------------------
--  DDL for Package IRC_POSTING_CONTENT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_POSTING_CONTENT_API" AUTHID CURRENT_USER as
/* $Header: iripcapi.pkh 120.7 2008/02/21 14:21:22 viviswan noship $ */
/*#
 * This package contains APIs for job adverts.
 * @rep:scope public
 * @rep:product irc
 * @rep:displayname Posting Content
*/
--
-- ----------------------------------------------------------------------------
-- |----------------------------< synchronize_index >-------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API synchronizes the advert text indexes.
 *
 * The API will either add new entries (ONLINE mode) or update and delete old
 * entries (FULL mode), or do nothing (NONE mode).
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with iRecruitment.
 *
 * <p><b>Prerequisites</b><br>
 * None.
 *
 * <p><b>Post Success</b><br>
 * The API will rebuild the index.
 *
 * <p><b>Post Failure</b><br>
 * The API will not rebuild the index and an error will be raised
 * @param p_mode Mode can be ONLINE, FULL or NONE.
 * @rep:displayname Synchronize Index
 * @rep:category BUSINESS_ENTITY IRC_JOB_POSTING
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
Procedure synchronize_index(p_mode in varchar2);
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_posting_content >----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a new job advert.
 *
 * Job adverts are used to advertise a vacancy.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with iRecruitment.
 *
 * <p><b>Prerequisites</b><br>
 * None.
 *
 * <p><b>Post Success</b><br>
 * The job advert will be created.
 *
 * <p><b>Post Failure</b><br>
 * The job advert will not be created in the database, and an error will be
 * raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_display_manager_info Should the manager's information be displayed
 * on the advert (Y or N).
 * @param p_display_recruiter_info Should the recruiter's information be
 * displayed on the advert (Y or N).
 * @param p_language_code Specifies to which language the translation values
 * apply. You can set to the base or any installed language. The default value
 * of hr_api.userenv_lang is equivalent to the RDBMS userenv('LANG') function
 * value.
 * @param p_name The name of the job advert.
 * @param p_org_name The advertised organization name.
 * @param p_org_description The advertised organization description.
 * @param p_job_title The advertised job title.
 * @param p_brief_description The advertised brief description.
 * @param p_detailed_description The advertised detailed description.
 * @param p_job_requirements The advertised job requirements.
 * @param p_additional_details The advertised additional details.
 * @param p_how_to_apply Instructions for applying for job.
 * @param p_benefit_info The information about available benefits.
 * @param p_image_url The URL for an image to accompany the advert.
 * @param p_alt_image_url The alternative text for an image to accompany the
 * advert.
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
 * @param p_ipc_information_category Developer Descriptive flexfield segment.
 * @param p_ipc_information1 Developer Descriptive flexfield segment.
 * @param p_ipc_information2 Developer Descriptive flexfield segment.
 * @param p_ipc_information3 Developer Descriptive flexfield segment.
 * @param p_ipc_information4 Developer Descriptive flexfield segment.
 * @param p_ipc_information5 Developer Descriptive flexfield segment.
 * @param p_ipc_information6 Developer Descriptive flexfield segment.
 * @param p_ipc_information7 Developer Descriptive flexfield segment.
 * @param p_ipc_information8 Developer Descriptive flexfield segment.
 * @param p_ipc_information9 Developer Descriptive flexfield segment.
 * @param p_ipc_information10 Developer Descriptive flexfield segment.
 * @param p_ipc_information11 Developer Descriptive flexfield segment.
 * @param p_ipc_information12 Developer Descriptive flexfield segment.
 * @param p_ipc_information13 Developer Descriptive flexfield segment.
 * @param p_ipc_information14 Developer Descriptive flexfield segment.
 * @param p_ipc_information15 Developer Descriptive flexfield segment.
 * @param p_ipc_information16 Developer Descriptive flexfield segment.
 * @param p_ipc_information17 Developer Descriptive flexfield segment.
 * @param p_ipc_information18 Developer Descriptive flexfield segment.
 * @param p_ipc_information19 Developer Descriptive flexfield segment.
 * @param p_ipc_information20 Developer Descriptive flexfield segment.
 * @param p_ipc_information21 Developer Descriptive flexfield segment.
 * @param p_ipc_information22 Developer Descriptive flexfield segment.
 * @param p_ipc_information23 Developer Descriptive flexfield segment.
 * @param p_ipc_information24 Developer Descriptive flexfield segment.
 * @param p_ipc_information25 Developer Descriptive flexfield segment.
 * @param p_ipc_information26 Developer Descriptive flexfield segment.
 * @param p_ipc_information27 Developer Descriptive flexfield segment.
 * @param p_ipc_information28 Developer Descriptive flexfield segment.
 * @param p_ipc_information29 Developer Descriptive flexfield segment.
 * @param p_ipc_information30 Developer Descriptive flexfield segment.
 * @param p_date_approved The date on which the job advert was approved
 * @param p_posting_content_id If p_validate is false, then this uniquely
 * identifies the job advert created. If p_validate is true, then set to null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created job advert. If p_validate is true, then the
 * value will be null.
 * @rep:displayname Create Posting Content
 * @rep:category BUSINESS_ENTITY IRC_JOB_POSTING
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_posting_content
  (
   P_VALIDATE                      in  boolean  default false
  ,P_DISPLAY_MANAGER_INFO          in  varchar2
  ,P_DISPLAY_RECRUITER_INFO        in  varchar2
  ,P_LANGUAGE_CODE                 in  varchar2	default hr_api.userenv_lang
  ,P_NAME                          in  varchar2
  ,P_ORG_NAME                      in  varchar2	default null
  ,P_ORG_DESCRIPTION               in  varchar2	default null
  ,P_JOB_TITLE                     in  varchar2	default null
  ,P_BRIEF_DESCRIPTION             in  varchar2	default null
  ,P_DETAILED_DESCRIPTION          in  varchar2	default null
  ,P_JOB_REQUIREMENTS              in  varchar2	default null
  ,P_ADDITIONAL_DETAILS            in  varchar2	default null
  ,P_HOW_TO_APPLY                  in  varchar2	default null
  ,P_BENEFIT_INFO                  in  varchar2	default null
  ,P_IMAGE_URL                     in  varchar2	default null
  ,P_ALT_IMAGE_URL                 in  varchar2	default null
  ,P_ATTRIBUTE_CATEGORY            in  varchar2 default null
  ,P_ATTRIBUTE1                    in  varchar2 default null
  ,P_ATTRIBUTE2                    in  varchar2 default null
  ,P_ATTRIBUTE3                    in  varchar2 default null
  ,P_ATTRIBUTE4                    in  varchar2 default null
  ,P_ATTRIBUTE5                    in  varchar2 default null
  ,P_ATTRIBUTE6                    in  varchar2 default null
  ,P_ATTRIBUTE7                    in  varchar2 default null
  ,P_ATTRIBUTE8                    in  varchar2 default null
  ,P_ATTRIBUTE9                    in  varchar2 default null
  ,P_ATTRIBUTE10                   in  varchar2 default null
  ,P_ATTRIBUTE11                   in  varchar2 default null
  ,P_ATTRIBUTE12                   in  varchar2 default null
  ,P_ATTRIBUTE13                   in  varchar2 default null
  ,P_ATTRIBUTE14                   in  varchar2 default null
  ,P_ATTRIBUTE15                   in  varchar2 default null
  ,P_ATTRIBUTE16                   in  varchar2 default null
  ,P_ATTRIBUTE17                   in  varchar2 default null
  ,P_ATTRIBUTE18                   in  varchar2 default null
  ,P_ATTRIBUTE19                   in  varchar2 default null
  ,P_ATTRIBUTE20                   in  varchar2 default null
  ,P_ATTRIBUTE21                   in  varchar2 default null
  ,P_ATTRIBUTE22                   in  varchar2 default null
  ,P_ATTRIBUTE23                   in  varchar2 default null
  ,P_ATTRIBUTE24                   in  varchar2 default null
  ,P_ATTRIBUTE25                   in  varchar2 default null
  ,P_ATTRIBUTE26                   in  varchar2 default null
  ,P_ATTRIBUTE27                   in  varchar2 default null
  ,P_ATTRIBUTE28                   in  varchar2 default null
  ,P_ATTRIBUTE29                   in  varchar2 default null
  ,P_ATTRIBUTE30                   in  varchar2 default null
  ,P_IPC_INFORMATION_CATEGORY      in  varchar2	default null
  ,P_IPC_INFORMATION1              in  varchar2 default null
  ,P_IPC_INFORMATION2              in  varchar2 default null
  ,P_IPC_INFORMATION3              in  varchar2 default null
  ,P_IPC_INFORMATION4              in  varchar2 default null
  ,P_IPC_INFORMATION5              in  varchar2 default null
  ,P_IPC_INFORMATION6              in  varchar2 default null
  ,P_IPC_INFORMATION7              in  varchar2 default null
  ,P_IPC_INFORMATION8              in  varchar2 default null
  ,P_IPC_INFORMATION9              in  varchar2 default null
  ,P_IPC_INFORMATION10             in  varchar2 default null
  ,P_IPC_INFORMATION11             in  varchar2 default null
  ,P_IPC_INFORMATION12             in  varchar2 default null
  ,P_IPC_INFORMATION13             in  varchar2 default null
  ,P_IPC_INFORMATION14             in  varchar2 default null
  ,P_IPC_INFORMATION15             in  varchar2 default null
  ,P_IPC_INFORMATION16             in  varchar2 default null
  ,P_IPC_INFORMATION17             in  varchar2 default null
  ,P_IPC_INFORMATION18             in  varchar2 default null
  ,P_IPC_INFORMATION19             in  varchar2 default null
  ,P_IPC_INFORMATION20             in  varchar2 default null
  ,P_IPC_INFORMATION21             in  varchar2 default null
  ,P_IPC_INFORMATION22             in  varchar2 default null
  ,P_IPC_INFORMATION23             in  varchar2 default null
  ,P_IPC_INFORMATION24             in  varchar2 default null
  ,P_IPC_INFORMATION25             in  varchar2 default null
  ,P_IPC_INFORMATION26             in  varchar2 default null
  ,P_IPC_INFORMATION27             in  varchar2 default null
  ,P_IPC_INFORMATION28             in  varchar2 default null
  ,P_IPC_INFORMATION29             in  varchar2 default null
  ,P_IPC_INFORMATION30             in  varchar2 default null
  ,P_DATE_APPROVED                 in  date     default null
  ,P_POSTING_CONTENT_ID            out nocopy number
  ,P_OBJECT_VERSION_NUMBER         out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_posting_content >----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates a job advert.
 *
 * Job adverts are used to advertise a vacancy.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with iRecruitment.
 *
 * <p><b>Prerequisites</b><br>
 * The job advert must already exist.
 *
 * <p><b>Post Success</b><br>
 * The job advert will be updated.
 *
 * <p><b>Post Failure</b><br>
 * The job advert will not be updated in the database and an error will be
 * raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_posting_content_id Identifies the job advert.
 * @param p_display_manager_info Should the manager's information be displayed
 * on the advert (Y or N).
 * @param p_display_recruiter_info Should the recruiter's information be
 * displayed on the advert (Y or N).
 * @param p_language_code Specifies to which language the translation values
 * apply. You can set to the base or any installed language. The default value
 * of hr_api.userenv_lang is equivalent to the RDBMS userenv('LANG') function
 * value.
 * @param p_name The name of the job advert.
 * @param p_org_name The advertised organization name.
 * @param p_org_description The advertised organization description.
 * @param p_job_title The advertised job title.
 * @param p_brief_description The advertised brief description.
 * @param p_detailed_description The advertised detailed description.
 * @param p_job_requirements The advertised job requirements.
 * @param p_additional_details The advertised additional details.
 * @param p_how_to_apply Instructions for applying for job.
 * @param p_benefit_info The information about available benefits.
 * @param p_image_url The URL for an image to accompany the advert.
 * @param p_alt_image_url The alternative text for an image to accompany the
 * advert.
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
 * @param p_ipc_information_category Developer Descriptive flexfield segment.
 * @param p_ipc_information1 Developer Descriptive flexfield segment.
 * @param p_ipc_information2 Developer Descriptive flexfield segment.
 * @param p_ipc_information3 Developer Descriptive flexfield segment.
 * @param p_ipc_information4 Developer Descriptive flexfield segment.
 * @param p_ipc_information5 Developer Descriptive flexfield segment.
 * @param p_ipc_information6 Developer Descriptive flexfield segment.
 * @param p_ipc_information7 Developer Descriptive flexfield segment.
 * @param p_ipc_information8 Developer Descriptive flexfield segment.
 * @param p_ipc_information9 Developer Descriptive flexfield segment.
 * @param p_ipc_information10 Developer Descriptive flexfield segment.
 * @param p_ipc_information11 Developer Descriptive flexfield segment.
 * @param p_ipc_information12 Developer Descriptive flexfield segment.
 * @param p_ipc_information13 Developer Descriptive flexfield segment.
 * @param p_ipc_information14 Developer Descriptive flexfield segment.
 * @param p_ipc_information15 Developer Descriptive flexfield segment.
 * @param p_ipc_information16 Developer Descriptive flexfield segment.
 * @param p_ipc_information17 Developer Descriptive flexfield segment.
 * @param p_ipc_information18 Developer Descriptive flexfield segment.
 * @param p_ipc_information19 Developer Descriptive flexfield segment.
 * @param p_ipc_information20 Developer Descriptive flexfield segment.
 * @param p_ipc_information21 Developer Descriptive flexfield segment.
 * @param p_ipc_information22 Developer Descriptive flexfield segment.
 * @param p_ipc_information23 Developer Descriptive flexfield segment.
 * @param p_ipc_information24 Developer Descriptive flexfield segment.
 * @param p_ipc_information25 Developer Descriptive flexfield segment.
 * @param p_ipc_information26 Developer Descriptive flexfield segment.
 * @param p_ipc_information27 Developer Descriptive flexfield segment.
 * @param p_ipc_information28 Developer Descriptive flexfield segment.
 * @param p_ipc_information29 Developer Descriptive flexfield segment.
 * @param p_ipc_information30 Developer Descriptive flexfield segment.
 * @param p_date_approved The date on which the job advert was approved.
 * @param p_object_version_number Pass in the current version number of the job
 * advert to be updated. When the API completes if p_validate is false, will be
 * set to the new version number of the updated job advert. If p_validate is
 * true will be set to the same value which was passed in.
 * @rep:displayname Update Posting Content
 * @rep:category BUSINESS_ENTITY IRC_JOB_POSTING
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_posting_content
(
 P_VALIDATE                   in boolean  default false
,P_POSTING_CONTENT_ID         in number
,P_DISPLAY_MANAGER_INFO       in varchar2 default hr_api.g_varchar2
,P_DISPLAY_RECRUITER_INFO     in varchar2 default hr_api.g_varchar2
,P_LANGUAGE_CODE              in varchar2 default hr_api.userenv_lang
,P_NAME                       in varchar2 default hr_api.g_varchar2
,P_ORG_NAME                   in varchar2 default hr_api.g_varchar2
,P_ORG_DESCRIPTION            in varchar2 default hr_api.g_varchar2
,P_JOB_TITLE                  in varchar2 default hr_api.g_varchar2
,P_BRIEF_DESCRIPTION          in varchar2 default hr_api.g_varchar2
,P_DETAILED_DESCRIPTION       in varchar2 default hr_api.g_varchar2
,P_JOB_REQUIREMENTS           in varchar2 default hr_api.g_varchar2
,P_ADDITIONAL_DETAILS         in varchar2 default hr_api.g_varchar2
,P_HOW_TO_APPLY               in varchar2 default hr_api.g_varchar2
,P_BENEFIT_INFO               in varchar2 default hr_api.g_varchar2
,P_IMAGE_URL                  in varchar2 default hr_api.g_varchar2
,P_ALT_IMAGE_URL              in varchar2 default hr_api.g_varchar2
,P_ATTRIBUTE_CATEGORY         in varchar2 default hr_api.g_varchar2
,P_ATTRIBUTE1                 in varchar2 default hr_api.g_varchar2
,P_ATTRIBUTE2                 in varchar2 default hr_api.g_varchar2
,P_ATTRIBUTE3                 in varchar2 default hr_api.g_varchar2
,P_ATTRIBUTE4                 in varchar2 default hr_api.g_varchar2
,P_ATTRIBUTE5                 in varchar2 default hr_api.g_varchar2
,P_ATTRIBUTE6                 in varchar2 default hr_api.g_varchar2
,P_ATTRIBUTE7                 in varchar2 default hr_api.g_varchar2
,P_ATTRIBUTE8                 in varchar2 default hr_api.g_varchar2
,P_ATTRIBUTE9                 in varchar2 default hr_api.g_varchar2
,P_ATTRIBUTE10                in varchar2 default hr_api.g_varchar2
,P_ATTRIBUTE11                in varchar2 default hr_api.g_varchar2
,P_ATTRIBUTE12                in varchar2 default hr_api.g_varchar2
,P_ATTRIBUTE13                in varchar2 default hr_api.g_varchar2
,P_ATTRIBUTE14                in varchar2 default hr_api.g_varchar2
,P_ATTRIBUTE15                in varchar2 default hr_api.g_varchar2
,P_ATTRIBUTE16                in varchar2 default hr_api.g_varchar2
,P_ATTRIBUTE17                in varchar2 default hr_api.g_varchar2
,P_ATTRIBUTE18                in varchar2 default hr_api.g_varchar2
,P_ATTRIBUTE19                in varchar2 default hr_api.g_varchar2
,P_ATTRIBUTE20                in varchar2 default hr_api.g_varchar2
,P_ATTRIBUTE21                in varchar2 default hr_api.g_varchar2
,P_ATTRIBUTE22                in varchar2 default hr_api.g_varchar2
,P_ATTRIBUTE23                in varchar2 default hr_api.g_varchar2
,P_ATTRIBUTE24                in varchar2 default hr_api.g_varchar2
,P_ATTRIBUTE25                in varchar2 default hr_api.g_varchar2
,P_ATTRIBUTE26                in varchar2 default hr_api.g_varchar2
,P_ATTRIBUTE27                in varchar2 default hr_api.g_varchar2
,P_ATTRIBUTE28                in varchar2 default hr_api.g_varchar2
,P_ATTRIBUTE29                in varchar2 default hr_api.g_varchar2
,P_ATTRIBUTE30                in varchar2 default hr_api.g_varchar2
,P_IPC_INFORMATION_CATEGORY   in varchar2 default hr_api.g_varchar2
,P_IPC_INFORMATION1           in varchar2 default hr_api.g_varchar2
,P_IPC_INFORMATION2           in varchar2 default hr_api.g_varchar2
,P_IPC_INFORMATION3           in varchar2 default hr_api.g_varchar2
,P_IPC_INFORMATION4           in varchar2 default hr_api.g_varchar2
,P_IPC_INFORMATION5           in varchar2 default hr_api.g_varchar2
,P_IPC_INFORMATION6           in varchar2 default hr_api.g_varchar2
,P_IPC_INFORMATION7           in varchar2 default hr_api.g_varchar2
,P_IPC_INFORMATION8           in varchar2 default hr_api.g_varchar2
,P_IPC_INFORMATION9           in varchar2 default hr_api.g_varchar2
,P_IPC_INFORMATION10          in varchar2 default hr_api.g_varchar2
,P_IPC_INFORMATION11          in varchar2 default hr_api.g_varchar2
,P_IPC_INFORMATION12          in varchar2 default hr_api.g_varchar2
,P_IPC_INFORMATION13          in varchar2 default hr_api.g_varchar2
,P_IPC_INFORMATION14          in varchar2 default hr_api.g_varchar2
,P_IPC_INFORMATION15          in varchar2 default hr_api.g_varchar2
,P_IPC_INFORMATION16          in varchar2 default hr_api.g_varchar2
,P_IPC_INFORMATION17          in varchar2 default hr_api.g_varchar2
,P_IPC_INFORMATION18          in varchar2 default hr_api.g_varchar2
,P_IPC_INFORMATION19          in varchar2 default hr_api.g_varchar2
,P_IPC_INFORMATION20          in varchar2 default hr_api.g_varchar2
,P_IPC_INFORMATION21          in varchar2 default hr_api.g_varchar2
,P_IPC_INFORMATION22          in varchar2 default hr_api.g_varchar2
,P_IPC_INFORMATION23          in varchar2 default hr_api.g_varchar2
,P_IPC_INFORMATION24          in varchar2 default hr_api.g_varchar2
,P_IPC_INFORMATION25          in varchar2 default hr_api.g_varchar2
,P_IPC_INFORMATION26          in varchar2 default hr_api.g_varchar2
,P_IPC_INFORMATION27          in varchar2 default hr_api.g_varchar2
,P_IPC_INFORMATION28          in varchar2 default hr_api.g_varchar2
,P_IPC_INFORMATION29          in varchar2 default hr_api.g_varchar2
,P_IPC_INFORMATION30          in varchar2 default hr_api.g_varchar2
,P_DATE_APPROVED              in date     default hr_api.g_date
,P_OBJECT_VERSION_NUMBER      in out nocopy number
);
--
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_posting_content >----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes a job advert.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with iRecruitment.
 *
 * <p><b>Prerequisites</b><br>
 * The job advert must already exist.
 *
 * <p><b>Post Success</b><br>
 * The job advert will be deleted.
 *
 * <p><b>Post Failure</b><br>
 * The job advert will not be removed from the database and an error will be
 * raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_posting_content_id Identifies the job advert.
 * @param p_object_version_number Current version number of the job advert to
 * be deleted.
 * @rep:displayname Delete Posting Content
 * @rep:category BUSINESS_ENTITY IRC_JOB_POSTING
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_posting_content
(
 P_VALIDATE                 in boolean	 default false
,P_POSTING_CONTENT_ID       in number
,P_OBJECT_VERSION_NUMBER    in number
);
--
-- ----------------------------------------------------------------------------
-- |------------------------< synchronize_recruiter_info >--------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates posting content rows with Recruiter information.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with iRecruitment.
 *
 * <p><b>Prerequisites</b><br>
 * None.
 *
 * <p><b>Post Success</b><br>
 * Updates the posting content with Recruiter information.
 *
 * <p><b>Post Failure</b><br>
 * Does not update the row and, raises an error.
 *
 * @rep:displayname Synchronize Recruiter Info
 * @rep:category BUSINESS_ENTITY IRC_JOB_POSTING
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure synchronize_recruiter_info;
--
end IRC_POSTING_CONTENT_API;

/
