--------------------------------------------------------
--  DDL for Package Body HR_LEI_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_LEI_SHD" as
/* $Header: hrleirhi.pkb 120.1.12010000.2 2009/01/28 09:08:21 ghshanka ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  hr_lei_shd.';  -- Global package name
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
  If (p_constraint_name = 'HR_LOCATION_EXTRA_INFO_FK1') Then
    hr_utility.set_message(800, 'HR_INV_INFO_TYPE');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'HR_LOCATION_EXTRA_INFO_FK2') Then
    hr_utility.set_message(800, 'HR_INV_LOCATION_ID');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'HR_LOCATION_EXTRA_INFO_PK') Then
    hr_utility.set_message(800, 'HR_ALL_PROCEDURE_FAIL');
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
  p_location_extra_info_id             in number,
  p_object_version_number              in number
  )      Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
	location_extra_info_id,
	information_type,
	location_id,
	request_id,
	program_application_id,
	program_id,
	program_update_date,
	lei_attribute_category,
	lei_attribute1,
	lei_attribute2,
	lei_attribute3,
	lei_attribute4,
	lei_attribute5,
	lei_attribute6,
	lei_attribute7,
	lei_attribute8,
	lei_attribute9,
	lei_attribute10,
	lei_attribute11,
	lei_attribute12,
	lei_attribute13,
	lei_attribute14,
	lei_attribute15,
	lei_attribute16,
	lei_attribute17,
	lei_attribute18,
	lei_attribute19,
	lei_attribute20,
	lei_information_category,
	lei_information1,
	lei_information2,
	lei_information3,
	lei_information4,
	lei_information5,
	lei_information6,
	lei_information7,
	lei_information8,
	lei_information9,
	lei_information10,
	lei_information11,
	lei_information12,
	lei_information13,
	lei_information14,
	lei_information15,
	lei_information16,
	lei_information17,
	lei_information18,
	lei_information19,
	lei_information20,
	lei_information21,
	lei_information22,
	lei_information23,
	lei_information24,
	lei_information25,
	lei_information26,
	lei_information27,
	lei_information28,
	lei_information29,
	lei_information30,
	object_version_number
    from	hr_location_extra_info
    where	location_extra_info_id = p_location_extra_info_id;
--
  l_proc	varchar2(72)	:= g_package||'api_updating';
  l_fct_ret	boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (
	p_location_extra_info_id is null and
	p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (
	p_location_extra_info_id = g_old_rec.location_extra_info_id and
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
  p_location_extra_info_id             in number,
  p_object_version_number              in number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select
	location_extra_info_id,
	information_type,
	location_id,
	request_id,
	program_application_id,
	program_id,
	program_update_date,
	lei_attribute_category,
	lei_attribute1,
	lei_attribute2,
	lei_attribute3,
	lei_attribute4,
	lei_attribute5,
	lei_attribute6,
	lei_attribute7,
	lei_attribute8,
	lei_attribute9,
	lei_attribute10,
	lei_attribute11,
	lei_attribute12,
	lei_attribute13,
	lei_attribute14,
	lei_attribute15,
	lei_attribute16,
	lei_attribute17,
	lei_attribute18,
	lei_attribute19,
	lei_attribute20,
	lei_information_category,
	lei_information1,
	lei_information2,
	lei_information3,
	lei_information4,
	lei_information5,
	lei_information6,
	lei_information7,
	lei_information8,
	lei_information9,
	lei_information10,
	lei_information11,
	lei_information12,
	lei_information13,
	lei_information14,
	lei_information15,
	lei_information16,
	lei_information17,
	lei_information18,
	lei_information19,
	lei_information20,
	lei_information21,
	lei_information22,
	lei_information23,
	lei_information24,
	lei_information25,
	lei_information26,
	lei_information27,
	lei_information28,
	lei_information29,
	lei_information30,
	object_version_number
    from	hr_location_extra_info
    where	location_extra_info_id = p_location_extra_info_id
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
    hr_utility.set_message_token('TABLE_NAME', 'hr_location_extra_info');
    hr_utility.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
	(
	p_location_extra_info_id        in number,
	p_information_type              in varchar2,
	p_location_id                   in number,
	p_request_id                    in number,
	p_program_application_id        in number,
	p_program_id                    in number,
	p_program_update_date           in date,
	p_lei_attribute_category        in varchar2,
	p_lei_attribute1                in varchar2,
	p_lei_attribute2                in varchar2,
	p_lei_attribute3                in varchar2,
	p_lei_attribute4                in varchar2,
	p_lei_attribute5                in varchar2,
	p_lei_attribute6                in varchar2,
	p_lei_attribute7                in varchar2,
	p_lei_attribute8                in varchar2,
	p_lei_attribute9                in varchar2,
	p_lei_attribute10               in varchar2,
	p_lei_attribute11               in varchar2,
	p_lei_attribute12               in varchar2,
	p_lei_attribute13               in varchar2,
	p_lei_attribute14               in varchar2,
	p_lei_attribute15               in varchar2,
	p_lei_attribute16               in varchar2,
	p_lei_attribute17               in varchar2,
	p_lei_attribute18               in varchar2,
	p_lei_attribute19               in varchar2,
	p_lei_attribute20               in varchar2,
	p_lei_information_category      in varchar2,
	p_lei_information1              in varchar2,
	p_lei_information2              in varchar2,
	p_lei_information3              in varchar2,
	p_lei_information4              in varchar2,
	p_lei_information5              in varchar2,
	p_lei_information6              in varchar2,
	p_lei_information7              in varchar2,
	p_lei_information8              in varchar2,
	p_lei_information9              in varchar2,
	p_lei_information10             in varchar2,
	p_lei_information11             in varchar2,
	p_lei_information12             in varchar2,
	p_lei_information13             in varchar2,
	p_lei_information14             in varchar2,
	p_lei_information15             in varchar2,
	p_lei_information16             in varchar2,
	p_lei_information17             in varchar2,
	p_lei_information18             in varchar2,
	p_lei_information19             in varchar2,
	p_lei_information20             in varchar2,
	p_lei_information21             in varchar2,
	p_lei_information22             in varchar2,
	p_lei_information23             in varchar2,
	p_lei_information24             in varchar2,
	p_lei_information25             in varchar2,
	p_lei_information26             in varchar2,
	p_lei_information27             in varchar2,
	p_lei_information28             in varchar2,
	p_lei_information29             in varchar2,
	p_lei_information30             in varchar2,
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
  l_rec.location_extra_info_id           := p_location_extra_info_id;
  l_rec.information_type                 := p_information_type;
  l_rec.location_id                      := p_location_id;
  l_rec.request_id                       := p_request_id;
  l_rec.program_application_id           := p_program_application_id;
  l_rec.program_id                       := p_program_id;
  l_rec.program_update_date              := p_program_update_date;
  l_rec.lei_attribute_category           := p_lei_attribute_category;
  l_rec.lei_attribute1                   := p_lei_attribute1;
  l_rec.lei_attribute2                   := p_lei_attribute2;
  l_rec.lei_attribute3                   := p_lei_attribute3;
  l_rec.lei_attribute4                   := p_lei_attribute4;
  l_rec.lei_attribute5                   := p_lei_attribute5;
  l_rec.lei_attribute6                   := p_lei_attribute6;
  l_rec.lei_attribute7                   := p_lei_attribute7;
  l_rec.lei_attribute8                   := p_lei_attribute8;
  l_rec.lei_attribute9                   := p_lei_attribute9;
  l_rec.lei_attribute10                  := p_lei_attribute10;
  l_rec.lei_attribute11                  := p_lei_attribute11;
  l_rec.lei_attribute12                  := p_lei_attribute12;
  l_rec.lei_attribute13                  := p_lei_attribute13;
  l_rec.lei_attribute14                  := p_lei_attribute14;
  l_rec.lei_attribute15                  := p_lei_attribute15;
  l_rec.lei_attribute16                  := p_lei_attribute16;
  l_rec.lei_attribute17                  := p_lei_attribute17;
  l_rec.lei_attribute18                  := p_lei_attribute18;
  l_rec.lei_attribute19                  := p_lei_attribute19;
  l_rec.lei_attribute20                  := p_lei_attribute20;
  l_rec.lei_information_category         := p_lei_information_category;
  l_rec.lei_information1                 := p_lei_information1;
  l_rec.lei_information2                 := p_lei_information2;
  l_rec.lei_information3                 := p_lei_information3;
  l_rec.lei_information4                 := p_lei_information4;
  l_rec.lei_information5                 := p_lei_information5;
  l_rec.lei_information6                 := p_lei_information6;
  l_rec.lei_information7                 := p_lei_information7;
  l_rec.lei_information8                 := p_lei_information8;
  l_rec.lei_information9                 := p_lei_information9;
  l_rec.lei_information10                := p_lei_information10;
  l_rec.lei_information11                := p_lei_information11;
  l_rec.lei_information12                := p_lei_information12;
  l_rec.lei_information13                := p_lei_information13;
  l_rec.lei_information14                := p_lei_information14;
  l_rec.lei_information15                := p_lei_information15;
  l_rec.lei_information16                := p_lei_information16;
  l_rec.lei_information17                := p_lei_information17;
  l_rec.lei_information18                := p_lei_information18;
  l_rec.lei_information19                := p_lei_information19;
  l_rec.lei_information20                := p_lei_information20;
  l_rec.lei_information21                := p_lei_information21;
  l_rec.lei_information22                := p_lei_information22;
  l_rec.lei_information23                := p_lei_information23;
  l_rec.lei_information24                := p_lei_information24;
  l_rec.lei_information25                := p_lei_information25;
  l_rec.lei_information26                := p_lei_information26;
  l_rec.lei_information27                := p_lei_information27;
  l_rec.lei_information28                := p_lei_information28;
  l_rec.lei_information29                := p_lei_information29;
  l_rec.lei_information30                := p_lei_information30;
  l_rec.object_version_number            := p_object_version_number;
  --
  -- Return the plsql record structure.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  Return(l_rec);
--
End convert_args;
--
end hr_lei_shd;

/
