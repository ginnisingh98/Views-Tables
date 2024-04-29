--------------------------------------------------------
--  DDL for Package Body BEN_ABR_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_ABR_INS" as
/* $Header: beabrrhi.pkb 120.18 2008/05/15 10:36:51 krupani ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_abr_ins.';  -- Global package name
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
	(p_rec 			 in out nocopy ben_abr_shd.g_rec_type,
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
    from   ben_acty_base_rt_f t
    where  t.acty_base_rt_id       = p_rec.acty_base_rt_id
    and    t.effective_start_date =
             ben_abr_shd.g_old_rec.effective_start_date
    and    t.effective_end_date   = (p_validation_start_date - 1);

  --Added for Bug 6881417
  cursor c_oipl is
     select pl_id
     from   ben_oipl_f
     where  oipl_id = p_rec.oipl_id
     and    p_effective_date between effective_start_date and effective_end_date;

cursor c_plip is
     select pl_id
     from   ben_plip_f
     where  plip_id = p_rec.plip_id
     and    p_effective_date between effective_start_date and effective_end_date;

cursor c_oiplip is
select pl_id
from ben_oiplip_f opp,
     ben_oipl_f   op
where opp.oiplip_id = p_rec.oiplip_id
     and opp.oipl_id = op.oipl_id
     and  p_effective_date between opp.effective_start_date and opp.effective_end_date
     and  p_effective_date between op.effective_start_date and op.effective_end_date;

cursor c_pl_typ(p_pl_id number) is
  select opt_typ_cd
  from   ben_pl_typ_f ptp,
         ben_pl_f pln
  where  pln.pl_id = p_pl_id
  and	 ptp.pl_typ_id = pln.pl_typ_id
  and    p_effective_date between pln.effective_start_date and pln.effective_end_date
  and    p_effective_date between ptp.effective_start_date and ptp.effective_end_date;
--
l_opt_typ_cd ben_pl_typ_f.opt_typ_cd%TYPE;
l_pl_id number;
--End of Code for Bug 6881417

--
  l_proc		varchar2(72) := g_package||'dt_insert_dml';
  l_created_by          ben_acty_base_rt_f.created_by%TYPE;
  l_creation_date       ben_acty_base_rt_f.creation_date%TYPE;
  l_last_update_date   	ben_acty_base_rt_f.last_update_date%TYPE;
  l_last_updated_by     ben_acty_base_rt_f.last_updated_by%TYPE;
  l_last_update_login   ben_acty_base_rt_f.last_update_login%TYPE;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Get the object version number for the insert
  --
  p_rec.object_version_number :=
    dt_api.get_object_version_number
	(p_base_table_name => 'ben_acty_base_rt_f',
	 p_base_key_column => 'acty_base_rt_id',
	 p_base_key_value  => p_rec.acty_base_rt_id);
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
  ben_abr_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Insert the row into: ben_acty_base_rt_f
  --
  hr_utility.set_location('total rate befr insert '||p_rec.TTL_COMP_LVL_FCTR_ID, 99);

  --Added for Bug 6881417
  if( p_rec.pl_id is not null) then
    open c_pl_typ(p_rec.pl_id);
    fetch c_pl_typ into l_opt_typ_cd;
    close c_pl_typ;
  end if;

  if( p_rec.plip_id is not null) then
    open c_plip;
    fetch c_plip into l_pl_id;
    close c_plip;

     open c_pl_typ(l_pl_id);
    fetch c_pl_typ into l_opt_typ_cd;
    close c_pl_typ;
  end if;

  if( p_rec.oipl_id is not null) then
    open c_oipl;
    fetch c_oipl into l_pl_id;
    close c_oipl;

    open c_pl_typ(l_pl_id);
    fetch c_pl_typ into l_opt_typ_cd;
    close c_pl_typ;
  end if;

  if( p_rec.oiplip_id is not null) then
    open c_oiplip;
    fetch c_oiplip into l_pl_id;
    close c_oiplip;

    open c_pl_typ(l_pl_id);
    fetch c_pl_typ into l_opt_typ_cd;
    close c_pl_typ;
  end if;
  --Added for Bug 6881417

  -- Added if..else condition for Bug 6881417, Element related information should not be copied for ICD plans thru PDC
  if(ben_abr_bus.g_ssben_call and l_opt_typ_cd='ICM') then

   fnd_file.put_line(fnd_file.log, 'Element and Input Value not copied for Rate Defintion '||p_rec.name);
   ben_abr_bus.g_ssben_var := ben_abr_bus.g_ssben_var || p_rec.name ||' ,';
   insert into ben_acty_base_rt_f
   (	acty_base_rt_id,
	effective_start_date,
	effective_end_date,
	ordr_num,
	acty_typ_cd,
	sub_acty_typ_cd,
	element_type_id,
        input_value_id,
        input_va_calc_rl,
        comp_lvl_fctr_id,
        parnt_acty_base_rt_id,
	pgm_id,
	pl_id,
	oipl_id,
        opt_id,
        oiplip_id,
	plip_id,
	ptip_id,
	cmbn_ptip_opt_id,
	vstg_for_acty_rt_id,
        actl_prem_id,
        ALWS_CHG_CD,
        ele_entry_val_cd,
        TTL_COMP_LVL_FCTR_ID,
        COST_ALLOCATION_KEYFLEX_ID,
	rt_typ_cd,
        bnft_rt_typ_cd,
	tx_typ_cd,
	use_to_calc_net_flx_cr_flag,
	asn_on_enrt_flag,
	abv_mx_elcn_val_alwd_flag,
	blw_mn_elcn_alwd_flag,
	parnt_chld_cd,
	use_calc_acty_bs_rt_flag,
	uses_ded_sched_flag,
	uses_varbl_rt_flag,
	vstg_sched_apls_flag,
	rt_mlt_cd,
	proc_each_pp_dflt_flag,
	prdct_flx_cr_when_elig_flag,
	no_std_rt_used_flag,
	rcrrg_cd,
	mn_elcn_val,
	mx_elcn_val,
        lwr_lmt_val,
        lwr_lmt_calc_rl,
        upr_lmt_val,
        upr_lmt_calc_rl,
        ptd_comp_lvl_fctr_id,
        clm_comp_lvl_fctr_id,
        entr_ann_val_flag,
        ann_mn_elcn_val,
        ann_mx_elcn_val,
        wsh_rl_dy_mo_num,
	uses_pymt_sched_flag,
	nnmntry_uom,
	val,
	incrmt_elcn_val,
	rndg_cd,
	val_ovrid_alwd_flag,
	prtl_mo_det_mthd_cd,
	acty_base_rt_stat_cd,
	procg_src_cd,
	dflt_val,
        dflt_flag,
	frgn_erg_ded_typ_cd,
	frgn_erg_ded_name,
	frgn_erg_ded_ident,
	no_mx_elcn_val_dfnd_flag,
	cmbn_plip_id,
	cmbn_ptip_id,
	prtl_mo_det_mthd_rl,
	entr_val_at_enrt_flag,
	prtl_mo_eff_dt_det_rl,
	rndg_rl,
	val_calc_rl,
	no_mn_elcn_val_dfnd_flag,
	prtl_mo_eff_dt_det_cd,
        pay_rate_grade_rule_id,
        rate_periodization_cd,
        rate_periodization_rl,
	business_group_id,
        only_one_bal_typ_alwd_flag,
        rt_usg_cd,
        prort_mn_ann_elcn_val_cd,
        prort_mn_ann_elcn_val_rl,
        prort_mx_ann_elcn_val_cd,
        prort_mx_ann_elcn_val_rl,
        one_ann_pymt_cd,
        det_pl_ytd_cntrs_cd,
        asmt_to_use_cd,
        ele_rqd_flag,
        subj_to_imptd_incm_flag,
        name,
        dsply_on_enrt_flag,
	mn_mx_elcn_rl,
	mapping_table_name,
        mapping_table_pk_id,
        context_pgm_id,
	context_pl_id,
	context_opt_id,
	element_det_rl,
	currency_det_cd,
	abr_attribute_category,
	abr_attribute1,
	abr_attribute2,
	abr_attribute3,
	abr_attribute4,
	abr_attribute5,
	abr_attribute6,
	abr_attribute7,
	abr_attribute8,
	abr_attribute9,
	abr_attribute10,
	abr_attribute11,
	abr_attribute12,
	abr_attribute13,
	abr_attribute14,
	abr_attribute15,
	abr_attribute16,
	abr_attribute17,
	abr_attribute18,
	abr_attribute19,
	abr_attribute20,
	abr_attribute21,
	abr_attribute22,
	abr_attribute23,
	abr_attribute24,
	abr_attribute25,
	abr_attribute26,
	abr_attribute27,
	abr_attribute28,
	abr_attribute29,
	abr_attribute30,
	abr_seq_num,
	object_version_number,
   	created_by,
   	creation_date,
   	last_update_date,
   	last_updated_by,
   	last_update_login
  )
  Values
  (	p_rec.acty_base_rt_id,
	p_rec.effective_start_date,
	p_rec.effective_end_date,
	p_rec.ordr_num,
	p_rec.acty_typ_cd,
	p_rec.sub_acty_typ_cd,
	null,
	null,
	null,
        p_rec.comp_lvl_fctr_id,
        p_rec.parnt_acty_base_rt_id,
	p_rec.pgm_id,
	p_rec.pl_id,
	p_rec.oipl_id,
        p_rec.opt_id,
        p_rec.oiplip_id,
	p_rec.plip_id,
	p_rec.ptip_id,
	p_rec.cmbn_ptip_opt_id,
	p_rec.vstg_for_acty_rt_id,
        p_rec.actl_prem_id,
        p_rec.ALWS_CHG_CD,
        null,
        p_rec.TTL_COMP_LVL_FCTR_ID,
        p_rec.COST_ALLOCATION_KEYFLEX_ID,
	p_rec.rt_typ_cd,
        p_rec.bnft_rt_typ_cd,
	p_rec.tx_typ_cd,
	p_rec.use_to_calc_net_flx_cr_flag,
	p_rec.asn_on_enrt_flag,
	p_rec.abv_mx_elcn_val_alwd_flag,
	p_rec.blw_mn_elcn_alwd_flag,
	p_rec.parnt_chld_cd,
	p_rec.use_calc_acty_bs_rt_flag,
	p_rec.uses_ded_sched_flag,
	p_rec.uses_varbl_rt_flag,
	p_rec.vstg_sched_apls_flag,
	p_rec.rt_mlt_cd,
	p_rec.proc_each_pp_dflt_flag,
	p_rec.prdct_flx_cr_when_elig_flag,
	p_rec.no_std_rt_used_flag,
	p_rec.rcrrg_cd,
	p_rec.mn_elcn_val,
	p_rec.mx_elcn_val,
        p_rec.lwr_lmt_val,
        p_rec.lwr_lmt_calc_rl,
        p_rec.upr_lmt_val,
        p_rec.upr_lmt_calc_rl,
        p_rec.ptd_comp_lvl_fctr_id,
        p_rec.clm_comp_lvl_fctr_id,
        p_rec.entr_ann_val_flag,
        p_rec.ann_mn_elcn_val,
        p_rec.ann_mx_elcn_val,
        p_rec.wsh_rl_dy_mo_num,
	p_rec.uses_pymt_sched_flag,
	p_rec.nnmntry_uom,
	p_rec.val,
	p_rec.incrmt_elcn_val,
	p_rec.rndg_cd,
	p_rec.val_ovrid_alwd_flag,
	p_rec.prtl_mo_det_mthd_cd,
	p_rec.acty_base_rt_stat_cd,
	p_rec.procg_src_cd,
	p_rec.dflt_val,
        p_rec.dflt_flag,
	p_rec.frgn_erg_ded_typ_cd,
	p_rec.frgn_erg_ded_name,
	p_rec.frgn_erg_ded_ident,
	p_rec.no_mx_elcn_val_dfnd_flag,
	p_rec.cmbn_plip_id,
	p_rec.cmbn_ptip_id,
	p_rec.prtl_mo_det_mthd_rl,
	p_rec.entr_val_at_enrt_flag,
	p_rec.prtl_mo_eff_dt_det_rl,
	p_rec.rndg_rl,
	p_rec.val_calc_rl,
	p_rec.no_mn_elcn_val_dfnd_flag,
	p_rec.prtl_mo_eff_dt_det_cd,
        p_rec.pay_rate_grade_rule_id,
        p_rec.rate_periodization_cd,
        p_rec.rate_periodization_rl,
	p_rec.business_group_id,
        p_rec.only_one_bal_typ_alwd_flag,
        p_rec.rt_usg_cd,
        p_rec.prort_mn_ann_elcn_val_cd,
        p_rec.prort_mn_ann_elcn_val_rl,
        p_rec.prort_mx_ann_elcn_val_cd,
        p_rec.prort_mx_ann_elcn_val_rl,
        p_rec.one_ann_pymt_cd,
        p_rec.det_pl_ytd_cntrs_cd,
        p_rec.asmt_to_use_cd,
        'N',
        p_rec.subj_to_imptd_incm_flag,
        p_rec.name,
        p_rec.dsply_on_enrt_flag,
	p_rec.mn_mx_elcn_rl,
	p_rec.mapping_table_name,
	p_rec.mapping_table_pk_id,
        p_rec.context_pgm_id,
	p_rec.context_pl_id,
	p_rec.context_opt_id,
	null,
	p_rec.currency_det_cd,
	p_rec.abr_attribute_category,
	p_rec.abr_attribute1,
	p_rec.abr_attribute2,
	p_rec.abr_attribute3,
	p_rec.abr_attribute4,
	p_rec.abr_attribute5,
	p_rec.abr_attribute6,
	p_rec.abr_attribute7,
	p_rec.abr_attribute8,
	p_rec.abr_attribute9,
	p_rec.abr_attribute10,
	p_rec.abr_attribute11,
	p_rec.abr_attribute12,
	p_rec.abr_attribute13,
	p_rec.abr_attribute14,
	p_rec.abr_attribute15,
	p_rec.abr_attribute16,
	p_rec.abr_attribute17,
	p_rec.abr_attribute18,
	p_rec.abr_attribute19,
	p_rec.abr_attribute20,
	p_rec.abr_attribute21,
	p_rec.abr_attribute22,
	p_rec.abr_attribute23,
	p_rec.abr_attribute24,
	p_rec.abr_attribute25,
	p_rec.abr_attribute26,
	p_rec.abr_attribute27,
	p_rec.abr_attribute28,
	p_rec.abr_attribute29,
	p_rec.abr_attribute30,
	p_rec.abr_seq_num,
	p_rec.object_version_number,
	l_created_by,
   	l_creation_date,
   	l_last_update_date,
   	l_last_updated_by,
   	l_last_update_login
  );
else
     insert into ben_acty_base_rt_f
  (	acty_base_rt_id,
	effective_start_date,
	effective_end_date,
	ordr_num,
	acty_typ_cd,
	sub_acty_typ_cd,
	element_type_id,
        input_value_id,
        input_va_calc_rl,
        comp_lvl_fctr_id,
        parnt_acty_base_rt_id,
	pgm_id,
	pl_id,
	oipl_id,
        opt_id,
        oiplip_id,
	plip_id,
	ptip_id,
	cmbn_ptip_opt_id,
	vstg_for_acty_rt_id,
        actl_prem_id,
        ALWS_CHG_CD,
        ele_entry_val_cd,
        TTL_COMP_LVL_FCTR_ID,
        COST_ALLOCATION_KEYFLEX_ID,
	rt_typ_cd,
        bnft_rt_typ_cd,
	tx_typ_cd,
	use_to_calc_net_flx_cr_flag,
	asn_on_enrt_flag,
	abv_mx_elcn_val_alwd_flag,
	blw_mn_elcn_alwd_flag,
	parnt_chld_cd,
	use_calc_acty_bs_rt_flag,
	uses_ded_sched_flag,
	uses_varbl_rt_flag,
	vstg_sched_apls_flag,
	rt_mlt_cd,
	proc_each_pp_dflt_flag,
	prdct_flx_cr_when_elig_flag,
	no_std_rt_used_flag,
	rcrrg_cd,
	mn_elcn_val,
	mx_elcn_val,
        lwr_lmt_val,
        lwr_lmt_calc_rl,
        upr_lmt_val,
        upr_lmt_calc_rl,
        ptd_comp_lvl_fctr_id,
        clm_comp_lvl_fctr_id,
        entr_ann_val_flag,
        ann_mn_elcn_val,
        ann_mx_elcn_val,
        wsh_rl_dy_mo_num,
	uses_pymt_sched_flag,
	nnmntry_uom,
	val,
	incrmt_elcn_val,
	rndg_cd,
	val_ovrid_alwd_flag,
	prtl_mo_det_mthd_cd,
	acty_base_rt_stat_cd,
	procg_src_cd,
	dflt_val,
        dflt_flag,
	frgn_erg_ded_typ_cd,
	frgn_erg_ded_name,
	frgn_erg_ded_ident,
	no_mx_elcn_val_dfnd_flag,
	cmbn_plip_id,
	cmbn_ptip_id,
	prtl_mo_det_mthd_rl,
	entr_val_at_enrt_flag,
	prtl_mo_eff_dt_det_rl,
	rndg_rl,
	val_calc_rl,
	no_mn_elcn_val_dfnd_flag,
	prtl_mo_eff_dt_det_cd,
        pay_rate_grade_rule_id,
        rate_periodization_cd,
        rate_periodization_rl,
	business_group_id,
        only_one_bal_typ_alwd_flag,
        rt_usg_cd,
        prort_mn_ann_elcn_val_cd,
        prort_mn_ann_elcn_val_rl,
        prort_mx_ann_elcn_val_cd,
        prort_mx_ann_elcn_val_rl,
        one_ann_pymt_cd,
        det_pl_ytd_cntrs_cd,
        asmt_to_use_cd,
        ele_rqd_flag,
        subj_to_imptd_incm_flag,
        name,
        dsply_on_enrt_flag,
	mn_mx_elcn_rl,
	mapping_table_name,
        mapping_table_pk_id,
        context_pgm_id,
	context_pl_id,
	context_opt_id,
	element_det_rl,
	currency_det_cd,
	abr_attribute_category,
	abr_attribute1,
	abr_attribute2,
	abr_attribute3,
	abr_attribute4,
	abr_attribute5,
	abr_attribute6,
	abr_attribute7,
	abr_attribute8,
	abr_attribute9,
	abr_attribute10,
	abr_attribute11,
	abr_attribute12,
	abr_attribute13,
	abr_attribute14,
	abr_attribute15,
	abr_attribute16,
	abr_attribute17,
	abr_attribute18,
	abr_attribute19,
	abr_attribute20,
	abr_attribute21,
	abr_attribute22,
	abr_attribute23,
	abr_attribute24,
	abr_attribute25,
	abr_attribute26,
	abr_attribute27,
	abr_attribute28,
	abr_attribute29,
	abr_attribute30,
	abr_seq_num,
	object_version_number,
   	created_by,
   	creation_date,
   	last_update_date,
   	last_updated_by,
   	last_update_login
  )
  Values
  (	p_rec.acty_base_rt_id,
	p_rec.effective_start_date,
	p_rec.effective_end_date,
	p_rec.ordr_num,
	p_rec.acty_typ_cd,
	p_rec.sub_acty_typ_cd,
	p_rec.element_type_id,
	p_rec.input_value_id,
	p_rec.input_va_calc_rl,
        p_rec.comp_lvl_fctr_id,
        p_rec.parnt_acty_base_rt_id,
	p_rec.pgm_id,
	p_rec.pl_id,
	p_rec.oipl_id,
        p_rec.opt_id,
        p_rec.oiplip_id,
	p_rec.plip_id,
	p_rec.ptip_id,
	p_rec.cmbn_ptip_opt_id,
	p_rec.vstg_for_acty_rt_id,
        p_rec.actl_prem_id,
        p_rec.ALWS_CHG_CD,
        p_rec.ele_entry_val_cd,
        p_rec.TTL_COMP_LVL_FCTR_ID,
        p_rec.COST_ALLOCATION_KEYFLEX_ID,
	p_rec.rt_typ_cd,
        p_rec.bnft_rt_typ_cd,
	p_rec.tx_typ_cd,
	p_rec.use_to_calc_net_flx_cr_flag,
	p_rec.asn_on_enrt_flag,
	p_rec.abv_mx_elcn_val_alwd_flag,
	p_rec.blw_mn_elcn_alwd_flag,
	p_rec.parnt_chld_cd,
	p_rec.use_calc_acty_bs_rt_flag,
	p_rec.uses_ded_sched_flag,
	p_rec.uses_varbl_rt_flag,
	p_rec.vstg_sched_apls_flag,
	p_rec.rt_mlt_cd,
	p_rec.proc_each_pp_dflt_flag,
	p_rec.prdct_flx_cr_when_elig_flag,
	p_rec.no_std_rt_used_flag,
	p_rec.rcrrg_cd,
	p_rec.mn_elcn_val,
	p_rec.mx_elcn_val,
        p_rec.lwr_lmt_val,
        p_rec.lwr_lmt_calc_rl,
        p_rec.upr_lmt_val,
        p_rec.upr_lmt_calc_rl,
        p_rec.ptd_comp_lvl_fctr_id,
        p_rec.clm_comp_lvl_fctr_id,
        p_rec.entr_ann_val_flag,
        p_rec.ann_mn_elcn_val,
        p_rec.ann_mx_elcn_val,
        p_rec.wsh_rl_dy_mo_num,
	p_rec.uses_pymt_sched_flag,
	p_rec.nnmntry_uom,
	p_rec.val,
	p_rec.incrmt_elcn_val,
	p_rec.rndg_cd,
	p_rec.val_ovrid_alwd_flag,
	p_rec.prtl_mo_det_mthd_cd,
	p_rec.acty_base_rt_stat_cd,
	p_rec.procg_src_cd,
	p_rec.dflt_val,
        p_rec.dflt_flag,
	p_rec.frgn_erg_ded_typ_cd,
	p_rec.frgn_erg_ded_name,
	p_rec.frgn_erg_ded_ident,
	p_rec.no_mx_elcn_val_dfnd_flag,
	p_rec.cmbn_plip_id,
	p_rec.cmbn_ptip_id,
	p_rec.prtl_mo_det_mthd_rl,
	p_rec.entr_val_at_enrt_flag,
	p_rec.prtl_mo_eff_dt_det_rl,
	p_rec.rndg_rl,
	p_rec.val_calc_rl,
	p_rec.no_mn_elcn_val_dfnd_flag,
	p_rec.prtl_mo_eff_dt_det_cd,
        p_rec.pay_rate_grade_rule_id,
        p_rec.rate_periodization_cd,
        p_rec.rate_periodization_rl,
	p_rec.business_group_id,
        p_rec.only_one_bal_typ_alwd_flag,
        p_rec.rt_usg_cd,
        p_rec.prort_mn_ann_elcn_val_cd,
        p_rec.prort_mn_ann_elcn_val_rl,
        p_rec.prort_mx_ann_elcn_val_cd,
        p_rec.prort_mx_ann_elcn_val_rl,
        p_rec.one_ann_pymt_cd,
        p_rec.det_pl_ytd_cntrs_cd,
        p_rec.asmt_to_use_cd,
        p_rec.ele_rqd_flag,
        p_rec.subj_to_imptd_incm_flag,
        p_rec.name,
        p_rec.dsply_on_enrt_flag,
	p_rec.mn_mx_elcn_rl,
	p_rec.mapping_table_name,
	p_rec.mapping_table_pk_id,
        p_rec.context_pgm_id,
	p_rec.context_pl_id,
	p_rec.context_opt_id,
	p_rec.element_det_rl,
	p_rec.currency_det_cd,
	p_rec.abr_attribute_category,
	p_rec.abr_attribute1,
	p_rec.abr_attribute2,
	p_rec.abr_attribute3,
	p_rec.abr_attribute4,
	p_rec.abr_attribute5,
	p_rec.abr_attribute6,
	p_rec.abr_attribute7,
	p_rec.abr_attribute8,
	p_rec.abr_attribute9,
	p_rec.abr_attribute10,
	p_rec.abr_attribute11,
	p_rec.abr_attribute12,
	p_rec.abr_attribute13,
	p_rec.abr_attribute14,
	p_rec.abr_attribute15,
	p_rec.abr_attribute16,
	p_rec.abr_attribute17,
	p_rec.abr_attribute18,
	p_rec.abr_attribute19,
	p_rec.abr_attribute20,
	p_rec.abr_attribute21,
	p_rec.abr_attribute22,
	p_rec.abr_attribute23,
	p_rec.abr_attribute24,
	p_rec.abr_attribute25,
	p_rec.abr_attribute26,
	p_rec.abr_attribute27,
	p_rec.abr_attribute28,
	p_rec.abr_attribute29,
	p_rec.abr_attribute30,
	p_rec.abr_seq_num,
	p_rec.object_version_number,
	l_created_by,
   	l_creation_date,
   	l_last_update_date,
   	l_last_updated_by,
   	l_last_update_login
  );
end if;


  --
  ben_abr_shd.g_api_dml := false;   -- Unset the api dml status
  hr_utility.set_location(' Leaving:'||l_proc, 15);
--
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    ben_abr_shd.g_api_dml := false;   -- Unset the api dml status
    ben_abr_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    ben_abr_shd.g_api_dml := false;   -- Unset the api dml status
    ben_abr_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    ben_abr_shd.g_api_dml := false;   -- Unset the api dml status
    Raise;
End dt_insert_dml;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< insert_dml >------------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_dml
	(p_rec 			 in out nocopy ben_abr_shd.g_rec_type,
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
	(p_rec  			in out nocopy ben_abr_shd.g_rec_type,
	 p_effective_date		in date,
	 p_datetrack_mode		in varchar2,
	 p_validation_start_date	in date,
	 p_validation_end_date		in date) is
--
  l_proc	varchar2(72) := g_package||'pre_insert';
--
  cursor c1 is
    select BEN_ACTY_BASE_RT_F_S.nextval
    from   sys.dual;
--
  cursor c_oipl is
     select opt_id, pl_id
     from ben_oipl_f
     where oipl_id = p_rec.oipl_id
     and   p_effective_date between effective_start_date and effective_end_date;
--
l_oipl c_oipl%rowtype;
--
  cursor c_plip is
     select pgm_id, pl_id
     from ben_plip_f
     where plip_id = p_rec.plip_id
     and   p_effective_date between effective_start_date and effective_end_date;
--
l_plip c_plip%rowtype;
--
  cursor c_oiplip is
     select plip.pgm_id, oipl.pl_id, oipl.opt_id
     from ben_oiplip_f oiplip, ben_oipl_f oipl, ben_plip_f plip
     where oiplip.oiplip_id = p_rec.oiplip_id
     and   oiplip.oipl_id = oipl.oipl_id
     and   oiplip.plip_id = plip.plip_id
     and   oipl.pl_id = plip.pl_id
     and   p_effective_date between oiplip.effective_start_date and oiplip.effective_end_date
     and   p_effective_date between plip.effective_start_date and plip.effective_end_date
     and   p_effective_date between oipl.effective_start_date and oipl.effective_end_date ;
--
l_oiplip c_oiplip%rowtype;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  open c1;
    --
    fetch c1 into p_rec.acty_base_rt_id;
    --
  close c1;
  --
  hr_utility.set_location(' p_rec.pgm_id :'||p_rec.pgm_id, 5);
  hr_utility.set_location(' p_rec.pl_id :'||p_rec.pl_id, 5);
  hr_utility.set_location(' p_rec.opt_id :'||p_rec.opt_id, 5);
  hr_utility.set_location(' p_rec.oipl_id :'||p_rec.oipl_id, 5);
  hr_utility.set_location(' p_rec.oiplip_id :'||p_rec.oiplip_id, 5);
  hr_utility.set_location(' p_rec.plip_id :'||p_rec.plip_id, 5);

  -- set the context ids before insert
  --
    	if p_rec.pgm_id is not null then
	   p_rec.context_pgm_id := p_rec.pgm_id ;
	end if;

  	if p_rec.pl_id is not null then
	   p_rec.context_pl_id := p_rec.pl_id ;
	end if;

  	if p_rec.opt_id is not null then
	   p_rec.context_opt_id := p_rec.opt_id ;
	end if;

	if p_rec.oipl_id is not null then
	   -- get opt_id and pl_id
	   open c_oipl;
	   fetch c_oipl into l_oipl ;
	   close c_oipl;
	   --
	   p_rec.context_opt_id := l_oipl.opt_id ;
	   p_rec.context_pl_id :=  l_oipl.pl_id;
	end if;

	if p_rec.oiplip_id is not null then
	   -- get opt_id, pgm_id and pl_id
	   open c_oiplip;
	   fetch c_oiplip into l_oiplip ;
	   close c_oiplip;
	   --
	   p_rec.context_opt_id := l_oiplip.opt_id ;
	   p_rec.context_pl_id := l_oiplip.pl_id ;
	   p_rec.context_pgm_id := l_oiplip.pgm_id ;
	end if;

  	if p_rec.plip_id is not null then
	   -- get pgm_id and pl_id
	   open c_plip;
	   fetch c_plip into l_plip ;
	   close c_plip;
	   --
	   p_rec.context_pl_id :=  l_plip.pl_id;
	   p_rec.context_pgm_id := l_plip.pgm_id ;
	end if;
  --
  hr_utility.set_location(' p_rec.context_pl_id :'||p_rec.context_pl_id, 5);
  hr_utility.set_location(' p_rec.context_pgm_id :'||p_rec.context_pgm_id, 5);
  hr_utility.set_location(' p_rec.context_opt_id :'||p_rec.context_opt_id, 5);
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
	(p_rec 			 in ben_abr_shd.g_rec_type,
	 p_effective_date	 in date,
	 p_datetrack_mode	 in varchar2,
	 p_validation_start_date in date,
	 p_validation_end_date	 in date) is
--
  l_proc	varchar2(72) := g_package||'post_insert';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);

  -- Added for GSP validations
  pqh_gsp_ben_validations.abr_validations
  	(  p_abr_id			=> p_rec.acty_base_rt_id
  	 , p_dml_operation 		=> 'I'
  	 , p_effective_date 		=> p_effective_date
  	 , p_business_group_id  	=> p_rec.business_group_id
  	 , p_pl_id			=> p_rec.pl_id
  	 , p_opt_id			=> p_rec.opt_id
  	 , p_acty_typ_cd		=> p_rec.acty_typ_cd
  	 , p_Acty_Base_RT_Stat_Cd	=> p_rec.Acty_Base_RT_Stat_Cd
  	 );

  --
  begin
   --
   ben_abr_rki.after_insert
   (
     p_acty_base_rt_id               => p_rec.acty_base_rt_id
    ,p_effective_start_date          => p_rec.effective_start_date
    ,p_effective_end_date            => p_rec.effective_end_date
    ,p_ordr_num			     => p_rec.ordr_num
    ,p_acty_typ_cd                   => p_rec.acty_typ_cd
    ,p_sub_acty_typ_cd               => p_rec.sub_acty_typ_cd
    ,p_name                          => p_rec.name
    ,p_rt_typ_cd                     => p_rec.rt_typ_cd
    ,p_bnft_rt_typ_cd                => p_rec.bnft_rt_typ_cd
    ,p_tx_typ_cd                     => p_rec.tx_typ_cd
    ,p_use_to_calc_net_flx_cr_flag   => p_rec.use_to_calc_net_flx_cr_flag
    ,p_asn_on_enrt_flag              => p_rec.asn_on_enrt_flag
    ,p_abv_mx_elcn_val_alwd_flag     => p_rec.abv_mx_elcn_val_alwd_flag
    ,p_blw_mn_elcn_alwd_flag         => p_rec.blw_mn_elcn_alwd_flag
    ,p_dsply_on_enrt_flag            => p_rec.dsply_on_enrt_flag
    ,p_parnt_chld_cd                 => p_rec.parnt_chld_cd
    ,p_use_calc_acty_bs_rt_flag      => p_rec.use_calc_acty_bs_rt_flag
    ,p_uses_ded_sched_flag           => p_rec.uses_ded_sched_flag
    ,p_uses_varbl_rt_flag            => p_rec.uses_varbl_rt_flag
    ,p_vstg_sched_apls_flag          => p_rec.vstg_sched_apls_flag
    ,p_rt_mlt_cd                     => p_rec.rt_mlt_cd
    ,p_proc_each_pp_dflt_flag        => p_rec.proc_each_pp_dflt_flag
    ,p_prdct_flx_cr_when_elig_flag   => p_rec.prdct_flx_cr_when_elig_flag
    ,p_no_std_rt_used_flag           => p_rec.no_std_rt_used_flag
    ,p_rcrrg_cd                      => p_rec.rcrrg_cd
    ,p_mn_elcn_val                   => p_rec.mn_elcn_val
    ,p_mx_elcn_val                   => p_rec.mx_elcn_val
    ,p_lwr_lmt_val                   => p_rec.lwr_lmt_val
    ,p_lwr_lmt_calc_rl               => p_rec.lwr_lmt_calc_rl
    ,p_upr_lmt_val                   => p_rec.upr_lmt_val
    ,p_upr_lmt_calc_rl               => p_rec.upr_lmt_calc_rl
    ,p_ptd_comp_lvl_fctr_id          => p_rec.ptd_comp_lvl_fctr_id
    ,p_clm_comp_lvl_fctr_id          => p_rec.clm_comp_lvl_fctr_id
    ,p_entr_ann_val_flag             => p_rec.entr_ann_val_flag
    ,p_ann_mn_elcn_val               => p_rec.ann_mn_elcn_val
    ,p_ann_mx_elcn_val               => p_rec.ann_mx_elcn_val
    ,p_wsh_rl_dy_mo_num              => p_rec.wsh_rl_dy_mo_num
    ,p_uses_pymt_sched_flag          => p_rec.uses_pymt_sched_flag
    ,p_nnmntry_uom                   => p_rec.nnmntry_uom
    ,p_val                           => p_rec.val
    ,p_incrmt_elcn_val               => p_rec.incrmt_elcn_val
    ,p_rndg_cd                       => p_rec.rndg_cd
    ,p_val_ovrid_alwd_flag           => p_rec.val_ovrid_alwd_flag
    ,p_prtl_mo_det_mthd_cd           => p_rec.prtl_mo_det_mthd_cd
    ,p_acty_base_rt_stat_cd          => p_rec.acty_base_rt_stat_cd
    ,p_procg_src_cd                  => p_rec.procg_src_cd
    ,p_dflt_val                      => p_rec.dflt_val
    ,p_dflt_flag                     => p_rec.dflt_flag
    ,p_frgn_erg_ded_typ_cd           => p_rec.frgn_erg_ded_typ_cd
    ,p_frgn_erg_ded_name             => p_rec.frgn_erg_ded_name
    ,p_frgn_erg_ded_ident            => p_rec.frgn_erg_ded_ident
    ,p_no_mx_elcn_val_dfnd_flag      => p_rec.no_mx_elcn_val_dfnd_flag
    ,p_prtl_mo_det_mthd_rl           => p_rec.prtl_mo_det_mthd_rl
    ,p_entr_val_at_enrt_flag         => p_rec.entr_val_at_enrt_flag
    ,p_prtl_mo_eff_dt_det_rl         => p_rec.prtl_mo_eff_dt_det_rl
    ,p_rndg_rl                       => p_rec.rndg_rl
    ,p_val_calc_rl                   => p_rec.val_calc_rl
    ,p_no_mn_elcn_val_dfnd_flag      => p_rec.no_mn_elcn_val_dfnd_flag
    ,p_prtl_mo_eff_dt_det_cd         => p_rec.prtl_mo_eff_dt_det_cd
    ,p_only_one_bal_typ_alwd_flag    => p_rec.only_one_bal_typ_alwd_flag
    ,p_rt_usg_cd                     => p_rec.rt_usg_cd
    ,p_prort_mn_ann_elcn_val_cd      => p_rec.prort_mn_ann_elcn_val_cd
    ,p_prort_mn_ann_elcn_val_rl      => p_rec.prort_mn_ann_elcn_val_rl
    ,p_prort_mx_ann_elcn_val_cd      => p_rec.prort_mx_ann_elcn_val_cd
    ,p_prort_mx_ann_elcn_val_rl      => p_rec.prort_mx_ann_elcn_val_rl
    ,p_one_ann_pymt_cd               => p_rec.one_ann_pymt_cd
    ,p_det_pl_ytd_cntrs_cd           => p_rec.det_pl_ytd_cntrs_cd
    ,p_asmt_to_use_cd                => p_rec.asmt_to_use_cd
    ,p_ele_rqd_flag                  => p_rec.ele_rqd_flag
    ,p_subj_to_imptd_incm_flag       => p_rec.subj_to_imptd_incm_flag
    ,p_element_type_id               => p_rec.element_type_id
    ,p_input_value_id                => p_rec.input_value_id
    ,p_input_va_calc_rl             => p_rec.input_va_calc_rl
    ,p_comp_lvl_fctr_id              => p_rec.comp_lvl_fctr_id
    ,p_parnt_acty_base_rt_id         => p_rec.parnt_acty_base_rt_id
    ,p_pgm_id                        => p_rec.pgm_id
    ,p_pl_id                         => p_rec.pl_id
    ,p_oipl_id                       => p_rec.oipl_id
    ,p_opt_id                        => p_rec.opt_id
    ,p_oiplip_id                     => p_rec.oiplip_id
    ,p_plip_id                       => p_rec.plip_id
    ,p_ptip_id                       => p_rec.ptip_id
    ,p_cmbn_plip_id                  => p_rec.cmbn_plip_id
    ,p_cmbn_ptip_id                  => p_rec.cmbn_ptip_id
    ,p_cmbn_ptip_opt_id              => p_rec.cmbn_ptip_opt_id
    ,p_vstg_for_acty_rt_id           => p_rec.vstg_for_acty_rt_id
    ,p_actl_prem_id                  => p_rec.actl_prem_id
    ,p_TTL_COMP_LVL_FCTR_ID          => p_rec.TTL_COMP_LVL_FCTR_ID
    ,p_COST_ALLOCATION_KEYFLEX_ID    => p_rec.COST_ALLOCATION_KEYFLEX_ID
    ,p_ALWS_CHG_CD                   => p_rec.ALWS_CHG_CD
    ,p_ele_entry_val_cd              => p_rec.ele_entry_val_cd
    ,p_pay_rate_grade_rule_id        => p_rec.pay_rate_grade_rule_id
    ,p_rate_periodization_cd         => p_rec.rate_periodization_cd
    ,p_rate_periodization_rl         => p_rec.rate_periodization_rl
    ,p_mn_mx_elcn_rl                 => p_rec.mn_mx_elcn_rl
    ,p_mapping_table_name            => p_rec.mapping_table_name
    ,p_mapping_table_pk_id           => p_rec.mapping_table_pk_id
    ,p_business_group_id             => p_rec.business_group_id
    ,p_context_pgm_id                => p_rec.context_pgm_id
    ,p_context_pl_id                => p_rec.context_pl_id
    ,p_context_opt_id                => p_rec.context_opt_id
    ,p_element_det_rl               => p_rec.element_det_rl
    ,p_currency_det_cd              => p_rec.currency_det_cd
    ,P_ABR_ATTRIBUTE_CATEGORY        => p_rec.ABR_ATTRIBUTE_CATEGORY
    ,P_ABR_ATTRIBUTE1                => p_rec.ABR_ATTRIBUTE1
    ,P_ABR_ATTRIBUTE2                => p_rec.ABR_ATTRIBUTE2
    ,P_ABR_ATTRIBUTE3                => p_rec.ABR_ATTRIBUTE3
    ,P_ABR_ATTRIBUTE4                => p_rec.ABR_ATTRIBUTE4
    ,P_ABR_ATTRIBUTE5                => p_rec.ABR_ATTRIBUTE5
    ,P_ABR_ATTRIBUTE6                => p_rec.ABR_ATTRIBUTE6
    ,P_ABR_ATTRIBUTE7                => p_rec.ABR_ATTRIBUTE7
    ,P_ABR_ATTRIBUTE8                => p_rec.ABR_ATTRIBUTE8
    ,P_ABR_ATTRIBUTE9                => p_rec.ABR_ATTRIBUTE9
    ,P_ABR_ATTRIBUTE10                => p_rec.ABR_ATTRIBUTE10
    ,P_ABR_ATTRIBUTE11                => p_rec.ABR_ATTRIBUTE11
    ,P_ABR_ATTRIBUTE12                => p_rec.ABR_ATTRIBUTE12
    ,P_ABR_ATTRIBUTE13                => p_rec.ABR_ATTRIBUTE13
    ,P_ABR_ATTRIBUTE14                => p_rec.ABR_ATTRIBUTE14
    ,P_ABR_ATTRIBUTE15                => p_rec.ABR_ATTRIBUTE15
    ,P_ABR_ATTRIBUTE16                => p_rec.ABR_ATTRIBUTE16
    ,P_ABR_ATTRIBUTE17                => p_rec.ABR_ATTRIBUTE17
    ,P_ABR_ATTRIBUTE18                => p_rec.ABR_ATTRIBUTE18
    ,P_ABR_ATTRIBUTE19                => p_rec.ABR_ATTRIBUTE19
    ,P_ABR_ATTRIBUTE20                => p_rec.ABR_ATTRIBUTE20
    ,P_ABR_ATTRIBUTE21                => p_rec.ABR_ATTRIBUTE21
    ,P_ABR_ATTRIBUTE22                => p_rec.ABR_ATTRIBUTE22
    ,P_ABR_ATTRIBUTE23                => p_rec.ABR_ATTRIBUTE23
    ,P_ABR_ATTRIBUTE24                => p_rec.ABR_ATTRIBUTE24
    ,P_ABR_ATTRIBUTE25                => p_rec.ABR_ATTRIBUTE25
    ,P_ABR_ATTRIBUTE26                => p_rec.ABR_ATTRIBUTE26
    ,P_ABR_ATTRIBUTE27                => p_rec.ABR_ATTRIBUTE27
    ,P_ABR_ATTRIBUTE28                => p_rec.ABR_ATTRIBUTE28
    ,P_ABR_ATTRIBUTE29                => p_rec.ABR_ATTRIBUTE29
    ,P_ABR_ATTRIBUTE30                => p_rec.ABR_ATTRIBUTE30
    ,P_ABR_SEQ_NUM                    => p_rec.abr_seq_num
    ,P_OBJECT_VERSION_NUMBER          => p_rec.OBJECT_VERSION_NUMBER
    ,p_effective_date               => p_effective_date
    ,p_validation_start_date        => p_validation_start_date
    ,p_validation_end_date          => p_validation_end_date
    );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'ben_acty_base_rt_f'
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
	 p_rec	 		 in  ben_abr_shd.g_rec_type,
	 p_validation_start_date out nocopy date,
	 p_validation_end_date	 out nocopy date) is
--
  l_proc		  varchar2(72) := g_package||'ins_lck';
  l_validation_start_date date;
  l_validation_end_date	  date;
  l_validation_start_date1 date;
  l_validation_end_date1   date;
  l_validation_start_date2 date;
  l_validation_end_date2   date;
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
	 p_base_table_name	   => 'ben_acty_base_rt_f',
	 p_base_key_column	   => 'acty_base_rt_id',
	 p_base_key_value 	   => p_rec.acty_base_rt_id,
	 p_parent_table_name1      => 'ff_formulas_f',
	 p_parent_key_column1      => 'formula_id',
	 p_parent_key_value1       => p_rec.prtl_mo_det_mthd_rl,
	 p_parent_table_name2      => 'ff_formulas_f',
	 p_parent_key_column2      => 'formula_id',
	 p_parent_key_value2       => p_rec.prtl_mo_eff_dt_det_rl,
	 p_parent_table_name3      => 'ff_formulas_f',
	 p_parent_key_column3      => 'formula_id',
	 p_parent_key_value3       => p_rec.rndg_rl,
	 p_parent_table_name4      => 'ff_formulas_f',
	 p_parent_key_column4      => 'formula_id',
	 p_parent_key_value4       => p_rec.val_calc_rl,
	 p_parent_table_name5      => 'ben_vstg_for_acty_rt_f',
	 p_parent_key_column5      => 'vstg_for_acty_rt_id',
	 p_parent_key_value5       => p_rec.vstg_for_acty_rt_id,
	 p_parent_table_name6      => 'ben_pgm_f',
	 p_parent_key_column6      => 'pgm_id',
	 p_parent_key_value6       => p_rec.pgm_id,
	 p_parent_table_name7      => 'ben_ptip_f',
	 p_parent_key_column7      => 'ptip_id',
	 p_parent_key_value7       => p_rec.ptip_id,
	 p_parent_table_name8      => 'ben_oipl_f',
	 p_parent_key_column8      => 'oipl_id',
	 p_parent_key_value8       => p_rec.oipl_id,
	 p_parent_table_name9       => 'ben_plip_f',
	 p_parent_key_column9       => 'plip_id',
	 p_parent_key_value9        => p_rec.plip_id,
         p_enforce_foreign_locking => true,
	 p_validation_start_date   => l_validation_start_date,
 	 p_validation_end_date	   => l_validation_end_date);
    --
    dt_api.validate_dt_mode
	(p_effective_date	   => p_effective_date,
	 p_datetrack_mode	   => p_datetrack_mode,
	 p_base_table_name	   => 'ben_acty_base_rt_f',
	 p_base_key_column	   => 'acty_base_rt_id',
	 p_base_key_value 	   => p_rec.acty_base_rt_id,
	 p_parent_table_name1      => 'ben_plip_f',
	 p_parent_key_column1      => 'plip_id',
	 p_parent_key_value1       => p_rec.plip_id,
	 p_parent_table_name2      => 'ben_pl_f',
	 p_parent_key_column2      => 'pl_id',
	 p_parent_key_value2       => p_rec.pl_id,
	 p_parent_table_name3      => 'ben_acty_base_rt_f',
	 p_parent_key_column3      => 'acty_base_rt_id',
	 p_parent_key_value3       => p_rec.parnt_acty_base_rt_id,
         p_parent_table_name4      => 'ben_oiplip_f',
         p_parent_key_column4      => 'oiplip_id',
         p_parent_key_value4       => p_rec.oiplip_id,
         p_parent_table_name5      => 'ben_actl_prem_f',
         p_parent_key_column5      => 'actl_prem_id',
         p_parent_key_value5       => p_rec.actl_prem_id,
         p_parent_table_name6      => 'ben_opt_f',
         p_parent_key_column6      => 'opt_id',
         p_parent_key_value6       => p_rec.opt_id,
         p_enforce_foreign_locking => true,
	 p_validation_start_date   => l_validation_start_date1,
 	 p_validation_end_date	   => l_validation_end_date1);
  --
  -- Set the validation start and end date OUT arguments
  --
  if l_validation_start_date > l_validation_start_date1 then
    --
    p_validation_start_date := l_validation_start_date;
  else
    --
    p_validation_start_date := l_validation_start_date1;
    --
  end if;
  --
  if l_validation_end_date > l_validation_end_date1 then
    --
    p_validation_end_date := l_validation_end_date;
  else
    --
    p_validation_end_date := l_validation_end_date1;
    --
  end if;
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
  p_rec		   in out nocopy ben_abr_shd.g_rec_type,
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
  ben_abr_bus.insert_validate
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

/*--Added for Bug 6881417
ben_abr_bus.g_ssben_call := false;*/

