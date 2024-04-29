--------------------------------------------------------
--  DDL for Package Body BEN_CCT_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_CCT_UPD" as
/* $Header: becctrhi.pkb 120.0 2005/05/28 00:58:57 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_cct_upd.';  -- Global package name
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
	(p_rec 			 in out nocopy ben_cct_shd.g_rec_type,
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
	  (p_base_table_name	=> 'ben_cm_typ_f',
	   p_base_key_column	=> 'cm_typ_id',
	   p_base_key_value	=> p_rec.cm_typ_id);
    --
    ben_cct_shd.g_api_dml := true;  -- Set the api dml status
    --
    -- Update the ben_cm_typ_f Row
    --
    update  ben_cm_typ_f
    set
        cm_typ_id                       = p_rec.cm_typ_id,
    name                            = p_rec.name,
    desc_txt                        = p_rec.desc_txt,
    cm_typ_rl                       = p_rec.cm_typ_rl,
    cm_usg_cd                       = p_rec.cm_usg_cd,
    whnvr_trgrd_flag                = p_rec.whnvr_trgrd_flag,
    shrt_name                       = p_rec.shrt_name,
    pc_kit_cd                       = p_rec.pc_kit_cd,
    trk_mlg_flag                    = p_rec.trk_mlg_flag,
    mx_num_avlbl_val                = p_rec.mx_num_avlbl_val,
    to_be_sent_dt_cd                = p_rec.to_be_sent_dt_cd,
    to_be_sent_dt_rl                = p_rec.to_be_sent_dt_rl,
    inspn_rqd_flag                  = p_rec.inspn_rqd_flag,
    inspn_rqd_rl                    = p_rec.inspn_rqd_rl,
    rcpent_cd                       = p_rec.rcpent_cd,
    parnt_cm_typ_id                 = p_rec.parnt_cm_typ_id,
    business_group_id               = p_rec.business_group_id,
    cct_attribute_category          = p_rec.cct_attribute_category,
    cct_attribute1                  = p_rec.cct_attribute1,
    cct_attribute10                 = p_rec.cct_attribute10,
    cct_attribute11                 = p_rec.cct_attribute11,
    cct_attribute12                 = p_rec.cct_attribute12,
    cct_attribute13                 = p_rec.cct_attribute13,
    cct_attribute14                 = p_rec.cct_attribute14,
    cct_attribute15                 = p_rec.cct_attribute15,
    cct_attribute16                 = p_rec.cct_attribute16,
    cct_attribute17                 = p_rec.cct_attribute17,
    cct_attribute18                 = p_rec.cct_attribute18,
    cct_attribute19                 = p_rec.cct_attribute19,
    cct_attribute2                  = p_rec.cct_attribute2,
    cct_attribute20                 = p_rec.cct_attribute20,
    cct_attribute21                 = p_rec.cct_attribute21,
    cct_attribute22                 = p_rec.cct_attribute22,
    cct_attribute23                 = p_rec.cct_attribute23,
    cct_attribute24                 = p_rec.cct_attribute24,
    cct_attribute25                 = p_rec.cct_attribute25,
    cct_attribute26                 = p_rec.cct_attribute26,
    cct_attribute27                 = p_rec.cct_attribute27,
    cct_attribute28                 = p_rec.cct_attribute28,
    cct_attribute29                 = p_rec.cct_attribute29,
    cct_attribute3                  = p_rec.cct_attribute3,
    cct_attribute30                 = p_rec.cct_attribute30,
    cct_attribute4                  = p_rec.cct_attribute4,
    cct_attribute5                  = p_rec.cct_attribute5,
    cct_attribute6                  = p_rec.cct_attribute6,
    cct_attribute7                  = p_rec.cct_attribute7,
    cct_attribute8                  = p_rec.cct_attribute8,
    cct_attribute9                  = p_rec.cct_attribute9,
    object_version_number           = p_rec.object_version_number
    where   cm_typ_id = p_rec.cm_typ_id
    and     effective_start_date = p_validation_start_date
    and     effective_end_date   = p_validation_end_date;
    --
    --  Update MLS table.
    --
    update ben_cm_typ_f_tl
    set shrt_name   = p_rec.shrt_name,
        name  = p_rec.name,
    last_update_date  = sysdate,
    last_updated_by   = fnd_global.user_id,
    last_update_login = fnd_global.login_id,
    source_lang = userenv('LANG')
    where cm_typ_id = p_rec.cm_typ_id
    and   effective_start_date = p_validation_start_date
    and   effective_end_date = p_validation_end_date
    and   userenv('LANG') in (language, source_lang);
    --
    ben_cct_shd.g_api_dml := false;   -- Unset the api dml status
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
    ben_cct_shd.g_api_dml := false;   -- Unset the api dml status
    ben_cct_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    ben_cct_shd.g_api_dml := false;   -- Unset the api dml status
    ben_cct_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    ben_cct_shd.g_api_dml := false;   -- Unset the api dml status
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
	(p_rec 			 in out nocopy ben_cct_shd.g_rec_type,
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
	(p_rec 			 in out nocopy ben_cct_shd.g_rec_type,
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
    ben_cct_shd.upd_effective_end_date
     (p_effective_date	       => p_effective_date,
      p_base_key_value	       => p_rec.cm_typ_id,
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
      ben_cct_del.delete_dml
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
    ben_cct_ins.insert_dml
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
	(p_rec 			 in out nocopy ben_cct_shd.g_rec_type,
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
	(p_rec 			 in ben_cct_shd.g_rec_type,
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
    ben_cct_rku.after_update
      (p_cm_typ_id                     =>p_rec.cm_typ_id
      ,p_effective_start_date          =>p_rec.effective_start_date
      ,p_effective_end_date            =>p_rec.effective_end_date
      ,p_name                          =>p_rec.name
      ,p_desc_txt                      =>p_rec.desc_txt
      ,p_cm_typ_rl                     =>p_rec.cm_typ_rl
      ,p_cm_usg_cd                     =>p_rec.cm_usg_cd
      ,p_whnvr_trgrd_flag              =>p_rec.whnvr_trgrd_flag
      ,p_shrt_name                     =>p_rec.shrt_name
      ,p_pc_kit_cd                     =>p_rec.pc_kit_cd
      ,p_trk_mlg_flag                  =>p_rec.trk_mlg_flag
      ,p_mx_num_avlbl_val              =>p_rec.mx_num_avlbl_val
      ,p_to_be_sent_dt_cd              =>p_rec.to_be_sent_dt_cd
      ,p_to_be_sent_dt_rl              =>p_rec.to_be_sent_dt_rl
      ,p_inspn_rqd_flag                =>p_rec.inspn_rqd_flag
      ,p_inspn_rqd_rl                  =>p_rec.inspn_rqd_rl
      ,p_rcpent_cd                     =>p_rec.rcpent_cd
      ,p_parnt_cm_typ_id               =>p_rec.parnt_cm_typ_id
      ,p_business_group_id             =>p_rec.business_group_id
      ,p_cct_attribute_category        =>p_rec.cct_attribute_category
      ,p_cct_attribute1                =>p_rec.cct_attribute1
      ,p_cct_attribute10               =>p_rec.cct_attribute10
      ,p_cct_attribute11               =>p_rec.cct_attribute11
      ,p_cct_attribute12               =>p_rec.cct_attribute12
      ,p_cct_attribute13               =>p_rec.cct_attribute13
      ,p_cct_attribute14               =>p_rec.cct_attribute14
      ,p_cct_attribute15               =>p_rec.cct_attribute15
      ,p_cct_attribute16               =>p_rec.cct_attribute16
      ,p_cct_attribute17               =>p_rec.cct_attribute17
      ,p_cct_attribute18               =>p_rec.cct_attribute18
      ,p_cct_attribute19               =>p_rec.cct_attribute19
      ,p_cct_attribute2                =>p_rec.cct_attribute2
      ,p_cct_attribute20               =>p_rec.cct_attribute20
      ,p_cct_attribute21               =>p_rec.cct_attribute21
      ,p_cct_attribute22               =>p_rec.cct_attribute22
      ,p_cct_attribute23               =>p_rec.cct_attribute23
      ,p_cct_attribute24               =>p_rec.cct_attribute24
      ,p_cct_attribute25               =>p_rec.cct_attribute25
      ,p_cct_attribute26               =>p_rec.cct_attribute26
      ,p_cct_attribute27               =>p_rec.cct_attribute27
      ,p_cct_attribute28               =>p_rec.cct_attribute28
      ,p_cct_attribute29               =>p_rec.cct_attribute29
      ,p_cct_attribute3                =>p_rec.cct_attribute3
      ,p_cct_attribute30               =>p_rec.cct_attribute30
      ,p_cct_attribute4                =>p_rec.cct_attribute4
      ,p_cct_attribute5                =>p_rec.cct_attribute5
      ,p_cct_attribute6                =>p_rec.cct_attribute6
      ,p_cct_attribute7                =>p_rec.cct_attribute7
      ,p_cct_attribute8                =>p_rec.cct_attribute8
      ,p_cct_attribute9                =>p_rec.cct_attribute9
      ,p_object_version_number         =>p_rec.object_version_number
      ,p_effective_date                =>p_effective_date
      ,p_datetrack_mode                =>p_datetrack_mode
      ,p_validation_start_date         =>p_validation_start_date
      ,p_validation_end_date           =>p_validation_end_date
      ,p_effective_start_date_o        =>ben_cct_shd.g_old_rec.effective_start_date
      ,p_effective_end_date_o          =>ben_cct_shd.g_old_rec.effective_end_date
      ,p_name_o                        =>ben_cct_shd.g_old_rec.name
      ,p_desc_txt_o                    =>ben_cct_shd.g_old_rec.desc_txt
      ,p_cm_typ_rl_o                   =>ben_cct_shd.g_old_rec.cm_typ_rl
      ,p_cm_usg_cd_o                   =>ben_cct_shd.g_old_rec.cm_usg_cd
      ,p_whnvr_trgrd_flag_o            =>ben_cct_shd.g_old_rec.whnvr_trgrd_flag
      ,p_shrt_name_o                   =>ben_cct_shd.g_old_rec.shrt_name
      ,p_pc_kit_cd_o                   =>ben_cct_shd.g_old_rec.pc_kit_cd
      ,p_trk_mlg_flag_o                =>ben_cct_shd.g_old_rec.trk_mlg_flag
      ,p_mx_num_avlbl_val_o            =>ben_cct_shd.g_old_rec.mx_num_avlbl_val
      ,p_to_be_sent_dt_cd_o            =>ben_cct_shd.g_old_rec.to_be_sent_dt_cd
      ,p_to_be_sent_dt_rl_o            =>ben_cct_shd.g_old_rec.to_be_sent_dt_rl
      ,p_inspn_rqd_flag_o              =>ben_cct_shd.g_old_rec.inspn_rqd_flag
      ,p_inspn_rqd_rl_o                =>ben_cct_shd.g_old_rec.inspn_rqd_rl
      ,p_rcpent_cd_o                   =>ben_cct_shd.g_old_rec.rcpent_cd
      ,p_parnt_cm_typ_id_o             =>ben_cct_shd.g_old_rec.parnt_cm_typ_id
      ,p_business_group_id_o           =>ben_cct_shd.g_old_rec.business_group_id
      ,p_cct_attribute_category_o      =>ben_cct_shd.g_old_rec.cct_attribute_category
      ,p_cct_attribute1_o              =>ben_cct_shd.g_old_rec.cct_attribute1
      ,p_cct_attribute10_o             =>ben_cct_shd.g_old_rec.cct_attribute10
      ,p_cct_attribute11_o             =>ben_cct_shd.g_old_rec.cct_attribute11
      ,p_cct_attribute12_o             =>ben_cct_shd.g_old_rec.cct_attribute12
      ,p_cct_attribute13_o             =>ben_cct_shd.g_old_rec.cct_attribute13
      ,p_cct_attribute14_o             =>ben_cct_shd.g_old_rec.cct_attribute14
      ,p_cct_attribute15_o             =>ben_cct_shd.g_old_rec.cct_attribute15
      ,p_cct_attribute16_o             =>ben_cct_shd.g_old_rec.cct_attribute16
      ,p_cct_attribute17_o             =>ben_cct_shd.g_old_rec.cct_attribute17
      ,p_cct_attribute18_o             =>ben_cct_shd.g_old_rec.cct_attribute18
      ,p_cct_attribute19_o             =>ben_cct_shd.g_old_rec.cct_attribute19
      ,p_cct_attribute2_o              =>ben_cct_shd.g_old_rec.cct_attribute2
      ,p_cct_attribute20_o             =>ben_cct_shd.g_old_rec.cct_attribute20
      ,p_cct_attribute21_o             =>ben_cct_shd.g_old_rec.cct_attribute21
      ,p_cct_attribute22_o             =>ben_cct_shd.g_old_rec.cct_attribute22
      ,p_cct_attribute23_o             =>ben_cct_shd.g_old_rec.cct_attribute23
      ,p_cct_attribute24_o             =>ben_cct_shd.g_old_rec.cct_attribute24
      ,p_cct_attribute25_o             =>ben_cct_shd.g_old_rec.cct_attribute25
      ,p_cct_attribute26_o             =>ben_cct_shd.g_old_rec.cct_attribute26
      ,p_cct_attribute27_o             =>ben_cct_shd.g_old_rec.cct_attribute27
      ,p_cct_attribute28_o             =>ben_cct_shd.g_old_rec.cct_attribute28
      ,p_cct_attribute29_o             =>ben_cct_shd.g_old_rec.cct_attribute29
      ,p_cct_attribute3_o              =>ben_cct_shd.g_old_rec.cct_attribute3
      ,p_cct_attribute30_o             =>ben_cct_shd.g_old_rec.cct_attribute30
      ,p_cct_attribute4_o              =>ben_cct_shd.g_old_rec.cct_attribute4
      ,p_cct_attribute5_o              =>ben_cct_shd.g_old_rec.cct_attribute5
      ,p_cct_attribute6_o              =>ben_cct_shd.g_old_rec.cct_attribute6
      ,p_cct_attribute7_o              =>ben_cct_shd.g_old_rec.cct_attribute7
      ,p_cct_attribute8_o              =>ben_cct_shd.g_old_rec.cct_attribute8
      ,p_cct_attribute9_o              =>ben_cct_shd.g_old_rec.cct_attribute9
      ,p_object_version_number_o       =>ben_cct_shd.g_old_rec.object_version_number);
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'ben_cm_typ_f'
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
Procedure convert_defs(p_rec in out nocopy ben_cct_shd.g_rec_type) is
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
    ben_cct_shd.g_old_rec.name;
  End If;
  If (p_rec.desc_txt = hr_api.g_varchar2) then
    p_rec.desc_txt :=
    ben_cct_shd.g_old_rec.desc_txt;
  End If;
  If (p_rec.cm_typ_rl = hr_api.g_number) then
    p_rec.cm_typ_rl :=
    ben_cct_shd.g_old_rec.cm_typ_rl;
  End If;
  If (p_rec.cm_usg_cd = hr_api.g_varchar2) then
    p_rec.cm_usg_cd :=
    ben_cct_shd.g_old_rec.cm_usg_cd;
  End If;
  If (p_rec.whnvr_trgrd_flag = hr_api.g_varchar2) then
    p_rec.whnvr_trgrd_flag :=
    ben_cct_shd.g_old_rec.whnvr_trgrd_flag;
  End If;
  If (p_rec.shrt_name = hr_api.g_varchar2) then
    p_rec.shrt_name :=
    ben_cct_shd.g_old_rec.shrt_name;
  End If;
  If (p_rec.pc_kit_cd = hr_api.g_varchar2) then
    p_rec.pc_kit_cd :=
    ben_cct_shd.g_old_rec.pc_kit_cd;
  End If;
  If (p_rec.trk_mlg_flag = hr_api.g_varchar2) then
    p_rec.trk_mlg_flag :=
    ben_cct_shd.g_old_rec.trk_mlg_flag;
  End If;
  If (p_rec.mx_num_avlbl_val = hr_api.g_number) then
    p_rec.mx_num_avlbl_val :=
    ben_cct_shd.g_old_rec.mx_num_avlbl_val;
  End If;
  If (p_rec.to_be_sent_dt_cd = hr_api.g_varchar2) then
    p_rec.to_be_sent_dt_cd :=
    ben_cct_shd.g_old_rec.to_be_sent_dt_cd;
  End If;
  If (p_rec.to_be_sent_dt_rl = hr_api.g_number) then
    p_rec.to_be_sent_dt_rl :=
    ben_cct_shd.g_old_rec.to_be_sent_dt_rl;
  End If;
  If (p_rec.inspn_rqd_flag = hr_api.g_varchar2) then
    p_rec.inspn_rqd_flag :=
    ben_cct_shd.g_old_rec.inspn_rqd_flag;
  End If;
  If (p_rec.inspn_rqd_rl = hr_api.g_number) then
    p_rec.inspn_rqd_rl :=
    ben_cct_shd.g_old_rec.inspn_rqd_rl;
  End If;
  If (p_rec.rcpent_cd = hr_api.g_varchar2) then
    p_rec.rcpent_cd :=
    ben_cct_shd.g_old_rec.rcpent_cd;
  End If;
  If (p_rec.parnt_cm_typ_id = hr_api.g_number) then
    p_rec.parnt_cm_typ_id :=
    ben_cct_shd.g_old_rec.parnt_cm_typ_id;
  End If;
  If (p_rec.business_group_id = hr_api.g_number) then
    p_rec.business_group_id :=
    ben_cct_shd.g_old_rec.business_group_id;
  End If;
  If (p_rec.cct_attribute_category = hr_api.g_varchar2) then
    p_rec.cct_attribute_category :=
    ben_cct_shd.g_old_rec.cct_attribute_category;
  End If;
  If (p_rec.cct_attribute1 = hr_api.g_varchar2) then
    p_rec.cct_attribute1 :=
    ben_cct_shd.g_old_rec.cct_attribute1;
  End If;
  If (p_rec.cct_attribute10 = hr_api.g_varchar2) then
    p_rec.cct_attribute10 :=
    ben_cct_shd.g_old_rec.cct_attribute10;
  End If;
  If (p_rec.cct_attribute11 = hr_api.g_varchar2) then
    p_rec.cct_attribute11 :=
    ben_cct_shd.g_old_rec.cct_attribute11;
  End If;
  If (p_rec.cct_attribute12 = hr_api.g_varchar2) then
    p_rec.cct_attribute12 :=
    ben_cct_shd.g_old_rec.cct_attribute12;
  End If;
  If (p_rec.cct_attribute13 = hr_api.g_varchar2) then
    p_rec.cct_attribute13 :=
    ben_cct_shd.g_old_rec.cct_attribute13;
  End If;
  If (p_rec.cct_attribute14 = hr_api.g_varchar2) then
    p_rec.cct_attribute14 :=
    ben_cct_shd.g_old_rec.cct_attribute14;
  End If;
  If (p_rec.cct_attribute15 = hr_api.g_varchar2) then
    p_rec.cct_attribute15 :=
    ben_cct_shd.g_old_rec.cct_attribute15;
  End If;
  If (p_rec.cct_attribute16 = hr_api.g_varchar2) then
    p_rec.cct_attribute16 :=
    ben_cct_shd.g_old_rec.cct_attribute16;
  End If;
  If (p_rec.cct_attribute17 = hr_api.g_varchar2) then
    p_rec.cct_attribute17 :=
    ben_cct_shd.g_old_rec.cct_attribute17;
  End If;
  If (p_rec.cct_attribute18 = hr_api.g_varchar2) then
    p_rec.cct_attribute18 :=
    ben_cct_shd.g_old_rec.cct_attribute18;
  End If;
  If (p_rec.cct_attribute19 = hr_api.g_varchar2) then
    p_rec.cct_attribute19 :=
    ben_cct_shd.g_old_rec.cct_attribute19;
  End If;
  If (p_rec.cct_attribute2 = hr_api.g_varchar2) then
    p_rec.cct_attribute2 :=
    ben_cct_shd.g_old_rec.cct_attribute2;
  End If;
  If (p_rec.cct_attribute20 = hr_api.g_varchar2) then
    p_rec.cct_attribute20 :=
    ben_cct_shd.g_old_rec.cct_attribute20;
  End If;
  If (p_rec.cct_attribute21 = hr_api.g_varchar2) then
    p_rec.cct_attribute21 :=
    ben_cct_shd.g_old_rec.cct_attribute21;
  End If;
  If (p_rec.cct_attribute22 = hr_api.g_varchar2) then
    p_rec.cct_attribute22 :=
    ben_cct_shd.g_old_rec.cct_attribute22;
  End If;
  If (p_rec.cct_attribute23 = hr_api.g_varchar2) then
    p_rec.cct_attribute23 :=
    ben_cct_shd.g_old_rec.cct_attribute23;
  End If;
  If (p_rec.cct_attribute24 = hr_api.g_varchar2) then
    p_rec.cct_attribute24 :=
    ben_cct_shd.g_old_rec.cct_attribute24;
  End If;
  If (p_rec.cct_attribute25 = hr_api.g_varchar2) then
    p_rec.cct_attribute25 :=
    ben_cct_shd.g_old_rec.cct_attribute25;
  End If;
  If (p_rec.cct_attribute26 = hr_api.g_varchar2) then
    p_rec.cct_attribute26 :=
    ben_cct_shd.g_old_rec.cct_attribute26;
  End If;
  If (p_rec.cct_attribute27 = hr_api.g_varchar2) then
    p_rec.cct_attribute27 :=
    ben_cct_shd.g_old_rec.cct_attribute27;
  End If;
  If (p_rec.cct_attribute28 = hr_api.g_varchar2) then
    p_rec.cct_attribute28 :=
    ben_cct_shd.g_old_rec.cct_attribute28;
  End If;
  If (p_rec.cct_attribute29 = hr_api.g_varchar2) then
    p_rec.cct_attribute29 :=
    ben_cct_shd.g_old_rec.cct_attribute29;
  End If;
  If (p_rec.cct_attribute3 = hr_api.g_varchar2) then
    p_rec.cct_attribute3 :=
    ben_cct_shd.g_old_rec.cct_attribute3;
  End If;
  If (p_rec.cct_attribute30 = hr_api.g_varchar2) then
    p_rec.cct_attribute30 :=
    ben_cct_shd.g_old_rec.cct_attribute30;
  End If;
  If (p_rec.cct_attribute4 = hr_api.g_varchar2) then
    p_rec.cct_attribute4 :=
    ben_cct_shd.g_old_rec.cct_attribute4;
  End If;
  If (p_rec.cct_attribute5 = hr_api.g_varchar2) then
    p_rec.cct_attribute5 :=
    ben_cct_shd.g_old_rec.cct_attribute5;
  End If;
  If (p_rec.cct_attribute6 = hr_api.g_varchar2) then
    p_rec.cct_attribute6 :=
    ben_cct_shd.g_old_rec.cct_attribute6;
  End If;
  If (p_rec.cct_attribute7 = hr_api.g_varchar2) then
    p_rec.cct_attribute7 :=
    ben_cct_shd.g_old_rec.cct_attribute7;
  End If;
  If (p_rec.cct_attribute8 = hr_api.g_varchar2) then
    p_rec.cct_attribute8 :=
    ben_cct_shd.g_old_rec.cct_attribute8;
  End If;
  If (p_rec.cct_attribute9 = hr_api.g_varchar2) then
    p_rec.cct_attribute9 :=
    ben_cct_shd.g_old_rec.cct_attribute9;
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
  p_rec			in out nocopy 	ben_cct_shd.g_rec_type,
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
  ben_cct_shd.lck
	(p_effective_date	 => p_effective_date,
      	 p_datetrack_mode	 => p_datetrack_mode,
      	 p_cm_typ_id	 => p_rec.cm_typ_id,
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
  ben_cct_bus.update_validate
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
  p_cm_typ_id                    in number,
  p_effective_start_date         out nocopy date,
  p_effective_end_date           out nocopy date,
  p_name                         in varchar2         default hr_api.g_varchar2,
  p_desc_txt                     in varchar2         default hr_api.g_varchar2,
  p_cm_typ_rl                    in number           default hr_api.g_number,
  p_cm_usg_cd                    in varchar2         default hr_api.g_varchar2,
  p_whnvr_trgrd_flag             in varchar2         default hr_api.g_varchar2,
  p_shrt_name                    in varchar2         default hr_api.g_varchar2,
  p_pc_kit_cd                    in varchar2         default hr_api.g_varchar2,
  p_trk_mlg_flag                 in varchar2         default hr_api.g_varchar2,
  p_mx_num_avlbl_val             in number           default hr_api.g_number,
  p_to_be_sent_dt_cd             in varchar2         default hr_api.g_varchar2,
  p_to_be_sent_dt_rl             in number           default hr_api.g_number,
  p_inspn_rqd_flag               in varchar2         default hr_api.g_varchar2,
  p_inspn_rqd_rl                 in number           default hr_api.g_number,
  p_rcpent_cd                    in varchar2         default hr_api.g_varchar2,
  p_parnt_cm_typ_id              in number           default hr_api.g_number,
  p_business_group_id            in number           default hr_api.g_number,
  p_cct_attribute_category       in varchar2         default hr_api.g_varchar2,
  p_cct_attribute1               in varchar2         default hr_api.g_varchar2,
  p_cct_attribute10              in varchar2         default hr_api.g_varchar2,
  p_cct_attribute11              in varchar2         default hr_api.g_varchar2,
  p_cct_attribute12              in varchar2         default hr_api.g_varchar2,
  p_cct_attribute13              in varchar2         default hr_api.g_varchar2,
  p_cct_attribute14              in varchar2         default hr_api.g_varchar2,
  p_cct_attribute15              in varchar2         default hr_api.g_varchar2,
  p_cct_attribute16              in varchar2         default hr_api.g_varchar2,
  p_cct_attribute17              in varchar2         default hr_api.g_varchar2,
  p_cct_attribute18              in varchar2         default hr_api.g_varchar2,
  p_cct_attribute19              in varchar2         default hr_api.g_varchar2,
  p_cct_attribute2               in varchar2         default hr_api.g_varchar2,
  p_cct_attribute20              in varchar2         default hr_api.g_varchar2,
  p_cct_attribute21              in varchar2         default hr_api.g_varchar2,
  p_cct_attribute22              in varchar2         default hr_api.g_varchar2,
  p_cct_attribute23              in varchar2         default hr_api.g_varchar2,
  p_cct_attribute24              in varchar2         default hr_api.g_varchar2,
  p_cct_attribute25              in varchar2         default hr_api.g_varchar2,
  p_cct_attribute26              in varchar2         default hr_api.g_varchar2,
  p_cct_attribute27              in varchar2         default hr_api.g_varchar2,
  p_cct_attribute28              in varchar2         default hr_api.g_varchar2,
  p_cct_attribute29              in varchar2         default hr_api.g_varchar2,
  p_cct_attribute3               in varchar2         default hr_api.g_varchar2,
  p_cct_attribute30              in varchar2         default hr_api.g_varchar2,
  p_cct_attribute4               in varchar2         default hr_api.g_varchar2,
  p_cct_attribute5               in varchar2         default hr_api.g_varchar2,
  p_cct_attribute6               in varchar2         default hr_api.g_varchar2,
  p_cct_attribute7               in varchar2         default hr_api.g_varchar2,
  p_cct_attribute8               in varchar2         default hr_api.g_varchar2,
  p_cct_attribute9               in varchar2         default hr_api.g_varchar2,
  p_object_version_number        in out nocopy number,
  p_effective_date		 in date,
  p_datetrack_mode		 in varchar2
  ) is
--
  l_rec		ben_cct_shd.g_rec_type;
  l_proc	varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  ben_cct_shd.convert_args
  (
  p_cm_typ_id,
  null,
  null,
  p_name,
  p_desc_txt,
  p_cm_typ_rl,
  p_cm_usg_cd,
  p_whnvr_trgrd_flag,
  p_shrt_name,
  p_pc_kit_cd,
  p_trk_mlg_flag,
  p_mx_num_avlbl_val,
  p_to_be_sent_dt_cd,
  p_to_be_sent_dt_rl,
  p_inspn_rqd_flag,
  p_inspn_rqd_rl,
  p_rcpent_cd,
  p_parnt_cm_typ_id,
  p_business_group_id,
  p_cct_attribute_category,
  p_cct_attribute1,
  p_cct_attribute10,
  p_cct_attribute11,
  p_cct_attribute12,
  p_cct_attribute13,
  p_cct_attribute14,
  p_cct_attribute15,
  p_cct_attribute16,
  p_cct_attribute17,
  p_cct_attribute18,
  p_cct_attribute19,
  p_cct_attribute2,
  p_cct_attribute20,
  p_cct_attribute21,
  p_cct_attribute22,
  p_cct_attribute23,
  p_cct_attribute24,
  p_cct_attribute25,
  p_cct_attribute26,
  p_cct_attribute27,
  p_cct_attribute28,
  p_cct_attribute29,
  p_cct_attribute3,
  p_cct_attribute30,
  p_cct_attribute4,
  p_cct_attribute5,
  p_cct_attribute6,
  p_cct_attribute7,
  p_cct_attribute8,
  p_cct_attribute9,
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
end ben_cct_upd;

/
