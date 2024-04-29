--------------------------------------------------------
--  DDL for Package Body PAY_QPA_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_QPA_API" as
/* $Header: pyqpxrhi.pkb 115.5 2002/12/06 15:10:04 swinton noship $ */
--
-- Current record structure definition
--
g_old_rec  g_rec_type;
--
-- Global package name
--
g_package  varchar2(33) := '  pay_qpa_api.';
--
-- Global api dml status
--
g_api_dml  boolean;


----------------           < qppsassact >      ----------------------
   /*

      NAME
         qpppassact - Insert a QuickPay Pay-slip assg action.
      DESCRIPTION
         Process a QuickPay Payslip action.
      NOTES
         This procedure is meant to be called via the QuickPay form.
   */
   procedure qppsassact
   (
      p_payroll_action_id     in  number, -- of QuickPay Payslip.
      p_assignment_action_id  out nocopy number,
      p_object_version_number out nocopy number
   ) is

      l_assignment_id     number;
      l_assignment_action_id pay_assignment_actions.assignment_action_id%TYPE;
      l_locking_action_id number;
      l_qpp_locked_action_id number;
      l_qp_locked_action_id number;
      l_locked_action_id  number;
      l_tax_unit_id       number;

      cursor c_qpaction is
      select act.assignment_action_id
      from   pay_payroll_actions    pac,
             pay_assignment_actions act
      where  pac.payroll_action_id = p_payroll_action_id
      and    act.payroll_action_id = pac.target_payroll_action_id
      and    act.source_action_id is null;

      cursor c_asgid is
      select act.assignment_id
      from   pay_assignment_actions act,
             pay_payroll_actions    pac
      where  pac.payroll_action_id = p_payroll_action_id
      and    act.payroll_action_id = pac.target_payroll_action_id
      and    act.source_action_id is null;

      cursor c_qppaction is
      select pac.assignment_action_id,pac.tax_unit_id
      from pay_assignment_actions pac
      where pac.payroll_action_id = (select ppa.payroll_action_id
    				     from pay_payroll_actions ppa
               			     where ppa.target_payroll_action_id = (select ppa.target_payroll_action_id
                  		  				           from pay_payroll_actions ppa
            								   where ppa.payroll_action_id = p_payroll_action_id)
            		             and ppa.action_type = 'U'
                       		     and ppa.action_status = 'C');

      cursor c_qparcassact is
      select pac.assignment_action_id
      from pay_assignment_actions pac
      where pac.payroll_action_id =p_payroll_action_id;

      cursor c_next_assact is
      select pay_assignment_actions_s.nextval
      from sys.dual;

   begin
--
      -- We have to get the assignment_id
      -- of the assignment that is going
      -- to be archived, so it may be passed on.
      --
      hr_utility.set_location('Entering :qppsassact',10);


      open c_asgid;
      fetch c_asgid into l_assignment_id;
      if l_assignment_id is not null then
      	hr_utility.set_location('qppsassact',30);
      	--First find the tax unit id of the pre-payment process
      	open c_qppaction;
      	fetch c_qppaction into l_qpp_locked_action_id,l_tax_unit_id;
      	open c_next_assact;
      	fetch c_next_assact into l_assignment_action_id;

      	--Insert the new assignment action
      	if c_next_assact%found then
           if c_qppaction%found then
                hr_nonrun_asact.insact(l_assignment_action_id,l_assignment_id,p_payroll_action_id,1,l_tax_unit_id,null,'M',null);
           end if;
         end if;
      end if;
      close c_asgid;
      --

      open c_qparcassact;
      fetch c_qparcassact into l_locking_action_id;

      if c_qparcassact%found then

            --Then insert the quick-pay action rows into pay_action_interlocks
      	    hr_utility.set_location(' qppsassact :',40);
      	    open c_qpaction;
      	    fetch c_qpaction into l_qp_locked_action_id;
      	    if c_qpaction%found then
      	       -- We can now insert interlock row.
      	       hr_utility.set_location('qppsassact',50);
      	       hr_nonrun_asact.insint(l_locking_action_id,l_qp_locked_action_id);
      	    end if;
      	    close c_qpaction;

      	    --Then insert the quick-pay pre-payment action rows
      	    hr_utility.set_location(' qppsassact   ',55);
      	    hr_nonrun_asact.insint(l_locking_action_id,l_qpp_locked_action_id);
      end if;


      hr_utility.set_location(' qppsassact :',60);
      -- Update the payroll actions table with the
      -- appropriate date_earned value.
      hr_utility.set_location('qppsassact',70);
      update pay_payroll_actions pac
      set    pac.date_earned = (
             select pa2.date_earned
             from   pay_payroll_actions pa2,
                    pay_assignment_actions act
             where  act.assignment_action_id = l_qpp_locked_action_id
             and    pa2.payroll_action_id = act.payroll_action_id)

      where  pac.payroll_action_id =p_payroll_action_id;
--

      p_assignment_action_id := l_locking_action_id;
      p_object_version_number := 1;

      --Close all open cursors
      close c_qparcassact;
      close c_next_assact;
      close c_qppaction;

--
--    update the action_population_status to indicate
      -- an action has been successfully inserted.
      hr_utility.set_location('qppsassact',75);
      update pay_payroll_actions pac
      set    pac.action_population_status = 'C'
      where  pac.payroll_action_id        = p_payroll_action_id;

      hr_utility.set_location('Leaving : qppsassact',80);

   end qppsassact;
