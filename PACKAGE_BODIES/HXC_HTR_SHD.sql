--------------------------------------------------------
--  DDL for Package Body HXC_HTR_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_HTR_SHD" as
/* $Header: hxchtrrhi.pkb 120.2 2005/09/23 07:45:11 nissharm noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  hxc_htr_shd.';  -- Global package name

g_debug boolean := hr_utility.debug_enabled;
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
  If (p_constraint_name = 'HXC_TIME_APPLICATIONS_PK') Then
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
  (p_time_recipient_id                    in     number
  ,p_object_version_number                in     number
  )
  Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
       time_recipient_id
      ,name
      ,application_id
      ,object_version_number
      ,application_retrieval_function
      ,application_update_process
      ,appl_validation_process
      ,application_period_function
      ,appl_dynamic_template_process
      ,extension_function1
      ,extension_function2
    from	hxc_time_recipients
    where	time_recipient_id = p_time_recipient_id;
--
  l_fct_ret	boolean;
--
Begin
  --
  If (p_time_recipient_id is null and
      p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_time_recipient_id
        = hxc_htr_shd.g_old_rec.time_recipient_id and
        p_object_version_number
        = hxc_htr_shd.g_old_rec.object_version_number
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
      Fetch C_Sel1 Into hxc_htr_shd.g_old_rec;
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
          <> hxc_htr_shd.g_old_rec.object_version_number) Then
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
  (p_time_recipient_id                    in     number
  ,p_object_version_number                in     number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select
       time_recipient_id
      ,name
      ,application_id
      ,object_version_number
      ,application_retrieval_function
      ,application_update_process
      ,appl_validation_process
      ,application_period_function
      ,appl_dynamic_template_process
      ,extension_function1
      ,extension_function2
    from	hxc_time_recipients
    where	time_recipient_id = p_time_recipient_id
    for	update nowait;
--
  l_proc	varchar2(72);
--
Begin
  g_debug := hr_utility.debug_enabled;

  if g_debug then
  	l_proc := g_package||'lck';
  	hr_utility.set_location('Entering:'||l_proc, 5);
  end if;
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'TIME_RECIPIENT_ID'
    ,p_argument_value     => p_time_recipient_id
    );
  --
  if g_debug then
  	hr_utility.set_location('Locking:'||l_proc, 1000);
  end if;
  Open  C_Sel1;
  Fetch C_Sel1 Into hxc_htr_shd.g_old_rec;
  if g_debug then
  	hr_utility.set_location('After Locking:'||l_proc, 2000);
  end if;
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
      <> hxc_htr_shd.g_old_rec.object_version_number) Then
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
    fnd_message.set_token('TABLE_NAME', 'hxc_time_recipients');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
  (p_time_recipient_id              in number
  ,p_name                           in varchar2
  ,p_appl_retrieval_function        in varchar2
  ,p_appl_update_process            in varchar2
  ,p_appl_validation_process        in varchar2
  ,p_appl_period_function           in varchar2
  ,p_appl_dyn_template_process      in varchar2
  ,p_extension_function1            in varchar2
  ,p_extension_function2            in varchar2
  ,p_application_id                 in number
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
  l_rec.time_recipient_id                := p_time_recipient_id;
  l_rec.name                             := p_name;
  l_rec.application_id                   := p_application_id;
  l_rec.object_version_number            := p_object_version_number;
  l_rec.application_retrieval_function   := p_appl_retrieval_function;
  l_rec.application_update_process       := p_appl_update_process;
  l_rec.appl_validation_process          := p_appl_validation_process;
  l_rec.application_period_function      := p_appl_period_function;
  l_rec.appl_dynamic_template_process    := p_appl_dyn_template_process;
  l_rec.extension_function1              := p_extension_function1;
  l_rec.extension_function2              := p_extension_function2;
  --
  -- Return the plsql record structure.
  --
  Return(l_rec);
--
End convert_args;
--
end hxc_htr_shd;

/
