--------------------------------------------------------
--  DDL for Package Body PER_POS_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_POS_SHD" as
/* $Header: peposrhi.pkb 120.0.12010000.1 2008/07/28 05:23:58 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  per_pos_shd.';  -- Global package name
--
-- ----------------------------------------------------------------------------
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
  If (p_constraint_name = 'PER_POSITIONS_FK1') Then
    hr_utility.set_message(801, 'HR_7208_API_BUS_GRP_INVALID');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'PER_POSITIONS_FK2') Then
    hr_utility.set_message(801, 'HR_51090_JOB_NOT_EXIST');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'PER_POSITIONS_FK3') Then
    hr_utility.set_message(801, 'HR_51371_POS_ORG_NOT_EXIST');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'PER_POSITIONS_FK4') Then
    fnd_message.set_name('PER','PER_52979_POS_SUCC_NOT_EXIST');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'PER_POSITIONS_FK5') Then
    fnd_message.set_name('PER','PER_52980_POS_RELF_NOT_EXIST');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'PER_POSITIONS_FK6') Then
    hr_utility.set_message(801, 'HR_51357_POS_LOC_NOT_EXIST');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'PER_POSITIONS_FK7') Then
    hr_utility.set_message(801, 'HR_51369_POS_DEF_NOT_EXIST');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'PER_POSITIONS_PK') Then
    hr_utility.set_message(801, 'HR_7220_INVALID_PRIMARY_KEY');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'PER_POSITIONS_UK2') Then
    hr_utility.set_message(801, 'PER_7415_POS_EXISTS');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'PER_POST_REPLACEMENT_REQUI_CHK') Then
    hr_utility.set_message(801, 'HR_51370_POS_REPL_REQ_FLAG');
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
  p_position_id                        in number,
  p_object_version_number              in number
  )      Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
		position_id,
	business_group_id,
	job_id,
	organization_id,
	successor_position_id,
	relief_position_id,
	location_id,
	position_definition_id,
	date_effective,
	comments,
	date_end,
	frequency,
	name,
	probation_period,
	probation_period_units,
	replacement_required_flag,
	time_normal_finish,
	time_normal_start,
        status,
	working_hours,
	request_id,
	program_application_id,
	program_id,
	program_update_date,
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
	attribute20,
	object_version_number
    from	per_positions
    where	position_id = p_position_id;
--
  l_proc	varchar2(72)	:= g_package||'api_updating';
  l_fct_ret	boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (
	p_position_id is null and
	p_object_version_number is null
     ) or per_pos_shd.G_DT_INS Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (
	p_position_id = g_old_rec.position_id and
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
  p_position_id                        in number,
  p_object_version_number              in number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select 	position_id,
	business_group_id,
	job_id,
	organization_id,
	successor_position_id,
	relief_position_id,
	location_id,
	position_definition_id,
	date_effective,
	comments,
	date_end,
	frequency,
	name,
	probation_period,
	probation_period_units,
	replacement_required_flag,
	time_normal_finish,
	time_normal_start,
        status,
	working_hours,
	request_id,
	program_application_id,
	program_id,
	program_update_date,
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
	attribute20,
	object_version_number
    from	per_all_positions
    where	position_id = p_position_id
      for	update nowait;
--
  l_proc	varchar2(72) := g_package||'lck';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Add any mandatory argument checking here:
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'position_id'
    ,p_argument_value => p_position_id);
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'object_version_number'
    ,p_argument_value => p_object_version_number);
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
    hr_utility.set_message_token('TABLE_NAME', 'per_all_positions');
    hr_utility.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
	(
	p_position_id                   in number,
	p_business_group_id             in number,
	p_job_id                        in number,
	p_organization_id               in number,
	p_successor_position_id         in number,
	p_relief_position_id            in number,
	p_location_id                   in number,
	p_position_definition_id        in number,
	p_date_effective                in date,
	p_comments                      in varchar2,
	p_date_end                      in date,
	p_frequency                     in varchar2,
	p_name                          in varchar2,
	p_probation_period              in number,
	p_probation_period_units        in varchar2,
	p_replacement_required_flag     in varchar2,
	p_time_normal_finish            in varchar2,
	p_time_normal_start             in varchar2,
        p_status                        in varchar2,
	p_working_hours                 in number,
	p_request_id                    in number,
	p_program_application_id        in number,
	p_program_id                    in number,
	p_program_update_date           in date,
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
	p_attribute20                   in varchar2,
	p_object_version_number         in number
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
  l_rec.position_id                      := p_position_id;
  l_rec.business_group_id                := p_business_group_id;
  l_rec.job_id                           := p_job_id;
  l_rec.organization_id                  := p_organization_id;
  l_rec.successor_position_id            := p_successor_position_id;
  l_rec.relief_position_id               := p_relief_position_id;
  l_rec.location_id                      := p_location_id;
  l_rec.position_definition_id           := p_position_definition_id;
  l_rec.date_effective                   := p_date_effective;
  l_rec.comments                         := p_comments;
  l_rec.date_end                         := p_date_end;
  l_rec.frequency                        := p_frequency;
  l_rec.name                             := p_name;
  l_rec.probation_period                 := p_probation_period;
  l_rec.probation_period_units           := p_probation_period_units;
  l_rec.replacement_required_flag        := p_replacement_required_flag;
  l_rec.time_normal_finish               := p_time_normal_finish;
  l_rec.time_normal_start                := p_time_normal_start;
  l_rec.status                           := p_status;
  l_rec.working_hours                    := p_working_hours;
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
  l_rec.object_version_number            := p_object_version_number;
  --
  -- Return the plsql record structure.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  Return(l_rec);
--
End convert_args;
--
end per_pos_shd;

/
