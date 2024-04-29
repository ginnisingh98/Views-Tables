--------------------------------------------------------
--  DDL for Package Body BEN_CPG_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_CPG_SHD" as
/* $Header: becpgrhi.pkb 120.0 2005/05/28 01:13:13 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  ben_cpg_shd.';  -- Global package name
g_debug  boolean := hr_utility.debug_enabled;
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
  If (p_constraint_name = 'BEN_CWB_PERSON_GROUPS_PK') Then
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
  ,p_group_pl_id                          in     number
  ,p_group_oipl_id                        in     number
  ,p_object_version_number                in     number
  )
  Return Boolean Is
  --
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
       group_per_in_ler_id
      ,group_pl_id
      ,group_oipl_id
      ,lf_evt_ocrd_dt
      ,bdgt_pop_cd
      ,due_dt
      ,access_cd
      ,approval_cd
      ,approval_date
      ,approval_comments
      ,submit_cd
      ,submit_date
      ,submit_comments
      ,dist_bdgt_val
      ,ws_bdgt_val
      ,rsrv_val
      ,dist_bdgt_mn_val
      ,dist_bdgt_mx_val
      ,dist_bdgt_incr_val
      ,ws_bdgt_mn_val
      ,ws_bdgt_mx_val
      ,ws_bdgt_incr_val
      ,rsrv_mn_val
      ,rsrv_mx_val
      ,rsrv_incr_val
      ,dist_bdgt_iss_val
      ,ws_bdgt_iss_val
      ,dist_bdgt_iss_date
      ,ws_bdgt_iss_date
      ,ws_bdgt_val_last_upd_date
      ,dist_bdgt_val_last_upd_date
      ,rsrv_val_last_upd_date
      ,ws_bdgt_val_last_upd_by
      ,dist_bdgt_val_last_upd_by
      ,rsrv_val_last_upd_by
      ,object_version_number
    from        ben_cwb_person_groups
    where       group_per_in_ler_id = p_group_per_in_ler_id
    and   group_pl_id = p_group_pl_id
    and   group_oipl_id = p_group_oipl_id;
  --
  l_fct_ret     boolean;
  --
Begin
  --
  If (p_group_per_in_ler_id is null and
      p_group_pl_id is null and
      p_group_oipl_id is null and
      p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_group_per_in_ler_id
        = ben_cpg_shd.g_old_rec.group_per_in_ler_id and
        p_group_pl_id
        = ben_cpg_shd.g_old_rec.group_pl_id and
        p_group_oipl_id
        = ben_cpg_shd.g_old_rec.group_oipl_id and
        p_object_version_number
        = ben_cpg_shd.g_old_rec.object_version_number
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
      Fetch C_Sel1 Into ben_cpg_shd.g_old_rec;
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
          <> ben_cpg_shd.g_old_rec.object_version_number) Then
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
  ,p_group_pl_id                          in     number
  ,p_group_oipl_id                        in     number
  ,p_object_version_number                in     number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select
       group_per_in_ler_id
      ,group_pl_id
      ,group_oipl_id
      ,lf_evt_ocrd_dt
      ,bdgt_pop_cd
      ,due_dt
      ,access_cd
      ,approval_cd
      ,approval_date
      ,approval_comments
      ,submit_cd
      ,submit_date
      ,submit_comments
      ,dist_bdgt_val
      ,ws_bdgt_val
      ,rsrv_val
      ,dist_bdgt_mn_val
      ,dist_bdgt_mx_val
      ,dist_bdgt_incr_val
      ,ws_bdgt_mn_val
      ,ws_bdgt_mx_val
      ,ws_bdgt_incr_val
      ,rsrv_mn_val
      ,rsrv_mx_val
      ,rsrv_incr_val
      ,dist_bdgt_iss_val
      ,ws_bdgt_iss_val
      ,dist_bdgt_iss_date
      ,ws_bdgt_iss_date
      ,ws_bdgt_val_last_upd_date
      ,dist_bdgt_val_last_upd_date
      ,rsrv_val_last_upd_date
      ,ws_bdgt_val_last_upd_by
      ,dist_bdgt_val_last_upd_by
      ,rsrv_val_last_upd_by
      ,object_version_number
    from        ben_cwb_person_groups
    where       group_per_in_ler_id = p_group_per_in_ler_id
    and   group_pl_id = p_group_pl_id
    and   group_oipl_id = p_group_oipl_id
    for update nowait;
--
  l_proc        varchar2(72) := g_package||'lck';
--
Begin
  if g_debug then
     hr_utility.set_location('Entering:'||l_proc, 5);
  end if;
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'GROUP_PER_IN_LER_ID'
    ,p_argument_value     => p_group_per_in_ler_id
    );
  if g_debug then
     hr_utility.set_location(l_proc,6);
  end if;
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'GROUP_PL_ID'
    ,p_argument_value     => p_group_pl_id
    );
  if g_debug then
     hr_utility.set_location(l_proc,7);
  end if;
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'GROUP_OIPL_ID'
    ,p_argument_value     => p_group_oipl_id
    );
  if g_debug then
     hr_utility.set_location(l_proc,8);
  end if;
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'OBJECT_VERSION_NUMBER'
    ,p_argument_value     => p_object_version_number
    );
  --
  Open  C_Sel1;
  Fetch C_Sel1 Into ben_cpg_shd.g_old_rec;
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
      <> ben_cpg_shd.g_old_rec.object_version_number) Then
        fnd_message.set_name('PAY', 'HR_7155_OBJECT_INVALID');
        fnd_message.raise_error;
  End If;
  --
  if g_debug then
     hr_utility.set_location(' Leaving:'||l_proc, 10);
  end if;
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
    fnd_message.set_token('TABLE_NAME', 'ben_cwb_person_groups');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
  (p_group_per_in_ler_id            in number
  ,p_group_pl_id                    in number
  ,p_group_oipl_id                  in number
  ,p_lf_evt_ocrd_dt                 in date
  ,p_bdgt_pop_cd                    in varchar2
  ,p_due_dt                         in date
  ,p_access_cd                      in varchar2
  ,p_approval_cd                    in varchar2
  ,p_approval_date                  in date
  ,p_approval_comments              in varchar2
  ,p_submit_cd                      in varchar2
  ,p_submit_date                    in date
  ,p_submit_comments                in varchar2
  ,p_dist_bdgt_val                  in number
  ,p_ws_bdgt_val                    in number
  ,p_rsrv_val                       in number
  ,p_dist_bdgt_mn_val               in number
  ,p_dist_bdgt_mx_val               in number
  ,p_dist_bdgt_incr_val             in number
  ,p_ws_bdgt_mn_val                 in number
  ,p_ws_bdgt_mx_val                 in number
  ,p_ws_bdgt_incr_val               in number
  ,p_rsrv_mn_val                    in number
  ,p_rsrv_mx_val                    in number
  ,p_rsrv_incr_val                  in number
  ,p_dist_bdgt_iss_val              in number
  ,p_ws_bdgt_iss_val                in number
  ,p_dist_bdgt_iss_date             in date
  ,p_ws_bdgt_iss_date               in date
  ,p_ws_bdgt_val_last_upd_date      in date
  ,p_dist_bdgt_val_last_upd_date    in date
  ,p_rsrv_val_last_upd_date         in date
  ,p_ws_bdgt_val_last_upd_by        in number
  ,p_dist_bdgt_val_last_upd_by      in number
  ,p_rsrv_val_last_upd_by           in number
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
  l_rec.group_per_in_ler_id              := p_group_per_in_ler_id;
  l_rec.group_pl_id                      := p_group_pl_id;
  l_rec.group_oipl_id                    := p_group_oipl_id;
  l_rec.lf_evt_ocrd_dt                   := p_lf_evt_ocrd_dt;
  l_rec.bdgt_pop_cd                      := p_bdgt_pop_cd;
  l_rec.due_dt                           := p_due_dt;
  l_rec.access_cd                        := p_access_cd;
  l_rec.approval_cd                      := p_approval_cd;
  l_rec.approval_date                    := p_approval_date;
  l_rec.approval_comments                := p_approval_comments;
  l_rec.submit_cd                        := p_submit_cd;
  l_rec.submit_date                      := p_submit_date;
  l_rec.submit_comments                  := p_submit_comments;
  l_rec.dist_bdgt_val                    := p_dist_bdgt_val;
  l_rec.ws_bdgt_val                      := p_ws_bdgt_val;
  l_rec.rsrv_val                         := p_rsrv_val;
  l_rec.dist_bdgt_mn_val                 := p_dist_bdgt_mn_val;
  l_rec.dist_bdgt_mx_val                 := p_dist_bdgt_mx_val;
  l_rec.dist_bdgt_incr_val               := p_dist_bdgt_incr_val;
  l_rec.ws_bdgt_mn_val                   := p_ws_bdgt_mn_val;
  l_rec.ws_bdgt_mx_val                   := p_ws_bdgt_mx_val;
  l_rec.ws_bdgt_incr_val                 := p_ws_bdgt_incr_val;
  l_rec.rsrv_mn_val                      := p_rsrv_mn_val;
  l_rec.rsrv_mx_val                      := p_rsrv_mx_val;
  l_rec.rsrv_incr_val                    := p_rsrv_incr_val;
  l_rec.dist_bdgt_iss_val                := p_dist_bdgt_iss_val;
  l_rec.ws_bdgt_iss_val                  := p_ws_bdgt_iss_val;
  l_rec.dist_bdgt_iss_date               := p_dist_bdgt_iss_date;
  l_rec.ws_bdgt_iss_date                 := p_ws_bdgt_iss_date;
  l_rec.ws_bdgt_val_last_upd_date        := p_ws_bdgt_val_last_upd_date;
  l_rec.dist_bdgt_val_last_upd_date      := p_dist_bdgt_val_last_upd_date;
  l_rec.rsrv_val_last_upd_date           := p_rsrv_val_last_upd_date;
  l_rec.ws_bdgt_val_last_upd_by          := p_ws_bdgt_val_last_upd_by;
  l_rec.dist_bdgt_val_last_upd_by        := p_dist_bdgt_val_last_upd_by;
  l_rec.rsrv_val_last_upd_by             := p_rsrv_val_last_upd_by;
  l_rec.object_version_number            := p_object_version_number;
  --
  -- Return the plsql record structure.
  --
  Return(l_rec);
--
End convert_args;
--
end ben_cpg_shd;

/
