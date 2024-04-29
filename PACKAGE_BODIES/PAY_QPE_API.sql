--------------------------------------------------------
--  DDL for Package Body PAY_QPE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_QPE_API" as
/* $Header: pyqperhi.pkb 115.2 2004/04/22 07:16 swinton noship $ */
--
-- Current record structure definition
--
g_old_rec  pay_quickpay_exclusions%ROWTYPE;
--
-- Global package name
--
g_package  varchar2(30) := '  pay_qpe_api.';
--
-- ----------------------------------------------------------------------------
-- |-------------------------< validate_asg_act_id >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Checks the assignment_action_id is valid. To be used in insert
--   validation.
--
-- Pre Conditions:
--   None.
--
-- In Arguments:
--   p_assignment_action_id is the id to validate. This is a mandatory
--   argument.
--
-- Post Success:
--   Ends successfully if a matching assignment_action_id exists in
--   pay_assignment_actions and it is for a QuickPay Run process.
--
-- Post Failure:
--   Raises an error if at least one of the following is true:
--     1) An Assignment Process with an id of p_assignment_action_id does
--        not exist.
--     2) The Assignment Process does exist but it is not for a 'QuickPay Run'
--        Payroll Process.
--
-- Access Status:
--   Private to this package.
--
-- {End Of Comments}
--
procedure validate_asg_act_id
  (p_assignment_action_id in pay_assignment_actions.assignment_action_id%TYPE
  ) is
  --
  v_exists  varchar2(1);
  v_proc    varchar2(72) := g_package||'validate_asg_act_id';
  --
  cursor sel_exists is
    select 'Y'
      from pay_assignment_actions
     where assignment_action_id = p_assignment_action_id;
  --
  cursor sel_for_qpr is
    select 'Y'
      from pay_payroll_actions     pya
         , pay_assignment_actions  asa
     where pya.action_type          = 'Q'
       and pya.payroll_action_id    = asa.payroll_action_id
       and asa.assignment_action_id = p_assignment_action_id;
begin
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => v_proc
    ,p_argument       => 'assignment_action_id'
    ,p_argument_value => p_assignment_action_id
    );
  --
  -- Check the assignment action exists
  --
  Open sel_exists;
  fetch sel_exists into v_exists;
  if sel_exists%notfound then
    close sel_exists;
    -- Error: You have tried to exclude an element entry in QuickPay for an
    -- assignment process that does not exist. The p_rec.assignment_action_id
    -- (or p_assignment_action_id) argument has been set to an incorrect value.
    hr_utility.set_message(801, 'PAY_33738_QPAY_NO_ASG_ACT');
    hr_utility.raise_error;
  end if;
  close sel_exists;
  hr_utility.set_location(v_proc, 6);
  --
  -- Check the assignment action is for a 'QuickPay Run' payroll action
  --
  Open sel_for_qpr;
  fetch sel_for_qpr into v_exists;
  if sel_for_qpr%notfound then
    close sel_for_qpr;
    -- Error: You have tried to exclude an element entry in QuickPay for an
    -- invalid type of payroll process. The payroll process corresponding to
    -- the assignment process (p_rec.assignment_action_id) must be of the type
    -- QuickPay Run.
    hr_utility.set_message(801, 'PAY_33696_QPAY_NOT_ACT_QP');
    hr_utility.raise_error;
  end if;
  close sel_for_qpr;
  hr_utility.set_location(' Leaving:'|| v_proc, 10);
