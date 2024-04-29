--------------------------------------------------------
--  DDL for Package Body BEN_PGM_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PGM_INS" as
/* $Header: bepgmrhi.pkb 120.1 2005/12/09 05:02:29 nhunur noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_pgm_ins.';  -- Global package name
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
	(p_rec 			 in out nocopy ben_pgm_shd.g_rec_type,
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
    from   ben_pgm_f t
    where  t.pgm_id       = p_rec.pgm_id
    and    t.effective_start_date =
             ben_pgm_shd.g_old_rec.effective_start_date
    and    t.effective_end_date   = (p_validation_start_date - 1);
--
  l_proc		varchar2(72) := g_package||'dt_insert_dml';
  l_created_by          ben_pgm_f.created_by%TYPE;
  l_creation_date       ben_pgm_f.creation_date%TYPE;
  l_last_update_date   	ben_pgm_f.last_update_date%TYPE;
  l_last_updated_by     ben_pgm_f.last_updated_by%TYPE;
  l_last_update_login   ben_pgm_f.last_update_login%TYPE;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Get the object version number for the insert
  --
  p_rec.object_version_number :=
    dt_api.get_object_version_number
	(p_base_table_name => 'ben_pgm_f',
	 p_base_key_column => 'pgm_id',
	 p_base_key_value  => p_rec.pgm_id);
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
  ben_pgm_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Insert the row into: ben_pgm_f
  --
  insert into ben_pgm_f
  (	pgm_id,
	effective_start_date,
	effective_end_date,
	name,
	dpnt_adrs_rqd_flag,
	pgm_prvds_no_auto_enrt_flag,
	dpnt_dob_rqd_flag,
	pgm_prvds_no_dflt_enrt_flag,
	dpnt_dsgn_lvl_cd,
	dpnt_legv_id_rqd_flag,
	pgm_stat_cd,
	ivr_ident,
	pgm_typ_cd,
	elig_apls_flag,
	uses_all_asmts_for_rts_flag,
	url_ref_name,
	pgm_desc,
	prtn_elig_ovrid_alwd_flag,
	pgm_use_all_asnts_elig_flag,
	dpnt_dsgn_cd,
	mx_dpnt_pct_prtt_lf_amt,
	mx_sps_pct_prtt_lf_amt,
	coord_cvg_for_all_pls_flg,
        enrt_cvg_end_dt_cd,
        enrt_cvg_end_dt_rl,
	pgm_grp_cd,
	acty_ref_perd_cd,
	drvbl_fctr_dpnt_elig_flag,
	pgm_uom,
	enrt_info_rt_freq_cd,
	drvbl_fctr_prtn_elig_flag,
	drvbl_fctr_apls_rts_flag,
        alws_unrstrctd_enrt_flag,
        enrt_cd,
        enrt_mthd_cd,
        poe_lvl_cd,
        enrt_rl,
        auto_enrt_mthd_rl,
	dpnt_dsgn_no_ctfn_rqd_flag,
        enrt_cvg_strt_dt_cd,
        enrt_cvg_strt_dt_rl,
        rt_end_dt_cd,
        rt_end_dt_rl,
        rt_strt_dt_cd,
        rt_strt_dt_rl,
	dpnt_cvg_strt_dt_cd,
	dpnt_cvg_strt_dt_rl,
	dpnt_cvg_end_dt_rl,
	dpnt_cvg_end_dt_cd,
	trk_inelig_per_flag,
	business_group_id,
        per_cvrd_cd  ,
        vrfy_fmly_mmbr_rl,
        vrfy_fmly_mmbr_cd,
        short_name,   		/*FHR*/
        short_code, 	        /*FHR*/
                legislation_code, 	        /*FHR*/
                legislation_subgroup, 	        /*FHR*/
        Dflt_pgm_flag,
        Use_prog_points_flag,
        Dflt_step_cd,
        Dflt_step_rl,
        Update_salary_cd,
        Use_multi_pay_rates_flag,
        dflt_element_type_id,
        Dflt_input_value_id,
        Use_scores_cd,
        Scores_calc_mthd_cd,
        Scores_calc_rl,
	gsp_allow_override_flag,
	use_variable_rates_flag,
	salary_calc_mthd_cd,
	salary_calc_mthd_rl,
        susp_if_dpnt_ssn_nt_prv_cd,
        susp_if_dpnt_dob_nt_prv_cd,
        susp_if_dpnt_adr_nt_prv_cd,
        susp_if_ctfn_not_dpnt_flag,
        dpnt_ctfn_determine_cd,
	pgm_attribute_category,
	pgm_attribute1,
	pgm_attribute2,
	pgm_attribute3,
	pgm_attribute4,
	pgm_attribute5,
	pgm_attribute6,
	pgm_attribute7,
	pgm_attribute8,
	pgm_attribute9,
	pgm_attribute10,
	pgm_attribute11,
	pgm_attribute12,
	pgm_attribute13,
	pgm_attribute14,
	pgm_attribute15,
	pgm_attribute16,
	pgm_attribute17,
	pgm_attribute18,
	pgm_attribute19,
	pgm_attribute20,
	pgm_attribute21,
	pgm_attribute22,
	pgm_attribute23,
	pgm_attribute24,
	pgm_attribute25,
	pgm_attribute26,
	pgm_attribute27,
	pgm_attribute28,
	pgm_attribute29,
	pgm_attribute30,
	object_version_number
   	, created_by,
   	creation_date,
   	last_update_date,
   	last_updated_by,
   	last_update_login
  )
  Values
  (	p_rec.pgm_id,
	p_rec.effective_start_date,
	p_rec.effective_end_date,
	p_rec.name,
	p_rec.dpnt_adrs_rqd_flag,
	p_rec.pgm_prvds_no_auto_enrt_flag,
	p_rec.dpnt_dob_rqd_flag,
	p_rec.pgm_prvds_no_dflt_enrt_flag,
	p_rec.dpnt_dsgn_lvl_cd,
	p_rec.dpnt_legv_id_rqd_flag,
	p_rec.pgm_stat_cd,
	p_rec.ivr_ident,
	p_rec.pgm_typ_cd,
	p_rec.elig_apls_flag,
	p_rec.uses_all_asmts_for_rts_flag,
	p_rec.url_ref_name,
	p_rec.pgm_desc,
	p_rec.prtn_elig_ovrid_alwd_flag,
	p_rec.pgm_use_all_asnts_elig_flag,
	p_rec.dpnt_dsgn_cd,
	p_rec.mx_dpnt_pct_prtt_lf_amt,
	p_rec.mx_sps_pct_prtt_lf_amt,
	p_rec.coord_cvg_for_all_pls_flg,
        p_rec.enrt_cvg_end_dt_cd,
        p_rec.enrt_cvg_end_dt_rl,
	p_rec.pgm_grp_cd,
	p_rec.acty_ref_perd_cd,
	p_rec.drvbl_fctr_dpnt_elig_flag,
	p_rec.pgm_uom,
	p_rec.enrt_info_rt_freq_cd,
	p_rec.drvbl_fctr_prtn_elig_flag,
	p_rec.drvbl_fctr_apls_rts_flag,
        p_rec.alws_unrstrctd_enrt_flag,
        p_rec.enrt_cd,
        p_rec.enrt_mthd_cd,
        p_rec.poe_lvl_cd,
        p_rec.enrt_rl,
        p_rec.auto_enrt_mthd_rl,
	p_rec.dpnt_dsgn_no_ctfn_rqd_flag,
        p_rec.enrt_cvg_strt_dt_cd,
        p_rec.enrt_cvg_strt_dt_rl,
        p_rec.rt_end_dt_cd,
        p_rec.rt_end_dt_rl,
        p_rec.rt_strt_dt_cd,
        p_rec.rt_strt_dt_rl,
	p_rec.dpnt_cvg_strt_dt_cd,
	p_rec.dpnt_cvg_strt_dt_rl,
	p_rec.dpnt_cvg_end_dt_rl,
	p_rec.dpnt_cvg_end_dt_cd,
	p_rec.trk_inelig_per_flag,
	p_rec.business_group_id,
        P_rec.per_cvrd_cd  ,
        P_rec.vrfy_fmly_mmbr_rl,
        P_rec.vrfy_fmly_mmbr_cd,
        p_rec.short_name, 		/*FHR*/
        p_rec.short_code,		/*FHR*/
                p_rec.legislation_code,		/*FHR*/
                p_rec.legislation_subgroup,		/*FHR*/
        p_rec.Dflt_pgm_flag,
        p_rec.Use_prog_points_flag,
        p_rec.Dflt_step_cd,
        p_rec.Dflt_step_rl,
        p_rec.Update_salary_cd,
        p_rec.Use_multi_pay_rates_flag,
        p_rec.dflt_element_type_id,
        p_rec.Dflt_input_value_id,
        p_rec.Use_scores_cd,
        p_rec.Scores_calc_mthd_cd,
        p_rec.Scores_calc_rl,
        p_rec.gsp_allow_override_flag,
        p_rec.use_variable_rates_flag,
        p_rec.salary_calc_mthd_cd,
        p_rec.salary_calc_mthd_rl,
        p_rec.susp_if_dpnt_ssn_nt_prv_cd,
        p_rec.susp_if_dpnt_dob_nt_prv_cd,
        p_rec.susp_if_dpnt_adr_nt_prv_cd,
        p_rec.susp_if_ctfn_not_dpnt_flag,
        p_rec.dpnt_ctfn_determine_cd,
        p_rec.pgm_attribute_category,
	p_rec.pgm_attribute1,
	p_rec.pgm_attribute2,
	p_rec.pgm_attribute3,
	p_rec.pgm_attribute4,
	p_rec.pgm_attribute5,
	p_rec.pgm_attribute6,
	p_rec.pgm_attribute7,
	p_rec.pgm_attribute8,
	p_rec.pgm_attribute9,
	p_rec.pgm_attribute10,
	p_rec.pgm_attribute11,
	p_rec.pgm_attribute12,
	p_rec.pgm_attribute13,
	p_rec.pgm_attribute14,
	p_rec.pgm_attribute15,
	p_rec.pgm_attribute16,
	p_rec.pgm_attribute17,
	p_rec.pgm_attribute18,
	p_rec.pgm_attribute19,
	p_rec.pgm_attribute20,
	p_rec.pgm_attribute21,
	p_rec.pgm_attribute22,
	p_rec.pgm_attribute23,
	p_rec.pgm_attribute24,
	p_rec.pgm_attribute25,
	p_rec.pgm_attribute26,
	p_rec.pgm_attribute27,
	p_rec.pgm_attribute28,
	p_rec.pgm_attribute29,
	p_rec.pgm_attribute30,
	p_rec.object_version_number
	, l_created_by,
   	l_creation_date,
   	l_last_update_date,
   	l_last_updated_by,
   	l_last_update_login
  );
  --
  ben_pgm_shd.g_api_dml := false;   -- Unset the api dml status
  hr_utility.set_location(' Leaving:'||l_proc, 15);
