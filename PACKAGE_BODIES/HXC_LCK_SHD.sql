--------------------------------------------------------
--  DDL for Package Body HXC_LCK_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_LCK_SHD" as
/* $Header: hxclocktypesrhi.pkb 120.2 2005/09/23 08:08:21 nissharm noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  hxc_lck_shd.';  -- Global package name

g_debug boolean := hr_utility.debug_enabled;
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
  If (p_constraint_name = 'HXC_LOCKER_TYPES_PK') Then
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
  (p_locker_type_id                       in     number
  )
  Return Boolean Is
  --
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
       locker_type_id
      ,locker_type
      ,process_type
    from        hxc_locker_types
    where       locker_type_id = p_locker_type_id;
  --
  l_fct_ret     boolean;
  --
Begin
  --
  If (p_locker_type_id is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_locker_type_id
        = hxc_lck_shd.g_old_rec.locker_type_id
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
      Fetch C_Sel1 Into hxc_lck_shd.g_old_rec;
      If C_Sel1%notfound Then
        Close C_Sel1;
        --
        -- The primary key is invalid therefore we must error
        --
        fnd_message.set_name('PAY', 'HR_7220_INVALID_PRIMARY_KEY');
        fnd_message.raise_error;
      End If;
      Close C_Sel1;
      --
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
  (p_locker_type_id                       in     number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select
       locker_type_id
      ,locker_type
      ,process_type
    from        hxc_locker_types
    where       locker_type_id = p_locker_type_id
    for update nowait;
--
  l_proc        varchar2(72);
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
    ,p_argument           => 'LOCKER_TYPE_ID'
    ,p_argument_value     => p_locker_type_id
    );
  --
  Open  C_Sel1;
  Fetch C_Sel1 Into hxc_lck_shd.g_old_rec;
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
    fnd_message.set_token('TABLE_NAME', 'hxc_locker_types');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
  (p_locker_type_id                 in number
  ,p_locker_type                    in varchar2
  ,p_process_type                   in varchar2
  )
  Return g_rec_type is
--
  l_rec   g_rec_type;
--
Begin
  --
  -- Convert arguments into local l_rec structure.
  --
  l_rec.locker_type_id                   := p_locker_type_id;
  l_rec.locker_type                      := p_locker_type;
  l_rec.process_type                     := p_process_type;
  --
  -- Return the plsql record structure.
  --
  Return(l_rec);
--
End convert_args;
--
end hxc_lck_shd;

/
