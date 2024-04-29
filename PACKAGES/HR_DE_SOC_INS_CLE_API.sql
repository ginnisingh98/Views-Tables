--------------------------------------------------------
--  DDL for Package HR_DE_SOC_INS_CLE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_DE_SOC_INS_CLE_API" AUTHID CURRENT_USER AS
/* $Header: hrcleapi.pkh 120.1 2005/10/02 02:00:02 aroussel $ */
/*#
 * This package contains APIs to maintain social insurnace contributions for
 * Germany.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Social Insurance Contribution
*/
--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_soc_ins_contributions >-------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a social insurance contribution record for Germany.
 *
 * A social insurance contribution record is held against an organization.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The organization must exist in the business group
 *
 * <p><b>Post Success</b><br>
 * The social insurance contribution record is successfully inserted into the
 * database
 *
 * <p><b>Post Failure</b><br>
 * The social insurance contribution record is not inserted into the database
 * and an error is raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_organization_id A valid organization in the business group
 * @param p_normal_percentage The normal percentage
 * @param p_normal_amount The normal amount
 * @param p_increased_percentage The increased percentage
 * @param p_increased_amount The increased amount
 * @param p_reduced_percentage The reduced percentage
 * @param p_reduced_amount The reduced amount
 * @param p_effective_start_date If p_validate is false, then set to the
 * earliest effective start date for the created social insurance contribution.
 * If p_validate is true, then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date for the created social insurance contribution. If
 * p_validate is true, then set to null.
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
 * @param p_effective_date Determines when the DateTrack operation comes into
 * force.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created social insurance contribution. If p_validate
 * is true, then the value will be null.
 * @param p_soc_ins_contr_lvls_id The unique identifier of the social insurance
 * contribution record.
 * @param p_flat_tax_limit_per_month The flat tax limit per month
 * @param p_flat_tax_limit_per_year The flat tax limit per year
 * @param p_min_increased_contribution The minimum increased contribution
 * @param p_max_increased_contribution The maximum increased contribution
 * @param p_month1 The first month. Valid values exist in the 'MONTH_CODE'
 * lookup type.
 * @param p_month1_min_contribution The minimum contribution for month 1
 * @param p_month1_max_contribution The maximum contribution for month 1
 * @param p_month2 The second month. Valid values exist in the 'MONTH_CODE'
 * lookup type.
 * @param p_month2_min_contribution The minimum contribution for month 2
 * @param p_month2_max_contribution The maximum contribution for month 2
 * @param p_employee_contribution The employee contribution amount
 * @param p_contribution_level_type The contribution level type.
 * @rep:displayname Create Social Insurance Contribution for Germany
 * @rep:category BUSINESS_ENTITY HR_SOC_INS_CONTRIBUTIONS
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_soc_ins_contributions
(
     p_validate                   IN    boolean     default false
   , p_organization_id            IN      number      default null
   , p_normal_percentage          IN      number      default null
   , p_normal_amount              IN      number      default null
   , p_increased_percentage       IN      number      default null
   , p_increased_amount           IN      number      default null
   , p_reduced_percentage         IN      number      default null
   , p_reduced_amount             IN      number      default null
   , p_effective_start_date       IN OUT NOCOPY  date
   , p_effective_end_date         IN OUT NOCOPY  date
   , p_attribute_category         IN      varchar2    default null
   , p_attribute1 		  IN      varchar2    default null
   , p_attribute2		  IN      varchar2    default null
   , p_attribute3 		  IN      varchar2    default null
   , p_attribute4		  IN      varchar2    default null
   , p_attribute5		  IN      varchar2    default null
   , p_attribute6 		  IN      varchar2    default null
   , p_attribute7 		  IN      varchar2    default null
   , p_attribute8 		  IN      varchar2    default null
   , p_attribute9 		  IN      varchar2    default null
   , p_attribute10 		  IN      varchar2    default null
   , p_attribute11 		  IN      varchar2    default null
   , p_attribute12 		  IN      varchar2    default null
   , p_attribute13 		  IN      varchar2    default null
   , p_attribute14 		  IN      varchar2    default null
   , p_attribute15 		  IN      varchar2    default null
   , p_attribute16 		  IN      varchar2    default null
   , p_attribute17 		  IN      varchar2    default null
   , p_attribute18 		  IN      varchar2    default null
   , p_attribute19 		  IN      varchar2    default null
   , p_attribute20 		  IN      varchar2    default null
   , p_attribute21 		  IN      varchar2    default null
   , p_attribute22 		  IN      varchar2    default null
   , p_attribute23 		  IN      varchar2    default null
   , p_attribute24 		  IN      varchar2    default null
   , p_attribute25 		  IN      varchar2    default null
   , p_attribute26 		  IN      varchar2    default null
   , p_attribute27 		  IN      varchar2    default null
   , p_attribute28 		  IN      varchar2    default null
   , p_attribute29 		  IN      varchar2    default null
   , p_attribute30 		  IN      varchar2    default null
   , p_effective_date             IN      date
   , p_object_version_number          OUT NOCOPY number
   , p_soc_ins_contr_lvls_id          OUT NOCOPY number
   , p_flat_tax_limit_per_month	  IN      number     default null
   , p_flat_tax_limit_per_year	  IN      number     default null
   , p_min_increased_contribution IN      number     default null
   , p_max_increased_contribution IN      number     default null
   , p_month1			  IN      varchar2   default null
   , p_month1_min_contribution    IN      number     default null
   , p_month1_max_contribution    IN      number     default null
   , p_month2		 	  IN      varchar2   default null
   , p_month2_min_contribution    IN      number     default null
   , p_month2_max_contribution    IN      number     default null
   , p_employee_contribution	  IN      number     default null
   , p_contribution_level_type    IN      varchar2   default null
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------< update_soc_ins_contributions >-------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates social insurance contribution record for Germany.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The social insurance contribution record must exist.
 *
 * <p><b>Post Success</b><br>
 * The organization link is successfully updated in the database.
 *
 * <p><b>Post Failure</b><br>
 * The API does not update the organization link and raises an error.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_organization_id A valid organization in the business group
 * @param p_normal_percentage The normal percentage
 * @param p_normal_amount The normal amount
 * @param p_increased_percentage The increased percentage
 * @param p_increased_amount The increased amount
 * @param p_reduced_percentage The reduced percentage
 * @param p_reduced_amount The reduced amount
 * @param p_effective_start_date If p_validate is false, then set to the
 * effective start date on the updated social insurance row which now exists as
 * of the effective date. If p_validate is true, then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date on the updated social insurance row which now exists as
 * of the effective date. If p_validate is true, then set to null.
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
 * @param p_effective_date Determines when the DateTrack operation comes into
 * force.
 * @param p_object_version_number Pass in the current version number of the
 * social insurance contribution to be updated. When the API completes if
 * p_validate is false, will be set to the new version number of the updated
 * social insurance contribution. If p_validate is true will be set to the same
 * value which was passed in.
 * @param p_soc_ins_contr_lvls_id The unique identifier of the social insurance
 * contribution record.
 * @param p_datetrack_mode Indicates which DateTrack mode to use when updating
 * the record. You must set to either UPDATE, CORRECTION, UPDATE_OVERRIDE or
 * UPDATE_CHANGE_INSERT. Modes available for use with a particular record
 * depend on the dates of previous record changes and the effective date of
 * this change.
 * @param p_flat_tax_limit_per_month The flat tax limit per month
 * @param p_flat_tax_limit_per_year The flat tax limit per year
 * @param p_min_increased_contribution The minimum increased contribution
 * @param p_max_increased_contribution The maximum increased contribution
 * @param p_month1 The first month. Valid values exist in the 'MONTH_CODE'
 * lookup type.
 * @param p_month1_min_contribution The minimum contribution for month 1
 * @param p_month1_max_contribution The maximum contribution for month 1
 * @param p_month2 The second month. Valid values exist in the 'MONTH_CODE'
 * lookup type.
 * @param p_month2_min_contribution The minimum contribution for month 2
 * @param p_month2_max_contribution The maximum contribution for month 2
 * @param p_employee_contribution The employee contribution amount
 * @param p_contribution_level_type The contribution level type.
 * @rep:displayname Update Social Insurance Contribution for Germany
 * @rep:category BUSINESS_ENTITY HR_SOC_INS_CONTRIBUTIONS
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_soc_ins_contributions
  (
     p_validate                     IN      boolean   	  default  false
   , p_organization_id              IN      number 	  default  hr_api.g_number
   , p_normal_percentage            IN      number 	  default  hr_api.g_number
   , p_normal_amount                IN      number 	  default  hr_api.g_number
   , p_increased_percentage         IN      number 	  default  hr_api.g_number
   , p_increased_amount             IN      number 	  default  hr_api.g_number
   , p_reduced_percentage           IN      number 	  default  hr_api.g_number
   , p_reduced_amount               IN      number 	  default  hr_api.g_number
   , p_effective_start_date         IN OUT NOCOPY  date
   , p_effective_end_date           IN OUT NOCOPY  date
   , p_attribute_category           IN      varchar2	  default hr_api.g_varchar2
   , p_attribute1 		    IN      varchar2	  default hr_api.g_varchar2
   , p_attribute2		    IN      varchar2	  default hr_api.g_varchar2
   , p_attribute3 		    IN      varchar2	  default hr_api.g_varchar2
   , p_attribute4		    IN      varchar2	  default hr_api.g_varchar2
   , p_attribute5		    IN      varchar2	  default hr_api.g_varchar2
   , p_attribute6 		    IN      varchar2	  default hr_api.g_varchar2
   , p_attribute7 		    IN      varchar2	  default hr_api.g_varchar2
   , p_attribute8 		    IN      varchar2	  default hr_api.g_varchar2
   , p_attribute9 		    IN      varchar2	  default hr_api.g_varchar2
   , p_attribute10 		    IN      varchar2	  default hr_api.g_varchar2
   , p_attribute11 		    IN      varchar2	  default hr_api.g_varchar2
   , p_attribute12 		    IN      varchar2	  default hr_api.g_varchar2
   , p_attribute13 		    IN      varchar2	  default hr_api.g_varchar2
   , p_attribute14 		    IN      varchar2	  default hr_api.g_varchar2
   , p_attribute15 		    IN      varchar2	  default hr_api.g_varchar2
   , p_attribute16 		    IN      varchar2	  default hr_api.g_varchar2
   , p_attribute17 		    IN      varchar2	  default hr_api.g_varchar2
   , p_attribute18 		    IN      varchar2	  default hr_api.g_varchar2
   , p_attribute19 		    IN      varchar2	  default hr_api.g_varchar2
   , p_attribute20 		    IN      varchar2	  default hr_api.g_varchar2
   , p_attribute21 		    IN      varchar2	  default hr_api.g_varchar2
   , p_attribute22 		    IN      varchar2	  default hr_api.g_varchar2
   , p_attribute23 		    IN      varchar2	  default hr_api.g_varchar2
   , p_attribute24 		    IN      varchar2	  default hr_api.g_varchar2
   , p_attribute25 		    IN      varchar2	  default hr_api.g_varchar2
   , p_attribute26 		    IN      varchar2	  default hr_api.g_varchar2
   , p_attribute27 		    IN      varchar2	  default hr_api.g_varchar2
   , p_attribute28 		    IN      varchar2	  default hr_api.g_varchar2
   , p_attribute29 		    IN      varchar2	  default hr_api.g_varchar2
   , p_attribute30 		    IN      varchar2	  default hr_api.g_varchar2
   , p_effective_date               IN      date
   , p_object_version_number        IN OUT NOCOPY number
   , p_soc_ins_contr_lvls_id        IN     number
   , p_datetrack_mode               IN     varchar2
   , p_flat_tax_limit_per_month	    IN     number    default hr_api.g_number
   , p_flat_tax_limit_per_year	    IN     number    default hr_api.g_number
   , p_min_increased_contribution   IN     number    default hr_api.g_number
   , p_max_increased_contribution   IN     number    default hr_api.g_number
   , p_month1			    IN     varchar2  default hr_api.g_varchar2
   , p_month1_min_contribution      IN     number    default hr_api.g_number
   , p_month1_max_contribution      IN     number    default hr_api.g_number
   , p_month2			    IN     varchar2  default hr_api.g_varchar2
   , p_month2_min_contribution      IN     number    default hr_api.g_number
   , p_month2_max_contribution      IN     number    default hr_api.g_number
   , p_employee_contribution	    IN     number    default hr_api.g_number
   , p_contribution_level_type  		    IN     varchar2  default hr_api.g_varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------< delete_soc_ins_contributions >-------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes a social insurance contribution record for Germany.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The social insurance record to be deleted must exist.
 *
 * <p><b>Post Success</b><br>
 * The social insurance link is successfully deleted from the database.
 *
 * <p><b>Post Failure</b><br>
 * The API does not delete the social insurance contribution row and raises an
 * error.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_soc_ins_contr_lvls_id Identifier of the record to be deleted.
 * @param p_effective_start_date If p_validate is false, then set to the
 * effective start date for the deleted social insurance row which now exists
 * as of the effective date. If p_validate is true or all row instances have
 * been deleted then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date for the deleted social insurance row which now exists as
 * of the effective date. If p_validate is true or all row instances have been
 * deleted then set to null.
 * @param p_object_version_number Current version number of the social
 * insurance record to be deleted.
 * @param p_effective_date Determines when the DateTrack operation comes into
 * force.
 * @param p_datetrack_mode Indicates which DateTrack mode to use when deleting
 * the record. You must set to either ZAP, DELETE, FUTURE_CHANGE or
 * DELETE_NEXT_CHANGE. Modes available for use with a particular record depend
 * on the dates of previous record changes and the effective date of this
 * change.
 * @rep:displayname Delete Social Insurance Contribution for Germany
 * @rep:category BUSINESS_ENTITY HR_SOC_INS_CONTRIBUTIONS
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_soc_ins_contributions
  (
   p_validate                       in boolean        default false
  ,p_soc_ins_contr_lvls_id          in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in date
  ,p_datetrack_mode                 in varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------------------< lck >---------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_soc_ins_contr_lvls_id        Yes  number   PK of record
--   p_object_version_number        Yes  number   OVN of record
--   p_effective_date               Yes  date     Session Date.
--   p_datetrack_mode               Yes  varchar2 Datetrack mode.
--
-- Post Success:
--
--   Name                           Type     Description
--   p_validation_start_date        Yes      Derived Effective Start Date.
--   p_validation_end_date          Yes      Derived Effective End Date.
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure lck
  (
    p_soc_ins_contr_lvls_id        in number
   ,p_object_version_number        in number
   ,p_effective_date               in date
   ,p_datetrack_mode               in varchar2
   ,p_validation_start_date        out nocopy date
   ,p_validation_end_date          out nocopy date
  );
--
end hr_de_soc_ins_cle_api;

 

/
