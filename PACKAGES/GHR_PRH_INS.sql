--------------------------------------------------------
--  DDL for Package GHR_PRH_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_PRH_INS" AUTHID CURRENT_USER as
/* $Header: ghprhrhi.pkh 120.1.12000000.1 2007/01/18 14:09:34 appldev noship $ */

--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is the record interface for the insert process
--   for the specified entity. The role of this process is to insert a fully
--   validated row, into the HR schema passing back to  the calling process,
--   any system generated values (e.g. primary and object version number
--   attributes). This process is the main backbone of the ins
--   process. The processing of this procedure is as follows:
--   1) If the p_validate parameter has been set to true then a savepoint is
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
--   6) If the p_validate parameter has been set to true an exception is
--      raised which is handled and processed by performing a rollback to the
--      savepoint which was issued at the beginning of the Ins process.
--
-- Pre Conditions:
--   The main parameters to the this process have to be in the record
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
--     the exception because, by raising the exception with the business
--     process, we can exit successfully without having any of the 'OUT'
--     parameters being set.
--
-- Post Success:
--   A fully validated row will be inserted into the specified entity
--   without being committed. If the p_validate parameter has been set to true
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
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure ins
  (
  p_rec        in out NOCOPY ghr_prh_shd.g_rec_type,
  p_validate   in     boolean default false
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is the attribute interface for the insert
--   process for the specified entity and is the outermost layer. The role
--   of this process is to insert a fully validated row into the HR schema
--   passing back to the calling process, any system generated values
--   (e.g. object version number attributes).The processing of this
--   procedure is as follows:
--   1) The attributes are converted into a local record structure by
--      calling the convert_args function.
--   2) After the conversion has taken place, the corresponding record ins
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
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure ins
  (
  p_pa_routing_history_id        out NOCOPY number,
  p_pa_request_id                in number,
  p_attachment_modified_flag     in varchar2         default null,
  p_initiator_flag               in varchar2         default null,
  p_approver_flag                in varchar2         default null,
  p_reviewer_flag                in varchar2         default null,
  p_requester_flag               in varchar2         default null,
  p_authorizer_flag              in varchar2         default null,
  p_personnelist_flag            in varchar2         default null,
  p_approved_flag                in varchar2         default null,
  p_user_name                    in varchar2         default null,
  p_user_name_employee_id        in number           default null,
  p_user_name_emp_first_name     in varchar2         default null,
  p_user_name_emp_last_name      in varchar2         default null,
  p_user_name_emp_middle_names   in varchar2         default null,
  p_notepad                      in varchar2         default null,
  p_action_taken                 in varchar2         default null,
  p_groupbox_id                  in number           default null,
  p_routing_list_id              in number           default null,
  p_routing_seq_number           in number           default null,
  p_noa_family_code              in varchar2         default null,
  p_nature_of_action_id          in number           default null,
  p_second_nature_of_action_id   in number           default null,
  p_approval_status              in varchar2         default null,
  p_date_notification_sent       in date             default null,
  p_object_version_number        out NOCOPY number,
  p_validate                     in boolean   default false
  );
 --
end ghr_prh_ins;

 

/