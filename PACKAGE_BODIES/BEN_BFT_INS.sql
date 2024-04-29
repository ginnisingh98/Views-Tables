--------------------------------------------------------
--  DDL for Package Body BEN_BFT_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_BFT_INS" as
/* $Header: bebftrhi.pkb 115.23 2003/08/18 05:05:29 rpgupta ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_bft_ins.';  -- Global package name
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
Procedure insert_dml(p_rec in out nocopy ben_bft_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'insert_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  p_rec.object_version_number := 1;  -- Initialise the object version
  --
  ben_bft_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Insert the row into: ben_benefit_actions
  --
  insert into ben_benefit_actions
  (	benefit_action_id,
	process_date,
	uneai_effective_date,
	mode_cd,
	derivable_factors_flag,
	close_uneai_flag,
	validate_flag,
	person_id,
	person_type_id,
	pgm_id,
	business_group_id,
	pl_id,
	popl_enrt_typ_cycl_id,
	no_programs_flag,
	no_plans_flag,
	comp_selection_rl,
	person_selection_rl,
	ler_id,
	organization_id,
	benfts_grp_id,
	location_id,
	pstl_zip_rng_id,
	rptg_grp_id,
	pl_typ_id,
	opt_id,
	eligy_prfl_id,
	vrbl_rt_prfl_id,
	legal_entity_id,
	payroll_id,
	debug_messages_flag,
  cm_trgr_typ_cd,
  cm_typ_id,
  age_fctr_id,
  min_age,
  max_age,
  los_fctr_id,
  min_los,
  max_los,
  cmbn_age_los_fctr_id,
  min_cmbn,
  max_cmbn,
  date_from,
  elig_enrol_cd,
  actn_typ_id,
  use_fctr_to_sel_flag,
  los_det_to_use_cd,
  audit_log_flag,
  lmt_prpnip_by_org_flag,
  lf_evt_ocrd_dt,
  ptnl_ler_for_per_stat_cd,
	bft_attribute_category,
	bft_attribute1,
	bft_attribute3,
	bft_attribute4,
	bft_attribute5,
	bft_attribute6,
	bft_attribute7,
	bft_attribute8,
	bft_attribute9,
	bft_attribute10,
	bft_attribute11,
	bft_attribute12,
	bft_attribute13,
	bft_attribute14,
	bft_attribute15,
	bft_attribute16,
	bft_attribute17,
	bft_attribute18,
	bft_attribute19,
	bft_attribute20,
	bft_attribute21,
	bft_attribute22,
	bft_attribute23,
	bft_attribute24,
	bft_attribute25,
	bft_attribute26,
	bft_attribute27,
	bft_attribute28,
	bft_attribute29,
	bft_attribute30,
  request_id,
  program_application_id,
  program_id,
  program_update_date,
	object_version_number,
	enrt_perd_id,
	inelg_action_cd,
	org_hierarchy_id,
	org_starting_node_id,
	grade_ladder_id,
	asg_events_to_all_sel_dt,
	rate_id,
	per_sel_dt_cd,
	per_sel_freq_cd,
	per_sel_dt_from,
	per_sel_dt_to,
	year_from,
	year_to,
	cagr_id,
	qual_type,
	qual_status,
	concat_segs,
  grant_price_val
  )
  Values
  (	p_rec.benefit_action_id,
	p_rec.process_date,
	p_rec.uneai_effective_date,
	p_rec.mode_cd,
	p_rec.derivable_factors_flag,
	p_rec.close_uneai_flag,
	p_rec.validate_flag,
	p_rec.person_id,
	p_rec.person_type_id,
	p_rec.pgm_id,
	p_rec.business_group_id,
	p_rec.pl_id,
	p_rec.popl_enrt_typ_cycl_id,
	p_rec.no_programs_flag,
	p_rec.no_plans_flag,
	p_rec.comp_selection_rl,
	p_rec.person_selection_rl,
	p_rec.ler_id,
	p_rec.organization_id,
	p_rec.benfts_grp_id,
	p_rec.location_id,
	p_rec.pstl_zip_rng_id,
	p_rec.rptg_grp_id,
	p_rec.pl_typ_id,
	p_rec.opt_id,
	p_rec.eligy_prfl_id,
	p_rec.vrbl_rt_prfl_id,
	p_rec.legal_entity_id,
	p_rec.payroll_id,
	p_rec.debug_messages_flag,
  p_rec.cm_trgr_typ_cd,
  p_rec.cm_typ_id,
  p_rec.age_fctr_id,
  p_rec.min_age,
  p_rec.max_age,
  p_rec.los_fctr_id,
  p_rec.min_los,
  p_rec.max_los,
  p_rec.cmbn_age_los_fctr_id,
  p_rec.min_cmbn,
  p_rec.max_cmbn,
  p_rec.date_from,
  p_rec.elig_enrol_cd,
  p_rec.actn_typ_id,
  p_rec.use_fctr_to_sel_flag,
  p_rec.los_det_to_use_cd,
  p_rec.audit_log_flag,
  p_rec.lmt_prpnip_by_org_flag,
  p_rec.lf_evt_ocrd_dt,
  p_rec.ptnl_ler_for_per_stat_cd,
	p_rec.bft_attribute_category,
	p_rec.bft_attribute1,
	p_rec.bft_attribute3,
	p_rec.bft_attribute4,
	p_rec.bft_attribute5,
	p_rec.bft_attribute6,
	p_rec.bft_attribute7,
	p_rec.bft_attribute8,
	p_rec.bft_attribute9,
	p_rec.bft_attribute10,
	p_rec.bft_attribute11,
	p_rec.bft_attribute12,
	p_rec.bft_attribute13,
	p_rec.bft_attribute14,
	p_rec.bft_attribute15,
	p_rec.bft_attribute16,
	p_rec.bft_attribute17,
	p_rec.bft_attribute18,
	p_rec.bft_attribute19,
	p_rec.bft_attribute20,
	p_rec.bft_attribute21,
	p_rec.bft_attribute22,
	p_rec.bft_attribute23,
	p_rec.bft_attribute24,
	p_rec.bft_attribute25,
	p_rec.bft_attribute26,
	p_rec.bft_attribute27,
	p_rec.bft_attribute28,
	p_rec.bft_attribute29,
	p_rec.bft_attribute30,
  p_rec.request_id,
  p_rec.program_application_id,
  p_rec.program_id,
  p_rec.program_update_date,
	p_rec.object_version_number,
	p_rec.enrt_perd_id,
	p_rec.inelg_action_cd,
	p_rec.org_hierarchy_id,
	p_rec.org_starting_node_id,
	p_rec.grade_ladder_id,
	p_rec.asg_events_to_all_sel_dt,
	p_rec.rate_id,
	p_rec.per_sel_dt_cd,
	p_rec.per_sel_freq_cd,
	p_rec.per_sel_dt_from,
	p_rec.per_sel_dt_to,
	p_rec.year_from,
	p_rec.year_to,
	p_rec.cagr_id,
	p_rec.qual_type,
	p_rec.qual_status,
	p_rec.concat_segs,
  p_rec.grant_price_val
  );
  --
  ben_bft_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
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
Procedure pre_insert(p_rec  in out nocopy ben_bft_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'pre_insert';
--
  Cursor C_Sel1 is select ben_benefit_actions_s.nextval from sys.dual;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  -- Select the next sequence number
  --
  Open C_Sel1;
  Fetch C_Sel1 Into p_rec.benefit_action_id;
  Close C_Sel1;
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
Procedure post_insert(
p_effective_date in date,p_rec in ben_bft_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'post_insert';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
--
  --
  -- Start of API User Hook for post_insert.
  --
  begin
    --
    ben_bft_rki.after_insert
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
 ,p_object_version_number         =>p_rec.object_version_number
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'ben_benefit_actions'
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
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (
  p_effective_date in date,
  p_rec        in out nocopy ben_bft_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call the supporting insert validate operations
  --
  ben_bft_bus.insert_validate(p_rec,p_effective_date);
  --
  -- Call the supporting pre-insert operation
  --
  pre_insert(p_rec);
  --
  -- Insert the row
  --
  insert_dml(p_rec);
  --
  -- Call the supporting post-insert operation
  --
  post_insert(p_effective_date,p_rec);
end ins;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (
  p_effective_date in date,
  p_benefit_action_id            out nocopy number,
  p_process_date                 in date,
  p_uneai_effective_date         in date,
  p_mode_cd                      in varchar2,
  p_derivable_factors_flag       in varchar2,
  p_close_uneai_flag             in varchar2,
  p_validate_flag                in varchar2,
  p_person_id                    in number           default null,
  p_person_type_id               in number           default null,
  p_pgm_id                       in number           default null,
  p_business_group_id            in number,
  p_pl_id                        in number           default null,
  p_popl_enrt_typ_cycl_id        in number           default null,
  p_no_programs_flag             in varchar2,
  p_no_plans_flag                in varchar2,
  p_comp_selection_rl            in number           default null,
  p_person_selection_rl          in number           default null,
  p_ler_id                       in number           default null,
  p_organization_id              in number           default null,
  p_benfts_grp_id                in number           default null,
  p_location_id                  in number           default null,
  p_pstl_zip_rng_id              in number           default null,
  p_rptg_grp_id                  in number           default null,
  p_pl_typ_id                    in number           default null,
  p_opt_id                       in number           default null,
  p_eligy_prfl_id                in number           default null,
  p_vrbl_rt_prfl_id              in number           default null,
  p_legal_entity_id              in number           default null,
  p_payroll_id                   in number           default null,
  p_debug_messages_flag          in varchar2,
  p_cm_trgr_typ_cd               in varchar2         default null,
  p_cm_typ_id                    in number           default null,
  p_age_fctr_id                  in number           default null,
  p_min_age                      in number           default null,
  p_max_age                      in number           default null,
  p_los_fctr_id                  in number           default null,
  p_min_los                      in number           default null,
  p_max_los                      in number           default null,
  p_cmbn_age_los_fctr_id         in number           default null,
  p_min_cmbn                     in number           default null,
  p_max_cmbn                     in number           default null,
  p_date_from                    in date             default null,
  p_elig_enrol_cd                in varchar2         default null,
  p_actn_typ_id                  in number           default null,
  p_use_fctr_to_sel_flag         in varchar2         default 'N',
  p_los_det_to_use_cd            in varchar2         default null,
  p_audit_log_flag               in varchar2         default 'N',
  p_lmt_prpnip_by_org_flag       in varchar2         default 'N',
  p_lf_evt_ocrd_dt               in date             default null,
  p_ptnl_ler_for_per_stat_cd     in varchar2         default null,
  p_bft_attribute_category       in varchar2         default null,
  p_bft_attribute1               in varchar2         default null,
  p_bft_attribute3               in varchar2         default null,
  p_bft_attribute4               in varchar2         default null,
  p_bft_attribute5               in varchar2         default null,
  p_bft_attribute6               in varchar2         default null,
  p_bft_attribute7               in varchar2         default null,
  p_bft_attribute8               in varchar2         default null,
  p_bft_attribute9               in varchar2         default null,
  p_bft_attribute10              in varchar2         default null,
  p_bft_attribute11              in varchar2         default null,
  p_bft_attribute12              in varchar2         default null,
  p_bft_attribute13              in varchar2         default null,
  p_bft_attribute14              in varchar2         default null,
  p_bft_attribute15              in varchar2         default null,
  p_bft_attribute16              in varchar2         default null,
  p_bft_attribute17              in varchar2         default null,
  p_bft_attribute18              in varchar2         default null,
  p_bft_attribute19              in varchar2         default null,
  p_bft_attribute20              in varchar2         default null,
  p_bft_attribute21              in varchar2         default null,
  p_bft_attribute22              in varchar2         default null,
  p_bft_attribute23              in varchar2         default null,
  p_bft_attribute24              in varchar2         default null,
  p_bft_attribute25              in varchar2         default null,
  p_bft_attribute26              in varchar2         default null,
  p_bft_attribute27              in varchar2         default null,
  p_bft_attribute28              in varchar2         default null,
  p_bft_attribute29              in varchar2         default null,
  p_bft_attribute30              in varchar2         default null,
  p_request_id                   in number           default null,
  p_program_application_id       in number           default null,
  p_program_id                   in number           default null,
  p_program_update_date          in date             default null,
  p_enrt_perd_id                 in number           default null,
  p_inelg_action_cd              in varchar2         default null,
  p_org_hierarchy_id              in number         default null,
  p_org_starting_node_id              in number         default null,
  p_grade_ladder_id              in number         default null,
  p_asg_events_to_all_sel_dt              in varchar2         default null,
  p_rate_id              in number         default null,
  p_per_sel_dt_cd              in varchar2         default null,
  p_per_sel_freq_cd              in varchar2         default null,
  p_per_sel_dt_from              in date         default null,
  p_per_sel_dt_to              in date         default null,
  p_year_from              in number         default null,
  p_year_to              in number         default null,
  p_cagr_id              in number         default null,
  p_qual_type              in number         default null,
  p_qual_status              in varchar2         default null,
  p_concat_segs              in varchar2         default null,
  p_grant_price_val              in number           default null,
  p_object_version_number        out nocopy number
  ) is
--
  l_rec	  ben_bft_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  ben_bft_shd.convert_args
  (
  null,
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
  null,
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
  -- Having converted the arguments into the ben_bft_rec
  -- plsql record structure we call the corresponding record business process.
  --
  ins(p_effective_date,l_rec);
  --
  -- As the primary key argument(s)
  -- are specified as an OUT's we must set these values.
  --
  p_benefit_action_id := l_rec.benefit_action_id;
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End ins;
--
end ben_bft_ins;

/
