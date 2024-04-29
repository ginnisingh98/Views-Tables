--------------------------------------------------------
--  DDL for Package Body HR_PDT_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_PDT_UPD" as
/* $Header: hrpdtrhi.pkb 120.4.12010000.2 2008/08/06 08:46:56 ubhat ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  hr_pdt_upd.';  -- Global package name
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
  (p_rec in out nocopy hr_pdt_shd.g_rec_type
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
  --
  --
  -- Update the hr_person_deployments Row
  --
  update hr_person_deployments
    set
     person_deployment_id            = p_rec.person_deployment_id
    ,object_version_number           = p_rec.object_version_number
    ,from_business_group_id          = p_rec.from_business_group_id
    ,to_business_group_id            = p_rec.to_business_group_id
    ,from_person_id                  = p_rec.from_person_id
    ,to_person_id                    = p_rec.to_person_id
    ,person_type_id                  = p_rec.person_type_id
    ,start_date                      = p_rec.start_date
    ,end_date                        = p_rec.end_date
    ,deployment_reason               = p_rec.deployment_reason
    ,employee_number                 = p_rec.employee_number
    ,leaving_reason                  = p_rec.leaving_reason
    ,leaving_person_type_id          = p_rec.leaving_person_type_id
    ,permanent                       = p_rec.permanent
    ,status                          = p_rec.status
    ,status_change_reason            = p_rec.status_change_reason
    ,status_change_date              = p_rec.status_change_date
    ,deplymt_policy_id               = p_rec.deplymt_policy_id
    ,organization_id                 = p_rec.organization_id
    ,location_id                     = p_rec.location_id
    ,job_id                          = p_rec.job_id
    ,position_id                     = p_rec.position_id
    ,grade_id                        = p_rec.grade_id
    ,supervisor_id                   = p_rec.supervisor_id
    ,supervisor_assignment_id        = p_rec.supervisor_assignment_id
    ,retain_direct_reports           = p_rec.retain_direct_reports
    ,payroll_id                      = p_rec.payroll_id
    ,pay_basis_id                    = p_rec.pay_basis_id
    ,proposed_salary                 = p_rec.proposed_salary
    ,people_group_id                 = p_rec.people_group_id
    ,soft_coding_keyflex_id          = p_rec.soft_coding_keyflex_id
    ,assignment_status_type_id       = p_rec.assignment_status_type_id
    ,ass_status_change_reason        = p_rec.ass_status_change_reason
    ,assignment_category             = p_rec.assignment_category
    ,per_information_category        = p_rec.per_information_category
    ,per_information1                = p_rec.per_information1
    ,per_information2                = p_rec.per_information2
    ,per_information3                = p_rec.per_information3
    ,per_information4                = p_rec.per_information4
    ,per_information5                = p_rec.per_information5
    ,per_information6                = p_rec.per_information6
    ,per_information7                = p_rec.per_information7
    ,per_information8                = p_rec.per_information8
    ,per_information9                = p_rec.per_information9
    ,per_information10               = p_rec.per_information10
    ,per_information11               = p_rec.per_information11
    ,per_information12               = p_rec.per_information12
    ,per_information13               = p_rec.per_information13
    ,per_information14               = p_rec.per_information14
    ,per_information15               = p_rec.per_information15
    ,per_information16               = p_rec.per_information16
    ,per_information17               = p_rec.per_information17
    ,per_information18               = p_rec.per_information18
    ,per_information19               = p_rec.per_information19
    ,per_information20               = p_rec.per_information20
    ,per_information21               = p_rec.per_information21
    ,per_information22               = p_rec.per_information22
    ,per_information23               = p_rec.per_information23
    ,per_information24               = p_rec.per_information24
    ,per_information25               = p_rec.per_information25
    ,per_information26               = p_rec.per_information26
    ,per_information27               = p_rec.per_information27
    ,per_information28               = p_rec.per_information28
    ,per_information29               = p_rec.per_information29
    ,per_information30               = p_rec.per_information30
    where person_deployment_id = p_rec.person_deployment_id;
  --
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    --
    hr_pdt_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    --
    hr_pdt_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    --
    hr_pdt_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    --
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
  (p_rec in hr_pdt_shd.g_rec_type
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
  (p_rec                          in hr_pdt_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'post_update';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  begin
    --
    hr_pdt_rku.after_update
      (p_person_deployment_id
      => p_rec.person_deployment_id
      ,p_object_version_number
      => p_rec.object_version_number
      ,p_from_business_group_id
      => p_rec.from_business_group_id
      ,p_to_business_group_id
      => p_rec.to_business_group_id
      ,p_from_person_id
      => p_rec.from_person_id
      ,p_to_person_id
      => p_rec.to_person_id
      ,p_person_type_id
      => p_rec.person_type_id
      ,p_start_date
      => p_rec.start_date
      ,p_end_date
      => p_rec.end_date
      ,p_deployment_reason
      => p_rec.deployment_reason
      ,p_employee_number
      => p_rec.employee_number
      ,p_leaving_reason
      => p_rec.leaving_reason
      ,p_leaving_person_type_id
      => p_rec.leaving_person_type_id
      ,p_permanent
      => p_rec.permanent
      ,p_status
      => p_rec.status
      ,p_status_change_reason
      => p_rec.status_change_reason
      ,p_status_change_date
      => p_rec.status_change_date
      ,p_deplymt_policy_id
      => p_rec.deplymt_policy_id
      ,p_organization_id
      => p_rec.organization_id
      ,p_location_id
      => p_rec.location_id
      ,p_job_id
      => p_rec.job_id
      ,p_position_id
      => p_rec.position_id
      ,p_grade_id
      => p_rec.grade_id
      ,p_supervisor_id
      => p_rec.supervisor_id
      ,p_supervisor_assignment_id
      => p_rec.supervisor_assignment_id
      ,p_retain_direct_reports
      => p_rec.retain_direct_reports
      ,p_payroll_id
      => p_rec.payroll_id
      ,p_pay_basis_id
      => p_rec.pay_basis_id
      ,p_proposed_salary
      => p_rec.proposed_salary
      ,p_people_group_id
      => p_rec.people_group_id
      ,p_soft_coding_keyflex_id
      => p_rec.soft_coding_keyflex_id
      ,p_assignment_status_type_id
      => p_rec.assignment_status_type_id
      ,p_ass_status_change_reason
      => p_rec.ass_status_change_reason
      ,p_assignment_category
      => p_rec.assignment_category
      ,p_per_information_category
      => p_rec.per_information_category
      ,p_per_information1
      => p_rec.per_information1
      ,p_per_information2
      => p_rec.per_information2
      ,p_per_information3
      => p_rec.per_information3
      ,p_per_information4
      => p_rec.per_information4
      ,p_per_information5
      => p_rec.per_information5
      ,p_per_information6
      => p_rec.per_information6
      ,p_per_information7
      => p_rec.per_information7
      ,p_per_information8
      => p_rec.per_information8
      ,p_per_information9
      => p_rec.per_information9
      ,p_per_information10
      => p_rec.per_information10
      ,p_per_information11
      => p_rec.per_information11
      ,p_per_information12
      => p_rec.per_information12
      ,p_per_information13
      => p_rec.per_information13
      ,p_per_information14
      => p_rec.per_information14
      ,p_per_information15
      => p_rec.per_information15
      ,p_per_information16
      => p_rec.per_information16
      ,p_per_information17
      => p_rec.per_information17
      ,p_per_information18
      => p_rec.per_information18
      ,p_per_information19
      => p_rec.per_information19
      ,p_per_information20
      => p_rec.per_information20
      ,p_per_information21
      => p_rec.per_information21
      ,p_per_information22
      => p_rec.per_information22
      ,p_per_information23
      => p_rec.per_information23
      ,p_per_information24
      => p_rec.per_information24
      ,p_per_information25
      => p_rec.per_information25
      ,p_per_information26
      => p_rec.per_information26
      ,p_per_information27
      => p_rec.per_information27
      ,p_per_information28
      => p_rec.per_information28
      ,p_per_information29
      => p_rec.per_information29
      ,p_per_information30
      => p_rec.per_information30
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
  (p_rec in out nocopy hr_pdt_shd.g_rec_type
  ) is
--
Begin
  --
  -- We must now examine each argument value in the
  -- p_rec plsql record structure
  -- to see if a system default is being used. If a system default
  -- is being used then we must set to the 'current' argument value.
  --
  If (p_rec.from_business_group_id = hr_api.g_number) then
    p_rec.from_business_group_id :=
    hr_pdt_shd.g_old_rec.from_business_group_id;
  End If;
  If (p_rec.to_business_group_id = hr_api.g_number) then
    p_rec.to_business_group_id :=
    hr_pdt_shd.g_old_rec.to_business_group_id;
  End If;
  If (p_rec.from_person_id = hr_api.g_number) then
    p_rec.from_person_id :=
    hr_pdt_shd.g_old_rec.from_person_id;
  End If;
  If (p_rec.to_person_id = hr_api.g_number) then
    p_rec.to_person_id :=
    hr_pdt_shd.g_old_rec.to_person_id;
  End If;
  If (p_rec.person_type_id = hr_api.g_number) then
    p_rec.person_type_id :=
    hr_pdt_shd.g_old_rec.person_type_id;
  End If;
  If (p_rec.start_date = hr_api.g_date) then
    p_rec.start_date :=
    hr_pdt_shd.g_old_rec.start_date;
  End If;
  If (p_rec.end_date = hr_api.g_date) then
    p_rec.end_date :=
    hr_pdt_shd.g_old_rec.end_date;
  End If;
  If (p_rec.deployment_reason = hr_api.g_varchar2) then
    p_rec.deployment_reason :=
    hr_pdt_shd.g_old_rec.deployment_reason;
  End If;
  If (p_rec.employee_number = hr_api.g_varchar2) then
    p_rec.employee_number :=
    hr_pdt_shd.g_old_rec.employee_number;
  End If;
  If (p_rec.leaving_reason = hr_api.g_varchar2) then
    p_rec.leaving_reason :=
    hr_pdt_shd.g_old_rec.leaving_reason;
  End If;
  If (p_rec.leaving_person_type_id = hr_api.g_number) then
    p_rec.leaving_person_type_id :=
    hr_pdt_shd.g_old_rec.leaving_person_type_id;
  End If;
  If (p_rec.permanent = hr_api.g_varchar2) then
    p_rec.permanent :=
    hr_pdt_shd.g_old_rec.permanent;
  End If;
  If (p_rec.status = hr_api.g_varchar2) then
    p_rec.status :=
    hr_pdt_shd.g_old_rec.status;
  End If;
  If (p_rec.status_change_reason = hr_api.g_varchar2) then
    p_rec.status_change_reason :=
    hr_pdt_shd.g_old_rec.status_change_reason;
  End If;
  If (p_rec.status_change_date = hr_api.g_date) then
    p_rec.status_change_date :=
    hr_pdt_shd.g_old_rec.status_change_date;
  End If;
  If (p_rec.deplymt_policy_id = hr_api.g_number) then
    p_rec.deplymt_policy_id :=
    hr_pdt_shd.g_old_rec.deplymt_policy_id;
  End If;
  If (p_rec.organization_id = hr_api.g_number) then
    p_rec.organization_id :=
    hr_pdt_shd.g_old_rec.organization_id;
  End If;
  If (p_rec.location_id = hr_api.g_number) then
    p_rec.location_id :=
    hr_pdt_shd.g_old_rec.location_id;
  End If;
  If (p_rec.job_id = hr_api.g_number) then
    p_rec.job_id :=
    hr_pdt_shd.g_old_rec.job_id;
  End If;
  If (p_rec.position_id = hr_api.g_number) then
    p_rec.position_id :=
    hr_pdt_shd.g_old_rec.position_id;
  End If;
  If (p_rec.grade_id = hr_api.g_number) then
    p_rec.grade_id :=
    hr_pdt_shd.g_old_rec.grade_id;
  End If;
  If (p_rec.supervisor_id = hr_api.g_number) then
    p_rec.supervisor_id :=
    hr_pdt_shd.g_old_rec.supervisor_id;
  End If;
  If (p_rec.supervisor_assignment_id = hr_api.g_number) then
    p_rec.supervisor_assignment_id :=
    hr_pdt_shd.g_old_rec.supervisor_assignment_id;
  End If;
  If (p_rec.retain_direct_reports = hr_api.g_varchar2) then
    p_rec.retain_direct_reports :=
    hr_pdt_shd.g_old_rec.retain_direct_reports;
  End If;
  If (p_rec.payroll_id = hr_api.g_number) then
    p_rec.payroll_id :=
    hr_pdt_shd.g_old_rec.payroll_id;
  End If;
  If (p_rec.pay_basis_id = hr_api.g_number) then
    p_rec.pay_basis_id :=
    hr_pdt_shd.g_old_rec.pay_basis_id;
  End If;
  If (p_rec.proposed_salary = hr_api.g_varchar2) then
    p_rec.proposed_salary :=
    hr_pdt_shd.g_old_rec.proposed_salary;
  End If;
  If (p_rec.people_group_id = hr_api.g_number) then
    p_rec.people_group_id :=
    hr_pdt_shd.g_old_rec.people_group_id;
  End If;
  If (p_rec.soft_coding_keyflex_id = hr_api.g_number) then
    p_rec.soft_coding_keyflex_id :=
    hr_pdt_shd.g_old_rec.soft_coding_keyflex_id;
  End If;
  If (p_rec.assignment_status_type_id = hr_api.g_number) then
    p_rec.assignment_status_type_id :=
    hr_pdt_shd.g_old_rec.assignment_status_type_id;
  End If;
  If (p_rec.ass_status_change_reason = hr_api.g_varchar2) then
    p_rec.ass_status_change_reason :=
    hr_pdt_shd.g_old_rec.ass_status_change_reason;
  End If;
  If (p_rec.assignment_category = hr_api.g_varchar2) then
    p_rec.assignment_category :=
    hr_pdt_shd.g_old_rec.assignment_category;
  End If;
  If (p_rec.per_information_category = hr_api.g_varchar2) then
    p_rec.per_information_category :=
    hr_pdt_shd.g_old_rec.per_information_category;
  End If;
  If (p_rec.per_information1 = hr_api.g_varchar2) then
    p_rec.per_information1 :=
    hr_pdt_shd.g_old_rec.per_information1;
  End If;
  If (p_rec.per_information2 = hr_api.g_varchar2) then
    p_rec.per_information2 :=
    hr_pdt_shd.g_old_rec.per_information2;
  End If;
  If (p_rec.per_information3 = hr_api.g_varchar2) then
    p_rec.per_information3 :=
    hr_pdt_shd.g_old_rec.per_information3;
  End If;
  If (p_rec.per_information4 = hr_api.g_varchar2) then
    p_rec.per_information4 :=
    hr_pdt_shd.g_old_rec.per_information4;
  End If;
  If (p_rec.per_information5 = hr_api.g_varchar2) then
    p_rec.per_information5 :=
    hr_pdt_shd.g_old_rec.per_information5;
  End If;
  If (p_rec.per_information6 = hr_api.g_varchar2) then
    p_rec.per_information6 :=
    hr_pdt_shd.g_old_rec.per_information6;
  End If;
  If (p_rec.per_information7 = hr_api.g_varchar2) then
    p_rec.per_information7 :=
    hr_pdt_shd.g_old_rec.per_information7;
  End If;
  If (p_rec.per_information8 = hr_api.g_varchar2) then
    p_rec.per_information8 :=
    hr_pdt_shd.g_old_rec.per_information8;
  End If;
  If (p_rec.per_information9 = hr_api.g_varchar2) then
    p_rec.per_information9 :=
    hr_pdt_shd.g_old_rec.per_information9;
  End If;
  If (p_rec.per_information10 = hr_api.g_varchar2) then
    p_rec.per_information10 :=
    hr_pdt_shd.g_old_rec.per_information10;
  End If;
  If (p_rec.per_information11 = hr_api.g_varchar2) then
    p_rec.per_information11 :=
    hr_pdt_shd.g_old_rec.per_information11;
  End If;
  If (p_rec.per_information12 = hr_api.g_varchar2) then
    p_rec.per_information12 :=
    hr_pdt_shd.g_old_rec.per_information12;
  End If;
  If (p_rec.per_information13 = hr_api.g_varchar2) then
    p_rec.per_information13 :=
    hr_pdt_shd.g_old_rec.per_information13;
  End If;
  If (p_rec.per_information14 = hr_api.g_varchar2) then
    p_rec.per_information14 :=
    hr_pdt_shd.g_old_rec.per_information14;
  End If;
  If (p_rec.per_information15 = hr_api.g_varchar2) then
    p_rec.per_information15 :=
    hr_pdt_shd.g_old_rec.per_information15;
  End If;
  If (p_rec.per_information16 = hr_api.g_varchar2) then
    p_rec.per_information16 :=
    hr_pdt_shd.g_old_rec.per_information16;
  End If;
  If (p_rec.per_information17 = hr_api.g_varchar2) then
    p_rec.per_information17 :=
    hr_pdt_shd.g_old_rec.per_information17;
  End If;
  If (p_rec.per_information18 = hr_api.g_varchar2) then
    p_rec.per_information18 :=
    hr_pdt_shd.g_old_rec.per_information18;
  End If;
  If (p_rec.per_information19 = hr_api.g_varchar2) then
    p_rec.per_information19 :=
    hr_pdt_shd.g_old_rec.per_information19;
  End If;
  If (p_rec.per_information20 = hr_api.g_varchar2) then
    p_rec.per_information20 :=
    hr_pdt_shd.g_old_rec.per_information20;
  End If;
  If (p_rec.per_information21 = hr_api.g_varchar2) then
    p_rec.per_information21 :=
    hr_pdt_shd.g_old_rec.per_information21;
  End If;
  If (p_rec.per_information22 = hr_api.g_varchar2) then
    p_rec.per_information22 :=
    hr_pdt_shd.g_old_rec.per_information22;
  End If;
  If (p_rec.per_information23 = hr_api.g_varchar2) then
    p_rec.per_information23 :=
    hr_pdt_shd.g_old_rec.per_information23;
  End If;
  If (p_rec.per_information24 = hr_api.g_varchar2) then
    p_rec.per_information24 :=
    hr_pdt_shd.g_old_rec.per_information24;
  End If;
  If (p_rec.per_information25 = hr_api.g_varchar2) then
    p_rec.per_information25 :=
    hr_pdt_shd.g_old_rec.per_information25;
  End If;
  If (p_rec.per_information26 = hr_api.g_varchar2) then
    p_rec.per_information26 :=
    hr_pdt_shd.g_old_rec.per_information26;
  End If;
  If (p_rec.per_information27 = hr_api.g_varchar2) then
    p_rec.per_information27 :=
    hr_pdt_shd.g_old_rec.per_information27;
  End If;
  If (p_rec.per_information28 = hr_api.g_varchar2) then
    p_rec.per_information28 :=
    hr_pdt_shd.g_old_rec.per_information28;
  End If;
  If (p_rec.per_information29 = hr_api.g_varchar2) then
    p_rec.per_information29 :=
    hr_pdt_shd.g_old_rec.per_information29;
  End If;
  If (p_rec.per_information30 = hr_api.g_varchar2) then
    p_rec.per_information30 :=
    hr_pdt_shd.g_old_rec.per_information30;
  End If;
  --
End convert_defs;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (p_rec                          in out nocopy hr_pdt_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to update.
  --
  hr_pdt_shd.lck
    (p_rec.person_deployment_id
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
  hr_pdt_bus.update_validate
     (p_rec
     );
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
  -- Set the status change date if the status has changed
  --
  if p_rec.status <> hr_pdt_shd.g_old_rec.status then
     p_rec.status_change_date := trunc(sysdate);
  else
     p_rec.status_change_date := hr_pdt_shd.g_old_rec.status_change_date;
  end if;
  --
  -- Call the supporting pre-update operation
  --
  hr_pdt_upd.pre_update(p_rec);
  --
  -- Update the row.
  --
  hr_pdt_upd.update_dml(p_rec);
  --
  -- Call the supporting post-update operation
  --
  hr_pdt_upd.post_update
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
  (p_person_deployment_id         in     number
  ,p_object_version_number        in out nocopy number
  ,p_from_business_group_id       in     number    default hr_api.g_number
  ,p_to_business_group_id         in     number    default hr_api.g_number
  ,p_from_person_id               in     number    default hr_api.g_number
  ,p_person_type_id               in     number    default hr_api.g_number
  ,p_start_date                   in     date      default hr_api.g_date
  ,p_status                       in     varchar2  default hr_api.g_varchar2
  ,p_to_person_id                 in     number    default hr_api.g_number
  ,p_end_date                     in     date      default hr_api.g_date
  ,p_deployment_reason            in     varchar2  default hr_api.g_varchar2
  ,p_employee_number              in     varchar2  default hr_api.g_varchar2
  ,p_leaving_reason               in     varchar2  default hr_api.g_varchar2
  ,p_leaving_person_type_id       in     number    default hr_api.g_number
  ,p_permanent                    in     varchar2  default hr_api.g_varchar2
  ,p_status_change_reason         in     varchar2  default hr_api.g_varchar2
  ,p_deplymt_policy_id            in     number    default hr_api.g_number
  ,p_organization_id              in     number    default hr_api.g_number
  ,p_location_id                  in     number    default hr_api.g_number
  ,p_job_id                       in     number    default hr_api.g_number
  ,p_position_id                  in     number    default hr_api.g_number
  ,p_grade_id                     in     number    default hr_api.g_number
  ,p_supervisor_id                in     number    default hr_api.g_number
  ,p_supervisor_assignment_id     in     number    default hr_api.g_number
  ,p_retain_direct_reports        in     varchar2  default hr_api.g_varchar2
  ,p_payroll_id                   in     number    default hr_api.g_number
  ,p_pay_basis_id                 in     number    default hr_api.g_number
  ,p_proposed_salary              in     varchar2  default hr_api.g_varchar2
  ,p_people_group_id              in     number    default hr_api.g_number
  ,p_soft_coding_keyflex_id       in     number    default hr_api.g_number
  ,p_assignment_status_type_id    in     number    default hr_api.g_number
  ,p_ass_status_change_reason     in     varchar2  default hr_api.g_varchar2
  ,p_assignment_category          in     varchar2  default hr_api.g_varchar2
  ,p_per_information_category     in     varchar2  default hr_api.g_varchar2
  ,p_per_information1             in     varchar2  default hr_api.g_varchar2
  ,p_per_information2             in     varchar2  default hr_api.g_varchar2
  ,p_per_information3             in     varchar2  default hr_api.g_varchar2
  ,p_per_information4             in     varchar2  default hr_api.g_varchar2
  ,p_per_information5             in     varchar2  default hr_api.g_varchar2
  ,p_per_information6             in     varchar2  default hr_api.g_varchar2
  ,p_per_information7             in     varchar2  default hr_api.g_varchar2
  ,p_per_information8             in     varchar2  default hr_api.g_varchar2
  ,p_per_information9             in     varchar2  default hr_api.g_varchar2
  ,p_per_information10            in     varchar2  default hr_api.g_varchar2
  ,p_per_information11            in     varchar2  default hr_api.g_varchar2
  ,p_per_information12            in     varchar2  default hr_api.g_varchar2
  ,p_per_information13            in     varchar2  default hr_api.g_varchar2
  ,p_per_information14            in     varchar2  default hr_api.g_varchar2
  ,p_per_information15            in     varchar2  default hr_api.g_varchar2
  ,p_per_information16            in     varchar2  default hr_api.g_varchar2
  ,p_per_information17            in     varchar2  default hr_api.g_varchar2
  ,p_per_information18            in     varchar2  default hr_api.g_varchar2
  ,p_per_information19            in     varchar2  default hr_api.g_varchar2
  ,p_per_information20            in     varchar2  default hr_api.g_varchar2
  ,p_per_information21            in     varchar2  default hr_api.g_varchar2
  ,p_per_information22            in     varchar2  default hr_api.g_varchar2
  ,p_per_information23            in     varchar2  default hr_api.g_varchar2
  ,p_per_information24            in     varchar2  default hr_api.g_varchar2
  ,p_per_information25            in     varchar2  default hr_api.g_varchar2
  ,p_per_information26            in     varchar2  default hr_api.g_varchar2
  ,p_per_information27            in     varchar2  default hr_api.g_varchar2
  ,p_per_information28            in     varchar2  default hr_api.g_varchar2
  ,p_per_information29            in     varchar2  default hr_api.g_varchar2
  ,p_per_information30            in     varchar2  default hr_api.g_varchar2
  ) is
--
  l_rec   hr_pdt_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  hr_pdt_shd.convert_args
  (p_person_deployment_id
  ,p_object_version_number
  ,p_from_business_group_id
  ,p_to_business_group_id
  ,p_from_person_id
  ,p_to_person_id
  ,p_person_type_id
  ,p_start_date
  ,p_end_date
  ,p_deployment_reason
  ,p_employee_number
  ,p_leaving_reason
  ,p_leaving_person_type_id
  ,p_permanent
  ,p_status
  ,p_status_change_reason
  ,null
  ,p_deplymt_policy_id
  ,p_organization_id
  ,p_location_id
  ,p_job_id
  ,p_position_id
  ,p_grade_id
  ,p_supervisor_id
  ,p_supervisor_assignment_id
  ,p_retain_direct_reports
  ,p_payroll_id
  ,p_pay_basis_id
  ,p_proposed_salary
  ,p_people_group_id
  ,p_soft_coding_keyflex_id
  ,p_assignment_status_type_id
  ,p_ass_status_change_reason
  ,p_assignment_category
  ,p_per_information_category
  ,p_per_information1
  ,p_per_information2
  ,p_per_information3
  ,p_per_information4
  ,p_per_information5
  ,p_per_information6
  ,p_per_information7
  ,p_per_information8
  ,p_per_information9
  ,p_per_information10
  ,p_per_information11
  ,p_per_information12
  ,p_per_information13
  ,p_per_information14
  ,p_per_information15
  ,p_per_information16
  ,p_per_information17
  ,p_per_information18
  ,p_per_information19
  ,p_per_information20
  ,p_per_information21
  ,p_per_information22
  ,p_per_information23
  ,p_per_information24
  ,p_per_information25
  ,p_per_information26
  ,p_per_information27
  ,p_per_information28
  ,p_per_information29
  ,p_per_information30
  );
  --
  -- Having converted the arguments into the
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  hr_pdt_upd.upd
     (l_rec
     );
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End upd;
--
end hr_pdt_upd;

/
