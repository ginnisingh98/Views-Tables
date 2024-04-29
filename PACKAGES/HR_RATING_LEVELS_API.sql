--------------------------------------------------------
--  DDL for Package HR_RATING_LEVELS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_RATING_LEVELS_API" AUTHID CURRENT_USER as
/* $Header: pertlapi.pkh 120.1 2005/11/28 03:22:49 dsaxby noship $ */
/*#
 * This package contains rating level APIs.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Rating Level
*/
--
-- package varialbe
--
g_ignore_df varchar2(1) := 'N';  -- BUG3621261
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_rating_level >---------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a rating level.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Oracle Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The competence or rating scale must exist.
 *
 * <p><b>Post Success</b><br>
 * The rating level will have been created.
 *
 * <p><b>Post Failure</b><br>
 * The rating level will not be created and an error will be raised.
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
 * @param p_name {@rep:casecolumn PER_RATING_LEVELS.NAME}
 * @param p_business_group_id {@rep:casecolumn
 * PER_RATING_LEVELS.BUSINESS_GROUP_ID}
 * @param p_step_value {@rep:casecolumn PER_RATING_LEVELS.STEP_VALUE}
 * @param p_behavioural_indicator {@rep:casecolumn
 * PER_RATING_LEVELS.BEHAVIOURAL_INDICATOR}
 * @param p_rating_scale_id {@rep:casecolumn PER_RATING_LEVELS.RATING_SCALE_ID}
 * @param p_competence_id {@rep:casecolumn PER_RATING_LEVELS.COMPETENCE_ID}
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
 * @param p_rating_level_id If p_validate is false, uniquely identifies the
 * rating level created. If p_validate is true, set to null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created rating level. If p_validate is true, then the
 * value will be null.
 * @param p_obj_ver_number_cpn_or_rsc If p_validate is false, set to the
 * version number of the competence or rating scale. If p_validate is true, set
 * to null.
 * @rep:displayname Create Rating Level
 * @rep:category BUSINESS_ENTITY PER_COMPETENCE
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_DATAPUMP
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_rating_level
 (p_language_code                in varchar2 default hr_api.userenv_lang,
  p_validate                     in		boolean  	     default false,
  p_effective_date               in		date,
  p_name                         in 	varchar2,
  p_business_group_id            in 	number           default null,
  p_step_value                   in		number,
  p_behavioural_indicator        in 	varchar2         default null,
  p_rating_scale_id              in		number           default null,
  p_competence_id                in 	number           default null,
  p_attribute_category           in 	varchar2         default null,
  p_attribute1                   in 	varchar2         default null,
  p_attribute2                   in 	varchar2         default null,
  p_attribute3                   in 	varchar2         default null,
  p_attribute4                   in 	varchar2         default null,
  p_attribute5                   in 	varchar2         default null,
  p_attribute6                   in 	varchar2         default null,
  p_attribute7                   in 	varchar2         default null,
  p_attribute8                   in 	varchar2         default null,
  p_attribute9                   in 	varchar2         default null,
  p_attribute10                  in 	varchar2         default null,
  p_attribute11                  in 	varchar2         default null,
  p_attribute12                  in 	varchar2         default null,
  p_attribute13                  in 	varchar2         default null,
  p_attribute14                  in 	varchar2         default null,
  p_attribute15                  in 	varchar2         default null,
  p_attribute16                  in 	varchar2         default null,
  p_attribute17                  in 	varchar2         default null,
  p_attribute18                  in 	varchar2         default null,
  p_attribute19                  in 	varchar2         default null,
  p_attribute20                  in 	varchar2         default null,
  p_rating_level_id              out nocopy    number,
  p_object_version_number        out nocopy 	number,
  p_obj_ver_number_cpn_or_rsc    out nocopy    number
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< update_rating_level >--------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates the rating level.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Oracle Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The rating level must exist.
 *
 * <p><b>Post Success</b><br>
 * The rating level will have been updated.
 *
 * <p><b>Post Failure</b><br>
 * The rating level will not be updated and an error will be raised.
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
 * @param p_rating_level_id {@rep:casecolumn PER_RATING_LEVELS.RATING_LEVEL_ID}
 * @param p_object_version_number Pass in the current version number of the
 * rating level to be updated. When the API completes if p_validate is false,
 * will be set to the new version number of the updated rating level. If
 * p_validate is true will be set to the same value which was passed in.
 * @param p_name {@rep:casecolumn PER_RATING_LEVELS.NAME}
 * @param p_behavioural_indicator REF.PER_RATING_LEVELS.BEHAVIOURAL_INDICATOR
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
 * @rep:displayname Update Rating Level
 * @rep:category BUSINESS_ENTITY PER_COMPETENCE
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_DATAPUMP
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_rating_level
 (
  p_language_code                in varchar2 default hr_api.userenv_lang,p_validate                     in boolean         default false,
  p_effective_date               in date,
  p_rating_level_id              in number,
  p_object_version_number        in out nocopy number,
  p_name                         in varchar2         default hr_api.g_varchar2,
  p_behavioural_indicator        in varchar2         default hr_api.g_varchar2,
  p_attribute_category           in varchar2         default hr_api.g_varchar2,
  p_attribute1                   in varchar2         default hr_api.g_varchar2,
  p_attribute2                   in varchar2         default hr_api.g_varchar2,
  p_attribute3                   in varchar2         default hr_api.g_varchar2,
  p_attribute4                   in varchar2         default hr_api.g_varchar2,
  p_attribute5                   in varchar2         default hr_api.g_varchar2,
  p_attribute6                   in varchar2         default hr_api.g_varchar2,
  p_attribute7                   in varchar2         default hr_api.g_varchar2,
  p_attribute8                   in varchar2         default hr_api.g_varchar2,
  p_attribute9                   in varchar2         default hr_api.g_varchar2,
  p_attribute10                  in varchar2         default hr_api.g_varchar2,
  p_attribute11                  in varchar2         default hr_api.g_varchar2,
  p_attribute12                  in varchar2         default hr_api.g_varchar2,
  p_attribute13                  in varchar2         default hr_api.g_varchar2,
  p_attribute14                  in varchar2         default hr_api.g_varchar2,
  p_attribute15                  in varchar2         default hr_api.g_varchar2,
  p_attribute16                  in varchar2         default hr_api.g_varchar2,
  p_attribute17                  in varchar2         default hr_api.g_varchar2,
  p_attribute18                  in varchar2         default hr_api.g_varchar2,
  p_attribute19                  in varchar2         default hr_api.g_varchar2,
  p_attribute20                  in varchar2         default hr_api.g_varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_rating_level >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes the rating level.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Oracle Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The rating level must exist.
 *
 * <p><b>Post Success</b><br>
 * The rating level will have been deleted.
 *
 * <p><b>Post Failure</b><br>
 * The rating level will not be deleted and an error will be raised.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_rating_level_id {@rep:casecolumn PER_RATING_LEVELS.RATING_LEVEL_ID}
 * @param p_object_version_number Current version number of the rating level to
 * be deleted.
 * @param p_obj_ver_number_cpn_or_rsc If p_validate is false, set to the
 * version number of the competence or rating scale. If p_validate is true, set
 * to null.
 * @rep:displayname Delete Rating Level
 * @rep:category BUSINESS_ENTITY PER_COMPETENCE
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_rating_level
(p_validate                           in  boolean default false,
 p_rating_level_id                    in  number,
 p_object_version_number              in  number,
 p_obj_ver_number_cpn_or_rsc	      out nocopy number
);
--
-- ----------------------------------------------------------------------------
-- |----------------------< create_or_update_rating_level >-------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a rating level if the rating level does not exist or
 * updates the rating level if the rating level already exists.
 *
 * This API is used for skills vendor integration.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Oracle Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The rating level must exist.
 *
 * <p><b>Post Success</b><br>
 * The rating level will have been created or updated.
 *
 * <p><b>Post Failure</b><br>
 * The rating level will not be created or updated and an error will be raised.
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
 * @param p_name {@rep:casecolumn PER_RATING_LEVELS.NAME}
 * @param p_step_value {@rep:casecolumn PER_RATING_LEVELS.STEP_VALUE}
 * @param p_rating_scale_name Rating scale name
 * @param p_behavioural_indicator {@rep:casecolumn
 * PER_RATING_LEVELS.BEHAVIOURAL_INDICATOR}
 * @param p_competence_name Competence name
 * @param p_translated_language If the name parameter is translated, this is
 * the language code for the name
 * @param p_source_rating_level_name This is the name with the source language
 * code
 * @rep:displayname Create or Update Rating Level
 * @rep:category BUSINESS_ENTITY PER_COMPETENCE
 * @rep:lifecycle active
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_or_update_rating_level
 (
  p_language_code                in varchar2 default hr_api.userenv_lang
 ,p_validate                     in boolean         default false
 ,p_effective_date               in date            default trunc(sysdate)
 ,p_name                         in varchar2        default null
 ,p_step_value                   in number          default 1
 ,p_rating_scale_name            in varchar2        default null
 ,p_behavioural_indicator        in varchar2        default null
 ,p_competence_name              in varchar2        default null
 ,p_translated_language          in varchar2        default null
 ,p_source_rating_level_name     in varchar2        default null
  );
--
end hr_rating_levels_api;

 

/