--

-- ----------------------------------------------------------------------------
-- |-------------------------< chk_action_status >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used check the action_status has only been updated
--   from 'C' (for Complete) to 'M' (for Mark for Retry). This is the only
--   update which the user is allowed to do.
--
-- Pre Conditions:
--   None.
--
-- In Arguments:
--   p_payroll_action_id is the id of the QuickPay Archival being updated.
--   p_old_action_status is set to the existing action_status in the database.
--   p_new_action_status is set to the user's proposed new action_status value.
--
-- Post Success:
--   Processing continues if the action_status update is valid and there are
--   no restrictive action interlocks.
--
-- Post Failure:
--   An application error is raised if the user is trying to do any other
--   update (i.e. not 'C' to 'M'). Also an error is raised if there are any
--   action interlocks preventing the update.
--
-- Access Status:
--   Private.
--
-- {End Of Comments}
--
procedure chk_action_status
  (p_payroll_action_id in number
  ,p_old_action_status in varchar2
  ,p_new_action_status in varchar2
  ) is
--
  l_proc  varchar2(72) := g_package||'chk_action_status';
--
begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Check the updated status is from 'C'omplete to 'M'ark for Retry
  --
  if (p_old_action_status not in ('C', 'S')) and (p_new_action_status <> 'M') then
    -- Error: You have tried to enter an invalid status for a completed
    -- QuickPay run. You can only update a completed assignment process
    -- status to Marked for Retry.
    hr_utility.set_message(801, 'HR_7252_QPAY_ONLY_MARK_RETRY');
    hr_utility.raise_error;
  end if;
  hr_utility.set_location(l_proc, 6);
  --
  -- Check that this QuickPay Archival can have
  -- a status of Mark for Retry
  --
  py_rollback_pkg.rollback_payroll_action(
                  p_payroll_action_id    => p_payroll_action_id,
                  p_rollback_mode        => 'RETRY',
                  p_leave_base_table_row => TRUE);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
end chk_action_status;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< chk_cur_task >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used in update and delete validation to check the
--   payroll_action current_task value. The user should not be allowed to
--   update any QuickPay Run attribute or delete a QuickPay Run when the
--   current_task is not null. (A not null value means a C process is
--   still processing the action.)
--
-- Pre Conditions:
--   p_payroll_action_id has already been validated as an id of a Payroll
--   Process which exists in the HR schema.
--
-- In Arguments:
--   p_payroll_action_id set to the id of an existing payroll action.
--
-- Post Success:
--   The current_task for this QuickPay Run is null. (Update or delete can
--   be allowed to continue, subject to other validation.)
--
-- Post Failure:
--   An application error is raised if the current_task value is not null.
--
-- Access Status:
--   Private.
--
-- {End Of Comments}
--
procedure chk_cur_task
  (p_payroll_action_id in pay_payroll_actions.payroll_action_id%TYPE
  ) is
  --
  v_exists  varchar2(1);
  l_proc    varchar2(72) := g_package||'chk_cur_task';
  --
  cursor sel_task is
    select 'Y'
      from pay_payroll_actions
     where payroll_action_id = p_payroll_action_id
       and current_task      is not null;
begin
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  open sel_task;
  fetch sel_task into v_exists;
  if sel_task%found then
    close sel_task;
    -- Error: You have tried to update or delete a QuickPay Archival while
    -- the corresponding payroll process has a status of Processing.
    hr_utility.set_message(801, 'HR_7256_QPAY_U_PROCESSING');
    hr_utility.raise_error;
  end if;
  close sel_task;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 10);
end chk_cur_task;
--
-- ----------------------------------------------------------------------------
-- |----------------------< check_non_updateable_args >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to ensure that non updateable attributes have
--   not been updated.
--
-- Pre Conditions:
--   g_old_rec has been populated with details of the values currently in
--   the database.
--
-- In Arguments:
--   p_rec has been populated with the updated values the user would like the
--   record set to.
--
-- Post Success:
--   Processing continues if all the non updateable attributes have not
--   changed.
--
-- Post Failure:
--   An application error is raised if any of the non updatable attributes
--   (business_group_id, org_payment_method_id, target_payroll_action_id or
--   effective_date) have been altered.
--
-- Access Status:
--   Private.
--
-- {End Of Comments}
--
Procedure check_non_updateable_args(p_rec in g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'check_non_updateable_args';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  if nvl(p_rec.business_group_id, hr_api.g_number) <>
     nvl(g_old_rec.business_group_id, hr_api.g_number) then
    hr_api.argument_changed_error
      (p_api_name => l_proc
      ,p_argument => 'business_group_id'
      );
  end if;
  hr_utility.set_location(l_proc, 6);
  --
  if nvl(p_rec.org_payment_method_id, hr_api.g_number) <>
     nvl(g_old_rec.org_payment_method_id, hr_api.g_number) then
    hr_api.argument_changed_error
      (p_api_name => l_proc
      ,p_argument => 'org_payment_method_id'
      );
  end if;
  hr_utility.set_location(l_proc, 7);
  --
  if nvl(p_rec.target_payroll_action_id, hr_api.g_number) <>
     nvl(g_old_rec.target_payroll_action_id, hr_api.g_number) then
    hr_api.argument_changed_error
      (p_api_name => l_proc
      ,p_argument => 'target_payroll_action_id'
      );
  end if;
  hr_utility.set_location(l_proc, 8);
  --
  if nvl(p_rec.effective_date, hr_api.g_date) <>
     nvl(g_old_rec.effective_date, hr_api.g_date) then
    hr_api.argument_changed_error
      (p_api_name => l_proc
      ,p_argument => 'effective_date'
      );
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
end check_non_updateable_args;
--

-- ----------------------------------------------------------------------------
-- |--------------------< chk_target_payroll_action_id >----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Validates target_payroll_action_id and business_group_id for a QuickPay
--   Archival Run Process. Used for insert validation.
--
-- Pre Conditions:
--   None.
--
-- In Arguments:
--   p_target_payroll_action_id is set to the payroll_action_id of QuickPay Run
--   associated with the QuickPay Archival.
--   p_business_group_id is set to the business group for the QuickPay
--   Archival.
--   p_effective_date is set to the effective_date for the QuickPay
--   Archival.
--
-- Post Success:
--   Processing continues if p_target_payroll_action_id, p_business_group_id
--   and p_effective_date are valid.
--
-- Post Failure:
--   An error is raised if any of the following conditions are found:
--   1) target_payroll_action_id, business_group_id or effective_date are
--      not null.
--   2) target_payroll_action_id does not exists in pay_payroll_actions for a
--      QuickPay Run.
--   3) The associated Assignment Process has a complete status.
--   4) Another QuickPay Archival run already
--      interlocks to the QuickPay Run Assignment Process.
--   5) The QuickPay Archival run business_group_id and date_paid
--      (effective_date) are not the same as the QuickPay Run
--      business_group_id and date_paid.
--
-- Access Status:
--   Private.
--

