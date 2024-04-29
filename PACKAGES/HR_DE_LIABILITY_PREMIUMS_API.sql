--------------------------------------------------------
--  DDL for Package HR_DE_LIABILITY_PREMIUMS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_DE_LIABILITY_PREMIUMS_API" AUTHID CURRENT_USER as
/* $Header: hrlipapi.pkh 120.1 2005/10/02 02:03:34 aroussel $ */
/*#
 * This package contains APIs to maintain liability premiums for Germany.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Liability Premium for Germany
*/
--
-- ----------------------------------------------------------------------------
-- |------------------------------< create_premium >--------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a new liability premium for an organization link.
 *
 * An organization link is an association between two organizations. The two
 * linked organizations consist of a HR organization and a workers liability
 * insurance organization.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The organization link record must exist.
 *
 * <p><b>Post Success</b><br>
 * The liability premium is successfully created in the database.
 *
 * <p><b>Post Failure</b><br>
 * The API does not create the liability premium and raises an error.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Determines when the DateTrack operation comes into
 * force.
 * @param p_organization_link_id Identifier of the organization link.
 * @param p_std_percentage Standard premium percentage.
 * @param p_calculation_method Method for calculating the standard working
 * hours. Valid values exist in the 'DE_WORKING_HOURS_CALC_METHOD' lookup type.
 * @param p_std_working_hours_per_year An average for the standard working
 * hours.
 * @param p_max_remuneration Maximum remuneration limit.
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
 * @param p_liability_premiums_id If p_validate is false, the parameter value
 * is set to the unique identifier of the liability premium record. If
 * p_validate is true, the value is null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created liability premium. If p_validate is true, then
 * the value will be null.
 * @param p_effective_start_date If p_validate is false, then set to the
 * earliest effective start date for the created liability premium. If
 * p_validate is true, then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date for the created liability premium. If p_validate is true,
 * then set to null.
 * @rep:displayname Create Liability Premium for Germany
 * @rep:category BUSINESS_ENTITY HR_LIABILITY_PREMIUM
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_premium
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_organization_link_id          in     number
  ,p_std_percentage                in     number   default null
  ,p_calculation_method            in     varchar2 default null
  ,p_std_working_hours_per_year    in     number   default null
  ,p_max_remuneration              in     number   default null
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
  ,p_liability_premiums_id            out nocopy number
  ,p_object_version_number            out nocopy number
  ,p_effective_start_date             out nocopy date
  ,p_effective_end_date               out nocopy date
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------------< update_premium >--------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates a liability premium for Germany.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The liability premium record must exist.
 *
 * <p><b>Post Success</b><br>
 * The API updates the liability premium record in the database.
 *
 * <p><b>Post Failure</b><br>
 * The API does not update the liability premium and raises an error.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Determines when the DateTrack operation comes into
 * force.
 * @param p_datetrack_mode Indicates which DateTrack mode to use when updating
 * the record. You must set to either UPDATE, CORRECTION, UPDATE_OVERRIDE or
 * UPDATE_CHANGE_INSERT. Modes available for use with a particular record
 * depend on the dates of previous record changes and the effective date of
 * this change.
 * @param p_liability_premiums_id The identifier of the liability premium to
 * update.
 * @param p_std_percentage Standard premium percentage.
 * @param p_calculation_method Method for calculating the standard working
 * hours. Valid values exist in the 'DE_WORKING_HOURS_CALC_METHOD' lookup type.
 * @param p_std_working_hours_per_year An average for the standard working
 * hours.
 * @param p_max_remuneration Maximum remuneration limit.
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
 * @param p_object_version_number Pass in the current version number of the
 * liability premium to be updated. When the API completes if p_validate is
 * false, will be set to the new version number of the updated liability
 * premium. If p_validate is true will be set to the same value which was
 * passed in.
 * @param p_effective_start_date If p_validate is false, then set to the
 * effective start date on the updated liability premium row which now exists
 * as of the effective date. If p_validate is true, then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date on the updated liability premium row which now exists as
 * of the effective date. If p_validate is true, then set to null.
 * @rep:displayname Update Liability Premium for Germany
 * @rep:category BUSINESS_ENTITY HR_LIABILITY_PREMIUM
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_premium
  (p_validate                     in     boolean  default false
  ,p_effective_date               in     date
  ,p_datetrack_mode               in     varchar2
  ,p_liability_premiums_id        in     number
  ,p_std_percentage               in     number    default hr_api.g_number
  ,p_calculation_method           in     varchar2  default hr_api.g_varchar2
  ,p_std_working_hours_per_year   in     number    default hr_api.g_number
  ,p_max_remuneration             in     number    default hr_api.g_number
  ,p_attribute_category           in     varchar2  default hr_api.g_varchar2
  ,p_attribute1                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute2                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute3                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute4                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute5                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute6                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute7                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute8                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute9                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute10                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute11                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute12                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute13                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute14                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute15                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute16                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute17                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute18                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute19                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute20                  in     varchar2  default hr_api.g_varchar2
  ,p_object_version_number        in out nocopy number
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------------< delete_premium >--------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes an existing liability premium for Germany.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The liability premium record must exist.
 *
 * <p><b>Post Success</b><br>
 * The liability premium record is successfully deleted from the database.
 *
 * <p><b>Post Failure</b><br>
 * The API does not update the liability premium and raises an error.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Determines when the DateTrack operation comes into
 * force.
 * @param p_datetrack_mode Indicates which DateTrack mode to use when deleting
 * the record. You must set to either ZAP, DELETE, FUTURE_CHANGE or
 * DELETE_NEXT_CHANGE. Modes available for use with a particular record depend
 * on the dates of previous record changes and the effective date of this
 * change.
 * @param p_liability_premiums_id Identifier of the liability premium to
 * delete.
 * @param p_object_version_number Current version number of the liability
 * premium to be deleted.
 * @param p_effective_start_date If p_validate is false, then set to the
 * effective start date for the deleted liability premium row which now exists
 * as of the effective date. If p_validate is true or all row instances have
 * been deleted then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date for the deleted liability premium row which now exists as
 * of the effective date. If p_validate is true or all row instances have been
 * deleted then set to null.
 * @rep:displayname Delete Liability Premium for Germany
 * @rep:category BUSINESS_ENTITY HR_LIABILITY_PREMIUM
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_premium
  (p_validate                     in     boolean  default false
  ,p_effective_date               in     date
  ,p_datetrack_mode               in     varchar2
  ,p_liability_premiums_id        in     number
  ,p_object_version_number        in out nocopy number
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------------------< lck >---------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
--   This API locks an existing liability premium.
--
-- Prerequisites:
--
--   The liability premium record must exist.
--
-- In Parameters:
--
--   Name                           Reqd Type     Description
--   p_effective_date               Yes  date     Session date.
--   p_datetrack_mode               Yes  varchar2 datetrack mode.
--   p_liability_premiums_id        Yes  number   PK of record.
--   p_object_version_number        Yes  number   OVN of record.
--
-- Post Success:
--
--   When the liability premium has been succesfully locked, the
--   following out parameters are set:
--
--   Name                           Type     Description
--   p_object_version_number        number   OVN of record.
--   p_validation_start_date        date     Derived effective start date.
--   p_validation_end_date          date     Derived effective end date.
--
-- Post Failure:
--
--   The API does not lock the liability premium and raises an error.
--
-- Access Status:
--
--   Public.
--
-- {End Of Comments}
--
procedure lck
  (p_effective_date                   in date
  ,p_datetrack_mode                   in varchar2
  ,p_liability_premiums_id            in number
  ,p_object_version_number            in number
  ,p_validation_start_date            out nocopy date
  ,p_validation_end_date              out nocopy date
  );
--
end hr_de_liability_premiums_api;

 

/
