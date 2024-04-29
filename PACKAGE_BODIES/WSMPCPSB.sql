--------------------------------------------------------
--  DDL for Package Body WSMPCPSB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSMPCPSB" as
/* $Header: WSMCPSBB.pls 120.2 2006/03/27 20:41:11 mprathap noship $ */

  PROCEDURE Check_Unique(X_rowid               VARCHAR2,
             X_co_product_group_id     NUMBER,
                         X_co_product_id           NUMBER,
                         X_substitute_coprod_id    NUMBER) IS

  x1_dummy  NUMBER; --abedajna
  dummy     NUMBER;

  dupl_sub_coprod_error   EXCEPTION;

  BEGIN

-- commented out by abedajna on 10/12/00 for perf. tuning

/*  SELECT 1 INTO dummy
**  FROM   DUAL
**  WHERE NOT EXISTS
**    ( SELECT 1
**    FROM wsm_co_prod_substitutes
**    WHERE co_product_group_id         = X_co_product_group_id
**    AND   co_product_id               = X_co_product_id
**    AND   substitute_co_product_id    = X_substitute_coprod_id
**    AND  ((X_Rowid IS NULL) OR (ROWID <> X_ROWID)));
**
**  EXCEPTION
**  WHEN NO_DATA_FOUND THEN
**      fnd_message.set_name('WSM','WSM_DUPLICATE_SUB_COPROD');
**      app_exception.raise_exception;
*/

-- modification begin for perf. tuning.. abedajna 10/12/00

  SELECT 1 INTO x1_dummy
  FROM wsm_co_prod_substitutes
  WHERE co_product_group_id         = X_co_product_group_id
  AND   co_product_id               = X_co_product_id
  AND   substitute_co_product_id    = X_substitute_coprod_id
  AND  ((X_Rowid IS NULL) OR (ROWID <> X_ROWID));

  IF x1_dummy <> 0 THEN
    RAISE dupl_sub_coprod_error;
  END IF;


  EXCEPTION

  WHEN dupl_sub_coprod_error THEN
      fnd_message.set_name('WSM','WSM_DUPLICATE_SUB_COPROD');
      app_exception.raise_exception;


  WHEN TOO_MANY_ROWS THEN
      fnd_message.set_name('WSM','WSM_DUPLICATE_SUB_COPROD');
      app_exception.raise_exception;


  WHEN NO_DATA_FOUND THEN
    NULL;


-- modification end for perf. tuning.. abedajna 10/12/00


  END Check_Unique;


PROCEDURE Delete_substitutes (x_co_product_group_id     IN  NUMBER,
                              x_co_product_id           IN  NUMBER) IS
BEGIN

    DELETE FROM WSM_CO_PROD_SUBSTITUTES
    WHERE  co_product_group_id      = x_co_product_group_id
    AND    substitute_co_product_id = x_co_product_id;

END Delete_Substitutes;

END WSMPCPSB;

/
