--------------------------------------------------------
--  DDL for Package PAY_BALANCE_CATEGORY_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_BALANCE_CATEGORY_API" AUTHID CURRENT_USER as
/* $Header: pypbcapi.pkh 120.2 2005/10/22 01:25:41 aroussel noship $ */
/*#
 * This package contains the Balance Category API.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Balance Category
*/
g_dml_status boolean:= FALSE;  -- Global package variable
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_balance_category >----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates the balance category.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * A valid business group should exists.
 *
 * <p><b>Post Success</b><br>
 * The balance category will be successfully inserted into the database.
 *
 * <p><b>Post Failure</b><br>
 * The API does not create the balance category and raises an error.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Determines when the DateTrack operation comes into
 * force.
 * @param p_category_name The name for the category
 * @param p_business_group_id Business Group of the Record.
 * @param p_legislation_code Legislation Code
 * @param p_save_run_balance_enabled Flag for determining whether to create run
 * balances.
 * @param p_user_category_name Holds NLS value for category name
 * @param p_pbc_information_category This context value determines which
 * Flexfield Structure to use with the Developer Descriptive flexfield
 * segments.
 * @param p_pbc_information1 Developer Descriptive flexfield segment.
 * @param p_pbc_information2 Developer Descriptive flexfield segment.
 * @param p_pbc_information3 Developer Descriptive flexfield segment.
 * @param p_pbc_information4 Developer Descriptive flexfield segment.
 * @param p_pbc_information5 Developer Descriptive flexfield segment.
 * @param p_pbc_information6 Developer Descriptive flexfield segment.
 * @param p_pbc_information7 Developer Descriptive flexfield segment.
 * @param p_pbc_information8 Developer Descriptive flexfield segment.
 * @param p_pbc_information9 Developer Descriptive flexfield segment.
 * @param p_pbc_information10 Developer Descriptive flexfield segment.
 * @param p_pbc_information11 Developer Descriptive flexfield segment.
 * @param p_pbc_information12 Developer Descriptive flexfield segment.
 * @param p_pbc_information13 Developer Descriptive flexfield segment.
 * @param p_pbc_information14 Developer Descriptive flexfield segment.
 * @param p_pbc_information15 Developer Descriptive flexfield segment.
 * @param p_pbc_information16 Developer Descriptive flexfield segment.
 * @param p_pbc_information17 Developer Descriptive flexfield segment.
 * @param p_pbc_information18 Developer Descriptive flexfield segment.
 * @param p_pbc_information19 Developer Descriptive flexfield segment.
 * @param p_pbc_information20 Developer Descriptive flexfield segment.
 * @param p_pbc_information21 Developer Descriptive flexfield segment.
 * @param p_pbc_information22 Developer Descriptive flexfield segment.
 * @param p_pbc_information23 Developer Descriptive flexfield segment.
 * @param p_pbc_information24 Developer Descriptive flexfield segment.
 * @param p_pbc_information25 Developer Descriptive flexfield segment.
 * @param p_pbc_information26 Developer Descriptive flexfield segment.
 * @param p_pbc_information27 Developer Descriptive flexfield segment.
 * @param p_pbc_information28 Developer Descriptive flexfield segment.
 * @param p_pbc_information29 Developer Descriptive flexfield segment.
 * @param p_pbc_information30 Developer Descriptive flexfield segment.
 * @param p_balance_category_id If p_validate is false, this uniquely
 * identifies the balance category created. If p_validate is set to true, this
 * parameter will be null.
 * @param p_effective_start_date If p_validate is false, then set to the
 * earliest effective start date for the created balance category. If
 * p_validate is true, then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date for the created balance category. If p_validate is true,
 * then set to null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created balance category. If p_validate is true, then
 * the value will be null.
 * @rep:displayname Create Balance Category
 * @rep:category BUSINESS_ENTITY PAY_BALANCE
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_balance_category
  (p_validate                      in            boolean  default false
  ,p_effective_date                in            date
  ,p_category_name                 in            varchar2
  ,p_business_group_id             in            number   default null
  ,p_legislation_code              in            varchar2 default null
  ,p_save_run_balance_enabled      in            varchar2 default null
  ,p_user_category_name            in            varchar2 default null
  ,p_pbc_information_category      in            varchar2 default null
  ,p_pbc_information1              in            varchar2 default null
  ,p_pbc_information2              in            varchar2 default null
  ,p_pbc_information3              in            varchar2 default null
  ,p_pbc_information4              in            varchar2 default null
  ,p_pbc_information5              in            varchar2 default null
  ,p_pbc_information6              in            varchar2 default null
  ,p_pbc_information7              in            varchar2 default null
  ,p_pbc_information8              in            varchar2 default null
  ,p_pbc_information9              in            varchar2 default null
  ,p_pbc_information10             in            varchar2 default null
  ,p_pbc_information11             in            varchar2 default null
  ,p_pbc_information12             in            varchar2 default null
  ,p_pbc_information13             in            varchar2 default null
  ,p_pbc_information14             in            varchar2 default null
  ,p_pbc_information15             in            varchar2 default null
  ,p_pbc_information16             in            varchar2 default null
  ,p_pbc_information17             in            varchar2 default null
  ,p_pbc_information18             in            varchar2 default null
  ,p_pbc_information19             in            varchar2 default null
  ,p_pbc_information20             in            varchar2 default null
  ,p_pbc_information21             in            varchar2 default null
  ,p_pbc_information22             in            varchar2 default null
  ,p_pbc_information23             in            varchar2 default null
  ,p_pbc_information24             in            varchar2 default null
  ,p_pbc_information25             in            varchar2 default null
  ,p_pbc_information26             in            varchar2 default null
  ,p_pbc_information27             in            varchar2 default null
  ,p_pbc_information28             in            varchar2 default null
  ,p_pbc_information29             in            varchar2 default null
  ,p_pbc_information30             in            varchar2 default null
  ,p_balance_category_id              out nocopy number
  ,p_effective_start_date             out nocopy date
  ,p_effective_end_date               out nocopy date
  ,p_object_version_number            out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_balance_category >----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates a balance category.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The balance category as identified by the in parameters
 * p_balance_category_id and p_object_version_number must already exist.
 *
 * <p><b>Post Success</b><br>
 * The balance category will be successfully updated in the database.
 *
 * <p><b>Post Failure</b><br>
 * The API does not update the balance category and raises an error.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Determines when the DateTrack operation comes into
 * force.
 * @param p_datetrack_update_mode Indicates which DateTrack mode to use when
 * updating the record. You must set to either UPDATE, CORRECTION,
 * UPDATE_OVERRIDE or UPDATE_CHANGE_INSERT. Modes available for use with a
 * particular record depend on the dates of previous record changes and the
 * effective date of this change.
 * @param p_balance_category_id {@rep:casecolumn
 * PAY_BALANCE_CATEGORIES_F.BALANCE_CATEGORY_ID}
 * @param p_object_version_number Pass in the current version number of the
 * balance category to be updated. When the API completes if p_validate is
 * false, will be set to the new version number of the updated balance
 * category. If p_validate is true will be set to the same value which was
 * passed in.
 * @param p_business_group_id Business Group of the Record.
 * @param p_legislation_code Legislation Code
 * @param p_save_run_balance_enabled Flag for determining whether run balances
 * are to be created
 * @param p_user_category_name Provides NLS support for category_name column
 * @param p_pbc_information_category This context value determines which
 * Flexfield Structure to use with the Developer Descriptive flexfield
 * segments.
 * @param p_pbc_information1 Developer Descriptive flexfield segment.
 * @param p_pbc_information2 Developer Descriptive flexfield segment.
 * @param p_pbc_information3 Developer Descriptive flexfield segment.
 * @param p_pbc_information4 Developer Descriptive flexfield segment.
 * @param p_pbc_information5 Developer Descriptive flexfield segment.
 * @param p_pbc_information6 Developer Descriptive flexfield segment.
 * @param p_pbc_information7 Developer Descriptive flexfield segment.
 * @param p_pbc_information8 Developer Descriptive flexfield segment.
 * @param p_pbc_information9 Developer Descriptive flexfield segment.
 * @param p_pbc_information10 Developer Descriptive flexfield segment.
 * @param p_pbc_information11 Developer Descriptive flexfield segment.
 * @param p_pbc_information12 Developer Descriptive flexfield segment.
 * @param p_pbc_information13 Developer Descriptive flexfield segment.
 * @param p_pbc_information14 Developer Descriptive flexfield segment.
 * @param p_pbc_information15 Developer Descriptive flexfield segment.
 * @param p_pbc_information16 Developer Descriptive flexfield segment.
 * @param p_pbc_information17 Developer Descriptive flexfield segment.
 * @param p_pbc_information18 Developer Descriptive flexfield segment.
 * @param p_pbc_information19 Developer Descriptive flexfield segment.
 * @param p_pbc_information20 Developer Descriptive flexfield segment.
 * @param p_pbc_information21 Developer Descriptive flexfield segment.
 * @param p_pbc_information22 Developer Descriptive flexfield segment.
 * @param p_pbc_information23 Developer Descriptive flexfield segment.
 * @param p_pbc_information24 Developer Descriptive flexfield segment.
 * @param p_pbc_information25 Developer Descriptive flexfield segment.
 * @param p_pbc_information26 Developer Descriptive flexfield segment.
 * @param p_pbc_information27 Developer Descriptive flexfield segment.
 * @param p_pbc_information28 Developer Descriptive flexfield segment.
 * @param p_pbc_information29 Developer Descriptive flexfield segment.
 * @param p_pbc_information30 Developer Descriptive flexfield segment.
 * @param p_effective_start_date If p_validate is false, then set to the
 * effective start date on the updated balance category row which now exists as
 * of the effective date. If p_validate is true, then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date on the updated balance category row which now exists as
 * of the effective date. If p_validate is true, then set to null.
 * @rep:displayname Update Balance Category
 * @rep:category BUSINESS_ENTITY PAY_BALANCE
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_balance_category
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_datetrack_update_mode         in     varchar2
  ,p_balance_category_id           in     number
  ,p_object_version_number         in out nocopy number
  ,p_business_group_id             in     number   default hr_api.g_number
  ,p_legislation_code              in     varchar2 default hr_api.g_varchar2
  ,p_save_run_balance_enabled      in     varchar2 default hr_api.g_varchar2
  ,p_user_category_name            in     varchar2 default hr_api.g_varchar2
  ,p_pbc_information_category      in     varchar2 default hr_api.g_varchar2
  ,p_pbc_information1              in     varchar2 default hr_api.g_varchar2
  ,p_pbc_information2              in     varchar2 default hr_api.g_varchar2
  ,p_pbc_information3              in     varchar2 default hr_api.g_varchar2
  ,p_pbc_information4              in     varchar2 default hr_api.g_varchar2
  ,p_pbc_information5              in     varchar2 default hr_api.g_varchar2
  ,p_pbc_information6              in     varchar2 default hr_api.g_varchar2
  ,p_pbc_information7              in     varchar2 default hr_api.g_varchar2
  ,p_pbc_information8              in     varchar2 default hr_api.g_varchar2
  ,p_pbc_information9              in     varchar2 default hr_api.g_varchar2
  ,p_pbc_information10             in     varchar2 default hr_api.g_varchar2
  ,p_pbc_information11             in     varchar2 default hr_api.g_varchar2
  ,p_pbc_information12             in     varchar2 default hr_api.g_varchar2
  ,p_pbc_information13             in     varchar2 default hr_api.g_varchar2
  ,p_pbc_information14             in     varchar2 default hr_api.g_varchar2
  ,p_pbc_information15             in     varchar2 default hr_api.g_varchar2
  ,p_pbc_information16             in     varchar2 default hr_api.g_varchar2
  ,p_pbc_information17             in     varchar2 default hr_api.g_varchar2
  ,p_pbc_information18             in     varchar2 default hr_api.g_varchar2
  ,p_pbc_information19             in     varchar2 default hr_api.g_varchar2
  ,p_pbc_information20             in     varchar2 default hr_api.g_varchar2
  ,p_pbc_information21             in     varchar2 default hr_api.g_varchar2
  ,p_pbc_information22             in     varchar2 default hr_api.g_varchar2
  ,p_pbc_information23             in     varchar2 default hr_api.g_varchar2
  ,p_pbc_information24             in     varchar2 default hr_api.g_varchar2
  ,p_pbc_information25             in     varchar2 default hr_api.g_varchar2
  ,p_pbc_information26             in     varchar2 default hr_api.g_varchar2
  ,p_pbc_information27             in     varchar2 default hr_api.g_varchar2
  ,p_pbc_information28             in     varchar2 default hr_api.g_varchar2
  ,p_pbc_information29             in     varchar2 default hr_api.g_varchar2
  ,p_pbc_information30             in     varchar2 default hr_api.g_varchar2
  ,p_effective_start_date             out nocopy date
  ,p_effective_end_date               out nocopy date
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_balance_category >----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes a balance category.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The balance category as identified by the in parameters
 * p_balance_category_id and p_object_version_number must already exist.
 *
 * <p><b>Post Success</b><br>
 * The balance category will be successfully deleted from the database.
 *
 * <p><b>Post Failure</b><br>
 * The API does not delete the balance category and raises an error.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Determines when the DateTrack operation comes into
 * force.
 * @param p_datetrack_delete_mode Indicates which DateTrack mode to use when
 * deleting the record. You must set to either ZAP, DELETE, FUTURE_CHANGE or
 * DELETE_NEXT_CHANGE. Modes available for use with a particular record depend
 * on the dates of previous record changes and the effective date of this
 * change.
 * @param p_balance_category_id {@rep:casecolumn
 * PAY_BALANCE_CATEGORIES_F.BALANCE_CATEGORY_ID}
 * @param p_object_version_number Pass in the current version number of the
 * balance category to be deleted. When the API completes if p_validate is
 * false, will be set to the new version number of the deleted balance
 * category. If p_validate is true will be set to the same value which was
 * passed in.
 * @param p_business_group_id Business Group of the Record.
 * @param p_legislation_code Legislation Code
 * @param p_effective_start_date If p_validate is false, then set to the
 * effective start date for the deleted balance category row which now exists
 * as of the effective date. If p_validate is true or all row instances have
 * been deleted then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date for the deleted balance category row which now exists as
 * of the effective date. If p_validate is true or all row instances have been
 * deleted then set to null.
 * @rep:displayname Delete Balance Category
 * @rep:category BUSINESS_ENTITY PAY_BALANCE
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_balance_category
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_datetrack_delete_mode         in     varchar2
  ,p_balance_category_id           in     number
  ,p_object_version_number         in out nocopy number
  ,p_business_group_id             in     number   default hr_api.g_number
  ,p_legislation_code              in     varchar2 default hr_api.g_varchar2
  ,p_effective_start_date             out nocopy date
  ,p_effective_end_date               out nocopy date
  );
--
function return_dml_status return boolean;
--
end PAY_BALANCE_CATEGORY_API;

 

/
