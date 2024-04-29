--------------------------------------------------------
--  DDL for Package Body BEN_ABR_DEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_ABR_DEL" as
/* $Header: beabrrhi.pkb 120.18 2008/05/15 10:36:51 krupani ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_abr_del.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |----------------------------< dt_delete_dml >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure controls the actual dml delete logic for the datetrack
--   delete modes: ZAP, DELETE, FUTURE_CHANGE and DELETE_NEXT_CHANGE. The
--   execution is as follows:
--   1) To set and unset the g_api_dml status as required (as we are about to
--      perform dml).
--   2) If the delete mode is DELETE_NEXT_CHANGE then delete where the
--      effective start date is equal to the validation start date.
--   3) If the delete mode is not DELETE_NEXT_CHANGE then delete
--      all rows for the entity where the effective start date is greater
--      than or equal to the validation start date.
--   4) To raise any errors.
--
-- Prerequisites:
--   This is an internal private procedure which must be called from the
--   delete_dml procedure.
--
-- In Parameters:
--   A Pl/Sql record structre.
--
-- Post Success:
--   The specified row will be delete from the schema.
--
-- Post Failure:
--   On the delete dml failure it is important to note that we always reset the
--   g_api_dml status to false.
--   If any other error is reported, the error will be raised after the
--   g_api_dml status is reset.
--
-- Developer Implementation Notes:
--   This is an internal private procedure which must be called from the
--   delete_dml procedure.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure dt_delete_dml
	(p_rec 			 in out nocopy ben_abr_shd.g_rec_type,
	 p_effective_date	 in	date,
	 p_datetrack_mode	 in	varchar2,
	 p_validation_start_date in	date,
	 p_validation_end_date	 in	date) is
--
  l_proc	varchar2(72) := g_package||'dt_delete_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  If (p_datetrack_mode = 'DELETE_NEXT_CHANGE') then
    hr_utility.set_location(l_proc, 10);
    ben_abr_shd.g_api_dml := true;  -- Set the api dml status
    --
    -- Delete the where the effective start date is equal
    -- to the validation end date.
    --
    delete from ben_acty_base_rt_f
    where       acty_base_rt_id = p_rec.acty_base_rt_id
    and	  effective_start_date = p_validation_start_date;
    --
    ben_abr_shd.g_api_dml := false;   -- Unset the api dml status
  Else
    hr_utility.set_location(l_proc, 15);
    ben_abr_shd.g_api_dml := true;  -- Set the api dml status
    --
    -- Delete the row(s) where the effective start date is greater than
    -- or equal to the validation start date.
    --
    delete from ben_acty_base_rt_f
    where        acty_base_rt_id = p_rec.acty_base_rt_id
    and	  effective_start_date >= p_validation_start_date;
    --
    ben_abr_shd.g_api_dml := false;   -- Unset the api dml status
  End If;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 20);
--
Exception
  When Others Then
    ben_abr_shd.g_api_dml := false;   -- Unset the api dml status
    Raise;
End dt_delete_dml;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< delete_dml >------------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_dml
	(p_rec 			 in out nocopy ben_abr_shd.g_rec_type,
	 p_effective_date	 in	date,
	 p_datetrack_mode	 in	varchar2,
	 p_validation_start_date in	date,
	 p_validation_end_date	 in	date) is
--
  l_proc	varchar2(72) := g_package||'delete_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  dt_delete_dml(p_rec			=> p_rec,
		p_effective_date	=> p_effective_date,
		p_datetrack_mode	=> p_datetrack_mode,
       		p_validation_start_date	=> p_validation_start_date,
		p_validation_end_date	=> p_validation_end_date);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_dml;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< dt_pre_delete >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   The dt_pre_delete process controls the execution of dml
--   for the datetrack modes: DELETE, FUTURE_CHANGE
--   and DELETE_NEXT_CHANGE only.
--
-- Prerequisites:
--   This is an internal procedure which is called from the pre_delete
--   procedure.
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
--   This is an internal procedure which is required by Datetrack. Don't
--   remove or modify.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure dt_pre_delete
	(p_rec 			 in out nocopy ben_abr_shd.g_rec_type,
	 p_effective_date	 in	date,
	 p_datetrack_mode	 in	varchar2,
	 p_validation_start_date in	date,
	 p_validation_end_date	 in	date) is
--
  l_proc	varchar2(72) := g_package||'dt_pre_delete';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (p_datetrack_mode <> 'ZAP') then
    --
    p_rec.effective_start_date := ben_abr_shd.g_old_rec.effective_start_date;
    --
    If (p_datetrack_mode = 'DELETE') then
      p_rec.effective_end_date := p_validation_start_date - 1;
    Else
      p_rec.effective_end_date := p_validation_end_date;
    End If;
    --
    -- Update the current effective end date record
    --
    ben_abr_shd.upd_effective_end_date
      (p_effective_date	        => p_effective_date,
       p_base_key_value	        => p_rec.acty_base_rt_id,
       p_new_effective_end_date => p_rec.effective_end_date,
       p_validation_start_date  => p_validation_start_date,
       p_validation_end_date	=> p_validation_end_date,
       p_object_version_number  => p_rec.object_version_number);
  Else
    p_rec.effective_start_date := null;
    p_rec.effective_end_date   := null;
  End If;
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End dt_pre_delete;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< pre_delete >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This private procedure contains any processing which is required before
--   the delete dml.
--
-- Prerequisites:
--   This is an internal procedure which is called from the del procedure.
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
--   Any pre-processing required before the delete dml is issued should be
--   coded within this procedure. It is important to note that any 3rd party
--   maintenance should be reviewed before placing in this procedure. The call
--   to the dt_delete_dml procedure should NOT be removed.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure pre_delete
	(p_rec 			 in out nocopy ben_abr_shd.g_rec_type,
	 p_effective_date	 in	date,
	 p_datetrack_mode	 in	varchar2,
	 p_validation_start_date in	date,
	 p_validation_end_date	 in	date) is
--
  l_proc	varchar2(72) := g_package||'pre_delete';
--
  --
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  --
  dt_pre_delete
    (p_rec 		     => p_rec,
     p_effective_date	     => p_effective_date,
     p_datetrack_mode	     => p_datetrack_mode,
     p_validation_start_date => p_validation_start_date,
     p_validation_end_date   => p_validation_end_date);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End pre_delete;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< post_delete >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This private procedure contains any processing which is required after the
--   delete dml.
--
-- Prerequisites:
--   This is an internal procedure which is called from the del procedure.
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
--   Any post-processing required after the delete dml is issued should be
--   coded within this procedure. It is important to note that any 3rd party
--   maintenance should be reviewed before placing in this procedure.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure post_delete
	(p_rec 			 in ben_abr_shd.g_rec_type,
	 p_effective_date	 in date,
	 p_datetrack_mode	 in varchar2,
	 p_validation_start_date in date,
	 p_validation_end_date	 in date) is
--
  l_proc	varchar2(72) := g_package||'post_delete';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);

  -- Added for GSP validations
  pqh_gsp_ben_validations.abr_validations
  	(  p_abr_id			=> p_rec.acty_base_rt_id
  	 , p_dml_operation 		=> 'D'
  	 , p_effective_date 		=> p_effective_date
  	 );

  --
  begin
   --
  --
  -- Start of API User Hook for post_delete.
  --
   ben_abr_rkd.after_delete
   (
     p_acty_base_rt_id               => p_rec.acty_base_rt_id
    ,p_datetrack_mode             => p_datetrack_mode
    ,p_validation_start_date      => p_validation_start_date
    ,p_validation_end_date        => p_validation_end_date
    ,p_effective_start_date       => p_rec.effective_start_date
    ,p_effective_end_date         => p_rec.effective_end_date
    ,P_EFFECTIVE_START_DATE_o     => ben_abr_shd.g_old_rec.EFFECTIVE_START_DATE
    ,P_EFFECTIVE_END_DATE_o       => ben_abr_shd.g_old_rec.EFFECTIVE_END_DATE
    ,p_ordr_num_o	          => ben_abr_shd.g_old_rec.ordr_num
    ,p_acty_typ_cd_o              => ben_abr_shd.g_old_rec.acty_typ_cd
    ,p_sub_acty_typ_cd_o          => ben_abr_shd.g_old_rec.sub_acty_typ_cd
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
    ,p_input_va_calc_rl_o           => ben_abr_shd.g_old_rec.input_va_calc_rl
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
    ,p_mn_mx_elcn_rl_o               => ben_abr_shd.g_old_rec.mn_mx_elcn_rl
    ,p_mapping_table_name_o          => ben_abr_shd.g_old_rec.mapping_table_name
    ,p_mapping_table_pk_id_o	     => ben_abr_shd.g_old_rec.mapping_table_pk_id
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
    ,P_ABR_ATTRIBUTE10_o              => ben_abr_shd.g_old_rec.ABR_ATTRIBUTE10
    ,P_ABR_ATTRIBUTE11_o              => ben_abr_shd.g_old_rec.ABR_ATTRIBUTE11
    ,P_ABR_ATTRIBUTE12_o              => ben_abr_shd.g_old_rec.ABR_ATTRIBUTE12
    ,P_ABR_ATTRIBUTE13_o              => ben_abr_shd.g_old_rec.ABR_ATTRIBUTE13
    ,P_ABR_ATTRIBUTE14_o              => ben_abr_shd.g_old_rec.ABR_ATTRIBUTE14
    ,P_ABR_ATTRIBUTE15_o              => ben_abr_shd.g_old_rec.ABR_ATTRIBUTE15
    ,P_ABR_ATTRIBUTE16_o              => ben_abr_shd.g_old_rec.ABR_ATTRIBUTE16
    ,P_ABR_ATTRIBUTE17_o              => ben_abr_shd.g_old_rec.ABR_ATTRIBUTE17
    ,P_ABR_ATTRIBUTE18_o              => ben_abr_shd.g_old_rec.ABR_ATTRIBUTE18
    ,P_ABR_ATTRIBUTE19_o              => ben_abr_shd.g_old_rec.ABR_ATTRIBUTE19
    ,P_ABR_ATTRIBUTE20_o              => ben_abr_shd.g_old_rec.ABR_ATTRIBUTE20
    ,P_ABR_ATTRIBUTE21_o              => ben_abr_shd.g_old_rec.ABR_ATTRIBUTE21
    ,P_ABR_ATTRIBUTE22_o              => ben_abr_shd.g_old_rec.ABR_ATTRIBUTE22
    ,P_ABR_ATTRIBUTE23_o              => ben_abr_shd.g_old_rec.ABR_ATTRIBUTE23
    ,P_ABR_ATTRIBUTE24_o              => ben_abr_shd.g_old_rec.ABR_ATTRIBUTE24
    ,P_ABR_ATTRIBUTE25_o              => ben_abr_shd.g_old_rec.ABR_ATTRIBUTE25
    ,P_ABR_ATTRIBUTE26_o              => ben_abr_shd.g_old_rec.ABR_ATTRIBUTE26
    ,P_ABR_ATTRIBUTE27_o              => ben_abr_shd.g_old_rec.ABR_ATTRIBUTE27
    ,P_ABR_ATTRIBUTE28_o              => ben_abr_shd.g_old_rec.ABR_ATTRIBUTE28
    ,P_ABR_ATTRIBUTE29_o              => ben_abr_shd.g_old_rec.ABR_ATTRIBUTE29
    ,P_ABR_ATTRIBUTE30_o              => ben_abr_shd.g_old_rec.ABR_ATTRIBUTE30
    ,P_ABR_SEQ_NUM_o                  => ben_abr_shd.g_old_rec.ABR_SEQ_NUM
    ,P_OBJECT_VERSION_NUMBER_o        => ben_abr_shd.g_old_rec.OBJECT_VERSION_NUMBER
    );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'ben_acty_base_rt_f'
        ,p_hook_type   => 'AD');
      --
  end;
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End post_delete;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< del >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure del
  (
  p_rec			in out nocopy 	ben_abr_shd.g_rec_type,
  p_effective_date	in 	date,
  p_datetrack_mode	in 	varchar2
  ) is
--
  l_proc			varchar2(72) := g_package||'del';
  l_validation_start_date	date;
  l_validation_end_date		date;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Ensure that the DateTrack delete mode is valid
  --
  dt_api.validate_dt_del_mode(p_datetrack_mode => p_datetrack_mode);
  --
  -- We must lock the row which we need to delete.
  --
  ben_abr_shd.lck
	(p_effective_date	 => p_effective_date,
      	 p_datetrack_mode	 => p_datetrack_mode,
      	 p_acty_base_rt_id	 => p_rec.acty_base_rt_id,
      	 p_object_version_number => p_rec.object_version_number,
      	 p_validation_start_date => l_validation_start_date,
      	 p_validation_end_date	 => l_validation_end_date);
  --
  -- Call the supporting delete validate operation
  --
  ben_abr_bus.delete_validate
	(p_rec			 => p_rec,
	 p_effective_date	 => p_effective_date,
	 p_datetrack_mode	 => p_datetrack_mode,
	 p_validation_start_date => l_validation_start_date,
	 p_validation_end_date	 => l_validation_end_date);
  --
  -- Call the supporting pre-delete operation
  --
  pre_delete
	(p_rec			 => p_rec,
	 p_effective_date	 => p_effective_date,
	 p_datetrack_mode	 => p_datetrack_mode,
	 p_validation_start_date => l_validation_start_date,
	 p_validation_end_date	 => l_validation_end_date);
  --
  -- Delete the row.
  --
  delete_dml
	(p_rec			 => p_rec,
	 p_effective_date	 => p_effective_date,
	 p_datetrack_mode	 => p_datetrack_mode,
	 p_validation_start_date => l_validation_start_date,
	 p_validation_end_date	 => l_validation_end_date);
  --
  -- Call the supporting post-delete operation
  --
  post_delete
	(p_rec			 => p_rec,
	 p_effective_date	 => p_effective_date,
	 p_datetrack_mode	 => p_datetrack_mode,
	 p_validation_start_date => l_validation_start_date,
	 p_validation_end_date	 => l_validation_end_date);
End del;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< del >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure del
  (
  p_acty_base_rt_id	  in 	 number,
  p_effective_start_date     out nocopy date,
  p_effective_end_date	     out nocopy date,
  p_object_version_number in out nocopy number,
  p_effective_date	  in     date,
  p_datetrack_mode  	  in     varchar2
  ) is
--
  l_rec		ben_abr_shd.g_rec_type;
  l_proc	varchar2(72) := g_package||'del';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- As the delete procedure accepts a plsql record structure we do need to
  -- convert the  arguments into the record structure.
  -- We don't need to call the supplied conversion argument routine as we
  -- only need a few attributes.
  --
  l_rec.acty_base_rt_id		:= p_acty_base_rt_id;
  l_rec.object_version_number 	:= p_object_version_number;
  --
  -- Having converted the arguments into the ben_abr_rec
  -- plsql record structure we must call the corresponding entity
  -- business process
  --
  del(l_rec, p_effective_date, p_datetrack_mode);
  --
  -- Set the out arguments
  --
  p_object_version_number := l_rec.object_version_number;
  p_effective_start_date  := l_rec.effective_start_date;
  p_effective_end_date    := l_rec.effective_end_date;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End del;
--
end ben_abr_del;

/
