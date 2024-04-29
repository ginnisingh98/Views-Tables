--------------------------------------------------------
--  DDL for Package OTA_TDB_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_TDB_INS" AUTHID CURRENT_USER as
/* $Header: ottdb01t.pkh 120.5.12010000.2 2009/08/13 09:15:22 smahanka ship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------------< set_base_key_value >----------------------------|
-- ----------------------------------------------------------------------------
procedure set_base_key_value
  (p_booking_id  in  number);
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is the record interface for the insert business process
--   for the specified entity. The role of this process is to insert a fully
--   validated row, into the HR schema passing back to  the calling process,
--   any system generated values (e.g. primary and object version number
--   attributes). This process is the main backbone of the ins business
--   process. The processing of this procedure is as follows:
--   1) If the p_validate argument has been set to true then a savepoint is
--      issued.
--   2) The controlling validation process insert_validate is then executed
--      which will execute all private and public validation business rule
--      processes.
--   3) The pre_insert business process is then executed which enables any
--      logic to be processed before the insert dml process is executed.
--   4) The insert_dml process will physical perform the insert dml into the
--      specified entity.
--   5) The post_insert business process is then executed which enables any
--      logic to be processed after the insert dml process.
--   6) If the p_validate argument has been set to true an exception is raised
--      which is handled and processed by performing a rollback to the
--      savepoint which was issued at the beginning of the Ins process.
--
-- Pre Conditions:
--   The main arguments to the business process have to be in the record
--   format.
--
-- In Arguments:
--   p_validate
--     Determines if the business process is to be validated. Setting this
--     boolean value to true will invoke the process to be validated. The
--     default is false. The validation is controlled by a savepoint and
--     rollback mechanism. The savepoint is issued at the beginning of the
--     business process and is rollbacked at the end of the business process
--     when all the processing has been completed. The rollback is controlled
--     by raising and handling the exception hr_api.validate_enabled. We use
--     the exception because, by raising the exception with the business
--     process, we can exit successfully without having any of the 'OUT'
--     arguments being set.
--
-- Post Success:
--   A fully validated row will be inserted into the specified entity
--   without being committed. If the p_validate argument has been set to true
--   then all the work will be rolled back.
--
-- Post Failure:
--   If an error has occurred, an error message will be supplied with the work
--   rolled back.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure ins
  (
  p_rec                 in out nocopy ota_tdb_shd.g_rec_type,
  p_create_finance_line in     varchar2,
  p_finance_header_id   in     number,
  p_currency_code       in     varchar2,
  p_standard_amount     in     number,
  p_unitary_amount      in     number,
  p_money_amount        in     number,
  p_booking_deal_id     in     number,
  p_booking_deal_type   in     varchar2,
  p_finance_line_id     in out nocopy number,
  p_enrollment_type     in     varchar2,
  p_validate            in     boolean  default false

  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is the attribute interface for the insert business
--   process for the specified entity and is the outermost layer. The role
--   of this process is to insert a fully validated row into the HR schema
--   passing back to the calling process, any system generated values
--   (e.g. object version number attributes).The processing of this
--   procedure is as follows:
--   1) The attributes are converted into a local record structure by
--      calling the convert_args function.
--   2) After the conversion has taken place, the corresponding record ins
--      interface business process is executed.
--   3) OUT arguments are then set to their corresponding record arguments.
--
-- Pre Conditions:
--
-- In Arguments:
--   p_validate
--     Determines if the business process is to be validated. Setting this
--     Boolean value to true will invoke the process to be validated.
--     The default is false.
--
-- Post Success:
--   A fully validated row will be inserted for the specified entity
--   without being committed (or rollbacked depending on the p_validate
--   status).
--
-- Post Failure:
--   If an error has occurred, an error message will be supplied with the work
--   rolled back.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure ins
  (
  p_booking_id                   out nocopy number,
  p_booking_status_type_id       in number,
  p_delegate_person_id           in number           default null,
  p_contact_id                   in number,
  p_business_group_id            in number,
  p_event_id                     in number,
  p_customer_id                  in number           default null,
  p_authorizer_person_id         in number           default null,
  p_date_booking_placed          in date,
  p_corespondent                 in varchar2         default null,
  p_internal_booking_flag        in varchar2,
  p_number_of_places             in number,
  p_object_version_number        out nocopy number,
  p_administrator                in number           default null,
  p_booking_priority             in varchar2         default null,
  p_comments                     in varchar2         default null,
  p_contact_address_id           in number           default null,
  p_delegate_contact_phone       in varchar2         default null,
  p_delegate_contact_fax         in varchar2         default null,
  p_third_party_customer_id      in number           default null,
  p_third_party_contact_id       in number           default null,
  p_third_party_address_id       in number           default null,
  p_third_party_contact_phone    in varchar2         default null,
  p_third_party_contact_fax      in varchar2         default null,
  p_date_status_changed          in date             default null,
  p_failure_reason               in varchar2         default null,
  p_attendance_result            in varchar2         default null,
  p_language_id                  in number           default null,
  p_source_of_booking            in varchar2         default null,
  p_special_booking_instructions in varchar2         default null,
  p_successful_attendance_flag   in varchar2         default null,
  p_tdb_information_category     in varchar2         default null,
  p_tdb_information1             in varchar2         default null,
  p_tdb_information2             in varchar2         default null,
  p_tdb_information3             in varchar2         default null,
  p_tdb_information4             in varchar2         default null,
  p_tdb_information5             in varchar2         default null,
  p_tdb_information6             in varchar2         default null,
  p_tdb_information7             in varchar2         default null,
  p_tdb_information8             in varchar2         default null,
  p_tdb_information9             in varchar2         default null,
  p_tdb_information10            in varchar2         default null,
  p_tdb_information11            in varchar2         default null,
  p_tdb_information12            in varchar2         default null,
  p_tdb_information13            in varchar2         default null,
  p_tdb_information14            in varchar2         default null,
  p_tdb_information15            in varchar2         default null,
  p_tdb_information16            in varchar2         default null,
  p_tdb_information17            in varchar2         default null,
  p_tdb_information18            in varchar2         default null,
  p_tdb_information19            in varchar2         default null,
  p_tdb_information20            in varchar2         default null,
  p_create_finance_line          in varchar2         default null,
  p_finance_header_id            in number           default null,
  p_currency_code                in varchar2         default null,
  p_standard_amount              in number           default null,
  p_unitary_amount               in number           default null,
  p_money_amount                 in number           default null,
  p_booking_deal_id              in number           default null,
  p_booking_deal_type            in varchar2         default null,
  p_finance_line_id              in out nocopy number,
  p_enrollment_type              in varchar2      default null,
  p_validate                     in boolean          default false,
  p_organization_id              in number           default null,
  p_sponsor_person_id            in number           default null,
  p_sponsor_assignment_id        in number           default null,
  p_person_address_id            in number           default null,
  p_delegate_assignment_id       in number           default null,
  p_delegate_contact_id          in number           default null,
  p_delegate_contact_email       in varchar2         default null,
  p_third_party_email            in varchar2         default null,
  p_person_address_type          in varchar2         default null,
  p_line_id             in number        default null,
  p_org_id              in number        default null,
  p_daemon_flag            in varchar2      default null,
  p_daemon_type            in varchar2      default null,
  p_old_event_id                 in number           default null,
  p_quote_line_id                in number           default null,
  p_interface_source             in varchar2         default null,
  p_total_training_time          in varchar2         default null,
  p_content_player_status        in varchar2         default null,
  p_score                     in number           default null,
  p_completed_content         in number           default null,
  p_total_content	               in number   	     default null  ,
  p_booking_justification_id                   in number default null,
  p_is_history_flag in varchar2 default null,
  p_sign_eval_status in varchar2 default null,
  p_is_mandatory_enrollment in varchar2 default 'N');
--
end ota_tdb_ins;

/
