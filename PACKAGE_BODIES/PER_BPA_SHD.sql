--------------------------------------------------------
--  DDL for Package Body PER_BPA_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_BPA_SHD" as
/* $Header: pebparhi.pkb 115.6 2002/12/02 13:36:46 apholt noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  per_bpa_shd.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |---------------------------< constraint_error >---------------------------|
-- ----------------------------------------------------------------------------
Procedure constraint_error
(p_constraint_name in all_constraints.constraint_name%TYPE
) Is
--
l_proc 	varchar2(72) := g_package||'constraint_error';
--
Begin
hr_utility.set_location('Entering:'||l_proc, 5);
--
If (p_constraint_name = 'PER_BF_PROCESSED_ASSIGNS_FK1') Then
fnd_message.set_name('PER', 'HR_52935_NO_RUN_AVAIL');
fnd_message.set_token('PROCEDURE', l_proc);
fnd_message.set_token('STEP','5');
fnd_message.raise_error;
ElsIf (p_constraint_name = 'PER_BF_PROCESSED_ASSIGNS_PK') Then
fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
fnd_message.set_token('PROCEDURE', l_proc);
fnd_message.set_token('STEP','10');
fnd_message.raise_error;
ElsIf (p_constraint_name = 'PER_BF_PROCESSED_ASSIGNS_UK1') Then
fnd_message.set_name('PER', 'PER_289360_BF_PAYROLL_NOT_UNIQ');
fnd_message.set_token('PROCEDURE', l_proc);
fnd_message.set_token('STEP','15');
fnd_message.raise_error;
ElsIf (p_constraint_name = 'PER_BF_PROCESSED_ASSIGNS_BPAB') Then
fnd_message.set_name('PER', 'PER_289355_BF_BAL_CHILD_EXIST');
fnd_message.set_token('PROCEDURE', l_proc);
fnd_message.set_token('STEP','20');
fnd_message.raise_error;
ElsIf (p_constraint_name = 'PER_BF_PROCESSED_ASSIGNS_BPAP') Then
fnd_message.set_name('PER', 'PER_289356_BF_PAY_CHILD_EXIST');
fnd_message.set_token('PROCEDURE', l_proc);
fnd_message.set_token('STEP','25');
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
(p_processed_assignment_id              in number
,p_object_version_number                in number
)
Return Boolean Is
--
--
-- Cursor selects the 'current' row from the HR Schema
--
Cursor C_Sel1 is
select
processed_assignment_id,
payroll_run_id,
assignment_id,
object_version_number,
bpa_attribute_category,
bpa_attribute1,
bpa_attribute2,
bpa_attribute3,
bpa_attribute4,
bpa_attribute5,
bpa_attribute6,
bpa_attribute7,
bpa_attribute8,
bpa_attribute9,
bpa_attribute10,
bpa_attribute11,
bpa_attribute12,
bpa_attribute13,
bpa_attribute14,
bpa_attribute15,
bpa_attribute16,
bpa_attribute17,
bpa_attribute18,
bpa_attribute19,
bpa_attribute20,
bpa_attribute21,
bpa_attribute22,
bpa_attribute23,
bpa_attribute24,
bpa_attribute25,
bpa_attribute26,
bpa_attribute27,
bpa_attribute28,
bpa_attribute29,
bpa_attribute30
from	per_bf_processed_assignments
where	processed_assignment_id = p_processed_assignment_id;
--
l_proc	varchar2(72)	:= g_package||'api_updating';
l_fct_ret	boolean;
--
Begin
hr_utility.set_location('Entering:'||l_proc, 5);
--
If (p_processed_assignment_id is null and
p_object_version_number is null
) Then
--
-- One of the primary key arguments is null therefore we must
-- set the returning function value to false
--
l_fct_ret := false;
Else
If (p_processed_assignment_id = g_old_rec.processed_assignment_id and
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
(p_processed_assignment_id              in number
,p_object_version_number                in number
) is
--
-- Cursor selects the 'current' row from the HR Schema
--
Cursor C_Sel1 is
select
processed_assignment_id,
payroll_run_id,
assignment_id,
object_version_number,
bpa_attribute_category,
bpa_attribute1,
bpa_attribute2,
bpa_attribute3,
bpa_attribute4,
bpa_attribute5,
bpa_attribute6,
bpa_attribute7,
bpa_attribute8,
bpa_attribute9,
bpa_attribute10,
bpa_attribute11,
bpa_attribute12,
bpa_attribute13,
bpa_attribute14,
bpa_attribute15,
bpa_attribute16,
bpa_attribute17,
bpa_attribute18,
bpa_attribute19,
bpa_attribute20,
bpa_attribute21,
bpa_attribute22,
bpa_attribute23,
bpa_attribute24,
bpa_attribute25,
bpa_attribute26,
bpa_attribute27,
bpa_attribute28,
bpa_attribute29,
bpa_attribute30
from	per_bf_processed_assignments
where	processed_assignment_id = p_processed_assignment_id
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
hr_api.mandatory_arg_error(p_api_name           => l_proc
		    ,p_argument           => 'PROCESSED_ASSIGNMENT_ID'
		    ,p_argument_value     => p_processed_assignment_id);
--
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
fnd_message.set_token('TABLE_NAME', 'per_bf_processed_assignments');
fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
  (p_processed_assignment_id     in number,
  p_payroll_run_id               in number,
  p_assignment_id                in number,
  p_object_version_number        in number,
  p_bpa_attribute_category           in varchar2,
  p_bpa_attribute1                   in varchar2,
  p_bpa_attribute2                   in varchar2,
  p_bpa_attribute3                   in varchar2,
  p_bpa_attribute4                   in varchar2,
  p_bpa_attribute5                   in varchar2,
  p_bpa_attribute6                   in varchar2,
  p_bpa_attribute7                   in varchar2,
  p_bpa_attribute8                   in varchar2,
  p_bpa_attribute9                   in varchar2,
  p_bpa_attribute10                  in varchar2,
  p_bpa_attribute11                  in varchar2,
  p_bpa_attribute12                  in varchar2,
  p_bpa_attribute13                  in varchar2,
  p_bpa_attribute14                  in varchar2,
  p_bpa_attribute15                  in varchar2,
  p_bpa_attribute16                  in varchar2,
  p_bpa_attribute17                  in varchar2,
  p_bpa_attribute18                  in varchar2,
  p_bpa_attribute19                  in varchar2,
  p_bpa_attribute20                  in varchar2,
  p_bpa_attribute21                  in varchar2,
  p_bpa_attribute22                  in varchar2,
  p_bpa_attribute23                  in varchar2,
  p_bpa_attribute24                  in varchar2,
  p_bpa_attribute25                  in varchar2,
  p_bpa_attribute26                  in varchar2,
  p_bpa_attribute27                  in varchar2,
  p_bpa_attribute28                  in varchar2,
  p_bpa_attribute29                  in varchar2,
  p_bpa_attribute30                  in varchar2
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
  l_rec.processed_assignment_id          := p_processed_assignment_id;
  l_rec.payroll_run_id                   := p_payroll_run_id;
  l_rec.assignment_id                    := p_assignment_id;
  l_rec.object_version_number            := p_object_version_number;
  l_rec.bpa_attribute_category               := p_bpa_attribute_category;
  l_rec.bpa_attribute1                       := p_bpa_attribute1;
  l_rec.bpa_attribute2                       := p_bpa_attribute2;
  l_rec.bpa_attribute3                       := p_bpa_attribute3;
  l_rec.bpa_attribute4                       := p_bpa_attribute4;
  l_rec.bpa_attribute5                       := p_bpa_attribute5;
  l_rec.bpa_attribute6                       := p_bpa_attribute6;
  l_rec.bpa_attribute7                       := p_bpa_attribute7;
  l_rec.bpa_attribute8                       := p_bpa_attribute8;
  l_rec.bpa_attribute9                       := p_bpa_attribute9;
  l_rec.bpa_attribute10                      := p_bpa_attribute10;
  l_rec.bpa_attribute11                      := p_bpa_attribute11;
  l_rec.bpa_attribute12                      := p_bpa_attribute12;
  l_rec.bpa_attribute13                      := p_bpa_attribute13;
  l_rec.bpa_attribute14                      := p_bpa_attribute14;
  l_rec.bpa_attribute15                      := p_bpa_attribute15;
  l_rec.bpa_attribute16                      := p_bpa_attribute16;
  l_rec.bpa_attribute17                      := p_bpa_attribute17;
  l_rec.bpa_attribute18                      := p_bpa_attribute18;
  l_rec.bpa_attribute19                      := p_bpa_attribute19;
  l_rec.bpa_attribute20                      := p_bpa_attribute20;
  l_rec.bpa_attribute21                      := p_bpa_attribute21;
  l_rec.bpa_attribute22                      := p_bpa_attribute22;
  l_rec.bpa_attribute23                      := p_bpa_attribute23;
  l_rec.bpa_attribute24                      := p_bpa_attribute24;
  l_rec.bpa_attribute25                      := p_bpa_attribute25;
  l_rec.bpa_attribute26                      := p_bpa_attribute26;
  l_rec.bpa_attribute27                      := p_bpa_attribute27;
  l_rec.bpa_attribute28                      := p_bpa_attribute28;
  l_rec.bpa_attribute29                      := p_bpa_attribute29;
  l_rec.bpa_attribute30                      := p_bpa_attribute30;
--
-- Return the plsql record structure.
--
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  Return(l_rec);
--
End convert_args;
--
end per_bpa_shd;

/
