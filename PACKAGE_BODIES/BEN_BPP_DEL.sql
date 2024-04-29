--------------------------------------------------------
--  DDL for Package Body BEN_BPP_DEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_BPP_DEL" as
/* $Header: bebpprhi.pkb 115.13 2002/12/22 20:25:09 pabodla ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_bpp_del.';  -- Global package name
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
	(p_rec 			 in out nocopy ben_bpp_shd.g_rec_type,
	 p_effective_date	 in	date,
	 p_datetrack_mode	 in	varchar2,
	 p_validation_start_date in	date,
	 p_validation_end_date	 in	date) is
--
  l_proc	varchar2(72) := g_package||'dt_delete_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  If (p_datetrack_mode = 'DELETE_NEXT_CHANGE') then
    hr_utility.set_location(l_proc, 10);
    ben_bpp_shd.g_api_dml := true;  -- Set the api dml status
    --
    -- Delete the where the effective start date is equal
    -- to the validation end date.
    --
    delete from ben_bnft_prvdr_pool_f
    where       bnft_prvdr_pool_id = p_rec.bnft_prvdr_pool_id
    and	  effective_start_date = p_validation_start_date;
    --
    ben_bpp_shd.g_api_dml := false;   -- Unset the api dml status
  Else
    hr_utility.set_location(l_proc, 15);
    ben_bpp_shd.g_api_dml := true;  -- Set the api dml status
    --
    -- Delete the row(s) where the effective start date is greater than
    -- or equal to the validation start date.
    --
    delete from ben_bnft_prvdr_pool_f
    where        bnft_prvdr_pool_id = p_rec.bnft_prvdr_pool_id
    and	  effective_start_date >= p_validation_start_date;
    --
    ben_bpp_shd.g_api_dml := false;   -- Unset the api dml status
  End If;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 20);
--
Exception
  When Others Then
    ben_bpp_shd.g_api_dml := false;   -- Unset the api dml status
    Raise;
End dt_delete_dml;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< delete_dml >------------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_dml
	(p_rec 			 in out nocopy ben_bpp_shd.g_rec_type,
	 p_effective_date	 in	date,
	 p_datetrack_mode	 in	varchar2,
	 p_validation_start_date in	date,
	 p_validation_end_date	 in	date) is
--
  l_proc	varchar2(72) := g_package||'delete_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  dt_delete_dml(p_rec			=> p_rec,
		p_effective_date	=> p_effective_date,
		p_datetrack_mode	=> p_datetrack_mode,
       		p_validation_start_date	=> p_validation_start_date,
		p_validation_end_date	=> p_validation_end_date);
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
	(p_rec 			 in out nocopy ben_bpp_shd.g_rec_type,
	 p_effective_date	 in	date,
	 p_datetrack_mode	 in	varchar2,
	 p_validation_start_date in	date,
	 p_validation_end_date	 in	date) is
--
  l_proc	varchar2(72) := g_package||'dt_pre_delete';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (p_datetrack_mode <> 'ZAP') then
    --
    p_rec.effective_start_date := ben_bpp_shd.g_old_rec.effective_start_date;
    --
    If (p_datetrack_mode = 'DELETE') then
      p_rec.effective_end_date := p_validation_start_date - 1;
    Else
      p_rec.effective_end_date := p_validation_end_date;
    End If;
    --
    -- Update the current effective end date record
    --
    ben_bpp_shd.upd_effective_end_date
      (p_effective_date	        => p_effective_date,
       p_base_key_value	        => p_rec.bnft_prvdr_pool_id,
       p_new_effective_end_date => p_rec.effective_end_date,
       p_validation_start_date  => p_validation_start_date,
       p_validation_end_date	=> p_validation_end_date,
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
	(p_rec 			 in out nocopy ben_bpp_shd.g_rec_type,
	 p_effective_date	 in	date,
	 p_datetrack_mode	 in	varchar2,
	 p_validation_start_date in	date,
	 p_validation_end_date	 in	date) is
--
  l_proc	varchar2(72) := g_package||'pre_delete';
--
  --
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  --
  dt_pre_delete
    (p_rec 		     => p_rec,
     p_effective_date	     => p_effective_date,
     p_datetrack_mode	     => p_datetrack_mode,
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
	(p_rec 			 in ben_bpp_shd.g_rec_type,
	 p_effective_date	 in date,
	 p_datetrack_mode	 in varchar2,
	 p_validation_start_date in date,
	 p_validation_end_date	 in date) is
--
  l_proc	varchar2(72) := g_package||'post_delete';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Start of API User Hook for post_delete.
  --
  begin
    --
    ben_bpp_rkd.after_delete
      (
  p_bnft_prvdr_pool_id             => p_rec.bnft_prvdr_pool_id
 ,p_datetrack_mode                 => p_datetrack_mode
 ,p_validation_start_date          => p_validation_start_date
 ,p_validation_end_date            => p_validation_end_date
 ,p_effective_start_date           => p_rec.effective_start_date
 ,p_effective_end_date             => p_rec.effective_end_date
 ,p_effective_start_date_o         => ben_bpp_shd.g_old_rec.effective_start_date
 ,p_effective_end_date_o           => ben_bpp_shd.g_old_rec.effective_end_date
 ,p_name_o                         => ben_bpp_shd.g_old_rec.name
 ,p_pgm_pool_flag_o                => ben_bpp_shd.g_old_rec.pgm_pool_flag
 ,p_excs_alwys_fftd_flag_o         => ben_bpp_shd.g_old_rec.excs_alwys_fftd_flag
 ,p_use_for_pgm_pool_flag_o        => ben_bpp_shd.g_old_rec.use_for_pgm_pool_flag
 ,p_pct_rndg_cd_o                  => ben_bpp_shd.g_old_rec.pct_rndg_cd
 ,p_pct_rndg_rl_o                  => ben_bpp_shd.g_old_rec.pct_rndg_rl
 ,p_val_rndg_cd_o                  => ben_bpp_shd.g_old_rec.val_rndg_cd
 ,p_val_rndg_rl_o                  => ben_bpp_shd.g_old_rec.val_rndg_rl
 ,p_dflt_excs_trtmt_cd_o           => ben_bpp_shd.g_old_rec.dflt_excs_trtmt_cd
 ,p_dflt_excs_trtmt_rl_o           => ben_bpp_shd.g_old_rec.dflt_excs_trtmt_rl
 ,p_rlovr_rstrcn_cd_o              => ben_bpp_shd.g_old_rec.rlovr_rstrcn_cd
 ,p_no_mn_dstrbl_pct_flag_o        => ben_bpp_shd.g_old_rec.no_mn_dstrbl_pct_flag
 ,p_no_mn_dstrbl_val_flag_o        => ben_bpp_shd.g_old_rec.no_mn_dstrbl_val_flag
 ,p_no_mx_dstrbl_pct_flag_o        => ben_bpp_shd.g_old_rec.no_mx_dstrbl_pct_flag
 ,p_no_mx_dstrbl_val_flag_o        => ben_bpp_shd.g_old_rec.no_mx_dstrbl_val_flag
 ,p_auto_alct_excs_flag_o          => ben_bpp_shd.g_old_rec.auto_alct_excs_flag
 ,p_alws_ngtv_crs_flag_o           => ben_bpp_shd.g_old_rec.alws_ngtv_crs_flag
 ,p_uses_net_crs_mthd_flag_o       => ben_bpp_shd.g_old_rec.uses_net_crs_mthd_flag
 ,p_mx_dfcit_pct_pool_crs_num_o    => ben_bpp_shd.g_old_rec.mx_dfcit_pct_pool_crs_num
 ,p_mx_dfcit_pct_comp_num_o         => ben_bpp_shd.g_old_rec.mx_dfcit_pct_comp_num
 ,p_comp_lvl_fctr_id_o             => ben_bpp_shd.g_old_rec.comp_lvl_fctr_id
 ,p_mn_dstrbl_pct_num_o            => ben_bpp_shd.g_old_rec.mn_dstrbl_pct_num
 ,p_mn_dstrbl_val_o                => ben_bpp_shd.g_old_rec.mn_dstrbl_val
 ,p_mx_dstrbl_pct_num_o            => ben_bpp_shd.g_old_rec.mx_dstrbl_pct_num
 ,p_mx_dstrbl_val_o                => ben_bpp_shd.g_old_rec.mx_dstrbl_val
 ,p_excs_trtmt_cd_o                => ben_bpp_shd.g_old_rec.excs_trtmt_cd
 ,p_ptip_id_o                      => ben_bpp_shd.g_old_rec.ptip_id
 ,p_plip_id_o                      => ben_bpp_shd.g_old_rec.plip_id
 ,p_pgm_id_o                       => ben_bpp_shd.g_old_rec.pgm_id
 ,p_oiplip_id_o                    => ben_bpp_shd.g_old_rec.oiplip_id
 ,p_cmbn_plip_id_o                 => ben_bpp_shd.g_old_rec.cmbn_plip_id
 ,p_cmbn_ptip_id_o                 => ben_bpp_shd.g_old_rec.cmbn_ptip_id
 ,p_cmbn_ptip_opt_id_o             => ben_bpp_shd.g_old_rec.cmbn_ptip_opt_id
 ,p_business_group_id_o            => ben_bpp_shd.g_old_rec.business_group_id
 ,p_bpp_attribute_category_o       => ben_bpp_shd.g_old_rec.bpp_attribute_category
 ,p_bpp_attribute1_o               => ben_bpp_shd.g_old_rec.bpp_attribute1
 ,p_bpp_attribute2_o               => ben_bpp_shd.g_old_rec.bpp_attribute2
 ,p_bpp_attribute3_o               => ben_bpp_shd.g_old_rec.bpp_attribute3
 ,p_bpp_attribute4_o               => ben_bpp_shd.g_old_rec.bpp_attribute4
 ,p_bpp_attribute5_o               => ben_bpp_shd.g_old_rec.bpp_attribute5
 ,p_bpp_attribute6_o               => ben_bpp_shd.g_old_rec.bpp_attribute6
 ,p_bpp_attribute7_o               => ben_bpp_shd.g_old_rec.bpp_attribute7
 ,p_bpp_attribute8_o               => ben_bpp_shd.g_old_rec.bpp_attribute8
 ,p_bpp_attribute9_o               => ben_bpp_shd.g_old_rec.bpp_attribute9
 ,p_bpp_attribute10_o              => ben_bpp_shd.g_old_rec.bpp_attribute10
 ,p_bpp_attribute11_o              => ben_bpp_shd.g_old_rec.bpp_attribute11
 ,p_bpp_attribute12_o              => ben_bpp_shd.g_old_rec.bpp_attribute12
 ,p_bpp_attribute13_o              => ben_bpp_shd.g_old_rec.bpp_attribute13
 ,p_bpp_attribute14_o              => ben_bpp_shd.g_old_rec.bpp_attribute14
 ,p_bpp_attribute15_o              => ben_bpp_shd.g_old_rec.bpp_attribute15
 ,p_bpp_attribute16_o              => ben_bpp_shd.g_old_rec.bpp_attribute16
 ,p_bpp_attribute17_o              => ben_bpp_shd.g_old_rec.bpp_attribute17
 ,p_bpp_attribute18_o              => ben_bpp_shd.g_old_rec.bpp_attribute18
 ,p_bpp_attribute19_o              => ben_bpp_shd.g_old_rec.bpp_attribute19
 ,p_bpp_attribute20_o              => ben_bpp_shd.g_old_rec.bpp_attribute20
 ,p_bpp_attribute21_o              => ben_bpp_shd.g_old_rec.bpp_attribute21
 ,p_bpp_attribute22_o              => ben_bpp_shd.g_old_rec.bpp_attribute22
 ,p_bpp_attribute23_o              => ben_bpp_shd.g_old_rec.bpp_attribute23
 ,p_bpp_attribute24_o              => ben_bpp_shd.g_old_rec.bpp_attribute24
 ,p_bpp_attribute25_o              => ben_bpp_shd.g_old_rec.bpp_attribute25
 ,p_bpp_attribute26_o              => ben_bpp_shd.g_old_rec.bpp_attribute26
 ,p_bpp_attribute27_o              => ben_bpp_shd.g_old_rec.bpp_attribute27
 ,p_bpp_attribute28_o              => ben_bpp_shd.g_old_rec.bpp_attribute28
 ,p_bpp_attribute29_o              => ben_bpp_shd.g_old_rec.bpp_attribute29
 ,p_bpp_attribute30_o              => ben_bpp_shd.g_old_rec.bpp_attribute30
 ,p_object_version_number_o        => ben_bpp_shd.g_old_rec.object_version_number
  );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'ben_bnft_prvdr_pool_f'
        ,p_hook_type   => 'AI');
      --
  end;
  --
  -- End of API User Hook for post_delete.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End post_delete;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< del >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure del
  (
  p_rec			in out nocopy 	ben_bpp_shd.g_rec_type,
  p_effective_date	in 	date,
  p_datetrack_mode	in 	varchar2
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
  ben_bpp_shd.lck
	(p_effective_date	 => p_effective_date,
      	 p_datetrack_mode	 => p_datetrack_mode,
      	 p_bnft_prvdr_pool_id	 => p_rec.bnft_prvdr_pool_id,
      	 p_object_version_number => p_rec.object_version_number,
      	 p_validation_start_date => l_validation_start_date,
      	 p_validation_end_date	 => l_validation_end_date);
  --
  -- Call the supporting delete validate operation
  --
  ben_bpp_bus.delete_validate
	(p_rec			 => p_rec,
	 p_effective_date	 => p_effective_date,
	 p_datetrack_mode	 => p_datetrack_mode,
	 p_validation_start_date => l_validation_start_date,
	 p_validation_end_date	 => l_validation_end_date);
  --
  -- Call the supporting pre-delete operation
  --
  pre_delete
	(p_rec			 => p_rec,
	 p_effective_date	 => p_effective_date,
	 p_datetrack_mode	 => p_datetrack_mode,
	 p_validation_start_date => l_validation_start_date,
	 p_validation_end_date	 => l_validation_end_date);
  --
  -- Delete the row.
  --
  delete_dml
	(p_rec			 => p_rec,
	 p_effective_date	 => p_effective_date,
	 p_datetrack_mode	 => p_datetrack_mode,
	 p_validation_start_date => l_validation_start_date,
	 p_validation_end_date	 => l_validation_end_date);
  --
  -- Call the supporting post-delete operation
  --
  post_delete
	(p_rec			 => p_rec,
	 p_effective_date	 => p_effective_date,
	 p_datetrack_mode	 => p_datetrack_mode,
	 p_validation_start_date => l_validation_start_date,
	 p_validation_end_date	 => l_validation_end_date);
End del;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< del >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure del
  (
  p_bnft_prvdr_pool_id	  in 	 number,
  p_effective_start_date     out nocopy date,
  p_effective_end_date	     out nocopy date,
  p_object_version_number in out nocopy number,
  p_effective_date	  in     date,
  p_datetrack_mode  	  in     varchar2
  ) is
--
  l_rec		ben_bpp_shd.g_rec_type;
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
  l_rec.bnft_prvdr_pool_id		:= p_bnft_prvdr_pool_id;
  l_rec.object_version_number 	:= p_object_version_number;
  --
  -- Having converted the arguments into the ben_bpp_rec
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
end ben_bpp_del;

/
