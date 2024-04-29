--------------------------------------------------------
--  DDL for Package Body PER_COT_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_COT_SHD" as
/* $Header: pecotrhi.pkb 115.0 2004/03/17 10:57 ynegoro noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  per_cot_shd.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |---------------------------< constraint_error >---------------------------|
-- ----------------------------------------------------------------------------
Procedure constraint_error
  (p_constraint_name in all_constraints.constraint_name%TYPE
  ) Is
--
  l_proc        varchar2(72) := g_package||'constraint_error';
--
Begin
  --
  If (p_constraint_name = 'PER_COMPETENCE_OUTCOMES_TL_PK') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','5');
    fnd_message.raise_error;
  Else
    fnd_message.set_name('PAY', 'HR_7877_API_INVALID_CONSTRAINT');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('CONSTRAINT_NAME', p_constraint_name);
    fnd_message.raise_error;
  End If;
  --
End constraint_error;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< api_updating >-----------------------------|
-- ----------------------------------------------------------------------------
Function api_updating
  (p_outcome_id                           in     number
  ,p_language                             in     varchar2
  )      Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
       outcome_id
      ,language
      ,source_lang
      ,name
      ,assessment_criteria
    from  per_competence_outcomes_tl
    where outcome_id = p_outcome_id
    and   language = p_language;
--
  l_fct_ret     boolean;
--
Begin
  --
  If (p_outcome_id is null or
      p_language is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_outcome_id
        = per_cot_shd.g_old_rec.outcome_id and
        p_language
        = per_cot_shd.g_old_rec.language
       ) Then
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
      Fetch C_Sel1 Into per_cot_shd.g_old_rec;
      If C_Sel1%notfound Then
        Close C_Sel1;
        --
        -- The primary key is invalid therefore we must error
        --
        fnd_message.set_name('PAY', 'HR_7220_INVALID_PRIMARY_KEY');
        fnd_message.raise_error;
      End If;
      Close C_Sel1;
      --
      l_fct_ret := true;
    End If;
  End If;
  Return (l_fct_ret);
--
End api_updating;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< lck >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure lck
  (p_outcome_id                           in     number
  ,p_language                             in     varchar2
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select
       outcome_id
      ,language
      ,source_lang
      ,name
      ,assessment_criteria
    from        per_competence_outcomes_tl
    where       outcome_id = p_outcome_id
    and         language = p_language
    for update nowait;
--
  l_proc        varchar2(72) := g_package||'lck';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'OUTCOME_ID'
    ,p_argument_value     => p_outcome_id
    );
  hr_utility.set_location(l_proc,6);
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'LANGUAGE'
    ,p_argument_value     => p_language
    );
  --
  Open  C_Sel1;
  Fetch C_Sel1 Into per_cot_shd.g_old_rec;
  If C_Sel1%notfound then
    Close C_Sel1;
    --
    -- The primary key is invalid therefore we must error
    --
    fnd_message.set_name('PAY', 'HR_7220_INVALID_PRIMARY_KEY');
    fnd_message.raise_error;
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
    fnd_message.set_name('PAY', 'HR_7165_OBJECT_LOCKED');
    fnd_message.set_token('TABLE_NAME', 'per_competence_outcomes_tl');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< add_language >------------------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE add_language IS
Begin
  --
  delete from per_competence_outcomes_tl T
  where not exists
    (select NULL
    from per_competence_outcomes B
    where B.outcome_id = T.outcome_id
    );

  update per_competence_outcomes_tl T set (
      NAME
    ) = (select
      B.NAME
    from per_competence_outcomes_tl B
    where B.outcome_id = T.outcome_id
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.outcome_id,
      T.LANGUAGE
  ) in (select
      SUBT.outcome_id,
      SUBT.LANGUAGE
    from per_competence_outcomes_tl SUBB, per_competence_outcomes_tl SUBT
    where SUBB.outcome_id = SUBT.outcome_id
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.NAME <> SUBT.NAME
      or (SUBB.NAME is null and SUBT.NAME is not null)
      or (SUBB.NAME is not null and SUBT.NAME is null)
  ));

  insert into per_competence_outcomes_tl (
    LAST_UPDATE_LOGIN,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    NAME,
    assessment_criteria,
    outcome_id,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.LAST_UPDATE_LOGIN,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.NAME,
    b.assessment_criteria,
    B.outcome_id,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from per_competence_outcomes_tl B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from per_competence_outcomes_tl T
    where T.outcome_id = B.outcome_id
    and T.LANGUAGE = L.LANGUAGE_CODE);
  --
  --
End;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
  (p_outcome_id                     in number
  ,p_language                       in varchar2
  ,p_source_lang                    in varchar2
  ,p_name                           in varchar2
  ,p_assessment_criteria            in varchar2
  )
  Return g_rec_type is
--
  l_rec   g_rec_type;
--
Begin
  --
  -- Convert arguments into local l_rec structure.
  --
  l_rec.outcome_id                       := p_outcome_id;
  l_rec.language                         := p_language;
  l_rec.source_lang                      := p_source_lang;
  l_rec.name                             := p_name;
  l_rec.assessment_criteria              := p_assessment_criteria;
  --
  -- Return the plsql record structure.
  --
  Return(l_rec);
--
End convert_args;
--
end per_cot_shd;

/
