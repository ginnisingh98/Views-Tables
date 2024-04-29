--------------------------------------------------------
--  DDL for Package Body LNS_ASSETS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."LNS_ASSETS_PKG" AS
/* $Header: LNS_ASSETS_TBLH_B.pls 120.0.12010000.1 2008/11/26 07:53:40 mbolli noship $ */

    PROCEDURE ADD_LANGUAGE
    IS
    BEGIN
      delete from LNS_ASSETS_TL T
      where not exists
        (select NULL
        from LNS_ASSETS B
        where B.ASSET_ID = T.ASSET_ID
        );

      update LNS_ASSETS_TL T set (
          DESCRIPTION
        ) = (select
          B.DESCRIPTION
        from LNS_ASSETS_TL B
        where B.ASSET_ID = T.ASSET_ID
        and B.LANGUAGE = T.SOURCE_LANG)
      where (
          T.ASSET_ID,
          T.LANGUAGE
      ) in (select
          SUBT.ASSET_ID,
          SUBT.LANGUAGE
        from LNS_ASSETS_TL SUBB, LNS_ASSETS_TL SUBT
        where SUBB.ASSET_ID = SUBT.ASSET_ID
        and SUBB.LANGUAGE = SUBT.SOURCE_LANG
        and (SUBB.DESCRIPTION <> SUBT.DESCRIPTION
          or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
          or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
      ));

      insert into LNS_ASSETS_TL (
        ASSET_ID,
        DESCRIPTION,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        CREATION_DATE,
        CREATED_BY,
        LAST_UPDATE_LOGIN,
        LANGUAGE,
        SOURCE_LANG
      ) select
        B.ASSET_ID,
        B.DESCRIPTION,
        B.LAST_UPDATE_DATE,
        B.LAST_UPDATED_BY,
        B.CREATION_DATE,
        B.CREATED_BY,
        B.LAST_UPDATE_LOGIN,
        L.LANGUAGE_CODE,
        B.SOURCE_LANG
      from LNS_ASSETS_TL B, FND_LANGUAGES L
      where L.INSTALLED_FLAG in ('I', 'B')
      and B.LANGUAGE = userenv('LANG')
      and not exists
        (select NULL
        from LNS_ASSETS_TL T
        where T.ASSET_ID = B.ASSET_ID
        and T.LANGUAGE = L.LANGUAGE_CODE);

    END ADD_LANGUAGE;

END LNS_ASSETS_PKG;

/
