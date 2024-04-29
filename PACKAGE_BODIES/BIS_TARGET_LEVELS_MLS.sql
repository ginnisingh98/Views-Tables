--------------------------------------------------------
--  DDL for Package Body BIS_TARGET_LEVELS_MLS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIS_TARGET_LEVELS_MLS" AS
/* $Header: BISTMLSB.pls 115.1 99/07/17 16:11:03 porting ship $ */

procedure ADD_LANGUAGE
is
begin
  delete from BIS_TARGET_LEVELS_TL T
  where not exists
    (select NULL
    from BIS_TARGET_LEVELS B
    where B.TARGET_LEVEL_ID = T.TARGET_LEVEL_ID
    );

  update BIS_TARGET_LEVELS_TL T set (
      NAME,
      DESCRIPTION
    ) = (select
      B.NAME,
      B.DESCRIPTION
    from BIS_TARGET_LEVELS_TL B
    where B.TARGET_LEVEL_ID = T.TARGET_LEVEL_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.TARGET_LEVEL_ID,
      T.LANGUAGE
  ) in (select
      SUBT.TARGET_LEVEL_ID,
      SUBT.LANGUAGE
    from BIS_TARGET_LEVELS_TL SUBB, BIS_TARGET_LEVELS_TL SUBT
    where SUBB.TARGET_LEVEL_ID = SUBT.TARGET_LEVEL_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.NAME <> SUBT.NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

  insert into BIS_TARGET_LEVELS_TL (
    TARGET_LEVEL_ID,
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
    B.TARGET_LEVEL_ID,
    B.NAME,
    B.DESCRIPTION,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from BIS_TARGET_LEVELS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from BIS_TARGET_LEVELS_TL T
    where T.TARGET_LEVEL_ID = B.TARGET_LEVEL_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);

end ADD_LANGUAGE;

end BIS_TARGET_LEVELS_MLS;

/
