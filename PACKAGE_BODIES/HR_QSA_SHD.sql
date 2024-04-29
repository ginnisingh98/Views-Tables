--------------------------------------------------------
--  DDL for Package Body HR_QSA_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_QSA_SHD" as
/* $Header: hrqsarhi.pkb 115.12 2003/08/27 00:16:05 hpandya ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)  := '  hr_qsa_shd.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |---------------------------< constraint_error >---------------------------|
-- ----------------------------------------------------------------------------
Procedure constraint_error
            (p_constraint_name in all_constraints.constraint_name%TYPE) Is
--
  l_proc   varchar2(72) := g_package||'constraint_error';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (p_constraint_name = 'HR_QUEST_ANSWERS_FK1') Then
    fnd_message.set_name('PER', 'PER_52427_QSA_QU_TMPLT_INVALID');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'HR_QUEST_ANSWERS_FK2') Then
    fnd_message.set_name('PER', 'PER_52428_QSA_INVAL_BUS_GRP');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'HR_QUEST_ANSWERS_PK') Then
    -- leave, as unlikely to occur
    fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE',l_proc);
    fnd_message.set_token('STEP','20');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'HR_QUEST_ANSWERS_UK1') Then
    fnd_message.set_name('PER', 'PER_52441_NON_UNIQUE_TYPE');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'HR_QUEST_ANS_TYPE_CHK') Then
    fnd_message.set_name('PER', 'PER_52429_QSA_INVAL_ANS_TYPE');
    fnd_message.raise_error;
  Else
    hr_utility.set_message('PER', 'HR_7877_API_INVALID_CONSTRAINT');
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
  p_questionnaire_answer_id            in number
  )      Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
    questionnaire_answer_id,
  questionnaire_template_id,
  type,
  type_object_id,
  business_group_id
    from  hr_quest_answers
    where  questionnaire_answer_id = p_questionnaire_answer_id;
--
  l_proc  varchar2(72)  := g_package||'api_updating';
  l_fct_ret  boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (
  p_questionnaire_answer_id is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (
  p_questionnaire_answer_id = g_old_rec.questionnaire_answer_id
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
        hr_utility.set_message('PER', 'HR_7220_INVALID_PRIMARY_KEY');
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
  p_questionnaire_answer_id            in number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select   questionnaire_answer_id,
  questionnaire_template_id,
  type,
  type_object_id,
  business_group_id
    from  hr_quest_answers
    where  questionnaire_answer_id = p_questionnaire_answer_id
    for  update nowait;
--
  l_proc  varchar2(72) := g_package||'lck';
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
  hr_api.mandatory_arg_error
    (p_api_name => l_proc
    ,p_argument => 'questionnaire_answer_id'
    ,p_argument_value => p_questionnaire_answer_id);
  --
  Open  C_Sel1;
  Fetch C_Sel1 Into g_old_rec;
  If C_Sel1%notfound then
    Close C_Sel1;
    --
    -- The primary key is invalid therefore we must error
    --
    hr_utility.set_message('PER', 'HR_7220_INVALID_PRIMARY_KEY');
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
    hr_utility.set_message('PER', 'HR_7165_OBJECT_LOCKED');
    hr_utility.set_message_token('TABLE_NAME', 'hr_quest_answers');
    hr_utility.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
  (
  p_questionnaire_answer_id       in number,
  p_questionnaire_template_id     in number,
  p_type                          in varchar2,
  p_type_object_id                in number,
  p_business_group_id             in number
  )
  Return g_rec_type is
--
  l_rec    g_rec_type;
  l_proc  varchar2(72) := g_package||'convert_args';
--
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Convert arguments into local l_rec structure.
  --
  l_rec.questionnaire_answer_id          := p_questionnaire_answer_id;
  l_rec.questionnaire_template_id        := p_questionnaire_template_id;
  l_rec.type                             := p_type;
  l_rec.type_object_id                   := p_type_object_id;
  l_rec.business_group_id                := p_business_group_id;
  --
  -- Return the plsql record structure.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  Return(l_rec);
--
End convert_args;
--
end hr_qsa_shd;

/
