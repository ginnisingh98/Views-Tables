--------------------------------------------------------
--  DDL for Package Body OKC_XQUESTIONS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_XQUESTIONS_PVT" AS
/* $Header: OKCVXQUESTIONSB.pls 120.0 2005/05/25 19:22:41 appldev noship $ */


procedure ADD_LANGUAGE
is
begin
  delete from OKC_XPRT_QUESTIONS_TL T
  where not exists
    (select NULL
    from OKC_XPRT_QUESTIONS_B B
    where B.QUESTION_ID = T.QUESTION_ID
    );

  update OKC_XPRT_QUESTIONS_TL T set (
      QUESTION_NAME,
      DESCRIPTION,
      PROMPT
    ) = (select
      B.QUESTION_NAME,
      B.DESCRIPTION,
      B.PROMPT
    from OKC_XPRT_QUESTIONS_TL B
    where B.QUESTION_ID = T.QUESTION_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.QUESTION_ID,
      T.LANGUAGE
  ) in (select
      SUBT.QUESTION_ID,
      SUBT.LANGUAGE
    from OKC_XPRT_QUESTIONS_TL SUBB, OKC_XPRT_QUESTIONS_TL SUBT
    where SUBB.QUESTION_ID = SUBT.QUESTION_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.QUESTION_NAME <> SUBT.QUESTION_NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
      or SUBB.PROMPT <> SUBT.PROMPT
      or (SUBB.PROMPT is null and SUBT.PROMPT is not null)
      or (SUBB.PROMPT is not null and SUBT.PROMPT is null)
  ));

  insert into OKC_XPRT_QUESTIONS_TL (
    QUESTION_ID,
    QUESTION_NAME,
    QUESTION_TYPE,
    DESCRIPTION,
    PROMPT,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select /*+ ORDERED */
    B.QUESTION_ID,
    B.QUESTION_NAME,
    B.QUESTION_TYPE,
    B.DESCRIPTION,
    B.PROMPT,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from OKC_XPRT_QUESTIONS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from OKC_XPRT_QUESTIONS_TL T
    where T.QUESTION_ID = B.QUESTION_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

END OKC_XQUESTIONS_PVT;

/
