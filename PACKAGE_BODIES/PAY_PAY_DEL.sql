--------------------------------------------------------
--  DDL for Package Body PAY_PAY_DEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_PAY_DEL" as
/* $Header: pypayrhi.pkb 120.0.12000000.3 2007/03/08 09:23:27 mshingan noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  pay_pay_del.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |----------------------------< dt_delete_dml >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure controls the actual dml delete logic for the datetrack
--   delete modes: ZAP, DELETE, FUTURE_CHANGE and DELETE_NEXT_CHANGE. The
--   execution is as follows:
--   1) To set and unset the g_api_dml status as required (as we are about to
--      perform dml).
--   2) If the delete mode is DELETE_NEXT_CHANGE then delete where the
--      effective start date is equal to the validation start date.
--   3) If the delete mode is not DELETE_NEXT_CHANGE then delete
--      all rows for the entity where the effective start date is greater
--      than or equal to the validation start date.
--   4) To raise any errors.
--
-- Prerequisites:
--   This is an internal private procedure which must be called from the
--   delete_dml procedure.
--
-- In Parameters:
--   A Pl/Sql record structure.
--
-- Post Success:
--   The specified row will be delete from the schema.
--
-- Post Failure:
--   On the delete dml failure it is important to note that we always reset the
--   g_api_dml status to false.
--   If any other error is reported, the error will be raised after the
--   g_api_dml status is reset.
--
-- Developer Implementation Notes:
--   This is an internal private procedure which must be called from the
--   delete_dml procedure.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure dt_delete_dml
  (p_rec                     in out nocopy pay_pay_shd.g_rec_type
  ,p_effective_date          in date
  ,p_datetrack_mode          in varchar2
  ,p_validation_start_date   in date
  ,p_validation_end_date     in date
  ) is
--
  l_proc        varchar2(72) := g_package||'dt_delete_dml';
  l_status_of_dml boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  If (p_datetrack_mode = hr_api.g_delete_next_change) then
    pay_pay_shd.g_api_dml := true;  -- Set the api dml status
    --
    -- Delete the where the effective start date is equal
    -- to the validation end date.
    --
    delete from pay_all_payrolls_f
    where       payroll_id = p_rec.payroll_id
    and   effective_start_date = p_validation_start_date;
    --
    pay_pay_shd.g_api_dml := false;   -- Unset the api dml status
    --
  Else
    --
    pay_pay_shd.g_api_dml := true;  -- Set the api dml status
    --
    -- Delete the row(s) where the effective start date is greater than
    -- or equal to the validation start date.
    --
    delete from pay_all_payrolls_f
    where        payroll_id = p_rec.payroll_id
    and   effective_start_date >= p_validation_start_date;
    --

    --Storing the result of the above DML operation.
    l_status_of_dml:=SQL%NOTFOUND;
    pay_pay_shd.g_api_dml := false;   -- Unset the api dml status

    --Checking the status of the above dml operation.
    /*if (l_status_of_dml) then
      hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
      hr_utility.set_message_token('PROCEDURE',
                                 'pay_payrolls_f_pkg.delete_row');
      hr_utility.set_message_token('STEP','1');
      hr_utility.raise_error;
    End if;*/

  End If;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 20);
--
Exception
  When Others Then
    pay_pay_shd.g_api_dml := false;   -- Unset the api dml status
    Raise;
--
End dt_delete_dml;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< delete_dml >------------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_dml
  (p_rec                     in out nocopy pay_pay_shd.g_rec_type
  ,p_effective_date          in date
  ,p_datetrack_mode          in varchar2
  ,p_validation_start_date   in date
  ,p_validation_end_date     in date
  ) is
--
  l_proc        varchar2(72) := g_package||'delete_dml';
