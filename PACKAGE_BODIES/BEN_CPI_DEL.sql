--------------------------------------------------------
--  DDL for Package Body BEN_CPI_DEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_CPI_DEL" as
/* $Header: becpirhi.pkb 120.0 2005/05/28 01:13 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  ben_cpi_del.';  -- Global package name
g_debug boolean := hr_utility.debug_enabled;
--
-- ----------------------------------------------------------------------------
-- ----------------------< delete_app_ownerships >----------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--   Deletes row(s) from hr_application_ownerships depending on the mode that
--   the row handler has been called in.
--
-- ----------------------------------------------------------------------------
PROCEDURE delete_app_ownerships(p_pk_column  IN  varchar2
                               ,p_pk_value   IN  varchar2) IS
--
BEGIN
  --
  IF (hr_startup_data_api_support.return_startup_mode
                           IN ('STARTUP','GENERIC')) THEN
     --
     DELETE FROM hr_application_ownerships
      WHERE key_name = p_pk_column
        AND key_value = p_pk_value;
     --
  END IF;
END delete_app_ownerships;
--
-- ----------------------------------------------------------------------------
-- ----------------------< delete_app_ownerships >----------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE delete_app_ownerships(p_pk_column IN varchar2
                               ,p_pk_value  IN number) IS
--
BEGIN
  delete_app_ownerships(p_pk_column, to_char(p_pk_value));
END delete_app_ownerships;
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
  (p_rec in ben_cpi_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'delete_dml';
--
Begin
  if g_debug then
     hr_utility.set_location('Entering:'||l_proc, 5);
  end if;
  --
  ben_cpi_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Delete the ben_cwb_person_info row.
  --
  delete from ben_cwb_person_info
  where group_per_in_ler_id = p_rec.group_per_in_ler_id;
  --
  ben_cpi_shd.g_api_dml := false;   -- Unset the api dml status
  --
  if g_debug then
     hr_utility.set_location(' Leaving:'||l_proc, 10);
  end if;
--
Exception
  When hr_api.child_integrity_violated then
    -- Child integrity has been violated
    ben_cpi_shd.g_api_dml := false;   -- Unset the api dml status
    ben_cpi_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    ben_cpi_shd.g_api_dml := false;   -- Unset the api dml status
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
Procedure pre_delete(p_rec in ben_cpi_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'pre_delete';
--
Begin
  if g_debug then
     hr_utility.set_location('Entering:'||l_proc, 5);
  end if;
  --
  if g_debug then
     hr_utility.set_location(' Leaving:'||l_proc, 10);
  end if;
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
Procedure post_delete(p_rec in ben_cpi_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'post_delete';
--
Begin
  if g_debug then
     hr_utility.set_location('Entering:'||l_proc, 5);
  end if;
  begin
    --
    -- Delete ownerships if applicable
    delete_app_ownerships
      ('GROUP_PER_IN_LER_ID', p_rec.group_per_in_ler_id
      );
    --
    ben_cpi_rkd.after_delete
      (p_group_per_in_ler_id
      => p_rec.group_per_in_ler_id
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
        ,p_hook_type   => 'AD');
      --
  end;
  --
  if g_debug then
     hr_utility.set_location(' Leaving:'||l_proc, 10);
  end if;
End post_delete;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< del >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure del
  (p_rec              in ben_cpi_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'del';
--
Begin
  if g_debug then
     hr_utility.set_location('Entering:'||l_proc, 5);
  end if;
  --
  -- We must lock the row which we need to delete.
  --
  ben_cpi_shd.lck
    (p_rec.group_per_in_ler_id
    ,p_rec.object_version_number
    );
  --
  -- Call the supporting delete validate operation
  --
  ben_cpi_bus.delete_validate(p_rec);
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
  -- Call the supporting pre-delete operation
  --
  ben_cpi_del.pre_delete(p_rec);
  --
  -- Delete the row.
  --
  ben_cpi_del.delete_dml(p_rec);
  --
  -- Call the supporting post-delete operation
  --
  ben_cpi_del.post_delete(p_rec);
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
  (p_group_per_in_ler_id                  in     number
  ,p_object_version_number                in     number
  ) is
--
  l_rec   ben_cpi_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'del';
--
Begin
  if g_debug then
     hr_utility.set_location('Entering:'||l_proc, 5);
  end if;
  --
  -- As the delete procedure accepts a plsql record structure we do need to
  -- convert the  arguments into the record structure.
  -- We don't need to call the supplied conversion argument routine as we
  -- only need a few attributes.
  --
  l_rec.group_per_in_ler_id := p_group_per_in_ler_id;
  l_rec.object_version_number := p_object_version_number;
  --
  -- Having converted the arguments into the ben_cpi_rec
  -- plsql record structure we must call the corresponding entity
  -- business process
  --
  ben_cpi_del.del(l_rec);
  --
  if g_debug then
     hr_utility.set_location(' Leaving:'||l_proc, 10);
  end if;
End del;
--
end ben_cpi_del;

/
