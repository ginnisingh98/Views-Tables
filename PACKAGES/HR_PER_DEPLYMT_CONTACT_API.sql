--------------------------------------------------------
--  DDL for Package HR_PER_DEPLYMT_CONTACT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_PER_DEPLYMT_CONTACT_API" AUTHID CURRENT_USER as
/* $Header: hrpdcapi.pkh 120.1.12010000.2 2008/08/06 08:46:38 ubhat ship $ */
/*#
 * This package contains global deployment contact APIs.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Person Deployment Contact
*/
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_per_deplymt_contact >--------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a deployment contact record.
 *
 * When a Deployment is initiated for an Employee from one Business Group to
 * another,this API creates a Contact Relationship for the Employee in the
 * Destination Business group, based on the contact information in the Source
 * Business Group.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The deployment record already exists in the database. The contact
 * relationship specified must exist and be for the same employee as
 * the deployment.
 *
 * <p><b>Post Success</b><br>
 * The deployment contact record is created successfully.
 *
 * <p><b>Post Failure</b><br>
 * The deployment contact record is not created and an error is raised.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_person_deployment_id Identifies the deployment record to which this
 * deployment contact applies.
 * @param p_contact_relationship_id The contact relationship which should be
 * copied when the deployment is initiated.
 * @param p_per_deplymt_contact_id If p_validate is false, then this uniquely
 * identifies the deployment contact record created. If p_validate is true,
 * then set to null.
 * @param p_object_version_number If p_validate is false, then set to
 * the version number of the created deployment contact. If p_validate is true,
 * then the value will be null.
 * @rep:displayname Create Deployment Contact
 * @rep:category BUSINESS_ENTITY PER_CONTACT_RELATIONSHIP
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_per_deplymt_contact
  (p_validate                         in     boolean  default false
  ,p_person_deployment_id             in     number
  ,p_contact_relationship_id          in     number
  ,p_per_deplymt_contact_id              out nocopy   number
  ,p_object_version_number               out nocopy   number
  );
--
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_per_deplymt_contact >--------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes a deployment contact record.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The deployment contact record already exists.
 *
 * <p><b>Post Success</b><br>
 * The deployment contact record is deleted.
 *
 * <p><b>Post Failure</b><br>
 * The deployment contact record is not deleted, and an error is raised.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_per_deplymt_contact_id Identifies the deployment contact record
 * to delete.
 * @param p_object_version_number Current version number of the deployment
 * contact to be deleted.
 * @rep:displayname Delete Deployment Contact
 * @rep:category BUSINESS_ENTITY PER_CONTACT_RELATIONSHIP
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_per_deplymt_contact
  (p_validate                      in     boolean  default false
  ,p_per_deplymt_contact_id        in     number
  ,p_object_version_number         in     number
  );
end HR_PER_DEPLYMT_CONTACT_API;

/
