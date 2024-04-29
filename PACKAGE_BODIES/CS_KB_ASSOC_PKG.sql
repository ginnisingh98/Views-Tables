--------------------------------------------------------
--  DDL for Package Body CS_KB_ASSOC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_KB_ASSOC_PKG" AS
/* $Header: cskbasb.pls 115.9 2003/08/28 18:03:57 mkettle noship $ */
/*======================================================================+
 |                Copyright (c) 1999 Oracle Corporation                 |
 |                   Redwood Shores, California, USA                    |
 |                        All rights reserved.                          |
 +======================================================================+
 |   Package Name : CS_KB_ASSOC_PKG                                     |
 |   Package Spec File Name : cskbass.pls                               |
 |   Package Body File Name : cskbasb.pls                               |
 |                                                                      |
 |   PURPOSE:                                                           |
 |               SOLUTION ASSOCIATIONS PACKAGE                          |
 |                                                                      |
 |   NOTES                                                              |
 |                                                                      |
 | History                                                              |
 |  5-16-2001   JAWSMITH Created                                        |
 |  03.27.2003  BAYU     Fix bug 2869963                                |
 |                       Remove hard-coded owner prefix: "CS."          |
 |  09-Jul-2003 MKETTLE  Add Insert into SET_CATEGORIES in clone_link   |
 +======================================================================*/


/****************************************************
-------------FUNCTIONS--------------------------------------------------------------------------
****************************************************/
function Clone_Link(
P_SET_SOURCE_ID in NUMBER,
P_SET_TARGET_ID in NUMBER
)return number IS
  l_count number;
  cursor plat_link_csr is
    select * from cs_kb_set_platforms
    where set_id = p_set_source_id;
  cursor prod_link_csr is
    select * from cs_kb_set_products
    where set_id = p_set_source_id;
  cursor cat_link_csr is
    select * from cs_kb_set_categories
    where set_id = p_set_source_id;

BEGIN

  for rec_plat_link in plat_link_csr loop

  insert into CS_KB_SET_PLATFORMS (
    SET_ID,
    PLATFORM_ID,
    PLATFORM_ORG_ID,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
   ) values (
     P_SET_TARGET_ID,
     REC_PLAT_LINK.PLATFORM_ID,
     REC_PLAT_LINK.PLATFORM_ORG_ID,
     REC_PLAT_LINK.CREATION_DATE,
     REC_PLAT_LINK.CREATED_BY,
     REC_PLAT_LINK.LAST_UPDATE_DATE,
     REC_PLAT_LINK.LAST_UPDATED_BY,
     REC_PLAT_LINK.LAST_UPDATE_LOGIN
   );


  end loop;

  for rec_prod_link in prod_link_csr loop

  insert into CS_KB_SET_PRODUCTS (
    SET_ID,
    PRODUCT_ID,
    PRODUCT_ORG_ID,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
   ) values (
     P_SET_TARGET_ID,
     REC_PROD_LINK.PRODUCT_ID,
     REC_PROD_LINK.PRODUCT_ORG_ID,
     REC_PROD_LINK.CREATION_DATE,
     REC_PROD_LINK.CREATED_BY,
     REC_PROD_LINK.LAST_UPDATE_DATE,
     REC_PROD_LINK.LAST_UPDATED_BY,
     REC_PROD_LINK.LAST_UPDATE_LOGIN
   );

  end loop;

  for rec_cat_link in cat_link_csr loop

  insert into CS_KB_SET_CATEGORIES (
    SET_ID,
    CATEGORY_ID,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    ATTRIBUTE_CATEGORY,
    ATTRIBUTE1,
    ATTRIBUTE2,
    ATTRIBUTE3,
    ATTRIBUTE4,
    ATTRIBUTE5,
    ATTRIBUTE6,
    ATTRIBUTE7,
    ATTRIBUTE8,
    ATTRIBUTE9,
    ATTRIBUTE10,
    ATTRIBUTE11,
    ATTRIBUTE12,
    ATTRIBUTE13,
    ATTRIBUTE14,
    ATTRIBUTE15

   ) values (
     P_SET_TARGET_ID,
     REC_CAT_LINK.CATEGORY_ID,
     REC_CAT_LINK.CREATION_DATE,
     REC_CAT_LINK.CREATED_BY,
     REC_CAT_LINK.LAST_UPDATE_DATE,
     REC_CAT_LINK.LAST_UPDATED_BY,
     REC_CAT_LINK.LAST_UPDATE_LOGIN,
     REC_CAT_LINK.ATTRIBUTE_CATEGORY,
     REC_CAT_LINK.ATTRIBUTE1,
     REC_CAT_LINK.ATTRIBUTE2,
     REC_CAT_LINK.ATTRIBUTE3,
     REC_CAT_LINK.ATTRIBUTE4,
     REC_CAT_LINK.ATTRIBUTE5,
     REC_CAT_LINK.ATTRIBUTE6,
     REC_CAT_LINK.ATTRIBUTE7,
     REC_CAT_LINK.ATTRIBUTE8,
     REC_CAT_LINK.ATTRIBUTE9,
     REC_CAT_LINK.ATTRIBUTE10,
     REC_CAT_LINK.ATTRIBUTE11,
     REC_CAT_LINK.ATTRIBUTE12,
     REC_CAT_LINK.ATTRIBUTE13,
     REC_CAT_LINK.ATTRIBUTE14,
     REC_CAT_LINK.ATTRIBUTE15
   );

  end loop;

  return OKAY_STATUS;

  <<error_found>>
  return ERROR_STATUS;

   EXCEPTION
    WHEN OTHERS THEN
        RAISE;

