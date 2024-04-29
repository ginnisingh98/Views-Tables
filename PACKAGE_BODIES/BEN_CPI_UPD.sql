--------------------------------------------------------
--  DDL for Package Body BEN_CPI_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_CPI_UPD" as
/* $Header: becpirhi.pkb 120.0 2005/05/28 01:13 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  ben_cpi_upd.';  -- Global package name
g_debug boolean := hr_utility.debug_enabled;
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
  (p_rec in out nocopy ben_cpi_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'update_dml';
--
Begin
  if g_debug then
     hr_utility.set_location('Entering:'||l_proc, 5);
  end if;
  --
  -- Increment the object version
  p_rec.object_version_number := p_rec.object_version_number + 1;
  --
  ben_cpi_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Update the ben_cwb_person_info Row
  --
  update ben_cwb_person_info
    set
     assignment_id                   = p_rec.assignment_id
    ,person_id                       = p_rec.person_id
    ,supervisor_id                   = p_rec.supervisor_id
    ,effective_date                  = p_rec.effective_date
    ,full_name                       = p_rec.full_name
    ,brief_name                      = p_rec.brief_name
    ,custom_name                     = p_rec.custom_name
    ,supervisor_full_name            = p_rec.supervisor_full_name
    ,supervisor_brief_name           = p_rec.supervisor_brief_name
    ,supervisor_custom_name          = p_rec.supervisor_custom_name
    ,legislation_code                = p_rec.legislation_code
    ,years_employed                  = p_rec.years_employed
    ,years_in_job                    = p_rec.years_in_job
    ,years_in_position               = p_rec.years_in_position
    ,years_in_grade                  = p_rec.years_in_grade
    ,employee_number                 = p_rec.employee_number
    ,start_date                      = p_rec.start_date
    ,original_start_date             = p_rec.original_start_date
    ,adjusted_svc_date               = p_rec.adjusted_svc_date
    ,base_salary                     = p_rec.base_salary
    ,base_salary_change_date         = p_rec.base_salary_change_date
    ,payroll_name                    = p_rec.payroll_name
    ,performance_rating              = p_rec.performance_rating
    ,performance_rating_type         = p_rec.performance_rating_type
    ,performance_rating_date         = p_rec.performance_rating_date
    ,business_group_id               = p_rec.business_group_id
    ,organization_id                 = p_rec.organization_id
    ,job_id                          = p_rec.job_id
    ,grade_id                        = p_rec.grade_id
    ,position_id                     = p_rec.position_id
    ,people_group_id                 = p_rec.people_group_id
    ,soft_coding_keyflex_id          = p_rec.soft_coding_keyflex_id
    ,location_id                     = p_rec.location_id
    ,pay_rate_id                     = p_rec.pay_rate_id
    ,assignment_status_type_id       = p_rec.assignment_status_type_id
    ,frequency                       = p_rec.frequency
    ,grade_annulization_factor       = p_rec.grade_annulization_factor
    ,pay_annulization_factor         = p_rec.pay_annulization_factor
    ,grd_min_val                     = p_rec.grd_min_val
    ,grd_max_val                     = p_rec.grd_max_val
    ,grd_mid_point                   = p_rec.grd_mid_point
    ,grd_quartile                    = p_rec.grd_quartile
    ,grd_comparatio                  = p_rec.grd_comparatio
    ,emp_category                    = p_rec.emp_category
    ,change_reason                   = p_rec.change_reason
    ,normal_hours                    = p_rec.normal_hours
    ,email_address                   = p_rec.email_address
    ,base_salary_frequency           = p_rec.base_salary_frequency
    ,new_assgn_ovn                   = p_rec.new_assgn_ovn
    ,new_perf_event_id               = p_rec.new_perf_event_id
    ,new_perf_review_id              = p_rec.new_perf_review_id
    ,post_process_stat_cd            = p_rec.post_process_stat_cd
    ,feedback_rating                 = p_rec.feedback_rating
    ,feedback_comments               = p_rec.feedback_comments
    ,object_version_number           = p_rec.object_version_number
    ,custom_segment1                 = p_rec.custom_segment1
    ,custom_segment2                 = p_rec.custom_segment2
    ,custom_segment3                 = p_rec.custom_segment3
    ,custom_segment4                 = p_rec.custom_segment4
    ,custom_segment5                 = p_rec.custom_segment5
    ,custom_segment6                 = p_rec.custom_segment6
    ,custom_segment7                 = p_rec.custom_segment7
    ,custom_segment8                 = p_rec.custom_segment8
    ,custom_segment9                 = p_rec.custom_segment9
    ,custom_segment10                = p_rec.custom_segment10
    ,custom_segment11                = p_rec.custom_segment11
    ,custom_segment12                = p_rec.custom_segment12
    ,custom_segment13                = p_rec.custom_segment13
    ,custom_segment14                = p_rec.custom_segment14
    ,custom_segment15                = p_rec.custom_segment15
    ,custom_segment16                = p_rec.custom_segment16
    ,custom_segment17                = p_rec.custom_segment17
    ,custom_segment18                = p_rec.custom_segment18
    ,custom_segment19                = p_rec.custom_segment19
    ,custom_segment20                = p_rec.custom_segment20
    ,people_group_name               = p_rec.people_group_name
    ,people_group_segment1           = p_rec.people_group_segment1
    ,people_group_segment2           = p_rec.people_group_segment2
    ,people_group_segment3           = p_rec.people_group_segment3
    ,people_group_segment4           = p_rec.people_group_segment4
    ,people_group_segment5           = p_rec.people_group_segment5
    ,people_group_segment6           = p_rec.people_group_segment6
    ,people_group_segment7           = p_rec.people_group_segment7
    ,people_group_segment8           = p_rec.people_group_segment8
    ,people_group_segment9           = p_rec.people_group_segment9
    ,people_group_segment10          = p_rec.people_group_segment10
    ,people_group_segment11          = p_rec.people_group_segment11
    ,ass_attribute_category          = p_rec.ass_attribute_category
    ,ass_attribute1                  = p_rec.ass_attribute1
    ,ass_attribute2                  = p_rec.ass_attribute2
    ,ass_attribute3                  = p_rec.ass_attribute3
    ,ass_attribute4                  = p_rec.ass_attribute4
    ,ass_attribute5                  = p_rec.ass_attribute5
    ,ass_attribute6                  = p_rec.ass_attribute6
    ,ass_attribute7                  = p_rec.ass_attribute7
    ,ass_attribute8                  = p_rec.ass_attribute8
    ,ass_attribute9                  = p_rec.ass_attribute9
    ,ass_attribute10                 = p_rec.ass_attribute10
    ,ass_attribute11                 = p_rec.ass_attribute11
    ,ass_attribute12                 = p_rec.ass_attribute12
    ,ass_attribute13                 = p_rec.ass_attribute13
    ,ass_attribute14                 = p_rec.ass_attribute14
    ,ass_attribute15                 = p_rec.ass_attribute15
    ,ass_attribute16                 = p_rec.ass_attribute16
    ,ass_attribute17                 = p_rec.ass_attribute17
    ,ass_attribute18                 = p_rec.ass_attribute18
    ,ass_attribute19                 = p_rec.ass_attribute19
    ,ass_attribute20                 = p_rec.ass_attribute20
    ,ass_attribute21                 = p_rec.ass_attribute21
    ,ass_attribute22                 = p_rec.ass_attribute22
    ,ass_attribute23                 = p_rec.ass_attribute23
    ,ass_attribute24                 = p_rec.ass_attribute24
    ,ass_attribute25                 = p_rec.ass_attribute25
    ,ass_attribute26                 = p_rec.ass_attribute26
    ,ass_attribute27                 = p_rec.ass_attribute27
    ,ass_attribute28                 = p_rec.ass_attribute28
    ,ass_attribute29                 = p_rec.ass_attribute29
    ,ass_attribute30                 = p_rec.ass_attribute30
    ,ws_comments                     = p_rec.ws_comments
    ,cpi_attribute_category          = p_rec.cpi_attribute_category
    ,cpi_attribute1                  = p_rec.cpi_attribute1
    ,cpi_attribute2                  = p_rec.cpi_attribute2
    ,cpi_attribute3                  = p_rec.cpi_attribute3
    ,cpi_attribute4                  = p_rec.cpi_attribute4
    ,cpi_attribute5                  = p_rec.cpi_attribute5
    ,cpi_attribute6                  = p_rec.cpi_attribute6
    ,cpi_attribute7                  = p_rec.cpi_attribute7
    ,cpi_attribute8                  = p_rec.cpi_attribute8
    ,cpi_attribute9                  = p_rec.cpi_attribute9
    ,cpi_attribute10                 = p_rec.cpi_attribute10
    ,cpi_attribute11                 = p_rec.cpi_attribute11
    ,cpi_attribute12                 = p_rec.cpi_attribute12
    ,cpi_attribute13                 = p_rec.cpi_attribute13
    ,cpi_attribute14                 = p_rec.cpi_attribute14
    ,cpi_attribute15                 = p_rec.cpi_attribute15
    ,cpi_attribute16                 = p_rec.cpi_attribute16
    ,cpi_attribute17                 = p_rec.cpi_attribute17
    ,cpi_attribute18                 = p_rec.cpi_attribute18
    ,cpi_attribute19                 = p_rec.cpi_attribute19
    ,cpi_attribute20                 = p_rec.cpi_attribute20
    ,cpi_attribute21                 = p_rec.cpi_attribute21
    ,cpi_attribute22                 = p_rec.cpi_attribute22
    ,cpi_attribute23                 = p_rec.cpi_attribute23
    ,cpi_attribute24                 = p_rec.cpi_attribute24
    ,cpi_attribute25                 = p_rec.cpi_attribute25
    ,cpi_attribute26                 = p_rec.cpi_attribute26
    ,cpi_attribute27                 = p_rec.cpi_attribute27
    ,cpi_attribute28                 = p_rec.cpi_attribute28
    ,cpi_attribute29                 = p_rec.cpi_attribute29
    ,cpi_attribute30                 = p_rec.cpi_attribute30
    ,feedback_date                   = p_rec.feedback_date
    where group_per_in_ler_id = p_rec.group_per_in_ler_id;
  --
  ben_cpi_shd.g_api_dml := false;   -- Unset the api dml status
  --
  if g_debug then
     hr_utility.set_location(' Leaving:'||l_proc, 10);
  end if;
--
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    ben_cpi_shd.g_api_dml := false;   -- Unset the api dml status
    ben_cpi_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    ben_cpi_shd.g_api_dml := false;   -- Unset the api dml status
    ben_cpi_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    ben_cpi_shd.g_api_dml := false;   -- Unset the api dml status
    ben_cpi_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    ben_cpi_shd.g_api_dml := false;   -- Unset the api dml status
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
  (p_rec in ben_cpi_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'pre_update';
--
Begin
  if g_debug then
     hr_utility.set_location('Entering:'||l_proc, 5);
  end if;
  --
  if g_debug then
     hr_utility.set_location(' Leaving:'||l_proc, 10);
  end if;
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
  (p_rec                          in ben_cpi_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'post_update';
--
Begin
  if g_debug then
     hr_utility.set_location('Entering:'||l_proc, 5);
  end if;
  begin
    --
    ben_cpi_rku.after_update
      (p_group_per_in_ler_id
      => p_rec.group_per_in_ler_id
      ,p_assignment_id
      => p_rec.assignment_id
      ,p_person_id
      => p_rec.person_id
      ,p_supervisor_id
      => p_rec.supervisor_id
      ,p_effective_date
      => p_rec.effective_date
      ,p_full_name
      => p_rec.full_name
      ,p_brief_name
      => p_rec.brief_name
      ,p_custom_name
      => p_rec.custom_name
      ,p_supervisor_full_name
      => p_rec.supervisor_full_name
      ,p_supervisor_brief_name
      => p_rec.supervisor_brief_name
      ,p_supervisor_custom_name
      => p_rec.supervisor_custom_name
      ,p_legislation_code
      => p_rec.legislation_code
      ,p_years_employed
      => p_rec.years_employed
      ,p_years_in_job
      => p_rec.years_in_job
      ,p_years_in_position
      => p_rec.years_in_position
      ,p_years_in_grade
      => p_rec.years_in_grade
      ,p_employee_number
      => p_rec.employee_number
      ,p_start_date
      => p_rec.start_date
      ,p_original_start_date
      => p_rec.original_start_date
      ,p_adjusted_svc_date
      => p_rec.adjusted_svc_date
      ,p_base_salary
      => p_rec.base_salary
      ,p_base_salary_change_date
      => p_rec.base_salary_change_date
      ,p_payroll_name
      => p_rec.payroll_name
      ,p_performance_rating
      => p_rec.performance_rating
      ,p_performance_rating_type
      => p_rec.performance_rating_type
      ,p_performance_rating_date
      => p_rec.performance_rating_date
      ,p_business_group_id
      => p_rec.business_group_id
      ,p_organization_id
      => p_rec.organization_id
      ,p_job_id
      => p_rec.job_id
      ,p_grade_id
      => p_rec.grade_id
      ,p_position_id
      => p_rec.position_id
      ,p_people_group_id
      => p_rec.people_group_id
      ,p_soft_coding_keyflex_id
      => p_rec.soft_coding_keyflex_id
      ,p_location_id
      => p_rec.location_id
      ,p_pay_rate_id
      => p_rec.pay_rate_id
      ,p_assignment_status_type_id
      => p_rec.assignment_status_type_id
      ,p_frequency
      => p_rec.frequency
      ,p_grade_annulization_factor
      => p_rec.grade_annulization_factor
      ,p_pay_annulization_factor
      => p_rec.pay_annulization_factor
      ,p_grd_min_val
      => p_rec.grd_min_val
      ,p_grd_max_val
      => p_rec.grd_max_val
      ,p_grd_mid_point
      => p_rec.grd_mid_point
      ,p_grd_quartile
      => p_rec.grd_quartile
      ,p_grd_comparatio
      => p_rec.grd_comparatio
      ,p_emp_category
      => p_rec.emp_category
      ,p_change_reason
      => p_rec.change_reason
      ,p_normal_hours
      => p_rec.normal_hours
      ,p_email_address
      => p_rec.email_address
      ,p_base_salary_frequency
      => p_rec.base_salary_frequency
      ,p_new_assgn_ovn
      => p_rec.new_assgn_ovn
      ,p_new_perf_event_id
      => p_rec.new_perf_event_id
      ,p_new_perf_review_id
      => p_rec.new_perf_review_id
      ,p_post_process_stat_cd
      => p_rec.post_process_stat_cd
      ,p_feedback_rating
      => p_rec.feedback_rating
      ,p_feedback_comments
      => p_rec.feedback_comments
      ,p_object_version_number
      => p_rec.object_version_number
      ,p_custom_segment1
      => p_rec.custom_segment1
      ,p_custom_segment2
      => p_rec.custom_segment2
      ,p_custom_segment3
      => p_rec.custom_segment3
      ,p_custom_segment4
      => p_rec.custom_segment4
      ,p_custom_segment5
      => p_rec.custom_segment5
      ,p_custom_segment6
      => p_rec.custom_segment6
      ,p_custom_segment7
      => p_rec.custom_segment7
      ,p_custom_segment8
      => p_rec.custom_segment8
      ,p_custom_segment9
      => p_rec.custom_segment9
      ,p_custom_segment10
      => p_rec.custom_segment10
      ,p_custom_segment11
      => p_rec.custom_segment11
      ,p_custom_segment12
      => p_rec.custom_segment12
      ,p_custom_segment13
      => p_rec.custom_segment13
      ,p_custom_segment14
      => p_rec.custom_segment14
      ,p_custom_segment15
      => p_rec.custom_segment15
      ,p_custom_segment16
      => p_rec.custom_segment16
      ,p_custom_segment17
      => p_rec.custom_segment17
      ,p_custom_segment18
      => p_rec.custom_segment18
      ,p_custom_segment19
      => p_rec.custom_segment19
      ,p_custom_segment20
      => p_rec.custom_segment20
      ,p_people_group_name
      => p_rec.people_group_name
      ,p_people_group_segment1
      => p_rec.people_group_segment1
      ,p_people_group_segment2
      => p_rec.people_group_segment2
      ,p_people_group_segment3
      => p_rec.people_group_segment3
      ,p_people_group_segment4
      => p_rec.people_group_segment4
      ,p_people_group_segment5
      => p_rec.people_group_segment5
      ,p_people_group_segment6
      => p_rec.people_group_segment6
      ,p_people_group_segment7
      => p_rec.people_group_segment7
      ,p_people_group_segment8
      => p_rec.people_group_segment8
      ,p_people_group_segment9
      => p_rec.people_group_segment9
      ,p_people_group_segment10
      => p_rec.people_group_segment10
      ,p_people_group_segment11
      => p_rec.people_group_segment11
      ,p_ass_attribute_category
      => p_rec.ass_attribute_category
      ,p_ass_attribute1
      => p_rec.ass_attribute1
      ,p_ass_attribute2
      => p_rec.ass_attribute2
      ,p_ass_attribute3
      => p_rec.ass_attribute3
      ,p_ass_attribute4
      => p_rec.ass_attribute4
      ,p_ass_attribute5
      => p_rec.ass_attribute5
      ,p_ass_attribute6
      => p_rec.ass_attribute6
      ,p_ass_attribute7
      => p_rec.ass_attribute7
      ,p_ass_attribute8
      => p_rec.ass_attribute8
      ,p_ass_attribute9
      => p_rec.ass_attribute9
      ,p_ass_attribute10
      => p_rec.ass_attribute10
      ,p_ass_attribute11
      => p_rec.ass_attribute11
      ,p_ass_attribute12
      => p_rec.ass_attribute12
      ,p_ass_attribute13
      => p_rec.ass_attribute13
      ,p_ass_attribute14
      => p_rec.ass_attribute14
      ,p_ass_attribute15
      => p_rec.ass_attribute15
      ,p_ass_attribute16
      => p_rec.ass_attribute16
      ,p_ass_attribute17
      => p_rec.ass_attribute17
      ,p_ass_attribute18
      => p_rec.ass_attribute18
      ,p_ass_attribute19
      => p_rec.ass_attribute19
      ,p_ass_attribute20
      => p_rec.ass_attribute20
      ,p_ass_attribute21
      => p_rec.ass_attribute21
      ,p_ass_attribute22
      => p_rec.ass_attribute22
      ,p_ass_attribute23
      => p_rec.ass_attribute23
      ,p_ass_attribute24
      => p_rec.ass_attribute24
      ,p_ass_attribute25
      => p_rec.ass_attribute25
      ,p_ass_attribute26
      => p_rec.ass_attribute26
      ,p_ass_attribute27
      => p_rec.ass_attribute27
      ,p_ass_attribute28
      => p_rec.ass_attribute28
      ,p_ass_attribute29
      => p_rec.ass_attribute29
      ,p_ass_attribute30
      => p_rec.ass_attribute30
      ,p_ws_comments
      => p_rec.ws_comments
      ,p_cpi_attribute_category
      => p_rec.cpi_attribute_category
      ,p_cpi_attribute1
      => p_rec.cpi_attribute1
      ,p_cpi_attribute2
      => p_rec.cpi_attribute2
      ,p_cpi_attribute3
      => p_rec.cpi_attribute3
      ,p_cpi_attribute4
      => p_rec.cpi_attribute4
      ,p_cpi_attribute5
      => p_rec.cpi_attribute5
      ,p_cpi_attribute6
      => p_rec.cpi_attribute6
      ,p_cpi_attribute7
      => p_rec.cpi_attribute7
      ,p_cpi_attribute8
      => p_rec.cpi_attribute8
      ,p_cpi_attribute9
      => p_rec.cpi_attribute9
      ,p_cpi_attribute10
      => p_rec.cpi_attribute10
      ,p_cpi_attribute11
      => p_rec.cpi_attribute11
      ,p_cpi_attribute12
      => p_rec.cpi_attribute12
      ,p_cpi_attribute13
      => p_rec.cpi_attribute13
      ,p_cpi_attribute14
      => p_rec.cpi_attribute14
      ,p_cpi_attribute15
      => p_rec.cpi_attribute15
      ,p_cpi_attribute16
      => p_rec.cpi_attribute16
      ,p_cpi_attribute17
      => p_rec.cpi_attribute17
      ,p_cpi_attribute18
      => p_rec.cpi_attribute18
      ,p_cpi_attribute19
      => p_rec.cpi_attribute19
      ,p_cpi_attribute20
      => p_rec.cpi_attribute20
      ,p_cpi_attribute21
      => p_rec.cpi_attribute21
      ,p_cpi_attribute22
      => p_rec.cpi_attribute22
      ,p_cpi_attribute23
      => p_rec.cpi_attribute23
      ,p_cpi_attribute24
      => p_rec.cpi_attribute24
      ,p_cpi_attribute25
      => p_rec.cpi_attribute25
      ,p_cpi_attribute26
      => p_rec.cpi_attribute26
      ,p_cpi_attribute27
      => p_rec.cpi_attribute27
      ,p_cpi_attribute28
      => p_rec.cpi_attribute28
      ,p_cpi_attribute29
      => p_rec.cpi_attribute29
      ,p_cpi_attribute30
      => p_rec.cpi_attribute30
      ,p_feedback_date
      => p_rec.feedback_date
      ,p_assignment_id_o
      => ben_cpi_shd.g_old_rec.assignment_id
      ,p_person_id_o
      => ben_cpi_shd.g_old_rec.person_id
      ,p_supervisor_id_o
      => ben_cpi_shd.g_old_rec.supervisor_id
      ,p_effective_date_o
      => ben_cpi_shd.g_old_rec.effective_date
      ,p_full_name_o
      => ben_cpi_shd.g_old_rec.full_name
      ,p_brief_name_o
      => ben_cpi_shd.g_old_rec.brief_name
      ,p_custom_name_o
      => ben_cpi_shd.g_old_rec.custom_name
      ,p_supervisor_full_name_o
      => ben_cpi_shd.g_old_rec.supervisor_full_name
      ,p_supervisor_brief_name_o
      => ben_cpi_shd.g_old_rec.supervisor_brief_name
      ,p_supervisor_custom_name_o
      => ben_cpi_shd.g_old_rec.supervisor_custom_name
      ,p_legislation_code_o
      => ben_cpi_shd.g_old_rec.legislation_code
      ,p_years_employed_o
      => ben_cpi_shd.g_old_rec.years_employed
      ,p_years_in_job_o
      => ben_cpi_shd.g_old_rec.years_in_job
      ,p_years_in_position_o
      => ben_cpi_shd.g_old_rec.years_in_position
      ,p_years_in_grade_o
      => ben_cpi_shd.g_old_rec.years_in_grade
      ,p_employee_number_o
      => ben_cpi_shd.g_old_rec.employee_number
      ,p_start_date_o
      => ben_cpi_shd.g_old_rec.start_date
      ,p_original_start_date_o
      => ben_cpi_shd.g_old_rec.original_start_date
      ,p_adjusted_svc_date_o
      => ben_cpi_shd.g_old_rec.adjusted_svc_date
      ,p_base_salary_o
      => ben_cpi_shd.g_old_rec.base_salary
      ,p_base_salary_change_date_o
      => ben_cpi_shd.g_old_rec.base_salary_change_date
      ,p_payroll_name_o
      => ben_cpi_shd.g_old_rec.payroll_name
      ,p_performance_rating_o
      => ben_cpi_shd.g_old_rec.performance_rating
      ,p_performance_rating_type_o
      => ben_cpi_shd.g_old_rec.performance_rating_type
      ,p_performance_rating_date_o
      => ben_cpi_shd.g_old_rec.performance_rating_date
      ,p_business_group_id_o
      => ben_cpi_shd.g_old_rec.business_group_id
      ,p_organization_id_o
      => ben_cpi_shd.g_old_rec.organization_id
      ,p_job_id_o
      => ben_cpi_shd.g_old_rec.job_id
      ,p_grade_id_o
      => ben_cpi_shd.g_old_rec.grade_id
      ,p_position_id_o
      => ben_cpi_shd.g_old_rec.position_id
      ,p_people_group_id_o
      => ben_cpi_shd.g_old_rec.people_group_id
      ,p_soft_coding_keyflex_id_o
      => ben_cpi_shd.g_old_rec.soft_coding_keyflex_id
      ,p_location_id_o
      => ben_cpi_shd.g_old_rec.location_id
      ,p_pay_rate_id_o
      => ben_cpi_shd.g_old_rec.pay_rate_id
      ,p_assignment_status_type_id_o
      => ben_cpi_shd.g_old_rec.assignment_status_type_id
      ,p_frequency_o
      => ben_cpi_shd.g_old_rec.frequency
      ,p_grade_annulization_factor_o
      => ben_cpi_shd.g_old_rec.grade_annulization_factor
      ,p_pay_annulization_factor_o
      => ben_cpi_shd.g_old_rec.pay_annulization_factor
      ,p_grd_min_val_o
      => ben_cpi_shd.g_old_rec.grd_min_val
      ,p_grd_max_val_o
      => ben_cpi_shd.g_old_rec.grd_max_val
      ,p_grd_mid_point_o
      => ben_cpi_shd.g_old_rec.grd_mid_point
      ,p_grd_quartile_o
      => ben_cpi_shd.g_old_rec.grd_quartile
      ,p_grd_comparatio_o
      => ben_cpi_shd.g_old_rec.grd_comparatio
      ,p_emp_category_o
      => ben_cpi_shd.g_old_rec.emp_category
      ,p_change_reason_o
      => ben_cpi_shd.g_old_rec.change_reason
      ,p_normal_hours_o
      => ben_cpi_shd.g_old_rec.normal_hours
      ,p_email_address_o
      => ben_cpi_shd.g_old_rec.email_address
      ,p_base_salary_frequency_o
      => ben_cpi_shd.g_old_rec.base_salary_frequency
      ,p_new_assgn_ovn_o
      => ben_cpi_shd.g_old_rec.new_assgn_ovn
      ,p_new_perf_event_id_o
      => ben_cpi_shd.g_old_rec.new_perf_event_id
      ,p_new_perf_review_id_o
      => ben_cpi_shd.g_old_rec.new_perf_review_id
      ,p_post_process_stat_cd_o
      => ben_cpi_shd.g_old_rec.post_process_stat_cd
      ,p_feedback_rating_o
      => ben_cpi_shd.g_old_rec.feedback_rating
      ,p_feedback_comments_o
      => ben_cpi_shd.g_old_rec.feedback_comments
      ,p_object_version_number_o
      => ben_cpi_shd.g_old_rec.object_version_number
      ,p_custom_segment1_o
      => ben_cpi_shd.g_old_rec.custom_segment1
      ,p_custom_segment2_o
      => ben_cpi_shd.g_old_rec.custom_segment2
      ,p_custom_segment3_o
      => ben_cpi_shd.g_old_rec.custom_segment3
      ,p_custom_segment4_o
      => ben_cpi_shd.g_old_rec.custom_segment4
      ,p_custom_segment5_o
      => ben_cpi_shd.g_old_rec.custom_segment5
      ,p_custom_segment6_o
      => ben_cpi_shd.g_old_rec.custom_segment6
      ,p_custom_segment7_o
      => ben_cpi_shd.g_old_rec.custom_segment7
      ,p_custom_segment8_o
      => ben_cpi_shd.g_old_rec.custom_segment8
      ,p_custom_segment9_o
      => ben_cpi_shd.g_old_rec.custom_segment9
      ,p_custom_segment10_o
      => ben_cpi_shd.g_old_rec.custom_segment10
      ,p_custom_segment11_o
      => ben_cpi_shd.g_old_rec.custom_segment11
      ,p_custom_segment12_o
      => ben_cpi_shd.g_old_rec.custom_segment12
      ,p_custom_segment13_o
      => ben_cpi_shd.g_old_rec.custom_segment13
      ,p_custom_segment14_o
      => ben_cpi_shd.g_old_rec.custom_segment14
      ,p_custom_segment15_o
      => ben_cpi_shd.g_old_rec.custom_segment15
      ,p_custom_segment16_o
      => ben_cpi_shd.g_old_rec.custom_segment16
      ,p_custom_segment17_o
      => ben_cpi_shd.g_old_rec.custom_segment17
      ,p_custom_segment18_o
      => ben_cpi_shd.g_old_rec.custom_segment18
      ,p_custom_segment19_o
      => ben_cpi_shd.g_old_rec.custom_segment19
      ,p_custom_segment20_o
      => ben_cpi_shd.g_old_rec.custom_segment20
      ,p_people_group_name_o
      => ben_cpi_shd.g_old_rec.people_group_name
      ,p_people_group_segment1_o
      => ben_cpi_shd.g_old_rec.people_group_segment1
      ,p_people_group_segment2_o
      => ben_cpi_shd.g_old_rec.people_group_segment2
      ,p_people_group_segment3_o
      => ben_cpi_shd.g_old_rec.people_group_segment3
      ,p_people_group_segment4_o
      => ben_cpi_shd.g_old_rec.people_group_segment4
      ,p_people_group_segment5_o
      => ben_cpi_shd.g_old_rec.people_group_segment5
      ,p_people_group_segment6_o
      => ben_cpi_shd.g_old_rec.people_group_segment6
      ,p_people_group_segment7_o
      => ben_cpi_shd.g_old_rec.people_group_segment7
      ,p_people_group_segment8_o
      => ben_cpi_shd.g_old_rec.people_group_segment8
      ,p_people_group_segment9_o
      => ben_cpi_shd.g_old_rec.people_group_segment9
      ,p_people_group_segment10_o
      => ben_cpi_shd.g_old_rec.people_group_segment10
      ,p_people_group_segment11_o
      => ben_cpi_shd.g_old_rec.people_group_segment11
      ,p_ass_attribute_category_o
      => ben_cpi_shd.g_old_rec.ass_attribute_category
      ,p_ass_attribute1_o
      => ben_cpi_shd.g_old_rec.ass_attribute1
      ,p_ass_attribute2_o
      => ben_cpi_shd.g_old_rec.ass_attribute2
      ,p_ass_attribute3_o
      => ben_cpi_shd.g_old_rec.ass_attribute3
      ,p_ass_attribute4_o
      => ben_cpi_shd.g_old_rec.ass_attribute4
      ,p_ass_attribute5_o
      => ben_cpi_shd.g_old_rec.ass_attribute5
      ,p_ass_attribute6_o
      => ben_cpi_shd.g_old_rec.ass_attribute6
      ,p_ass_attribute7_o
      => ben_cpi_shd.g_old_rec.ass_attribute7
      ,p_ass_attribute8_o
      => ben_cpi_shd.g_old_rec.ass_attribute8
      ,p_ass_attribute9_o
      => ben_cpi_shd.g_old_rec.ass_attribute9
      ,p_ass_attribute10_o
      => ben_cpi_shd.g_old_rec.ass_attribute10
      ,p_ass_attribute11_o
      => ben_cpi_shd.g_old_rec.ass_attribute11
      ,p_ass_attribute12_o
      => ben_cpi_shd.g_old_rec.ass_attribute12
      ,p_ass_attribute13_o
      => ben_cpi_shd.g_old_rec.ass_attribute13
      ,p_ass_attribute14_o
      => ben_cpi_shd.g_old_rec.ass_attribute14
      ,p_ass_attribute15_o
      => ben_cpi_shd.g_old_rec.ass_attribute15
      ,p_ass_attribute16_o
      => ben_cpi_shd.g_old_rec.ass_attribute16
      ,p_ass_attribute17_o
      => ben_cpi_shd.g_old_rec.ass_attribute17
      ,p_ass_attribute18_o
      => ben_cpi_shd.g_old_rec.ass_attribute18
      ,p_ass_attribute19_o
      => ben_cpi_shd.g_old_rec.ass_attribute19
      ,p_ass_attribute20_o
      => ben_cpi_shd.g_old_rec.ass_attribute20
      ,p_ass_attribute21_o
      => ben_cpi_shd.g_old_rec.ass_attribute21
      ,p_ass_attribute22_o
      => ben_cpi_shd.g_old_rec.ass_attribute22
      ,p_ass_attribute23_o
      => ben_cpi_shd.g_old_rec.ass_attribute23
      ,p_ass_attribute24_o
      => ben_cpi_shd.g_old_rec.ass_attribute24
      ,p_ass_attribute25_o
      => ben_cpi_shd.g_old_rec.ass_attribute25
      ,p_ass_attribute26_o
      => ben_cpi_shd.g_old_rec.ass_attribute26
      ,p_ass_attribute27_o
      => ben_cpi_shd.g_old_rec.ass_attribute27
      ,p_ass_attribute28_o
      => ben_cpi_shd.g_old_rec.ass_attribute28
      ,p_ass_attribute29_o
      => ben_cpi_shd.g_old_rec.ass_attribute29
      ,p_ass_attribute30_o
      => ben_cpi_shd.g_old_rec.ass_attribute30
      ,p_ws_comments_o
      => ben_cpi_shd.g_old_rec.ws_comments
      ,p_cpi_attribute_category_o
      => ben_cpi_shd.g_old_rec.cpi_attribute_category
      ,p_cpi_attribute1_o
      => ben_cpi_shd.g_old_rec.cpi_attribute1
      ,p_cpi_attribute2_o
      => ben_cpi_shd.g_old_rec.cpi_attribute2
      ,p_cpi_attribute3_o
      => ben_cpi_shd.g_old_rec.cpi_attribute3
      ,p_cpi_attribute4_o
      => ben_cpi_shd.g_old_rec.cpi_attribute4
      ,p_cpi_attribute5_o
      => ben_cpi_shd.g_old_rec.cpi_attribute5
      ,p_cpi_attribute6_o
      => ben_cpi_shd.g_old_rec.cpi_attribute6
      ,p_cpi_attribute7_o
      => ben_cpi_shd.g_old_rec.cpi_attribute7
      ,p_cpi_attribute8_o
      => ben_cpi_shd.g_old_rec.cpi_attribute8
      ,p_cpi_attribute9_o
      => ben_cpi_shd.g_old_rec.cpi_attribute9
      ,p_cpi_attribute10_o
      => ben_cpi_shd.g_old_rec.cpi_attribute10
      ,p_cpi_attribute11_o
      => ben_cpi_shd.g_old_rec.cpi_attribute11
      ,p_cpi_attribute12_o
      => ben_cpi_shd.g_old_rec.cpi_attribute12
      ,p_cpi_attribute13_o
      => ben_cpi_shd.g_old_rec.cpi_attribute13
      ,p_cpi_attribute14_o
      => ben_cpi_shd.g_old_rec.cpi_attribute14
      ,p_cpi_attribute15_o
      => ben_cpi_shd.g_old_rec.cpi_attribute15
      ,p_cpi_attribute16_o
      => ben_cpi_shd.g_old_rec.cpi_attribute16
      ,p_cpi_attribute17_o
      => ben_cpi_shd.g_old_rec.cpi_attribute17
      ,p_cpi_attribute18_o
      => ben_cpi_shd.g_old_rec.cpi_attribute18
      ,p_cpi_attribute19_o
      => ben_cpi_shd.g_old_rec.cpi_attribute19
      ,p_cpi_attribute20_o
      => ben_cpi_shd.g_old_rec.cpi_attribute20
      ,p_cpi_attribute21_o
      => ben_cpi_shd.g_old_rec.cpi_attribute21
      ,p_cpi_attribute22_o
      => ben_cpi_shd.g_old_rec.cpi_attribute22
      ,p_cpi_attribute23_o
      => ben_cpi_shd.g_old_rec.cpi_attribute23
      ,p_cpi_attribute24_o
      => ben_cpi_shd.g_old_rec.cpi_attribute24
      ,p_cpi_attribute25_o
      => ben_cpi_shd.g_old_rec.cpi_attribute25
      ,p_cpi_attribute26_o
      => ben_cpi_shd.g_old_rec.cpi_attribute26
      ,p_cpi_attribute27_o
      => ben_cpi_shd.g_old_rec.cpi_attribute27
      ,p_cpi_attribute28_o
      => ben_cpi_shd.g_old_rec.cpi_attribute28
      ,p_cpi_attribute29_o
      => ben_cpi_shd.g_old_rec.cpi_attribute29
      ,p_cpi_attribute30_o
      => ben_cpi_shd.g_old_rec.cpi_attribute30
      ,p_feedback_date_o
      => ben_cpi_shd.g_old_rec.feedback_date
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'BEN_CWB_PERSON_INFO'
        ,p_hook_type   => 'AU');
      --
  end;
  --
  if g_debug then
     hr_utility.set_location(' Leaving:'||l_proc, 10);
  end if;
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
  (p_rec in out nocopy ben_cpi_shd.g_rec_type
  ) is
--
Begin
  --
  -- We must now examine each argument value in the
  -- p_rec plsql record structure
  -- to see if a system default is being used. If a system default
  -- is being used then we must set to the 'current' argument value.
  --
  If (p_rec.assignment_id = hr_api.g_number) then
    p_rec.assignment_id :=
    ben_cpi_shd.g_old_rec.assignment_id;
  End If;
  If (p_rec.person_id = hr_api.g_number) then
    p_rec.person_id :=
    ben_cpi_shd.g_old_rec.person_id;
  End If;
  If (p_rec.supervisor_id = hr_api.g_number) then
    p_rec.supervisor_id :=
    ben_cpi_shd.g_old_rec.supervisor_id;
  End If;
  If (p_rec.effective_date = hr_api.g_date) then
    p_rec.effective_date :=
    ben_cpi_shd.g_old_rec.effective_date;
  End If;
  If (p_rec.full_name = hr_api.g_varchar2) then
    p_rec.full_name :=
    ben_cpi_shd.g_old_rec.full_name;
  End If;
  If (p_rec.brief_name = hr_api.g_varchar2) then
    p_rec.brief_name :=
    ben_cpi_shd.g_old_rec.brief_name;
  End If;
  If (p_rec.custom_name = hr_api.g_varchar2) then
    p_rec.custom_name :=
    ben_cpi_shd.g_old_rec.custom_name;
  End If;
  If (p_rec.supervisor_full_name = hr_api.g_varchar2) then
    p_rec.supervisor_full_name :=
    ben_cpi_shd.g_old_rec.supervisor_full_name;
  End If;
  If (p_rec.supervisor_brief_name = hr_api.g_varchar2) then
    p_rec.supervisor_brief_name :=
    ben_cpi_shd.g_old_rec.supervisor_brief_name;
  End If;
  If (p_rec.supervisor_custom_name = hr_api.g_varchar2) then
    p_rec.supervisor_custom_name :=
    ben_cpi_shd.g_old_rec.supervisor_custom_name;
  End If;
  If (p_rec.legislation_code = hr_api.g_varchar2) then
    p_rec.legislation_code :=
    ben_cpi_shd.g_old_rec.legislation_code;
  End If;
  If (p_rec.years_employed = hr_api.g_number) then
    p_rec.years_employed :=
    ben_cpi_shd.g_old_rec.years_employed;
  End If;
  If (p_rec.years_in_job = hr_api.g_number) then
    p_rec.years_in_job :=
    ben_cpi_shd.g_old_rec.years_in_job;
  End If;
  If (p_rec.years_in_position = hr_api.g_number) then
    p_rec.years_in_position :=
    ben_cpi_shd.g_old_rec.years_in_position;
  End If;
  If (p_rec.years_in_grade = hr_api.g_number) then
    p_rec.years_in_grade :=
    ben_cpi_shd.g_old_rec.years_in_grade;
  End If;
  If (p_rec.employee_number = hr_api.g_varchar2) then
    p_rec.employee_number :=
    ben_cpi_shd.g_old_rec.employee_number;
  End If;
  If (p_rec.start_date = hr_api.g_date) then
    p_rec.start_date :=
    ben_cpi_shd.g_old_rec.start_date;
  End If;
  If (p_rec.original_start_date = hr_api.g_date) then
    p_rec.original_start_date :=
    ben_cpi_shd.g_old_rec.original_start_date;
  End If;
  If (p_rec.adjusted_svc_date = hr_api.g_date) then
    p_rec.adjusted_svc_date :=
    ben_cpi_shd.g_old_rec.adjusted_svc_date;
  End If;
  If (p_rec.base_salary = hr_api.g_number) then
    p_rec.base_salary :=
    ben_cpi_shd.g_old_rec.base_salary;
  End If;
  If (p_rec.base_salary_change_date = hr_api.g_date) then
    p_rec.base_salary_change_date :=
    ben_cpi_shd.g_old_rec.base_salary_change_date;
  End If;
  If (p_rec.payroll_name = hr_api.g_varchar2) then
    p_rec.payroll_name :=
    ben_cpi_shd.g_old_rec.payroll_name;
  End If;
  If (p_rec.performance_rating = hr_api.g_varchar2) then
    p_rec.performance_rating :=
    ben_cpi_shd.g_old_rec.performance_rating;
  End If;
  If (p_rec.performance_rating_type = hr_api.g_varchar2) then
    p_rec.performance_rating_type :=
    ben_cpi_shd.g_old_rec.performance_rating_type;
  End If;
  If (p_rec.performance_rating_date = hr_api.g_date) then
    p_rec.performance_rating_date :=
    ben_cpi_shd.g_old_rec.performance_rating_date;
  End If;
  If (p_rec.business_group_id = hr_api.g_number) then
    p_rec.business_group_id :=
    ben_cpi_shd.g_old_rec.business_group_id;
  End If;
  If (p_rec.organization_id = hr_api.g_number) then
    p_rec.organization_id :=
    ben_cpi_shd.g_old_rec.organization_id;
  End If;
  If (p_rec.job_id = hr_api.g_number) then
    p_rec.job_id :=
    ben_cpi_shd.g_old_rec.job_id;
  End If;
  If (p_rec.grade_id = hr_api.g_number) then
    p_rec.grade_id :=
    ben_cpi_shd.g_old_rec.grade_id;
  End If;
  If (p_rec.position_id = hr_api.g_number) then
    p_rec.position_id :=
    ben_cpi_shd.g_old_rec.position_id;
  End If;
  If (p_rec.people_group_id = hr_api.g_number) then
    p_rec.people_group_id :=
    ben_cpi_shd.g_old_rec.people_group_id;
  End If;
  If (p_rec.soft_coding_keyflex_id = hr_api.g_number) then
    p_rec.soft_coding_keyflex_id :=
    ben_cpi_shd.g_old_rec.soft_coding_keyflex_id;
  End If;
  If (p_rec.location_id = hr_api.g_number) then
    p_rec.location_id :=
    ben_cpi_shd.g_old_rec.location_id;
  End If;
  If (p_rec.pay_rate_id = hr_api.g_number) then
    p_rec.pay_rate_id :=
    ben_cpi_shd.g_old_rec.pay_rate_id;
  End If;
  If (p_rec.assignment_status_type_id = hr_api.g_number) then
    p_rec.assignment_status_type_id :=
    ben_cpi_shd.g_old_rec.assignment_status_type_id;
  End If;
  If (p_rec.frequency = hr_api.g_varchar2) then
    p_rec.frequency :=
    ben_cpi_shd.g_old_rec.frequency;
  End If;
  If (p_rec.grade_annulization_factor = hr_api.g_number) then
    p_rec.grade_annulization_factor :=
    ben_cpi_shd.g_old_rec.grade_annulization_factor;
  End If;
  If (p_rec.pay_annulization_factor = hr_api.g_number) then
    p_rec.pay_annulization_factor :=
    ben_cpi_shd.g_old_rec.pay_annulization_factor;
  End If;
  If (p_rec.grd_min_val = hr_api.g_number) then
    p_rec.grd_min_val :=
    ben_cpi_shd.g_old_rec.grd_min_val;
  End If;
  If (p_rec.grd_max_val = hr_api.g_number) then
    p_rec.grd_max_val :=
    ben_cpi_shd.g_old_rec.grd_max_val;
  End If;
  If (p_rec.grd_mid_point = hr_api.g_number) then
    p_rec.grd_mid_point :=
    ben_cpi_shd.g_old_rec.grd_mid_point;
  End If;
  If (p_rec.grd_quartile = hr_api.g_varchar2) then
    p_rec.grd_quartile :=
    ben_cpi_shd.g_old_rec.grd_quartile;
  End If;
  If (p_rec.grd_comparatio = hr_api.g_number) then
    p_rec.grd_comparatio :=
    ben_cpi_shd.g_old_rec.grd_comparatio;
  End If;
  If (p_rec.emp_category = hr_api.g_varchar2) then
    p_rec.emp_category :=
    ben_cpi_shd.g_old_rec.emp_category;
  End If;
  If (p_rec.change_reason = hr_api.g_varchar2) then
    p_rec.change_reason :=
    ben_cpi_shd.g_old_rec.change_reason;
  End If;
  If (p_rec.normal_hours = hr_api.g_number) then
    p_rec.normal_hours :=
    ben_cpi_shd.g_old_rec.normal_hours;
  End If;
  If (p_rec.email_address = hr_api.g_varchar2) then
    p_rec.email_address :=
    ben_cpi_shd.g_old_rec.email_address;
  End If;
  If (p_rec.base_salary_frequency = hr_api.g_varchar2) then
    p_rec.base_salary_frequency :=
    ben_cpi_shd.g_old_rec.base_salary_frequency;
  End If;
  If (p_rec.new_assgn_ovn = hr_api.g_number) then
    p_rec.new_assgn_ovn :=
    ben_cpi_shd.g_old_rec.new_assgn_ovn;
  End If;
  If (p_rec.new_perf_event_id = hr_api.g_number) then
    p_rec.new_perf_event_id :=
    ben_cpi_shd.g_old_rec.new_perf_event_id;
  End If;
  If (p_rec.new_perf_review_id = hr_api.g_number) then
    p_rec.new_perf_review_id :=
    ben_cpi_shd.g_old_rec.new_perf_review_id;
  End If;
  If (p_rec.post_process_stat_cd = hr_api.g_varchar2) then
    p_rec.post_process_stat_cd :=
    ben_cpi_shd.g_old_rec.post_process_stat_cd;
  End If;
  If (p_rec.feedback_rating = hr_api.g_varchar2) then
    p_rec.feedback_rating :=
    ben_cpi_shd.g_old_rec.feedback_rating;
  End If;
  If (p_rec.feedback_comments = hr_api.g_varchar2) then
    p_rec.feedback_comments :=
    ben_cpi_shd.g_old_rec.feedback_comments;
  End If;
  If (p_rec.custom_segment1 = hr_api.g_varchar2) then
    p_rec.custom_segment1 :=
    ben_cpi_shd.g_old_rec.custom_segment1;
  End If;
  If (p_rec.custom_segment2 = hr_api.g_varchar2) then
    p_rec.custom_segment2 :=
    ben_cpi_shd.g_old_rec.custom_segment2;
  End If;
  If (p_rec.custom_segment3 = hr_api.g_varchar2) then
    p_rec.custom_segment3 :=
    ben_cpi_shd.g_old_rec.custom_segment3;
  End If;
  If (p_rec.custom_segment4 = hr_api.g_varchar2) then
    p_rec.custom_segment4 :=
    ben_cpi_shd.g_old_rec.custom_segment4;
  End If;
  If (p_rec.custom_segment5 = hr_api.g_varchar2) then
    p_rec.custom_segment5 :=
    ben_cpi_shd.g_old_rec.custom_segment5;
  End If;
  If (p_rec.custom_segment6 = hr_api.g_varchar2) then
    p_rec.custom_segment6 :=
    ben_cpi_shd.g_old_rec.custom_segment6;
  End If;
  If (p_rec.custom_segment7 = hr_api.g_varchar2) then
    p_rec.custom_segment7 :=
    ben_cpi_shd.g_old_rec.custom_segment7;
  End If;
  If (p_rec.custom_segment8 = hr_api.g_varchar2) then
    p_rec.custom_segment8 :=
    ben_cpi_shd.g_old_rec.custom_segment8;
  End If;
  If (p_rec.custom_segment9 = hr_api.g_varchar2) then
    p_rec.custom_segment9 :=
    ben_cpi_shd.g_old_rec.custom_segment9;
  End If;
  If (p_rec.custom_segment10 = hr_api.g_varchar2) then
    p_rec.custom_segment10 :=
    ben_cpi_shd.g_old_rec.custom_segment10;
  End If;
  If (p_rec.custom_segment11 = hr_api.g_number) then
    p_rec.custom_segment11 :=
    ben_cpi_shd.g_old_rec.custom_segment11;
  End If;
  If (p_rec.custom_segment12 = hr_api.g_number) then
    p_rec.custom_segment12 :=
    ben_cpi_shd.g_old_rec.custom_segment12;
  End If;
  If (p_rec.custom_segment13 = hr_api.g_number) then
    p_rec.custom_segment13 :=
    ben_cpi_shd.g_old_rec.custom_segment13;
  End If;
  If (p_rec.custom_segment14 = hr_api.g_number) then
    p_rec.custom_segment14 :=
    ben_cpi_shd.g_old_rec.custom_segment14;
  End If;
  If (p_rec.custom_segment15 = hr_api.g_number) then
    p_rec.custom_segment15 :=
    ben_cpi_shd.g_old_rec.custom_segment15;
  End If;
  If (p_rec.custom_segment16 = hr_api.g_number) then
    p_rec.custom_segment16 :=
    ben_cpi_shd.g_old_rec.custom_segment16;
  End If;
  If (p_rec.custom_segment17 = hr_api.g_number) then
    p_rec.custom_segment17 :=
    ben_cpi_shd.g_old_rec.custom_segment17;
  End If;
  If (p_rec.custom_segment18 = hr_api.g_number) then
    p_rec.custom_segment18 :=
    ben_cpi_shd.g_old_rec.custom_segment18;
  End If;
  If (p_rec.custom_segment19 = hr_api.g_number) then
    p_rec.custom_segment19 :=
    ben_cpi_shd.g_old_rec.custom_segment19;
  End If;
  If (p_rec.custom_segment20 = hr_api.g_number) then
    p_rec.custom_segment20 :=
    ben_cpi_shd.g_old_rec.custom_segment20;
  End If;
  If (p_rec.people_group_name = hr_api.g_varchar2) then
    p_rec.people_group_name :=
    ben_cpi_shd.g_old_rec.people_group_name;
  End If;
  If (p_rec.people_group_segment1 = hr_api.g_varchar2) then
    p_rec.people_group_segment1 :=
    ben_cpi_shd.g_old_rec.people_group_segment1;
  End If;
  If (p_rec.people_group_segment2 = hr_api.g_varchar2) then
    p_rec.people_group_segment2 :=
    ben_cpi_shd.g_old_rec.people_group_segment2;
  End If;
  If (p_rec.people_group_segment3 = hr_api.g_varchar2) then
    p_rec.people_group_segment3 :=
    ben_cpi_shd.g_old_rec.people_group_segment3;
  End If;
  If (p_rec.people_group_segment4 = hr_api.g_varchar2) then
    p_rec.people_group_segment4 :=
    ben_cpi_shd.g_old_rec.people_group_segment4;
  End If;
  If (p_rec.people_group_segment5 = hr_api.g_varchar2) then
    p_rec.people_group_segment5 :=
    ben_cpi_shd.g_old_rec.people_group_segment5;
  End If;
  If (p_rec.people_group_segment6 = hr_api.g_varchar2) then
    p_rec.people_group_segment6 :=
    ben_cpi_shd.g_old_rec.people_group_segment6;
  End If;
  If (p_rec.people_group_segment7 = hr_api.g_varchar2) then
    p_rec.people_group_segment7 :=
    ben_cpi_shd.g_old_rec.people_group_segment7;
  End If;
  If (p_rec.people_group_segment8 = hr_api.g_varchar2) then
    p_rec.people_group_segment8 :=
    ben_cpi_shd.g_old_rec.people_group_segment8;
  End If;
  If (p_rec.people_group_segment9 = hr_api.g_varchar2) then
    p_rec.people_group_segment9 :=
    ben_cpi_shd.g_old_rec.people_group_segment9;
  End If;
  If (p_rec.people_group_segment10 = hr_api.g_varchar2) then
    p_rec.people_group_segment10 :=
    ben_cpi_shd.g_old_rec.people_group_segment10;
  End If;
  If (p_rec.people_group_segment11 = hr_api.g_varchar2) then
    p_rec.people_group_segment11 :=
    ben_cpi_shd.g_old_rec.people_group_segment11;
  End If;
  If (p_rec.ass_attribute_category = hr_api.g_varchar2) then
    p_rec.ass_attribute_category :=
    ben_cpi_shd.g_old_rec.ass_attribute_category;
  End If;
  If (p_rec.ass_attribute1 = hr_api.g_varchar2) then
    p_rec.ass_attribute1 :=
    ben_cpi_shd.g_old_rec.ass_attribute1;
  End If;
  If (p_rec.ass_attribute2 = hr_api.g_varchar2) then
    p_rec.ass_attribute2 :=
    ben_cpi_shd.g_old_rec.ass_attribute2;
  End If;
  If (p_rec.ass_attribute3 = hr_api.g_varchar2) then
    p_rec.ass_attribute3 :=
    ben_cpi_shd.g_old_rec.ass_attribute3;
  End If;
  If (p_rec.ass_attribute4 = hr_api.g_varchar2) then
    p_rec.ass_attribute4 :=
    ben_cpi_shd.g_old_rec.ass_attribute4;
  End If;
  If (p_rec.ass_attribute5 = hr_api.g_varchar2) then
    p_rec.ass_attribute5 :=
    ben_cpi_shd.g_old_rec.ass_attribute5;
  End If;
  If (p_rec.ass_attribute6 = hr_api.g_varchar2) then
    p_rec.ass_attribute6 :=
    ben_cpi_shd.g_old_rec.ass_attribute6;
  End If;
  If (p_rec.ass_attribute7 = hr_api.g_varchar2) then
    p_rec.ass_attribute7 :=
    ben_cpi_shd.g_old_rec.ass_attribute7;
  End If;
  If (p_rec.ass_attribute8 = hr_api.g_varchar2) then
    p_rec.ass_attribute8 :=
    ben_cpi_shd.g_old_rec.ass_attribute8;
  End If;
  If (p_rec.ass_attribute9 = hr_api.g_varchar2) then
    p_rec.ass_attribute9 :=
    ben_cpi_shd.g_old_rec.ass_attribute9;
  End If;
  If (p_rec.ass_attribute10 = hr_api.g_varchar2) then
    p_rec.ass_attribute10 :=
    ben_cpi_shd.g_old_rec.ass_attribute10;
  End If;
  If (p_rec.ass_attribute11 = hr_api.g_varchar2) then
    p_rec.ass_attribute11 :=
    ben_cpi_shd.g_old_rec.ass_attribute11;
  End If;
  If (p_rec.ass_attribute12 = hr_api.g_varchar2) then
    p_rec.ass_attribute12 :=
    ben_cpi_shd.g_old_rec.ass_attribute12;
  End If;
  If (p_rec.ass_attribute13 = hr_api.g_varchar2) then
    p_rec.ass_attribute13 :=
    ben_cpi_shd.g_old_rec.ass_attribute13;
  End If;
  If (p_rec.ass_attribute14 = hr_api.g_varchar2) then
    p_rec.ass_attribute14 :=
    ben_cpi_shd.g_old_rec.ass_attribute14;
  End If;
  If (p_rec.ass_attribute15 = hr_api.g_varchar2) then
    p_rec.ass_attribute15 :=
    ben_cpi_shd.g_old_rec.ass_attribute15;
  End If;
  If (p_rec.ass_attribute16 = hr_api.g_varchar2) then
    p_rec.ass_attribute16 :=
    ben_cpi_shd.g_old_rec.ass_attribute16;
  End If;
  If (p_rec.ass_attribute17 = hr_api.g_varchar2) then
    p_rec.ass_attribute17 :=
    ben_cpi_shd.g_old_rec.ass_attribute17;
  End If;
  If (p_rec.ass_attribute18 = hr_api.g_varchar2) then
    p_rec.ass_attribute18 :=
    ben_cpi_shd.g_old_rec.ass_attribute18;
  End If;
  If (p_rec.ass_attribute19 = hr_api.g_varchar2) then
    p_rec.ass_attribute19 :=
    ben_cpi_shd.g_old_rec.ass_attribute19;
  End If;
  If (p_rec.ass_attribute20 = hr_api.g_varchar2) then
    p_rec.ass_attribute20 :=
    ben_cpi_shd.g_old_rec.ass_attribute20;
  End If;
  If (p_rec.ass_attribute21 = hr_api.g_varchar2) then
    p_rec.ass_attribute21 :=
    ben_cpi_shd.g_old_rec.ass_attribute21;
  End If;
  If (p_rec.ass_attribute22 = hr_api.g_varchar2) then
    p_rec.ass_attribute22 :=
    ben_cpi_shd.g_old_rec.ass_attribute22;
  End If;
  If (p_rec.ass_attribute23 = hr_api.g_varchar2) then
    p_rec.ass_attribute23 :=
    ben_cpi_shd.g_old_rec.ass_attribute23;
  End If;
  If (p_rec.ass_attribute24 = hr_api.g_varchar2) then
    p_rec.ass_attribute24 :=
    ben_cpi_shd.g_old_rec.ass_attribute24;
  End If;
  If (p_rec.ass_attribute25 = hr_api.g_varchar2) then
    p_rec.ass_attribute25 :=
    ben_cpi_shd.g_old_rec.ass_attribute25;
  End If;
  If (p_rec.ass_attribute26 = hr_api.g_varchar2) then
    p_rec.ass_attribute26 :=
    ben_cpi_shd.g_old_rec.ass_attribute26;
  End If;
  If (p_rec.ass_attribute27 = hr_api.g_varchar2) then
    p_rec.ass_attribute27 :=
    ben_cpi_shd.g_old_rec.ass_attribute27;
  End If;
  If (p_rec.ass_attribute28 = hr_api.g_varchar2) then
    p_rec.ass_attribute28 :=
    ben_cpi_shd.g_old_rec.ass_attribute28;
  End If;
  If (p_rec.ass_attribute29 = hr_api.g_varchar2) then
    p_rec.ass_attribute29 :=
    ben_cpi_shd.g_old_rec.ass_attribute29;
  End If;
  If (p_rec.ass_attribute30 = hr_api.g_varchar2) then
    p_rec.ass_attribute30 :=
    ben_cpi_shd.g_old_rec.ass_attribute30;
  End If;
  If (p_rec.ws_comments = hr_api.g_varchar2) then
    p_rec.ws_comments :=
    ben_cpi_shd.g_old_rec.ws_comments;
  End If;
  If (p_rec.cpi_attribute_category = hr_api.g_varchar2) then
    p_rec.cpi_attribute_category :=
    ben_cpi_shd.g_old_rec.cpi_attribute_category;
  End If;
  If (p_rec.cpi_attribute1 = hr_api.g_varchar2) then
    p_rec.cpi_attribute1 :=
    ben_cpi_shd.g_old_rec.cpi_attribute1;
  End If;
  If (p_rec.cpi_attribute2 = hr_api.g_varchar2) then
    p_rec.cpi_attribute2 :=
    ben_cpi_shd.g_old_rec.cpi_attribute2;
  End If;
  If (p_rec.cpi_attribute3 = hr_api.g_varchar2) then
    p_rec.cpi_attribute3 :=
    ben_cpi_shd.g_old_rec.cpi_attribute3;
  End If;
  If (p_rec.cpi_attribute4 = hr_api.g_varchar2) then
    p_rec.cpi_attribute4 :=
    ben_cpi_shd.g_old_rec.cpi_attribute4;
  End If;
  If (p_rec.cpi_attribute5 = hr_api.g_varchar2) then
    p_rec.cpi_attribute5 :=
    ben_cpi_shd.g_old_rec.cpi_attribute5;
  End If;
  If (p_rec.cpi_attribute6 = hr_api.g_varchar2) then
    p_rec.cpi_attribute6 :=
    ben_cpi_shd.g_old_rec.cpi_attribute6;
  End If;
  If (p_rec.cpi_attribute7 = hr_api.g_varchar2) then
    p_rec.cpi_attribute7 :=
    ben_cpi_shd.g_old_rec.cpi_attribute7;
  End If;
  If (p_rec.cpi_attribute8 = hr_api.g_varchar2) then
    p_rec.cpi_attribute8 :=
    ben_cpi_shd.g_old_rec.cpi_attribute8;
  End If;
  If (p_rec.cpi_attribute9 = hr_api.g_varchar2) then
    p_rec.cpi_attribute9 :=
    ben_cpi_shd.g_old_rec.cpi_attribute9;
  End If;
  If (p_rec.cpi_attribute10 = hr_api.g_varchar2) then
    p_rec.cpi_attribute10 :=
    ben_cpi_shd.g_old_rec.cpi_attribute10;
  End If;
  If (p_rec.cpi_attribute11 = hr_api.g_varchar2) then
    p_rec.cpi_attribute11 :=
    ben_cpi_shd.g_old_rec.cpi_attribute11;
  End If;
  If (p_rec.cpi_attribute12 = hr_api.g_varchar2) then
    p_rec.cpi_attribute12 :=
    ben_cpi_shd.g_old_rec.cpi_attribute12;
  End If;
  If (p_rec.cpi_attribute13 = hr_api.g_varchar2) then
    p_rec.cpi_attribute13 :=
    ben_cpi_shd.g_old_rec.cpi_attribute13;
  End If;
  If (p_rec.cpi_attribute14 = hr_api.g_varchar2) then
    p_rec.cpi_attribute14 :=
    ben_cpi_shd.g_old_rec.cpi_attribute14;
  End If;
  If (p_rec.cpi_attribute15 = hr_api.g_varchar2) then
    p_rec.cpi_attribute15 :=
    ben_cpi_shd.g_old_rec.cpi_attribute15;
  End If;
  If (p_rec.cpi_attribute16 = hr_api.g_varchar2) then
    p_rec.cpi_attribute16 :=
    ben_cpi_shd.g_old_rec.cpi_attribute16;
  End If;
  If (p_rec.cpi_attribute17 = hr_api.g_varchar2) then
    p_rec.cpi_attribute17 :=
    ben_cpi_shd.g_old_rec.cpi_attribute17;
  End If;
  If (p_rec.cpi_attribute18 = hr_api.g_varchar2) then
    p_rec.cpi_attribute18 :=
    ben_cpi_shd.g_old_rec.cpi_attribute18;
  End If;
  If (p_rec.cpi_attribute19 = hr_api.g_varchar2) then
    p_rec.cpi_attribute19 :=
    ben_cpi_shd.g_old_rec.cpi_attribute19;
  End If;
  If (p_rec.cpi_attribute20 = hr_api.g_varchar2) then
    p_rec.cpi_attribute20 :=
    ben_cpi_shd.g_old_rec.cpi_attribute20;
  End If;
  If (p_rec.cpi_attribute21 = hr_api.g_varchar2) then
    p_rec.cpi_attribute21 :=
    ben_cpi_shd.g_old_rec.cpi_attribute21;
  End If;
  If (p_rec.cpi_attribute22 = hr_api.g_varchar2) then
    p_rec.cpi_attribute22 :=
    ben_cpi_shd.g_old_rec.cpi_attribute22;
  End If;
  If (p_rec.cpi_attribute23 = hr_api.g_varchar2) then
    p_rec.cpi_attribute23 :=
    ben_cpi_shd.g_old_rec.cpi_attribute23;
  End If;
  If (p_rec.cpi_attribute24 = hr_api.g_varchar2) then
    p_rec.cpi_attribute24 :=
    ben_cpi_shd.g_old_rec.cpi_attribute24;
  End If;
  If (p_rec.cpi_attribute25 = hr_api.g_varchar2) then
    p_rec.cpi_attribute25 :=
    ben_cpi_shd.g_old_rec.cpi_attribute25;
  End If;
  If (p_rec.cpi_attribute26 = hr_api.g_varchar2) then
    p_rec.cpi_attribute26 :=
    ben_cpi_shd.g_old_rec.cpi_attribute26;
  End If;
  If (p_rec.cpi_attribute27 = hr_api.g_varchar2) then
    p_rec.cpi_attribute27 :=
    ben_cpi_shd.g_old_rec.cpi_attribute27;
  End If;
  If (p_rec.cpi_attribute28 = hr_api.g_varchar2) then
    p_rec.cpi_attribute28 :=
    ben_cpi_shd.g_old_rec.cpi_attribute28;
  End If;
  If (p_rec.cpi_attribute29 = hr_api.g_varchar2) then
    p_rec.cpi_attribute29 :=
    ben_cpi_shd.g_old_rec.cpi_attribute29;
  End If;
  If (p_rec.cpi_attribute30 = hr_api.g_varchar2) then
    p_rec.cpi_attribute30 :=
    ben_cpi_shd.g_old_rec.cpi_attribute30;
  End If;
  If (p_rec.feedback_date = hr_api.g_date) then
    p_rec.feedback_date :=
    ben_cpi_shd.g_old_rec.feedback_date;
  End If;
  --
End convert_defs;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (p_rec                          in out nocopy ben_cpi_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  if g_debug then
     hr_utility.set_location('Entering:'||l_proc, 5);
  end if;
  --
  -- We must lock the row which we need to update.
  --
  ben_cpi_shd.lck
    (p_rec.group_per_in_ler_id
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
  ben_cpi_bus.update_validate
     (p_rec
     );
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
  -- Call the supporting pre-update operation
  --
  ben_cpi_upd.pre_update(p_rec);
  --
  -- Update the row.
  --
  ben_cpi_upd.update_dml(p_rec);
  --
  -- Call the supporting post-update operation
  --
  ben_cpi_upd.post_update
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
  (p_group_per_in_ler_id          in     number
  ,p_object_version_number        in out nocopy number
  ,p_assignment_id                in     number    default hr_api.g_number
  ,p_person_id                    in     number    default hr_api.g_number
  ,p_supervisor_id                in     number    default hr_api.g_number
  ,p_effective_date               in     date      default hr_api.g_date
  ,p_full_name                    in     varchar2  default hr_api.g_varchar2
  ,p_brief_name                   in     varchar2  default hr_api.g_varchar2
  ,p_custom_name                  in     varchar2  default hr_api.g_varchar2
  ,p_supervisor_full_name         in     varchar2  default hr_api.g_varchar2
  ,p_supervisor_brief_name        in     varchar2  default hr_api.g_varchar2
  ,p_supervisor_custom_name       in     varchar2  default hr_api.g_varchar2
  ,p_legislation_code             in     varchar2  default hr_api.g_varchar2
  ,p_years_employed               in     number    default hr_api.g_number
  ,p_years_in_job                 in     number    default hr_api.g_number
  ,p_years_in_position            in     number    default hr_api.g_number
  ,p_years_in_grade               in     number    default hr_api.g_number
  ,p_employee_number              in     varchar2  default hr_api.g_varchar2
  ,p_start_date                   in     date      default hr_api.g_date
  ,p_original_start_date          in     date      default hr_api.g_date
  ,p_adjusted_svc_date            in     date      default hr_api.g_date
  ,p_base_salary                  in     number    default hr_api.g_number
  ,p_base_salary_change_date      in     date      default hr_api.g_date
  ,p_payroll_name                 in     varchar2  default hr_api.g_varchar2
  ,p_performance_rating           in     varchar2  default hr_api.g_varchar2
  ,p_performance_rating_type      in     varchar2  default hr_api.g_varchar2
  ,p_performance_rating_date      in     date      default hr_api.g_date
  ,p_business_group_id            in     number    default hr_api.g_number
  ,p_organization_id              in     number    default hr_api.g_number
  ,p_job_id                       in     number    default hr_api.g_number
  ,p_grade_id                     in     number    default hr_api.g_number
  ,p_position_id                  in     number    default hr_api.g_number
  ,p_people_group_id              in     number    default hr_api.g_number
  ,p_soft_coding_keyflex_id       in     number    default hr_api.g_number
  ,p_location_id                  in     number    default hr_api.g_number
  ,p_pay_rate_id                  in     number    default hr_api.g_number
  ,p_assignment_status_type_id    in     number    default hr_api.g_number
  ,p_frequency                    in     varchar2  default hr_api.g_varchar2
  ,p_grade_annulization_factor    in     number    default hr_api.g_number
  ,p_pay_annulization_factor      in     number    default hr_api.g_number
  ,p_grd_min_val                  in     number    default hr_api.g_number
  ,p_grd_max_val                  in     number    default hr_api.g_number
  ,p_grd_mid_point                in     number    default hr_api.g_number
  ,p_grd_quartile                 in     varchar2  default hr_api.g_varchar2
  ,p_grd_comparatio               in     number    default hr_api.g_number
  ,p_emp_category                 in     varchar2  default hr_api.g_varchar2
  ,p_change_reason                in     varchar2  default hr_api.g_varchar2
  ,p_normal_hours                 in     number    default hr_api.g_number
  ,p_email_address                in     varchar2  default hr_api.g_varchar2
  ,p_base_salary_frequency        in     varchar2  default hr_api.g_varchar2
  ,p_new_assgn_ovn                in     number    default hr_api.g_number
  ,p_new_perf_event_id            in     number    default hr_api.g_number
  ,p_new_perf_review_id           in     number    default hr_api.g_number
  ,p_post_process_stat_cd         in     varchar2  default hr_api.g_varchar2
  ,p_feedback_rating              in     varchar2  default hr_api.g_varchar2
  ,p_feedback_comments            in     varchar2  default hr_api.g_varchar2
  ,p_custom_segment1              in     varchar2  default hr_api.g_varchar2
  ,p_custom_segment2              in     varchar2  default hr_api.g_varchar2
  ,p_custom_segment3              in     varchar2  default hr_api.g_varchar2
  ,p_custom_segment4              in     varchar2  default hr_api.g_varchar2
  ,p_custom_segment5              in     varchar2  default hr_api.g_varchar2
  ,p_custom_segment6              in     varchar2  default hr_api.g_varchar2
  ,p_custom_segment7              in     varchar2  default hr_api.g_varchar2
  ,p_custom_segment8              in     varchar2  default hr_api.g_varchar2
  ,p_custom_segment9              in     varchar2  default hr_api.g_varchar2
  ,p_custom_segment10             in     varchar2  default hr_api.g_varchar2
  ,p_custom_segment11             in     number    default hr_api.g_number
  ,p_custom_segment12             in     number    default hr_api.g_number
  ,p_custom_segment13             in     number    default hr_api.g_number
  ,p_custom_segment14             in     number    default hr_api.g_number
  ,p_custom_segment15             in     number    default hr_api.g_number
  ,p_custom_segment16             in     number    default hr_api.g_number
  ,p_custom_segment17             in     number    default hr_api.g_number
  ,p_custom_segment18             in     number    default hr_api.g_number
  ,p_custom_segment19             in     number    default hr_api.g_number
  ,p_custom_segment20             in     number    default hr_api.g_number
  ,p_people_group_name            in     varchar2  default hr_api.g_varchar2
  ,p_people_group_segment1        in     varchar2  default hr_api.g_varchar2
  ,p_people_group_segment2        in     varchar2  default hr_api.g_varchar2
  ,p_people_group_segment3        in     varchar2  default hr_api.g_varchar2
  ,p_people_group_segment4        in     varchar2  default hr_api.g_varchar2
  ,p_people_group_segment5        in     varchar2  default hr_api.g_varchar2
  ,p_people_group_segment6        in     varchar2  default hr_api.g_varchar2
  ,p_people_group_segment7        in     varchar2  default hr_api.g_varchar2
  ,p_people_group_segment8        in     varchar2  default hr_api.g_varchar2
  ,p_people_group_segment9        in     varchar2  default hr_api.g_varchar2
  ,p_people_group_segment10       in     varchar2  default hr_api.g_varchar2
  ,p_people_group_segment11       in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute_category       in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute1               in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute2               in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute3               in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute4               in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute5               in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute6               in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute7               in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute8               in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute9               in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute10              in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute11              in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute12              in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute13              in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute14              in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute15              in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute16              in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute17              in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute18              in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute19              in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute20              in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute21              in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute22              in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute23              in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute24              in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute25              in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute26              in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute27              in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute28              in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute29              in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute30              in     varchar2  default hr_api.g_varchar2
  ,p_ws_comments                  in     varchar2  default hr_api.g_varchar2
  ,p_cpi_attribute_category       in     varchar2  default hr_api.g_varchar2
  ,p_cpi_attribute1               in     varchar2  default hr_api.g_varchar2
  ,p_cpi_attribute2               in     varchar2  default hr_api.g_varchar2
  ,p_cpi_attribute3               in     varchar2  default hr_api.g_varchar2
  ,p_cpi_attribute4               in     varchar2  default hr_api.g_varchar2
  ,p_cpi_attribute5               in     varchar2  default hr_api.g_varchar2
  ,p_cpi_attribute6               in     varchar2  default hr_api.g_varchar2
  ,p_cpi_attribute7               in     varchar2  default hr_api.g_varchar2
  ,p_cpi_attribute8               in     varchar2  default hr_api.g_varchar2
  ,p_cpi_attribute9               in     varchar2  default hr_api.g_varchar2
  ,p_cpi_attribute10              in     varchar2  default hr_api.g_varchar2
  ,p_cpi_attribute11              in     varchar2  default hr_api.g_varchar2
  ,p_cpi_attribute12              in     varchar2  default hr_api.g_varchar2
  ,p_cpi_attribute13              in     varchar2  default hr_api.g_varchar2
  ,p_cpi_attribute14              in     varchar2  default hr_api.g_varchar2
  ,p_cpi_attribute15              in     varchar2  default hr_api.g_varchar2
  ,p_cpi_attribute16              in     varchar2  default hr_api.g_varchar2
  ,p_cpi_attribute17              in     varchar2  default hr_api.g_varchar2
  ,p_cpi_attribute18              in     varchar2  default hr_api.g_varchar2
  ,p_cpi_attribute19              in     varchar2  default hr_api.g_varchar2
  ,p_cpi_attribute20              in     varchar2  default hr_api.g_varchar2
  ,p_cpi_attribute21              in     varchar2  default hr_api.g_varchar2
  ,p_cpi_attribute22              in     varchar2  default hr_api.g_varchar2
  ,p_cpi_attribute23              in     varchar2  default hr_api.g_varchar2
  ,p_cpi_attribute24              in     varchar2  default hr_api.g_varchar2
  ,p_cpi_attribute25              in     varchar2  default hr_api.g_varchar2
  ,p_cpi_attribute26              in     varchar2  default hr_api.g_varchar2
  ,p_cpi_attribute27              in     varchar2  default hr_api.g_varchar2
  ,p_cpi_attribute28              in     varchar2  default hr_api.g_varchar2
  ,p_cpi_attribute29              in     varchar2  default hr_api.g_varchar2
  ,p_cpi_attribute30              in     varchar2  default hr_api.g_varchar2
  ,p_feedback_date                in     date      default hr_api.g_date
  ) is
--
  l_rec   ben_cpi_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  if g_debug then
     hr_utility.set_location('Entering:'||l_proc, 5);
  end if;
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  ben_cpi_shd.convert_args
  (p_group_per_in_ler_id
  ,p_assignment_id
  ,p_person_id
  ,p_supervisor_id
  ,p_effective_date
  ,p_full_name
  ,p_brief_name
  ,p_custom_name
  ,p_supervisor_full_name
  ,p_supervisor_brief_name
  ,p_supervisor_custom_name
  ,p_legislation_code
  ,p_years_employed
  ,p_years_in_job
  ,p_years_in_position
  ,p_years_in_grade
  ,p_employee_number
  ,p_start_date
  ,p_original_start_date
  ,p_adjusted_svc_date
  ,p_base_salary
  ,p_base_salary_change_date
  ,p_payroll_name
  ,p_performance_rating
  ,p_performance_rating_type
  ,p_performance_rating_date
  ,p_business_group_id
  ,p_organization_id
  ,p_job_id
  ,p_grade_id
  ,p_position_id
  ,p_people_group_id
  ,p_soft_coding_keyflex_id
  ,p_location_id
  ,p_pay_rate_id
  ,p_assignment_status_type_id
  ,p_frequency
  ,p_grade_annulization_factor
  ,p_pay_annulization_factor
  ,p_grd_min_val
  ,p_grd_max_val
  ,p_grd_mid_point
  ,p_grd_quartile
  ,p_grd_comparatio
  ,p_emp_category
  ,p_change_reason
  ,p_normal_hours
  ,p_email_address
  ,p_base_salary_frequency
  ,p_new_assgn_ovn
  ,p_new_perf_event_id
  ,p_new_perf_review_id
  ,p_post_process_stat_cd
  ,p_feedback_rating
  ,p_feedback_comments
  ,p_object_version_number
  ,p_custom_segment1
  ,p_custom_segment2
  ,p_custom_segment3
  ,p_custom_segment4
  ,p_custom_segment5
  ,p_custom_segment6
  ,p_custom_segment7
  ,p_custom_segment8
  ,p_custom_segment9
  ,p_custom_segment10
  ,p_custom_segment11
  ,p_custom_segment12
  ,p_custom_segment13
  ,p_custom_segment14
  ,p_custom_segment15
  ,p_custom_segment16
  ,p_custom_segment17
  ,p_custom_segment18
  ,p_custom_segment19
  ,p_custom_segment20
  ,p_people_group_name
  ,p_people_group_segment1
  ,p_people_group_segment2
  ,p_people_group_segment3
  ,p_people_group_segment4
  ,p_people_group_segment5
  ,p_people_group_segment6
  ,p_people_group_segment7
  ,p_people_group_segment8
  ,p_people_group_segment9
  ,p_people_group_segment10
  ,p_people_group_segment11
  ,p_ass_attribute_category
  ,p_ass_attribute1
  ,p_ass_attribute2
  ,p_ass_attribute3
  ,p_ass_attribute4
  ,p_ass_attribute5
  ,p_ass_attribute6
  ,p_ass_attribute7
  ,p_ass_attribute8
  ,p_ass_attribute9
  ,p_ass_attribute10
  ,p_ass_attribute11
  ,p_ass_attribute12
  ,p_ass_attribute13
  ,p_ass_attribute14
  ,p_ass_attribute15
  ,p_ass_attribute16
  ,p_ass_attribute17
  ,p_ass_attribute18
  ,p_ass_attribute19
  ,p_ass_attribute20
  ,p_ass_attribute21
  ,p_ass_attribute22
  ,p_ass_attribute23
  ,p_ass_attribute24
  ,p_ass_attribute25
  ,p_ass_attribute26
  ,p_ass_attribute27
  ,p_ass_attribute28
  ,p_ass_attribute29
  ,p_ass_attribute30
  ,p_ws_comments
  ,p_cpi_attribute_category
  ,p_cpi_attribute1
  ,p_cpi_attribute2
  ,p_cpi_attribute3
  ,p_cpi_attribute4
  ,p_cpi_attribute5
  ,p_cpi_attribute6
  ,p_cpi_attribute7
  ,p_cpi_attribute8
  ,p_cpi_attribute9
  ,p_cpi_attribute10
  ,p_cpi_attribute11
  ,p_cpi_attribute12
  ,p_cpi_attribute13
  ,p_cpi_attribute14
  ,p_cpi_attribute15
  ,p_cpi_attribute16
  ,p_cpi_attribute17
  ,p_cpi_attribute18
  ,p_cpi_attribute19
  ,p_cpi_attribute20
  ,p_cpi_attribute21
  ,p_cpi_attribute22
  ,p_cpi_attribute23
  ,p_cpi_attribute24
  ,p_cpi_attribute25
  ,p_cpi_attribute26
  ,p_cpi_attribute27
  ,p_cpi_attribute28
  ,p_cpi_attribute29
  ,p_cpi_attribute30
  ,p_feedback_date
  );
  --
  -- Having converted the arguments into the
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  ben_cpi_upd.upd
     (l_rec
     );
  p_object_version_number := l_rec.object_version_number;
  --
  if g_debug then
     hr_utility.set_location(' Leaving:'||l_proc, 10);
  end if;
End upd;
--
end ben_cpi_upd;

/
