--------------------------------------------------------
--  DDL for Package Body PQH_WDT_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_WDT_SHD" as
/* $Header: pqwdtrhi.pkb 120.0.12000000.1 2007/01/17 00:29:46 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pqh_wdt_shd.';  -- Global package name
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
  If (p_constraint_name = 'PQH_WORKSHEET_DETAILS_FK2') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','5');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'PQH_WORKSHEET_DETAILS_FK3') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','10');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'PQH_WORKSHEET_DETAILS_FK4') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','15');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'PQH_WORKSHEET_DETAILS_FK5') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','20');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'PQH_WORKSHEET_DETAILS_FK6') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','25');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'PQH_WORKSHEET_DETAILS_FK7') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','30');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'PQH_WORKSHEET_DETAILS_FK8') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','35');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'PQH_WORKSHEET_DETAILS_PK') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','40');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'PQH_WORKSHEET_DETAILS_UK') Then
    --
    -- Code Changed to provide a more meaningful message on
    -- unique constraint failure.
    --
    hr_utility.set_message(8302, 'PQH_DUPLICATE_WORKSHEET_DETAIL');
    hr_utility.raise_error;
    /**
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','45');
    hr_utility.raise_error;
    **/
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
  p_worksheet_detail_id                in number,
  p_object_version_number              in number
  )      Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
		worksheet_detail_id,
	worksheet_id,
	organization_id,
	job_id,
	position_id,
	grade_id,
	position_transaction_id,
	budget_detail_id,
	parent_worksheet_detail_id,
	user_id,
	action_cd,
	budget_unit1_percent,
	budget_unit1_value,
	budget_unit2_percent,
	budget_unit2_value,
	budget_unit3_percent,
	budget_unit3_value,
	object_version_number,
	budget_unit1_value_type_cd,
	budget_unit2_value_type_cd,
	budget_unit3_value_type_cd,
	status,
	budget_unit1_available,
	budget_unit2_available,
	budget_unit3_available,
	old_unit1_value,
	old_unit2_value,
	old_unit3_value,
	defer_flag,
	propagation_method
    from	pqh_worksheet_details
    where	worksheet_detail_id = p_worksheet_detail_id;
--
  l_proc	varchar2(72)	:= g_package||'api_updating';
  l_fct_ret	boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (
	p_worksheet_detail_id is null and
	p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (
	p_worksheet_detail_id = g_old_rec.worksheet_detail_id and
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
  p_worksheet_detail_id                in number,
  p_object_version_number              in number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select 	worksheet_detail_id,
	worksheet_id,
	organization_id,
	job_id,
	position_id,
	grade_id,
	position_transaction_id,
	budget_detail_id,
	parent_worksheet_detail_id,
	user_id,
	action_cd,
	budget_unit1_percent,
	budget_unit1_value,
	budget_unit2_percent,
	budget_unit2_value,
	budget_unit3_percent,
	budget_unit3_value,
	object_version_number,
	budget_unit1_value_type_cd,
	budget_unit2_value_type_cd,
	budget_unit3_value_type_cd,
	status,
	budget_unit1_available,
	budget_unit2_available,
	budget_unit3_available,
	old_unit1_value,
	old_unit2_value,
	old_unit3_value,
	defer_flag,
	propagation_method
    from	pqh_worksheet_details
    where	worksheet_detail_id = p_worksheet_detail_id
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
    hr_utility.set_message_token('TABLE_NAME', 'pqh_worksheet_details');
    hr_utility.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
	(
	p_worksheet_detail_id           in number,
	p_worksheet_id                  in number,
	p_organization_id               in number,
	p_job_id                        in number,
	p_position_id                   in number,
	p_grade_id                      in number,
	p_position_transaction_id       in number,
	p_budget_detail_id              in number,
	p_parent_worksheet_detail_id    in number,
	p_user_id                       in number,
	p_action_cd                     in varchar2,
	p_budget_unit1_percent          in number,
	p_budget_unit1_value            in number,
	p_budget_unit2_percent          in number,
	p_budget_unit2_value            in number,
	p_budget_unit3_percent          in number,
	p_budget_unit3_value            in number,
	p_object_version_number         in number,
	p_budget_unit1_value_type_cd    in varchar2,
	p_budget_unit2_value_type_cd    in varchar2,
	p_budget_unit3_value_type_cd    in varchar2,
	p_status                        in varchar2,
	p_budget_unit1_available        in number,
	p_budget_unit2_available        in number,
	p_budget_unit3_available        in number,
	p_old_unit1_value               in number,
	p_old_unit2_value               in number,
	p_old_unit3_value               in number,
	p_defer_flag                    in varchar2,
	p_propagation_method            in varchar2
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
  l_rec.worksheet_detail_id              := p_worksheet_detail_id;
  l_rec.worksheet_id                     := p_worksheet_id;
  l_rec.organization_id                  := p_organization_id;
  l_rec.job_id                           := p_job_id;
  l_rec.position_id                      := p_position_id;
  l_rec.grade_id                         := p_grade_id;
  l_rec.position_transaction_id          := p_position_transaction_id;
  l_rec.budget_detail_id                 := p_budget_detail_id;
  l_rec.parent_worksheet_detail_id       := p_parent_worksheet_detail_id;
  l_rec.user_id                          := p_user_id;
  l_rec.action_cd                        := p_action_cd;
  l_rec.budget_unit1_percent             := p_budget_unit1_percent;
  l_rec.budget_unit1_value               := p_budget_unit1_value;
  l_rec.budget_unit2_percent             := p_budget_unit2_percent;
  l_rec.budget_unit2_value               := p_budget_unit2_value;
  l_rec.budget_unit3_percent             := p_budget_unit3_percent;
  l_rec.budget_unit3_value               := p_budget_unit3_value;
  l_rec.object_version_number            := p_object_version_number;
  l_rec.budget_unit1_value_type_cd       := p_budget_unit1_value_type_cd;
  l_rec.budget_unit2_value_type_cd       := p_budget_unit2_value_type_cd;
  l_rec.budget_unit3_value_type_cd       := p_budget_unit3_value_type_cd;
  l_rec.status                           := p_status;
  l_rec.budget_unit1_available           := p_budget_unit1_available;
  l_rec.budget_unit2_available           := p_budget_unit2_available;
  l_rec.budget_unit3_available           := p_budget_unit3_available;
  l_rec.old_unit1_value                  := p_old_unit1_value;
  l_rec.old_unit2_value                  := p_old_unit2_value;
  l_rec.old_unit3_value                  := p_old_unit3_value;
  l_rec.defer_flag                       := p_defer_flag;
  l_rec.propagation_method               := p_propagation_method;
  --
  -- Return the plsql record structure.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  Return(l_rec);
--
End convert_args;
--
end pqh_wdt_shd;

/