end validate_asg_act_id;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< validate_ele_ent_id >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Checks the element_entry_id is validate. Used in insert validation.
--
-- Pre Conditions:
--   None.
--
-- In Arguments:
--   p_rec is the QuickPay Exclusion record which contains the element entry
--   to check.
--
-- Post Success:
--   End successfully if it is valid to include the element entry for this
--   QuickPay Run assignment process.
--
-- Post Failure:
--   Raises an error if at least one of the following is true:
--     1) No element entry exists with an id of p_rec.element_entry_id.
--     2) The element entry does not exist as of the QuickPay Run date_earned.
--     3) The element entry is not for the assignment as defined on the
--        Assignment Action.
--     4) A run result exists for the element entry id/assignment action id
--
-- Access Status:
--   Private to this package.
--
-- {End Of Comments}
--
procedure validate_ele_ent_id
  (p_rec in pay_quickpay_exclusions%ROWTYPE
  ) is
  --
  v_exists       varchar2(1);
  v_date_earned  pay_payroll_actions.date_earned%TYPE;
  v_proc         varchar2(72) := g_package||'validate_ele_ent_id';
  --
  cursor cur_exists is
    select 'Y'
      from dual
     where exists (select 'Y'
                     from pay_element_entries_f
                    where element_entry_id = p_rec.element_entry_id);
  --
  cursor cur_date is
    select pya.date_earned
      from
           pay_element_types_f    et
         , pay_element_links_f    el
         , pay_element_entries_f  ent
         , pay_payroll_actions    pya
         , pay_assignment_actions aga
     where ent.element_entry_id     = p_rec.element_entry_id
       and ent.effective_start_date <= pya.date_earned
       and ent.effective_end_date   >= decode(et.proration_group_id, null, pya.date_earned,
                                              pay_interpreter_pkg.prorate_start_date
                                                     (aga.assignment_action_id,
                                                      et.proration_group_id
                                                     ))
       and ent.element_link_id = el.element_link_id
       and el.element_type_id = et.element_type_id
       and pya.date_earned between el.effective_start_date
                               and el.effective_end_date
       and pya.date_earned between et.effective_start_date
                               and et.effective_end_date
       and pya.payroll_action_id    = aga.payroll_action_id
       and aga.assignment_action_id = p_rec.assignment_action_id;
  --
  cursor cur_same is
    select 'Y'
      from
           pay_element_types_f    et
         , pay_element_links_f    el
         , pay_element_entries_f  ent
         , pay_payroll_actions    pya
         , pay_assignment_actions aga
     where ent.element_entry_id     = p_rec.element_entry_id
       and ent.assignment_id        = aga.assignment_id
       and ent.effective_start_date <= pya.date_earned
       and ent.effective_end_date   >= decode(et.proration_group_id, null, pya.date_earned,
                                              pay_interpreter_pkg.prorate_start_date
                                                     (aga.assignment_action_id,
                                                      et.proration_group_id
                                                     ))
       and ent.element_link_id = el.element_link_id
       and el.element_type_id = et.element_type_id
       and pya.date_earned between el.effective_start_date
                               and el.effective_end_date
       and pya.date_earned between et.effective_start_date
                               and et.effective_end_date
       and pya.payroll_action_id    = aga.payroll_action_id
       and aga.assignment_action_id = p_rec.assignment_action_id;
  --
  cursor cur_rr_exists (
    p_assignment_action_id in number,
    p_element_entry_id in number
    ) is
    select 'Y'
    from pay_assignment_actions asgt_act,
         pay_run_results rr
    where asgt_act.assignment_action_id = rr.assignment_action_id
    and rr.source_id = p_element_entry_id
    and rr.source_type in ('E','I')
    and (asgt_act.assignment_action_id = p_assignment_action_id
         or asgt_act.source_action_id = p_assignment_action_id);
  --
