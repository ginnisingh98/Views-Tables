--------------------------------------------------------
--  DDL for Package Body PER_QAT_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_QAT_SHD" as
/* $Header: peqatrhi.pkb 120.0.12010000.2 2008/11/20 12:27:31 kgowripe ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  per_qat_shd.';  -- Global package name
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
  If (p_constraint_name = 'PER_QUALIFICATIONS_TL_PK') Then
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
  (p_qualification_id                     in     number
  ,p_language                             in     varchar2
  )      Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
       qualification_id
      ,language
      ,source_lang
      ,title
      ,group_ranking
      ,license_restrictions
      ,awarding_body
      ,grade_attained
      ,reimbursement_arrangements
      ,training_completed_units
      ,membership_category
    from  per_qualifications_tl
    where qualification_id = p_qualification_id
    and   language = p_language;
--
  l_fct_ret     boolean;
--
Begin
  --
  If (p_qualification_id is null or
      p_language is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_qualification_id
        = per_qat_shd.g_old_rec.qualification_id and
        p_language
        = per_qat_shd.g_old_rec.language
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
      Fetch C_Sel1 Into per_qat_shd.g_old_rec;
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
  (p_qualification_id                     in     number
  ,p_language                             in     varchar2
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select
       qualification_id
      ,language
      ,source_lang
      ,title
      ,group_ranking
      ,license_restrictions
      ,awarding_body
      ,grade_attained
      ,reimbursement_arrangements
      ,training_completed_units
      ,membership_category
    from        per_qualifications_tl
    where       qualification_id = p_qualification_id
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
    ,p_argument           => 'QUALIFICATION_ID'
    ,p_argument_value     => p_qualification_id
    );
  hr_utility.set_location(l_proc,6);
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'LANGUAGE'
    ,p_argument_value     => p_language
    );
  --
  Open  C_Sel1;
  Fetch C_Sel1 Into per_qat_shd.g_old_rec;
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
    fnd_message.set_token('TABLE_NAME', 'per_qualifications_tl');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< add_language >------------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE add_language IS
Begin
  --
  delete from PER_QUALIFICATIONS_TL T
  where not exists
    (select NULL
    from PER_QUALIFICATIONS B
    where B.QUALIFICATION_ID = T.QUALIFICATION_ID
    );

  update PER_QUALIFICATIONS_TL T set (
      TITLE,
      GROUP_RANKING,
      LICENSE_RESTRICTIONS,
      AWARDING_BODY,
      GRADE_ATTAINED,
      REIMBURSEMENT_ARRANGEMENTS,
      TRAINING_COMPLETED_UNITS,
      MEMBERSHIP_CATEGORY
    ) = (select
      B.TITLE,
      B.GROUP_RANKING,
      B.LICENSE_RESTRICTIONS,
      B.AWARDING_BODY,
      B.GRADE_ATTAINED,
      B.REIMBURSEMENT_ARRANGEMENTS,
      B.TRAINING_COMPLETED_UNITS,
      B.MEMBERSHIP_CATEGORY
    from PER_QUALIFICATIONS_TL B
    where B.QUALIFICATION_ID = T.QUALIFICATION_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.QUALIFICATION_ID,
      T.LANGUAGE
  ) in (select
      SUBT.QUALIFICATION_ID,
      SUBT.LANGUAGE
    from PER_QUALIFICATIONS_TL SUBB, PER_QUALIFICATIONS_TL SUBT
    where SUBB.QUALIFICATION_ID = SUBT.QUALIFICATION_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.GROUP_RANKING <> SUBT.GROUP_RANKING
      or (SUBB.GROUP_RANKING is null and SUBT.GROUP_RANKING is not null)
      or (SUBB.GROUP_RANKING is not null and SUBT.GROUP_RANKING is null)
      or SUBB.TITLE <> SUBT.TITLE
      or (SUBB.TITLE is null and SUBT.TITLE is not null)
      or (SUBB.TITLE is not null and SUBT.TITLE is null)
      or SUBB.LICENSE_RESTRICTIONS <> SUBT.LICENSE_RESTRICTIONS
      or (SUBB.LICENSE_RESTRICTIONS is null and SUBT.LICENSE_RESTRICTIONS is not null)
      or (SUBB.LICENSE_RESTRICTIONS is not null and SUBT.LICENSE_RESTRICTIONS is null)
      or SUBB.AWARDING_BODY <> SUBT.AWARDING_BODY
      or (SUBB.AWARDING_BODY is null and SUBT.AWARDING_BODY is not null)
      or (SUBB.AWARDING_BODY is not null and SUBT.AWARDING_BODY is null)
      or SUBB.GRADE_ATTAINED <> SUBT.GRADE_ATTAINED
      or (SUBB.GRADE_ATTAINED is null and SUBT.GRADE_ATTAINED is not null)
      or (SUBB.GRADE_ATTAINED is not null and SUBT.GRADE_ATTAINED is null)
      or SUBB.REIMBURSEMENT_ARRANGEMENTS <> SUBT.REIMBURSEMENT_ARRANGEMENTS
      or (SUBB.REIMBURSEMENT_ARRANGEMENTS is null and SUBT.REIMBURSEMENT_ARRANGEMENTS is not null)
      or (SUBB.REIMBURSEMENT_ARRANGEMENTS is not null and SUBT.REIMBURSEMENT_ARRANGEMENTS is null)
      or SUBB.TRAINING_COMPLETED_UNITS <> SUBT.TRAINING_COMPLETED_UNITS
      or (SUBB.TRAINING_COMPLETED_UNITS is null and SUBT.TRAINING_COMPLETED_UNITS is not null)
      or (SUBB.TRAINING_COMPLETED_UNITS is not null and SUBT.TRAINING_COMPLETED_UNITS is null)
      or SUBB.MEMBERSHIP_CATEGORY <> SUBT.MEMBERSHIP_CATEGORY
      or (SUBB.MEMBERSHIP_CATEGORY is null and SUBT.MEMBERSHIP_CATEGORY is not null)
      or (SUBB.MEMBERSHIP_CATEGORY is not null and SUBT.MEMBERSHIP_CATEGORY is null)
  ));

  insert into PER_QUALIFICATIONS_TL (
    QUALIFICATION_ID,
    TITLE,
    GROUP_RANKING,
    LICENSE_RESTRICTIONS,
    AWARDING_BODY,
    GRADE_ATTAINED,
    REIMBURSEMENT_ARRANGEMENTS,
    TRAINING_COMPLETED_UNITS,
    MEMBERSHIP_CATEGORY,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.QUALIFICATION_ID,
    B.TITLE,
    B.GROUP_RANKING,
    B.LICENSE_RESTRICTIONS,
    B.AWARDING_BODY,
    B.GRADE_ATTAINED,
    B.REIMBURSEMENT_ARRANGEMENTS,
    B.TRAINING_COMPLETED_UNITS,
    B.MEMBERSHIP_CATEGORY,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from PER_QUALIFICATIONS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from PER_QUALIFICATIONS_TL T
    where T.QUALIFICATION_ID = B.QUALIFICATION_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
  --
End;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
  (p_qualification_id               in number
  ,p_language                       in varchar2
  ,p_source_lang                    in varchar2
  ,p_title                          in varchar2
  ,p_group_ranking                  in varchar2
  ,p_license_restrictions           in varchar2
  ,p_awarding_body                  in varchar2
  ,p_grade_attained                 in varchar2
  ,p_reimbursement_arrangements     in varchar2
  ,p_training_completed_units       in varchar2
  ,p_membership_category            in varchar2
  )
  Return g_rec_type is
--
  l_rec   g_rec_type;
--
Begin
  --
  -- Convert arguments into local l_rec structure.
  --
  l_rec.qualification_id                 := p_qualification_id;
  l_rec.language                         := p_language;
  l_rec.source_lang                      := p_source_lang;
  l_rec.title                            := p_title;
  l_rec.group_ranking                    := p_group_ranking;
  l_rec.license_restrictions             := p_license_restrictions;
  l_rec.awarding_body                    := p_awarding_body;
  l_rec.grade_attained                   := p_grade_attained;
  l_rec.reimbursement_arrangements       := p_reimbursement_arrangements;
  l_rec.training_completed_units         := p_training_completed_units;
  l_rec.membership_category              := p_membership_category;
  --
  -- Return the plsql record structure.
  --
  Return(l_rec);
--
End convert_args;
--
end per_qat_shd;

/
