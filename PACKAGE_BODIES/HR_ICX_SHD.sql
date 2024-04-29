--------------------------------------------------------
--  DDL for Package Body HR_ICX_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_ICX_SHD" as
/* $Header: hricxrhi.pkb 115.5 2003/10/23 01:44:08 bsubrama noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  hr_icx_shd.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |---------------------------< constraint_error >---------------------------|
-- ----------------------------------------------------------------------------
Procedure constraint_error
  (p_constraint_name in all_constraints.constraint_name%TYPE
  ) Is
--
  l_proc  varchar2(72) := g_package||'constraint_error';
--
Begin
  --
  If (p_constraint_name = 'HR_ITEM_CONTEXTS_PK') Then
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
  (p_item_context_id                      in     number
  ,p_object_version_number                in     number
  )
  Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
       item_context_id
      ,object_version_number
      ,id_flex_num
      ,summary_flag
      ,enabled_flag
      ,start_date_active
      ,end_date_active
      ,segment1
      ,segment2
      ,segment3
      ,segment4
      ,segment5
      ,segment6
      ,segment7
      ,segment8
      ,segment9
      ,segment10
      ,segment11
      ,segment12
      ,segment13
      ,segment14
      ,segment15
      ,segment16
      ,segment17
      ,segment18
      ,segment19
      ,segment20
      ,segment21
      ,segment22
      ,segment23
      ,segment24
      ,segment25
      ,segment26
      ,segment27
      ,segment28
      ,segment29
      ,segment30
    from  hr_item_contexts
    where item_context_id = p_item_context_id;
--
  l_fct_ret boolean;
--
Begin
  --
  If (p_item_context_id is null and
      p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_item_context_id
        = hr_icx_shd.g_old_rec.item_context_id and
        p_object_version_number
        = hr_tdg_shd.g_old_rec.object_version_number
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
      Fetch C_Sel1 Into hr_icx_shd.g_old_rec;
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
          <> hr_tdg_shd.g_old_rec.object_version_number) Then
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
  (p_item_context_id                      in     number
  ,p_object_version_number                in     number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select
       item_context_id
      ,object_version_number
      ,id_flex_num
      ,summary_flag
      ,enabled_flag
      ,start_date_active
      ,end_date_active
      ,segment1
      ,segment2
      ,segment3
      ,segment4
      ,segment5
      ,segment6
      ,segment7
      ,segment8
      ,segment9
      ,segment10
      ,segment11
      ,segment12
      ,segment13
      ,segment14
      ,segment15
      ,segment16
      ,segment17
      ,segment18
      ,segment19
      ,segment20
      ,segment21
      ,segment22
      ,segment23
      ,segment24
      ,segment25
      ,segment26
      ,segment27
      ,segment28
      ,segment29
      ,segment30
    from  hr_item_contexts
    where item_context_id = p_item_context_id
    for update nowait;
--
  l_proc  varchar2(72) := g_package||'lck';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'ITEM_CONTEXT_ID'
    ,p_argument_value     => p_item_context_id
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name   => l_proc
    ,p_argument   => 'object_version_number'
    ,p_argument_value   => p_object_version_number
   );
  Open  C_Sel1;
  Fetch C_Sel1 Into hr_icx_shd.g_old_rec;
  If C_Sel1%notfound then
    Close C_Sel1;
    --
    -- The primary key is invalid therefore we must error
    --
    fnd_message.set_name('PAY', 'HR_7220_INVALID_PRIMARY_KEY');
    fnd_message.raise_error;
  End If;
  Close C_Sel1;
  --
  If (p_object_version_number
      <> hr_tdg_shd.g_old_rec.object_version_number) Then
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
    fnd_message.set_token('TABLE_NAME', 'hr_item_contexts');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
  (p_item_context_id                in number
  ,p_object_version_number          in number
  ,p_id_flex_num                    in number
  ,p_summary_flag                   in varchar2
  ,p_enabled_flag                   in varchar2
  ,p_start_date_active              in date
  ,p_end_date_active                in date
  ,p_segment1                       in varchar2
  ,p_segment2                       in varchar2
  ,p_segment3                       in varchar2
  ,p_segment4                       in varchar2
  ,p_segment5                       in varchar2
  ,p_segment6                       in varchar2
  ,p_segment7                       in varchar2
  ,p_segment8                       in varchar2
  ,p_segment9                       in varchar2
  ,p_segment10                      in varchar2
  ,p_segment11                      in varchar2
  ,p_segment12                      in varchar2
  ,p_segment13                      in varchar2
  ,p_segment14                      in varchar2
  ,p_segment15                      in varchar2
  ,p_segment16                      in varchar2
  ,p_segment17                      in varchar2
  ,p_segment18                      in varchar2
  ,p_segment19                      in varchar2
  ,p_segment20                      in varchar2
  ,p_segment21                      in varchar2
  ,p_segment22                      in varchar2
  ,p_segment23                      in varchar2
  ,p_segment24                      in varchar2
  ,p_segment25                      in varchar2
  ,p_segment26                      in varchar2
  ,p_segment27                      in varchar2
  ,p_segment28                      in varchar2
  ,p_segment29                      in varchar2
  ,p_segment30                      in varchar2
  )
  Return g_rec_type is
--
  l_rec   g_rec_type;
--
Begin
  --
  -- Convert arguments into local l_rec structure.
  --
  l_rec.item_context_id                  := p_item_context_id;
  l_rec.object_version_number            := p_object_version_number;
  l_rec.id_flex_num                      := p_id_flex_num;
  l_rec.summary_flag                     := p_summary_flag;
  l_rec.enabled_flag                     := p_enabled_flag;
  l_rec.start_date_active                := p_start_date_active;
  l_rec.end_date_active                  := p_end_date_active;
  l_rec.segment1                         := p_segment1;
  l_rec.segment2                         := p_segment2;
  l_rec.segment3                         := p_segment3;
  l_rec.segment4                         := p_segment4;
  l_rec.segment5                         := p_segment5;
  l_rec.segment6                         := p_segment6;
  l_rec.segment7                         := p_segment7;
  l_rec.segment8                         := p_segment8;
  l_rec.segment9                         := p_segment9;
  l_rec.segment10                        := p_segment10;
  l_rec.segment11                        := p_segment11;
  l_rec.segment12                        := p_segment12;
  l_rec.segment13                        := p_segment13;
  l_rec.segment14                        := p_segment14;
  l_rec.segment15                        := p_segment15;
  l_rec.segment16                        := p_segment16;
  l_rec.segment17                        := p_segment17;
  l_rec.segment18                        := p_segment18;
  l_rec.segment19                        := p_segment19;
  l_rec.segment20                        := p_segment20;
  l_rec.segment21                        := p_segment21;
  l_rec.segment22                        := p_segment22;
  l_rec.segment23                        := p_segment23;
  l_rec.segment24                        := p_segment24;
  l_rec.segment25                        := p_segment25;
  l_rec.segment26                        := p_segment26;
  l_rec.segment27                        := p_segment27;
  l_rec.segment28                        := p_segment28;
  l_rec.segment29                        := p_segment29;
  l_rec.segment30                        := p_segment30;
  --
  -- Return the plsql record structure.
  --
  Return(l_rec);
--
End convert_args;
--
end hr_icx_shd;

/
