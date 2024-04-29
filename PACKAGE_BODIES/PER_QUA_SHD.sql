--------------------------------------------------------
--  DDL for Package Body PER_QUA_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_QUA_SHD" as
/* $Header: pequarhi.pkb 120.0.12010000.2 2008/08/06 09:31:13 ubhat ship $ */
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  per_qua_shd.';  -- Global package name
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
  If (p_constraint_name = 'PER_QUALIFICATIONS_FK1') Then
    hr_utility.set_message(801, 'HR_51850_QUA_ATT_ID_FK');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'PER_QUALIFICATIONS_FK2') Then
    hr_utility.set_message(801, 'HR_51851_QUA_QUAL_TYPE_ID_FK');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'PER_QUALIFICATIONS_FK3') Then
    hr_utility.set_message(801, 'HR_51852_QUA_BUS_GRP_ID_FK');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'PER_QUA_CHK_DATES') Then
    hr_utility.set_message(801, 'HR_51853_QUA_DATE_INV');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'PER_QUALIFICATIONS_PK') Then
    hr_utility.set_message(801, 'HR_51854_QUA_QUAL_ID_PK');
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
  p_qualification_id                   in number,
  p_object_version_number              in number
  )      Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
	qualification_id,
	business_group_id,
	object_version_number,
	person_id,
	title,
	grade_attained,
	status,
	awarded_date,
	fee,
	fee_currency,
	training_completed_amount,
	reimbursement_arrangements,
	training_completed_units,
	total_training_amount,
	start_date,
	end_date,
	license_number,
	expiry_date,
	license_restrictions,
	projected_completion_date,
	awarding_body,
	tuition_method,
	group_ranking,
	comments,
	qualification_type_id,
	attendance_id,
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
	qua_information_category,
	qua_information1,
	qua_information2,
	qua_information3,
	qua_information4,
	qua_information5,
	qua_information6,
	qua_information7,
	qua_information8,
	qua_information9,
	qua_information10,
	qua_information11,
	qua_information12,
	qua_information13,
	qua_information14,
	qua_information15,
	qua_information16,
	qua_information17,
	qua_information18,
	qua_information19,
	qua_information20,
        professional_body_name,
        membership_number,
        membership_category,
        subscription_payment_method,
        party_id
    from	per_qualifications
    where	qualification_id = p_qualification_id;
