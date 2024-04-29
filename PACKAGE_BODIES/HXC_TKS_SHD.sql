--------------------------------------------------------
--  DDL for Package Body HXC_TKS_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_TKS_SHD" as
/* $Header: hxctksrhi.pkb 120.2 2005/09/23 05:29:46 rchennur noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  hxc_tks_shd.';  -- Global package name
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
/*  If (p_constraint_name = 'HXC_TK_TIMEKEEPER_SUBMITS_PK1') Then
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
  */
  null;
  --
End constraint_error;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< api_updating >-----------------------------|
-- ----------------------------------------------------------------------------
Function api_updating
  (p_submission_id                        in     number
  )
  Return Boolean Is
  --
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
       submission_id
      ,resource_id
    from        hxc_tk_timekeeper_submits
    where       submission_id = p_submission_id;
  --
  l_fct_ret     boolean;
  --
Begin
  --
  If (p_submission_id is null ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_submission_id
        = hxc_tks_shd.g_old_rec.submission_id
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
      Fetch C_Sel1 Into hxc_tks_shd.g_old_rec;
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
  (p_submission_id                        in     number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select
       submission_id
      ,resource_id
    from        hxc_tk_timekeeper_submits
    where       submission_id = p_submission_id
    for update nowait;
--
  l_proc        varchar2(72) ;
--
Begin
  g_debug :=hr_utility.debug_enabled;
  if g_debug then
  	l_proc := g_package||'lck';
  	hr_utility.set_location('Entering:'||l_proc, 5);
  end if;
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'SUBMISSION_ID'
    ,p_argument_value     => p_submission_id
    );
  --
  Open  C_Sel1;
  Fetch C_Sel1 Into hxc_tks_shd.g_old_rec;
  If C_Sel1%notfound then
    Close C_Sel1;
    --
    -- The primary key is invalid therefore we must error
    --
--    fnd_message.set_name('PAY', 'HR_7220_INVALID_PRIMARY_KEY');
  --  fnd_message.raise_error;
  null;

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
    fnd_message.set_token('TABLE_NAME', 'hxc_tk_timekeeper_submits');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
  (p_submission_id                  in number
  ,p_resource_id                    in number
  )
  Return g_rec_type is
--
  l_rec   g_rec_type;
--
Begin
  --
  -- Convert arguments into local l_rec structure.
  --
  l_rec.submission_id                    := p_submission_id;
  l_rec.resource_id                      := p_resource_id;
  --
  -- Return the plsql record structure.
  --
  Return(l_rec);
--
End convert_args;
--
end hxc_tks_shd;

/
