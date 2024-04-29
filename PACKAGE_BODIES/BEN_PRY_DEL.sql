--------------------------------------------------------
--  DDL for Package Body BEN_PRY_DEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PRY_DEL" as
/* $Header: bepryrhi.pkb 120.5.12010000.3 2008/08/05 15:23:35 ubhat ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  ben_pry_del.';  -- Global package name
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
  (p_rec                     in out nocopy ben_pry_shd.g_rec_type
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
    ben_pry_shd.g_api_dml := true;  -- Set the api dml status
    --
    -- Delete the where the effective start date is equal
    -- to the validation end date.
    --
    delete from ben_prtt_rmt_aprvd_fr_pymt_f
    where       prtt_rmt_aprvd_fr_pymt_id = p_rec.prtt_rmt_aprvd_fr_pymt_id
    and   effective_start_date = p_validation_start_date;
    --
    ben_pry_shd.g_api_dml := false;   -- Unset the api dml status
  Else
    ben_pry_shd.g_api_dml := true;  -- Set the api dml status
    --
    -- Delete the row(s) where the effective start date is greater than
    -- or equal to the validation start date.
    --
    delete from ben_prtt_rmt_aprvd_fr_pymt_f
    where        prtt_rmt_aprvd_fr_pymt_id = p_rec.prtt_rmt_aprvd_fr_pymt_id
    and   effective_start_date >= p_validation_start_date;
    --
    ben_pry_shd.g_api_dml := false;   -- Unset the api dml status
  End If;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 20);
--
Exception
  When Others Then
    ben_pry_shd.g_api_dml := false;   -- Unset the api dml status
    Raise;
--
End dt_delete_dml;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< delete_dml >------------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_dml
  (p_rec                     in out nocopy ben_pry_shd.g_rec_type
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
  ben_pry_del.dt_delete_dml
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
  (p_rec                     in out nocopy ben_pry_shd.g_rec_type
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
      := ben_pry_shd.g_old_rec.effective_start_date;
    --
    If (p_datetrack_mode = hr_api.g_delete) then
      p_rec.effective_end_date := p_validation_start_date - 1;
    Else
      p_rec.effective_end_date := p_validation_end_date;
    End If;
    --
    -- Update the current effective end date record
    --
    ben_pry_shd.upd_effective_end_date
      (p_effective_date         => p_effective_date
      ,p_base_key_value         => p_rec.prtt_rmt_aprvd_fr_pymt_id
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
  (p_rec                   in out nocopy ben_pry_shd.g_rec_type
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
  ben_pry_del.dt_pre_delete
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
  (p_rec                   in ben_pry_shd.g_rec_type
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
    ben_pry_rkd.after_delete
      (p_effective_date
      => p_effective_date
      ,p_datetrack_mode
      => p_datetrack_mode
      ,p_validation_start_date
      => p_validation_start_date
      ,p_validation_end_date
      => p_validation_end_date
      ,p_prtt_rmt_aprvd_fr_pymt_id
      => p_rec.prtt_rmt_aprvd_fr_pymt_id
      ,p_effective_start_date
      => p_rec.effective_start_date
      ,p_effective_end_date
      => p_rec.effective_end_date
      ,p_prtt_reimbmt_rqst_id_o
      => ben_pry_shd.g_old_rec.prtt_reimbmt_rqst_id
      ,p_effective_start_date_o
      => ben_pry_shd.g_old_rec.effective_start_date
      ,p_effective_end_date_o
      => ben_pry_shd.g_old_rec.effective_end_date
      ,p_apprvd_fr_pymt_num_o
      => ben_pry_shd.g_old_rec.apprvd_fr_pymt_num
      ,p_adjmt_flag_o
      => ben_pry_shd.g_old_rec.adjmt_flag
      ,p_aprvd_fr_pymt_amt_o
      => ben_pry_shd.g_old_rec.aprvd_fr_pymt_amt
      ,p_pymt_stat_cd_o
      => ben_pry_shd.g_old_rec.pymt_stat_cd
      ,p_pymt_stat_rsn_cd_o
      => ben_pry_shd.g_old_rec.pymt_stat_rsn_cd
      ,p_pymt_stat_ovrdn_rsn_cd_o
      => ben_pry_shd.g_old_rec.pymt_stat_ovrdn_rsn_cd
      ,p_pymt_stat_prr_to_ovrd_cd_o
      => ben_pry_shd.g_old_rec.pymt_stat_prr_to_ovrd_cd
      ,p_business_group_id_o
      => ben_pry_shd.g_old_rec.business_group_id
      ,p_element_entry_value_id_o => ben_pry_shd.g_old_rec.element_entry_value_id
      ,p_pry_attribute_category_o
      => ben_pry_shd.g_old_rec.pry_attribute_category
      ,p_pry_attribute1_o
      => ben_pry_shd.g_old_rec.pry_attribute1
      ,p_pry_attribute2_o
      => ben_pry_shd.g_old_rec.pry_attribute2
      ,p_pry_attribute3_o
      => ben_pry_shd.g_old_rec.pry_attribute3
      ,p_pry_attribute4_o
      => ben_pry_shd.g_old_rec.pry_attribute4
      ,p_pry_attribute5_o
      => ben_pry_shd.g_old_rec.pry_attribute5
      ,p_pry_attribute6_o
      => ben_pry_shd.g_old_rec.pry_attribute6
      ,p_pry_attribute7_o
      => ben_pry_shd.g_old_rec.pry_attribute7
      ,p_pry_attribute8_o
      => ben_pry_shd.g_old_rec.pry_attribute8
      ,p_pry_attribute9_o
      => ben_pry_shd.g_old_rec.pry_attribute9
      ,p_pry_attribute10_o
      => ben_pry_shd.g_old_rec.pry_attribute10
      ,p_pry_attribute11_o
      => ben_pry_shd.g_old_rec.pry_attribute11
      ,p_pry_attribute12_o
      => ben_pry_shd.g_old_rec.pry_attribute12
      ,p_pry_attribute13_o
      => ben_pry_shd.g_old_rec.pry_attribute13
      ,p_pry_attribute14_o
      => ben_pry_shd.g_old_rec.pry_attribute14
      ,p_pry_attribute15_o
      => ben_pry_shd.g_old_rec.pry_attribute15
      ,p_pry_attribute16_o
      => ben_pry_shd.g_old_rec.pry_attribute16
      ,p_pry_attribute17_o
      => ben_pry_shd.g_old_rec.pry_attribute17
      ,p_pry_attribute18_o
      => ben_pry_shd.g_old_rec.pry_attribute18
      ,p_pry_attribute19_o
      => ben_pry_shd.g_old_rec.pry_attribute19
      ,p_pry_attribute20_o
      => ben_pry_shd.g_old_rec.pry_attribute20
      ,p_pry_attribute21_o
      => ben_pry_shd.g_old_rec.pry_attribute21
      ,p_pry_attribute22_o
      => ben_pry_shd.g_old_rec.pry_attribute22
      ,p_pry_attribute23_o
      => ben_pry_shd.g_old_rec.pry_attribute23
      ,p_pry_attribute24_o
      => ben_pry_shd.g_old_rec.pry_attribute24
      ,p_pry_attribute25_o
      => ben_pry_shd.g_old_rec.pry_attribute25
      ,p_pry_attribute26_o
      => ben_pry_shd.g_old_rec.pry_attribute26
      ,p_pry_attribute27_o
      => ben_pry_shd.g_old_rec.pry_attribute27
      ,p_pry_attribute28_o
      => ben_pry_shd.g_old_rec.pry_attribute28
      ,p_pry_attribute29_o
      => ben_pry_shd.g_old_rec.pry_attribute29
      ,p_pry_attribute30_o
      => ben_pry_shd.g_old_rec.pry_attribute30
      ,p_object_version_number_o
      => ben_pry_shd.g_old_rec.object_version_number
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'BEN_PRTT_RMT_APRVD_FR_PYMT_F'
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
  ,p_rec            in out nocopy ben_pry_shd.g_rec_type
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
  ben_pry_shd.lck
    (p_effective_date                   => p_effective_date
    ,p_datetrack_mode                   => p_datetrack_mode
    ,p_prtt_rmt_aprvd_fr_pymt_id        => p_rec.prtt_rmt_aprvd_fr_pymt_id
    ,p_object_version_number            => p_rec.object_version_number
    ,p_validation_start_date            => l_validation_start_date
    ,p_validation_end_date              => l_validation_end_date
    );
  --
  -- Call the supporting delete validate operation
  --
  ben_pry_bus.delete_validate
    (p_rec                              => p_rec
    ,p_effective_date                   => p_effective_date
    ,p_datetrack_mode                   => p_datetrack_mode
    ,p_validation_start_date            => l_validation_start_date
    ,p_validation_end_date              => l_validation_end_date
    );
  --
  -- Call the supporting pre-delete operation
  --
  ben_pry_del.pre_delete
    (p_rec                              => p_rec
    ,p_effective_date                   => p_effective_date
    ,p_datetrack_mode                   => p_datetrack_mode
    ,p_validation_start_date            => l_validation_start_date
    ,p_validation_end_date              => l_validation_end_date
    );
  --
  -- Delete the row.
  --
  ben_pry_del.delete_dml
    (p_rec                              => p_rec
    ,p_effective_date                   => p_effective_date
    ,p_datetrack_mode                   => p_datetrack_mode
    ,p_validation_start_date            => l_validation_start_date
    ,p_validation_end_date              => l_validation_end_date
    );
  -- Call the supporting post-delete operation
  --
  ben_pry_del.post_delete
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
  ,p_prtt_rmt_aprvd_fr_pymt_id        in     number
  ,p_object_version_number            in out nocopy number
  ,p_effective_start_date                out nocopy date
  ,p_effective_end_date                  out nocopy date
  ) is
--
  l_rec         ben_pry_shd.g_rec_type;
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
  l_rec.prtt_rmt_aprvd_fr_pymt_id          := p_prtt_rmt_aprvd_fr_pymt_id;
  l_rec.object_version_number     := p_object_version_number;
  --
  -- Having converted the arguments into the ben_pry_rec
  -- plsql record structure we must call the corresponding entity
  -- business process
  --
  ben_pry_del.del
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
end ben_pry_del;

/