-- {End Of Comments}
--
procedure chk_target_payroll_action_id
  (p_target_payroll_action_id in
     pay_payroll_actions.target_payroll_action_id%TYPE
  ,p_business_group_id        in pay_payroll_actions.business_group_id%TYPE
  ,p_effective_date           in pay_payroll_actions.effective_date%TYPE
  ) is
  --
  l_exists  varchar2(1);
  l_proc    varchar2(72) := g_package||'chk_target_payroll_action_id';
  --
  cursor csr_pay_act is

    select 'Y'
      from pay_payroll_actions    pya
         , pay_assignment_actions aga
     where pya.payroll_action_id = p_target_payroll_action_id
       and pya.action_type       = 'Q'
       and aga.payroll_action_id = pya.payroll_action_id
       and aga.action_status     in ('C', 'S');
  --

  cursor csr_bus_grp is
    select 'Y'
      from pay_payroll_actions pya
     where pya.payroll_action_id = p_target_payroll_action_id
       and pya.business_group_id = p_business_group_id
       and pya.effective_date    = p_effective_date;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error

    (p_api_name       => l_proc
    ,p_argument       => 'target_payroll_action_id'
    ,p_argument_value => p_target_payroll_action_id
    );
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'business_group_id'
    ,p_argument_value => p_business_group_id
    );
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'effective_date'
    ,p_argument_value => p_effective_date

    );
  hr_utility.set_location(l_proc, 6);
  --
  -- Check the target_payroll_action_id exists in pay_payroll_actions
  -- and it is for a completed QuickPay Run assignment action.
  --
  open csr_pay_act;
  fetch csr_pay_act into l_exists;
  if csr_pay_act%notfound then
    close csr_pay_act;
    -- Error: You have tried to create a QuickPay Archival for a
    -- target_payroll_action_id that does not exist, or for a QuickPay run
    -- that does not have the status Complete.

    hr_utility.set_message(801, 'HR_7257_QPAY_U_QRUN_NOT_EXIST');
    hr_utility.raise_error;
  end if;
  close csr_pay_act;
  hr_utility.set_location(l_proc, 7);
  --
  --
  -- Check the QuickPay Archival run business group and effective_date are the
  -- same as the QuickPay Run business group and effective_date (date_paid).

  --
  open csr_bus_grp;
  fetch csr_bus_grp into l_exists;
  if csr_bus_grp%notfound then
    close csr_bus_grp;
    -- Error: The business_group and date_paid attributes for the QuickPay
    -- Archival must have the same values as the business_group and
    -- date_paid for the QuickPay run.
    hr_utility.set_message(801, 'HR_7260_QPAY_U_SAME_AS_Q');
    hr_utility.raise_error;
  end if;
  close csr_bus_grp;
  --

  hr_utility.set_location(' Leaving:'|| l_proc, 9);
end chk_target_payroll_action_id;
--
-- ----------------------------------------------------------------------------
-- |------------------------< return_api_dml_status >-------------------------|
-- ----------------------------------------------------------------------------
--

Function return_api_dml_status Return Boolean Is
--
  l_proc  varchar2(72) := g_package||'return_api_dml_status';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  Return (nvl(g_api_dml, false));
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End return_api_dml_status;
--
-- ----------------------------------------------------------------------------

-- |---------------------------< constraint_error >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is called when a constraint has been violated (i.e.
--   The exception hr_api.check_integrity_violated,
--   hr_api.parent_integrity_violated, hr_api.child_integrity_violated or
--   hr_api.unique_integrity_violated has been raised).
--   The exceptions can only be raised as follows:
--   1) A check constraint can only be violated during an INSERT or UPDATE
--      dml operation.
--   2) A parent integrity constraint can only be violated during an

