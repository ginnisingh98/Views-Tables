--------------------------------------------------------
--  DDL for Package Body PER_CAG_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_CAG_SHD" as
/* $Header: pecagrhi.pkb 120.1 2006/10/18 08:42:10 grreddy noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  per_cag_shd.';  -- Global package name
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
  If (p_constraint_name = 'PER_COLLECTIVE_AGREEMENTS_PK') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','5');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'PER_COLLECTIVE_AGREEMENTS_UK1') Then
    hr_utility.set_message(800, 'PER_52835_CAG_INV_CAG_NAME');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'PER_COLLECTIVE_AGREEMENTS_FK1') Then
    hr_utility.set_message(800, 'PER_52846_CAG_INV_EMP_ORG');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'PER_COLLECTIVE_AGREEMENTS_FK2') Then
    hr_utility.set_message(800, 'PER_52847_CAG_INV_BARG_ORG');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'PER_COLLECTIVE_AGREEMENTS_FK3') Then
    hr_utility.set_message(800, 'PER_52848_CAG_INV_BG');
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
  p_collective_agreement_id            in number,
  p_object_version_number              in number
  )      Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
  Select collective_agreement_id,
         business_group_id,
         object_version_number,
         name,
         status,
         pl_id,
         cag_number,
         description,
         start_date,
         end_date,
         employer_organization_id,
         employer_signatory,
         bargaining_organization_id,
         bargaining_unit_signatory,
         jurisdiction,
         authorizing_body,
         authorized_date,
         cag_information_category,
         cag_information1,
         cag_information2,
         cag_information3,
         cag_information4,
         cag_information5,
         cag_information6,
         cag_information7,
         cag_information8,
         cag_information9,
         cag_information10,
         cag_information11,
         cag_information12,
         cag_information13,
         cag_information14,
         cag_information15,
         cag_information16,
         cag_information17,
         cag_information18,
         cag_information19,
         cag_information20,
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
         attribute20
    from	per_collective_agreements
    where	collective_agreement_id = p_collective_agreement_id;
/*    select
	collective_agreement_id,
	business_group_id,
	object_version_number,
	name,
	pl_id,
	status,
	cag_number,
	description,
	start_date,
	end_date,
	employer_organization_id,
	employer_signatory,
	bargaining_organization_id,
	bargaining_unit_signatory,
	jurisdiction,
	authorizing_body,
	authorized_date,
	cag_information_category,
	cag_information1,
	cag_information2,
	cag_information3,
	cag_information4,
	cag_information5,
	cag_information6,
	cag_information7,
	cag_information8,
	cag_information9,
	cag_information10,
	cag_information11,
	cag_information12,
	cag_information13,
	cag_information14,
	cag_information15,
	cag_information16,
	cag_information17,
	cag_information18,
	cag_information19,
	cag_information20,
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
	attribute20	*/
