--------------------------------------------------------
--  DDL for Package Body BEN_PRB_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PRB_INS" as
/* $Header: beprbrhi.pkb 120.0.12010000.2 2008/08/05 15:17:48 ubhat ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_prb_ins.';  -- Global package name
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
	(p_rec 			 in out nocopy ben_prb_shd.g_rec_type,
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
    from   ben_pl_regy_bod_f t
    where  t.pl_regy_bod_id       = p_rec.pl_regy_bod_id
    and    t.effective_start_date =
             ben_prb_shd.g_old_rec.effective_start_date
    and    t.effective_end_date   = (p_validation_start_date - 1);
--
  l_proc		varchar2(72) := g_package||'dt_insert_dml';
  l_created_by          ben_pl_regy_bod_f.created_by%TYPE;
  l_creation_date       ben_pl_regy_bod_f.creation_date%TYPE;
  l_last_update_date   	ben_pl_regy_bod_f.last_update_date%TYPE;
  l_last_updated_by     ben_pl_regy_bod_f.last_updated_by%TYPE;
  l_last_update_login   ben_pl_regy_bod_f.last_update_login%TYPE;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Get the object version number for the insert
  --
  p_rec.object_version_number :=
    dt_api.get_object_version_number
	(p_base_table_name => 'ben_pl_regy_bod_f',
	 p_base_key_column => 'pl_regy_bod_id',
	 p_base_key_value  => p_rec.pl_regy_bod_id);
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
  ben_prb_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Insert the row into: ben_pl_regy_bod_f
  --
  insert into ben_pl_regy_bod_f
  (	pl_regy_bod_id,
	effective_start_date,
	effective_end_date,
	business_group_id,
	pl_id,
	rptg_grp_id,
        organization_id,
	quald_dt,
	quald_flag,
	regy_pl_name,
	aprvd_trmn_dt,
	prb_attribute_category,
	prb_attribute1,
	prb_attribute2,
	prb_attribute3,
	prb_attribute4,
	prb_attribute5,
	prb_attribute6,
	prb_attribute7,
	prb_attribute8,
	prb_attribute9,
	prb_attribute10,
	prb_attribute11,
	prb_attribute12,
	prb_attribute13,
	prb_attribute14,
	prb_attribute15,
	prb_attribute16,
	prb_attribute17,
	prb_attribute18,
	prb_attribute19,
	prb_attribute20,
	prb_attribute21,
	prb_attribute22,
	prb_attribute23,
	prb_attribute24,
	prb_attribute25,
	prb_attribute26,
	prb_attribute27,
	prb_attribute28,
	prb_attribute29,
	prb_attribute30,
	object_version_number
   	, created_by,
   	creation_date,
   	last_update_date,
   	last_updated_by,
   	last_update_login
  )
  Values
  (	p_rec.pl_regy_bod_id,
	p_rec.effective_start_date,
	p_rec.effective_end_date,
	p_rec.business_group_id,
	p_rec.pl_id,
	p_rec.rptg_grp_id,
        p_rec.organization_id,
	p_rec.quald_dt,
	p_rec.quald_flag,
	p_rec.regy_pl_name,
	p_rec.aprvd_trmn_dt,
	p_rec.prb_attribute_category,
	p_rec.prb_attribute1,
	p_rec.prb_attribute2,
	p_rec.prb_attribute3,
	p_rec.prb_attribute4,
	p_rec.prb_attribute5,
	p_rec.prb_attribute6,
	p_rec.prb_attribute7,
	p_rec.prb_attribute8,
	p_rec.prb_attribute9,
	p_rec.prb_attribute10,
	p_rec.prb_attribute11,
	p_rec.prb_attribute12,
	p_rec.prb_attribute13,
	p_rec.prb_attribute14,
	p_rec.prb_attribute15,
	p_rec.prb_attribute16,
	p_rec.prb_attribute17,
	p_rec.prb_attribute18,
	p_rec.prb_attribute19,
	p_rec.prb_attribute20,
	p_rec.prb_attribute21,
	p_rec.prb_attribute22,
	p_rec.prb_attribute23,
	p_rec.prb_attribute24,
	p_rec.prb_attribute25,
	p_rec.prb_attribute26,
	p_rec.prb_attribute27,
	p_rec.prb_attribute28,
	p_rec.prb_attribute29,
	p_rec.prb_attribute30,
	p_rec.object_version_number
	, l_created_by,
   	l_creation_date,
   	l_last_update_date,
   	l_last_updated_by,
   	l_last_update_login
  );
  --
  ben_prb_shd.g_api_dml := false;   -- Unset the api dml status
  hr_utility.set_location(' Leaving:'||l_proc, 15);
--
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    ben_prb_shd.g_api_dml := false;   -- Unset the api dml status
    ben_prb_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    ben_prb_shd.g_api_dml := false;   -- Unset the api dml status
    ben_prb_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    ben_prb_shd.g_api_dml := false;   -- Unset the api dml status
    Raise;
End dt_insert_dml;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< insert_dml >------------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_dml
	(p_rec 			 in out nocopy ben_prb_shd.g_rec_type,
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
	(p_rec  			in out nocopy ben_prb_shd.g_rec_type,
	 p_effective_date		in date,
	 p_datetrack_mode		in varchar2,
	 p_validation_start_date	in date,
	 p_validation_end_date		in date) is
  --
  l_proc	varchar2(72) := g_package||'pre_insert';
  --
  Cursor C_Sel1 is select ben_pl_regy_bod_f_s.nextval from sys.dual;
  --
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Select the next sequence number
  --
  Open C_Sel1;
  Fetch C_Sel1 Into p_rec.pl_regy_bod_id;
  Close C_Sel1;
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
	(p_rec 			 in ben_prb_shd.g_rec_type,
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
  -- Start of API User Hook for post_insert.
  --
  begin
    --
    ben_prb_rki.after_insert
      (
      p_pl_regy_bod_id                =>p_rec.pl_regy_bod_id
     ,p_effective_start_date          =>p_rec.effective_start_date
     ,p_effective_end_date            =>p_rec.effective_end_date
     ,p_business_group_id             =>p_rec.business_group_id
     ,p_pl_id                         =>p_rec.pl_id
     ,p_rptg_grp_id                   =>p_rec.rptg_grp_id
     ,p_organization_id               =>p_rec.organization_id
     ,p_quald_dt                      =>p_rec.quald_dt
     ,p_quald_flag                    =>p_rec.quald_flag
     ,p_regy_pl_name                  =>p_rec.regy_pl_name
     ,p_aprvd_trmn_dt                 =>p_rec.aprvd_trmn_dt
     ,p_prb_attribute_category        =>p_rec.prb_attribute_category
     ,p_prb_attribute1                =>p_rec.prb_attribute1
     ,p_prb_attribute2                =>p_rec.prb_attribute2
     ,p_prb_attribute3                =>p_rec.prb_attribute3
     ,p_prb_attribute4                =>p_rec.prb_attribute4
     ,p_prb_attribute5                =>p_rec.prb_attribute5
     ,p_prb_attribute6                =>p_rec.prb_attribute6
     ,p_prb_attribute7                =>p_rec.prb_attribute7
     ,p_prb_attribute8                =>p_rec.prb_attribute8
     ,p_prb_attribute9                =>p_rec.prb_attribute9
     ,p_prb_attribute10               =>p_rec.prb_attribute10
     ,p_prb_attribute11               =>p_rec.prb_attribute11
     ,p_prb_attribute12               =>p_rec.prb_attribute12
     ,p_prb_attribute13               =>p_rec.prb_attribute13
     ,p_prb_attribute14               =>p_rec.prb_attribute14
     ,p_prb_attribute15               =>p_rec.prb_attribute15
     ,p_prb_attribute16               =>p_rec.prb_attribute16
     ,p_prb_attribute17               =>p_rec.prb_attribute17
     ,p_prb_attribute18               =>p_rec.prb_attribute18
     ,p_prb_attribute19               =>p_rec.prb_attribute19
     ,p_prb_attribute20               =>p_rec.prb_attribute20
     ,p_prb_attribute21               =>p_rec.prb_attribute21
     ,p_prb_attribute22               =>p_rec.prb_attribute22
     ,p_prb_attribute23               =>p_rec.prb_attribute23
     ,p_prb_attribute24               =>p_rec.prb_attribute24
     ,p_prb_attribute25               =>p_rec.prb_attribute25
     ,p_prb_attribute26               =>p_rec.prb_attribute26
     ,p_prb_attribute27               =>p_rec.prb_attribute27
     ,p_prb_attribute28               =>p_rec.prb_attribute28
     ,p_prb_attribute29               =>p_rec.prb_attribute29
     ,p_prb_attribute30               =>p_rec.prb_attribute30
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
        (p_module_name => 'ben_pl_regy_bod_f'
        ,p_hook_type   => 'AI');
      --
  end;
  --
  -- End of API User Hook for post_insert.
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
	 p_rec	 		 in  ben_prb_shd.g_rec_type,
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
	 p_base_table_name	   => 'ben_pl_regy_bod_f',
	 p_base_key_column	   => 'pl_regy_bod_id',
	 p_base_key_value 	   => p_rec.pl_regy_bod_id,
	 p_parent_table_name1      => 'ben_pl_f',
	 p_parent_key_column1      => 'pl_id',
	 p_parent_key_value1       => p_rec.pl_id,
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
  p_rec		   in out nocopy ben_prb_shd.g_rec_type,
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
  ben_prb_bus.insert_validate
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
  p_pl_regy_bod_id               out nocopy number,
  p_effective_start_date         out nocopy date,
  p_effective_end_date           out nocopy date,
  p_business_group_id            in number,
  p_pl_id                        in number           default null,
  p_rptg_grp_id                  in number           default null,
  p_organization_id              in number           default null,
  p_quald_dt                     in date             default null,
  p_quald_flag                   in varchar2         default null,
  p_regy_pl_name                 in varchar2         default null,
  p_aprvd_trmn_dt                in date             default null,
  p_prb_attribute_category       in varchar2         default null,
  p_prb_attribute1               in varchar2         default null,
  p_prb_attribute2               in varchar2         default null,
  p_prb_attribute3               in varchar2         default null,
  p_prb_attribute4               in varchar2         default null,
  p_prb_attribute5               in varchar2         default null,
  p_prb_attribute6               in varchar2         default null,
  p_prb_attribute7               in varchar2         default null,
  p_prb_attribute8               in varchar2         default null,
  p_prb_attribute9               in varchar2         default null,
  p_prb_attribute10              in varchar2         default null,
  p_prb_attribute11              in varchar2         default null,
  p_prb_attribute12              in varchar2         default null,
  p_prb_attribute13              in varchar2         default null,
  p_prb_attribute14              in varchar2         default null,
  p_prb_attribute15              in varchar2         default null,
  p_prb_attribute16              in varchar2         default null,
  p_prb_attribute17              in varchar2         default null,
  p_prb_attribute18              in varchar2         default null,
  p_prb_attribute19              in varchar2         default null,
  p_prb_attribute20              in varchar2         default null,
  p_prb_attribute21              in varchar2         default null,
  p_prb_attribute22              in varchar2         default null,
  p_prb_attribute23              in varchar2         default null,
  p_prb_attribute24              in varchar2         default null,
  p_prb_attribute25              in varchar2         default null,
  p_prb_attribute26              in varchar2         default null,
  p_prb_attribute27              in varchar2         default null,
  p_prb_attribute28              in varchar2         default null,
  p_prb_attribute29              in varchar2         default null,
  p_prb_attribute30              in varchar2         default null,
  p_object_version_number        out nocopy number,
  p_effective_date		 in date
  ) is
--
  l_rec		ben_prb_shd.g_rec_type;
  l_proc	varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  ben_prb_shd.convert_args
  (
  null,
  null,
  null,
  p_business_group_id,
  p_pl_id,
  p_rptg_grp_id,
  p_organization_id,
  p_quald_dt,
  p_quald_flag,
  p_regy_pl_name,
  p_aprvd_trmn_dt,
  p_prb_attribute_category,
  p_prb_attribute1,
  p_prb_attribute2,
  p_prb_attribute3,
  p_prb_attribute4,
  p_prb_attribute5,
  p_prb_attribute6,
  p_prb_attribute7,
  p_prb_attribute8,
  p_prb_attribute9,
  p_prb_attribute10,
  p_prb_attribute11,
  p_prb_attribute12,
  p_prb_attribute13,
  p_prb_attribute14,
  p_prb_attribute15,
  p_prb_attribute16,
  p_prb_attribute17,
  p_prb_attribute18,
  p_prb_attribute19,
  p_prb_attribute20,
  p_prb_attribute21,
  p_prb_attribute22,
  p_prb_attribute23,
  p_prb_attribute24,
  p_prb_attribute25,
  p_prb_attribute26,
  p_prb_attribute27,
  p_prb_attribute28,
  p_prb_attribute29,
  p_prb_attribute30,
  null
  );
  --
  -- Having converted the arguments into the ben_prb_rec
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  ins(l_rec, p_effective_date);
  --
  -- Set the OUT arguments.
  --
  p_pl_regy_bod_id        	:= l_rec.pl_regy_bod_id;
  p_effective_start_date  	:= l_rec.effective_start_date;
  p_effective_end_date    	:= l_rec.effective_end_date;
  p_object_version_number 	:= l_rec.object_version_number;
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End ins;
--
end ben_prb_ins;

/
