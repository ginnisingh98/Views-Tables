--------------------------------------------------------
--  DDL for Package Body PE_PEI_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PE_PEI_SHD" as
/* $Header: pepeirhi.pkb 120.1 2005/07/25 05:01:42 jpthomas noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pe_pei_shd.';  -- Global package name
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
  If (p_constraint_name = 'PER_PEOPLE_EXTRA_INFO_FK1') Then
    hr_utility.set_message(800, 'HR_INV_INFO_TYPE');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'PER_PEOPLE_EXTRA_INFO_PK') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','10');
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
  p_person_extra_info_id               in number,
  p_object_version_number              in number
  )      Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
	person_extra_info_id,
	person_id,
	information_type,
	request_id,
	program_application_id,
	program_id,
	program_update_date,
	pei_attribute_category,
	pei_attribute1,
	pei_attribute2,
	pei_attribute3,
	pei_attribute4,
	pei_attribute5,
	pei_attribute6,
	pei_attribute7,
	pei_attribute8,
	pei_attribute9,
	pei_attribute10,
	pei_attribute11,
	pei_attribute12,
	pei_attribute13,
	pei_attribute14,
	pei_attribute15,
	pei_attribute16,
	pei_attribute17,
	pei_attribute18,
	pei_attribute19,
	pei_attribute20,
	pei_information_category,
	pei_information1,
	pei_information2,
	pei_information3,
	pei_information4,
	pei_information5,
	pei_information6,
	pei_information7,
	pei_information8,
	pei_information9,
	pei_information10,
	pei_information11,
	pei_information12,
	pei_information13,
	pei_information14,
	pei_information15,
	pei_information16,
	pei_information17,
	pei_information18,
	pei_information19,
	pei_information20,
	pei_information21,
	pei_information22,
	pei_information23,
	pei_information24,
	pei_information25,
	pei_information26,
	pei_information27,
	pei_information28,
	pei_information29,
	pei_information30,
	object_version_number
    from	per_people_extra_info
    where	person_extra_info_id = p_person_extra_info_id;
--
  l_proc	varchar2(72)	:= g_package||'api_updating';
  l_fct_ret	boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (
	p_person_extra_info_id is null and
	p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (
	p_person_extra_info_id = g_old_rec.person_extra_info_id and
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
  p_person_extra_info_id               in number,
  p_object_version_number              in number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select 	person_extra_info_id,
	person_id,
	information_type,
	request_id,
	program_application_id,
	program_id,
	program_update_date,
	pei_attribute_category,
	pei_attribute1,
	pei_attribute2,
	pei_attribute3,
	pei_attribute4,
	pei_attribute5,
	pei_attribute6,
	pei_attribute7,
	pei_attribute8,
	pei_attribute9,
	pei_attribute10,
	pei_attribute11,
	pei_attribute12,
	pei_attribute13,
	pei_attribute14,
	pei_attribute15,
	pei_attribute16,
	pei_attribute17,
	pei_attribute18,
	pei_attribute19,
	pei_attribute20,
	pei_information_category,
	pei_information1,
	pei_information2,
	pei_information3,
	pei_information4,
	pei_information5,
	pei_information6,
	pei_information7,
	pei_information8,
	pei_information9,
	pei_information10,
	pei_information11,
	pei_information12,
	pei_information13,
	pei_information14,
	pei_information15,
	pei_information16,
	pei_information17,
	pei_information18,
	pei_information19,
	pei_information20,
	pei_information21,
	pei_information22,
	pei_information23,
	pei_information24,
	pei_information25,
	pei_information26,
	pei_information27,
	pei_information28,
	pei_information29,
	pei_information30,
	object_version_number
    from	per_people_extra_info
    where	person_extra_info_id = p_person_extra_info_id
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
    hr_utility.set_message_token('TABLE_NAME', 'per_people_extra_info');
    hr_utility.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
	(
	p_person_extra_info_id          in number,
	p_person_id                     in number,
	p_information_type              in varchar2,
	p_request_id                    in number,
	p_program_application_id        in number,
	p_program_id                    in number,
	p_program_update_date           in date,
	p_pei_attribute_category        in varchar2,
	p_pei_attribute1                in varchar2,
	p_pei_attribute2                in varchar2,
	p_pei_attribute3                in varchar2,
	p_pei_attribute4                in varchar2,
	p_pei_attribute5                in varchar2,
	p_pei_attribute6                in varchar2,
	p_pei_attribute7                in varchar2,
	p_pei_attribute8                in varchar2,
	p_pei_attribute9                in varchar2,
	p_pei_attribute10               in varchar2,
	p_pei_attribute11               in varchar2,
	p_pei_attribute12               in varchar2,
	p_pei_attribute13               in varchar2,
	p_pei_attribute14               in varchar2,
	p_pei_attribute15               in varchar2,
	p_pei_attribute16               in varchar2,
	p_pei_attribute17               in varchar2,
	p_pei_attribute18               in varchar2,
	p_pei_attribute19               in varchar2,
	p_pei_attribute20               in varchar2,
	p_pei_information_category      in varchar2,
	p_pei_information1              in varchar2,
	p_pei_information2              in varchar2,
	p_pei_information3              in varchar2,
	p_pei_information4              in varchar2,
	p_pei_information5              in varchar2,
	p_pei_information6              in varchar2,
	p_pei_information7              in varchar2,
	p_pei_information8              in varchar2,
	p_pei_information9              in varchar2,
	p_pei_information10             in varchar2,
	p_pei_information11             in varchar2,
	p_pei_information12             in varchar2,
	p_pei_information13             in varchar2,
	p_pei_information14             in varchar2,
	p_pei_information15             in varchar2,
	p_pei_information16             in varchar2,
	p_pei_information17             in varchar2,
	p_pei_information18             in varchar2,
	p_pei_information19             in varchar2,
	p_pei_information20             in varchar2,
	p_pei_information21             in varchar2,
	p_pei_information22             in varchar2,
	p_pei_information23             in varchar2,
	p_pei_information24             in varchar2,
	p_pei_information25             in varchar2,
	p_pei_information26             in varchar2,
	p_pei_information27             in varchar2,
	p_pei_information28             in varchar2,
	p_pei_information29             in varchar2,
	p_pei_information30             in varchar2,
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
  l_rec.person_extra_info_id             := p_person_extra_info_id;
  l_rec.person_id                        := p_person_id;
  l_rec.information_type                 := p_information_type;
  l_rec.request_id                       := p_request_id;
  l_rec.program_application_id           := p_program_application_id;
  l_rec.program_id                       := p_program_id;
  l_rec.program_update_date              := p_program_update_date;
  l_rec.pei_attribute_category           := p_pei_attribute_category;
  l_rec.pei_attribute1                   := p_pei_attribute1;
  l_rec.pei_attribute2                   := p_pei_attribute2;
  l_rec.pei_attribute3                   := p_pei_attribute3;
  l_rec.pei_attribute4                   := p_pei_attribute4;
  l_rec.pei_attribute5                   := p_pei_attribute5;
  l_rec.pei_attribute6                   := p_pei_attribute6;
  l_rec.pei_attribute7                   := p_pei_attribute7;
  l_rec.pei_attribute8                   := p_pei_attribute8;
  l_rec.pei_attribute9                   := p_pei_attribute9;
  l_rec.pei_attribute10                  := p_pei_attribute10;
  l_rec.pei_attribute11                  := p_pei_attribute11;
  l_rec.pei_attribute12                  := p_pei_attribute12;
  l_rec.pei_attribute13                  := p_pei_attribute13;
  l_rec.pei_attribute14                  := p_pei_attribute14;
  l_rec.pei_attribute15                  := p_pei_attribute15;
  l_rec.pei_attribute16                  := p_pei_attribute16;
  l_rec.pei_attribute17                  := p_pei_attribute17;
  l_rec.pei_attribute18                  := p_pei_attribute18;
  l_rec.pei_attribute19                  := p_pei_attribute19;
  l_rec.pei_attribute20                  := p_pei_attribute20;
  l_rec.pei_information_category         := p_pei_information_category;
  l_rec.pei_information1                 := p_pei_information1;
  l_rec.pei_information2                 := p_pei_information2;
  l_rec.pei_information3                 := p_pei_information3;
  l_rec.pei_information4                 := p_pei_information4;
  l_rec.pei_information5                 := p_pei_information5;
  l_rec.pei_information6                 := p_pei_information6;
  l_rec.pei_information7                 := p_pei_information7;
  l_rec.pei_information8                 := p_pei_information8;
  l_rec.pei_information9                 := p_pei_information9;
  l_rec.pei_information10                := p_pei_information10;
  l_rec.pei_information11                := p_pei_information11;
  l_rec.pei_information12                := p_pei_information12;
  l_rec.pei_information13                := p_pei_information13;
  l_rec.pei_information14                := p_pei_information14;
  l_rec.pei_information15                := p_pei_information15;
  l_rec.pei_information16                := p_pei_information16;
  l_rec.pei_information17                := p_pei_information17;
  l_rec.pei_information18                := p_pei_information18;
  l_rec.pei_information19                := p_pei_information19;
  l_rec.pei_information20                := p_pei_information20;
  l_rec.pei_information21                := p_pei_information21;
  l_rec.pei_information22                := p_pei_information22;
  l_rec.pei_information23                := p_pei_information23;
  l_rec.pei_information24                := p_pei_information24;
  l_rec.pei_information25                := p_pei_information25;
  l_rec.pei_information26                := p_pei_information26;
  l_rec.pei_information27                := p_pei_information27;
  l_rec.pei_information28                := p_pei_information28;
  l_rec.pei_information29                := p_pei_information29;
  l_rec.pei_information30                := p_pei_information30;
  l_rec.object_version_number            := p_object_version_number;
  --
  -- Return the plsql record structure.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  Return(l_rec);
--
End convert_args;
--
end pe_pei_shd;

/
