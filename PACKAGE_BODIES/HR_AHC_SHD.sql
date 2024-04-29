--------------------------------------------------------
--  DDL for Package Body HR_AHC_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_AHC_SHD" as
/* $Header: hrahcrhi.pkb 115.7 2002/12/02 14:52:05 apholt ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  hr_ahc_shd.';  -- Global package name
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
  If (p_constraint_name = 'HR_API_HOOK_CALLS_CK1') Then
    hr_utility.set_message(800, 'PER_52135_AHC_HK_CALL_TYPE_INV');
    hr_utility.raise_error;

  ----------------------------------------------------------------------
  -- This constraint now has two error messages associated with it.
  -- These are called from the chk_sequence procedure and therefore this
  -- condition will never be called.
  ----------------------------------------------------------------------
  ElsIf (p_constraint_name = 'HR_API_HOOK_CALLS_CK2') Then
    hr_utility.set_message(800, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','10');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'HR_API_HOOK_CALLS_FK1') Then
    hr_utility.set_message(800, 'PER_52134_AHC_HOOK_ID_INV');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'HR_API_HOOK_CALLS_PK') Then
    hr_utility.set_message(800, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','20');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'HR_API_HOOK_CALLS_UK1') Then
    hr_utility.set_message(800, 'PER_52139_AHC_DUP_PROC_CALL');
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
  p_api_hook_call_id                   in number,
  p_object_version_number              in number
  )      Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
		api_hook_call_id,
	api_hook_id,
	api_hook_call_type,
	legislation_code,
	sequence,
	enabled_flag,
	call_package,
	call_procedure,
	pre_processor_date,
	encoded_error,
	status,
	object_version_number,
        application_id,
        app_install_status
    from	hr_api_hook_calls
    where	api_hook_call_id = p_api_hook_call_id;
--
  l_proc	varchar2(72)	:= g_package||'api_updating';
  l_fct_ret	boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (
	p_api_hook_call_id is null and
	p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (
	p_api_hook_call_id = g_old_rec.api_hook_call_id and
	p_object_version_number = g_old_rec.object_version_number
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
      If (p_object_version_number <> g_old_rec.object_version_number) Then
        hr_utility.set_message(801, 'HR_7155_OBJECT_INVALID');
        hr_utility.raise_error;
      End If;
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
  p_api_hook_call_id                   in number,
  p_object_version_number              in number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select 	api_hook_call_id,
	api_hook_id,
	api_hook_call_type,
	legislation_code,
	sequence,
	enabled_flag,
	call_package,
	call_procedure,
	pre_processor_date,
	encoded_error,
	status,
	object_version_number,
        application_id,
        app_install_status
    from	hr_api_hook_calls
    where	api_hook_call_id      = p_api_hook_call_id
    for	update nowait;
--
  l_proc	varchar2(72) := g_package||'lck';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Check that the object version number is set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'object_version_number'
    ,p_argument_value => p_object_version_number
    );
  --
  Open  C_Sel1;
  Fetch C_Sel1 Into g_old_rec;
  If C_Sel1%notfound then
    Close C_Sel1;
    --
    -- The primary key is invalid therefore we must error
    --
    hr_utility.set_message(801, 'HR_7220_INVALID_PRIMARY_KEY');
    hr_utility.raise_error;
  End If;
  Close C_Sel1;
  If (p_object_version_number <> g_old_rec.object_version_number) Then
        hr_utility.set_message(801, 'HR_7155_OBJECT_INVALID');
        hr_utility.raise_error;
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
    hr_utility.set_message(801, 'HR_7165_OBJECT_LOCKED');
    hr_utility.set_message_token('TABLE_NAME', 'hr_api_hook_calls');
    hr_utility.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
	(
	p_api_hook_call_id              in number,
	p_api_hook_id                   in number,
	p_api_hook_call_type            in varchar2,
	p_legislation_code              in varchar2,
	p_sequence                      in number,
	p_enabled_flag                  in varchar2,
	p_call_package                  in varchar2,
	p_call_procedure                in varchar2,
	p_pre_processor_date            in date,
	p_encoded_error                 in varchar2,
	p_status                        in varchar2,
	p_object_version_number         in number,
        p_application_id                in number,
        p_app_install_status            in varchar2
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
  l_rec.api_hook_call_id                 := p_api_hook_call_id;
  l_rec.api_hook_id                      := p_api_hook_id;
  l_rec.api_hook_call_type               := p_api_hook_call_type;
  l_rec.legislation_code                 := p_legislation_code;
  l_rec.sequence                         := p_sequence;
  l_rec.enabled_flag                     := p_enabled_flag;
  l_rec.call_package                     := p_call_package;
  l_rec.call_procedure                   := p_call_procedure;
  l_rec.pre_processor_date               := p_pre_processor_date;
  l_rec.encoded_error                    := p_encoded_error;
  l_rec.status                           := p_status;
  l_rec.object_version_number            := p_object_version_number;
  l_rec.application_id                   := p_application_id;
  l_rec.app_install_status               := p_app_install_status;
  --
  -- Return the plsql record structure.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  Return(l_rec);
--
End convert_args;
--
end hr_ahc_shd;

/
