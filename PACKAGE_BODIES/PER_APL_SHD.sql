--------------------------------------------------------
--  DDL for Package Body PER_APL_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_APL_SHD" as
/* $Header: peaplrhi.pkb 120.1 2005/10/25 00:31:11 risgupta noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  per_apl_shd.';  -- Global package name
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
  If (p_constraint_name = 'PER_APPLICATIONS_FK1') Then
    hr_utility.set_message(801, 'HR_51183_APL_BUS_GRP_INVALID');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'PER_APPLICATIONS_PK') Then
    hr_utility.set_message(801, 'HR_51184_APL_PK');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'PER_APPL_SUCCESSFUL_FLAG_CHK') Then
    hr_utility.set_message(801, 'HR_51186_APL_CHK');
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
  p_application_id                     in number,
  p_object_version_number              in number
  )      Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
        application_id,
	business_group_id,
	person_id,
	date_received,
	comments,
	current_employer,
	date_end,
	projected_hire_date,
	successful_flag,
	termination_reason,
	request_id,
	program_application_id,
	program_id,
	program_update_date,
	appl_attribute_category,
	appl_attribute1,
	appl_attribute2,
	appl_attribute3,
	appl_attribute4,
	appl_attribute5,
	appl_attribute6,
	appl_attribute7,
	appl_attribute8,
	appl_attribute9,
	appl_attribute10,
	appl_attribute11,
	appl_attribute12,
	appl_attribute13,
	appl_attribute14,
	appl_attribute15,
	appl_attribute16,
	appl_attribute17,
	appl_attribute18,
	appl_attribute19,
	appl_attribute20,
	object_version_number
    from	per_applications
    where	application_id = p_application_id;
--
  l_proc	varchar2(72)	:= g_package||'api_updating';
  l_fct_ret	boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (
	p_application_id is null and
	p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (
	p_application_id = g_old_rec.application_id and
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
  p_application_id                     in number,
  p_object_version_number              in number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select 	application_id,
	business_group_id,
	person_id,
	date_received,
	comments,
	current_employer,
	date_end,
	projected_hire_date,
	successful_flag,
	termination_reason,
	request_id,
	program_application_id,
	program_id,
	program_update_date,
	appl_attribute_category,
	appl_attribute1,
	appl_attribute2,
	appl_attribute3,
	appl_attribute4,
	appl_attribute5,
	appl_attribute6,
	appl_attribute7,
	appl_attribute8,
	appl_attribute9,
	appl_attribute10,
	appl_attribute11,
	appl_attribute12,
	appl_attribute13,
	appl_attribute14,
	appl_attribute15,
	appl_attribute16,
	appl_attribute17,
	appl_attribute18,
	appl_attribute19,
	appl_attribute20,
	object_version_number
    from	per_applications
    where	application_id = p_application_id
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
    hr_utility.set_message_token('TABLE_NAME', 'per_applications');
    hr_utility.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
	(
	p_application_id                in number,
	p_business_group_id             in number,
	p_person_id                     in number,
	p_date_received                 in date,
	p_comments                      in varchar2,
	p_current_employer              in varchar2,
	p_date_end                      in date,
	p_projected_hire_date           in date,
	p_successful_flag               in varchar2,
	p_termination_reason            in varchar2,
	p_request_id                    in number,
	p_program_application_id        in number,
	p_program_id                    in number,
	p_program_update_date           in date,
	p_appl_attribute_category       in varchar2,
	p_appl_attribute1               in varchar2,
	p_appl_attribute2               in varchar2,
	p_appl_attribute3               in varchar2,
	p_appl_attribute4               in varchar2,
	p_appl_attribute5               in varchar2,
	p_appl_attribute6               in varchar2,
	p_appl_attribute7               in varchar2,
	p_appl_attribute8               in varchar2,
	p_appl_attribute9               in varchar2,
	p_appl_attribute10              in varchar2,
	p_appl_attribute11              in varchar2,
	p_appl_attribute12              in varchar2,
	p_appl_attribute13              in varchar2,
	p_appl_attribute14              in varchar2,
	p_appl_attribute15              in varchar2,
	p_appl_attribute16              in varchar2,
	p_appl_attribute17              in varchar2,
	p_appl_attribute18              in varchar2,
	p_appl_attribute19              in varchar2,
	p_appl_attribute20              in varchar2,
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
  l_rec.application_id                   := p_application_id;
  l_rec.business_group_id                := p_business_group_id;
  l_rec.person_id                        := p_person_id;
  l_rec.date_received                    := p_date_received;
  l_rec.comments                         := p_comments;
  l_rec.current_employer                 := p_current_employer;
  l_rec.date_end                         := p_date_end;
  l_rec.projected_hire_date              := p_projected_hire_date;
  l_rec.successful_flag                  := p_successful_flag;
  l_rec.termination_reason               := p_termination_reason;
  l_rec.request_id                       := p_request_id;
  l_rec.program_application_id           := p_program_application_id;
  l_rec.program_id                       := p_program_id;
  l_rec.program_update_date              := p_program_update_date;
  l_rec.appl_attribute_category          := p_appl_attribute_category;
  l_rec.appl_attribute1                  := p_appl_attribute1;
  l_rec.appl_attribute2                  := p_appl_attribute2;
  l_rec.appl_attribute3                  := p_appl_attribute3;
  l_rec.appl_attribute4                  := p_appl_attribute4;
  l_rec.appl_attribute5                  := p_appl_attribute5;
  l_rec.appl_attribute6                  := p_appl_attribute6;
  l_rec.appl_attribute7                  := p_appl_attribute7;
  l_rec.appl_attribute8                  := p_appl_attribute8;
  l_rec.appl_attribute9                  := p_appl_attribute9;
  l_rec.appl_attribute10                 := p_appl_attribute10;
  l_rec.appl_attribute11                 := p_appl_attribute11;
  l_rec.appl_attribute12                 := p_appl_attribute12;
  l_rec.appl_attribute13                 := p_appl_attribute13;
  l_rec.appl_attribute14                 := p_appl_attribute14;
  l_rec.appl_attribute15                 := p_appl_attribute15;
  l_rec.appl_attribute16                 := p_appl_attribute16;
  l_rec.appl_attribute17                 := p_appl_attribute17;
  l_rec.appl_attribute18                 := p_appl_attribute18;
  l_rec.appl_attribute19                 := p_appl_attribute19;
  l_rec.appl_attribute20                 := p_appl_attribute20;
  l_rec.object_version_number            := p_object_version_number;
  --
  -- Return the plsql record structure.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  Return(l_rec);
--
End convert_args;
--
end per_apl_shd;

/
