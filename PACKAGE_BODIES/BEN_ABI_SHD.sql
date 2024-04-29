--------------------------------------------------------
--  DDL for Package Body BEN_ABI_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_ABI_SHD" as
/* $Header: beabirhi.pkb 115.0 2003/09/23 10:13:59 hmani noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_abi_shd.';  -- Global package name
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
  If (p_constraint_name = 'BEN_ABR_EXTRA_INFO_FK1') Then
    hr_utility.set_message(801, 'HR_INV_INFO_TYPE');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'BEN_ABR_EXTRA_INFO_FK2') Then
    hr_utility.set_message(801, 'HR_INV_pl_ID');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'BEN_ABR_EXTRA_INFO_PK') Then
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
  p_abr_extra_info_id                  in number,

  p_object_version_number              in number
  )      Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
	abr_extra_info_id,
	information_type,
	acty_base_rt_id,
	request_id,
	program_application_id,
	program_id,
	program_update_date,
	abi_attribute_category,
	abi_attribute1,
	abi_attribute2,
	abi_attribute3,
	abi_attribute4,
	abi_attribute5,
	abi_attribute6,
	abi_attribute7,
	abi_attribute8,
	abi_attribute9,
	abi_attribute10,
	abi_attribute11,
	abi_attribute12,
	abi_attribute13,
	abi_attribute14,
	abi_attribute15,
	abi_attribute16,
	abi_attribute17,
	abi_attribute18,
	abi_attribute19,
	abi_attribute20,
	abi_information_category,
	abi_information1,
	abi_information2,
	abi_information3,
	abi_information4,
	abi_information5,
	abi_information6,
	abi_information7,
	abi_information8,
	abi_information9,
	abi_information10,
	abi_information11,
	abi_information12,
	abi_information13,
	abi_information14,
	abi_information15,
	abi_information16,
	abi_information17,
	abi_information18,
	abi_information19,
	abi_information20,
	abi_information21,
	abi_information22,
	abi_information23,
	abi_information24,
	abi_information25,
	abi_information26,
	abi_information27,
	abi_information28,
	abi_information29,
	abi_information30,
	object_version_number
    from	BEN_abr_extra_info
    where	abr_extra_info_id = p_abr_extra_info_id;
--
  l_proc	varchar2(72)	:= g_package||'api_updating';
  l_fct_ret	boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (
	p_abr_extra_info_id is null and
	p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (
	p_abr_extra_info_id = g_old_rec.abr_extra_info_id and
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
  p_abr_extra_info_id                  in number,
  p_object_version_number              in number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select 	abr_extra_info_id,
	information_type,
	acty_base_rt_id,
	request_id,
	program_application_id,
	program_id,
	program_update_date,
	abi_attribute_category,
	abi_attribute1,
	abi_attribute2,
	abi_attribute3,
	abi_attribute4,
	abi_attribute5,
	abi_attribute6,
	abi_attribute7,
	abi_attribute8,
	abi_attribute9,
	abi_attribute10,
	abi_attribute11,
	abi_attribute12,
	abi_attribute13,
	abi_attribute14,
	abi_attribute15,
	abi_attribute16,
	abi_attribute17,
	abi_attribute18,
	abi_attribute19,
	abi_attribute20,
	abi_information_category,
	abi_information1,
	abi_information2,
	abi_information3,
	abi_information4,
	abi_information5,
	abi_information6,
	abi_information7,
	abi_information8,
	abi_information9,
	abi_information10,
	abi_information11,
	abi_information12,
	abi_information13,
	abi_information14,
	abi_information15,
	abi_information16,
	abi_information17,
	abi_information18,
	abi_information19,
	abi_information20,
	abi_information21,
	abi_information22,
	abi_information23,
	abi_information24,
	abi_information25,
	abi_information26,
	abi_information27,
	abi_information28,
	abi_information29,
	abi_information30,
	object_version_number
    from	ben_abr_extra_info
    where	abr_extra_info_id = p_abr_extra_info_id
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
    hr_utility.set_message_token('TABLE_NAME', 'BEN_ABR_EXTRA_INFO');
    hr_utility.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
	(
	p_abr_extra_info_id             in number,
	p_information_type              in varchar2,
	p_acty_base_rt_id                        in number,
	p_request_id                    in number,
	p_program_application_id        in number,
	p_program_id                    in number,
	p_program_update_date           in date,
	p_abi_attribute_category        in varchar2,
	p_abi_attribute1                in varchar2,
	p_abi_attribute2                in varchar2,
	p_abi_attribute3                in varchar2,
	p_abi_attribute4                in varchar2,
	p_abi_attribute5                in varchar2,
	p_abi_attribute6                in varchar2,
	p_abi_attribute7                in varchar2,
	p_abi_attribute8                in varchar2,
	p_abi_attribute9                in varchar2,
	p_abi_attribute10               in varchar2,
	p_abi_attribute11               in varchar2,
	p_abi_attribute12               in varchar2,
	p_abi_attribute13               in varchar2,
	p_abi_attribute14               in varchar2,
	p_abi_attribute15               in varchar2,
	p_abi_attribute16               in varchar2,
	p_abi_attribute17               in varchar2,
	p_abi_attribute18               in varchar2,
	p_abi_attribute19               in varchar2,
	p_abi_attribute20               in varchar2,
	p_abi_information_category      in varchar2,
	p_abi_information1              in varchar2,
	p_abi_information2              in varchar2,
	p_abi_information3              in varchar2,
	p_abi_information4              in varchar2,
	p_abi_information5              in varchar2,
	p_abi_information6              in varchar2,
	p_abi_information7              in varchar2,
	p_abi_information8              in varchar2,
	p_abi_information9              in varchar2,
	p_abi_information10             in varchar2,
	p_abi_information11             in varchar2,
	p_abi_information12             in varchar2,
	p_abi_information13             in varchar2,
	p_abi_information14             in varchar2,
	p_abi_information15             in varchar2,
	p_abi_information16             in varchar2,
	p_abi_information17             in varchar2,
	p_abi_information18             in varchar2,
	p_abi_information19             in varchar2,
	p_abi_information20             in varchar2,
	p_abi_information21             in varchar2,
	p_abi_information22             in varchar2,
	p_abi_information23             in varchar2,
	p_abi_information24             in varchar2,
	p_abi_information25             in varchar2,
	p_abi_information26             in varchar2,
	p_abi_information27             in varchar2,
	p_abi_information28             in varchar2,
	p_abi_information29             in varchar2,
	p_abi_information30             in varchar2,
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
  l_rec.abr_extra_info_id                := p_abr_extra_info_id;
  l_rec.information_type                 := p_information_type;
  l_rec.acty_base_rt_id                           := p_acty_base_rt_id;
  l_rec.request_id                       := p_request_id;
  l_rec.program_application_id           := p_program_application_id;
  l_rec.program_id                       := p_program_id;
  l_rec.program_update_date              := p_program_update_date;
  l_rec.abi_attribute_category           := p_abi_attribute_category;
  l_rec.abi_attribute1                   := p_abi_attribute1;
  l_rec.abi_attribute2                   := p_abi_attribute2;
  l_rec.abi_attribute3                   := p_abi_attribute3;
  l_rec.abi_attribute4                   := p_abi_attribute4;
  l_rec.abi_attribute5                   := p_abi_attribute5;
  l_rec.abi_attribute6                   := p_abi_attribute6;
  l_rec.abi_attribute7                   := p_abi_attribute7;
  l_rec.abi_attribute8                   := p_abi_attribute8;
  l_rec.abi_attribute9                   := p_abi_attribute9;
  l_rec.abi_attribute10                  := p_abi_attribute10;
  l_rec.abi_attribute11                  := p_abi_attribute11;
  l_rec.abi_attribute12                  := p_abi_attribute12;
  l_rec.abi_attribute13                  := p_abi_attribute13;
  l_rec.abi_attribute14                  := p_abi_attribute14;
  l_rec.abi_attribute15                  := p_abi_attribute15;
  l_rec.abi_attribute16                  := p_abi_attribute16;
  l_rec.abi_attribute17                  := p_abi_attribute17;
  l_rec.abi_attribute18                  := p_abi_attribute18;
  l_rec.abi_attribute19                  := p_abi_attribute19;
  l_rec.abi_attribute20                  := p_abi_attribute20;
  l_rec.abi_information_category         := p_abi_information_category;
  l_rec.abi_information1                 := p_abi_information1;
  l_rec.abi_information2                 := p_abi_information2;
  l_rec.abi_information3                 := p_abi_information3;
  l_rec.abi_information4                 := p_abi_information4;
  l_rec.abi_information5                 := p_abi_information5;
  l_rec.abi_information6                 := p_abi_information6;
  l_rec.abi_information7                 := p_abi_information7;
  l_rec.abi_information8                 := p_abi_information8;
  l_rec.abi_information9                 := p_abi_information9;
  l_rec.abi_information10                := p_abi_information10;
  l_rec.abi_information11                := p_abi_information11;
  l_rec.abi_information12                := p_abi_information12;
  l_rec.abi_information13                := p_abi_information13;
  l_rec.abi_information14                := p_abi_information14;
  l_rec.abi_information15                := p_abi_information15;
  l_rec.abi_information16                := p_abi_information16;
  l_rec.abi_information17                := p_abi_information17;
  l_rec.abi_information18                := p_abi_information18;
  l_rec.abi_information19                := p_abi_information19;
  l_rec.abi_information20                := p_abi_information20;
  l_rec.abi_information21                := p_abi_information21;
  l_rec.abi_information22                := p_abi_information22;
  l_rec.abi_information23                := p_abi_information23;
  l_rec.abi_information24                := p_abi_information24;
  l_rec.abi_information25                := p_abi_information25;
  l_rec.abi_information26                := p_abi_information26;
  l_rec.abi_information27                := p_abi_information27;
  l_rec.abi_information28                := p_abi_information28;
  l_rec.abi_information29                := p_abi_information29;
  l_rec.abi_information30                := p_abi_information30;
  l_rec.object_version_number            := p_object_version_number;
  --
  -- Return the abrsql record structure.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  Return(l_rec);
--
End convert_args;
--
end ben_abi_shd;

/
