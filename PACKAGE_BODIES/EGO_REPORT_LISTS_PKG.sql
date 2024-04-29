--------------------------------------------------------
--  DDL for Package Body EGO_REPORT_LISTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EGO_REPORT_LISTS_PKG" as
/* $Header: EGOURPLB.pls 120.0 2005/11/04 18:28 sshrikha noship $ */


PROCEDURE ADD_LANGUAGE
IS

BEGIN
  delete from EGO_REPORT_LISTS_TL T
  where not exists
    (select NULL
    from EGO_REPORT_LISTS_B B
    where B.LIST_ID = T.LIST_ID
    );

  update EGO_REPORT_LISTS_TL T set (
      LIST_NAME
    ) = (select
      B.LIST_NAME
    from EGO_REPORT_LISTS_TL B
    where B.LIST_ID = T.LIST_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
        T.LIST_ID,
        T.LANGUAGE
    ) in (select
        SUBT.LIST_ID,
        SUBT.LANGUAGE
      from EGO_REPORT_LISTS_TL SUBB, EGO_REPORT_LISTS_TL SUBT
      where SUBB.LIST_ID = SUBT.LIST_ID
      and SUBB.LANGUAGE = SUBT.SOURCE_LANG
      and (SUBB.LIST_NAME <> SUBT.LIST_NAME
        or (SUBB.LIST_NAME is null and SUBT.LIST_NAME is not null)
        or (SUBB.LIST_NAME is not null and SUBT.LIST_NAME is null)
  ));

   insert into EGO_REPORT_LISTS_TL (
      LIST_ID,
      CREATION_DATE,
      CREATED_BY,
      LAST_UPDATE_DATE,
      LAST_UPDATED_BY,
      LAST_UPDATE_LOGIN,
      LIST_NAME,
      LANGUAGE,
      SOURCE_LANG
        ) select
          B.LIST_ID,
          B.CREATION_DATE,
          B.CREATED_BY,
          B.LAST_UPDATE_DATE,
          B.LAST_UPDATED_BY,
          B.LAST_UPDATE_LOGIN,
          B.LIST_NAME,
          L.LANGUAGE_CODE,
          B.SOURCE_LANG
        from EGO_REPORT_LISTS_TL B, FND_LANGUAGES L
        where L.INSTALLED_FLAG in ('I', 'B')
        and B.LANGUAGE = userenv('LANG')
  and not exists
  (select NULL
      from EGO_REPORT_LISTS_TL T
      where T.LIST_ID = B.LIST_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);

END ADD_LANGUAGE;

end EGO_REPORT_LISTS_PKG;

/
