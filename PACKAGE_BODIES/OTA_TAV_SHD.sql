--------------------------------------------------------
--  DDL for Package Body OTA_TAV_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_TAV_SHD" as
/* $Header: ottav01t.pkb 120.2.12010000.3 2009/08/11 13:44:21 smahanka ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ota_tav_shd.';  -- Global package name
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
            (p_constraint_name in varchar2) Is
--
  l_proc 	varchar2(72) := g_package||'constraint_error';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (p_constraint_name = 'OTA_ACTIVITY_VERSIONS_FK1') Then
    fnd_message.set_name('OTA', 'OTA_13292_TAV_NO_TAD');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'OTA_ACTIVITY_VERSIONS_FK2') Then
    fnd_message.set_name('OTA', 'OTA_13293_TAV_NO_SUP');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'OTA_ACTIVITY_VERSIONS_FK3') Then
    fnd_message.set_name('OTA', 'OTA_13294_TAV_NO_DEV');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'OTA_TAV_MAX_INTERNAL_MAX_ORDER') Then
    fnd_message.set_name('OTA', 'OTA_13385_TAV_MAX_INT_ATTS');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'OTA_TAV_MAX_INT_ATTS_POSITIVE') Then
    fnd_message.set_name('OTA', 'OTA_13385_TAV_MAX_INT_ATTS');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'OTA_TAV_MAX_ATTENDEES_POSITIVE') Then
    fnd_message.set_name('OTA', 'OTA_13296_GEN_MINMAX_POS');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'OTA_TAV_MAX_OCCUR_POSITIVE') Then
    fnd_message.set_name('OTA', 'OTA_13296_GEN_MINMAX_POS');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'OTA_TAV_MIN_ATTENDEES_POSITIVE') Then
    fnd_message.set_name('OTA', 'OTA_13296_GEN_MINMAX_POS');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'OTA_TAV_MIN_MAX_ORDER') Then
    fnd_message.set_name('OTA', 'OTA_13298_GEN_MINMAX_ORDER');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'OTA_TAV_EXPENSES_ALLOWED_CHK') Then
    fnd_message.set_name('OTA', 'OTA_13204_GEN_INVALID_LOOKUP');
    fnd_message.set_token('FIELD','EXPENSES_ALLOWED');
    fnd_message.set_token('LOOKUP_TYPE','YES_NO');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'OTA_TAV_VERS_START_END_ORDER') Then
    fnd_message.set_name('OTA', 'OTA_13312_GEN_DATE_ORDER');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'OTA_ACTIVITY_VERSIONS_PK') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','5');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'OTA_ACTIVITY_VERSIONS_UK2') Then
    fnd_message.set_name('OTA', 'OTA_13301_TAV_DUPLICATE');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'OTA_ACTIVITY_VERSIONS_UK4') Then
    fnd_message.set_name('OTA', 'OTA_13694_TAV_DUPLICATE');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'OTA_ACTIVITY_VERSIONS_UK5') Then
    fnd_message.set_name('OTA', 'OTA_TAV_DUPLICATE_RCO');
    fnd_message.raise_error;
  Else
    fnd_message.set_name('OTA','OTA_GEN_UNKN_CONSTRAINT');
    fnd_message.set_token('CONSTRAINT',p_constraint_name);
    fnd_message.raise_error;
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
  p_activity_version_id                in number,
  p_object_version_number              in number
  )      Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
		activity_version_id,
	activity_id,
	superseded_by_act_version_id,
	developer_organization_id,
	controlling_person_id,
	object_version_number,
	version_name,
	comments,
	description,
	duration,
	duration_units,
	end_date,
	intended_audience,
	language_id,
	maximum_attendees,
	minimum_attendees,
	objectives,
	start_date,
	success_criteria,
	user_status,
      vendor_id,
      actual_cost,
      budget_cost,
      budget_currency_code,
      expenses_allowed,
      professional_credit_type,
      professional_credits,
      maximum_internal_attendees,
	tav_information_category,
	tav_information1,
	tav_information2,
	tav_information3,
	tav_information4,
	tav_information5,
	tav_information6,
	tav_information7,
	tav_information8,
	tav_information9,
	tav_information10,
	tav_information11,
	tav_information12,
	tav_information13,
	tav_information14,
	tav_information15,
	tav_information16,
	tav_information17,
	tav_information18,
	tav_information19,
	tav_information20,
      inventory_item_id,
      organization_id,
      rco_id,
      version_code,
      business_group_id,
      data_source
      ,competency_update_level,
      eres_enabled

    from	ota_activity_versions
    where	activity_version_id = p_activity_version_id;
--
  l_proc	varchar2(72)	:= g_package||'api_updating';
  l_fct_ret	boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (
	p_activity_version_id is null and
	p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (
	p_activity_version_id = g_old_rec.activity_version_id and
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
  p_activity_version_id                in number,
  p_object_version_number              in number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select 	activity_version_id,
	activity_id,
	superseded_by_act_version_id,
	developer_organization_id,
	controlling_person_id,
	object_version_number,
	version_name,
	comments,
	description,
	duration,
	duration_units,
	end_date,
	intended_audience,
	language_id,
	maximum_attendees,
	minimum_attendees,
	objectives,
	start_date,
	success_criteria,
	user_status,
      vendor_id,
      actual_cost,
      budget_cost,
      budget_currency_code,
      expenses_allowed,
      professional_credit_type,
      professional_credits,
      maximum_internal_attendees,
	tav_information_category,
	tav_information1,
	tav_information2,
	tav_information3,
	tav_information4,
	tav_information5,
	tav_information6,
	tav_information7,
	tav_information8,
	tav_information9,
	tav_information10,
	tav_information11,
	tav_information12,
	tav_information13,
	tav_information14,
	tav_information15,
	tav_information16,
	tav_information17,
	tav_information18,
	tav_information19,
	tav_information20,
      inventory_item_id,
      organization_id,
      rco_id,
      version_code,
      business_group_id,
      data_source
      ,competency_update_level,
      eres_enabled

    from	ota_activity_versions
    where	activity_version_id = p_activity_version_id
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
    hr_utility.set_message_token('TABLE_NAME', 'ota_activity_versions');
    hr_utility.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
	(
	p_activity_version_id           in number,
	p_activity_id                   in number,
	p_superseded_by_act_version_id  in number,
	p_developer_organization_id     in number,
	p_controlling_person_id         in number,
	p_object_version_number         in number,
	p_version_name                  in varchar2,
	p_comments                      in varchar2,
	p_description                   in varchar2,
	p_duration                      in number,
	p_duration_units                in varchar2,
	p_end_date                      in date,
	p_intended_audience             in varchar2,
	p_language_id                   in number,
	p_maximum_attendees             in number,
	p_minimum_attendees             in number,
	p_objectives                    in varchar2,
	p_start_date                    in date,
	p_success_criteria              in varchar2,
	p_user_status                   in varchar2,
      p_vendor_id                     in number,
      p_actual_cost                   in number,
      p_budget_cost                   in number,
      p_budget_currency_code          in varchar2,
      p_expenses_allowed              in varchar2,
      p_professional_credit_type      in varchar2,
      p_professional_credits          in number,
      p_maximum_internal_attendees    in number,
	p_tav_information_category      in varchar2,
	p_tav_information1              in varchar2,
	p_tav_information2              in varchar2,
	p_tav_information3              in varchar2,
	p_tav_information4              in varchar2,
	p_tav_information5              in varchar2,
	p_tav_information6              in varchar2,
	p_tav_information7              in varchar2,
	p_tav_information8              in varchar2,
	p_tav_information9              in varchar2,
	p_tav_information10             in varchar2,
	p_tav_information11             in varchar2,
	p_tav_information12             in varchar2,
	p_tav_information13             in varchar2,
	p_tav_information14             in varchar2,
	p_tav_information15             in varchar2,
	p_tav_information16             in varchar2,
	p_tav_information17             in varchar2,
	p_tav_information18             in varchar2,
	p_tav_information19             in varchar2,
	p_tav_information20             in varchar2,
      p_inventory_item_id  		  in number,
      p_organization_id  		  in number,
      p_rco_id				  in number,
      p_version_code          in varchar2,
      p_business_group_id              in number,
      p_data_source           in varchar2
      ,p_competency_update_level        in     varchar2,
      p_eres_enabled          in varchar2

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
  l_rec.activity_version_id              := p_activity_version_id;
  l_rec.activity_id                      := p_activity_id;
  l_rec.superseded_by_act_version_id     := p_superseded_by_act_version_id;
  l_rec.developer_organization_id        := p_developer_organization_id;
  l_rec.controlling_person_id            := p_controlling_person_id;
  l_rec.object_version_number            := p_object_version_number;
  l_rec.version_name                     := p_version_name;
  l_rec.comments                         := p_comments;
  l_rec.description                      := p_description;
  l_rec.duration                         := p_duration;
  l_rec.duration_units                   := p_duration_units;
  l_rec.end_date                         := p_end_date;
  l_rec.intended_audience                := p_intended_audience;
  l_rec.language_id                      := p_language_id;
  l_rec.maximum_attendees                := p_maximum_attendees;
  l_rec.minimum_attendees                := p_minimum_attendees;
  l_rec.objectives                       := p_objectives;
  l_rec.start_date                       := p_start_date;
  l_rec.success_criteria                 := p_success_criteria;
  l_rec.user_status                      := p_user_status;
  l_rec.vendor_id                        := p_vendor_id;
  l_rec.actual_cost                      := p_actual_cost;
  l_rec.budget_cost                      := p_budget_cost;
  l_rec.budget_currency_code             := p_budget_currency_code;
  l_rec.expenses_allowed                 := p_expenses_allowed;
  l_rec.professional_credit_type         := p_professional_credit_type;
  l_rec.professional_credits             := p_professional_credits;
  l_rec.maximum_internal_attendees       := p_maximum_internal_attendees;
  l_rec.tav_information_category         := p_tav_information_category;
  l_rec.tav_information1                 := p_tav_information1;
  l_rec.tav_information2                 := p_tav_information2;
  l_rec.tav_information3                 := p_tav_information3;
  l_rec.tav_information4                 := p_tav_information4;
  l_rec.tav_information5                 := p_tav_information5;
  l_rec.tav_information6                 := p_tav_information6;
  l_rec.tav_information7                 := p_tav_information7;
  l_rec.tav_information8                 := p_tav_information8;
  l_rec.tav_information9                 := p_tav_information9;
  l_rec.tav_information10                := p_tav_information10;
  l_rec.tav_information11                := p_tav_information11;
  l_rec.tav_information12                := p_tav_information12;
  l_rec.tav_information13                := p_tav_information13;
  l_rec.tav_information14                := p_tav_information14;
  l_rec.tav_information15                := p_tav_information15;
  l_rec.tav_information16                := p_tav_information16;
  l_rec.tav_information17                := p_tav_information17;
  l_rec.tav_information18                := p_tav_information18;
  l_rec.tav_information19                := p_tav_information19;
  l_rec.tav_information20                := p_tav_information20;
  l_rec.inventory_item_id		     := p_inventory_item_id;
  l_rec.organization_id			     := p_organization_id;
  l_rec.rco_id			     	     := p_rco_id;
  l_rec.version_code                 := p_version_code;
  l_rec.business_group_id            := p_business_group_id;
  l_rec.data_source                  := p_data_source;
   l_rec.competency_update_level          := p_competency_update_level  ;
  l_rec.eres_enabled                 := p_eres_enabled  ;

  --
  -- Return the plsql record structure.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  Return(l_rec);
--
End convert_args;
--
end ota_tav_shd;

/
