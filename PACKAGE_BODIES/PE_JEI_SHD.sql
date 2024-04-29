--------------------------------------------------------
--  DDL for Package Body PE_JEI_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PE_JEI_SHD" as
/* $Header: pejeirhi.pkb 115.8 2002/12/06 10:38:05 pkakar ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pe_jei_shd.';  -- Global package name
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
  If (p_constraint_name = 'PER_JOB_EXTRA_INFO_FK1') Then
    hr_utility.set_message(801, 'HR_INV_INFO_TYPE');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'PER_JOB_EXTRA_INFO_FK2') Then
    hr_utility.set_message(801, 'HR_INV_JOB_ID');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'PER_JOB_EXTRA_INFO_PK') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','15');
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
  p_job_extra_info_id                  in number,

  p_object_version_number              in number
  )      Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
	job_extra_info_id,
	information_type,
	job_id,
	request_id,
	program_application_id,
	program_id,
	program_update_date,
	jei_attribute_category,
	jei_attribute1,
	jei_attribute2,
	jei_attribute3,
	jei_attribute4,
	jei_attribute5,
	jei_attribute6,
	jei_attribute7,
	jei_attribute8,
	jei_attribute9,
	jei_attribute10,
	jei_attribute11,
	jei_attribute12,
	jei_attribute13,
	jei_attribute14,
	jei_attribute15,
	jei_attribute16,
	jei_attribute17,
	jei_attribute18,
	jei_attribute19,
	jei_attribute20,
	jei_information_category,
	jei_information1,
	jei_information2,
	jei_information3,
	jei_information4,
	jei_information5,
	jei_information6,
	jei_information7,
	jei_information8,
	jei_information9,
	jei_information10,
	jei_information11,
	jei_information12,
	jei_information13,
	jei_information14,
	jei_information15,
	jei_information16,
	jei_information17,
	jei_information18,
	jei_information19,
	jei_information20,
	jei_information21,
	jei_information22,
	jei_information23,
	jei_information24,
	jei_information25,
	jei_information26,
	jei_information27,
	jei_information28,
	jei_information29,
	jei_information30,
	object_version_number
    from	per_job_extra_info
    where	job_extra_info_id = p_job_extra_info_id;
--
  l_proc	varchar2(72)	:= g_package||'api_updating';
  l_fct_ret	boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (
	p_job_extra_info_id is null and
	p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (
	p_job_extra_info_id = g_old_rec.job_extra_info_id and
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
  p_job_extra_info_id                  in number,
  p_object_version_number              in number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select 	job_extra_info_id,
	information_type,
	job_id,
	request_id,
	program_application_id,
	program_id,
	program_update_date,
	jei_attribute_category,
	jei_attribute1,
	jei_attribute2,
	jei_attribute3,
	jei_attribute4,
	jei_attribute5,
	jei_attribute6,
	jei_attribute7,
	jei_attribute8,
	jei_attribute9,
	jei_attribute10,
	jei_attribute11,
	jei_attribute12,
	jei_attribute13,
	jei_attribute14,
	jei_attribute15,
	jei_attribute16,
	jei_attribute17,
	jei_attribute18,
	jei_attribute19,
	jei_attribute20,
	jei_information_category,
	jei_information1,
	jei_information2,
	jei_information3,
	jei_information4,
	jei_information5,
	jei_information6,
	jei_information7,
	jei_information8,
	jei_information9,
	jei_information10,
	jei_information11,
	jei_information12,
	jei_information13,
	jei_information14,
	jei_information15,
	jei_information16,
	jei_information17,
	jei_information18,
	jei_information19,
	jei_information20,
	jei_information21,
	jei_information22,
	jei_information23,
	jei_information24,
	jei_information25,
	jei_information26,
	jei_information27,
	jei_information28,
	jei_information29,
	jei_information30,
	object_version_number
    from	per_job_extra_info
    where	job_extra_info_id = p_job_extra_info_id
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
    hr_utility.set_message_token('TABLE_NAME', 'per_job_extra_info');
    hr_utility.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
	(
	p_job_extra_info_id             in number,
	p_information_type              in varchar2,
	p_job_id                        in number,
	p_request_id                    in number,
	p_program_application_id        in number,
	p_program_id                    in number,
	p_program_update_date           in date,
	p_jei_attribute_category        in varchar2,
	p_jei_attribute1                in varchar2,
	p_jei_attribute2                in varchar2,
	p_jei_attribute3                in varchar2,
	p_jei_attribute4                in varchar2,
	p_jei_attribute5                in varchar2,
	p_jei_attribute6                in varchar2,
	p_jei_attribute7                in varchar2,
	p_jei_attribute8                in varchar2,
	p_jei_attribute9                in varchar2,
	p_jei_attribute10               in varchar2,
	p_jei_attribute11               in varchar2,
	p_jei_attribute12               in varchar2,
	p_jei_attribute13               in varchar2,
	p_jei_attribute14               in varchar2,
	p_jei_attribute15               in varchar2,
	p_jei_attribute16               in varchar2,
	p_jei_attribute17               in varchar2,
	p_jei_attribute18               in varchar2,
	p_jei_attribute19               in varchar2,
	p_jei_attribute20               in varchar2,
	p_jei_information_category      in varchar2,
	p_jei_information1              in varchar2,
	p_jei_information2              in varchar2,
	p_jei_information3              in varchar2,
	p_jei_information4              in varchar2,
	p_jei_information5              in varchar2,
	p_jei_information6              in varchar2,
	p_jei_information7              in varchar2,
	p_jei_information8              in varchar2,
	p_jei_information9              in varchar2,
	p_jei_information10             in varchar2,
	p_jei_information11             in varchar2,
	p_jei_information12             in varchar2,
	p_jei_information13             in varchar2,
	p_jei_information14             in varchar2,
	p_jei_information15             in varchar2,
	p_jei_information16             in varchar2,
	p_jei_information17             in varchar2,
	p_jei_information18             in varchar2,
	p_jei_information19             in varchar2,
	p_jei_information20             in varchar2,
	p_jei_information21             in varchar2,
	p_jei_information22             in varchar2,
	p_jei_information23             in varchar2,
	p_jei_information24             in varchar2,
	p_jei_information25             in varchar2,
	p_jei_information26             in varchar2,
	p_jei_information27             in varchar2,
	p_jei_information28             in varchar2,
	p_jei_information29             in varchar2,
	p_jei_information30             in varchar2,
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
  l_rec.job_extra_info_id                := p_job_extra_info_id;
  l_rec.information_type                 := p_information_type;
  l_rec.job_id                           := p_job_id;
  l_rec.request_id                       := p_request_id;
  l_rec.program_application_id           := p_program_application_id;
  l_rec.program_id                       := p_program_id;
  l_rec.program_update_date              := p_program_update_date;
  l_rec.jei_attribute_category           := p_jei_attribute_category;
  l_rec.jei_attribute1                   := p_jei_attribute1;
  l_rec.jei_attribute2                   := p_jei_attribute2;
  l_rec.jei_attribute3                   := p_jei_attribute3;
  l_rec.jei_attribute4                   := p_jei_attribute4;
  l_rec.jei_attribute5                   := p_jei_attribute5;
  l_rec.jei_attribute6                   := p_jei_attribute6;
  l_rec.jei_attribute7                   := p_jei_attribute7;
  l_rec.jei_attribute8                   := p_jei_attribute8;
  l_rec.jei_attribute9                   := p_jei_attribute9;
  l_rec.jei_attribute10                  := p_jei_attribute10;
  l_rec.jei_attribute11                  := p_jei_attribute11;
  l_rec.jei_attribute12                  := p_jei_attribute12;
  l_rec.jei_attribute13                  := p_jei_attribute13;
  l_rec.jei_attribute14                  := p_jei_attribute14;
  l_rec.jei_attribute15                  := p_jei_attribute15;
  l_rec.jei_attribute16                  := p_jei_attribute16;
  l_rec.jei_attribute17                  := p_jei_attribute17;
  l_rec.jei_attribute18                  := p_jei_attribute18;
  l_rec.jei_attribute19                  := p_jei_attribute19;
  l_rec.jei_attribute20                  := p_jei_attribute20;
  l_rec.jei_information_category         := p_jei_information_category;
  l_rec.jei_information1                 := p_jei_information1;
  l_rec.jei_information2                 := p_jei_information2;
  l_rec.jei_information3                 := p_jei_information3;
  l_rec.jei_information4                 := p_jei_information4;
  l_rec.jei_information5                 := p_jei_information5;
  l_rec.jei_information6                 := p_jei_information6;
  l_rec.jei_information7                 := p_jei_information7;
  l_rec.jei_information8                 := p_jei_information8;
  l_rec.jei_information9                 := p_jei_information9;
  l_rec.jei_information10                := p_jei_information10;
  l_rec.jei_information11                := p_jei_information11;
  l_rec.jei_information12                := p_jei_information12;
  l_rec.jei_information13                := p_jei_information13;
  l_rec.jei_information14                := p_jei_information14;
  l_rec.jei_information15                := p_jei_information15;
  l_rec.jei_information16                := p_jei_information16;
  l_rec.jei_information17                := p_jei_information17;
  l_rec.jei_information18                := p_jei_information18;
  l_rec.jei_information19                := p_jei_information19;
  l_rec.jei_information20                := p_jei_information20;
  l_rec.jei_information21                := p_jei_information21;
  l_rec.jei_information22                := p_jei_information22;
  l_rec.jei_information23                := p_jei_information23;
  l_rec.jei_information24                := p_jei_information24;
  l_rec.jei_information25                := p_jei_information25;
  l_rec.jei_information26                := p_jei_information26;
  l_rec.jei_information27                := p_jei_information27;
  l_rec.jei_information28                := p_jei_information28;
  l_rec.jei_information29                := p_jei_information29;
  l_rec.jei_information30                := p_jei_information30;
  l_rec.object_version_number            := p_object_version_number;
  --
  -- Return the plsql record structure.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  Return(l_rec);
--
End convert_args;
--
end pe_jei_shd;

/
