--------------------------------------------------------
--  DDL for Package Body PER_CPN_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_CPN_SHD" as
/* $Header: pecpnrhi.pkb 120.0 2005/05/31 07:14:07 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  per_cpn_shd.';  -- Global package name
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
  hr_utility.set_location(p_constraint_name,9999);
  --
  If (p_constraint_name = 'PER_COMPETENCES_FK1') Then
    hr_utility.set_message(801, 'HR_7208_API_BUS_GRP_INVALID');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','5');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'PER_COMPETENCES_FK2') Then
    hr_utility.set_message(801, 'HR_51452_COMP_RAT_SC_NOT_EXIST');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'PER_COMPETENCES_PK') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','15');
    hr_utility.raise_error;
  --
  -- pmfletch - Replaced with procedure chk_definition_id
  --ElsIf (p_constraint_name = 'PER_COMPETENCES_UK2') Then
  --  hr_utility.set_message(801, 'HR_51436_COMP_NOT_UNIQUE');
  --  hr_utility.raise_error;
  --
  ElsIf (p_constraint_name = 'PER_CPN_CERT_REQ_CHK') Then
    hr_utility.set_message(801, 'HR_51432_COMP_CERTIFY_FLAG');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'PER_CPN_RENEWAL_CHK') Then
    hr_utility.set_message(801, 'HR_51435_COMP_DEPENDENT_FIELDS');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','35');
    hr_utility.raise_error;
  --
  -- pmfletch Replaced with procedure chk_alias in TL row handler
  -- -- ngundura changes done for pa requirements
  -- ElsIf (p_constraint_name = 'PER_COMPETENCES_UK3') Then
  --   fnd_message.set_name('PER', 'HR_52700_ALIAS_NOT_UNIQUE');
  -- --hr_utility.set_message_token('PROCEDURE', l_proc);
  -- --hr_utility.set_message_token('CONSTRAINT_NAME', p_constraint_name);
  --   fnd_message.raise_error;
  -- -- ngundura end of changes
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
  p_competence_id                      in number,
  p_object_version_number              in number
  )      Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
	competence_id,
	name,
	business_group_id,
	object_version_number,
	description,
	date_from,
	date_to,
	behavioural_indicator,
	certification_required,
	evaluation_method,
	renewal_period_frequency,
	renewal_period_units,
	min_level,
	max_level,
        rating_scale_id,
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
        competence_alias,
        competence_definition_id
       ,competence_cluster                -- BUG3356369
       ,unit_standard_id
       ,credit_type
       ,credits
       ,level_type
       ,level_number
       ,field
       ,sub_field
       ,provider
       ,qa_organization
       ,information_category
       ,information1
       ,information2
       ,information3
       ,information4
       ,information5
       ,information6
       ,information7
       ,information8
       ,information9
       ,information10
       ,information11
       ,information12
       ,information13
       ,information14
       ,information15
       ,information16
       ,information17
       ,information18
       ,information19
       ,information20
    from	per_competences
    where	competence_id = p_competence_id;
--
  l_proc	varchar2(72)	:= g_package||'api_updating';
  l_fct_ret	boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (
	p_competence_id is null and
	p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (
	p_competence_id = g_old_rec.competence_id and
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
  p_competence_id                      in number,
  p_object_version_number              in number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select 	competence_id,
	name,
	business_group_id,
	object_version_number,
	description,
	date_from,
	date_to,
	behavioural_indicator,
	certification_required,
	evaluation_method,
	renewal_period_frequency,
	renewal_period_units,
        min_level,
	max_level,
	rating_scale_id,
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
        competence_alias,
        competence_definition_id
       ,competence_cluster                -- BUG3356369
       ,unit_standard_id
       ,credit_type
       ,credits
       ,level_type
       ,level_number
       ,field
       ,sub_field
       ,provider
       ,qa_organization
       ,information_category
       ,information1
       ,information2
       ,information3
       ,information4
       ,information5
       ,information6
       ,information7
       ,information8
       ,information9
       ,information10
       ,information11
       ,information12
       ,information13
       ,information14
       ,information15
       ,information16
       ,information17
       ,information18
       ,information19
       ,information20
    from	per_competences
    where	competence_id = p_competence_id
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
    hr_utility.set_message_token('TABLE_NAME', 'per_competences');
    hr_utility.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
	(
	p_competence_id                 in number,
	p_name                          in varchar2,
	p_business_group_id             in number,
	p_object_version_number         in number,
	p_description                   in varchar2,
	p_date_from 			in date,
	p_date_to 			in date,
	p_behavioural_indicator         in varchar2,
	p_certification_required        in varchar2,
	p_evaluation_method             in varchar2,
	p_renewal_period_frequency      in number,
	p_renewal_period_units          in varchar2,
	p_min_level			in number,
	p_max_level			in number,
	p_rating_scale_id		in number,
        p_attribute_category            in varchar2,
        p_attribute1                    in varchar2,
        p_attribute2                    in varchar2,
        p_attribute3                    in varchar2,
        p_attribute4                    in varchar2,
        p_attribute5                    in varchar2,
        p_attribute6                    in varchar2,
        p_attribute7                    in varchar2,
        p_attribute8                    in varchar2,
        p_attribute9                    in varchar2,
        p_attribute10                   in varchar2,
        p_attribute11                   in varchar2,
        p_attribute12                   in varchar2,
        p_attribute13                   in varchar2,
        p_attribute14                   in varchar2,
        p_attribute15                   in varchar2,
        p_attribute16                   in varchar2,
        p_attribute17                   in varchar2,
        p_attribute18                   in varchar2,
        p_attribute19                   in varchar2,
        p_attribute20                   in varchar2,
        p_competence_alias              in varchar2,
        p_competence_definition_id      in number
       ,p_competence_cluster            in varchar2   -- BUG3356369
       ,p_unit_standard_id              in varchar2
       ,p_credit_type                   in varchar2
       ,p_credits                       in number
       ,p_level_type                    in varchar2
       ,p_level_number                  in number
       ,p_field                         in varchar2
       ,p_sub_field                     in varchar2
       ,p_provider                      in varchar2
       ,p_qa_organization               in varchar2
       ,p_information_category          in varchar2
       ,p_information1                  in varchar2
       ,p_information2                  in varchar2
       ,p_information3                  in varchar2
       ,p_information4                  in varchar2
       ,p_information5                  in varchar2
       ,p_information6                  in varchar2
       ,p_information7                  in varchar2
       ,p_information8                  in varchar2
       ,p_information9                  in varchar2
       ,p_information10                 in varchar2
       ,p_information11                 in varchar2
       ,p_information12                 in varchar2
       ,p_information13                 in varchar2
       ,p_information14                 in varchar2
       ,p_information15                 in varchar2
       ,p_information16                 in varchar2
       ,p_information17                 in varchar2
       ,p_information18                 in varchar2
       ,p_information19                 in varchar2
       ,p_information20                 in varchar2
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
  l_rec.competence_id                    := p_competence_id;
  l_rec.name                             := p_name;
  l_rec.business_group_id                := p_business_group_id;
  l_rec.object_version_number            := p_object_version_number;
  l_rec.description                      := p_description;
  l_rec.date_from 			 := p_date_from;
  l_rec.date_to 			 := p_date_to;
  l_rec.behavioural_indicator            := p_behavioural_indicator;
  l_rec.certification_required           := p_certification_required;
  l_rec.evaluation_method                := p_evaluation_method;
  l_rec.renewal_period_frequency         := p_renewal_period_frequency;
  l_rec.renewal_period_units             := p_renewal_period_units;
  l_rec.min_level			 := p_min_level;
  l_rec.max_level                        := p_max_level;
  l_rec.rating_scale_id			 := p_rating_scale_id;
  l_rec.attribute_category               := p_attribute_category;
  l_rec.attribute1                       := p_attribute1;
  l_rec.attribute2                       := p_attribute2;
  l_rec.attribute3                       := p_attribute3;
  l_rec.attribute4                       := p_attribute4;
  l_rec.attribute5                       := p_attribute5;
  l_rec.attribute6                       := p_attribute6;
  l_rec.attribute7                       := p_attribute7;
  l_rec.attribute8                       := p_attribute8;
  l_rec.attribute9                       := p_attribute9;
  l_rec.attribute10                      := p_attribute10;
  l_rec.attribute11                      := p_attribute11;
  l_rec.attribute12                      := p_attribute12;
  l_rec.attribute13                      := p_attribute13;
  l_rec.attribute14                      := p_attribute14;
  l_rec.attribute15                      := p_attribute15;
  l_rec.attribute16                      := p_attribute16;
  l_rec.attribute17                      := p_attribute17;
  l_rec.attribute18                      := p_attribute18;
  l_rec.attribute19                      := p_attribute19;
  l_rec.attribute20                      := p_attribute20;
  l_rec.competence_alias                 := p_competence_alias;
  l_rec.competence_definition_id         := p_competence_definition_id;
  -- BUG3356369
  l_rec.competence_cluster               := p_competence_cluster;
  l_rec.unit_standard_id                 := p_unit_standard_id;
  l_rec.credit_type                      := p_credit_type;
  l_rec.credits                          := p_credits;
  l_rec.level_type                       := p_level_type;
  l_rec.level_number                     := p_level_number;
  l_rec.field                            := p_field     ;
  l_rec.sub_field                        := p_sub_field;
  l_rec.provider                         := p_provider;
  l_rec.qa_organization                  := p_qa_organization;
  l_rec.information_category             := p_information_category;
  l_rec.information1                     := p_information1;
  l_rec.information2                     := p_information2;
  l_rec.information3                     := p_information3;
  l_rec.information4                     := p_information4;
  l_rec.information5                     := p_information5;
  l_rec.information6                     := p_information6;
  l_rec.information7                     := p_information7;
  l_rec.information8                     := p_information8;
  l_rec.information9                     := p_information9;
  l_rec.information10                    := p_information10;
  l_rec.information11                    := p_information11;
  l_rec.information12                    := p_information12;
  l_rec.information13                    := p_information13;
  l_rec.information14                    := p_information14;
  l_rec.information15                    := p_information15;
  l_rec.information16                    := p_information16;
  l_rec.information17                    := p_information17;
  l_rec.information18                    := p_information18;
  l_rec.information19                    := p_information19;
  l_rec.information20                    := p_information20;
  --
  -- Return the plsql record structure.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  Return(l_rec);
--
End convert_args;
--
end per_cpn_shd;

/
