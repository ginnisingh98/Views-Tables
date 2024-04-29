--------------------------------------------------------
--  DDL for Package Body LNS_LOAN_TYPES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."LNS_LOAN_TYPES_PKG" AS
/*$Header: LNS_LTYPES_TBLH_B.pls 120.0.12010000.1 2008/11/21 12:48:21 mbolli noship $ */

    PROCEDURE ADD_LANGUAGE
    IS
    BEGIN
      delete from LNS_LOAN_TYPES_TL T
      where not exists
        (select NULL
        from LNS_LOAN_TYPES B
        where B.LOAN_TYPE_ID = T.LOAN_TYPE_ID
        );

      update LNS_LOAN_TYPES_TL T set (
          LOAN_TYPE_NAME,
          LOAN_TYPE_DESC
        ) = (select
          B.LOAN_TYPE_NAME,
          B.LOAN_TYPE_DESC
        from LNS_LOAN_TYPES_TL B
        where B.LOAN_TYPE_ID = T.LOAN_TYPE_ID
        and B.LANGUAGE = T.SOURCE_LANG)
      where (
          T.LOAN_TYPE_ID,
          T.LANGUAGE
      ) in (select
          SUBT.LOAN_TYPE_ID,
          SUBT.LANGUAGE
        from LNS_LOAN_TYPES_TL SUBB, LNS_LOAN_TYPES_TL SUBT
        where SUBB.LOAN_TYPE_ID = SUBT.LOAN_TYPE_ID
        and SUBB.LANGUAGE = SUBT.SOURCE_LANG
        and (SUBB.LOAN_TYPE_NAME <> SUBT.LOAN_TYPE_NAME
          or (SUBB.LOAN_TYPE_NAME is null and SUBT.LOAN_TYPE_NAME is not null)
          or (SUBB.LOAN_TYPE_NAME is not null and SUBT.LOAN_TYPE_NAME is null)
          or SUBB.LOAN_TYPE_DESC <> SUBT.LOAN_TYPE_DESC
          or (SUBB.LOAN_TYPE_DESC is null and SUBT.LOAN_TYPE_DESC is not null)
          or (SUBB.LOAN_TYPE_DESC is not null and SUBT.LOAN_TYPE_DESC is null)
      ));

      insert into LNS_LOAN_TYPES_TL (
        LOAN_TYPE_ID,
        LOAN_TYPE_NAME,
        LOAN_TYPE_DESC,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        CREATION_DATE,
        CREATED_BY,
        LAST_UPDATE_LOGIN,
        LANGUAGE,
        SOURCE_LANG
      ) select
        B.LOAN_TYPE_ID,
        B.LOAN_TYPE_NAME,
        B.LOAN_TYPE_DESC,
        B.LAST_UPDATE_DATE,
        B.LAST_UPDATED_BY,
        B.CREATION_DATE,
        B.CREATED_BY,
        B.LAST_UPDATE_LOGIN,
        L.LANGUAGE_CODE,
        B.SOURCE_LANG
      from LNS_LOAN_TYPES_TL B, FND_LANGUAGES L
      where L.INSTALLED_FLAG in ('I', 'B')
      and B.LANGUAGE = userenv('LANG')
      and not exists
        (select NULL
        from LNS_LOAN_TYPES_TL T
        where T.LOAN_TYPE_ID = B.LOAN_TYPE_ID
        and T.LANGUAGE = L.LANGUAGE_CODE);

    END ADD_LANGUAGE;

END LNS_LOAN_TYPES_PKG;

/
