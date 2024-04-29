--------------------------------------------------------
--  DDL for Package Body PQP_ERT_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_ERT_SHD" as
/* $Header: pqertrhi.pkb 120.7 2006/09/15 00:09:58 sshetty noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  pqp_ert_shd.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------------------------< return_api_dml_status >-------------------------|
-- ----------------------------------------------------------------------------
Function return_api_dml_status Return Boolean Is
--
Begin
  --
  Return (nvl(g_api_dml, false));
  --
End return_api_dml_status;
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
  If (p_constraint_name = 'PEL_PK') Then
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
  (p_exception_report_id                  in     number
  ,p_language                             in     varchar2
  )      Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
       exception_report_id
      ,exception_report_name
      ,language
      ,source_lang
    from  pqp_exception_reports_tl
    where exception_report_id = p_exception_report_id
    and   language = p_language;
--
  l_fct_ret     boolean;
--
Begin
  --
  If (p_exception_report_id is null or
      p_language is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_exception_report_id
        = pqp_ert_shd.g_old_rec.exception_report_id and
        p_language
        = pqp_ert_shd.g_old_rec.language
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
      Fetch C_Sel1 Into pqp_ert_shd.g_old_rec;
      If C_Sel1%notfound Then
        Close C_Sel1;
        --
        -- The primary key is invalid therefore we must error
        --
        fnd_message.set_name('PAY', 'HR_7220_INVALID_PRIMARY_KEY');
        fnd_message.raise_error;
      End If;
      Close C_Sel1;
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
  (p_exception_report_id                  in     number
  ,p_language                             in     varchar2
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select
       exception_report_id
      ,exception_report_name
      ,language
      ,source_lang
    from        pqp_exception_reports_tl
    where       exception_report_id = p_exception_report_id
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
    ,p_argument           => 'EXCEPTION_REPORT_ID'
    ,p_argument_value     => p_exception_report_id
    );
  hr_utility.set_location(l_proc,6);
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'LANGUAGE'
    ,p_argument_value     => p_language
    );
  hr_utility.set_location(l_proc,7);
  --
  Open  C_Sel1;
  Fetch C_Sel1 Into pqp_ert_shd.g_old_rec;
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
    fnd_message.set_token('TABLE_NAME', 'pqp_exception_reports_tl');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< add_language >------------------------------|
-- ----------------------------------------------------------------------------
procedure ADD_LANGUAGE
is
begin
  delete from PQP_EXCEPTION_REPORTS_TL T
  where not exists
    (select NULL
    from PQP_EXCEPTION_REPORTS B
    where B.EXCEPTION_REPORT_ID = T.EXCEPTION_REPORT_ID
    );

  update PQP_EXCEPTION_REPORTS_TL T set (
      EXCEPTION_REPORT_NAME
    ) = (select
      B.EXCEPTION_REPORT_NAME
    from PQP_EXCEPTION_REPORTS_TL B
    where B.EXCEPTION_REPORT_ID = T.EXCEPTION_REPORT_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.EXCEPTION_REPORT_ID,
      T.LANGUAGE
  ) in (select
      SUBT.EXCEPTION_REPORT_ID,
      SUBT.LANGUAGE
    from PQP_EXCEPTION_REPORTS_TL SUBB, PQP_EXCEPTION_REPORTS_TL SUBT
    where SUBB.EXCEPTION_REPORT_ID = SUBT.EXCEPTION_REPORT_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.EXCEPTION_REPORT_NAME <> SUBT.EXCEPTION_REPORT_NAME
  ));


  insert into PQP_EXCEPTION_REPORTS_TL (
    EXCEPTION_REPORT_ID,
    EXCEPTION_REPORT_NAME,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    CREATED_BY,
    CREATION_DATE,
--    OBJECT_VERSION_NUMBER,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.EXCEPTION_REPORT_ID,
    B.EXCEPTION_REPORT_NAME,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    B.CREATED_BY,
    B.CREATION_DATE,
--  B.OBJECT_VERSION_NUMBER,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from PQP_EXCEPTION_REPORTS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from PQP_EXCEPTION_REPORTS_TL T
    where T.EXCEPTION_REPORT_ID = B.EXCEPTION_REPORT_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;
--
--
Procedure load_row  (
                          p_exception_report_name  IN VARCHAR2
                         ,p_legislation_code       IN VARCHAR2
                         ,p_business_group_id      IN NUMBER
                         ,p_currency_code          IN VARCHAR2
                         ,p_balance_type_id        IN NUMBER
                         ,p_balance_dimension_id   IN NUMBER
                         ,p_variance_type          IN VARCHAR2
                         ,p_variance_value         IN NUMBER
                         ,p_comparison_type        IN VARCHAR2
                         ,p_comparison_value       IN NUMBER
                         ,p_exception_report_id    IN OUT NOCOPY NUMBER
                         ,p_object_version_number  IN OUT NOCOPY NUMBER
                         ,p_output_format_type     IN VARCHAr2
                         ,p_variance_operator      IN VARCHAr2
                         ,p_type                   IN VARCHAR2)
IS

begin

IF p_type='I' THEN

pqp_exr_api.create_exception_report (
                          p_exception_report_name   => p_exception_report_name
                         ,p_legislation_code        => p_legislation_code
                         ,p_business_group_id       => p_business_group_id
                         ,p_currency_code           => p_currency_code
                         ,p_balance_type_id         => p_balance_type_id
                         ,p_balance_dimension_id    => p_balance_dimension_id
                         ,p_variance_type           => p_variance_type
                         ,p_variance_value          => p_variance_value
                         ,p_comparison_type         => p_comparison_type
                         ,p_comparison_value        => p_comparison_value
                         ,p_exception_report_id     => p_exception_report_id
                         ,p_object_version_number   => p_object_version_number
                         ,p_output_format_type      => p_output_format_type
                         ,p_variance_operator       => p_variance_operator );
ELSE
 pqp_exr_api.update_exception_report (
                          p_exception_report_name   => p_exception_report_name
                         ,p_legislation_code        => p_legislation_code
                         ,p_business_group_id       => p_business_group_id
                         ,p_currency_code           => p_currency_code
                         ,p_balance_type_id         => p_balance_type_id
                         ,p_balance_dimension_id    => p_balance_dimension_id
                         ,p_variance_type           => p_variance_type
                         ,p_variance_value          => p_variance_value
                         ,p_comparison_type         => p_comparison_type
                         ,p_comparison_value        => p_comparison_value
                         ,p_exception_report_id     => p_exception_report_id
                         ,p_object_version_number   => p_object_version_number
                         ,p_output_format_type	    => p_output_format_type
                         ,p_variance_operator	    => p_variance_operator );
END IF;
end;
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
  (p_exception_report_id            in number
  ,p_exception_report_name          in varchar2
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
  l_rec.exception_report_id              := p_exception_report_id;
  l_rec.exception_report_name            := p_exception_report_name;
  l_rec.language                         := p_language;
  l_rec.source_lang                      := p_source_lang;
  --
  -- Return the plsql record structure.
  --
  Return(l_rec);
--
End convert_args;
--
end pqp_ert_shd;

/
