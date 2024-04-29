--------------------------------------------------------
--  DDL for Package Body HR_AHK_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_AHK_SHD" as
/* $Header: hrahkrhi.pkb 115.8 2002/12/03 16:34:49 apholt ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  hr_ahk_shd.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |---------------------------< constraint_error >---------------------------|
-- ----------------------------------------------------------------------------
Procedure constraint_error
            (p_constraint_name in all_constraints.constraint_name%TYPE) Is
--
  l_proc 	varchar2(72) := g_package||'constraint_error';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (p_constraint_name = 'HR_API_HOOKS_CK1') Then
    hr_utility.set_message(800, 'PER_52127_AHK_HOOK_TYPE_INV');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'HR_API_HOOKS_CK2') Then
    hr_utility.set_message(800, 'PER_52133_AHK_LEG_PACK_FUN_INV');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'HR_API_HOOKS_FK1') Then
    hr_utility.set_message(800, 'PER_52154_AHK_MOD_ID_INV');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'HR_API_HOOKS_PK') Then
    hr_utility.set_message(800, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','20');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'HR_API_HOOKS_UK1') Then
    hr_utility.set_message(800, 'PER_52128_AHK_DUP_HOOK_TYPE');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'HR_API_HOOKS_UK2') Then
    hr_utility.set_message(800, 'PER_52130_AHK_HOOK_PROC_INV');
    hr_utility.raise_error;
  Else
    hr_utility.set_message(800, 'HR_7877_API_INVALID_CONSTRAINT');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('CONSTRAINT_NAME', p_constraint_name);
    hr_utility.raise_error;
  End If;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End constraint_error;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< api_updating >-----------------------------|
-- ----------------------------------------------------------------------------
Function api_updating
  (
  p_api_hook_id                        in number
  )      Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
		api_hook_id,
	api_module_id,
	api_hook_type,
	hook_package,
	hook_procedure,
	legislation_code,
	legislation_package,
	legislation_function,
	encoded_error
    from	hr_api_hooks
    where	api_hook_id = p_api_hook_id;
--
  l_proc	varchar2(72)	:= g_package||'api_updating';
  l_fct_ret	boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (
	p_api_hook_id is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (
	p_api_hook_id = g_old_rec.api_hook_id
       ) Then
      hr_utility.set_location(l_proc, 10);
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
      Fetch C_Sel1 Into g_old_rec;
      If C_Sel1%notfound Then
        Close C_Sel1;
        --
        -- The primary key is invalid therefore we must error
        --
        hr_utility.set_message(801, 'HR_7220_INVALID_PRIMARY_KEY');
        hr_utility.raise_error;
      End If;
      Close C_Sel1;
      --
      hr_utility.set_location(l_proc, 15);
      l_fct_ret := true;
    End If;
  End If;
  hr_utility.set_location(' Leaving:'||l_proc, 20);
  Return (l_fct_ret);
--
End api_updating;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< lck >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure lck
  (
  p_api_hook_id                        in number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select 	api_hook_id,
	api_module_id,
	api_hook_type,
	hook_package,
	hook_procedure,
	legislation_code,
	legislation_package,
	legislation_function,
	encoded_error
    from	hr_api_hooks
    where	api_hook_id = p_api_hook_id
    for	update nowait;
--
  l_proc	varchar2(72) := g_package||'lck';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Add any mandatory argument checking here:
  -- Example:
  -- hr_api.mandatory_arg_error
  --   (p_api_name       => l_proc,
  --    p_argument       => 'object_version_number',
  --    p_argument_value => p_object_version_number);
  --
  Open  C_Sel1;
  Fetch C_Sel1 Into g_old_rec;
  If C_Sel1%notfound then
    Close C_Sel1;
    --
    -- The primary key is invalid therefore we must error
    --
    hr_utility.set_message(800, 'HR_7220_INVALID_PRIMARY_KEY');
    hr_utility.raise_error;
  End If;
  Close C_Sel1;
  --
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
    hr_utility.set_message(801, 'HR_7165_OBJECT_LOCKED');
    hr_utility.set_message_token('TABLE_NAME', 'hr_api_hooks');
    hr_utility.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
	(
	p_api_hook_id                   in number,
	p_api_module_id                 in number,
	p_api_hook_type                 in varchar2,
	p_hook_package                  in varchar2,
	p_hook_procedure                in varchar2,
	p_legislation_code              in varchar2,
	p_legislation_package           in varchar2,
	p_legislation_function          in varchar2,
        p_encoded_error                 in varchar2
	)
	Return g_rec_type is
--
  l_rec	  g_rec_type;
  l_proc  varchar2(72) := g_package||'convert_args';
--
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Convert arguments into local l_rec structure.
  --
  --   mjh_webform.h3heading_createdefault('conv_arg: pkey = '||p_api_hook_id);
  l_rec.api_hook_id                      := p_api_hook_id;
  l_rec.api_module_id                    := p_api_module_id;
  l_rec.api_hook_type                    := p_api_hook_type;
  l_rec.hook_package                     := p_hook_package;
  l_rec.hook_procedure                   := p_hook_procedure;
  l_rec.legislation_code                 := p_legislation_code;
  l_rec.legislation_package              := p_legislation_package;
  l_rec.legislation_function             := p_legislation_function;
  l_rec.encoded_error                    := p_encoded_error;
  --
  -- Return the plsql record structure.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  Return(l_rec);
--
End convert_args;
--
end hr_ahk_shd;

/