--      INSERT or UPDATE dml operation.
--   3) A child integrity constraint can only be violated during an
--      DELETE dml operation.
--   4) A unique integrity constraint can only be violated during INSERT or
--      UPDATE dml operation.
--
-- Pre Conditions:
--   1) Either hr_api.check_integrity_violated,
--      hr_api.parent_integrity_violated, hr_api.child_integrity_violated or
--      hr_api.unique_integrity_violated has been raised with the subsequent
--      stripping of the constraint name from the generated error message
--      text.
--   2) Standalone validation test which correspond with a constraint error.

--
-- In Arguments:
--   p_constraint_name is in upper format and is just the constraint name
--   (e.g. not prefixed by brackets, schema owner etc).
--
-- Post Success:
--   Development dependant.
--
-- Post Failure:
--   Development dependant.
--
-- Developer Implementation Notes:
--   For each constraint being checked the hr system package failure message

--   has been generated as a template only. These system error messages should
--   be modified as required (i.e. change the system failure message to a user
--   friendly defined error message).
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
Procedure constraint_error
            (p_constraint_name in all_constraints.constraint_name%TYPE) Is
--
  l_proc 	varchar2(72) := g_package||'constraint_error';

--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (p_constraint_name = 'PAY_PAYRACT_ACTION_POPULAT_CHK') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','5');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'PAY_PAYRACT_ACTION_STATUS_CHK') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','10');

    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'PAY_PAYRACT_ACTION_TYPE_CHK') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','15');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'PAY_PAYRACT_CURRENT_TASK_CHK') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','20');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'PAY_PAYROLL_ACTIONS_FK1') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');

    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','25');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'PAY_PAYROLL_ACTIONS_FK2') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','30');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'PAY_PAYROLL_ACTIONS_FK5') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','35');
    hr_utility.raise_error;

  ElsIf (p_constraint_name = 'PAY_PAYROLL_ACTIONS_FK6') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','40');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'PAY_PAYROLL_ACTIONS_FK7') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','45');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'PAY_PAYROLL_ACTIONS_FK8') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);

    hr_utility.set_message_token('STEP','50');
    hr_utility.raise_error;
  Else
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','55');
    hr_utility.raise_error;
  End If;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End constraint_error;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< lck >----------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (p_payroll_action_id        in number
  ,p_p_object_version_number  in number
  ,p_a_object_version_number  in number
  ) is
  l_p_object_version_number  number;
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_lock is
    select pya.payroll_action_id
         , pya.business_group_id
	 , pya.org_payment_method_id
	 , pya.action_status
         , pya.effective_date
	 , pya.target_payroll_action_id
	 , aga.object_version_number
         , pya.object_version_number
      from pay_payroll_actions    pya
         , pay_assignment_actions aga
     where /* Payroll action lock */
           pya.payroll_action_id = p_payroll_action_id
       and pya.action_type       = 'X'
           /* Assignment action lock */
       and aga.payroll_action_id = pya.payroll_action_id
       for update nowait;
  --
  l_proc  varchar2(72) := g_package||'lck';
  --
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Check the mandatory args have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'payroll_action_id'
    ,p_argument_value => p_payroll_action_id
    );
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'p_object_version_number'
    ,p_argument_value => p_p_object_version_number
    );
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'a_object_version_number'
    ,p_argument_value => p_a_object_version_number
    );
  hr_utility.set_location(l_proc, 6);
  --
  -- Additional logic specific to this entity:
  -- Do not allow the lock to be taken out if there is an AOL concurrent
  -- request waiting to run or still running on a concurrent manager.
  --
  pay_qpq_api.chk_for_con_request
    (p_payroll_action_id => p_payroll_action_id);
  hr_utility.set_location(l_proc, 7);
  --
  open  C_lock;
  Fetch C_lock Into g_old_rec.payroll_action_id
                  , g_old_rec.business_group_id
                  , g_old_rec.org_payment_method_id
                  , g_old_rec.action_status
                  , g_old_rec.effective_date
                  , g_old_rec.target_payroll_action_id
                  , g_old_rec.object_version_number
                  , l_p_object_version_number;
  If C_lock%notfound then
    Close C_lock;
    --
    -- The primary key is invalid therefore we must error
    --
    hr_utility.set_message(801, 'HR_7220_INVALID_PRIMARY_KEY');
    hr_utility.raise_error;
  End If;
  Close C_lock;
  If (p_a_object_version_number <> g_old_rec.object_version_number) or
     (p_p_object_version_number <> l_p_object_version_number)       Then
    hr_utility.set_message(801, 'HR_7155_OBJECT_INVALID');
    hr_utility.raise_error;
  End If;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  --
  -- We need to trap the ORA LOCK exception
  --
Exception
  When HR_Api.Object_Locked then
    --
    -- The object is locked therefore we need to supply a meaningful
    -- error message.
    --
    hr_utility.set_message(801, 'HR_7165_OBJECT_LOCKED');
    hr_utility.set_message_token('TABLE_NAME', 'pay_payroll_actions');
    hr_utility.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_defs >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   The Convert_Defs function has one very important function:
