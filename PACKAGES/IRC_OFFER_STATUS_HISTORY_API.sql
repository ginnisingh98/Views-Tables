--------------------------------------------------------
--  DDL for Package IRC_OFFER_STATUS_HISTORY_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_OFFER_STATUS_HISTORY_API" AUTHID CURRENT_USER as
/* $Header: iriosapi.pkh 120.8.12010000.1 2008/07/28 12:43:59 appldev ship $ */
/*#
 * This package contains APIs for maintaining offer status history.
 * @rep:scope public
 * @rep:product irc
 * @rep:displayname Offer Status History
*/
--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_offer_status_history >--------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a new offer status history.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with iRecruitment.
 *
 * <p><b>Prerequisites</b><br>
 * None
 *
 * <p><b>Post Success</b><br>
 * A new record is successfully inserted.
 *
 * <p><b>Post Failure</b><br>
 * The API does not create an offer status history and raises an error.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Determines when the DateTrack operation comes
 * into force.
 * @param p_offer_id The associated offer ID for
 * this status history record.
 * @param p_status_change_date The date on which the offer status was changed.
 * @param p_offer_status The offer status for the record.
 * @param p_change_reason The reason for the change in the offer status.
 * @param p_decline_reason The reason for declining the offer.
 * @param p_note_text Offer notes text.
 * @param p_offer_status_history_id Primary key of the offer status history in
 * IRC_OFFER_STATUS_HISTORY table.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created assignment detail. If p_validate is true,
 * then the value will be null.
 * @rep:displayname Create Offer Status History
 * @rep:category BUSINESS_ENTITY IRC_JOB_OFFER
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
  procedure create_offer_status_history
  ( P_VALIDATE           IN  boolean  default false
   ,P_EFFECTIVE_DATE     IN  DATE     default null
   ,P_OFFER_ID           IN  NUMBER
   ,P_STATUS_CHANGE_DATE IN  DATE     default null
   ,P_OFFER_STATUS       IN  VARCHAR2
   ,P_CHANGE_REASON      IN  VARCHAR2 default null
   ,P_DECLINE_REASON     IN  VARCHAR2 default null
   ,P_NOTE_TEXT          IN  VARCHAR2 default null
   ,P_OFFER_STATUS_HISTORY_ID    OUT nocopy NUMBER
   ,P_OBJECT_VERSION_NUMBER      OUT nocopy NUMBER
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------< update_offer_status_history >--------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates an offer status history record.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with iRecruitment.
 *
 * <p><b>Prerequisites</b><br>
 * The offer status history must exist.
 *
 * <p><b>Post Success</b><br>
 * The record gets successfully updated.
 *
 * <p><b>Post Failure</b><br>
 * The API does not update the offer and an error will be raised.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Determines when the DateTrack operation comes into
 * force.
 * @param p_offer_status_history_id Primary key of the offer status history in
 * IRC_OFFER_STATUS_HISTORY table.
 * @param p_offer_id The associated Offer ID for
 * this status history record.
 * @param p_status_change_date The date on which the offer status was changed.
 * @param p_offer_status The offer status for the record.
 * @param p_change_reason The reason for the change in the offer status.
 * @param p_decline_reason The reason for declining the offer.
 * @param p_note_text Offer Notes Text.
 * @param p_object_version_number Pass in the current version number of the
 * note to be updated. When the API completes if p_validate is
 * false, will be set to the new version number of the updated note.
 * If p_validate is true will be set to the same value which was
 * passed in.
 * @rep:displayname Update Offer Status History
 * @rep:category BUSINESS_ENTITY IRC_JOB_OFFER
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
  procedure update_offer_status_history
  ( P_VALIDATE                 IN   boolean   default false
   ,P_EFFECTIVE_DATE           IN   DATE      default null
   ,P_OFFER_STATUS_HISTORY_ID  IN   NUMBER
   ,P_OFFER_ID                 IN   NUMBER
   ,P_STATUS_CHANGE_DATE       IN   DATE
   ,P_OFFER_STATUS             IN   VARCHAR2
   ,P_CHANGE_REASON            IN   VARCHAR2  default null
   ,P_DECLINE_REASON           IN   VARCHAR2  default null
   ,P_NOTE_TEXT                IN   VARCHAR2  default null
   ,P_OBJECT_VERSION_NUMBER    IN OUT  nocopy    NUMBER
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------< delete_offer_status_history >--------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes an offer status history record.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with iRecruitment.
 *
 * <p><b>Prerequisites</b><br>
 * The offer status history must exist.
 *
 * <p><b>Post Success</b><br>
 * The current offer status history record will be deleted.
 *
 * <p><b>Post Failure</b><br>
 * The record will not be deleted and an error is raised.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_offer_id The associated offer ID for
 * this status history record.
 * @param p_effective_date Determines when the DateTrack operation comes into
 * force.
 * @rep:displayname Delete Offer Status History
 * @rep:category BUSINESS_ENTITY IRC_JOB_OFFER
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
  procedure delete_offer_status_history
  ( P_VALIDATE                   IN   boolean   default false
   ,P_OFFER_ID                   IN   NUMBER
   ,P_EFFECTIVE_DATE             IN   DATE
  );
--
end IRC_OFFER_STATUS_HISTORY_API;

/
