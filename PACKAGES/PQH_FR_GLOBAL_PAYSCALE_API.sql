--------------------------------------------------------
--  DDL for Package PQH_FR_GLOBAL_PAYSCALE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_FR_GLOBAL_PAYSCALE_API" AUTHID CURRENT_USER as
/* $Header: pqginapi.pkh 120.1 2005/10/02 02:45 aroussel $ */
/*#
 * This package contains global payscale APIs.
 * @rep:scope public
 * @rep:product PER
 * @rep:displayname Global Payscale for France
*/
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_indemnity_rate >-----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This procedure creates indemnity rate for global payscale.
 *
 * In this case, type_of_record is assumed to be INM.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The indeminity rates are defined at global site level so there is no
 * prerequsite for it.
 *
 * <p><b>Post Success</b><br>
 * Creates the indeminity rates for global index.
 *
 * <p><b>Post Failure</b><br>
 * Raises appropriate error message and the changes will not be posted to the
 * database.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Determines when the DateTrack operation comes into
 * force.
 * @param p_basic_salary_rate Determines the Basic Salary Rate.
 * @param p_housing_indemnity_rate Determines the Housing Indemnity Rate.
 * @param p_currency_code Determines the Currency.
 * @param p_global_index_id Gives the Global Index Identifier when indeminity
 * get created.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created Indeminity. If p_validate is true, then the
 * value will be null.
 * @param p_effective_start_date If p_validate is false, then set to the
 * earliest effective start date for the created Indeminity. If p_validate is
 * true, then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date for the created Indeminity. If p_validate is true, then
 * set to null.
 * @rep:displayname Create Indemnity Rate
 * @rep:category BUSINESS_ENTITY PQH_GLOBAL_PAY_SCALE
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_indemnity_rate
  ( p_validate                      in     boolean  default false
   ,p_effective_date                 in     date
   ,p_basic_salary_rate              in     number   default null
   ,p_housing_indemnity_rate              in     number   default null
   ,p_currency_code                  in     varchar2
   ,p_global_index_id                   out nocopy number
   ,p_object_version_number             out nocopy number
   ,p_effective_start_date              out nocopy date
   ,p_effective_end_date                out nocopy date
   );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_global_index >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This procedure creates global index for global payscale.
 *
 * In this case type_of_record is assumed to be IND.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * Indeminty rates should exists at the site level.
 *
 * <p><b>Post Success</b><br>
 * Creates a new Global index for the defined gross and increased index.
 *
 * <p><b>Post Failure</b><br>
 * Raises appropriate error message and the changes are not posted to the
 * database.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Determines when the DateTrack operation comes into
 * force.
 * @param p_gross_index Determines the value of Gross index.
 * @param p_increased_index Determines the value of Increased index.
 * @param p_global_index_id Determines the Global Index Identifier when Global
 * index for the Gross and Increased index get created.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created global index for gross and increased index. If
 * p_validate is true, then the value will be null.
 * @param p_effective_start_date If p_validate is false, then set to the
 * earliest effective start date for the created created global index for gross
 * and increased index. If p_validate is true, then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date for the created created global index for gross and
 * increased index. If p_validate is true, then set to null.
 * @rep:displayname Create Global Index
 * @rep:category BUSINESS_ENTITY PQH_GLOBAL_PAY_SCALE
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_global_index
  (p_validate                      in     boolean  default false
   ,p_effective_date                 in     date
   ,p_gross_index                    in     number   default null
   ,p_increased_index                in     number   default null
   ,p_global_index_id                   out nocopy number
   ,p_object_version_number             out nocopy number
   ,p_effective_start_date              out nocopy date
   ,p_effective_end_date                out nocopy date
   );
