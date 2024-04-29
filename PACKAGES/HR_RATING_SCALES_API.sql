--------------------------------------------------------
--  DDL for Package HR_RATING_SCALES_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_RATING_SCALES_API" AUTHID CURRENT_USER as
/* $Header: perscapi.pkh 120.1 2005/11/28 03:22:27 dsaxby noship $ */
/*#
 * This package contains rating scale APIs.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Rating Scale
*/
--
-- package variable
--
g_ignore_df varchar2(1) := 'N';
--
-- ----------------------------------------------------------------------------
-- |------------------------< <create_rating_scale> >--------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a rating scale.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Oracle Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * No known prerequisites.
 *
 * <p><b>Post Success</b><br>
 * The rating scale will have been created.
 *
 * <p><b>Post Failure</b><br>
 * The rating scale will not be created and an error will be raised.
 *
 * @param p_language_code Specifies to which language the translation values
 * apply. You can set to the base or any installed language. The default value
 * of hr_api.userenv_lang is equivalent to the RDBMS userenv('LANG') function
 * value.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_name {@rep:casecolumn PER_RATING_SCALES.NAME}
 * @param p_type {@rep:casecolumn PER_RATING_SCALES.TYPE}
 * @param p_default_flag {@rep:casecolumn PER_RATING_SCALES.DEFAULT_FLAG}
 * @param p_business_group_id {@rep:casecolumn
 * PER_RATING_SCALES.BUSINESS_GROUP_ID}
 * @param p_description {@rep:casecolumn PER_RATING_SCALES.DESCRIPTION}
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
 * @param p_rating_scale_id If p_validate is false, uniquely identifies the
 * rating scale created. If p_validate is true, set to null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created rating scale. If p_validate is true, then the
 * value will be null.
 * @rep:displayname Create a Rating Scale
 * @rep:category BUSINESS_ENTITY PER_COMPETENCE_RATING_SCALE
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_DATAPUMP
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_rating_scale
 (p_language_code                in varchar2 default hr_api.userenv_lang,
  p_validate                     in     boolean         default false,
  p_effective_date               in     date,
  p_name                         in     varchar2,
  p_type                         in     varchar2,
  p_default_flag                 in     varchar2         default 'N',
  p_business_group_id            in     number           default null,
  p_description                  in     varchar2         default null,
  p_attribute_category           in     varchar2         default null,
  p_attribute1                   in     varchar2         default null,
  p_attribute2                   in     varchar2         default null,
  p_attribute3                   in     varchar2         default null,
  p_attribute4                   in     varchar2         default null,
  p_attribute5                   in     varchar2         default null,
  p_attribute6                   in     varchar2         default null,
  p_attribute7                   in     varchar2         default null,
  p_attribute8                   in     varchar2         default null,
  p_attribute9                   in     varchar2         default null,
  p_attribute10                  in     varchar2         default null,
  p_attribute11                  in     varchar2         default null,
  p_attribute12                  in     varchar2         default null,
  p_attribute13                  in     varchar2         default null,
  p_attribute14                  in     varchar2         default null,
  p_attribute15                  in     varchar2         default null,
  p_attribute16                  in     varchar2         default null,
  p_attribute17                  in     varchar2         default null,
  p_attribute18                  in     varchar2         default null,
  p_attribute19                  in     varchar2         default null,
  p_attribute20                  in     varchar2         default null,
  p_rating_scale_id              out nocopy    number,
  p_object_version_number        out nocopy    number
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< <update_rating_scales> >--------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates the rating scale.
 *
 * This API updates a rating scale as identified by the in parameter
 * p_rating_scale_id and the in out parameter p_object_version_number.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Oracle Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The rating scale must exist.
 *
 * <p><b>Post Success</b><br>
 * The rating scale will have been updated.
 *
 * <p><b>Post Failure</b><br>
 * The rating scale will not be updated and an error will be raised.
 *
 * @param p_language_code Specifies to which language the translation values
 * apply. You can set to the base or any installed language. The default value
 * of hr_api.userenv_lang is equivalent to the RDBMS userenv('LANG') function
 * value.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_rating_scale_id {@rep:casecolumn PER_RATING_SCALES.RATING_SCALE_ID}
 * @param p_object_version_number Pass in the current version number of the
 * rating scale to be updated. When the API completes if p_validate is false,
 * will be set to the new version number of the updated rating scale. If
 * p_validate is true will be set to the same value which was passed in.
 * @param p_name REF.PER_RATING_SCALES.NAME
 * @param p_description REF.PER_RATING_SCALES.DESCRIPTION
 * @param p_default_flag REF.PER_RATING_SCALES.DEFAULT_FLAG
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
 * @rep:displayname Update a Rating Scale
 * @rep:category BUSINESS_ENTITY PER_COMPETENCE_RATING_SCALE
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_DATAPUMP
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_rating_scale
 (p_language_code                in varchar2 default hr_api.userenv_lang,
  p_validate                     in boolean	default false,
  p_effective_date               in date,
  p_rating_scale_id              in number,
  p_object_version_number        in out nocopy number,
  p_name                         in varchar2    default hr_api.g_varchar2,
  p_description                  in varchar2    default hr_api.g_varchar2,
  p_default_flag                 in varchar2    default hr_api.g_varchar2,
  p_attribute_category           in varchar2    default hr_api.g_varchar2,
  p_attribute1                   in varchar2    default hr_api.g_varchar2,
  p_attribute2                   in varchar2    default hr_api.g_varchar2,
  p_attribute3                   in varchar2    default hr_api.g_varchar2,
  p_attribute4                   in varchar2    default hr_api.g_varchar2,
  p_attribute5                   in varchar2    default hr_api.g_varchar2,
  p_attribute6                   in varchar2    default hr_api.g_varchar2,
  p_attribute7                   in varchar2    default hr_api.g_varchar2,
  p_attribute8                   in varchar2    default hr_api.g_varchar2,
  p_attribute9                   in varchar2    default hr_api.g_varchar2,
  p_attribute10                  in varchar2    default hr_api.g_varchar2,
  p_attribute11                  in varchar2    default hr_api.g_varchar2,
  p_attribute12                  in varchar2    default hr_api.g_varchar2,
  p_attribute13                  in varchar2    default hr_api.g_varchar2,
  p_attribute14                  in varchar2    default hr_api.g_varchar2,
  p_attribute15                  in varchar2    default hr_api.g_varchar2,
  p_attribute16                  in varchar2    default hr_api.g_varchar2,
  p_attribute17                  in varchar2    default hr_api.g_varchar2,
  p_attribute18                  in varchar2    default hr_api.g_varchar2,
  p_attribute19                  in varchar2    default hr_api.g_varchar2,
  p_attribute20                  in varchar2    default hr_api.g_varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< <delete_rating_scales> >--------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes the rating scale.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Oracle Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The rating scale must exist.
 *
 * <p><b>Post Success</b><br>
 * The rating scale will have been deleted.
 *
 * <p><b>Post Failure</b><br>
 * The rating scale will not be deleted and an error will be raised.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_rating_scale_id {@rep:casecolumn PER_RATING_SCALES.RATING_SCALE_ID}
 * @param p_object_version_number Current version number of the rating scale to
 * be deleted.
 * @rep:displayname Delete a Rating Scale
 * @rep:category BUSINESS_ENTITY PER_COMPETENCE_RATING_SCALE
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_rating_scale
(p_validate                           in boolean default false,
 p_rating_scale_id                    in number,
 p_object_version_number              in number
);
-- ----------------------------------------------------------------------------
-- |-------------------< <create_or_update_rating_scale> >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This Api creates a rating scale if the rating scale does not exist and
 * updates the rating scale if the rating scale already exists.
 *
 * This API is used for skills vendor integration.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Oracle Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The rating scale must exist for update.
 *
 * <p><b>Post Success</b><br>
 * The rating scale will have been created or updated.
 *
 * <p><b>Post Failure</b><br>
 * The rating scale will not be created or updated and an error will be raised.
 *
 * @param p_language_code Specifies to which language the translation values
 * apply. You can set to the base or any installed language. The default value
 * of hr_api.userenv_lang is equivalent to the RDBMS userenv('LANG') function
 * value.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_name {@rep:casecolumn PER_RATING_SCALES.NAME}
 * @param p_type {@rep:casecolumn PER_RATING_SCALES.TYPE}
 * @param p_description {@rep:casecolumn PER_RATING_SCALES.DESCRIPTION}
 * @param p_default_flag {@rep:casecolumn PER_RATING_SCALES.DEFAULT_FLAG}
 * @param p_translated_language If the name parameter is translated, this is
 * the language code for the name
 * @param p_source_rating_scale_name This is the rating scale name with the
 * source language code
 * @rep:displayname Create or Update a Rating Scale
 * @rep:category BUSINESS_ENTITY PER_COMPETENCE_RATING_SCALE
 * @rep:lifecycle active
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_or_update_rating_scale
 (p_language_code                in varchar2    default hr_api.userenv_lang
 ,p_validate                     in boolean	default false
 ,p_effective_date               in date        default trunc(sysdate)
 ,p_name                         in varchar2    default null
 ,p_type                         in varchar2    default null
 ,p_description                  in varchar2    default null
 ,p_default_flag                 in varchar2    default null
 ,p_translated_language          in varchar2    default null
 ,p_source_rating_scale_name     in varchar2    default null
  );
--
end hr_rating_scales_api;

 

/
