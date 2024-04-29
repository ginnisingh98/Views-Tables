--------------------------------------------------------
--  DDL for Package IRC_NOTIFICATION_PREFS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_NOTIFICATION_PREFS_API" AUTHID CURRENT_USER as
/* $Header: irinpapi.pkh 120.4 2008/02/21 14:16:27 viviswan noship $ */
/*#
 * This package contains Notification Preferences APIs.
 * @rep:scope public
 * @rep:product irc
 * @rep:displayname Notification Preferences
*/
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_notification_prefs >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates notification preferences for a person.
 *
 * These notification preferences are used for recruiting purposes only.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with iRecruitment.
 *
 * <p><b>Prerequisites</b><br>
 * The person must already exist
 *
 * <p><b>Post Success</b><br>
 * The notification preferences will be created in the database
 *
 * <p><b>Post Failure</b><br>
 * The notification preferences will not be created in the database and an
 * error will be raised
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_person_id Identifies the person for whom you create the
 * notification preferences record.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_address_id The existing address that is used for recruiting
 * purposes
 * @param p_matching_jobs Indicates if the person wants to receive emails about
 * matching jobs (Y or N)
 * @param p_matching_job_freq The number of days between receiving emails about
 * matching jobs. Valid values are defined by 'IRC_MESSAGE_FREQ' lookup type.
 * @param p_allow_access Indicates if managers may search for the person for
 * recruiting (Y or N)
 * @param p_receive_info_mail Indicates if the person wants to receive general
 * recruiting emails (Y or N)
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
 * @param p_notification_preference_id If p_validate is false, then this
 * uniquely identifies the notification preferences created. If p_validate is
 * true, then set to null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created notification preferences. If p_validate is
 * true, then the value will be null.
 * @param p_agency_id Identifies the agency.
 * @param p_attempt_id Identifies the registration assessment attempt.
 * @rep:displayname Create Notification Preferences
 * @rep:category BUSINESS_ENTITY IRC_CANDIDATE_NOTIFY_PREFS
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure CREATE_NOTIFICATION_PREFS
  (p_validate                      in     boolean  default false
  ,p_person_id                     in     number
  ,p_effective_date                in     date
  ,p_address_id                    in     number   default null
  ,p_matching_jobs                 in     varchar2 default 'N'
  ,p_matching_job_freq             in     varchar2 default '1'
  ,p_allow_access                  in     varchar2 default 'N'
  ,p_receive_info_mail             in     varchar2 default 'N'
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
  ,p_attribute21                   in     varchar2 default null
  ,p_attribute22                   in     varchar2 default null
  ,p_attribute23                   in     varchar2 default null
  ,p_attribute24                   in     varchar2 default null
  ,p_attribute25                   in     varchar2 default null
  ,p_attribute26                   in     varchar2 default null
  ,p_attribute27                   in     varchar2 default null
  ,p_attribute28                   in     varchar2 default null
  ,p_attribute29                   in     varchar2 default null
  ,p_attribute30                   in     varchar2 default null
  ,p_agency_id                     in     number   default null
  ,p_attempt_id                    in     number   default null
  ,p_notification_preference_id       out nocopy number
  ,p_object_version_number            out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< update_notification_prefs >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates notification preferences for a person.
 *
 * These notification preferences are only used for recruiting purposes.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with iRecruitment.
 *
 * <p><b>Prerequisites</b><br>
 * The notification preferences must already exist
 *
 * <p><b>Post Success</b><br>
 * The notification preferences will be updated in the database
 *
 * <p><b>Post Failure</b><br>
 * The notification preferences will not be updated in the database and an
 * error will be raised
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_party_id Obsolete parameter. Do not use
 * @param p_person_id Identifies the person for whom you update the
 * notification preferences record.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_matching_jobs Indicates if the person wants to receive emails about
 * matching jobs (Y or N)
 * @param p_matching_job_freq The number of days between receiving emails about
 * matching jobs. Valid values are defined by 'IRC_MESSAGE_FREQ' lookup type.
 * @param p_allow_access Indicates if managers may search for the person for
 * recruiting (Y or N)
 * @param p_receive_info_mail Indicates if the person wants to receive general
 * recruiting emails (Y or N)
 * @param p_address_id The existing address that is used for recruiting
 * purposes
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
 * @param p_notification_preference_id Identifies the notification preferences
 * to be updated
 * @param p_object_version_number Pass in the current version number of the
 * notification preferences to be updated. When the API completes if p_validate
 * is false, will be set to the new version number of the updated notification
 * preferences. If p_validate is true will be set to the same value which was
 * passed in.
 * @param p_agency_id Identifies the agency.
 * @param p_attempt_id Identifies the registration assessment attempt.
 * @rep:displayname Update Notification Preferences
 * @rep:category BUSINESS_ENTITY IRC_CANDIDATE_NOTIFY_PREFS
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure UPDATE_NOTIFICATION_PREFS
  (p_validate                      in     boolean  default false
  ,p_party_id                      in     number   default hr_api.g_number
  ,p_person_id                     in     number   default hr_api.g_number
  ,p_effective_date                in     date
  ,p_matching_jobs                 in     varchar2 default hr_api.g_varchar2
  ,p_matching_job_freq             in     varchar2 default hr_api.g_varchar2
  ,p_allow_access                  in     varchar2 default hr_api.g_varchar2
  ,p_receive_info_mail             in     varchar2 default hr_api.g_varchar2
  ,p_address_id                    in     number   default hr_api.g_number
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
  ,p_attribute21                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute22                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute23                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute24                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute25                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute26                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute27                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute28                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute29                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute30                   in     varchar2 default hr_api.g_varchar2
  ,p_notification_preference_id    in     number
  ,p_agency_id                     in     number   default hr_api.g_number
  ,p_attempt_id                    in     number   default hr_api.g_number
  ,p_object_version_number         in out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_notification_prefs >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes notification preferences for a person.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with iRecruitment.
 *
 * <p><b>Prerequisites</b><br>
 * The notification preferences must already exist
 *
 * <p><b>Post Success</b><br>
 * The notification preferences will be deleted from the database
 *
 * <p><b>Post Failure</b><br>
 * The notification preferences will not be deleted from the database and an
 * error will be raised
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_notification_preference_id Identifies the notification preferences
 * to be deleted
 * @param p_object_version_number Current version number of the notification
 * preferences to be deleted.
 * @rep:displayname Delete Notification Preferences
 * @rep:category BUSINESS_ENTITY IRC_CANDIDATE_NOTIFY_PREFS
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure DELETE_NOTIFICATION_PREFS
  (p_validate                      in     boolean  default false
  ,p_notification_preference_id    in     number
  ,p_object_version_number         in     number
  );
--
end IRC_NOTIFICATION_PREFS_API;

/
