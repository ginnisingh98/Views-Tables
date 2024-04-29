--------------------------------------------------------
--  DDL for Package OTA_DELEGATE_BOOKING_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_DELEGATE_BOOKING_API" AUTHID CURRENT_USER as
/* $Header: otenrapi.pkh 120.13.12010000.6 2009/08/13 07:22:59 smahanka ship $ */
/*#
 * This package manages a learner enrollment in a class.
 * @rep:scope public
 * @rep:product ota
 * @rep:displayname Enrollment
*/
--
--
-- Package Variables
--
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_delegate_booking >----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a learner enrollment in a class.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Learning Management.
 *
 * <p><b>Prerequisites</b><br>
 * User should have learner access for the class for which enrollment is to be
 * created.
 *
 * <p><b>Post Success</b><br>
 * An enrollment record created in the database.
 *
 * <p><b>Post Failure</b><br>
 * An enrollment record is not created and an error is raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_booking_id If p_validate is false, then this ID uniquely identifies
 * the enrollment created. If p_validate is true, then it is set to null.
 * @param p_booking_status_type_id {@rep:casecolumn
 * OTA_BOOKING_STATUS_TYPES.BOOKING_STATUS_TYPE_ID}.
 * @param p_delegate_person_id Identifies the person for whom the enrollment
 * record will be created.
 * @param p_contact_id Identifies the contact of the customer for which the
 * enrollment record is created.
 * @param p_business_group_id {@rep:casecolumn OTA_EVENTS.BUSINESS_GROUP_ID}.
 * @param p_event_id Identifies the class in which the person or contact is
 * enrolling.
 * @param p_customer_id Identifies the customer for which the enrollment record
 * is being created.
 * @param p_authorizer_person_id {@rep:casecolumn
 * OTA_DELEGATE_BOOKINGS.AUTHORIZER_PERSON_ID}.
 * @param p_date_booking_placed Identifies the date on which the enrollment is
 * being created.
 * @param p_corespondent {@rep:casecolumn OTA_DELEGATE_BOOKINGS.CORESPONDENT}.
 * @param p_internal_booking_flag This flag should have value Y for internal
 * enrollments and N for external enrollments.
 * @param p_number_of_places Identifies the number of places needed in the
 * class.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created enrollment. If p_validate is true, then the
 * value will be null.
 * @param p_administrator {@rep:casecolumn OTA_DELEGATE_BOOKINGS.ADMINISTRATOR}.
 * @param p_booking_priority Enrollment Priority. Valid values are defined by
 * the 'PRIORITY_LEVEL' lookup type.
 * @param p_comments Comment text.
 * @param p_contact_address_id {@rep:casecolumn
 * OTA_DELEGATE_BOOKINGS.CONTACT_ADDRESS_ID}.
 * @param p_delegate_contact_phone Telephone number for the delegate.
 * @param p_delegate_contact_fax {@rep:casecolumn
 * OTA_DELEGATE_BOOKINGS.DELEGATE_CONTACT_FAX}
 * @param p_third_party_customer_id {@rep:casecolumn
 * OTA_DELEGATE_BOOKINGS.THIRD_PARTY_CUSTOMER_ID}
 * @param p_third_party_contact_id {@rep:casecolumn
 * OTA_DELEGATE_BOOKINGS.THIRD_PARTY_CONTACT_ID}
 * @param p_third_party_address_id {@rep:casecolumn
 * OTA_DELEGATE_BOOKINGS.THIRD_PARTY_ADDRESS_ID}
 * @param p_third_party_contact_phone {@rep:casecolumn
 * OTA_DELEGATE_BOOKINGS.THIRD_PARTY_CONTACT_PHONE}
 * @param p_third_party_contact_fax {@rep:casecolumn
 * OTA_DELEGATE_BOOKINGS.THIRD_PARTY_CONTACT_FAX}
 * @param p_date_status_changed {@rep:casecolumn
 * OTA_DELEGATE_BOOKINGS.DATE_STATUS_CHANGED}.
 * @param p_failure_reason Identifies the failure reason. Valid values are
 * defined by the 'DELEGATE_FAILURE_REASON' lookup type.
 * @param p_attendance_result {@rep:casecolumn
 * OTA_DELEGATE_BOOKINGS.ATTENDANCE_RESULT}.
 * @param p_language_id {@rep:casecolumn OTA_DELEGATE_BOOKINGS.LANGUAGE_ID}.
 * @param p_source_of_booking Identifies the source of the enrollment. Valid
 * values are defined by the 'BOOKING_SOURCE' lookup type.
 * @param p_special_booking_instructions {@rep:casecolumn
 * OTA_DELEGATE_BOOKINGS.SPECIAL_BOOKING_INSTRUCTIONS}
 * @param p_successful_attendance_flag {@rep:casecolumn
 * OTA_DELEGATE_BOOKINGS.SUCCESSFUL_ATTENDANCE_FLAG}.
 * @param p_tdb_information_category This context value determines which
 * Flexfield Structure to use with the Descriptive flexfield segment.
 * @param p_tdb_information1 Descriptive flexfield segment.
 * @param p_tdb_information2 Descriptive flexfield segment.
 * @param p_tdb_information3 Descriptive flexfield segment.
 * @param p_tdb_information4 Descriptive flexfield segment.
 * @param p_tdb_information5 Descriptive flexfield segment.
 * @param p_tdb_information6 Descriptive flexfield segment.
 * @param p_tdb_information7 Descriptive flexfield segment.
 * @param p_tdb_information8 Descriptive flexfield segment.
 * @param p_tdb_information9 Descriptive flexfield segment.
 * @param p_tdb_information10 Descriptive flexfield segment.
 * @param p_tdb_information11 Descriptive flexfield segment.
 * @param p_tdb_information12 Descriptive flexfield segment.
 * @param p_tdb_information13 Descriptive flexfield segment.
 * @param p_tdb_information14 Descriptive flexfield segment.
 * @param p_tdb_information15 Descriptive flexfield segment.
 * @param p_tdb_information16 Descriptive flexfield segment.
 * @param p_tdb_information17 Descriptive flexfield segment.
 * @param p_tdb_information18 Descriptive flexfield segment.
 * @param p_tdb_information19 Descriptive flexfield segment.
 * @param p_tdb_information20 Descriptive flexfield segment.
 * @param p_create_finance_line Identifies whether a finance line needs to be
 * created.
 * @param p_finance_header_id Identifies the finance header.
 * @param p_currency_code {@rep:casecolumn OTA_FINANCE_LINES.CURRENCY_CODE}.
 * @param p_standard_amount {@rep:casecolumn OTA_FINANCE_LINES.STANDARD_AMOUNT}.
 * @param p_unitary_amount {@rep:casecolumn OTA_FINANCE_LINES.UNITARY_AMOUNT}.
 * @param p_money_amount {@rep:casecolumn OTA_FINANCE_LINES.MONEY_AMOUNT}.
 * @param p_booking_deal_id {@rep:casecolumn OTA_FINANCE_LINES.BOOKING_DEAL_ID}.
 * @param p_booking_deal_type Identifies the type of booking deal.
 * @param p_finance_line_id Identifies the finance line.
 * @param p_enrollment_type Enrollment type is S for student, null for others.
 * @param p_organization_id {@rep:casecolumn
 * OTA_DELEGATE_BOOKINGS.ORGANIZATION_ID}
 * @param p_sponsor_person_id {@rep:casecolumn
 * OTA_DELEGATE_BOOKINGS.SPONSOR_PERSON_ID}
 * @param p_sponsor_assignment_id {@rep:casecolumn
 * OTA_DELEGATE_BOOKINGS.SPONSOR_ASSIGNMENT_ID}
 * @param p_person_address_id {@rep:casecolumn
 * OTA_DELEGATE_BOOKINGS.PERSON_ADDRESS_ID}
 * @param p_delegate_assignment_id {@rep:casecolumn
 * OTA_DELEGATE_BOOKINGS.DELEGATE_ASSIGNMENT_ID}
 * @param p_delegate_contact_id Identifies the contact of the customer for whom
 * the enrollment record is being created.
 * @param p_delegate_contact_email {@rep:casecolumn
 * OTA_DELEGATE_BOOKINGS.DELEGATE_CONTACT_EMAIL}
 * @param p_third_party_email {@rep:casecolumn
 * OTA_DELEGATE_BOOKINGS.THIRD_PARTY_EMAIL}
 * @param p_person_address_type {@rep:casecolumn
 * OTA_DELEGATE_BOOKINGS.PERSON_ADDRESS_TYPE}
 * @param p_line_id {@rep:casecolumn OTA_DELEGATE_BOOKINGS.LINE_ID}
 * @param p_org_id {@rep:casecolumn OTA_DELEGATE_BOOKINGS.ORG_ID}
 * @param p_daemon_flag {@rep:casecolumn OTA_DELEGATE_BOOKINGS.DAEMON_FLAG}
 * @param p_daemon_type {@rep:casecolumn OTA_DELEGATE_BOOKINGS.DAEMON_TYPE}
 * @param p_old_event_id {@rep:casecolumn OTA_DELEGATE_BOOKINGS.OLD_EVENT_ID}
 * @param p_quote_line_id {@rep:casecolumn OTA_DELEGATE_BOOKINGS.QUOTE_LINE_ID}.
 * @param p_interface_source {@rep:casecolumn
 * OTA_DELEGATE_BOOKINGS.INTERFACE_SOURCE}.
 * @param p_total_training_time {@rep:casecolumn
 * OTA_DELEGATE_BOOKINGS.TOTAL_TRAINING_TIME}.
 * @param p_content_player_status Player status of Courses imported from
 * iLearning.
 * @param p_score Test Score of Courses imported from iLearning.
 * @param p_completed_content {@rep:casecolumn
 * OTA_DELEGATE_BOOKINGS.COMPLETED_CONTENT}.
 * @param p_total_content {@rep:casecolumn OTA_DELEGATE_BOOKINGS.TOTAL_CONTENT}.
 * @param p_booking_justification_id Identifies the enrollment justification
 * for the enrollment record.
 * @param p_is_history_flag Determines whether the enrollment record should
 * be moved to history. Valid values are Y and N. Default value is N.
 * @param p_override_prerequisites Determines whether the course and
 * competency prerequisites check is to be overridden. Valid values are Y and
 * N. Default value is N.
 * @param p_override_learner_access Determines whether the learner access
 * check is to be overridden. Valid values are Y and N. Default value is N.
 * @param p_book_from Specifies whether the enrollment originates from the
 * learner or admin. Valid value is 'AME' when coming from the learner;
 * otherwise it is null.
 * @param p_is_mandatory_enrollment Determines whether the enrollment is
 * mandatory or not. Gets the value Y only when enrollments are created
 * through concurrent program.
 * @rep:displayname Create Enrollment
 * @rep:category BUSINESS_ENTITY OTA_LEARNER_ENROLLMENT
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_delegate_booking
  (
  p_validate                     in  boolean           default false,
  p_effective_date               in  date,
  p_booking_id                   out nocopy number,
  p_booking_status_type_id       in  number,
  p_delegate_person_id           in  number            default null,
  p_contact_id                   in  number,
  p_business_group_id            in  number,
  p_event_id                     in  number,
  p_customer_id                  in  number            default null,
  p_authorizer_person_id         in  number            default null,
  p_date_booking_placed          in  date,
  p_corespondent                 in  varchar2          default null,
  p_internal_booking_flag        in  varchar2,
  p_number_of_places             in  number,
  p_object_version_number        out nocopy number,
  p_administrator                in  number            default null,
  p_booking_priority             in  varchar2          default null,
  p_comments                     in  varchar2          default null,
  p_contact_address_id           in  number            default null,
  p_delegate_contact_phone       in  varchar2          default null,
  p_delegate_contact_fax         in  varchar2          default null,
  p_third_party_customer_id      in  number            default null,
  p_third_party_contact_id       in  number            default null,
  p_third_party_address_id       in  number            default null,
  p_third_party_contact_phone    in  varchar2          default null,
  p_third_party_contact_fax      in  varchar2          default null,
  p_date_status_changed          in  date              default null,
  p_failure_reason               in  varchar2          default null,
  p_attendance_result            in  varchar2          default null,
  p_language_id                  in  number            default null,
  p_source_of_booking            in  varchar2          default null,
  p_special_booking_instructions in  varchar2          default null,
  p_successful_attendance_flag   in  varchar2          default null,
  p_tdb_information_category     in  varchar2          default null,
  p_tdb_information1             in  varchar2          default null,
  p_tdb_information2             in  varchar2          default null,
  p_tdb_information3             in  varchar2          default null,
  p_tdb_information4             in  varchar2          default null,
  p_tdb_information5             in  varchar2          default null,
  p_tdb_information6             in  varchar2          default null,
  p_tdb_information7             in  varchar2          default null,
  p_tdb_information8             in  varchar2          default null,
  p_tdb_information9             in  varchar2          default null,
  p_tdb_information10            in  varchar2          default null,
  p_tdb_information11            in  varchar2          default null,
  p_tdb_information12            in  varchar2          default null,
  p_tdb_information13            in  varchar2          default null,
  p_tdb_information14            in  varchar2          default null,
  p_tdb_information15            in  varchar2          default null,
  p_tdb_information16            in  varchar2          default null,
  p_tdb_information17            in  varchar2          default null,
  p_tdb_information18            in  varchar2          default null,
  p_tdb_information19            in  varchar2          default null,
  p_tdb_information20            in  varchar2          default null,
  p_create_finance_line          in  varchar2          default null,
  p_finance_header_id            in  number            default null,
  p_currency_code                in  varchar2          default null,
  p_standard_amount              in  number            default null,
  p_unitary_amount               in  number            default null,
  p_money_amount                 in  number            default null,
  p_booking_deal_id              in  number            default null,
  p_booking_deal_type            in  varchar2          default null,
  p_finance_line_id              in  out nocopy number,
  p_enrollment_type              in  varchar2          default null,
  p_organization_id              in  number            default null,
  p_sponsor_person_id            in  number            default null,
  p_sponsor_assignment_id        in  number            default null,
  p_person_address_id            in  number            default null,
  p_delegate_assignment_id       in  number            default null,
  p_delegate_contact_id          in  number            default null,
  p_delegate_contact_email       in  varchar2          default null,
  p_third_party_email            in  varchar2          default null,
  p_person_address_type          in  varchar2          default null,
  p_line_id                      in  number            default null,
  p_org_id                       in  number            default null,
  p_daemon_flag                  in  varchar2          default null,
  p_daemon_type                  in  varchar2          default null,
  p_old_event_id                 in  number            default null,
  p_quote_line_id                in  number            default null,
  p_interface_source             in  varchar2          default null,
  p_total_training_time          in  varchar2          default null,
  p_content_player_status        in  varchar2          default null,
  p_score                        in  number            default null,
  p_completed_content            in  number            default null,
  p_total_content                in  number            default null,
  p_booking_justification_id     in number             default null,
  p_is_history_flag	 	 in varchar2	       default 'N',
  p_override_prerequisites       in varchar2           default 'N',
  p_override_learner_access      in varchar2           default 'N',
  p_book_from                    in varchar2           default null,
  p_is_mandatory_enrollment      in varchar2           default 'N',
  p_sign_eval_status             in varchar2           default null
  );