begin
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  -- Check that the element entry exists with id p_element_entry_id
  --
  open cur_exists;
  fetch cur_exists into v_exists;
  if cur_exists%notfound then
    close cur_exists;
    -- Error: You have tried to exclude a non-existent element entry for
    -- QuickPay. The p_rec.element_entry_id (or element_entry_id) argument has
    -- been set to an incorrect value.
    hr_utility.set_message(801, 'PAY_34808_QPAY_NO_ELE_ENT');
    hr_utility.raise_error;
  end if;
  close cur_exists;
  hr_utility.set_location(v_proc, 6);
  --
  -- Check the element entry exists as of the QuickPay Run
  -- date_earned.
  --
  open cur_date;
  fetch cur_date into v_date_earned;
  if cur_date%notfound then
    close cur_date;
    -- Error: You have tried to exclude an element entry for QuickPay that
    -- does not exist at Date Earned. You can only exclude element entries
    -- that are date effective at this date.
    hr_utility.set_message(801, 'PAY_34637_QPAY_NO_ELE_D_EARN');
    hr_utility.raise_error;
  end if;
  close cur_date;
  hr_utility.set_location(v_proc, 7);
  --
  -- Check element entry must be for the same
  -- assignment as the assignment action
  --
  open cur_same;
  fetch cur_same into v_exists;
  if cur_same%notfound then
    close cur_same;
    -- Error: You have tried to exclude an element entry for QuickPay that is
    -- not for the same assignment as defined for the QuickPay run.
    hr_utility.set_message(801, 'PAY_34517_QPAY_ELE_NOT_ASG');
    hr_utility.raise_error;
  end if;
  close cur_same;
  hr_utility.set_location(v_proc, 8);
  hr_utility.set_location(v_proc, 9);
  hr_utility.set_location(v_proc, 10);
  --
  -- Do not allow an entry to be excluded from a QP if the QP has been
  -- processed and a run result exists for that assignment action/element entry
  -- id
  --
  open cur_rr_exists(
    p_rec.assignment_action_id,
    p_rec.element_entry_id
  );
  fetch cur_rr_exists into v_exists;
  if cur_rr_exists%found then
    -- A run result exists for this element entry/assignment action
    -- Therefore, this element entry cannot be excluded for the QuickPay
    hr_utility.set_message(801, 'PAY_33922_QPAY_EXCL_RR_EXISTS');
    hr_utility.raise_error;
  end if;
  close cur_rr_exists;
  --
  hr_utility.set_location(' Leaving:'|| v_proc, 11);
  --
end validate_ele_ent_id;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< validate_row_exists >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Validates that a Quickpay Exclusion does not exist. Used in insert
--   validation.
--
-- Pre Conditions:
--   None.
--
-- In Arguments:
--   p_rec is the QuickPay Exclusion record to check for.
--
-- Post Success:
--   This procedure ends successfully if the the QuickPay Exclusion does
--   not already exist in the pay_quickpay_exclusions table.
--
-- Post Failure:
--   Raises an error if the Quickpay Exclusion p_rec already exists in the
--   database.
--
-- Access Status:
--   Private to this package.
--
-- {End Of Comments}
--
procedure validate_row_exists
  (p_rec   in pay_quickpay_exclusions%ROWTYPE
  ) is
  --
  v_exists  varchar2(1);
  v_proc    varchar2(72) := g_package||'validate_row_exists';
  --
  cursor cur_exists is
    select 'Y'
      from pay_quickpay_exclusions
     where element_entry_id     = p_rec.element_entry_id
       and assignment_action_id = p_rec.assignment_action_id;
begin
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  -- Check that quickpay exclusion does not exist.
  --
  open cur_exists;
  fetch cur_exists into v_exists;
  if cur_exists%found then
    close cur_exists;
    -- Error: You have tried to exclude the same element entry more than once
    -- from the QuickPay run.
    hr_utility.set_message(801, 'PAY_33373_QPAY_ELE_EXCLUDED');
    hr_utility.raise_error;
  end if;
  close cur_exists;
  hr_utility.set_location(' Leaving:'|| v_proc, 10);
end validate_row_exists;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< validate_act_cmp >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Checks that the payroll action does not have a current task set to not
--   null. This procedure is used in insert and delete validation.
--
-- Pre Conditions:
--   A QuickPay Run assignment process already exists in pay_assignment_actions
--   with an id of p_assignment_action_id.
--
-- In Arguments:
--   p_assignment_action_id is the assignment_action_id on the Quickpay
--   Exclusion row.
--
-- Post Success:
--   Completes successfully if the payroll process has a null current_task.
--
-- Post Failure:
--   Raises an error if the payroll process current_task is not null.
--
-- Access Status:
--   Private to this package.
--
-- {End Of Comments}
--
procedure validate_act_cmp
  (p_assignment_action_id  in pay_assignment_actions.assignment_action_id%TYPE
  ) is
  --
  v_exists  varchar2(1);
  v_proc    varchar2(72) := g_package||'validate_act_cmp';
  --
  -- Enhancement 3368211
  -- No longer require cur_aga_act for quickpay exclusions...
  /*
  cursor cur_aga_act is
    select 'Y'
      from pay_assignment_actions
     where assignment_action_id = p_assignment_action_id
       and action_status        in  ('C', 'S');
  */
  --
  --
  cursor cur_pya_act is
    select 'Y'
      from pay_payroll_actions    pya
         , pay_assignment_actions aga
     where aga.assignment_action_id = p_assignment_action_id
       and pya.payroll_action_id    = aga.payroll_action_id
       and pya.current_task         is not null;
