--------------------------------------------------------
--  DDL for Package Body BEN_COP_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_COP_INS" as
/* $Header: becoprhi.pkb 120.5 2007/12/04 10:59:29 bachakra noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_cop_ins.';  -- Global package name
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
	(p_rec 			 in out nocopy ben_cop_shd.g_rec_type,
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
    from   ben_oipl_f t
    where  t.oipl_id       = p_rec.oipl_id
    and    t.effective_start_date =
             ben_cop_shd.g_old_rec.effective_start_date
    and    t.effective_end_date   = (p_validation_start_date - 1);
--
  l_proc		varchar2(72) := g_package||'dt_insert_dml';
  l_created_by          ben_oipl_f.created_by%TYPE;
  l_creation_date       ben_oipl_f.creation_date%TYPE;
  l_last_update_date   	ben_oipl_f.last_update_date%TYPE;
  l_last_updated_by     ben_oipl_f.last_updated_by%TYPE;
  l_last_update_login   ben_oipl_f.last_update_login%TYPE;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Get the object version number for the insert
  --
  p_rec.object_version_number :=
    dt_api.get_object_version_number
	(p_base_table_name => 'ben_oipl_f',
	 p_base_key_column => 'oipl_id',
	 p_base_key_value  => p_rec.oipl_id);
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
  ben_cop_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Insert the row into: ben_oipl_f
  --
  insert into ben_oipl_f
  (	oipl_id,
	effective_start_date,
	effective_end_date,
	ivr_ident,
        url_ref_name,
	opt_id,
	business_group_id,
	pl_id,
	ordr_num,
	rqd_perd_enrt_nenrt_val,
	actl_prem_id,
	dflt_flag,
	mndtry_flag,
	oipl_stat_cd,
      pcp_dsgn_cd,
      pcp_dpnt_dsgn_cd,
	rqd_perd_enrt_nenrt_uom,
	elig_apls_flag,
	dflt_enrt_det_rl,
	trk_inelig_per_flag,
	drvbl_fctr_prtn_elig_flag,
	mndtry_rl,
	rqd_perd_enrt_nenrt_rl,
	dflt_enrt_cd,
	prtn_elig_ovrid_alwd_flag,
	drvbl_fctr_apls_rts_flag,
        per_cvrd_cd,
        postelcn_edit_rl,
        vrfy_fmly_mmbr_cd,
        vrfy_fmly_mmbr_rl,
        enrt_cd,
        enrt_rl,
        auto_enrt_flag,
        auto_enrt_mthd_rl,
        short_name,		/*FHR*/
        short_code,		/*FHR*/
                legislation_code,		/*FHR*/
                legislation_subgroup,		/*FHR*/
        hidden_flag,
        susp_if_ctfn_not_prvd_flag,
        ctfn_determine_cd,
	cop_attribute_category,
	cop_attribute1,
	cop_attribute2,
	cop_attribute3,
	cop_attribute4,
	cop_attribute5,
	cop_attribute6,
	cop_attribute7,
	cop_attribute8,
	cop_attribute9,
	cop_attribute10,
	cop_attribute11,
	cop_attribute12,
	cop_attribute13,
	cop_attribute14,
	cop_attribute15,
	cop_attribute16,
	cop_attribute17,
	cop_attribute18,
	cop_attribute19,
	cop_attribute20,
	cop_attribute21,
	cop_attribute22,
	cop_attribute23,
	cop_attribute24,
	cop_attribute25,
	cop_attribute26,
	cop_attribute27,
	cop_attribute28,
	cop_attribute29,
	cop_attribute30,
	object_version_number
   	, created_by,
   	creation_date,
   	last_update_date,
   	last_updated_by,
   	last_update_login
  )
  Values
  (	p_rec.oipl_id,
	p_rec.effective_start_date,
	p_rec.effective_end_date,
	p_rec.ivr_ident,
        p_rec.url_ref_name,
	p_rec.opt_id,
	p_rec.business_group_id,
	p_rec.pl_id,
	p_rec.ordr_num,
	p_rec.rqd_perd_enrt_nenrt_val,
	p_rec.actl_prem_id,
	p_rec.dflt_flag,
	p_rec.mndtry_flag,
	p_rec.oipl_stat_cd,
      p_rec.pcp_dsgn_cd,
      p_rec.pcp_dpnt_dsgn_cd,
	p_rec.rqd_perd_enrt_nenrt_uom,
	p_rec.elig_apls_flag,
	p_rec.dflt_enrt_det_rl,
	p_rec.trk_inelig_per_flag,
	p_rec.drvbl_fctr_prtn_elig_flag,
	p_rec.mndtry_rl,
	p_rec.rqd_perd_enrt_nenrt_rl,
	p_rec.dflt_enrt_cd,
	p_rec.prtn_elig_ovrid_alwd_flag,
	p_rec.drvbl_fctr_apls_rts_flag,
        p_rec.per_cvrd_cd,
        p_rec.postelcn_edit_rl,
        p_rec.vrfy_fmly_mmbr_cd,
        p_rec.vrfy_fmly_mmbr_rl,
        p_rec.enrt_cd,
        p_rec.enrt_rl,
        p_rec.auto_enrt_flag,
        p_rec.auto_enrt_mthd_rl,
        p_rec.short_name,		/*FHR*/
        p_rec.short_code,		/*FHR*/
                p_rec.legislation_code,		/*FHR*/
                p_rec.legislation_subgroup,		/*FHR*/
        nvl(p_rec.hidden_flag,'N'),
        p_rec.susp_if_ctfn_not_prvd_flag,
        p_rec.ctfn_determine_cd,
	p_rec.cop_attribute_category,
	p_rec.cop_attribute1,
	p_rec.cop_attribute2,
	p_rec.cop_attribute3,
	p_rec.cop_attribute4,
	p_rec.cop_attribute5,
	p_rec.cop_attribute6,
	p_rec.cop_attribute7,
	p_rec.cop_attribute8,
	p_rec.cop_attribute9,
	p_rec.cop_attribute10,
	p_rec.cop_attribute11,
	p_rec.cop_attribute12,
	p_rec.cop_attribute13,
	p_rec.cop_attribute14,
	p_rec.cop_attribute15,
	p_rec.cop_attribute16,
	p_rec.cop_attribute17,
	p_rec.cop_attribute18,
	p_rec.cop_attribute19,
	p_rec.cop_attribute20,
	p_rec.cop_attribute21,
	p_rec.cop_attribute22,
	p_rec.cop_attribute23,
	p_rec.cop_attribute24,
	p_rec.cop_attribute25,
	p_rec.cop_attribute26,
	p_rec.cop_attribute27,
	p_rec.cop_attribute28,
	p_rec.cop_attribute29,
	p_rec.cop_attribute30,
	p_rec.object_version_number,
	l_created_by,
   	l_creation_date,
   	l_last_update_date,
   	l_last_updated_by,
   	l_last_update_login
  );
  --
  ben_cop_shd.g_api_dml := false;   -- Unset the api dml status
  hr_utility.set_location(' Leaving:'||l_proc, 15);
