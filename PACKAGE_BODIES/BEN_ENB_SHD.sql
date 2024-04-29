--------------------------------------------------------
--  DDL for Package Body BEN_ENB_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_ENB_SHD" as
/* $Header: beenbrhi.pkb 115.15 2002/12/16 07:02:08 rpgupta ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_enb_shd.';  -- Global package name
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
  If (p_constraint_name = 'BEN_ENRT_BNFT_PK') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','5');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'DFLT_FLAG_FLG') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','15');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'VAL_HAS_BN_FLAG_FLG1') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','20');
    hr_utility.raise_error;
  Else
    hr_utility.set_message(801, 'HR_7877_API_INVALID_CONSTRAINT');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('CONSTRAINT_NAME', p_constraint_name);
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
  p_enrt_bnft_id                       in number,
  p_object_version_number              in number
  )      Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
		 enrt_bnft_id
		,dflt_flag
		,val_has_bn_prortd_flag
		,bndry_perd_cd
		,val
		,nnmntry_uom
		,bnft_typ_cd
		,entr_val_at_enrt_flag
		,mn_val
		,mx_val
		,incrmt_val
                ,dflt_val
		,rt_typ_cd
		,cvg_mlt_cd
		,ctfn_rqd_flag
		,ordr_num
		,crntly_enrld_flag
		,elig_per_elctbl_chc_id
		,prtt_enrt_rslt_id
		,comp_lvl_fctr_id
		,business_group_id
		,enb_attribute_category
		,enb_attribute1
		,enb_attribute2
		,enb_attribute3
		,enb_attribute4
		,enb_attribute5
		,enb_attribute6
		,enb_attribute7
		,enb_attribute8
		,enb_attribute9
		,enb_attribute10
		,enb_attribute11
		,enb_attribute12
		,enb_attribute13
		,enb_attribute14
		,enb_attribute15
		,enb_attribute16
		,enb_attribute17
		,enb_attribute18
		,enb_attribute19
		,enb_attribute20
		,enb_attribute21
		,enb_attribute22
		,enb_attribute23
		,enb_attribute24
		,enb_attribute25
		,enb_attribute26
		,enb_attribute27
		,enb_attribute28
		,enb_attribute29
        ,enb_attribute30
        ,request_id
        ,program_application_id
        ,program_id
        ,mx_wout_ctfn_val
        ,mx_wo_ctfn_flag
        ,program_update_date
        ,object_version_number
    from	ben_enrt_bnft
    where	enrt_bnft_id = p_enrt_bnft_id;

--
  l_proc	varchar2(72)	:= g_package||'api_updating';
  l_fct_ret	boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (
	p_enrt_bnft_id is null and
	p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (
	p_enrt_bnft_id = g_old_rec.enrt_bnft_id and
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
  p_enrt_bnft_id                       in number,
  p_object_version_number              in number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select
		 enrt_bnft_id
		,dflt_flag
		,val_has_bn_prortd_flag
		,bndry_perd_cd
		,val
		,nnmntry_uom
		,bnft_typ_cd
		,entr_val_at_enrt_flag
		,mn_val
		,mx_val
		,incrmt_val
                ,dflt_val
		,rt_typ_cd
		,cvg_mlt_cd
		,ctfn_rqd_flag
		,ordr_num
		,crntly_enrld_flag
		,elig_per_elctbl_chc_id
		,prtt_enrt_rslt_id
		,comp_lvl_fctr_id
		,business_group_id
		,enb_attribute_category
		,enb_attribute1
		,enb_attribute2
		,enb_attribute3
		,enb_attribute4
		,enb_attribute5
		,enb_attribute6
		,enb_attribute7
		,enb_attribute8
		,enb_attribute9
		,enb_attribute10
		,enb_attribute11
		,enb_attribute12
		,enb_attribute13
		,enb_attribute14
		,enb_attribute15
		,enb_attribute16
		,enb_attribute17
		,enb_attribute18
		,enb_attribute19
		,enb_attribute20
		,enb_attribute21
		,enb_attribute22
		,enb_attribute23
		,enb_attribute24
		,enb_attribute25
		,enb_attribute26
		,enb_attribute27
		,enb_attribute28
		,enb_attribute29
        ,enb_attribute30
        ,request_id
        ,program_application_id
        ,program_id
        ,mx_wout_ctfn_val
        ,mx_wo_ctfn_flag
        ,program_update_date
        ,object_version_number
    from	ben_enrt_bnft
    where	enrt_bnft_id = p_enrt_bnft_id
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
    hr_utility.set_message_token('TABLE_NAME', 'ben_enrt_bnft');
    hr_utility.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
 (
   p_enrt_bnft_id                   in  number
  ,p_dflt_flag                      in  varchar2
  ,p_val_has_bn_prortd_flag         in  varchar2
  ,p_bndry_perd_cd                  in  varchar2
  ,p_val                            in  number
  ,p_nnmntry_uom                    in  varchar2
  ,p_bnft_typ_cd                    in  varchar2
  ,p_entr_val_at_enrt_flag          in  varchar2
  ,p_mn_val                         in  number
  ,p_mx_val                         in  number
  ,p_incrmt_val                     in  number
  ,p_dflt_val                       in  number
  ,p_rt_typ_cd                      in  varchar2
  ,p_cvg_mlt_cd                     in  varchar2
  ,p_ctfn_rqd_flag                  in  varchar2
  ,p_ordr_num                       in  number
  ,p_crntly_enrld_flag              in  varchar2
  ,p_elig_per_elctbl_chc_id         in  number
  ,p_prtt_enrt_rslt_id              in  number
  ,p_comp_lvl_fctr_id               in  number
  ,p_business_group_id              in  number
  ,p_enb_attribute_category         in  varchar2
  ,p_enb_attribute1                 in  varchar2
  ,p_enb_attribute2                 in  varchar2
  ,p_enb_attribute3                 in  varchar2
  ,p_enb_attribute4                 in  varchar2
  ,p_enb_attribute5                 in  varchar2
  ,p_enb_attribute6                 in  varchar2
  ,p_enb_attribute7                 in  varchar2
  ,p_enb_attribute8                 in  varchar2
  ,p_enb_attribute9                 in  varchar2
  ,p_enb_attribute10                in  varchar2
  ,p_enb_attribute11                in  varchar2
  ,p_enb_attribute12                in  varchar2
  ,p_enb_attribute13                in  varchar2
  ,p_enb_attribute14                in  varchar2
  ,p_enb_attribute15                in  varchar2
  ,p_enb_attribute16                in  varchar2
  ,p_enb_attribute17                in  varchar2
  ,p_enb_attribute18                in  varchar2
  ,p_enb_attribute19                in  varchar2
  ,p_enb_attribute20                in  varchar2
  ,p_enb_attribute21                in  varchar2
  ,p_enb_attribute22                in  varchar2
  ,p_enb_attribute23                in  varchar2
  ,p_enb_attribute24                in  varchar2
  ,p_enb_attribute25                in  varchar2
  ,p_enb_attribute26                in  varchar2
  ,p_enb_attribute27                in  varchar2
  ,p_enb_attribute28                in  varchar2
  ,p_enb_attribute29                in  varchar2
  ,p_enb_attribute30                in  varchar2
  ,p_request_id                     in  number
  ,p_program_application_id         in  number
  ,p_program_id                     in  number
  ,p_mx_wout_ctfn_val               in  number
  ,p_mx_wo_ctfn_flag                in  varchar2
  ,p_program_update_date            in  date
  ,p_object_version_number          in  number
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
  l_rec.enrt_bnft_id                    := p_enrt_bnft_id          ;
  l_rec.dflt_flag                       := p_dflt_flag             ;
  l_rec.val_has_bn_prortd_flag          := p_val_has_bn_prortd_flag;
  l_rec.bndry_perd_cd                   := p_bndry_perd_cd         ;
  l_rec.val                             := p_val                   ;
  l_rec.nnmntry_uom                     := p_nnmntry_uom           ;
  l_rec.bnft_typ_cd                     := p_bnft_typ_cd           ;
  l_rec.entr_val_at_enrt_flag           := p_entr_val_at_enrt_flag ;
  l_rec.mn_val                          := p_mn_val                ;
  l_rec.mx_val                          := p_mx_val                ;
  l_rec.incrmt_val                      := p_incrmt_val            ;
  l_rec.dflt_val                        := p_dflt_val              ;
  l_rec.rt_typ_cd                       := p_rt_typ_cd             ;
  l_rec.cvg_mlt_cd                      := p_cvg_mlt_cd            ;
  l_rec.ctfn_rqd_flag                   := p_ctfn_rqd_flag         ;
  l_rec.ordr_num                        := p_ordr_num              ;
  l_rec.crntly_enrld_flag               := p_crntly_enrld_flag     ;
  l_rec.elig_per_elctbl_chc_id          := p_elig_per_elctbl_chc_id;
  l_rec.prtt_enrt_rslt_id               := p_prtt_enrt_rslt_id     ;
  l_rec.comp_lvl_fctr_id                := p_comp_lvl_fctr_id      ;
  l_rec.business_group_id               := p_business_group_id     ;
  l_rec.enb_attribute_category          := p_enb_attribute_category;
  l_rec.enb_attribute1                  := p_enb_attribute1        ;
  l_rec.enb_attribute2                  := p_enb_attribute2        ;
  l_rec.enb_attribute3                  := p_enb_attribute3        ;
  l_rec.enb_attribute4                  := p_enb_attribute4        ;
  l_rec.enb_attribute5                  := p_enb_attribute5        ;
  l_rec.enb_attribute6                  := p_enb_attribute6        ;
  l_rec.enb_attribute7                  := p_enb_attribute7        ;
  l_rec.enb_attribute8                  := p_enb_attribute8        ;
  l_rec.enb_attribute9                  := p_enb_attribute9        ;
  l_rec.enb_attribute10                 := p_enb_attribute10       ;
  l_rec.enb_attribute11                 := p_enb_attribute11       ;
  l_rec.enb_attribute12                 := p_enb_attribute12       ;
  l_rec.enb_attribute13                 := p_enb_attribute13       ;
  l_rec.enb_attribute14                 := p_enb_attribute14       ;
  l_rec.enb_attribute15                 := p_enb_attribute15       ;
  l_rec.enb_attribute16                 := p_enb_attribute16       ;
  l_rec.enb_attribute17                 := p_enb_attribute17       ;
  l_rec.enb_attribute18                 := p_enb_attribute18       ;
  l_rec.enb_attribute19                 := p_enb_attribute19       ;
  l_rec.enb_attribute20                 := p_enb_attribute20       ;
  l_rec.enb_attribute21                 := p_enb_attribute21       ;
  l_rec.enb_attribute22                 := p_enb_attribute22       ;
  l_rec.enb_attribute23                 := p_enb_attribute23       ;
  l_rec.enb_attribute24                 := p_enb_attribute24       ;
  l_rec.enb_attribute25                 := p_enb_attribute25       ;
  l_rec.enb_attribute26                 := p_enb_attribute26       ;
  l_rec.enb_attribute27                 := p_enb_attribute27       ;
  l_rec.enb_attribute28                 := p_enb_attribute28       ;
  l_rec.enb_attribute29                 := p_enb_attribute29       ;
  l_rec.enb_attribute30                 := p_enb_attribute30       ;
  l_rec.request_id                      := p_request_id            ;
  l_rec.program_application_id          := p_program_application_id;
  l_rec.program_id                      := p_program_id            ;
  l_rec.mx_wout_ctfn_val                := p_mx_wout_ctfn_val      ;
  l_rec.mx_wo_ctfn_flag                 := p_mx_wo_ctfn_flag       ;
  l_rec.program_update_date             := p_program_update_date   ;
  l_rec.object_version_number           := p_object_version_number ;
  --
  -- Return the plsql record structure.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  Return(l_rec);
--
End convert_args;
--
end ben_enb_shd;

/
