--------------------------------------------------------
--  DDL for Package Body PQH_CRL_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_CRL_SHD" as
/* $Header: pqcrlrhi.pkb 120.2 2005/12/07 13:23 srajakum noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  pqh_crl_shd.';  -- Global package name
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
  If (p_constraint_name = 'PQH_CRITERIA_RT_DEFN_TL_PK') Then
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
  (p_criteria_rate_defn_id                in     number
  ,p_language                             in     varchar2
  )      Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
       criteria_rate_defn_id
      ,name
      ,language
      ,source_lang
    from  pqh_criteria_rate_defn_tl
    where criteria_rate_defn_id = p_criteria_rate_defn_id
    and   language = p_language;
--
  l_fct_ret     boolean;
--
Begin
  --
  If (p_criteria_rate_defn_id is null or
      p_language is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_criteria_rate_defn_id
        = pqh_crl_shd.g_old_rec.criteria_rate_defn_id and
        p_language
        = pqh_crl_shd.g_old_rec.language
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
      Fetch C_Sel1 Into pqh_crl_shd.g_old_rec;
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
  (p_criteria_rate_defn_id                in     number
  ,p_language                             in     varchar2
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select
       criteria_rate_defn_id
      ,name
      ,language
      ,source_lang
    from        pqh_criteria_rate_defn_tl
    where       criteria_rate_defn_id = p_criteria_rate_defn_id
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
    ,p_argument           => 'CRITERIA_RATE_DEFN_ID'
    ,p_argument_value     => p_criteria_rate_defn_id
    );
  hr_utility.set_location(l_proc,6);
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'LANGUAGE'
    ,p_argument_value     => p_language
    );
  --
  Open  C_Sel1;
  Fetch C_Sel1 Into pqh_crl_shd.g_old_rec;
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
    fnd_message.set_token('TABLE_NAME', 'pqh_criteria_rate_defn_tl');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< add_language >------------------------------|
-- ----------------------------------------------------------------------------
--
--
-- ----------------------------------------------------------------------------
PROCEDURE add_language IS
Begin
  --
  delete from PQH_CRITERIA_RATE_DEFN_TL T
  where not exists
    (select NULL
    from  PQH_CRITERIA_RATE_DEFN B
    where B.CRITERIA_RATE_DEFN_ID = T.CRITERIA_RATE_DEFN_ID
    );

  update PQH_CRITERIA_RATE_DEFN_TL T set (
      NAME
    ) = (select
      B.NAME
    from PQH_CRITERIA_RATE_DEFN_TL B
    where B.CRITERIA_RATE_DEFN_ID = T.CRITERIA_RATE_DEFN_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.CRITERIA_RATE_DEFN_ID,
      T.LANGUAGE
  ) in (select
      SUBT.CRITERIA_RATE_DEFN_ID,
      SUBT.LANGUAGE
    from PQH_CRITERIA_RATE_DEFN_TL SUBB, PQH_CRITERIA_RATE_DEFN_TL SUBT
    where SUBB.CRITERIA_RATE_DEFN_ID = SUBT.CRITERIA_RATE_DEFN_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.NAME <> SUBT.NAME
  ));

   insert into PQH_CRITERIA_RATE_DEFN_TL (
    CRITERIA_RATE_DEFN_ID,
    NAME,
    LAST_UPDATE_DATE,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    LAST_UPDATED_BY,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.CRITERIA_RATE_DEFN_ID,
    B.NAME,
    B.LAST_UPDATE_DATE,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_LOGIN,
    B.LAST_UPDATED_BY,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from PQH_CRITERIA_RATE_DEFN_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from PQH_CRITERIA_RATE_DEFN_TL T
    where T.CRITERIA_RATE_DEFN_ID = B.CRITERIA_RATE_DEFN_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
  --
  --
End;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
  (p_criteria_rate_defn_id          in number
  ,p_name                           in varchar2
  ,p_language                       in varchar2
  ,p_source_lang                    in varchar2
  )
  Return g_rec_type is
--
  l_rec   g_rec_type;
--
Begin
  --
  -- Convert arguments into local l_rec structure.
  --
  l_rec.criteria_rate_defn_id            := p_criteria_rate_defn_id;
  l_rec.name                             := p_name;
  l_rec.language                         := p_language;
  l_rec.source_lang                      := p_source_lang;
  --
  -- Return the plsql record structure.
  --
  Return(l_rec);
--
End convert_args;
--
end pqh_crl_shd;

/