--   It must return the record structure for the row with all system defaulted
--   values converted into its corresponding argument value for update. When
--   we attempt to update a row through the Upd business process , certain
--   arguments can be defaulted which enables flexibility in the calling of
--   the upd process (e.g. only attributes which need to be updated need to be
--   specified). For the upd business process to determine which attributes
--   have NOT been specified we need to check if the argument has a reserved
--   system default value. Therefore, for all attributes which have a
--   corresponding reserved system default mechanism specified we need to
--   check if a system default is being used. If a system default is being
--   used then we convert the defaulted value into its corresponding attribute
--   value held in the g_old_rec data structure.
--
-- Pre Conditions:
--   This private function can only be called from the upd process.
--
-- In Arguments:
--   A Pl/Sql record structure.
--
-- Post Success:
--   The record structure will be returned with all system defaulted argument
--   values converted into its current row attribute value.
--
-- Post Failure:
--   No direct error handling is required within this function. Any possible
--   errors within this function will be a PL/SQL value error due to
--   conversion  of datatypes or data lengths.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
Function convert_defs(p_rec in out nocopy g_rec_type)
         Return g_rec_type is
--
  l_proc	  varchar2(72) := g_package||'convert_defs';
--
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must now examine each argument value in the
  -- p_rec plsql record structure
  -- to see if a system default is being used. If a system default
  -- is being used then we must set to the 'current' argument value.
  --
  If (p_rec.business_group_id = hr_api.g_number) then
    p_rec.business_group_id := g_old_rec.business_group_id;
  End If;
  If (p_rec.org_payment_method_id = hr_api.g_number) then
    p_rec.org_payment_method_id := g_old_rec.org_payment_method_id;
  End If;
  If (p_rec.action_status = hr_api.g_varchar2) then
    p_rec.action_status := g_old_rec.action_status;
  End If;
  If (p_rec.effective_date = hr_api.g_date) then
    p_rec.effective_date := g_old_rec.effective_date;
  End If;
  If (p_rec.target_payroll_action_id = hr_api.g_number) then
    p_rec.target_payroll_action_id := g_old_rec.target_payroll_action_id;
  End If;
  --
  -- Return the plsql record structure.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  Return(p_rec);
