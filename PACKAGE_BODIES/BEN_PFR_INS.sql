--------------------------------------------------------
--  DDL for Package Body BEN_PFR_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PFR_INS" as
/* $Header: bepfrrhi.pkb 120.0 2005/05/28 10:43:33 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_pfr_ins.';  -- Global package name
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
	(p_rec 			 in out nocopy ben_pfr_shd.g_rec_type,
	 p_effective_date	 in	date,
	 p_datetrack_mode	 in	varchar2,
	 p_validation_start_date in	date,
	 p_validation_end_date	 in	date) is
--
-- Cursor to select 'old' created AOL who column values
--
  Cursor C_Sel1 Is
    select t.created_by,
           t.creation_date
    from   ben_pct_fl_tm_rt_f t
    where  t.pct_fl_tm_rt_id       = p_rec.pct_fl_tm_rt_id
    and    t.effective_start_date =
             ben_pfr_shd.g_old_rec.effective_start_date
    and    t.effective_end_date   = (p_validation_start_date - 1);
--
  l_proc		varchar2(72) := g_package||'dt_insert_dml';
  l_created_by          ben_pct_fl_tm_rt_f.created_by%TYPE;
  l_creation_date       ben_pct_fl_tm_rt_f.creation_date%TYPE;
  l_last_update_date   	ben_pct_fl_tm_rt_f.last_update_date%TYPE;
  l_last_updated_by     ben_pct_fl_tm_rt_f.last_updated_by%TYPE;
  l_last_update_login   ben_pct_fl_tm_rt_f.last_update_login%TYPE;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Get the object version number for the insert
  --
  p_rec.object_version_number :=
    dt_api.get_object_version_number
	(p_base_table_name => 'ben_pct_fl_tm_rt_f',
	 p_base_key_column => 'pct_fl_tm_rt_id',
	 p_base_key_value  => p_rec.pct_fl_tm_rt_id);
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
  ben_pfr_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Insert the row into: ben_pct_fl_tm_rt_f
  --
  insert into ben_pct_fl_tm_rt_f
  (	pct_fl_tm_rt_id,
	effective_start_date,
	effective_end_date,
	business_group_id,
	vrbl_rt_prfl_id,
	pct_fl_tm_fctr_id,
	excld_flag,
	ordr_num,
	pfr_attribute_category,
	pfr_attribute1,
	pfr_attribute2,
	pfr_attribute3,
	pfr_attribute4,
	pfr_attribute5,
	pfr_attribute6,
	pfr_attribute7,
	pfr_attribute8,
	pfr_attribute9,
	pfr_attribute10,
	pfr_attribute11,
	pfr_attribute12,
	pfr_attribute13,
	pfr_attribute14,
	pfr_attribute15,
	pfr_attribute16,
	pfr_attribute17,
	pfr_attribute18,
	pfr_attribute19,
	pfr_attribute20,
	pfr_attribute21,
	pfr_attribute22,
	pfr_attribute23,
	pfr_attribute24,
	pfr_attribute25,
	pfr_attribute26,
	pfr_attribute27,
	pfr_attribute28,
	pfr_attribute29,
	pfr_attribute30,
	object_version_number
   	, created_by,
   	creation_date,
   	last_update_date,
   	last_updated_by,
   	last_update_login
  )
  Values
  (	p_rec.pct_fl_tm_rt_id,
	p_rec.effective_start_date,
	p_rec.effective_end_date,
	p_rec.business_group_id,
	p_rec.vrbl_rt_prfl_id,
	p_rec.pct_fl_tm_fctr_id,
	p_rec.excld_flag,
	p_rec.ordr_num,
	p_rec.pfr_attribute_category,
	p_rec.pfr_attribute1,
	p_rec.pfr_attribute2,
	p_rec.pfr_attribute3,
	p_rec.pfr_attribute4,
	p_rec.pfr_attribute5,
	p_rec.pfr_attribute6,
	p_rec.pfr_attribute7,
	p_rec.pfr_attribute8,
	p_rec.pfr_attribute9,
	p_rec.pfr_attribute10,
	p_rec.pfr_attribute11,
	p_rec.pfr_attribute12,
	p_rec.pfr_attribute13,
	p_rec.pfr_attribute14,
	p_rec.pfr_attribute15,
	p_rec.pfr_attribute16,
	p_rec.pfr_attribute17,
	p_rec.pfr_attribute18,
	p_rec.pfr_attribute19,
	p_rec.pfr_attribute20,
	p_rec.pfr_attribute21,
	p_rec.pfr_attribute22,
	p_rec.pfr_attribute23,
	p_rec.pfr_attribute24,
	p_rec.pfr_attribute25,
	p_rec.pfr_attribute26,
	p_rec.pfr_attribute27,
	p_rec.pfr_attribute28,
	p_rec.pfr_attribute29,
	p_rec.pfr_attribute30,
	p_rec.object_version_number
	, l_created_by,
   	l_creation_date,
   	l_last_update_date,
   	l_last_updated_by,
   	l_last_update_login
  );
  --
  ben_pfr_shd.g_api_dml := false;   -- Unset the api dml status
  hr_utility.set_location(' Leaving:'||l_proc, 15);
--
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    ben_pfr_shd.g_api_dml := false;   -- Unset the api dml status
    ben_pfr_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    ben_pfr_shd.g_api_dml := false;   -- Unset the api dml status
    ben_pfr_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    ben_pfr_shd.g_api_dml := false;   -- Unset the api dml status
    Raise;
End dt_insert_dml;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< insert_dml >------------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_dml
	(p_rec 			 in out nocopy ben_pfr_shd.g_rec_type,
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
	(p_rec  			in out nocopy ben_pfr_shd.g_rec_type,
	 p_effective_date		in date,
	 p_datetrack_mode		in varchar2,
	 p_validation_start_date	in date,
	 p_validation_end_date		in date) is
--
  l_proc	varchar2(72) := g_package||'pre_insert';
  cursor c1 is select ben_pct_fl_tm_rt_f_s.nextval
               from   sys.dual;
--
--
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  open c1;
  fetch c1 into p_rec.pct_fl_tm_rt_id;
  close c1;
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
	(p_rec 			 in ben_pfr_shd.g_rec_type,
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
    ben_pfr_rki.after_insert
      (
  p_pct_fl_tm_rt_id               =>p_rec.pct_fl_tm_rt_id
 ,p_effective_start_date          =>p_rec.effective_start_date
 ,p_effective_end_date            =>p_rec.effective_end_date
 ,p_business_group_id             =>p_rec.business_group_id
 ,p_vrbl_rt_prfl_id               =>p_rec.vrbl_rt_prfl_id
 ,p_pct_fl_tm_fctr_id             =>p_rec.pct_fl_tm_fctr_id
 ,p_excld_flag                    =>p_rec.excld_flag
 ,p_ordr_num                      =>p_rec.ordr_num
 ,p_pfr_attribute_category        =>p_rec.pfr_attribute_category
 ,p_pfr_attribute1                =>p_rec.pfr_attribute1
 ,p_pfr_attribute2                =>p_rec.pfr_attribute2
 ,p_pfr_attribute3                =>p_rec.pfr_attribute3
 ,p_pfr_attribute4                =>p_rec.pfr_attribute4
 ,p_pfr_attribute5                =>p_rec.pfr_attribute5
 ,p_pfr_attribute6                =>p_rec.pfr_attribute6
 ,p_pfr_attribute7                =>p_rec.pfr_attribute7
 ,p_pfr_attribute8                =>p_rec.pfr_attribute8
 ,p_pfr_attribute9                =>p_rec.pfr_attribute9
 ,p_pfr_attribute10               =>p_rec.pfr_attribute10
 ,p_pfr_attribute11               =>p_rec.pfr_attribute11
 ,p_pfr_attribute12               =>p_rec.pfr_attribute12
 ,p_pfr_attribute13               =>p_rec.pfr_attribute13
 ,p_pfr_attribute14               =>p_rec.pfr_attribute14
 ,p_pfr_attribute15               =>p_rec.pfr_attribute15
 ,p_pfr_attribute16               =>p_rec.pfr_attribute16
 ,p_pfr_attribute17               =>p_rec.pfr_attribute17
 ,p_pfr_attribute18               =>p_rec.pfr_attribute18
 ,p_pfr_attribute19               =>p_rec.pfr_attribute19
 ,p_pfr_attribute20               =>p_rec.pfr_attribute20
 ,p_pfr_attribute21               =>p_rec.pfr_attribute21
 ,p_pfr_attribute22               =>p_rec.pfr_attribute22
 ,p_pfr_attribute23               =>p_rec.pfr_attribute23
 ,p_pfr_attribute24               =>p_rec.pfr_attribute24
 ,p_pfr_attribute25               =>p_rec.pfr_attribute25
 ,p_pfr_attribute26               =>p_rec.pfr_attribute26
 ,p_pfr_attribute27               =>p_rec.pfr_attribute27
 ,p_pfr_attribute28               =>p_rec.pfr_attribute28
 ,p_pfr_attribute29               =>p_rec.pfr_attribute29
 ,p_pfr_attribute30               =>p_rec.pfr_attribute30
 ,p_object_version_number         =>p_rec.object_version_number
 ,p_effective_date                =>p_effective_date
 ,p_validation_start_date         =>p_validation_start_date
 ,p_validation_end_date           =>p_validation_end_date
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'ben_pct_fl_tm_rt_f'
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
	 p_rec	 		 in  ben_pfr_shd.g_rec_type,
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
	 p_base_table_name	   => 'ben_pct_fl_tm_rt_f',
	 p_base_key_column	   => 'pct_fl_tm_rt_id',
	 p_base_key_value 	   => p_rec.pct_fl_tm_rt_id,
         p_parent_table_name1      => 'ben_vrbl_rt_prfl_f',
         p_parent_key_column1      => 'vrbl_rt_prfl_id',
         p_parent_key_value1       => p_rec.vrbl_rt_prfl_id,
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
  p_rec		   in out nocopy ben_pfr_shd.g_rec_type,
  p_effective_date in     date
  ) is
--
  l_proc			varchar2(72) := g_package||'ins';
  l_datetrack_mode		varchar2(30) := 'INSERT';
  l_validation_start_date	date;
  l_validation_end_date		date;
--
Begin
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
  ben_pfr_bus.insert_validate
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
  p_pct_fl_tm_rt_id              out nocopy number,
  p_effective_start_date         out nocopy date,
  p_effective_end_date           out nocopy date,
  p_business_group_id            in number,
  p_vrbl_rt_prfl_id              in number,
  p_pct_fl_tm_fctr_id            in number,
  p_excld_flag                   in varchar2,
  p_ordr_num                     in number           default null,
  p_pfr_attribute_category       in varchar2         default null,
  p_pfr_attribute1               in varchar2         default null,
  p_pfr_attribute2               in varchar2         default null,
  p_pfr_attribute3               in varchar2         default null,
  p_pfr_attribute4               in varchar2         default null,
  p_pfr_attribute5               in varchar2         default null,
  p_pfr_attribute6               in varchar2         default null,
  p_pfr_attribute7               in varchar2         default null,
  p_pfr_attribute8               in varchar2         default null,
  p_pfr_attribute9               in varchar2         default null,
  p_pfr_attribute10              in varchar2         default null,
  p_pfr_attribute11              in varchar2         default null,
  p_pfr_attribute12              in varchar2         default null,
  p_pfr_attribute13              in varchar2         default null,
  p_pfr_attribute14              in varchar2         default null,
  p_pfr_attribute15              in varchar2         default null,
  p_pfr_attribute16              in varchar2         default null,
  p_pfr_attribute17              in varchar2         default null,
  p_pfr_attribute18              in varchar2         default null,
  p_pfr_attribute19              in varchar2         default null,
  p_pfr_attribute20              in varchar2         default null,
  p_pfr_attribute21              in varchar2         default null,
  p_pfr_attribute22              in varchar2         default null,
  p_pfr_attribute23              in varchar2         default null,
  p_pfr_attribute24              in varchar2         default null,
  p_pfr_attribute25              in varchar2         default null,
  p_pfr_attribute26              in varchar2         default null,
  p_pfr_attribute27              in varchar2         default null,
  p_pfr_attribute28              in varchar2         default null,
  p_pfr_attribute29              in varchar2         default null,
  p_pfr_attribute30              in varchar2         default null,
  p_object_version_number        out nocopy number,
  p_effective_date		 in date
  ) is
--
  l_rec		ben_pfr_shd.g_rec_type;
  l_proc	varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  ben_pfr_shd.convert_args
  (
  null,
  null,
  null,
  p_business_group_id,
  p_vrbl_rt_prfl_id,
  p_pct_fl_tm_fctr_id,
  p_excld_flag,
  p_ordr_num,
  p_pfr_attribute_category,
  p_pfr_attribute1,
  p_pfr_attribute2,
  p_pfr_attribute3,
  p_pfr_attribute4,
  p_pfr_attribute5,
  p_pfr_attribute6,
  p_pfr_attribute7,
  p_pfr_attribute8,
  p_pfr_attribute9,
  p_pfr_attribute10,
  p_pfr_attribute11,
  p_pfr_attribute12,
  p_pfr_attribute13,
  p_pfr_attribute14,
  p_pfr_attribute15,
  p_pfr_attribute16,
  p_pfr_attribute17,
  p_pfr_attribute18,
  p_pfr_attribute19,
  p_pfr_attribute20,
  p_pfr_attribute21,
  p_pfr_attribute22,
  p_pfr_attribute23,
  p_pfr_attribute24,
  p_pfr_attribute25,
  p_pfr_attribute26,
  p_pfr_attribute27,
  p_pfr_attribute28,
  p_pfr_attribute29,
  p_pfr_attribute30,
  null
  );
  --
  -- Having converted the arguments into the ben_pfr_rec
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  ins(l_rec, p_effective_date);
  --
  -- Set the OUT arguments.
  --
  p_pct_fl_tm_rt_id        	:= l_rec.pct_fl_tm_rt_id;
  p_effective_start_date  	:= l_rec.effective_start_date;
  p_effective_end_date    	:= l_rec.effective_end_date;
  p_object_version_number 	:= l_rec.object_version_number;
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End ins;
--
end ben_pfr_ins;

/
