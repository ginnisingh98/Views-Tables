--------------------------------------------------------
--  DDL for Package Body BEN_ELI_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_ELI_SHD" as
/* $Header: beelirhi.pkb 115.1 2004/04/14 02:40:36 hmani noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_eli_shd.';  -- Global package name
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
  If (p_constraint_name = 'BEN_ELP_EXTRA_INFO_FK1') Then
    hr_utility.set_message(801, 'HR_INV_INFO_TYPE');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'BEN_ELP_EXTRA_INFO_FK2') Then
    hr_utility.set_message(801, 'HR_INV_ELP_ID');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'BEN_ELP_EXTRA_INFO_PK') Then
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
  p_elp_extra_info_id                  in number,

  p_object_version_number              in number
  )      Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
	elp_extra_info_id,
	information_type,
	eligy_prfl_id,
	request_id,
	program_application_id,
	program_id,
	program_update_date,
	eli_attribute_category,
	eli_attribute1,
	eli_attribute2,
	eli_attribute3,
	eli_attribute4,
	eli_attribute5,
	eli_attribute6,
	eli_attribute7,
	eli_attribute8,
	eli_attribute9,
	eli_attribute10,
	eli_attribute11,
	eli_attribute12,
	eli_attribute13,
	eli_attribute14,
	eli_attribute15,
	eli_attribute16,
	eli_attribute17,
	eli_attribute18,
	eli_attribute19,
	eli_attribute20,
	eli_information_category,
	eli_information1,
	eli_information2,
	eli_information3,
	eli_information4,
	eli_information5,
	eli_information6,
	eli_information7,
	eli_information8,
	eli_information9,
	eli_information10,
	eli_information11,
	eli_information12,
	eli_information13,
	eli_information14,
	eli_information15,
	eli_information16,
	eli_information17,
	eli_information18,
	eli_information19,
	eli_information20,
	eli_information21,
	eli_information22,
	eli_information23,
	eli_information24,
	eli_information25,
	eli_information26,
	eli_information27,
	eli_information28,
	eli_information29,
	eli_information30,
	object_version_number
    from	ben_elp_extra_info
    where	elp_extra_info_id = p_elp_extra_info_id;
--
  l_proc	varchar2(72)	:= g_package||'api_updating';
  l_fct_ret	boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (
	p_elp_extra_info_id is null and
	p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (
	p_elp_extra_info_id = g_old_rec.elp_extra_info_id and
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
  p_elp_extra_info_id                  in number,
  p_object_version_number              in number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select 	elp_extra_info_id,
	information_type,
	eligy_prfl_id,
	request_id,
	program_application_id,
	program_id,
	program_update_date,
	eli_attribute_category,
	eli_attribute1,
	eli_attribute2,
	eli_attribute3,
	eli_attribute4,
	eli_attribute5,
	eli_attribute6,
	eli_attribute7,
	eli_attribute8,
	eli_attribute9,
	eli_attribute10,
	eli_attribute11,
	eli_attribute12,
	eli_attribute13,
	eli_attribute14,
	eli_attribute15,
	eli_attribute16,
	eli_attribute17,
	eli_attribute18,
	eli_attribute19,
	eli_attribute20,
	eli_information_category,
	eli_information1,
	eli_information2,
	eli_information3,
	eli_information4,
	eli_information5,
	eli_information6,
	eli_information7,
	eli_information8,
	eli_information9,
	eli_information10,
	eli_information11,
	eli_information12,
	eli_information13,
	eli_information14,
	eli_information15,
	eli_information16,
	eli_information17,
	eli_information18,
	eli_information19,
	eli_information20,
	eli_information21,
	eli_information22,
	eli_information23,
	eli_information24,
	eli_information25,
	eli_information26,
	eli_information27,
	eli_information28,
	eli_information29,
	eli_information30,
	object_version_number
    from	ben_elp_extra_info
    where	elp_extra_info_id = p_elp_extra_info_id
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
    hr_utility.set_message_token('TABLE_NAME', 'ben_elp_extra_info');
    hr_utility.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
	(
	p_elp_extra_info_id             in number,
	p_information_type              in varchar2,
	p_eligy_prfl_id                        in number,
	p_request_id                    in number,
	p_program_application_id        in number,
	p_program_id                    in number,
	p_program_update_date           in date,
	p_eli_attribute_category        in varchar2,
	p_eli_attribute1                in varchar2,
	p_eli_attribute2                in varchar2,
	p_eli_attribute3                in varchar2,
	p_eli_attribute4                in varchar2,
	p_eli_attribute5                in varchar2,
	p_eli_attribute6                in varchar2,
	p_eli_attribute7                in varchar2,
	p_eli_attribute8                in varchar2,
	p_eli_attribute9                in varchar2,
	p_eli_attribute10               in varchar2,
	p_eli_attribute11               in varchar2,
	p_eli_attribute12               in varchar2,
	p_eli_attribute13               in varchar2,
	p_eli_attribute14               in varchar2,
	p_eli_attribute15               in varchar2,
	p_eli_attribute16               in varchar2,
	p_eli_attribute17               in varchar2,
	p_eli_attribute18               in varchar2,
	p_eli_attribute19               in varchar2,
	p_eli_attribute20               in varchar2,
	p_eli_information_category      in varchar2,
	p_eli_information1              in varchar2,
	p_eli_information2              in varchar2,
	p_eli_information3              in varchar2,
	p_eli_information4              in varchar2,
	p_eli_information5              in varchar2,
	p_eli_information6              in varchar2,
	p_eli_information7              in varchar2,
	p_eli_information8              in varchar2,
	p_eli_information9              in varchar2,
	p_eli_information10             in varchar2,
	p_eli_information11             in varchar2,
	p_eli_information12             in varchar2,
	p_eli_information13             in varchar2,
	p_eli_information14             in varchar2,
	p_eli_information15             in varchar2,
	p_eli_information16             in varchar2,
	p_eli_information17             in varchar2,
	p_eli_information18             in varchar2,
	p_eli_information19             in varchar2,
	p_eli_information20             in varchar2,
	p_eli_information21             in varchar2,
	p_eli_information22             in varchar2,
	p_eli_information23             in varchar2,
	p_eli_information24             in varchar2,
	p_eli_information25             in varchar2,
	p_eli_information26             in varchar2,
	p_eli_information27             in varchar2,
	p_eli_information28             in varchar2,
	p_eli_information29             in varchar2,
	p_eli_information30             in varchar2,
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
  l_rec.elp_extra_info_id                := p_elp_extra_info_id;
  l_rec.information_type                 := p_information_type;
  l_rec.eligy_prfl_id                           := p_eligy_prfl_id;
  l_rec.request_id                       := p_request_id;
  l_rec.program_application_id           := p_program_application_id;
  l_rec.program_id                       := p_program_id;
  l_rec.program_update_date              := p_program_update_date;
  l_rec.eli_attribute_category           := p_eli_attribute_category;
  l_rec.eli_attribute1                   := p_eli_attribute1;
  l_rec.eli_attribute2                   := p_eli_attribute2;
  l_rec.eli_attribute3                   := p_eli_attribute3;
  l_rec.eli_attribute4                   := p_eli_attribute4;
  l_rec.eli_attribute5                   := p_eli_attribute5;
  l_rec.eli_attribute6                   := p_eli_attribute6;
  l_rec.eli_attribute7                   := p_eli_attribute7;
  l_rec.eli_attribute8                   := p_eli_attribute8;
  l_rec.eli_attribute9                   := p_eli_attribute9;
  l_rec.eli_attribute10                  := p_eli_attribute10;
  l_rec.eli_attribute11                  := p_eli_attribute11;
  l_rec.eli_attribute12                  := p_eli_attribute12;
  l_rec.eli_attribute13                  := p_eli_attribute13;
  l_rec.eli_attribute14                  := p_eli_attribute14;
  l_rec.eli_attribute15                  := p_eli_attribute15;
  l_rec.eli_attribute16                  := p_eli_attribute16;
  l_rec.eli_attribute17                  := p_eli_attribute17;
  l_rec.eli_attribute18                  := p_eli_attribute18;
  l_rec.eli_attribute19                  := p_eli_attribute19;
  l_rec.eli_attribute20                  := p_eli_attribute20;
  l_rec.eli_information_category         := p_eli_information_category;
  l_rec.eli_information1                 := p_eli_information1;
  l_rec.eli_information2                 := p_eli_information2;
  l_rec.eli_information3                 := p_eli_information3;
  l_rec.eli_information4                 := p_eli_information4;
  l_rec.eli_information5                 := p_eli_information5;
  l_rec.eli_information6                 := p_eli_information6;
  l_rec.eli_information7                 := p_eli_information7;
  l_rec.eli_information8                 := p_eli_information8;
  l_rec.eli_information9                 := p_eli_information9;
  l_rec.eli_information10                := p_eli_information10;
  l_rec.eli_information11                := p_eli_information11;
  l_rec.eli_information12                := p_eli_information12;
  l_rec.eli_information13                := p_eli_information13;
  l_rec.eli_information14                := p_eli_information14;
  l_rec.eli_information15                := p_eli_information15;
  l_rec.eli_information16                := p_eli_information16;
  l_rec.eli_information17                := p_eli_information17;
  l_rec.eli_information18                := p_eli_information18;
  l_rec.eli_information19                := p_eli_information19;
  l_rec.eli_information20                := p_eli_information20;
  l_rec.eli_information21                := p_eli_information21;
  l_rec.eli_information22                := p_eli_information22;
  l_rec.eli_information23                := p_eli_information23;
  l_rec.eli_information24                := p_eli_information24;
  l_rec.eli_information25                := p_eli_information25;
  l_rec.eli_information26                := p_eli_information26;
  l_rec.eli_information27                := p_eli_information27;
  l_rec.eli_information28                := p_eli_information28;
  l_rec.eli_information29                := p_eli_information29;
  l_rec.eli_information30                := p_eli_information30;
  l_rec.object_version_number            := p_object_version_number;
  --
  -- Return the elpsql record structure.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  Return(l_rec);
--
End convert_args;
--
end ben_eli_shd;

/
