--------------------------------------------------------
--  DDL for Package Body PAY_PAY_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_PAY_UPD" as
/* $Header: pypayrhi.pkb 120.0.12000000.3 2007/03/08 09:23:27 mshingan noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  pay_pay_upd.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |----------------------------< dt_update_dml >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure controls the execution of dml from the datetrack mode
--   of CORRECTION only. It is important to note that the object version
--   number is only increment by 1 because the datetrack correction is
--   soley for one datetracked row.
--   This procedure controls the actual dml update logic. The functions of
--   this procedure are as follows:
--   1) Get the next object_version_number.
--   2) To set and unset the g_api_dml status as required (as we are about to
--      perform dml).
--   3) To update the specified row in the schema using the primary key in
--      the predicates.
--   4) To trap any constraint violations that may have occurred.
--   5) To raise any other errors.
--
-- Prerequisites:
--   This is an internal private procedure which must be called from the
--   update_dml procedure.
--
-- In Parameters:
--   A Pl/Sql record structure.
--
-- Post Success:
--   The specified row will be updated in the schema.
--
-- Post Failure:
--   On the update dml failure it is important to note that we always reset the
--   g_api_dml status to false.
--   If a check or unique integrity constraint violation is raised the
--   constraint_error procedure will be called.
--   If any other error is reported, the error will be raised after the
--   g_api_dml status is reset.
--
-- Developer Implementation Notes:
--   The update 'set' arguments list should be modified if any of your
--   attributes are not updateable.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure dt_update_dml
  (p_rec                   in out nocopy pay_pay_shd.g_rec_type
  ,p_effective_date        in date
  ,p_datetrack_mode        in varchar2
  ,p_validation_start_date in date
  ,p_validation_end_date   in date
  ) is
--
  l_proc        varchar2(72) := g_package||'dt_update_dml';
  l_status_of_dml boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (p_datetrack_mode = hr_api.g_correction) then
    --
    hr_utility.set_location(l_proc, 10);
    hr_utility.trace('In CORRECTION , p_effective_date : '||to_char(p_effective_date));
    --
    -- Because we are updating a row we must get the next object
    -- version number.
    --
    p_rec.object_version_number :=
      dt_api.get_object_version_number
        (p_base_table_name => 'pay_all_payrolls_f'
        ,p_base_key_column => 'payroll_id'
        ,p_base_key_value  => p_rec.payroll_id
        );
    --
    pay_pay_shd.g_api_dml := true;  -- Set the api dml status
    --
    -- Update the pay_all_payrolls_f Row
    --
    update  pay_all_payrolls_f
    set
     payroll_id                           = p_rec.payroll_id
    ,default_payment_method_id            = p_rec.default_payment_method_id
    ,business_group_id                    = p_rec.business_group_id
    ,consolidation_set_id                 = p_rec.consolidation_set_id
    ,cost_allocation_keyflex_id           = p_rec.cost_allocation_keyflex_id
    ,suspense_account_keyflex_id          = p_rec.suspense_account_keyflex_id
    ,gl_set_of_books_id                   = p_rec.gl_set_of_books_id
    ,soft_coding_keyflex_id               = p_rec.soft_coding_keyflex_id
    ,period_type                          = p_rec.period_type
    ,organization_id                      = p_rec.organization_id
    ,cut_off_date_offset                  = p_rec.cut_off_date_offset
    ,direct_deposit_date_offset           = p_rec.direct_deposit_date_offset
    ,first_period_end_date                = p_rec.first_period_end_date
    ,negative_pay_allowed_flag            = p_rec.negative_pay_allowed_flag
    ,number_of_years                      = p_rec.number_of_years
    ,pay_advice_date_offset               = p_rec.pay_advice_date_offset
    ,pay_date_offset                      = p_rec.pay_date_offset
    ,payroll_name                         = p_rec.payroll_name
    ,workload_shifting_level              = p_rec.workload_shifting_level
    ,comment_id                           = p_rec.comment_id
    ,midpoint_offset                      = p_rec.midpoint_offset
    ,attribute_category                   = p_rec.attribute_category
    ,attribute1                           = p_rec.attribute1
    ,attribute2                           = p_rec.attribute2
    ,attribute3                           = p_rec.attribute3
    ,attribute4                           = p_rec.attribute4
    ,attribute5                           = p_rec.attribute5
    ,attribute6                           = p_rec.attribute6
    ,attribute7                           = p_rec.attribute7
    ,attribute8                           = p_rec.attribute8
    ,attribute9                           = p_rec.attribute9
    ,attribute10                          = p_rec.attribute10
    ,attribute11                          = p_rec.attribute11
    ,attribute12                          = p_rec.attribute12
    ,attribute13                          = p_rec.attribute13
    ,attribute14                          = p_rec.attribute14
    ,attribute15                          = p_rec.attribute15
    ,attribute16                          = p_rec.attribute16
    ,attribute17                          = p_rec.attribute17
    ,attribute18                          = p_rec.attribute18
    ,attribute19                          = p_rec.attribute19
    ,attribute20                          = p_rec.attribute20
    ,arrears_flag                         = p_rec.arrears_flag
    ,payroll_type                         = p_rec.payroll_type
    ,prl_information_category             = p_rec.prl_information_category
    ,prl_information1                     = p_rec.prl_information1
    ,prl_information2                     = p_rec.prl_information2
    ,prl_information3                     = p_rec.prl_information3
    ,prl_information4                     = p_rec.prl_information4
    ,prl_information5                     = p_rec.prl_information5
    ,prl_information6                     = p_rec.prl_information6
    ,prl_information7                     = p_rec.prl_information7
    ,prl_information8                     = p_rec.prl_information8
    ,prl_information9                     = p_rec.prl_information9
    ,prl_information10                    = p_rec.prl_information10
    ,prl_information11                    = p_rec.prl_information11
    ,prl_information12                    = p_rec.prl_information12
    ,prl_information13                    = p_rec.prl_information13
    ,prl_information14                    = p_rec.prl_information14
    ,prl_information15                    = p_rec.prl_information15
    ,prl_information16                    = p_rec.prl_information16
    ,prl_information17                    = p_rec.prl_information17
    ,prl_information18                    = p_rec.prl_information18
    ,prl_information19                    = p_rec.prl_information19
    ,prl_information20                    = p_rec.prl_information20
    ,prl_information21                    = p_rec.prl_information21
    ,prl_information22                    = p_rec.prl_information22
    ,prl_information23                    = p_rec.prl_information23
    ,prl_information24                    = p_rec.prl_information24
    ,prl_information25                    = p_rec.prl_information25
    ,prl_information26                    = p_rec.prl_information26
    ,prl_information27                    = p_rec.prl_information27
    ,prl_information28                    = p_rec.prl_information28
    ,prl_information29                    = p_rec.prl_information29
    ,prl_information30                    = p_rec.prl_information30
    ,multi_assignments_flag               = p_rec.multi_assignments_flag
    ,period_reset_years                   = p_rec.period_reset_years
    ,object_version_number                = p_rec.object_version_number
    ,payslip_view_date_offset             = p_rec.payslip_view_date_offset
    where   payroll_id = p_rec.payroll_id
    and     effective_start_date = p_validation_start_date
    and     effective_end_date   = p_validation_end_date;
    --
    --Storing the status of the above dml operation.
    l_status_of_dml := SQL%NOTFOUND;
    pay_pay_shd.g_api_dml := false;   -- Unset the api dml status
    --
    -- Set the effective start and end dates
    --
    p_rec.effective_start_date := p_validation_start_date;
    p_rec.effective_end_date   := p_validation_end_date;
    --
    if (l_status_of_dml) then
      --
      hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
      hr_utility.set_message_token('PROCEDURE',
                                 'pay_payrolls_f_pkg.update_row');
      hr_utility.set_message_token('STEP','1');
      hr_utility.raise_error;
      --
    End if;
    --
  End If;
--
hr_utility.set_location(' Leaving:'||l_proc, 15);
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
End dt_update_dml;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< update_dml >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure calls the dt_update_dml control logic which handles
--   the actual datetrack dml.
--
-- Prerequisites:
--   This is an internal private procedure which must be called from the upd
--   procedure.
--
-- In Parameters:
--   A Pl/Sql record structre.
--
-- Post Success:
--   Processing contines.
--
-- Post Failure:
--   No specific error handling is required within this procedure.
--
-- Developer Implementation Notes:
--   The update 'set' arguments list should be modified if any of your
--   attributes are not updateable.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure update_dml
  (p_rec                      in out nocopy pay_pay_shd.g_rec_type
  ,p_effective_date           in date
  ,p_datetrack_mode           in varchar2
  ,p_validation_start_date    in date
  ,p_validation_end_date      in date
  ) is
--
  l_proc        varchar2(72) := g_package||'update_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  pay_pay_upd.dt_update_dml
    (p_rec                   => p_rec
    ,p_effective_date        => p_effective_date
    ,p_datetrack_mode        => p_datetrack_mode
    ,p_validation_start_date => p_validation_start_date
    ,p_validation_end_date   => p_validation_end_date
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_dml;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< dt_pre_update >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   The dt_pre_update procedure controls the execution
--   of dml for the datetrack modes of: UPDATE, UPDATE_OVERRIDE
--   and UPDATE_CHANGE_INSERT only. The execution required is as
--   follows:
--
--   1) Providing the datetrack update mode is not 'CORRECTION'
--      then set the effective end date of the current row (this
--      will be the validation_start_date - 1).
--   2) If the datetrack mode is 'UPDATE_OVERRIDE' then call the
--      corresponding delete_dml process to delete any future rows
--      where the effective_start_date is greater than or equal to
--      the validation_start_date.
--   3) Call the insert_dml process to insert the new updated row
--      details.
--
-- Prerequisites:
--   This is an internal procedure which is called from the
--   pre_update procedure.
--
-- In Parameters:
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   If an error has occurred, an error message and exception will be raised
--   but not handled.
--
-- Developer Implementation Notes:
--   This is an internal procedure which is required by Datetrack. Don't
--   remove or modify.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure dt_pre_update
  (p_rec                     in out  nocopy   pay_pay_shd.g_rec_type
  ,p_effective_date          in date
  ,p_datetrack_mode          in varchar2
  ,p_validation_start_date   in date
  ,p_validation_end_date     in date
  ) is
--
  l_proc                 varchar2(72) := g_package||'dt_pre_update';
  l_dummy_version_number number;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  If (p_datetrack_mode <> hr_api.g_correction) then
    --
    -- Update the current effective end date
    --
    pay_pay_shd.upd_effective_end_date
      (p_effective_date         => p_effective_date
      ,p_base_key_value         => p_rec.payroll_id
      ,p_new_effective_end_date => (p_validation_start_date - 1)
      ,p_validation_start_date  => p_validation_start_date
      ,p_validation_end_date    => p_validation_end_date
      ,p_object_version_number  => l_dummy_version_number
      );
    --
    If (p_datetrack_mode = hr_api.g_update_override) then
      --
      -- As the datetrack mode is 'UPDATE_OVERRIDE' then we must
      -- delete any future rows
      --
    pay_pay_del.delete_dml
        (p_rec                   => p_rec
        ,p_effective_date        => p_effective_date
        ,p_datetrack_mode        => p_datetrack_mode
        ,p_validation_start_date => p_validation_start_date
        ,p_validation_end_date   => p_validation_end_date
        );
      --
    End If;
    --
    -- We must now insert the updated row
    --
    pay_pay_ins.insert_dml
      (p_rec                    => p_rec
      ,p_effective_date         => p_effective_date
      ,p_datetrack_mode         => p_datetrack_mode
      ,p_validation_start_date  => p_validation_start_date
      ,p_validation_end_date    => p_validation_end_date
      );
  End If;
  hr_utility.set_location(' Leaving:'||l_proc, 20);

  Exception
  When Others Then
    pay_pay_shd.g_api_dml := false;   -- Unset the api dml status
    Raise;
--
End dt_pre_update;
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
-- Prerequisites:
--   This is an internal procedure which is called from the upd procedure.
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
-- Developer Implementation Notes:
--   Any pre-processing required before the update dml is issued should be
--   coded within this procedure. It is important to note that any 3rd party
--   maintenance should be reviewed before placing in this procedure. The call
--   to the dt_update_dml procedure should NOT be removed.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure pre_update
  (p_rec                   in out nocopy pay_pay_shd.g_rec_type
  ,p_effective_date        in date
  ,p_datetrack_mode        in varchar2
  ,p_validation_start_date in date
  ,p_validation_end_date   in date
  ) is
--
  l_proc        varchar2(72) := g_package||'pre_update';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  -- Insert the comment text if comments exist
  --
  If (p_rec.comments is not null and p_rec.comment_id is null) then
     --
     hr_comm_api.ins(p_comment_id        => p_rec.comment_id
                    ,p_source_table_name => 'PAY_ALL_PAYROLLS_F'
                    ,p_comment_text      => p_rec.comments
                    );
  -- Update the comments if they have changed
  ElsIf (p_rec.comment_id is not null and p_rec.comments <>
        pay_pay_shd.g_old_rec.comments) then
     --

     hr_comm_api.upd(p_comment_id        => p_rec.comment_id
                    ,p_source_table_name => 'PAY_ALL_PAYROLLS_F'
                    ,p_comment_text      => p_rec.comments
                    );

/*
-- a conflict between payroll form and API
-- form generating a new comment_id when the comments being changed
-- but API is only updating the new comment_text and not generating
-- a new comment_id
-- need to be reviewed

-- old code commented, bcz upd procedure not generating a new comment_id
-- when the comment_text is changed
-- so, whenever the comment_text is changed then we call this ins proc
-- to generate a new comment_id.
-- 5144323 / 5609830 starts
     hr_comm_api.ins(p_comment_id        => p_rec.comment_id
                    ,p_source_table_name => 'PAY_ALL_PAYROLLS_F'
                    ,p_comment_text      => p_rec.comments
                    );
--5144323 / 5609830 ends
*/     --
  End If;
  --
  dt_pre_update
    (p_rec                   => p_rec
    ,p_effective_date        => p_effective_date
    ,p_datetrack_mode        => p_datetrack_mode
    ,p_validation_start_date => p_validation_start_date
    ,p_validation_end_date   => p_validation_end_date
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End pre_update;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< post_update >-------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This private procedure contains any processing which is required after
--   the update dml.
--
-- Prerequisites:
--   This is an internal procedure which is called from the upd procedure.
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
--   Any post-processing required after the update dml is issued should be
--   coded within this procedure. It is important to note that any 3rd party
--   maintenance should be reviewed before placing in this procedure.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure post_update
  (p_rec                   in pay_pay_shd.g_rec_type
  ,p_effective_date        in date
  ,p_datetrack_mode        in varchar2
  ,p_validation_start_date in date
  ,p_validation_end_date   in date
  ) is
--
  l_proc        varchar2(72) := g_package||'post_update';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  begin
    --


-- Copy new payroll_name to all rows for the payroll ie,. this should not be
  -- datetracked.
  if p_rec.payroll_name <> pay_pay_shd.g_old_rec.payroll_name then
--
    pay_pay_shd.g_api_dml := true;
    pay_payrolls_f_pkg.propagate_changes
      (p_rec.payroll_id,
       p_rec.payroll_name,
       null); -- number of years
    pay_pay_shd.g_api_dml := false;
--
  end if;
--
  -- Extend the number of payroll time periods if the number of years has been
  -- increased.
  if p_rec.number_of_years > pay_pay_shd.g_old_rec.number_of_years then
--
    -- copy new number_of_years to all rows for the payroll ie,. this should
    -- not be datetracked.
    pay_pay_shd.g_api_dml := true;
    pay_payrolls_f_pkg.propagate_changes
      (p_rec.payroll_id,
       null, -- payroll name
       p_rec.number_of_years);
    pay_pay_shd.g_api_dml := false;
--
    /*hr_payrolls.create_payroll_proc_periods
      (p_rec.payroll_id,
       null,  -- last_update_date
       null,  -- last_updated_by
       null,  -- last_update_login
       null,  -- created_by
       null,  -- creation_date
       p_effective_date -- effective_date
      );*/
--
  end if;
--
  -- If default payment method for the payroll has changed then create
  -- opmu to represent it.
  if p_rec.default_payment_method_id <> nvl(pay_pay_shd.g_old_rec.default_payment_method_id, 0)
     and p_rec.default_payment_method_id is not null then
    --
    pay_payrolls_f_pkg.maintain_dflt_payment_method
      (p_rec.payroll_id,
       p_rec.default_payment_method_id,
       p_validation_start_date,
       p_validation_end_date);
    --
  end if;

    pay_pay_rku.after_update
      (p_effective_date                     => p_effective_date
      ,p_datetrack_mode                     => p_datetrack_mode
      ,p_validation_start_date              => p_validation_start_date
      ,p_validation_end_date                => p_validation_end_date
      ,p_payroll_id                         => p_rec.payroll_id
      ,p_effective_start_date               => p_rec.effective_start_date
      ,p_effective_end_date                 => p_rec.effective_end_date
      ,p_default_payment_method_id          => p_rec.default_payment_method_id
      ,p_consolidation_set_id               => p_rec.consolidation_set_id
      ,p_cost_allocation_keyflex_id         => p_rec.cost_allocation_keyflex_id
      ,p_suspense_account_keyflex_id        => p_rec.suspense_account_keyflex_id
       ,p_soft_coding_keyflex_id            => p_rec.soft_coding_keyflex_id
      ,p_negative_pay_allowed_flag          => p_rec.negative_pay_allowed_flag
      ,p_number_of_years                    => p_rec.number_of_years
      ,p_payroll_name                       => p_rec.payroll_name
      ,p_workload_shifting_level            => p_rec.workload_shifting_level
      ,p_comment_id                         => p_rec.comment_id
      ,p_comments                           => p_rec.comments
      ,p_attribute_category                 => p_rec.attribute_category
      ,p_attribute1                         => p_rec.attribute1
      ,p_attribute2                         => p_rec.attribute2
      ,p_attribute3                         => p_rec.attribute3
      ,p_attribute4                         => p_rec.attribute4
      ,p_attribute5                         => p_rec.attribute5
      ,p_attribute6                         => p_rec.attribute6
      ,p_attribute7                         => p_rec.attribute7
      ,p_attribute8                         => p_rec.attribute8
      ,p_attribute9                         => p_rec.attribute9
      ,p_attribute10                        => p_rec.attribute10
      ,p_attribute11                        => p_rec.attribute11
      ,p_attribute12                        => p_rec.attribute12
      ,p_attribute13                        => p_rec.attribute13
      ,p_attribute14                        => p_rec.attribute14
      ,p_attribute15                        => p_rec.attribute15
      ,p_attribute16                        => p_rec.attribute16
      ,p_attribute17                        => p_rec.attribute17
      ,p_attribute18                        => p_rec.attribute18
      ,p_attribute19                        => p_rec.attribute19
      ,p_attribute20                        => p_rec.attribute20
      ,p_arrears_flag                       => p_rec.arrears_flag
      ,p_prl_information_category           => p_rec.prl_information_category
      ,p_prl_information1                   => p_rec.prl_information1
      ,p_prl_information2                   => p_rec.prl_information2
      ,p_prl_information3                   => p_rec.prl_information3
      ,p_prl_information4                   => p_rec.prl_information4
      ,p_prl_information5                   => p_rec.prl_information5
      ,p_prl_information6                   => p_rec.prl_information6
      ,p_prl_information7                   => p_rec.prl_information7
      ,p_prl_information8                   => p_rec.prl_information8
      ,p_prl_information9                   => p_rec.prl_information9
      ,p_prl_information10                  => p_rec.prl_information10
      ,p_prl_information11                  => p_rec.prl_information11
      ,p_prl_information12                  => p_rec.prl_information12
      ,p_prl_information13                  => p_rec.prl_information13
      ,p_prl_information14                  => p_rec.prl_information14
      ,p_prl_information15                  => p_rec.prl_information15
      ,p_prl_information16                  => p_rec.prl_information16
      ,p_prl_information17                  => p_rec.prl_information17
      ,p_prl_information18                  => p_rec.prl_information18
      ,p_prl_information19                  => p_rec.prl_information19
      ,p_prl_information20                  => p_rec.prl_information20
      ,p_prl_information21                  => p_rec.prl_information21
      ,p_prl_information22                  => p_rec.prl_information22
      ,p_prl_information23                  => p_rec.prl_information23
      ,p_prl_information24                  => p_rec.prl_information24
      ,p_prl_information25                  => p_rec.prl_information25
      ,p_prl_information26                  => p_rec.prl_information26
      ,p_prl_information27                  => p_rec.prl_information27
      ,p_prl_information28                  => p_rec.prl_information28
      ,p_prl_information29                  => p_rec.prl_information29
      ,p_prl_information30                  => p_rec.prl_information30
      ,p_multi_assignments_flag             => p_rec.multi_assignments_flag
      ,p_object_version_number              => p_rec.object_version_number
      ,p_payslip_view_date_offset           => p_rec.payslip_view_date_offset
      ,p_effective_start_date_o             => pay_pay_shd.g_old_rec.effective_start_date
      ,p_effective_end_date_o               => pay_pay_shd.g_old_rec.effective_end_date
      ,p_default_payment_method_id_o        => pay_pay_shd.g_old_rec.default_payment_method_id
      ,p_business_group_id_o                => pay_pay_shd.g_old_rec.business_group_id
      ,p_consolidation_set_id_o             => pay_pay_shd.g_old_rec.consolidation_set_id
      ,p_cost_allocation_keyflex_id_o       => pay_pay_shd.g_old_rec.cost_allocation_keyflex_id
      ,p_suspense_account_keyflex_i_o       => pay_pay_shd.g_old_rec.suspense_account_keyflex_id
      ,p_gl_set_of_books_id_o               => pay_pay_shd.g_old_rec.gl_set_of_books_id
      ,p_soft_coding_keyflex_id_o           => pay_pay_shd.g_old_rec.soft_coding_keyflex_id
      ,p_period_type_o                      => pay_pay_shd.g_old_rec.period_type
      ,p_organization_id_o                  => pay_pay_shd.g_old_rec.organization_id
      ,p_cut_off_date_offset_o              => pay_pay_shd.g_old_rec.cut_off_date_offset
      ,p_direct_deposit_date_offset_o       => pay_pay_shd.g_old_rec.direct_deposit_date_offset
      ,p_first_period_end_date_o            => pay_pay_shd.g_old_rec.first_period_end_date
      ,p_negative_pay_allowed_flag_o        => pay_pay_shd.g_old_rec.negative_pay_allowed_flag
      ,p_number_of_years_o                  => pay_pay_shd.g_old_rec.number_of_years
      ,p_pay_advice_date_offset_o           => pay_pay_shd.g_old_rec.pay_advice_date_offset
      ,p_pay_date_offset_o                  => pay_pay_shd.g_old_rec.pay_date_offset
      ,p_payroll_name_o                     => pay_pay_shd.g_old_rec.payroll_name
      ,p_workload_shifting_level_o          => pay_pay_shd.g_old_rec.workload_shifting_level
      ,p_comment_id_o                       => pay_pay_shd.g_old_rec.comment_id
      ,p_comments_o                         => pay_pay_shd.g_old_rec.comments
      ,p_midpoint_offset_o                  => pay_pay_shd.g_old_rec.midpoint_offset
      ,p_attribute_category_o               => pay_pay_shd.g_old_rec.attribute_category
      ,p_attribute1_o                       => pay_pay_shd.g_old_rec.attribute1
      ,p_attribute2_o                       => pay_pay_shd.g_old_rec.attribute2
      ,p_attribute3_o                       => pay_pay_shd.g_old_rec.attribute3
      ,p_attribute4_o                       => pay_pay_shd.g_old_rec.attribute4
      ,p_attribute5_o                       => pay_pay_shd.g_old_rec.attribute5
      ,p_attribute6_o                       => pay_pay_shd.g_old_rec.attribute6
      ,p_attribute7_o                       => pay_pay_shd.g_old_rec.attribute7
      ,p_attribute8_o                       => pay_pay_shd.g_old_rec.attribute8
      ,p_attribute9_o                       => pay_pay_shd.g_old_rec.attribute9
      ,p_attribute10_o                      => pay_pay_shd.g_old_rec.attribute10
      ,p_attribute11_o                      => pay_pay_shd.g_old_rec.attribute11
      ,p_attribute12_o                      => pay_pay_shd.g_old_rec.attribute12
      ,p_attribute13_o                      => pay_pay_shd.g_old_rec.attribute13
      ,p_attribute14_o                      => pay_pay_shd.g_old_rec.attribute14
      ,p_attribute15_o                      => pay_pay_shd.g_old_rec.attribute15
      ,p_attribute16_o                      => pay_pay_shd.g_old_rec.attribute16
      ,p_attribute17_o                      => pay_pay_shd.g_old_rec.attribute17
      ,p_attribute18_o                      => pay_pay_shd.g_old_rec.attribute18
      ,p_attribute19_o                      => pay_pay_shd.g_old_rec.attribute19
      ,p_attribute20_o                      => pay_pay_shd.g_old_rec.attribute20
      ,p_arrears_flag_o                     => pay_pay_shd.g_old_rec.arrears_flag
      ,p_payroll_type_o                     => pay_pay_shd.g_old_rec.payroll_type
      ,p_prl_information_category_o         => pay_pay_shd.g_old_rec.prl_information_category
      ,p_prl_information1_o                 => pay_pay_shd.g_old_rec.prl_information1
      ,p_prl_information2_o                 => pay_pay_shd.g_old_rec.prl_information2
      ,p_prl_information3_o                 => pay_pay_shd.g_old_rec.prl_information3
      ,p_prl_information4_o                 => pay_pay_shd.g_old_rec.prl_information4
      ,p_prl_information5_o                 => pay_pay_shd.g_old_rec.prl_information5
      ,p_prl_information6_o                 => pay_pay_shd.g_old_rec.prl_information6
      ,p_prl_information7_o                 => pay_pay_shd.g_old_rec.prl_information7
      ,p_prl_information8_o                 => pay_pay_shd.g_old_rec.prl_information8
      ,p_prl_information9_o                 => pay_pay_shd.g_old_rec.prl_information9
      ,p_prl_information10_o                => pay_pay_shd.g_old_rec.prl_information10
      ,p_prl_information11_o                => pay_pay_shd.g_old_rec.prl_information11
      ,p_prl_information12_o                => pay_pay_shd.g_old_rec.prl_information12
      ,p_prl_information13_o                => pay_pay_shd.g_old_rec.prl_information13
      ,p_prl_information14_o                => pay_pay_shd.g_old_rec.prl_information14
      ,p_prl_information15_o                => pay_pay_shd.g_old_rec.prl_information15
      ,p_prl_information16_o                => pay_pay_shd.g_old_rec.prl_information16
      ,p_prl_information17_o                => pay_pay_shd.g_old_rec.prl_information17
      ,p_prl_information18_o                => pay_pay_shd.g_old_rec.prl_information18
      ,p_prl_information19_o                => pay_pay_shd.g_old_rec.prl_information19
      ,p_prl_information20_o                => pay_pay_shd.g_old_rec.prl_information20
      ,p_prl_information21_o                => pay_pay_shd.g_old_rec.prl_information21
      ,p_prl_information22_o                => pay_pay_shd.g_old_rec.prl_information22
      ,p_prl_information23_o                => pay_pay_shd.g_old_rec.prl_information23
      ,p_prl_information24_o                => pay_pay_shd.g_old_rec.prl_information24
      ,p_prl_information25_o                => pay_pay_shd.g_old_rec.prl_information25
      ,p_prl_information26_o                => pay_pay_shd.g_old_rec.prl_information26
      ,p_prl_information27_o                => pay_pay_shd.g_old_rec.prl_information27
      ,p_prl_information28_o                => pay_pay_shd.g_old_rec.prl_information28
      ,p_prl_information29_o                => pay_pay_shd.g_old_rec.prl_information29
      ,p_prl_information30_o                => pay_pay_shd.g_old_rec.prl_information30
      ,p_multi_assignments_flag_o           => pay_pay_shd.g_old_rec.multi_assignments_flag
      ,p_period_reset_years_o               => pay_pay_shd.g_old_rec.period_reset_years
      ,p_object_version_number_o            => pay_pay_shd.g_old_rec.object_version_number
      ,p_payslip_view_date_offset_o         => pay_pay_shd.g_old_rec.payslip_view_date_offset
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PAY_ALL_PAYROLLS_F'
        ,p_hook_type   => 'AU');
      --
  end;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  --
End post_update;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_defs >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   The Convert_Defs procedure has one very important function:
--   It must return the record structure for the row with all system defaulted
--   values converted into its corresponding parameter value for update. When
--   we attempt to update a row through the Upd process , certain
--   parameters can be defaulted which enables flexibility in the calling of
--   the upd process (e.g. only attributes which need to be updated need to be
--   specified). For the upd process to determine which attributes
--   have NOT been specified we need to check if the parameter has a reserved
--   system default value. Therefore, for all parameters which have a
--   corresponding reserved system default mechanism specified we need to
--   check if a system default is being used. If a system default is being
--   used then we convert the defaulted value into its corresponding attribute
--   value held in the g_old_rec data structure.
--
-- Prerequisites:
--   This private function can only be called from the upd process.
--
-- In Parameters:
--   A Pl/Sql record structure.
--
-- Post Success:
--   The record structure will be returned with all system defaulted parameter
--   values converted into its current row attribute value.
--
-- Post Failure:
--   No direct error handling is required within this function. Any possible
--   errors within this procedure will be a PL/SQL value error due to
--   conversion of datatypes or data lengths.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure convert_defs
  (p_rec in out nocopy pay_pay_shd.g_rec_type
  ) is
--
Begin
  --
  -- We must now examine each argument value in the
  -- p_rec plsql record structure
  -- to see if a system default is being used. If a system default
  -- is being used then we must set to the 'current' argument value.
  --
  If (p_rec.default_payment_method_id = hr_api.g_number) then
    --
    p_rec.default_payment_method_id :=
    pay_pay_shd.g_old_rec.default_payment_method_id;
    --
  End If;
  --
  If (p_rec.business_group_id = hr_api.g_number) then
    --
    p_rec.business_group_id := pay_pay_shd.g_old_rec.business_group_id;
    --
  End if;
  --
  If (p_rec.consolidation_set_id = hr_api.g_number) then
    --
    p_rec.consolidation_set_id := pay_pay_shd.g_old_rec.consolidation_set_id;
    --
  End If;
  --
  If (p_rec.cost_allocation_keyflex_id = hr_api.g_number) then
    --
    p_rec.cost_allocation_keyflex_id :=
    pay_pay_shd.g_old_rec.cost_allocation_keyflex_id;
    --
  End If;
  --
  If (p_rec.suspense_account_keyflex_id = hr_api.g_number) then
    --
    p_rec.suspense_account_keyflex_id :=
    pay_pay_shd.g_old_rec.suspense_account_keyflex_id;
    --
  End If;
  --
  If (p_rec.gl_set_of_books_id = hr_api.g_number) then
    --
    p_rec.gl_set_of_books_id :=
    pay_pay_shd.g_old_rec.gl_set_of_books_id;
    --
  End If;
  --
  If (p_rec.soft_coding_keyflex_id = hr_api.g_number) then
    --
    p_rec.soft_coding_keyflex_id :=
    pay_pay_shd.g_old_rec.soft_coding_keyflex_id;
    --
  End If;
  --
  If (p_rec.period_type = hr_api.g_varchar2) then
    --
    p_rec.period_type :=
    pay_pay_shd.g_old_rec.period_type;
    --
  End If;
  --
  If (p_rec.organization_id = hr_api.g_number) then
    --
    p_rec.organization_id := pay_pay_shd.g_old_rec.organization_id;
    --
  End If;
  --
  If (p_rec.cut_off_date_offset = hr_api.g_number) then
    --
    p_rec.cut_off_date_offset := pay_pay_shd.g_old_rec.cut_off_date_offset;
    --
  End If;
  --
  If (p_rec.direct_deposit_date_offset = hr_api.g_number) then
    --
    p_rec.direct_deposit_date_offset :=
    pay_pay_shd.g_old_rec.direct_deposit_date_offset;
    --
  End If;
  --
  If (p_rec.first_period_end_date = hr_api.g_date) then
    --
    p_rec.first_period_end_date :=
    pay_pay_shd.g_old_rec.first_period_end_date;
    --
  End If;
  If (p_rec.negative_pay_allowed_flag = hr_api.g_varchar2) then
    --
    p_rec.negative_pay_allowed_flag :=
    pay_pay_shd.g_old_rec.negative_pay_allowed_flag;
    --
  End If;
  If (p_rec.number_of_years = hr_api.g_number) then
    --
    p_rec.number_of_years := pay_pay_shd.g_old_rec.number_of_years;
    --
  End If;
  --
  If (p_rec.pay_advice_date_offset = hr_api.g_number) then
    --
    p_rec.pay_advice_date_offset :=
    pay_pay_shd.g_old_rec.pay_advice_date_offset;
    --
  End If;
  --
  If (p_rec.pay_date_offset = hr_api.g_number) then
    --
    p_rec.pay_date_offset := pay_pay_shd.g_old_rec.pay_date_offset;
    --
  End If;
  --
  If (p_rec.payroll_name = hr_api.g_varchar2) then
    --
    p_rec.payroll_name := pay_pay_shd.g_old_rec.payroll_name;
    --
  End If;
  --
  If (p_rec.workload_shifting_level = hr_api.g_varchar2) then
    --
    p_rec.workload_shifting_level :=
    pay_pay_shd.g_old_rec.workload_shifting_level;
    --
  End If;
  --
  If (p_rec.comment_id = hr_api.g_number) then
    --
    p_rec.comment_id := pay_pay_shd.g_old_rec.comment_id;
    --
  End If;
  --
  If (p_rec.comments = hr_api.g_varchar2) then
    --
    p_rec.comments := pay_pay_shd.g_old_rec.comments;
    --
  End If;
  --
  If (p_rec.midpoint_offset = hr_api.g_number) then
    --
    p_rec.midpoint_offset := pay_pay_shd.g_old_rec.midpoint_offset;
    --
  End If;
  --
  If (p_rec.attribute_category = hr_api.g_varchar2) then
    --
    p_rec.attribute_category := pay_pay_shd.g_old_rec.attribute_category;
    --
  End If;
  --
  If (p_rec.attribute1 = hr_api.g_varchar2) then
    --
    p_rec.attribute1 := pay_pay_shd.g_old_rec.attribute1;
    --
  End If;
  --
  If (p_rec.attribute2 = hr_api.g_varchar2) then
    --
    p_rec.attribute2 := pay_pay_shd.g_old_rec.attribute2;
    --
  End If;
  --
  If (p_rec.attribute3 = hr_api.g_varchar2) then
    --
    p_rec.attribute3 := pay_pay_shd.g_old_rec.attribute3;
    --
  End If;
  --
  If (p_rec.attribute4 = hr_api.g_varchar2) then
    --
    p_rec.attribute4 := pay_pay_shd.g_old_rec.attribute4;
    --
  End If;
  --
  If (p_rec.attribute5 = hr_api.g_varchar2) then
    --
    p_rec.attribute5 := pay_pay_shd.g_old_rec.attribute5;
    --
  End If;
  --
  If (p_rec.attribute6 = hr_api.g_varchar2) then
    --
    p_rec.attribute6 := pay_pay_shd.g_old_rec.attribute6;
    --
  End If;
  --
  If (p_rec.attribute7 = hr_api.g_varchar2) then
    --
    p_rec.attribute7 := pay_pay_shd.g_old_rec.attribute7;
    --
  End If;
  --
  If (p_rec.attribute8 = hr_api.g_varchar2) then
    --
    p_rec.attribute8 := pay_pay_shd.g_old_rec.attribute8;
    --
  End If;
  --
  If (p_rec.attribute9 = hr_api.g_varchar2) then
    --
    p_rec.attribute9 := pay_pay_shd.g_old_rec.attribute9;
    --
  End If;
  --
  If (p_rec.attribute10 = hr_api.g_varchar2) then
    --
    p_rec.attribute10 := pay_pay_shd.g_old_rec.attribute10;
    --
  End If;
  --
  If (p_rec.attribute11 = hr_api.g_varchar2) then
    --
    p_rec.attribute11 := pay_pay_shd.g_old_rec.attribute11;
    --
  End If;
  --
  If (p_rec.attribute12 = hr_api.g_varchar2) then
    --
    p_rec.attribute12 := pay_pay_shd.g_old_rec.attribute12;
    --
  End If;
  --
  If (p_rec.attribute13 = hr_api.g_varchar2) then
    --
    p_rec.attribute13 := pay_pay_shd.g_old_rec.attribute13;
    --
  End If;
  --
  If (p_rec.attribute14 = hr_api.g_varchar2) then
    --
    p_rec.attribute14 := pay_pay_shd.g_old_rec.attribute14;
    --
  End If;
  --
  If (p_rec.attribute15 = hr_api.g_varchar2) then
    --
    p_rec.attribute15 := pay_pay_shd.g_old_rec.attribute15;
    --
  End If;
  --
  If (p_rec.attribute16 = hr_api.g_varchar2) then
    --
    p_rec.attribute16 := pay_pay_shd.g_old_rec.attribute16;
    --
  End If;
  If (p_rec.attribute17 = hr_api.g_varchar2) then
    --
    p_rec.attribute17 := pay_pay_shd.g_old_rec.attribute17;
    --
  End If;
  --
  If (p_rec.attribute18 = hr_api.g_varchar2) then
    --
    p_rec.attribute18 := pay_pay_shd.g_old_rec.attribute18;
    --
  End If;
  --
  If (p_rec.attribute19 = hr_api.g_varchar2) then
    --
    p_rec.attribute19 := pay_pay_shd.g_old_rec.attribute19;
    --
  End If;
  --
  If (p_rec.attribute20 = hr_api.g_varchar2) then
    --
    p_rec.attribute20 := pay_pay_shd.g_old_rec.attribute20;
    --
  End If;
  --
  If (p_rec.arrears_flag = hr_api.g_varchar2) then
    --
    p_rec.arrears_flag := pay_pay_shd.g_old_rec.arrears_flag;
    --
  End If;
  --
  If (p_rec.payroll_type = hr_api.g_varchar2) then
    --
    p_rec.payroll_type := pay_pay_shd.g_old_rec.payroll_type;
    --
  End If;
  --
  If (p_rec.prl_information_category = hr_api.g_varchar2) then
    --
    p_rec.prl_information_category :=
    pay_pay_shd.g_old_rec.prl_information_category;
    --
  End If;
  --
  If (p_rec.prl_information1 = hr_api.g_varchar2) then
    --
    p_rec.prl_information1 := pay_pay_shd.g_old_rec.prl_information1;
    --
  End If;
  --
  If (p_rec.prl_information2 = hr_api.g_varchar2) then
    --
    p_rec.prl_information2 := pay_pay_shd.g_old_rec.prl_information2;
    --
  End If;
  --
  If (p_rec.prl_information3 = hr_api.g_varchar2) then
    --
    p_rec.prl_information3 := pay_pay_shd.g_old_rec.prl_information3;
    --
  End If;
  --
  If (p_rec.prl_information4 = hr_api.g_varchar2) then
    --
    p_rec.prl_information4 := pay_pay_shd.g_old_rec.prl_information4;
    --
  End If;
  --
  If (p_rec.prl_information5 = hr_api.g_varchar2) then
    --
    p_rec.prl_information5 := pay_pay_shd.g_old_rec.prl_information5;
    --
  End If;
  --
  If (p_rec.prl_information6 = hr_api.g_varchar2) then
    --
    p_rec.prl_information6 := pay_pay_shd.g_old_rec.prl_information6;
    --
  End If;
  --
  If (p_rec.prl_information7 = hr_api.g_varchar2) then
    --
    p_rec.prl_information7 := pay_pay_shd.g_old_rec.prl_information7;
    --
  End If;
  If (p_rec.prl_information8 = hr_api.g_varchar2) then
    --
    p_rec.prl_information8 := pay_pay_shd.g_old_rec.prl_information8;
    --
  End If;
  --
  If (p_rec.prl_information9 = hr_api.g_varchar2) then
    --
    p_rec.prl_information9 := pay_pay_shd.g_old_rec.prl_information9;
    --
  End If;
  --
  If (p_rec.prl_information10 = hr_api.g_varchar2) then
    --
    p_rec.prl_information10 := pay_pay_shd.g_old_rec.prl_information10;
    --
  End If;
  --
  If (p_rec.prl_information11 = hr_api.g_varchar2) then
    --
    p_rec.prl_information11 := pay_pay_shd.g_old_rec.prl_information11;
    --
  End If;
  --
  If (p_rec.prl_information12 = hr_api.g_varchar2) then
    --
    p_rec.prl_information12 := pay_pay_shd.g_old_rec.prl_information12;
    --
  End If;
  --
  If (p_rec.prl_information13 = hr_api.g_varchar2) then
    --
    p_rec.prl_information13 := pay_pay_shd.g_old_rec.prl_information13;
    --
  End If;
  --
  If (p_rec.prl_information14 = hr_api.g_varchar2) then
    --
    p_rec.prl_information14 := pay_pay_shd.g_old_rec.prl_information14;
    --
  End If;
  --
  If (p_rec.prl_information15 = hr_api.g_varchar2) then
    --
    p_rec.prl_information15 := pay_pay_shd.g_old_rec.prl_information15;
    --
  End If;
  --
  If (p_rec.prl_information16 = hr_api.g_varchar2) then
    --
    p_rec.prl_information16 := pay_pay_shd.g_old_rec.prl_information16;
    --
  End If;
  --
  If (p_rec.prl_information17 = hr_api.g_varchar2) then
    --
    p_rec.prl_information17 := pay_pay_shd.g_old_rec.prl_information17;
    --
  End If;
  --
  If (p_rec.prl_information18 = hr_api.g_varchar2) then
    --
    p_rec.prl_information18 := pay_pay_shd.g_old_rec.prl_information18;
    --
  End If;
  --
  If (p_rec.prl_information19 = hr_api.g_varchar2) then
    --
    p_rec.prl_information19 := pay_pay_shd.g_old_rec.prl_information19;
    --
  End If;
  --
  If (p_rec.prl_information20 = hr_api.g_varchar2) then
    --
    p_rec.prl_information20 := pay_pay_shd.g_old_rec.prl_information20;
    --
  End If;
  --
  If (p_rec.prl_information21 = hr_api.g_varchar2) then
    --
    p_rec.prl_information21 := pay_pay_shd.g_old_rec.prl_information21;
    --
  End If;
  --
  If (p_rec.prl_information22 = hr_api.g_varchar2) then
    --
    p_rec.prl_information22 := pay_pay_shd.g_old_rec.prl_information22;
    --
  End If;
  --
  If (p_rec.prl_information23 = hr_api.g_varchar2) then
    --
    p_rec.prl_information23 := pay_pay_shd.g_old_rec.prl_information23;
    --
  End If;
  --
  If (p_rec.prl_information24 = hr_api.g_varchar2) then
    --
    p_rec.prl_information24 := pay_pay_shd.g_old_rec.prl_information24;
    --
  End If;
  --
  If (p_rec.prl_information25 = hr_api.g_varchar2) then
    --
    p_rec.prl_information25 := pay_pay_shd.g_old_rec.prl_information25;
    --
  End If;
  --
  If (p_rec.prl_information26 = hr_api.g_varchar2) then
    --
    p_rec.prl_information26 := pay_pay_shd.g_old_rec.prl_information26;
    --
  End If;
  --
  If (p_rec.prl_information27 = hr_api.g_varchar2) then
    --
    p_rec.prl_information27 := pay_pay_shd.g_old_rec.prl_information27;
    --
  End If;
  --
  If (p_rec.prl_information28 = hr_api.g_varchar2) then
    --
    p_rec.prl_information28 := pay_pay_shd.g_old_rec.prl_information28;
    --
  End If;
  --
  If (p_rec.prl_information29 = hr_api.g_varchar2) then
    --
    p_rec.prl_information29 := pay_pay_shd.g_old_rec.prl_information29;
    --
  End If;
  --
  If (p_rec.prl_information30 = hr_api.g_varchar2) then
    --
    p_rec.prl_information30 := pay_pay_shd.g_old_rec.prl_information30;
    --
  End If;
  --
  If (p_rec.multi_assignments_flag = hr_api.g_varchar2) then
    --
    p_rec.multi_assignments_flag := pay_pay_shd.g_old_rec.multi_assignments_flag;
    --
  End If;
  --
  If (p_rec.period_reset_years = hr_api.g_varchar2) then
    --
    p_rec.period_reset_years := pay_pay_shd.g_old_rec.period_reset_years;
    --
  End If;
  --
  IF (p_rec.payslip_view_date_offset = hr_api.g_number) then
    --
    p_rec.payslip_view_date_offset := pay_pay_shd.g_old_rec.payslip_view_date_offset;
    --
  End If;
--
End convert_defs;

-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (p_effective_date in     date
  ,p_datetrack_mode in     varchar2
  ,p_rec            in out nocopy pay_pay_shd.g_rec_type
  ) is
--
  l_proc                        varchar2(72) := g_package||'upd';
  l_validation_start_date       date;
  l_validation_end_date         date;
  l_rec                         pay_pay_shd.g_rec_type := p_rec;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Ensure that the DateTrack update mode is valid
  --
  dt_api.validate_dt_upd_mode(p_datetrack_mode => p_datetrack_mode);
  --
  -- We must lock the row which we need to update.
  --

  pay_pay_shd.lck
    (p_effective_date                   => p_effective_date
    ,p_datetrack_mode                   => p_datetrack_mode
    ,p_payroll_id                       => l_rec.payroll_id
    ,p_object_version_number            => l_rec.object_version_number
    ,p_validation_start_date            => l_validation_start_date
    ,p_validation_end_date              => l_validation_end_date
    );
  --
  -- 1. During an update system defaults are used to determine if
  --    arguments have been defaulted or not. We must therefore
  --    derive the full record structure values to be updated.
  --
  -- 2. Call the supporting update validate operations.
  --
  pay_pay_upd.convert_defs(l_rec);
  --
  pay_pay_bus.update_validate
    (p_rec                              => l_rec
    ,p_effective_date                   => p_effective_date
    ,p_datetrack_mode                   => p_datetrack_mode
    ,p_validation_start_date            => l_validation_start_date
    ,p_validation_end_date              => l_validation_end_date
    );
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
  -- Call the supporting pre-update operation
  --
  pre_update
    (p_rec                              => l_rec
    ,p_effective_date                   => p_effective_date
    ,p_datetrack_mode                   => p_datetrack_mode
    ,p_validation_start_date            => l_validation_start_date
    ,p_validation_end_date              => l_validation_end_date
    );
  --
  -- Update the row.
  --
  update_dml
    (p_rec                              => l_rec
    ,p_effective_date                   => p_effective_date
    ,p_datetrack_mode                   => p_datetrack_mode
    ,p_validation_start_date            => l_validation_start_date
    ,p_validation_end_date              => l_validation_end_date
     );
  --
  -- Call the supporting post-update operation
  --
  post_update
    (p_rec                              => l_rec
    ,p_effective_date                   => p_effective_date
    ,p_datetrack_mode                   => p_datetrack_mode
    ,p_validation_start_date            => l_validation_start_date
    ,p_validation_end_date              => l_validation_end_date
    );

    p_rec.payroll_id             := l_rec.payroll_id;
    p_rec.object_version_number  := l_rec.object_version_number;
    p_rec.effective_start_date   := l_rec.effective_start_date;
    p_rec.effective_end_date     := l_rec.effective_end_date;
-- bug 5609830 / 5144323
-- added to return the new comment_id to the called proc
-- a conflict between payroll form and API
-- form generating a new comment_id when the comments being changed
-- but API is only updating the new comment_text and not generating
-- a new comment_id
-- need to be reviewed
--
    p_rec.comment_id             := l_rec.comment_id;
--
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
End upd;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< upd >-------------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (p_effective_date               in     date
  ,p_datetrack_mode               in     varchar2
  ,p_consolidation_set_id         in     number    default hr_api.g_number
  ,p_period_type                  in     varchar2  default hr_api.g_varchar2
  ,p_cut_off_date_offset          in     number    default hr_api.g_number
  ,p_direct_deposit_date_offset   in     number    default hr_api.g_number
  ,p_first_period_end_date        in     date      default hr_api.g_date
  ,p_negative_pay_allowed_flag    in     varchar2  default hr_api.g_varchar2
  ,p_number_of_years              in     number    default hr_api.g_number
  ,p_pay_advice_date_offset       in     number    default hr_api.g_number
  ,p_pay_date_offset              in     number    default hr_api.g_number
  ,p_payroll_name                 in     varchar2  default hr_api.g_varchar2
  ,p_workload_shifting_level      in     varchar2  default hr_api.g_varchar2
  ,p_default_payment_method_id    in     number    default hr_api.g_number
  ,p_cost_allocation_keyflex_id   in     number    default hr_api.g_number
  ,p_suspense_account_keyflex_id  in     number    default hr_api.g_number
  ,p_gl_set_of_books_id           in     number    default hr_api.g_number
  ,p_soft_coding_keyflex_id       in     number    default hr_api.g_number
  ,p_organization_id              in     number    default hr_api.g_number
  ,p_comments                     in     varchar2  default hr_api.g_varchar2
  ,p_midpoint_offset              in     number    default hr_api.g_number
  ,p_attribute_category           in     varchar2  default hr_api.g_varchar2
  ,p_attribute1                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute2                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute3                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute4                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute5                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute6                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute7                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute8                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute9                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute10                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute11                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute12                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute13                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute14                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute15                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute16                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute17                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute18                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute19                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute20                  in     varchar2  default hr_api.g_varchar2
  ,p_arrears_flag                 in     varchar2  default hr_api.g_varchar2
  ,p_payroll_type                 in     varchar2  default hr_api.g_varchar2
  ,p_prl_information_category     in     varchar2  default hr_api.g_varchar2
  ,p_prl_information1             in     varchar2  default hr_api.g_varchar2
  ,p_prl_information2             in     varchar2  default hr_api.g_varchar2
  ,p_prl_information3             in     varchar2  default hr_api.g_varchar2
  ,p_prl_information4             in     varchar2  default hr_api.g_varchar2
  ,p_prl_information5             in     varchar2  default hr_api.g_varchar2
  ,p_prl_information6             in     varchar2  default hr_api.g_varchar2
  ,p_prl_information7             in     varchar2  default hr_api.g_varchar2
  ,p_prl_information8             in     varchar2  default hr_api.g_varchar2
  ,p_prl_information9             in     varchar2  default hr_api.g_varchar2
  ,p_prl_information10            in     varchar2  default hr_api.g_varchar2
  ,p_prl_information11            in     varchar2  default hr_api.g_varchar2
  ,p_prl_information12            in     varchar2  default hr_api.g_varchar2
  ,p_prl_information13            in     varchar2  default hr_api.g_varchar2
  ,p_prl_information14            in     varchar2  default hr_api.g_varchar2
  ,p_prl_information15            in     varchar2  default hr_api.g_varchar2
  ,p_prl_information16            in     varchar2  default hr_api.g_varchar2
  ,p_prl_information17            in     varchar2  default hr_api.g_varchar2
  ,p_prl_information18            in     varchar2  default hr_api.g_varchar2
  ,p_prl_information19            in     varchar2  default hr_api.g_varchar2
  ,p_prl_information20            in     varchar2  default hr_api.g_varchar2
  ,p_prl_information21            in     varchar2  default hr_api.g_varchar2
  ,p_prl_information22            in     varchar2  default hr_api.g_varchar2
  ,p_prl_information23            in     varchar2  default hr_api.g_varchar2
  ,p_prl_information24            in     varchar2  default hr_api.g_varchar2
  ,p_prl_information25            in     varchar2  default hr_api.g_varchar2
  ,p_prl_information26            in     varchar2  default hr_api.g_varchar2
  ,p_prl_information27            in     varchar2  default hr_api.g_varchar2
  ,p_prl_information28            in     varchar2  default hr_api.g_varchar2
  ,p_prl_information29            in     varchar2  default hr_api.g_varchar2
  ,p_prl_information30            in     varchar2  default hr_api.g_varchar2
  ,p_multi_assignments_flag       in     varchar2  default hr_api.g_varchar2
  ,p_period_reset_years           in     varchar2  default hr_api.g_varchar2

  ,p_payslip_view_date_offset     in     number    default hr_api.g_number
  ,p_payroll_id                   in out nocopy number -- Added 'out'.
  ,p_object_version_number        in out nocopy number

  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ,p_comment_id                      out nocopy number
  ) is
--
  l_rec         pay_pay_shd.g_rec_type;
  l_proc        varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  pay_pay_shd.convert_args
    (p_payroll_id
    ,null
    ,null
    ,p_default_payment_method_id
    ,hr_api.g_number
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
    ,hr_api.g_number
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
    ,p_object_version_number
    ,p_payslip_view_date_offset
    );
  --
  -- Having converted the arguments into the
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  pay_pay_upd.upd
    (p_effective_date
    ,p_datetrack_mode
    ,l_rec
    );
  --
  -- Set the out parameters
  --
  p_payroll_id                       := l_rec.payroll_id;
  p_object_version_number            := l_rec.object_version_number;
  p_effective_start_date             := l_rec.effective_start_date;
  p_effective_end_date               := l_rec.effective_end_date;
  p_comment_id                       := l_rec.comment_id;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End upd;
--
end pay_pay_upd;

/
