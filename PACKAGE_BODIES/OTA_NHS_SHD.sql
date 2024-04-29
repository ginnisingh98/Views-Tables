--------------------------------------------------------
--  DDL for Package Body OTA_NHS_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_NHS_SHD" as
/* $Header: otnhsrhi.pkb 120.1 2005/09/30 05:00:04 ssur noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  ota_nhs_shd.';  -- Global package name
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
  If (p_constraint_name = 'OTA_NOTRNG_HISTORIES_PK') Then
    fnd_message.set_name('OTA', 'OTA_13698_NHS_PRIMARY_KEY');
    fnd_message.raise_error;
  Elsif (p_constraint_name = 'OTA_NOTRNG_HISTORIES_FK1') Then
    fnd_message.set_name('OTA', 'OTA_13699_NHS_FOREIGN_KEY1');
    fnd_message.raise_error;
  Elsif (p_constraint_name = 'OTA_NOTRNG_HISTORIES_FK2') Then
    fnd_message.set_name('OTA', 'OTA_13303_TAV_NOT_EXISTS');
    fnd_message.raise_error;
  Elsif (p_constraint_name = 'OTA_NTH_CUSTOMER_ID_NOT_NULL') Then
    fnd_message.set_name('OTA', 'OTA_13883_NHS_CUS_ORG_EXISTS');
    fnd_message.raise_error;
  Elsif (p_constraint_name = 'OTA_NTH_ORGANIZATION_NOT_NULL') Then
    fnd_message.set_name('OTA', 'OTA_13883_NHS_CUS_ORG_EXISTS');
    fnd_message.raise_error;
  Else
    fnd_message.set_name('OTA', 'OTA_13259_GEN_UNKN_CONSTRAINT');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('CONSTRAINT', p_constraint_name);
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
  p_nota_history_id                    in number,
  p_object_version_number              in number
  )      Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
      nota_history_id,
   person_id,
   contact_id,
   trng_title,
   provider,
   type,
   centre,
   completion_date,
   award,
   rating,
   duration,
   duration_units,
   activity_version_id,
   status,
   verified_by_id,
   nth_information_category,
   nth_information1,
   nth_information2,
   nth_information3,
   nth_information4,
   nth_information5,
   nth_information6,
   nth_information7,
   nth_information8,
   nth_information9,
   nth_information10,
   nth_information11,
   nth_information12,
   nth_information13,
   nth_information15,
   nth_information16,
   nth_information17,
   nth_information18,
   nth_information19,
   nth_information20,
   org_id,
   object_version_number,
   business_group_id,
   nth_information14,
        customer_id,
        organization_id
    from ota_notrng_histories
    where   nota_history_id = p_nota_history_id;
--
  l_proc varchar2(72)   := g_package||'api_updating';
  l_fct_ret boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (
   p_nota_history_id is null and
   p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (
   p_nota_history_id = g_old_rec.nota_history_id and
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
  p_nota_history_id                    in number,
  p_object_version_number              in number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select  nota_history_id,
   person_id,
   contact_id,
   trng_title,
   provider,
   type,
   centre,
   completion_date,
   award,
   rating,
   duration,
   duration_units,
   activity_version_id,
   status,
   verified_by_id,
   nth_information_category,
   nth_information1,
   nth_information2,
   nth_information3,
   nth_information4,
   nth_information5,
   nth_information6,
   nth_information7,
   nth_information8,
   nth_information9,
   nth_information10,
   nth_information11,
   nth_information12,
   nth_information13,
   nth_information15,
   nth_information16,
   nth_information17,
   nth_information18,
   nth_information19,
   nth_information20,
   org_id,
   object_version_number,
   business_group_id,
   nth_information14,
        customer_id,
        organization_id
    from ota_notrng_histories
    where   nota_history_id = p_nota_history_id
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
    hr_utility.set_message_token('TABLE_NAME', 'ota_notrng_histories');
    hr_utility.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
   (
   p_nota_history_id               in number,
   p_person_id                     in number,
   p_contact_id                    in number,
   p_trng_title                    in varchar2,
   p_provider                      in varchar2,
   p_type                          in varchar2,
   p_centre                        in varchar2,
   p_completion_date               in date,
   p_award                         in varchar2,
   p_rating                        in varchar2,
   p_duration                      in number,
   p_duration_units                in varchar2,
   p_activity_version_id           in number,
   p_status                        in varchar2,
   p_verified_by_id                in number,
   p_nth_information_category      in varchar2,
   p_nth_information1              in varchar2,
   p_nth_information2              in varchar2,
   p_nth_information3              in varchar2,
   p_nth_information4              in varchar2,
   p_nth_information5              in varchar2,
   p_nth_information6              in varchar2,
   p_nth_information7              in varchar2,
   p_nth_information8              in varchar2,
   p_nth_information9              in varchar2,
   p_nth_information10             in varchar2,
   p_nth_information11             in varchar2,
   p_nth_information12             in varchar2,
   p_nth_information13             in varchar2,
   p_nth_information15             in varchar2,
   p_nth_information16             in varchar2,
   p_nth_information17             in varchar2,
   p_nth_information18             in varchar2,
   p_nth_information19             in varchar2,
   p_nth_information20             in varchar2,
   p_org_id                        in number,
   p_object_version_number         in number,
   p_business_group_id             in number,
   p_nth_information14             in varchar2,
        p_customer_id         in number,
        p_organization_id     in number
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
  l_rec.nota_history_id                  := p_nota_history_id;
  l_rec.person_id                        := p_person_id;
  l_rec.contact_id                       := p_contact_id;
  l_rec.trng_title                       := p_trng_title;
  l_rec.provider                         := p_provider;
  l_rec.type                             := p_type;
  l_rec.centre                           := p_centre;
  l_rec.completion_date                  := p_completion_date;
  l_rec.award                            := p_award;
  l_rec.rating                           := p_rating;
  l_rec.duration                         := p_duration;
  l_rec.duration_units                   := p_duration_units;
  l_rec.activity_version_id              := p_activity_version_id;
  l_rec.status                           := p_status;
  l_rec.verified_by_id                   := p_verified_by_id;
  l_rec.nth_information_category         := p_nth_information_category;
  l_rec.nth_information1                 := p_nth_information1;
  l_rec.nth_information2                 := p_nth_information2;
  l_rec.nth_information3                 := p_nth_information3;
  l_rec.nth_information4                 := p_nth_information4;
  l_rec.nth_information5                 := p_nth_information5;
  l_rec.nth_information6                 := p_nth_information6;
  l_rec.nth_information7                 := p_nth_information7;
  l_rec.nth_information8                 := p_nth_information8;
  l_rec.nth_information9                 := p_nth_information9;
  l_rec.nth_information10                := p_nth_information10;
  l_rec.nth_information11                := p_nth_information11;
  l_rec.nth_information12                := p_nth_information12;
  l_rec.nth_information13                := p_nth_information13;
  l_rec.nth_information15                := p_nth_information15;
  l_rec.nth_information16                := p_nth_information16;
  l_rec.nth_information17                := p_nth_information17;
  l_rec.nth_information18                := p_nth_information18;
  l_rec.nth_information19                := p_nth_information19;
  l_rec.nth_information20                := p_nth_information20;
  l_rec.org_id                           := p_org_id;
  l_rec.object_version_number            := p_object_version_number;
  l_rec.business_group_id                := p_business_group_id;
  l_rec.nth_information14                := p_nth_information14;
  l_rec.customer_id         := p_customer_id;
  l_rec.organization_id        := p_organization_id;
  --
  -- Return the plsql record structure.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  Return(l_rec);
--
End convert_args;
--
end ota_nhs_shd;

/
