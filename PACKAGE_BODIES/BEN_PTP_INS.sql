--------------------------------------------------------
--  DDL for Package Body BEN_PTP_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PTP_INS" as
/* $Header: beptprhi.pkb 120.1 2005/06/02 03:22:51 bmanyam noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_ptp_ins.';  -- Global package name
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
	(p_rec 			 in out nocopy ben_ptp_shd.g_rec_type,
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
    from   ben_pl_typ_f t
    where  t.pl_typ_id       = p_rec.pl_typ_id
    and    t.effective_start_date =
             ben_ptp_shd.g_old_rec.effective_start_date
    and    t.effective_end_date   = (p_validation_start_date - 1);
--
  l_proc		varchar2(72) := g_package||'dt_insert_dml';
  l_created_by          ben_pl_typ_f.created_by%TYPE;
  l_creation_date       ben_pl_typ_f.creation_date%TYPE;
  l_last_update_date   	ben_pl_typ_f.last_update_date%TYPE;
  l_last_updated_by     ben_pl_typ_f.last_updated_by%TYPE;
  l_last_update_login   ben_pl_typ_f.last_update_login%TYPE;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Get the object version number for the insert
  --
  p_rec.object_version_number :=
    dt_api.get_object_version_number
	(p_base_table_name => 'ben_pl_typ_f',
	 p_base_key_column => 'pl_typ_id',
	 p_base_key_value  => p_rec.pl_typ_id);
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
  ben_ptp_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Insert the row into: ben_pl_typ_f
  --
  insert into ben_pl_typ_f
  (	pl_typ_id,
	effective_start_date,
	effective_end_date,
	name,
	mx_enrl_alwd_num,
	mn_enrl_rqd_num,
	pl_typ_stat_cd,
	opt_typ_cd,
        opt_dsply_fmt_cd,
        comp_typ_cd,
	ivr_ident,
	no_mx_enrl_num_dfnd_flag,
	no_mn_enrl_num_dfnd_flag,
	business_group_id,
	ptp_attribute_category,
	ptp_attribute1,
	ptp_attribute2,
	ptp_attribute3,
	ptp_attribute4,
	ptp_attribute5,
	ptp_attribute6,
	ptp_attribute7,
	ptp_attribute8,
	ptp_attribute9,
	ptp_attribute10,
	ptp_attribute11,
	ptp_attribute12,
	ptp_attribute13,
	ptp_attribute14,
	ptp_attribute15,
	ptp_attribute16,
	ptp_attribute17,
	ptp_attribute18,
	ptp_attribute19,
	ptp_attribute20,
	ptp_attribute21,
	ptp_attribute22,
	ptp_attribute23,
	ptp_attribute24,
	ptp_attribute25,
	ptp_attribute26,
	ptp_attribute27,
	ptp_attribute28,
	ptp_attribute29,
	ptp_attribute30,
	short_name,		/*FHR*/
	short_code,		/*FHR*/
		legislation_code,
		legislation_subgroup,
	object_version_number
   	, created_by,
   	creation_date,
   	last_update_date,
   	last_updated_by,
   	last_update_login
  )
  Values
  (	p_rec.pl_typ_id,
	p_rec.effective_start_date,
	p_rec.effective_end_date,
	p_rec.name,
	p_rec.mx_enrl_alwd_num,
	p_rec.mn_enrl_rqd_num,
	p_rec.pl_typ_stat_cd,
	p_rec.opt_typ_cd,
        p_rec.opt_dsply_fmt_cd,
        p_rec.comp_typ_cd,
	p_rec.ivr_ident,
	p_rec.no_mx_enrl_num_dfnd_flag,
	p_rec.no_mn_enrl_num_dfnd_flag,
	p_rec.business_group_id,
	p_rec.ptp_attribute_category,
	p_rec.ptp_attribute1,
	p_rec.ptp_attribute2,
	p_rec.ptp_attribute3,
	p_rec.ptp_attribute4,
	p_rec.ptp_attribute5,
	p_rec.ptp_attribute6,
	p_rec.ptp_attribute7,
	p_rec.ptp_attribute8,
	p_rec.ptp_attribute9,
	p_rec.ptp_attribute10,
	p_rec.ptp_attribute11,
	p_rec.ptp_attribute12,
	p_rec.ptp_attribute13,
	p_rec.ptp_attribute14,
	p_rec.ptp_attribute15,
	p_rec.ptp_attribute16,
	p_rec.ptp_attribute17,
	p_rec.ptp_attribute18,
	p_rec.ptp_attribute19,
	p_rec.ptp_attribute20,
	p_rec.ptp_attribute21,
	p_rec.ptp_attribute22,
	p_rec.ptp_attribute23,
	p_rec.ptp_attribute24,
	p_rec.ptp_attribute25,
	p_rec.ptp_attribute26,
	p_rec.ptp_attribute27,
	p_rec.ptp_attribute28,
	p_rec.ptp_attribute29,
	p_rec.ptp_attribute30,
	p_rec.short_name,		/*FHR*/
	p_rec.short_code, 		/*FHR*/
		p_rec.legislation_code,
		p_rec.legislation_subgroup,
	p_rec.object_version_number,
	l_created_by,
   	l_creation_date,
   	l_last_update_date,
   	l_last_updated_by,
   	l_last_update_login
  );
  --
  ben_ptp_shd.g_api_dml := false;   -- Unset the api dml status
  hr_utility.set_location(' Leaving:'||l_proc, 15);
