--------------------------------------------------------
--  DDL for Package Body BEN_RTS_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_RTS_SHD" as
/* $Header: bertsrhi.pkb 120.1 2006/01/09 14:37:17 maagrawa noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  ben_rts_shd.';  -- Global package name
g_debug boolean := hr_utility.debug_enabled;
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
  If (p_constraint_name = 'BEN_CWB_PERSON_RATES_PK') Then
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
  (p_group_per_in_ler_id                  in     number
  ,p_pl_id                                in     number
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
       person_rate_id
      ,group_per_in_ler_id
      ,pl_id
      ,oipl_id
      ,group_pl_id
      ,group_oipl_id
      ,lf_evt_ocrd_dt
      ,person_id
      ,assignment_id
      ,elig_flag
      ,ws_val
      ,ws_mn_val
      ,ws_mx_val
      ,ws_incr_val
      ,elig_sal_val
      ,stat_sal_val
      ,oth_comp_val
      ,tot_comp_val
      ,misc1_val
      ,misc2_val
      ,misc3_val
      ,rec_val
      ,rec_mn_val
      ,rec_mx_val
      ,rec_incr_val
      ,ws_val_last_upd_date
      ,ws_val_last_upd_by
      ,pay_proposal_id
      ,element_entry_value_id
      ,inelig_rsn_cd
      ,elig_ovrid_dt
      ,elig_ovrid_person_id
      ,copy_dist_bdgt_val
      ,copy_ws_bdgt_val
      ,copy_rsrv_val
      ,copy_dist_bdgt_mn_val
      ,copy_dist_bdgt_mx_val
      ,copy_dist_bdgt_incr_val
      ,copy_ws_bdgt_mn_val
      ,copy_ws_bdgt_mx_val
      ,copy_ws_bdgt_incr_val
      ,copy_rsrv_mn_val
      ,copy_rsrv_mx_val
      ,copy_rsrv_incr_val
      ,copy_dist_bdgt_iss_val
      ,copy_ws_bdgt_iss_val
      ,copy_dist_bdgt_iss_date
      ,copy_ws_bdgt_iss_date
      ,comp_posting_date
      ,ws_rt_start_date
      ,currency
      ,object_version_number
    from        ben_cwb_person_rates
    where       group_per_in_ler_id = p_group_per_in_ler_id
    and   pl_id = p_pl_id
    and   oipl_id = p_oipl_id;
  --
  l_fct_ret     boolean;
  --
Begin
  --
  If (p_group_per_in_ler_id is null and
      p_pl_id is null and
      p_oipl_id is null and
      p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_group_per_in_ler_id
        = ben_rts_shd.g_old_rec.group_per_in_ler_id and
        p_pl_id
        = ben_rts_shd.g_old_rec.pl_id and
        p_oipl_id
        = ben_rts_shd.g_old_rec.oipl_id and
        p_object_version_number
        = ben_rts_shd.g_old_rec.object_version_number
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
      Fetch C_Sel1 Into ben_rts_shd.g_old_rec;
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
          <> ben_rts_shd.g_old_rec.object_version_number) Then
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
  (p_group_per_in_ler_id                  in     number
  ,p_pl_id                                in     number
  ,p_oipl_id                              in     number
  ,p_object_version_number                in     number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select
       person_rate_id
      ,group_per_in_ler_id
      ,pl_id
      ,oipl_id
      ,group_pl_id
      ,group_oipl_id
      ,lf_evt_ocrd_dt
      ,person_id
      ,assignment_id
      ,elig_flag
      ,ws_val
      ,ws_mn_val
      ,ws_mx_val
      ,ws_incr_val
      ,elig_sal_val
      ,stat_sal_val
      ,oth_comp_val
      ,tot_comp_val
      ,misc1_val
      ,misc2_val
      ,misc3_val
      ,rec_val
      ,rec_mn_val
      ,rec_mx_val
      ,rec_incr_val
      ,ws_val_last_upd_date
      ,ws_val_last_upd_by
      ,pay_proposal_id
      ,element_entry_value_id
      ,inelig_rsn_cd
      ,elig_ovrid_dt
      ,elig_ovrid_person_id
      ,copy_dist_bdgt_val
      ,copy_ws_bdgt_val
      ,copy_rsrv_val
      ,copy_dist_bdgt_mn_val
      ,copy_dist_bdgt_mx_val
      ,copy_dist_bdgt_incr_val
      ,copy_ws_bdgt_mn_val
      ,copy_ws_bdgt_mx_val
      ,copy_ws_bdgt_incr_val
      ,copy_rsrv_mn_val
      ,copy_rsrv_mx_val
      ,copy_rsrv_incr_val
      ,copy_dist_bdgt_iss_val
      ,copy_ws_bdgt_iss_val
      ,copy_dist_bdgt_iss_date
      ,copy_ws_bdgt_iss_date
      ,comp_posting_date
      ,ws_rt_start_date
      ,currency
      ,object_version_number
    from        ben_cwb_person_rates
    where       group_per_in_ler_id = p_group_per_in_ler_id
    and   pl_id = p_pl_id
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
    ,p_argument           => 'GROUP_PER_IN_LER_ID'
    ,p_argument_value     => p_group_per_in_ler_id
    );
  hr_utility.set_location(l_proc,6);
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'PL_ID'
    ,p_argument_value     => p_pl_id
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
  Fetch C_Sel1 Into ben_rts_shd.g_old_rec;
  If C_Sel1%notfound then
    Close C_Sel1;
    --
    -- The primary key is invalid therefore we must error
    --
    fnd_message.set_name('PAY', 'HR_7220_INVALID_PRIMARY_KEY');
    fnd_message.raise_error;
  End If;
  Close C_Sel1;
  If (p_object_version_number
      <> ben_rts_shd.g_old_rec.object_version_number) Then
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
    fnd_message.set_token('TABLE_NAME', 'ben_cwb_person_rates');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
  (p_person_rate_id                 in number
  ,p_group_per_in_ler_id            in number
  ,p_pl_id                          in number
  ,p_oipl_id                        in number
  ,p_group_pl_id                    in number
  ,p_group_oipl_id                  in number
  ,p_lf_evt_ocrd_dt                 in date
  ,p_person_id                      in number
  ,p_assignment_id                  in number
  ,p_elig_flag                      in varchar2
  ,p_ws_val                         in number
  ,p_ws_mn_val                      in number
  ,p_ws_mx_val                      in number
  ,p_ws_incr_val                    in number
  ,p_elig_sal_val                   in number
  ,p_stat_sal_val                   in number
  ,p_oth_comp_val                   in number
  ,p_tot_comp_val                   in number
  ,p_misc1_val                      in number
  ,p_misc2_val                      in number
  ,p_misc3_val                      in number
  ,p_rec_val                        in number
  ,p_rec_mn_val                     in number
  ,p_rec_mx_val                     in number
  ,p_rec_incr_val                   in number
  ,p_ws_val_last_upd_date           in date
  ,p_ws_val_last_upd_by             in number
  ,p_pay_proposal_id                in number
  ,p_element_entry_value_id         in number
  ,p_inelig_rsn_cd                  in varchar2
  ,p_elig_ovrid_dt                  in date
  ,p_elig_ovrid_person_id           in number
  ,p_copy_dist_bdgt_val             in number
  ,p_copy_ws_bdgt_val               in number
  ,p_copy_rsrv_val                  in number
  ,p_copy_dist_bdgt_mn_val          in number
  ,p_copy_dist_bdgt_mx_val          in number
  ,p_copy_dist_bdgt_incr_val        in number
  ,p_copy_ws_bdgt_mn_val            in number
  ,p_copy_ws_bdgt_mx_val            in number
  ,p_copy_ws_bdgt_incr_val          in number
  ,p_copy_rsrv_mn_val               in number
  ,p_copy_rsrv_mx_val               in number
  ,p_copy_rsrv_incr_val             in number
  ,p_copy_dist_bdgt_iss_val         in number
  ,p_copy_ws_bdgt_iss_val           in number
  ,p_copy_dist_bdgt_iss_date        in date
  ,p_copy_ws_bdgt_iss_date          in date
  ,p_comp_posting_date              in date
  ,p_ws_rt_start_date               in date
  ,p_currency                       in varchar2
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
  l_rec.person_rate_id                   := p_person_rate_id;
  l_rec.group_per_in_ler_id              := p_group_per_in_ler_id;
  l_rec.pl_id                            := p_pl_id;
  l_rec.oipl_id                          := p_oipl_id;
  l_rec.group_pl_id                      := p_group_pl_id;
  l_rec.group_oipl_id                    := p_group_oipl_id;
  l_rec.lf_evt_ocrd_dt                   := p_lf_evt_ocrd_dt;
  l_rec.person_id                        := p_person_id;
  l_rec.assignment_id                    := p_assignment_id;
  l_rec.elig_flag                        := p_elig_flag;
  l_rec.ws_val                           := p_ws_val;
  l_rec.ws_mn_val                        := p_ws_mn_val;
  l_rec.ws_mx_val                        := p_ws_mx_val;
  l_rec.ws_incr_val                      := p_ws_incr_val;
  l_rec.elig_sal_val                     := p_elig_sal_val;
  l_rec.stat_sal_val                     := p_stat_sal_val;
  l_rec.oth_comp_val                     := p_oth_comp_val;
  l_rec.tot_comp_val                     := p_tot_comp_val;
  l_rec.misc1_val                        := p_misc1_val;
  l_rec.misc2_val                        := p_misc2_val;
  l_rec.misc3_val                        := p_misc3_val;
  l_rec.rec_val                          := p_rec_val;
  l_rec.rec_mn_val                       := p_rec_mn_val;
  l_rec.rec_mx_val                       := p_rec_mx_val;
  l_rec.rec_incr_val                     := p_rec_incr_val;
  l_rec.ws_val_last_upd_date             := p_ws_val_last_upd_date;
  l_rec.ws_val_last_upd_by               := p_ws_val_last_upd_by;
  l_rec.pay_proposal_id                  := p_pay_proposal_id;
  l_rec.element_entry_value_id           := p_element_entry_value_id;
  l_rec.inelig_rsn_cd                    := p_inelig_rsn_cd;
  l_rec.elig_ovrid_dt                    := p_elig_ovrid_dt;
  l_rec.elig_ovrid_person_id             := p_elig_ovrid_person_id;
  l_rec.copy_dist_bdgt_val               := p_copy_dist_bdgt_val;
  l_rec.copy_ws_bdgt_val                 := p_copy_ws_bdgt_val;
  l_rec.copy_rsrv_val                    := p_copy_rsrv_val;
  l_rec.copy_dist_bdgt_mn_val            := p_copy_dist_bdgt_mn_val;
  l_rec.copy_dist_bdgt_mx_val            := p_copy_dist_bdgt_mx_val;
  l_rec.copy_dist_bdgt_incr_val          := p_copy_dist_bdgt_incr_val;
  l_rec.copy_ws_bdgt_mn_val              := p_copy_ws_bdgt_mn_val;
  l_rec.copy_ws_bdgt_mx_val              := p_copy_ws_bdgt_mx_val;
  l_rec.copy_ws_bdgt_incr_val            := p_copy_ws_bdgt_incr_val;
  l_rec.copy_rsrv_mn_val                 := p_copy_rsrv_mn_val;
  l_rec.copy_rsrv_mx_val                 := p_copy_rsrv_mx_val;
  l_rec.copy_rsrv_incr_val               := p_copy_rsrv_incr_val;
  l_rec.copy_dist_bdgt_iss_val           := p_copy_dist_bdgt_iss_val;
  l_rec.copy_ws_bdgt_iss_val             := p_copy_ws_bdgt_iss_val;
  l_rec.copy_dist_bdgt_iss_date          := p_copy_dist_bdgt_iss_date;
  l_rec.copy_ws_bdgt_iss_date            := p_copy_ws_bdgt_iss_date;
  l_rec.comp_posting_date                := p_comp_posting_date;
  l_rec.ws_rt_start_date                 := p_ws_rt_start_date;
  l_rec.currency                         := p_currency;
  l_rec.object_version_number            := p_object_version_number;
  --
  -- Return the plsql record structure.
  --
  Return(l_rec);
--
End convert_args;
--
end ben_rts_shd;

/
