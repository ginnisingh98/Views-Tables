--------------------------------------------------------
--  DDL for Package Body BEN_EIV_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_EIV_SHD" as
/* $Header: beeivrhi.pkb 115.4 2002/12/22 20:25:28 pabodla noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  ben_eiv_shd.';  -- Global package name
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
  If (p_constraint_name = 'BEN_EXTRA_INPUT_VALUES_PK') Then
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
  (p_extra_input_value_id                 in     number
  ,p_object_version_number                in     number
  )
  Return Boolean Is
  --
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
       extra_input_value_id
      ,acty_base_rt_id
      ,input_value_id
      ,input_text
      ,upd_when_ele_ended_cd
      ,return_var_name
      ,business_group_id
      ,eiv_attribute_category
      ,eiv_attribute1
      ,eiv_attribute2
      ,eiv_attribute3
      ,eiv_attribute4
      ,eiv_attribute5
      ,eiv_attribute6
      ,eiv_attribute7
      ,eiv_attribute8
      ,eiv_attribute9
      ,eiv_attribute10
      ,eiv_attribute11
      ,eiv_attribute12
      ,eiv_attribute13
      ,eiv_attribute14
      ,eiv_attribute15
      ,eiv_attribute16
      ,eiv_attribute17
      ,eiv_attribute18
      ,eiv_attribute19
      ,eiv_attribute20
      ,eiv_attribute21
      ,eiv_attribute22
      ,eiv_attribute23
      ,eiv_attribute24
      ,eiv_attribute25
      ,eiv_attribute26
      ,eiv_attribute27
      ,eiv_attribute28
      ,eiv_attribute29
      ,eiv_attribute30
      ,object_version_number
    from        ben_extra_input_values
    where       extra_input_value_id = p_extra_input_value_id;
  --
  l_fct_ret     boolean;
  --
Begin
  --
  If (p_extra_input_value_id is null and
      p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_extra_input_value_id
        = ben_eiv_shd.g_old_rec.extra_input_value_id and
        p_object_version_number
        = ben_eiv_shd.g_old_rec.object_version_number
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
      Fetch C_Sel1 Into ben_eiv_shd.g_old_rec;
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
          <> ben_eiv_shd.g_old_rec.object_version_number) Then
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
  (p_extra_input_value_id                 in     number
  ,p_object_version_number                in     number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select
       extra_input_value_id
      ,acty_base_rt_id
      ,input_value_id
      ,input_text
      ,upd_when_ele_ended_cd
      ,return_var_name
      ,business_group_id
      ,eiv_attribute_category
      ,eiv_attribute1
      ,eiv_attribute2
      ,eiv_attribute3
      ,eiv_attribute4
      ,eiv_attribute5
      ,eiv_attribute6
      ,eiv_attribute7
      ,eiv_attribute8
      ,eiv_attribute9
      ,eiv_attribute10
      ,eiv_attribute11
      ,eiv_attribute12
      ,eiv_attribute13
      ,eiv_attribute14
      ,eiv_attribute15
      ,eiv_attribute16
      ,eiv_attribute17
      ,eiv_attribute18
      ,eiv_attribute19
      ,eiv_attribute20
      ,eiv_attribute21
      ,eiv_attribute22
      ,eiv_attribute23
      ,eiv_attribute24
      ,eiv_attribute25
      ,eiv_attribute26
      ,eiv_attribute27
      ,eiv_attribute28
      ,eiv_attribute29
      ,eiv_attribute30
      ,object_version_number
    from        ben_extra_input_values
    where       extra_input_value_id = p_extra_input_value_id
    for update nowait;
--
  l_proc        varchar2(72) := g_package||'lck';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'EXTRA_INPUT_VALUE_ID'
    ,p_argument_value     => p_extra_input_value_id
    );
  hr_utility.set_location(l_proc,6);
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'OBJECT_VERSION_NUMBER'
    ,p_argument_value     => p_object_version_number
    );
  --
  Open  C_Sel1;
  Fetch C_Sel1 Into ben_eiv_shd.g_old_rec;
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
      <> ben_eiv_shd.g_old_rec.object_version_number) Then
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
    fnd_message.set_token('TABLE_NAME', 'ben_extra_input_values');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
  (p_extra_input_value_id           in number
  ,p_acty_base_rt_id                in number
  ,p_input_value_id                 in number
  ,p_input_text                     in varchar2
  ,p_upd_when_ele_ended_cd          in varchar2
  ,p_return_var_name                in varchar2
  ,p_business_group_id              in number
  ,p_eiv_attribute_category         in varchar2
  ,p_eiv_attribute1                 in varchar2
  ,p_eiv_attribute2                 in varchar2
  ,p_eiv_attribute3                 in varchar2
  ,p_eiv_attribute4                 in varchar2
  ,p_eiv_attribute5                 in varchar2
  ,p_eiv_attribute6                 in varchar2
  ,p_eiv_attribute7                 in varchar2
  ,p_eiv_attribute8                 in varchar2
  ,p_eiv_attribute9                 in varchar2
  ,p_eiv_attribute10                in varchar2
  ,p_eiv_attribute11                in varchar2
  ,p_eiv_attribute12                in varchar2
  ,p_eiv_attribute13                in varchar2
  ,p_eiv_attribute14                in varchar2
  ,p_eiv_attribute15                in varchar2
  ,p_eiv_attribute16                in varchar2
  ,p_eiv_attribute17                in varchar2
  ,p_eiv_attribute18                in varchar2
  ,p_eiv_attribute19                in varchar2
  ,p_eiv_attribute20                in varchar2
  ,p_eiv_attribute21                in varchar2
  ,p_eiv_attribute22                in varchar2
  ,p_eiv_attribute23                in varchar2
  ,p_eiv_attribute24                in varchar2
  ,p_eiv_attribute25                in varchar2
  ,p_eiv_attribute26                in varchar2
  ,p_eiv_attribute27                in varchar2
  ,p_eiv_attribute28                in varchar2
  ,p_eiv_attribute29                in varchar2
  ,p_eiv_attribute30                in varchar2
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
  l_rec.extra_input_value_id             := p_extra_input_value_id;
  l_rec.acty_base_rt_id                  := p_acty_base_rt_id;
  l_rec.input_value_id                   := p_input_value_id;
  l_rec.input_text                       := p_input_text;
  l_rec.upd_when_ele_ended_cd            := p_upd_when_ele_ended_cd;
  l_rec.return_var_name                  := p_return_var_name;
  l_rec.business_group_id                := p_business_group_id;
  l_rec.eiv_attribute_category           := p_eiv_attribute_category;
  l_rec.eiv_attribute1                   := p_eiv_attribute1;
  l_rec.eiv_attribute2                   := p_eiv_attribute2;
  l_rec.eiv_attribute3                   := p_eiv_attribute3;
  l_rec.eiv_attribute4                   := p_eiv_attribute4;
  l_rec.eiv_attribute5                   := p_eiv_attribute5;
  l_rec.eiv_attribute6                   := p_eiv_attribute6;
  l_rec.eiv_attribute7                   := p_eiv_attribute7;
  l_rec.eiv_attribute8                   := p_eiv_attribute8;
  l_rec.eiv_attribute9                   := p_eiv_attribute9;
  l_rec.eiv_attribute10                  := p_eiv_attribute10;
  l_rec.eiv_attribute11                  := p_eiv_attribute11;
  l_rec.eiv_attribute12                  := p_eiv_attribute12;
  l_rec.eiv_attribute13                  := p_eiv_attribute13;
  l_rec.eiv_attribute14                  := p_eiv_attribute14;
  l_rec.eiv_attribute15                  := p_eiv_attribute15;
  l_rec.eiv_attribute16                  := p_eiv_attribute16;
  l_rec.eiv_attribute17                  := p_eiv_attribute17;
  l_rec.eiv_attribute18                  := p_eiv_attribute18;
  l_rec.eiv_attribute19                  := p_eiv_attribute19;
  l_rec.eiv_attribute20                  := p_eiv_attribute20;
  l_rec.eiv_attribute21                  := p_eiv_attribute21;
  l_rec.eiv_attribute22                  := p_eiv_attribute22;
  l_rec.eiv_attribute23                  := p_eiv_attribute23;
  l_rec.eiv_attribute24                  := p_eiv_attribute24;
  l_rec.eiv_attribute25                  := p_eiv_attribute25;
  l_rec.eiv_attribute26                  := p_eiv_attribute26;
  l_rec.eiv_attribute27                  := p_eiv_attribute27;
  l_rec.eiv_attribute28                  := p_eiv_attribute28;
  l_rec.eiv_attribute29                  := p_eiv_attribute29;
  l_rec.eiv_attribute30                  := p_eiv_attribute30;
  l_rec.object_version_number            := p_object_version_number;
  --
  -- Return the plsql record structure.
  --
  Return(l_rec);
--
End convert_args;
--
end ben_eiv_shd;

/
