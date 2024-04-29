--------------------------------------------------------
--  DDL for Package HR_VALID_GRADE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_VALID_GRADE_API" AUTHID CURRENT_USER as
/* $Header: pevgrapi.pkh 120.1 2005/10/02 02:24:59 aroussel $ */
/*#
 * This package contains APIs that create and maintain valid grades.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Valid Grade
*/
--
-- ----------------------------------------------------------------------------
-- |----------------------------< create_valid_grade >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a new valid grade for a given job or position.
 *
 * A component of an employee assignment that defines their level and can be
 * used to control the value of their salary and other compensation elements.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with HR Foundation.
 *
 * <p><b>Prerequisites</b><br>
 * The grade, identified by p_grade_id, must exist as of date_from and must not
 * end before date_to. Either the job_id or position_id must be passed into the
 * API. Both values cannot be provided for the same valid grade. When the
 * job_id is specified it must exist as of date_from, must not end before
 * date_to and must be in the same business group as the grade. When the
 * position_id is specified it must exist as of date_from, must not end before
 * date_to, and must be in the same business group as the grade. The
 * combination of grade, job and position must not already exist as a valid
 * grade.
 *
 * <p><b>Post Success</b><br>
 * Valid grade record is created for the job or position.
 *
 * <p><b>Post Failure</b><br>
 * The API does not create the valid grade and raises an error.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_grade_id Uniquely identifies the grade.
 * @param p_date_from The date on which the valid grade takes effect
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_comments Comment Text
 * @param p_date_to The date on which the valid grade is no longer in effect.
 * @param p_job_id Uniquely identifies the job.
 * @param p_position_id Uniquely identifies the position.
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
 * @param p_valid_grade_id If p_validate is false, uniquely identifies the
 * valid grade created. If p_validate is true, set to null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created Valid Grade. If p_validate is true, then the
 * value will be null.
 * @rep:displayname Create Valid Grade
 * @rep:category BUSINESS_ENTITY PER_JOB
 * @rep:category BUSINESS_ENTITY PER_POSITION
 * @rep:category MISC_EXTENSIONS HR_DATAPUMP
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_valid_grade
  (p_validate                      in     boolean  default false
  ,p_grade_id                      in     number
  ,p_date_from                     in     date
  ,p_effective_date 		       in 	  date --Added for bug# 1760707
  ,p_comments                      in     varchar2 default null
  ,p_date_to                       in     date     default null
  ,p_job_id                        in     number   default null
  ,p_position_id                   in     number   default null
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
  ,p_valid_grade_id                   out nocopy number
  ,p_object_version_number            out nocopy number
  );
--
--
end hr_valid_grade_api;
--

 

/
