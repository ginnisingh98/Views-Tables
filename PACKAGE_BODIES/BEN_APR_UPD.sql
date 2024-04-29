--------------------------------------------------------
--  DDL for Package Body BEN_APR_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_APR_UPD" as
/* $Header: beaprrhi.pkb 120.0 2005/05/28 00:26:53 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_apr_upd.';  -- Global package name
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
	(p_rec 			 in out nocopy ben_apr_shd.g_rec_type,
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
	  (p_base_table_name	=> 'ben_actl_prem_f',
	   p_base_key_column	=> 'actl_prem_id',
	   p_base_key_value	=> p_rec.actl_prem_id);
    --
    ben_apr_shd.g_api_dml := true;  -- Set the api dml status
    --
    -- Update the ben_actl_prem_f Row
    --
    update  ben_actl_prem_f
    set
    actl_prem_id                    = p_rec.actl_prem_id,
    name                            = p_rec.name,
    acty_ref_perd_cd                = p_rec.acty_ref_perd_cd,
    uom                             = p_rec.uom,
    rt_typ_cd                       = p_rec.rt_typ_cd,
    bnft_rt_typ_cd                  = p_rec.bnft_rt_typ_cd,
    val                             = p_rec.val,
    mlt_cd                          = p_rec.mlt_cd,
    prdct_cd                        = p_rec.prdct_cd,
    rndg_cd                         = p_rec.rndg_cd,
    rndg_rl                         = p_rec.rndg_rl,
    val_calc_rl                   =p_rec.val_calc_rl
    ,prem_asnmt_cd                 =p_rec.prem_asnmt_cd
    ,prem_asnmt_lvl_cd             =p_rec.prem_asnmt_lvl_cd
    ,actl_prem_typ_cd              =p_rec.actl_prem_typ_cd
    ,prem_pyr_cd                   =p_rec.prem_pyr_cd
    ,cr_lkbk_val                   =p_rec.cr_lkbk_val
    ,cr_lkbk_uom                   =p_rec.cr_lkbk_uom
    ,cr_lkbk_crnt_py_only_flag     =p_rec.cr_lkbk_crnt_py_only_flag
    ,prsptv_r_rtsptv_cd            =p_rec.prsptv_r_rtsptv_cd
    ,upr_lmt_val                   =p_rec.upr_lmt_val
    ,upr_lmt_calc_rl               =p_rec.upr_lmt_calc_rl
    ,lwr_lmt_val                   =p_rec.lwr_lmt_val
    ,lwr_lmt_calc_rl               =p_rec.lwr_lmt_calc_rl
    ,cost_allocation_keyflex_id    =p_rec.cost_allocation_keyflex_id
    ,organization_id               =p_rec.organization_id
    ,oipl_id                       =p_rec.oipl_id
    ,pl_id                         =p_rec.pl_id
    ,comp_lvl_fctr_id                = p_rec.comp_lvl_fctr_id,
    business_group_id               = p_rec.business_group_id,
    prtl_mo_det_mthd_cd             = p_rec.prtl_mo_det_mthd_cd,
    prtl_mo_det_mthd_rl             = p_rec.prtl_mo_det_mthd_rl,
    wsh_rl_dy_mo_num                = p_rec.wsh_rl_dy_mo_num,
    vrbl_rt_add_on_calc_rl          = p_rec.vrbl_rt_add_on_calc_rl,
    apr_attribute_category          = p_rec.apr_attribute_category,
    apr_attribute1                  = p_rec.apr_attribute1,
    apr_attribute2                  = p_rec.apr_attribute2,
    apr_attribute3                  = p_rec.apr_attribute3,
    apr_attribute4                  = p_rec.apr_attribute4,
    apr_attribute5                  = p_rec.apr_attribute5,
    apr_attribute6                  = p_rec.apr_attribute6,
    apr_attribute7                  = p_rec.apr_attribute7,
    apr_attribute8                  = p_rec.apr_attribute8,
    apr_attribute9                  = p_rec.apr_attribute9,
    apr_attribute10                 = p_rec.apr_attribute10,
    apr_attribute11                 = p_rec.apr_attribute11,
    apr_attribute12                 = p_rec.apr_attribute12,
    apr_attribute13                 = p_rec.apr_attribute13,
    apr_attribute14                 = p_rec.apr_attribute14,
    apr_attribute15                 = p_rec.apr_attribute15,
    apr_attribute16                 = p_rec.apr_attribute16,
    apr_attribute17                 = p_rec.apr_attribute17,
    apr_attribute18                 = p_rec.apr_attribute18,
    apr_attribute19                 = p_rec.apr_attribute19,
    apr_attribute20                 = p_rec.apr_attribute20,
    apr_attribute21                 = p_rec.apr_attribute21,
    apr_attribute22                 = p_rec.apr_attribute22,
    apr_attribute23                 = p_rec.apr_attribute23,
    apr_attribute24                 = p_rec.apr_attribute24,
    apr_attribute25                 = p_rec.apr_attribute25,
    apr_attribute26                 = p_rec.apr_attribute26,
    apr_attribute27                 = p_rec.apr_attribute27,
    apr_attribute28                 = p_rec.apr_attribute28,
    apr_attribute29                 = p_rec.apr_attribute29,
    apr_attribute30                 = p_rec.apr_attribute30,
    object_version_number           = p_rec.object_version_number
    where   actl_prem_id = p_rec.actl_prem_id
    and     effective_start_date = p_validation_start_date
    and     effective_end_date   = p_validation_end_date;
    --
    ben_apr_shd.g_api_dml := false;   -- Unset the api dml status
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
    ben_apr_shd.g_api_dml := false;   -- Unset the api dml status
    ben_apr_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    ben_apr_shd.g_api_dml := false;   -- Unset the api dml status
    ben_apr_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    ben_apr_shd.g_api_dml := false;   -- Unset the api dml status
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
	(p_rec 			 in out nocopy ben_apr_shd.g_rec_type,
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
	(p_rec 			 in out nocopy ben_apr_shd.g_rec_type,
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
    ben_apr_shd.upd_effective_end_date
     (p_effective_date	       => p_effective_date,
      p_base_key_value	       => p_rec.actl_prem_id,
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
      ben_apr_del.delete_dml
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
    ben_apr_ins.insert_dml
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
	(p_rec 			 in out nocopy ben_apr_shd.g_rec_type,
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
	(p_rec 			 in ben_apr_shd.g_rec_type,
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
  --
  -- Start of API User Hook for post_update.
  --
  begin
    --
    ben_apr_rku.after_update
      (
  p_actl_prem_id                  =>p_rec.actl_prem_id
 ,p_effective_start_date          =>p_rec.effective_start_date
 ,p_effective_end_date            =>p_rec.effective_end_date
 ,p_name                          =>p_rec.name
 ,p_acty_ref_perd_cd              =>p_rec.acty_ref_perd_cd
 ,p_uom                           =>p_rec.uom
 ,p_rt_typ_cd                     =>p_rec.rt_typ_cd
 ,p_bnft_rt_typ_cd                =>p_rec.bnft_rt_typ_cd
 ,p_val                           =>p_rec.val
 ,p_mlt_cd                        =>p_rec.mlt_cd
 ,p_prdct_cd                      =>p_rec.prdct_cd
 ,p_rndg_cd                       =>p_rec.rndg_cd
 ,p_rndg_rl                       =>p_rec.rndg_rl
 ,p_val_calc_rl                   =>p_rec.val_calc_rl
 ,p_prem_asnmt_cd                 =>p_rec.prem_asnmt_cd
 ,p_prem_asnmt_lvl_cd             =>p_rec.prem_asnmt_lvl_cd
 ,p_actl_prem_typ_cd              =>p_rec.actl_prem_typ_cd
 ,p_prem_pyr_cd                   =>p_rec.prem_pyr_cd
 ,p_cr_lkbk_val                   =>p_rec.cr_lkbk_val
 ,p_cr_lkbk_uom                   =>p_rec.cr_lkbk_uom
 ,p_cr_lkbk_crnt_py_only_flag     =>p_rec.cr_lkbk_crnt_py_only_flag
 ,p_prsptv_r_rtsptv_cd            =>p_rec.prsptv_r_rtsptv_cd
 ,p_upr_lmt_val                   =>p_rec.upr_lmt_val
 ,p_upr_lmt_calc_rl               =>p_rec.upr_lmt_calc_rl
 ,p_lwr_lmt_val                   =>p_rec.lwr_lmt_val
 ,p_lwr_lmt_calc_rl               =>p_rec.lwr_lmt_calc_rl
 ,p_cost_allocation_keyflex_id    =>p_rec.cost_allocation_keyflex_id
 ,p_organization_id               =>p_rec.organization_id
 ,p_oipl_id                       =>p_rec.oipl_id
 ,p_pl_id                         =>p_rec.pl_id
 ,p_comp_lvl_fctr_id              =>p_rec.comp_lvl_fctr_id
 ,p_business_group_id             =>p_rec.business_group_id
 ,p_prtl_mo_det_mthd_cd             => p_rec.prtl_mo_det_mthd_cd
 ,p_prtl_mo_det_mthd_rl             => p_rec.prtl_mo_det_mthd_rl
 ,p_wsh_rl_dy_mo_num                => p_rec.wsh_rl_dy_mo_num
 ,p_vrbl_rt_add_on_calc_rl        =>p_rec.vrbl_rt_add_on_calc_rl
 ,p_apr_attribute_category        =>p_rec.apr_attribute_category
 ,p_apr_attribute1                =>p_rec.apr_attribute1
 ,p_apr_attribute2                =>p_rec.apr_attribute2
 ,p_apr_attribute3                =>p_rec.apr_attribute3
 ,p_apr_attribute4                =>p_rec.apr_attribute4
 ,p_apr_attribute5                =>p_rec.apr_attribute5
 ,p_apr_attribute6                =>p_rec.apr_attribute6
 ,p_apr_attribute7                =>p_rec.apr_attribute7
 ,p_apr_attribute8                =>p_rec.apr_attribute8
 ,p_apr_attribute9                =>p_rec.apr_attribute9
 ,p_apr_attribute10               =>p_rec.apr_attribute10
 ,p_apr_attribute11               =>p_rec.apr_attribute11
 ,p_apr_attribute12               =>p_rec.apr_attribute12
 ,p_apr_attribute13               =>p_rec.apr_attribute13
 ,p_apr_attribute14               =>p_rec.apr_attribute14
 ,p_apr_attribute15               =>p_rec.apr_attribute15
 ,p_apr_attribute16               =>p_rec.apr_attribute16
 ,p_apr_attribute17               =>p_rec.apr_attribute17
 ,p_apr_attribute18               =>p_rec.apr_attribute18
 ,p_apr_attribute19               =>p_rec.apr_attribute19
 ,p_apr_attribute20               =>p_rec.apr_attribute20
 ,p_apr_attribute21               =>p_rec.apr_attribute21
 ,p_apr_attribute22               =>p_rec.apr_attribute22
 ,p_apr_attribute23               =>p_rec.apr_attribute23
 ,p_apr_attribute24               =>p_rec.apr_attribute24
 ,p_apr_attribute25               =>p_rec.apr_attribute25
 ,p_apr_attribute26               =>p_rec.apr_attribute26
 ,p_apr_attribute27               =>p_rec.apr_attribute27
 ,p_apr_attribute28               =>p_rec.apr_attribute28
 ,p_apr_attribute29               =>p_rec.apr_attribute29
 ,p_apr_attribute30               =>p_rec.apr_attribute30
 ,p_object_version_number         =>p_rec.object_version_number
 ,p_effective_date                =>p_effective_date
 ,p_datetrack_mode                =>p_datetrack_mode
 ,p_validation_start_date         =>p_validation_start_date
 ,p_validation_end_date           =>p_validation_end_date
 ,p_effective_start_date_o        =>ben_apr_shd.g_old_rec.effective_start_date
 ,p_effective_end_date_o          =>ben_apr_shd.g_old_rec.effective_end_date
 ,p_name_o                        =>ben_apr_shd.g_old_rec.name
 ,p_acty_ref_perd_cd_o            =>ben_apr_shd.g_old_rec.acty_ref_perd_cd
 ,p_uom_o                         =>ben_apr_shd.g_old_rec.uom
 ,p_rt_typ_cd_o                   =>ben_apr_shd.g_old_rec.rt_typ_cd
 ,p_bnft_rt_typ_cd_o              =>ben_apr_shd.g_old_rec.bnft_rt_typ_cd
 ,p_val_o                         =>ben_apr_shd.g_old_rec.val
 ,p_mlt_cd_o                      =>ben_apr_shd.g_old_rec.mlt_cd
 ,p_prdct_cd_o                    =>ben_apr_shd.g_old_rec.prdct_cd
 ,p_rndg_cd_o                     =>ben_apr_shd.g_old_rec.rndg_cd
 ,p_rndg_rl_o                     =>ben_apr_shd.g_old_rec.rndg_rl
 ,p_val_calc_rl_o                   =>ben_apr_shd.g_old_rec.val_calc_rl
 ,p_prem_asnmt_cd_o                 =>ben_apr_shd.g_old_rec.prem_asnmt_cd
 ,p_prem_asnmt_lvl_cd_o             =>ben_apr_shd.g_old_rec.prem_asnmt_lvl_cd
 ,p_actl_prem_typ_cd_o              =>ben_apr_shd.g_old_rec.actl_prem_typ_cd
 ,p_prem_pyr_cd_o                   =>ben_apr_shd.g_old_rec.prem_pyr_cd
 ,p_cr_lkbk_val_o                   =>ben_apr_shd.g_old_rec.cr_lkbk_val
 ,p_cr_lkbk_uom_o                   =>ben_apr_shd.g_old_rec.cr_lkbk_uom
 ,p_cr_lkbk_crnt_py_only_flag_o     =>ben_apr_shd.g_old_rec.cr_lkbk_crnt_py_only_flag
 ,p_prsptv_r_rtsptv_cd_o            =>ben_apr_shd.g_old_rec.prsptv_r_rtsptv_cd
 ,p_upr_lmt_val_o                   =>ben_apr_shd.g_old_rec.upr_lmt_val
 ,p_upr_lmt_calc_rl_o               =>ben_apr_shd.g_old_rec.upr_lmt_calc_rl
 ,p_lwr_lmt_val_o                   =>ben_apr_shd.g_old_rec.lwr_lmt_val
 ,p_lwr_lmt_calc_rl_o               =>ben_apr_shd.g_old_rec.lwr_lmt_calc_rl
 ,p_cost_allocation_keyflex_id_o    =>ben_apr_shd.g_old_rec.cost_allocation_keyflex_id
 ,p_organization_id_o               =>ben_apr_shd.g_old_rec.organization_id
 ,p_oipl_id_o                       =>ben_apr_shd.g_old_rec.oipl_id
 ,p_pl_id_o                         =>ben_apr_shd.g_old_rec.pl_id
 ,p_comp_lvl_fctr_id_o            =>ben_apr_shd.g_old_rec.comp_lvl_fctr_id
 ,p_business_group_id_o           =>ben_apr_shd.g_old_rec.business_group_id
 ,p_prtl_mo_det_mthd_cd_o             => ben_apr_shd.g_old_rec.prtl_mo_det_mthd_cd
 ,p_prtl_mo_det_mthd_rl_o             => ben_apr_shd.g_old_rec.prtl_mo_det_mthd_rl
 ,p_wsh_rl_dy_mo_num_o                => ben_apr_shd.g_old_rec.wsh_rl_dy_mo_num
 ,p_vrbl_rt_add_on_calc_rl_o      =>ben_apr_shd.g_old_rec.vrbl_rt_add_on_calc_rl
 ,p_apr_attribute_category_o      =>ben_apr_shd.g_old_rec.apr_attribute_category
 ,p_apr_attribute1_o              =>ben_apr_shd.g_old_rec.apr_attribute1
 ,p_apr_attribute2_o              =>ben_apr_shd.g_old_rec.apr_attribute2
 ,p_apr_attribute3_o              =>ben_apr_shd.g_old_rec.apr_attribute3
 ,p_apr_attribute4_o              =>ben_apr_shd.g_old_rec.apr_attribute4
 ,p_apr_attribute5_o              =>ben_apr_shd.g_old_rec.apr_attribute5
 ,p_apr_attribute6_o              =>ben_apr_shd.g_old_rec.apr_attribute6
 ,p_apr_attribute7_o              =>ben_apr_shd.g_old_rec.apr_attribute7
 ,p_apr_attribute8_o              =>ben_apr_shd.g_old_rec.apr_attribute8
 ,p_apr_attribute9_o              =>ben_apr_shd.g_old_rec.apr_attribute9
 ,p_apr_attribute10_o             =>ben_apr_shd.g_old_rec.apr_attribute10
 ,p_apr_attribute11_o             =>ben_apr_shd.g_old_rec.apr_attribute11
 ,p_apr_attribute12_o             =>ben_apr_shd.g_old_rec.apr_attribute12
 ,p_apr_attribute13_o             =>ben_apr_shd.g_old_rec.apr_attribute13
 ,p_apr_attribute14_o             =>ben_apr_shd.g_old_rec.apr_attribute14
 ,p_apr_attribute15_o             =>ben_apr_shd.g_old_rec.apr_attribute15
 ,p_apr_attribute16_o             =>ben_apr_shd.g_old_rec.apr_attribute16
 ,p_apr_attribute17_o             =>ben_apr_shd.g_old_rec.apr_attribute17
 ,p_apr_attribute18_o             =>ben_apr_shd.g_old_rec.apr_attribute18
 ,p_apr_attribute19_o             =>ben_apr_shd.g_old_rec.apr_attribute19
 ,p_apr_attribute20_o             =>ben_apr_shd.g_old_rec.apr_attribute20
 ,p_apr_attribute21_o             =>ben_apr_shd.g_old_rec.apr_attribute21
 ,p_apr_attribute22_o             =>ben_apr_shd.g_old_rec.apr_attribute22
 ,p_apr_attribute23_o             =>ben_apr_shd.g_old_rec.apr_attribute23
 ,p_apr_attribute24_o             =>ben_apr_shd.g_old_rec.apr_attribute24
 ,p_apr_attribute25_o             =>ben_apr_shd.g_old_rec.apr_attribute25
 ,p_apr_attribute26_o             =>ben_apr_shd.g_old_rec.apr_attribute26
 ,p_apr_attribute27_o             =>ben_apr_shd.g_old_rec.apr_attribute27
 ,p_apr_attribute28_o             =>ben_apr_shd.g_old_rec.apr_attribute28
 ,p_apr_attribute29_o             =>ben_apr_shd.g_old_rec.apr_attribute29
 ,p_apr_attribute30_o             =>ben_apr_shd.g_old_rec.apr_attribute30
 ,p_object_version_number_o       =>ben_apr_shd.g_old_rec.object_version_number
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'ben_actl_prem_f'
        ,p_hook_type   => 'AU');
      --
  end;
  --
  -- End of API User Hook for post_update.
  --
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
Procedure convert_defs(p_rec in out nocopy ben_apr_shd.g_rec_type) is
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
  If (p_rec.name = hr_api.g_varchar2) then
    p_rec.name :=
    ben_apr_shd.g_old_rec.name;
  End If;
  If (p_rec.acty_ref_perd_cd = hr_api.g_varchar2) then
    p_rec.acty_ref_perd_cd :=
    ben_apr_shd.g_old_rec.acty_ref_perd_cd;
  End If;
  If (p_rec.uom = hr_api.g_varchar2) then
    p_rec.uom :=
    ben_apr_shd.g_old_rec.uom;
  End If;
  If (p_rec.rt_typ_cd = hr_api.g_varchar2) then
    p_rec.rt_typ_cd :=
    ben_apr_shd.g_old_rec.rt_typ_cd;
  End If;
  If (p_rec.bnft_rt_typ_cd = hr_api.g_varchar2) then
    p_rec.bnft_rt_typ_cd :=
    ben_apr_shd.g_old_rec.bnft_rt_typ_cd;
  End If;
  If (p_rec.val = hr_api.g_number) then
    p_rec.val :=
    ben_apr_shd.g_old_rec.val;
  End If;
  If (p_rec.mlt_cd = hr_api.g_varchar2) then
    p_rec.mlt_cd :=
    ben_apr_shd.g_old_rec.mlt_cd;
  End If;
  If (p_rec.prdct_cd = hr_api.g_varchar2) then
    p_rec.prdct_cd :=
    ben_apr_shd.g_old_rec.prdct_cd;
  End If;
  If (p_rec.rndg_cd = hr_api.g_varchar2) then
    p_rec.rndg_cd :=
    ben_apr_shd.g_old_rec.rndg_cd;
  End If;
  If (p_rec.rndg_rl = hr_api.g_number) then
    p_rec.rndg_rl :=
    ben_apr_shd.g_old_rec.rndg_rl;
  End If;
  If (p_rec.comp_lvl_fctr_id = hr_api.g_number) then
    p_rec.comp_lvl_fctr_id :=
    ben_apr_shd.g_old_rec.comp_lvl_fctr_id;
  End If;
  If (p_rec.organization_id = hr_api.g_number) then
    p_rec.organization_id :=
    ben_apr_shd.g_old_rec.organization_id;
  End If;
  If (p_rec.business_group_id = hr_api.g_number) then
    p_rec.business_group_id :=
    ben_apr_shd.g_old_rec.business_group_id;
  End If;
  If (p_rec.val_calc_rl = hr_api.g_number) then
    p_rec.val_calc_rl :=
    ben_apr_shd.g_old_rec.val_calc_rl;
  End If;
  If (p_rec.prtl_mo_det_mthd_cd = hr_api.g_varchar2) then
    p_rec.prtl_mo_det_mthd_cd :=
    ben_apr_shd.g_old_rec.prtl_mo_det_mthd_cd;
  End If;
  If (p_rec.prtl_mo_det_mthd_rl = hr_api.g_number) then
    p_rec.prtl_mo_det_mthd_rl :=
    ben_apr_shd.g_old_rec.prtl_mo_det_mthd_rl;
  End If;
  If (p_rec.wsh_rl_dy_mo_num = hr_api.g_number) then
    p_rec.wsh_rl_dy_mo_num :=
    ben_apr_shd.g_old_rec.wsh_rl_dy_mo_num;
  End If;
  If (p_rec.vrbl_rt_add_on_calc_rl = hr_api.g_number) then
    p_rec.vrbl_rt_add_on_calc_rl :=
    ben_apr_shd.g_old_rec.vrbl_rt_add_on_calc_rl;
  End If;
  If (p_rec.apr_attribute_category = hr_api.g_varchar2) then
    p_rec.apr_attribute_category :=
    ben_apr_shd.g_old_rec.apr_attribute_category;
  End If;
  If (p_rec.apr_attribute1 = hr_api.g_varchar2) then
    p_rec.apr_attribute1 :=
    ben_apr_shd.g_old_rec.apr_attribute1;
  End If;
  If (p_rec.apr_attribute2 = hr_api.g_varchar2) then
    p_rec.apr_attribute2 :=
    ben_apr_shd.g_old_rec.apr_attribute2;
  End If;
  If (p_rec.apr_attribute3 = hr_api.g_varchar2) then
    p_rec.apr_attribute3 :=
    ben_apr_shd.g_old_rec.apr_attribute3;
  End If;
  If (p_rec.apr_attribute4 = hr_api.g_varchar2) then
    p_rec.apr_attribute4 :=
    ben_apr_shd.g_old_rec.apr_attribute4;
  End If;
  If (p_rec.apr_attribute5 = hr_api.g_varchar2) then
    p_rec.apr_attribute5 :=
    ben_apr_shd.g_old_rec.apr_attribute5;
  End If;
  If (p_rec.apr_attribute6 = hr_api.g_varchar2) then
    p_rec.apr_attribute6 :=
    ben_apr_shd.g_old_rec.apr_attribute6;
  End If;
  If (p_rec.apr_attribute7 = hr_api.g_varchar2) then
    p_rec.apr_attribute7 :=
    ben_apr_shd.g_old_rec.apr_attribute7;
  End If;
  If (p_rec.apr_attribute8 = hr_api.g_varchar2) then
    p_rec.apr_attribute8 :=
    ben_apr_shd.g_old_rec.apr_attribute8;
  End If;
  If (p_rec.apr_attribute9 = hr_api.g_varchar2) then
    p_rec.apr_attribute9 :=
    ben_apr_shd.g_old_rec.apr_attribute9;
  End If;
  If (p_rec.apr_attribute10 = hr_api.g_varchar2) then
    p_rec.apr_attribute10 :=
    ben_apr_shd.g_old_rec.apr_attribute10;
  End If;
  If (p_rec.apr_attribute11 = hr_api.g_varchar2) then
    p_rec.apr_attribute11 :=
    ben_apr_shd.g_old_rec.apr_attribute11;
  End If;
  If (p_rec.apr_attribute12 = hr_api.g_varchar2) then
    p_rec.apr_attribute12 :=
    ben_apr_shd.g_old_rec.apr_attribute12;
  End If;
  If (p_rec.apr_attribute13 = hr_api.g_varchar2) then
    p_rec.apr_attribute13 :=
    ben_apr_shd.g_old_rec.apr_attribute13;
  End If;
  If (p_rec.apr_attribute14 = hr_api.g_varchar2) then
    p_rec.apr_attribute14 :=
    ben_apr_shd.g_old_rec.apr_attribute14;
  End If;
  If (p_rec.apr_attribute15 = hr_api.g_varchar2) then
    p_rec.apr_attribute15 :=
    ben_apr_shd.g_old_rec.apr_attribute15;
  End If;
  If (p_rec.apr_attribute16 = hr_api.g_varchar2) then
    p_rec.apr_attribute16 :=
    ben_apr_shd.g_old_rec.apr_attribute16;
  End If;
  If (p_rec.apr_attribute17 = hr_api.g_varchar2) then
    p_rec.apr_attribute17 :=
    ben_apr_shd.g_old_rec.apr_attribute17;
  End If;
  If (p_rec.apr_attribute18 = hr_api.g_varchar2) then
    p_rec.apr_attribute18 :=
    ben_apr_shd.g_old_rec.apr_attribute18;
  End If;
  If (p_rec.apr_attribute19 = hr_api.g_varchar2) then
    p_rec.apr_attribute19 :=
    ben_apr_shd.g_old_rec.apr_attribute19;
  End If;
  If (p_rec.apr_attribute20 = hr_api.g_varchar2) then
    p_rec.apr_attribute20 :=
    ben_apr_shd.g_old_rec.apr_attribute20;
  End If;
  If (p_rec.apr_attribute21 = hr_api.g_varchar2) then
    p_rec.apr_attribute21 :=
    ben_apr_shd.g_old_rec.apr_attribute21;
  End If;
  If (p_rec.apr_attribute22 = hr_api.g_varchar2) then
    p_rec.apr_attribute22 :=
    ben_apr_shd.g_old_rec.apr_attribute22;
  End If;
  If (p_rec.apr_attribute23 = hr_api.g_varchar2) then
    p_rec.apr_attribute23 :=
    ben_apr_shd.g_old_rec.apr_attribute23;
  End If;
  If (p_rec.apr_attribute24 = hr_api.g_varchar2) then
    p_rec.apr_attribute24 :=
    ben_apr_shd.g_old_rec.apr_attribute24;
  End If;
  If (p_rec.apr_attribute25 = hr_api.g_varchar2) then
    p_rec.apr_attribute25 :=
    ben_apr_shd.g_old_rec.apr_attribute25;
  End If;
  If (p_rec.apr_attribute26 = hr_api.g_varchar2) then
    p_rec.apr_attribute26 :=
    ben_apr_shd.g_old_rec.apr_attribute26;
  End If;
  If (p_rec.apr_attribute27 = hr_api.g_varchar2) then
    p_rec.apr_attribute27 :=
    ben_apr_shd.g_old_rec.apr_attribute27;
  End If;
  If (p_rec.apr_attribute28 = hr_api.g_varchar2) then
    p_rec.apr_attribute28 :=
    ben_apr_shd.g_old_rec.apr_attribute28;
  End If;
  If (p_rec.apr_attribute29 = hr_api.g_varchar2) then
    p_rec.apr_attribute29 :=
    ben_apr_shd.g_old_rec.apr_attribute29;
  End If;
  If (p_rec.apr_attribute30 = hr_api.g_varchar2) then
    p_rec.apr_attribute30 :=
    ben_apr_shd.g_old_rec.apr_attribute30;
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
  p_rec			in out nocopy 	ben_apr_shd.g_rec_type,
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
  ben_apr_shd.lck
	(p_effective_date	 => p_effective_date,
      	 p_datetrack_mode	 => p_datetrack_mode,
      	 p_actl_prem_id	 => p_rec.actl_prem_id,
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
  ben_apr_bus.update_validate
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
  p_actl_prem_id                 in number,
  p_effective_start_date         out nocopy date,
  p_effective_end_date           out nocopy date,
  p_name                         in varchar2         default hr_api.g_varchar2,
  p_acty_ref_perd_cd             in varchar2         default hr_api.g_varchar2,
  p_uom                          in varchar2         default hr_api.g_varchar2,
  p_rt_typ_cd                    in varchar2         default hr_api.g_varchar2,
  p_bnft_rt_typ_cd               in varchar2         default hr_api.g_varchar2,
  p_val                          in number           default hr_api.g_number,
  p_mlt_cd                       in varchar2         default hr_api.g_varchar2,
  p_prdct_cd                     in varchar2         default hr_api.g_varchar2,
  p_rndg_cd                      in varchar2         default hr_api.g_varchar2,
  p_rndg_rl                      in number           default hr_api.g_number,
  p_val_calc_rl                  in number           default hr_api.g_number,
  p_prem_asnmt_cd                 in varchar2       default hr_api.g_varchar2,
  p_prem_asnmt_lvl_cd             in varchar2       default hr_api.g_varchar2,
  p_actl_prem_typ_cd              in varchar2       default hr_api.g_varchar2,
  p_prem_pyr_cd                   in varchar2       default hr_api.g_varchar2,
  p_cr_lkbk_val                   in number         default hr_api.g_number,
  p_cr_lkbk_uom                   in varchar2       default hr_api.g_varchar2,
  p_cr_lkbk_crnt_py_only_flag     in varchar2,
  p_prsptv_r_rtsptv_cd            in varchar2      default hr_api.g_varchar2,
  p_upr_lmt_val                   in number         default hr_api.g_number,
  p_upr_lmt_calc_rl               in number         default hr_api.g_number,
  p_lwr_lmt_val                   in number         default hr_api.g_number,
  p_lwr_lmt_calc_rl               in number         default hr_api.g_number,
  p_cost_allocation_keyflex_id    in number         default hr_api.g_number,
  p_organization_id               in number         default hr_api.g_number,
  p_oipl_id                       in number         default hr_api.g_number,
  p_pl_id                         in number         default hr_api.g_number,
  p_comp_lvl_fctr_id             in number           default hr_api.g_number,
  p_business_group_id            in number           default hr_api.g_number,
  p_prtl_mo_det_mthd_cd                      in varchar2         default hr_api.g_varchar2,
  p_prtl_mo_det_mthd_rl                      in number           default hr_api.g_number,
  p_wsh_rl_dy_mo_num                      in number           default hr_api.g_number,
  p_vrbl_rt_add_on_calc_rl       in number           default hr_api.g_number,
  p_apr_attribute_category       in varchar2         default hr_api.g_varchar2,
  p_apr_attribute1               in varchar2         default hr_api.g_varchar2,
  p_apr_attribute2               in varchar2         default hr_api.g_varchar2,
  p_apr_attribute3               in varchar2         default hr_api.g_varchar2,
  p_apr_attribute4               in varchar2         default hr_api.g_varchar2,
  p_apr_attribute5               in varchar2         default hr_api.g_varchar2,
  p_apr_attribute6               in varchar2         default hr_api.g_varchar2,
  p_apr_attribute7               in varchar2         default hr_api.g_varchar2,
  p_apr_attribute8               in varchar2         default hr_api.g_varchar2,
  p_apr_attribute9               in varchar2         default hr_api.g_varchar2,
  p_apr_attribute10              in varchar2         default hr_api.g_varchar2,
  p_apr_attribute11              in varchar2         default hr_api.g_varchar2,
  p_apr_attribute12              in varchar2         default hr_api.g_varchar2,
  p_apr_attribute13              in varchar2         default hr_api.g_varchar2,
  p_apr_attribute14              in varchar2         default hr_api.g_varchar2,
  p_apr_attribute15              in varchar2         default hr_api.g_varchar2,
  p_apr_attribute16              in varchar2         default hr_api.g_varchar2,
  p_apr_attribute17              in varchar2         default hr_api.g_varchar2,
  p_apr_attribute18              in varchar2         default hr_api.g_varchar2,
  p_apr_attribute19              in varchar2         default hr_api.g_varchar2,
  p_apr_attribute20              in varchar2         default hr_api.g_varchar2,
  p_apr_attribute21              in varchar2         default hr_api.g_varchar2,
  p_apr_attribute22              in varchar2         default hr_api.g_varchar2,
  p_apr_attribute23              in varchar2         default hr_api.g_varchar2,
  p_apr_attribute24              in varchar2         default hr_api.g_varchar2,
  p_apr_attribute25              in varchar2         default hr_api.g_varchar2,
  p_apr_attribute26              in varchar2         default hr_api.g_varchar2,
  p_apr_attribute27              in varchar2         default hr_api.g_varchar2,
  p_apr_attribute28              in varchar2         default hr_api.g_varchar2,
  p_apr_attribute29              in varchar2         default hr_api.g_varchar2,
  p_apr_attribute30              in varchar2         default hr_api.g_varchar2,
  p_object_version_number        in out nocopy number,
  p_effective_date		 in date,
  p_datetrack_mode		 in varchar2
  ) is
--
  l_rec		ben_apr_shd.g_rec_type;
  l_proc	varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  ben_apr_shd.convert_args
  (
  p_actl_prem_id,
  null,
  null,
  p_name,
  p_acty_ref_perd_cd,
  p_uom,
  p_rt_typ_cd,
  p_bnft_rt_typ_cd,
  p_val,
  p_mlt_cd,
  p_prdct_cd,
  p_rndg_cd,
  p_rndg_rl,
  p_val_calc_rl,
  p_prem_asnmt_cd,
  p_prem_asnmt_lvl_cd,
  p_actl_prem_typ_cd,
  p_prem_pyr_cd,
  p_cr_lkbk_val,
  p_cr_lkbk_uom,
  p_cr_lkbk_crnt_py_only_flag,
  p_prsptv_r_rtsptv_cd,
  p_upr_lmt_val,
  p_upr_lmt_calc_rl,
  p_lwr_lmt_val,
  p_lwr_lmt_calc_rl,
  p_cost_allocation_keyflex_id,
  p_organization_id,
  p_oipl_id,
  p_pl_id,
  p_comp_lvl_fctr_id,
  p_business_group_id,
  p_prtl_mo_det_mthd_cd,
  p_prtl_mo_det_mthd_rl,
  p_wsh_rl_dy_mo_num,
  p_vrbl_rt_add_on_calc_rl,
  p_apr_attribute_category,
  p_apr_attribute1,
  p_apr_attribute2,
  p_apr_attribute3,
  p_apr_attribute4,
  p_apr_attribute5,
  p_apr_attribute6,
  p_apr_attribute7,
  p_apr_attribute8,
  p_apr_attribute9,
  p_apr_attribute10,
  p_apr_attribute11,
  p_apr_attribute12,
  p_apr_attribute13,
  p_apr_attribute14,
  p_apr_attribute15,
  p_apr_attribute16,
  p_apr_attribute17,
  p_apr_attribute18,
  p_apr_attribute19,
  p_apr_attribute20,
  p_apr_attribute21,
  p_apr_attribute22,
  p_apr_attribute23,
  p_apr_attribute24,
  p_apr_attribute25,
  p_apr_attribute26,
  p_apr_attribute27,
  p_apr_attribute28,
  p_apr_attribute29,
  p_apr_attribute30,
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
end ben_apr_upd;

/
