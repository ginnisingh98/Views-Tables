--------------------------------------------------------
--  DDL for Package Body PER_BPD_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_BPD_SHD" as
/* $Header: pebpdrhi.pkb 115.6 2002/12/02 13:52:43 apholt noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  per_bpd_shd.';  -- Global package name
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
If (p_constraint_name = 'PER_BF_PAYMENT_DETAILS_FK1') Then
fnd_message.set_name('PER', 'PER_289357_BF_BG_ID_INVALID');
fnd_message.set_token('PROCEDURE', l_proc);
fnd_message.set_token('STEP','5');
fnd_message.raise_error;
ElsIf (p_constraint_name = 'PER_BF_PAYMENT_DETAILS_FK2') Then
fnd_message.set_name('PER', 'HR_52948_BAD_PROCESSED_ASG_ID');
fnd_message.set_token('PROCEDURE', l_proc);
fnd_message.set_token('STEP','10');
fnd_message.raise_error;
ElsIf (p_constraint_name = 'PER_BF_PAYMENT_DETAILS_PK') Then
fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
fnd_message.set_token('PROCEDURE', l_proc);
fnd_message.set_token('STEP','15');
fnd_message.raise_error;
ElsIf (p_constraint_name = 'PER_BF_PAYMENT_DETAILS_UK1') Then
fnd_message.set_name('PER', 'PER_289358_BF_ASG_PPM_NOT_UNQ');
fnd_message.set_token('PROCEDURE', l_proc);
fnd_message.set_token('STEP','15');
fnd_message.raise_error;
Else
fnd_message.set_name('PER', 'HR_7877_API_INVALID_CONSTRAINT');
fnd_message.set_token('PROCEDURE', l_proc);
fnd_message.set_token('CONSTRAINT_NAME', p_constraint_name);
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
p_payment_detail_id                    in number,
p_object_version_number              in number
)      Return Boolean Is
--
--
-- Cursor selects the 'current' row from the HR Schema
--
Cursor C_Sel1 is
select
payment_detail_id,
processed_assignment_id,
personal_payment_method_id,
business_group_id,
check_number,
payment_date,
amount,
check_type,
object_version_number,
bpd_attribute_category,
bpd_attribute1,
bpd_attribute2,
bpd_attribute3,
bpd_attribute4,
bpd_attribute5,
bpd_attribute6,
bpd_attribute7,
bpd_attribute8,
bpd_attribute9,
bpd_attribute10,
bpd_attribute11,
bpd_attribute12,
bpd_attribute13,
bpd_attribute14,
bpd_attribute15,
bpd_attribute16,
bpd_attribute17,
bpd_attribute18,
bpd_attribute19,
bpd_attribute20,
bpd_attribute21,
bpd_attribute22,
bpd_attribute23,
bpd_attribute24,
bpd_attribute25,
bpd_attribute26,
bpd_attribute27,
bpd_attribute28,
bpd_attribute29,
bpd_attribute30
from	per_bf_payment_details
where	payment_detail_id = p_payment_detail_id;
--
l_proc	varchar2(72)	:= g_package||'api_updating';
l_fct_ret	boolean;
--
Begin
hr_utility.set_location('Entering:'||l_proc, 5);
--
If (
p_payment_detail_id is null and
p_object_version_number is null
) Then
--
-- One of the primary key arguments is null therefore we must
-- set the returning function value to false
--
l_fct_ret := false;
Else
If (
p_payment_detail_id = g_old_rec.payment_detail_id and
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
fnd_message.set_name('PER', 'HR_7220_INVALID_PRIMARY_KEY');
fnd_message.raise_error;
End If;
Close C_Sel1;
If (p_object_version_number <> g_old_rec.object_version_number) Then
fnd_message.set_name('PER', 'HR_7155_OBJECT_INVALID');
fnd_message.raise_error;
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
p_payment_detail_id                    in number,
p_object_version_number              in number
) is
--
-- Cursor selects the 'current' row from the HR Schema
--
Cursor C_Sel1 is
select       payment_detail_id,
processed_assignment_id,
personal_payment_method_id,
business_group_id,
check_number,
payment_date,
amount,
check_type,
object_version_number,
bpd_attribute_category,
bpd_attribute1,
bpd_attribute2,
bpd_attribute3,
bpd_attribute4,
bpd_attribute5,
bpd_attribute6,
bpd_attribute7,
bpd_attribute8,
bpd_attribute9,
bpd_attribute10,
bpd_attribute11,
bpd_attribute12,
bpd_attribute13,
bpd_attribute14,
bpd_attribute15,
bpd_attribute16,
bpd_attribute17,
bpd_attribute18,
bpd_attribute19,
bpd_attribute20,
bpd_attribute21,
bpd_attribute22,
bpd_attribute23,
bpd_attribute24,
bpd_attribute25,
bpd_attribute26,
bpd_attribute27,
bpd_attribute28,
bpd_attribute29,
bpd_attribute30
from	per_bf_payment_details
where	payment_detail_id = p_payment_detail_id
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
hr_api.mandatory_arg_error(p_api_name           => l_proc,
		       p_argument           => 'PAYMENT_DETAIL_ID',
		       p_argument_value     => p_payment_detail_id);
Open  C_Sel1;
Fetch C_Sel1 Into g_old_rec;
If C_Sel1%notfound then
Close C_Sel1;
--
-- The primary key is invalid therefore we must error
--
fnd_message.set_name('PER', 'HR_7220_INVALID_PRIMARY_KEY');
fnd_message.raise_error;
End If;
Close C_Sel1;
If (p_object_version_number <> g_old_rec.object_version_number) Then
fnd_message.set_name('PER', 'HR_7155_OBJECT_INVALID');
fnd_message.raise_error;
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
fnd_message.set_name('PER', 'HR_7165_OBJECT_LOCKED');
fnd_message.set_token('TABLE_NAME', 'per_bf_payment_details');
fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
(
p_payment_detail_id            in number,
p_processed_assignment_id      in number,
p_personal_payment_method_id   in number,
p_business_group_id            in number,
p_check_number                 in number,
p_payment_date                   in date,
p_amount                       in number,
p_check_type                   in varchar2,
p_object_version_number        in number,
p_bpd_attribute_category           in varchar2,
p_bpd_attribute1                   in varchar2,
p_bpd_attribute2                   in varchar2,
p_bpd_attribute3                   in varchar2,
p_bpd_attribute4                   in varchar2,
p_bpd_attribute5                   in varchar2,
p_bpd_attribute6                   in varchar2,
p_bpd_attribute7                   in varchar2,
p_bpd_attribute8                   in varchar2,
p_bpd_attribute9                   in varchar2,
p_bpd_attribute10                  in varchar2,
p_bpd_attribute11                  in varchar2,
p_bpd_attribute12                  in varchar2,
p_bpd_attribute13                  in varchar2,
p_bpd_attribute14                  in varchar2,
p_bpd_attribute15                  in varchar2,
p_bpd_attribute16                  in varchar2,
p_bpd_attribute17                  in varchar2,
p_bpd_attribute18                  in varchar2,
p_bpd_attribute19                  in varchar2,
p_bpd_attribute20                  in varchar2,
p_bpd_attribute21                  in varchar2,
p_bpd_attribute22                  in varchar2,
p_bpd_attribute23                  in varchar2,
p_bpd_attribute24                  in varchar2,
p_bpd_attribute25                  in varchar2,
p_bpd_attribute26                  in varchar2,
p_bpd_attribute27                  in varchar2,
p_bpd_attribute28                  in varchar2,
p_bpd_attribute29                  in varchar2,
p_bpd_attribute30                  in varchar2
)
Return g_rec_type is
--
l_rec         g_rec_type;
l_proc  varchar2(72) := g_package||'convert_args';
--
Begin
--
hr_utility.set_location('Entering:'||l_proc, 5);
--
-- Convert arguments into local l_rec structure.
--
l_rec.payment_detail_id                := p_payment_detail_id;
l_rec.processed_assignment_id          := p_processed_assignment_id;
l_rec.personal_payment_method_id       := p_personal_payment_method_id;
l_rec.business_group_id                := p_business_group_id;
l_rec.check_number                     := p_check_number;
l_rec.payment_date                     := p_payment_date;
l_rec.amount                           := p_amount;
l_rec.check_type                       := p_check_type;
l_rec.object_version_number            := p_object_version_number;
l_rec.bpd_attribute_category           := p_bpd_attribute_category;
l_rec.bpd_attribute1                   := p_bpd_attribute1;
l_rec.bpd_attribute2                   := p_bpd_attribute2;
l_rec.bpd_attribute3                   := p_bpd_attribute3;
l_rec.bpd_attribute4                   := p_bpd_attribute4;
l_rec.bpd_attribute5                   := p_bpd_attribute5;
l_rec.bpd_attribute6                   := p_bpd_attribute6;
l_rec.bpd_attribute7                   := p_bpd_attribute7;
l_rec.bpd_attribute8                   := p_bpd_attribute8;
l_rec.bpd_attribute9                   := p_bpd_attribute9;
l_rec.bpd_attribute10                  := p_bpd_attribute10;
l_rec.bpd_attribute11                  := p_bpd_attribute11;
l_rec.bpd_attribute12                  := p_bpd_attribute12;
l_rec.bpd_attribute13                  := p_bpd_attribute13;
l_rec.bpd_attribute14                  := p_bpd_attribute14;
l_rec.bpd_attribute15                  := p_bpd_attribute15;
l_rec.bpd_attribute16                  := p_bpd_attribute16;
l_rec.bpd_attribute17                  := p_bpd_attribute17;
l_rec.bpd_attribute18                  := p_bpd_attribute18;
l_rec.bpd_attribute19                  := p_bpd_attribute19;
l_rec.bpd_attribute20                  := p_bpd_attribute20;
l_rec.bpd_attribute21                  := p_bpd_attribute21;
l_rec.bpd_attribute22                  := p_bpd_attribute22;
l_rec.bpd_attribute23                  := p_bpd_attribute23;
l_rec.bpd_attribute24                  := p_bpd_attribute24;
l_rec.bpd_attribute25                  := p_bpd_attribute25;
l_rec.bpd_attribute26                  := p_bpd_attribute26;
l_rec.bpd_attribute27                  := p_bpd_attribute27;
l_rec.bpd_attribute28                  := p_bpd_attribute28;
l_rec.bpd_attribute29                  := p_bpd_attribute29;
l_rec.bpd_attribute30                  := p_bpd_attribute30;
--
-- Return the plsql record structure.
--
hr_utility.set_location(' Leaving:'||l_proc, 10);
Return(l_rec);
--
End convert_args;
--
end per_bpd_shd;

/
