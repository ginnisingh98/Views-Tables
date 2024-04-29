--------------------------------------------------------
--  DDL for Package Body PER_BPR_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_BPR_SHD" as
/* $Header: pebprrhi.pkb 115.6 2002/12/02 14:33:23 apholt noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  per_bpr_shd.';  -- Global package name
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
  If (p_constraint_name = 'PER_BF_PAYROLL_RUNS_FK1') Then
    fnd_message.set_name('PER', 'PER_289357_BF_BG_ID_INVALID');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','5');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'PER_BF_PAYROLL_RUNS_PK') Then
    fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','10');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'PER_BF_PAYROLL_RUNS_UK1') Then
    fnd_message.set_name('PER', 'HR_52931_IDENTIFIER_NOT_UNQ');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','15');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'PER_BF_PAYROLL_RUNS_REX') Then
    fnd_message.set_name('PER', 'PER_289359_BF_PROC_ASG_EXISTS');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','20');
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
p_payroll_run_id                       in number,
  p_object_version_number              in number
  )      Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
      payroll_run_id,
      payroll_id,
      business_group_id,
      payroll_identifier,
      period_start_date,
      period_end_date,
      processing_date,
      object_version_number,
      bpr_attribute_category,
      bpr_attribute1,
      bpr_attribute2,
      bpr_attribute3,
      bpr_attribute4,
      bpr_attribute5,
      bpr_attribute6,
      bpr_attribute7,
      bpr_attribute8,
      bpr_attribute9,
      bpr_attribute10,
      bpr_attribute11,
      bpr_attribute12,
      bpr_attribute13,
      bpr_attribute14,
      bpr_attribute15,
      bpr_attribute16,
      bpr_attribute17,
      bpr_attribute18,
      bpr_attribute19,
      bpr_attribute20,
      bpr_attribute21,
      bpr_attribute22,
      bpr_attribute23,
      bpr_attribute24,
      bpr_attribute25,
      bpr_attribute26,
      bpr_attribute27,
      bpr_attribute28,
      bpr_attribute29,
      bpr_attribute30
    from	per_bf_payroll_runs
    where	payroll_run_id = p_payroll_run_id;
--
  l_proc	varchar2(72)	:= g_package||'api_updating';
  l_fct_ret	boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (
      p_payroll_run_id is null and
      p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (
      p_payroll_run_id = g_old_rec.payroll_run_id and
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
p_payroll_run_id                       in number,
  p_object_version_number              in number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select       payroll_run_id,
      payroll_id,
      business_group_id,
      payroll_identifier,
      period_start_date,
      period_end_date,
      processing_date,
      object_version_number,
      bpr_attribute_category,
      bpr_attribute1,
      bpr_attribute2,
      bpr_attribute3,
      bpr_attribute4,
      bpr_attribute5,
      bpr_attribute6,
      bpr_attribute7,
      bpr_attribute8,
      bpr_attribute9,
      bpr_attribute10,
      bpr_attribute11,
      bpr_attribute12,
      bpr_attribute13,
      bpr_attribute14,
      bpr_attribute15,
      bpr_attribute16,
      bpr_attribute17,
      bpr_attribute18,
      bpr_attribute19,
      bpr_attribute20,
      bpr_attribute21,
      bpr_attribute22,
      bpr_attribute23,
      bpr_attribute24,
      bpr_attribute25,
      bpr_attribute26,
      bpr_attribute27,
      bpr_attribute28,
      bpr_attribute29,
      bpr_attribute30
    from	per_bf_payroll_runs
    where	payroll_run_id = p_payroll_run_id
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
                               p_argument           => 'PAYROLL_RUN_ID',
                               p_argument_value     => p_payroll_run_id);
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
    fnd_message.set_token('TABLE_NAME', 'per_bf_payroll_runs');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
        (
      p_payroll_run_id               in number,
      p_payroll_id                   in number,
      p_business_group_id            in number,
      p_payroll_identifier           in varchar2,
      p_period_start_date            in date,
      p_period_end_date              in date,
      p_processing_date              in date,
      p_object_version_number        in number,
      p_bpr_attribute_category           in varchar2,
      p_bpr_attribute1                   in varchar2,
      p_bpr_attribute2                   in varchar2,
      p_bpr_attribute3                   in varchar2,
      p_bpr_attribute4                   in varchar2,
      p_bpr_attribute5                   in varchar2,
      p_bpr_attribute6                   in varchar2,
      p_bpr_attribute7                   in varchar2,
      p_bpr_attribute8                   in varchar2,
      p_bpr_attribute9                   in varchar2,
      p_bpr_attribute10                  in varchar2,
      p_bpr_attribute11                  in varchar2,
      p_bpr_attribute12                  in varchar2,
      p_bpr_attribute13                  in varchar2,
      p_bpr_attribute14                  in varchar2,
      p_bpr_attribute15                  in varchar2,
      p_bpr_attribute16                  in varchar2,
      p_bpr_attribute17                  in varchar2,
      p_bpr_attribute18                  in varchar2,
      p_bpr_attribute19                  in varchar2,
      p_bpr_attribute20                  in varchar2,
      p_bpr_attribute21                  in varchar2,
      p_bpr_attribute22                  in varchar2,
      p_bpr_attribute23                  in varchar2,
      p_bpr_attribute24                  in varchar2,
      p_bpr_attribute25                  in varchar2,
      p_bpr_attribute26                  in varchar2,
      p_bpr_attribute27                  in varchar2,
      p_bpr_attribute28                  in varchar2,
      p_bpr_attribute29                  in varchar2,
      p_bpr_attribute30                  in varchar2
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
  l_rec.payroll_run_id                   := p_payroll_run_id;
  l_rec.payroll_id                       := p_payroll_id;
  l_rec.business_group_id                := p_business_group_id;
  l_rec.payroll_identifier               := p_payroll_identifier;
  l_rec.period_start_date                := p_period_start_date;
  l_rec.period_end_date                  := p_period_end_date;
  l_rec.processing_date                  := p_processing_date;
  l_rec.object_version_number            := p_object_version_number;
  l_rec.bpr_attribute_category               := p_bpr_attribute_category;
  l_rec.bpr_attribute1                       := p_bpr_attribute1;
  l_rec.bpr_attribute2                       := p_bpr_attribute2;
  l_rec.bpr_attribute3                       := p_bpr_attribute3;
  l_rec.bpr_attribute4                       := p_bpr_attribute4;
  l_rec.bpr_attribute5                       := p_bpr_attribute5;
  l_rec.bpr_attribute6                       := p_bpr_attribute6;
  l_rec.bpr_attribute7                       := p_bpr_attribute7;
  l_rec.bpr_attribute8                       := p_bpr_attribute8;
  l_rec.bpr_attribute9                       := p_bpr_attribute9;
  l_rec.bpr_attribute10                      := p_bpr_attribute10;
  l_rec.bpr_attribute11                      := p_bpr_attribute11;
  l_rec.bpr_attribute12                      := p_bpr_attribute12;
  l_rec.bpr_attribute13                      := p_bpr_attribute13;
  l_rec.bpr_attribute14                      := p_bpr_attribute14;
  l_rec.bpr_attribute15                      := p_bpr_attribute15;
  l_rec.bpr_attribute16                      := p_bpr_attribute16;
  l_rec.bpr_attribute17                      := p_bpr_attribute17;
  l_rec.bpr_attribute18                      := p_bpr_attribute18;
  l_rec.bpr_attribute19                      := p_bpr_attribute19;
  l_rec.bpr_attribute20                      := p_bpr_attribute20;
  l_rec.bpr_attribute21                      := p_bpr_attribute21;
  l_rec.bpr_attribute22                      := p_bpr_attribute22;
  l_rec.bpr_attribute23                      := p_bpr_attribute23;
  l_rec.bpr_attribute24                      := p_bpr_attribute24;
  l_rec.bpr_attribute25                      := p_bpr_attribute25;
  l_rec.bpr_attribute26                      := p_bpr_attribute26;
  l_rec.bpr_attribute27                      := p_bpr_attribute27;
  l_rec.bpr_attribute28                      := p_bpr_attribute28;
  l_rec.bpr_attribute29                      := p_bpr_attribute29;
  l_rec.bpr_attribute30                      := p_bpr_attribute30;
  --
  -- Return the plsql record structure.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  Return(l_rec);
--
End convert_args;
--
end per_bpr_shd;

/
