--------------------------------------------------------
--  DDL for Package Body BEN_CWG_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_CWG_SHD" as
/* $Header: becwgrhi.pkb 120.0 2005/05/28 01:29:54 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  ben_cwg_shd.';  -- Global package name
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
  If (p_constraint_name = 'BEN_CWB_WKSHT_GRP_PK') Then
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
  (p_cwb_wksht_grp_id                     in     number
  ,p_object_version_number                in     number
  )
  Return Boolean Is
  --
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
       cwb_wksht_grp_id
      ,business_group_id
      ,pl_id
      ,ordr_num
      ,wksht_grp_cd
      ,label
      ,cwg_attribute_category
      ,cwg_attribute1
      ,cwg_attribute2
      ,cwg_attribute3
      ,cwg_attribute4
      ,cwg_attribute5
      ,cwg_attribute6
      ,cwg_attribute7
      ,cwg_attribute8
      ,cwg_attribute9
      ,cwg_attribute10
      ,cwg_attribute11
      ,cwg_attribute12
      ,cwg_attribute13
      ,cwg_attribute14
      ,cwg_attribute15
      ,cwg_attribute16
      ,cwg_attribute17
      ,cwg_attribute18
      ,cwg_attribute19
      ,cwg_attribute20
      ,cwg_attribute21
      ,cwg_attribute22
      ,cwg_attribute23
      ,cwg_attribute24
      ,cwg_attribute25
      ,cwg_attribute26
      ,cwg_attribute27
      ,cwg_attribute28
      ,cwg_attribute29
      ,cwg_attribute30
      ,status_Cd
      ,hidden_cd
      ,object_version_number
    from        ben_cwb_wksht_grp
    where       cwb_wksht_grp_id = p_cwb_wksht_grp_id;
  --
  l_fct_ret     boolean;
  --
Begin
  --
  If (p_cwb_wksht_grp_id is null and
      p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_cwb_wksht_grp_id
        = ben_cwg_shd.g_old_rec.cwb_wksht_grp_id and
        p_object_version_number
        = ben_cwg_shd.g_old_rec.object_version_number
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
      Fetch C_Sel1 Into ben_cwg_shd.g_old_rec;
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
          <> ben_cwg_shd.g_old_rec.object_version_number) Then
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
  (p_cwb_wksht_grp_id                     in     number
  ,p_object_version_number                in     number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select
       cwb_wksht_grp_id
      ,business_group_id
      ,pl_id
      ,ordr_num
      ,wksht_grp_cd
      ,label
      ,cwg_attribute_category
      ,cwg_attribute1
      ,cwg_attribute2
      ,cwg_attribute3
      ,cwg_attribute4
      ,cwg_attribute5
      ,cwg_attribute6
      ,cwg_attribute7
      ,cwg_attribute8
      ,cwg_attribute9
      ,cwg_attribute10
      ,cwg_attribute11
      ,cwg_attribute12
      ,cwg_attribute13
      ,cwg_attribute14
      ,cwg_attribute15
      ,cwg_attribute16
      ,cwg_attribute17
      ,cwg_attribute18
      ,cwg_attribute19
      ,cwg_attribute20
      ,cwg_attribute21
      ,cwg_attribute22
      ,cwg_attribute23
      ,cwg_attribute24
      ,cwg_attribute25
      ,cwg_attribute26
      ,cwg_attribute27
      ,cwg_attribute28
      ,cwg_attribute29
      ,cwg_attribute30
      ,status_Cd
      ,hidden_cd
      ,object_version_number
    from        ben_cwb_wksht_grp
    where       cwb_wksht_grp_id = p_cwb_wksht_grp_id
    for update nowait;
--
  l_proc        varchar2(72) := g_package||'lck';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'CWB_WKSHT_GRP_ID'
    ,p_argument_value     => p_cwb_wksht_grp_id
    );
  hr_utility.set_location(l_proc,6);
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'OBJECT_VERSION_NUMBER'
    ,p_argument_value     => p_object_version_number
    );
  --
  Open  C_Sel1;
  Fetch C_Sel1 Into ben_cwg_shd.g_old_rec;
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
      <> ben_cwg_shd.g_old_rec.object_version_number) Then
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
    fnd_message.set_token('TABLE_NAME', 'ben_cwb_wksht_grp');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
  (p_cwb_wksht_grp_id               in number
  ,p_business_group_id              in number
  ,p_pl_id                          in number
  ,p_ordr_num                       in number
  ,p_wksht_grp_cd                   in varchar2
  ,p_label                          in varchar2
  ,p_cwg_attribute_category         in varchar2
  ,p_cwg_attribute1                 in varchar2
  ,p_cwg_attribute2                 in varchar2
  ,p_cwg_attribute3                 in varchar2
  ,p_cwg_attribute4                 in varchar2
  ,p_cwg_attribute5                 in varchar2
  ,p_cwg_attribute6                 in varchar2
  ,p_cwg_attribute7                 in varchar2
  ,p_cwg_attribute8                 in varchar2
  ,p_cwg_attribute9                 in varchar2
  ,p_cwg_attribute10                in varchar2
  ,p_cwg_attribute11                in varchar2
  ,p_cwg_attribute12                in varchar2
  ,p_cwg_attribute13                in varchar2
  ,p_cwg_attribute14                in varchar2
  ,p_cwg_attribute15                in varchar2
  ,p_cwg_attribute16                in varchar2
  ,p_cwg_attribute17                in varchar2
  ,p_cwg_attribute18                in varchar2
  ,p_cwg_attribute19                in varchar2
  ,p_cwg_attribute20                in varchar2
  ,p_cwg_attribute21                in varchar2
  ,p_cwg_attribute22                in varchar2
  ,p_cwg_attribute23                in varchar2
  ,p_cwg_attribute24                in varchar2
  ,p_cwg_attribute25                in varchar2
  ,p_cwg_attribute26                in varchar2
  ,p_cwg_attribute27                in varchar2
  ,p_cwg_attribute28                in varchar2
  ,p_cwg_attribute29                in varchar2
  ,p_cwg_attribute30                in varchar2
  ,p_status_Cd                      in varchar2
  ,p_hidden_cd                    in varchar2
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
  l_rec.cwb_wksht_grp_id                 := p_cwb_wksht_grp_id;
  l_rec.business_group_id                := p_business_group_id;
  l_rec.pl_id                            := p_pl_id;
  l_rec.ordr_num                         := p_ordr_num;
  l_rec.wksht_grp_cd                     := p_wksht_grp_cd;
  l_rec.label                            := p_label;
  l_rec.cwg_attribute_category           := p_cwg_attribute_category;
  l_rec.cwg_attribute1                   := p_cwg_attribute1;
  l_rec.cwg_attribute2                   := p_cwg_attribute2;
  l_rec.cwg_attribute3                   := p_cwg_attribute3;
  l_rec.cwg_attribute4                   := p_cwg_attribute4;
  l_rec.cwg_attribute5                   := p_cwg_attribute5;
  l_rec.cwg_attribute6                   := p_cwg_attribute6;
  l_rec.cwg_attribute7                   := p_cwg_attribute7;
  l_rec.cwg_attribute8                   := p_cwg_attribute8;
  l_rec.cwg_attribute9                   := p_cwg_attribute9;
  l_rec.cwg_attribute10                  := p_cwg_attribute10;
  l_rec.cwg_attribute11                  := p_cwg_attribute11;
  l_rec.cwg_attribute12                  := p_cwg_attribute12;
  l_rec.cwg_attribute13                  := p_cwg_attribute13;
  l_rec.cwg_attribute14                  := p_cwg_attribute14;
  l_rec.cwg_attribute15                  := p_cwg_attribute15;
  l_rec.cwg_attribute16                  := p_cwg_attribute16;
  l_rec.cwg_attribute17                  := p_cwg_attribute17;
  l_rec.cwg_attribute18                  := p_cwg_attribute18;
  l_rec.cwg_attribute19                  := p_cwg_attribute19;
  l_rec.cwg_attribute20                  := p_cwg_attribute20;
  l_rec.cwg_attribute21                  := p_cwg_attribute21;
  l_rec.cwg_attribute22                  := p_cwg_attribute22;
  l_rec.cwg_attribute23                  := p_cwg_attribute23;
  l_rec.cwg_attribute24                  := p_cwg_attribute24;
  l_rec.cwg_attribute25                  := p_cwg_attribute25;
  l_rec.cwg_attribute26                  := p_cwg_attribute26;
  l_rec.cwg_attribute27                  := p_cwg_attribute27;
  l_rec.cwg_attribute28                  := p_cwg_attribute28;
  l_rec.cwg_attribute29                  := p_cwg_attribute29;
  l_rec.cwg_attribute30                  := p_cwg_attribute30;
  l_rec.status_Cd                        := p_status_Cd      ;
  l_rec.hidden_cd                      := p_hidden_cd    ;
  l_rec.object_version_number            := p_object_version_number;
  l_rec.object_version_number            := p_object_version_number;
  --
  -- Return the plsql record structure.
  --
  Return(l_rec);
--
End convert_args;
--
end ben_cwg_shd;

/
