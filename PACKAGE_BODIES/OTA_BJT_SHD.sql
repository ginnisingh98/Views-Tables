--------------------------------------------------------
--  DDL for Package Body OTA_BJT_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_BJT_SHD" as
/* $Header: otbjtrhi.pkb 120.0 2005/05/29 07:03:39 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  ota_bjt_shd.';  -- Global package name
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
  If (p_constraint_name = 'SYS_C00179292') Then
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
  (p_booking_justification_id             in     number
  ,p_language                             in     varchar2
  )      Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
       booking_justification_id
      ,justification_text
      ,source_lang
      ,language
    from  ota_bkng_justifications_tl
    where booking_justification_id = p_booking_justification_id
    and   language = p_language;
--
  l_fct_ret     boolean;
--
Begin
  --
  If (p_booking_justification_id is null or
      p_language is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_booking_justification_id
        = ota_bjt_shd.g_old_rec.booking_justification_id and
        p_language
        = ota_bjt_shd.g_old_rec.language
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
      Fetch C_Sel1 Into ota_bjt_shd.g_old_rec;
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
  (p_booking_justification_id             in     number
  ,p_language                             in     varchar2
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select
       booking_justification_id
      ,justification_text
      ,source_lang
      ,language
    from        ota_bkng_justifications_tl
    where       booking_justification_id = p_booking_justification_id
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
    ,p_argument           => 'BOOKING_JUSTIFICATION_ID'
    ,p_argument_value     => p_booking_justification_id
    );
  hr_utility.set_location(l_proc,6);
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'LANGUAGE'
    ,p_argument_value     => p_language
    );
  --
  Open  C_Sel1;
  Fetch C_Sel1 Into ota_bjt_shd.g_old_rec;
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
    fnd_message.set_token('TABLE_NAME', 'ota_bkng_justifications_tl');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< add_language >------------------------------|
-- ----------------------------------------------------------------------------
procedure ADD_LANGUAGE
is
begin
  delete from OTA_BKNG_JUSTIFICATIONS_TL T
  where not exists
    (select NULL
    from OTA_BKNG_JUSTIFICATIONS_B B
    where B.BOOKING_JUSTIFICATION_ID = T.BOOKING_JUSTIFICATION_ID
    );

  update OTA_BKNG_JUSTIFICATIONS_TL T set (
      JUSTIFICATION_TEXT
    ) = (select
      B.JUSTIFICATION_TEXT
    from OTA_BKNG_JUSTIFICATIONS_TL B
    where B.BOOKING_JUSTIFICATION_ID = T.BOOKING_JUSTIFICATION_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.BOOKING_JUSTIFICATION_ID,
      T.LANGUAGE
  ) in (select
      SUBT.BOOKING_JUSTIFICATION_ID,
      SUBT.LANGUAGE
    from OTA_BKNG_JUSTIFICATIONS_TL SUBB, OTA_BKNG_JUSTIFICATIONS_TL SUBT
    where SUBB.BOOKING_JUSTIFICATION_ID = SUBT.BOOKING_JUSTIFICATION_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.JUSTIFICATION_TEXT <> SUBT.JUSTIFICATION_TEXT
  ));

  insert into OTA_BKNG_JUSTIFICATIONS_TL (
    BOOKING_JUSTIFICATION_ID,
    JUSTIFICATION_TEXT,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select /*+ ORDERED */
    B.BOOKING_JUSTIFICATION_ID,
    B.JUSTIFICATION_TEXT,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from OTA_BKNG_JUSTIFICATIONS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from OTA_BKNG_JUSTIFICATIONS_TL T
    where T.BOOKING_JUSTIFICATION_ID = B.BOOKING_JUSTIFICATION_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
  (p_booking_justification_id       in number
  ,p_justification_text             in varchar2
  ,p_source_lang                    in varchar2
  ,p_language                       in varchar2
  )
  Return g_rec_type is
--
  l_rec   g_rec_type;
--
Begin
  --
  -- Convert arguments into local l_rec structure.
  --
  l_rec.booking_justification_id         := p_booking_justification_id;
  l_rec.justification_text               := p_justification_text;
  l_rec.source_lang                      := p_source_lang;
  l_rec.language                         := p_language;
  --
  -- Return the plsql record structure.
  --
  Return(l_rec);
--
End convert_args;
--
end ota_bjt_shd;

/