--
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  pay_pay_del.dt_delete_dml
    (p_rec                   => p_rec
    ,p_effective_date        => p_effective_date
    ,p_datetrack_mode        => p_datetrack_mode
    ,p_validation_start_date => p_validation_start_date
    ,p_validation_end_date   => p_validation_end_date
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  --
End delete_dml;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< dt_pre_delete >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   The dt_pre_delete process controls the execution of dml
--   for the datetrack modes: DELETE, FUTURE_CHANGE
--   and DELETE_NEXT_CHANGE only.
--
-- Prerequisites:
--   This is an internal procedure which is called from the pre_delete
--   procedure.
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
--   This is an internal procedure which is required by Datetrack. Don't
--   remove or modify.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure dt_pre_delete
  (p_rec                     in out nocopy pay_pay_shd.g_rec_type
  ,p_effective_date          in date
  ,p_datetrack_mode          in varchar2
  ,p_validation_start_date   in date
  ,p_validation_end_date     in date
  ) is
--
  l_proc        varchar2(72) := g_package||'dt_pre_delete';
--
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (p_datetrack_mode <> hr_api.g_zap) then
    --
    p_rec.effective_start_date
      := pay_pay_shd.g_old_rec.effective_start_date;
    --
    If (p_datetrack_mode = hr_api.g_delete) then
      --
      p_rec.effective_end_date := p_validation_start_date - 1;
      --
    Else
      --
      p_rec.effective_end_date := p_validation_end_date;
      --
    End If;
    --
    -- Update the current effective end date record
    --
    pay_pay_shd.upd_effective_end_date
      (p_effective_date         => p_effective_date
      ,p_base_key_value         => p_rec.payroll_id
      ,p_new_effective_end_date => p_rec.effective_end_date
      ,p_validation_start_date  => p_validation_start_date
      ,p_validation_end_date    => p_validation_end_date
      ,p_object_version_number            => p_rec.object_version_number
      );
    --
  Else
    --
    p_rec.effective_start_date := null;
    p_rec.effective_end_date   := null;
    --
  End If;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  --
End dt_pre_delete;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< pre_delete >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This private procedure contains any processing which is required before
--   the delete dml.
--
-- Prerequisites:
--   This is an internal procedure which is called from the del procedure.
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
--   Any pre-processing required before the delete dml is issued should be
--   coded within this procedure. It is important to note that any 3rd party
--   maintenance should be reviewed before placing in this procedure. The call
--   to the dt_delete_dml procedure should NOT be removed.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure pre_delete
  (p_rec                   in out nocopy pay_pay_shd.g_rec_type
  ,p_effective_date        in date
  ,p_datetrack_mode        in varchar2
  ,p_validation_start_date in date
  ,p_validation_end_date   in date
  ) is
--
  l_proc        varchar2(72) := g_package||'pre_delete';
--
-- Cursor C_Sel1 select comments to be deleted
--
  Cursor C_Sel1 is
    select t1.comment_id
    from   pay_all_payrolls_f t1
    where  t1.comment_id is not null
    and    t1.payroll_id = p_rec.payroll_id
    and    t1.effective_start_date <= p_validation_end_date
    and    t1.effective_end_date   >= p_validation_start_date
    and    not exists
           (select 1
            from   pay_all_payrolls_f t2
            where  t2.comment_id = t1.comment_id
            and    t2.payroll_id = t1.payroll_id
            and   (t2.effective_start_date > p_validation_end_date
            or    t2.effective_end_date   < p_validation_start_date));
--
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Delete any possible comments
  --
  For Comm_Del In C_Sel1 Loop
    hr_comm_api.del(p_comment_id        => Comm_Del.comment_id);
  End Loop;
  --
  --
  pay_pay_del.dt_pre_delete
    (p_rec                   => p_rec
    ,p_effective_date        => p_effective_date
    ,p_datetrack_mode        => p_datetrack_mode
    ,p_validation_start_date => p_validation_start_date
    ,p_validation_end_date   => p_validation_end_date
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  --
End pre_delete;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< post_delete >-------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This private procedure contains any processing which is required after
--   the delete dml.
--
-- Prerequisites:
--   This is an internal procedure which is called from the del procedure.
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
--   Any post-processing required after the delete dml is issued should be
--   coded within this procedure. It is important to note that any 3rd party
--   maintenance should be reviewed before placing in this procedure.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure post_delete
  (p_rec                   in pay_pay_shd.g_rec_type
  ,p_effective_date        in date
  ,p_datetrack_mode        in varchar2
  ,p_validation_start_date in date
  ,p_validation_end_date   in date
  ) is
--
  l_proc        varchar2(72) := g_package||'post_delete';
--
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
   begin
    --
    -- Following call to a procedure Maintains payroll related tables on deletion of a payroll.
    --
    pay_pay_rkd.after_delete
      (p_effective_date
      => p_effective_date
      ,p_datetrack_mode
      => p_datetrack_mode
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
      ,p_effective_start_date_o
      => pay_pay_shd.g_old_rec.effective_start_date
      ,p_effective_end_date_o
      => pay_pay_shd.g_old_rec.effective_end_date
      ,p_default_payment_method_id_o
      => pay_pay_shd.g_old_rec.default_payment_method_id
      ,p_business_group_id_o
      => pay_pay_shd.g_old_rec.business_group_id
      ,p_consolidation_set_id_o
      => pay_pay_shd.g_old_rec.consolidation_set_id
      ,p_cost_allocation_keyflex_id_o
      => pay_pay_shd.g_old_rec.cost_allocation_keyflex_id
      ,p_suspense_account_keyflex_i_o
      => pay_pay_shd.g_old_rec.suspense_account_keyflex_id
      ,p_gl_set_of_books_id_o
      => pay_pay_shd.g_old_rec.gl_set_of_books_id
      ,p_soft_coding_keyflex_id_o
      => pay_pay_shd.g_old_rec.soft_coding_keyflex_id
      ,p_period_type_o
      => pay_pay_shd.g_old_rec.period_type
      ,p_organization_id_o
      => pay_pay_shd.g_old_rec.organization_id
      ,p_cut_off_date_offset_o
      => pay_pay_shd.g_old_rec.cut_off_date_offset
      ,p_direct_deposit_date_offset_o
      => pay_pay_shd.g_old_rec.direct_deposit_date_offset
      ,p_first_period_end_date_o
      => pay_pay_shd.g_old_rec.first_period_end_date
      ,p_negative_pay_allowed_flag_o
      => pay_pay_shd.g_old_rec.negative_pay_allowed_flag
      ,p_number_of_years_o
      => pay_pay_shd.g_old_rec.number_of_years
      ,p_pay_advice_date_offset_o
      => pay_pay_shd.g_old_rec.pay_advice_date_offset
      ,p_pay_date_offset_o
      => pay_pay_shd.g_old_rec.pay_date_offset
      ,p_payroll_name_o
      => pay_pay_shd.g_old_rec.payroll_name
      ,p_workload_shifting_level_o
      => pay_pay_shd.g_old_rec.workload_shifting_level
      ,p_comment_id_o
      => pay_pay_shd.g_old_rec.comment_id
      ,p_comments_o
      => pay_pay_shd.g_old_rec.comments
      ,p_midpoint_offset_o
      => pay_pay_shd.g_old_rec.midpoint_offset
      ,p_attribute_category_o
      => pay_pay_shd.g_old_rec.attribute_category
      ,p_attribute1_o
      => pay_pay_shd.g_old_rec.attribute1
      ,p_attribute2_o
      => pay_pay_shd.g_old_rec.attribute2
      ,p_attribute3_o
      => pay_pay_shd.g_old_rec.attribute3
      ,p_attribute4_o
      => pay_pay_shd.g_old_rec.attribute4
      ,p_attribute5_o
      => pay_pay_shd.g_old_rec.attribute5
      ,p_attribute6_o
      => pay_pay_shd.g_old_rec.attribute6
      ,p_attribute7_o
      => pay_pay_shd.g_old_rec.attribute7
      ,p_attribute8_o
      => pay_pay_shd.g_old_rec.attribute8
      ,p_attribute9_o
      => pay_pay_shd.g_old_rec.attribute9
      ,p_attribute10_o
      => pay_pay_shd.g_old_rec.attribute10
      ,p_attribute11_o
      => pay_pay_shd.g_old_rec.attribute11
      ,p_attribute12_o
      => pay_pay_shd.g_old_rec.attribute12
      ,p_attribute13_o
      => pay_pay_shd.g_old_rec.attribute13
      ,p_attribute14_o
      => pay_pay_shd.g_old_rec.attribute14
      ,p_attribute15_o
      => pay_pay_shd.g_old_rec.attribute15
      ,p_attribute16_o
      => pay_pay_shd.g_old_rec.attribute16
      ,p_attribute17_o
      => pay_pay_shd.g_old_rec.attribute17
      ,p_attribute18_o
      => pay_pay_shd.g_old_rec.attribute18
      ,p_attribute19_o
      => pay_pay_shd.g_old_rec.attribute19
      ,p_attribute20_o
      => pay_pay_shd.g_old_rec.attribute20
      ,p_arrears_flag_o
      => pay_pay_shd.g_old_rec.arrears_flag
      ,p_payroll_type_o
      => pay_pay_shd.g_old_rec.payroll_type
      ,p_prl_information_category_o
      => pay_pay_shd.g_old_rec.prl_information_category
      ,p_prl_information1_o
      => pay_pay_shd.g_old_rec.prl_information1
      ,p_prl_information2_o
      => pay_pay_shd.g_old_rec.prl_information2
      ,p_prl_information3_o
      => pay_pay_shd.g_old_rec.prl_information3
      ,p_prl_information4_o
      => pay_pay_shd.g_old_rec.prl_information4
      ,p_prl_information5_o
      => pay_pay_shd.g_old_rec.prl_information5
      ,p_prl_information6_o
      => pay_pay_shd.g_old_rec.prl_information6
      ,p_prl_information7_o
      => pay_pay_shd.g_old_rec.prl_information7
      ,p_prl_information8_o
      => pay_pay_shd.g_old_rec.prl_information8
      ,p_prl_information9_o
      => pay_pay_shd.g_old_rec.prl_information9
      ,p_prl_information10_o
      => pay_pay_shd.g_old_rec.prl_information10
      ,p_prl_information11_o
      => pay_pay_shd.g_old_rec.prl_information11
      ,p_prl_information12_o
      => pay_pay_shd.g_old_rec.prl_information12
      ,p_prl_information13_o
      => pay_pay_shd.g_old_rec.prl_information13
      ,p_prl_information14_o
      => pay_pay_shd.g_old_rec.prl_information14
      ,p_prl_information15_o
      => pay_pay_shd.g_old_rec.prl_information15
      ,p_prl_information16_o
      => pay_pay_shd.g_old_rec.prl_information16
      ,p_prl_information17_o
      => pay_pay_shd.g_old_rec.prl_information17
      ,p_prl_information18_o
      => pay_pay_shd.g_old_rec.prl_information18
      ,p_prl_information19_o
      => pay_pay_shd.g_old_rec.prl_information19
      ,p_prl_information20_o
      => pay_pay_shd.g_old_rec.prl_information20
      ,p_prl_information21_o
      => pay_pay_shd.g_old_rec.prl_information21
      ,p_prl_information22_o
      => pay_pay_shd.g_old_rec.prl_information22
      ,p_prl_information23_o
      => pay_pay_shd.g_old_rec.prl_information23
      ,p_prl_information24_o
      => pay_pay_shd.g_old_rec.prl_information24
      ,p_prl_information25_o
      => pay_pay_shd.g_old_rec.prl_information25
      ,p_prl_information26_o
      => pay_pay_shd.g_old_rec.prl_information26
      ,p_prl_information27_o
      => pay_pay_shd.g_old_rec.prl_information27
      ,p_prl_information28_o
      => pay_pay_shd.g_old_rec.prl_information28
      ,p_prl_information29_o
      => pay_pay_shd.g_old_rec.prl_information29
      ,p_prl_information30_o
      => pay_pay_shd.g_old_rec.prl_information30
      ,p_multi_assignments_flag_o
      => pay_pay_shd.g_old_rec.multi_assignments_flag
      ,p_period_reset_years_o
      => pay_pay_shd.g_old_rec.period_reset_years
      ,p_object_version_number_o
      => pay_pay_shd.g_old_rec.object_version_number
      ,p_payslip_view_date_offset_o
      => pay_pay_shd.g_old_rec.payslip_view_date_offset
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PAY_ALL_PAYROLLS_F'
        ,p_hook_type   => 'AD');
      --
  end;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  --
End post_delete;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< del >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure del
  (p_effective_date in     date
  ,p_datetrack_mode in     varchar2
  ,p_rec            in out nocopy pay_pay_shd.g_rec_type
  ) is
--
  l_proc                        varchar2(72) := g_package||'del';
  l_validation_start_date       date;
  l_validation_end_date         date;
--
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Ensure that the DateTrack delete mode is valid
  --
  dt_api.validate_dt_del_mode(p_datetrack_mode => p_datetrack_mode);
  --
  -- We must lock the row which we need to delete.
  --
  --
  pay_pay_shd.lck
    (p_effective_date                   => p_effective_date
    ,p_datetrack_mode                   => p_datetrack_mode
    ,p_payroll_id                       => p_rec.payroll_id
    ,p_object_version_number            => p_rec.object_version_number
    ,p_validation_start_date            => l_validation_start_date
    ,p_validation_end_date              => l_validation_end_date
    );
  --
  pay_pay_bus.delete_validate
    (p_rec                              => p_rec
    ,p_effective_date                   => p_effective_date
    ,p_datetrack_mode                   => p_datetrack_mode
    ,p_validation_start_date            => l_validation_start_date
    ,p_validation_end_date              => l_validation_end_date
    );
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
  -- Call the supporting pre-delete operation
  --
  pay_pay_del.pre_delete
    (p_rec                              => p_rec
    ,p_effective_date                   => p_effective_date
    ,p_datetrack_mode                   => p_datetrack_mode
    ,p_validation_start_date            => l_validation_start_date
    ,p_validation_end_date              => l_validation_end_date
    );
  --
  -- Delete the row.
  --
  pay_pay_del.delete_dml
    (p_rec                              => p_rec
    ,p_effective_date                   => p_effective_date
    ,p_datetrack_mode                   => p_datetrack_mode
    ,p_validation_start_date            => l_validation_start_date
    ,p_validation_end_date              => l_validation_end_date
    );
  -- Call the supporting post-delete operation
  --
  pay_pay_del.post_delete
    (p_rec                              => p_rec
    ,p_effective_date                   => p_effective_date
    ,p_datetrack_mode                   => p_datetrack_mode
    ,p_validation_start_date            => l_validation_start_date
    ,p_validation_end_date              => l_validation_end_date
    );
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 5);
End del;
--
-- ----------------------------------------------------------------------------
-- |--------------------------------< del >-----------------------------------|
-- ----------------------------------------------------------------------------
Procedure del
  (p_effective_date                   in     date
  ,p_datetrack_mode                   in     varchar2
  ,p_payroll_id                       in     number
  ,p_object_version_number            in out nocopy number
  ,p_effective_start_date                out nocopy date
  ,p_effective_end_date                  out nocopy date
  ) is
--
  l_rec         pay_pay_shd.g_rec_type;
  l_proc        varchar2(72) := g_package||'del';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- As the delete procedure accepts a plsql record structure we do need to
  -- convert the  arguments into the record structure.
  -- We don't need to call the supplied conversion argument routine as we
  -- only need a few attributes.
  --
  l_rec.payroll_id          := p_payroll_id;
  l_rec.object_version_number     := p_object_version_number;
  --
  -- Having converted the arguments into the pay_pay_rec
  -- plsql record structure we must call the corresponding entity
  -- business process
  --
  pay_pay_del.del
     (p_effective_date
     ,p_datetrack_mode
     ,l_rec
     );
  --
  -- Set the out arguments
  --
  p_object_version_number            := l_rec.object_version_number;
  p_effective_start_date             := l_rec.effective_start_date;
  p_effective_end_date               := l_rec.effective_end_date;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End del;
--
end pay_pay_del;

/