--
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    ben_pgm_shd.g_api_dml := false;   -- Unset the api dml status
    ben_pgm_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    ben_pgm_shd.g_api_dml := false;   -- Unset the api dml status
    ben_pgm_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    ben_pgm_shd.g_api_dml := false;   -- Unset the api dml status
    Raise;
End dt_insert_dml;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< insert_dml >------------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_dml
	(p_rec 			 in out nocopy ben_pgm_shd.g_rec_type,
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
	(p_rec  			in out nocopy ben_pgm_shd.g_rec_type,
	 p_effective_date		in date,
	 p_datetrack_mode		in varchar2,
	 p_validation_start_date	in date,
	 p_validation_end_date		in date) is
--
  l_proc	varchar2(72) := g_package||'pre_insert';
--
cursor c1 is
      select ben_pgm_f_s.nextval
      from sys.dual;
--
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
      open c1;
        fetch c1 into p_rec.pgm_id;
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
	(p_rec 			 in ben_pgm_shd.g_rec_type,
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
  -- Added for GSP validations
  pqh_gsp_ben_validations.pgm_validations
  	(  p_pgm_id			=> p_rec.pgm_id
  	 , p_dml_operation 		=> 'I'
  	 , p_effective_date 		=> p_effective_date
  	 , p_business_group_id  	=> p_rec.business_group_id
  	 , p_short_name			=> p_rec.short_name
  	 , p_short_code			=> p_rec.short_code
  	 , p_Dflt_Pgm_Flag		=> p_rec.Dflt_Pgm_Flag
  	 , p_Pgm_Typ_Cd			=> p_rec.Pgm_Typ_Cd
  	 , p_pgm_Stat_cd		=> p_rec.pgm_Stat_cd
  	 , p_Use_Prog_Points_Flag	=> p_rec.Use_Prog_Points_Flag
  	 , p_Acty_Ref_Perd_Cd		=> p_rec.Acty_Ref_Perd_Cd
  	 , p_Pgm_Uom			=> p_rec.Pgm_Uom
  	 );

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
	 p_rec	 		 in  ben_pgm_shd.g_rec_type,
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
	 (p_datetrack_mode	   => p_datetrack_mode,
	 p_effective_date	   => p_effective_date,
	 p_base_table_name	   => 'ben_pgm_f',
	 p_base_key_column	   => 'pgm_id',
	 p_base_key_value 	   => p_rec.pgm_id,
	 p_parent_table_name1      => 'ff_formulas_f',
	 p_parent_key_column1      => 'formula_id',
	 p_parent_key_value1       => p_rec.enrt_cvg_strt_dt_rl,
	 p_parent_table_name2      => 'ff_formulas_f',
	 p_parent_key_column2      => 'formula_id',
	 p_parent_key_value2       => p_rec.enrt_cvg_end_dt_rl,
	 p_parent_table_name3      => 'ff_formulas_f',
	 p_parent_key_column3      => 'formula_id',
	 p_parent_key_value3       => p_rec.dpnt_cvg_strt_dt_rl,
	 p_parent_table_name4      => 'ff_formulas_f',
	 p_parent_key_column4      => 'formula_id',
	 p_parent_key_value4       => p_rec.dpnt_cvg_end_dt_rl,
	 p_parent_table_name5      => 'ff_formulas_f',
	 p_parent_key_column5      => 'formula_id',
	 p_parent_key_value5       => p_rec.rt_end_dt_rl,
	 p_parent_table_name6      => 'ff_formulas_f',
	 p_parent_key_column6      => 'formula_id',
	 p_parent_key_value6       => p_rec.rt_strt_dt_rl,
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
  p_rec		   in out nocopy ben_pgm_shd.g_rec_type,
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
  ben_pgm_bus.insert_validate
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
  p_pgm_id                       out nocopy number,
  p_effective_start_date         out nocopy date,
  p_effective_end_date           out nocopy date,
  p_name                         in varchar2,
  p_dpnt_adrs_rqd_flag           in varchar2,
  p_pgm_prvds_no_auto_enrt_flag  in varchar2,
  p_dpnt_dob_rqd_flag            in varchar2,
  p_pgm_prvds_no_dflt_enrt_flag  in varchar2,
  p_dpnt_legv_id_rqd_flag        in varchar2,
  p_dpnt_dsgn_lvl_cd             in varchar2         default null,
  p_pgm_stat_cd                  in varchar2         default null,
  p_ivr_ident                    in varchar2         default null,
  p_pgm_typ_cd                   in varchar2         default null,
  p_elig_apls_flag               in varchar2,
  p_uses_all_asmts_for_rts_flag  in varchar2,
  p_url_ref_name                 in varchar2,
  p_pgm_desc                     in varchar2         default null,
  p_prtn_elig_ovrid_alwd_flag    in varchar2,
  p_pgm_use_all_asnts_elig_flag  in varchar2,
  p_dpnt_dsgn_cd                 in varchar2         default null,
  p_mx_dpnt_pct_prtt_lf_amt      in number           default null,
  p_mx_sps_pct_prtt_lf_amt       in number           default null,
  p_acty_ref_perd_cd             in varchar2         default null,
  p_coord_cvg_for_all_pls_flg    in varchar2,
  p_enrt_cvg_end_dt_cd           in varchar2         default null,
  p_enrt_cvg_end_dt_rl           in number           default null,
  p_dpnt_cvg_end_dt_cd           in varchar2         default null,
  p_dpnt_cvg_end_dt_rl           in number           default null,
  p_dpnt_cvg_strt_dt_cd          in varchar2         default null,
  p_dpnt_cvg_strt_dt_rl          in number           default null,
  p_dpnt_dsgn_no_ctfn_rqd_flag   in varchar2,
  p_drvbl_fctr_dpnt_elig_flag    in varchar2,
  p_drvbl_fctr_prtn_elig_flag    in varchar2,
  p_enrt_cvg_strt_dt_cd          in varchar2         default null,
  p_enrt_cvg_strt_dt_rl          in number           default null,
  p_enrt_info_rt_freq_cd         in varchar2         default null,
  p_rt_strt_dt_cd                in varchar2         default null,
  p_rt_strt_dt_rl                in number           default null,
  p_rt_end_dt_cd                 in varchar2         default null,
  p_rt_end_dt_rl                 in number           default null,
  p_pgm_grp_cd                   in varchar2         default null,
  p_pgm_uom                      in varchar2         default null,
  p_drvbl_fctr_apls_rts_flag     in varchar2,
  p_alws_unrstrctd_enrt_flag     in varchar2,
  p_enrt_cd                      in varchar2,
  p_enrt_mthd_cd                 in varchar2,
  p_poe_lvl_cd                   in varchar2         default null,
  p_enrt_rl                      in number,
  p_auto_enrt_mthd_rl            in number,
  p_trk_inelig_per_flag          in varchar2,
  p_business_group_id            in number,
  p_per_cvrd_cd                  in  varchar2        default null,
  P_vrfy_fmly_mmbr_rl            in  number          default null,
  P_vrfy_fmly_mmbr_cd            in  varchar2        default null,
  p_short_name			 in varchar2	     default null, 	--FHR
  p_short_code			 in varchar2	     default null, 	--FHR
    p_legislation_code			 in varchar2	     default null,
    p_legislation_subgroup			 in varchar2	     default null,
  p_Dflt_pgm_flag                in  Varchar2        default null,
  p_Use_prog_points_flag         in  Varchar2        default null,
  p_Dflt_step_cd                 in  Varchar2        default null,
  p_Dflt_step_rl                 in  number          default null,
  p_Update_salary_cd             in  Varchar2        default null,
  p_Use_multi_pay_rates_flag     in  Varchar2        default null,
  p_dflt_element_type_id         in  number          default null,
  p_Dflt_input_value_id          in  number          default null,
  p_Use_scores_cd                in  Varchar2        default null,
  p_Scores_calc_mthd_cd          in  Varchar2        default null,
  p_Scores_calc_rl               in  number          default null,
  p_gsp_allow_override_flag       in varchar2         default null,
  p_use_variable_rates_flag       in varchar2         default null,
  p_salary_calc_mthd_cd       in varchar2         default null,
  p_salary_calc_mthd_rl       in number         default null,
  p_susp_if_dpnt_ssn_nt_prv_cd      in  varchar2   default null,
  p_susp_if_dpnt_dob_nt_prv_cd      in  varchar2   default null,
  p_susp_if_dpnt_adr_nt_prv_cd      in  varchar2   default null,
  p_susp_if_ctfn_not_dpnt_flag      in  varchar2   default 'Y',
  p_dpnt_ctfn_determine_cd          in  varchar2   default null,
  p_pgm_attribute_category       in varchar2         default null,
  p_pgm_attribute1               in varchar2         default null,
  p_pgm_attribute2               in varchar2         default null,
  p_pgm_attribute3               in varchar2         default null,
  p_pgm_attribute4               in varchar2         default null,
  p_pgm_attribute5               in varchar2         default null,
  p_pgm_attribute6               in varchar2         default null,
  p_pgm_attribute7               in varchar2         default null,
  p_pgm_attribute8               in varchar2         default null,
  p_pgm_attribute9               in varchar2         default null,
  p_pgm_attribute10              in varchar2         default null,
  p_pgm_attribute11              in varchar2         default null,
  p_pgm_attribute12              in varchar2         default null,
  p_pgm_attribute13              in varchar2         default null,
  p_pgm_attribute14              in varchar2         default null,
  p_pgm_attribute15              in varchar2         default null,
  p_pgm_attribute16              in varchar2         default null,
  p_pgm_attribute17              in varchar2         default null,
  p_pgm_attribute18              in varchar2         default null,
  p_pgm_attribute19              in varchar2         default null,
  p_pgm_attribute20              in varchar2         default null,
  p_pgm_attribute21              in varchar2         default null,
  p_pgm_attribute22              in varchar2         default null,
  p_pgm_attribute23              in varchar2         default null,
  p_pgm_attribute24              in varchar2         default null,
  p_pgm_attribute25              in varchar2         default null,
  p_pgm_attribute26              in varchar2         default null,
  p_pgm_attribute27              in varchar2         default null,
  p_pgm_attribute28              in varchar2         default null,
  p_pgm_attribute29              in varchar2         default null,
  p_pgm_attribute30              in varchar2         default null,
  p_object_version_number        out nocopy number,
  p_effective_date               in date
  ) is
--
  l_rec		ben_pgm_shd.g_rec_type;
  l_proc	varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  ben_pgm_shd.convert_args
  (
    null
   ,null
   ,null
   ,p_name
   ,p_dpnt_adrs_rqd_flag
   ,p_pgm_prvds_no_auto_enrt_flag
   ,p_dpnt_dob_rqd_flag
   ,p_pgm_prvds_no_dflt_enrt_flag
   ,p_dpnt_legv_id_rqd_flag
   ,p_dpnt_dsgn_lvl_cd
   ,p_pgm_stat_cd
   ,p_ivr_ident
   ,p_pgm_typ_cd
   ,p_elig_apls_flag
   ,p_uses_all_asmts_for_rts_flag
   ,p_url_ref_name
   ,p_pgm_desc
   ,p_prtn_elig_ovrid_alwd_flag
   ,p_pgm_use_all_asnts_elig_flag
   ,p_dpnt_dsgn_cd
   ,p_mx_dpnt_pct_prtt_lf_amt
   ,p_mx_sps_pct_prtt_lf_amt
   ,p_acty_ref_perd_cd
   ,p_coord_cvg_for_all_pls_flg
   ,p_enrt_cvg_end_dt_cd
   ,p_enrt_cvg_end_dt_rl
   ,p_dpnt_cvg_end_dt_cd
   ,p_dpnt_cvg_end_dt_rl
   ,p_dpnt_cvg_strt_dt_cd
   ,p_dpnt_cvg_strt_dt_rl
   ,p_dpnt_dsgn_no_ctfn_rqd_flag
   ,p_drvbl_fctr_dpnt_elig_flag
   ,p_drvbl_fctr_prtn_elig_flag
   ,p_enrt_cvg_strt_dt_cd
   ,p_enrt_cvg_strt_dt_rl
   ,p_enrt_info_rt_freq_cd
   ,p_rt_strt_dt_cd
   ,p_rt_strt_dt_rl
   ,p_rt_end_dt_cd
   ,p_rt_end_dt_rl
   ,p_pgm_grp_cd
   ,p_pgm_uom
   ,p_drvbl_fctr_apls_rts_flag
   ,p_alws_unrstrctd_enrt_flag
   ,p_enrt_cd
   ,p_enrt_mthd_cd
   ,p_poe_lvl_cd
   ,p_enrt_rl
   ,p_auto_enrt_mthd_rl
   ,p_trk_inelig_per_flag
   ,p_business_group_id
   ,p_per_cvrd_cd
   ,P_vrfy_fmly_mmbr_rl
   ,P_vrfy_fmly_mmbr_cd
   ,p_short_name		/*FHR*/
   ,p_short_code		/*FHR*/
      ,p_legislation_code		/*FHR*/
      ,p_legislation_subgroup		/*FHR*/
   ,p_Dflt_pgm_flag
   ,p_Use_prog_points_flag
   ,p_Dflt_step_cd
   ,p_Dflt_step_rl
   ,p_Update_salary_cd
   ,p_Use_multi_pay_rates_flag
   ,p_dflt_element_type_id
   ,p_Dflt_input_value_id
   ,p_Use_scores_cd
   ,p_Scores_calc_mthd_cd
   ,p_Scores_calc_rl
   ,p_gsp_allow_override_flag
   ,p_use_variable_rates_flag
   ,p_salary_calc_mthd_cd
   ,p_salary_calc_mthd_rl
   ,p_susp_if_dpnt_ssn_nt_prv_cd
   ,p_susp_if_dpnt_dob_nt_prv_cd
   ,p_susp_if_dpnt_adr_nt_prv_cd
   ,p_susp_if_ctfn_not_dpnt_flag
   ,p_dpnt_ctfn_determine_cd
   ,p_pgm_attribute_category
   ,p_pgm_attribute1
   ,p_pgm_attribute2
   ,p_pgm_attribute3
   ,p_pgm_attribute4
   ,p_pgm_attribute5
   ,p_pgm_attribute6
   ,p_pgm_attribute7
   ,p_pgm_attribute8
   ,p_pgm_attribute9
   ,p_pgm_attribute10
   ,p_pgm_attribute11
   ,p_pgm_attribute12
   ,p_pgm_attribute13
   ,p_pgm_attribute14
   ,p_pgm_attribute15
   ,p_pgm_attribute16
   ,p_pgm_attribute17
   ,p_pgm_attribute18
   ,p_pgm_attribute19
   ,p_pgm_attribute20
   ,p_pgm_attribute21
   ,p_pgm_attribute22
   ,p_pgm_attribute23
   ,p_pgm_attribute24
   ,p_pgm_attribute25
   ,p_pgm_attribute26
   ,p_pgm_attribute27
   ,p_pgm_attribute28
   ,p_pgm_attribute29
   ,p_pgm_attribute30
   ,null
  );
  --
  -- Having converted the arguments into the ben_pgm_rec
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  ins(l_rec, p_effective_date);
  --
  -- Set the OUT arguments.
  --
  p_pgm_id        	:= l_rec.pgm_id;
  p_effective_start_date  	:= l_rec.effective_start_date;
  p_effective_end_date    	:= l_rec.effective_end_date;
  p_object_version_number 	:= l_rec.object_version_number;
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End ins;
--
end ben_pgm_ins;

/
