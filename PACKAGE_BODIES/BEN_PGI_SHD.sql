--------------------------------------------------------
--  DDL for Package Body BEN_PGI_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PGI_SHD" as
/* $Header: bepgirhi.pkb 115.0 2003/09/23 10:19:40 hmani noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_pgi_shd.';  -- Global package name
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
  If (p_constraint_name = 'BEN_PGM_EXTRA_INFO_FK1') Then
    hr_utility.set_message(801, 'HR_INV_INFO_TYPE');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'BEN_PGM_EXTRA_INFO_FK2') Then
    hr_utility.set_message(801, 'HR_INV_pl_ID');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'BEN_PGM_EXTRA_INFO_PK') Then
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
  p_pgm_extra_info_id                  in number,

  p_object_version_number              in number
  )      Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
	pgm_extra_info_id,
	information_type,
	pgm_id,
	request_id,
	program_application_id,
	program_id,
	program_update_date,
	pgi_attribute_category,
	pgi_attribute1,
	pgi_attribute2,
	pgi_attribute3,
	pgi_attribute4,
	pgi_attribute5,
	pgi_attribute6,
	pgi_attribute7,
	pgi_attribute8,
	pgi_attribute9,
	pgi_attribute10,
	pgi_attribute11,
	pgi_attribute12,
	pgi_attribute13,
	pgi_attribute14,
	pgi_attribute15,
	pgi_attribute16,
	pgi_attribute17,
	pgi_attribute18,
	pgi_attribute19,
	pgi_attribute20,
	pgi_information_category,
	pgi_information1,
	pgi_information2,
	pgi_information3,
	pgi_information4,
	pgi_information5,
	pgi_information6,
	pgi_information7,
	pgi_information8,
	pgi_information9,
	pgi_information10,
	pgi_information11,
	pgi_information12,
	pgi_information13,
	pgi_information14,
	pgi_information15,
	pgi_information16,
	pgi_information17,
	pgi_information18,
	pgi_information19,
	pgi_information20,
	pgi_information21,
	pgi_information22,
	pgi_information23,
	pgi_information24,
	pgi_information25,
	pgi_information26,
	pgi_information27,
	pgi_information28,
	pgi_information29,
	pgi_information30,
	object_version_number
    from	BEN_pgm_extra_info
    where	pgm_extra_info_id = p_pgm_extra_info_id;
--
  l_proc	varchar2(72)	:= g_package||'api_updating';
  l_fct_ret	boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (
	p_pgm_extra_info_id is null and
	p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (
	p_pgm_extra_info_id = g_old_rec.pgm_extra_info_id and
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
  p_pgm_extra_info_id                  in number,
  p_object_version_number              in number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select 	pgm_extra_info_id,
	information_type,
	pgm_id,
	request_id,
	program_application_id,
	program_id,
	program_update_date,
	pgi_attribute_category,
	pgi_attribute1,
	pgi_attribute2,
	pgi_attribute3,
	pgi_attribute4,
	pgi_attribute5,
	pgi_attribute6,
	pgi_attribute7,
	pgi_attribute8,
	pgi_attribute9,
	pgi_attribute10,
	pgi_attribute11,
	pgi_attribute12,
	pgi_attribute13,
	pgi_attribute14,
	pgi_attribute15,
	pgi_attribute16,
	pgi_attribute17,
	pgi_attribute18,
	pgi_attribute19,
	pgi_attribute20,
	pgi_information_category,
	pgi_information1,
	pgi_information2,
	pgi_information3,
	pgi_information4,
	pgi_information5,
	pgi_information6,
	pgi_information7,
	pgi_information8,
	pgi_information9,
	pgi_information10,
	pgi_information11,
	pgi_information12,
	pgi_information13,
	pgi_information14,
	pgi_information15,
	pgi_information16,
	pgi_information17,
	pgi_information18,
	pgi_information19,
	pgi_information20,
	pgi_information21,
	pgi_information22,
	pgi_information23,
	pgi_information24,
	pgi_information25,
	pgi_information26,
	pgi_information27,
	pgi_information28,
	pgi_information29,
	pgi_information30,
	object_version_number
    from	ben_pgm_extra_info
    where	pgm_extra_info_id = p_pgm_extra_info_id
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
    hr_utility.set_message_token('TABLE_NAME', 'BEN_PGM_EXTRA_INFO');
    hr_utility.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
	(
	p_pgm_extra_info_id             in number,
	p_information_type              in varchar2,
	p_pgm_id                        in number,
	p_request_id                    in number,
	p_program_application_id        in number,
	p_program_id                    in number,
	p_program_update_date           in date,
	p_pgi_attribute_category        in varchar2,
	p_pgi_attribute1                in varchar2,
	p_pgi_attribute2                in varchar2,
	p_pgi_attribute3                in varchar2,
	p_pgi_attribute4                in varchar2,
	p_pgi_attribute5                in varchar2,
	p_pgi_attribute6                in varchar2,
	p_pgi_attribute7                in varchar2,
	p_pgi_attribute8                in varchar2,
	p_pgi_attribute9                in varchar2,
	p_pgi_attribute10               in varchar2,
	p_pgi_attribute11               in varchar2,
	p_pgi_attribute12               in varchar2,
	p_pgi_attribute13               in varchar2,
	p_pgi_attribute14               in varchar2,
	p_pgi_attribute15               in varchar2,
	p_pgi_attribute16               in varchar2,
	p_pgi_attribute17               in varchar2,
	p_pgi_attribute18               in varchar2,
	p_pgi_attribute19               in varchar2,
	p_pgi_attribute20               in varchar2,
	p_pgi_information_category      in varchar2,
	p_pgi_information1              in varchar2,
	p_pgi_information2              in varchar2,
	p_pgi_information3              in varchar2,
	p_pgi_information4              in varchar2,
	p_pgi_information5              in varchar2,
	p_pgi_information6              in varchar2,
	p_pgi_information7              in varchar2,
	p_pgi_information8              in varchar2,
	p_pgi_information9              in varchar2,
	p_pgi_information10             in varchar2,
	p_pgi_information11             in varchar2,
	p_pgi_information12             in varchar2,
	p_pgi_information13             in varchar2,
	p_pgi_information14             in varchar2,
	p_pgi_information15             in varchar2,
	p_pgi_information16             in varchar2,
	p_pgi_information17             in varchar2,
	p_pgi_information18             in varchar2,
	p_pgi_information19             in varchar2,
	p_pgi_information20             in varchar2,
	p_pgi_information21             in varchar2,
	p_pgi_information22             in varchar2,
	p_pgi_information23             in varchar2,
	p_pgi_information24             in varchar2,
	p_pgi_information25             in varchar2,
	p_pgi_information26             in varchar2,
	p_pgi_information27             in varchar2,
	p_pgi_information28             in varchar2,
	p_pgi_information29             in varchar2,
	p_pgi_information30             in varchar2,
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
  l_rec.pgm_extra_info_id                := p_pgm_extra_info_id;
  l_rec.information_type                 := p_information_type;
  l_rec.pgm_id                           := p_pgm_id;
  l_rec.request_id                       := p_request_id;
  l_rec.program_application_id           := p_program_application_id;
  l_rec.program_id                       := p_program_id;
  l_rec.program_update_date              := p_program_update_date;
  l_rec.pgi_attribute_category           := p_pgi_attribute_category;
  l_rec.pgi_attribute1                   := p_pgi_attribute1;
  l_rec.pgi_attribute2                   := p_pgi_attribute2;
  l_rec.pgi_attribute3                   := p_pgi_attribute3;
  l_rec.pgi_attribute4                   := p_pgi_attribute4;
  l_rec.pgi_attribute5                   := p_pgi_attribute5;
  l_rec.pgi_attribute6                   := p_pgi_attribute6;
  l_rec.pgi_attribute7                   := p_pgi_attribute7;
  l_rec.pgi_attribute8                   := p_pgi_attribute8;
  l_rec.pgi_attribute9                   := p_pgi_attribute9;
  l_rec.pgi_attribute10                  := p_pgi_attribute10;
  l_rec.pgi_attribute11                  := p_pgi_attribute11;
  l_rec.pgi_attribute12                  := p_pgi_attribute12;
  l_rec.pgi_attribute13                  := p_pgi_attribute13;
  l_rec.pgi_attribute14                  := p_pgi_attribute14;
  l_rec.pgi_attribute15                  := p_pgi_attribute15;
  l_rec.pgi_attribute16                  := p_pgi_attribute16;
  l_rec.pgi_attribute17                  := p_pgi_attribute17;
  l_rec.pgi_attribute18                  := p_pgi_attribute18;
  l_rec.pgi_attribute19                  := p_pgi_attribute19;
  l_rec.pgi_attribute20                  := p_pgi_attribute20;
  l_rec.pgi_information_category         := p_pgi_information_category;
  l_rec.pgi_information1                 := p_pgi_information1;
  l_rec.pgi_information2                 := p_pgi_information2;
  l_rec.pgi_information3                 := p_pgi_information3;
  l_rec.pgi_information4                 := p_pgi_information4;
  l_rec.pgi_information5                 := p_pgi_information5;
  l_rec.pgi_information6                 := p_pgi_information6;
  l_rec.pgi_information7                 := p_pgi_information7;
  l_rec.pgi_information8                 := p_pgi_information8;
  l_rec.pgi_information9                 := p_pgi_information9;
  l_rec.pgi_information10                := p_pgi_information10;
  l_rec.pgi_information11                := p_pgi_information11;
  l_rec.pgi_information12                := p_pgi_information12;
  l_rec.pgi_information13                := p_pgi_information13;
  l_rec.pgi_information14                := p_pgi_information14;
  l_rec.pgi_information15                := p_pgi_information15;
  l_rec.pgi_information16                := p_pgi_information16;
  l_rec.pgi_information17                := p_pgi_information17;
  l_rec.pgi_information18                := p_pgi_information18;
  l_rec.pgi_information19                := p_pgi_information19;
  l_rec.pgi_information20                := p_pgi_information20;
  l_rec.pgi_information21                := p_pgi_information21;
  l_rec.pgi_information22                := p_pgi_information22;
  l_rec.pgi_information23                := p_pgi_information23;
  l_rec.pgi_information24                := p_pgi_information24;
  l_rec.pgi_information25                := p_pgi_information25;
  l_rec.pgi_information26                := p_pgi_information26;
  l_rec.pgi_information27                := p_pgi_information27;
  l_rec.pgi_information28                := p_pgi_information28;
  l_rec.pgi_information29                := p_pgi_information29;
  l_rec.pgi_information30                := p_pgi_information30;
  l_rec.object_version_number            := p_object_version_number;
  --
  -- Return the pgmsql record structure.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  Return(l_rec);
--
End convert_args;
--
end ben_pgi_shd;

/
