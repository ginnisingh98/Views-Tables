--------------------------------------------------------
--  DDL for Package Body LNS_CONDITIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."LNS_CONDITIONS_PKG" AS
/* $Header: LNS_CONDITIONS_TBLH_B.pls 120.0.12010000.1 2008/11/26 07:53:43 mbolli noship $ */

    PROCEDURE ADD_LANGUAGE
    IS
    BEGIN
      delete from LNS_CONDITIONS_TL T
      where not exists
        (select NULL
        from LNS_CONDITIONS B
        where B.CONDITION_ID = T.CONDITION_ID
        );

      update LNS_CONDITIONS_TL T set (
          CONDITION_NAME,
          CONDITION_DESCRIPTION
        ) = (select
          B.CONDITION_NAME,
          B.CONDITION_DESCRIPTION
        from LNS_CONDITIONS_TL B
        where B.CONDITION_ID = T.CONDITION_ID
        and B.LANGUAGE = T.SOURCE_LANG)
      where (
          T.CONDITION_ID,
          T.LANGUAGE
      ) in (select
          SUBT.CONDITION_ID,
          SUBT.LANGUAGE
        from LNS_CONDITIONS_TL SUBB, LNS_CONDITIONS_TL SUBT
        where SUBB.CONDITION_ID = SUBT.CONDITION_ID
        and SUBB.LANGUAGE = SUBT.SOURCE_LANG
        and (SUBB.CONDITION_NAME <> SUBT.CONDITION_NAME
          or (SUBB.CONDITION_NAME is null and SUBT.CONDITION_NAME is not null)
          or (SUBB.CONDITION_NAME is not null and SUBT.CONDITION_NAME is null)
          or SUBB.CONDITION_DESCRIPTION <> SUBT.CONDITION_DESCRIPTION
          or (SUBB.CONDITION_DESCRIPTION is null and SUBT.CONDITION_DESCRIPTION is not null)
          or (SUBB.CONDITION_DESCRIPTION is not null and SUBT.CONDITION_DESCRIPTION is null)
      ));

      insert into LNS_CONDITIONS_TL (
        CONDITION_ID,
        CONDITION_NAME,
        CONDITION_DESCRIPTION,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        CREATION_DATE,
        CREATED_BY,
        LAST_UPDATE_LOGIN,
        LANGUAGE,
        SOURCE_LANG
      ) select
        B.CONDITION_ID,
        B.CONDITION_NAME,
        B.CONDITION_DESCRIPTION,
        B.LAST_UPDATE_DATE,
        B.LAST_UPDATED_BY,
        B.CREATION_DATE,
        B.CREATED_BY,
        B.LAST_UPDATE_LOGIN,
        L.LANGUAGE_CODE,
        B.SOURCE_LANG
      from LNS_CONDITIONS_TL B, FND_LANGUAGES L
      where L.INSTALLED_FLAG in ('I', 'B')
      and B.LANGUAGE = userenv('LANG')
      and not exists
        (select NULL
        from LNS_CONDITIONS_TL T
        where T.CONDITION_ID = B.CONDITION_ID
        and T.LANGUAGE = L.LANGUAGE_CODE);

    END ADD_LANGUAGE;

END LNS_CONDITIONS_PKG;

/
