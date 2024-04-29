--------------------------------------------------------
--  DDL for Package PER_CANCEL_APPLICATION_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_CANCEL_APPLICATION_API" AUTHID CURRENT_USER as
/* $Header: pecapapi.pkh 120.1 2005/10/02 02:12:39 aroussel $ */
/*#
 * This package contains APIs relating to canceling application.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Cancel Application
*/
--
-- ----------------------------------------------------------------------------
-- |----------------------------< cancel_application >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API cancels an application.
 *
 * The API will delete the record of the application and applicant assignments
 * and restore the personal data from before the application.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The person must be a current applicant with no future person type changes,
 * and there must be a previous non-applicant person type to which the system
 * can revert.
 *
 * <p><b>Post Success</b><br>
 * The application record is deleted and all records related to the applicant
 * assignment. The person data from the period of time prior to becoming an
 * applicant are reinstated.
 *
 * <p><b>Post Failure</b><br>
 * An error is raised and the application and related applicant assignment
 * records are not deleted.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_business_group_id Business group of the applicant
 * @param p_person_id Identifies the person record for which the cancellation
 * is to be processed.
 * @param p_application_id Identifies the application that is to be cancelled.
 * @rep:displayname Cancel Application
 * @rep:category BUSINESS_ENTITY PER_APPLICANT
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure cancel_application
  (p_validate                      in     boolean  default false
  ,p_business_group_id             in     number
  ,p_person_id                     in     number
  ,p_application_id                in     number
  );
--
end per_cancel_application_api;

 

/
