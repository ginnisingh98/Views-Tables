--------------------------------------------------------
--  DDL for Package Body BEN_ABR_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_ABR_UPD" as
/* $Header: beabrrhi.pkb 120.18 2008/05/15 10:36:51 krupani ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_abr_upd.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |----------------------------< dt_update_dml >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure controls the execution of dml from the datetrack mode
--   of CORRECTION only. It is important to note that the object version
--   number is only increment by 1 because the datetrack correction is
--   soley for one datetracked row.
--   This procedure controls the actual dml update logic. The functions of this
--   procedure are as follows:
--   1) Get the next object_version_number.
--   2) To set and unset the g_api_dml status as required (as we are about to
--      perform dml).
--   3) To update the specified row in the schema using the primary key in
--      the predicates.
--   4) To trap any constraint violations that may have occurred.
--   5) To raise any other errors.
--
-- Prerequisites:
--   This is an internal private procedure which must be called from the
--   update_dml procedure.
--
-- In Parameters:
--   A Pl/Sql record structre.
--
-- Post Success:
--   The specified row will be updated in the schema.
--
-- Post Failure:
--   On the update dml failure it is important to note that we always reset the
--   g_api_dml status to false.
--   If a check or unique integrity constraint violation is raised the
--   constraint_error procedure will be called.
--   If any other error is reported, the error will be raised after the
--   g_api_dml status is reset.
--
-- Developer Implementation Notes:
--   The update 'set' arguments list should be modified if any of your
--   attributes are not updateable.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure dt_update_dml
	(p_rec 			 in out nocopy ben_abr_shd.g_rec_type,
	 p_effective_date	 in	date,
	 p_datetrack_mode	 in	varchar2,
	 p_validation_start_date in	date,
	 p_validation_end_date	 in	date) is
--
  l_proc	varchar2(72) := g_package||'dt_update_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (p_datetrack_mode = 'CORRECTION') then
    hr_utility.set_location(l_proc, 10);
    --
    -- Because we are updating a row we must get the next object
    -- version number.
    --
    p_rec.object_version_number :=
      dt_api.get_object_version_number
	  (p_base_table_name	=> 'ben_acty_base_rt_f',
	   p_base_key_column	=> 'acty_base_rt_id',
	   p_base_key_value	=> p_rec.acty_base_rt_id);
    --
    ben_abr_shd.g_api_dml := true;  -- Set the api dml status
    --
    -- Update the ben_acty_base_rt_f Row
    --
    update  ben_acty_base_rt_f
    set
    acty_base_rt_id                 = p_rec.acty_base_rt_id,
    ordr_num			    = p_rec.ordr_num,
    acty_typ_cd                     = p_rec.acty_typ_cd,
    sub_acty_typ_cd                 = p_rec.sub_acty_typ_cd,
    element_type_id                 = p_rec.element_type_id,
    input_value_id                  = p_rec.input_value_id,
    input_va_calc_rl               = p_rec.input_va_calc_rl,
    comp_lvl_fctr_id                = p_rec.comp_lvl_fctr_id,
    parnt_acty_base_rt_id           = p_rec.parnt_acty_base_rt_id,
    pgm_id                          = p_rec.pgm_id,
    pl_id                           = p_rec.pl_id,
    oipl_id                         = p_rec.oipl_id,
    opt_id                          = p_rec.opt_id,
    oiplip_id                       = p_rec.oiplip_id,
    plip_id                         = p_rec.plip_id,
    ptip_id                         = p_rec.ptip_id,
    cmbn_ptip_opt_id                = p_rec.cmbn_ptip_opt_id,
    vstg_for_acty_rt_id             = p_rec.vstg_for_acty_rt_id,
    actl_prem_id                    = p_rec.actl_prem_id,
    ALWS_CHG_CD                     = p_rec.ALWS_CHG_CD,
    ele_entry_val_cd                = p_rec.ele_entry_val_cd,
    TTL_COMP_LVL_FCTR_ID            = p_rec.TTL_COMP_LVL_FCTR_ID,
    COST_ALLOCATION_KEYFLEX_ID      = p_rec.COST_ALLOCATION_KEYFLEX_ID,
    rt_typ_cd                       = p_rec.rt_typ_cd,
    bnft_rt_typ_cd                  = p_rec.bnft_rt_typ_cd,
    tx_typ_cd                       = p_rec.tx_typ_cd,
    use_to_calc_net_flx_cr_flag     = p_rec.use_to_calc_net_flx_cr_flag,
    asn_on_enrt_flag                = p_rec.asn_on_enrt_flag,
    abv_mx_elcn_val_alwd_flag       = p_rec.abv_mx_elcn_val_alwd_flag,
    blw_mn_elcn_alwd_flag           = p_rec.blw_mn_elcn_alwd_flag,
    dsply_on_enrt_flag              = p_rec.dsply_on_enrt_flag,
    parnt_chld_cd                   = p_rec.parnt_chld_cd,
    use_calc_acty_bs_rt_flag        = p_rec.use_calc_acty_bs_rt_flag,
    uses_ded_sched_flag             = p_rec.uses_ded_sched_flag,
    uses_varbl_rt_flag              = p_rec.uses_varbl_rt_flag,
    vstg_sched_apls_flag            = p_rec.vstg_sched_apls_flag,
    rt_mlt_cd                       = p_rec.rt_mlt_cd,
    proc_each_pp_dflt_flag          = p_rec.proc_each_pp_dflt_flag,
    prdct_flx_cr_when_elig_flag     = p_rec.prdct_flx_cr_when_elig_flag,
    no_std_rt_used_flag             = p_rec.no_std_rt_used_flag,
    rcrrg_cd                        = p_rec.rcrrg_cd,
    mn_elcn_val                     = p_rec.mn_elcn_val,
    mx_elcn_val                     = p_rec.mx_elcn_val,
    lwr_lmt_val                     = p_rec.lwr_lmt_val,
    lwr_lmt_calc_rl                 = p_rec.lwr_lmt_calc_rl,
    upr_lmt_val                     = p_rec.upr_lmt_val,
    upr_lmt_calc_rl                 = p_rec.upr_lmt_calc_rl,
    ptd_comp_lvl_fctr_id            = p_rec.ptd_comp_lvl_fctr_id,
    clm_comp_lvl_fctr_id            = p_rec.clm_comp_lvl_fctr_id,
    entr_ann_val_flag               = p_rec.entr_ann_val_flag,
    ann_mn_elcn_val                 = p_rec.ann_mn_elcn_val,
    ann_mx_elcn_val                 = p_rec.ann_mx_elcn_val,
    wsh_rl_dy_mo_num                = p_rec.wsh_rl_dy_mo_num,
    uses_pymt_sched_flag            = p_rec.uses_pymt_sched_flag,
    nnmntry_uom                     = p_rec.nnmntry_uom,
    val                             = p_rec.val,
    incrmt_elcn_val                 = p_rec.incrmt_elcn_val,
    rndg_cd                         = p_rec.rndg_cd,
    val_ovrid_alwd_flag             = p_rec.val_ovrid_alwd_flag,
    prtl_mo_det_mthd_cd             = p_rec.prtl_mo_det_mthd_cd,
    acty_base_rt_stat_cd            = p_rec.acty_base_rt_stat_cd,
    procg_src_cd                    = p_rec.procg_src_cd,
    dflt_val                        = p_rec.dflt_val,
    dflt_flag                       = p_rec.dflt_flag,
    frgn_erg_ded_typ_cd             = p_rec.frgn_erg_ded_typ_cd,
    frgn_erg_ded_name               = p_rec.frgn_erg_ded_name,
    frgn_erg_ded_ident              = p_rec.frgn_erg_ded_ident,
    no_mx_elcn_val_dfnd_flag        = p_rec.no_mx_elcn_val_dfnd_flag,
    cmbn_plip_id                    = p_rec.cmbn_plip_id,
    cmbn_ptip_id                    = p_rec.cmbn_ptip_id,
    prtl_mo_det_mthd_rl             = p_rec.prtl_mo_det_mthd_rl,
    entr_val_at_enrt_flag           = p_rec.entr_val_at_enrt_flag,
    prtl_mo_eff_dt_det_rl           = p_rec.prtl_mo_eff_dt_det_rl,
    rndg_rl                         = p_rec.rndg_rl,
    val_calc_rl                     = p_rec.val_calc_rl,
    no_mn_elcn_val_dfnd_flag        = p_rec.no_mn_elcn_val_dfnd_flag,
    prtl_mo_eff_dt_det_cd           = p_rec.prtl_mo_eff_dt_det_cd,
    pay_rate_grade_rule_id          = p_rec.pay_rate_grade_rule_id ,
    rate_periodization_cd           = p_rec.rate_periodization_cd,
    rate_periodization_rl           = p_rec.rate_periodization_rl,
    business_group_id               = p_rec.business_group_id,
    only_one_bal_typ_alwd_flag      = p_rec.only_one_bal_typ_alwd_flag,
    rt_usg_cd                       = p_rec.rt_usg_cd,
    prort_mn_ann_elcn_val_cd        = p_rec.prort_mn_ann_elcn_val_cd,
    prort_mn_ann_elcn_val_rl        = p_rec.prort_mn_ann_elcn_val_rl,
    prort_mx_ann_elcn_val_cd        = p_rec.prort_mx_ann_elcn_val_cd,
    prort_mx_ann_elcn_val_rl        = p_rec.prort_mx_ann_elcn_val_rl,
    one_ann_pymt_cd                 = p_rec.one_ann_pymt_cd,
    det_pl_ytd_cntrs_cd             = p_rec.det_pl_ytd_cntrs_cd,
    asmt_to_use_cd                  = p_rec.asmt_to_use_cd,
    ele_rqd_flag                    = p_rec.ele_rqd_flag,
    subj_to_imptd_incm_flag         = p_rec.subj_to_imptd_incm_flag,
    name                            = p_rec.name,
    mn_mx_elcn_rl		    = p_rec.mn_mx_elcn_rl,
    mapping_table_name              = p_rec.mapping_table_name,
    mapping_table_pk_id             = p_rec.mapping_table_pk_id,
    context_pgm_id                  = p_rec.context_pgm_id,
    context_pl_id                   = p_rec.context_pl_id,
    context_opt_id                  = p_rec.context_opt_id,
    element_det_rl                  = p_rec.element_det_rl,
    currency_det_cd                 = p_rec.currency_det_cd ,
    abr_attribute_category          = p_rec.abr_attribute_category,
    abr_attribute1                  = p_rec.abr_attribute1,
    abr_attribute2                  = p_rec.abr_attribute2,
    abr_attribute3                  = p_rec.abr_attribute3,
    abr_attribute4                  = p_rec.abr_attribute4,
    abr_attribute5                  = p_rec.abr_attribute5,
    abr_attribute6                  = p_rec.abr_attribute6,
    abr_attribute7                  = p_rec.abr_attribute7,
    abr_attribute8                  = p_rec.abr_attribute8,
    abr_attribute9                  = p_rec.abr_attribute9,
    abr_attribute10                 = p_rec.abr_attribute10,
    abr_attribute11                 = p_rec.abr_attribute11,
    abr_attribute12                 = p_rec.abr_attribute12,
    abr_attribute13                 = p_rec.abr_attribute13,
    abr_attribute14                 = p_rec.abr_attribute14,
    abr_attribute15                 = p_rec.abr_attribute15,
    abr_attribute16                 = p_rec.abr_attribute16,
    abr_attribute17                 = p_rec.abr_attribute17,
    abr_attribute18                 = p_rec.abr_attribute18,
    abr_attribute19                 = p_rec.abr_attribute19,
    abr_attribute20                 = p_rec.abr_attribute20,
    abr_attribute21                 = p_rec.abr_attribute21,
    abr_attribute22                 = p_rec.abr_attribute22,
    abr_attribute23                 = p_rec.abr_attribute23,
    abr_attribute24                 = p_rec.abr_attribute24,
    abr_attribute25                 = p_rec.abr_attribute25,
    abr_attribute26                 = p_rec.abr_attribute26,
    abr_attribute27                 = p_rec.abr_attribute27,
    abr_attribute28                 = p_rec.abr_attribute28,
    abr_attribute29                 = p_rec.abr_attribute29,
    abr_attribute30                 = p_rec.abr_attribute30,
    abr_seq_num                     = p_rec.abr_seq_num,
    object_version_number           = p_rec.object_version_number
    where   acty_base_rt_id = p_rec.acty_base_rt_id
    and     effective_start_date = p_validation_start_date
    and     effective_end_date   = p_validation_end_date;
    --
    ben_abr_shd.g_api_dml := false;   -- Unset the api dml status
    --
    -- Set the effective start and end dates
    --
    p_rec.effective_start_date := p_validation_start_date;
    p_rec.effective_end_date   := p_validation_end_date;
  End If;
--
hr_utility.set_location(' Leaving:'||l_proc, 15);
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
End dt_update_dml;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< update_dml >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure calls the dt_update_dml control logic which handles
--   the actual datetrack dml.
--
-- Prerequisites:
--   This is an internal private procedure which must be called from the upd
--   procedure.
--
-- In Parameters:
--   A Pl/Sql record structre.
--
-- Post Success:
--   Processing contines.
--
-- Post Failure:
--   No specific error handling is required within this procedure.
--
-- Developer Implementation Notes:
--   The update 'set' arguments list should be modified if any of your
--   attributes are not updateable.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure update_dml
	(p_rec 			 in out nocopy ben_abr_shd.g_rec_type,
	 p_effective_date	 in	date,
	 p_datetrack_mode	 in	varchar2,
	 p_validation_start_date in	date,
	 p_validation_end_date	 in	date) is
--
  l_proc	varchar2(72) := g_package||'update_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  dt_update_dml(p_rec			=> p_rec,
		p_effective_date	=> p_effective_date,
		p_datetrack_mode	=> p_datetrack_mode,
       		p_validation_start_date	=> p_validation_start_date,
		p_validation_end_date	=> p_validation_end_date);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_dml;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< dt_pre_update >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   The dt_pre_update procedure controls the execution
--   of dml for the datetrack modes of: UPDATE, UPDATE_OVERRIDE
--   and UPDATE_CHANGE_INSERT only. The execution required is as
--   follows:
--
--   1) Providing the datetrack update mode is not 'CORRECTION'
--      then set the effective end date of the current row (this
--      will be the validation_start_date - 1).
--   2) If the datetrack mode is 'UPDATE_OVERRIDE' then call the
--      corresponding delete_dml process to delete any future rows
--      where the effective_start_date is greater than or equal to
--	the validation_start_date.
--   3) Call the insert_dml process to insert the new updated row
--      details..
--
-- Prerequisites:
--   This is an internal procedure which is called from the
--   pre_update procedure.
--
-- In Parameters:
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   If an error has occurred, an error message and exception will be raised
--   but not handled.
--
-- Developer Implementation Notes:
--   This is an internal procedure which is required by Datetrack. Don't
--   remove or modify.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure dt_pre_update
	(p_rec 			 in out nocopy ben_abr_shd.g_rec_type,
	 p_effective_date	 in	date,
	 p_datetrack_mode	 in	varchar2,
	 p_validation_start_date in	date,
	 p_validation_end_date	 in	date) is
--
  l_proc	         varchar2(72) := g_package||'dt_pre_update';
  l_dummy_version_number number;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  If (p_datetrack_mode <> 'CORRECTION') then
    hr_utility.set_location(l_proc, 10);
    --
    -- Update the current effective end date
    --
    ben_abr_shd.upd_effective_end_date
     (p_effective_date	       => p_effective_date,
      p_base_key_value	       => p_rec.acty_base_rt_id,
      p_new_effective_end_date => (p_validation_start_date - 1),
      p_validation_start_date  => p_validation_start_date,
      p_validation_end_date    => p_validation_end_date,
      p_object_version_number  => l_dummy_version_number);
    --
    If (p_datetrack_mode = 'UPDATE_OVERRIDE') then
      hr_utility.set_location(l_proc, 15);
      --
      -- As the datetrack mode is 'UPDATE_OVERRIDE' then we must
      -- delete any future rows
      --
      ben_abr_del.delete_dml
        (p_rec			 => p_rec,
	 p_effective_date	 => p_effective_date,
	 p_datetrack_mode	 => p_datetrack_mode,
	 p_validation_start_date => p_validation_start_date,
	 p_validation_end_date   => p_validation_end_date);
    End If;
    hr_utility.set_location(l_proc, 20);
    --
    -- We must now insert the updated row
    --
    ben_abr_ins.insert_dml
      (p_rec			=> p_rec,
       p_effective_date		=> p_effective_date,
       p_datetrack_mode		=> p_datetrack_mode,
       p_validation_start_date	=> p_validation_start_date,
       p_validation_end_date	=> p_validation_end_date);
  End If;
  hr_utility.set_location(' Leaving:'||l_proc, 20);
End dt_pre_update;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< pre_update >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This private procedure contains any processing which is required before
--   the update dml.
--
-- Prerequisites:
--   This is an internal procedure which is called from the upd procedure.
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
--   Any pre-processing required before the update dml is issued should be
--   coded within this procedure. It is important to note that any 3rd party
--   maintenance should be reviewed before placing in this procedure. The call
--   to the dt_update_dml procedure should NOT be removed.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure pre_update
	(p_rec 			 in out nocopy ben_abr_shd.g_rec_type,
	 p_effective_date	 in	date,
	 p_datetrack_mode	 in	varchar2,
	 p_validation_start_date in	date,
	 p_validation_end_date	 in	date) is
--
  l_proc	varchar2(72) := g_package||'pre_update';
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
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- set the context ids before update
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
  --
  dt_pre_update
    (p_rec 		     => p_rec,
     p_effective_date	     => p_effective_date,
     p_datetrack_mode	     => p_datetrack_mode,
     p_validation_start_date => p_validation_start_date,
     p_validation_end_date   => p_validation_end_date);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End pre_update;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< post_update >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This private procedure contains any processing which is required after the
--   update dml.
--
-- Prerequisites:
--   This is an internal procedure which is called from the upd procedure.
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
--   Any post-processing required after the update dml is issued should be
--   coded within this procedure. It is important to note that any 3rd party
--   maintenance should be reviewed before placing in this procedure.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure post_update
	(p_rec 			 in ben_abr_shd.g_rec_type,
	 p_effective_date	 in date,
	 p_datetrack_mode	 in varchar2,
	 p_validation_start_date in date,
	 p_validation_end_date	 in date) is
--
  l_proc	varchar2(72) := g_package||'post_update';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Added for GSP validations
  pqh_gsp_ben_validations.abr_validations
  	(  p_abr_id			=> p_rec.acty_base_rt_id
  	 , p_dml_operation 		=> 'U'
  	 , p_effective_date 		=> p_effective_date
  	 , p_business_group_id  	=> p_rec.business_group_id
  	 , p_pl_id			=> p_rec.pl_id
  	 , p_opt_id			=> p_rec.opt_id
  	 , p_acty_typ_cd		=> p_rec.acty_typ_cd
  	 , p_Acty_Base_RT_Stat_Cd	=> p_rec.Acty_Base_RT_Stat_Cd
  	 );

  begin
   --
   ben_abr_rku.after_update
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
    ,p_ALWS_CHG_CD                   => p_rec.ALWS_CHG_CD
    ,p_ele_entry_val_cd              => p_rec.ele_entry_val_cd
    ,p_TTL_COMP_LVL_FCTR_ID          => p_rec.TTL_COMP_LVL_FCTR_ID
    ,p_COST_ALLOCATION_KEYFLEX_ID    => p_rec.COST_ALLOCATION_KEYFLEX_ID
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
    ,p_element_det_rl                => p_rec.element_det_rl
    ,p_currency_det_cd               => p_rec.currency_det_cd
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
    ,P_ABR_SEQ_NUM                    => p_rec.ABR_SEQ_NUM
    ,P_OBJECT_VERSION_NUMBER          => p_rec.OBJECT_VERSION_NUMBER
    ,P_effective_date                 => p_effective_date
    ,P_datetrack_mode                 => p_datetrack_mode
    ,P_validation_start_date          => p_validation_start_date
    ,P_validation_end_date            => p_validation_end_date
    ,p_effective_start_date_o        => ben_abr_shd.g_old_rec.effective_start_date
    ,p_effective_end_date_o          => ben_abr_shd.g_old_rec.effective_end_date
    ,p_ordr_num_o	 	     => ben_abr_shd.g_old_rec.ordr_num
    ,p_acty_typ_cd_o                 => ben_abr_shd.g_old_rec.acty_typ_cd
    ,p_sub_acty_typ_cd_o             => ben_abr_shd.g_old_rec.sub_acty_typ_cd
    ,p_name_o                        => ben_abr_shd.g_old_rec.name
    ,p_rt_typ_cd_o                   => ben_abr_shd.g_old_rec.rt_typ_cd
    ,p_bnft_rt_typ_cd_o              => ben_abr_shd.g_old_rec.bnft_rt_typ_cd
    ,p_tx_typ_cd_o                   => ben_abr_shd.g_old_rec.tx_typ_cd
    ,p_use_to_calc_net_flx_cr_fla_o  => ben_abr_shd.g_old_rec.use_to_calc_net_flx_cr_flag
    ,p_asn_on_enrt_flag_o            => ben_abr_shd.g_old_rec.asn_on_enrt_flag
    ,p_abv_mx_elcn_val_alwd_flag_o   => ben_abr_shd.g_old_rec.abv_mx_elcn_val_alwd_flag
    ,p_blw_mn_elcn_alwd_flag_o       => ben_abr_shd.g_old_rec.blw_mn_elcn_alwd_flag
    ,p_dsply_on_enrt_flag_o          => ben_abr_shd.g_old_rec.dsply_on_enrt_flag
    ,p_parnt_chld_cd_o               => ben_abr_shd.g_old_rec.parnt_chld_cd
    ,p_use_calc_acty_bs_rt_flag_o    => ben_abr_shd.g_old_rec.use_calc_acty_bs_rt_flag
    ,p_uses_ded_sched_flag_o         => ben_abr_shd.g_old_rec.uses_ded_sched_flag
    ,p_uses_varbl_rt_flag_o          => ben_abr_shd.g_old_rec.uses_varbl_rt_flag
    ,p_vstg_sched_apls_flag_o        => ben_abr_shd.g_old_rec.vstg_sched_apls_flag
    ,p_rt_mlt_cd_o                   => ben_abr_shd.g_old_rec.rt_mlt_cd
    ,p_proc_each_pp_dflt_flag_o      => ben_abr_shd.g_old_rec.proc_each_pp_dflt_flag
    ,p_prdct_flx_cr_when_elig_fla_o  => ben_abr_shd.g_old_rec.prdct_flx_cr_when_elig_flag
    ,p_no_std_rt_used_flag_o         => ben_abr_shd.g_old_rec.no_std_rt_used_flag
    ,p_rcrrg_cd_o                    => ben_abr_shd.g_old_rec.rcrrg_cd
    ,p_mn_elcn_val_o                 => ben_abr_shd.g_old_rec.mn_elcn_val
    ,p_mx_elcn_val_o                 => ben_abr_shd.g_old_rec.mx_elcn_val
    ,p_lwr_lmt_val_o                 => ben_abr_shd.g_old_rec.lwr_lmt_val
    ,p_lwr_lmt_calc_rl_o             => ben_abr_shd.g_old_rec.lwr_lmt_calc_rl
    ,p_upr_lmt_val_o                 => ben_abr_shd.g_old_rec.upr_lmt_val
    ,p_upr_lmt_calc_rl_o             => ben_abr_shd.g_old_rec.upr_lmt_calc_rl
    ,p_ptd_comp_lvl_fctr_id_o        => ben_abr_shd.g_old_rec.ptd_comp_lvl_fctr_id
    ,p_clm_comp_lvl_fctr_id_o        => ben_abr_shd.g_old_rec.clm_comp_lvl_fctr_id
    ,p_entr_ann_val_flag_o           => ben_abr_shd.g_old_rec.entr_ann_val_flag
    ,p_ann_mn_elcn_val_o             => ben_abr_shd.g_old_rec.ann_mn_elcn_val
    ,p_ann_mx_elcn_val_o             => ben_abr_shd.g_old_rec.ann_mx_elcn_val
    ,p_wsh_rl_dy_mo_num_o            => ben_abr_shd.g_old_rec.wsh_rl_dy_mo_num
    ,p_uses_pymt_sched_flag_o        => ben_abr_shd.g_old_rec.uses_pymt_sched_flag
    ,p_nnmntry_uom_o                 => ben_abr_shd.g_old_rec.nnmntry_uom
    ,p_val_o                         => ben_abr_shd.g_old_rec.val
    ,p_incrmt_elcn_val_o             => ben_abr_shd.g_old_rec.incrmt_elcn_val
    ,p_rndg_cd_o                     => ben_abr_shd.g_old_rec.rndg_cd
    ,p_val_ovrid_alwd_flag_o         => ben_abr_shd.g_old_rec.val_ovrid_alwd_flag
    ,p_prtl_mo_det_mthd_cd_o         => ben_abr_shd.g_old_rec.prtl_mo_det_mthd_cd
    ,p_acty_base_rt_stat_cd_o        => ben_abr_shd.g_old_rec.acty_base_rt_stat_cd
    ,p_procg_src_cd_o                => ben_abr_shd.g_old_rec.procg_src_cd
    ,p_dflt_val_o                    => ben_abr_shd.g_old_rec.dflt_val
    ,p_dflt_flag_o                   => ben_abr_shd.g_old_rec.dflt_flag
    ,p_frgn_erg_ded_typ_cd_o         => ben_abr_shd.g_old_rec.frgn_erg_ded_typ_cd
    ,p_frgn_erg_ded_name_o           => ben_abr_shd.g_old_rec.frgn_erg_ded_name
    ,p_frgn_erg_ded_ident_o          => ben_abr_shd.g_old_rec.frgn_erg_ded_ident
    ,p_no_mx_elcn_val_dfnd_flag_o    => ben_abr_shd.g_old_rec.no_mx_elcn_val_dfnd_flag
    ,p_prtl_mo_det_mthd_rl_o         => ben_abr_shd.g_old_rec.prtl_mo_det_mthd_rl
    ,p_entr_val_at_enrt_flag_o       => ben_abr_shd.g_old_rec.entr_val_at_enrt_flag
    ,p_prtl_mo_eff_dt_det_rl_o       => ben_abr_shd.g_old_rec.prtl_mo_eff_dt_det_rl
    ,p_rndg_rl_o                     => ben_abr_shd.g_old_rec.rndg_rl
    ,p_val_calc_rl_o                 => ben_abr_shd.g_old_rec.val_calc_rl
    ,p_no_mn_elcn_val_dfnd_flag_o    => ben_abr_shd.g_old_rec.no_mn_elcn_val_dfnd_flag
    ,p_prtl_mo_eff_dt_det_cd_o       => ben_abr_shd.g_old_rec.prtl_mo_eff_dt_det_cd
    ,p_only_one_bal_typ_alwd_flag_o  => ben_abr_shd.g_old_rec.only_one_bal_typ_alwd_flag
    ,p_rt_usg_cd_o                   => ben_abr_shd.g_old_rec.rt_usg_cd
    ,p_prort_mn_ann_elcn_val_cd_o    => ben_abr_shd.g_old_rec.prort_mn_ann_elcn_val_cd
    ,p_prort_mn_ann_elcn_val_rl_o    => ben_abr_shd.g_old_rec.prort_mn_ann_elcn_val_rl
    ,p_prort_mx_ann_elcn_val_cd_o    => ben_abr_shd.g_old_rec.prort_mx_ann_elcn_val_cd
    ,p_prort_mx_ann_elcn_val_rl_o    => ben_abr_shd.g_old_rec.prort_mx_ann_elcn_val_rl
    ,p_one_ann_pymt_cd_o             => ben_abr_shd.g_old_rec.one_ann_pymt_cd
    ,p_det_pl_ytd_cntrs_cd_o         => ben_abr_shd.g_old_rec.det_pl_ytd_cntrs_cd
    ,p_asmt_to_use_cd_o              => ben_abr_shd.g_old_rec.asmt_to_use_cd
    ,p_ele_rqd_flag_o                => ben_abr_shd.g_old_rec.ele_rqd_flag
    ,p_subj_to_imptd_incm_flag_o     => ben_abr_shd.g_old_rec.subj_to_imptd_incm_flag
    ,p_element_type_id_o             => ben_abr_shd.g_old_rec.element_type_id
    ,p_input_value_id_o              => ben_abr_shd.g_old_rec.input_value_id
    ,p_input_va_calc_rl_o            => ben_abr_shd.g_old_rec.input_va_calc_rl
    ,p_comp_lvl_fctr_id_o            => ben_abr_shd.g_old_rec.comp_lvl_fctr_id
    ,p_parnt_acty_base_rt_id_o       => ben_abr_shd.g_old_rec.parnt_acty_base_rt_id
    ,p_pgm_id_o                      => ben_abr_shd.g_old_rec.pgm_id
    ,p_pl_id_o                       => ben_abr_shd.g_old_rec.pl_id
    ,p_oipl_id_o                     => ben_abr_shd.g_old_rec.oipl_id
    ,p_opt_id_o                      => ben_abr_shd.g_old_rec.opt_id
    ,p_oiplip_id_o                   => ben_abr_shd.g_old_rec.oiplip_id
    ,p_plip_id_o                     => ben_abr_shd.g_old_rec.plip_id
    ,p_ptip_id_o                     => ben_abr_shd.g_old_rec.ptip_id
    ,p_cmbn_plip_id_o                => ben_abr_shd.g_old_rec.cmbn_plip_id
    ,p_cmbn_ptip_id_o                => ben_abr_shd.g_old_rec.cmbn_ptip_id
    ,p_cmbn_ptip_opt_id_o            => ben_abr_shd.g_old_rec.cmbn_ptip_opt_id
    ,p_vstg_for_acty_rt_id_o         => ben_abr_shd.g_old_rec.vstg_for_acty_rt_id
    ,p_actl_prem_id_o                => ben_abr_shd.g_old_rec.actl_prem_id
    ,p_TTL_COMP_LVL_FCTR_ID_o        => ben_abr_shd.g_old_rec.TTL_COMP_LVL_FCTR_ID
    ,p_COST_ALLOCATION_KEYFLEX_ID_o  => ben_abr_shd.g_old_rec.COST_ALLOCATION_KEYFLEX_ID
    ,p_ALWS_CHG_CD_o                 => ben_abr_shd.g_old_rec.ALWS_CHG_CD
    ,p_ele_entry_val_cd_o            => ben_abr_shd.g_old_rec.ele_entry_val_cd
    ,p_pay_rate_grade_rule_id_o      => ben_abr_shd.g_old_rec.pay_rate_grade_rule_id
    ,p_rate_periodization_cd_o       => ben_abr_shd.g_old_rec.rate_periodization_cd
    ,p_rate_periodization_rl_o       => ben_abr_shd.g_old_rec.rate_periodization_rl
    ,p_mn_mx_elcn_rl_o		     => ben_abr_shd.g_old_rec.mn_mx_elcn_rl
    ,p_mapping_table_name_o            => ben_abr_shd.g_old_rec.mapping_table_name
    ,p_mapping_table_pk_id_o           => ben_abr_shd.g_old_rec.mapping_table_pk_id
    ,p_business_group_id_o           => ben_abr_shd.g_old_rec.business_group_id
    ,p_context_pgm_id_o              => ben_abr_shd.g_old_rec.context_pgm_id
    ,p_context_pl_id_o               => ben_abr_shd.g_old_rec.context_pl_id
    ,p_context_opt_id_o              => ben_abr_shd.g_old_rec.context_opt_id
    ,p_element_det_rl_o              => ben_abr_shd.g_old_rec.element_det_rl
    ,p_currency_det_cd_o             => ben_abr_shd.g_old_rec.currency_det_cd
    ,P_ABR_ATTRIBUTE_CATEGORY_o      => ben_abr_shd.g_old_rec.ABR_ATTRIBUTE_CATEGORY
    ,P_ABR_ATTRIBUTE1_o              => ben_abr_shd.g_old_rec.ABR_ATTRIBUTE1
    ,P_ABR_ATTRIBUTE2_o              => ben_abr_shd.g_old_rec.ABR_ATTRIBUTE2
    ,P_ABR_ATTRIBUTE3_o              => ben_abr_shd.g_old_rec.ABR_ATTRIBUTE3
    ,P_ABR_ATTRIBUTE4_o              => ben_abr_shd.g_old_rec.ABR_ATTRIBUTE4
    ,P_ABR_ATTRIBUTE5_o              => ben_abr_shd.g_old_rec.ABR_ATTRIBUTE5
    ,P_ABR_ATTRIBUTE6_o              => ben_abr_shd.g_old_rec.ABR_ATTRIBUTE6
    ,P_ABR_ATTRIBUTE7_o              => ben_abr_shd.g_old_rec.ABR_ATTRIBUTE7
    ,P_ABR_ATTRIBUTE8_o              => ben_abr_shd.g_old_rec.ABR_ATTRIBUTE8
    ,P_ABR_ATTRIBUTE9_o              => ben_abr_shd.g_old_rec.ABR_ATTRIBUTE9
    ,P_ABR_ATTRIBUTE10_o             => ben_abr_shd.g_old_rec.ABR_ATTRIBUTE10
    ,P_ABR_ATTRIBUTE11_o             => ben_abr_shd.g_old_rec.ABR_ATTRIBUTE11
    ,P_ABR_ATTRIBUTE12_o             => ben_abr_shd.g_old_rec.ABR_ATTRIBUTE12
    ,P_ABR_ATTRIBUTE13_o             => ben_abr_shd.g_old_rec.ABR_ATTRIBUTE13
    ,P_ABR_ATTRIBUTE14_o             => ben_abr_shd.g_old_rec.ABR_ATTRIBUTE14
    ,P_ABR_ATTRIBUTE15_o             => ben_abr_shd.g_old_rec.ABR_ATTRIBUTE15
    ,P_ABR_ATTRIBUTE16_o             => ben_abr_shd.g_old_rec.ABR_ATTRIBUTE16
    ,P_ABR_ATTRIBUTE17_o             => ben_abr_shd.g_old_rec.ABR_ATTRIBUTE17
    ,P_ABR_ATTRIBUTE18_o             => ben_abr_shd.g_old_rec.ABR_ATTRIBUTE18
    ,P_ABR_ATTRIBUTE19_o             => ben_abr_shd.g_old_rec.ABR_ATTRIBUTE19
    ,P_ABR_ATTRIBUTE20_o             => ben_abr_shd.g_old_rec.ABR_ATTRIBUTE20
    ,P_ABR_ATTRIBUTE21_o             => ben_abr_shd.g_old_rec.ABR_ATTRIBUTE21
    ,P_ABR_ATTRIBUTE22_o             => ben_abr_shd.g_old_rec.ABR_ATTRIBUTE22
    ,P_ABR_ATTRIBUTE23_o             => ben_abr_shd.g_old_rec.ABR_ATTRIBUTE23
    ,P_ABR_ATTRIBUTE24_o             => ben_abr_shd.g_old_rec.ABR_ATTRIBUTE24
    ,P_ABR_ATTRIBUTE25_o             => ben_abr_shd.g_old_rec.ABR_ATTRIBUTE25
    ,P_ABR_ATTRIBUTE26_o             => ben_abr_shd.g_old_rec.ABR_ATTRIBUTE26
    ,P_ABR_ATTRIBUTE27_o             => ben_abr_shd.g_old_rec.ABR_ATTRIBUTE27
    ,P_ABR_ATTRIBUTE28_o             => ben_abr_shd.g_old_rec.ABR_ATTRIBUTE28
    ,P_ABR_ATTRIBUTE29_o             => ben_abr_shd.g_old_rec.ABR_ATTRIBUTE29
    ,P_ABR_ATTRIBUTE30_o             => ben_abr_shd.g_old_rec.ABR_ATTRIBUTE30
    ,P_ABR_SEQ_NUM_o                 => ben_abr_shd.g_old_rec.ABR_SEQ_NUM
    ,P_OBJECT_VERSION_NUMBER_o       => ben_abr_shd.g_old_rec.OBJECT_VERSION_NUMBER
    );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'ben_acty_base_rt_f'
        ,p_hook_type   => 'AU');
      --
  end;

  hr_utility.set_location(' Leaving:'||l_proc, 10);
End post_update;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_defs >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   The Convert_Defs procedure has one very important function:
--   It must return the record structure for the row with all system defaulted
--   values converted into its corresponding parameter value for update. When
--   we attempt to update a row through the Upd process , certain
--   parameters can be defaulted which enables flexibility in the calling of
--   the upd process (e.g. only attributes which need to be updated need to be
--   specified). For the upd process to determine which attributes
--   have NOT been specified we need to check if the parameter has a reserved
--   system default value. Therefore, for all parameters which have a
--   corresponding reserved system default mechanism specified we need to
--   check if a system default is being used. If a system default is being
--   used then we convert the defaulted value into its corresponding attribute
--   value held in the g_old_rec data structure.
--
-- Prerequisites:
--   This private function can only be called from the upd process.
--
-- In Parameters:
--   A Pl/Sql record structre.
--
-- Post Success:
--   The record structure will be returned with all system defaulted parameter
--   values converted into its current row attribute value.
--
-- Post Failure:
--   No direct error handling is required within this function. Any possible
--   errors within this procedure will be a PL/SQL value error due to conversion

--   of datatypes or data lengths.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure convert_defs(p_rec in out nocopy ben_abr_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'convert_defs';
--
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must now examine each argument value in the
  -- p_rec plsql record structure
  -- to see if a system default is being used. If a system default
  -- is being used then we must set to the 'current' argument value.
  --
  If (p_rec.ordr_num = hr_api.g_number) then
      p_rec.ordr_num :=
      ben_abr_shd.g_old_rec.ordr_num;
  End If;
  If (p_rec.acty_typ_cd = hr_api.g_varchar2) then
    p_rec.acty_typ_cd :=
    ben_abr_shd.g_old_rec.acty_typ_cd;
  End If;

  If (p_rec.sub_acty_typ_cd = hr_api.g_varchar2) then
    p_rec.sub_acty_typ_cd :=
    ben_abr_shd.g_old_rec.sub_acty_typ_cd;
  End If;

  If (p_rec.element_type_id = hr_api.g_number) then
    p_rec.element_type_id :=
    ben_abr_shd.g_old_rec.element_type_id;
  End If;
  If (p_rec.input_value_id  = hr_api.g_number) then
    p_rec.input_value_id  :=
    ben_abr_shd.g_old_rec.input_value_id ;
  End If;
  If (p_rec.input_va_calc_rl  = hr_api.g_number) then
    p_rec.input_va_calc_rl  :=
    ben_abr_shd.g_old_rec.input_va_calc_rl ;
  End If;
  If (p_rec.comp_lvl_fctr_id = hr_api.g_number) then
    p_rec.comp_lvl_fctr_id :=
    ben_abr_shd.g_old_rec.comp_lvl_fctr_id;
  End If;
  If (p_rec.parnt_acty_base_rt_id = hr_api.g_number) then
    p_rec.parnt_acty_base_rt_id :=
    ben_abr_shd.g_old_rec.parnt_acty_base_rt_id;
  End If;
  If (p_rec.pgm_id = hr_api.g_number) then
    p_rec.pgm_id :=
    ben_abr_shd.g_old_rec.pgm_id;
  End If;
  If (p_rec.pl_id = hr_api.g_number) then
    p_rec.pl_id :=
    ben_abr_shd.g_old_rec.pl_id;
  End If;
  If (p_rec.oipl_id = hr_api.g_number) then
    p_rec.oipl_id :=
    ben_abr_shd.g_old_rec.oipl_id;
  End If;
  If (p_rec.opt_id = hr_api.g_number) then
    p_rec.opt_id :=
    ben_abr_shd.g_old_rec.opt_id;
  End If;
  If (p_rec.oiplip_id = hr_api.g_number) then
    p_rec.oiplip_id :=
    ben_abr_shd.g_old_rec.oiplip_id;
  End If;
  If (p_rec.plip_id = hr_api.g_number) then
    p_rec.plip_id :=
    ben_abr_shd.g_old_rec.plip_id;
  End If;
  If (p_rec.ptip_id = hr_api.g_number) then
    p_rec.ptip_id :=
    ben_abr_shd.g_old_rec.ptip_id;
  End If;
  If (p_rec.cmbn_ptip_opt_id = hr_api.g_number) then
    p_rec.cmbn_ptip_opt_id :=
    ben_abr_shd.g_old_rec.cmbn_ptip_opt_id;
  End If;
  If (p_rec.vstg_for_acty_rt_id = hr_api.g_number) then
    p_rec.vstg_for_acty_rt_id :=
    ben_abr_shd.g_old_rec.vstg_for_acty_rt_id;
  End If;
  If (p_rec.actl_prem_id = hr_api.g_number) then
    p_rec.actl_prem_id :=
    ben_abr_shd.g_old_rec.actl_prem_id;
  End If;
  If (p_rec.TTL_COMP_LVL_FCTR_ID = hr_api.g_number) then
    p_rec.TTL_COMP_LVL_FCTR_ID :=
    ben_abr_shd.g_old_rec.TTL_COMP_LVL_FCTR_ID;
  End If;
  If (p_rec.COST_ALLOCATION_KEYFLEX_ID = hr_api.g_number) then
    p_rec.COST_ALLOCATION_KEYFLEX_ID :=
    ben_abr_shd.g_old_rec.COST_ALLOCATION_KEYFLEX_ID;
  End If;
  If (p_rec.ALWS_CHG_CD = hr_api.g_varchar2) then
    p_rec.ALWS_CHG_CD :=
    ben_abr_shd.g_old_rec.ALWS_CHG_CD;
  End If;
  If (p_rec.ele_entry_val_cd = hr_api.g_varchar2) then
    p_rec.ele_entry_val_cd :=
    ben_abr_shd.g_old_rec.ele_entry_val_cd;
  End If;
  If (p_rec.rt_typ_cd = hr_api.g_varchar2) then
    p_rec.rt_typ_cd :=
    ben_abr_shd.g_old_rec.rt_typ_cd;
  End If;
  If (p_rec.bnft_rt_typ_cd = hr_api.g_varchar2) then
    p_rec.bnft_rt_typ_cd :=
    ben_abr_shd.g_old_rec.bnft_rt_typ_cd;
  End If;
  If (p_rec.tx_typ_cd = hr_api.g_varchar2) then
    p_rec.tx_typ_cd :=
    ben_abr_shd.g_old_rec.tx_typ_cd;
  End If;
  If (p_rec.use_to_calc_net_flx_cr_flag = hr_api.g_varchar2) then
    p_rec.use_to_calc_net_flx_cr_flag :=
    ben_abr_shd.g_old_rec.use_to_calc_net_flx_cr_flag;
  End If;
  If (p_rec.asn_on_enrt_flag = hr_api.g_varchar2) then
    p_rec.asn_on_enrt_flag :=
    ben_abr_shd.g_old_rec.asn_on_enrt_flag;
  End If;
  If (p_rec.abv_mx_elcn_val_alwd_flag = hr_api.g_varchar2) then
    p_rec.abv_mx_elcn_val_alwd_flag :=
    ben_abr_shd.g_old_rec.abv_mx_elcn_val_alwd_flag;
  End If;
  If (p_rec.blw_mn_elcn_alwd_flag = hr_api.g_varchar2) then
    p_rec.blw_mn_elcn_alwd_flag :=
    ben_abr_shd.g_old_rec.blw_mn_elcn_alwd_flag;
  End If;
  If (p_rec.dsply_on_enrt_flag = hr_api.g_varchar2) then
    p_rec.dsply_on_enrt_flag :=
    ben_abr_shd.g_old_rec.dsply_on_enrt_flag;
  End If;
  If (p_rec.parnt_chld_cd = hr_api.g_varchar2) then
    p_rec.parnt_chld_cd :=
    ben_abr_shd.g_old_rec.parnt_chld_cd;
  End If;
  If (p_rec.use_calc_acty_bs_rt_flag = hr_api.g_varchar2) then
    p_rec.use_calc_acty_bs_rt_flag :=
    ben_abr_shd.g_old_rec.use_calc_acty_bs_rt_flag;
  End If;
  If (p_rec.uses_ded_sched_flag = hr_api.g_varchar2) then
    p_rec.uses_ded_sched_flag :=
    ben_abr_shd.g_old_rec.uses_ded_sched_flag;
  End If;
  If (p_rec.uses_varbl_rt_flag = hr_api.g_varchar2) then
    p_rec.uses_varbl_rt_flag :=
    ben_abr_shd.g_old_rec.uses_varbl_rt_flag;
  End If;
  If (p_rec.vstg_sched_apls_flag = hr_api.g_varchar2) then
    p_rec.vstg_sched_apls_flag :=
    ben_abr_shd.g_old_rec.vstg_sched_apls_flag;
  End If;
  If (p_rec.rt_mlt_cd = hr_api.g_varchar2) then
    p_rec.rt_mlt_cd :=
    ben_abr_shd.g_old_rec.rt_mlt_cd;
  End If;
  If (p_rec.proc_each_pp_dflt_flag = hr_api.g_varchar2) then
    p_rec.proc_each_pp_dflt_flag :=
    ben_abr_shd.g_old_rec.proc_each_pp_dflt_flag;
  End If;
  If (p_rec.prdct_flx_cr_when_elig_flag = hr_api.g_varchar2) then
    p_rec.prdct_flx_cr_when_elig_flag :=
    ben_abr_shd.g_old_rec.prdct_flx_cr_when_elig_flag;
  End If;
  If (p_rec.no_std_rt_used_flag = hr_api.g_varchar2) then
    p_rec.no_std_rt_used_flag :=
    ben_abr_shd.g_old_rec.no_std_rt_used_flag;
  End If;
  If (p_rec.rcrrg_cd = hr_api.g_varchar2) then
    p_rec.rcrrg_cd :=
    ben_abr_shd.g_old_rec.rcrrg_cd;
  End If;
  If (p_rec.mn_elcn_val = hr_api.g_number) then
    p_rec.mn_elcn_val :=
    ben_abr_shd.g_old_rec.mn_elcn_val;
  End If;
  If (p_rec.mx_elcn_val = hr_api.g_number) then
    p_rec.mx_elcn_val :=
    ben_abr_shd.g_old_rec.mx_elcn_val;
  End If;
  If (p_rec.lwr_lmt_val = hr_api.g_number) then
    p_rec.lwr_lmt_val :=
    ben_abr_shd.g_old_rec.lwr_lmt_val;
  End If;
  If (p_rec.lwr_lmt_calc_rl = hr_api.g_number) then
    p_rec.lwr_lmt_calc_rl :=
    ben_abr_shd.g_old_rec.lwr_lmt_calc_rl;
  End If;
  If (p_rec.upr_lmt_val = hr_api.g_number) then
    p_rec.upr_lmt_val :=
    ben_abr_shd.g_old_rec.upr_lmt_val;
  End If;
  If (p_rec.upr_lmt_calc_rl = hr_api.g_number) then
    p_rec.upr_lmt_calc_rl :=
    ben_abr_shd.g_old_rec.upr_lmt_calc_rl;
  End If;
  If (p_rec.ptd_comp_lvl_fctr_id = hr_api.g_number) then
    p_rec.ptd_comp_lvl_fctr_id :=
    ben_abr_shd.g_old_rec.ptd_comp_lvl_fctr_id;
  End If;
  If (p_rec.clm_comp_lvl_fctr_id = hr_api.g_number) then
    p_rec.clm_comp_lvl_fctr_id :=
    ben_abr_shd.g_old_rec.clm_comp_lvl_fctr_id;
  End If;
  If (p_rec.entr_ann_val_flag = hr_api.g_varchar2) then
    p_rec.entr_ann_val_flag :=
    ben_abr_shd.g_old_rec.entr_ann_val_flag;
  End If;
  If (p_rec.ann_mn_elcn_val = hr_api.g_number) then
    p_rec.ann_mn_elcn_val :=
    ben_abr_shd.g_old_rec.ann_mn_elcn_val;
  End If;
  If (p_rec.ann_mx_elcn_val = hr_api.g_number) then
    p_rec.ann_mx_elcn_val :=
    ben_abr_shd.g_old_rec.ann_mx_elcn_val;
  End If;
  If (p_rec.wsh_rl_dy_mo_num = hr_api.g_number) then
    p_rec.wsh_rl_dy_mo_num :=
    ben_abr_shd.g_old_rec.wsh_rl_dy_mo_num;
  End If;
  If (p_rec.uses_pymt_sched_flag = hr_api.g_varchar2) then
    p_rec.uses_pymt_sched_flag :=
    ben_abr_shd.g_old_rec.uses_pymt_sched_flag;
  End If;
  If (p_rec.nnmntry_uom = hr_api.g_varchar2) then
    p_rec.nnmntry_uom :=
    ben_abr_shd.g_old_rec.nnmntry_uom;
  End If;
  If (p_rec.val = hr_api.g_number) then
    p_rec.val :=
    ben_abr_shd.g_old_rec.val;
  End If;
  If (p_rec.incrmt_elcn_val = hr_api.g_number) then
    p_rec.incrmt_elcn_val :=
    ben_abr_shd.g_old_rec.incrmt_elcn_val;
  End If;
  If (p_rec.rndg_cd = hr_api.g_varchar2) then
    p_rec.rndg_cd :=
    ben_abr_shd.g_old_rec.rndg_cd;
  End If;
  If (p_rec.val_ovrid_alwd_flag = hr_api.g_varchar2) then
    p_rec.val_ovrid_alwd_flag :=
    ben_abr_shd.g_old_rec.val_ovrid_alwd_flag;
  End If;
  If (p_rec.prtl_mo_det_mthd_cd = hr_api.g_varchar2) then
    p_rec.prtl_mo_det_mthd_cd :=
    ben_abr_shd.g_old_rec.prtl_mo_det_mthd_cd;
  End If;
  If (p_rec.acty_base_rt_stat_cd = hr_api.g_varchar2) then
    p_rec.acty_base_rt_stat_cd :=
    ben_abr_shd.g_old_rec.acty_base_rt_stat_cd;
  End If;
  If (p_rec.procg_src_cd = hr_api.g_varchar2) then
    p_rec.procg_src_cd :=
    ben_abr_shd.g_old_rec.procg_src_cd;
  End If;
  If (p_rec.dflt_val = hr_api.g_number) then
    p_rec.dflt_val :=
    ben_abr_shd.g_old_rec.dflt_val;
  End If;
  If (p_rec.dflt_flag = hr_api.g_varchar2) then
    p_rec.dflt_flag :=
    ben_abr_shd.g_old_rec.dflt_flag;
  End If;
  If (p_rec.frgn_erg_ded_typ_cd = hr_api.g_varchar2) then
    p_rec.frgn_erg_ded_typ_cd :=
    ben_abr_shd.g_old_rec.frgn_erg_ded_typ_cd;
  End If;
  If (p_rec.frgn_erg_ded_name = hr_api.g_varchar2) then
    p_rec.frgn_erg_ded_name :=
    ben_abr_shd.g_old_rec.frgn_erg_ded_name;
  End If;
  If (p_rec.frgn_erg_ded_ident = hr_api.g_varchar2) then
    p_rec.frgn_erg_ded_ident :=
    ben_abr_shd.g_old_rec.frgn_erg_ded_ident;
  End If;
  If (p_rec.no_mx_elcn_val_dfnd_flag = hr_api.g_varchar2) then
    p_rec.no_mx_elcn_val_dfnd_flag :=
    ben_abr_shd.g_old_rec.no_mx_elcn_val_dfnd_flag;
  End If;
  If (p_rec.cmbn_plip_id = hr_api.g_number) then
    p_rec.cmbn_plip_id :=
    ben_abr_shd.g_old_rec.cmbn_plip_id;
  End If;
  If (p_rec.cmbn_ptip_id = hr_api.g_number) then
    p_rec.cmbn_ptip_id :=
    ben_abr_shd.g_old_rec.cmbn_ptip_id;
  End If;
  If (p_rec.prtl_mo_det_mthd_rl = hr_api.g_number) then
    p_rec.prtl_mo_det_mthd_rl :=
    ben_abr_shd.g_old_rec.prtl_mo_det_mthd_rl;
  End If;
  If (p_rec.entr_val_at_enrt_flag = hr_api.g_varchar2) then
    p_rec.entr_val_at_enrt_flag :=
    ben_abr_shd.g_old_rec.entr_val_at_enrt_flag;
  End If;
  If (p_rec.prtl_mo_eff_dt_det_rl = hr_api.g_number) then
    p_rec.prtl_mo_eff_dt_det_rl :=
    ben_abr_shd.g_old_rec.prtl_mo_eff_dt_det_rl;
  End If;
  If (p_rec.rndg_rl = hr_api.g_number) then
    p_rec.rndg_rl :=
    ben_abr_shd.g_old_rec.rndg_rl;
  End If;
  If (p_rec.val_calc_rl = hr_api.g_number) then
    p_rec.val_calc_rl :=
    ben_abr_shd.g_old_rec.val_calc_rl;
  End If;
  If (p_rec.no_mn_elcn_val_dfnd_flag = hr_api.g_varchar2) then
    p_rec.no_mn_elcn_val_dfnd_flag :=
    ben_abr_shd.g_old_rec.no_mn_elcn_val_dfnd_flag;
  End If;
  If (p_rec.prtl_mo_eff_dt_det_cd = hr_api.g_varchar2) then
    p_rec.prtl_mo_eff_dt_det_cd :=
    ben_abr_shd.g_old_rec.prtl_mo_eff_dt_det_cd;
  End If;

  If (p_rec.pay_rate_grade_rule_id  = hr_api.g_number) then
    p_rec.pay_rate_grade_rule_id  :=
    ben_abr_shd.g_old_rec.pay_rate_grade_rule_id;
  End If;

  If (p_rec.rate_periodization_cd  = hr_api.g_varchar2) then
    p_rec.rate_periodization_cd  :=
    ben_abr_shd.g_old_rec.rate_periodization_cd;
  End If;

  If (p_rec.rate_periodization_rl  = hr_api.g_number) then
    p_rec.rate_periodization_rl  :=
    ben_abr_shd.g_old_rec.rate_periodization_rl;
  End If;

  If (p_rec.business_group_id = hr_api.g_number) then
    p_rec.business_group_id :=
    ben_abr_shd.g_old_rec.business_group_id;
  End If;

  If (p_rec.only_one_bal_typ_alwd_flag = hr_api.g_varchar2) then
    p_rec.only_one_bal_typ_alwd_flag :=
    ben_abr_shd.g_old_rec.only_one_bal_typ_alwd_flag;
  End If;
  If (p_rec.rt_usg_cd = hr_api.g_varchar2) then
    p_rec.rt_usg_cd :=
    ben_abr_shd.g_old_rec.rt_usg_cd;
  End If;
  If (p_rec.prort_mn_ann_elcn_val_cd = hr_api.g_varchar2) then
    p_rec.prort_mn_ann_elcn_val_cd :=
    ben_abr_shd.g_old_rec.prort_mn_ann_elcn_val_cd;
  End If;
  If (p_rec.prort_mn_ann_elcn_val_rl = hr_api.g_number) then
    p_rec.prort_mn_ann_elcn_val_rl :=
    ben_abr_shd.g_old_rec.prort_mn_ann_elcn_val_rl;
  End If;
  If (p_rec.prort_mx_ann_elcn_val_cd = hr_api.g_varchar2) then
    p_rec.prort_mx_ann_elcn_val_cd :=
    ben_abr_shd.g_old_rec.prort_mx_ann_elcn_val_cd;
  End If;
  If (p_rec.prort_mx_ann_elcn_val_rl = hr_api.g_number) then
    p_rec.prort_mx_ann_elcn_val_rl :=
    ben_abr_shd.g_old_rec.prort_mx_ann_elcn_val_rl;
  End If;
  If (p_rec.one_ann_pymt_cd = hr_api.g_varchar2) then
    p_rec.one_ann_pymt_cd :=
    ben_abr_shd.g_old_rec.one_ann_pymt_cd;
  End If;
  If (p_rec.det_pl_ytd_cntrs_cd = hr_api.g_varchar2) then
    p_rec.det_pl_ytd_cntrs_cd :=
    ben_abr_shd.g_old_rec.det_pl_ytd_cntrs_cd;
  End If;
  If (p_rec.asmt_to_use_cd = hr_api.g_varchar2) then
    p_rec.asmt_to_use_cd :=
    ben_abr_shd.g_old_rec.asmt_to_use_cd;
  End If;
  If (p_rec.ele_rqd_flag = hr_api.g_varchar2) then
    p_rec.ele_rqd_flag :=
    ben_abr_shd.g_old_rec.ele_rqd_flag;
  End If;
  If (p_rec.subj_to_imptd_incm_flag = hr_api.g_varchar2) then
    p_rec.subj_to_imptd_incm_flag :=
    ben_abr_shd.g_old_rec.subj_to_imptd_incm_flag;
  End If;
  If (p_rec.name    = hr_api.g_varchar2) then
    p_rec.name :=
    ben_abr_shd.g_old_rec.name;
  End If;
  If (p_rec.mn_mx_elcn_rl  = hr_api.g_number) then
    p_rec.mn_mx_elcn_rl  :=
    ben_abr_shd.g_old_rec.mn_mx_elcn_rl;
  End If;
  If (p_rec.mapping_table_name = hr_api.g_varchar2) then
    p_rec.mapping_table_name:=
    ben_abr_shd.g_old_rec.mapping_table_name;
  End If;
  If (p_rec.mapping_table_pk_id  = hr_api.g_number) then
    p_rec.mapping_table_pk_id  :=
    ben_abr_shd.g_old_rec.mapping_table_pk_id;
  End If;

  If (p_rec.element_det_rl  = hr_api.g_number) then
    p_rec.element_det_rl  :=
    ben_abr_shd.g_old_rec.element_det_rl;
  End If;
  If (p_rec.currency_det_cd = hr_api.g_varchar2) then
    p_rec.currency_det_cd:=
    ben_abr_shd.g_old_rec.currency_det_cd;
  End If;

  If (p_rec.abr_attribute_category = hr_api.g_varchar2) then
    p_rec.abr_attribute_category :=
    ben_abr_shd.g_old_rec.abr_attribute_category;
  End If;
  If (p_rec.abr_attribute1 = hr_api.g_varchar2) then
    p_rec.abr_attribute1 :=
    ben_abr_shd.g_old_rec.abr_attribute1;
  End If;
  If (p_rec.abr_attribute2 = hr_api.g_varchar2) then
    p_rec.abr_attribute2 :=
    ben_abr_shd.g_old_rec.abr_attribute2;
  End If;
  If (p_rec.abr_attribute3 = hr_api.g_varchar2) then
    p_rec.abr_attribute3 :=
    ben_abr_shd.g_old_rec.abr_attribute3;
  End If;
  If (p_rec.abr_attribute4 = hr_api.g_varchar2) then
    p_rec.abr_attribute4 :=
    ben_abr_shd.g_old_rec.abr_attribute4;
  End If;
  If (p_rec.abr_attribute5 = hr_api.g_varchar2) then
    p_rec.abr_attribute5 :=
    ben_abr_shd.g_old_rec.abr_attribute5;
  End If;
  If (p_rec.abr_attribute6 = hr_api.g_varchar2) then
    p_rec.abr_attribute6 :=
    ben_abr_shd.g_old_rec.abr_attribute6;
  End If;
  If (p_rec.abr_attribute7 = hr_api.g_varchar2) then
    p_rec.abr_attribute7 :=
    ben_abr_shd.g_old_rec.abr_attribute7;
  End If;
  If (p_rec.abr_attribute8 = hr_api.g_varchar2) then
    p_rec.abr_attribute8 :=
    ben_abr_shd.g_old_rec.abr_attribute8;
  End If;
  If (p_rec.abr_attribute9 = hr_api.g_varchar2) then
    p_rec.abr_attribute9 :=
    ben_abr_shd.g_old_rec.abr_attribute9;
  End If;
  If (p_rec.abr_attribute10 = hr_api.g_varchar2) then
    p_rec.abr_attribute10 :=
    ben_abr_shd.g_old_rec.abr_attribute10;
  End If;
  If (p_rec.abr_attribute11 = hr_api.g_varchar2) then
    p_rec.abr_attribute11 :=
    ben_abr_shd.g_old_rec.abr_attribute11;
  End If;
  If (p_rec.abr_attribute12 = hr_api.g_varchar2) then
    p_rec.abr_attribute12 :=
    ben_abr_shd.g_old_rec.abr_attribute12;
  End If;
  If (p_rec.abr_attribute13 = hr_api.g_varchar2) then
    p_rec.abr_attribute13 :=
    ben_abr_shd.g_old_rec.abr_attribute13;
  End If;
  If (p_rec.abr_attribute14 = hr_api.g_varchar2) then
    p_rec.abr_attribute14 :=
    ben_abr_shd.g_old_rec.abr_attribute14;
  End If;
  If (p_rec.abr_attribute15 = hr_api.g_varchar2) then
    p_rec.abr_attribute15 :=
    ben_abr_shd.g_old_rec.abr_attribute15;
  End If;
  If (p_rec.abr_attribute16 = hr_api.g_varchar2) then
    p_rec.abr_attribute16 :=
    ben_abr_shd.g_old_rec.abr_attribute16;
  End If;
  If (p_rec.abr_attribute17 = hr_api.g_varchar2) then
    p_rec.abr_attribute17 :=
    ben_abr_shd.g_old_rec.abr_attribute17;
  End If;
  If (p_rec.abr_attribute18 = hr_api.g_varchar2) then
    p_rec.abr_attribute18 :=
    ben_abr_shd.g_old_rec.abr_attribute18;
  End If;
  If (p_rec.abr_attribute19 = hr_api.g_varchar2) then
    p_rec.abr_attribute19 :=
    ben_abr_shd.g_old_rec.abr_attribute19;
  End If;
  If (p_rec.abr_attribute20 = hr_api.g_varchar2) then
    p_rec.abr_attribute20 :=
    ben_abr_shd.g_old_rec.abr_attribute20;
  End If;
  If (p_rec.abr_attribute21 = hr_api.g_varchar2) then
    p_rec.abr_attribute21 :=
    ben_abr_shd.g_old_rec.abr_attribute21;
  End If;
  If (p_rec.abr_attribute22 = hr_api.g_varchar2) then
    p_rec.abr_attribute22 :=
    ben_abr_shd.g_old_rec.abr_attribute22;
  End If;
  If (p_rec.abr_attribute23 = hr_api.g_varchar2) then
    p_rec.abr_attribute23 :=
    ben_abr_shd.g_old_rec.abr_attribute23;
  End If;
  If (p_rec.abr_attribute24 = hr_api.g_varchar2) then
    p_rec.abr_attribute24 :=
    ben_abr_shd.g_old_rec.abr_attribute24;
  End If;
  If (p_rec.abr_attribute25 = hr_api.g_varchar2) then
    p_rec.abr_attribute25 :=
    ben_abr_shd.g_old_rec.abr_attribute25;
  End If;
  If (p_rec.abr_attribute26 = hr_api.g_varchar2) then
    p_rec.abr_attribute26 :=
    ben_abr_shd.g_old_rec.abr_attribute26;
  End If;
  If (p_rec.abr_attribute27 = hr_api.g_varchar2) then
    p_rec.abr_attribute27 :=
    ben_abr_shd.g_old_rec.abr_attribute27;
  End If;
  If (p_rec.abr_attribute28 = hr_api.g_varchar2) then
    p_rec.abr_attribute28 :=
    ben_abr_shd.g_old_rec.abr_attribute28;
  End If;
  If (p_rec.abr_attribute29 = hr_api.g_varchar2) then
    p_rec.abr_attribute29 :=
    ben_abr_shd.g_old_rec.abr_attribute29;
  End If;
  If (p_rec.abr_attribute30 = hr_api.g_varchar2) then
    p_rec.abr_attribute30 :=
    ben_abr_shd.g_old_rec.abr_attribute30;
  End If;
  If (p_rec.abr_seq_num = hr_api.g_number) then
    p_rec.abr_seq_num :=
    ben_abr_shd.g_old_rec.abr_seq_num;
  End If;
  If (p_rec.context_pgm_id = hr_api.g_number) then
    p_rec.context_pgm_id :=
    ben_abr_shd.g_old_rec.context_pgm_id;
  End If;

  If (p_rec.context_pl_id = hr_api.g_number) then
    p_rec.context_pl_id :=
    ben_abr_shd.g_old_rec.context_pl_id;
  End If;

  If (p_rec.context_opt_id = hr_api.g_number) then
    p_rec.context_opt_id :=
    ben_abr_shd.g_old_rec.context_opt_id;
  End If;
   --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
End convert_defs;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (
  p_rec			in out nocopy 	ben_abr_shd.g_rec_type,
  p_effective_date	in 	date,
  p_datetrack_mode	in 	varchar2
  ) is
--
  l_proc			varchar2(72) := g_package||'upd';
  l_validation_start_date	date;
  l_validation_end_date		date;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Ensure that the DateTrack update mode is valid
  --
  dt_api.validate_dt_upd_mode(p_datetrack_mode => p_datetrack_mode);
  --
  -- We must lock the row which we need to update.
  --
  ben_abr_shd.lck
	(p_effective_date	 => p_effective_date,
      	 p_datetrack_mode	 => p_datetrack_mode,
      	 p_acty_base_rt_id	 => p_rec.acty_base_rt_id,
      	 p_object_version_number => p_rec.object_version_number,
      	 p_validation_start_date => l_validation_start_date,
      	 p_validation_end_date	 => l_validation_end_date);
  --
  -- 1. During an update system defaults are used to determine if
  --    arguments have been defaulted or not. We must therefore
  --    derive the full record structure values to be updated.
  --
  -- 2. Call the supporting update validate operations.
  --
  convert_defs(p_rec);
  ben_abr_bus.update_validate
	(p_rec			 => p_rec,
	 p_effective_date	 => p_effective_date,
	 p_datetrack_mode  	 => p_datetrack_mode,
	 p_validation_start_date => l_validation_start_date,
	 p_validation_end_date	 => l_validation_end_date);
  --
  -- Call the supporting pre-update operation
  --
  pre_update
	(p_rec			 => p_rec,
	 p_effective_date	 => p_effective_date,
	 p_datetrack_mode	 => p_datetrack_mode,
	 p_validation_start_date => l_validation_start_date,
	 p_validation_end_date	 => l_validation_end_date);
  --
  -- Update the row.
  --
  update_dml
	(p_rec			 => p_rec,
	 p_effective_date	 => p_effective_date,
	 p_datetrack_mode	 => p_datetrack_mode,
	 p_validation_start_date => l_validation_start_date,
	 p_validation_end_date	 => l_validation_end_date);
  --
  -- Call the supporting post-update operation
  --
  post_update
	(p_rec			 => p_rec,
	 p_effective_date	 => p_effective_date,
	 p_datetrack_mode	 => p_datetrack_mode,
	 p_validation_start_date => l_validation_start_date,
	 p_validation_end_date	 => l_validation_end_date);
End upd;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (
  p_acty_base_rt_id              in number,
  p_effective_start_date         out nocopy date,
  p_effective_end_date           out nocopy date,
  p_ordr_num			 in number           default hr_api.g_number,
  p_acty_typ_cd                  in varchar2         default hr_api.g_varchar2,
  p_sub_acty_typ_cd              in varchar2         default hr_api.g_varchar2,
  p_name                         in varchar2         default hr_api.g_varchar2,
  p_rt_typ_cd                    in varchar2         default hr_api.g_varchar2,
  p_bnft_rt_typ_cd               in varchar2         default hr_api.g_varchar2,
  p_tx_typ_cd                    in varchar2         default hr_api.g_varchar2,
  p_use_to_calc_net_flx_cr_flag  in varchar2         default hr_api.g_varchar2,
  p_asn_on_enrt_flag             in varchar2         default hr_api.g_varchar2,
  p_abv_mx_elcn_val_alwd_flag    in varchar2         default hr_api.g_varchar2,
  p_blw_mn_elcn_alwd_flag        in varchar2         default hr_api.g_varchar2,
  p_dsply_on_enrt_flag           in varchar2         default hr_api.g_varchar2,
  p_parnt_chld_cd                in varchar2         default hr_api.g_varchar2,
  p_use_calc_acty_bs_rt_flag     in varchar2         default hr_api.g_varchar2,
  p_uses_ded_sched_flag          in varchar2         default hr_api.g_varchar2,
  p_uses_varbl_rt_flag           in varchar2         default hr_api.g_varchar2,
  p_vstg_sched_apls_flag         in varchar2         default hr_api.g_varchar2,
  p_rt_mlt_cd                    in varchar2         default hr_api.g_varchar2,
  p_proc_each_pp_dflt_flag       in varchar2         default hr_api.g_varchar2,
  p_prdct_flx_cr_when_elig_flag  in varchar2         default hr_api.g_varchar2,
  p_no_std_rt_used_flag          in varchar2         default hr_api.g_varchar2,
  p_rcrrg_cd                     in varchar2         default hr_api.g_varchar2,
  p_mn_elcn_val                  in number           default hr_api.g_number,
  p_mx_elcn_val                  in number           default hr_api.g_number,
  p_lwr_lmt_val                  in number           default hr_api.g_number,
  p_lwr_lmt_calc_rl              in number           default hr_api.g_number,
  p_upr_lmt_val                  in number           default hr_api.g_number,
  p_upr_lmt_calc_rl              in number           default hr_api.g_number,
  p_ptd_comp_lvl_fctr_id         in number           default hr_api.g_number,
  p_clm_comp_lvl_fctr_id         in number           default hr_api.g_number,
  p_entr_ann_val_flag            in varchar2         default hr_api.g_varchar2,
  p_ann_mn_elcn_val              in number           default hr_api.g_number,
  p_ann_mx_elcn_val              in number           default hr_api.g_number,
  p_wsh_rl_dy_mo_num             in number           default hr_api.g_number,
  p_uses_pymt_sched_flag         in varchar2         default hr_api.g_varchar2,
  p_nnmntry_uom                  in varchar2         default hr_api.g_varchar2,
  p_val                          in number           default hr_api.g_number,
  p_incrmt_elcn_val              in number           default hr_api.g_number,
  p_rndg_cd                      in varchar2         default hr_api.g_varchar2,
  p_val_ovrid_alwd_flag          in varchar2         default hr_api.g_varchar2,
  p_prtl_mo_det_mthd_cd          in varchar2         default hr_api.g_varchar2,
  p_acty_base_rt_stat_cd         in varchar2         default hr_api.g_varchar2,
  p_procg_src_cd                 in varchar2         default hr_api.g_varchar2,
  p_dflt_val                     in number           default hr_api.g_number,
  p_dflt_flag                    in varchar2         default hr_api.g_varchar2,
  p_frgn_erg_ded_typ_cd          in varchar2         default hr_api.g_varchar2,
  p_frgn_erg_ded_name            in varchar2         default hr_api.g_varchar2,
  p_frgn_erg_ded_ident           in varchar2         default hr_api.g_varchar2,
  p_no_mx_elcn_val_dfnd_flag     in varchar2         default hr_api.g_varchar2,
  p_prtl_mo_det_mthd_rl          in number           default hr_api.g_number,
  p_entr_val_at_enrt_flag        in varchar2         default hr_api.g_varchar2,
  p_prtl_mo_eff_dt_det_rl        in number           default hr_api.g_number,
  p_rndg_rl                      in number           default hr_api.g_number,
  p_val_calc_rl                  in number           default hr_api.g_number,
  p_no_mn_elcn_val_dfnd_flag     in varchar2         default hr_api.g_varchar2,
  p_prtl_mo_eff_dt_det_cd        in varchar2         default hr_api.g_varchar2,
  p_only_one_bal_typ_alwd_flag   in varchar2         default hr_api.g_varchar2,
  p_rt_usg_cd                    in varchar2         default hr_api.g_varchar2,
  p_prort_mn_ann_elcn_val_cd     in varchar2         default hr_api.g_varchar2,
  p_prort_mn_ann_elcn_val_rl     in number           default hr_api.g_number,
  p_prort_mx_ann_elcn_val_cd     in varchar2         default hr_api.g_varchar2,
  p_prort_mx_ann_elcn_val_rl     in number           default hr_api.g_number,
  p_one_ann_pymt_cd              in varchar2         default hr_api.g_varchar2,
  p_det_pl_ytd_cntrs_cd          in varchar2         default hr_api.g_varchar2,
  p_asmt_to_use_cd               in varchar2         default hr_api.g_varchar2,
  p_ele_rqd_flag                 in varchar2         default hr_api.g_varchar2,
  p_subj_to_imptd_incm_flag      in varchar2         default hr_api.g_varchar2,
  p_element_type_id              in number           default hr_api.g_number,
  p_input_value_id               in number           default hr_api.g_number,
  p_input_va_calc_rl            in number           default hr_api.g_number,
  p_comp_lvl_fctr_id             in number           default hr_api.g_number,
  p_parnt_acty_base_rt_id        in number           default hr_api.g_number,
  p_pgm_id                       in number           default hr_api.g_number,
  p_pl_id                        in number           default hr_api.g_number,
  p_oipl_id                      in number           default hr_api.g_number,
  p_opt_id                       in number           default hr_api.g_number,
  p_oiplip_id                    in number           default hr_api.g_number,
  p_plip_id                      in number           default hr_api.g_number,
  p_ptip_id                      in number           default hr_api.g_number,
  p_cmbn_plip_id                 in number           default hr_api.g_number,
  p_cmbn_ptip_id                 in number           default hr_api.g_number,
  p_cmbn_ptip_opt_id             in number           default hr_api.g_number,
  p_vstg_for_acty_rt_id          in number           default hr_api.g_number,
  p_actl_prem_id                 in number           default hr_api.g_number,
  p_TTL_COMP_LVL_FCTR_ID         in number           default hr_api.g_number,
  p_COST_ALLOCATION_KEYFLEX_ID   in number           default hr_api.g_number,
  p_ALWS_CHG_CD                  in varchar2         default hr_api.g_varchar2,
  p_ele_entry_val_cd             in varchar2         default hr_api.g_varchar2,
  p_pay_rate_grade_rule_id       in number           default hr_api.g_number,
  p_rate_periodization_cd        in varchar2         default hr_api.g_varchar2,
  p_rate_periodization_rl        in number           default hr_api.g_number,
  p_mn_mx_elcn_rl 		 in number           default hr_api.g_number,
  p_mapping_table_name		 in varchar2         default hr_api.g_varchar2,
  p_mapping_table_pk_id		 in number           default hr_api.g_number,
  p_business_group_id            in number           default hr_api.g_number,
  p_context_pgm_id               in number           default hr_api.g_number,
  p_context_pl_id                in number           default hr_api.g_number,
  p_context_opt_id               in number           default hr_api.g_number,
  p_element_det_rl               in number           default hr_api.g_number,
  p_currency_det_cd              in varchar2         default hr_api.g_varchar2,
  p_abr_attribute_category       in varchar2         default hr_api.g_varchar2,
  p_abr_attribute1               in varchar2         default hr_api.g_varchar2,
  p_abr_attribute2               in varchar2         default hr_api.g_varchar2,
  p_abr_attribute3               in varchar2         default hr_api.g_varchar2,
  p_abr_attribute4               in varchar2         default hr_api.g_varchar2,
  p_abr_attribute5               in varchar2         default hr_api.g_varchar2,
  p_abr_attribute6               in varchar2         default hr_api.g_varchar2,
  p_abr_attribute7               in varchar2         default hr_api.g_varchar2,
  p_abr_attribute8               in varchar2         default hr_api.g_varchar2,
  p_abr_attribute9               in varchar2         default hr_api.g_varchar2,
  p_abr_attribute10              in varchar2         default hr_api.g_varchar2,
  p_abr_attribute11              in varchar2         default hr_api.g_varchar2,
  p_abr_attribute12              in varchar2         default hr_api.g_varchar2,
  p_abr_attribute13              in varchar2         default hr_api.g_varchar2,
  p_abr_attribute14              in varchar2         default hr_api.g_varchar2,
  p_abr_attribute15              in varchar2         default hr_api.g_varchar2,
  p_abr_attribute16              in varchar2         default hr_api.g_varchar2,
  p_abr_attribute17              in varchar2         default hr_api.g_varchar2,
  p_abr_attribute18              in varchar2         default hr_api.g_varchar2,
  p_abr_attribute19              in varchar2         default hr_api.g_varchar2,
  p_abr_attribute20              in varchar2         default hr_api.g_varchar2,
  p_abr_attribute21              in varchar2         default hr_api.g_varchar2,
  p_abr_attribute22              in varchar2         default hr_api.g_varchar2,
  p_abr_attribute23              in varchar2         default hr_api.g_varchar2,
  p_abr_attribute24              in varchar2         default hr_api.g_varchar2,
  p_abr_attribute25              in varchar2         default hr_api.g_varchar2,
  p_abr_attribute26              in varchar2         default hr_api.g_varchar2,
  p_abr_attribute27              in varchar2         default hr_api.g_varchar2,
  p_abr_attribute28              in varchar2         default hr_api.g_varchar2,
  p_abr_attribute29              in varchar2         default hr_api.g_varchar2,
  p_abr_attribute30              in varchar2         default hr_api.g_varchar2,
  p_abr_seq_num                  in number           default hr_api.g_number,
  p_object_version_number        in out nocopy number,
  p_effective_date               in date,
  p_datetrack_mode               in varchar2

  ) is
--
  l_rec		ben_abr_shd.g_rec_type;
  l_proc	varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
   hr_utility.set_location('total rate in upd rhi '||p_TTL_COMP_LVL_FCTR_ID, 99);

  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  ben_abr_shd.convert_args
  (
        p_acty_base_rt_id
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
       ,p_object_version_number
  );
  --
  -- Having converted the arguments into the
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  upd(l_rec, p_effective_date, p_datetrack_mode);
  p_object_version_number       := l_rec.object_version_number;
  p_effective_start_date        := l_rec.effective_start_date;
  p_effective_end_date          := l_rec.effective_end_date;
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End upd;
--
end ben_abr_upd;

/
