--------------------------------------------------------
--  DDL for Package Body BEN_CPD_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_CPD_UPD" as
/* $Header: becpdrhi.pkb 120.1.12010000.3 2010/03/12 06:12:31 sgnanama ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  ben_cpd_upd.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------------------------------< update_dml >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure controls the actual dml update logic. The processing of
--   this procedure is:
--   1) Increment the object_version_number by 1 if the object_version_number
--      is defined as an attribute for this entity.
--   2) To set and unset the g_api_dml status as required (as we are about to
--      perform dml).
--   3) To update the specified row in the schema using the primary key in
--      the predicates.
--   4) To trap any constraint violations that may have occurred.
--   5) To raise any other errors.
--
-- Prerequisites:
--   This is an internal private procedure which must be called from the upd
--   procedure.
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
--   If a check, unique or parent integrity constraint violation is raised the
--   constraint_error procedure will be called.
--   If any other error is reported, the error will be raised after the
--   g_api_dml status is reset.
--
-- Developer Implementation Notes:
--   The update 'set' attribute list should be modified if any of your
--   attributes are not updateable.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure update_dml
  (p_rec in out nocopy ben_cpd_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'update_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Increment the object version
  p_rec.object_version_number := p_rec.object_version_number + 1;
  --
  ben_cpd_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Update the ben_cwb_pl_dsgn Row
  --
  update ben_cwb_pl_dsgn
    set
     pl_id                           = p_rec.pl_id
    ,lf_evt_ocrd_dt                  = p_rec.lf_evt_ocrd_dt
    ,oipl_id                         = p_rec.oipl_id
    ,effective_date                  = p_rec.effective_date
    ,name                            = p_rec.name
    ,group_pl_id                     = p_rec.group_pl_id
    ,group_oipl_id                   = p_rec.group_oipl_id
    ,opt_hidden_flag                 = p_rec.opt_hidden_flag
    ,opt_id                          = p_rec.opt_id
    ,pl_uom                          = p_rec.pl_uom
    ,pl_ordr_num                     = p_rec.pl_ordr_num
    ,oipl_ordr_num                   = p_rec.oipl_ordr_num
    ,pl_xchg_rate                    = p_rec.pl_xchg_rate
    ,opt_count                       = p_rec.opt_count
    ,uses_bdgt_flag                  = p_rec.uses_bdgt_flag
    ,prsrv_bdgt_cd                   = p_rec.prsrv_bdgt_cd
    ,upd_start_dt                    = p_rec.upd_start_dt
    ,upd_end_dt                      = p_rec.upd_end_dt
    ,approval_mode                   = p_rec.approval_mode
    ,enrt_perd_start_dt              = p_rec.enrt_perd_start_dt
    ,enrt_perd_end_dt                = p_rec.enrt_perd_end_dt
    ,yr_perd_start_dt                = p_rec.yr_perd_start_dt
    ,yr_perd_end_dt                  = p_rec.yr_perd_end_dt
    ,wthn_yr_start_dt                = p_rec.wthn_yr_start_dt
    ,wthn_yr_end_dt                  = p_rec.wthn_yr_end_dt
    ,enrt_perd_id                    = p_rec.enrt_perd_id
    ,yr_perd_id                      = p_rec.yr_perd_id
    ,business_group_id               = p_rec.business_group_id
    ,perf_revw_strt_dt               = p_rec.perf_revw_strt_dt
    ,asg_updt_eff_date               = p_rec.asg_updt_eff_date
    ,emp_interview_typ_cd            = p_rec.emp_interview_typ_cd
    ,salary_change_reason            = p_rec.salary_change_reason
    ,ws_abr_id                       = p_rec.ws_abr_id
    ,ws_nnmntry_uom                  = p_rec.ws_nnmntry_uom
    ,ws_rndg_cd                      = p_rec.ws_rndg_cd
    ,ws_sub_acty_typ_cd              = p_rec.ws_sub_acty_typ_cd
    ,dist_bdgt_abr_id                = p_rec.dist_bdgt_abr_id
    ,dist_bdgt_nnmntry_uom           = p_rec.dist_bdgt_nnmntry_uom
    ,dist_bdgt_rndg_cd               = p_rec.dist_bdgt_rndg_cd
    ,ws_bdgt_abr_id                  = p_rec.ws_bdgt_abr_id
    ,ws_bdgt_nnmntry_uom             = p_rec.ws_bdgt_nnmntry_uom
    ,ws_bdgt_rndg_cd                 = p_rec.ws_bdgt_rndg_cd
    ,rsrv_abr_id                     = p_rec.rsrv_abr_id
    ,rsrv_nnmntry_uom                = p_rec.rsrv_nnmntry_uom
    ,rsrv_rndg_cd                    = p_rec.rsrv_rndg_cd
    ,elig_sal_abr_id                 = p_rec.elig_sal_abr_id
    ,elig_sal_nnmntry_uom            = p_rec.elig_sal_nnmntry_uom
    ,elig_sal_rndg_cd                = p_rec.elig_sal_rndg_cd
    ,misc1_abr_id                    = p_rec.misc1_abr_id
    ,misc1_nnmntry_uom               = p_rec.misc1_nnmntry_uom
    ,misc1_rndg_cd                   = p_rec.misc1_rndg_cd
    ,misc2_abr_id                    = p_rec.misc2_abr_id
    ,misc2_nnmntry_uom               = p_rec.misc2_nnmntry_uom
    ,misc2_rndg_cd                   = p_rec.misc2_rndg_cd
    ,misc3_abr_id                    = p_rec.misc3_abr_id
    ,misc3_nnmntry_uom               = p_rec.misc3_nnmntry_uom
    ,misc3_rndg_cd                   = p_rec.misc3_rndg_cd
    ,stat_sal_abr_id                 = p_rec.stat_sal_abr_id
    ,stat_sal_nnmntry_uom            = p_rec.stat_sal_nnmntry_uom
    ,stat_sal_rndg_cd                = p_rec.stat_sal_rndg_cd
    ,rec_abr_id                      = p_rec.rec_abr_id
    ,rec_nnmntry_uom                 = p_rec.rec_nnmntry_uom
    ,rec_rndg_cd                     = p_rec.rec_rndg_cd
    ,tot_comp_abr_id                 = p_rec.tot_comp_abr_id
    ,tot_comp_nnmntry_uom            = p_rec.tot_comp_nnmntry_uom
    ,tot_comp_rndg_cd                = p_rec.tot_comp_rndg_cd
    ,oth_comp_abr_id                 = p_rec.oth_comp_abr_id
    ,oth_comp_nnmntry_uom            = p_rec.oth_comp_nnmntry_uom
    ,oth_comp_rndg_cd                = p_rec.oth_comp_rndg_cd
    ,actual_flag                     = p_rec.actual_flag
    ,acty_ref_perd_cd                = p_rec.acty_ref_perd_cd
    ,legislation_code                = p_rec.legislation_code
    ,pl_annulization_factor          = p_rec.pl_annulization_factor
    ,pl_stat_cd                      = p_rec.pl_stat_cd
    ,uom_precision                   = p_rec.uom_precision
    ,ws_element_type_id              = p_rec.ws_element_type_id
    ,ws_input_value_id               = p_rec.ws_input_value_id
    ,data_freeze_date                = p_rec.data_freeze_date
    ,ws_amt_edit_cd                  = p_rec.ws_amt_edit_cd
    ,ws_amt_edit_enf_cd_for_nulls    = p_rec.ws_amt_edit_enf_cd_for_nulls
    ,ws_over_budget_edit_cd          = p_rec.ws_over_budget_edit_cd
    ,ws_over_budget_tolerance_pct    = p_rec.ws_over_budget_tolerance_pct
    ,bdgt_over_budget_edit_cd        = p_rec.bdgt_over_budget_edit_cd
    ,bdgt_over_budget_tolerance_pct  = p_rec.bdgt_over_budget_tolerance_pct
    ,auto_distr_flag                 = p_rec.auto_distr_flag
    ,pqh_document_short_name         = p_rec.pqh_document_short_name
    ,ovrid_rt_strt_dt                = p_rec.ovrid_rt_strt_dt
    ,do_not_process_flag             = p_rec.do_not_process_flag
    ,ovr_perf_revw_strt_dt           = p_rec.ovr_perf_revw_strt_dt
    ,object_version_number           = p_rec.object_version_number
    ,post_zero_salary_increase       = p_rec.post_zero_salary_increase
    ,show_appraisals_n_days          = p_rec.show_appraisals_n_days
    ,grade_range_validation          = p_rec.grade_range_validation
    where pl_id = p_rec.pl_id
    and lf_evt_ocrd_dt = p_rec.lf_evt_ocrd_dt
    and oipl_id = p_rec.oipl_id;
  --
  ben_cpd_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    ben_cpd_shd.g_api_dml := false;   -- Unset the api dml status
    ben_cpd_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    ben_cpd_shd.g_api_dml := false;   -- Unset the api dml status
    ben_cpd_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    ben_cpd_shd.g_api_dml := false;   -- Unset the api dml status
    ben_cpd_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    ben_cpd_shd.g_api_dml := false;   -- Unset the api dml status
    Raise;
End update_dml;
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
--   A Pl/Sql record structure.
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   If an error has occurred, an error message and exception wil be raised
--   but not handled.
--
-- Developer Implementation Notes:
--   Any pre-processing required before the update dml is issued should be
--   coded within this procedure. It is important to note that any 3rd party
--   maintenance should be reviewed before placing in this procedure.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure pre_update
  (p_rec in ben_cpd_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'pre_update';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
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
--   This private procedure contains any processing which is required after
--   the update dml.
--
-- Prerequisites:
--   This is an internal procedure which is called from the upd procedure.
--
-- In Parameters:
--   A Pl/Sql record structure.
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
  (p_rec                          in ben_cpd_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'post_update';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  begin
    --
    ben_cpd_rku.after_update
      (p_pl_id
      => p_rec.pl_id
      ,p_lf_evt_ocrd_dt
      => p_rec.lf_evt_ocrd_dt
      ,p_oipl_id
      => p_rec.oipl_id
      ,p_effective_date
      => p_rec.effective_date
      ,p_name
      => p_rec.name
      ,p_group_pl_id
      => p_rec.group_pl_id
      ,p_group_oipl_id
      => p_rec.group_oipl_id
      ,p_opt_hidden_flag
      => p_rec.opt_hidden_flag
      ,p_opt_id
      => p_rec.opt_id
      ,p_pl_uom
      => p_rec.pl_uom
      ,p_pl_ordr_num
      => p_rec.pl_ordr_num
      ,p_oipl_ordr_num
      => p_rec.oipl_ordr_num
      ,p_pl_xchg_rate
      => p_rec.pl_xchg_rate
      ,p_opt_count
      => p_rec.opt_count
      ,p_uses_bdgt_flag
      => p_rec.uses_bdgt_flag
      ,p_prsrv_bdgt_cd
      => p_rec.prsrv_bdgt_cd
      ,p_upd_start_dt
      => p_rec.upd_start_dt
      ,p_upd_end_dt
      => p_rec.upd_end_dt
      ,p_approval_mode
      => p_rec.approval_mode
      ,p_enrt_perd_start_dt
      => p_rec.enrt_perd_start_dt
      ,p_enrt_perd_end_dt
      => p_rec.enrt_perd_end_dt
      ,p_yr_perd_start_dt
      => p_rec.yr_perd_start_dt
      ,p_yr_perd_end_dt
      => p_rec.yr_perd_end_dt
      ,p_wthn_yr_start_dt
      => p_rec.wthn_yr_start_dt
      ,p_wthn_yr_end_dt
      => p_rec.wthn_yr_end_dt
      ,p_enrt_perd_id
      => p_rec.enrt_perd_id
      ,p_yr_perd_id
      => p_rec.yr_perd_id
      ,p_business_group_id
      => p_rec.business_group_id
      ,p_perf_revw_strt_dt
      => p_rec.perf_revw_strt_dt
      ,p_asg_updt_eff_date
      => p_rec.asg_updt_eff_date
      ,p_emp_interview_typ_cd
      => p_rec.emp_interview_typ_cd
      ,p_salary_change_reason
      => p_rec.salary_change_reason
      ,p_ws_abr_id
      => p_rec.ws_abr_id
      ,p_ws_nnmntry_uom
      => p_rec.ws_nnmntry_uom
      ,p_ws_rndg_cd
      => p_rec.ws_rndg_cd
      ,p_ws_sub_acty_typ_cd
      => p_rec.ws_sub_acty_typ_cd
      ,p_dist_bdgt_abr_id
      => p_rec.dist_bdgt_abr_id
      ,p_dist_bdgt_nnmntry_uom
      => p_rec.dist_bdgt_nnmntry_uom
      ,p_dist_bdgt_rndg_cd
      => p_rec.dist_bdgt_rndg_cd
      ,p_ws_bdgt_abr_id
      => p_rec.ws_bdgt_abr_id
      ,p_ws_bdgt_nnmntry_uom
      => p_rec.ws_bdgt_nnmntry_uom
      ,p_ws_bdgt_rndg_cd
      => p_rec.ws_bdgt_rndg_cd
      ,p_rsrv_abr_id
      => p_rec.rsrv_abr_id
      ,p_rsrv_nnmntry_uom
      => p_rec.rsrv_nnmntry_uom
      ,p_rsrv_rndg_cd
      => p_rec.rsrv_rndg_cd
      ,p_elig_sal_abr_id
      => p_rec.elig_sal_abr_id
      ,p_elig_sal_nnmntry_uom
      => p_rec.elig_sal_nnmntry_uom
      ,p_elig_sal_rndg_cd
      => p_rec.elig_sal_rndg_cd
      ,p_misc1_abr_id
      => p_rec.misc1_abr_id
      ,p_misc1_nnmntry_uom
      => p_rec.misc1_nnmntry_uom
      ,p_misc1_rndg_cd
      => p_rec.misc1_rndg_cd
      ,p_misc2_abr_id
      => p_rec.misc2_abr_id
      ,p_misc2_nnmntry_uom
      => p_rec.misc2_nnmntry_uom
      ,p_misc2_rndg_cd
      => p_rec.misc2_rndg_cd
      ,p_misc3_abr_id
      => p_rec.misc3_abr_id
      ,p_misc3_nnmntry_uom
      => p_rec.misc3_nnmntry_uom
      ,p_misc3_rndg_cd
      => p_rec.misc3_rndg_cd
      ,p_stat_sal_abr_id
      => p_rec.stat_sal_abr_id
      ,p_stat_sal_nnmntry_uom
      => p_rec.stat_sal_nnmntry_uom
      ,p_stat_sal_rndg_cd
      => p_rec.stat_sal_rndg_cd
      ,p_rec_abr_id
      => p_rec.rec_abr_id
      ,p_rec_nnmntry_uom
      => p_rec.rec_nnmntry_uom
      ,p_rec_rndg_cd
      => p_rec.rec_rndg_cd
      ,p_tot_comp_abr_id
      => p_rec.tot_comp_abr_id
      ,p_tot_comp_nnmntry_uom
      => p_rec.tot_comp_nnmntry_uom
      ,p_tot_comp_rndg_cd
      => p_rec.tot_comp_rndg_cd
      ,p_oth_comp_abr_id
      => p_rec.oth_comp_abr_id
      ,p_oth_comp_nnmntry_uom
      => p_rec.oth_comp_nnmntry_uom
      ,p_oth_comp_rndg_cd
      => p_rec.oth_comp_rndg_cd
      ,p_actual_flag
      => p_rec.actual_flag
      ,p_acty_ref_perd_cd
      => p_rec.acty_ref_perd_cd
      ,p_legislation_code
      => p_rec.legislation_code
      ,p_pl_annulization_factor
      => p_rec.pl_annulization_factor
      ,p_pl_stat_cd
      => p_rec.pl_stat_cd
      ,p_uom_precision
      => p_rec.uom_precision
      ,p_ws_element_type_id
      => p_rec.ws_element_type_id
      ,p_ws_input_value_id
      => p_rec.ws_input_value_id
      ,p_data_freeze_date
      => p_rec.data_freeze_date
      ,p_ws_amt_edit_cd
      => p_rec.ws_amt_edit_cd
      ,p_ws_amt_edit_enf_cd_for_nul
      => p_rec.ws_amt_edit_enf_cd_for_nulls
      ,p_ws_over_budget_edit_cd
      => p_rec.ws_over_budget_edit_cd
      ,p_ws_over_budget_tol_pct
      => p_rec.ws_over_budget_tolerance_pct
      ,p_bdgt_over_budget_edit_cd
      => p_rec.bdgt_over_budget_edit_cd
      ,p_bdgt_over_budget_tol_pct
      => p_rec.bdgt_over_budget_tolerance_pct
      ,p_auto_distr_flag
      => p_rec.auto_distr_flag
      ,p_pqh_document_short_name
      => p_rec.pqh_document_short_name
      ,p_ovrid_rt_strt_dt
      => p_rec.ovrid_rt_strt_dt
      ,p_do_not_process_flag
      => p_rec.do_not_process_flag
      ,p_ovr_perf_revw_strt_dt
      => p_rec.ovr_perf_revw_strt_dt
      ,p_post_zero_salary_increase
      => p_rec.post_zero_salary_increase
     ,p_show_appraisals_n_days
      => p_rec.show_appraisals_n_days
      ,p_grade_range_validation
      => p_rec.grade_range_validation
      ,p_object_version_number
      => p_rec.object_version_number
      ,p_effective_date_o
      => ben_cpd_shd.g_old_rec.effective_date
      ,p_name_o
      => ben_cpd_shd.g_old_rec.name
      ,p_group_pl_id_o
      => ben_cpd_shd.g_old_rec.group_pl_id
      ,p_group_oipl_id_o
      => ben_cpd_shd.g_old_rec.group_oipl_id
      ,p_opt_hidden_flag_o
      => ben_cpd_shd.g_old_rec.opt_hidden_flag
      ,p_opt_id_o
      => ben_cpd_shd.g_old_rec.opt_id
      ,p_pl_uom_o
      => ben_cpd_shd.g_old_rec.pl_uom
      ,p_pl_ordr_num_o
      => ben_cpd_shd.g_old_rec.pl_ordr_num
      ,p_oipl_ordr_num_o
      => ben_cpd_shd.g_old_rec.oipl_ordr_num
      ,p_pl_xchg_rate_o
      => ben_cpd_shd.g_old_rec.pl_xchg_rate
      ,p_opt_count_o
      => ben_cpd_shd.g_old_rec.opt_count
      ,p_uses_bdgt_flag_o
      => ben_cpd_shd.g_old_rec.uses_bdgt_flag
      ,p_prsrv_bdgt_cd_o
      => ben_cpd_shd.g_old_rec.prsrv_bdgt_cd
      ,p_upd_start_dt_o
      => ben_cpd_shd.g_old_rec.upd_start_dt
      ,p_upd_end_dt_o
      => ben_cpd_shd.g_old_rec.upd_end_dt
      ,p_approval_mode_o
      => ben_cpd_shd.g_old_rec.approval_mode
      ,p_enrt_perd_start_dt_o
      => ben_cpd_shd.g_old_rec.enrt_perd_start_dt
      ,p_enrt_perd_end_dt_o
      => ben_cpd_shd.g_old_rec.enrt_perd_end_dt
      ,p_yr_perd_start_dt_o
      => ben_cpd_shd.g_old_rec.yr_perd_start_dt
      ,p_yr_perd_end_dt_o
      => ben_cpd_shd.g_old_rec.yr_perd_end_dt
      ,p_wthn_yr_start_dt_o
      => ben_cpd_shd.g_old_rec.wthn_yr_start_dt
      ,p_wthn_yr_end_dt_o
      => ben_cpd_shd.g_old_rec.wthn_yr_end_dt
      ,p_enrt_perd_id_o
      => ben_cpd_shd.g_old_rec.enrt_perd_id
      ,p_yr_perd_id_o
      => ben_cpd_shd.g_old_rec.yr_perd_id
      ,p_business_group_id_o
      => ben_cpd_shd.g_old_rec.business_group_id
      ,p_perf_revw_strt_dt_o
      => ben_cpd_shd.g_old_rec.perf_revw_strt_dt
      ,p_asg_updt_eff_date_o
      => ben_cpd_shd.g_old_rec.asg_updt_eff_date
      ,p_emp_interview_typ_cd_o
      => ben_cpd_shd.g_old_rec.emp_interview_typ_cd
      ,p_salary_change_reason_o
      => ben_cpd_shd.g_old_rec.salary_change_reason
      ,p_ws_abr_id_o
      => ben_cpd_shd.g_old_rec.ws_abr_id
      ,p_ws_nnmntry_uom_o
      => ben_cpd_shd.g_old_rec.ws_nnmntry_uom
      ,p_ws_rndg_cd_o
      => ben_cpd_shd.g_old_rec.ws_rndg_cd
      ,p_ws_sub_acty_typ_cd_o
      => ben_cpd_shd.g_old_rec.ws_sub_acty_typ_cd
      ,p_dist_bdgt_abr_id_o
      => ben_cpd_shd.g_old_rec.dist_bdgt_abr_id
      ,p_dist_bdgt_nnmntry_uom_o
      => ben_cpd_shd.g_old_rec.dist_bdgt_nnmntry_uom
      ,p_dist_bdgt_rndg_cd_o
      => ben_cpd_shd.g_old_rec.dist_bdgt_rndg_cd
      ,p_ws_bdgt_abr_id_o
      => ben_cpd_shd.g_old_rec.ws_bdgt_abr_id
      ,p_ws_bdgt_nnmntry_uom_o
      => ben_cpd_shd.g_old_rec.ws_bdgt_nnmntry_uom
      ,p_ws_bdgt_rndg_cd_o
      => ben_cpd_shd.g_old_rec.ws_bdgt_rndg_cd
      ,p_rsrv_abr_id_o
      => ben_cpd_shd.g_old_rec.rsrv_abr_id
      ,p_rsrv_nnmntry_uom_o
      => ben_cpd_shd.g_old_rec.rsrv_nnmntry_uom
      ,p_rsrv_rndg_cd_o
      => ben_cpd_shd.g_old_rec.rsrv_rndg_cd
      ,p_elig_sal_abr_id_o
      => ben_cpd_shd.g_old_rec.elig_sal_abr_id
      ,p_elig_sal_nnmntry_uom_o
      => ben_cpd_shd.g_old_rec.elig_sal_nnmntry_uom
      ,p_elig_sal_rndg_cd_o
      => ben_cpd_shd.g_old_rec.elig_sal_rndg_cd
      ,p_misc1_abr_id_o
      => ben_cpd_shd.g_old_rec.misc1_abr_id
      ,p_misc1_nnmntry_uom_o
      => ben_cpd_shd.g_old_rec.misc1_nnmntry_uom
      ,p_misc1_rndg_cd_o
      => ben_cpd_shd.g_old_rec.misc1_rndg_cd
      ,p_misc2_abr_id_o
      => ben_cpd_shd.g_old_rec.misc2_abr_id
      ,p_misc2_nnmntry_uom_o
      => ben_cpd_shd.g_old_rec.misc2_nnmntry_uom
      ,p_misc2_rndg_cd_o
      => ben_cpd_shd.g_old_rec.misc2_rndg_cd
      ,p_misc3_abr_id_o
      => ben_cpd_shd.g_old_rec.misc3_abr_id
      ,p_misc3_nnmntry_uom_o
      => ben_cpd_shd.g_old_rec.misc3_nnmntry_uom
      ,p_misc3_rndg_cd_o
      => ben_cpd_shd.g_old_rec.misc3_rndg_cd
      ,p_stat_sal_abr_id_o
      => ben_cpd_shd.g_old_rec.stat_sal_abr_id
      ,p_stat_sal_nnmntry_uom_o
      => ben_cpd_shd.g_old_rec.stat_sal_nnmntry_uom
      ,p_stat_sal_rndg_cd_o
      => ben_cpd_shd.g_old_rec.stat_sal_rndg_cd
      ,p_rec_abr_id_o
      => ben_cpd_shd.g_old_rec.rec_abr_id
      ,p_rec_nnmntry_uom_o
      => ben_cpd_shd.g_old_rec.rec_nnmntry_uom
      ,p_rec_rndg_cd_o
      => ben_cpd_shd.g_old_rec.rec_rndg_cd
      ,p_tot_comp_abr_id_o
      => ben_cpd_shd.g_old_rec.tot_comp_abr_id
      ,p_tot_comp_nnmntry_uom_o
      => ben_cpd_shd.g_old_rec.tot_comp_nnmntry_uom
      ,p_tot_comp_rndg_cd_o
      => ben_cpd_shd.g_old_rec.tot_comp_rndg_cd
      ,p_oth_comp_abr_id_o
      => ben_cpd_shd.g_old_rec.oth_comp_abr_id
      ,p_oth_comp_nnmntry_uom_o
      => ben_cpd_shd.g_old_rec.oth_comp_nnmntry_uom
      ,p_oth_comp_rndg_cd_o
      => ben_cpd_shd.g_old_rec.oth_comp_rndg_cd
      ,p_actual_flag_o
      => ben_cpd_shd.g_old_rec.actual_flag
      ,p_acty_ref_perd_cd_o
      => ben_cpd_shd.g_old_rec.acty_ref_perd_cd
      ,p_legislation_code_o
      => ben_cpd_shd.g_old_rec.legislation_code
      ,p_pl_annulization_factor_o
      => ben_cpd_shd.g_old_rec.pl_annulization_factor
      ,p_pl_stat_cd_o
      => ben_cpd_shd.g_old_rec.pl_stat_cd
      ,p_uom_precision_o
      => ben_cpd_shd.g_old_rec.uom_precision
      ,p_ws_element_type_id_o
      => ben_cpd_shd.g_old_rec.ws_element_type_id
      ,p_ws_input_value_id_o
      => ben_cpd_shd.g_old_rec.ws_input_value_id
      ,p_data_freeze_date_o
      => ben_cpd_shd.g_old_rec.data_freeze_date
      ,p_ws_amt_edit_cd_o
      => ben_cpd_shd.g_old_rec.ws_amt_edit_cd
      ,p_ws_amt_edit_enf_cd_for_nul_o
      => ben_cpd_shd.g_old_rec.ws_amt_edit_enf_cd_for_nulls
      ,p_ws_over_budget_edit_cd_o
      => ben_cpd_shd.g_old_rec.ws_over_budget_edit_cd
      ,p_ws_over_budget_tol_pct_o
      => ben_cpd_shd.g_old_rec.ws_over_budget_tolerance_pct
      ,p_bdgt_over_budget_edit_cd_o
      => ben_cpd_shd.g_old_rec.bdgt_over_budget_edit_cd
      ,p_bdgt_over_budget_tol_pct_o
      => ben_cpd_shd.g_old_rec.bdgt_over_budget_tolerance_pct
      ,p_auto_distr_flag_o
      => ben_cpd_shd.g_old_rec.auto_distr_flag
      ,p_pqh_document_short_name_o
      => ben_cpd_shd.g_old_rec.pqh_document_short_name
      ,p_ovrid_rt_strt_dt_o
      => ben_cpd_shd.g_old_rec.ovrid_rt_strt_dt
      ,p_do_not_process_flag_o
      => ben_cpd_shd.g_old_rec.do_not_process_flag
      ,p_ovr_perf_revw_strt_dt_o
      => ben_cpd_shd.g_old_rec.ovr_perf_revw_strt_dt
      ,p_post_zero_salary_increase_o
      => ben_cpd_shd.g_old_rec.post_zero_salary_increase
     ,p_show_appraisals_n_days_o
      => ben_cpd_shd.g_old_rec.show_appraisals_n_days
      ,p_grade_range_validation_o
      => ben_cpd_shd.g_old_rec.grade_range_validation
      ,p_object_version_number_o
      => ben_cpd_shd.g_old_rec.object_version_number
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'BEN_CWB_PL_DSGN'
        ,p_hook_type   => 'AU');
      --
  end;
  --
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
--   A Pl/Sql record structure.
--
-- Post Success:
--   The record structure will be returned with all system defaulted parameter
--   values converted into its current row attribute value.
--
-- Post Failure:
--   No direct error handling is required within this function. Any possible
--   errors within this procedure will be a PL/SQL value error due to
--   conversion of datatypes or data lengths.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure convert_defs
  (p_rec in out nocopy ben_cpd_shd.g_rec_type
  ) is
--
Begin
  --
  -- We must now examine each argument value in the
  -- p_rec plsql record structure
  -- to see if a system default is being used. If a system default
  -- is being used then we must set to the 'current' argument value.
  --
  If (p_rec.effective_date = hr_api.g_date) then
    p_rec.effective_date :=
    ben_cpd_shd.g_old_rec.effective_date;
  End If;
  If (p_rec.name = hr_api.g_varchar2) then
    p_rec.name :=
    ben_cpd_shd.g_old_rec.name;
  End If;
  If (p_rec.group_pl_id = hr_api.g_number) then
    p_rec.group_pl_id :=
    ben_cpd_shd.g_old_rec.group_pl_id;
  End If;
  If (p_rec.group_oipl_id = hr_api.g_number) then
    p_rec.group_oipl_id :=
    ben_cpd_shd.g_old_rec.group_oipl_id;
  End If;
  If (p_rec.opt_hidden_flag = hr_api.g_varchar2) then
    p_rec.opt_hidden_flag :=
    ben_cpd_shd.g_old_rec.opt_hidden_flag;
  End If;
  If (p_rec.opt_id = hr_api.g_number) then
    p_rec.opt_id :=
    ben_cpd_shd.g_old_rec.opt_id;
  End If;
  If (p_rec.pl_uom = hr_api.g_varchar2) then
    p_rec.pl_uom :=
    ben_cpd_shd.g_old_rec.pl_uom;
  End If;
  If (p_rec.pl_ordr_num = hr_api.g_number) then
    p_rec.pl_ordr_num :=
    ben_cpd_shd.g_old_rec.pl_ordr_num;
  End If;
  If (p_rec.oipl_ordr_num = hr_api.g_number) then
    p_rec.oipl_ordr_num :=
    ben_cpd_shd.g_old_rec.oipl_ordr_num;
  End If;
  If (p_rec.pl_xchg_rate = hr_api.g_number) then
    p_rec.pl_xchg_rate :=
    ben_cpd_shd.g_old_rec.pl_xchg_rate;
  End If;
  If (p_rec.opt_count = hr_api.g_number) then
    p_rec.opt_count :=
    ben_cpd_shd.g_old_rec.opt_count;
  End If;
  If (p_rec.uses_bdgt_flag = hr_api.g_varchar2) then
    p_rec.uses_bdgt_flag :=
    ben_cpd_shd.g_old_rec.uses_bdgt_flag;
  End If;
  If (p_rec.prsrv_bdgt_cd = hr_api.g_varchar2) then
    p_rec.prsrv_bdgt_cd :=
    ben_cpd_shd.g_old_rec.prsrv_bdgt_cd;
  End If;
  If (p_rec.upd_start_dt = hr_api.g_date) then
    p_rec.upd_start_dt :=
    ben_cpd_shd.g_old_rec.upd_start_dt;
  End If;
  If (p_rec.upd_end_dt = hr_api.g_date) then
    p_rec.upd_end_dt :=
    ben_cpd_shd.g_old_rec.upd_end_dt;
  End If;
  If (p_rec.approval_mode = hr_api.g_varchar2) then
    p_rec.approval_mode :=
    ben_cpd_shd.g_old_rec.approval_mode;
  End If;
  If (p_rec.enrt_perd_start_dt = hr_api.g_date) then
    p_rec.enrt_perd_start_dt :=
    ben_cpd_shd.g_old_rec.enrt_perd_start_dt;
  End If;
  If (p_rec.enrt_perd_end_dt = hr_api.g_date) then
    p_rec.enrt_perd_end_dt :=
    ben_cpd_shd.g_old_rec.enrt_perd_end_dt;
  End If;
  If (p_rec.yr_perd_start_dt = hr_api.g_date) then
    p_rec.yr_perd_start_dt :=
    ben_cpd_shd.g_old_rec.yr_perd_start_dt;
  End If;
  If (p_rec.yr_perd_end_dt = hr_api.g_date) then
    p_rec.yr_perd_end_dt :=
    ben_cpd_shd.g_old_rec.yr_perd_end_dt;
  End If;
  If (p_rec.wthn_yr_start_dt = hr_api.g_date) then
    p_rec.wthn_yr_start_dt :=
    ben_cpd_shd.g_old_rec.wthn_yr_start_dt;
  End If;
  If (p_rec.wthn_yr_end_dt = hr_api.g_date) then
    p_rec.wthn_yr_end_dt :=
    ben_cpd_shd.g_old_rec.wthn_yr_end_dt;
  End If;
  If (p_rec.enrt_perd_id = hr_api.g_number) then
    p_rec.enrt_perd_id :=
    ben_cpd_shd.g_old_rec.enrt_perd_id;
  End If;
  If (p_rec.yr_perd_id = hr_api.g_number) then
    p_rec.yr_perd_id :=
    ben_cpd_shd.g_old_rec.yr_perd_id;
  End If;
  If (p_rec.business_group_id = hr_api.g_number) then
    p_rec.business_group_id :=
    ben_cpd_shd.g_old_rec.business_group_id;
  End If;
  If (p_rec.perf_revw_strt_dt = hr_api.g_date) then
    p_rec.perf_revw_strt_dt :=
    ben_cpd_shd.g_old_rec.perf_revw_strt_dt;
  End If;
  If (p_rec.asg_updt_eff_date = hr_api.g_date) then
    p_rec.asg_updt_eff_date :=
    ben_cpd_shd.g_old_rec.asg_updt_eff_date;
  End If;
  If (p_rec.emp_interview_typ_cd = hr_api.g_varchar2) then
    p_rec.emp_interview_typ_cd :=
    ben_cpd_shd.g_old_rec.emp_interview_typ_cd;
  End If;
  If (p_rec.salary_change_reason = hr_api.g_varchar2) then
    p_rec.salary_change_reason :=
    ben_cpd_shd.g_old_rec.salary_change_reason;
  End If;
  If (p_rec.ws_abr_id = hr_api.g_number) then
    p_rec.ws_abr_id :=
    ben_cpd_shd.g_old_rec.ws_abr_id;
  End If;
  If (p_rec.ws_nnmntry_uom = hr_api.g_varchar2) then
    p_rec.ws_nnmntry_uom :=
    ben_cpd_shd.g_old_rec.ws_nnmntry_uom;
  End If;
  If (p_rec.ws_rndg_cd = hr_api.g_varchar2) then
    p_rec.ws_rndg_cd :=
    ben_cpd_shd.g_old_rec.ws_rndg_cd;
  End If;
  If (p_rec.ws_sub_acty_typ_cd = hr_api.g_varchar2) then
    p_rec.ws_sub_acty_typ_cd :=
    ben_cpd_shd.g_old_rec.ws_sub_acty_typ_cd;
  End If;
  If (p_rec.dist_bdgt_abr_id = hr_api.g_number) then
    p_rec.dist_bdgt_abr_id :=
    ben_cpd_shd.g_old_rec.dist_bdgt_abr_id;
  End If;
  If (p_rec.dist_bdgt_nnmntry_uom = hr_api.g_varchar2) then
    p_rec.dist_bdgt_nnmntry_uom :=
    ben_cpd_shd.g_old_rec.dist_bdgt_nnmntry_uom;
  End If;
  If (p_rec.dist_bdgt_rndg_cd = hr_api.g_varchar2) then
    p_rec.dist_bdgt_rndg_cd :=
    ben_cpd_shd.g_old_rec.dist_bdgt_rndg_cd;
  End If;
  If (p_rec.ws_bdgt_abr_id = hr_api.g_number) then
    p_rec.ws_bdgt_abr_id :=
    ben_cpd_shd.g_old_rec.ws_bdgt_abr_id;
  End If;
  If (p_rec.ws_bdgt_nnmntry_uom = hr_api.g_varchar2) then
    p_rec.ws_bdgt_nnmntry_uom :=
    ben_cpd_shd.g_old_rec.ws_bdgt_nnmntry_uom;
  End If;
  If (p_rec.ws_bdgt_rndg_cd = hr_api.g_varchar2) then
    p_rec.ws_bdgt_rndg_cd :=
    ben_cpd_shd.g_old_rec.ws_bdgt_rndg_cd;
  End If;
  If (p_rec.rsrv_abr_id = hr_api.g_number) then
    p_rec.rsrv_abr_id :=
    ben_cpd_shd.g_old_rec.rsrv_abr_id;
  End If;
  If (p_rec.rsrv_nnmntry_uom = hr_api.g_varchar2) then
    p_rec.rsrv_nnmntry_uom :=
    ben_cpd_shd.g_old_rec.rsrv_nnmntry_uom;
  End If;
  If (p_rec.rsrv_rndg_cd = hr_api.g_varchar2) then
    p_rec.rsrv_rndg_cd :=
    ben_cpd_shd.g_old_rec.rsrv_rndg_cd;
  End If;
  If (p_rec.elig_sal_abr_id = hr_api.g_number) then
    p_rec.elig_sal_abr_id :=
    ben_cpd_shd.g_old_rec.elig_sal_abr_id;
  End If;
  If (p_rec.elig_sal_nnmntry_uom = hr_api.g_varchar2) then
    p_rec.elig_sal_nnmntry_uom :=
    ben_cpd_shd.g_old_rec.elig_sal_nnmntry_uom;
  End If;
  If (p_rec.elig_sal_rndg_cd = hr_api.g_varchar2) then
    p_rec.elig_sal_rndg_cd :=
    ben_cpd_shd.g_old_rec.elig_sal_rndg_cd;
  End If;
  If (p_rec.misc1_abr_id = hr_api.g_number) then
    p_rec.misc1_abr_id :=
    ben_cpd_shd.g_old_rec.misc1_abr_id;
  End If;
  If (p_rec.misc1_nnmntry_uom = hr_api.g_varchar2) then
    p_rec.misc1_nnmntry_uom :=
    ben_cpd_shd.g_old_rec.misc1_nnmntry_uom;
  End If;
  If (p_rec.misc1_rndg_cd = hr_api.g_varchar2) then
    p_rec.misc1_rndg_cd :=
    ben_cpd_shd.g_old_rec.misc1_rndg_cd;
  End If;
  If (p_rec.misc2_abr_id = hr_api.g_number) then
    p_rec.misc2_abr_id :=
    ben_cpd_shd.g_old_rec.misc2_abr_id;
  End If;
  If (p_rec.misc2_nnmntry_uom = hr_api.g_varchar2) then
    p_rec.misc2_nnmntry_uom :=
    ben_cpd_shd.g_old_rec.misc2_nnmntry_uom;
  End If;
  If (p_rec.misc2_rndg_cd = hr_api.g_varchar2) then
    p_rec.misc2_rndg_cd :=
    ben_cpd_shd.g_old_rec.misc2_rndg_cd;
  End If;
  If (p_rec.misc3_abr_id = hr_api.g_number) then
    p_rec.misc3_abr_id :=
    ben_cpd_shd.g_old_rec.misc3_abr_id;
  End If;
  If (p_rec.misc3_nnmntry_uom = hr_api.g_varchar2) then
    p_rec.misc3_nnmntry_uom :=
    ben_cpd_shd.g_old_rec.misc3_nnmntry_uom;
  End If;
  If (p_rec.misc3_rndg_cd = hr_api.g_varchar2) then
    p_rec.misc3_rndg_cd :=
    ben_cpd_shd.g_old_rec.misc3_rndg_cd;
  End If;
  If (p_rec.stat_sal_abr_id = hr_api.g_number) then
    p_rec.stat_sal_abr_id :=
    ben_cpd_shd.g_old_rec.stat_sal_abr_id;
  End If;
  If (p_rec.stat_sal_nnmntry_uom = hr_api.g_varchar2) then
    p_rec.stat_sal_nnmntry_uom :=
    ben_cpd_shd.g_old_rec.stat_sal_nnmntry_uom;
  End If;
  If (p_rec.stat_sal_rndg_cd = hr_api.g_varchar2) then
    p_rec.stat_sal_rndg_cd :=
    ben_cpd_shd.g_old_rec.stat_sal_rndg_cd;
  End If;
  If (p_rec.rec_abr_id = hr_api.g_number) then
    p_rec.rec_abr_id :=
    ben_cpd_shd.g_old_rec.rec_abr_id;
  End If;
  If (p_rec.rec_nnmntry_uom = hr_api.g_varchar2) then
    p_rec.rec_nnmntry_uom :=
    ben_cpd_shd.g_old_rec.rec_nnmntry_uom;
  End If;
  If (p_rec.rec_rndg_cd = hr_api.g_varchar2) then
    p_rec.rec_rndg_cd :=
    ben_cpd_shd.g_old_rec.rec_rndg_cd;
  End If;
  If (p_rec.tot_comp_abr_id = hr_api.g_number) then
    p_rec.tot_comp_abr_id :=
    ben_cpd_shd.g_old_rec.tot_comp_abr_id;
  End If;
  If (p_rec.tot_comp_nnmntry_uom = hr_api.g_varchar2) then
    p_rec.tot_comp_nnmntry_uom :=
    ben_cpd_shd.g_old_rec.tot_comp_nnmntry_uom;
  End If;
  If (p_rec.tot_comp_rndg_cd = hr_api.g_varchar2) then
    p_rec.tot_comp_rndg_cd :=
    ben_cpd_shd.g_old_rec.tot_comp_rndg_cd;
  End If;
  If (p_rec.oth_comp_abr_id = hr_api.g_number) then
    p_rec.oth_comp_abr_id :=
    ben_cpd_shd.g_old_rec.oth_comp_abr_id;
  End If;
  If (p_rec.oth_comp_nnmntry_uom = hr_api.g_varchar2) then
    p_rec.oth_comp_nnmntry_uom :=
    ben_cpd_shd.g_old_rec.oth_comp_nnmntry_uom;
  End If;
  If (p_rec.oth_comp_rndg_cd = hr_api.g_varchar2) then
    p_rec.oth_comp_rndg_cd :=
    ben_cpd_shd.g_old_rec.oth_comp_rndg_cd;
  End If;
  If (p_rec.actual_flag = hr_api.g_varchar2) then
    p_rec.actual_flag :=
    ben_cpd_shd.g_old_rec.actual_flag;
  End If;
  If (p_rec.acty_ref_perd_cd = hr_api.g_varchar2) then
    p_rec.acty_ref_perd_cd :=
    ben_cpd_shd.g_old_rec.acty_ref_perd_cd;
  End If;
  If (p_rec.legislation_code = hr_api.g_varchar2) then
    p_rec.legislation_code :=
    ben_cpd_shd.g_old_rec.legislation_code;
  End If;
  If (p_rec.pl_annulization_factor = hr_api.g_number) then
    p_rec.pl_annulization_factor :=
    ben_cpd_shd.g_old_rec.pl_annulization_factor;
  End If;
  If (p_rec.pl_stat_cd = hr_api.g_varchar2) then
    p_rec.pl_stat_cd :=
    ben_cpd_shd.g_old_rec.pl_stat_cd;
  End If;
  If (p_rec.uom_precision = hr_api.g_number) then
    p_rec.uom_precision :=
    ben_cpd_shd.g_old_rec.uom_precision;
  End If;
  If (p_rec.ws_element_type_id = hr_api.g_number) then
    p_rec.ws_element_type_id :=
    ben_cpd_shd.g_old_rec.ws_element_type_id;
  End If;
  If (p_rec.ws_input_value_id = hr_api.g_number) then
    p_rec.ws_input_value_id :=
    ben_cpd_shd.g_old_rec.ws_input_value_id;
  End if;
  If (p_rec.data_freeze_date = hr_api.g_date) then
    p_rec.data_freeze_date :=
    ben_cpd_shd.g_old_rec.data_freeze_date;
  End If;
  If (p_rec.ws_amt_edit_cd = hr_api.g_varchar2) then
    p_rec.ws_amt_edit_cd :=
    ben_cpd_shd.g_old_rec.ws_amt_edit_cd;
  End If;
  If (p_rec.ws_amt_edit_enf_cd_for_nulls = hr_api.g_varchar2) then
    p_rec.ws_amt_edit_enf_cd_for_nulls :=
    ben_cpd_shd.g_old_rec.ws_amt_edit_enf_cd_for_nulls;
  End If;
  If (p_rec.ws_over_budget_edit_cd = hr_api.g_varchar2) then
    p_rec.ws_over_budget_edit_cd :=
    ben_cpd_shd.g_old_rec.ws_over_budget_edit_cd;
  End If;
  If (p_rec.ws_over_budget_tolerance_pct = hr_api.g_number) then
    p_rec.ws_over_budget_tolerance_pct :=
    ben_cpd_shd.g_old_rec.ws_over_budget_tolerance_pct;
  End If;
  If (p_rec.bdgt_over_budget_edit_cd = hr_api.g_varchar2) then
    p_rec.bdgt_over_budget_edit_cd :=
    ben_cpd_shd.g_old_rec.bdgt_over_budget_edit_cd;
  End If;
  If (p_rec.bdgt_over_budget_tolerance_pct = hr_api.g_number) then
    p_rec.bdgt_over_budget_tolerance_pct :=
    ben_cpd_shd.g_old_rec.bdgt_over_budget_tolerance_pct;
  End If;
  If (p_rec.auto_distr_flag = hr_api.g_varchar2) then
    p_rec.auto_distr_flag :=
    ben_cpd_shd.g_old_rec.auto_distr_flag;
  End If;
  If (p_rec.pqh_document_short_name = hr_api.g_varchar2) then
    p_rec.pqh_document_short_name :=
    ben_cpd_shd.g_old_rec.pqh_document_short_name;
  End If;
  If (p_rec.ovrid_rt_strt_dt = hr_api.g_date) then
    p_rec.ovrid_rt_strt_dt :=
    ben_cpd_shd.g_old_rec.ovrid_rt_strt_dt;
  End If;
  If (p_rec.do_not_process_flag = hr_api.g_varchar2) then
    p_rec.do_not_process_flag :=
    ben_cpd_shd.g_old_rec.do_not_process_flag;
  End If;
  If (p_rec.ovr_perf_revw_strt_dt = hr_api.g_date) then
    p_rec.ovr_perf_revw_strt_dt :=
    ben_cpd_shd.g_old_rec.ovr_perf_revw_strt_dt;
  End If;
  If (p_rec.post_zero_salary_increase = hr_api.g_varchar2) then
    p_rec.post_zero_salary_increase :=
    ben_cpd_shd.g_old_rec.post_zero_salary_increase;
  End If;
  If (p_rec.show_appraisals_n_days = hr_api.g_number) then
    p_rec.show_appraisals_n_days :=
    ben_cpd_shd.g_old_rec.show_appraisals_n_days;
  End If;
  If (p_rec.grade_range_validation = hr_api.g_varchar2) then
    p_rec.grade_range_validation :=
    ben_cpd_shd.g_old_rec.grade_range_validation;
  End If;
  --
End convert_defs;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (p_rec                          in out nocopy ben_cpd_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to update.
  --
  ben_cpd_shd.lck
    (p_rec.pl_id
    ,p_rec.lf_evt_ocrd_dt
    ,p_rec.oipl_id
    ,p_rec.object_version_number
    );
  --
  -- 1. During an update system defaults are used to determine if
  --    arguments have been defaulted or not. We must therefore
  --    derive the full record structure values to be updated.
  --
  -- 2. Call the supporting update validate operations.
  --
  convert_defs(p_rec);
  ben_cpd_bus.update_validate
     (p_rec
     );
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
  -- Call the supporting pre-update operation
  --
  ben_cpd_upd.pre_update(p_rec);
  --
  -- Update the row.
  --
  ben_cpd_upd.update_dml(p_rec);
  --
  -- Call the supporting post-update operation
  --
  ben_cpd_upd.post_update
     (p_rec
     );
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
End upd;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (p_pl_id                          in     number
  ,p_oipl_id                        in     number
  ,p_lf_evt_ocrd_dt                 in     date
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in     date      default hr_api.g_date
  ,p_name                           in     varchar2  default hr_api.g_varchar2
  ,p_group_pl_id                    in     number    default hr_api.g_number
  ,p_group_oipl_id                  in     number    default hr_api.g_number
  ,p_opt_hidden_flag                in     varchar2  default hr_api.g_varchar2
  ,p_opt_id                         in     number    default hr_api.g_number
  ,p_pl_uom                         in     varchar2  default hr_api.g_varchar2
  ,p_pl_ordr_num                    in     number    default hr_api.g_number
  ,p_oipl_ordr_num                  in     number    default hr_api.g_number
  ,p_pl_xchg_rate                   in     number    default hr_api.g_number
  ,p_opt_count                      in     number    default hr_api.g_number
  ,p_uses_bdgt_flag                 in     varchar2  default hr_api.g_varchar2
  ,p_prsrv_bdgt_cd                  in     varchar2  default hr_api.g_varchar2
  ,p_upd_start_dt                   in     date      default hr_api.g_date
  ,p_upd_end_dt                     in     date      default hr_api.g_date
  ,p_approval_mode                  in     varchar2  default hr_api.g_varchar2
  ,p_enrt_perd_start_dt             in     date      default hr_api.g_date
  ,p_enrt_perd_end_dt               in     date      default hr_api.g_date
  ,p_yr_perd_start_dt               in     date      default hr_api.g_date
  ,p_yr_perd_end_dt                 in     date      default hr_api.g_date
  ,p_wthn_yr_start_dt               in     date      default hr_api.g_date
  ,p_wthn_yr_end_dt                 in     date      default hr_api.g_date
  ,p_enrt_perd_id                   in     number    default hr_api.g_number
  ,p_yr_perd_id                     in     number    default hr_api.g_number
  ,p_business_group_id              in     number    default hr_api.g_number
  ,p_perf_revw_strt_dt              in     date      default hr_api.g_date
  ,p_asg_updt_eff_date              in     date      default hr_api.g_date
  ,p_emp_interview_typ_cd           in     varchar2  default hr_api.g_varchar2
  ,p_salary_change_reason           in     varchar2  default hr_api.g_varchar2
  ,p_ws_abr_id                      in     number    default hr_api.g_number
  ,p_ws_nnmntry_uom                 in     varchar2  default hr_api.g_varchar2
  ,p_ws_rndg_cd                     in     varchar2  default hr_api.g_varchar2
  ,p_ws_sub_acty_typ_cd             in     varchar2  default hr_api.g_varchar2
  ,p_dist_bdgt_abr_id               in     number    default hr_api.g_number
  ,p_dist_bdgt_nnmntry_uom          in     varchar2  default hr_api.g_varchar2
  ,p_dist_bdgt_rndg_cd              in     varchar2  default hr_api.g_varchar2
  ,p_ws_bdgt_abr_id                 in     number    default hr_api.g_number
  ,p_ws_bdgt_nnmntry_uom            in     varchar2  default hr_api.g_varchar2
  ,p_ws_bdgt_rndg_cd                in     varchar2  default hr_api.g_varchar2
  ,p_rsrv_abr_id                    in     number    default hr_api.g_number
  ,p_rsrv_nnmntry_uom               in     varchar2  default hr_api.g_varchar2
  ,p_rsrv_rndg_cd                   in     varchar2  default hr_api.g_varchar2
  ,p_elig_sal_abr_id                in     number    default hr_api.g_number
  ,p_elig_sal_nnmntry_uom           in     varchar2  default hr_api.g_varchar2
  ,p_elig_sal_rndg_cd               in     varchar2  default hr_api.g_varchar2
  ,p_misc1_abr_id                   in     number    default hr_api.g_number
  ,p_misc1_nnmntry_uom              in     varchar2  default hr_api.g_varchar2
  ,p_misc1_rndg_cd                  in     varchar2  default hr_api.g_varchar2
  ,p_misc2_abr_id                   in     number    default hr_api.g_number
  ,p_misc2_nnmntry_uom              in     varchar2  default hr_api.g_varchar2
  ,p_misc2_rndg_cd                  in     varchar2  default hr_api.g_varchar2
  ,p_misc3_abr_id                   in     number    default hr_api.g_number
  ,p_misc3_nnmntry_uom              in     varchar2  default hr_api.g_varchar2
  ,p_misc3_rndg_cd                  in     varchar2  default hr_api.g_varchar2
  ,p_stat_sal_abr_id                in     number    default hr_api.g_number
  ,p_stat_sal_nnmntry_uom           in     varchar2  default hr_api.g_varchar2
  ,p_stat_sal_rndg_cd               in     varchar2  default hr_api.g_varchar2
  ,p_rec_abr_id                     in     number    default hr_api.g_number
  ,p_rec_nnmntry_uom                in     varchar2  default hr_api.g_varchar2
  ,p_rec_rndg_cd                    in     varchar2  default hr_api.g_varchar2
  ,p_tot_comp_abr_id                in     number    default hr_api.g_number
  ,p_tot_comp_nnmntry_uom           in     varchar2  default hr_api.g_varchar2
  ,p_tot_comp_rndg_cd               in     varchar2  default hr_api.g_varchar2
  ,p_oth_comp_abr_id                in     number    default hr_api.g_number
  ,p_oth_comp_nnmntry_uom           in     varchar2  default hr_api.g_varchar2
  ,p_oth_comp_rndg_cd               in     varchar2  default hr_api.g_varchar2
  ,p_actual_flag                    in     varchar2  default hr_api.g_varchar2
  ,p_acty_ref_perd_cd               in     varchar2  default hr_api.g_varchar2
  ,p_legislation_code               in     varchar2  default hr_api.g_varchar2
  ,p_pl_annulization_factor         in     number    default hr_api.g_number
  ,p_pl_stat_cd                     in     varchar2  default hr_api.g_varchar2
  ,p_uom_precision                  in     number    default hr_api.g_number
  ,p_ws_element_type_id             in     number    default hr_api.g_number
  ,p_ws_input_value_id              in     number    default hr_api.g_number
  ,p_data_freeze_date               in     date      default hr_api.g_date
  ,p_ws_amt_edit_cd                 in     varchar2  default hr_api.g_varchar2
  ,p_ws_amt_edit_enf_cd_for_nul     in     varchar2  default hr_api.g_varchar2
  ,p_ws_over_budget_edit_cd         in     varchar2  default hr_api.g_varchar2
  ,p_ws_over_budget_tol_pct         in     number    default hr_api.g_number
  ,p_bdgt_over_budget_edit_cd       in     varchar2  default hr_api.g_varchar2
  ,p_bdgt_over_budget_tol_pct       in     number    default hr_api.g_number
  ,p_auto_distr_flag                in     varchar2  default hr_api.g_varchar2
  ,p_pqh_document_short_name        in     varchar2  default hr_api.g_varchar2
  ,p_ovrid_rt_strt_dt               in     date      default hr_api.g_date
  ,p_do_not_process_flag            in     varchar2  default hr_api.g_varchar2
  ,p_ovr_perf_revw_strt_dt          in     date      default hr_api.g_date
  ,p_post_zero_salary_increase      in     varchar2  default hr_api.g_varchar2
 ,p_show_appraisals_n_days          in     number    default hr_api.g_number
 ,p_grade_range_validation         in     varchar2  default hr_api.g_varchar2
  ) is
--
  l_rec   ben_cpd_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  ben_cpd_shd.convert_args
  (p_pl_id
  ,p_oipl_id
  ,p_lf_evt_ocrd_dt
  ,p_effective_date
  ,p_name
  ,p_group_pl_id
  ,p_group_oipl_id
  ,p_opt_hidden_flag
  ,p_opt_id
  ,p_pl_uom
  ,p_pl_ordr_num
  ,p_oipl_ordr_num
  ,p_pl_xchg_rate
  ,p_opt_count
  ,p_uses_bdgt_flag
  ,p_prsrv_bdgt_cd
  ,p_upd_start_dt
  ,p_upd_end_dt
  ,p_approval_mode
  ,p_enrt_perd_start_dt
  ,p_enrt_perd_end_dt
  ,p_yr_perd_start_dt
  ,p_yr_perd_end_dt
  ,p_wthn_yr_start_dt
  ,p_wthn_yr_end_dt
  ,p_enrt_perd_id
  ,p_yr_perd_id
  ,p_business_group_id
  ,p_perf_revw_strt_dt
  ,p_asg_updt_eff_date
  ,p_emp_interview_typ_cd
  ,p_salary_change_reason
  ,p_ws_abr_id
  ,p_ws_nnmntry_uom
  ,p_ws_rndg_cd
  ,p_ws_sub_acty_typ_cd
  ,p_dist_bdgt_abr_id
  ,p_dist_bdgt_nnmntry_uom
  ,p_dist_bdgt_rndg_cd
  ,p_ws_bdgt_abr_id
  ,p_ws_bdgt_nnmntry_uom
  ,p_ws_bdgt_rndg_cd
  ,p_rsrv_abr_id
  ,p_rsrv_nnmntry_uom
  ,p_rsrv_rndg_cd
  ,p_elig_sal_abr_id
  ,p_elig_sal_nnmntry_uom
  ,p_elig_sal_rndg_cd
  ,p_misc1_abr_id
  ,p_misc1_nnmntry_uom
  ,p_misc1_rndg_cd
  ,p_misc2_abr_id
  ,p_misc2_nnmntry_uom
  ,p_misc2_rndg_cd
  ,p_misc3_abr_id
  ,p_misc3_nnmntry_uom
  ,p_misc3_rndg_cd
  ,p_stat_sal_abr_id
  ,p_stat_sal_nnmntry_uom
  ,p_stat_sal_rndg_cd
  ,p_rec_abr_id
  ,p_rec_nnmntry_uom
  ,p_rec_rndg_cd
  ,p_tot_comp_abr_id
  ,p_tot_comp_nnmntry_uom
  ,p_tot_comp_rndg_cd
  ,p_oth_comp_abr_id
  ,p_oth_comp_nnmntry_uom
  ,p_oth_comp_rndg_cd
  ,p_actual_flag
  ,p_acty_ref_perd_cd
  ,p_legislation_code
  ,p_pl_annulization_factor
  ,p_pl_stat_cd
  ,p_uom_precision
  ,p_ws_element_type_id
  ,p_ws_input_value_id
  ,p_data_freeze_date
  ,p_ws_amt_edit_cd
  ,p_ws_amt_edit_enf_cd_for_nul
  ,p_ws_over_budget_edit_cd
  ,p_ws_over_budget_tol_pct
  ,p_bdgt_over_budget_edit_cd
  ,p_bdgt_over_budget_tol_pct
  ,p_auto_distr_flag
  ,p_pqh_document_short_name
  ,p_ovrid_rt_strt_dt
  ,p_do_not_process_flag
  ,p_ovr_perf_revw_strt_dt
  ,p_post_zero_salary_increase
  ,p_show_appraisals_n_days
  ,p_grade_range_validation
  ,p_object_version_number
  );
  --
  -- Having converted the arguments into the
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  ben_cpd_upd.upd
     (l_rec
     );
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End upd;
--
end ben_cpd_upd;

/
