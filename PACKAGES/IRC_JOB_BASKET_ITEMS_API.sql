--------------------------------------------------------
--  DDL for Package IRC_JOB_BASKET_ITEMS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_JOB_BASKET_ITEMS_API" AUTHID CURRENT_USER as
/* $Header: irjbiapi.pkh 120.2 2008/02/21 14:31:22 viviswan noship $ */
/*#
 * This package contains Job Basket APIs.
 * @rep:scope public
 * @rep:product irc
 * @rep:displayname Job Basket
*/
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_job_basket_item >----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates an item in a person's job basket.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with iRecruitment.
 *
 * <p><b>Prerequisites</b><br>
 * The person and recruitment activity must exist in the database
 *
 * <p><b>Post Success</b><br>
 * A job basket item will be added
 *
 * <p><b>Post Failure</b><br>
 * The job basket item will not be added and an error will be raised
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_recruitment_activity_id The recruitment activity for the job basket
 * item
 * @param p_person_id Identifies the person for whom you create the job basket
 * record.
 * @param p_job_basket_item_id If p_validate is false, then this uniquely
 * identifies the job basket item created. If p_validate is true, then set to
 * null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created job basket item. If p_validate is true, then
 * the value will be null.
 * @rep:displayname Create Job Basket Item
 * @rep:category BUSINESS_ENTITY IRC_JOB_BASKET
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_job_basket_item
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_recruitment_activity_id       in     number
  ,p_person_id                     in     number
  ,p_job_basket_item_id            out   nocopy number
  ,p_object_version_number         out   nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_job_basket_item >----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API removes an item from a persons job basket.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with iRecruitment.
 *
 * <p><b>Prerequisites</b><br>
 * The job basket item must exist in the database
 *
 * <p><b>Post Success</b><br>
 * The job basket item will be removed
 *
 * <p><b>Post Failure</b><br>
 * The job basket item will not be removed and an error will be raised
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_object_version_number Current version number of the job basket item
 * to be deleted.
 * @param p_job_basket_item_id Identifies the job basket item that is being
 * removed
 * @rep:displayname Delete Job Basket Item
 * @rep:category BUSINESS_ENTITY IRC_JOB_BASKET
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_job_basket_item
  (p_validate                      in     boolean  default false
  ,p_object_version_number         in     number
  ,p_job_basket_item_id            in     number
  );
--

end irc_job_basket_items_api;

/
