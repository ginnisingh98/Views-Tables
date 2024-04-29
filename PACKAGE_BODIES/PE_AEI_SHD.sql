--------------------------------------------------------
--  DDL for Package Body PE_AEI_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PE_AEI_SHD" as
/* $Header: peaeirhi.pkb 115.8 2002/12/03 15:36:45 raranjan ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pe_aei_shd.';  -- Global package name
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
  If (p_constraint_name = 'PER_ASSIGNMENT_EXTRA_INFO_FK1') Then
    hr_utility.set_message(800, 'HR_INV_INFO_TYPE 1');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'PER_ASSIGNMENT_EXTRA_INFO_FK2') Then
    hr_utility.set_message(800, 'HR_INV_ASG_ID');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'PER_ASSIGNMENT_EXTRA_INFO_PK') Then
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
  p_assignment_extra_info_id           in number,
  p_object_version_number              in number
  )      Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
        assignment_extra_info_id,
	assignment_id,
	information_type,
	request_id,
	program_application_id,
	program_id,
	program_update_date,
	aei_attribute_category,
	aei_attribute1,
	aei_attribute2,
	aei_attribute3,
	aei_attribute4,
	aei_attribute5,
	aei_attribute6,
	aei_attribute7,
	aei_attribute8,
	aei_attribute9,
	aei_attribute10,
	aei_attribute11,
	aei_attribute12,
	aei_attribute13,
	aei_attribute14,
	aei_attribute15,
	aei_attribute16,
	aei_attribute17,
	aei_attribute18,
	aei_attribute19,
	aei_attribute20,
	aei_information_category,
	aei_information1,
	aei_information2,
	aei_information3,
	aei_information4,
	aei_information5,
	aei_information6,
	aei_information7,
	aei_information8,
	aei_information9,
	aei_information10,
	aei_information11,
	aei_information12,
	aei_information13,
	aei_information14,
	aei_information15,
	aei_information16,
	aei_information17,
	aei_information18,
	aei_information19,
	aei_information20,
	aei_information21,
	aei_information22,
	aei_information23,
	aei_information24,
	aei_information25,
	aei_information26,
	aei_information27,
	aei_information28,
	aei_information29,
	aei_information30,
	object_version_number
    from	per_assignment_extra_info
    where	assignment_extra_info_id = p_assignment_extra_info_id;
--
  l_proc	varchar2(72)	:= g_package||'api_updating';
  l_fct_ret	boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (
	p_assignment_extra_info_id is null and
	p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (
	p_assignment_extra_info_id = g_old_rec.assignment_extra_info_id and
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
  p_assignment_extra_info_id           in number,
  p_object_version_number              in number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select
 	assignment_extra_info_id,
	assignment_id,
	information_type,
	request_id,
	program_application_id,
	program_id,
	program_update_date,
	aei_attribute_category,
	aei_attribute1,
	aei_attribute2,
	aei_attribute3,
	aei_attribute4,
	aei_attribute5,
	aei_attribute6,
	aei_attribute7,
	aei_attribute8,
	aei_attribute9,
	aei_attribute10,
	aei_attribute11,
	aei_attribute12,
	aei_attribute13,
	aei_attribute14,
	aei_attribute15,
	aei_attribute16,
	aei_attribute17,
	aei_attribute18,
	aei_attribute19,
	aei_attribute20,
	aei_information_category,
	aei_information1,
	aei_information2,
	aei_information3,
	aei_information4,
	aei_information5,
	aei_information6,
	aei_information7,
	aei_information8,
	aei_information9,
	aei_information10,
	aei_information11,
	aei_information12,
	aei_information13,
	aei_information14,
	aei_information15,
	aei_information16,
	aei_information17,
	aei_information18,
	aei_information19,
	aei_information20,
	aei_information21,
	aei_information22,
	aei_information23,
	aei_information24,
	aei_information25,
	aei_information26,
	aei_information27,
	aei_information28,
	aei_information29,
	aei_information30,
	object_version_number
    from	per_assignment_extra_info
    where	assignment_extra_info_id = p_assignment_extra_info_id
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
    hr_utility.set_message_token('TABLE_NAME', 'per_assignment_extra_info');
    hr_utility.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
	(
	p_assignment_extra_info_id      in number,
	p_assignment_id                 in number,
	p_information_type              in varchar2,
	p_request_id                    in number,
	p_program_application_id        in number,
	p_program_id                    in number,
	p_program_update_date           in date,
	p_aei_attribute_category        in varchar2,
	p_aei_attribute1                in varchar2,
	p_aei_attribute2                in varchar2,
	p_aei_attribute3                in varchar2,
	p_aei_attribute4                in varchar2,
	p_aei_attribute5                in varchar2,
	p_aei_attribute6                in varchar2,
	p_aei_attribute7                in varchar2,
	p_aei_attribute8                in varchar2,
	p_aei_attribute9                in varchar2,
	p_aei_attribute10               in varchar2,
	p_aei_attribute11               in varchar2,
	p_aei_attribute12               in varchar2,
	p_aei_attribute13               in varchar2,
	p_aei_attribute14               in varchar2,
	p_aei_attribute15               in varchar2,
	p_aei_attribute16               in varchar2,
	p_aei_attribute17               in varchar2,
	p_aei_attribute18               in varchar2,
	p_aei_attribute19               in varchar2,
	p_aei_attribute20               in varchar2,
	p_aei_information_category      in varchar2,
	p_aei_information1              in varchar2,
	p_aei_information2              in varchar2,
	p_aei_information3              in varchar2,
	p_aei_information4              in varchar2,
	p_aei_information5              in varchar2,
	p_aei_information6              in varchar2,
	p_aei_information7              in varchar2,
	p_aei_information8              in varchar2,
	p_aei_information9              in varchar2,
	p_aei_information10             in varchar2,
	p_aei_information11             in varchar2,
	p_aei_information12             in varchar2,
	p_aei_information13             in varchar2,
	p_aei_information14             in varchar2,
	p_aei_information15             in varchar2,
	p_aei_information16             in varchar2,
	p_aei_information17             in varchar2,
	p_aei_information18             in varchar2,
	p_aei_information19             in varchar2,
	p_aei_information20             in varchar2,
	p_aei_information21             in varchar2,
	p_aei_information22             in varchar2,
	p_aei_information23             in varchar2,
	p_aei_information24             in varchar2,
	p_aei_information25             in varchar2,
	p_aei_information26             in varchar2,
	p_aei_information27             in varchar2,
	p_aei_information28             in varchar2,
	p_aei_information29             in varchar2,
	p_aei_information30             in varchar2,
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
  l_rec.assignment_extra_info_id         := p_assignment_extra_info_id;
  l_rec.assignment_id                    := p_assignment_id;
  l_rec.information_type                 := p_information_type;
  l_rec.request_id                       := p_request_id;
  l_rec.program_application_id           := p_program_application_id;
  l_rec.program_id                       := p_program_id;
  l_rec.program_update_date              := p_program_update_date;
  l_rec.aei_attribute_category           := p_aei_attribute_category;
  l_rec.aei_attribute1                   := p_aei_attribute1;
  l_rec.aei_attribute2                   := p_aei_attribute2;
  l_rec.aei_attribute3                   := p_aei_attribute3;
  l_rec.aei_attribute4                   := p_aei_attribute4;
  l_rec.aei_attribute5                   := p_aei_attribute5;
  l_rec.aei_attribute6                   := p_aei_attribute6;
  l_rec.aei_attribute7                   := p_aei_attribute7;
  l_rec.aei_attribute8                   := p_aei_attribute8;
  l_rec.aei_attribute9                   := p_aei_attribute9;
  l_rec.aei_attribute10                  := p_aei_attribute10;
  l_rec.aei_attribute11                  := p_aei_attribute11;
  l_rec.aei_attribute12                  := p_aei_attribute12;
  l_rec.aei_attribute13                  := p_aei_attribute13;
  l_rec.aei_attribute14                  := p_aei_attribute14;
  l_rec.aei_attribute15                  := p_aei_attribute15;
  l_rec.aei_attribute16                  := p_aei_attribute16;
  l_rec.aei_attribute17                  := p_aei_attribute17;
  l_rec.aei_attribute18                  := p_aei_attribute18;
  l_rec.aei_attribute19                  := p_aei_attribute19;
  l_rec.aei_attribute20                  := p_aei_attribute20;
  l_rec.aei_information_category         := p_aei_information_category;
  l_rec.aei_information1                 := p_aei_information1;
  l_rec.aei_information2                 := p_aei_information2;
  l_rec.aei_information3                 := p_aei_information3;
  l_rec.aei_information4                 := p_aei_information4;
  l_rec.aei_information5                 := p_aei_information5;
  l_rec.aei_information6                 := p_aei_information6;
  l_rec.aei_information7                 := p_aei_information7;
  l_rec.aei_information8                 := p_aei_information8;
  l_rec.aei_information9                 := p_aei_information9;
  l_rec.aei_information10                := p_aei_information10;
  l_rec.aei_information11                := p_aei_information11;
  l_rec.aei_information12                := p_aei_information12;
  l_rec.aei_information13                := p_aei_information13;
  l_rec.aei_information14                := p_aei_information14;
  l_rec.aei_information15                := p_aei_information15;
  l_rec.aei_information16                := p_aei_information16;
  l_rec.aei_information17                := p_aei_information17;
  l_rec.aei_information18                := p_aei_information18;
  l_rec.aei_information19                := p_aei_information19;
  l_rec.aei_information20                := p_aei_information20;
  l_rec.aei_information21                := p_aei_information21;
  l_rec.aei_information22                := p_aei_information22;
  l_rec.aei_information23                := p_aei_information23;
  l_rec.aei_information24                := p_aei_information24;
  l_rec.aei_information25                := p_aei_information25;
  l_rec.aei_information26                := p_aei_information26;
  l_rec.aei_information27                := p_aei_information27;
  l_rec.aei_information28                := p_aei_information28;
  l_rec.aei_information29                := p_aei_information29;
  l_rec.aei_information30                := p_aei_information30;
  l_rec.object_version_number            := p_object_version_number;
  --
  -- Return the plsql record structure.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  Return(l_rec);
--
End convert_args;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< set_called_from_form >------------------------|
-- ----------------------------------------------------------------------------
procedure set_called_from_form
   ( p_flag     in boolean ) as
begin
   g_called_from_form:=p_flag;
end;
--
end pe_aei_shd;

/