--
  l_proc	varchar2(72)	:= g_package||'api_updating';
  l_fct_ret	boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (
	p_collective_agreement_id is null and
	p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (
	p_collective_agreement_id = g_old_rec.collective_agreement_id and
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
  p_collective_agreement_id            in number,
  p_object_version_number              in number
  ) is
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
  	collective_agreement_id,
	business_group_id,
	object_version_number,
	name,
	status,
	pl_id,
	cag_number,
	description,
	start_date,
	end_date,
	employer_organization_id,
	employer_signatory,
	bargaining_organization_id,
	bargaining_unit_signatory,
	jurisdiction,
	authorizing_body,
	authorized_date,
	cag_information_category,
	cag_information1,
	cag_information2,
	cag_information3,
	cag_information4,
	cag_information5,
	cag_information6,
	cag_information7,
	cag_information8,
	cag_information9,
	cag_information10,
	cag_information11,
	cag_information12,
	cag_information13,
	cag_information14,
	cag_information15,
	cag_information16,
	cag_information17,
	cag_information18,
	cag_information19,
	cag_information20,
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
	attribute20
    from	per_collective_agreements
    where	collective_agreement_id = p_collective_agreement_id
    for	update nowait;
  --
  l_proc	varchar2(72) := g_package||'lck';
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc||'/'||p_collective_agreement_id, 5);
  --
  -- Ensure that all mandatory arguments are not NULL
  --
  hr_api.mandatory_arg_error(p_api_name       => l_proc,
                             p_argument       => 'collective_agreement_id',
                             p_argument_value => p_collective_agreement_id);
  --
  hr_utility.set_location(l_proc, 10);
  --
  hr_api.mandatory_arg_error(p_api_name       => l_proc,
                             p_argument       => 'object_version_number',
                             p_argument_value => p_object_version_number);
  --
  hr_utility.set_location(l_proc, 20);
  --
  Open  C_Sel1;
  Fetch C_Sel1 Into g_old_rec;
  hr_utility.set_location(l_proc, 25);
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
  hr_utility.set_location(' Leaving:'||l_proc, 999);
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
    hr_utility.set_message_token('TABLE_NAME', 'per_collective_agreements');
    hr_utility.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
	(
	p_collective_agreement_id       in number,
	p_business_group_id             in number,
	p_object_version_number         in number,
	p_name                          in varchar2,
	p_pl_id                         in number,
	p_status                        in varchar2,
	p_cag_number                    in number,
	p_description                   in varchar2,
	p_start_date                    in date,
	p_end_date                      in date,
	p_employer_organization_id      in number,
	p_employer_signatory            in varchar2,
	p_bargaining_organization_id    in number,
	p_bargaining_unit_signatory     in varchar2,
	p_jurisdiction                  in varchar2,
	p_authorizing_body              in varchar2,
	p_authorized_date               in date,
	p_cag_information_category      in varchar2,
	p_cag_information1              in varchar2,
	p_cag_information2              in varchar2,
	p_cag_information3              in varchar2,
	p_cag_information4              in varchar2,
	p_cag_information5              in varchar2,
	p_cag_information6              in varchar2,
	p_cag_information7              in varchar2,
	p_cag_information8              in varchar2,
	p_cag_information9              in varchar2,
	p_cag_information10             in varchar2,
	p_cag_information11             in varchar2,
	p_cag_information12             in varchar2,
	p_cag_information13             in varchar2,
	p_cag_information14             in varchar2,
	p_cag_information15             in varchar2,
	p_cag_information16             in varchar2,
	p_cag_information17             in varchar2,
	p_cag_information18             in varchar2,
	p_cag_information19             in varchar2,
	p_cag_information20             in varchar2,
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
	p_attribute20                   in varchar2
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
  l_rec.collective_agreement_id          := p_collective_agreement_id;
  l_rec.business_group_id                := p_business_group_id;
  l_rec.object_version_number            := p_object_version_number;
  l_rec.name                             := p_name;
  l_rec.pl_id                            := p_pl_id;
  l_rec.status                           := p_status;
  l_rec.cag_number                       := p_cag_number;
  l_rec.description                      := p_description;
  l_rec.start_date                       := p_start_date;
  l_rec.end_date                         := p_end_date;
  l_rec.employer_organization_id         := p_employer_organization_id;
  l_rec.employer_signatory               := p_employer_signatory;
  l_rec.bargaining_organization_id       := p_bargaining_organization_id;
  l_rec.bargaining_unit_signatory        := p_bargaining_unit_signatory;
  l_rec.jurisdiction                     := p_jurisdiction;
  l_rec.authorizing_body                 := p_authorizing_body;
  l_rec.authorized_date                  := p_authorized_date;
  l_rec.cag_information_category         := p_cag_information_category;
  l_rec.cag_information1                 := p_cag_information1;
  l_rec.cag_information2                 := p_cag_information2;
  l_rec.cag_information3                 := p_cag_information3;
  l_rec.cag_information4                 := p_cag_information4;
  l_rec.cag_information5                 := p_cag_information5;
  l_rec.cag_information6                 := p_cag_information6;
  l_rec.cag_information7                 := p_cag_information7;
  l_rec.cag_information8                 := p_cag_information8;
  l_rec.cag_information9                 := p_cag_information9;
  l_rec.cag_information10                := p_cag_information10;
  l_rec.cag_information11                := p_cag_information11;
  l_rec.cag_information12                := p_cag_information12;
  l_rec.cag_information13                := p_cag_information13;
  l_rec.cag_information14                := p_cag_information14;
  l_rec.cag_information15                := p_cag_information15;
  l_rec.cag_information16                := p_cag_information16;
  l_rec.cag_information17                := p_cag_information17;
  l_rec.cag_information18                := p_cag_information18;
  l_rec.cag_information19                := p_cag_information19;
  l_rec.cag_information20                := p_cag_information20;
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
  --
  -- Return the plsql record structure.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  Return(l_rec);
--
End convert_args;
--

end per_cag_shd;

/
