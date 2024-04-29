--------------------------------------------------------
--  DDL for Package Body PQH_PTX_DEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_PTX_DEL" as
/* $Header: pqptxrhi.pkb 120.0.12010000.2 2008/08/05 13:41:09 ubhat ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pqh_ptx_del.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------------------------------< delete_dml >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure controls the actual dml delete logic. The functions of
--   this procedure are as follows:
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
--   If a child integrity constraint violation is raised the
--   constraint_error procedure will be called.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure delete_dml(p_rec in pqh_ptx_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'delete_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  -- Delete the pqh_position_transactions row.
  --
  delete from pqh_position_transactions
  where position_transaction_id = p_rec.position_transaction_id;
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.child_integrity_violated then
    -- Child integrity has been violated
    pqh_ptx_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
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
Procedure pre_delete(p_rec in pqh_ptx_shd.g_rec_type) is
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
--   Internal table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure post_delete(
p_effective_date in date,p_rec in pqh_ptx_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'post_delete';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
--
  --
  -- Start of API User Hook for post_delete.
  --
  begin
    --
    pqh_ptx_rkd.after_delete
      (
  p_position_transaction_id       =>p_rec.position_transaction_id
 ,p_action_date_o                 =>pqh_ptx_shd.g_old_rec.action_date
 ,p_position_id_o                 =>pqh_ptx_shd.g_old_rec.position_id
 ,p_availability_status_id_o      =>pqh_ptx_shd.g_old_rec.availability_status_id
 ,p_business_group_id_o           =>pqh_ptx_shd.g_old_rec.business_group_id
 ,p_entry_step_id_o               =>pqh_ptx_shd.g_old_rec.entry_step_id
 ,p_entry_grade_rule_id_o         =>pqh_ptx_shd.g_old_rec.entry_grade_rule_id
 ,p_job_id_o                      =>pqh_ptx_shd.g_old_rec.job_id
 ,p_location_id_o                 =>pqh_ptx_shd.g_old_rec.location_id
 ,p_organization_id_o             =>pqh_ptx_shd.g_old_rec.organization_id
 ,p_pay_freq_payroll_id_o         =>pqh_ptx_shd.g_old_rec.pay_freq_payroll_id
 ,p_position_definition_id_o      =>pqh_ptx_shd.g_old_rec.position_definition_id
 ,p_prior_position_id_o           =>pqh_ptx_shd.g_old_rec.prior_position_id
 ,p_relief_position_id_o          =>pqh_ptx_shd.g_old_rec.relief_position_id
 ,p_entry_grade_id_o              =>pqh_ptx_shd.g_old_rec.entry_grade_id
 ,p_successor_position_id_o       =>pqh_ptx_shd.g_old_rec.successor_position_id
 ,p_supervisor_position_id_o      =>pqh_ptx_shd.g_old_rec.supervisor_position_id
 ,p_amendment_date_o              =>pqh_ptx_shd.g_old_rec.amendment_date
 ,p_amendment_recommendation_o    =>pqh_ptx_shd.g_old_rec.amendment_recommendation
 ,p_amendment_ref_number_o        =>pqh_ptx_shd.g_old_rec.amendment_ref_number
 ,p_avail_status_prop_end_date_o  =>pqh_ptx_shd.g_old_rec.avail_status_prop_end_date
 ,p_bargaining_unit_cd_o          =>pqh_ptx_shd.g_old_rec.bargaining_unit_cd
 ,p_comments_o                    =>pqh_ptx_shd.g_old_rec.comments
 ,p_country1_o                    =>pqh_ptx_shd.g_old_rec.country1
 ,p_country2_o                    =>pqh_ptx_shd.g_old_rec.country2
 ,p_country3_o                    =>pqh_ptx_shd.g_old_rec.country3
 ,p_current_job_prop_end_date_o   =>pqh_ptx_shd.g_old_rec.current_job_prop_end_date
 ,p_current_org_prop_end_date_o   =>pqh_ptx_shd.g_old_rec.current_org_prop_end_date
 ,p_date_effective_o              =>pqh_ptx_shd.g_old_rec.date_effective
 ,p_date_end_o                    =>pqh_ptx_shd.g_old_rec.date_end
 ,p_earliest_hire_date_o          =>pqh_ptx_shd.g_old_rec.earliest_hire_date
 ,p_fill_by_date_o                =>pqh_ptx_shd.g_old_rec.fill_by_date
 ,p_frequency_o                   =>pqh_ptx_shd.g_old_rec.frequency
 ,p_fte_o                         =>pqh_ptx_shd.g_old_rec.fte
 ,p_fte_capacity_o                =>pqh_ptx_shd.g_old_rec.fte_capacity
 ,p_location1_o                   =>pqh_ptx_shd.g_old_rec.location1
 ,p_location2_o                   =>pqh_ptx_shd.g_old_rec.location2
 ,p_location3_o                   =>pqh_ptx_shd.g_old_rec.location3
 ,p_max_persons_o                 =>pqh_ptx_shd.g_old_rec.max_persons
 ,p_name_o                        =>pqh_ptx_shd.g_old_rec.name
 ,p_other_requirements_o          =>pqh_ptx_shd.g_old_rec.other_requirements
 ,p_overlap_period_o              =>pqh_ptx_shd.g_old_rec.overlap_period
 ,p_overlap_unit_cd_o             =>pqh_ptx_shd.g_old_rec.overlap_unit_cd
 ,p_passport_required_o           =>pqh_ptx_shd.g_old_rec.passport_required
 ,p_pay_term_end_day_cd_o         =>pqh_ptx_shd.g_old_rec.pay_term_end_day_cd
 ,p_pay_term_end_month_cd_o       =>pqh_ptx_shd.g_old_rec.pay_term_end_month_cd
 ,p_permanent_temporary_flag_o    =>pqh_ptx_shd.g_old_rec.permanent_temporary_flag
 ,p_permit_recruitment_flag_o     =>pqh_ptx_shd.g_old_rec.permit_recruitment_flag
 ,p_position_type_o               =>pqh_ptx_shd.g_old_rec.position_type
 ,p_posting_description_o         =>pqh_ptx_shd.g_old_rec.posting_description
 ,p_probation_period_o            =>pqh_ptx_shd.g_old_rec.probation_period
 ,p_probation_period_unit_cd_o    =>pqh_ptx_shd.g_old_rec.probation_period_unit_cd
 ,p_relocate_domestically_o       =>pqh_ptx_shd.g_old_rec.relocate_domestically
 ,p_relocate_internationally_o    =>pqh_ptx_shd.g_old_rec.relocate_internationally
 ,p_replacement_required_flag_o   =>pqh_ptx_shd.g_old_rec.replacement_required_flag
 ,p_review_flag_o                 =>pqh_ptx_shd.g_old_rec.review_flag
 ,p_seasonal_flag_o               =>pqh_ptx_shd.g_old_rec.seasonal_flag
 ,p_security_requirements_o       =>pqh_ptx_shd.g_old_rec.security_requirements
 ,p_service_minimum_o             =>pqh_ptx_shd.g_old_rec.service_minimum
 ,p_term_start_day_cd_o           =>pqh_ptx_shd.g_old_rec.term_start_day_cd
 ,p_term_start_month_cd_o         =>pqh_ptx_shd.g_old_rec.term_start_month_cd
 ,p_time_normal_finish_o          =>pqh_ptx_shd.g_old_rec.time_normal_finish
 ,p_time_normal_start_o           =>pqh_ptx_shd.g_old_rec.time_normal_start
 ,p_transaction_status_o          =>pqh_ptx_shd.g_old_rec.transaction_status
 ,p_travel_required_o             =>pqh_ptx_shd.g_old_rec.travel_required
 ,p_working_hours_o               =>pqh_ptx_shd.g_old_rec.working_hours
 ,p_works_council_approval_fla_o =>pqh_ptx_shd.g_old_rec.works_council_approval_flag
 ,p_work_any_country_o            =>pqh_ptx_shd.g_old_rec.work_any_country
 ,p_work_any_location_o           =>pqh_ptx_shd.g_old_rec.work_any_location
 ,p_work_period_type_cd_o         =>pqh_ptx_shd.g_old_rec.work_period_type_cd
 ,p_work_schedule_o               =>pqh_ptx_shd.g_old_rec.work_schedule
 ,p_work_duration_o               =>pqh_ptx_shd.g_old_rec.work_duration
 ,p_work_term_end_day_cd_o        =>pqh_ptx_shd.g_old_rec.work_term_end_day_cd
 ,p_work_term_end_month_cd_o      =>pqh_ptx_shd.g_old_rec.work_term_end_month_cd
 ,p_proposed_fte_for_layoff_o     =>pqh_ptx_shd.g_old_rec.proposed_fte_for_layoff
 ,p_proposed_date_for_layoff_o    =>pqh_ptx_shd.g_old_rec.proposed_date_for_layoff
 ,p_information1_o                =>pqh_ptx_shd.g_old_rec.information1
 ,p_information2_o                =>pqh_ptx_shd.g_old_rec.information2
 ,p_information3_o                =>pqh_ptx_shd.g_old_rec.information3
 ,p_information4_o                =>pqh_ptx_shd.g_old_rec.information4
 ,p_information5_o                =>pqh_ptx_shd.g_old_rec.information5
 ,p_information6_o                =>pqh_ptx_shd.g_old_rec.information6
 ,p_information7_o                =>pqh_ptx_shd.g_old_rec.information7
 ,p_information8_o                =>pqh_ptx_shd.g_old_rec.information8
 ,p_information9_o                =>pqh_ptx_shd.g_old_rec.information9
 ,p_information10_o               =>pqh_ptx_shd.g_old_rec.information10
 ,p_information11_o               =>pqh_ptx_shd.g_old_rec.information11
 ,p_information12_o               =>pqh_ptx_shd.g_old_rec.information12
 ,p_information13_o               =>pqh_ptx_shd.g_old_rec.information13
 ,p_information14_o               =>pqh_ptx_shd.g_old_rec.information14
 ,p_information15_o               =>pqh_ptx_shd.g_old_rec.information15
 ,p_information16_o               =>pqh_ptx_shd.g_old_rec.information16
 ,p_information17_o               =>pqh_ptx_shd.g_old_rec.information17
 ,p_information18_o               =>pqh_ptx_shd.g_old_rec.information18
 ,p_information19_o               =>pqh_ptx_shd.g_old_rec.information19
 ,p_information20_o               =>pqh_ptx_shd.g_old_rec.information20
 ,p_information21_o               =>pqh_ptx_shd.g_old_rec.information21
 ,p_information22_o               =>pqh_ptx_shd.g_old_rec.information22
 ,p_information23_o               =>pqh_ptx_shd.g_old_rec.information23
 ,p_information24_o               =>pqh_ptx_shd.g_old_rec.information24
 ,p_information25_o               =>pqh_ptx_shd.g_old_rec.information25
 ,p_information26_o               =>pqh_ptx_shd.g_old_rec.information26
 ,p_information27_o               =>pqh_ptx_shd.g_old_rec.information27
 ,p_information28_o               =>pqh_ptx_shd.g_old_rec.information28
 ,p_information29_o               =>pqh_ptx_shd.g_old_rec.information29
 ,p_information30_o               =>pqh_ptx_shd.g_old_rec.information30
 ,p_information_category_o        =>pqh_ptx_shd.g_old_rec.information_category
 ,p_attribute1_o                  =>pqh_ptx_shd.g_old_rec.attribute1
 ,p_attribute2_o                  =>pqh_ptx_shd.g_old_rec.attribute2
 ,p_attribute3_o                  =>pqh_ptx_shd.g_old_rec.attribute3
 ,p_attribute4_o                  =>pqh_ptx_shd.g_old_rec.attribute4
 ,p_attribute5_o                  =>pqh_ptx_shd.g_old_rec.attribute5
 ,p_attribute6_o                  =>pqh_ptx_shd.g_old_rec.attribute6
 ,p_attribute7_o                  =>pqh_ptx_shd.g_old_rec.attribute7
 ,p_attribute8_o                  =>pqh_ptx_shd.g_old_rec.attribute8
 ,p_attribute9_o                  =>pqh_ptx_shd.g_old_rec.attribute9
 ,p_attribute10_o                 =>pqh_ptx_shd.g_old_rec.attribute10
 ,p_attribute11_o                 =>pqh_ptx_shd.g_old_rec.attribute11
 ,p_attribute12_o                 =>pqh_ptx_shd.g_old_rec.attribute12
 ,p_attribute13_o                 =>pqh_ptx_shd.g_old_rec.attribute13
 ,p_attribute14_o                 =>pqh_ptx_shd.g_old_rec.attribute14
 ,p_attribute15_o                 =>pqh_ptx_shd.g_old_rec.attribute15
 ,p_attribute16_o                 =>pqh_ptx_shd.g_old_rec.attribute16
 ,p_attribute17_o                 =>pqh_ptx_shd.g_old_rec.attribute17
 ,p_attribute18_o                 =>pqh_ptx_shd.g_old_rec.attribute18
 ,p_attribute19_o                 =>pqh_ptx_shd.g_old_rec.attribute19
 ,p_attribute20_o                 =>pqh_ptx_shd.g_old_rec.attribute20
 ,p_attribute21_o                 =>pqh_ptx_shd.g_old_rec.attribute21
 ,p_attribute22_o                 =>pqh_ptx_shd.g_old_rec.attribute22
 ,p_attribute23_o                 =>pqh_ptx_shd.g_old_rec.attribute23
 ,p_attribute24_o                 =>pqh_ptx_shd.g_old_rec.attribute24
 ,p_attribute25_o                 =>pqh_ptx_shd.g_old_rec.attribute25
 ,p_attribute26_o                 =>pqh_ptx_shd.g_old_rec.attribute26
 ,p_attribute27_o                 =>pqh_ptx_shd.g_old_rec.attribute27
 ,p_attribute28_o                 =>pqh_ptx_shd.g_old_rec.attribute28
 ,p_attribute29_o                 =>pqh_ptx_shd.g_old_rec.attribute29
 ,p_attribute30_o                 =>pqh_ptx_shd.g_old_rec.attribute30
 ,p_attribute_category_o          =>pqh_ptx_shd.g_old_rec.attribute_category
 ,p_object_version_number_o       =>pqh_ptx_shd.g_old_rec.object_version_number
 ,p_pay_basis_id_o		  =>pqh_ptx_shd.g_old_rec.pay_basis_id
 ,p_supervisor_id_o		  =>pqh_ptx_shd.g_old_rec.supervisor_id
 ,p_wf_transaction_category_id_o  =>pqh_ptx_shd.g_old_rec.wf_transaction_category_id
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'pqh_position_transactions'
        ,p_hook_type   => 'AD');
      --
  end;
  --
  -- End of API User Hook for post_delete.
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End post_delete;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< del >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure del
  (
  p_effective_date in date,
  p_rec	      in pqh_ptx_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'del';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to delete.
  --
  pqh_ptx_shd.lck
	(
	p_rec.position_transaction_id,
	p_rec.object_version_number
	);
  --
  -- Call the supporting delete validate operation
  --
  pqh_ptx_bus.delete_validate(p_rec
  ,p_effective_date);
  --
  -- Call the supporting pre-delete operation
  --
  pre_delete(p_rec);
  --
  -- Delete the row.
  --
  delete_dml(p_rec);
  --
  -- Call the supporting post-delete operation
  --
  post_delete(
p_effective_date,p_rec);
End del;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< del >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure del
  (
 p_effective_date in date,
  p_position_transaction_id            in number,
  p_object_version_number              in number
  ) is
--
  l_rec	  pqh_ptx_shd.g_rec_type;
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
  l_rec.position_transaction_id:= p_position_transaction_id;
  l_rec.object_version_number := p_object_version_number;
  --
  -- Having converted the arguments into the pqh_ptx_rec
  -- plsql record structure we must call the corresponding entity
  -- business process
  --
  del(
    p_effective_date,l_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End del;
--
end pqh_ptx_del;

/
