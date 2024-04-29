--------------------------------------------------------
--  DDL for Package Body PER_CTR_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_CTR_SHD" as
/* $Header: pectrrhi.pkb 120.2.12010000.3 2009/04/09 13:42:18 pchowdav ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  per_ctr_shd.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------------------------< return_api_dml_status >-------------------------|
-- ----------------------------------------------------------------------------
Function return_api_dml_status Return Boolean Is
--
  l_proc    varchar2(72) := g_package||'return_api_dml_status';
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
  l_proc    varchar2(72) := g_package||'constraint_error';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (p_constraint_name = 'P.ER_CONTACT_RELATIONSHIPS_FK1') Then
    hr_utility.set_message(801, 'HR_7208_API_BUS_GRP_INVALID');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'PER_CONTACT_RELATIONSHIPS_PK') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'PER_CONT_BONDHOLDER_FLAG_CHK') Then
    hr_utility.set_message(801, 'HR_51386_CTR_INV_BONDHLD_FLAG');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'PER_CONT_PRIMARY_CONTACT_F_CHK') Then
    hr_utility.set_message(801, 'HR_51388_CTR_INV_P_CONT_FLAG');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'PER_CONT_RLTD_PER_DSGNTR_F_CHK') Then
    hr_utility.set_message(801, 'PER_52379_RLTD_PER_DSGNTR_FLAG');
    hr_utility.raise_error;
  Elsif (p_constraint_name = 'PER_CONT_PERSONAL_F_CHK') Then
    hr_utility.set_message(801,'PER_52406_PERSONAL_FLAG');
    hr_utility.raise_error;
  Elsif (p_constraint_name = 'PER_CONT_DEPENDENT_FLAG_CHK') then
    hr_utility.set_message(801,'PER_51387_CTR_INV_DEPEND_FLAG');
    hr_utility.raise_error;
  Elsif (p_constraint_name = 'PER_CONT_BENEFICIARY_FLAG_CHK') then
    hr_utility.set_message(801,'PER_51385_CTR_INVALID_BEN_FLAG');
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
  p_contact_relationship_id            in number,
  p_object_version_number              in number
  )      Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
   contact_relationship_id,
   business_group_id,
   person_id,
   contact_person_id,
   contact_type,
   comments,
   primary_contact_flag,
   request_id,
   program_application_id,
   program_id,
   program_update_date,
        date_start,
        start_life_reason_id,
        date_end,
        end_life_reason_id,
        rltd_per_rsds_w_dsgntr_flag,
        personal_flag,
   sequence_number,
        cont_attribute_category,
   cont_attribute1,
   cont_attribute2,
   cont_attribute3,
   cont_attribute4,
   cont_attribute5,
   cont_attribute6,
   cont_attribute7,
   cont_attribute8,
   cont_attribute9,
   cont_attribute10,
   cont_attribute11,
   cont_attribute12,
   cont_attribute13,
   cont_attribute14,
   cont_attribute15,
   cont_attribute16,
   cont_attribute17,
   cont_attribute18,
   cont_attribute19,
   cont_attribute20,
        cont_information_category,
   cont_information1,
   cont_information2,
   cont_information3,
   cont_information4,
   cont_information5,
   cont_information6,
   cont_information7,
   cont_information8,
   cont_information9,
   cont_information10,
   cont_information11,
   cont_information12,
   cont_information13,
   cont_information14,
   cont_information15,
   cont_information16,
   cont_information17,
   cont_information18,
   cont_information19,
   cont_information20,
   third_party_pay_flag,
   bondholder_flag,
        dependent_flag,
        beneficiary_flag,
   object_version_number
--
    from per_contact_relationships
    where   contact_relationship_id = p_contact_relationship_id;
--
  l_proc varchar2(72)   := g_package||'api_updating';
  l_fct_ret boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (
   p_contact_relationship_id is null and
   p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (
   p_contact_relationship_id = g_old_rec.contact_relationship_id and
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
  p_contact_relationship_id            in number,
  p_object_version_number              in number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select  contact_relationship_id,
   business_group_id,
   person_id,
   contact_person_id,
   contact_type,
   comments,
   primary_contact_flag,
   request_id,
   program_application_id,
   program_id,
   program_update_date,
        date_start,
        start_life_reason_id,
        date_end,
        end_life_reason_id,
        rltd_per_rsds_w_dsgntr_flag,
        personal_flag,
   sequence_number,
        cont_attribute_category,
   cont_attribute1,
   cont_attribute2,
   cont_attribute3,
   cont_attribute4,
   cont_attribute5,
   cont_attribute6,
   cont_attribute7,
   cont_attribute8,
   cont_attribute9,
   cont_attribute10,
   cont_attribute11,
   cont_attribute12,
   cont_attribute13,
   cont_attribute14,
   cont_attribute15,
   cont_attribute16,
   cont_attribute17,
   cont_attribute18,
   cont_attribute19,
   cont_attribute20,
        cont_information_category,
   cont_information1,
   cont_information2,
   cont_information3,
   cont_information4,
   cont_information5,
   cont_information6,
   cont_information7,
   cont_information8,
   cont_information9,
   cont_information10,
   cont_information11,
   cont_information12,
   cont_information13,
   cont_information14,
   cont_information15,
   cont_information16,
   cont_information17,
   cont_information18,
   cont_information19,
   cont_information20,
   third_party_pay_flag,
   bondholder_flag,
        dependent_flag,
        beneficiary_flag,
   object_version_number

    from per_contact_relationships
    where   contact_relationship_id = p_contact_relationship_id
    for  update nowait;
--
  l_proc varchar2(72) := g_package||'lck';
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
    hr_utility.set_message_token('TABLE_NAME', 'per_contact_relationships');
    hr_utility.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
   (
   p_contact_relationship_id       in number,
   p_business_group_id             in number,
   p_person_id                     in number,
   p_contact_person_id             in number,
   p_contact_type                  in varchar2,
   p_comments                      in long,
   p_primary_contact_flag          in varchar2,
   p_request_id                    in number,
   p_program_application_id        in number,
   p_program_id                    in number,
   p_program_update_date           in date,
        p_date_start                    in date,
        p_start_life_reason_id          in number,
        p_date_end                      in date,
        p_end_life_reason_id            in number,
        p_rltd_per_rsds_w_dsgntr_flag   in varchar2,
        p_personal_flag                 in varchar2,
   p_sequence_number               in number,
   p_cont_attribute_category       in varchar2,
   p_cont_attribute1               in varchar2,
   p_cont_attribute2               in varchar2,
   p_cont_attribute3               in varchar2,
   p_cont_attribute4               in varchar2,
   p_cont_attribute5               in varchar2,
   p_cont_attribute6               in varchar2,
   p_cont_attribute7               in varchar2,
   p_cont_attribute8               in varchar2,
   p_cont_attribute9               in varchar2,
   p_cont_attribute10              in varchar2,
   p_cont_attribute11              in varchar2,
   p_cont_attribute12              in varchar2,
   p_cont_attribute13              in varchar2,
   p_cont_attribute14              in varchar2,
   p_cont_attribute15              in varchar2,
   p_cont_attribute16              in varchar2,
   p_cont_attribute17              in varchar2,
   p_cont_attribute18              in varchar2,
   p_cont_attribute19              in varchar2,
   p_cont_attribute20              in varchar2,
   p_cont_information_category       in varchar2,
   p_cont_information1               in varchar2,
   p_cont_information2               in varchar2,
   p_cont_information3               in varchar2,
   p_cont_information4               in varchar2,
   p_cont_information5               in varchar2,
   p_cont_information6               in varchar2,
   p_cont_information7               in varchar2,
   p_cont_information8               in varchar2,
   p_cont_information9               in varchar2,
   p_cont_information10              in varchar2,
   p_cont_information11              in varchar2,
   p_cont_information12              in varchar2,
   p_cont_information13              in varchar2,
   p_cont_information14              in varchar2,
   p_cont_information15              in varchar2,
   p_cont_information16              in varchar2,
   p_cont_information17              in varchar2,
   p_cont_information18              in varchar2,
   p_cont_information19              in varchar2,
   p_cont_information20              in varchar2,
   p_third_party_pay_flag          in varchar2,
   p_bondholder_flag               in varchar2,
        p_dependent_flag                in varchar2,
        p_beneficiary_flag              in varchar2,
   p_object_version_number         in number
        )
   Return g_rec_type is
--
  l_rec    g_rec_type;
  l_proc  varchar2(72) := g_package||'convert_args';
--
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Convert arguments into local l_rec structure.
  --
  l_rec.contact_relationship_id          := p_contact_relationship_id;
  l_rec.business_group_id                := p_business_group_id;
  l_rec.person_id                        := p_person_id;
  l_rec.contact_person_id                := p_contact_person_id;
  l_rec.contact_type                     := p_contact_type;
  l_rec.comments                         := p_comments;
  l_rec.primary_contact_flag             := p_primary_contact_flag;
  l_rec.request_id                       := p_request_id;
  l_rec.program_application_id           := p_program_application_id;
  l_rec.program_id                       := p_program_id;
  l_rec.program_update_date              := p_program_update_date;
  l_rec.date_start                       := p_date_start;
  l_rec.start_life_reason_id             := p_start_life_reason_id;
  l_rec.date_end                         := p_date_end;
  l_rec.end_life_reason_id               := p_end_life_reason_id;
  l_rec.rltd_per_rsds_w_dsgntr_flag      := p_rltd_per_rsds_w_dsgntr_flag;
  l_rec.personal_flag                    := p_personal_flag;
  l_rec.sequence_number                  := p_sequence_number;
  l_rec.cont_attribute_category          := p_cont_attribute_category;
  l_rec.cont_attribute1                  := p_cont_attribute1;
  l_rec.cont_attribute2                  := p_cont_attribute2;
  l_rec.cont_attribute3                  := p_cont_attribute3;
  l_rec.cont_attribute4                  := p_cont_attribute4;
  l_rec.cont_attribute5                  := p_cont_attribute5;
  l_rec.cont_attribute6                  := p_cont_attribute6;
  l_rec.cont_attribute7                  := p_cont_attribute7;
  l_rec.cont_attribute8                  := p_cont_attribute8;
  l_rec.cont_attribute9                  := p_cont_attribute9;
  l_rec.cont_attribute10                 := p_cont_attribute10;
  l_rec.cont_attribute11                 := p_cont_attribute11;
  l_rec.cont_attribute12                 := p_cont_attribute12;
  l_rec.cont_attribute13                 := p_cont_attribute13;
  l_rec.cont_attribute14                 := p_cont_attribute14;
  l_rec.cont_attribute15                 := p_cont_attribute15;
  l_rec.cont_attribute16                 := p_cont_attribute16;
  l_rec.cont_attribute17                 := p_cont_attribute17;
  l_rec.cont_attribute18                 := p_cont_attribute18;
  l_rec.cont_attribute19                 := p_cont_attribute19;
  l_rec.cont_attribute20                 := p_cont_attribute20;
  l_rec.cont_information_category          := p_cont_information_category;
  l_rec.cont_information1                  := p_cont_information1;
  l_rec.cont_information2                  := p_cont_information2;
  l_rec.cont_information3                  := p_cont_information3;
  l_rec.cont_information4                  := p_cont_information4;
  l_rec.cont_information5                  := p_cont_information5;
  l_rec.cont_information6                  := p_cont_information6;
  l_rec.cont_information7                  := p_cont_information7;
  l_rec.cont_information8                  := p_cont_information8;
  l_rec.cont_information9                  := p_cont_information9;
  l_rec.cont_information10                 := p_cont_information10;
  l_rec.cont_information11                 := p_cont_information11;
  l_rec.cont_information12                 := p_cont_information12;
  l_rec.cont_information13                 := p_cont_information13;
  l_rec.cont_information14                 := p_cont_information14;
  l_rec.cont_information15                 := p_cont_information15;
  l_rec.cont_information16                 := p_cont_information16;
  l_rec.cont_information17                 := p_cont_information17;
  l_rec.cont_information18                 := p_cont_information18;
  l_rec.cont_information19                 := p_cont_information19;
  l_rec.cont_information20                 := p_cont_information20;
  l_rec.third_party_pay_flag             := p_third_party_pay_flag;
  l_rec.bondholder_flag                  := p_bondholder_flag;
  l_rec.dependent_flag                   := p_dependent_flag;
  l_rec.beneficiary_flag                 := p_beneficiary_flag;
  l_rec.object_version_number            := p_object_version_number;
  --
  --
  -- Return the plsql record structure.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  Return(l_rec);
--
End convert_args;
--
end per_ctr_shd;

/
