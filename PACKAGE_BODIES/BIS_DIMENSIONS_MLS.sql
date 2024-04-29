--------------------------------------------------------
--  DDL for Package Body BIS_DIMENSIONS_MLS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIS_DIMENSIONS_MLS" AS
/* $Header: BISDMLSB.pls 115.1 99/07/17 16:07:40 porting ship $ */

procedure ADD_LANGUAGE
is
begin
  delete from BIS_DIMENSIONS_TL T
  where not exists
    (select NULL
    from BIS_DIMENSIONS B
    where B.DIMENSION_ID = T.DIMENSION_ID
    );

  update BIS_DIMENSIONS_TL T set (
      NAME,
      DESCRIPTION
    ) = (select
      B.NAME,
      B.DESCRIPTION
    from BIS_DIMENSIONS_TL B
    where B.DIMENSION_ID = T.DIMENSION_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.DIMENSION_ID,
      T.LANGUAGE
  ) in (select
      SUBT.DIMENSION_ID,
      SUBT.LANGUAGE
    from BIS_DIMENSIONS_TL SUBB, BIS_DIMENSIONS_TL SUBT
    where SUBB.DIMENSION_ID = SUBT.DIMENSION_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.NAME <> SUBT.NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

  insert into BIS_DIMENSIONS_TL (
    DIMENSION_ID,
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
    B.DIMENSION_ID,
    B.NAME,
    B.DESCRIPTION,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from BIS_DIMENSIONS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from BIS_DIMENSIONS_TL T
    where T.DIMENSION_ID = B.DIMENSION_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);

end ADD_LANGUAGE;

end BIS_DIMENSIONS_MLS;

/
