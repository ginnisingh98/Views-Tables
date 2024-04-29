--------------------------------------------------------
--  DDL for Package Body BEN_ENP_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_ENP_SHD" as
/* $Header: beenprhi.pkb 120.1.12000000.3 2007/05/13 22:36:53 rtagarra noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_enp_shd.';  -- Global package name
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
  If (p_constraint_name = 'BEN_ENRT_PERD_FK1') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','5');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'BEN_ENRT_PERD_FK2') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','10');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'BEN_ENRT_PERD_PK') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','15');
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
  p_enrt_perd_id                       in number,
  p_object_version_number              in number
  )      Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
	enrt_perd_id,
	business_group_id,
	yr_perd_id,
	popl_enrt_typ_cycl_id,
	end_dt,
	strt_dt,
        asnd_lf_evt_dt,
	cls_enrt_dt_to_use_cd,
	dflt_enrt_dt,
	enrt_cvg_strt_dt_cd,
	rt_strt_dt_rl,
	enrt_cvg_end_dt_cd,
	enrt_cvg_strt_dt_rl,
	enrt_cvg_end_dt_rl,
	procg_end_dt,
	rt_strt_dt_cd,
	rt_end_dt_cd,
	rt_end_dt_rl,
        bdgt_upd_strt_dt,
        bdgt_upd_end_dt,
        ws_upd_strt_dt,
        ws_upd_end_dt,
        dflt_ws_acc_cd,
        prsvr_bdgt_cd,
        uses_bdgt_flag,
        auto_distr_flag,
        hrchy_to_use_cd,
        pos_structure_version_id,
        emp_interview_type_cd,
        wthn_yr_perd_id,
        ler_id,
        perf_revw_strt_dt,
        asg_updt_eff_date,
	enp_attribute_category,
	enp_attribute1,
	enp_attribute2,
	enp_attribute3,
	enp_attribute4,
	enp_attribute5,
	enp_attribute6,
	enp_attribute7,
	enp_attribute8,
	enp_attribute9,
	enp_attribute10,
	enp_attribute11,
	enp_attribute12,
	enp_attribute13,
	enp_attribute14,
	enp_attribute15,
	enp_attribute16,
	enp_attribute17,
	enp_attribute18,
	enp_attribute19,
	enp_attribute20,
	enp_attribute21,
	enp_attribute22,
	enp_attribute23,
	enp_attribute24,
	enp_attribute25,
	enp_attribute26,
	enp_attribute27,
	enp_attribute28,
	enp_attribute29,
	enp_attribute30,
	enrt_perd_det_ovrlp_bckdt_cd,
        --cwb
        data_freeze_date   ,
        Sal_chg_reason_cd,
        Approval_mode_cd,
        hrchy_ame_trn_cd,
        hrchy_rl        ,
        hrchy_ame_app_id,
        ---
	object_version_number,
	reinstate_cd,
	reinstate_ovrdn_cd,
	defer_deenrol_flag
    from	ben_enrt_perd
    where	enrt_perd_id = p_enrt_perd_id;
--
  l_proc	varchar2(72)	:= g_package||'api_updating';
  l_fct_ret	boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (
	p_enrt_perd_id is null and
	p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (
	p_enrt_perd_id = g_old_rec.enrt_perd_id and
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
  p_enrt_perd_id                       in number,
  p_object_version_number              in number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select 	enrt_perd_id,
	business_group_id,
	yr_perd_id,
	popl_enrt_typ_cycl_id,
	end_dt,
	strt_dt,
	asnd_lf_evt_Dt,
	cls_enrt_dt_to_use_cd,
	dflt_enrt_dt,
	enrt_cvg_strt_dt_cd,
	rt_strt_dt_rl,
	enrt_cvg_end_dt_cd,
	enrt_cvg_strt_dt_rl,
	enrt_cvg_end_dt_rl,
	procg_end_dt,
	rt_strt_dt_cd,
	rt_end_dt_cd,
	rt_end_dt_rl,
        bdgt_upd_strt_dt,
        bdgt_upd_end_dt,
        ws_upd_strt_dt,
        ws_upd_end_dt,
        dflt_ws_acc_cd,
        prsvr_bdgt_cd,
        uses_bdgt_flag,
        auto_distr_flag,
        hrchy_to_use_cd,
        pos_structure_version_id,
        emp_interview_type_cd,
        wthn_yr_perd_id,
        ler_id,
        perf_revw_strt_dt,
        asg_updt_eff_date,
	enp_attribute_category,
	enp_attribute1,
	enp_attribute2,
	enp_attribute3,
	enp_attribute4,
	enp_attribute5,
	enp_attribute6,
	enp_attribute7,
	enp_attribute8,
	enp_attribute9,
	enp_attribute10,
	enp_attribute11,
	enp_attribute12,
	enp_attribute13,
	enp_attribute14,
	enp_attribute15,
	enp_attribute16,
	enp_attribute17,
	enp_attribute18,
	enp_attribute19,
	enp_attribute20,
	enp_attribute21,
	enp_attribute22,
	enp_attribute23,
	enp_attribute24,
	enp_attribute25,
	enp_attribute26,
	enp_attribute27,
	enp_attribute28,
	enp_attribute29,
	enp_attribute30,
	enrt_perd_det_ovrlp_bckdt_cd,
          --cwb
        data_freeze_date   ,
        Sal_chg_reason_cd,
        Approval_mode_cd,
        hrchy_ame_trn_cd,
        hrchy_rl        ,
        hrchy_ame_app_id,
        ---
	object_version_number,
	reinstate_cd,
	reinstate_ovrdn_cd,
	defer_deenrol_flag
    from	ben_enrt_perd
    where	enrt_perd_id = p_enrt_perd_id
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
    hr_utility.set_message_token('TABLE_NAME', 'ben_enrt_perd');
    hr_utility.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
	(
	p_enrt_perd_id                  in number,
	p_business_group_id             in number,
	p_yr_perd_id                    in number,
	p_popl_enrt_typ_cycl_id         in number,
	p_end_dt                        in date,
	p_strt_dt                       in date,
	p_asnd_lf_evt_dt                in date,
	p_cls_enrt_dt_to_use_cd         in varchar2,
	p_dflt_enrt_dt                  in date,
	p_enrt_cvg_strt_dt_cd           in varchar2,
	p_rt_strt_dt_rl                 in number,
	p_enrt_cvg_end_dt_cd            in varchar2,
	p_enrt_cvg_strt_dt_rl           in number,
	p_enrt_cvg_end_dt_rl            in number,
	p_procg_end_dt                  in date,
	p_rt_strt_dt_cd                 in varchar2,
	p_rt_end_dt_cd                  in varchar2,
	p_rt_end_dt_rl                  in number,
        p_bdgt_upd_strt_dt              in date,
        p_bdgt_upd_end_dt               in date,
        p_ws_upd_strt_dt                in date,
        p_ws_upd_end_dt                 in date,
        p_dflt_ws_acc_cd                in varchar2,
        p_prsvr_bdgt_cd                 in varchar2,
        p_uses_bdgt_flag                in varchar2,
        p_auto_distr_flag               in varchar2,
        p_hrchy_to_use_cd               in varchar2,
        p_pos_structure_version_id         in number,
        p_emp_interview_type_cd         in varchar2,
        p_wthn_yr_perd_id               in number,
        p_ler_id                        in number,
        p_perf_revw_strt_dt             in date,
        p_asg_updt_eff_date             in date,
	p_enp_attribute_category        in varchar2,
	p_enp_attribute1                in varchar2,
	p_enp_attribute2                in varchar2,
	p_enp_attribute3                in varchar2,
	p_enp_attribute4                in varchar2,
	p_enp_attribute5                in varchar2,
	p_enp_attribute6                in varchar2,
	p_enp_attribute7                in varchar2,
	p_enp_attribute8                in varchar2,
	p_enp_attribute9                in varchar2,
	p_enp_attribute10               in varchar2,
	p_enp_attribute11               in varchar2,
	p_enp_attribute12               in varchar2,
	p_enp_attribute13               in varchar2,
	p_enp_attribute14               in varchar2,
	p_enp_attribute15               in varchar2,
	p_enp_attribute16               in varchar2,
	p_enp_attribute17               in varchar2,
	p_enp_attribute18               in varchar2,
	p_enp_attribute19               in varchar2,
	p_enp_attribute20               in varchar2,
	p_enp_attribute21               in varchar2,
	p_enp_attribute22               in varchar2,
	p_enp_attribute23               in varchar2,
	p_enp_attribute24               in varchar2,
	p_enp_attribute25               in varchar2,
	p_enp_attribute26               in varchar2,
	p_enp_attribute27               in varchar2,
	p_enp_attribute28               in varchar2,
	p_enp_attribute29               in varchar2,
	p_enp_attribute30               in varchar2,
	p_enrt_perd_det_ovrlp_bckdt_cd  in varchar2,
        --cwb
        p_data_freeze_date               in  date    ,
        p_Sal_chg_reason_cd              in  varchar2,
        p_Approval_mode_cd               in  varchar2,
        p_hrchy_ame_trn_cd               in  varchar2,
        p_hrchy_rl                       in  number,
        p_hrchy_ame_app_id               in  number,
	p_object_version_number         in number,
	p_reinstate_cd			in varchar2,
	p_reinstate_ovrdn_cd		in varchar2,
	p_defer_deenrol_flag            in varchar2
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
  l_rec.enrt_perd_id                     := p_enrt_perd_id;
  l_rec.business_group_id                := p_business_group_id;
  l_rec.yr_perd_id                       := p_yr_perd_id;
  l_rec.popl_enrt_typ_cycl_id            := p_popl_enrt_typ_cycl_id;
  l_rec.end_dt                           := p_end_dt;
  l_rec.strt_dt                          := p_strt_dt;
  l_rec.asnd_lf_evt_Dt                   := p_asnd_lf_evt_dt;
  l_rec.cls_enrt_dt_to_use_cd            := p_cls_enrt_dt_to_use_cd;
  l_rec.dflt_enrt_dt                     := p_dflt_enrt_dt;
  l_rec.enrt_cvg_strt_dt_cd              := p_enrt_cvg_strt_dt_cd;
  l_rec.rt_strt_dt_rl                    := p_rt_strt_dt_rl;
  l_rec.enrt_cvg_end_dt_cd               := p_enrt_cvg_end_dt_cd;
  l_rec.enrt_cvg_strt_dt_rl              := p_enrt_cvg_strt_dt_rl;
  l_rec.enrt_cvg_end_dt_rl               := p_enrt_cvg_end_dt_rl;
  l_rec.procg_end_dt                     := p_procg_end_dt;
  l_rec.rt_strt_dt_cd                    := p_rt_strt_dt_cd;
  l_rec.rt_end_dt_cd                     := p_rt_end_dt_cd;
  l_rec.rt_end_dt_rl                     := p_rt_end_dt_rl;
  l_rec.bdgt_upd_strt_dt                 := p_bdgt_upd_strt_dt;
  l_rec.bdgt_upd_end_dt                  := p_bdgt_upd_end_dt;
  l_rec.ws_upd_strt_dt                   := p_ws_upd_strt_dt;
  l_rec.ws_upd_end_dt                    := p_ws_upd_end_dt;
  l_rec.dflt_ws_acc_cd                   := p_dflt_ws_acc_cd;
  l_rec.prsvr_bdgt_cd                    := p_prsvr_bdgt_cd;
  l_rec.uses_bdgt_flag                   := p_uses_bdgt_flag;
  l_rec.auto_distr_flag                  := p_auto_distr_flag;
  l_rec.hrchy_to_use_cd                  := p_hrchy_to_use_cd;
  l_rec.pos_structure_version_id            := p_pos_structure_version_id;
  l_rec.emp_interview_type_cd            := p_emp_interview_type_cd;
  l_rec.wthn_yr_perd_id                  := p_wthn_yr_perd_id;
  l_rec.ler_id                           := p_ler_id;
  l_rec.perf_revw_strt_dt                := p_perf_revw_strt_dt;
  l_rec.asg_updt_eff_date                := p_asg_updt_eff_date;
  l_rec.enp_attribute_category           := p_enp_attribute_category;
  l_rec.enp_attribute1                   := p_enp_attribute1;
  l_rec.enp_attribute2                   := p_enp_attribute2;
  l_rec.enp_attribute3                   := p_enp_attribute3;
  l_rec.enp_attribute4                   := p_enp_attribute4;
  l_rec.enp_attribute5                   := p_enp_attribute5;
  l_rec.enp_attribute6                   := p_enp_attribute6;
  l_rec.enp_attribute7                   := p_enp_attribute7;
  l_rec.enp_attribute8                   := p_enp_attribute8;
  l_rec.enp_attribute9                   := p_enp_attribute9;
  l_rec.enp_attribute10                  := p_enp_attribute10;
  l_rec.enp_attribute11                  := p_enp_attribute11;
  l_rec.enp_attribute12                  := p_enp_attribute12;
  l_rec.enp_attribute13                  := p_enp_attribute13;
  l_rec.enp_attribute14                  := p_enp_attribute14;
  l_rec.enp_attribute15                  := p_enp_attribute15;
  l_rec.enp_attribute16                  := p_enp_attribute16;
  l_rec.enp_attribute17                  := p_enp_attribute17;
  l_rec.enp_attribute18                  := p_enp_attribute18;
  l_rec.enp_attribute19                  := p_enp_attribute19;
  l_rec.enp_attribute20                  := p_enp_attribute20;
  l_rec.enp_attribute21                  := p_enp_attribute21;
  l_rec.enp_attribute22                  := p_enp_attribute22;
  l_rec.enp_attribute23                  := p_enp_attribute23;
  l_rec.enp_attribute24                  := p_enp_attribute24;
  l_rec.enp_attribute25                  := p_enp_attribute25;
  l_rec.enp_attribute26                  := p_enp_attribute26;
  l_rec.enp_attribute27                  := p_enp_attribute27;
  l_rec.enp_attribute28                  := p_enp_attribute28;
  l_rec.enp_attribute29                  := p_enp_attribute29;
  l_rec.enp_attribute30                  := p_enp_attribute30;
  l_rec.enrt_perd_det_ovrlp_bckdt_cd     := p_enrt_perd_det_ovrlp_bckdt_cd;
  l_rec.data_freeze_date                 := p_data_freeze_date ;
  l_rec.Sal_chg_reason_cd                := p_Sal_chg_reason_cd ;
  l_rec.Approval_mode_cd                 := p_Approval_mode_cd ;
  l_rec.hrchy_ame_trn_cd                 := p_hrchy_ame_trn_cd ;
  l_rec.hrchy_rl                         := p_hrchy_rl ;
  l_rec.hrchy_ame_app_id                 := p_hrchy_ame_app_id ;
  l_rec.object_version_number            := p_object_version_number;
  l_rec.reinstate_cd		 	 := p_reinstate_cd;
  l_rec.reinstate_ovrdn_cd		 := p_reinstate_ovrdn_cd;
  l_rec.defer_deenrol_flag               := p_defer_deenrol_flag;
  --
  -- Return the plsql record structure.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  Return(l_rec);
--
End convert_args;
--
end ben_enp_shd;

/
