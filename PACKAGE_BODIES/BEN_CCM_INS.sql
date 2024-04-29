--------------------------------------------------------
--  DDL for Package Body BEN_CCM_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_CCM_INS" as
/* $Header: beccmrhi.pkb 120.5 2006/03/22 02:53:46 rgajula noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_ccm_ins.';  -- Global package name
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
	(p_rec 			 in out nocopy ben_ccm_shd.g_rec_type,
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
    from   ben_cvg_amt_calc_mthd_f t
    where  t.cvg_amt_calc_mthd_id       = p_rec.cvg_amt_calc_mthd_id
    and    t.effective_start_date =
             ben_ccm_shd.g_old_rec.effective_start_date
    and    t.effective_end_date   = (p_validation_start_date - 1);
--
  l_proc		varchar2(72) := g_package||'dt_insert_dml';
  l_created_by          ben_cvg_amt_calc_mthd_f.created_by%TYPE;
  l_creation_date       ben_cvg_amt_calc_mthd_f.creation_date%TYPE;
  l_last_update_date   	ben_cvg_amt_calc_mthd_f.last_update_date%TYPE;
  l_last_updated_by     ben_cvg_amt_calc_mthd_f.last_updated_by%TYPE;
  l_last_update_login   ben_cvg_amt_calc_mthd_f.last_update_login%TYPE;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Get the object version number for the insert
  --
  p_rec.object_version_number :=
    dt_api.get_object_version_number
	(p_base_table_name => 'ben_cvg_amt_calc_mthd_f',
	 p_base_key_column => 'cvg_amt_calc_mthd_id',
	 p_base_key_value  => p_rec.cvg_amt_calc_mthd_id);
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
  ben_ccm_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Insert the row into: ben_cvg_amt_calc_mthd_f
  --
  insert into ben_cvg_amt_calc_mthd_f
  (	cvg_amt_calc_mthd_id,
	effective_start_date,
	effective_end_date,
	name,
	incrmt_val,
	mx_val,
	mn_val,
	no_mx_val_dfnd_flag,
	no_mn_val_dfnd_flag,
	rndg_cd,
	rndg_rl,
        lwr_lmt_val,
        lwr_lmt_calc_rl,
        upr_lmt_val,
        upr_lmt_calc_rl,
	val,
	val_ovrid_alwd_flag,
	val_calc_rl,
	uom,
	nnmntry_uom,
	bndry_perd_cd,
	bnft_typ_cd,
	cvg_mlt_cd,
	rt_typ_cd,
        dflt_val,
        entr_val_at_enrt_flag,
        dflt_flag,
	comp_lvl_fctr_id,
	oipl_id,
	pl_id,
	plip_id,
	business_group_id,
	ccm_attribute_category,
	ccm_attribute1,
	ccm_attribute2,
	ccm_attribute3,
	ccm_attribute4,
	ccm_attribute5,
	ccm_attribute6,
	ccm_attribute7,
	ccm_attribute8,
	ccm_attribute9,
	ccm_attribute10,
	ccm_attribute11,
	ccm_attribute12,
	ccm_attribute13,
	ccm_attribute14,
	ccm_attribute15,
	ccm_attribute16,
	ccm_attribute17,
	ccm_attribute18,
	ccm_attribute19,
	ccm_attribute20,
	ccm_attribute21,
	ccm_attribute22,
	ccm_attribute23,
	ccm_attribute24,
	ccm_attribute25,
	ccm_attribute26,
	ccm_attribute27,
	ccm_attribute28,
	ccm_attribute29,
	ccm_attribute30,
	object_version_number
   	, created_by,
   	creation_date,
   	last_update_date,
   	last_updated_by,
   	last_update_login
  )
  Values
  (	p_rec.cvg_amt_calc_mthd_id,
	p_rec.effective_start_date,
	p_rec.effective_end_date,
	p_rec.name,
	p_rec.incrmt_val,
	p_rec.mx_val,
	p_rec.mn_val,
	p_rec.no_mx_val_dfnd_flag,
	p_rec.no_mn_val_dfnd_flag,
	p_rec.rndg_cd,
	p_rec.rndg_rl,
        p_rec.lwr_lmt_val,
        p_rec.lwr_lmt_calc_rl,
        p_rec.upr_lmt_val,
        p_rec.upr_lmt_calc_rl,
	p_rec.val,
	p_rec.val_ovrid_alwd_flag,
	p_rec.val_calc_rl,
	p_rec.uom,
	p_rec.nnmntry_uom,
	p_rec.bndry_perd_cd,
	p_rec.bnft_typ_cd,
	p_rec.cvg_mlt_cd,
	p_rec.rt_typ_cd,
        p_rec.dflt_val,
        p_rec.entr_val_at_enrt_flag,
        p_rec.dflt_flag,
	p_rec.comp_lvl_fctr_id,
	p_rec.oipl_id,
	p_rec.pl_id,
	p_rec.plip_id,
	p_rec.business_group_id,
	p_rec.ccm_attribute_category,
	p_rec.ccm_attribute1,
	p_rec.ccm_attribute2,
	p_rec.ccm_attribute3,
	p_rec.ccm_attribute4,
	p_rec.ccm_attribute5,
	p_rec.ccm_attribute6,
	p_rec.ccm_attribute7,
	p_rec.ccm_attribute8,
	p_rec.ccm_attribute9,
	p_rec.ccm_attribute10,
	p_rec.ccm_attribute11,
	p_rec.ccm_attribute12,
	p_rec.ccm_attribute13,
	p_rec.ccm_attribute14,
	p_rec.ccm_attribute15,
	p_rec.ccm_attribute16,
	p_rec.ccm_attribute17,
	p_rec.ccm_attribute18,
	p_rec.ccm_attribute19,
	p_rec.ccm_attribute20,
	p_rec.ccm_attribute21,
	p_rec.ccm_attribute22,
	p_rec.ccm_attribute23,
	p_rec.ccm_attribute24,
	p_rec.ccm_attribute25,
	p_rec.ccm_attribute26,
	p_rec.ccm_attribute27,
	p_rec.ccm_attribute28,
	p_rec.ccm_attribute29,
	p_rec.ccm_attribute30,
	p_rec.object_version_number
	, l_created_by,
   	l_creation_date,
   	l_last_update_date,
   	l_last_updated_by,
   	l_last_update_login
  );
  --
  ben_ccm_shd.g_api_dml := false;   -- Unset the api dml status
  hr_utility.set_location(' Leaving:'||l_proc, 15);
--
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    ben_ccm_shd.g_api_dml := false;   -- Unset the api dml status
    ben_ccm_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    ben_ccm_shd.g_api_dml := false;   -- Unset the api dml status
    ben_ccm_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    ben_ccm_shd.g_api_dml := false;   -- Unset the api dml status
    Raise;
End dt_insert_dml;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< insert_dml >------------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_dml
	(p_rec 			 in out nocopy ben_ccm_shd.g_rec_type,
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
	(p_rec  			in out nocopy ben_ccm_shd.g_rec_type,
	 p_effective_date		in date,
	 p_datetrack_mode		in varchar2,
	 p_validation_start_date	in date,
	 p_validation_end_date		in date) is
--
  l_proc	varchar2(72) := g_package||'pre_insert';
--
  Cursor C_Sel1 is select ben_cvg_amt_calc_mthd_f_s.nextval from sys.dual;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Select the next sequence number
  --
  Open C_Sel1;
  Fetch C_Sel1 Into p_rec.cvg_amt_calc_mthd_id;
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
	(p_rec 			 in ben_ccm_shd.g_rec_type,
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
    ben_ccm_rki.after_insert
      (
  p_cvg_amt_calc_mthd_id          =>p_rec.cvg_amt_calc_mthd_id
 ,p_effective_start_date          =>p_rec.effective_start_date
 ,p_effective_end_date            =>p_rec.effective_end_date
 ,p_name                          =>p_rec.name
 ,p_incrmt_val                    =>p_rec.incrmt_val
 ,p_mx_val                        =>p_rec.mx_val
 ,p_mn_val                        =>p_rec.mn_val
 ,p_no_mx_val_dfnd_flag           =>p_rec.no_mx_val_dfnd_flag
 ,p_no_mn_val_dfnd_flag           =>p_rec.no_mn_val_dfnd_flag
 ,p_rndg_cd                       =>p_rec.rndg_cd
 ,p_rndg_rl                       =>p_rec.rndg_rl
 ,p_lwr_lmt_val                   =>p_rec.lwr_lmt_val
 ,p_lwr_lmt_calc_rl               =>p_rec.lwr_lmt_calc_rl
 ,p_upr_lmt_val                   =>p_rec.upr_lmt_val
 ,p_upr_lmt_calc_rl               =>p_rec.upr_lmt_calc_rl
 ,p_val                           =>p_rec.val
 ,p_val_ovrid_alwd_flag           =>p_rec.val_ovrid_alwd_flag
 ,p_val_calc_rl                   =>p_rec.val_calc_rl
 ,p_uom                           =>p_rec.uom
 ,p_nnmntry_uom                   =>p_rec.nnmntry_uom
 ,p_bndry_perd_cd                 =>p_rec.bndry_perd_cd
 ,p_bnft_typ_cd                   =>p_rec.bnft_typ_cd
 ,p_cvg_mlt_cd                    =>p_rec.cvg_mlt_cd
 ,p_rt_typ_cd                     =>p_rec.rt_typ_cd
 ,p_dflt_val                      =>p_rec.dflt_val
 ,p_entr_val_at_enrt_flag         =>p_rec.entr_val_at_enrt_flag
 ,p_dflt_flag                     =>p_rec.dflt_flag
 ,p_comp_lvl_fctr_id              =>p_rec.comp_lvl_fctr_id
 ,p_oipl_id                       =>p_rec.oipl_id
 ,p_pl_id                         =>p_rec.pl_id
 ,p_plip_id                       =>p_rec.plip_id
 ,p_business_group_id             =>p_rec.business_group_id
 ,p_ccm_attribute_category        =>p_rec.ccm_attribute_category
 ,p_ccm_attribute1                =>p_rec.ccm_attribute1
 ,p_ccm_attribute2                =>p_rec.ccm_attribute2
 ,p_ccm_attribute3                =>p_rec.ccm_attribute3
 ,p_ccm_attribute4                =>p_rec.ccm_attribute4
 ,p_ccm_attribute5                =>p_rec.ccm_attribute5
 ,p_ccm_attribute6                =>p_rec.ccm_attribute6
 ,p_ccm_attribute7                =>p_rec.ccm_attribute7
 ,p_ccm_attribute8                =>p_rec.ccm_attribute8
 ,p_ccm_attribute9                =>p_rec.ccm_attribute9
 ,p_ccm_attribute10               =>p_rec.ccm_attribute10
 ,p_ccm_attribute11               =>p_rec.ccm_attribute11
 ,p_ccm_attribute12               =>p_rec.ccm_attribute12
 ,p_ccm_attribute13               =>p_rec.ccm_attribute13
 ,p_ccm_attribute14               =>p_rec.ccm_attribute14
 ,p_ccm_attribute15               =>p_rec.ccm_attribute15
 ,p_ccm_attribute16               =>p_rec.ccm_attribute16
 ,p_ccm_attribute17               =>p_rec.ccm_attribute17
 ,p_ccm_attribute18               =>p_rec.ccm_attribute18
 ,p_ccm_attribute19               =>p_rec.ccm_attribute19
 ,p_ccm_attribute20               =>p_rec.ccm_attribute20
 ,p_ccm_attribute21               =>p_rec.ccm_attribute21
 ,p_ccm_attribute22               =>p_rec.ccm_attribute22
 ,p_ccm_attribute23               =>p_rec.ccm_attribute23
 ,p_ccm_attribute24               =>p_rec.ccm_attribute24
 ,p_ccm_attribute25               =>p_rec.ccm_attribute25
 ,p_ccm_attribute26               =>p_rec.ccm_attribute26
 ,p_ccm_attribute27               =>p_rec.ccm_attribute27
 ,p_ccm_attribute28               =>p_rec.ccm_attribute28
 ,p_ccm_attribute29               =>p_rec.ccm_attribute29
 ,p_ccm_attribute30               =>p_rec.ccm_attribute30
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
        (p_module_name => 'ben_cvg_amt_calc_mthd_f'
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
	 p_rec	 		 in  ben_ccm_shd.g_rec_type,
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
	 p_base_table_name	   => 'ben_cvg_amt_calc_mthd_f',
	 p_base_key_column	   => 'cvg_amt_calc_mthd_id',
	 p_base_key_value 	   => p_rec.cvg_amt_calc_mthd_id,
	 p_parent_table_name1      => 'ben_oipl_f',
	 p_parent_key_column1      => 'oipl_id',
	 p_parent_key_value1       => p_rec.oipl_id,
	 p_parent_table_name2      => 'ben_pl_f',
	 p_parent_key_column2      => 'pl_id',
	 p_parent_key_value2       => p_rec.pl_id,
	 p_parent_table_name3      => 'ben_plip_f',
	 p_parent_key_column3      => 'plip_id',
	 p_parent_key_value3       => p_rec.plip_id,
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
  p_rec		   in out nocopy ben_ccm_shd.g_rec_type,
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
  ben_ccm_bus.insert_validate
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
  p_cvg_amt_calc_mthd_id         out nocopy number,
  p_effective_start_date         out nocopy date,
  p_effective_end_date           out nocopy date,
  p_name                         in varchar2,
  p_incrmt_val                   in number           default null,
  p_mx_val                       in number           default null,
  p_mn_val                       in number           default null,
  p_no_mx_val_dfnd_flag          in varchar2,
  p_no_mn_val_dfnd_flag          in varchar2,
  p_rndg_cd                      in varchar2         default null,
  p_rndg_rl                      in number           default null,
  p_lwr_lmt_val                  in number           default null,
  p_lwr_lmt_calc_rl              in number           default null,
  p_upr_lmt_val                  in number           default null,
  p_upr_lmt_calc_rl              in number           default null,
  p_val                          in number           default null,
  p_val_ovrid_alwd_flag          in varchar2,
  p_val_calc_rl                  in number           default null,
  p_uom                          in varchar2         default null,
  p_nnmntry_uom                  in varchar2         default null,
  p_bndry_perd_cd                in varchar2         default null,
  p_bnft_typ_cd                  in varchar2         default null,
  p_cvg_mlt_cd                   in varchar2         default null,
  p_rt_typ_cd                    in varchar2         default null,
  p_dflt_val                     in number           default null,
  p_entr_val_at_enrt_flag        in varchar2,
  p_dflt_flag                    in varchar2,
  p_comp_lvl_fctr_id             in number           default null,
  p_oipl_id                      in number           default null,
  p_pl_id                        in number           default null,
  p_plip_id                      in number           default null,
  p_business_group_id            in number,
  p_ccm_attribute_category       in varchar2         default null,
  p_ccm_attribute1               in varchar2         default null,
  p_ccm_attribute2               in varchar2         default null,
  p_ccm_attribute3               in varchar2         default null,
  p_ccm_attribute4               in varchar2         default null,
  p_ccm_attribute5               in varchar2         default null,
  p_ccm_attribute6               in varchar2         default null,
  p_ccm_attribute7               in varchar2         default null,
  p_ccm_attribute8               in varchar2         default null,
  p_ccm_attribute9               in varchar2         default null,
  p_ccm_attribute10              in varchar2         default null,
  p_ccm_attribute11              in varchar2         default null,
  p_ccm_attribute12              in varchar2         default null,
  p_ccm_attribute13              in varchar2         default null,
  p_ccm_attribute14              in varchar2         default null,
  p_ccm_attribute15              in varchar2         default null,
  p_ccm_attribute16              in varchar2         default null,
  p_ccm_attribute17              in varchar2         default null,
  p_ccm_attribute18              in varchar2         default null,
  p_ccm_attribute19              in varchar2         default null,
  p_ccm_attribute20              in varchar2         default null,
  p_ccm_attribute21              in varchar2         default null,
  p_ccm_attribute22              in varchar2         default null,
  p_ccm_attribute23              in varchar2         default null,
  p_ccm_attribute24              in varchar2         default null,
  p_ccm_attribute25              in varchar2         default null,
  p_ccm_attribute26              in varchar2         default null,
  p_ccm_attribute27              in varchar2         default null,
  p_ccm_attribute28              in varchar2         default null,
  p_ccm_attribute29              in varchar2         default null,
  p_ccm_attribute30              in varchar2         default null,
  p_object_version_number        out nocopy number,
  p_effective_date		 in date
  ) is
--
  l_rec		ben_ccm_shd.g_rec_type;
  l_proc	varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  ben_ccm_shd.convert_args
  (
  null,
  null,
  null,
  p_name,
  p_incrmt_val,
  p_mx_val,
  p_mn_val,
  p_no_mx_val_dfnd_flag,
  p_no_mn_val_dfnd_flag,
  p_rndg_cd,
  p_rndg_rl,
  p_lwr_lmt_val,
  p_lwr_lmt_calc_rl,
  p_upr_lmt_val,
  p_upr_lmt_calc_rl,
  p_val,
  p_val_ovrid_alwd_flag,
  p_val_calc_rl,
  p_uom,
  p_nnmntry_uom,
  p_bndry_perd_cd,
  p_bnft_typ_cd,
  p_cvg_mlt_cd,
  p_rt_typ_cd,
  p_dflt_val,
  p_entr_val_at_enrt_flag,
  p_dflt_flag,
  p_comp_lvl_fctr_id,
  p_oipl_id,
  p_pl_id,
  p_plip_id,
  p_business_group_id,
  p_ccm_attribute_category,
  p_ccm_attribute1,
  p_ccm_attribute2,
  p_ccm_attribute3,
  p_ccm_attribute4,
  p_ccm_attribute5,
  p_ccm_attribute6,
  p_ccm_attribute7,
  p_ccm_attribute8,
  p_ccm_attribute9,
  p_ccm_attribute10,
  p_ccm_attribute11,
  p_ccm_attribute12,
  p_ccm_attribute13,
  p_ccm_attribute14,
  p_ccm_attribute15,
  p_ccm_attribute16,
  p_ccm_attribute17,
  p_ccm_attribute18,
  p_ccm_attribute19,
  p_ccm_attribute20,
  p_ccm_attribute21,
  p_ccm_attribute22,
  p_ccm_attribute23,
  p_ccm_attribute24,
  p_ccm_attribute25,
  p_ccm_attribute26,
  p_ccm_attribute27,
  p_ccm_attribute28,
  p_ccm_attribute29,
  p_ccm_attribute30,
  null
  );
  --
  -- Having converted the arguments into the ben_ccm_rec
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  ins(l_rec, p_effective_date);
  --
  -- Set the OUT arguments.
  --
  p_cvg_amt_calc_mthd_id        	:= l_rec.cvg_amt_calc_mthd_id;
  p_effective_start_date  	:= l_rec.effective_start_date;
  p_effective_end_date    	:= l_rec.effective_end_date;
  p_object_version_number 	:= l_rec.object_version_number;
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End ins;
--
end ben_ccm_ins;

/
