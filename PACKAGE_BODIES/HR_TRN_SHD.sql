--------------------------------------------------------
--  DDL for Package Body HR_TRN_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_TRN_SHD" as
/* $Header: hrtrnrhi.pkb 120.2 2005/09/21 04:59:16 hpandya noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  hr_trn_shd.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------------------------< return_api_dml_status >-------------------------|
-- ----------------------------------------------------------------------------
Function return_api_dml_status Return Boolean Is
--
  l_proc    varchar2(72) := g_package||'return_api_dml_status';
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
  l_proc    varchar2(72) := g_package||'constraint_error';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (p_constraint_name = 'CHK_TRANSACTION_PRIVILEGE') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','5');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'HR_API_TRANSACTIONS_PK') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','10');
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
  p_transaction_id                     in number
  )      Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select transaction_id,
    creator_person_id,
    transaction_privilege,
    product_code,
    url,
    status,
    transaction_state,  --ns
    section_display_name,
    function_id,
    transaction_ref_table,
    transaction_ref_id,
    transaction_type,
    assignment_id,
    api_addtnl_info,
    selected_person_id,
    item_type,
    item_key,
    transaction_effective_date,
    process_name,
    plan_id ,
    rptg_grp_id,
    effective_date_option,
    creator_role,
    last_update_role,
    parent_transaction_id,
    relaunch_function,
    transaction_group,
    transaction_identifier,
    transaction_document
    from    hr_api_transactions
    where   transaction_id = p_transaction_id;
  --
  -- plan_id, rptg_grp_id, effective_date_option added by sanej
--
  l_proc    varchar2(72)    := g_package||'api_updating';
  l_fct_ret boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (
    p_transaction_id is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (
    p_transaction_id = g_old_rec.transaction_id
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
  p_transaction_id                     in number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select  transaction_id,
    creator_person_id,
    transaction_privilege,
    product_code,
    url,
    status,
    transaction_state, --ns
    section_display_name,
    function_id,
    transaction_ref_table,
    transaction_ref_id,
    transaction_type,
    assignment_id,
    api_addtnl_info,
    selected_person_id,
    item_type,
    item_key,
    transaction_effective_date,
    process_name,
    plan_id ,
    rptg_grp_id,
    effective_date_option,
    creator_role,
    last_update_role,
    parent_transaction_id,
    relaunch_function,
    transaction_group,
    transaction_identifier,
    transaction_document
    from    hr_api_transactions
    where   transaction_id = p_transaction_id
    for update nowait;
  --
  -- plan_id, rptg_grp_id, effective_date_option added by sanej
--
  l_proc    varchar2(72) := g_package||'lck';
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
    hr_utility.set_message_token('TABLE_NAME', 'hr_api_transactions');
    hr_utility.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
    (
    p_transaction_id                in number,
    p_creator_person_id             in number,
    p_transaction_privilege         in varchar2
    )
    Return g_rec_type is
--
  l_rec   g_rec_type;
  l_proc  varchar2(72) := g_package||'convert_args';
--
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Convert arguments into local l_rec structure.
  --

   hr_utility.trace(' Start convert_args ');

  l_rec.transaction_id                   := p_transaction_id;
  l_rec.creator_person_id                := p_creator_person_id;
  l_rec.transaction_privilege            := p_transaction_privilege;
  --
  -- Return the plsql record structure.
  --

    hr_utility.trace(' End convert_args ');

  hr_utility.set_location(' Leaving:'||l_proc, 10);
  Return(l_rec);
--
End convert_args;
--
Function convert_args
    (
    p_transaction_id                in number,
    p_creator_person_id             in number,
    p_transaction_privilege         in varchar2,
    p_product_code                    in varchar2,
    p_url                           in varchar2,
    p_status                        in varchar2,
    p_transaction_state             in varchar2, --ns
    p_section_display_name           in varchar2,
    p_function_id                   in number,
    p_transaction_ref_table         in varchar2,
    p_transaction_ref_id            in number,
    p_transaction_type              in varchar2,
    p_assignment_id                 in number,
    p_api_addtnl_info               in varchar2,
    p_selected_person_id            in number,
    p_item_type                     in varchar2,
    p_item_key                      in varchar2,
    p_transaction_effective_date    in date,
    p_process_name                  in varchar2,
    p_plan_id                      in number,
    p_rptg_grp_id                  in number,
    p_effective_date_option        in varchar2,
    p_creator_role                 in varchar2,
    p_last_update_role             in varchar2,
    p_parent_transaction_id        in number,
    p_relaunch_function            in varchar2,
    p_transaction_group            in varchar2,
    p_transaction_identifier       in varchar2,
    p_transaction_document         in clob

    )
    Return g_rec_type is
--
-- p_plan_id, p_rptg_grp_id, p_effective_date_option added by sanej
--
  l_rec   g_rec_type;
  l_proc  varchar2(72) := g_package||'convert_args';
--
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Convert arguments into local l_rec structure.
  --

  l_rec.transaction_id                   := p_transaction_id;
  l_rec.creator_person_id                := p_creator_person_id;
  l_rec.transaction_privilege            := p_transaction_privilege;
  l_rec.product_code                     := p_product_code;
  l_rec.url                              := p_url;
  l_rec.status                           := p_status;
  l_rec.transaction_state                := p_transaction_state;  --ns
  l_rec.section_display_name             := p_section_display_name;
  l_rec.function_id                      := p_function_id;
  l_rec.transaction_ref_table            := p_transaction_ref_table;
  l_rec.transaction_ref_id               := p_transaction_ref_id;
  l_rec.transaction_type                 := p_transaction_type;
  l_rec.assignment_id                    := p_assignment_id;
  l_rec.api_addtnl_info                  := p_api_addtnl_info;
  l_rec.selected_person_id               := p_selected_person_id;
  l_rec.item_type                        := p_item_type;
  l_rec.Item_key                         := p_item_key;
  l_rec.transaction_effective_date       := p_transaction_effective_date;
  l_rec.process_name                     := p_process_name;
  l_rec.plan_id                          := p_plan_id ;
  l_rec.rptg_grp_id                      := p_rptg_grp_id ;
  l_rec.effective_date_option            := p_effective_date_option ;
  l_rec.creator_role                     := p_creator_role;
  l_rec.last_update_role                 := p_last_update_role;
  l_rec.parent_transaction_id            := p_parent_transaction_id;
  l_rec.relaunch_function                := p_relaunch_function;
  l_rec.transaction_group                := p_transaction_group;
  l_rec.transaction_identifier           := p_transaction_identifier;
  l_rec.transaction_document             := p_transaction_document;
  --
  -- plan_id, rptg_grp_id, effective_date_option added by sanej

  --
  -- Return the plsql record structure.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  Return(l_rec);
--
End convert_args;

end hr_trn_shd;

/
