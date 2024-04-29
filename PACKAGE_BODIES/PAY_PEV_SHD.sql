--------------------------------------------------------
--  DDL for Package Body PAY_PEV_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_PEV_SHD" as
/* $Header: pypperhi.pkb 120.1.12010000.1 2008/07/27 23:25:17 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pay_pev_shd.';  -- Global package name
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
  If (p_constraint_name = 'PAY_PROCESS_EVENTS_FK2') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','5');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'PAY_PROCESS_EVENT_FK1') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','10');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'PAY_PROCESS_EVENT_ID_PK') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','15');
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
  (p_process_event_id                     in     number
  ,p_object_version_number                in     number
  )
  Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
       process_event_id
      ,assignment_id
      ,effective_date
      ,change_type
      ,status
      ,description
      ,event_update_id
      ,business_group_id
      ,org_process_event_group_id
      ,surrogate_key
      ,object_version_number
      ,calculation_date
      ,retroactive_status
      ,noted_value
    from	pay_process_events
    where	process_event_id = p_process_event_id;
--
  l_fct_ret	boolean;
--
Begin
  --
  If (p_process_event_id is null and
      p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_process_event_id
        = pay_pev_shd.g_old_rec.process_event_id and
        p_object_version_number
        = pay_pev_shd.g_old_rec.object_version_number
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
      Fetch C_Sel1 Into pay_pev_shd.g_old_rec;
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
          <> pay_pev_shd.g_old_rec.object_version_number) Then
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
  (p_process_event_id                     in     number
  ,p_object_version_number                in     number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select
       process_event_id
      ,assignment_id
      ,effective_date
      ,change_type
      ,status
      ,description
      ,event_update_id
      ,business_group_id
      ,org_process_event_group_id
      ,surrogate_key
      ,object_version_number
      ,calculation_date
      ,retroactive_status
      ,noted_value
    from	pay_process_events
    where	process_event_id = p_process_event_id
    for	update nowait;
--
  l_proc	varchar2(72) := g_package||'lck';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'PROCESS_EVENT_ID'
    ,p_argument_value     => p_process_event_id
    );
  --
  Open  C_Sel1;
  Fetch C_Sel1 Into pay_pev_shd.g_old_rec;
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
      <> pay_pev_shd.g_old_rec.object_version_number) Then
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
    fnd_message.set_token('TABLE_NAME', 'pay_process_events');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
  (p_process_event_id               in number
  ,p_assignment_id                  in number
  ,p_effective_date                 in date
  ,p_change_type                    in varchar2
  ,p_status                         in varchar2
  ,p_description                    in varchar2
  ,p_event_update_id                in number
  ,p_business_group_id              in number
  ,p_org_process_event_group_id     in number
  ,p_surrogate_key                  in varchar2
  ,p_object_version_number          in number
  ,p_calculation_date               in date
  ,p_retroactive_status             in varchar2
  ,p_noted_value                    in varchar2
  )
  Return g_rec_type is
--
  l_rec   g_rec_type;
--
Begin
  --
  -- Convert arguments into local l_rec structure.
  --
  l_rec.process_event_id                 := p_process_event_id;
  l_rec.assignment_id                    := p_assignment_id;
  l_rec.effective_date                   := p_effective_date;
  l_rec.change_type                      := p_change_type;
  l_rec.status                           := p_status;
  l_rec.description                      := p_description;
  l_rec.event_update_id                  := p_event_update_id;
  l_rec.business_group_id                := p_business_group_id;
  l_rec.org_process_event_group_id       := p_org_process_event_group_id;
  l_rec.surrogate_key                    := p_surrogate_key;
  l_rec.object_version_number            := p_object_version_number;
  l_rec.calculation_date                 := p_calculation_date;
  l_rec.retroactive_status               := p_retroactive_status;
  l_rec.noted_value                      := p_noted_value;
  --
  -- Return the plsql record structure.
  --
  Return(l_rec);
--
End convert_args;
--
end pay_pev_shd;

/
