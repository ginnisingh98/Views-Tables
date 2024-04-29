--------------------------------------------------------
--  DDL for Package Body BEN_EPE_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_EPE_SHD" as
/* $Header: beeperhi.pkb 120.0 2005/05/28 02:36:58 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_epe_shd.';  -- Global package name
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
  --
  If (p_constraint_name = 'BEN_ELIG_PER_ELCTBL_CHC_DT1') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','10');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'BEN_ELIG_PER_ELCTBL_CHC_DT2') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'BEN_ELIG_PER_ELCTBL_CHC_DT3') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'BEN_ELIG_PER_ELCTBL_CHC_DT4') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'BEN_ELIG_PER_ELCTBL_CHC_DT5') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'BEN_ELIG_PER_ELCTBL_CHC_DT6') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'BEN_ELIG_PER_ELCTBL_CHC_DT7') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'BEN_ELIG_PER_ELCTBL_CHC_DT8') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'BEN_ELIG_PER_ELCTBL_CHC_DT9') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'BEN_ELIG_PER_ELCTBL_CHC_DT10') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'BEN_ELIG_PER_ELCTBL_CHC_DT11') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'BEN_ELIG_PER_ELCTBL_CHC_DT12') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'BEN_ELIG_PER_ELCTBL_CHC_DT13') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'BEN_ELIG_PER_ELCTBL_CHC_DT14') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'BEN_ELIG_PER_ELCTBL_CHC_DT15') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'BEN_ELIG_PER_ELCTBL_CHC_DT16') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'BEN_ELIG_PER_ELCTBL_CHC_FK15') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'BEN_ELIG_PER_ELCTBL_CHC_FK18') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'BEN_ELIG_PER_ELCTBL_CHC_PK') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','5');
    hr_utility.raise_error;
  Else
    hr_utility.set_message(801, 'HR_7877_API_INVALID_CONSTRAINT');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('CONSTRAINT_NAME', p_constraint_name);
    hr_utility.raise_error;
  End If;
  --
End constraint_error;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< api_updating >-----------------------------|
-- ----------------------------------------------------------------------------
Function api_updating
  (
  p_elig_per_elctbl_chc_id             in number,
  p_object_version_number              in number
  )      Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
	elig_per_elctbl_chc_id,
--	enrt_typ_cycl_cd,
	enrt_cvg_strt_dt_cd,
--	enrt_perd_end_dt,
--	enrt_perd_strt_dt,
	enrt_cvg_strt_dt_rl,
--	rt_strt_dt,
--	rt_strt_dt_rl,
--	rt_strt_dt_cd,
        ctfn_rqd_flag,
        pil_elctbl_chc_popl_id,
	roll_crs_flag,
	crntly_enrd_flag,
	dflt_flag,
	elctbl_flag,
	mndtry_flag,
        in_pndg_wkflow_flag,
--	dflt_enrt_dt,
	dpnt_cvg_strt_dt_cd,
	dpnt_cvg_strt_dt_rl,
	enrt_cvg_strt_dt,
	alws_dpnt_dsgn_flag,
	dpnt_dsgn_cd,
	ler_chg_dpnt_cvg_cd,
	erlst_deenrt_dt,
	procg_end_dt,
	comp_lvl_cd,
	pl_id,
	oipl_id,
	pgm_id,
	plip_id,
	ptip_id,
	pl_typ_id,
	oiplip_id,
	cmbn_plip_id,
	cmbn_ptip_id,
	cmbn_ptip_opt_id,
        assignment_id,
	spcl_rt_pl_id,
	spcl_rt_oipl_id,
	must_enrl_anthr_pl_id,
	interim_elig_per_elctbl_chc_id,
	prtt_enrt_rslt_id,
	bnft_prvdr_pool_id,
	per_in_ler_id,
	yr_perd_id,
        auto_enrt_flag,
	business_group_id,
        pl_ordr_num,
        plip_ordr_num,
        ptip_ordr_num,
        oipl_ordr_num,
        -- cwb
        comments,
        elig_flag,
        elig_ovrid_dt,
        elig_ovrid_person_id,
        inelig_rsn_cd,
        mgr_ovrid_dt,
        mgr_ovrid_person_id,
        ws_mgr_id,
        -- cwb
	epe_attribute_category,
	epe_attribute1,
	epe_attribute2,
	epe_attribute3,
	epe_attribute4,
	epe_attribute5,
	epe_attribute6,
	epe_attribute7,
	epe_attribute8,
	epe_attribute9,
	epe_attribute10,
	epe_attribute11,
	epe_attribute12,
	epe_attribute13,
	epe_attribute14,
	epe_attribute15,
	epe_attribute16,
	epe_attribute17,
	epe_attribute18,
	epe_attribute19,
	epe_attribute20,
	epe_attribute21,
	epe_attribute22,
	epe_attribute23,
	epe_attribute24,
	epe_attribute25,
	epe_attribute26,
	epe_attribute27,
	epe_attribute28,
	epe_attribute29,
	epe_attribute30,
	approval_status_cd,
        fonm_cvg_strt_dt,
        cryfwd_elig_dpnt_cd,
	request_id,
	program_application_id,
	program_id,
	program_update_date,
	object_version_number
    from	ben_elig_per_elctbl_chc
    where	elig_per_elctbl_chc_id = p_elig_per_elctbl_chc_id;
--
  l_proc	varchar2(72)	:= g_package||'api_updating';
  l_fct_ret	boolean;
--
Begin
/*
  hr_utility.set_location('Entering:'||l_proc, 5);
*/
  --
  If (
	p_elig_per_elctbl_chc_id is null and
	p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (
	p_elig_per_elctbl_chc_id = g_old_rec.elig_per_elctbl_chc_id and
	p_object_version_number = g_old_rec.object_version_number
       ) Then
/*
      hr_utility.set_location(l_proc, 10);
*/
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
/*
      hr_utility.set_location(l_proc, 15);
*/
      l_fct_ret := true;
    End If;
  End If;
/*
  hr_utility.set_location(' Leaving:'||l_proc, 20);
*/
  Return (l_fct_ret);
--
End api_updating;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< lck >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure lck
  (
  p_elig_per_elctbl_chc_id             in number,
  p_object_version_number              in number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select 	elig_per_elctbl_chc_id,
--	enrt_typ_cycl_cd,
	enrt_cvg_strt_dt_cd,
--	enrt_perd_end_dt,
--	enrt_perd_strt_dt,
	enrt_cvg_strt_dt_rl,
--	rt_strt_dt,
--	rt_strt_dt_rl,
--	rt_strt_dt_cd,
        ctfn_rqd_flag,
        pil_elctbl_chc_popl_id,
	roll_crs_flag,
	crntly_enrd_flag,
	dflt_flag,
	elctbl_flag,
	mndtry_flag,
        in_pndg_wkflow_flag,
--	dflt_enrt_dt,
	dpnt_cvg_strt_dt_cd,
	dpnt_cvg_strt_dt_rl,
	enrt_cvg_strt_dt,
	alws_dpnt_dsgn_flag,
	dpnt_dsgn_cd,
	ler_chg_dpnt_cvg_cd,
	erlst_deenrt_dt,
	procg_end_dt,
	comp_lvl_cd,
	pl_id,
	oipl_id,
	pgm_id,
	plip_id,
	ptip_id,
	pl_typ_id,
	oiplip_id,
	cmbn_plip_id,
	cmbn_ptip_id,
	cmbn_ptip_opt_id,
        assignment_id,
	spcl_rt_pl_id,
	spcl_rt_oipl_id,
	must_enrl_anthr_pl_id,
	interim_elig_per_elctbl_chc_id,
	prtt_enrt_rslt_id,
	bnft_prvdr_pool_id,
	per_in_ler_id,
	yr_perd_id,
	auto_enrt_flag,
	business_group_id,
        pl_ordr_num,
        plip_ordr_num,
        ptip_ordr_num,
        oipl_ordr_num,
        -- cwb
        comments,
        elig_flag,
        elig_ovrid_dt,
        elig_ovrid_person_id,
        inelig_rsn_cd,
        mgr_ovrid_dt,
        mgr_ovrid_person_id,
        ws_mgr_id,
        -- cwb
	epe_attribute_category,
	epe_attribute1,
	epe_attribute2,
	epe_attribute3,
	epe_attribute4,
	epe_attribute5,
	epe_attribute6,
	epe_attribute7,
	epe_attribute8,
	epe_attribute9,
	epe_attribute10,
	epe_attribute11,
	epe_attribute12,
	epe_attribute13,
	epe_attribute14,
	epe_attribute15,
	epe_attribute16,
	epe_attribute17,
	epe_attribute18,
	epe_attribute19,
	epe_attribute20,
	epe_attribute21,
	epe_attribute22,
	epe_attribute23,
	epe_attribute24,
	epe_attribute25,
	epe_attribute26,
	epe_attribute27,
	epe_attribute28,
	epe_attribute29,
	epe_attribute30,
	approval_status_cd,
        fonm_cvg_strt_dt,
        cryfwd_elig_dpnt_cd,
	request_id,
	program_application_id,
	program_id,
	program_update_date,
	object_version_number
    from	ben_elig_per_elctbl_chc
    where	elig_per_elctbl_chc_id = p_elig_per_elctbl_chc_id
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
    hr_utility.set_message(805, 'BEN_93618_EPE_OBJECT_LOCKED'); -- Bug 3140549
    --hr_utility.set_message_token('TABLE_NAME', 'ben_elig_per_elctbl_chc');
    hr_utility.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
	(
	p_elig_per_elctbl_chc_id        in number,
--	p_enrt_typ_cycl_cd              in varchar2,
	p_enrt_cvg_strt_dt_cd           in varchar2,
--	p_enrt_perd_end_dt              in date,
--	p_enrt_perd_strt_dt             in date,
	p_enrt_cvg_strt_dt_rl           in varchar2,
--	p_rt_strt_dt                    in date,
--	p_rt_strt_dt_rl                 in varchar2,
--	p_rt_strt_dt_cd                 in varchar2,
        p_ctfn_rqd_flag                 in varchar2,
        p_pil_elctbl_chc_popl_id        in number,
	p_roll_crs_flag                 in varchar2,
	p_crntly_enrd_flag              in varchar2,
	p_dflt_flag                     in varchar2,
	p_elctbl_flag                   in varchar2,
	p_mndtry_flag                   in varchar2,
        p_in_pndg_wkflow_flag           in varchar2,
--	p_dflt_enrt_dt                  in date,
	p_dpnt_cvg_strt_dt_cd           in varchar2,
	p_dpnt_cvg_strt_dt_rl           in varchar2,
	p_enrt_cvg_strt_dt              in date,
	p_alws_dpnt_dsgn_flag           in varchar2,
	p_dpnt_dsgn_cd                  in varchar2,
	p_ler_chg_dpnt_cvg_cd           in varchar2,
	p_erlst_deenrt_dt               in date,
	p_procg_end_dt                  in date,
	p_comp_lvl_cd                   in varchar2,
	p_pl_id                         in number,
	p_oipl_id                       in number,
	p_pgm_id                        in number,
	p_plip_id                       in number,
	p_ptip_id                       in number,
	p_pl_typ_id                     in number,
	p_oiplip_id                     in number,
	p_cmbn_plip_id                  in number,
	p_cmbn_ptip_id                  in number,
	p_cmbn_ptip_opt_id              in number,
        p_assignment_id                 in number,
	p_spcl_rt_pl_id                 in number,
	p_spcl_rt_oipl_id               in number,
	p_must_enrl_anthr_pl_id         in number,
	p_int_elig_per_elctbl_chc_id in number,
	p_prtt_enrt_rslt_id             in number,
	p_bnft_prvdr_pool_id            in number,
	p_per_in_ler_id                 in number,
	p_yr_perd_id                    in number,
	p_auto_enrt_flag                in varchar2,
	p_business_group_id             in number,
	p_pl_ordr_num                   in number,
	p_plip_ordr_num                   in number,
	p_ptip_ordr_num                   in number,
	p_oipl_ordr_num                   in number,
        -- cwb
        p_comments                        in  varchar2,
        p_elig_flag                       in  varchar2,
        p_elig_ovrid_dt                   in  date,
        p_elig_ovrid_person_id            in  number,
        p_inelig_rsn_cd                   in  varchar2,
        p_mgr_ovrid_dt                    in  date,
        p_mgr_ovrid_person_id             in  number,
        p_ws_mgr_id                       in  number,
        -- cwb
	p_epe_attribute_category        in varchar2,
	p_epe_attribute1                in varchar2,
	p_epe_attribute2                in varchar2,
	p_epe_attribute3                in varchar2,
	p_epe_attribute4                in varchar2,
	p_epe_attribute5                in varchar2,
	p_epe_attribute6                in varchar2,
	p_epe_attribute7                in varchar2,
	p_epe_attribute8                in varchar2,
	p_epe_attribute9                in varchar2,
	p_epe_attribute10               in varchar2,
	p_epe_attribute11               in varchar2,
	p_epe_attribute12               in varchar2,
	p_epe_attribute13               in varchar2,
	p_epe_attribute14               in varchar2,
	p_epe_attribute15               in varchar2,
	p_epe_attribute16               in varchar2,
	p_epe_attribute17               in varchar2,
	p_epe_attribute18               in varchar2,
	p_epe_attribute19               in varchar2,
	p_epe_attribute20               in varchar2,
	p_epe_attribute21               in varchar2,
	p_epe_attribute22               in varchar2,
	p_epe_attribute23               in varchar2,
	p_epe_attribute24               in varchar2,
	p_epe_attribute25               in varchar2,
	p_epe_attribute26               in varchar2,
	p_epe_attribute27               in varchar2,
	p_epe_attribute28               in varchar2,
	p_epe_attribute29               in varchar2,
	p_epe_attribute30                  in varchar2,
	p_approval_status_cd               in varchar2,
        p_fonm_cvg_strt_dt              in date,
        p_cryfwd_elig_dpnt_cd           in varchar2,
	p_request_id                    in number,
	p_program_application_id        in number,
	p_program_id                    in number,
	p_program_update_date           in date,
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
  l_rec.elig_per_elctbl_chc_id           := p_elig_per_elctbl_chc_id;
--  l_rec.enrt_typ_cycl_cd                 := p_enrt_typ_cycl_cd;
  l_rec.enrt_cvg_strt_dt_cd              := p_enrt_cvg_strt_dt_cd;
--  l_rec.enrt_perd_end_dt                 := p_enrt_perd_end_dt;
--  l_rec.enrt_perd_strt_dt                := p_enrt_perd_strt_dt;
  l_rec.enrt_cvg_strt_dt_rl              := p_enrt_cvg_strt_dt_rl;
--  l_rec.rt_strt_dt                       := p_rt_strt_dt;
--  l_rec.rt_strt_dt_rl                    := p_rt_strt_dt_rl;
--  l_rec.rt_strt_dt_cd                    := p_rt_strt_dt_cd;
  l_rec.ctfn_rqd_flag                        := p_ctfn_rqd_flag;
  l_rec.pil_elctbl_chc_popl_id               := p_pil_elctbl_chc_popl_id;
  l_rec.roll_crs_flag               := p_roll_crs_flag;
  l_rec.crntly_enrd_flag                 := p_crntly_enrd_flag;
  l_rec.dflt_flag                        := p_dflt_flag;
  l_rec.elctbl_flag                      := p_elctbl_flag;
  l_rec.mndtry_flag                      := p_mndtry_flag;
  l_rec.in_pndg_wkflow_flag              := p_in_pndg_wkflow_flag;
-- l_rec.dflt_enrt_dt                     := p_dflt_enrt_dt;
  l_rec.dpnt_cvg_strt_dt_cd              := p_dpnt_cvg_strt_dt_cd;
  l_rec.dpnt_cvg_strt_dt_rl              := p_dpnt_cvg_strt_dt_rl;
  l_rec.enrt_cvg_strt_dt                 := p_enrt_cvg_strt_dt;
  l_rec.alws_dpnt_dsgn_flag              := p_alws_dpnt_dsgn_flag;
  l_rec.dpnt_dsgn_cd                     := p_dpnt_dsgn_cd;
  l_rec.ler_chg_dpnt_cvg_cd              := p_ler_chg_dpnt_cvg_cd;
  l_rec.erlst_deenrt_dt                  := p_erlst_deenrt_dt;
  l_rec.procg_end_dt                     := p_procg_end_dt;
  l_rec.comp_lvl_cd                      := p_comp_lvl_cd;
  l_rec.pl_id                            := p_pl_id;
  l_rec.oipl_id                          := p_oipl_id;
  l_rec.pgm_id                           := p_pgm_id;
  l_rec.plip_id                          := p_plip_id;
  l_rec.ptip_id                          := p_ptip_id;
  l_rec.pl_typ_id                        := p_pl_typ_id;
  l_rec.oiplip_id                        := p_oiplip_id;
  l_rec.cmbn_plip_id                     := p_cmbn_plip_id;
  l_rec.cmbn_ptip_id                     := p_cmbn_ptip_id;
  l_rec.cmbn_ptip_opt_id                 := p_cmbn_ptip_opt_id;
  l_rec.assignment_id                    := p_assignment_id;
  l_rec.spcl_rt_pl_id                    := p_spcl_rt_pl_id;
  l_rec.spcl_rt_oipl_id                  := p_spcl_rt_oipl_id;
  l_rec.must_enrl_anthr_pl_id            := p_must_enrl_anthr_pl_id;
  l_rec.int_elig_per_elctbl_chc_id   := p_int_elig_per_elctbl_chc_id;
  l_rec.prtt_enrt_rslt_id                := p_prtt_enrt_rslt_id;
  l_rec.bnft_prvdr_pool_id               := p_bnft_prvdr_pool_id;
  l_rec.per_in_ler_id                    := p_per_in_ler_id;
  l_rec.yr_perd_id                       := p_yr_perd_id;
  l_rec.auto_enrt_flag                   := p_auto_enrt_flag;
  l_rec.business_group_id                := p_business_group_id;
  l_rec.pl_ordr_num                      := p_pl_ordr_num;
  l_rec.plip_ordr_num                      := p_plip_ordr_num;
  l_rec.ptip_ordr_num                      := p_ptip_ordr_num;
  l_rec.oipl_ordr_num                      := p_oipl_ordr_num;
  -- cwb
  l_rec.comments                        :=       p_comments;
  l_rec.elig_flag                       :=       p_elig_flag;
  l_rec.elig_ovrid_dt                   :=       p_elig_ovrid_dt;
  l_rec.elig_ovrid_person_id            :=       p_elig_ovrid_person_id;
  l_rec.inelig_rsn_cd                   :=       p_inelig_rsn_cd;
  l_rec.mgr_ovrid_dt                    :=       p_mgr_ovrid_dt;
  l_rec.mgr_ovrid_person_id             :=       p_mgr_ovrid_person_id;
  l_rec.ws_mgr_id                       :=       p_ws_mgr_id;
  -- cwb
  l_rec.epe_attribute_category           := p_epe_attribute_category;
  l_rec.epe_attribute1                   := p_epe_attribute1;
  l_rec.epe_attribute2                   := p_epe_attribute2;
  l_rec.epe_attribute3                   := p_epe_attribute3;
  l_rec.epe_attribute4                   := p_epe_attribute4;
  l_rec.epe_attribute5                   := p_epe_attribute5;
  l_rec.epe_attribute6                   := p_epe_attribute6;
  l_rec.epe_attribute7                   := p_epe_attribute7;
  l_rec.epe_attribute8                   := p_epe_attribute8;
  l_rec.epe_attribute9                   := p_epe_attribute9;
  l_rec.epe_attribute10                  := p_epe_attribute10;
  l_rec.epe_attribute11                  := p_epe_attribute11;
  l_rec.epe_attribute12                  := p_epe_attribute12;
  l_rec.epe_attribute13                  := p_epe_attribute13;
  l_rec.epe_attribute14                  := p_epe_attribute14;
  l_rec.epe_attribute15                  := p_epe_attribute15;
  l_rec.epe_attribute16                  := p_epe_attribute16;
  l_rec.epe_attribute17                  := p_epe_attribute17;
  l_rec.epe_attribute18                  := p_epe_attribute18;
  l_rec.epe_attribute19                  := p_epe_attribute19;
  l_rec.epe_attribute20                  := p_epe_attribute20;
  l_rec.epe_attribute21                  := p_epe_attribute21;
  l_rec.epe_attribute22                  := p_epe_attribute22;
  l_rec.epe_attribute23                  := p_epe_attribute23;
  l_rec.epe_attribute24                  := p_epe_attribute24;
  l_rec.epe_attribute25                  := p_epe_attribute25;
  l_rec.epe_attribute26                  := p_epe_attribute26;
  l_rec.epe_attribute27                  := p_epe_attribute27;
  l_rec.epe_attribute28                  := p_epe_attribute28;
  l_rec.epe_attribute29                  := p_epe_attribute29;
  l_rec.epe_attribute30                  := p_epe_attribute30;
  l_rec.approval_status_cd                  := p_approval_status_cd;
  l_rec.fonm_cvg_strt_dt                 := p_fonm_cvg_strt_dt;
  l_rec.cryfwd_elig_dpnt_cd              := p_cryfwd_elig_dpnt_cd;
  l_rec.request_id                       := p_request_id;
  l_rec.program_application_id           := p_program_application_id;
  l_rec.program_id                       := p_program_id;
  l_rec.program_update_date              := p_program_update_date;
  l_rec.object_version_number            := p_object_version_number;
  --
  -- Return the plsql record structure.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  Return(l_rec);
--
End convert_args;
--
end ben_epe_shd;

/
