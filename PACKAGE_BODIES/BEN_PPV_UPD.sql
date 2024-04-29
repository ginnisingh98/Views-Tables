--------------------------------------------------------
--  DDL for Package Body BEN_PPV_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PPV_UPD" as
/* $Header: beppvrhi.pkb 120.5.12010000.2 2008/08/05 15:17:18 ubhat ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_ppv_upd.';  -- Global package name
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
	(p_rec 			 in out nocopy ben_ppv_shd.g_rec_type,
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
	  (p_base_table_name	=> 'ben_prtl_mo_rt_prtn_val_f',
	   p_base_key_column	=> 'prtl_mo_rt_prtn_val_id',
	   p_base_key_value	=> p_rec.prtl_mo_rt_prtn_val_id);
    --
    ben_ppv_shd.g_api_dml := true;  -- Set the api dml status
    --
    -- Update the ben_prtl_mo_rt_prtn_val_f Row
    --
    update  ben_prtl_mo_rt_prtn_val_f
    set
        prtl_mo_rt_prtn_val_id          = p_rec.prtl_mo_rt_prtn_val_id,
    business_group_id               = p_rec.business_group_id,
    rndg_cd                         = p_rec.rndg_cd,
    to_dy_mo_num                    = p_rec.to_dy_mo_num,
    from_dy_mo_num                  = p_rec.from_dy_mo_num,
    pct_val                         = p_rec.pct_val,
    acty_base_rt_id                 = p_rec.acty_base_rt_id,
    strt_r_stp_cvg_cd               = p_rec.strt_r_stp_cvg_cd,
    rndg_rl                         = p_rec.rndg_rl,
    prtl_mo_prortn_rl               = p_rec.prtl_mo_prortn_rl,
    actl_prem_id                    = p_rec.actl_prem_id,
    cvg_amt_calc_mthd_id            = p_rec.cvg_amt_calc_mthd_id,
    num_days_month                  = p_rec.num_days_month,
    prorate_by_day_to_mon_flag      = p_rec.prorate_by_day_to_mon_flag,
    pmrpv_attribute_category        = p_rec.pmrpv_attribute_category,
    pmrpv_attribute1                = p_rec.pmrpv_attribute1,
    pmrpv_attribute2                = p_rec.pmrpv_attribute2,
    pmrpv_attribute3                = p_rec.pmrpv_attribute3,
    pmrpv_attribute4                = p_rec.pmrpv_attribute4,
    pmrpv_attribute5                = p_rec.pmrpv_attribute5,
    pmrpv_attribute6                = p_rec.pmrpv_attribute6,
    pmrpv_attribute7                = p_rec.pmrpv_attribute7,
    pmrpv_attribute8                = p_rec.pmrpv_attribute8,
    pmrpv_attribute9                = p_rec.pmrpv_attribute9,
    pmrpv_attribute10               = p_rec.pmrpv_attribute10,
    pmrpv_attribute11               = p_rec.pmrpv_attribute11,
    pmrpv_attribute12               = p_rec.pmrpv_attribute12,
    pmrpv_attribute13               = p_rec.pmrpv_attribute13,
    pmrpv_attribute14               = p_rec.pmrpv_attribute14,
    pmrpv_attribute15               = p_rec.pmrpv_attribute15,
    pmrpv_attribute16               = p_rec.pmrpv_attribute16,
    pmrpv_attribute17               = p_rec.pmrpv_attribute17,
    pmrpv_attribute18               = p_rec.pmrpv_attribute18,
    pmrpv_attribute19               = p_rec.pmrpv_attribute19,
    pmrpv_attribute20               = p_rec.pmrpv_attribute20,
    pmrpv_attribute21               = p_rec.pmrpv_attribute21,
    pmrpv_attribute22               = p_rec.pmrpv_attribute22,
    pmrpv_attribute23               = p_rec.pmrpv_attribute23,
    pmrpv_attribute24               = p_rec.pmrpv_attribute24,
    pmrpv_attribute25               = p_rec.pmrpv_attribute25,
    pmrpv_attribute26               = p_rec.pmrpv_attribute26,
    pmrpv_attribute27               = p_rec.pmrpv_attribute27,
    pmrpv_attribute28               = p_rec.pmrpv_attribute28,
    pmrpv_attribute29               = p_rec.pmrpv_attribute29,
    pmrpv_attribute30               = p_rec.pmrpv_attribute30,
    object_version_number           = p_rec.object_version_number
    where   prtl_mo_rt_prtn_val_id = p_rec.prtl_mo_rt_prtn_val_id
    and     effective_start_date = p_validation_start_date
    and     effective_end_date   = p_validation_end_date;
    --
    ben_ppv_shd.g_api_dml := false;   -- Unset the api dml status
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
    ben_ppv_shd.g_api_dml := false;   -- Unset the api dml status
    ben_ppv_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    ben_ppv_shd.g_api_dml := false;   -- Unset the api dml status
    ben_ppv_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    ben_ppv_shd.g_api_dml := false;   -- Unset the api dml status
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
	(p_rec 			 in out nocopy ben_ppv_shd.g_rec_type,
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
	(p_rec 			 in out nocopy ben_ppv_shd.g_rec_type,
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
    ben_ppv_shd.upd_effective_end_date
     (p_effective_date	       => p_effective_date,
      p_base_key_value	       => p_rec.prtl_mo_rt_prtn_val_id,
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
      ben_ppv_del.delete_dml
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
    ben_ppv_ins.insert_dml
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
	(p_rec 			 in out nocopy ben_ppv_shd.g_rec_type,
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
	(p_rec 			 in ben_ppv_shd.g_rec_type,
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
    ben_ppv_rku.after_update
      (
  p_prtl_mo_rt_prtn_val_id        =>p_rec.prtl_mo_rt_prtn_val_id
 ,p_effective_end_date            =>p_rec.effective_end_date
 ,p_effective_start_date          =>p_rec.effective_start_date
 ,p_business_group_id             =>p_rec.business_group_id
 ,p_rndg_cd                       =>p_rec.rndg_cd
 ,p_to_dy_mo_num                  =>p_rec.to_dy_mo_num
 ,p_from_dy_mo_num                =>p_rec.from_dy_mo_num
 ,p_pct_val                       =>p_rec.pct_val
 ,p_acty_base_rt_id               =>p_rec.acty_base_rt_id
 ,p_strt_r_stp_cvg_cd             =>p_rec.strt_r_stp_cvg_cd
 ,p_rndg_rl                       =>p_rec.rndg_rl
 ,p_prtl_mo_prortn_rl             =>p_rec.prtl_mo_prortn_rl
 ,p_actl_prem_id                  =>p_rec.actl_prem_id
 ,p_cvg_amt_calc_mthd_id          =>p_rec.cvg_amt_calc_mthd_id
 ,p_num_days_month                =>p_rec.num_days_month
 ,p_prorate_by_day_to_mon_flag    =>p_rec.prorate_by_day_to_mon_flag
 ,p_pmrpv_attribute_category      =>p_rec.pmrpv_attribute_category
 ,p_pmrpv_attribute1              =>p_rec.pmrpv_attribute1
 ,p_pmrpv_attribute2              =>p_rec.pmrpv_attribute2
 ,p_pmrpv_attribute3              =>p_rec.pmrpv_attribute3
 ,p_pmrpv_attribute4              =>p_rec.pmrpv_attribute4
 ,p_pmrpv_attribute5              =>p_rec.pmrpv_attribute5
 ,p_pmrpv_attribute6              =>p_rec.pmrpv_attribute6
 ,p_pmrpv_attribute7              =>p_rec.pmrpv_attribute7
 ,p_pmrpv_attribute8              =>p_rec.pmrpv_attribute8
 ,p_pmrpv_attribute9              =>p_rec.pmrpv_attribute9
 ,p_pmrpv_attribute10             =>p_rec.pmrpv_attribute10
 ,p_pmrpv_attribute11             =>p_rec.pmrpv_attribute11
 ,p_pmrpv_attribute12             =>p_rec.pmrpv_attribute12
 ,p_pmrpv_attribute13             =>p_rec.pmrpv_attribute13
 ,p_pmrpv_attribute14             =>p_rec.pmrpv_attribute14
 ,p_pmrpv_attribute15             =>p_rec.pmrpv_attribute15
 ,p_pmrpv_attribute16             =>p_rec.pmrpv_attribute16
 ,p_pmrpv_attribute17             =>p_rec.pmrpv_attribute17
 ,p_pmrpv_attribute18             =>p_rec.pmrpv_attribute18
 ,p_pmrpv_attribute19             =>p_rec.pmrpv_attribute19
 ,p_pmrpv_attribute20             =>p_rec.pmrpv_attribute20
 ,p_pmrpv_attribute21             =>p_rec.pmrpv_attribute21
 ,p_pmrpv_attribute22             =>p_rec.pmrpv_attribute22
 ,p_pmrpv_attribute23             =>p_rec.pmrpv_attribute23
 ,p_pmrpv_attribute24             =>p_rec.pmrpv_attribute24
 ,p_pmrpv_attribute25             =>p_rec.pmrpv_attribute25
 ,p_pmrpv_attribute26             =>p_rec.pmrpv_attribute26
 ,p_pmrpv_attribute27             =>p_rec.pmrpv_attribute27
 ,p_pmrpv_attribute28             =>p_rec.pmrpv_attribute28
 ,p_pmrpv_attribute29             =>p_rec.pmrpv_attribute29
 ,p_pmrpv_attribute30             =>p_rec.pmrpv_attribute30
 ,p_object_version_number         =>p_rec.object_version_number
 ,p_effective_date                =>p_effective_date
 ,p_datetrack_mode                =>p_datetrack_mode
 ,p_validation_start_date         =>p_validation_start_date
 ,p_validation_end_date           =>p_validation_end_date
 ,p_effective_end_date_o          =>ben_ppv_shd.g_old_rec.effective_end_date
 ,p_effective_start_date_o        =>ben_ppv_shd.g_old_rec.effective_start_date
 ,p_business_group_id_o           =>ben_ppv_shd.g_old_rec.business_group_id
 ,p_rndg_cd_o                     =>ben_ppv_shd.g_old_rec.rndg_cd
 ,p_to_dy_mo_num_o                =>ben_ppv_shd.g_old_rec.to_dy_mo_num
 ,p_from_dy_mo_num_o              =>ben_ppv_shd.g_old_rec.from_dy_mo_num
 ,p_pct_val_o                     =>ben_ppv_shd.g_old_rec.pct_val
 ,p_acty_base_rt_id_o             =>ben_ppv_shd.g_old_rec.acty_base_rt_id
 ,p_strt_r_stp_cvg_cd_o           =>ben_ppv_shd.g_old_rec.strt_r_stp_cvg_cd
 ,p_rndg_rl_o                     =>ben_ppv_shd.g_old_rec.rndg_rl
 ,p_prtl_mo_prortn_rl_o           =>ben_ppv_shd.g_old_rec.prtl_mo_prortn_rl
 ,p_actl_prem_id_o                =>ben_ppv_shd.g_old_rec.actl_prem_id
 ,p_cvg_amt_calc_mthd_id_o        =>ben_ppv_shd.g_old_rec.cvg_amt_calc_mthd_id
 ,p_num_days_month_o              =>ben_ppv_shd.g_old_rec.num_days_month
 ,p_prorate_by_day_to_mon_flag_o  =>ben_ppv_shd.g_old_rec.prorate_by_day_to_mon_flag
 ,p_pmrpv_attribute_category_o    =>ben_ppv_shd.g_old_rec.pmrpv_attribute_category
 ,p_pmrpv_attribute1_o            =>ben_ppv_shd.g_old_rec.pmrpv_attribute1
 ,p_pmrpv_attribute2_o            =>ben_ppv_shd.g_old_rec.pmrpv_attribute2
 ,p_pmrpv_attribute3_o            =>ben_ppv_shd.g_old_rec.pmrpv_attribute3
 ,p_pmrpv_attribute4_o            =>ben_ppv_shd.g_old_rec.pmrpv_attribute4
 ,p_pmrpv_attribute5_o            =>ben_ppv_shd.g_old_rec.pmrpv_attribute5
 ,p_pmrpv_attribute6_o            =>ben_ppv_shd.g_old_rec.pmrpv_attribute6
 ,p_pmrpv_attribute7_o            =>ben_ppv_shd.g_old_rec.pmrpv_attribute7
 ,p_pmrpv_attribute8_o            =>ben_ppv_shd.g_old_rec.pmrpv_attribute8
 ,p_pmrpv_attribute9_o            =>ben_ppv_shd.g_old_rec.pmrpv_attribute9
 ,p_pmrpv_attribute10_o           =>ben_ppv_shd.g_old_rec.pmrpv_attribute10
 ,p_pmrpv_attribute11_o           =>ben_ppv_shd.g_old_rec.pmrpv_attribute11
 ,p_pmrpv_attribute12_o           =>ben_ppv_shd.g_old_rec.pmrpv_attribute12
 ,p_pmrpv_attribute13_o           =>ben_ppv_shd.g_old_rec.pmrpv_attribute13
 ,p_pmrpv_attribute14_o           =>ben_ppv_shd.g_old_rec.pmrpv_attribute14
 ,p_pmrpv_attribute15_o           =>ben_ppv_shd.g_old_rec.pmrpv_attribute15
 ,p_pmrpv_attribute16_o           =>ben_ppv_shd.g_old_rec.pmrpv_attribute16
 ,p_pmrpv_attribute17_o           =>ben_ppv_shd.g_old_rec.pmrpv_attribute17
 ,p_pmrpv_attribute18_o           =>ben_ppv_shd.g_old_rec.pmrpv_attribute18
 ,p_pmrpv_attribute19_o           =>ben_ppv_shd.g_old_rec.pmrpv_attribute19
 ,p_pmrpv_attribute20_o           =>ben_ppv_shd.g_old_rec.pmrpv_attribute20
 ,p_pmrpv_attribute21_o           =>ben_ppv_shd.g_old_rec.pmrpv_attribute21
 ,p_pmrpv_attribute22_o           =>ben_ppv_shd.g_old_rec.pmrpv_attribute22
 ,p_pmrpv_attribute23_o           =>ben_ppv_shd.g_old_rec.pmrpv_attribute23
 ,p_pmrpv_attribute24_o           =>ben_ppv_shd.g_old_rec.pmrpv_attribute24
 ,p_pmrpv_attribute25_o           =>ben_ppv_shd.g_old_rec.pmrpv_attribute25
 ,p_pmrpv_attribute26_o           =>ben_ppv_shd.g_old_rec.pmrpv_attribute26
 ,p_pmrpv_attribute27_o           =>ben_ppv_shd.g_old_rec.pmrpv_attribute27
 ,p_pmrpv_attribute28_o           =>ben_ppv_shd.g_old_rec.pmrpv_attribute28
 ,p_pmrpv_attribute29_o           =>ben_ppv_shd.g_old_rec.pmrpv_attribute29
 ,p_pmrpv_attribute30_o           =>ben_ppv_shd.g_old_rec.pmrpv_attribute30
 ,p_object_version_number_o       =>ben_ppv_shd.g_old_rec.object_version_number
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'ben_prtl_mo_rt_prtn_val_f'
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
Procedure convert_defs(p_rec in out nocopy ben_ppv_shd.g_rec_type) is
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
    ben_ppv_shd.g_old_rec.business_group_id;
  End If;
  If (p_rec.rndg_cd = hr_api.g_varchar2) then
    p_rec.rndg_cd :=
    ben_ppv_shd.g_old_rec.rndg_cd;
  End If;
  If (p_rec.to_dy_mo_num = hr_api.g_number) then
    p_rec.to_dy_mo_num :=
    ben_ppv_shd.g_old_rec.to_dy_mo_num;
  End If;
  If (p_rec.from_dy_mo_num = hr_api.g_number) then
    p_rec.from_dy_mo_num :=
    ben_ppv_shd.g_old_rec.from_dy_mo_num;
  End If;
  If (p_rec.pct_val = hr_api.g_number) then
    p_rec.pct_val :=
    ben_ppv_shd.g_old_rec.pct_val;
  End If;
  If (p_rec.acty_base_rt_id = hr_api.g_number) then
    p_rec.acty_base_rt_id :=
    ben_ppv_shd.g_old_rec.acty_base_rt_id;
  End If;
  If (p_rec.strt_r_stp_cvg_cd = hr_api.g_varchar2) then
    p_rec.strt_r_stp_cvg_cd :=
    ben_ppv_shd.g_old_rec.strt_r_stp_cvg_cd;
  End If;
  If (p_rec.rndg_rl = hr_api.g_number) then
    p_rec.rndg_rl :=
    ben_ppv_shd.g_old_rec.rndg_rl;
  End If;
  If (p_rec.prtl_mo_prortn_rl = hr_api.g_number) then
    p_rec.prtl_mo_prortn_rl :=
    ben_ppv_shd.g_old_rec.prtl_mo_prortn_rl;
  End If;
  If (p_rec.actl_prem_id = hr_api.g_number) then
    p_rec.actl_prem_id :=
    ben_ppv_shd.g_old_rec.actl_prem_id;
  End If;
  If (p_rec.cvg_amt_calc_mthd_id = hr_api.g_number) then
    p_rec.cvg_amt_calc_mthd_id :=
    ben_ppv_shd.g_old_rec.cvg_amt_calc_mthd_id;
  End If;
  If (p_rec.num_days_month = hr_api.g_number) then
    p_rec.num_days_month :=
    ben_ppv_shd.g_old_rec.num_days_month;
  End If;
  If (p_rec.prorate_by_day_to_mon_flag = hr_api.g_varchar2) then
    p_rec.prorate_by_day_to_mon_flag :=
    ben_ppv_shd.g_old_rec.prorate_by_day_to_mon_flag;
  End If;
  If (p_rec.pmrpv_attribute_category = hr_api.g_varchar2) then
    p_rec.pmrpv_attribute_category :=
    ben_ppv_shd.g_old_rec.pmrpv_attribute_category;
  End If;
  If (p_rec.pmrpv_attribute1 = hr_api.g_varchar2) then
    p_rec.pmrpv_attribute1 :=
    ben_ppv_shd.g_old_rec.pmrpv_attribute1;
  End If;
  If (p_rec.pmrpv_attribute2 = hr_api.g_varchar2) then
    p_rec.pmrpv_attribute2 :=
    ben_ppv_shd.g_old_rec.pmrpv_attribute2;
  End If;
  If (p_rec.pmrpv_attribute3 = hr_api.g_varchar2) then
    p_rec.pmrpv_attribute3 :=
    ben_ppv_shd.g_old_rec.pmrpv_attribute3;
  End If;
  If (p_rec.pmrpv_attribute4 = hr_api.g_varchar2) then
    p_rec.pmrpv_attribute4 :=
    ben_ppv_shd.g_old_rec.pmrpv_attribute4;
  End If;
  If (p_rec.pmrpv_attribute5 = hr_api.g_varchar2) then
    p_rec.pmrpv_attribute5 :=
    ben_ppv_shd.g_old_rec.pmrpv_attribute5;
  End If;
  If (p_rec.pmrpv_attribute6 = hr_api.g_varchar2) then
    p_rec.pmrpv_attribute6 :=
    ben_ppv_shd.g_old_rec.pmrpv_attribute6;
  End If;
  If (p_rec.pmrpv_attribute7 = hr_api.g_varchar2) then
    p_rec.pmrpv_attribute7 :=
    ben_ppv_shd.g_old_rec.pmrpv_attribute7;
  End If;
  If (p_rec.pmrpv_attribute8 = hr_api.g_varchar2) then
    p_rec.pmrpv_attribute8 :=
    ben_ppv_shd.g_old_rec.pmrpv_attribute8;
  End If;
  If (p_rec.pmrpv_attribute9 = hr_api.g_varchar2) then
    p_rec.pmrpv_attribute9 :=
    ben_ppv_shd.g_old_rec.pmrpv_attribute9;
  End If;
  If (p_rec.pmrpv_attribute10 = hr_api.g_varchar2) then
    p_rec.pmrpv_attribute10 :=
    ben_ppv_shd.g_old_rec.pmrpv_attribute10;
  End If;
  If (p_rec.pmrpv_attribute11 = hr_api.g_varchar2) then
    p_rec.pmrpv_attribute11 :=
    ben_ppv_shd.g_old_rec.pmrpv_attribute11;
  End If;
  If (p_rec.pmrpv_attribute12 = hr_api.g_varchar2) then
    p_rec.pmrpv_attribute12 :=
    ben_ppv_shd.g_old_rec.pmrpv_attribute12;
  End If;
  If (p_rec.pmrpv_attribute13 = hr_api.g_varchar2) then
    p_rec.pmrpv_attribute13 :=
    ben_ppv_shd.g_old_rec.pmrpv_attribute13;
  End If;
  If (p_rec.pmrpv_attribute14 = hr_api.g_varchar2) then
    p_rec.pmrpv_attribute14 :=
    ben_ppv_shd.g_old_rec.pmrpv_attribute14;
  End If;
  If (p_rec.pmrpv_attribute15 = hr_api.g_varchar2) then
    p_rec.pmrpv_attribute15 :=
    ben_ppv_shd.g_old_rec.pmrpv_attribute15;
  End If;
  If (p_rec.pmrpv_attribute16 = hr_api.g_varchar2) then
    p_rec.pmrpv_attribute16 :=
    ben_ppv_shd.g_old_rec.pmrpv_attribute16;
  End If;
  If (p_rec.pmrpv_attribute17 = hr_api.g_varchar2) then
    p_rec.pmrpv_attribute17 :=
    ben_ppv_shd.g_old_rec.pmrpv_attribute17;
  End If;
  If (p_rec.pmrpv_attribute18 = hr_api.g_varchar2) then
    p_rec.pmrpv_attribute18 :=
    ben_ppv_shd.g_old_rec.pmrpv_attribute18;
  End If;
  If (p_rec.pmrpv_attribute19 = hr_api.g_varchar2) then
    p_rec.pmrpv_attribute19 :=
    ben_ppv_shd.g_old_rec.pmrpv_attribute19;
  End If;
  If (p_rec.pmrpv_attribute20 = hr_api.g_varchar2) then
    p_rec.pmrpv_attribute20 :=
    ben_ppv_shd.g_old_rec.pmrpv_attribute20;
  End If;
  If (p_rec.pmrpv_attribute21 = hr_api.g_varchar2) then
    p_rec.pmrpv_attribute21 :=
    ben_ppv_shd.g_old_rec.pmrpv_attribute21;
  End If;
  If (p_rec.pmrpv_attribute22 = hr_api.g_varchar2) then
    p_rec.pmrpv_attribute22 :=
    ben_ppv_shd.g_old_rec.pmrpv_attribute22;
  End If;
  If (p_rec.pmrpv_attribute23 = hr_api.g_varchar2) then
    p_rec.pmrpv_attribute23 :=
    ben_ppv_shd.g_old_rec.pmrpv_attribute23;
  End If;
  If (p_rec.pmrpv_attribute24 = hr_api.g_varchar2) then
    p_rec.pmrpv_attribute24 :=
    ben_ppv_shd.g_old_rec.pmrpv_attribute24;
  End If;
  If (p_rec.pmrpv_attribute25 = hr_api.g_varchar2) then
    p_rec.pmrpv_attribute25 :=
    ben_ppv_shd.g_old_rec.pmrpv_attribute25;
  End If;
  If (p_rec.pmrpv_attribute26 = hr_api.g_varchar2) then
    p_rec.pmrpv_attribute26 :=
    ben_ppv_shd.g_old_rec.pmrpv_attribute26;
  End If;
  If (p_rec.pmrpv_attribute27 = hr_api.g_varchar2) then
    p_rec.pmrpv_attribute27 :=
    ben_ppv_shd.g_old_rec.pmrpv_attribute27;
  End If;
  If (p_rec.pmrpv_attribute28 = hr_api.g_varchar2) then
    p_rec.pmrpv_attribute28 :=
    ben_ppv_shd.g_old_rec.pmrpv_attribute28;
  End If;
  If (p_rec.pmrpv_attribute29 = hr_api.g_varchar2) then
    p_rec.pmrpv_attribute29 :=
    ben_ppv_shd.g_old_rec.pmrpv_attribute29;
  End If;
  If (p_rec.pmrpv_attribute30 = hr_api.g_varchar2) then
    p_rec.pmrpv_attribute30 :=
    ben_ppv_shd.g_old_rec.pmrpv_attribute30;
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
  p_rec			in out nocopy 	ben_ppv_shd.g_rec_type,
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
  ben_ppv_shd.lck
	(p_effective_date	 => p_effective_date,
      	 p_datetrack_mode	 => p_datetrack_mode,
      	 p_prtl_mo_rt_prtn_val_id	 => p_rec.prtl_mo_rt_prtn_val_id,
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
  ben_ppv_bus.update_validate
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
  p_prtl_mo_rt_prtn_val_id       in number,
  p_effective_end_date           out nocopy date,
  p_effective_start_date         out nocopy date,
  p_business_group_id            in number           default hr_api.g_number,
  p_rndg_cd                      in varchar2         default hr_api.g_varchar2,
  p_to_dy_mo_num                 in number           default hr_api.g_number,
  p_from_dy_mo_num               in number           default hr_api.g_number,
  p_pct_val                      in number           default hr_api.g_number,
  p_acty_base_rt_id              in number           default hr_api.g_number,
  p_strt_r_stp_cvg_cd            in varchar2         default hr_api.g_varchar2,
  p_rndg_rl                      in number           default hr_api.g_number,
  p_prtl_mo_prortn_rl            in number           default hr_api.g_number,
  p_actl_prem_id                 in number           default hr_api.g_number,
  p_cvg_amt_calc_mthd_id         in number           default hr_api.g_number,
  p_num_days_month               in number,
  p_prorate_by_day_to_mon_flag   in varchar2,
  p_pmrpv_attribute_category     in varchar2         default hr_api.g_varchar2,
  p_pmrpv_attribute1             in varchar2         default hr_api.g_varchar2,
  p_pmrpv_attribute2             in varchar2         default hr_api.g_varchar2,
  p_pmrpv_attribute3             in varchar2         default hr_api.g_varchar2,
  p_pmrpv_attribute4             in varchar2         default hr_api.g_varchar2,
  p_pmrpv_attribute5             in varchar2         default hr_api.g_varchar2,
  p_pmrpv_attribute6             in varchar2         default hr_api.g_varchar2,
  p_pmrpv_attribute7             in varchar2         default hr_api.g_varchar2,
  p_pmrpv_attribute8             in varchar2         default hr_api.g_varchar2,
  p_pmrpv_attribute9             in varchar2         default hr_api.g_varchar2,
  p_pmrpv_attribute10            in varchar2         default hr_api.g_varchar2,
  p_pmrpv_attribute11            in varchar2         default hr_api.g_varchar2,
  p_pmrpv_attribute12            in varchar2         default hr_api.g_varchar2,
  p_pmrpv_attribute13            in varchar2         default hr_api.g_varchar2,
  p_pmrpv_attribute14            in varchar2         default hr_api.g_varchar2,
  p_pmrpv_attribute15            in varchar2         default hr_api.g_varchar2,
  p_pmrpv_attribute16            in varchar2         default hr_api.g_varchar2,
  p_pmrpv_attribute17            in varchar2         default hr_api.g_varchar2,
  p_pmrpv_attribute18            in varchar2         default hr_api.g_varchar2,
  p_pmrpv_attribute19            in varchar2         default hr_api.g_varchar2,
  p_pmrpv_attribute20            in varchar2         default hr_api.g_varchar2,
  p_pmrpv_attribute21            in varchar2         default hr_api.g_varchar2,
  p_pmrpv_attribute22            in varchar2         default hr_api.g_varchar2,
  p_pmrpv_attribute23            in varchar2         default hr_api.g_varchar2,
  p_pmrpv_attribute24            in varchar2         default hr_api.g_varchar2,
  p_pmrpv_attribute25            in varchar2         default hr_api.g_varchar2,
  p_pmrpv_attribute26            in varchar2         default hr_api.g_varchar2,
  p_pmrpv_attribute27            in varchar2         default hr_api.g_varchar2,
  p_pmrpv_attribute28            in varchar2         default hr_api.g_varchar2,
  p_pmrpv_attribute29            in varchar2         default hr_api.g_varchar2,
  p_pmrpv_attribute30            in varchar2         default hr_api.g_varchar2,
  p_object_version_number        in out nocopy number,
  p_effective_date		 in date,
  p_datetrack_mode		 in varchar2
  ) is
--
  l_rec		ben_ppv_shd.g_rec_type;
  l_proc	varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  ben_ppv_shd.convert_args
  (
  p_prtl_mo_rt_prtn_val_id,
  null,
  null,
  p_business_group_id,
  p_rndg_cd,
  p_to_dy_mo_num,
  p_from_dy_mo_num,
  p_pct_val,
  p_acty_base_rt_id,
  p_strt_r_stp_cvg_cd,
  p_rndg_rl,
  p_prtl_mo_prortn_rl,
  p_actl_prem_id,
  p_cvg_amt_calc_mthd_id,
  p_num_days_month   ,
  p_prorate_by_day_to_mon_flag,
  p_pmrpv_attribute_category,
  p_pmrpv_attribute1,
  p_pmrpv_attribute2,
  p_pmrpv_attribute3,
  p_pmrpv_attribute4,
  p_pmrpv_attribute5,
  p_pmrpv_attribute6,
  p_pmrpv_attribute7,
  p_pmrpv_attribute8,
  p_pmrpv_attribute9,
  p_pmrpv_attribute10,
  p_pmrpv_attribute11,
  p_pmrpv_attribute12,
  p_pmrpv_attribute13,
  p_pmrpv_attribute14,
  p_pmrpv_attribute15,
  p_pmrpv_attribute16,
  p_pmrpv_attribute17,
  p_pmrpv_attribute18,
  p_pmrpv_attribute19,
  p_pmrpv_attribute20,
  p_pmrpv_attribute21,
  p_pmrpv_attribute22,
  p_pmrpv_attribute23,
  p_pmrpv_attribute24,
  p_pmrpv_attribute25,
  p_pmrpv_attribute26,
  p_pmrpv_attribute27,
  p_pmrpv_attribute28,
  p_pmrpv_attribute29,
  p_pmrpv_attribute30,
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
end ben_ppv_upd;

/
