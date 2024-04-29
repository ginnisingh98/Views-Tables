--------------------------------------------------------
--  DDL for Package Body PER_SBT_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_SBT_SHD" as
/* $Header: pesbtrhi.pkb 120.0 2005/05/31 20:43:05 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  per_sbt_shd.';  -- Global package name
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
  If (p_constraint_name = 'PER_SUBJECTS_TAKEN_TL_PK') Then
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
  (p_subjects_taken_id                    in     number
  ,p_language                             in     varchar2
  )      Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
       subjects_taken_id
      ,language
      ,source_lang
      ,grade_attained
    from  per_subjects_taken_tl
    where subjects_taken_id = p_subjects_taken_id
    and   language = p_language;
--
  l_fct_ret     boolean;
--
Begin
  --
  If (p_subjects_taken_id is null or
      p_language is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_subjects_taken_id
        = per_sbt_shd.g_old_rec.subjects_taken_id and
        p_language
        = per_sbt_shd.g_old_rec.language
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
      Fetch C_Sel1 Into per_sbt_shd.g_old_rec;
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
  (p_subjects_taken_id                    in     number
  ,p_language                             in     varchar2
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select
       subjects_taken_id
      ,language
      ,source_lang
      ,grade_attained
    from        per_subjects_taken_tl
    where       subjects_taken_id = p_subjects_taken_id
    and   language = p_language
    for update nowait;
--
  l_proc        varchar2(72) := g_package||'lck';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'SUBJECTS_TAKEN_ID'
    ,p_argument_value     => p_subjects_taken_id
    );
  hr_utility.set_location(l_proc,6);
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'LANGUAGE'
    ,p_argument_value     => p_language
    );
  --
  Open  C_Sel1;
  Fetch C_Sel1 Into per_sbt_shd.g_old_rec;
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
    fnd_message.set_token('TABLE_NAME', 'per_subjects_taken_tl');
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
  delete from PER_SUBJECTS_TAKEN_TL T
  where not exists
    (select NULL
    from PER_SUBJECTS_TAKEN B
    where B.SUBJECTS_TAKEN_ID = T.SUBJECTS_TAKEN_ID
    );

  update PER_SUBJECTS_TAKEN_TL T set (
      GRADE_ATTAINED
    ) = (select
      B.GRADE_ATTAINED
    from PER_SUBJECTS_TAKEN_TL B
    where B.SUBJECTS_TAKEN_ID = T.SUBJECTS_TAKEN_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.SUBJECTS_TAKEN_ID,
      T.LANGUAGE
  ) in (select
      SUBT.SUBJECTS_TAKEN_ID,
      SUBT.LANGUAGE
    from PER_SUBJECTS_TAKEN_TL SUBB, PER_SUBJECTS_TAKEN_TL SUBT
    where SUBB.SUBJECTS_TAKEN_ID = SUBT.SUBJECTS_TAKEN_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.GRADE_ATTAINED <> SUBT.GRADE_ATTAINED
      or (SUBB.GRADE_ATTAINED is null and SUBT.GRADE_ATTAINED is not null)
      or (SUBB.GRADE_ATTAINED is not null and SUBT.GRADE_ATTAINED is null)
  ));

  insert into PER_SUBJECTS_TAKEN_TL (
    SUBJECTS_TAKEN_ID,
    GRADE_ATTAINED,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.SUBJECTS_TAKEN_ID,
    B.GRADE_ATTAINED,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from PER_SUBJECTS_TAKEN_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from PER_SUBJECTS_TAKEN_TL T
    where T.SUBJECTS_TAKEN_ID = B.SUBJECTS_TAKEN_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
  --
End;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
  (p_subjects_taken_id              in number
  ,p_language                       in varchar2
  ,p_source_lang                    in varchar2
  ,p_grade_attained                 in varchar2
  )
  Return g_rec_type is
--
  l_rec   g_rec_type;
--
Begin
  --
  -- Convert arguments into local l_rec structure.
  --
  l_rec.subjects_taken_id                := p_subjects_taken_id;
  l_rec.language                         := p_language;
  l_rec.source_lang                      := p_source_lang;
  l_rec.grade_attained                   := p_grade_attained;
  --
  -- Return the plsql record structure.
  --
  Return(l_rec);
--
End convert_args;
--
end per_sbt_shd;

/
