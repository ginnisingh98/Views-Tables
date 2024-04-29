--------------------------------------------------------
--  DDL for Package Body BEN_DPNT_EDC_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_DPNT_EDC_INS" as
/* $Header: beedvrhi.pkb 120.0.12010000.2 2010/04/16 06:19:30 pvelvano noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_dpnt_edc_ins.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |----------------------------< dt_insert_dml >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure controls the actual dml insert logic for datetrack. The
--   functions of this procedure are as follows:
--   1) Get the object_version_number.
--   2) To set the effective start and end dates to the corresponding
--      validation start and end dates. Also, the object version number
--      record attribute is set.
--   3) To set and unset the g_api_dml status as required (as we are about to
--      perform dml).
--   4) To insert the row into the schema with the derived effective start
--      and end dates and the object version number.
--   5) To trap any constraint violations that may have occurred.
--   6) To raise any other errors.
--
-- Prerequisites:
--   This is an internal private procedure which must be called from the
--   insert_dml and pre_update (logic permitting) procedure and must have
--   all mandatory arguments set.
--
-- In Parameters:
--   A Pl/Sql record structre.
--
-- Post Success:
--   The specified row will be inserted into the schema.
--
-- Post Failure:
--   On the insert dml failure it is important to note that we always reset the
--   g_api_dml status to false.
--   If a check or unique integrity constraint violation is raised the
--   constraint_error procedure will be called.
--   If any other error is reported, the error will be raised after the
--   g_api_dml status is reset.
--
-- Developer Implementation Notes:
--   This is an internal datetrack maintenance procedure which should
--   not be modified in anyway.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure dt_insert_dml
	(p_rec 			 in out nocopy ben_dpnt_edc_shd.g_rec_type,
	 p_effective_date	 in	date,
	 p_datetrack_mode	 in	varchar2,
	 p_validation_start_date in	date,
	 p_validation_end_date	 in	date) is
--
-- Cursor to select 'old' created AOL who column values
--
  Cursor C_sel1 is
    Select t.created_by,
           t.creation_date
    from   ben_dpnt_eligy_crit_values_f t
    where  t.dpnt_eligy_crit_values_id = p_rec.dpnt_eligy_crit_values_id
    and    t.effective_start_date = ben_dpnt_edc_shd.g_old_rec.effective_start_date
    and    t.effective_end_date   = (p_validation_start_date - 1);
--
  l_proc		varchar2(72) := g_package||'dt_insert_dml';
  l_created_by          ben_dpnt_eligy_crit_values_f.created_by%TYPE;
  l_creation_date       ben_dpnt_eligy_crit_values_f.creation_date%TYPE;
  l_last_update_date   	ben_dpnt_eligy_crit_values_f.last_update_date%TYPE;
  l_last_updated_by     ben_dpnt_eligy_crit_values_f.last_updated_by%TYPE;
  l_last_update_login   ben_dpnt_eligy_crit_values_f.last_update_login%TYPE;
--
Begin
   hr_utility.set_location('Entering :'||l_proc,10);
  --
  -- Get the object version number for the insert
  --
  p_rec.object_version_number :=
      dt_api.get_object_version_number
        (p_base_table_name  => 'ben_dpnt_eligy_crit_values_f',
         p_base_key_column  => 'dpnt_eligy_crit_values_id',
         p_base_key_value   =>  p_rec.dpnt_eligy_crit_values_id
         );
  --
  -- Set the effective start and end dates to the corresponding
  -- validation start and end dates
  --
  p_rec.effective_start_date := p_validation_start_date;
  p_rec.effective_end_date   := p_validation_end_date;
  --
  -- If the datetrack_mode is not INSERT then we must populate the WHO
  -- columns with the 'old' creation values and 'new' updated values.
  --
  If (p_datetrack_mode <> 'INSERT') then
    hr_utility.set_location(l_proc, 10);
    --
    -- Select the 'old' created values
    --
    Open C_Sel1;
    Fetch C_Sel1 Into l_created_by, l_creation_date;
    If C_Sel1%notfound Then
      --
      -- The previous 'old' created row has not been found. We need
      -- to error as an internal datetrack problem exists.
      --
      Close C_Sel1;
      hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
      hr_utility.set_message_token('PROCEDURE', l_proc);
      hr_utility.set_message_token('STEP','10');
      hr_utility.raise_error;
    End If;
    Close C_Sel1;
    --
    -- Set the AOL updated WHO values
    --
    l_last_update_date   := sysdate;
    l_last_updated_by    := fnd_global.user_id;
    l_last_update_login  := fnd_global.login_id;
  End If;
  --
  ben_dpnt_edc_shd.g_api_dml  :=  true;     -- Set the api dml status
  --
  -- Insert the row into ben_dpnt_eligy_crit_values_f
  --
  Insert into ben_dpnt_eligy_crit_values_f
  (
  dpnt_eligy_crit_values_id,
  dpnt_cvg_eligy_prfl_id,
  eligy_criteria_dpnt_id,
  effective_start_date,
  effective_end_date,
  ordr_num,
  number_value1,
  number_value2,
  char_value1,
  char_value2,
  date_value1,
  date_value2,
  excld_flag,
  business_group_id,
  edc_attribute_category,
  edc_attribute1,
  edc_attribute2,
  edc_attribute3,
  edc_attribute4,
  edc_attribute5,
  edc_attribute6,
  edc_attribute7,
  edc_attribute8,
  edc_attribute9,
  edc_attribute10,
  edc_attribute11,
  edc_attribute12,
  edc_attribute13,
  edc_attribute14,
  edc_attribute15,
  edc_attribute16,
  edc_attribute17,
  edc_attribute18,
  edc_attribute19,
  edc_attribute20,
  edc_attribute21,
  edc_attribute22,
  edc_attribute23,
  edc_attribute24,
  edc_attribute25,
  edc_attribute26,
  edc_attribute27,
  edc_attribute28,
  edc_attribute29,
  edc_attribute30,
  object_version_number,
  created_by,
  creation_date,
  last_update_date,
  last_updated_by,
  last_update_login,
  char_value3,
  char_value4,
  number_value3,
  number_value4,
  date_value3,
  date_value4
  )
  values
  (
  p_rec.dpnt_eligy_crit_values_id,
  p_rec.dpnt_cvg_eligy_prfl_id,
  p_rec.eligy_criteria_dpnt_id,
  p_rec.effective_start_date,
  p_rec.effective_end_date,
  p_rec.ordr_num,
  p_rec.number_value1,
  p_rec.number_value2,
  p_rec.char_value1,
  p_rec.char_value2,
  p_rec.date_value1,
  p_rec.date_value2,
  p_rec.excld_flag,
  p_rec.business_group_id,
  p_rec.edc_attribute_category,
  p_rec.edc_attribute1,
  p_rec.edc_attribute2,
  p_rec.edc_attribute3,
  p_rec.edc_attribute4,
  p_rec.edc_attribute5,
  p_rec.edc_attribute6,
  p_rec.edc_attribute7,
  p_rec.edc_attribute8,
  p_rec.edc_attribute9,
  p_rec.edc_attribute10,
  p_rec.edc_attribute11,
  p_rec.edc_attribute12,
  p_rec.edc_attribute13,
  p_rec.edc_attribute14,
  p_rec.edc_attribute15,
  p_rec.edc_attribute16,
  p_rec.edc_attribute17,
  p_rec.edc_attribute18,
  p_rec.edc_attribute19,
  p_rec.edc_attribute20,
  p_rec.edc_attribute21,
  p_rec.edc_attribute22,
  p_rec.edc_attribute23,
  p_rec.edc_attribute24,
  p_rec.edc_attribute25,
  p_rec.edc_attribute26,
  p_rec.edc_attribute27,
  p_rec.edc_attribute28,
  p_rec.edc_attribute29,
  p_rec.edc_attribute30,
  p_rec.object_version_number,
  l_created_by,
  l_creation_date,
  l_last_update_date,
  l_last_updated_by,
  l_last_update_login,
  p_rec.char_value3,
  p_rec.char_value4,
  p_rec.number_value3,
  p_rec.number_value4,
  p_rec.date_value3,
  p_rec.date_value4
  );
  --
  ben_dpnt_edc_shd.g_api_dml := false;   -- Unset the api dml status
  hr_utility.set_location(' Leaving:'||l_proc, 15);
--
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    ben_dpnt_edc_shd.g_api_dml := false;   -- Unset the api dml status
    ben_dpnt_edc_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    ben_dpnt_edc_shd.g_api_dml := false;   -- Unset the api dml status
    ben_dpnt_edc_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    ben_dpnt_edc_shd.g_api_dml := false;   -- Unset the api dml status
    Raise;
End dt_insert_dml;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< insert_dml >------------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_dml
	(p_rec 			 in out nocopy ben_dpnt_edc_shd.g_rec_type,
	 p_effective_date	 in	date,
	 p_datetrack_mode	 in	varchar2,
	 p_validation_start_date in	date,
	 p_validation_end_date	 in	date) is
--
  l_proc	varchar2(72) := g_package||'insert_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  dt_insert_dml(p_rec			=> p_rec,
		p_effective_date	=> p_effective_date,
		p_datetrack_mode	=> p_datetrack_mode,
       		p_validation_start_date	=> p_validation_start_date,
		p_validation_end_date	=> p_validation_end_date);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_dml;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< pre_insert >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This private procedure contains any processing which is required before
--   the insert dml. Presently, if the entity has a corresponding primary
--   key which is maintained by an associating sequence, the primary key for
--   the entity will be populated with the next sequence value in
--   preparation for the insert dml.
--   Also, if comments are defined for this entity, the comments insert
--   logic will also be called, generating a comment_id if required.
--
-- Prerequisites:
--   This is an internal procedure which is called from the ins procedure.
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
--   Any pre-processing required before the insert dml is issued should be
--   coded within this procedure. As stated above, a good example is the
--   generation of a primary key number via a corresponding sequence.
--   It is important to note that any 3rd party maintenance should be reviewed
--   before placing in this procedure.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure pre_insert
	(p_rec  			in out nocopy ben_dpnt_edc_shd.g_rec_type,
	 p_effective_date		in date,
	 p_datetrack_mode		in varchar2,
	 p_validation_start_date	in date,
	 p_validation_end_date		in date) is
--
  l_proc	varchar2(72) := g_package||'pre_insert';
--
  Cursor C_Sel1 is select ben_dpnt_eligy_crit_values_f_s.nextval from sys.dual;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  -- Select the next sequence number
  --
  Open C_Sel1;
  Fetch C_Sel1 Into p_rec.dpnt_eligy_crit_values_id;
  Close C_Sel1;
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End pre_insert;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< post_insert >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This private procedure contains any processing which is required after the
--   insert dml.
--
-- Prerequisites:
--   This is an internal procedure which is called from the ins procedure.
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
--   Any post-processing required after the insert dml is issued should be
--   coded within this procedure. It is important to note that any 3rd party
--   maintenance should be reviewed before placing in this procedure.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure post_insert
	(p_rec 			 in ben_dpnt_edc_shd.g_rec_type,
	 p_effective_date	 in date,
	 p_datetrack_mode	 in varchar2,
	 p_validation_start_date in date,
	 p_validation_end_date	 in date) is
--
  l_proc	varchar2(72) := g_package||'post_insert';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
--
 --
  -- Start of API User Hook for post_insert.
  --
  begin
    --
    ben_dpnt_edc_rki.after_insert
    (
     p_dpnt_eligy_crit_values_id         	=>   p_rec.dpnt_eligy_crit_values_id
    ,p_dpnt_cvg_eligy_prfl_id                	=>   p_rec.dpnt_cvg_eligy_prfl_id
    ,p_eligy_criteria_dpnt_id            	=>   p_rec.eligy_criteria_dpnt_id
    ,p_effective_start_date         	=>   p_rec.effective_start_date
    ,p_effective_end_date           	=>   p_rec.effective_end_date
    ,p_ordr_num                     	=>   p_rec.ordr_num
    ,p_number_value1                	=>   p_rec.number_value1
    ,p_number_value2                	=>   p_rec.number_value2
    ,p_char_value1                  	=>   p_rec.char_value1
    ,p_char_value2                  	=>   p_rec.char_value2
    ,p_date_value1                  	=>   p_rec.date_value1
    ,p_date_value2                  	=>   p_rec.date_value2
    ,p_excld_flag                       =>   p_rec.excld_flag
    ,p_business_group_id            	=>   p_rec.business_group_id
    ,p_edc_attribute_category       	=>   p_rec.edc_attribute_category
    ,p_edc_attribute1               	=>   p_rec.edc_attribute1
    ,p_edc_attribute2               	=>   p_rec.edc_attribute2
    ,p_edc_attribute3               	=>   p_rec.edc_attribute3
    ,p_edc_attribute4               	=>   p_rec.edc_attribute4
    ,p_edc_attribute5               	=>   p_rec.edc_attribute5
    ,p_edc_attribute6               	=>   p_rec.edc_attribute6
    ,p_edc_attribute7               	=>   p_rec.edc_attribute7
    ,p_edc_attribute8               	=>   p_rec.edc_attribute8
    ,p_edc_attribute9               	=>   p_rec.edc_attribute9
    ,p_edc_attribute10              	=>   p_rec.edc_attribute10
    ,p_edc_attribute11              	=>   p_rec.edc_attribute11
    ,p_edc_attribute12              	=>   p_rec.edc_attribute12
    ,p_edc_attribute13              	=>   p_rec.edc_attribute13
    ,p_edc_attribute14              	=>   p_rec.edc_attribute14
    ,p_edc_attribute15              	=>   p_rec.edc_attribute15
    ,p_edc_attribute16              	=>   p_rec.edc_attribute16
    ,p_edc_attribute17              	=>   p_rec.edc_attribute17
    ,p_edc_attribute18              	=>   p_rec.edc_attribute18
    ,p_edc_attribute19              	=>   p_rec.edc_attribute19
    ,p_edc_attribute20              	=>   p_rec.edc_attribute20
    ,p_edc_attribute21              	=>   p_rec.edc_attribute21
    ,p_edc_attribute22              	=>   p_rec.edc_attribute22
    ,p_edc_attribute23              	=>   p_rec.edc_attribute23
    ,p_edc_attribute24              	=>   p_rec.edc_attribute24
    ,p_edc_attribute25              	=>   p_rec.edc_attribute25
    ,p_edc_attribute26              	=>   p_rec.edc_attribute26
    ,p_edc_attribute27              	=>   p_rec.edc_attribute27
    ,p_edc_attribute28              	=>   p_rec.edc_attribute28
    ,p_edc_attribute29              	=>   p_rec.edc_attribute29
    ,p_edc_attribute30              	=>   p_rec.edc_attribute30
    ,p_object_version_number        	=>   p_rec.object_version_number
    ,p_effective_date               	=>   p_effective_date
    ,p_validation_start_date        	=>   p_validation_start_date
    ,p_validation_end_date          	=>   p_validation_end_date
    ,p_char_value3                      =>   p_rec.char_value3
    ,p_char_value4     			=>   p_rec.char_value4
    ,p_number_value3   			=>   p_rec.number_value3
    ,p_number_value4   			=>   p_rec.number_value4
    ,p_date_value3			=>   p_rec.date_value3
    ,p_date_value4     			=>   p_rec.date_value4
   );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'ben_dpnt_eligy_crit_values_f'
        ,p_hook_type   => 'AI');
      --
  end;
  --
  -- End of API User Hook for post_insert.
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End post_insert;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< ins_lck >--------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   The ins_lck process has one main function to perform. When inserting
--   a datetracked row, we must validate the DT mode.
--   be manipulated.
--
-- Prerequisites:
--   This procedure can only be called for the datetrack mode of INSERT.
--
-- In Parameters:
--
-- Post Success:
--   On successful completion of the ins_lck process the parental
--   datetracked rows will be locked providing the p_enforce_foreign_locking
--   argument value is TRUE.
--   If the p_enforce_foreign_locking argument value is FALSE then the
--   parential rows are not locked.
--
-- Post Failure:
--   The Lck process can fail for:
--   1) When attempting to lock the row the row could already be locked by
--      another user. This will raise the HR_Api.Object_Locked exception.
--   2) When attempting to the lock the parent which doesn't exist.
--      For the entity to be locked the parent must exist!
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure ins_lck
	(p_effective_date	 in  date,
	 p_datetrack_mode	 in  varchar2,
	 p_rec	 		     in  ben_dpnt_edc_shd.g_rec_type,
	 p_validation_start_date out nocopy date,
	 p_validation_end_date	 out nocopy date) is
--
  l_proc		  varchar2(72) := g_package||'ins_lck';
  l_validation_start_date date;
  l_validation_end_date	  date;
--
Begin
     hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Validate the datetrack mode mode getting the validation start
  -- and end dates for the specified datetrack operation.
  --
  dt_api.validate_dt_mode
	(p_effective_date	   => p_effective_date,
	 p_datetrack_mode	   => p_datetrack_mode,
	 p_base_table_name	   => 'ben_dpnt_eligy_crit_values_f',
	 p_base_key_column	   => 'dpnt_eligy_crit_values_id',
	 p_base_key_value 	   => p_rec.dpnt_eligy_crit_values_id,
--	 p_parent_table_name1      => 'ben_eligy_criteria',
--	 p_parent_key_column1      => 'eligy_criteria_dpnt_id',
--	 p_parent_key_value1       => p_rec.eligy_criteria_dpnt_id,
	 p_parent_table_name2      => 'ben_dpnt_cvg_eligy_prfl_f',
	 p_parent_key_column2      =>  'dpnt_cvg_eligy_prfl_id',
	 p_parent_key_value2       =>  p_rec.dpnt_cvg_eligy_prfl_id,
         p_enforce_foreign_locking => true,
	 p_validation_start_date   => l_validation_start_date,
 	 p_validation_end_date	   => l_validation_end_date);
  --
  -- Set the validation start and end date OUT arguments
  --
  p_validation_start_date := l_validation_start_date;
  p_validation_end_date   := l_validation_end_date;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
End ins_lck;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (
  p_rec		   in out nocopy ben_dpnt_edc_shd.g_rec_type,
  p_effective_date in     date
  ) is
--
  l_proc			varchar2(72) := g_package||'ins';
  l_datetrack_mode		varchar2(30) := 'INSERT';
  l_validation_start_date	date;
  l_validation_end_date		date;
--
begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call the lock operation
  --
  ins_lck
	(p_effective_date	 => p_effective_date,
	 p_datetrack_mode	 => l_datetrack_mode,
	 p_rec	 		 => p_rec,
	 p_validation_start_date => l_validation_start_date,
	 p_validation_end_date	 => l_validation_end_date);
  --
  -- Call the supporting insert validate operations
  --
  ben_dpnt_edc_bus.insert_validate
	(p_rec			 => p_rec,
	 p_effective_date	 => p_effective_date,
	 p_datetrack_mode	 => l_datetrack_mode,
	 p_validation_start_date => l_validation_start_date,
	 p_validation_end_date	 => l_validation_end_date);
  --
  -- Call the supporting pre-insert operation
  --
  pre_insert
 	(p_rec			 => p_rec,
	 p_effective_date	 => p_effective_date,
	 p_datetrack_mode	 => l_datetrack_mode,
	 p_validation_start_date => l_validation_start_date,
	 p_validation_end_date	 => l_validation_end_date);
  --
  -- Insert the row
  --
  insert_dml
 	(p_rec			 => p_rec,
	 p_effective_date	 => p_effective_date,
	 p_datetrack_mode	 => l_datetrack_mode,
	 p_validation_start_date => l_validation_start_date,
	 p_validation_end_date	 => l_validation_end_date);
  --
  -- Call the supporting post-insert operation
  --
  post_insert
 	(p_rec			 => p_rec,
	 p_effective_date	 => p_effective_date,
	 p_datetrack_mode	 => l_datetrack_mode,
	 p_validation_start_date => l_validation_start_date,
	 p_validation_end_date	 => l_validation_end_date);
end ins;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (
   p_dpnt_eligy_crit_values_id         Out nocopy Number
  ,p_dpnt_cvg_eligy_prfl_id                In  Number       default NULL
  ,p_eligy_criteria_dpnt_id            In  Number       default NULL
  ,p_effective_start_date         Out nocopy Date
  ,p_effective_end_date           Out nocopy Date
  ,p_ordr_num                     In  Number       default NULL
  ,p_number_value1                In  Number       default NULL
  ,p_number_value2                In  Number       default NULL
  ,p_char_value1                  In  Varchar2     default NULL
  ,p_char_value2                  In  Varchar2     default NULL
  ,p_date_value1                  In  Date         default NULL
  ,p_date_value2                  In  Date         default NULL
  ,p_excld_flag                   In  Varchar2     default 'N'
  ,p_business_group_id            In  Number       default NULL
  ,p_edc_attribute_category       In  Varchar2     default NULL
  ,p_edc_attribute1               In  Varchar2     default NULL
  ,p_edc_attribute2               In  Varchar2     default NULL
  ,p_edc_attribute3               In  Varchar2     default NULL
  ,p_edc_attribute4               In  Varchar2     default NULL
  ,p_edc_attribute5               In  Varchar2     default NULL
  ,p_edc_attribute6               In  Varchar2     default NULL
  ,p_edc_attribute7               In  Varchar2     default NULL
  ,p_edc_attribute8               In  Varchar2     default NULL
  ,p_edc_attribute9               In  Varchar2     default NULL
  ,p_edc_attribute10              In  Varchar2     default NULL
  ,p_edc_attribute11              In  Varchar2     default NULL
  ,p_edc_attribute12              In  Varchar2     default NULL
  ,p_edc_attribute13              In  Varchar2     default NULL
  ,p_edc_attribute14              In  Varchar2     default NULL
  ,p_edc_attribute15              In  Varchar2     default NULL
  ,p_edc_attribute16              In  Varchar2     default NULL
  ,p_edc_attribute17              In  Varchar2     default NULL
  ,p_edc_attribute18              In  Varchar2     default NULL
  ,p_edc_attribute19              In  Varchar2     default NULL
  ,p_edc_attribute20              In  Varchar2     default NULL
  ,p_edc_attribute21              In  Varchar2     default NULL
  ,p_edc_attribute22              In  Varchar2     default NULL
  ,p_edc_attribute23              In  Varchar2     default NULL
  ,p_edc_attribute24              In  Varchar2     default NULL
  ,p_edc_attribute25              In  Varchar2     default NULL
  ,p_edc_attribute26              In  Varchar2     default NULL
  ,p_edc_attribute27              In  Varchar2     default NULL
  ,p_edc_attribute28              In  Varchar2     default NULL
  ,p_edc_attribute29              In  Varchar2     default NULL
  ,p_edc_attribute30              In  Varchar2     default NULL
  ,p_object_version_number        Out nocopy Number
  ,p_effective_date               In  Date
  ,p_char_value3                  In  Varchar2     default NULL
  ,p_char_value4     	          In  Varchar2     default NULL
  ,p_number_value3   	          In  Number       default NULL
  ,p_number_value4   	          In  Number       default NULL
  ,p_date_value3	          In  Date         default NULL
  ,p_date_value4     	          In  Date         default NULL
  ) is
--
  l_rec		ben_dpnt_edc_shd.g_rec_type;
  l_proc	varchar2(72) := g_package||'ins';
--

Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  ben_dpnt_edc_shd.convert_args
  (
  NULL,
  p_dpnt_cvg_eligy_prfl_id,
  p_eligy_criteria_dpnt_id,
  NULL,
  NULL,
  p_ordr_num,
  p_number_value1,
  p_number_value2,
  p_char_value1,
  p_char_value2,
  p_date_value1,
  p_date_value2,
  p_excld_flag,
  p_business_group_id,
  p_edc_attribute_category,
  p_edc_attribute1,
  p_edc_attribute2,
  p_edc_attribute3,
  p_edc_attribute4,
  p_edc_attribute5,
  p_edc_attribute6,
  p_edc_attribute7,
  p_edc_attribute8,
  p_edc_attribute9,
  p_edc_attribute10,
  p_edc_attribute11,
  p_edc_attribute12,
  p_edc_attribute13,
  p_edc_attribute14,
  p_edc_attribute15,
  p_edc_attribute16,
  p_edc_attribute17,
  p_edc_attribute18,
  p_edc_attribute19,
  p_edc_attribute20,
  p_edc_attribute21,
  p_edc_attribute22,
  p_edc_attribute23,
  p_edc_attribute24,
  p_edc_attribute25,
  p_edc_attribute26,
  p_edc_attribute27,
  p_edc_attribute28,
  p_edc_attribute29,
  p_edc_attribute30,
  NULL,
  p_char_value3,
  p_char_value4,
  p_number_value3,
  p_number_value4,
  p_date_value3,
  p_date_value4
  );
  --
  -- Having converted the arguments into the ben_edc_rec
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  ins(l_rec, p_effective_date);
  --
  -- Set the OUT arguments.
  --
  p_dpnt_eligy_crit_values_id    := l_rec.dpnt_eligy_crit_values_id;
  p_effective_start_date  	:= l_rec.effective_start_date;
  p_effective_end_date    	:= l_rec.effective_end_date;
  p_object_version_number 	:= l_rec.object_version_number;
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
end ins;
--
end ben_dpnt_edc_ins;

/
