--------------------------------------------------------
--  DDL for Package PQH_CRITERIA_RATE_DEFN_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_CRITERIA_RATE_DEFN_API" AUTHID CURRENT_USER as
/* $Header: pqcrdapi.pkh 120.6 2006/03/14 11:28:41 srajakum noship $ */
/*#
 * This package contains criteria rate definition APIs.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Criteria rate definition
*/
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_criteria_rate_defn >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
/*#
 * This API creates a new criteria rate definition.
 *
 * The API allows the user to configure if they would like to define a maximum ,
 * minimum , mid-value and default value when defining rates for a defining criteria
 * rate definition.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources and HR Foundation.
 *
 * <p><b>Prerequisites</b><br>
 * The business group in which the criteria rate definition is created must already
 * exist.
 *
 * <p><b>Post Success</b><br>
 * The criteria rate definition is created.
 *
 * <p><b>Post Failure</b><br>
 * The criteria rate definition will not be created and error is raised.
 *
 * @param p_validate If true, then validation alone will be performed and
 * the database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * effective during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_business_group_id Business group of the criteria rate definition.
 * @param p_criteria_rate_defn_id If p_validate is false, then this uniquely
 * identifies the criteria rate definition created. If p_validate is true, then
 * set to null.
 * @param p_short_name Short name.
 * @param p_name Name of the criteria rate definition.
 * @param p_language_code Specifies to which language the translation
 * values apply. You can set to the base or any installed language. The default
 * value of hr_api.userenv_lang is equivalent to the RDBMS userenv('LANG')
 * function value.
 * @param p_uom Unit of measure. Valid values are defined by PQH_RBC_UOM
 * lookup type.
 * @param p_currency_code The currency for rates defined for this criteria
 * rate definition.
 * @param p_reference_period_cd The frequency of rate value defined for this criteria
 * rate definition. Valid values are defined by PQH_RBC_REFERENCE_PERIOD lookup type.
 * @param p_define_max_rate_flag Define maximum rate value. Valid values are defined
 * by the PQH_YES_NO lookup type.
 * @param p_define_min_rate_flag Define minimum rate value. Valid values are defined
 * by the PQH_YES_NO lookup type.
 * @param p_define_mid_rate_flag Define mid rate value. Valid values are defined
 * by the PQH_YES_NO lookup type.
 * @param p_define_std_rate_flag Define default rate value. Valid values are defined
 * by the PQH_YES_NO lookup type.
 * @param p_rate_calc_cd Rate calculation method. Valid values are defined by
 * PQH_RBC_RATE_CALC_METHOD lookup type.
 * @param p_rate_calc_rule Fast formula used for rate calculation.
 * @param p_preferential_rate_cd Preferential rate calculation method. Valid values
 * are defined by PQH_RBC_PEFERENTIAL_RATE lookup type.
 * @param p_preferential_rate_rule Fast formual used to calculate preferential rate.
 * @param p_rounding_cd Rounding method. Valid values are defined by
 * PQH_RBC_ROUNDING lookup type.
 * @param p_rounding_rule Fast formula used to perform rounding.
 * @param p_legislation_code Legislation code of the criteria rate definition.
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
 * @param p_object_version_number If p_validate is false, then set to
 * the version number of the created criteria rate definition. If p_validate
 * is true, then the value will be null.
 * @rep:displayname Create criteria rate definition
 * @rep:category BUSINESS_ENTITY PQH_RBC_RATE_MATRIX
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--

procedure create_criteria_rate_defn
(
   p_validate                      in     boolean      default false
  ,p_effective_date                in     date
  ,p_business_group_id             in     number
  ,p_criteria_rate_defn_id            out nocopy number
  ,p_short_name		         	   in     varchar2     default  null
  ,p_name                          in     varchar2
  ,p_language_code                 in     varchar2     default hr_api.userenv_lang
  ,p_uom                           in     varchar2
  ,p_currency_code		           in     varchar2     default null
  ,p_reference_period_cd           in     varchar2     default null
  ,p_define_max_rate_flag          in	  varchar2     default null
  ,p_define_min_rate_flag          in	  varchar2     default null
  ,p_define_mid_rate_flag          in	  varchar2     default null
  ,p_define_std_rate_flag          in	  varchar2     default null
  ,p_rate_calc_cd		  		   in     varchar2
  ,p_rate_calc_rule		  		   in     number       default null
  ,p_preferential_rate_cd          in	  varchar2
  ,p_preferential_rate_rule        in 	  number       default null
  ,p_rounding_cd                   in     varchar2
  ,p_rounding_rule		  		   in     number       default null
  ,p_legislation_code 	           in     varchar2     default null
  ,p_attribute_category            in     varchar2     default null
  ,p_attribute1                    in     varchar2     default null
  ,p_attribute2                    in     varchar2     default null
  ,p_attribute3                    in     varchar2     default null
  ,p_attribute4                    in     varchar2     default null
  ,p_attribute5                    in     varchar2     default null
  ,p_attribute6                    in     varchar2     default null
  ,p_attribute7                    in     varchar2     default null
  ,p_attribute8                    in     varchar2     default null
  ,p_attribute9                    in     varchar2     default null
  ,p_attribute10                   in     varchar2     default null
  ,p_attribute11                   in     varchar2     default null
  ,p_attribute12                   in     varchar2     default null
  ,p_attribute13                   in     varchar2     default null
  ,p_attribute14                   in     varchar2     default null
  ,p_attribute15                   in     varchar2     default null
  ,p_attribute16                   in     varchar2     default null
  ,p_attribute17                   in     varchar2     default null
  ,p_attribute18                   in     varchar2     default null
  ,p_attribute19                   in     varchar2     default null
  ,p_attribute20                   in     varchar2     default null
  ,p_attribute21                   in     varchar2     default null
  ,p_attribute22                   in     varchar2     default null
  ,p_attribute23                   in     varchar2     default null
  ,p_attribute24                   in     varchar2     default null
  ,p_attribute25                   in     varchar2     default null
  ,p_attribute26                   in     varchar2     default null
  ,p_attribute27                   in     varchar2     default null
  ,p_attribute28                   in     varchar2     default null
  ,p_attribute29                   in     varchar2     default null
  ,p_attribute30                   in     varchar2     default null
  ,p_object_version_number            out nocopy number
  );
--
--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_criteria_rate_defn >--------------------------|
-- ----------------------------------------------------------------------------
--
--
-- {Start Of Comments}
/*#
 * This API updates details of an existing criteria rate definition.
 *
 * The currency code and frequency details are mandatory if the unit of measure
 * is Money.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources and HR Foundation.
 *
 * <p><b>Prerequisites</b><br>
 * The criteria rate definition details can be updated only if it is not already
 * used in a rate matrix to define rates.
 *
 * <p><b>Post Success</b><br>
 * The criteria rate definition details are successfully updated.
 *
 * <p><b>Post Failure</b><br>
 * The criteria rate definition details will not be updated and error is raised.
 *
 * @param p_validate If true, then validation alone will be performed and
 * the database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup
 * values are effective during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_business_group_id Business group of the criteria rate definition.
 * @param p_criteria_rate_defn_id Uniquely identifies the criteria rate
 * definition to be modified.
 * @param p_short_name Short name.
 * @param p_name Name of the criteria rate definition.
 * @param p_language_code Specifies to which language the translation
 * values apply. You can set to the base or any installed language. The default
 * value of hr_api.userenv_lang is equivalent to the RDBMS userenv('LANG')
 * function value.
 * @param p_uom Unit of measure. Valid values are defined by PQH_RBC_UOM
 * lookup type.
 * @param p_currency_code The currency for rates defined for this criteria
 * rate definition.
 * @param p_reference_period_cd The frequency of rate value defined for this criteria
 * rate definition. Valid values are defined by PQH_RBC_REFERENCE_PERIOD lookup type.
 * @param p_define_max_rate_flag Define maximum rate value. Valid values are defined
 * by the PQH_YES_NO lookup type.
 * @param p_define_min_rate_flag Define minimum rate value. Valid values are defined
 * by the PQH_YES_NO lookup type.
 * @param p_define_mid_rate_flag Define mid rate value. Valid values are defined
 * by the PQH_YES_NO lookup type.
 * @param p_define_std_rate_flag Define default rate value. Valid values are defined
 * by the PQH_YES_NO lookup type.
 * @param p_rate_calc_cd Rate calculation method. Valid values are defined by
 * PQH_RBC_RATE_CALC_METHOD lookup type.
 * @param p_rate_calc_rule Fast formula used for rate calculation.
 * @param p_preferential_rate_cd Preferential rate calculation method. Valid values
 * are defined by PQH_RBC_PEFERENTIAL_RATE lookup type.
 * @param p_preferential_rate_rule Fast formual used to calculate preferential rate.
 * @param p_rounding_cd Rounding method. Valid values are defined by
 * PQH_RBC_ROUNDING lookup type.
 * @param p_rounding_rule Fast formula used to perform rounding.
 * @param p_legislation_code Legislation code of the criteria rate definition.
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
 * @param p_object_version_number Pass in the current version number of the criteria
 * rate definition to be updated. When the API completes if p_validate is false, will be
 * set to the new version number of the updated criteria rate definition. If p_validate
 * is true will be set to the same value which was passed in.
 * @rep:displayname Update criteria rate definition
 * @rep:category BUSINESS_ENTITY PQH_RBC_RATE_MATRIX
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
--
procedure update_criteria_rate_defn
  (p_validate                      in     boolean      default false
  ,p_effective_date                in     date
  ,p_business_group_id             in     number
  ,p_criteria_rate_defn_id         in     number
  ,p_short_name		           	   in     varchar2     default hr_api.g_varchar2
  ,p_name                          in     varchar2
  ,p_language_code                 in     varchar2     default hr_api.userenv_lang
  ,p_uom                           in     varchar2
  ,p_currency_code		   		   in     varchar2     default hr_api.g_varchar2
  ,p_reference_period_cd           in     varchar2     default hr_api.g_varchar2
  ,p_define_max_rate_flag          in	  varchar2     default hr_api.g_varchar2
  ,p_define_min_rate_flag          in	  varchar2     default hr_api.g_varchar2
  ,p_define_mid_rate_flag          in	  varchar2     default hr_api.g_varchar2
  ,p_define_std_rate_flag          in	  varchar2     default hr_api.g_varchar2
  ,p_rate_calc_cd		   		   in     varchar2
  ,p_rate_calc_rule		   		   in     number       default hr_api.g_number
  ,p_preferential_rate_cd          in	  varchar2
  ,p_preferential_rate_rule        in 	  number       default hr_api.g_number
  ,p_rounding_cd                   in     varchar2
  ,p_rounding_rule		   		   in     number       default hr_api.g_number
  ,p_legislation_code 	           in     varchar2     default hr_api.g_varchar2
  ,p_attribute_category            in     varchar2     default hr_api.g_varchar2
  ,p_attribute1                    in     varchar2     default hr_api.g_varchar2
  ,p_attribute2                    in     varchar2     default hr_api.g_varchar2
  ,p_attribute3                    in     varchar2     default hr_api.g_varchar2
  ,p_attribute4                    in     varchar2     default hr_api.g_varchar2
  ,p_attribute5                    in     varchar2     default hr_api.g_varchar2
  ,p_attribute6                    in     varchar2     default hr_api.g_varchar2
  ,p_attribute7                    in     varchar2     default hr_api.g_varchar2
  ,p_attribute8                    in     varchar2     default hr_api.g_varchar2
  ,p_attribute9                    in     varchar2     default hr_api.g_varchar2
  ,p_attribute10                   in     varchar2     default hr_api.g_varchar2
  ,p_attribute11                   in     varchar2     default hr_api.g_varchar2
  ,p_attribute12                   in     varchar2     default hr_api.g_varchar2
  ,p_attribute13                   in     varchar2     default hr_api.g_varchar2
  ,p_attribute14                   in     varchar2     default hr_api.g_varchar2
  ,p_attribute15                   in     varchar2     default hr_api.g_varchar2
  ,p_attribute16                   in     varchar2     default hr_api.g_varchar2
  ,p_attribute17                   in     varchar2     default hr_api.g_varchar2
  ,p_attribute18                   in     varchar2     default hr_api.g_varchar2
  ,p_attribute19                   in     varchar2     default hr_api.g_varchar2
  ,p_attribute20                   in     varchar2     default hr_api.g_varchar2
  ,p_attribute21                   in     varchar2     default hr_api.g_varchar2
  ,p_attribute22                   in     varchar2     default hr_api.g_varchar2
  ,p_attribute23                   in     varchar2     default hr_api.g_varchar2
  ,p_attribute24                   in     varchar2     default hr_api.g_varchar2
  ,p_attribute25                   in     varchar2     default hr_api.g_varchar2
  ,p_attribute26                   in     varchar2     default hr_api.g_varchar2
  ,p_attribute27                   in     varchar2     default hr_api.g_varchar2
  ,p_attribute28                   in     varchar2     default hr_api.g_varchar2
  ,p_attribute29                   in     varchar2     default hr_api.g_varchar2
  ,p_attribute30                   in     varchar2     default hr_api.g_varchar2
  ,p_object_version_number         in out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_criteria_rate_defn >--------------------------|
-- ----------------------------------------------------------------------------
--
/*#
 * This API deletes a criteria rate definition.
 *
 * Deleting a criteria rate definition removes a rate type for which rates can be defined
 * from the current business group.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources and HR Foundation.
 *
 * <p><b>Prerequisites</b><br>
 * This criteria rate definition must not be used as a rate factor for rate
 * calculation by other criteria rate definitions in the business group. The criteria
 * rate definition must not be used in any rate matrix to define rates.
 *
 * <p><b>Post Success</b><br>
 * The criteria rate definition is deleted.
 *
 * <p><b>Post Failure</b><br>
 * The criteria rate definition is not deleted and error is raised.
 *
 * @param p_validate If true, then validation alone will be performed and
 * the database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values
 * are applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_criteria_rate_defn_id Identifies the criteria rate definition
 * to be deleted.
 * @param p_object_version_number Current version number of the criteria rate
 * definition to be deleted.
 * @rep:displayname Delete criteria rate definition
 * @rep:category BUSINESS_ENTITY PQH_RBC_RATE_MATRIX
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--

procedure delete_criteria_rate_defn
  (p_validate                      in     boolean           default false
  ,p_effective_date                in     date
  ,p_criteria_rate_defn_id         in     number
  ,p_object_version_number         in     number
  );
--
end PQH_CRITERIA_RATE_DEFN_API;

 

/