--
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    ben_cop_shd.g_api_dml := false;   -- Unset the api dml status
    ben_cop_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    ben_cop_shd.g_api_dml := false;   -- Unset the api dml status
    ben_cop_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    ben_cop_shd.g_api_dml := false;   -- Unset the api dml status
    Raise;
End dt_insert_dml;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< insert_dml >------------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_dml
	(p_rec 			 in out nocopy ben_cop_shd.g_rec_type,
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
	(p_rec  			in out nocopy ben_cop_shd.g_rec_type,
	 p_effective_date		in date,
	 p_datetrack_mode		in varchar2,
	 p_validation_start_date	in date,
	 p_validation_end_date		in date) is
--
  l_proc	varchar2(72) := g_package||'pre_insert';
--
  Cursor c1 is select ben_oipl_f_s.nextval from sys.dual;
--
cursor c_icm_opt_track_flag is
  select ptp.opt_typ_cd
  from   ben_pl_typ_f ptp,ben_pl_f pln
  where  pln.pl_id = p_rec.pl_id
  and    pln.pl_typ_id = ptp.pl_typ_id
  and    pln.business_group_id = p_rec.business_group_id
  and    p_effective_date between pln.effective_start_date and pln.effective_end_date
  and    p_effective_date between ptp.effective_start_date and ptp.effective_end_date;
--
 l_icm_opt_track_flag ben_pl_typ_f.opt_typ_cd%TYPE;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  open c1;
  fetch c1 into p_rec.oipl_id;
  close c1;
  --
  open c_icm_opt_track_flag;
   fetch c_icm_opt_track_flag into l_icm_opt_track_flag;
  --
  if l_icm_opt_track_flag = 'ICM' then
  p_rec.trk_inelig_per_flag := 'Y';
  end if;
   close c_icm_opt_track_flag;
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
	(p_rec 			 in ben_cop_shd.g_rec_type,
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
  pqh_gsp_ben_validations.oipl_validations
  	(  p_oipl_id			=> p_rec.oipl_id
  	 , p_dml_operation 		=> 'I'
  	 , p_effective_date 		=> p_effective_date
  	 , p_business_group_id  	=> p_rec.business_group_id
  	 , p_oipl_stat_cd		=> p_rec.oipl_stat_cd
  	 );

  -- Start of API User Hook for post_insert.

  --
  begin
    --
    ben_cop_rki.after_insert
    (p_oipl_id                        => p_rec.oipl_id
    ,p_effective_start_date           => p_rec.effective_start_date
    ,p_effective_end_date             => p_rec.effective_end_date
    ,p_ivr_ident                      => p_rec.ivr_ident
    ,p_url_ref_name                   => p_rec.url_ref_name
    ,p_opt_id                         => p_rec.opt_id
    ,p_business_group_id              => p_rec.business_group_id
    ,p_pl_id                          => p_rec.pl_id
    ,p_ordr_num                       => p_rec.ordr_num
    ,p_rqd_perd_enrt_nenrt_val        => p_rec.rqd_perd_enrt_nenrt_val
    ,p_actl_prem_id                   => p_rec.actl_prem_id
    ,p_dflt_flag                      => p_rec.dflt_flag
    ,p_mndtry_flag                    => p_rec.mndtry_flag
    ,p_oipl_stat_cd                   => p_rec.oipl_stat_cd
    ,p_pcp_dsgn_cd                    => p_rec.pcp_dsgn_cd
    ,p_pcp_dpnt_dsgn_cd               => p_rec.pcp_dpnt_dsgn_cd
    ,p_rqd_perd_enrt_nenrt_uom        => p_rec.rqd_perd_enrt_nenrt_uom
    ,p_elig_apls_flag                 => p_rec.elig_apls_flag
    ,p_dflt_enrt_det_rl               => p_rec.dflt_enrt_det_rl
    ,p_trk_inelig_per_flag            => p_rec.trk_inelig_per_flag
    ,p_drvbl_fctr_prtn_elig_flag      => p_rec.drvbl_fctr_prtn_elig_flag
    ,p_mndtry_rl                      => p_rec.mndtry_rl
    ,p_rqd_perd_enrt_nenrt_rl                      => p_rec.rqd_perd_enrt_nenrt_rl
    ,p_dflt_enrt_cd                   => p_rec.dflt_enrt_cd
    ,p_prtn_elig_ovrid_alwd_flag      => p_rec.prtn_elig_ovrid_alwd_flag
    ,p_drvbl_fctr_apls_rts_flag       => p_rec.drvbl_fctr_apls_rts_flag
    ,p_per_cvrd_cd                    => p_rec.per_cvrd_cd
    ,p_postelcn_edit_rl               => p_rec.postelcn_edit_rl
    ,p_vrfy_fmly_mmbr_cd              => p_rec.vrfy_fmly_mmbr_cd
    ,p_vrfy_fmly_mmbr_rl              => p_rec.vrfy_fmly_mmbr_rl
    ,p_enrt_cd                        => p_rec.enrt_cd
    ,p_enrt_rl                        => p_rec.enrt_rl
    ,p_auto_enrt_flag                 => p_rec.auto_enrt_flag
    ,p_auto_enrt_mthd_rl              => p_rec.auto_enrt_mthd_rl
    ,p_short_name		      => p_rec.short_name		/*FHR*/
    ,p_short_code		      => p_rec.short_code		/*FHR*/
        ,p_legislation_code		      => p_rec.legislation_code		/*FHR*/
        ,p_legislation_subgroup		      => p_rec.legislation_subgroup		/*FHR*/
    ,p_hidden_flag		      => p_rec.hidden_flag
    ,p_susp_if_ctfn_not_prvd_flag     =>  p_rec.susp_if_ctfn_not_prvd_flag
    ,p_ctfn_determine_cd         =>  p_rec.ctfn_determine_cd
    ,p_cop_attribute_category         => p_rec.cop_attribute_category
    ,p_cop_attribute1                 => p_rec.cop_attribute1
    ,p_cop_attribute2                 => p_rec.cop_attribute2
    ,p_cop_attribute3                 => p_rec.cop_attribute3
    ,p_cop_attribute4                 => p_rec.cop_attribute4
    ,p_cop_attribute5                 => p_rec.cop_attribute5
    ,p_cop_attribute6                 => p_rec.cop_attribute6
    ,p_cop_attribute7                 => p_rec.cop_attribute7
    ,p_cop_attribute8                 => p_rec.cop_attribute8
    ,p_cop_attribute9                 => p_rec.cop_attribute9
    ,p_cop_attribute10                => p_rec.cop_attribute10
    ,p_cop_attribute11                => p_rec.cop_attribute11
    ,p_cop_attribute12                => p_rec.cop_attribute12
    ,p_cop_attribute13                => p_rec.cop_attribute13
    ,p_cop_attribute14                => p_rec.cop_attribute14
    ,p_cop_attribute15                => p_rec.cop_attribute15
    ,p_cop_attribute16                => p_rec.cop_attribute16
    ,p_cop_attribute17                => p_rec.cop_attribute17
    ,p_cop_attribute18                => p_rec.cop_attribute18
    ,p_cop_attribute19                => p_rec.cop_attribute19
    ,p_cop_attribute20                => p_rec.cop_attribute20
    ,p_cop_attribute21                => p_rec.cop_attribute21
    ,p_cop_attribute22                => p_rec.cop_attribute22
    ,p_cop_attribute23                => p_rec.cop_attribute23
    ,p_cop_attribute24                => p_rec.cop_attribute24
    ,p_cop_attribute25                => p_rec.cop_attribute25
    ,p_cop_attribute26                => p_rec.cop_attribute26
    ,p_cop_attribute27                => p_rec.cop_attribute27
    ,p_cop_attribute28                => p_rec.cop_attribute28
    ,p_cop_attribute29                => p_rec.cop_attribute29
    ,p_cop_attribute30                => p_rec.cop_attribute30
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
        (p_module_name => 'ben_oipl_f'
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
	 p_rec	 		 in  ben_cop_shd.g_rec_type,
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
	 p_base_table_name	   => 'ben_oipl_f',
	 p_base_key_column	   => 'oipl_id',
	 p_base_key_value 	   => p_rec.oipl_id,
	 p_parent_table_name1      => 'ff_formulas_f',
	 p_parent_key_column1      => 'formula_id',
	 p_parent_key_value1       => p_rec.dflt_enrt_det_rl,
	 p_parent_table_name2      => 'ff_formulas_f',
	 p_parent_key_column2      => 'formula_id',
	 p_parent_key_value2       => p_rec.mndtry_rl,
	 p_parent_table_name3      => 'ff_formulas_f',
	 p_parent_key_column3      => 'formula_id',
	 p_parent_key_value3       => p_rec.postelcn_edit_rl,
	 p_parent_table_name4      => 'ff_formulas_f',
	 p_parent_key_column4      => 'formula_id',
	 p_parent_key_value4       => p_rec.vrfy_fmly_mmbr_rl,
	 p_parent_table_name5      => 'ben_actl_prem_f',
	 p_parent_key_column5      => 'actl_prem_id',
	 p_parent_key_value5       => p_rec.actl_prem_id,
	 p_parent_table_name6      => 'ben_pl_f',
	 p_parent_key_column6      => 'pl_id',
	 p_parent_key_value6       => p_rec.pl_id,
	 p_parent_table_name7      => 'ben_opt_f',
	 p_parent_key_column7      => 'opt_id',
	 p_parent_key_value7       => p_rec.opt_id,
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
  p_rec		   in out nocopy ben_cop_shd.g_rec_type,
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
  ben_cop_bus.insert_validate
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
  p_oipl_id                      out nocopy number,
  p_effective_start_date         out nocopy date,
  p_effective_end_date           out nocopy date,
  p_ivr_ident                    in varchar2         default null,
  p_url_ref_name                 in varchar2         default null,
  p_opt_id                       in number,
  p_business_group_id            in number,
  p_pl_id                        in number,
  p_ordr_num                     in number           default null,
  p_rqd_perd_enrt_nenrt_val      in number           default null,
  p_dflt_flag                    in varchar2,
  p_actl_prem_id                 in number           default null,
  p_mndtry_flag                  in varchar2,
  p_oipl_stat_cd                 in varchar2,
  p_pcp_dsgn_cd                  in varchar2        default null,
  p_pcp_dpnt_dsgn_cd             in varchar2        default null,
  p_rqd_perd_enrt_nenrt_uom      in varchar2,
  p_elig_apls_flag               in varchar2,
  p_dflt_enrt_det_rl             in number           default null,
  p_trk_inelig_per_flag          in varchar2,
  p_drvbl_fctr_prtn_elig_flag    in varchar2,
  p_mndtry_rl                    in number           default null,
  p_rqd_perd_enrt_nenrt_rl                    in number           default null,
  p_dflt_enrt_cd                 in varchar2         default null,
  p_prtn_elig_ovrid_alwd_flag    in varchar2,
  p_drvbl_fctr_apls_rts_flag     in varchar2,
  p_per_cvrd_cd                  in varchar2         default null,
  p_postelcn_edit_rl             in number           default null,
  p_vrfy_fmly_mmbr_cd            in varchar2         default null,
  p_vrfy_fmly_mmbr_rl            in number           default null,
  p_enrt_cd                      in varchar2         default null,
  p_enrt_rl                      in number           default null,
  p_auto_enrt_flag               in varchar2         default null,
  p_auto_enrt_mthd_rl            in number           default null,
  p_short_name			 in varchar2	     default null,	--FHR
  p_short_code			 in varchar2	     default null,	--FHR
    p_legislation_code			 in varchar2	     default null,
    p_legislation_subgroup			 in varchar2	     default null,
  p_hidden_flag			 in varchar2,
  p_susp_if_ctfn_not_prvd_flag   in  varchar2  default 'Y',
  p_ctfn_determine_cd            in  varchar2  default null,
  p_cop_attribute_category       in varchar2         default null,
  p_cop_attribute1               in varchar2         default null,
  p_cop_attribute2               in varchar2         default null,
  p_cop_attribute3               in varchar2         default null,
  p_cop_attribute4               in varchar2         default null,
  p_cop_attribute5               in varchar2         default null,
  p_cop_attribute6               in varchar2         default null,
  p_cop_attribute7               in varchar2         default null,
  p_cop_attribute8               in varchar2         default null,
  p_cop_attribute9               in varchar2         default null,
  p_cop_attribute10              in varchar2         default null,
  p_cop_attribute11              in varchar2         default null,
  p_cop_attribute12              in varchar2         default null,
  p_cop_attribute13              in varchar2         default null,
  p_cop_attribute14              in varchar2         default null,
  p_cop_attribute15              in varchar2         default null,
  p_cop_attribute16              in varchar2         default null,
  p_cop_attribute17              in varchar2         default null,
  p_cop_attribute18              in varchar2         default null,
  p_cop_attribute19              in varchar2         default null,
  p_cop_attribute20              in varchar2         default null,
  p_cop_attribute21              in varchar2         default null,
  p_cop_attribute22              in varchar2         default null,
  p_cop_attribute23              in varchar2         default null,
  p_cop_attribute24              in varchar2         default null,
  p_cop_attribute25              in varchar2         default null,
  p_cop_attribute26              in varchar2         default null,
  p_cop_attribute27              in varchar2         default null,
  p_cop_attribute28              in varchar2         default null,
  p_cop_attribute29              in varchar2         default null,
  p_cop_attribute30              in varchar2         default null,
  p_object_version_number        out nocopy number,
  p_effective_date               in date
  ) is
--
  l_rec		ben_cop_shd.g_rec_type;
  l_proc	varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  ben_cop_shd.convert_args
  (
  null,
  null,
  null,
  p_ivr_ident,
  p_url_ref_name,
  p_opt_id,
  p_business_group_id,
  p_pl_id,
  p_ordr_num,
  p_rqd_perd_enrt_nenrt_val,
  p_dflt_flag,
  p_actl_prem_id,
  p_mndtry_flag,
  p_oipl_stat_cd,
  p_pcp_dsgn_cd,
  p_pcp_dpnt_dsgn_cd,
  p_rqd_perd_enrt_nenrt_uom,
  p_elig_apls_flag,
  p_dflt_enrt_det_rl,
  p_trk_inelig_per_flag,
  p_drvbl_fctr_prtn_elig_flag,
  p_mndtry_rl,
  p_rqd_perd_enrt_nenrt_rl,
  p_dflt_enrt_cd,
  p_prtn_elig_ovrid_alwd_flag,
  p_drvbl_fctr_apls_rts_flag,
  p_per_cvrd_cd,
  p_postelcn_edit_rl,
  p_vrfy_fmly_mmbr_cd,
  p_vrfy_fmly_mmbr_rl,
  p_enrt_cd,
  p_enrt_rl,
  p_auto_enrt_flag,
  p_auto_enrt_mthd_rl,
  p_short_name,		--FHR
  p_short_code,		--FHR
    p_legislation_code,
    p_legislation_subgroup,
  p_hidden_flag,
  p_susp_if_ctfn_not_prvd_flag,
  p_ctfn_determine_cd,
  p_cop_attribute_category,
  p_cop_attribute1,
  p_cop_attribute2,
  p_cop_attribute3,
  p_cop_attribute4,
  p_cop_attribute5,
  p_cop_attribute6,
  p_cop_attribute7,
  p_cop_attribute8,
  p_cop_attribute9,
  p_cop_attribute10,
  p_cop_attribute11,
  p_cop_attribute12,
  p_cop_attribute13,
  p_cop_attribute14,
  p_cop_attribute15,
  p_cop_attribute16,
  p_cop_attribute17,
  p_cop_attribute18,
  p_cop_attribute19,
  p_cop_attribute20,
  p_cop_attribute21,
  p_cop_attribute22,
  p_cop_attribute23,
  p_cop_attribute24,
  p_cop_attribute25,
  p_cop_attribute26,
  p_cop_attribute27,
  p_cop_attribute28,
  p_cop_attribute29,
  p_cop_attribute30,
  null
  );
  --
  -- Having converted the arguments into the ben_cop_rec
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  ins(l_rec, p_effective_date);
  --
  -- Set the OUT arguments.
  --
  p_oipl_id        	:= l_rec.oipl_id;
  p_effective_start_date  	:= l_rec.effective_start_date;
  p_effective_end_date    	:= l_rec.effective_end_date;
  p_object_version_number 	:= l_rec.object_version_number;
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End ins;
--
end ben_cop_ins;

/
