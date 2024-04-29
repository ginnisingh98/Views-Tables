--------------------------------------------------------
--  DDL for Package PER_BF_PAYROLL_RUNS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_BF_PAYROLL_RUNS_API" AUTHID CURRENT_USER as
/* $Header: pebprapi.pkh 120.1 2005/10/02 02:12:27 aroussel $ */
/*#
 * This package contains APIs that maintain backfeed payroll runs details.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Backfeed Payroll Run
*/
--
-- ----------------------------------------------------------------------------
-- |----------------------------< create_payroll_run >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates payroll run information from a third party payroll
 * application.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * A valid payroll definition must exist.
 *
 * <p><b>Post Success</b><br>
 * The backfeed payroll run will be successfully inserted into the database.
 *
 * <p><b>Post Failure</b><br>
 * The backfeed payroll run will not be created and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_business_group_id Business Group for the backfeed payroll run.
 * @param p_payroll_id The payroll id of the payroll run.
 * @param p_payroll_identifier Unique identifier of a payroll run.
 * @param p_period_start_date Start date of the payroll period.
 * @param p_period_end_date End date of the payroll period.
 * @param p_processing_date Date the payroll run took place.
 * @param p_bpr_attribute_category This context value determines which
 * flexfield structure to use with the descriptive flexfield segments.
 * @param p_bpr_attribute1 Descriptive flexfield segment.
 * @param p_bpr_attribute2 Descriptive flexfield segment.
 * @param p_bpr_attribute3 Descriptive flexfield segment.
 * @param p_bpr_attribute4 Descriptive flexfield segment.
 * @param p_bpr_attribute5 Descriptive flexfield segment.
 * @param p_bpr_attribute6 Descriptive flexfield segment.
 * @param p_bpr_attribute7 Descriptive flexfield segment.
 * @param p_bpr_attribute8 Descriptive flexfield segment.
 * @param p_bpr_attribute9 Descriptive flexfield segment.
 * @param p_bpr_attribute10 Descriptive flexfield segment.
 * @param p_bpr_attribute11 Descriptive flexfield segment.
 * @param p_bpr_attribute12 Descriptive flexfield segment.
 * @param p_bpr_attribute13 Descriptive flexfield segment.
 * @param p_bpr_attribute14 Descriptive flexfield segment.
 * @param p_bpr_attribute15 Descriptive flexfield segment.
 * @param p_bpr_attribute16 Descriptive flexfield segment.
 * @param p_bpr_attribute17 Descriptive flexfield segment.
 * @param p_bpr_attribute18 Descriptive flexfield segment.
 * @param p_bpr_attribute19 Descriptive flexfield segment.
 * @param p_bpr_attribute20 Descriptive flexfield segment.
 * @param p_bpr_attribute21 Descriptive flexfield segment.
 * @param p_bpr_attribute22 Descriptive flexfield segment.
 * @param p_bpr_attribute23 Descriptive flexfield segment.
 * @param p_bpr_attribute24 Descriptive flexfield segment.
 * @param p_bpr_attribute25 Descriptive flexfield segment.
 * @param p_bpr_attribute26 Descriptive flexfield segment.
 * @param p_bpr_attribute27 Descriptive flexfield segment.
 * @param p_bpr_attribute28 Descriptive flexfield segment.
 * @param p_bpr_attribute29 Descriptive flexfield segment.
 * @param p_bpr_attribute30 Descriptive flexfield segment.
 * @param p_payroll_run_id If p_validate is false, then this uniquely
 * identifies the backfeed payroll run created. If p_validate is true, then set
 * to null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created backfeed payroll run record. If p_validate is
 * true, then the value will be null.
 * @rep:displayname Create Backfeed Payroll Run
 * @rep:category BUSINESS_ENTITY PER_BF_PAYROLL_RESULTS
 * @rep:category MISC_EXTENSIONS HR_DATAPUMP
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_payroll_run
  (p_validate                      in boolean          default false
  ,p_effective_date                in date
  ,p_business_group_id             in number
  ,p_payroll_id                    in number
  ,p_payroll_identifier            in varchar2
  ,p_period_start_date             in date             default null
  ,p_period_end_date               in date             default null
  ,p_processing_date               in date             default null
  ,p_bpr_attribute_category        in varchar2         default null
  ,p_bpr_attribute1                in varchar2         default null
  ,p_bpr_attribute2                in varchar2         default null
  ,p_bpr_attribute3                in varchar2         default null
  ,p_bpr_attribute4                in varchar2         default null
  ,p_bpr_attribute5                in varchar2         default null
  ,p_bpr_attribute6                in varchar2         default null
  ,p_bpr_attribute7                in varchar2         default null
  ,p_bpr_attribute8                in varchar2         default null
  ,p_bpr_attribute9                in varchar2         default null
  ,p_bpr_attribute10               in varchar2         default null
  ,p_bpr_attribute11               in varchar2         default null
  ,p_bpr_attribute12               in varchar2         default null
  ,p_bpr_attribute13               in varchar2         default null
  ,p_bpr_attribute14               in varchar2         default null
  ,p_bpr_attribute15               in varchar2         default null
  ,p_bpr_attribute16               in varchar2         default null
  ,p_bpr_attribute17               in varchar2         default null
  ,p_bpr_attribute18               in varchar2         default null
  ,p_bpr_attribute19               in varchar2         default null
  ,p_bpr_attribute20               in varchar2         default null
  ,p_bpr_attribute21               in varchar2         default null
  ,p_bpr_attribute22               in varchar2         default null
  ,p_bpr_attribute23               in varchar2         default null
  ,p_bpr_attribute24               in varchar2         default null
  ,p_bpr_attribute25               in varchar2         default null
  ,p_bpr_attribute26               in varchar2         default null
  ,p_bpr_attribute27               in varchar2         default null
  ,p_bpr_attribute28               in varchar2         default null
  ,p_bpr_attribute29               in varchar2         default null
  ,p_bpr_attribute30               in varchar2     default null
  --
  ,p_payroll_run_id                   out nocopy number
  ,p_object_version_number            out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------------< update_payroll_run >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates payroll run information from a third party payroll
 * application.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * A valid backfeed payroll run must exist.
 *
 * <p><b>Post Success</b><br>
 * The backfeed payroll run will be successfully updated into the database.
 *
 * <p><b>Post Failure</b><br>
 * The backfeed payroll run will not be updated and an error will be raised.
 * @param p_payroll_run_id Uniquely identifies the backfeed payroll run.
 * @param p_payroll_identifier Unique identifier of a payroll run.
 * @param p_period_start_date Start date of the payroll period.
 * @param p_period_end_date End date of the payroll period.
 * @param p_processing_date Date the payroll run took place.
 * @param p_bpr_attribute_category This context value determines which
 * flexfield structure to use with the descriptive flexfield segments.
 * @param p_bpr_attribute1 Descriptive flexfield segment.
 * @param p_bpr_attribute2 Descriptive flexfield segment.
 * @param p_bpr_attribute3 Descriptive flexfield segment.
 * @param p_bpr_attribute4 Descriptive flexfield segment.
 * @param p_bpr_attribute5 Descriptive flexfield segment.
 * @param p_bpr_attribute6 Descriptive flexfield segment.
 * @param p_bpr_attribute7 Descriptive flexfield segment.
 * @param p_bpr_attribute8 Descriptive flexfield segment.
 * @param p_bpr_attribute9 Descriptive flexfield segment.
 * @param p_bpr_attribute10 Descriptive flexfield segment.
 * @param p_bpr_attribute11 Descriptive flexfield segment.
 * @param p_bpr_attribute12 Descriptive flexfield segment.
 * @param p_bpr_attribute13 Descriptive flexfield segment.
 * @param p_bpr_attribute14 Descriptive flexfield segment.
 * @param p_bpr_attribute15 Descriptive flexfield segment.
 * @param p_bpr_attribute16 Descriptive flexfield segment.
 * @param p_bpr_attribute17 Descriptive flexfield segment.
 * @param p_bpr_attribute18 Descriptive flexfield segment.
 * @param p_bpr_attribute19 Descriptive flexfield segment.
 * @param p_bpr_attribute20 Descriptive flexfield segment.
 * @param p_bpr_attribute21 Descriptive flexfield segment.
 * @param p_bpr_attribute22 Descriptive flexfield segment.
 * @param p_bpr_attribute23 Descriptive flexfield segment.
 * @param p_bpr_attribute24 Descriptive flexfield segment.
 * @param p_bpr_attribute25 Descriptive flexfield segment.
 * @param p_bpr_attribute26 Descriptive flexfield segment.
 * @param p_bpr_attribute27 Descriptive flexfield segment.
 * @param p_bpr_attribute28 Descriptive flexfield segment.
 * @param p_bpr_attribute29 Descriptive flexfield segment.
 * @param p_bpr_attribute30 Descriptive flexfield segment.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_object_version_number Pass in the current version number of the
 * backfeed payroll run to be updated. When the API completes if p_validate is
 * false, will be set to the new version number of the updated backfeed payment
 * detail. If p_validate is true will be set to the same value which was passed
 * in.
 * @rep:displayname Update Backfeed Payroll Run
 * @rep:category BUSINESS_ENTITY PER_BF_PAYROLL_RESULTS
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_payroll_run
  (p_payroll_run_id                in number
  ,p_payroll_identifier            in varchar2         default hr_api.g_varchar2
  ,p_period_start_date             in date             default hr_api.g_date
  ,p_period_end_date               in date             default hr_api.g_date
  ,p_processing_date               in date             default hr_api.g_date
  ,p_bpr_attribute_category        in varchar2         default hr_api.g_varchar2
  ,p_bpr_attribute1                in varchar2         default hr_api.g_varchar2
  ,p_bpr_attribute2                in varchar2         default hr_api.g_varchar2
  ,p_bpr_attribute3                in varchar2         default hr_api.g_varchar2
  ,p_bpr_attribute4                in varchar2         default hr_api.g_varchar2
  ,p_bpr_attribute5                in varchar2         default hr_api.g_varchar2
  ,p_bpr_attribute6                in varchar2         default hr_api.g_varchar2
  ,p_bpr_attribute7                in varchar2         default hr_api.g_varchar2
  ,p_bpr_attribute8                in varchar2         default hr_api.g_varchar2
  ,p_bpr_attribute9                in varchar2         default hr_api.g_varchar2
  ,p_bpr_attribute10               in varchar2         default hr_api.g_varchar2
  ,p_bpr_attribute11               in varchar2         default hr_api.g_varchar2
  ,p_bpr_attribute12               in varchar2         default hr_api.g_varchar2
  ,p_bpr_attribute13               in varchar2         default hr_api.g_varchar2
  ,p_bpr_attribute14               in varchar2         default hr_api.g_varchar2
  ,p_bpr_attribute15               in varchar2         default hr_api.g_varchar2
  ,p_bpr_attribute16               in varchar2         default hr_api.g_varchar2
  ,p_bpr_attribute17               in varchar2         default hr_api.g_varchar2
  ,p_bpr_attribute18               in varchar2         default hr_api.g_varchar2
  ,p_bpr_attribute19               in varchar2         default hr_api.g_varchar2
  ,p_bpr_attribute20               in varchar2         default hr_api.g_varchar2
  ,p_bpr_attribute21               in varchar2         default hr_api.g_varchar2
  ,p_bpr_attribute22               in varchar2         default hr_api.g_varchar2
  ,p_bpr_attribute23               in varchar2         default hr_api.g_varchar2
  ,p_bpr_attribute24               in varchar2         default hr_api.g_varchar2
  ,p_bpr_attribute25               in varchar2         default hr_api.g_varchar2
  ,p_bpr_attribute26               in varchar2         default hr_api.g_varchar2
  ,p_bpr_attribute27               in varchar2         default hr_api.g_varchar2
  ,p_bpr_attribute28               in varchar2         default hr_api.g_varchar2
  ,p_bpr_attribute29               in varchar2         default hr_api.g_varchar2
  ,p_bpr_attribute30               in varchar2         default hr_api.g_varchar2
  ,p_validate                      in boolean          default false
  ,p_effective_date                in date
  ,p_object_version_number         in out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------------< delete_payroll_run >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes payroll run information from a third party payroll
 * application.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * A valid backfeed payroll run amount must exist.
 *
 * <p><b>Post Success</b><br>
 * The backfeed payroll run amount will be successfully deleted from the
 * database.
 *
 * <p><b>Post Failure</b><br>
 * The backfeed payroll run amount will not be deleted and an error will be
 * raised.
 * @param p_payroll_run_id Uniquely identifies the backfeed payroll run.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_object_version_number Current version number of the backfeed
 * payroll run to be deleted.
 * @rep:displayname Delete Backfeed Payroll Run
 * @rep:category BUSINESS_ENTITY PER_BF_PAYROLL_RESULTS
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_payroll_run
  (p_payroll_run_id                in number
  ,p_validate                      in boolean          default false
  ,p_object_version_number         in number
  );
end PER_BF_PAYROLL_RUNS_API;

 

/
