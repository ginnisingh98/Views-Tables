--------------------------------------------------------
--  DDL for Package Body PQH_BGT_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_BGT_SHD" as
/* $Header: pqbgtrhi.pkb 120.1 2005/09/21 03:11:10 hmehta noship $ */
--
-- ---------------------------------------------------------------------------+
-- |                     Private Global Definitions                           |
-- ---------------------------------------------------------------------------+
--
g_package  varchar2(33)	:= '  pqh_bgt_shd.';  -- Global package name
--
--
-- ---------------------------------------------------------------------------+
-- |---------------------------< constraint_error >---------------------------|
-- ---------------------------------------------------------------------------+
Procedure constraint_error
            (p_constraint_name in all_constraints.constraint_name%TYPE) Is
--
  l_proc 	varchar2(72) := g_package||'constraint_error';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (p_constraint_name = 'AVCON_21709591_TRANS_000') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','5');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'PQH_BUDGETS_FK1') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','10');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'PQH_BUDGETS_FK2') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','15');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'PQH_BUDGETS_FK3') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','20');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'PQH_BUDGETS_FK4') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','25');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'PQH_BUDGETS_FK5') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','30');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'PQH_BUDGETS_PK') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','35');
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
-- ----------------------------------------------------------------------------+
-- |-----------------------------< api_updating >-----------------------------|
-- ----------------------------------------------------------------------------+
Function api_updating
  (
  p_budget_id                          in number,
  p_object_version_number              in number
  )      Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
		budget_id,
	business_group_id,
	start_organization_id,
	org_structure_version_id,
	budgeted_entity_cd,
	budget_style_cd,
	budget_name,
	period_set_name,
	budget_start_date,
	budget_end_date,
        gl_budget_name,
        psb_budget_flag,
	transfer_to_gl_flag,
	transfer_to_grants_flag,
	status,
	object_version_number,
	budget_unit1_id,
	budget_unit2_id,
	budget_unit3_id,
	gl_set_of_books_id,
        budget_unit1_aggregate,
        budget_unit2_aggregate,
        budget_unit3_aggregate,
        position_control_flag ,
        valid_grade_reqd_flag ,
        currency_code,
        dflt_budget_set_id
    from	pqh_budgets
    where	budget_id = p_budget_id;
--
  l_proc	varchar2(72)	:= g_package||'api_updating';
  l_fct_ret	boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (
	p_budget_id is null and
	p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (
	p_budget_id = g_old_rec.budget_id and
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
-- ----------------------------------------------------------------------------+
-- |---------------------------------< lck >----------------------------------|
-- ----------------------------------------------------------------------------+
Procedure lck
  (
  p_budget_id                          in number,
  p_object_version_number              in number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select 	budget_id,
	business_group_id,
	start_organization_id,
	org_structure_version_id,
	budgeted_entity_cd,
	budget_style_cd,
	budget_name,
	period_set_name,
	budget_start_date,
	budget_end_date,
        gl_budget_name,
        psb_budget_flag,
	transfer_to_gl_flag,
	transfer_to_grants_flag,
	status,
	object_version_number,
	budget_unit1_id,
	budget_unit2_id,
	budget_unit3_id,
	gl_set_of_books_id,
        budget_unit1_aggregate,
        budget_unit2_aggregate,
        budget_unit3_aggregate,
        position_control_flag ,
        valid_grade_reqd_flag ,
        currency_code,
        dflt_budget_set_id
    from	pqh_budgets
    where	budget_id = p_budget_id
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
    hr_utility.set_message_token('TABLE_NAME', 'pqh_budgets');
    hr_utility.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------+
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------+
Function convert_args
	(
	p_budget_id                     in number,
	p_business_group_id             in number,
	p_start_organization_id         in number,
	p_org_structure_version_id      in number,
	p_budgeted_entity_cd            in varchar2,
	p_budget_style_cd               in varchar2,
	p_budget_name                   in varchar2,
	p_period_set_name               in varchar2,
	p_budget_start_date             in date,
	p_budget_end_date               in date,
        p_gl_budget_name                in varchar2,
        p_psb_budget_flag               in varchar2,
	p_transfer_to_gl_flag           in varchar2,
	p_transfer_to_grants_flag       in varchar2,
	p_status                        in varchar2,
	p_object_version_number         in number,
	p_budget_unit1_id               in number,
	p_budget_unit2_id               in number,
	p_budget_unit3_id               in number,
	p_gl_set_of_books_id            in number,
        p_budget_unit1_aggregate        in varchar2,
        p_budget_unit2_aggregate        in varchar2,
        p_budget_unit3_aggregate        in varchar2,
        p_position_control_flag         in varchar2,
        p_valid_grade_reqd_flag         in varchar2,
        p_currency_code                 in varchar2,
        p_dflt_budget_set_id            in number
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
  l_rec.budget_id                        := p_budget_id;
  l_rec.business_group_id                := p_business_group_id;
  l_rec.start_organization_id            := p_start_organization_id;
  l_rec.org_structure_version_id         := p_org_structure_version_id;
  l_rec.budgeted_entity_cd               := p_budgeted_entity_cd;
  l_rec.budget_style_cd                  := p_budget_style_cd;
  l_rec.budget_name                      := p_budget_name;
  l_rec.period_set_name                  := p_period_set_name;
  l_rec.budget_start_date                := p_budget_start_date;
  l_rec.budget_end_date                  := p_budget_end_date;
  l_rec.gl_budget_name                   := p_gl_budget_name;
  l_rec.psb_budget_flag                  := p_psb_budget_flag;
  l_rec.transfer_to_gl_flag              := p_transfer_to_gl_flag;
  l_rec.transfer_to_grants_flag          := p_transfer_to_grants_flag;
  l_rec.status                           := p_status;
  l_rec.object_version_number            := p_object_version_number;
  l_rec.budget_unit1_id                  := p_budget_unit1_id;
  l_rec.budget_unit2_id                  := p_budget_unit2_id;
  l_rec.budget_unit3_id                  := p_budget_unit3_id;
  l_rec.gl_set_of_books_id               := p_gl_set_of_books_id;
  l_rec.budget_unit1_aggregate           := p_budget_unit1_aggregate;
  l_rec.budget_unit2_aggregate           := p_budget_unit2_aggregate;
  l_rec.budget_unit3_aggregate           := p_budget_unit3_aggregate;
  l_rec.position_control_flag            := p_position_control_flag;
  l_rec.valid_grade_reqd_flag            := p_valid_grade_reqd_flag     ;
  l_rec.currency_code                    := p_currency_code;
  l_rec.dflt_budget_set_id               := p_dflt_budget_set_id;
  --
  -- Return the plsql record structure.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  Return(l_rec);
--
End convert_args;
--
end pqh_bgt_shd;

/
