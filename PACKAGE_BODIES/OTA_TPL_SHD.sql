--------------------------------------------------------
--  DDL for Package Body OTA_TPL_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_TPL_SHD" as
/* $Header: ottpl01t.pkb 115.2 99/07/16 00:55:57 porting ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ota_tpl_shd.';  -- Global package name
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
  If (p_constraint_name = 'OTA_PRICE_LISTS_FK1') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','5');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'OTA_PRICE_LISTS_PK') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','10');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'OTA_PRICE_LISTS_UK2') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','15');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'OTA_TPL_CHECK_DATES_ORDER') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','20');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'OTA_TPL_DEFAULT_FLAG_CHK') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','25');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'OTA_TPL_PRICE_LIST_TYPE_CHK') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','30');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'OTA_TPL_UNIT_PRICE_NOTNULL') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','35');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'OTA_TPL_UNIT_PRICE_NULL') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','40');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'OTA_TPL_UNIT_TYPE_NOTNULL') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','45');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'OTA_TPL_UNIT_TYPE_NULL') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','50');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'UNIQUE_NAME_WITHIN_BGROUP') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','55');
    hr_utility.raise_error;
  Else
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','60');
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
  p_price_list_id                      in number,
  p_object_version_number              in number
  )      Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
		price_list_id,
	business_group_id,
	currency_code,
	default_flag,
	name,
	object_version_number,
	price_list_type,
	start_date,
	comments,
	description,
	end_date,
	single_unit_price,
	training_unit_type,
	tpl_information_category,
	tpl_information1,
	tpl_information2,
	tpl_information3,
	tpl_information4,
	tpl_information5,
	tpl_information6,
	tpl_information7,
	tpl_information8,
	tpl_information9,
	tpl_information10,
	tpl_information11,
	tpl_information12,
	tpl_information13,
	tpl_information14,
	tpl_information15,
	tpl_information16,
	tpl_information17,
	tpl_information18,
	tpl_information19,
	tpl_information20
    from	ota_price_lists
    where	price_list_id = p_price_list_id;
--
  l_proc	varchar2(72)	:= g_package||'api_updating';
  l_fct_ret	boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (
	p_price_list_id is null and
	p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (
	p_price_list_id = g_old_rec.price_list_id and
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
  p_price_list_id                      in number,
  p_object_version_number              in number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select 	price_list_id,
	business_group_id,
	currency_code,
	default_flag,
	name,
	object_version_number,
	price_list_type,
	start_date,
	comments,
	description,
	end_date,
	single_unit_price,
	training_unit_type,
	tpl_information_category,
	tpl_information1,
	tpl_information2,
	tpl_information3,
	tpl_information4,
	tpl_information5,
	tpl_information6,
	tpl_information7,
	tpl_information8,
	tpl_information9,
	tpl_information10,
	tpl_information11,
	tpl_information12,
	tpl_information13,
	tpl_information14,
	tpl_information15,
	tpl_information16,
	tpl_information17,
	tpl_information18,
	tpl_information19,
	tpl_information20
    from	ota_price_lists
    where	price_list_id = p_price_list_id
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
    hr_utility.set_message_token('TABLE_NAME', 'ota_price_lists');
    hr_utility.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
	(
	p_price_list_id                 in number,
	p_business_group_id             in number,
	p_currency_code                 in varchar2,
	p_default_flag                  in varchar2,
	p_name                          in varchar2,
	p_object_version_number         in number,
	p_price_list_type               in varchar2,
	p_start_date                    in date,
	p_comments                      in varchar2,
	p_description                   in varchar2,
	p_end_date                      in date,
	p_single_unit_price             in number,
	p_training_unit_type            in varchar2,
	p_tpl_information_category      in varchar2,
	p_tpl_information1              in varchar2,
	p_tpl_information2              in varchar2,
	p_tpl_information3              in varchar2,
	p_tpl_information4              in varchar2,
	p_tpl_information5              in varchar2,
	p_tpl_information6              in varchar2,
	p_tpl_information7              in varchar2,
	p_tpl_information8              in varchar2,
	p_tpl_information9              in varchar2,
	p_tpl_information10             in varchar2,
	p_tpl_information11             in varchar2,
	p_tpl_information12             in varchar2,
	p_tpl_information13             in varchar2,
	p_tpl_information14             in varchar2,
	p_tpl_information15             in varchar2,
	p_tpl_information16             in varchar2,
	p_tpl_information17             in varchar2,
	p_tpl_information18             in varchar2,
	p_tpl_information19             in varchar2,
	p_tpl_information20             in varchar2
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
  l_rec.price_list_id                    := p_price_list_id;
  l_rec.business_group_id                := p_business_group_id;
  l_rec.currency_code                    := p_currency_code;
  l_rec.default_flag                     := p_default_flag;
  l_rec.name                             := p_name;
  l_rec.object_version_number            := p_object_version_number;
  l_rec.price_list_type                  := p_price_list_type;
  l_rec.start_date                       := p_start_date;
  l_rec.comments                         := p_comments;
  l_rec.description                      := p_description;
  l_rec.end_date                         := p_end_date;
  l_rec.single_unit_price                := p_single_unit_price;
  l_rec.training_unit_type               := p_training_unit_type;
  l_rec.tpl_information_category         := p_tpl_information_category;
  l_rec.tpl_information1                 := p_tpl_information1;
  l_rec.tpl_information2                 := p_tpl_information2;
  l_rec.tpl_information3                 := p_tpl_information3;
  l_rec.tpl_information4                 := p_tpl_information4;
  l_rec.tpl_information5                 := p_tpl_information5;
  l_rec.tpl_information6                 := p_tpl_information6;
  l_rec.tpl_information7                 := p_tpl_information7;
  l_rec.tpl_information8                 := p_tpl_information8;
  l_rec.tpl_information9                 := p_tpl_information9;
  l_rec.tpl_information10                := p_tpl_information10;
  l_rec.tpl_information11                := p_tpl_information11;
  l_rec.tpl_information12                := p_tpl_information12;
  l_rec.tpl_information13                := p_tpl_information13;
  l_rec.tpl_information14                := p_tpl_information14;
  l_rec.tpl_information15                := p_tpl_information15;
  l_rec.tpl_information16                := p_tpl_information16;
  l_rec.tpl_information17                := p_tpl_information17;
  l_rec.tpl_information18                := p_tpl_information18;
  l_rec.tpl_information19                := p_tpl_information19;
  l_rec.tpl_information20                := p_tpl_information20;
  --
  -- Return the plsql record structure.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  Return(l_rec);
--
End convert_args;
--
end ota_tpl_shd;

/
