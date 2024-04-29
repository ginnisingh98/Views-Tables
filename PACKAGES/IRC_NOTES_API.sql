--------------------------------------------------------
--  DDL for Package IRC_NOTES_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_NOTES_API" AUTHID CURRENT_USER as
/* $Header: irinoapi.pkh 120.3 2008/02/21 14:14:34 viviswan noship $ */
/*#
 * This package contains APIs to maintain notes for offers.
 * @rep:scope public
 * @rep:product irc
 * @rep:displayname Note
*/
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< create_note >----------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates new records in the IRC_NOTES table.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with iRecruitment.
 *
 * <p><b>Prerequisites</b><br>
 * The offer_status_history_id should exist in IRC_OFFER_STATUS_HISTORY table.
 *
 * <p><b>Post Success</b><br>
 * Sucessfully inserts a new record in the IRC_NOTES table.
 *
 * <p><b>Post Failure</b><br>
 * The API does not create the record in the IRC_NOTES table and
 * raises an error.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_offer_status_history_id Identifies the record in the
 * IRC_OFFER_STATUS_HISTORY table.
 * @param p_note_text The offer notes text.
 * @param p_note_id Primary key of the note in the IRC_NOTES table.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created assignment detail. If p_validate is true,
 * then the value will be null.
 * @rep:displayname Create Note
 * @rep:category BUSINESS_ENTITY IRC_JOB_OFFER_NOTES
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure CREATE_NOTE
  (p_validate                      in     boolean  default false
  ,p_offer_status_history_id       in     number
  ,p_note_text                     in     varchar2
  ,p_note_id                          out nocopy   number
  ,p_object_version_number            out nocopy   number
  );
--
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< update_note >----------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates records in the IRC_NOTES table.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with iRecruitment.
 *
 * <p><b>Prerequisites</b><br>
 * The note_id must exist in IRC_NOTES table.
 *
 * <p><b>Post Success</b><br>
 * The record in the IRC_NOTES will be successfully updated.
 *
 * <p><b>Post Failure</b><br>
 * The API does not update the record and raises an error.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 *
 * @param p_note_id Identifies the note in the IRC_NOTES table.
 * @param p_offer_status_history_id Identifies the record in the
 * IRC_OFFER_STATUS_HISTORY table.
 * @param p_note_text The text of the offer note.
 * @param p_object_version_number Pass in the current version number of the
 * note to be updated. When the API completes if p_validate is
 * false, will be set to the new version number of the updated note.
 * If p_validate is true will be set to the same value which was
 * passed in.
 * @rep:displayname Update Note
 * @rep:category BUSINESS_ENTITY IRC_JOB_OFFER_NOTES
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure UPDATE_NOTE
  (p_validate                      in     boolean  default false
  ,p_note_id                       in     number
  ,p_offer_status_history_id       in     number   default hr_api.g_number
  ,p_note_text                     in     varchar2 default hr_api.g_varchar2
  ,p_object_version_number         in out nocopy   number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< delete_note >----------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes records from the IRC_NOTES table.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with iRecruitment.
 *
 * <p><b>Prerequisites</b><br>
 * The notes_id must exist in IRC_NOTES table.
 *
 * <p><b>Post Success</b><br>
 * The record will be deleted
 *
 * <p><b>Post Failure</b><br>
 * The record will not be deleted and an error is raised.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_note_id Identifies the note in the IRC_NOTES table.
 * @param p_object_version_number Current version number of the note to
 * be deleted.
 * @rep:displayname Delete Note
 * @rep:category BUSINESS_ENTITY IRC_JOB_OFFER_NOTES
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure DELETE_NOTE
  (p_validate                      in     boolean  default false
  ,p_note_id                       in     number
  ,p_object_version_number         in     number
  );
--
end IRC_NOTES_API;

/
