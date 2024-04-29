--------------------------------------------------------
--  DDL for Package Body BEN_CPD_DEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_CPD_DEL" as
/* $Header: becpdrhi.pkb 120.1.12010000.3 2010/03/12 06:12:31 sgnanama ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  ben_cpd_del.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------------------------------< delete_dml >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure controls the actual dml delete logic. The functions of
--   this procedure are as follows:
--   1) To set and unset the g_api_dml status as required (as we are about to
--      perform dml).
--   2) To delete the specified row from the schema using the primary key in
--      the predicates.
--   3) To trap any constraint violations that may have occurred.
--   4) To raise any other errors.
--
-- Prerequisites:
--   This is an internal private procedure which must be called from the del
--   procedure.
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
--   If a child integrity constraint violation is raised the
--   constraint_error procedure will be called.
--   If any other error is reported, the error will be raised after the
--   g_api_dml status is reset.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure delete_dml
  (p_rec in ben_cpd_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'delete_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  ben_cpd_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Delete the ben_cwb_pl_dsgn row.
  --
  delete from ben_cwb_pl_dsgn
  where pl_id = p_rec.pl_id
    and lf_evt_ocrd_dt = p_rec.lf_evt_ocrd_dt
    and oipl_id = p_rec.oipl_id;
  --
  ben_cpd_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.child_integrity_violated then
    -- Child integrity has been violated
    ben_cpd_shd.g_api_dml := false;   -- Unset the api dml status
    ben_cpd_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    ben_cpd_shd.g_api_dml := false;   -- Unset the api dml status
    Raise;
End delete_dml;
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
--   maintenance should be reviewed before placing in this procedure.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure pre_delete(p_rec in ben_cpd_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'pre_delete';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
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
--   This private procedure contains any processing which is required after
--   the delete dml.
--
-- Prerequistes:
--   This is an internal procedure which is called from the del procedure.
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
--   Any post-processing required after the delete dml is issued should be
--   coded within this procedure. It is important to note that any 3rd party
--   maintenance should be reviewed before placing in this procedure.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- -----------------------------------------------------------------------------
Procedure post_delete(p_rec in ben_cpd_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'post_delete';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  begin
    ben_cpd_rkd.after_delete
      (p_pl_id
      => p_rec.pl_id
      ,p_oipl_id
      => p_rec.oipl_id
      ,p_lf_evt_ocrd_dt
      => p_rec.lf_evt_ocrd_dt
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
        ,p_hook_type   => 'AD');
      --
  end;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End post_delete;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< del >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure del
  (p_rec              in ben_cpd_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'del';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to delete.
  --
  ben_cpd_shd.lck
    (p_rec.pl_id
    ,p_rec.lf_evt_ocrd_dt
    ,p_rec.oipl_id
    ,p_rec.object_version_number
    );
  --
  -- Call the supporting delete validate operation
  --
  ben_cpd_bus.delete_validate(p_rec);
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
  -- Call the supporting pre-delete operation
  --
  ben_cpd_del.pre_delete(p_rec);
  --
  -- Delete the row.
  --
  ben_cpd_del.delete_dml(p_rec);
  --
  -- Call the supporting post-delete operation
  --
  ben_cpd_del.post_delete(p_rec);
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
End del;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< del >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure del
  (p_pl_id                                in     number
  ,p_lf_evt_ocrd_dt                       in     date
  ,p_oipl_id                              in     number
  ,p_object_version_number                in     number
  ) is
--
  l_rec   ben_cpd_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'del';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- As the delete procedure accepts a plsql record structure we do need to
  -- convert the  arguments into the record structure.
  -- We don't need to call the supplied conversion argument routine as we
  -- only need a few attributes.
  --
  l_rec.pl_id := p_pl_id;
  l_rec.lf_evt_ocrd_dt := p_lf_evt_ocrd_dt;
  l_rec.oipl_id := p_oipl_id;
  l_rec.object_version_number := p_object_version_number;
  --
  -- Having converted the arguments into the ben_cpd_rec
  -- plsql record structure we must call the corresponding entity
  -- business process
  --
  ben_cpd_del.del(l_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End del;
--
end ben_cpd_del;

/
