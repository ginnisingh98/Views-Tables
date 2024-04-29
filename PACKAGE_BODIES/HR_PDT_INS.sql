--------------------------------------------------------
--  DDL for Package Body HR_PDT_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_PDT_INS" as
/* $Header: hrpdtrhi.pkb 120.4.12010000.2 2008/08/06 08:46:56 ubhat ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  hr_pdt_ins.';  -- Global package name
--
-- The following global variables are only to be used by
-- the set_base_key_value and pre_insert procedures.
--
g_person_deployment_id_i  number   default null;
--
-- ----------------------------------------------------------------------------
-- |------------------------< set_base_key_value >----------------------------|
-- ----------------------------------------------------------------------------
procedure set_base_key_value
  (p_person_deployment_id  in  number) is
--
  l_proc       varchar2(72) := g_package||'set_base_key_value';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  hr_pdt_ins.g_person_deployment_id_i := p_person_deployment_id;
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
  (p_rec in out nocopy hr_pdt_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'insert_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  p_rec.object_version_number := 1;  -- Initialise the object version
  --
  --
  --
  -- Insert the row into: hr_person_deployments
  --
  insert into hr_person_deployments
      (person_deployment_id
      ,object_version_number
      ,from_business_group_id
      ,to_business_group_id
      ,from_person_id
      ,to_person_id
      ,person_type_id
      ,start_date
      ,end_date
      ,deployment_reason
      ,employee_number
      ,leaving_reason
      ,leaving_person_type_id
      ,permanent
      ,status
      ,status_change_reason
      ,status_change_date
      ,deplymt_policy_id
      ,organization_id
      ,location_id
      ,job_id
      ,position_id
      ,grade_id
      ,supervisor_id
      ,supervisor_assignment_id
      ,retain_direct_reports
      ,payroll_id
      ,pay_basis_id
      ,proposed_salary
      ,people_group_id
      ,soft_coding_keyflex_id
      ,assignment_status_type_id
      ,ass_status_change_reason
      ,assignment_category
      ,per_information_category
      ,per_information1
      ,per_information2
      ,per_information3
      ,per_information4
      ,per_information5
      ,per_information6
      ,per_information7
      ,per_information8
      ,per_information9
      ,per_information10
      ,per_information11
      ,per_information12
      ,per_information13
      ,per_information14
      ,per_information15
      ,per_information16
      ,per_information17
      ,per_information18
      ,per_information19
      ,per_information20
      ,per_information21
      ,per_information22
      ,per_information23
      ,per_information24
      ,per_information25
      ,per_information26
      ,per_information27
      ,per_information28
      ,per_information29
      ,per_information30
      )
  Values
    (p_rec.person_deployment_id
    ,p_rec.object_version_number
    ,p_rec.from_business_group_id
    ,p_rec.to_business_group_id
    ,p_rec.from_person_id
    ,p_rec.to_person_id
    ,p_rec.person_type_id
    ,p_rec.start_date
    ,p_rec.end_date
    ,p_rec.deployment_reason
    ,p_rec.employee_number
    ,p_rec.leaving_reason
    ,p_rec.leaving_person_type_id
    ,p_rec.permanent
    ,p_rec.status
    ,p_rec.status_change_reason
    ,p_rec.status_change_date
    ,p_rec.deplymt_policy_id
    ,p_rec.organization_id
    ,p_rec.location_id
    ,p_rec.job_id
    ,p_rec.position_id
    ,p_rec.grade_id
    ,p_rec.supervisor_id
    ,p_rec.supervisor_assignment_id
    ,p_rec.retain_direct_reports
    ,p_rec.payroll_id
    ,p_rec.pay_basis_id
    ,p_rec.proposed_salary
    ,p_rec.people_group_id
    ,p_rec.soft_coding_keyflex_id
    ,p_rec.assignment_status_type_id
    ,p_rec.ass_status_change_reason
    ,p_rec.assignment_category
    ,p_rec.per_information_category
    ,p_rec.per_information1
    ,p_rec.per_information2
    ,p_rec.per_information3
    ,p_rec.per_information4
    ,p_rec.per_information5
    ,p_rec.per_information6
    ,p_rec.per_information7
    ,p_rec.per_information8
    ,p_rec.per_information9
    ,p_rec.per_information10
    ,p_rec.per_information11
    ,p_rec.per_information12
    ,p_rec.per_information13
    ,p_rec.per_information14
    ,p_rec.per_information15
    ,p_rec.per_information16
    ,p_rec.per_information17
    ,p_rec.per_information18
    ,p_rec.per_information19
    ,p_rec.per_information20
    ,p_rec.per_information21
    ,p_rec.per_information22
    ,p_rec.per_information23
    ,p_rec.per_information24
    ,p_rec.per_information25
    ,p_rec.per_information26
    ,p_rec.per_information27
    ,p_rec.per_information28
    ,p_rec.per_information29
    ,p_rec.per_information30
    );
  --
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
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
  (p_rec  in out nocopy hr_pdt_shd.g_rec_type
  ) is
--
  Cursor C_Sel1 is select hr_person_deployments_s.nextval from sys.dual;
--
  Cursor C_Sel2 is
    Select null
      from hr_person_deployments
     where person_deployment_id =
             hr_pdt_ins.g_person_deployment_id_i;
--
  l_proc   varchar2(72) := g_package||'pre_insert';
  l_exists varchar2(1);
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (hr_pdt_ins.g_person_deployment_id_i is not null) Then
    --
    -- Verify registered primary key values not already in use
    --
    Open C_Sel2;
    Fetch C_Sel2 into l_exists;
    If C_Sel2%found Then
       Close C_Sel2;
       --
       -- The primary key values are already in use.
       --
       fnd_message.set_name('PER','PER_289391_KEY_ALREADY_USED');
       fnd_message.set_token('TABLE_NAME','hr_person_deployments');
       fnd_message.raise_error;
    End If;
    Close C_Sel2;
    --
    -- Use registered key values and clear globals
    --
    p_rec.person_deployment_id :=
      hr_pdt_ins.g_person_deployment_id_i;
    hr_pdt_ins.g_person_deployment_id_i := null;
  Else
    --
    -- No registerd key values, so select the next sequence number
    --
    --
    -- Select the next sequence number
    --
    Open C_Sel1;
    Fetch C_Sel1 Into p_rec.person_deployment_id;
    Close C_Sel1;
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
  (p_rec                          in hr_pdt_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'post_insert';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  begin
    --
    hr_pdt_rki.after_insert
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
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'HR_PERSON_DEPLOYMENTS'
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
  (p_rec                          in out nocopy hr_pdt_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call the supporting insert validate operations
  --
  hr_pdt_bus.insert_validate
     (p_rec
     );
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
  -- Set the status_change_date
  --
  p_rec.status_change_date := trunc(sysdate);
  --
  -- Call the supporting pre-insert operation
  --
  hr_pdt_ins.pre_insert(p_rec);
  --
  -- Insert the row
  --
  hr_pdt_ins.insert_dml(p_rec);
  --
  -- Call the supporting post-insert operation
  --
  hr_pdt_ins.post_insert
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
  (p_from_business_group_id         in     number
  ,p_to_business_group_id           in     number
  ,p_from_person_id                 in     number
  ,p_person_type_id                 in     number
  ,p_start_date                     in     date
  ,p_status                         in     varchar2
  ,p_to_person_id                   in     number   default null
  ,p_end_date                       in     date     default null
  ,p_deployment_reason              in     varchar2 default null
  ,p_employee_number                in     varchar2 default null
  ,p_leaving_reason                 in     varchar2 default null
  ,p_leaving_person_type_id         in     number   default null
  ,p_permanent                      in     varchar2 default null
  ,p_status_change_reason           in     varchar2 default null
  ,p_deplymt_policy_id              in     number   default null
  ,p_organization_id                in     number   default null
  ,p_location_id                    in     number   default null
  ,p_job_id                         in     number   default null
  ,p_position_id                    in     number   default null
  ,p_grade_id                       in     number   default null
  ,p_supervisor_id                  in     number   default null
  ,p_supervisor_assignment_id       in     number   default null
  ,p_retain_direct_reports          in     varchar2 default null
  ,p_payroll_id                     in     number   default null
  ,p_pay_basis_id                   in     number   default null
  ,p_proposed_salary                in     varchar2 default null
  ,p_people_group_id                in     number   default null
  ,p_soft_coding_keyflex_id         in     number   default null
  ,p_assignment_status_type_id      in     number   default null
  ,p_ass_status_change_reason       in     varchar2 default null
  ,p_assignment_category            in     varchar2 default null
  ,p_per_information_category       in     varchar2 default null
  ,p_per_information1               in     varchar2 default null
  ,p_per_information2               in     varchar2 default null
  ,p_per_information3               in     varchar2 default null
  ,p_per_information4               in     varchar2 default null
  ,p_per_information5               in     varchar2 default null
  ,p_per_information6               in     varchar2 default null
  ,p_per_information7               in     varchar2 default null
  ,p_per_information8               in     varchar2 default null
  ,p_per_information9               in     varchar2 default null
  ,p_per_information10              in     varchar2 default null
  ,p_per_information11              in     varchar2 default null
  ,p_per_information12              in     varchar2 default null
  ,p_per_information13              in     varchar2 default null
  ,p_per_information14              in     varchar2 default null
  ,p_per_information15              in     varchar2 default null
  ,p_per_information16              in     varchar2 default null
  ,p_per_information17              in     varchar2 default null
  ,p_per_information18              in     varchar2 default null
  ,p_per_information19              in     varchar2 default null
  ,p_per_information20              in     varchar2 default null
  ,p_per_information21              in     varchar2 default null
  ,p_per_information22              in     varchar2 default null
  ,p_per_information23              in     varchar2 default null
  ,p_per_information24              in     varchar2 default null
  ,p_per_information25              in     varchar2 default null
  ,p_per_information26              in     varchar2 default null
  ,p_per_information27              in     varchar2 default null
  ,p_per_information28              in     varchar2 default null
  ,p_per_information29              in     varchar2 default null
  ,p_per_information30              in     varchar2 default null
  ,p_person_deployment_id              out nocopy number
  ,p_object_version_number             out nocopy number
  ) is
--
  l_rec   hr_pdt_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  hr_pdt_shd.convert_args
    (null
    ,null
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
  -- Having converted the arguments into the hr_pdt_rec
  -- plsql record structure we call the corresponding record business process.
  --
  hr_pdt_ins.ins
     (l_rec
     );
  --
  -- As the primary key argument(s)
  -- are specified as an OUT's we must set these values.
  --
  p_person_deployment_id := l_rec.person_deployment_id;
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End ins;
--
end hr_pdt_ins;

/
