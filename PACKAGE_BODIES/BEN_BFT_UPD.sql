--------------------------------------------------------
--  DDL for Package Body BEN_BFT_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_BFT_UPD" as
/* $Header: bebftrhi.pkb 115.23 2003/08/18 05:05:29 rpgupta ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_bft_upd.';  -- Global package name
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
Procedure update_dml(p_rec in out nocopy ben_bft_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'update_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Increment the object version
  --
  p_rec.object_version_number := p_rec.object_version_number + 1;
  --
  ben_bft_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Update the ben_benefit_actions Row
  --
  update ben_benefit_actions
  set
  benefit_action_id                 = p_rec.benefit_action_id,
  process_date                      = p_rec.process_date,
  uneai_effective_date              = p_rec.uneai_effective_date,
  mode_cd                           = p_rec.mode_cd,
  derivable_factors_flag            = p_rec.derivable_factors_flag,
  close_uneai_flag                  = p_rec.close_uneai_flag      ,
  validate_flag                     = p_rec.validate_flag,
  person_id                         = p_rec.person_id,
  person_type_id                    = p_rec.person_type_id,
  pgm_id                            = p_rec.pgm_id,
  business_group_id                 = p_rec.business_group_id,
  pl_id                             = p_rec.pl_id,
  popl_enrt_typ_cycl_id             = p_rec.popl_enrt_typ_cycl_id,
  no_programs_flag                  = p_rec.no_programs_flag,
  no_plans_flag                     = p_rec.no_plans_flag,
  comp_selection_rl                 = p_rec.comp_selection_rl,
  person_selection_rl               = p_rec.person_selection_rl,
  ler_id                            = p_rec.ler_id,
  organization_id                   = p_rec.organization_id,
  benfts_grp_id                     = p_rec.benfts_grp_id,
  location_id                       = p_rec.location_id,
  pstl_zip_rng_id                   = p_rec.pstl_zip_rng_id,
  rptg_grp_id                       = p_rec.rptg_grp_id,
  pl_typ_id                         = p_rec.pl_typ_id,
  opt_id                            = p_rec.opt_id,
  eligy_prfl_id                     = p_rec.eligy_prfl_id,
  vrbl_rt_prfl_id                   = p_rec.vrbl_rt_prfl_id,
  legal_entity_id                   = p_rec.legal_entity_id,
  payroll_id                        = p_rec.payroll_id,
  debug_messages_flag               = p_rec.debug_messages_flag,
  cm_trgr_typ_cd                    = p_rec.cm_trgr_typ_cd,
  cm_typ_id                         = p_rec.cm_typ_id,
  age_fctr_id                       = p_rec.age_fctr_id,
  min_age                           = p_rec.min_age,
  max_age                           = p_rec.max_age,
  los_fctr_id                       = p_rec.los_fctr_id,
  min_los                           = p_rec.min_los,
  max_los                           = p_rec.max_los,
  cmbn_age_los_fctr_id              = p_rec.cmbn_age_los_fctr_id,
  min_cmbn                          = p_rec.min_cmbn,
  max_cmbn                          = p_rec.max_cmbn,
  date_from                         = p_rec.date_from,
  elig_enrol_cd                     = p_rec.elig_enrol_cd,
  actn_typ_id                       = p_rec.actn_typ_id,
  use_fctr_to_sel_flag              = p_rec.use_fctr_to_sel_flag,
  los_det_to_use_cd                 = p_rec.los_det_to_use_cd,
  audit_log_flag                    = p_rec.audit_log_flag,
  lmt_prpnip_by_org_flag            = p_rec.lmt_prpnip_by_org_flag,
  lf_evt_ocrd_dt                    = p_rec.lf_evt_ocrd_dt,
  ptnl_ler_for_per_stat_cd          = p_rec.ptnl_ler_for_per_stat_cd,
  bft_attribute_category            = p_rec.bft_attribute_category,
  bft_attribute1                    = p_rec.bft_attribute1,
  bft_attribute3                    = p_rec.bft_attribute3,
  bft_attribute4                    = p_rec.bft_attribute4,
  bft_attribute5                    = p_rec.bft_attribute5,
  bft_attribute6                    = p_rec.bft_attribute6,
  bft_attribute7                    = p_rec.bft_attribute7,
  bft_attribute8                    = p_rec.bft_attribute8,
  bft_attribute9                    = p_rec.bft_attribute9,
  bft_attribute10                   = p_rec.bft_attribute10,
  bft_attribute11                   = p_rec.bft_attribute11,
  bft_attribute12                   = p_rec.bft_attribute12,
  bft_attribute13                   = p_rec.bft_attribute13,
  bft_attribute14                   = p_rec.bft_attribute14,
  bft_attribute15                   = p_rec.bft_attribute15,
  bft_attribute16                   = p_rec.bft_attribute16,
  bft_attribute17                   = p_rec.bft_attribute17,
  bft_attribute18                   = p_rec.bft_attribute18,
  bft_attribute19                   = p_rec.bft_attribute19,
  bft_attribute20                   = p_rec.bft_attribute20,
  bft_attribute21                   = p_rec.bft_attribute21,
  bft_attribute22                   = p_rec.bft_attribute22,
  bft_attribute23                   = p_rec.bft_attribute23,
  bft_attribute24                   = p_rec.bft_attribute24,
  bft_attribute25                   = p_rec.bft_attribute25,
  bft_attribute26                   = p_rec.bft_attribute26,
  bft_attribute27                   = p_rec.bft_attribute27,
  bft_attribute28                   = p_rec.bft_attribute28,
  bft_attribute29                   = p_rec.bft_attribute29,
  bft_attribute30                   = p_rec.bft_attribute30,
  request_id                        = p_rec.request_id,
  program_application_id            = p_rec.program_application_id,
  program_id                        = p_rec.program_id,
  program_update_date               = p_rec.program_update_date,
  object_version_number             = p_rec.object_version_number,
  enrt_perd_id                      = p_rec.enrt_perd_id,
  inelg_action_cd                   = p_rec.inelg_action_cd,
  org_hierarchy_id                   = p_rec.org_hierarchy_id,
  org_starting_node_id                   = p_rec.org_starting_node_id,
  grade_ladder_id                   = p_rec.grade_ladder_id,
  asg_events_to_all_sel_dt                   = p_rec.asg_events_to_all_sel_dt,
  rate_id                   = p_rec.rate_id,
  per_sel_dt_cd                   = p_rec.per_sel_dt_cd,
  per_sel_freq_cd                   = p_rec.per_sel_freq_cd,
  per_sel_dt_from                   = p_rec.per_sel_dt_from,
  per_sel_dt_to                   = p_rec.per_sel_dt_to,
  year_from                   = p_rec.year_from,
  year_to                   = p_rec.year_to,
  cagr_id                   = p_rec.cagr_id,
  qual_type                   = p_rec.qual_type,
  qual_status                   = p_rec.qual_status,
  concat_segs                   = p_rec.concat_segs,
  grant_price_val                   = p_rec.grant_price_val
  where benefit_action_id = p_rec.benefit_action_id;
  --
  ben_bft_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    ben_bft_shd.g_api_dml := false;   -- Unset the api dml status
    ben_bft_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    ben_bft_shd.g_api_dml := false;   -- Unset the api dml status
    ben_bft_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    ben_bft_shd.g_api_dml := false;   -- Unset the api dml status
    ben_bft_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    ben_bft_shd.g_api_dml := false;   -- Unset the api dml status
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
--   maintenance should be reviewed before placing in this procedure.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure pre_update(p_rec in ben_bft_shd.g_rec_type) is
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
Procedure post_update(
p_effective_date in date,p_rec in ben_bft_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'post_update';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
--
  --
  -- Start of API User Hook for post_update.
  --
  begin
    --
    ben_bft_rku.after_update
      (
  p_benefit_action_id             =>p_rec.benefit_action_id
 ,p_process_date                  =>p_rec.process_date
 ,p_uneai_effective_date          =>p_rec.uneai_effective_date
 ,p_mode_cd                       =>p_rec.mode_cd
 ,p_derivable_factors_flag        =>p_rec.derivable_factors_flag
 ,p_close_uneai_flag              =>p_rec.close_uneai_flag
 ,p_validate_flag                 =>p_rec.validate_flag
 ,p_person_id                     =>p_rec.person_id
 ,p_person_type_id                =>p_rec.person_type_id
 ,p_pgm_id                        =>p_rec.pgm_id
 ,p_business_group_id             =>p_rec.business_group_id
 ,p_pl_id                         =>p_rec.pl_id
 ,p_popl_enrt_typ_cycl_id         =>p_rec.popl_enrt_typ_cycl_id
 ,p_no_programs_flag              =>p_rec.no_programs_flag
 ,p_no_plans_flag                 =>p_rec.no_plans_flag
 ,p_comp_selection_rl             =>p_rec.comp_selection_rl
 ,p_person_selection_rl           =>p_rec.person_selection_rl
 ,p_ler_id                        =>p_rec.ler_id
 ,p_organization_id               =>p_rec.organization_id
 ,p_benfts_grp_id                 =>p_rec.benfts_grp_id
 ,p_location_id                   =>p_rec.location_id
 ,p_pstl_zip_rng_id               =>p_rec.pstl_zip_rng_id
 ,p_rptg_grp_id                   =>p_rec.rptg_grp_id
 ,p_pl_typ_id                     =>p_rec.pl_typ_id
 ,p_opt_id                        =>p_rec.opt_id
 ,p_eligy_prfl_id                 =>p_rec.eligy_prfl_id
 ,p_vrbl_rt_prfl_id               =>p_rec.vrbl_rt_prfl_id
 ,p_legal_entity_id               =>p_rec.legal_entity_id
 ,p_payroll_id                    =>p_rec.payroll_id
 ,p_debug_messages_flag           =>p_rec.debug_messages_flag
 ,p_cm_trgr_typ_cd                =>p_rec.cm_trgr_typ_cd
 ,p_cm_typ_id                     =>p_rec.cm_typ_id
 ,p_age_fctr_id                   =>p_rec.age_fctr_id
 ,p_min_age                       =>p_rec.min_age
 ,p_max_age                       =>p_rec.max_age
 ,p_los_fctr_id                   =>p_rec.los_fctr_id
 ,p_min_los                       =>p_rec.min_los
 ,p_max_los                       =>p_rec.max_los
 ,p_cmbn_age_los_fctr_id          =>p_rec.cmbn_age_los_fctr_id
 ,p_min_cmbn                      =>p_rec.min_cmbn
 ,p_max_cmbn                      =>p_rec.max_cmbn
 ,p_date_from                     =>p_rec.date_from
 ,p_elig_enrol_cd                 =>p_rec.elig_enrol_cd
 ,p_actn_typ_id                   =>p_rec.actn_typ_id
 ,p_use_fctr_to_sel_flag          =>p_rec.use_fctr_to_sel_flag
 ,p_los_det_to_use_cd             =>p_rec.los_det_to_use_cd
 ,p_audit_log_flag                =>p_rec.audit_log_flag
 ,p_lmt_prpnip_by_org_flag        =>p_rec.lmt_prpnip_by_org_flag
 ,p_lf_evt_ocrd_dt                =>p_rec.lf_evt_ocrd_dt
 ,p_ptnl_ler_for_per_stat_cd      =>p_rec.ptnl_ler_for_per_stat_cd
 ,p_bft_attribute_category        =>p_rec.bft_attribute_category
 ,p_bft_attribute1                =>p_rec.bft_attribute1
 ,p_bft_attribute3                =>p_rec.bft_attribute3
 ,p_bft_attribute4                =>p_rec.bft_attribute4
 ,p_bft_attribute5                =>p_rec.bft_attribute5
 ,p_bft_attribute6                =>p_rec.bft_attribute6
 ,p_bft_attribute7                =>p_rec.bft_attribute7
 ,p_bft_attribute8                =>p_rec.bft_attribute8
 ,p_bft_attribute9                =>p_rec.bft_attribute9
 ,p_bft_attribute10               =>p_rec.bft_attribute10
 ,p_bft_attribute11               =>p_rec.bft_attribute11
 ,p_bft_attribute12               =>p_rec.bft_attribute12
 ,p_bft_attribute13               =>p_rec.bft_attribute13
 ,p_bft_attribute14               =>p_rec.bft_attribute14
 ,p_bft_attribute15               =>p_rec.bft_attribute15
 ,p_bft_attribute16               =>p_rec.bft_attribute16
 ,p_bft_attribute17               =>p_rec.bft_attribute17
 ,p_bft_attribute18               =>p_rec.bft_attribute18
 ,p_bft_attribute19               =>p_rec.bft_attribute19
 ,p_bft_attribute20               =>p_rec.bft_attribute20
 ,p_bft_attribute21               =>p_rec.bft_attribute21
 ,p_bft_attribute22               =>p_rec.bft_attribute22
 ,p_bft_attribute23               =>p_rec.bft_attribute23
 ,p_bft_attribute24               =>p_rec.bft_attribute24
 ,p_bft_attribute25               =>p_rec.bft_attribute25
 ,p_bft_attribute26               =>p_rec.bft_attribute26
 ,p_bft_attribute27               =>p_rec.bft_attribute27
 ,p_bft_attribute28               =>p_rec.bft_attribute28
 ,p_bft_attribute29               =>p_rec.bft_attribute29
 ,p_bft_attribute30               =>p_rec.bft_attribute30
 ,p_object_version_number         =>p_rec.object_version_number
 ,p_effective_date                =>p_effective_date
 ,p_enrt_perd_id                  =>p_rec.enrt_perd_id
 ,p_inelg_action_cd               =>p_rec.inelg_action_cd
 ,p_org_hierarchy_id               =>p_rec.org_hierarchy_id
 ,p_org_starting_node_id               =>p_rec.org_starting_node_id
 ,p_grade_ladder_id               =>p_rec.grade_ladder_id
 ,p_asg_events_to_all_sel_dt               =>p_rec.asg_events_to_all_sel_dt
 ,p_rate_id               =>p_rec.rate_id
 ,p_per_sel_dt_cd               =>p_rec.per_sel_dt_cd
 ,p_per_sel_freq_cd               =>p_rec.per_sel_freq_cd
 ,p_per_sel_dt_from               =>p_rec.per_sel_dt_from
 ,p_per_sel_dt_to               =>p_rec.per_sel_dt_to
 ,p_year_from               =>p_rec.year_from
 ,p_year_to               =>p_rec.year_to
 ,p_cagr_id               =>p_rec.cagr_id
 ,p_qual_type               =>p_rec.qual_type
 ,p_qual_status               =>p_rec.qual_status
 ,p_concat_segs               =>p_rec.concat_segs
 ,p_grant_price_val               =>p_rec.grant_price_val
 ,p_process_date_o                =>ben_bft_shd.g_old_rec.process_date
 ,p_uneai_effective_date_o        =>ben_bft_shd.g_old_rec.uneai_effective_date
 ,p_mode_cd_o                     =>ben_bft_shd.g_old_rec.mode_cd
 ,p_derivable_factors_flag_o      =>ben_bft_shd.g_old_rec.derivable_factors_flag
 ,p_close_uneai_flag_o            =>ben_bft_shd.g_old_rec.close_uneai_flag
 ,p_validate_flag_o               =>ben_bft_shd.g_old_rec.validate_flag
 ,p_person_id_o                   =>ben_bft_shd.g_old_rec.person_id
 ,p_person_type_id_o              =>ben_bft_shd.g_old_rec.person_type_id
 ,p_pgm_id_o                      =>ben_bft_shd.g_old_rec.pgm_id
 ,p_business_group_id_o           =>ben_bft_shd.g_old_rec.business_group_id
 ,p_pl_id_o                       =>ben_bft_shd.g_old_rec.pl_id
 ,p_popl_enrt_typ_cycl_id_o       =>ben_bft_shd.g_old_rec.popl_enrt_typ_cycl_id
 ,p_no_programs_flag_o            =>ben_bft_shd.g_old_rec.no_programs_flag
 ,p_no_plans_flag_o               =>ben_bft_shd.g_old_rec.no_plans_flag
 ,p_comp_selection_rl_o           =>ben_bft_shd.g_old_rec.comp_selection_rl
 ,p_person_selection_rl_o         =>ben_bft_shd.g_old_rec.person_selection_rl
 ,p_ler_id_o                      =>ben_bft_shd.g_old_rec.ler_id
 ,p_organization_id_o             =>ben_bft_shd.g_old_rec.organization_id
 ,p_benfts_grp_id_o               =>ben_bft_shd.g_old_rec.benfts_grp_id
 ,p_location_id_o                 =>ben_bft_shd.g_old_rec.location_id
 ,p_pstl_zip_rng_id_o             =>ben_bft_shd.g_old_rec.pstl_zip_rng_id
 ,p_rptg_grp_id_o                 =>ben_bft_shd.g_old_rec.rptg_grp_id
 ,p_pl_typ_id_o                   =>ben_bft_shd.g_old_rec.pl_typ_id
 ,p_opt_id_o                      =>ben_bft_shd.g_old_rec.opt_id
 ,p_eligy_prfl_id_o               =>ben_bft_shd.g_old_rec.eligy_prfl_id
 ,p_vrbl_rt_prfl_id_o             =>ben_bft_shd.g_old_rec.vrbl_rt_prfl_id
 ,p_legal_entity_id_o             =>ben_bft_shd.g_old_rec.legal_entity_id
 ,p_payroll_id_o                  =>ben_bft_shd.g_old_rec.payroll_id
 ,p_debug_messages_flag_o         =>ben_bft_shd.g_old_rec.debug_messages_flag
 ,p_cm_trgr_typ_cd_o              =>ben_bft_shd.g_old_rec.cm_trgr_typ_cd
 ,p_cm_typ_id_o                   =>ben_bft_shd.g_old_rec.cm_typ_id
 ,p_age_fctr_id_o                 =>ben_bft_shd.g_old_rec.age_fctr_id
 ,p_min_age_o                     =>ben_bft_shd.g_old_rec.min_age
 ,p_max_age_o                     =>ben_bft_shd.g_old_rec.max_age
 ,p_los_fctr_id_o                 =>ben_bft_shd.g_old_rec.los_fctr_id
 ,p_min_los_o                     =>ben_bft_shd.g_old_rec.min_los
 ,p_max_los_o                     =>ben_bft_shd.g_old_rec.max_los
 ,p_cmbn_age_los_fctr_id_o        =>ben_bft_shd.g_old_rec.cmbn_age_los_fctr_id
 ,p_min_cmbn_o                    =>ben_bft_shd.g_old_rec.min_cmbn
 ,p_max_cmbn_o                    =>ben_bft_shd.g_old_rec.max_cmbn
 ,p_date_from_o                   =>ben_bft_shd.g_old_rec.date_from
 ,p_elig_enrol_cd_o               =>ben_bft_shd.g_old_rec.elig_enrol_cd
 ,p_actn_typ_id_o                 =>ben_bft_shd.g_old_rec.actn_typ_id
 ,p_use_fctr_to_sel_flag_o        =>ben_bft_shd.g_old_rec.use_fctr_to_sel_flag
 ,p_los_det_to_use_cd_o           =>ben_bft_shd.g_old_rec.los_det_to_use_cd
 ,p_audit_log_flag_o              =>ben_bft_shd.g_old_rec.audit_log_flag
 ,p_lmt_prpnip_by_org_flag_o      =>ben_bft_shd.g_old_rec.lmt_prpnip_by_org_flag
 ,p_lf_evt_ocrd_dt_o              =>ben_bft_shd.g_old_rec.lf_evt_ocrd_dt
 ,p_ptnl_ler_for_per_stat_cd_o    =>ben_bft_shd.g_old_rec.ptnl_ler_for_per_stat_cd
 ,p_bft_attribute_category_o      =>ben_bft_shd.g_old_rec.bft_attribute_category
 ,p_bft_attribute1_o              =>ben_bft_shd.g_old_rec.bft_attribute1
 ,p_bft_attribute3_o              =>ben_bft_shd.g_old_rec.bft_attribute3
 ,p_bft_attribute4_o              =>ben_bft_shd.g_old_rec.bft_attribute4
 ,p_bft_attribute5_o              =>ben_bft_shd.g_old_rec.bft_attribute5
 ,p_bft_attribute6_o              =>ben_bft_shd.g_old_rec.bft_attribute6
 ,p_bft_attribute7_o              =>ben_bft_shd.g_old_rec.bft_attribute7
 ,p_bft_attribute8_o              =>ben_bft_shd.g_old_rec.bft_attribute8
 ,p_bft_attribute9_o              =>ben_bft_shd.g_old_rec.bft_attribute9
 ,p_bft_attribute10_o             =>ben_bft_shd.g_old_rec.bft_attribute10
 ,p_bft_attribute11_o             =>ben_bft_shd.g_old_rec.bft_attribute11
 ,p_bft_attribute12_o             =>ben_bft_shd.g_old_rec.bft_attribute12
 ,p_bft_attribute13_o             =>ben_bft_shd.g_old_rec.bft_attribute13
 ,p_bft_attribute14_o             =>ben_bft_shd.g_old_rec.bft_attribute14
 ,p_bft_attribute15_o             =>ben_bft_shd.g_old_rec.bft_attribute15
 ,p_bft_attribute16_o             =>ben_bft_shd.g_old_rec.bft_attribute16
 ,p_bft_attribute17_o             =>ben_bft_shd.g_old_rec.bft_attribute17
 ,p_bft_attribute18_o             =>ben_bft_shd.g_old_rec.bft_attribute18
 ,p_bft_attribute19_o             =>ben_bft_shd.g_old_rec.bft_attribute19
 ,p_bft_attribute20_o             =>ben_bft_shd.g_old_rec.bft_attribute20
 ,p_bft_attribute21_o             =>ben_bft_shd.g_old_rec.bft_attribute21
 ,p_bft_attribute22_o             =>ben_bft_shd.g_old_rec.bft_attribute22
 ,p_bft_attribute23_o             =>ben_bft_shd.g_old_rec.bft_attribute23
 ,p_bft_attribute24_o             =>ben_bft_shd.g_old_rec.bft_attribute24
 ,p_bft_attribute25_o             =>ben_bft_shd.g_old_rec.bft_attribute25
 ,p_bft_attribute26_o             =>ben_bft_shd.g_old_rec.bft_attribute26
 ,p_bft_attribute27_o             =>ben_bft_shd.g_old_rec.bft_attribute27
 ,p_bft_attribute28_o             =>ben_bft_shd.g_old_rec.bft_attribute28
 ,p_bft_attribute29_o             =>ben_bft_shd.g_old_rec.bft_attribute29
 ,p_bft_attribute30_o             =>ben_bft_shd.g_old_rec.bft_attribute30
 ,p_enrt_perd_id_o                =>ben_bft_shd.g_old_rec.enrt_perd_id
 ,p_inelg_action_cd_o             =>ben_bft_shd.g_old_rec.inelg_action_cd
 ,p_org_hierarchy_id_o             =>ben_bft_shd.g_old_rec.org_hierarchy_id
 ,p_org_starting_node_id_o             =>ben_bft_shd.g_old_rec.org_starting_node_id
 ,p_grade_ladder_id_o             =>ben_bft_shd.g_old_rec.grade_ladder_id
 ,p_asg_events_to_all_sel_dt_o             =>ben_bft_shd.g_old_rec.asg_events_to_all_sel_dt
 ,p_rate_id_o             =>ben_bft_shd.g_old_rec.rate_id
 ,p_per_sel_dt_cd_o             =>ben_bft_shd.g_old_rec.per_sel_dt_cd
 ,p_per_sel_freq_cd_o             =>ben_bft_shd.g_old_rec.per_sel_freq_cd
 ,p_per_sel_dt_from_o             =>ben_bft_shd.g_old_rec.per_sel_dt_from
 ,p_per_sel_dt_to_o             =>ben_bft_shd.g_old_rec.per_sel_dt_to
 ,p_year_from_o             =>ben_bft_shd.g_old_rec.year_from
 ,p_year_to_o             =>ben_bft_shd.g_old_rec.year_to
 ,p_cagr_id_o             =>ben_bft_shd.g_old_rec.cagr_id
 ,p_qual_type_o             =>ben_bft_shd.g_old_rec.qual_type
 ,p_qual_status_o             =>ben_bft_shd.g_old_rec.qual_status
 ,p_concat_segs_o             =>ben_bft_shd.g_old_rec.concat_segs
 ,p_grant_price_val_o             =>ben_bft_shd.g_old_rec.grant_price_val
 ,p_object_version_number_o       =>ben_bft_shd.g_old_rec.object_version_number
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'ben_benefit_actions'
        ,p_hook_type   => 'AU');
      --
  end;
  --
  -- End of API User Hook for post_update.
  --
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
Procedure convert_defs(p_rec in out nocopy ben_bft_shd.g_rec_type) is
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
  If (p_rec.process_date = hr_api.g_date) then
    p_rec.process_date :=
    ben_bft_shd.g_old_rec.process_date;
  End If;
  If (p_rec.uneai_effective_date = hr_api.g_date) then
    p_rec.uneai_effective_date :=
    ben_bft_shd.g_old_rec.uneai_effective_date;
  End If;
  If (p_rec.mode_cd = hr_api.g_varchar2) then
    p_rec.mode_cd :=
    ben_bft_shd.g_old_rec.mode_cd;
  End If;
  If (p_rec.derivable_factors_flag = hr_api.g_varchar2) then
    p_rec.derivable_factors_flag :=
    ben_bft_shd.g_old_rec.derivable_factors_flag;
  End If;
  If (p_rec.close_uneai_flag = hr_api.g_varchar2) then
    p_rec.close_uneai_flag :=
    ben_bft_shd.g_old_rec.close_uneai_flag      ;
  End If;
  If (p_rec.validate_flag = hr_api.g_varchar2) then
    p_rec.validate_flag :=
    ben_bft_shd.g_old_rec.validate_flag;
  End If;
  If (p_rec.person_id = hr_api.g_number) then
    p_rec.person_id :=
    ben_bft_shd.g_old_rec.person_id;
  End If;
  If (p_rec.person_type_id = hr_api.g_number) then
    p_rec.person_type_id :=
    ben_bft_shd.g_old_rec.person_type_id;
  End If;
  If (p_rec.pgm_id = hr_api.g_number) then
    p_rec.pgm_id :=
    ben_bft_shd.g_old_rec.pgm_id;
  End If;
  If (p_rec.business_group_id = hr_api.g_number) then
    p_rec.business_group_id :=
    ben_bft_shd.g_old_rec.business_group_id;
  End If;
  If (p_rec.pl_id = hr_api.g_number) then
    p_rec.pl_id :=
    ben_bft_shd.g_old_rec.pl_id;
  End If;
  If (p_rec.popl_enrt_typ_cycl_id = hr_api.g_number) then
    p_rec.popl_enrt_typ_cycl_id :=
    ben_bft_shd.g_old_rec.popl_enrt_typ_cycl_id;
  End If;
  If (p_rec.no_programs_flag = hr_api.g_varchar2) then
    p_rec.no_programs_flag :=
    ben_bft_shd.g_old_rec.no_programs_flag;
  End If;
  If (p_rec.no_plans_flag = hr_api.g_varchar2) then
    p_rec.no_plans_flag :=
    ben_bft_shd.g_old_rec.no_plans_flag;
  End If;
  If (p_rec.comp_selection_rl = hr_api.g_number) then
    p_rec.comp_selection_rl :=
    ben_bft_shd.g_old_rec.comp_selection_rl;
  End If;
  If (p_rec.person_selection_rl = hr_api.g_number) then
    p_rec.person_selection_rl :=
    ben_bft_shd.g_old_rec.person_selection_rl;
  End If;
  If (p_rec.ler_id = hr_api.g_number) then
    p_rec.ler_id :=
    ben_bft_shd.g_old_rec.ler_id;
  End If;
  If (p_rec.organization_id = hr_api.g_number) then
    p_rec.organization_id :=
    ben_bft_shd.g_old_rec.organization_id;
  End If;
  If (p_rec.benfts_grp_id = hr_api.g_number) then
    p_rec.benfts_grp_id :=
    ben_bft_shd.g_old_rec.benfts_grp_id;
  End If;
  If (p_rec.location_id = hr_api.g_number) then
    p_rec.location_id :=
    ben_bft_shd.g_old_rec.location_id;
  End If;
  If (p_rec.pstl_zip_rng_id = hr_api.g_number) then
    p_rec.pstl_zip_rng_id :=
    ben_bft_shd.g_old_rec.pstl_zip_rng_id;
  End If;
  If (p_rec.rptg_grp_id = hr_api.g_number) then
    p_rec.rptg_grp_id :=
    ben_bft_shd.g_old_rec.rptg_grp_id;
  End If;
  If (p_rec.pl_typ_id = hr_api.g_number) then
    p_rec.pl_typ_id :=
    ben_bft_shd.g_old_rec.pl_typ_id;
  End If;
  If (p_rec.opt_id = hr_api.g_number) then
    p_rec.opt_id :=
    ben_bft_shd.g_old_rec.opt_id;
  End If;
  If (p_rec.eligy_prfl_id = hr_api.g_number) then
    p_rec.eligy_prfl_id :=
    ben_bft_shd.g_old_rec.eligy_prfl_id;
  End If;
  If (p_rec.vrbl_rt_prfl_id = hr_api.g_number) then
    p_rec.vrbl_rt_prfl_id :=
    ben_bft_shd.g_old_rec.vrbl_rt_prfl_id;
  End If;
  If (p_rec.legal_entity_id = hr_api.g_number) then
    p_rec.legal_entity_id :=
    ben_bft_shd.g_old_rec.legal_entity_id;
  End If;
  If (p_rec.payroll_id = hr_api.g_number) then
    p_rec.payroll_id :=
    ben_bft_shd.g_old_rec.payroll_id;
  End If;
  If (p_rec.debug_messages_flag = hr_api.g_varchar2) then
    p_rec.debug_messages_flag :=
    ben_bft_shd.g_old_rec.debug_messages_flag;
  End If;
  If (p_rec.cm_trgr_typ_cd = hr_api.g_number) then
    p_rec.cm_trgr_typ_cd :=
    ben_bft_shd.g_old_rec.cm_trgr_typ_cd;
  End If;
  If (p_rec.cm_typ_id = hr_api.g_number) then
    p_rec.cm_typ_id :=
    ben_bft_shd.g_old_rec.cm_typ_id;
  End If;
  If (p_rec.age_fctr_id = hr_api.g_number) then
    p_rec.age_fctr_id :=
    ben_bft_shd.g_old_rec.age_fctr_id;
  End If;
  If (p_rec.min_age = hr_api.g_number) then
    p_rec.min_age :=
    ben_bft_shd.g_old_rec.min_age;
  End If;
  If (p_rec.max_age = hr_api.g_number) then
    p_rec.max_age :=
    ben_bft_shd.g_old_rec.max_age;
  End If;
  If (p_rec.los_fctr_id = hr_api.g_number) then
    p_rec.los_fctr_id :=
    ben_bft_shd.g_old_rec.los_fctr_id;
  End If;
  If (p_rec.min_los = hr_api.g_number) then
    p_rec.min_los :=
    ben_bft_shd.g_old_rec.min_los;
  End If;
  If (p_rec.max_los = hr_api.g_number) then
    p_rec.max_los :=
    ben_bft_shd.g_old_rec.max_los;
  End If;
  If (p_rec.cmbn_age_los_fctr_id = hr_api.g_number) then
    p_rec.cmbn_age_los_fctr_id :=
    ben_bft_shd.g_old_rec.cmbn_age_los_fctr_id;
  End If;
  If (p_rec.min_cmbn = hr_api.g_number) then
    p_rec.min_cmbn :=
    ben_bft_shd.g_old_rec.min_cmbn;
  End If;
  If (p_rec.max_cmbn = hr_api.g_number) then
    p_rec.max_cmbn :=
    ben_bft_shd.g_old_rec.max_cmbn;
  End If;
  If (p_rec.date_from = hr_api.g_date) then
    p_rec.date_from :=
    ben_bft_shd.g_old_rec.date_from;
  End If;
  If (p_rec.elig_enrol_cd = hr_api.g_varchar2) then
    p_rec.elig_enrol_cd :=
    ben_bft_shd.g_old_rec.elig_enrol_cd;
  End If;
  If (p_rec.actn_typ_id = hr_api.g_number) then
    p_rec.actn_typ_id :=
    ben_bft_shd.g_old_rec.actn_typ_id;
  End If;
  If (p_rec.use_fctr_to_sel_flag = hr_api.g_varchar2) then
    p_rec.use_fctr_to_sel_flag :=
    ben_bft_shd.g_old_rec.use_fctr_to_sel_flag;
  End If;
  If (p_rec.los_det_to_use_cd = hr_api.g_varchar2) then
    p_rec.los_det_to_use_cd :=
    ben_bft_shd.g_old_rec.los_det_to_use_cd;
  End If;
  If (p_rec.audit_log_flag = hr_api.g_varchar2) then
    p_rec.audit_log_flag :=
    ben_bft_shd.g_old_rec.audit_log_flag;
  End If;
  If (p_rec.lmt_prpnip_by_org_flag = hr_api.g_varchar2) then
    p_rec.lmt_prpnip_by_org_flag :=
    ben_bft_shd.g_old_rec.lmt_prpnip_by_org_flag;
  End If;
  If (p_rec.lf_evt_ocrd_dt = hr_api.g_date) then
    p_rec.lf_evt_ocrd_dt :=
    ben_bft_shd.g_old_rec.lf_evt_ocrd_dt;
  End If;
  If (p_rec.ptnl_ler_for_per_stat_cd = hr_api.g_varchar2) then
    p_rec.ptnl_ler_for_per_stat_cd :=
    ben_bft_shd.g_old_rec.ptnl_ler_for_per_stat_cd;
  End If;
  If (p_rec.bft_attribute_category = hr_api.g_varchar2) then
    p_rec.bft_attribute_category :=
    ben_bft_shd.g_old_rec.bft_attribute_category;
  End If;
  If (p_rec.bft_attribute1 = hr_api.g_varchar2) then
    p_rec.bft_attribute1 :=
    ben_bft_shd.g_old_rec.bft_attribute1;
  End If;
  If (p_rec.bft_attribute3 = hr_api.g_varchar2) then
    p_rec.bft_attribute3 :=
    ben_bft_shd.g_old_rec.bft_attribute3;
  End If;
  If (p_rec.bft_attribute4 = hr_api.g_varchar2) then
    p_rec.bft_attribute4 :=
    ben_bft_shd.g_old_rec.bft_attribute4;
  End If;
  If (p_rec.bft_attribute5 = hr_api.g_varchar2) then
    p_rec.bft_attribute5 :=
    ben_bft_shd.g_old_rec.bft_attribute5;
  End If;
  If (p_rec.bft_attribute6 = hr_api.g_varchar2) then
    p_rec.bft_attribute6 :=
    ben_bft_shd.g_old_rec.bft_attribute6;
  End If;
  If (p_rec.bft_attribute7 = hr_api.g_varchar2) then
    p_rec.bft_attribute7 :=
    ben_bft_shd.g_old_rec.bft_attribute7;
  End If;
  If (p_rec.bft_attribute8 = hr_api.g_varchar2) then
    p_rec.bft_attribute8 :=
    ben_bft_shd.g_old_rec.bft_attribute8;
  End If;
  If (p_rec.bft_attribute9 = hr_api.g_varchar2) then
    p_rec.bft_attribute9 :=
    ben_bft_shd.g_old_rec.bft_attribute9;
  End If;
  If (p_rec.bft_attribute10 = hr_api.g_varchar2) then
    p_rec.bft_attribute10 :=
    ben_bft_shd.g_old_rec.bft_attribute10;
  End If;
  If (p_rec.bft_attribute11 = hr_api.g_varchar2) then
    p_rec.bft_attribute11 :=
    ben_bft_shd.g_old_rec.bft_attribute11;
  End If;
  If (p_rec.bft_attribute12 = hr_api.g_varchar2) then
    p_rec.bft_attribute12 :=
    ben_bft_shd.g_old_rec.bft_attribute12;
  End If;
  If (p_rec.bft_attribute13 = hr_api.g_varchar2) then
    p_rec.bft_attribute13 :=
    ben_bft_shd.g_old_rec.bft_attribute13;
  End If;
  If (p_rec.bft_attribute14 = hr_api.g_varchar2) then
    p_rec.bft_attribute14 :=
    ben_bft_shd.g_old_rec.bft_attribute14;
  End If;
  If (p_rec.bft_attribute15 = hr_api.g_varchar2) then
    p_rec.bft_attribute15 :=
    ben_bft_shd.g_old_rec.bft_attribute15;
  End If;
  If (p_rec.bft_attribute16 = hr_api.g_varchar2) then
    p_rec.bft_attribute16 :=
    ben_bft_shd.g_old_rec.bft_attribute16;
  End If;
  If (p_rec.bft_attribute17 = hr_api.g_varchar2) then
    p_rec.bft_attribute17 :=
    ben_bft_shd.g_old_rec.bft_attribute17;
  End If;
  If (p_rec.bft_attribute18 = hr_api.g_varchar2) then
    p_rec.bft_attribute18 :=
    ben_bft_shd.g_old_rec.bft_attribute18;
  End If;
  If (p_rec.bft_attribute19 = hr_api.g_varchar2) then
    p_rec.bft_attribute19 :=
    ben_bft_shd.g_old_rec.bft_attribute19;
  End If;
  If (p_rec.bft_attribute20 = hr_api.g_varchar2) then
    p_rec.bft_attribute20 :=
    ben_bft_shd.g_old_rec.bft_attribute20;
  End If;
  If (p_rec.bft_attribute21 = hr_api.g_varchar2) then
    p_rec.bft_attribute21 :=
    ben_bft_shd.g_old_rec.bft_attribute21;
  End If;
  If (p_rec.bft_attribute22 = hr_api.g_varchar2) then
    p_rec.bft_attribute22 :=
    ben_bft_shd.g_old_rec.bft_attribute22;
  End If;
  If (p_rec.bft_attribute23 = hr_api.g_varchar2) then
    p_rec.bft_attribute23 :=
    ben_bft_shd.g_old_rec.bft_attribute23;
  End If;
  If (p_rec.bft_attribute24 = hr_api.g_varchar2) then
    p_rec.bft_attribute24 :=
    ben_bft_shd.g_old_rec.bft_attribute24;
  End If;
  If (p_rec.bft_attribute25 = hr_api.g_varchar2) then
    p_rec.bft_attribute25 :=
    ben_bft_shd.g_old_rec.bft_attribute25;
  End If;
  If (p_rec.bft_attribute26 = hr_api.g_varchar2) then
    p_rec.bft_attribute26 :=
    ben_bft_shd.g_old_rec.bft_attribute26;
  End If;
  If (p_rec.bft_attribute27 = hr_api.g_varchar2) then
    p_rec.bft_attribute27 :=
    ben_bft_shd.g_old_rec.bft_attribute27;
  End If;
  If (p_rec.bft_attribute28 = hr_api.g_varchar2) then
    p_rec.bft_attribute28 :=
    ben_bft_shd.g_old_rec.bft_attribute28;
  End If;
  If (p_rec.bft_attribute29 = hr_api.g_varchar2) then
    p_rec.bft_attribute29 :=
    ben_bft_shd.g_old_rec.bft_attribute29;
  End If;
  If (p_rec.bft_attribute30 = hr_api.g_varchar2) then
    p_rec.bft_attribute30 :=
    ben_bft_shd.g_old_rec.bft_attribute30;
  End If;
  If (p_rec.request_id = hr_api.g_number) then
    p_rec.request_id :=
    ben_bft_shd.g_old_rec.request_id;
  End If;
  If (p_rec.program_application_id = hr_api.g_number) then
    p_rec.program_application_id :=
    ben_bft_shd.g_old_rec.program_application_id;
  End If;
  If (p_rec.program_id = hr_api.g_number) then
    p_rec.program_id :=
    ben_bft_shd.g_old_rec.program_id;
  End If;
  If (p_rec.program_update_date = hr_api.g_date) then
    p_rec.program_update_date :=
    ben_bft_shd.g_old_rec.program_update_date;
  End If;
  If (p_rec.enrt_perd_id = hr_api.g_number) then
	    p_rec.enrt_perd_id :=
	    ben_bft_shd.g_old_rec.enrt_perd_id;
  End If;
  If (p_rec.inelg_action_cd = hr_api.g_varchar2) then
		    p_rec.inelg_action_cd:=
		    ben_bft_shd.g_old_rec.inelg_action_cd;
  End If;

  If (p_rec.org_hierarchy_id = hr_api.g_number) then
		    p_rec.org_hierarchy_id:=
		    ben_bft_shd.g_old_rec.org_hierarchy_id;
  End If;

  If (p_rec.org_starting_node_id = hr_api.g_number) then
		    p_rec.org_starting_node_id:=
		    ben_bft_shd.g_old_rec.org_starting_node_id;
  End If;

  If (p_rec.grade_ladder_id = hr_api.g_number) then
		    p_rec.grade_ladder_id:=
		    ben_bft_shd.g_old_rec.grade_ladder_id;
  End If;
  If (p_rec.asg_events_to_all_sel_dt = hr_api.g_varchar2) then
		    p_rec.asg_events_to_all_sel_dt:=
		    ben_bft_shd.g_old_rec.asg_events_to_all_sel_dt;
  End If;
  If (p_rec.rate_id = hr_api.g_number) then
		    p_rec.rate_id:=
		    ben_bft_shd.g_old_rec.rate_id;
  End If;
  If (p_rec.per_sel_dt_cd = hr_api.g_varchar2) then
		    p_rec.per_sel_dt_cd:=
		    ben_bft_shd.g_old_rec.per_sel_dt_cd;
  End If;
  If (p_rec.per_sel_freq_cd = hr_api.g_varchar2) then
		    p_rec.per_sel_freq_cd:=
		    ben_bft_shd.g_old_rec.per_sel_freq_cd;
  End If;
  If (p_rec.per_sel_dt_from = hr_api.g_date) then
		    p_rec.per_sel_dt_from:=
		    ben_bft_shd.g_old_rec.per_sel_dt_from;
  End If;
  If (p_rec.per_sel_dt_to = hr_api.g_date) then
		    p_rec.per_sel_dt_to:=
		    ben_bft_shd.g_old_rec.per_sel_dt_to;
  End If;
  If (p_rec.year_from = hr_api.g_number) then
		    p_rec.year_from:=
		    ben_bft_shd.g_old_rec.year_from;
  End If;
  If (p_rec.year_to = hr_api.g_number) then
		    p_rec.year_to:=
		    ben_bft_shd.g_old_rec.year_to;
  End If;
  If (p_rec.cagr_id = hr_api.g_number) then
		    p_rec.cagr_id:=
		    ben_bft_shd.g_old_rec.cagr_id;
  End If;
  If (p_rec.qual_type = hr_api.g_number) then
		    p_rec.qual_type:=
		    ben_bft_shd.g_old_rec.qual_type;
  End If;
  If (p_rec.qual_status = hr_api.g_varchar2) then
		    p_rec.qual_status:=
		    ben_bft_shd.g_old_rec.qual_status;
  End If;
  If (p_rec.concat_segs = hr_api.g_varchar2) then
		    p_rec.concat_segs:=
		    ben_bft_shd.g_old_rec.concat_segs;
  End If;
  If (p_rec.grant_price_val = hr_api.g_number) then
			    p_rec.grant_price_val:=
			    ben_bft_shd.g_old_rec.grant_price_val;
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
  p_effective_date in date,
  p_rec        in out nocopy ben_bft_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to update.
  --
  ben_bft_shd.lck
	(
	p_rec.benefit_action_id,
	p_rec.object_version_number
	);
  --
  -- 1. During an update system defaults are used to determine if
  --    arguments have been defaulted or not. We must therefore
  --    derive the full record structure values to be updated.
  --
  -- 2. Call the supporting update validate operations.
  --
  convert_defs(p_rec);
  ben_bft_bus.update_validate(p_rec,p_effective_date);
  --
  -- Call the supporting pre-update operation
  --
  pre_update(p_rec);
  --
  -- Update the row.
  --
  update_dml(p_rec);
  --
  -- Call the supporting post-update operation
  --
  post_update(p_effective_date,p_rec);
End upd;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (
  p_effective_date in date,
  p_benefit_action_id            in number,
  p_process_date                 in date             default hr_api.g_date,
  p_uneai_effective_date         in date             default hr_api.g_date,
  p_mode_cd                      in varchar2         default hr_api.g_varchar2,
  p_derivable_factors_flag       in varchar2         default hr_api.g_varchar2,
  p_close_uneai_flag             in varchar2         default hr_api.g_varchar2,
  p_validate_flag                in varchar2         default hr_api.g_varchar2,
  p_person_id                    in number           default hr_api.g_number,
  p_person_type_id               in number           default hr_api.g_number,
  p_pgm_id                       in number           default hr_api.g_number,
  p_business_group_id            in number           default hr_api.g_number,
  p_pl_id                        in number           default hr_api.g_number,
  p_popl_enrt_typ_cycl_id        in number           default hr_api.g_number,
  p_no_programs_flag             in varchar2         default hr_api.g_varchar2,
  p_no_plans_flag                in varchar2         default hr_api.g_varchar2,
  p_comp_selection_rl            in number           default hr_api.g_number,
  p_person_selection_rl          in number           default hr_api.g_number,
  p_ler_id                       in number           default hr_api.g_number,
  p_organization_id              in number           default hr_api.g_number,
  p_benfts_grp_id                in number           default hr_api.g_number,
  p_location_id                  in number           default hr_api.g_number,
  p_pstl_zip_rng_id              in number           default hr_api.g_number,
  p_rptg_grp_id                  in number           default hr_api.g_number,
  p_pl_typ_id                    in number           default hr_api.g_number,
  p_opt_id                       in number           default hr_api.g_number,
  p_eligy_prfl_id                in number           default hr_api.g_number,
  p_vrbl_rt_prfl_id              in number           default hr_api.g_number,
  p_legal_entity_id              in number           default hr_api.g_number,
  p_payroll_id                   in number           default hr_api.g_number,
  p_debug_messages_flag          in varchar2         default hr_api.g_varchar2,
  p_cm_trgr_typ_cd               in varchar2         default hr_api.g_varchar2,
  p_cm_typ_id                    in number           default hr_api.g_number,
  p_age_fctr_id                  in number           default hr_api.g_number,
  p_min_age                      in number           default hr_api.g_number,
  p_max_age                      in number           default hr_api.g_number,
  p_los_fctr_id                  in number           default hr_api.g_number,
  p_min_los                      in number           default hr_api.g_number,
  p_max_los                      in number           default hr_api.g_number,
  p_cmbn_age_los_fctr_id         in number           default hr_api.g_number,
  p_min_cmbn                     in number           default hr_api.g_number,
  p_max_cmbn                     in number           default hr_api.g_number,
  p_date_from                    in date             default hr_api.g_date,
  p_elig_enrol_cd                in varchar2         default hr_api.g_varchar2,
  p_actn_typ_id                  in number           default hr_api.g_number,
  p_use_fctr_to_sel_flag         in varchar2         default hr_api.g_varchar2,
  p_los_det_to_use_cd            in varchar2         default hr_api.g_varchar2,
  p_audit_log_flag               in varchar2         default hr_api.g_varchar2,
  p_lmt_prpnip_by_org_flag       in varchar2         default hr_api.g_varchar2,
  p_lf_evt_ocrd_dt               in date             default hr_api.g_date,
  p_ptnl_ler_for_per_stat_cd     in varchar2         default hr_api.g_varchar2,
  p_bft_attribute_category       in varchar2         default hr_api.g_varchar2,
  p_bft_attribute1               in varchar2         default hr_api.g_varchar2,
  p_bft_attribute3               in varchar2         default hr_api.g_varchar2,
  p_bft_attribute4               in varchar2         default hr_api.g_varchar2,
  p_bft_attribute5               in varchar2         default hr_api.g_varchar2,
  p_bft_attribute6               in varchar2         default hr_api.g_varchar2,
  p_bft_attribute7               in varchar2         default hr_api.g_varchar2,
  p_bft_attribute8               in varchar2         default hr_api.g_varchar2,
  p_bft_attribute9               in varchar2         default hr_api.g_varchar2,
  p_bft_attribute10              in varchar2         default hr_api.g_varchar2,
  p_bft_attribute11              in varchar2         default hr_api.g_varchar2,
  p_bft_attribute12              in varchar2         default hr_api.g_varchar2,
  p_bft_attribute13              in varchar2         default hr_api.g_varchar2,
  p_bft_attribute14              in varchar2         default hr_api.g_varchar2,
  p_bft_attribute15              in varchar2         default hr_api.g_varchar2,
  p_bft_attribute16              in varchar2         default hr_api.g_varchar2,
  p_bft_attribute17              in varchar2         default hr_api.g_varchar2,
  p_bft_attribute18              in varchar2         default hr_api.g_varchar2,
  p_bft_attribute19              in varchar2         default hr_api.g_varchar2,
  p_bft_attribute20              in varchar2         default hr_api.g_varchar2,
  p_bft_attribute21              in varchar2         default hr_api.g_varchar2,
  p_bft_attribute22              in varchar2         default hr_api.g_varchar2,
  p_bft_attribute23              in varchar2         default hr_api.g_varchar2,
  p_bft_attribute24              in varchar2         default hr_api.g_varchar2,
  p_bft_attribute25              in varchar2         default hr_api.g_varchar2,
  p_bft_attribute26              in varchar2         default hr_api.g_varchar2,
  p_bft_attribute27              in varchar2         default hr_api.g_varchar2,
  p_bft_attribute28              in varchar2         default hr_api.g_varchar2,
  p_bft_attribute29              in varchar2         default hr_api.g_varchar2,
  p_bft_attribute30              in varchar2         default hr_api.g_varchar2,
  p_request_id                   in number           default hr_api.g_number,
  p_program_application_id       in number           default hr_api.g_number,
  p_program_id                   in number           default hr_api.g_number,
  p_program_update_date          in date             default hr_api.g_date,
  p_enrt_perd_id                 in number           default hr_api.g_number,
  p_inelg_action_cd              in varchar2         default hr_api.g_varchar2,
  p_org_hierarchy_id              in number         default hr_api.g_number,
  p_org_starting_node_id              in number         default hr_api.g_number,
  p_grade_ladder_id              in number         default hr_api.g_number,
  p_asg_events_to_all_sel_dt              in varchar2         default hr_api.g_varchar2,
  p_rate_id              in number         default hr_api.g_number,
  p_per_sel_dt_cd              in varchar2         default hr_api.g_varchar2,
  p_per_sel_freq_cd              in varchar2         default hr_api.g_varchar2,
  p_per_sel_dt_from              in date         default hr_api.g_date,
  p_per_sel_dt_to              in date         default hr_api.g_date,
  p_year_from              in number         default hr_api.g_number,
  p_year_to              in number         default hr_api.g_number,
  p_cagr_id              in number         default hr_api.g_number,
  p_qual_type              in number         default hr_api.g_number,
  p_qual_status              in varchar2         default hr_api.g_varchar2,
  p_concat_segs              in varchar2         default hr_api.g_varchar2,
  p_grant_price_val              in number           default hr_api.g_number,
  p_object_version_number        in out nocopy number
  ) is
--
  l_rec	  ben_bft_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  ben_bft_shd.convert_args
  (
  p_benefit_action_id,
  p_process_date,
  p_uneai_effective_date,
  p_mode_cd,
  p_derivable_factors_flag,
  p_close_uneai_flag      ,
  p_validate_flag,
  p_person_id,
  p_person_type_id,
  p_pgm_id,
  p_business_group_id,
  p_pl_id,
  p_popl_enrt_typ_cycl_id,
  p_no_programs_flag,
  p_no_plans_flag,
  p_comp_selection_rl,
  p_person_selection_rl,
  p_ler_id,
  p_organization_id,
  p_benfts_grp_id,
  p_location_id,
  p_pstl_zip_rng_id,
  p_rptg_grp_id,
  p_pl_typ_id,
  p_opt_id,
  p_eligy_prfl_id,
  p_vrbl_rt_prfl_id,
  p_legal_entity_id,
  p_payroll_id,
  p_debug_messages_flag,
  p_cm_trgr_typ_cd,
  p_cm_typ_id,
  p_age_fctr_id,
  p_min_age,
  p_max_age,
  p_los_fctr_id,
  p_min_los,
  p_max_los,
  p_cmbn_age_los_fctr_id,
  p_min_cmbn,
  p_max_cmbn,
  p_date_from,
  p_elig_enrol_cd,
  p_actn_typ_id,
  p_use_fctr_to_sel_flag,
  p_los_det_to_use_cd,
  p_audit_log_flag,
  p_lmt_prpnip_by_org_flag,
  p_lf_evt_ocrd_dt,
  p_ptnl_ler_for_per_stat_cd,
  p_bft_attribute_category,
  p_bft_attribute1,
  p_bft_attribute3,
  p_bft_attribute4,
  p_bft_attribute5,
  p_bft_attribute6,
  p_bft_attribute7,
  p_bft_attribute8,
  p_bft_attribute9,
  p_bft_attribute10,
  p_bft_attribute11,
  p_bft_attribute12,
  p_bft_attribute13,
  p_bft_attribute14,
  p_bft_attribute15,
  p_bft_attribute16,
  p_bft_attribute17,
  p_bft_attribute18,
  p_bft_attribute19,
  p_bft_attribute20,
  p_bft_attribute21,
  p_bft_attribute22,
  p_bft_attribute23,
  p_bft_attribute24,
  p_bft_attribute25,
  p_bft_attribute26,
  p_bft_attribute27,
  p_bft_attribute28,
  p_bft_attribute29,
  p_bft_attribute30,
  p_request_id,
  p_program_application_id,
  p_program_id,
  p_program_update_date,
  p_object_version_number,
  p_enrt_perd_id,
  p_inelg_action_cd,
  p_org_hierarchy_id,
  p_org_starting_node_id,
  p_grade_ladder_id,
  p_asg_events_to_all_sel_dt,
  p_rate_id,
  p_per_sel_dt_cd,
  p_per_sel_freq_cd,
  p_per_sel_dt_from,
  p_per_sel_dt_to,
  p_year_from,
  p_year_to,
  p_cagr_id,
  p_qual_type,
  p_qual_status,
  p_concat_segs,
  p_grant_price_val

  );
  --
  -- Having converted the arguments into the
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  upd(p_effective_date,l_rec);
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End upd;
--
end ben_bft_upd;

/