--
  l_proc	varchar2(72)	:= g_package||'api_updating';
  l_fct_ret	boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (
	p_qualification_id is null and
	p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (
	p_qualification_id = g_old_rec.qualification_id and
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
  p_qualification_id                   in number,
  p_object_version_number              in number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select 	qualification_id,
	business_group_id,
	object_version_number,
	person_id,
	title,
	grade_attained,
	status,
	awarded_date,
	fee,
	fee_currency,
	training_completed_amount,
	reimbursement_arrangements,
	training_completed_units,
	total_training_amount,
	start_date,
	end_date,
	license_number,
	expiry_date,
	license_restrictions,
	projected_completion_date,
	awarding_body,
	tuition_method,
	group_ranking,
	comments,
	qualification_type_id,
	attendance_id,
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
	qua_information_category,
	qua_information1,
	qua_information2,
	qua_information3,
	qua_information4,
	qua_information5,
	qua_information6,
	qua_information7,
	qua_information8,
	qua_information9,
	qua_information10,
	qua_information11,
	qua_information12,
	qua_information13,
	qua_information14,
	qua_information15,
	qua_information16,
	qua_information17,
	qua_information18,
	qua_information19,
	qua_information20,
        professional_body_name,
        membership_number,
        membership_category,
        subscription_payment_method,
        party_id
    from	per_qualifications
    where	qualification_id = p_qualification_id
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
    hr_utility.set_message_token('TABLE_NAME', 'per_qualifications');
    hr_utility.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
	(
	p_qualification_id              in number,
	p_business_group_id             in number,
	p_object_version_number         in number,
	p_person_id                     in number,
	p_title                         in varchar2,
	p_grade_attained                in varchar2,
	p_status                        in varchar2,
	p_awarded_date                  in date,
	p_fee                           in number,
	p_fee_currency                  in varchar2,
	p_training_completed_amount     in number,
	p_reimbursement_arrangements    in varchar2,
	p_training_completed_units      in varchar2,
	p_total_training_amount         in number,
	p_start_date                    in date,
	p_end_date                      in date,
	p_license_number                in varchar2,
	p_expiry_date                   in date,
	p_license_restrictions          in varchar2,
	p_projected_completion_date     in date,
	p_awarding_body                 in varchar2,
	p_tuition_method                in varchar2,
	p_group_ranking                 in varchar2,
	p_comments                      in varchar2,
	p_qualification_type_id         in number,
	p_attendance_id                 in number,
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
	p_qua_information_category            in varchar2,
	p_qua_information1                    in varchar2,
	p_qua_information2                    in varchar2,
	p_qua_information3                    in varchar2,
	p_qua_information4                    in varchar2,
	p_qua_information5                    in varchar2,
	p_qua_information6                    in varchar2,
	p_qua_information7                    in varchar2,
	p_qua_information8                    in varchar2,
	p_qua_information9                    in varchar2,
	p_qua_information10                   in varchar2,
	p_qua_information11                   in varchar2,
	p_qua_information12                   in varchar2,
	p_qua_information13                   in varchar2,
	p_qua_information14                   in varchar2,
	p_qua_information15                   in varchar2,
	p_qua_information16                   in varchar2,
	p_qua_information17                   in varchar2,
	p_qua_information18                   in varchar2,
	p_qua_information19                   in varchar2,
	p_qua_information20                   in varchar2,
	p_professional_body_name        in varchar2,
        p_membership_number             in varchar2,
        p_membership_category           in varchar2,
        p_subscription_payment_method   in varchar2,
        p_party_id                      in number  default null
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
  l_rec.qualification_id                 := p_qualification_id;
  l_rec.business_group_id                := p_business_group_id;
  l_rec.object_version_number            := p_object_version_number;
  l_rec.person_id                        := p_person_id;
  l_rec.title                            := p_title;
  l_rec.grade_attained                   := p_grade_attained;
  l_rec.status                           := p_status;
  l_rec.awarded_date                     := p_awarded_date;
  l_rec.fee                              := p_fee;
  l_rec.fee_currency                     := p_fee_currency;
  l_rec.training_completed_amount        := p_training_completed_amount;
  l_rec.reimbursement_arrangements       := p_reimbursement_arrangements;
  l_rec.training_completed_units         := p_training_completed_units;
  l_rec.total_training_amount            := p_total_training_amount;
  l_rec.start_date                       := p_start_date;
  l_rec.end_date                         := p_end_date;
  l_rec.license_number                   := p_license_number;
  l_rec.expiry_date                      := p_expiry_date;
  l_rec.license_restrictions             := p_license_restrictions;
  l_rec.projected_completion_date        := p_projected_completion_date;
  l_rec.awarding_body                    := p_awarding_body;
  l_rec.tuition_method                   := p_tuition_method;
  l_rec.group_ranking                    := p_group_ranking;
  l_rec.comments                         := p_comments;
  l_rec.qualification_type_id            := p_qualification_type_id;
  l_rec.attendance_id                    := p_attendance_id;
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
  l_rec.qua_information_category               := p_qua_information_category;
  l_rec.qua_information1                       := p_qua_information1;
  l_rec.qua_information2                       := p_qua_information2;
  l_rec.qua_information3                       := p_qua_information3;
  l_rec.qua_information4                       := p_qua_information4;
  l_rec.qua_information5                       := p_qua_information5;
  l_rec.qua_information6                       := p_qua_information6;
  l_rec.qua_information7                       := p_qua_information7;
  l_rec.qua_information8                       := p_qua_information8;
  l_rec.qua_information9                       := p_qua_information9;
  l_rec.qua_information10                      := p_qua_information10;
  l_rec.qua_information11                      := p_qua_information11;
  l_rec.qua_information12                      := p_qua_information12;
  l_rec.qua_information13                      := p_qua_information13;
  l_rec.qua_information14                      := p_qua_information14;
  l_rec.qua_information15                      := p_qua_information15;
  l_rec.qua_information16                      := p_qua_information16;
  l_rec.qua_information17                      := p_qua_information17;
  l_rec.qua_information18                      := p_qua_information18;
  l_rec.qua_information19                      := p_qua_information19;
  l_rec.qua_information20                      := p_qua_information20;
  l_rec.professional_body_name           := p_professional_body_name;
  l_rec.membership_number                := p_membership_number;
  l_rec.membership_category              := p_membership_category;
  l_rec.subscription_payment_method      := p_subscription_payment_method;
  l_rec.party_id                         := p_party_id;
  --
  -- Return the plsql record structure.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  Return(l_rec);
--
End convert_args;
--
end per_qua_shd;

/
