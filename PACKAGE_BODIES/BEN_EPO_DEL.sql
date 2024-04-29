--------------------------------------------------------
--  DDL for Package Body BEN_EPO_DEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_EPO_DEL" as
/* $Header: beeporhi.pkb 120.0 2005/05/28 02:42:27 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)    := '  ben_epo_del.';  -- Global package name
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
--   A Pl/Sql record structre.
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
    (p_rec              in out nocopy ben_epo_shd.g_rec_type,
     p_effective_date     in    date,
     p_datetrack_mode     in    varchar2,
     p_validation_start_date in    date,
     p_validation_end_date     in    date) is
--
  l_proc    varchar2(72) := g_package||'dt_delete_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  If (p_datetrack_mode = 'DELETE_NEXT_CHANGE') then
    hr_utility.set_location(l_proc, 10);
    ben_epo_shd.g_api_dml := true;  -- Set the api dml status
    --
    -- Delete the where the effective start date is equal
    -- to the validation end date.
    --
    delete from ben_elig_per_opt_f
    where       elig_per_opt_id = p_rec.elig_per_opt_id
    and      effective_start_date = p_validation_start_date;
    --
    ben_epo_shd.g_api_dml := false;   -- Unset the api dml status
  Else
    hr_utility.set_location(l_proc, 15);
    ben_epo_shd.g_api_dml := true;  -- Set the api dml status
    --
    -- Delete the row(s) where the effective start date is greater than
    -- or equal to the validation start date.
    --
    delete from ben_elig_per_opt_f
    where        elig_per_opt_id = p_rec.elig_per_opt_id
    and      effective_start_date >= p_validation_start_date;
    --
    ben_epo_shd.g_api_dml := false;   -- Unset the api dml status
  End If;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 20);
--
Exception
  When Others Then
    ben_epo_shd.g_api_dml := false;   -- Unset the api dml status
    Raise;
End dt_delete_dml;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< delete_dml >------------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_dml
    (p_rec              in out nocopy ben_epo_shd.g_rec_type,
     p_effective_date     in    date,
     p_datetrack_mode     in    varchar2,
     p_validation_start_date in    date,
     p_validation_end_date     in    date) is
--
  l_proc    varchar2(72) := g_package||'delete_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  dt_delete_dml(p_rec            => p_rec,
        p_effective_date    => p_effective_date,
        p_datetrack_mode    => p_datetrack_mode,
               p_validation_start_date    => p_validation_start_date,
        p_validation_end_date    => p_validation_end_date);
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
--   A Pl/Sql record structre.
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
    (p_rec              in out nocopy ben_epo_shd.g_rec_type,
     p_effective_date     in    date,
     p_datetrack_mode     in    varchar2,
     p_validation_start_date in    date,
     p_validation_end_date     in    date) is
--
  l_proc    varchar2(72) := g_package||'dt_pre_delete';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (p_datetrack_mode <> 'ZAP') then
    --
    p_rec.effective_start_date := ben_epo_shd.g_old_rec.effective_start_date;
    --
    If (p_datetrack_mode = 'DELETE') then
      p_rec.effective_end_date := p_validation_start_date - 1;
    Else
      p_rec.effective_end_date := p_validation_end_date;
    End If;
    --
    -- Update the current effective end date record
    --
    ben_epo_shd.upd_effective_end_date
      (p_effective_date            => p_effective_date,
       p_base_key_value            => p_rec.elig_per_opt_id,
       p_new_effective_end_date => p_rec.effective_end_date,
       p_validation_start_date  => p_validation_start_date,
       p_validation_end_date    => p_validation_end_date,
       p_object_version_number  => p_rec.object_version_number);
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
--   A Pl/Sql record structre.
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
    (p_rec              in out nocopy ben_epo_shd.g_rec_type,
     p_effective_date     in    date,
     p_datetrack_mode     in    varchar2,
     p_validation_start_date in    date,
     p_validation_end_date     in    date) is
--
  l_proc    varchar2(72) := g_package||'pre_delete';
--
  --
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  --
  dt_pre_delete
    (p_rec              => p_rec,
     p_effective_date         => p_effective_date,
     p_datetrack_mode         => p_datetrack_mode,
     p_validation_start_date => p_validation_start_date,
     p_validation_end_date   => p_validation_end_date);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End pre_delete;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< post_delete >------------------------------|
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
--   A Pl/Sql record structre.
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
    (p_rec              in ben_epo_shd.g_rec_type,
     p_effective_date     in date,
     p_datetrack_mode     in varchar2,
     p_validation_start_date in date,
     p_validation_end_date     in date) is
--
  l_proc    varchar2(72) := g_package||'post_delete';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
--
  --
  -- Start of API User Hook for post_delete.
  --
  begin
    --
    ben_epo_rkd.after_delete
      (
  p_elig_per_opt_id               =>p_rec.elig_per_opt_id
 ,p_datetrack_mode                =>p_datetrack_mode
 ,p_validation_start_date         =>p_validation_start_date
 ,p_validation_end_date           =>p_validation_end_date
 ,p_effective_start_date          =>p_rec.effective_start_date
 ,p_effective_end_date            =>p_rec.effective_end_date
 ,p_elig_per_id_o                 =>ben_epo_shd.g_old_rec.elig_per_id
 ,p_effective_start_date_o        =>ben_epo_shd.g_old_rec.effective_start_date
 ,p_effective_end_date_o          =>ben_epo_shd.g_old_rec.effective_end_date
 ,p_prtn_ovridn_flag_o            =>ben_epo_shd.g_old_rec.prtn_ovridn_flag
 ,p_prtn_ovridn_thru_dt_o         =>ben_epo_shd.g_old_rec.prtn_ovridn_thru_dt
 ,p_no_mx_prtn_ovrid_thru_flag_o  =>ben_epo_shd.g_old_rec.no_mx_prtn_ovrid_thru_flag
 ,p_elig_flag_o                   =>ben_epo_shd.g_old_rec.elig_flag
 ,p_prtn_strt_dt_o                =>ben_epo_shd.g_old_rec.prtn_strt_dt
 ,p_prtn_end_dt_o                 =>ben_epo_shd.g_old_rec.prtn_end_dt
 ,p_wait_perd_cmpltn_date_o         =>ben_epo_shd.g_old_rec.wait_perd_cmpltn_date
 ,p_wait_perd_strt_dt_o           =>ben_epo_shd.g_old_rec.wait_perd_strt_dt
 ,p_prtn_ovridn_rsn_cd_o          =>ben_epo_shd.g_old_rec.prtn_ovridn_rsn_cd
 ,p_pct_fl_tm_val_o               =>ben_epo_shd.g_old_rec.pct_fl_tm_val
 ,p_opt_id_o                      =>ben_epo_shd.g_old_rec.opt_id
 ,p_per_in_ler_id_o               =>ben_epo_shd.g_old_rec.per_in_ler_id
 ,p_rt_comp_ref_amt_o             =>ben_epo_shd.g_old_rec.rt_comp_ref_amt
 ,p_rt_cmbn_age_n_los_val_o       =>ben_epo_shd.g_old_rec.rt_cmbn_age_n_los_val
 ,p_rt_comp_ref_uom_o             =>ben_epo_shd.g_old_rec.rt_comp_ref_uom
 ,p_rt_age_val_o                  =>ben_epo_shd.g_old_rec.rt_age_val
 ,p_rt_los_val_o                  =>ben_epo_shd.g_old_rec.rt_los_val
 ,p_rt_hrs_wkd_val_o              =>ben_epo_shd.g_old_rec.rt_hrs_wkd_val
 ,p_rt_hrs_wkd_bndry_perd_cd_o    =>ben_epo_shd.g_old_rec.rt_hrs_wkd_bndry_perd_cd
 ,p_rt_age_uom_o                  =>ben_epo_shd.g_old_rec.rt_age_uom
 ,p_rt_los_uom_o                  =>ben_epo_shd.g_old_rec.rt_los_uom
 ,p_rt_pct_fl_tm_val_o            =>ben_epo_shd.g_old_rec.rt_pct_fl_tm_val
 ,p_rt_frz_los_flag_o             =>ben_epo_shd.g_old_rec.rt_frz_los_flag
 ,p_rt_frz_age_flag_o             =>ben_epo_shd.g_old_rec.rt_frz_age_flag
 ,p_rt_frz_cmp_lvl_flag_o         =>ben_epo_shd.g_old_rec.rt_frz_cmp_lvl_flag
 ,p_rt_frz_pct_fl_tm_flag_o       =>ben_epo_shd.g_old_rec.rt_frz_pct_fl_tm_flag
 ,p_rt_frz_hrs_wkd_flag_o         =>ben_epo_shd.g_old_rec.rt_frz_hrs_wkd_flag
 ,p_rt_frz_comb_age_and_los_fl_o  =>ben_epo_shd.g_old_rec.rt_frz_comb_age_and_los_flag
 ,p_comp_ref_amt_o                =>ben_epo_shd.g_old_rec.comp_ref_amt
 ,p_cmbn_age_n_los_val_o          =>ben_epo_shd.g_old_rec.cmbn_age_n_los_val
 ,p_comp_ref_uom_o                =>ben_epo_shd.g_old_rec.comp_ref_uom
 ,p_age_val_o                     =>ben_epo_shd.g_old_rec.age_val
 ,p_los_val_o                     =>ben_epo_shd.g_old_rec.los_val
 ,p_hrs_wkd_val_o                 =>ben_epo_shd.g_old_rec.hrs_wkd_val
 ,p_hrs_wkd_bndry_perd_cd_o       =>ben_epo_shd.g_old_rec.hrs_wkd_bndry_perd_cd
 ,p_age_uom_o                     =>ben_epo_shd.g_old_rec.age_uom
 ,p_los_uom_o                     =>ben_epo_shd.g_old_rec.los_uom
 ,p_frz_los_flag_o                =>ben_epo_shd.g_old_rec.frz_los_flag
 ,p_frz_age_flag_o                =>ben_epo_shd.g_old_rec.frz_age_flag
 ,p_frz_cmp_lvl_flag_o            =>ben_epo_shd.g_old_rec.frz_cmp_lvl_flag
 ,p_frz_pct_fl_tm_flag_o          =>ben_epo_shd.g_old_rec.frz_pct_fl_tm_flag
 ,p_frz_hrs_wkd_flag_o            =>ben_epo_shd.g_old_rec.frz_hrs_wkd_flag
 ,p_frz_comb_age_and_los_flag_o   =>ben_epo_shd.g_old_rec.frz_comb_age_and_los_flag
 ,p_ovrid_svc_dt_o                =>ben_epo_shd.g_old_rec.ovrid_svc_dt
 ,p_inelg_rsn_cd_o                =>ben_epo_shd.g_old_rec.inelg_rsn_cd
 ,p_once_r_cntug_cd_o             =>ben_epo_shd.g_old_rec.once_r_cntug_cd
 ,p_oipl_ordr_num_o               =>ben_epo_shd.g_old_rec.oipl_ordr_num
 ,p_business_group_id_o           =>ben_epo_shd.g_old_rec.business_group_id
 ,p_epo_attribute_category_o      =>ben_epo_shd.g_old_rec.epo_attribute_category
 ,p_epo_attribute1_o              =>ben_epo_shd.g_old_rec.epo_attribute1
 ,p_epo_attribute2_o              =>ben_epo_shd.g_old_rec.epo_attribute2
 ,p_epo_attribute3_o              =>ben_epo_shd.g_old_rec.epo_attribute3
 ,p_epo_attribute4_o              =>ben_epo_shd.g_old_rec.epo_attribute4
 ,p_epo_attribute5_o              =>ben_epo_shd.g_old_rec.epo_attribute5
 ,p_epo_attribute6_o              =>ben_epo_shd.g_old_rec.epo_attribute6
 ,p_epo_attribute7_o              =>ben_epo_shd.g_old_rec.epo_attribute7
 ,p_epo_attribute8_o              =>ben_epo_shd.g_old_rec.epo_attribute8
 ,p_epo_attribute9_o              =>ben_epo_shd.g_old_rec.epo_attribute9
 ,p_epo_attribute10_o             =>ben_epo_shd.g_old_rec.epo_attribute10
 ,p_epo_attribute11_o             =>ben_epo_shd.g_old_rec.epo_attribute11
 ,p_epo_attribute12_o             =>ben_epo_shd.g_old_rec.epo_attribute12
 ,p_epo_attribute13_o             =>ben_epo_shd.g_old_rec.epo_attribute13
 ,p_epo_attribute14_o             =>ben_epo_shd.g_old_rec.epo_attribute14
 ,p_epo_attribute15_o             =>ben_epo_shd.g_old_rec.epo_attribute15
 ,p_epo_attribute16_o             =>ben_epo_shd.g_old_rec.epo_attribute16
 ,p_epo_attribute17_o             =>ben_epo_shd.g_old_rec.epo_attribute17
 ,p_epo_attribute18_o             =>ben_epo_shd.g_old_rec.epo_attribute18
 ,p_epo_attribute19_o             =>ben_epo_shd.g_old_rec.epo_attribute19
 ,p_epo_attribute20_o             =>ben_epo_shd.g_old_rec.epo_attribute20
 ,p_epo_attribute21_o             =>ben_epo_shd.g_old_rec.epo_attribute21
 ,p_epo_attribute22_o             =>ben_epo_shd.g_old_rec.epo_attribute22
 ,p_epo_attribute23_o             =>ben_epo_shd.g_old_rec.epo_attribute23
 ,p_epo_attribute24_o             =>ben_epo_shd.g_old_rec.epo_attribute24
 ,p_epo_attribute25_o             =>ben_epo_shd.g_old_rec.epo_attribute25
 ,p_epo_attribute26_o             =>ben_epo_shd.g_old_rec.epo_attribute26
 ,p_epo_attribute27_o             =>ben_epo_shd.g_old_rec.epo_attribute27
 ,p_epo_attribute28_o             =>ben_epo_shd.g_old_rec.epo_attribute28
 ,p_epo_attribute29_o             =>ben_epo_shd.g_old_rec.epo_attribute29
 ,p_epo_attribute30_o             =>ben_epo_shd.g_old_rec.epo_attribute30
 ,p_request_id_o                  =>ben_epo_shd.g_old_rec.request_id
 ,p_program_application_id_o      =>ben_epo_shd.g_old_rec.program_application_id
 ,p_program_id_o                  =>ben_epo_shd.g_old_rec.program_id
 ,p_program_update_date_o         =>ben_epo_shd.g_old_rec.program_update_date
 ,p_object_version_number_o       =>ben_epo_shd.g_old_rec.object_version_number
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'ben_elig_per_opt_f'
        ,p_hook_type   => 'AD');
      --
  end;
  --
  -- End of API User Hook for post_delete.
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End post_delete;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< del >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure del
  (
  p_rec            in out nocopy     ben_epo_shd.g_rec_type,
  p_effective_date    in     date,
  p_datetrack_mode    in     varchar2
  ) is
--
  l_proc            varchar2(72) := g_package||'del';
  l_validation_start_date    date;
  l_validation_end_date        date;
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
  ben_epo_shd.lck
    (p_effective_date     => p_effective_date,
           p_datetrack_mode     => p_datetrack_mode,
           p_elig_per_opt_id     => p_rec.elig_per_opt_id,
           p_object_version_number => p_rec.object_version_number,
           p_validation_start_date => l_validation_start_date,
           p_validation_end_date     => l_validation_end_date);
  --
  -- Call the supporting delete validate operation
  --
  ben_epo_bus.delete_validate
    (p_rec             => p_rec,
     p_effective_date     => p_effective_date,
     p_datetrack_mode     => p_datetrack_mode,
     p_validation_start_date => l_validation_start_date,
     p_validation_end_date     => l_validation_end_date);
  --
  -- Call the supporting pre-delete operation
  --
  pre_delete
    (p_rec             => p_rec,
     p_effective_date     => p_effective_date,
     p_datetrack_mode     => p_datetrack_mode,
     p_validation_start_date => l_validation_start_date,
     p_validation_end_date     => l_validation_end_date);
  --
  -- Delete the row.
  --
  delete_dml
    (p_rec             => p_rec,
     p_effective_date     => p_effective_date,
     p_datetrack_mode     => p_datetrack_mode,
     p_validation_start_date => l_validation_start_date,
     p_validation_end_date     => l_validation_end_date);
  --
  -- Call the supporting post-delete operation
  --
  post_delete
    (p_rec             => p_rec,
     p_effective_date     => p_effective_date,
     p_datetrack_mode     => p_datetrack_mode,
     p_validation_start_date => l_validation_start_date,
     p_validation_end_date     => l_validation_end_date);
End del;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< del >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure del
  (
  p_elig_per_opt_id      in      number,
  p_effective_start_date     out nocopy date,
  p_effective_end_date         out nocopy date,
  p_object_version_number in out nocopy number,
  p_effective_date      in     date,
  p_datetrack_mode        in     varchar2
  ) is
--
  l_rec        ben_epo_shd.g_rec_type;
  l_proc    varchar2(72) := g_package||'del';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- As the delete procedure accepts a plsql record structure we do need to
  -- convert the  arguments into the record structure.
  -- We don't need to call the supplied conversion argument routine as we
  -- only need a few attributes.
  --
  l_rec.elig_per_opt_id        := p_elig_per_opt_id;
  l_rec.object_version_number     := p_object_version_number;
  --
  -- Having converted the arguments into the ben_epo_rec
  -- plsql record structure we must call the corresponding entity
  -- business process
  --
  del(l_rec, p_effective_date, p_datetrack_mode);
  --
  -- Set the out arguments
  --
  p_object_version_number := l_rec.object_version_number;
  p_effective_start_date  := l_rec.effective_start_date;
  p_effective_end_date    := l_rec.effective_end_date;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End del;
--
end ben_epo_del;

/
