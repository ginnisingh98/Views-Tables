--------------------------------------------------------
--  DDL for Package Body BEN_BPP_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_BPP_INS" as
/* $Header: bebpprhi.pkb 115.13 2002/12/22 20:25:09 pabodla ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_bpp_ins.';  -- Global package name
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
	(p_rec 			 in out nocopy ben_bpp_shd.g_rec_type,
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
    from   ben_bnft_prvdr_pool_f t
    where  t.bnft_prvdr_pool_id       = p_rec.bnft_prvdr_pool_id
    and    t.effective_start_date =
             ben_bpp_shd.g_old_rec.effective_start_date
    and    t.effective_end_date   = (p_validation_start_date - 1);
--
  l_proc		varchar2(72) := g_package||'dt_insert_dml';
  l_created_by          ben_bnft_prvdr_pool_f.created_by%TYPE;
  l_creation_date       ben_bnft_prvdr_pool_f.creation_date%TYPE;
  l_last_update_date   	ben_bnft_prvdr_pool_f.last_update_date%TYPE;
  l_last_updated_by     ben_bnft_prvdr_pool_f.last_updated_by%TYPE;
  l_last_update_login   ben_bnft_prvdr_pool_f.last_update_login%TYPE;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Get the object version number for the insert
  --
  p_rec.object_version_number :=
    dt_api.get_object_version_number
	(p_base_table_name => 'ben_bnft_prvdr_pool_f',
	 p_base_key_column => 'bnft_prvdr_pool_id',
	 p_base_key_value  => p_rec.bnft_prvdr_pool_id);
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
  ben_bpp_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Insert the row into: ben_bnft_prvdr_pool_f
  --

  insert into ben_bnft_prvdr_pool_f
  (	bnft_prvdr_pool_id,
	effective_start_date,
	effective_end_date,
	name,
	pgm_pool_flag,
	excs_alwys_fftd_flag,
	use_for_pgm_pool_flag,
	pct_rndg_cd,
	pct_rndg_rl,
	val_rndg_cd,
	val_rndg_rl,
	dflt_excs_trtmt_cd,
	dflt_excs_trtmt_rl,
	rlovr_rstrcn_cd,
	no_mn_dstrbl_pct_flag,
	no_mn_dstrbl_val_flag,
	no_mx_dstrbl_pct_flag,
	no_mx_dstrbl_val_flag,
        auto_alct_excs_flag,
        alws_ngtv_crs_flag ,
        uses_net_crs_mthd_flag,
        mx_dfcit_pct_pool_crs_num ,
        mx_dfcit_pct_comp_num ,
        comp_lvl_fctr_id,
	mn_dstrbl_pct_num,
	mn_dstrbl_val,
	mx_dstrbl_pct_num,
	mx_dstrbl_val,
	excs_trtmt_cd,
	ptip_id,
	plip_id,
	pgm_id,
	oiplip_id,
	cmbn_plip_id,
	cmbn_ptip_id,
	cmbn_ptip_opt_id,
	business_group_id,
	bpp_attribute_category,
	bpp_attribute1,
	bpp_attribute2,
	bpp_attribute3,
	bpp_attribute4,
	bpp_attribute5,
	bpp_attribute6,
	bpp_attribute7,
	bpp_attribute8,
	bpp_attribute9,
	bpp_attribute10,
	bpp_attribute11,
	bpp_attribute12,
	bpp_attribute13,
	bpp_attribute14,
	bpp_attribute15,
	bpp_attribute16,
	bpp_attribute17,
	bpp_attribute18,
	bpp_attribute19,
	bpp_attribute20,
	bpp_attribute21,
	bpp_attribute22,
	bpp_attribute23,
	bpp_attribute24,
	bpp_attribute25,
	bpp_attribute26,
	bpp_attribute27,
	bpp_attribute28,
	bpp_attribute29,
	bpp_attribute30,
	object_version_number,
   	created_by,
   	creation_date,
   	last_update_date,
   	last_updated_by,
   	last_update_login
  )
  Values
  (	p_rec.bnft_prvdr_pool_id,
	p_rec.effective_start_date,
	p_rec.effective_end_date,
	p_rec.name,
	p_rec.pgm_pool_flag,
	p_rec.excs_alwys_fftd_flag,
	p_rec.use_for_pgm_pool_flag,
	p_rec.pct_rndg_cd,
	p_rec.pct_rndg_rl,
	p_rec.val_rndg_cd,
	p_rec.val_rndg_rl,
	p_rec.dflt_excs_trtmt_cd,
	p_rec.dflt_excs_trtmt_rl,
	p_rec.rlovr_rstrcn_cd,
	p_rec.no_mn_dstrbl_pct_flag,
	p_rec.no_mn_dstrbl_val_flag,
	p_rec.no_mx_dstrbl_pct_flag,
	p_rec.no_mx_dstrbl_val_flag,
        p_rec.auto_alct_excs_flag,
        p_rec.alws_ngtv_crs_flag ,
        p_rec.uses_net_crs_mthd_flag,
        p_rec.mx_dfcit_pct_pool_crs_num ,
        p_rec.mx_dfcit_pct_comp_num ,
        p_rec.comp_lvl_fctr_id,
	p_rec.mn_dstrbl_pct_num,
	p_rec.mn_dstrbl_val,
	p_rec.mx_dstrbl_pct_num,
	p_rec.mx_dstrbl_val,
	p_rec.excs_trtmt_cd,
	p_rec.ptip_id,
	p_rec.plip_id,
	p_rec.pgm_id,
	p_rec.oiplip_id,
	p_rec.cmbn_plip_id,
	p_rec.cmbn_ptip_id,
	p_rec.cmbn_ptip_opt_id,
	p_rec.business_group_id,
	p_rec.bpp_attribute_category,
	p_rec.bpp_attribute1,
	p_rec.bpp_attribute2,
	p_rec.bpp_attribute3,
	p_rec.bpp_attribute4,
	p_rec.bpp_attribute5,
	p_rec.bpp_attribute6,
	p_rec.bpp_attribute7,
	p_rec.bpp_attribute8,
	p_rec.bpp_attribute9,
	p_rec.bpp_attribute10,
	p_rec.bpp_attribute11,
	p_rec.bpp_attribute12,
	p_rec.bpp_attribute13,
	p_rec.bpp_attribute14,
	p_rec.bpp_attribute15,
	p_rec.bpp_attribute16,
	p_rec.bpp_attribute17,
	p_rec.bpp_attribute18,
	p_rec.bpp_attribute19,
	p_rec.bpp_attribute20,
	p_rec.bpp_attribute21,
	p_rec.bpp_attribute22,
	p_rec.bpp_attribute23,
	p_rec.bpp_attribute24,
	p_rec.bpp_attribute25,
	p_rec.bpp_attribute26,
	p_rec.bpp_attribute27,
	p_rec.bpp_attribute28,
	p_rec.bpp_attribute29,
	p_rec.bpp_attribute30,
	p_rec.object_version_number ,
	l_created_by,
   	l_creation_date,
   	l_last_update_date,
   	l_last_updated_by,
   	l_last_update_login
  );
  --

  ben_bpp_shd.g_api_dml := false;   -- Unset the api dml status
  hr_utility.set_location(' Leaving:'||l_proc, 15);
--
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    ben_bpp_shd.g_api_dml := false;   -- Unset the api dml status
    ben_bpp_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    ben_bpp_shd.g_api_dml := false;   -- Unset the api dml status
    ben_bpp_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    ben_bpp_shd.g_api_dml := false;   -- Unset the api dml status
    Raise;
End dt_insert_dml;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< insert_dml >------------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_dml
	(p_rec 			 in out nocopy ben_bpp_shd.g_rec_type,
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
	(p_rec  			in out nocopy ben_bpp_shd.g_rec_type,
	 p_effective_date		in date,
	 p_datetrack_mode		in varchar2,
	 p_validation_start_date	in date,
	 p_validation_end_date		in date) is
--
  l_proc	varchar2(72) := g_package||'pre_insert';
--
  CURSOR c1 is
    select ben_bnft_prvdr_pool_f_s.nextval
    from   sys.dual;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  open c1;
  fetch c1 into p_rec.bnft_prvdr_pool_id;
  close c1;
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
	(p_rec 			 in ben_bpp_shd.g_rec_type,
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
    ben_bpp_rki.after_insert
      (
  p_bnft_prvdr_pool_id             => p_rec.bnft_prvdr_pool_id
 ,p_effective_start_date           => p_rec.effective_start_date
 ,p_effective_end_date             => p_rec.effective_end_date
 ,p_name                           => p_rec.name
 ,p_pgm_pool_flag                  => p_rec.pgm_pool_flag
 ,p_excs_alwys_fftd_flag           => p_rec.excs_alwys_fftd_flag
 ,p_use_for_pgm_pool_flag          => p_rec.use_for_pgm_pool_flag
 ,p_pct_rndg_cd                    => p_rec.pct_rndg_cd
 ,p_pct_rndg_rl                    => p_rec.pct_rndg_rl
 ,p_val_rndg_cd                    => p_rec.val_rndg_cd
 ,p_val_rndg_rl                    => p_rec.val_rndg_rl
 ,p_dflt_excs_trtmt_cd             => p_rec.dflt_excs_trtmt_cd
 ,p_dflt_excs_trtmt_rl             => p_rec.dflt_excs_trtmt_rl
 ,p_rlovr_rstrcn_cd                => p_rec.rlovr_rstrcn_cd
 ,p_no_mn_dstrbl_pct_flag          => p_rec.no_mn_dstrbl_pct_flag
 ,p_no_mn_dstrbl_val_flag          => p_rec.no_mn_dstrbl_val_flag
 ,p_no_mx_dstrbl_pct_flag          => p_rec.no_mx_dstrbl_pct_flag
 ,p_no_mx_dstrbl_val_flag          => p_rec.no_mx_dstrbl_val_flag
 ,p_auto_alct_excs_flag            => p_rec.auto_alct_excs_flag
 ,p_alws_ngtv_crs_flag             => p_rec.alws_ngtv_crs_flag
 ,p_uses_net_crs_mthd_flag         => p_rec.uses_net_crs_mthd_flag
 ,p_mx_dfcit_pct_pool_crs_num      => p_rec.mx_dfcit_pct_pool_crs_num
 ,p_mx_dfcit_pct_comp_num           => p_rec.mx_dfcit_pct_comp_num
 ,p_comp_lvl_fctr_id               => p_rec.comp_lvl_fctr_id
 ,p_mn_dstrbl_pct_num              => p_rec.mn_dstrbl_pct_num
 ,p_mn_dstrbl_val                  => p_rec.mn_dstrbl_val
 ,p_mx_dstrbl_pct_num              => p_rec.mx_dstrbl_pct_num
 ,p_mx_dstrbl_val                  => p_rec.mx_dstrbl_val
 ,p_excs_trtmt_cd                  => p_rec.excs_trtmt_cd
 ,p_ptip_id                        => p_rec.ptip_id
 ,p_plip_id                        => p_rec.plip_id
 ,p_pgm_id                         => p_rec.pgm_id
 ,p_oiplip_id                      => p_rec.oiplip_id
 ,p_cmbn_plip_id                   => p_rec.cmbn_plip_id
 ,p_cmbn_ptip_id                   => p_rec.cmbn_ptip_id
 ,p_cmbn_ptip_opt_id               => p_rec.cmbn_ptip_opt_id
 ,p_business_group_id              => p_rec.business_group_id
 ,p_bpp_attribute_category         => p_rec.bpp_attribute_category
 ,p_bpp_attribute1                 => p_rec.bpp_attribute1
 ,p_bpp_attribute2                 => p_rec.bpp_attribute2
 ,p_bpp_attribute3                 => p_rec.bpp_attribute3
 ,p_bpp_attribute4                 => p_rec.bpp_attribute4
 ,p_bpp_attribute5                 => p_rec.bpp_attribute5
 ,p_bpp_attribute6                 => p_rec.bpp_attribute6
 ,p_bpp_attribute7                 => p_rec.bpp_attribute7
 ,p_bpp_attribute8                 => p_rec.bpp_attribute8
 ,p_bpp_attribute9                 => p_rec.bpp_attribute9
 ,p_bpp_attribute10                => p_rec.bpp_attribute10
 ,p_bpp_attribute11                => p_rec.bpp_attribute11
 ,p_bpp_attribute12                => p_rec.bpp_attribute12
 ,p_bpp_attribute13                => p_rec.bpp_attribute13
 ,p_bpp_attribute14                => p_rec.bpp_attribute14
 ,p_bpp_attribute15                => p_rec.bpp_attribute15
 ,p_bpp_attribute16                => p_rec.bpp_attribute16
 ,p_bpp_attribute17                => p_rec.bpp_attribute17
 ,p_bpp_attribute18                => p_rec.bpp_attribute18
 ,p_bpp_attribute19                => p_rec.bpp_attribute19
 ,p_bpp_attribute20                => p_rec.bpp_attribute20
 ,p_bpp_attribute21                => p_rec.bpp_attribute21
 ,p_bpp_attribute22                => p_rec.bpp_attribute22
 ,p_bpp_attribute23                => p_rec.bpp_attribute23
 ,p_bpp_attribute24                => p_rec.bpp_attribute24
 ,p_bpp_attribute25                => p_rec.bpp_attribute25
 ,p_bpp_attribute26                => p_rec.bpp_attribute26
 ,p_bpp_attribute27                => p_rec.bpp_attribute27
 ,p_bpp_attribute28                => p_rec.bpp_attribute28
 ,p_bpp_attribute29                => p_rec.bpp_attribute29
 ,p_bpp_attribute30                => p_rec.bpp_attribute30
 ,p_object_version_number          => p_rec.object_version_number
 ,p_effective_date                 => p_effective_date
 ,p_validation_start_date          => p_validation_start_date
 ,p_validation_end_date            => p_validation_end_date
  );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'ben_bnft_prvdr_pool_f'
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
	 p_rec	 		 in  ben_bpp_shd.g_rec_type,
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
	 p_base_table_name	   => 'ben_bnft_prvdr_pool_f',
	 p_base_key_column	   => 'bnft_prvdr_pool_id',
	 p_base_key_value 	   => p_rec.bnft_prvdr_pool_id,
	 p_parent_table_name1      => 'ben_pgm_f',
	 p_parent_key_column1      => 'pgm_id',
	 p_parent_key_value1       => p_rec.pgm_id,
	 p_parent_table_name2      => 'ben_plip_f',
	 p_parent_key_column2      => 'plip_id',
	 p_parent_key_value2       => p_rec.plip_id,
	 p_parent_table_name3      => 'ben_ptip_f',
	 p_parent_key_column3      => 'ptip_id',
	 p_parent_key_value3       => p_rec.ptip_id,
	 p_parent_table_name4      => 'ben_cmbn_plip_f',
	 p_parent_key_column4      => 'cmbn_plip_id',
	 p_parent_key_value4       => p_rec.cmbn_plip_id,
	 p_parent_table_name5      => 'ben_cmbn_ptip_f',
	 p_parent_key_column5      => 'cmbn_ptip_id',
	 p_parent_key_value5       => p_rec.cmbn_ptip_id,
	 p_parent_table_name6      => 'ben_cmbn_ptip_opt_f',
	 p_parent_key_column6      => 'cmbn_ptip_opt_id',
	 p_parent_key_value6       => p_rec.cmbn_ptip_opt_id,
	 p_parent_table_name7      => 'ben_oiplip_f',
	 p_parent_key_column7      => 'oiplip_id',
	 p_parent_key_value7       => p_rec.oiplip_id,
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
  p_rec		   in out nocopy ben_bpp_shd.g_rec_type,
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
  ben_bpp_bus.insert_validate
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
  p_bnft_prvdr_pool_id           out nocopy number,
  p_effective_start_date         out nocopy date,
  p_effective_end_date           out nocopy date,
  p_name                         in varchar2,
  p_pgm_pool_flag                in varchar2,
  p_excs_alwys_fftd_flag         in varchar2,
  p_use_for_pgm_pool_flag        in varchar2,
  p_pct_rndg_cd                  in varchar2         default null,
  p_pct_rndg_rl                  in number           default null,
  p_val_rndg_cd                  in varchar2         default null,
  p_val_rndg_rl                  in number           default null,
  p_dflt_excs_trtmt_cd           in varchar2         default null,
  p_dflt_excs_trtmt_rl           in number           default null,
  p_rlovr_rstrcn_cd              in varchar2         default null,
  p_no_mn_dstrbl_pct_flag        in varchar2,
  p_no_mn_dstrbl_val_flag        in varchar2,
  p_no_mx_dstrbl_pct_flag        in varchar2,
  p_no_mx_dstrbl_val_flag        in varchar2,
  p_auto_alct_excs_flag          in varchar2         default 'N',
  p_alws_ngtv_crs_flag           in varchar2         default 'N',
  p_uses_net_crs_mthd_flag       in varchar2         default 'N',
  p_mx_dfcit_pct_pool_crs_num    in number           default null,
  p_mx_dfcit_pct_comp_num         in number           default null,
  p_comp_lvl_fctr_id             in number           default null,
  p_mn_dstrbl_pct_num            in number           default null,
  p_mn_dstrbl_val                in number           default null,
  p_mx_dstrbl_pct_num            in number           default null,
  p_mx_dstrbl_val                in number           default null,
  p_excs_trtmt_cd                in varchar2         default null,
  p_ptip_id                      in number           default null,
  p_plip_id                      in number           default null,
  p_pgm_id                       in number,
  p_oiplip_id                    in number           default null,
  p_cmbn_plip_id                 in number           default null,
  p_cmbn_ptip_id                 in number           default null,
  p_cmbn_ptip_opt_id             in number           default null,
  p_business_group_id            in number,
  p_bpp_attribute_category       in varchar2         default null,
  p_bpp_attribute1               in varchar2         default null,
  p_bpp_attribute2               in varchar2         default null,
  p_bpp_attribute3               in varchar2         default null,
  p_bpp_attribute4               in varchar2         default null,
  p_bpp_attribute5               in varchar2         default null,
  p_bpp_attribute6               in varchar2         default null,
  p_bpp_attribute7               in varchar2         default null,
  p_bpp_attribute8               in varchar2         default null,
  p_bpp_attribute9               in varchar2         default null,
  p_bpp_attribute10              in varchar2         default null,
  p_bpp_attribute11              in varchar2         default null,
  p_bpp_attribute12              in varchar2         default null,
  p_bpp_attribute13              in varchar2         default null,
  p_bpp_attribute14              in varchar2         default null,
  p_bpp_attribute15              in varchar2         default null,
  p_bpp_attribute16              in varchar2         default null,
  p_bpp_attribute17              in varchar2         default null,
  p_bpp_attribute18              in varchar2         default null,
  p_bpp_attribute19              in varchar2         default null,
  p_bpp_attribute20              in varchar2         default null,
  p_bpp_attribute21              in varchar2         default null,
  p_bpp_attribute22              in varchar2         default null,
  p_bpp_attribute23              in varchar2         default null,
  p_bpp_attribute24              in varchar2         default null,
  p_bpp_attribute25              in varchar2         default null,
  p_bpp_attribute26              in varchar2         default null,
  p_bpp_attribute27              in varchar2         default null,
  p_bpp_attribute28              in varchar2         default null,
  p_bpp_attribute29              in varchar2         default null,
  p_bpp_attribute30              in varchar2         default null,
  p_object_version_number        out nocopy number,
  p_effective_date		 in date
  ) is
--
  l_rec		ben_bpp_shd.g_rec_type;
  l_proc	varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  ben_bpp_shd.convert_args
  (
  null,
  null,
  null,
  p_name,
  p_pgm_pool_flag,
  p_excs_alwys_fftd_flag,
  p_use_for_pgm_pool_flag,
  p_pct_rndg_cd,
  p_pct_rndg_rl,
  p_val_rndg_cd,
  p_val_rndg_rl,
  p_dflt_excs_trtmt_cd,
  p_dflt_excs_trtmt_rl,
  p_rlovr_rstrcn_cd,
  p_no_mn_dstrbl_pct_flag,
  p_no_mn_dstrbl_val_flag,
  p_no_mx_dstrbl_pct_flag,
  p_no_mx_dstrbl_val_flag,
  p_auto_alct_excs_flag,
  p_alws_ngtv_crs_flag ,
  p_uses_net_crs_mthd_flag,
  p_mx_dfcit_pct_pool_crs_num ,
  p_mx_dfcit_pct_comp_num ,
  p_comp_lvl_fctr_id,
  p_mn_dstrbl_pct_num,
  p_mn_dstrbl_val,
  p_mx_dstrbl_pct_num,
  p_mx_dstrbl_val,
  p_excs_trtmt_cd,
  p_ptip_id,
  p_plip_id,
  p_pgm_id,
  p_oiplip_id,
  p_cmbn_plip_id,
  p_cmbn_ptip_id,
  p_cmbn_ptip_opt_id,
  p_business_group_id,
  p_bpp_attribute_category,
  p_bpp_attribute1,
  p_bpp_attribute2,
  p_bpp_attribute3,
  p_bpp_attribute4,
  p_bpp_attribute5,
  p_bpp_attribute6,
  p_bpp_attribute7,
  p_bpp_attribute8,
  p_bpp_attribute9,
  p_bpp_attribute10,
  p_bpp_attribute11,
  p_bpp_attribute12,
  p_bpp_attribute13,
  p_bpp_attribute14,
  p_bpp_attribute15,
  p_bpp_attribute16,
  p_bpp_attribute17,
  p_bpp_attribute18,
  p_bpp_attribute19,
  p_bpp_attribute20,
  p_bpp_attribute21,
  p_bpp_attribute22,
  p_bpp_attribute23,
  p_bpp_attribute24,
  p_bpp_attribute25,
  p_bpp_attribute26,
  p_bpp_attribute27,
  p_bpp_attribute28,
  p_bpp_attribute29,
  p_bpp_attribute30,
  null
  );
  --
  -- Having converted the arguments into the ben_bpp_rec
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  ins(l_rec, p_effective_date);
  --
  -- Set the OUT arguments.
  --
  p_bnft_prvdr_pool_id        	:= l_rec.bnft_prvdr_pool_id;
  p_effective_start_date  	:= l_rec.effective_start_date;
  p_effective_end_date    	:= l_rec.effective_end_date;
  p_object_version_number 	:= l_rec.object_version_number;
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End ins;
--
end ben_bpp_ins;

/
