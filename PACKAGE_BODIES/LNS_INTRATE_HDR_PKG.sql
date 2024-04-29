--------------------------------------------------------
--  DDL for Package Body LNS_INTRATE_HDR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."LNS_INTRATE_HDR_PKG" AS
/*$Header: LNS_LINTRATE_HDR_TBLH_B.pls 120.0.12010000.1 2008/11/21 14:43:50 mbolli noship $ */

    PROCEDURE ADD_LANGUAGE
    IS
    BEGIN
      delete from LNS_INT_RATE_HEADERS_TL T
      where not exists
        (select NULL
        from LNS_INT_RATE_HEADERS B
        where B.INTEREST_RATE_ID = T.INTEREST_RATE_ID
        );

      update LNS_INT_RATE_HEADERS_TL T set (
          INTEREST_RATE_NAME,
          INTEREST_RATE_DESCRIPTION
        ) = (select
          B.INTEREST_RATE_NAME,
          B.INTEREST_RATE_DESCRIPTION
        from LNS_INT_RATE_HEADERS_TL B
        where B.INTEREST_RATE_ID = T.INTEREST_RATE_ID
        and B.LANGUAGE = T.SOURCE_LANG)
      where (
          T.INTEREST_RATE_ID,
          T.LANGUAGE
      ) in (select
          SUBT.INTEREST_RATE_ID,
          SUBT.LANGUAGE
        from LNS_INT_RATE_HEADERS_TL SUBB, LNS_INT_RATE_HEADERS_TL SUBT
        where SUBB.INTEREST_RATE_ID = SUBT.INTEREST_RATE_ID
        and SUBB.LANGUAGE = SUBT.SOURCE_LANG
        and (SUBB.INTEREST_RATE_NAME <> SUBT.INTEREST_RATE_NAME
          or (SUBB.INTEREST_RATE_NAME is null and SUBT.INTEREST_RATE_NAME is not null)
          or (SUBB.INTEREST_RATE_NAME is not null and SUBT.INTEREST_RATE_NAME is null)
          or SUBB.INTEREST_RATE_DESCRIPTION <> SUBT.INTEREST_RATE_DESCRIPTION
          or (SUBB.INTEREST_RATE_DESCRIPTION is null and SUBT.INTEREST_RATE_DESCRIPTION is not null)
          or (SUBB.INTEREST_RATE_DESCRIPTION is not null and SUBT.INTEREST_RATE_DESCRIPTION is null)
      ));

      insert into LNS_INT_RATE_HEADERS_TL (
        INTEREST_RATE_ID,
        INTEREST_RATE_NAME,
        INTEREST_RATE_DESCRIPTION,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        CREATION_DATE,
        CREATED_BY,
        LAST_UPDATE_LOGIN,
        LANGUAGE,
        SOURCE_LANG
      ) select
        B.INTEREST_RATE_ID,
        B.INTEREST_RATE_NAME,
        B.INTEREST_RATE_DESCRIPTION,
        B.LAST_UPDATE_DATE,
        B.LAST_UPDATED_BY,
        B.CREATION_DATE,
        B.CREATED_BY,
        B.LAST_UPDATE_LOGIN,
        L.LANGUAGE_CODE,
        B.SOURCE_LANG
      from LNS_INT_RATE_HEADERS_TL B, FND_LANGUAGES L
      where L.INSTALLED_FLAG in ('I', 'B')
      and B.LANGUAGE = userenv('LANG')
      and not exists
        (select NULL
        from LNS_INT_RATE_HEADERS_TL T
      where T.INTEREST_RATE_ID = B.INTEREST_RATE_ID
      and T.LANGUAGE = L.LANGUAGE_CODE);

  END ADD_LANGUAGE;


END LNS_INTRATE_HDR_PKG;

/