--
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    ben_ptp_shd.g_api_dml := false;   -- Unset the api dml status
    ben_ptp_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    ben_ptp_shd.g_api_dml := false;   -- Unset the api dml status
    ben_ptp_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    ben_ptp_shd.g_api_dml := false;   -- Unset the api dml status
    Raise;
End dt_insert_dml;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< insert_dml >------------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_dml
	(p_rec 			 in out nocopy ben_ptp_shd.g_rec_type,
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
	(p_rec  			in out nocopy ben_ptp_shd.g_rec_type,
	 p_effective_date		in date,
	 p_datetrack_mode		in varchar2,
	 p_validation_start_date	in date,
	 p_validation_end_date		in date) is
--
  l_proc	varchar2(72) := g_package||'pre_insert';
--
  Cursor C_Sel1 is select ben_pl_typ_f_s.nextval from sys.dual;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  -- Select the next sequence number
  --
  Open C_Sel1;
  Fetch C_Sel1 Into p_rec.pl_typ_id;
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
	(p_rec 			 in ben_ptp_shd.g_rec_type,
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
    ben_ptp_rki.after_insert
      (
  p_pl_typ_id                     =>p_rec.pl_typ_id
 ,p_effective_start_date          =>p_rec.effective_start_date
 ,p_effective_end_date            =>p_rec.effective_end_date
 ,p_name                          =>p_rec.name
 ,p_mx_enrl_alwd_num              =>p_rec.mx_enrl_alwd_num
 ,p_mn_enrl_rqd_num               =>p_rec.mn_enrl_rqd_num
 ,p_pl_typ_stat_cd                =>p_rec.pl_typ_stat_cd
 ,p_opt_typ_cd                    =>p_rec.opt_typ_cd
 ,p_opt_dsply_fmt_cd              =>p_rec.opt_dsply_fmt_cd
 ,p_comp_typ_cd                   =>p_rec.comp_typ_cd
 ,p_ivr_ident                     =>p_rec.ivr_ident
 ,p_no_mx_enrl_num_dfnd_flag      =>p_rec.no_mx_enrl_num_dfnd_flag
 ,p_no_mn_enrl_num_dfnd_flag      =>p_rec.no_mn_enrl_num_dfnd_flag
 ,p_business_group_id             =>p_rec.business_group_id
 ,p_ptp_attribute_category        =>p_rec.ptp_attribute_category
 ,p_ptp_attribute1                =>p_rec.ptp_attribute1
 ,p_ptp_attribute2                =>p_rec.ptp_attribute2
 ,p_ptp_attribute3                =>p_rec.ptp_attribute3
 ,p_ptp_attribute4                =>p_rec.ptp_attribute4
 ,p_ptp_attribute5                =>p_rec.ptp_attribute5
 ,p_ptp_attribute6                =>p_rec.ptp_attribute6
 ,p_ptp_attribute7                =>p_rec.ptp_attribute7
 ,p_ptp_attribute8                =>p_rec.ptp_attribute8
 ,p_ptp_attribute9                =>p_rec.ptp_attribute9
 ,p_ptp_attribute10               =>p_rec.ptp_attribute10
 ,p_ptp_attribute11               =>p_rec.ptp_attribute11
 ,p_ptp_attribute12               =>p_rec.ptp_attribute12
 ,p_ptp_attribute13               =>p_rec.ptp_attribute13
 ,p_ptp_attribute14               =>p_rec.ptp_attribute14
 ,p_ptp_attribute15               =>p_rec.ptp_attribute15
 ,p_ptp_attribute16               =>p_rec.ptp_attribute16
 ,p_ptp_attribute17               =>p_rec.ptp_attribute17
 ,p_ptp_attribute18               =>p_rec.ptp_attribute18
 ,p_ptp_attribute19               =>p_rec.ptp_attribute19
 ,p_ptp_attribute20               =>p_rec.ptp_attribute20
 ,p_ptp_attribute21               =>p_rec.ptp_attribute21
 ,p_ptp_attribute22               =>p_rec.ptp_attribute22
 ,p_ptp_attribute23               =>p_rec.ptp_attribute23
 ,p_ptp_attribute24               =>p_rec.ptp_attribute24
 ,p_ptp_attribute25               =>p_rec.ptp_attribute25
 ,p_ptp_attribute26               =>p_rec.ptp_attribute26
 ,p_ptp_attribute27               =>p_rec.ptp_attribute27
 ,p_ptp_attribute28               =>p_rec.ptp_attribute28
 ,p_ptp_attribute29               =>p_rec.ptp_attribute29
 ,p_ptp_attribute30               =>p_rec.ptp_attribute30
 ,p_short_name			  =>p_rec.short_name		--FHR
 ,p_short_code			  =>p_rec.short_code		--FHR
  ,p_legislation_code			  =>p_rec.legislation_code
  ,p_legislation_subgroup			  =>p_rec.legislation_subgroup
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
        (p_module_name => 'ben_pl_typ_f'
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
	 p_rec	 		 in  ben_ptp_shd.g_rec_type,
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
	 p_base_table_name	   => 'ben_pl_typ_f',
	 p_base_key_column	   => 'pl_typ_id',
	 p_base_key_value 	   => p_rec.pl_typ_id,
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
  p_rec		   in out nocopy ben_ptp_shd.g_rec_type,
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
  ben_ptp_bus.insert_validate
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
  p_pl_typ_id                    out nocopy number,
  p_effective_start_date         out nocopy date,
  p_effective_end_date           out nocopy date,
  p_name                         in varchar2,
  p_mx_enrl_alwd_num             in number           default null,
  p_mn_enrl_rqd_num              in number           default null,
  p_pl_typ_stat_cd               in varchar2         default null,
  p_opt_typ_cd                   in varchar2         default null,
  p_opt_dsply_fmt_cd             in varchar2         default null,
  p_comp_typ_cd                  in varchar2         default null,
  p_ivr_ident                    in varchar2         default null,
  p_no_mx_enrl_num_dfnd_flag     in varchar2         default null,
  p_no_mn_enrl_num_dfnd_flag     in varchar2         default null,
  p_business_group_id            in number           default null,
  p_ptp_attribute_category       in varchar2         default null,
  p_ptp_attribute1               in varchar2         default null,
  p_ptp_attribute2               in varchar2         default null,
  p_ptp_attribute3               in varchar2         default null,
  p_ptp_attribute4               in varchar2         default null,
  p_ptp_attribute5               in varchar2         default null,
  p_ptp_attribute6               in varchar2         default null,
  p_ptp_attribute7               in varchar2         default null,
  p_ptp_attribute8               in varchar2         default null,
  p_ptp_attribute9               in varchar2         default null,
  p_ptp_attribute10              in varchar2         default null,
  p_ptp_attribute11              in varchar2         default null,
  p_ptp_attribute12              in varchar2         default null,
  p_ptp_attribute13              in varchar2         default null,
  p_ptp_attribute14              in varchar2         default null,
  p_ptp_attribute15              in varchar2         default null,
  p_ptp_attribute16              in varchar2         default null,
  p_ptp_attribute17              in varchar2         default null,
  p_ptp_attribute18              in varchar2         default null,
  p_ptp_attribute19              in varchar2         default null,
  p_ptp_attribute20              in varchar2         default null,
  p_ptp_attribute21              in varchar2         default null,
  p_ptp_attribute22              in varchar2         default null,
  p_ptp_attribute23              in varchar2         default null,
  p_ptp_attribute24              in varchar2         default null,
  p_ptp_attribute25              in varchar2         default null,
  p_ptp_attribute26              in varchar2         default null,
  p_ptp_attribute27              in varchar2         default null,
  p_ptp_attribute28              in varchar2         default null,
  p_ptp_attribute29              in varchar2         default null,
  p_ptp_attribute30              in varchar2         default null,
  p_short_name			 in varchar2         default null, 	--FHR
  p_short_code			 in varchar2         default null, 	--FHR
    p_legislation_code			 in varchar2         default null,
    p_legislation_subgroup			 in varchar2         default null,
  p_object_version_number        out nocopy number,
  p_effective_date		 in date
  ) is
--
  l_rec		ben_ptp_shd.g_rec_type;
  l_proc	varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  ben_ptp_shd.convert_args
  (
  null,
  null,
  null,
  p_name,
  p_mx_enrl_alwd_num,
  p_mn_enrl_rqd_num,
  p_pl_typ_stat_cd,
  p_opt_typ_cd,
  p_opt_dsply_fmt_cd,
  p_comp_typ_cd,
  p_ivr_ident,
  p_no_mx_enrl_num_dfnd_flag,
  p_no_mn_enrl_num_dfnd_flag,
  p_business_group_id,
  p_ptp_attribute_category,
  p_ptp_attribute1,
  p_ptp_attribute2,
  p_ptp_attribute3,
  p_ptp_attribute4,
  p_ptp_attribute5,
  p_ptp_attribute6,
  p_ptp_attribute7,
  p_ptp_attribute8,
  p_ptp_attribute9,
  p_ptp_attribute10,
  p_ptp_attribute11,
  p_ptp_attribute12,
  p_ptp_attribute13,
  p_ptp_attribute14,
  p_ptp_attribute15,
  p_ptp_attribute16,
  p_ptp_attribute17,
  p_ptp_attribute18,
  p_ptp_attribute19,
  p_ptp_attribute20,
  p_ptp_attribute21,
  p_ptp_attribute22,
  p_ptp_attribute23,
  p_ptp_attribute24,
  p_ptp_attribute25,
  p_ptp_attribute26,
  p_ptp_attribute27,
  p_ptp_attribute28,
  p_ptp_attribute29,
  p_ptp_attribute30,
  p_short_name,		--FHR
  p_short_code, 	--FHR
    p_legislation_code,
    p_legislation_subgroup,
  null
  );
  --
  -- Having converted the arguments into the ben_ptp_rec
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  ins(l_rec, p_effective_date);
  --
  -- Set the OUT arguments.
  --
  p_pl_typ_id        	:= l_rec.pl_typ_id;
  p_effective_start_date  	:= l_rec.effective_start_date;
  p_effective_end_date    	:= l_rec.effective_end_date;
  p_object_version_number 	:= l_rec.object_version_number;
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End ins;
--
end ben_ptp_ins;

/