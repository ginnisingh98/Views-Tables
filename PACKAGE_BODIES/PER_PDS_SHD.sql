--------------------------------------------------------
--  DDL for Package Body PER_PDS_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_PDS_SHD" as
/* $Header: pepdsrhi.pkb 120.7.12010000.2 2009/07/15 10:28:27 pchowdav ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  per_pds_shd.';  -- Global package name
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
  If (p_constraint_name = 'PER_PERIODS_OF_SERVICE_FK1') Then
    --
    -- The business_group_id is invalid
    --
    hr_utility.set_message(801, 'HR_7208_API_BUS_GRP_INVALID');
    --
  ElsIf (p_constraint_name = 'PER_PERIODS_OF_SERVICE_PK') Then
    --
    -- The primary key is not unique
    --
    hr_utility.set_message(801, 'HR_7391_ASG_INV_PERIOD_OF_SERV');
    --
  elsif (p_constraint_name = 'SSP_PDS_SSP_WEEKS_NATURAL_NUM') then
    --
    -- Prior_employment_SSP_weeks must be an integer greater than zero
    --
    hr_utility.set_message (801,'HR_51100_PDS_SSP_WEEKS_NATURAL');
    --
  elsif (p_constraint_name = 'SSP_PDS_SSP_PAID_TO_PRE_HIRE') then
    --
    -- Prior_employment_SSP_paid_to must be before date_start
    --
    hr_utility.set_message (801,'HR_51102_PDS_SSP_PAID_PRE_HIRE');
    --
  elsif (p_constraint_name = 'SSP_PDS_SSP1L_DETAILS') then
    --
    -- Prior_employment... fields are mutually inclusive
    --
    hr_utility.set_message (801,'HR_51101_PDS_SSP1L_DETAILS');
    --
  elsif (p_constraint_name = 'PER_ASSIGNMENTS_F_FK51') then
    --
    -- Assignment rows must be deleted before period of service
    --
    hr_utility.set_message (801,'HR_51392_PDS_DEL_ASG_FIRST');
    --
  Else
    --
    -- A constraint was added after this code was delivered and is not
    -- handled by this procedure.
    --
    hr_utility.set_message(801, 'HR_7877_API_INVALID_CONSTRAINT');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('CONSTRAINT_NAME', p_constraint_name);
    --
  End If;
  --
  hr_utility.raise_error;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End constraint_error;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< api_updating >-----------------------------|
-- ----------------------------------------------------------------------------
Function api_updating
  (
  p_period_of_service_id               in number,
  p_object_version_number              in number
  )      Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
		period_of_service_id,
	business_group_id,
	termination_accepted_person_id,
	person_id,
	date_start,
	accepted_termination_date,
	actual_termination_date,
	comments,
	final_process_date,
	last_standard_process_date,
	leaving_reason,
	notified_termination_date,
	projected_termination_date,
        adjusted_svc_date,
	request_id,
	program_application_id,
	program_id,
	program_update_date,
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
	prior_employment_ssp_weeks,
	prior_employment_ssp_paid_to,
	pds_information_category,
	pds_information1,
	pds_information2,
	pds_information3,
	pds_information4,
	pds_information5,
	pds_information6,
	pds_information7,
	pds_information8,
	pds_information9,
	pds_information10,
	pds_information11,
	pds_information12,
	pds_information13,
	pds_information14,
	pds_information15,
	pds_information16,
	pds_information17,
	pds_information18,
	pds_information19,
	pds_information20,
	pds_information21,
	pds_information22,
	pds_information23,
	pds_information24,
	pds_information25,
	pds_information26,
	pds_information27,
	pds_information28,
	pds_information29,
	pds_information30
    from	per_periods_of_service pds
    where	pds.period_of_service_id = p_period_of_service_id;
--
  l_proc	varchar2(72)	:= g_package||'api_updating';
  l_fct_ret	boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (
	p_period_of_service_id is null and
	p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (
	p_period_of_service_id = g_old_rec.period_of_service_id and
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
  p_period_of_service_id               in number,
  p_object_version_number              in number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select
        period_of_service_id,
	business_group_id,
	termination_accepted_person_id,
	person_id,
	date_start,
	accepted_termination_date,
	actual_termination_date,
	comments,
	final_process_date,
	last_standard_process_date,
	leaving_reason,
	notified_termination_date,
        projected_termination_date,
        adjusted_svc_date,
	request_id,
	program_application_id,
	program_id,
	program_update_date,
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
	prior_employment_ssp_weeks,
	prior_employment_ssp_paid_to,
	pds_information_category,
	pds_information1,
	pds_information2,
	pds_information3,
	pds_information4,
	pds_information5,
	pds_information6,
	pds_information7,
	pds_information8,
	pds_information9,
	pds_information10,
	pds_information11,
	pds_information12,
	pds_information13,
	pds_information14,
	pds_information15,
	pds_information16,
	pds_information17,
	pds_information18,
	pds_information19,
	pds_information20,
	pds_information21,
	pds_information22,
	pds_information23,
	pds_information24,
	pds_information25,
	pds_information26,
	pds_information27,
	pds_information28,
	pds_information29,
	pds_information30
    from	per_periods_of_service pds
    where	pds.period_of_service_id = p_period_of_service_id
    for	update nowait;
--
  l_proc	varchar2(72) := g_package||'lck';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 1);
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc,
     p_argument       => 'period_of_service_id',
     p_argument_value => p_period_of_service_id);
  --
  hr_utility.set_location(l_proc, 3);
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc,
     p_argument       => 'object_version_number',
     p_argument_value => p_object_version_number);
  --
  hr_utility.set_location(l_proc, 7);
  --
  Open  C_Sel1;
  --
  hr_utility.set_location(l_proc, 10);
  --
  Fetch C_Sel1 Into g_old_rec;
  --
  hr_utility.set_location(l_proc, 15);
  --
  If C_Sel1%notfound then
    --
    hr_utility.set_location(l_proc, 20);
    --
    Close C_Sel1;
    --
    -- The primary key is invalid therefore we must error
    --
    hr_utility.set_message(801, 'HR_7220_INVALID_PRIMARY_KEY');
    hr_utility.raise_error;
  End If;
  --
  hr_utility.set_location(l_proc, 25);
  --
  Close C_Sel1;
  --
  If (p_object_version_number <> g_old_rec.object_version_number) Then
        hr_utility.set_location(l_proc, 30);
        hr_utility.set_message(801, 'HR_7155_OBJECT_INVALID');
        hr_utility.raise_error;
      End If;
--
  hr_utility.set_location(' Leaving:'||l_proc, 35);
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
    hr_utility.set_message_token('TABLE_NAME', 'per_periods_of_service');
    hr_utility.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
	(
	p_period_of_service_id          in number,
	p_business_group_id             in number,
	p_termination_accepted_person   in number,
	p_person_id                     in number,
	p_date_start                    in date,
	p_accepted_termination_date     in date,
	p_actual_termination_date       in date,
	p_comments                      in varchar2,
	p_final_process_date            in date,
	p_last_standard_process_date    in date,
	p_leaving_reason                in varchar2,
	p_notified_termination_date     in date,
	p_projected_termination_date    in date,
        p_adjusted_svc_date             in date,
	p_request_id                    in number,
	p_program_application_id        in number,
	p_program_id                    in number,
	p_program_update_date           in date,
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
	p_object_version_number         in number,
	p_prior_employment_ssp_weeks	in number,
	p_prior_employment_ssp_paid_to	in date,
	p_pds_information_category      in varchar2,
	p_pds_information1              in varchar2,
	p_pds_information2              in varchar2,
	p_pds_information3              in varchar2,
	p_pds_information4              in varchar2,
	p_pds_information5              in varchar2,
	p_pds_information6              in varchar2,
	p_pds_information7              in varchar2,
	p_pds_information8              in varchar2,
	p_pds_information9              in varchar2,
	p_pds_information10             in varchar2,
	p_pds_information11             in varchar2,
	p_pds_information12             in varchar2,
	p_pds_information13             in varchar2,
	p_pds_information14             in varchar2,
	p_pds_information15             in varchar2,
	p_pds_information16             in varchar2,
	p_pds_information17             in varchar2,
	p_pds_information18             in varchar2,
	p_pds_information19             in varchar2,
	p_pds_information20             in varchar2,
	p_pds_information21             in varchar2,
	p_pds_information22             in varchar2,
	p_pds_information23             in varchar2,
	p_pds_information24             in varchar2,
	p_pds_information25             in varchar2,
	p_pds_information26             in varchar2,
	p_pds_information27             in varchar2,
	p_pds_information28             in varchar2,
	p_pds_information29             in varchar2,
	p_pds_information30             in varchar2
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
  l_rec.period_of_service_id             := p_period_of_service_id;
  l_rec.business_group_id                := p_business_group_id;
  l_rec.termination_accepted_person_id   := p_termination_accepted_person;
  l_rec.person_id                        := p_person_id;
  l_rec.date_start                       := p_date_start;
  l_rec.accepted_termination_date        := p_accepted_termination_date;
  l_rec.actual_termination_date          := p_actual_termination_date;
  l_rec.comments                         := p_comments;
  l_rec.final_process_date               := p_final_process_date;
  l_rec.last_standard_process_date       := p_last_standard_process_date;
  l_rec.leaving_reason                   := p_leaving_reason;
  l_rec.notified_termination_date        := p_notified_termination_date;
  l_rec.projected_termination_date       := p_projected_termination_date;
  l_rec.adjusted_svc_date                := p_adjusted_svc_date;
  l_rec.request_id                       := p_request_id;
  l_rec.program_application_id           := p_program_application_id;
  l_rec.program_id                       := p_program_id;
  l_rec.program_update_date              := p_program_update_date;
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
  l_rec.object_version_number            := p_object_version_number;
  l_rec.prior_employment_ssp_weeks       := p_prior_employment_ssp_weeks;
  l_rec.prior_employment_ssp_paid_to     := p_prior_employment_ssp_paid_to;
  l_rec.pds_information_category         := p_pds_information_category;
  l_rec.pds_information1                 := p_pds_information1;
  l_rec.pds_information2                 := p_pds_information2;
  l_rec.pds_information3                 := p_pds_information3;
  l_rec.pds_information4                 := p_pds_information4;
  l_rec.pds_information5                 := p_pds_information5;
  l_rec.pds_information6                 := p_pds_information6;
  l_rec.pds_information7                 := p_pds_information7;
  l_rec.pds_information8                 := p_pds_information8;
  l_rec.pds_information9                 := p_pds_information9;
  l_rec.pds_information10                := p_pds_information10;
  l_rec.pds_information11                := p_pds_information11;
  l_rec.pds_information12                := p_pds_information12;
  l_rec.pds_information13                := p_pds_information13;
  l_rec.pds_information14                := p_pds_information14;
  l_rec.pds_information15                := p_pds_information15;
  l_rec.pds_information16                := p_pds_information16;
  l_rec.pds_information17                := p_pds_information17;
  l_rec.pds_information18                := p_pds_information18;
  l_rec.pds_information19                := p_pds_information19;
  l_rec.pds_information20                := p_pds_information20;
  l_rec.pds_information21                := p_pds_information21;
  l_rec.pds_information22                := p_pds_information22;
  l_rec.pds_information23                := p_pds_information23;
  l_rec.pds_information24                := p_pds_information24;
  l_rec.pds_information25                := p_pds_information25;
  l_rec.pds_information26                := p_pds_information26;
  l_rec.pds_information27                := p_pds_information27;
  l_rec.pds_information28                := p_pds_information28;
  l_rec.pds_information29                := p_pds_information29;
  l_rec.pds_information30                := p_pds_information30;
  --
  -- Return the plsql record structure.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  Return(l_rec);
--
End convert_args;
--
end per_pds_shd;

/
