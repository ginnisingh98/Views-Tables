--------------------------------------------------------
--  DDL for Package Body HR_QSF_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_QSF_SHD" as
/* $Header: hrqsfrhi.pkb 115.11 2003/08/27 00:16:45 hpandya ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)  := '  hr_qsf_shd.';  -- Global package name
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
  If (p_constraint_name = 'HR_QUEST_FIELDS_FK') Then
    fnd_message.set_name('PER', 'PER_52416_QSF_INVAL_TEMP_ID');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'HR_QUEST_FIELDS_PK') Then
    -- Unlikely to fail.
    hr_utility.set_message('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','10');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'HR_QUEST_FIELDS_SQL_FLAG_CHK') Then
    fnd_message.set_name('PER', 'PER_52417_QSF_REQD_FLAG_INVAL');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'HR_QUEST_FIELDS_TYPE_CHK') Then
    fnd_message.set_name('PER', 'PER_52418_QSF_TYPE_INVALID');
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
  p_field_id                           in number,
  p_object_version_number              in number
  )      Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
    field_id,
  questionnaire_template_id,
  name,
  type,
  html_text,
  sql_required_flag,
  sql_text,
  object_version_number
    from  hr_quest_fields
    where  field_id = p_field_id;
--
  l_proc  varchar2(72)  := g_package||'api_updating';
  l_fct_ret  boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (
  p_field_id is null and
  p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (
  p_field_id = g_old_rec.field_id and
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
        hr_utility.set_message('PER', 'HR_7220_INVALID_PRIMARY_KEY');
        hr_utility.raise_error;
      End If;
      Close C_Sel1;
      If (p_object_version_number <> g_old_rec.object_version_number) Then
        hr_utility.set_message('PER', 'HR_7155_OBJECT_INVALID');
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
  p_field_id                           in number,
  p_object_version_number              in number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select   field_id,
  questionnaire_template_id,
  name,
  type,
  html_text,
  sql_required_flag,
  sql_text,
  object_version_number
    from  hr_quest_fields
    where  field_id = p_field_id
    for  update nowait;
--
  l_proc  varchar2(72) := g_package||'lck';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_api.mandatory_arg_error
    (p_api_name  => l_proc
    ,p_argument  => 'field_id'
    ,p_argument_value => p_field_id);
  --
  hr_api.mandatory_arg_error
    (p_api_name  => l_proc
    ,p_argument  => 'object_version_number'
    ,p_argument_value => p_object_version_number);
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
  If (p_object_version_number <> g_old_rec.object_version_number) Then
        hr_utility.set_message('PER', 'HR_7155_OBJECT_INVALID');
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
    hr_utility.set_message('PER', 'HR_7165_OBJECT_LOCKED');
    hr_utility.set_message_token('TABLE_NAME', 'hr_quest_fields');
    hr_utility.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
  (
  p_field_id                      in number,
  p_questionnaire_template_id     in number,
  p_name                          in varchar2,
  p_type                          in varchar2,
  p_html_text                     in varchar2,
  p_sql_required_flag             in varchar2,
  p_sql_text                      in varchar2,
  p_object_version_number         in number
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
  l_rec.field_id                         := p_field_id;
  l_rec.questionnaire_template_id        := p_questionnaire_template_id;
  l_rec.name                             := p_name;
  l_rec.type                             := p_type;
  l_rec.html_text                        := p_html_text;
  l_rec.sql_required_flag                := p_sql_required_flag;
  l_rec.sql_text                         := p_sql_text;
  l_rec.object_version_number            := p_object_version_number;
  --
  -- Return the plsql record structure.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  Return(l_rec);
--
End convert_args;
--
end hr_qsf_shd;

/
