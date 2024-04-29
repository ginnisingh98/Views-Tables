--------------------------------------------------------
--  DDL for Package IRC_TEMPLATE_ASSOCIATION_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_TEMPLATE_ASSOCIATION_API" AUTHID CURRENT_USER as
/* $Header: iritaapi.pkh 120.4 2008/02/21 14:28:15 viviswan noship $ */
/*#
 * This package contains APIs for managing template association for an
 * organisation or job or position.
 * @rep:scope public
 * @rep:product irc
 * @rep:displayname Template Association
*/
--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_template_association >--------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a new template association.
 *
 * This api creates template association for an organisation, job or position.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with iRecruitment.
 *
 * <p><b>Prerequisites</b><br>
 * A valid Template is required to create a new template association.
 *
 * <p><b>Post Success</b><br>
 * The API creates the template association.
 *
 * <p><b>Post Failure</b><br>
 * The API does not create a template association and an error is raised.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_template_id Identifies the associated template.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does
 * not determine when the changes take effect.
 * @param p_default_association Identifies the default template association.
 * @param p_job_id Identifies the job that is associated with the template
 * association.
 * @param p_position_id Identifies the position that is associated with
 * the template association.
 * @param p_organization_id Identifies the organization that is associated
 * with the template association.
 * @param p_start_date The start date from which the template association is
 * in effect.
 * @param p_end_date The last date till which the template association
 * is active.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created template association. If p_validate is true,
 * then the value will be null.
 * @param p_template_association_id Primary key of the template association.
 * @rep:displayname Create Template Association
 * @rep:category BUSINESS_ENTITY IRC_JOB_OFFER_LETTER_TEMPLATE
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_template_association
  (p_validate                         in  boolean    default false
  ,p_template_id                      in  number
  ,p_effective_date                   in  date       default null
  ,p_default_association              in  varchar2   default null
  ,p_job_id                           in  number     default null
  ,p_position_id                      in  number     default null
  ,p_organization_id                  in  number     default null
  ,p_start_date                       in  date       default null
  ,p_end_date                         in  date       default null
  ,p_object_version_number            out NOCOPY number
  ,p_template_association_id          out NOCOPY number
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------< update_template_association >--------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates template association for an organization, job
 * or position.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with iRecruitment.
 *
 * <p><b>Prerequisites</b><br>
 * Template association must already exist.
 *
 * <p><b>Post Success</b><br>
 * The API updates the template association.
 *
 * <p><b>Post Failure</b><br>
 * Template association will not be updated and an error will be raised.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does
 * not determine when the changes take effect.
 * @param p_template_association_id Identifies the template association.
 * @param p_template_id Identifies the associated template.
 * @param p_default_association Identifies the default tempalte association.
 * @param p_job_id Identifies the job that is associated with the template
 * association.
 * @param p_position_id Identifies the position that is associated with
 * the template association.
 * @param p_organization_id Identifies the organization that is associated
 * with the template association.
 * @param p_start_date The start date from which the template association is
 * in effect.
 * @param p_end_date The last date till which the template association
 * is active.
 * @param p_object_version_number Pass in the current version number of the
 * template association to be updated. When the API completes if p_validate is
 * false, will be set to the new version number of the updated
 * template association.
 * If p_validate is true will be set to the same value which was
 * passed in.
 * @rep:displayname Update Template Association
 * @rep:category BUSINESS_ENTITY IRC_JOB_OFFER_LETTER_TEMPLATE
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_template_association
(  p_validate                         in      boolean    default false
  ,p_effective_date                   in      date       default null
  ,p_template_association_id          in      number
  ,p_template_id                      in      number
  ,p_default_association              in      varchar2   default null
  ,p_job_id                           in      number     default null
  ,p_position_id                      in      number     default null
  ,p_organization_id                  in      number     default null
  ,p_start_date                       in      date       default null
  ,p_end_date                         in      date       default null
  ,p_object_version_number            in out  NOCOPY number
);
--
-- ----------------------------------------------------------------------------
-- |-----------------------< delete_template_association >--------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes the template association.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with iRecruitment.
 *
 * <p><b>Prerequisites</b><br>
 * Template association must already exist.
 *
 * <p><b>Post Success</b><br>
 * The API deletes the template association.
 *
 * <p><b>Post Failure</b><br>
 * Template association will not be deleted and an error will be raised.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_template_association_id Identifies the template association.
 * @param p_object_version_number Current version number of the template
 * association to be deleted.
 * @rep:displayname Delete Template Association
 * @rep:category BUSINESS_ENTITY IRC_JOB_OFFER_LETTER_TEMPLATE
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_template_association
  (p_validate                       in       boolean    default false
  ,p_template_association_id        in       number
  ,p_object_version_number          in       number
  );

--
end irc_template_association_api;

/
