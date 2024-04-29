--------------------------------------------------------
--  DDL for Package Body HR_PDT_DEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_PDT_DEL" as
/* $Header: hrpdtrhi.pkb 120.4.12010000.2 2008/08/06 08:46:56 ubhat ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  hr_pdt_del.';  -- Global package name
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
  (p_rec in hr_pdt_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'delete_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  --
  -- Delete the hr_person_deployments row.
  --
  delete from hr_person_deployments
  where person_deployment_id = p_rec.person_deployment_id;
  --
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.child_integrity_violated then
    -- Child integrity has been violated
    --
    hr_pdt_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    --
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
Procedure pre_delete(p_rec in hr_pdt_shd.g_rec_type) is
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
Procedure post_delete(p_rec in hr_pdt_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'post_delete';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  begin
    --
    hr_pdt_rkd.after_delete
      (p_person_deployment_id
      => p_rec.person_deployment_id
      ,p_object_version_number_o
      => hr_pdt_shd.g_old_rec.object_version_number
      ,p_from_business_group_id_o
      => hr_pdt_shd.g_old_rec.from_business_group_id
      ,p_to_business_group_id_o
      => hr_pdt_shd.g_old_rec.to_business_group_id
      ,p_from_person_id_o
      => hr_pdt_shd.g_old_rec.from_person_id
      ,p_to_person_id_o
      => hr_pdt_shd.g_old_rec.to_person_id
      ,p_person_type_id_o
      => hr_pdt_shd.g_old_rec.person_type_id
      ,p_start_date_o
      => hr_pdt_shd.g_old_rec.start_date
      ,p_end_date_o
      => hr_pdt_shd.g_old_rec.end_date
      ,p_deployment_reason_o
      => hr_pdt_shd.g_old_rec.deployment_reason
      ,p_employee_number_o
      => hr_pdt_shd.g_old_rec.employee_number
      ,p_leaving_reason_o
      => hr_pdt_shd.g_old_rec.leaving_reason
      ,p_leaving_person_type_id_o
      => hr_pdt_shd.g_old_rec.leaving_person_type_id
      ,p_permanent_o
      => hr_pdt_shd.g_old_rec.permanent
      ,p_status_o
      => hr_pdt_shd.g_old_rec.status
      ,p_status_change_reason_o
      => hr_pdt_shd.g_old_rec.status_change_reason
      ,p_status_change_date_o
      => hr_pdt_shd.g_old_rec.status_change_date
      ,p_deplymt_policy_id_o
      => hr_pdt_shd.g_old_rec.deplymt_policy_id
      ,p_organization_id_o
      => hr_pdt_shd.g_old_rec.organization_id
      ,p_location_id_o
      => hr_pdt_shd.g_old_rec.location_id
      ,p_job_id_o
      => hr_pdt_shd.g_old_rec.job_id
      ,p_position_id_o
      => hr_pdt_shd.g_old_rec.position_id
      ,p_grade_id_o
      => hr_pdt_shd.g_old_rec.grade_id
      ,p_supervisor_id_o
      => hr_pdt_shd.g_old_rec.supervisor_id
      ,p_supervisor_assignment_id_o
      => hr_pdt_shd.g_old_rec.supervisor_assignment_id
      ,p_retain_direct_reports_o
      => hr_pdt_shd.g_old_rec.retain_direct_reports
      ,p_payroll_id_o
      => hr_pdt_shd.g_old_rec.payroll_id
      ,p_pay_basis_id_o
      => hr_pdt_shd.g_old_rec.pay_basis_id
      ,p_proposed_salary_o
      => hr_pdt_shd.g_old_rec.proposed_salary
      ,p_people_group_id_o
      => hr_pdt_shd.g_old_rec.people_group_id
      ,p_soft_coding_keyflex_id_o
      => hr_pdt_shd.g_old_rec.soft_coding_keyflex_id
      ,p_assignment_status_type_id_o
      => hr_pdt_shd.g_old_rec.assignment_status_type_id
      ,p_ass_status_change_reason_o
      => hr_pdt_shd.g_old_rec.ass_status_change_reason
      ,p_assignment_category_o
      => hr_pdt_shd.g_old_rec.assignment_category
      ,p_per_information_category_o
      => hr_pdt_shd.g_old_rec.per_information_category
      ,p_per_information1_o
      => hr_pdt_shd.g_old_rec.per_information1
      ,p_per_information2_o
      => hr_pdt_shd.g_old_rec.per_information2
      ,p_per_information3_o
      => hr_pdt_shd.g_old_rec.per_information3
      ,p_per_information4_o
      => hr_pdt_shd.g_old_rec.per_information4
      ,p_per_information5_o
      => hr_pdt_shd.g_old_rec.per_information5
      ,p_per_information6_o
      => hr_pdt_shd.g_old_rec.per_information6
      ,p_per_information7_o
      => hr_pdt_shd.g_old_rec.per_information7
      ,p_per_information8_o
      => hr_pdt_shd.g_old_rec.per_information8
      ,p_per_information9_o
      => hr_pdt_shd.g_old_rec.per_information9
      ,p_per_information10_o
      => hr_pdt_shd.g_old_rec.per_information10
      ,p_per_information11_o
      => hr_pdt_shd.g_old_rec.per_information11
      ,p_per_information12_o
      => hr_pdt_shd.g_old_rec.per_information12
      ,p_per_information13_o
      => hr_pdt_shd.g_old_rec.per_information13
      ,p_per_information14_o
      => hr_pdt_shd.g_old_rec.per_information14
      ,p_per_information15_o
      => hr_pdt_shd.g_old_rec.per_information15
      ,p_per_information16_o
      => hr_pdt_shd.g_old_rec.per_information16
      ,p_per_information17_o
      => hr_pdt_shd.g_old_rec.per_information17
      ,p_per_information18_o
      => hr_pdt_shd.g_old_rec.per_information18
      ,p_per_information19_o
      => hr_pdt_shd.g_old_rec.per_information19
      ,p_per_information20_o
      => hr_pdt_shd.g_old_rec.per_information20
      ,p_per_information21_o
      => hr_pdt_shd.g_old_rec.per_information21
      ,p_per_information22_o
      => hr_pdt_shd.g_old_rec.per_information22
      ,p_per_information23_o
      => hr_pdt_shd.g_old_rec.per_information23
      ,p_per_information24_o
      => hr_pdt_shd.g_old_rec.per_information24
      ,p_per_information25_o
      => hr_pdt_shd.g_old_rec.per_information25
      ,p_per_information26_o
      => hr_pdt_shd.g_old_rec.per_information26
      ,p_per_information27_o
      => hr_pdt_shd.g_old_rec.per_information27
      ,p_per_information28_o
      => hr_pdt_shd.g_old_rec.per_information28
      ,p_per_information29_o
      => hr_pdt_shd.g_old_rec.per_information29
      ,p_per_information30_o
      => hr_pdt_shd.g_old_rec.per_information30
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'HR_PERSON_DEPLOYMENTS'
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
  (p_rec              in hr_pdt_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'del';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to delete.
  --
  hr_pdt_shd.lck
    (p_rec.person_deployment_id
    ,p_rec.object_version_number
    );
  --
  -- Call the supporting delete validate operation
  --
  hr_pdt_bus.delete_validate(p_rec);
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
  -- Call the supporting pre-delete operation
  --
  hr_pdt_del.pre_delete(p_rec);
  --
  -- Delete the row.
  --
  hr_pdt_del.delete_dml(p_rec);
  --
  -- Call the supporting post-delete operation
  --
  hr_pdt_del.post_delete(p_rec);
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
  (p_person_deployment_id                 in     number
  ,p_object_version_number                in     number
  ) is
--
  l_rec   hr_pdt_shd.g_rec_type;
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
  l_rec.person_deployment_id := p_person_deployment_id;
  l_rec.object_version_number := p_object_version_number;
  --
  -- Having converted the arguments into the hr_pdt_rec
  -- plsql record structure we must call the corresponding entity
  -- business process
  --
  hr_pdt_del.del(l_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End del;
--
end hr_pdt_del;

/
