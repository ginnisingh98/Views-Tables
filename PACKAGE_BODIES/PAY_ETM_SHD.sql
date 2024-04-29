--------------------------------------------------------
--  DDL for Package Body PAY_ETM_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_ETM_SHD" as
/* $Header: pyetmrhi.pkb 120.0 2005/05/29 04:42:30 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pay_etm_shd.';  -- Global package name
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
  If (p_constraint_name = 'PAY_ELEMENT_TEMPLATES_PK') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','5');
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
  p_template_id                        in number,
  p_object_version_number              in number
  )      Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
		template_id,
	template_type,
	template_name,
	base_processing_priority,
	business_group_id,
	legislation_code,
	version_number,
	base_name,
	max_base_name_length,
	preference_info_category,
	preference_information1,
	preference_information2,
	preference_information3,
	preference_information4,
	preference_information5,
	preference_information6,
	preference_information7,
	preference_information8,
	preference_information9,
	preference_information10,
	preference_information11,
	preference_information12,
	preference_information13,
	preference_information14,
	preference_information15,
	preference_information16,
	preference_information17,
	preference_information18,
	preference_information19,
	preference_information20,
	preference_information21,
	preference_information22,
	preference_information23,
	preference_information24,
	preference_information25,
	preference_information26,
	preference_information27,
	preference_information28,
	preference_information29,
	preference_information30,
	configuration_info_category,
	configuration_information1,
	configuration_information2,
	configuration_information3,
	configuration_information4,
	configuration_information5,
	configuration_information6,
	configuration_information7,
	configuration_information8,
	configuration_information9,
	configuration_information10,
	configuration_information11,
	configuration_information12,
	configuration_information13,
	configuration_information14,
	configuration_information15,
	configuration_information16,
	configuration_information17,
	configuration_information18,
	configuration_information19,
	configuration_information20,
	configuration_information21,
	configuration_information22,
	configuration_information23,
	configuration_information24,
	configuration_information25,
	configuration_information26,
	configuration_information27,
	configuration_information28,
	configuration_information29,
	configuration_information30,
	object_version_number
    from	pay_element_templates
    where	template_id = p_template_id;
--
  l_proc	varchar2(72)	:= g_package||'api_updating';
  l_fct_ret	boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (
	p_template_id is null and
	p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (
	p_template_id = g_old_rec.template_id and
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
  p_template_id                        in number,
  p_object_version_number              in number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select 	template_id,
	template_type,
	template_name,
	base_processing_priority,
	business_group_id,
	legislation_code,
	version_number,
	base_name,
	max_base_name_length,
	preference_info_category,
	preference_information1,
	preference_information2,
	preference_information3,
	preference_information4,
	preference_information5,
	preference_information6,
	preference_information7,
	preference_information8,
	preference_information9,
	preference_information10,
	preference_information11,
	preference_information12,
	preference_information13,
	preference_information14,
	preference_information15,
	preference_information16,
	preference_information17,
	preference_information18,
	preference_information19,
	preference_information20,
	preference_information21,
	preference_information22,
	preference_information23,
	preference_information24,
	preference_information25,
	preference_information26,
	preference_information27,
	preference_information28,
	preference_information29,
	preference_information30,
	configuration_info_category,
	configuration_information1,
	configuration_information2,
	configuration_information3,
	configuration_information4,
	configuration_information5,
	configuration_information6,
	configuration_information7,
	configuration_information8,
	configuration_information9,
	configuration_information10,
	configuration_information11,
	configuration_information12,
	configuration_information13,
	configuration_information14,
	configuration_information15,
	configuration_information16,
	configuration_information17,
	configuration_information18,
	configuration_information19,
	configuration_information20,
	configuration_information21,
	configuration_information22,
	configuration_information23,
	configuration_information24,
	configuration_information25,
	configuration_information26,
	configuration_information27,
	configuration_information28,
	configuration_information29,
	configuration_information30,
	object_version_number
    from	pay_element_templates
    where	template_id = p_template_id
    for	update nowait;
--
  l_proc	varchar2(72) := g_package||'lck';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Check for mandatory arguments.
  --
  hr_api.mandatory_arg_error
  (p_api_name       => l_proc
  ,p_argument       => 'p_template_id'
  ,p_argument_value => p_template_id
  );
  hr_api.mandatory_arg_error
  (p_api_name       => l_proc
  ,p_argument       => 'object_version_number'
  ,p_argument_value => p_object_version_number
  );
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
    hr_utility.set_message_token('TABLE_NAME', 'pay_element_templates');
    hr_utility.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
	(
	p_template_id                   in number,
	p_template_type                 in varchar2,
	p_template_name                 in varchar2,
	p_base_processing_priority      in number,
	p_business_group_id             in number,
	p_legislation_code              in varchar2,
	p_version_number                in number,
	p_base_name                     in varchar2,
	p_max_base_name_length          in number,
	p_preference_info_category      in varchar2,
	p_preference_information1       in varchar2,
	p_preference_information2       in varchar2,
	p_preference_information3       in varchar2,
	p_preference_information4       in varchar2,
	p_preference_information5       in varchar2,
	p_preference_information6       in varchar2,
	p_preference_information7       in varchar2,
	p_preference_information8       in varchar2,
	p_preference_information9       in varchar2,
	p_preference_information10      in varchar2,
	p_preference_information11      in varchar2,
	p_preference_information12      in varchar2,
	p_preference_information13      in varchar2,
	p_preference_information14      in varchar2,
	p_preference_information15      in varchar2,
	p_preference_information16      in varchar2,
	p_preference_information17      in varchar2,
	p_preference_information18      in varchar2,
	p_preference_information19      in varchar2,
	p_preference_information20      in varchar2,
	p_preference_information21      in varchar2,
	p_preference_information22      in varchar2,
	p_preference_information23      in varchar2,
	p_preference_information24      in varchar2,
	p_preference_information25      in varchar2,
	p_preference_information26      in varchar2,
	p_preference_information27      in varchar2,
	p_preference_information28      in varchar2,
	p_preference_information29      in varchar2,
	p_preference_information30      in varchar2,
	p_configuration_info_category   in varchar2,
	p_configuration_information1    in varchar2,
	p_configuration_information2    in varchar2,
	p_configuration_information3    in varchar2,
	p_configuration_information4    in varchar2,
	p_configuration_information5    in varchar2,
	p_configuration_information6    in varchar2,
	p_configuration_information7    in varchar2,
	p_configuration_information8    in varchar2,
	p_configuration_information9    in varchar2,
	p_configuration_information10   in varchar2,
	p_configuration_information11   in varchar2,
	p_configuration_information12   in varchar2,
	p_configuration_information13   in varchar2,
	p_configuration_information14   in varchar2,
	p_configuration_information15   in varchar2,
	p_configuration_information16   in varchar2,
	p_configuration_information17   in varchar2,
	p_configuration_information18   in varchar2,
	p_configuration_information19   in varchar2,
	p_configuration_information20   in varchar2,
	p_configuration_information21   in varchar2,
	p_configuration_information22   in varchar2,
	p_configuration_information23   in varchar2,
	p_configuration_information24   in varchar2,
	p_configuration_information25   in varchar2,
	p_configuration_information26   in varchar2,
	p_configuration_information27   in varchar2,
	p_configuration_information28   in varchar2,
	p_configuration_information29   in varchar2,
	p_configuration_information30   in varchar2,
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
  l_rec.template_id                      := p_template_id;
  l_rec.template_type                    := p_template_type;
  l_rec.template_name                    := p_template_name;
  l_rec.base_processing_priority         := p_base_processing_priority;
  l_rec.business_group_id                := p_business_group_id;
  l_rec.legislation_code                 := p_legislation_code;
  l_rec.version_number                   := p_version_number;
  l_rec.base_name                        := p_base_name;
  l_rec.max_base_name_length             := p_max_base_name_length;
  l_rec.preference_info_category         := p_preference_info_category;
  l_rec.preference_information1          := p_preference_information1;
  l_rec.preference_information2          := p_preference_information2;
  l_rec.preference_information3          := p_preference_information3;
  l_rec.preference_information4          := p_preference_information4;
  l_rec.preference_information5          := p_preference_information5;
  l_rec.preference_information6          := p_preference_information6;
  l_rec.preference_information7          := p_preference_information7;
  l_rec.preference_information8          := p_preference_information8;
  l_rec.preference_information9          := p_preference_information9;
  l_rec.preference_information10         := p_preference_information10;
  l_rec.preference_information11         := p_preference_information11;
  l_rec.preference_information12         := p_preference_information12;
  l_rec.preference_information13         := p_preference_information13;
  l_rec.preference_information14         := p_preference_information14;
  l_rec.preference_information15         := p_preference_information15;
  l_rec.preference_information16         := p_preference_information16;
  l_rec.preference_information17         := p_preference_information17;
  l_rec.preference_information18         := p_preference_information18;
  l_rec.preference_information19         := p_preference_information19;
  l_rec.preference_information20         := p_preference_information20;
  l_rec.preference_information21         := p_preference_information21;
  l_rec.preference_information22         := p_preference_information22;
  l_rec.preference_information23         := p_preference_information23;
  l_rec.preference_information24         := p_preference_information24;
  l_rec.preference_information25         := p_preference_information25;
  l_rec.preference_information26         := p_preference_information26;
  l_rec.preference_information27         := p_preference_information27;
  l_rec.preference_information28         := p_preference_information28;
  l_rec.preference_information29         := p_preference_information29;
  l_rec.preference_information30         := p_preference_information30;
  l_rec.configuration_info_category      := p_configuration_info_category;
  l_rec.configuration_information1       := p_configuration_information1;
  l_rec.configuration_information2       := p_configuration_information2;
  l_rec.configuration_information3       := p_configuration_information3;
  l_rec.configuration_information4       := p_configuration_information4;
  l_rec.configuration_information5       := p_configuration_information5;
  l_rec.configuration_information6       := p_configuration_information6;
  l_rec.configuration_information7       := p_configuration_information7;
  l_rec.configuration_information8       := p_configuration_information8;
  l_rec.configuration_information9       := p_configuration_information9;
  l_rec.configuration_information10      := p_configuration_information10;
  l_rec.configuration_information11      := p_configuration_information11;
  l_rec.configuration_information12      := p_configuration_information12;
  l_rec.configuration_information13      := p_configuration_information13;
  l_rec.configuration_information14      := p_configuration_information14;
  l_rec.configuration_information15      := p_configuration_information15;
  l_rec.configuration_information16      := p_configuration_information16;
  l_rec.configuration_information17      := p_configuration_information17;
  l_rec.configuration_information18      := p_configuration_information18;
  l_rec.configuration_information19      := p_configuration_information19;
  l_rec.configuration_information20      := p_configuration_information20;
  l_rec.configuration_information21      := p_configuration_information21;
  l_rec.configuration_information22      := p_configuration_information22;
  l_rec.configuration_information23      := p_configuration_information23;
  l_rec.configuration_information24      := p_configuration_information24;
  l_rec.configuration_information25      := p_configuration_information25;
  l_rec.configuration_information26      := p_configuration_information26;
  l_rec.configuration_information27      := p_configuration_information27;
  l_rec.configuration_information28      := p_configuration_information28;
  l_rec.configuration_information29      := p_configuration_information29;
  l_rec.configuration_information30      := p_configuration_information30;
  l_rec.object_version_number            := p_object_version_number;
  --
  -- Return the plsql record structure.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  Return(l_rec);
--
End convert_args;
--
end pay_etm_shd;

/
