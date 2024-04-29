--------------------------------------------------------
--  DDL for Package Body BEN_CPD_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_CPD_SHD" as
/* $Header: becpdrhi.pkb 120.1.12010000.3 2010/03/12 06:12:31 sgnanama ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  ben_cpd_shd.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------------------------< return_api_dml_status >-------------------------|
-- ----------------------------------------------------------------------------
Function return_api_dml_status Return Boolean Is
--
Begin
  --
  Return (nvl(g_api_dml, false));
  --
End return_api_dml_status;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< constraint_error >---------------------------|
-- ----------------------------------------------------------------------------
Procedure constraint_error
  (p_constraint_name in all_constraints.constraint_name%TYPE
  ) Is
--
  l_proc        varchar2(72) := g_package||'constraint_error';
--
Begin
  --
  If (p_constraint_name = 'BEN_CWB_PL_DSGN_PK') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','5');
    fnd_message.raise_error;
  Else
    fnd_message.set_name('PAY', 'HR_7877_API_INVALID_CONSTRAINT');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('CONSTRAINT_NAME', p_constraint_name);
    fnd_message.raise_error;
  End If;
  --
End constraint_error;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< api_updating >-----------------------------|
-- ----------------------------------------------------------------------------
Function api_updating
  (p_pl_id                                in     number
  ,p_lf_evt_ocrd_dt                       in     date
  ,p_oipl_id                              in     number
  ,p_object_version_number                in     number
  )
  Return Boolean Is
  --
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
       pl_id
      ,lf_evt_ocrd_dt
      ,oipl_id
      ,effective_date
      ,name
      ,group_pl_id
      ,group_oipl_id
      ,opt_hidden_flag
      ,opt_id
      ,pl_uom
      ,pl_ordr_num
      ,oipl_ordr_num
      ,pl_xchg_rate
      ,opt_count
      ,uses_bdgt_flag
      ,prsrv_bdgt_cd
      ,upd_start_dt
      ,upd_end_dt
      ,approval_mode
      ,enrt_perd_start_dt
      ,enrt_perd_end_dt
      ,yr_perd_start_dt
      ,yr_perd_end_dt
      ,wthn_yr_start_dt
      ,wthn_yr_end_dt
      ,enrt_perd_id
      ,yr_perd_id
      ,business_group_id
      ,perf_revw_strt_dt
      ,asg_updt_eff_date
      ,emp_interview_typ_cd
      ,salary_change_reason
      ,ws_abr_id
      ,ws_nnmntry_uom
      ,ws_rndg_cd
      ,ws_sub_acty_typ_cd
      ,dist_bdgt_abr_id
      ,dist_bdgt_nnmntry_uom
      ,dist_bdgt_rndg_cd
      ,ws_bdgt_abr_id
      ,ws_bdgt_nnmntry_uom
      ,ws_bdgt_rndg_cd
      ,rsrv_abr_id
      ,rsrv_nnmntry_uom
      ,rsrv_rndg_cd
      ,elig_sal_abr_id
      ,elig_sal_nnmntry_uom
      ,elig_sal_rndg_cd
      ,misc1_abr_id
      ,misc1_nnmntry_uom
      ,misc1_rndg_cd
      ,misc2_abr_id
      ,misc2_nnmntry_uom
      ,misc2_rndg_cd
      ,misc3_abr_id
      ,misc3_nnmntry_uom
      ,misc3_rndg_cd
      ,stat_sal_abr_id
      ,stat_sal_nnmntry_uom
      ,stat_sal_rndg_cd
      ,rec_abr_id
      ,rec_nnmntry_uom
      ,rec_rndg_cd
      ,tot_comp_abr_id
      ,tot_comp_nnmntry_uom
      ,tot_comp_rndg_cd
      ,oth_comp_abr_id
      ,oth_comp_nnmntry_uom
      ,oth_comp_rndg_cd
      ,actual_flag
      ,acty_ref_perd_cd
      ,legislation_code
      ,pl_annulization_factor
      ,pl_stat_cd
      ,uom_precision
      ,ws_element_type_id
      ,ws_input_value_id
      ,data_freeze_date
      ,ws_amt_edit_cd
      ,ws_amt_edit_enf_cd_for_nulls
      ,ws_over_budget_edit_cd
      ,ws_over_budget_tolerance_pct
      ,bdgt_over_budget_edit_cd
      ,bdgt_over_budget_tolerance_pct
      ,auto_distr_flag
      ,pqh_document_short_name
      ,ovrid_rt_strt_dt
      ,do_not_process_flag
      ,ovr_perf_revw_strt_dt
      ,post_zero_salary_increase
      ,show_appraisals_n_days
      ,grade_range_validation
      ,object_version_number
    from        ben_cwb_pl_dsgn
    where       pl_id = p_pl_id
    and   lf_evt_ocrd_dt = p_lf_evt_ocrd_dt
    and   oipl_id = p_oipl_id;
  --
  l_fct_ret     boolean;
  --
Begin
  --
  If (p_pl_id is null and
      p_lf_evt_ocrd_dt is null and
      p_oipl_id is null and
      p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_pl_id
        = ben_cpd_shd.g_old_rec.pl_id and
        p_lf_evt_ocrd_dt
        = ben_cpd_shd.g_old_rec.lf_evt_ocrd_dt and
        p_oipl_id
        = ben_cpd_shd.g_old_rec.oipl_id and
        p_object_version_number
        = ben_cpd_shd.g_old_rec.object_version_number
       ) Then
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
      Fetch C_Sel1 Into ben_cpd_shd.g_old_rec;
      If C_Sel1%notfound Then
        Close C_Sel1;
        --
        -- The primary key is invalid therefore we must error
        --
        fnd_message.set_name('PAY', 'HR_7220_INVALID_PRIMARY_KEY');
        fnd_message.raise_error;
      End If;
      Close C_Sel1;
      If (p_object_version_number
          <> ben_cpd_shd.g_old_rec.object_version_number) Then
        fnd_message.set_name('PAY', 'HR_7155_OBJECT_INVALID');
        fnd_message.raise_error;
      End If;
      l_fct_ret := true;
    End If;
  End If;
  Return (l_fct_ret);
--
End api_updating;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< lck >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure lck
  (p_pl_id                                in     number
  ,p_lf_evt_ocrd_dt                       in     date
  ,p_oipl_id                              in     number
  ,p_object_version_number                in     number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select
       pl_id
      ,lf_evt_ocrd_dt
      ,oipl_id
      ,effective_date
      ,name
      ,group_pl_id
      ,group_oipl_id
      ,opt_hidden_flag
      ,opt_id
      ,pl_uom
      ,pl_ordr_num
      ,oipl_ordr_num
      ,pl_xchg_rate
      ,opt_count
      ,uses_bdgt_flag
      ,prsrv_bdgt_cd
      ,upd_start_dt
      ,upd_end_dt
      ,approval_mode
      ,enrt_perd_start_dt
      ,enrt_perd_end_dt
      ,yr_perd_start_dt
      ,yr_perd_end_dt
      ,wthn_yr_start_dt
      ,wthn_yr_end_dt
      ,enrt_perd_id
      ,yr_perd_id
      ,business_group_id
      ,perf_revw_strt_dt
      ,asg_updt_eff_date
      ,emp_interview_typ_cd
      ,salary_change_reason
      ,ws_abr_id
      ,ws_nnmntry_uom
      ,ws_rndg_cd
      ,ws_sub_acty_typ_cd
      ,dist_bdgt_abr_id
      ,dist_bdgt_nnmntry_uom
      ,dist_bdgt_rndg_cd
      ,ws_bdgt_abr_id
      ,ws_bdgt_nnmntry_uom
      ,ws_bdgt_rndg_cd
      ,rsrv_abr_id
      ,rsrv_nnmntry_uom
      ,rsrv_rndg_cd
      ,elig_sal_abr_id
      ,elig_sal_nnmntry_uom
      ,elig_sal_rndg_cd
      ,misc1_abr_id
      ,misc1_nnmntry_uom
      ,misc1_rndg_cd
      ,misc2_abr_id
      ,misc2_nnmntry_uom
      ,misc2_rndg_cd
      ,misc3_abr_id
      ,misc3_nnmntry_uom
      ,misc3_rndg_cd
      ,stat_sal_abr_id
      ,stat_sal_nnmntry_uom
      ,stat_sal_rndg_cd
      ,rec_abr_id
      ,rec_nnmntry_uom
      ,rec_rndg_cd
      ,tot_comp_abr_id
      ,tot_comp_nnmntry_uom
      ,tot_comp_rndg_cd
      ,oth_comp_abr_id
      ,oth_comp_nnmntry_uom
      ,oth_comp_rndg_cd
      ,actual_flag
      ,acty_ref_perd_cd
      ,legislation_code
      ,pl_annulization_factor
      ,pl_stat_cd
      ,uom_precision
      ,ws_element_type_id
      ,ws_input_value_id
      ,data_freeze_date
      ,ws_amt_edit_cd
      ,ws_amt_edit_enf_cd_for_nulls
      ,ws_over_budget_edit_cd
      ,ws_over_budget_tolerance_pct
      ,bdgt_over_budget_edit_cd
      ,bdgt_over_budget_tolerance_pct
      ,auto_distr_flag
      ,pqh_document_short_name
      ,ovrid_rt_strt_dt
      ,do_not_process_flag
      ,ovr_perf_revw_strt_dt
      ,post_zero_salary_increase
      ,show_appraisals_n_days
      ,grade_range_validation
      ,object_version_number
    from        ben_cwb_pl_dsgn
    where       pl_id = p_pl_id
    and   lf_evt_ocrd_dt = p_lf_evt_ocrd_dt
    and   oipl_id = p_oipl_id
    for update nowait;
--
  l_proc        varchar2(72) := g_package||'lck';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'PL_ID'
    ,p_argument_value     => p_pl_id
    );
  hr_utility.set_location(l_proc,6);
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'LF_EVT_OCRD_DT'
    ,p_argument_value     => p_lf_evt_ocrd_dt
    );
  hr_utility.set_location(l_proc,7);
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'OIPL_ID'
    ,p_argument_value     => p_oipl_id
    );
  hr_utility.set_location(l_proc,8);
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'OBJECT_VERSION_NUMBER'
    ,p_argument_value     => p_object_version_number
    );
  --
  Open  C_Sel1;
  Fetch C_Sel1 Into ben_cpd_shd.g_old_rec;
  If C_Sel1%notfound then
    Close C_Sel1;
    --
    -- The primary key is invalid therefore we must error
    --
    fnd_message.set_name('PAY', 'HR_7220_INVALID_PRIMARY_KEY');
    fnd_message.raise_error;
  End If;
  Close C_Sel1;
hr_utility.set_location('ovn : '||p_object_version_number,999);
hr_utility.set_location('old ovn : '||ben_cpd_shd.g_old_rec.object_version_number,999);
  If (p_object_version_number
      <> ben_cpd_shd.g_old_rec.object_version_number) Then
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
    fnd_message.set_token('TABLE_NAME', 'ben_cwb_pl_dsgn');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
  (p_pl_id                          in number
  ,p_oipl_id                        in number
  ,p_lf_evt_ocrd_dt                 in date
  ,p_effective_date                 in date
  ,p_name                           in varchar2
  ,p_group_pl_id                    in number
  ,p_group_oipl_id                  in number
  ,p_opt_hidden_flag                in varchar2
  ,p_opt_id                         in number
  ,p_pl_uom                         in varchar2
  ,p_pl_ordr_num                    in number
  ,p_oipl_ordr_num                  in number
  ,p_pl_xchg_rate                   in number
  ,p_opt_count                      in number
  ,p_uses_bdgt_flag                 in varchar2
  ,p_prsrv_bdgt_cd                  in varchar2
  ,p_upd_start_dt                   in date
  ,p_upd_end_dt                     in date
  ,p_approval_mode                  in varchar2
  ,p_enrt_perd_start_dt             in date
  ,p_enrt_perd_end_dt               in date
  ,p_yr_perd_start_dt               in date
  ,p_yr_perd_end_dt                 in date
  ,p_wthn_yr_start_dt               in date
  ,p_wthn_yr_end_dt                 in date
  ,p_enrt_perd_id                   in number
  ,p_yr_perd_id                     in number
  ,p_business_group_id              in number
  ,p_perf_revw_strt_dt              in date
  ,p_asg_updt_eff_date              in date
  ,p_emp_interview_typ_cd           in varchar2
  ,p_salary_change_reason           in varchar2
  ,p_ws_abr_id                      in number
  ,p_ws_nnmntry_uom                 in varchar2
  ,p_ws_rndg_cd                     in varchar2
  ,p_ws_sub_acty_typ_cd             in varchar2
  ,p_dist_bdgt_abr_id               in number
  ,p_dist_bdgt_nnmntry_uom          in varchar2
  ,p_dist_bdgt_rndg_cd              in varchar2
  ,p_ws_bdgt_abr_id                 in number
  ,p_ws_bdgt_nnmntry_uom            in varchar2
  ,p_ws_bdgt_rndg_cd                in varchar2
  ,p_rsrv_abr_id                    in number
  ,p_rsrv_nnmntry_uom               in varchar2
  ,p_rsrv_rndg_cd                   in varchar2
  ,p_elig_sal_abr_id                in number
  ,p_elig_sal_nnmntry_uom           in varchar2
  ,p_elig_sal_rndg_cd               in varchar2
  ,p_misc1_abr_id                   in number
  ,p_misc1_nnmntry_uom              in varchar2
  ,p_misc1_rndg_cd                  in varchar2
  ,p_misc2_abr_id                   in number
  ,p_misc2_nnmntry_uom              in varchar2
  ,p_misc2_rndg_cd                  in varchar2
  ,p_misc3_abr_id                   in number
  ,p_misc3_nnmntry_uom              in varchar2
  ,p_misc3_rndg_cd                  in varchar2
  ,p_stat_sal_abr_id                in number
  ,p_stat_sal_nnmntry_uom           in varchar2
  ,p_stat_sal_rndg_cd               in varchar2
  ,p_rec_abr_id                     in number
  ,p_rec_nnmntry_uom                in varchar2
  ,p_rec_rndg_cd                    in varchar2
  ,p_tot_comp_abr_id                in number
  ,p_tot_comp_nnmntry_uom           in varchar2
  ,p_tot_comp_rndg_cd               in varchar2
  ,p_oth_comp_abr_id                in number
  ,p_oth_comp_nnmntry_uom           in varchar2
  ,p_oth_comp_rndg_cd               in varchar2
  ,p_actual_flag                    in varchar2
  ,p_acty_ref_perd_cd               in varchar2
  ,p_legislation_code               in varchar2
  ,p_pl_annulization_factor         in number
  ,p_pl_stat_cd                     in varchar2
  ,p_uom_precision                  in number
  ,p_ws_element_type_id             in number
  ,p_ws_input_value_id              in number
  ,p_data_freeze_date               in date
  ,p_ws_amt_edit_cd                 in varchar2
  ,p_ws_amt_edit_enf_cd_for_nul     in varchar2
  ,p_ws_over_budget_edit_cd         in varchar2
  ,p_ws_over_budget_tol_pct         in number
  ,p_bdgt_over_budget_edit_cd       in varchar2
  ,p_bdgt_over_budget_tol_pct       in number
  ,p_auto_distr_flag                in varchar2
  ,p_pqh_document_short_name        in varchar2
  ,p_ovrid_rt_strt_dt               in date
  ,p_do_not_process_flag            in varchar2
  ,p_ovr_perf_revw_strt_dt          in date
  ,p_post_zero_salary_increase      in varchar2
  ,p_show_appraisals_n_days         in number
  ,p_grade_range_validation         in  varchar2
  ,p_object_version_number          in number
  )
  Return g_rec_type is
--
  l_rec   g_rec_type;
--
Begin
  --
  -- Convert arguments into local l_rec structure.
  --
  l_rec.pl_id                            := p_pl_id;
  l_rec.lf_evt_ocrd_dt                   := p_lf_evt_ocrd_dt;
  l_rec.oipl_id                          := p_oipl_id;
  l_rec.effective_date                   := p_effective_date;
  l_rec.name                             := p_name;
  l_rec.group_pl_id                      := p_group_pl_id;
  l_rec.group_oipl_id                    := p_group_oipl_id;
  l_rec.opt_hidden_flag                  := p_opt_hidden_flag;
  l_rec.opt_id                           := p_opt_id;
  l_rec.pl_uom                           := p_pl_uom;
  l_rec.pl_ordr_num                      := p_pl_ordr_num;
  l_rec.oipl_ordr_num                    := p_oipl_ordr_num;
  l_rec.pl_xchg_rate                     := p_pl_xchg_rate;
  l_rec.opt_count                        := p_opt_count;
  l_rec.uses_bdgt_flag                   := p_uses_bdgt_flag;
  l_rec.prsrv_bdgt_cd                    := p_prsrv_bdgt_cd;
  l_rec.upd_start_dt                     := p_upd_start_dt;
  l_rec.upd_end_dt                       := p_upd_end_dt;
  l_rec.approval_mode                    := p_approval_mode;
  l_rec.enrt_perd_start_dt               := p_enrt_perd_start_dt;
  l_rec.enrt_perd_end_dt                 := p_enrt_perd_end_dt;
  l_rec.yr_perd_start_dt                 := p_yr_perd_start_dt;
  l_rec.yr_perd_end_dt                   := p_yr_perd_end_dt;
  l_rec.wthn_yr_start_dt                 := p_wthn_yr_start_dt;
  l_rec.wthn_yr_end_dt                   := p_wthn_yr_end_dt;
  l_rec.enrt_perd_id                     := p_enrt_perd_id;
  l_rec.yr_perd_id                       := p_yr_perd_id;
  l_rec.business_group_id                := p_business_group_id;
  l_rec.perf_revw_strt_dt                := p_perf_revw_strt_dt;
  l_rec.asg_updt_eff_date                := p_asg_updt_eff_date;
  l_rec.emp_interview_typ_cd             := p_emp_interview_typ_cd;
  l_rec.salary_change_reason             := p_salary_change_reason;
  l_rec.ws_abr_id                        := p_ws_abr_id;
  l_rec.ws_nnmntry_uom                   := p_ws_nnmntry_uom;
  l_rec.ws_rndg_cd                       := p_ws_rndg_cd;
  l_rec.ws_sub_acty_typ_cd               := p_ws_sub_acty_typ_cd;
  l_rec.dist_bdgt_abr_id                 := p_dist_bdgt_abr_id;
  l_rec.dist_bdgt_nnmntry_uom            := p_dist_bdgt_nnmntry_uom;
  l_rec.dist_bdgt_rndg_cd                := p_dist_bdgt_rndg_cd;
  l_rec.ws_bdgt_abr_id                   := p_ws_bdgt_abr_id;
  l_rec.ws_bdgt_nnmntry_uom              := p_ws_bdgt_nnmntry_uom;
  l_rec.ws_bdgt_rndg_cd                  := p_ws_bdgt_rndg_cd;
  l_rec.rsrv_abr_id                      := p_rsrv_abr_id;
  l_rec.rsrv_nnmntry_uom                 := p_rsrv_nnmntry_uom;
  l_rec.rsrv_rndg_cd                     := p_rsrv_rndg_cd;
  l_rec.elig_sal_abr_id                  := p_elig_sal_abr_id;
  l_rec.elig_sal_nnmntry_uom             := p_elig_sal_nnmntry_uom;
  l_rec.elig_sal_rndg_cd                 := p_elig_sal_rndg_cd;
  l_rec.misc1_abr_id                     := p_misc1_abr_id;
  l_rec.misc1_nnmntry_uom                := p_misc1_nnmntry_uom;
  l_rec.misc1_rndg_cd                    := p_misc1_rndg_cd;
  l_rec.misc2_abr_id                     := p_misc2_abr_id;
  l_rec.misc2_nnmntry_uom                := p_misc2_nnmntry_uom;
  l_rec.misc2_rndg_cd                    := p_misc2_rndg_cd;
  l_rec.misc3_abr_id                     := p_misc3_abr_id;
  l_rec.misc3_nnmntry_uom                := p_misc3_nnmntry_uom;
  l_rec.misc3_rndg_cd                    := p_misc3_rndg_cd;
  l_rec.stat_sal_abr_id                  := p_stat_sal_abr_id;
  l_rec.stat_sal_nnmntry_uom             := p_stat_sal_nnmntry_uom;
  l_rec.stat_sal_rndg_cd                 := p_stat_sal_rndg_cd;
  l_rec.rec_abr_id                       := p_rec_abr_id;
  l_rec.rec_nnmntry_uom                  := p_rec_nnmntry_uom;
  l_rec.rec_rndg_cd                      := p_rec_rndg_cd;
  l_rec.tot_comp_abr_id                  := p_tot_comp_abr_id;
  l_rec.tot_comp_nnmntry_uom             := p_tot_comp_nnmntry_uom;
  l_rec.tot_comp_rndg_cd                 := p_tot_comp_rndg_cd;
  l_rec.oth_comp_abr_id                  := p_oth_comp_abr_id;
  l_rec.oth_comp_nnmntry_uom             := p_oth_comp_nnmntry_uom;
  l_rec.oth_comp_rndg_cd                 := p_oth_comp_rndg_cd;
  l_rec.actual_flag                      := p_actual_flag;
  l_rec.acty_ref_perd_cd                 := p_acty_ref_perd_cd;
  l_rec.legislation_code                 := p_legislation_code;
  l_rec.pl_annulization_factor           := p_pl_annulization_factor;
  l_rec.pl_stat_cd                       := p_pl_stat_cd;
  l_rec.uom_precision                    := p_uom_precision;
  l_rec.ws_element_type_id               := p_ws_element_type_id;
  l_rec.ws_input_value_id                := p_ws_input_value_id;
  l_rec.data_freeze_date                 := p_data_freeze_date;
  l_rec.ws_amt_edit_cd                   := p_ws_amt_edit_cd;
  l_rec.ws_amt_edit_enf_cd_for_nulls     := p_ws_amt_edit_enf_cd_for_nul;
  l_rec.ws_over_budget_edit_cd           := p_ws_over_budget_edit_cd;
  l_rec.ws_over_budget_tolerance_pct     := p_ws_over_budget_tol_pct;
  l_rec.bdgt_over_budget_edit_cd         := p_bdgt_over_budget_edit_cd;
  l_rec.bdgt_over_budget_tolerance_pct   := p_bdgt_over_budget_tol_pct;
  l_rec.auto_distr_flag                  := p_auto_distr_flag;
  l_rec.pqh_document_short_name          := p_pqh_document_short_name;
  l_rec.ovrid_rt_strt_dt               := p_ovrid_rt_strt_dt;
  l_rec.do_not_process_flag            := p_do_not_process_flag;
  l_rec.ovr_perf_revw_strt_dt            := p_ovr_perf_revw_strt_dt;
  l_rec.post_zero_salary_increase            := p_post_zero_salary_increase;
  l_rec.show_appraisals_n_days            := p_show_appraisals_n_days;
  l_rec.grade_range_validation            := p_grade_range_validation;
  l_rec.object_version_number            := p_object_version_number;
  --
  -- Return the plsql record structure.
  --
  Return(l_rec);
--
End convert_args;
--
end ben_cpd_shd;

/