--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_indemnity_rate >-----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This procedure updates the Indeminity rates for global payscale.
 *
 * Updates the value of basic salary rate, housing indeminity rate or Currency
 * for the Global index.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The global index identifier should exist.
 *
 * <p><b>Post Success</b><br>
 * Updates the changed value to the database as of the effective date.
 *
 * <p><b>Post Failure</b><br>
 * Raises appropriate error message and the changes are not posted to the
 * database.
 *
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
 * @param p_global_index_id Determines the Global Index Identifier which needed
 * to be updated.
 * @param p_object_version_number Pass in the current version number of the
 * global index to be updated. When the API completes if p_validate is false,
 * will be set to the new version number of the updated Global index. If
 * p_validate is true will be set to the same value which was passed in.
 * @param p_basic_salary_rate Determines the changed Basic Salary rate
 * @param p_housing_indemnity_rate Determines the changed Housing Indeminity
 * rate
 * @param p_currency_code Determines the changed Currency
 * @param p_effective_start_date If p_validate is false, then set to the
 * effective start date on the updated global index row which now exists as of
 * the effective date. If p_validate is true, then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date on the updated global index row which now exists as of
 * the effective date. If p_validate is true, then set to null.
 * @rep:displayname Update Indemnity Rate
 * @rep:category BUSINESS_ENTITY PQH_GLOBAL_PAY_SCALE
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_indemnity_rate
  (p_validate                      in     boolean  default false
   ,p_effective_date               in     date
   ,p_datetrack_mode               in     varchar2
   ,p_global_index_id              in     number
   ,p_object_version_number        in out nocopy number
   ,p_basic_salary_rate            in     number    default hr_api.g_number
   ,p_housing_indemnity_rate            in     number    default hr_api.g_number
   ,p_currency_code                in     varchar2
   ,p_effective_start_date            out nocopy date
   ,p_effective_end_date              out nocopy date
   );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_global_index >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This procedure updates the global index for global payscale.
 *
 * Updates the value of Gross and increased for the Global index.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The global index identifier should exist.
 *
 * <p><b>Post Success</b><br>
 * Updates the changed value to the database as of the effective date.
 *
 * <p><b>Post Failure</b><br>
 * Raises appropriate error message and the changes are not posted to the
 * database.
 *
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
 * @param p_global_index_id Determines the Global Index Identifier which needed
 * to be updated.
 * @param p_object_version_number Pass in the current version number of the
 * global index to be updated. When the API completes if p_validate is false,
 * will be set to the new version number of the updated Global index. If
 * p_validate is true will be set to the same value which was passed in.
 * @param p_gross_index Determines the changed Gross Index
 * @param p_increased_index Determines the changed Incresed Index
 * @param p_effective_start_date If p_validate is false, then set to the
 * effective start date on the updated global index row which now exists as of
 * the effective date. If p_validate is true, then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date on the updated global index row which now exists as of
 * the effective date. If p_validate is true, then set to null.
 * @rep:displayname Update Global Index
 * @rep:category BUSINESS_ENTITY PQH_GLOBAL_PAY_SCALE
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_global_index
  (p_validate                      in     boolean  default false
   ,p_effective_date               in     date
   ,p_datetrack_mode               in     varchar2
   ,p_global_index_id              in     number
   ,p_object_version_number        in out nocopy number
   ,p_gross_index                  in     number    default hr_api.g_number
   ,p_increased_index              in     number    default hr_api.g_number
   ,p_effective_start_date            out nocopy date
   ,p_effective_end_date              out nocopy date
   );
--
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_indemnity_rate >-----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This procedure deletes the indeminity rate for global payscale.
 *
 * Procedure deletes or end dates the record depending on the datetrack mode
 * passed as of the effective date
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The global index identifier should exist
 *
 * <p><b>Post Success</b><br>
 * Procedure deletes or updates the record in the database depending on the
 * datetrack mode passed as of the effective date.
 *
 * <p><b>Post Failure</b><br>
 * Raises appropriate error message and the changes are not posted to the
 * database.
 *
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
 * @param p_global_index_id Determines the Global index identifier to be
 * deleted
 * @param p_object_version_number Pass in the current version number of the
 * Indeminity rate to be deletedWhen the API completes if p_validate is false,
 * and record is end dated as of the effective date then it will be set to the
 * new version number of the updated glonal index. Other wise it is set to
 * null.If p_validate is true will be set to the same value which was passed
 * in.
 * @param p_effective_start_date If p_validate is false, then set to the
 * effective start date for the deleted indeminity rate row which now exists as
 * of the effective date. If p_validate is true or all row instances have been
 * deleted then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date for the deleted indeminity rate row which now exists as
 * of the effective date. If p_validate is true or all row instances have been
 * deleted then set to null.
 * @rep:displayname Delete Indemnity Rate
 * @rep:category BUSINESS_ENTITY PQH_GLOBAL_PAY_SCALE
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_indemnity_rate
  (p_validate                      in     boolean  default false
   ,p_effective_date                   in     date
   ,p_datetrack_mode                   in     varchar2
   ,p_global_index_id                  in     number
   ,p_object_version_number            in out nocopy number
   ,p_effective_start_date                out nocopy date
   ,p_effective_end_date                  out nocopy date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_global_index >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This procedure deletes the global index for global payscale.
 *
 * Procedure deletes or end dates the record depending on the datetrack mode
 * passed as of the effective date
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The global index identifier should exist
 *
 * <p><b>Post Success</b><br>
 * Procedure deletes or updates the record in the database depending on the
 * datetrack mode passed as of the effective date.
 *
 * <p><b>Post Failure</b><br>
 * Raises appropriate error message and the changes are not posted to the
 * database.
 *
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
 * @param p_global_index_id Determines the Global index identifier to be
 * deleted
 * @param p_object_version_number Pass in the current version number of the
 * global index to be deleted.When the API completes if p_validate is false,
 * and record is end dated as of the effective date, then it will be set to the
 * new version number of the updated global index. Other wise, it is set to
 * null. If p_validate is true, it will be set to the same value which was
 * passed in.
 * @param p_effective_start_date If p_validate is false, then set to the
 * effective start date for the deleted global index row which now exists as of
 * the effective date. If p_validate is true or all row instances have been
 * deleted then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date for the deleted global index row which now exists as of
 * the effective date. If p_validate is true or all row instances have been
 * deleted then set to null.
 * @rep:displayname Delete Global Index
 * @rep:category BUSINESS_ENTITY PQH_GLOBAL_PAY_SCALE
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_global_index
  (p_validate                          in     boolean  default false
   ,p_effective_date                   in     date
   ,p_datetrack_mode                   in     varchar2
   ,p_global_index_id                  in     number
   ,p_object_version_number            in out nocopy number
   ,p_effective_start_date                out nocopy date
   ,p_effective_end_date                  out nocopy date
  );
--

end pqh_fr_global_payscale_api;

 

/