END Clone_Link;



/*********************************** ADD LINK ********************************
--   This procedure adds AND deletes rows from two seperate link tables.
-- The tables both are very similar and serve as link tables for solutions.
-- Because this procedure is flexible, it require a couple of flags.  Those
-- variables are as follows:
--
--    P_LINK_TYPE:
--    0 = CS_KB_SET_PLATFORMS
--    1 = CS_KB_SET_PRODUCTS
--
--    P_TASK:
--    0 = REMOVE
--    1 = ADD
--
--    P_RESULT:
--    0 = general error
--    1 = everything fine.
--    2 = no valid table to insert into.
******************************************************************************/

   PROCEDURE add_link(
       p_item_id IN JTF_NUMBER_TABLE,
       p_org_id  IN JTF_NUMBER_TABLE,
       p_set_id  IN NUMBER,
       p_link_type  IN NUMBER,
       p_task IN NUMBER,
       p_result OUT NOCOPY NUMBER
   ) IS

    -- Vars to hold sql statement
    sqlStatement VARCHAR2(200);
    a_sql VARCHAR2(100) := 'CREATION_DATE,CREATED_BY,LAST_UPDATE_DATE,LAST_UPDATED_BY) VALUES(:S,:P,:O,:D,:U,:D,:U)';

    -- Var to hold cursor value for sql statement
    stmt INTEGER;
    cursorReturn INTEGER;

    -- Loop control variables
    length INTEGER;
    counter INTEGER;


   BEGIN
    p_result := 1;
    -- Getting table name
    IF (p_link_type = 0) AND (p_task = 0) THEN
        sqlStatement := 'DELETE FROM CS_KB_SET_PLATFORMS WHERE SET_ID = :S AND PLATFORM_ID = :P AND PLATFORM_ORG_ID = :O';
    ELSIF (p_link_type = 0) AND (p_task = 1) THEN
        sqlStatement := 'INSERT INTO CS_KB_SET_PLATFORMS(SET_ID,PLATFORM_ID,PLATFORM_ORG_ID,'||a_sql;
    ELSIF (p_link_type = 1) AND (p_task = 0) THEN
        sqlStatement := 'DELETE FROM CS_KB_SET_PRODUCTS WHERE SET_ID = :S AND PRODUCT_ID = :P AND PRODUCT_ORG_ID = :O';
    ELSIF (p_link_type = 1) AND (p_task = 1) THEN
        sqlStatement := 'INSERT INTO CS_KB_SET_PRODUCTS(SET_ID,PRODUCT_ID,PRODUCT_ORG_ID,'||a_sql;
    END IF;

    IF (sqlStatement is not null) THEN
        length := p_item_id.COUNT;
        stmt := DBMS_SQL.OPEN_CURSOR;
        DBMS_SQL.PARSE(stmt, sqlStatement, DBMS_SQL.V7);

        -- shared bind variable
        DBMS_SQL.BIND_VARIABLE(stmt, ':S', p_set_id);

        -- bind variables (used only with creating links)
        IF (p_task = 1) THEN
            DBMS_SQL.BIND_VARIABLE(stmt, ':D', sysdate);
            DBMS_SQL.BIND_VARIABLE(stmt, ':U', fnd_global.user_id);
        END IF;

        FOR counter IN 1..length LOOP
            -- bind variables (temporary)
            DBMS_SQL.BIND_VARIABLE(stmt, ':P', p_item_id(counter));
            DBMS_SQL.BIND_VARIABLE(stmt, ':O', p_org_id(counter));
            -- execute everytime in loop
            cursorReturn := DBMS_SQL.EXECUTE(stmt);
        END LOOP;

        -- Clean up!
        DBMS_SQL.CLOSE_CURSOR(stmt);
        --p_result := 1;
    ELSE
        p_result := 2;
    END IF;
   EXCEPTION
    WHEN OTHERS THEN
        DBMS_SQL.CLOSE_CURSOR(stmt);
        p_result := 0;
        RAISE;
   END;


END;

/
