--------------------------------------------------------
--  DDL for Package Body LNS_LOAN_PRODUCTS_ALL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."LNS_LOAN_PRODUCTS_ALL_PKG" AS
/*$Header: LNS_LPROD_TBLH_B.pls 120.0.12010000.2 2008/11/21 14:52:51 mbolli noship $ */

      PROCEDURE ADD_LANGUAGE
      IS
      BEGIN
        delete from LNS_LOAN_PRODUCTS_ALL_TL T
        where not exists
          (select NULL
          from LNS_LOAN_PRODUCTS_ALL B
          where B.LOAN_PRODUCT_ID = T.LOAN_PRODUCT_ID
          );

        update LNS_LOAN_PRODUCTS_ALL_TL T set (
            LOAN_PRODUCT_NAME,
            LOAN_PRODUCT_DESC
          ) = (select
            B.LOAN_PRODUCT_NAME,
            B.LOAN_PRODUCT_DESC
          from LNS_LOAN_PRODUCTS_ALL_TL B
          where B.LOAN_PRODUCT_ID = T.LOAN_PRODUCT_ID
          and B.LANGUAGE = T.SOURCE_LANG)
        where (
            T.LOAN_PRODUCT_ID,
            T.LANGUAGE
        ) in (select
            SUBT.LOAN_PRODUCT_ID,
            SUBT.LANGUAGE
          from LNS_LOAN_PRODUCTS_ALL_TL SUBB, LNS_LOAN_PRODUCTS_ALL_TL SUBT
          where SUBB.LOAN_PRODUCT_ID = SUBT.LOAN_PRODUCT_ID
          and SUBB.LANGUAGE = SUBT.SOURCE_LANG
          and (SUBB.LOAN_PRODUCT_NAME <> SUBT.LOAN_PRODUCT_NAME
            or (SUBB.LOAN_PRODUCT_NAME is null and SUBT.LOAN_PRODUCT_NAME is not null)
            or (SUBB.LOAN_PRODUCT_NAME is not null and SUBT.LOAN_PRODUCT_NAME is null)
            or SUBB.LOAN_PRODUCT_DESC <> SUBT.LOAN_PRODUCT_DESC
            or (SUBB.LOAN_PRODUCT_DESC is null and SUBT.LOAN_PRODUCT_DESC is not null)
            or (SUBB.LOAN_PRODUCT_DESC is not null and SUBT.LOAN_PRODUCT_DESC is null)
        ));

        insert into LNS_LOAN_PRODUCTS_ALL_TL (
          LOAN_PRODUCT_ID,
          LOAN_PRODUCT_NAME,
          LOAN_PRODUCT_DESC,
          LAST_UPDATE_DATE,
          LAST_UPDATED_BY,
          CREATION_DATE,
          CREATED_BY,
          LAST_UPDATE_LOGIN,
          LANGUAGE,
          SOURCE_LANG
        ) select
          B.LOAN_PRODUCT_ID,
          B.LOAN_PRODUCT_NAME,
          B.LOAN_PRODUCT_DESC,
          B.LAST_UPDATE_DATE,
          B.LAST_UPDATED_BY,
          B.CREATION_DATE,
          B.CREATED_BY,
          B.LAST_UPDATE_LOGIN,
          L.LANGUAGE_CODE,
          B.SOURCE_LANG
        from LNS_LOAN_PRODUCTS_ALL_TL B, FND_LANGUAGES L
        where L.INSTALLED_FLAG in ('I', 'B')
        and B.LANGUAGE = userenv('LANG')
        and not exists
          (select NULL
          from LNS_LOAN_PRODUCTS_ALL_TL T
          where T.LOAN_PRODUCT_ID = B.LOAN_PRODUCT_ID
          and T.LANGUAGE = L.LANGUAGE_CODE);

      END ADD_LANGUAGE;

END LNS_LOAN_PRODUCTS_ALL_PKG;

/
