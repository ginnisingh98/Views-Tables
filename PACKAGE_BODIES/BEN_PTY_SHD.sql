--------------------------------------------------------
--  DDL for Package Body BEN_PTY_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PTY_SHD" as
/* $Header: beptyrhi.pkb 115.7 2002/12/10 15:22:41 bmanyam noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_pty_shd.';  -- Global package name
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
  l_proc 	varchar2(72) := g_package||'constraint_error';
--
Begin
  --
  If (p_constraint_name = 'BEN_PL_PCP_TYP_FK2') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','5');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'BEN_PL_PCP_TYP_PK') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','10');
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
  (p_pl_pcp_typ_id                        in     number
  ,p_object_version_number                in     number
  )
  Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
       pl_pcp_typ_id
      ,pl_pcp_id
      ,business_group_id
      ,pcp_typ_cd
      ,min_age
      ,max_age
      ,gndr_alwd_cd
      ,pty_attribute_category
      ,pty_attribute1
      ,pty_attribute2
      ,pty_attribute3
      ,pty_attribute4
      ,pty_attribute5
      ,pty_attribute6
      ,pty_attribute7
      ,pty_attribute8
      ,pty_attribute9
      ,pty_attribute10
      ,pty_attribute11
      ,pty_attribute12
      ,pty_attribute13
      ,pty_attribute14
      ,pty_attribute15
      ,pty_attribute16
      ,pty_attribute17
      ,pty_attribute18
      ,pty_attribute19
      ,pty_attribute20
      ,pty_attribute21
      ,pty_attribute22
      ,pty_attribute23
      ,pty_attribute24
      ,pty_attribute25
      ,pty_attribute26
      ,pty_attribute27
      ,pty_attribute28
      ,pty_attribute29
      ,pty_attribute30
      ,object_version_number
    from	ben_pl_pcp_typ
    where	pl_pcp_typ_id = p_pl_pcp_typ_id;
--
  l_fct_ret	boolean;
--
Begin
  --
  If (p_pl_pcp_typ_id is null and
      p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_pl_pcp_typ_id
        = ben_pty_shd.g_old_rec.pl_pcp_typ_id and
        p_object_version_number
        = ben_pty_shd.g_old_rec.object_version_number
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
      Fetch C_Sel1 Into ben_pty_shd.g_old_rec;
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
          <> ben_pty_shd.g_old_rec.object_version_number) Then
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
  (p_pl_pcp_typ_id                        in     number
  ,p_object_version_number                in     number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select
       pl_pcp_typ_id
      ,pl_pcp_id
      ,business_group_id
      ,pcp_typ_cd
      ,min_age
      ,max_age
      ,gndr_alwd_cd
      ,pty_attribute_category
      ,pty_attribute1
      ,pty_attribute2
      ,pty_attribute3
      ,pty_attribute4
      ,pty_attribute5
      ,pty_attribute6
      ,pty_attribute7
      ,pty_attribute8
      ,pty_attribute9
      ,pty_attribute10
      ,pty_attribute11
      ,pty_attribute12
      ,pty_attribute13
      ,pty_attribute14
      ,pty_attribute15
      ,pty_attribute16
      ,pty_attribute17
      ,pty_attribute18
      ,pty_attribute19
      ,pty_attribute20
      ,pty_attribute21
      ,pty_attribute22
      ,pty_attribute23
      ,pty_attribute24
      ,pty_attribute25
      ,pty_attribute26
      ,pty_attribute27
      ,pty_attribute28
      ,pty_attribute29
      ,pty_attribute30
      ,object_version_number
    from	ben_pl_pcp_typ
    where	pl_pcp_typ_id = p_pl_pcp_typ_id
    for	update nowait;
--
  l_proc	varchar2(72) := g_package||'lck';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'PL_PCP_TYP_ID'
    ,p_argument_value     => p_pl_pcp_typ_id
    );
  --
  Open  C_Sel1;
  Fetch C_Sel1 Into ben_pty_shd.g_old_rec;
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
      <> ben_pty_shd.g_old_rec.object_version_number) Then
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
    fnd_message.set_token('TABLE_NAME', 'ben_pl_pcp_typ');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
  (p_pl_pcp_typ_id                  in number
  ,p_pl_pcp_id                      in number
  ,p_business_group_id              in number
  ,p_pcp_typ_cd                     in varchar2
  ,p_min_age                        in number
  ,p_max_age                        in number
  ,p_gndr_alwd_cd                   in varchar2
  ,p_pty_attribute_category         in varchar2
  ,p_pty_attribute1                 in varchar2
  ,p_pty_attribute2                 in varchar2
  ,p_pty_attribute3                 in varchar2
  ,p_pty_attribute4                 in varchar2
  ,p_pty_attribute5                 in varchar2
  ,p_pty_attribute6                 in varchar2
  ,p_pty_attribute7                 in varchar2
  ,p_pty_attribute8                 in varchar2
  ,p_pty_attribute9                 in varchar2
  ,p_pty_attribute10                in varchar2
  ,p_pty_attribute11                in varchar2
  ,p_pty_attribute12                in varchar2
  ,p_pty_attribute13                in varchar2
  ,p_pty_attribute14                in varchar2
  ,p_pty_attribute15                in varchar2
  ,p_pty_attribute16                in varchar2
  ,p_pty_attribute17                in varchar2
  ,p_pty_attribute18                in varchar2
  ,p_pty_attribute19                in varchar2
  ,p_pty_attribute20                in varchar2
  ,p_pty_attribute21                in varchar2
  ,p_pty_attribute22                in varchar2
  ,p_pty_attribute23                in varchar2
  ,p_pty_attribute24                in varchar2
  ,p_pty_attribute25                in varchar2
  ,p_pty_attribute26                in varchar2
  ,p_pty_attribute27                in varchar2
  ,p_pty_attribute28                in varchar2
  ,p_pty_attribute29                in varchar2
  ,p_pty_attribute30                in varchar2
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
  l_rec.pl_pcp_typ_id                    := p_pl_pcp_typ_id;
  l_rec.pl_pcp_id                        := p_pl_pcp_id;
  l_rec.business_group_id                := p_business_group_id;
  l_rec.pcp_typ_cd                       := p_pcp_typ_cd;
  l_rec.min_age                          := p_min_age;
  l_rec.max_age                          := p_max_age;
  l_rec.gndr_alwd_cd                     := p_gndr_alwd_cd;
  l_rec.pty_attribute_category           := p_pty_attribute_category;
  l_rec.pty_attribute1                   := p_pty_attribute1;
  l_rec.pty_attribute2                   := p_pty_attribute2;
  l_rec.pty_attribute3                   := p_pty_attribute3;
  l_rec.pty_attribute4                   := p_pty_attribute4;
  l_rec.pty_attribute5                   := p_pty_attribute5;
  l_rec.pty_attribute6                   := p_pty_attribute6;
  l_rec.pty_attribute7                   := p_pty_attribute7;
  l_rec.pty_attribute8                   := p_pty_attribute8;
  l_rec.pty_attribute9                   := p_pty_attribute9;
  l_rec.pty_attribute10                  := p_pty_attribute10;
  l_rec.pty_attribute11                  := p_pty_attribute11;
  l_rec.pty_attribute12                  := p_pty_attribute12;
  l_rec.pty_attribute13                  := p_pty_attribute13;
  l_rec.pty_attribute14                  := p_pty_attribute14;
  l_rec.pty_attribute15                  := p_pty_attribute15;
  l_rec.pty_attribute16                  := p_pty_attribute16;
  l_rec.pty_attribute17                  := p_pty_attribute17;
  l_rec.pty_attribute18                  := p_pty_attribute18;
  l_rec.pty_attribute19                  := p_pty_attribute19;
  l_rec.pty_attribute20                  := p_pty_attribute20;
  l_rec.pty_attribute21                  := p_pty_attribute21;
  l_rec.pty_attribute22                  := p_pty_attribute22;
  l_rec.pty_attribute23                  := p_pty_attribute23;
  l_rec.pty_attribute24                  := p_pty_attribute24;
  l_rec.pty_attribute25                  := p_pty_attribute25;
  l_rec.pty_attribute26                  := p_pty_attribute26;
  l_rec.pty_attribute27                  := p_pty_attribute27;
  l_rec.pty_attribute28                  := p_pty_attribute28;
  l_rec.pty_attribute29                  := p_pty_attribute29;
  l_rec.pty_attribute30                  := p_pty_attribute30;
  l_rec.object_version_number            := p_object_version_number;
  --
  -- Return the plsql record structure.
  --
  Return(l_rec);
--
End convert_args;
--
end ben_pty_shd;

/
