--------------------------------------------------------
--  DDL for Package AME_APPROVER_TYPE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AME_APPROVER_TYPE_API" AUTHID CURRENT_USER as
/* $Header: amaptapi.pkh 120.3 2006/09/28 14:03:55 avarri noship $ */
/*#
 * This package contains AME approver type APIs.
 * @rep:scope public
 * @rep:product AME
 * @rep:displayname Approver Type
*/
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_ame_approver_type >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API adds a new approver type.
 *
 * <p><b>Licensing</b><br>
 * This API is available for use with any licensed component of the e-business
 * suite.
 *
 * <p><b>Prerequisites</b><br>
 * The Approver Type should have an entry in wf_roles.
 *
 * <p><b>Post Success</b><br>
 * Approver type is added successfully. approver_type_id,
 * object_version_number, start_date and end_date are set for the
 * added approver type.
 *
 * <p><b>Post Failure</b><br>
 * The approver type is not added and an error is raised.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_orig_system This is the unique approver type name.
 * @param p_approver_type_id If p_validate is false, then this uniquely
 * identifies the added approver type. If p_validate is true, then it is set
 * to null.
 * @param p_object_version_number If p_validate is false, then it is set to
 * version number of the added approver type. If p_validate is true, then it
 * is set to null.
 * @param p_start_date It is the date from which the added approver type is
 * effective.If p_validate is false, then set to the start date
 * of the added approver type. If p_validate is true, then set to null.
 * @param p_end_date It is the date up to, which the added approver type
 * is effective. If p_validate is false, then it is set to 31-Dec-4712.
 * If p_validate is true, then it is set to null.
 * @rep:displayname Create Ame Approver Type
 * @rep:category BUSINESS_ENTITY AME_APPROVER_TYPE
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
*/
--
-- {End Of Comments}
--
procedure create_ame_approver_type
  (p_validate                      in          boolean  default false
  ,p_orig_system                   in          varchar2
  ,p_approver_type_id              out nocopy  number
  ,p_object_version_number         out nocopy  number
  ,p_start_date                    out nocopy  date
  ,p_end_date                      out nocopy  date
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_ame_approver_type >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes the approver type.
 *
 * <p><b>Licensing</b><br>
 * This API is available for use with any licensed component of the e-business
 * suite.
 *
 * <p><b>Prerequisites</b><br>
 * Approver Type Id should be valid.
 *
 * <p><b>Post Success</b><br>
 * Deletes the approver type successfully.
 *
 * <p><b>Post Failure</b><br>
 * The approver type is not deleted and an error is raised.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_approver_type_id This uniquely identifies the approver type
 * to be deleted.
 * @param p_object_version_number Pass in the current version number of
 * the approver type to be deleted. When the API completes if p_validate is
 * false, it will be set to the new version number of the deleted
 * approver type. If p_validate is true, will be set to the same value which
 * was passed in.
 * @param p_start_date If p_validate is false, it is set to the date from
 * which the deleted approver type was effective. If p_validate is true,
 * it is set to the same date which was passed in.
 * @param p_end_date If p_validate is false, it is set to present date.
 * If p_validate is true, it is set to the same date which was passed in.
 * @rep:displayname Delete Ame Approver Type
 * @rep:category BUSINESS_ENTITY AME_APPROVER_TYPE
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
*/
--
-- {End Of Comments}
--
procedure delete_ame_approver_type
  (p_validate                   in              boolean  default false
  ,p_approver_type_id           in              number
  ,p_object_version_number      in out nocopy   number
  ,p_start_date                 out nocopy      date
  ,p_end_date                   out nocopy      date
  );
--
end ame_approver_type_api;

 

/
