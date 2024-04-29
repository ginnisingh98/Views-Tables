--------------------------------------------------------
--  DDL for Package Body PQH_BST_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_BST_SHD" as
/* $Header: pqbstrhi.pkb 115.7 2002/12/05 19:30:15 rpasapul ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pqh_bst_shd.';  -- Global package name
--
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
  If (p_constraint_name = 'PQH_BUDGET_SETS_FK1') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','5');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'PQH_BUDGET_SETS_FK2') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','10');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'PQH_BUDGET_SETS_PK') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','15');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'PQH_BUDGET_SETS_UK') Then
    hr_utility.set_message(8302, 'PQH_DUPLICATE_BUDGET_SET_NAME');
    hr_utility.raise_error;
  Else
    hr_utility.set_message(801, 'HR_7877_API_INVALID_CONSTRAINT');
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
  p_budget_set_id                      in number,
  p_object_version_number              in number
  )      Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
		budget_set_id,
	dflt_budget_set_id,
	budget_period_id,
	budget_unit1_percent,
	budget_unit2_percent,
	budget_unit3_percent,
	budget_unit1_value,
	budget_unit2_value,
	budget_unit3_value,
	budget_unit1_available,
	budget_unit2_available,
	budget_unit3_available,
	object_version_number,
	budget_unit1_value_type_cd,
	budget_unit2_value_type_cd,
	budget_unit3_value_type_cd
    from	pqh_budget_sets
    where	budget_set_id = p_budget_set_id;
--
  l_proc	varchar2(72)	:= g_package||'api_updating';
  l_fct_ret	boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (
	p_budget_set_id is null and
	p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (
	p_budget_set_id = g_old_rec.budget_set_id and
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
  p_budget_set_id                      in number,
  p_object_version_number              in number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select 	budget_set_id,
	dflt_budget_set_id,
	budget_period_id,
	budget_unit1_percent,
	budget_unit2_percent,
	budget_unit3_percent,
	budget_unit1_value,
	budget_unit2_value,
	budget_unit3_value,
	budget_unit1_available,
	budget_unit2_available,
	budget_unit3_available,
	object_version_number,
	budget_unit1_value_type_cd,
	budget_unit2_value_type_cd,
	budget_unit3_value_type_cd
    from	pqh_budget_sets
    where	budget_set_id = p_budget_set_id
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
    hr_utility.set_message_token('TABLE_NAME', 'pqh_budget_sets');
    hr_utility.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
	(
	p_budget_set_id                 in number,
	p_dflt_budget_set_id            in number,
	p_budget_period_id              in number,
	p_budget_unit1_percent          in number,
	p_budget_unit2_percent          in number,
	p_budget_unit3_percent          in number,
	p_budget_unit1_value            in number,
	p_budget_unit2_value            in number,
	p_budget_unit3_value            in number,
	p_budget_unit1_available         in number,
	p_budget_unit2_available         in number,
	p_budget_unit3_available         in number,
	p_object_version_number         in number,
	p_budget_unit1_value_type_cd    in varchar2,
	p_budget_unit2_value_type_cd    in varchar2,
	p_budget_unit3_value_type_cd    in varchar2
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
  l_rec.budget_set_id                    := p_budget_set_id;
  l_rec.dflt_budget_set_id               := p_dflt_budget_set_id;
  l_rec.budget_period_id                 := p_budget_period_id;
  l_rec.budget_unit1_percent             := p_budget_unit1_percent;
  l_rec.budget_unit2_percent             := p_budget_unit2_percent;
  l_rec.budget_unit3_percent             := p_budget_unit3_percent;
  l_rec.budget_unit1_value               := p_budget_unit1_value;
  l_rec.budget_unit2_value               := p_budget_unit2_value;
  l_rec.budget_unit3_value               := p_budget_unit3_value;
  l_rec.budget_unit1_available            := p_budget_unit1_available;
  l_rec.budget_unit2_available            := p_budget_unit2_available;
  l_rec.budget_unit3_available            := p_budget_unit3_available;
  l_rec.object_version_number            := p_object_version_number;
  l_rec.budget_unit1_value_type_cd       := p_budget_unit1_value_type_cd;
  l_rec.budget_unit2_value_type_cd       := p_budget_unit2_value_type_cd;
  l_rec.budget_unit3_value_type_cd       := p_budget_unit3_value_type_cd;
  --
  -- Return the plsql record structure.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  Return(l_rec);
--
End convert_args;
--
end pqh_bst_shd;

/
