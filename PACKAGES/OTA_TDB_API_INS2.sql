--------------------------------------------------------
--  DDL for Package OTA_TDB_API_INS2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_TDB_API_INS2" AUTHID CURRENT_USER as
/* $Header: ottdb02t.pkh 120.9.12010000.2 2009/08/12 14:12:22 smahanka ship $ */
/*#
 * This package creates a learner enrollment in a class.
 * @rep:scope private
 * @rep:product ota
 * @rep:displayname Enrollment
*/
--
-- ----------------------------------------------------------------------------
-- |----------------------------< create_enrollment >-------------------------|
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
 * @param p_delegate_contact_phone {@rep:casecolumn
 * OTA_DELEGATE_BOOKINGS.DELEGATE_CONTACT_PHONE}.
 * @param p_delegate_contact_fax {@rep:casecolumn
 * OTA_DELEGATE_BOOKINGS.DELEGATE_CONTACT_FAX}.
 * @param p_third_party_customer_id {@rep:casecolumn
 * OTA_DELEGATE_BOOKINGS.THIRD_PARTY_CUSTOMER_ID}.
 * @param p_third_party_contact_id {@rep:casecolumn
 * OTA_DELEGATE_BOOKINGS.THIRD_PARTY_CONTACT_ID}.
 * @param p_third_party_address_id {@rep:casecolumn
 * OTA_DELEGATE_BOOKINGS.THIRD_PARTY_ADDRESS_ID}.
 * @param p_third_party_contact_phone {@rep:casecolumn
 * OTA_DELEGATE_BOOKINGS.THIRD_PARTY_CONTACT_PHONE}.
 * @param p_third_party_contact_fax {@rep:casecolumn
 * OTA_DELEGATE_BOOKINGS.THIRD_PARTY_CONTACT_FAX}.
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
 * OTA_DELEGATE_BOOKINGS.SPECIAL_BOOKING_INSTRUCTIONS}.
 * @param p_successful_attendance_flag {@rep:casecolumn
 * OTA_DELEGATE_BOOKINGS.SUCCESSFUL_ATTENDANCE_FLAG}.
 * @param p_tdb_information_category This context value determines which
 * Flexfield Structure to use with the Descriptive flexfield segment
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
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_organization_id {@rep:casecolumn
 * OTA_DELEGATE_BOOKINGS.ORGANIZATION_ID}.
 * @param p_sponsor_person_id {@rep:casecolumn
 * OTA_DELEGATE_BOOKINGS.SPONSOR_PERSON_ID}.
 * @param p_sponsor_assignment_id {@rep:casecolumn
 * OTA_DELEGATE_BOOKINGS.SPONSOR_ASSIGNMENT_ID}.
 * @param p_person_address_id {@rep:casecolumn
 * OTA_DELEGATE_BOOKINGS.PERSON_ADDRESS_ID}.
 * @param p_delegate_assignment_id {@rep:casecolumn
 * OTA_DELEGATE_BOOKINGS.DELEGATE_ASSIGNMENT_ID}.
 * @param p_delegate_contact_id Identifies the contact of the customer for whom
 * the enrollment record is being created.
 * @param p_delegate_contact_email {@rep:casecolumn
 * OTA_DELEGATE_BOOKINGS.DELEGATE_CONTACT_EMAIL}.
 * @param p_third_party_email {@rep:casecolumn
 * OTA_DELEGATE_BOOKINGS.THIRD_PARTY_EMAIL}.
 * @param p_person_address_type {@rep:casecolumn
 * OTA_DELEGATE_BOOKINGS.PERSON_ADDRESS_TYPE}.
 * @param p_line_id {@rep:casecolumn OTA_DELEGATE_BOOKINGS.LINE_ID}.
 * @param p_org_id {@rep:casecolumn OTA_DELEGATE_BOOKINGS.ORG_ID}.
 * @param p_daemon_flag {@rep:casecolumn OTA_DELEGATE_BOOKINGS.DAEMON_FLAG}.
 * @param p_daemon_type {@rep:casecolumn OTA_DELEGATE_BOOKINGS.DAEMON_TYPE}.
 * @param p_old_event_id {@rep:casecolumn OTA_DELEGATE_BOOKINGS.OLD_EVENT_ID}.
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
 * @param p_override_prerequisites Determines whether the course and
 * competency prerequisites check is to be overridden. Valid values are Y and
 * N. Default value is N.
 * @param p_book_from Specifies whether the enrollment originates from the
 * learner or admin. Valid value is 'AME' when coming from the learner;
 * otherwise it is null.
 * @param p_override_learner_access Determines whether the learner access
 * check is to be overridden. Valid values are Y and N. Default value is N.
 * @param p_is_history_flag Determines whether the enrollment record should
 * be moved to history. Valid values are Y and N. Default value is N.
 * @rep:displayname Create Enrollment
 * @rep:category BUSINESS_ENTITY OTA_LEARNER_ENROLLMENT
 * @rep:scope private
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure Create_Enrollment
  (
  p_booking_id				in out nocopy number,
  p_booking_status_type_id		in number,
  p_delegate_person_id			in number	default null,
  p_contact_id				in number,
  p_business_group_id			in number,
  p_event_id				in number,
  p_customer_id				in number	default null,
  p_authorizer_person_id		in number	default null,
  p_date_booking_placed			in date,
  p_corespondent			in varchar2	default null,
  p_internal_booking_flag		in varchar2,
  p_number_of_places			in number,
  p_object_version_number		in out nocopy number,
  p_administrator			in number	default null,
  p_booking_priority			in varchar2	default null,
  p_comments				in varchar2	default null,
  p_contact_address_id			in number	default null,
  p_delegate_contact_phone		in varchar2	default null,
  p_delegate_contact_fax		in varchar2	default null,
  p_third_party_customer_id		in number	default null,
  p_third_party_contact_id		in number	default null,
  p_third_party_address_id		in number	default null,
  p_third_party_contact_phone		in varchar2	default null,
  p_third_party_contact_fax		in varchar2	default null,
  p_date_status_changed			in date		default null,
  p_failure_reason			in varchar2	default null,
  p_attendance_result			in varchar2	default null,
  p_language_id				in number	default null,
  p_source_of_booking			in varchar2	default null,
  p_special_booking_instructions	in varchar2	default null,
  p_successful_attendance_flag		in varchar2	default null,
  p_tdb_information_category		in varchar2	default null,
  p_tdb_information1			in varchar2	default null,
  p_tdb_information2			in varchar2	default null,
  p_tdb_information3			in varchar2	default null,
  p_tdb_information4			in varchar2	default null,
  p_tdb_information5			in varchar2	default null,
  p_tdb_information6			in varchar2	default null,
  p_tdb_information7			in varchar2	default null,
  p_tdb_information8			in varchar2	default null,
  p_tdb_information9			in varchar2	default null,
  p_tdb_information10			in varchar2	default null,
  p_tdb_information11			in varchar2	default null,
  p_tdb_information12			in varchar2	default null,
  p_tdb_information13			in varchar2	default null,
  p_tdb_information14			in varchar2	default null,
  p_tdb_information15			in varchar2	default null,
  p_tdb_information16			in varchar2	default null,
  p_tdb_information17			in varchar2	default null,
  p_tdb_information18			in varchar2	default null,
  p_tdb_information19			in varchar2	default null,
  p_tdb_information20			in varchar2	default null,
  p_create_finance_line			in varchar2	default null,
  p_finance_header_id			in number	default null,
  p_currency_code			in varchar2	default null,
  p_standard_amount			in number	default null,
  p_unitary_amount			in number	default null,
  p_money_amount			in number	default null,
  p_booking_deal_id			in number	default null,
  p_booking_deal_type			in varchar2	default null,
  p_finance_line_id			in out nocopy number,
  p_enrollment_type			in varchar2,
  p_validate				in boolean	default false,
  p_organization_id              	in number	default null,
  p_sponsor_person_id            	in number	default null,
  p_sponsor_assignment_id        	in number	default null,
  p_person_address_id            	in number	default null,
  p_delegate_assignment_id       	in number	default null,
  p_delegate_contact_id          	in number	default null,
  p_delegate_contact_email       	in varchar2	default null,
  p_third_party_email            	in varchar2	default null,
  p_person_address_type          	in varchar2	default null,
  p_line_id                         	in number   default null,
  p_org_id                          	in number   default null,
  p_daemon_flag				in varchar2 default null,
  p_daemon_type				in varchar2 default null,
  p_old_event_id                    	in number   default null,
  p_quote_line_id                   	in number   default null,
  p_interface_source                	in varchar2 default null,
  p_total_training_time             	in varchar2 default null,
  p_content_player_status           	in varchar2 default null,
  p_score		                in number   default null,
  p_completed_content			in number   default null,
  p_total_content	                in number   default null,
  p_booking_justification_id            in number   default null,
  p_override_prerequisites              in varchar2 default 'N',
  p_book_from                           in varchar2 default null,
  p_override_learner_access             in varchar2 default 'N',
  p_is_history_flag                     in varchar2 default 'N',
  p_is_mandatory_enrollment             in varchar2 default 'N'

);
end ota_tdb_api_ins2;

/
