--------------------------------------------------------
--  DDL for Package Body HXC_ERR_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_ERR_SHD" as
/* $Header: hxcerrrhi.pkb 120.2 2005/09/23 08:08:12 sechandr noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  hxc_err_shd.';  -- Global package name
g_debug    boolean	:= hr_utility.debug_enabled;
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
  If (p_constraint_name = 'HXC_ERRORS_PK') Then
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
  (p_error_id                             in     number
  ,p_object_version_number                in     number
  )
  Return Boolean Is
  --
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
       error_id
      ,transaction_detail_id
      ,time_building_block_id
      ,time_building_block_ovn
      ,time_attribute_id
      ,time_attribute_ovn
      ,message_name
      ,message_level
      ,message_field
      ,message_tokens
      ,application_short_name
      ,object_version_number
      ,date_from
      ,date_to
    from        hxc_errors
    where       error_id = p_error_id;
  --
  l_fct_ret     boolean;
  --
Begin
  --
  If (p_error_id is null --p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_error_id
        = hxc_err_shd.g_old_rec.error_id --and
        --p_object_version_number
        --= hxc_err_shd.g_old_rec.object_version_number
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
      Fetch C_Sel1 Into hxc_err_shd.g_old_rec;
      If C_Sel1%notfound Then
        Close C_Sel1;
        --
        -- The primary key is invalid therefore we must error
        --
        fnd_message.set_name('PAY', 'HR_7220_INVALID_PRIMARY_KEY');
        fnd_message.raise_error;
      End If;
      Close C_Sel1;
--      If (p_object_version_number
 --         <> hxc_err_shd.g_old_rec.object_version_number) Then
  --      fnd_message.set_name('PAY', 'HR_7155_OBJECT_INVALID');
   --     fnd_message.raise_error;
    --  End If;
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
  (p_error_id                             in     number
  ,p_object_version_number                in     number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select
       error_id
      ,transaction_detail_id
      ,time_building_block_id
      ,time_building_block_ovn
      ,time_attribute_id
      ,time_attribute_ovn
      ,message_name
      ,message_level
      ,message_field
      ,message_tokens
      ,application_short_name
      ,object_version_number
      ,date_from
      ,date_to
    from        hxc_errors
    where       error_id = p_error_id
    for update nowait;
--
  l_proc        varchar2(72);
--
Begin
  g_debug:=hr_utility.debug_enabled;
  if g_debug then
	l_proc := g_package||'lck';
	hr_utility.set_location('Entering:'||l_proc, 5);
  end if;
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'ERROR_ID'
    ,p_argument_value     => p_error_id
    );
  if g_debug then
	hr_utility.set_location(l_proc,6);
  end if;
  --hr_api.mandatory_arg_error
   -- (p_api_name           => l_proc
   -- ,p_argument           => 'OBJECT_VERSION_NUMBER'
    --,p_argument_value     => p_object_version_number
    --);
  --
  Open  C_Sel1;
  Fetch C_Sel1 Into hxc_err_shd.g_old_rec;
  If C_Sel1%notfound then
    Close C_Sel1;
    --
    -- The primary key is invalid therefore we must error
    --
    fnd_message.set_name('PAY', 'HR_7220_INVALID_PRIMARY_KEY');
    fnd_message.raise_error;
  End If;
  Close C_Sel1;
--  If (p_object_version_number
 --     <> hxc_err_shd.g_old_rec.object_version_number) Then
  --      fnd_message.set_name('PAY', 'HR_7155_OBJECT_INVALID');
   --     fnd_message.raise_error;
--  End If;
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
    fnd_message.set_token('TABLE_NAME', 'hxc_errors');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
  (p_error_id                       in number
  ,p_transaction_detail_id          in number
  ,p_time_building_block_id         in number
  ,p_time_building_block_ovn        in number
  ,p_time_attribute_id              in number
  ,p_time_attribute_ovn             in number
  ,p_message_name                   in varchar2
  ,p_message_level                  in varchar2
  ,p_message_field                  in varchar2
  ,p_message_tokens                 in varchar2
  ,p_application_short_name         in varchar2
  ,p_object_version_number          in number
  ,p_date_from			    in date
  ,p_date_to			    in date
  )
  Return g_rec_type is
--
  l_rec   g_rec_type;
--
Begin
  --
  -- Convert arguments into local l_rec structure.
  --
  l_rec.error_id                         := p_error_id;
  l_rec.transaction_detail_id            := p_transaction_detail_id;
  l_rec.time_building_block_id           := p_time_building_block_id;
  l_rec.time_building_block_ovn          := p_time_building_block_ovn;
  l_rec.time_attribute_id                := p_time_attribute_id;
  l_rec.time_attribute_ovn               := p_time_attribute_ovn;
  l_rec.message_name                     := p_message_name;
  l_rec.message_level                    := p_message_level;
  l_rec.message_field                    := p_message_field;
  l_rec.message_tokens                   := p_message_tokens;
  l_rec.application_short_name           := p_application_short_name;
  l_rec.object_version_number            := p_object_version_number;
  l_rec.date_from			 := p_date_from;
  l_rec.date_to			         := p_date_to;
  --
  -- Return the plsql record structure.
  --
  Return(l_rec);
--
End convert_args;
--
end hxc_err_shd;

/
