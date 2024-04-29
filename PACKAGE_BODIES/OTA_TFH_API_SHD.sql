--------------------------------------------------------
--  DDL for Package Body OTA_TFH_API_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_TFH_API_SHD" as
/* $Header: ottfh01t.pkb 120.0 2005/05/29 07:40:15 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ota_tfh_api_shd.';  -- Global package name
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
  If (p_constraint_name = 'OTA_FINANCE_HEADERS_FK1') Then
    fnd_message.set_name('OTA','OTA_13362_TFH_SUPER_INVALID');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'OTA_FINANCE_HEADERS_FK2') Then
    fnd_message.set_name('OTA','OTA_13268_TFH_INVALID_ORG');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'OTA_FINANCE_HEADERS_PK') Then
    fnd_message.set_name('OTA','');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'OTA_TFH_CANCELLED_FLAG_CHK') Then
    fnd_message.set_name('OTA','OTA_13255_TFH_INVALID_CANCEL');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'OTA_TFH_PAYMENT_STATUS_FLA_CHK') Then
    fnd_message.set_name('OTA','OTA_13248_TFH_INVALID_PAY_STA');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'OTA_TFH_TRANSFER_STATUS_CHK') Then
    fnd_message.set_name('OTA','OTA_13232_TFH_INVALID_TRANS_ST');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'OTA_TFH_TYPE_CHK') Then
    fnd_message.set_name('OTA','OTA_13230_TFH_INVALID_TYPE');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'OTA_TFH_RECEIVABLE_TYPE_CHK') Then
    fnd_message.set_name('OTA','OTA_13463_TFH_WRONG_REC_TYPE');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'OTA_TFH_RECEIVABLE_ATTRIBUTES') Then
    fnd_message.set_name('OTA','OTA_13282_TFH_RECEIVABLE_ATTS');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'OTA_TFH_PAYABLE_ATTRIBUTES') Then
    fnd_message.set_name('OTA','OTA_13277_TFH_PAYABLE_ATTS');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'OTA_TFH_CANCELLED_ATTRIBUTES') Then
    fnd_message.set_name('OTA','OTA_13279_TFH_CANCEL_ATTS');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'OTA_TFH_CHECK_TRANSFER_ATTRIBUTES') Then
    fnd_message.set_name('OTA','OTA_13363_TFH_TRANS_ATTS');
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
  p_finance_header_id                  in number,
  p_object_version_number              in number
  )      Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
	finance_header_id,
	superceding_header_id,
	authorizer_person_id,
	organization_id,
	administrator,
	cancelled_flag,
	currency_code,
	date_raised,
	object_version_number,
	payment_status_flag,
	transfer_status,
	type,
        receivable_type,
	comments,
	external_reference,
	invoice_address,
	invoice_contact,
	payment_method,
	pym_attribute1,
	pym_attribute10,
	pym_attribute11,
	pym_attribute12,
	pym_attribute13,
	pym_attribute14,
	pym_attribute15,
	pym_attribute16,
	pym_attribute17,
	pym_attribute18,
	pym_attribute19,
	pym_attribute2,
	pym_attribute20,
	pym_attribute3,
	pym_attribute4,
	pym_attribute5,
	pym_attribute6,
	pym_attribute7,
	pym_attribute8,
	pym_attribute9,
	pym_information_category,
	transfer_date,
	transfer_message,
	vendor_id,
	contact_id,
	address_id,
	customer_id,
	tfh_information_category,
	tfh_information1,
	tfh_information2,
	tfh_information3,
	tfh_information4,
	tfh_information5,
	tfh_information6,
	tfh_information7,
	tfh_information8,
	tfh_information9,
	tfh_information10,
	tfh_information11,
	tfh_information12,
	tfh_information13,
	tfh_information14,
	tfh_information15,
	tfh_information16,
	tfh_information17,
	tfh_information18,
	tfh_information19,
	tfh_information20,
        paying_cost_center,
        receiving_cost_center,
      transfer_from_set_of_books_id,
      transfer_to_set_of_books_id,
      from_segment1,
      from_segment2,
      from_segment3,
      from_segment4,
      from_segment5,
      from_segment6,
      from_segment7,
      from_segment8,
      from_segment9,
      from_segment10,
	from_segment11,
      from_segment12,
      from_segment13,
      from_segment14,
      from_segment15,
      from_segment16,
      from_segment17,
      from_segment18,
      from_segment19,
      from_segment20,
      from_segment21,
      from_segment22,
      from_segment23,
      from_segment24,
      from_segment25,
      from_segment26,
      from_segment27,
      from_segment28,
      from_segment29,
      from_segment30,
      to_segment1,
      to_segment2,
      to_segment3,
      to_segment4,
      to_segment5,
      to_segment6,
      to_segment7,
      to_segment8,
      to_segment9,
      to_segment10,
	to_segment11,
      to_segment12,
      to_segment13,
      to_segment14,
      to_segment15,
      to_segment16,
      to_segment17,
      to_segment18,
      to_segment19,
      to_segment20,
      to_segment21,
      to_segment22,
      to_segment23,
      to_segment24,
      to_segment25,
      to_segment26,
      to_segment27,
      to_segment28,
      to_segment29,
      to_segment30,
      transfer_from_cc_id,
      transfer_to_cc_id
    from	ota_finance_headers
    where	finance_header_id = p_finance_header_id;
--
  l_proc	varchar2(72)	:= g_package||'api_updating';
  l_fct_ret	boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (
	p_finance_header_id is null and
	p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (
	p_finance_header_id = g_old_rec.finance_header_id and
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
  p_finance_header_id                  in number,
  p_object_version_number              in number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select 	finance_header_id,
	superceding_header_id,
	authorizer_person_id,
	organization_id,
	administrator,
	cancelled_flag,
	currency_code,
	date_raised,
	object_version_number,
	payment_status_flag,
	transfer_status,
	type,
        receivable_type,
	comments,
	external_reference,
	invoice_address,
	invoice_contact,
	payment_method,
	pym_attribute1,
	pym_attribute10,
	pym_attribute11,
	pym_attribute12,
	pym_attribute13,
	pym_attribute14,
	pym_attribute15,
	pym_attribute16,
	pym_attribute17,
	pym_attribute18,
	pym_attribute19,
	pym_attribute2,
	pym_attribute20,
	pym_attribute3,
	pym_attribute4,
	pym_attribute5,
	pym_attribute6,
	pym_attribute7,
	pym_attribute8,
	pym_attribute9,
	pym_information_category,
	transfer_date,
	transfer_message,
	vendor_id,
	contact_id,
	address_id,
	customer_id,
	tfh_information_category,
	tfh_information1,
	tfh_information2,
	tfh_information3,
	tfh_information4,
	tfh_information5,
	tfh_information6,
	tfh_information7,
	tfh_information8,
	tfh_information9,
	tfh_information10,
	tfh_information11,
	tfh_information12,
	tfh_information13,
	tfh_information14,
	tfh_information15,
	tfh_information16,
	tfh_information17,
	tfh_information18,
	tfh_information19,
	tfh_information20,
      paying_cost_center,
      receiving_cost_center,
      transfer_from_set_of_books_id,
      transfer_to_set_of_books_id,
      from_segment1,
      from_segment2,
      from_segment3,
      from_segment4,
      from_segment5,
      from_segment6,
      from_segment7,
      from_segment8,
      from_segment9,
      from_segment10,
	from_segment11,
      from_segment12,
      from_segment13,
      from_segment14,
      from_segment15,
      from_segment16,
      from_segment17,
      from_segment18,
      from_segment19,
      from_segment20,
      from_segment21,
      from_segment22,
      from_segment23,
      from_segment24,
      from_segment25,
      from_segment26,
      from_segment27,
      from_segment28,
      from_segment29,
      from_segment30,
      to_segment1,
      to_segment2,
      to_segment3,
      to_segment4,
      to_segment5,
      to_segment6,
      to_segment7,
      to_segment8,
      to_segment9,
      to_segment10,
	to_segment11,
      to_segment12,
      to_segment13,
      to_segment14,
      to_segment15,
      to_segment16,
      to_segment17,
      to_segment18,
      to_segment19,
      to_segment20,
      to_segment21,
      to_segment22,
      to_segment23,
      to_segment24,
      to_segment25,
      to_segment26,
      to_segment27,
      to_segment28,
      to_segment29,
      to_segment30,
      transfer_from_cc_id,
      transfer_to_cc_id
    from	ota_finance_headers
    where	finance_header_id = p_finance_header_id
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
    hr_utility.set_message_token('TABLE_NAME', 'ota_finance_headers');
    hr_utility.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
	(
	p_finance_header_id             in number,
	p_superceding_header_id         in number,
	p_authorizer_person_id          in number,
	p_organization_id               in number,
	p_administrator                 in number,
	p_cancelled_flag                in varchar2,
	p_currency_code                 in varchar2,
	p_date_raised                   in date,
	p_object_version_number         in number,
	p_payment_status_flag           in varchar2,
	p_transfer_status               in varchar2,
	p_type                          in varchar2,
	p_receivable_type               in varchar2,
	p_comments                      in varchar2,
	p_external_reference            in varchar2,
	p_invoice_address               in varchar2,
	p_invoice_contact               in varchar2,
	p_payment_method                in varchar2,
	p_pym_attribute1                in varchar2,
	p_pym_attribute10               in varchar2,
	p_pym_attribute11               in varchar2,
	p_pym_attribute12               in varchar2,
	p_pym_attribute13               in varchar2,
	p_pym_attribute14               in varchar2,
	p_pym_attribute15               in varchar2,
	p_pym_attribute16               in varchar2,
	p_pym_attribute17               in varchar2,
	p_pym_attribute18               in varchar2,
	p_pym_attribute19               in varchar2,
	p_pym_attribute2                in varchar2,
	p_pym_attribute20               in varchar2,
	p_pym_attribute3                in varchar2,
	p_pym_attribute4                in varchar2,
	p_pym_attribute5                in varchar2,
	p_pym_attribute6                in varchar2,
	p_pym_attribute7                in varchar2,
	p_pym_attribute8                in varchar2,
	p_pym_attribute9                in varchar2,
	p_pym_information_category      in varchar2,
	p_transfer_date                 in date,
	p_transfer_message              in varchar2,
	p_vendor_id                     in number,
	p_contact_id                    in number,
	p_address_id                    in number,
	p_customer_id                   in number,
	p_tfh_information_category      in varchar2,
	p_tfh_information1              in varchar2,
	p_tfh_information2              in varchar2,
	p_tfh_information3              in varchar2,
	p_tfh_information4              in varchar2,
	p_tfh_information5              in varchar2,
	p_tfh_information6              in varchar2,
	p_tfh_information7              in varchar2,
	p_tfh_information8              in varchar2,
	p_tfh_information9              in varchar2,
	p_tfh_information10             in varchar2,
	p_tfh_information11             in varchar2,
	p_tfh_information12             in varchar2,
	p_tfh_information13             in varchar2,
	p_tfh_information14             in varchar2,
	p_tfh_information15             in varchar2,
	p_tfh_information16             in varchar2,
	p_tfh_information17             in varchar2,
	p_tfh_information18             in varchar2,
	p_tfh_information19             in varchar2,
	p_tfh_information20             in varchar2,
        p_paying_cost_center            in varchar2,
        p_receiving_cost_center         in varchar2,
  p_transfer_from_set_of_book_id in number,
      p_transfer_to_set_of_book_id   in number,
      p_from_segment1                 in varchar2,
      p_from_segment2                 in varchar2,
      p_from_segment3                 in varchar2,
      p_from_segment4                 in varchar2,
      p_from_segment5                 in varchar2,
      p_from_segment6                 in varchar2,
      p_from_segment7                 in varchar2,
      p_from_segment8                 in varchar2,
      p_from_segment9                 in varchar2,
      p_from_segment10                in varchar2,
	p_from_segment11                 in varchar2,
      p_from_segment12                 in varchar2,
      p_from_segment13                 in varchar2,
      p_from_segment14                 in varchar2,
      p_from_segment15                 in varchar2,
      p_from_segment16                 in varchar2,
      p_from_segment17                 in varchar2,
      p_from_segment18                 in varchar2,
      p_from_segment19                 in varchar2,
      p_from_segment20                in varchar2,
	p_from_segment21                 in varchar2,
      p_from_segment22                 in varchar2,
      p_from_segment23                 in varchar2,
      p_from_segment24                 in varchar2,
      p_from_segment25                 in varchar2,
      p_from_segment26                 in varchar2,
      p_from_segment27                 in varchar2,
      p_from_segment28                 in varchar2,
      p_from_segment29                 in varchar2,
      p_from_segment30                in varchar2,
      p_to_segment1                 in varchar2,
      p_to_segment2                 in varchar2,
      p_to_segment3                 in varchar2,
      p_to_segment4                 in varchar2,
      p_to_segment5                 in varchar2,
      p_to_segment6                 in varchar2,
      p_to_segment7                 in varchar2,
      p_to_segment8                 in varchar2,
      p_to_segment9                 in varchar2,
      p_to_segment10                in varchar2,
	p_to_segment11                 in varchar2,
      p_to_segment12                 in varchar2,
      p_to_segment13                 in varchar2,
      p_to_segment14                 in varchar2,
      p_to_segment15                 in varchar2,
      p_to_segment16                 in varchar2,
      p_to_segment17                 in varchar2,
      p_to_segment18                 in varchar2,
      p_to_segment19                 in varchar2,
      p_to_segment20                in varchar2,
	p_to_segment21                 in varchar2,
      p_to_segment22                 in varchar2,
      p_to_segment23                 in varchar2,
      p_to_segment24                 in varchar2,
      p_to_segment25                 in varchar2,
      p_to_segment26                 in varchar2,
      p_to_segment27                 in varchar2,
      p_to_segment28                 in varchar2,
      p_to_segment29                 in varchar2,
      p_to_segment30                in varchar2,
      p_transfer_from_cc_id          in number,
      p_transfer_to_cc_id            in number
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
  l_rec.finance_header_id                := p_finance_header_id;
  l_rec.superceding_header_id            := p_superceding_header_id;
  l_rec.authorizer_person_id             := p_authorizer_person_id;
  l_rec.organization_id                  := p_organization_id;
  l_rec.administrator                    := p_administrator;
  l_rec.cancelled_flag                   := p_cancelled_flag;
  l_rec.currency_code                    := p_currency_code;
  l_rec.date_raised                      := p_date_raised;
  l_rec.object_version_number            := p_object_version_number;
  l_rec.payment_status_flag              := p_payment_status_flag;
  l_rec.transfer_status                  := p_transfer_status;
  l_rec.type                             := p_type;
  l_rec.receivable_type                  := p_receivable_type;
  l_rec.comments                         := p_comments;
  l_rec.external_reference               := p_external_reference;
  l_rec.invoice_address                  := p_invoice_address;
  l_rec.invoice_contact                  := p_invoice_contact;
  l_rec.payment_method                   := p_payment_method;
  l_rec.pym_attribute1                   := p_pym_attribute1;
  l_rec.pym_attribute10                  := p_pym_attribute10;
  l_rec.pym_attribute11                  := p_pym_attribute11;
  l_rec.pym_attribute12                  := p_pym_attribute12;
  l_rec.pym_attribute13                  := p_pym_attribute13;
  l_rec.pym_attribute14                  := p_pym_attribute14;
  l_rec.pym_attribute15                  := p_pym_attribute15;
  l_rec.pym_attribute16                  := p_pym_attribute16;
  l_rec.pym_attribute17                  := p_pym_attribute17;
  l_rec.pym_attribute18                  := p_pym_attribute18;
  l_rec.pym_attribute19                  := p_pym_attribute19;
  l_rec.pym_attribute2                   := p_pym_attribute2;
  l_rec.pym_attribute20                  := p_pym_attribute20;
  l_rec.pym_attribute3                   := p_pym_attribute3;
  l_rec.pym_attribute4                   := p_pym_attribute4;
  l_rec.pym_attribute5                   := p_pym_attribute5;
  l_rec.pym_attribute6                   := p_pym_attribute6;
  l_rec.pym_attribute7                   := p_pym_attribute7;
  l_rec.pym_attribute8                   := p_pym_attribute8;
  l_rec.pym_attribute9                   := p_pym_attribute9;
  l_rec.pym_information_category         := p_pym_information_category;
  l_rec.transfer_date                    := p_transfer_date;
  l_rec.transfer_message                 := p_transfer_message;
  l_rec.vendor_id                        := p_vendor_id;
  l_rec.contact_id                       := p_contact_id;
  l_rec.address_id                       := p_address_id;
  l_rec.customer_id                      := p_customer_id;
  l_rec.tfh_information_category         := p_tfh_information_category;
  l_rec.tfh_information1                 := p_tfh_information1;
  l_rec.tfh_information2                 := p_tfh_information2;
  l_rec.tfh_information3                 := p_tfh_information3;
  l_rec.tfh_information4                 := p_tfh_information4;
  l_rec.tfh_information5                 := p_tfh_information5;
  l_rec.tfh_information6                 := p_tfh_information6;
  l_rec.tfh_information7                 := p_tfh_information7;
  l_rec.tfh_information8                 := p_tfh_information8;
  l_rec.tfh_information9                 := p_tfh_information9;
  l_rec.tfh_information10                := p_tfh_information10;
  l_rec.tfh_information11                := p_tfh_information11;
  l_rec.tfh_information12                := p_tfh_information12;
  l_rec.tfh_information13                := p_tfh_information13;
  l_rec.tfh_information14                := p_tfh_information14;
  l_rec.tfh_information15                := p_tfh_information15;
  l_rec.tfh_information16                := p_tfh_information16;
  l_rec.tfh_information17                := p_tfh_information17;
  l_rec.tfh_information18                := p_tfh_information18;
  l_rec.tfh_information19                := p_tfh_information19;
  l_rec.tfh_information20                := p_tfh_information20;
  l_rec.paying_cost_center               := p_paying_cost_center;
  l_rec.receiving_cost_center            := p_receiving_cost_center;
  l_rec.transfer_from_set_of_book_id    := p_transfer_from_set_of_book_id;
  l_rec.transfer_to_set_of_book_id      := p_transfer_to_set_of_book_id;
  l_rec.from_segment1			     := p_from_segment1;
  l_rec.from_segment2    		     := p_from_segment2;
  l_rec.from_segment3                    := p_from_segment3;
  l_rec.from_segment4			     := p_from_segment4;
  l_rec.from_segment5			     := p_from_segment5;
  l_rec.from_segment6			     := p_from_segment6;
  l_rec.from_segment7    		     := p_from_segment7;
  l_rec.from_segment8                    := p_from_segment8;
  l_rec.from_segment9			     := p_from_segment9;
  l_rec.from_segment10			     := p_from_segment10;
  l_rec.from_segment11			     := p_from_segment11;
  l_rec.from_segment12   		     := p_from_segment12;
  l_rec.from_segment13                    := p_from_segment13;
  l_rec.from_segment14			     := p_from_segment14;
  l_rec.from_segment15			     := p_from_segment15;
  l_rec.from_segment16			     := p_from_segment16;
  l_rec.from_segment17    		     := p_from_segment17;
  l_rec.from_segment18                    := p_from_segment18;
  l_rec.from_segment19			     := p_from_segment19;
  l_rec.from_segment20			     := p_from_segment20;
  l_rec.from_segment21			     := p_from_segment21;
  l_rec.from_segment22    		     := p_from_segment22;
  l_rec.from_segment23                    := p_from_segment23;
  l_rec.from_segment24			     := p_from_segment24;
  l_rec.from_segment25			     := p_from_segment25;
  l_rec.from_segment26			     := p_from_segment26;
  l_rec.from_segment27    		     := p_from_segment27;
  l_rec.from_segment28                    := p_from_segment28;
  l_rec.from_segment29			     := p_from_segment29;
  l_rec.from_segment30			     := p_from_segment30;
  l_rec.to_segment1			     := p_to_segment1;
  l_rec.to_segment2    		     := p_to_segment2;
  l_rec.to_segment3                    := p_to_segment3;
  l_rec.to_segment4			     := p_to_segment4;
  l_rec.to_segment5			     := p_to_segment5;
  l_rec.to_segment6			     := p_to_segment6;
  l_rec.to_segment7    		     := p_to_segment7;
  l_rec.to_segment8                    := p_to_segment8;
  l_rec.to_segment9			     := p_to_segment9;
  l_rec.to_segment10			     := p_to_segment10;
  l_rec.to_segment11			     := p_to_segment11;
  l_rec.to_segment12   		     := p_to_segment12;
  l_rec.to_segment13                    := p_to_segment13;
  l_rec.to_segment14			     := p_to_segment14;
  l_rec.to_segment15			     := p_to_segment15;
  l_rec.to_segment16			     := p_to_segment16;
  l_rec.to_segment17    		     := p_to_segment17;
  l_rec.to_segment18                    := p_to_segment18;
  l_rec.to_segment19			     := p_to_segment19;
  l_rec.to_segment20			     := p_to_segment20;
  l_rec.to_segment21			     := p_to_segment21;
  l_rec.to_segment22    		     := p_to_segment22;
  l_rec.to_segment23                    := p_to_segment23;
  l_rec.to_segment24			     := p_to_segment24;
  l_rec.to_segment25			     := p_to_segment25;
  l_rec.to_segment26			     := p_to_segment26;
  l_rec.to_segment27    		     := p_to_segment27;
  l_rec.to_segment28                    := p_to_segment28;
  l_rec.to_segment29			     := p_to_segment29;
  l_rec.to_segment30			     := p_to_segment30;
  l_rec.transfer_from_cc_id              := p_transfer_from_cc_id;
  l_rec.transfer_to_cc_id                := p_transfer_to_cc_id;
  --
  -- Return the plsql record structure.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  Return(l_rec);
--
End convert_args;
--
end ota_tfh_api_shd;

/
