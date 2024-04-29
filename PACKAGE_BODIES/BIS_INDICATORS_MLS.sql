--------------------------------------------------------
--  DDL for Package Body BIS_INDICATORS_MLS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIS_INDICATORS_MLS" AS
/* $Header: BISIMLSB.pls 115.3 2003/02/12 04:34:07 sashaik noship $ */
procedure ADD_LANGUAGE
is
begin
  delete from BIS_INDICATORS_TL T
  where not exists
    (select NULL
    from BIS_INDICATORS B
    where B.INDICATOR_ID = T.INDICATOR_ID
    );

  update BIS_INDICATORS_TL T set (
      NAME,
      DESCRIPTION
    ) = (select
      B.NAME,
      B.DESCRIPTION
    from BIS_INDICATORS_TL B
    where B.INDICATOR_ID = T.INDICATOR_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.INDICATOR_ID,
      T.LANGUAGE
  ) in (select
      SUBT.INDICATOR_ID,
      SUBT.LANGUAGE
    from BIS_INDICATORS_TL SUBB, BIS_INDICATORS_TL SUBT
    where SUBB.INDICATOR_ID = SUBT.INDICATOR_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.NAME <> SUBT.NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

  insert into BIS_INDICATORS_TL (
    INDICATOR_ID,
    NAME,
    DESCRIPTION,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.INDICATOR_ID,
    B.NAME,
    B.DESCRIPTION,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from BIS_INDICATORS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from BIS_INDICATORS_TL T
    where T.INDICATOR_ID = B.INDICATOR_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);

end ADD_LANGUAGE;

end BIS_INDICATORS_MLS;

/
