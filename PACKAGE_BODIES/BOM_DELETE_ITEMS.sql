--------------------------------------------------------
--  DDL for Package Body BOM_DELETE_ITEMS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BOM_DELETE_ITEMS" AS
/* $Header: BOMDELTB.pls 120.1 2005/06/08 15:28:05 appldev  $ */
-- +==========================================================================+
-- | Copyright (c) 1993 Oracle Corporation Belmont, California, USA           |
-- |                          All rights reserved.                            |
-- +==========================================================================+
-- |                                                                          |
-- | File Name   : BOMDELTB.pls                                               |
-- | Description : Populate BOM_DELETE_ENTITIES and BOM_DELETE_SUB_ENTITIES   |
-- |               when called by BOMFDDEL (Item, BOM and Routing Delete Form |
-- |               under the following conditions:                            |
-- |               - called on return from Item Catalog Search                |
-- |               - Component or Routing Where Used request                  |
-- |               - Master Org to Child Org explosion                        |
-- |               - BOM and Routing explosion                                |
-- | Parameters  : org_id organization_id                                     |
-- |               err_msg  error message out buffer                          |
-- |               error_code error code out. returns sql error code          |
-- |                          if sql error.                                   |
-- | Revision                                                                 |
-- |  08-MAR-95 Anand Rajaraman Creation                                      |
-- |  07-JUL-95 Anand Rajaraman Changes after Code Review (Shreyas Shah)      |
-- |                            Removed expiration_time (Calvin Siew)         |
-- |                                                                          |
-- +==========================================================================+

-- +--------------------------- RAISE_ERROR ----------------------------------+

-- NAME
-- RAISE_ERROR

-- DESCRIPTION
-- Raise generic error message. For sql error failures, places the SQLERRM
-- error on the message stack

-- REQUIRES
-- func_name: function name
-- stmt_num : statement number

-- OUTPUT

-- NOTES

-- +--------------------------------------------------------------------------+

PROCEDURE RAISE_ERROR (
func_name VARCHAR2,
stmt_num  NUMBER
)
IS
err_text  VARCHAR2(1000);
BEGIN
  ROLLBACK;
  err_text := func_name || '(' || stmt_num || ') ' || SQLERRM;
  FND_MESSAGE.SET_NAME('BOM', 'BOM_SQL_ERR');
  FND_MESSAGE.SET_TOKEN('entity', err_text);
  APP_EXCEPTION.RAISE_EXCEPTION;
  EXCEPTION
    WHEN OTHERS THEN
      NULL;
END RAISE_ERROR;


-- +-------------------------- UPDATE_UNPROCESSED_ROWS -----------------------+

-- NAME
-- UPDATE_UNPROCESSED_ROWS

-- DESCRIPTION
-- Update all unprocessed rows that exist, to be processed for this group_id

-- REQUIRES
-- delete_group_id

-- OUTPUT

-- RETURNS

-- NOTES

-- +--------------------------------------------------------------------------+

PROCEDURE UPDATE_UNPROCESSED_ROWS
(
delete_group_id   IN NUMBER
)
IS
BEGIN
  UPDATE BOM_DELETE_ENTITIES
  SET PRIOR_process_flag = 1
  WHERE DELETE_GROUP_SEQUENCE_ID = delete_group_id
  AND PRIOR_process_flag = 2;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE_ERROR(
        func_name => 'UPDATE_UNPROCESSED_ROWS',
        stmt_num  => 1);
END UPDATE_UNPROCESSED_ROWS;


-- +------------------------------- POPULATE_DELETE --------------------------+

-- NAME
-- POPULATE_DELETE

-- DESCRIPTION
-- Populate BOM_DELETE_ENTITIES and BOM_DELETE_SUB_ENTITIES

-- REQUIRES
-- org_id: organization id
-- last_login_id
-- catalog_search_id: Item catalog search id
-- component_id
-- delete_group_id
-- delete_type
-- "1" - ITEM
-- "2" - BOM
-- "3" - ROUTING
-- "4" - COMPONENT
-- "5" - OPERATION
-- "6" - BOM and ROUTING
-- "7" - ITEM/BOM and ROUTING
-- del_grp_type
-- "1" - Non-ENG Items only
-- "2" - ENG Items only
-- process_type
-- "1" - called from form
-- "2" - called from search region
-- expiration_date

-- OUTPUT

-- RETURNS

-- NOTES

-- +--------------------------------------------------------------------------+

PROCEDURE POPULATE_DELETE
(
org_id      IN NUMBER,
last_login_id   IN NUMBER DEFAULT -1,
catalog_search_id IN NUMBER,
component_id    IN NUMBER,
delete_group_id   IN NUMBER,
delete_type   IN NUMBER,
del_grp_type    IN NUMBER,
process_type    IN NUMBER,
expiration_date   IN DATE) IS

invalid_parameter EXCEPTION;
finale      EXCEPTION;
stmt_num    NUMBER;
var_text    VARCHAR2(1000);
process_flag    NUMBER; -- =1 FOR PROCESSED, =2 FOR NOT PROCESSED
eng_flag    NUMBER; -- =1 FOR NON-ENG ITEMS, =2 FOR ENG ITEMS
item_eng_flag   CHAR;
commit_flag   NUMBER; -- =1 IF ON COMMIT FROM FORM
                                -- =2 IF FROM SEARCH REGION
del_stat_type   NUMBER;
master_org_flag CHAR;
userid  NUMBER;
BEGIN

  userid := FND_GLOBAL.USER_ID ;
  -- process_flag = 2 MEANS NOT PROCESSED, SO ROWS STORED IN MASTER ORG
  -- EXPLOSION WILL BE PROCESSED BY BOM AND ROUTING EXPLOSION

  IF delete_type = 1 THEN
    process_flag := 1;
  ELSIF delete_type = 7 THEN
    process_flag := 2;
  END IF;

  stmt_num := 1;
  eng_flag := del_grp_type;
  IF eng_flag = 1 THEN
    item_eng_flag := 'N';
  ELSIF eng_flag = 2 THEN
    item_eng_flag := 'Y';
  ELSE
    var_text := 'delete group type';
    RAISE invalid_parameter;
  END IF;

  stmt_num := 2;
  commit_flag := 0;
  IF process_type = 1 THEN
    commit_flag := 2;
  ELSIF process_type = 2 THEN
    commit_flag := 1;
  ELSE
    var_text := 'process type';
    RAISE invalid_parameter;
  END IF;

  stmt_num := 3;
  IF delete_type IN (1, 2, 3, 7) THEN
    del_stat_type := 1;
  ELSIF delete_type IN (4, 5, 6) THEN
    del_stat_type := -1;
  ELSE
    var_text := 'delete type';
    RAISE invalid_parameter;
  END IF;

  IF process_type = 1 THEN

    -- CATALOG SEARCH: GET ITEMS FROM MTL_CATALOG_SEARCH_ITEMS

    IF catalog_search_id > 0 THEN
      stmt_num := 4;

      -- CASE 1 ITEM
      -- CASE 6 BOM AND ROUTING
      -- CASE 7 ITEM/BOM AND ROUTING

      IF delete_type IN (1, 6, 7) THEN
        INSERT INTO BOM_DELETE_ENTITIES(
          DELETE_ENTITY_SEQUENCE_ID,
          DELETE_GROUP_SEQUENCE_ID,
          DELETE_ENTITY_TYPE,
          INVENTORY_ITEM_ID,
    ORGANIZATION_ID,
    ALTERNATE_DESIGNATOR,
    ITEM_DESCRIPTION,
    ITEM_CONCAT_SEGMENTS,
    DELETE_STATUS_TYPE,
    PRIOR_PROCESS_FLAG,
    PRIOR_COMMIT_FLAG,
    BILL_SEQUENCE_ID,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN)
        SELECT
          BOM_DELETE_ENTITIES_S.NEXTVAL,
    delete_group_id,
    1,
    MCSI.INVENTORY_ITEM_ID,
    MCSI.ORGANIZATION_ID,
    '',
    MCSI.DESCRIPTION,
    MIF.ITEM_NUMBER,
    del_stat_type,
    2,
    commit_flag,
    '',
    SYSDATE,
    userid,
    SYSDATE,
    userid,
    last_login_id
        FROM
          MTL_CATALOG_SEARCH_ITEMS MCSI,
          MTL_SYSTEM_ITEMS MSI,
          MTL_ITEM_FLEXFIELDS MIF
        WHERE MSI.INVENTORY_ITEM_ID = MCSI.INVENTORY_ITEM_ID
        AND MSI.ORGANIZATION_ID = MCSI.ORGANIZATION_ID
        AND MIF.ITEM_ID = MCSI.INVENTORY_ITEM_ID
        AND MIF.ORGANIZATION_ID = MCSI.ORGANIZATION_ID
        AND MCSI.ORGANIZATION_ID = org_id
        AND MSI.ENG_ITEM_FLAG = DECODE(delete_type, 1, item_eng_flag,
                                       7, item_eng_flag, MSI.ENG_ITEM_FLAG)
        AND MCSI.GROUP_HANDLE_ID = catalog_search_id
        AND MCSI.INVENTORY_ITEM_ID NOT IN(
          SELECT DISTINCT INVENTORY_ITEM_ID
          FROM BOM_DELETE_ENTITIES
          WHERE DELETE_GROUP_SEQUENCE_ID = delete_group_id
          AND ORGANIZATION_ID = org_id);

        DELETE MTL_CATALOG_SEARCH_ITEMS
        WHERE GROUP_HANDLE_ID = catalog_search_id;

        -- CASE 2 BOM
        -- CASE 4 COMPONENT

      ELSIF delete_type IN (2, 4) THEN
        INSERT INTO BOM_DELETE_ENTITIES(
          DELETE_ENTITY_SEQUENCE_ID,
          DELETE_GROUP_SEQUENCE_ID,
          DELETE_ENTITY_TYPE,
          INVENTORY_ITEM_ID,
          ORGANIZATION_ID,
          ALTERNATE_DESIGNATOR,
          ITEM_DESCRIPTION,
          ITEM_CONCAT_SEGMENTS,
          DELETE_STATUS_TYPE,
          PRIOR_PROCESS_FLAG,
          PRIOR_COMMIT_FLAG,
          BILL_SEQUENCE_ID,
          LAST_UPDATE_DATE,
          LAST_UPDATED_BY,
          CREATION_DATE,
          CREATED_BY,
          LAST_UPDATE_LOGIN)
        SELECT
          BOM_DELETE_ENTITIES_S.NEXTVAL,
          delete_group_id,
          2,
          BOM.ASSEMBLY_ITEM_ID,
          BOM.ORGANIZATION_ID,
          BOM.ALTERNATE_BOM_DESIGNATOR,
          MCSI.DESCRIPTION,
          MIF.ITEM_NUMBER,
          del_stat_type,
          2,
          commit_flag,
          BOM.BILL_SEQUENCE_ID,
          SYSDATE,
          userid,
          SYSDATE,
          userid,
          last_login_id
        FROM
          MTL_CATALOG_SEARCH_ITEMS MCSI,
          BOM_BILL_OF_MATERIALS BOM,
          MTL_ITEM_FLEXFIELDS MIF
        WHERE MCSI.INVENTORY_ITEM_ID = BOM.ASSEMBLY_ITEM_ID
        AND MCSI.ORGANIZATION_ID = BOM.ORGANIZATION_ID
        AND MIF.ITEM_ID = MCSI.INVENTORY_ITEM_ID
        AND MIF.ORGANIZATION_ID = MCSI.ORGANIZATION_ID
        AND MCSI.ORGANIZATION_ID = org_id
        AND BOM.ASSEMBLY_TYPE = eng_flag
        AND MCSI.GROUP_HANDLE_ID = catalog_search_id
        AND BOM.BILL_SEQUENCE_ID NOT IN(
          SELECT NVL(BILL_SEQUENCE_ID, 0)
          FROM BOM_DELETE_ENTITIES
          WHERE DELETE_GROUP_SEQUENCE_ID = delete_group_id);

        DELETE MTL_CATALOG_SEARCH_ITEMS
        WHERE GROUP_HANDLE_ID = catalog_search_id;

      -- CASE 3 ROUTING
      -- CASE 5 OPERATION

      ELSIF delete_type IN (3, 5) THEN
        INSERT INTO BOM_DELETE_ENTITIES(
          DELETE_ENTITY_SEQUENCE_ID,
    DELETE_GROUP_SEQUENCE_ID,
    DELETE_ENTITY_TYPE,
    INVENTORY_ITEM_ID,
    ORGANIZATION_ID,
    ALTERNATE_DESIGNATOR,
    ITEM_DESCRIPTION,
    ITEM_CONCAT_SEGMENTS,
    DELETE_STATUS_TYPE,
    PRIOR_PROCESS_FLAG,
    PRIOR_COMMIT_FLAG,
    ROUTING_SEQUENCE_ID,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN)
        SELECT
          BOM_DELETE_ENTITIES_S.NEXTVAL,
    delete_group_id,
    3,
    BOR.ASSEMBLY_ITEM_ID,
    BOR.ORGANIZATION_ID,
    BOR.ALTERNATE_ROUTING_DESIGNATOR,
    MCSI.DESCRIPTION,
    MIF.ITEM_NUMBER,
    del_stat_type,
    2,
    commit_flag,
    BOR.ROUTING_SEQUENCE_ID,
    SYSDATE,
    userid,
    SYSDATE,
    userid,
    last_login_id
        FROM
          MTL_CATALOG_SEARCH_ITEMS MCSI,
          BOM_OPERATIONAL_ROUTINGS BOR,
          MTL_ITEM_FLEXFIELDS MIF
        WHERE MCSI.ORGANIZATION_ID = org_id
        AND MCSI.INVENTORY_ITEM_ID = BOR.ASSEMBLY_ITEM_ID
  AND MCSI.ORGANIZATION_ID = BOR.ORGANIZATION_ID
  AND MIF.ITEM_ID = MCSI.INVENTORY_ITEM_ID
  AND MIF.ORGANIZATION_ID = MCSI.ORGANIZATION_ID
  AND BOR.ROUTING_TYPE = eng_flag
  AND MCSI.GROUP_HANDLE_ID = catalog_search_id
  AND BOR.ROUTING_SEQUENCE_ID NOT IN(
          SELECT NVL(ROUTING_SEQUENCE_ID, 0)
          FROM BOM_DELETE_ENTITIES
          WHERE DELETE_GROUP_SEQUENCE_ID = delete_group_id
          AND ORGANIZATION_ID = org_id);
        DELETE MTL_CATALOG_SEARCH_ITEMS
        WHERE GROUP_HANDLE_ID = catalog_search_id;

    ELSE
      var_text := 'catalog search id';
      RAISE invalid_parameter;
    END IF;  -- END OF CATALOG SEARCH

  -- COMPONENT OR OPERATION WHERE USED SEARCH

  ELSE
    stmt_num := 5;

    -- COMPONENT WHERE USED

    IF delete_type = 4 THEN

      -- COMPONENT ID: NULL, EXPIRATION DATE: NOT NULL

      IF component_id <= 0 THEN
        INSERT INTO BOM_DELETE_ENTITIES(
          DELETE_ENTITY_SEQUENCE_ID,
    DELETE_GROUP_SEQUENCE_ID,
    DELETE_ENTITY_TYPE,
    INVENTORY_ITEM_ID,
    ORGANIZATION_ID,
    ALTERNATE_DESIGNATOR,
    ITEM_DESCRIPTION,
    ITEM_CONCAT_SEGMENTS,
    PRIOR_PROCESS_FLAG,
    PRIOR_COMMIT_FLAG,
    BILL_SEQUENCE_ID,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN)
        SELECT
          BOM_DELETE_ENTITIES_S.NEXTVAL,
    delete_group_id,
    2,
    BOM.ASSEMBLY_ITEM_ID,
    BOM.ORGANIZATION_ID,
    BOM.ALTERNATE_BOM_DESIGNATOR,
    MSI.DESCRIPTION,
    MIF.ITEM_NUMBER,
    1,
    commit_flag,
    BOM.BILL_SEQUENCE_ID,
    SYSDATE,
    userid,
    SYSDATE,
    userid,
    last_login_id
        FROM
          BOM_BILL_OF_MATERIALS BOM,
          MTL_SYSTEM_ITEMS MSI,
          MTL_ITEM_FLEXFIELDS MIF
        WHERE MSI.INVENTORY_ITEM_ID = BOM.ASSEMBLY_ITEM_ID
        AND MSI.ORGANIZATION_ID = BOM.ORGANIZATION_ID
        AND MIF.ITEM_ID = BOM.ASSEMBLY_ITEM_ID
        AND MIF.ORGANIZATION_ID = BOM.ORGANIZATION_ID
        AND BOM.BILL_SEQUENCE_ID IN(
          SELECT DISTINCT BOM.BILL_SEQUENCE_ID
          FROM
            BOM_BILL_OF_MATERIALS BOM,
            BOM_INVENTORY_COMPONENTS BIC
          WHERE BOM.BILL_SEQUENCE_ID = BIC.BILL_SEQUENCE_ID
          AND BOM.ORGANIZATION_ID = org_id
          AND BOM.ASSEMBLY_TYPE = eng_flag
          AND expiration_date >= BIC.DISABLE_DATE
          AND BOM.BILL_SEQUENCE_ID NOT IN(
            SELECT NVL(BILL_SEQUENCE_ID, 0)
            FROM BOM_DELETE_ENTITIES
            WHERE DELETE_GROUP_SEQUENCE_ID = delete_group_id));

        INSERT INTO BOM_DELETE_SUB_ENTITIES(
          DELETE_ENTITY_SEQUENCE_ID,
    COMPONENT_SEQUENCE_ID,
    OPERATION_SEQ_NUM,
    EFFECTIVITY_DATE,
    COMPONENT_ITEM_ID,
    COMPONENT_CONCAT_SEGMENTS,
    ITEM_NUM,
    DISABLE_DATE,
    DESCRIPTION,
    DELETE_STATUS_TYPE,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN)
        SELECT
          BDE.DELETE_ENTITY_SEQUENCE_ID,
    BIC.COMPONENT_SEQUENCE_ID,
    BIC.OPERATION_SEQ_NUM,
    BIC.EFFECTIVITY_DATE,
    BIC.COMPONENT_ITEM_ID,
    MIF.ITEM_NUMBER,
    BIC.ITEM_NUM,
    BIC.DISABLE_DATE,
    MSI.DESCRIPTION,
    1,
    SYSDATE,
    userid,
    SYSDATE,
    userid,
    last_login_id
        FROM
          BOM_INVENTORY_COMPONENTS BIC,
          BOM_DELETE_ENTITIES BDE,
          BOM_BILL_OF_MATERIALS BOM,
          MTL_SYSTEM_ITEMS MSI,
          MTL_ITEM_FLEXFIELDS MIF
        WHERE BOM.BILL_SEQUENCE_ID = BIC.BILL_SEQUENCE_ID
        AND BDE.BILL_SEQUENCE_ID = BIC.BILL_SEQUENCE_ID
        AND MSI.INVENTORY_ITEM_ID = BIC.COMPONENT_ITEM_ID
        AND MSI.ORGANIZATION_ID = BOM.ORGANIZATION_ID
        AND MIF.ITEM_ID = BIC.COMPONENT_ITEM_ID
        AND MIF.ORGANIZATION_ID = BOM.ORGANIZATION_ID
        AND BOM.ASSEMBLY_TYPE = eng_flag
        AND BDE.DELETE_GROUP_SEQUENCE_ID = delete_group_id
        AND expiration_date >= BIC.DISABLE_DATE
        AND BIC.COMPONENT_SEQUENCE_ID NOT IN(
          SELECT NVL(COMPONENT_SEQUENCE_ID, 0)
          FROM
            BOM_DELETE_SUB_ENTITIES BDSE,
            BOM_DELETE_ENTITIES BDE
          WHERE BDE.DELETE_GROUP_SEQUENCE_ID = delete_group_id
          AND BDE.DELETE_ENTITY_SEQUENCE_ID = BDSE.DELETE_ENTITY_SEQUENCE_ID);

      -- COMPONENT ID: NOT NULL, EXPIRATION DATE: NOT NULL OR NULL

      -- THE EXPIRATION_DATE/DISABLE_DATE WHERE CLAUSE BELOW IS OBSCURE
      -- EXPECTED BEHAVIOR:
      -- EXPIRATION_DATE DISABLE_DATE BEHAVIOR
      -- --------------- ------------ --------
      -- NOT NULL        NOT NULL     RETAIN ROW IF EXPIRATION_DATE
      --                              >= BIC.DISABLE_DATE
      -- NOT NULL        NULL         DROP ROW
      -- NULL            NOT NULL     RETAIN ROW
      -- NULL            NULL         RETAIN ROW

      ELSE
        INSERT INTO BOM_DELETE_ENTITIES(
          DELETE_ENTITY_SEQUENCE_ID,
          DELETE_GROUP_SEQUENCE_ID,
          DELETE_ENTITY_TYPE,
          INVENTORY_ITEM_ID,
          ORGANIZATION_ID,
          ALTERNATE_DESIGNATOR,
          ITEM_DESCRIPTION,
          ITEM_CONCAT_SEGMENTS,
          PRIOR_PROCESS_FLAG,
          PRIOR_COMMIT_FLAG,
          BILL_SEQUENCE_ID,
          LAST_UPDATE_DATE,
          LAST_UPDATED_BY,
          CREATION_DATE,
          CREATED_BY,
          LAST_UPDATE_LOGIN)
        SELECT
          BOM_DELETE_ENTITIES_S.NEXTVAL,
          delete_group_id,
          2,
          BOM.ASSEMBLY_ITEM_ID,
          BOM.ORGANIZATION_ID,
          BOM.ALTERNATE_BOM_DESIGNATOR,
          MSI.DESCRIPTION,
          MIF.ITEM_NUMBER,
          1,
          commit_flag,
          BOM.BILL_SEQUENCE_ID,
          SYSDATE,
          userid,
          SYSDATE,
          userid,
          last_login_id
        FROM
          BOM_BILL_OF_MATERIALS BOM,
          MTL_SYSTEM_ITEMS MSI,
          MTL_ITEM_FLEXFIELDS MIF
        WHERE MSI.INVENTORY_ITEM_ID = BOM.ASSEMBLY_ITEM_ID
        AND MSI.ORGANIZATION_ID = BOM.ORGANIZATION_ID
        AND MIF.ITEM_ID = BOM.ASSEMBLY_ITEM_ID
        AND MIF.ORGANIZATION_ID = BOM.ORGANIZATION_ID
        AND BOM.BILL_SEQUENCE_ID IN(
          SELECT DISTINCT BOM.BILL_SEQUENCE_ID
          FROM
            BOM_BILL_OF_MATERIALS BOM,
            BOM_INVENTORY_COMPONENTS BIC
          WHERE BOM.BILL_SEQUENCE_ID = BIC.BILL_SEQUENCE_ID
          AND BOM.ORGANIZATION_ID = org_id
          AND BOM.ASSEMBLY_TYPE = eng_flag
          AND BIC.COMPONENT_ITEM_ID = component_id
          AND NVL(expiration_date, NVL(BIC.DISABLE_DATE, TRUNC(SYSDATE))) >=
              NVL(BIC.DISABLE_DATE, NVL(expiration_date+1, TRUNC(SYSDATE)))
          AND BOM.BILL_SEQUENCE_ID NOT IN(
            SELECT NVL(BILL_SEQUENCE_ID, 0)
            FROM BOM_DELETE_ENTITIES
            WHERE DELETE_GROUP_SEQUENCE_ID = delete_group_id));

        -- THE EXPIRATION_DATE/DISABLE_DATE WHERE CLAUSE BELOW IS OBSCURE
        -- EXPECTED BEHAVIOR:
        -- EXPIRATION_DATE DISABLE_DATE BEHAVIOR
        -- --------------- ------------ --------
        -- NOT NULL        NOT NULL     RETAIN ROW IF EXPIRATION_DATE
        --                              >= BIC.DISABLE_DATE
        -- NOT NULL        NULL         DROP ROW
        -- NULL            NOT NULL     RETAIN ROW
        -- NULL            NULL         RETAIN ROW

        INSERT INTO BOM_DELETE_SUB_ENTITIES(
          DELETE_ENTITY_SEQUENCE_ID,
          COMPONENT_SEQUENCE_ID,
          OPERATION_SEQ_NUM,
          EFFECTIVITY_DATE,
          COMPONENT_ITEM_ID,
          COMPONENT_CONCAT_SEGMENTS,
          ITEM_NUM,
          DISABLE_DATE,
          DESCRIPTION,
          DELETE_STATUS_TYPE,
          LAST_UPDATE_DATE,
          LAST_UPDATED_BY,
          CREATION_DATE,
          CREATED_BY,
          LAST_UPDATE_LOGIN)
        SELECT
          BDE.DELETE_ENTITY_SEQUENCE_ID,
          BIC.COMPONENT_SEQUENCE_ID,
          BIC.OPERATION_SEQ_NUM,
          BIC.EFFECTIVITY_DATE,
          BIC.COMPONENT_ITEM_ID,
          MIF.ITEM_NUMBER,
          BIC.ITEM_NUM,
          BIC.DISABLE_DATE,
          MSI.DESCRIPTION,
          1,
          SYSDATE,
          userid,
          SYSDATE,
          userid,
          last_login_id
        FROM
          BOM_INVENTORY_COMPONENTS BIC,
          BOM_DELETE_ENTITIES BDE,
          BOM_BILL_OF_MATERIALS BOM,
          MTL_SYSTEM_ITEMS MSI,
          MTL_ITEM_FLEXFIELDS MIF
        WHERE BOM.BILL_SEQUENCE_ID = BIC.BILL_SEQUENCE_ID
        AND BDE.BILL_SEQUENCE_ID = BIC.BILL_SEQUENCE_ID
        AND MSI.INVENTORY_ITEM_ID = BIC.COMPONENT_ITEM_ID
        AND MSI.ORGANIZATION_ID = BOM.ORGANIZATION_ID
        AND MIF.ITEM_ID = BIC.COMPONENT_ITEM_ID
        AND MIF.ORGANIZATION_ID = BOM.ORGANIZATION_ID
        AND BOM.ASSEMBLY_TYPE = eng_flag
        AND BDE.DELETE_GROUP_SEQUENCE_ID = delete_group_id
        AND BIC.COMPONENT_ITEM_ID = component_id
        AND NVL(expiration_date, NVL(BIC.DISABLE_DATE,TRUNC(SYSDATE))) >=
            NVL(BIC.DISABLE_DATE, NVL(expiration_date + 1, TRUNC(SYSDATE)))
        AND BIC.COMPONENT_SEQUENCE_ID NOT IN(
          SELECT NVL(COMPONENT_SEQUENCE_ID, 0)
          FROM
            BOM_DELETE_SUB_ENTITIES BDSE,
            BOM_DELETE_ENTITIES BDE
          WHERE BDE.DELETE_GROUP_SEQUENCE_ID = delete_group_id
          AND BDE.DELETE_ENTITY_SEQUENCE_ID = BDSE.DELETE_ENTITY_SEQUENCE_ID);
      END IF;  -- END OF COMPONENT WHERE USED SEARCH
      RAISE finale;

      -- OPERATION WHERE USED

      ELSIF delete_type = 5 THEN
        INSERT INTO BOM_DELETE_ENTITIES(
          DELETE_ENTITY_SEQUENCE_ID,
          DELETE_GROUP_SEQUENCE_ID,
          DELETE_ENTITY_TYPE,
          INVENTORY_ITEM_ID,
          ORGANIZATION_ID,
          ALTERNATE_DESIGNATOR,
          ITEM_DESCRIPTION,
          ITEM_CONCAT_SEGMENTS,
          PRIOR_PROCESS_FLAG,
          PRIOR_COMMIT_FLAG,
          ROUTING_SEQUENCE_ID,
          LAST_UPDATE_DATE,
          LAST_UPDATED_BY,
          CREATION_DATE,
          CREATED_BY,
          LAST_UPDATE_LOGIN)
        SELECT
          BOM_DELETE_ENTITIES_S.NEXTVAL,
          delete_group_id,
          3,
          BOR.ASSEMBLY_ITEM_ID,
          BOR.ORGANIZATION_ID,
          BOR.ALTERNATE_ROUTING_DESIGNATOR,
          MSI.DESCRIPTION,
          MIF.ITEM_NUMBER,
          1,
          commit_flag,
          BOR.ROUTING_SEQUENCE_ID,
          SYSDATE,
          userid,
          SYSDATE,
          userid,
          last_login_id
        FROM
          BOM_OPERATIONAL_ROUTINGS BOR,
          MTL_SYSTEM_ITEMS MSI,
          MTL_ITEM_FLEXFIELDS MIF
        WHERE BOR.ORGANIZATION_ID = org_id
        AND MSI.INVENTORY_ITEM_ID = BOR.ASSEMBLY_ITEM_ID
        AND MSI.ORGANIZATION_ID = BOR.ORGANIZATION_ID
        AND MIF.ITEM_ID = BOR.ASSEMBLY_ITEM_ID
        AND MIF.ORGANIZATION_ID = BOR.ORGANIZATION_ID
        AND BOR.ROUTING_TYPE = eng_flag
        AND BOR.ROUTING_SEQUENCE_ID IN(
          SELECT DISTINCT BOS.ROUTING_SEQUENCE_ID
          FROM
            BOM_OPERATIONAL_ROUTINGS BOR,
            BOM_OPERATION_SEQUENCES BOS
          WHERE BOR.ROUTING_SEQUENCE_ID = BOS.ROUTING_SEQUENCE_ID
          AND BOS.DISABLE_DATE <= expiration_date
          AND BOS.ROUTING_SEQUENCE_ID NOT IN(
            SELECT NVL(ROUTING_SEQUENCE_ID, 0)
            FROM BOM_DELETE_ENTITIES
            WHERE DELETE_GROUP_SEQUENCE_ID = delete_group_id));

        INSERT INTO BOM_DELETE_SUB_ENTITIES(
          DELETE_ENTITY_SEQUENCE_ID,
          OPERATION_SEQUENCE_ID,
          OPERATION_SEQ_NUM,
          EFFECTIVITY_DATE,
          DISABLE_DATE,
          DESCRIPTION,
          OPERATION_DEPARTMENT_CODE,
          DELETE_STATUS_TYPE,
          LAST_UPDATE_DATE,
          LAST_UPDATED_BY,
          CREATION_DATE,
          CREATED_BY,
          LAST_UPDATE_LOGIN)
        SELECT
          BDE.DELETE_ENTITY_SEQUENCE_ID,
          BOS.OPERATION_SEQUENCE_ID,
          BOS.OPERATION_SEQ_NUM,
          BOS.EFFECTIVITY_DATE,
          BOS.DISABLE_DATE,
          BOS.OPERATION_DESCRIPTION,
          BD.DEPARTMENT_CODE,
          1,
          SYSDATE,
          userid,
          SYSDATE,
          userid,
          last_login_id
        FROM
          BOM_OPERATION_SEQUENCES BOS,
          BOM_DELETE_ENTITIES BDE,
          BOM_OPERATIONAL_ROUTINGS BOR,
          BOM_DEPARTMENTS BD
        WHERE BOR.ROUTING_SEQUENCE_ID = BOS.ROUTING_SEQUENCE_ID
        AND BDE.ROUTING_SEQUENCE_ID = BOS.ROUTING_SEQUENCE_ID
        AND BOR.ROUTING_TYPE = eng_flag
        AND BDE.DELETE_GROUP_SEQUENCE_ID = delete_group_id
        AND BOS.DEPARTMENT_ID = BD.DEPARTMENT_ID
        AND BOS.DISABLE_DATE <= expiration_date
        AND BOS.OPERATION_SEQUENCE_ID NOT IN(
          SELECT NVL(OPERATION_SEQUENCE_ID, 0)
          FROM
            BOM_DELETE_SUB_ENTITIES BDSE,
            BOM_DELETE_ENTITIES BDE
          WHERE BDE.DELETE_GROUP_SEQUENCE_ID = delete_group_id
          AND BDE.DELETE_ENTITY_SEQUENCE_ID = BDSE.DELETE_ENTITY_SEQUENCE_ID);
      RAISE finale;
      ELSE
        var_text := 'delete type';
        RAISE invalid_parameter;
      END IF;  -- END OF OPERATION WHERE USED SEARCH
    END IF;  -- END OF COMPONENT OR OPERATION WHERE USED SEARCH
  END IF;  -- END OF process_type = 1

  -- process_type = 2 CALLED ON COMMIT STARTS HERE
  -- SOME process_type = 1 FALL THROUGH TO THIS SECTION TOO
  -- - ITEM CATALOG SEARCHES

  -- DETERMINE IF THE ORG IS A MASTER ORG. IF IT IS, THEN EXPLODE
  -- TO INSERT THIS ITEM FOR CHILD ORGS.
/*
Bug 1457363
  Because of the New Functionality to delete Items from single org,
Organization Hierarchy and all Organizations, The following code is
not required as we need to give an error whenever item is being deleted
from master org when it still exists in child Organizations ,
 instead of deleting items from all the child Organizations also
Commenting the Following Code
*/

/*
  stmt_num := 6;
  IF delete_type IN (1, 7) THEN
  DECLARE
    CURSOR GetMasterOrg IS
    SELECT DECODE(ORGANIZATION_ID, MASTER_ORGANIZATION_ID, 'Y', 'N')
           master_org_flag
    FROM MTL_PARAMETERS
    WHERE ORGANIZATION_ID = org_id;
  BEGIN
    FOR GetMasterOrgREC IN GetMasterOrg LOOP
      IF GetMasterOrgREC.master_org_flag = 'N' THEN
        IF delete_type = 1 THEN
          UPDATE_UNPROCESSED_ROWS(delete_group_id);
          RAISE finale;
        END IF;
      ELSE  -- MASTER ORG
      DECLARE
        CURSOR GetDelEntities IS
        SELECT DELETE_ENTITY_SEQUENCE_ID, INVENTORY_ITEM_ID
        FROM BOM_DELETE_ENTITIES
        WHERE DELETE_GROUP_SEQUENCE_ID = delete_group_id
        AND PRIOR_PROCESS_FLAG = 2;
      BEGIN

        -- INSERT ROW IN BOM_DELETE_ENTITIES FOR THE ITEM IN ALL CHILD ORGS
        FOR GetDelEntitiesREC IN GetDelEntities LOOP
          INSERT INTO BOM_DELETE_ENTITIES(
            DELETE_ENTITY_SEQUENCE_ID,
            DELETE_GROUP_SEQUENCE_ID,
            DELETE_ENTITY_TYPE,
            INVENTORY_ITEM_ID,
            ORGANIZATION_ID,
            ITEM_DESCRIPTION,
            ITEM_CONCAT_SEGMENTS,
            DELETE_STATUS_TYPE,
            PRIOR_PROCESS_FLAG,
            PRIOR_COMMIT_FLAG,
            LAST_UPDATE_DATE,
            LAST_UPDATED_BY,
            CREATION_DATE,
            CREATED_BY)
          SELECT
            BOM_DELETE_ENTITIES_S.NEXTVAL,
            delete_group_id,
            1,
            MSI.INVENTORY_ITEM_ID,
            MSI.ORGANIZATION_ID,
            MSI.DESCRIPTION,
            MIF.ITEM_NUMBER,
            1,
            process_flag,
            commit_flag,
            SYSDATE,
            userid,
            SYSDATE,
            userid
          FROM
            MTL_SYSTEM_ITEMS MSI,
            MTL_ITEM_FLEXFIELDS MIF
          WHERE MSI.INVENTORY_ITEM_ID = GetDelEntitiesREC.INVENTORY_ITEM_ID
          AND MSI.ENG_ITEM_FLAG = item_eng_flag
          AND MIF.ITEM_ID = MSI.INVENTORY_ITEM_ID
          AND MIF.ORGANIZATION_ID = MSI.ORGANIZATION_ID
          AND MSI.ORGANIZATION_ID IN(
            SELECT ORGANIZATION_ID
            FROM MTL_PARAMETERS
            WHERE MASTER_ORGANIZATION_ID = org_id
            AND ORGANIZATION_ID <> MASTER_ORGANIZATION_ID)
            AND MSI.ORGANIZATION_ID NOT IN(
              SELECT DISTINCT ORGANIZATION_ID
              FROM BOM_DELETE_ENTITIES
              WHERE DELETE_GROUP_SEQUENCE_ID = delete_group_id
              AND INVENTORY_ITEM_ID = GetDelEntitiesREC.INVENTORY_ITEM_ID);
        END LOOP;  -- FOR
        IF delete_type = 1 THEN
          UPDATE_UNPROCESSED_ROWS(delete_group_id);
          RAISE finale;
        END IF;
      END;
      END IF;
    END LOOP;  -- FOR
  END;
  END IF;
*/
  IF delete_type IN (6, 7) THEN
  DECLARE
    CURSOR BR_GetDelEntities IS
    SELECT DELETE_ENTITY_SEQUENCE_ID, INVENTORY_ITEM_ID, ORGANIZATION_ID
    FROM BOM_DELETE_ENTITIES
    WHERE DELETE_GROUP_SEQUENCE_ID = delete_group_id
    AND PRIOR_PROCESS_FLAG = 2;
  BEGIN

    -- INSERT ROW IN BOM_DELETE_ENTITIES FOR ALL BOMS AND ALTERNATES

    FOR BR_GetDelEntitiesREC IN BR_GetDelEntities LOOP
      INSERT INTO BOM_DELETE_ENTITIES(
        DELETE_ENTITY_SEQUENCE_ID,
        DELETE_GROUP_SEQUENCE_ID,
        DELETE_ENTITY_TYPE,
        INVENTORY_ITEM_ID,
        ORGANIZATION_ID,
        ALTERNATE_DESIGNATOR,
        ITEM_DESCRIPTION,
        ITEM_CONCAT_SEGMENTS,
        DELETE_STATUS_TYPE,
        PRIOR_PROCESS_FLAG,
        PRIOR_COMMIT_FLAG,
        BILL_SEQUENCE_ID,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        CREATION_DATE,
        CREATED_BY)
      SELECT
        BOM_DELETE_ENTITIES_S.NEXTVAL,
        delete_group_id,
        2,
        BOM.ASSEMBLY_ITEM_ID,
        BOM.ORGANIZATION_ID,
        BOM.ALTERNATE_BOM_DESIGNATOR,
        MSI.DESCRIPTION,
        MIF.ITEM_NUMBER,
        1,
        1,
        commit_flag,
        BOM.BILL_SEQUENCE_ID,
        SYSDATE,
        userid,
        SYSDATE,
        userid
      FROM
        BOM_BILL_OF_MATERIALS BOM,
        MTL_SYSTEM_ITEMS MSI,
        MTL_ITEM_FLEXFIELDS MIF
      WHERE ASSEMBLY_ITEM_ID = BR_GetDelEntitiesREC.INVENTORY_ITEM_ID
      AND BOM.ORGANIZATION_ID  = BR_GetDelEntitiesREC.ORGANIZATION_ID
      AND MSI.INVENTORY_ITEM_ID = BOM.ASSEMBLY_ITEM_ID
      AND MSI.ORGANIZATION_ID = BOM.ORGANIZATION_ID
      AND MIF.ITEM_ID = BOM.ASSEMBLY_ITEM_ID
      AND MIF.ORGANIZATION_ID = BOM.ORGANIZATION_ID
      AND BOM.ASSEMBLY_TYPE = eng_flag
      AND BOM.BILL_SEQUENCE_ID NOT IN(
        SELECT NVL(BILL_SEQUENCE_ID, 0)
        FROM BOM_DELETE_ENTITIES
        WHERE DELETE_GROUP_SEQUENCE_ID = delete_group_id);

      -- INSERT ROW IN BOM_DELETE_ENTITIES FOR ALL ROUTINGS AND ALTERNATES

      INSERT INTO BOM_DELETE_ENTITIES(
        DELETE_ENTITY_SEQUENCE_ID,
        DELETE_GROUP_SEQUENCE_ID,
        DELETE_ENTITY_TYPE,
        INVENTORY_ITEM_ID,
        ORGANIZATION_ID,
        ALTERNATE_DESIGNATOR,
        ITEM_DESCRIPTION,
        ITEM_CONCAT_SEGMENTS,
        DELETE_STATUS_TYPE,
        PRIOR_PROCESS_FLAG,
        PRIOR_COMMIT_FLAG,
        ROUTING_SEQUENCE_ID,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        CREATION_DATE,
        CREATED_BY)
      SELECT
        BOM_DELETE_ENTITIES_S.NEXTVAL,
        delete_group_id,
        3,
        BOR.ASSEMBLY_ITEM_ID,
        BOR.ORGANIZATION_ID,
        BOR.ALTERNATE_ROUTING_DESIGNATOR,
        MSI.DESCRIPTION,
        MIF.ITEM_NUMBER,
        1,
        1,
        commit_flag,
        BOR.ROUTING_SEQUENCE_ID,
        SYSDATE,
        userid,
        SYSDATE,
        userid
      FROM
        BOM_OPERATIONAL_ROUTINGS BOR,
        MTL_SYSTEM_ITEMS MSI,
        MTL_ITEM_FLEXFIELDS MIF
      WHERE ASSEMBLY_ITEM_ID = BR_GetDelEntitiesREC.INVENTORY_ITEM_ID
      AND BOR.ORGANIZATION_ID  = BR_GetDelEntitiesREC.ORGANIZATION_ID
      AND MSI.INVENTORY_ITEM_ID = BOR.ASSEMBLY_ITEM_ID
      AND MSI.ORGANIZATION_ID = BOR.ORGANIZATION_ID
      AND MIF.ITEM_ID = BOR.ASSEMBLY_ITEM_ID
      AND MIF.ORGANIZATION_ID = BOR.ORGANIZATION_ID
      AND BOR.ROUTING_TYPE = eng_flag
      AND BOR.ROUTING_SEQUENCE_ID NOT IN(
        SELECT NVL(ROUTING_SEQUENCE_ID, 0)
        FROM BOM_DELETE_ENTITIES
        WHERE DELETE_GROUP_SEQUENCE_ID = delete_group_id);

      -- DELETE ROW IN BOM_DELETE_ENTITIES FOR BILL AND ROUTING
      -- THAT WAS THE ITEM PLACE HOLDER (CURRENT OF CURSOR)

      IF delete_type = 6 THEN
        DELETE
        FROM BOM_DELETE_ENTITIES
        WHERE DELETE_ENTITY_SEQUENCE_ID =
              BR_GetDelEntitiesREC.DELETE_ENTITY_SEQUENCE_ID;
      END IF;

    END LOOP;
       -- this is to fix the bug 1205006.
       -- Updates the pre-process-flag for row
       -- containing item info(ITEM PLACE HOLDER)if delete-type is 7.
       IF delete_type = 7 THEN
         UPDATE_UNPROCESSED_ROWS(delete_group_id);
         RAISE finale;
       END IF;
  END;
  ELSIF delete_type IN (2, 3, 4, 5) THEN
    UPDATE_UNPROCESSED_ROWS(delete_group_id);
    RAISE finale;
  ELSIF delete_type = 1 THEN
    null;
  ELSE
    var_text := 'delete type';
    RAISE invalid_parameter;
  END IF;

EXCEPTION
  WHEN invalid_parameter THEN
    FND_MESSAGE.SET_NAME('BOM','BOM_DELETE_ITEMS_PARAM');
    FND_MESSAGE.SET_TOKEN('ENTITY', var_text, TRUE);
    APP_EXCEPTION.RAISE_EXCEPTION;
  WHEN finale THEN
    null;
  WHEN OTHERS THEN
    RAISE_ERROR(
      func_name => 'P0PULATE_DELETE',
      stmt_num  => stmt_num);

END POPULATE_DELETE;

END BOM_DELETE_ITEMS;

/
