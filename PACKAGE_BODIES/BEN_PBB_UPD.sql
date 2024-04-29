--------------------------------------------------------
--  DDL for Package Body BEN_PBB_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PBB_UPD" as
/* $Header: bepbbrhi.pkb 115.14 2004/02/03 10:38:48 pbodla ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_pbb_upd.';  -- Global package name
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
	(p_rec 			 in out nocopy ben_pbb_shd.g_rec_type,
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
	  (p_base_table_name	=> 'ben_per_bnfts_bal_f',
	   p_base_key_column	=> 'per_bnfts_bal_id',
	   p_base_key_value	=> p_rec.per_bnfts_bal_id);
    --
    ben_pbb_shd.g_api_dml := true;  -- Set the api dml status
    --
    -- Update the ben_per_bnfts_bal_f Row
    --
    update  ben_per_bnfts_bal_f
    set
        per_bnfts_bal_id                = p_rec.per_bnfts_bal_id,
    val                             = p_rec.val,
    bnfts_bal_id                    = p_rec.bnfts_bal_id,
    person_id                       = p_rec.person_id,
    business_group_id               = p_rec.business_group_id,
    pbb_attribute_category          = p_rec.pbb_attribute_category,
    pbb_attribute1                  = p_rec.pbb_attribute1,
    pbb_attribute2                  = p_rec.pbb_attribute2,
    pbb_attribute3                  = p_rec.pbb_attribute3,
    pbb_attribute4                  = p_rec.pbb_attribute4,
    pbb_attribute5                  = p_rec.pbb_attribute5,
    pbb_attribute6                  = p_rec.pbb_attribute6,
    pbb_attribute7                  = p_rec.pbb_attribute7,
    pbb_attribute8                  = p_rec.pbb_attribute8,
    pbb_attribute9                  = p_rec.pbb_attribute9,
    pbb_attribute10                 = p_rec.pbb_attribute10,
    pbb_attribute11                 = p_rec.pbb_attribute11,
    pbb_attribute12                 = p_rec.pbb_attribute12,
    pbb_attribute13                 = p_rec.pbb_attribute13,
    pbb_attribute14                 = p_rec.pbb_attribute14,
    pbb_attribute15                 = p_rec.pbb_attribute15,
    pbb_attribute16                 = p_rec.pbb_attribute16,
    pbb_attribute17                 = p_rec.pbb_attribute17,
    pbb_attribute18                 = p_rec.pbb_attribute18,
    pbb_attribute19                 = p_rec.pbb_attribute19,
    pbb_attribute20                 = p_rec.pbb_attribute20,
    pbb_attribute21                 = p_rec.pbb_attribute21,
    pbb_attribute22                 = p_rec.pbb_attribute22,
    pbb_attribute23                 = p_rec.pbb_attribute23,
    pbb_attribute24                 = p_rec.pbb_attribute24,
    pbb_attribute25                 = p_rec.pbb_attribute25,
    pbb_attribute26                 = p_rec.pbb_attribute26,
    pbb_attribute27                 = p_rec.pbb_attribute27,
    pbb_attribute28                 = p_rec.pbb_attribute28,
    pbb_attribute29                 = p_rec.pbb_attribute29,
    pbb_attribute30                 = p_rec.pbb_attribute30,
    object_version_number           = p_rec.object_version_number
    where   per_bnfts_bal_id = p_rec.per_bnfts_bal_id
    and     effective_start_date = p_validation_start_date
    and     effective_end_date   = p_validation_end_date;
    --
    ben_pbb_shd.g_api_dml := false;   -- Unset the api dml status
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
    ben_pbb_shd.g_api_dml := false;   -- Unset the api dml status
    ben_pbb_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    ben_pbb_shd.g_api_dml := false;   -- Unset the api dml status
    ben_pbb_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    ben_pbb_shd.g_api_dml := false;   -- Unset the api dml status
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
	(p_rec 			 in out nocopy ben_pbb_shd.g_rec_type,
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
	(p_rec 			 in out nocopy ben_pbb_shd.g_rec_type,
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
    ben_pbb_shd.upd_effective_end_date
     (p_effective_date	       => p_effective_date,
      p_base_key_value	       => p_rec.per_bnfts_bal_id,
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
      ben_pbb_del.delete_dml
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
    ben_pbb_ins.insert_dml
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
	(p_rec 			 in out nocopy ben_pbb_shd.g_rec_type,
	 p_effective_date	 in	date,
	 p_datetrack_mode	 in	varchar2,
	 p_validation_start_date in	date,
	 p_validation_end_date	 in	date) is
--
  l_proc	varchar2(72) := g_package||'pre_update';
  l_rowid       varchar2(72);
  l_esd         date;
  l_eed         date;
--
cursor csr_rowid is
select rowid, effective_start_date, effective_end_date
from ben_per_bnfts_bal_f
where per_bnfts_bal_id = p_rec.per_bnfts_bal_id
and p_effective_date between
effective_start_date and effective_end_date;

cursor csr_rowid_u is
select rowid
from ben_per_bnfts_bal_f
where per_bnfts_bal_id = p_rec.per_bnfts_bal_id
and p_effective_date -1 between
effective_start_date and effective_end_date;
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
  --
  if p_datetrack_mode <> 'CORRECTION' then
     open csr_rowid_u;
     fetch csr_rowid_u into l_rowid;
     close csr_rowid_u;
     l_esd := p_rec.effective_start_date;
     l_eed := p_rec.effective_end_date;
  else
    open csr_rowid;
    fetch csr_rowid into l_rowid, l_esd, l_eed;
    close csr_rowid;
 end if;
  --
  hr_utility.set_location(' pbb rhi esd:'||p_rec.effective_start_date, 10);
  hr_utility.set_location(' pbb rhi eed:'||p_rec.effective_end_date, 10);
  hr_utility.set_location(' pbb rhi l_esd:'||l_esd, 10);
  hr_utility.set_location(' pbb rhi l_eed:'||l_eed, 10);

 ben_dt_trgr_handle.bnfts_bal
    (p_rowid                 => l_rowid
    ,p_per_bnfts_bal_id      => p_rec.per_bnfts_bal_id
    ,p_business_group_id     => p_rec.business_group_id
    ,p_person_id             => p_rec.person_id
    ,p_effective_start_date  => l_esd
    ,p_effective_end_date    => l_eed
    ,p_val                   => p_rec.val
    ,p_bnfts_bal_id          => p_rec.bnfts_bal_id
    );
  --
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
	(p_rec 			 in ben_pbb_shd.g_rec_type,
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
    ben_pbb_rku.after_update
      (
  p_per_bnfts_bal_id              =>p_rec.per_bnfts_bal_id
 ,p_effective_start_date          =>p_rec.effective_start_date
 ,p_effective_end_date            =>p_rec.effective_end_date
 ,p_val                           =>p_rec.val
 ,p_bnfts_bal_id                  =>p_rec.bnfts_bal_id
 ,p_person_id                     =>p_rec.person_id
 ,p_business_group_id             =>p_rec.business_group_id
 ,p_pbb_attribute_category        =>p_rec.pbb_attribute_category
 ,p_pbb_attribute1                =>p_rec.pbb_attribute1
 ,p_pbb_attribute2                =>p_rec.pbb_attribute2
 ,p_pbb_attribute3                =>p_rec.pbb_attribute3
 ,p_pbb_attribute4                =>p_rec.pbb_attribute4
 ,p_pbb_attribute5                =>p_rec.pbb_attribute5
 ,p_pbb_attribute6                =>p_rec.pbb_attribute6
 ,p_pbb_attribute7                =>p_rec.pbb_attribute7
 ,p_pbb_attribute8                =>p_rec.pbb_attribute8
 ,p_pbb_attribute9                =>p_rec.pbb_attribute9
 ,p_pbb_attribute10               =>p_rec.pbb_attribute10
 ,p_pbb_attribute11               =>p_rec.pbb_attribute11
 ,p_pbb_attribute12               =>p_rec.pbb_attribute12
 ,p_pbb_attribute13               =>p_rec.pbb_attribute13
 ,p_pbb_attribute14               =>p_rec.pbb_attribute14
 ,p_pbb_attribute15               =>p_rec.pbb_attribute15
 ,p_pbb_attribute16               =>p_rec.pbb_attribute16
 ,p_pbb_attribute17               =>p_rec.pbb_attribute17
 ,p_pbb_attribute18               =>p_rec.pbb_attribute18
 ,p_pbb_attribute19               =>p_rec.pbb_attribute19
 ,p_pbb_attribute20               =>p_rec.pbb_attribute20
 ,p_pbb_attribute21               =>p_rec.pbb_attribute21
 ,p_pbb_attribute22               =>p_rec.pbb_attribute22
 ,p_pbb_attribute23               =>p_rec.pbb_attribute23
 ,p_pbb_attribute24               =>p_rec.pbb_attribute24
 ,p_pbb_attribute25               =>p_rec.pbb_attribute25
 ,p_pbb_attribute26               =>p_rec.pbb_attribute26
 ,p_pbb_attribute27               =>p_rec.pbb_attribute27
 ,p_pbb_attribute28               =>p_rec.pbb_attribute28
 ,p_pbb_attribute29               =>p_rec.pbb_attribute29
 ,p_pbb_attribute30               =>p_rec.pbb_attribute30
 ,p_object_version_number         =>p_rec.object_version_number
 ,p_effective_date                =>p_effective_date
 ,p_datetrack_mode                =>p_datetrack_mode
 ,p_validation_start_date         =>p_validation_start_date
 ,p_validation_end_date           =>p_validation_end_date
 ,p_effective_start_date_o        =>ben_pbb_shd.g_old_rec.effective_start_date
 ,p_effective_end_date_o          =>ben_pbb_shd.g_old_rec.effective_end_date
 ,p_val_o                         =>ben_pbb_shd.g_old_rec.val
 ,p_bnfts_bal_id_o                =>ben_pbb_shd.g_old_rec.bnfts_bal_id
 ,p_person_id_o                   =>ben_pbb_shd.g_old_rec.person_id
 ,p_business_group_id_o           =>ben_pbb_shd.g_old_rec.business_group_id
 ,p_pbb_attribute_category_o      =>ben_pbb_shd.g_old_rec.pbb_attribute_category
 ,p_pbb_attribute1_o              =>ben_pbb_shd.g_old_rec.pbb_attribute1
 ,p_pbb_attribute2_o              =>ben_pbb_shd.g_old_rec.pbb_attribute2
 ,p_pbb_attribute3_o              =>ben_pbb_shd.g_old_rec.pbb_attribute3
 ,p_pbb_attribute4_o              =>ben_pbb_shd.g_old_rec.pbb_attribute4
 ,p_pbb_attribute5_o              =>ben_pbb_shd.g_old_rec.pbb_attribute5
 ,p_pbb_attribute6_o              =>ben_pbb_shd.g_old_rec.pbb_attribute6
 ,p_pbb_attribute7_o              =>ben_pbb_shd.g_old_rec.pbb_attribute7
 ,p_pbb_attribute8_o              =>ben_pbb_shd.g_old_rec.pbb_attribute8
 ,p_pbb_attribute9_o              =>ben_pbb_shd.g_old_rec.pbb_attribute9
 ,p_pbb_attribute10_o             =>ben_pbb_shd.g_old_rec.pbb_attribute10
 ,p_pbb_attribute11_o             =>ben_pbb_shd.g_old_rec.pbb_attribute11
 ,p_pbb_attribute12_o             =>ben_pbb_shd.g_old_rec.pbb_attribute12
 ,p_pbb_attribute13_o             =>ben_pbb_shd.g_old_rec.pbb_attribute13
 ,p_pbb_attribute14_o             =>ben_pbb_shd.g_old_rec.pbb_attribute14
 ,p_pbb_attribute15_o             =>ben_pbb_shd.g_old_rec.pbb_attribute15
 ,p_pbb_attribute16_o             =>ben_pbb_shd.g_old_rec.pbb_attribute16
 ,p_pbb_attribute17_o             =>ben_pbb_shd.g_old_rec.pbb_attribute17
 ,p_pbb_attribute18_o             =>ben_pbb_shd.g_old_rec.pbb_attribute18
 ,p_pbb_attribute19_o             =>ben_pbb_shd.g_old_rec.pbb_attribute19
 ,p_pbb_attribute20_o             =>ben_pbb_shd.g_old_rec.pbb_attribute20
 ,p_pbb_attribute21_o             =>ben_pbb_shd.g_old_rec.pbb_attribute21
 ,p_pbb_attribute22_o             =>ben_pbb_shd.g_old_rec.pbb_attribute22
 ,p_pbb_attribute23_o             =>ben_pbb_shd.g_old_rec.pbb_attribute23
 ,p_pbb_attribute24_o             =>ben_pbb_shd.g_old_rec.pbb_attribute24
 ,p_pbb_attribute25_o             =>ben_pbb_shd.g_old_rec.pbb_attribute25
 ,p_pbb_attribute26_o             =>ben_pbb_shd.g_old_rec.pbb_attribute26
 ,p_pbb_attribute27_o             =>ben_pbb_shd.g_old_rec.pbb_attribute27
 ,p_pbb_attribute28_o             =>ben_pbb_shd.g_old_rec.pbb_attribute28
 ,p_pbb_attribute29_o             =>ben_pbb_shd.g_old_rec.pbb_attribute29
 ,p_pbb_attribute30_o             =>ben_pbb_shd.g_old_rec.pbb_attribute30
 ,p_object_version_number_o       =>ben_pbb_shd.g_old_rec.object_version_number
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'ben_per_bnfts_bal_f'
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
Procedure convert_defs(p_rec in out nocopy ben_pbb_shd.g_rec_type) is
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
  If (p_rec.val = hr_api.g_number) then
    p_rec.val :=
    ben_pbb_shd.g_old_rec.val;
  End If;
  If (p_rec.bnfts_bal_id = hr_api.g_number) then
    p_rec.bnfts_bal_id :=
    ben_pbb_shd.g_old_rec.bnfts_bal_id;
  End If;
  If (p_rec.person_id = hr_api.g_number) then
    p_rec.person_id :=
    ben_pbb_shd.g_old_rec.person_id;
  End If;
  If (p_rec.business_group_id = hr_api.g_number) then
    p_rec.business_group_id :=
    ben_pbb_shd.g_old_rec.business_group_id;
  End If;
  If (p_rec.pbb_attribute_category = hr_api.g_varchar2) then
    p_rec.pbb_attribute_category :=
    ben_pbb_shd.g_old_rec.pbb_attribute_category;
  End If;
  If (p_rec.pbb_attribute1 = hr_api.g_varchar2) then
    p_rec.pbb_attribute1 :=
    ben_pbb_shd.g_old_rec.pbb_attribute1;
  End If;
  If (p_rec.pbb_attribute2 = hr_api.g_varchar2) then
    p_rec.pbb_attribute2 :=
    ben_pbb_shd.g_old_rec.pbb_attribute2;
  End If;
  If (p_rec.pbb_attribute3 = hr_api.g_varchar2) then
    p_rec.pbb_attribute3 :=
    ben_pbb_shd.g_old_rec.pbb_attribute3;
  End If;
  If (p_rec.pbb_attribute4 = hr_api.g_varchar2) then
    p_rec.pbb_attribute4 :=
    ben_pbb_shd.g_old_rec.pbb_attribute4;
  End If;
  If (p_rec.pbb_attribute5 = hr_api.g_varchar2) then
    p_rec.pbb_attribute5 :=
    ben_pbb_shd.g_old_rec.pbb_attribute5;
  End If;
  If (p_rec.pbb_attribute6 = hr_api.g_varchar2) then
    p_rec.pbb_attribute6 :=
    ben_pbb_shd.g_old_rec.pbb_attribute6;
  End If;
  If (p_rec.pbb_attribute7 = hr_api.g_varchar2) then
    p_rec.pbb_attribute7 :=
    ben_pbb_shd.g_old_rec.pbb_attribute7;
  End If;
  If (p_rec.pbb_attribute8 = hr_api.g_varchar2) then
    p_rec.pbb_attribute8 :=
    ben_pbb_shd.g_old_rec.pbb_attribute8;
  End If;
  If (p_rec.pbb_attribute9 = hr_api.g_varchar2) then
    p_rec.pbb_attribute9 :=
    ben_pbb_shd.g_old_rec.pbb_attribute9;
  End If;
  If (p_rec.pbb_attribute10 = hr_api.g_varchar2) then
    p_rec.pbb_attribute10 :=
    ben_pbb_shd.g_old_rec.pbb_attribute10;
  End If;
  If (p_rec.pbb_attribute11 = hr_api.g_varchar2) then
    p_rec.pbb_attribute11 :=
    ben_pbb_shd.g_old_rec.pbb_attribute11;
  End If;
  If (p_rec.pbb_attribute12 = hr_api.g_varchar2) then
    p_rec.pbb_attribute12 :=
    ben_pbb_shd.g_old_rec.pbb_attribute12;
  End If;
  If (p_rec.pbb_attribute13 = hr_api.g_varchar2) then
    p_rec.pbb_attribute13 :=
    ben_pbb_shd.g_old_rec.pbb_attribute13;
  End If;
  If (p_rec.pbb_attribute14 = hr_api.g_varchar2) then
    p_rec.pbb_attribute14 :=
    ben_pbb_shd.g_old_rec.pbb_attribute14;
  End If;
  If (p_rec.pbb_attribute15 = hr_api.g_varchar2) then
    p_rec.pbb_attribute15 :=
    ben_pbb_shd.g_old_rec.pbb_attribute15;
  End If;
  If (p_rec.pbb_attribute16 = hr_api.g_varchar2) then
    p_rec.pbb_attribute16 :=
    ben_pbb_shd.g_old_rec.pbb_attribute16;
  End If;
  If (p_rec.pbb_attribute17 = hr_api.g_varchar2) then
    p_rec.pbb_attribute17 :=
    ben_pbb_shd.g_old_rec.pbb_attribute17;
  End If;
  If (p_rec.pbb_attribute18 = hr_api.g_varchar2) then
    p_rec.pbb_attribute18 :=
    ben_pbb_shd.g_old_rec.pbb_attribute18;
  End If;
  If (p_rec.pbb_attribute19 = hr_api.g_varchar2) then
    p_rec.pbb_attribute19 :=
    ben_pbb_shd.g_old_rec.pbb_attribute19;
  End If;
  If (p_rec.pbb_attribute20 = hr_api.g_varchar2) then
    p_rec.pbb_attribute20 :=
    ben_pbb_shd.g_old_rec.pbb_attribute20;
  End If;
  If (p_rec.pbb_attribute21 = hr_api.g_varchar2) then
    p_rec.pbb_attribute21 :=
    ben_pbb_shd.g_old_rec.pbb_attribute21;
  End If;
  If (p_rec.pbb_attribute22 = hr_api.g_varchar2) then
    p_rec.pbb_attribute22 :=
    ben_pbb_shd.g_old_rec.pbb_attribute22;
  End If;
  If (p_rec.pbb_attribute23 = hr_api.g_varchar2) then
    p_rec.pbb_attribute23 :=
    ben_pbb_shd.g_old_rec.pbb_attribute23;
  End If;
  If (p_rec.pbb_attribute24 = hr_api.g_varchar2) then
    p_rec.pbb_attribute24 :=
    ben_pbb_shd.g_old_rec.pbb_attribute24;
  End If;
  If (p_rec.pbb_attribute25 = hr_api.g_varchar2) then
    p_rec.pbb_attribute25 :=
    ben_pbb_shd.g_old_rec.pbb_attribute25;
  End If;
  If (p_rec.pbb_attribute26 = hr_api.g_varchar2) then
    p_rec.pbb_attribute26 :=
    ben_pbb_shd.g_old_rec.pbb_attribute26;
  End If;
  If (p_rec.pbb_attribute27 = hr_api.g_varchar2) then
    p_rec.pbb_attribute27 :=
    ben_pbb_shd.g_old_rec.pbb_attribute27;
  End If;
  If (p_rec.pbb_attribute28 = hr_api.g_varchar2) then
    p_rec.pbb_attribute28 :=
    ben_pbb_shd.g_old_rec.pbb_attribute28;
  End If;
  If (p_rec.pbb_attribute29 = hr_api.g_varchar2) then
    p_rec.pbb_attribute29 :=
    ben_pbb_shd.g_old_rec.pbb_attribute29;
  End If;
  If (p_rec.pbb_attribute30 = hr_api.g_varchar2) then
    p_rec.pbb_attribute30 :=
    ben_pbb_shd.g_old_rec.pbb_attribute30;
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
  p_rec			in out nocopy 	ben_pbb_shd.g_rec_type,
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
  ben_pbb_shd.lck
	(p_effective_date	 => p_effective_date,
      	 p_datetrack_mode	 => p_datetrack_mode,
      	 p_per_bnfts_bal_id	 => p_rec.per_bnfts_bal_id,
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
  ben_pbb_bus.update_validate
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
  p_per_bnfts_bal_id             in number,
  p_effective_start_date         out nocopy date,
  p_effective_end_date           out nocopy date,
  p_val                          in number           default hr_api.g_number,
  p_bnfts_bal_id                 in number           default hr_api.g_number,
  p_person_id                    in number           default hr_api.g_number,
  p_business_group_id            in number           default hr_api.g_number,
  p_pbb_attribute_category       in varchar2         default hr_api.g_varchar2,
  p_pbb_attribute1               in varchar2         default hr_api.g_varchar2,
  p_pbb_attribute2               in varchar2         default hr_api.g_varchar2,
  p_pbb_attribute3               in varchar2         default hr_api.g_varchar2,
  p_pbb_attribute4               in varchar2         default hr_api.g_varchar2,
  p_pbb_attribute5               in varchar2         default hr_api.g_varchar2,
  p_pbb_attribute6               in varchar2         default hr_api.g_varchar2,
  p_pbb_attribute7               in varchar2         default hr_api.g_varchar2,
  p_pbb_attribute8               in varchar2         default hr_api.g_varchar2,
  p_pbb_attribute9               in varchar2         default hr_api.g_varchar2,
  p_pbb_attribute10              in varchar2         default hr_api.g_varchar2,
  p_pbb_attribute11              in varchar2         default hr_api.g_varchar2,
  p_pbb_attribute12              in varchar2         default hr_api.g_varchar2,
  p_pbb_attribute13              in varchar2         default hr_api.g_varchar2,
  p_pbb_attribute14              in varchar2         default hr_api.g_varchar2,
  p_pbb_attribute15              in varchar2         default hr_api.g_varchar2,
  p_pbb_attribute16              in varchar2         default hr_api.g_varchar2,
  p_pbb_attribute17              in varchar2         default hr_api.g_varchar2,
  p_pbb_attribute18              in varchar2         default hr_api.g_varchar2,
  p_pbb_attribute19              in varchar2         default hr_api.g_varchar2,
  p_pbb_attribute20              in varchar2         default hr_api.g_varchar2,
  p_pbb_attribute21              in varchar2         default hr_api.g_varchar2,
  p_pbb_attribute22              in varchar2         default hr_api.g_varchar2,
  p_pbb_attribute23              in varchar2         default hr_api.g_varchar2,
  p_pbb_attribute24              in varchar2         default hr_api.g_varchar2,
  p_pbb_attribute25              in varchar2         default hr_api.g_varchar2,
  p_pbb_attribute26              in varchar2         default hr_api.g_varchar2,
  p_pbb_attribute27              in varchar2         default hr_api.g_varchar2,
  p_pbb_attribute28              in varchar2         default hr_api.g_varchar2,
  p_pbb_attribute29              in varchar2         default hr_api.g_varchar2,
  p_pbb_attribute30              in varchar2         default hr_api.g_varchar2,
  p_object_version_number        in out nocopy number,
  p_effective_date		 in date,
  p_datetrack_mode		 in varchar2
  ) is
--
  l_rec		ben_pbb_shd.g_rec_type;
  l_proc	varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  ben_pbb_shd.convert_args
  (
  p_per_bnfts_bal_id,
  null,
  null,
  p_val,
  p_bnfts_bal_id,
  p_person_id,
  p_business_group_id,
  p_pbb_attribute_category,
  p_pbb_attribute1,
  p_pbb_attribute2,
  p_pbb_attribute3,
  p_pbb_attribute4,
  p_pbb_attribute5,
  p_pbb_attribute6,
  p_pbb_attribute7,
  p_pbb_attribute8,
  p_pbb_attribute9,
  p_pbb_attribute10,
  p_pbb_attribute11,
  p_pbb_attribute12,
  p_pbb_attribute13,
  p_pbb_attribute14,
  p_pbb_attribute15,
  p_pbb_attribute16,
  p_pbb_attribute17,
  p_pbb_attribute18,
  p_pbb_attribute19,
  p_pbb_attribute20,
  p_pbb_attribute21,
  p_pbb_attribute22,
  p_pbb_attribute23,
  p_pbb_attribute24,
  p_pbb_attribute25,
  p_pbb_attribute26,
  p_pbb_attribute27,
  p_pbb_attribute28,
  p_pbb_attribute29,
  p_pbb_attribute30,
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
end ben_pbb_upd;

/