--
End convert_defs;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< update_dml >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure controls the actual dml update logic. The functions of
--   this  procedure are as follows:
--   1. Increment the object_version_number by 1.
--   2. To set and unset the g_api_dml status as required (as we are about to
--      perform dml).
--   3. To update the specified row in the schema using the primary key in
--      the predicates.
--   4. To trap any constraint violations that may have occurred.
--   5. To raise any other errors.
--
-- Pre Conditions:
--   This is an internal private procedure which must be called from the upd
--   procedure.
--
-- In Arguments:
--   A Pl/Sql record structure.
--
-- Post Success:
--   The specified row will be updated in the schema.
--
-- Post Failure:
--   On the update dml failure it is important to note that we always reset
--   the g_api_dml status to false.
--   If a check or parent integrity constraint violation is raised the
--   constraint_error procedure will be called.
--   If any other error is reported, the error will be raised after the
--   g_api_dml status is reset.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
Procedure update_dml(p_rec in out nocopy g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'update_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Increment the object version
  --
  p_rec.object_version_number := p_rec.object_version_number + 1;
  --
  -- Set the api dml status
  --
  g_api_dml := true;
  --
  -- Update the pay_payroll_actions Row
  --
  update pay_payroll_actions
    set action_status         = p_rec.action_status
      , object_version_number = p_rec.object_version_number
  where payroll_action_id     = p_rec.payroll_action_id;
  --
  -- Unset the api dml status
  --
  g_api_dml := false;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    g_api_dml := false;   -- Unset the api dml status
    constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated then
    -- Parent integrity has been violated
    g_api_dml := false;   -- Unset the api dml status
    constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    g_api_dml := false;   -- Unset the api dml status
    constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    g_api_dml := false;   -- Unset the api dml status
    Raise;
End update_dml;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< insert_dml >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure controls the actual dml insert logic. The functions of
--   this procedure are as follows:
--   1. Initialise the object_version_number to 1.
--   2. To set and unset the g_api_dml status as required (as we are about to
--      perform dml).
--   3. To insert the row into the schema.
--   4. To trap any constraint violations that may have occurred.
--   5. To raise any other errors.

--
-- Pre Conditions:
--   This is an internal private procedure which must be called from the ins
--   procedure and must have all mandatory arguments set (except the
--   object_version_number which is initialised within this procedure).
--
-- In Arguments:
--   p_rec
--     Contains the main attributes to be inserted for the Payroll Process row.
--   p_action_type
--     Will be used to populate pay_payroll_action.action_type
--   p_payroll_id
--     Will be used to populate pay_payroll_action.payroll_id

--   p_consolidation_set_id
--     Will be used to populate pay_payroll_action.consolidation_set_id
--   p_action_population_status
--     Will be used to populate pay_payroll_action.action_population_status
--
-- Post Success:
--   The specified row will be inserted into the schema.
--
-- Post Failure:
--   On the insert dml failure it is important to note that we always reset
--   the g_api_dml status to false.
--   If a check or parent integrity constraint violation is raised the
--   constraint_error procedure will be called.

--   If any other error is reported, the error will be raised after the
--   g_api_dml status is reset.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
Procedure insert_dml
  (p_rec                       in out nocopy g_rec_type
  ,p_action_type               in     pay_payroll_actions.action_type%TYPE
  ,p_payroll_id                in     pay_payroll_actions.payroll_id%TYPE
  ,p_consolidation_set_id      in
                       pay_payroll_actions.consolidation_set_id%TYPE
  ,p_action_population_status  in
                       pay_payroll_actions.action_population_status%TYPE
  ) is
--
  l_proc  varchar2(72) := g_package||'insert_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --

  -- Initialise the object version
  --
  p_rec.object_version_number := 1;
  --
  -- Set the api dml status
  --
  g_api_dml := true;
  --
  -- Insert the row into: pay_payroll_actions
  --
  insert into pay_payroll_actions
    (payroll_action_id
    ,business_group_id
    ,org_payment_method_id
    ,action_status
    ,effective_date
    ,target_payroll_action_id
    ,action_type
    ,payroll_id
    ,consolidation_set_id
    ,action_population_status
    ,object_version_number
    ,legislative_parameters
    ,report_type
    ,report_qualifier
    ,report_category
    )
  values
    (p_rec.payroll_action_id
    ,p_rec.business_group_id
    ,p_rec.org_payment_method_id
    ,p_rec.action_status
    ,p_rec.effective_date
    ,p_rec.target_payroll_action_id
    ,p_action_type
    ,p_payroll_id
    ,p_consolidation_set_id
    ,p_action_population_status
    ,p_rec.object_version_number
    ,p_rec.legislative_parameters
    ,p_rec.report_type
    ,p_rec.report_qualifier
    ,p_rec.report_category
    );
  --
  -- Unset the api dml status
  --

  g_api_dml := false;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    g_api_dml := false;   -- Unset the api dml status
    constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated then
    -- Parent integrity has been violated
    g_api_dml := false;   -- Unset the api dml status
    constraint_error

      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    g_api_dml := false;   -- Unset the api dml status
    constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    g_api_dml := false;   -- Unset the api dml status
    hr_utility.set_location('Others exception '||l_proc,-999);
    Raise;
End insert_dml;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< pre_update >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This private procedure contains any processing which is required before
--   the update dml.
--
-- Pre Conditions:
--   This is an internal procedure which is called from the upd procedure.
--
-- In Arguments:
--   A Pl/Sql record structure.
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   If an error has occurred, an error message and exception will be raised
--   but not handled.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
Procedure pre_update(p_rec in g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'pre_update';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End pre_update;
--

-- ----------------------------------------------------------------------------
-- |------------------------------< pre_insert >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}

--
-- Description:
--   This private procedure contains any processing which is required before
--   the insert dml. Presently, if the entity has a corresponding primary
--   key which is maintained by an associating sequence, the primary key for
--   the entity will be populated with the next sequence value in
--   preparation for the insert dml.
--
-- Pre Conditions:
--   This is an internal procedure which is called from the ins procedure.
--
-- In Arguments:
--   A Pl/Sql record structure.

--
-- Post Success:
--   p_rec.action_status
--     Set to 'M', the code for Mark for Retry
--   p_action_type
--     Set to 'X', the code for a Archive
--   p_payroll_id
--     Set to the payroll_id attribute as defined on the corresponding
--     QuickPay Run payroll action.
--   p_consolidation_set_id
--     Set to the consolidation_set_id attribute as defined on the
--     corresponding QuickPay Run payroll action.
--   p_action_population_status
--     Set to 'U', the code for Unpopulated.
--
-- Post Failure:
--   If an error has occurred, an error message and exception will be raised
--   but not handled.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
Procedure pre_insert
  (p_rec                   in out nocopy g_rec_type
  ,p_action_type              out nocopy varchar2
  ,p_payroll_id               out nocopy number
  ,p_consolidation_set_id     out nocopy pay_payroll_actions.
                                                    consolidation_set_id%TYPE
  ,p_action_population_status out nocopy varchar2
  ) is
  --
  l_proc  varchar2(72) := g_package||'pre_insert';
  --
  Cursor C_next_id is select pay_payroll_actions_s.nextval from sys.dual;
  --
  cursor csr_qpq_details (v_target_payroll_action_id number) is
    select pya.payroll_id
         , pya.consolidation_set_id
      from pay_payroll_actions  pya
     where pya.payroll_action_id = v_target_payroll_action_id;
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Select the next sequence number
  --
  Open C_next_id;
  Fetch C_next_id Into p_rec.payroll_action_id;
  Close C_next_id;
  hr_utility.set_location(l_proc, 6);
  --
  -- Set the action_status to Mark for Retry
  --
  p_rec.action_status := 'M';
  --
  -- Set pay_payroll_action columns which are only
  -- set by non-process code at insert time.
  --
  -- Set action_type to Archive
  --
  p_action_type := 'X';
  --
  -- Set action_population_status to unpopulated
  --
  p_action_population_status := 'U';

  --
  -- Set columns which are derived from the QuickPay Run action
  --
  open csr_qpq_details(p_rec.target_payroll_action_id);
  fetch csr_qpq_details into p_payroll_id
                           , p_consolidation_set_id;
  if csr_qpq_details%notfound then
    close csr_qpq_details;
    -- Internal error
    -- The corresponding QuickPay Run payroll action has been deleted
    -- between validating it exists in insert_validate and pre_insert.
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);

    hr_utility.set_message_token('STEP', '1');
    hr_utility.raise_error;
  end if;
  close csr_qpq_details;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End pre_insert;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< post_update >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This private procedure contains any processing which is required after
