--------------------------------------------------------
--  DDL for Package Body PER_EQT_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_EQT_SHD" as
/* $Header: peeqtrhi.pkb 115.15 2004/03/30 18:11:30 ynegoro ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  per_eqt_shd.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------------------------< return_api_dml_status >-------------------------|
-- ----------------------------------------------------------------------------
Function return_api_dml_status Return Boolean Is
--
  l_proc 	varchar2(72) := g_package||'return_api_dml_status';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  Return (nvl(g_api_dml, false));
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End return_api_dml_status;
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
  If (p_constraint_name = 'PER_QUALIFICATION_TYPES_PK') Then
    hr_utility.set_message(801, 'HR_51535_EQT_QUAL_TYPE_PK');
    hr_utility.raise_error;
  --
  -- pmfletch. Now coded check in TL row handler
  --
  -- ElsIf (p_constraint_name = 'PER_QUALIFICATION_TYPES_UK') Then
  --   hr_utility.set_message(801, 'HR_51536_EQT_NAME_UK');
  --   hr_utility.raise_error;
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
  p_qualification_type_id              in number,
  p_object_version_number              in number
  )      Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema

  -- mvankda
  -- Added Developer DF Columns to cursor C_Sel1

  Cursor C_Sel1 is
    select
	qualification_type_id,
	name,
	category,
	rank,
	attribute_category,
	attribute1,
	attribute2,
	attribute3,
	attribute4,
	attribute5,
	attribute6,
	attribute7,
	attribute8,
	attribute9,
	attribute10,
	attribute11,
	attribute12,
	attribute13,
	attribute14,
	attribute15,
	attribute16,
	attribute17,
	attribute18,
	attribute19,
	attribute20,
	object_version_number,
	information_category,
        information1,
 	information2,
	information3,
	information4,
	information5,
	information6,
	information7,
	information8,
	information9,
	information10,
	information11,
	information12,
	information13,
	information14,
	information15,
	information16,
	information17,
	information18,
	information19,
	information20,
	information21,
	information22,
	information23,
	information24,
	information25,
	information26,
	information27,
	information28,
	information29,
	information30
       ,qual_framework_id     -- BUG3356369
       ,qualification_type
       ,credit_type
       ,credits
       ,level_type
       ,level_number
       ,field
       ,sub_field
       ,provider
       ,qa_organization
    from	per_qualification_types
    where	qualification_type_id = p_qualification_type_id;
--
  l_proc	varchar2(72)	:= g_package||'api_updating';
  l_fct_ret	boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (
	p_qualification_type_id is null and
	p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (
	p_qualification_type_id = g_old_rec.qualification_type_id and
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
  p_qualification_type_id              in number,
  p_object_version_number              in number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
-- mvankda
-- Added Developer DF columns to Curor C_Sel1

  Cursor C_Sel1 is
    select 	qualification_type_id,
	name,
	category,
	rank,
	attribute_category,
	attribute1,
	attribute2,
	attribute3,
	attribute4,
	attribute5,
	attribute6,
	attribute7,
	attribute8,
	attribute9,
	attribute10,
	attribute11,
	attribute12,
	attribute13,
	attribute14,
	attribute15,
	attribute16,
	attribute17,
	attribute18,
	attribute19,
	attribute20,
	object_version_number,
	information_category,
        information1,
 	information2,
	information3,
	information4,
	information5,
	information6,
	information7,
	information8,
	information9,
	information10,
	information11,
	information12,
	information13,
	information14,
	information15,
	information16,
	information17,
	information18,
	information19,
	information20,
	information21,
	information22,
	information23,
	information24,
	information25,
	information26,
	information27,
	information28,
	information29,
	information30
       ,qual_framework_id     -- BUG3356369
       ,qualification_type
       ,credit_type
       ,credits
       ,level_type
       ,level_number
       ,field
       ,sub_field
       ,provider
       ,qa_organization
    from	per_qualification_types
    where	qualification_type_id = p_qualification_type_id
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
    hr_utility.set_message_token('TABLE_NAME', 'per_qualification_types');
    hr_utility.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
-- mvankada
-- Added Developer DF columns
Function convert_args
	(
	p_qualification_type_id   in number,
	p_name                    in varchar2,
	p_category                in varchar2,
	p_rank                    in number,
	p_attribute_category      in varchar2,
	p_attribute1              in varchar2,
	p_attribute2              in varchar2,
	p_attribute3              in varchar2,
	p_attribute4              in varchar2,
	p_attribute5              in varchar2,
	p_attribute6              in varchar2,
	p_attribute7              in varchar2,
	p_attribute8              in varchar2,
	p_attribute9              in varchar2,
	p_attribute10             in varchar2,
	p_attribute11             in varchar2,
	p_attribute12             in varchar2,
	p_attribute13             in varchar2,
	p_attribute14             in varchar2,
	p_attribute15             in varchar2,
	p_attribute16             in varchar2,
	p_attribute17             in varchar2,
	p_attribute18             in varchar2,
	p_attribute19             in varchar2,
	p_attribute20             in varchar2,
	p_object_version_number   in number,
	p_information_category    in varchar2,
	p_information1            in varchar2,
	p_information2	          in varchar2,
	p_information3            in varchar2,
	p_information4	          in varchar2,
	p_information5            in varchar2,
	p_information6	          in varchar2,
	p_information7            in varchar2,
	p_information8	          in varchar2,
	p_information9            in varchar2,
	p_information10	          in varchar2,
	p_information11           in varchar2,
	p_information12	          in varchar2,
	p_information13	          in varchar2,
	p_information14           in varchar2,
	p_information15	          in varchar2,
	p_information16           in varchar2,
	p_information17	          in varchar2,
	p_information18           in varchar2,
	p_information19	          in varchar2,
	p_information20           in varchar2,
	p_information21           in varchar2,
	p_information22	          in varchar2,
	p_information23	          in varchar2,
	p_information24           in varchar2,
	p_information25	          in varchar2,
	p_information26           in varchar2,
	p_information27	          in varchar2,
	p_information28           in varchar2,
	p_information29	          in varchar2,
	p_information30           in varchar2
       ,p_qual_framework_id       in number   -- BUG3356369
       ,p_qualification_type      in varchar2
       ,p_credit_type             in varchar2
       ,p_credits                 in number
       ,p_level_type              in varchar2
       ,p_level_number            in number
       ,p_field                   in varchar2
       ,p_sub_field               in varchar2
       ,p_provider                in varchar2
       ,p_qa_organization         in varchar2
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

  l_rec.qualification_type_id      := p_qualification_type_id;
  l_rec.name                       := p_name;
  l_rec.category                   := p_category;
  l_rec.rank                       := p_rank;
  l_rec.attribute_category         := p_attribute_category;
  l_rec.attribute1                 := p_attribute1;
  l_rec.attribute2                 := p_attribute2;
  l_rec.attribute3                 := p_attribute3;
  l_rec.attribute4                 := p_attribute4;
  l_rec.attribute5                 := p_attribute5;
  l_rec.attribute6                 := p_attribute6;
  l_rec.attribute7                 := p_attribute7;
  l_rec.attribute8                 := p_attribute8;
  l_rec.attribute9                 := p_attribute9;
  l_rec.attribute10                := p_attribute10;
  l_rec.attribute11                := p_attribute11;
  l_rec.attribute12                := p_attribute12;
  l_rec.attribute13                := p_attribute13;
  l_rec.attribute14                := p_attribute14;
  l_rec.attribute15                := p_attribute15;
  l_rec.attribute16                := p_attribute16;
  l_rec.attribute17                := p_attribute17;
  l_rec.attribute18                := p_attribute18;
  l_rec.attribute19                := p_attribute19;
  l_rec.attribute20                := p_attribute20;
  l_rec.object_version_number      := p_object_version_number;

  -- mvankada
  -- For DDF columns
  l_rec.information_category       := p_information_category;
  l_rec.information1	    	   := p_information1;
  l_rec.information2	  	   := p_information2;
  l_rec.information3	 	   := p_information3;
  l_rec.information4	 	   := p_information4;
  l_rec.information5	  	   := p_information5;
  l_rec.information6	  	   := p_information6;
  l_rec.information7	  	   := p_information7;
  l_rec.information8	  	   := p_information8;
  l_rec.information9	  	   := p_information9;
  l_rec.information10	  	   := p_information10;
  l_rec.information11	  	   := p_information11;
  l_rec.information12	  	   := p_information12;
  l_rec.information13	 	   := p_information13;
  l_rec.information14	  	   := p_information14;
  l_rec.information15	 	   := p_information15;
  l_rec.information16	  	   := p_information16;
  l_rec.information17	  	   := p_information17;
  l_rec.information18	 	   := p_information18;
  l_rec.information19	 	   := p_information19;
  l_rec.information20	   	   := p_information20;
  l_rec.information21	 	   := p_information21;
  l_rec.information22	   	   := p_information22;
  l_rec.information23	   	   := p_information23;
  l_rec.information24	  	   := p_information24;
  l_rec.information25	  	   := p_information25;
  l_rec.information26	  	   := p_information26;
  l_rec.information27		   := p_information27;
  l_rec.information28	  	   := p_information28;
  l_rec.information29	  	   := p_information29;
  l_rec.information30	  	   := p_information30;

  -- BUG3356369
  l_rec.qual_framework_id          := p_qual_framework_id;
  l_rec.qualification_type         := p_qualification_type;
  l_rec.credit_type                := p_credit_type;
  l_rec.credits                    := p_credits;
  l_rec.level_type                 := p_level_type;
  l_rec.level_number               := p_level_number;
  l_rec.field                      := p_field     ;
  l_rec.sub_field                  := p_sub_field;
  l_rec.provider                   := p_provider;
  l_rec.qa_organization            := p_qa_organization;
  --
  -- Return the plsql record structure.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  Return(l_rec);
--
End convert_args;
--
end per_eqt_shd;

/
