--------------------------------------------------------
--  DDL for Package Body PAY_PBC_DEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_PBC_DEL" as
/* $Header: pypbcrhi.pkb 120.0 2005/05/29 07:19:45 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  pay_pbc_del.';  -- Global package name
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
  (p_rec                     in out nocopy pay_pbc_shd.g_rec_type
  ,p_effective_date          in date
  ,p_datetrack_mode          in varchar2
  ,p_validation_start_date   in date
  ,p_validation_end_date     in date
  ) is
--
  l_proc        varchar2(72) := g_package||'dt_delete_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  If (p_datetrack_mode = hr_api.g_delete_next_change) then
    --
    --
    -- Delete the where the effective start date is equal
    -- to the validation end date.
    --
    delete from pay_balance_categories_f
    where       balance_category_id = p_rec.balance_category_id
    and   effective_start_date = p_validation_start_date;
    --
    --
  Else
    --
    --
    -- Delete the row(s) where the effective start date is greater than
    -- or equal to the validation start date.
    --
    delete from pay_balance_categories_f
    where        balance_category_id = p_rec.balance_category_id
    and   effective_start_date >= p_validation_start_date;
    --
    --
  End If;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 20);
--
End dt_delete_dml;
--
-- ----------------------------------------------------------------------------
-- ----------------------< delete_app_ownerships >----------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--   Deletes row(s) from hr_application_ownerships depending on the mode that
--   the row handler has been called in.
--
-- ----------------------------------------------------------------------------
PROCEDURE delete_app_ownerships(p_pk_column      IN varchar2
                               ,p_pk_value       IN varchar2
			       ,p_datetrack_mode IN varchar2) IS
--
BEGIN
  --
  IF ((hr_startup_data_api_support.return_startup_mode
                           IN ('STARTUP','GENERIC')) AND
     p_datetrack_mode = hr_api.g_zap) THEN
     --
     DELETE FROM hr_application_ownerships
      WHERE key_name = p_pk_column
        AND key_value = p_pk_value;
     --
  END IF;
END delete_app_ownerships;
--
-- ----------------------------------------------------------------------------
-- ----------------------< delete_app_ownerships >----------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE delete_app_ownerships(p_pk_column      IN varchar2
                               ,p_pk_value       IN number
			       ,p_datetrack_mode IN varchar2) IS
--
BEGIN
  delete_app_ownerships(p_pk_column, to_char(p_pk_value), p_datetrack_mode);
END delete_app_ownerships;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< delete_dml >------------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_dml
  (p_rec                     in out nocopy pay_pbc_shd.g_rec_type
  ,p_effective_date          in date
  ,p_datetrack_mode          in varchar2
  ,p_validation_start_date   in date
  ,p_validation_end_date     in date
  ) is
--
  l_proc        varchar2(72) := g_package||'delete_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  pay_pbc_del.dt_delete_dml
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
  (p_rec                     in out nocopy pay_pbc_shd.g_rec_type
  ,p_effective_date          in date
  ,p_datetrack_mode          in varchar2
  ,p_validation_start_date   in date
  ,p_validation_end_date     in date
  ) is
--
  l_proc        varchar2(72) := g_package||'dt_pre_delete';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (p_datetrack_mode <> hr_api.g_zap) then
    --
    p_rec.effective_start_date
      := pay_pbc_shd.g_old_rec.effective_start_date;
    --
    If (p_datetrack_mode = hr_api.g_delete) then
      p_rec.effective_end_date := p_validation_start_date - 1;
    Else
      p_rec.effective_end_date := p_validation_end_date;
    End If;
    --
    -- Update the current effective end date record
    --
    pay_pbc_shd.upd_effective_end_date
      (p_effective_date         => p_effective_date
      ,p_base_key_value         => p_rec.balance_category_id
      ,p_new_effective_end_date => p_rec.effective_end_date
      ,p_validation_start_date  => p_validation_start_date
      ,p_validation_end_date    => p_validation_end_date
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
  (p_rec                   in out nocopy pay_pbc_shd.g_rec_type
  ,p_effective_date        in date
  ,p_datetrack_mode        in varchar2
  ,p_validation_start_date in date
  ,p_validation_end_date   in date
  ) is
--
  l_proc        varchar2(72) := g_package||'pre_delete';
--
  --
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
--
  --
  pay_pbc_del.dt_pre_delete
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
  (p_rec                   in pay_pbc_shd.g_rec_type
  ,p_effective_date        in date
  ,p_datetrack_mode        in varchar2
  ,p_validation_start_date in date
  ,p_validation_end_date   in date
  ) is
--
  l_proc        varchar2(72) := g_package||'post_delete';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
   begin
      --
    -- Delete ownerships if applicable
    delete_app_ownerships
      ('BALANCE_CATEGORY_ID'
      ,p_rec.balance_category_id
      ,p_datetrack_mode
      );
    --
    pay_pbc_rkd.after_delete
      (p_effective_date
      => p_effective_date
      ,p_datetrack_mode
      => p_datetrack_mode
      ,p_validation_start_date
      => p_validation_start_date
      ,p_validation_end_date
      => p_validation_end_date
      ,p_balance_category_id
      => p_rec.balance_category_id
      ,p_effective_start_date
      => p_rec.effective_start_date
      ,p_effective_end_date
      => p_rec.effective_end_date
      ,p_object_version_number
      => p_rec.object_version_number
      ,p_category_name_o
      => pay_pbc_shd.g_old_rec.category_name
      ,p_effective_start_date_o
      => pay_pbc_shd.g_old_rec.effective_start_date
      ,p_effective_end_date_o
      => pay_pbc_shd.g_old_rec.effective_end_date
      ,p_legislation_code_o
      => pay_pbc_shd.g_old_rec.legislation_code
      ,p_business_group_id_o
      => pay_pbc_shd.g_old_rec.business_group_id
      ,p_save_run_balance_enabled_o
      => pay_pbc_shd.g_old_rec.save_run_balance_enabled
      ,p_user_category_name_o
      => pay_pbc_shd.g_old_rec.user_category_name
      ,p_pbc_information_category_o
      => pay_pbc_shd.g_old_rec.pbc_information_category
      ,p_pbc_information1_o
      => pay_pbc_shd.g_old_rec.pbc_information1
      ,p_pbc_information2_o
      => pay_pbc_shd.g_old_rec.pbc_information2
      ,p_pbc_information3_o
      => pay_pbc_shd.g_old_rec.pbc_information3
      ,p_pbc_information4_o
      => pay_pbc_shd.g_old_rec.pbc_information4
      ,p_pbc_information5_o
      => pay_pbc_shd.g_old_rec.pbc_information5
      ,p_pbc_information6_o
      => pay_pbc_shd.g_old_rec.pbc_information6
      ,p_pbc_information7_o
      => pay_pbc_shd.g_old_rec.pbc_information7
      ,p_pbc_information8_o
      => pay_pbc_shd.g_old_rec.pbc_information8
      ,p_pbc_information9_o
      => pay_pbc_shd.g_old_rec.pbc_information9
      ,p_pbc_information10_o
      => pay_pbc_shd.g_old_rec.pbc_information10
      ,p_pbc_information11_o
      => pay_pbc_shd.g_old_rec.pbc_information11
      ,p_pbc_information12_o
      => pay_pbc_shd.g_old_rec.pbc_information12
      ,p_pbc_information13_o
      => pay_pbc_shd.g_old_rec.pbc_information13
      ,p_pbc_information14_o
      => pay_pbc_shd.g_old_rec.pbc_information14
      ,p_pbc_information15_o
      => pay_pbc_shd.g_old_rec.pbc_information15
      ,p_pbc_information16_o
      => pay_pbc_shd.g_old_rec.pbc_information16
      ,p_pbc_information17_o
      => pay_pbc_shd.g_old_rec.pbc_information17
      ,p_pbc_information18_o
      => pay_pbc_shd.g_old_rec.pbc_information18
      ,p_pbc_information19_o
      => pay_pbc_shd.g_old_rec.pbc_information19
      ,p_pbc_information20_o
      => pay_pbc_shd.g_old_rec.pbc_information20
      ,p_pbc_information21_o
      => pay_pbc_shd.g_old_rec.pbc_information21
      ,p_pbc_information22_o
      => pay_pbc_shd.g_old_rec.pbc_information22
      ,p_pbc_information23_o
      => pay_pbc_shd.g_old_rec.pbc_information23
      ,p_pbc_information24_o
      => pay_pbc_shd.g_old_rec.pbc_information24
      ,p_pbc_information25_o
      => pay_pbc_shd.g_old_rec.pbc_information25
      ,p_pbc_information26_o
      => pay_pbc_shd.g_old_rec.pbc_information26
      ,p_pbc_information27_o
      => pay_pbc_shd.g_old_rec.pbc_information27
      ,p_pbc_information28_o
      => pay_pbc_shd.g_old_rec.pbc_information28
      ,p_pbc_information29_o
      => pay_pbc_shd.g_old_rec.pbc_information29
      ,p_pbc_information30_o
      => pay_pbc_shd.g_old_rec.pbc_information30
      ,p_object_version_number_o
      => pay_pbc_shd.g_old_rec.object_version_number
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PAY_BALANCE_CATEGORIES_F'
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
  (p_effective_date in     date
  ,p_datetrack_mode in     varchar2
  ,p_rec            in out nocopy pay_pbc_shd.g_rec_type
  ) is
--
  l_proc                        varchar2(72) := g_package||'del';
  l_validation_start_date       date;
  l_validation_end_date         date;
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
  pay_pbc_shd.lck
    (p_effective_date                   => p_effective_date
    ,p_datetrack_mode                   => p_datetrack_mode
    ,p_balance_category_id              => p_rec.balance_category_id
    ,p_object_version_number            => p_rec.object_version_number
    ,p_validation_start_date            => l_validation_start_date
    ,p_validation_end_date              => l_validation_end_date
    );
  --
  -- Call the supporting delete validate operation
  --
  pay_pbc_bus.delete_validate
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
  pay_pbc_del.pre_delete
    (p_rec                              => p_rec
    ,p_effective_date                   => p_effective_date
    ,p_datetrack_mode                   => p_datetrack_mode
    ,p_validation_start_date            => l_validation_start_date
    ,p_validation_end_date              => l_validation_end_date
    );
  --
  -- Delete the row.
  --
  pay_pbc_del.delete_dml
    (p_rec                              => p_rec
    ,p_effective_date                   => p_effective_date
    ,p_datetrack_mode                   => p_datetrack_mode
    ,p_validation_start_date            => l_validation_start_date
    ,p_validation_end_date              => l_validation_end_date
    );
  -- Call the supporting post-delete operation
  --
  pay_pbc_del.post_delete
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
  ,p_balance_category_id              in     number
  ,p_object_version_number            in out nocopy number
  ,p_effective_start_date                out nocopy date
  ,p_effective_end_date                  out nocopy date
  ) is
--
  l_rec         pay_pbc_shd.g_rec_type;
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
  l_rec.balance_category_id          := p_balance_category_id;
  l_rec.object_version_number     := p_object_version_number;
  --
  -- Having converted the arguments into the pay_pbc_rec
  -- plsql record structure we must call the corresponding entity
  -- business process
  --
  pay_pbc_del.del
     (p_effective_date
     ,p_datetrack_mode
     ,l_rec
     );
  --
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
end pay_pbc_del;

/