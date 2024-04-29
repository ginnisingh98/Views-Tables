--------------------------------------------------------
--  DDL for Package HR_RETAINED_RIGHTS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_RETAINED_RIGHTS_API" AUTHID CURRENT_USER as
/* $Header: peretapi.pkh 120.1 2005/10/02 02:23:54 aroussel $ */
/*#
 * This package contains APIs which create and maintain retained rights.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Retained Rights
*/
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_retained_right >-----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a retained right for a collective agreement entitlement
 * result record.
 *
 * A retained right is a retained entitlement (benefit) which is granted to a
 * person, by virtue of the collective agreement they were previously or are
 * currently covered by. Although no longer qualifying for the benefit that
 * they were eligible for previously, the collective agreement may specify that
 * the entitlement may not be taken away from the person for a period of time.
 * An example could be the regional salary allowance that a person once
 * qualified for by working within that region, but following a change in
 * location, they should not be able to receive. If the regional allowance was
 * designated as a retained right within the collective agreement, then that
 * benefit will still be paid to the person for the duration of the retained
 * right.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * Entitlement result record exists
 *
 * <p><b>Post Success</b><br>
 * The retained right record is created and the API sets the following out
 *
 * <p><b>Post Failure</b><br>
 * The API does not create the retained right and raises an error.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_cagr_entitlement_result_id Uniquely identifies the collective
 * agreement entitlement result that the retained right is to be created for.
 * @param p_start_date Start date of the retained right record.
 * @param p_end_date End date of the retained right record.
 * @param p_freeze_flag Flag indicating whether the retained right should be
 * created with the entitlement result values, or whether the values for the
 * retained right should be re-evaluated.
 * @param p_cagr_retained_right_id If p_validate is false, uniquely identifies
 * the retained right created. If p_validate is true, set to null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created retained right. If p_validate is true, then
 * the value will be null.
 * @rep:displayname Create Retained Right
 * @rep:category BUSINESS_ENTITY PER_COLLECTIVE_AGREEMENT
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_retained_right
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_cagr_entitlement_result_id    in     number
  ,p_start_date                    in     date
  ,p_end_date                      in     date     default hr_api.g_date
  ,p_freeze_flag                   in     varchar2 default hr_api.g_varchar2
  ,p_cagr_retained_right_id           out nocopy number
  ,p_object_version_number            out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_retained_right >-----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates a retained right record as identified by the value for
 * p_cagr_retained_right_id and p_object_version_number.
 *
 * A retained right is a retained entitlement (benefit) which is granted to a
 * person, by virtue of the collective agreement they were previously or are
 * currently covered by. Although no longer qualifying for the benefit that
 * they were eligible for previously, the collective agreement may specify that
 * the entitlement may not be taken away from the person for a period of time.
 * An example could be the regional salary allowance that a person once
 * qualified for by working within that region, but following a change in
 * location, they should not be able to receive. If the regional allowance was
 * designated as a retained right within the collective agreement, then that
 * benefit will still be paid to the person for the duration of the retained
 * right.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The retained right record identified by p_cagr_retained_right_id and
 * object_version_number must exist.
 *
 * <p><b>Post Success</b><br>
 * The retained right record is updated and the API sets the following out
 *
 * <p><b>Post Failure</b><br>
 * The API does not update the retained right and raises an error.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_cagr_retained_right_id Uniquely identifies the retained right to be
 * updated.
 * @param p_end_date End date for the retained right record.
 * @param p_object_version_number Pass in the current version number of the
 * retained right to be updated. When the API completes if p_validate is false,
 * will be set to the new version number of the updated retained right. If
 * p_validate is true will be set to the same value which was passed in.
 * @rep:displayname Update Retained Right
 * @rep:category BUSINESS_ENTITY PER_COLLECTIVE_AGREEMENT
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_retained_right
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_cagr_retained_right_id        in     number
  ,p_end_date                      in     date  default hr_api.g_date
  ,p_object_version_number         in out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_retained_right >-----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes a retained right for a person as identified by the
 * parameter p_cagr_retained_right_id and p_object_version_number.
 *
 * A retained right is a retained entitlement (benefit) which is granted to a
 * person, by virtue of the collective agreement they were previously or are
 * currently covered by. Although no longer qualifying for the benefit that
 * they were eligible for previously, the collective agreement may specify that
 * the entitlement may not be taken away from the person for a period of time.
 * An example could be the regional salary allowance that a person once
 * qualified for by working within that region, but following a change in
 * location, they should not be able to receive. If the regional allowance was
 * designated as a retained right within the collective agreement, then that
 * benefit will still be paid to the person for the duration of the retained
 * right.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The retained right as identified by the in parameter
 * p_cagr_retained_right_id and the in out parameter p_object_version_number
 * must already exist.
 *
 * <p><b>Post Success</b><br>
 * The retained right is deleted.
 *
 * <p><b>Post Failure</b><br>
 * The API does not delete the retained right and raises an error.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_cagr_retained_right_id Uniquely identifies the retained right to be
 * deleted.
 * @param p_object_version_number Current version number of the retained right
 * to be deleted.
 * @rep:displayname Delete Retained Right
 * @rep:category BUSINESS_ENTITY PER_COLLECTIVE_AGREEMENT
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_retained_right
  (p_validate                      in     boolean  default false
  ,p_cagr_retained_right_id        in     number
  ,p_object_version_number         in     number
  );
--
--
end HR_RETAINED_RIGHTS_API;

 

/
