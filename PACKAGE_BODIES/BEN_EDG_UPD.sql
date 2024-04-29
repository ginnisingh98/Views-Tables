--------------------------------------------------------
--  DDL for Package Body BEN_EDG_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_EDG_UPD" as
/* $Header: beedgrhi.pkb 120.1 2006/02/28 01:54:21 rtagarra noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_edg_upd.';  -- Global package name
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
	(p_rec 			 in out nocopy ben_edg_shd.g_rec_type,
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
	  (p_base_table_name	=> 'ben_elig_dpnt_cvrd_othr_pgm_f',
	   p_base_key_column	=> 'elig_dpnt_cvrd_othr_pgm_id',
	   p_base_key_value	=> p_rec.elig_dpnt_cvrd_othr_pgm_id);
    --
    ben_edg_shd.g_api_dml := true;  -- Set the api dml status
    --
    -- Update the ben_elig_dpnt_cvrd_othr_pgm_f Row
    --
    update  ben_elig_dpnt_cvrd_othr_pgm_f
    set
        elig_dpnt_cvrd_othr_pgm_id      = p_rec.elig_dpnt_cvrd_othr_pgm_id,
    excld_flag                      = p_rec.excld_flag,
    only_pls_subj_cobra_flag        = p_rec.only_pls_subj_cobra_flag,
    enrl_det_dt_cd                  = p_rec.enrl_det_dt_cd,
    ordr_num                        = p_rec.ordr_num,
    pgm_id                          = p_rec.pgm_id,
    eligy_prfl_id                   = p_rec.eligy_prfl_id,
    business_group_id               = p_rec.business_group_id,
    edg_attribute_category          = p_rec.edg_attribute_category,
    edg_attribute1                  = p_rec.edg_attribute1,
    edg_attribute2                  = p_rec.edg_attribute2,
    edg_attribute3                  = p_rec.edg_attribute3,
    edg_attribute4                  = p_rec.edg_attribute4,
    edg_attribute5                  = p_rec.edg_attribute5,
    edg_attribute6                  = p_rec.edg_attribute6,
    edg_attribute7                  = p_rec.edg_attribute7,
    edg_attribute8                  = p_rec.edg_attribute8,
    edg_attribute9                  = p_rec.edg_attribute9,
    edg_attribute10                 = p_rec.edg_attribute10,
    edg_attribute11                 = p_rec.edg_attribute11,
    edg_attribute12                 = p_rec.edg_attribute12,
    edg_attribute13                 = p_rec.edg_attribute13,
    edg_attribute14                 = p_rec.edg_attribute14,
    edg_attribute15                 = p_rec.edg_attribute15,
    edg_attribute16                 = p_rec.edg_attribute16,
    edg_attribute17                 = p_rec.edg_attribute17,
    edg_attribute18                 = p_rec.edg_attribute18,
    edg_attribute19                 = p_rec.edg_attribute19,
    edg_attribute20                 = p_rec.edg_attribute20,
    edg_attribute21                 = p_rec.edg_attribute21,
    edg_attribute22                 = p_rec.edg_attribute22,
    edg_attribute23                 = p_rec.edg_attribute23,
    edg_attribute24                 = p_rec.edg_attribute24,
    edg_attribute25                 = p_rec.edg_attribute25,
    edg_attribute26                 = p_rec.edg_attribute26,
    edg_attribute27                 = p_rec.edg_attribute27,
    edg_attribute28                 = p_rec.edg_attribute28,
    edg_attribute29                 = p_rec.edg_attribute29,
    edg_attribute30                 = p_rec.edg_attribute30,
    object_version_number           = p_rec.object_version_number
    where   elig_dpnt_cvrd_othr_pgm_id = p_rec.elig_dpnt_cvrd_othr_pgm_id
    and     effective_start_date = p_validation_start_date
    and     effective_end_date   = p_validation_end_date;
    --
    ben_edg_shd.g_api_dml := false;   -- Unset the api dml status
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
    ben_edg_shd.g_api_dml := false;   -- Unset the api dml status
    ben_edg_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    ben_edg_shd.g_api_dml := false;   -- Unset the api dml status
    ben_edg_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    ben_edg_shd.g_api_dml := false;   -- Unset the api dml status
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
	(p_rec 			 in out nocopy ben_edg_shd.g_rec_type,
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
	(p_rec 			 in out nocopy ben_edg_shd.g_rec_type,
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
    ben_edg_shd.upd_effective_end_date
     (p_effective_date	       => p_effective_date,
      p_base_key_value	       => p_rec.elig_dpnt_cvrd_othr_pgm_id,
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
      ben_edg_del.delete_dml
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
    ben_edg_ins.insert_dml
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
	(p_rec 			 in out nocopy ben_edg_shd.g_rec_type,
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
	(p_rec 			 in ben_edg_shd.g_rec_type,
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
    ben_edg_rku.after_update
      (
  p_elig_dpnt_cvrd_othr_pgm_id    =>p_rec.elig_dpnt_cvrd_othr_pgm_id
 ,p_effective_start_date          =>p_rec.effective_start_date
 ,p_effective_end_date            =>p_rec.effective_end_date
 ,p_excld_flag                    =>p_rec.excld_flag
 ,p_only_pls_subj_cobra_flag      =>p_rec.only_pls_subj_cobra_flag
 ,p_enrl_det_dt_cd                =>p_rec.enrl_det_dt_cd
 ,p_ordr_num                      =>p_rec.ordr_num
 ,p_pgm_id                        =>p_rec.pgm_id
 ,p_eligy_prfl_id                 =>p_rec.eligy_prfl_id
 ,p_business_group_id             =>p_rec.business_group_id
 ,p_edg_attribute_category        =>p_rec.edg_attribute_category
 ,p_edg_attribute1                =>p_rec.edg_attribute1
 ,p_edg_attribute2                =>p_rec.edg_attribute2
 ,p_edg_attribute3                =>p_rec.edg_attribute3
 ,p_edg_attribute4                =>p_rec.edg_attribute4
 ,p_edg_attribute5                =>p_rec.edg_attribute5
 ,p_edg_attribute6                =>p_rec.edg_attribute6
 ,p_edg_attribute7                =>p_rec.edg_attribute7
 ,p_edg_attribute8                =>p_rec.edg_attribute8
 ,p_edg_attribute9                =>p_rec.edg_attribute9
 ,p_edg_attribute10               =>p_rec.edg_attribute10
 ,p_edg_attribute11               =>p_rec.edg_attribute11
 ,p_edg_attribute12               =>p_rec.edg_attribute12
 ,p_edg_attribute13               =>p_rec.edg_attribute13
 ,p_edg_attribute14               =>p_rec.edg_attribute14
 ,p_edg_attribute15               =>p_rec.edg_attribute15
 ,p_edg_attribute16               =>p_rec.edg_attribute16
 ,p_edg_attribute17               =>p_rec.edg_attribute17
 ,p_edg_attribute18               =>p_rec.edg_attribute18
 ,p_edg_attribute19               =>p_rec.edg_attribute19
 ,p_edg_attribute20               =>p_rec.edg_attribute20
 ,p_edg_attribute21               =>p_rec.edg_attribute21
 ,p_edg_attribute22               =>p_rec.edg_attribute22
 ,p_edg_attribute23               =>p_rec.edg_attribute23
 ,p_edg_attribute24               =>p_rec.edg_attribute24
 ,p_edg_attribute25               =>p_rec.edg_attribute25
 ,p_edg_attribute26               =>p_rec.edg_attribute26
 ,p_edg_attribute27               =>p_rec.edg_attribute27
 ,p_edg_attribute28               =>p_rec.edg_attribute28
 ,p_edg_attribute29               =>p_rec.edg_attribute29
 ,p_edg_attribute30               =>p_rec.edg_attribute30
 ,p_object_version_number         =>p_rec.object_version_number
 ,p_effective_date                =>p_effective_date
 ,p_datetrack_mode                =>p_datetrack_mode
 ,p_validation_start_date         =>p_validation_start_date
 ,p_validation_end_date           =>p_validation_end_date
 ,p_effective_start_date_o        =>ben_edg_shd.g_old_rec.effective_start_date
 ,p_effective_end_date_o          =>ben_edg_shd.g_old_rec.effective_end_date
 ,p_excld_flag_o                  =>ben_edg_shd.g_old_rec.excld_flag
 ,p_only_pls_subj_cobra_flag_o    =>ben_edg_shd.g_old_rec.only_pls_subj_cobra_flag
 ,p_enrl_det_dt_cd_o              =>ben_edg_shd.g_old_rec.enrl_det_dt_cd
 ,p_ordr_num_o                    =>ben_edg_shd.g_old_rec.ordr_num
 ,p_pgm_id_o                      =>ben_edg_shd.g_old_rec.pgm_id
 ,p_eligy_prfl_id_o               =>ben_edg_shd.g_old_rec.eligy_prfl_id
 ,p_business_group_id_o           =>ben_edg_shd.g_old_rec.business_group_id
 ,p_edg_attribute_category_o      =>ben_edg_shd.g_old_rec.edg_attribute_category
 ,p_edg_attribute1_o              =>ben_edg_shd.g_old_rec.edg_attribute1
 ,p_edg_attribute2_o              =>ben_edg_shd.g_old_rec.edg_attribute2
 ,p_edg_attribute3_o              =>ben_edg_shd.g_old_rec.edg_attribute3
 ,p_edg_attribute4_o              =>ben_edg_shd.g_old_rec.edg_attribute4
 ,p_edg_attribute5_o              =>ben_edg_shd.g_old_rec.edg_attribute5
 ,p_edg_attribute6_o              =>ben_edg_shd.g_old_rec.edg_attribute6
 ,p_edg_attribute7_o              =>ben_edg_shd.g_old_rec.edg_attribute7
 ,p_edg_attribute8_o              =>ben_edg_shd.g_old_rec.edg_attribute8
 ,p_edg_attribute9_o              =>ben_edg_shd.g_old_rec.edg_attribute9
 ,p_edg_attribute10_o             =>ben_edg_shd.g_old_rec.edg_attribute10
 ,p_edg_attribute11_o             =>ben_edg_shd.g_old_rec.edg_attribute11
 ,p_edg_attribute12_o             =>ben_edg_shd.g_old_rec.edg_attribute12
 ,p_edg_attribute13_o             =>ben_edg_shd.g_old_rec.edg_attribute13
 ,p_edg_attribute14_o             =>ben_edg_shd.g_old_rec.edg_attribute14
 ,p_edg_attribute15_o             =>ben_edg_shd.g_old_rec.edg_attribute15
 ,p_edg_attribute16_o             =>ben_edg_shd.g_old_rec.edg_attribute16
 ,p_edg_attribute17_o             =>ben_edg_shd.g_old_rec.edg_attribute17
 ,p_edg_attribute18_o             =>ben_edg_shd.g_old_rec.edg_attribute18
 ,p_edg_attribute19_o             =>ben_edg_shd.g_old_rec.edg_attribute19
 ,p_edg_attribute20_o             =>ben_edg_shd.g_old_rec.edg_attribute20
 ,p_edg_attribute21_o             =>ben_edg_shd.g_old_rec.edg_attribute21
 ,p_edg_attribute22_o             =>ben_edg_shd.g_old_rec.edg_attribute22
 ,p_edg_attribute23_o             =>ben_edg_shd.g_old_rec.edg_attribute23
 ,p_edg_attribute24_o             =>ben_edg_shd.g_old_rec.edg_attribute24
 ,p_edg_attribute25_o             =>ben_edg_shd.g_old_rec.edg_attribute25
 ,p_edg_attribute26_o             =>ben_edg_shd.g_old_rec.edg_attribute26
 ,p_edg_attribute27_o             =>ben_edg_shd.g_old_rec.edg_attribute27
 ,p_edg_attribute28_o             =>ben_edg_shd.g_old_rec.edg_attribute28
 ,p_edg_attribute29_o             =>ben_edg_shd.g_old_rec.edg_attribute29
 ,p_edg_attribute30_o             =>ben_edg_shd.g_old_rec.edg_attribute30
 ,p_object_version_number_o       =>ben_edg_shd.g_old_rec.object_version_number
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'ben_elig_dpnt_cvrd_othr_pgm_f'
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
Procedure convert_defs(p_rec in out nocopy ben_edg_shd.g_rec_type) is
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
  If (p_rec.excld_flag = hr_api.g_varchar2) then
    p_rec.excld_flag :=
    ben_edg_shd.g_old_rec.excld_flag;
  End If;
  If (p_rec.only_pls_subj_cobra_flag = hr_api.g_varchar2) then
    p_rec.only_pls_subj_cobra_flag :=
    ben_edg_shd.g_old_rec.only_pls_subj_cobra_flag;
  End If;
  If (p_rec.enrl_det_dt_cd = hr_api.g_varchar2) then
    p_rec.enrl_det_dt_cd :=
    ben_edg_shd.g_old_rec.enrl_det_dt_cd;
  End If;
  If (p_rec.ordr_num = hr_api.g_number) then
    p_rec.ordr_num :=
    ben_edg_shd.g_old_rec.ordr_num;
  End If;
  If (p_rec.pgm_id = hr_api.g_number) then
    p_rec.pgm_id :=
    ben_edg_shd.g_old_rec.pgm_id;
  End If;
  If (p_rec.eligy_prfl_id = hr_api.g_number) then
    p_rec.eligy_prfl_id :=
    ben_edg_shd.g_old_rec.eligy_prfl_id;
  End If;
  If (p_rec.business_group_id = hr_api.g_number) then
    p_rec.business_group_id :=
    ben_edg_shd.g_old_rec.business_group_id;
  End If;
  If (p_rec.edg_attribute_category = hr_api.g_varchar2) then
    p_rec.edg_attribute_category :=
    ben_edg_shd.g_old_rec.edg_attribute_category;
  End If;
  If (p_rec.edg_attribute1 = hr_api.g_varchar2) then
    p_rec.edg_attribute1 :=
    ben_edg_shd.g_old_rec.edg_attribute1;
  End If;
  If (p_rec.edg_attribute2 = hr_api.g_varchar2) then
    p_rec.edg_attribute2 :=
    ben_edg_shd.g_old_rec.edg_attribute2;
  End If;
  If (p_rec.edg_attribute3 = hr_api.g_varchar2) then
    p_rec.edg_attribute3 :=
    ben_edg_shd.g_old_rec.edg_attribute3;
  End If;
  If (p_rec.edg_attribute4 = hr_api.g_varchar2) then
    p_rec.edg_attribute4 :=
    ben_edg_shd.g_old_rec.edg_attribute4;
  End If;
  If (p_rec.edg_attribute5 = hr_api.g_varchar2) then
    p_rec.edg_attribute5 :=
    ben_edg_shd.g_old_rec.edg_attribute5;
  End If;
  If (p_rec.edg_attribute6 = hr_api.g_varchar2) then
    p_rec.edg_attribute6 :=
    ben_edg_shd.g_old_rec.edg_attribute6;
  End If;
  If (p_rec.edg_attribute7 = hr_api.g_varchar2) then
    p_rec.edg_attribute7 :=
    ben_edg_shd.g_old_rec.edg_attribute7;
  End If;
  If (p_rec.edg_attribute8 = hr_api.g_varchar2) then
    p_rec.edg_attribute8 :=
    ben_edg_shd.g_old_rec.edg_attribute8;
  End If;
  If (p_rec.edg_attribute9 = hr_api.g_varchar2) then
    p_rec.edg_attribute9 :=
    ben_edg_shd.g_old_rec.edg_attribute9;
  End If;
  If (p_rec.edg_attribute10 = hr_api.g_varchar2) then
    p_rec.edg_attribute10 :=
    ben_edg_shd.g_old_rec.edg_attribute10;
  End If;
  If (p_rec.edg_attribute11 = hr_api.g_varchar2) then
    p_rec.edg_attribute11 :=
    ben_edg_shd.g_old_rec.edg_attribute11;
  End If;
  If (p_rec.edg_attribute12 = hr_api.g_varchar2) then
    p_rec.edg_attribute12 :=
    ben_edg_shd.g_old_rec.edg_attribute12;
  End If;
  If (p_rec.edg_attribute13 = hr_api.g_varchar2) then
    p_rec.edg_attribute13 :=
    ben_edg_shd.g_old_rec.edg_attribute13;
  End If;
  If (p_rec.edg_attribute14 = hr_api.g_varchar2) then
    p_rec.edg_attribute14 :=
    ben_edg_shd.g_old_rec.edg_attribute14;
  End If;
  If (p_rec.edg_attribute15 = hr_api.g_varchar2) then
    p_rec.edg_attribute15 :=
    ben_edg_shd.g_old_rec.edg_attribute15;
  End If;
  If (p_rec.edg_attribute16 = hr_api.g_varchar2) then
    p_rec.edg_attribute16 :=
    ben_edg_shd.g_old_rec.edg_attribute16;
  End If;
  If (p_rec.edg_attribute17 = hr_api.g_varchar2) then
    p_rec.edg_attribute17 :=
    ben_edg_shd.g_old_rec.edg_attribute17;
  End If;
  If (p_rec.edg_attribute18 = hr_api.g_varchar2) then
    p_rec.edg_attribute18 :=
    ben_edg_shd.g_old_rec.edg_attribute18;
  End If;
  If (p_rec.edg_attribute19 = hr_api.g_varchar2) then
    p_rec.edg_attribute19 :=
    ben_edg_shd.g_old_rec.edg_attribute19;
  End If;
  If (p_rec.edg_attribute20 = hr_api.g_varchar2) then
    p_rec.edg_attribute20 :=
    ben_edg_shd.g_old_rec.edg_attribute20;
  End If;
  If (p_rec.edg_attribute21 = hr_api.g_varchar2) then
    p_rec.edg_attribute21 :=
    ben_edg_shd.g_old_rec.edg_attribute21;
  End If;
  If (p_rec.edg_attribute22 = hr_api.g_varchar2) then
    p_rec.edg_attribute22 :=
    ben_edg_shd.g_old_rec.edg_attribute22;
  End If;
  If (p_rec.edg_attribute23 = hr_api.g_varchar2) then
    p_rec.edg_attribute23 :=
    ben_edg_shd.g_old_rec.edg_attribute23;
  End If;
  If (p_rec.edg_attribute24 = hr_api.g_varchar2) then
    p_rec.edg_attribute24 :=
    ben_edg_shd.g_old_rec.edg_attribute24;
  End If;
  If (p_rec.edg_attribute25 = hr_api.g_varchar2) then
    p_rec.edg_attribute25 :=
    ben_edg_shd.g_old_rec.edg_attribute25;
  End If;
  If (p_rec.edg_attribute26 = hr_api.g_varchar2) then
    p_rec.edg_attribute26 :=
    ben_edg_shd.g_old_rec.edg_attribute26;
  End If;
  If (p_rec.edg_attribute27 = hr_api.g_varchar2) then
    p_rec.edg_attribute27 :=
    ben_edg_shd.g_old_rec.edg_attribute27;
  End If;
  If (p_rec.edg_attribute28 = hr_api.g_varchar2) then
    p_rec.edg_attribute28 :=
    ben_edg_shd.g_old_rec.edg_attribute28;
  End If;
  If (p_rec.edg_attribute29 = hr_api.g_varchar2) then
    p_rec.edg_attribute29 :=
    ben_edg_shd.g_old_rec.edg_attribute29;
  End If;
  If (p_rec.edg_attribute30 = hr_api.g_varchar2) then
    p_rec.edg_attribute30 :=
    ben_edg_shd.g_old_rec.edg_attribute30;
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
  p_rec			in out nocopy 	ben_edg_shd.g_rec_type,
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
  ben_edg_shd.lck
	(p_effective_date	 => p_effective_date,
      	 p_datetrack_mode	 => p_datetrack_mode,
      	 p_elig_dpnt_cvrd_othr_pgm_id	 => p_rec.elig_dpnt_cvrd_othr_pgm_id,
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
  ben_edg_bus.update_validate
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
  p_elig_dpnt_cvrd_othr_pgm_id   in number,
  p_effective_start_date         out nocopy date,
  p_effective_end_date           out nocopy date,
  p_excld_flag                   in varchar2         default hr_api.g_varchar2,
  p_only_pls_subj_cobra_flag     in varchar2         default hr_api.g_varchar2,
  p_enrl_det_dt_cd               in varchar2         default hr_api.g_varchar2,
  p_ordr_num                     in number           default hr_api.g_number,
  p_pgm_id                       in number           default hr_api.g_number,
  p_eligy_prfl_id                in number           default hr_api.g_number,
  p_business_group_id            in number           default hr_api.g_number,
  p_edg_attribute_category       in varchar2         default hr_api.g_varchar2,
  p_edg_attribute1               in varchar2         default hr_api.g_varchar2,
  p_edg_attribute2               in varchar2         default hr_api.g_varchar2,
  p_edg_attribute3               in varchar2         default hr_api.g_varchar2,
  p_edg_attribute4               in varchar2         default hr_api.g_varchar2,
  p_edg_attribute5               in varchar2         default hr_api.g_varchar2,
  p_edg_attribute6               in varchar2         default hr_api.g_varchar2,
  p_edg_attribute7               in varchar2         default hr_api.g_varchar2,
  p_edg_attribute8               in varchar2         default hr_api.g_varchar2,
  p_edg_attribute9               in varchar2         default hr_api.g_varchar2,
  p_edg_attribute10              in varchar2         default hr_api.g_varchar2,
  p_edg_attribute11              in varchar2         default hr_api.g_varchar2,
  p_edg_attribute12              in varchar2         default hr_api.g_varchar2,
  p_edg_attribute13              in varchar2         default hr_api.g_varchar2,
  p_edg_attribute14              in varchar2         default hr_api.g_varchar2,
  p_edg_attribute15              in varchar2         default hr_api.g_varchar2,
  p_edg_attribute16              in varchar2         default hr_api.g_varchar2,
  p_edg_attribute17              in varchar2         default hr_api.g_varchar2,
  p_edg_attribute18              in varchar2         default hr_api.g_varchar2,
  p_edg_attribute19              in varchar2         default hr_api.g_varchar2,
  p_edg_attribute20              in varchar2         default hr_api.g_varchar2,
  p_edg_attribute21              in varchar2         default hr_api.g_varchar2,
  p_edg_attribute22              in varchar2         default hr_api.g_varchar2,
  p_edg_attribute23              in varchar2         default hr_api.g_varchar2,
  p_edg_attribute24              in varchar2         default hr_api.g_varchar2,
  p_edg_attribute25              in varchar2         default hr_api.g_varchar2,
  p_edg_attribute26              in varchar2         default hr_api.g_varchar2,
  p_edg_attribute27              in varchar2         default hr_api.g_varchar2,
  p_edg_attribute28              in varchar2         default hr_api.g_varchar2,
  p_edg_attribute29              in varchar2         default hr_api.g_varchar2,
  p_edg_attribute30              in varchar2         default hr_api.g_varchar2,
  p_object_version_number        in out nocopy number,
  p_effective_date		 in date,
  p_datetrack_mode		 in varchar2
  ) is
--
  l_rec		ben_edg_shd.g_rec_type;
  l_proc	varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  ben_edg_shd.convert_args
  (
  p_elig_dpnt_cvrd_othr_pgm_id,
  null,
  null,
  p_excld_flag,
  p_only_pls_subj_cobra_flag,
  p_enrl_det_dt_cd,
  p_ordr_num,
  p_pgm_id,
  p_eligy_prfl_id,
  p_business_group_id,
  p_edg_attribute_category,
  p_edg_attribute1,
  p_edg_attribute2,
  p_edg_attribute3,
  p_edg_attribute4,
  p_edg_attribute5,
  p_edg_attribute6,
  p_edg_attribute7,
  p_edg_attribute8,
  p_edg_attribute9,
  p_edg_attribute10,
  p_edg_attribute11,
  p_edg_attribute12,
  p_edg_attribute13,
  p_edg_attribute14,
  p_edg_attribute15,
  p_edg_attribute16,
  p_edg_attribute17,
  p_edg_attribute18,
  p_edg_attribute19,
  p_edg_attribute20,
  p_edg_attribute21,
  p_edg_attribute22,
  p_edg_attribute23,
  p_edg_attribute24,
  p_edg_attribute25,
  p_edg_attribute26,
  p_edg_attribute27,
  p_edg_attribute28,
  p_edg_attribute29,
  p_edg_attribute30,
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
end ben_edg_upd;

/
