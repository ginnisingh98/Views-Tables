--------------------------------------------------------
--  DDL for Package PAY_GRR_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_GRR_UPD" AUTHID CURRENT_USER as
/* $Header: pygrrrhi.pkh 115.3 2002/12/10 09:48:11 pkakar ship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is the record interface for the update business
--   process for the specified entity. The role of this process is
--   to perform the datetrack update mode, fully validating the row
--   for the HR schema passing back to the calling process, any system
--   generated values (e.g. object version number attribute). This process
--   is the main backbone of the upd business process. The processing of
--   this procedure is as follows:
--   1) Ensure that the datetrack update mode is valid.
--   2) If the p_validate argument has been set to true then a savepoint
--      is issued.
--   3) The row to be updated is then locked and selected into the record
--      structure g_old_rec.
--   4) Because on update arguments which are not part of the update do not
--      have to be defaulted, we need to build up the updated row by
--      converting any system defaulted arguments to their corresponding
--      value.
--   5) The controlling validation process update_validate is then executed
--      which will execute all private and public validation business rule
--      processes.
--   6) The pre_update business process is then executed which enables any
--      logic to be processed before the update dml process is executed.
--   7) The update_dml process will physical perform the update dml into the
--      specified entity.
--   8) The post_update business process is then executed which enables any
--      logic to be processed after the update dml process.
--   9) If the p_validate argument has been set to true an exception is
--      raised which is handled and processed by performing a rollback to
--      the savepoint which was issued at the beginning of the upd process.
--
-- Pre Conditions:
--   The main arguments to the business process have to be in the record
--   format. The following attributes in p_rec are mandatory:
--   business_group_id, grade_or_spinal_point_id, rate_id and rate_type.
--
-- In Arguments:
--   p_effective_date
--     Specifies the date of the datetrack update operation.
--   p_datetrack_mode
--     Determines the datetrack update mode.
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
--   The specified row will be fully validated and datetracked updated for
--   the specified entity without being committed for the datetrack mode. If
--   the p_validate argument has been set to true then all the work will be
--   rolled back.
--   p_rec.object_version_number will be set with the new object_version_number
--   for the grade rule record.
--
-- Post Failure:
--   If an error has occurred, an error message will be supplied with the work
--   rolled back. A failure will occur if any of the following business rules/
--   conditions are found:
--     1) The mandatory arguments have not been set.
--     2) The p_rec.maximum value is less than the p_rec.minimum value.
--     3) The p_rec.maximum value is less than the p_rec.minimum value.
--     4) The p_rec.mid_value value is less than the p_rec.minimum value.
--     5) The p_rec.mid_value value is greater than the p_rec.maximum value.
--     6) The p_rec.minimum value is greater than the p_rec.value value.
--     7) The p_rec.value value is greater than the p_rec.maximum value.
--     8) An attempt is made to update on of the following attributes:
--        p_rec.grade_rule_id, p_rec.business_group_id,
--        p_rec.grade_or_spinal_point_id, p_rec.rate_id and p_rec.rate_type.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure upd
  (
  p_rec			in out nocopy 	pay_grr_shd.g_rec_type,
  p_effective_date	in 	date,
  p_datetrack_mode	in 	varchar2,
  p_validate		in 	boolean default false
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is the attribute interface for the datetrack update
--   business process for the specified entity and is the outermost layer.
--   The role of this process is to update a fully validated row into the
--   HR schema passing back to the calling process, any system generated
--   values (e.g. object version number attributes).The processing of this
--   procedure is as follows:
--   1) The attributes are converted into a local record structure by
--      calling the convert_defs function.
--   2) After the conversion has taken place, the corresponding record upd
--      interface business process is executed.
--   3) OUT arguments are then set to their corresponding record arguments.
--
-- Pre Conditions:
--   Refer to the upd record interface for details.
--
-- In Arguments:
--   p_effective_date
--     Specifies the date of the datetrack update operation.
--   p_datetrack_mode
--     Determines the datetrack update mode.
--   p_validate
--     Determines if the business process is to be validated. Setting this
--     Boolean value to true will invoke the process to be validated.
--     The default is false.
--
-- Post Success:
--   A fully validated row will be updated for the specified entity
--   without being committed (or rollbacked depending on the p_validate
--   status).
--   p_object_version_number will be set with the new object_version_number
--   for the grade rule record.
--
-- Post Failure:
--   If an error has occurred, an error message will be supplied with the work
--   rolled back. Refer to the upd record interface for details of possible
--   failures.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure upd
  (
  p_grade_rule_id                in number,
  p_effective_start_date         out nocopy date,
  p_effective_end_date           out nocopy date,
  p_maximum                      in varchar2         default hr_api.g_varchar2,
  p_mid_value                    in varchar2         default hr_api.g_varchar2,
  p_minimum                      in varchar2         default hr_api.g_varchar2,
  p_value                        in varchar2         default hr_api.g_varchar2,
  p_request_id                   in number           default hr_api.g_number,
  p_program_application_id       in number           default hr_api.g_number,
  p_program_id                   in number           default hr_api.g_number,
  p_program_update_date          in date             default hr_api.g_date,
  p_object_version_number        in out nocopy number,
  p_effective_date		 in date,
  p_datetrack_mode		 in varchar2,
  p_validate			 in boolean      default false,
  p_currency_code                in varchar2     default hr_api.g_varchar2
  );
--
end pay_grr_upd;

 

/
