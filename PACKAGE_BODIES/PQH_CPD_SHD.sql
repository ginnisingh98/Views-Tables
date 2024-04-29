--------------------------------------------------------
--  DDL for Package Body PQH_CPD_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_CPD_SHD" as
/* $Header: pqcpdrhi.pkb 120.0 2005/05/29 01:44:39 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  pqh_cpd_shd.';  -- Global package name
g_debug boolean := hr_utility.debug_enabled;
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
  If (p_constraint_name = 'PQH_CORPS_DEFINITIONS_PK') Then
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
  (p_corps_definition_id                  in     number
  ,p_object_version_number                in     number
  )
  Return Boolean Is
  --
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
       corps_definition_id
      ,business_group_id
      ,name
      ,status_cd
      ,retirement_age
      ,category_cd
      ,recruitment_end_date
      ,corps_type_cd
      ,starting_grade_step_id
      ,task_desc
      ,secondment_threshold
      ,normal_hours
      ,normal_hours_frequency
      ,minimum_hours
      ,minimum_hours_frequency
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
      ,attribute21
      ,attribute22
      ,attribute23
      ,attribute24
      ,attribute25
      ,attribute26
      ,attribute27
      ,attribute28
      ,attribute29
      ,attribute30
      ,attribute_category
      ,object_version_number
      ,type_of_ps
      ,date_from
      ,date_to
      ,primary_prof_field_id
      ,starting_grade_id
      ,ben_pgm_id
      ,probation_period
      ,probation_units
    from        pqh_corps_definitions
    where       corps_definition_id = p_corps_definition_id;
  --
  l_fct_ret     boolean;
  --
Begin
  --
  If (p_corps_definition_id is null and
      p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_corps_definition_id
        = pqh_cpd_shd.g_old_rec.corps_definition_id and
        p_object_version_number
        = pqh_cpd_shd.g_old_rec.object_version_number
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
      Fetch C_Sel1 Into pqh_cpd_shd.g_old_rec;
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
          <> pqh_cpd_shd.g_old_rec.object_version_number) Then
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
  (p_corps_definition_id                  in     number
  ,p_object_version_number                in     number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select
       corps_definition_id
      ,business_group_id
      ,name
      ,status_cd
      ,retirement_age
      ,category_cd
      ,recruitment_end_date
      ,corps_type_cd
      ,starting_grade_step_id
      ,task_desc
      ,secondment_threshold
      ,normal_hours
      ,normal_hours_frequency
      ,minimum_hours
      ,minimum_hours_frequency
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
      ,attribute21
      ,attribute22
      ,attribute23
      ,attribute24
      ,attribute25
      ,attribute26
      ,attribute27
      ,attribute28
      ,attribute29
      ,attribute30
      ,attribute_category
      ,object_version_number
      ,type_of_ps
      ,date_from
      ,date_to
      ,primary_prof_field_id
      ,starting_grade_id
      ,ben_pgm_id
      ,probation_period
      ,probation_units
    from        pqh_corps_definitions
    where       corps_definition_id = p_corps_definition_id
    for update nowait;
--
  l_proc        varchar2(72) ;
--
Begin
  g_debug := hr_utility.debug_enabled;
  if g_debug then
    l_proc := g_package||'lck';
    hr_utility.set_location('Entering:'||l_proc, 5);
  end if;
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'CORPS_DEFINITION_ID'
    ,p_argument_value     => p_corps_definition_id
    );
  if g_debug then
    hr_utility.set_location(l_proc,6);
  end if;
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'OBJECT_VERSION_NUMBER'
    ,p_argument_value     => p_object_version_number
    );
  --
  Open  C_Sel1;
  Fetch C_Sel1 Into pqh_cpd_shd.g_old_rec;
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
      <> pqh_cpd_shd.g_old_rec.object_version_number) Then
        fnd_message.set_name('PAY', 'HR_7155_OBJECT_INVALID');
        fnd_message.raise_error;
  End If;
  --
  if g_debug then
    hr_utility.set_location(' Leaving:'||l_proc, 10);
  end if;
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
    fnd_message.set_token('TABLE_NAME', 'pqh_corps_definitions');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
  (p_corps_definition_id            in number
  ,p_business_group_id              in number
  ,p_name                           in varchar2
  ,p_status_cd                      in varchar2
  ,p_retirement_age                 in number
  ,p_category_cd                    in varchar2
  ,p_recruitment_end_date           in date
  ,p_corps_type_cd                  in varchar2
  ,p_starting_grade_step_id         in number
  ,p_task_desc                      in varchar2
  ,p_secondment_threshold           in number
  ,p_normal_hours                   in number
  ,p_normal_hours_frequency         in varchar2
  ,p_minimum_hours                  in number
  ,p_minimum_hours_frequency        in varchar2
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
  ,p_attribute21                    in varchar2
  ,p_attribute22                    in varchar2
  ,p_attribute23                    in varchar2
  ,p_attribute24                    in varchar2
  ,p_attribute25                    in varchar2
  ,p_attribute26                    in varchar2
  ,p_attribute27                    in varchar2
  ,p_attribute28                    in varchar2
  ,p_attribute29                    in varchar2
  ,p_attribute30                    in varchar2
  ,p_attribute_category             in varchar2
  ,p_object_version_number          in number
  ,p_type_of_ps                     in varchar2
  ,p_date_from                      in date
  ,p_date_to                        in date
  ,p_primary_prof_field_id          in number
  ,p_starting_grade_id              in number
  ,p_ben_pgm_id                     in number
  ,p_probation_period               in number
  ,p_probation_units                in varchar2
  )
  Return g_rec_type is
--
  l_rec   g_rec_type;
--
Begin
  --
  -- Convert arguments into local l_rec structure.
  --
  l_rec.corps_definition_id              := p_corps_definition_id;
  l_rec.business_group_id                := p_business_group_id;
  l_rec.name                             := p_name;
  l_rec.status_cd                        := p_status_cd;
  l_rec.retirement_age                   := p_retirement_age;
  l_rec.category_cd                      := p_category_cd;
  l_rec.recruitment_end_date             := p_recruitment_end_date;
  l_rec.corps_type_cd                    := p_corps_type_cd;
  l_rec.starting_grade_step_id           := p_starting_grade_step_id;
  l_rec.task_desc                        := p_task_desc;
  l_rec.secondment_threshold             := p_secondment_threshold;
  l_rec.normal_hours                     := p_normal_hours;
  l_rec.normal_hours_frequency           := p_normal_hours_frequency;
  l_rec.minimum_hours                    := p_minimum_hours;
  l_rec.minimum_hours_frequency          := p_minimum_hours_frequency;
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
  l_rec.attribute21                      := p_attribute21;
  l_rec.attribute22                      := p_attribute22;
  l_rec.attribute23                      := p_attribute23;
  l_rec.attribute24                      := p_attribute24;
  l_rec.attribute25                      := p_attribute25;
  l_rec.attribute26                      := p_attribute26;
  l_rec.attribute27                      := p_attribute27;
  l_rec.attribute28                      := p_attribute28;
  l_rec.attribute29                      := p_attribute29;
  l_rec.attribute30                      := p_attribute30;
  l_rec.attribute_category               := p_attribute_category;
  l_rec.object_version_number            := p_object_version_number;
  l_rec.type_of_ps                       := p_type_of_ps;
  l_rec.date_from                        := p_date_from;
  l_rec.date_to                          := p_date_to;
  l_rec.primary_prof_field_id            := p_primary_prof_field_id;
  l_rec.starting_grade_id                := p_starting_grade_id;
  l_rec.ben_pgm_id                       := p_ben_pgm_id;
  l_rec.probation_period                 := p_probation_period;
  l_rec.probation_units                  := p_probation_units;
  --
  -- Return the plsql record structure.
  --
  Return(l_rec);
--
End convert_args;
--
end pqh_cpd_shd;

/
