--------------------------------------------------------
--  DDL for Package Body PAY_EVG_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_EVG_SHD" as
/* $Header: pyevgrhi.pkb 120.4 2005/11/07 09:03:07 mkataria noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pay_evg_shd.';  -- Global package name
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
  If (p_constraint_name = 'PAY_EVENT_GROUPS_PK') Then
    fnd_message.set_name('PAY', 'HR_7220_INVALID_PRIMARY_KEY');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'PAY_EVENT_GROUPS_UK1') Then
    fnd_message.set_name('PAY', 'HR_6123_ALL_UNIQUE_NAME');
    fnd_message.set_token('INFORMATION_TYPE', 'Event Group');
    fnd_message.raise_error;
  --ElsIf (p_constraint_name = 'PAY_EVENT_GROUPS_FK1') Then
    --fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    --fnd_message.set_token('PROCEDURE', l_proc);
    --fnd_message.set_token('STEP','10');
    --fnd_message.raise_error;
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
  (p_event_group_id                       in     number
  ,p_object_version_number                in     number
  )
  Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
       event_group_id
      ,event_group_name
      ,event_group_type
      ,proration_type
      ,business_group_id
      ,legislation_code
      ,object_version_number
      ,time_definition_id
    from	pay_event_groups
    where	event_group_id = p_event_group_id;
--
  l_fct_ret	boolean;
--
Begin
  --
  If (p_event_group_id is null and
      p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_event_group_id
        = pay_evg_shd.g_old_rec.event_group_id and
        p_object_version_number
        = pay_evg_shd.g_old_rec.object_version_number
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
      Fetch C_Sel1 Into pay_evg_shd.g_old_rec;
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
          <> pay_evg_shd.g_old_rec.object_version_number) Then
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
  (p_event_group_id                       in     number
  ,p_object_version_number                in     number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select
       event_group_id
      ,event_group_name
      ,event_group_type
      ,proration_type
      ,business_group_id
      ,legislation_code
      ,object_version_number
      ,time_definition_id
    from	pay_event_groups
    where	event_group_id = p_event_group_id
    for	update nowait;
--
  l_proc	varchar2(72) := g_package||'lck';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'EVENT_GROUP_ID'
    ,p_argument_value     => p_event_group_id
    );
  --
  Open  C_Sel1;
  Fetch C_Sel1 Into pay_evg_shd.g_old_rec;
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
      <> pay_evg_shd.g_old_rec.object_version_number) Then
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
    fnd_message.set_token('TABLE_NAME', 'pay_event_groups');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
  (p_event_group_id                 in number
  ,p_event_group_name               in varchar2
  ,p_event_group_type               in varchar2
  ,p_proration_type                 in varchar2
  ,p_business_group_id              in number
  ,p_legislation_code               in varchar2
  ,p_object_version_number          in number
  ,p_time_definition_id             in number
  )
  Return g_rec_type is
--
  l_rec   g_rec_type;
--
Begin
  --
  -- Convert arguments into local l_rec structure.
  --
  l_rec.event_group_id                   := p_event_group_id;
  l_rec.event_group_name                 := p_event_group_name;
  l_rec.event_group_type                 := p_event_group_type;
  l_rec.proration_type                   := p_proration_type;
  l_rec.business_group_id                := p_business_group_id;
  l_rec.legislation_code                 := p_legislation_code;
  l_rec.object_version_number            := p_object_version_number;
  l_rec.time_definition_id               := p_time_definition_id;
  --
  -- Return the plsql record structure.
  --
  Return(l_rec);
--
End convert_args;
--
end pay_evg_shd;

/
