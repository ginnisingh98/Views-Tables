--------------------------------------------------------
--  DDL for Package OTA_TEA_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_TEA_UPD" AUTHID CURRENT_USER as
/* $Header: ottea01t.pkh 115.2 2002/11/29 10:05:15 arkashya ship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is the record interface for the update business
--   process for the specified entity. The role of this process is
--   to update a fully validated row for the HR schema passing back
--   to the calling process, any system generated values (e.g.
--   object version number attribute). This process is the main
--   backbone of the upd business process. The processing of this
--   procedure is as follows:
--   1) If the p_validate argument has been set to true then a savepoint
--      is issued.
--   2) The row to be updated is then locked and selected into the record
--      structure g_old_rec.
--   3) Because on update arguments which are not part of the update do not
--      have to be defaulted, we need to build up the updated row by
--      converting any system defaulted arguments to their corresponding
--      value.
--   4) The controlling validation process update_validate is then executed
--      which will execute all private and public validation business rule
--      processes.
--   5) The pre_update business process is then executed which enables any
--      logic to be processed before the update dml process is executed.
--   6) The update_dml process will physical perform the update dml into the
--      specified entity.
--   7) The post_update business process is then executed which enables any
--      logic to be processed after the update dml process.
--   8) If the p_validate argument has been set to true an exception is
--      raised which is handled and processed by performing a rollback to
--      the savepoint which was issued at the beginning of the upd process.
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
--   The specified row will be fully validated and updated for the specified
--   entity without being committed. If the p_validate argument has been set
--   to true then all the work will be rolled back.
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
Procedure upd
  (
  p_rec        in out nocopy ota_tea_shd.g_rec_type,
  p_validate   in     boolean default false
  ,p_association_type           in varchar2
  ,p_business_group_id          in number
  ,p_price_basis                  in varchar2
  ,p_booking_id                 in out nocopy number
  ,p_tdb_object_version_number  in out nocopy number
  ,p_booking_status_type_id     in number
  ,p_date_status_changed        in date
  ,p_status_change_comments     in varchar2
        ,p_booking_contact_id           in number
        ,p_contact_address_id           in number
        ,p_delegate_contact_phone       in varchar2
        ,p_delegate_contact_fax         in varchar2
        ,p_internal_booking_flag        in varchar2
	,p_source_of_booking		in varchar2
	,p_number_of_places             in number
	,p_date_booking_placed		in date
        ,p_tfl_object_version_number    in out nocopy number
        ,p_update_finance_line          in varchar2
        ,p_finance_header_id            in number
        ,p_currency_code                in varchar2
        ,p_standard_amount		in number
        ,p_unitary_amount               in number
        ,p_money_amount                 in number
        ,p_booking_deal_id              in number
        ,p_booking_deal_type            in varchar2
        ,p_finance_line_id              in out nocopy number
        ,p_delegate_contact_email       in varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is the attribute interface for the update business
--   process for the specified entity and is the outermost layer. The role
--   of this process is to update a fully validated row into the HR schema
--   passing back to the calling process, any system generated values
--   (e.g. object version number attributes).The processing of this
--   procedure is as follows:
--   1) The attributes are converted into a local record structure by
--      calling the convert_defs function.
--   2) After the conversion has taken place, the corresponding record upd
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
--   A fully validated row will be updated for the specified entity
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
Procedure upd
  (
  p_event_association_id         in number,
  p_event_id                     in number           default hr_api.g_number,
  p_customer_id                  in number           default hr_api.g_number,
  p_comments                     in varchar2         default hr_api.g_varchar2,
  p_tea_information_category     in varchar2         default hr_api.g_varchar2,
  p_tea_information1             in varchar2         default hr_api.g_varchar2,
  p_tea_information2             in varchar2         default hr_api.g_varchar2,
  p_tea_information3             in varchar2         default hr_api.g_varchar2,
  p_tea_information4             in varchar2         default hr_api.g_varchar2,
  p_tea_information5             in varchar2         default hr_api.g_varchar2,
  p_tea_information6             in varchar2         default hr_api.g_varchar2,
  p_tea_information7             in varchar2         default hr_api.g_varchar2,
  p_tea_information8             in varchar2         default hr_api.g_varchar2,
  p_tea_information9             in varchar2         default hr_api.g_varchar2,
  p_tea_information10            in varchar2         default hr_api.g_varchar2,
  p_tea_information11            in varchar2         default hr_api.g_varchar2,
  p_tea_information12            in varchar2         default hr_api.g_varchar2,
  p_tea_information13            in varchar2         default hr_api.g_varchar2,
  p_tea_information14            in varchar2         default hr_api.g_varchar2,
  p_tea_information15            in varchar2         default hr_api.g_varchar2,
  p_tea_information16            in varchar2         default hr_api.g_varchar2,
  p_tea_information17            in varchar2         default hr_api.g_varchar2,
  p_tea_information18            in varchar2         default hr_api.g_varchar2,
  p_tea_information19            in varchar2         default hr_api.g_varchar2,
  p_tea_information20            in varchar2         default hr_api.g_varchar2,
  p_validate                     in boolean      default false
  ,p_business_group_id           in number       default null
  ,p_price_basis                 in varchar2     default null
  ,p_booking_id                  in out nocopy number
  ,p_tdb_object_version_number   in out nocopy number
  ,p_booking_status_type_id      in number       default null
  ,p_date_status_changed         in date         default null
  ,p_status_change_comments      in varchar2     default null
  ,p_booking_contact_id          in number       default null
  ,p_contact_address_id          in number       default null
  ,p_delegate_contact_phone      in varchar2     default null
  ,p_delegate_contact_fax        in varchar2     default null
  ,p_internal_booking_flag       in varchar2     default null
  ,p_source_of_booking		 in varchar2     default null
  ,p_number_of_places            in number       default null
  ,p_date_booking_placed	 in date         default null
  ,p_tfl_object_version_number   in out nocopy  number
  ,p_update_finance_line         in varchar2     default null
  ,p_finance_header_id           in number       default null
  ,p_currency_code               in varchar2     default null
  ,p_standard_amount		 in number       default null
  ,p_unitary_amount              in number       default null
  ,p_money_amount                in number       default null
  ,p_booking_deal_id             in number       default null
  ,p_booking_deal_type           in varchar2     default null
  ,p_finance_line_id             in out nocopy number
  ,p_delegate_contact_email      in varchar2     default null
  );
--
Procedure upd
  (
  p_event_association_id         in number,
  p_event_id                     in number           default hr_api.g_number,
  p_organization_id              in number           default hr_api.g_number,
  p_job_id                       in number           default hr_api.g_number,
  p_position_id                  in number           default hr_api.g_number,
  p_comments                     in varchar2         default hr_api.g_varchar2,
  p_tea_information_category     in varchar2         default hr_api.g_varchar2,
  p_tea_information1             in varchar2         default hr_api.g_varchar2,
  p_tea_information2             in varchar2         default hr_api.g_varchar2,
  p_tea_information3             in varchar2         default hr_api.g_varchar2,
  p_tea_information4             in varchar2         default hr_api.g_varchar2,
  p_tea_information5             in varchar2         default hr_api.g_varchar2,
  p_tea_information6             in varchar2         default hr_api.g_varchar2,
  p_tea_information7             in varchar2         default hr_api.g_varchar2,
  p_tea_information8             in varchar2         default hr_api.g_varchar2,
  p_tea_information9             in varchar2         default hr_api.g_varchar2,
  p_tea_information10            in varchar2         default hr_api.g_varchar2,
  p_tea_information11            in varchar2         default hr_api.g_varchar2,
  p_tea_information12            in varchar2         default hr_api.g_varchar2,
  p_tea_information13            in varchar2         default hr_api.g_varchar2,
  p_tea_information14            in varchar2         default hr_api.g_varchar2,
  p_tea_information15            in varchar2         default hr_api.g_varchar2,
  p_tea_information16            in varchar2         default hr_api.g_varchar2,
  p_tea_information17            in varchar2         default hr_api.g_varchar2,
  p_tea_information18            in varchar2         default hr_api.g_varchar2,
  p_tea_information19            in varchar2         default hr_api.g_varchar2,
  p_tea_information20            in varchar2         default hr_api.g_varchar2,
  p_validate                     in boolean      default false
  );
--
end ota_tea_upd;

 

/
