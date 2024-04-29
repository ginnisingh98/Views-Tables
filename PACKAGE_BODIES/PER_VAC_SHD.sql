--------------------------------------------------------
--  DDL for Package Body PER_VAC_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_VAC_SHD" as
/* $Header: pevacrhi.pkb 120.0.12010000.2 2010/04/08 10:24:32 karthmoh ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  per_vac_shd.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------------------------< return_api_dml_status >-------------------------|
-- ----------------------------------------------------------------------------
Function return_api_dml_status Return Boolean Is
--
Begin
--
  Return (nvl(g_api_dml, false));
  --
End return_api_dml_status;
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
  if (p_constraint_name = 'PER_VACANCIES_FK1') then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','5');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'PER_VACANCIES_FK3') then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','10');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'PER_VACANCIES_FK4') then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','15');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'PER_VACANCIES_FK5') then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','20');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'PER_VACANCIES_FK6') then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','25');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'PER_VACANCIES_FK7') then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','30');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'PER_VACANCIES_FK8') then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','35');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'PER_VACANCIES_PK') then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','40');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'PER_VACANCIES_UK2') then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','45');
    fnd_message.raise_error;
  Else
    fnd_message.set_name('PAY', 'HR_7877_API_INVALID_CONSTRAINT');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('CONSTRAINT_NAME', p_constraint_name);
    fnd_message.raise_error;
  end if;
  --
End constraint_error;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< api_updating >-----------------------------|
-- ----------------------------------------------------------------------------
Function api_updating
  (p_vacancy_id                           in     number
  ,p_object_version_number                in     number
  )
  Return Boolean Is
  --
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
       vacancy_id
      ,business_group_id
      ,position_id
      ,job_id
      ,grade_id
      ,organization_id
      ,requisition_id
      ,people_group_id
      ,location_id
      ,recruiter_id
      ,date_from
      ,name
      ,comments
      ,date_to
      ,description
      ,number_of_openings
      ,status
      ,request_id
      ,program_application_id
      ,program_id
      ,program_update_date
      ,attribute_category
      ,attribute1
      ,attribute2
      ,attribute3
      ,attribute4
      ,attribute5
      ,attribute6
      ,attribute7
      ,attribute8
      ,attribute9
      ,attribute10
      ,attribute11
      ,attribute12
      ,attribute13
      ,attribute14
      ,attribute15
      ,attribute16
      ,attribute17
      ,attribute18
      ,attribute19
      ,attribute20
      ,vacancy_category
      ,budget_measurement_type
      ,budget_measurement_value
      ,manager_id
      ,security_method
      ,primary_posting_id
      ,assessment_id
      ,object_version_number
    from        per_all_vacancies
    where       vacancy_id = p_vacancy_id;
  --
  l_fct_ret     boolean;
  --
Begin
  --
  if (p_vacancy_id is null and
      p_object_version_number is null
     ) then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    if (p_vacancy_id
        = per_vac_shd.g_old_rec.vacancy_id and
        p_object_version_number
        = per_vac_shd.g_old_rec.object_version_number
       ) then
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
      Fetch C_Sel1 Into per_vac_shd.g_old_rec;
      if C_Sel1%notfound then
        Close C_Sel1;
        --
        -- The primary key is invalid therefore we must error
        --
        fnd_message.set_name('PAY', 'HR_7220_INVALID_PRIMARY_KEY');
        fnd_message.raise_error;
      end if;
      Close C_Sel1;
      if (p_object_version_number
          <> per_vac_shd.g_old_rec.object_version_number) then
        fnd_message.set_name('PAY', 'HR_7155_OBJECT_INVALID');
        fnd_message.raise_error;
      end if;
      l_fct_ret := true;
    end if;
  end if;
  Return (l_fct_ret);
--
End api_updating;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< lck >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure lck
  (p_vacancy_id                           in     number
  ,p_object_version_number                in     number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select
       vacancy_id
      ,business_group_id
      ,position_id
      ,job_id
      ,grade_id
      ,organization_id
      ,requisition_id
      ,people_group_id
      ,location_id
      ,recruiter_id
      ,date_from
      ,name
      ,comments
      ,date_to
      ,description
      ,number_of_openings
      ,status
      ,request_id
      ,program_application_id
      ,program_id
      ,program_update_date
      ,attribute_category
      ,attribute1
      ,attribute2
      ,attribute3
      ,attribute4
      ,attribute5
      ,attribute6
      ,attribute7
      ,attribute8
      ,attribute9
      ,attribute10
      ,attribute11
      ,attribute12
      ,attribute13
      ,attribute14
      ,attribute15
      ,attribute16
      ,attribute17
      ,attribute18
      ,attribute19
      ,attribute20
      ,vacancy_category
      ,budget_measurement_type
      ,budget_measurement_value
      ,manager_id
      ,security_method
      ,primary_posting_id
      ,assessment_id
      ,object_version_number
    from        per_all_vacancies
    where       vacancy_id = p_vacancy_id
    for update nowait;
--
  l_proc        varchar2(72) := g_package||'lck';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'VACANCY_ID'
    ,p_argument_value     => p_vacancy_id
    );
  hr_utility.set_location(l_proc,6);
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'OBJECT_VERSION_NUMBER'
    ,p_argument_value     => p_object_version_number
    );
  --
  Open  C_Sel1;
  Fetch C_Sel1 Into per_vac_shd.g_old_rec;
  if C_Sel1%notfound then
    Close C_Sel1;
    --
    -- The primary key is invalid therefore we must error
    --
    fnd_message.set_name('PAY', 'HR_7220_INVALID_PRIMARY_KEY');
    fnd_message.raise_error;
  end if;
  Close C_Sel1;
  if (p_object_version_number
      <> per_vac_shd.g_old_rec.object_version_number) then
        fnd_message.set_name('PAY', 'HR_7155_OBJECT_INVALID');
        fnd_message.raise_error;
  end if;
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
    fnd_message.set_token('TABLE_NAME', 'per_all_vacancies');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
  (p_vacancy_id                     in number
  ,p_business_group_id              in number
  ,p_position_id                    in number
  ,p_job_id                         in number
  ,p_grade_id                       in number
  ,p_organization_id                in number
  ,p_requisition_id                 in number
  ,p_people_group_id                in number
  ,p_location_id                    in number
  ,p_recruiter_id                   in number
  ,p_date_from                      in date
  ,p_name                           in varchar2
  ,p_comments                       in varchar2
  ,p_date_to                        in date
  ,p_description                    in varchar2
  ,p_number_of_openings             in number
  ,p_status                         in varchar2
  ,p_request_id                     in number
  ,p_program_application_id         in number
  ,p_program_id                     in number
  ,p_program_update_date            in date
  ,p_attribute_category             in varchar2
  ,p_attribute1                     in varchar2
  ,p_attribute2                     in varchar2
  ,p_attribute3                     in varchar2
  ,p_attribute4                     in varchar2
  ,p_attribute5                     in varchar2
  ,p_attribute6                     in varchar2
  ,p_attribute7                     in varchar2
  ,p_attribute8                     in varchar2
  ,p_attribute9                     in varchar2
  ,p_attribute10                    in varchar2
  ,p_attribute11                    in varchar2
  ,p_attribute12                    in varchar2
  ,p_attribute13                    in varchar2
  ,p_attribute14                    in varchar2
  ,p_attribute15                    in varchar2
  ,p_attribute16                    in varchar2
  ,p_attribute17                    in varchar2
  ,p_attribute18                    in varchar2
  ,p_attribute19                    in varchar2
  ,p_attribute20                    in varchar2
  ,p_vacancy_category               in varchar2
  ,p_budget_measurement_type        in varchar2
  ,p_budget_measurement_value       in number
  ,p_manager_id                     in number
  ,p_security_method                in varchar2
  ,p_primary_posting_id             in number
  ,p_assessment_id                  in number
  ,p_object_version_number          in number
  )
  Return g_rec_type is
--
  l_rec   g_rec_type;
--
Begin
  --
  -- Convert arguments into local l_rec structure.
  --
  l_rec.vacancy_id                       := p_vacancy_id;
  l_rec.business_group_id                := p_business_group_id;
  l_rec.position_id                      := p_position_id;
  l_rec.job_id                           := p_job_id;
  l_rec.grade_id                         := p_grade_id;
  l_rec.organization_id                  := p_organization_id;
  l_rec.requisition_id                   := p_requisition_id;
  l_rec.people_group_id                  := p_people_group_id;
  l_rec.location_id                      := p_location_id;
  l_rec.recruiter_id                     := p_recruiter_id;
  l_rec.date_from                        := p_date_from;
  l_rec.name                             := p_name;
  l_rec.comments                         := p_comments;
  l_rec.date_to                          := p_date_to;
  l_rec.description                      := p_description;
  l_rec.number_of_openings               := p_number_of_openings;
  l_rec.status                           := p_status;
  l_rec.request_id                       := p_request_id;
  l_rec.program_application_id           := p_program_application_id;
  l_rec.program_id                       := p_program_id;
  l_rec.program_update_date              := p_program_update_date;
  l_rec.attribute_category               := p_attribute_category;
  l_rec.attribute1                       := p_attribute1;
  l_rec.attribute2                       := p_attribute2;
  l_rec.attribute3                       := p_attribute3;
  l_rec.attribute4                       := p_attribute4;
  l_rec.attribute5                       := p_attribute5;
  l_rec.attribute6                       := p_attribute6;
  l_rec.attribute7                       := p_attribute7;
  l_rec.attribute8                       := p_attribute8;
  l_rec.attribute9                       := p_attribute9;
  l_rec.attribute10                      := p_attribute10;
  l_rec.attribute11                      := p_attribute11;
  l_rec.attribute12                      := p_attribute12;
  l_rec.attribute13                      := p_attribute13;
  l_rec.attribute14                      := p_attribute14;
  l_rec.attribute15                      := p_attribute15;
  l_rec.attribute16                      := p_attribute16;
  l_rec.attribute17                      := p_attribute17;
  l_rec.attribute18                      := p_attribute18;
  l_rec.attribute19                      := p_attribute19;
  l_rec.attribute20                      := p_attribute20;
  l_rec.vacancy_category                 := p_vacancy_category;
  l_rec.budget_measurement_type          := p_budget_measurement_type;
  l_rec.budget_measurement_value         := p_budget_measurement_value;
  l_rec.manager_id                       := p_manager_id;
  l_rec.security_method                  := p_security_method;
  l_rec.primary_posting_id               := p_primary_posting_id;
  l_rec.assessment_id                    := p_assessment_id;
  l_rec.object_version_number            := p_object_version_number;
  --
  -- Return the plsql record structure.
  --
  Return(l_rec);
--
End convert_args;
--
end per_vac_shd;

/
