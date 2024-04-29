--------------------------------------------------------
--  DDL for Package Body BEN_CTP_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_CTP_INS" as
/* $Header: bectprhi.pkb 120.0 2005/05/28 01:26:14 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_ctp_ins.';  -- Global package name
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
	(p_rec 			 in out nocopy ben_ctp_shd.g_rec_type,
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
    from   ben_ptip_f t
    where  t.ptip_id       = p_rec.ptip_id
    and    t.effective_start_date =
             ben_ctp_shd.g_old_rec.effective_start_date
    and    t.effective_end_date   = (p_validation_start_date - 1);
--
  l_proc		varchar2(72) := g_package||'dt_insert_dml';
  l_created_by          ben_ptip_f.created_by%TYPE;
  l_creation_date       ben_ptip_f.creation_date%TYPE;
  l_last_update_date   	ben_ptip_f.last_update_date%TYPE;
  l_last_updated_by     ben_ptip_f.last_updated_by%TYPE;
  l_last_update_login   ben_ptip_f.last_update_login%TYPE;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Get the object version number for the insert
  --
  p_rec.object_version_number :=
    dt_api.get_object_version_number
	(p_base_table_name => 'ben_ptip_f',
	 p_base_key_column => 'ptip_id',
	 p_base_key_value  => p_rec.ptip_id);
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
  ben_ctp_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Insert the row into: ben_ptip_f
  --
  insert into ben_ptip_f
  (	ptip_id,
	effective_start_date,
	effective_end_date,
	business_group_id,
	pgm_id,
        cmbn_ptip_id,
        cmbn_ptip_opt_id,
        acrs_ptip_cvg_id,
	pl_typ_id,
	coord_cvg_for_all_pls_flag,
	dpnt_dsgn_cd,
        dpnt_cvg_strt_dt_rl,
        dpnt_cvg_end_dt_rl,
        postelcn_edit_rl,
        rt_end_dt_rl,
        rt_strt_dt_rl,
        enrt_cvg_end_dt_rl,
        enrt_cvg_strt_dt_rl,
        rqd_perd_enrt_nenrt_rl,
        auto_enrt_mthd_rl,
        enrt_mthd_cd,
        enrt_cd,
        enrt_rl,
        dflt_enrt_cd,
        dflt_enrt_det_rl,
        drvbl_fctr_apls_rts_flag,
        drvbl_fctr_prtn_elig_flag,
        elig_apls_flag,
        prtn_elig_ovrid_alwd_flag,
        trk_inelig_per_flag,
        dpnt_cvg_strt_dt_cd,
        rt_end_dt_cd,
        rt_strt_dt_cd,
        enrt_cvg_end_dt_cd,
        enrt_cvg_strt_dt_cd,
        dpnt_cvg_end_dt_cd,
	crs_this_pl_typ_only_flag,
	ptip_stat_cd,
	mx_cvg_alwd_amt,
	mx_enrd_alwd_ovrid_num,
	mn_enrd_rqd_ovrid_num,
	no_mx_pl_typ_ovrid_flag,
	ordr_num,
	prvds_cr_flag,
	rqd_perd_enrt_nenrt_val,
	rqd_perd_enrt_nenrt_tm_uom,
	wvbl_flag,
        dpnt_adrs_rqd_flag,
        dpnt_cvg_no_ctfn_rqd_flag,
        dpnt_dob_rqd_flag,
        dpnt_legv_id_rqd_flag,
        susp_if_dpnt_ssn_nt_prv_cd,
        susp_if_dpnt_dob_nt_prv_cd,
        susp_if_dpnt_adr_nt_prv_cd,
        susp_if_ctfn_not_dpnt_flag,
        dpnt_ctfn_determine_cd,
	drvd_fctr_dpnt_cvg_flag,
	no_mn_pl_typ_overid_flag,
      sbj_to_sps_lf_ins_mx_flag,
      sbj_to_dpnt_lf_ins_mx_flag,
      use_to_sum_ee_lf_ins_flag,
      per_cvrd_cd,
      short_name,
      short_code ,
            legislation_code ,
            legislation_subgroup ,
      vrfy_fmly_mmbr_cd,
      vrfy_fmly_mmbr_rl,
	ivr_ident,
        url_ref_name,
	rqd_enrt_perd_tco_cd,
	ctp_attribute_category,
	ctp_attribute1,
	ctp_attribute2,
	ctp_attribute3,
	ctp_attribute4,
	ctp_attribute5,
	ctp_attribute6,
	ctp_attribute7,
	ctp_attribute8,
	ctp_attribute9,
	ctp_attribute10,
	ctp_attribute11,
	ctp_attribute12,
	ctp_attribute13,
	ctp_attribute14,
	ctp_attribute15,
	ctp_attribute16,
	ctp_attribute17,
	ctp_attribute18,
	ctp_attribute19,
	ctp_attribute20,
	ctp_attribute21,
	ctp_attribute22,
	ctp_attribute23,
	ctp_attribute24,
	ctp_attribute25,
	ctp_attribute26,
	ctp_attribute27,
	ctp_attribute28,
	ctp_attribute29,
	ctp_attribute30,
	object_version_number
   	, created_by,
   	creation_date,
   	last_update_date,
   	last_updated_by,
   	last_update_login
  )
  Values
  (	p_rec.ptip_id,
	p_rec.effective_start_date,
	p_rec.effective_end_date,
	p_rec.business_group_id,
	p_rec.pgm_id,
        p_rec.cmbn_ptip_id,
        p_rec.cmbn_ptip_opt_id,
        p_rec.acrs_ptip_cvg_id,
	p_rec.pl_typ_id,
	p_rec.coord_cvg_for_all_pls_flag,
	p_rec.dpnt_dsgn_cd,
        p_rec.dpnt_cvg_strt_dt_rl,
        p_rec.dpnt_cvg_end_dt_rl,
        p_rec.postelcn_edit_rl,
        p_rec.rt_end_dt_rl,
        p_rec.rt_strt_dt_rl,
        p_rec.enrt_cvg_end_dt_rl,
        p_rec.enrt_cvg_strt_dt_rl,
        p_rec.rqd_perd_enrt_nenrt_rl,
        p_rec.auto_enrt_mthd_rl,
        p_rec.enrt_mthd_cd,
        p_rec.enrt_cd,
        p_rec.enrt_rl,
        p_rec.dflt_enrt_cd,
        p_rec.dflt_enrt_det_rl,
        p_rec.drvbl_fctr_apls_rts_flag,
        p_rec.drvbl_fctr_prtn_elig_flag,
        p_rec.elig_apls_flag,
        p_rec.prtn_elig_ovrid_alwd_flag,
        p_rec.trk_inelig_per_flag,
        p_rec.dpnt_cvg_strt_dt_cd,
        p_rec.rt_end_dt_cd,
        p_rec.rt_strt_dt_cd,
        p_rec.enrt_cvg_end_dt_cd,
        p_rec.enrt_cvg_strt_dt_cd,
        p_rec.dpnt_cvg_end_dt_cd,
	p_rec.crs_this_pl_typ_only_flag,
	p_rec.ptip_stat_cd,
	p_rec.mx_cvg_alwd_amt,
	p_rec.mx_enrd_alwd_ovrid_num,
	p_rec.mn_enrd_rqd_ovrid_num,
	p_rec.no_mx_pl_typ_ovrid_flag,
	p_rec.ordr_num,
	p_rec.prvds_cr_flag,
	p_rec.rqd_perd_enrt_nenrt_val,
	p_rec.rqd_perd_enrt_nenrt_tm_uom,
	p_rec.wvbl_flag,
        p_rec.dpnt_adrs_rqd_flag,
        p_rec.dpnt_cvg_no_ctfn_rqd_flag,
        p_rec.dpnt_dob_rqd_flag,
        p_rec.dpnt_legv_id_rqd_flag,
        p_rec.susp_if_dpnt_ssn_nt_prv_cd,
        p_rec.susp_if_dpnt_dob_nt_prv_cd,
        p_rec.susp_if_dpnt_adr_nt_prv_cd,
        p_rec.susp_if_ctfn_not_dpnt_flag,
        p_rec.dpnt_ctfn_determine_cd,
	p_rec.drvd_fctr_dpnt_cvg_flag,
	p_rec.no_mn_pl_typ_overid_flag,
      p_rec.sbj_to_sps_lf_ins_mx_flag,
      p_rec.sbj_to_dpnt_lf_ins_mx_flag,
      p_rec.use_to_sum_ee_lf_ins_flag,
      p_rec.per_cvrd_cd,
      p_rec.short_name,
      p_rec.short_code,
            p_rec.legislation_code,
            p_rec.legislation_subgroup,
      p_rec.vrfy_fmly_mmbr_cd,
      p_rec.vrfy_fmly_mmbr_rl,
	p_rec.ivr_ident,
        p_rec.url_ref_name,
	p_rec.rqd_enrt_perd_tco_cd,
	p_rec.ctp_attribute_category,
	p_rec.ctp_attribute1,
	p_rec.ctp_attribute2,
	p_rec.ctp_attribute3,
	p_rec.ctp_attribute4,
	p_rec.ctp_attribute5,
	p_rec.ctp_attribute6,
	p_rec.ctp_attribute7,
	p_rec.ctp_attribute8,
	p_rec.ctp_attribute9,
	p_rec.ctp_attribute10,
	p_rec.ctp_attribute11,
	p_rec.ctp_attribute12,
	p_rec.ctp_attribute13,
	p_rec.ctp_attribute14,
	p_rec.ctp_attribute15,
	p_rec.ctp_attribute16,
	p_rec.ctp_attribute17,
	p_rec.ctp_attribute18,
	p_rec.ctp_attribute19,
	p_rec.ctp_attribute20,
	p_rec.ctp_attribute21,
	p_rec.ctp_attribute22,
	p_rec.ctp_attribute23,
	p_rec.ctp_attribute24,
	p_rec.ctp_attribute25,
	p_rec.ctp_attribute26,
	p_rec.ctp_attribute27,
	p_rec.ctp_attribute28,
	p_rec.ctp_attribute29,
	p_rec.ctp_attribute30,
	p_rec.object_version_number
	, l_created_by,
   	l_creation_date,
   	l_last_update_date,
   	l_last_updated_by,
   	l_last_update_login
  );
  --
  ben_ctp_shd.g_api_dml := false;   -- Unset the api dml status
  hr_utility.set_location(' Leaving:'||l_proc, 15);
--
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    ben_ctp_shd.g_api_dml := false;   -- Unset the api dml status
    ben_ctp_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    ben_ctp_shd.g_api_dml := false;   -- Unset the api dml status
    ben_ctp_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    ben_ctp_shd.g_api_dml := false;   -- Unset the api dml status
    Raise;
End dt_insert_dml;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< insert_dml >------------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_dml
	(p_rec 			 in out nocopy ben_ctp_shd.g_rec_type,
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
	(p_rec  			in out nocopy ben_ctp_shd.g_rec_type,
	 p_effective_date		in date,
	 p_datetrack_mode		in varchar2,
	 p_validation_start_date	in date,
	 p_validation_end_date		in date) is
--
  l_proc	varchar2(72) := g_package||'pre_insert';
--
--
  cursor c1 is select ben_ptip_f_s.nextval
               from sys.dual;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  open c1;
  fetch c1 into p_rec.ptip_id;
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
	(p_rec 			 in ben_ctp_shd.g_rec_type,
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
    ben_ctp_rki.after_insert
      (
  p_ptip_id                       =>p_rec.ptip_id
 ,p_effective_start_date          =>p_rec.effective_start_date
 ,p_effective_end_date            =>p_rec.effective_end_date
 ,p_business_group_id             =>p_rec.business_group_id
 ,p_pgm_id                        =>p_rec.pgm_id
 ,p_cmbn_ptip_id                  =>p_rec.cmbn_ptip_id
 ,p_cmbn_ptip_opt_id              =>p_rec.cmbn_ptip_opt_id
 ,p_acrs_ptip_cvg_id              =>p_rec.acrs_ptip_cvg_id
 ,p_pl_typ_id                     =>p_rec.pl_typ_id
 ,p_coord_cvg_for_all_pls_flag    =>p_rec.coord_cvg_for_all_pls_flag
 ,p_dpnt_dsgn_cd                  =>p_rec.dpnt_dsgn_cd
 ,p_dpnt_cvg_strt_dt_rl           =>p_rec.dpnt_cvg_strt_dt_rl
 ,p_dpnt_cvg_end_dt_rl            =>p_rec.dpnt_cvg_end_dt_rl
 ,p_postelcn_edit_rl              =>p_rec.postelcn_edit_rl
 ,p_rt_end_dt_rl                  =>p_rec.rt_end_dt_rl
 ,p_rt_strt_dt_rl                 =>p_rec.rt_strt_dt_rl
 ,p_enrt_cvg_end_dt_rl            =>p_rec.enrt_cvg_end_dt_rl
 ,p_enrt_cvg_strt_dt_rl           =>p_rec.enrt_cvg_strt_dt_rl
 ,p_rqd_perd_enrt_nenrt_rl        =>p_rec.rqd_perd_enrt_nenrt_rl
 ,p_auto_enrt_mthd_rl             =>p_rec.auto_enrt_mthd_rl
 ,p_enrt_mthd_cd                  =>p_rec.enrt_mthd_cd
 ,p_enrt_cd                       =>p_rec.enrt_cd
 ,p_enrt_rl                       =>p_rec.enrt_rl
 ,p_dflt_enrt_cd                  =>p_rec.dflt_enrt_cd
 ,p_dflt_enrt_det_rl              =>p_rec.dflt_enrt_det_rl
 ,p_drvbl_fctr_apls_rts_flag      =>p_rec.drvbl_fctr_apls_rts_flag
 ,p_drvbl_fctr_prtn_elig_flag     =>p_rec.drvbl_fctr_prtn_elig_flag
 ,p_elig_apls_flag                =>p_rec.elig_apls_flag
 ,p_prtn_elig_ovrid_alwd_flag     =>p_rec.prtn_elig_ovrid_alwd_flag
 ,p_trk_inelig_per_flag           =>p_rec.trk_inelig_per_flag
 ,p_rt_end_dt_cd                  =>p_rec.rt_end_dt_cd
 ,p_rt_strt_dt_cd                 =>p_rec.rt_strt_dt_cd
 ,p_enrt_cvg_end_dt_cd            =>p_rec.enrt_cvg_end_dt_cd
 ,p_enrt_cvg_strt_dt_cd           =>p_rec.enrt_cvg_strt_dt_cd
 ,p_dpnt_cvg_end_dt_cd            =>p_rec.dpnt_cvg_end_dt_cd
 ,p_dpnt_cvg_strt_dt_cd           =>p_rec.dpnt_cvg_strt_dt_cd
 ,p_crs_this_pl_typ_only_flag     =>p_rec.crs_this_pl_typ_only_flag
 ,p_ptip_stat_cd                  =>p_rec.ptip_stat_cd
 ,p_mx_cvg_alwd_amt               =>p_rec.mx_cvg_alwd_amt
 ,p_mx_enrd_alwd_ovrid_num        =>p_rec.mx_enrd_alwd_ovrid_num
 ,p_mn_enrd_rqd_ovrid_num         =>p_rec.mn_enrd_rqd_ovrid_num
 ,p_no_mx_pl_typ_ovrid_flag       =>p_rec.no_mx_pl_typ_ovrid_flag
 ,p_ordr_num                      =>p_rec.ordr_num
 ,p_prvds_cr_flag                 =>p_rec.prvds_cr_flag
 ,p_rqd_perd_enrt_nenrt_val       =>p_rec.rqd_perd_enrt_nenrt_val
 ,p_rqd_perd_enrt_nenrt_tm_uom    =>p_rec.rqd_perd_enrt_nenrt_tm_uom
 ,p_wvbl_flag                     =>p_rec.wvbl_flag
 ,p_dpnt_adrs_rqd_flag            =>p_rec.dpnt_adrs_rqd_flag
 ,p_dpnt_cvg_no_ctfn_rqd_flag     =>p_rec.dpnt_cvg_no_ctfn_rqd_flag
 ,p_dpnt_dob_rqd_flag             =>p_rec.dpnt_dob_rqd_flag
 ,p_dpnt_legv_id_rqd_flag         =>p_rec.dpnt_legv_id_rqd_flag
 ,p_susp_if_dpnt_ssn_nt_prv_cd    =>p_rec.susp_if_dpnt_ssn_nt_prv_cd
 ,p_susp_if_dpnt_dob_nt_prv_cd    =>p_rec.susp_if_dpnt_dob_nt_prv_cd
 ,p_susp_if_dpnt_adr_nt_prv_cd    =>p_rec.susp_if_dpnt_adr_nt_prv_cd
 ,p_susp_if_ctfn_not_dpnt_flag    =>p_rec.susp_if_ctfn_not_dpnt_flag
 ,p_dpnt_ctfn_determine_cd        =>p_rec.dpnt_ctfn_determine_cd
 ,p_drvd_fctr_dpnt_cvg_flag       =>p_rec.drvd_fctr_dpnt_cvg_flag
 ,p_no_mn_pl_typ_overid_flag      =>p_rec.no_mn_pl_typ_overid_flag
 ,p_sbj_to_sps_lf_ins_mx_flag   =>p_rec.sbj_to_sps_lf_ins_mx_flag
 ,p_sbj_to_dpnt_lf_ins_mx_flag  =>p_rec.sbj_to_dpnt_lf_ins_mx_flag
 ,p_use_to_sum_ee_lf_ins_flag     =>p_rec.use_to_sum_ee_lf_ins_flag
 ,p_per_cvrd_cd                   =>p_rec.per_cvrd_cd
 ,p_short_name                   =>p_rec.short_name
 ,p_short_code                   =>p_rec.short_code
  ,p_legislation_code                   =>p_rec.legislation_code
  ,p_legislation_subgroup                   =>p_rec.legislation_subgroup
 ,p_vrfy_fmly_mmbr_cd             =>p_rec.vrfy_fmly_mmbr_cd
 ,p_vrfy_fmly_mmbr_rl             =>p_rec.vrfy_fmly_mmbr_rl
 ,p_ivr_ident                     =>p_rec.ivr_ident
 ,p_url_ref_name                  =>p_rec.url_ref_name
 ,p_rqd_enrt_perd_tco_cd          =>p_rec.rqd_enrt_perd_tco_cd
 ,p_ctp_attribute_category        =>p_rec.ctp_attribute_category
 ,p_ctp_attribute1                =>p_rec.ctp_attribute1
 ,p_ctp_attribute2                =>p_rec.ctp_attribute2
 ,p_ctp_attribute3                =>p_rec.ctp_attribute3
 ,p_ctp_attribute4                =>p_rec.ctp_attribute4
 ,p_ctp_attribute5                =>p_rec.ctp_attribute5
 ,p_ctp_attribute6                =>p_rec.ctp_attribute6
 ,p_ctp_attribute7                =>p_rec.ctp_attribute7
 ,p_ctp_attribute8                =>p_rec.ctp_attribute8
 ,p_ctp_attribute9                =>p_rec.ctp_attribute9
 ,p_ctp_attribute10               =>p_rec.ctp_attribute10
 ,p_ctp_attribute11               =>p_rec.ctp_attribute11
 ,p_ctp_attribute12               =>p_rec.ctp_attribute12
 ,p_ctp_attribute13               =>p_rec.ctp_attribute13
 ,p_ctp_attribute14               =>p_rec.ctp_attribute14
 ,p_ctp_attribute15               =>p_rec.ctp_attribute15
 ,p_ctp_attribute16               =>p_rec.ctp_attribute16
 ,p_ctp_attribute17               =>p_rec.ctp_attribute17
 ,p_ctp_attribute18               =>p_rec.ctp_attribute18
 ,p_ctp_attribute19               =>p_rec.ctp_attribute19
 ,p_ctp_attribute20               =>p_rec.ctp_attribute20
 ,p_ctp_attribute21               =>p_rec.ctp_attribute21
 ,p_ctp_attribute22               =>p_rec.ctp_attribute22
 ,p_ctp_attribute23               =>p_rec.ctp_attribute23
 ,p_ctp_attribute24               =>p_rec.ctp_attribute24
 ,p_ctp_attribute25               =>p_rec.ctp_attribute25
 ,p_ctp_attribute26               =>p_rec.ctp_attribute26
 ,p_ctp_attribute27               =>p_rec.ctp_attribute27
 ,p_ctp_attribute28               =>p_rec.ctp_attribute28
 ,p_ctp_attribute29               =>p_rec.ctp_attribute29
 ,p_ctp_attribute30               =>p_rec.ctp_attribute30
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
        (p_module_name => 'ben_ptip_f'
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
	 p_rec	 		 in  ben_ctp_shd.g_rec_type,
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
	 p_base_table_name	   => 'ben_ptip_f',
	 p_base_key_column	   => 'ptip_id',
	 p_base_key_value 	   => p_rec.ptip_id,
	 p_parent_table_name1      => 'ben_pgm_f',
	 p_parent_key_column1      => 'pgm_id',
	 p_parent_key_value1       => p_rec.pgm_id,
	 p_parent_table_name2      => 'ben_pl_typ_f',
	 p_parent_key_column2      => 'pl_typ_id',
	 p_parent_key_value2       => p_rec.pl_typ_id,
	 p_parent_table_name3      => 'ben_cmbn_ptip_f',
	 p_parent_key_column3      => 'cmbn_ptip_id',
	 p_parent_key_value3       => p_rec.cmbn_ptip_id,
	 p_parent_table_name4      => 'ben_cmbn_ptip_opt_f',
	 p_parent_key_column4      => 'cmbn_ptip_opt_id',
	 p_parent_key_value4       => p_rec.cmbn_ptip_opt_id,
         p_parent_table_name5      => 'ben_acrs_ptip_cvg_f',
         p_parent_key_column5      => 'acrs_ptip_cvg_id',
         p_parent_key_value5       => p_rec.acrs_ptip_cvg_id,
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
  p_rec		   in out nocopy ben_ctp_shd.g_rec_type,
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
  ben_ctp_bus.insert_validate
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
  p_ptip_id                      out nocopy number,
  p_effective_start_date         out nocopy date,
  p_effective_end_date           out nocopy date,
  p_coord_cvg_for_all_pls_flag   in varchar2         default 'N',
  p_dpnt_dsgn_cd                 in varchar2         default null,
  p_dpnt_cvg_no_ctfn_rqd_flag    in varchar2         default 'N',
  p_dpnt_cvg_strt_dt_cd          in varchar2         default null,
  p_rt_end_dt_cd                 in varchar2         default null,
  p_rt_strt_dt_cd                in varchar2         default null,
  p_enrt_cvg_end_dt_cd           in varchar2         default null,
  p_enrt_cvg_strt_dt_cd          in varchar2         default null,
  p_dpnt_cvg_strt_dt_rl          in number           default null,
  p_dpnt_cvg_end_dt_cd           in varchar2         default null,
  p_dpnt_cvg_end_dt_rl           in number           default null,
  p_dpnt_adrs_rqd_flag           in varchar2         default 'N',
  p_dpnt_legv_id_rqd_flag        in varchar2         default 'N',
  p_susp_if_dpnt_ssn_nt_prv_cd      in  varchar2   default null,
  p_susp_if_dpnt_dob_nt_prv_cd      in  varchar2   default null,
  p_susp_if_dpnt_adr_nt_prv_cd      in  varchar2   default null,
  p_susp_if_ctfn_not_dpnt_flag      in  varchar2   default 'Y',
  p_dpnt_ctfn_determine_cd          in  varchar2   default null,
  p_postelcn_edit_rl             in number           default null,
  p_rt_end_dt_rl                 in number           default null,
  p_rt_strt_dt_rl                in number           default null,
  p_enrt_cvg_end_dt_rl           in number           default null,
  p_enrt_cvg_strt_dt_rl          in number           default null,
  p_rqd_perd_enrt_nenrt_rl       in number           default null,
  p_auto_enrt_mthd_rl            in number           default null,
  p_enrt_mthd_cd                 in varchar2         default null,
  p_enrt_cd                      in varchar2         default null,
  p_enrt_rl                      in number           default null,
  p_dflt_enrt_cd                 in varchar2         default null,
  p_dflt_enrt_det_rl             in number           default null,
  p_drvbl_fctr_apls_rts_flag     in varchar2         default 'N',
  p_drvbl_fctr_prtn_elig_flag    in varchar2         default 'N',
  p_elig_apls_flag               in varchar2         default 'N',
  p_prtn_elig_ovrid_alwd_flag    in varchar2         default 'N',
  p_trk_inelig_per_flag          in varchar2         default 'N',
  p_dpnt_dob_rqd_flag            in varchar2         default 'N',
  p_crs_this_pl_typ_only_flag    in varchar2         default 'N',
  p_ptip_stat_cd                 in varchar2         default null,
  p_mx_cvg_alwd_amt              in number           default null,
  p_mx_enrd_alwd_ovrid_num       in number           default null,
  p_mn_enrd_rqd_ovrid_num        in number           default null,
  p_no_mx_pl_typ_ovrid_flag      in varchar2         default 'N',
  p_ordr_num                     in number           default null,
  p_prvds_cr_flag                in varchar2         default 'N',
  p_rqd_perd_enrt_nenrt_val      in number           default null,
  p_rqd_perd_enrt_nenrt_tm_uom   in varchar2         default null,
  p_wvbl_flag                    in varchar2         default 'N',
  p_drvd_fctr_dpnt_cvg_flag      in varchar2         default 'N',
  p_no_mn_pl_typ_overid_flag     in varchar2         default 'N',
  p_sbj_to_sps_lf_ins_mx_flag    in varchar2         default 'N',
  p_sbj_to_dpnt_lf_ins_mx_flag   in varchar2         default 'N',
  p_use_to_sum_ee_lf_ins_flag    in varchar2         default 'N',
  p_per_cvrd_cd                  in varchar2         default null,
  p_short_name                  in varchar2         default null,
  p_short_code                  in varchar2         default null,
    p_legislation_code                  in varchar2         default null,
    p_legislation_subgroup                  in varchar2         default null,
  p_vrfy_fmly_mmbr_cd            in varchar2         default null,
  p_vrfy_fmly_mmbr_rl            in number           default null,
  p_ivr_ident                    in varchar2         default null,
  p_url_ref_name                 in varchar2         default null,
  p_rqd_enrt_perd_tco_cd         in varchar2         default null,
  p_pgm_id                       in number,
  p_pl_typ_id                    in number,
  p_cmbn_ptip_id                 in number           default null,
  p_cmbn_ptip_opt_id             in number           default null,
  p_acrs_ptip_cvg_id             in number           default null,
  p_business_group_id            in number,
  p_ctp_attribute_category       in varchar2         default null,
  p_ctp_attribute1               in varchar2         default null,
  p_ctp_attribute2               in varchar2         default null,
  p_ctp_attribute3               in varchar2         default null,
  p_ctp_attribute4               in varchar2         default null,
  p_ctp_attribute5               in varchar2         default null,
  p_ctp_attribute6               in varchar2         default null,
  p_ctp_attribute7               in varchar2         default null,
  p_ctp_attribute8               in varchar2         default null,
  p_ctp_attribute9               in varchar2         default null,
  p_ctp_attribute10              in varchar2         default null,
  p_ctp_attribute11              in varchar2         default null,
  p_ctp_attribute12              in varchar2         default null,
  p_ctp_attribute13              in varchar2         default null,
  p_ctp_attribute14              in varchar2         default null,
  p_ctp_attribute15              in varchar2         default null,
  p_ctp_attribute16              in varchar2         default null,
  p_ctp_attribute17              in varchar2         default null,
  p_ctp_attribute18              in varchar2         default null,
  p_ctp_attribute19              in varchar2         default null,
  p_ctp_attribute20              in varchar2         default null,
  p_ctp_attribute21              in varchar2         default null,
  p_ctp_attribute22              in varchar2         default null,
  p_ctp_attribute23              in varchar2         default null,
  p_ctp_attribute24              in varchar2         default null,
  p_ctp_attribute25              in varchar2         default null,
  p_ctp_attribute26              in varchar2         default null,
  p_ctp_attribute27              in varchar2         default null,
  p_ctp_attribute28              in varchar2         default null,
  p_ctp_attribute29              in varchar2         default null,
  p_ctp_attribute30              in varchar2         default null,
  p_object_version_number        out nocopy number,
  p_effective_date               in date
  ) is
--
  l_rec		ben_ctp_shd.g_rec_type;
  l_proc	varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  ben_ctp_shd.convert_args
  (
  null,
  null,
  null,
  p_coord_cvg_for_all_pls_flag,
  p_dpnt_dsgn_cd,
  p_dpnt_cvg_no_ctfn_rqd_flag,
  p_dpnt_cvg_strt_dt_cd,
  p_rt_end_dt_cd,
  p_rt_strt_dt_cd,
  p_enrt_cvg_end_dt_cd,
  p_enrt_cvg_strt_dt_cd,
  p_dpnt_cvg_strt_dt_rl,
  p_dpnt_cvg_end_dt_cd,
  p_dpnt_cvg_end_dt_rl,
  p_dpnt_adrs_rqd_flag,
  p_dpnt_legv_id_rqd_flag,
  p_susp_if_dpnt_ssn_nt_prv_cd,
  p_susp_if_dpnt_dob_nt_prv_cd,
  p_susp_if_dpnt_adr_nt_prv_cd,
  p_susp_if_ctfn_not_dpnt_flag,
  p_dpnt_ctfn_determine_cd,
  p_postelcn_edit_rl,
  p_rt_end_dt_rl,
  p_rt_strt_dt_rl,
  p_enrt_cvg_end_dt_rl,
  p_enrt_cvg_strt_dt_rl,
  p_rqd_perd_enrt_nenrt_rl,
  p_auto_enrt_mthd_rl,
  p_enrt_mthd_cd,
  p_enrt_cd,
  p_enrt_rl,
  p_dflt_enrt_cd,
  p_dflt_enrt_det_rl,
  p_drvbl_fctr_apls_rts_flag,
  p_drvbl_fctr_prtn_elig_flag,
  p_elig_apls_flag,
  p_prtn_elig_ovrid_alwd_flag,
  p_trk_inelig_per_flag,
  p_dpnt_dob_rqd_flag,
  p_crs_this_pl_typ_only_flag,
  p_ptip_stat_cd,
  p_mx_cvg_alwd_amt,
  p_mx_enrd_alwd_ovrid_num,
  p_mn_enrd_rqd_ovrid_num,
  p_no_mx_pl_typ_ovrid_flag,
  p_ordr_num,
  p_prvds_cr_flag,
  p_rqd_perd_enrt_nenrt_val,
  p_rqd_perd_enrt_nenrt_tm_uom,
  p_wvbl_flag,
  p_drvd_fctr_dpnt_cvg_flag,
  p_no_mn_pl_typ_overid_flag,
  p_sbj_to_sps_lf_ins_mx_flag,
  p_sbj_to_dpnt_lf_ins_mx_flag,
  p_use_to_sum_ee_lf_ins_flag,
  p_per_cvrd_cd,
  p_short_name,
  p_short_code,
    p_legislation_code,
    p_legislation_subgroup,
  p_vrfy_fmly_mmbr_cd,
  p_vrfy_fmly_mmbr_rl,
  p_ivr_ident,
  p_url_ref_name,
  p_rqd_enrt_perd_tco_cd,
  p_pgm_id,
  p_pl_typ_id,
  p_cmbn_ptip_id,
  p_cmbn_ptip_opt_id,
  p_acrs_ptip_cvg_id,
  p_business_group_id,
  p_ctp_attribute_category,
  p_ctp_attribute1,
  p_ctp_attribute2,
  p_ctp_attribute3,
  p_ctp_attribute4,
  p_ctp_attribute5,
  p_ctp_attribute6,
  p_ctp_attribute7,
  p_ctp_attribute8,
  p_ctp_attribute9,
  p_ctp_attribute10,
  p_ctp_attribute11,
  p_ctp_attribute12,
  p_ctp_attribute13,
  p_ctp_attribute14,
  p_ctp_attribute15,
  p_ctp_attribute16,
  p_ctp_attribute17,
  p_ctp_attribute18,
  p_ctp_attribute19,
  p_ctp_attribute20,
  p_ctp_attribute21,
  p_ctp_attribute22,
  p_ctp_attribute23,
  p_ctp_attribute24,
  p_ctp_attribute25,
  p_ctp_attribute26,
  p_ctp_attribute27,
  p_ctp_attribute28,
  p_ctp_attribute29,
  p_ctp_attribute30,
  null);
  --
  -- Having converted the arguments into the ben_ctp_rec
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  ins(l_rec, p_effective_date);
  --
  -- Set the OUT arguments.
  --
  p_ptip_id        	:= l_rec.ptip_id;
  p_effective_start_date  	:= l_rec.effective_start_date;
  p_effective_end_date    	:= l_rec.effective_end_date;
  p_object_version_number 	:= l_rec.object_version_number;
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End ins;
--
end ben_ctp_ins;

/
