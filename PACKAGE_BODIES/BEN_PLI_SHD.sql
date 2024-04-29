--------------------------------------------------------
--  DDL for Package Body BEN_PLI_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PLI_SHD" as
/* $Header: beplirhi.pkb 115.1 2003/09/24 00:02:28 hmani noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_pli_shd.';  -- Global package name
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
  If (p_constraint_name = 'BEN_PL_EXTRA_INFO_FK1') Then
    hr_utility.set_message(801, 'HR_INV_INFO_TYPE');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'BEN_PL_EXTRA_INFO_FK2') Then
    hr_utility.set_message(801, 'HR_INV_pl_ID');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'BEN_PL_EXTRA_INFO_PK') Then
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
  p_pl_extra_info_id                  in number,

  p_object_version_number              in number
  )      Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
	pl_extra_info_id,
	information_type,
	pl_id,
	request_id,
	program_application_id,
	program_id,
	program_update_date,
	pli_attribute_category,
	pli_attribute1,
	pli_attribute2,
	pli_attribute3,
	pli_attribute4,
	pli_attribute5,
	pli_attribute6,
	pli_attribute7,
	pli_attribute8,
	pli_attribute9,
	pli_attribute10,
	pli_attribute11,
	pli_attribute12,
	pli_attribute13,
	pli_attribute14,
	pli_attribute15,
	pli_attribute16,
	pli_attribute17,
	pli_attribute18,
	pli_attribute19,
	pli_attribute20,
	pli_information_category,
	pli_information1,
	pli_information2,
	pli_information3,
	pli_information4,
	pli_information5,
	pli_information6,
	pli_information7,
	pli_information8,
	pli_information9,
	pli_information10,
	pli_information11,
	pli_information12,
	pli_information13,
	pli_information14,
	pli_information15,
	pli_information16,
	pli_information17,
	pli_information18,
	pli_information19,
	pli_information20,
	pli_information21,
	pli_information22,
	pli_information23,
	pli_information24,
	pli_information25,
	pli_information26,
	pli_information27,
	pli_information28,
	pli_information29,
	pli_information30,
	object_version_number
    from	BEN_pl_extra_info
    where	pl_extra_info_id = p_pl_extra_info_id;
--
  l_proc	varchar2(72)	:= g_package||'api_updating';
  l_fct_ret	boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (
	p_pl_extra_info_id is null and
	p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (
	p_pl_extra_info_id = g_old_rec.pl_extra_info_id and
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
  p_pl_extra_info_id                  in number,
  p_object_version_number              in number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select 	pl_extra_info_id,
	information_type,
	pl_id,
	request_id,
	program_application_id,
	program_id,
	program_update_date,
	pli_attribute_category,
	pli_attribute1,
	pli_attribute2,
	pli_attribute3,
	pli_attribute4,
	pli_attribute5,
	pli_attribute6,
	pli_attribute7,
	pli_attribute8,
	pli_attribute9,
	pli_attribute10,
	pli_attribute11,
	pli_attribute12,
	pli_attribute13,
	pli_attribute14,
	pli_attribute15,
	pli_attribute16,
	pli_attribute17,
	pli_attribute18,
	pli_attribute19,
	pli_attribute20,
	pli_information_category,
	pli_information1,
	pli_information2,
	pli_information3,
	pli_information4,
	pli_information5,
	pli_information6,
	pli_information7,
	pli_information8,
	pli_information9,
	pli_information10,
	pli_information11,
	pli_information12,
	pli_information13,
	pli_information14,
	pli_information15,
	pli_information16,
	pli_information17,
	pli_information18,
	pli_information19,
	pli_information20,
	pli_information21,
	pli_information22,
	pli_information23,
	pli_information24,
	pli_information25,
	pli_information26,
	pli_information27,
	pli_information28,
	pli_information29,
	pli_information30,
	object_version_number
    from	ben_pl_extra_info
    where	pl_extra_info_id = p_pl_extra_info_id
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
    hr_utility.set_message_token('TABLE_NAME', 'BEN_PL_EXTRA_INFO');
    hr_utility.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
	(
	p_pl_extra_info_id             in number,
	p_information_type              in varchar2,
	p_pl_id                        in number,
	p_request_id                    in number,
	p_program_application_id        in number,
	p_program_id                    in number,
	p_program_update_date           in date,
	p_pli_attribute_category        in varchar2,
	p_pli_attribute1                in varchar2,
	p_pli_attribute2                in varchar2,
	p_pli_attribute3                in varchar2,
	p_pli_attribute4                in varchar2,
	p_pli_attribute5                in varchar2,
	p_pli_attribute6                in varchar2,
	p_pli_attribute7                in varchar2,
	p_pli_attribute8                in varchar2,
	p_pli_attribute9                in varchar2,
	p_pli_attribute10               in varchar2,
	p_pli_attribute11               in varchar2,
	p_pli_attribute12               in varchar2,
	p_pli_attribute13               in varchar2,
	p_pli_attribute14               in varchar2,
	p_pli_attribute15               in varchar2,
	p_pli_attribute16               in varchar2,
	p_pli_attribute17               in varchar2,
	p_pli_attribute18               in varchar2,
	p_pli_attribute19               in varchar2,
	p_pli_attribute20               in varchar2,
	p_pli_information_category      in varchar2,
	p_pli_information1              in varchar2,
	p_pli_information2              in varchar2,
	p_pli_information3              in varchar2,
	p_pli_information4              in varchar2,
	p_pli_information5              in varchar2,
	p_pli_information6              in varchar2,
	p_pli_information7              in varchar2,
	p_pli_information8              in varchar2,
	p_pli_information9              in varchar2,
	p_pli_information10             in varchar2,
	p_pli_information11             in varchar2,
	p_pli_information12             in varchar2,
	p_pli_information13             in varchar2,
	p_pli_information14             in varchar2,
	p_pli_information15             in varchar2,
	p_pli_information16             in varchar2,
	p_pli_information17             in varchar2,
	p_pli_information18             in varchar2,
	p_pli_information19             in varchar2,
	p_pli_information20             in varchar2,
	p_pli_information21             in varchar2,
	p_pli_information22             in varchar2,
	p_pli_information23             in varchar2,
	p_pli_information24             in varchar2,
	p_pli_information25             in varchar2,
	p_pli_information26             in varchar2,
	p_pli_information27             in varchar2,
	p_pli_information28             in varchar2,
	p_pli_information29             in varchar2,
	p_pli_information30             in varchar2,
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
  l_rec.pl_extra_info_id                := p_pl_extra_info_id;
  l_rec.information_type                 := p_information_type;
  l_rec.pl_id                           := p_pl_id;
  l_rec.request_id                       := p_request_id;
  l_rec.program_application_id           := p_program_application_id;
  l_rec.program_id                       := p_program_id;
  l_rec.program_update_date              := p_program_update_date;
  l_rec.pli_attribute_category           := p_pli_attribute_category;
  l_rec.pli_attribute1                   := p_pli_attribute1;
  l_rec.pli_attribute2                   := p_pli_attribute2;
  l_rec.pli_attribute3                   := p_pli_attribute3;
  l_rec.pli_attribute4                   := p_pli_attribute4;
  l_rec.pli_attribute5                   := p_pli_attribute5;
  l_rec.pli_attribute6                   := p_pli_attribute6;
  l_rec.pli_attribute7                   := p_pli_attribute7;
  l_rec.pli_attribute8                   := p_pli_attribute8;
  l_rec.pli_attribute9                   := p_pli_attribute9;
  l_rec.pli_attribute10                  := p_pli_attribute10;
  l_rec.pli_attribute11                  := p_pli_attribute11;
  l_rec.pli_attribute12                  := p_pli_attribute12;
  l_rec.pli_attribute13                  := p_pli_attribute13;
  l_rec.pli_attribute14                  := p_pli_attribute14;
  l_rec.pli_attribute15                  := p_pli_attribute15;
  l_rec.pli_attribute16                  := p_pli_attribute16;
  l_rec.pli_attribute17                  := p_pli_attribute17;
  l_rec.pli_attribute18                  := p_pli_attribute18;
  l_rec.pli_attribute19                  := p_pli_attribute19;
  l_rec.pli_attribute20                  := p_pli_attribute20;
  l_rec.pli_information_category         := p_pli_information_category;
  l_rec.pli_information1                 := p_pli_information1;
  l_rec.pli_information2                 := p_pli_information2;
  l_rec.pli_information3                 := p_pli_information3;
  l_rec.pli_information4                 := p_pli_information4;
  l_rec.pli_information5                 := p_pli_information5;
  l_rec.pli_information6                 := p_pli_information6;
  l_rec.pli_information7                 := p_pli_information7;
  l_rec.pli_information8                 := p_pli_information8;
  l_rec.pli_information9                 := p_pli_information9;
  l_rec.pli_information10                := p_pli_information10;
  l_rec.pli_information11                := p_pli_information11;
  l_rec.pli_information12                := p_pli_information12;
  l_rec.pli_information13                := p_pli_information13;
  l_rec.pli_information14                := p_pli_information14;
  l_rec.pli_information15                := p_pli_information15;
  l_rec.pli_information16                := p_pli_information16;
  l_rec.pli_information17                := p_pli_information17;
  l_rec.pli_information18                := p_pli_information18;
  l_rec.pli_information19                := p_pli_information19;
  l_rec.pli_information20                := p_pli_information20;
  l_rec.pli_information21                := p_pli_information21;
  l_rec.pli_information22                := p_pli_information22;
  l_rec.pli_information23                := p_pli_information23;
  l_rec.pli_information24                := p_pli_information24;
  l_rec.pli_information25                := p_pli_information25;
  l_rec.pli_information26                := p_pli_information26;
  l_rec.pli_information27                := p_pli_information27;
  l_rec.pli_information28                := p_pli_information28;
  l_rec.pli_information29                := p_pli_information29;
  l_rec.pli_information30                := p_pli_information30;
  l_rec.object_version_number            := p_object_version_number;
  --
  -- Return the plsql record structure.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  Return(l_rec);
--
End convert_args;
--
end ben_pli_shd;

/
