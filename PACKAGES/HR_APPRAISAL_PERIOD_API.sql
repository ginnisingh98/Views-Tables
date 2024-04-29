--------------------------------------------------------
--  DDL for Package HR_APPRAISAL_PERIOD_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_APPRAISAL_PERIOD_API" AUTHID CURRENT_USER as
/* $Header: pepmaapi.pkh 120.7.12010000.3 2010/02/22 06:38:33 schowdhu ship $ */
/*#
 * This package contains appraisal period APIs.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Appraisal Period
*/
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_appraisal_period >----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API defines an appraisal period for a performance management plan.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The performance management plan and the appraisal template must exist.
 *
 * <p><b>Post Success</b><br>
 * The appraisal period will have been created, and the status of the
 * performance management plan will have been changed to Updated if its
 * status was previously Published.
 *
 * <p><b>Post Failure</b><br>
 * The appraisal period will not be created and an error will be raised.
 *
 * @param p_validate If true, then validation alone will be performed and
 * the database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_plan_id Identifies the performance plan for which this appraisal
 * period belongs.
 * @param p_appraisal_template_id Identifies the appraisal template to use.
 * @param p_start_date Start date of this appraisal period.
 * @param p_end_date Start date of this appraisal period.
 * @param p_task_start_date Task start date for this appraisal period.
 * @param p_task_end_date Task end date for this appraisal period.
 * @param p_initiator_code Identifies the initiator of this appraisal period.
 * Valid values are identified by HR_WPM_INITIATOR lookup type.
 * @param p_appraisal_system_type  Identifies appraisal system type of this appraisal period.
 * Valid values are identified by APPRAISAL_SYSTEM_TYPE lookup type.
 * @param p_appraisal_type Identifies appraisasl purpose of this appraisal period.
 * Valid values are identified by APPRAISAL_TYPE lookup type.
 * @param p_appraisal_assmt_status Identifies appraisal assessment status for this appraisal period.
 * Valid values are identified by APPRAISAL_ASSESSMENT_STATUS lookup type.
 * @param p_auto_conc_process Identifies whether mass appraisal creation concurrent
 * process has to start automatically. Valid values are identified by YES_NO lookup type.
 * @param p_days_before_task_st_dt Identifies number of days before task start date, to
 * calculate the date on which the mass appraisal creation concurrent process has to run.
 * @param p_participation_type identifies the participation type of the participant to
 * be created automatically for secondary assignment manager.
 * @param p_questionnaire_template_id identifies the questionnaire template to
 * be attached for the participant.
 * @param p_attribute_category This context value determines which
 * flexfield structure to use with the descriptive flexfield segments.
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
 * @param p_appraisal_period_id If p_validate is false, then this uniquely
 * identifies the appraisal period created. If p_validate is true, then set to
 * null.
 * @param p_object_version_number If p_validate is false, then set to
 * the version number of the created appraisal period. If p_validate is true,
 * then the value will be null.
 * @rep:displayname Create Appraisal Period
 * @rep:category BUSINESS_ENTITY PER_APPRAISAL_PERIOD
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
--
procedure create_appraisal_period
  (p_validate                      in     boolean  default false
  ,p_effective_date               in     date
  ,p_plan_id                       in     number
  ,p_appraisal_template_id         in     number
  ,p_start_date                    in     date
  ,p_end_date                      in     date
  ,p_task_start_date               in     date
  ,p_task_end_date                 in     date
  ,p_initiator_code                in     varchar2 default null
  ,p_appraisal_system_type         in     varchar2 default null
  ,p_appraisal_type                in     varchar2 default null
  ,p_appraisal_assmt_status        in     varchar2 default null
  ,p_auto_conc_process             in     varchar2 default null
  ,p_days_before_task_st_dt        in     number   default null
  ,p_participation_type            in     varchar2 default null
  ,p_questionnaire_template_id     in     number   default null
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
  ,p_appraisal_period_id              out nocopy   number
  ,p_object_version_number            out nocopy   number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_appraisal_period >----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates an appraisal period for a performance management plan.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The appraisal period must exist.
 *
 * <p><b>Post Success</b><br>
 * The appraisal period will have been updated, and the status of the
 * performance management plan will have been changed to Updated if its
 * status was previously Published.
 *
 * <p><b>Post Failure</b><br>
 * The appraisal period will not be updated and an error will be raised.
 *
 * @param p_validate If true, then validation alone will be performed and
 * the database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_appraisal_period_id Identifies the appraisal period to be
 * modified.
 * @param p_object_version_number Pass in the current version number of
 * the appraisal period to be updated. When the API completes if p_validate is
 * false, will be set to the new version number of the updated appraisal
 * period. If p_validate is true will be set to the same value which was
 * passed in.
 * @param p_start_date Start date of this appraisal period.
 * @param p_end_date Start date of this appraisal period.
 * @param p_task_start_date Task start date for this appraisal period.
 * @param p_task_end_date Task end date for this appraisal period.
 * @param p_initiator_code Identifies the initiator of this appraisal period.
 * Valid values are identified by HR_WPM_INITIATOR lookup type.
 * @param p_appraisal_system_type  Identifies appraisal system type of this appraisal period.
 * Valid values are identified by APPRAISAL_SYSTEM_TYPE lookup type.
 * @param p_appraisal_type Identifies appraisasl purpose of this appraisal period.
 * Valid values are identified by APPRAISAL_TYPE lookup type.
 * @param p_appraisal_assmt_status Identifies appraisal assessment status for this appraisal period.
 * Valid values are identified by APPRAISAL_ASSESSMENT_STATUS lookup type.
 * @param p_auto_conc_process Identifies whether mass appraisal creation concurrent
 * process has to start automatically. Valid values are identified by YES_NO lookup type.
 * @param p_days_before_task_st_dt Identifies number of days before task start date, to
 * calculate the date on which the mass appraisal creation concurrent process has to run.
 * @param p_participation_type identifies the participation type of the participant to
 * be created automatically for secondary assignment manager.
 * @param p_questionnaire_template_id identifies the questionnaire template to
 * be attached for the participant.
 * @param p_attribute_category This context value determines which
 * flexfield structure to use with the descriptive flexfield segments.
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
 * @rep:displayname Update Appraisal Period
 * @rep:category BUSINESS_ENTITY PER_APPRAISAL_PERIOD
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
--
procedure update_appraisal_period
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_appraisal_period_id           in     number
  ,p_object_version_number         in out nocopy   number
  ,p_start_date                    in     date     default hr_api.g_date
  ,p_end_date                      in     date     default hr_api.g_date
  ,p_task_start_date               in     date     default hr_api.g_date
  ,p_task_end_date                 in     date     default hr_api.g_date
  ,p_initiator_code                in     varchar2 default hr_api.g_varchar2
  ,p_appraisal_system_type         in     varchar2 default hr_api.g_varchar2
  ,p_appraisal_type                in     varchar2 default hr_api.g_varchar2
  ,p_appraisal_assmt_status        in     varchar2 default hr_api.g_varchar2
  ,p_auto_conc_process             in     varchar2 default hr_api.g_varchar2
  ,p_days_before_task_st_dt        in     number   default hr_api.g_number
  ,p_participation_type            in     varchar2 default hr_api.g_varchar2
  ,p_questionnaire_template_id     in     number   default hr_api.g_number
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
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_appraisal_period >----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes an appraisal period for a performance management plan.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The appraisal period must exist.
 *
 * <p><b>Post Success</b><br>
 * The appraisal period will have been deleted, and the status of the
 * performance management plan will have been changed to Updated if its
 * status was previously Published.
 *
 * <p><b>Post Failure</b><br>
 * The appraisal period will not be deleted and an error will be raised.
 *
 * @param p_validate If true, then validation alone will be performed and
 * the database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_appraisal_period_id Identifies the appraisal period to be
 * deleted.
 * @param p_object_version_number Current version number of the appraisal
 * period to be deleted.
 * @rep:displayname Delete Appraisal Period
 * @rep:category BUSINESS_ENTITY PER_APPRAISAL_PERIOD
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_appraisal_period
  (p_validate                      in     boolean  default false
  ,p_appraisal_period_id           in     number
  ,p_object_version_number         in     number
  );
--
end hr_appraisal_period_api;

/
