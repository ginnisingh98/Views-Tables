--------------------------------------------------------
--  DDL for Package Body BEN_CLF_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_CLF_SHD" as
/* $Header: beclfrhi.pkb 120.0 2005/05/28 01:04:10 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_clf_shd.';  -- Global package name
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
  If (p_constraint_name = 'BEN_COMP_LVL_FCTR_FK1') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','5');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'BEN_COMP_LVL_FCTR_PK') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','10');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'BEN_COMP_LVL_RT_F_FK1') Then
    ben_utility.child_exists_error(p_table_name => 'BEN_COMP_LVL_RT_F');
  ElsIf (p_constraint_name = 'BEN_ELIG_COMP_LVL_PRTE_F_FK2') Then
    ben_utility.child_exists_error(p_table_name => 'BEN_ELIG_COMP_LVL_PRTE_F');
  ElsIf (p_constraint_name = 'BEN_CVG_AMT_CALC_MTHD_F_FK2') Then
    ben_utility.child_exists_error(p_table_name => 'BEN_CVG_AMT_CALC_MTHD_F');
  ElsIf (p_constraint_name = 'BEN_ACTL_PREM_F_FK2') Then
    ben_utility.child_exists_error (p_table_name => 'BEN_ACTL_PREM_F');
  ElsIf (p_constraint_name = 'BEN_ACTY_BASE_RT_F_FK2') Then
    ben_utility.child_exists_error(p_table_name => 'BEN_ACTY_BASE_RT_F');
  ElsIf (p_constraint_name = 'BEN_COMP_LVL_ACTY_RT_F_FK2') Then
    ben_utility.child_exists_error(p_table_name => 'BEN_COMP_LVL_ACTY_RT_F');
  ElsIf (p_constraint_name = 'BEN_ENRT_BNFT_FK3') Then
    ben_utility.child_exists_error(p_table_name => 'BEN_ENRT_BNFT');
  ElsIf (p_constraint_name = 'BEN_MTCHG_RT_F_FK2') Then
    ben_utility.child_exists_error(p_table_name => 'BEN_MTCHG_RT_F');
  ElsIf (p_constraint_name = 'BEN_PTD_BAL_TYP_F_FK2') Then
    ben_utility.child_exists_error(p_table_name => 'BEN_PTD_BAL_TYP_F_FK2');
  ElsIf (p_constraint_name = 'BEN_PTD_LMT_F_FK2') Then
   ben_utility.child_exists_error(p_table_name => 'BEN_PTD_LMT_F');
  ElsIf (p_constraint_name = 'BEN_VRBL_RT_PRFL_F_FK5') Then
    ben_utility.child_exists_error(p_table_name => 'BEN_VRBL_RT_PRFL_F');
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
  p_comp_lvl_fctr_id                   in number,
  p_object_version_number              in number
  )      Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
	comp_lvl_fctr_id,
	business_group_id,
	name,
	comp_lvl_det_cd,
        comp_lvl_det_rl,
	comp_lvl_uom,
	comp_src_cd,
	defined_balance_id,
	no_mn_comp_flag,
	no_mx_comp_flag,
	mx_comp_val,
	mn_comp_val,
	rndg_cd,
	rndg_rl,
        bnfts_bal_id,
        comp_alt_val_to_use_cd,
        comp_calc_rl,
        proration_flag,
        start_day_mo,
        end_day_mo,
        start_year,
        end_year,
	clf_attribute_category,
	clf_attribute1,
	clf_attribute2,
	clf_attribute3,
	clf_attribute4,
	clf_attribute5,
	clf_attribute6,
	clf_attribute7,
	clf_attribute8,
	clf_attribute9,
	clf_attribute10,
	clf_attribute11,
	clf_attribute12,
	clf_attribute13,
	clf_attribute14,
	clf_attribute15,
	clf_attribute16,
	clf_attribute17,
	clf_attribute18,
	clf_attribute19,
	clf_attribute20,
	clf_attribute21,
	clf_attribute22,
	clf_attribute23,
	clf_attribute24,
	clf_attribute25,
	clf_attribute26,
	clf_attribute27,
	clf_attribute28,
	clf_attribute29,
	clf_attribute30,
	object_version_number,
    sttd_sal_prdcty_cd
    from	ben_comp_lvl_fctr
    where	comp_lvl_fctr_id = p_comp_lvl_fctr_id;
--
  l_proc	varchar2(72)	:= g_package||'api_updating';
  l_fct_ret	boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (
	p_comp_lvl_fctr_id is null and
	p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (
	p_comp_lvl_fctr_id = g_old_rec.comp_lvl_fctr_id and
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
  p_comp_lvl_fctr_id                   in number,
  p_object_version_number              in number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select 	comp_lvl_fctr_id,
	business_group_id,
	name,
	comp_lvl_det_cd,
        comp_lvl_det_rl,
	comp_lvl_uom,
	comp_src_cd,
	defined_balance_id,
	no_mn_comp_flag,
	no_mx_comp_flag,
	mx_comp_val,
	mn_comp_val,
	rndg_cd,
	rndg_rl,
        bnfts_bal_id,
        comp_alt_val_to_use_cd,
        comp_calc_rl,
        proration_flag,
        start_day_mo,
        end_day_mo,
        start_year,
        end_year,
	clf_attribute_category,
	clf_attribute1,
	clf_attribute2,
	clf_attribute3,
	clf_attribute4,
	clf_attribute5,
	clf_attribute6,
	clf_attribute7,
	clf_attribute8,
	clf_attribute9,
	clf_attribute10,
	clf_attribute11,
	clf_attribute12,
	clf_attribute13,
	clf_attribute14,
	clf_attribute15,
	clf_attribute16,
	clf_attribute17,
	clf_attribute18,
	clf_attribute19,
	clf_attribute20,
	clf_attribute21,
	clf_attribute22,
	clf_attribute23,
	clf_attribute24,
	clf_attribute25,
	clf_attribute26,
	clf_attribute27,
	clf_attribute28,
	clf_attribute29,
	clf_attribute30,
	object_version_number,
    sttd_sal_prdcty_cd
    from	ben_comp_lvl_fctr
    where	comp_lvl_fctr_id = p_comp_lvl_fctr_id
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
    fnd_message.set_token('TABLE_NAME', 'ben_comp_lvl_fctr');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
	(
	p_comp_lvl_fctr_id              in number,
	p_business_group_id             in number,
	p_name                          in varchar2,
	p_comp_lvl_det_cd               in varchar2,
        p_comp_lvl_det_rl               in number,
	p_comp_lvl_uom                  in varchar2,
	p_comp_src_cd                   in varchar2,
	p_defined_balance_id            in number,
	p_no_mn_comp_flag               in varchar2,
	p_no_mx_comp_flag               in varchar2,
	p_mx_comp_val                   in number,
	p_mn_comp_val                   in number,
	p_rndg_cd                       in varchar2,
	p_rndg_rl                       in number,
        p_bnfts_bal_id                  in number,
        p_comp_alt_val_to_use_cd        in varchar2,
        p_comp_calc_rl                  in number,
        p_proration_flag                in varchar2,
        p_start_day_mo                  in varchar2,
        p_end_day_mo                    in varchar2,
        p_start_year                    in varchar2,
        p_end_year                      in varchar2,
	p_clf_attribute_category        in varchar2,
	p_clf_attribute1                in varchar2,
	p_clf_attribute2                in varchar2,
	p_clf_attribute3                in varchar2,
	p_clf_attribute4                in varchar2,
	p_clf_attribute5                in varchar2,
	p_clf_attribute6                in varchar2,
	p_clf_attribute7                in varchar2,
	p_clf_attribute8                in varchar2,
	p_clf_attribute9                in varchar2,
	p_clf_attribute10               in varchar2,
	p_clf_attribute11               in varchar2,
	p_clf_attribute12               in varchar2,
	p_clf_attribute13               in varchar2,
	p_clf_attribute14               in varchar2,
	p_clf_attribute15               in varchar2,
	p_clf_attribute16               in varchar2,
	p_clf_attribute17               in varchar2,
	p_clf_attribute18               in varchar2,
	p_clf_attribute19               in varchar2,
	p_clf_attribute20               in varchar2,
	p_clf_attribute21               in varchar2,
	p_clf_attribute22               in varchar2,
	p_clf_attribute23               in varchar2,
	p_clf_attribute24               in varchar2,
	p_clf_attribute25               in varchar2,
	p_clf_attribute26               in varchar2,
	p_clf_attribute27               in varchar2,
	p_clf_attribute28               in varchar2,
	p_clf_attribute29               in varchar2,
	p_clf_attribute30               in varchar2,
	p_object_version_number         in number,
    p_sttd_sal_prdcty_cd            in  varchar2
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
  l_rec.comp_lvl_fctr_id                 := p_comp_lvl_fctr_id;
  l_rec.business_group_id                := p_business_group_id;
  l_rec.name                             := p_name;
  l_rec.comp_lvl_det_cd                  := p_comp_lvl_det_cd;
  l_rec.comp_lvl_det_rl                  := p_comp_lvl_det_rl;
  l_rec.comp_lvl_uom                     := p_comp_lvl_uom;
  l_rec.comp_src_cd                      := p_comp_src_cd;
  l_rec.defined_balance_id               := p_defined_balance_id;
  l_rec.no_mn_comp_flag                  := p_no_mn_comp_flag;
  l_rec.no_mx_comp_flag                  := p_no_mx_comp_flag;
  l_rec.mx_comp_val                      := p_mx_comp_val;
  l_rec.mn_comp_val                      := p_mn_comp_val;
  l_rec.rndg_cd                          := p_rndg_cd;
  l_rec.rndg_rl                          := p_rndg_rl;
  l_rec.bnfts_bal_id                     := p_bnfts_bal_id;
  l_rec.comp_alt_val_to_use_cd           := p_comp_alt_val_to_use_cd;
  l_rec.comp_calc_rl                     := p_comp_calc_rl;
  l_rec.proration_flag                   := p_proration_flag ;
  l_rec.start_day_mo                     := p_start_day_mo ;
  l_rec.end_day_mo                       := p_end_day_mo ;
  l_rec.start_year                       := p_start_year ;
  l_rec.end_year                         := p_end_year ;
  l_rec.clf_attribute_category           := p_clf_attribute_category;
  l_rec.clf_attribute1                   := p_clf_attribute1;
  l_rec.clf_attribute2                   := p_clf_attribute2;
  l_rec.clf_attribute3                   := p_clf_attribute3;
  l_rec.clf_attribute4                   := p_clf_attribute4;
  l_rec.clf_attribute5                   := p_clf_attribute5;
  l_rec.clf_attribute6                   := p_clf_attribute6;
  l_rec.clf_attribute7                   := p_clf_attribute7;
  l_rec.clf_attribute8                   := p_clf_attribute8;
  l_rec.clf_attribute9                   := p_clf_attribute9;
  l_rec.clf_attribute10                  := p_clf_attribute10;
  l_rec.clf_attribute11                  := p_clf_attribute11;
  l_rec.clf_attribute12                  := p_clf_attribute12;
  l_rec.clf_attribute13                  := p_clf_attribute13;
  l_rec.clf_attribute14                  := p_clf_attribute14;
  l_rec.clf_attribute15                  := p_clf_attribute15;
  l_rec.clf_attribute16                  := p_clf_attribute16;
  l_rec.clf_attribute17                  := p_clf_attribute17;
  l_rec.clf_attribute18                  := p_clf_attribute18;
  l_rec.clf_attribute19                  := p_clf_attribute19;
  l_rec.clf_attribute20                  := p_clf_attribute20;
  l_rec.clf_attribute21                  := p_clf_attribute21;
  l_rec.clf_attribute22                  := p_clf_attribute22;
  l_rec.clf_attribute23                  := p_clf_attribute23;
  l_rec.clf_attribute24                  := p_clf_attribute24;
  l_rec.clf_attribute25                  := p_clf_attribute25;
  l_rec.clf_attribute26                  := p_clf_attribute26;
  l_rec.clf_attribute27                  := p_clf_attribute27;
  l_rec.clf_attribute28                  := p_clf_attribute28;
  l_rec.clf_attribute29                  := p_clf_attribute29;
  l_rec.clf_attribute30                  := p_clf_attribute30;
  l_rec.object_version_number            := p_object_version_number;
  l_rec.sttd_sal_prdcty_cd               := p_sttd_sal_prdcty_cd;
  --
  -- Return the plsql record structure.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  Return(l_rec);
--
End convert_args;
--
end ben_clf_shd;

/
