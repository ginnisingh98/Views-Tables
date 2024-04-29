--------------------------------------------------------
--  DDL for Package PAY_QPQ_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_QPQ_API" AUTHID CURRENT_USER as
/* $Header: pyqpqrhi.pkh 120.0.12010000.2 2010/02/15 09:33:37 phattarg ship $ */
--
-- ----------------------------------------------------------------------------
-- |                    Global Record Type Specification                      |
-- ----------------------------------------------------------------------------
--
Type g_rec_type Is Record
  (payroll_action_id          number(9)
  ,business_group_id          number(15)
  ,consolidation_set_id       number(9)
  ,action_status              varchar2(9)    -- Increased from length 1 to 9
  ,effective_date             date
  ,comments                   varchar2(2000)
  ,current_task               varchar2(30)
  ,legislative_parameters     varchar2(240)
  ,run_type_id                number(9)
  ,date_earned                date
  ,pay_advice_date            date
  ,pay_advice_message         varchar2(240)
  ,object_version_number      number(9)
  );
--
--
-- ----------------------------------------------------------------------------
-- |---------------------------< use_qpay_excl_model >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Determines whether the new QuickPay Exclusions model is available for
--   use.
--
-- Pre Conditions:
--   None.
--
-- In Arguments:
--   None.
--
-- Post Success:
--   The function returns 'Y' if the new QuickPay Exclusions model is
--   available for use, and 'N' if the obsolete QuickPay Inclusions model is
--   still being used.
--
-- Post Failure:
--   An exception will be raised if the QuickPay upgrade is currently being
--   processed.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
function use_qpay_excl_model return varchar2;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< chk_asg_on_payroll >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Validates that the assignment is on a payroll as of the current effective
--   date. Used to validate navigation to the QuickPay Form in a Taskflow.
--
-- Pre Conditions:
--   A row has been inserted into fnd_sessions for the current database
--   session. p_assignment_id is known to exist in the HR schema.
--
-- In Arguments:
--   p_assignment_id is set to the id of the current assignment. This is a
--   mandatory argument.
--
-- Post Success:
--   End normally if the assignment is on a payroll as of the current effective
--   date.
--
-- Post Failure:
--   An application error is raised if the assignment does not have a payroll
--   component as of the current effective date.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure chk_asg_on_payroll
  (p_assignment_id  in pay_assignment_actions.assignment_id%TYPE
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_new_eff_date >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Validates that the assignment is on a payroll as of the proposed new
--   effective date. Used to validate the new session effective date when the
--   user has called the Alter Effective Date Form from the QuickPay Form.
--
-- Pre Conditions:
--   p_assignment_id is known to exist in the HR schema.
--
-- In Arguments:
--   p_assignment_id is set to the id of the current assignment. This is a
--   mandatory argument.
--   p_new_date is the proposed new effective date.
--   (All the parameters are varchar2 because this procedure will be called
--   via the Forms4 Forms_ddl built_in.)
--
-- Post Success:
--   End normally if the assignment is on a payroll as of p_new_date.
--
-- Post Failure:
--   An application error is raised if the assignment does not exists as of
--   p_new_date, or does not have a payroll component as of p_new_date.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure chk_new_eff_date
  (p_assignment_id in varchar2
  ,p_new_date      in varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< chk_eff_date >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Validates the QuickPay Run Payroll Process effective_date. This is known
--   to the user as date paid. Checks the assignment has a payroll component
--   as of the QuickPay Run's effective_date and that a time period exists for
--   that payroll as of the same date.
--
-- Pre Conditions:
--   p_assignment_id is known to a valid assignment in the HR schema.
--
-- In Arguments:
--   p_effective_date the date paid for the QuickPay Run Payroll Process.
--   p_assignment_id the assignment to check.
--   p_legislation_code must be set to the assignment' business group
--   legislation.
--   p_recal_date_earned indicates if the default value for date_earned
--   should be re-calulated.
--
-- Post Success:
--   p_payroll_id is set to the assignment's payroll component as of
--   p_effective_date.
--   p_time_period_id and p_period_name are set from the corresponding
--   attributes of the time periods entity, for the period which exists as
--   of p_effective_date for the payroll p_payroll_id.
--   If p_effective_date is valid and p_recal_date_earned is true then
--   p_new_date_earned will be set to the recommended default value for
--   date earned. The exact value returned depends on the p_legislation_code.
--
-- Post Failure:
--   An application error message is raised if:
--      1) The assignment does not have a payroll component as of
--         p_effective_date.
--   or 2) There is no time period for the Assignment's payroll as of
--         p_effective_date.
--   If an error is raised the values of p_payroll_id, p_time_period_id and
--   p_period_name will be undefined because the end of the procedure will
--   not have been reached.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure chk_eff_date
  (p_effective_date    in     pay_payroll_actions.effective_date%TYPE
  ,p_assignment_id     in     pay_assignment_actions.assignment_id%TYPE
  ,p_legislation_code  in     per_business_groups.legislation_code%TYPE
  ,p_recal_date_earned in     boolean
  ,p_payroll_id           out nocopy pay_payroll_actions.payroll_id%TYPE
  ,p_time_period_id       out nocopy pay_payroll_actions.time_period_id%TYPE
  ,p_period_name          out nocopy per_time_periods.period_name%TYPE
  ,p_new_date_earned      out nocopy pay_payroll_actions.date_earned%TYPE
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------------< chk_date_earned >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Validates the date_earned for a QuickPay Run Payroll Process. Checks the
--   assignment has a payroll component as of date earned and that a time
--   period exists for that payroll as of date earned.
--
-- Pre Conditions:
--   p_assignment_id is known to a valid assignment in the HR schema.
--
-- In Arguments:
--   p_date_earned the date to check.
--   p_assignment_id is the assignment to check.
--   p_effective_date is mandatory when the legislation is 'GB'. When
--   validating p_date_earned for other legislations this procedure does not
--   use the p_effective_date value.
--
-- Post Success:
--   Ends normally if the assignment has payroll component as of date earned
--   and that a time period exists for that payroll as of date earned.
--   p_payroll_id is set to the assignment's payroll component as of
--   p_effective_date.
--   p_time_period_id and p_period_name are set from the corresponding
--   attributes of the time periods entity, for the period which exists as
--   of p_effective_date for the payroll p_payroll_id.
--
-- Post Failure:
--   An application error message is raised if:
--      1) The assignment does not have a payroll component as of
--         p_date_earned.
--   or 2) There is no time period for the Assignment's payroll as of
--         p_date_earned.
--   If an error is raised the values of p_payroll_id, p_time_period_id and
--   p_period_name will be undefined because the end of the procedure will
--   not have been reached.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure chk_date_earned
  (p_date_earned       in pay_payroll_actions.date_earned%TYPE
  ,p_assignment_id     in pay_assignment_actions.assignment_id%TYPE
  ,p_legislation_code  in per_business_groups.legislation_code%TYPE
  ,p_effective_date    in pay_payroll_actions.effective_date%TYPE
  ,p_payroll_id        in out nocopy pay_payroll_actions.payroll_id%TYPE
  ,p_time_period_id    in out nocopy pay_payroll_actions.time_period_id%TYPE
  ,p_period_name       in out nocopy per_time_periods.period_name%TYPE
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< chk_for_con_request >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to check that an AOL request is not waiting to run
--   or still running on concurrent manager queue.
--
-- Pre Conditions:
--   None.
--
-- In Arguments:
--   p_payroll_action_id set to the id of an existing Payroll Process.
--
-- Post Success:
--   There is no concurrent request still waiting or running on the AOL
--   concurrent manager.
--
-- Post Failure:
--   An application error is raised if there is a request still waiting or
--   running on the AOL concurrent manager.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure chk_for_con_request
  (p_payroll_action_id in pay_payroll_actions.payroll_action_id%TYPE
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
-- {End Of Comments}
--
function return_api_dml_status Return Boolean;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< lck >----------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   The Lck process has two main functions to perform. Firstly, a row to be
--   updated or deleted must be locked. The locking of the row will only be
--   successful if the row is not currently locked by another user, the
--   specified object version numbers match and there is no AOL request
--   waiting or still running on the concurrent manager for this QuickPay Run.
--   Secondly, during the locking of the row, the row is selected into the
--   g_old_rec data structure which enables the current row values from the
--   server to be available to the api.
--
-- Pre Conditions:
--   None.
--
-- In Arguments:
--   All the arguments to the Lck process are mandatory.
--   p_payroll_action_id is set to the id of the QuickPay Pre-payment Payroll
--   Process.
--   p_p_object_version_number is set to the object_version_number for the
--   Payroll Process.
--   p_a_object_version_number is set to the object_version_number for the
--   Assignment Process.
--
-- Post Success:
--   The lock will only be successful if the Payroll Process is for a
--   QuickPay Run.
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
--      still running on the concurrent manager for this QuickPay Run.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure lck
  (p_payroll_action_id        in pay_payroll_actions.payroll_action_id%TYPE
  ,p_p_object_version_number  in pay_payroll_actions.object_version_number%TYPE
  ,p_a_object_version_number  in
                             pay_assignment_actions.object_version_number%TYPE
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is the record interface insert business process
--   for the QuickPay Run entity. The role of this process is to
--   insert fully validated rows, into the HR schema passing back to the
--   calling process, any system generated values (e.g. primary and object
--   version number attributes). The processing of this procedure is as
--   follows:
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
--   The following attributes in p_rec are not for external issue. If these
--   values are set they will be overwritten: payroll_action_id,
--   action_status, current_task and object_version_number.
--   The following attributes in p_rec are mandatory: business_group_id,
--   effective_date, date_earned and consolidation_set_id.
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
--   p_rec
--     Contains the attributes of the QuickPay Run Payroll Process.
--     N.B. p_rec.effective_date is known to the end use as date paid.
--   p_assignment_id
--     Is set to the assignment the QuickPay Run Assignment Process is to be
--     created for. This is a mandatory argument.
--
-- Post Success:
--   Fully validated rows will be inserted for a QuickPay Run Payroll
--   Process, QuickPay Run Assignment Process and QuickPay Inclusions without
--   being committed. If the p_validate argument has been set to true
--   then all the work will be rolled back.
--   p_rec
--     The primary key and object version number details for the inserted
--     QuickPay Run Payroll Process will be returned in p_rec.
--   p_assignment_action_id
--     will be set to the primary key value of the inserted QuickPay Run
--     Assignment Process.
--   p_a_object_version_number
--     will be set to the object version number of the inserted QuickPay Run
--     Assignment Process.
--
-- Post Failure:
--   If an error has occurred, an error message will be supplied with the work
--   rolled back. A failure will occur if any of the following conditions are
--   found:
--     1) All of the mandatory arguments have not been set.
--     2) The p_rec.business_group_id business group does not exist.
--     3) The assignment does not exist in the QuickPay Run business_group_id
--        as of p_rec.effective_date.
--     4) A consolidation_set does not exist with an id of
--        p_rec.consolidation_set_id.
--     5) The p_rec.consolidation_set_id does exist but it is not in the same
--        business group as the QuickPay Run.
--     6) The assignment does not have a payroll component as of
--        p_rec.effective_date or p_rec.date_earned.
--     7) There is no time period for the Assignment's payroll as of
--        p_rec.effective_date or p_rec.date_earned.
--     8) The assignment does not exist on the same payroll as of
--        p_rec.date_earned and p_rec.effective_date.
--     9) If the business group is for a US legislation and
--        p_rec.legislative_parameters is not set to ('R' or 'S') then an error
--        will be raised. For any non-US legislation and
--        p_rec.legislative_parameters is not null then an error is raised.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure ins
  (p_rec                     in out nocopy g_rec_type
  ,p_assignment_id           in     number
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
--   This procedure is the attribute interface for the QuickPay Pre-payment
--   insert business. It is the outermost layer. The role of this process is
--   to insert fully validated rows into the HR schema passing back to the
--   calling process, any system generated values (e.g. the primary key and
--   the object version numbers).The processing of this procedure is as
--   follows:
--     1) The attributes are converted into a local record structure by
--        calling the convert_defs function.
--     2) After the conversion has taken place, the corresponding record ins
--        interface business process is executed.
--     3) OUT arguments are then set to their corresponding record arguments.
--
-- Pre Conditions:
--   None.
--
-- In Arguments:
--   p_validate
--     Determines if the business process is to be validated. Setting this
--     Boolean value to true will invoke the process to be validated.
--     The default is false.
--
-- Post Success:
--   Fully validated rows will be inserted for a QuickPay Run Payroll
--   Process, QuickPay Run Assignment Process and QuickPay Inclusions without
--   being committed. If the p_validate argument has been set to true
--   then all the work will be rolled back.
--   p_payroll_action_id
--     will be set to the primary key value of the inserted
--     QuickPay Run Payroll Process.
--   p_p_object_version_number
--     will be set to the object version number of the inserted QuickPay Run
--     Process.
--   p_assignment_action_id
--     will be set to the primary key value of the inserted QuickPay Run
--     Assignment Process.
--   p_a_object_version_number
--     will be set to the object version number of the inserted QuickPay Run
--     Assignment Process.
--
-- Post Failure:
--   If an error has occurred, an error message will be supplied with the work
--   rolled back. Refer to the ins record interface for details of possible
--   failures.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure ins
  (p_business_group_id       in     number
  ,p_assignment_id           in     number
  ,p_consolidation_set_id    in     number
  ,p_effective_date          in     date
  ,p_legislative_parameters  in     varchar2  default null
  ,p_run_type_id             in     number    default null
  ,p_date_earned             in     date
  ,p_pay_advice_date         in     date      default null
  ,p_pay_advice_message      in     varchar2  default null
  ,p_comments                in     varchar2  default null
  ,p_payroll_action_id          out nocopy number
  ,p_p_object_version_number    out nocopy number
  ,p_assignment_action_id       out nocopy number
  ,p_a_object_version_number    out nocopy number
  ,p_validate                in     boolean   default false
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is the record interface for the QuickPay Pre-payment
--   update business process. The role of this process is to update a fully
--   validated row for the HR schema passing back to the calling process, any
--   system generated values (e.g. object version number attribute). This
--   process is the main backbone of the upd business process. The processing
--   of this procedure is as follows:
--   1) If the p_validate argument has been set to true then a savepoint
--      is issued.
--   2) The row to be updated is then locked and selected into the record
--      structure g_old_rec.
--   3) Because on update arguments which are not part of the update do not
--      have to be defaulted, we need to build up the updated row by
--      converting any system defaulted arguments to their corresponding
--      database value.
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
--   None.
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
--   p_assignment_action_id
--     Set to the id of the associated QuickPay Run Assignment Process.
--   p_a_object_version_number
--     Set to the object version number of the associated QuickPay Run
--     Assignment Process.
--
-- Post Success:
--   The specified row will be fully validated and updated without being
--   committed. If the p_validate argument has been set to true then all the
--   work will be rolled back.
--   p_rec.object_version_number will be set with the new object_version_number
--   for the QuickPay Run Payroll Process.
--
-- Post Failure:
--   If an error has occurred, an error message will be supplied with the work
--   rolled back. A failure will occur if any of the business rules/conditions
--   are found:
--     1) An AOL concurrent request is waiting to run or still running on the
--        concurrent manager for this QuickPay Run.
--     2) The QuickPay Run Payroll Process current_task is not null.
--     3) If the action_status is being updated the only valid change is from
--        'C' (Complete) to 'M' (Mark for Retry). Any other attempted change
--        to the action_status will result in an error being raised.
--     4) Regardless of the action_status value, the caller has attempted to
--        update one of the non updateable attributes. (business_group_id,
--        effective_date, current_task, date_earned).
--     5) A consolidation_set does not exist with an id of
--        p_rec.consolidation_set_id.
--     6) The p_rec.consolidation_set_id does exist but it is not in the same
--        business group as the QuickPay Run.
--     7) The QuickPay Run business group is for a US legislation and
--        legislative_parameters is not set to 'R' or 'S'.
--     8) The business group is for a US legislation and the caller
--        has attempted to update legislation_parameters when the action status
--        is Complete.
--     9) The business group is for any non-US legislation and
--        p_legislative_parameters is not null.
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
--   This procedure is the attribute interface for the QuickPay Run update
--   business process.
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
--   None.
--
-- In Arguments:
--   p_validate
--     Determines if the business process is to be validated. Setting this
--     Boolean value to true will invoke the process to be validated.
--     The default is false.
--
-- Post Success:
--   The specified row will be fully validated and updated without being
--   committed. If the p_validate argument has been set to true then all the
--   work will be rolled back.
--   p_p_object_version_number will be set with the new object_version_number
--   for the QuickPay Run Payroll Process.
--
-- Post Failure:
--   If an error has occurred, an error message will be supplied with the work
--   rolled back. Refer to the upd record interface for details of possible
--   failures.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure upd
  (p_payroll_action_id       in     number
  ,p_consolidation_set_id    in     number   default hr_api.g_number
  ,p_legislative_parameters  in     varchar2 default hr_api.g_varchar2
  ,p_run_type_id             in     number   default hr_api.g_number
  ,p_pay_advice_date         in     date     default hr_api.g_date
  ,p_pay_advice_message      in     varchar2 default hr_api.g_varchar2
  ,p_action_status           in     varchar2 default hr_api.g_varchar2
  ,p_comments                in     varchar2 default hr_api.g_varchar2
  ,p_assignment_action_id    in     number
  ,p_p_object_version_number in out nocopy number
  ,p_a_object_version_number in     number
  ,p_validate                in     boolean  default false
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< del >----------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is the record interface for the delete business process
--   for the QuickPay Run entity. The role of this process is to
--   delete a QuickPay Run definition from the HR schema. This process is the
--   main backbone of the del business process. The processing of this
--   procedure is as follows:
--   1) If the p_validate argument has been set to true then a savepoint is
--      issued.
--   2) The controlling validation process delete_validate is then executed
--      which will execute all private and public validation business rule
--      processes.
--   3) The pre_delete business process is then executed which enables any
--      logic to be processed before the delete dml process is executed.
--   4) The delete_dml process will physical perform the delete dml for the
--      specified rows.
--   5) The post_delete business process is then executed which enables any
--      logic to be processed after the delete dml process.
--   6) If the p_validate argument has been set to true an exception is raised
--      which is handled and processed by performing a rollback to the
--      savepoint which was issued at the beginning of the del process.
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
--   p_rec
--     The only components which must be set in the record structure are
--     the primary key (p_rec.payroll_action_id) and the Payroll Process
--     object version number (p_rec.object_version_number).
--   p_a_object_version_number
--     Must be set to the current object version number for the QuickPay Run
--     Assignment Process.
--   If the Payroll or Assignment Process object version number does not
--   match the current value in the database the deletion of the whole
--   QuickPay Run definition will not be allowed.
--
-- Post Success:
--   The specified QuickPay Run will be fully validated and deleted without
--   being committed. If the p_validate argument has been set to true then all
--   the work will be rolled back.
--
-- Post Failure:
--   If an error has occurred, an error message will be supplied with the work
--   rolled back. A failure will occur if any of the business rules/conditions
--   are found:
--     1) An AOL concurrent request is waiting to run or still running on the
--        concurrent manager for this QuickPay Run.
--     2) The QuickPay Run Payroll Process current_task is not null.
--     3) The Payroll or Assignment Process object version numbers do not
--        match the current values in the database.
--     4) There is another Assignment Process locking the QuickPay Run
--        Assignment Process which has not been marked for retry.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure del
  (p_rec                      in g_rec_type
  ,p_a_object_version_number  in number
  ,p_validate                 in boolean default false
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< del >----------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is the attribute interface for the delete business
--   process for the QuickPay Run entity and is the outermost layer.
--   The role of this process is to validate and delete the specified rows
--   from the HR schema. The processing of this procedure is as follows:
--   1) The attributes are converted into a local record structure by
--      explicitly coding the attribute arguments into the g_rec_type
--      datatype.
--   2) After the conversion has taken place, the corresponding record del
--      interface business process is executed.
--
-- Pre Conditions:
--
-- In Arguments:
--   p_payroll_action_id
--     Set the primary key of the QuickPay Run Payroll Process.
--   p_p_object_version_number
--     Set the current object version number of the QuickPay Run Payroll
--     Process.
--   p_a_object_version_number
--     Set to the current object version number of the QuickPay Run Assignment
--     Process.
--   p_validate
--     Determines if the business process is to be validated. Setting this
--     Boolean value to true will invoke the process to be validated.
--     The default is false.
--
-- Post Success:
--   The specified row will be fully validated and deleted for the specified
--   entity without being committed (or rollbacked depending on the
--   p_validate status).
--
-- Post Failure:
--   If an error has occurred, an error message will be supplied with the work
--   rolled back. Refer to the del record interface for details of possible
--   failures.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
Procedure del
  (p_payroll_action_id        in number
  ,p_p_object_version_number  in number
  ,p_a_object_version_number  in number
  ,p_validate                 in boolean default false
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------------< default_values >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure returns the QuickPay Run default values which are provided
--   on the Form. It also returns various translatable prompts which are
--   used by the Form.
--
-- Pre Conditions:
--   This procedure assumes the following is true:
--     1) p_assignment_id is an assignment which exists in the HR schema.
--     2) The assignment exists in the same business group as the current
--        Forms session.
--     3) The assignment has a not null payroll components as of the
--        current effective date or as of trunc(sysdate).
--
-- In Arguments:
--   p_assignment_id
--     Is set to the id of the assignment, as in the current Taskflow context.
--
-- Post Success:
--   The values for some of the out arguments depends on the assignment's
--   business group legislation.
--   p_df_effective_date, p_df_date_earned and p_period_name will be null if
--   no time period exists for the assignment's payroll, as of the Forms
--   session effective date. If there is no row in fnd_sessions for this
--   database session, trunc(sysdate) will be used to find a matching time
--   period.
--   If a time period definition does exist the date values depend on the
--   assignment's business group legislation:
--   For 'GB' legislation:
--     p_df_effective_date
--       The regular payment date for the matching period.
--     p_df_date_earned
--       The earliest of the following dates will be used:
--         1) The end date of the matching time period.
--         2) The final date for which the assignment is on this payroll.
--            (This will always be less than or equal to the end date of
--            the assignment.)
--            If for some reason the assignment has transferred from the
--            current payroll more than once in this period, the first
--            leaving date will be taken.
--
--   For all other legislations (not 'GB'):
--     p_df_effective_date
--       Set to the current Forms session effective date. If there is no
--       corresponding row in fnd_sessions for this database session, this
--       argument will be set to trunc(sysdate).
--     p_df_date_earned
--       Set to the ame value as p_df_effective_date.
--
--   The following attributes are always set with the stated values,
--   regardless of the business group's legislation:
--     p_period_name
--       If the assignment's payroll has a time period definition which spans
--       the effective date (p_eff_date), this argument will be set to the
--       users period name for that period. If there is no matching time period
--       this argument will be null.
--     p_consolidation_set_id
--       Set to the id of the default consolidation set for the assignment's
--       payroll as of the effective_date.
--     p_consolidation_set_name
--       Set to the user name description corresponding to
--       p_consolidation_set_id.
--     p_unprocessed_status
--       Set to the user description for an Unprocessed assignment process.
--     p_mark_for_retry_status
--       Set to the user description for a Marked for retry assignment process.
--     p_complete_status
--       Set to the user description for a Completed assignment process.
--     p_in_error_status
--       Set to the user description for an In error assignment process.
--     p_start_run_prompt
--       Set to the user button prompt for starting a QuickPay Run which has
--       a status of Unprocessed.
--     p_start_pre_prompt
--       Set to the user button prompt for starting a QuickPay Pre-payment
--       which has a status of Unprocessed.
--     p_retry_run_prompt
--       Set to the user button prompt for re-doing a QuickPay Run which has a
--       status of In Error, complete or Marked for Retry.
--     p_start_arc_prompt
--       Set to the user button prompt for starting a QuickPay Archival
--       which has a status of Unprocessed.
--     p_retry_arc_prompt
--       Set to the user button prompt for re-doing a QuickPay Archival which has a
--       status of In Error, complete or Marked for Retry.
--     p_qp_run_user_name
--       Set to the user description of a QuickPay Run Payroll Process.
--
-- Post Failure:
--   An error will be raised if any of the status or button prompts can be
--   found.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
Procedure default_values
  (p_assignment_id          in     pay_assignment_actions.assignment_id%TYPE
  ,p_df_effective_date         out nocopy pay_payroll_actions.
                                                  effective_date%TYPE
  ,p_df_date_earned            out nocopy pay_payroll_actions.date_earned%TYPE
  ,p_period_name               out nocopy per_time_periods.period_name%TYPE
  ,p_consolidation_set_id      out nocopy pay_consolidation_sets.
                                                  consolidation_set_id%TYPE
  ,p_consolidation_set_name    out nocopy pay_consolidation_sets.
                                                  consolidation_set_name%TYPE
  ,p_unprocessed_status        out nocopy varchar2
  ,p_mark_for_retry_status     out nocopy varchar2
  ,p_complete_status           out nocopy varchar2
  ,p_in_error_status           out nocopy varchar2
  ,p_start_run_prompt          out nocopy varchar2
  ,p_start_pre_prompt          out nocopy varchar2
  ,p_retry_run_prompt          out nocopy varchar2
  ,p_rerun_pre_prompt          out nocopy varchar2
  ,p_start_arc_prompt          out nocopy varchar2
  ,p_retry_arc_prompt          out nocopy varchar2
  ,p_qp_run_user_name          out nocopy varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |--------------------------< start_quickpay_process >----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
--   Submits a QuickPay Run or QuickPay Pre-payment process to the AOL
--   concurrent manager. The type of process is worked out internally. It
--   depends on the action_type and action_status.
--
-- Pre Conditions:
--   None.
--
-- In Arguments:
--   p_payroll_action_id
--     Set to the id of a QuickPay Run or QuickPay Pre-payment Payroll Process,
--     which already exists in the database.
--   p_p_object_version_number
--     Set to the current object version number for the Payroll Process.
--   p_a_object_version_number
--     Set to the current object version number for the Assignment Process.
--   All the arguments are mandatory.
--
-- Post Success:
--   An AOL process request was successfully submitted to the concurrent
--   manager and the request_id was updated on the pay_payroll_actions table.
--   If this procedure call is successful the caller code must issue a commit.
--   This must be done otherwise the concurrent manager will not start the
--   request running.
--
-- Post Failure:
--   An error will be raised if:
--     1) A QuickPay Run or QuickPay Pre-payment Payroll Process could not be
--        found in the database with an id of p_payroll_action_id.
--     2) The Payroll or Assignment Process object version numbers do not
--        match the current values in the database.
--     3) An AOL concurrent request is waiting to run or still running on the
--        concurrent manager for this QuickPay Run or QuickPay Pre-payment.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
procedure start_quickpay_process
  (p_payroll_action_id       in pay_payroll_actions.payroll_action_id%TYPE
  ,p_p_object_version_number in pay_payroll_actions.object_version_number%TYPE
  ,p_a_object_version_number in pay_assignment_actions.object_version_number%TYPE
  ,p_status                  in out nocopy varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |--------------------------< wait_quickpay_process >-----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
--   Waits for the QuickPay Run or QuickPay Pre-payment process to finish
--   running on the AOL concurrent manager. If the maximum wait time is
--   reached, this procedure will end successfully before the process has
--   finished.
--
-- Pre Conditions:
--   A call to start_quickpay_process has been done and a commit has been
--   issued.
--
-- In Arguments:
--   p_payroll_action_id
--     Is the id of a QuickPay Run or QuickPay Pre-payment Payroll Process.
--     This is a mandatory argument.
--
-- Post Success:
--   p_display_run_number
--     Set to Payroll Process display_run_number attribute.
--   p_a_action_status
--     Set to current Assignment Process action_status attribute.
--   p_process_info
--     Set to 'PROCESS_NOT_STARTED', 'PROCESS_RUNNING' or 'PROCESS_FINISHED'.
--   p_request_id
--     Set to the AOL concurrent request this procedure has been waiting to
--     finish.
--
-- Post Failure:
--   An error will be raised if a payroll_action does not exist with an id
--   of p_payroll_action_id.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure wait_quickpay_process
  (p_payroll_action_id  in     pay_payroll_actions.payroll_action_id%TYPE
  ,p_display_run_number    out nocopy pay_payroll_actions.
                                                 display_run_number%TYPE
  ,p_a_action_status       out nocopy pay_assignment_actions.action_status%TYPE
  ,p_process_info          out nocopy varchar2
  ,p_request_id            out nocopy pay_payroll_actions.request_id%TYPE
  );
--

end pay_qpq_api;

/