end ins;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (
  p_acty_base_rt_id              out nocopy number,
  p_effective_start_date         out nocopy date,
  p_effective_end_date           out nocopy date,
  p_ordr_num			 in number           default null,
  p_acty_typ_cd                  in varchar2         default null,
  p_sub_acty_typ_cd              in varchar2         default null,
  p_name                         in varchar2         default null,
  p_rt_typ_cd                    in varchar2         default null,
  p_bnft_rt_typ_cd               in varchar2         default null,
  p_tx_typ_cd                    in varchar2         default null,
  p_use_to_calc_net_flx_cr_flag  in varchar2,
  p_asn_on_enrt_flag             in varchar2,
  p_abv_mx_elcn_val_alwd_flag    in varchar2,
  p_blw_mn_elcn_alwd_flag        in varchar2,
  p_dsply_on_enrt_flag           in varchar2,
  p_parnt_chld_cd                in varchar2         default null,
  p_use_calc_acty_bs_rt_flag     in varchar2,
  p_uses_ded_sched_flag          in varchar2,
  p_uses_varbl_rt_flag           in varchar2,
  p_vstg_sched_apls_flag         in varchar2,
  p_rt_mlt_cd                    in varchar2         default null,
  p_proc_each_pp_dflt_flag       in varchar2,
  p_prdct_flx_cr_when_elig_flag  in varchar2,
  p_no_std_rt_used_flag          in varchar2,
  p_rcrrg_cd                     in varchar2         default null,
  p_mn_elcn_val                  in number           default null,
  p_mx_elcn_val                  in number           default null,
  p_lwr_lmt_val                  in number           default null,
  p_lwr_lmt_calc_rl              in number           default null,
  p_upr_lmt_val                  in number           default null,
  p_upr_lmt_calc_rl              in number           default null,
  p_ptd_comp_lvl_fctr_id         in number           default null,
  p_clm_comp_lvl_fctr_id         in number           default null,
  p_entr_ann_val_flag            in varchar2         default 'N',
  p_ann_mn_elcn_val              in number           default null,
  p_ann_mx_elcn_val              in number           default null,
  p_wsh_rl_dy_mo_num             in number           default null,
  p_uses_pymt_sched_flag         in varchar2,
  p_nnmntry_uom                  in varchar2         default null,
  p_val                          in number           default null,
  p_incrmt_elcn_val              in number           default null,
  p_rndg_cd                      in varchar2         default null,
  p_val_ovrid_alwd_flag          in varchar2,
  p_prtl_mo_det_mthd_cd          in varchar2         default null,
  p_acty_base_rt_stat_cd         in varchar2         default null,
  p_procg_src_cd                 in varchar2         default null,
  p_dflt_val                     in number           default null,
  p_dflt_flag                    in varchar2,
  p_frgn_erg_ded_typ_cd          in varchar2         default null,
  p_frgn_erg_ded_name            in varchar2         default null,
  p_frgn_erg_ded_ident           in varchar2         default null,
  p_no_mx_elcn_val_dfnd_flag     in varchar2,
  p_prtl_mo_det_mthd_rl          in number           default null,
  p_entr_val_at_enrt_flag        in varchar2,
  p_prtl_mo_eff_dt_det_rl        in number           default null,
  p_rndg_rl                      in number           default null,
  p_val_calc_rl                  in number           default null,
  p_no_mn_elcn_val_dfnd_flag     in varchar2,
  p_prtl_mo_eff_dt_det_cd        in varchar2         default null,
  p_only_one_bal_typ_alwd_flag   in varchar2,
  p_rt_usg_cd                    in varchar2         default null,
  p_prort_mn_ann_elcn_val_cd     in varchar2         default null,
  p_prort_mn_ann_elcn_val_rl     in number           default null,
  p_prort_mx_ann_elcn_val_cd     in varchar2         default null,
  p_prort_mx_ann_elcn_val_rl     in number           default null,
  p_one_ann_pymt_cd              in varchar2         default null,
  p_det_pl_ytd_cntrs_cd          in varchar2         default null,
  p_asmt_to_use_cd               in varchar2         default null,
  p_ele_rqd_flag                 in varchar2         default 'Y',
  p_subj_to_imptd_incm_flag      in varchar2         default 'N',
  p_element_type_id              in number           default null,
  p_input_value_id               in number           default null,
  p_input_va_calc_rl             in number           default null,
  p_comp_lvl_fctr_id             in number           default null,
  p_parnt_acty_base_rt_id        in number           default null,
  p_pgm_id                       in number           default null,
  p_pl_id                        in number           default null,
  p_oipl_id                      in number           default null,
  p_opt_id                       in number           default null,
  p_oiplip_id                    in number           default null,
  p_plip_id                      in number           default null,
  p_ptip_id                      in number           default null,
  p_cmbn_plip_id                 in number           default null,
  p_cmbn_ptip_id                 in number           default null,
  p_cmbn_ptip_opt_id             in number           default null,
  p_vstg_for_acty_rt_id          in number           default null,
  p_actl_prem_id                 in number           default null,
  p_TTL_COMP_LVL_FCTR_ID         in number           default null,
  p_COST_ALLOCATION_KEYFLEX_ID   in number           default null,
  p_ALWS_CHG_CD                  in varchar2         default null,
  p_ele_entry_val_cd             in varchar2         default null,
  p_pay_rate_grade_rule_id       in number           default null,
  p_rate_periodization_cd        in varchar2         default null,
  p_rate_periodization_rl        in number           default null,
  p_mn_mx_elcn_rl 		 in number           default null,
  p_mapping_table_name           in varchar2         default null,
  p_mapping_table_pk_id		 in number           default null,
  p_business_group_id            in number,
  p_context_pgm_id               in number           default null,
  p_context_pl_id                in number           default null,
  p_context_opt_id               in number           default null,
  p_element_det_rl               in number           default null,
  p_currency_det_cd              in varchar2         default null,
  p_abr_attribute_category       in varchar2         default null,
  p_abr_attribute1               in varchar2         default null,
  p_abr_attribute2               in varchar2         default null,
  p_abr_attribute3               in varchar2         default null,
  p_abr_attribute4               in varchar2         default null,
  p_abr_attribute5               in varchar2         default null,
  p_abr_attribute6               in varchar2         default null,
  p_abr_attribute7               in varchar2         default null,
  p_abr_attribute8               in varchar2         default null,
  p_abr_attribute9               in varchar2         default null,
  p_abr_attribute10              in varchar2         default null,
  p_abr_attribute11              in varchar2         default null,
  p_abr_attribute12              in varchar2         default null,
  p_abr_attribute13              in varchar2         default null,
  p_abr_attribute14              in varchar2         default null,
  p_abr_attribute15              in varchar2         default null,
  p_abr_attribute16              in varchar2         default null,
  p_abr_attribute17              in varchar2         default null,
  p_abr_attribute18              in varchar2         default null,
  p_abr_attribute19              in varchar2         default null,
  p_abr_attribute20              in varchar2         default null,
  p_abr_attribute21              in varchar2         default null,
  p_abr_attribute22              in varchar2         default null,
  p_abr_attribute23              in varchar2         default null,
  p_abr_attribute24              in varchar2         default null,
  p_abr_attribute25              in varchar2         default null,
  p_abr_attribute26              in varchar2         default null,
  p_abr_attribute27              in varchar2         default null,
  p_abr_attribute28              in varchar2         default null,
  p_abr_attribute29              in varchar2         default null,
  p_abr_attribute30              in varchar2         default null,
  p_abr_seq_num                  in  number          default null,
  p_object_version_number        out nocopy number,
  p_effective_date               in date
  ) is
