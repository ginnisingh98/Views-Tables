--------------------------------------------------------
--  DDL for Package Body PAY_OPM_DEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_OPM_DEL" as
/* $Header: pyopmrhi.pkb 120.4 2005/11/07 01:38:13 pgongada noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pay_opm_del.';  -- Global package name
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
  (p_rec                     in out nocopy pay_opm_shd.g_rec_type
  ,p_effective_date          in            date
  ,p_datetrack_mode          in            varchar2
  ,p_validation_start_date   in            date
  ,p_validation_end_date     in            date
  ) is
--
  l_proc	varchar2(72) := g_package||'dt_delete_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  If (p_datetrack_mode = hr_api.g_delete_next_change) then
    pay_opm_shd.g_api_dml := true;  -- Set the api dml status
    --
    -- Delete the where the effective start date is equal
    -- to the validation end date.
    --
    delete from pay_org_payment_methods_f
    where       org_payment_method_id = p_rec.org_payment_method_id
    and	  effective_start_date = p_validation_start_date;
    --
    pay_opm_shd.g_api_dml := false;   -- Unset the api dml status
  Else
    pay_opm_shd.g_api_dml := true;  -- Set the api dml status
    --
    -- Delete the row(s) where the effective start date is greater than
    -- or equal to the validation start date.
    --
    delete from pay_org_payment_methods_f
    where        org_payment_method_id = p_rec.org_payment_method_id
    and	  effective_start_date >= p_validation_start_date;
    --
    pay_opm_shd.g_api_dml := false;   -- Unset the api dml status
  End If;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 20);
--
Exception
  When Others Then
    pay_opm_shd.g_api_dml := false;   -- Unset the api dml status
    Raise;
--
End dt_delete_dml;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< delete_dml >------------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_dml
  (p_rec                     in out nocopy pay_opm_shd.g_rec_type
  ,p_effective_date          in            date
  ,p_datetrack_mode          in            varchar2
  ,p_validation_start_date   in            date
  ,p_validation_end_date     in            date
  ) is
--
  l_proc	varchar2(72) := g_package||'delete_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  pay_opm_del.dt_delete_dml
    (p_rec                   => p_rec
    ,p_effective_date        => p_effective_date
    ,p_datetrack_mode        => p_datetrack_mode
    ,p_validation_start_date => p_validation_start_date
    ,p_validation_end_date   => p_validation_end_date
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
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
  (p_rec                     in out nocopy pay_opm_shd.g_rec_type
  ,p_effective_date          in            date
  ,p_datetrack_mode          in            varchar2
  ,p_validation_start_date   in            date
  ,p_validation_end_date     in            date
  ) is
--
  l_proc	varchar2(72) := g_package||'dt_pre_delete';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (p_datetrack_mode <> hr_api.g_zap) then
    --
    p_rec.effective_start_date
      := pay_opm_shd.g_old_rec.effective_start_date;
    --
    If (p_datetrack_mode = hr_api.g_delete) then
      p_rec.effective_end_date := p_validation_start_date - 1;
    Else
      p_rec.effective_end_date := p_validation_end_date;
    End If;
    --
    -- Update the current effective end date record
    --
    pay_opm_shd.upd_effective_end_date
      (p_effective_date	        => p_effective_date
      ,p_base_key_value	        => p_rec.org_payment_method_id
      ,p_new_effective_end_date => p_rec.effective_end_date
      ,p_validation_start_date  => p_validation_start_date
      ,p_validation_end_date	=> p_validation_end_date
      ,p_object_version_number            => p_rec.object_version_number
      );
  Else
    p_rec.effective_start_date := null;
    p_rec.effective_end_date   := null;
  End If;
  hr_utility.set_location(' Leaving:'||l_proc, 10);
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
  (p_rec                   in out nocopy pay_opm_shd.g_rec_type
  ,p_effective_date        in            date
  ,p_datetrack_mode        in            varchar2
  ,p_validation_start_date in            date
  ,p_validation_end_date   in            date
  ) is
--
  l_proc	varchar2(72) := g_package||'pre_delete';
--
-- Cursor C_Sel1 select comments to be deleted
--
  Cursor C_Sel1 is
    select distinct t1.comment_id
    from   pay_org_payment_methods_f t1
    where  t1.comment_id is not null
    and    t1.org_payment_method_id = p_rec.org_payment_method_id
    and    t1.effective_start_date <= p_validation_end_date
    and    t1.effective_end_date   >= p_validation_start_date
    and    not exists
           (select 1
            from   pay_org_payment_methods_f t2
            where  t2.comment_id = t1.comment_id
            and    t2.org_payment_method_id = t1.org_payment_method_id
            and   (t2.effective_start_date > p_validation_end_date
            or    t2.effective_end_date   < p_validation_start_date));
--
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  -- Delete any possible comments
  --
  hr_utility.set_location('Start:'||to_char(p_validation_start_date),6);
  hr_utility.set_location('End:'||to_char(p_validation_end_date),7);
  --
  For Comm_Del In C_Sel1 Loop
    hr_utility.set_location('Comment ID:'||Comm_Del.comment_id,7);
    hr_comm_api.del(p_comment_id        => Comm_Del.comment_id);
  End Loop;
  --
  --
  pay_opm_del.dt_pre_delete
    (p_rec                   => p_rec
    ,p_effective_date        => p_effective_date
    ,p_datetrack_mode        => p_datetrack_mode
    ,p_validation_start_date => p_validation_start_date
    ,p_validation_end_date   => p_validation_end_date
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End pre_delete;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< post_delete >-------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This private procedure contains any processing which is required after the
--   delete dml.
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
  (p_rec                   in pay_opm_shd.g_rec_type
  ,p_effective_date        in date
  ,p_datetrack_mode        in varchar2
  ,p_validation_start_date in date
  ,p_validation_end_date   in date
  ) is
--
  l_proc	varchar2(72) := g_package||'post_delete';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
   begin
    --
    pay_opm_rkd.after_delete
      (p_effective_date
      => p_effective_date
      ,p_datetrack_mode
      => p_datetrack_mode
      ,p_validation_start_date
      => p_validation_start_date
      ,p_validation_end_date
      => p_validation_end_date
      ,p_org_payment_method_id
      => p_rec.org_payment_method_id
      ,p_effective_start_date
      => p_rec.effective_start_date
      ,p_effective_end_date
      => p_rec.effective_end_date
      ,p_effective_start_date_o
      => pay_opm_shd.g_old_rec.effective_start_date
      ,p_effective_end_date_o
      => pay_opm_shd.g_old_rec.effective_end_date
      ,p_business_group_id_o
      => pay_opm_shd.g_old_rec.business_group_id
      ,p_external_account_id_o
      => pay_opm_shd.g_old_rec.external_account_id
      ,p_currency_code_o
      => pay_opm_shd.g_old_rec.currency_code
      ,p_payment_type_id_o
      => pay_opm_shd.g_old_rec.payment_type_id
      ,p_defined_balance_id_o
      => pay_opm_shd.g_old_rec.defined_balance_id
      ,p_org_payment_method_name_o
      => pay_opm_shd.g_old_rec.org_payment_method_name
      ,p_comment_id_o
      => pay_opm_shd.g_old_rec.comment_id
      ,p_comments_o
      => pay_opm_shd.g_old_rec.comments
      ,p_attribute_category_o
      => pay_opm_shd.g_old_rec.attribute_category
      ,p_attribute1_o
      => pay_opm_shd.g_old_rec.attribute1
      ,p_attribute2_o
      => pay_opm_shd.g_old_rec.attribute2
      ,p_attribute3_o
      => pay_opm_shd.g_old_rec.attribute3
      ,p_attribute4_o
      => pay_opm_shd.g_old_rec.attribute4
      ,p_attribute5_o
      => pay_opm_shd.g_old_rec.attribute5
      ,p_attribute6_o
      => pay_opm_shd.g_old_rec.attribute6
      ,p_attribute7_o
      => pay_opm_shd.g_old_rec.attribute7
      ,p_attribute8_o
      => pay_opm_shd.g_old_rec.attribute8
      ,p_attribute9_o
      => pay_opm_shd.g_old_rec.attribute9
      ,p_attribute10_o
      => pay_opm_shd.g_old_rec.attribute10
      ,p_attribute11_o
      => pay_opm_shd.g_old_rec.attribute11
      ,p_attribute12_o
      => pay_opm_shd.g_old_rec.attribute12
      ,p_attribute13_o
      => pay_opm_shd.g_old_rec.attribute13
      ,p_attribute14_o
      => pay_opm_shd.g_old_rec.attribute14
      ,p_attribute15_o
      => pay_opm_shd.g_old_rec.attribute15
      ,p_attribute16_o
      => pay_opm_shd.g_old_rec.attribute16
      ,p_attribute17_o
      => pay_opm_shd.g_old_rec.attribute17
      ,p_attribute18_o
      => pay_opm_shd.g_old_rec.attribute18
      ,p_attribute19_o
      => pay_opm_shd.g_old_rec.attribute19
      ,p_attribute20_o
      => pay_opm_shd.g_old_rec.attribute20
      ,p_pmeth_information_category_o
      => pay_opm_shd.g_old_rec.pmeth_information_category
      ,p_pmeth_information1_o
      => pay_opm_shd.g_old_rec.pmeth_information1
      ,p_pmeth_information2_o
      => pay_opm_shd.g_old_rec.pmeth_information2
      ,p_pmeth_information3_o
      => pay_opm_shd.g_old_rec.pmeth_information3
      ,p_pmeth_information4_o
      => pay_opm_shd.g_old_rec.pmeth_information4
      ,p_pmeth_information5_o
      => pay_opm_shd.g_old_rec.pmeth_information5
      ,p_pmeth_information6_o
      => pay_opm_shd.g_old_rec.pmeth_information6
      ,p_pmeth_information7_o
      => pay_opm_shd.g_old_rec.pmeth_information7
      ,p_pmeth_information8_o
      => pay_opm_shd.g_old_rec.pmeth_information8
      ,p_pmeth_information9_o
      => pay_opm_shd.g_old_rec.pmeth_information9
      ,p_pmeth_information10_o
      => pay_opm_shd.g_old_rec.pmeth_information10
      ,p_pmeth_information11_o
      => pay_opm_shd.g_old_rec.pmeth_information11
      ,p_pmeth_information12_o
      => pay_opm_shd.g_old_rec.pmeth_information12
      ,p_pmeth_information13_o
      => pay_opm_shd.g_old_rec.pmeth_information13
      ,p_pmeth_information14_o
      => pay_opm_shd.g_old_rec.pmeth_information14
      ,p_pmeth_information15_o
      => pay_opm_shd.g_old_rec.pmeth_information15
      ,p_pmeth_information16_o
      => pay_opm_shd.g_old_rec.pmeth_information16
      ,p_pmeth_information17_o
      => pay_opm_shd.g_old_rec.pmeth_information17
      ,p_pmeth_information18_o
      => pay_opm_shd.g_old_rec.pmeth_information18
      ,p_pmeth_information19_o
      => pay_opm_shd.g_old_rec.pmeth_information19
      ,p_pmeth_information20_o
      => pay_opm_shd.g_old_rec.pmeth_information20
      ,p_object_version_number_o
      => pay_opm_shd.g_old_rec.object_version_number
      ,p_transfer_to_gl_flag_o
      => pay_opm_shd.g_old_rec.transfer_to_gl_flag
      ,p_cost_payment_o
      => pay_opm_shd.g_old_rec.cost_payment
      ,p_cost_cleared_payment_o
      => pay_opm_shd.g_old_rec.cost_cleared_payment
      ,p_cost_cleared_void_payment_o
      => pay_opm_shd.g_old_rec.cost_cleared_void_payment
      ,p_exclude_manual_payment_o
      => pay_opm_shd.g_old_rec.exclude_manual_payment
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PAY_ORG_PAYMENT_METHODS_F'
        ,p_hook_type   => 'AD');
      --
  end;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End post_delete;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< del >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure del
  (p_effective_date in            date
  ,p_datetrack_mode in            varchar2
  ,p_rec            in out nocopy pay_opm_shd.g_rec_type
  ) is
--
  l_proc			varchar2(72) := g_package||'del';
  l_validation_start_date	date;
  l_validation_end_date		date;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Ensure that the DateTrack delete mode is valid
  --
  dt_api.validate_dt_del_mode(p_datetrack_mode => p_datetrack_mode);
  --
  -- We must lock the row which we need to delete.
  --
  pay_opm_shd.lck
    (p_effective_date                   => p_effective_date
    ,p_datetrack_mode                   => p_datetrack_mode
    ,p_org_payment_method_id            => p_rec.org_payment_method_id
    ,p_object_version_number            => p_rec.object_version_number
    ,p_validation_start_date            => l_validation_start_date
    ,p_validation_end_date              => l_validation_end_date
    );
  --
  -- Call the supporting delete validate operation
  --
  pay_opm_bus.delete_validate
    (p_rec                              => p_rec
    ,p_effective_date                   => p_effective_date
    ,p_datetrack_mode                   => p_datetrack_mode
    ,p_validation_start_date            => l_validation_start_date
    ,p_validation_end_date              => l_validation_end_date
    );
  --
  -- Call the supporting pre-delete operation
  --
  pay_opm_del.pre_delete
    (p_rec                              => p_rec
    ,p_effective_date                   => p_effective_date
    ,p_datetrack_mode                   => p_datetrack_mode
    ,p_validation_start_date            => l_validation_start_date
    ,p_validation_end_date              => l_validation_end_date
    );
  --
  -- Delete the row.
  --
  pay_opm_del.delete_dml
    (p_rec                              => p_rec
    ,p_effective_date                   => p_effective_date
    ,p_datetrack_mode                   => p_datetrack_mode
    ,p_validation_start_date            => l_validation_start_date
    ,p_validation_end_date              => l_validation_end_date
    );
  -- Call the supporting post-delete operation
  --
  pay_opm_del.post_delete
    (p_rec                              => p_rec
    ,p_effective_date                   => p_effective_date
    ,p_datetrack_mode                   => p_datetrack_mode
    ,p_validation_start_date            => l_validation_start_date
    ,p_validation_end_date              => l_validation_end_date
    );
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
  ,p_org_payment_method_id            in     number
  ,p_object_version_number            in out nocopy number
  ,p_effective_start_date                out nocopy date
  ,p_effective_end_date	                 out nocopy date
  ) is
--
  cursor csr_bus_grp is
    select opm.business_group_id
      from pay_org_payment_methods_f opm
     where opm.org_payment_method_id = p_org_payment_method_id;
--
  l_rec		pay_opm_shd.g_rec_type;
  l_proc	varchar2(72) := g_package||'del';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- As the delete procedure accepts a plsql record structure we do need to
  -- convert the  arguments into the record structure.
  -- We don't need to call the supplied conversion argument routine as we
  -- only need a few attributes.
  --
  l_rec.org_payment_method_id		:= p_org_payment_method_id;
  l_rec.object_version_number 	:= p_object_version_number;
  open csr_bus_grp;
  fetch csr_bus_grp into l_rec.business_group_id;
  --
  if csr_bus_grp%notfound then
     --
     close csr_bus_grp;
     --
     -- The primary key is invalid therefore we must error
     --
     fnd_message.set_name('PAY','HR_7220_INVALID_PRIMARY_KEY');
     fnd_message.raise_error;
     --
  end if;
  close csr_bus_grp;
  --
  -- Having converted the arguments into the pay_opm_rec
  -- plsql record structure we must call the corresponding entity
  -- business process
  --
  pay_opm_del.del
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
end pay_opm_del;

/
