--------------------------------------------------------
--  DDL for Package PQH_FR_VALIDATION_EVENTS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_FR_VALIDATION_EVENTS_API" AUTHID CURRENT_USER as
/* $Header: pqvleapi.pkh 120.1 2005/10/02 02:28:47 aroussel $ */
/*#
 * This package contains APIs to create, update and delete events in a services
 * validation process.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Validation Event for France
*/
--
-- ----------------------------------------------------------------------------
-- |-------------------------< insert_validation_event >----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API validates the inputs and creates a new validation event record.
 *
 * During the services validation process for a civil servant the organization
 * needs to record a set of events that happen during the processing. This API
 * creates the event for a services validation record.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * A validation event can be created only for a services validation that is not
 * already validated.
 *
 * <p><b>Post Success</b><br>
 * A validation event is created for the services validation.
 *
 * <p><b>Post Failure</b><br>
 * A validation event is not created in the database and an error is raised
 * @param p_effective_date Specifies the reference date for validating lookup
 * values, applicable within the active date range. This date does not
 * determine when the changes take effect.
 * @param p_validation_id Identifier of the service validation for which the
 * validation event is being created. It references the primary key of
 * PQH_FR_VALIDATIONS. It is a mandatory parameter
 * @param p_event_type Event type code for the validation. Valid values are
 * identified by lookup type 'FR_PQH_EVENT_TYPE'
 * @param p_event_code Event code for the validation corresponding to the event
 * type. Valid values are identified by lookup type 'FR_PQH_VALIDATION_EVENT'.
 * @param p_start_date {@rep:casecolumn PQH_FR_VALIDATION_EVENTS.START_DATE}
 * @param p_end_date {@rep:casecolumn PQH_FR_VALIDATION_EVENTS.END_DATE}
 * @param p_comments Comment text
 * @param p_validation_event_id The process returns the unique validation event
 * identifier generated for each new record as primary key
 * @param p_object_version_number If p_validate is false, the process returns
 * the version number of the created validation event record. If p_validate is
 * true, the process returns null
 * @rep:displayname Create Validation Event
 * @rep:category BUSINESS_ENTITY PQH_FR_SERVICES_VALIDATION
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure Insert_Validation_event
  (
     p_effective_date               in     date
  ,p_validation_id                  in     number
  ,p_event_type                     in     varchar2
  ,p_event_code                     in     varchar2
  ,p_start_date                     in     date     default null
  ,p_end_date                       in     date     default null
  ,p_comments                       in     varchar2 default null
  ,p_validation_event_id               out nocopy number
  ,p_object_version_number             out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_validation_event >----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API validates the changes made to an existing validation event record
 * and updates the record in the database.
 *
 * This API updates records into PQH_FR_VALIDATION_EVENTS table
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * A validation event must exist with the specified object version number.
 *
 * <p><b>Post Success</b><br>
 * The validation event is updated in the database.
 *
 * <p><b>Post Failure</b><br>
 * The validation event is not updated in the database and an error is raised
 * @param p_effective_date Specifies the reference date for validating lookup
 * values, applicable within the active date range. This date does not
 * determine when the changes take effect.
 * @param p_validation_event_id Unique validation event identifier generated
 * for each new record as primary key. It is a mandatory parameter
 * @param p_object_version_number Passes the current version number of the
 * validation event to be updated. When the API completes if p_validate is
 * false, the process returns the new version number of the updated validation
 * event. If p_validate is true, it returns the same value which was passed in
 * @param p_validation_id Identifier of the service validation for which the
 * validation event is being created. It references the primary key of
 * PQH_FR_VALIDATIONS. It is a mandatory parameter
 * @param p_event_type Event type code for the validation. Valid values are
 * identified by lookup type 'FR_PQH_EVENT_TYPE'
 * @param p_event_code Event code for the validation corresponding to the event
 * type. Valid values are identified by lookup type 'FR_PQH_VALIDATION_EVENT'.
 * @param p_start_date {@rep:casecolumn PQH_FR_VALIDATION_EVENTS.START_DATE}
 * @param p_end_date {@rep:casecolumn PQH_FR_VALIDATION_EVENTS.END_DATE}
 * @param p_comments Comment text
 * @rep:displayname Update Validation Event
 * @rep:category BUSINESS_ENTITY PQH_FR_SERVICES_VALIDATION
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure Update_Validation_event
( p_effective_date                in     date
  ,p_validation_event_id          in     number
  ,p_object_version_number        in out nocopy number
  ,p_validation_id                in     number    default hr_api.g_number
  ,p_event_type                   in     varchar2  default hr_api.g_varchar2
  ,p_event_code                   in     varchar2  default hr_api.g_varchar2
  ,p_start_date                   in     date      default hr_api.g_date
  ,p_end_date                     in     date      default hr_api.g_date
  ,p_comments                     in     varchar2  default hr_api.g_varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_validation_event >----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes a validation event record from the database.
 *
 * This API deletes records from PQH_FR_VALIDATION_EVENTS table
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The validation event must exist with the specified object version number.
 *
 * <p><b>Post Success</b><br>
 * The validation event is deleted from the database.
 *
 * <p><b>Post Failure</b><br>
 * The validation event is not deleted from the database and an error is raised
 * @param p_validation_event_id Unique validation event identifier generated
 * for each new record as primary key. It is a mandatory parameter
 * @param p_object_version_number Current version number of the validation
 * event record to be deleted
 * @rep:displayname Delete Validation Event
 * @rep:category BUSINESS_ENTITY PQH_FR_SERVICES_VALIDATION
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
Procedure Delete_Validation_event
  (p_validation_event_id                  in     number
  ,p_object_version_number                in     number);
--
end  PQH_FR_VALIDATION_EVENTS_API;

 

/
