--------------------------------------------------------
--  DDL for Package Body HR_QSN_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_QSN_SHD" as
/* $Header: hrqsnrhi.pkb 120.4.12010000.3 2008/11/05 09:57:56 rsykam ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)  := '  hr_qsn_shd.';  -- Global package name
--
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
  If (p_constraint_name = 'HR_QUESTIONNAIRES_FK') Then
    fnd_message.set_name('PER','PER_52409_QSN_INVAL_BUS_GRP_ID');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'HR_QUESTIONNAIRES_PK') Then
    -- Unlikely to fail
    fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE',l_proc);
    fnd_message.set_token('STEP','10');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'HR_QUESTIONNAIRES_UK1') Then
    fnd_message.set_name('PER', 'PER_52410_QSN_NAME_NOT_UNIQUE');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'HR_QUEST_AVAILABLE_FLAG_CHK') Then
    fnd_message.set_name('PER', 'PER_52411_QSN_AVAIL_FLAG_INVAL');
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
  p_questionnaire_template_id          in number,
  p_object_version_number              in number
  )      Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
    questionnaire_template_id,
  name,
  text,
  available_flag,
  business_group_id,
  object_version_number
    from  hr_questionnaires
    where  questionnaire_template_id = p_questionnaire_template_id;
--
  l_proc  varchar2(72)  := g_package||'api_updating';
  l_fct_ret  boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (
  p_questionnaire_template_id is null and
  p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (
  p_questionnaire_template_id = g_old_rec.questionnaire_template_id and
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
  p_questionnaire_template_id          in number,
  p_object_version_number              in number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select   questionnaire_template_id,
  name,
  text,
  available_flag,
  business_group_id,
  object_version_number
    from  hr_questionnaires
    where  questionnaire_template_id = p_questionnaire_template_id
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
    ,p_argument => 'questionnaire_template_id'
    ,p_argument_value => p_questionnaire_template_id);
  --
  hr_api.mandatory_arg_error
    (p_api_name => l_proc
    ,p_argument => 'object_version_number'
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
    hr_utility.set_message_token('TABLE_NAME', 'hr_questionnaires');
    hr_utility.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
  (
  p_questionnaire_template_id     in number,
  p_name                          in varchar2,
  p_text                          in CLOB,
  p_available_flag                in varchar2,
  p_business_group_id             in number,
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
  l_rec.questionnaire_template_id        := p_questionnaire_template_id;
  l_rec.name                             := p_name;
  l_rec.text                             := p_text;
  l_rec.available_flag                   := p_available_flag;
  l_rec.business_group_id                := p_business_group_id;
  l_rec.object_version_number            := p_object_version_number;
  --
  -- Return the plsql record structure.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  Return(l_rec);
--
End convert_args;
--
end hr_qsn_shd;

/
