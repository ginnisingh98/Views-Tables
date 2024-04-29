--------------------------------------------------------
--  DDL for Package Body BEN_ECR_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_ECR_SHD" as
/* $Header: beecrrhi.pkb 115.21 2002/12/27 20:59:56 pabodla ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_ecr_shd.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------------------------< return_api_dml_status >-------------------------|
-- ----------------------------------------------------------------------------
Function return_api_dml_status Return Boolean Is
--
  l_proc 	varchar2(72) := g_package||'return_api_dml_status';
--
Begin
  --hr_utility.set_location('Entering:'||l_proc, 5);
  --
  Return (nvl(g_api_dml, false));
  --
  --hr_utility.set_location(' Leaving:'||l_proc, 10);
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
  If (p_constraint_name = 'ASN_ON_ENRT_FLAG_FLG1') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','5');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'BEN_ENRT_RT_FK1') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','10');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'BEN_ENRT_RT_FK3') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','15');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'BEN_ENRT_RT_PK') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','20');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'DFLT_FLAG_FLGA') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','25');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'DFLT_PNDG_CTFN_FLAG_FLG1') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','30');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'DSPLY_ON_ENRT_FLAG_FLGA') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','35');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'ENTR_VAL_AT_ENRT_FLAG_FLG1') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','40');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'USE_TO_AL_NFC_FLAG_FLG1') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','45');
    hr_utility.raise_error;
  Else
    hr_utility.set_message(801, 'HR_7877_API_INVALID_CONSTRAINT');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('CONSTRAINT_NAME', p_constraint_name);
    hr_utility.raise_error;
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
  p_enrt_rt_id                         in number,
  p_object_version_number              in number
  )      Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
	enrt_rt_id            ,
	ordr_num,
	acty_typ_cd           ,
	tx_typ_cd             ,
	ctfn_rqd_flag         ,
	dflt_flag             ,
	dflt_pndg_ctfn_flag   ,
	dsply_on_enrt_flag    ,
	use_to_calc_net_flx_cr_flag,
	entr_val_at_enrt_flag ,
	asn_on_enrt_flag      ,
	rl_crs_only_flag      ,
	dflt_val              ,
	ann_val               ,
	ann_mn_elcn_val       ,
	ann_mx_elcn_val       ,
	val                   ,
	nnmntry_uom           ,
	mx_elcn_val           ,
	mn_elcn_val           ,
	incrmt_elcn_val       ,
	cmcd_acty_ref_perd_cd ,
	cmcd_mn_elcn_val      ,
	cmcd_mx_elcn_val      ,
	cmcd_val              ,
	cmcd_dflt_val         ,
	rt_usg_cd             ,
	ann_dflt_val          ,
	bnft_rt_typ_cd        ,
	rt_mlt_cd             ,
	dsply_mn_elcn_val     ,
	dsply_mx_elcn_val     ,
	entr_ann_val_flag     ,
	rt_strt_dt            ,
	rt_strt_dt_cd         ,
	rt_strt_dt_rl         ,
	rt_typ_cd             ,
	elig_per_elctbl_chc_id,
	acty_base_rt_id       ,
	spcl_rt_enrt_rt_id    ,
	enrt_bnft_id          ,
	prtt_rt_val_id        ,
	decr_bnft_prvdr_pool_id,
	cvg_amt_calc_mthd_id  ,
	actl_prem_id          ,
	comp_lvl_fctr_id      ,
	ptd_comp_lvl_fctr_id  ,
	clm_comp_lvl_fctr_id  ,
	business_group_id     ,
        --cwb
        iss_val               ,
        val_last_upd_date     ,
        val_last_upd_person_id,
        --cwb
        pp_in_yr_used_num,
	ecr_attribute_category,
	ecr_attribute1        ,
	ecr_attribute2        ,
	ecr_attribute3        ,
	ecr_attribute4        ,
	ecr_attribute5        ,
	ecr_attribute6        ,
	ecr_attribute7        ,
	ecr_attribute8        ,
	ecr_attribute9        ,
	ecr_attribute10       ,
	ecr_attribute11       ,
	ecr_attribute12       ,
	ecr_attribute13       ,
	ecr_attribute14       ,
	ecr_attribute15       ,
	ecr_attribute16       ,
	ecr_attribute17       ,
	ecr_attribute18       ,
	ecr_attribute19       ,
	ecr_attribute20       ,
	ecr_attribute21       ,
	ecr_attribute22       ,
    ecr_attribute23       ,
    ecr_attribute24       ,
    ecr_attribute25       ,
    ecr_attribute26       ,
    ecr_attribute27       ,
    ecr_attribute28       ,
    ecr_attribute29       ,
    ecr_attribute30       ,
    last_update_login     ,
    created_by            ,
    creation_date         ,
    last_updated_by       ,
    last_update_date      ,
    request_id            ,
    program_application_id,
    program_id            ,
    program_update_date   ,
    object_version_number
    from	ben_enrt_rt
    where	enrt_rt_id = p_enrt_rt_id;
--
  l_proc	varchar2(72)	:= g_package||'api_updating';
  l_fct_ret	boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (
	p_enrt_rt_id is null and
	p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (
	p_enrt_rt_id = g_old_rec.enrt_rt_id and
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
  p_enrt_rt_id                         in number,
  p_object_version_number              in number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select
	enrt_rt_id            ,
	ordr_num,
	acty_typ_cd           ,
	tx_typ_cd             ,
	ctfn_rqd_flag         ,
	dflt_flag             ,
	dflt_pndg_ctfn_flag   ,
	dsply_on_enrt_flag    ,
	use_to_calc_net_flx_cr_flag,
	entr_val_at_enrt_flag ,
	asn_on_enrt_flag      ,
	rl_crs_only_flag      ,
	dflt_val              ,
	ann_val               ,
	ann_mn_elcn_val       ,
	ann_mx_elcn_val       ,
	val                   ,
	nnmntry_uom           ,
	mx_elcn_val           ,
	mn_elcn_val           ,
	incrmt_elcn_val       ,
	cmcd_acty_ref_perd_cd ,
	cmcd_mn_elcn_val      ,
	cmcd_mx_elcn_val      ,
	cmcd_val              ,
	cmcd_dflt_val         ,
	rt_usg_cd             ,
	ann_dflt_val          ,
	bnft_rt_typ_cd        ,
	rt_mlt_cd             ,
	dsply_mn_elcn_val     ,
	dsply_mx_elcn_val     ,
	entr_ann_val_flag     ,
	rt_strt_dt            ,
	rt_strt_dt_cd         ,
	rt_strt_dt_rl         ,
	rt_typ_cd             ,
	elig_per_elctbl_chc_id,
	acty_base_rt_id       ,
	spcl_rt_enrt_rt_id    ,
	enrt_bnft_id          ,
	prtt_rt_val_id        ,
	decr_bnft_prvdr_pool_id,
	cvg_amt_calc_mthd_id  ,
	actl_prem_id          ,
	comp_lvl_fctr_id      ,
	ptd_comp_lvl_fctr_id  ,
	clm_comp_lvl_fctr_id  ,
	business_group_id     ,
        --cwb
        iss_val               ,
        val_last_upd_date     ,
        val_last_upd_person_id,
        --cwb
        pp_in_yr_used_num,
	ecr_attribute_category,
	ecr_attribute1        ,
	ecr_attribute2        ,
	ecr_attribute3        ,
	ecr_attribute4        ,
	ecr_attribute5        ,
	ecr_attribute6        ,
	ecr_attribute7        ,
	ecr_attribute8        ,
	ecr_attribute9        ,
	ecr_attribute10       ,
	ecr_attribute11       ,
	ecr_attribute12       ,
	ecr_attribute13       ,
	ecr_attribute14       ,
	ecr_attribute15       ,
	ecr_attribute16       ,
	ecr_attribute17       ,
	ecr_attribute18       ,
	ecr_attribute19       ,
	ecr_attribute20       ,
	ecr_attribute21       ,
	ecr_attribute22       ,
    ecr_attribute23       ,
    ecr_attribute24       ,
    ecr_attribute25       ,
    ecr_attribute26       ,
    ecr_attribute27       ,
    ecr_attribute28       ,
    ecr_attribute29       ,
    ecr_attribute30       ,
    last_update_login     ,
    created_by            ,
    creation_date         ,
    last_updated_by       ,
    last_update_date      ,
    request_id            ,
    program_application_id,
    program_id            ,
    program_update_date   ,
    object_version_number
    from	ben_enrt_rt
    where	enrt_rt_id = p_enrt_rt_id
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
    hr_utility.set_message_token('TABLE_NAME', 'ben_enrt_rt');
    hr_utility.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
	(
	p_enrt_rt_id                  in  NUMBER,
	p_ordr_num			in number,
	p_acty_typ_cd                 in  VARCHAR2,
	p_tx_typ_cd                   in  VARCHAR2,
	p_ctfn_rqd_flag               in  VARCHAR2,
	p_dflt_flag                   in  VARCHAR2,
	p_dflt_pndg_ctfn_flag         in  VARCHAR2,
	p_dsply_on_enrt_flag          in  VARCHAR2,
	p_use_to_calc_net_flx_cr_flag in  VARCHAR2,
	p_entr_val_at_enrt_flag       in  VARCHAR2,
	p_asn_on_enrt_flag            in  VARCHAR2,
	p_rl_crs_only_flag            in  VARCHAR2,
	p_dflt_val                    in  NUMBER,
	p_ann_val                     in  NUMBER,
	p_ann_mn_elcn_val             in  NUMBER,
	p_ann_mx_elcn_val             in  NUMBER,
	p_val                         in  NUMBER,
	p_nnmntry_uom                 in  VARCHAR2,
	p_mx_elcn_val                 in  NUMBER,
	p_mn_elcn_val                 in  NUMBER,
	p_incrmt_elcn_val             in  NUMBER,
	p_cmcd_acty_ref_perd_cd       in  VARCHAR2,
	p_cmcd_mn_elcn_val            in  NUMBER,
	p_cmcd_mx_elcn_val            in  NUMBER,
	p_cmcd_val                    in  NUMBER,
	p_cmcd_dflt_val               in  NUMBER,
	p_rt_usg_cd                   in  VARCHAR2,
	p_ann_dflt_val                in  NUMBER,
	p_bnft_rt_typ_cd              in  VARCHAR2,
	p_rt_mlt_cd                   in  VARCHAR2,
	p_dsply_mn_elcn_val           in  NUMBER,
	p_dsply_mx_elcn_val           in  NUMBER,
	p_entr_ann_val_flag           in  VARCHAR2,
	p_rt_strt_dt                  in  DATE,
	p_rt_strt_dt_cd               in  VARCHAR2,
	p_rt_strt_dt_rl               in  NUMBER,
	p_rt_typ_cd                   in  VARCHAR2,
	p_elig_per_elctbl_chc_id      in  NUMBER,
	p_acty_base_rt_id             in  NUMBER,
	p_spcl_rt_enrt_rt_id          in  NUMBER,
	p_enrt_bnft_id                in  NUMBER,
	p_prtt_rt_val_id              in  NUMBER,
	p_decr_bnft_prvdr_pool_id     in  NUMBER,
	p_cvg_amt_calc_mthd_id        in  NUMBER,
	p_actl_prem_id                in  NUMBER,
	p_comp_lvl_fctr_id            in  NUMBER,
	p_ptd_comp_lvl_fctr_id        in  NUMBER,
	p_clm_comp_lvl_fctr_id        in  NUMBER,
	p_business_group_id           in  NUMBER,
        --cwb
        p_iss_val                     in  number,
        p_val_last_upd_date           in  date,
        p_val_last_upd_person_id      in  number,
        --cwb
        p_pp_in_yr_used_num           in  number,
	p_ecr_attribute_category      in  VARCHAR2,
	p_ecr_attribute1              in  VARCHAR2,
	p_ecr_attribute2              in  VARCHAR2,
	p_ecr_attribute3              in  VARCHAR2,
	p_ecr_attribute4              in  VARCHAR2,
	p_ecr_attribute5              in  VARCHAR2,
	p_ecr_attribute6              in  VARCHAR2,
	p_ecr_attribute7              in  VARCHAR2,
	p_ecr_attribute8              in  VARCHAR2,
	p_ecr_attribute9              in  VARCHAR2,
	p_ecr_attribute10             in  VARCHAR2,
	p_ecr_attribute11             in  VARCHAR2,
	p_ecr_attribute12             in  VARCHAR2,
	p_ecr_attribute13             in  VARCHAR2,
	p_ecr_attribute14             in  VARCHAR2,
	p_ecr_attribute15             in  VARCHAR2,
	p_ecr_attribute16             in  VARCHAR2,
	p_ecr_attribute17             in  VARCHAR2,
	p_ecr_attribute18             in  VARCHAR2,
	p_ecr_attribute19             in  VARCHAR2,
	p_ecr_attribute20             in  VARCHAR2,
	p_ecr_attribute21             in  VARCHAR2,
	p_ecr_attribute22             in  VARCHAR2,
    p_ecr_attribute23             in  VARCHAR2,
    p_ecr_attribute24             in  VARCHAR2,
    p_ecr_attribute25             in  VARCHAR2,
    p_ecr_attribute26             in  VARCHAR2,
    p_ecr_attribute27             in  VARCHAR2,
    p_ecr_attribute28             in  VARCHAR2,
    p_ecr_attribute29             in  VARCHAR2,
    p_ecr_attribute30             in  VARCHAR2,
    p_last_update_login           in  NUMBER,
    p_created_by                  in  NUMBER,
    p_creation_date               in  DATE,
    p_last_updated_by             in  NUMBER,
    p_last_update_date            in  DATE,
    p_request_id                  in  NUMBER,
    p_program_application_id      in  NUMBER,
    p_program_id                  in  NUMBER,
    p_program_update_date         in  DATE,
    p_object_version_number       in  NUMBER
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
  l_rec.enrt_rt_id                   := p_enrt_rt_id;
  l_rec.ordr_num	             := p_ordr_num;
  l_rec.acty_typ_cd                  := p_acty_typ_cd;
  l_rec.tx_typ_cd                    := p_tx_typ_cd;
  l_rec.ctfn_rqd_flag                := p_ctfn_rqd_flag;
  l_rec.dflt_flag                    := p_dflt_flag;
  l_rec.dflt_pndg_ctfn_flag          := p_dflt_pndg_ctfn_flag;
  l_rec.dsply_on_enrt_flag           := p_dsply_on_enrt_flag;
  l_rec.use_to_calc_net_flx_cr_flag  := p_use_to_calc_net_flx_cr_flag;
  l_rec.entr_val_at_enrt_flag        := p_entr_val_at_enrt_flag;
  l_rec.asn_on_enrt_flag             := p_asn_on_enrt_flag;
  l_rec.rl_crs_only_flag             := p_rl_crs_only_flag;
  l_rec.dflt_val                     := p_dflt_val;
  l_rec.ann_val                      := p_ann_val;
  l_rec.ann_mn_elcn_val              := p_ann_mn_elcn_val;
  l_rec.ann_mx_elcn_val              := p_ann_mx_elcn_val;
  l_rec.val                          := p_val;
  l_rec.nnmntry_uom                  := p_nnmntry_uom;
  l_rec.mx_elcn_val                  := p_mx_elcn_val;
  l_rec.mn_elcn_val                  := p_mn_elcn_val;
  l_rec.incrmt_elcn_val              := p_incrmt_elcn_val;
  l_rec.cmcd_acty_ref_perd_cd        := p_cmcd_acty_ref_perd_cd;
  l_rec.cmcd_mn_elcn_val             := p_cmcd_mn_elcn_val;
  l_rec.cmcd_mx_elcn_val             := p_cmcd_mx_elcn_val;
  l_rec.cmcd_val                     := p_cmcd_val;
  l_rec.cmcd_dflt_val                := p_cmcd_dflt_val;
  l_rec.rt_usg_cd                    := p_rt_usg_cd;
  l_rec.ann_dflt_val                 := p_ann_dflt_val;
  l_rec.bnft_rt_typ_cd               := p_bnft_rt_typ_cd;
  l_rec.rt_mlt_cd                    := p_rt_mlt_cd;
  l_rec.dsply_mn_elcn_val            := p_dsply_mn_elcn_val;
  l_rec.dsply_mx_elcn_val            := p_dsply_mx_elcn_val;
  l_rec.entr_ann_val_flag            := p_entr_ann_val_flag;
  l_rec.rt_strt_dt                   := p_rt_strt_dt;
  l_rec.rt_strt_dt_cd                := p_rt_strt_dt_cd;
  l_rec.rt_strt_dt_rl                := p_rt_strt_dt_rl;
  l_rec.rt_typ_cd                    := p_rt_typ_cd;
  l_rec.elig_per_elctbl_chc_id       := p_elig_per_elctbl_chc_id;
  l_rec.acty_base_rt_id              := p_acty_base_rt_id;
  l_rec.spcl_rt_enrt_rt_id           := p_spcl_rt_enrt_rt_id;
  l_rec.enrt_bnft_id                 := p_enrt_bnft_id;
  l_rec.prtt_rt_val_id               := p_prtt_rt_val_id;
  l_rec.decr_bnft_prvdr_pool_id      := p_decr_bnft_prvdr_pool_id;
  l_rec.cvg_amt_calc_mthd_id         := p_cvg_amt_calc_mthd_id;
  l_rec.actl_prem_id                 := p_actl_prem_id;
  l_rec.comp_lvl_fctr_id             := p_comp_lvl_fctr_id;
  l_rec.ptd_comp_lvl_fctr_id         := p_ptd_comp_lvl_fctr_id;
  l_rec.clm_comp_lvl_fctr_id         := p_clm_comp_lvl_fctr_id;
  l_rec.business_group_id            := p_business_group_id;
   --cwb
  l_rec.iss_val                      :=  p_iss_val ;
  l_rec.val_last_upd_date            :=  p_val_last_upd_date ;
  l_rec.val_last_upd_person_id       :=  p_val_last_upd_person_id;
   --cwb
  l_rec.pp_in_yr_used_num            := p_pp_in_yr_used_num;
  l_rec.ecr_attribute_category       := p_ecr_attribute_category;
  l_rec.ecr_attribute1               := p_ecr_attribute1;
  l_rec.ecr_attribute2               := p_ecr_attribute2;
  l_rec.ecr_attribute3               := p_ecr_attribute3;
  l_rec.ecr_attribute4               := p_ecr_attribute4;
  l_rec.ecr_attribute5               := p_ecr_attribute5;
  l_rec.ecr_attribute6               := p_ecr_attribute6;
  l_rec.ecr_attribute7               := p_ecr_attribute7;
  l_rec.ecr_attribute8               := p_ecr_attribute8;
  l_rec.ecr_attribute9               := p_ecr_attribute9;
  l_rec.ecr_attribute10              := p_ecr_attribute10;
  l_rec.ecr_attribute11              := p_ecr_attribute11;
  l_rec.ecr_attribute12              := p_ecr_attribute12;
  l_rec.ecr_attribute13              := p_ecr_attribute13;
  l_rec.ecr_attribute14              := p_ecr_attribute14;
  l_rec.ecr_attribute15              := p_ecr_attribute15;
  l_rec.ecr_attribute16              := p_ecr_attribute16;
  l_rec.ecr_attribute17              := p_ecr_attribute17;
  l_rec.ecr_attribute18              := p_ecr_attribute18;
  l_rec.ecr_attribute19              := p_ecr_attribute19;
  l_rec.ecr_attribute20              := p_ecr_attribute20;
  l_rec.ecr_attribute21              := p_ecr_attribute21;
  l_rec.ecr_attribute22              := p_ecr_attribute22;
  l_rec.ecr_attribute23              := p_ecr_attribute23;
  l_rec.ecr_attribute24              := p_ecr_attribute24;
  l_rec.ecr_attribute25              := p_ecr_attribute25;
  l_rec.ecr_attribute26              := p_ecr_attribute26;
  l_rec.ecr_attribute27              := p_ecr_attribute27;
  l_rec.ecr_attribute28              := p_ecr_attribute28;
  l_rec.ecr_attribute29              := p_ecr_attribute29;
  l_rec.ecr_attribute30              := p_ecr_attribute30;
  l_rec.last_update_login            := p_last_update_login;
  l_rec.created_by                   := p_created_by;
  l_rec.creation_date                := p_creation_date;
  l_rec.last_updated_by              := p_last_updated_by;
  l_rec.last_update_date             := p_last_update_date;
  l_rec.request_id                   := p_request_id;
  l_rec.program_application_id       := p_program_application_id;
  l_rec.program_id                   := p_program_id;
  l_rec.program_update_date          := p_program_update_date;
  l_rec.object_version_number        := p_object_version_number;
  --
  -- Return the plsql record structure.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  Return(l_rec);
--
End convert_args;
--
end ben_ecr_shd;

/
