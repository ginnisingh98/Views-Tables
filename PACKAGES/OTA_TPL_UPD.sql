--------------------------------------------------------
--  DDL for Package OTA_TPL_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_TPL_UPD" AUTHID CURRENT_USER as
/* $Header: ottpl01t.pkh 115.0 99/07/16 00:56:02 porting ship $ */
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
  p_rec        in out ota_tpl_shd.g_rec_type,
  p_validate   in     boolean default false
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
  p_price_list_id                in number,
  p_business_group_id            in number           default hr_api.g_number,
  p_currency_code                in varchar2         default hr_api.g_varchar2,
  p_default_flag                 in varchar2         default hr_api.g_varchar2,
  p_name                         in varchar2         default hr_api.g_varchar2,
  p_object_version_number        in out number,
  p_price_list_type              in varchar2         default hr_api.g_varchar2,
  p_start_date                   in date             default hr_api.g_date,
  p_comments                     in varchar2         default hr_api.g_varchar2,
  p_description                  in varchar2         default hr_api.g_varchar2,
  p_end_date                     in date             default hr_api.g_date,
  p_single_unit_price            in number           default hr_api.g_number,
  p_training_unit_type           in varchar2         default hr_api.g_varchar2,
  p_tpl_information_category     in varchar2         default hr_api.g_varchar2,
  p_tpl_information1             in varchar2         default hr_api.g_varchar2,
  p_tpl_information2             in varchar2         default hr_api.g_varchar2,
  p_tpl_information3             in varchar2         default hr_api.g_varchar2,
  p_tpl_information4             in varchar2         default hr_api.g_varchar2,
  p_tpl_information5             in varchar2         default hr_api.g_varchar2,
  p_tpl_information6             in varchar2         default hr_api.g_varchar2,
  p_tpl_information7             in varchar2         default hr_api.g_varchar2,
  p_tpl_information8             in varchar2         default hr_api.g_varchar2,
  p_tpl_information9             in varchar2         default hr_api.g_varchar2,
  p_tpl_information10            in varchar2         default hr_api.g_varchar2,
  p_tpl_information11            in varchar2         default hr_api.g_varchar2,
  p_tpl_information12            in varchar2         default hr_api.g_varchar2,
  p_tpl_information13            in varchar2         default hr_api.g_varchar2,
  p_tpl_information14            in varchar2         default hr_api.g_varchar2,
  p_tpl_information15            in varchar2         default hr_api.g_varchar2,
  p_tpl_information16            in varchar2         default hr_api.g_varchar2,
  p_tpl_information17            in varchar2         default hr_api.g_varchar2,
  p_tpl_information18            in varchar2         default hr_api.g_varchar2,
  p_tpl_information19            in varchar2         default hr_api.g_varchar2,
  p_tpl_information20            in varchar2         default hr_api.g_varchar2,
  p_validate                     in boolean      default false
  );
--
end ota_tpl_upd;

 

/
