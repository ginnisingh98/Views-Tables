--------------------------------------------------------
--  DDL for Package Body BEN_PRV_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PRV_SHD" as
/* $Header: beprvrhi.pkb 120.0.12000000.3 2007/07/01 19:16:05 mmudigon noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_prv_shd.';  -- Global package name
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
--  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (p_constraint_name = 'BEN_PRTT_RT_VAL_FK1') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','5');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'BEN_PRTT_RT_VAL_FK3') Then
           ben_utility.child_exists_error(p_table_name =>
'BEN_PER_IN_LER');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'BEN_PRTT_RT_VAL_FK4') Then
           ben_utility.child_exists_error(p_table_name =>
'BEN_PER_IN_LER');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'BEN_PRTT_RT_VAL_PK') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','20');
    fnd_message.raise_error;
  Else
    fnd_message.set_name('PAY', 'HR_7877_API_INVALID_CONSTRAINT');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('CONSTRAINT_NAME', p_constraint_name);
    fnd_message.raise_error;
  End If;
  --
--  hr_utility.set_location(' Leaving:'||l_proc, 10);
End constraint_error;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< api_updating >-----------------------------|
-- ----------------------------------------------------------------------------
Function api_updating
  (
  p_prtt_rt_val_id                     in number,
  p_object_version_number              in number
  )      Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
	prtt_rt_val_id,
      null,
	rt_strt_dt,
	rt_end_dt,
	rt_typ_cd,
	tx_typ_cd,
	ordr_num,
	acty_typ_cd,
	mlt_cd,
	acty_ref_perd_cd,
	rt_val,
	ann_rt_val,
	cmcd_rt_val,
	cmcd_ref_perd_cd,
	bnft_rt_typ_cd,
	dsply_on_enrt_flag,
	rt_ovridn_flag,
	rt_ovridn_thru_dt,
	elctns_made_dt,
	prtt_rt_val_stat_cd,
	prtt_enrt_rslt_id,
	cvg_amt_calc_mthd_id,
	actl_prem_id,
	comp_lvl_fctr_id,
	element_entry_value_id,
	per_in_ler_id,
	ended_per_in_ler_id,
	acty_base_rt_id,
	prtt_reimbmt_rqst_id,
        prtt_rmt_aprvd_fr_pymt_id,
        pp_in_yr_used_num,
	business_group_id,
	prv_attribute_category,
	prv_attribute1,
	prv_attribute2,
	prv_attribute3,
	prv_attribute4,
	prv_attribute5,
	prv_attribute6,
	prv_attribute7,
	prv_attribute8,
	prv_attribute9,
	prv_attribute10,
	prv_attribute11,
	prv_attribute12,
	prv_attribute13,
	prv_attribute14,
	prv_attribute15,
	prv_attribute16,
	prv_attribute17,
	prv_attribute18,
	prv_attribute19,
	prv_attribute20,
	prv_attribute21,
	prv_attribute22,
	prv_attribute23,
	prv_attribute24,
	prv_attribute25,
	prv_attribute26,
	prv_attribute27,
	prv_attribute28,
	prv_attribute29,
	prv_attribute30,
        pk_id_table_name,
        pk_id,
	object_version_number
    from	ben_prtt_rt_val
    where	prtt_rt_val_id = p_prtt_rt_val_id;
--
  l_proc	varchar2(72)	:= g_package||'api_updating';
  l_fct_ret	boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (
	p_prtt_rt_val_id is null and
	p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (
	p_prtt_rt_val_id = g_old_rec.prtt_rt_val_id and
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
  p_prtt_rt_val_id                     in number,
  p_object_version_number              in number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select 	prtt_rt_val_id,
      null,
	rt_strt_dt,
	rt_end_dt,
	rt_typ_cd,
	tx_typ_cd,
	ordr_num,
	acty_typ_cd,
	mlt_cd,
	acty_ref_perd_cd,
	rt_val,
	ann_rt_val,
	cmcd_rt_val,
	cmcd_ref_perd_cd,
	bnft_rt_typ_cd,
	dsply_on_enrt_flag,
	rt_ovridn_flag,
	rt_ovridn_thru_dt,
	elctns_made_dt,
	prtt_rt_val_stat_cd,
	prtt_enrt_rslt_id,
	cvg_amt_calc_mthd_id,
	actl_prem_id,
	comp_lvl_fctr_id,
	element_entry_value_id,
	per_in_ler_id,
	ended_per_in_ler_id,
        acty_base_rt_id,
        prtt_reimbmt_rqst_id,
        prtt_rmt_aprvd_fr_pymt_id,
        pp_in_yr_used_num,
	business_group_id,
	prv_attribute_category,
	prv_attribute1,
	prv_attribute2,
	prv_attribute3,
	prv_attribute4,
	prv_attribute5,
	prv_attribute6,
	prv_attribute7,
	prv_attribute8,
	prv_attribute9,
	prv_attribute10,
	prv_attribute11,
	prv_attribute12,
	prv_attribute13,
	prv_attribute14,
	prv_attribute15,
	prv_attribute16,
	prv_attribute17,
	prv_attribute18,
	prv_attribute19,
	prv_attribute20,
	prv_attribute21,
	prv_attribute22,
	prv_attribute23,
	prv_attribute24,
	prv_attribute25,
	prv_attribute26,
	prv_attribute27,
	prv_attribute28,
	prv_attribute29,
	prv_attribute30,
        pk_id_table_name,
        pk_id,
	object_version_number
    from	ben_prtt_rt_val
    where	prtt_rt_val_id = p_prtt_rt_val_id
    for	update nowait;
--
  l_proc	varchar2(72) := g_package||'lck';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  -- Ensure that all the mandatory arguments are not null
  --
  hr_api.mandatory_arg_error(p_api_name       => l_proc,
                             p_argument       => 'prtt_rt_val_id',
                             p_argument_value => p_prtt_rt_val_id);
  --
  hr_api.mandatory_arg_error(p_api_name       => l_proc,
                             p_argument       => 'object_version_number',
                             p_argument_value => p_object_version_number);
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
    fnd_message.set_token('TABLE_NAME', 'ben_prtt_rt_val');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
	(
	p_prtt_rt_val_id                in number,
	p_enrt_rt_id			in number,
	p_rt_strt_dt                    in date,
	p_rt_end_dt                     in date,
	p_rt_typ_cd                     in varchar2,
	p_tx_typ_cd                     in varchar2,
	p_ordr_num			in number,
	p_acty_typ_cd                   in varchar2,
	p_mlt_cd                        in varchar2,
	p_acty_ref_perd_cd              in varchar2,
	p_rt_val                        in number,
	p_ann_rt_val                    in number,
	p_cmcd_rt_val                   in number,
	p_cmcd_ref_perd_cd              in varchar2,
	p_bnft_rt_typ_cd                in varchar2,
	p_dsply_on_enrt_flag            in varchar2,
	p_rt_ovridn_flag                in varchar2,
	p_rt_ovridn_thru_dt             in date,
	p_elctns_made_dt                in date,
	p_prtt_rt_val_stat_cd           in varchar2,
	p_prtt_enrt_rslt_id             in number,
	p_cvg_amt_calc_mthd_id          in number,
	p_actl_prem_id                  in number,
	p_comp_lvl_fctr_id              in number,
	p_element_entry_value_id        in number,
	p_per_in_ler_id                 in number,
	p_ended_per_in_ler_id           in number,
	p_acty_base_rt_id               in number,
	p_prtt_reimbmt_rqst_id          in number,
        p_prtt_rmt_aprvd_fr_pymt_id     in number,
        p_pp_in_yr_used_num             in  number,
	p_business_group_id             in number,
	p_prv_attribute_category        in varchar2,
	p_prv_attribute1                in varchar2,
	p_prv_attribute2                in varchar2,
	p_prv_attribute3                in varchar2,
	p_prv_attribute4                in varchar2,
	p_prv_attribute5                in varchar2,
	p_prv_attribute6                in varchar2,
	p_prv_attribute7                in varchar2,
	p_prv_attribute8                in varchar2,
	p_prv_attribute9                in varchar2,
	p_prv_attribute10               in varchar2,
	p_prv_attribute11               in varchar2,
	p_prv_attribute12               in varchar2,
	p_prv_attribute13               in varchar2,
	p_prv_attribute14               in varchar2,
	p_prv_attribute15               in varchar2,
	p_prv_attribute16               in varchar2,
	p_prv_attribute17               in varchar2,
	p_prv_attribute18               in varchar2,
	p_prv_attribute19               in varchar2,
	p_prv_attribute20               in varchar2,
	p_prv_attribute21               in varchar2,
	p_prv_attribute22               in varchar2,
	p_prv_attribute23               in varchar2,
	p_prv_attribute24               in varchar2,
	p_prv_attribute25               in varchar2,
	p_prv_attribute26               in varchar2,
	p_prv_attribute27               in varchar2,
	p_prv_attribute28               in varchar2,
	p_prv_attribute29               in varchar2,
	p_prv_attribute30               in varchar2,
	p_pk_id_table_name              in varchar2,
	p_pk_id                         in number ,
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
  l_rec.prtt_rt_val_id                   := p_prtt_rt_val_id;
  l_rec.enrt_rt_id			 := p_enrt_rt_id;
  l_rec.rt_strt_dt                       := p_rt_strt_dt;
  l_rec.rt_end_dt                        := p_rt_end_dt;
  l_rec.rt_typ_cd                        := p_rt_typ_cd;
  l_rec.tx_typ_cd                        := p_tx_typ_cd;
  l_rec.ordr_num			 := p_ordr_num;
  l_rec.acty_typ_cd                      := p_acty_typ_cd;
  l_rec.mlt_cd                           := p_mlt_cd;
  l_rec.acty_ref_perd_cd                 := p_acty_ref_perd_cd;
  l_rec.rt_val                           := p_rt_val;
  l_rec.ann_rt_val                       := p_ann_rt_val;
  l_rec.cmcd_rt_val                      := p_cmcd_rt_val;
  l_rec.cmcd_ref_perd_cd                 := p_cmcd_ref_perd_cd;
  l_rec.bnft_rt_typ_cd                   := p_bnft_rt_typ_cd;
  l_rec.dsply_on_enrt_flag               := p_dsply_on_enrt_flag;
  l_rec.rt_ovridn_flag                   := p_rt_ovridn_flag;
  l_rec.rt_ovridn_thru_dt                := p_rt_ovridn_thru_dt;
  l_rec.elctns_made_dt                   := p_elctns_made_dt;
  l_rec.prtt_rt_val_stat_cd              := p_prtt_rt_val_stat_cd;
  l_rec.prtt_enrt_rslt_id                := p_prtt_enrt_rslt_id;
  l_rec.cvg_amt_calc_mthd_id             := p_cvg_amt_calc_mthd_id;
  l_rec.actl_prem_id                     := p_actl_prem_id;
  l_rec.comp_lvl_fctr_id                 := p_comp_lvl_fctr_id;
  l_rec.element_entry_value_id           := p_element_entry_value_id;
  l_rec.per_in_ler_id                    := p_per_in_ler_id;
  l_rec.ended_per_in_ler_id              := p_ended_per_in_ler_id;
  l_rec.acty_base_rt_id                  := p_acty_base_rt_id;
  l_rec.prtt_reimbmt_rqst_id             := p_prtt_reimbmt_rqst_id;
  l_rec.prtt_rmt_aprvd_fr_pymt_id        := p_prtt_rmt_aprvd_fr_pymt_id;
  l_rec.pp_in_yr_used_num                := p_pp_in_yr_used_num;
  l_rec.business_group_id                := p_business_group_id;
  l_rec.prv_attribute_category           := p_prv_attribute_category;
  l_rec.prv_attribute1                   := p_prv_attribute1;
  l_rec.prv_attribute2                   := p_prv_attribute2;
  l_rec.prv_attribute3                   := p_prv_attribute3;
  l_rec.prv_attribute4                   := p_prv_attribute4;
  l_rec.prv_attribute5                   := p_prv_attribute5;
  l_rec.prv_attribute6                   := p_prv_attribute6;
  l_rec.prv_attribute7                   := p_prv_attribute7;
  l_rec.prv_attribute8                   := p_prv_attribute8;
  l_rec.prv_attribute9                   := p_prv_attribute9;
  l_rec.prv_attribute10                  := p_prv_attribute10;
  l_rec.prv_attribute11                  := p_prv_attribute11;
  l_rec.prv_attribute12                  := p_prv_attribute12;
  l_rec.prv_attribute13                  := p_prv_attribute13;
  l_rec.prv_attribute14                  := p_prv_attribute14;
  l_rec.prv_attribute15                  := p_prv_attribute15;
  l_rec.prv_attribute16                  := p_prv_attribute16;
  l_rec.prv_attribute17                  := p_prv_attribute17;
  l_rec.prv_attribute18                  := p_prv_attribute18;
  l_rec.prv_attribute19                  := p_prv_attribute19;
  l_rec.prv_attribute20                  := p_prv_attribute20;
  l_rec.prv_attribute21                  := p_prv_attribute21;
  l_rec.prv_attribute22                  := p_prv_attribute22;
  l_rec.prv_attribute23                  := p_prv_attribute23;
  l_rec.prv_attribute24                  := p_prv_attribute24;
  l_rec.prv_attribute25                  := p_prv_attribute25;
  l_rec.prv_attribute26                  := p_prv_attribute26;
  l_rec.prv_attribute27                  := p_prv_attribute27;
  l_rec.prv_attribute28                  := p_prv_attribute28;
  l_rec.prv_attribute29                  := p_prv_attribute29;
  l_rec.prv_attribute30                  := p_prv_attribute30;
  l_rec.pk_id_table_name                 := p_pk_id_table_name ;
  l_rec.pk_id                            := p_pk_id;
  l_rec.object_version_number            := p_object_version_number;
  --
  -- Return the plsql record structure.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  Return(l_rec);
--
End convert_args;
--
end ben_prv_shd;

/
