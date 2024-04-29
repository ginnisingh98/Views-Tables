--------------------------------------------------------
--  DDL for Package Body HR_PAB_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_PAB_SHD" as
/* $Header: hrpabrhi.pkb 115.1 99/07/17 05:36:11 porting ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  hr_pab_shd.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------------------------< return_api_dml_status >-------------------------|
-- ----------------------------------------------------------------------------
Function return_api_dml_status Return Boolean Is
--
  l_proc 	varchar2(72) := g_package||'return_api_dml_status';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  Return (nvl(g_api_dml, false));
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End return_api_dml_status;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< constraint_error >---------------------------|
-- ----------------------------------------------------------------------------
Procedure constraint_error
            (p_constraint_name in all_constraints.constraint_name%TYPE) Is
--
  l_proc 	varchar2(72) := g_package||'constraint_error';
--
     -- *** NEW_MESSAGE_REQUIRED ***
     -- Following messages must be moved from SSP to PAY
     --
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (p_constraint_name = 'HR_PAB_PK') Then
    FND_MESSAGE.SET_NAME('PAY', 'HR_51022_HR_INV_PRIMARY_KEY');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'HR_PAB_POSITIVE_MULTIPLIER') Then
    FND_MESSAGE.SET_NAME('PAY','HR_51024_HR_MULTIP');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'HR_PAB_UK01') Then
    FND_MESSAGE.SET_NAME('PAY','HR_51023_HR_PATT_BIT');
    fnd_message.raise_error;
  Else
    fnd_message.set_name('PAY', 'HR_7877_API_INVALID_CONSTRAINT');
    fnd_message.set_token('PROCEDURE',l_proc);
    fnd_message.set_token('CONSTRAINT_NAME',p_constraint_name);
    fnd_message.raise_error;
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
  p_pattern_bit_id                     in number,
  p_object_version_number              in number
  )      Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
		pattern_bit_id,
	pattern_bit_code,
	bit_meaning,
	time_unit_multiplier,
	base_time_unit,
	object_version_number
    from	hr_pattern_bits
    where	pattern_bit_id = p_pattern_bit_id;
--
  l_proc	varchar2(72)	:= g_package||'api_updating';
  l_fct_ret	boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (
	p_pattern_bit_id is null and
	p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (
	p_pattern_bit_id = g_old_rec.pattern_bit_id and
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
        FND_MESSAGE.SET_NAME('PAY', 'HR_51022_HR_INV_PRIMARY_KEY');
        fnd_message.raise_error;
      End If;
      Close C_Sel1;
      If (p_object_version_number <> g_old_rec.object_version_number) Then
        FND_MESSAGE.SET_NAME('PAY', 'HR_51026_HR_LOCKED_OBJ');
        fnd_message.raise_error;
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
  p_pattern_bit_id                     in number,
  p_object_version_number              in number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select 	pattern_bit_id,
	pattern_bit_code,
	bit_meaning,
	time_unit_multiplier,
	base_time_unit,
	object_version_number
    from	hr_pattern_bits
    where	pattern_bit_id = p_pattern_bit_id
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
    FND_MESSAGE.SET_NAME('PAY', 'HR_51022_HR_INV_PRIMARY_KEY');
    fnd_message.raise_error;
  End If;
  Close C_Sel1;
  If (p_object_version_number <> g_old_rec.object_version_number) Then
        FND_MESSAGE.SET_NAME('PAY', 'HR_51027_HR_INV_OBJ');
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
    FND_MESSAGE.SET_NAME('PAY', 'HR_51026_HR_LOCKED_OBJ');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
	(
	p_pattern_bit_id                in number,
	p_pattern_bit_code              in varchar2,
	p_bit_meaning                   in varchar2,
	p_time_unit_multiplier          in number,
	p_base_time_unit                in varchar2,
	p_object_version_number         in number
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
  l_rec.pattern_bit_id                   := p_pattern_bit_id;
  l_rec.pattern_bit_code                 := p_pattern_bit_code;
  l_rec.bit_meaning                      := p_bit_meaning;
  l_rec.time_unit_multiplier             := p_time_unit_multiplier;
  l_rec.base_time_unit                   := p_base_time_unit;
  l_rec.object_version_number            := p_object_version_number;
  --
  -- Return the plsql record structure.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  Return(l_rec);
--
End convert_args;
--
end hr_pab_shd;

/
