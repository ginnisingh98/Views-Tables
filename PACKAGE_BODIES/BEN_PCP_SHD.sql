--------------------------------------------------------
--  DDL for Package Body BEN_PCP_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PCP_SHD" as
/* $Header: bepcprhi.pkb 115.13 2002/12/16 12:00:12 vsethi noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_pcp_shd.';  -- Global package name
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
  If (p_constraint_name = 'BEN_PL_PCP_PK') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','5');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'BEN_PL_PCP_TYP_FK2') Then
    ben_utility.child_exists_error(p_table_name => 'BEN_PL_PCP_TYP');
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
  (p_pl_pcp_id                            in     number
  ,p_object_version_number                in     number
  )
  Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
       pl_pcp_id
      ,pl_id
      ,business_group_id
      ,pcp_strt_dt_cd
      ,pcp_dsgn_cd
      ,pcp_dpnt_dsgn_cd
      ,pcp_rpstry_flag
      ,pcp_can_keep_flag
      ,pcp_radius
      ,pcp_radius_uom
      ,pcp_radius_warn_flag
      ,pcp_num_chgs
      ,pcp_num_chgs_uom
      ,pcp_attribute_category
      ,pcp_attribute1
      ,pcp_attribute2
      ,pcp_attribute3
      ,pcp_attribute4
      ,pcp_attribute5
      ,pcp_attribute6
      ,pcp_attribute7
      ,pcp_attribute8
      ,pcp_attribute9
      ,pcp_attribute10
      ,pcp_attribute11
      ,pcp_attribute12
      ,pcp_attribute13
      ,pcp_attribute14
      ,pcp_attribute15
      ,pcp_attribute16
      ,pcp_attribute17
      ,pcp_attribute18
      ,pcp_attribute19
      ,pcp_attribute20
      ,pcp_attribute21
      ,pcp_attribute22
      ,pcp_attribute23
      ,pcp_attribute24
      ,pcp_attribute25
      ,pcp_attribute26
      ,pcp_attribute27
      ,pcp_attribute28
      ,pcp_attribute29
      ,pcp_attribute30
      ,object_version_number
    from	ben_pl_pcp
    where	pl_pcp_id = p_pl_pcp_id;
--
  l_fct_ret	boolean;
--
Begin
  --
  If (p_pl_pcp_id is null and
      p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_pl_pcp_id
        = ben_pcp_shd.g_old_rec.pl_pcp_id and
        p_object_version_number
        = ben_pcp_shd.g_old_rec.object_version_number
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
      Fetch C_Sel1 Into ben_pcp_shd.g_old_rec;
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
          <> ben_pcp_shd.g_old_rec.object_version_number) Then
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
  (p_pl_pcp_id                            in     number
  ,p_object_version_number                in     number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select
       pl_pcp_id
      ,pl_id
      ,business_group_id
      ,pcp_strt_dt_cd
      ,pcp_dsgn_cd
      ,pcp_dpnt_dsgn_cd
      ,pcp_rpstry_flag
      ,pcp_can_keep_flag
      ,pcp_radius
      ,pcp_radius_uom
      ,pcp_radius_warn_flag
      ,pcp_num_chgs
      ,pcp_num_chgs_uom
      ,pcp_attribute_category
      ,pcp_attribute1
      ,pcp_attribute2
      ,pcp_attribute3
      ,pcp_attribute4
      ,pcp_attribute5
      ,pcp_attribute6
      ,pcp_attribute7
      ,pcp_attribute8
      ,pcp_attribute9
      ,pcp_attribute10
      ,pcp_attribute11
      ,pcp_attribute12
      ,pcp_attribute13
      ,pcp_attribute14
      ,pcp_attribute15
      ,pcp_attribute16
      ,pcp_attribute17
      ,pcp_attribute18
      ,pcp_attribute19
      ,pcp_attribute20
      ,pcp_attribute21
      ,pcp_attribute22
      ,pcp_attribute23
      ,pcp_attribute24
      ,pcp_attribute25
      ,pcp_attribute26
      ,pcp_attribute27
      ,pcp_attribute28
      ,pcp_attribute29
      ,pcp_attribute30
      ,object_version_number
    from	ben_pl_pcp
    where	pl_pcp_id = p_pl_pcp_id
    for	update nowait;
--
  l_proc	varchar2(72) := g_package||'lck';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- hr_api.mandatory_arg_error
  --  (p_api_name           => l_proc
  --  ,p_argument           => 'PL_PCP_ID'
  --  ,p_argument_value     => p_pl_pcp_id
  --  );
  --
  Open  C_Sel1;
  Fetch C_Sel1 Into ben_pcp_shd.g_old_rec;
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
      <> ben_pcp_shd.g_old_rec.object_version_number) Then
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
    fnd_message.set_token('TABLE_NAME', 'ben_pl_pcp');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
  (p_pl_pcp_id                      in number
  ,p_pl_id                          in number
  ,p_business_group_id              in number
  ,p_pcp_strt_dt_cd                 in varchar2
  ,p_pcp_dsgn_cd                    in varchar2
  ,p_pcp_dpnt_dsgn_cd               in varchar2
  ,p_pcp_rpstry_flag                in varchar2
  ,p_pcp_can_keep_flag              in varchar2
  ,p_pcp_radius                     in number
  ,p_pcp_radius_uom                 in varchar2
  ,p_pcp_radius_warn_flag           in varchar2
  ,p_pcp_num_chgs                   in number
  ,p_pcp_num_chgs_uom               in varchar2
  ,p_pcp_attribute_category         in varchar2
  ,p_pcp_attribute1                 in varchar2
  ,p_pcp_attribute2                 in varchar2
  ,p_pcp_attribute3                 in varchar2
  ,p_pcp_attribute4                 in varchar2
  ,p_pcp_attribute5                 in varchar2
  ,p_pcp_attribute6                 in varchar2
  ,p_pcp_attribute7                 in varchar2
  ,p_pcp_attribute8                 in varchar2
  ,p_pcp_attribute9                 in varchar2
  ,p_pcp_attribute10                in varchar2
  ,p_pcp_attribute11                in varchar2
  ,p_pcp_attribute12                in varchar2
  ,p_pcp_attribute13                in varchar2
  ,p_pcp_attribute14                in varchar2
  ,p_pcp_attribute15                in varchar2
  ,p_pcp_attribute16                in varchar2
  ,p_pcp_attribute17                in varchar2
  ,p_pcp_attribute18                in varchar2
  ,p_pcp_attribute19                in varchar2
  ,p_pcp_attribute20                in varchar2
  ,p_pcp_attribute21                in varchar2
  ,p_pcp_attribute22                in varchar2
  ,p_pcp_attribute23                in varchar2
  ,p_pcp_attribute24                in varchar2
  ,p_pcp_attribute25                in varchar2
  ,p_pcp_attribute26                in varchar2
  ,p_pcp_attribute27                in varchar2
  ,p_pcp_attribute28                in varchar2
  ,p_pcp_attribute29                in varchar2
  ,p_pcp_attribute30                in varchar2
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
  l_rec.pl_pcp_id                        := p_pl_pcp_id;
  l_rec.pl_id                            := p_pl_id;
  l_rec.business_group_id                := p_business_group_id;
  l_rec.pcp_strt_dt_cd                   := p_pcp_strt_dt_cd;
  l_rec.pcp_dsgn_cd                      := p_pcp_dsgn_cd;
  l_rec.pcp_dpnt_dsgn_cd                 := p_pcp_dpnt_dsgn_cd;
  l_rec.pcp_rpstry_flag                  := p_pcp_rpstry_flag;
  l_rec.pcp_can_keep_flag                := p_pcp_can_keep_flag;
  l_rec.pcp_radius                       := p_pcp_radius;
  l_rec.pcp_radius_uom                   := p_pcp_radius_uom;
  l_rec.pcp_radius_warn_flag             := p_pcp_radius_warn_flag;
  l_rec.pcp_num_chgs                     := p_pcp_num_chgs;
  l_rec.pcp_num_chgs_uom                 := p_pcp_num_chgs_uom;
  l_rec.pcp_attribute_category           := p_pcp_attribute_category;
  l_rec.pcp_attribute1                   := p_pcp_attribute1;
  l_rec.pcp_attribute2                   := p_pcp_attribute2;
  l_rec.pcp_attribute3                   := p_pcp_attribute3;
  l_rec.pcp_attribute4                   := p_pcp_attribute4;
  l_rec.pcp_attribute5                   := p_pcp_attribute5;
  l_rec.pcp_attribute6                   := p_pcp_attribute6;
  l_rec.pcp_attribute7                   := p_pcp_attribute7;
  l_rec.pcp_attribute8                   := p_pcp_attribute8;
  l_rec.pcp_attribute9                   := p_pcp_attribute9;
  l_rec.pcp_attribute10                  := p_pcp_attribute10;
  l_rec.pcp_attribute11                  := p_pcp_attribute11;
  l_rec.pcp_attribute12                  := p_pcp_attribute12;
  l_rec.pcp_attribute13                  := p_pcp_attribute13;
  l_rec.pcp_attribute14                  := p_pcp_attribute14;
  l_rec.pcp_attribute15                  := p_pcp_attribute15;
  l_rec.pcp_attribute16                  := p_pcp_attribute16;
  l_rec.pcp_attribute17                  := p_pcp_attribute17;
  l_rec.pcp_attribute18                  := p_pcp_attribute18;
  l_rec.pcp_attribute19                  := p_pcp_attribute19;
  l_rec.pcp_attribute20                  := p_pcp_attribute20;
  l_rec.pcp_attribute21                  := p_pcp_attribute21;
  l_rec.pcp_attribute22                  := p_pcp_attribute22;
  l_rec.pcp_attribute23                  := p_pcp_attribute23;
  l_rec.pcp_attribute24                  := p_pcp_attribute24;
  l_rec.pcp_attribute25                  := p_pcp_attribute25;
  l_rec.pcp_attribute26                  := p_pcp_attribute26;
  l_rec.pcp_attribute27                  := p_pcp_attribute27;
  l_rec.pcp_attribute28                  := p_pcp_attribute28;
  l_rec.pcp_attribute29                  := p_pcp_attribute29;
  l_rec.pcp_attribute30                  := p_pcp_attribute30;
  l_rec.object_version_number            := p_object_version_number;
  --
  -- Return the plsql record structure.
  --
  Return(l_rec);
--
End convert_args;
--
end ben_pcp_shd;

/
