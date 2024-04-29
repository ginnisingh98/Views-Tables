--------------------------------------------------------
--  DDL for Package Body BEN_CPD_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_CPD_INS" as
/* $Header: becpdrhi.pkb 120.1.12010000.3 2010/03/12 06:12:31 sgnanama ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  ben_cpd_ins.';  -- Global package name
--
-- The following global variables are only to be used by
-- the set_base_key_value and pre_insert procedures.
--
g_pl_id_i  number   default null;
g_oipl_id_i  number   default null;
g_lf_evt_ocrd_dt_i  date   default null;
--
-- ----------------------------------------------------------------------------
-- |------------------------< set_base_key_value >----------------------------|
-- ----------------------------------------------------------------------------
procedure set_base_key_value
  (p_pl_id  in  number
  ,p_oipl_id  in  number
  ,p_lf_evt_ocrd_dt  in  date) is
--
  l_proc       varchar2(72) := g_package||'set_base_key_value';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  ben_cpd_ins.g_pl_id_i := p_pl_id;
  ben_cpd_ins.g_lf_evt_ocrd_dt_i := p_lf_evt_ocrd_dt;
  ben_cpd_ins.g_oipl_id_i := p_oipl_id;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 20);
End set_base_key_value;
--
--
-- ----------------------------------------------------------------------------
-- |------------------------------< insert_dml >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure controls the actual dml insert logic. The processing of
--   this procedure are as follows:
--   1) Initialise the object_version_number to 1 if the object_version_number
--      is defined as an attribute for this entity.
--   2) To set and unset the g_api_dml status as required (as we are about to
--      perform dml).
--   3) To insert the row into the schema.
--   4) To trap any constraint violations that may have occurred.
--   5) To raise any other errors.
--
-- Prerequisites:
--   This is an internal private procedure which must be called from the ins
--   procedure and must have all mandatory attributes set (except the
--   object_version_number which is initialised within this procedure).
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
--   If a check, unique or parent integrity constraint violation is raised the
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
Procedure insert_dml
  (p_rec in out nocopy ben_cpd_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'insert_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  p_rec.object_version_number := 1;  -- Initialise the object version
  --
  ben_cpd_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Insert the row into: ben_cwb_pl_dsgn
  --
  insert into ben_cwb_pl_dsgn
      (pl_id
      ,lf_evt_ocrd_dt
      ,oipl_id
      ,effective_date
      ,name
      ,group_pl_id
      ,group_oipl_id
      ,opt_hidden_flag
      ,opt_id
      ,pl_uom
      ,pl_ordr_num
      ,oipl_ordr_num
      ,pl_xchg_rate
      ,opt_count
      ,uses_bdgt_flag
      ,prsrv_bdgt_cd
      ,upd_start_dt
      ,upd_end_dt
      ,approval_mode
      ,enrt_perd_start_dt
      ,enrt_perd_end_dt
      ,yr_perd_start_dt
      ,yr_perd_end_dt
      ,wthn_yr_start_dt
      ,wthn_yr_end_dt
      ,enrt_perd_id
      ,yr_perd_id
      ,business_group_id
      ,perf_revw_strt_dt
      ,asg_updt_eff_date
      ,emp_interview_typ_cd
      ,salary_change_reason
      ,ws_abr_id
      ,ws_nnmntry_uom
      ,ws_rndg_cd
      ,ws_sub_acty_typ_cd
      ,dist_bdgt_abr_id
      ,dist_bdgt_nnmntry_uom
      ,dist_bdgt_rndg_cd
      ,ws_bdgt_abr_id
      ,ws_bdgt_nnmntry_uom
      ,ws_bdgt_rndg_cd
      ,rsrv_abr_id
      ,rsrv_nnmntry_uom
      ,rsrv_rndg_cd
      ,elig_sal_abr_id
      ,elig_sal_nnmntry_uom
      ,elig_sal_rndg_cd
      ,misc1_abr_id
      ,misc1_nnmntry_uom
      ,misc1_rndg_cd
      ,misc2_abr_id
      ,misc2_nnmntry_uom
      ,misc2_rndg_cd
      ,misc3_abr_id
      ,misc3_nnmntry_uom
      ,misc3_rndg_cd
      ,stat_sal_abr_id
      ,stat_sal_nnmntry_uom
      ,stat_sal_rndg_cd
      ,rec_abr_id
      ,rec_nnmntry_uom
      ,rec_rndg_cd
      ,tot_comp_abr_id
      ,tot_comp_nnmntry_uom
      ,tot_comp_rndg_cd
      ,oth_comp_abr_id
      ,oth_comp_nnmntry_uom
      ,oth_comp_rndg_cd
      ,actual_flag
      ,acty_ref_perd_cd
      ,legislation_code
      ,pl_annulization_factor
      ,pl_stat_cd
      ,uom_precision
      ,ws_element_type_id
      ,ws_input_value_id
      ,data_freeze_date
      ,ws_amt_edit_cd
      ,ws_amt_edit_enf_cd_for_nulls
      ,ws_over_budget_edit_cd
      ,ws_over_budget_tolerance_pct
      ,bdgt_over_budget_edit_cd
      ,bdgt_over_budget_tolerance_pct
      ,auto_distr_flag
      ,pqh_document_short_name
      ,ovrid_rt_strt_dt
      ,do_not_process_flag
      ,ovr_perf_revw_strt_dt
      ,post_zero_salary_increase
      ,show_appraisals_n_days
      ,grade_range_validation
      ,object_version_number
      )
  Values
    (p_rec.pl_id
    ,p_rec.lf_evt_ocrd_dt
    ,p_rec.oipl_id
    ,p_rec.effective_date
    ,p_rec.name
    ,p_rec.group_pl_id
    ,p_rec.group_oipl_id
    ,p_rec.opt_hidden_flag
    ,p_rec.opt_id
    ,p_rec.pl_uom
    ,p_rec.pl_ordr_num
    ,p_rec.oipl_ordr_num
    ,p_rec.pl_xchg_rate
    ,p_rec.opt_count
    ,p_rec.uses_bdgt_flag
    ,p_rec.prsrv_bdgt_cd
    ,p_rec.upd_start_dt
    ,p_rec.upd_end_dt
    ,p_rec.approval_mode
    ,p_rec.enrt_perd_start_dt
    ,p_rec.enrt_perd_end_dt
    ,p_rec.yr_perd_start_dt
    ,p_rec.yr_perd_end_dt
    ,p_rec.wthn_yr_start_dt
    ,p_rec.wthn_yr_end_dt
    ,p_rec.enrt_perd_id
    ,p_rec.yr_perd_id
    ,p_rec.business_group_id
    ,p_rec.perf_revw_strt_dt
    ,p_rec.asg_updt_eff_date
    ,p_rec.emp_interview_typ_cd
    ,p_rec.salary_change_reason
    ,p_rec.ws_abr_id
    ,p_rec.ws_nnmntry_uom
    ,p_rec.ws_rndg_cd
    ,p_rec.ws_sub_acty_typ_cd
    ,p_rec.dist_bdgt_abr_id
    ,p_rec.dist_bdgt_nnmntry_uom
    ,p_rec.dist_bdgt_rndg_cd
    ,p_rec.ws_bdgt_abr_id
    ,p_rec.ws_bdgt_nnmntry_uom
    ,p_rec.ws_bdgt_rndg_cd
    ,p_rec.rsrv_abr_id
    ,p_rec.rsrv_nnmntry_uom
    ,p_rec.rsrv_rndg_cd
    ,p_rec.elig_sal_abr_id
    ,p_rec.elig_sal_nnmntry_uom
    ,p_rec.elig_sal_rndg_cd
    ,p_rec.misc1_abr_id
    ,p_rec.misc1_nnmntry_uom
    ,p_rec.misc1_rndg_cd
    ,p_rec.misc2_abr_id
    ,p_rec.misc2_nnmntry_uom
    ,p_rec.misc2_rndg_cd
    ,p_rec.misc3_abr_id
    ,p_rec.misc3_nnmntry_uom
    ,p_rec.misc3_rndg_cd
    ,p_rec.stat_sal_abr_id
    ,p_rec.stat_sal_nnmntry_uom
    ,p_rec.stat_sal_rndg_cd
    ,p_rec.rec_abr_id
    ,p_rec.rec_nnmntry_uom
    ,p_rec.rec_rndg_cd
    ,p_rec.tot_comp_abr_id
    ,p_rec.tot_comp_nnmntry_uom
    ,p_rec.tot_comp_rndg_cd
    ,p_rec.oth_comp_abr_id
    ,p_rec.oth_comp_nnmntry_uom
    ,p_rec.oth_comp_rndg_cd
    ,p_rec.actual_flag
    ,p_rec.acty_ref_perd_cd
    ,p_rec.legislation_code
    ,p_rec.pl_annulization_factor
    ,p_rec.pl_stat_cd
    ,p_rec.uom_precision
    ,p_rec.ws_element_type_id
    ,p_rec.ws_input_value_id
    ,p_rec.data_freeze_date
    ,p_rec.ws_amt_edit_cd
    ,p_rec.ws_amt_edit_enf_cd_for_nulls
    ,p_rec.ws_over_budget_edit_cd
    ,p_rec.ws_over_budget_tolerance_pct
    ,p_rec.bdgt_over_budget_edit_cd
    ,p_rec.bdgt_over_budget_tolerance_pct
    ,p_rec.auto_distr_flag
    ,p_rec.pqh_document_short_name
    ,p_rec.ovrid_rt_strt_dt
    ,p_rec.do_not_process_flag
    ,p_rec.ovr_perf_revw_strt_dt
    ,p_rec.post_zero_salary_increase
    ,p_rec.show_appraisals_n_days
    ,p_rec.grade_range_validation
    ,p_rec.object_version_number
    );
  --
  ben_cpd_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
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
--
-- Prerequisites:
--   This is an internal procedure which is called from the ins procedure.
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
  (p_rec  in out nocopy ben_cpd_shd.g_rec_type
  ) is
--
  Cursor C_Sel1 is
    Select null
      from ben_cwb_pl_dsgn
     where pl_id =
             ben_cpd_ins.g_pl_id_i
        or lf_evt_ocrd_dt =
             ben_cpd_ins.g_lf_evt_ocrd_dt_i
        or oipl_id =
             ben_cpd_ins.g_oipl_id_i;
--
  l_proc   varchar2(72) := g_package||'pre_insert';
  l_exists varchar2(1);
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (ben_cpd_ins.g_pl_id_i is not null or
      ben_cpd_ins.g_lf_evt_ocrd_dt_i is not null or
      ben_cpd_ins.g_oipl_id_i is not null) Then
    --
    -- Verify registered primary key values not already in use
    --
    Open C_Sel1;
    Fetch C_Sel1 into l_exists;
    If C_Sel1%found Then
       Close C_Sel1;
       --
       -- The primary key values are already in use.
       --
       fnd_message.set_name('PER','PER_289391_KEY_ALREADY_USED');
       fnd_message.set_token('TABLE_NAME','ben_cwb_pl_dsgn');
       fnd_message.raise_error;
    End If;
    Close C_Sel1;
    --
    -- Use registered key values and clear globals
    --
    p_rec.pl_id :=
      ben_cpd_ins.g_pl_id_i;
    ben_cpd_ins.g_pl_id_i := null;
    p_rec.lf_evt_ocrd_dt :=
      ben_cpd_ins.g_lf_evt_ocrd_dt_i;
    ben_cpd_ins.g_lf_evt_ocrd_dt_i := null;
    p_rec.oipl_id :=
      ben_cpd_ins.g_oipl_id_i;
    ben_cpd_ins.g_oipl_id_i := null;
  Else
      -- Commented out the following code as it is not required.
    null;
/*    --
    -- No registerd key values, so select the next sequence number
    --
    --
    -- Select the next sequence number
    --
    Open C_Sel1;
    Fetch C_Sel1 Into p_rec.oipl_id;
    Close C_Sel1; */
  End If;
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
--   This private procedure contains any processing which is required after
--   the insert dml.
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
  (p_rec                          in ben_cpd_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'post_insert';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  begin
    --
    ben_cpd_rki.after_insert
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
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'BEN_CWB_PL_DSGN'
        ,p_hook_type   => 'AI');
      --
  end;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End post_insert;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (p_rec                          in out nocopy ben_cpd_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call the supporting insert validate operations
  --
  ben_cpd_bus.insert_validate
     (p_rec
     );
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
  -- Call the supporting pre-insert operation
  --
  ben_cpd_ins.pre_insert(p_rec);
  --
  -- Insert the row
  --
  ben_cpd_ins.insert_dml(p_rec);
  --
  -- Call the supporting post-insert operation
  --
  ben_cpd_ins.post_insert
     (p_rec
     );
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
  hr_utility.set_location('Leaving:'||l_proc, 20);
end ins;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (p_pl_id                          in     number
  ,p_oipl_id                        in     number
  ,p_lf_evt_ocrd_dt                 in     date
  ,p_effective_date                 in     date     default null
  ,p_name                           in     varchar2 default null
  ,p_group_pl_id                    in     number   default null
  ,p_group_oipl_id                  in     number   default null
  ,p_opt_hidden_flag                in     varchar2 default null
  ,p_opt_id                         in     number   default null
  ,p_pl_uom                         in     varchar2 default null
  ,p_pl_ordr_num                    in     number   default null
  ,p_oipl_ordr_num                  in     number   default null
  ,p_pl_xchg_rate                   in     number   default null
  ,p_opt_count                      in     number   default null
  ,p_uses_bdgt_flag                 in     varchar2 default null
  ,p_prsrv_bdgt_cd                  in     varchar2 default null
  ,p_upd_start_dt                   in     date     default null
  ,p_upd_end_dt                     in     date     default null
  ,p_approval_mode                  in     varchar2 default null
  ,p_enrt_perd_start_dt             in     date     default null
  ,p_enrt_perd_end_dt               in     date     default null
  ,p_yr_perd_start_dt               in     date     default null
  ,p_yr_perd_end_dt                 in     date     default null
  ,p_wthn_yr_start_dt               in     date     default null
  ,p_wthn_yr_end_dt                 in     date     default null
  ,p_enrt_perd_id                   in     number   default null
  ,p_yr_perd_id                     in     number   default null
  ,p_business_group_id              in     number   default null
  ,p_perf_revw_strt_dt              in     date     default null
  ,p_asg_updt_eff_date              in     date     default null
  ,p_emp_interview_typ_cd           in     varchar2 default null
  ,p_salary_change_reason           in     varchar2 default null
  ,p_ws_abr_id                      in     number   default null
  ,p_ws_nnmntry_uom                 in     varchar2 default null
  ,p_ws_rndg_cd                     in     varchar2 default null
  ,p_ws_sub_acty_typ_cd             in     varchar2 default null
  ,p_dist_bdgt_abr_id               in     number   default null
  ,p_dist_bdgt_nnmntry_uom          in     varchar2 default null
  ,p_dist_bdgt_rndg_cd              in     varchar2 default null
  ,p_ws_bdgt_abr_id                 in     number   default null
  ,p_ws_bdgt_nnmntry_uom            in     varchar2 default null
  ,p_ws_bdgt_rndg_cd                in     varchar2 default null
  ,p_rsrv_abr_id                    in     number   default null
  ,p_rsrv_nnmntry_uom               in     varchar2 default null
  ,p_rsrv_rndg_cd                   in     varchar2 default null
  ,p_elig_sal_abr_id                in     number   default null
  ,p_elig_sal_nnmntry_uom           in     varchar2 default null
  ,p_elig_sal_rndg_cd               in     varchar2 default null
  ,p_misc1_abr_id                   in     number   default null
  ,p_misc1_nnmntry_uom              in     varchar2 default null
  ,p_misc1_rndg_cd                  in     varchar2 default null
  ,p_misc2_abr_id                   in     number   default null
  ,p_misc2_nnmntry_uom              in     varchar2 default null
  ,p_misc2_rndg_cd                  in     varchar2 default null
  ,p_misc3_abr_id                   in     number   default null
  ,p_misc3_nnmntry_uom              in     varchar2 default null
  ,p_misc3_rndg_cd                  in     varchar2 default null
  ,p_stat_sal_abr_id                in     number   default null
  ,p_stat_sal_nnmntry_uom           in     varchar2 default null
  ,p_stat_sal_rndg_cd               in     varchar2 default null
  ,p_rec_abr_id                     in     number   default null
  ,p_rec_nnmntry_uom                in     varchar2 default null
  ,p_rec_rndg_cd                    in     varchar2 default null
  ,p_tot_comp_abr_id                in     number   default null
  ,p_tot_comp_nnmntry_uom           in     varchar2 default null
  ,p_tot_comp_rndg_cd               in     varchar2 default null
  ,p_oth_comp_abr_id                in     number   default null
  ,p_oth_comp_nnmntry_uom           in     varchar2 default null
  ,p_oth_comp_rndg_cd               in     varchar2 default null
  ,p_actual_flag                    in     varchar2 default null
  ,p_acty_ref_perd_cd               in     varchar2 default null
  ,p_legislation_code               in     varchar2 default null
  ,p_pl_annulization_factor         in     number   default null
  ,p_pl_stat_cd                     in     varchar2 default null
  ,p_uom_precision                  in     number   default null
  ,p_ws_element_type_id             in     number   default null
  ,p_ws_input_value_id              in     number   default null
  ,p_data_freeze_date               in     date     default null
  ,p_ws_amt_edit_cd                 in     varchar2 default null
  ,p_ws_amt_edit_enf_cd_for_nul     in     varchar2 default null
  ,p_ws_over_budget_edit_cd         in     varchar2 default null
  ,p_ws_over_budget_tol_pct         in     number   default null
  ,p_bdgt_over_budget_edit_cd       in     varchar2 default null
  ,p_bdgt_over_budget_tol_pct       in     number   default null
  ,p_auto_distr_flag                in     varchar2 default null
  ,p_pqh_document_short_name        in     varchar2 default null
  ,p_ovrid_rt_strt_dt               in     date     default null
  ,p_do_not_process_flag            in     varchar2 default null
  ,p_ovr_perf_revw_strt_dt          in     date     default null
  ,p_post_zero_salary_increase         in     varchar2  default null
  ,p_show_appraisals_n_days            in     number    default null
  ,p_grade_range_validation         in     varchar2  default null
  ,p_object_version_number             out nocopy number
  ) is
--
  l_rec   ben_cpd_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
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
    ,null
    );
  --
  -- Having converted the arguments into the ben_cpd_rec
  -- plsql record structure we call the corresponding record business process.
  --
  ben_cpd_ins.ins
     (l_rec
     );
  --
  -- As the primary key argument(s)
  -- are specified as an OUT's we must set these values.
  --
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End ins;
--
end ben_cpd_ins;

/
