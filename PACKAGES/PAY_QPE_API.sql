--------------------------------------------------------
--  DDL for Package PAY_QPE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_QPE_API" AUTHID CURRENT_USER as
/* $Header: pyqperhi.pkh 115.1 2004/01/13 01:09 swinton noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< lck >----------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   The Lck process has two main functions to perform. Firstly, the row to be
--   deleted must be locked. The locking of the row will only be
--   successful if the row is not currently locked by another user.
--   Secondly, during the locking of the row, the row is selected into
--   the g_old_rec data structure which enables the current row values from the
--   server to be available to the api.
--
-- Pre Conditions:
--   None.
--
-- In Arguments:
--   The arguments to the Lck process are the primary key(s) which uniquely
--   identify the row (element_entry_id and assignment_action_id).
--
-- Post Success:
--   On successful completion of the Lck process the row to be updated or
--   deleted will be locked and selected into the global data structure
--   g_old_rec.
--
-- Post Failure:
--   The Lck process can fail for two reasons:
--   1) When attempting to lock the row the row could already be locked by
--      another user. This will raise the error HR_7165_OBJECT_LOCKED.
--   2) The row which is required to be locked doesn't exist in the HR Schema.
--      This error is trapped and reported using the message name
--      'HR_7220_INVALID_PRIMARY_KEY'.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
PROCEDURE lck
  (p_element_entry_id     IN NUMBER
  ,p_assignment_action_id IN NUMBER
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is the record interface for the insert business process
--   for the PAY_QUICKPAY_EXCLUSIONS entity. The role of this process is to
--   insert a fully validated row, into the HR schema.
--   1) If the p_validate argument has been set to true then a savepoint is
--      issued.
--   2) The controlling validation process insert_validate is then executed
--      which will execute all private and public validation business rule
--      processes.
--   3) The insert_dml process will physical perform the insert dml into the
--      specified entity.
--   4) If the p_validate argument has been set to true an exception is raised
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
--   An insert will be disallowed if any of the following conditions are
--   found:
--     1) An Assignment Process with an id of p_rec.assignment_action_id does
--        not exist.
--     2) The Assignment Process does exist but it is not for a 'QuickPay Run'
--        Payroll Process.
--     3) The Assignment Process has a status of complete and a run result
--        exists for the element entry/assignment action id being excluded.
--     4) The Payroll Process current_task is not null.
--     5) No Element Entry exists with an id of p_rec.element_entry_id.
--     6) The entry is not for the assignment defined on the QuickPay Run
--        definition.
--     7) The element entry does not exist as of the QuickPay date earned.
--     8) A QuickPay Exclusion for this Assignment Process and Element Entry
--        already exists.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
PROCEDURE ins
  (p_rec       IN OUT NOCOPY pay_quickpay_exclusions%ROWTYPE
  ,p_validate  IN BOOLEAN DEFAULT FALSE
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is the attribute interface for the insert business
--   process for QuickPay Exclusions and is the outermost layer. The role
--   of this process is to insert a fully validated row into the HR schema.
--   The processing of this procedure is as follows:
--   1) The attributes are converted into a local record structure by
--      calling an internal convert_args function.
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
--   A fully validated row will be inserted for QuickPay Exclusions
--   without being committed (or rolled back, depending on the p_validate
--   status).
--
-- Post Failure:
--   If an error has occurred, an error message will be supplied with the work
--   rolled back. For full details of the error conditions refer to the
--   'ins' record interface.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
PROCEDURE ins
  (p_element_entry_id      IN NUMBER
  ,p_assignment_action_id  IN NUMBER
  ,p_validate              IN BOOLEAN   DEFAULT FALSE
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< del >----------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is the record interface for the delete business process
--   for QuickPay Exclusions. The role of this process is to delete the
--   row from the HR schema. This process is the main backbone of the del
--   business process. The processing of this procedure is as follows:
--   1) If the p_validate argument has been set to true then a savepoint is
--      issued.
--   2) The controlling validation process delete_validate is then executed
--      which will execute all private and public validation business rule
--      processes.
--   3) The pre_delete business process is then executed which enables any
--      logic to be processed before the delete dml process is executed.
--   4) The delete_dml process will physical perform the delete dml for the
--      specified row.
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
--
-- Post Success:
--   The specified row will be fully validated and deleted without being
--   committed. If the p_validate argument has been set to true then all the
--   work will be rolled back.
--
-- Post Failure:
--   If an error has occurred, an error message will be supplied with the work
--   rolled back.
--   A delete will be disallowed if any of the following conditions are
--   found:
--     1) The corresponding Payroll Process has a current_task which is
--        not null.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
PROCEDURE del
  (p_rec        IN pay_quickpay_exclusions%ROWTYPE
  ,p_validate   IN BOOLEAN DEFAULT FALSE
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< del >----------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is the attribute interface for the delete business
--   process for QuickPay Exclusions and is the outermost layer. The role
--   of this process is to validate and delete the specified row from the
--   HR schema. The processing of this procedure is as follows:
--   1) The attributes are converted into a local record structure by
--      explicitly coding the attribute arguments into the
--      pay_quickpay_exclusions%ROWTYPE datatype.
--   2) After the conversion has taken place, the corresponding record del
--      interface business process is executed.
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
--   The specified row will be fully validated and deleted for the specified
--   entity without being committed (or rolled back depending on the
--   p_validate status).
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
procedure del
  (p_element_entry_id      in number
  ,p_assignment_action_id  in number
  ,p_validate              in boolean default false
  );
end pay_qpe_api;

 

/