begin
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  -- Check that assignment_action does not have a status of Complete.
  --
  -- Enhancement 3368211
  -- Removed this check, no longer needed for quickpay exclusions...
  /*
  open cur_aga_act;
  fetch cur_aga_act into v_exists;
  if cur_aga_act%found then
    close cur_aga_act;
    -- Error: You have tried to include or exclude an element entry for a
    -- QuickPay run that has completed successfully. To do this you must
    -- change the assignment process status to Marked for Retry.
    hr_utility.set_message(801, 'HR_7239_QPAY_ELE_MARK');
    hr_utility.raise_error;
  end if;
  close cur_aga_act;
  --
  */
  hr_utility.set_location(v_proc, 6);
  --
  -- Check that payroll_action does not have
  -- current_task set to a not null value.
  --
  open cur_pya_act;
  fetch cur_pya_act into v_exists;
  if cur_pya_act%found then
    close cur_pya_act;
    -- Error: You have tried to include or exclude an element entry from a
    -- QuickPay run while the run is processing.
    hr_utility.set_message(801, 'HR_7240_QPAY_ELE_RUNNING');
    hr_utility.raise_error;
  end if;
  close cur_pya_act;
  hr_utility.set_location(' Leaving:'|| v_proc, 10);
end validate_act_cmp;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< insert_dml >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure controls the actual dml insert logic. The function of this
--   procedure is to insert the row into the schema.
--
-- Pre Conditions:
--   This is an internal private procedure which must be called from the ins
--   procedure and must have all mandatory arguments set.
--
-- In Arguments:
--   A Pl/Sql record structure.
--
-- Post Success:
--   The specified row will be inserted into the schema
--   (pay_quickpay_exclusions table).
--
-- Post Failure:
--   If an error occurs a standard Oracle error will be raised.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure insert_dml(p_rec in out nocopy pay_quickpay_exclusions%ROWTYPE) is
--
  v_proc  varchar2(72) := g_package||'insert_dml';
--
begin
  hr_utility.set_location('Entering:'||v_proc, 5);
  --
  -- Insert the row into: pay_quickpay_exclusions
  --
  insert into pay_quickpay_exclusions
    (element_entry_id
    ,assignment_action_id
    ,created_by
    ,creation_date
    ,last_update_date
    ,last_updated_by
    ,last_update_login
    )
  values
    (p_rec.element_entry_id
    ,p_rec.assignment_action_id
    ,fnd_global.user_id
    ,sysdate
    ,sysdate
    ,fnd_global.user_id
    ,fnd_global.login_id
    );
  --
  hr_utility.set_location(' Leaving:'||v_proc, 10);
end insert_dml;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< delete_dml >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure controls the actual dml delete logic. The function of this
--   procedure is to delete the specified row from the schema using the
--   primary key.
--
-- Pre Conditions:
--   This is an internal private procedure which must be called from the del
--   procedure.
--
-- In Arguments:
--   A Pl/Sql record structure.
--
-- Post Success:
--   The specified row will be delete from the schema.
--
-- Post Failure:
--   If an error occurs a standard Oracle error will be raised.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
Procedure delete_dml(p_rec in pay_quickpay_exclusions%ROWTYPE) is
--
  v_proc varchar2(72) := g_package||'delete_dml';
--
Begin
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  -- Delete the pay_quickpay_exclusions row.
  --
  delete from pay_quickpay_exclusions
   where element_entry_id     = p_rec.element_entry_id
     and assignment_action_id = p_rec.assignment_action_id;
  --
  If sql%NOTFOUND then
    --
    -- The row to be deleted was NOT found therefore a serious
    -- error has occurred which MUST be reported.
    --
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', v_proc);
    hr_utility.set_message_token('STEP','5');
    hr_utility.raise_error;
  End If;
  --
  hr_utility.set_location(' Leaving:'|| v_proc, 10);
