--------------------------------------------------------
--  DDL for Package Body OTA_TFL_API_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_TFL_API_SHD" as
/* $Header: ottfl01t.pkb 120.0 2005/05/29 07:41:43 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ota_tfl_api_shd.';  -- Global package name
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
  If (p_constraint_name = 'OTA_FINANCE_LINES_FK1') Then
    fnd_message.set_name('OTA','OTA_13369_TFL_INVALID_FK');
    fnd_message.set_token('STEP','1');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'OTA_FINANCE_LINES_FK2') Then
    fnd_message.set_name('OTA','OTA_13369_TFL_INVALID_FK');
    fnd_message.set_token('STEP','2');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'OTA_FINANCE_LINES_FK3') Then
    fnd_message.set_name('OTA','OTA_13369_TFL_INVALID_FK');
    fnd_message.set_token('STEP','3');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'OTA_FINANCE_LINES_FK4') Then
    fnd_message.set_name('OTA','OTA_13369_TFL_INVALID_FK');
    fnd_message.set_token('STEP','4');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'OTA_FINANCE_LINES_FK5') Then
    fnd_message.set_name('OTA','OTA_13369_TFL_INVALID_FK');
    fnd_message.set_token('STEP','5');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'OTA_FINANCE_LINES_PK') Then
    fnd_message.set_name('OTA','');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'OTA_TFL_CANCELLED_FLAG_CHK') Then
   fnd_message.set_name('OTA','OTA_13255_TFH_INVALID_CANCEL');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'OTA_TFL_LINE_TYPE_CHK') Then
    fnd_message.set_name('OTA','OTA_13383_TFL_INVALID_TYPE');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'OTA_TFL_TRANSFER_STATUS_CHK') Then
    fnd_message.set_name('OTA','OTA_13232_TFH_INVALID_TRANS_ST');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'OTA_TFL_V_AMOUNT_ATTRIBUTES') Then
    fnd_message.set_name('OTA','OTA_13372_TFL_AMT_ATTRIBUTES');
    fnd_message.set_token('STEP','1');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'OTA_TFL_E_AMOUNT_ATTRIBUTES') Then
    fnd_message.set_name('OTA','OTA_13372_TFL_AMT_ATTRIBUTES');
    fnd_message.set_token('STEP','2');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'OTA_TFL_P_AMOUNT_ATTRIBUTES') Then
    fnd_message.set_name('OTA','OTA_13372_TFL_AMT_ATTRIBUTES');
    fnd_message.set_token('STEP','3');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'OTA_TFL_R_AMOUNT_ATTRIBUTES') Then
    fnd_message.set_name('OTA','OTA_13372_TFL_AMT_ATTRIBUTES');
    fnd_message.set_token('STEP','4');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'OTA_TFL_O_AMOUNT_ATTRIBUTES') Then
    fnd_message.set_name('OTA','OTA_13372_TFL_AMT_ATTRIBUTES');
    fnd_message.set_token('STEP','5');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'OTA_TFL_CHECK_ENROLL_ATTR') Then
    fnd_message.set_name('OTA','OTA_13350_TFL_ENROLLMENT_ATTR');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'OTA_TFL_CHECK_PRE_PURCH_ATTR') Then
    fnd_message.set_name('OTA','OTA_13349_TFL_PRE_PURCH_ATTR');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'OTA_TFL_CHECK_PAYMENT_ATTR') Then
    fnd_message.set_name('OTA','OTA_13353_TFL_VENDOR_PAY_ATTR');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'OTA_TFL_CHECK_OTHER_ATTR') Then
    fnd_message.set_name('OTA','Invalid-attributes');
    fnd_message.raise_error;
  Else
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP',p_constraint_name);
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
  p_finance_line_id                    in number,
  p_object_version_number              in number
  )      Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
	finance_line_id,
	finance_header_id,
	cancelled_flag,
	date_raised,
	line_type,
	object_version_number,
	sequence_number,
	transfer_status,
	comments,
	currency_code,
	money_amount,
	standard_amount,
	trans_information_category,
	trans_information1,
	trans_information10,
	trans_information11,
	trans_information12,
	trans_information13,
	trans_information14,
	trans_information15,
	trans_information16,
	trans_information17,
	trans_information18,
	trans_information19,
	trans_information2,
	trans_information20,
	trans_information3,
	trans_information4,
	trans_information5,
	trans_information6,
	trans_information7,
	trans_information8,
	trans_information9,
	transfer_date,
	transfer_message,
	unitary_amount,
	booking_deal_id,
	booking_id,
	resource_allocation_id,
	resource_booking_id,
	tfl_information_category,
	tfl_information1,
	tfl_information2,
	tfl_information3,
	tfl_information4,
	tfl_information5,
	tfl_information6,
	tfl_information7,
	tfl_information8,
	tfl_information9,
	tfl_information10,
	tfl_information11,
	tfl_information12,
	tfl_information13,
	tfl_information14,
	tfl_information15,
	tfl_information16,
	tfl_information17,
	tfl_information18,
	tfl_information19,
	tfl_information20
    from	ota_finance_lines
    where	finance_line_id = p_finance_line_id;
--
  l_proc	varchar2(72)	:= g_package||'api_updating';
  l_fct_ret	boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (
	p_finance_line_id is null and
	p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (
	p_finance_line_id = g_old_rec.finance_line_id and
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
  p_finance_line_id                    in number,
  p_object_version_number              in number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select 	finance_line_id,
	finance_header_id,
	cancelled_flag,
	date_raised,
	line_type,
	object_version_number,
	sequence_number,
	transfer_status,
	comments,
	currency_code,
	money_amount,
	standard_amount,
	trans_information_category,
	trans_information1,
	trans_information10,
	trans_information11,
	trans_information12,
	trans_information13,
	trans_information14,
	trans_information15,
	trans_information16,
	trans_information17,
	trans_information18,
	trans_information19,
	trans_information2,
	trans_information20,
	trans_information3,
	trans_information4,
	trans_information5,
	trans_information6,
	trans_information7,
	trans_information8,
	trans_information9,
	transfer_date,
	transfer_message,
	unitary_amount,
	booking_deal_id,
	booking_id,
	resource_allocation_id,
	resource_booking_id,
	tfl_information_category,
	tfl_information1,
	tfl_information2,
	tfl_information3,
	tfl_information4,
	tfl_information5,
	tfl_information6,
	tfl_information7,
	tfl_information8,
	tfl_information9,
	tfl_information10,
	tfl_information11,
	tfl_information12,
	tfl_information13,
	tfl_information14,
	tfl_information15,
	tfl_information16,
	tfl_information17,
	tfl_information18,
	tfl_information19,
	tfl_information20
    from	ota_finance_lines
    where	finance_line_id = p_finance_line_id
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
    hr_utility.set_message_token('TABLE_NAME', 'ota_finance_lines');
    hr_utility.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
	(
	p_finance_line_id               in number,
	p_finance_header_id             in number,
	p_cancelled_flag                in varchar2,
	p_date_raised                   in date,
	p_line_type                     in varchar2,
	p_object_version_number         in number,
	p_sequence_number               in number,
	p_transfer_status               in varchar2,
	p_comments                      in varchar2,
	p_currency_code                 in varchar2,
	p_money_amount                  in number,
	p_standard_amount               in number,
	p_trans_information_category    in varchar2,
	p_trans_information1            in varchar2,
	p_trans_information10           in varchar2,
	p_trans_information11           in varchar2,
	p_trans_information12           in varchar2,
	p_trans_information13           in varchar2,
	p_trans_information14           in varchar2,
	p_trans_information15           in varchar2,
	p_trans_information16           in varchar2,
	p_trans_information17           in varchar2,
	p_trans_information18           in varchar2,
	p_trans_information19           in varchar2,
	p_trans_information2            in varchar2,
	p_trans_information20           in varchar2,
	p_trans_information3            in varchar2,
	p_trans_information4            in varchar2,
	p_trans_information5            in varchar2,
	p_trans_information6            in varchar2,
	p_trans_information7            in varchar2,
	p_trans_information8            in varchar2,
	p_trans_information9            in varchar2,
	p_transfer_date                 in date,
	p_transfer_message              in varchar2,
	p_unitary_amount                in number,
	p_booking_deal_id               in number,
	p_booking_id                    in number,
	p_resource_allocation_id        in number,
	p_resource_booking_id           in number,
	p_tfl_information_category      in varchar2,
	p_tfl_information1              in varchar2,
	p_tfl_information2              in varchar2,
	p_tfl_information3              in varchar2,
	p_tfl_information4              in varchar2,
	p_tfl_information5              in varchar2,
	p_tfl_information6              in varchar2,
	p_tfl_information7              in varchar2,
	p_tfl_information8              in varchar2,
	p_tfl_information9              in varchar2,
	p_tfl_information10             in varchar2,
	p_tfl_information11             in varchar2,
	p_tfl_information12             in varchar2,
	p_tfl_information13             in varchar2,
	p_tfl_information14             in varchar2,
	p_tfl_information15             in varchar2,
	p_tfl_information16             in varchar2,
	p_tfl_information17             in varchar2,
	p_tfl_information18             in varchar2,
	p_tfl_information19             in varchar2,
	p_tfl_information20             in varchar2
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
  l_rec.finance_line_id                  := p_finance_line_id;
  l_rec.finance_header_id                := p_finance_header_id;
  l_rec.cancelled_flag                   := p_cancelled_flag;
  l_rec.date_raised                      := p_date_raised;
  l_rec.line_type                        := p_line_type;
  l_rec.object_version_number            := p_object_version_number;
  l_rec.sequence_number                  := p_sequence_number;
  l_rec.transfer_status                  := p_transfer_status;
  l_rec.comments                         := p_comments;
  l_rec.currency_code                    := p_currency_code;
  l_rec.money_amount                     := p_money_amount;
  l_rec.standard_amount                  := p_standard_amount;
  l_rec.trans_information_category       := p_trans_information_category;
  l_rec.trans_information1               := p_trans_information1;
  l_rec.trans_information10              := p_trans_information10;
  l_rec.trans_information11              := p_trans_information11;
  l_rec.trans_information12              := p_trans_information12;
  l_rec.trans_information13              := p_trans_information13;
  l_rec.trans_information14              := p_trans_information14;
  l_rec.trans_information15              := p_trans_information15;
  l_rec.trans_information16              := p_trans_information16;
  l_rec.trans_information17              := p_trans_information17;
  l_rec.trans_information18              := p_trans_information18;
  l_rec.trans_information19              := p_trans_information19;
  l_rec.trans_information2               := p_trans_information2;
  l_rec.trans_information20              := p_trans_information20;
  l_rec.trans_information3               := p_trans_information3;
  l_rec.trans_information4               := p_trans_information4;
  l_rec.trans_information5               := p_trans_information5;
  l_rec.trans_information6               := p_trans_information6;
  l_rec.trans_information7               := p_trans_information7;
  l_rec.trans_information8               := p_trans_information8;
  l_rec.trans_information9               := p_trans_information9;
  l_rec.transfer_date                    := p_transfer_date;
  l_rec.transfer_message                 := p_transfer_message;
  l_rec.unitary_amount                   := p_unitary_amount;
  l_rec.booking_deal_id                  := p_booking_deal_id;
  l_rec.booking_id                       := p_booking_id;
  l_rec.resource_allocation_id           := p_resource_allocation_id;
  l_rec.resource_booking_id              := p_resource_booking_id;
  l_rec.tfl_information_category         := p_tfl_information_category;
  l_rec.tfl_information1                 := p_tfl_information1;
  l_rec.tfl_information2                 := p_tfl_information2;
  l_rec.tfl_information3                 := p_tfl_information3;
  l_rec.tfl_information4                 := p_tfl_information4;
  l_rec.tfl_information5                 := p_tfl_information5;
  l_rec.tfl_information6                 := p_tfl_information6;
  l_rec.tfl_information7                 := p_tfl_information7;
  l_rec.tfl_information8                 := p_tfl_information8;
  l_rec.tfl_information9                 := p_tfl_information9;
  l_rec.tfl_information10                := p_tfl_information10;
  l_rec.tfl_information11                := p_tfl_information11;
  l_rec.tfl_information12                := p_tfl_information12;
  l_rec.tfl_information13                := p_tfl_information13;
  l_rec.tfl_information14                := p_tfl_information14;
  l_rec.tfl_information15                := p_tfl_information15;
  l_rec.tfl_information16                := p_tfl_information16;
  l_rec.tfl_information17                := p_tfl_information17;
  l_rec.tfl_information18                := p_tfl_information18;
  l_rec.tfl_information19                := p_tfl_information19;
  l_rec.tfl_information20                := p_tfl_information20;
  --
  -- Return the plsql record structure.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  Return(l_rec);
--
End convert_args;
--
end ota_tfl_api_shd;

/