--   the update dml.
--
-- Pre Conditions:
--   This is an internal procedure which is called from the upd procedure.
--
-- In Arguments:
--   A Pl/Sql record structure.
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   If an error has occurred, an error message and exception will be raised
--   but not handled.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
Procedure post_update(p_rec in g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'post_update';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End post_update;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< post_insert >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This private procedure contains any processing which is required after
--   the insert dml.
--

-- Pre Conditions:
--   This is an internal procedure which is called from the ins procedure.
--
-- In Arguments:
--   A Pl/Sql record structure.
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   If an error has occurred, an error message and exception will be raised
--   but not handled.
--

-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
Procedure post_insert
  (p_rec                     in     g_rec_type
  ,p_assignment_action_id       out nocopy number
  ,p_a_object_version_number    out nocopy number
  ) is
  --
  l_proc                  varchar2(72) := g_package||'post_insert';
  --

  -- These variables are set by inserting the assignment action.
  -- The values are returned from this procedure.
  --
  l_assignment_action_id  pay_assignment_actions.assignment_action_id%TYPE;
  l_object_version_number pay_assignment_actions.object_version_number%TYPE;
  --
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Insert the QuickPay Archival Run assignment action and the action interlock
  --
    qppsassact
    (p_payroll_action_id     => p_rec.payroll_action_id
    ,p_assignment_action_id  => l_assignment_action_id
    ,p_object_version_number => l_object_version_number
    );

  hr_utility.set_location(l_proc, 6);
  --
  p_assignment_action_id    := l_assignment_action_id;
  p_a_object_version_number := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End post_insert;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This function is used to turn attribute arguments into the record
--   structure g_rec_type.
--
-- Pre Conditions:
--   This is a private function and can only be called from the ins or upd
--   attribute processes.
--
-- In Arguments:
--   The individual attributes of a QuickPay Archival.
--
-- Post Success:
--   A returning record structure will be returned.
--
-- Post Failure:
--   No direct error handling is required within this function. Any possible
--   errors within this function will be a PL/SQL value error due to
--    conversion of datatypes or data lengths.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
function convert_args
  (p_payroll_action_id         in number
  ,p_business_group_id         in number
  ,p_org_payment_method_id     in number
  ,p_action_status             in varchar2
  ,p_effective_date            in date
  ,p_legislative_parameters    in varchar2
  ,p_target_payroll_action_id  in number
  ,p_object_version_number     in number
  ,p_report_type	       in varchar2
  ,p_report_qualifier	       in varchar2
  ,p_report_category	       in varchar2
  ) Return g_rec_type is
--
  l_rec	g_rec_type;
  l_proc  varchar2(72) := g_package||'convert_args';
--
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Convert arguments into local l_rec structure.

  --
  l_rec.payroll_action_id         := p_payroll_action_id;
  l_rec.business_group_id         := p_business_group_id;
  l_rec.org_payment_method_id     := p_org_payment_method_id;
  l_rec.action_status             := p_action_status;
  l_rec.effective_date            := p_effective_date;
  l_rec.legislative_parameters    := p_legislative_parameters;
  l_rec.target_payroll_action_id  := p_target_payroll_action_id;
  l_rec.object_version_number     := p_object_version_number;
  l_rec.report_type		  := p_report_type;
  l_rec.report_qualifier	  := p_report_qualifier;
  l_rec.report_category		  := p_report_category;
  --
  -- Return the plsql record structure.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  Return(l_rec);

--
End convert_args;
--
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure controls the execution of all update business rules
--   validation.
--
-- Pre Conditions:
--   This private procedure is called from upd procedure.
--
-- In Arguments:
--   A Pl/Sql record structure.
--
-- Post Success:
--   Processing continues.
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
Procedure update_validate(p_rec in g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  -- Check that the columns which cannot be
  -- updated have not be changed.
  --
  check_non_updateable_args(p_rec => p_rec);
  hr_utility.set_location(l_proc, 6);
  --
  -- Check that the payroll_action has a null current_task.
  --
  chk_cur_task
    (p_payroll_action_id => p_rec.payroll_action_id
    );
  hr_utility.set_location(l_proc, 7);
  --
  -- If the action_status has changed, validate it has only been
  -- changed to 'M'ark for Retry and that action is allowed to have
  -- a 'M'ark for Retry status. (Ensure this is always the last validation
  -- step because the chk_action_status procedure will update child rows.)
  --

  if p_rec.action_status <> g_old_rec.action_status then
    chk_action_status
      (p_payroll_action_id => p_rec.payroll_action_id
      ,p_old_action_status => g_old_rec.action_status
      ,p_new_action_status => p_rec.action_status
      );
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
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
--   Processing continues.
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
Procedure insert_validate(p_rec in g_rec_type) is
--
  l_proc	varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  --
  -- Validate target_payroll_action_id, business_group_id and effective_date
  --
  chk_target_payroll_action_id
    (p_target_payroll_action_id => p_rec.target_payroll_action_id
    ,p_business_group_id        => p_rec.business_group_id
    ,p_effective_date           => p_rec.effective_date
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
--
procedure upd
  (p_rec                     in out nocopy g_rec_type
  ,p_assignment_action_id    in     number
  ,p_a_object_version_number in     number
  ,p_validate                in     boolean default false
  ) is
--
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Determine if the business process is to be validated.
  --
  If p_validate then
    --
    -- Issue the savepoint.
    --
    SAVEPOINT upd_pay_qpu;
  End If;
  --
  -- We must lock the row which we need to update.
  --
  lck
    (p_payroll_action_id       => p_rec.payroll_action_id
    ,p_p_object_version_number => p_rec.object_version_number
    ,p_a_object_version_number => p_a_object_version_number
    );
  --
  -- 1. During an update system defaults are used to determine if
  --    arguments have been defaulted or not. We must therefore
  --    derive the full record structure values to be updated.
  --
  -- 2. Call the supporting update validate operations.
  --
  update_validate(convert_defs(p_rec));
  --
  -- Call the supporting pre-update operation
  --
  pre_update(p_rec);
  --
  -- Update the row.
  --
  update_dml(p_rec);
  --
  -- Call the supporting post-update operation
  --
  post_update(p_rec);
  --
  -- If we are validating then raise the Validate_Enabled exception
  --
  If p_validate then
    Raise HR_Api.Validate_Enabled;
  End If;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  When HR_Api.Validate_Enabled Then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO upd_pay_qpu;
End upd;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
--
Procedure ins
  (p_rec                     in out nocopy g_rec_type
  ,p_assignment_action_id       out nocopy number
  ,p_a_object_version_number    out nocopy number
  ,p_validate                in     boolean default false
  ) is
  --
  l_proc                     varchar2(72) := g_package||'ins';
  --
  -- These variables are set by pre_insert and past to insert_dml
  --
  l_action_type              pay_payroll_actions.action_type%TYPE;
  l_payroll_id               pay_payroll_actions.payroll_id%TYPE;
  l_consolidation_set_id     pay_payroll_actions.consolidation_set_id%TYPE;
  l_action_population_status pay_payroll_actions.action_population_status%TYPE;

  --
  -- These variables are set by post_insert and returned from this procedure
  --
  l_assignment_action_id     pay_assignment_actions.assignment_action_id%TYPE;
  l_a_object_version_number  pay_assignment_actions.object_version_number%TYPE;
  --
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Determine if the business process is to be validated.
  --
  If p_validate then
    --
    -- Issue the savepoint.
    --
    SAVEPOINT ins_pay_qpu;
  End If;
  --
  -- Call the supporting insert validate operations
  --
  insert_validate(p_rec);
  --
  -- Call the supporting pre-insert operation
  --
  pre_insert
    (p_rec                       => p_rec
    ,p_action_type               => l_action_type
    ,p_payroll_id                => l_payroll_id
    ,p_consolidation_set_id      => l_consolidation_set_id
    ,p_action_population_status  => l_action_population_status
    );
  --
  -- Insert the row
  --
  insert_dml
    (p_rec                       => p_rec
    ,p_action_type               => l_action_type
    ,p_payroll_id                => l_payroll_id
    ,p_consolidation_set_id      => l_consolidation_set_id
    ,p_action_population_status  => l_action_population_status
    );
  --
  -- Call the supporting post-insert operation
  --
  post_insert
    (p_rec                     => p_rec
    ,p_assignment_action_id    => l_assignment_action_id
    ,p_a_object_version_number => l_a_object_version_number
    );
  --
  -- Set output parameters
  --

  p_assignment_action_id    := l_assignment_action_id;
  p_a_object_version_number := l_a_object_version_number;
  --
  -- If we are validating then raise the Validate_Enabled exception
  --
  If p_validate then

    Raise HR_Api.Validate_Enabled;
  End If;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  When HR_Api.Validate_Enabled Then
    --

    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    hr_utility.set_location(' Calling Rollback now'||l_proc, 99);
    ROLLBACK TO ins_pay_qpu;
end ins;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
--
procedure upd
  (p_payroll_action_id        in     number
  ,p_assignment_action_id     in     number
  ,p_action_status            in     varchar2  default hr_api.g_varchar2
  ,p_p_object_version_number  in out nocopy number
  ,p_a_object_version_number  in     number
  ,p_validate                 in     boolean   default false
  ) is
--
  l_rec   g_rec_type;
  l_proc  varchar2(72) := g_package||'upd';
--
Begin

  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
    convert_args
      (p_payroll_action_id
      ,hr_api.g_number
      ,hr_api.g_number
      ,p_action_status
      ,hr_api.g_date
      ,hr_api.g_varchar2
      ,hr_api.g_number
      ,p_p_object_version_number
      ,hr_api.g_varchar2
      ,hr_api.g_varchar2
      ,hr_api.g_varchar2
      );
  --
  -- Having converted the arguments into the
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  upd
    (p_rec                     => l_rec
    ,p_assignment_action_id    => p_assignment_action_id
    ,p_a_object_version_number => p_a_object_version_number
    ,p_validate                => p_validate
    );
  p_p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End upd;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
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
  ) is
--
  l_rec	  g_rec_type;
  l_proc  varchar2(72) := g_package||'ins';
--

Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
    convert_args
      (null
      ,p_business_group_id
      ,p_org_payment_method_id
      ,null
      ,p_effective_date
      ,p_legislative_parameters
      ,p_target_payroll_action_id
      ,null
      ,p_report_type
      ,p_report_qualifier
      ,p_report_category
      );
  --
  -- Having converted the arguments into the pay_qpa_rec
  -- plsql record structure we call the corresponding record business process.
  --
  ins
    (p_rec                     => l_rec
    ,p_assignment_action_id    => p_assignment_action_id
    ,p_a_object_version_number => p_a_object_version_number
    ,p_validate                => p_validate
    );

  --
  -- As the primary key argument(s)
  -- are specified as an OUT's we must set these values.
  --
  p_payroll_action_id       := l_rec.payroll_action_id;
  p_action_status           := l_rec.action_status;
  p_p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End ins;
--

--

end pay_qpa_api;

/
