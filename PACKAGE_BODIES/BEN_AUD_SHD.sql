--------------------------------------------------------
--  DDL for Package Body BEN_AUD_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_AUD_SHD" as
/* $Header: beaudrhi.pkb 120.0 2005/05/28 00:31 appldev noship $ */
--
-- --------------------------------------------------------------------------
-- |                     Private Global Definitions                         |
-- --------------------------------------------------------------------------
--
g_package  varchar2(33) := '  ben_aud_shd.';  -- Global package name
--
-- --------------------------------------------------------------------------
-- |---------------------------< constraint_error >-------------------------|
-- --------------------------------------------------------------------------
Procedure constraint_error
  (p_constraint_name in all_constraints.constraint_name%TYPE
  ) Is
--
  l_proc        varchar2(72) := g_package||'constraint_error';
--
Begin
  --
  If (p_constraint_name = 'SYS_C00163503') Then
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
-- --------------------------------------------------------------------------
-- |-----------------------------< api_updating >---------------------------|
-- --------------------------------------------------------------------------
Function api_updating
  (p_cwb_audit_id                         in     number
  ,p_object_version_number                in     number
  )
  Return Boolean Is
  --
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
       cwb_audit_id
      ,group_per_in_ler_id
      ,group_pl_id
      ,lf_evt_ocrd_dt
      ,pl_id
      ,group_oipl_id
      ,audit_type_cd
      ,old_val_varchar
      ,new_val_varchar
      ,old_val_number
      ,new_val_number
      ,old_val_date
      ,new_val_date
      ,date_stamp
      ,change_made_by_person_id
      ,supporting_information
      ,request_id
      ,object_version_number
    from        ben_cwb_audit
    where       cwb_audit_id = p_cwb_audit_id;
  --
  l_fct_ret     boolean;
  --
Begin
  --
  If (p_cwb_audit_id is null and
      p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_cwb_audit_id
        = ben_aud_shd.g_old_rec.cwb_audit_id and
        p_object_version_number
        = ben_aud_shd.g_old_rec.object_version_number
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
      Fetch C_Sel1 Into ben_aud_shd.g_old_rec;
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
          <> ben_aud_shd.g_old_rec.object_version_number) Then
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
-- -------------------------------------------------------------------------
-- |---------------------------------< lck >-------------------------------|
-- -------------------------------------------------------------------------
Procedure lck
  (p_cwb_audit_id                         in     number
  ,p_object_version_number                in     number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select
       cwb_audit_id
      ,group_per_in_ler_id
      ,group_pl_id
      ,lf_evt_ocrd_dt
      ,pl_id
      ,group_oipl_id
      ,audit_type_cd
      ,old_val_varchar
      ,new_val_varchar
      ,old_val_number
      ,new_val_number
      ,old_val_date
      ,new_val_date
      ,date_stamp
      ,change_made_by_person_id
      ,supporting_information
      ,request_id
      ,object_version_number
    from        ben_cwb_audit
    where       cwb_audit_id = p_cwb_audit_id
    for update nowait;
--
  l_proc        varchar2(72) := g_package||'lck';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'CWB_AUDIT_ID'
    ,p_argument_value     => p_cwb_audit_id
    );
  hr_utility.set_location(l_proc,6);
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'OBJECT_VERSION_NUMBER'
    ,p_argument_value     => p_object_version_number
    );
  --
  Open  C_Sel1;
  Fetch C_Sel1 Into ben_aud_shd.g_old_rec;
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
      <> ben_aud_shd.g_old_rec.object_version_number) Then
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
    fnd_message.set_token('TABLE_NAME', 'ben_cwb_audit');
    fnd_message.raise_error;
End lck;
--
-- -------------------------------------------------------------------------
-- |-----------------------------< convert_args >--------------------------|
-- -------------------------------------------------------------------------
Function convert_args
  (p_cwb_audit_id                   in number
  ,p_group_per_in_ler_id            in number
  ,p_group_pl_id                    in number
  ,p_lf_evt_ocrd_dt                 in date
  ,p_pl_id                          in number
  ,p_group_oipl_id                  in number
  ,p_audit_type_cd                  in varchar2
  ,p_old_val_varchar                in varchar2
  ,p_new_val_varchar                in varchar2
  ,p_old_val_number                 in number
  ,p_new_val_number                 in number
  ,p_old_val_date                   in date
  ,p_new_val_date                   in date
  ,p_date_stamp                     in date
  ,p_change_made_by_person_id       in number
  ,p_supporting_information         in varchar2
  ,p_request_id                     in number
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
  l_rec.cwb_audit_id                     := p_cwb_audit_id;
  l_rec.group_per_in_ler_id              := p_group_per_in_ler_id;
  l_rec.group_pl_id                      := p_group_pl_id;
  l_rec.lf_evt_ocrd_dt                   := p_lf_evt_ocrd_dt;
  l_rec.pl_id                            := p_pl_id;
  l_rec.group_oipl_id                    := p_group_oipl_id;
  l_rec.audit_type_cd                    := p_audit_type_cd;
  l_rec.old_val_varchar                  := p_old_val_varchar;
  l_rec.new_val_varchar                  := p_new_val_varchar;
  l_rec.old_val_number                   := p_old_val_number;
  l_rec.new_val_number                   := p_new_val_number;
  l_rec.old_val_date                     := p_old_val_date;
  l_rec.new_val_date                     := p_new_val_date;
  l_rec.date_stamp                       := p_date_stamp;
  l_rec.change_made_by_person_id         := p_change_made_by_person_id;
  l_rec.supporting_information           := p_supporting_information;
  l_rec.request_id                       := p_request_id;
  l_rec.object_version_number            := p_object_version_number;
  --
  -- Return the plsql record structure.
  --
  Return(l_rec);
--
End convert_args;
--
end ben_aud_shd;

/
