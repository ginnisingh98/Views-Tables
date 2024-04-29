--------------------------------------------------------
--  DDL for Package Body PQH_CET_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_CET_SHD" as
/* $Header: pqcetrhi.pkb 120.2 2005/10/01 10:56:44 scnair noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pqh_cet_shd.';  -- Global package name
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
  If (p_constraint_name = 'PQH_COPY_ENTITY_TXNS_FK1') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','5');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'PQH_COPY_ENTITY_TXNS_FK2') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','10');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'PQH_COPY_ENTITY_TXNS_PK') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','15');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'PQH_COMPLETED_TARGET') Then
    hr_utility.set_message(8302, 'PQH_COMPLETED_TARGET');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'PQH_COPY_ENTITY_TXNS_UK') Then
    hr_utility.set_message(8302, 'PQH_GEN_UNQUE_NAME');
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
  p_copy_entity_txn_id                 in number,
  p_object_version_number              in number
  )      Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
		copy_entity_txn_id,
	transaction_category_id,
	txn_category_attribute_id,
	context_business_group_id,
	datetrack_mode,
	context         ,
        action_date ,
        src_effective_date,
	number_of_copies,
	display_name,
	replacement_type_cd,
	start_with,
	increment_by,
	status,
	object_version_number
    from	pqh_copy_entity_txns
    where	copy_entity_txn_id = p_copy_entity_txn_id;
--
  l_proc	varchar2(72)	:= g_package||'api_updating';
  l_fct_ret	boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (
	p_copy_entity_txn_id is null and
	p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (
	p_copy_entity_txn_id = g_old_rec.copy_entity_txn_id and
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
  p_copy_entity_txn_id                 in number,
  p_object_version_number              in number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select 	copy_entity_txn_id,
	transaction_category_id,
	txn_category_attribute_id,
	context_business_group_id,
	datetrack_mode,
	context         ,
        action_date ,
        src_effective_date,
	number_of_copies ,
	display_name,
	replacement_type_cd,
	start_with,
	increment_by,
	status,
	object_version_number
    from	pqh_copy_entity_txns
    where	copy_entity_txn_id = p_copy_entity_txn_id
    for	update nowait;
--
  l_proc	varchar2(72) := g_package||'lck';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Add any mandatory argument checking here:
  -- Example:
   hr_api.mandatory_arg_error
     (p_api_name       => l_proc,
      p_argument       => 'object_version_number',
      p_argument_value => p_object_version_number);
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
    hr_utility.set_message_token('TABLE_NAME', 'pqh_copy_entity_txns');
    hr_utility.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
	(
	p_copy_entity_txn_id            in number,
	p_transaction_category_id       in number,
	p_txn_category_attribute_id     in number,
     p_context_business_group_id      in  number,
     p_datetrack_mode                 in  varchar2,
	p_context                       in varchar2,
        p_action_date                   in date,
        p_src_effective_date            in date,
	p_number_of_copies              in number,
	p_display_name                  in varchar2,
	p_replacement_type_cd           in varchar2,
	p_start_with                    in varchar2,
	p_increment_by                  in number,
	p_status                        in varchar2,
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
  l_rec.copy_entity_txn_id               := p_copy_entity_txn_id;
  l_rec.transaction_category_id          := p_transaction_category_id;
  l_rec.txn_category_attribute_id        := p_txn_category_attribute_id;
  l_rec.context_business_group_id        := p_context_business_group_id;
  l_rec.datetrack_mode                   := p_datetrack_mode;
  l_rec.context                          := p_context         ;
  l_rec.action_date                      := p_action_date ;
  l_rec.src_effective_date               := p_src_effective_date ;
  l_rec.number_of_copies                 := p_number_of_copies ;
  l_rec.display_name                     := p_display_name;
  l_rec.replacement_type_cd              := p_replacement_type_cd;
  l_rec.start_with                       := p_start_with;
  l_rec.increment_by                     := p_increment_by;
  l_rec.status                           := p_status;
  l_rec.object_version_number            := p_object_version_number;
  --
  -- Return the plsql record structure.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  Return(l_rec);
--
End convert_args;
--
end pqh_cet_shd;

/
