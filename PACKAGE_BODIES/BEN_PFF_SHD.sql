--------------------------------------------------------
--  DDL for Package Body BEN_PFF_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PFF_SHD" as
/* $Header: bepffrhi.pkb 120.0 2005/05/28 10:42:25 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_pff_shd.';  -- Global package name
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
            (p_constraint_name in all_constraints.constraint_name%TYPE) Is
--
  l_proc 	varchar2(72) := g_package||'constraint_error';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (p_constraint_name = 'BEN_PCT_FL_TM_FCTR_FK1') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','5');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'BEN_PCT_FL_TM_FCTR_PK') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','10');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'BEN_ELIG_PCT_FL_FK1') Then
    ben_utility.child_exists_error(p_table_name => 'BEN_ELIG_PCT_FL_TM_PRTE_F');
  ElsIf (p_constraint_name = 'BEN_PCT_FL_TM_RT_FK1') Then
    ben_utility.child_exists_error(p_table_name => 'BEN_PCT_FL_TM_RT_F');
  Else
    fnd_message.set_name('PAY', 'HR_7877_API_INVALID_CONSTRAINT');
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
  p_pct_fl_tm_fctr_id                  in number,
  p_object_version_number              in number
  )      Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
		pct_fl_tm_fctr_id,
	name,
	business_group_id,
	mx_pct_val,
	mn_pct_val,
	no_mn_pct_val_flag,
	no_mx_pct_val_flag,
	use_prmry_asnt_only_flag,
	use_sum_of_all_asnts_flag,
	rndg_cd,
	rndg_rl,
	pff_attribute_category,
	pff_attribute1,
	pff_attribute2,
	pff_attribute3,
	pff_attribute4,
	pff_attribute5,
	pff_attribute6,
	pff_attribute7,
	pff_attribute8,
	pff_attribute9,
	pff_attribute10,
	pff_attribute11,
	pff_attribute12,
	pff_attribute13,
	pff_attribute14,
	pff_attribute15,
	pff_attribute16,
	pff_attribute17,
	pff_attribute18,
	pff_attribute19,
	pff_attribute20,
	pff_attribute21,
	pff_attribute22,
	pff_attribute23,
	pff_attribute24,
	pff_attribute25,
	pff_attribute26,
	pff_attribute27,
	pff_attribute28,
	pff_attribute29,
	pff_attribute30,
	object_version_number
    from	ben_pct_fl_tm_fctr
    where	pct_fl_tm_fctr_id = p_pct_fl_tm_fctr_id;
--
  l_proc	varchar2(72)	:= g_package||'api_updating';
  l_fct_ret	boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (
	p_pct_fl_tm_fctr_id is null and
	p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (
	p_pct_fl_tm_fctr_id = g_old_rec.pct_fl_tm_fctr_id and
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
        fnd_message.set_name('PAY', 'HR_7220_INVALID_PRIMARY_KEY');
        fnd_message.raise_error;
      End If;
      Close C_Sel1;
      If (p_object_version_number <> g_old_rec.object_version_number) Then
        fnd_message.set_name('PAY', 'HR_7155_OBJECT_INVALID');
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
  p_pct_fl_tm_fctr_id                  in number,
  p_object_version_number              in number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select 	pct_fl_tm_fctr_id,
	name,
	business_group_id,
	mx_pct_val,
	mn_pct_val,
	no_mn_pct_val_flag,
	no_mx_pct_val_flag,
	use_prmry_asnt_only_flag,
	use_sum_of_all_asnts_flag,
	rndg_cd,
	rndg_rl,
	pff_attribute_category,
	pff_attribute1,
	pff_attribute2,
	pff_attribute3,
	pff_attribute4,
	pff_attribute5,
	pff_attribute6,
	pff_attribute7,
	pff_attribute8,
	pff_attribute9,
	pff_attribute10,
	pff_attribute11,
	pff_attribute12,
	pff_attribute13,
	pff_attribute14,
	pff_attribute15,
	pff_attribute16,
	pff_attribute17,
	pff_attribute18,
	pff_attribute19,
	pff_attribute20,
	pff_attribute21,
	pff_attribute22,
	pff_attribute23,
	pff_attribute24,
	pff_attribute25,
	pff_attribute26,
	pff_attribute27,
	pff_attribute28,
	pff_attribute29,
	pff_attribute30,
	object_version_number
    from	ben_pct_fl_tm_fctr
    where	pct_fl_tm_fctr_id = p_pct_fl_tm_fctr_id
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
    fnd_message.set_name('PAY', 'HR_7220_INVALID_PRIMARY_KEY');
    fnd_message.raise_error;
  End If;
  Close C_Sel1;
  If (p_object_version_number <> g_old_rec.object_version_number) Then
        fnd_message.set_name('PAY', 'HR_7155_OBJECT_INVALID');
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
    fnd_message.set_name('PAY', 'HR_7165_OBJECT_LOCKED');
    fnd_message.set_token('TABLE_NAME', 'ben_pct_fl_tm_fctr');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
	(
	p_pct_fl_tm_fctr_id             in number,
	p_name                          in varchar2,
	p_business_group_id             in number,
	p_mx_pct_val                    in number,
	p_mn_pct_val                    in number,
	p_no_mn_pct_val_flag            in varchar2,
	p_no_mx_pct_val_flag            in varchar2,
	p_use_prmry_asnt_only_flag      in varchar2,
	p_use_sum_of_all_asnts_flag     in varchar2,
	p_rndg_cd                       in varchar2,
	p_rndg_rl                       in number,
	p_pff_attribute_category        in varchar2,
	p_pff_attribute1                in varchar2,
	p_pff_attribute2                in varchar2,
	p_pff_attribute3                in varchar2,
	p_pff_attribute4                in varchar2,
	p_pff_attribute5                in varchar2,
	p_pff_attribute6                in varchar2,
	p_pff_attribute7                in varchar2,
	p_pff_attribute8                in varchar2,
	p_pff_attribute9                in varchar2,
	p_pff_attribute10               in varchar2,
	p_pff_attribute11               in varchar2,
	p_pff_attribute12               in varchar2,
	p_pff_attribute13               in varchar2,
	p_pff_attribute14               in varchar2,
	p_pff_attribute15               in varchar2,
	p_pff_attribute16               in varchar2,
	p_pff_attribute17               in varchar2,
	p_pff_attribute18               in varchar2,
	p_pff_attribute19               in varchar2,
	p_pff_attribute20               in varchar2,
	p_pff_attribute21               in varchar2,
	p_pff_attribute22               in varchar2,
	p_pff_attribute23               in varchar2,
	p_pff_attribute24               in varchar2,
	p_pff_attribute25               in varchar2,
	p_pff_attribute26               in varchar2,
	p_pff_attribute27               in varchar2,
	p_pff_attribute28               in varchar2,
	p_pff_attribute29               in varchar2,
	p_pff_attribute30               in varchar2,
	p_object_version_number         in number
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
  l_rec.pct_fl_tm_fctr_id                := p_pct_fl_tm_fctr_id;
  l_rec.name                             := p_name;
  l_rec.business_group_id                := p_business_group_id;
  l_rec.mx_pct_val                       := p_mx_pct_val;
  l_rec.mn_pct_val                       := p_mn_pct_val;
  l_rec.no_mn_pct_val_flag               := p_no_mn_pct_val_flag;
  l_rec.no_mx_pct_val_flag               := p_no_mx_pct_val_flag;
  l_rec.use_prmry_asnt_only_flag         := p_use_prmry_asnt_only_flag;
  l_rec.use_sum_of_all_asnts_flag        := p_use_sum_of_all_asnts_flag;
  l_rec.rndg_cd                          := p_rndg_cd;
  l_rec.rndg_rl                          := p_rndg_rl;
  l_rec.pff_attribute_category           := p_pff_attribute_category;
  l_rec.pff_attribute1                   := p_pff_attribute1;
  l_rec.pff_attribute2                   := p_pff_attribute2;
  l_rec.pff_attribute3                   := p_pff_attribute3;
  l_rec.pff_attribute4                   := p_pff_attribute4;
  l_rec.pff_attribute5                   := p_pff_attribute5;
  l_rec.pff_attribute6                   := p_pff_attribute6;
  l_rec.pff_attribute7                   := p_pff_attribute7;
  l_rec.pff_attribute8                   := p_pff_attribute8;
  l_rec.pff_attribute9                   := p_pff_attribute9;
  l_rec.pff_attribute10                  := p_pff_attribute10;
  l_rec.pff_attribute11                  := p_pff_attribute11;
  l_rec.pff_attribute12                  := p_pff_attribute12;
  l_rec.pff_attribute13                  := p_pff_attribute13;
  l_rec.pff_attribute14                  := p_pff_attribute14;
  l_rec.pff_attribute15                  := p_pff_attribute15;
  l_rec.pff_attribute16                  := p_pff_attribute16;
  l_rec.pff_attribute17                  := p_pff_attribute17;
  l_rec.pff_attribute18                  := p_pff_attribute18;
  l_rec.pff_attribute19                  := p_pff_attribute19;
  l_rec.pff_attribute20                  := p_pff_attribute20;
  l_rec.pff_attribute21                  := p_pff_attribute21;
  l_rec.pff_attribute22                  := p_pff_attribute22;
  l_rec.pff_attribute23                  := p_pff_attribute23;
  l_rec.pff_attribute24                  := p_pff_attribute24;
  l_rec.pff_attribute25                  := p_pff_attribute25;
  l_rec.pff_attribute26                  := p_pff_attribute26;
  l_rec.pff_attribute27                  := p_pff_attribute27;
  l_rec.pff_attribute28                  := p_pff_attribute28;
  l_rec.pff_attribute29                  := p_pff_attribute29;
  l_rec.pff_attribute30                  := p_pff_attribute30;
  l_rec.object_version_number            := p_object_version_number;
  --
  -- Return the plsql record structure.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  Return(l_rec);
--
End convert_args;
--
end ben_pff_shd;

/
