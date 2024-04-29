--------------------------------------------------------
--  DDL for Package Body PER_BBA_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_BBA_SHD" as
/* $Header: pebbarhi.pkb 115.8 2002/12/02 13:03:45 apholt noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  per_bba_shd.';  -- Global package name
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
  If (p_constraint_name = 'PER_BF_BALANCE_AMOUNTS_FK1') Then
    fnd_message.set_name('PER', 'PER_289357_BF_BG_ID_INVALID');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','5');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'PER_BF_BALANCE_AMOUNTS_FK2') Then
    fnd_message.set_name('PER', 'HR_52938_BAL_TYPE_NOT_EXIST');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','10');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'PER_BF_BALANCE_AMOUNTS_FK3') Then
    fnd_message.set_name('PER', 'HR_52937_BAD_PROCESSED_ASG_ID');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','15');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'PER_BF_BALANCE_AMOUNTS_PK') Then
    fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
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
p_balance_amount_id                    in number,
  p_object_version_number              in number
  )      Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
      balance_amount_id,
      balance_type_id,
      processed_assignment_id,
      business_group_id,
      ytd_amount,
      fytd_amount,
      ptd_amount,
      mtd_amount,
      qtd_amount,
      run_amount,
      object_version_number,
      bba_attribute_category,
      bba_attribute1,
      bba_attribute2,
      bba_attribute3,
      bba_attribute4,
      bba_attribute5,
      bba_attribute6,
      bba_attribute7,
      bba_attribute8,
      bba_attribute9,
      bba_attribute10,
      bba_attribute11,
      bba_attribute12,
      bba_attribute13,
      bba_attribute14,
      bba_attribute15,
      bba_attribute16,
      bba_attribute17,
      bba_attribute18,
      bba_attribute19,
      bba_attribute20,
      bba_attribute21,
      bba_attribute22,
      bba_attribute23,
      bba_attribute24,
      bba_attribute25,
      bba_attribute26,
      bba_attribute27,
      bba_attribute28,
      bba_attribute29,
      bba_attribute30
    from	per_bf_balance_amounts
    where	balance_amount_id = p_balance_amount_id;
--
  l_proc	varchar2(72)	:= g_package||'api_updating';
  l_fct_ret	boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (
      p_balance_amount_id is null and
      p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (
      p_balance_amount_id = g_old_rec.balance_amount_id and
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
p_balance_amount_id                    in number,
  p_object_version_number              in number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select       balance_amount_id,
      balance_type_id,
      processed_assignment_id,
      business_group_id,
      ytd_amount,
      fytd_amount,
      ptd_amount,
      mtd_amount,
      qtd_amount,
      run_amount,
      object_version_number,
      bba_attribute_category,
      bba_attribute1,
      bba_attribute2,
      bba_attribute3,
      bba_attribute4,
      bba_attribute5,
      bba_attribute6,
      bba_attribute7,
      bba_attribute8,
      bba_attribute9,
      bba_attribute10,
      bba_attribute11,
      bba_attribute12,
      bba_attribute13,
      bba_attribute14,
      bba_attribute15,
      bba_attribute16,
      bba_attribute17,
      bba_attribute18,
      bba_attribute19,
      bba_attribute20,
      bba_attribute21,
      bba_attribute22,
      bba_attribute23,
      bba_attribute24,
      bba_attribute25,
      bba_attribute26,
      bba_attribute27,
      bba_attribute28,
      bba_attribute29,
      bba_attribute30
    from	per_bf_balance_amounts
    where	balance_amount_id = p_balance_amount_id
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
                               p_argument           => 'BALANCE_AMOUNT_ID',
                               p_argument_value     => p_balance_amount_id);
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
    fnd_message.set_token('TABLE_NAME', 'per_bf_balance_amounts');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
        (
      p_balance_amount_id            in number,
      p_balance_type_id              in number,
      p_processed_assignment_id      in number,
      p_business_group_id            in number,
      p_ytd_amount                   in number,
      p_fytd_amount                  in number,
      p_ptd_amount                   in number,
      p_mtd_amount                   in number,
      p_qtd_amount                   in number,
      p_run_amount                   in number,
      p_object_version_number        in number,
      p_bba_attribute_category           in varchar2,
      p_bba_attribute1                   in varchar2,
      p_bba_attribute2                   in varchar2,
      p_bba_attribute3                   in varchar2,
      p_bba_attribute4                   in varchar2,
      p_bba_attribute5                   in varchar2,
      p_bba_attribute6                   in varchar2,
      p_bba_attribute7                   in varchar2,
      p_bba_attribute8                   in varchar2,
      p_bba_attribute9                   in varchar2,
      p_bba_attribute10                  in varchar2,
      p_bba_attribute11                  in varchar2,
      p_bba_attribute12                  in varchar2,
      p_bba_attribute13                  in varchar2,
      p_bba_attribute14                  in varchar2,
      p_bba_attribute15                  in varchar2,
      p_bba_attribute16                  in varchar2,
      p_bba_attribute17                  in varchar2,
      p_bba_attribute18                  in varchar2,
      p_bba_attribute19                  in varchar2,
      p_bba_attribute20                  in varchar2,
      p_bba_attribute21                  in varchar2,
      p_bba_attribute22                  in varchar2,
      p_bba_attribute23                  in varchar2,
      p_bba_attribute24                  in varchar2,
      p_bba_attribute25                  in varchar2,
      p_bba_attribute26                  in varchar2,
      p_bba_attribute27                  in varchar2,
      p_bba_attribute28                  in varchar2,
      p_bba_attribute29                  in varchar2,
      p_bba_attribute30                  in varchar2

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
  l_rec.balance_amount_id                := p_balance_amount_id;
  l_rec.balance_type_id                  := p_balance_type_id;
  l_rec.processed_assignment_id          := p_processed_assignment_id;
  l_rec.business_group_id                := p_business_group_id;
  l_rec.ytd_amount                       := p_ytd_amount;
  l_rec.fytd_amount                      := p_fytd_amount;
  l_rec.ptd_amount                       := p_ptd_amount;
  l_rec.mtd_amount                       := p_mtd_amount;
  l_rec.qtd_amount                       := p_qtd_amount;
  l_rec.run_amount                       := p_run_amount;
  l_rec.object_version_number            := p_object_version_number;
  l_rec.bba_attribute_category               := p_bba_attribute_category;
  l_rec.bba_attribute1                       := p_bba_attribute1;
  l_rec.bba_attribute2                       := p_bba_attribute2;
  l_rec.bba_attribute3                       := p_bba_attribute3;
  l_rec.bba_attribute4                       := p_bba_attribute4;
  l_rec.bba_attribute5                       := p_bba_attribute5;
  l_rec.bba_attribute6                       := p_bba_attribute6;
  l_rec.bba_attribute7                       := p_bba_attribute7;
  l_rec.bba_attribute8                       := p_bba_attribute8;
  l_rec.bba_attribute9                       := p_bba_attribute9;
  l_rec.bba_attribute10                      := p_bba_attribute10;
  l_rec.bba_attribute11                      := p_bba_attribute11;
  l_rec.bba_attribute12                      := p_bba_attribute12;
  l_rec.bba_attribute13                      := p_bba_attribute13;
  l_rec.bba_attribute14                      := p_bba_attribute14;
  l_rec.bba_attribute15                      := p_bba_attribute15;
  l_rec.bba_attribute16                      := p_bba_attribute16;
  l_rec.bba_attribute17                      := p_bba_attribute17;
  l_rec.bba_attribute18                      := p_bba_attribute18;
  l_rec.bba_attribute19                      := p_bba_attribute19;
  l_rec.bba_attribute20                      := p_bba_attribute20;
  l_rec.bba_attribute21                      := p_bba_attribute21;
  l_rec.bba_attribute22                      := p_bba_attribute22;
  l_rec.bba_attribute23                      := p_bba_attribute23;
  l_rec.bba_attribute24                      := p_bba_attribute24;
  l_rec.bba_attribute25                      := p_bba_attribute25;
  l_rec.bba_attribute26                      := p_bba_attribute26;
  l_rec.bba_attribute27                      := p_bba_attribute27;
  l_rec.bba_attribute28                      := p_bba_attribute28;
  l_rec.bba_attribute29                      := p_bba_attribute29;
  l_rec.bba_attribute30                      := p_bba_attribute30;
--
-- Return the plsql record structure.
--
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  Return(l_rec);
--
End convert_args;
--
end per_bba_shd;

/
