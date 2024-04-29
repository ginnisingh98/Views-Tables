--------------------------------------------------------
--  DDL for Package Body BEN_PEO_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PEO_UPD" as
/* $Header: bepeorhi.pkb 120.0 2005/05/28 10:38:09 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_peo_upd.';  -- Global package name
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
--   This procedure controls the actual dml update logic. The functions of this
--   procedure are as follows:
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
--   A Pl/Sql record structre.
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
	(p_rec 			 in out nocopy ben_peo_shd.g_rec_type,
	 p_effective_date	 in	date,
	 p_datetrack_mode	 in	varchar2,
	 p_validation_start_date in	date,
	 p_validation_end_date	 in	date) is
--
  l_proc	varchar2(72) := g_package||'dt_update_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (p_datetrack_mode = 'CORRECTION') then
    hr_utility.set_location(l_proc, 10);
    --
    -- Because we are updating a row we must get the next object
    -- version number.
    --
    p_rec.object_version_number :=
      dt_api.get_object_version_number
	  (p_base_table_name	=> 'ben_elig_to_prte_rsn_f',
	   p_base_key_column	=> 'elig_to_prte_rsn_id',
	   p_base_key_value	=> p_rec.elig_to_prte_rsn_id);
    --
    ben_peo_shd.g_api_dml := true;  -- Set the api dml status
    --
    -- Update the ben_elig_to_prte_rsn_f Row
    --
    update  ben_elig_to_prte_rsn_f
    set
    elig_to_prte_rsn_id             = p_rec.elig_to_prte_rsn_id,
    business_group_id               = p_rec.business_group_id,
    ler_id                          = p_rec.ler_id,
    oipl_id                         = p_rec.oipl_id,
    pgm_id                          = p_rec.pgm_id,
    pl_id                           = p_rec.pl_id,
    ptip_id                         = p_rec.ptip_id,
    plip_id                         = p_rec.plip_id,
    ignr_prtn_ovrid_flag            = p_rec.ignr_prtn_ovrid_flag,
    elig_inelig_cd                  = p_rec.elig_inelig_cd,
    prtn_eff_strt_dt_cd             = p_rec.prtn_eff_strt_dt_cd,
    prtn_eff_strt_dt_rl             = p_rec.prtn_eff_strt_dt_rl,
    prtn_eff_end_dt_cd              = p_rec.prtn_eff_end_dt_cd,
    prtn_eff_end_dt_rl              = p_rec.prtn_eff_end_dt_rl,
    wait_perd_dt_to_use_cd          = p_rec.wait_perd_dt_to_use_cd,
    wait_perd_dt_to_use_rl          = p_rec.wait_perd_dt_to_use_rl,
    wait_perd_val                   = p_rec.wait_perd_val,
    wait_perd_uom                   = p_rec.wait_perd_uom,
    wait_perd_rl                    = p_rec.wait_perd_rl,
    mx_poe_det_dt_cd                = p_rec.mx_poe_det_dt_cd,
    mx_poe_det_dt_rl                = p_rec.mx_poe_det_dt_rl,
    mx_poe_val                      = p_rec.mx_poe_val,
    mx_poe_uom                      = p_rec.mx_poe_uom,
    mx_poe_rl                       = p_rec.mx_poe_rl,
    mx_poe_apls_cd                  = p_rec.mx_poe_apls_cd,
    prtn_ovridbl_flag               = p_rec.prtn_ovridbl_flag,
    vrfy_fmly_mmbr_cd               = p_rec.vrfy_fmly_mmbr_cd,
    vrfy_fmly_mmbr_rl               = p_rec.vrfy_fmly_mmbr_rl,
    peo_attribute_category          = p_rec.peo_attribute_category,
    peo_attribute1                  = p_rec.peo_attribute1,
    peo_attribute2                  = p_rec.peo_attribute2,
    peo_attribute3                  = p_rec.peo_attribute3,
    peo_attribute4                  = p_rec.peo_attribute4,
    peo_attribute5                  = p_rec.peo_attribute5,
    peo_attribute6                  = p_rec.peo_attribute6,
    peo_attribute7                  = p_rec.peo_attribute7,
    peo_attribute8                  = p_rec.peo_attribute8,
    peo_attribute9                  = p_rec.peo_attribute9,
    peo_attribute10                 = p_rec.peo_attribute10,
    peo_attribute11                 = p_rec.peo_attribute11,
    peo_attribute12                 = p_rec.peo_attribute12,
    peo_attribute13                 = p_rec.peo_attribute13,
    peo_attribute14                 = p_rec.peo_attribute14,
    peo_attribute15                 = p_rec.peo_attribute15,
    peo_attribute16                 = p_rec.peo_attribute16,
    peo_attribute17                 = p_rec.peo_attribute17,
    peo_attribute18                 = p_rec.peo_attribute18,
    peo_attribute19                 = p_rec.peo_attribute19,
    peo_attribute20                 = p_rec.peo_attribute20,
    peo_attribute21                 = p_rec.peo_attribute21,
    peo_attribute22                 = p_rec.peo_attribute22,
    peo_attribute23                 = p_rec.peo_attribute23,
    peo_attribute24                 = p_rec.peo_attribute24,
    peo_attribute25                 = p_rec.peo_attribute25,
    peo_attribute26                 = p_rec.peo_attribute26,
    peo_attribute27                 = p_rec.peo_attribute27,
    peo_attribute28                 = p_rec.peo_attribute28,
    peo_attribute29                 = p_rec.peo_attribute29,
    peo_attribute30                 = p_rec.peo_attribute30,
    object_version_number           = p_rec.object_version_number
    where   elig_to_prte_rsn_id = p_rec.elig_to_prte_rsn_id
    and     effective_start_date = p_validation_start_date
    and     effective_end_date   = p_validation_end_date;
    --
    ben_peo_shd.g_api_dml := false;   -- Unset the api dml status
    --
    -- Set the effective start and end dates
    --
    p_rec.effective_start_date := p_validation_start_date;
    p_rec.effective_end_date   := p_validation_end_date;
  End If;
--
hr_utility.set_location(' Leaving:'||l_proc, 15);
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    ben_peo_shd.g_api_dml := false;   -- Unset the api dml status
    ben_peo_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    ben_peo_shd.g_api_dml := false;   -- Unset the api dml status
    ben_peo_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    ben_peo_shd.g_api_dml := false;   -- Unset the api dml status
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
	(p_rec 			 in out nocopy ben_peo_shd.g_rec_type,
	 p_effective_date	 in	date,
	 p_datetrack_mode	 in	varchar2,
	 p_validation_start_date in	date,
	 p_validation_end_date	 in	date) is
--
  l_proc	varchar2(72) := g_package||'update_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  dt_update_dml(p_rec			=> p_rec,
		p_effective_date	=> p_effective_date,
		p_datetrack_mode	=> p_datetrack_mode,
       		p_validation_start_date	=> p_validation_start_date,
		p_validation_end_date	=> p_validation_end_date);
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
--	the validation_start_date.
--   3) Call the insert_dml process to insert the new updated row
--      details..
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
	(p_rec 			 in out nocopy ben_peo_shd.g_rec_type,
	 p_effective_date	 in	date,
	 p_datetrack_mode	 in	varchar2,
	 p_validation_start_date in	date,
	 p_validation_end_date	 in	date) is
--
  l_proc	         varchar2(72) := g_package||'dt_pre_update';
  l_dummy_version_number number;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  If (p_datetrack_mode <> 'CORRECTION') then
    hr_utility.set_location(l_proc, 10);
    --
    -- Update the current effective end date
    --
    ben_peo_shd.upd_effective_end_date
     (p_effective_date	       => p_effective_date,
      p_base_key_value	       => p_rec.elig_to_prte_rsn_id,
      p_new_effective_end_date => (p_validation_start_date - 1),
      p_validation_start_date  => p_validation_start_date,
      p_validation_end_date    => p_validation_end_date,
      p_object_version_number  => l_dummy_version_number);
    --
    If (p_datetrack_mode = 'UPDATE_OVERRIDE') then
      hr_utility.set_location(l_proc, 15);
      --
      -- As the datetrack mode is 'UPDATE_OVERRIDE' then we must
      -- delete any future rows
      --
      ben_peo_del.delete_dml
        (p_rec			 => p_rec,
	 p_effective_date	 => p_effective_date,
	 p_datetrack_mode	 => p_datetrack_mode,
	 p_validation_start_date => p_validation_start_date,
	 p_validation_end_date   => p_validation_end_date);
    End If;
    hr_utility.set_location(l_proc, 20);
    --
    -- We must now insert the updated row
    --
    ben_peo_ins.insert_dml
      (p_rec			=> p_rec,
       p_effective_date		=> p_effective_date,
       p_datetrack_mode		=> p_datetrack_mode,
       p_validation_start_date	=> p_validation_start_date,
       p_validation_end_date	=> p_validation_end_date);
  End If;
  hr_utility.set_location(' Leaving:'||l_proc, 20);
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
	(p_rec 			 in out nocopy ben_peo_shd.g_rec_type,
	 p_effective_date	 in	date,
	 p_datetrack_mode	 in	varchar2,
	 p_validation_start_date in	date,
	 p_validation_end_date	 in	date) is
--
  l_proc	varchar2(72) := g_package||'pre_update';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  --
  dt_pre_update
    (p_rec 		     => p_rec,
     p_effective_date	     => p_effective_date,
     p_datetrack_mode	     => p_datetrack_mode,
     p_validation_start_date => p_validation_start_date,
     p_validation_end_date   => p_validation_end_date);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End pre_update;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< post_update >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This private procedure contains any processing which is required after the
--   update dml.
--
-- Prerequisites:
--   This is an internal procedure which is called from the upd procedure.
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
	(p_rec 			 in ben_peo_shd.g_rec_type,
	 p_effective_date	 in date,
	 p_datetrack_mode	 in varchar2,
	 p_validation_start_date in date,
	 p_validation_end_date	 in date) is
--
  l_proc	varchar2(72) := g_package||'post_update';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Start of API User Hook for post_update.
  --
  begin
    --
    ben_peo_rku.after_update
      (
      p_elig_to_prte_rsn_id      => p_rec.elig_to_prte_rsn_id
     ,p_effective_start_date     => p_rec.effective_start_date
     ,p_effective_end_date       => p_rec.effective_end_date
     ,p_business_group_id        => p_rec.business_group_id
     ,p_ler_id                   => p_rec.ler_id
     ,p_oipl_id                  => p_rec.oipl_id
     ,p_pgm_id                   => p_rec.pgm_id
     ,p_pl_id                    => p_rec.pl_id
     ,p_ptip_id                  => p_rec.ptip_id
     ,p_plip_id                  => p_rec.plip_id
     ,p_ignr_prtn_ovrid_flag     => p_rec.ignr_prtn_ovrid_flag
     ,p_elig_inelig_cd           => p_rec.elig_inelig_cd
     ,p_prtn_eff_strt_dt_cd      => p_rec.prtn_eff_strt_dt_cd
     ,p_prtn_eff_strt_dt_rl      => p_rec.prtn_eff_strt_dt_rl
     ,p_prtn_eff_end_dt_cd       => p_rec.prtn_eff_end_dt_cd
     ,p_prtn_eff_end_dt_rl       => p_rec.prtn_eff_end_dt_rl
     ,p_wait_perd_dt_to_use_cd   => p_rec.wait_perd_dt_to_use_cd
     ,p_wait_perd_dt_to_use_rl   => p_rec.wait_perd_dt_to_use_rl
     ,p_wait_perd_val            => p_rec.wait_perd_val
     ,p_wait_perd_uom            => p_rec.wait_perd_uom
     ,p_wait_perd_rl             => p_rec.wait_perd_rl
     ,p_mx_poe_det_dt_cd         => p_rec.mx_poe_det_dt_cd
     ,p_mx_poe_det_dt_rl         => p_rec.mx_poe_det_dt_rl
     ,p_mx_poe_val               => p_rec.mx_poe_val
     ,p_mx_poe_uom               => p_rec.mx_poe_uom
     ,p_mx_poe_rl                => p_rec.mx_poe_rl
     ,p_mx_poe_apls_cd           => p_rec.mx_poe_apls_cd
     ,p_prtn_ovridbl_flag        => p_rec.prtn_ovridbl_flag
     ,p_vrfy_fmly_mmbr_cd        => p_rec.vrfy_fmly_mmbr_cd
     ,p_vrfy_fmly_mmbr_rl        => p_rec.vrfy_fmly_mmbr_rl
     ,p_peo_attribute_category   => p_rec.peo_attribute_category
     ,p_peo_attribute1           => p_rec.peo_attribute1
     ,p_peo_attribute2           => p_rec.peo_attribute2
     ,p_peo_attribute3           => p_rec.peo_attribute3
     ,p_peo_attribute4           => p_rec.peo_attribute4
     ,p_peo_attribute5           => p_rec.peo_attribute5
     ,p_peo_attribute6           => p_rec.peo_attribute6
     ,p_peo_attribute7           => p_rec.peo_attribute7
     ,p_peo_attribute8           => p_rec.peo_attribute8
     ,p_peo_attribute9           => p_rec.peo_attribute9
     ,p_peo_attribute10          => p_rec.peo_attribute10
     ,p_peo_attribute11          => p_rec.peo_attribute11
     ,p_peo_attribute12          => p_rec.peo_attribute12
     ,p_peo_attribute13          => p_rec.peo_attribute13
     ,p_peo_attribute14          => p_rec.peo_attribute14
     ,p_peo_attribute15          => p_rec.peo_attribute15
     ,p_peo_attribute16          => p_rec.peo_attribute16
     ,p_peo_attribute17          => p_rec.peo_attribute17
     ,p_peo_attribute18          => p_rec.peo_attribute18
     ,p_peo_attribute19          => p_rec.peo_attribute19
     ,p_peo_attribute20          => p_rec.peo_attribute20
     ,p_peo_attribute21          => p_rec.peo_attribute21
     ,p_peo_attribute22          => p_rec.peo_attribute22
     ,p_peo_attribute23          => p_rec.peo_attribute23
     ,p_peo_attribute24          => p_rec.peo_attribute24
     ,p_peo_attribute25          => p_rec.peo_attribute25
     ,p_peo_attribute26          => p_rec.peo_attribute26
     ,p_peo_attribute27          => p_rec.peo_attribute27
     ,p_peo_attribute28          => p_rec.peo_attribute28
     ,p_peo_attribute29          => p_rec.peo_attribute29
     ,p_peo_attribute30          => p_rec.peo_attribute30
     ,p_object_version_number    => p_rec.object_version_number
     ,p_effective_date           => p_effective_date
     ,p_datetrack_mode           => p_datetrack_mode
     ,p_validation_start_date    => p_validation_start_date
     ,p_validation_end_date      => p_validation_end_date
     ,p_effective_start_date_o   => ben_peo_shd.g_old_rec.effective_start_date
     ,p_effective_end_date_o     => ben_peo_shd.g_old_rec.effective_end_date
     ,p_business_group_id_o      => ben_peo_shd.g_old_rec.business_group_id
     ,p_ler_id_o                 => ben_peo_shd.g_old_rec.ler_id
     ,p_oipl_id_o                => ben_peo_shd.g_old_rec.oipl_id
     ,p_pgm_id_o                 => ben_peo_shd.g_old_rec.pgm_id
     ,p_pl_id_o                  => ben_peo_shd.g_old_rec.pl_id
     ,p_ptip_id_o                => ben_peo_shd.g_old_rec.ptip_id
     ,p_plip_id_o                => ben_peo_shd.g_old_rec.plip_id
     ,p_ignr_prtn_ovrid_flag_o   => ben_peo_shd.g_old_rec.ignr_prtn_ovrid_flag
     ,p_elig_inelig_cd_o         => ben_peo_shd.g_old_rec.elig_inelig_cd
     ,p_prtn_eff_strt_dt_cd_o    => ben_peo_shd.g_old_rec.prtn_eff_strt_dt_cd
     ,p_prtn_eff_strt_dt_rl_o    => ben_peo_shd.g_old_rec.prtn_eff_strt_dt_rl
     ,p_prtn_eff_end_dt_cd_o     => ben_peo_shd.g_old_rec.prtn_eff_end_dt_cd
     ,p_prtn_eff_end_dt_rl_o     => ben_peo_shd.g_old_rec.prtn_eff_end_dt_rl
     ,p_wait_perd_dt_to_use_cd_o => ben_peo_shd.g_old_rec.wait_perd_dt_to_use_cd
     ,p_wait_perd_dt_to_use_rl_o => ben_peo_shd.g_old_rec.wait_perd_dt_to_use_rl
     ,p_wait_perd_val_o          => ben_peo_shd.g_old_rec.wait_perd_val
     ,p_wait_perd_uom_o          => ben_peo_shd.g_old_rec.wait_perd_uom
     ,p_wait_perd_rl_o           => ben_peo_shd.g_old_rec.wait_perd_rl
     ,p_mx_poe_det_dt_cd_o       => ben_peo_shd.g_old_rec.mx_poe_det_dt_cd
     ,p_mx_poe_det_dt_rl_o       => ben_peo_shd.g_old_rec.mx_poe_det_dt_rl
     ,p_mx_poe_val_o             => ben_peo_shd.g_old_rec.mx_poe_val
     ,p_mx_poe_uom_o             => ben_peo_shd.g_old_rec.mx_poe_uom
     ,p_mx_poe_rl_o              => ben_peo_shd.g_old_rec.mx_poe_rl
     ,p_mx_poe_apls_cd_o         => ben_peo_shd.g_old_rec.mx_poe_apls_cd
     ,p_prtn_ovridbl_flag_o      => ben_peo_shd.g_old_rec.prtn_ovridbl_flag
     ,p_vrfy_fmly_mmbr_cd_o      => ben_peo_shd.g_old_rec.vrfy_fmly_mmbr_cd
     ,p_vrfy_fmly_mmbr_rl_o      => ben_peo_shd.g_old_rec.vrfy_fmly_mmbr_rl
     ,p_peo_attribute_category_o => ben_peo_shd.g_old_rec.peo_attribute_category
     ,p_peo_attribute1_o         => ben_peo_shd.g_old_rec.peo_attribute1
     ,p_peo_attribute2_o         => ben_peo_shd.g_old_rec.peo_attribute2
     ,p_peo_attribute3_o         => ben_peo_shd.g_old_rec.peo_attribute3
     ,p_peo_attribute4_o         => ben_peo_shd.g_old_rec.peo_attribute4
     ,p_peo_attribute5_o         => ben_peo_shd.g_old_rec.peo_attribute5
     ,p_peo_attribute6_o         => ben_peo_shd.g_old_rec.peo_attribute6
     ,p_peo_attribute7_o         => ben_peo_shd.g_old_rec.peo_attribute7
     ,p_peo_attribute8_o         => ben_peo_shd.g_old_rec.peo_attribute8
     ,p_peo_attribute9_o         => ben_peo_shd.g_old_rec.peo_attribute9
     ,p_peo_attribute10_o        => ben_peo_shd.g_old_rec.peo_attribute10
     ,p_peo_attribute11_o        => ben_peo_shd.g_old_rec.peo_attribute11
     ,p_peo_attribute12_o        => ben_peo_shd.g_old_rec.peo_attribute12
     ,p_peo_attribute13_o        => ben_peo_shd.g_old_rec.peo_attribute13
     ,p_peo_attribute14_o        => ben_peo_shd.g_old_rec.peo_attribute14
     ,p_peo_attribute15_o        => ben_peo_shd.g_old_rec.peo_attribute15
     ,p_peo_attribute16_o        => ben_peo_shd.g_old_rec.peo_attribute16
     ,p_peo_attribute17_o        => ben_peo_shd.g_old_rec.peo_attribute17
     ,p_peo_attribute18_o        => ben_peo_shd.g_old_rec.peo_attribute18
     ,p_peo_attribute19_o        => ben_peo_shd.g_old_rec.peo_attribute19
     ,p_peo_attribute20_o        => ben_peo_shd.g_old_rec.peo_attribute20
     ,p_peo_attribute21_o        => ben_peo_shd.g_old_rec.peo_attribute21
     ,p_peo_attribute22_o        => ben_peo_shd.g_old_rec.peo_attribute22
     ,p_peo_attribute23_o        => ben_peo_shd.g_old_rec.peo_attribute23
     ,p_peo_attribute24_o        => ben_peo_shd.g_old_rec.peo_attribute24
     ,p_peo_attribute25_o        => ben_peo_shd.g_old_rec.peo_attribute25
     ,p_peo_attribute26_o        => ben_peo_shd.g_old_rec.peo_attribute26
     ,p_peo_attribute27_o        => ben_peo_shd.g_old_rec.peo_attribute27
     ,p_peo_attribute28_o        => ben_peo_shd.g_old_rec.peo_attribute28
     ,p_peo_attribute29_o        => ben_peo_shd.g_old_rec.peo_attribute29
     ,p_peo_attribute30_o        => ben_peo_shd.g_old_rec.peo_attribute30
     ,p_object_version_number_o  => ben_peo_shd.g_old_rec.object_version_number
    );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'ben_elig_to_prte_rsn_f'
        ,p_hook_type   => 'AU');
      --
  end;
  --
  -- End of API User Hook for post_update.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
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
--   A Pl/Sql record structre.
--
-- Post Success:
--   The record structure will be returned with all system defaulted parameter
--   values converted into its current row attribute value.
--
-- Post Failure:
--   No direct error handling is required within this function. Any possible
--   errors within this procedure will be a PL/SQL value error due to conversion
--   of datatypes or data lengths.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure convert_defs(p_rec in out nocopy ben_peo_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'convert_defs';
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
    p_rec.business_group_id :=
    ben_peo_shd.g_old_rec.business_group_id;
  End If;
  If (p_rec.ler_id = hr_api.g_number) then
    p_rec.ler_id :=
    ben_peo_shd.g_old_rec.ler_id;
  End If;
  If (p_rec.oipl_id = hr_api.g_number) then
    p_rec.oipl_id :=
    ben_peo_shd.g_old_rec.oipl_id;
  End If;
  If (p_rec.pgm_id = hr_api.g_number) then
    p_rec.pgm_id :=
    ben_peo_shd.g_old_rec.pgm_id;
  End If;
  If (p_rec.pl_id = hr_api.g_number) then
    p_rec.pl_id :=
    ben_peo_shd.g_old_rec.pl_id;
  End If;
  If (p_rec.ptip_id = hr_api.g_number) then
    p_rec.ptip_id :=
    ben_peo_shd.g_old_rec.ptip_id;
  End If;
  If (p_rec.plip_id = hr_api.g_number) then
    p_rec.plip_id :=
    ben_peo_shd.g_old_rec.plip_id;
  End If;
  If (p_rec.ignr_prtn_ovrid_flag = hr_api.g_varchar2) then
    p_rec.ignr_prtn_ovrid_flag :=
    ben_peo_shd.g_old_rec.ignr_prtn_ovrid_flag;
  End If;
  If (p_rec.elig_inelig_cd = hr_api.g_varchar2) then
    p_rec.elig_inelig_cd :=
    ben_peo_shd.g_old_rec.elig_inelig_cd;
  End If;
  If (p_rec.prtn_eff_strt_dt_cd = hr_api.g_varchar2) then
    p_rec.prtn_eff_strt_dt_cd :=
    ben_peo_shd.g_old_rec.prtn_eff_strt_dt_cd;
  End If;
  If (p_rec.prtn_eff_strt_dt_rl = hr_api.g_number) then
    p_rec.prtn_eff_strt_dt_rl :=
    ben_peo_shd.g_old_rec.prtn_eff_strt_dt_rl;
  End If;
  If (p_rec.prtn_eff_end_dt_cd = hr_api.g_varchar2) then
    p_rec.prtn_eff_end_dt_cd :=
    ben_peo_shd.g_old_rec.prtn_eff_end_dt_cd;
  End If;
  If (p_rec.prtn_eff_end_dt_rl = hr_api.g_number) then
    p_rec.prtn_eff_end_dt_rl :=
    ben_peo_shd.g_old_rec.prtn_eff_end_dt_rl;
  End If;
  If (p_rec.wait_perd_dt_to_use_cd = hr_api.g_varchar2) then
    p_rec.wait_perd_dt_to_use_cd :=
    ben_peo_shd.g_old_rec.wait_perd_dt_to_use_cd;
  End If;
  If (p_rec.wait_perd_dt_to_use_rl = hr_api.g_number) then
    p_rec.wait_perd_dt_to_use_rl :=
    ben_peo_shd.g_old_rec.wait_perd_dt_to_use_rl;
  End If;
  If (p_rec.wait_perd_val = hr_api.g_number) then
    p_rec.wait_perd_val :=
    ben_peo_shd.g_old_rec.wait_perd_val;
  End If;
  If (p_rec.wait_perd_uom = hr_api.g_varchar2) then
    p_rec.wait_perd_uom :=
    ben_peo_shd.g_old_rec.wait_perd_uom;
  End If;
  If (p_rec.wait_perd_rl = hr_api.g_number) then
    p_rec.wait_perd_rl :=
    ben_peo_shd.g_old_rec.wait_perd_rl;
  End If;
  If (p_rec.mx_poe_det_dt_cd = hr_api.g_varchar2) then
    p_rec.mx_poe_det_dt_cd :=
    ben_peo_shd.g_old_rec.mx_poe_det_dt_cd;
  End If;
  If (p_rec.mx_poe_det_dt_rl = hr_api.g_number) then
    p_rec.mx_poe_det_dt_rl :=
    ben_peo_shd.g_old_rec.mx_poe_det_dt_rl;
  End If;
  If (p_rec.mx_poe_val = hr_api.g_number) then
    p_rec.mx_poe_val :=
    ben_peo_shd.g_old_rec.mx_poe_val;
  End If;
  If (p_rec.mx_poe_uom = hr_api.g_varchar2) then
    p_rec.mx_poe_uom :=
    ben_peo_shd.g_old_rec.mx_poe_uom;
  End If;
  If (p_rec.mx_poe_rl = hr_api.g_number) then
    p_rec.mx_poe_rl :=
    ben_peo_shd.g_old_rec.mx_poe_rl;
  End If;
  If (p_rec.mx_poe_apls_cd = hr_api.g_varchar2) then
    p_rec.mx_poe_apls_cd :=
    ben_peo_shd.g_old_rec.mx_poe_apls_cd;
  End If;
  If (p_rec.prtn_ovridbl_flag = hr_api.g_varchar2) then
    p_rec.prtn_ovridbl_flag :=
    ben_peo_shd.g_old_rec.prtn_ovridbl_flag;
  End If;
  If (p_rec.vrfy_fmly_mmbr_cd = hr_api.g_varchar2) then
    p_rec.vrfy_fmly_mmbr_cd :=
    ben_peo_shd.g_old_rec.vrfy_fmly_mmbr_cd;
  End If;
  If (p_rec.vrfy_fmly_mmbr_rl = hr_api.g_number) then
    p_rec.vrfy_fmly_mmbr_rl :=
    ben_peo_shd.g_old_rec.vrfy_fmly_mmbr_rl;
  End If;
  If (p_rec.peo_attribute_category = hr_api.g_varchar2) then
    p_rec.peo_attribute_category :=
    ben_peo_shd.g_old_rec.peo_attribute_category;
  End If;
  If (p_rec.peo_attribute1 = hr_api.g_varchar2) then
    p_rec.peo_attribute1 :=
    ben_peo_shd.g_old_rec.peo_attribute1;
  End If;
  If (p_rec.peo_attribute2 = hr_api.g_varchar2) then
    p_rec.peo_attribute2 :=
    ben_peo_shd.g_old_rec.peo_attribute2;
  End If;
  If (p_rec.peo_attribute3 = hr_api.g_varchar2) then
    p_rec.peo_attribute3 :=
    ben_peo_shd.g_old_rec.peo_attribute3;
  End If;
  If (p_rec.peo_attribute4 = hr_api.g_varchar2) then
    p_rec.peo_attribute4 :=
    ben_peo_shd.g_old_rec.peo_attribute4;
  End If;
  If (p_rec.peo_attribute5 = hr_api.g_varchar2) then
    p_rec.peo_attribute5 :=
    ben_peo_shd.g_old_rec.peo_attribute5;
  End If;
  If (p_rec.peo_attribute6 = hr_api.g_varchar2) then
    p_rec.peo_attribute6 :=
    ben_peo_shd.g_old_rec.peo_attribute6;
  End If;
  If (p_rec.peo_attribute7 = hr_api.g_varchar2) then
    p_rec.peo_attribute7 :=
    ben_peo_shd.g_old_rec.peo_attribute7;
  End If;
  If (p_rec.peo_attribute8 = hr_api.g_varchar2) then
    p_rec.peo_attribute8 :=
    ben_peo_shd.g_old_rec.peo_attribute8;
  End If;
  If (p_rec.peo_attribute9 = hr_api.g_varchar2) then
    p_rec.peo_attribute9 :=
    ben_peo_shd.g_old_rec.peo_attribute9;
  End If;
  If (p_rec.peo_attribute10 = hr_api.g_varchar2) then
    p_rec.peo_attribute10 :=
    ben_peo_shd.g_old_rec.peo_attribute10;
  End If;
  If (p_rec.peo_attribute11 = hr_api.g_varchar2) then
    p_rec.peo_attribute11 :=
    ben_peo_shd.g_old_rec.peo_attribute11;
  End If;
  If (p_rec.peo_attribute12 = hr_api.g_varchar2) then
    p_rec.peo_attribute12 :=
    ben_peo_shd.g_old_rec.peo_attribute12;
  End If;
  If (p_rec.peo_attribute13 = hr_api.g_varchar2) then
    p_rec.peo_attribute13 :=
    ben_peo_shd.g_old_rec.peo_attribute13;
  End If;
  If (p_rec.peo_attribute14 = hr_api.g_varchar2) then
    p_rec.peo_attribute14 :=
    ben_peo_shd.g_old_rec.peo_attribute14;
  End If;
  If (p_rec.peo_attribute15 = hr_api.g_varchar2) then
    p_rec.peo_attribute15 :=
    ben_peo_shd.g_old_rec.peo_attribute15;
  End If;
  If (p_rec.peo_attribute16 = hr_api.g_varchar2) then
    p_rec.peo_attribute16 :=
    ben_peo_shd.g_old_rec.peo_attribute16;
  End If;
  If (p_rec.peo_attribute17 = hr_api.g_varchar2) then
    p_rec.peo_attribute17 :=
    ben_peo_shd.g_old_rec.peo_attribute17;
  End If;
  If (p_rec.peo_attribute18 = hr_api.g_varchar2) then
    p_rec.peo_attribute18 :=
    ben_peo_shd.g_old_rec.peo_attribute18;
  End If;
  If (p_rec.peo_attribute19 = hr_api.g_varchar2) then
    p_rec.peo_attribute19 :=
    ben_peo_shd.g_old_rec.peo_attribute19;
  End If;
  If (p_rec.peo_attribute20 = hr_api.g_varchar2) then
    p_rec.peo_attribute20 :=
    ben_peo_shd.g_old_rec.peo_attribute20;
  End If;
  If (p_rec.peo_attribute21 = hr_api.g_varchar2) then
    p_rec.peo_attribute21 :=
    ben_peo_shd.g_old_rec.peo_attribute21;
  End If;
  If (p_rec.peo_attribute22 = hr_api.g_varchar2) then
    p_rec.peo_attribute22 :=
    ben_peo_shd.g_old_rec.peo_attribute22;
  End If;
  If (p_rec.peo_attribute23 = hr_api.g_varchar2) then
    p_rec.peo_attribute23 :=
    ben_peo_shd.g_old_rec.peo_attribute23;
  End If;
  If (p_rec.peo_attribute24 = hr_api.g_varchar2) then
    p_rec.peo_attribute24 :=
    ben_peo_shd.g_old_rec.peo_attribute24;
  End If;
  If (p_rec.peo_attribute25 = hr_api.g_varchar2) then
    p_rec.peo_attribute25 :=
    ben_peo_shd.g_old_rec.peo_attribute25;
  End If;
  If (p_rec.peo_attribute26 = hr_api.g_varchar2) then
    p_rec.peo_attribute26 :=
    ben_peo_shd.g_old_rec.peo_attribute26;
  End If;
  If (p_rec.peo_attribute27 = hr_api.g_varchar2) then
    p_rec.peo_attribute27 :=
    ben_peo_shd.g_old_rec.peo_attribute27;
  End If;
  If (p_rec.peo_attribute28 = hr_api.g_varchar2) then
    p_rec.peo_attribute28 :=
    ben_peo_shd.g_old_rec.peo_attribute28;
  End If;
  If (p_rec.peo_attribute29 = hr_api.g_varchar2) then
    p_rec.peo_attribute29 :=
    ben_peo_shd.g_old_rec.peo_attribute29;
  End If;
  If (p_rec.peo_attribute30 = hr_api.g_varchar2) then
    p_rec.peo_attribute30 :=
    ben_peo_shd.g_old_rec.peo_attribute30;
  End If;

  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
End convert_defs;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (
  p_rec			in out nocopy 	ben_peo_shd.g_rec_type,
  p_effective_date	in 	date,
  p_datetrack_mode	in 	varchar2
  ) is
--
  l_proc			varchar2(72) := g_package||'upd';
  l_validation_start_date	date;
  l_validation_end_date		date;
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
  ben_peo_shd.lck
	(p_effective_date	 => p_effective_date,
      	 p_datetrack_mode	 => p_datetrack_mode,
      	 p_elig_to_prte_rsn_id	 => p_rec.elig_to_prte_rsn_id,
      	 p_object_version_number => p_rec.object_version_number,
      	 p_validation_start_date => l_validation_start_date,
      	 p_validation_end_date	 => l_validation_end_date);
  --
  -- 1. During an update system defaults are used to determine if
  --    arguments have been defaulted or not. We must therefore
  --    derive the full record structure values to be updated.
  --
  -- 2. Call the supporting update validate operations.
  --
  convert_defs(p_rec);
  ben_peo_bus.update_validate
	(p_rec			 => p_rec,
	 p_effective_date	 => p_effective_date,
	 p_datetrack_mode  	 => p_datetrack_mode,
	 p_validation_start_date => l_validation_start_date,
	 p_validation_end_date	 => l_validation_end_date);
  --
  -- Call the supporting pre-update operation
  --
  pre_update
	(p_rec			 => p_rec,
	 p_effective_date	 => p_effective_date,
	 p_datetrack_mode	 => p_datetrack_mode,
	 p_validation_start_date => l_validation_start_date,
	 p_validation_end_date	 => l_validation_end_date);
  --
  -- Update the row.
  --
  update_dml
	(p_rec			 => p_rec,
	 p_effective_date	 => p_effective_date,
	 p_datetrack_mode	 => p_datetrack_mode,
	 p_validation_start_date => l_validation_start_date,
	 p_validation_end_date	 => l_validation_end_date);
  --
  -- Call the supporting post-update operation
  --
  post_update
	(p_rec			 => p_rec,
	 p_effective_date	 => p_effective_date,
	 p_datetrack_mode	 => p_datetrack_mode,
	 p_validation_start_date => l_validation_start_date,
	 p_validation_end_date	 => l_validation_end_date);
End upd;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (
  p_elig_to_prte_rsn_id          in number,
  p_effective_start_date         out nocopy date,
  p_effective_end_date           out nocopy date,
  p_business_group_id            in number           default hr_api.g_number,
  p_ler_id                       in number           default hr_api.g_number,
  p_oipl_id                      in number           default hr_api.g_number,
  p_pgm_id                       in number           default hr_api.g_number,
  p_pl_id                        in number           default hr_api.g_number,
  p_ptip_id                      in number           default hr_api.g_number,
  p_plip_id                      in number           default hr_api.g_number,
  p_ignr_prtn_ovrid_flag         in varchar2         default hr_api.g_varchar2,
  p_elig_inelig_cd               in varchar2         default hr_api.g_varchar2,
  p_prtn_eff_strt_dt_cd          in varchar2         default hr_api.g_varchar2,
  p_prtn_eff_strt_dt_rl          in number           default hr_api.g_number,
  p_prtn_eff_end_dt_cd           in varchar2         default hr_api.g_varchar2,
  p_prtn_eff_end_dt_rl           in number           default hr_api.g_number,
  p_wait_perd_dt_to_use_cd       in varchar2         default hr_api.g_varchar2,
  p_wait_perd_dt_to_use_rl       in number           default hr_api.g_number,
  p_wait_perd_val                in number           default hr_api.g_number,
  p_wait_perd_uom                in varchar2         default hr_api.g_varchar2,
  p_wait_perd_rl                 in number           default hr_api.g_number,
  p_mx_poe_det_dt_cd             in varchar2         default hr_api.g_varchar2,
  p_mx_poe_det_dt_rl             in number           default hr_api.g_number,
  p_mx_poe_val                   in number           default hr_api.g_number,
  p_mx_poe_uom                   in varchar2         default hr_api.g_varchar2,
  p_mx_poe_rl                    in number           default hr_api.g_number,
  p_mx_poe_apls_cd               in varchar2         default hr_api.g_varchar2,
  p_prtn_ovridbl_flag            in varchar2         default hr_api.g_varchar2,
  p_vrfy_fmly_mmbr_cd            in varchar2         default hr_api.g_varchar2,
  p_vrfy_fmly_mmbr_rl            in number           default hr_api.g_number,
  p_peo_attribute_category       in varchar2         default hr_api.g_varchar2,
  p_peo_attribute1               in varchar2         default hr_api.g_varchar2,
  p_peo_attribute2               in varchar2         default hr_api.g_varchar2,
  p_peo_attribute3               in varchar2         default hr_api.g_varchar2,
  p_peo_attribute4               in varchar2         default hr_api.g_varchar2,
  p_peo_attribute5               in varchar2         default hr_api.g_varchar2,
  p_peo_attribute6               in varchar2         default hr_api.g_varchar2,
  p_peo_attribute7               in varchar2         default hr_api.g_varchar2,
  p_peo_attribute8               in varchar2         default hr_api.g_varchar2,
  p_peo_attribute9               in varchar2         default hr_api.g_varchar2,
  p_peo_attribute10              in varchar2         default hr_api.g_varchar2,
  p_peo_attribute11              in varchar2         default hr_api.g_varchar2,
  p_peo_attribute12              in varchar2         default hr_api.g_varchar2,
  p_peo_attribute13              in varchar2         default hr_api.g_varchar2,
  p_peo_attribute14              in varchar2         default hr_api.g_varchar2,
  p_peo_attribute15              in varchar2         default hr_api.g_varchar2,
  p_peo_attribute16              in varchar2         default hr_api.g_varchar2,
  p_peo_attribute17              in varchar2         default hr_api.g_varchar2,
  p_peo_attribute18              in varchar2         default hr_api.g_varchar2,
  p_peo_attribute19              in varchar2         default hr_api.g_varchar2,
  p_peo_attribute20              in varchar2         default hr_api.g_varchar2,
  p_peo_attribute21              in varchar2         default hr_api.g_varchar2,
  p_peo_attribute22              in varchar2         default hr_api.g_varchar2,
  p_peo_attribute23              in varchar2         default hr_api.g_varchar2,
  p_peo_attribute24              in varchar2         default hr_api.g_varchar2,
  p_peo_attribute25              in varchar2         default hr_api.g_varchar2,
  p_peo_attribute26              in varchar2         default hr_api.g_varchar2,
  p_peo_attribute27              in varchar2         default hr_api.g_varchar2,
  p_peo_attribute28              in varchar2         default hr_api.g_varchar2,
  p_peo_attribute29              in varchar2         default hr_api.g_varchar2,
  p_peo_attribute30              in varchar2         default hr_api.g_varchar2,
  p_object_version_number        in out nocopy number,
  p_effective_date		 in date,
  p_datetrack_mode		 in varchar2
  ) is
--
  l_rec		ben_peo_shd.g_rec_type;
  l_proc	varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  ben_peo_shd.convert_args
  (
  p_elig_to_prte_rsn_id,
  null,
  null,
  p_business_group_id,
  p_ler_id,
  p_oipl_id,
  p_pgm_id,
  p_pl_id,
  p_ptip_id,
  p_plip_id,
  p_ignr_prtn_ovrid_flag,
  p_elig_inelig_cd,
  p_prtn_eff_strt_dt_cd,
  p_prtn_eff_strt_dt_rl,
  p_prtn_eff_end_dt_cd,
  p_prtn_eff_end_dt_rl,
  p_wait_perd_dt_to_use_cd,
  p_wait_perd_dt_to_use_rl,
  p_wait_perd_val,
  p_wait_perd_uom,
  p_wait_perd_rl,
  p_mx_poe_det_dt_cd,
  p_mx_poe_det_dt_rl,
  p_mx_poe_val,
  p_mx_poe_uom,
  p_mx_poe_rl,
  p_mx_poe_apls_cd,
  p_prtn_ovridbl_flag,
  p_vrfy_fmly_mmbr_cd,
  p_vrfy_fmly_mmbr_rl,
  p_peo_attribute_category,
  p_peo_attribute1,
  p_peo_attribute2,
  p_peo_attribute3,
  p_peo_attribute4,
  p_peo_attribute5,
  p_peo_attribute6,
  p_peo_attribute7,
  p_peo_attribute8,
  p_peo_attribute9,
  p_peo_attribute10,
  p_peo_attribute11,
  p_peo_attribute12,
  p_peo_attribute13,
  p_peo_attribute14,
  p_peo_attribute15,
  p_peo_attribute16,
  p_peo_attribute17,
  p_peo_attribute18,
  p_peo_attribute19,
  p_peo_attribute20,
  p_peo_attribute21,
  p_peo_attribute22,
  p_peo_attribute23,
  p_peo_attribute24,
  p_peo_attribute25,
  p_peo_attribute26,
  p_peo_attribute27,
  p_peo_attribute28,
  p_peo_attribute29,
  p_peo_attribute30,
  p_object_version_number
  );
  --
  -- Having converted the arguments into the
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  upd(l_rec, p_effective_date, p_datetrack_mode);
  p_object_version_number       := l_rec.object_version_number;
  p_effective_start_date        := l_rec.effective_start_date;
  p_effective_end_date          := l_rec.effective_end_date;
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End upd;
--
end ben_peo_upd;

/
