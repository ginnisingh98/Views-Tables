--------------------------------------------------------
--  DDL for Package GHR_PRH_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_PRH_UPD" AUTHID CURRENT_USER as
/* $Header: ghprhrhi.pkh 120.1.12000000.1 2007/01/18 14:09:34 appldev noship $ */

--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is the record interface for the update
--   process for the specified entity. The role of this process is
--   to update a fully validated row for the HR schema passing back
--   to the calling process, any system generated values (e.g.
--   object version number attribute). This process is the main
--   backbone of the upd business process. The processing of this
--   procedure is as follows:
--   1) If the p_validate parameter has been set to true then a savepoint
--      is issued.
--   2) The row to be updated is then locked and selected into the record
--      structure g_old_rec.
--   3) Because on update parameters which are not part of the update do not
--      have to be defaulted, we need to build up the updated row by
--      converting any system defaulted parameters to their corresponding
--      value.
--   4) The controlling validation process update_validate is then executed
--      which will execute all private and public validation business rule
--      processes.
--   5) The pre_update process is then executed which enables any
--      logic to be processed before the update dml process is executed.
--   6) The update_dml process will physical perform the update dml into the
--      specified entity.
--   7) The post_update process is then executed which enables any
--      logic to be processed after the update dml process.
--   8) If the p_validate parameter has been set to true an exception is
--      raised which is handled and processed by performing a rollback to
--      the savepoint which was issued at the beginning of the upd process.
--
-- Pre Conditions:
--   The main parameters to the business process have to be in the record
--   format.
--
-- In Parameters:
--   p_validate
--     Determines if the process is to be validated. Setting this
--     boolean value to true will invoke the process to be validated. The
--     default is false. The validation is controlled by a savepoint and
--     rollback mechanism. The savepoint is issued at the beginning of the
--     process and is rollbacked at the end of the process
--     when all the processing has been completed. The rollback is controlled
--     by raising and handling the exception hr_api.validate_enabled. We use
--     the exception because, by raising the exception with the
--     process, we can exit successfully without having any of the 'OUT'
--     parameters being set.
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
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure upd
  (
  p_rec        in out NOCOPY ghr_prh_shd.g_rec_type,
  p_validate   in     boolean default false
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is the attribute interface for the update
--   process for the specified entity and is the outermost layer. The role
--   of this process is to update a fully validated row into the HR schema
--   passing back to the calling process, any system generated values
--   (e.g. object version number attributes). The processing of this
--   procedure is as follows:
--   1) The attributes are converted into a local record structure by
--      calling the convert_defs function.
--   2) After the conversion has taken place, the corresponding record upd
--      interface process is executed.
--   3) OUT parameters are then set to their corresponding record attributes.
--
-- Pre Conditions:
--
-- In Parameters:
--   p_validate
--     Determines if the process is to be validated. Setting this
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
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure upd
  (
  p_pa_routing_history_id        in number,
  p_attachment_modified_flag     in varchar2         default hr_api.g_varchar2,
  p_initiator_flag               in varchar2         default hr_api.g_varchar2,
  p_approver_flag                in varchar2         default hr_api.g_varchar2,
  p_reviewer_flag                in varchar2         default hr_api.g_varchar2,
  p_requester_flag               in varchar2         default hr_api.g_varchar2,
  p_authorizer_flag              in varchar2         default hr_api.g_varchar2,
  p_personnelist_flag            in varchar2         default hr_api.g_varchar2,
  p_approved_flag                in varchar2         default hr_api.g_varchar2,
  p_user_name                    in varchar2         default hr_api.g_varchar2,
  p_user_name_employee_id        in number           default hr_api.g_number,
  p_user_name_emp_first_name     in varchar2         default hr_api.g_varchar2,
  p_user_name_emp_last_name      in varchar2         default hr_api.g_varchar2,
  p_user_name_emp_middle_names   in varchar2         default hr_api.g_varchar2,
  p_notepad				   in varchar2         default hr_api.g_varchar2,
  p_action_taken                 in varchar2         default hr_api.g_varchar2,
  p_groupbox_id                  in number           default hr_api.g_number,
  p_noa_family_code              in varchar2         default hr_api.g_varchar2,
  p_nature_of_action_id          in number           default hr_api.g_number,
  p_second_nature_of_action_id   in number           default hr_api.g_number,
  p_approval_status              in varchar2         default hr_api.g_varchar2,
  p_date_notification_sent       in date             default hr_api.g_date,
  p_object_version_number        in out NOCOPY number,
  p_validate                     in boolean      default false
  );
--
end ghr_prh_upd;

 

/