-- ----------------------------------------------------------------------------
-- |-------------------------< update_delegate_booking >-----------------------|
-- ----------------------------------------------------------------------------
--
--
-- {Start Of Comments}
/*#
 * This API updates the enrollment of a learner in a class.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Learning Management.
 *
 * <p><b>Prerequisites</b><br>
 * The learner should have learner access for the class for which enrollment is
 * going to be updated.
 *
 * <p><b>Post Success</b><br>
 * The enrollment record is updated.
 *
 * <p><b>Post Failure</b><br>
 * The enrollment record is not updated and an error is raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_booking_id Identifies the enrollment to be updated.
 * @param p_booking_status_type_id {@rep:casecolumn
 * OTA_BOOKING_STATUS_TYPES.BOOKING_STATUS_TYPE_ID}.
 * @param p_delegate_person_id Identifies the person for whom the enrollment
 * record is being updated.
 * @param p_contact_id Identifies the contact of customer for whom the
 * enrollment record is being updated.
 * @param p_business_group_id {@rep:casecolumn OTA_EVENTS.BUSINESS_GROUP_ID}.
 * @param p_event_id Identifies the class in which person or contact is
 * enrolled.
 * @param p_customer_id Identifies the customer for whom the enrollment record
 * is being updated.
 * @param p_authorizer_person_id {@rep:casecolumn
 * OTA_DELEGATE_BOOKINGS.AUTHORIZER_PERSON_ID}.
 * @param p_date_booking_placed Identifies the date on which the enrollment is
 * updated.
 * @param p_corespondent {@rep:casecolumn OTA_DELEGATE_BOOKINGS.CORESPONDENT}.
 * @param p_internal_booking_flag This flag should have the value Y for
 * internal enrollments and N for external enrollments.
 * @param p_number_of_places Identifies the number of places needed in the
 * class.
 * @param p_object_version_number Pass the current version number of the
 * enrollment to be updated.When the API completes if p_validate is false,will
 * be set to the new version number of the updated enrollment. If p_validate is
 * true will be set to the same value which was passed in.
 * @param p_administrator {@rep:casecolumn OTA_DELEGATE_BOOKINGS.ADMINISTRATOR}.
 * @param p_booking_priority Enrollment Priority. Valid values are defined by
 * the 'PRIORITY_LEVEL' lookup type.
 * @param p_comments Comment text.
 * @param p_contact_address_id {@rep:casecolumn
 * OTA_DELEGATE_BOOKINGS.CONTACT_ADDRESS_ID}.
 * @param p_delegate_contact_phone Telephone number for the delegate.
 * @param p_delegate_contact_fax {@rep:casecolumn
 * OTA_DELEGATE_BOOKINGS.DELEGATE_CONTACT_FAX}
 * @param p_third_party_customer_id {@rep:casecolumn
 * OTA_DELEGATE_BOOKINGS.THIRD_PARTY_CUSTOMER_ID}
 * @param p_third_party_contact_id {@rep:casecolumn
 * OTA_DELEGATE_BOOKINGS.THIRD_PARTY_CONTACT_ID}
 * @param p_third_party_address_id {@rep:casecolumn
 * OTA_DELEGATE_BOOKINGS.THIRD_PARTY_ADDRESS_ID}
 * @param p_third_party_contact_phone {@rep:casecolumn
 * OTA_DELEGATE_BOOKINGS.THIRD_PARTY_CONTACT_PHONE}
 * @param p_third_party_contact_fax {@rep:casecolumn
 * OTA_DELEGATE_BOOKINGS.THIRD_PARTY_CONTACT_FAX}
 * @param p_date_status_changed {@rep:casecolumn
 * OTA_DELEGATE_BOOKINGS.DATE_STATUS_CHANGED}.
 * @param p_status_change_comments Comments on status change.
 * @param p_failure_reason Identifies the failure reason. Valid values are
 * defined by 'DELEGATE_FAILURE_REASON' lookup type.
 * @param p_attendance_result {@rep:casecolumn
 * OTA_DELEGATE_BOOKINGS.ATTENDANCE_RESULT}.
 * @param p_language_id {@rep:casecolumn OTA_DELEGATE_BOOKINGS.LANGUAGE_ID}.
 * @param p_source_of_booking Identifies the source of enrollment. Valid values
 * are defined by the 'BOOKING_SOURCE' lookup type.
 * @param p_special_booking_instructions {@rep:casecolumn
 * OTA_DELEGATE_BOOKINGS.SPECIAL_BOOKING_INSTRUCTIONS}
 * @param p_successful_attendance_flag {@rep:casecolumn
 * OTA_DELEGATE_BOOKINGS.SUCCESSFUL_ATTENDANCE_FLAG}.
 * @param p_tdb_information_category This context value determines which
 * Flexfield Structure to use with the Descriptive flexfield segment.
 * @param p_tdb_information1 Descriptive flexfield segment.
 * @param p_tdb_information2 Descriptive flexfield segment.
 * @param p_tdb_information3 Descriptive flexfield segment.
 * @param p_tdb_information4 Descriptive flexfield segment.
 * @param p_tdb_information5 Descriptive flexfield segment.
 * @param p_tdb_information6 Descriptive flexfield segment.
 * @param p_tdb_information7 Descriptive flexfield segment.
 * @param p_tdb_information8 Descriptive flexfield segment.
 * @param p_tdb_information9 Descriptive flexfield segment.
 * @param p_tdb_information10 Descriptive flexfield segment.
 * @param p_tdb_information11 Descriptive flexfield segment.
 * @param p_tdb_information12 Descriptive flexfield segment.
 * @param p_tdb_information13 Descriptive flexfield segment.
 * @param p_tdb_information14 Descriptive flexfield segment.
 * @param p_tdb_information15 Descriptive flexfield segment.
 * @param p_tdb_information16 Descriptive flexfield segment.
 * @param p_tdb_information17 Descriptive flexfield segment.
 * @param p_tdb_information18 Descriptive flexfield segment.
 * @param p_tdb_information19 Descriptive flexfield segment.
 * @param p_tdb_information20 Descriptive flexfield segment.
 * @param p_update_finance_line Identifies whether a finance line needs to be
 * updated.
 * @param p_tfl_object_version_number If p_validate is false, then set to the
 * version number of the updated finance line. If p_validate is true, then the
 * value will be null.
 * @param p_finance_header_id Identifies the finance header.
 * @param p_finance_line_id Identifies the finance line.
 * @param p_standard_amount {@rep:casecolumn OTA_FINANCE_LINES.STANDARD_AMOUNT}.
 * @param p_unitary_amount {@rep:casecolumn OTA_FINANCE_LINES.UNITARY_AMOUNT}.
 * @param p_money_amount {@rep:casecolumn OTA_FINANCE_LINES.MONEY_AMOUNT}.
 * @param p_currency_code {@rep:casecolumn OTA_FINANCE_LINES.CURRENCY_CODE}.
 * @param p_booking_deal_type Identifies the type of booking deal.
 * @param p_booking_deal_id {@rep:casecolumn OTA_FINANCE_LINES.BOOKING_DEAL_ID}.
 * @param p_enrollment_type Enrollment type is S for student, null for others.
 * @param p_organization_id {@rep:casecolumn
 * OTA_DELEGATE_BOOKINGS.ORGANIZATION_ID}
 * @param p_sponsor_person_id {@rep:casecolumn
 * OTA_DELEGATE_BOOKINGS.SPONSOR_PERSON_ID}
 * @param p_sponsor_assignment_id {@rep:casecolumn
 * OTA_DELEGATE_BOOKINGS.SPONSOR_ASSIGNMENT_ID}
 * @param p_person_address_id {@rep:casecolumn
 * OTA_DELEGATE_BOOKINGS.PERSON_ADDRESS_ID}
 * @param p_delegate_assignment_id {@rep:casecolumn
 * OTA_DELEGATE_BOOKINGS.DELEGATE_ASSIGNMENT_ID}
 * @param p_delegate_contact_id {@rep:casecolumn
 * OTA_DELEGATE_BOOKINGS.DELEGATE_CONTACT_ID}
 * @param p_delegate_contact_email {@rep:casecolumn
 * OTA_DELEGATE_BOOKINGS.DELEGATE_CONTACT_EMAIL}
 * @param p_third_party_email {@rep:casecolumn
 * OTA_DELEGATE_BOOKINGS.THIRD_PARTY_EMAIL}
 * @param p_person_address_type {@rep:casecolumn
 * OTA_DELEGATE_BOOKINGS.PERSON_ADDRESS_TYPE}
 * @param p_line_id {@rep:casecolumn OTA_DELEGATE_BOOKINGS.LINE_ID}
 * @param p_org_id {@rep:casecolumn OTA_DELEGATE_BOOKINGS.ORG_ID}
 * @param p_daemon_flag {@rep:casecolumn OTA_DELEGATE_BOOKINGS.DAEMON_FLAG}
 * @param p_daemon_type {@rep:casecolumn OTA_DELEGATE_BOOKINGS.DAEMON_TYPE}
 * @param p_old_event_id {@rep:casecolumn OTA_DELEGATE_BOOKINGS.OLD_EVENT_ID}
 * @param p_quote_line_id {@rep:casecolumn OTA_DELEGATE_BOOKINGS.QUOTE_LINE_ID}.
 * @param p_interface_source {@rep:casecolumn
 * OTA_DELEGATE_BOOKINGS.INTERFACE_SOURCE}.
 * @param p_total_training_time {@rep:casecolumn
 * OTA_DELEGATE_BOOKINGS.TOTAL_TRAINING_TIME}.
 * @param p_content_player_status Player status of Courses imported from
 * iLearning.
 * @param p_score Test Score of Courses imported from iLearning.
 * @param p_completed_content {@rep:casecolumn
 * OTA_DELEGATE_BOOKINGS.COMPLETED_CONTENT}.
 * @param p_total_content {@rep:casecolumn OTA_DELEGATE_BOOKINGS.TOTAL_CONTENT}.
 * @param p_booking_justification_id Identifies the enrollment justification
 * for the enrollment record.
 * @param p_is_history_flag Determines whether the enrollment record should be
 * moved to history. Valid values are Y and N. Default value is N.
 * @param p_override_prerequisites Determines whether the course and competency
 * prerequisites check is to be overridden. Valid values are Y and N. Default
 * value is N.
 * @param p_override_learner_access Determines whether the learner access
 * check is to be overridden. Valid values are Y and N. Default value is N.
 * @param p_source_cancel Specifies whether the unenrollment originates from
 * the learner or admin. Valid value is 'AME' when coming from the learner;
 * otherwise it is null.
 * @rep:displayname Update Enrollment
 * @rep:category BUSINESS_ENTITY OTA_LEARNER_ENROLLMENT
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_delegate_booking
  (
  p_validate                     in  boolean          default false,
  p_effective_date               in  date,
  p_booking_id                   in  number,
  p_booking_status_type_id       in  number           default hr_api.g_number,
  p_delegate_person_id           in  number           default hr_api.g_number,
  p_contact_id                   in  number           default hr_api.g_number,
  p_business_group_id            in  number           default hr_api.g_number,
  p_event_id                     in  number           default hr_api.g_number,
  p_customer_id                  in  number           default hr_api.g_number,
  p_authorizer_person_id         in  number           default hr_api.g_number,
  p_date_booking_placed          in  date             default hr_api.g_date,
  p_corespondent                 in  varchar2         default hr_api.g_varchar2,
  p_internal_booking_flag        in  varchar2         default hr_api.g_varchar2,
  p_number_of_places             in  number           default hr_api.g_number,
  p_object_version_number        in  out nocopy number,
  p_administrator                in  number           default hr_api.g_number,
  p_booking_priority             in  varchar2         default hr_api.g_varchar2,
  p_comments                     in  varchar2         default hr_api.g_varchar2,
  p_contact_address_id           in  number           default hr_api.g_number,
  p_delegate_contact_phone       in  varchar2         default hr_api.g_varchar2,
  p_delegate_contact_fax         in  varchar2         default hr_api.g_varchar2,
  p_third_party_customer_id      in  number           default hr_api.g_number,
  p_third_party_contact_id       in  number           default hr_api.g_number,
  p_third_party_address_id       in  number           default hr_api.g_number,
  p_third_party_contact_phone    in  varchar2         default hr_api.g_varchar2,
  p_third_party_contact_fax      in  varchar2         default hr_api.g_varchar2,
  p_date_status_changed          in  date             default hr_api.g_date,
  p_status_change_comments       in  varchar2         default hr_api.g_varchar2,
  p_failure_reason               in  varchar2         default hr_api.g_varchar2,
  p_attendance_result            in  varchar2         default hr_api.g_varchar2,
  p_language_id                  in  number           default hr_api.g_number,
  p_source_of_booking            in  varchar2         default hr_api.g_varchar2,
  p_special_booking_instructions in  varchar2         default hr_api.g_varchar2,
  p_successful_attendance_flag   in  varchar2         default hr_api.g_varchar2,
  p_tdb_information_category     in  varchar2         default hr_api.g_varchar2,
  p_tdb_information1             in  varchar2         default hr_api.g_varchar2,
  p_tdb_information2             in  varchar2         default hr_api.g_varchar2,
  p_tdb_information3             in  varchar2         default hr_api.g_varchar2,
  p_tdb_information4             in  varchar2         default hr_api.g_varchar2,
  p_tdb_information5             in  varchar2         default hr_api.g_varchar2,
  p_tdb_information6             in  varchar2         default hr_api.g_varchar2,
  p_tdb_information7             in  varchar2         default hr_api.g_varchar2,
  p_tdb_information8             in  varchar2         default hr_api.g_varchar2,
  p_tdb_information9             in  varchar2         default hr_api.g_varchar2,
  p_tdb_information10            in  varchar2         default hr_api.g_varchar2,
  p_tdb_information11            in  varchar2         default hr_api.g_varchar2,
  p_tdb_information12            in  varchar2         default hr_api.g_varchar2,
  p_tdb_information13            in  varchar2         default hr_api.g_varchar2,
  p_tdb_information14            in  varchar2         default hr_api.g_varchar2,
  p_tdb_information15            in  varchar2         default hr_api.g_varchar2,
  p_tdb_information16            in  varchar2         default hr_api.g_varchar2,
  p_tdb_information17            in  varchar2         default hr_api.g_varchar2,
  p_tdb_information18            in  varchar2         default hr_api.g_varchar2,
  p_tdb_information19            in  varchar2         default hr_api.g_varchar2,
  p_tdb_information20            in  varchar2         default hr_api.g_varchar2,
  p_update_finance_line          in  varchar2         default 'N',
  p_tfl_object_version_number    in  out nocopy number,
  p_finance_header_id            in  number           default hr_api.g_number,
  p_finance_line_id              in  out nocopy number,
  p_standard_amount              in  number           default hr_api.g_number,
  p_unitary_amount               in  number           default hr_api.g_number,
  p_money_amount                 in  number           default hr_api.g_number,
  p_currency_code                in  varchar2         default hr_api.g_varchar2,
  p_booking_deal_type            in  varchar2         default hr_api.g_varchar2,
  p_booking_deal_id              in  number           default hr_api.g_number,
  p_enrollment_type              in  varchar2         default hr_api.g_varchar2,
  p_organization_id              in  number           default hr_api.g_number,
  p_sponsor_person_id            in  number           default hr_api.g_number,
  p_sponsor_assignment_id        in  number           default hr_api.g_number,
  p_person_address_id            in  number           default hr_api.g_number,
  p_delegate_assignment_id       in  number           default hr_api.g_number,
  p_delegate_contact_id          in  number           default hr_api.g_number,
  p_delegate_contact_email       in  varchar2         default hr_api.g_varchar2,
  p_third_party_email            in  varchar2         default hr_api.g_varchar2,
  p_person_address_type          in  varchar2         default hr_api.g_varchar2,
  p_line_id                      in  number           default hr_api.g_number,
  p_org_id                       in  number           default hr_api.g_number,
  p_daemon_flag                  in  varchar2         default hr_api.g_varchar2,
  p_daemon_type                  in  varchar2         default hr_api.g_varchar2,
  p_old_event_id                 in  number           default hr_api.g_number,
  p_quote_line_id                in  number           default hr_api.g_number,
  p_interface_source             in  varchar2         default hr_api.g_varchar2,
  p_total_training_time          in  varchar2         default hr_api.g_varchar2,
  p_content_player_status        in  varchar2         default hr_api.g_varchar2,
  p_score                        in  number           default hr_api.g_number,
  p_completed_content            in  number           default hr_api.g_number,
  p_total_content                in  number           default hr_api.g_number,
  p_booking_justification_id     in  number           default hr_api.g_number,
  p_is_history_flag       	 in  varchar2         default hr_api.g_varchar2
 ,p_override_prerequisites 	 in  varchar2         default 'N'
 ,p_override_learner_access 	 in  varchar2         default 'N'
 ,p_source_cancel                in  varchar2         default hr_api.g_varchar2
 ,p_sign_eval_status             in  varchar2         default null
  );

--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_delegate_booking >----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes the enrollment of a learner in a class.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Learning Management.
 *
 * <p><b>Prerequisites</b><br>
 * The enrollment should not have a finance line attached to it.
 *
 * <p><b>Post Success</b><br>
 * The enrollment record will be deleted from the database.
 *
 * <p><b>Post Failure</b><br>
 * The enrollment will not be deleted and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_booking_id The unique identifier for the enrollment.
 * @param p_object_version_number Current version number of the enrollment
 * to be deleted.

 * @rep:displayname Delete Enrollment
 * @rep:category BUSINESS_ENTITY OTA_LEARNER_ENROLLMENT
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_delegate_booking
(
  p_validate                           in boolean default false,
  p_booking_id                         in number,
  p_object_version_number              in number
);

--
-- ----------------------------------------------------------------------------
-- |----------------------------< update_waitlisted >-------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates Waitlisted enrollments from the Waitlist window.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Learning Management.
 *
 * <p><b>Prerequisites</b><br>
 * The learner should have learner access for the class for which enrollment
 * is going to be updated.
 *
 * <p><b>Post Success</b><br>
 * The waitlisted enrollment record is updated.
 *
 * <p><b>Post Failure</b><br>
 * The waitlisted enrollment record is not updated and an error is raised.
 *
 * @param p_booking_id The unique identifier for the enrollment.
 * @param p_object_version_number Pass the current version number of the
 * enrollment to be updated.When the API completes if p_validate is false,will
 * be set to the new version number of the updated enrollment. If p_validate
 * is true will be set to the same value which was passed in.
 * @param p_event_id Identifies the class in which person or contact is enrolled.
 * @param p_booking_status_type_id {@rep:casecolumn
 * OTA_BOOKING_STATUS_TYPES.BOOKING_STATUS_TYPE_ID}.
 * @param p_date_status_changed {@rep:casecolumn
 * OTA_DELEGATE_BOOKINGS.DATE_STATUS_CHANGED}.
 * @param p_status_change_comments Comments on enrollment status change.
 * @param p_number_of_places Identifies the number of places needed in the class.
 * @param p_finance_line_id Identifies the finance line.
 * @param p_tfl_object_version_number If p_validate is false, then set to the
 * version number of the updated finance line. If p_validate is true, then the
 * value will be null.
 * @param p_administrator {@rep:casecolumn
 * OTA_DELEGATE_BOOKINGS.ADMINISTRATOR}.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @rep:displayname Update Waitlisted Enrollments
 * @rep:category BUSINESS_ENTITY OTA_LEARNER_ENROLLMENT
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope private
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
Procedure Update_Waitlisted
  (
  p_booking_id 			in number,
  p_object_version_number 	in out nocopy number,
  p_event_id 			in number,
  p_booking_status_type_id 	in number,
  p_date_status_changed 	in date,
  p_status_change_comments	in varchar2,
  p_number_of_places		in number,
  p_finance_line_id 		in out nocopy number,
  p_tfl_object_version_number 	in out nocopy number,
  p_administrator		in number,
  p_validate 			in boolean
  );
--
-- ----------------------------------------------------------------------------
-- |--------------------------< chk_mandatory_prereqs >-----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API checks for all the mandatory prerequisites required for a class.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Learning Management.
 *
 * <p><b>Prerequisites</b><br>
 * The Person or Contact must exist.
 *
 * <p><b>Post Success</b><br>
 * The Person or Contact has completed all the mandatory prerequisites required
 * for the class.
 *
 * <p><b>Post Failure</b><br>
 * The Person or Contact has not completed all the mandatory prerequisites required
 * for the class and an error is raised.
 *
 * @param p_delegate_person_id Identifies the person for whom the enrollment record
 * is being updated.
 * @param p_delegate_contact_id {@rep:casecolumn
 * OTA_DELEGATE_BOOKINGS.DELEGATE_CONTACT_ID}.
 * @param p_customer_id Identifies the customer for whom the enrollment
 * record is being updated.
 * @param p_event_id Identifies the class in which person or
 * contact is enrolled.
 * @param p_booking_status_type_id {@rep:casecolumn
 * OTA_BOOKING_STATUS_TYPES.BOOKING_STATUS_TYPE_ID}.
 * @rep:displayname Check Mandatory Prerequisites
 * @rep:category BUSINESS_ENTITY OTA_LEARNER_ENROLLMENT
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope private
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--

Procedure chk_mandatory_prereqs
         (p_delegate_person_id in number,
	  p_delegate_contact_id in number,
	  p_customer_id in number,
	  p_event_id number,
          p_booking_status_type_id in number
         );


--
procedure create_finance_header
  ( p_finance_header_id            in number,
    p_result_finance_header_id     out nocopy number,
    p_result_create_finance_line   out nocopy varchar2,
    p_create_finance_line          in  varchar2,
    p_event_id                     in number,
    p_delegate_person_id           in  number,
    p_delegate_assignment_id       in  number,
    p_business_group_id_from       in  number,
    p_booking_status_type_id       in  number
   );

end ota_delegate_booking_api;

/
