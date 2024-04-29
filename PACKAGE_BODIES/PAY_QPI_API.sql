--------------------------------------------------------
--  DDL for Package Body PAY_QPI_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_QPI_API" as
/* $Header: pyqpirhi.pkb 115.5 2004/05/20 07:26:29 nbristow ship $ */
--
-- Current record structure definition
--
g_old_rec  pay_quickpay_inclusions%ROWTYPE;
--
-- Global package name
--
g_package  varchar2(30) := '  pay_qpi_api.';
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
    -- Error: You have tried to include an element entry in QuickPay for an
    -- assignment process that does not exist. The p_rec.assignment_action_id
    -- (or p_assignment_action_id) argument has been set to an incorrect value.
    hr_utility.set_message(801, 'HR_7224_QPAY_NO_ASG_ACT');
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
    -- Error: You have tried to include an element entry in QuickPay for an
    -- invalid type of payroll process. The payroll process corresponding to
    -- the assignment process (p_rec.assignment_action_id) must be of the type
    -- QuickPay Run.
    hr_utility.set_message(801, 'HR_7230_QPAY_NOT_ACT_QP');
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
--   p_rec is the QuickPay Inclusion record which contains the element entry
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
--     4) The element type for the element entry cannot be processed in a run.
--     5) The entry type is balance adjustment, replacement adjustment or
--        additive adjustment.
--
-- Access Status:
--   Private to this package.
--
-- {End Of Comments}
--
procedure validate_ele_ent_id
  (p_rec in pay_quickpay_inclusions%ROWTYPE
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
  cursor cur_inrun (p_date_earned date) is
    select 'Y'
      from pay_element_types_f    ety
         , pay_element_links_f    elk
         , pay_element_entries_f  ent
     where /* Element Types */
           ety.process_in_run_flag  = 'Y'
       and ety.element_type_id      = elk.element_type_id
       and p_date_earned      between ety.effective_start_date
                                  and ety.effective_end_date
           /* Element Links */
       and elk.element_link_id      = ent.element_link_id
       and p_date_earned      between elk.effective_start_date
                                  and elk.effective_end_date
           /* Element Entries */
       and ent.effective_start_date <= p_date_earned
       and ent.effective_end_date   >= decode(ety.proration_group_id, null, p_date_earned,
                                              pay_interpreter_pkg.prorate_start_date
                                                     (p_rec.assignment_action_id,
                                                      ety.proration_group_id
                                                     ))
       and ent.element_entry_id     = p_rec.element_entry_id;
   --
   cursor cur_entry (p_date_earned date) is
   select 'Y'
     from pay_element_entries_f
    where p_date_earned    between effective_start_date
                               and effective_end_date
      and entry_type            in ('B', 'A', 'R')
      and element_entry_id       = p_rec.element_entry_id;
   --
   cursor cur_fur_ele (p_date_earned date) is
    select 'Y'
      from pay_element_types_f    ety
         , pay_element_links_f    elk
         , pay_element_entries_f  ent
     where /*
            * Element Types
            */
           ety.element_type_id      = elk.element_type_id
       and p_date_earned      between ety.effective_start_date
                                  and ety.effective_end_date
           /*
            * Element Links
            */
       and elk.element_link_id      = ent.element_link_id
       and p_date_earned      between elk.effective_start_date
                                  and elk.effective_end_date
           /*
            * Element Entries, further checks
            */
       and ent.element_entry_id     = p_rec.element_entry_id
       and ent.effective_start_date <= p_date_earned
       and ent.effective_end_date   >= decode(ety.proration_group_id, null, p_date_earned,
                                              pay_interpreter_pkg.prorate_start_date
                                                     (p_rec.assignment_action_id,
                                                      ety.proration_group_id
                                                     ))
               /*
                * Non-recurring entries can only be included if they have not
                * been processed.
                */
       and ( ( (   (ety.processing_type   = 'N'
                   )
               /*
                * Recurring, additional or override entries can only be
                * included if they have not been processed. (These types of
                * recurring entry are handled as if they were non-recurring.)
                */
                or (    ety.processing_type    = 'R'
                    and ent.entry_type        <> 'E'
                   )
               )
               and (not exists (select null
                                 from pay_run_results pr1
                                where pr1.source_id   = ent.element_entry_id
                                  and pr1.source_type = 'E'
                                  and pr1.status      in ('P', 'PA')
                                  and not exists (select ''
                                                    from pay_run_results pr2
                                                   where pr2.source_id = pr1.run_result_id
                                                     and pr2.source_type = 'R'
                                                 )
                              )
                   )
             )
               /*
                * Include other recurring entries.
                * i.e. Those which are not additional or overrides entries.
                */
            or (    ety.processing_type    = 'R'
                and ent.entry_type         = 'E'
               )
           );
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
    -- Error: You have tried to include a non-existent element entry for
    -- QuickPay. The p_rec.element_entry_id (or element_entry_id) argument has
    -- been set to an incorrect value.
    hr_utility.set_message(801, 'HR_7232_QPAY_NO_ELE_ENT');
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
    -- Error: You have tried to include an element entry for QuickPay that
    -- does not exist at Date Earned. You can only include element entries
    -- that are date effective at this date.
    hr_utility.set_message(801, 'HR_7233_QPAY_NO_ELE_D_EARN');
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
    -- Error: You have tried to include an element entry for QuickPay that is
    -- not for the same assignment as defined for the QuickPay run.
    hr_utility.set_message(801, 'HR_7234_QPAY_ELE_NOT_ASG');
    hr_utility.raise_error;
  end if;
  close cur_same;
  hr_utility.set_location(v_proc, 8);
  --
  -- Check that the element type, for the element entry,
  -- can be processed in the run.
  --
  open cur_inrun(v_date_earned);
  fetch cur_inrun into v_exists;
  if cur_inrun%notfound then
    close cur_inrun;
    -- Error: You have tried to include an element entry for QuickPay for an
    -- element that cannot be processed in a payroll run.
    hr_utility.set_message(801, 'HR_7236_QPAY_ELE_NOT_PRO');
    hr_utility.raise_error;
  end if;
  close cur_inrun;
  hr_utility.set_location(v_proc, 9);
  --
  -- Check the element entry does not have a entry_type of
  -- balance adjustment, replacement adjustment or additive adjustment.
  --
  open cur_entry(v_date_earned);
  fetch cur_entry into v_exists;
  if cur_entry%found then
    close cur_entry;
    -- Error: You have tried to include an element entry in a QuickPay run
    -- that can only be used for a balance adjustment, replacement adjustment
    -- or additive adjustment.
    hr_utility.set_message(801, 'HR_7237_QPAY_ELE_WRG_CAT');
    hr_utility.raise_error;
  end if;
  close cur_entry;
  hr_utility.set_location(v_proc, 10);
  --
  -- Further element entry checks:
  --   A non-recurring entry cannot be included if it has already
  --   been processed.
  --   A recurring entry which is an 'Additional entry' or 'Override' cannot
  --   be included if it has already been processed. (These types of recurring
  --   entry are handled like a non-recurring entries.)
  --
  open cur_fur_ele(v_date_earned);
  fetch cur_fur_ele into v_exists;
  if cur_fur_ele%notfound then
    close cur_fur_ele;
    -- Error: You have tried to include an element entry in a QuickPay run
    -- that has already been processed. It is either a processed non-recurring
    -- entry or a processed recurring, additional or override entry.
    hr_utility.set_message(801, 'HR_7284_QPAY_ELE_ARY_PRO');
    hr_utility.raise_error;
  end if;
  close cur_fur_ele;
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
--   Validates that a Quickpay Inclusion does not exist. Used in insert
--   validation.
--
-- Pre Conditions:
--   None.
--
-- In Arguments:
--   p_rec is the QuickPay Inclusion record to check for.
--
-- Post Success:
--   This procedure ends successfully if the the QuickPay Inclusion does
--   not already exist in the pay_quickpay_inclusions table.
--
-- Post Failure:
--   Raises an error if the Quickpay Inclusion p_rec already exists in the
--   database.
--
-- Access Status:
--   Private to this package.
--
-- {End Of Comments}
--
procedure validate_row_exists
  (p_rec   in pay_quickpay_inclusions%ROWTYPE
  ) is
  --
  v_exists  varchar2(1);
  v_proc    varchar2(72) := g_package||'validate_row_exists';
  --
  cursor cur_exists is
    select 'Y'
      from pay_quickpay_inclusions
     where element_entry_id     = p_rec.element_entry_id
       and assignment_action_id = p_rec.assignment_action_id;
begin
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  -- Check that quickpay inclusion does not exist.
  --
  open cur_exists;
  fetch cur_exists into v_exists;
  if cur_exists%found then
    close cur_exists;
    -- Error: You have tried to include the same element entry more than once
    -- in the QuickPay run.
    hr_utility.set_message(801, 'HR_7238_QPAY_ELE_INCED');
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
--   Checks that the assignment action associated with this quickpay inclusion
--   does not have a status of complete and the payroll action does not have
--   a current task set to not null. This procedure is used in insert and
--   delete validation.
--
-- Pre Conditions:
--   A QuickPay Run assignment process already exists in pay_assignment_actions
--   with an id of p_assignment_action_id.
--
-- In Arguments:
--   p_assignment_action_id is the assignment_action_id on the Quickpay
--   Inclusion row.
--
-- Post Success:
--   Completes successfully if the assignment action does not have an
--   action_status of complete and the corresponding payroll process has a
--   null current_task.
--
-- Post Failure:
--   Raises an error if the Assignment Action has a status of complete or the
--   payroll process current_task is not null.
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
  cursor cur_aga_act is
    select 'Y'
      from pay_assignment_actions
     where assignment_action_id = p_assignment_action_id
       and action_status        in  ('C', 'S');
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
--   (pay_quickpay_inclusions table).
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
procedure insert_dml(p_rec in out nocopy pay_quickpay_inclusions%ROWTYPE) is
--
  v_proc  varchar2(72) := g_package||'insert_dml';
--
begin
  hr_utility.set_location('Entering:'||v_proc, 5);
  --
  -- Insert the row into: pay_quickpay_inclusions
  --
  insert into pay_quickpay_inclusions
    (element_entry_id
    ,assignment_action_id
    )
  values
    (p_rec.element_entry_id
    ,p_rec.assignment_action_id
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
Procedure delete_dml(p_rec in pay_quickpay_inclusions%ROWTYPE) is
--
  v_proc varchar2(72) := g_package||'delete_dml';
--
Begin
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  -- Delete the pay_quickpay_inclusions row.
  --
  delete from pay_quickpay_inclusions
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
      from pay_quickpay_inclusions
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
    hr_utility.set_message_token('TABLE_NAME', 'pay_quickpay_inclusions');
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
--   The individual attributes of the QuickPay Inclusion. p_element_entry_id
--   and p_assignment_action_id.
--
-- Post Success:
--   A record structure will be returned of type
--   pay_quickpay_inclusions%ROWTYPE.
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
  ) return pay_quickpay_inclusions%ROWTYPE is
--
  v_rec   pay_quickpay_inclusions%ROWTYPE;
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
procedure insert_validate(p_rec in pay_quickpay_inclusions%ROWTYPE) is
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
  -- Validate that corresponding assignment action
  -- does not have a status of Complete and the corresponding
  -- Payroll Process is not being processed.
  --
  validate_act_cmp(p_assignment_action_id => p_rec.assignment_action_id);
  hr_utility.set_location(v_proc, 7);
  --
  -- Validate the element entry.
  --
  validate_ele_ent_id(p_rec => p_rec);
  hr_utility.set_location(v_proc, 8);
  --
  -- Validate that this quickpay inclusion does not already exist.
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
procedure delete_validate(p_rec in pay_quickpay_inclusions%ROWTYPE) is
--
  v_proc  varchar2(72) := g_package||'delete_validate';
--
begin
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  -- Validate that corresponding assignment action
  -- does not have a status of Complete and the corresponding
  -- payroll action does not have a status of Processing.
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
  p_rec        in out nocopy pay_quickpay_inclusions%ROWTYPE,
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
    SAVEPOINT ins_pay_qpi;
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
    ROLLBACK TO ins_pay_qpi;
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
  v_rec   pay_quickpay_inclusions%ROWTYPE;
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
-- |-------------------------< bulk_default_ins >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure bulk_default_ins
  (p_assignment_action_id in pay_assignment_actions.assignment_action_id%TYPE
  ,p_validate             in boolean default false
  ) is
--
  v_proc  varchar2(72) := g_package||'bulk_default_ins';
--
begin
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  -- Determine if the business process is to be validated.
  --
  if p_validate then
    --
    -- Issue the savepoint.
    --
    savepoint bulk_default_ins_pay_qpi;
  end if;
  --
  -- Validate the assignment_action exists and the corresponding
  -- payroll_action is for a 'QuickPay Run'.
  --
  validate_asg_act_id(p_assignment_action_id => p_assignment_action_id);
  hr_utility.set_location(v_proc, 6);
  --
  -- Validate that corresponding assignment action
  -- does not have a status of Complete and the corresponding
  -- payroll action does not have a status of Processing.
  --
  validate_act_cmp(p_assignment_action_id => p_assignment_action_id);
  hr_utility.set_location(v_proc, 7);
  --
  -- Insert the default quickpay inclusions
  --
  insert into pay_quickpay_inclusions
    (element_entry_id
    ,assignment_action_id)
    select distinct
           ent.element_entry_id
         , asa.assignment_action_id
      from pay_element_types_f    ety
         , pay_element_links_f    elk
         , pay_element_entries_f  ent
         , pay_payroll_actions    pya
         , pay_assignment_actions asa
     where /*
            * Element Type:
            * Only include those which can be processed in the run.
            */
           ety.process_in_run_flag  = 'Y'
       and ety.element_type_id      = elk.element_type_id
       and pya.date_earned    between ety.effective_start_date
                                  and ety.effective_end_date
           /*
            * Element Link:
            * Only include those that exist as of QuickPay date earned.
            */
       and elk.element_link_id      = ent.element_link_id
       and pya.date_earned    between elk.effective_start_date
                                  and elk.effective_end_date
           /*
            * Element Entry:
            * Do not include balance adjustment, replacement adjustment
            * or additive adjustment.
            */
       and ent.entry_type      not in ('B', 'A', 'R')
       and ent.assignment_id        = asa.assignment_id
       and ent.effective_start_date <= pya.date_earned
       and ent.effective_end_date   >= decode(ety.proration_group_id, null, pya.date_earned,
                                              pay_interpreter_pkg.prorate_start_date
                                                     (asa.assignment_action_id,
                                                      ety.proration_group_id
                                                     ))
               /*
                * Non-recurring entries can only be included if they have not
                * been processed.
                */
       and ( ( (   (ety.processing_type   = 'N'
                   )
               /*
                * Recurring, additional or override entries can only be
                * included if they have not been processed. (These types of
                * recurring entry are handled as if they were non-recurring.)
                */
                or (    ety.processing_type    = 'R'
                    and ent.entry_type        <> 'E'
                   )
               )
               and (not exists (select null
                                 from pay_run_results pr1
                                where pr1.source_id   = ent.element_entry_id
                                  and pr1.source_type = 'E'
                                  and pr1.status      in ('P', 'PA')
                                  and not exists (select ''
                                                    from pay_run_results pr2
                                                   where pr2.source_id = pr1.run_result_id
                                                     and pr2.source_type = 'R'
                                                 )
                              )
                   )
             )
               /*
                * Include other recurring entries.
                * i.e. Those which are not additional or overrides entries.
                */
            or (    ety.processing_type    = 'R'
                and ent.entry_type         = 'E'
               )
           )
           /*
            * Payroll Action:
            * Ensure the action is for a QuickPay Run.
            */
       and pya.action_type          = 'Q'
       and pya.payroll_action_id    = asa.payroll_action_id
           /*
            *  Assignment Action:
            */
       and asa.assignment_action_id = p_assignment_action_id;
  --
  hr_utility.set_location(v_proc, 7);
  --
  -- If we are validating then perform the rollback.
  --
  if p_validate then
    --
    -- Issue the rollback.
    --
    rollback to bulk_default_ins_pay_qpi;
  end if;
  --
  hr_utility.set_location(' Leaving:'|| v_proc, 10);
end bulk_default_ins;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< del >----------------------------------|
-- ----------------------------------------------------------------------------
--
procedure del
  (p_rec        in pay_quickpay_inclusions%ROWTYPE
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
      SAVEPOINT del_pay_qpi;
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
    ROLLBACK TO del_pay_qpi;
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
  v_rec   pay_quickpay_inclusions%ROWTYPE;
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
end pay_qpi_api;

/
