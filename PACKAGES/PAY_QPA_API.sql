--------------------------------------------------------
--  DDL for Package PAY_QPA_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_QPA_API" AUTHID CURRENT_USER as
/* $Header: pyqpxrhi.pkh 115.6 2002/12/06 15:05:17 swinton noship $ */

--
-- ----------------------------------------------------------------------------
-- |                    Global Record Type Specification                      |
-- ----------------------------------------------------------------------------
--
Type g_rec_type Is Record
  (payroll_action_id         number(9)
  ,business_group_id         number(15)
  ,consolidation_set_id      number(9)
  ,org_payment_method_id     number(9)
  ,action_status             varchar2(9)    -- Increased from length 1 to 9
  ,effective_date            date
  ,comments		     long
  ,current_task		     varchar2(30)
  ,legislative_parameters    varchar2(2000)
  ,date_earned               date
  ,pay_advice_date           date
  ,pay_advice_message        varchar2(240)
  ,target_payroll_action_id  number(9)
  ,object_version_number     number
  ,report_type               varchar2(30)
  ,report_qualifier	     varchar2(30)
  ,report_category	     varchar2(30)
  ,run_type_id               number(9)
  );

--

--------------------------- qppsassact ------------------------------
/*
   NAME
      qpppassact - Insert a QuickPay Archival action.
   DESCRIPTION
      Process a QuickPay Archival assignment action.
   NOTES
      This procedure is meant to be called via the QuickPay form.
*/
procedure qppsassact
(
   p_payroll_action_id     in  number, -- of QuickPay Archival.
   p_assignment_action_id  out nocopy number,
   p_object_version_number out nocopy number
);
--
-- |---------------------------------< lck >----------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   The Lck process has two main functions to perform. Firstly, the row to be
--   updated or deleted must be locked. The locking of the row will only be
--   successful if the row is not currently locked by another user, the
--   specified object version numbers match and there is no AOL request
--   waiting or still running on the concurrent manager for this QuickPay
--   Archival. Secondly, during the locking of the row, the row is selected
--   into the g_old_rec data structure which enables the current row values
--   from the server to be available to the api.
--
-- Pre Conditions:
--   None.
--
-- In Arguments:
--   All the arguments to the Lck process are mandatory.
--   p_payroll_action_id is set to the id of the QuickPay Archival Payroll
--   Process.
--   p_p_object_version_number is set to the object_version_number for the
--   Payroll Process.
--   p_a_object_version_number is set to the object_version_number for the
--   Assignment Process.
--
-- Post Success:
--   The lock will only be successful if the payroll action is for a
--   QuickPay Archival.
--   On successful completion of the Lck process the row to be updated or
--   deleted will be locked and selected into the global data structure
--   g_old_rec.
--
-- Post Failure:
--   The Lck process can fail for four reasons:
--   1) When attempting to lock the row the row could already be locked by
--      another user. This will raise the HR_7165_OBJECT_LOCKED error.
--   2) The row which is required to be locked doesn't exist in the HR Schema.
--      This error is trapped and reported using the message name
--      'HR_7155_OBJECT_INVALID'.
--   3) The row although existing in the HR Schema has a different object
--      version number than the object version number specified.
--      This error is trapped and reported using the message name
--      'HR_7155_OBJECT_INVALID'.
--   4) An error is raised if an AOL concurrent request is waiting to run or
--      still running on the concurrent manager for this QuickPay Archival.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure lck
  (p_payroll_action_id        in number
  ,p_p_object_version_number  in number
  ,p_a_object_version_number  in number
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is the record interface for the update business
--   process for the QuickPay Archival entity. The role of this process is
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
--   rolled back. A failure will occur if any of the business rules/conditions
--   are found:
--     1) An AOL concurrent request is waiting to run or still running on the
--        concurrent manager for this QuickPay Archival.
--     2) The QuickPay Archival Payroll Process current_task is not
--        null.
--     3) If the action_status is being updated the only valid change is from
--        Complete to Mark for Retry. Any other attempted change to the
--        action_status will result in an error being raised.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure upd
  (p_rec                     in out nocopy g_rec_type
  ,p_assignment_action_id    in     number
  ,p_a_object_version_number in     number
  ,p_validate                in     boolean default false
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is the attribute interface for the update business
--   process for the QuickPay Archival entity and is the outermost layer.
--   The role of this process is to update a fully validated row into the HR
--   schema passing back to the calling process, any system generated values
--   (e.g. object version number attributes). The processing of this
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
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure upd
  (p_payroll_action_id        in     number
  ,p_assignment_action_id     in     number
  ,p_action_status            in     varchar2  default hr_api.g_varchar2
  ,p_p_object_version_number  in out nocopy number
  ,p_a_object_version_number  in     number
  ,p_validate                 in     boolean   default false
  );
--

-- ----------------------------------------------------------------------------
-- |------------------------< return_api_dml_status >-------------------------|
-- ----------------------------------------------------------------------------

-- {Start Of Comments}
--
-- Description:
--   This function will return the current g_api_dml private global
--   boolean status.
--   The g_api_dml status determines if at the time of the function
--   being executed if a dml statement (i.e. INSERT, UPDATE or DELETE)
--   is being issued from within an api.
--   If the status is TRUE then a dml statement is being issued from
--   within this entity api.
--   This function is primarily to support database triggers which
--   need to maintain the object_version_number for non-supported
--   dml statements (i.e. dml statement issued outside of the api layer).
--
-- Pre Conditions:
--   None.
--
-- In Arguments:
--   None.
--
-- Post Success:
--   Processing continues.
--   If the function returns a TRUE value then, dml is being executed from
--   within this api.
--
-- Post Failure:
--   None.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
Function return_api_dml_status Return Boolean;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is the record interface for the insert business process
--   for the Archival process. The role of this process is to
--   insert a fully validated row, into the HR schema passing back to the
--   calling process, any system generated values (e.g. primary and object
--   version number attributes). This process is the main backbone of the ins
--   business  process. The processing of this procedure is as follows:
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
--   rolled back. A failure will occur if any of the business rules/conditions
--   are found:
--   1) p_rec.target_payroll_action_id, p_rec.business_group_id or
--      p_rec.effective_date are not null.
--   2) p_rec.target_payroll_action_id does not exists in pay_payroll_actions
--      for a QuickPay Run Payroll Process.
--   3) The associated Assignment Process has a complete status.
--   4) Another QuickPay Archival process already
--      interlocks the QuickPay Run Assignment Process.
--   5) The QuickPay Archival business_group_id and date_paid
--      (effective_date) are not the same as the QuickPay Run
--      business_group_id and date_paid.
--   6) If p_rec.org_payment_method_id is not null and it does not exist in
--      pay_org_payment_methods_f of the QuickPay Run date paid.
--   7) If p_rec.org_payment_method_id is not null and does not exist in the
--      same business group as the QuickPay Archival.
--   8) If p_rec.org_payment_method_id is not null the corresponding payment
--      category must not be magnetic transfer.
--
-- {End Of Comments}
--
Procedure ins
  (p_rec                     in out nocopy g_rec_type
  ,p_assignment_action_id       out nocopy number
  ,p_a_object_version_number    out nocopy number
  ,p_validate                in     boolean default false
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is the attribute interface for the insert business
--   process for the QuickPay Archival and is the outermost layer.
--   The role of this process is to insert a fully validated row into the HR
--   schema  passing back to the calling process, any system generated values
--   (e.g. the primary key and the object version numbers).The processing of
--   this procedure is as follows:
--   1) The attributes are converted into a local record structure by
--      calling the convert_defs function.
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
--   status)
--
-- Post Failure:
--   If an error has occurred, an error message will be supplied with the work
--   rolled back
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
Procedure ins
  (p_business_group_id         in     number
  ,p_org_payment_method_id     in     number    default null
  ,p_effective_date            in     date
  ,p_target_payroll_action_id  in     number    default null
  ,p_legislative_parameters    in     varchar2
  ,p_report_type               in     varchar2
  ,p_report_qualifier          in     varchar2
  ,p_report_category           in     varchar2
  ,p_payroll_action_id            out nocopy number
  ,p_action_status                out nocopy varchar2
  ,p_p_object_version_number      out nocopy number
  ,p_assignment_action_id         out nocopy number
  ,p_a_object_version_number      out nocopy number
  ,p_validate                  in     boolean   default false
  );
--

--

end pay_qpa_api;

 

/
