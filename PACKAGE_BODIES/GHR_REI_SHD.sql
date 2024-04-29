--------------------------------------------------------
--  DDL for Package Body GHR_REI_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GHR_REI_SHD" as
/* $Header: ghreirhi.pkb 120.2.12010000.2 2008/09/02 07:19:59 vmididho ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ghr_rei_shd.';  -- Global package name
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
  If (p_constraint_name = 'GHR_PA_REQUEST_EXTRA_INFO_FK1') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','5');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'GHR_PA_REQUEST_EXTRA_INFO_FK2') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','10');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'GHR_PA_REQUEST_EXTRA_INFO_PK') Then
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
  p_pa_request_extra_info_id           in number,
  p_object_version_number              in number
  )      Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
		pa_request_extra_info_id,
	pa_request_id,
	information_type,
	rei_attribute_category,
	rei_attribute1,
	rei_attribute2,
	rei_attribute3,
	rei_attribute4,
	rei_attribute5,
	rei_attribute6,
	rei_attribute7,
	rei_attribute8,
	rei_attribute9,
	rei_attribute10,
	rei_attribute11,
	rei_attribute12,
	rei_attribute13,
	rei_attribute14,
	rei_attribute15,
	rei_attribute16,
	rei_attribute17,
	rei_attribute18,
	rei_attribute19,
	rei_attribute20,
	rei_information_category,
	rei_information1,
	rei_information2,
	rei_information3,
	rei_information4,
	rei_information5,
	rei_information6,
	rei_information7,
	rei_information8,
	rei_information9,
	rei_information10,
	rei_information11,
	rei_information12,
	rei_information13,
	rei_information14,
	rei_information15,
	rei_information16,
	rei_information17,
	rei_information18,
	rei_information19,
	rei_information20,
	rei_information21,
	rei_information22,
	rei_information28,
	rei_information29,
	rei_information23,
	rei_information24,
	rei_information25,
	rei_information26,
	rei_information27,
	rei_information30,
	object_version_number,
	request_id,
	program_application_id,
	program_id,
	program_update_date
    from	ghr_pa_request_extra_info
    where	pa_request_extra_info_id = p_pa_request_extra_info_id;
--
  l_proc	varchar2(72)	:= g_package||'api_updating';
  l_fct_ret	boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (
	p_pa_request_extra_info_id is null and
	p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (
	p_pa_request_extra_info_id = g_old_rec.pa_request_extra_info_id and
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
  p_pa_request_extra_info_id           in number,
  p_object_version_number              in number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select 	pa_request_extra_info_id,
	pa_request_id,
	information_type,
	rei_attribute_category,
	rei_attribute1,
	rei_attribute2,
	rei_attribute3,
	rei_attribute4,
	rei_attribute5,
	rei_attribute6,
	rei_attribute7,
	rei_attribute8,
	rei_attribute9,
	rei_attribute10,
	rei_attribute11,
	rei_attribute12,
	rei_attribute13,
	rei_attribute14,
	rei_attribute15,
	rei_attribute16,
	rei_attribute17,
	rei_attribute18,
	rei_attribute19,
	rei_attribute20,
	rei_information_category,
	rei_information1,
	rei_information2,
	rei_information3,
	rei_information4,
	rei_information5,
	rei_information6,
	rei_information7,
	rei_information8,
	rei_information9,
	rei_information10,
	rei_information11,
	rei_information12,
	rei_information13,
	rei_information14,
	rei_information15,
	rei_information16,
	rei_information17,
	rei_information18,
	rei_information19,
	rei_information20,
	rei_information21,
	rei_information22,
	rei_information28,
	rei_information29,
	rei_information23,
	rei_information24,
	rei_information25,
	rei_information26,
	rei_information27,
	rei_information30,
	object_version_number,
	request_id,
	program_application_id,
	program_id,
	program_update_date
    from	ghr_pa_request_extra_info
    where	pa_request_extra_info_id = p_pa_request_extra_info_id
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
    hr_utility.set_message_token('TABLE_NAME', 'ghr_ogh_pa_request_extra_info');

    hr_utility.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
	(
	p_pa_request_extra_info_id      in number,
	p_pa_request_id                 in number,
	p_information_type              in varchar2,
	p_rei_attribute_category        in varchar2,
	p_rei_attribute1                in varchar2,
	p_rei_attribute2                in varchar2,
	p_rei_attribute3                in varchar2,
	p_rei_attribute4                in varchar2,
	p_rei_attribute5                in varchar2,
	p_rei_attribute6                in varchar2,
	p_rei_attribute7                in varchar2,
	p_rei_attribute8                in varchar2,
	p_rei_attribute9                in varchar2,
	p_rei_attribute10               in varchar2,
	p_rei_attribute11               in varchar2,
	p_rei_attribute12               in varchar2,
	p_rei_attribute13               in varchar2,
	p_rei_attribute14               in varchar2,
	p_rei_attribute15               in varchar2,
	p_rei_attribute16               in varchar2,
	p_rei_attribute17               in varchar2,
	p_rei_attribute18               in varchar2,
	p_rei_attribute19               in varchar2,
	p_rei_attribute20               in varchar2,
	p_rei_information_category      in varchar2,
	p_rei_information1              in varchar2,
	p_rei_information2              in varchar2,
	p_rei_information3              in varchar2,
	p_rei_information4              in varchar2,
	p_rei_information5              in varchar2,
	p_rei_information6              in varchar2,
	p_rei_information7              in varchar2,
	p_rei_information8              in varchar2,
	p_rei_information9              in varchar2,
	p_rei_information10             in varchar2,
	p_rei_information11             in varchar2,
	p_rei_information12             in varchar2,
	p_rei_information13             in varchar2,
	p_rei_information14             in varchar2,
	p_rei_information15             in varchar2,
	p_rei_information16             in varchar2,
	p_rei_information17             in varchar2,
	p_rei_information18             in varchar2,
	p_rei_information19             in varchar2,
	p_rei_information20             in varchar2,
	p_rei_information21             in varchar2,
	p_rei_information22             in varchar2,
	p_rei_information28             in varchar2,
	p_rei_information29             in varchar2,
	p_rei_information23             in varchar2,
	p_rei_information24             in varchar2,
	p_rei_information25             in varchar2,
	p_rei_information26             in varchar2,
	p_rei_information27             in varchar2,
	p_rei_information30             in varchar2,
	p_object_version_number         in number,
	p_request_id                    in number,
	p_program_application_id        in number,
	p_program_id                    in number,
	p_program_update_date           in date
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
  l_rec.pa_request_extra_info_id         := p_pa_request_extra_info_id;
  l_rec.pa_request_id                    := p_pa_request_id;
  l_rec.information_type                 := p_information_type;
  l_rec.rei_attribute_category           := p_rei_attribute_category;
  l_rec.rei_attribute1                   := p_rei_attribute1;
  l_rec.rei_attribute2                   := p_rei_attribute2;
  l_rec.rei_attribute3                   := p_rei_attribute3;
  l_rec.rei_attribute4                   := p_rei_attribute4;
  l_rec.rei_attribute5                   := p_rei_attribute5;
  l_rec.rei_attribute6                   := p_rei_attribute6;
  l_rec.rei_attribute7                   := p_rei_attribute7;
  l_rec.rei_attribute8                   := p_rei_attribute8;
  l_rec.rei_attribute9                   := p_rei_attribute9;
  l_rec.rei_attribute10                  := p_rei_attribute10;
  l_rec.rei_attribute11                  := p_rei_attribute11;
  l_rec.rei_attribute12                  := p_rei_attribute12;
  l_rec.rei_attribute13                  := p_rei_attribute13;
  l_rec.rei_attribute14                  := p_rei_attribute14;
  l_rec.rei_attribute15                  := p_rei_attribute15;
  l_rec.rei_attribute16                  := p_rei_attribute16;
  l_rec.rei_attribute17                  := p_rei_attribute17;
  l_rec.rei_attribute18                  := p_rei_attribute18;
  l_rec.rei_attribute19                  := p_rei_attribute19;
  l_rec.rei_attribute20                  := p_rei_attribute20;
  l_rec.rei_information_category         := p_rei_information_category;
  l_rec.rei_information1                 := p_rei_information1;
  l_rec.rei_information2                 := p_rei_information2;
  l_rec.rei_information3                 := p_rei_information3;
  l_rec.rei_information4                 := p_rei_information4;
  l_rec.rei_information5                 := p_rei_information5;
  l_rec.rei_information6                 := p_rei_information6;
  l_rec.rei_information7                 := p_rei_information7;
  l_rec.rei_information8                 := p_rei_information8;
  l_rec.rei_information9                 := p_rei_information9;
  l_rec.rei_information10                := p_rei_information10;
  l_rec.rei_information11                := p_rei_information11;
  l_rec.rei_information12                := p_rei_information12;
  l_rec.rei_information13                := p_rei_information13;
  l_rec.rei_information14                := p_rei_information14;
  l_rec.rei_information15                := p_rei_information15;
  l_rec.rei_information16                := p_rei_information16;
  l_rec.rei_information17                := p_rei_information17;
  l_rec.rei_information18                := p_rei_information18;
  l_rec.rei_information19                := p_rei_information19;
  l_rec.rei_information20                := p_rei_information20;
  l_rec.rei_information21                := p_rei_information21;
  l_rec.rei_information22                := p_rei_information22;
  l_rec.rei_information28                := p_rei_information28;
  l_rec.rei_information29                := p_rei_information29;
  l_rec.rei_information23                := p_rei_information23;
  l_rec.rei_information24                := p_rei_information24;
  l_rec.rei_information25                := p_rei_information25;
  l_rec.rei_information26                := p_rei_information26;
  l_rec.rei_information27                := p_rei_information27;
  l_rec.rei_information30                := p_rei_information30;
  l_rec.object_version_number            := p_object_version_number;
  l_rec.request_id                       := p_request_id;
  l_rec.program_application_id           := p_program_application_id;
  l_rec.program_id                       := p_program_id;
  l_rec.program_update_date              := p_program_update_date;
  --
  -- Return the plsql record structure.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  Return(l_rec);
--
End convert_args;
--
end ghr_rei_shd;

/
