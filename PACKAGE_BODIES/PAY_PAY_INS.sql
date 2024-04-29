--------------------------------------------------------
--  DDL for Package Body PAY_PAY_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_PAY_INS" as
/* $Header: pypayrhi.pkb 120.0.12000000.3 2007/03/08 09:23:27 mshingan noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  pay_pay_ins.';  -- Global package name
--
-- The following global variables are only to be used by
-- the set_base_key_value and pre_insert procedures.
--
g_payroll_id_i  number   default null;
--
-- ----------------------------------------------------------------------------
-- |------------------------< set_base_key_value >----------------------------|
-- ----------------------------------------------------------------------------
procedure set_base_key_value
  (p_payroll_id  in  number) is
--
  l_proc       varchar2(72) := g_package||'set_base_key_value';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  pay_pay_ins.g_payroll_id_i := p_payroll_id;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 20);
End set_base_key_value;
--
-- ----------------------------------------------------------------------------
-- |------------------------< get_comment_id >-------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--	This function is used to get new comment-id for inserting the comments.
--
-- Prerequisites:
--	This is an internal private function which must be called from the
--	pre_insert and pre_update procedure and must have
--	all mandatory arguments set.This procedure must be called when the
--	comments are not null.
--
-- In Parameters:
--	None.
--
-- Post Success:
--   Returns the new comment id.

-- Post Failure:
--	None.
--
--Developer Implementation Notes:
--   This is an internal call.
--
-- Access Status:
--   Internal Row Handler Use Only.

function get_comment_id return number is
   l_comment_id number;
begin
   select hr_comments_s.nextval
   into   l_comment_id
   from   sys.dual;
   return(l_comment_id);
end get_comment_id;

--
-- ----------------------------------------------------------------------------
-- |----------------------------< dt_insert_dml >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure controls the actual dml insert logic for datetrack. The
--   functions of this procedure are as follows:
--   1) Get the object_version_number.
--   2) To set the effective start and end dates to the corresponding
--      validation start and end dates. Also, the object version number
--      record attribute is set.
--   3) To set and unset the g_api_dml status as required (as we are about to
--      perform dml).
--   4) To insert the row into the schema with the derived effective start
--      and end dates and the object version number.
--   5) To trap any constraint violations that may have occurred.
--   6) To raise any other errors.
--
-- Prerequisites:
--   This is an internal private procedure which must be called from the
--   insert_dml and pre_update (logic permitting) procedure and must have
--   all mandatory arguments set.
--
-- In Parameters:
--   A Pl/Sql record structure.
--
-- Post Success:
--   The specified row will be inserted into the schema.
--
-- Post Failure:
--   On the insert dml failure it is important to note that we always reset the
--   g_api_dml status to false.
--   If a check or unique integrity constraint violation is raised the
--   constraint_error procedure will be called.
--   If any other error is reported, the error will be raised after the
--   g_api_dml status is reset.
--
-- Developer Implementation Notes:
--   This is an internal datetrack maintenance procedure which should
--   not be modified in anyway.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure dt_insert_dml
  (p_rec                     in out nocopy pay_pay_shd.g_rec_type
  ,p_effective_date          in date
  ,p_datetrack_mode          in varchar2
  ,p_validation_start_date   in date
  ,p_validation_end_date     in date
  ) is
-- Cursor to select 'old' created AOL who column values
--
  Cursor C_Sel1 Is
    select t.created_by,
           t.creation_date
    from   pay_all_payrolls_f t
    where  t.payroll_id       = p_rec.payroll_id
    and    t.effective_start_date =
             pay_pay_shd.g_old_rec.effective_start_date
    and    t.effective_end_date   = (p_validation_start_date - 1);
--
  l_proc                varchar2(72) := g_package||'dt_insert_dml';
  l_created_by          pay_all_payrolls_f.created_by%TYPE;
  l_creation_date       pay_all_payrolls_f.creation_date%TYPE ;
  l_last_update_date    pay_all_payrolls_f.last_update_date%TYPE := sysdate;
  l_last_updated_by     pay_all_payrolls_f.last_updated_by%TYPE := fnd_global.user_id;
  l_last_update_login   pay_all_payrolls_f.last_update_login%TYPE := fnd_global.login_id;

  l_effective_start_date    date;
  l_effective_end_date      date;
  c_eot constant date := to_date('4712/12/31','YYYY/MM/DD');
  l_org_pay_method_usage_id  number(16);
  l_status_of_dml boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Set the effective start and end dates to the corresponding
  -- validation start and end dates
  --
  p_rec.effective_start_date := p_validation_start_date;
  p_rec.effective_end_date   := p_validation_end_date;

  l_created_by := l_last_updated_by;
  l_creation_date := l_last_update_date;
  --
  -- If the datetrack_mode is not INSERT then we must populate the WHO
  -- columns with the 'old' creation values and 'new' updated values.
  --
  If (p_datetrack_mode <> hr_api.g_insert) then
    --
    hr_utility.set_location(l_proc, 10);
    --
    -- Get the object version number for the insert
    --
    p_rec.object_version_number :=
    dt_api.get_object_version_number
      (p_base_table_name => 'pay_all_payrolls_f'
      ,p_base_key_column => 'payroll_id'
      ,p_base_key_value  => p_rec.payroll_id
      );
    --
    -- Select the 'old' created values
    --
    Open C_Sel1;
    Fetch C_Sel1 Into l_created_by, l_creation_date;
    If C_Sel1%notfound Then
      --
      -- The previous 'old' created row has not been found. We need
      -- to error as an internal datetrack problem exists.
      --
      Close C_Sel1;
      fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
      fnd_message.set_token('PROCEDURE', l_proc);
      fnd_message.set_token('STEP','10');
      fnd_message.raise_error;
      --
    End If;
    Close C_Sel1;
    --
    -- Set the AOL updated WHO values
    --
    l_last_update_date   := sysdate;
    l_last_updated_by    := fnd_global.user_id;
    l_last_update_login  := fnd_global.login_id;
  Else
    --
    p_rec.object_version_number := 1;  -- Initialise the object version
    --
  End If;
  --
  pay_pay_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Insert the row into: pay_all_payrolls_f
  --
  insert into pay_all_payrolls_f
      (payroll_id
      ,effective_start_date
      ,effective_end_date
      ,default_payment_method_id
      ,business_group_id
      ,consolidation_set_id
      ,cost_allocation_keyflex_id
      ,suspense_account_keyflex_id
      ,gl_set_of_books_id
      ,soft_coding_keyflex_id
      ,period_type
      ,organization_id
      ,cut_off_date_offset
      ,direct_deposit_date_offset
      ,first_period_end_date
      ,negative_pay_allowed_flag
      ,number_of_years
      ,pay_advice_date_offset
      ,pay_date_offset
      ,payroll_name
      ,workload_shifting_level
      ,comment_id
      ,midpoint_offset
      ,attribute_category
      ,attribute1
      ,attribute2
      ,attribute3
      ,attribute4
      ,attribute5
      ,attribute6
      ,attribute7
      ,attribute8
      ,attribute9
      ,attribute10
      ,attribute11
      ,attribute12
      ,attribute13
      ,attribute14
      ,attribute15
      ,attribute16
      ,attribute17
      ,attribute18
      ,attribute19
      ,attribute20
      ,arrears_flag
      ,payroll_type
      ,prl_information_category
      ,prl_information1
      ,prl_information2
      ,prl_information3
      ,prl_information4
      ,prl_information5
      ,prl_information6
      ,prl_information7
      ,prl_information8
      ,prl_information9
      ,prl_information10
      ,prl_information11
      ,prl_information12
      ,prl_information13
      ,prl_information14
      ,prl_information15
      ,prl_information16
      ,prl_information17
      ,prl_information18
      ,prl_information19
      ,prl_information20
      ,prl_information21
      ,prl_information22
      ,prl_information23
      ,prl_information24
      ,prl_information25
      ,prl_information26
      ,prl_information27
      ,prl_information28
      ,prl_information29
      ,prl_information30
      ,multi_assignments_flag
      ,period_reset_years
      ,object_version_number
      ,payslip_view_date_offset
      ,created_by
      ,creation_date
      ,last_update_date
      ,last_updated_by
      ,last_update_login
      )
  Values
    (p_rec.payroll_id
    ,p_rec.effective_start_date
    ,p_rec.effective_end_date
    ,p_rec.default_payment_method_id
    ,p_rec.business_group_id
    ,p_rec.consolidation_set_id
    ,p_rec.cost_allocation_keyflex_id
    ,p_rec.suspense_account_keyflex_id
    ,p_rec.gl_set_of_books_id
    ,p_rec.soft_coding_keyflex_id
    ,p_rec.period_type
    ,p_rec.organization_id
    ,p_rec.cut_off_date_offset
    ,p_rec.direct_deposit_date_offset
    ,p_rec.first_period_end_date
    ,p_rec.negative_pay_allowed_flag
    ,p_rec.number_of_years
    ,p_rec.pay_advice_date_offset
    ,p_rec.pay_date_offset
    ,p_rec.payroll_name
    ,p_rec.workload_shifting_level
    ,p_rec.comment_id
    ,p_rec.midpoint_offset
    ,p_rec.attribute_category
    ,p_rec.attribute1
    ,p_rec.attribute2
    ,p_rec.attribute3
    ,p_rec.attribute4
    ,p_rec.attribute5
    ,p_rec.attribute6
    ,p_rec.attribute7
    ,p_rec.attribute8
    ,p_rec.attribute9
    ,p_rec.attribute10
    ,p_rec.attribute11
    ,p_rec.attribute12
    ,p_rec.attribute13
    ,p_rec.attribute14
    ,p_rec.attribute15
    ,p_rec.attribute16
    ,p_rec.attribute17
    ,p_rec.attribute18
    ,p_rec.attribute19
    ,p_rec.attribute20
    ,p_rec.arrears_flag
    ,p_rec.payroll_type
    ,p_rec.prl_information_category
    ,p_rec.prl_information1
    ,p_rec.prl_information2
    ,p_rec.prl_information3
    ,p_rec.prl_information4
    ,p_rec.prl_information5
    ,p_rec.prl_information6
    ,p_rec.prl_information7
    ,p_rec.prl_information8
    ,p_rec.prl_information9
    ,p_rec.prl_information10
    ,p_rec.prl_information11
    ,p_rec.prl_information12
    ,p_rec.prl_information13
    ,p_rec.prl_information14
    ,p_rec.prl_information15
    ,p_rec.prl_information16
    ,p_rec.prl_information17
    ,p_rec.prl_information18
    ,p_rec.prl_information19
    ,p_rec.prl_information20
    ,p_rec.prl_information21
    ,p_rec.prl_information22
    ,p_rec.prl_information23
    ,p_rec.prl_information24
    ,p_rec.prl_information25
    ,p_rec.prl_information26
    ,p_rec.prl_information27
    ,p_rec.prl_information28
    ,p_rec.prl_information29
    ,p_rec.prl_information30
    ,p_rec.multi_assignments_flag
    ,p_rec.period_reset_years
    ,p_rec.object_version_number
    ,p_rec.payslip_view_date_offset
    ,l_created_by
    ,l_creation_date
    ,l_last_update_date
    ,l_last_updated_by
    ,l_last_update_login
    );
  --
  --Storing the result of the above DML operation.
  l_status_of_dml:=SQL%NOTFOUND;

  pay_pay_shd.g_api_dml := false;   -- Unset the api dml status

  --Checking the status of the above dml operation.
  if (l_status_of_dml) then
      --
      hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
      hr_utility.set_message_token('PROCEDURE',
                                 'pay_payrolls_f_pkg.insert_row');
      hr_utility.set_message_token('STEP','1');
      hr_utility.raise_error;
      --
    End if;
    --
  hr_utility.set_location(' Leaving:'||l_proc, 25);
--
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    pay_pay_shd.g_api_dml := false;   -- Unset the api dml status
    pay_pay_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    pay_pay_shd.g_api_dml := false;   -- Unset the api dml status
    pay_pay_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    pay_pay_shd.g_api_dml := false;   -- Unset the api dml status
    Raise;
End dt_insert_dml;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< insert_dml >------------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_dml
  (p_rec                   in out nocopy pay_pay_shd.g_rec_type
  ,p_effective_date        in date
  ,p_datetrack_mode        in varchar2
  ,p_validation_start_date in date
  ,p_validation_end_date   in date
  ) is
--
  l_proc        varchar2(72) := g_package||'insert_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  pay_pay_ins.dt_insert_dml
    (p_rec                   => p_rec
    ,p_effective_date        => p_effective_date
    ,p_datetrack_mode        => p_datetrack_mode
    ,p_validation_start_date => p_validation_start_date
    ,p_validation_end_date   => p_validation_end_date
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_dml;
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
--   Also, if comments are defined for this entity, the comments insert
--   logic will also be called, generating a comment_id if required.
--
-- Prerequisites:
--   This is an internal procedure which is called from the ins procedure.
--
-- In Parameters:
--   A Pl/Sql record structure.
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   If an error has occurred, an error message and exception will be raised
--   but not handled.
--
-- Developer Implementation Notes:
--   Any pre-processing required before the insert dml is issued should be
--   coded within this procedure. As stated above, a good example is the
--   generation of a primary key number via a corresponding sequence.
--   It is important to note that any 3rd party maintenance should be reviewed
--   before placing in this procedure.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure pre_insert
  (p_rec                   in out nocopy pay_pay_shd.g_rec_type
  ,p_effective_date        in date
  ,p_datetrack_mode        in varchar2
  ,p_validation_start_date in date
  ,p_validation_end_date   in date
  ) is
--
  Cursor C_Sel1 is select pay_payrolls_s.nextval from sys.dual;
--
 Cursor C_Sel2 is
    Select null
      from pay_all_payrolls_f
     where payroll_id =
             pay_pay_ins.g_payroll_id_i;
--
  l_proc        varchar2(72) := g_package||'pre_insert';
  l_exists      varchar2(1);
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
    If (pay_pay_ins.g_payroll_id_i is not null) Then
    --
    -- Verify registered primary key values not already in use
    --
    Open C_Sel2;
    Fetch C_Sel2 into l_exists;
    If C_Sel2%found Then
       --
       Close C_Sel2;
       --
       -- The primary key values are already in use.
       --
       fnd_message.set_name('PER','PER_289391_KEY_ALREADY_USED');
       fnd_message.set_token('TABLE_NAME','pay_all_payrolls_f');
       fnd_message.raise_error;
       --
    End If;
    Close C_Sel2;
    --
    -- Use registered key values and clear globals
    --
    p_rec.payroll_id := pay_pay_ins.g_payroll_id_i;
    pay_pay_ins.g_payroll_id_i := null;
  Else
    --
    -- No registerd key values, so select the next sequence number
    --
    -- Select the next sequence number
    --
    Open C_Sel1;
    Fetch C_Sel1 Into p_rec.payroll_id;
    Close C_Sel1;
    --
  End If;
  --

  -- Insert the comment text if comments exist.
  --
  If (p_rec.comments is not null) then
    --
    p_rec.comment_id :=get_comment_id();
    hr_comm_api.ins
      (p_comment_id        => p_rec.comment_id
      ,p_source_table_name => 'PAY_ALL_PAYROLLS_F'
      ,p_comment_text      => p_rec.comments
      );
    --
  End If;

  -- Default the Midpoint Offset

   If (p_rec.period_type = 'Semi-Month') then
      --
      p_rec.midpoint_offset := -15;
      --
   Else
      --
      p_rec.midpoint_offset := 0;
      --
   End If;

  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
End pre_insert;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< post_insert >-------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This private procedure contains any processing which is required after
--   the insert dml.
--
-- Prerequisites:
--   This is an internal procedure which is called from the ins procedure.
--
-- In Parameters:
--   A Pl/Sql record structure.
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   If an error has occurred, an error message and exception will be raised
--   but not handled.
--
-- Developer Implementation Notes:
--   Any post-processing required after the insert dml is issued should be
--   coded within this procedure. It is important to note that any 3rd party
--   maintenance should be reviewed before placing in this procedure.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure post_insert
  (p_rec                   in pay_pay_shd.g_rec_type
  ,p_effective_date        in date
  ,p_datetrack_mode        in varchar2
  ,p_validation_start_date in date
  ,p_validation_end_date   in date
  ) is
--
  l_proc        varchar2(72) := g_package||'post_insert';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  begin
    --
    pay_pay_rki.after_insert
      (p_effective_date
      => p_effective_date
      ,p_validation_start_date
      => p_validation_start_date
      ,p_validation_end_date
      => p_validation_end_date
      ,p_payroll_id
      => p_rec.payroll_id
      ,p_effective_start_date
      => p_rec.effective_start_date
      ,p_effective_end_date
      => p_rec.effective_end_date
      ,p_default_payment_method_id
      => p_rec.default_payment_method_id
      ,p_business_group_id
      => p_rec.business_group_id
      ,p_consolidation_set_id
      => p_rec.consolidation_set_id
      ,p_cost_allocation_keyflex_id
      => p_rec.cost_allocation_keyflex_id
      ,p_suspense_account_keyflex_id
      => p_rec.suspense_account_keyflex_id
      ,p_gl_set_of_books_id
      => p_rec.gl_set_of_books_id
      ,p_soft_coding_keyflex_id
      => p_rec.soft_coding_keyflex_id
      ,p_period_type
      => p_rec.period_type
      ,p_organization_id
      => p_rec.organization_id
      ,p_cut_off_date_offset
      => p_rec.cut_off_date_offset
      ,p_direct_deposit_date_offset
      => p_rec.direct_deposit_date_offset
      ,p_first_period_end_date
      => p_rec.first_period_end_date
      ,p_negative_pay_allowed_flag
      => p_rec.negative_pay_allowed_flag
      ,p_number_of_years
      => p_rec.number_of_years
      ,p_pay_advice_date_offset
      => p_rec.pay_advice_date_offset
      ,p_pay_date_offset
      => p_rec.pay_date_offset
      ,p_payroll_name
      => p_rec.payroll_name
      ,p_workload_shifting_level
      => p_rec.workload_shifting_level
      ,p_comment_id
      => p_rec.comment_id
      ,p_comments
      => p_rec.comments
      ,p_midpoint_offset
      => p_rec.midpoint_offset
      ,p_attribute_category
      => p_rec.attribute_category
      ,p_attribute1
      => p_rec.attribute1
      ,p_attribute2
      => p_rec.attribute2
      ,p_attribute3
      => p_rec.attribute3
      ,p_attribute4
      => p_rec.attribute4
      ,p_attribute5
      => p_rec.attribute5
      ,p_attribute6
      => p_rec.attribute6
      ,p_attribute7
      => p_rec.attribute7
      ,p_attribute8
      => p_rec.attribute8
      ,p_attribute9
      => p_rec.attribute9
      ,p_attribute10
      => p_rec.attribute10
      ,p_attribute11
      => p_rec.attribute11
      ,p_attribute12
      => p_rec.attribute12
      ,p_attribute13
      => p_rec.attribute13
      ,p_attribute14
      => p_rec.attribute14
      ,p_attribute15
      => p_rec.attribute15
      ,p_attribute16
      => p_rec.attribute16
      ,p_attribute17
      => p_rec.attribute17
      ,p_attribute18
      => p_rec.attribute18
      ,p_attribute19
      => p_rec.attribute19
      ,p_attribute20
      => p_rec.attribute20
      ,p_arrears_flag
      => p_rec.arrears_flag
      ,p_payroll_type
      => p_rec.payroll_type
      ,p_prl_information_category
      => p_rec.prl_information_category
      ,p_prl_information1
      => p_rec.prl_information1
      ,p_prl_information2
      => p_rec.prl_information2
      ,p_prl_information3
      => p_rec.prl_information3
      ,p_prl_information4
      => p_rec.prl_information4
      ,p_prl_information5
      => p_rec.prl_information5
      ,p_prl_information6
      => p_rec.prl_information6
      ,p_prl_information7
      => p_rec.prl_information7
      ,p_prl_information8
      => p_rec.prl_information8
      ,p_prl_information9
      => p_rec.prl_information9
      ,p_prl_information10
      => p_rec.prl_information10
      ,p_prl_information11
      => p_rec.prl_information11
      ,p_prl_information12
      => p_rec.prl_information12
      ,p_prl_information13
      => p_rec.prl_information13
      ,p_prl_information14
      => p_rec.prl_information14
      ,p_prl_information15
      => p_rec.prl_information15
      ,p_prl_information16
      => p_rec.prl_information16
      ,p_prl_information17
      => p_rec.prl_information17
      ,p_prl_information18
      => p_rec.prl_information18
      ,p_prl_information19
      => p_rec.prl_information19
      ,p_prl_information20
      => p_rec.prl_information20
      ,p_prl_information21
      => p_rec.prl_information21
      ,p_prl_information22
      => p_rec.prl_information22
      ,p_prl_information23
      => p_rec.prl_information23
      ,p_prl_information24
      => p_rec.prl_information24
      ,p_prl_information25
      => p_rec.prl_information25
      ,p_prl_information26
      => p_rec.prl_information26
      ,p_prl_information27
      => p_rec.prl_information27
      ,p_prl_information28
      => p_rec.prl_information28
      ,p_prl_information29
      => p_rec.prl_information29
      ,p_prl_information30
      => p_rec.prl_information30
      ,p_multi_assignments_flag
      => p_rec.multi_assignments_flag
      ,p_period_reset_years
      => p_rec.period_reset_years
      ,p_object_version_number
      => p_rec.object_version_number
      ,p_payslip_view_date_offset
      => p_rec.payslip_view_date_offset
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PAY_ALL_PAYROLLS_F'
        ,p_hook_type   => 'AI');
      --
  end;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End post_insert;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< ins_lck >--------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   The ins_lck process has one main function to perform. When inserting
--   a datetracked row, we must validate the DT mode.
--
-- Prerequisites:
--   This procedure can only be called for the datetrack mode of INSERT.
--
-- In Parameters:
--
-- Post Success:
--   On successful completion of the ins_lck process the parental
--   datetracked rows will be locked providing the p_enforce_foreign_locking
--   argument value is TRUE.
--   If the p_enforce_foreign_locking argument value is FALSE then the
--   parential rows are not locked.
--
-- Post Failure:
--   The Lck process can fail for:
--   1) When attempting to lock the row the row could already be locked by
--      another user. This will raise the HR_Api.Object_Locked exception.
--   2) When attempting to the lock the parent which doesn't exist.
--      For the entity to be locked the parent must exist!
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure ins_lck
  (p_effective_date        in date
  ,p_datetrack_mode        in varchar2
  ,p_rec                   in pay_pay_shd.g_rec_type
  ,p_validation_start_date out nocopy date
  ,p_validation_end_date   out nocopy date
  ) is
--
  l_proc                  varchar2(72) := g_package||'ins_lck';
  l_validation_start_date date;
  l_validation_end_date   date;

  l_effective_date          date;
  l_first_period_end_date   date;

--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);

  l_effective_date        := trunc(p_effective_date);
  l_first_period_end_date := trunc(p_rec.first_period_end_date);

  hr_api.mandatory_arg_error
     (p_api_name       => l_proc
     ,p_argument       => 'effective_date'
     ,p_argument_value => l_effective_date
     );

   hr_utility.set_location(l_proc, 20);
   hr_api.mandatory_arg_error
     (p_api_name       => l_proc
     ,p_argument       => 'payroll_name'
     ,p_argument_value => p_rec.payroll_name
     );

   hr_utility.set_location(l_proc, 30);
   hr_api.mandatory_arg_error
     (p_api_name       => l_proc
     ,p_argument       => 'period_type'
     ,p_argument_value => p_rec.period_type
     );

   hr_utility.set_location(l_proc, 40);
   hr_api.mandatory_arg_error
     (p_api_name       => l_proc
     ,p_argument       => 'first_period_end_date'
     ,p_argument_value => l_first_period_end_date
     );

   hr_api.mandatory_arg_error
     (p_api_name       => l_proc
     ,p_argument       => 'number_of_years'
     ,p_argument_value => p_rec.number_of_years
     );

   hr_api.mandatory_arg_error
     (p_api_name       => l_proc
     ,p_argument       => 'consolidation_set_id'
     ,p_argument_value => p_rec.consolidation_set_id
     );

  --
  -- Validate the datetrack mode mode getting the validation start
  -- and end dates for the specified datetrack operation.
  --
  dt_api.validate_dt_mode
      (p_effective_date             => p_effective_date
      ,p_datetrack_mode             => p_datetrack_mode
      ,p_base_table_name            => 'pay_all_payrolls_f'
      ,p_base_key_column            => 'payroll_id'
      ,p_base_key_value             => p_rec.payroll_id

      ,p_parent_table_name1         => 'pay_org_payment_methods_f'
      ,p_parent_key_column1         => 'org_payment_method_id'
      ,p_parent_key_value1          => pay_pay_shd.g_old_rec.default_payment_method_id

      ,p_child_table_name1          => 'per_all_assignments_f'
      ,p_child_key_column1          => 'assignment_id'
      ,p_child_alt_base_key_column1 => 'payroll_id'

      ,p_child_table_name2          => 'pay_element_links_f'
      ,p_child_key_column2          => 'element_link_id'
      ,p_child_alt_base_key_column2 => 'payroll_id'

      ,p_child_table_name3          => 'hr_all_positions_f'
      ,p_child_key_column3	    => 'position_id'
      ,p_child_alt_base_key_column3 => 'pay_freq_payroll_id'

      ,p_enforce_foreign_locking    => true
      ,p_validation_start_date      => l_validation_start_date
      ,p_validation_end_date        => l_validation_end_date
      );
  --
  -- Set the validation start and end date OUT arguments
  --
  p_validation_start_date := l_validation_start_date;
  p_validation_end_date   := l_validation_end_date;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  --
End ins_lck;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (p_effective_date in     date
  ,p_rec            in out nocopy pay_pay_shd.g_rec_type
  ) is
--
  l_proc                        varchar2(72) := g_package||'ins';
  l_datetrack_mode              varchar2(30) := hr_api.g_insert;
  l_validation_start_date       date;
  l_validation_end_date         date;
  l_business_group_id           number(15);
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);

  --
  -- Call the lock operation
  --
  pay_pay_ins.ins_lck
    (p_effective_date        => p_effective_date
    ,p_datetrack_mode        => l_datetrack_mode
    ,p_rec                   => p_rec
    ,p_validation_start_date => l_validation_start_date
    ,p_validation_end_date   => l_validation_end_date
    );
  --
  -- Call the supporting insert validate operations
  --
  pay_pay_bus.insert_validate
    (p_rec                   => p_rec
    ,p_effective_date        => p_effective_date
    ,p_datetrack_mode        => l_datetrack_mode
    ,p_validation_start_date => l_validation_start_date
    ,p_validation_end_date   => l_validation_end_date
    );
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
  -- Call the supporting pre-insert operation
  --
  pay_pay_ins.pre_insert
    (p_rec                   => p_rec
    ,p_effective_date        => p_effective_date
    ,p_datetrack_mode        => l_datetrack_mode
    ,p_validation_start_date => l_validation_start_date
    ,p_validation_end_date   => l_validation_end_date
    );
  --
  -- Insert the row
  --
  pay_pay_ins.insert_dml
    (p_rec                   => p_rec
    ,p_effective_date        => p_effective_date
    ,p_datetrack_mode        => l_datetrack_mode
    ,p_validation_start_date => l_validation_start_date
    ,p_validation_end_date   => l_validation_end_date
    );
  --
  -- Call the supporting post-insert operation
  --
  pay_pay_ins.post_insert
    (p_rec                   => p_rec
    ,p_effective_date        => p_effective_date
    ,p_datetrack_mode        => l_datetrack_mode
    ,p_validation_start_date => l_validation_start_date
    ,p_validation_end_date   => l_validation_end_date
    );
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
end ins;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (p_effective_date                 in     date
  ,p_consolidation_set_id           in     number
  ,p_period_type                    in     varchar2
  ,p_cut_off_date_offset            in     number default 0 --Added default as per the old API
  ,p_direct_deposit_date_offset     in     number default 0 --Added default as per the old API
  ,p_first_period_end_date          in     date
  ,p_negative_pay_allowed_flag      in     varchar2 default 'N' --Added default as per the old API
  ,p_number_of_years                in     number
  ,p_pay_advice_date_offset         in     number default 0 --Added  default as per the old API
  ,p_pay_date_offset                in     number default 0 --Added  default as per the old API.
  ,p_payroll_name                   in     varchar2
  ,p_workload_shifting_level        in     varchar2 default 'N' --Added default.
  ,p_default_payment_method_id      in     number   default null
  ,p_cost_allocation_keyflex_id     in     number   default null
  ,p_suspense_account_keyflex_id    in     number   default null
  ,p_gl_set_of_books_id             in     number   default null
  ,p_soft_coding_keyflex_id         in     number   default null
  ,p_organization_id                in     number   default null
  ,p_comments                       in     varchar2 default null
  ,p_midpoint_offset                in     number   default null
  ,p_attribute_category             in     varchar2 default null
  ,p_attribute1                     in     varchar2 default null
  ,p_attribute2                     in     varchar2 default null
  ,p_attribute3                     in     varchar2 default null
  ,p_attribute4                     in     varchar2 default null
  ,p_attribute5                     in     varchar2 default null
  ,p_attribute6                     in     varchar2 default null
  ,p_attribute7                     in     varchar2 default null
  ,p_attribute8                     in     varchar2 default null
  ,p_attribute9                     in     varchar2 default null
  ,p_attribute10                    in     varchar2 default null
  ,p_attribute11                    in     varchar2 default null
  ,p_attribute12                    in     varchar2 default null
  ,p_attribute13                    in     varchar2 default null
  ,p_attribute14                    in     varchar2 default null
  ,p_attribute15                    in     varchar2 default null
  ,p_attribute16                    in     varchar2 default null
  ,p_attribute17                    in     varchar2 default null
  ,p_attribute18                    in     varchar2 default null
  ,p_attribute19                    in     varchar2 default null
  ,p_attribute20                    in     varchar2 default null
  ,p_arrears_flag                   in     varchar2 default null
  ,p_payroll_type                   in     varchar2 default null
  ,p_prl_information_category       in     varchar2 default null
  ,p_prl_information1               in     varchar2 default null
  ,p_prl_information2               in     varchar2 default null
  ,p_prl_information3               in     varchar2 default null
  ,p_prl_information4               in     varchar2 default null
  ,p_prl_information5               in     varchar2 default null
  ,p_prl_information6               in     varchar2 default null
  ,p_prl_information7               in     varchar2 default null
  ,p_prl_information8               in     varchar2 default null
  ,p_prl_information9               in     varchar2 default null
  ,p_prl_information10              in     varchar2 default null
  ,p_prl_information11              in     varchar2 default null
  ,p_prl_information12              in     varchar2 default null
  ,p_prl_information13              in     varchar2 default null
  ,p_prl_information14              in     varchar2 default null
  ,p_prl_information15              in     varchar2 default null
  ,p_prl_information16              in     varchar2 default null
  ,p_prl_information17              in     varchar2 default null
  ,p_prl_information18              in     varchar2 default null
  ,p_prl_information19              in     varchar2 default null
  ,p_prl_information20              in     varchar2 default null
  ,p_prl_information21              in     varchar2 default null
  ,p_prl_information22              in     varchar2 default null
  ,p_prl_information23              in     varchar2 default null
  ,p_prl_information24              in     varchar2 default null
  ,p_prl_information25              in     varchar2 default null
  ,p_prl_information26              in     varchar2 default null
  ,p_prl_information27              in     varchar2 default null
  ,p_prl_information28              in     varchar2 default null
  ,p_prl_information29              in     varchar2 default null
  ,p_prl_information30              in     varchar2 default null
  ,p_multi_assignments_flag         in     varchar2 default null
  ,p_period_reset_years             in     varchar2 default null
  ,p_payslip_view_date_offset       in     number   default null
  ,p_payroll_id                        out nocopy number
  ,p_object_version_number             out nocopy number
  ,p_effective_start_date              out nocopy date
  ,p_effective_end_date                out nocopy date
  ,p_comment_id                        out nocopy number
  ) is
--
  l_rec         pay_pay_shd.g_rec_type;
  l_proc        varchar2(72) := g_package||'ins';
  l_effective_date          date;
  l_first_period_end_date   date;

--
Begin

  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  pay_pay_shd.convert_args
    (null
    ,null
    ,null
    ,p_default_payment_method_id
    ,null --p_business_group_id
    ,p_consolidation_set_id
    ,p_cost_allocation_keyflex_id
    ,p_suspense_account_keyflex_id
    ,p_gl_set_of_books_id
    ,p_soft_coding_keyflex_id
    ,p_period_type
    ,p_organization_id
    ,p_cut_off_date_offset
    ,p_direct_deposit_date_offset
    ,p_first_period_end_date
    ,p_negative_pay_allowed_flag
    ,p_number_of_years
    ,p_pay_advice_date_offset
    ,p_pay_date_offset
    ,p_payroll_name
    ,p_workload_shifting_level
    ,null
    ,p_comments
    ,p_midpoint_offset
    ,p_attribute_category
    ,p_attribute1
    ,p_attribute2
    ,p_attribute3
    ,p_attribute4
    ,p_attribute5
    ,p_attribute6
    ,p_attribute7
    ,p_attribute8
    ,p_attribute9
    ,p_attribute10
    ,p_attribute11
    ,p_attribute12
    ,p_attribute13
    ,p_attribute14
    ,p_attribute15
    ,p_attribute16
    ,p_attribute17
    ,p_attribute18
    ,p_attribute19
    ,p_attribute20
    ,p_arrears_flag
    ,p_payroll_type
    ,p_prl_information_category
    ,p_prl_information1
    ,p_prl_information2
    ,p_prl_information3
    ,p_prl_information4
    ,p_prl_information5
    ,p_prl_information6
    ,p_prl_information7
    ,p_prl_information8
    ,p_prl_information9
    ,p_prl_information10
    ,p_prl_information11
    ,p_prl_information12
    ,p_prl_information13
    ,p_prl_information14
    ,p_prl_information15
    ,p_prl_information16
    ,p_prl_information17
    ,p_prl_information18
    ,p_prl_information19
    ,p_prl_information20
    ,p_prl_information21
    ,p_prl_information22
    ,p_prl_information23
    ,p_prl_information24
    ,p_prl_information25
    ,p_prl_information26
    ,p_prl_information27
    ,p_prl_information28
    ,p_prl_information29
    ,p_prl_information30
    ,p_multi_assignments_flag
    ,p_period_reset_years
    ,NULL --p_object_version_number
    ,p_payslip_view_date_offset
    );
  --
  -- Having converted the arguments into the pay_pay_rec
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  pay_pay_ins.ins
    (p_effective_date
    ,l_rec
    );
  --
  -- Set the OUT arguments.
  --
  p_payroll_id                       := l_rec.payroll_id;
  p_effective_start_date             := l_rec.effective_start_date;
  p_effective_end_date               := l_rec.effective_end_date;
  p_object_version_number            := l_rec.object_version_number;
  p_comment_id                       := l_rec.comment_id;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End ins;
--
end pay_pay_ins;

/
