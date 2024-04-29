--------------------------------------------------------
--  DDL for Package Body OTA_TSR_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_TSR_SHD" as
/* $Header: ottsr01t.pkb 120.2 2005/08/08 23:27:40 ssur noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ota_tsr_shd.';  -- Global package name
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
  If (p_constraint_name = 'OTA_SUPPLIABLE_RESOURCES_FK1') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','5');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'OTA_SUPPLIABLE_RESOURCES_FK2') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','10');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'OTA_SUPPLIABLE_RESOURCES_PK') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','15');
    hr_utility.raise_error;
 -- ElsIf (p_constraint_name = 'OTA_TSR_ADDRESS_LINE_NULL') Then
    --hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    --hr_utility.set_message_token('PROCEDURE', l_proc);
    --hr_utility.set_message_token('STEP','20');
    --hr_utility.raise_error;
  ElsIf (p_constraint_name = 'OTA_TSR_CHECK_DATES_ORDER') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','25');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'OTA_TSR_CONSUMABLE_FLAG_CHK') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','30');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'OTA_TSR_CURRENCY_NOTNULL') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','35');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'OTA_TSR_CURRENCY_NULL') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','40');
    hr_utility.raise_error;
  --ElsIf (p_constraint_name = 'OTA_TSR_DELEGATES_NULL') Then
    --hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    --hr_utility.set_message_token('PROCEDURE', l_proc);
    --hr_utility.set_message_token('STEP','45');
    --hr_utility.raise_error;
  ElsIf (p_constraint_name = 'OTA_TSR_INTERNAL_FLAG_CHK') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','50');
    hr_utility.raise_error;
  --ElsIf (p_constraint_name = 'OTA_TSR_LOCATION_NULL') Then
    --hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    --hr_utility.set_message_token('PROCEDURE', l_proc);
    --hr_utility.set_message_token('STEP','55');
    --hr_utility.raise_error;
  ElsIf (p_constraint_name = 'OTA_TSR_NAME_PERSON_NOTNULL') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','60');
    hr_utility.raise_error;
  --ElsIf (p_constraint_name = 'OTA_TSR_NON_CONSUMABLE') Then
    --hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    --hr_utility.set_message_token('PROCEDURE', l_proc);
    --hr_utility.set_message_token('STEP','65');
    --hr_utility.raise_error;
  --ElsIf (p_constraint_name = 'OTA_TSR_PERSON_NULL') Then
    --hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    --hr_utility.set_message_token('PROCEDURE', l_proc);
    --hr_utility.set_message_token('STEP','70');
    --hr_utility.raise_error;
  --ElsIf (p_constraint_name = 'OTA_TSR_STOCKDATE_NOTNULL') Then
    --hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    --hr_utility.set_message_token('PROCEDURE', l_proc);
    --hr_utility.set_message_token('STEP','75');
    --hr_utility.raise_error;
  --ElsIf (p_constraint_name = 'OTA_TSR_STOCKDATE_NULL1') Then
    --hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    --hr_utility.set_message_token('PROCEDURE', l_proc);
    --hr_utility.set_message_token('STEP','80');
    --hr_utility.raise_error;
  --ElsIf (p_constraint_name = 'OTA_TSR_STOCKDATE_NULL2') Then
    --hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    --hr_utility.set_message_token('PROCEDURE', l_proc);
    --hr_utility.set_message_token('STEP','85');
    --hr_utility.raise_error;
  --ElsIf (p_constraint_name = 'OTA_TSR_STOCKDATE_NULL3') Then
    --hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    --hr_utility.set_message_token('PROCEDURE', l_proc);
    --hr_utility.set_message_token('STEP','90');
    --hr_utility.raise_error;
  --ElsIf (p_constraint_name = 'OTA_TSR_STOCK_NULL1') Then
    --hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    --hr_utility.set_message_token('PROCEDURE', l_proc);
    --hr_utility.set_message_token('STEP','95');
    --hr_utility.raise_error;
  --ElsIf (p_constraint_name = 'OTA_TSR_STOCK_NULL2') Then
    --hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    --hr_utility.set_message_token('PROCEDURE', l_proc);
    --hr_utility.set_message_token('STEP','96');
    --hr_utility.raise_error;
  Else
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','105');
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
  p_supplied_resource_id               in number,
  p_object_version_number              in number
  )      Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
	supplied_resource_id,
	vendor_id,
	business_group_id,
	resource_definition_id,
	consumable_flag,
	object_version_number,
	resource_type,
	start_date,
	comments,
	cost,
	cost_unit,
	currency_code,
	end_date,
	internal_address_line,
	lead_time,
	name,
	supplier_reference,
	tsr_information_category,
	tsr_information1,
	tsr_information2,
	tsr_information3,
	tsr_information4,
	tsr_information5,
	tsr_information6,
	tsr_information7,
	tsr_information8,
	tsr_information9,
	tsr_information10,
	tsr_information11,
	tsr_information12,
	tsr_information13,
	tsr_information14,
	tsr_information15,
	tsr_information16,
	tsr_information17,
	tsr_information18,
	tsr_information19,
	tsr_information20,
      training_center_id ,
      location_id	,
      trainer_id  ,
      special_instruction
    from	ota_suppliable_resources
    where	supplied_resource_id = p_supplied_resource_id;
--
  l_proc	varchar2(72)	:= g_package||'api_updating';
  l_fct_ret	boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (
	p_supplied_resource_id is null and
	p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (
	p_supplied_resource_id = g_old_rec.supplied_resource_id and
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
  p_supplied_resource_id               in number,
  p_object_version_number              in number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select 	supplied_resource_id,
	vendor_id,
	business_group_id,
	resource_definition_id,
	consumable_flag,
	object_version_number,
	resource_type,
	start_date,
	comments,
	cost,
	cost_unit,
	currency_code,
	end_date,
	internal_address_line,
	lead_time,
	name,
	supplier_reference,
	tsr_information_category,
	tsr_information1,
	tsr_information2,
	tsr_information3,
	tsr_information4,
	tsr_information5,
	tsr_information6,
	tsr_information7,
	tsr_information8,
	tsr_information9,
	tsr_information10,
	tsr_information11,
	tsr_information12,
	tsr_information13,
	tsr_information14,
	tsr_information15,
	tsr_information16,
	tsr_information17,
	tsr_information18,
	tsr_information19,
	tsr_information20,
      training_center_id,
      location_id,
      trainer_id,
      special_instruction
    from	ota_suppliable_resources
    where	supplied_resource_id = p_supplied_resource_id
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
    hr_utility.set_message_token('TABLE_NAME', 'ota_suppliable_resources');
    hr_utility.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
	(
	p_supplied_resource_id          in number,
	p_vendor_id                     in number,
	p_business_group_id             in number,
	p_resource_definition_id        in number,
	p_consumable_flag               in varchar2,
	p_object_version_number         in number,
	p_resource_type                 in varchar2,
	p_start_date                    in date,
	p_comments                      in varchar2,
	p_cost                          in number,
	p_cost_unit                     in varchar2,
	p_currency_code                 in varchar2,
	p_end_date                      in date,
	p_internal_address_line         in varchar2,
	p_lead_time                     in number,
	p_name                          in varchar2,
	p_supplier_reference            in varchar2,
	p_tsr_information_category      in varchar2,
	p_tsr_information1              in varchar2,
	p_tsr_information2              in varchar2,
	p_tsr_information3              in varchar2,
	p_tsr_information4              in varchar2,
	p_tsr_information5              in varchar2,
	p_tsr_information6              in varchar2,
	p_tsr_information7              in varchar2,
	p_tsr_information8              in varchar2,
	p_tsr_information9              in varchar2,
	p_tsr_information10             in varchar2,
	p_tsr_information11             in varchar2,
	p_tsr_information12             in varchar2,
	p_tsr_information13             in varchar2,
	p_tsr_information14             in varchar2,
	p_tsr_information15             in varchar2,
	p_tsr_information16             in varchar2,
	p_tsr_information17             in varchar2,
	p_tsr_information18             in varchar2,
	p_tsr_information19             in varchar2,
	p_tsr_information20             in varchar2,
      p_training_center_id            in number,
      p_location_id			  in number,
      p_trainer_id                    in number,
      p_special_instruction           in varchar2
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
  l_rec.supplied_resource_id             := p_supplied_resource_id;
  l_rec.vendor_id                        := p_vendor_id;
  l_rec.business_group_id                := p_business_group_id;
  l_rec.resource_definition_id           := p_resource_definition_id;
  l_rec.consumable_flag                  := p_consumable_flag;
  l_rec.object_version_number            := p_object_version_number;
  l_rec.resource_type                    := p_resource_type;
  l_rec.start_date                       := p_start_date;
  l_rec.comments                         := p_comments;
  l_rec.cost                             := p_cost;
  l_rec.cost_unit                        := p_cost_unit;
  l_rec.currency_code                    := p_currency_code;
  l_rec.end_date                         := p_end_date;
  l_rec.internal_address_line            := p_internal_address_line;
  l_rec.lead_time                        := p_lead_time;
  l_rec.name                             := p_name;
  l_rec.supplier_reference               := p_supplier_reference;
  l_rec.tsr_information_category         := p_tsr_information_category;
  l_rec.tsr_information1                 := p_tsr_information1;
  l_rec.tsr_information2                 := p_tsr_information2;
  l_rec.tsr_information3                 := p_tsr_information3;
  l_rec.tsr_information4                 := p_tsr_information4;
  l_rec.tsr_information5                 := p_tsr_information5;
  l_rec.tsr_information6                 := p_tsr_information6;
  l_rec.tsr_information7                 := p_tsr_information7;
  l_rec.tsr_information8                 := p_tsr_information8;
  l_rec.tsr_information9                 := p_tsr_information9;
  l_rec.tsr_information10                := p_tsr_information10;
  l_rec.tsr_information11                := p_tsr_information11;
  l_rec.tsr_information12                := p_tsr_information12;
  l_rec.tsr_information13                := p_tsr_information13;
  l_rec.tsr_information14                := p_tsr_information14;
  l_rec.tsr_information15                := p_tsr_information15;
  l_rec.tsr_information16                := p_tsr_information16;
  l_rec.tsr_information17                := p_tsr_information17;
  l_rec.tsr_information18                := p_tsr_information18;
  l_rec.tsr_information19                := p_tsr_information19;
  l_rec.tsr_information20                := p_tsr_information20;
  l_rec.training_center_id               := p_training_center_id;
  l_rec.location_id			     := p_location_id;
  l_rec.trainer_id                       := p_trainer_id;
  l_rec.special_instruction              := p_special_instruction;
  --
  -- Return the plsql record structure.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  Return(l_rec);
--
End convert_args;
--
end ota_tsr_shd;

/
