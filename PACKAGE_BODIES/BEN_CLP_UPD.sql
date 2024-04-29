--------------------------------------------------------
--  DDL for Package Body BEN_CLP_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_CLP_UPD" as
/* $Header: beclprhi.pkb 120.0.12010000.2 2008/08/05 14:17:49 ubhat ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_clp_upd.';  -- Global package name
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
	(p_rec 			 in out nocopy ben_clp_shd.g_rec_type,
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
	  (p_base_table_name	=> 'ben_clpse_lf_evt_f',
	   p_base_key_column	=> 'clpse_lf_evt_id',
	   p_base_key_value	=> p_rec.clpse_lf_evt_id);
    --
    ben_clp_shd.g_api_dml := true;  -- Set the api dml status
    --
    -- Update the ben_clpse_lf_evt_f Row
    --
    update  ben_clpse_lf_evt_f
    set
    clpse_lf_evt_id                 = p_rec.clpse_lf_evt_id,
    business_group_id               = p_rec.business_group_id,
    seq                             = p_rec.seq,
    ler1_id                         = p_rec.ler1_id,
    bool1_cd                        = p_rec.bool1_cd,
    ler2_id                         = p_rec.ler2_id,
    bool2_cd                        = p_rec.bool2_cd,
    ler3_id                         = p_rec.ler3_id,
    bool3_cd                        = p_rec.bool3_cd,
    ler4_id                         = p_rec.ler4_id,
    bool4_cd                        = p_rec.bool4_cd,
    ler5_id                         = p_rec.ler5_id,
    bool5_cd                        = p_rec.bool5_cd,
    ler6_id                         = p_rec.ler6_id,
    bool6_cd                        = p_rec.bool6_cd,
    ler7_id                         = p_rec.ler7_id,
    bool7_cd                        = p_rec.bool7_cd,
    ler8_id                         = p_rec.ler8_id,
    bool8_cd                        = p_rec.bool8_cd,
    ler9_id                         = p_rec.ler9_id,
    bool9_cd                        = p_rec.bool9_cd,
    ler10_id                        = p_rec.ler10_id,
    eval_cd                         = p_rec.eval_cd,
    eval_rl                         = p_rec.eval_rl,
    tlrnc_dys_num                   = p_rec.tlrnc_dys_num,
    eval_ler_id                     = p_rec.eval_ler_id,
    eval_ler_det_cd                 = p_rec.eval_ler_det_cd,
    eval_ler_det_rl                 = p_rec.eval_ler_det_rl,
    clp_attribute_category          = p_rec.clp_attribute_category,
    clp_attribute1                  = p_rec.clp_attribute1,
    clp_attribute2                  = p_rec.clp_attribute2,
    clp_attribute3                  = p_rec.clp_attribute3,
    clp_attribute4                  = p_rec.clp_attribute4,
    clp_attribute5                  = p_rec.clp_attribute5,
    clp_attribute6                  = p_rec.clp_attribute6,
    clp_attribute7                  = p_rec.clp_attribute7,
    clp_attribute8                  = p_rec.clp_attribute8,
    clp_attribute9                  = p_rec.clp_attribute9,
    clp_attribute10                 = p_rec.clp_attribute10,
    clp_attribute11                 = p_rec.clp_attribute11,
    clp_attribute12                 = p_rec.clp_attribute12,
    clp_attribute13                 = p_rec.clp_attribute13,
    clp_attribute14                 = p_rec.clp_attribute14,
    clp_attribute15                 = p_rec.clp_attribute15,
    clp_attribute16                 = p_rec.clp_attribute16,
    clp_attribute17                 = p_rec.clp_attribute17,
    clp_attribute18                 = p_rec.clp_attribute18,
    clp_attribute19                 = p_rec.clp_attribute19,
    clp_attribute20                 = p_rec.clp_attribute20,
    clp_attribute21                 = p_rec.clp_attribute21,
    clp_attribute22                 = p_rec.clp_attribute22,
    clp_attribute23                 = p_rec.clp_attribute23,
    clp_attribute24                 = p_rec.clp_attribute24,
    clp_attribute25                 = p_rec.clp_attribute25,
    clp_attribute26                 = p_rec.clp_attribute26,
    clp_attribute27                 = p_rec.clp_attribute27,
    clp_attribute28                 = p_rec.clp_attribute28,
    clp_attribute29                 = p_rec.clp_attribute29,
    clp_attribute30                 = p_rec.clp_attribute30,
    object_version_number           = p_rec.object_version_number
    where   clpse_lf_evt_id = p_rec.clpse_lf_evt_id
    and     effective_start_date = p_validation_start_date
    and     effective_end_date   = p_validation_end_date;
    --
    ben_clp_shd.g_api_dml := false;   -- Unset the api dml status
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
    ben_clp_shd.g_api_dml := false;   -- Unset the api dml status
    ben_clp_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    ben_clp_shd.g_api_dml := false;   -- Unset the api dml status
    ben_clp_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    ben_clp_shd.g_api_dml := false;   -- Unset the api dml status
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
	(p_rec 			 in out nocopy ben_clp_shd.g_rec_type,
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
	(p_rec 			 in out nocopy ben_clp_shd.g_rec_type,
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
    ben_clp_shd.upd_effective_end_date
     (p_effective_date	       => p_effective_date,
      p_base_key_value	       => p_rec.clpse_lf_evt_id,
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
      ben_clp_del.delete_dml
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
    ben_clp_ins.insert_dml
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
	(p_rec 			 in out nocopy ben_clp_shd.g_rec_type,
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
	(p_rec 			 in ben_clp_shd.g_rec_type,
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
    ben_clp_rku.after_update
      (p_clpse_lf_evt_id                => p_rec.clpse_lf_evt_id
      ,p_effective_start_date           => p_rec.effective_start_date
      ,p_effective_end_date             => p_rec.effective_end_date
      ,p_business_group_id              => p_rec.business_group_id
      ,p_seq                            => p_rec.seq
      ,p_ler1_id                        => p_rec.ler1_id
      ,p_bool1_cd                       => p_rec.bool1_cd
      ,p_ler2_id                        => p_rec.ler2_id
      ,p_bool2_cd                       => p_rec.bool2_cd
      ,p_ler3_id                        => p_rec.ler3_id
      ,p_bool3_cd                       => p_rec.bool3_cd
      ,p_ler4_id                        => p_rec.ler4_id
      ,p_bool4_cd                       => p_rec.bool4_cd
      ,p_ler5_id                        => p_rec.ler5_id
      ,p_bool5_cd                       => p_rec.bool5_cd
      ,p_ler6_id                        => p_rec.ler6_id
      ,p_bool6_cd                       => p_rec.bool6_cd
      ,p_ler7_id                        => p_rec.ler7_id
      ,p_bool7_cd                       => p_rec.bool7_cd
      ,p_ler8_id                        => p_rec.ler8_id
      ,p_bool8_cd                       => p_rec.bool8_cd
      ,p_ler9_id                        => p_rec.ler9_id
      ,p_bool9_cd                       => p_rec.bool9_cd
      ,p_ler10_id                       => p_rec.ler10_id
      ,p_eval_cd                        => p_rec.eval_cd
      ,p_eval_rl                        => p_rec.eval_rl
      ,p_tlrnc_dys_num                  => p_Rec.tlrnc_dys_num
      ,p_eval_ler_id                    => p_rec.eval_ler_id
      ,p_eval_ler_det_cd                => p_rec.eval_ler_det_cd
      ,p_eval_ler_det_rl                => p_rec.eval_ler_det_rl
      ,p_clp_attribute_category         => p_rec.clp_attribute_category
      ,p_clp_attribute1                 => p_rec.clp_attribute1
      ,p_clp_attribute2                 => p_rec.clp_attribute2
      ,p_clp_attribute3                 => p_rec.clp_attribute3
      ,p_clp_attribute4                 => p_rec.clp_attribute4
      ,p_clp_attribute5                 => p_rec.clp_attribute5
      ,p_clp_attribute6                 => p_rec.clp_attribute6
      ,p_clp_attribute7                 => p_rec.clp_attribute7
      ,p_clp_attribute8                 => p_rec.clp_attribute8
      ,p_clp_attribute9                 => p_rec.clp_attribute9
      ,p_clp_attribute10                => p_rec.clp_attribute10
      ,p_clp_attribute11                => p_rec.clp_attribute11
      ,p_clp_attribute12                => p_rec.clp_attribute12
      ,p_clp_attribute13                => p_rec.clp_attribute13
      ,p_clp_attribute14                => p_rec.clp_attribute14
      ,p_clp_attribute15                => p_rec.clp_attribute15
      ,p_clp_attribute16                => p_rec.clp_attribute16
      ,p_clp_attribute17                => p_rec.clp_attribute17
      ,p_clp_attribute18                => p_rec.clp_attribute18
      ,p_clp_attribute19                => p_rec.clp_attribute19
      ,p_clp_attribute20                => p_rec.clp_attribute20
      ,p_clp_attribute21                => p_rec.clp_attribute21
      ,p_clp_attribute22                => p_rec.clp_attribute22
      ,p_clp_attribute23                => p_rec.clp_attribute23
      ,p_clp_attribute24                => p_rec.clp_attribute24
      ,p_clp_attribute25                => p_rec.clp_attribute25
      ,p_clp_attribute26                => p_rec.clp_attribute26
      ,p_clp_attribute27                => p_rec.clp_attribute27
      ,p_clp_attribute28                => p_rec.clp_attribute28
      ,p_clp_attribute29                => p_rec.clp_attribute29
      ,p_clp_attribute30                => p_rec.clp_attribute30
      ,p_object_version_number          => p_rec.object_version_number
      ,p_effective_date                 => p_effective_date
      ,p_datetrack_mode                 => p_datetrack_mode
      ,p_validation_start_date          => p_validation_start_date
      ,p_validation_end_date            => p_validation_end_date
      ,p_effective_start_date_o         => ben_clp_shd.g_old_rec.effective_start_date
      ,p_effective_end_date_o           => ben_clp_shd.g_old_rec.effective_end_date
      ,p_business_group_id_o            => ben_clp_shd.g_old_rec.business_group_id
      ,p_seq_o                          => ben_clp_shd.g_old_rec.seq
      ,p_ler1_id_o                      => ben_clp_shd.g_old_rec.ler1_id
      ,p_bool1_cd_o                     => ben_clp_shd.g_old_rec.bool1_cd
      ,p_ler2_id_o                      => ben_clp_shd.g_old_rec.ler2_id
      ,p_bool2_cd_o                     => ben_clp_shd.g_old_rec.bool2_cd
      ,p_ler3_id_o                      => ben_clp_shd.g_old_rec.ler3_id
      ,p_bool3_cd_o                     => ben_clp_shd.g_old_rec.bool3_cd
      ,p_ler4_id_o                      => ben_clp_shd.g_old_rec.ler4_id
      ,p_bool4_cd_o                     => ben_clp_shd.g_old_rec.bool4_cd
      ,p_ler5_id_o                      => ben_clp_shd.g_old_rec.ler5_id
      ,p_bool5_cd_o                     => ben_clp_shd.g_old_rec.bool5_cd
      ,p_ler6_id_o                      => ben_clp_shd.g_old_rec.ler6_id
      ,p_bool6_cd_o                     => ben_clp_shd.g_old_rec.bool6_cd
      ,p_ler7_id_o                      => ben_clp_shd.g_old_rec.ler7_id
      ,p_bool7_cd_o                     => ben_clp_shd.g_old_rec.bool7_cd
      ,p_ler8_id_o                      => ben_clp_shd.g_old_rec.ler8_id
      ,p_bool8_cd_o                     => ben_clp_shd.g_old_rec.bool8_cd
      ,p_ler9_id_o                      => ben_clp_shd.g_old_rec.ler9_id
      ,p_bool9_cd_o                     => ben_clp_shd.g_old_rec.bool9_cd
      ,p_ler10_id_o                     => ben_clp_shd.g_old_rec.ler10_id
      ,p_eval_cd_o                      => ben_clp_shd.g_old_rec.eval_cd
      ,p_eval_rl_o                      => ben_clp_shd.g_old_rec.eval_rl
      ,p_tlrnc_dys_num_o                => ben_clp_shd.g_old_rec.tlrnc_dys_num
      ,p_eval_ler_id_o                  => ben_clp_shd.g_old_rec.eval_ler_id
      ,p_eval_ler_det_cd_o              => ben_clp_shd.g_old_rec.eval_ler_det_cd
      ,p_eval_ler_det_rl_o              => ben_clp_shd.g_old_rec.eval_ler_det_rl
      ,p_clp_attribute_category_o       => ben_clp_shd.g_old_rec.clp_attribute_category
      ,p_clp_attribute1_o               => ben_clp_shd.g_old_rec.clp_attribute1
      ,p_clp_attribute2_o               => ben_clp_shd.g_old_rec.clp_attribute2
      ,p_clp_attribute3_o               => ben_clp_shd.g_old_rec.clp_attribute3
      ,p_clp_attribute4_o               => ben_clp_shd.g_old_rec.clp_attribute4
      ,p_clp_attribute5_o               => ben_clp_shd.g_old_rec.clp_attribute5
      ,p_clp_attribute6_o               => ben_clp_shd.g_old_rec.clp_attribute6
      ,p_clp_attribute7_o               => ben_clp_shd.g_old_rec.clp_attribute7
      ,p_clp_attribute8_o               => ben_clp_shd.g_old_rec.clp_attribute8
      ,p_clp_attribute9_o               => ben_clp_shd.g_old_rec.clp_attribute9
      ,p_clp_attribute10_o              => ben_clp_shd.g_old_rec.clp_attribute10
      ,p_clp_attribute11_o              => ben_clp_shd.g_old_rec.clp_attribute11
      ,p_clp_attribute12_o              => ben_clp_shd.g_old_rec.clp_attribute12
      ,p_clp_attribute13_o              => ben_clp_shd.g_old_rec.clp_attribute13
      ,p_clp_attribute14_o              => ben_clp_shd.g_old_rec.clp_attribute14
      ,p_clp_attribute15_o              => ben_clp_shd.g_old_rec.clp_attribute15
      ,p_clp_attribute16_o              => ben_clp_shd.g_old_rec.clp_attribute16
      ,p_clp_attribute17_o              => ben_clp_shd.g_old_rec.clp_attribute17
      ,p_clp_attribute18_o              => ben_clp_shd.g_old_rec.clp_attribute18
      ,p_clp_attribute19_o              => ben_clp_shd.g_old_rec.clp_attribute19
      ,p_clp_attribute20_o              => ben_clp_shd.g_old_rec.clp_attribute20
      ,p_clp_attribute21_o              => ben_clp_shd.g_old_rec.clp_attribute21
      ,p_clp_attribute22_o              => ben_clp_shd.g_old_rec.clp_attribute22
      ,p_clp_attribute23_o              => ben_clp_shd.g_old_rec.clp_attribute23
      ,p_clp_attribute24_o              => ben_clp_shd.g_old_rec.clp_attribute24
      ,p_clp_attribute25_o              => ben_clp_shd.g_old_rec.clp_attribute25
      ,p_clp_attribute26_o              => ben_clp_shd.g_old_rec.clp_attribute26
      ,p_clp_attribute27_o              => ben_clp_shd.g_old_rec.clp_attribute27
      ,p_clp_attribute28_o              => ben_clp_shd.g_old_rec.clp_attribute28
      ,p_clp_attribute29_o              => ben_clp_shd.g_old_rec.clp_attribute29
      ,p_clp_attribute30_o              => ben_clp_shd.g_old_rec.clp_attribute30
      ,p_object_version_number_o        => ben_clp_shd.g_old_rec.object_version_number);
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'ben_clpse_lf_evt_f'
        ,p_hook_type   => 'AU');
      --
  end;
  --
  -- End of API User Hook for post_update.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  --
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
Procedure convert_defs(p_rec in out nocopy ben_clp_shd.g_rec_type) is
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
    ben_clp_shd.g_old_rec.business_group_id;
  End If;
  If (p_rec.seq = hr_api.g_number) then
    p_rec.seq :=
    ben_clp_shd.g_old_rec.seq;
  End If;
  If (p_rec.ler1_id = hr_api.g_number) then
    p_rec.ler1_id :=
    ben_clp_shd.g_old_rec.ler1_id;
  End If;
  If (p_rec.bool1_cd = hr_api.g_varchar2) then
    p_rec.bool1_cd :=
    ben_clp_shd.g_old_rec.bool1_cd;
  End If;
  If (p_rec.ler2_id = hr_api.g_number) then
    p_rec.ler2_id :=
    ben_clp_shd.g_old_rec.ler2_id;
  End If;
  If (p_rec.bool2_cd = hr_api.g_varchar2) then
    p_rec.bool2_cd :=
    ben_clp_shd.g_old_rec.bool2_cd;
  End If;
  If (p_rec.ler3_id = hr_api.g_number) then
    p_rec.ler3_id :=
    ben_clp_shd.g_old_rec.ler3_id;
  End If;
  If (p_rec.bool3_cd = hr_api.g_varchar2) then
    p_rec.bool3_cd :=
    ben_clp_shd.g_old_rec.bool3_cd;
  End If;
  If (p_rec.ler4_id = hr_api.g_number) then
    p_rec.ler4_id :=
    ben_clp_shd.g_old_rec.ler4_id;
  End If;
  If (p_rec.bool4_cd = hr_api.g_varchar2) then
    p_rec.bool4_cd :=
    ben_clp_shd.g_old_rec.bool4_cd;
  End If;
  If (p_rec.ler5_id = hr_api.g_number) then
    p_rec.ler5_id :=
    ben_clp_shd.g_old_rec.ler5_id;
  End If;
  If (p_rec.bool5_cd = hr_api.g_varchar2) then
    p_rec.bool5_cd :=
    ben_clp_shd.g_old_rec.bool5_cd;
  End If;
  If (p_rec.ler6_id = hr_api.g_number) then
    p_rec.ler6_id :=
    ben_clp_shd.g_old_rec.ler6_id;
  End If;
  If (p_rec.bool6_cd = hr_api.g_varchar2) then
    p_rec.bool6_cd :=
    ben_clp_shd.g_old_rec.bool6_cd;
  End If;
  If (p_rec.ler7_id = hr_api.g_number) then
    p_rec.ler7_id :=
    ben_clp_shd.g_old_rec.ler7_id;
  End If;
  If (p_rec.bool7_cd = hr_api.g_varchar2) then
    p_rec.bool7_cd :=
    ben_clp_shd.g_old_rec.bool7_cd;
  End If;
  If (p_rec.ler8_id = hr_api.g_number) then
    p_rec.ler8_id :=
    ben_clp_shd.g_old_rec.ler8_id;
  End If;
  If (p_rec.bool8_cd = hr_api.g_varchar2) then
    p_rec.bool8_cd :=
    ben_clp_shd.g_old_rec.bool8_cd;
  End If;
  If (p_rec.ler9_id = hr_api.g_number) then
    p_rec.ler9_id :=
    ben_clp_shd.g_old_rec.ler9_id;
  End If;
  If (p_rec.bool9_cd = hr_api.g_varchar2) then
    p_rec.bool9_cd :=
    ben_clp_shd.g_old_rec.bool9_cd;
  End If;
  If (p_rec.ler10_id = hr_api.g_number) then
    p_rec.ler10_id :=
    ben_clp_shd.g_old_rec.ler10_id;
  End If;
  If (p_rec.eval_cd = hr_api.g_varchar2) then
    p_rec.eval_cd :=
    ben_clp_shd.g_old_rec.eval_cd;
  End If;
  If (p_rec.eval_rl = hr_api.g_number) then
    p_rec.eval_rl :=
    ben_clp_shd.g_old_rec.eval_rl;
  End If;
  If (p_rec.tlrnc_dys_num = hr_api.g_number) then
    p_rec.tlrnc_dys_num :=
    ben_clp_shd.g_old_rec.tlrnc_dys_num;
  End If;
  If (p_rec.eval_ler_id = hr_api.g_number) then
    p_rec.eval_ler_id :=
    ben_clp_shd.g_old_rec.eval_ler_id;
  End If;
  If (p_rec.eval_ler_det_cd = hr_api.g_varchar2) then
    p_rec.eval_ler_det_cd :=
    ben_clp_shd.g_old_rec.eval_ler_det_cd;
  End If;
  If (p_rec.eval_ler_det_rl = hr_api.g_number) then
    p_rec.eval_ler_det_rl :=
    ben_clp_shd.g_old_rec.eval_ler_det_rl;
  End If;
  If (p_rec.clp_attribute_category = hr_api.g_varchar2) then
    p_rec.clp_attribute_category :=
    ben_clp_shd.g_old_rec.clp_attribute_category;
  End If;
  If (p_rec.clp_attribute1 = hr_api.g_varchar2) then
    p_rec.clp_attribute1 :=
    ben_clp_shd.g_old_rec.clp_attribute1;
  End If;
  If (p_rec.clp_attribute2 = hr_api.g_varchar2) then
    p_rec.clp_attribute2 :=
    ben_clp_shd.g_old_rec.clp_attribute2;
  End If;
  If (p_rec.clp_attribute3 = hr_api.g_varchar2) then
    p_rec.clp_attribute3 :=
    ben_clp_shd.g_old_rec.clp_attribute3;
  End If;
  If (p_rec.clp_attribute4 = hr_api.g_varchar2) then
    p_rec.clp_attribute4 :=
    ben_clp_shd.g_old_rec.clp_attribute4;
  End If;
  If (p_rec.clp_attribute5 = hr_api.g_varchar2) then
    p_rec.clp_attribute5 :=
    ben_clp_shd.g_old_rec.clp_attribute5;
  End If;
  If (p_rec.clp_attribute6 = hr_api.g_varchar2) then
    p_rec.clp_attribute6 :=
    ben_clp_shd.g_old_rec.clp_attribute6;
  End If;
  If (p_rec.clp_attribute7 = hr_api.g_varchar2) then
    p_rec.clp_attribute7 :=
    ben_clp_shd.g_old_rec.clp_attribute7;
  End If;
  If (p_rec.clp_attribute8 = hr_api.g_varchar2) then
    p_rec.clp_attribute8 :=
    ben_clp_shd.g_old_rec.clp_attribute8;
  End If;
  If (p_rec.clp_attribute9 = hr_api.g_varchar2) then
    p_rec.clp_attribute9 :=
    ben_clp_shd.g_old_rec.clp_attribute9;
  End If;
  If (p_rec.clp_attribute10 = hr_api.g_varchar2) then
    p_rec.clp_attribute10 :=
    ben_clp_shd.g_old_rec.clp_attribute10;
  End If;
  If (p_rec.clp_attribute11 = hr_api.g_varchar2) then
    p_rec.clp_attribute11 :=
    ben_clp_shd.g_old_rec.clp_attribute11;
  End If;
  If (p_rec.clp_attribute12 = hr_api.g_varchar2) then
    p_rec.clp_attribute12 :=
    ben_clp_shd.g_old_rec.clp_attribute12;
  End If;
  If (p_rec.clp_attribute13 = hr_api.g_varchar2) then
    p_rec.clp_attribute13 :=
    ben_clp_shd.g_old_rec.clp_attribute13;
  End If;
  If (p_rec.clp_attribute14 = hr_api.g_varchar2) then
    p_rec.clp_attribute14 :=
    ben_clp_shd.g_old_rec.clp_attribute14;
  End If;
  If (p_rec.clp_attribute15 = hr_api.g_varchar2) then
    p_rec.clp_attribute15 :=
    ben_clp_shd.g_old_rec.clp_attribute15;
  End If;
  If (p_rec.clp_attribute16 = hr_api.g_varchar2) then
    p_rec.clp_attribute16 :=
    ben_clp_shd.g_old_rec.clp_attribute16;
  End If;
  If (p_rec.clp_attribute17 = hr_api.g_varchar2) then
    p_rec.clp_attribute17 :=
    ben_clp_shd.g_old_rec.clp_attribute17;
  End If;
  If (p_rec.clp_attribute18 = hr_api.g_varchar2) then
    p_rec.clp_attribute18 :=
    ben_clp_shd.g_old_rec.clp_attribute18;
  End If;
  If (p_rec.clp_attribute19 = hr_api.g_varchar2) then
    p_rec.clp_attribute19 :=
    ben_clp_shd.g_old_rec.clp_attribute19;
  End If;
  If (p_rec.clp_attribute20 = hr_api.g_varchar2) then
    p_rec.clp_attribute20 :=
    ben_clp_shd.g_old_rec.clp_attribute20;
  End If;
  If (p_rec.clp_attribute21 = hr_api.g_varchar2) then
    p_rec.clp_attribute21 :=
    ben_clp_shd.g_old_rec.clp_attribute21;
  End If;
  If (p_rec.clp_attribute22 = hr_api.g_varchar2) then
    p_rec.clp_attribute22 :=
    ben_clp_shd.g_old_rec.clp_attribute22;
  End If;
  If (p_rec.clp_attribute23 = hr_api.g_varchar2) then
    p_rec.clp_attribute23 :=
    ben_clp_shd.g_old_rec.clp_attribute23;
  End If;
  If (p_rec.clp_attribute24 = hr_api.g_varchar2) then
    p_rec.clp_attribute24 :=
    ben_clp_shd.g_old_rec.clp_attribute24;
  End If;
  If (p_rec.clp_attribute25 = hr_api.g_varchar2) then
    p_rec.clp_attribute25 :=
    ben_clp_shd.g_old_rec.clp_attribute25;
  End If;
  If (p_rec.clp_attribute26 = hr_api.g_varchar2) then
    p_rec.clp_attribute26 :=
    ben_clp_shd.g_old_rec.clp_attribute26;
  End If;
  If (p_rec.clp_attribute27 = hr_api.g_varchar2) then
    p_rec.clp_attribute27 :=
    ben_clp_shd.g_old_rec.clp_attribute27;
  End If;
  If (p_rec.clp_attribute28 = hr_api.g_varchar2) then
    p_rec.clp_attribute28 :=
    ben_clp_shd.g_old_rec.clp_attribute28;
  End If;
  If (p_rec.clp_attribute29 = hr_api.g_varchar2) then
    p_rec.clp_attribute29 :=
    ben_clp_shd.g_old_rec.clp_attribute29;
  End If;
  If (p_rec.clp_attribute30 = hr_api.g_varchar2) then
    p_rec.clp_attribute30 :=
    ben_clp_shd.g_old_rec.clp_attribute30;
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
  p_rec			in out nocopy 	ben_clp_shd.g_rec_type,
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
  ben_clp_shd.lck
	(p_effective_date	 => p_effective_date,
      	 p_datetrack_mode	 => p_datetrack_mode,
      	 p_clpse_lf_evt_id	 => p_rec.clpse_lf_evt_id,
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
  ben_clp_bus.update_validate
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
  p_clpse_lf_evt_id              in number,
  p_effective_start_date         out nocopy date,
  p_effective_end_date           out nocopy date,
  p_business_group_id            in number           default hr_api.g_number,
  p_seq                          in number           default hr_api.g_number,
  p_ler1_id                      in number           default hr_api.g_number,
  p_bool1_cd                     in varchar2         default hr_api.g_varchar2,
  p_ler2_id                      in number           default hr_api.g_number,
  p_bool2_cd                     in varchar2         default hr_api.g_varchar2,
  p_ler3_id                      in number           default hr_api.g_number,
  p_bool3_cd                     in varchar2         default hr_api.g_varchar2,
  p_ler4_id                      in number           default hr_api.g_number,
  p_bool4_cd                     in varchar2         default hr_api.g_varchar2,
  p_ler5_id                      in number           default hr_api.g_number,
  p_bool5_cd                     in varchar2         default hr_api.g_varchar2,
  p_ler6_id                      in number           default hr_api.g_number,
  p_bool6_cd                     in varchar2         default hr_api.g_varchar2,
  p_ler7_id                      in number           default hr_api.g_number,
  p_bool7_cd                     in varchar2         default hr_api.g_varchar2,
  p_ler8_id                      in number           default hr_api.g_number,
  p_bool8_cd                     in varchar2         default hr_api.g_varchar2,
  p_ler9_id                      in number           default hr_api.g_number,
  p_bool9_cd                     in varchar2         default hr_api.g_varchar2,
  p_ler10_id                     in number           default hr_api.g_number,
  p_eval_cd                      in varchar2         default hr_api.g_varchar2,
  p_eval_rl                      in number           default hr_api.g_number,
  p_tlrnc_dys_num                in number           default hr_api.g_number,
  p_eval_ler_id                  in number           default hr_api.g_number,
  p_eval_ler_det_cd              in varchar2         default hr_api.g_varchar2,
  p_eval_ler_det_rl              in number           default hr_api.g_number,
  p_clp_attribute_category       in varchar2         default hr_api.g_varchar2,
  p_clp_attribute1               in varchar2         default hr_api.g_varchar2,
  p_clp_attribute2               in varchar2         default hr_api.g_varchar2,
  p_clp_attribute3               in varchar2         default hr_api.g_varchar2,
  p_clp_attribute4               in varchar2         default hr_api.g_varchar2,
  p_clp_attribute5               in varchar2         default hr_api.g_varchar2,
  p_clp_attribute6               in varchar2         default hr_api.g_varchar2,
  p_clp_attribute7               in varchar2         default hr_api.g_varchar2,
  p_clp_attribute8               in varchar2         default hr_api.g_varchar2,
  p_clp_attribute9               in varchar2         default hr_api.g_varchar2,
  p_clp_attribute10              in varchar2         default hr_api.g_varchar2,
  p_clp_attribute11              in varchar2         default hr_api.g_varchar2,
  p_clp_attribute12              in varchar2         default hr_api.g_varchar2,
  p_clp_attribute13              in varchar2         default hr_api.g_varchar2,
  p_clp_attribute14              in varchar2         default hr_api.g_varchar2,
  p_clp_attribute15              in varchar2         default hr_api.g_varchar2,
  p_clp_attribute16              in varchar2         default hr_api.g_varchar2,
  p_clp_attribute17              in varchar2         default hr_api.g_varchar2,
  p_clp_attribute18              in varchar2         default hr_api.g_varchar2,
  p_clp_attribute19              in varchar2         default hr_api.g_varchar2,
  p_clp_attribute20              in varchar2         default hr_api.g_varchar2,
  p_clp_attribute21              in varchar2         default hr_api.g_varchar2,
  p_clp_attribute22              in varchar2         default hr_api.g_varchar2,
  p_clp_attribute23              in varchar2         default hr_api.g_varchar2,
  p_clp_attribute24              in varchar2         default hr_api.g_varchar2,
  p_clp_attribute25              in varchar2         default hr_api.g_varchar2,
  p_clp_attribute26              in varchar2         default hr_api.g_varchar2,
  p_clp_attribute27              in varchar2         default hr_api.g_varchar2,
  p_clp_attribute28              in varchar2         default hr_api.g_varchar2,
  p_clp_attribute29              in varchar2         default hr_api.g_varchar2,
  p_clp_attribute30              in varchar2         default hr_api.g_varchar2,
  p_object_version_number        in out nocopy number,
  p_effective_date		 in date,
  p_datetrack_mode		 in varchar2
  ) is
--
  l_rec		ben_clp_shd.g_rec_type;
  l_proc	varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  ben_clp_shd.convert_args
  (
  p_clpse_lf_evt_id,
  null,
  null,
  p_business_group_id,
  p_seq,
  p_ler1_id,
  p_bool1_cd,
  p_ler2_id,
  p_bool2_cd,
  p_ler3_id,
  p_bool3_cd,
  p_ler4_id,
  p_bool4_cd,
  p_ler5_id,
  p_bool5_cd,
  p_ler6_id,
  p_bool6_cd,
  p_ler7_id,
  p_bool7_cd,
  p_ler8_id,
  p_bool8_cd,
  p_ler9_id,
  p_bool9_cd,
  p_ler10_id,
  p_eval_cd,
  p_eval_rl,
  p_tlrnc_dys_num,
  p_eval_ler_id,
  p_eval_ler_det_cd,
  p_eval_ler_det_rl,
  p_clp_attribute_category,
  p_clp_attribute1,
  p_clp_attribute2,
  p_clp_attribute3,
  p_clp_attribute4,
  p_clp_attribute5,
  p_clp_attribute6,
  p_clp_attribute7,
  p_clp_attribute8,
  p_clp_attribute9,
  p_clp_attribute10,
  p_clp_attribute11,
  p_clp_attribute12,
  p_clp_attribute13,
  p_clp_attribute14,
  p_clp_attribute15,
  p_clp_attribute16,
  p_clp_attribute17,
  p_clp_attribute18,
  p_clp_attribute19,
  p_clp_attribute20,
  p_clp_attribute21,
  p_clp_attribute22,
  p_clp_attribute23,
  p_clp_attribute24,
  p_clp_attribute25,
  p_clp_attribute26,
  p_clp_attribute27,
  p_clp_attribute28,
  p_clp_attribute29,
  p_clp_attribute30,
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
end ben_clp_upd;

/
