--------------------------------------------------------
--  DDL for Package Body HR_PDT_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_PDT_SHD" as
/* $Header: hrpdtrhi.pkb 120.4.12010000.2 2008/08/06 08:46:56 ubhat ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  hr_pdt_shd.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |---------------------------< constraint_error >---------------------------|
-- ----------------------------------------------------------------------------
Procedure constraint_error
  (p_constraint_name in all_constraints.constraint_name%TYPE
  ) Is
--
  l_proc        varchar2(72) := g_package||'constraint_error';
--
Begin
  --
  If (p_constraint_name = 'HR_PERSON_DEPLOYMENTS_PK') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','5');
    fnd_message.raise_error;
  Else
    fnd_message.set_name('PAY', 'HR_7877_API_INVALID_CONSTRAINT');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('CONSTRAINT_NAME', p_constraint_name);
    fnd_message.raise_error;
  End If;
  --
End constraint_error;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< api_updating >-----------------------------|
-- ----------------------------------------------------------------------------
Function api_updating
  (p_person_deployment_id                 in     number
  ,p_object_version_number                in     number
  )
  Return Boolean Is
  --
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
       person_deployment_id
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
    from        hr_person_deployments
    where       person_deployment_id = p_person_deployment_id;
  --
  l_fct_ret     boolean;
  --
Begin
  --
  If (p_person_deployment_id is null and
      p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_person_deployment_id
        = hr_pdt_shd.g_old_rec.person_deployment_id and
        p_object_version_number
        = hr_pdt_shd.g_old_rec.object_version_number
       ) Then
      --
      -- The g_old_rec is current therefore we must
      -- set the returning function to true
      --
      l_fct_ret := true;
    Else
      --
      -- Select the current row into g_old_rec
      --
      Open C_Sel1;
      Fetch C_Sel1 Into hr_pdt_shd.g_old_rec;
      If C_Sel1%notfound Then
        Close C_Sel1;
        --
        -- The primary key is invalid therefore we must error
        --
        fnd_message.set_name('PAY', 'HR_7220_INVALID_PRIMARY_KEY');
        fnd_message.raise_error;
      End If;
      Close C_Sel1;
      If (p_object_version_number
          <> hr_pdt_shd.g_old_rec.object_version_number) Then
        fnd_message.set_name('PAY', 'HR_7155_OBJECT_INVALID');
        fnd_message.raise_error;
      End If;
      l_fct_ret := true;
    End If;
  End If;
  Return (l_fct_ret);
--
End api_updating;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< lck >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure lck
  (p_person_deployment_id                 in     number
  ,p_object_version_number                in     number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select
       person_deployment_id
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
    from        hr_person_deployments
    where       person_deployment_id = p_person_deployment_id
    for update nowait;
--
  l_proc        varchar2(72) := g_package||'lck';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'PERSON_DEPLOYMENT_ID'
    ,p_argument_value     => p_person_deployment_id
    );
  hr_utility.set_location(l_proc,6);
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'OBJECT_VERSION_NUMBER'
    ,p_argument_value     => p_object_version_number
    );
  --
  Open  C_Sel1;
  Fetch C_Sel1 Into hr_pdt_shd.g_old_rec;
  If C_Sel1%notfound then
    Close C_Sel1;
    --
    -- The primary key is invalid therefore we must error
    --
    fnd_message.set_name('PAY', 'HR_7220_INVALID_PRIMARY_KEY');
    fnd_message.raise_error;
  End If;
  Close C_Sel1;
  If (p_object_version_number
      <> hr_pdt_shd.g_old_rec.object_version_number) Then
        fnd_message.set_name('PAY', 'HR_7155_OBJECT_INVALID');
        fnd_message.raise_error;
  End If;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  --
  -- We need to trap the ORA LOCK exception
  --
Exception
  When HR_Api.Object_Locked then
    --
    -- The object is locked therefore we need to supply a meaningful
    -- error message.
    --
    fnd_message.set_name('PAY', 'HR_7165_OBJECT_LOCKED');
    fnd_message.set_token('TABLE_NAME', 'hr_person_deployments');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
  (p_person_deployment_id           in number
  ,p_object_version_number          in number
  ,p_from_business_group_id         in number
  ,p_to_business_group_id           in number
  ,p_from_person_id                 in number
  ,p_to_person_id                   in number
  ,p_person_type_id                 in number
  ,p_start_date                     in date
  ,p_end_date                       in date
  ,p_deployment_reason              in varchar2
  ,p_employee_number                in varchar2
  ,p_leaving_reason                 in varchar2
  ,p_leaving_person_type_id         in number
  ,p_permanent                      in varchar2
  ,p_status                         in varchar2
  ,p_status_change_reason           in varchar2
  ,p_status_change_date             in date
  ,p_deplymt_policy_id              in number
  ,p_organization_id                in number
  ,p_location_id                    in number
  ,p_job_id                         in number
  ,p_position_id                    in number
  ,p_grade_id                       in number
  ,p_supervisor_id                  in number
  ,p_supervisor_assignment_id       in number
  ,p_retain_direct_reports          in varchar2
  ,p_payroll_id                     in number
  ,p_pay_basis_id                   in number
  ,p_proposed_salary                in varchar2
  ,p_people_group_id                in number
  ,p_soft_coding_keyflex_id         in number
  ,p_assignment_status_type_id      in number
  ,p_ass_status_change_reason       in varchar2
  ,p_assignment_category            in varchar2
  ,p_per_information_category       in varchar2
  ,p_per_information1               in varchar2
  ,p_per_information2               in varchar2
  ,p_per_information3               in varchar2
  ,p_per_information4               in varchar2
  ,p_per_information5               in varchar2
  ,p_per_information6               in varchar2
  ,p_per_information7               in varchar2
  ,p_per_information8               in varchar2
  ,p_per_information9               in varchar2
  ,p_per_information10              in varchar2
  ,p_per_information11              in varchar2
  ,p_per_information12              in varchar2
  ,p_per_information13              in varchar2
  ,p_per_information14              in varchar2
  ,p_per_information15              in varchar2
  ,p_per_information16              in varchar2
  ,p_per_information17              in varchar2
  ,p_per_information18              in varchar2
  ,p_per_information19              in varchar2
  ,p_per_information20              in varchar2
  ,p_per_information21              in varchar2
  ,p_per_information22              in varchar2
  ,p_per_information23              in varchar2
  ,p_per_information24              in varchar2
  ,p_per_information25              in varchar2
  ,p_per_information26              in varchar2
  ,p_per_information27              in varchar2
  ,p_per_information28              in varchar2
  ,p_per_information29              in varchar2
  ,p_per_information30              in varchar2
  )
  Return g_rec_type is
--
  l_rec   g_rec_type;
--
Begin
  --
  -- Convert arguments into local l_rec structure.
  --
  l_rec.person_deployment_id             := p_person_deployment_id;
  l_rec.object_version_number            := p_object_version_number;
  l_rec.from_business_group_id           := p_from_business_group_id;
  l_rec.to_business_group_id             := p_to_business_group_id;
  l_rec.from_person_id                   := p_from_person_id;
  l_rec.to_person_id                     := p_to_person_id;
  l_rec.person_type_id                   := p_person_type_id;
  l_rec.start_date                       := p_start_date;
  l_rec.end_date                         := p_end_date;
  l_rec.deployment_reason                := p_deployment_reason;
  l_rec.employee_number                  := p_employee_number;
  l_rec.leaving_reason                   := p_leaving_reason;
  l_rec.leaving_person_type_id           := p_leaving_person_type_id;
  l_rec.permanent                        := p_permanent;
  l_rec.status                           := p_status;
  l_rec.status_change_reason             := p_status_change_reason;
  l_rec.status_change_date               := p_status_change_date;
  l_rec.deplymt_policy_id                := p_deplymt_policy_id;
  l_rec.organization_id                  := p_organization_id;
  l_rec.location_id                      := p_location_id;
  l_rec.job_id                           := p_job_id;
  l_rec.position_id                      := p_position_id;
  l_rec.grade_id                         := p_grade_id;
  l_rec.supervisor_id                    := p_supervisor_id;
  l_rec.supervisor_assignment_id         := p_supervisor_assignment_id;
  l_rec.retain_direct_reports            := p_retain_direct_reports;
  l_rec.payroll_id                       := p_payroll_id;
  l_rec.pay_basis_id                     := p_pay_basis_id;
  l_rec.proposed_salary                  := p_proposed_salary;
  l_rec.people_group_id                  := p_people_group_id;
  l_rec.soft_coding_keyflex_id           := p_soft_coding_keyflex_id;
  l_rec.assignment_status_type_id        := p_assignment_status_type_id;
  l_rec.ass_status_change_reason         := p_ass_status_change_reason;
  l_rec.assignment_category              := p_assignment_category;
  l_rec.per_information_category         := p_per_information_category;
  l_rec.per_information1                 := p_per_information1;
  l_rec.per_information2                 := p_per_information2;
  l_rec.per_information3                 := p_per_information3;
  l_rec.per_information4                 := p_per_information4;
  l_rec.per_information5                 := p_per_information5;
  l_rec.per_information6                 := p_per_information6;
  l_rec.per_information7                 := p_per_information7;
  l_rec.per_information8                 := p_per_information8;
  l_rec.per_information9                 := p_per_information9;
  l_rec.per_information10                := p_per_information10;
  l_rec.per_information11                := p_per_information11;
  l_rec.per_information12                := p_per_information12;
  l_rec.per_information13                := p_per_information13;
  l_rec.per_information14                := p_per_information14;
  l_rec.per_information15                := p_per_information15;
  l_rec.per_information16                := p_per_information16;
  l_rec.per_information17                := p_per_information17;
  l_rec.per_information18                := p_per_information18;
  l_rec.per_information19                := p_per_information19;
  l_rec.per_information20                := p_per_information20;
  l_rec.per_information21                := p_per_information21;
  l_rec.per_information22                := p_per_information22;
  l_rec.per_information23                := p_per_information23;
  l_rec.per_information24                := p_per_information24;
  l_rec.per_information25                := p_per_information25;
  l_rec.per_information26                := p_per_information26;
  l_rec.per_information27                := p_per_information27;
  l_rec.per_information28                := p_per_information28;
  l_rec.per_information29                := p_per_information29;
  l_rec.per_information30                := p_per_information30;
  --
  -- Return the plsql record structure.
  --
  Return(l_rec);
--
End convert_args;
--
end hr_pdt_shd;

/
