--------------------------------------------------------
--  DDL for Package Body OTA_PLE_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_PLE_SHD" as
/* $Header: otple01t.pkb 115.3 99/07/16 00:52:56 porting ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ota_ple_shd.';  -- Global package name
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
  If (p_constraint_name = 'OTA_PLE_DATES_ORDER') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','5');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'OTA_PLE_MAX_ATTENDEES_NOTNULL') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','10');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'OTA_PLE_MAX_ATTENDEES_NULL') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','15');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'OTA_PLE_MIN_ATTENDEES_NOTNULL') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','20');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'OTA_PLE_MIN_ATTENDEES_NULL') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','25');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'OTA_PLE_MIN_GREATER_THAN_ONE') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','30');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'OTA_PLE_MIN_SMALLER_THAN_MAX') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','35');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'OTA_PLE_PRICE_BASIS_CHK') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','40');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'OTA_PLE_PRICE_POSITIVE') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','45');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'OTA_PLE_VEND_ACTIV_MUT_EXCL') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','50');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'OTA_PRICE_LIST_ENTRIES_FK3') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','55');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'OTA_PRICE_LIST_ENTRIES_PK') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','60');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'OTA_PRICE_LIST_ENTRIES_UK2') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','65');
    hr_utility.raise_error;
  Else
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','70');
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
  p_price_list_entry_id                in number,
  p_object_version_number              in number
  )      Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
		price_list_entry_id,
	vendor_supply_id,
	activity_version_id,
	price_list_id,
	object_version_number,
	price,
	price_basis,
	start_date,
	comments,
	end_date,
	maximum_attendees,
	minimum_attendees,
	ple_information_category,
	ple_information1,
	ple_information2,
	ple_information3,
	ple_information4,
	ple_information5,
	ple_information6,
	ple_information7,
	ple_information8,
	ple_information9,
	ple_information10,
	ple_information11,
	ple_information12,
	ple_information13,
	ple_information14,
	ple_information15,
	ple_information16,
	ple_information17,
	ple_information18,
	ple_information19,
	ple_information20
    from	ota_price_list_entries
    where	price_list_entry_id = p_price_list_entry_id;
--
  l_proc	varchar2(72)	:= g_package||'api_updating';
  l_fct_ret	boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (
	p_price_list_entry_id is null and
	p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (
	p_price_list_entry_id = g_old_rec.price_list_entry_id and
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
  p_price_list_entry_id                in number,
  p_object_version_number              in number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select 	price_list_entry_id,
	vendor_supply_id,
	activity_version_id,
	price_list_id,
	object_version_number,
	price,
	price_basis,
	start_date,
	comments,
	end_date,
	maximum_attendees,
	minimum_attendees,
	ple_information_category,
	ple_information1,
	ple_information2,
	ple_information3,
	ple_information4,
	ple_information5,
	ple_information6,
	ple_information7,
	ple_information8,
	ple_information9,
	ple_information10,
	ple_information11,
	ple_information12,
	ple_information13,
	ple_information14,
	ple_information15,
	ple_information16,
	ple_information17,
	ple_information18,
	ple_information19,
	ple_information20
    from	ota_price_list_entries
    where	price_list_entry_id = p_price_list_entry_id
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
    hr_utility.set_message_token('TABLE_NAME', 'ota_price_list_entries');
    hr_utility.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
	(
	p_price_list_entry_id           in number,
	p_vendor_supply_id              in number,
	p_activity_version_id           in number,
	p_price_list_id                 in number,
	p_object_version_number         in number,
	p_price                         in number,
	p_price_basis                   in varchar2,
	p_start_date                    in date,
	p_comments                      in varchar2,
	p_end_date                      in date,
	p_maximum_attendees             in number,
	p_minimum_attendees             in number,
	p_ple_information_category      in varchar2,
	p_ple_information1              in varchar2,
	p_ple_information2              in varchar2,
	p_ple_information3              in varchar2,
	p_ple_information4              in varchar2,
	p_ple_information5              in varchar2,
	p_ple_information6              in varchar2,
	p_ple_information7              in varchar2,
	p_ple_information8              in varchar2,
	p_ple_information9              in varchar2,
	p_ple_information10             in varchar2,
	p_ple_information11             in varchar2,
	p_ple_information12             in varchar2,
	p_ple_information13             in varchar2,
	p_ple_information14             in varchar2,
	p_ple_information15             in varchar2,
	p_ple_information16             in varchar2,
	p_ple_information17             in varchar2,
	p_ple_information18             in varchar2,
	p_ple_information19             in varchar2,
	p_ple_information20             in varchar2
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
  l_rec.price_list_entry_id              := p_price_list_entry_id;
  l_rec.vendor_supply_id                 := p_vendor_supply_id;
  l_rec.activity_version_id              := p_activity_version_id;
  l_rec.price_list_id                    := p_price_list_id;
  l_rec.object_version_number            := p_object_version_number;
  l_rec.price                            := p_price;
  l_rec.price_basis                      := p_price_basis;
  l_rec.start_date                       := p_start_date;
  l_rec.comments                         := p_comments;
  l_rec.end_date                         := p_end_date;
  l_rec.maximum_attendees                := p_maximum_attendees;
  l_rec.minimum_attendees                := p_minimum_attendees;
  l_rec.ple_information_category         := p_ple_information_category;
  l_rec.ple_information1                 := p_ple_information1;
  l_rec.ple_information2                 := p_ple_information2;
  l_rec.ple_information3                 := p_ple_information3;
  l_rec.ple_information4                 := p_ple_information4;
  l_rec.ple_information5                 := p_ple_information5;
  l_rec.ple_information6                 := p_ple_information6;
  l_rec.ple_information7                 := p_ple_information7;
  l_rec.ple_information8                 := p_ple_information8;
  l_rec.ple_information9                 := p_ple_information9;
  l_rec.ple_information10                := p_ple_information10;
  l_rec.ple_information11                := p_ple_information11;
  l_rec.ple_information12                := p_ple_information12;
  l_rec.ple_information13                := p_ple_information13;
  l_rec.ple_information14                := p_ple_information14;
  l_rec.ple_information15                := p_ple_information15;
  l_rec.ple_information16                := p_ple_information16;
  l_rec.ple_information17                := p_ple_information17;
  l_rec.ple_information18                := p_ple_information18;
  l_rec.ple_information19                := p_ple_information19;
  l_rec.ple_information20                := p_ple_information20;
  --
  -- Return the plsql record structure.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  Return(l_rec);
--
End convert_args;
--
end ota_ple_shd;

/