End delete_dml;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< lck >----------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (p_element_entry_id       in number
  ,p_assignment_action_id   in number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select *
      from pay_quickpay_exclusions
     where element_entry_id     = p_element_entry_id
       and assignment_action_id = p_assignment_action_id
       for update nowait;
--
  v_proc varchar2(72) := g_package||'lck';
--
Begin
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  -- The primary key exists therefore we must now attempt to lock the
  -- row and check the object version numbers.
  --
  Open  C_Sel1;
  Fetch C_Sel1 Into g_old_rec;
  If C_Sel1%notfound then
    Close C_Sel1;
    --
    -- The primary key is invalid therefore we must error
    --
    hr_utility.set_message(801, 'HR_7220_INVALID_PRIMARY_KEY');
    hr_utility.raise_error;
  End If;
  Close C_Sel1;
--
  hr_utility.set_location(' Leaving:'|| v_proc, 10);
--
-- We need to trap the ORA LOCK exception
--
Exception
  When HR_api.Object_Locked then
    --
    -- The object is locked therefore we need to supply a meaningful
    -- error message.
    --
    hr_utility.set_message(801, 'HR_7165_OBJECT_LOCKED');
    hr_utility.set_message_token('TABLE_NAME', 'PAY_QUICKPAY_EXCLUSIONS');
    hr_utility.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This function is used to turn attribute arguments into the record
--   structure.
--
-- Pre Conditions:
--   This is a private function and can only be called from the ins or upd
--   attribute processes.
--
-- In Arguments:
--   The individual attributes of the QuickPay Exclusion. p_element_entry_id
--   and p_assignment_action_id.
--
-- Post Success:
--   A record structure will be returned of type
--   pay_quickpay_exclusions%ROWTYPE.
--
-- Post Failure:
--   No direct error handling is required within this function. Any possible
--   errors within this function will be a PL/SQL value error due to conversion
--   of datatypes or data lengths.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
function convert_args
  (p_element_entry_id      in number
  ,p_assignment_action_id  in number
  ) return pay_quickpay_exclusions%ROWTYPE is
--
  v_rec   pay_quickpay_exclusions%ROWTYPE;
  v_proc  varchar2(72) := g_package||'convert_args';
--
Begin
  --
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  -- Convert arguments into local l_rec structure.
  --
  v_rec.element_entry_id     := p_element_entry_id;
  v_rec.assignment_action_id := p_assignment_action_id;
  --
  -- Return the plsql record structure.
  --
  hr_utility.set_location(' Leaving:'|| v_proc, 10);
  Return(v_rec);
--
End convert_args;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure controls the execution of all insert business rules
--   validation.
--
-- Pre Conditions:
--   This private procedure is called from ins procedure.
--
-- In Arguments:
--   A Pl/Sql record structure.
--
-- Post Success:
--   Processing continues if no validation errors are found.
--
-- Post Failure:
--   If a business rules fails the error will not be handled by this procedure
--   unless explicitly coded.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure insert_validate(p_rec in pay_quickpay_exclusions%ROWTYPE) is
--
  v_proc varchar2(72) := g_package||'insert_validate';
--
begin
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  -- Call all supporting business operations
  --
  -- Validate that the assignment action actually exists and it
  -- is for a 'QuickPay Run' Payroll Process.
  --
  validate_asg_act_id(p_assignment_action_id => p_rec.assignment_action_id);
  hr_utility.set_location(v_proc, 6);
  --
  -- Validate that corresponding assignment action's Payroll Process is not
  -- being processed.
  --
  validate_act_cmp(p_assignment_action_id => p_rec.assignment_action_id);
  hr_utility.set_location(v_proc, 7);
  --
  -- Validate the element entry.
  --
  validate_ele_ent_id(p_rec => p_rec);
  hr_utility.set_location(v_proc, 8);
  --
  -- Validate that this quickpay exclusion does not already exist.
  --
  validate_row_exists(p_rec => p_rec);
  hr_utility.set_location(v_proc, 9);
  --
  hr_utility.set_location(' Leaving:'|| v_proc, 10);
end insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure controls the execution of all delete business rules
--   validation.
--
-- Pre Conditions:
--   This private procedure is called from del procedure.
--
-- In Arguments:
--   A Pl/Sql record structure.
--
-- Post Success:
--   Processing continues is no delete validation errors.
--
-- Post Failure:
--   If a business rules fails the error will not be handled by this procedure
--   unless explicitly coded.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure delete_validate(p_rec in pay_quickpay_exclusions%ROWTYPE) is
--
  v_proc  varchar2(72) := g_package||'delete_validate';
--
begin
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  -- Validate that the corresponding assignment action's payroll action does
  -- not have a status of Processing.
  --
  validate_act_cmp(p_assignment_action_id => p_rec.assignment_action_id);
  --
  hr_utility.set_location(' Leaving:'|| v_proc, 10);
end delete_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
--
Procedure ins
  (
  p_rec        in out nocopy pay_quickpay_exclusions%ROWTYPE,
  p_validate   in boolean default false
  ) is
--
  v_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  -- Determine if the business process is to be validated.
  --
  If p_validate then
    --
    -- Issue the savepoint.
    --
    SAVEPOINT ins_pay_qpe;
  End If;
  --
  -- Call the supporting insert validate operations
  --
  insert_validate(p_rec);
  --
  -- Insert the row
  --
  insert_dml(p_rec);
  --
  -- If we are validating then raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  hr_utility.set_location(' Leaving:'||v_proc, 10);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO ins_pay_qpe;
end ins;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
--
procedure ins
  (p_element_entry_id      in number
  ,p_assignment_action_id  in number
  ,p_validate              in boolean default false
  ) is
--
  v_rec   pay_quickpay_exclusions%ROWTYPE;
  v_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- pl/sql record structure.
  --
  v_rec :=
    convert_args
      (p_element_entry_id     => p_element_entry_id
      ,p_assignment_action_id => p_assignment_action_id
      );
  --
  -- Having converted the arguments into a pl/sql record structure
  -- call the entity version of ins.
  --
  ins(v_rec, p_validate);
  --
  hr_utility.set_location(' Leaving:'|| v_proc, 10);
End ins;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< del >----------------------------------|
-- ----------------------------------------------------------------------------
--
procedure del
  (p_rec        in pay_quickpay_exclusions%ROWTYPE
  ,p_validate   in boolean default false
  ) is
--
  v_proc varchar2(30) := g_package||'del';
--
Begin
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  -- We are deleting using the primary key therefore
  -- we must ensure that the argument value is NOT null.
  --
  if (p_rec.element_entry_id     is null  or
      p_rec.assignment_action_id is null
     ) then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', v_proc);
    hr_utility.set_message_token('STEP','5');
    hr_utility.raise_error;
  else
    --
    -- Determine if the business process is to be validated.
    --
    if p_validate then
      --
      -- Issue the savepoint.
      --
      SAVEPOINT del_pay_qpe;
    end if;
    --
    -- We must lock the row which we need to delete.
    --
    lck
      (p_rec.element_entry_id
      ,p_rec.assignment_action_id
      );
    --
    -- Call the supporting delete validate operation
    --
    delete_validate(p_rec);
    --
    -- Delete the row.
    --
    delete_dml(p_rec);

    --
    -- If we are validating then raise the Validate_Enabled exception
    --
    if p_validate then
      raise hr_api.validate_enabled;
    end if;
  end if;
  --
  hr_utility.set_location(' Leaving:'||v_proc, 10);
exception
  when hr_api.validate_enabled Then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO del_pay_qpe;
end del;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< del >----------------------------------|
-- ----------------------------------------------------------------------------
--
procedure del
  (p_element_entry_id      in number
  ,p_assignment_action_id  in number
  ,p_validate              in boolean default false
  ) is
--
  v_rec   pay_quickpay_exclusions%ROWTYPE;
  v_proc  varchar2(72) := g_package||'del';
--
begin
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  -- As the delete procedure accepts a plsql record structure we do need to
  -- convert the arguments into the record structure.
  -- We don't need to call the supplied conversion argument routine as we
  -- only need a few attributes.
  --
  v_rec.element_entry_id     := p_element_entry_id;
  v_rec.assignment_action_id := p_assignment_action_id;
  --
  -- Having converted the arguments into a plsql record
  -- structure we must call the entity version of del.
  --
  del(v_rec, p_validate);
  --
  hr_utility.set_location(' Leaving:'|| v_proc, 10);
end del;
--
end pay_qpe_api;

/
