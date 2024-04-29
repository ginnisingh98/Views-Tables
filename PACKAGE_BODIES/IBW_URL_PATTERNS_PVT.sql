--------------------------------------------------------
--  DDL for Package Body IBW_URL_PATTERNS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBW_URL_PATTERNS_PVT" as
/* $Header: IBWURLB.pls 120.2 2005/10/28 01:32 vekancha noship $*/

  -- HISTORY
  --   10/27/05           VEKANCHA         Created this file.
  -- **************************************************************************


procedure ADD_LANGUAGE
is
begin
  delete from IBW_URL_PATTERNS_TL T
  where not exists
    (select NULL
    from IBW_URL_PATTERNS_B B
    where B.URL_PATTERN_ID = T.URL_PATTERN_ID
    );

  update IBW_URL_PATTERNS_TL T set (
      DESCRIPTION
    ) = (select
      B.DESCRIPTION
    from IBW_URL_PATTERNS_TL B
    where B.URL_PATTERN_ID = T.URL_PATTERN_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.URL_PATTERN_ID,
      T.LANGUAGE
  ) in (select
      SUBT.URL_PATTERN_ID,
      SUBT.LANGUAGE
    from IBW_URL_PATTERNS_TL SUBB, IBW_URL_PATTERNS_TL SUBT
    where SUBB.URL_PATTERN_ID = SUBT.URL_PATTERN_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

  insert into IBW_URL_PATTERNS_TL (
    URL_PATTERN_ID,
    DESCRIPTION,
    CREATED_BY,
    OBJECT_VERSION_NUMBER,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    PROGRAM_ID,
    PROGRAM_LOGIN_ID,
    PROGRAM_APPLICATION_ID,
    REQUEST_ID,
    LANGUAGE,
    SOURCE_LANG
  ) select /*+ ORDERED */
    B.URL_PATTERN_ID,
    B.DESCRIPTION,
    B.CREATED_BY,
    B.OBJECT_VERSION_NUMBER,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    B.PROGRAM_ID,
    B.PROGRAM_LOGIN_ID,
    B.PROGRAM_APPLICATION_ID,
    B.REQUEST_ID,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from IBW_URL_PATTERNS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from IBW_URL_PATTERNS_TL T
    where T.URL_PATTERN_ID = B.URL_PATTERN_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

end IBW_URL_PATTERNS_PVT;


/
