--------------------------------------------------------
--  DDL for Package IRC_OFFERS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_OFFERS_API" AUTHID CURRENT_USER as
/* $Header: iriofapi.pkh 120.10.12010000.1 2008/07/28 12:43:40 appldev ship $ */
/*#
 * This package contains APIs for maintaining offers and offer assignments.
 * @rep:scope public
 * @rep:product irc
 * @rep:displayname Offer
*/
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< create_offer >---------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a new offer.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with iRecruitment.
 *
 * <p><b>Prerequisites</b><br>
 * None.
 *
 * <p><b>Post Success</b><br>
 *  The record gets successfully inserted.
 *
 * <p><b>Post Failure</b><br>
 * The API does not create the offer and raises an error.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Effective date for the creation
 * of the offer. If this is not passed in, DATE_FROM will be used.
 * @param p_offer_status Status of the Offer version.
 * @param p_discretionary_job_title Job title that can be used as the offer
 * title instead of the title available in the Job Table.
 * @param p_offer_extended_method Indicates how offers are extended to
 * applicants- SYSTEM/HARDCOPY. Value is defined by the IRC: Offer Send Method
 * System Profile Option.
 * @param p_respondent_id User ID of the person responding to
 * the offer extension.
 * @param p_expiry_date Date when the current offer version expires.
 * @param p_proposed_start_date The proposed employment start date of the
 * applicant, if the person accepts the job offer.
 * @param p_offer_letter_tracking_code Tracking code from the shipping
 * company when the offer shipped.
 * @param p_offer_postal_service Name of the company handling the
 * delivery of the offer.
 * @param p_offer_shipping_date Date on which paper copy of the Offer was
 * shipped.
 * @param p_applicant_assignment_id Applicant assignment for the applicant
 * where the type is 'APPLICANT'.
 * @param p_offer_assignment_id Offer assignment for the applicant where the
 * type is 'OFFER'.
 * @param p_address_id Address Offer should be sent to.
 * @param p_template_id ID of the template associated with the offer. The
 * application sets the value to null, if a manager uploads a modified version
 * of the offer letter.
 * @param p_offer_letter_file_type File type of the uploaded offer letter.
 * @param p_offer_letter_file_name Filename of the uploaded offer letter.
 * @param p_attribute_category This context value determines which flexfield
 * structure to use with the descriptive flexfield segments.
 * @param p_attribute1 Descriptive flexfield segment.
 * @param p_attribute2 Descriptive flexfield segment.
 * @param p_attribute3 Descriptive flexfield segment.
 * @param p_attribute4 Descriptive flexfield segment.
 * @param p_attribute5 Descriptive flexfield segment.
 * @param p_attribute6 Descriptive flexfield segment.
 * @param p_attribute7 Descriptive flexfield segment.
 * @param p_attribute8 Descriptive flexfield segment.
 * @param p_attribute9 Descriptive flexfield segment.
 * @param p_attribute10 Descriptive flexfield segment.
 * @param p_attribute11 Descriptive flexfield segment.
 * @param p_attribute12 Descriptive flexfield segment.
 * @param p_attribute13 Descriptive flexfield segment.
 * @param p_attribute14 Descriptive flexfield segment.
 * @param p_attribute15 Descriptive flexfield segment.
 * @param p_attribute16 Descriptive flexfield segment.
 * @param p_attribute17 Descriptive flexfield segment.
 * @param p_attribute18 Descriptive flexfield segment.
 * @param p_attribute19 Descriptive flexfield segment.
 * @param p_attribute20 Descriptive flexfield segment.
 * @param p_attribute21 Descriptive flexfield segment.
 * @param p_attribute22 Descriptive flexfield segment.
 * @param p_attribute23 Descriptive flexfield segment.
 * @param p_attribute24 Descriptive flexfield segment.
 * @param p_attribute25 Descriptive flexfield segment.
 * @param p_attribute26 Descriptive flexfield segment.
 * @param p_attribute27 Descriptive flexfield segment.
 * @param p_attribute28 Descriptive flexfield segment.
 * @param p_attribute29 Descriptive flexfield segment.
 * @param p_attribute30 Descriptive flexfield segment.
 * @param p_status_change_date Date of the offer status change.
 * @param p_offer_id If p_validate is false, then this uniquely identifies
 * the offer created. If p_validate is true, then set to null.
 * @param p_offer_version Version of the Offer starting at 1.
 * Part of the Business Key to the Table.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created assignment detail. If p_validate is true,
 * then the value will be null.
 * @rep:displayname Create Offer
 * @rep:category BUSINESS_ENTITY IRC_JOB_OFFER
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_offer
  ( P_VALIDATE                     IN   boolean     default false
   ,P_EFFECTIVE_DATE               IN   date        default null
   ,P_OFFER_STATUS                 IN   VARCHAR2
   ,P_DISCRETIONARY_JOB_TITLE      IN   VARCHAR2    default null
   ,P_OFFER_EXTENDED_METHOD        IN   VARCHAR2    default null
   ,P_RESPONDENT_ID                IN   NUMBER      default null
   ,P_EXPIRY_DATE                  IN   DATE        default null
   ,P_PROPOSED_START_DATE          IN   DATE        default null
   ,P_OFFER_LETTER_TRACKING_CODE   IN   VARCHAR2    default null
   ,P_OFFER_POSTAL_SERVICE         IN   VARCHAR2    default null
   ,P_OFFER_SHIPPING_DATE          IN   DATE        default null
   ,P_APPLICANT_ASSIGNMENT_ID      IN   NUMBER
   ,P_OFFER_ASSIGNMENT_ID          IN   NUMBER
   ,P_ADDRESS_ID                   IN   NUMBER      default null
   ,P_TEMPLATE_ID                  IN   NUMBER      default null
   ,P_OFFER_LETTER_FILE_TYPE       IN   VARCHAR2    default null
   ,P_OFFER_LETTER_FILE_NAME       IN   VARCHAR2    default null
   ,P_ATTRIBUTE_CATEGORY           IN   VARCHAR2    default null
   ,P_ATTRIBUTE1                   IN   VARCHAR2    default null
   ,P_ATTRIBUTE2                   IN   VARCHAR2    default null
   ,P_ATTRIBUTE3                   IN   VARCHAR2    default null
   ,P_ATTRIBUTE4                   IN   VARCHAR2    default null
   ,P_ATTRIBUTE5                   IN   VARCHAR2    default null
   ,P_ATTRIBUTE6                   IN   VARCHAR2    default null
   ,P_ATTRIBUTE7                   IN   VARCHAR2    default null
   ,P_ATTRIBUTE8                   IN   VARCHAR2    default null
   ,P_ATTRIBUTE9                   IN   VARCHAR2    default null
   ,P_ATTRIBUTE10                  IN   VARCHAR2    default null
   ,P_ATTRIBUTE11                  IN   VARCHAR2    default null
   ,P_ATTRIBUTE12                  IN   VARCHAR2    default null
   ,P_ATTRIBUTE13                  IN   VARCHAR2    default null
   ,P_ATTRIBUTE14                  IN   VARCHAR2    default null
   ,P_ATTRIBUTE15                  IN   VARCHAR2    default null
   ,P_ATTRIBUTE16                  IN   VARCHAR2    default null
   ,P_ATTRIBUTE17                  IN   VARCHAR2    default null
   ,P_ATTRIBUTE18                  IN   VARCHAR2    default null
   ,P_ATTRIBUTE19                  IN   VARCHAR2    default null
   ,P_ATTRIBUTE20                  IN   VARCHAR2    default null
   ,P_ATTRIBUTE21                  IN   VARCHAR2    default null
   ,P_ATTRIBUTE22                  IN   VARCHAR2    default null
   ,P_ATTRIBUTE23                  IN   VARCHAR2    default null
   ,P_ATTRIBUTE24                  IN   VARCHAR2    default null
   ,P_ATTRIBUTE25                  IN   VARCHAR2    default null
   ,P_ATTRIBUTE26                  IN   VARCHAR2    default null
   ,P_ATTRIBUTE27                  IN   VARCHAR2    default null
   ,P_ATTRIBUTE28                  IN   VARCHAR2    default null
   ,P_ATTRIBUTE29                  IN   VARCHAR2    default null
   ,P_ATTRIBUTE30                  IN   VARCHAR2    default null
   ,P_STATUS_CHANGE_DATE           IN   DATE        default null
   ,P_OFFER_ID                     OUT  nocopy   NUMBER
   ,P_OFFER_VERSION                OUT  nocopy   NUMBER
   ,P_OBJECT_VERSION_NUMBER        OUT  nocopy   NUMBER
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< update_offer >---------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates an offer.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with iRecruitment.
 *
 * <p><b>Prerequisites</b><br>
 * The offer should exist.
 *
 * <p><b>Post Success</b><br>
 * Successfully updates the record.
 *
 * <p><b>Post Failure</b><br>
 * The API does not update the offer and an error will be raised.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Effective date for the creation
 * of the offer.
 * @param p_offer_status Status of the Offer version.
 * @param p_discretionary_job_title Job Title that can be used as the offer
 * title instead of the Title set in the Job Table.
 * @param p_offer_extended_method Indicates how offers are extended to
 * applicants- SYSTEM/HARDCOPY. Value is defined by the IRC: Offer Send Method
 * System Profile Option.
 * @param p_respondent_id User ID of the person responding to
 * the offer extension.
 * @param p_expiry_date Date when the current offer version expires.
 * @param p_proposed_start_date The proposed employment start date of the
 * applicant, if the person accepts the job offer.
 * @param p_offer_letter_tracking_code Tracking code from the shipping
 * company when the offer shipped.
 * @param p_offer_postal_service Name of the company handling the
 * delivery of the offer.
 * @param p_offer_shipping_date Date on which paper copy of the Offer was
 * shipped.
 * @param p_applicant_assignment_id Applicant assignment for the applicant
 * where the type is 'APPLICANT'.
 * @param p_offer_assignment_id Offer assignment for the applicant where the
 * type is 'OFFER'.
 * @param p_address_id Address Offer should be sent to.
 * @param p_template_id ID of the template associated with the offer. The
 * application sets the value to null, if a manager uploads a modified version
 * of the offer letter.
 * @param p_offer_letter_file_type File type of the uploaded offer letter.
 * @param p_offer_letter_file_name Filename of the uploaded offer letter.
 * @param p_attribute_category This context value determines which flexfield
 * structure to use with the descriptive flexfield segments.
 * @param p_attribute1 Descriptive flexfield segment.
 * @param p_attribute2 Descriptive flexfield segment.
 * @param p_attribute3 Descriptive flexfield segment.
 * @param p_attribute4 Descriptive flexfield segment.
 * @param p_attribute5 Descriptive flexfield segment.
 * @param p_attribute6 Descriptive flexfield segment.
 * @param p_attribute7 Descriptive flexfield segment.
 * @param p_attribute8 Descriptive flexfield segment.
 * @param p_attribute9 Descriptive flexfield segment.
 * @param p_attribute10 Descriptive flexfield segment.
 * @param p_attribute11 Descriptive flexfield segment.
 * @param p_attribute12 Descriptive flexfield segment.
 * @param p_attribute13 Descriptive flexfield segment.
 * @param p_attribute14 Descriptive flexfield segment.
 * @param p_attribute15 Descriptive flexfield segment.
 * @param p_attribute16 Descriptive flexfield segment.
 * @param p_attribute17 Descriptive flexfield segment.
 * @param p_attribute18 Descriptive flexfield segment.
 * @param p_attribute19 Descriptive flexfield segment.
 * @param p_attribute20 Descriptive flexfield segment.
 * @param p_attribute21 Descriptive flexfield segment.
 * @param p_attribute22 Descriptive flexfield segment.
 * @param p_attribute23 Descriptive flexfield segment.
 * @param p_attribute24 Descriptive flexfield segment.
 * @param p_attribute25 Descriptive flexfield segment.
 * @param p_attribute26 Descriptive flexfield segment.
 * @param p_attribute27 Descriptive flexfield segment.
 * @param p_attribute28 Descriptive flexfield segment.
 * @param p_attribute29 Descriptive flexfield segment.
 * @param p_attribute30 Descriptive flexfield segment.
 * @param p_change_reason Reason for the Status Change.
 * @param p_decline_reason Applicant Decline Reason.
 * @param p_note_text Offer Notes Text.
 * @param p_status_change_date Date of the offer status change.
 * @param p_offer_id If p_validate is false, then this uniquely identifies
 * the new version of offer that may be created or will be set to the same
 * value which was passed in. If p_validate is true will be set to the same
 * value which was passed in.
 * @param p_object_version_number Pass in the current version number of the
 * offer to be updated. When the API completes if p_validate is
 * false, will be set to the new version number of the updated offer.
 * @param p_offer_version New Version of the updated Offer.
 * @rep:displayname Update Offer
 * @rep:category BUSINESS_ENTITY IRC_JOB_OFFER
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
  procedure update_offer
  ( P_VALIDATE                     IN   boolean     default false
   ,P_EFFECTIVE_DATE               IN   date        default null
   ,P_OFFER_STATUS                 IN   VARCHAR2    default hr_api.g_varchar2
   ,P_DISCRETIONARY_JOB_TITLE      IN   VARCHAR2    default hr_api.g_varchar2
   ,P_OFFER_EXTENDED_METHOD        IN   VARCHAR2    default hr_api.g_varchar2
   ,P_RESPONDENT_ID                IN   NUMBER      default hr_api.g_number
   ,P_EXPIRY_DATE                  IN   DATE        default hr_api.g_date
   ,P_PROPOSED_START_DATE          IN   DATE        default hr_api.g_date
   ,P_OFFER_LETTER_TRACKING_CODE   IN   VARCHAR2    default hr_api.g_varchar2
   ,P_OFFER_POSTAL_SERVICE         IN   VARCHAR2    default hr_api.g_varchar2
   ,P_OFFER_SHIPPING_DATE          IN   DATE        default hr_api.g_date
   ,P_APPLICANT_ASSIGNMENT_ID      IN   NUMBER      default hr_api.g_number
   ,P_OFFER_ASSIGNMENT_ID          IN   NUMBER      default hr_api.g_number
   ,P_ADDRESS_ID                   IN   NUMBER      default hr_api.g_number
   ,P_TEMPLATE_ID                  IN   NUMBER      default hr_api.g_number
   ,P_OFFER_LETTER_FILE_TYPE       IN   VARCHAR2    default hr_api.g_varchar2
   ,P_OFFER_LETTER_FILE_NAME       IN   VARCHAR2    default hr_api.g_varchar2
   ,P_ATTRIBUTE_CATEGORY           IN   VARCHAR2    default hr_api.g_varchar2
   ,P_ATTRIBUTE1                   IN   VARCHAR2    default hr_api.g_varchar2
   ,P_ATTRIBUTE2                   IN   VARCHAR2    default hr_api.g_varchar2
   ,P_ATTRIBUTE3                   IN   VARCHAR2    default hr_api.g_varchar2
   ,P_ATTRIBUTE4                   IN   VARCHAR2    default hr_api.g_varchar2
   ,P_ATTRIBUTE5                   IN   VARCHAR2    default hr_api.g_varchar2
   ,P_ATTRIBUTE6                   IN   VARCHAR2    default hr_api.g_varchar2
   ,P_ATTRIBUTE7                   IN   VARCHAR2    default hr_api.g_varchar2
   ,P_ATTRIBUTE8                   IN   VARCHAR2    default hr_api.g_varchar2
   ,P_ATTRIBUTE9                   IN   VARCHAR2    default hr_api.g_varchar2
   ,P_ATTRIBUTE10                  IN   VARCHAR2    default hr_api.g_varchar2
   ,P_ATTRIBUTE11                  IN   VARCHAR2    default hr_api.g_varchar2
   ,P_ATTRIBUTE12                  IN   VARCHAR2    default hr_api.g_varchar2
   ,P_ATTRIBUTE13                  IN   VARCHAR2    default hr_api.g_varchar2
   ,P_ATTRIBUTE14                  IN   VARCHAR2    default hr_api.g_varchar2
   ,P_ATTRIBUTE15                  IN   VARCHAR2    default hr_api.g_varchar2
   ,P_ATTRIBUTE16                  IN   VARCHAR2    default hr_api.g_varchar2
   ,P_ATTRIBUTE17                  IN   VARCHAR2    default hr_api.g_varchar2
   ,P_ATTRIBUTE18                  IN   VARCHAR2    default hr_api.g_varchar2
   ,P_ATTRIBUTE19                  IN   VARCHAR2    default hr_api.g_varchar2
   ,P_ATTRIBUTE20                  IN   VARCHAR2    default hr_api.g_varchar2
   ,P_ATTRIBUTE21                  IN   VARCHAR2    default hr_api.g_varchar2
   ,P_ATTRIBUTE22                  IN   VARCHAR2    default hr_api.g_varchar2
   ,P_ATTRIBUTE23                  IN   VARCHAR2    default hr_api.g_varchar2
   ,P_ATTRIBUTE24                  IN   VARCHAR2    default hr_api.g_varchar2
   ,P_ATTRIBUTE25                  IN   VARCHAR2    default hr_api.g_varchar2
   ,P_ATTRIBUTE26                  IN   VARCHAR2    default hr_api.g_varchar2
   ,P_ATTRIBUTE27                  IN   VARCHAR2    default hr_api.g_varchar2
   ,P_ATTRIBUTE28                  IN   VARCHAR2    default hr_api.g_varchar2
   ,P_ATTRIBUTE29                  IN   VARCHAR2    default hr_api.g_varchar2
   ,P_ATTRIBUTE30                  IN   VARCHAR2    default hr_api.g_varchar2
   ,P_CHANGE_REASON                IN   VARCHAR2    default null
   ,P_DECLINE_REASON               IN   VARCHAR2    default null
   ,P_NOTE_TEXT                    IN   VARCHAR2    default null
   ,P_STATUS_CHANGE_DATE           IN   DATE        default null
   ,P_OFFER_ID                     IN OUT  nocopy   NUMBER
   ,P_OBJECT_VERSION_NUMBER        IN OUT  nocopy   NUMBER
   ,P_OFFER_VERSION                OUT     nocopy   NUMBER
   );
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< delete_offer >---------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes an offer.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with iRecruitment.
 *
 * <p><b>Prerequisites</b><br>
 * The offer should exist.
 *
 * <p><b>Post Success</b><br>
 * The current offer record will be deleted.
 *
 * <p><b>Post Failure</b><br>
 * The record will not be deleted and an error is raised.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_object_version_number Current version number of the offer
 * to be deleted.
 * @param p_offer_id Primary key of the offer in the IRC_OFFERS table.
 * @param p_effective_date Effective date for the creation
 * of the offer.
 * @rep:displayname Delete Offer
 * @rep:category BUSINESS_ENTITY IRC_JOB_OFFER
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_offer
(
  P_VALIDATE                    in boolean  default false
, P_OBJECT_VERSION_NUMBER       in number
, P_OFFER_ID                    in number
, P_EFFECTIVE_DATE              in date     default null
);
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< close_offer >----------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API closes an offer and also end dates the offer assignment record.
 *
 * This API works for 2 cases:
 * 1. A manager closes an offer or an applicant declines an offer.
 * 2. The applicant withdraws the application for which an offer has been
 *    created.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with iRecruitment.
 *
 * <p><b>Prerequisites</b><br>
 * The offer should exist for the applicant assignment.
 *
 * <p><b>Post Success</b><br>
 * The API sets the offer status to closed and end dates the offer assignment
 * record.
 *
 * <p><b>Post Failure</b><br>
 * The API does not close the offer and raises an error.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Effective date for the creation
 * of the offer.
 * @param p_applicant_assignment_id Applicant assignment for the applicant
 * where the type is 'APPLICANT'.
 * @param p_offer_id Primary key of the offer in the IRC_OFFERS table.
 * @param p_respondent_id User ID of the person closing the offer.
 * @param p_change_reason Reason for the status change.
 * @param p_decline_reason The applicant's reason for declining an offer.
 * @param p_note_text Offer notes text.
 * @param p_status_change_date Date of the offer status change.
 * @rep:displayname Close Offer
 * @rep:category BUSINESS_ENTITY IRC_JOB_OFFER
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure close_offer
( P_VALIDATE                     IN   boolean     default false
 ,P_EFFECTIVE_DATE               IN   date        default null
 ,P_APPLICANT_ASSIGNMENT_ID      IN   number      default null
 ,P_OFFER_ID                     IN   number      default null
 ,P_RESPONDENT_ID                IN   number      default null
 ,P_CHANGE_REASON                IN   VARCHAR2    default null
 ,P_DECLINE_REASON               IN   VARCHAR2    default null
 ,P_NOTE_TEXT                    IN   VARCHAR2    default null
 ,P_STATUS_CHANGE_DATE           IN   date        default null
);
--
-- ----------------------------------------------------------------------------
-- |--------------------------------< hold_offer >----------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API places an offer on Hold.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with iRecruitment.
 *
 * <p><b>Prerequisites</b><br>
 * The offer should exist.
 *
 * <p><b>Post Success</b><br>
 * The offer's status would be set to "HOLD".
 *
 * <p><b>Post Failure</b><br>
 * The API does not place the offer on hold and raises an error.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Effective date for the creation
 * of the offer.
 * @param p_offer_id Primary key of the offer in the IRC_OFFERS table.
 * @param p_respondent_id User ID of the person holding the offer.
 * @param p_change_reason Reason for the Status Change.
 * @param p_status_change_date Date of the offer status change.
 * @param p_note_text Offer Notes Text.
 * @param p_object_version_number Pass in the current version number of the
 * offer to be put on hold. When the API completes if p_validate is false,
 * will be set to the new version number of the updated offer. If p_validate
 * is true will be set to the same value which was passed in.
 * @rep:displayname Hold Offer
 * @rep:category BUSINESS_ENTITY IRC_JOB_OFFER
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure hold_offer
( P_VALIDATE                     IN   boolean     default false
 ,P_EFFECTIVE_DATE               IN   date        default null
 ,P_OFFER_ID                     IN   NUMBER
 ,P_RESPONDENT_ID                IN   NUMBER      default hr_api.g_number
 ,P_CHANGE_REASON                IN   VARCHAR2    default null
 ,P_STATUS_CHANGE_DATE           IN   date        default null
 ,P_NOTE_TEXT                    IN   VARCHAR2    default null
 ,P_OBJECT_VERSION_NUMBER        IN OUT  nocopy   NUMBER
);
--
-- ----------------------------------------------------------------------------
-- |------------------------------< release_offer >---------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API releases an offer from the HOLD state and sets the offer status to the
 * one that existed before the offer was placed on hold.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with iRecruitment.
 *
 * <p><b>Prerequisites</b><br>
 * The offer should exist and be in HOLD status.
 *
 * <p><b>Post Success</b><br>
 * The offer's status would be released from HOLD and set to the offer status
 * that existed before the offer was held.
 *
 * <p><b>Post Failure</b><br>
 * The offer will not be released and an error would be raised.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Effective date for the creation
 * of the offer.
 * @param p_offer_id Primary key of the offer in the IRC_OFFERS table.
 * @param p_respondent_id User ID of the person releasing the offer.
 * @param p_change_reason Reason for the status change.
 * @param p_status_change_date Date of the offer status change.
 * @param p_note_text Offer notes text.
 * @param p_object_version_number Pass in the current version number of the
 * offer to be released. When the API completes if p_validate is false, will be
 * set to the new version number of the released offer. If p_validate is true
 * will be set to the same value which was passed in.
 * @rep:displayname Release Offer
 * @rep:category BUSINESS_ENTITY IRC_JOB_OFFER
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure release_offer
( P_VALIDATE                     IN   boolean     default false
 ,P_EFFECTIVE_DATE               IN   date        default null
 ,P_OFFER_ID                     IN   NUMBER
 ,P_RESPONDENT_ID                IN   NUMBER      default hr_api.g_number
 ,P_CHANGE_REASON                IN   VARCHAR2    default null
 ,P_STATUS_CHANGE_DATE           IN   date        default null
 ,P_NOTE_TEXT                    IN   VARCHAR2    default null
 ,P_OBJECT_VERSION_NUMBER        IN OUT  nocopy   NUMBER
);
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_offer_assignment >----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates an assignment record of type 'O' for offers.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with iRecruitment.
 *
 * <p><b>Prerequisites</b><br>
 * None.
 *
 * <p><b>Post Success</b><br>
 * A new offer assignment record will be created.
 *
 * <p><b>Post Failure</b><br>
 * The record will not be created and an error is raised.
 *
 * @param p_assignment_id If p_validate is false, then this uniquely identifies
 * the created assignment. If p_validate is true, then set to null.
 * @param p_effective_start_date If p_validate is false, then set to the
 * earliest effective start date for the created assignment. If p_validate is
 * true, then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date for the created assignment. If p_validate is true, then
 * set to null.
 * @param p_business_group_id The business group associated with this
 * assignment. This should be the same as the business group associated with
 * the applicant person.
 * @param p_recruiter_id Recruiter for the assignment. The value refers to the
 * recruiter's person record.
 * @param p_grade_id Identifies the grade of the assignment.
 * @param p_position_id Identifies the position of the assignment.
 * @param p_job_id Identifies the job of the assignment.
 * @param p_assignment_status_type_id Identifies the assignment status of the
 * assignment.
 * @param p_payroll_id Identifies the payroll for the assignment.
 * @param p_location_id Identifies the location of the assignment.
 * @param p_person_referred_by_id Identifies the person record of the person
 * who referred the applicant.
 * @param p_supervisor_id Identifies the supervisor for the assignment. The
 * value refers to the supervisor's person record.
 * @param p_special_ceiling_step_id Highest allowed step for the grade scale
 * associated with the grade of the assignment.
 * @param p_person_id Identifies the person record that owns the assignments to
 * update.
 * @param p_recruitment_activity_id Identifies the Recruitment Activity from
 * which the applicant was found.
 * @param p_source_organization_id Identifies the recruiting source
 * organization.
 * @param p_organization_id Identifies the organization of the assignment.
 * @param p_people_group_id If a value is passed in for this parameter, it
 * identifies an existing People Group Key Flexfield combination to associate
 * with the assignment, and segment values are ignored. If a value is not
 * passed in, then the individual People Group Key Flexfield segments supplied
 * will be used to choose an existing combination or create a new combination.
 * When the API completes, if p_validate is false, then this uniquely
 * identifies the associated combination of the People Group Key flexfield for
 * this assignment. If p_validate is true, then set to null.
 * @param p_soft_coding_keyflex_id If a value is passed in for this parameter,
 * it identifies an existing Soft Coded Key Flexfield combination to associate
 * with the assignment, and segment values are ignored. If a value is not
 * passed in, then the individual Soft Coded Key Flexfield segments supplied
 * will be used to choose an existing combination or create a new combination.
 * When the API completes, if p_validate is false, then this uniquely
 * identifies the associated combination of the Soft Coded Key flexfield for
 * this assignment. If p_validate is true, then set to null.
 * @param p_vacancy_id Identifies the vacancy that the applicant applied for.
 * @param p_pay_basis_id Salary basis for the assignment.
 * @param p_assignment_sequence If p_validate is false, then an automatically
 * incremented number is associated with this assignment, depending on the
 * number of assignment which already exist. If p_validate is true then set to
 * null.
 * @param p_assignment_type Represents the type of the person's assignment,
 * 'A' if Applicant, 'O' for Offer.
 * @param p_primary_flag Indicates whether the address is a primary address.
 * Valid values are 'Y' or 'N'.
 * @param p_application_id Identifies the application record of the offer
 * assignment.
 * @param p_assignment_number If a value is passed in, this is used as the
 * assignment number. If no value is passed in an assignment number is
 * generated.
 * @param p_change_reason Reason for the assignment status change. If there is
 * no change reason, then the parameter can be null. Valid values are defined
 * in the EMP_ASSIGN_REASON lookup type.
 * @param p_comment_id If p_validate is false and comment text was provided,
 * then will be set to the identifier of the created assignment comment record.
 * If p_validate is true or no comment text was provided, then will be null.
 * @param p_comments Comment text.
 * @param p_date_probation_end End date of the probation period.
 * @param p_default_code_comb_id Identifier for the General Ledger Accounting
 * Flexfield combination that applies to this assignment.
 * @param p_employment_category Employment category. Valid values are defined
 * in the EMP_CAT lookup type.
 * @param p_frequency Frequency associated with the defined normal working
 * hours. Valid values are defined in the FREQUENCY lookup type.
 * @param p_internal_address_line Internal address identified with the
 * assignment.
 * @param p_manager_flag Indicates whether the employee is a manager.
 * @param p_normal_hours Normal working hours for this assignment.
 * @param p_perf_review_period Length of the performance review period.
 * @param p_perf_review_period_frequency Units of the performance review
 * period.
 * @param p_period_of_service_id Period of service that is being terminated.
 * @param p_probation_period Length of the probation period.
 * @param p_probation_unit Units of the probation period. Valid values are
 * defined in the QUALIFYING_UNITS lookup type.
 * @param p_sal_review_period Length of the salary review period.
 * @param p_sal_review_period_frequency Units of the salary review period.
 * Valid values are defined in the FREQUENCY lookup type.
 * @param p_set_of_books_id Identifies General Ledger set of books.
 * @param p_source_type Recruitment activity that this assignment is sourced
 * from. Valid values are defined in the REC_TYPE lookup type.
 * @param p_time_normal_finish Normal work finish time.
 * @param p_time_normal_start Normal work start time.
 * @param p_bargaining_unit_code Code for the bargaining unit. Valid values are
 * defined in the BARGAINING_UNIT_CODE lookup type.
 * @param p_labour_union_member_flag Value 'Y' indicates employee is a union
 * member. Other values indicate that the employee is not a union member.
 * @param p_hourly_salaried_code Identifies whether the assignment is paid
 * hourly or is salaried. Valid values are defined in the HOURLY_SALARIED_CODE
 * lookup type.
 * @param p_request_id When the API is executed from a concurrent program, the
 * value is set to the concurrent request identifier.
 * @param p_program_application_id When the API is executed from a concurrent
 * program, the value is set to the program's Application identifier.
 * @param p_program_id When the API is executed from a concurrent program, the
 * value is set to the program's identifier.
 * @param p_program_update_date When the API is executed from a concurrent
 * program, the value is set to when the program was run.
 * @param p_ass_attribute_category This context value determines which
 * Flexfield Structure to use with the Descriptive flexfield segments.
 * @param p_ass_attribute1 Descriptive flexfield segment.
 * @param p_ass_attribute2 Descriptive flexfield segment.
 * @param p_ass_attribute3 Descriptive flexfield segment.
 * @param p_ass_attribute4 Descriptive flexfield segment.
 * @param p_ass_attribute5 Descriptive flexfield segment.
 * @param p_ass_attribute6 Descriptive flexfield segment.
 * @param p_ass_attribute7 Descriptive flexfield segment.
 * @param p_ass_attribute8 Descriptive flexfield segment.
 * @param p_ass_attribute9 Descriptive flexfield segment.
 * @param p_ass_attribute10 Descriptive flexfield segment.
 * @param p_ass_attribute11 Descriptive flexfield segment.
 * @param p_ass_attribute12 Descriptive flexfield segment.
 * @param p_ass_attribute13 Descriptive flexfield segment.
 * @param p_ass_attribute14 Descriptive flexfield segment.
 * @param p_ass_attribute15 Descriptive flexfield segment.
 * @param p_ass_attribute16 Descriptive flexfield segment.
 * @param p_ass_attribute17 Descriptive flexfield segment.
 * @param p_ass_attribute18 Descriptive flexfield segment.
 * @param p_ass_attribute19 Descriptive flexfield segment.
 * @param p_ass_attribute20 Descriptive flexfield segment.
 * @param p_ass_attribute21 Descriptive flexfield segment.
 * @param p_ass_attribute22 Descriptive flexfield segment.
 * @param p_ass_attribute23 Descriptive flexfield segment.
 * @param p_ass_attribute24 Descriptive flexfield segment.
 * @param p_ass_attribute25 Descriptive flexfield segment.
 * @param p_ass_attribute26 Descriptive flexfield segment.
 * @param p_ass_attribute27 Descriptive flexfield segment.
 * @param p_ass_attribute28 Descriptive flexfield segment.
 * @param p_ass_attribute29 Descriptive flexfield segment.
 * @param p_ass_attribute30 Descriptive flexfield segment.
 * @param p_title Obsolete parameter, do not use.
 * @param p_validate_df_flex Identifies whether to validate the descriptive
 * flex fields values.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created assignment. If p_validate is true, then the
 * value will be null.
 * @param p_other_manager_warning If set to true, then a manager existed in the
 * organization prior to calling this API and the manager flag has been set to
 * 'Y' for yes.
 * @param p_hourly_salaried_warning Set to true if values entered for Salary
 * Basis and Hourly Salaried Code are invalid as of p_effective_date.
 * @param p_effective_date 	Determines when the DateTrack operation comes
 * into force.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_contract_id Contract associated with this assignment.
 * @param p_establishment_id For French business groups, this identifies the
 * Establishment Legal Entity for this assignment.
 * @param p_collective_agreement_id Collective Agreement that applies to this
 * assignment.
 * @param p_cagr_grade_def_id If a value is passed in for this parameter, it
 * identifies an existing CAGR Key Flexfield combination to associate with the
 * assignment, and segment values are ignored. If a value is not passed in,
 * then the individual CAGR Key Flexfield segments supplied will be used to
 * choose an existing combination or create a new combination. When the API
 * completes, if p_validate is false, then this uniquely identifies the
 * associated combination of the CAGR Key flexfield for this assignment. If
 * p_validate is true, then set to null.
 * @param p_cagr_id_flex_num Identifier for the structure from CAGR Key
 * flexfield to use for this assignment.
 * @param p_notice_period Length of notice period.
 * @param p_notice_period_uom Units for notice period. Valid values are defined
 * in the QUALIFYING_UNITS lookup type.
 * @param p_employee_category Employee Category. Valid values are defined in
 * the EMPLOYEE_CATG lookup type.
 * @param p_work_at_home Indicates whether this assignment is to work at home.
 * Valid values are defined in the YES_NO lookup type.
 * @param p_job_post_source_name The source of the job posting that was
 * selected for this assignment.
 * @param p_posting_content_id Identifies the posting to which the applicant
 * has applied.
 * @param p_placement_date_start Start date of the placement action.
 * @param p_vendor_id Identifier of the supplier of the contingent worker from
 * iProcurement.
 * @param p_vendor_employee_number Identification number given by the supplier
 * to the contingent worker.
 * @param p_vendor_assignment_number Identification number given by the
 * supplier to the contingent worker's assignment.
 * @param p_assignment_category Assignment Category. Valid values are defined
 * in the CWK_ASG_CATEGORY lookup type.
 * @param p_project_title Project title.
 * @param p_applicant_rank Applicant's rank.
 * @param p_grade_ladder_pgm_id Grade ladder defined for this assignment.
 * @param p_supervisor_assignment_id Supervisor's assignment that is
 * responsible for supervising this assignment.
 * @param p_vendor_site_id Identifier of the supplier site of the contingent
 * worker from iProcurement.
 * @param p_po_header_id Identifies the purchase order header in iProcurement
 * that stores the contingent worker's assignment pay details.
 * @param p_po_line_id Identifies the purchase order line in iProcurement that
 * stores the contingent worker's assignment pay details.
 * @param p_projected_assignment_end Projected end date of this assignment.
 * @rep:displayname Create Offer Assignment
 * @rep:category BUSINESS_ENTITY IRC_JOB_OFFER
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
  Procedure create_offer_assignment
  (
    p_assignment_id                OUT NOCOPY NUMBER
   ,p_effective_start_date         OUT NOCOPY DATE
   ,p_effective_end_date           OUT NOCOPY DATE
   ,p_business_group_id            IN NUMBER
   ,p_recruiter_id                 IN NUMBER           default null
   ,p_grade_id                     IN NUMBER           default null
   ,p_position_id                  IN NUMBER           default null
   ,p_job_id                       IN NUMBER           default null
   ,p_assignment_status_type_id    IN NUMBER
   ,p_payroll_id                   IN NUMBER           default null
   ,p_location_id                  IN NUMBER           default null
   ,p_person_referred_by_id        IN NUMBER           default null
   ,p_supervisor_id                IN NUMBER           default null
   ,p_special_ceiling_step_id      IN NUMBER           default null
   ,p_person_id                    IN NUMBER
   ,p_recruitment_activity_id      IN NUMBER           default null
   ,p_source_organization_id       IN NUMBER           default null
   ,p_organization_id              IN NUMBER
   ,p_people_group_id              IN NUMBER           default null
   ,p_soft_coding_keyflex_id       IN NUMBER           default null
   ,p_vacancy_id                   IN NUMBER           default null
   ,p_pay_basis_id                 IN NUMBER           default null
   ,p_assignment_sequence          OUT NOCOPY NUMBER
   ,p_assignment_type              IN VARCHAR2
   ,p_primary_flag                 IN VARCHAR2
   ,p_application_id               IN NUMBER           default null
   ,p_assignment_number            IN OUT NOCOPY VARCHAr2
   ,p_change_reason                IN VARCHAR2         default null
   ,p_comment_id                   OUT NOCOPY NUMBER
   ,p_comments                     IN VARCHAR2         default null
   ,p_date_probation_end           IN DATE             default null
   ,p_default_code_comb_id         IN NUMBER           default null
   ,p_employment_category          IN VARCHAR2         default null
   ,p_frequency                    IN VARCHAR2         default null
   ,p_internal_address_line        IN VARCHAR2         default null
   ,p_manager_flag                 IN VARCHAR2         default null
   ,p_normal_hours                 IN NUMBER           default null
   ,p_perf_review_period           IN NUMBER           default null
   ,p_perf_review_period_frequency IN VARCHAR2         default null
   ,p_period_of_service_id         IN NUMBER           default null
   ,p_probation_period             IN NUMBER           default null
   ,p_probation_unit               IN VARCHAR2         default null
   ,p_sal_review_period            IN NUMBER           default null
   ,p_sal_review_period_frequency  IN VARCHAR2         default null
   ,p_set_of_books_id              IN NUMBER           default null
   ,p_source_type                  IN VARCHAR2         default null
   ,p_time_normal_finish           IN VARCHAR2         default null
   ,p_time_normal_start            IN VARCHAR2         default null
   ,p_bargaining_unit_code         IN VARCHAR2         default null
   ,p_labour_union_member_flag     IN VARCHAR2         default 'N'
   ,p_hourly_salaried_code         IN VARCHAR2         default null
   ,p_request_id                   IN NUMBER           default null
   ,p_program_application_id       IN NUMBER           default null
   ,p_program_id                   IN NUMBER           default null
   ,p_program_update_date          IN DATE             default null
   ,p_ass_attribute_category       IN VARCHAR2         default null
   ,p_ass_attribute1               IN VARCHAR2         default null
   ,p_ass_attribute2               IN VARCHAR2         default null
   ,p_ass_attribute3               IN VARCHAR2         default null
   ,p_ass_attribute4               IN VARCHAR2         default null
   ,p_ass_attribute5               IN VARCHAR2         default null
   ,p_ass_attribute6               IN VARCHAR2         default null
   ,p_ass_attribute7               IN VARCHAR2         default null
   ,p_ass_attribute8               IN VARCHAR2         default null
   ,p_ass_attribute9               IN VARCHAR2         default null
   ,p_ass_attribute10              IN VARCHAR2         default null
   ,p_ass_attribute11              IN VARCHAR2         default null
   ,p_ass_attribute12              IN VARCHAR2         default null
   ,p_ass_attribute13              IN VARCHAR2         default null
   ,p_ass_attribute14              IN VARCHAR2         default null
   ,p_ass_attribute15              IN VARCHAR2         default null
   ,p_ass_attribute16              IN VARCHAR2         default null
   ,p_ass_attribute17              IN VARCHAR2         default null
   ,p_ass_attribute18              IN VARCHAR2         default null
   ,p_ass_attribute19              IN VARCHAR2         default null
   ,p_ass_attribute20              IN VARCHAR2         default null
   ,p_ass_attribute21              IN VARCHAR2         default null
   ,p_ass_attribute22              IN VARCHAR2         default null
   ,p_ass_attribute23              IN VARCHAR2         default null
   ,p_ass_attribute24              IN VARCHAR2         default null
   ,p_ass_attribute25              IN VARCHAR2         default null
   ,p_ass_attribute26              IN VARCHAR2         default null
   ,p_ass_attribute27              IN VARCHAR2         default null
   ,p_ass_attribute28              IN VARCHAR2         default null
   ,p_ass_attribute29              IN VARCHAR2         default null
   ,p_ass_attribute30              IN VARCHAR2         default null
   ,p_title                        IN VARCHAR2         default null
   ,p_validate_df_flex             IN BOOLEAN          default true
   ,p_object_version_number        OUT NOCOPY NUMBER
   ,p_other_manager_warning        OUT NOCOPY BOOLEAN
   ,p_hourly_salaried_warning      OUT NOCOPY BOOLEAN
   ,p_effective_date               IN DATE
   ,p_validate                     IN BOOLEAN          default false
   ,p_contract_id                  IN NUMBER           default null
   ,p_establishment_id             IN NUMBER           default null
   ,p_collective_agreement_id      IN NUMBER           default null
   ,p_cagr_grade_def_id            IN NUMBER           default null
   ,p_cagr_id_flex_num             IN NUMBER           default null
   ,p_notice_period                IN NUMBER           default null
   ,p_notice_period_uom            IN VARCHAR2         default null
   ,p_employee_category            IN VARCHAR2         default null
   ,p_work_at_home                 IN VARCHAR2         default null
   ,p_job_post_source_name         IN VARCHAR2         default null
   ,p_posting_content_id           IN NUMBER           default null
   ,p_placement_date_start         IN DATE             default null
   ,p_vendor_id                    IN NUMBER           default null
   ,p_vendor_employee_number       IN VARCHAR2         default null
   ,p_vendor_assignment_number     IN VARCHAR2         default null
   ,p_assignment_category          IN VARCHAR2         default null
   ,p_project_title                IN VARCHAR2         default null
   ,p_applicant_rank               IN NUMBER           default null
   ,p_grade_ladder_pgm_id          IN NUMBER           default null
   ,p_supervisor_assignment_id     IN NUMBER           default null
   ,p_vendor_site_id               IN NUMBER           default null
   ,p_po_header_id                 IN NUMBER           default null
   ,p_po_line_id                   IN NUMBER           default null
   ,p_projected_assignment_end     IN DATE             default null
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_offer_assignment >----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This api updates an offer assignment.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with iRecruitment.
 *
 * <p><b>Prerequisites</b><br>
 * The offer assignment should exist.
 *
 * <p><b>Post Success</b><br>
 * When the offer assignment is successfully updated, the following parameters are
 *  set.
 *
 * <p><b>Post Failure</b><br>
 * The record will not be updated and an error is raised.
 *
 * @param p_assignment_id If p_validate is false, then this uniquely identifies
 * the created assignment. If p_validate is true, then set to null.
 * @param p_effective_start_date If p_validate is false, then set to the
 * effective start date on the updated offer assignment row which now exists
 * as of the effective date. If p_validate is true, then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date on the updated offer assignment row which now exists
 * as of the effective date. If p_validate is true, then set to null.
 * @param p_business_group_id The business group associated with this
 * assignment. This should be the same as the business group associated with
 * the contingent worker.
 * @param p_recruiter_id Recruiter for the assignment. The value refers to the
 * recruiter's person record.
 * @param p_grade_id Identifies the grade of the assignment.
 * @param p_position_id Identifies the position of the assignment.
 * @param p_job_id Identifies the job of the assignment.
 * @param p_assignment_status_type_id Identifies the assignment status of the
 * assignment.
 * @param p_payroll_id Identifies the payroll for the assignment.
 * @param p_location_id Identifies the location of the assignment.
 * @param p_person_referred_by_id Identifies the person record of the person
 * who referred the applicant.
 * @param p_supervisor_id Identifies the supervisor for the assignment. The
 * value refers to the supervisor's person record.
 * @param p_special_ceiling_step_id Highest allowed step for the grade scale
 * associated with the grade of the assignment.
 * @param p_recruitment_activity_id Identifies the Recruitment Activity from
 * which the applicant was found.
 * @param p_source_organization_id Identifies the recruiting source
 * organization.
 * @param p_organization_id Identifies the organization of the assignment.
 * @param p_people_group_id If a value is passed in for this parameter, it
 * identifies an existing People Group Key Flexfield combination to associate
 * with the assignment, and segment values are ignored. If a value is not
 * passed in, then the individual People Group Key Flexfield segments supplied
 * will be used to choose an existing combination or create a new combination.
 * When the API completes, if p_validate is false, then this uniquely
 * identifies the associated combination of the People Group Key flexfield for
 * this assignment. If p_validate is true, then set to null.
 * @param p_soft_coding_keyflex_id If a value is passed in for this parameter,
 * it identifies an existing Soft Coded Key Flexfield combination to associate
 * with the assignment, and segment values are ignored. If a value is not
 * passed in, then the individual Soft Coded Key Flexfield segments supplied
 * will be used to choose an existing combination or create a new combination.
 * When the API completes, if p_validate is false, then this uniquely
 * identifies the associated combination of the Soft Coded Key flexfield for
 * this assignment. If p_validate is true, then set to null.
 * @param p_vacancy_id Identifies the vacancy that the applicant applied for.
 * @param p_pay_basis_id Salary basis for the assignment.
 * @param p_assignment_type Represents the type of the person's assignment,
 * 'A' if Applicant, 'O' for Offer.
 * @param p_primary_flag Indicates whether the address is a primary address.
 * Valid values are 'Y' or 'N'.
 * @param p_application_id Identifies the application record to which this
 * assignment belongs.
 * @param p_assignment_number If a value is passed in, this is used as the
 * assignment number. If no value is passed in an assignment number is
 * generated.
 * @param p_change_reason Reason for the assignment status change. If there is
 * no change reason, then the parameter can be null. Valid values are defined in the
 * EMP_ASSIGN_REASON lookup type.
 * @param p_comment_id If p_validate is false and comment text was provided,
 * then will be set to the identifier of the created assignment comment record.
 * If p_validate is true or no comment text was provided, then will be null.
 * @param p_comments Comment text.
 * @param p_date_probation_end End date of the probation period.
 * @param p_default_code_comb_id Identifier for the General Ledger Accounting
 * Flexfield combination that applies to this assignment.
 * @param p_employment_category Employment category. Valid values are defined
 * in the EMP_CAT lookup type.
 * @param p_frequency Frequency associated with the defined normal working
 * hours. Valid values are defined in the FREQUENCY lookup type.
 * @param p_internal_address_line Internal address identified with the
 * assignment.
 * @param p_manager_flag Indicates whether the employee is a manager.
 * @param p_normal_hours Normal working hours for this assignment.
 * @param p_perf_review_period Length of the performance review period.
 * @param p_perf_review_period_frequency Units of the performance review
 * period.
 * @param p_period_of_service_id Period of service that is being terminated.
 * @param p_probation_period Length of the probation period.
 * @param p_probation_unit Units of the probation period. Valid values are
 * defined in the QUALIFYING_UNITS lookup type.
 * @param p_sal_review_period Length of the salary review period.
 * @param p_sal_review_period_frequency Units of the salary review period.
 * Valid values are defined in the FREQUENCY lookup type.
 * @param p_set_of_books_id Identifies General Ledger set of books.
 * @param p_source_type Recruitment activity that this assignment is sourced
 * from. Valid values are defined in the REC_TYPE lookup type.
 * @param p_time_normal_finish Normal work finish time.
 * @param p_time_normal_start Normal work start time.
 * @param p_bargaining_unit_code Code for the bargaining unit. Valid values are
 * defined in the BARGAINING_UNIT_CODE lookup type.
 * @param p_labour_union_member_flag Value 'Y' indicates employee is a union
 * member. Other values indicate that the employee is not a union member.
 * @param p_hourly_salaried_code Identifies whether the assignment is paid
 * hourly or is salaried. Valid values are defined in the HOURLY_SALARIED_CODE
 * lookup type.
 * @param p_request_id When the API is executed from a concurrent program, the
 * value is set to the concurrent request identifier.
 * @param p_program_application_id When the API is executed from a concurrent
 * program, the value is set to the program's Application identifier.
 * @param p_program_id When the API is executed from a concurrent program, the
 * value is set to the program's identifier.
 * @param p_program_update_date When the API is executed from a concurrent
 * program, the value is set to when the program was run.
 * @param p_ass_attribute_category This context value determines which
 * Flexfield Structure to use with the Descriptive flexfield segments.
 * @param p_ass_attribute1 Descriptive flexfield segment.
 * @param p_ass_attribute2 Descriptive flexfield segment.
 * @param p_ass_attribute3 Descriptive flexfield segment.
 * @param p_ass_attribute4 Descriptive flexfield segment.
 * @param p_ass_attribute5 Descriptive flexfield segment.
 * @param p_ass_attribute6 Descriptive flexfield segment.
 * @param p_ass_attribute7 Descriptive flexfield segment.
 * @param p_ass_attribute8 Descriptive flexfield segment.
 * @param p_ass_attribute9 Descriptive flexfield segment.
 * @param p_ass_attribute10 Descriptive flexfield segment.
 * @param p_ass_attribute11 Descriptive flexfield segment.
 * @param p_ass_attribute12 Descriptive flexfield segment.
 * @param p_ass_attribute13 Descriptive flexfield segment.
 * @param p_ass_attribute14 Descriptive flexfield segment.
 * @param p_ass_attribute15 Descriptive flexfield segment.
 * @param p_ass_attribute16 Descriptive flexfield segment.
 * @param p_ass_attribute17 Descriptive flexfield segment.
 * @param p_ass_attribute18 Descriptive flexfield segment.
 * @param p_ass_attribute19 Descriptive flexfield segment.
 * @param p_ass_attribute20 Descriptive flexfield segment.
 * @param p_ass_attribute21 Descriptive flexfield segment.
 * @param p_ass_attribute22 Descriptive flexfield segment.
 * @param p_ass_attribute23 Descriptive flexfield segment.
 * @param p_ass_attribute24 Descriptive flexfield segment.
 * @param p_ass_attribute25 Descriptive flexfield segment.
 * @param p_ass_attribute26 Descriptive flexfield segment.
 * @param p_ass_attribute27 Descriptive flexfield segment.
 * @param p_ass_attribute28 Descriptive flexfield segment.
 * @param p_ass_attribute29 Descriptive flexfield segment.
 * @param p_ass_attribute30 Descriptive flexfield segment.
 * @param p_title Obsolete parameter, do not use.
* @param p_contract_id Contract associated with this assignment.
 * @param p_establishment_id For French business groups, this identifies the
 * Establishment Legal Entity for this assignment.
 * @param p_collective_agreement_id Collective Agreement that applies to this
 * assignment.
 * @param p_cagr_grade_def_id If a value is passed in for this parameter, it
 * identifies an existing CAGR Key Flexfield combination to associate with the
 * assignment, and segment values are ignored. If a value is not passed in,
 * then the individual CAGR Key Flexfield segments supplied will be used to
 * choose an existing combination or create a new combination. When the API
 * completes, if p_validate is false, then this uniquely identifies the
 * associated combination of the CAGR Key flexfield for this assignment. If
 * p_validate is true, then set to null.
 * @param p_cagr_id_flex_num Identifier for the structure from CAGR Key
 * flexfield to use for this assignment.
 * @param p_asg_object_version_number If p_validate is false, then this
 * parameter is set to the version number of the assignment created. If
 * p_validate is true, then this parameter is null.
 * @param p_notice_period Length of notice period.
 * @param p_notice_period_uom Units for notice period. Valid values are defined
 * in the QUALIFYING_UNITS lookup type.
 * @param p_employee_category Employee Category. Valid values are defined in
 * the EMPLOYEE_CATG lookup type.
 * @param p_work_at_home Indicates whether this assignment is to work at home.
 * Valid values are defined in the YES_NO lookup type.
 * @param p_job_post_source_name The source of the job posting that was
 * selected for this assignment.
 * @param p_posting_content_id Identifies the posting to which the applicant
 * has applied.
 * @param p_placement_date_start Start date of the placement action.
 * @param p_vendor_id Identifier of the supplier of the contingent worker from
 * iProcurement.
 * @param p_vendor_employee_number Identification number given by the supplier
 * to the contingent worker.
 * @param p_vendor_assignment_number Identification number given by the
 * supplier to the contingent worker's assignment.
 * @param p_assignment_category Assignment Category. Valid values are defined
 * in the CWK_ASG_CATEGORY lookup type.
 * @param p_project_title Project title.
 * @param p_applicant_rank Applicant's rank.
 * @param p_grade_ladder_pgm_id Grade lLadder defined for this assignment.
 * @param p_supervisor_assignment_id Supervisor's assignment that is
 * responsible for supervising this assignment.
 * @param p_vendor_site_id Identifier of the supplier site of the contingent
 * worker from iProcurement.
 * @param p_po_header_id Identifies the purchase order header in iProcurement
 * that stores the contingent worker's assignment pay details.
 * @param p_po_line_id Identifies the purchase order line in iProcurement that
 * stores the contingent worker's assignment pay details.
 * @param p_projected_assignment_end Projected end date of this assignment.
 * @param p_payroll_id_updated ID of the payroll for the updated assignment.
 * @param p_other_manager_warning If set to true, then a manager existed in the
 * organization prior to calling this API and the manager flag has been set to
 * 'Y' for yes.
 * @param p_hourly_salaried_warning Set to true if values entered for Salary
 * Basis and Hourly Salaried Code are invalid as of p_effective_date.
 * @param p_no_managers_warning Set to true if as a result of the update there
 * is no manager in the organization. Otherwise set to false.
 * @param p_org_now_no_manager_warning Set to true if this assignment had the
 * manager flag set to 'Y' and there are no other managers in the assignment's
 * organization. Set to false if there is another manager in the assignment's
 * organization or if this assignment did not have the manager flag set to 'Y'.
 * The warning value only applies as of the final process date.
 * @param p_validation_start_date Derived Effective Start Date.
 * @param p_validation_end_date Derived Effective End Date.
 * @param p_effective_date Determines when the DateTrack operation comes
 * into force.
 * @param p_datetrack_mode Indicates which DateTrack mode to use when
 * deleting the record. You must set to either ZAP, DELETE_NEXT_CHANGE or
 * FUTURE_CHANGE. Modes available for use with a particular record depend on
 * the dates of previous record changes and the effective date of this change.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_offer_id If p_validate is false, then this uniquely identifies
 * the new version of offer that may be created or will be set to the same
 * value which was passed in. If p_validate is true will be set to the same
 * value which was passed in.
 * @param p_offer_status Status of the Offer version.
 * @rep:displayname Update Offer Assignment
 * @rep:category BUSINESS_ENTITY IRC_JOB_OFFER
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
  procedure update_offer_assignment
  ( P_ASSIGNMENT_ID                     IN OUT NOCOPY  NUMBER
   ,P_EFFECTIVE_START_DATE              OUT NOCOPY DATE
   ,P_EFFECTIVE_END_DATE                OUT NOCOPY DATE
   ,P_BUSINESS_GROUP_ID                 OUT NOCOPY NUMBER

   ,P_RECRUITER_ID                      IN NUMBER                default hr_api.g_number
   ,P_GRADE_ID                          IN NUMBER                default hr_api.g_number
   ,P_POSITION_ID                       IN NUMBER                default hr_api.g_number
   ,P_JOB_ID                            IN NUMBER                default hr_api.g_number
   ,P_ASSIGNMENT_STATUS_TYPE_ID         IN NUMBER                default hr_api.g_number
   ,P_PAYROLL_ID                        IN NUMBER                default hr_api.g_number
   ,P_LOCATION_ID                       IN NUMBER                default hr_api.g_number
   ,P_PERSON_REFERRED_BY_ID             IN NUMBER                default hr_api.g_number
   ,P_SUPERVISOR_ID                     IN NUMBER                default hr_api.g_number
   ,P_SPECIAL_CEILING_STEP_ID           IN NUMBER                default hr_api.g_number
   ,P_RECRUITMENT_ACTIVITY_ID           IN NUMBER                default hr_api.g_number
   ,P_SOURCE_ORGANIZATION_ID            IN NUMBER                default hr_api.g_number

   ,P_ORGANIZATION_ID                   IN NUMBER                default hr_api.g_number
   ,P_PEOPLE_GROUP_ID                   IN NUMBER                default hr_api.g_number
   ,P_SOFT_CODING_KEYFLEX_ID            IN NUMBER                default hr_api.g_number
   ,P_VACANCY_ID                        IN NUMBER                default hr_api.g_number
   ,P_PAY_BASIS_ID                      IN NUMBER                default hr_api.g_number
   ,P_ASSIGNMENT_TYPE                   IN VARCHAR2              default hr_api.g_varchar2
   ,P_PRIMARY_FLAG                      IN VARCHAR2              default hr_api.g_varchar2
   ,P_APPLICATION_ID                    IN NUMBER                default hr_api.g_number
   ,P_ASSIGNMENT_NUMBER                 IN VARCHAR2              default hr_api.g_varchar2
   ,P_CHANGE_REASON                     IN VARCHAR2              default hr_api.g_varchar2
   ,P_COMMENT_ID                        OUT NOCOPY NUMBER
   ,P_COMMENTS                          IN VARCHAR2              default hr_api.g_varchar2
   ,P_DATE_PROBATION_END                IN DATE                  default hr_api.g_date

   ,P_DEFAULT_CODE_COMB_ID              IN NUMBER                default hr_api.g_number
   ,P_EMPLOYMENT_CATEGORY               IN VARCHAR2              default hr_api.g_varchar2
   ,P_FREQUENCY                         IN VARCHAR2              default hr_api.g_varchar2
   ,P_INTERNAL_ADDRESS_LINE             IN VARCHAR2              default hr_api.g_varchar2
   ,P_MANAGER_FLAG                      IN VARCHAR2              default hr_api.g_varchar2
   ,P_NORMAL_HOURS                      IN NUMBER                default hr_api.g_number
   ,P_PERF_REVIEW_PERIOD                IN NUMBER                default hr_api.g_number
   ,P_PERF_REVIEW_PERIOD_FREQUENCY      IN VARCHAR2              default hr_api.g_varchar2
   ,P_PERIOD_OF_SERVICE_ID              IN NUMBER                default hr_api.g_number
   ,P_PROBATION_PERIOD                  IN NUMBER                default hr_api.g_number
   ,P_PROBATION_UNIT                    IN VARCHAR2              default hr_api.g_varchar2
   ,P_SAL_REVIEW_PERIOD                 IN NUMBER                default hr_api.g_number
   ,P_SAL_REVIEW_PERIOD_FREQUENCY       IN VARCHAR2              default hr_api.g_varchar2
   ,P_SET_OF_BOOKS_ID                   IN NUMBER                default hr_api.g_number

   ,P_SOURCE_TYPE                       IN VARCHAR2              default hr_api.g_varchar2
   ,P_TIME_NORMAL_FINISH                IN VARCHAR2              default hr_api.g_varchar2
   ,P_TIME_NORMAL_START                 IN VARCHAR2              default hr_api.g_varchar2
   ,P_BARGAINING_UNIT_CODE              IN VARCHAR2              default hr_api.g_varchar2
   ,P_LABOUR_UNION_MEMBER_FLAG          IN VARCHAR2              default hr_api.g_varchar2
   ,P_HOURLY_SALARIED_CODE              IN VARCHAR2              default hr_api.g_varchar2
   ,P_REQUEST_ID                        IN NUMBER                default hr_api.g_number
   ,P_PROGRAM_APPLICATION_ID            IN NUMBER                default hr_api.g_number
   ,P_PROGRAM_ID                        IN NUMBER                default hr_api.g_number
   ,P_PROGRAM_UPDATE_DATE               IN DATE                  default hr_api.g_date
   ,P_ASS_ATTRIBUTE_CATEGORY            IN VARCHAR2              default hr_api.g_varchar2
   ,P_ASS_ATTRIBUTE1                    IN VARCHAR2              default hr_api.g_varchar2
   ,P_ASS_ATTRIBUTE2                    IN VARCHAR2              default hr_api.g_varchar2
   ,P_ASS_ATTRIBUTE3                    IN VARCHAR2              default hr_api.g_varchar2
   ,P_ASS_ATTRIBUTE4                    IN VARCHAR2              default hr_api.g_varchar2
   ,P_ASS_ATTRIBUTE5                    IN VARCHAR2              default hr_api.g_varchar2

   ,P_ASS_ATTRIBUTE6                    IN VARCHAR2              default hr_api.g_varchar2
   ,P_ASS_ATTRIBUTE7                    IN VARCHAR2              default hr_api.g_varchar2
   ,P_ASS_ATTRIBUTE8                    IN VARCHAR2              default hr_api.g_varchar2
   ,P_ASS_ATTRIBUTE9                    IN VARCHAR2              default hr_api.g_varchar2
   ,P_ASS_ATTRIBUTE10                   IN VARCHAR2              default hr_api.g_varchar2
   ,P_ASS_ATTRIBUTE11                   IN VARCHAR2              default hr_api.g_varchar2
   ,P_ASS_ATTRIBUTE12                   IN VARCHAR2              default hr_api.g_varchar2
   ,P_ASS_ATTRIBUTE13                   IN VARCHAR2              default hr_api.g_varchar2
   ,P_ASS_ATTRIBUTE14                   IN VARCHAR2              default hr_api.g_varchar2
   ,P_ASS_ATTRIBUTE15                   IN VARCHAR2              default hr_api.g_varchar2
   ,P_ASS_ATTRIBUTE16                   IN VARCHAR2              default hr_api.g_varchar2
   ,P_ASS_ATTRIBUTE17                   IN VARCHAR2              default hr_api.g_varchar2
   ,P_ASS_ATTRIBUTE18                   IN VARCHAR2              default hr_api.g_varchar2

   ,P_ASS_ATTRIBUTE19                   IN VARCHAR2              default hr_api.g_varchar2
   ,P_ASS_ATTRIBUTE20                   IN VARCHAR2              default hr_api.g_varchar2
   ,P_ASS_ATTRIBUTE21                   IN VARCHAR2              default hr_api.g_varchar2
   ,P_ASS_ATTRIBUTE22                   IN VARCHAR2              default hr_api.g_varchar2
   ,P_ASS_ATTRIBUTE23                   IN VARCHAR2              default hr_api.g_varchar2
   ,P_ASS_ATTRIBUTE24                   IN VARCHAR2              default hr_api.g_varchar2
   ,P_ASS_ATTRIBUTE25                   IN VARCHAR2              default hr_api.g_varchar2
   ,P_ASS_ATTRIBUTE26                   IN VARCHAR2              default hr_api.g_varchar2
   ,P_ASS_ATTRIBUTE27                   IN VARCHAR2              default hr_api.g_varchar2
   ,P_ASS_ATTRIBUTE28                   IN VARCHAR2              default hr_api.g_varchar2
   ,P_ASS_ATTRIBUTE29                   IN VARCHAR2              default hr_api.g_varchar2
   ,P_ASS_ATTRIBUTE30                   IN VARCHAR2              default hr_api.g_varchar2
   ,P_TITLE                             IN VARCHAR2              default hr_api.g_varchar2
   ,P_CONTRACT_ID                       IN NUMBER                default hr_api.g_number
   ,P_ESTABLISHMENT_ID                  IN NUMBER                default hr_api.g_number
   ,P_COLLECTIVE_AGREEMENT_ID           IN NUMBER                default hr_api.g_number
   ,P_CAGR_GRADE_DEF_ID                 IN NUMBER                default hr_api.g_number
   ,P_CAGR_ID_FLEX_NUM                  IN NUMBER                default hr_api.g_number
   ,P_ASG_OBJECT_VERSION_NUMBER         IN OUT NOCOPY NUMBER
   ,P_NOTICE_PERIOD                     IN NUMBER                default hr_api.g_number
   ,P_NOTICE_PERIOD_UOM                 IN VARCHAR2              default hr_api.g_varchar2
   ,P_EMPLOYEE_CATEGORY                 IN VARCHAR2              default hr_api.g_varchar2
   ,P_WORK_AT_HOME                      IN VARCHAR2              default hr_api.g_varchar2
   ,P_JOB_POST_SOURCE_NAME              IN VARCHAR2              default hr_api.g_varchar2
   ,P_POSTING_CONTENT_ID                IN NUMBER                default hr_api.g_number
   ,P_PLACEMENT_DATE_START              IN DATE                  default hr_api.g_date
   ,P_VENDOR_ID                         IN NUMBER                default hr_api.g_number
   ,P_VENDOR_EMPLOYEE_NUMBER            IN VARCHAR2              default hr_api.g_varchar2
   ,P_VENDOR_ASSIGNMENT_NUMBER          IN VARCHAR2              default hr_api.g_varchar2
   ,P_ASSIGNMENT_CATEGORY               IN VARCHAR2              default hr_api.g_varchar2
   ,P_PROJECT_TITLE                     IN VARCHAR2              default hr_api.g_varchar2
   ,P_APPLICANT_RANK                    IN NUMBER                default hr_api.g_number
   ,P_GRADE_LADDER_PGM_ID               IN NUMBER                default hr_api.g_number
   ,P_SUPERVISOR_ASSIGNMENT_ID          IN NUMBER                default hr_api.g_number
   ,P_VENDOR_SITE_ID                    IN NUMBER                default hr_api.g_number
   ,P_PO_HEADER_ID                      IN NUMBER                default hr_api.g_number
   ,P_PO_LINE_ID                        IN NUMBER                default hr_api.g_number
   ,P_PROJECTED_ASSIGNMENT_END          IN DATE                  default hr_api.g_date
   ,P_PAYROLL_ID_UPDATED                OUT NOCOPY BOOLEAN
   ,P_OTHER_MANAGER_WARNING             OUT NOCOPY BOOLEAN
   ,P_HOURLY_SALARIED_WARNING           OUT NOCOPY BOOLEAN
   ,P_NO_MANAGERS_WARNING               OUT NOCOPY BOOLEAN
   ,P_ORG_NOW_NO_MANAGER_WARNING        OUT NOCOPY BOOLEAN
   ,P_VALIDATION_START_DATE             OUT NOCOPY DATE
   ,P_VALIDATION_END_DATE               OUT NOCOPY DATE
   ,P_EFFECTIVE_DATE                    IN DATE                 default null
   ,P_DATETRACK_MODE                    IN VARCHAR2             default hr_api.g_update
   ,P_VALIDATE                          IN BOOLEAN              default false
   ,P_OFFER_ID                          IN OUT NOCOPY  NUMBER
   ,P_OFFER_STATUS                      IN VARCHAR2             default null
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_offer_assignment >----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes an offer assignment and the offer associated with it.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with iRecruitment.
 *
 * <p><b>Prerequisites</b><br>
 * An offer assignment should exist.
 *
 * <p><b>Post Success</b><br>
 * Both the offer assignment and the offer records will be deleted.
 *
 * <p><b>Post Failure</b><br>
 * If there is no offer associated with this assignment, then the API raises
 * an error.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Determines when the DateTrack operation comes into
 * force.
 * @param p_offer_assignment_id Offer assignment for the applicant where the
 * type is 'OFFER'.
 * @rep:displayname Delete Offer Assignment
 * @rep:category BUSINESS_ENTITY IRC_JOB_OFFER
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_offer_assignment
( P_VALIDATE                     IN   boolean     default false
 ,P_EFFECTIVE_DATE               IN   date        default null
 ,P_OFFER_ASSIGNMENT_ID          IN   number
);
--
-- ----------------------------------------------------------------------------
-- |---------------------------< upload_offer_letter >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API uploads the offer letter to the corresponding offer record.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with iRecruitment.
 *
 * <p><b>Prerequisites</b><br>
 * The offer should exist.
 *
 * <p><b>Post Success</b><br>
 * The offer letter will be uploaded to the IRC_OFFERS table.
 *
 * <p><b>Post Failure</b><br>
 * Offer letter will not be uploaded and, an error is raised.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_offer_letter Offer letter either generated when the offer is
 * extended or uploaded by the Super User.
 * @param p_offer_id Primary key of the offer in the IRC_OFFERS table.
 * @param p_object_version_number System generated version of row.
 * @rep:displayname Upload Offer Letter
 * @rep:category BUSINESS_ENTITY IRC_JOB_OFFER
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure upload_offer_letter
( P_VALIDATE                     IN   boolean     default false
 ,P_OFFER_LETTER                 IN   BLOB
 ,P_OFFER_ID                     IN   NUMBER
 ,P_OBJECT_VERSION_NUMBER        IN   NUMBER
);
--
-- ----------------------------------------------------------------------------
-- |-----------------------< other_extended_offers_count >--------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This function returns the number of offers that have already been extended
 * or accepted by the candidate.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with iRecruitment.
 *
 * <p><b>Prerequisites</b><br>
 * The applicant should exist.
 *
 * <p><b>Post Success</b><br>
 * The API returns the sum of extended and accepted offers for this
 * candidate.
 *
 * <p><b>Post Failure</b><br>
 * An error is raised.
 *
 * @param p_applicant_assignment_id Applicant assignment for the applicant
 * where the type is 'APPLICANT'.
 * @param p_effective_date Effective date for the creation
 * of the offer.
 * @param p_person_id The person ID for this applicant.
 * @param p_other_extended_offer_count Contains the sum of the extended and
 * accepted offers for this candidate.
 * @rep:displayname Other Extended Offers Count.
 * @rep:category BUSINESS_ENTITY IRC_JOB_OFFER
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
PROCEDURE other_extended_offers_count
( p_applicant_assignment_id             IN NUMBER   default null
 ,p_effective_date                      IN DATE
 ,p_person_id                           IN NUMBER   default null
 ,p_other_extended_offer_count          OUT nocopy NUMBER
);
--
end IRC_OFFERS_API;

/
