--------------------------------------------------------
--  DDL for Package Body PE_POI_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PE_POI_SHD" as
/* $Header: pepoirhi.pkb 120.0 2005/05/31 14:50:38 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pe_poi_shd.';  -- Global package name
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
  If (p_constraint_name = 'PER_POSITION_EXTRA_INFO_FK1') Then
    hr_utility.set_message(800, 'HR_INV_INFO_TYPE');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'PER_POSITION_EXTRA_INFO_FK2') Then
    hr_utility.set_message(800, 'HR_INV_POS_ID');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'PER_POSITION_EXTRA_INFO_PK') Then
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
  p_position_extra_info_id             in number,
  p_object_version_number              in number
  )      Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
        position_extra_info_id,
	position_id,
	information_type,
	request_id,
	program_application_id,
	program_id,
	program_update_date,
	poei_attribute_category,
	poei_attribute1,
	poei_attribute2,
	poei_attribute3,
	poei_attribute4,
	poei_attribute5,
	poei_attribute6,
	poei_attribute7,
	poei_attribute8,
	poei_attribute9,
	poei_attribute10,
	poei_attribute11,
	poei_attribute12,
	poei_attribute13,
	poei_attribute14,
	poei_attribute15,
	poei_attribute16,
	poei_attribute17,
	poei_attribute18,
	poei_attribute19,
	poei_attribute20,
	poei_information_category,
	poei_information1,
	poei_information2,
	poei_information3,
	poei_information4,
	poei_information5,
	poei_information6,
	poei_information7,
	poei_information8,
	poei_information9,
	poei_information10,
        poei_information11,
	poei_information12,
	poei_information13,
	poei_information14,
	poei_information15,
	poei_information16,
	poei_information17,
	poei_information18,
	poei_information19,
	poei_information20,
	poei_information21,
	poei_information22,
	poei_information23,
	poei_information24,
	poei_information25,
	poei_information26,
	poei_information27,
	poei_information28,
	poei_information29,
	poei_information30,
	object_version_number
    from	per_position_extra_info
    where	position_extra_info_id = p_position_extra_info_id;
--
  l_proc	varchar2(72)	:= g_package||'api_updating';
  l_fct_ret	boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (
	p_position_extra_info_id is null and
	p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (
	p_position_extra_info_id = g_old_rec.position_extra_info_id and
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
  p_position_extra_info_id             in number,
  p_object_version_number              in number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select
     	position_extra_info_id,
	position_id,
	information_type,
	request_id,
	program_application_id,
	program_id,
	program_update_date,
	poei_attribute_category,
	poei_attribute1,
	poei_attribute2,
	poei_attribute3,
	poei_attribute4,
	poei_attribute5,
	poei_attribute6,
	poei_attribute7,
	poei_attribute8,
	poei_attribute9,
	poei_attribute10,
	poei_attribute11,
	poei_attribute12,
	poei_attribute13,
	poei_attribute14,
	poei_attribute15,
	poei_attribute16,
	poei_attribute17,
	poei_attribute18,
	poei_attribute19,
	poei_attribute20,
	poei_information_category,
	poei_information1,
	poei_information2,
	poei_information3,
	poei_information4,
	poei_information5,
	poei_information6,
	poei_information7,
	poei_information8,
	poei_information9,
	poei_information10,
	poei_information11,
	poei_information12,
	poei_information13,
	poei_information14,
	poei_information15,
	poei_information16,
	poei_information17,
	poei_information18,
	poei_information19,
	poei_information20,
	poei_information21,
	poei_information22,
	poei_information23,
	poei_information24,
	poei_information25,
	poei_information26,
	poei_information27,
	poei_information28,
	poei_information29,
	poei_information30,
	object_version_number
    from	per_position_extra_info
    where	position_extra_info_id = p_position_extra_info_id
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
    hr_utility.set_message_token('TABLE_NAME', 'per_position_extra_info');
    hr_utility.raise_error;
End lck;

--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
        (
        p_position_extra_info_id        in number,
        p_position_id                   in number,
        p_information_type              in varchar2,
        p_request_id                    in number,
        p_program_application_id        in number,
        p_program_id                    in number,
        p_program_update_date           in date,
        p_poei_attribute_category       in varchar2,
        p_poei_attribute1               in varchar2,
        p_poei_attribute2               in varchar2,
        p_poei_attribute3               in varchar2,
        p_poei_attribute4               in varchar2,
        p_poei_attribute5               in varchar2,
        p_poei_attribute6               in varchar2,
        p_poei_attribute7               in varchar2,
        p_poei_attribute8               in varchar2,
        p_poei_attribute9               in varchar2,
        p_poei_attribute10              in varchar2,
        p_poei_attribute11              in varchar2,
        p_poei_attribute12              in varchar2,
        p_poei_attribute13              in varchar2,
        p_poei_attribute14              in varchar2,
        p_poei_attribute15              in varchar2,
        p_poei_attribute16              in varchar2,
        p_poei_attribute17              in varchar2,
        p_poei_attribute18              in varchar2,
        p_poei_attribute19              in varchar2,
        p_poei_attribute20              in varchar2,
        p_poei_information_category     in varchar2,
        p_poei_information1             in varchar2,
        p_poei_information2             in varchar2,
        p_poei_information3             in varchar2,
        p_poei_information4             in varchar2,
        p_poei_information5             in varchar2,
        p_poei_information6             in varchar2,
        p_poei_information7             in varchar2,
        p_poei_information8             in varchar2,
        p_poei_information9             in varchar2,
        p_poei_information10            in varchar2,
        p_poei_information11            in varchar2,
        p_poei_information12            in varchar2,
        p_poei_information13            in varchar2,
        p_poei_information14            in varchar2,
        p_poei_information15            in varchar2,
        p_poei_information16            in varchar2,
        p_poei_information17            in varchar2,
        p_poei_information18            in varchar2,
        p_poei_information19            in varchar2,
        p_poei_information20            in varchar2,
        p_poei_information21            in varchar2,
        p_poei_information22            in varchar2,
        p_poei_information23            in varchar2,
        p_poei_information24            in varchar2,
        p_poei_information25            in varchar2,
        p_poei_information26            in varchar2,
        p_poei_information27            in varchar2,
        p_poei_information28            in varchar2,
        p_poei_information29            in varchar2,
        p_poei_information30            in varchar2,
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
  l_rec.position_extra_info_id           := p_position_extra_info_id;
  l_rec.position_id                      := p_position_id;
  l_rec.information_type                 := p_information_type;
  l_rec.request_id                       := p_request_id;
  l_rec.program_application_id           := p_program_application_id;
  l_rec.program_id                       := p_program_id;
  l_rec.program_update_date              := p_program_update_date;
  l_rec.poei_attribute_category          := p_poei_attribute_category;
  l_rec.poei_attribute1                  := p_poei_attribute1;
  l_rec.poei_attribute2                  := p_poei_attribute2;
  l_rec.poei_attribute3                  := p_poei_attribute3;
  l_rec.poei_attribute4                  := p_poei_attribute4;
  l_rec.poei_attribute5                  := p_poei_attribute5;
  l_rec.poei_attribute6                  := p_poei_attribute6;
  l_rec.poei_attribute7                  := p_poei_attribute7;
  l_rec.poei_attribute8                  := p_poei_attribute8;
  l_rec.poei_attribute9                  := p_poei_attribute9;
  l_rec.poei_attribute10                 := p_poei_attribute10;
  l_rec.poei_attribute11                 := p_poei_attribute11;
  l_rec.poei_attribute12                 := p_poei_attribute12;
  l_rec.poei_attribute13                 := p_poei_attribute13;
  l_rec.poei_attribute14                 := p_poei_attribute14;
  l_rec.poei_attribute15                 := p_poei_attribute15;
  l_rec.poei_attribute16                 := p_poei_attribute16;
  l_rec.poei_attribute17                 := p_poei_attribute17;
  l_rec.poei_attribute18                 := p_poei_attribute18;
  l_rec.poei_attribute19                 := p_poei_attribute19;
  l_rec.poei_attribute20                 := p_poei_attribute20;
  l_rec.poei_information_category        := p_poei_information_category;
  l_rec.poei_information1                := p_poei_information1;
  l_rec.poei_information2                := p_poei_information2;
  l_rec.poei_information3                := p_poei_information3;
  l_rec.poei_information4                := p_poei_information4;
  l_rec.poei_information5                := p_poei_information5;
  l_rec.poei_information6                := p_poei_information6;
  l_rec.poei_information7                := p_poei_information7;
  l_rec.poei_information8                := p_poei_information8;
  l_rec.poei_information9                := p_poei_information9;
  l_rec.poei_information10               := p_poei_information10;
  l_rec.poei_information11               := p_poei_information11;
  l_rec.poei_information12               := p_poei_information12;
  l_rec.poei_information13               := p_poei_information13;
  l_rec.poei_information14               := p_poei_information14;
  l_rec.poei_information15               := p_poei_information15;
  l_rec.poei_information16               := p_poei_information16;
  l_rec.poei_information17               := p_poei_information17;
  l_rec.poei_information18               := p_poei_information18;
  l_rec.poei_information19               := p_poei_information19;
  l_rec.poei_information20               := p_poei_information20;
  l_rec.poei_information21               := p_poei_information21;
  l_rec.poei_information22               := p_poei_information22;
  l_rec.poei_information23               := p_poei_information23;
  l_rec.poei_information24               := p_poei_information24;
  l_rec.poei_information25               := p_poei_information25;
  l_rec.poei_information26               := p_poei_information26;
  l_rec.poei_information27               := p_poei_information27;
  l_rec.poei_information28               := p_poei_information28;
  l_rec.poei_information29               := p_poei_information29;
  l_rec.poei_information30               := p_poei_information30;
  l_rec.object_version_number            := p_object_version_number;
  --
  -- Return the plsql record structure.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  Return(l_rec);
--
End convert_args;
--
end pe_poi_shd;

/
