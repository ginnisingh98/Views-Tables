--------------------------------------------------------
--  DDL for Package Body PER_DPF_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_DPF_SHD" as
/* $Header: pedpfrhi.pkb 115.13 2002/12/05 10:20:52 pkakar ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  per_dpf_shd.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------------------------< return_api_dml_status >-------------------------|
-- ----------------------------------------------------------------------------
Function return_api_dml_status Return Boolean Is
--
  l_proc 	varchar2(72) := g_package||'return_api_dml_status';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  Return (nvl(g_api_dml, false));
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End return_api_dml_status;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< constraint_error >---------------------------|
-- ----------------------------------------------------------------------------
Procedure constraint_error
            (p_constraint_name in all_constraints.constraint_name%TYPE) Is
--
  l_proc 	varchar2(72) := g_package||'constraint_error';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (p_constraint_name = 'PER_DEPLOYMENT_FACTORS_FK1') Then
    hr_utility.set_message(801,'HR_52026_DPF_CHK_JOB_ID');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'PER_DEPLOYMENT_FACTORS_FK2') Then
    hr_utility.set_message(801,'HR_52024_DPF_CHK_POSITION_ID');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'PER_DEPLOYMENT_FACTORS_FK3') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','15');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'PER_DEPLOYMENT_FACTORS_PK') Then
    hr_utility.set_message(801, 'HR_52041_DPF_DEP_FACTOR_PK');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'PER_DEPLOYMENT_FACTORS_UK') Then
    hr_utility.set_message(801, 'HR_52043_DPF_DEP_FACTOR_UK');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'PER_DPF_AVAILABLE_FOR_TRANSFER') Then
    hr_utility.set_message(801, 'HR_52044_DPF_DEP_AVAIL_TRANS');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'PER_DPF_ONLY_CURRENT_LOCATION') Then
    hr_utility.set_message(801, 'HR_52045_DPF_ONLY_CUR_LOCATION');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'PER_DPF_PASSPORT_REQUIRED') Then
    hr_utility.set_message(801, 'HR_52046_DPF_PASSPORT_REQUIRED');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'PER_DPF_RELOCATE_DOMESTICALLY') Then
    hr_utility.set_message(801, 'HR_52047_DPF_RELOCATE_DOMESTIC');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'PER_DPF_RELOCATE_INTERNATIONAL') Then
    hr_utility.set_message(801, 'HR_52048_DPF_RELOCATE_INTERNAT');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'PER_DPF_RELOCATION_REQUIRED') Then
    hr_utility.set_message(801, 'HR_52049_DPF_RELOCATION_REQUIR');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'PER_DPF_TRAVEL_REQUIRED') Then
    hr_utility.set_message(801, 'HR_52050_DPF_TRAVEL_REQUIRED');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'PER_DPF_VISIT_INTERNATIONALLY') Then
    hr_utility.set_message(801, 'HR_52051_DPF_VISIT_INTER');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'PER_DPF_WORK_ANY_COUNTRY') Then
    hr_utility.set_message(801, 'HR_52052_WORK_ANY_COUNTRY');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'PER_DPF_WORK_ANY_LOCATION') Then
    hr_utility.set_message(801, 'HR_52053_DPF_WORK_ANY_LOCATION');
    hr_utility.raise_error;
  Else
    hr_utility.set_message(801, 'HR_7877_API_INVALID_CONSTRAINT');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('CONSTRAINT_NAME', p_constraint_name);
    hr_utility.raise_error;
  End If;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End constraint_error;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< api_updating >-----------------------------|
-- ----------------------------------------------------------------------------
Function api_updating
  (
  p_deployment_factor_id               in number,
  p_object_version_number              in number
  )      Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
		deployment_factor_id,
	position_id,
	person_id,
	job_id,
	business_group_id,
	work_any_country,
	work_any_location,
	relocate_domestically,
	relocate_internationally,
	travel_required,
	country1,
	country2,
	country3,
	work_duration,
	work_schedule,
	work_hours,
	fte_capacity,
	visit_internationally,
	only_current_location,
	no_country1,
	no_country2,
	no_country3,
	comments,
	earliest_available_date,
	available_for_transfer,
	relocation_preference,
	relocation_required,
	passport_required,
	location1,
	location2,
	location3,
	other_requirements,
	service_minimum,
	object_version_number,
	attribute_category,
	attribute1,
	attribute2,
	attribute3,
	attribute4,
	attribute5,
	attribute6,
	attribute7,
	attribute8,
	attribute9,
	attribute10,
	attribute11,
	attribute12,
	attribute13,
	attribute14,
	attribute15,
	attribute16,
	attribute17,
	attribute18,
	attribute19,
	attribute20
    from	per_deployment_factors
    where	deployment_factor_id = p_deployment_factor_id;
--
  l_proc	varchar2(72)	:= g_package||'api_updating';
  l_fct_ret	boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (
	p_deployment_factor_id is null and
	p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (
	p_deployment_factor_id = g_old_rec.deployment_factor_id and
	p_object_version_number = g_old_rec.object_version_number
       ) Then
      hr_utility.set_location(l_proc, 10);
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
      Fetch C_Sel1 Into g_old_rec;
      If C_Sel1%notfound Then
        Close C_Sel1;
        --
        -- The primary key is invalid therefore we must error
        --
        hr_utility.set_message(801, 'HR_7220_INVALID_PRIMARY_KEY');
        hr_utility.raise_error;
      End If;
      Close C_Sel1;
      If (p_object_version_number <> g_old_rec.object_version_number) Then
        hr_utility.set_message(801, 'HR_7155_OBJECT_INVALID');
        hr_utility.raise_error;
      End If;
      hr_utility.set_location(l_proc, 15);
      l_fct_ret := true;
    End If;
  End If;
  hr_utility.set_location(' Leaving:'||l_proc, 20);
  Return (l_fct_ret);
--
End api_updating;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< lck >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure lck
  (
  p_deployment_factor_id               in number,
  p_object_version_number              in number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select 	deployment_factor_id,
	position_id,
	person_id,
	job_id,
	business_group_id,
	work_any_country,
	work_any_location,
	relocate_domestically,
	relocate_internationally,
	travel_required,
	country1,
	country2,
	country3,
	work_duration,
	work_schedule,
	work_hours,
	fte_capacity,
	visit_internationally,
	only_current_location,
	no_country1,
	no_country2,
	no_country3,
	comments,
	earliest_available_date,
	available_for_transfer,
	relocation_preference,
	relocation_required,
	passport_required,
	location1,
	location2,
	location3,
	other_requirements,
	service_minimum,
	object_version_number,
	attribute_category,
	attribute1,
	attribute2,
	attribute3,
	attribute4,
	attribute5,
	attribute6,
	attribute7,
	attribute8,
	attribute9,
	attribute10,
	attribute11,
	attribute12,
	attribute13,
	attribute14,
	attribute15,
	attribute16,
	attribute17,
	attribute18,
	attribute19,
	attribute20
    from	per_deployment_factors
    where	deployment_factor_id = p_deployment_factor_id
    for	update nowait;
--
  l_proc	varchar2(72) := g_package||'lck';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Add any mandatory argument checking here:
  -- Example:
  -- hr_api.mandatory_arg_error
  --   (p_api_name       => l_proc,
  --    p_argument       => 'object_version_number',
  --    p_argument_value => p_object_version_number);
  --
  Open  C_Sel1;
  Fetch C_Sel1 Into g_old_rec;
  If C_Sel1%notfound then
    Close C_Sel1;
    --
    -- The primary key is invalid therefore we must error
    --
    hr_utility.set_message(801, 'HR_7220_INVALID_PRIMARY_KEY');
    hr_utility.raise_error;
  End If;
  Close C_Sel1;
  If (p_object_version_number <> g_old_rec.object_version_number) Then
        hr_utility.set_message(801, 'HR_7155_OBJECT_INVALID');
        hr_utility.raise_error;
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
    hr_utility.set_message(801, 'HR_7165_OBJECT_LOCKED');
    hr_utility.set_message_token('TABLE_NAME', 'per_deployment_factors');
    hr_utility.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
	(
	p_deployment_factor_id          in number,
	p_position_id                   in number,
	p_person_id                     in number,
	p_job_id                        in number,
	p_business_group_id             in number,
	p_work_any_country              in varchar2,
	p_work_any_location             in varchar2,
	p_relocate_domestically         in varchar2,
	p_relocate_internationally      in varchar2,
	p_travel_required               in varchar2,
	p_country1                      in varchar2,
	p_country2                      in varchar2,
	p_country3                      in varchar2,
	p_work_duration                 in varchar2,
	p_work_schedule                 in varchar2,
	p_work_hours                    in varchar2,
	p_fte_capacity                  in varchar2,
	p_visit_internationally         in varchar2,
	p_only_current_location         in varchar2,
	p_no_country1                   in varchar2,
	p_no_country2                   in varchar2,
	p_no_country3                   in varchar2,
	p_comments                      in varchar2,
	p_earliest_available_date       in date,
	p_available_for_transfer        in varchar2,
	p_relocation_preference         in varchar2,
	p_relocation_required           in varchar2,
	p_passport_required             in varchar2,
	p_location1                     in varchar2,
	p_location2                     in varchar2,
	p_location3                     in varchar2,
	p_other_requirements            in varchar2,
	p_service_minimum               in varchar2,
	p_object_version_number         in number,
	p_attribute_category            in varchar2,
	p_attribute1                    in varchar2,
	p_attribute2                    in varchar2,
	p_attribute3                    in varchar2,
	p_attribute4                    in varchar2,
	p_attribute5                    in varchar2,
	p_attribute6                    in varchar2,
	p_attribute7                    in varchar2,
	p_attribute8                    in varchar2,
	p_attribute9                    in varchar2,
	p_attribute10                   in varchar2,
	p_attribute11                   in varchar2,
	p_attribute12                   in varchar2,
	p_attribute13                   in varchar2,
	p_attribute14                   in varchar2,
	p_attribute15                   in varchar2,
	p_attribute16                   in varchar2,
	p_attribute17                   in varchar2,
	p_attribute18                   in varchar2,
	p_attribute19                   in varchar2,
	p_attribute20                   in varchar2
	)
	Return g_rec_type is
--
  l_rec	  g_rec_type;
  l_proc  varchar2(72) := g_package||'convert_args';
--
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Convert arguments into local l_rec structure.
  --
  l_rec.deployment_factor_id             := p_deployment_factor_id;
  l_rec.position_id                      := p_position_id;
  l_rec.person_id                        := p_person_id;
  l_rec.job_id                           := p_job_id;
  l_rec.business_group_id                := p_business_group_id;
  l_rec.work_any_country                 := p_work_any_country;
  l_rec.work_any_location                := p_work_any_location;
  l_rec.relocate_domestically            := p_relocate_domestically;
  l_rec.relocate_internationally         := p_relocate_internationally;
  l_rec.travel_required                  := p_travel_required;
  l_rec.country1                         := p_country1;
  l_rec.country2                         := p_country2;
  l_rec.country3                         := p_country3;
  l_rec.work_duration                    := p_work_duration;
  l_rec.work_schedule                    := p_work_schedule;
  l_rec.work_hours                       := p_work_hours;
  l_rec.fte_capacity                     := p_fte_capacity;
  l_rec.visit_internationally            := p_visit_internationally;
  l_rec.only_current_location            := p_only_current_location;
  l_rec.no_country1                      := p_no_country1;
  l_rec.no_country2                      := p_no_country2;
  l_rec.no_country3                      := p_no_country3;
  l_rec.comments                         := p_comments;
  l_rec.earliest_available_date          := p_earliest_available_date;
  l_rec.available_for_transfer           := p_available_for_transfer;
  l_rec.relocation_preference            := p_relocation_preference;
  l_rec.relocation_required              := p_relocation_required;
  l_rec.passport_required                := p_passport_required;
  l_rec.location1                        := p_location1;
  l_rec.location2                        := p_location2;
  l_rec.location3                        := p_location3;
  l_rec.other_requirements               := p_other_requirements;
  l_rec.service_minimum                  := p_service_minimum;
  l_rec.object_version_number            := p_object_version_number;
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
  --
  -- Return the plsql record structure.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  Return(l_rec);
--
End convert_args;
--
end per_dpf_shd;

/
