--------------------------------------------------------
--  DDL for Package OTA_TFH_API_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_TFH_API_UPD" AUTHID CURRENT_USER as
/* $Header: ottfh01t.pkh 120.0 2005/05/29 07:40:27 appldev noship $ */
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
  p_rec                 in out nocopy ota_tfh_api_shd.g_rec_type,
  p_validate            in     boolean default false,
  p_transaction_type    in     varchar2 default 'UPDATE'
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
  p_finance_header_id            in number,
  p_superceding_header_id        in number           default hr_api.g_number,
  p_authorizer_person_id         in number           default hr_api.g_number,
  p_organization_id              in number           default hr_api.g_number,
  p_administrator                in number           default hr_api.g_number,
  p_cancelled_flag               in varchar2         default hr_api.g_varchar2,
  p_currency_code                in varchar2         default hr_api.g_varchar2,
  p_date_raised                  in date             default hr_api.g_date,
  p_object_version_number        in out nocopy number,
  p_payment_status_flag          in varchar2         default hr_api.g_varchar2,
  p_transfer_status              in varchar2         default hr_api.g_varchar2,
  p_type                         in varchar2         default hr_api.g_varchar2,
  p_receivable_type              in varchar2         default hr_api.g_varchar2,
  p_comments                     in varchar2         default hr_api.g_varchar2,
  p_external_reference           in varchar2         default hr_api.g_varchar2,
  p_invoice_address              in varchar2         default hr_api.g_varchar2,
  p_invoice_contact              in varchar2         default hr_api.g_varchar2,
  p_payment_method               in varchar2         default hr_api.g_varchar2,
  p_pym_attribute1               in varchar2         default hr_api.g_varchar2,
  p_pym_attribute10              in varchar2         default hr_api.g_varchar2,
  p_pym_attribute11              in varchar2         default hr_api.g_varchar2,
  p_pym_attribute12              in varchar2         default hr_api.g_varchar2,
  p_pym_attribute13              in varchar2         default hr_api.g_varchar2,
  p_pym_attribute14              in varchar2         default hr_api.g_varchar2,
  p_pym_attribute15              in varchar2         default hr_api.g_varchar2,
  p_pym_attribute16              in varchar2         default hr_api.g_varchar2,
  p_pym_attribute17              in varchar2         default hr_api.g_varchar2,
  p_pym_attribute18              in varchar2         default hr_api.g_varchar2,
  p_pym_attribute19              in varchar2         default hr_api.g_varchar2,
  p_pym_attribute2               in varchar2         default hr_api.g_varchar2,
  p_pym_attribute20              in varchar2         default hr_api.g_varchar2,
  p_pym_attribute3               in varchar2         default hr_api.g_varchar2,
  p_pym_attribute4               in varchar2         default hr_api.g_varchar2,
  p_pym_attribute5               in varchar2         default hr_api.g_varchar2,
  p_pym_attribute6               in varchar2         default hr_api.g_varchar2,
  p_pym_attribute7               in varchar2         default hr_api.g_varchar2,
  p_pym_attribute8               in varchar2         default hr_api.g_varchar2,
  p_pym_attribute9               in varchar2         default hr_api.g_varchar2,
  p_pym_information_category     in varchar2         default hr_api.g_varchar2,
  p_transfer_date                in date             default hr_api.g_date,
  p_transfer_message             in varchar2         default hr_api.g_varchar2,
  p_vendor_id                    in number           default hr_api.g_number,
  p_contact_id                   in number           default hr_api.g_number,
  p_address_id                   in number           default hr_api.g_number,
  p_customer_id                  in number           default hr_api.g_number,
  p_tfh_information_category     in varchar2         default hr_api.g_varchar2,
  p_tfh_information1             in varchar2         default hr_api.g_varchar2,
  p_tfh_information2             in varchar2         default hr_api.g_varchar2,
  p_tfh_information3             in varchar2         default hr_api.g_varchar2,
  p_tfh_information4             in varchar2         default hr_api.g_varchar2,
  p_tfh_information5             in varchar2         default hr_api.g_varchar2,
  p_tfh_information6             in varchar2         default hr_api.g_varchar2,
  p_tfh_information7             in varchar2         default hr_api.g_varchar2,
  p_tfh_information8             in varchar2         default hr_api.g_varchar2,
  p_tfh_information9             in varchar2         default hr_api.g_varchar2,
  p_tfh_information10            in varchar2         default hr_api.g_varchar2,
  p_tfh_information11            in varchar2         default hr_api.g_varchar2,
  p_tfh_information12            in varchar2         default hr_api.g_varchar2,
  p_tfh_information13            in varchar2         default hr_api.g_varchar2,
  p_tfh_information14            in varchar2         default hr_api.g_varchar2,
  p_tfh_information15            in varchar2         default hr_api.g_varchar2,
  p_tfh_information16            in varchar2         default hr_api.g_varchar2,
  p_tfh_information17            in varchar2         default hr_api.g_varchar2,
  p_tfh_information18            in varchar2         default hr_api.g_varchar2,
  p_tfh_information19            in varchar2         default hr_api.g_varchar2,
  p_tfh_information20            in varchar2         default hr_api.g_varchar2,
  p_paying_cost_center           in varchar2         default hr_api.g_varchar2,
  p_receiving_cost_center        in varchar2         default hr_api.g_varchar2,
  p_transfer_from_set_of_book_id in number		default hr_api.g_number,
  p_transfer_to_set_of_book_id   in number		default hr_api.g_number,
  p_from_segment1                 in varchar2		default hr_api.g_varchar2,
  p_from_segment2                 in varchar2		default hr_api.g_varchar2,
  p_from_segment3                 in varchar2		default hr_api.g_varchar2,
  p_from_segment4                 in varchar2		default hr_api.g_varchar2,
  p_from_segment5                 in varchar2		default hr_api.g_varchar2,
  p_from_segment6                 in varchar2		default hr_api.g_varchar2,
  p_from_segment7                 in varchar2		default hr_api.g_varchar2,
  p_from_segment8                 in varchar2		default hr_api.g_varchar2,
  p_from_segment9                 in varchar2		default hr_api.g_varchar2,
  p_from_segment10                in varchar2		default hr_api.g_varchar2,
  p_from_segment11                 in varchar2		default hr_api.g_varchar2,
  p_from_segment12                 in varchar2		default hr_api.g_varchar2,
  p_from_segment13                 in varchar2		default hr_api.g_varchar2,
  p_from_segment14                 in varchar2		default hr_api.g_varchar2,
  p_from_segment15                 in varchar2		default hr_api.g_varchar2,
  p_from_segment16                 in varchar2		default hr_api.g_varchar2,
  p_from_segment17                 in varchar2		default hr_api.g_varchar2,
  p_from_segment18                 in varchar2		default hr_api.g_varchar2,
  p_from_segment19                 in varchar2		default hr_api.g_varchar2,
  p_from_segment20                in varchar2		default hr_api.g_varchar2,
  p_from_segment21                 in varchar2		default hr_api.g_varchar2,
  p_from_segment22                 in varchar2		default hr_api.g_varchar2,
  p_from_segment23                 in varchar2		default hr_api.g_varchar2,
  p_from_segment24                 in varchar2		default hr_api.g_varchar2,
  p_from_segment25                 in varchar2		default hr_api.g_varchar2,
  p_from_segment26                 in varchar2		default hr_api.g_varchar2,
  p_from_segment27                 in varchar2		default hr_api.g_varchar2,
  p_from_segment28                 in varchar2		default hr_api.g_varchar2,
  p_from_segment29                	in varchar2		default hr_api.g_varchar2,
  p_from_segment30                	in varchar2		default hr_api.g_varchar2,
  p_to_segment1                 	in varchar2		default hr_api.g_varchar2,
  p_to_segment2                 	in varchar2		default hr_api.g_varchar2,
  p_to_segment3                 	in varchar2		default hr_api.g_varchar2,
  p_to_segment4                 	in varchar2		default hr_api.g_varchar2,
  p_to_segment5                 	in varchar2		default hr_api.g_varchar2,
  p_to_segment6                 	in varchar2		default hr_api.g_varchar2,
  p_to_segment7                 	in varchar2		default hr_api.g_varchar2,
  p_to_segment8                 	in varchar2		default hr_api.g_varchar2,
  p_to_segment9                 	in varchar2		default hr_api.g_varchar2,
  p_to_segment10                	in varchar2		default hr_api.g_varchar2,
  p_to_segment11                 	in varchar2		default hr_api.g_varchar2,
  p_to_segment12                	in varchar2		default hr_api.g_varchar2,
  p_to_segment13                 	in varchar2		default hr_api.g_varchar2,
  p_to_segment14                 	in varchar2		default hr_api.g_varchar2,
  p_to_segment15                 	in varchar2		default hr_api.g_varchar2,
  p_to_segment16                 	in varchar2		default hr_api.g_varchar2,
  p_to_segment17                 	in varchar2		default hr_api.g_varchar2,
  p_to_segment18                 	in varchar2		default hr_api.g_varchar2,
  p_to_segment19                 	in varchar2		default hr_api.g_varchar2,
  p_to_segment20                	in varchar2		default hr_api.g_varchar2,
  p_to_segment21                 	in varchar2		default hr_api.g_varchar2,
  p_to_segment22                 	in varchar2		default hr_api.g_varchar2,
  p_to_segment23                 	in varchar2		default hr_api.g_varchar2,
  p_to_segment24                 	in varchar2		default hr_api.g_varchar2,
  p_to_segment25                 	in varchar2		default hr_api.g_varchar2,
  p_to_segment26                 	in varchar2		default hr_api.g_varchar2,
  p_to_segment27                 	in varchar2		default hr_api.g_varchar2,
  p_to_segment28                 	in varchar2		default hr_api.g_varchar2,
  p_to_segment29                 	in varchar2		default hr_api.g_varchar2,
  p_to_segment30                	in varchar2 	default hr_api.g_varchar2,
  p_transfer_from_cc_id             in number         default hr_api.g_number,
  p_transfer_to_cc_id               in number         default hr_api.g_number,
  p_validate                     	in boolean        default false,
  p_transaction_type             	in varchar2       default 'UPDATE'
  );
--
end ota_tfh_api_upd;

 

/
