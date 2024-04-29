--------------------------------------------------------
--  DDL for Package Body BEN_EGN_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_EGN_INS" as
/* $Header: beegnrhi.pkb 120.0 2005/05/28 02:12:39 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_egn_ins.';  -- Global package name
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
	(p_rec 			 in out nocopy ben_egn_shd.g_rec_type,
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
    from   ben_ELIG_GNDR_PRTE_f t
    where  t.ELIG_GNDR_PRTE_id       = p_rec.ELIG_GNDR_PRTE_id
    and    t.effective_start_date =
             ben_egn_shd.g_old_rec.effective_start_date
    and    t.effective_end_date   = (p_validation_start_date - 1);
--
  l_proc		varchar2(72) := g_package||'dt_insert_dml';
  l_created_by          ben_ELIG_GNDR_PRTE_f.created_by%TYPE;
  l_creation_date       ben_ELIG_GNDR_PRTE_f.creation_date%TYPE;
  l_last_update_date   	ben_ELIG_GNDR_PRTE_f.last_update_date%TYPE;
  l_last_updated_by     ben_ELIG_GNDR_PRTE_f.last_updated_by%TYPE;
  l_last_update_login   ben_ELIG_GNDR_PRTE_f.last_update_login%TYPE;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Get the object version number for the insert
  --
  p_rec.object_version_number :=
    dt_api.get_object_version_number
	(p_base_table_name => 'ben_ELIG_GNDR_PRTE_f',
	 p_base_key_column => 'ELIG_GNDR_PRTE_id',
	 p_base_key_value  => p_rec.ELIG_GNDR_PRTE_id);
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
      fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
      fnd_message.set_token('PROCEDURE', l_proc);
      fnd_message.set_token('STEP','10');
      fnd_message.raise_error;
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
  ben_egn_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Insert the row into: ben_ELIG_GNDR_PRTE_f
  --
  insert into ben_ELIG_GNDR_PRTE_f
  (	ELIG_GNDR_PRTE_id,
	effective_start_date,
	effective_end_date,
	excld_flag,
	sex,
	eligy_prfl_id,
	business_group_id,
	egn_attribute_category,
	egn_attribute1,
	egn_attribute2,
	egn_attribute3,
	egn_attribute4,
	egn_attribute5,
	egn_attribute6,
	egn_attribute7,
	egn_attribute8,
	egn_attribute9,
	egn_attribute10,
	egn_attribute11,
	egn_attribute12,
	egn_attribute13,
	egn_attribute14,
	egn_attribute15,
	egn_attribute16,
	egn_attribute17,
	egn_attribute18,
	egn_attribute19,
	egn_attribute20,
	egn_attribute21,
	egn_attribute22,
	egn_attribute23,
	egn_attribute24,
	egn_attribute25,
	egn_attribute26,
	egn_attribute27,
	egn_attribute28,
	egn_attribute29,
	egn_attribute30,
	ordr_num,
	object_version_number,
   	created_by,
   	creation_date,
   	last_update_date,
   	last_updated_by,
   	last_update_login,
   	criteria_score,
   	criteria_weight
  )
  Values
  (	p_rec.ELIG_GNDR_PRTE_id,
	p_rec.effective_start_date,
	p_rec.effective_end_date,
	p_rec.excld_flag,
	p_rec.sex,
	p_rec.eligy_prfl_id,
	p_rec.business_group_id,
	p_rec.egn_attribute_category,
	p_rec.egn_attribute1,
	p_rec.egn_attribute2,
	p_rec.egn_attribute3,
	p_rec.egn_attribute4,
	p_rec.egn_attribute5,
	p_rec.egn_attribute6,
	p_rec.egn_attribute7,
	p_rec.egn_attribute8,
	p_rec.egn_attribute9,
	p_rec.egn_attribute10,
	p_rec.egn_attribute11,
	p_rec.egn_attribute12,
	p_rec.egn_attribute13,
	p_rec.egn_attribute14,
	p_rec.egn_attribute15,
	p_rec.egn_attribute16,
	p_rec.egn_attribute17,
	p_rec.egn_attribute18,
	p_rec.egn_attribute19,
	p_rec.egn_attribute20,
	p_rec.egn_attribute21,
	p_rec.egn_attribute22,
	p_rec.egn_attribute23,
	p_rec.egn_attribute24,
	p_rec.egn_attribute25,
	p_rec.egn_attribute26,
	p_rec.egn_attribute27,
	p_rec.egn_attribute28,
	p_rec.egn_attribute29,
	p_rec.egn_attribute30,
	p_rec.ordr_num,
	p_rec.object_version_number,
	l_created_by,
   	l_creation_date,
   	l_last_update_date,
   	l_last_updated_by,
   	l_last_update_login,
   	p_rec.criteria_score,
   	p_rec.criteria_weight
  );
  --
  ben_egn_shd.g_api_dml := false;   -- Unset the api dml status
  hr_utility.set_location(' Leaving:'||l_proc, 15);
--
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    ben_egn_shd.g_api_dml := false;   -- Unset the api dml status
    ben_egn_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    ben_egn_shd.g_api_dml := false;   -- Unset the api dml status
    ben_egn_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    ben_egn_shd.g_api_dml := false;   -- Unset the api dml status
    Raise;
End dt_insert_dml;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< insert_dml >------------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_dml
	(p_rec 			 in out nocopy ben_egn_shd.g_rec_type,
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
	(p_rec  			in out nocopy ben_egn_shd.g_rec_type,
	 p_effective_date		in date,
	 p_datetrack_mode		in varchar2,
	 p_validation_start_date	in date,
	 p_validation_end_date		in date) is
--
  l_proc	varchar2(72) := g_package||'pre_insert';
--
cursor c1 is
    select BEN_ELIG_GNDR_PRTE_F_S.nextval
    from   sys.dual;
--
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  open c1;
    --
    fetch c1 into p_rec.ELIG_GNDR_PRTE_id;
    --
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
	(p_rec 			 in ben_egn_shd.g_rec_type,
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
    ben_egn_rki.after_insert
      (
  p_ELIG_GNDR_PRTE_id             =>p_rec.ELIG_GNDR_PRTE_id
 ,p_effective_start_date          =>p_rec.effective_start_date
 ,p_effective_end_date            =>p_rec.effective_end_date
 ,p_excld_flag                    =>p_rec.excld_flag
 ,p_sex                           =>p_rec.sex
 ,p_eligy_prfl_id                 =>p_rec.eligy_prfl_id
 ,p_business_group_id             =>p_rec.business_group_id
 ,p_egn_attribute_category        =>p_rec.egn_attribute_category
 ,p_egn_attribute1                =>p_rec.egn_attribute1
 ,p_egn_attribute2                =>p_rec.egn_attribute2
 ,p_egn_attribute3                =>p_rec.egn_attribute3
 ,p_egn_attribute4                =>p_rec.egn_attribute4
 ,p_egn_attribute5                =>p_rec.egn_attribute5
 ,p_egn_attribute6                =>p_rec.egn_attribute6
 ,p_egn_attribute7                =>p_rec.egn_attribute7
 ,p_egn_attribute8                =>p_rec.egn_attribute8
 ,p_egn_attribute9                =>p_rec.egn_attribute9
 ,p_egn_attribute10               =>p_rec.egn_attribute10
 ,p_egn_attribute11               =>p_rec.egn_attribute11
 ,p_egn_attribute12               =>p_rec.egn_attribute12
 ,p_egn_attribute13               =>p_rec.egn_attribute13
 ,p_egn_attribute14               =>p_rec.egn_attribute14
 ,p_egn_attribute15               =>p_rec.egn_attribute15
 ,p_egn_attribute16               =>p_rec.egn_attribute16
 ,p_egn_attribute17               =>p_rec.egn_attribute17
 ,p_egn_attribute18               =>p_rec.egn_attribute18
 ,p_egn_attribute19               =>p_rec.egn_attribute19
 ,p_egn_attribute20               =>p_rec.egn_attribute20
 ,p_egn_attribute21               =>p_rec.egn_attribute21
 ,p_egn_attribute22               =>p_rec.egn_attribute22
 ,p_egn_attribute23               =>p_rec.egn_attribute23
 ,p_egn_attribute24               =>p_rec.egn_attribute24
 ,p_egn_attribute25               =>p_rec.egn_attribute25
 ,p_egn_attribute26               =>p_rec.egn_attribute26
 ,p_egn_attribute27               =>p_rec.egn_attribute27
 ,p_egn_attribute28               =>p_rec.egn_attribute28
 ,p_egn_attribute29               =>p_rec.egn_attribute29
 ,p_egn_attribute30               =>p_rec.egn_attribute30
 ,p_ordr_num	                  =>p_rec.ordr_num
 ,p_object_version_number         =>p_rec.object_version_number
 ,p_effective_date                =>p_effective_date
 ,p_validation_start_date         =>p_validation_start_date
 ,p_validation_end_date           =>p_validation_end_date
 ,p_criteria_score				  =>p_rec.criteria_score
 ,p_criteria_weight				  =>p_rec.criteria_weight

      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'ben_ELIG_GNDR_PRTE_f'
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
	 p_rec	 		 in  ben_egn_shd.g_rec_type,
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
	 p_base_table_name	   => 'ben_ELIG_GNDR_PRTE_f',
	 p_base_key_column	   => 'ELIG_GNDR_PRTE_id',
	 p_base_key_value 	   => p_rec.ELIG_GNDR_PRTE_id,
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
  p_rec		   in out nocopy ben_egn_shd.g_rec_type,
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
  ben_egn_bus.insert_validate
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
  p_ELIG_GNDR_PRTE_id       out nocopy number,
  p_effective_start_date         out nocopy date,
  p_effective_end_date           out nocopy date,
  p_excld_flag                   in varchar2         default 'N',
  p_sex                          in varchar2         default null,
  p_eligy_prfl_id                in number,
  p_business_group_id            in number,
  p_egn_attribute_category       in varchar2         default null,
  p_egn_attribute1               in varchar2         default null,
  p_egn_attribute2               in varchar2         default null,
  p_egn_attribute3               in varchar2         default null,
  p_egn_attribute4               in varchar2         default null,
  p_egn_attribute5               in varchar2         default null,
  p_egn_attribute6               in varchar2         default null,
  p_egn_attribute7               in varchar2         default null,
  p_egn_attribute8               in varchar2         default null,
  p_egn_attribute9               in varchar2         default null,
  p_egn_attribute10              in varchar2         default null,
  p_egn_attribute11              in varchar2         default null,
  p_egn_attribute12              in varchar2         default null,
  p_egn_attribute13              in varchar2         default null,
  p_egn_attribute14              in varchar2         default null,
  p_egn_attribute15              in varchar2         default null,
  p_egn_attribute16              in varchar2         default null,
  p_egn_attribute17              in varchar2         default null,
  p_egn_attribute18              in varchar2         default null,
  p_egn_attribute19              in varchar2         default null,
  p_egn_attribute20              in varchar2         default null,
  p_egn_attribute21              in varchar2         default null,
  p_egn_attribute22              in varchar2         default null,
  p_egn_attribute23              in varchar2         default null,
  p_egn_attribute24              in varchar2         default null,
  p_egn_attribute25              in varchar2         default null,
  p_egn_attribute26              in varchar2         default null,
  p_egn_attribute27              in varchar2         default null,
  p_egn_attribute28              in varchar2         default null,
  p_egn_attribute29              in varchar2         default null,
  p_egn_attribute30              in varchar2         default null,
  p_ordr_num  			 in number,
  p_object_version_number        out nocopy number,
  p_effective_date		 in date,
  p_criteria_score		 in number					default null,
  p_criteria_weight		 in number					default null
  ) is
--
  l_rec		ben_egn_shd.g_rec_type;
  l_proc	varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  ben_egn_shd.convert_args
  (
  null,
  null,
  null,
  p_excld_flag,
  p_sex,
  p_eligy_prfl_id,
  p_business_group_id,
  p_egn_attribute_category,
  p_egn_attribute1,
  p_egn_attribute2,
  p_egn_attribute3,
  p_egn_attribute4,
  p_egn_attribute5,
  p_egn_attribute6,
  p_egn_attribute7,
  p_egn_attribute8,
  p_egn_attribute9,
  p_egn_attribute10,
  p_egn_attribute11,
  p_egn_attribute12,
  p_egn_attribute13,
  p_egn_attribute14,
  p_egn_attribute15,
  p_egn_attribute16,
  p_egn_attribute17,
  p_egn_attribute18,
  p_egn_attribute19,
  p_egn_attribute20,
  p_egn_attribute21,
  p_egn_attribute22,
  p_egn_attribute23,
  p_egn_attribute24,
  p_egn_attribute25,
  p_egn_attribute26,
  p_egn_attribute27,
  p_egn_attribute28,
  p_egn_attribute29,
  p_egn_attribute30,
  p_ordr_num,
  null,
  p_criteria_score,
  p_criteria_weight
  );
  --
  -- Having converted the arguments into the ben_egn_rec
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  ins(l_rec, p_effective_date);
  --
  -- Set the OUT arguments.
  --
  p_ELIG_GNDR_PRTE_id        	:= l_rec.ELIG_GNDR_PRTE_id;
  p_effective_start_date  	:= l_rec.effective_start_date;
  p_effective_end_date    	:= l_rec.effective_end_date;
  p_object_version_number 	:= l_rec.object_version_number;
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End ins;
--
end ben_egn_ins;

/
