--------------------------------------------------------
--  DDL for Package Body HR_CTX_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_CTX_SHD" as
/* $Header: hrctxrhi.pkb 120.0 2005/05/30 23:30:30 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  hr_ctx_shd.';  -- Global package name
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
  If (p_constraint_name = 'HR_KI_CONTEXT_PK') Then
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
  (p_context_id                           in     number
  ,p_object_version_number                in     number
  )
  Return Boolean Is
  --
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
       context_id
      ,view_name
      ,param_1
      ,param_2
      ,param_3
      ,param_4
      ,param_5
      ,param_6
      ,param_7
      ,param_8
      ,param_9
      ,param_10
      ,param_11
      ,param_12
      ,param_13
      ,param_14
      ,param_15
      ,param_16
      ,param_17
      ,param_18
      ,param_19
      ,param_20
      ,param_21
      ,param_22
      ,param_23
      ,param_24
      ,param_25
      ,param_26
      ,param_27
      ,param_28
      ,param_29
      ,param_30
      ,object_version_number
    from        hr_ki_contexts
    where       context_id = p_context_id;
  --
  l_fct_ret     boolean;
  --
Begin
  --
  If (p_context_id is null and
      p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_context_id
        = hr_ctx_shd.g_old_rec.context_id and
        p_object_version_number
        = hr_ctx_shd.g_old_rec.object_version_number
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
      Fetch C_Sel1 Into hr_ctx_shd.g_old_rec;
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
          <> hr_ctx_shd.g_old_rec.object_version_number) Then
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
  (p_context_id                           in     number
  ,p_object_version_number                in     number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select
       context_id
      ,view_name
      ,param_1
      ,param_2
      ,param_3
      ,param_4
      ,param_5
      ,param_6
      ,param_7
      ,param_8
      ,param_9
      ,param_10
      ,param_11
      ,param_12
      ,param_13
      ,param_14
      ,param_15
      ,param_16
      ,param_17
      ,param_18
      ,param_19
      ,param_20
      ,param_21
      ,param_22
      ,param_23
      ,param_24
      ,param_25
      ,param_26
      ,param_27
      ,param_28
      ,param_29
      ,param_30
      ,object_version_number
    from        hr_ki_contexts
    where       context_id = p_context_id
    for update nowait;
--
  l_proc        varchar2(72) := g_package||'lck';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'CONTEXT_ID'
    ,p_argument_value     => p_context_id
    );
  hr_utility.set_location(l_proc,6);
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'OBJECT_VERSION_NUMBER'
    ,p_argument_value     => p_object_version_number
    );
  --
  Open  C_Sel1;
  Fetch C_Sel1 Into hr_ctx_shd.g_old_rec;
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
      <> hr_ctx_shd.g_old_rec.object_version_number) Then
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
    fnd_message.set_token('TABLE_NAME', 'hr_ki_contexts');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
  (p_context_id                     in number
  ,p_view_name                      in varchar2
  ,p_param_1                        in varchar2
  ,p_param_2                        in varchar2
  ,p_param_3                        in varchar2
  ,p_param_4                        in varchar2
  ,p_param_5                        in varchar2
  ,p_param_6                        in varchar2
  ,p_param_7                        in varchar2
  ,p_param_8                        in varchar2
  ,p_param_9                        in varchar2
  ,p_param_10                       in varchar2
  ,p_param_11                       in varchar2
  ,p_param_12                       in varchar2
  ,p_param_13                       in varchar2
  ,p_param_14                       in varchar2
  ,p_param_15                       in varchar2
  ,p_param_16                       in varchar2
  ,p_param_17                       in varchar2
  ,p_param_18                       in varchar2
  ,p_param_19                       in varchar2
  ,p_param_20                       in varchar2
  ,p_param_21                       in varchar2
  ,p_param_22                       in varchar2
  ,p_param_23                       in varchar2
  ,p_param_24                       in varchar2
  ,p_param_25                       in varchar2
  ,p_param_26                       in varchar2
  ,p_param_27                       in varchar2
  ,p_param_28                       in varchar2
  ,p_param_29                       in varchar2
  ,p_param_30                       in varchar2
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
  l_rec.context_id                       := p_context_id;
  l_rec.view_name                        := p_view_name;
  l_rec.param_1                          := p_param_1;
  l_rec.param_2                          := p_param_2;
  l_rec.param_3                          := p_param_3;
  l_rec.param_4                          := p_param_4;
  l_rec.param_5                          := p_param_5;
  l_rec.param_6                          := p_param_6;
  l_rec.param_7                          := p_param_7;
  l_rec.param_8                          := p_param_8;
  l_rec.param_9                          := p_param_9;
  l_rec.param_10                         := p_param_10;
  l_rec.param_11                         := p_param_11;
  l_rec.param_12                         := p_param_12;
  l_rec.param_13                         := p_param_13;
  l_rec.param_14                         := p_param_14;
  l_rec.param_15                         := p_param_15;
  l_rec.param_16                         := p_param_16;
  l_rec.param_17                         := p_param_17;
  l_rec.param_18                         := p_param_18;
  l_rec.param_19                         := p_param_19;
  l_rec.param_20                         := p_param_20;
  l_rec.param_21                         := p_param_21;
  l_rec.param_22                         := p_param_22;
  l_rec.param_23                         := p_param_23;
  l_rec.param_24                         := p_param_24;
  l_rec.param_25                         := p_param_25;
  l_rec.param_26                         := p_param_26;
  l_rec.param_27                         := p_param_27;
  l_rec.param_28                         := p_param_28;
  l_rec.param_29                         := p_param_29;
  l_rec.param_30                         := p_param_30;
  l_rec.object_version_number            := p_object_version_number;
  --
  -- Return the plsql record structure.
  --
  Return(l_rec);
--
End convert_args;
--
end hr_ctx_shd;

/