--
  l_rec		ben_abr_shd.g_rec_type;
  l_proc	varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  hr_utility.set_location('total rate before conv in ins '||p_TTL_COMP_LVL_FCTR_ID, 99);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  ben_abr_shd.convert_args
  (
        null
       ,null
       ,null
       ,p_ordr_num
       ,p_acty_typ_cd
       ,p_sub_acty_typ_cd
       ,p_name
       ,p_rt_typ_cd
       ,p_bnft_rt_typ_cd
       ,p_tx_typ_cd
       ,p_use_to_calc_net_flx_cr_flag
       ,p_asn_on_enrt_flag
       ,p_abv_mx_elcn_val_alwd_flag
       ,p_blw_mn_elcn_alwd_flag
       ,p_dsply_on_enrt_flag
       ,p_parnt_chld_cd
       ,p_use_calc_acty_bs_rt_flag
       ,p_uses_ded_sched_flag
       ,p_uses_varbl_rt_flag
       ,p_vstg_sched_apls_flag
       ,p_rt_mlt_cd
       ,p_proc_each_pp_dflt_flag
       ,p_prdct_flx_cr_when_elig_flag
       ,p_no_std_rt_used_flag
       ,p_rcrrg_cd
       ,p_mn_elcn_val
       ,p_mx_elcn_val
       ,p_lwr_lmt_val
       ,p_lwr_lmt_calc_rl
       ,p_upr_lmt_val
       ,p_upr_lmt_calc_rl
       ,p_ptd_comp_lvl_fctr_id
       ,p_clm_comp_lvl_fctr_id
       ,p_entr_ann_val_flag
       ,p_ann_mn_elcn_val
       ,p_ann_mx_elcn_val
       ,p_wsh_rl_dy_mo_num
       ,p_uses_pymt_sched_flag
       ,p_nnmntry_uom
       ,p_val
       ,p_incrmt_elcn_val
       ,p_rndg_cd
       ,p_val_ovrid_alwd_flag
       ,p_prtl_mo_det_mthd_cd
       ,p_acty_base_rt_stat_cd
       ,p_procg_src_cd
       ,p_dflt_val
       ,p_dflt_flag
       ,p_frgn_erg_ded_typ_cd
       ,p_frgn_erg_ded_name
       ,p_frgn_erg_ded_ident
       ,p_no_mx_elcn_val_dfnd_flag
       ,p_prtl_mo_det_mthd_rl
       ,p_entr_val_at_enrt_flag
       ,p_prtl_mo_eff_dt_det_rl
       ,p_rndg_rl
       ,p_val_calc_rl
       ,p_no_mn_elcn_val_dfnd_flag
       ,p_prtl_mo_eff_dt_det_cd
       ,p_only_one_bal_typ_alwd_flag
       ,p_rt_usg_cd
       ,p_prort_mn_ann_elcn_val_cd
       ,p_prort_mn_ann_elcn_val_rl
       ,p_prort_mx_ann_elcn_val_cd
       ,p_prort_mx_ann_elcn_val_rl
       ,p_one_ann_pymt_cd
       ,p_det_pl_ytd_cntrs_cd
       ,p_asmt_to_use_cd
       ,p_ele_rqd_flag
       ,p_subj_to_imptd_incm_flag
       ,p_element_type_id
       ,p_input_value_id
       ,p_input_va_calc_rl
       ,p_comp_lvl_fctr_id
       ,p_parnt_acty_base_rt_id
       ,p_pgm_id
       ,p_pl_id
       ,p_oipl_id
       ,p_opt_id
       ,p_oiplip_id
       ,p_plip_id
       ,p_ptip_id
       ,p_cmbn_plip_id
       ,p_cmbn_ptip_id
       ,p_cmbn_ptip_opt_id
       ,p_vstg_for_acty_rt_id
       ,p_actl_prem_id
       ,p_TTL_COMP_LVL_FCTR_ID
       ,p_COST_ALLOCATION_KEYFLEX_ID
       ,p_ALWS_CHG_CD
       ,p_ele_entry_val_cd
       ,p_pay_rate_grade_rule_id
       ,p_rate_periodization_cd
       ,p_rate_periodization_rl
       ,p_mn_mx_elcn_rl
       ,p_mapping_table_name
       ,p_mapping_table_pk_id
       ,p_business_group_id
       ,p_context_pgm_id
       ,p_context_pl_id
       ,p_context_opt_id
       ,p_element_det_rl
       ,p_currency_det_cd
       ,p_abr_attribute_category
       ,p_abr_attribute1
       ,p_abr_attribute2
       ,p_abr_attribute3
       ,p_abr_attribute4
       ,p_abr_attribute5
       ,p_abr_attribute6
       ,p_abr_attribute7
       ,p_abr_attribute8
       ,p_abr_attribute9
       ,p_abr_attribute10
       ,p_abr_attribute11
       ,p_abr_attribute12
       ,p_abr_attribute13
       ,p_abr_attribute14
       ,p_abr_attribute15
       ,p_abr_attribute16
       ,p_abr_attribute17
       ,p_abr_attribute18
       ,p_abr_attribute19
       ,p_abr_attribute20
       ,p_abr_attribute21
       ,p_abr_attribute22
       ,p_abr_attribute23
       ,p_abr_attribute24
       ,p_abr_attribute25
       ,p_abr_attribute26
       ,p_abr_attribute27
       ,p_abr_attribute28
       ,p_abr_attribute29
       ,p_abr_attribute30
       ,p_abr_seq_num
       ,null
  );
  --
  -- Having converted the arguments into the ben_abr_rec
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  ins(l_rec, p_effective_date);
  --
  -- Set the OUT arguments.
  --
  p_acty_base_rt_id        	:= l_rec.acty_base_rt_id;
  p_effective_start_date  	:= l_rec.effective_start_date;
  p_effective_end_date    	:= l_rec.effective_end_date;
  p_object_version_number 	:= l_rec.object_version_number;
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End ins;
--
end ben_abr_ins;

/
