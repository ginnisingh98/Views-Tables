--------------------------------------------------------
--  DDL for Package Body EGO_IMPORT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EGO_IMPORT_PVT" AS
/* $Header: EGOVIMPB.pls 120.173.12010000.12 2011/11/25 06:58:53 jewen ship $ */

    G_DEFAULT_ATTR_GROUP_TYPE    CONSTANT VARCHAR2(30) := 'EGO_ITEMMGMT_GROUP';
--  G_IOI_STAMP_REQUEST_ID_FLAG  CONSTANT NUMBER := -1;

    G_TRANS_TYPE_CREATE         CONSTANT VARCHAR2(10) := 'CREATE';
    G_TRANS_TYPE_UPDATE         CONSTANT VARCHAR2(10) := 'UPDATE';
    G_TRANS_TYPE_DELETE         CONSTANT VARCHAR2(10) := 'DELETE';
    G_TRANS_TYPE_SYNC           CONSTANT VARCHAR2(10) := 'SYNC';

    TYPE UROWID_TABLE    IS     TABLE OF UROWID;
    G_MSII_REIMPORT_ROWS        UROWID_TABLE;

    G_NEEDS_REQUEST_ID_STAMP    CONSTANT NUMBER := -1;
    G_NEED_TO_LOG_ERROR         CONSTANT NUMBER := -3;

    SUBTYPE MSII_ROW    IS MTL_SYSTEM_ITEMS_INTERFACE%ROWTYPE;
    TYPE COLUMN_NAMES   IS TABLE OF ALL_TAB_COLUMNS.COLUMN_NAME%TYPE;
    SUBTYPE EIUAI_ROW   IS EGO_ITM_USR_ATTR_INTRFC%ROWTYPE;
    TYPE EIUAI_ROWS     IS TABLE OF EIUAI_ROW INDEX BY BINARY_INTEGER;
    SUBTYPE IAssocs_Row IS EGO_ITEM_ASSOCIATIONS_INTF%ROWTYPE;
    TYPE IAssocs_Rows   IS TABLE OF IAssocs_Row INDEX BY BINARY_INTEGER;

    G_PARTY_NAME        VARCHAR2(100);

    G_LOG_TIMESTAMP_FORMAT CONSTANT VARCHAR2( 30 ) := 'dd-mon-yyyy hh:mi:ss.ff';

    G_EXCEL_MISS_DATE_VAL   CONSTANT DATE           := to_date( '9999-12-31', 'YYYY-MM-DD' );
    G_EXCEL_MISS_DATE_STR   CONSTANT VARCHAR2(50)   := 'to_date(''9999-12-31'', ''YYYY-MM-DD'') ';

    G_EXCEL_MISS_NUM_STR    CONSTANT VARCHAR2(20)   := EGO_USER_ATTRS_BULK_PVT.G_NULL_NUM_VAL;
    G_EXCEL_MISS_CHAR_VAL   CONSTANT VARCHAR2(30)   := EGO_USER_ATTRS_BULK_PVT.G_NULL_CHAR_VAL;

    G_EXCEL_MISS_VS_VAL     CONSTANT VARCHAR2(30)   := ''''||G_EXCEL_MISS_CHAR_VAL||'''';

    -- Confirm Status Constants Available in package spec
    G_DATE_TIME_DATA_TYPE     CONSTANT FLAG := 'Y';

  /*
   * This method writes into concurrent program log
   */
  PROCEDURE Debug_Conc_Log( p_message IN VARCHAR2
                          , p_add_timestamp IN BOOLEAN DEFAULT TRUE )
  IS
     l_inv_debug_level  NUMBER := INVPUTLI.get_debug_level;     --Bug: 4667452
  BEGIN
    IF l_inv_debug_level IN(101, 102) THEN
      INVPUTLI.info(  ( CASE
                        WHEN p_add_timestamp THEN to_char( systimestamp, G_LOG_TIMESTAMP_FORMAT ) || ': '
                        ELSE ''
                        END  )
                   ||   p_message );
    END IF;
  END Debug_Conc_Log;

  /*
   * Private method to return current party name string associated with current user
   */
  FUNCTION Get_Current_Party_Name RETURN VARCHAR2
  IS
    l_party_id NUMBER;
  BEGIN
    IF G_PARTY_NAME IS NULL THEN
      BEGIN
        SELECT PARTY_ID INTO l_party_id
        FROM ego_user_v
        WHERE USER_ID = FND_GLOBAL.USER_ID;
      EXCEPTION WHEN OTHERS THEN
        RETURN NULL;
      END;

      G_PARTY_NAME := 'HZ_PARTY:' || TO_CHAR(l_party_id);
      RETURN G_PARTY_NAME;
    ELSE
      RETURN G_PARTY_NAME;
    END IF;
  END Get_Current_Party_Name;

       /*This method errors out all those rows in interface tables which have
    *NULL source System reference or have invalid source system id.
    *
    *For handling the case when user insert data through BackEnd and tries to import
    *data using Import WorkBench.
    *
    *Done for Bug 5352143
    */
  PROCEDURE Err_null_ssxref_ssid( p_data_set_id  IN  NUMBER )
  IS
    l_msg_text          VARCHAR2(4000);
    l_err_text          VARCHAR2(4000);
    l_user_id           NUMBER := FND_GLOBAL.USER_ID;
    l_login_id          NUMBER := FND_GLOBAL.LOGIN_ID;
    l_prog_appid        NUMBER := FND_GLOBAL.PROG_APPL_ID;
    l_prog_id           NUMBER := FND_GLOBAL.CONC_PROGRAM_ID;
    l_request_id        NUMBER := FND_GLOBAL.CONC_REQUEST_ID;
    dumm_status         VARCHAR2(100);

    CURSOR c_ssxref_null_msii IS
      SELECT
        ORGANIZATION_ID,
        TRANSACTION_ID,
        PROCESS_FLAG
      FROM MTL_SYSTEM_ITEMS_INTERFACE
      WHERE SET_PROCESS_ID = p_data_set_id
        AND PROCESS_FLAG IN (33379, 33389);

    CURSOR c_ssxref_null_miri IS
      SELECT
        ORGANIZATION_ID,
        TRANSACTION_ID,
        PROCESS_FLAG
      FROM MTL_ITEM_REVISIONS_INTERFACE
      WHERE SET_PROCESS_ID = p_data_set_id
        AND PROCESS_FLAG  IN (33379, 33389);

    CURSOR c_ssxref_null_mici IS
      SELECT
        ORGANIZATION_ID,
        TRANSACTION_ID,
        PROCESS_FLAG
      FROM MTL_ITEM_CATEGORIES_INTERFACE
      WHERE SET_PROCESS_ID = p_data_set_id
        AND PROCESS_FLAG  IN (33379, 33389);

    CURSOR c_ssxref_null_eiuai IS
      SELECT
        ORGANIZATION_ID,
        TRANSACTION_ID,
        PROCESS_STATUS
      FROM EGO_ITM_USR_ATTR_INTRFC
      WHERE DATA_SET_ID = p_data_set_id
        AND PROCESS_STATUS  IN (33379, 33389);

    CURSOR c_ssxref_null_eipi IS
      SELECT
        ORGANIZATION_ID,
        TRANSACTION_ID,
        PROCESS_STATUS
      FROM EGO_ITEM_PEOPLE_INTF
      WHERE DATA_SET_ID = p_data_set_id
        AND PROCESS_STATUS  IN (33379, 33389);

    CURSOR c_ssxref_null_eai IS
      SELECT
        ORGANIZATION_ID,
        TRANSACTION_ID,
        PROCESS_FLAG
      FROM EGO_AML_INTF
      WHERE DATA_SET_ID = p_data_set_id
        AND PROCESS_FLAG  IN (33379, 33389);
   --R12C:BEGIN
   CURSOR c_ssxref_null_assocs IS
     SELECT
       ORGANIZATION_ID,
       TRANSACTION_ID,
       PROCESS_FLAG
     FROM EGO_ITEM_ASSOCIATIONS_INTF
     WHERE BATCH_ID = p_data_set_id
     AND PROCESS_FLAG  IN (33379, 33389);
   --R12C:BEGIN
  BEGIN
    Debug_Conc_Log( 'Err_null_ssxref_ssid - Begin' );
-- MSII
    UPDATE MTL_SYSTEM_ITEMS_INTERFACE MSII
    SET PROCESS_FLAG = (CASE WHEN MSII.SOURCE_SYSTEM_REFERENCE IS NULL THEN 33379 ELSE 33389 END),
        TRANSACTION_ID   = NVL(TRANSACTION_ID, MTL_SYSTEM_ITEMS_INTERFACE_S.NEXTVAL),
        PROGRAM_APPLICATION_ID = l_prog_appid,
        PROGRAM_ID = l_prog_id,
        REQUEST_ID = l_request_id
    WHERE SET_PROCESS_ID = p_data_set_id
      AND PROCESS_FLAG = 0
      AND (MSII.SOURCE_SYSTEM_REFERENCE IS NULL
        OR MSII.SOURCE_SYSTEM_ID <>
              (SELECT SOURCE_SYSTEM_ID
               FROM EGO_IMPORT_BATCHES_B
               WHERE BATCH_ID = MSII.SET_PROCESS_ID
              )
          );

-- MIRI
    UPDATE MTL_ITEM_REVISIONS_INTERFACE MIRI
    SET PROCESS_FLAG = (CASE WHEN MIRI.SOURCE_SYSTEM_REFERENCE IS NULL THEN 33379 ELSE 33389 END),
        TRANSACTION_ID   = NVL(TRANSACTION_ID, MTL_SYSTEM_ITEMS_INTERFACE_S.NEXTVAL),
        PROGRAM_APPLICATION_ID = l_prog_appid,
        PROGRAM_ID = l_prog_id,
        REQUEST_ID = l_request_id
    WHERE SET_PROCESS_ID = p_data_set_id
    AND   PROCESS_FLAG = 0
    AND ( MIRI.SOURCE_SYSTEM_REFERENCE IS NULL
        OR MIRI.SOURCE_SYSTEM_ID <>
              (SELECT SOURCE_SYSTEM_ID
               FROM EGO_IMPORT_BATCHES_B
               WHERE BATCH_ID = MIRI.SET_PROCESS_ID
              )
          );

-- MICI
    UPDATE MTL_ITEM_CATEGORIES_INTERFACE MICI
    SET PROCESS_FLAG = (CASE WHEN MICI.SOURCE_SYSTEM_REFERENCE IS NULL THEN 33379 ELSE 33389 END),
        TRANSACTION_ID   = NVL(TRANSACTION_ID, MTL_SYSTEM_ITEMS_INTERFACE_S.NEXTVAL),
        PROGRAM_APPLICATION_ID = l_prog_appid,
        PROGRAM_ID = l_prog_id,
        REQUEST_ID = l_request_id
    WHERE SET_PROCESS_ID = p_data_set_id
      AND PROCESS_FLAG = 0
      AND (MICI.SOURCE_SYSTEM_REFERENCE IS NULL
        OR MICI.SOURCE_SYSTEM_ID <>
              (SELECT SOURCE_SYSTEM_ID
               FROM EGO_IMPORT_BATCHES_B
               WHERE BATCH_ID = MICI.SET_PROCESS_ID
              )
          );

-- EIUAI
    UPDATE EGO_ITM_USR_ATTR_INTRFC EIUAI
    SET PROCESS_STATUS = (CASE WHEN EIUAI.SOURCE_SYSTEM_REFERENCE IS NULL THEN 33379 ELSE 33389 END),
        TRANSACTION_ID   = NVL(TRANSACTION_ID, MTL_SYSTEM_ITEMS_INTERFACE_S.NEXTVAL),
        PROGRAM_APPLICATION_ID = l_prog_appid,
        PROGRAM_ID = l_prog_id,
        REQUEST_ID = l_request_id
    WHERE DATA_SET_ID = p_data_set_id
      AND PROCESS_STATUS = 0
      AND (EIUAI.SOURCE_SYSTEM_REFERENCE IS NULL
        OR EIUAI.SOURCE_SYSTEM_ID <>
              (SELECT SOURCE_SYSTEM_ID
               FROM EGO_IMPORT_BATCHES_B
               WHERE BATCH_ID = EIUAI.DATA_SET_ID
              )
          );

-- EIPI
    UPDATE EGO_ITEM_PEOPLE_INTF EIPI
    SET PROCESS_STATUS = (CASE WHEN EIPI.SOURCE_SYSTEM_REFERENCE IS NULL THEN 33379 ELSE 33389 END),
        TRANSACTION_ID   = NVL(TRANSACTION_ID, MTL_SYSTEM_ITEMS_INTERFACE_S.NEXTVAL),
        PROGRAM_APPLICATION_ID = l_prog_appid,
        PROGRAM_ID = l_prog_id,
        REQUEST_ID = l_request_id
    WHERE DATA_SET_ID = p_data_set_id
      AND PROCESS_STATUS = 0
      AND (EIPI.SOURCE_SYSTEM_REFERENCE IS NULL
        OR EIPI.SOURCE_SYSTEM_ID <>
              (SELECT SOURCE_SYSTEM_ID
               FROM EGO_IMPORT_BATCHES_B
               WHERE BATCH_ID = EIPI.DATA_SET_ID
              )
          );

-- EAI
    UPDATE EGO_AML_INTF EAI
    SET PROCESS_FLAG = (CASE WHEN EAI.SOURCE_SYSTEM_REFERENCE IS NULL THEN 33379 ELSE 33389 END),
        TRANSACTION_ID   = NVL(TRANSACTION_ID, MTL_SYSTEM_ITEMS_INTERFACE_S.NEXTVAL),
        PROGRAM_APPLICATION_ID = l_prog_appid,
        PROGRAM_ID = l_prog_id,
        REQUEST_ID = l_request_id
    WHERE DATA_SET_ID = p_data_set_id
      AND PROCESS_FLAG = 0
      AND (EAI.SOURCE_SYSTEM_REFERENCE IS NULL
        OR EAI.SOURCE_SYSTEM_ID <>
              (SELECT SOURCE_SYSTEM_ID
               FROM EGO_IMPORT_BATCHES_B
               WHERE BATCH_ID = EAI.DATA_SET_ID
              )
          );

-- R12C:BEGIN ASSOCSINTF
    UPDATE EGO_ITEM_ASSOCIATIONS_INTF EIAI
    SET PROCESS_FLAG = (CASE WHEN EIAI.SOURCE_SYSTEM_REFERENCE IS NULL THEN 33379 ELSE 33389 END),
        TRANSACTION_ID   = NVL(TRANSACTION_ID, MTL_SYSTEM_ITEMS_INTERFACE_S.NEXTVAL),
        PROGRAM_APPLICATION_ID = l_prog_appid,
        PROGRAM_ID = l_prog_id,
        REQUEST_ID = l_request_id
    WHERE BATCH_ID = p_data_set_id
      AND PROCESS_FLAG = 0
      AND (EIAI.SOURCE_SYSTEM_REFERENCE IS NULL
        OR EIAI.SOURCE_SYSTEM_ID <>
              (SELECT SOURCE_SYSTEM_ID
               FROM EGO_IMPORT_BATCHES_B
               WHERE BATCH_ID = EIAI.BATCH_ID
              )
          );
-- R12C:END ASSOCSINTF
    Debug_Conc_Log( 'Err_null_ssxref_ssid - Completed updating rows having null SSxRef or invalid SSid' );
    Debug_Conc_Log( 'Err_null_ssxref_ssid - Started inserting Errors' );
  -- MSII
    FOR i IN c_ssxref_null_msii LOOP
      IF i.PROCESS_FLAG = 33379 THEN
        FND_MESSAGE.SET_NAME('EGO', 'EGO_SSXREF_IS_NULL');
        l_msg_text := FND_MESSAGE.GET;
        dumm_status  := INVPUOPI.mtl_log_interface_err(
                                i.ORGANIZATION_ID
                               ,l_user_id
                               ,l_login_id
                               ,l_prog_appid
                               ,l_prog_id
                               ,l_request_id
                               ,i.TRANSACTION_ID
                               ,l_msg_text
                               ,'SOURCE_SYSTEM_REFERENCE'
                               ,'MTL_SYSTEM_ITEMS_INTERFACE'
                               ,'INV_IOI_ERR'
                               ,l_err_text);

      ELSIF i.PROCESS_FLAG = 33389 THEN
        FND_MESSAGE.SET_NAME('EGO', 'EGO_SSXID_INVALID');
        l_msg_text := FND_MESSAGE.GET;
        dumm_status  := INVPUOPI.mtl_log_interface_err(
                                i.ORGANIZATION_ID
                               ,l_user_id
                               ,l_login_id
                               ,l_prog_appid
                               ,l_prog_id
                               ,l_request_id
                               ,i.TRANSACTION_ID
                               ,l_msg_text
                               ,'SOURCE_SYSTEM_ID'
                               ,'MTL_SYSTEM_ITEMS_INTERFACE'
                               ,'INV_IOI_ERR'
                               ,l_err_text);
      END IF;
    END LOOP;

  -- MIRI
    FOR i IN c_ssxref_null_miri LOOP
      IF i.PROCESS_FLAG = 33379 THEN
        FND_MESSAGE.SET_NAME('EGO', 'EGO_SSXREF_IS_NULL');
        l_msg_text := FND_MESSAGE.GET;
        dumm_status  := INVPUOPI.mtl_log_interface_err(
                                i.ORGANIZATION_ID
                               ,l_user_id
                               ,l_login_id
                               ,l_prog_appid
                               ,l_prog_id
                               ,l_request_id
                               ,i.TRANSACTION_ID
                               ,l_msg_text
                               ,'SOURCE_SYSTEM_REFERENCE'
                               ,'MTL_ITEM_REVISIONS_INTERFACE'
                               ,'INV_IOI_ERR'
                               ,l_err_text);
      ELSIF i.PROCESS_FLAG = 33389 THEN
        FND_MESSAGE.SET_NAME('EGO', 'EGO_SSXID_INVALID');
        l_msg_text := FND_MESSAGE.GET;
        dumm_status  := INVPUOPI.mtl_log_interface_err(
                                i.ORGANIZATION_ID
                               ,l_user_id
                               ,l_login_id
                               ,l_prog_appid
                               ,l_prog_id
                               ,l_request_id
                               ,i.TRANSACTION_ID
                               ,l_msg_text
                               ,'SOURCE_SYSTEM_ID'
                               ,'MTL_ITEM_REVISIONS_INTERFACE'
                               ,'INV_IOI_ERR'
                               ,l_err_text);
      END IF;
    END LOOP;

  -- MICI
    FOR i IN c_ssxref_null_mici LOOP
      IF i.PROCESS_FLAG = 33379 THEN
        FND_MESSAGE.SET_NAME('EGO', 'EGO_SSXREF_IS_NULL');
        l_msg_text := FND_MESSAGE.GET;
        dumm_status  := INVPUOPI.mtl_log_interface_err(
                                i.ORGANIZATION_ID
                               ,l_user_id
                               ,l_login_id
                               ,l_prog_appid
                               ,l_prog_id
                               ,l_request_id
                               ,i.TRANSACTION_ID
                               ,l_msg_text
                               ,'SOURCE_SYSTEM_REFERENCE'
                               ,'MTL_ITEM_CATEGORIES_INTERFACE'
                               ,'INV_IOI_ERR'
                               ,l_err_text);
      ELSIF i.PROCESS_FLAG = 33389 THEN
        FND_MESSAGE.SET_NAME('EGO', 'EGO_SSXID_INVALID');
        l_msg_text := FND_MESSAGE.GET;
        dumm_status  := INVPUOPI.mtl_log_interface_err(
                                i.ORGANIZATION_ID
                               ,l_user_id
                               ,l_login_id
                               ,l_prog_appid
                               ,l_prog_id
                               ,l_request_id
                               ,i.TRANSACTION_ID
                               ,l_msg_text
                               ,'SOURCE_SYSTEM_ID'
                               ,'MTL_ITEM_CATEGORIES_INTERFACE'
                               ,'INV_IOI_ERR'
                               ,l_err_text);
      END IF;
    END LOOP;

  -- EIUAI
    FOR i IN c_ssxref_null_eiuai LOOP
      IF i.PROCESS_STATUS = 33379 THEN
        FND_MESSAGE.SET_NAME('EGO', 'EGO_SSXREF_IS_NULL');
        l_msg_text := FND_MESSAGE.GET;
        dumm_status  := INVPUOPI.mtl_log_interface_err(
                                i.ORGANIZATION_ID
                               ,l_user_id
                               ,l_login_id
                               ,l_prog_appid
                               ,l_prog_id
                               ,l_request_id
                               ,i.TRANSACTION_ID
                               ,l_msg_text
                               ,'SOURCE_SYSTEM_REFERENCE'
                               ,'EGO_ITM_USR_ATTR_INTRFC'
                               ,'INV_IOI_ERR'
                               ,l_err_text);
      ELSIF i.PROCESS_STATUS = 33389 THEN
        FND_MESSAGE.SET_NAME('EGO', 'EGO_SSXID_INVALID');
        l_msg_text := FND_MESSAGE.GET;
        dumm_status  := INVPUOPI.mtl_log_interface_err(
                                i.ORGANIZATION_ID
                               ,l_user_id
                               ,l_login_id
                               ,l_prog_appid
                               ,l_prog_id
                               ,l_request_id
                               ,i.TRANSACTION_ID
                               ,l_msg_text
                               ,'SOURCE_SYSTEM_ID'
                               ,'EGO_ITM_USR_ATTR_INTRFC'
                               ,'INV_IOI_ERR'
                               ,l_err_text);
      END IF;
    END LOOP;

  -- EIPI
    FOR i IN c_ssxref_null_eipi LOOP
      IF i.PROCESS_STATUS = 33379 THEN
        FND_MESSAGE.SET_NAME('EGO', 'EGO_SSXREF_IS_NULL');
        l_msg_text := FND_MESSAGE.GET;
        dumm_status  := INVPUOPI.mtl_log_interface_err(
                                i.ORGANIZATION_ID
                               ,l_user_id
                               ,l_login_id
                               ,l_prog_appid
                               ,l_prog_id
                               ,l_request_id
                               ,i.TRANSACTION_ID
                               ,l_msg_text
                               ,'SOURCE_SYSTEM_REFERENCE'
                               ,'EGO_ITEM_PEOPLE_INTF'
                               ,'INV_IOI_ERR'
                               ,l_err_text);
      ELSIF i.PROCESS_STATUS = 33389 THEN
        FND_MESSAGE.SET_NAME('EGO', 'EGO_SSXID_INVALID');
        l_msg_text := FND_MESSAGE.GET;
        dumm_status  := INVPUOPI.mtl_log_interface_err(
                                i.ORGANIZATION_ID
                               ,l_user_id
                               ,l_login_id
                               ,l_prog_appid
                               ,l_prog_id
                               ,l_request_id
                               ,i.TRANSACTION_ID
                               ,l_msg_text
                               ,'SOURCE_SYSTEM_ID'
                               ,'EGO_ITEM_PEOPLE_INTF'
                               ,'INV_IOI_ERR'
                               ,l_err_text);
      END IF;
    END LOOP;

  -- EAI
    FOR i IN c_ssxref_null_eai LOOP
      IF i.PROCESS_FLAG = 33379 THEN
        FND_MESSAGE.SET_NAME('EGO', 'EGO_SSXREF_IS_NULL');
        l_msg_text := FND_MESSAGE.GET;
        dumm_status  := INVPUOPI.mtl_log_interface_err(
                                i.ORGANIZATION_ID
                               ,l_user_id
                               ,l_login_id
                               ,l_prog_appid
                               ,l_prog_id
                               ,l_request_id
                               ,i.TRANSACTION_ID
                               ,l_msg_text
                               ,'SOURCE_SYSTEM_REFERENCE'
                               ,'EGO_AML_INTF'
                               ,'INV_IOI_ERR'
                               ,l_err_text);
      ELSIF i.PROCESS_FLAG = 33389 THEN
        FND_MESSAGE.SET_NAME('EGO', 'EGO_SSXID_INVALID');
        l_msg_text := FND_MESSAGE.GET;
        dumm_status  := INVPUOPI.mtl_log_interface_err(
                                i.ORGANIZATION_ID
                               ,l_user_id
                               ,l_login_id
                               ,l_prog_appid
                               ,l_prog_id
                               ,l_request_id
                               ,i.TRANSACTION_ID
                               ,l_msg_text
                               ,'SOURCE_SYSTEM_ID'
                               ,'EGO_AML_INTF'
                               ,'INV_IOI_ERR'
                               ,l_err_text);
      END IF;
        END LOOP;

  -- R12C:BEGIN
      FOR i IN c_ssxref_null_assocs LOOP
        IF i.PROCESS_FLAG = 33379 THEN
          FND_MESSAGE.SET_NAME('EGO', 'EGO_SSXREF_IS_NULL');
          l_msg_text := FND_MESSAGE.GET;
          dumm_status  := INVPUOPI.mtl_log_interface_err(
                                i.ORGANIZATION_ID
                               ,l_user_id
                               ,l_login_id
                               ,l_prog_appid
                               ,l_prog_id
                               ,l_request_id
                               ,i.TRANSACTION_ID
                               ,l_msg_text
                               ,'SOURCE_SYSTEM_REFERENCE'
                               ,'EGO_ITEM_ASSOCIATIONS_INTF'
                               ,'INV_IOI_ERR'
                               ,l_err_text);
        ELSIF i.PROCESS_FLAG = 33389 THEN
          FND_MESSAGE.SET_NAME('EGO', 'EGO_SSXID_INVALID');
          l_msg_text := FND_MESSAGE.GET;
          dumm_status  := INVPUOPI.mtl_log_interface_err(
                                i.ORGANIZATION_ID
                               ,l_user_id
                               ,l_login_id
                               ,l_prog_appid
                               ,l_prog_id
                               ,l_request_id
                               ,i.TRANSACTION_ID
                               ,l_msg_text
                               ,'SOURCE_SYSTEM_ID'
                               ,'EGO_ITEM_ASSOCIATIONS_INTF'
                               ,'INV_IOI_ERR'
                               ,l_err_text);
        END IF;
    END LOOP;
  --R12C: END

    Debug_Conc_Log( 'Err_null_ssxref_ssid - Finished inserting Errors' );

    UPDATE MTL_SYSTEM_ITEMS_INTERFACE
    SET PROCESS_FLAG =3
    WHERE PROCESS_FLAG IN (33379, 33389)
      AND SET_PROCESS_ID = p_data_set_id;

    UPDATE MTL_ITEM_REVISIONS_INTERFACE
    SET PROCESS_FLAG =3
    WHERE PROCESS_FLAG IN (33379, 33389)
      AND SET_PROCESS_ID = p_data_set_id;

    UPDATE MTL_ITEM_CATEGORIES_INTERFACE
    SET PROCESS_FLAG =3
    WHERE PROCESS_FLAG IN (33379, 33389)
      AND SET_PROCESS_ID = p_data_set_id;

    UPDATE EGO_ITM_USR_ATTR_INTRFC
    SET PROCESS_STATUS =3
    WHERE PROCESS_STATUS IN (33379, 33389)
      AND DATA_SET_ID = p_data_set_id;

    UPDATE EGO_ITEM_PEOPLE_INTF
    SET PROCESS_STATUS =3
    WHERE PROCESS_STATUS IN (33379, 33389)
      AND DATA_SET_ID = p_data_set_id;

    UPDATE EGO_AML_INTF
    SET PROCESS_FLAG =3
    WHERE PROCESS_FLAG IN (33379, 33389)
      AND DATA_SET_ID = p_data_set_id;
      --R12C: BEGIN
      UPDATE EGO_ITEM_ASSOCIATIONS_INTF
      SET PROCESS_FLAG =3
      WHERE PROCESS_FLAG IN (33379, 33389)
      AND BATCH_ID = p_data_set_id;
      --R12C:END
  END Err_null_ssxref_ssid;

  /*
   * Method to get next item number for a sequence generated item
   * This method is only for use in Resolve_Child_Entities
   */
  FUNCTION GET_NEXT_ITEM_NUMBER(p_catalog_group_id NUMBER) RETURN VARCHAR2 AS
    l_seq_name      MTL_ITEM_CATALOG_GROUPS_B.ITEM_NUM_SEQ_NAME%TYPE;
    l_prefix        MTL_ITEM_CATALOG_GROUPS_B.PREFIX%TYPE;
    l_suffix        MTL_ITEM_CATALOG_GROUPS_B.SUFFIX%TYPE;
    l_gen_method    MTL_ITEM_CATALOG_GROUPS_B.ITEM_NUM_GEN_METHOD%TYPE;
    l_item_number   VARCHAR2(2000);
    l_sql           VARCHAR2(2000);
  BEGIN
    SELECT ITEM_NUM_SEQ_NAME, PREFIX, SUFFIX, ITEM_NUM_GEN_METHOD
      INTO l_seq_name, l_prefix, l_suffix, l_gen_method
    FROM
    (
        SELECT  ICC.ITEM_NUM_SEQ_NAME, ICC.PREFIX, ICC.SUFFIX, ICC.ITEM_NUM_GEN_METHOD
        FROM    MTL_ITEM_CATALOG_GROUPS_B ICC
        WHERE   ICC.ITEM_NUM_GEN_METHOD IS NOT NULL
          AND   ICC.ITEM_NUM_GEN_METHOD <> 'I'
        CONNECT BY PRIOR ICC.PARENT_CATALOG_GROUP_ID = ICC.ITEM_CATALOG_GROUP_ID
            START WITH ICC.ITEM_CATALOG_GROUP_ID = p_catalog_group_id
        ORDER BY LEVEL ASC
    )
    WHERE ROWNUM = 1;

    IF 'S' <> l_gen_method THEN
        Debug_Conc_Log( 'GET_NEXT_ITEM_NUMBER for category-'||p_catalog_group_id||': Generation Method was ' || l_gen_method ||', not S.' );
        RETURN NULL;
    END IF;

    l_sql := 'SELECT '''||l_prefix||'''||'||l_seq_name||'.NEXTVAL||'''||l_suffix||''' FROM DUAL';
    EXECUTE IMMEDIATE l_sql INTO l_item_number;

    RETURN l_item_number;
  EXCEPTION WHEN OTHERS THEN
    Debug_Conc_Log( 'Error in - GET_NEXT_ITEM_NUMBER for category-'||p_catalog_group_id||': '||SQLCODE||'-'|| SQLERRM );
    RETURN NULL;
  END GET_NEXT_ITEM_NUMBER;

  /*
   * This method gathers statistics on interface tables, if required
   */
  PROCEDURE Gather_Stats_For_Intf_Tables(p_data_set_id IN NUMBER) AS
    l_records        NUMBER;
    l_status         VARCHAR2(1000);
    l_industry       VARCHAR2(1000);
    l_schema         VARCHAR2(1000);
    l_inv_installed  BOOLEAN;
    l_ego_installed  BOOLEAN;
    --6602290 : Stats gather through profile
    l_stats_profile  NUMBER := NVL(FND_PROFILE.VALUE('EGO_GATHER_STATS'),100);
  BEGIN
    Debug_Conc_Log('Starting Gather_Stats_For_Intf_Tables');
     l_inv_installed := FND_INSTALLATION.GET_APP_INFO('INV', l_status, l_industry, l_schema);

    /* Bug 12669090 : Commenting the Gather Stats.
      As mentioned in the note 1208945.1 and suggested by performance team,
      for any performance issues we need to gather stats manualy so no need to gather stats in the code.
   */
   /*

    -- checking whether stats needs to be collected on MTL_SYSTEM_ITEMS_INTERFACE
    SELECT COUNT(1) INTO l_records
    FROM MTL_SYSTEM_ITEMS_INTERFACE
    WHERE SET_PROCESS_ID = p_data_set_id;

    l_inv_installed := FND_INSTALLATION.GET_APP_INFO('INV', l_status, l_industry, l_schema);
    IF (l_records > l_stats_profile) AND l_inv_installed AND l_schema IS NOT NULL THEN
      FND_STATS.GATHER_TABLE_STATS(l_schema, 'MTL_SYSTEM_ITEMS_INTERFACE');
      Debug_Conc_Log('Collected Statistics on MTL_SYSTEM_ITEMS_INTERFACE');
    END IF;

    -- checking whether stats needs to be collected on MTL_ITEM_REVISIONS_INTERFACE
    SELECT COUNT(1) INTO l_records
    FROM MTL_ITEM_REVISIONS_INTERFACE
    WHERE SET_PROCESS_ID = p_data_set_id;

    IF (l_records > l_stats_profile) AND l_inv_installed AND l_schema IS NOT NULL THEN
      FND_STATS.GATHER_TABLE_STATS(l_schema, 'MTL_ITEM_REVISIONS_INTERFACE');
      Debug_Conc_Log('Collected Statistics on MTL_ITEM_REVISIONS_INTERFACE');
    END IF;
		 */
 	  -- Bug 12669090 : End

    -- checking whether stats needs to be collected on MTL_ITEM_CATEGORIES_INTERFACE
    SELECT COUNT(1) INTO l_records
    FROM MTL_ITEM_CATEGORIES_INTERFACE
    WHERE SET_PROCESS_ID = p_data_set_id;

    IF (l_records > l_stats_profile) AND l_inv_installed AND l_schema IS NOT NULL THEN
      FND_STATS.GATHER_TABLE_STATS(l_schema, 'MTL_ITEM_CATEGORIES_INTERFACE');
      Debug_Conc_Log('Collected Statistics on MTL_ITEM_CATEGORIES_INTERFACE');
    END IF;

    l_ego_installed := FND_INSTALLATION.GET_APP_INFO('EGO', l_status, l_industry, l_schema);
    -- checking whether stats needs to be collected on EGO_ITEM_PEOPLE_INTF
    SELECT COUNT(1) INTO l_records
    FROM EGO_ITEM_PEOPLE_INTF
    WHERE DATA_SET_ID = p_data_set_id;

    IF (l_records > l_stats_profile) AND l_ego_installed AND l_schema IS NOT NULL THEN
      FND_STATS.GATHER_TABLE_STATS(l_schema, 'EGO_ITEM_PEOPLE_INTF');
      Debug_Conc_Log('Collected Statistics on EGO_ITEM_PEOPLE_INTF');
    END IF;

    -- checking whether stats needs to be collected on EGO_AML_INTF
    SELECT COUNT(1) INTO l_records
    FROM EGO_AML_INTF
    WHERE DATA_SET_ID = p_data_set_id;

    IF (l_records > l_stats_profile) AND l_ego_installed AND l_schema IS NOT NULL THEN
      FND_STATS.GATHER_TABLE_STATS(l_schema, 'EGO_AML_INTF');
      Debug_Conc_Log('Collected Statistics on EGO_AML_INTF');
    END IF;
 /* Bug 12669090 : Commenting the Gather Stats.
    As mentioned in the note 1208945.1 and suggested by performance team,
    for any performance issues we need to gather stats manualy so no need to gather stats in the code.
 */
 	  /*
    -- checking whether stats needs to be collected on EGO_ITM_USR_ATTR_INTRFC
    SELECT COUNT(1) INTO l_records
    FROM EGO_ITM_USR_ATTR_INTRFC
    WHERE DATA_SET_ID = p_data_set_id;

    IF (l_records > (l_stats_profile*25)) AND l_ego_installed AND l_schema IS NOT NULL THEN
      FND_STATS.GATHER_TABLE_STATS(l_schema, 'EGO_ITM_USR_ATTR_INTRFC');
      Debug_Conc_Log('Collected Statistics on EGO_ITM_USR_ATTR_INTRFC');
    END IF;
*/
-- Bug 12669090 : End
    -- R12C: BEGIN
    -- checking whether stats needs to be collected on EGO_ITEM_ASSOCIATIONS_INTF

    SELECT COUNT(1) INTO l_records
    FROM EGO_ITEM_ASSOCIATIONS_INTF
    WHERE BATCH_ID = p_data_set_id;

    IF (l_records > l_stats_profile) AND l_ego_installed AND l_schema IS NOT NULL THEN
      FND_STATS.GATHER_TABLE_STATS(l_schema, 'EGO_ITEM_ASSOCIATIONS_INTF');
      Debug_Conc_Log('Collected Statistics on EGO_ITEM_ASSOCIATIONS_INTF');
    END IF;

    --R12C: END
    Debug_Conc_Log('Done Gather_Stats_For_Intf_Tables');
  EXCEPTION WHEN OTHERS THEN
    Debug_Conc_Log('Error in Gather_Stats_For_Intf_Tables-'||SQLERRM);
  END Gather_Stats_For_Intf_Tables;

    --=================================================================================================================--
    --------------------------------------- Start of Merging Section ----------------------------------------------------
    --=================================================================================================================--
    /*
     * The procedures in this section, both public and private, relate to the task of identifying the rows in various
     * item interface tables that have the same keys and need to be merged - i.e. collapsed into one row. The result of
     * the merging operation on a subset of the table should be that there is at most one row for any set of keys.
     *
     *
     * All the MERGE_* procedures take the following arguments:
     *  p_batch_id       IN NUMBER                  =>
     *      The batch identifier (MANDATORY).
     *  p_is_pdh_batch   IN FLAG      DEFAULT NULL  =>
     *      Used to determine the set of keys to use for merging.
     *          - Pass FND_API.G_TRUE to indicate that the batch is a PIMDH batch
     *          - Pass FND_API.G_FALSE to indicate that the batch is a non-PIMDH batch
     *          - If not passed, the batch header will be used to determine whether or not
     *              the batch is a PIMDH batch (absence of a header implies that it is).
     *  p_master_org_id  IN NUMBER    DEFAULT NULL =>
     *      The ID of the default batch organization, to be used for rows for which neither
     *          ORGANIZATION_ID nor ORGANIZATION_CODE are provided.
     *      If not passed, the ORGANIZATION_ID in the batch header will be used.
     *
     *  p_commit         IN FLAG      DEFAULT FND_API.G_FALSE =>
     *      Pass FND_API.G_TRUE to have a COMMIT issued at the end of the procedure.
     */

    PROCEDURE merge_params_from_batch_header( p_batch_id        IN           NUMBER
                                            , x_is_pdh_batch    OUT NOCOPY   FLAG
                                            , x_master_org_id   OUT NOCOPY   NUMBER
                                            , x_ss_id           OUT NOCOPY   NUMBER
                                            )
    IS
        l_org_id        NUMBER                                      := NULL;
        l_ss_id         EGO_IMPORT_BATCHES_B.SOURCE_SYSTEM_ID%TYPE  := NULL;
    BEGIN
        Debug_Conc_Log( 'Attempting to resolve merge parameters from batch header for batch_id='
                      || to_char( p_batch_id ) );
        BEGIN
            SELECT  MP.ORGANIZATION_ID,
                    BA.SOURCE_SYSTEM_ID
            INTO    l_org_id
                  , l_ss_id
            FROM    MTL_PARAMETERS MP
                  , EGO_IMPORT_BATCHES_B ba
            WHERE   BA.ORGANIZATION_ID = MP.ORGANIZATION_ID
                AND BA.BATCH_ID = p_batch_id;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                Debug_Conc_Log( 'Batch header not found!' );
                NULL;
        END;

        x_ss_id := l_ss_id;
        Debug_Conc_Log( 'SS ID:' || x_ss_id );
        x_is_pdh_batch :=   CASE l_ss_id
                                WHEN NULL                       THEN FND_API.G_TRUE
                                WHEN get_pdh_source_system_id   THEN FND_API.G_TRUE
                                ELSE FND_API.G_FALSE
                            END;
        Debug_Conc_Log( 'Is PDH Batch:' || x_is_pdh_batch );
        x_master_org_id :=  l_org_id;
        Debug_Conc_Log( 'Master Org ID:' || x_master_org_id );

        Debug_Conc_Log( 'Done resolving merge parameters from batch header' );
    END merge_params_from_batch_header;


    PROCEDURE merge_rev_attrs   ( p_batch_id       IN NUMBER
                                , p_is_pdh_batch   IN FLAG      DEFAULT NULL
                                , p_ss_id          IN NUMBER    DEFAULT NULL
                                , p_master_org_id  IN NUMBER    DEFAULT NULL
                                , p_commit         IN FLAG      DEFAULT FND_API.G_FALSE
                                )
    IS
        --6468564:Perf issue replacing EGO_ATTRS_V
        CURSOR c_pdh_target_rev_attrs( cp_master_org_id EGO_ITM_USR_ATTR_INTRFC.ORGANIZATION_ID%TYPE, cp_rev_dl_id NUMBER ) IS
            SELECT  sub.*
                   ,EXT.DATA_TYPE DATA_TYPE_CODE
            FROM
                ( SELECT
                        EIUAI.ROWID rid
                        , COUNT( * ) OVER ( PARTITION BY
                                                    ITEM_NUMBER
                                                    , ATTR_GROUP_INT_NAME
                                                    , ATTR_INT_NAME
                                                    , COALESCE( EIUAI.ORGANIZATION_ID,
                                                                (   SELECT  ORGANIZATION_ID
                                                                    FROM    MTL_PARAMETERS P
                                                                    WHERE   P.ORGANIZATION_CODE = EIUAI.ORGANIZATION_CODE
                                                                ),
                                                                (   SELECT  ORGANIZATION_ID
                                                                    FROM    MTL_ITEM_REVISIONS_B R
                                                                    WHERE   R.REVISION_ID = EIUAI.REVISION_ID
                                                                ),
                                                                NVL2( ORGANIZATION_CODE, cp_master_org_id, NULL )
                                                              )
                                                    , NVL( eiuai.REVISION,
                                                           (    SELECT  r.REVISION
                                                                FROM    MTL_ITEM_REVISIONS_B r
                                                                WHERE   r.REVISION_ID = eiuai.REVISION_ID
                                                           )
                                                         )
                                                    , NVL( eiuai.ATTR_GROUP_TYPE, G_DEFAULT_ATTR_GROUP_TYPE )
                                          )
                        cnt
                        , RANK() OVER   ( ORDER BY
                                                    ITEM_NUMBER
                                                    , ATTR_GROUP_INT_NAME
                                                    , ATTR_INT_NAME
                                                    , COALESCE( EIUAI.ORGANIZATION_ID,
                                                                (   SELECT  ORGANIZATION_ID
                                                                    FROM    MTL_PARAMETERS P
                                                                    WHERE   P.ORGANIZATION_CODE = EIUAI.ORGANIZATION_CODE
                                                                ),
                                                                (   SELECT  ORGANIZATION_ID
                                                                    FROM    MTL_ITEM_REVISIONS_B R
                                                                    WHERE   R.REVISION_ID = EIUAI.REVISION_ID
                                                                ),
                                                                NVL2( ORGANIZATION_CODE, cp_master_org_id, NULL )
                                                              )
                                                    , NVL( eiuai.REVISION,
                                                           (    SELECT  r.REVISION
                                                                FROM    MTL_ITEM_REVISIONS_B r
                                                                WHERE   r.REVISION_ID = eiuai.REVISION_ID
                                                           )
                                                         )
                                                    , NVL( eiuai.ATTR_GROUP_TYPE, G_DEFAULT_ATTR_GROUP_TYPE )
                                        )
                        rnk
                        , eiuai.*
                   FROM EGO_ITM_USR_ATTR_INTRFC EIUAI, EGO_FND_DSC_FLX_CTX_EXT FL_CTX_EXT
                   WHERE DATA_SET_ID = p_batch_id
                     AND PROCESS_STATUS                           = 1
                     AND ITEM_NUMBER                              IS NOT NULL
                     AND FL_CTX_EXT.DESCRIPTIVE_FLEXFIELD_NAME    = NVL( EIUAI.ATTR_GROUP_TYPE, G_DEFAULT_ATTR_GROUP_TYPE )
                     AND FL_CTX_EXT.APPLICATION_ID                = 431
                     AND FL_CTX_EXT.DESCRIPTIVE_FLEX_CONTEXT_CODE = EIUAI.ATTR_GROUP_INT_NAME
                     AND FL_CTX_EXT.MULTI_ROW                     = 'N'
                     AND EXISTS( SELECT NULL
                                 FROM EGO_ATTR_GROUP_DL A
                                 WHERE A.DATA_LEVEL_ID = cp_rev_dl_id
                                   AND A.ATTR_GROUP_ID = FL_CTX_EXT.ATTR_GROUP_ID
                               )
                ) sub
                 ,FND_DESCR_FLEX_COLUMN_USAGES FL_COL
                 ,EGO_FND_DF_COL_USGS_EXT EXT
            WHERE sub.CNT > 1
              AND FL_COL.APPLICATION_ID                = 431
              AND FL_COL.DESCRIPTIVE_FLEX_CONTEXT_CODE = sub.ATTR_GROUP_INT_NAME
              AND FL_COL.END_USER_COLUMN_NAME          = sub.ATTR_INT_NAME
              AND FL_COL.DESCRIPTIVE_FLEXFIELD_NAME    = SUB.ATTR_GROUP_TYPE
              AND EXT.APPLICATION_ID                   = FL_COL.APPLICATION_ID
              AND EXT.DESCRIPTIVE_FLEXFIELD_NAME       = FL_COL.DESCRIPTIVE_FLEXFIELD_NAME
              AND EXT.DESCRIPTIVE_FLEX_CONTEXT_CODE    = FL_COL.DESCRIPTIVE_FLEX_CONTEXT_CODE
              AND EXT.APPLICATION_COLUMN_NAME          = FL_COL.APPLICATION_COLUMN_NAME
            ORDER BY rnk, sub.last_update_date DESC, interface_table_unique_id DESC ;

        --6468564:Perf issue replacing EGO_ATTRS_V
        CURSOR c_ss_target_rev_attrs( cp_master_org_id EGO_ITM_USR_ATTR_INTRFC.ORGANIZATION_ID%TYPE, cp_rev_dl_id NUMBER ) IS
            SELECT  sub.*
                   ,EXT.DATA_TYPE DATA_TYPE_CODE
            FROM
                ( SELECT
                        EIUAI.ROWID rid
                        , COUNT( * ) OVER ( PARTITION BY
                                                    SOURCE_SYSTEM_ID
                                                    , SOURCE_SYSTEM_REFERENCE
                                                    , ATTR_GROUP_INT_NAME
                                                    , ATTR_INT_NAME
                                                    , COALESCE( EIUAI.ORGANIZATION_ID,
                                                                (   SELECT  ORGANIZATION_ID
                                                                    FROM    MTL_PARAMETERS P
                                                                    WHERE   P.ORGANIZATION_CODE = EIUAI.ORGANIZATION_CODE
                                                                ),
                                                                (   SELECT  ORGANIZATION_ID
                                                                    FROM    MTL_ITEM_REVISIONS_B R
                                                                    WHERE   R.REVISION_ID = EIUAI.REVISION_ID
                                                                ),
                                                                NVL2( ORGANIZATION_CODE, cp_master_org_id, NULL )
                                                              )
                                                    , NVL( eiuai.REVISION,
                                                           (    SELECT  r.REVISION
                                                                FROM    MTL_ITEM_REVISIONS_B r
                                                                WHERE   r.REVISION_ID = eiuai.REVISION_ID
                                                           )
                                                         )
                                                    , NVL( eiuai.ATTR_GROUP_TYPE, G_DEFAULT_ATTR_GROUP_TYPE )
                                          )
                        cnt
                        , RANK() OVER   ( ORDER BY
                                                    SOURCE_SYSTEM_ID
                                                    , SOURCE_SYSTEM_REFERENCE
                                                    , ATTR_GROUP_INT_NAME
                                                    , ATTR_INT_NAME
                                                    , COALESCE( EIUAI.ORGANIZATION_ID,
                                                                (   SELECT  ORGANIZATION_ID
                                                                    FROM    MTL_PARAMETERS P
                                                                    WHERE   P.ORGANIZATION_CODE = EIUAI.ORGANIZATION_CODE
                                                                ),
                                                                (   SELECT  ORGANIZATION_ID
                                                                    FROM    MTL_ITEM_REVISIONS_B R
                                                                    WHERE   R.REVISION_ID = EIUAI.REVISION_ID
                                                                ),
                                                                NVL2( ORGANIZATION_CODE, cp_master_org_id, NULL )
                                                              )
                                                    , NVL( eiuai.REVISION,
                                                           (    SELECT  r.REVISION
                                                                FROM    MTL_ITEM_REVISIONS_B r
                                                                WHERE   r.REVISION_ID = eiuai.REVISION_ID
                                                           )
                                                         )
                                                    , NVL( eiuai.ATTR_GROUP_TYPE, G_DEFAULT_ATTR_GROUP_TYPE )
                                        )
                        rnk
                        , eiuai.*
                   FROM EGO_ITM_USR_ATTR_INTRFC EIUAI, EGO_FND_DSC_FLX_CTX_EXT FL_CTX_EXT
                   WHERE DATA_SET_ID                              = p_batch_id
                     AND PROCESS_STATUS                           = 0
                     AND FL_CTX_EXT.DESCRIPTIVE_FLEXFIELD_NAME    = NVL( EIUAI.ATTR_GROUP_TYPE, G_DEFAULT_ATTR_GROUP_TYPE )
                     AND FL_CTX_EXT.APPLICATION_ID                = 431
                     AND FL_CTX_EXT.DESCRIPTIVE_FLEX_CONTEXT_CODE = EIUAI.ATTR_GROUP_INT_NAME
                     AND FL_CTX_EXT.MULTI_ROW                     = 'N'
                     AND EXISTS( SELECT NULL
                                 FROM EGO_ATTR_GROUP_DL A
                                 WHERE A.DATA_LEVEL_ID = cp_rev_dl_id
                                   AND A.ATTR_GROUP_ID = FL_CTX_EXT.ATTR_GROUP_ID
                               )
                ) sub
                 ,FND_DESCR_FLEX_COLUMN_USAGES FL_COL
                 ,EGO_FND_DF_COL_USGS_EXT EXT
            WHERE sub.CNT > 1
              AND FL_COL.APPLICATION_ID                = 431
              AND FL_COL.DESCRIPTIVE_FLEX_CONTEXT_CODE = sub.ATTR_GROUP_INT_NAME
              AND FL_COL.END_USER_COLUMN_NAME          = sub.ATTR_INT_NAME
              AND FL_COL.DESCRIPTIVE_FLEXFIELD_NAME    = SUB.ATTR_GROUP_TYPE
              AND EXT.APPLICATION_ID                   = FL_COL.APPLICATION_ID
              AND EXT.DESCRIPTIVE_FLEXFIELD_NAME       = FL_COL.DESCRIPTIVE_FLEXFIELD_NAME
              AND EXT.DESCRIPTIVE_FLEX_CONTEXT_CODE    = FL_COL.DESCRIPTIVE_FLEX_CONTEXT_CODE
              AND EXT.APPLICATION_COLUMN_NAME          = FL_COL.APPLICATION_COLUMN_NAME
            ORDER BY rnk, sub.last_update_date DESC, interface_table_unique_id DESC ;

        TYPE TARGET_ROWS    IS TABLE OF c_pdh_target_rev_attrs%ROWTYPE;

        l_merged_rows   EIUAI_ROWS;
        l_merge_base    EIUAI_ROW;
        l_old_rows      TARGET_ROWS;
        l_old_rowids    UROWID_TABLE;

        l_ss_id         EGO_ITM_USR_ATTR_INTRFC.SOURCE_SYSTEM_ID%TYPE := p_ss_id;
        l_ssr           EGO_ITM_USR_ATTR_INTRFC.SOURCE_SYSTEM_REFERENCE%TYPE;
        l_candidate_trans EGO_ITM_USR_ATTR_INTRFC.TRANSACTION_TYPE%TYPE;

        l_cur_rank      PLS_INTEGER := 0; -- because rank() starts at 1
        l_mrow_ix       PLS_INTEGER := 0;
        l_is_pdh_batch  BOOLEAN;

        l_data_type_code EGO_ATTRS_V.DATA_TYPE_CODE%TYPE;

        l_org_id        EGO_ITM_USR_ATTR_INTRFC.ORGANIZATION_ID%TYPE := p_master_org_id;
        l_pdh_batch_flag FLAG := p_is_pdh_batch;
        l_rev_dl_id     NUMBER;

        l_proc_log_prefix CONSTANT VARCHAR2(30) := '  merge_rev_attrs - ';
    BEGIN
        Debug_Conc_Log( l_proc_log_prefix || 'Entering' );
        Debug_Conc_Log( l_proc_log_prefix || 'Batch ID: ' || p_batch_id );
        BEGIN
          SELECT DATA_LEVEL_ID INTO l_rev_dl_id
          FROM EGO_DATA_LEVEL_B
          WHERE ATTR_GROUP_TYPE = 'EGO_ITEMMGMT_GROUP'
            AND APPLICATION_ID = 431
            AND DATA_LEVEL_NAME = 'ITEM_REVISION_LEVEL';
        EXCEPTION WHEN NO_DATA_FOUND THEN
          RETURN;
        END;
        Debug_Conc_Log( l_proc_log_prefix || 'l_rev_dl_id: ' || l_rev_dl_id );
        IF  l_pdh_batch_flag IS NULL OR l_org_id IS NULL OR l_ss_id IS NULL THEN
            merge_params_from_batch_header( p_batch_id      => p_batch_id
                                          , x_is_pdh_batch  => l_pdh_batch_flag
                                          , x_ss_id         => l_ss_id
                                          , x_master_org_id => l_org_id
                                          );
        END IF;
        Debug_Conc_Log( l_proc_log_prefix || 'Master Org ID: '|| l_org_id );
        Debug_Conc_Log( l_proc_log_prefix || 'SS ID: ' || l_ss_id );
        Debug_Conc_Log( l_proc_log_prefix || 'Is PDH Batch?: '|| l_pdh_batch_flag );

        l_is_pdh_batch  := ( l_pdh_batch_flag = FND_API.G_TRUE );
        IF  l_is_pdh_batch THEN
            -- DBMS_OUTPUT.PUT_LINE( 'PDH Batch' );
            OPEN c_pdh_target_rev_attrs( l_org_id, l_rev_dl_id );
            FETCH c_pdh_target_rev_attrs BULK COLLECT INTO l_old_rows;
            CLOSE c_pdh_target_rev_attrs;
        ELSE
            -- DBMS_OUTPUT.PUT_LINE( 'SS Batch' );
            OPEN c_ss_target_rev_attrs( l_org_id, l_rev_dl_id );
            FETCH c_ss_target_rev_attrs BULK COLLECT INTO l_old_rows;
            CLOSE c_ss_target_rev_attrs;
        END IF;

        Debug_Conc_Log( l_proc_log_prefix || 'Rows requiring merging: ' || l_old_rows.COUNT );
        IF  0 <> l_old_rows.COUNT THEN
            -- attributes common to every merged row
            l_merge_base.DATA_SET_ID    := p_batch_id;
            l_merge_base.PROCESS_STATUS := CASE WHEN l_is_pdh_batch THEN 1 ELSE 0 END;

            l_old_rowids := UROWID_TABLE( );
            l_old_rowids.EXTEND( l_old_rows.COUNT );

            -- process the item-level attrs
            FOR orow_ix IN l_old_rows.FIRST .. l_old_rows.LAST LOOP
                l_old_rowids( orow_ix ) := l_old_rows( orow_ix ).RID;

                IF( l_old_rows( orow_ix ).RNK <> l_cur_rank ) THEN
                    l_cur_rank := l_old_rows( orow_ix ).RNK;
                    Debug_Conc_Log( l_proc_log_prefix || '  Starting new merged row; rank = '|| l_cur_rank );
                    l_mrow_ix := l_mrow_ix + 1;
                    l_merged_rows( l_mrow_ix ) := l_merge_base;
                    IF NOT l_is_pdh_batch THEN
                        l_merged_rows( l_mrow_ix ).SOURCE_SYSTEM_ID          := l_old_rows( orow_ix ).SOURCE_SYSTEM_ID;
                        l_merged_rows( l_mrow_ix ).SOURCE_SYSTEM_REFERENCE   := l_old_rows( orow_ix ).SOURCE_SYSTEM_REFERENCE;
                        Debug_Conc_Log( l_proc_log_prefix || '   Source System Reference = ' || l_merged_rows( l_mrow_ix ).SOURCE_SYSTEM_REFERENCE );
                    END IF;

                    l_merged_rows( l_mrow_ix ).ATTR_GROUP_INT_NAME  := l_old_rows( orow_ix ).ATTR_GROUP_INT_NAME;
                    l_merged_rows( l_mrow_ix ).ATTR_INT_NAME        := l_old_rows( orow_ix ).ATTR_INT_NAME;
                    l_merged_rows( l_mrow_ix ).DATA_LEVEL_ID        := l_old_rows( orow_ix ).DATA_LEVEL_ID;
                    l_data_type_code := l_old_rows( orow_ix ).DATA_TYPE_CODE;
                    Debug_Conc_Log( l_proc_log_prefix || '   AttrGroup = ' || l_merged_rows( l_mrow_ix ).ATTR_GROUP_INT_NAME
                                                      || ', Attr = '    || l_merged_rows( l_mrow_ix ).ATTR_INT_NAME
                                                      || ', AttrDataTypeCode = ' || l_data_type_code
                                  );
                ELSE
                    Debug_Conc_Log( l_proc_log_prefix || '  Merging another record into current merged row; rank = '|| l_cur_rank );
                END IF;

                -- Special Cases:
                -- Transaction type
                l_candidate_trans := UPPER( l_old_rows( orow_ix ).TRANSACTION_TYPE );

                IF      l_merged_rows( l_mrow_ix ).TRANSACTION_TYPE IS NULL
                    OR  l_merged_rows( l_mrow_ix ).TRANSACTION_TYPE <> l_candidate_trans     -- <> filters out nulls
                THEN
                    -- CREATE > SYNC > UPDATE : order of case expression matters
                    l_merged_rows( l_mrow_ix ).TRANSACTION_TYPE :=
                        CASE
                            WHEN l_merged_rows( l_mrow_ix ).TRANSACTION_TYPE = G_TRANS_TYPE_CREATE
                              OR l_candidate_trans = G_TRANS_TYPE_CREATE                            THEN G_TRANS_TYPE_CREATE
                            WHEN l_merged_rows( l_mrow_ix ).TRANSACTION_TYPE = G_TRANS_TYPE_SYNC
                              OR l_candidate_trans = G_TRANS_TYPE_SYNC                              THEN G_TRANS_TYPE_SYNC
                            WHEN l_merged_rows( l_mrow_ix ).TRANSACTION_TYPE = G_TRANS_TYPE_UPDATE
                              OR l_candidate_trans = G_TRANS_TYPE_UPDATE                            THEN G_TRANS_TYPE_UPDATE
                            ELSE NULL -- INVALID transaction types encountered so far ...
                        END;
                END IF;


                -- The following columns need to be treated as atomic groups
                -- 1. Item Identifier
                IF      l_merged_rows( l_mrow_ix ).INVENTORY_ITEM_ID  IS NULL
                    AND l_merged_rows( l_mrow_ix ).ITEM_NUMBER        IS NULL
                THEN
                    l_merged_rows( l_mrow_ix ).INVENTORY_ITEM_ID  := l_old_rows( orow_ix ).INVENTORY_ITEM_ID;
                    l_merged_rows( l_mrow_ix ).ITEM_NUMBER        := l_old_rows( orow_ix ).ITEM_NUMBER;
                END IF;

                -- 2. Organization
                IF      l_merged_rows( l_mrow_ix ).ORGANIZATION_ID    IS NULL
                    AND l_merged_rows( l_mrow_ix ).ORGANIZATION_CODE  IS NULL
                THEN
                    l_merged_rows( l_mrow_ix ).ORGANIZATION_ID        := l_old_rows( orow_ix ).ORGANIZATION_ID ;
                    l_merged_rows( l_mrow_ix ).ORGANIZATION_CODE      := l_old_rows( orow_ix ).ORGANIZATION_CODE ;
                END IF;

                -- 3. Revision

                -- 4. The attribute value
                IF      l_merged_rows( l_mrow_ix ).ATTR_DISP_VALUE  IS NULL
                    AND l_merged_rows( l_mrow_ix ).ATTR_VALUE_STR   IS NULL
                    AND l_merged_rows( l_mrow_ix ).ATTR_VALUE_DATE  IS NULL
                    AND l_merged_rows( l_mrow_ix ).ATTR_VALUE_NUM   IS NULL
                    AND l_merged_rows( l_mrow_ix ).ATTR_VALUE_UOM       IS NULL
                    AND l_merged_rows( l_mrow_ix ).ATTR_UOM_DISP_VALUE  IS NULL
                THEN
                    CASE
                        WHEN l_data_type_code = 'C' OR l_data_type_code = 'A' THEN      -- String Attribute
                            IF      l_old_rows( orow_ix ).ATTR_VALUE_STR    IS NOT NULL
                                OR  l_old_rows( orow_ix ).ATTR_DISP_VALUE   IS NOT NULL
                            THEN
                                l_merged_rows( l_mrow_ix ).ATTR_VALUE_STR       := l_old_rows( orow_ix ).ATTR_VALUE_STR;
                                l_merged_rows( l_mrow_ix ).ATTR_DISP_VALUE      := l_old_rows( orow_ix ).ATTR_DISP_VALUE;
                                l_merged_rows( l_mrow_ix ).ATTR_VALUE_UOM       := l_old_rows( orow_ix ).ATTR_VALUE_UOM;
                                l_merged_rows( l_mrow_ix ).ATTR_UOM_DISP_VALUE  := l_old_rows( orow_ix ).ATTR_UOM_DISP_VALUE;
                            END IF;
                        WHEN l_data_type_code = 'X' or l_data_type_code = 'Y' THEN      -- Date Attribute
                            IF      l_old_rows( orow_ix ).ATTR_VALUE_DATE   IS NOT NULL
                                OR  l_old_rows( orow_ix ).ATTR_DISP_VALUE   IS NOT NULL
                            THEN
                                l_merged_rows( l_mrow_ix ).ATTR_VALUE_DATE      := l_old_rows( orow_ix ).ATTR_VALUE_DATE;
                                l_merged_rows( l_mrow_ix ).ATTR_DISP_VALUE      := l_old_rows( orow_ix ).ATTR_DISP_VALUE;
                                l_merged_rows( l_mrow_ix ).ATTR_VALUE_UOM       := l_old_rows( orow_ix ).ATTR_VALUE_UOM;
                                l_merged_rows( l_mrow_ix ).ATTR_UOM_DISP_VALUE  := l_old_rows( orow_ix ).ATTR_UOM_DISP_VALUE;
                            END IF;
                        WHEN l_data_type_code = 'N' THEN                                -- Num Attribute
                            IF      l_old_rows( orow_ix ).ATTR_VALUE_NUM    IS NOT NULL
                                OR  l_old_rows( orow_ix ).ATTR_DISP_VALUE   IS NOT NULL
                            THEN
                                l_merged_rows( l_mrow_ix ).ATTR_VALUE_NUM       := l_old_rows( orow_ix ).ATTR_VALUE_NUM;
                                l_merged_rows( l_mrow_ix ).ATTR_DISP_VALUE      := l_old_rows( orow_ix ).ATTR_DISP_VALUE;
                                l_merged_rows( l_mrow_ix ).ATTR_VALUE_UOM       := l_old_rows( orow_ix ).ATTR_VALUE_UOM;
                                l_merged_rows( l_mrow_ix ).ATTR_UOM_DISP_VALUE  := l_old_rows( orow_ix ).ATTR_UOM_DISP_VALUE;
                            END IF;
                    END CASE;
                END IF;

                -- Non-special cased
                -- Start Generated Code
                /* Generated using:
                    SET LINESIZE 200
                    SELECT  'if l_merged_rows( l_mrow_ix ).' ||column_name || ' is null then l_merged_rows( l_mrow_ix ).' || column_name || ' := l_old_rows( orow_ix ).' || column_name || '; end if; '
                    FROM    ALL_TAB_COLUMNS
                    WHERE   TABLE_NAME = 'EGO_ITM_USR_ATTR_INTRFC'
                    AND COLUMN_NAME NOT IN
                        ( -- special cases (for merge)
                          'INVENTORY_ITEM_ID'
                        , 'ITEM_NUMBER'
                        , 'ORGANIZATION_ID'
                        , 'ORGANIZATION_CODE'
                        , 'TRANSACTION_TYPE'
                        , 'ATTR_INT_NAME'
                        , 'ATTR_GROUP_INT_NAME'
                        , 'ATTR_DISP_VALUE'
                        , 'ATTR_VALUE_STR'
                        , 'ATTR_VALUE_DATE'
                        , 'ATTR_VALUE_NUM'
                        , 'ATTR_VALUE_UOM'
                        , 'ATTR_UOM_DISP_VALUE'
                        , 'ATTR_GROUP_ID' -- ignore; assume will be filled during processing
                          -- special columns
                        , 'DATA_SET_ID'
                        , 'PROCESS_STATUS'
                        , 'SOURCE_SYSTEM_ID'
                        , 'SOURCE_SYSTEM_REFERENCE'
                        , 'INTERFACE_TABLE_UNIQUE_ID' -- should be handled by INSERT trigger
                          -- who columns
                        , 'LAST_UPDATE_DATE'
                        , 'CREATION_DATE'
                        , 'CREATED_BY'
                        , 'LAST_UPDATED_BY'
                        , 'LAST_UPDATE_LOGIN'
                          -- XXX: exclude concurrent processing columns?
                        )
                    ORDER BY COLUMN_NAME ASC
                */
                if l_merged_rows( l_mrow_ix ).ATTR_GROUP_TYPE is null then l_merged_rows( l_mrow_ix ).ATTR_GROUP_TYPE := l_old_rows( orow_ix ).ATTR_GROUP_TYPE; end if;
                if l_merged_rows( l_mrow_ix ).CHANGE_ID is null then l_merged_rows( l_mrow_ix ).CHANGE_ID := l_old_rows( orow_ix ).CHANGE_ID; end if;
                if l_merged_rows( l_mrow_ix ).CHANGE_LINE_ID is null then l_merged_rows( l_mrow_ix ).CHANGE_LINE_ID := l_old_rows( orow_ix ).CHANGE_LINE_ID; end if;
                if l_merged_rows( l_mrow_ix ).ITEM_CATALOG_GROUP_ID is null then l_merged_rows( l_mrow_ix ).ITEM_CATALOG_GROUP_ID := l_old_rows( orow_ix ).ITEM_CATALOG_GROUP_ID; end if;
                if l_merged_rows( l_mrow_ix ).PROGRAM_APPLICATION_ID is null then l_merged_rows( l_mrow_ix ).PROGRAM_APPLICATION_ID := l_old_rows( orow_ix ).PROGRAM_APPLICATION_ID; end if;
                if l_merged_rows( l_mrow_ix ).PROGRAM_ID is null then l_merged_rows( l_mrow_ix ).PROGRAM_ID := l_old_rows( orow_ix ).PROGRAM_ID; end if;
                if l_merged_rows( l_mrow_ix ).PROGRAM_UPDATE_DATE is null then l_merged_rows( l_mrow_ix ).PROGRAM_UPDATE_DATE := l_old_rows( orow_ix ).PROGRAM_UPDATE_DATE; end if;
                if l_merged_rows( l_mrow_ix ).REVISION is null then l_merged_rows( l_mrow_ix ).REVISION := l_old_rows( orow_ix ).REVISION; end if;
                if l_merged_rows( l_mrow_ix ).REVISION_ID is null then l_merged_rows( l_mrow_ix ).REVISION_ID := l_old_rows( orow_ix ).REVISION_ID; end if;
                if l_merged_rows( l_mrow_ix ).REQUEST_ID is null then l_merged_rows( l_mrow_ix ).REQUEST_ID := l_old_rows( orow_ix ).REQUEST_ID; end if;
                if l_merged_rows( l_mrow_ix ).ROW_IDENTIFIER is null then l_merged_rows( l_mrow_ix ).ROW_IDENTIFIER := l_old_rows( orow_ix ).ROW_IDENTIFIER; end if;
                if l_merged_rows( l_mrow_ix ).TRANSACTION_ID is null then l_merged_rows( l_mrow_ix ).TRANSACTION_ID := l_old_rows( orow_ix ).TRANSACTION_ID; end if;
                -- End Generated Code
            END LOOP; -- loop over old rows

            /*
            -- XXX: In case only null/invalid transaction types encountered, set transaction type to SYNC ?.
            IF l_merged_rows( l_mrow_ix ).TRANSACTION_TYPE IS NULL THEN
                l_merged_rows( l_mrow_ix ).TRANSACTION_TYPE := G_TRANS_TYPE_SYNC;
            END IF;
            */
            IF l_merged_rows IS NOT NULL THEN
                -- delete
                Debug_Conc_Log( l_proc_log_prefix || 'Deleting ' || l_old_rowids.COUNT || ' old rows ...' );
                FORALL rid_ix IN INDICES OF l_old_rowids
                    DELETE FROM EGO_ITM_USR_ATTR_INTRFC
                        WHERE ROWID = l_old_rowids( rid_ix );
                -- insert
                Debug_Conc_Log( l_proc_log_prefix || 'Inserting ' || l_merged_rows.COUNT || ' merged rows ...' );
                FORALL row_index IN INDICES OF l_merged_rows
                    INSERT INTO EGO_ITM_USR_ATTR_INTRFC
                        VALUES l_merged_rows( row_index );
            END IF;
        END IF; -- ENDS IF l_old_rows.count <> 0

        IF p_commit = FND_API.G_TRUE THEN
            Debug_Conc_Log( l_proc_log_prefix || 'Committing' );
            COMMIT;
        END IF;
        Debug_Conc_Log( l_proc_log_prefix || 'Exiting' );
    END merge_rev_attrs;

    PROCEDURE merge_item_attrs  ( p_batch_id       IN NUMBER
                                , p_is_pdh_batch   IN FLAG      DEFAULT NULL
                                , p_ss_id          IN NUMBER    DEFAULT NULL
                                , p_master_org_id  IN NUMBER    DEFAULT NULL
                                , p_commit         IN FLAG      DEFAULT FND_API.G_FALSE
                                )
    IS

        --6468564:Perf issue replacing EGO_ATTRS_V
        CURSOR c_pdh_target_item_attrs( cp_master_org_id EGO_ITM_USR_ATTR_INTRFC.ORGANIZATION_ID%TYPE ) IS
            SELECT  sub.*
                ,EXT.DATA_TYPE DATA_TYPE_CODE
            FROM
                ( SELECT
                        eiuai.ROWID rid
                        , COUNT( * ) OVER ( PARTITION BY
                                                    ITEM_NUMBER
                                                    , ATTR_GROUP_INT_NAME
                                                    , ATTR_INT_NAME
                                                    , DATA_LEVEL_ID
                                                    , PK1_VALUE
                                                    , PK2_VALUE
                                                    , PK3_VALUE
                                                    , PK4_VALUE
                                                    , PK5_VALUE
                                                    , COALESCE  ( eiuai.ORGANIZATION_ID
                                                                , (  SELECT  ORGANIZATION_ID
                                                                     FROM    MTL_PARAMETERS p
                                                                     WHERE   p.ORGANIZATION_CODE = eiuai.ORGANIZATION_CODE
                                                                  )
                                                                , NVL2( ORGANIZATION_CODE, cp_master_org_id, NULL )
                                                                )
                                                    , NVL(  ATTR_GROUP_TYPE, G_DEFAULT_ATTR_GROUP_TYPE )
                                          )
                        cnt
                        , RANK() OVER   ( ORDER BY
                                                    ITEM_NUMBER
                                                    , ATTR_GROUP_INT_NAME
                                                    , ATTR_INT_NAME
                                                    , DATA_LEVEL_ID
                                                    , PK1_VALUE
                                                    , PK2_VALUE
                                                    , PK3_VALUE
                                                    , PK4_VALUE
                                                    , PK5_VALUE
                                                    , COALESCE  ( eiuai.ORGANIZATION_ID
                                                                , (  SELECT  ORGANIZATION_ID
                                                                     FROM    MTL_PARAMETERS p
                                                                     WHERE   p.ORGANIZATION_CODE = eiuai.ORGANIZATION_CODE
                                                                  )
                                                                , NVL2( ORGANIZATION_CODE, cp_master_org_id, NULL )
                                                                )
                                                    , NVL(  ATTR_GROUP_TYPE, G_DEFAULT_ATTR_GROUP_TYPE )
                                        )
                        rnk
                        , eiuai.*
                   FROM EGO_ITM_USR_ATTR_INTRFC eiuai, EGO_FND_DSC_FLX_CTX_EXT FL_CTX_EXT
                   WHERE DATA_SET_ID                              = p_batch_id
                     AND PROCESS_STATUS                           = 1
                     AND FL_CTX_EXT.DESCRIPTIVE_FLEXFIELD_NAME    = NVL( EIUAI.ATTR_GROUP_TYPE, G_DEFAULT_ATTR_GROUP_TYPE )
                     AND FL_CTX_EXT.APPLICATION_ID                = 431
                     AND FL_CTX_EXT.DESCRIPTIVE_FLEX_CONTEXT_CODE = EIUAI.ATTR_GROUP_INT_NAME
                     AND FL_CTX_EXT.MULTI_ROW                     = 'N'
                     AND EXISTS( SELECT NULL
                                 FROM EGO_ATTR_GROUP_DL A, EGO_DATA_LEVEL_B DL
                                 WHERE DL.APPLICATION_ID  = 431
                                   AND DL.ATTR_GROUP_TYPE = FL_CTX_EXT.DESCRIPTIVE_FLEXFIELD_NAME
                                   AND DL.DATA_LEVEL_NAME IN ( 'ITEM_LEVEL' , 'ITEM_ORG', 'ITEM_SUP', 'ITEM_SUP_SITE', 'ITEM_SUP_SITE_ORG' )
                                   /* Bug:11887867
                                   AND DL.DATA_LEVEL_ID   = DL.DATA_LEVEL_ID
                                   */
                                   AND A.DATA_LEVEL_ID   = DL.DATA_LEVEL_ID
                                   AND A.ATTR_GROUP_ID    = FL_CTX_EXT.ATTR_GROUP_ID
                               )
                ) sub
                 ,FND_DESCR_FLEX_COLUMN_USAGES FL_COL
                 ,EGO_FND_DF_COL_USGS_EXT EXT
            WHERE sub.CNT > 1
              AND FL_COL.APPLICATION_ID                = 431
              AND FL_COL.DESCRIPTIVE_FLEX_CONTEXT_CODE = sub.ATTR_GROUP_INT_NAME
              AND FL_COL.END_USER_COLUMN_NAME          = sub.ATTR_INT_NAME
              AND FL_COL.DESCRIPTIVE_FLEXFIELD_NAME    = SUB.ATTR_GROUP_TYPE
              AND EXT.APPLICATION_ID                   = FL_COL.APPLICATION_ID
              AND EXT.DESCRIPTIVE_FLEXFIELD_NAME       = FL_COL.DESCRIPTIVE_FLEXFIELD_NAME
              AND EXT.DESCRIPTIVE_FLEX_CONTEXT_CODE    = FL_COL.DESCRIPTIVE_FLEX_CONTEXT_CODE
              AND EXT.APPLICATION_COLUMN_NAME          = FL_COL.APPLICATION_COLUMN_NAME
            ORDER BY rnk, sub.last_update_date DESC, interface_table_unique_id DESC ;

        --6468564 : Perf issue replacing EGO_ATTRS_V
        CURSOR c_ss_target_item_attrs( cp_master_org_id EGO_ITM_USR_ATTR_INTRFC.ORGANIZATION_ID%TYPE ) IS
            SELECT  sub.*
                   ,EXT.DATA_TYPE DATA_TYPE_CODE
            FROM
                ( SELECT
                        EIUAI.ROWID rid
                        , COUNT( * ) OVER ( PARTITION BY
                                                    SOURCE_SYSTEM_ID
                                                    , SOURCE_SYSTEM_REFERENCE
                                                    , ATTR_GROUP_INT_NAME
                                                    , ATTR_INT_NAME
                                                    , DATA_LEVEL_ID
                                                    , PK1_VALUE
                                                    , PK2_VALUE
                                                    , PK3_VALUE
                                                    , PK4_VALUE
                                                    , PK5_VALUE
                                                    , COALESCE  ( eiuai.ORGANIZATION_ID
                                                                , (  SELECT  ORGANIZATION_ID
                                                                     FROM    MTL_PARAMETERS p
                                                                     WHERE   p.ORGANIZATION_CODE = eiuai.ORGANIZATION_CODE
                                                                  )
                                                                , NVL2( ORGANIZATION_CODE, cp_master_org_id, NULL )
                                                                )
                                                    , NVL( ATTR_GROUP_TYPE, G_DEFAULT_ATTR_GROUP_TYPE )
                                          )
                        cnt
                        , RANK() OVER   ( ORDER BY
                                                    SOURCE_SYSTEM_ID
                                                    , SOURCE_SYSTEM_REFERENCE
                                                    , ATTR_GROUP_INT_NAME
                                                    , ATTR_INT_NAME
                                                    , DATA_LEVEL_ID
                                                    , PK1_VALUE
                                                    , PK2_VALUE
                                                    , PK3_VALUE
                                                    , PK4_VALUE
                                                    , PK5_VALUE
                                                    , COALESCE  ( eiuai.ORGANIZATION_ID
                                                                , (  SELECT  ORGANIZATION_ID
                                                                     FROM    MTL_PARAMETERS p
                                                                     WHERE   p.ORGANIZATION_CODE = eiuai.ORGANIZATION_CODE
                                                                  )
                                                                , NVL2( ORGANIZATION_CODE, cp_master_org_id, NULL )
                                                                )
                                                    , NVL( ATTR_GROUP_TYPE, G_DEFAULT_ATTR_GROUP_TYPE )
                                        )
                        rnk
                        , eiuai.*
                   FROM EGO_ITM_USR_ATTR_INTRFC eiuai, EGO_FND_DSC_FLX_CTX_EXT FL_CTX_EXT
                   WHERE DATA_SET_ID                              = p_batch_id
                     AND PROCESS_STATUS                           = 0
                     AND FL_CTX_EXT.DESCRIPTIVE_FLEXFIELD_NAME    = NVL( EIUAI.ATTR_GROUP_TYPE, G_DEFAULT_ATTR_GROUP_TYPE )
                     AND FL_CTX_EXT.APPLICATION_ID                = 431
                     AND FL_CTX_EXT.DESCRIPTIVE_FLEX_CONTEXT_CODE = EIUAI.ATTR_GROUP_INT_NAME
                     AND FL_CTX_EXT.MULTI_ROW                     = 'N'
                     AND EXISTS( SELECT NULL
                                 FROM EGO_ATTR_GROUP_DL A, EGO_DATA_LEVEL_B DL
                                 WHERE DL.APPLICATION_ID  = 431
                                   AND DL.ATTR_GROUP_TYPE = FL_CTX_EXT.DESCRIPTIVE_FLEXFIELD_NAME
                                   AND DL.DATA_LEVEL_NAME IN ( 'ITEM_LEVEL' , 'ITEM_ORG', 'ITEM_SUP', 'ITEM_SUP_SITE', 'ITEM_SUP_SITE_ORG' )
                                   /* Bug:11887867
                                   AND DL.DATA_LEVEL_ID   = DL.DATA_LEVEL_ID
                                   */
                                   AND A.DATA_LEVEL_ID   = DL.DATA_LEVEL_ID
                                   AND A.ATTR_GROUP_ID    = FL_CTX_EXT.ATTR_GROUP_ID
                               )
                ) sub
                 ,FND_DESCR_FLEX_COLUMN_USAGES FL_COL
                 ,EGO_FND_DF_COL_USGS_EXT EXT
            WHERE sub.CNT > 1
              AND FL_COL.APPLICATION_ID                = 431
              AND FL_COL.DESCRIPTIVE_FLEX_CONTEXT_CODE = sub.ATTR_GROUP_INT_NAME
              AND FL_COL.END_USER_COLUMN_NAME          = sub.ATTR_INT_NAME
              AND FL_COL.DESCRIPTIVE_FLEXFIELD_NAME    = SUB.ATTR_GROUP_TYPE
              AND EXT.APPLICATION_ID                   = FL_COL.APPLICATION_ID
              AND EXT.DESCRIPTIVE_FLEXFIELD_NAME       = FL_COL.DESCRIPTIVE_FLEXFIELD_NAME
              AND EXT.DESCRIPTIVE_FLEX_CONTEXT_CODE    = FL_COL.DESCRIPTIVE_FLEX_CONTEXT_CODE
              AND EXT.APPLICATION_COLUMN_NAME          = FL_COL.APPLICATION_COLUMN_NAME
            ORDER BY rnk, sub.last_update_date DESC, interface_table_unique_id DESC ;

        TYPE TARGET_ROWS    IS TABLE OF c_ss_target_item_attrs%ROWTYPE;

        l_merged_rows   EIUAI_ROWS;
        l_merge_base    EIUAI_ROW;
        l_old_rows      TARGET_ROWS;
        l_old_rowids    UROWID_TABLE;

        l_ss_id         EGO_ITM_USR_ATTR_INTRFC.SOURCE_SYSTEM_ID%TYPE := p_ss_id;
        l_ssr           EGO_ITM_USR_ATTR_INTRFC.SOURCE_SYSTEM_REFERENCE%TYPE;
        l_candidate_trans EGO_ITM_USR_ATTR_INTRFC.TRANSACTION_TYPE%TYPE;

        l_cur_rank      PLS_INTEGER := 0; -- because rank() starts at 1
        l_mrow_ix       PLS_INTEGER := 0;
        l_is_pdh_batch  BOOLEAN;

        l_data_type_code EGO_ATTRS_V.DATA_TYPE_CODE%TYPE;
        l_org_id        EGO_ITM_USR_ATTR_INTRFC.ORGANIZATION_ID%TYPE := p_master_org_id;
        l_pdh_batch_flag FLAG := p_is_pdh_batch;

        l_proc_log_prefix CONSTANT VARCHAR2(30) := '  merge_item_attrs - ';
    BEGIN
        Debug_Conc_Log( l_proc_log_prefix || 'Entering' );
        Debug_Conc_Log( l_proc_log_prefix || 'Batch ID: ' || p_batch_id );
        IF  l_pdh_batch_flag IS NULL OR l_org_id IS NULL OR l_ss_id IS NULL THEN
            merge_params_from_batch_header( p_batch_id      => p_batch_id
                                          , x_is_pdh_batch  => l_pdh_batch_flag
                                          , x_master_org_id => l_org_id
                                          , x_ss_id         => l_ss_id
                                          );
        END IF;
        Debug_Conc_Log( l_proc_log_prefix || 'Master Org ID: ' || l_org_id );
        Debug_Conc_Log( l_proc_log_prefix || 'SS ID: ' || l_ss_id );
        Debug_Conc_Log( l_proc_log_prefix || 'Is PDH Batch?: ' || l_pdh_batch_flag );

        l_is_pdh_batch  := ( l_pdh_batch_flag = FND_API.G_TRUE );
        IF  l_is_pdh_batch THEN
            -- DBMS_OUTPUT.PUT_LINE( 'PDH Batch' );
            OPEN c_pdh_target_item_attrs( l_org_id );
            FETCH c_pdh_target_item_attrs BULK COLLECT INTO l_old_rows;
            CLOSE c_pdh_target_item_attrs;
        ELSE
            -- DBMS_OUTPUT.PUT_LINE( 'SS Batch' );
            OPEN c_ss_target_item_attrs( l_org_id );
            FETCH c_ss_target_item_attrs BULK COLLECT INTO l_old_rows;
            CLOSE c_ss_target_item_attrs;
        END IF;

        Debug_Conc_Log( l_proc_log_prefix || 'Rows requiring merging: ' || l_old_rows.COUNT );
        IF  0 <> l_old_rows.COUNT THEN
            -- attributes common to every merged row
            l_merge_base.DATA_SET_ID    := p_batch_id;
            l_merge_base.PROCESS_STATUS := CASE WHEN l_is_pdh_batch THEN 1 ELSE 0 END;

            l_old_rowids := UROWID_TABLE( );
            l_old_rowids.EXTEND( l_old_rows.COUNT );

            -- process the item-level attrs
            FOR orow_ix IN l_old_rows.FIRST .. l_old_rows.LAST LOOP
                l_old_rowids( orow_ix ) := l_old_rows( orow_ix ).RID;

                IF( l_old_rows( orow_ix ).RNK <> l_cur_rank ) THEN
                    l_cur_rank := l_old_rows( orow_ix ).RNK;
                    Debug_Conc_Log( l_proc_log_prefix || '  Starting new merged row; rank = '|| l_cur_rank );
                    l_mrow_ix := l_mrow_ix + 1;
                    l_merged_rows( l_mrow_ix ) := l_merge_base;
                    IF NOT l_is_pdh_batch THEN
                        l_merged_rows( l_mrow_ix ).SOURCE_SYSTEM_ID          := l_old_rows( orow_ix ).SOURCE_SYSTEM_ID;
                        l_merged_rows( l_mrow_ix ).SOURCE_SYSTEM_REFERENCE   := l_old_rows( orow_ix ).SOURCE_SYSTEM_REFERENCE;
                        Debug_Conc_Log( l_proc_log_prefix || '   Source System Reference = ' || l_merged_rows( l_mrow_ix ).SOURCE_SYSTEM_REFERENCE );
                    END IF;

                    l_merged_rows( l_mrow_ix ).ATTR_GROUP_INT_NAME  := l_old_rows( orow_ix ).ATTR_GROUP_INT_NAME;
                    l_merged_rows( l_mrow_ix ).ATTR_INT_NAME        := l_old_rows( orow_ix ).ATTR_INT_NAME;
                    l_merged_rows( l_mrow_ix ).DATA_LEVEL_ID        := l_old_rows( orow_ix ).DATA_LEVEL_ID;
                    l_merged_rows( l_mrow_ix ).DATA_LEVEL_NAME      := l_old_rows( orow_ix ).DATA_LEVEL_NAME;
                    l_merged_rows( l_mrow_ix ).PK1_VALUE      := l_old_rows( orow_ix ).PK1_VALUE;
                    l_merged_rows( l_mrow_ix ).PK2_VALUE      := l_old_rows( orow_ix ).PK2_VALUE;
                    l_merged_rows( l_mrow_ix ).PK3_VALUE      := l_old_rows( orow_ix ).PK3_VALUE;
                    l_merged_rows( l_mrow_ix ).PK4_VALUE      := l_old_rows( orow_ix ).PK4_VALUE;
                    l_merged_rows( l_mrow_ix ).PK5_VALUE      := l_old_rows( orow_ix ).PK5_VALUE;
                    l_data_type_code := l_old_rows( orow_ix ).DATA_TYPE_CODE;
                    Debug_Conc_Log( l_proc_log_prefix || '   AttrGroup = ' || l_merged_rows( l_mrow_ix ).ATTR_GROUP_INT_NAME
                                                      || ', Attr = '    || l_merged_rows( l_mrow_ix ).ATTR_INT_NAME
                                                      || ', AttrDataTypeCode = ' || l_data_type_code
                                  );
                ELSE
                    Debug_Conc_Log( l_proc_log_prefix || '  Merging another record into current merged row; rank = '|| l_cur_rank );
                END IF;

                -- Special Cases:
                -- Transaction type
                l_candidate_trans := UPPER( l_old_rows( orow_ix ).TRANSACTION_TYPE );

                IF      l_merged_rows( l_mrow_ix ).TRANSACTION_TYPE IS NULL
                    OR  l_merged_rows( l_mrow_ix ).TRANSACTION_TYPE <> l_candidate_trans     -- <> filters out nulls
                THEN
                    -- CREATE > SYNC > UPDATE : order of case expression matters
                    l_merged_rows( l_mrow_ix ).TRANSACTION_TYPE :=
                        CASE
                            WHEN l_merged_rows( l_mrow_ix ).TRANSACTION_TYPE = G_TRANS_TYPE_CREATE
                              OR l_candidate_trans = G_TRANS_TYPE_CREATE                            THEN G_TRANS_TYPE_CREATE
                            WHEN l_merged_rows( l_mrow_ix ).TRANSACTION_TYPE = G_TRANS_TYPE_SYNC
                              OR l_candidate_trans = G_TRANS_TYPE_SYNC                              THEN G_TRANS_TYPE_SYNC
                            WHEN l_merged_rows( l_mrow_ix ).TRANSACTION_TYPE = G_TRANS_TYPE_UPDATE
                              OR l_candidate_trans = G_TRANS_TYPE_UPDATE                            THEN G_TRANS_TYPE_UPDATE
                            ELSE NULL -- INVALID transaction types encountered so far ...
                        END;
                END IF;


                -- The following columns need to be treated as atomic groups
                -- 1. Item Identifier
                IF      l_merged_rows( l_mrow_ix ).INVENTORY_ITEM_ID  IS NULL
                    AND l_merged_rows( l_mrow_ix ).ITEM_NUMBER        IS NULL
                THEN
                    l_merged_rows( l_mrow_ix ).INVENTORY_ITEM_ID  := l_old_rows( orow_ix ).INVENTORY_ITEM_ID;
                    l_merged_rows( l_mrow_ix ).ITEM_NUMBER        := l_old_rows( orow_ix ).ITEM_NUMBER;
                END IF;

                -- 2. Organization
                IF      l_merged_rows( l_mrow_ix ).ORGANIZATION_ID    IS NULL
                    AND l_merged_rows( l_mrow_ix ).ORGANIZATION_CODE  IS NULL
                THEN
                    l_merged_rows( l_mrow_ix ).ORGANIZATION_ID        := l_old_rows( orow_ix ).ORGANIZATION_ID ;
                    l_merged_rows( l_mrow_ix ).ORGANIZATION_CODE      := l_old_rows( orow_ix ).ORGANIZATION_CODE ;
                END IF;

                -- 3. The attribute value
                IF      l_merged_rows( l_mrow_ix ).ATTR_DISP_VALUE  IS NULL
                    AND l_merged_rows( l_mrow_ix ).ATTR_VALUE_STR   IS NULL
                    AND l_merged_rows( l_mrow_ix ).ATTR_VALUE_DATE  IS NULL
                    AND l_merged_rows( l_mrow_ix ).ATTR_VALUE_NUM   IS NULL
                    AND l_merged_rows( l_mrow_ix ).ATTR_VALUE_UOM       IS NULL
                    AND l_merged_rows( l_mrow_ix ).ATTR_UOM_DISP_VALUE  IS NULL
                THEN
                    CASE
                        WHEN l_data_type_code = 'C' OR l_data_type_code = 'A' THEN      -- String Attribute
                            IF      l_old_rows( orow_ix ).ATTR_VALUE_STR    IS NOT NULL
                                OR  l_old_rows( orow_ix ).ATTR_DISP_VALUE   IS NOT NULL
                            THEN
                                l_merged_rows( l_mrow_ix ).ATTR_VALUE_STR       := l_old_rows( orow_ix ).ATTR_VALUE_STR;
                                l_merged_rows( l_mrow_ix ).ATTR_DISP_VALUE      := l_old_rows( orow_ix ).ATTR_DISP_VALUE;
                                l_merged_rows( l_mrow_ix ).ATTR_VALUE_UOM       := l_old_rows( orow_ix ).ATTR_VALUE_UOM;
                                l_merged_rows( l_mrow_ix ).ATTR_UOM_DISP_VALUE  := l_old_rows( orow_ix ).ATTR_UOM_DISP_VALUE;
                            END IF;
                        WHEN l_data_type_code = 'X' or l_data_type_code = 'Y' THEN      -- Date Attribute
                            IF      l_old_rows( orow_ix ).ATTR_VALUE_DATE   IS NOT NULL
                                OR  l_old_rows( orow_ix ).ATTR_DISP_VALUE   IS NOT NULL
                            THEN
                                l_merged_rows( l_mrow_ix ).ATTR_VALUE_DATE      := l_old_rows( orow_ix ).ATTR_VALUE_DATE;
                                l_merged_rows( l_mrow_ix ).ATTR_DISP_VALUE      := l_old_rows( orow_ix ).ATTR_DISP_VALUE;
                                l_merged_rows( l_mrow_ix ).ATTR_VALUE_UOM       := l_old_rows( orow_ix ).ATTR_VALUE_UOM;
                                l_merged_rows( l_mrow_ix ).ATTR_UOM_DISP_VALUE  := l_old_rows( orow_ix ).ATTR_UOM_DISP_VALUE;
                            END IF;
                        WHEN l_data_type_code = 'N' THEN                                -- Num Attribute
                            IF      l_old_rows( orow_ix ).ATTR_VALUE_NUM    IS NOT NULL
                                OR  l_old_rows( orow_ix ).ATTR_DISP_VALUE   IS NOT NULL
                            THEN
                                l_merged_rows( l_mrow_ix ).ATTR_VALUE_NUM       := l_old_rows( orow_ix ).ATTR_VALUE_NUM;
                                l_merged_rows( l_mrow_ix ).ATTR_DISP_VALUE      := l_old_rows( orow_ix ).ATTR_DISP_VALUE;
                                l_merged_rows( l_mrow_ix ).ATTR_VALUE_UOM       := l_old_rows( orow_ix ).ATTR_VALUE_UOM;
                                l_merged_rows( l_mrow_ix ).ATTR_UOM_DISP_VALUE  := l_old_rows( orow_ix ).ATTR_UOM_DISP_VALUE;
                            END IF;
                    END CASE;
                END IF;

                -- Non-special cased
                -- Start Generated Code
                /* Generated using:
                    SET LINESIZE 200
                    SELECT  'if l_merged_rows( l_mrow_ix ).' ||column_name || ' is null then l_merged_rows( l_mrow_ix ).' || column_name || ' := l_old_rows( orow_ix ).' || column_name || '; end if; '
                    FROM    ALL_TAB_COLUMNS
                    WHERE   TABLE_NAME = 'EGO_ITM_USR_ATTR_INTRFC'
                    AND COLUMN_NAME NOT IN
                        ( -- special cases (for merge)
                          'INVENTORY_ITEM_ID'
                        , 'ITEM_NUMBER'
                        , 'ORGANIZATION_ID'
                        , 'ORGANIZATION_CODE'
                        , 'TRANSACTION_TYPE'
                        , 'REVISION_ID' -- ignore for item-level attrs
                        , 'REVISION'    -- ignore for item-level attrs
                        , 'ATTR_INT_NAME'
                        , 'ATTR_GROUP_INT_NAME'
                        , 'ATTR_DISP_VALUE'
                        , 'ATTR_VALUE_STR'
                        , 'ATTR_VALUE_DATE'
                        , 'ATTR_VALUE_NUM'
                        , 'ATTR_VALUE_UOM'
                        , 'ATTR_UOM_DISP_VALUE'
                        , 'ATTR_GROUP_ID' -- ignore; assume will be filled during processing
                          -- special columns
                        , 'DATA_SET_ID'
                        , 'PROCESS_STATUS'
                        , 'SOURCE_SYSTEM_ID'
                        , 'SOURCE_SYSTEM_REFERENCE'
                        , 'INTERFACE_TABLE_UNIQUE_ID' -- should be handled by INSERT trigger
                          -- who columns
                        , 'LAST_UPDATE_DATE'
                        , 'CREATION_DATE'
                        , 'CREATED_BY'
                        , 'LAST_UPDATED_BY'
                        , 'LAST_UPDATE_LOGIN'
                          -- XXX: exclude concurrent processing columns?
                        )
                    ORDER BY COLUMN_NAME ASC
                */
                if l_merged_rows( l_mrow_ix ).ATTR_GROUP_TYPE is null then l_merged_rows( l_mrow_ix ).ATTR_GROUP_TYPE := l_old_rows( orow_ix ).ATTR_GROUP_TYPE; end if;
                if l_merged_rows( l_mrow_ix ).CHANGE_ID is null then l_merged_rows( l_mrow_ix ).CHANGE_ID := l_old_rows( orow_ix ).CHANGE_ID; end if;
                if l_merged_rows( l_mrow_ix ).CHANGE_LINE_ID is null then l_merged_rows( l_mrow_ix ).CHANGE_LINE_ID := l_old_rows( orow_ix ).CHANGE_LINE_ID; end if;
                if l_merged_rows( l_mrow_ix ).ITEM_CATALOG_GROUP_ID is null then l_merged_rows( l_mrow_ix ).ITEM_CATALOG_GROUP_ID := l_old_rows( orow_ix ).ITEM_CATALOG_GROUP_ID; end if;
                if l_merged_rows( l_mrow_ix ).PROGRAM_APPLICATION_ID is null then l_merged_rows( l_mrow_ix ).PROGRAM_APPLICATION_ID := l_old_rows( orow_ix ).PROGRAM_APPLICATION_ID; end if;
                if l_merged_rows( l_mrow_ix ).PROGRAM_ID is null then l_merged_rows( l_mrow_ix ).PROGRAM_ID := l_old_rows( orow_ix ).PROGRAM_ID; end if;
                if l_merged_rows( l_mrow_ix ).PROGRAM_UPDATE_DATE is null then l_merged_rows( l_mrow_ix ).PROGRAM_UPDATE_DATE := l_old_rows( orow_ix ).PROGRAM_UPDATE_DATE; end if;
                if l_merged_rows( l_mrow_ix ).REQUEST_ID is null then l_merged_rows( l_mrow_ix ).REQUEST_ID := l_old_rows( orow_ix ).REQUEST_ID; end if;
                if l_merged_rows( l_mrow_ix ).ROW_IDENTIFIER is null then l_merged_rows( l_mrow_ix ).ROW_IDENTIFIER := l_old_rows( orow_ix ).ROW_IDENTIFIER; end if;
                if l_merged_rows( l_mrow_ix ).TRANSACTION_ID is null then l_merged_rows( l_mrow_ix ).TRANSACTION_ID := l_old_rows( orow_ix ).TRANSACTION_ID; end if;
                -- End Generated Code
            END LOOP; -- loop over old rows

            /*
            -- XXX: In case only null/invalid transaction types encountered, set transaction type to SYNC ?.
            IF l_merged_rows( l_mrow_ix ).TRANSACTION_TYPE IS NULL THEN
                l_merged_rows( l_mrow_ix ).TRANSACTION_TYPE := G_TRANS_TYPE_SYNC;
            END IF;
            */
            IF l_merged_rows IS NOT NULL THEN
                -- delete
                Debug_Conc_Log( l_proc_log_prefix || l_old_rowids.COUNT || ' old rows ...' );
                FORALL rid_ix IN INDICES OF l_old_rowids
                    DELETE FROM EGO_ITM_USR_ATTR_INTRFC
                        WHERE ROWID = l_old_rowids( rid_ix );
                -- insert
                Debug_Conc_Log( l_proc_log_prefix || l_merged_rows.COUNT || ' merged rows ...' );
                FORALL row_index IN INDICES OF l_merged_rows
                    INSERT INTO EGO_ITM_USR_ATTR_INTRFC
                        VALUES l_merged_rows( row_index );
            END IF;
        END IF; -- ENDS IF l_old_rows.count <> 0

        IF p_commit = FND_API.G_TRUE THEN
            Debug_Conc_Log( l_proc_log_prefix || 'Committing' );
            COMMIT;
        END IF;
        Debug_Conc_Log( l_proc_log_prefix || 'Exiting' );
    END merge_item_attrs;

    PROCEDURE merge_items( p_batch_id       IN NUMBER
                         , p_is_pdh_batch   IN FLAG
                         , p_ss_id          IN NUMBER   DEFAULT NULL
                         , p_master_org_id  IN NUMBER   DEFAULT NULL
                         , p_commit         IN FLAG     DEFAULT FND_API.G_FALSE
                         )
    IS
        TYPE MSII_ROWS      IS TABLE OF MSII_ROW INDEX BY BINARY_INTEGER;

        /*
         * This cursor is never executed.
         * It's only used for type definition.
         */
        CURSOR c_target_rec_type IS
            SELECT ROWID rid
                 , 0     cnt
                 , 0     rnk
                 , 'N'   excluded_flag
                 , msii.*
            FROM MTL_SYSTEM_ITEMS_INTERFACE msii;

        /*
         * Types for fetching the rows to merged.
         */
        TYPE MSII_CURSOR    IS REF CURSOR;
        c_target_rows       MSII_CURSOR;
        old_row             c_target_rec_type%ROWTYPE;

        l_merged_rows   MSII_ROWS;
        l_merge_base    MSII_ROW;
        l_old_rowids    UROWID_TABLE;

        l_ss_id         MTL_SYSTEM_ITEMS_INTERFACE.SOURCE_SYSTEM_ID%TYPE := p_ss_id;
        l_ssr           MTL_SYSTEM_ITEMS_INTERFACE.SOURCE_SYSTEM_REFERENCE%TYPE;
        l_candidate_trans MTL_SYSTEM_ITEMS_INTERFACE.TRANSACTION_TYPE%TYPE;

        l_cur_rank      PLS_INTEGER := 0; -- because rank() starts at 1
        l_mrow_ix       PLS_INTEGER := 0;
        l_is_pdh_batch  BOOLEAN;
        l_excluded_flag VARCHAR2(1);

        l_org_id        MTL_SYSTEM_ITEMS_INTERFACE.ORGANIZATION_ID%TYPE := p_master_org_id;
        l_pdh_batch_flag FLAG := p_is_pdh_batch;
        l_proc_log_prefix     CONSTANT VARCHAR2( 30 ) := 'merge_items - ';
    BEGIN
        Debug_Conc_Log( l_proc_log_prefix || 'Entering' );
        Debug_Conc_Log( l_proc_log_prefix || 'Batch ID: ' || p_batch_id );
        IF  l_pdh_batch_flag IS NULL OR l_org_id IS NULL OR l_ss_id IS NULL THEN
            merge_params_from_batch_header( p_batch_id      => p_batch_id
                                          , x_is_pdh_batch  => l_pdh_batch_flag
                                          , x_master_org_id => l_org_id
                                          , x_ss_id         => l_ss_id
                                          );
        END IF;
        Debug_Conc_Log( l_proc_log_prefix || 'Master Org ID: ' || l_org_id );
        Debug_Conc_Log( l_proc_log_prefix || 'SS ID: '         || l_ss_id );
        Debug_Conc_Log( l_proc_log_prefix || 'Is PDH Batch?: ' || l_pdh_batch_flag );

        l_is_pdh_batch  := ( l_pdh_batch_flag = FND_API.G_TRUE );
        IF  l_is_pdh_batch THEN
            OPEN c_target_rows FOR
                SELECT  *
                FROM
                    ( SELECT
                        ROWID rid,
                        COUNT( * ) OVER ( PARTITION BY  ITEM_NUMBER
                                                    ,   ORGANIZATION_ID
                                        )
                        cnt
                        , RANK() OVER   ( ORDER BY      ITEM_NUMBER
                                                    ,   ORGANIZATION_ID
                                        )
                        rnk
                        , null EXCLUDED_FLAG
                        , msii.*
                    FROM MTL_SYSTEM_ITEMS_INTERFACE msii
                    WHERE   PROCESS_FLAG        = 1
                        AND SET_PROCESS_ID      = p_batch_id
                        AND (   SOURCE_SYSTEM_ID    IS NULL
                            OR  SOURCE_SYSTEM_ID    = G_PDH_SOURCE_SYSTEM_ID
                            )
                        AND ITEM_NUMBER         IS NOT NULL
                        AND ORGANIZATION_ID     IS NOT NULL
                        AND EXISTS ( SELECT NULL
                                     FROM   MTL_PARAMETERS mp
                                     WHERE  mp.ORGANIZATION_ID          = msii.ORGANIZATION_ID
                                       AND  mp.MASTER_ORGANIZATION_ID   = l_org_id
                                   )
                    )
                    sub
                WHERE sub.cnt > 1
                ORDER BY rnk, last_update_date DESC NULLS LAST, interface_table_unique_id DESC NULLS LAST;
        ELSE
            OPEN c_target_rows FOR
                SELECT  *
                FROM
                    ( SELECT
                        ROWID rid,
                        COUNT( * ) OVER ( PARTITION BY  SOURCE_SYSTEM_ID
                                                    ,   SOURCE_SYSTEM_REFERENCE
                                                    ,   ORGANIZATION_ID
                                        )
                        cnt
                        , RANK() OVER   ( ORDER BY      SOURCE_SYSTEM_ID
                                                    ,   SOURCE_SYSTEM_REFERENCE
                                                    ,   ORGANIZATION_ID
                                        )
                        rnk
                        , ( SELECT 'Y' FROM DUAL
                            WHERE EXISTS (
                                          SELECT NULL FROM EGO_IMPORT_EXCLUDED_SS_ITEMS
                                          WHERE SOURCE_SYSTEM_REFERENCE = MSII.SOURCE_SYSTEM_REFERENCE
                                            AND SOURCE_SYSTEM_ID = MSII.SOURCE_SYSTEM_ID
                                         )
                          )
                        EXCLUDED_FLAG
                        , msii.*
                    FROM MTL_SYSTEM_ITEMS_INTERFACE msii
                    WHERE   PROCESS_FLAG        = 0
                        AND SET_PROCESS_ID      = p_batch_id
                        AND SOURCE_SYSTEM_ID    = l_ss_id
                        AND SOURCE_SYSTEM_REFERENCE IS NOT NULL
                        AND ORGANIZATION_ID         IS NOT NULL
                        AND EXISTS ( SELECT NULL
                                     FROM   MTL_PARAMETERS mp
                                     WHERE  mp.ORGANIZATION_ID          = msii.ORGANIZATION_ID
                                       AND  mp.MASTER_ORGANIZATION_ID   = l_org_id
                                   )
                    )
                    sub
                WHERE sub.cnt > 1
                ORDER BY rnk, last_update_date DESC NULLS LAST, interface_table_unique_id DESC NULLS LAST;
        END IF;

        -- attributes common to every merged row
        l_merge_base.SET_PROCESS_ID := p_batch_id;
        l_merge_base.PROCESS_FLAG   := CASE WHEN l_is_pdh_batch THEN 1 ELSE 0 END;

        l_old_rowids := UROWID_TABLE( );
        LOOP
            FETCH c_target_rows INTO old_row;
            EXIT WHEN c_target_rows%NOTFOUND;

            l_old_rowids.EXTEND;
            l_old_rowids( l_old_rowids.LAST ) := old_row.RID;

            IF( old_row.RNK <> l_cur_rank ) THEN
                IF( l_cur_rank <> 0 AND NOT l_is_pdh_batch) THEN
                    IF( l_merged_rows(l_mrow_ix).CONFIRM_STATUS NOT IN ( G_UNCONF_NONE_MATCH, G_UNCONF_SIGL_MATCH, G_UNCONF_MULT_MATCH  )
                        AND l_merged_rows(l_mrow_ix).TRANSACTION_TYPE = G_TRANS_TYPE_CREATE )
                    THEN
                        l_merged_rows(l_mrow_ix).CONFIRM_STATUS := G_CONF_NEW;
                    END IF;
                    IF( l_excluded_flag IS NOT NULL ) THEN
                        l_merged_rows( l_mrow_ix ).CONFIRM_STATUS := G_EXCLUDED;
                    END IF;
                END IF; --IF( l_cur_rank <> 0 AND NOT l_is_pdh_batch)

                l_cur_rank := old_row.RNK;
                Debug_Conc_Log( l_proc_log_prefix || '  Starting new merged row; rank = '|| l_cur_rank );
                l_mrow_ix := l_mrow_ix + 1;
                l_merged_rows( l_mrow_ix ) := l_merge_base;
                IF NOT l_is_pdh_batch THEN
                    l_merged_rows( l_mrow_ix ).SOURCE_SYSTEM_ID          := old_row.SOURCE_SYSTEM_ID;
                    l_merged_rows( l_mrow_ix ).SOURCE_SYSTEM_REFERENCE   := old_row.SOURCE_SYSTEM_REFERENCE;
                    Debug_Conc_Log( l_proc_log_prefix || '   Source System Reference: ' || l_merged_rows( l_mrow_ix ).SOURCE_SYSTEM_REFERENCE );
    ELSE
                   /* Bug 7662239. Updating SOURCE_SYSTEM_ID if the batch is a PDH batch */
                   l_merged_rows( l_mrow_ix ).SOURCE_SYSTEM_ID          := old_row.SOURCE_SYSTEM_ID;
                END IF;
            ELSE
                Debug_Conc_Log( l_proc_log_prefix || '  Merging another record into current merged row; rank = '|| l_cur_rank );
            END IF;

            -- Special Cases:
            -- Transaction type
            l_candidate_trans := UPPER( old_row.TRANSACTION_TYPE );
            l_excluded_flag := old_row.EXCLUDED_FLAG;

            IF      l_merged_rows( l_mrow_ix ).TRANSACTION_TYPE IS NULL
                OR  l_merged_rows( l_mrow_ix ).TRANSACTION_TYPE <> l_candidate_trans     -- <> filters out nulls
            THEN
                -- CREATE > SYNC > UPDATE : order of case expression matters
                l_merged_rows( l_mrow_ix ).TRANSACTION_TYPE :=
                    CASE
                        WHEN l_merged_rows( l_mrow_ix ).TRANSACTION_TYPE = G_TRANS_TYPE_CREATE
                          OR l_candidate_trans = G_TRANS_TYPE_CREATE                            THEN G_TRANS_TYPE_CREATE
                        WHEN l_merged_rows( l_mrow_ix ).TRANSACTION_TYPE = G_TRANS_TYPE_SYNC
                          OR l_candidate_trans = G_TRANS_TYPE_SYNC                              THEN G_TRANS_TYPE_SYNC
                        WHEN l_merged_rows( l_mrow_ix ).TRANSACTION_TYPE = G_TRANS_TYPE_UPDATE
                          OR l_candidate_trans = G_TRANS_TYPE_UPDATE                            THEN G_TRANS_TYPE_UPDATE
                        ELSE NULL -- INVALID transaction types encountered so far ...
                    END;
            END IF;
            Debug_Conc_Log('The Old - item columns are - ' || old_row.INVENTORY_ITEM_ID || ' -- ' || old_row.CONFIRM_STATUS );

            -- The following columns need to be treated as atomic groups
            -- 1. Item Identifier
            IF      l_merged_rows( l_mrow_ix ).INVENTORY_ITEM_ID  IS NULL
                AND l_merged_rows( l_mrow_ix ).ITEM_NUMBER        IS NULL
                AND l_merged_rows( l_mrow_ix ).SEGMENT1           IS NULL
                AND l_merged_rows( l_mrow_ix ).SEGMENT2           IS NULL
                AND l_merged_rows( l_mrow_ix ).SEGMENT3           IS NULL
                AND l_merged_rows( l_mrow_ix ).SEGMENT4           IS NULL
                AND l_merged_rows( l_mrow_ix ).SEGMENT5           IS NULL
                AND l_merged_rows( l_mrow_ix ).SEGMENT6           IS NULL
                AND l_merged_rows( l_mrow_ix ).SEGMENT7           IS NULL
                AND l_merged_rows( l_mrow_ix ).SEGMENT8           IS NULL
                AND l_merged_rows( l_mrow_ix ).SEGMENT9           IS NULL
                AND l_merged_rows( l_mrow_ix ).SEGMENT10          IS NULL
                AND l_merged_rows( l_mrow_ix ).SEGMENT11          IS NULL
                AND l_merged_rows( l_mrow_ix ).SEGMENT12          IS NULL
                AND l_merged_rows( l_mrow_ix ).SEGMENT13          IS NULL
                AND l_merged_rows( l_mrow_ix ).SEGMENT14          IS NULL
                AND l_merged_rows( l_mrow_ix ).SEGMENT15          IS NULL
                AND l_merged_rows( l_mrow_ix ).SEGMENT16          IS NULL
                AND l_merged_rows( l_mrow_ix ).SEGMENT17          IS NULL
                AND l_merged_rows( l_mrow_ix ).SEGMENT18          IS NULL
                AND l_merged_rows( l_mrow_ix ).SEGMENT19          IS NULL
                AND l_merged_rows( l_mrow_ix ).SEGMENT20          IS NULL
            THEN
                l_merged_rows( l_mrow_ix ).INVENTORY_ITEM_ID  := old_row.INVENTORY_ITEM_ID;
                l_merged_rows( l_mrow_ix ).ITEM_NUMBER        := old_row.ITEM_NUMBER;
                l_merged_rows( l_mrow_ix ).SEGMENT1           := old_row.SEGMENT1;
                l_merged_rows( l_mrow_ix ).SEGMENT2           := old_row.SEGMENT2;
                l_merged_rows( l_mrow_ix ).SEGMENT3           := old_row.SEGMENT3;
                l_merged_rows( l_mrow_ix ).SEGMENT4           := old_row.SEGMENT4;
                l_merged_rows( l_mrow_ix ).SEGMENT5           := old_row.SEGMENT5;
                l_merged_rows( l_mrow_ix ).SEGMENT6           := old_row.SEGMENT6;
                l_merged_rows( l_mrow_ix ).SEGMENT7           := old_row.SEGMENT7;
                l_merged_rows( l_mrow_ix ).SEGMENT8           := old_row.SEGMENT8;
                l_merged_rows( l_mrow_ix ).SEGMENT9           := old_row.SEGMENT9;
                l_merged_rows( l_mrow_ix ).SEGMENT10          := old_row.SEGMENT10;
                l_merged_rows( l_mrow_ix ).SEGMENT11          := old_row.SEGMENT11;
                l_merged_rows( l_mrow_ix ).SEGMENT12          := old_row.SEGMENT12;
                l_merged_rows( l_mrow_ix ).SEGMENT13          := old_row.SEGMENT13;
                l_merged_rows( l_mrow_ix ).SEGMENT14          := old_row.SEGMENT14;
                l_merged_rows( l_mrow_ix ).SEGMENT15          := old_row.SEGMENT15;
                l_merged_rows( l_mrow_ix ).SEGMENT16          := old_row.SEGMENT16;
                l_merged_rows( l_mrow_ix ).SEGMENT17          := old_row.SEGMENT17;
                l_merged_rows( l_mrow_ix ).SEGMENT18          := old_row.SEGMENT18;
                l_merged_rows( l_mrow_ix ).SEGMENT19          := old_row.SEGMENT19;
                l_merged_rows( l_mrow_ix ).SEGMENT20          := old_row.SEGMENT20;
                -- Copying Confirm Status
                -- If confirm_Status is fake make it real else copy the old confirm_status.
                IF( old_row.CONFIRM_STATUS = G_CONF_XREF_FAKE ) THEN
                   l_merged_rows( l_mrow_ix ).CONFIRM_STATUS := G_CONF_XREF;
                ELSIF ( old_row.CONFIRM_STATUS = G_CONF_MATCH_FAKE ) THEN
                   l_merged_rows( l_mrow_ix ).CONFIRM_STATUS := G_CONF_MATCH;
                ELSIF ( old_row.CONFIRM_STATUS = G_FAKE_MATCH_READY ) THEN
                   l_merged_rows( l_mrow_ix ).CONFIRM_STATUS := G_CONF_MATCH_READY;
                ELSIF ( old_row.CONFIRM_STATUS = G_UNCONF_SINGLE_MATCH_FAKE ) THEN
                   l_merged_rows( l_mrow_ix ).CONFIRM_STATUS := G_UNCONF_SIGL_MATCH;
                ELSIF ( old_row.CONFIRM_STATUS = G_UNCONF_MULTI_MATCH_FAKE ) THEN
                   l_merged_rows( l_mrow_ix ).CONFIRM_STATUS := G_UNCONF_MULT_MATCH;
                ELSIF ( old_row.CONFIRM_STATUS = G_FAKE_EXCLUDED ) THEN
                   l_merged_rows( l_mrow_ix ).CONFIRM_STATUS := G_EXCLUDED;
                ELSIF ( old_row.CONFIRM_STATUS = G_FAKE_CONF_STATUS_FLAG ) THEN
                   l_merged_rows( l_mrow_ix ).CONFIRM_STATUS := NULL;
                ELSE
                   l_merged_rows( l_mrow_ix ).CONFIRM_STATUS := old_row.CONFIRM_STATUS;
                END IF;
            END IF;

            Debug_Conc_Log('The merged - item columns are - ' || l_merged_rows( l_mrow_ix ).INVENTORY_ITEM_ID || ' -- ' || l_merged_rows( l_mrow_ix ).CONFIRM_STATUS );

            -- 2. Template Identifier
            IF      l_merged_rows( l_mrow_ix ).TEMPLATE_ID        IS NULL
                AND l_merged_rows( l_mrow_ix ).TEMPLATE_NAME      IS NULL
            THEN
                l_merged_rows( l_mrow_ix ).TEMPLATE_ID    := old_row.TEMPLATE_ID ;
                l_merged_rows( l_mrow_ix ).TEMPLATE_NAME  := old_row.TEMPLATE_NAME ;
            END IF;

            -- 3. Item Catalog Category
            IF      l_merged_rows( l_mrow_ix ).ITEM_CATALOG_GROUP_ID      IS NULL
                AND l_merged_rows( l_mrow_ix ).ITEM_CATALOG_GROUP_NAME    IS NULL
            THEN
                l_merged_rows( l_mrow_ix ).ITEM_CATALOG_GROUP_ID      := old_row.ITEM_CATALOG_GROUP_ID ;
                l_merged_rows( l_mrow_ix ).ITEM_CATALOG_GROUP_NAME    := old_row.ITEM_CATALOG_GROUP_NAME ;
            END IF;

            -- 4. Primary UOM
            IF      l_merged_rows( l_mrow_ix ).PRIMARY_UOM_CODE           IS NULL
                AND l_merged_rows( l_mrow_ix ).PRIMARY_UNIT_OF_MEASURE    IS NULL
            THEN
                l_merged_rows( l_mrow_ix ).PRIMARY_UOM_CODE           := old_row.PRIMARY_UOM_CODE ;
                l_merged_rows( l_mrow_ix ).PRIMARY_UNIT_OF_MEASURE    := old_row.PRIMARY_UNIT_OF_MEASURE ;
            END IF;

            -- 5. Organization
            IF      l_merged_rows( l_mrow_ix ).ORGANIZATION_ID    IS NULL
                AND l_merged_rows( l_mrow_ix ).ORGANIZATION_CODE  IS NULL
            THEN
                l_merged_rows( l_mrow_ix ).ORGANIZATION_ID        := old_row.ORGANIZATION_ID ;
                l_merged_rows( l_mrow_ix ).ORGANIZATION_CODE      := old_row.ORGANIZATION_CODE ;
            END IF;

            -- 6. Copy Organization
            IF      l_merged_rows( l_mrow_ix ).COPY_ORGANIZATION_ID    IS NULL
                AND l_merged_rows( l_mrow_ix ).COPY_ORGANIZATION_CODE  IS NULL
            THEN
                l_merged_rows( l_mrow_ix ).COPY_ORGANIZATION_ID        := old_row.COPY_ORGANIZATION_ID ;
                l_merged_rows( l_mrow_ix ).COPY_ORGANIZATION_CODE      := old_row.COPY_ORGANIZATION_CODE ;
            END IF;

            -- 7. Merging StyleItemNumber and SytleItemFlag
            IF      l_merged_rows( l_mrow_ix ).STYLE_ITEM_NUMBER IS NULL
                AND l_merged_rows( l_mrow_ix ).STYLE_ITEM_FLAG   IS NULL
            THEN
                l_merged_rows( l_mrow_ix ).STYLE_ITEM_NUMBER := old_row.STYLE_ITEM_NUMBER;
                l_merged_rows( l_mrow_ix ).STYLE_ITEM_FLAG   := old_row.STYLE_ITEM_FLAG;
            END IF;

            /* ELETUCHY: commented out due to the regressions this code would introduce
            --Bug.5336962 Begin (Nisar) -> Copy Confirm Status
            -- If old row that is to be merged is fake, we don't copy the ConfirmStatus or we make confirm status null
            -- If old row already have non fake ConfirmStatus we copy it as it is.
            IF      l_merged_rows( l_mrow_ix ).CONFIRM_STATUS IS NULL
                AND old_row.CONFIRM_STATUS NOT IN ('CFC', 'CFM', 'FMR', 'UFS', 'UFM', 'FK', 'FEX')
            THEN
                l_merged_rows( l_mrow_ix ).CONFIRM_STATUS := old_row.CONFIRM_STATUS;
            END IF;
            --Bug.5336962 End
            */

            -- Non-special-cased
            -- Starting generated code
            /* generate using the following script:
                SET LINESIZE 200
                SELECT  'if l_merged_rows( l_mrow_ix ).' ||column_name || ' is null then l_merged_rows( l_mrow_ix ).' || column_name || ' := old_row.' || column_name || '; end if; '
                FROM    ALL_TAB_COLUMNS
                WHERE   TABLE_NAME = 'MTL_SYSTEM_ITEMS_INTERFACE'
                AND COLUMN_NAME NOT IN
                    ( -- special cases (for merge)
                      'INVENTORY_ITEM_ID'
                    , 'ITEM_NUMBER'
                    , 'SEGMENT1'
                    , 'SEGMENT2'
                    , 'SEGMENT3'
                    , 'SEGMENT4'
                    , 'SEGMENT5'
                    , 'SEGMENT6'
                    , 'SEGMENT7'
                    , 'SEGMENT8'
                    , 'SEGMENT9'
                    , 'SEGMENT10'
                    , 'SEGMENT11'
                    , 'SEGMENT12'
                    , 'SEGMENT13'
                    , 'SEGMENT14'
                    , 'SEGMENT15'
                    , 'SEGMENT16'
                    , 'SEGMENT17'
                    , 'SEGMENT18'
                    , 'SEGMENT19'
                    , 'SEGMENT20'
                    , 'TRANSACTION_TYPE'
                    , 'TEMPLATE_ID'
                    , 'TEMPLATE_NAME'
                    , 'ITEM_CATALOG_GROUP_ID'
                    , 'ITEM_CATALOG_GROUP_NAME'
                    , 'PRIMARY_UOM_CODE'
                    , 'PRIMARY_UNIT_OF_MEASURE'
                    , 'ORGANIZATION_ID'
                    , 'ORGANIZATION_CODE'
                    , 'COPY_ORGANIZATION_ID'
                    , 'COPY_ORGANIZATION_CODE'
                      -- special columns
                    , 'SET_PROCESS_ID'
                    , 'PROCESS_FLAG'
                    , 'SOURCE_SYSTEM_ID'
                    , 'SOURCE_SYSTEM_REFERENCE'
                    , 'INTERFACE_TABLE_UNIQUE_ID' -- handled by INSERT trigger
                    , 'CONFIRM_STATUS'            -- should always be left null after a MERGE is performed
                      -- who columns
                    , 'LAST_UPDATE_DATE'
                    , 'CREATION_DATE'
                    , 'CREATED_BY'
                    , 'LAST_UPDATED_BY'
                    , 'LAST_UPDATE_LOGIN'
                      -- XXX: exclude concurrent processing columns?
                    )
                order by column_name asc;
            */
      /* Bug 7662239. Added TRADE_ITEM_DESCRIPTOR to consider it while merging the two rows */
            if l_merged_rows( l_mrow_ix ).TRADE_ITEM_DESCRIPTOR is null then l_merged_rows( l_mrow_ix ).TRADE_ITEM_DESCRIPTOR := old_row.TRADE_ITEM_DESCRIPTOR; end if;
      if l_merged_rows( l_mrow_ix ).ACCEPTABLE_EARLY_DAYS is null then l_merged_rows( l_mrow_ix ).ACCEPTABLE_EARLY_DAYS := old_row.ACCEPTABLE_EARLY_DAYS; end if;
            if l_merged_rows( l_mrow_ix ).ACCEPTABLE_RATE_DECREASE is null then l_merged_rows( l_mrow_ix ).ACCEPTABLE_RATE_DECREASE := old_row.ACCEPTABLE_RATE_DECREASE; end if;
            if l_merged_rows( l_mrow_ix ).ACCEPTABLE_RATE_INCREASE is null then l_merged_rows( l_mrow_ix ).ACCEPTABLE_RATE_INCREASE := old_row.ACCEPTABLE_RATE_INCREASE; end if;
            if l_merged_rows( l_mrow_ix ).ACCOUNTING_RULE_ID is null then l_merged_rows( l_mrow_ix ).ACCOUNTING_RULE_ID := old_row.ACCOUNTING_RULE_ID; end if;
            if l_merged_rows( l_mrow_ix ).ALLOWED_UNITS_LOOKUP_CODE is null then l_merged_rows( l_mrow_ix ).ALLOWED_UNITS_LOOKUP_CODE := old_row.ALLOWED_UNITS_LOOKUP_CODE; end if;
            if l_merged_rows( l_mrow_ix ).ALLOW_EXPRESS_DELIVERY_FLAG is null then l_merged_rows( l_mrow_ix ).ALLOW_EXPRESS_DELIVERY_FLAG := old_row.ALLOW_EXPRESS_DELIVERY_FLAG; end if;
            if l_merged_rows( l_mrow_ix ).ALLOW_ITEM_DESC_UPDATE_FLAG is null then l_merged_rows( l_mrow_ix ).ALLOW_ITEM_DESC_UPDATE_FLAG := old_row.ALLOW_ITEM_DESC_UPDATE_FLAG; end if;
            if l_merged_rows( l_mrow_ix ).ALLOW_SUBSTITUTE_RECEIPTS_FLAG is null then l_merged_rows( l_mrow_ix ).ALLOW_SUBSTITUTE_RECEIPTS_FLAG := old_row.ALLOW_SUBSTITUTE_RECEIPTS_FLAG; end if;
            if l_merged_rows( l_mrow_ix ).ALLOW_UNORDERED_RECEIPTS_FLAG is null then l_merged_rows( l_mrow_ix ).ALLOW_UNORDERED_RECEIPTS_FLAG := old_row.ALLOW_UNORDERED_RECEIPTS_FLAG; end if;
            if l_merged_rows( l_mrow_ix ).ASN_AUTOEXPIRE_FLAG is null then l_merged_rows( l_mrow_ix ).ASN_AUTOEXPIRE_FLAG := old_row.ASN_AUTOEXPIRE_FLAG; end if;
            if l_merged_rows( l_mrow_ix ).ASSET_CATEGORY_ID is null then l_merged_rows( l_mrow_ix ).ASSET_CATEGORY_ID := old_row.ASSET_CATEGORY_ID; end if;
            if l_merged_rows( l_mrow_ix ).ASSET_CREATION_CODE is null then l_merged_rows( l_mrow_ix ).ASSET_CREATION_CODE := old_row.ASSET_CREATION_CODE; end if;
            if l_merged_rows( l_mrow_ix ).ATO_FORECAST_CONTROL is null then l_merged_rows( l_mrow_ix ).ATO_FORECAST_CONTROL := old_row.ATO_FORECAST_CONTROL; end if;
            if l_merged_rows( l_mrow_ix ).ATP_COMPONENTS_FLAG is null then l_merged_rows( l_mrow_ix ).ATP_COMPONENTS_FLAG := old_row.ATP_COMPONENTS_FLAG; end if;
            if l_merged_rows( l_mrow_ix ).ATP_FLAG is null then l_merged_rows( l_mrow_ix ).ATP_FLAG := old_row.ATP_FLAG; end if;
            if l_merged_rows( l_mrow_ix ).ATP_RULE_ID is null then l_merged_rows( l_mrow_ix ).ATP_RULE_ID := old_row.ATP_RULE_ID; end if;
            if l_merged_rows( l_mrow_ix ).ATTRIBUTE1 is null then l_merged_rows( l_mrow_ix ).ATTRIBUTE1 := old_row.ATTRIBUTE1; end if;
            if l_merged_rows( l_mrow_ix ).ATTRIBUTE10 is null then l_merged_rows( l_mrow_ix ).ATTRIBUTE10 := old_row.ATTRIBUTE10; end if;
            if l_merged_rows( l_mrow_ix ).ATTRIBUTE11 is null then l_merged_rows( l_mrow_ix ).ATTRIBUTE11 := old_row.ATTRIBUTE11; end if;
            if l_merged_rows( l_mrow_ix ).ATTRIBUTE12 is null then l_merged_rows( l_mrow_ix ).ATTRIBUTE12 := old_row.ATTRIBUTE12; end if;
            if l_merged_rows( l_mrow_ix ).ATTRIBUTE13 is null then l_merged_rows( l_mrow_ix ).ATTRIBUTE13 := old_row.ATTRIBUTE13; end if;
            if l_merged_rows( l_mrow_ix ).ATTRIBUTE14 is null then l_merged_rows( l_mrow_ix ).ATTRIBUTE14 := old_row.ATTRIBUTE14; end if;
            if l_merged_rows( l_mrow_ix ).ATTRIBUTE15 is null then l_merged_rows( l_mrow_ix ).ATTRIBUTE15 := old_row.ATTRIBUTE15; end if;
            if l_merged_rows( l_mrow_ix ).ATTRIBUTE16 is null then l_merged_rows( l_mrow_ix ).ATTRIBUTE16 := old_row.ATTRIBUTE16; end if;
            if l_merged_rows( l_mrow_ix ).ATTRIBUTE17 is null then l_merged_rows( l_mrow_ix ).ATTRIBUTE17 := old_row.ATTRIBUTE17; end if;
            if l_merged_rows( l_mrow_ix ).ATTRIBUTE18 is null then l_merged_rows( l_mrow_ix ).ATTRIBUTE18 := old_row.ATTRIBUTE18; end if;
            if l_merged_rows( l_mrow_ix ).ATTRIBUTE19 is null then l_merged_rows( l_mrow_ix ).ATTRIBUTE19 := old_row.ATTRIBUTE19; end if;
            if l_merged_rows( l_mrow_ix ).ATTRIBUTE2 is null then l_merged_rows( l_mrow_ix ).ATTRIBUTE2 := old_row.ATTRIBUTE2; end if;
            if l_merged_rows( l_mrow_ix ).ATTRIBUTE20 is null then l_merged_rows( l_mrow_ix ).ATTRIBUTE20 := old_row.ATTRIBUTE20; end if;
            if l_merged_rows( l_mrow_ix ).ATTRIBUTE21 is null then l_merged_rows( l_mrow_ix ).ATTRIBUTE21 := old_row.ATTRIBUTE21; end if;
            if l_merged_rows( l_mrow_ix ).ATTRIBUTE22 is null then l_merged_rows( l_mrow_ix ).ATTRIBUTE22 := old_row.ATTRIBUTE22; end if;
            if l_merged_rows( l_mrow_ix ).ATTRIBUTE23 is null then l_merged_rows( l_mrow_ix ).ATTRIBUTE23 := old_row.ATTRIBUTE23; end if;
            if l_merged_rows( l_mrow_ix ).ATTRIBUTE24 is null then l_merged_rows( l_mrow_ix ).ATTRIBUTE24 := old_row.ATTRIBUTE24; end if;
            if l_merged_rows( l_mrow_ix ).ATTRIBUTE25 is null then l_merged_rows( l_mrow_ix ).ATTRIBUTE25 := old_row.ATTRIBUTE25; end if;
            if l_merged_rows( l_mrow_ix ).ATTRIBUTE26 is null then l_merged_rows( l_mrow_ix ).ATTRIBUTE26 := old_row.ATTRIBUTE26; end if;
            if l_merged_rows( l_mrow_ix ).ATTRIBUTE27 is null then l_merged_rows( l_mrow_ix ).ATTRIBUTE27 := old_row.ATTRIBUTE27; end if;
            if l_merged_rows( l_mrow_ix ).ATTRIBUTE28 is null then l_merged_rows( l_mrow_ix ).ATTRIBUTE28 := old_row.ATTRIBUTE28; end if;
            if l_merged_rows( l_mrow_ix ).ATTRIBUTE29 is null then l_merged_rows( l_mrow_ix ).ATTRIBUTE29 := old_row.ATTRIBUTE29; end if;
            if l_merged_rows( l_mrow_ix ).ATTRIBUTE3 is null then l_merged_rows( l_mrow_ix ).ATTRIBUTE3 := old_row.ATTRIBUTE3; end if;
            if l_merged_rows( l_mrow_ix ).ATTRIBUTE30 is null then l_merged_rows( l_mrow_ix ).ATTRIBUTE30 := old_row.ATTRIBUTE30; end if;
            if l_merged_rows( l_mrow_ix ).ATTRIBUTE4 is null then l_merged_rows( l_mrow_ix ).ATTRIBUTE4 := old_row.ATTRIBUTE4; end if;
            if l_merged_rows( l_mrow_ix ).ATTRIBUTE5 is null then l_merged_rows( l_mrow_ix ).ATTRIBUTE5 := old_row.ATTRIBUTE5; end if;
            if l_merged_rows( l_mrow_ix ).ATTRIBUTE6 is null then l_merged_rows( l_mrow_ix ).ATTRIBUTE6 := old_row.ATTRIBUTE6; end if;
            if l_merged_rows( l_mrow_ix ).ATTRIBUTE7 is null then l_merged_rows( l_mrow_ix ).ATTRIBUTE7 := old_row.ATTRIBUTE7; end if;
            if l_merged_rows( l_mrow_ix ).ATTRIBUTE8 is null then l_merged_rows( l_mrow_ix ).ATTRIBUTE8 := old_row.ATTRIBUTE8; end if;
            if l_merged_rows( l_mrow_ix ).ATTRIBUTE9 is null then l_merged_rows( l_mrow_ix ).ATTRIBUTE9 := old_row.ATTRIBUTE9; end if;
            if l_merged_rows( l_mrow_ix ).ATTRIBUTE_CATEGORY is null then l_merged_rows( l_mrow_ix ).ATTRIBUTE_CATEGORY := old_row.ATTRIBUTE_CATEGORY; end if;
            if l_merged_rows( l_mrow_ix ).AUTO_CREATED_CONFIG_FLAG is null then l_merged_rows( l_mrow_ix ).AUTO_CREATED_CONFIG_FLAG := old_row.AUTO_CREATED_CONFIG_FLAG; end if;
            if l_merged_rows( l_mrow_ix ).AUTO_LOT_ALPHA_PREFIX is null then l_merged_rows( l_mrow_ix ).AUTO_LOT_ALPHA_PREFIX := old_row.AUTO_LOT_ALPHA_PREFIX; end if;
            if l_merged_rows( l_mrow_ix ).AUTO_REDUCE_MPS is null then l_merged_rows( l_mrow_ix ).AUTO_REDUCE_MPS := old_row.AUTO_REDUCE_MPS; end if;
            if l_merged_rows( l_mrow_ix ).AUTO_SERIAL_ALPHA_PREFIX is null then l_merged_rows( l_mrow_ix ).AUTO_SERIAL_ALPHA_PREFIX := old_row.AUTO_SERIAL_ALPHA_PREFIX; end if;
            if l_merged_rows( l_mrow_ix ).BACK_ORDERABLE_FLAG is null then l_merged_rows( l_mrow_ix ).BACK_ORDERABLE_FLAG := old_row.BACK_ORDERABLE_FLAG; end if;
            if l_merged_rows( l_mrow_ix ).BASE_ITEM_ID is null then l_merged_rows( l_mrow_ix ).BASE_ITEM_ID := old_row.BASE_ITEM_ID; end if;
            if l_merged_rows( l_mrow_ix ).BASE_WARRANTY_SERVICE_ID is null then l_merged_rows( l_mrow_ix ).BASE_WARRANTY_SERVICE_ID := old_row.BASE_WARRANTY_SERVICE_ID; end if;
            if l_merged_rows( l_mrow_ix ).BOM_ENABLED_FLAG is null then l_merged_rows( l_mrow_ix ).BOM_ENABLED_FLAG := old_row.BOM_ENABLED_FLAG; end if;
            if l_merged_rows( l_mrow_ix ).BOM_ITEM_TYPE is null then l_merged_rows( l_mrow_ix ).BOM_ITEM_TYPE := old_row.BOM_ITEM_TYPE; end if;
            if l_merged_rows( l_mrow_ix ).BUILD_IN_WIP_FLAG is null then l_merged_rows( l_mrow_ix ).BUILD_IN_WIP_FLAG := old_row.BUILD_IN_WIP_FLAG; end if;
            if l_merged_rows( l_mrow_ix ).BULK_PICKED_FLAG is null then l_merged_rows( l_mrow_ix ).BULK_PICKED_FLAG := old_row.BULK_PICKED_FLAG; end if;
            if l_merged_rows( l_mrow_ix ).BUYER_ID is null then l_merged_rows( l_mrow_ix ).BUYER_ID := old_row.BUYER_ID; end if;
            if l_merged_rows( l_mrow_ix ).CARRYING_COST is null then l_merged_rows( l_mrow_ix ).CARRYING_COST := old_row.CARRYING_COST; end if;
            if l_merged_rows( l_mrow_ix ).CAS_NUMBER is null then l_merged_rows( l_mrow_ix ).CAS_NUMBER := old_row.CAS_NUMBER; end if;
            if l_merged_rows( l_mrow_ix ).CATALOG_STATUS_FLAG is null then l_merged_rows( l_mrow_ix ).CATALOG_STATUS_FLAG := old_row.CATALOG_STATUS_FLAG; end if;
            if l_merged_rows( l_mrow_ix ).CHANGE_ID is null then l_merged_rows( l_mrow_ix ).CHANGE_ID := old_row.CHANGE_ID; end if;
            if l_merged_rows( l_mrow_ix ).CHANGE_LINE_ID is null then l_merged_rows( l_mrow_ix ).CHANGE_LINE_ID := old_row.CHANGE_LINE_ID; end if;
            if l_merged_rows( l_mrow_ix ).CHARGE_PERIODICITY_CODE is null then l_merged_rows( l_mrow_ix ).CHARGE_PERIODICITY_CODE := old_row.CHARGE_PERIODICITY_CODE; end if;
            if l_merged_rows( l_mrow_ix ).CHECK_SHORTAGES_FLAG is null then l_merged_rows( l_mrow_ix ).CHECK_SHORTAGES_FLAG := old_row.CHECK_SHORTAGES_FLAG; end if;
            if l_merged_rows( l_mrow_ix ).CHILD_LOT_FLAG is null then l_merged_rows( l_mrow_ix ).CHILD_LOT_FLAG := old_row.CHILD_LOT_FLAG; end if;
            if l_merged_rows( l_mrow_ix ).CHILD_LOT_PREFIX is null then l_merged_rows( l_mrow_ix ).CHILD_LOT_PREFIX := old_row.CHILD_LOT_PREFIX; end if;
            if l_merged_rows( l_mrow_ix ).CHILD_LOT_STARTING_NUMBER is null then l_merged_rows( l_mrow_ix ).CHILD_LOT_STARTING_NUMBER := old_row.CHILD_LOT_STARTING_NUMBER; end if;
            if l_merged_rows( l_mrow_ix ).CHILD_LOT_VALIDATION_FLAG is null then l_merged_rows( l_mrow_ix ).CHILD_LOT_VALIDATION_FLAG := old_row.CHILD_LOT_VALIDATION_FLAG; end if;
            if l_merged_rows( l_mrow_ix ).COLLATERAL_FLAG is null then l_merged_rows( l_mrow_ix ).COLLATERAL_FLAG := old_row.COLLATERAL_FLAG; end if;
            if l_merged_rows( l_mrow_ix ).COMMS_ACTIVATION_REQD_FLAG is null then l_merged_rows( l_mrow_ix ).COMMS_ACTIVATION_REQD_FLAG := old_row.COMMS_ACTIVATION_REQD_FLAG; end if;
            if l_merged_rows( l_mrow_ix ).COMMS_NL_TRACKABLE_FLAG is null then l_merged_rows( l_mrow_ix ).COMMS_NL_TRACKABLE_FLAG := old_row.COMMS_NL_TRACKABLE_FLAG; end if;
            if l_merged_rows( l_mrow_ix ).CONFIG_MATCH is null then l_merged_rows( l_mrow_ix ).CONFIG_MATCH := old_row.CONFIG_MATCH; end if;
            if l_merged_rows( l_mrow_ix ).CONFIG_MODEL_TYPE is null then l_merged_rows( l_mrow_ix ).CONFIG_MODEL_TYPE := old_row.CONFIG_MODEL_TYPE; end if;
            if l_merged_rows( l_mrow_ix ).CONFIG_ORGS is null then l_merged_rows( l_mrow_ix ).CONFIG_ORGS := old_row.CONFIG_ORGS; end if;
            if l_merged_rows( l_mrow_ix ).CONSIGNED_FLAG is null then l_merged_rows( l_mrow_ix ).CONSIGNED_FLAG := old_row.CONSIGNED_FLAG; end if;
            if l_merged_rows( l_mrow_ix ).CONTAINER_ITEM_FLAG is null then l_merged_rows( l_mrow_ix ).CONTAINER_ITEM_FLAG := old_row.CONTAINER_ITEM_FLAG; end if;
            if l_merged_rows( l_mrow_ix ).CONTAINER_TYPE_CODE is null then l_merged_rows( l_mrow_ix ).CONTAINER_TYPE_CODE := old_row.CONTAINER_TYPE_CODE; end if;
            if l_merged_rows( l_mrow_ix ).CONTINOUS_TRANSFER is null then l_merged_rows( l_mrow_ix ).CONTINOUS_TRANSFER := old_row.CONTINOUS_TRANSFER; end if;
            if l_merged_rows( l_mrow_ix ).CONTRACT_ITEM_TYPE_CODE is null then l_merged_rows( l_mrow_ix ).CONTRACT_ITEM_TYPE_CODE := old_row.CONTRACT_ITEM_TYPE_CODE; end if;
            if l_merged_rows( l_mrow_ix ).CONVERGENCE is null then l_merged_rows( l_mrow_ix ).CONVERGENCE := old_row.CONVERGENCE; end if;
            if l_merged_rows( l_mrow_ix ).COPY_ITEM_ID is null then l_merged_rows( l_mrow_ix ).COPY_ITEM_ID := old_row.COPY_ITEM_ID; end if;
            if l_merged_rows( l_mrow_ix ).COPY_ITEM_NUMBER is null then l_merged_rows( l_mrow_ix ).COPY_ITEM_NUMBER := old_row.COPY_ITEM_NUMBER; end if;
            if l_merged_rows( l_mrow_ix ).COPY_LOT_ATTRIBUTE_FLAG is null then l_merged_rows( l_mrow_ix ).COPY_LOT_ATTRIBUTE_FLAG := old_row.COPY_LOT_ATTRIBUTE_FLAG; end if;
            if l_merged_rows( l_mrow_ix ).COSTING_ENABLED_FLAG is null then l_merged_rows( l_mrow_ix ).COSTING_ENABLED_FLAG := old_row.COSTING_ENABLED_FLAG; end if;
            if l_merged_rows( l_mrow_ix ).COST_OF_SALES_ACCOUNT is null then l_merged_rows( l_mrow_ix ).COST_OF_SALES_ACCOUNT := old_row.COST_OF_SALES_ACCOUNT; end if;
            if l_merged_rows( l_mrow_ix ).COUPON_EXEMPT_FLAG is null then l_merged_rows( l_mrow_ix ).COUPON_EXEMPT_FLAG := old_row.COUPON_EXEMPT_FLAG; end if;
            if l_merged_rows( l_mrow_ix ).COVERAGE_SCHEDULE_ID is null then l_merged_rows( l_mrow_ix ).COVERAGE_SCHEDULE_ID := old_row.COVERAGE_SCHEDULE_ID; end if;
            if l_merged_rows( l_mrow_ix ).CREATE_SUPPLY_FLAG is null then l_merged_rows( l_mrow_ix ).CREATE_SUPPLY_FLAG := old_row.CREATE_SUPPLY_FLAG; end if;
            if l_merged_rows( l_mrow_ix ).CRITICAL_COMPONENT_FLAG is null then l_merged_rows( l_mrow_ix ).CRITICAL_COMPONENT_FLAG := old_row.CRITICAL_COMPONENT_FLAG; end if;
            if l_merged_rows( l_mrow_ix ).CUMULATIVE_TOTAL_LEAD_TIME is null then l_merged_rows( l_mrow_ix ).CUMULATIVE_TOTAL_LEAD_TIME := old_row.CUMULATIVE_TOTAL_LEAD_TIME; end if;
            if l_merged_rows( l_mrow_ix ).CUM_MANUFACTURING_LEAD_TIME is null then l_merged_rows( l_mrow_ix ).CUM_MANUFACTURING_LEAD_TIME := old_row.CUM_MANUFACTURING_LEAD_TIME; end if;
            if l_merged_rows( l_mrow_ix ).CURRENT_PHASE_ID is null then l_merged_rows( l_mrow_ix ).CURRENT_PHASE_ID := old_row.CURRENT_PHASE_ID; end if;
            if l_merged_rows( l_mrow_ix ).CUSTOMER_ORDER_ENABLED_FLAG is null then l_merged_rows( l_mrow_ix ).CUSTOMER_ORDER_ENABLED_FLAG := old_row.CUSTOMER_ORDER_ENABLED_FLAG; end if;
            if l_merged_rows( l_mrow_ix ).CUSTOMER_ORDER_FLAG is null then l_merged_rows( l_mrow_ix ).CUSTOMER_ORDER_FLAG := old_row.CUSTOMER_ORDER_FLAG; end if;
            if l_merged_rows( l_mrow_ix ).CYCLE_COUNT_ENABLED_FLAG is null then l_merged_rows( l_mrow_ix ).CYCLE_COUNT_ENABLED_FLAG := old_row.CYCLE_COUNT_ENABLED_FLAG; end if;
            if l_merged_rows( l_mrow_ix ).DAYS_EARLY_RECEIPT_ALLOWED is null then l_merged_rows( l_mrow_ix ).DAYS_EARLY_RECEIPT_ALLOWED := old_row.DAYS_EARLY_RECEIPT_ALLOWED; end if;
            if l_merged_rows( l_mrow_ix ).DAYS_LATE_RECEIPT_ALLOWED is null then l_merged_rows( l_mrow_ix ).DAYS_LATE_RECEIPT_ALLOWED := old_row.DAYS_LATE_RECEIPT_ALLOWED; end if;
            if l_merged_rows( l_mrow_ix ).DAYS_MAX_INV_SUPPLY is null then l_merged_rows( l_mrow_ix ).DAYS_MAX_INV_SUPPLY := old_row.DAYS_MAX_INV_SUPPLY; end if;
            if l_merged_rows( l_mrow_ix ).DAYS_MAX_INV_WINDOW is null then l_merged_rows( l_mrow_ix ).DAYS_MAX_INV_WINDOW := old_row.DAYS_MAX_INV_WINDOW; end if;
            if l_merged_rows( l_mrow_ix ).DAYS_TGT_INV_SUPPLY is null then l_merged_rows( l_mrow_ix ).DAYS_TGT_INV_SUPPLY := old_row.DAYS_TGT_INV_SUPPLY; end if;
            if l_merged_rows( l_mrow_ix ).DAYS_TGT_INV_WINDOW is null then l_merged_rows( l_mrow_ix ).DAYS_TGT_INV_WINDOW := old_row.DAYS_TGT_INV_WINDOW; end if;
            if l_merged_rows( l_mrow_ix ).DEFAULT_GRADE is null then l_merged_rows( l_mrow_ix ).DEFAULT_GRADE := old_row.DEFAULT_GRADE; end if;
            if l_merged_rows( l_mrow_ix ).DEFAULT_INCLUDE_IN_ROLLUP_FLAG is null then l_merged_rows( l_mrow_ix ).DEFAULT_INCLUDE_IN_ROLLUP_FLAG := old_row.DEFAULT_INCLUDE_IN_ROLLUP_FLAG; end if;
            if l_merged_rows( l_mrow_ix ).DEFAULT_LOT_STATUS_ID is null then l_merged_rows( l_mrow_ix ).DEFAULT_LOT_STATUS_ID := old_row.DEFAULT_LOT_STATUS_ID; end if;
            if l_merged_rows( l_mrow_ix ).DEFAULT_SERIAL_STATUS_ID is null then l_merged_rows( l_mrow_ix ).DEFAULT_SERIAL_STATUS_ID := old_row.DEFAULT_SERIAL_STATUS_ID; end if;
            if l_merged_rows( l_mrow_ix ).DEFAULT_SHIPPING_ORG is null then l_merged_rows( l_mrow_ix ).DEFAULT_SHIPPING_ORG := old_row.DEFAULT_SHIPPING_ORG; end if;
            if l_merged_rows( l_mrow_ix ).DEFAULT_SO_SOURCE_TYPE is null then l_merged_rows( l_mrow_ix ).DEFAULT_SO_SOURCE_TYPE := old_row.DEFAULT_SO_SOURCE_TYPE; end if;
            if l_merged_rows( l_mrow_ix ).DEFECT_TRACKING_ON_FLAG is null then l_merged_rows( l_mrow_ix ).DEFECT_TRACKING_ON_FLAG := old_row.DEFECT_TRACKING_ON_FLAG; end if;
            if l_merged_rows( l_mrow_ix ).DEMAND_SOURCE_HEADER_ID is null then l_merged_rows( l_mrow_ix ).DEMAND_SOURCE_HEADER_ID := old_row.DEMAND_SOURCE_HEADER_ID; end if;
            if l_merged_rows( l_mrow_ix ).DEMAND_SOURCE_LINE is null then l_merged_rows( l_mrow_ix ).DEMAND_SOURCE_LINE := old_row.DEMAND_SOURCE_LINE; end if;
            if l_merged_rows( l_mrow_ix ).DEMAND_SOURCE_TYPE is null then l_merged_rows( l_mrow_ix ).DEMAND_SOURCE_TYPE := old_row.DEMAND_SOURCE_TYPE; end if;
            if l_merged_rows( l_mrow_ix ).DEMAND_TIME_FENCE_CODE is null then l_merged_rows( l_mrow_ix ).DEMAND_TIME_FENCE_CODE := old_row.DEMAND_TIME_FENCE_CODE; end if;
            if l_merged_rows( l_mrow_ix ).DEMAND_TIME_FENCE_DAYS is null then l_merged_rows( l_mrow_ix ).DEMAND_TIME_FENCE_DAYS := old_row.DEMAND_TIME_FENCE_DAYS; end if;
            if l_merged_rows( l_mrow_ix ).DESCRIPTION is null then l_merged_rows( l_mrow_ix ).DESCRIPTION := old_row.DESCRIPTION; end if;
            if l_merged_rows( l_mrow_ix ).DIMENSION_UOM_CODE is null then l_merged_rows( l_mrow_ix ).DIMENSION_UOM_CODE := old_row.DIMENSION_UOM_CODE; end if;
            if l_merged_rows( l_mrow_ix ).DIVERGENCE is null then l_merged_rows( l_mrow_ix ).DIVERGENCE := old_row.DIVERGENCE; end if;
            if l_merged_rows( l_mrow_ix ).DOWNLOADABLE_FLAG is null then l_merged_rows( l_mrow_ix ).DOWNLOADABLE_FLAG := old_row.DOWNLOADABLE_FLAG; end if;
            if l_merged_rows( l_mrow_ix ).DRP_PLANNED_FLAG is null then l_merged_rows( l_mrow_ix ).DRP_PLANNED_FLAG := old_row.DRP_PLANNED_FLAG; end if;
            if l_merged_rows( l_mrow_ix ).DUAL_UOM_CONTROL is null then l_merged_rows( l_mrow_ix ).DUAL_UOM_CONTROL := old_row.DUAL_UOM_CONTROL; end if;
            if l_merged_rows( l_mrow_ix ).DUAL_UOM_DEVIATION_HIGH is null then l_merged_rows( l_mrow_ix ).DUAL_UOM_DEVIATION_HIGH := old_row.DUAL_UOM_DEVIATION_HIGH; end if;
            if l_merged_rows( l_mrow_ix ).DUAL_UOM_DEVIATION_LOW is null then l_merged_rows( l_mrow_ix ).DUAL_UOM_DEVIATION_LOW := old_row.DUAL_UOM_DEVIATION_LOW; end if;
            if l_merged_rows( l_mrow_ix ).EAM_ACTIVITY_CAUSE_CODE is null then l_merged_rows( l_mrow_ix ).EAM_ACTIVITY_CAUSE_CODE := old_row.EAM_ACTIVITY_CAUSE_CODE; end if;
            if l_merged_rows( l_mrow_ix ).EAM_ACTIVITY_SOURCE_CODE is null then l_merged_rows( l_mrow_ix ).EAM_ACTIVITY_SOURCE_CODE := old_row.EAM_ACTIVITY_SOURCE_CODE; end if;
            if l_merged_rows( l_mrow_ix ).EAM_ACTIVITY_TYPE_CODE is null then l_merged_rows( l_mrow_ix ).EAM_ACTIVITY_TYPE_CODE := old_row.EAM_ACTIVITY_TYPE_CODE; end if;
            if l_merged_rows( l_mrow_ix ).EAM_ACT_NOTIFICATION_FLAG is null then l_merged_rows( l_mrow_ix ).EAM_ACT_NOTIFICATION_FLAG := old_row.EAM_ACT_NOTIFICATION_FLAG; end if;
            if l_merged_rows( l_mrow_ix ).EAM_ACT_SHUTDOWN_STATUS is null then l_merged_rows( l_mrow_ix ).EAM_ACT_SHUTDOWN_STATUS := old_row.EAM_ACT_SHUTDOWN_STATUS; end if;
            if l_merged_rows( l_mrow_ix ).EAM_ITEM_TYPE is null then l_merged_rows( l_mrow_ix ).EAM_ITEM_TYPE := old_row.EAM_ITEM_TYPE; end if;
            if l_merged_rows( l_mrow_ix ).EFFECTIVITY_CONTROL is null then l_merged_rows( l_mrow_ix ).EFFECTIVITY_CONTROL := old_row.EFFECTIVITY_CONTROL; end if;
            if l_merged_rows( l_mrow_ix ).ELECTRONIC_FLAG is null then l_merged_rows( l_mrow_ix ).ELECTRONIC_FLAG := old_row.ELECTRONIC_FLAG; end if;
            if l_merged_rows( l_mrow_ix ).ENABLED_FLAG is null then l_merged_rows( l_mrow_ix ).ENABLED_FLAG := old_row.ENABLED_FLAG; end if;
            if l_merged_rows( l_mrow_ix ).ENCUMBRANCE_ACCOUNT is null then l_merged_rows( l_mrow_ix ).ENCUMBRANCE_ACCOUNT := old_row.ENCUMBRANCE_ACCOUNT; end if;
            if l_merged_rows( l_mrow_ix ).END_ASSEMBLY_PEGGING_FLAG is null then l_merged_rows( l_mrow_ix ).END_ASSEMBLY_PEGGING_FLAG := old_row.END_ASSEMBLY_PEGGING_FLAG; end if;
            if l_merged_rows( l_mrow_ix ).END_DATE_ACTIVE is null then l_merged_rows( l_mrow_ix ).END_DATE_ACTIVE := old_row.END_DATE_ACTIVE; end if;
            if l_merged_rows( l_mrow_ix ).ENFORCE_SHIP_TO_LOCATION_CODE is null then l_merged_rows( l_mrow_ix ).ENFORCE_SHIP_TO_LOCATION_CODE := old_row.ENFORCE_SHIP_TO_LOCATION_CODE; end if;
            if l_merged_rows( l_mrow_ix ).ENGINEERING_DATE is null then l_merged_rows( l_mrow_ix ).ENGINEERING_DATE := old_row.ENGINEERING_DATE; end if;
            if l_merged_rows( l_mrow_ix ).ENGINEERING_ECN_CODE is null then l_merged_rows( l_mrow_ix ).ENGINEERING_ECN_CODE := old_row.ENGINEERING_ECN_CODE; end if;
            if l_merged_rows( l_mrow_ix ).ENGINEERING_ITEM_ID is null then l_merged_rows( l_mrow_ix ).ENGINEERING_ITEM_ID := old_row.ENGINEERING_ITEM_ID; end if;
            if l_merged_rows( l_mrow_ix ).ENG_ITEM_FLAG is null then l_merged_rows( l_mrow_ix ).ENG_ITEM_FLAG := old_row.ENG_ITEM_FLAG; end if;
            if l_merged_rows( l_mrow_ix ).EQUIPMENT_TYPE is null then l_merged_rows( l_mrow_ix ).EQUIPMENT_TYPE := old_row.EQUIPMENT_TYPE; end if;
            if l_merged_rows( l_mrow_ix ).EVENT_FLAG is null then l_merged_rows( l_mrow_ix ).EVENT_FLAG := old_row.EVENT_FLAG; end if;
            if l_merged_rows( l_mrow_ix ).EXCLUDE_FROM_BUDGET_FLAG is null then l_merged_rows( l_mrow_ix ).EXCLUDE_FROM_BUDGET_FLAG := old_row.EXCLUDE_FROM_BUDGET_FLAG; end if;
            if l_merged_rows( l_mrow_ix ).EXPENSE_ACCOUNT is null then l_merged_rows( l_mrow_ix ).EXPENSE_ACCOUNT := old_row.EXPENSE_ACCOUNT; end if;
            if l_merged_rows( l_mrow_ix ).EXPENSE_BILLABLE_FLAG is null then l_merged_rows( l_mrow_ix ).EXPENSE_BILLABLE_FLAG := old_row.EXPENSE_BILLABLE_FLAG; end if;
            if l_merged_rows( l_mrow_ix ).EXPIRATION_ACTION_CODE is null then l_merged_rows( l_mrow_ix ).EXPIRATION_ACTION_CODE := old_row.EXPIRATION_ACTION_CODE; end if;
            if l_merged_rows( l_mrow_ix ).EXPIRATION_ACTION_INTERVAL is null then l_merged_rows( l_mrow_ix ).EXPIRATION_ACTION_INTERVAL := old_row.EXPIRATION_ACTION_INTERVAL; end if;
            if l_merged_rows( l_mrow_ix ).FINANCING_ALLOWED_FLAG is null then l_merged_rows( l_mrow_ix ).FINANCING_ALLOWED_FLAG := old_row.FINANCING_ALLOWED_FLAG; end if;
            if l_merged_rows( l_mrow_ix ).FIXED_DAYS_SUPPLY is null then l_merged_rows( l_mrow_ix ).FIXED_DAYS_SUPPLY := old_row.FIXED_DAYS_SUPPLY; end if;
            if l_merged_rows( l_mrow_ix ).FIXED_LEAD_TIME is null then l_merged_rows( l_mrow_ix ).FIXED_LEAD_TIME := old_row.FIXED_LEAD_TIME; end if;
            if l_merged_rows( l_mrow_ix ).FIXED_LOT_MULTIPLIER is null then l_merged_rows( l_mrow_ix ).FIXED_LOT_MULTIPLIER := old_row.FIXED_LOT_MULTIPLIER; end if;
            if l_merged_rows( l_mrow_ix ).FIXED_ORDER_QUANTITY is null then l_merged_rows( l_mrow_ix ).FIXED_ORDER_QUANTITY := old_row.FIXED_ORDER_QUANTITY; end if;
            if l_merged_rows( l_mrow_ix ).FORECAST_HORIZON is null then l_merged_rows( l_mrow_ix ).FORECAST_HORIZON := old_row.FORECAST_HORIZON; end if;
            if l_merged_rows( l_mrow_ix ).FULL_LEAD_TIME is null then l_merged_rows( l_mrow_ix ).FULL_LEAD_TIME := old_row.FULL_LEAD_TIME; end if;
            if l_merged_rows( l_mrow_ix ).GLOBAL_ATTRIBUTE1 is null then l_merged_rows( l_mrow_ix ).GLOBAL_ATTRIBUTE1 := old_row.GLOBAL_ATTRIBUTE1; end if;
            if l_merged_rows( l_mrow_ix ).GLOBAL_ATTRIBUTE10 is null then l_merged_rows( l_mrow_ix ).GLOBAL_ATTRIBUTE10 := old_row.GLOBAL_ATTRIBUTE10; end if;
            if l_merged_rows( l_mrow_ix ).GLOBAL_ATTRIBUTE2 is null then l_merged_rows( l_mrow_ix ).GLOBAL_ATTRIBUTE2 := old_row.GLOBAL_ATTRIBUTE2; end if;
            if l_merged_rows( l_mrow_ix ).GLOBAL_ATTRIBUTE3 is null then l_merged_rows( l_mrow_ix ).GLOBAL_ATTRIBUTE3 := old_row.GLOBAL_ATTRIBUTE3; end if;
            if l_merged_rows( l_mrow_ix ).GLOBAL_ATTRIBUTE4 is null then l_merged_rows( l_mrow_ix ).GLOBAL_ATTRIBUTE4 := old_row.GLOBAL_ATTRIBUTE4; end if;
            if l_merged_rows( l_mrow_ix ).GLOBAL_ATTRIBUTE5 is null then l_merged_rows( l_mrow_ix ).GLOBAL_ATTRIBUTE5 := old_row.GLOBAL_ATTRIBUTE5; end if;
            if l_merged_rows( l_mrow_ix ).GLOBAL_ATTRIBUTE6 is null then l_merged_rows( l_mrow_ix ).GLOBAL_ATTRIBUTE6 := old_row.GLOBAL_ATTRIBUTE6; end if;
            if l_merged_rows( l_mrow_ix ).GLOBAL_ATTRIBUTE7 is null then l_merged_rows( l_mrow_ix ).GLOBAL_ATTRIBUTE7 := old_row.GLOBAL_ATTRIBUTE7; end if;
            if l_merged_rows( l_mrow_ix ).GLOBAL_ATTRIBUTE8 is null then l_merged_rows( l_mrow_ix ).GLOBAL_ATTRIBUTE8 := old_row.GLOBAL_ATTRIBUTE8; end if;
            if l_merged_rows( l_mrow_ix ).GLOBAL_ATTRIBUTE9 is null then l_merged_rows( l_mrow_ix ).GLOBAL_ATTRIBUTE9 := old_row.GLOBAL_ATTRIBUTE9; end if;
            if l_merged_rows( l_mrow_ix ).GLOBAL_ATTRIBUTE_CATEGORY is null then l_merged_rows( l_mrow_ix ).GLOBAL_ATTRIBUTE_CATEGORY := old_row.GLOBAL_ATTRIBUTE_CATEGORY; end if;
            if l_merged_rows( l_mrow_ix ).GLOBAL_TRADE_ITEM_NUMBER is null then l_merged_rows( l_mrow_ix ).GLOBAL_TRADE_ITEM_NUMBER := old_row.GLOBAL_TRADE_ITEM_NUMBER; end if;
            if l_merged_rows( l_mrow_ix ).GRADE_CONTROL_FLAG is null then l_merged_rows( l_mrow_ix ).GRADE_CONTROL_FLAG := old_row.GRADE_CONTROL_FLAG; end if;
            if l_merged_rows( l_mrow_ix ).GTIN_DESCRIPTION is null then l_merged_rows( l_mrow_ix ).GTIN_DESCRIPTION := old_row.GTIN_DESCRIPTION; end if;
            if l_merged_rows( l_mrow_ix ).HAZARDOUS_MATERIAL_FLAG is null then l_merged_rows( l_mrow_ix ).HAZARDOUS_MATERIAL_FLAG := old_row.HAZARDOUS_MATERIAL_FLAG; end if;
            if l_merged_rows( l_mrow_ix ).HAZARD_CLASS_ID is null then l_merged_rows( l_mrow_ix ).HAZARD_CLASS_ID := old_row.HAZARD_CLASS_ID; end if;
            if l_merged_rows( l_mrow_ix ).HOLD_DAYS is null then l_merged_rows( l_mrow_ix ).HOLD_DAYS := old_row.HOLD_DAYS; end if;
            if l_merged_rows( l_mrow_ix ).IB_ITEM_INSTANCE_CLASS is null then l_merged_rows( l_mrow_ix ).IB_ITEM_INSTANCE_CLASS := old_row.IB_ITEM_INSTANCE_CLASS; end if;
            if l_merged_rows( l_mrow_ix ).INDIVISIBLE_FLAG is null then l_merged_rows( l_mrow_ix ).INDIVISIBLE_FLAG := old_row.INDIVISIBLE_FLAG; end if;
            if l_merged_rows( l_mrow_ix ).INSPECTION_REQUIRED_FLAG is null then l_merged_rows( l_mrow_ix ).INSPECTION_REQUIRED_FLAG := old_row.INSPECTION_REQUIRED_FLAG; end if;
            if l_merged_rows( l_mrow_ix ).INTERNAL_ORDER_ENABLED_FLAG is null then l_merged_rows( l_mrow_ix ).INTERNAL_ORDER_ENABLED_FLAG := old_row.INTERNAL_ORDER_ENABLED_FLAG; end if;
            if l_merged_rows( l_mrow_ix ).INTERNAL_ORDER_FLAG is null then l_merged_rows( l_mrow_ix ).INTERNAL_ORDER_FLAG := old_row.INTERNAL_ORDER_FLAG; end if;
            if l_merged_rows( l_mrow_ix ).INTERNAL_VOLUME is null then l_merged_rows( l_mrow_ix ).INTERNAL_VOLUME := old_row.INTERNAL_VOLUME; end if;
            if l_merged_rows( l_mrow_ix ).INVENTORY_ASSET_FLAG is null then l_merged_rows( l_mrow_ix ).INVENTORY_ASSET_FLAG := old_row.INVENTORY_ASSET_FLAG; end if;
            if l_merged_rows( l_mrow_ix ).INVENTORY_CARRY_PENALTY is null then l_merged_rows( l_mrow_ix ).INVENTORY_CARRY_PENALTY := old_row.INVENTORY_CARRY_PENALTY; end if;
            if l_merged_rows( l_mrow_ix ).INVENTORY_ITEM_FLAG is null then l_merged_rows( l_mrow_ix ).INVENTORY_ITEM_FLAG := old_row.INVENTORY_ITEM_FLAG; end if;
            if l_merged_rows( l_mrow_ix ).INVENTORY_ITEM_STATUS_CODE is null then l_merged_rows( l_mrow_ix ).INVENTORY_ITEM_STATUS_CODE := old_row.INVENTORY_ITEM_STATUS_CODE; end if;
            if l_merged_rows( l_mrow_ix ).INVENTORY_PLANNING_CODE is null then l_merged_rows( l_mrow_ix ).INVENTORY_PLANNING_CODE := old_row.INVENTORY_PLANNING_CODE; end if;
            if l_merged_rows( l_mrow_ix ).INVOICEABLE_ITEM_FLAG is null then l_merged_rows( l_mrow_ix ).INVOICEABLE_ITEM_FLAG := old_row.INVOICEABLE_ITEM_FLAG; end if;
            if l_merged_rows( l_mrow_ix ).INVOICE_CLOSE_TOLERANCE is null then l_merged_rows( l_mrow_ix ).INVOICE_CLOSE_TOLERANCE := old_row.INVOICE_CLOSE_TOLERANCE; end if;
            if l_merged_rows( l_mrow_ix ).INVOICE_ENABLED_FLAG is null then l_merged_rows( l_mrow_ix ).INVOICE_ENABLED_FLAG := old_row.INVOICE_ENABLED_FLAG; end if;
            if l_merged_rows( l_mrow_ix ).INVOICING_RULE_ID is null then l_merged_rows( l_mrow_ix ).INVOICING_RULE_ID := old_row.INVOICING_RULE_ID; end if;
            if l_merged_rows( l_mrow_ix ).ITEM_TYPE is null then l_merged_rows( l_mrow_ix ).ITEM_TYPE := old_row.ITEM_TYPE; end if;
            if l_merged_rows( l_mrow_ix ).LEAD_TIME_LOT_SIZE is null then l_merged_rows( l_mrow_ix ).LEAD_TIME_LOT_SIZE := old_row.LEAD_TIME_LOT_SIZE; end if;
            if l_merged_rows( l_mrow_ix ).LIFECYCLE_ID is null then l_merged_rows( l_mrow_ix ).LIFECYCLE_ID := old_row.LIFECYCLE_ID; end if;
            if l_merged_rows( l_mrow_ix ).LIST_PRICE_PER_UNIT is null then l_merged_rows( l_mrow_ix ).LIST_PRICE_PER_UNIT := old_row.LIST_PRICE_PER_UNIT; end if;
            if l_merged_rows( l_mrow_ix ).LOCATION_CONTROL_CODE is null then l_merged_rows( l_mrow_ix ).LOCATION_CONTROL_CODE := old_row.LOCATION_CONTROL_CODE; end if;
            if l_merged_rows( l_mrow_ix ).LONG_DESCRIPTION is null then l_merged_rows( l_mrow_ix ).LONG_DESCRIPTION := old_row.LONG_DESCRIPTION; end if;
            if l_merged_rows( l_mrow_ix ).LOT_CONTROL_CODE is null then l_merged_rows( l_mrow_ix ).LOT_CONTROL_CODE := old_row.LOT_CONTROL_CODE; end if;
            if l_merged_rows( l_mrow_ix ).LOT_DIVISIBLE_FLAG is null then l_merged_rows( l_mrow_ix ).LOT_DIVISIBLE_FLAG := old_row.LOT_DIVISIBLE_FLAG; end if;
            if l_merged_rows( l_mrow_ix ).LOT_MERGE_ENABLED is null then l_merged_rows( l_mrow_ix ).LOT_MERGE_ENABLED := old_row.LOT_MERGE_ENABLED; end if;
            if l_merged_rows( l_mrow_ix ).LOT_SPLIT_ENABLED is null then l_merged_rows( l_mrow_ix ).LOT_SPLIT_ENABLED := old_row.LOT_SPLIT_ENABLED; end if;
            if l_merged_rows( l_mrow_ix ).LOT_STATUS_ENABLED is null then l_merged_rows( l_mrow_ix ).LOT_STATUS_ENABLED := old_row.LOT_STATUS_ENABLED; end if;
            if l_merged_rows( l_mrow_ix ).LOT_SUBSTITUTION_ENABLED is null then l_merged_rows( l_mrow_ix ).LOT_SUBSTITUTION_ENABLED := old_row.LOT_SUBSTITUTION_ENABLED; end if;
            if l_merged_rows( l_mrow_ix ).LOT_TRANSLATE_ENABLED is null then l_merged_rows( l_mrow_ix ).LOT_TRANSLATE_ENABLED := old_row.LOT_TRANSLATE_ENABLED; end if;
            if l_merged_rows( l_mrow_ix ).MARKET_PRICE is null then l_merged_rows( l_mrow_ix ).MARKET_PRICE := old_row.MARKET_PRICE; end if;
            if l_merged_rows( l_mrow_ix ).MATERIAL_BILLABLE_FLAG is null then l_merged_rows( l_mrow_ix ).MATERIAL_BILLABLE_FLAG := old_row.MATERIAL_BILLABLE_FLAG; end if;
            if l_merged_rows( l_mrow_ix ).MATERIAL_COST is null then l_merged_rows( l_mrow_ix ).MATERIAL_COST := old_row.MATERIAL_COST; end if;
            if l_merged_rows( l_mrow_ix ).MATERIAL_OH_RATE is null then l_merged_rows( l_mrow_ix ).MATERIAL_OH_RATE := old_row.MATERIAL_OH_RATE; end if;
            if l_merged_rows( l_mrow_ix ).MATERIAL_OH_SUB_ELEM is null then l_merged_rows( l_mrow_ix ).MATERIAL_OH_SUB_ELEM := old_row.MATERIAL_OH_SUB_ELEM; end if;
            if l_merged_rows( l_mrow_ix ).MATERIAL_OH_SUB_ELEM_ID is null then l_merged_rows( l_mrow_ix ).MATERIAL_OH_SUB_ELEM_ID := old_row.MATERIAL_OH_SUB_ELEM_ID; end if;
            if l_merged_rows( l_mrow_ix ).MATERIAL_SUB_ELEM is null then l_merged_rows( l_mrow_ix ).MATERIAL_SUB_ELEM := old_row.MATERIAL_SUB_ELEM; end if;
            if l_merged_rows( l_mrow_ix ).MATERIAL_SUB_ELEM_ID is null then l_merged_rows( l_mrow_ix ).MATERIAL_SUB_ELEM_ID := old_row.MATERIAL_SUB_ELEM_ID; end if;
            if l_merged_rows( l_mrow_ix ).MATURITY_DAYS is null then l_merged_rows( l_mrow_ix ).MATURITY_DAYS := old_row.MATURITY_DAYS; end if;
            if l_merged_rows( l_mrow_ix ).MAXIMUM_LOAD_WEIGHT is null then l_merged_rows( l_mrow_ix ).MAXIMUM_LOAD_WEIGHT := old_row.MAXIMUM_LOAD_WEIGHT; end if;
            if l_merged_rows( l_mrow_ix ).MAXIMUM_ORDER_QUANTITY is null then l_merged_rows( l_mrow_ix ).MAXIMUM_ORDER_QUANTITY := old_row.MAXIMUM_ORDER_QUANTITY; end if;
            if l_merged_rows( l_mrow_ix ).MAX_MINMAX_QUANTITY is null then l_merged_rows( l_mrow_ix ).MAX_MINMAX_QUANTITY := old_row.MAX_MINMAX_QUANTITY; end if;
            if l_merged_rows( l_mrow_ix ).MAX_WARRANTY_AMOUNT is null then l_merged_rows( l_mrow_ix ).MAX_WARRANTY_AMOUNT := old_row.MAX_WARRANTY_AMOUNT; end if;
            if l_merged_rows( l_mrow_ix ).MINIMUM_FILL_PERCENT is null then l_merged_rows( l_mrow_ix ).MINIMUM_FILL_PERCENT := old_row.MINIMUM_FILL_PERCENT; end if;
            if l_merged_rows( l_mrow_ix ).MINIMUM_LICENSE_QUANTITY is null then l_merged_rows( l_mrow_ix ).MINIMUM_LICENSE_QUANTITY := old_row.MINIMUM_LICENSE_QUANTITY; end if;
            if l_merged_rows( l_mrow_ix ).MINIMUM_ORDER_QUANTITY is null then l_merged_rows( l_mrow_ix ).MINIMUM_ORDER_QUANTITY := old_row.MINIMUM_ORDER_QUANTITY; end if;
            if l_merged_rows( l_mrow_ix ).MIN_MINMAX_QUANTITY is null then l_merged_rows( l_mrow_ix ).MIN_MINMAX_QUANTITY := old_row.MIN_MINMAX_QUANTITY; end if;
            if l_merged_rows( l_mrow_ix ).MODEL_CONFIG_CLAUSE_NAME is null then l_merged_rows( l_mrow_ix ).MODEL_CONFIG_CLAUSE_NAME := old_row.MODEL_CONFIG_CLAUSE_NAME; end if;
            if l_merged_rows( l_mrow_ix ).MRP_CALCULATE_ATP_FLAG is null then l_merged_rows( l_mrow_ix ).MRP_CALCULATE_ATP_FLAG := old_row.MRP_CALCULATE_ATP_FLAG; end if;
            if l_merged_rows( l_mrow_ix ).MRP_PLANNING_CODE is null then l_merged_rows( l_mrow_ix ).MRP_PLANNING_CODE := old_row.MRP_PLANNING_CODE; end if;
            if l_merged_rows( l_mrow_ix ).MRP_SAFETY_STOCK_CODE is null then l_merged_rows( l_mrow_ix ).MRP_SAFETY_STOCK_CODE := old_row.MRP_SAFETY_STOCK_CODE; end if;
            if l_merged_rows( l_mrow_ix ).MRP_SAFETY_STOCK_PERCENT is null then l_merged_rows( l_mrow_ix ).MRP_SAFETY_STOCK_PERCENT := old_row.MRP_SAFETY_STOCK_PERCENT; end if;
            if l_merged_rows( l_mrow_ix ).MTL_TRANSACTIONS_ENABLED_FLAG is null then l_merged_rows( l_mrow_ix ).MTL_TRANSACTIONS_ENABLED_FLAG := old_row.MTL_TRANSACTIONS_ENABLED_FLAG; end if;
            if l_merged_rows( l_mrow_ix ).MUST_USE_APPROVED_VENDOR_FLAG is null then l_merged_rows( l_mrow_ix ).MUST_USE_APPROVED_VENDOR_FLAG := old_row.MUST_USE_APPROVED_VENDOR_FLAG; end if;
            if l_merged_rows( l_mrow_ix ).NEGATIVE_MEASUREMENT_ERROR is null then l_merged_rows( l_mrow_ix ).NEGATIVE_MEASUREMENT_ERROR := old_row.NEGATIVE_MEASUREMENT_ERROR; end if;
            if l_merged_rows( l_mrow_ix ).NEW_REVISION_CODE is null then l_merged_rows( l_mrow_ix ).NEW_REVISION_CODE := old_row.NEW_REVISION_CODE; end if;
            if l_merged_rows( l_mrow_ix ).ONT_PRICING_QTY_SOURCE is null then l_merged_rows( l_mrow_ix ).ONT_PRICING_QTY_SOURCE := old_row.ONT_PRICING_QTY_SOURCE; end if;
            if l_merged_rows( l_mrow_ix ).OPERATION_SLACK_PENALTY is null then l_merged_rows( l_mrow_ix ).OPERATION_SLACK_PENALTY := old_row.OPERATION_SLACK_PENALTY; end if;
            if l_merged_rows( l_mrow_ix ).ORDERABLE_ON_WEB_FLAG is null then l_merged_rows( l_mrow_ix ).ORDERABLE_ON_WEB_FLAG := old_row.ORDERABLE_ON_WEB_FLAG; end if;
            if l_merged_rows( l_mrow_ix ).ORDER_COST is null then l_merged_rows( l_mrow_ix ).ORDER_COST := old_row.ORDER_COST; end if;
            if l_merged_rows( l_mrow_ix ).OUTSIDE_OPERATION_FLAG is null then l_merged_rows( l_mrow_ix ).OUTSIDE_OPERATION_FLAG := old_row.OUTSIDE_OPERATION_FLAG; end if;
            if l_merged_rows( l_mrow_ix ).OUTSIDE_OPERATION_UOM_TYPE is null then l_merged_rows( l_mrow_ix ).OUTSIDE_OPERATION_UOM_TYPE := old_row.OUTSIDE_OPERATION_UOM_TYPE; end if;
            if l_merged_rows( l_mrow_ix ).OUTSOURCED_ASSEMBLY is null then l_merged_rows( l_mrow_ix ).OUTSOURCED_ASSEMBLY := old_row.OUTSOURCED_ASSEMBLY; end if;
            if l_merged_rows( l_mrow_ix ).OVERCOMPLETION_TOLERANCE_TYPE is null then l_merged_rows( l_mrow_ix ).OVERCOMPLETION_TOLERANCE_TYPE := old_row.OVERCOMPLETION_TOLERANCE_TYPE; end if;
            if l_merged_rows( l_mrow_ix ).OVERCOMPLETION_TOLERANCE_VALUE is null then l_merged_rows( l_mrow_ix ).OVERCOMPLETION_TOLERANCE_VALUE := old_row.OVERCOMPLETION_TOLERANCE_VALUE; end if;
            if l_merged_rows( l_mrow_ix ).OVERRUN_PERCENTAGE is null then l_merged_rows( l_mrow_ix ).OVERRUN_PERCENTAGE := old_row.OVERRUN_PERCENTAGE; end if;
            if l_merged_rows( l_mrow_ix ).OVER_RETURN_TOLERANCE is null then l_merged_rows( l_mrow_ix ).OVER_RETURN_TOLERANCE := old_row.OVER_RETURN_TOLERANCE; end if;
            if l_merged_rows( l_mrow_ix ).OVER_SHIPMENT_TOLERANCE is null then l_merged_rows( l_mrow_ix ).OVER_SHIPMENT_TOLERANCE := old_row.OVER_SHIPMENT_TOLERANCE; end if;
            if l_merged_rows( l_mrow_ix ).PARENT_CHILD_GENERATION_FLAG is null then l_merged_rows( l_mrow_ix ).PARENT_CHILD_GENERATION_FLAG := old_row.PARENT_CHILD_GENERATION_FLAG; end if;
            if l_merged_rows( l_mrow_ix ).PAYMENT_TERMS_ID is null then l_merged_rows( l_mrow_ix ).PAYMENT_TERMS_ID := old_row.PAYMENT_TERMS_ID; end if;
            if l_merged_rows( l_mrow_ix ).PICKING_RULE_ID is null then l_merged_rows( l_mrow_ix ).PICKING_RULE_ID := old_row.PICKING_RULE_ID; end if;
            if l_merged_rows( l_mrow_ix ).PICK_COMPONENTS_FLAG is null then l_merged_rows( l_mrow_ix ).PICK_COMPONENTS_FLAG := old_row.PICK_COMPONENTS_FLAG; end if;
            if l_merged_rows( l_mrow_ix ).PLANNED_INV_POINT_FLAG is null then l_merged_rows( l_mrow_ix ).PLANNED_INV_POINT_FLAG := old_row.PLANNED_INV_POINT_FLAG; end if;
            if l_merged_rows( l_mrow_ix ).PLANNER_CODE is null then l_merged_rows( l_mrow_ix ).PLANNER_CODE := old_row.PLANNER_CODE; end if;
            if l_merged_rows( l_mrow_ix ).PLANNING_EXCEPTION_SET is null then l_merged_rows( l_mrow_ix ).PLANNING_EXCEPTION_SET := old_row.PLANNING_EXCEPTION_SET; end if;
            if l_merged_rows( l_mrow_ix ).PLANNING_MAKE_BUY_CODE is null then l_merged_rows( l_mrow_ix ).PLANNING_MAKE_BUY_CODE := old_row.PLANNING_MAKE_BUY_CODE; end if;
            if l_merged_rows( l_mrow_ix ).PLANNING_TIME_FENCE_CODE is null then l_merged_rows( l_mrow_ix ).PLANNING_TIME_FENCE_CODE := old_row.PLANNING_TIME_FENCE_CODE; end if;
            if l_merged_rows( l_mrow_ix ).PLANNING_TIME_FENCE_DAYS is null then l_merged_rows( l_mrow_ix ).PLANNING_TIME_FENCE_DAYS := old_row.PLANNING_TIME_FENCE_DAYS; end if;
            if l_merged_rows( l_mrow_ix ).POSITIVE_MEASUREMENT_ERROR is null then l_merged_rows( l_mrow_ix ).POSITIVE_MEASUREMENT_ERROR := old_row.POSITIVE_MEASUREMENT_ERROR; end if;
            if l_merged_rows( l_mrow_ix ).POSTPROCESSING_LEAD_TIME is null then l_merged_rows( l_mrow_ix ).POSTPROCESSING_LEAD_TIME := old_row.POSTPROCESSING_LEAD_TIME; end if;
            if l_merged_rows( l_mrow_ix ).PREPOSITION_POINT is null then l_merged_rows( l_mrow_ix ).PREPOSITION_POINT := old_row.PREPOSITION_POINT; end if;
            if l_merged_rows( l_mrow_ix ).PREPROCESSING_LEAD_TIME is null then l_merged_rows( l_mrow_ix ).PREPROCESSING_LEAD_TIME := old_row.PREPROCESSING_LEAD_TIME; end if;
            if l_merged_rows( l_mrow_ix ).PREVENTIVE_MAINTENANCE_FLAG is null then l_merged_rows( l_mrow_ix ).PREVENTIVE_MAINTENANCE_FLAG := old_row.PREVENTIVE_MAINTENANCE_FLAG; end if;
            if l_merged_rows( l_mrow_ix ).PRICE_TOLERANCE_PERCENT is null then l_merged_rows( l_mrow_ix ).PRICE_TOLERANCE_PERCENT := old_row.PRICE_TOLERANCE_PERCENT; end if;
            if l_merged_rows( l_mrow_ix ).PRIMARY_SPECIALIST_ID is null then l_merged_rows( l_mrow_ix ).PRIMARY_SPECIALIST_ID := old_row.PRIMARY_SPECIALIST_ID; end if;
            if l_merged_rows( l_mrow_ix ).PROCESS_COSTING_ENABLED_FLAG is null then l_merged_rows( l_mrow_ix ).PROCESS_COSTING_ENABLED_FLAG := old_row.PROCESS_COSTING_ENABLED_FLAG; end if;
            if l_merged_rows( l_mrow_ix ).PROCESS_EXECUTION_ENABLED_FLAG is null then l_merged_rows( l_mrow_ix ).PROCESS_EXECUTION_ENABLED_FLAG := old_row.PROCESS_EXECUTION_ENABLED_FLAG; end if;
            if l_merged_rows( l_mrow_ix ).PROCESS_QUALITY_ENABLED_FLAG is null then l_merged_rows( l_mrow_ix ).PROCESS_QUALITY_ENABLED_FLAG := old_row.PROCESS_QUALITY_ENABLED_FLAG; end if;
            if l_merged_rows( l_mrow_ix ).PROCESS_SUPPLY_LOCATOR_ID is null then l_merged_rows( l_mrow_ix ).PROCESS_SUPPLY_LOCATOR_ID := old_row.PROCESS_SUPPLY_LOCATOR_ID; end if;
            if l_merged_rows( l_mrow_ix ).PROCESS_SUPPLY_SUBINVENTORY is null then l_merged_rows( l_mrow_ix ).PROCESS_SUPPLY_SUBINVENTORY := old_row.PROCESS_SUPPLY_SUBINVENTORY; end if;
            if l_merged_rows( l_mrow_ix ).PROCESS_YIELD_LOCATOR_ID is null then l_merged_rows( l_mrow_ix ).PROCESS_YIELD_LOCATOR_ID := old_row.PROCESS_YIELD_LOCATOR_ID; end if;
            if l_merged_rows( l_mrow_ix ).PROCESS_YIELD_SUBINVENTORY is null then l_merged_rows( l_mrow_ix ).PROCESS_YIELD_SUBINVENTORY := old_row.PROCESS_YIELD_SUBINVENTORY; end if;
            if l_merged_rows( l_mrow_ix ).PRODUCT_FAMILY_ITEM_ID is null then l_merged_rows( l_mrow_ix ).PRODUCT_FAMILY_ITEM_ID := old_row.PRODUCT_FAMILY_ITEM_ID; end if;
            if l_merged_rows( l_mrow_ix ).PROGRAM_APPLICATION_ID is null then l_merged_rows( l_mrow_ix ).PROGRAM_APPLICATION_ID := old_row.PROGRAM_APPLICATION_ID; end if;
            if l_merged_rows( l_mrow_ix ).PROGRAM_ID is null then l_merged_rows( l_mrow_ix ).PROGRAM_ID := old_row.PROGRAM_ID; end if;
            if l_merged_rows( l_mrow_ix ).PROGRAM_UPDATE_DATE is null then l_merged_rows( l_mrow_ix ).PROGRAM_UPDATE_DATE := old_row.PROGRAM_UPDATE_DATE; end if;
            if l_merged_rows( l_mrow_ix ).PRORATE_SERVICE_FLAG is null then l_merged_rows( l_mrow_ix ).PRORATE_SERVICE_FLAG := old_row.PRORATE_SERVICE_FLAG; end if;
            if l_merged_rows( l_mrow_ix ).PURCHASING_ENABLED_FLAG is null then l_merged_rows( l_mrow_ix ).PURCHASING_ENABLED_FLAG := old_row.PURCHASING_ENABLED_FLAG; end if;
            if l_merged_rows( l_mrow_ix ).PURCHASING_ITEM_FLAG is null then l_merged_rows( l_mrow_ix ).PURCHASING_ITEM_FLAG := old_row.PURCHASING_ITEM_FLAG; end if;
            if l_merged_rows( l_mrow_ix ).PURCHASING_TAX_CODE is null then l_merged_rows( l_mrow_ix ).PURCHASING_TAX_CODE := old_row.PURCHASING_TAX_CODE; end if;
            if l_merged_rows( l_mrow_ix ).QTY_RCV_EXCEPTION_CODE is null then l_merged_rows( l_mrow_ix ).QTY_RCV_EXCEPTION_CODE := old_row.QTY_RCV_EXCEPTION_CODE; end if;
            if l_merged_rows( l_mrow_ix ).QTY_RCV_TOLERANCE is null then l_merged_rows( l_mrow_ix ).QTY_RCV_TOLERANCE := old_row.QTY_RCV_TOLERANCE; end if;
            if l_merged_rows( l_mrow_ix ).RECEIPT_DAYS_EXCEPTION_CODE is null then l_merged_rows( l_mrow_ix ).RECEIPT_DAYS_EXCEPTION_CODE := old_row.RECEIPT_DAYS_EXCEPTION_CODE; end if;
            if l_merged_rows( l_mrow_ix ).RECEIPT_REQUIRED_FLAG is null then l_merged_rows( l_mrow_ix ).RECEIPT_REQUIRED_FLAG := old_row.RECEIPT_REQUIRED_FLAG; end if;
            if l_merged_rows( l_mrow_ix ).RECEIVE_CLOSE_TOLERANCE is null then l_merged_rows( l_mrow_ix ).RECEIVE_CLOSE_TOLERANCE := old_row.RECEIVE_CLOSE_TOLERANCE; end if;
            if l_merged_rows( l_mrow_ix ).RECEIVING_ROUTING_ID is null then l_merged_rows( l_mrow_ix ).RECEIVING_ROUTING_ID := old_row.RECEIVING_ROUTING_ID; end if;
            if l_merged_rows( l_mrow_ix ).RECIPE_ENABLED_FLAG is null then l_merged_rows( l_mrow_ix ).RECIPE_ENABLED_FLAG := old_row.RECIPE_ENABLED_FLAG; end if;
            if l_merged_rows( l_mrow_ix ).RECOVERED_PART_DISP_CODE is null then l_merged_rows( l_mrow_ix ).RECOVERED_PART_DISP_CODE := old_row.RECOVERED_PART_DISP_CODE; end if;
            if l_merged_rows( l_mrow_ix ).RELEASE_TIME_FENCE_CODE is null then l_merged_rows( l_mrow_ix ).RELEASE_TIME_FENCE_CODE := old_row.RELEASE_TIME_FENCE_CODE; end if;
            if l_merged_rows( l_mrow_ix ).RELEASE_TIME_FENCE_DAYS is null then l_merged_rows( l_mrow_ix ).RELEASE_TIME_FENCE_DAYS := old_row.RELEASE_TIME_FENCE_DAYS; end if;
            if l_merged_rows( l_mrow_ix ).REPAIR_LEADTIME is null then l_merged_rows( l_mrow_ix ).REPAIR_LEADTIME := old_row.REPAIR_LEADTIME; end if;
            if l_merged_rows( l_mrow_ix ).REPAIR_PROGRAM is null then l_merged_rows( l_mrow_ix ).REPAIR_PROGRAM := old_row.REPAIR_PROGRAM; end if;
            if l_merged_rows( l_mrow_ix ).REPAIR_YIELD is null then l_merged_rows( l_mrow_ix ).REPAIR_YIELD := old_row.REPAIR_YIELD; end if;
            if l_merged_rows( l_mrow_ix ).REPETITIVE_PLANNING_FLAG is null then l_merged_rows( l_mrow_ix ).REPETITIVE_PLANNING_FLAG := old_row.REPETITIVE_PLANNING_FLAG; end if;
            if l_merged_rows( l_mrow_ix ).REPLENISH_TO_ORDER_FLAG is null then l_merged_rows( l_mrow_ix ).REPLENISH_TO_ORDER_FLAG := old_row.REPLENISH_TO_ORDER_FLAG; end if;
            if l_merged_rows( l_mrow_ix ).REQUEST_ID is null then l_merged_rows( l_mrow_ix ).REQUEST_ID := old_row.REQUEST_ID; end if;
            if l_merged_rows( l_mrow_ix ).RESERVABLE_TYPE is null then l_merged_rows( l_mrow_ix ).RESERVABLE_TYPE := old_row.RESERVABLE_TYPE; end if;
            if l_merged_rows( l_mrow_ix ).RESPONSE_TIME_PERIOD_CODE is null then l_merged_rows( l_mrow_ix ).RESPONSE_TIME_PERIOD_CODE := old_row.RESPONSE_TIME_PERIOD_CODE; end if;
            if l_merged_rows( l_mrow_ix ).RESPONSE_TIME_VALUE is null then l_merged_rows( l_mrow_ix ).RESPONSE_TIME_VALUE := old_row.RESPONSE_TIME_VALUE; end if;
            if l_merged_rows( l_mrow_ix ).RESTRICT_LOCATORS_CODE is null then l_merged_rows( l_mrow_ix ).RESTRICT_LOCATORS_CODE := old_row.RESTRICT_LOCATORS_CODE; end if;
            if l_merged_rows( l_mrow_ix ).RESTRICT_SUBINVENTORIES_CODE is null then l_merged_rows( l_mrow_ix ).RESTRICT_SUBINVENTORIES_CODE := old_row.RESTRICT_SUBINVENTORIES_CODE; end if;
            if l_merged_rows( l_mrow_ix ).RETEST_INTERVAL is null then l_merged_rows( l_mrow_ix ).RETEST_INTERVAL := old_row.RETEST_INTERVAL; end if;
            if l_merged_rows( l_mrow_ix ).RETURNABLE_FLAG is null then l_merged_rows( l_mrow_ix ).RETURNABLE_FLAG := old_row.RETURNABLE_FLAG; end if;
            if l_merged_rows( l_mrow_ix ).RETURN_INSPECTION_REQUIREMENT is null then l_merged_rows( l_mrow_ix ).RETURN_INSPECTION_REQUIREMENT := old_row.RETURN_INSPECTION_REQUIREMENT; end if;
            if l_merged_rows( l_mrow_ix ).REVISION is null then l_merged_rows( l_mrow_ix ).REVISION := old_row.REVISION; end if;
            if l_merged_rows( l_mrow_ix ).REVISION_IMPORT_POLICY is null then l_merged_rows( l_mrow_ix ).REVISION_IMPORT_POLICY := old_row.REVISION_IMPORT_POLICY; end if;
            if l_merged_rows( l_mrow_ix ).REVISION_QTY_CONTROL_CODE is null then l_merged_rows( l_mrow_ix ).REVISION_QTY_CONTROL_CODE := old_row.REVISION_QTY_CONTROL_CODE; end if;
            if l_merged_rows( l_mrow_ix ).RFQ_REQUIRED_FLAG is null then l_merged_rows( l_mrow_ix ).RFQ_REQUIRED_FLAG := old_row.RFQ_REQUIRED_FLAG; end if;
            if l_merged_rows( l_mrow_ix ).ROUNDING_CONTROL_TYPE is null then l_merged_rows( l_mrow_ix ).ROUNDING_CONTROL_TYPE := old_row.ROUNDING_CONTROL_TYPE; end if;
            if l_merged_rows( l_mrow_ix ).ROUNDING_FACTOR is null then l_merged_rows( l_mrow_ix ).ROUNDING_FACTOR := old_row.ROUNDING_FACTOR; end if;
            if l_merged_rows( l_mrow_ix ).SAFETY_STOCK_BUCKET_DAYS is null then l_merged_rows( l_mrow_ix ).SAFETY_STOCK_BUCKET_DAYS := old_row.SAFETY_STOCK_BUCKET_DAYS; end if;
            if l_merged_rows( l_mrow_ix ).SALES_ACCOUNT is null then l_merged_rows( l_mrow_ix ).SALES_ACCOUNT := old_row.SALES_ACCOUNT; end if;
            if l_merged_rows( l_mrow_ix ).SECONDARY_DEFAULT_IND is null then l_merged_rows( l_mrow_ix ).SECONDARY_DEFAULT_IND := old_row.SECONDARY_DEFAULT_IND; end if;
            if l_merged_rows( l_mrow_ix ).SECONDARY_SPECIALIST_ID is null then l_merged_rows( l_mrow_ix ).SECONDARY_SPECIALIST_ID := old_row.SECONDARY_SPECIALIST_ID; end if;
            if l_merged_rows( l_mrow_ix ).SECONDARY_UOM_CODE is null then l_merged_rows( l_mrow_ix ).SECONDARY_UOM_CODE := old_row.SECONDARY_UOM_CODE; end if;
            if l_merged_rows( l_mrow_ix ).SERIAL_NUMBER_CONTROL_CODE is null then l_merged_rows( l_mrow_ix ).SERIAL_NUMBER_CONTROL_CODE := old_row.SERIAL_NUMBER_CONTROL_CODE; end if;
            if l_merged_rows( l_mrow_ix ).SERIAL_STATUS_ENABLED is null then l_merged_rows( l_mrow_ix ).SERIAL_STATUS_ENABLED := old_row.SERIAL_STATUS_ENABLED; end if;
            if l_merged_rows( l_mrow_ix ).SERVICEABLE_COMPONENT_FLAG is null then l_merged_rows( l_mrow_ix ).SERVICEABLE_COMPONENT_FLAG := old_row.SERVICEABLE_COMPONENT_FLAG; end if;
            if l_merged_rows( l_mrow_ix ).SERVICEABLE_ITEM_CLASS_ID is null then l_merged_rows( l_mrow_ix ).SERVICEABLE_ITEM_CLASS_ID := old_row.SERVICEABLE_ITEM_CLASS_ID; end if;
            if l_merged_rows( l_mrow_ix ).SERVICEABLE_PRODUCT_FLAG is null then l_merged_rows( l_mrow_ix ).SERVICEABLE_PRODUCT_FLAG := old_row.SERVICEABLE_PRODUCT_FLAG; end if;
            if l_merged_rows( l_mrow_ix ).SERVICE_DURATION is null then l_merged_rows( l_mrow_ix ).SERVICE_DURATION := old_row.SERVICE_DURATION; end if;
            if l_merged_rows( l_mrow_ix ).SERVICE_DURATION_PERIOD_CODE is null then l_merged_rows( l_mrow_ix ).SERVICE_DURATION_PERIOD_CODE := old_row.SERVICE_DURATION_PERIOD_CODE; end if;
            if l_merged_rows( l_mrow_ix ).SERVICE_ITEM_FLAG is null then l_merged_rows( l_mrow_ix ).SERVICE_ITEM_FLAG := old_row.SERVICE_ITEM_FLAG; end if;
            if l_merged_rows( l_mrow_ix ).SERVICE_STARTING_DELAY is null then l_merged_rows( l_mrow_ix ).SERVICE_STARTING_DELAY := old_row.SERVICE_STARTING_DELAY; end if;
            if l_merged_rows( l_mrow_ix ).SERV_BILLING_ENABLED_FLAG is null then l_merged_rows( l_mrow_ix ).SERV_BILLING_ENABLED_FLAG := old_row.SERV_BILLING_ENABLED_FLAG; end if;
            if l_merged_rows( l_mrow_ix ).SERV_IMPORTANCE_LEVEL is null then l_merged_rows( l_mrow_ix ).SERV_IMPORTANCE_LEVEL := old_row.SERV_IMPORTANCE_LEVEL; end if;
            if l_merged_rows( l_mrow_ix ).SERV_REQ_ENABLED_CODE is null then l_merged_rows( l_mrow_ix ).SERV_REQ_ENABLED_CODE := old_row.SERV_REQ_ENABLED_CODE; end if;
            if l_merged_rows( l_mrow_ix ).SET_ID is null then l_merged_rows( l_mrow_ix ).SET_ID := old_row.SET_ID; end if;
            if l_merged_rows( l_mrow_ix ).SHELF_LIFE_CODE is null then l_merged_rows( l_mrow_ix ).SHELF_LIFE_CODE := old_row.SHELF_LIFE_CODE; end if;
            if l_merged_rows( l_mrow_ix ).SHELF_LIFE_DAYS is null then l_merged_rows( l_mrow_ix ).SHELF_LIFE_DAYS := old_row.SHELF_LIFE_DAYS; end if;
            if l_merged_rows( l_mrow_ix ).SHIPPABLE_ITEM_FLAG is null then l_merged_rows( l_mrow_ix ).SHIPPABLE_ITEM_FLAG := old_row.SHIPPABLE_ITEM_FLAG; end if;
            if l_merged_rows( l_mrow_ix ).SHIP_MODEL_COMPLETE_FLAG is null then l_merged_rows( l_mrow_ix ).SHIP_MODEL_COMPLETE_FLAG := old_row.SHIP_MODEL_COMPLETE_FLAG; end if;
            if l_merged_rows( l_mrow_ix ).SHRINKAGE_RATE is null then l_merged_rows( l_mrow_ix ).SHRINKAGE_RATE := old_row.SHRINKAGE_RATE; end if;
            if l_merged_rows( l_mrow_ix ).SOURCE_ORGANIZATION_ID is null then l_merged_rows( l_mrow_ix ).SOURCE_ORGANIZATION_ID := old_row.SOURCE_ORGANIZATION_ID; end if;
            if l_merged_rows( l_mrow_ix ).SOURCE_SUBINVENTORY is null then l_merged_rows( l_mrow_ix ).SOURCE_SUBINVENTORY := old_row.SOURCE_SUBINVENTORY; end if;
            if l_merged_rows( l_mrow_ix ).SOURCE_SYSTEM_REFERENCE_DESC is null then l_merged_rows( l_mrow_ix ).SOURCE_SYSTEM_REFERENCE_DESC := old_row.SOURCE_SYSTEM_REFERENCE_DESC; end if;
            if l_merged_rows( l_mrow_ix ).SOURCE_TYPE is null then l_merged_rows( l_mrow_ix ).SOURCE_TYPE := old_row.SOURCE_TYPE; end if;
            if l_merged_rows( l_mrow_ix ).SO_AUTHORIZATION_FLAG is null then l_merged_rows( l_mrow_ix ).SO_AUTHORIZATION_FLAG := old_row.SO_AUTHORIZATION_FLAG; end if;
            if l_merged_rows( l_mrow_ix ).SO_TRANSACTIONS_FLAG is null then l_merged_rows( l_mrow_ix ).SO_TRANSACTIONS_FLAG := old_row.SO_TRANSACTIONS_FLAG; end if;
            if l_merged_rows( l_mrow_ix ).START_AUTO_LOT_NUMBER is null then l_merged_rows( l_mrow_ix ).START_AUTO_LOT_NUMBER := old_row.START_AUTO_LOT_NUMBER; end if;
            if l_merged_rows( l_mrow_ix ).START_AUTO_SERIAL_NUMBER is null then l_merged_rows( l_mrow_ix ).START_AUTO_SERIAL_NUMBER := old_row.START_AUTO_SERIAL_NUMBER; end if;
            if l_merged_rows( l_mrow_ix ).START_DATE_ACTIVE is null then l_merged_rows( l_mrow_ix ).START_DATE_ACTIVE := old_row.START_DATE_ACTIVE; end if;
            if l_merged_rows( l_mrow_ix ).STD_LOT_SIZE is null then l_merged_rows( l_mrow_ix ).STD_LOT_SIZE := old_row.STD_LOT_SIZE; end if;
            if l_merged_rows( l_mrow_ix ).STOCK_ENABLED_FLAG is null then l_merged_rows( l_mrow_ix ).STOCK_ENABLED_FLAG := old_row.STOCK_ENABLED_FLAG; end if;
            if l_merged_rows( l_mrow_ix ).SUBCONTRACTING_COMPONENT is null then l_merged_rows( l_mrow_ix ).SUBCONTRACTING_COMPONENT := old_row.SUBCONTRACTING_COMPONENT; end if;
            if l_merged_rows( l_mrow_ix ).SUBSCRIPTION_DEPEND_FLAG is null then l_merged_rows( l_mrow_ix ).SUBSCRIPTION_DEPEND_FLAG := old_row.SUBSCRIPTION_DEPEND_FLAG; end if;
            if l_merged_rows( l_mrow_ix ).SUBSTITUTION_WINDOW_CODE is null then l_merged_rows( l_mrow_ix ).SUBSTITUTION_WINDOW_CODE := old_row.SUBSTITUTION_WINDOW_CODE; end if;
            if l_merged_rows( l_mrow_ix ).SUBSTITUTION_WINDOW_DAYS is null then l_merged_rows( l_mrow_ix ).SUBSTITUTION_WINDOW_DAYS := old_row.SUBSTITUTION_WINDOW_DAYS; end if;
            if l_merged_rows( l_mrow_ix ).SUMMARY_FLAG is null then l_merged_rows( l_mrow_ix ).SUMMARY_FLAG := old_row.SUMMARY_FLAG; end if;
            if l_merged_rows( l_mrow_ix ).TAXABLE_FLAG is null then l_merged_rows( l_mrow_ix ).TAXABLE_FLAG := old_row.TAXABLE_FLAG; end if;
            if l_merged_rows( l_mrow_ix ).TAX_CODE is null then l_merged_rows( l_mrow_ix ).TAX_CODE := old_row.TAX_CODE; end if;
            if l_merged_rows( l_mrow_ix ).TIME_BILLABLE_FLAG is null then l_merged_rows( l_mrow_ix ).TIME_BILLABLE_FLAG := old_row.TIME_BILLABLE_FLAG; end if;
            if l_merged_rows( l_mrow_ix ).TRACKING_QUANTITY_IND is null then l_merged_rows( l_mrow_ix ).TRACKING_QUANTITY_IND := old_row.TRACKING_QUANTITY_IND; end if;
            if l_merged_rows( l_mrow_ix ).TRANSACTION_ID is null then l_merged_rows( l_mrow_ix ).TRANSACTION_ID := old_row.TRANSACTION_ID; end if;
            if l_merged_rows( l_mrow_ix ).UNDER_RETURN_TOLERANCE is null then l_merged_rows( l_mrow_ix ).UNDER_RETURN_TOLERANCE := old_row.UNDER_RETURN_TOLERANCE; end if;
            if l_merged_rows( l_mrow_ix ).UNDER_SHIPMENT_TOLERANCE is null then l_merged_rows( l_mrow_ix ).UNDER_SHIPMENT_TOLERANCE := old_row.UNDER_SHIPMENT_TOLERANCE; end if;
            if l_merged_rows( l_mrow_ix ).UNIT_HEIGHT is null then l_merged_rows( l_mrow_ix ).UNIT_HEIGHT := old_row.UNIT_HEIGHT; end if;
            if l_merged_rows( l_mrow_ix ).UNIT_LENGTH is null then l_merged_rows( l_mrow_ix ).UNIT_LENGTH := old_row.UNIT_LENGTH; end if;
            if l_merged_rows( l_mrow_ix ).UNIT_OF_ISSUE is null then l_merged_rows( l_mrow_ix ).UNIT_OF_ISSUE := old_row.UNIT_OF_ISSUE; end if;
            if l_merged_rows( l_mrow_ix ).UNIT_VOLUME is null then l_merged_rows( l_mrow_ix ).UNIT_VOLUME := old_row.UNIT_VOLUME; end if;
            if l_merged_rows( l_mrow_ix ).UNIT_WEIGHT is null then l_merged_rows( l_mrow_ix ).UNIT_WEIGHT := old_row.UNIT_WEIGHT; end if;
            if l_merged_rows( l_mrow_ix ).UNIT_WIDTH is null then l_merged_rows( l_mrow_ix ).UNIT_WIDTH := old_row.UNIT_WIDTH; end if;
            if l_merged_rows( l_mrow_ix ).UN_NUMBER_ID is null then l_merged_rows( l_mrow_ix ).UN_NUMBER_ID := old_row.UN_NUMBER_ID; end if;
            if l_merged_rows( l_mrow_ix ).USAGE_ITEM_FLAG is null then l_merged_rows( l_mrow_ix ).USAGE_ITEM_FLAG := old_row.USAGE_ITEM_FLAG; end if;
            if l_merged_rows( l_mrow_ix ).VARIABLE_LEAD_TIME is null then l_merged_rows( l_mrow_ix ).VARIABLE_LEAD_TIME := old_row.VARIABLE_LEAD_TIME; end if;
            if l_merged_rows( l_mrow_ix ).VEHICLE_ITEM_FLAG is null then l_merged_rows( l_mrow_ix ).VEHICLE_ITEM_FLAG := old_row.VEHICLE_ITEM_FLAG; end if;
            if l_merged_rows( l_mrow_ix ).VENDOR_WARRANTY_FLAG is null then l_merged_rows( l_mrow_ix ).VENDOR_WARRANTY_FLAG := old_row.VENDOR_WARRANTY_FLAG; end if;
            if l_merged_rows( l_mrow_ix ).VMI_FIXED_ORDER_QUANTITY is null then l_merged_rows( l_mrow_ix ).VMI_FIXED_ORDER_QUANTITY := old_row.VMI_FIXED_ORDER_QUANTITY; end if;
            if l_merged_rows( l_mrow_ix ).VMI_FORECAST_TYPE is null then l_merged_rows( l_mrow_ix ).VMI_FORECAST_TYPE := old_row.VMI_FORECAST_TYPE; end if;
            if l_merged_rows( l_mrow_ix ).VMI_MAXIMUM_DAYS is null then l_merged_rows( l_mrow_ix ).VMI_MAXIMUM_DAYS := old_row.VMI_MAXIMUM_DAYS; end if;
            if l_merged_rows( l_mrow_ix ).VMI_MAXIMUM_UNITS is null then l_merged_rows( l_mrow_ix ).VMI_MAXIMUM_UNITS := old_row.VMI_MAXIMUM_UNITS; end if;
            if l_merged_rows( l_mrow_ix ).VMI_MINIMUM_DAYS is null then l_merged_rows( l_mrow_ix ).VMI_MINIMUM_DAYS := old_row.VMI_MINIMUM_DAYS; end if;
            if l_merged_rows( l_mrow_ix ).VMI_MINIMUM_UNITS is null then l_merged_rows( l_mrow_ix ).VMI_MINIMUM_UNITS := old_row.VMI_MINIMUM_UNITS; end if;
            if l_merged_rows( l_mrow_ix ).VOLUME_UOM_CODE is null then l_merged_rows( l_mrow_ix ).VOLUME_UOM_CODE := old_row.VOLUME_UOM_CODE; end if;
            if l_merged_rows( l_mrow_ix ).VOL_DISCOUNT_EXEMPT_FLAG is null then l_merged_rows( l_mrow_ix ).VOL_DISCOUNT_EXEMPT_FLAG := old_row.VOL_DISCOUNT_EXEMPT_FLAG; end if;
            if l_merged_rows( l_mrow_ix ).WARRANTY_VENDOR_ID is null then l_merged_rows( l_mrow_ix ).WARRANTY_VENDOR_ID := old_row.WARRANTY_VENDOR_ID; end if;
            if l_merged_rows( l_mrow_ix ).WEB_STATUS is null then l_merged_rows( l_mrow_ix ).WEB_STATUS := old_row.WEB_STATUS; end if;
            if l_merged_rows( l_mrow_ix ).WEIGHT_UOM_CODE is null then l_merged_rows( l_mrow_ix ).WEIGHT_UOM_CODE := old_row.WEIGHT_UOM_CODE; end if;
            if l_merged_rows( l_mrow_ix ).WH_UPDATE_DATE is null then l_merged_rows( l_mrow_ix ).WH_UPDATE_DATE := old_row.WH_UPDATE_DATE; end if;
            if l_merged_rows( l_mrow_ix ).WIP_SUPPLY_LOCATOR_ID is null then l_merged_rows( l_mrow_ix ).WIP_SUPPLY_LOCATOR_ID := old_row.WIP_SUPPLY_LOCATOR_ID; end if;
            if l_merged_rows( l_mrow_ix ).WIP_SUPPLY_SUBINVENTORY is null then l_merged_rows( l_mrow_ix ).WIP_SUPPLY_SUBINVENTORY := old_row.WIP_SUPPLY_SUBINVENTORY; end if;
            if l_merged_rows( l_mrow_ix ).WIP_SUPPLY_TYPE is null then l_merged_rows( l_mrow_ix ).WIP_SUPPLY_TYPE := old_row.WIP_SUPPLY_TYPE; end if;
            -- end generated code
        END LOOP; -- over old rows
        /*
        -- XXX: In case only null/invalid transaction types encountered, set transaction type to SYNC ?.
        IF l_merged_rows( l_mrow_ix ).TRANSACTION_TYPE IS NULL THEN
            l_merged_rows( l_mrow_ix ).TRANSACTION_TYPE := G_TRANS_TYPE_SYNC;
        END IF;
        */
        --Changing the confirm status for the last group of merged items.
        IF( l_cur_rank > 0 AND NOT l_is_pdh_batch) THEN
            IF( l_merged_rows(l_mrow_ix).CONFIRM_STATUS NOT IN ( G_UNCONF_NONE_MATCH, G_UNCONF_SIGL_MATCH, G_UNCONF_MULT_MATCH  )
                AND l_merged_rows(l_mrow_ix).TRANSACTION_TYPE = G_TRANS_TYPE_CREATE )
            THEN
                l_merged_rows(l_mrow_ix).CONFIRM_STATUS := G_CONF_NEW;
            END IF;
            IF( l_excluded_flag IS NOT NULL) THEN
                l_merged_rows( l_mrow_ix ).CONFIRM_STATUS := G_EXCLUDED;
            END IF;
        END IF; --IF( l_cur_rank > 0 AND NOT l_is_pdh_batch)

        Debug_Conc_Log( l_proc_log_prefix || 'Rows requiring merging: ' || c_target_rows%ROWCOUNT );
        IF c_target_rows%ISOPEN THEN
            CLOSE c_target_rows;
        END IF;

        IF l_merged_rows IS NOT NULL THEN
            -- delete
            Debug_Conc_Log( l_proc_log_prefix || 'Deleting ' || l_old_rowids.COUNT || ' old rows ...' );
            FORALL rid_ix IN INDICES OF l_old_rowids
                DELETE FROM MTL_SYSTEM_ITEMS_INTERFACE
                    WHERE ROWID = l_old_rowids( rid_ix );
            -- insert
            Debug_Conc_Log( l_proc_log_prefix || 'Inserting ' || l_merged_rows.COUNT || ' merged rows ...' );
            FORALL row_index IN INDICES OF l_merged_rows
                INSERT INTO MTL_SYSTEM_ITEMS_INTERFACE
                    VALUES l_merged_rows( row_index );
        END IF;

        IF p_commit = FND_API.G_TRUE THEN
            Debug_Conc_Log( l_proc_log_prefix || 'Committing' );
            COMMIT;
        END IF;
        Debug_Conc_Log( l_proc_log_prefix || 'Exiting' );
    END merge_items;

    PROCEDURE merge_revs( p_batch_id       IN NUMBER
                        , p_is_pdh_batch   IN FLAG
                        , p_ss_id          IN NUMBER    DEFAULT NULL
                        , p_master_org_id  IN NUMBER    DEFAULT NULL
                        , p_commit         IN FLAG      DEFAULT FND_API.G_FALSE
                        )
    IS
        SUBTYPE MIRI_ROW   IS MTL_ITEM_REVISIONS_INTERFACE%ROWTYPE;
        TYPE MIRI_ROWS  IS TABLE OF MIRI_ROW INDEX BY BINARY_INTEGER;

        /*
         * Note that the organization_id column is filled in from the organization_code and batch organization_id
         *   as part of resolve_ssxref_on_data_load
         * revision column is filled in from the revision_id before this cursor is fetched.
         */
        CURSOR c_ss_target_revs( cp_ss_id         MTL_ITEM_REVISIONS_INTERFACE.SOURCE_SYSTEM_ID%TYPE
                               , cp_master_org_id MTL_ITEM_REVISIONS_INTERFACE.ORGANIZATION_ID%TYPE ) IS
            SELECT
                rowid rid
                , FIRST_VALUE( ROWID ) OVER ( PARTITION BY
                                              source_system_id
                                            , source_system_reference
                                            , organization_id
                                            , revision
                                              ORDER BY
                                              last_update_date desc nulls last
                                            , interface_table_unique_id desc nulls last
                                            ) master_rid
                , RANK( ) OVER ( PARTITION BY
                                  source_system_id
                                , source_system_reference
                                , organization_id
                                , revision
                                  ORDER BY
                                  last_update_date desc nulls last
                                , interface_table_unique_id desc nulls last
                                ) local_rank
                , sub.*
            FROM
                ( SELECT
                    COUNT( * ) OVER ( PARTITION BY
                                      source_system_id
                                    , source_system_reference
                                    , organization_id
                                    , revision
                                    )
                    cnt
                    , miri.*
                FROM mtl_item_revisions_interface miri
                WHERE   PROCESS_FLAG            = 0
                   and  SET_PROCESS_ID          = p_batch_id
                   and  SOURCE_SYSTEM_ID        = cp_ss_id
                   and  SOURCE_SYSTEM_REFERENCE IS NOT NULL
                   AND  ORGANIZATION_ID         IS NOT NULL
                   and  EXISTS ( SELECT null
                                 FROM   mtl_parameters mp
                                 WHERE  mp.ORGANIZATION_ID        = miri.ORGANIZATION_ID
                                   and  mp.MASTER_ORGANIZATION_ID = cp_master_org_id
                               )
                )
                sub
            WHERE sub.cnt > 1
            ORDER BY master_rid, local_rank;

        CURSOR c_pdh_target_revs( cp_master_org_id MTL_ITEM_REVISIONS_INTERFACE.ORGANIZATION_ID%TYPE ) IS
            SELECT
                rowid rid
                , first_value( rowid ) over ( PARTITION BY
                                              item_number
                                            , organization_id
                                            , revision
                                              ORDER BY
                                              last_update_date desc nulls last
                                            , interface_table_unique_id desc nulls last
                                            ) master_rid
                , rank( ) over ( PARTITION BY
                                  item_number
                                , organization_id
                                , revision
                                  ORDER BY
                                  last_update_date desc nulls last
                                , interface_table_unique_id desc nulls last
                                ) local_rank
                , sub.*
            FROM
                ( select
                    count( * ) over ( PARTITION BY
                                      item_number
                                    , organization_id
                                    , revision
                                    )
                    cnt
                    , miri.*
                FROM MTL_ITEM_REVISIONS_INTERFACE miri
                WHERE   PROCESS_FLAG            = 1
                   AND  SET_PROCESS_ID          = p_batch_id
                   AND  ITEM_NUMBER             IS NOT NULL
                   AND  ORGANIZATION_ID         IS NOT NULL
                   AND  (   SOURCE_SYSTEM_ID    IS NULL
                        OR  SOURCE_SYSTEM_ID    = G_PDH_SOURCE_SYSTEM_ID
                        )
                   AND  EXISTS ( SELECT null
                                 FROM   mtl_parameters mp
                                 WHERE  mp.organization_id        = miri.organization_id
                                   AND  mp.master_organization_id = cp_master_org_id
                               )
                )
                sub
            WHERE sub.cnt > 1
            ORDER BY master_rid, local_rank;

        TYPE TARGET_ROWS    IS TABLE OF c_ss_target_revs%ROWTYPE;

        l_merged_rows   MIRI_ROWS;
        l_merge_base    MIRI_ROW;
        l_old_rows      TARGET_ROWS;
        l_old_rowids    UROWID_TABLE;

        l_ss_id         MTL_ITEM_REVISIONS_INTERFACE.SOURCE_SYSTEM_ID%TYPE := p_ss_id;
        l_ssr           MTL_ITEM_REVISIONS_INTERFACE.SOURCE_SYSTEM_REFERENCE%TYPE;
        l_candidate_trans MTL_ITEM_REVISIONS_INTERFACE.TRANSACTION_TYPE%TYPE;

        l_cur_master_rid    UROWID := NULL;
        l_mrow_ix           PLS_INTEGER := 0;
        l_is_pdh_batch      BOOLEAN;

        l_org_id        MTL_ITEM_REVISIONS_INTERFACE.ORGANIZATION_ID%TYPE := p_master_org_id;
        l_pdh_batch_flag FLAG := p_is_pdh_batch;

        l_proc_log_prefix CONSTANT VARCHAR2(30) := 'merge_revs - ';
    BEGIN
        Debug_Conc_Log( l_proc_log_prefix || 'Entering' );
        Debug_Conc_Log( l_proc_log_prefix || 'Batch ID: ' || p_batch_id );
        IF  l_pdh_batch_flag IS NULL OR l_org_id IS NULL OR l_ss_id IS NULL THEN
            merge_params_from_batch_header( p_batch_id      => p_batch_id
                                          , x_is_pdh_batch  => l_pdh_batch_flag
                                          , x_master_org_id => l_org_id
                                          , x_ss_id         => l_ss_id
                                          );
        END IF;
        Debug_Conc_Log( l_proc_log_prefix || 'Master Org ID: ' || l_org_id );
        Debug_Conc_Log( l_proc_log_prefix || 'SS ID: ' || l_ss_id );
        Debug_Conc_Log( l_proc_log_prefix || 'Is PDH Batch?: ' || l_pdh_batch_flag );

        UPDATE MTL_ITEM_REVISIONS_INTERFACE miri
            SET REVISION = NVL( (   SELECT  r.REVISION
                                    FROM    MTL_ITEM_REVISIONS_B r
                                    WHERE   r.REVISION_ID       = miri.REVISION_ID
                                        AND r.ORGANIZATION_ID   = miri.ORGANIZATION_ID
                                )
                              , REVISION
                              )
             WHERE REVISION_ID IS NOT NULL
               AND SET_PROCESS_ID = p_batch_id
               AND REVISION IS NULL;

        l_is_pdh_batch  := ( l_pdh_batch_flag = FND_API.G_TRUE );
        IF  l_is_pdh_batch THEN
            OPEN c_pdh_target_revs( l_org_id );
            FETCH c_pdh_target_revs BULK COLLECT INTO l_old_rows;
            CLOSE c_pdh_target_revs;
        ELSE
            OPEN c_ss_target_revs( l_ss_id, l_org_id );
            FETCH c_ss_target_revs BULK COLLECT INTO l_old_rows;
            CLOSE c_ss_target_revs;
        END IF;

        Debug_Conc_Log( l_proc_log_prefix || 'Rows requiring merging: ' || l_old_rows.COUNT );
        IF 0 <>  l_old_rows.COUNT THEN
            -- attributes common to every merged row
            l_merge_base.SET_PROCESS_ID := p_batch_id;
            l_merge_base.PROCESS_FLAG   := CASE WHEN l_is_pdh_batch THEN 1 ELSE 0 END;

            l_old_rowids := UROWID_TABLE( );
            l_old_rowids.EXTEND( l_old_rows.COUNT );

            FOR orow_ix IN l_old_rows.FIRST .. l_old_rows.LAST LOOP
                l_old_rowids( orow_ix ) := l_old_rows( orow_ix ).RID;

                IF( l_cur_master_rid IS NULL
                  OR l_old_rows( orow_ix ).master_rid <> l_cur_master_rid )
                THEN
                    l_cur_master_rid := l_old_rows( orow_ix ).master_rid;
                    Debug_Conc_Log( l_proc_log_prefix || '  Starting new merged row; ROWID = '|| l_cur_master_rid );
                    l_mrow_ix := l_mrow_ix + 1;
                    l_merged_rows( l_mrow_ix ) := l_merge_base;
                    IF NOT l_is_pdh_batch THEN
                        l_merged_rows( l_mrow_ix ).SOURCE_SYSTEM_ID          := l_old_rows( orow_ix ).SOURCE_SYSTEM_ID;
                        l_merged_rows( l_mrow_ix ).SOURCE_SYSTEM_REFERENCE   := l_old_rows( orow_ix ).SOURCE_SYSTEM_REFERENCE;
                        Debug_Conc_Log( l_proc_log_prefix || '   Source System Reference = ' || l_merged_rows( l_mrow_ix ).SOURCE_SYSTEM_REFERENCE );
                    END IF;
                ELSE
                    Debug_Conc_Log( l_proc_log_prefix || '  Merging another record into current merged row; ROWID = '
                                  || l_old_rows( orow_ix ).rid || '; master ROWID = '|| l_cur_master_rid );
                END IF;

                -- Special Cases:
                -- Transaction type
                l_candidate_trans := UPPER( l_old_rows( orow_ix ).TRANSACTION_TYPE );

                IF      l_merged_rows( l_mrow_ix ).TRANSACTION_TYPE IS NULL
                    OR  l_merged_rows( l_mrow_ix ).TRANSACTION_TYPE <> l_candidate_trans -- <> filters out nulls
                THEN
                    -- CREATE > SYNC > UPDATE : order of case expression matters
                    l_merged_rows( l_mrow_ix ).TRANSACTION_TYPE :=
                        CASE
                            WHEN l_merged_rows( l_mrow_ix ).TRANSACTION_TYPE = G_TRANS_TYPE_CREATE
                              OR l_candidate_trans = G_TRANS_TYPE_CREATE                            THEN G_TRANS_TYPE_CREATE
                            WHEN l_merged_rows( l_mrow_ix ).TRANSACTION_TYPE = G_TRANS_TYPE_SYNC
                              OR l_candidate_trans = G_TRANS_TYPE_SYNC                              THEN G_TRANS_TYPE_SYNC
                            WHEN l_merged_rows( l_mrow_ix ).TRANSACTION_TYPE = G_TRANS_TYPE_UPDATE
                              OR l_candidate_trans = G_TRANS_TYPE_UPDATE                            THEN G_TRANS_TYPE_UPDATE
                            ELSE NULL -- INVALID transaction types encountered ...
                        END;
                END IF;

                -- The following columns need to be treated as atomic groups
                -- 1. Item Identifier
                IF      l_merged_rows( l_mrow_ix ).INVENTORY_ITEM_ID  IS NULL
                    AND l_merged_rows( l_mrow_ix ).ITEM_NUMBER        IS NULL
                THEN
                    l_merged_rows( l_mrow_ix ).INVENTORY_ITEM_ID  := l_old_rows( orow_ix ).INVENTORY_ITEM_ID;
                    l_merged_rows( l_mrow_ix ).ITEM_NUMBER        := l_old_rows( orow_ix ).ITEM_NUMBER;
                END IF;

                -- 2. Organization
                IF      l_merged_rows( l_mrow_ix ).ORGANIZATION_ID    IS NULL
                    AND l_merged_rows( l_mrow_ix ).ORGANIZATION_CODE  IS NULL
                THEN
                    l_merged_rows( l_mrow_ix ).ORGANIZATION_ID        := l_old_rows( orow_ix ).ORGANIZATION_ID;
                    l_merged_rows( l_mrow_ix ).ORGANIZATION_CODE      := l_old_rows( orow_ix ).ORGANIZATION_CODE;
                END IF;

                -- Non-special cased
                -- Start Generated Code
                /* Generated using:
                    SET LINESIZE 200
                    SELECT  'if l_merged_rows( l_mrow_ix ).' ||column_name || ' is null then l_merged_rows( l_mrow_ix ).' || column_name || ' := l_old_rows( orow_ix ).' || column_name || '; end if; '
                    FROM    ALL_TAB_COLUMNS
                    WHERE   TABLE_NAME = 'MTL_ITEM_REVISIONS_INTERFACE'
                    AND COLUMN_NAME NOT IN
                        ( -- special cases (for merge)
                          'INVENTORY_ITEM_ID'
                        , 'ITEM_NUMBER'
                        , 'ORGANIZATION_ID'
                        , 'ORGANIZATION_CODE'
                        , 'TRANSACTION_TYPE'
                          -- special columns
                        , 'SET_PROCESS_ID'
                        , 'PROCESS_FLAG'
                        , 'SOURCE_SYSTEM_ID'
                        , 'SOURCE_SYSTEM_REFERENCE'
                        , 'INTERFACE_TABLE_UNIQUE_ID'
                          -- who columns
                        , 'LAST_UPDATE_DATE'
                        , 'CREATION_DATE'
                        , 'CREATED_BY'
                        , 'LAST_UPDATED_BY'
                        , 'LAST_UPDATE_LOGIN'
                          -- XXX: exclude concurrent processing columns?
                        )
                    ORDER BY COLUMN_NAME ASC
                */
                if l_merged_rows( l_mrow_ix ).ATTRIBUTE1 is null then l_merged_rows( l_mrow_ix ).ATTRIBUTE1 := l_old_rows( orow_ix ).ATTRIBUTE1; end if;
                if l_merged_rows( l_mrow_ix ).ATTRIBUTE10 is null then l_merged_rows( l_mrow_ix ).ATTRIBUTE10 := l_old_rows( orow_ix ).ATTRIBUTE10; end if;
                if l_merged_rows( l_mrow_ix ).ATTRIBUTE11 is null then l_merged_rows( l_mrow_ix ).ATTRIBUTE11 := l_old_rows( orow_ix ).ATTRIBUTE11; end if;
                if l_merged_rows( l_mrow_ix ).ATTRIBUTE12 is null then l_merged_rows( l_mrow_ix ).ATTRIBUTE12 := l_old_rows( orow_ix ).ATTRIBUTE12; end if;
                if l_merged_rows( l_mrow_ix ).ATTRIBUTE13 is null then l_merged_rows( l_mrow_ix ).ATTRIBUTE13 := l_old_rows( orow_ix ).ATTRIBUTE13; end if;
                if l_merged_rows( l_mrow_ix ).ATTRIBUTE14 is null then l_merged_rows( l_mrow_ix ).ATTRIBUTE14 := l_old_rows( orow_ix ).ATTRIBUTE14; end if;
                if l_merged_rows( l_mrow_ix ).ATTRIBUTE15 is null then l_merged_rows( l_mrow_ix ).ATTRIBUTE15 := l_old_rows( orow_ix ).ATTRIBUTE15; end if;
                if l_merged_rows( l_mrow_ix ).ATTRIBUTE2 is null then l_merged_rows( l_mrow_ix ).ATTRIBUTE2 := l_old_rows( orow_ix ).ATTRIBUTE2; end if;
                if l_merged_rows( l_mrow_ix ).ATTRIBUTE3 is null then l_merged_rows( l_mrow_ix ).ATTRIBUTE3 := l_old_rows( orow_ix ).ATTRIBUTE3; end if;
                if l_merged_rows( l_mrow_ix ).ATTRIBUTE4 is null then l_merged_rows( l_mrow_ix ).ATTRIBUTE4 := l_old_rows( orow_ix ).ATTRIBUTE4; end if;
                if l_merged_rows( l_mrow_ix ).ATTRIBUTE5 is null then l_merged_rows( l_mrow_ix ).ATTRIBUTE5 := l_old_rows( orow_ix ).ATTRIBUTE5; end if;
                if l_merged_rows( l_mrow_ix ).ATTRIBUTE6 is null then l_merged_rows( l_mrow_ix ).ATTRIBUTE6 := l_old_rows( orow_ix ).ATTRIBUTE6; end if;
                if l_merged_rows( l_mrow_ix ).ATTRIBUTE7 is null then l_merged_rows( l_mrow_ix ).ATTRIBUTE7 := l_old_rows( orow_ix ).ATTRIBUTE7; end if;
                if l_merged_rows( l_mrow_ix ).ATTRIBUTE8 is null then l_merged_rows( l_mrow_ix ).ATTRIBUTE8 := l_old_rows( orow_ix ).ATTRIBUTE8; end if;
                if l_merged_rows( l_mrow_ix ).ATTRIBUTE9 is null then l_merged_rows( l_mrow_ix ).ATTRIBUTE9 := l_old_rows( orow_ix ).ATTRIBUTE9; end if;
                if l_merged_rows( l_mrow_ix ).ATTRIBUTE_CATEGORY is null then l_merged_rows( l_mrow_ix ).ATTRIBUTE_CATEGORY := l_old_rows( orow_ix ).ATTRIBUTE_CATEGORY; end if;
                if l_merged_rows( l_mrow_ix ).CHANGE_ID is null then l_merged_rows( l_mrow_ix ).CHANGE_ID := l_old_rows( orow_ix ).CHANGE_ID; end if;
                if l_merged_rows( l_mrow_ix ).CHANGE_NOTICE is null then l_merged_rows( l_mrow_ix ).CHANGE_NOTICE := l_old_rows( orow_ix ).CHANGE_NOTICE; end if;
                if l_merged_rows( l_mrow_ix ).CURRENT_PHASE_ID is null then l_merged_rows( l_mrow_ix ).CURRENT_PHASE_ID := l_old_rows( orow_ix ).CURRENT_PHASE_ID; end if;
                if l_merged_rows( l_mrow_ix ).DESCRIPTION is null then l_merged_rows( l_mrow_ix ).DESCRIPTION := l_old_rows( orow_ix ).DESCRIPTION; end if;
                if l_merged_rows( l_mrow_ix ).ECN_INITIATION_DATE is null then l_merged_rows( l_mrow_ix ).ECN_INITIATION_DATE := l_old_rows( orow_ix ).ECN_INITIATION_DATE; end if;
                if l_merged_rows( l_mrow_ix ).EFFECTIVITY_DATE is null then l_merged_rows( l_mrow_ix ).EFFECTIVITY_DATE := l_old_rows( orow_ix ).EFFECTIVITY_DATE; end if;
                if l_merged_rows( l_mrow_ix ).IMPLEMENTATION_DATE is null then l_merged_rows( l_mrow_ix ).IMPLEMENTATION_DATE := l_old_rows( orow_ix ).IMPLEMENTATION_DATE; end if;
                if l_merged_rows( l_mrow_ix ).IMPLEMENTED_SERIAL_NUMBER is null then l_merged_rows( l_mrow_ix ).IMPLEMENTED_SERIAL_NUMBER := l_old_rows( orow_ix ).IMPLEMENTED_SERIAL_NUMBER; end if;
                if l_merged_rows( l_mrow_ix ).LIFECYCLE_ID is null then l_merged_rows( l_mrow_ix ).LIFECYCLE_ID := l_old_rows( orow_ix ).LIFECYCLE_ID; end if;
                if l_merged_rows( l_mrow_ix ).PROGRAM_APPLICATION_ID is null then l_merged_rows( l_mrow_ix ).PROGRAM_APPLICATION_ID := l_old_rows( orow_ix ).PROGRAM_APPLICATION_ID; end if;
                if l_merged_rows( l_mrow_ix ).PROGRAM_ID is null then l_merged_rows( l_mrow_ix ).PROGRAM_ID := l_old_rows( orow_ix ).PROGRAM_ID; end if;
                if l_merged_rows( l_mrow_ix ).PROGRAM_UPDATE_DATE is null then l_merged_rows( l_mrow_ix ).PROGRAM_UPDATE_DATE := l_old_rows( orow_ix ).PROGRAM_UPDATE_DATE; end if;
                if l_merged_rows( l_mrow_ix ).REQUEST_ID is null then l_merged_rows( l_mrow_ix ).REQUEST_ID := l_old_rows( orow_ix ).REQUEST_ID; end if;
                if l_merged_rows( l_mrow_ix ).REVISED_ITEM_SEQUENCE_ID is null then l_merged_rows( l_mrow_ix ).REVISED_ITEM_SEQUENCE_ID := l_old_rows( orow_ix ).REVISED_ITEM_SEQUENCE_ID; end if;
                if l_merged_rows( l_mrow_ix ).REVISION is null then l_merged_rows( l_mrow_ix ).REVISION := l_old_rows( orow_ix ).REVISION; end if;
                if l_merged_rows( l_mrow_ix ).REVISION_ID is null then l_merged_rows( l_mrow_ix ).REVISION_ID := l_old_rows( orow_ix ).REVISION_ID; end if;
                if l_merged_rows( l_mrow_ix ).REVISION_LABEL is null then l_merged_rows( l_mrow_ix ).REVISION_LABEL := l_old_rows( orow_ix ).REVISION_LABEL; end if;
                if l_merged_rows( l_mrow_ix ).REVISION_REASON is null then l_merged_rows( l_mrow_ix ).REVISION_REASON := l_old_rows( orow_ix ).REVISION_REASON; end if;
                if l_merged_rows( l_mrow_ix ).TRANSACTION_ID is null then l_merged_rows( l_mrow_ix ).TRANSACTION_ID := l_old_rows( orow_ix ).TRANSACTION_ID; end if;
                -- End Generated Code

            END LOOP; -- loop over old rows

            /*
            -- XXX: In case only null/invalid transaction types encountered, set transaction type to SYNC ?.
            IF l_merged_rows( l_mrow_ix ).TRANSACTION_TYPE IS NULL THEN
                l_merged_rows( l_mrow_ix ).TRANSACTION_TYPE := G_TRANS_TYPE_SYNC;
            END IF;
            */
            IF l_merged_rows IS NOT NULL THEN
                -- delete
                Debug_Conc_Log( l_proc_log_prefix || 'Deleting ' || l_old_rowids.COUNT || ' old rows ...' );
                FORALL rid_ix IN INDICES OF l_old_rowids
                    DELETE FROM MTL_ITEM_REVISIONS_INTERFACE
                        WHERE ROWID = l_old_rowids( rid_ix );
                -- insert
                Debug_Conc_Log( l_proc_log_prefix || 'Inserting ' || l_merged_rows.COUNT || ' merged rows ...' );
                FORALL row_index IN INDICES OF l_merged_rows
                    INSERT INTO MTL_ITEM_REVISIONS_INTERFACE
                        VALUES l_merged_rows( row_index );
            END IF;
        END IF; -- ENDS IF l_old_rows.count <> 0
        IF p_commit = FND_API.G_TRUE THEN
            Debug_Conc_Log( l_proc_log_prefix || 'Committing' );
            COMMIT;
        END IF;
        Debug_Conc_Log( l_proc_log_prefix || 'Exiting' );
    END merge_revs;

    -- Merging Item Associations.
    PROCEDURE Merge_Associations  ( p_batch_id       IN NUMBER
                                  , p_is_pdh_batch   IN FLAG      DEFAULT NULL
                                  , p_commit         IN FLAG      DEFAULT FND_API.G_FALSE
                                  )
    IS

    CURSOR pdh_candidate_assocs_rows_cur IS
        SELECT *
        FROM
          (
            SELECT
              ROWID rid,
              Count(*) OVER ( PARTITION BY ITEM_NUMBER,
                                          PK1_VALUE,
                                          PK2_VALUE,
                                          PK3_VALUE,
                                          PK4_VALUE,
                                          PK5_VALUE,
                                          BUNDLE_ID,
                                          DATA_LEVEL_ID,
                                          ORGANIZATION_ID )
              CNT,
              Rank()  OVER ( ORDER BY ITEM_NUMBER,
                                      PK1_VALUE,
                                      PK2_VALUE,
                                      PK3_VALUE,
                                      PK4_VALUE,
                                      PK5_VALUE,
                                      BUNDLE_ID,
                                      DATA_LEVEL_ID,
                                      ORGANIZATION_ID )
              RNK,
              eiai.*
            FROM EGO_ITEM_ASSOCIATIONS_INTF eiai
            WHERE BATCH_ID = p_batch_id
            AND PROCESS_FLAG = 1
          )
        WHERE CNT > 1
        ORDER BY rnk, last_update_date DESC;

    CURSOR ss_candidate_assocs_rows_cur IS
        SELECT *
        FROM
          (
            SELECT
              ROWID rid,
              Count(*) OVER ( PARTITION BY SOURCE_SYSTEM_ID,
                                          SOURCE_SYSTEM_REFERENCE,
                                          PK1_VALUE,
                                          PK2_VALUE,
                                          PK3_VALUE,
                                          PK4_VALUE,
                                          PK5_VALUE,
                                          BUNDLE_ID,
                                          DATA_LEVEL_ID,
                                          ORGANIZATION_ID )
              CNT,
              Rank()  OVER ( ORDER BY SOURCE_SYSTEM_ID,
                                      SOURCE_SYSTEM_REFERENCE,
                                      PK1_VALUE,
                                      PK2_VALUE,
                                      PK3_VALUE,
                                      PK4_VALUE,
                                      PK5_VALUE,
                                      BUNDLE_ID,
                                      DATA_LEVEL_ID,
                                      ORGANIZATION_ID )
              RNK,
              eiai.*
            FROM EGO_ITEM_ASSOCIATIONS_INTF eiai
            WHERE BATCH_ID = p_batch_id
            AND PROCESS_FLAG = 0
          )
        WHERE CNT > 1
        ORDER BY rnk, last_update_date DESC;

    TYPE Assocs_Rows_With_RowId    IS TABLE OF ss_candidate_assocs_rows_cur%ROWTYPE;

    l_current_rank_handled          NUMBER;
    l_previous_rank_handled         NUMBER;
    l_new_row_index                 NUMBER := 0;
    l_old_row_ids                   UROWID_TABLE;
    l_current_merged_tran_type      VARCHAR2(10);

    l_new_row      IAssocs_Row;
    l_new_rows     IAssocs_Rows;
    l_old_rows     Assocs_Rows_With_RowId;

    BEGIN
      Debug_Conc_Log( 'Calling Merge_Associations ');
      l_current_rank_handled := 0;
      l_previous_rank_handled := 0;

      IF p_is_pdh_batch = FND_API.G_TRUE THEN
        -- 'PDH Batch'
        Debug_Conc_Log( 'Getting candidate rows for merging for PDH Batch ');
        OPEN pdh_candidate_assocs_rows_cur;
        FETCH pdh_candidate_assocs_rows_cur BULK COLLECT INTO l_old_rows;
        CLOSE pdh_candidate_assocs_rows_cur;
      ELSE
        -- 'SS Batch'
        Debug_Conc_Log( 'Getting candidate rows for merging for Source System Batch ');
        OPEN ss_candidate_assocs_rows_cur;
        FETCH ss_candidate_assocs_rows_cur BULK COLLECT INTO l_old_rows;
        CLOSE ss_candidate_assocs_rows_cur;
      END IF;

      Debug_Conc_Log( 'Merging '|| l_old_rows.COUNT || ' rows in associations table' );

      IF l_old_rows.COUNT < 1 THEN
        RETURN;
      END IF;

      l_old_row_ids := UROWID_TABLE( );
      l_old_row_ids.EXTEND( l_old_rows.COUNT );

      FOR l_index IN l_old_rows.FIRST .. l_old_rows.LAST
      LOOP
        l_old_row_ids( l_index ) := l_old_rows( l_index ).RID;
        l_current_rank_handled := l_old_rows( l_index ).RNK;
        IF l_current_rank_handled <> l_previous_rank_handled THEN
          l_new_row_index                := l_new_row_index + 1 ;
          l_new_rows( l_new_row_index )  := l_new_row;
          l_new_rows( l_new_row_index ).BATCH_ID                  := l_old_rows( l_index ).BATCH_ID;
          l_new_rows( l_new_row_index ).ORGANIZATION_ID           := l_old_rows( l_index ).ORGANIZATION_ID;
          l_new_rows( l_new_row_index ).PK1_VALUE                 := l_old_rows( l_index ).PK1_VALUE;
          l_new_rows( l_new_row_index ).PK2_VALUE                 := l_old_rows( l_index ).PK2_VALUE;
          l_new_rows( l_new_row_index ).PK3_VALUE                 := l_old_rows( l_index ).PK3_VALUE;
          l_new_rows( l_new_row_index ).PK4_VALUE                 := l_old_rows( l_index ).PK4_VALUE;
          l_new_rows( l_new_row_index ).PK5_VALUE                 := l_old_rows( l_index ).PK5_VALUE;
          l_new_rows( l_new_row_index ).DATA_LEVEL_ID             := l_old_rows( l_index ).DATA_LEVEL_ID;
          l_new_rows( l_new_row_index ).ORGANIZATION_CODE         := l_old_rows( l_index ).ORGANIZATION_CODE;
          l_new_rows( l_new_row_index ).PROCESS_FLAG              := l_old_rows( l_index ).PROCESS_FLAG;
          l_new_rows( l_new_row_index ).TRANSACTION_ID            := l_old_rows( l_index ).TRANSACTION_ID;
          l_new_rows( l_new_row_index ).ASSOCIATION_ID            := l_old_rows( l_index ).ASSOCIATION_ID;
          l_new_rows( l_new_row_index ).REQUEST_ID                := l_old_rows( l_index ).REQUEST_ID;
          l_new_rows( l_new_row_index ).PROGRAM_APPLICATION_ID    := l_old_rows( l_index ).PROGRAM_APPLICATION_ID;
          l_new_rows( l_new_row_index ).PROGRAM_ID                := l_old_rows( l_index ).PROGRAM_ID;
          l_new_rows( l_new_row_index ).PROGRAM_UPDATE_DATE       := l_old_rows( l_index ).PROGRAM_UPDATE_DATE;
          l_new_rows( l_new_row_index ).SUPPLIER_NAME             := l_old_rows( l_index ).SUPPLIER_NAME;
          l_new_rows( l_new_row_index ).SUPPLIER_NUMBER           := l_old_rows( l_index ).SUPPLIER_NUMBER;
          l_new_rows( l_new_row_index ).SUPPLIER_SITE_NAME        := l_old_rows( l_index ).SUPPLIER_SITE_NAME;
          l_new_rows( l_new_row_index ).DATA_LEVEL_NAME           := l_old_rows( l_index ).DATA_LEVEL_NAME;
          l_new_rows( l_new_row_index ).STYLE_ITEM_FLAG           := l_old_rows( l_index ).STYLE_ITEM_FLAG;
          l_new_rows( l_new_row_index ).STYLE_ITEM_ID             := l_old_rows( l_index ).STYLE_ITEM_ID;
          l_new_rows( l_new_row_index ).BUNDLE_ID                 := l_old_rows( l_index ).BUNDLE_ID;
          l_new_rows( l_new_row_index ).SOURCE_SYSTEM_ID          := l_old_rows( l_index ).SOURCE_SYSTEM_ID;
          l_new_rows( l_new_row_index ).SOURCE_SYSTEM_REFERENCE   := l_old_rows( l_index ).SOURCE_SYSTEM_REFERENCE;
          l_new_rows( l_new_row_index ).ITEM_NUMBER               := l_old_rows( l_index ).ITEM_NUMBER;
          l_new_rows( l_new_row_index ).CREATED_BY                := l_old_rows( l_index ).CREATED_BY;
          l_new_rows( l_new_row_index ).CREATION_DATE             := l_old_rows( l_index ).CREATION_DATE;
          l_new_rows( l_new_row_index ).LAST_UPDATED_BY           := l_old_rows( l_index ).LAST_UPDATED_BY;
          l_new_rows( l_new_row_index ).LAST_UPDATE_DATE          := l_old_rows( l_index ).LAST_UPDATE_DATE;
          l_new_rows( l_new_row_index ).LAST_UPDATE_LOGIN         := l_old_rows( l_index ).LAST_UPDATE_LOGIN;
          l_current_merged_tran_type                              := l_old_rows( l_index ).TRANSACTION_TYPE;
        END IF;
        IF l_new_rows( l_new_row_index ).INVENTORY_ITEM_ID IS NULL THEN
          l_new_rows( l_new_row_index ).INVENTORY_ITEM_ID := l_old_rows( l_index ).INVENTORY_ITEM_ID;
        END IF;
        IF l_new_rows( l_new_row_index ).PRIMARY_FLAG IS NULL
          AND l_new_rows( l_new_row_index ).STATUS_CODE <> 2
          AND l_old_rows( l_index ).PRIMARY_FLAG <> 'Y' THEN
          l_new_rows( l_new_row_index ).PRIMARY_FLAG := l_old_rows( l_index ).PRIMARY_FLAG;
        END IF;
        IF l_new_rows( l_new_row_index ).STATUS_CODE IS NULL
          AND l_new_rows( l_new_row_index ).PRIMARY_FLAG <> 'Y'
          AND l_old_rows( l_index ).STATUS_CODE <> '2' THEN
          l_new_rows( l_new_row_index ).STATUS_CODE := l_old_rows( l_index ).STATUS_CODE;
        END IF;
        IF l_new_rows( l_new_row_index ).TRANSACTION_TYPE IS NULL
          OR l_new_rows( l_new_row_index ).TRANSACTION_TYPE <> l_current_merged_tran_type THEN
          l_new_rows( l_new_row_index ).TRANSACTION_TYPE :=
                          CASE
                              WHEN l_new_rows( l_new_row_index ).TRANSACTION_TYPE = G_TRANS_TYPE_CREATE
                                  OR l_current_merged_tran_type = G_TRANS_TYPE_CREATE
                                THEN G_TRANS_TYPE_CREATE
                              WHEN l_new_rows( l_new_row_index ).TRANSACTION_TYPE = G_TRANS_TYPE_SYNC
                                  OR l_current_merged_tran_type = G_TRANS_TYPE_SYNC
                                THEN G_TRANS_TYPE_SYNC
                              WHEN l_new_rows( l_new_row_index ).TRANSACTION_TYPE = G_TRANS_TYPE_UPDATE
                                  OR l_current_merged_tran_type = G_TRANS_TYPE_UPDATE
                                THEN G_TRANS_TYPE_UPDATE
                              ELSE NULL  -- Transaction type is not valid.
                            END;
          l_current_merged_tran_type := l_new_rows( l_new_row_index ).TRANSACTION_TYPE;
        END IF;
        l_previous_rank_handled := l_old_rows( l_index ).RNK;
      END LOOP;

      -- Updating default values for primary_flag and status_code
      -- primary_flag null is defaulted with  'N'
      -- status_code null is defaulted with 1
      UPDATE EGO_ITEM_ASSOCIATIONS_INTF
      SET PRIMARY_FLAG = 'N'
      WHERE PRIMARY_FLAG IS NULL
        AND BATCH_ID = p_batch_id
	AND TRANSACTION_TYPE = 'CREATE'; --Modified for bug 11670735

      UPDATE EGO_ITEM_ASSOCIATIONS_INTF
      SET STATUS_CODE = 'N'
      WHERE STATUS_CODE IS NULL
        AND BATCH_ID = p_batch_id
	AND TRANSACTION_TYPE = 'CREATE'; --Modified for bug 11670735

      IF l_new_rows IS NOT NULL THEN
        -- Delete
        FORALL rid_ix IN INDICES OF l_old_row_ids
            DELETE FROM EGO_ITEM_ASSOCIATIONS_INTF
                WHERE ROWID = l_old_row_ids( rid_ix );
        -- Insert
        FORALL row_index IN INDICES OF l_new_rows
            INSERT INTO EGO_ITEM_ASSOCIATIONS_INTF
                VALUES l_new_rows( row_index );
      END IF;
      Debug_Conc_Log( 'End of Call to Merge_Associations ');

    END merge_associations;


    PROCEDURE merge_batch   ( p_batch_id       IN NUMBER
                            , p_is_pdh_batch   IN FLAG      DEFAULT NULL
                            , p_ss_id          IN NUMBER    DEFAULT NULL
                            , p_master_org_id  IN NUMBER    DEFAULT NULL
                            , p_commit         IN FLAG      DEFAULT FND_API.G_FALSE
                            )
    IS
        l_org_id            NUMBER  := p_master_org_id;
        l_pdh_batch_flag    FLAG    := p_is_pdh_batch;
        l_ss_id             NUMBER  := p_ss_id;
    BEGIN
        Debug_Conc_Log( 'merge_batch: Starting for batch_id=' || TO_CHAR(p_batch_id) );
        IF  l_pdh_batch_flag IS NULL OR l_org_id IS NULL OR l_ss_id IS NULL THEN
            merge_params_from_batch_header( p_batch_id      => p_batch_id
                                          , x_is_pdh_batch  => l_pdh_batch_flag
                                          , x_ss_id         => l_ss_id
                                          , x_master_org_id => l_org_id
                                          );
        END IF;

        Debug_Conc_Log( 'merge_batch: Merging batch items' );
        MERGE_ITEMS(  p_batch_id        => p_batch_id
                   ,  p_master_org_id   => l_org_id
                   ,  p_is_pdh_batch    => l_pdh_batch_flag
                   ,  p_ss_id           => l_ss_id
                   ,  p_commit          => FND_API.G_FALSE
                   );
        Debug_Conc_Log( 'merge_batch: Merging batch revisions' );
        MERGE_REVS (  p_batch_id        => p_batch_id
                   ,  p_master_org_id   => l_org_id
                   ,  p_is_pdh_batch    => l_pdh_batch_flag
                   ,  p_ss_id           => l_ss_id
                   ,  p_commit          => FND_API.G_FALSE
                   );
        Debug_Conc_Log( 'merge_batch: Merging Associations' );
        merge_associations( p_batch_id       => p_batch_id
                          , p_is_pdh_batch   => l_pdh_batch_flag
                          , p_commit         => FND_API.G_FALSE
                          );

        Debug_Conc_Log( 'merge_batch: Merging batch extended attributes' );
        MERGE_ATTRS(  p_batch_id        => p_batch_id
                   ,  p_master_org_id   => l_org_id
                   ,  p_is_pdh_batch    => l_pdh_batch_flag
                   ,  p_ss_id           => l_ss_id
                   ,  p_commit          => FND_API.G_FALSE
                   );
        IF p_commit = FND_API.G_TRUE   THEN
            Debug_Conc_Log( 'merge_batch: Committing' );
            COMMIT;
        END IF;
        Debug_Conc_Log( 'merge_batch: Exiting' );
    END merge_batch;

    PROCEDURE merge_attrs   ( p_batch_id       IN NUMBER
                            , p_is_pdh_batch   IN FLAG      DEFAULT NULL
                            , p_ss_id          IN NUMBER    DEFAULT NULL
                            , p_master_org_id  IN NUMBER    DEFAULT NULL
                            , p_commit         IN FLAG      DEFAULT FND_API.G_FALSE
                            )
    IS
        l_org_id            NUMBER  := p_master_org_id;
        l_pdh_batch_flag    FLAG    := p_is_pdh_batch;
        l_ss_id             NUMBER  := p_ss_id;
    BEGIN
        Debug_Conc_Log( 'Starting merge_attrs for batch_id:' || to_char( p_batch_id ) );
        IF  l_pdh_batch_flag IS NULL OR l_org_id IS NULL OR l_ss_id IS NULL THEN
            merge_params_from_batch_header( p_batch_id      => p_batch_id
                                          , x_is_pdh_batch  => l_pdh_batch_flag
                                          , x_ss_id         => l_ss_id
                                          , x_master_org_id => l_org_id
                                          );
        END IF;

        Debug_Conc_Log( 'merge_attrs: merging item-level extended attributes' );
        MERGE_ITEM_ATTRS   (  p_batch_id        => p_batch_id
                           ,  p_master_org_id   => l_org_id
                           ,  p_is_pdh_batch    => l_pdh_batch_flag
                           ,  p_ss_id           => l_ss_id
                           ,  p_commit          => FND_API.G_FALSE
                           );
        Debug_Conc_Log( 'merge_attrs: merging revision-level extended attributes' );
        MERGE_REV_ATTRS(  p_batch_id        => p_batch_id
                       ,  p_master_org_id   => l_org_id
                       ,  p_is_pdh_batch    => l_pdh_batch_flag
                       ,  p_ss_id           => l_ss_id
                       ,  p_commit          => FND_API.G_FALSE
                       );
        IF p_commit = FND_API.G_TRUE   THEN
            Debug_Conc_Log( 'merge_attrs: Committing' );
            COMMIT;
        END IF;
        Debug_Conc_Log( 'merge_attrs: Exiting' );
    END merge_attrs;

    --=================================================================================================================--
    --------------------------------------- End of Merging Section ----------------------------------------------------
    --=================================================================================================================--

    --=================================================================================================================--
    --------------------------------- Start of Merging Section for Import -----------------------------------------------
    --=================================================================================================================--
    /*
     * All methods in this section does the following - For all the ready records in batch i.e. with process status = 1,
     *   if more than one record found for same primary keys (for example ITEM_NUMBER, ORGANIZATION_ID, REVISION for
     *   revisions interface table), then merge all the data to all the rows having same PKs. Then mark all other rows
     *   with process status = 111 and keep only one row with process status = 1. This way only one record will get
     *   processed and all the data from all the records will get processed. Later, after completion of all imports,
     *   the rows with process status = 111 will get converted to success or failure depending on the status of row
     *   that got processed.
     */

    -- Merges item and org assignments
    PROCEDURE Merge_Items_For_Import( p_batch_id       IN NUMBER
                                    , p_master_org_id  IN NUMBER
                                    )
    IS
        /*
         * This cursor is never executed.
         * It's only used for type definition.
         */
        CURSOR c_target_rec_type IS
            SELECT ROWID rid
                 , 0     cnt
                 , 0     rnk
                 , msii.*
            FROM MTL_SYSTEM_ITEMS_INTERFACE msii;

        TYPE MSII_ROWS      IS TABLE OF MSII_ROW INDEX BY BINARY_INTEGER;
        TYPE MSII_CURSOR    IS REF CURSOR;
        c_target_rows       MSII_CURSOR;
        old_row             c_target_rec_type%ROWTYPE;

        l_merged_rows   MSII_ROWS;
        l_new_rows      MSII_ROWS;
        l_merged_row    MSII_ROW;
        l_old_rowids    UROWID_TABLE;

        l_candidate_trans MTL_SYSTEM_ITEMS_INTERFACE.TRANSACTION_TYPE%TYPE;

        l_cur_rank      PLS_INTEGER := 0; -- because rank() starts at 1
        l_mrow_ix       PLS_INTEGER := 0;
        l_new_row_idx   PLS_INTEGER := 0;

        l_org_id        MTL_SYSTEM_ITEMS_INTERFACE.ORGANIZATION_ID%TYPE := p_master_org_id;
        l_proc_log_prefix     CONSTANT VARCHAR2( 30 ) := 'Merge_Items_For_Import - ';
    BEGIN
        Debug_Conc_Log( l_proc_log_prefix || 'Entering' );
        Debug_Conc_Log( l_proc_log_prefix || 'Batch ID: ' || p_batch_id );
        -- making sure that item_number always has a value for ready records
        UPDATE MTL_SYSTEM_ITEMS_INTERFACE MSII
        SET ITEM_NUMBER = (SELECT CONCATENATED_SEGMENTS
                           FROM MTL_SYSTEM_ITEMS_KFV
                           WHERE INVENTORY_ITEM_ID = MSII.INVENTORY_ITEM_ID
                             AND ORGANIZATION_ID = MSII.ORGANIZATION_ID)
        WHERE SET_PROCESS_ID = p_batch_id
          AND PROCESS_FLAG = 1
          AND INVENTORY_ITEM_ID IS NOT NULL
          AND ITEM_NUMBER IS NULL;

        OPEN c_target_rows FOR
          SELECT *
          FROM
            (SELECT
              ROWID rid,
              COUNT( * ) OVER ( PARTITION BY ITEM_NUMBER, ORGANIZATION_ID) cnt,
              RANK() OVER ( ORDER BY ITEM_NUMBER, ORGANIZATION_ID) rnk,
              msii.*
            FROM MTL_SYSTEM_ITEMS_INTERFACE msii
            WHERE PROCESS_FLAG   = 1
              AND SET_PROCESS_ID = p_batch_id
              AND ITEM_NUMBER IS NOT NULL
              AND ORGANIZATION_ID IS NOT NULL
              AND EXISTS
                  (SELECT NULL
                   FROM MTL_PARAMETERS mp
                   WHERE mp.ORGANIZATION_ID        = msii.ORGANIZATION_ID
                     AND mp.MASTER_ORGANIZATION_ID = l_org_id
                  )
            ) sub
          WHERE sub.cnt > 1
          ORDER BY rnk, last_update_date DESC NULLS LAST, interface_table_unique_id DESC NULLS LAST;

        l_old_rowids := UROWID_TABLE( );
        l_new_row_idx := 0;
        LOOP
            FETCH c_target_rows INTO old_row;
            IF c_target_rows%NOTFOUND AND l_new_row_idx > 0 THEN
                FOR i IN 1..l_new_row_idx LOOP
                    Debug_Conc_Log( l_proc_log_prefix || '  No More records found for processing.');
                    Debug_Conc_Log( l_proc_log_prefix || '  Creating merged record for SSR, SS-ID = ' ||
                                                         l_new_rows( i ).SOURCE_SYSTEM_REFERENCE || ',' ||
                                                         l_new_rows( i ).SOURCE_SYSTEM_ID);
                    l_mrow_ix := l_mrow_ix + 1;
                    l_merged_rows( l_mrow_ix )                              := l_merged_row;
                    l_merged_rows( l_mrow_ix ).SET_PROCESS_ID               := l_new_rows( i ).SET_PROCESS_ID;
                    l_merged_rows( l_mrow_ix ).PROCESS_FLAG                 := l_new_rows( i ).PROCESS_FLAG;
                    l_merged_rows( l_mrow_ix ).SOURCE_SYSTEM_ID             := l_new_rows( i ).SOURCE_SYSTEM_ID;
                    l_merged_rows( l_mrow_ix ).SOURCE_SYSTEM_REFERENCE      := l_new_rows( i ).SOURCE_SYSTEM_REFERENCE;
                    l_merged_rows( l_mrow_ix ).SOURCE_SYSTEM_REFERENCE_DESC := l_new_rows( i ).SOURCE_SYSTEM_REFERENCE_DESC;
                    l_merged_rows( l_mrow_ix ).CONFIRM_STATUS               := l_new_rows( i ).CONFIRM_STATUS;
                    l_merged_rows( l_mrow_ix ).CREATED_BY                   := l_new_rows( i ).CREATED_BY;
                    l_merged_rows( l_mrow_ix ).LAST_UPDATED_BY              := l_new_rows( i ).LAST_UPDATED_BY;
                    l_merged_rows( l_mrow_ix ).REQUEST_ID                   := FND_GLOBAL.CONC_REQUEST_ID;
                    l_merged_rows( l_mrow_ix ).PROGRAM_APPLICATION_ID       := FND_GLOBAL.PROG_APPL_ID;
                    l_merged_rows( l_mrow_ix ).PROGRAM_ID                   := FND_GLOBAL.CONC_PROGRAM_ID;
                    l_merged_rows( l_mrow_ix ).PROGRAM_UPDATE_DATE          := SYSDATE;
                END LOOP; --FOR i IN 1..l_new_row_idx LOOP
            END IF; --IF l_new_row_idx > 0 THEN
            EXIT WHEN c_target_rows%NOTFOUND;

            l_old_rowids.EXTEND;
            l_old_rowids( l_old_rowids.LAST ) := old_row.RID;

            IF( old_row.RNK <> l_cur_rank ) THEN
                -- check if already merged rows exists, then insert them into l_merged_rows
                -- when a final merged record is ready for one item-org then for each source system reference
                -- we will insert a merged record i.e. ssr, msii.merged_record
                IF l_new_row_idx > 0 THEN
                    FOR i IN 1..l_new_row_idx LOOP
                        Debug_Conc_Log( l_proc_log_prefix || '  Creating merged record for SSR, SS-ID = ' ||
                                                             l_new_rows( i ).SOURCE_SYSTEM_REFERENCE || ', ' ||
                                                             l_new_rows( i ).SOURCE_SYSTEM_ID);
                        l_mrow_ix := l_mrow_ix + 1;
                        l_merged_rows( l_mrow_ix )                              := l_merged_row;
                        l_merged_rows( l_mrow_ix ).SET_PROCESS_ID               := l_new_rows( i ).SET_PROCESS_ID;
                        l_merged_rows( l_mrow_ix ).PROCESS_FLAG                 := l_new_rows( i ).PROCESS_FLAG;
                        l_merged_rows( l_mrow_ix ).SOURCE_SYSTEM_ID             := l_new_rows( i ).SOURCE_SYSTEM_ID;
                        l_merged_rows( l_mrow_ix ).SOURCE_SYSTEM_REFERENCE      := l_new_rows( i ).SOURCE_SYSTEM_REFERENCE;
                        l_merged_rows( l_mrow_ix ).SOURCE_SYSTEM_REFERENCE_DESC := l_new_rows( i ).SOURCE_SYSTEM_REFERENCE_DESC;
                        l_merged_rows( l_mrow_ix ).CONFIRM_STATUS               := l_new_rows( i ).CONFIRM_STATUS;
                        l_merged_rows( l_mrow_ix ).CREATED_BY                   := l_new_rows( i ).CREATED_BY;
                        l_merged_rows( l_mrow_ix ).LAST_UPDATED_BY              := l_new_rows( i ).LAST_UPDATED_BY;
                        l_merged_rows( l_mrow_ix ).REQUEST_ID                   := FND_GLOBAL.CONC_REQUEST_ID;
                        l_merged_rows( l_mrow_ix ).PROGRAM_APPLICATION_ID       := FND_GLOBAL.PROG_APPL_ID;
                        l_merged_rows( l_mrow_ix ).PROGRAM_ID                   := FND_GLOBAL.CONC_PROGRAM_ID;
                        l_merged_rows( l_mrow_ix ).PROGRAM_UPDATE_DATE          := SYSDATE;
                    END LOOP; --FOR i IN 1..l_new_row_idx LOOP
                END IF; --IF l_new_row_idx > 0 THEN
                l_cur_rank := old_row.RNK;
                Debug_Conc_Log( l_proc_log_prefix || '  Starting new merged row; rank = '|| l_cur_rank );
                Debug_Conc_Log( l_proc_log_prefix || '    Item, Org-ID, Item-ID = ' ||
                                                     old_row.ITEM_NUMBER || ',' ||
                                                     old_row.ORGANIZATION_ID || ', ' ||
                                                     old_row.INVENTORY_ITEM_ID);
                l_new_rows.DELETE;
                l_new_row_idx := 1;
                l_new_rows( l_new_row_idx ).PROCESS_FLAG              := old_row.PROCESS_FLAG;
                -- initializing l_merged_row . This row will contain the current merged row for an item
                l_merged_row := NULL;
                l_merged_row.SET_PROCESS_ID            := p_batch_id;
                l_merged_row.PROCESS_FLAG              := old_row.PROCESS_FLAG;
            ELSE
                Debug_Conc_Log( l_proc_log_prefix || '  Merging another record into current merged row; rank = '|| l_cur_rank );
                Debug_Conc_Log( l_proc_log_prefix || '    Item, Org-ID, Item-ID = ' ||
                                                     old_row.ITEM_NUMBER || ', ' ||
                                                     old_row.ORGANIZATION_ID || ', ' ||
                                                     old_row.INVENTORY_ITEM_ID);
                l_new_row_idx := l_new_row_idx + 1;
                l_new_rows( l_new_row_idx ).PROCESS_FLAG              := 111;
            END IF;

            l_new_rows( l_new_row_idx ).SET_PROCESS_ID               := p_batch_id;
            l_new_rows( l_new_row_idx ).SOURCE_SYSTEM_ID             := old_row.SOURCE_SYSTEM_ID;
            l_new_rows( l_new_row_idx ).SOURCE_SYSTEM_REFERENCE      := old_row.SOURCE_SYSTEM_REFERENCE;
            l_new_rows( l_new_row_idx ).SOURCE_SYSTEM_REFERENCE_DESC := old_row.SOURCE_SYSTEM_REFERENCE_DESC;
            l_new_rows( l_new_row_idx ).CONFIRM_STATUS               := old_row.CONFIRM_STATUS;
            l_new_rows( l_new_row_idx ).CREATED_BY                   := old_row.CREATED_BY;
            l_new_rows( l_new_row_idx ).LAST_UPDATED_BY              := old_row.LAST_UPDATED_BY;

            -- Special Cases:
            -- Transaction type
            l_candidate_trans := UPPER( old_row.TRANSACTION_TYPE );

            IF      l_merged_row.TRANSACTION_TYPE IS NULL
                OR  l_merged_row.TRANSACTION_TYPE <> l_candidate_trans     -- <> filters out nulls
            THEN
                -- CREATE > SYNC > UPDATE : order of case expression matters
                l_merged_row.TRANSACTION_TYPE :=
                    CASE
                        WHEN l_merged_row.TRANSACTION_TYPE = G_TRANS_TYPE_CREATE
                          OR l_candidate_trans = G_TRANS_TYPE_CREATE                            THEN G_TRANS_TYPE_CREATE
                        WHEN l_merged_row.TRANSACTION_TYPE = G_TRANS_TYPE_SYNC
                          OR l_candidate_trans = G_TRANS_TYPE_SYNC                              THEN G_TRANS_TYPE_SYNC
                        WHEN l_merged_row.TRANSACTION_TYPE = G_TRANS_TYPE_UPDATE
                          OR l_candidate_trans = G_TRANS_TYPE_UPDATE                            THEN G_TRANS_TYPE_UPDATE
                        ELSE NULL -- INVALID transaction types encountered so far ...
                    END;
            END IF;

            -- The following columns need to be treated as atomic groups
            -- 1. Item Identifier
            IF      l_merged_row.INVENTORY_ITEM_ID  IS NULL
                AND l_merged_row.ITEM_NUMBER        IS NULL
                AND l_merged_row.SEGMENT1           IS NULL
                AND l_merged_row.SEGMENT2           IS NULL
                AND l_merged_row.SEGMENT3           IS NULL
                AND l_merged_row.SEGMENT4           IS NULL
                AND l_merged_row.SEGMENT5           IS NULL
                AND l_merged_row.SEGMENT6           IS NULL
                AND l_merged_row.SEGMENT7           IS NULL
                AND l_merged_row.SEGMENT8           IS NULL
                AND l_merged_row.SEGMENT9           IS NULL
                AND l_merged_row.SEGMENT10          IS NULL
                AND l_merged_row.SEGMENT11          IS NULL
                AND l_merged_row.SEGMENT12          IS NULL
                AND l_merged_row.SEGMENT13          IS NULL
                AND l_merged_row.SEGMENT14          IS NULL
                AND l_merged_row.SEGMENT15          IS NULL
                AND l_merged_row.SEGMENT16          IS NULL
                AND l_merged_row.SEGMENT17          IS NULL
                AND l_merged_row.SEGMENT18          IS NULL
                AND l_merged_row.SEGMENT19          IS NULL
                AND l_merged_row.SEGMENT20          IS NULL
            THEN
                l_merged_row.INVENTORY_ITEM_ID  := old_row.INVENTORY_ITEM_ID;
                l_merged_row.ITEM_NUMBER        := old_row.ITEM_NUMBER;
                l_merged_row.SEGMENT1           := old_row.SEGMENT1;
                l_merged_row.SEGMENT2           := old_row.SEGMENT2;
                l_merged_row.SEGMENT3           := old_row.SEGMENT3;
                l_merged_row.SEGMENT4           := old_row.SEGMENT4;
                l_merged_row.SEGMENT5           := old_row.SEGMENT5;
                l_merged_row.SEGMENT6           := old_row.SEGMENT6;
                l_merged_row.SEGMENT7           := old_row.SEGMENT7;
                l_merged_row.SEGMENT8           := old_row.SEGMENT8;
                l_merged_row.SEGMENT9           := old_row.SEGMENT9;
                l_merged_row.SEGMENT10          := old_row.SEGMENT10;
                l_merged_row.SEGMENT11          := old_row.SEGMENT11;
                l_merged_row.SEGMENT12          := old_row.SEGMENT12;
                l_merged_row.SEGMENT13          := old_row.SEGMENT13;
                l_merged_row.SEGMENT14          := old_row.SEGMENT14;
                l_merged_row.SEGMENT15          := old_row.SEGMENT15;
                l_merged_row.SEGMENT16          := old_row.SEGMENT16;
                l_merged_row.SEGMENT17          := old_row.SEGMENT17;
                l_merged_row.SEGMENT18          := old_row.SEGMENT18;
                l_merged_row.SEGMENT19          := old_row.SEGMENT19;
                l_merged_row.SEGMENT20          := old_row.SEGMENT20;
            END IF;

            -- 2. Template Identifier
            IF      l_merged_row.TEMPLATE_ID        IS NULL
                AND l_merged_row.TEMPLATE_NAME      IS NULL
            THEN
                l_merged_row.TEMPLATE_ID    := old_row.TEMPLATE_ID ;
                l_merged_row.TEMPLATE_NAME  := old_row.TEMPLATE_NAME ;
            END IF;

            -- 3. Item Catalog Category
            IF      l_merged_row.ITEM_CATALOG_GROUP_ID      IS NULL
                AND l_merged_row.ITEM_CATALOG_GROUP_NAME    IS NULL
            THEN
                l_merged_row.ITEM_CATALOG_GROUP_ID      := old_row.ITEM_CATALOG_GROUP_ID ;
                l_merged_row.ITEM_CATALOG_GROUP_NAME    := old_row.ITEM_CATALOG_GROUP_NAME ;
            END IF;

            -- 4. Primary UOM
            IF      l_merged_row.PRIMARY_UOM_CODE           IS NULL
                AND l_merged_row.PRIMARY_UNIT_OF_MEASURE    IS NULL
            THEN
                l_merged_row.PRIMARY_UOM_CODE           := old_row.PRIMARY_UOM_CODE ;
                l_merged_row.PRIMARY_UNIT_OF_MEASURE    := old_row.PRIMARY_UNIT_OF_MEASURE ;
            END IF;

            -- 5. Organization
            IF      l_merged_row.ORGANIZATION_ID    IS NULL
                AND l_merged_row.ORGANIZATION_CODE  IS NULL
            THEN
                l_merged_row.ORGANIZATION_ID        := old_row.ORGANIZATION_ID ;
                l_merged_row.ORGANIZATION_CODE      := old_row.ORGANIZATION_CODE ;
            END IF;

            -- 6. Copy Organization
            IF      l_merged_row.COPY_ORGANIZATION_ID    IS NULL
                AND l_merged_row.COPY_ORGANIZATION_CODE  IS NULL
            THEN
                l_merged_row.COPY_ORGANIZATION_ID        := old_row.COPY_ORGANIZATION_ID ;
                l_merged_row.COPY_ORGANIZATION_CODE      := old_row.COPY_ORGANIZATION_CODE ;
            END IF;

            if l_merged_row.ACCEPTABLE_EARLY_DAYS is null then l_merged_row.ACCEPTABLE_EARLY_DAYS := old_row.ACCEPTABLE_EARLY_DAYS; end if;
            if l_merged_row.ACCEPTABLE_RATE_DECREASE is null then l_merged_row.ACCEPTABLE_RATE_DECREASE := old_row.ACCEPTABLE_RATE_DECREASE; end if;
            if l_merged_row.ACCEPTABLE_RATE_INCREASE is null then l_merged_row.ACCEPTABLE_RATE_INCREASE := old_row.ACCEPTABLE_RATE_INCREASE; end if;
            if l_merged_row.ACCOUNTING_RULE_ID is null then l_merged_row.ACCOUNTING_RULE_ID := old_row.ACCOUNTING_RULE_ID; end if;
            if l_merged_row.ALLOWED_UNITS_LOOKUP_CODE is null then l_merged_row.ALLOWED_UNITS_LOOKUP_CODE := old_row.ALLOWED_UNITS_LOOKUP_CODE; end if;
            if l_merged_row.ALLOW_EXPRESS_DELIVERY_FLAG is null then l_merged_row.ALLOW_EXPRESS_DELIVERY_FLAG := old_row.ALLOW_EXPRESS_DELIVERY_FLAG; end if;
            if l_merged_row.ALLOW_ITEM_DESC_UPDATE_FLAG is null then l_merged_row.ALLOW_ITEM_DESC_UPDATE_FLAG := old_row.ALLOW_ITEM_DESC_UPDATE_FLAG; end if;
            if l_merged_row.ALLOW_SUBSTITUTE_RECEIPTS_FLAG is null then l_merged_row.ALLOW_SUBSTITUTE_RECEIPTS_FLAG := old_row.ALLOW_SUBSTITUTE_RECEIPTS_FLAG; end if;
            if l_merged_row.ALLOW_UNORDERED_RECEIPTS_FLAG is null then l_merged_row.ALLOW_UNORDERED_RECEIPTS_FLAG := old_row.ALLOW_UNORDERED_RECEIPTS_FLAG; end if;
            if l_merged_row.ASN_AUTOEXPIRE_FLAG is null then l_merged_row.ASN_AUTOEXPIRE_FLAG := old_row.ASN_AUTOEXPIRE_FLAG; end if;
            if l_merged_row.ASSET_CATEGORY_ID is null then l_merged_row.ASSET_CATEGORY_ID := old_row.ASSET_CATEGORY_ID; end if;
            if l_merged_row.ASSET_CREATION_CODE is null then l_merged_row.ASSET_CREATION_CODE := old_row.ASSET_CREATION_CODE; end if;
            if l_merged_row.ATO_FORECAST_CONTROL is null then l_merged_row.ATO_FORECAST_CONTROL := old_row.ATO_FORECAST_CONTROL; end if;
            if l_merged_row.ATP_COMPONENTS_FLAG is null then l_merged_row.ATP_COMPONENTS_FLAG := old_row.ATP_COMPONENTS_FLAG; end if;
            if l_merged_row.ATP_FLAG is null then l_merged_row.ATP_FLAG := old_row.ATP_FLAG; end if;
            if l_merged_row.ATP_RULE_ID is null then l_merged_row.ATP_RULE_ID := old_row.ATP_RULE_ID; end if;
            if l_merged_row.ATTRIBUTE1 is null then l_merged_row.ATTRIBUTE1 := old_row.ATTRIBUTE1; end if;
            if l_merged_row.ATTRIBUTE10 is null then l_merged_row.ATTRIBUTE10 := old_row.ATTRIBUTE10; end if;
            if l_merged_row.ATTRIBUTE11 is null then l_merged_row.ATTRIBUTE11 := old_row.ATTRIBUTE11; end if;
            if l_merged_row.ATTRIBUTE12 is null then l_merged_row.ATTRIBUTE12 := old_row.ATTRIBUTE12; end if;
            if l_merged_row.ATTRIBUTE13 is null then l_merged_row.ATTRIBUTE13 := old_row.ATTRIBUTE13; end if;
            if l_merged_row.ATTRIBUTE14 is null then l_merged_row.ATTRIBUTE14 := old_row.ATTRIBUTE14; end if;
            if l_merged_row.ATTRIBUTE15 is null then l_merged_row.ATTRIBUTE15 := old_row.ATTRIBUTE15; end if;
            if l_merged_row.ATTRIBUTE16 is null then l_merged_row.ATTRIBUTE16 := old_row.ATTRIBUTE16; end if;
            if l_merged_row.ATTRIBUTE17 is null then l_merged_row.ATTRIBUTE17 := old_row.ATTRIBUTE17; end if;
            if l_merged_row.ATTRIBUTE18 is null then l_merged_row.ATTRIBUTE18 := old_row.ATTRIBUTE18; end if;
            if l_merged_row.ATTRIBUTE19 is null then l_merged_row.ATTRIBUTE19 := old_row.ATTRIBUTE19; end if;
            if l_merged_row.ATTRIBUTE2 is null then l_merged_row.ATTRIBUTE2 := old_row.ATTRIBUTE2; end if;
            if l_merged_row.ATTRIBUTE20 is null then l_merged_row.ATTRIBUTE20 := old_row.ATTRIBUTE20; end if;
            if l_merged_row.ATTRIBUTE21 is null then l_merged_row.ATTRIBUTE21 := old_row.ATTRIBUTE21; end if;
            if l_merged_row.ATTRIBUTE22 is null then l_merged_row.ATTRIBUTE22 := old_row.ATTRIBUTE22; end if;
            if l_merged_row.ATTRIBUTE23 is null then l_merged_row.ATTRIBUTE23 := old_row.ATTRIBUTE23; end if;
            if l_merged_row.ATTRIBUTE24 is null then l_merged_row.ATTRIBUTE24 := old_row.ATTRIBUTE24; end if;
            if l_merged_row.ATTRIBUTE25 is null then l_merged_row.ATTRIBUTE25 := old_row.ATTRIBUTE25; end if;
            if l_merged_row.ATTRIBUTE26 is null then l_merged_row.ATTRIBUTE26 := old_row.ATTRIBUTE26; end if;
            if l_merged_row.ATTRIBUTE27 is null then l_merged_row.ATTRIBUTE27 := old_row.ATTRIBUTE27; end if;
            if l_merged_row.ATTRIBUTE28 is null then l_merged_row.ATTRIBUTE28 := old_row.ATTRIBUTE28; end if;
            if l_merged_row.ATTRIBUTE29 is null then l_merged_row.ATTRIBUTE29 := old_row.ATTRIBUTE29; end if;
            if l_merged_row.ATTRIBUTE3 is null then l_merged_row.ATTRIBUTE3 := old_row.ATTRIBUTE3; end if;
            if l_merged_row.ATTRIBUTE30 is null then l_merged_row.ATTRIBUTE30 := old_row.ATTRIBUTE30; end if;
            if l_merged_row.ATTRIBUTE4 is null then l_merged_row.ATTRIBUTE4 := old_row.ATTRIBUTE4; end if;
            if l_merged_row.ATTRIBUTE5 is null then l_merged_row.ATTRIBUTE5 := old_row.ATTRIBUTE5; end if;
            if l_merged_row.ATTRIBUTE6 is null then l_merged_row.ATTRIBUTE6 := old_row.ATTRIBUTE6; end if;
            if l_merged_row.ATTRIBUTE7 is null then l_merged_row.ATTRIBUTE7 := old_row.ATTRIBUTE7; end if;
            if l_merged_row.ATTRIBUTE8 is null then l_merged_row.ATTRIBUTE8 := old_row.ATTRIBUTE8; end if;
            if l_merged_row.ATTRIBUTE9 is null then l_merged_row.ATTRIBUTE9 := old_row.ATTRIBUTE9; end if;
            if l_merged_row.ATTRIBUTE_CATEGORY is null then l_merged_row.ATTRIBUTE_CATEGORY := old_row.ATTRIBUTE_CATEGORY; end if;
            if l_merged_row.AUTO_CREATED_CONFIG_FLAG is null then l_merged_row.AUTO_CREATED_CONFIG_FLAG := old_row.AUTO_CREATED_CONFIG_FLAG; end if;
            if l_merged_row.AUTO_LOT_ALPHA_PREFIX is null then l_merged_row.AUTO_LOT_ALPHA_PREFIX := old_row.AUTO_LOT_ALPHA_PREFIX; end if;
            if l_merged_row.AUTO_REDUCE_MPS is null then l_merged_row.AUTO_REDUCE_MPS := old_row.AUTO_REDUCE_MPS; end if;
            if l_merged_row.AUTO_SERIAL_ALPHA_PREFIX is null then l_merged_row.AUTO_SERIAL_ALPHA_PREFIX := old_row.AUTO_SERIAL_ALPHA_PREFIX; end if;
            if l_merged_row.BACK_ORDERABLE_FLAG is null then l_merged_row.BACK_ORDERABLE_FLAG := old_row.BACK_ORDERABLE_FLAG; end if;
            if l_merged_row.BASE_ITEM_ID is null then l_merged_row.BASE_ITEM_ID := old_row.BASE_ITEM_ID; end if;
            if l_merged_row.BASE_WARRANTY_SERVICE_ID is null then l_merged_row.BASE_WARRANTY_SERVICE_ID := old_row.BASE_WARRANTY_SERVICE_ID; end if;
            if l_merged_row.BOM_ENABLED_FLAG is null then l_merged_row.BOM_ENABLED_FLAG := old_row.BOM_ENABLED_FLAG; end if;
            if l_merged_row.BOM_ITEM_TYPE is null then l_merged_row.BOM_ITEM_TYPE := old_row.BOM_ITEM_TYPE; end if;
            if l_merged_row.BUILD_IN_WIP_FLAG is null then l_merged_row.BUILD_IN_WIP_FLAG := old_row.BUILD_IN_WIP_FLAG; end if;
            if l_merged_row.BULK_PICKED_FLAG is null then l_merged_row.BULK_PICKED_FLAG := old_row.BULK_PICKED_FLAG; end if;
            if l_merged_row.BUYER_ID is null then l_merged_row.BUYER_ID := old_row.BUYER_ID; end if;
            if l_merged_row.CARRYING_COST is null then l_merged_row.CARRYING_COST := old_row.CARRYING_COST; end if;
            if l_merged_row.CAS_NUMBER is null then l_merged_row.CAS_NUMBER := old_row.CAS_NUMBER; end if;
            if l_merged_row.CATALOG_STATUS_FLAG is null then l_merged_row.CATALOG_STATUS_FLAG := old_row.CATALOG_STATUS_FLAG; end if;
            if l_merged_row.CHANGE_ID is null then l_merged_row.CHANGE_ID := old_row.CHANGE_ID; end if;
            if l_merged_row.CHANGE_LINE_ID is null then l_merged_row.CHANGE_LINE_ID := old_row.CHANGE_LINE_ID; end if;
            if l_merged_row.CHARGE_PERIODICITY_CODE is null then l_merged_row.CHARGE_PERIODICITY_CODE := old_row.CHARGE_PERIODICITY_CODE; end if;
            if l_merged_row.CHECK_SHORTAGES_FLAG is null then l_merged_row.CHECK_SHORTAGES_FLAG := old_row.CHECK_SHORTAGES_FLAG; end if;
            if l_merged_row.CHILD_LOT_FLAG is null then l_merged_row.CHILD_LOT_FLAG := old_row.CHILD_LOT_FLAG; end if;
            if l_merged_row.CHILD_LOT_PREFIX is null then l_merged_row.CHILD_LOT_PREFIX := old_row.CHILD_LOT_PREFIX; end if;
            if l_merged_row.CHILD_LOT_STARTING_NUMBER is null then l_merged_row.CHILD_LOT_STARTING_NUMBER := old_row.CHILD_LOT_STARTING_NUMBER; end if;
            if l_merged_row.CHILD_LOT_VALIDATION_FLAG is null then l_merged_row.CHILD_LOT_VALIDATION_FLAG := old_row.CHILD_LOT_VALIDATION_FLAG; end if;
            if l_merged_row.COLLATERAL_FLAG is null then l_merged_row.COLLATERAL_FLAG := old_row.COLLATERAL_FLAG; end if;
            if l_merged_row.COMMS_ACTIVATION_REQD_FLAG is null then l_merged_row.COMMS_ACTIVATION_REQD_FLAG := old_row.COMMS_ACTIVATION_REQD_FLAG; end if;
            if l_merged_row.COMMS_NL_TRACKABLE_FLAG is null then l_merged_row.COMMS_NL_TRACKABLE_FLAG := old_row.COMMS_NL_TRACKABLE_FLAG; end if;
            if l_merged_row.CONFIG_MATCH is null then l_merged_row.CONFIG_MATCH := old_row.CONFIG_MATCH; end if;
            if l_merged_row.CONFIG_MODEL_TYPE is null then l_merged_row.CONFIG_MODEL_TYPE := old_row.CONFIG_MODEL_TYPE; end if;
            if l_merged_row.CONFIG_ORGS is null then l_merged_row.CONFIG_ORGS := old_row.CONFIG_ORGS; end if;
            if l_merged_row.CONSIGNED_FLAG is null then l_merged_row.CONSIGNED_FLAG := old_row.CONSIGNED_FLAG; end if;
            if l_merged_row.CONTAINER_ITEM_FLAG is null then l_merged_row.CONTAINER_ITEM_FLAG := old_row.CONTAINER_ITEM_FLAG; end if;
            if l_merged_row.CONTAINER_TYPE_CODE is null then l_merged_row.CONTAINER_TYPE_CODE := old_row.CONTAINER_TYPE_CODE; end if;
            if l_merged_row.CONTINOUS_TRANSFER is null then l_merged_row.CONTINOUS_TRANSFER := old_row.CONTINOUS_TRANSFER; end if;
            if l_merged_row.CONTRACT_ITEM_TYPE_CODE is null then l_merged_row.CONTRACT_ITEM_TYPE_CODE := old_row.CONTRACT_ITEM_TYPE_CODE; end if;
            if l_merged_row.CONVERGENCE is null then l_merged_row.CONVERGENCE := old_row.CONVERGENCE; end if;
            if l_merged_row.COPY_ITEM_ID is null then l_merged_row.COPY_ITEM_ID := old_row.COPY_ITEM_ID; end if;
            if l_merged_row.COPY_ITEM_NUMBER is null then l_merged_row.COPY_ITEM_NUMBER := old_row.COPY_ITEM_NUMBER; end if;
            if l_merged_row.COPY_LOT_ATTRIBUTE_FLAG is null then l_merged_row.COPY_LOT_ATTRIBUTE_FLAG := old_row.COPY_LOT_ATTRIBUTE_FLAG; end if;
            if l_merged_row.COSTING_ENABLED_FLAG is null then l_merged_row.COSTING_ENABLED_FLAG := old_row.COSTING_ENABLED_FLAG; end if;
            if l_merged_row.COST_OF_SALES_ACCOUNT is null then l_merged_row.COST_OF_SALES_ACCOUNT := old_row.COST_OF_SALES_ACCOUNT; end if;
            if l_merged_row.COUPON_EXEMPT_FLAG is null then l_merged_row.COUPON_EXEMPT_FLAG := old_row.COUPON_EXEMPT_FLAG; end if;
            if l_merged_row.COVERAGE_SCHEDULE_ID is null then l_merged_row.COVERAGE_SCHEDULE_ID := old_row.COVERAGE_SCHEDULE_ID; end if;
            if l_merged_row.CREATE_SUPPLY_FLAG is null then l_merged_row.CREATE_SUPPLY_FLAG := old_row.CREATE_SUPPLY_FLAG; end if;
            if l_merged_row.CRITICAL_COMPONENT_FLAG is null then l_merged_row.CRITICAL_COMPONENT_FLAG := old_row.CRITICAL_COMPONENT_FLAG; end if;
            if l_merged_row.CUMULATIVE_TOTAL_LEAD_TIME is null then l_merged_row.CUMULATIVE_TOTAL_LEAD_TIME := old_row.CUMULATIVE_TOTAL_LEAD_TIME; end if;
            if l_merged_row.CUM_MANUFACTURING_LEAD_TIME is null then l_merged_row.CUM_MANUFACTURING_LEAD_TIME := old_row.CUM_MANUFACTURING_LEAD_TIME; end if;
            if l_merged_row.CURRENT_PHASE_ID is null then l_merged_row.CURRENT_PHASE_ID := old_row.CURRENT_PHASE_ID; end if;
            if l_merged_row.CUSTOMER_ORDER_ENABLED_FLAG is null then l_merged_row.CUSTOMER_ORDER_ENABLED_FLAG := old_row.CUSTOMER_ORDER_ENABLED_FLAG; end if;
            if l_merged_row.CUSTOMER_ORDER_FLAG is null then l_merged_row.CUSTOMER_ORDER_FLAG := old_row.CUSTOMER_ORDER_FLAG; end if;
            if l_merged_row.CYCLE_COUNT_ENABLED_FLAG is null then l_merged_row.CYCLE_COUNT_ENABLED_FLAG := old_row.CYCLE_COUNT_ENABLED_FLAG; end if;
            if l_merged_row.DAYS_EARLY_RECEIPT_ALLOWED is null then l_merged_row.DAYS_EARLY_RECEIPT_ALLOWED := old_row.DAYS_EARLY_RECEIPT_ALLOWED; end if;
            if l_merged_row.DAYS_LATE_RECEIPT_ALLOWED is null then l_merged_row.DAYS_LATE_RECEIPT_ALLOWED := old_row.DAYS_LATE_RECEIPT_ALLOWED; end if;
            if l_merged_row.DAYS_MAX_INV_SUPPLY is null then l_merged_row.DAYS_MAX_INV_SUPPLY := old_row.DAYS_MAX_INV_SUPPLY; end if;
            if l_merged_row.DAYS_MAX_INV_WINDOW is null then l_merged_row.DAYS_MAX_INV_WINDOW := old_row.DAYS_MAX_INV_WINDOW; end if;
            if l_merged_row.DAYS_TGT_INV_SUPPLY is null then l_merged_row.DAYS_TGT_INV_SUPPLY := old_row.DAYS_TGT_INV_SUPPLY; end if;
            if l_merged_row.DAYS_TGT_INV_WINDOW is null then l_merged_row.DAYS_TGT_INV_WINDOW := old_row.DAYS_TGT_INV_WINDOW; end if;
            if l_merged_row.DEFAULT_GRADE is null then l_merged_row.DEFAULT_GRADE := old_row.DEFAULT_GRADE; end if;
            if l_merged_row.DEFAULT_INCLUDE_IN_ROLLUP_FLAG is null then l_merged_row.DEFAULT_INCLUDE_IN_ROLLUP_FLAG := old_row.DEFAULT_INCLUDE_IN_ROLLUP_FLAG; end if;
            if l_merged_row.DEFAULT_LOT_STATUS_ID is null then l_merged_row.DEFAULT_LOT_STATUS_ID := old_row.DEFAULT_LOT_STATUS_ID; end if;
            if l_merged_row.DEFAULT_SERIAL_STATUS_ID is null then l_merged_row.DEFAULT_SERIAL_STATUS_ID := old_row.DEFAULT_SERIAL_STATUS_ID; end if;
            if l_merged_row.DEFAULT_SHIPPING_ORG is null then l_merged_row.DEFAULT_SHIPPING_ORG := old_row.DEFAULT_SHIPPING_ORG; end if;
            if l_merged_row.DEFAULT_SO_SOURCE_TYPE is null then l_merged_row.DEFAULT_SO_SOURCE_TYPE := old_row.DEFAULT_SO_SOURCE_TYPE; end if;
            if l_merged_row.DEFECT_TRACKING_ON_FLAG is null then l_merged_row.DEFECT_TRACKING_ON_FLAG := old_row.DEFECT_TRACKING_ON_FLAG; end if;
            if l_merged_row.DEMAND_SOURCE_HEADER_ID is null then l_merged_row.DEMAND_SOURCE_HEADER_ID := old_row.DEMAND_SOURCE_HEADER_ID; end if;
            if l_merged_row.DEMAND_SOURCE_LINE is null then l_merged_row.DEMAND_SOURCE_LINE := old_row.DEMAND_SOURCE_LINE; end if;
            if l_merged_row.DEMAND_SOURCE_TYPE is null then l_merged_row.DEMAND_SOURCE_TYPE := old_row.DEMAND_SOURCE_TYPE; end if;
            if l_merged_row.DEMAND_TIME_FENCE_CODE is null then l_merged_row.DEMAND_TIME_FENCE_CODE := old_row.DEMAND_TIME_FENCE_CODE; end if;
            if l_merged_row.DEMAND_TIME_FENCE_DAYS is null then l_merged_row.DEMAND_TIME_FENCE_DAYS := old_row.DEMAND_TIME_FENCE_DAYS; end if;
            if l_merged_row.DESCRIPTION is null then l_merged_row.DESCRIPTION := old_row.DESCRIPTION; end if;
            if l_merged_row.DIMENSION_UOM_CODE is null then l_merged_row.DIMENSION_UOM_CODE := old_row.DIMENSION_UOM_CODE; end if;
            if l_merged_row.DIVERGENCE is null then l_merged_row.DIVERGENCE := old_row.DIVERGENCE; end if;
            if l_merged_row.DOWNLOADABLE_FLAG is null then l_merged_row.DOWNLOADABLE_FLAG := old_row.DOWNLOADABLE_FLAG; end if;
            if l_merged_row.DRP_PLANNED_FLAG is null then l_merged_row.DRP_PLANNED_FLAG := old_row.DRP_PLANNED_FLAG; end if;
            if l_merged_row.DUAL_UOM_CONTROL is null then l_merged_row.DUAL_UOM_CONTROL := old_row.DUAL_UOM_CONTROL; end if;
            if l_merged_row.DUAL_UOM_DEVIATION_HIGH is null then l_merged_row.DUAL_UOM_DEVIATION_HIGH := old_row.DUAL_UOM_DEVIATION_HIGH; end if;
            if l_merged_row.DUAL_UOM_DEVIATION_LOW is null then l_merged_row.DUAL_UOM_DEVIATION_LOW := old_row.DUAL_UOM_DEVIATION_LOW; end if;
            if l_merged_row.EAM_ACTIVITY_CAUSE_CODE is null then l_merged_row.EAM_ACTIVITY_CAUSE_CODE := old_row.EAM_ACTIVITY_CAUSE_CODE; end if;
            if l_merged_row.EAM_ACTIVITY_SOURCE_CODE is null then l_merged_row.EAM_ACTIVITY_SOURCE_CODE := old_row.EAM_ACTIVITY_SOURCE_CODE; end if;
            if l_merged_row.EAM_ACTIVITY_TYPE_CODE is null then l_merged_row.EAM_ACTIVITY_TYPE_CODE := old_row.EAM_ACTIVITY_TYPE_CODE; end if;
            if l_merged_row.EAM_ACT_NOTIFICATION_FLAG is null then l_merged_row.EAM_ACT_NOTIFICATION_FLAG := old_row.EAM_ACT_NOTIFICATION_FLAG; end if;
            if l_merged_row.EAM_ACT_SHUTDOWN_STATUS is null then l_merged_row.EAM_ACT_SHUTDOWN_STATUS := old_row.EAM_ACT_SHUTDOWN_STATUS; end if;
            if l_merged_row.EAM_ITEM_TYPE is null then l_merged_row.EAM_ITEM_TYPE := old_row.EAM_ITEM_TYPE; end if;
            if l_merged_row.EFFECTIVITY_CONTROL is null then l_merged_row.EFFECTIVITY_CONTROL := old_row.EFFECTIVITY_CONTROL; end if;
            if l_merged_row.ELECTRONIC_FLAG is null then l_merged_row.ELECTRONIC_FLAG := old_row.ELECTRONIC_FLAG; end if;
            if l_merged_row.ENABLED_FLAG is null then l_merged_row.ENABLED_FLAG := old_row.ENABLED_FLAG; end if;
            if l_merged_row.ENCUMBRANCE_ACCOUNT is null then l_merged_row.ENCUMBRANCE_ACCOUNT := old_row.ENCUMBRANCE_ACCOUNT; end if;
            if l_merged_row.END_ASSEMBLY_PEGGING_FLAG is null then l_merged_row.END_ASSEMBLY_PEGGING_FLAG := old_row.END_ASSEMBLY_PEGGING_FLAG; end if;
            if l_merged_row.END_DATE_ACTIVE is null then l_merged_row.END_DATE_ACTIVE := old_row.END_DATE_ACTIVE; end if;
            if l_merged_row.ENFORCE_SHIP_TO_LOCATION_CODE is null then l_merged_row.ENFORCE_SHIP_TO_LOCATION_CODE := old_row.ENFORCE_SHIP_TO_LOCATION_CODE; end if;
            if l_merged_row.ENGINEERING_DATE is null then l_merged_row.ENGINEERING_DATE := old_row.ENGINEERING_DATE; end if;
            if l_merged_row.ENGINEERING_ECN_CODE is null then l_merged_row.ENGINEERING_ECN_CODE := old_row.ENGINEERING_ECN_CODE; end if;
            if l_merged_row.ENGINEERING_ITEM_ID is null then l_merged_row.ENGINEERING_ITEM_ID := old_row.ENGINEERING_ITEM_ID; end if;
            if l_merged_row.ENG_ITEM_FLAG is null then l_merged_row.ENG_ITEM_FLAG := old_row.ENG_ITEM_FLAG; end if;
            if l_merged_row.EQUIPMENT_TYPE is null then l_merged_row.EQUIPMENT_TYPE := old_row.EQUIPMENT_TYPE; end if;
            if l_merged_row.EVENT_FLAG is null then l_merged_row.EVENT_FLAG := old_row.EVENT_FLAG; end if;
            if l_merged_row.EXCLUDE_FROM_BUDGET_FLAG is null then l_merged_row.EXCLUDE_FROM_BUDGET_FLAG := old_row.EXCLUDE_FROM_BUDGET_FLAG; end if;
            if l_merged_row.EXPENSE_ACCOUNT is null then l_merged_row.EXPENSE_ACCOUNT := old_row.EXPENSE_ACCOUNT; end if;
            if l_merged_row.EXPENSE_BILLABLE_FLAG is null then l_merged_row.EXPENSE_BILLABLE_FLAG := old_row.EXPENSE_BILLABLE_FLAG; end if;
            if l_merged_row.EXPIRATION_ACTION_CODE is null then l_merged_row.EXPIRATION_ACTION_CODE := old_row.EXPIRATION_ACTION_CODE; end if;
            if l_merged_row.EXPIRATION_ACTION_INTERVAL is null then l_merged_row.EXPIRATION_ACTION_INTERVAL := old_row.EXPIRATION_ACTION_INTERVAL; end if;
            if l_merged_row.FINANCING_ALLOWED_FLAG is null then l_merged_row.FINANCING_ALLOWED_FLAG := old_row.FINANCING_ALLOWED_FLAG; end if;
            if l_merged_row.FIXED_DAYS_SUPPLY is null then l_merged_row.FIXED_DAYS_SUPPLY := old_row.FIXED_DAYS_SUPPLY; end if;
            if l_merged_row.FIXED_LEAD_TIME is null then l_merged_row.FIXED_LEAD_TIME := old_row.FIXED_LEAD_TIME; end if;
            if l_merged_row.FIXED_LOT_MULTIPLIER is null then l_merged_row.FIXED_LOT_MULTIPLIER := old_row.FIXED_LOT_MULTIPLIER; end if;
            if l_merged_row.FIXED_ORDER_QUANTITY is null then l_merged_row.FIXED_ORDER_QUANTITY := old_row.FIXED_ORDER_QUANTITY; end if;
            if l_merged_row.FORECAST_HORIZON is null then l_merged_row.FORECAST_HORIZON := old_row.FORECAST_HORIZON; end if;
            if l_merged_row.FULL_LEAD_TIME is null then l_merged_row.FULL_LEAD_TIME := old_row.FULL_LEAD_TIME; end if;
            if l_merged_row.GLOBAL_ATTRIBUTE1 is null then l_merged_row.GLOBAL_ATTRIBUTE1 := old_row.GLOBAL_ATTRIBUTE1; end if;
            if l_merged_row.GLOBAL_ATTRIBUTE10 is null then l_merged_row.GLOBAL_ATTRIBUTE10 := old_row.GLOBAL_ATTRIBUTE10; end if;
            if l_merged_row.GLOBAL_ATTRIBUTE2 is null then l_merged_row.GLOBAL_ATTRIBUTE2 := old_row.GLOBAL_ATTRIBUTE2; end if;
            if l_merged_row.GLOBAL_ATTRIBUTE3 is null then l_merged_row.GLOBAL_ATTRIBUTE3 := old_row.GLOBAL_ATTRIBUTE3; end if;
            if l_merged_row.GLOBAL_ATTRIBUTE4 is null then l_merged_row.GLOBAL_ATTRIBUTE4 := old_row.GLOBAL_ATTRIBUTE4; end if;
            if l_merged_row.GLOBAL_ATTRIBUTE5 is null then l_merged_row.GLOBAL_ATTRIBUTE5 := old_row.GLOBAL_ATTRIBUTE5; end if;
            if l_merged_row.GLOBAL_ATTRIBUTE6 is null then l_merged_row.GLOBAL_ATTRIBUTE6 := old_row.GLOBAL_ATTRIBUTE6; end if;
            if l_merged_row.GLOBAL_ATTRIBUTE7 is null then l_merged_row.GLOBAL_ATTRIBUTE7 := old_row.GLOBAL_ATTRIBUTE7; end if;
            if l_merged_row.GLOBAL_ATTRIBUTE8 is null then l_merged_row.GLOBAL_ATTRIBUTE8 := old_row.GLOBAL_ATTRIBUTE8; end if;
            if l_merged_row.GLOBAL_ATTRIBUTE9 is null then l_merged_row.GLOBAL_ATTRIBUTE9 := old_row.GLOBAL_ATTRIBUTE9; end if;
            if l_merged_row.GLOBAL_ATTRIBUTE_CATEGORY is null then l_merged_row.GLOBAL_ATTRIBUTE_CATEGORY := old_row.GLOBAL_ATTRIBUTE_CATEGORY; end if;
            if l_merged_row.GLOBAL_TRADE_ITEM_NUMBER is null then l_merged_row.GLOBAL_TRADE_ITEM_NUMBER := old_row.GLOBAL_TRADE_ITEM_NUMBER; end if;
            if l_merged_row.GRADE_CONTROL_FLAG is null then l_merged_row.GRADE_CONTROL_FLAG := old_row.GRADE_CONTROL_FLAG; end if;
            if l_merged_row.GTIN_DESCRIPTION is null then l_merged_row.GTIN_DESCRIPTION := old_row.GTIN_DESCRIPTION; end if;
            if l_merged_row.HAZARDOUS_MATERIAL_FLAG is null then l_merged_row.HAZARDOUS_MATERIAL_FLAG := old_row.HAZARDOUS_MATERIAL_FLAG; end if;
            if l_merged_row.HAZARD_CLASS_ID is null then l_merged_row.HAZARD_CLASS_ID := old_row.HAZARD_CLASS_ID; end if;
            if l_merged_row.HOLD_DAYS is null then l_merged_row.HOLD_DAYS := old_row.HOLD_DAYS; end if;
            if l_merged_row.IB_ITEM_INSTANCE_CLASS is null then l_merged_row.IB_ITEM_INSTANCE_CLASS := old_row.IB_ITEM_INSTANCE_CLASS; end if;
            if l_merged_row.INDIVISIBLE_FLAG is null then l_merged_row.INDIVISIBLE_FLAG := old_row.INDIVISIBLE_FLAG; end if;
            if l_merged_row.INSPECTION_REQUIRED_FLAG is null then l_merged_row.INSPECTION_REQUIRED_FLAG := old_row.INSPECTION_REQUIRED_FLAG; end if;
            if l_merged_row.INTERNAL_ORDER_ENABLED_FLAG is null then l_merged_row.INTERNAL_ORDER_ENABLED_FLAG := old_row.INTERNAL_ORDER_ENABLED_FLAG; end if;
            if l_merged_row.INTERNAL_ORDER_FLAG is null then l_merged_row.INTERNAL_ORDER_FLAG := old_row.INTERNAL_ORDER_FLAG; end if;
            if l_merged_row.INTERNAL_VOLUME is null then l_merged_row.INTERNAL_VOLUME := old_row.INTERNAL_VOLUME; end if;
            if l_merged_row.INVENTORY_ASSET_FLAG is null then l_merged_row.INVENTORY_ASSET_FLAG := old_row.INVENTORY_ASSET_FLAG; end if;
            if l_merged_row.INVENTORY_CARRY_PENALTY is null then l_merged_row.INVENTORY_CARRY_PENALTY := old_row.INVENTORY_CARRY_PENALTY; end if;
            if l_merged_row.INVENTORY_ITEM_FLAG is null then l_merged_row.INVENTORY_ITEM_FLAG := old_row.INVENTORY_ITEM_FLAG; end if;
            if l_merged_row.INVENTORY_ITEM_STATUS_CODE is null then l_merged_row.INVENTORY_ITEM_STATUS_CODE := old_row.INVENTORY_ITEM_STATUS_CODE; end if;
            if l_merged_row.INVENTORY_PLANNING_CODE is null then l_merged_row.INVENTORY_PLANNING_CODE := old_row.INVENTORY_PLANNING_CODE; end if;
            if l_merged_row.INVOICEABLE_ITEM_FLAG is null then l_merged_row.INVOICEABLE_ITEM_FLAG := old_row.INVOICEABLE_ITEM_FLAG; end if;
            if l_merged_row.INVOICE_CLOSE_TOLERANCE is null then l_merged_row.INVOICE_CLOSE_TOLERANCE := old_row.INVOICE_CLOSE_TOLERANCE; end if;
            if l_merged_row.INVOICE_ENABLED_FLAG is null then l_merged_row.INVOICE_ENABLED_FLAG := old_row.INVOICE_ENABLED_FLAG; end if;
            if l_merged_row.INVOICING_RULE_ID is null then l_merged_row.INVOICING_RULE_ID := old_row.INVOICING_RULE_ID; end if;
            if l_merged_row.ITEM_TYPE is null then l_merged_row.ITEM_TYPE := old_row.ITEM_TYPE; end if;
            if l_merged_row.LEAD_TIME_LOT_SIZE is null then l_merged_row.LEAD_TIME_LOT_SIZE := old_row.LEAD_TIME_LOT_SIZE; end if;
            if l_merged_row.LIFECYCLE_ID is null then l_merged_row.LIFECYCLE_ID := old_row.LIFECYCLE_ID; end if;
            if l_merged_row.LIST_PRICE_PER_UNIT is null then l_merged_row.LIST_PRICE_PER_UNIT := old_row.LIST_PRICE_PER_UNIT; end if;
            if l_merged_row.LOCATION_CONTROL_CODE is null then l_merged_row.LOCATION_CONTROL_CODE := old_row.LOCATION_CONTROL_CODE; end if;
            if l_merged_row.LONG_DESCRIPTION is null then l_merged_row.LONG_DESCRIPTION := old_row.LONG_DESCRIPTION; end if;
            if l_merged_row.LOT_CONTROL_CODE is null then l_merged_row.LOT_CONTROL_CODE := old_row.LOT_CONTROL_CODE; end if;
            if l_merged_row.LOT_DIVISIBLE_FLAG is null then l_merged_row.LOT_DIVISIBLE_FLAG := old_row.LOT_DIVISIBLE_FLAG; end if;
            if l_merged_row.LOT_MERGE_ENABLED is null then l_merged_row.LOT_MERGE_ENABLED := old_row.LOT_MERGE_ENABLED; end if;
            if l_merged_row.LOT_SPLIT_ENABLED is null then l_merged_row.LOT_SPLIT_ENABLED := old_row.LOT_SPLIT_ENABLED; end if;
            if l_merged_row.LOT_STATUS_ENABLED is null then l_merged_row.LOT_STATUS_ENABLED := old_row.LOT_STATUS_ENABLED; end if;
            if l_merged_row.LOT_SUBSTITUTION_ENABLED is null then l_merged_row.LOT_SUBSTITUTION_ENABLED := old_row.LOT_SUBSTITUTION_ENABLED; end if;
            if l_merged_row.LOT_TRANSLATE_ENABLED is null then l_merged_row.LOT_TRANSLATE_ENABLED := old_row.LOT_TRANSLATE_ENABLED; end if;
            if l_merged_row.MARKET_PRICE is null then l_merged_row.MARKET_PRICE := old_row.MARKET_PRICE; end if;
            if l_merged_row.MATERIAL_BILLABLE_FLAG is null then l_merged_row.MATERIAL_BILLABLE_FLAG := old_row.MATERIAL_BILLABLE_FLAG; end if;
            if l_merged_row.MATERIAL_COST is null then l_merged_row.MATERIAL_COST := old_row.MATERIAL_COST; end if;
            if l_merged_row.MATERIAL_OH_RATE is null then l_merged_row.MATERIAL_OH_RATE := old_row.MATERIAL_OH_RATE; end if;
            if l_merged_row.MATERIAL_OH_SUB_ELEM is null then l_merged_row.MATERIAL_OH_SUB_ELEM := old_row.MATERIAL_OH_SUB_ELEM; end if;
            if l_merged_row.MATERIAL_OH_SUB_ELEM_ID is null then l_merged_row.MATERIAL_OH_SUB_ELEM_ID := old_row.MATERIAL_OH_SUB_ELEM_ID; end if;
            if l_merged_row.MATERIAL_SUB_ELEM is null then l_merged_row.MATERIAL_SUB_ELEM := old_row.MATERIAL_SUB_ELEM; end if;
            if l_merged_row.MATERIAL_SUB_ELEM_ID is null then l_merged_row.MATERIAL_SUB_ELEM_ID := old_row.MATERIAL_SUB_ELEM_ID; end if;
            if l_merged_row.MATURITY_DAYS is null then l_merged_row.MATURITY_DAYS := old_row.MATURITY_DAYS; end if;
            if l_merged_row.MAXIMUM_LOAD_WEIGHT is null then l_merged_row.MAXIMUM_LOAD_WEIGHT := old_row.MAXIMUM_LOAD_WEIGHT; end if;
            if l_merged_row.MAXIMUM_ORDER_QUANTITY is null then l_merged_row.MAXIMUM_ORDER_QUANTITY := old_row.MAXIMUM_ORDER_QUANTITY; end if;
            if l_merged_row.MAX_MINMAX_QUANTITY is null then l_merged_row.MAX_MINMAX_QUANTITY := old_row.MAX_MINMAX_QUANTITY; end if;
            if l_merged_row.MAX_WARRANTY_AMOUNT is null then l_merged_row.MAX_WARRANTY_AMOUNT := old_row.MAX_WARRANTY_AMOUNT; end if;
            if l_merged_row.MINIMUM_FILL_PERCENT is null then l_merged_row.MINIMUM_FILL_PERCENT := old_row.MINIMUM_FILL_PERCENT; end if;
            if l_merged_row.MINIMUM_LICENSE_QUANTITY is null then l_merged_row.MINIMUM_LICENSE_QUANTITY := old_row.MINIMUM_LICENSE_QUANTITY; end if;
            if l_merged_row.MINIMUM_ORDER_QUANTITY is null then l_merged_row.MINIMUM_ORDER_QUANTITY := old_row.MINIMUM_ORDER_QUANTITY; end if;
            if l_merged_row.MIN_MINMAX_QUANTITY is null then l_merged_row.MIN_MINMAX_QUANTITY := old_row.MIN_MINMAX_QUANTITY; end if;
            if l_merged_row.MODEL_CONFIG_CLAUSE_NAME is null then l_merged_row.MODEL_CONFIG_CLAUSE_NAME := old_row.MODEL_CONFIG_CLAUSE_NAME; end if;
            if l_merged_row.MRP_CALCULATE_ATP_FLAG is null then l_merged_row.MRP_CALCULATE_ATP_FLAG := old_row.MRP_CALCULATE_ATP_FLAG; end if;
            if l_merged_row.MRP_PLANNING_CODE is null then l_merged_row.MRP_PLANNING_CODE := old_row.MRP_PLANNING_CODE; end if;
            if l_merged_row.MRP_SAFETY_STOCK_CODE is null then l_merged_row.MRP_SAFETY_STOCK_CODE := old_row.MRP_SAFETY_STOCK_CODE; end if;
            if l_merged_row.MRP_SAFETY_STOCK_PERCENT is null then l_merged_row.MRP_SAFETY_STOCK_PERCENT := old_row.MRP_SAFETY_STOCK_PERCENT; end if;
            if l_merged_row.MTL_TRANSACTIONS_ENABLED_FLAG is null then l_merged_row.MTL_TRANSACTIONS_ENABLED_FLAG := old_row.MTL_TRANSACTIONS_ENABLED_FLAG; end if;
            if l_merged_row.MUST_USE_APPROVED_VENDOR_FLAG is null then l_merged_row.MUST_USE_APPROVED_VENDOR_FLAG := old_row.MUST_USE_APPROVED_VENDOR_FLAG; end if;
            if l_merged_row.NEGATIVE_MEASUREMENT_ERROR is null then l_merged_row.NEGATIVE_MEASUREMENT_ERROR := old_row.NEGATIVE_MEASUREMENT_ERROR; end if;
            if l_merged_row.NEW_REVISION_CODE is null then l_merged_row.NEW_REVISION_CODE := old_row.NEW_REVISION_CODE; end if;
            if l_merged_row.ONT_PRICING_QTY_SOURCE is null then l_merged_row.ONT_PRICING_QTY_SOURCE := old_row.ONT_PRICING_QTY_SOURCE; end if;
            if l_merged_row.OPERATION_SLACK_PENALTY is null then l_merged_row.OPERATION_SLACK_PENALTY := old_row.OPERATION_SLACK_PENALTY; end if;
            if l_merged_row.ORDERABLE_ON_WEB_FLAG is null then l_merged_row.ORDERABLE_ON_WEB_FLAG := old_row.ORDERABLE_ON_WEB_FLAG; end if;
            if l_merged_row.ORDER_COST is null then l_merged_row.ORDER_COST := old_row.ORDER_COST; end if;
            if l_merged_row.OUTSIDE_OPERATION_FLAG is null then l_merged_row.OUTSIDE_OPERATION_FLAG := old_row.OUTSIDE_OPERATION_FLAG; end if;
            if l_merged_row.OUTSIDE_OPERATION_UOM_TYPE is null then l_merged_row.OUTSIDE_OPERATION_UOM_TYPE := old_row.OUTSIDE_OPERATION_UOM_TYPE; end if;
            if l_merged_row.OUTSOURCED_ASSEMBLY is null then l_merged_row.OUTSOURCED_ASSEMBLY := old_row.OUTSOURCED_ASSEMBLY; end if;
            if l_merged_row.OVERCOMPLETION_TOLERANCE_TYPE is null then l_merged_row.OVERCOMPLETION_TOLERANCE_TYPE := old_row.OVERCOMPLETION_TOLERANCE_TYPE; end if;
            if l_merged_row.OVERCOMPLETION_TOLERANCE_VALUE is null then l_merged_row.OVERCOMPLETION_TOLERANCE_VALUE := old_row.OVERCOMPLETION_TOLERANCE_VALUE; end if;
            if l_merged_row.OVERRUN_PERCENTAGE is null then l_merged_row.OVERRUN_PERCENTAGE := old_row.OVERRUN_PERCENTAGE; end if;
            if l_merged_row.OVER_RETURN_TOLERANCE is null then l_merged_row.OVER_RETURN_TOLERANCE := old_row.OVER_RETURN_TOLERANCE; end if;
            if l_merged_row.OVER_SHIPMENT_TOLERANCE is null then l_merged_row.OVER_SHIPMENT_TOLERANCE := old_row.OVER_SHIPMENT_TOLERANCE; end if;
            if l_merged_row.PARENT_CHILD_GENERATION_FLAG is null then l_merged_row.PARENT_CHILD_GENERATION_FLAG := old_row.PARENT_CHILD_GENERATION_FLAG; end if;
            if l_merged_row.PAYMENT_TERMS_ID is null then l_merged_row.PAYMENT_TERMS_ID := old_row.PAYMENT_TERMS_ID; end if;
            if l_merged_row.PICKING_RULE_ID is null then l_merged_row.PICKING_RULE_ID := old_row.PICKING_RULE_ID; end if;
            if l_merged_row.PICK_COMPONENTS_FLAG is null then l_merged_row.PICK_COMPONENTS_FLAG := old_row.PICK_COMPONENTS_FLAG; end if;
            if l_merged_row.PLANNED_INV_POINT_FLAG is null then l_merged_row.PLANNED_INV_POINT_FLAG := old_row.PLANNED_INV_POINT_FLAG; end if;
            if l_merged_row.PLANNER_CODE is null then l_merged_row.PLANNER_CODE := old_row.PLANNER_CODE; end if;
            if l_merged_row.PLANNING_EXCEPTION_SET is null then l_merged_row.PLANNING_EXCEPTION_SET := old_row.PLANNING_EXCEPTION_SET; end if;
            if l_merged_row.PLANNING_MAKE_BUY_CODE is null then l_merged_row.PLANNING_MAKE_BUY_CODE := old_row.PLANNING_MAKE_BUY_CODE; end if;
            if l_merged_row.PLANNING_TIME_FENCE_CODE is null then l_merged_row.PLANNING_TIME_FENCE_CODE := old_row.PLANNING_TIME_FENCE_CODE; end if;
            if l_merged_row.PLANNING_TIME_FENCE_DAYS is null then l_merged_row.PLANNING_TIME_FENCE_DAYS := old_row.PLANNING_TIME_FENCE_DAYS; end if;
            if l_merged_row.POSITIVE_MEASUREMENT_ERROR is null then l_merged_row.POSITIVE_MEASUREMENT_ERROR := old_row.POSITIVE_MEASUREMENT_ERROR; end if;
            if l_merged_row.POSTPROCESSING_LEAD_TIME is null then l_merged_row.POSTPROCESSING_LEAD_TIME := old_row.POSTPROCESSING_LEAD_TIME; end if;
            if l_merged_row.PREPOSITION_POINT is null then l_merged_row.PREPOSITION_POINT := old_row.PREPOSITION_POINT; end if;
            if l_merged_row.PREPROCESSING_LEAD_TIME is null then l_merged_row.PREPROCESSING_LEAD_TIME := old_row.PREPROCESSING_LEAD_TIME; end if;
            if l_merged_row.PREVENTIVE_MAINTENANCE_FLAG is null then l_merged_row.PREVENTIVE_MAINTENANCE_FLAG := old_row.PREVENTIVE_MAINTENANCE_FLAG; end if;
            if l_merged_row.PRICE_TOLERANCE_PERCENT is null then l_merged_row.PRICE_TOLERANCE_PERCENT := old_row.PRICE_TOLERANCE_PERCENT; end if;
            if l_merged_row.PRIMARY_SPECIALIST_ID is null then l_merged_row.PRIMARY_SPECIALIST_ID := old_row.PRIMARY_SPECIALIST_ID; end if;
            if l_merged_row.PROCESS_COSTING_ENABLED_FLAG is null then l_merged_row.PROCESS_COSTING_ENABLED_FLAG := old_row.PROCESS_COSTING_ENABLED_FLAG; end if;
            if l_merged_row.PROCESS_EXECUTION_ENABLED_FLAG is null then l_merged_row.PROCESS_EXECUTION_ENABLED_FLAG := old_row.PROCESS_EXECUTION_ENABLED_FLAG; end if;
            if l_merged_row.PROCESS_QUALITY_ENABLED_FLAG is null then l_merged_row.PROCESS_QUALITY_ENABLED_FLAG := old_row.PROCESS_QUALITY_ENABLED_FLAG; end if;
            if l_merged_row.PROCESS_SUPPLY_LOCATOR_ID is null then l_merged_row.PROCESS_SUPPLY_LOCATOR_ID := old_row.PROCESS_SUPPLY_LOCATOR_ID; end if;
            if l_merged_row.PROCESS_SUPPLY_SUBINVENTORY is null then l_merged_row.PROCESS_SUPPLY_SUBINVENTORY := old_row.PROCESS_SUPPLY_SUBINVENTORY; end if;
            if l_merged_row.PROCESS_YIELD_LOCATOR_ID is null then l_merged_row.PROCESS_YIELD_LOCATOR_ID := old_row.PROCESS_YIELD_LOCATOR_ID; end if;
            if l_merged_row.PROCESS_YIELD_SUBINVENTORY is null then l_merged_row.PROCESS_YIELD_SUBINVENTORY := old_row.PROCESS_YIELD_SUBINVENTORY; end if;
            if l_merged_row.PRODUCT_FAMILY_ITEM_ID is null then l_merged_row.PRODUCT_FAMILY_ITEM_ID := old_row.PRODUCT_FAMILY_ITEM_ID; end if;
            if l_merged_row.PRORATE_SERVICE_FLAG is null then l_merged_row.PRORATE_SERVICE_FLAG := old_row.PRORATE_SERVICE_FLAG; end if;
            if l_merged_row.PURCHASING_ENABLED_FLAG is null then l_merged_row.PURCHASING_ENABLED_FLAG := old_row.PURCHASING_ENABLED_FLAG; end if;
            if l_merged_row.PURCHASING_ITEM_FLAG is null then l_merged_row.PURCHASING_ITEM_FLAG := old_row.PURCHASING_ITEM_FLAG; end if;
            if l_merged_row.PURCHASING_TAX_CODE is null then l_merged_row.PURCHASING_TAX_CODE := old_row.PURCHASING_TAX_CODE; end if;
            if l_merged_row.QTY_RCV_EXCEPTION_CODE is null then l_merged_row.QTY_RCV_EXCEPTION_CODE := old_row.QTY_RCV_EXCEPTION_CODE; end if;
            if l_merged_row.QTY_RCV_TOLERANCE is null then l_merged_row.QTY_RCV_TOLERANCE := old_row.QTY_RCV_TOLERANCE; end if;
            if l_merged_row.RECEIPT_DAYS_EXCEPTION_CODE is null then l_merged_row.RECEIPT_DAYS_EXCEPTION_CODE := old_row.RECEIPT_DAYS_EXCEPTION_CODE; end if;
            if l_merged_row.RECEIPT_REQUIRED_FLAG is null then l_merged_row.RECEIPT_REQUIRED_FLAG := old_row.RECEIPT_REQUIRED_FLAG; end if;
            if l_merged_row.RECEIVE_CLOSE_TOLERANCE is null then l_merged_row.RECEIVE_CLOSE_TOLERANCE := old_row.RECEIVE_CLOSE_TOLERANCE; end if;
            if l_merged_row.RECEIVING_ROUTING_ID is null then l_merged_row.RECEIVING_ROUTING_ID := old_row.RECEIVING_ROUTING_ID; end if;
            if l_merged_row.RECIPE_ENABLED_FLAG is null then l_merged_row.RECIPE_ENABLED_FLAG := old_row.RECIPE_ENABLED_FLAG; end if;
            if l_merged_row.RECOVERED_PART_DISP_CODE is null then l_merged_row.RECOVERED_PART_DISP_CODE := old_row.RECOVERED_PART_DISP_CODE; end if;
            if l_merged_row.RELEASE_TIME_FENCE_CODE is null then l_merged_row.RELEASE_TIME_FENCE_CODE := old_row.RELEASE_TIME_FENCE_CODE; end if;
            if l_merged_row.RELEASE_TIME_FENCE_DAYS is null then l_merged_row.RELEASE_TIME_FENCE_DAYS := old_row.RELEASE_TIME_FENCE_DAYS; end if;
            if l_merged_row.REPAIR_LEADTIME is null then l_merged_row.REPAIR_LEADTIME := old_row.REPAIR_LEADTIME; end if;
            if l_merged_row.REPAIR_PROGRAM is null then l_merged_row.REPAIR_PROGRAM := old_row.REPAIR_PROGRAM; end if;
            if l_merged_row.REPAIR_YIELD is null then l_merged_row.REPAIR_YIELD := old_row.REPAIR_YIELD; end if;
            if l_merged_row.REPETITIVE_PLANNING_FLAG is null then l_merged_row.REPETITIVE_PLANNING_FLAG := old_row.REPETITIVE_PLANNING_FLAG; end if;
            if l_merged_row.REPLENISH_TO_ORDER_FLAG is null then l_merged_row.REPLENISH_TO_ORDER_FLAG := old_row.REPLENISH_TO_ORDER_FLAG; end if;
            if l_merged_row.RESERVABLE_TYPE is null then l_merged_row.RESERVABLE_TYPE := old_row.RESERVABLE_TYPE; end if;
            if l_merged_row.RESPONSE_TIME_PERIOD_CODE is null then l_merged_row.RESPONSE_TIME_PERIOD_CODE := old_row.RESPONSE_TIME_PERIOD_CODE; end if;
            if l_merged_row.RESPONSE_TIME_VALUE is null then l_merged_row.RESPONSE_TIME_VALUE := old_row.RESPONSE_TIME_VALUE; end if;
            if l_merged_row.RESTRICT_LOCATORS_CODE is null then l_merged_row.RESTRICT_LOCATORS_CODE := old_row.RESTRICT_LOCATORS_CODE; end if;
            if l_merged_row.RESTRICT_SUBINVENTORIES_CODE is null then l_merged_row.RESTRICT_SUBINVENTORIES_CODE := old_row.RESTRICT_SUBINVENTORIES_CODE; end if;
            if l_merged_row.RETEST_INTERVAL is null then l_merged_row.RETEST_INTERVAL := old_row.RETEST_INTERVAL; end if;
            if l_merged_row.RETURNABLE_FLAG is null then l_merged_row.RETURNABLE_FLAG := old_row.RETURNABLE_FLAG; end if;
            if l_merged_row.RETURN_INSPECTION_REQUIREMENT is null then l_merged_row.RETURN_INSPECTION_REQUIREMENT := old_row.RETURN_INSPECTION_REQUIREMENT; end if;
            if l_merged_row.REVISION is null then l_merged_row.REVISION := old_row.REVISION; end if;
            if l_merged_row.REVISION_IMPORT_POLICY is null then l_merged_row.REVISION_IMPORT_POLICY := old_row.REVISION_IMPORT_POLICY; end if;
            if l_merged_row.REVISION_QTY_CONTROL_CODE is null then l_merged_row.REVISION_QTY_CONTROL_CODE := old_row.REVISION_QTY_CONTROL_CODE; end if;
            if l_merged_row.RFQ_REQUIRED_FLAG is null then l_merged_row.RFQ_REQUIRED_FLAG := old_row.RFQ_REQUIRED_FLAG; end if;
            if l_merged_row.ROUNDING_CONTROL_TYPE is null then l_merged_row.ROUNDING_CONTROL_TYPE := old_row.ROUNDING_CONTROL_TYPE; end if;
            if l_merged_row.ROUNDING_FACTOR is null then l_merged_row.ROUNDING_FACTOR := old_row.ROUNDING_FACTOR; end if;
            if l_merged_row.SAFETY_STOCK_BUCKET_DAYS is null then l_merged_row.SAFETY_STOCK_BUCKET_DAYS := old_row.SAFETY_STOCK_BUCKET_DAYS; end if;
            if l_merged_row.SALES_ACCOUNT is null then l_merged_row.SALES_ACCOUNT := old_row.SALES_ACCOUNT; end if;
            if l_merged_row.SECONDARY_DEFAULT_IND is null then l_merged_row.SECONDARY_DEFAULT_IND := old_row.SECONDARY_DEFAULT_IND; end if;
            if l_merged_row.SECONDARY_SPECIALIST_ID is null then l_merged_row.SECONDARY_SPECIALIST_ID := old_row.SECONDARY_SPECIALIST_ID; end if;
            if l_merged_row.SECONDARY_UOM_CODE is null then l_merged_row.SECONDARY_UOM_CODE := old_row.SECONDARY_UOM_CODE; end if;
            if l_merged_row.SERIAL_NUMBER_CONTROL_CODE is null then l_merged_row.SERIAL_NUMBER_CONTROL_CODE := old_row.SERIAL_NUMBER_CONTROL_CODE; end if;
            if l_merged_row.SERIAL_STATUS_ENABLED is null then l_merged_row.SERIAL_STATUS_ENABLED := old_row.SERIAL_STATUS_ENABLED; end if;
            if l_merged_row.SERVICEABLE_COMPONENT_FLAG is null then l_merged_row.SERVICEABLE_COMPONENT_FLAG := old_row.SERVICEABLE_COMPONENT_FLAG; end if;
            if l_merged_row.SERVICEABLE_ITEM_CLASS_ID is null then l_merged_row.SERVICEABLE_ITEM_CLASS_ID := old_row.SERVICEABLE_ITEM_CLASS_ID; end if;
            if l_merged_row.SERVICEABLE_PRODUCT_FLAG is null then l_merged_row.SERVICEABLE_PRODUCT_FLAG := old_row.SERVICEABLE_PRODUCT_FLAG; end if;
            if l_merged_row.SERVICE_DURATION is null then l_merged_row.SERVICE_DURATION := old_row.SERVICE_DURATION; end if;
            if l_merged_row.SERVICE_DURATION_PERIOD_CODE is null then l_merged_row.SERVICE_DURATION_PERIOD_CODE := old_row.SERVICE_DURATION_PERIOD_CODE; end if;
            if l_merged_row.SERVICE_ITEM_FLAG is null then l_merged_row.SERVICE_ITEM_FLAG := old_row.SERVICE_ITEM_FLAG; end if;
            if l_merged_row.SERVICE_STARTING_DELAY is null then l_merged_row.SERVICE_STARTING_DELAY := old_row.SERVICE_STARTING_DELAY; end if;
            if l_merged_row.SERV_BILLING_ENABLED_FLAG is null then l_merged_row.SERV_BILLING_ENABLED_FLAG := old_row.SERV_BILLING_ENABLED_FLAG; end if;
            if l_merged_row.SERV_IMPORTANCE_LEVEL is null then l_merged_row.SERV_IMPORTANCE_LEVEL := old_row.SERV_IMPORTANCE_LEVEL; end if;
            if l_merged_row.SERV_REQ_ENABLED_CODE is null then l_merged_row.SERV_REQ_ENABLED_CODE := old_row.SERV_REQ_ENABLED_CODE; end if;
            if l_merged_row.SET_ID is null then l_merged_row.SET_ID := old_row.SET_ID; end if;
            if l_merged_row.SHELF_LIFE_CODE is null then l_merged_row.SHELF_LIFE_CODE := old_row.SHELF_LIFE_CODE; end if;
            if l_merged_row.SHELF_LIFE_DAYS is null then l_merged_row.SHELF_LIFE_DAYS := old_row.SHELF_LIFE_DAYS; end if;
            if l_merged_row.SHIPPABLE_ITEM_FLAG is null then l_merged_row.SHIPPABLE_ITEM_FLAG := old_row.SHIPPABLE_ITEM_FLAG; end if;
            if l_merged_row.SHIP_MODEL_COMPLETE_FLAG is null then l_merged_row.SHIP_MODEL_COMPLETE_FLAG := old_row.SHIP_MODEL_COMPLETE_FLAG; end if;
            if l_merged_row.SHRINKAGE_RATE is null then l_merged_row.SHRINKAGE_RATE := old_row.SHRINKAGE_RATE; end if;
            if l_merged_row.SOURCE_ORGANIZATION_ID is null then l_merged_row.SOURCE_ORGANIZATION_ID := old_row.SOURCE_ORGANIZATION_ID; end if;
            if l_merged_row.SOURCE_SUBINVENTORY is null then l_merged_row.SOURCE_SUBINVENTORY := old_row.SOURCE_SUBINVENTORY; end if;
            if l_merged_row.SOURCE_TYPE is null then l_merged_row.SOURCE_TYPE := old_row.SOURCE_TYPE; end if;
            if l_merged_row.SO_AUTHORIZATION_FLAG is null then l_merged_row.SO_AUTHORIZATION_FLAG := old_row.SO_AUTHORIZATION_FLAG; end if;
            if l_merged_row.SO_TRANSACTIONS_FLAG is null then l_merged_row.SO_TRANSACTIONS_FLAG := old_row.SO_TRANSACTIONS_FLAG; end if;
            if l_merged_row.START_AUTO_LOT_NUMBER is null then l_merged_row.START_AUTO_LOT_NUMBER := old_row.START_AUTO_LOT_NUMBER; end if;
            if l_merged_row.START_AUTO_SERIAL_NUMBER is null then l_merged_row.START_AUTO_SERIAL_NUMBER := old_row.START_AUTO_SERIAL_NUMBER; end if;
            if l_merged_row.START_DATE_ACTIVE is null then l_merged_row.START_DATE_ACTIVE := old_row.START_DATE_ACTIVE; end if;
            if l_merged_row.STD_LOT_SIZE is null then l_merged_row.STD_LOT_SIZE := old_row.STD_LOT_SIZE; end if;
            if l_merged_row.STOCK_ENABLED_FLAG is null then l_merged_row.STOCK_ENABLED_FLAG := old_row.STOCK_ENABLED_FLAG; end if;
            if l_merged_row.SUBCONTRACTING_COMPONENT is null then l_merged_row.SUBCONTRACTING_COMPONENT := old_row.SUBCONTRACTING_COMPONENT; end if;
            if l_merged_row.SUBSCRIPTION_DEPEND_FLAG is null then l_merged_row.SUBSCRIPTION_DEPEND_FLAG := old_row.SUBSCRIPTION_DEPEND_FLAG; end if;
            if l_merged_row.SUBSTITUTION_WINDOW_CODE is null then l_merged_row.SUBSTITUTION_WINDOW_CODE := old_row.SUBSTITUTION_WINDOW_CODE; end if;
            if l_merged_row.SUBSTITUTION_WINDOW_DAYS is null then l_merged_row.SUBSTITUTION_WINDOW_DAYS := old_row.SUBSTITUTION_WINDOW_DAYS; end if;
            if l_merged_row.SUMMARY_FLAG is null then l_merged_row.SUMMARY_FLAG := old_row.SUMMARY_FLAG; end if;
            if l_merged_row.TAXABLE_FLAG is null then l_merged_row.TAXABLE_FLAG := old_row.TAXABLE_FLAG; end if;
            if l_merged_row.TAX_CODE is null then l_merged_row.TAX_CODE := old_row.TAX_CODE; end if;
            if l_merged_row.TIME_BILLABLE_FLAG is null then l_merged_row.TIME_BILLABLE_FLAG := old_row.TIME_BILLABLE_FLAG; end if;
            if l_merged_row.TRACKING_QUANTITY_IND is null then l_merged_row.TRACKING_QUANTITY_IND := old_row.TRACKING_QUANTITY_IND; end if;
            if l_merged_row.TRANSACTION_ID is null then l_merged_row.TRANSACTION_ID := old_row.TRANSACTION_ID; end if;
            if l_merged_row.UNDER_RETURN_TOLERANCE is null then l_merged_row.UNDER_RETURN_TOLERANCE := old_row.UNDER_RETURN_TOLERANCE; end if;
            if l_merged_row.UNDER_SHIPMENT_TOLERANCE is null then l_merged_row.UNDER_SHIPMENT_TOLERANCE := old_row.UNDER_SHIPMENT_TOLERANCE; end if;
            if l_merged_row.UNIT_HEIGHT is null then l_merged_row.UNIT_HEIGHT := old_row.UNIT_HEIGHT; end if;
            if l_merged_row.UNIT_LENGTH is null then l_merged_row.UNIT_LENGTH := old_row.UNIT_LENGTH; end if;
            if l_merged_row.UNIT_OF_ISSUE is null then l_merged_row.UNIT_OF_ISSUE := old_row.UNIT_OF_ISSUE; end if;
            if l_merged_row.UNIT_VOLUME is null then l_merged_row.UNIT_VOLUME := old_row.UNIT_VOLUME; end if;
            if l_merged_row.UNIT_WEIGHT is null then l_merged_row.UNIT_WEIGHT := old_row.UNIT_WEIGHT; end if;
            if l_merged_row.UNIT_WIDTH is null then l_merged_row.UNIT_WIDTH := old_row.UNIT_WIDTH; end if;
            if l_merged_row.UN_NUMBER_ID is null then l_merged_row.UN_NUMBER_ID := old_row.UN_NUMBER_ID; end if;
            if l_merged_row.USAGE_ITEM_FLAG is null then l_merged_row.USAGE_ITEM_FLAG := old_row.USAGE_ITEM_FLAG; end if;
            if l_merged_row.VARIABLE_LEAD_TIME is null then l_merged_row.VARIABLE_LEAD_TIME := old_row.VARIABLE_LEAD_TIME; end if;
            if l_merged_row.VEHICLE_ITEM_FLAG is null then l_merged_row.VEHICLE_ITEM_FLAG := old_row.VEHICLE_ITEM_FLAG; end if;
            if l_merged_row.VENDOR_WARRANTY_FLAG is null then l_merged_row.VENDOR_WARRANTY_FLAG := old_row.VENDOR_WARRANTY_FLAG; end if;
            if l_merged_row.VMI_FIXED_ORDER_QUANTITY is null then l_merged_row.VMI_FIXED_ORDER_QUANTITY := old_row.VMI_FIXED_ORDER_QUANTITY; end if;
            if l_merged_row.VMI_FORECAST_TYPE is null then l_merged_row.VMI_FORECAST_TYPE := old_row.VMI_FORECAST_TYPE; end if;
            if l_merged_row.VMI_MAXIMUM_DAYS is null then l_merged_row.VMI_MAXIMUM_DAYS := old_row.VMI_MAXIMUM_DAYS; end if;
            if l_merged_row.VMI_MAXIMUM_UNITS is null then l_merged_row.VMI_MAXIMUM_UNITS := old_row.VMI_MAXIMUM_UNITS; end if;
            if l_merged_row.VMI_MINIMUM_DAYS is null then l_merged_row.VMI_MINIMUM_DAYS := old_row.VMI_MINIMUM_DAYS; end if;
            if l_merged_row.VMI_MINIMUM_UNITS is null then l_merged_row.VMI_MINIMUM_UNITS := old_row.VMI_MINIMUM_UNITS; end if;
            if l_merged_row.VOLUME_UOM_CODE is null then l_merged_row.VOLUME_UOM_CODE := old_row.VOLUME_UOM_CODE; end if;
            if l_merged_row.VOL_DISCOUNT_EXEMPT_FLAG is null then l_merged_row.VOL_DISCOUNT_EXEMPT_FLAG := old_row.VOL_DISCOUNT_EXEMPT_FLAG; end if;
            if l_merged_row.WARRANTY_VENDOR_ID is null then l_merged_row.WARRANTY_VENDOR_ID := old_row.WARRANTY_VENDOR_ID; end if;
            if l_merged_row.WEB_STATUS is null then l_merged_row.WEB_STATUS := old_row.WEB_STATUS; end if;
            if l_merged_row.WEIGHT_UOM_CODE is null then l_merged_row.WEIGHT_UOM_CODE := old_row.WEIGHT_UOM_CODE; end if;
            if l_merged_row.WH_UPDATE_DATE is null then l_merged_row.WH_UPDATE_DATE := old_row.WH_UPDATE_DATE; end if;
            if l_merged_row.WIP_SUPPLY_LOCATOR_ID is null then l_merged_row.WIP_SUPPLY_LOCATOR_ID := old_row.WIP_SUPPLY_LOCATOR_ID; end if;
            if l_merged_row.WIP_SUPPLY_SUBINVENTORY is null then l_merged_row.WIP_SUPPLY_SUBINVENTORY := old_row.WIP_SUPPLY_SUBINVENTORY; end if;
            if l_merged_row.WIP_SUPPLY_TYPE is null then l_merged_row.WIP_SUPPLY_TYPE := old_row.WIP_SUPPLY_TYPE; end if;
            -- end generated code
        END LOOP; -- over old rows

        Debug_Conc_Log( l_proc_log_prefix || 'Total rows requiring merging = ' || c_target_rows%ROWCOUNT );
        IF c_target_rows%ISOPEN THEN
            CLOSE c_target_rows;
        END IF;

        IF l_merged_rows IS NOT NULL THEN
            -- delete
            Debug_Conc_Log( l_proc_log_prefix || 'Deleting ' || l_old_rowids.COUNT || ' old rows ...' );
            FORALL rid_ix IN INDICES OF l_old_rowids
                DELETE FROM MTL_SYSTEM_ITEMS_INTERFACE
                    WHERE ROWID = l_old_rowids( rid_ix );
            -- insert
            Debug_Conc_Log( l_proc_log_prefix || 'Inserting ' || l_merged_rows.COUNT || ' merged rows ...' );
            FORALL row_index IN INDICES OF l_merged_rows
                INSERT INTO MTL_SYSTEM_ITEMS_INTERFACE
                    VALUES l_merged_rows( row_index );
        END IF;
        Debug_Conc_Log( l_proc_log_prefix || 'Exiting' );
    EXCEPTION WHEN OTHERS THEN
        Debug_Conc_Log( l_proc_log_prefix || 'Error - ' || SQLERRM);
        IF c_target_rows%ISOPEN THEN
            CLOSE c_target_rows;
        END IF;
        RAISE;
    END Merge_Items_For_Import;

    -- Merges Item Revision records
    PROCEDURE Merge_Revs_For_Import( p_batch_id       IN NUMBER
                                   , p_master_org_id  IN NUMBER
                                   )
    IS
        SUBTYPE MIRI_ROW   IS MTL_ITEM_REVISIONS_INTERFACE%ROWTYPE;
        TYPE MIRI_ROWS  IS TABLE OF MIRI_ROW INDEX BY BINARY_INTEGER;

        /*
         * Note that the organization_id column is filled in from the organization_code and batch organization_id
         *   as part of resolve_ssxref_on_data_load
         * revision column is filled in from the revision_id before this cursor is fetched.
         */
        CURSOR c_target_revs IS
          SELECT *
          FROM
            (SELECT
              ROWID rid,
              COUNT( * ) OVER ( PARTITION BY ITEM_NUMBER, ORGANIZATION_ID, REVISION ) cnt,
              RANK() OVER ( ORDER BY ITEM_NUMBER, ORGANIZATION_ID, REVISION ) rnk,
              miri.*
            FROM MTL_ITEM_REVISIONS_INTERFACE miri
            WHERE PROCESS_FLAG   = 1
              AND SET_PROCESS_ID = p_batch_id
              AND ITEM_NUMBER IS NOT NULL
              AND ORGANIZATION_ID IS NOT NULL
              AND REVISION IS NOT NULL
              AND EXISTS
                  (SELECT NULL
                   FROM MTL_PARAMETERS mp
                   WHERE mp.ORGANIZATION_ID        = miri.ORGANIZATION_ID
                     AND mp.MASTER_ORGANIZATION_ID = p_master_org_id
                  )
            ) sub
          WHERE sub.cnt > 1
          ORDER BY rnk, last_update_date DESC NULLS LAST, interface_table_unique_id DESC NULLS LAST;

        TYPE TARGET_ROWS    IS TABLE OF c_target_revs%ROWTYPE;

        l_merged_rows   MIRI_ROWS;
        l_new_rows      MIRI_ROWS;
        l_merged_row    MIRI_ROW;
        l_old_rows      TARGET_ROWS;
        l_old_rowids    UROWID_TABLE;

        l_candidate_trans MTL_ITEM_REVISIONS_INTERFACE.TRANSACTION_TYPE%TYPE;

        l_mrow_ix       PLS_INTEGER := 0;
        l_new_row_idx   PLS_INTEGER := 0;
        l_cur_rank      PLS_INTEGER := 0; -- because rank() starts at 1

        l_proc_log_prefix CONSTANT VARCHAR2(30) := 'Merge_Revs_For_Import - ';
    BEGIN
        Debug_Conc_Log( l_proc_log_prefix || 'Entering' );
        Debug_Conc_Log( l_proc_log_prefix || 'Batch ID: ' || p_batch_id );

        UPDATE MTL_ITEM_REVISIONS_INTERFACE miri
            SET REVISION = NVL( (   SELECT r.REVISION
                                    FROM MTL_ITEM_REVISIONS_B r
                                    WHERE r.REVISION_ID       = miri.REVISION_ID
                                      AND r.ORGANIZATION_ID   = miri.ORGANIZATION_ID
                                )
                              , REVISION
                              )
        WHERE REVISION_ID IS NOT NULL
          AND SET_PROCESS_ID = p_batch_id
          AND PROCESS_FLAG = 1
          AND REVISION IS NULL;

        UPDATE MTL_ITEM_REVISIONS_INTERFACE miri
        SET ITEM_NUMBER = (SELECT CONCATENATED_SEGMENTS
                           FROM MTL_SYSTEM_ITEMS_KFV
                           WHERE INVENTORY_ITEM_ID = miri.INVENTORY_ITEM_ID
                             AND ORGANIZATION_ID = miri.ORGANIZATION_ID)
        WHERE SET_PROCESS_ID = p_batch_id
          AND PROCESS_FLAG = 1
          AND INVENTORY_ITEM_ID IS NOT NULL
          AND ITEM_NUMBER IS NULL;

        OPEN c_target_revs;
        FETCH c_target_revs BULK COLLECT INTO l_old_rows;
        CLOSE c_target_revs;

        Debug_Conc_Log( l_proc_log_prefix || 'Total rows requiring merging = ' || l_old_rows.COUNT );
        IF 0 <>  l_old_rows.COUNT THEN
            l_old_rowids := UROWID_TABLE( );
            l_old_rowids.EXTEND( l_old_rows.COUNT );

            FOR idx IN l_old_rows.FIRST .. l_old_rows.LAST LOOP
                l_old_rowids( idx ) := l_old_rows( idx ).RID;

                IF ( l_cur_rank <> l_old_rows( idx ).RNK )
                THEN
                    IF l_new_row_idx > 0 THEN
                        FOR i IN 1..l_new_row_idx LOOP
                            Debug_Conc_Log( l_proc_log_prefix || '  Creating merged record for SSR, SS-ID = ' ||
                                                                 l_new_rows( i ).SOURCE_SYSTEM_REFERENCE || ', ' ||
                                                                 l_new_rows( i ).SOURCE_SYSTEM_ID);
                            l_mrow_ix := l_mrow_ix + 1;
                            l_merged_rows( l_mrow_ix )                           := l_merged_row;
                            l_merged_rows( l_mrow_ix ).SET_PROCESS_ID            := l_new_rows( i ).SET_PROCESS_ID;
                            l_merged_rows( l_mrow_ix ).PROCESS_FLAG              := l_new_rows( i ).PROCESS_FLAG;
                            l_merged_rows( l_mrow_ix ).SOURCE_SYSTEM_ID          := l_new_rows( i ).SOURCE_SYSTEM_ID;
                            l_merged_rows( l_mrow_ix ).SOURCE_SYSTEM_REFERENCE   := l_new_rows( i ).SOURCE_SYSTEM_REFERENCE;
                            l_merged_rows( l_mrow_ix ).CREATED_BY                := l_new_rows( i ).CREATED_BY;
                            l_merged_rows( l_mrow_ix ).LAST_UPDATED_BY           := l_new_rows( i ).LAST_UPDATED_BY;
                            l_merged_rows( l_mrow_ix ).REQUEST_ID                := FND_GLOBAL.CONC_REQUEST_ID;
                            l_merged_rows( l_mrow_ix ).PROGRAM_APPLICATION_ID    := FND_GLOBAL.PROG_APPL_ID;
                            l_merged_rows( l_mrow_ix ).PROGRAM_ID                := FND_GLOBAL.CONC_PROGRAM_ID;
                            l_merged_rows( l_mrow_ix ).PROGRAM_UPDATE_DATE       := SYSDATE;
                        END LOOP; --FOR i IN 1..l_new_row_idx LOOP
                    END IF; --IF l_new_row_idx > 0 THEN
                    l_cur_rank := l_old_rows( idx ).RNK;
                    Debug_Conc_Log( l_proc_log_prefix || '  Starting new merged row; rank = '|| l_cur_rank );
                    Debug_Conc_Log( l_proc_log_prefix || '    Item, Org-ID, Item-ID, Revision = ' ||
                                                         l_old_rows( idx ).ITEM_NUMBER || ', ' ||
                                                         l_old_rows( idx ).ORGANIZATION_ID || ', ' ||
                                                         l_old_rows( idx ).INVENTORY_ITEM_ID || ', ' ||
                                                         l_old_rows( idx ).REVISION);
                    l_new_rows.DELETE;
                    l_new_row_idx := 1;
                    l_new_rows( l_new_row_idx ).PROCESS_FLAG              := l_old_rows( idx ).PROCESS_FLAG;
                    -- initializing l_merged_row . This row will contain the current merged row for an item
                    l_merged_row := NULL;
                    l_merged_row.SET_PROCESS_ID            := p_batch_id;
                    l_merged_row.PROCESS_FLAG              := l_old_rows( idx ).PROCESS_FLAG;
                ELSE
                    Debug_Conc_Log( l_proc_log_prefix || '  Merging another record into current merged row; rank = '|| l_cur_rank );
                    Debug_Conc_Log( l_proc_log_prefix || '    Item, Org-ID, Item-ID, Revision = ' ||
                                                         l_old_rows( idx ).ITEM_NUMBER || ', ' ||
                                                         l_old_rows( idx ).ORGANIZATION_ID || ', ' ||
                                                         l_old_rows( idx ).INVENTORY_ITEM_ID || ', ' ||
                                                         l_old_rows( idx ).REVISION);
                    l_new_row_idx := l_new_row_idx + 1;
                    l_new_rows( l_new_row_idx ).PROCESS_FLAG              := 111;
                END IF;

                l_new_rows( l_new_row_idx ).SET_PROCESS_ID            := p_batch_id;
                l_new_rows( l_new_row_idx ).SOURCE_SYSTEM_ID          := l_old_rows( idx ).SOURCE_SYSTEM_ID;
                l_new_rows( l_new_row_idx ).SOURCE_SYSTEM_REFERENCE   := l_old_rows( idx ).SOURCE_SYSTEM_REFERENCE;
                l_new_rows( l_new_row_idx ).CREATED_BY                := l_old_rows( idx ).CREATED_BY;
                l_new_rows( l_new_row_idx ).LAST_UPDATED_BY           := l_old_rows( idx ).LAST_UPDATED_BY;

                -- Special Cases:
                -- Transaction type
                l_candidate_trans := UPPER( l_old_rows( idx ).TRANSACTION_TYPE );

                IF      l_merged_row.TRANSACTION_TYPE IS NULL
                    OR  l_merged_row.TRANSACTION_TYPE <> l_candidate_trans -- <> filters out nulls
                THEN
                    -- CREATE > SYNC > UPDATE : order of case expression matters
                    l_merged_row.TRANSACTION_TYPE :=
                        CASE
                            WHEN l_merged_row.TRANSACTION_TYPE = G_TRANS_TYPE_CREATE
                              OR l_candidate_trans = G_TRANS_TYPE_CREATE                            THEN G_TRANS_TYPE_CREATE
                            WHEN l_merged_row.TRANSACTION_TYPE = G_TRANS_TYPE_SYNC
                              OR l_candidate_trans = G_TRANS_TYPE_SYNC                              THEN G_TRANS_TYPE_SYNC
                            WHEN l_merged_row.TRANSACTION_TYPE = G_TRANS_TYPE_UPDATE
                              OR l_candidate_trans = G_TRANS_TYPE_UPDATE                            THEN G_TRANS_TYPE_UPDATE
                            ELSE NULL -- INVALID transaction types encountered ...
                        END;
                END IF;

                -- The following columns need to be treated as atomic groups
                -- 1. Item Identifier
                IF      l_merged_row.INVENTORY_ITEM_ID  IS NULL
                    AND l_merged_row.ITEM_NUMBER        IS NULL
                THEN
                    l_merged_row.INVENTORY_ITEM_ID  := l_old_rows( idx ).INVENTORY_ITEM_ID;
                    l_merged_row.ITEM_NUMBER        := l_old_rows( idx ).ITEM_NUMBER;
                END IF;

                -- 2. Organization
                IF      l_merged_row.ORGANIZATION_ID    IS NULL
                    AND l_merged_row.ORGANIZATION_CODE  IS NULL
                THEN
                    l_merged_row.ORGANIZATION_ID        := l_old_rows( idx ).ORGANIZATION_ID;
                    l_merged_row.ORGANIZATION_CODE      := l_old_rows( idx ).ORGANIZATION_CODE;
                END IF;

                -- 3. Template Identifier
                IF      l_merged_row.TEMPLATE_ID        IS NULL
                    AND l_merged_row.TEMPLATE_NAME      IS NULL
                THEN
                    l_merged_row.TEMPLATE_ID    := l_old_rows( idx ).TEMPLATE_ID ;
                    l_merged_row.TEMPLATE_NAME  := l_old_rows( idx ).TEMPLATE_NAME ;
                END IF;

                -- Non-special cased
                if l_merged_row.ATTRIBUTE1 is null then l_merged_row.ATTRIBUTE1 := l_old_rows( idx ).ATTRIBUTE1; end if;
                if l_merged_row.ATTRIBUTE10 is null then l_merged_row.ATTRIBUTE10 := l_old_rows( idx ).ATTRIBUTE10; end if;
                if l_merged_row.ATTRIBUTE11 is null then l_merged_row.ATTRIBUTE11 := l_old_rows( idx ).ATTRIBUTE11; end if;
                if l_merged_row.ATTRIBUTE12 is null then l_merged_row.ATTRIBUTE12 := l_old_rows( idx ).ATTRIBUTE12; end if;
                if l_merged_row.ATTRIBUTE13 is null then l_merged_row.ATTRIBUTE13 := l_old_rows( idx ).ATTRIBUTE13; end if;
                if l_merged_row.ATTRIBUTE14 is null then l_merged_row.ATTRIBUTE14 := l_old_rows( idx ).ATTRIBUTE14; end if;
                if l_merged_row.ATTRIBUTE15 is null then l_merged_row.ATTRIBUTE15 := l_old_rows( idx ).ATTRIBUTE15; end if;
                if l_merged_row.ATTRIBUTE2 is null then l_merged_row.ATTRIBUTE2 := l_old_rows( idx ).ATTRIBUTE2; end if;
                if l_merged_row.ATTRIBUTE3 is null then l_merged_row.ATTRIBUTE3 := l_old_rows( idx ).ATTRIBUTE3; end if;
                if l_merged_row.ATTRIBUTE4 is null then l_merged_row.ATTRIBUTE4 := l_old_rows( idx ).ATTRIBUTE4; end if;
                if l_merged_row.ATTRIBUTE5 is null then l_merged_row.ATTRIBUTE5 := l_old_rows( idx ).ATTRIBUTE5; end if;
                if l_merged_row.ATTRIBUTE6 is null then l_merged_row.ATTRIBUTE6 := l_old_rows( idx ).ATTRIBUTE6; end if;
                if l_merged_row.ATTRIBUTE7 is null then l_merged_row.ATTRIBUTE7 := l_old_rows( idx ).ATTRIBUTE7; end if;
                if l_merged_row.ATTRIBUTE8 is null then l_merged_row.ATTRIBUTE8 := l_old_rows( idx ).ATTRIBUTE8; end if;
                if l_merged_row.ATTRIBUTE9 is null then l_merged_row.ATTRIBUTE9 := l_old_rows( idx ).ATTRIBUTE9; end if;
                if l_merged_row.ATTRIBUTE_CATEGORY is null then l_merged_row.ATTRIBUTE_CATEGORY := l_old_rows( idx ).ATTRIBUTE_CATEGORY; end if;
                if l_merged_row.CHANGE_ID is null then l_merged_row.CHANGE_ID := l_old_rows( idx ).CHANGE_ID; end if;
                if l_merged_row.CHANGE_NOTICE is null then l_merged_row.CHANGE_NOTICE := l_old_rows( idx ).CHANGE_NOTICE; end if;
                if l_merged_row.CURRENT_PHASE_ID is null then l_merged_row.CURRENT_PHASE_ID := l_old_rows( idx ).CURRENT_PHASE_ID; end if;
                if l_merged_row.DESCRIPTION is null then l_merged_row.DESCRIPTION := l_old_rows( idx ).DESCRIPTION; end if;
                if l_merged_row.ECN_INITIATION_DATE is null then l_merged_row.ECN_INITIATION_DATE := l_old_rows( idx ).ECN_INITIATION_DATE; end if;
                if l_merged_row.EFFECTIVITY_DATE is null then l_merged_row.EFFECTIVITY_DATE := l_old_rows( idx ).EFFECTIVITY_DATE; end if;
                if l_merged_row.IMPLEMENTATION_DATE is null then l_merged_row.IMPLEMENTATION_DATE := l_old_rows( idx ).IMPLEMENTATION_DATE; end if;
                if l_merged_row.IMPLEMENTED_SERIAL_NUMBER is null then l_merged_row.IMPLEMENTED_SERIAL_NUMBER := l_old_rows( idx ).IMPLEMENTED_SERIAL_NUMBER; end if;
                if l_merged_row.LIFECYCLE_ID is null then l_merged_row.LIFECYCLE_ID := l_old_rows( idx ).LIFECYCLE_ID; end if;
                if l_merged_row.REVISED_ITEM_SEQUENCE_ID is null then l_merged_row.REVISED_ITEM_SEQUENCE_ID := l_old_rows( idx ).REVISED_ITEM_SEQUENCE_ID; end if;
                if l_merged_row.REVISION is null then l_merged_row.REVISION := l_old_rows( idx ).REVISION; end if;
                if l_merged_row.REVISION_ID is null then l_merged_row.REVISION_ID := l_old_rows( idx ).REVISION_ID; end if;
                if l_merged_row.REVISION_LABEL is null then l_merged_row.REVISION_LABEL := l_old_rows( idx ).REVISION_LABEL; end if;
                if l_merged_row.REVISION_REASON is null then l_merged_row.REVISION_REASON := l_old_rows( idx ).REVISION_REASON; end if;
                if l_merged_row.TRANSACTION_ID is null then l_merged_row.TRANSACTION_ID := l_old_rows( idx ).TRANSACTION_ID; end if;

                IF idx = l_old_rows.LAST AND l_new_row_idx > 0 THEN
                    FOR i IN 1..l_new_row_idx LOOP
                        Debug_Conc_Log( l_proc_log_prefix || '  No More records found for processing.');
                        Debug_Conc_Log( l_proc_log_prefix || '  Creating merged record for SSR, SS-ID = ' ||
                                                             l_new_rows( i ).SOURCE_SYSTEM_REFERENCE || ', ' ||
                                                             l_new_rows( i ).SOURCE_SYSTEM_ID);
                        l_mrow_ix := l_mrow_ix + 1;
                        l_merged_rows( l_mrow_ix )                           := l_merged_row;
                        l_merged_rows( l_mrow_ix ).SET_PROCESS_ID            := l_new_rows( i ).SET_PROCESS_ID;
                        l_merged_rows( l_mrow_ix ).PROCESS_FLAG              := l_new_rows( i ).PROCESS_FLAG;
                        l_merged_rows( l_mrow_ix ).SOURCE_SYSTEM_ID          := l_new_rows( i ).SOURCE_SYSTEM_ID;
                        l_merged_rows( l_mrow_ix ).SOURCE_SYSTEM_REFERENCE   := l_new_rows( i ).SOURCE_SYSTEM_REFERENCE;
                        l_merged_rows( l_mrow_ix ).CREATED_BY                := l_new_rows( i ).CREATED_BY;
                        l_merged_rows( l_mrow_ix ).LAST_UPDATED_BY           := l_new_rows( i ).LAST_UPDATED_BY;
                        l_merged_rows( l_mrow_ix ).REQUEST_ID                := FND_GLOBAL.CONC_REQUEST_ID;
                        l_merged_rows( l_mrow_ix ).PROGRAM_APPLICATION_ID    := FND_GLOBAL.PROG_APPL_ID;
                        l_merged_rows( l_mrow_ix ).PROGRAM_ID                := FND_GLOBAL.CONC_PROGRAM_ID;
                        l_merged_rows( l_mrow_ix ).PROGRAM_UPDATE_DATE       := SYSDATE;
                    END LOOP; --FOR i IN 1..l_new_row_idx LOOP
                END IF; --IF idx = l_old_rows.LAST AND l_new_row_idx > 0 THEN
            END LOOP; -- loop over old rows

            IF l_merged_rows IS NOT NULL THEN
                -- delete
                Debug_Conc_Log( l_proc_log_prefix || 'Deleting ' || l_old_rowids.COUNT || ' old rows ...' );
                FORALL rid_ix IN INDICES OF l_old_rowids
                    DELETE FROM MTL_ITEM_REVISIONS_INTERFACE
                        WHERE ROWID = l_old_rowids( rid_ix );
                -- insert
                Debug_Conc_Log( l_proc_log_prefix || 'Inserting ' || l_merged_rows.COUNT || ' merged rows ...' );
                FORALL row_index IN INDICES OF l_merged_rows
                    INSERT INTO MTL_ITEM_REVISIONS_INTERFACE
                        VALUES l_merged_rows( row_index );
            END IF;
        END IF; -- ENDS IF l_old_rows.count <> 0
        Debug_Conc_Log( l_proc_log_prefix || 'Exiting' );
    EXCEPTION WHEN OTHERS THEN
        Debug_Conc_Log( l_proc_log_prefix || 'Error - ' || SQLERRM);
        IF c_target_revs%ISOPEN THEN
            CLOSE c_target_revs;
        END IF;
        RAISE;
    END Merge_Revs_For_Import;

    -- Merges Item Category assignments
    PROCEDURE Merge_Categories_For_Import( p_batch_id       IN NUMBER
                                         , p_master_org_id  IN NUMBER
                                         )
    IS
        SUBTYPE MICI_ROW   IS MTL_ITEM_CATEGORIES_INTERFACE%ROWTYPE;
        TYPE MICI_ROWS  IS TABLE OF MICI_ROW INDEX BY BINARY_INTEGER;

        /*
         * Note that the organization_id column is filled in from the organization_code and batch organization_id
         *   as part of resolve_ssxref_on_data_load
         */
        CURSOR c_target_categories IS
          SELECT *
          FROM
            (SELECT
              ROWID rid,
              COUNT( * ) OVER ( PARTITION BY ITEM_NUMBER, ORGANIZATION_ID, CATEGORY_SET_NAME, CATEGORY_NAME ) cnt,
              RANK() OVER ( ORDER BY ITEM_NUMBER, ORGANIZATION_ID, CATEGORY_SET_NAME, CATEGORY_NAME ) rnk,
              mici.*
            FROM MTL_ITEM_CATEGORIES_INTERFACE mici
            WHERE PROCESS_FLAG   = 1
              AND SET_PROCESS_ID = p_batch_id
              AND ITEM_NUMBER IS NOT NULL
              AND ORGANIZATION_ID IS NOT NULL
              AND CATEGORY_SET_NAME IS NOT NULL
              AND CATEGORY_NAME IS NOT NULL
              AND EXISTS
                  (SELECT NULL
                   FROM MTL_PARAMETERS mp
                   WHERE mp.ORGANIZATION_ID        = mici.ORGANIZATION_ID
                     AND mp.MASTER_ORGANIZATION_ID = p_master_org_id
                  )
            ) sub
          WHERE sub.cnt > 1
          ORDER BY rnk, last_update_date DESC NULLS LAST;

        TYPE TARGET_ROWS    IS TABLE OF c_target_categories%ROWTYPE;

        l_merged_rows   MICI_ROWS;
        l_new_rows      MICI_ROWS;
        l_merged_row    MICI_ROW;
        l_old_rows      TARGET_ROWS;
        l_old_rowids    UROWID_TABLE;

        l_candidate_trans MTL_ITEM_CATEGORIES_INTERFACE.TRANSACTION_TYPE%TYPE;

        l_mrow_ix       PLS_INTEGER := 0;
        l_new_row_idx   PLS_INTEGER := 0;
        l_cur_rank      PLS_INTEGER := 0; -- because rank() starts at 1

        l_proc_log_prefix CONSTANT VARCHAR2(50) := 'Merge_Categories_For_Import - ';
    BEGIN
        Debug_Conc_Log( l_proc_log_prefix || 'Entering' );
        Debug_Conc_Log( l_proc_log_prefix || 'Batch ID: ' || p_batch_id );

        UPDATE MTL_ITEM_CATEGORIES_INTERFACE mici
            SET CATEGORY_SET_NAME = NVL( mici.CATEGORY_SET_NAME,
                                         ( SELECT mcs.CATEGORY_SET_NAME
                                           FROM MTL_CATEGORY_SETS mcs
                                           WHERE mcs.CATEGORY_SET_ID     = mici.CATEGORY_SET_ID
                                         )
                                       ),
                CATEGORY_NAME     = NVL( mici.CATEGORY_NAME,
                                         ( SELECT mc.CONCATENATED_SEGMENTS
                                           FROM MTL_CATEGORIES_KFV mc
                                           WHERE mc.CATEGORY_ID     = mici.CATEGORY_ID
                                         )
                                       )
        WHERE ( ( CATEGORY_NAME IS NULL AND CATEGORY_ID IS NOT NULL )
             OR ( CATEGORY_SET_NAME IS NULL AND CATEGORY_SET_ID IS NOT NULL )
              )
          AND SET_PROCESS_ID = p_batch_id
          AND PROCESS_FLAG = 1;

        UPDATE MTL_ITEM_CATEGORIES_INTERFACE mici
        SET ITEM_NUMBER = (SELECT CONCATENATED_SEGMENTS
                           FROM MTL_SYSTEM_ITEMS_KFV
                           WHERE INVENTORY_ITEM_ID = mici.INVENTORY_ITEM_ID
                             AND ORGANIZATION_ID = mici.ORGANIZATION_ID)
        WHERE SET_PROCESS_ID = p_batch_id
          AND PROCESS_FLAG = 1
          AND INVENTORY_ITEM_ID IS NOT NULL
          AND ITEM_NUMBER IS NULL;

        OPEN c_target_categories;
        FETCH c_target_categories BULK COLLECT INTO l_old_rows;
        CLOSE c_target_categories;

        Debug_Conc_Log( l_proc_log_prefix || 'Total rows requiring merging = ' || l_old_rows.COUNT );
        IF 0 <>  l_old_rows.COUNT THEN
            l_old_rowids := UROWID_TABLE( );
            l_old_rowids.EXTEND( l_old_rows.COUNT );

            FOR idx IN l_old_rows.FIRST .. l_old_rows.LAST LOOP
                l_old_rowids( idx ) := l_old_rows( idx ).RID;

                IF ( l_cur_rank <> l_old_rows( idx ).RNK )
                THEN
                    IF l_new_row_idx > 0 THEN
                        FOR i IN 1..l_new_row_idx LOOP
                            Debug_Conc_Log( l_proc_log_prefix || '  Creating merged record for SSR, SS-ID = ' ||
                                                                 l_new_rows( i ).SOURCE_SYSTEM_REFERENCE || ', ' ||
                                                                 l_new_rows( i ).SOURCE_SYSTEM_ID);
                            l_mrow_ix := l_mrow_ix + 1;
                            l_merged_rows( l_mrow_ix )                           := l_merged_row;
                            l_merged_rows( l_mrow_ix ).SET_PROCESS_ID            := l_new_rows( i ).SET_PROCESS_ID;
                            l_merged_rows( l_mrow_ix ).PROCESS_FLAG              := l_new_rows( i ).PROCESS_FLAG;
                            l_merged_rows( l_mrow_ix ).SOURCE_SYSTEM_ID          := l_new_rows( i ).SOURCE_SYSTEM_ID;
                            l_merged_rows( l_mrow_ix ).SOURCE_SYSTEM_REFERENCE   := l_new_rows( i ).SOURCE_SYSTEM_REFERENCE;
                            l_merged_rows( l_mrow_ix ).CREATED_BY                := l_new_rows( i ).CREATED_BY;
                            l_merged_rows( l_mrow_ix ).LAST_UPDATED_BY           := l_new_rows( i ).LAST_UPDATED_BY;
                            l_merged_rows( l_mrow_ix ).REQUEST_ID                := FND_GLOBAL.CONC_REQUEST_ID;
                            l_merged_rows( l_mrow_ix ).PROGRAM_APPLICATION_ID    := FND_GLOBAL.PROG_APPL_ID;
                            l_merged_rows( l_mrow_ix ).PROGRAM_ID                := FND_GLOBAL.CONC_PROGRAM_ID;
                            l_merged_rows( l_mrow_ix ).PROGRAM_UPDATE_DATE       := SYSDATE;
                        END LOOP; --FOR i IN 1..l_new_row_idx LOOP
                    END IF; --IF l_new_row_idx > 0 THEN
                    l_cur_rank := l_old_rows( idx ).RNK;
                    Debug_Conc_Log( l_proc_log_prefix || '  Starting new merged row; rank = '|| l_cur_rank );
                    Debug_Conc_Log( l_proc_log_prefix || '    Item, Org-ID, Item-ID, Cat-Set, Cat = ' ||
                                                         l_old_rows( idx ).ITEM_NUMBER || ', ' ||
                                                         l_old_rows( idx ).ORGANIZATION_ID || ', ' ||
                                                         l_old_rows( idx ).INVENTORY_ITEM_ID || ', ' ||
                                                         l_old_rows( idx ).CATEGORY_SET_NAME || ', ' ||
                                                         l_old_rows( idx ).CATEGORY_NAME);
                    l_new_rows.DELETE;
                    l_new_row_idx := 1;
                    l_new_rows( l_new_row_idx ).PROCESS_FLAG              := l_old_rows( idx ).PROCESS_FLAG;
                    -- initializing l_merged_row . This row will contain the current merged row for an item
                    l_merged_row := NULL;
                    l_merged_row.SET_PROCESS_ID            := p_batch_id;
                    l_merged_row.PROCESS_FLAG              := l_old_rows( idx ).PROCESS_FLAG;
                ELSE
                    Debug_Conc_Log( l_proc_log_prefix || '  Merging another record into current merged row; rank = '|| l_cur_rank );
                    Debug_Conc_Log( l_proc_log_prefix || '    Item, Org-ID, Item-ID, Cat-Set, Cat = ' ||
                                                         l_old_rows( idx ).ITEM_NUMBER || ', ' ||
                                                         l_old_rows( idx ).ORGANIZATION_ID || ', ' ||
                                                         l_old_rows( idx ).INVENTORY_ITEM_ID || ', ' ||
                                                         l_old_rows( idx ).CATEGORY_SET_NAME || ', ' ||
                                                         l_old_rows( idx ).CATEGORY_NAME);
                    l_new_row_idx := l_new_row_idx + 1;
                    l_new_rows( l_new_row_idx ).PROCESS_FLAG              := 111;
                END IF;

                l_new_rows( l_new_row_idx ).SET_PROCESS_ID            := p_batch_id;
                l_new_rows( l_new_row_idx ).SOURCE_SYSTEM_ID          := l_old_rows( idx ).SOURCE_SYSTEM_ID;
                l_new_rows( l_new_row_idx ).SOURCE_SYSTEM_REFERENCE   := l_old_rows( idx ).SOURCE_SYSTEM_REFERENCE;
                l_new_rows( l_new_row_idx ).CREATED_BY                := l_old_rows( idx ).CREATED_BY;
                l_new_rows( l_new_row_idx ).LAST_UPDATED_BY           := l_old_rows( idx ).LAST_UPDATED_BY;

                -- Special Cases:
                -- Transaction type
                l_candidate_trans := UPPER( l_old_rows( idx ).TRANSACTION_TYPE );

                IF      l_merged_row.TRANSACTION_TYPE IS NULL
                    OR  l_merged_row.TRANSACTION_TYPE <> l_candidate_trans -- <> filters out nulls
                THEN
                    -- CREATE > SYNC > UPDATE : order of case expression matters
                    l_merged_row.TRANSACTION_TYPE :=
                        CASE
                            WHEN l_merged_row.TRANSACTION_TYPE = G_TRANS_TYPE_CREATE
                              OR l_candidate_trans = G_TRANS_TYPE_CREATE                            THEN G_TRANS_TYPE_CREATE
                            WHEN l_merged_row.TRANSACTION_TYPE = G_TRANS_TYPE_SYNC
                              OR l_candidate_trans = G_TRANS_TYPE_SYNC                              THEN G_TRANS_TYPE_SYNC
                            WHEN l_merged_row.TRANSACTION_TYPE = G_TRANS_TYPE_UPDATE
                              OR l_candidate_trans = G_TRANS_TYPE_UPDATE                            THEN G_TRANS_TYPE_UPDATE
                            ELSE NULL -- INVALID transaction types encountered ...
                        END;
                END IF;

                -- The following columns need to be treated as atomic groups
                -- 1. Item Identifier
                IF      l_merged_row.INVENTORY_ITEM_ID  IS NULL
                    AND l_merged_row.ITEM_NUMBER        IS NULL
                THEN
                    l_merged_row.INVENTORY_ITEM_ID  := l_old_rows( idx ).INVENTORY_ITEM_ID;
                    l_merged_row.ITEM_NUMBER        := l_old_rows( idx ).ITEM_NUMBER;
                END IF;

                -- 2. Organization
                IF      l_merged_row.ORGANIZATION_ID    IS NULL
                    AND l_merged_row.ORGANIZATION_CODE  IS NULL
                THEN
                    l_merged_row.ORGANIZATION_ID        := l_old_rows( idx ).ORGANIZATION_ID;
                    l_merged_row.ORGANIZATION_CODE      := l_old_rows( idx ).ORGANIZATION_CODE;
                END IF;

                -- 3. Category Set
                IF      l_merged_row.CATEGORY_SET_ID    IS NULL
                    AND l_merged_row.CATEGORY_SET_NAME  IS NULL
                THEN
                    l_merged_row.CATEGORY_SET_ID        := l_old_rows( idx ).CATEGORY_SET_ID;
                    l_merged_row.CATEGORY_SET_NAME      := l_old_rows( idx ).CATEGORY_SET_NAME;
                END IF;

                -- 4. Category
                IF      l_merged_row.CATEGORY_ID    IS NULL
                    AND l_merged_row.CATEGORY_NAME  IS NULL
                THEN
                    l_merged_row.CATEGORY_ID        := l_old_rows( idx ).CATEGORY_ID;
                    l_merged_row.CATEGORY_NAME      := l_old_rows( idx ).CATEGORY_NAME;
                END IF;

                -- Non-special cased
                if l_merged_row.CHANGE_ID is null then l_merged_row.CHANGE_ID := l_old_rows( idx ).CHANGE_ID; end if;
                if l_merged_row.CHANGE_LINE_ID is null then l_merged_row.CHANGE_LINE_ID := l_old_rows( idx ).CHANGE_LINE_ID; end if;
                if l_merged_row.OLD_CATEGORY_ID is null then l_merged_row.OLD_CATEGORY_ID := l_old_rows( idx ).OLD_CATEGORY_ID; end if;
                if l_merged_row.OLD_CATEGORY_NAME is null then l_merged_row.OLD_CATEGORY_NAME := l_old_rows( idx ).OLD_CATEGORY_NAME; end if;
                if l_merged_row.TRANSACTION_ID is null then l_merged_row.TRANSACTION_ID := l_old_rows( idx ).TRANSACTION_ID; end if;

                IF idx = l_old_rows.LAST AND l_new_row_idx > 0 THEN
                    FOR i IN 1..l_new_row_idx LOOP
                        Debug_Conc_Log( l_proc_log_prefix || '  No More records found for processing.');
                        Debug_Conc_Log( l_proc_log_prefix || '  Creating merged record for SSR, SS-ID = ' ||
                                                             l_new_rows( i ).SOURCE_SYSTEM_REFERENCE || ', ' ||
                                                             l_new_rows( i ).SOURCE_SYSTEM_ID);
                        l_mrow_ix := l_mrow_ix + 1;
                        l_merged_rows( l_mrow_ix )                           := l_merged_row;
                        l_merged_rows( l_mrow_ix ).SET_PROCESS_ID            := l_new_rows( i ).SET_PROCESS_ID;
                        l_merged_rows( l_mrow_ix ).PROCESS_FLAG              := l_new_rows( i ).PROCESS_FLAG;
                        l_merged_rows( l_mrow_ix ).SOURCE_SYSTEM_ID          := l_new_rows( i ).SOURCE_SYSTEM_ID;
                        l_merged_rows( l_mrow_ix ).SOURCE_SYSTEM_REFERENCE   := l_new_rows( i ).SOURCE_SYSTEM_REFERENCE;
                        l_merged_rows( l_mrow_ix ).CREATED_BY                := l_new_rows( i ).CREATED_BY;
                        l_merged_rows( l_mrow_ix ).LAST_UPDATED_BY           := l_new_rows( i ).LAST_UPDATED_BY;
                        l_merged_rows( l_mrow_ix ).REQUEST_ID                := FND_GLOBAL.CONC_REQUEST_ID;
                        l_merged_rows( l_mrow_ix ).PROGRAM_APPLICATION_ID    := FND_GLOBAL.PROG_APPL_ID;
                        l_merged_rows( l_mrow_ix ).PROGRAM_ID                := FND_GLOBAL.CONC_PROGRAM_ID;
                        l_merged_rows( l_mrow_ix ).PROGRAM_UPDATE_DATE       := SYSDATE;
                    END LOOP; --FOR i IN 1..l_new_row_idx LOOP
                END IF; --IF idx = l_old_rows.LAST AND l_new_row_idx > 0 THEN
            END LOOP; -- loop over old rows

            IF l_merged_rows IS NOT NULL THEN
                -- delete
                Debug_Conc_Log( l_proc_log_prefix || 'Deleting ' || l_old_rowids.COUNT || ' old rows ...' );
                FORALL rid_ix IN INDICES OF l_old_rowids
                    DELETE FROM MTL_ITEM_CATEGORIES_INTERFACE
                        WHERE ROWID = l_old_rowids( rid_ix );
                -- insert
                Debug_Conc_Log( l_proc_log_prefix || 'Inserting ' || l_merged_rows.COUNT || ' merged rows ...' );
                FORALL row_index IN INDICES OF l_merged_rows
                    INSERT INTO MTL_ITEM_CATEGORIES_INTERFACE
                        VALUES l_merged_rows( row_index );
            END IF;
        END IF; -- ENDS IF l_old_rows.count <> 0
        Debug_Conc_Log( l_proc_log_prefix || 'Exiting' );
    EXCEPTION WHEN OTHERS THEN
        Debug_Conc_Log( l_proc_log_prefix || 'Error - ' || SQLERRM);
        IF c_target_categories%ISOPEN THEN
            CLOSE c_target_categories;
        END IF;
        RAISE;
    END Merge_Categories_For_Import;

    -- Merges Item Attributes
    PROCEDURE Merge_Item_Attrs_For_Import( p_batch_id       IN NUMBER
                                         , p_master_org_id  IN NUMBER
                                         )
    IS
        CURSOR c_target_item_attrs IS
            SELECT  sub.*
                ,   attrs.DATA_TYPE_CODE
            FROM
                ( SELECT
                        EIUAI.ROWID rid
                        , COUNT( * ) OVER ( PARTITION BY
                                                      ITEM_NUMBER
                                                    , ATTR_GROUP_INT_NAME
                                                    , ATTR_INT_NAME
                                                    , DATA_LEVEL_ID
                                                    , PK1_VALUE
                                                    , PK2_VALUE
                                                    , PK3_VALUE
                                                    , PK4_VALUE
                                                    , PK5_VALUE
                                                    , ORGANIZATION_ID
                                                    , NVL( ATTR_GROUP_TYPE, G_DEFAULT_ATTR_GROUP_TYPE )
                                          )
                        cnt
                        , RANK() OVER   ( ORDER BY
                                                      ITEM_NUMBER
                                                    , ATTR_GROUP_INT_NAME
                                                    , ATTR_INT_NAME
                                                    , DATA_LEVEL_ID
                                                    , PK1_VALUE
                                                    , PK2_VALUE
                                                    , PK3_VALUE
                                                    , PK4_VALUE
                                                    , PK5_VALUE
                                                    , ORGANIZATION_ID
                                                    , NVL( ATTR_GROUP_TYPE, G_DEFAULT_ATTR_GROUP_TYPE )
                                        )
                        rnk
                        , eiuai.*
                   FROM EGO_ITM_USR_ATTR_INTRFC eiuai, EGO_FND_DSC_FLX_CTX_EXT FL_CTX_EXT
                   WHERE DATA_SET_ID                              = p_batch_id
                     AND PROCESS_STATUS                           = 1
                     AND ITEM_NUMBER                              IS NOT NULL
                     AND ORGANIZATION_ID                          IS NOT NULL
                     AND FL_CTX_EXT.DESCRIPTIVE_FLEXFIELD_NAME    = NVL( EIUAI.ATTR_GROUP_TYPE, G_DEFAULT_ATTR_GROUP_TYPE )
                     AND FL_CTX_EXT.APPLICATION_ID                = 431
                     AND FL_CTX_EXT.DESCRIPTIVE_FLEX_CONTEXT_CODE = EIUAI.ATTR_GROUP_INT_NAME
                     AND FL_CTX_EXT.MULTI_ROW                     = 'N'
                     AND EXISTS( SELECT NULL
                                 FROM EGO_ATTR_GROUP_DL A, EGO_DATA_LEVEL_B DL
                                 WHERE DL.APPLICATION_ID  = 431
                                   AND DL.ATTR_GROUP_TYPE = FL_CTX_EXT.DESCRIPTIVE_FLEXFIELD_NAME
                                   AND DL.DATA_LEVEL_NAME IN ( 'ITEM_LEVEL' , 'ITEM_ORG', 'ITEM_SUP', 'ITEM_SUP_SITE', 'ITEM_SUP_SITE_ORG' )
                                   /* Bug:11887867
                                   AND DL.DATA_LEVEL_ID   = DL.DATA_LEVEL_ID
                                   */
                                   AND A.DATA_LEVEL_ID   = DL.DATA_LEVEL_ID
                                   AND A.ATTR_GROUP_ID    = FL_CTX_EXT.ATTR_GROUP_ID
                               )
                ) sub
                , EGO_ATTRS_V attrs
            WHERE sub.CNT > 1
              AND attrs.APPLICATION_ID    = 431
              AND attrs.ATTR_GROUP_NAME   = sub.ATTR_GROUP_INT_NAME
              AND attrs.ATTR_NAME         = sub.ATTR_INT_NAME
              AND attrs.ATTR_GROUP_TYPE   = NVL( sub.ATTR_GROUP_TYPE, G_DEFAULT_ATTR_GROUP_TYPE )
            ORDER BY rnk, last_update_date DESC, interface_table_unique_id DESC;

        TYPE TARGET_ROWS    IS TABLE OF c_target_item_attrs%ROWTYPE;

        l_merged_rows   EIUAI_ROWS;
        l_new_rows      EIUAI_ROWS;
        l_merged_row    EIUAI_ROW;
        l_old_rows      TARGET_ROWS;
        l_old_rowids    UROWID_TABLE;

        l_candidate_trans EGO_ITM_USR_ATTR_INTRFC.TRANSACTION_TYPE%TYPE;

        l_cur_rank      PLS_INTEGER := 0; -- because rank() starts at 1
        l_mrow_ix       PLS_INTEGER := 0;
        l_new_row_idx   PLS_INTEGER := 0;

        l_data_type_code EGO_ATTRS_V.DATA_TYPE_CODE%TYPE;

        l_proc_log_prefix CONSTANT VARCHAR2(50) := 'Merge_Item_Attrs_For_Import - ';
    BEGIN
        Debug_Conc_Log( l_proc_log_prefix || 'Entering' );
        Debug_Conc_Log( l_proc_log_prefix || 'Batch ID: ' || p_batch_id );

        UPDATE EGO_ITM_USR_ATTR_INTRFC eiuai
        SET ITEM_NUMBER = (SELECT CONCATENATED_SEGMENTS
                           FROM MTL_SYSTEM_ITEMS_KFV
                           WHERE INVENTORY_ITEM_ID = eiuai.INVENTORY_ITEM_ID
                             AND ORGANIZATION_ID = eiuai.ORGANIZATION_ID)
        WHERE DATA_SET_ID = p_batch_id
          AND PROCESS_STATUS = 1
          AND INVENTORY_ITEM_ID IS NOT NULL
          AND ITEM_NUMBER IS NULL;

        OPEN c_target_item_attrs;
        FETCH c_target_item_attrs BULK COLLECT INTO l_old_rows;
        CLOSE c_target_item_attrs;

        Debug_Conc_Log( l_proc_log_prefix || 'Total rows requiring merging = ' || l_old_rows.COUNT );
        IF  0 <> l_old_rows.COUNT THEN
            l_old_rowids := UROWID_TABLE( );
            l_old_rowids.EXTEND( l_old_rows.COUNT );

            -- process the item-level attrs
            FOR idx IN l_old_rows.FIRST .. l_old_rows.LAST LOOP
                l_old_rowids( idx ) := l_old_rows( idx ).RID;

                IF( l_old_rows( idx ).RNK <> l_cur_rank ) THEN
                    IF l_new_row_idx > 0 THEN
                        FOR i IN 1..l_new_row_idx LOOP
                            Debug_Conc_Log( l_proc_log_prefix || '  Creating merged record for SSR, SS-ID = ' ||
                                                                 l_new_rows( i ).SOURCE_SYSTEM_REFERENCE || ', ' ||
                                                                 l_new_rows( i ).SOURCE_SYSTEM_ID);
                            l_mrow_ix := l_mrow_ix + 1;
                            l_merged_rows( l_mrow_ix )                           := l_merged_row;
                            l_merged_rows( l_mrow_ix ).DATA_SET_ID               := l_new_rows( i ).DATA_SET_ID;
                            l_merged_rows( l_mrow_ix ).PROCESS_STATUS            := l_new_rows( i ).PROCESS_STATUS;
                            l_merged_rows( l_mrow_ix ).SOURCE_SYSTEM_ID          := l_new_rows( i ).SOURCE_SYSTEM_ID;
                            l_merged_rows( l_mrow_ix ).SOURCE_SYSTEM_REFERENCE   := l_new_rows( i ).SOURCE_SYSTEM_REFERENCE;
                            l_merged_rows( l_mrow_ix ).ATTR_GROUP_INT_NAME       := l_new_rows( i ).ATTR_GROUP_INT_NAME;
                            l_merged_rows( l_mrow_ix ).ATTR_INT_NAME             := l_new_rows( i ).ATTR_INT_NAME;
                            l_merged_rows( l_mrow_ix ).DATA_LEVEL_ID           := l_new_rows( i ).DATA_LEVEL_ID;
                            l_merged_rows( l_mrow_ix ).DATA_LEVEL_NAME           := l_new_rows( i ).DATA_LEVEL_NAME;
                            l_merged_rows( l_mrow_ix ).PK1_VALUE           := l_new_rows( i ).PK1_VALUE;
                            l_merged_rows( l_mrow_ix ).PK2_VALUE           := l_new_rows( i ).PK2_VALUE;
                            l_merged_rows( l_mrow_ix ).PK3_VALUE           := l_new_rows( i ).PK3_VALUE;
                            l_merged_rows( l_mrow_ix ).PK4_VALUE           := l_new_rows( i ).PK4_VALUE;
                            l_merged_rows( l_mrow_ix ).PK5_VALUE           := l_new_rows( i ).PK5_VALUE;
                            l_merged_rows( l_mrow_ix ).ROW_IDENTIFIER            := l_new_rows( i ).ROW_IDENTIFIER;
                            l_merged_rows( l_mrow_ix ).CREATED_BY                := l_new_rows( i ).CREATED_BY;
                            l_merged_rows( l_mrow_ix ).LAST_UPDATED_BY           := l_new_rows( i ).LAST_UPDATED_BY;
                            l_merged_rows( l_mrow_ix ).REQUEST_ID                := FND_GLOBAL.CONC_REQUEST_ID;
                            l_merged_rows( l_mrow_ix ).PROGRAM_APPLICATION_ID    := FND_GLOBAL.PROG_APPL_ID;
                            l_merged_rows( l_mrow_ix ).PROGRAM_ID                := FND_GLOBAL.CONC_PROGRAM_ID;
                            l_merged_rows( l_mrow_ix ).PROGRAM_UPDATE_DATE       := SYSDATE;
                        END LOOP; --FOR i IN 1..l_new_row_idx LOOP
                    END IF; --IF l_new_row_idx > 0 THEN
                    l_cur_rank := l_old_rows( idx ).RNK;
                    l_data_type_code := l_old_rows( idx ).DATA_TYPE_CODE;

                    Debug_Conc_Log( l_proc_log_prefix || '  Starting new merged row; rank = '|| l_cur_rank );
                    Debug_Conc_Log( l_proc_log_prefix || '    Item, Org-ID, Item-ID, AG-Name, Attr-Name = ' ||
                                                         l_old_rows( idx ).ITEM_NUMBER || ', ' ||
                                                         l_old_rows( idx ).ORGANIZATION_ID || ', ' ||
                                                         l_old_rows( idx ).INVENTORY_ITEM_ID || ', ' ||
                                                         l_old_rows( idx ).ATTR_GROUP_INT_NAME || ', ' ||
                                                         l_old_rows( idx ).ATTR_INT_NAME);
                    l_new_rows.DELETE;
                    l_new_row_idx := 1;
                    l_new_rows( l_new_row_idx ).PROCESS_STATUS          := l_old_rows( idx ).PROCESS_STATUS;
                    -- initializing l_merged_row . This row will contain the current merged row for an item
                    l_merged_row := NULL;
                    l_merged_row.DATA_SET_ID            := p_batch_id;
                    l_merged_row.PROCESS_STATUS         := l_old_rows( idx ).PROCESS_STATUS;
                ELSE
                    Debug_Conc_Log( l_proc_log_prefix || '  Merging another record into current merged row; rank = '|| l_cur_rank );
                    Debug_Conc_Log( l_proc_log_prefix || '    Item, Org-ID, Item-ID, AG-Name, Attr-Name = ' ||
                                                         l_old_rows( idx ).ITEM_NUMBER || ', ' ||
                                                         l_old_rows( idx ).ORGANIZATION_ID || ', ' ||
                                                         l_old_rows( idx ).INVENTORY_ITEM_ID || ', ' ||
                                                         l_old_rows( idx ).ATTR_GROUP_INT_NAME || ', ' ||
                                                         l_old_rows( idx ).ATTR_INT_NAME);
                    l_new_row_idx := l_new_row_idx + 1;
                    l_new_rows( l_new_row_idx ).PROCESS_STATUS              := 7;
                END IF;

                l_new_rows( l_new_row_idx ).DATA_SET_ID               := p_batch_id;
                l_new_rows( l_new_row_idx ).SOURCE_SYSTEM_ID          := l_old_rows( idx ).SOURCE_SYSTEM_ID;
                l_new_rows( l_new_row_idx ).SOURCE_SYSTEM_REFERENCE   := l_old_rows( idx ).SOURCE_SYSTEM_REFERENCE;
                l_new_rows( l_new_row_idx ).ATTR_GROUP_INT_NAME       := l_old_rows( idx ).ATTR_GROUP_INT_NAME;
                l_new_rows( l_new_row_idx ).ATTR_INT_NAME             := l_old_rows( idx ).ATTR_INT_NAME;
                l_new_rows( l_new_row_idx ).DATA_LEVEL_NAME           := l_old_rows( idx ).DATA_LEVEL_NAME;
                l_new_rows( l_new_row_idx ).DATA_LEVEL_ID           := l_old_rows( idx ).DATA_LEVEL_ID;
                l_new_rows( l_new_row_idx ).PK1_VALUE           := l_old_rows( idx ).PK1_VALUE;
                l_new_rows( l_new_row_idx ).PK2_VALUE           := l_old_rows( idx ).PK2_VALUE;
                l_new_rows( l_new_row_idx ).PK3_VALUE           := l_old_rows( idx ).PK3_VALUE;
                l_new_rows( l_new_row_idx ).PK4_VALUE           := l_old_rows( idx ).PK4_VALUE;
                l_new_rows( l_new_row_idx ).PK5_VALUE           := l_old_rows( idx ).PK5_VALUE;
                l_new_rows( l_new_row_idx ).ROW_IDENTIFIER            := l_old_rows( idx ).ROW_IDENTIFIER;
                l_new_rows( l_new_row_idx ).CREATED_BY                := l_old_rows( idx ).CREATED_BY;
                l_new_rows( l_new_row_idx ).LAST_UPDATED_BY           := l_old_rows( idx ).LAST_UPDATED_BY;

                -- Special Cases:
                -- Transaction type
                l_candidate_trans := UPPER( l_old_rows( idx ).TRANSACTION_TYPE );

                IF      l_merged_row.TRANSACTION_TYPE IS NULL
                    OR  l_merged_row.TRANSACTION_TYPE <> l_candidate_trans     -- <> filters out nulls
                THEN
                    -- CREATE > SYNC > UPDATE : order of case expression matters
                    l_merged_row.TRANSACTION_TYPE :=
                        CASE
                            WHEN l_merged_row.TRANSACTION_TYPE = G_TRANS_TYPE_CREATE
                              OR l_candidate_trans = G_TRANS_TYPE_CREATE                            THEN G_TRANS_TYPE_CREATE
                            WHEN l_merged_row.TRANSACTION_TYPE = G_TRANS_TYPE_SYNC
                              OR l_candidate_trans = G_TRANS_TYPE_SYNC                              THEN G_TRANS_TYPE_SYNC
                            WHEN l_merged_row.TRANSACTION_TYPE = G_TRANS_TYPE_UPDATE
                              OR l_candidate_trans = G_TRANS_TYPE_UPDATE                            THEN G_TRANS_TYPE_UPDATE
                            ELSE NULL -- INVALID transaction types encountered so far ...
                        END;
                END IF;


                -- The following columns need to be treated as atomic groups
                -- 1. Item Identifier
                IF      l_merged_row.INVENTORY_ITEM_ID  IS NULL
                    AND l_merged_row.ITEM_NUMBER        IS NULL
                THEN
                    l_merged_row.INVENTORY_ITEM_ID  := l_old_rows( idx ).INVENTORY_ITEM_ID;
                    l_merged_row.ITEM_NUMBER        := l_old_rows( idx ).ITEM_NUMBER;
                END IF;

                -- 2. Organization
                IF      l_merged_row.ORGANIZATION_ID    IS NULL
                    AND l_merged_row.ORGANIZATION_CODE  IS NULL
                THEN
                    l_merged_row.ORGANIZATION_ID        := l_old_rows( idx ).ORGANIZATION_ID ;
                    l_merged_row.ORGANIZATION_CODE      := l_old_rows( idx ).ORGANIZATION_CODE ;
                END IF;

                -- 3. The attribute value
                IF      l_merged_row.ATTR_DISP_VALUE  IS NULL
                    AND l_merged_row.ATTR_VALUE_STR   IS NULL
                    AND l_merged_row.ATTR_VALUE_DATE  IS NULL
                    AND l_merged_row.ATTR_VALUE_NUM   IS NULL
                    AND l_merged_row.ATTR_VALUE_UOM       IS NULL
                    AND l_merged_row.ATTR_UOM_DISP_VALUE  IS NULL
                THEN
                    CASE
                        WHEN l_data_type_code = 'C' OR l_data_type_code = 'A' THEN      -- String Attribute
                            IF      l_old_rows( idx ).ATTR_VALUE_STR    IS NOT NULL
                                OR  l_old_rows( idx ).ATTR_DISP_VALUE   IS NOT NULL
                            THEN
                                l_merged_row.ATTR_VALUE_STR       := l_old_rows( idx ).ATTR_VALUE_STR;
                                l_merged_row.ATTR_DISP_VALUE      := l_old_rows( idx ).ATTR_DISP_VALUE;
                                l_merged_row.ATTR_VALUE_UOM       := l_old_rows( idx ).ATTR_VALUE_UOM;
                                l_merged_row.ATTR_UOM_DISP_VALUE  := l_old_rows( idx ).ATTR_UOM_DISP_VALUE;
                            END IF;
                        WHEN l_data_type_code = 'X' or l_data_type_code = 'Y' THEN      -- Date Attribute
                            IF      l_old_rows( idx ).ATTR_VALUE_DATE   IS NOT NULL
                                OR  l_old_rows( idx ).ATTR_DISP_VALUE   IS NOT NULL
                            THEN
                                l_merged_row.ATTR_VALUE_DATE      := l_old_rows( idx ).ATTR_VALUE_DATE;
                                l_merged_row.ATTR_DISP_VALUE      := l_old_rows( idx ).ATTR_DISP_VALUE;
                                l_merged_row.ATTR_VALUE_UOM       := l_old_rows( idx ).ATTR_VALUE_UOM;
                                l_merged_row.ATTR_UOM_DISP_VALUE  := l_old_rows( idx ).ATTR_UOM_DISP_VALUE;
                            END IF;
                        WHEN l_data_type_code = 'N' THEN                                -- Num Attribute
                            IF      l_old_rows( idx ).ATTR_VALUE_NUM    IS NOT NULL
                                OR  l_old_rows( idx ).ATTR_DISP_VALUE   IS NOT NULL
                            THEN
                                l_merged_row.ATTR_VALUE_NUM       := l_old_rows( idx ).ATTR_VALUE_NUM;
                                l_merged_row.ATTR_DISP_VALUE      := l_old_rows( idx ).ATTR_DISP_VALUE;
                                l_merged_row.ATTR_VALUE_UOM       := l_old_rows( idx ).ATTR_VALUE_UOM;
                                l_merged_row.ATTR_UOM_DISP_VALUE  := l_old_rows( idx ).ATTR_UOM_DISP_VALUE;
                            END IF;
                    END CASE;
                END IF;

                -- Non-special cased
                if l_merged_row.ATTR_GROUP_TYPE is null then l_merged_row.ATTR_GROUP_TYPE := l_old_rows( idx ).ATTR_GROUP_TYPE; end if;
                if l_merged_row.CHANGE_ID is null then l_merged_row.CHANGE_ID := l_old_rows( idx ).CHANGE_ID; end if;
                if l_merged_row.CHANGE_LINE_ID is null then l_merged_row.CHANGE_LINE_ID := l_old_rows( idx ).CHANGE_LINE_ID; end if;
                if l_merged_row.ITEM_CATALOG_GROUP_ID is null then l_merged_row.ITEM_CATALOG_GROUP_ID := l_old_rows( idx ).ITEM_CATALOG_GROUP_ID; end if;
                if l_merged_row.TRANSACTION_ID is null then l_merged_row.TRANSACTION_ID := l_old_rows( idx ).TRANSACTION_ID; end if;
                -- End Generated Code

                IF idx = l_old_rows.LAST AND l_new_row_idx > 0 THEN
                    FOR i IN 1..l_new_row_idx LOOP
                        Debug_Conc_Log( l_proc_log_prefix || '  No More records found for processing.');
                        Debug_Conc_Log( l_proc_log_prefix || '  Creating merged record for SSR, SS-ID = ' ||
                                                             l_new_rows( i ).SOURCE_SYSTEM_REFERENCE || ', ' ||
                                                             l_new_rows( i ).SOURCE_SYSTEM_ID);
                        l_mrow_ix := l_mrow_ix + 1;
                        l_merged_rows( l_mrow_ix )                           := l_merged_row;
                        l_merged_rows( l_mrow_ix ).DATA_SET_ID               := l_new_rows( i ).DATA_SET_ID;
                        l_merged_rows( l_mrow_ix ).PROCESS_STATUS            := l_new_rows( i ).PROCESS_STATUS;
                        l_merged_rows( l_mrow_ix ).SOURCE_SYSTEM_ID          := l_new_rows( i ).SOURCE_SYSTEM_ID;
                        l_merged_rows( l_mrow_ix ).SOURCE_SYSTEM_REFERENCE   := l_new_rows( i ).SOURCE_SYSTEM_REFERENCE;
                        l_merged_rows( l_mrow_ix ).ATTR_GROUP_INT_NAME       := l_new_rows( i ).ATTR_GROUP_INT_NAME;
                        l_merged_rows( l_mrow_ix ).ATTR_INT_NAME             := l_new_rows( i ).ATTR_INT_NAME;
                        l_merged_rows( l_mrow_ix ).DATA_LEVEL_NAME           := l_new_rows( i ).DATA_LEVEL_NAME;
                        l_merged_rows( l_mrow_ix ).DATA_LEVEL_ID             := l_new_rows( i ).DATA_LEVEL_ID;
                        l_merged_rows( l_mrow_ix ).PK1_VALUE           := l_new_rows( i ).PK1_VALUE;
                        l_merged_rows( l_mrow_ix ).PK2_VALUE           := l_new_rows( i ).PK2_VALUE;
                        l_merged_rows( l_mrow_ix ).PK3_VALUE           := l_new_rows( i ).PK3_VALUE;
                        l_merged_rows( l_mrow_ix ).PK4_VALUE           := l_new_rows( i ).PK4_VALUE;
                        l_merged_rows( l_mrow_ix ).PK5_VALUE           := l_new_rows( i ).PK5_VALUE;
                        l_merged_rows( l_mrow_ix ).ROW_IDENTIFIER            := l_new_rows( i ).ROW_IDENTIFIER;
                        l_merged_rows( l_mrow_ix ).CREATED_BY                := l_new_rows( i ).CREATED_BY;
                        l_merged_rows( l_mrow_ix ).LAST_UPDATED_BY           := l_new_rows( i ).LAST_UPDATED_BY;
                        l_merged_rows( l_mrow_ix ).REQUEST_ID                := FND_GLOBAL.CONC_REQUEST_ID;
                        l_merged_rows( l_mrow_ix ).PROGRAM_APPLICATION_ID    := FND_GLOBAL.PROG_APPL_ID;
                        l_merged_rows( l_mrow_ix ).PROGRAM_ID                := FND_GLOBAL.CONC_PROGRAM_ID;
                        l_merged_rows( l_mrow_ix ).PROGRAM_UPDATE_DATE       := SYSDATE;
                    END LOOP; --FOR i IN 1..l_new_row_idx LOOP
                END IF; --IF idx = l_old_rows.LAST AND l_new_row_idx > 0 THEN
            END LOOP; -- loop over old rows

            IF l_merged_rows IS NOT NULL THEN
                -- delete
                Debug_Conc_Log( l_proc_log_prefix || l_old_rowids.COUNT || ' old rows ...' );
                FORALL rid_ix IN INDICES OF l_old_rowids
                    DELETE FROM EGO_ITM_USR_ATTR_INTRFC
                        WHERE ROWID = l_old_rowids( rid_ix );
                -- insert
                Debug_Conc_Log( l_proc_log_prefix || l_merged_rows.COUNT || ' merged rows ...' );
                FORALL row_index IN INDICES OF l_merged_rows
                    INSERT INTO EGO_ITM_USR_ATTR_INTRFC
                        VALUES l_merged_rows( row_index );
            END IF;
        END IF; -- ENDS IF l_old_rows.count <> 0

        Debug_Conc_Log( l_proc_log_prefix || 'Exiting' );
    EXCEPTION WHEN OTHERS THEN
        Debug_Conc_Log( l_proc_log_prefix || 'Error - ' || SQLERRM);
        IF c_target_item_attrs%ISOPEN THEN
            CLOSE c_target_item_attrs;
        END IF;
        RAISE;
    END Merge_Item_Attrs_For_Import;

    -- Merges Item Revision Attributes
    PROCEDURE Merge_Rev_Attrs_For_Import( p_batch_id       IN NUMBER
                                        , p_master_org_id  IN NUMBER
                                        )
    IS
        CURSOR c_target_rev_attrs(cp_rev_dl_id NUMBER) IS
            SELECT  sub.*
                ,   attrs.DATA_TYPE_CODE
            FROM
                ( SELECT
                        eiuai.ROWID rid
                        , COUNT( * ) OVER ( PARTITION BY
                                                      ITEM_NUMBER
                                                    , ATTR_GROUP_INT_NAME
                                                    , ATTR_INT_NAME
                                                    , ORGANIZATION_ID
                                                    , REVISION
                                                    , NVL( ATTR_GROUP_TYPE, G_DEFAULT_ATTR_GROUP_TYPE )
                                          )
                        cnt
                        , RANK() OVER   ( ORDER BY
                                                      ITEM_NUMBER
                                                    , ATTR_GROUP_INT_NAME
                                                    , ATTR_INT_NAME
                                                    , ORGANIZATION_ID
                                                    , REVISION
                                                    , NVL( ATTR_GROUP_TYPE, G_DEFAULT_ATTR_GROUP_TYPE )
                                        )
                        rnk
                        , eiuai.*
                   FROM EGO_ITM_USR_ATTR_INTRFC eiuai, EGO_FND_DSC_FLX_CTX_EXT FL_CTX_EXT
                   WHERE DATA_SET_ID                              = p_batch_id
                     AND PROCESS_STATUS                           = 1
                     AND ITEM_NUMBER                              IS NOT NULL
                     AND ORGANIZATION_ID                          IS NOT NULL
                     AND FL_CTX_EXT.DESCRIPTIVE_FLEXFIELD_NAME    = NVL( EIUAI.ATTR_GROUP_TYPE, G_DEFAULT_ATTR_GROUP_TYPE )
                     AND FL_CTX_EXT.APPLICATION_ID                = 431
                     AND FL_CTX_EXT.DESCRIPTIVE_FLEX_CONTEXT_CODE = EIUAI.ATTR_GROUP_INT_NAME
                     AND FL_CTX_EXT.MULTI_ROW                     = 'N'
                     AND EXISTS( SELECT NULL
                                 FROM EGO_ATTR_GROUP_DL A
                                 WHERE A.DATA_LEVEL_ID = cp_rev_dl_id
                                   AND A.ATTR_GROUP_ID  = FL_CTX_EXT.ATTR_GROUP_ID
                               )
                ) sub
                , EGO_ATTRS_V attrs
            WHERE sub.CNT > 1
              AND attrs.APPLICATION_ID    = 431
              AND attrs.ATTR_GROUP_NAME   = sub.ATTR_GROUP_INT_NAME
              AND attrs.ATTR_NAME         = sub.ATTR_INT_NAME
              AND attrs.ATTR_GROUP_TYPE   = NVL( sub.ATTR_GROUP_TYPE, G_DEFAULT_ATTR_GROUP_TYPE )
            ORDER BY rnk, last_update_date DESC, interface_table_unique_id DESC;

        TYPE TARGET_ROWS    IS TABLE OF c_target_rev_attrs%ROWTYPE;

        l_merged_rows   EIUAI_ROWS;
        l_new_rows      EIUAI_ROWS;
        l_merged_row    EIUAI_ROW;
        l_old_rows      TARGET_ROWS;
        l_old_rowids    UROWID_TABLE;

        l_candidate_trans EGO_ITM_USR_ATTR_INTRFC.TRANSACTION_TYPE%TYPE;

        l_cur_rank      PLS_INTEGER := 0; -- because rank() starts at 1
        l_mrow_ix       PLS_INTEGER := 0;
        l_new_row_idx   PLS_INTEGER := 0;
        l_rev_dl_id     NUMBER;

        l_data_type_code EGO_ATTRS_V.DATA_TYPE_CODE%TYPE;

        l_proc_log_prefix CONSTANT VARCHAR2(50) := 'Merge_Rev_Attrs_For_Import - ';
    BEGIN
        Debug_Conc_Log( l_proc_log_prefix || 'Entering' );
        Debug_Conc_Log( l_proc_log_prefix || 'Batch ID: ' || p_batch_id );
        BEGIN
          SELECT DATA_LEVEL_ID INTO l_rev_dl_id
          FROM EGO_DATA_LEVEL_B
          WHERE ATTR_GROUP_TYPE = 'EGO_ITEMMGMT_GROUP'
            AND APPLICATION_ID = 431
            AND DATA_LEVEL_NAME = 'ITEM_REVISION_LEVEL';
        EXCEPTION WHEN NO_DATA_FOUND THEN
          RETURN;
        END;
        Debug_Conc_Log( l_proc_log_prefix || 'l_rev_dl_id: ' || l_rev_dl_id );

        UPDATE EGO_ITM_USR_ATTR_INTRFC eiuai
        SET ITEM_NUMBER = (SELECT CONCATENATED_SEGMENTS
                           FROM MTL_SYSTEM_ITEMS_KFV
                           WHERE INVENTORY_ITEM_ID = eiuai.INVENTORY_ITEM_ID
                             AND ORGANIZATION_ID = eiuai.ORGANIZATION_ID)
        WHERE DATA_SET_ID = p_batch_id
          AND PROCESS_STATUS = 1
          AND INVENTORY_ITEM_ID IS NOT NULL
          AND ITEM_NUMBER IS NULL;

        OPEN c_target_rev_attrs(l_rev_dl_id);
        FETCH c_target_rev_attrs BULK COLLECT INTO l_old_rows;
        CLOSE c_target_rev_attrs;

        Debug_Conc_Log( l_proc_log_prefix || 'Total rows requiring merging = ' || l_old_rows.COUNT );
        IF  0 <> l_old_rows.COUNT THEN
            l_old_rowids := UROWID_TABLE( );
            l_old_rowids.EXTEND( l_old_rows.COUNT );

            -- process the item-level attrs
            FOR idx IN l_old_rows.FIRST .. l_old_rows.LAST LOOP
                l_old_rowids( idx ) := l_old_rows( idx ).RID;

                IF( l_old_rows( idx ).RNK <> l_cur_rank ) THEN
                    IF l_new_row_idx > 0 THEN
                        FOR i IN 1..l_new_row_idx LOOP
                            Debug_Conc_Log( l_proc_log_prefix || '  Creating merged record for SSR, SS-ID = ' ||
                                                                 l_new_rows( i ).SOURCE_SYSTEM_REFERENCE || ', ' ||
                                                                 l_new_rows( i ).SOURCE_SYSTEM_ID);
                            l_mrow_ix := l_mrow_ix + 1;
                            l_merged_rows( l_mrow_ix )                           := l_merged_row;
                            l_merged_rows( l_mrow_ix ).DATA_SET_ID               := l_new_rows( i ).DATA_SET_ID;
                            l_merged_rows( l_mrow_ix ).PROCESS_STATUS            := l_new_rows( i ).PROCESS_STATUS;
                            l_merged_rows( l_mrow_ix ).SOURCE_SYSTEM_ID          := l_new_rows( i ).SOURCE_SYSTEM_ID;
                            l_merged_rows( l_mrow_ix ).SOURCE_SYSTEM_REFERENCE   := l_new_rows( i ).SOURCE_SYSTEM_REFERENCE;
                            l_merged_rows( l_mrow_ix ).ATTR_GROUP_INT_NAME       := l_new_rows( i ).ATTR_GROUP_INT_NAME;
                            l_merged_rows( l_mrow_ix ).ATTR_INT_NAME             := l_new_rows( i ).ATTR_INT_NAME;
                            l_merged_rows( l_mrow_ix ).DATA_LEVEL_NAME           := l_new_rows( i ).DATA_LEVEL_NAME;
                            l_merged_rows( l_mrow_ix ).DATA_LEVEL_ID           := l_new_rows( i ).DATA_LEVEL_ID;
                            l_merged_rows( l_mrow_ix ).ROW_IDENTIFIER            := l_new_rows( i ).ROW_IDENTIFIER;
                            l_merged_rows( l_mrow_ix ).CREATED_BY                := l_new_rows( i ).CREATED_BY;
                            l_merged_rows( l_mrow_ix ).LAST_UPDATED_BY           := l_new_rows( i ).LAST_UPDATED_BY;
                            l_merged_rows( l_mrow_ix ).REQUEST_ID                := FND_GLOBAL.CONC_REQUEST_ID;
                            l_merged_rows( l_mrow_ix ).PROGRAM_APPLICATION_ID    := FND_GLOBAL.PROG_APPL_ID;
                            l_merged_rows( l_mrow_ix ).PROGRAM_ID                := FND_GLOBAL.CONC_PROGRAM_ID;
                            l_merged_rows( l_mrow_ix ).PROGRAM_UPDATE_DATE       := SYSDATE;
                        END LOOP; --FOR i IN 1..l_new_row_idx LOOP
                    END IF; --IF l_new_row_idx > 0 THEN
                    l_cur_rank := l_old_rows( idx ).RNK;
                    l_data_type_code := l_old_rows( idx ).DATA_TYPE_CODE;

                    Debug_Conc_Log( l_proc_log_prefix || '  Starting new merged row; rank = '|| l_cur_rank );
                    Debug_Conc_Log( l_proc_log_prefix || '    Item, Org-ID, Item-ID, AG-Name, Attr-Name = ' ||
                                                         l_old_rows( idx ).ITEM_NUMBER || ', ' ||
                                                         l_old_rows( idx ).ORGANIZATION_ID || ', ' ||
                                                         l_old_rows( idx ).INVENTORY_ITEM_ID || ', ' ||
                                                         l_old_rows( idx ).ATTR_GROUP_INT_NAME || ', ' ||
                                                         l_old_rows( idx ).ATTR_INT_NAME);
                    l_new_rows.DELETE;
                    l_new_row_idx := 1;
                    l_new_rows( l_new_row_idx ).PROCESS_STATUS          := l_old_rows( idx ).PROCESS_STATUS;
                    -- initializing l_merged_row . This row will contain the current merged row for an item
                    l_merged_row := NULL;
                    l_merged_row.DATA_SET_ID            := p_batch_id;
                    l_merged_row.PROCESS_STATUS         := l_old_rows( idx ).PROCESS_STATUS;
                ELSE
                    Debug_Conc_Log( l_proc_log_prefix || '  Merging another record into current merged row; rank = '|| l_cur_rank );
                    Debug_Conc_Log( l_proc_log_prefix || '    Item, Org-ID, Item-ID, AG-Name, Attr-Name = ' ||
                                                         l_old_rows( idx ).ITEM_NUMBER || ', ' ||
                                                         l_old_rows( idx ).ORGANIZATION_ID || ', ' ||
                                                         l_old_rows( idx ).INVENTORY_ITEM_ID || ', ' ||
                                                         l_old_rows( idx ).ATTR_GROUP_INT_NAME || ', ' ||
                                                         l_old_rows( idx ).ATTR_INT_NAME);
                    l_new_row_idx := l_new_row_idx + 1;
                    l_new_rows( l_new_row_idx ).PROCESS_STATUS              := 7;
                END IF;

                l_new_rows( l_new_row_idx ).DATA_SET_ID               := p_batch_id;
                l_new_rows( l_new_row_idx ).SOURCE_SYSTEM_ID          := l_old_rows( idx ).SOURCE_SYSTEM_ID;
                l_new_rows( l_new_row_idx ).SOURCE_SYSTEM_REFERENCE   := l_old_rows( idx ).SOURCE_SYSTEM_REFERENCE;
                l_new_rows( l_new_row_idx ).ATTR_GROUP_INT_NAME       := l_old_rows( idx ).ATTR_GROUP_INT_NAME;
                l_new_rows( l_new_row_idx ).ATTR_INT_NAME             := l_old_rows( idx ).ATTR_INT_NAME;
                l_new_rows( l_new_row_idx ).DATA_LEVEL_NAME           := l_old_rows( idx ).DATA_LEVEL_NAME;
                l_new_rows( l_new_row_idx ).DATA_LEVEL_ID             := l_old_rows( idx ).DATA_LEVEL_ID;
                l_new_rows( l_new_row_idx ).ROW_IDENTIFIER            := l_old_rows( idx ).ROW_IDENTIFIER;
                l_new_rows( l_new_row_idx ).CREATED_BY                := l_old_rows( idx ).CREATED_BY;
                l_new_rows( l_new_row_idx ).LAST_UPDATED_BY           := l_old_rows( idx ).LAST_UPDATED_BY;

                -- Special Cases:
                -- Transaction type
                l_candidate_trans := UPPER( l_old_rows( idx ).TRANSACTION_TYPE );

                IF      l_merged_row.TRANSACTION_TYPE IS NULL
                    OR  l_merged_row.TRANSACTION_TYPE <> l_candidate_trans     -- <> filters out nulls
                THEN
                    -- CREATE > SYNC > UPDATE : order of case expression matters
                    l_merged_row.TRANSACTION_TYPE :=
                        CASE
                            WHEN l_merged_row.TRANSACTION_TYPE = G_TRANS_TYPE_CREATE
                              OR l_candidate_trans = G_TRANS_TYPE_CREATE                            THEN G_TRANS_TYPE_CREATE
                            WHEN l_merged_row.TRANSACTION_TYPE = G_TRANS_TYPE_SYNC
                              OR l_candidate_trans = G_TRANS_TYPE_SYNC                              THEN G_TRANS_TYPE_SYNC
                            WHEN l_merged_row.TRANSACTION_TYPE = G_TRANS_TYPE_UPDATE
                              OR l_candidate_trans = G_TRANS_TYPE_UPDATE                            THEN G_TRANS_TYPE_UPDATE
                            ELSE NULL -- INVALID transaction types encountered so far ...
                        END;
                END IF;


                -- The following columns need to be treated as atomic groups
                -- 1. Item Identifier
                IF      l_merged_row.INVENTORY_ITEM_ID  IS NULL
                    AND l_merged_row.ITEM_NUMBER        IS NULL
                THEN
                    l_merged_row.INVENTORY_ITEM_ID  := l_old_rows( idx ).INVENTORY_ITEM_ID;
                    l_merged_row.ITEM_NUMBER        := l_old_rows( idx ).ITEM_NUMBER;
                END IF;

                -- 2. Organization
                IF      l_merged_row.ORGANIZATION_ID    IS NULL
                    AND l_merged_row.ORGANIZATION_CODE  IS NULL
                THEN
                    l_merged_row.ORGANIZATION_ID        := l_old_rows( idx ).ORGANIZATION_ID ;
                    l_merged_row.ORGANIZATION_CODE      := l_old_rows( idx ).ORGANIZATION_CODE ;
                END IF;

                -- 3. The attribute value
                IF      l_merged_row.ATTR_DISP_VALUE  IS NULL
                    AND l_merged_row.ATTR_VALUE_STR   IS NULL
                    AND l_merged_row.ATTR_VALUE_DATE  IS NULL
                    AND l_merged_row.ATTR_VALUE_NUM   IS NULL
                    AND l_merged_row.ATTR_VALUE_UOM       IS NULL
                    AND l_merged_row.ATTR_UOM_DISP_VALUE  IS NULL
                THEN
                    CASE
                        WHEN l_data_type_code = 'C' OR l_data_type_code = 'A' THEN      -- String Attribute
                            IF      l_old_rows( idx ).ATTR_VALUE_STR    IS NOT NULL
                                OR  l_old_rows( idx ).ATTR_DISP_VALUE   IS NOT NULL
                            THEN
                                l_merged_row.ATTR_VALUE_STR       := l_old_rows( idx ).ATTR_VALUE_STR;
                                l_merged_row.ATTR_DISP_VALUE      := l_old_rows( idx ).ATTR_DISP_VALUE;
                                l_merged_row.ATTR_VALUE_UOM       := l_old_rows( idx ).ATTR_VALUE_UOM;
                                l_merged_row.ATTR_UOM_DISP_VALUE  := l_old_rows( idx ).ATTR_UOM_DISP_VALUE;
                            END IF;
                        WHEN l_data_type_code = 'X' or l_data_type_code = 'Y' THEN      -- Date Attribute
                            IF      l_old_rows( idx ).ATTR_VALUE_DATE   IS NOT NULL
                                OR  l_old_rows( idx ).ATTR_DISP_VALUE   IS NOT NULL
                            THEN
                                l_merged_row.ATTR_VALUE_DATE      := l_old_rows( idx ).ATTR_VALUE_DATE;
                                l_merged_row.ATTR_DISP_VALUE      := l_old_rows( idx ).ATTR_DISP_VALUE;
                                l_merged_row.ATTR_VALUE_UOM       := l_old_rows( idx ).ATTR_VALUE_UOM;
                                l_merged_row.ATTR_UOM_DISP_VALUE  := l_old_rows( idx ).ATTR_UOM_DISP_VALUE;
                            END IF;
                        WHEN l_data_type_code = 'N' THEN                                -- Num Attribute
                            IF      l_old_rows( idx ).ATTR_VALUE_NUM    IS NOT NULL
                                OR  l_old_rows( idx ).ATTR_DISP_VALUE   IS NOT NULL
                            THEN
                                l_merged_row.ATTR_VALUE_NUM       := l_old_rows( idx ).ATTR_VALUE_NUM;
                                l_merged_row.ATTR_DISP_VALUE      := l_old_rows( idx ).ATTR_DISP_VALUE;
                                l_merged_row.ATTR_VALUE_UOM       := l_old_rows( idx ).ATTR_VALUE_UOM;
                                l_merged_row.ATTR_UOM_DISP_VALUE  := l_old_rows( idx ).ATTR_UOM_DISP_VALUE;
                            END IF;
                    END CASE;
                END IF;

                -- Non-special cased
                if l_merged_row.ATTR_GROUP_TYPE is null then l_merged_row.ATTR_GROUP_TYPE := l_old_rows( idx ).ATTR_GROUP_TYPE; end if;
                if l_merged_row.CHANGE_ID is null then l_merged_row.CHANGE_ID := l_old_rows( idx ).CHANGE_ID; end if;
                if l_merged_row.CHANGE_LINE_ID is null then l_merged_row.CHANGE_LINE_ID := l_old_rows( idx ).CHANGE_LINE_ID; end if;
                if l_merged_row.ITEM_CATALOG_GROUP_ID is null then l_merged_row.ITEM_CATALOG_GROUP_ID := l_old_rows( idx ).ITEM_CATALOG_GROUP_ID; end if;
                if l_merged_row.REVISION is null then l_merged_row.REVISION := l_old_rows( idx ).REVISION; end if;
                if l_merged_row.REVISION_ID is null then l_merged_row.REVISION_ID := l_old_rows( idx ).REVISION_ID; end if;
                if l_merged_row.TRANSACTION_ID is null then l_merged_row.TRANSACTION_ID := l_old_rows( idx ).TRANSACTION_ID; end if;
                -- End Generated Code

                IF idx = l_old_rows.LAST AND l_new_row_idx > 0 THEN
                    FOR i IN 1..l_new_row_idx LOOP
                        Debug_Conc_Log( l_proc_log_prefix || '  No More records found for processing.');
                        Debug_Conc_Log( l_proc_log_prefix || '  Creating merged record for SSR, SS-ID = ' ||
                                                             l_new_rows( i ).SOURCE_SYSTEM_REFERENCE || ', ' ||
                                                             l_new_rows( i ).SOURCE_SYSTEM_ID);
                        l_mrow_ix := l_mrow_ix + 1;
                        l_merged_rows( l_mrow_ix )                           := l_merged_row;
                        l_merged_rows( l_mrow_ix ).DATA_SET_ID               := l_new_rows( i ).DATA_SET_ID;
                        l_merged_rows( l_mrow_ix ).PROCESS_STATUS            := l_new_rows( i ).PROCESS_STATUS;
                        l_merged_rows( l_mrow_ix ).SOURCE_SYSTEM_ID          := l_new_rows( i ).SOURCE_SYSTEM_ID;
                        l_merged_rows( l_mrow_ix ).SOURCE_SYSTEM_REFERENCE   := l_new_rows( i ).SOURCE_SYSTEM_REFERENCE;
                        l_merged_rows( l_mrow_ix ).ATTR_GROUP_INT_NAME       := l_new_rows( i ).ATTR_GROUP_INT_NAME;
                        l_merged_rows( l_mrow_ix ).ATTR_INT_NAME             := l_new_rows( i ).ATTR_INT_NAME;
                        l_merged_rows( l_mrow_ix ).DATA_LEVEL_NAME           := l_new_rows( i ).DATA_LEVEL_NAME;
                        l_merged_rows( l_mrow_ix ).DATA_LEVEL_ID           := l_new_rows( i ).DATA_LEVEL_ID;
                        l_merged_rows( l_mrow_ix ).ROW_IDENTIFIER            := l_new_rows( i ).ROW_IDENTIFIER;
                        l_merged_rows( l_mrow_ix ).CREATED_BY                := l_new_rows( i ).CREATED_BY;
                        l_merged_rows( l_mrow_ix ).LAST_UPDATED_BY           := l_new_rows( i ).LAST_UPDATED_BY;
                        l_merged_rows( l_mrow_ix ).REQUEST_ID                := FND_GLOBAL.CONC_REQUEST_ID;
                        l_merged_rows( l_mrow_ix ).PROGRAM_APPLICATION_ID    := FND_GLOBAL.PROG_APPL_ID;
                        l_merged_rows( l_mrow_ix ).PROGRAM_ID                := FND_GLOBAL.CONC_PROGRAM_ID;
                        l_merged_rows( l_mrow_ix ).PROGRAM_UPDATE_DATE       := SYSDATE;
                    END LOOP; --FOR i IN 1..l_new_row_idx LOOP
                END IF; --IF idx = l_old_rows.LAST AND l_new_row_idx > 0 THEN
            END LOOP; -- loop over old rows

            IF l_merged_rows IS NOT NULL THEN
                -- delete
                Debug_Conc_Log( l_proc_log_prefix || l_old_rowids.COUNT || ' old rows ...' );
                FORALL rid_ix IN INDICES OF l_old_rowids
                    DELETE FROM EGO_ITM_USR_ATTR_INTRFC
                        WHERE ROWID = l_old_rowids( rid_ix );
                -- insert
                Debug_Conc_Log( l_proc_log_prefix || l_merged_rows.COUNT || ' merged rows ...' );
                FORALL row_index IN INDICES OF l_merged_rows
                    INSERT INTO EGO_ITM_USR_ATTR_INTRFC
                        VALUES l_merged_rows( row_index );
            END IF;
        END IF; -- ENDS IF l_old_rows.count <> 0
        Debug_Conc_Log( l_proc_log_prefix || 'Exiting' );
    EXCEPTION WHEN OTHERS THEN
        Debug_Conc_Log( l_proc_log_prefix || 'Error - ' || SQLERRM);
        IF c_target_rev_attrs%ISOPEN THEN
            CLOSE c_target_rev_attrs;
        END IF;
        RAISE;
    END Merge_Rev_Attrs_For_Import;

    -- Merges all entities in batch
    PROCEDURE Merge_Batch_For_Import( p_batch_id       IN NUMBER
                                    , p_master_org_id  IN NUMBER
                                    )
    IS
    BEGIN
        Merge_Items_For_Import(p_batch_id, p_master_org_id);
        Merge_Revs_For_Import(p_batch_id, p_master_org_id);
        Merge_Categories_For_Import(p_batch_id, p_master_org_id);
        Merge_Item_Attrs_For_Import(p_batch_id, p_master_org_id);
        Merge_Rev_Attrs_For_Import(p_batch_id, p_master_org_id);
    END Merge_Batch_For_Import;

    --=================================================================================================================--
    --------------------------------- End of Merging Section for Import -----------------------------------------------
    --=================================================================================================================--

    /*
     * This method is called after all the import is completed
     * this will update the process flag of rows with process flag = 111
     */
    PROCEDURE Demerge_Batch_After_Import(
                                           ERRBUF  OUT NOCOPY VARCHAR2
                                         , RETCODE OUT NOCOPY VARCHAR2
                                         , p_batch_id        IN NUMBER
                                        )
    IS
        l_proc_log_prefix   VARCHAR2(50) := 'Demerge_Batch_After_Import - ';
    BEGIN
        Debug_Conc_Log( l_proc_log_prefix || 'Starting ...' );
        -- processing items and org assignments
        UPDATE MTL_SYSTEM_ITEMS_INTERFACE msii
          SET (PROCESS_FLAG, INVENTORY_ITEM_ID) =
                             (SELECT PROCESS_FLAG, INVENTORY_ITEM_ID
                              FROM MTL_SYSTEM_ITEMS_INTERFACE msii_merged
                              WHERE msii_merged.ITEM_NUMBER = msii.ITEM_NUMBER
                                AND msii_merged.ORGANIZATION_ID = msii.ORGANIZATION_ID
                                AND msii_merged.REQUEST_ID = msii.REQUEST_ID
                                AND msii_merged.SET_PROCESS_ID = msii.SET_PROCESS_ID
                                AND msii_merged.PROCESS_FLAG <> 111)
        WHERE SET_PROCESS_ID = p_batch_id
          AND PROCESS_FLAG = 111;

        Debug_Conc_Log( l_proc_log_prefix || 'Processed ' || SQL%ROWCOUNT || ' Items.' );
        -- processing item revisions
        UPDATE MTL_ITEM_REVISIONS_INTERFACE miri
          SET (PROCESS_FLAG, INVENTORY_ITEM_ID) =
                             (SELECT PROCESS_FLAG, INVENTORY_ITEM_ID
                              FROM MTL_ITEM_REVISIONS_INTERFACE miri_merged
                              WHERE miri_merged.ITEM_NUMBER = miri.ITEM_NUMBER
                                AND miri_merged.ORGANIZATION_ID = miri.ORGANIZATION_ID
                                AND miri_merged.REVISION = miri.REVISION
                                AND miri_merged.REQUEST_ID = miri.REQUEST_ID
                                AND miri_merged.SET_PROCESS_ID = miri.SET_PROCESS_ID
                                AND miri_merged.PROCESS_FLAG <> 111)
        WHERE SET_PROCESS_ID = p_batch_id
          AND PROCESS_FLAG = 111;

        Debug_Conc_Log( l_proc_log_prefix || 'Processed ' || SQL%ROWCOUNT || ' Revisions.' );
        -- processing category assignments
        UPDATE MTL_ITEM_CATEGORIES_INTERFACE mici
          SET (PROCESS_FLAG, INVENTORY_ITEM_ID) =
                             (SELECT PROCESS_FLAG, INVENTORY_ITEM_ID
                              FROM MTL_ITEM_CATEGORIES_INTERFACE mici_merged
                              WHERE mici_merged.ITEM_NUMBER = mici.ITEM_NUMBER
                                AND mici_merged.ORGANIZATION_ID = mici.ORGANIZATION_ID
                                AND mici_merged.CATEGORY_SET_NAME = mici.CATEGORY_SET_NAME
                                AND mici_merged.CATEGORY_NAME = mici.CATEGORY_NAME
                                AND mici_merged.REQUEST_ID = mici.REQUEST_ID
                                AND mici_merged.SET_PROCESS_ID = mici.SET_PROCESS_ID
                                AND mici_merged.PROCESS_FLAG <> 111)
        WHERE SET_PROCESS_ID = p_batch_id
          AND PROCESS_FLAG = 111;

        Debug_Conc_Log( l_proc_log_prefix || 'Processed ' || SQL%ROWCOUNT || ' Category Assignments.' );
        -- processing revision attributes
        UPDATE EGO_ITM_USR_ATTR_INTRFC eiuai
          SET (PROCESS_STATUS, INVENTORY_ITEM_ID) =
                               (SELECT PROCESS_STATUS, INVENTORY_ITEM_ID
                                FROM EGO_ITM_USR_ATTR_INTRFC eiuai_merged
                                WHERE eiuai_merged.ITEM_NUMBER = eiuai.ITEM_NUMBER
                                  AND eiuai_merged.ORGANIZATION_ID = eiuai.ORGANIZATION_ID
                                  AND eiuai_merged.ATTR_GROUP_INT_NAME = eiuai.ATTR_GROUP_INT_NAME
                                  AND eiuai_merged.ATTR_INT_NAME = eiuai.ATTR_INT_NAME
                                  AND NVL(eiuai_merged.ATTR_GROUP_TYPE, 'EGO_ITEMMGMT_GROUP') = NVL(eiuai.ATTR_GROUP_TYPE, 'EGO_ITEMMGMT_GROUP')
                                  AND eiuai_merged.REVISION = eiuai.REVISION
                                  AND eiuai_merged.REQUEST_ID = eiuai.REQUEST_ID
                                  AND eiuai_merged.DATA_SET_ID = eiuai.DATA_SET_ID
                                  AND eiuai_merged.PROCESS_STATUS <> 7)
        WHERE DATA_SET_ID = p_batch_id
          AND PROCESS_STATUS = 7
          AND REVISION IS NOT NULL;

        Debug_Conc_Log( l_proc_log_prefix || 'Processed ' || SQL%ROWCOUNT || ' Revision attributes.' );
        -- processing item attributes
        UPDATE /*+ INDEX(eiuai,EGO_ITM_USR_ATTR_INTRFC_N3) */   /* Bug 9678667 */
          EGO_ITM_USR_ATTR_INTRFC eiuai
          SET (PROCESS_STATUS, INVENTORY_ITEM_ID) =
                               (SELECT PROCESS_STATUS, INVENTORY_ITEM_ID
                                FROM EGO_ITM_USR_ATTR_INTRFC eiuai_merged
                                WHERE eiuai_merged.ITEM_NUMBER = eiuai.ITEM_NUMBER
                                  AND eiuai_merged.ORGANIZATION_ID = eiuai.ORGANIZATION_ID
                                  AND eiuai_merged.ATTR_GROUP_INT_NAME = eiuai.ATTR_GROUP_INT_NAME
                                  AND eiuai_merged.ATTR_INT_NAME = eiuai.ATTR_INT_NAME
                                  AND Nvl(eiuai_merged.ATTR_GROUP_TYPE, 'EGO_ITEMMGMT_GROUP') = Nvl(eiuai.ATTR_GROUP_TYPE, 'EGO_ITEMMGMT_GROUP')
                                  AND eiuai_merged.REVISION IS NULL
                                  AND eiuai_merged.REQUEST_ID = eiuai.REQUEST_ID
                                  AND eiuai_merged.DATA_SET_ID = eiuai.DATA_SET_ID
                                  AND eiuai_merged.PROCESS_STATUS <> 7)
        WHERE DATA_SET_ID = p_batch_id
          AND PROCESS_STATUS = 7
          AND REVISION IS NULL;

        Debug_Conc_Log( l_proc_log_prefix || 'Processed ' || SQL%ROWCOUNT || ' Item attributes.' );

        --COMMIT;
        Debug_Conc_Log( l_proc_log_prefix || 'Exiting' );
        RETCODE := '0';
        ERRBUF := NULL;
    EXCEPTION WHEN OTHERS THEN
        Debug_Conc_Log(l_proc_log_prefix || 'Error - ' || SQLERRM);
        RETCODE := '2';
        ERRBUF := 'Error in method EGO_IMPORT_PVT.Demerge_Batch_After_Import - '||SQLERRM;
    END Demerge_Batch_After_Import;

 /*
  * This method does a bulkload of GTINs
  */
 PROCEDURE Process_Gtin_Intf_Rows(ERRBUF  OUT NOCOPY VARCHAR2,
                                  RETCODE OUT NOCOPY VARCHAR2,
                                  p_data_set_id IN  NUMBER) IS
   CURSOR c_intf_rows IS
   SELECT
     intf.INVENTORY_ITEM_ID,
     intf.ORGANIZATION_ID,
     intf.ITEM_NUMBER,
     intf.ORGANIZATION_CODE,
     intf.PRIMARY_UOM_CODE,
     intf.GLOBAL_TRADE_ITEM_NUMBER,
     intf.GTIN_DESCRIPTION,
     intf.TRANSACTION_ID,
     c.CROSS_REFERENCE EXISTING_GTIN,
     c.DESCRIPTION     EXISTING_GTIN_DESC,
     c.CROSS_REFERENCE_ID
   FROM MTL_SYSTEM_ITEMS_INTERFACE intf, MTL_PARAMETERS p, MTL_CROSS_REFERENCES c
   WHERE intf.SET_PROCESS_ID = p_data_set_id
     AND intf.ORGANIZATION_ID = p.ORGANIZATION_ID
     AND p.ORGANIZATION_ID = p.MASTER_ORGANIZATION_ID
     AND intf.PROCESS_FLAG IN (5,7)
     AND intf.GLOBAL_TRADE_ITEM_NUMBER IS NOT NULL
     AND c.INVENTORY_ITEM_ID(+) = intf.INVENTORY_ITEM_ID
     AND c.UOM_CODE(+) = intf.PRIMARY_UOM_CODE
     AND intf.REQUEST_ID = FND_GLOBAL.CONC_REQUEST_ID
     AND c.CROSS_REFERENCE_TYPE(+) = 'GTIN';

   l_gtin              NUMBER;
   l_msg_text          VARCHAR2(4000);
   dumm_status         VARCHAR2(100);
   l_user_id           NUMBER := FND_GLOBAL.USER_ID;
   l_login_id          NUMBER := FND_GLOBAL.LOGIN_ID;
   l_prog_appid        NUMBER := FND_GLOBAL.PROG_APPL_ID;
   l_prog_id           NUMBER := FND_GLOBAL.CONC_PROGRAM_ID;
   l_request_id        NUMBER := FND_GLOBAL.CONC_REQUEST_ID;
   l_err_text          VARCHAR2(4000);
   l_error             BOOLEAN;
   l_rowid             ROWID;
   l_xref_id           NUMBER;
   l_existing_gtin     VARCHAR2(1000);
   l_raise_event       BOOLEAN;
   l_xref_event_name   CONSTANT VARCHAR2(100) := 'oracle.apps.ego.item.postXrefChange';
   l_msg_data          VARCHAR2(4000);
   l_return_status     VARCHAR2(10);
   l_org_id            NUMBER;
   l_transaction_id    NUMBER;
   l_priv              VARCHAR2(10);
   l_party_name        VARCHAR2(1000);  -- Bug: 5355759
 BEGIN
   Debug_Conc_Log('Starting Process_Gtin_Intf_Rows for batch_id='||TO_CHAR(p_data_set_id));
   l_raise_event := FALSE;
   l_party_name := Get_Current_Party_Name; -- Bug: 5355759
   FOR i IN c_intf_rows LOOP
     Debug_Conc_Log('Processing for Item, Org='||TO_CHAR(i.INVENTORY_ITEM_ID)||', '||TO_CHAR(i.ORGANIZATION_ID));
     -- checking the edit cross reference privilege for creating GTIN xref.
     --l_priv := EGO_ITEM_AML_PUB.Check_No_AML_Priv(1.0, i.INVENTORY_ITEM_ID, i.ORGANIZATION_ID, 'EGO_EDIT_ITEM_XREFS', NULL, NULL);
     l_priv := EGO_DATA_SECURITY.CHECK_FUNCTION(1.0, 'EGO_EDIT_ITEM_XREFS', 'EGO_ITEM', i.INVENTORY_ITEM_ID, i.ORGANIZATION_ID, NULL, NULL, NULL, l_party_name);

     IF NVL(l_priv, 'F') <> 'T' THEN
       Debug_Conc_Log('No Edit Cross Reference Privilege on item');
       FND_MESSAGE.SET_NAME('EGO', 'EGO_NO_EDIT_XREF_PRIV');
       FND_MESSAGE.SET_TOKEN('ITEM', i.ITEM_NUMBER);
       FND_MESSAGE.SET_TOKEN('ORG', i.ORGANIZATION_CODE);
       l_msg_text := FND_MESSAGE.GET;

         dumm_status  := INVPUOPI.mtl_log_interface_err(
                                i.ORGANIZATION_ID
                               ,l_user_id
                               ,l_login_id
                               ,l_prog_appid
                               ,l_prog_id
                               ,l_request_id
                               ,i.TRANSACTION_ID
                               ,l_msg_text
                               ,'GLOBAL_TRADE_ITEM_NUMBER'
                               ,'MTL_SYSTEM_ITEMS_INTERFACE'
                               ,'INV_IOI_ERR'
                               ,l_err_text);
     ELSE
       Debug_Conc_Log('Edit Cross Reference Privilege is present on item');
       -- validating the GTIN
       IF i.EXISTING_GTIN IS NULL THEN
         Debug_Conc_Log('No Existing GTIN found');
         Debug_Conc_Log('Validating GTIN-'||i.GLOBAL_TRADE_ITEM_NUMBER);
         --1. validating GTIN is number or not
         l_error := FALSE;
         l_msg_text := NULL;
         BEGIN
           l_gtin := TO_NUMBER(i.GLOBAL_TRADE_ITEM_NUMBER);
         EXCEPTION WHEN VALUE_ERROR THEN
           Debug_Conc_Log('Validation Failed - GTIN is not a Number');
           l_msg_text := i.GLOBAL_TRADE_ITEM_NUMBER ||' - '||FND_MESSAGE.GET_STRING('EGO', 'EGO_GTIN_NOT_NUMBER');
           dumm_status  := INVPUOPI.mtl_log_interface_err(
                                  i.ORGANIZATION_ID
                                 ,l_user_id
                                 ,l_login_id
                                 ,l_prog_appid
                                 ,l_prog_id
                                 ,l_request_id
                                 ,i.TRANSACTION_ID
                                 ,l_msg_text
                                 ,'GLOBAL_TRADE_ITEM_NUMBER'
                                 ,'MTL_SYSTEM_ITEMS_INTERFACE'
                                 ,'INV_IOI_ERR'
                                 ,l_err_text);
           l_error := TRUE;
         END;

         --2. validating the length of GTIN to be 14
         IF LENGTH(i.GLOBAL_TRADE_ITEM_NUMBER) <> 14 THEN
           Debug_Conc_Log('Validation Failed - Length is not 14 chars');
           l_msg_text := i.GLOBAL_TRADE_ITEM_NUMBER ||' - '||FND_MESSAGE.GET_STRING('EGO', 'EGO_GTIN_LENGTH_NOT_CORRECT');
           dumm_status  := INVPUOPI.mtl_log_interface_err(
                                  i.ORGANIZATION_ID
                                 ,l_user_id
                                 ,l_login_id
                                 ,l_prog_appid
                                 ,l_prog_id
                                 ,l_request_id
                                 ,i.TRANSACTION_ID
                                 ,l_msg_text
                                 ,'GLOBAL_TRADE_ITEM_NUMBER'
                                 ,'MTL_SYSTEM_ITEMS_INTERFACE'
                                 ,'INV_IOI_ERR'
                                 ,l_err_text);
           l_error := TRUE;
         END IF; --end IF LENGTH(i.GLOBAL_TRADE_ITEM_NUMBER

         --3. validating the check digit of GTIN to be valid
         IF (NOT l_error) AND EGO_GTIN_ATTRS_PVT.Is_Check_Digit_Invalid(i.GLOBAL_TRADE_ITEM_NUMBER) THEN
           Debug_Conc_Log('Validation Failed - Check digit is not valid');
           l_msg_text := i.GLOBAL_TRADE_ITEM_NUMBER ||' - '||FND_MESSAGE.GET_STRING('EGO', 'EGO_GTIN_CHECKDIGIT_INVALID');
           dumm_status  := INVPUOPI.mtl_log_interface_err(
                                  i.ORGANIZATION_ID
                                 ,l_user_id
                                 ,l_login_id
                                 ,l_prog_appid
                                 ,l_prog_id
                                 ,l_request_id
                                 ,i.TRANSACTION_ID
                                 ,l_msg_text
                                 ,'GLOBAL_TRADE_ITEM_NUMBER'
                                 ,'MTL_SYSTEM_ITEMS_INTERFACE'
                                 ,'INV_IOI_ERR'
                                 ,l_err_text);
           l_error := TRUE;
         END IF; --end IF (NOT l_error) AND

         --4. gtin can not contain more than six leading zeros
         IF SUBSTR(i.GLOBAL_TRADE_ITEM_NUMBER, 1, 7) = '0000000' THEN
           Debug_Conc_Log('Validation Failed - gtin can not contain more than six leading zeros');
           l_msg_text := i.GLOBAL_TRADE_ITEM_NUMBER ||' - '||FND_MESSAGE.GET_STRING('EGO', 'EGO_GTIN_LEADING_ZERO_INVALID');
           dumm_status  := INVPUOPI.mtl_log_interface_err(
                                  i.ORGANIZATION_ID
                                 ,l_user_id
                                 ,l_login_id
                                 ,l_prog_appid
                                 ,l_prog_id
                                 ,l_request_id
                                 ,i.TRANSACTION_ID
                                 ,l_msg_text
                                 ,'GLOBAL_TRADE_ITEM_NUMBER'
                                 ,'MTL_SYSTEM_ITEMS_INTERFACE'
                                 ,'INV_IOI_ERR'
                                 ,l_err_text);
           l_error := TRUE;
         END IF;

         -- 5. The third digit from the left contained in a GTIN must be 0,1,3,6,7,8,9 when the second digit from the left is 0
         IF SUBSTR(i.GLOBAL_TRADE_ITEM_NUMBER, 2, 1) = '0' AND
            SUBSTR(i.GLOBAL_TRADE_ITEM_NUMBER, 3, 1) NOT IN ('0', '1', '3', '6', '7', '8', '9') THEN
           Debug_Conc_Log('Validation Failed - The third digit from the left contained in a GTIN must be 0,1,3,6,7,8,9 when the second digit from the left is 0 ');
           l_msg_text := i.GLOBAL_TRADE_ITEM_NUMBER ||' - '||FND_MESSAGE.GET_STRING('EGO', 'EGO_GTIN_THIRD_DIGIT_INVALID');
           dumm_status  := INVPUOPI.mtl_log_interface_err(
                                  i.ORGANIZATION_ID
                                 ,l_user_id
                                 ,l_login_id
                                 ,l_prog_appid
                                 ,l_prog_id
                                 ,l_request_id
                                 ,i.TRANSACTION_ID
                                 ,l_msg_text
                                 ,'GLOBAL_TRADE_ITEM_NUMBER'
                                 ,'MTL_SYSTEM_ITEMS_INTERFACE'
                                 ,'INV_IOI_ERR'
                                 ,l_err_text);
           l_error := TRUE;
         END IF;

         -- 6. If a GTIN in a RCI message has six leading zeros, digits 7-9 must be between 301-968
         IF (NOT l_error) AND SUBSTR(i.GLOBAL_TRADE_ITEM_NUMBER, 1, 6) = '000000' AND
            TO_NUMBER(SUBSTR(i.GLOBAL_TRADE_ITEM_NUMBER, 7, 3)) NOT BETWEEN 301 AND 968 THEN
           Debug_Conc_Log('Validation Failed - If a GTIN in a RCI message has six leading zeros, digits 7-9 must be between 301-968');
           l_msg_text := i.GLOBAL_TRADE_ITEM_NUMBER ||' - '||FND_MESSAGE.GET_STRING('EGO', 'EGO_GTIN_7TO9DIGIT_INVALID');
           dumm_status  := INVPUOPI.mtl_log_interface_err(
                                  i.ORGANIZATION_ID
                                 ,l_user_id
                                 ,l_login_id
                                 ,l_prog_appid
                                 ,l_prog_id
                                 ,l_request_id
                                 ,i.TRANSACTION_ID
                                 ,l_msg_text
                                 ,'GLOBAL_TRADE_ITEM_NUMBER'
                                 ,'MTL_SYSTEM_ITEMS_INTERFACE'
                                 ,'INV_IOI_ERR'
                                 ,l_err_text);
           l_error := TRUE;
         END IF;

         -- 7. GTINs submitted in RCI messages cannot contain values 0980-0989 or 099 in the first 4 digits
         IF SUBSTR(i.GLOBAL_TRADE_ITEM_NUMBER, 1, 3) IN ('098', '099') THEN
           Debug_Conc_Log('Validation Failed - GTINs submitted in RCI messages cannot contain values 0980-0989 or 099 in the first 4 digits');
           l_msg_text := i.GLOBAL_TRADE_ITEM_NUMBER ||' - '||FND_MESSAGE.GET_STRING('EGO', 'EGO_GTIN_0TO4_DIGIT_INVALID');
           dumm_status  := INVPUOPI.mtl_log_interface_err(
                                  i.ORGANIZATION_ID
                                 ,l_user_id
                                 ,l_login_id
                                 ,l_prog_appid
                                 ,l_prog_id
                                 ,l_request_id
                                 ,i.TRANSACTION_ID
                                 ,l_msg_text
                                 ,'GLOBAL_TRADE_ITEM_NUMBER'
                                 ,'MTL_SYSTEM_ITEMS_INTERFACE'
                                 ,'INV_IOI_ERR'
                                 ,l_err_text);
           l_error := TRUE;
         END IF;

         -- 8. GTINs submitted in RCI messages cannot contain values 02, 04, 05, and 10-29 in the second and third digits from the left
         IF (NOT l_error) AND (SUBSTR(i.GLOBAL_TRADE_ITEM_NUMBER, 2, 2) IN ('02', '04', '05') OR
             TO_NUMBER(SUBSTR(i.GLOBAL_TRADE_ITEM_NUMBER, 2, 2)) BETWEEN 10 AND 29) THEN
           Debug_Conc_Log('Validation Failed - GTINs submitted in RCI messages cannot contain values 02, 04, 05, and 10-29 in the second and third digits from the left');
           l_msg_text := i.GLOBAL_TRADE_ITEM_NUMBER ||' - '||FND_MESSAGE.GET_STRING('EGO', 'EGO_GTIN_2TO3_DIGIT_INVALID');
           dumm_status  := INVPUOPI.mtl_log_interface_err(
                                  i.ORGANIZATION_ID
                                 ,l_user_id
                                 ,l_login_id
                                 ,l_prog_appid
                                 ,l_prog_id
                                 ,l_request_id
                                 ,i.TRANSACTION_ID
                                 ,l_msg_text
                                 ,'GLOBAL_TRADE_ITEM_NUMBER'
                                 ,'MTL_SYSTEM_ITEMS_INTERFACE'
                                 ,'INV_IOI_ERR'
                                 ,l_err_text);
           l_error := TRUE;
         END IF;

         -- checking for duplicate GTIN
         IF NOT l_error THEN
           BEGIN
             SELECT CONCATENATED_SEGMENTS INTO l_existing_gtin
             FROM MTL_SYSTEM_ITEMS_KFV msik, MTL_CROSS_REFERENCES_B mcr, MTL_PARAMETERS mp
             WHERE msik.INVENTORY_ITEM_ID = mcr.INVENTORY_ITEM_ID
               AND msik.ORGANIZATION_ID = mp.ORGANIZATION_ID
               AND mp.ORGANIZATION_ID = mp.MASTER_ORGANIZATION_ID
               AND mcr.CROSS_REFERENCE_TYPE = 'GTIN'
               AND mcr.CROSS_REFERENCE = i.GLOBAL_TRADE_ITEM_NUMBER
               AND mcr.UOM_CODE = msik.PRIMARY_UOM_CODE
               AND ROWNUM = 1;

             Debug_Conc_Log('Validation Failed - duplicate GTIN');
             FND_MESSAGE.Set_Name('EGO', 'EGO_GTIN_EXISTS_WITH_PACKITEM');
             FND_MESSAGE.Set_Token('GTIN', i.GLOBAL_TRADE_ITEM_NUMBER);
             FND_MESSAGE.Set_Token('PACK_ITEM', l_existing_gtin);
             FND_MESSAGE.Set_Token('UOM', i.PRIMARY_UOM_CODE);
             l_msg_text := i.GLOBAL_TRADE_ITEM_NUMBER ||' - '||FND_MESSAGE.GET;
             dumm_status  := INVPUOPI.mtl_log_interface_err(
                                    i.ORGANIZATION_ID
                                   ,l_user_id
                                   ,l_login_id
                                   ,l_prog_appid
                                   ,l_prog_id
                                   ,l_request_id
                                   ,i.TRANSACTION_ID
                                   ,l_msg_text
                                   ,'GLOBAL_TRADE_ITEM_NUMBER'
                                   ,'MTL_SYSTEM_ITEMS_INTERFACE'
                                   ,'INV_IOI_ERR'
                                   ,l_err_text);
             l_error := TRUE;
           EXCEPTION WHEN NO_DATA_FOUND THEN
             NULL;
           END;
         END IF; -- checking for duplicate GTIN
         -- if no errors then creating a GTIN
         IF NOT l_error THEN
           Debug_Conc_Log('No Errors - Creating GTIN');
           MTL_CROSS_REFERENCES_PKG.INSERT_ROW(
             P_SOURCE_SYSTEM_ID       => NULL,
             P_START_DATE_ACTIVE      => NULL,
             P_END_DATE_ACTIVE        => NULL,
             P_OBJECT_VERSION_NUMBER  => NULL,
             P_UOM_CODE               => i.PRIMARY_UOM_CODE,
             P_REVISION_ID            => NULL,
             P_EPC_GTIN_SERIAL        => NULL,
             P_INVENTORY_ITEM_ID      => i.INVENTORY_ITEM_ID,
             P_ORGANIZATION_ID        => NULL,
             P_CROSS_REFERENCE_TYPE   => 'GTIN',
             P_CROSS_REFERENCE        => i.GLOBAL_TRADE_ITEM_NUMBER,
             P_ORG_INDEPENDENT_FLAG   => 'Y',
             P_REQUEST_ID             => l_request_id,
             P_ATTRIBUTE1             => NULL,
             P_ATTRIBUTE2             => NULL,
             P_ATTRIBUTE3             => NULL,
             P_ATTRIBUTE4             => NULL,
             P_ATTRIBUTE5             => NULL,
             P_ATTRIBUTE6             => NULL,
             P_ATTRIBUTE7             => NULL,
             P_ATTRIBUTE8             => NULL,
             P_ATTRIBUTE9             => NULL,
             P_ATTRIBUTE10            => NULL,
             P_ATTRIBUTE11            => NULL,
             P_ATTRIBUTE12            => NULL,
             P_ATTRIBUTE13            => NULL,
             P_ATTRIBUTE14            => NULL,
             P_ATTRIBUTE15            => NULL,
             P_ATTRIBUTE_CATEGORY     => NULL,
             P_DESCRIPTION            => i.GTIN_DESCRIPTION,
             P_CREATION_DATE          => SYSDATE,
             P_CREATED_BY             => l_user_id,
             P_LAST_UPDATE_DATE       => SYSDATE,
             P_LAST_UPDATED_BY        => l_user_id,
             P_LAST_UPDATE_LOGIN      => l_login_id,
             P_PROGRAM_APPLICATION_ID => l_prog_appid,
             P_PROGRAM_ID             => l_prog_id,
             P_PROGRAM_UPDATE_DATE    => SYSDATE,
             X_CROSS_REFERENCE_ID     => l_xref_id);

           Debug_Conc_Log('Done Creating GTIN');
           l_raise_event := TRUE;
           l_transaction_id := i.TRANSACTION_ID;
           l_org_id := i.ORGANIZATION_ID;
         END IF; -- end IF NOT l_error
       ELSIF i.EXISTING_GTIN IS NOT NULL THEN
         IF i.GTIN_DESCRIPTION IS NOT NULL
             AND (  ( i.EXISTING_GTIN_DESC <> i.GTIN_DESCRIPTION)
                 OR (i.EXISTING_GTIN_DESC IS NULL AND i.GTIN_DESCRIPTION IS NOT NULL)
                 )
         THEN
           Debug_Conc_Log('Existing GTIN found. Description needs to be updated.');
           UPDATE MTL_CROSS_REFERENCES_TL
           SET    DESCRIPTION            = i.GTIN_DESCRIPTION,
                  LAST_UPDATE_DATE       = SYSDATE,
                  LAST_UPDATED_BY        = l_user_id,
                  LAST_UPDATE_LOGIN      = l_login_id,
                  SOURCE_LANG            = USERENV('LANG')
           WHERE CROSS_REFERENCE_ID = i.CROSS_REFERENCE_ID
             AND USERENV('LANG') IN (LANGUAGE, SOURCE_LANG);

           Debug_Conc_Log('Description updated for GTIN='||i.EXISTING_GTIN);
           l_raise_event := TRUE;
           l_transaction_id := i.TRANSACTION_ID;
           l_org_id := i.ORGANIZATION_ID;
         END IF; -- IF i.GTIN_DESCRIPTION IS NOT NULL

         -- BUG 5549140 - Adding validation that existing GTIN can not be changed
         IF i.EXISTING_GTIN <> i.GLOBAL_TRADE_ITEM_NUMBER THEN
           Debug_Conc_Log('GTIN can not be updated');
           FND_MESSAGE.Set_Name('EGO', 'EGO_GTIN_NOT_UPDATEABLE');
           l_msg_text := FND_MESSAGE.GET;
           dumm_status  := INVPUOPI.mtl_log_interface_err(
                                  i.ORGANIZATION_ID
                                 ,l_user_id
                                 ,l_login_id
                                 ,l_prog_appid
                                 ,l_prog_id
                                 ,l_request_id
                                 ,i.TRANSACTION_ID
                                 ,l_msg_text
                                 ,'GLOBAL_TRADE_ITEM_NUMBER'
                                 ,'MTL_SYSTEM_ITEMS_INTERFACE'
                                 ,'INV_IOI_ERR'
                                 ,l_err_text);
         END IF; -- IF i.EXISTING_GTIN <> i.GLOBAL_TRADE_ITEM_NUMBER THEN

       END IF; -- IF i.EXISTING_GTIN IS NULL THEN
     END IF; -- IF NVL(l_priv, 'Y') = 'Y' THEN
   END LOOP;

   IF l_raise_event THEN
     Debug_Conc_Log('Raising business event');
     EGO_WF_WRAPPER_PVT.Raise_Item_Event(
       p_event_name    => l_xref_event_name,
       p_request_id    => l_request_id,
       x_msg_data      => l_msg_data,
       x_return_status => l_return_status);

     Debug_Conc_Log('Done Raising business event with status - '||l_return_status);
     Debug_Conc_Log('Done Raising business event with message - '||SUBSTR(l_msg_data, 3950));
     IF l_return_status <> 'S' THEN
       l_msg_text := SUBSTR('Error in raising business event for GTIN Cross References - '||l_msg_data, 4000);
       dumm_status  := INVPUOPI.mtl_log_interface_err(
                                  l_org_id
                                 ,l_user_id
                                 ,l_login_id
                                 ,l_prog_appid
                                 ,l_prog_id
                                 ,l_request_id
                                 ,l_transaction_id
                                 ,l_msg_text
                                 ,'GLOBAL_TRADE_ITEM_NUMBER'
                                 ,'MTL_SYSTEM_ITEMS_INTERFACE'
                                 ,'INV_IOI_ERR'
                                 ,l_err_text);
     END IF;
   END IF;

   COMMIT;
   RETCODE := '0';
   ERRBUF := NULL;
   Debug_Conc_Log('Done Process_Gtin_Intf_Rows with success');
 EXCEPTION WHEN OTHERS THEN
   Debug_Conc_Log('Done Process_Gtin_Intf_Rows with error - '||SQLERRM);
   RETCODE := '2';
   ERRBUF := 'Error in method EGO_IMPORT_PVT.Process_Gtin_Intf_Rows - '||SQLERRM;
 END Process_Gtin_Intf_Rows;

 /*
  * Private method to process Source System item cross reference
  */
 FUNCTION Process_SSXref_Pvt(p_source_system_id                 IN NUMBER,
                             p_source_system_reference        IN VARCHAR2,
                             p_source_system_reference_desc   IN VARCHAR2,
                             p_inventory_item_id                  IN NUMBER)
 RETURN BOOLEAN
 IS
   l_rowid             ROWID;
   l_xref_id           NUMBER;
   l_user_id           NUMBER := FND_GLOBAL.USER_ID;
   l_login_id          NUMBER := FND_GLOBAL.LOGIN_ID;
   l_prog_appid        NUMBER := FND_GLOBAL.PROG_APPL_ID;
   l_prog_id           NUMBER := FND_GLOBAL.CONC_PROGRAM_ID;
   l_request_id        NUMBER := FND_GLOBAL.CONC_REQUEST_ID;
   l_raise_event       BOOLEAN;
   l_msg_data          VARCHAR2(4000);
   l_return_status     VARCHAR2(10);
   l_msg_text          VARCHAR2(4000);
   l_err_text          VARCHAR2(4000);
   dumm_status         NUMBER;
   l_item_id           NUMBER;
 BEGIN
   Debug_Conc_Log('In Process_SSXref_Pvt begin');
   l_raise_event := FALSE;
   -- if a cross reference already exists for the source system item, then end dating it
   BEGIN
     SELECT ROWID, INVENTORY_ITEM_ID INTO l_rowid, l_item_id
     FROM MTL_CROSS_REFERENCES_B mcr
     WHERE mcr.SOURCE_SYSTEM_ID = p_source_system_id
       AND mcr.CROSS_REFERENCE_TYPE = 'SS_ITEM_XREF'
       AND mcr.CROSS_REFERENCE = p_source_system_reference
       AND (mcr.END_DATE_ACTIVE IS NULL OR mcr.END_DATE_ACTIVE > SYSDATE);

     Debug_Conc_Log('Existing Xref found l_item_id='||to_char(l_item_id));
     IF p_inventory_item_id <> NVL(l_item_id, -1) THEN
       Debug_Conc_Log('Updating the existing SS Xref, end dating');
       UPDATE MTL_CROSS_REFERENCES_B
       SET
         END_DATE_ACTIVE = SYSDATE,
         LAST_UPDATED_BY = l_user_id,
         LAST_UPDATE_DATE = SYSDATE,
         LAST_UPDATE_LOGIN = l_login_id,
         PROGRAM_APPLICATION_ID = l_prog_appid,
         PROGRAM_ID = l_prog_id,
         REQUEST_ID = l_request_id,
         PROGRAM_UPDATE_DATE = SYSDATE
       WHERE ROWID = l_rowid;
       Debug_Conc_Log('Done Updating the existing SS Xref, end dating');
       l_raise_event := TRUE;
     END IF; --IF p_inventory_item_id <> NVL(l_item_id, -1) THEN
   EXCEPTION WHEN NO_DATA_FOUND THEN
     Debug_Conc_Log('No Existing SS Xref Found');
     l_item_id := -1;
     NULL;
   END;

   IF p_inventory_item_id <> NVL(l_item_id, -1) THEN
     -- calling MTL_CROSS_REFERENCES_B table handler to insert rows
     Debug_Conc_Log('Creating SS Xref');
     MTL_CROSS_REFERENCES_PKG.INSERT_ROW(
         P_SOURCE_SYSTEM_ID       => p_source_system_id,
         P_START_DATE_ACTIVE      => SYSDATE,
         P_END_DATE_ACTIVE        => NULL,
         P_OBJECT_VERSION_NUMBER  => NULL,
         P_UOM_CODE               => NULL,
         P_REVISION_ID            => NULL,
         P_EPC_GTIN_SERIAL        => NULL,
         P_INVENTORY_ITEM_ID      => p_inventory_item_id,
         P_ORGANIZATION_ID        => NULL,
         P_CROSS_REFERENCE_TYPE   => 'SS_ITEM_XREF',
         P_CROSS_REFERENCE        => p_source_system_reference,
         P_ORG_INDEPENDENT_FLAG   => 'Y',
         P_REQUEST_ID             => l_request_id,
         P_ATTRIBUTE1             => NULL,
         P_ATTRIBUTE2             => NULL,
         P_ATTRIBUTE3             => NULL,
         P_ATTRIBUTE4             => NULL,
         P_ATTRIBUTE5             => NULL,
         P_ATTRIBUTE6             => NULL,
         P_ATTRIBUTE7             => NULL,
         P_ATTRIBUTE8             => NULL,
         P_ATTRIBUTE9             => NULL,
         P_ATTRIBUTE10            => NULL,
         P_ATTRIBUTE11            => NULL,
         P_ATTRIBUTE12            => NULL,
         P_ATTRIBUTE13            => NULL,
         P_ATTRIBUTE14            => NULL,
         P_ATTRIBUTE15            => NULL,
         P_ATTRIBUTE_CATEGORY     => NULL,
         P_DESCRIPTION            => p_source_system_reference_desc,
         P_CREATION_DATE          => SYSDATE,
         P_CREATED_BY             => l_user_id,
         P_LAST_UPDATE_DATE       => SYSDATE,
         P_LAST_UPDATED_BY        => l_user_id,
         P_LAST_UPDATE_LOGIN      => l_login_id,
         P_PROGRAM_APPLICATION_ID => l_prog_appid,
         P_PROGRAM_ID             => l_prog_id,
         P_PROGRAM_UPDATE_DATE    => SYSDATE,
         X_CROSS_REFERENCE_ID     => l_xref_id);

     l_raise_event := TRUE;
   END IF; --IF p_inventory_item_id <> NVL(l_item_id, -1) THEN
   Debug_Conc_Log('Done Process_SSXref_Pvt');
   RETURN l_raise_event;
 END Process_SSXref_Pvt;

 /*
  * This method Bulk Loads the Source system cross references
  */
 PROCEDURE Process_SSXref_Intf_Rows(ERRBUF  OUT NOCOPY VARCHAR2,
                                    RETCODE OUT NOCOPY VARCHAR2,
                                    p_data_set_id IN  NUMBER) IS
   CURSOR c_intf_rows IS
     SELECT
       SOURCE_SYSTEM_ID,
       SOURCE_SYSTEM_REFERENCE,
       SOURCE_SYSTEM_REFERENCE_DESC,
       INVENTORY_ITEM_ID,
       ORGANIZATION_ID,
       TRANSACTION_ID,
       TRANSACTION_TYPE
     FROM MTL_SYSTEM_ITEMS_INTERFACE msi
     WHERE msi.PROCESS_FLAG IN (5, 7)
       AND msi.SET_PROCESS_ID = p_data_set_id
       AND msi.SOURCE_SYSTEM_ID IS NOT NULL
       AND msi.SOURCE_SYSTEM_REFERENCE IS NOT NULL
       AND msi.REQUEST_ID = FND_GLOBAL.CONC_REQUEST_ID
       AND NOT EXISTS (SELECT NULL
                       FROM MTL_CROSS_REFERENCES_B mcr
                       WHERE mcr.SOURCE_SYSTEM_ID = msi.SOURCE_SYSTEM_ID
                         AND mcr.CROSS_REFERENCE_TYPE = 'SS_ITEM_XREF'
                         AND mcr.CROSS_REFERENCE = msi.SOURCE_SYSTEM_REFERENCE
                         AND mcr.INVENTORY_ITEM_ID = msi.INVENTORY_ITEM_ID
                         AND (mcr.END_DATE_ACTIVE IS NULL OR mcr.END_DATE_ACTIVE > SYSDATE));

   -- Bug: 4752861
   CURSOR c_intf_existing_rows IS
     SELECT
       msi.SOURCE_SYSTEM_ID,
       msi.SOURCE_SYSTEM_REFERENCE,
       msi.SOURCE_SYSTEM_REFERENCE_DESC,
       msi.INVENTORY_ITEM_ID,
       msi.ORGANIZATION_ID,
       msi.TRANSACTION_ID,
       msi.TRANSACTION_TYPE,
       mcr.CROSS_REFERENCE_ID
     FROM MTL_SYSTEM_ITEMS_INTERFACE msi, MTL_CROSS_REFERENCES mcr
     WHERE msi.PROCESS_FLAG IN (5, 7)
       AND msi.SET_PROCESS_ID = p_data_set_id
       AND msi.SOURCE_SYSTEM_ID IS NOT NULL
       AND msi.SOURCE_SYSTEM_REFERENCE IS NOT NULL
       AND msi.REQUEST_ID = FND_GLOBAL.CONC_REQUEST_ID
       AND mcr.SOURCE_SYSTEM_ID = msi.SOURCE_SYSTEM_ID
       AND mcr.CROSS_REFERENCE_TYPE = 'SS_ITEM_XREF'
       AND mcr.CROSS_REFERENCE = msi.SOURCE_SYSTEM_REFERENCE
       AND mcr.INVENTORY_ITEM_ID = msi.INVENTORY_ITEM_ID
       AND msi.SOURCE_SYSTEM_REFERENCE_DESC IS NOT NULL
       AND NVL(mcr.DESCRIPTION, msi.SOURCE_SYSTEM_REFERENCE_DESC||'##') <> msi.SOURCE_SYSTEM_REFERENCE_DESC
       AND UPPER(msi.TRANSACTION_TYPE) <> 'CREATE'
       AND (mcr.END_DATE_ACTIVE IS NULL OR mcr.END_DATE_ACTIVE > SYSDATE);

   -- Bug: 5262421 - Introducing 11 as new process_status. When user chooses to re-import and Import Only Cross References
   -- is true, then we move the status of MSII record to 11, so that it will not be picked up by any other IOI program
   -- running with option "Process All Batch". So while creating Xrefs, we will also pick up records with process_status = 11
   CURSOR c_unprcd_intf_rows IS
     SELECT
       SOURCE_SYSTEM_ID,
       SOURCE_SYSTEM_REFERENCE,
       SOURCE_SYSTEM_REFERENCE_DESC,
       INVENTORY_ITEM_ID,
       ITEM_NUMBER,
       ORGANIZATION_ID,
       TRANSACTION_ID,
       TRANSACTION_TYPE,
       ROWID AS ROW_ID
     FROM MTL_SYSTEM_ITEMS_INTERFACE msi
     WHERE msi.PROCESS_FLAG IN (0, 11)
       AND msi.SET_PROCESS_ID = p_data_set_id
       AND msi.SOURCE_SYSTEM_ID IS NOT NULL
       AND msi.SOURCE_SYSTEM_REFERENCE IS NOT NULL
       AND msi.CONFIRM_STATUS IN ('CM', 'CC')
       AND NOT EXISTS (SELECT NULL
                       FROM MTL_CROSS_REFERENCES_B mcr
                       WHERE mcr.SOURCE_SYSTEM_ID = msi.SOURCE_SYSTEM_ID
                         AND mcr.CROSS_REFERENCE_TYPE = 'SS_ITEM_XREF'
                         AND mcr.CROSS_REFERENCE = msi.SOURCE_SYSTEM_REFERENCE
                         AND mcr.INVENTORY_ITEM_ID = msi.INVENTORY_ITEM_ID
                         AND (mcr.END_DATE_ACTIVE IS NULL OR mcr.END_DATE_ACTIVE > SYSDATE));

   -- Bug: 4752861
   CURSOR c_unprcd_intf_existing_rows IS
     SELECT
       msi.SOURCE_SYSTEM_ID,
       msi.SOURCE_SYSTEM_REFERENCE,
       msi.SOURCE_SYSTEM_REFERENCE_DESC,
       msi.INVENTORY_ITEM_ID,
       msi.ITEM_NUMBER,
       msi.ORGANIZATION_ID,
       msi.TRANSACTION_ID,
       msi.TRANSACTION_TYPE,
       mcr.CROSS_REFERENCE_ID,
       msi.ROWID AS ROW_ID
     FROM MTL_SYSTEM_ITEMS_INTERFACE msi, MTL_CROSS_REFERENCES mcr
     WHERE msi.PROCESS_FLAG IN (0, 11)
       AND msi.SET_PROCESS_ID = p_data_set_id
       AND msi.SOURCE_SYSTEM_ID IS NOT NULL
       AND msi.SOURCE_SYSTEM_REFERENCE IS NOT NULL
       AND msi.CONFIRM_STATUS IN ('CM', 'CC')
       AND mcr.SOURCE_SYSTEM_ID = msi.SOURCE_SYSTEM_ID
       AND mcr.CROSS_REFERENCE_TYPE = 'SS_ITEM_XREF'
       AND mcr.CROSS_REFERENCE = msi.SOURCE_SYSTEM_REFERENCE
       AND mcr.INVENTORY_ITEM_ID = msi.INVENTORY_ITEM_ID
       AND msi.SOURCE_SYSTEM_REFERENCE_DESC IS NOT NULL
       AND NVL(mcr.DESCRIPTION, msi.SOURCE_SYSTEM_REFERENCE_DESC||'##') <> msi.SOURCE_SYSTEM_REFERENCE_DESC
       AND UPPER(msi.TRANSACTION_TYPE) <> 'CREATE'
       AND (mcr.END_DATE_ACTIVE IS NULL OR mcr.END_DATE_ACTIVE > SYSDATE);

   l_xref_event_name               CONSTANT VARCHAR2(100) := 'oracle.apps.ego.item.postXrefChange';
   l_ss_id                         NUMBER;
   l_raise_event                   BOOLEAN;
   l_raise_bus_event               BOOLEAN;
   l_user_id                       NUMBER := FND_GLOBAL.USER_ID;
   l_login_id                      NUMBER := FND_GLOBAL.LOGIN_ID;
   l_prog_appid                    NUMBER := FND_GLOBAL.PROG_APPL_ID;
   l_prog_id                       NUMBER := FND_GLOBAL.CONC_PROGRAM_ID;
   l_request_id                    NUMBER := FND_GLOBAL.CONC_REQUEST_ID;
   l_msg_data                      VARCHAR2(4000);
   l_err_text                      VARCHAR2(4000);
   l_return_status                 VARCHAR2(10);
   l_msg_text                      VARCHAR2(4000);
   dumm_status                     NUMBER;
   l_org_id                        NUMBER;

   l_import_xref_only              EGO_IMPORT_OPTION_SETS.IMPORT_XREF_ONLY%TYPE;
   l_inventory_item_id             MTL_SYSTEM_ITEMS_INTERFACE.INVENTORY_ITEM_ID%TYPE;
   l_transaction_id                MTL_SYSTEM_ITEMS_INTERFACE.TRANSACTION_ID%TYPE;
 BEGIN
   Debug_Conc_Log('Starting Process_SSXref_Intf_Rows for batch_id='||TO_CHAR(p_data_set_id));
   BEGIN
     SELECT b.SOURCE_SYSTEM_ID, NVL(opt.IMPORT_XREF_ONLY, 'N')
     INTO l_ss_id, l_import_xref_only
     FROM EGO_IMPORT_BATCHES_B b, EGO_IMPORT_OPTION_SETS opt
     WHERE b.BATCH_ID = p_data_set_id
       AND b.BATCH_ID = opt.BATCH_ID;
   EXCEPTION WHEN NO_DATA_FOUND THEN
     l_ss_id := get_pdh_source_system_id;
     l_import_xref_only := 'N';
   END;

   IF l_ss_id = get_pdh_source_system_id THEN
     Debug_Conc_Log('Batch is a PDH batch, so returning');
     RETCODE := '0';
     ERRBUF := NULL;
     RETURN;
   END IF;

   l_raise_bus_event := FALSE;
   IF l_import_xref_only = 'Y' THEN
     Debug_Conc_Log('Import Only Cross References is TRUE');
     Debug_Conc_Log('Updating the Source System Description');
     FOR i IN c_unprcd_intf_existing_rows LOOP
       Debug_Conc_Log('Processing for SS_ID, SS_REF='||TO_CHAR(i.SOURCE_SYSTEM_ID)||', '||i.SOURCE_SYSTEM_REFERENCE);
       l_inventory_item_id := i.INVENTORY_ITEM_ID;

       IF l_inventory_item_id IS NOT NULL THEN
         UPDATE MTL_CROSS_REFERENCES_TL
         SET    DESCRIPTION       = i.SOURCE_SYSTEM_REFERENCE_DESC,
                LAST_UPDATE_DATE  = SYSDATE,
                LAST_UPDATED_BY   = FND_GLOBAL.USER_ID,
                LAST_UPDATE_LOGIN = FND_GLOBAL.LOGIN_ID,
                SOURCE_LANG       = USERENV('LANG')
         WHERE CROSS_REFERENCE_ID = i.CROSS_REFERENCE_ID
           AND USERENV('LANG') IN (LANGUAGE, SOURCE_LANG);

         l_raise_bus_event := TRUE;
         l_transaction_id := i.TRANSACTION_ID;
         l_org_id := i.ORGANIZATION_ID;

         -- Bug: 5262421
         -- Updating item, user-defined attrs, gdsn attrs, AMLs to successful process status
         -- so that they appear correctly in the Imported tab
         UPDATE MTL_SYSTEM_ITEMS_INTERFACE
         SET PROCESS_FLAG = 7,
             TRANSACTION_TYPE = 'UPDATE',
             PROGRAM_APPLICATION_ID = l_prog_appid,
             PROGRAM_ID = l_prog_id,
             REQUEST_ID = l_request_id,
             PROGRAM_UPDATE_DATE = SYSDATE
         WHERE ROWID = i.ROW_ID;

         UPDATE EGO_ITM_USR_ATTR_INTRFC
         SET PROCESS_STATUS = 4,
             PROGRAM_APPLICATION_ID = l_prog_appid,
             PROGRAM_ID = l_prog_id,
             REQUEST_ID = l_request_id,
             PROGRAM_UPDATE_DATE = SYSDATE
         WHERE DATA_SET_ID = p_data_set_id
           AND PROCESS_STATUS = 0
           AND SOURCE_SYSTEM_ID = i.SOURCE_SYSTEM_ID
           AND SOURCE_SYSTEM_REFERENCE = i.SOURCE_SYSTEM_REFERENCE;

         UPDATE EGO_AML_INTF
         SET PROCESS_FLAG = 7,
             PROGRAM_APPLICATION_ID = l_prog_appid,
             PROGRAM_ID = l_prog_id,
             REQUEST_ID = l_request_id,
             PROGRAM_UPDATE_DATE = SYSDATE
         WHERE DATA_SET_ID = p_data_set_id
           AND PROCESS_FLAG = 0
           AND SOURCE_SYSTEM_ID = i.SOURCE_SYSTEM_ID
           AND SOURCE_SYSTEM_REFERENCE = i.SOURCE_SYSTEM_REFERENCE;
       ELSE
         Debug_Conc_Log('Inventory Item ID is NULL');
       END IF; --IF l_inventory_item_id IS NOT NULL THEN
     END LOOP; --FOR i IN c_unprcd_intf_existing_rows LOOP
     Debug_Conc_Log('Done Updating the Source System Description');

     Debug_Conc_Log('Processing Source System Cross references that does not exist in PDH');
     FOR i IN c_unprcd_intf_rows LOOP
       Debug_Conc_Log('Processing for SS_ID, SS_REF='||TO_CHAR(i.SOURCE_SYSTEM_ID)||', '||i.SOURCE_SYSTEM_REFERENCE);
       IF i.INVENTORY_ITEM_ID IS NULL THEN
         BEGIN
           SELECT INVENTORY_ITEM_ID INTO l_inventory_item_id
           FROM MTL_SYSTEM_ITEMS_B_KFV
           WHERE CONCATENATED_SEGMENTS = i.ITEM_NUMBER
             AND ORGANIZATION_ID = i.ORGANIZATION_ID;
         EXCEPTION WHEN NO_DATA_FOUND THEN
           Debug_Conc_Log('Inventory Item Id is NULL and no Matching Item found for Item Number-'||i.ITEM_NUMBER);
           l_inventory_item_id := NULL;
         END;
       ELSE
         l_inventory_item_id := i.INVENTORY_ITEM_ID;
       END IF; --IF i.INVENTORY_ITEM_ID IS NULL THEN

       IF l_inventory_item_id IS NOT NULL THEN
         l_raise_event := Process_SSXref_Pvt(
                                p_source_system_id               => i.SOURCE_SYSTEM_ID,
                                p_source_system_reference        => i.SOURCE_SYSTEM_REFERENCE,
                                p_source_system_reference_desc   => i.SOURCE_SYSTEM_REFERENCE_DESC,
                                p_inventory_item_id              => l_inventory_item_id);
         IF l_raise_event THEN
           l_raise_bus_event := TRUE;
           -- Bug: 5262421
           -- Updating item, user-defined attrs, gdsn attrs, AMLs to successful process status
           -- so that they appear correctly in the Imported tab
           UPDATE MTL_SYSTEM_ITEMS_INTERFACE
           SET PROCESS_FLAG = 7,
               TRANSACTION_TYPE = 'UPDATE',
               PROGRAM_APPLICATION_ID = l_prog_appid,
               PROGRAM_ID = l_prog_id,
               REQUEST_ID = l_request_id,
               PROGRAM_UPDATE_DATE = SYSDATE
           WHERE ROWID = i.ROW_ID;

           UPDATE EGO_ITM_USR_ATTR_INTRFC
           SET PROCESS_STATUS = 4,
               PROGRAM_APPLICATION_ID = l_prog_appid,
               PROGRAM_ID = l_prog_id,
               REQUEST_ID = l_request_id,
               PROGRAM_UPDATE_DATE = SYSDATE
           WHERE DATA_SET_ID = p_data_set_id
             AND PROCESS_STATUS = 0
             AND SOURCE_SYSTEM_ID = i.SOURCE_SYSTEM_ID
             AND SOURCE_SYSTEM_REFERENCE = i.SOURCE_SYSTEM_REFERENCE;

           UPDATE EGO_AML_INTF
           SET PROCESS_FLAG = 7,
               PROGRAM_APPLICATION_ID = l_prog_appid,
               PROGRAM_ID = l_prog_id,
               REQUEST_ID = l_request_id,
               PROGRAM_UPDATE_DATE = SYSDATE
           WHERE DATA_SET_ID = p_data_set_id
             AND PROCESS_FLAG = 0
             AND SOURCE_SYSTEM_ID = i.SOURCE_SYSTEM_ID
             AND SOURCE_SYSTEM_REFERENCE = i.SOURCE_SYSTEM_REFERENCE;
         END IF; --IF l_raise_event THEN
         l_transaction_id := i.TRANSACTION_ID;
         l_org_id := i.ORGANIZATION_ID;
       ELSE
         Debug_Conc_Log('Inventory Item ID is NULL, so not calling Process_SSXref_Pvt');
       END IF; --IF l_inventory_item_id IS NOT NULL THEN
     END LOOP;
   ELSE --IF l_import_xref_only = 'Y' THEN
     Debug_Conc_Log('Import Only Cross References is FALSE');
     Debug_Conc_Log('Updating the Source System Description');
     FOR i IN c_intf_existing_rows LOOP
       Debug_Conc_Log('Processing for SS_ID, SS_REF='||TO_CHAR(i.SOURCE_SYSTEM_ID)||', '||i.SOURCE_SYSTEM_REFERENCE);
       l_inventory_item_id := i.INVENTORY_ITEM_ID;

       IF l_inventory_item_id IS NOT NULL THEN
         UPDATE MTL_CROSS_REFERENCES_TL
         SET    DESCRIPTION       = i.SOURCE_SYSTEM_REFERENCE_DESC,
                LAST_UPDATE_DATE  = SYSDATE,
                LAST_UPDATED_BY   = FND_GLOBAL.USER_ID,
                LAST_UPDATE_LOGIN = FND_GLOBAL.LOGIN_ID,
                SOURCE_LANG       = USERENV('LANG')
         WHERE CROSS_REFERENCE_ID = i.CROSS_REFERENCE_ID
           AND USERENV('LANG') IN (LANGUAGE, SOURCE_LANG);

         l_raise_bus_event := TRUE;
         l_transaction_id := i.TRANSACTION_ID;
         l_org_id := i.ORGANIZATION_ID;
       ELSE
         Debug_Conc_Log('Inventory Item ID is NULL');
       END IF; --IF l_inventory_item_id IS NOT NULL THEN
     END LOOP; --FOR i IN c_intf_existing_rows LOOP
     Debug_Conc_Log('Done Updating the Source System Description');

     Debug_Conc_Log('Processing Source System Cross references that does not exist in PDH');
     FOR i IN c_intf_rows LOOP
       Debug_Conc_Log('Processing for SS_ID, SS_REF='||TO_CHAR(i.SOURCE_SYSTEM_ID)||', '||i.SOURCE_SYSTEM_REFERENCE);
       l_raise_event := Process_SSXref_Pvt(
                              p_source_system_id                 => i.SOURCE_SYSTEM_ID,
                              p_source_system_reference      => i.SOURCE_SYSTEM_REFERENCE,
                              p_source_system_reference_desc => i.SOURCE_SYSTEM_REFERENCE_DESC,
                              p_inventory_item_id                => i.INVENTORY_ITEM_ID);
       IF l_raise_event THEN
         l_raise_bus_event := TRUE;
       END IF; --IF l_raise_event THEN
       l_transaction_id := i.TRANSACTION_ID;
       l_org_id := i.ORGANIZATION_ID;
     END LOOP;
   END IF; --IF l_import_xref_only = 'Y' THEN

   IF l_raise_bus_event THEN
     Debug_Conc_Log('Raising business event');
     EGO_WF_WRAPPER_PVT.Raise_Item_Event(
       p_event_name    => l_xref_event_name,
       p_request_id    => l_request_id,
       x_msg_data      => l_msg_data,
       x_return_status => l_return_status);

     Debug_Conc_Log('Done Raising business event with status - '||l_return_status);
     Debug_Conc_Log('Done Raising business event with message - '||SUBSTR(l_msg_data, 3950));
     IF l_return_status <> 'S' THEN
       l_msg_text := SUBSTR('Error in raising business event for Source System Item Cross References - '||l_msg_data, 4000);
       dumm_status  := INVPUOPI.mtl_log_interface_err(
                                  l_org_id
                                 ,l_user_id
                                 ,l_login_id
                                 ,l_prog_appid
                                 ,l_prog_id
                                 ,l_request_id
                                 ,l_transaction_id
                                 ,l_msg_text
                                 ,'SOURCE_SYSTEM_REFERENCE'
                                 ,'MTL_SYSTEM_ITEMS_INTERFACE'
                                 ,'INV_IOI_ERR'
                                 ,l_err_text);
     END IF; --IF l_return_status <> 'S' THEN
   END IF; --IF l_raise_event THEN

   --COMMIT;
   RETCODE := '0';
   ERRBUF := NULL;
   Debug_Conc_Log('Done Process_SSXref_Intf_Rows with success');
 EXCEPTION WHEN OTHERS THEN
   RETCODE := '2';
   ERRBUF := 'Error in method EGO_IMPORT_PVT.Process_SSXref_Intf_Rows - '||SQLERRM;
   Debug_Conc_Log('Done Process_SSXref_Intf_Rows with error - '||SQLERRM);
 END Process_SSXref_Intf_Rows;

    /*
     * This method sets the confirm_status for an unprocessed row (process_flag = 0) in the master org
     * for a source system item identified by p_source_system_id and p_source_system_reference.
     * p_status can have the following values:
     * G_CONF_XREF  -- expecting p_inventory_item_id to be passed
     * G_CONF_MATCH -- expecting p_inventory_item_id to be passed
     * G_CONF_NEW   -- expecting no p_inventory_item_id to be passed
     * G_UNCONF_NONE_MATCH -- expecting no p_inventory_item_id to be passed
     * G_UNCONF_SIGL_MATCH -- expecting p_inventory_item_id to be passed
     * G_UNCONF_MULT_MATCH -- p_inventory_item_id is optional
     */
    PROCEDURE Set_Confirm_Status(p_data_set_id IN  NUMBER,
                                 p_source_system_id IN VARCHAR2,
                                 p_source_system_reference IN VARCHAR2,
                                 p_status IN VARCHAR2,
                                 p_inventory_item_id IN NUMBER DEFAULT NULL,
                                 p_organization_id IN NUMBER DEFAULT NULL)
    IS
      l_org_id    MTL_PARAMETERS.ORGANIZATION_ID%TYPE;
      l_org_code  MTL_PARAMETERS.ORGANIZATION_CODE%TYPE;
      unexpected_parameters EXCEPTION;
    BEGIN
        -- Check that the parameters satisfy the assumptions: if they don't, raise error

        -- Status should be one of the constants
        IF p_status NOT IN ( G_CONF_XREF, G_CONF_MATCH, G_CONF_NEW
                           , G_UNCONF_NONE_MATCH, G_UNCONF_SIGL_MATCH, G_UNCONF_MULT_MATCH )
        THEN
            RAISE unexpected_parameters;
        END IF;

        -- Item id must be passed for cross-referenced, confirmed matches, and unconfirmed single matches
        IF p_inventory_item_id IS NULL AND p_status IN ( G_CONF_XREF, G_CONF_MATCH, G_UNCONF_SIGL_MATCH )
        THEN
            RAISE unexpected_parameters;
        END IF;

        -- Item id cannot be passed for confirmed new items, and no-match items
        IF p_inventory_item_id IS NOT NULL AND p_status IN ( G_CONF_NEW, G_UNCONF_NONE_MATCH )
        THEN
            RAISE unexpected_parameters;
        END IF;

        SELECT
         MP.ORGANIZATION_ID,
         MP.ORGANIZATION_CODE
        INTO l_org_id, l_org_code
        FROM MTL_PARAMETERS MP,
         EGO_IMPORT_BATCHES_B BA
        WHERE BA.ORGANIZATION_ID = MP.ORGANIZATION_ID AND
         BA.BATCH_ID = p_data_set_id;

        -- Set the confirm status and item number based on the parameters
        -- Rows that already have a "fake" confirm_status are kept "fake"
  /* Bug 8621347. Do not modify ITEM_NUMBER if p_status is G_UNCONF_NONE_MATCH.
           If p_status is G_CONF_NEW, update ITEM_NUMBER with SOURCE_SYSTEM_REFERENCE, if ITEM_NUMBER is not provided, otherwise
           retain ITEM_NUMBER.
           If p_status is G_CONF_NEW, update DESCRIPTION with SOURCE_SYSTEM_REFERENCE_DES, if DESCRIPTION is not provided, otherwise
           retain DESCRIPTION.
        */
        UPDATE MTL_SYSTEM_ITEMS_INTERFACE
        SET PROCESS_FLAG = 0,
         ORGANIZATION_ID = l_org_id,
         ORGANIZATION_CODE = l_org_code,
         INVENTORY_ITEM_ID = p_inventory_item_id,
         ITEM_NUMBER = Decode(p_status,
                              G_CONF_NEW,Decode(ITEM_NUMBER,NULL,SOURCE_SYSTEM_REFERENCE,ITEM_NUMBER),
                              G_UNCONF_NONE_MATCH,ITEM_NUMBER,(SELECT CONCATENATED_SEGMENTS
                                                               FROM MTL_SYSTEM_ITEMS_KFV
                                                               WHERE INVENTORY_ITEM_ID = p_inventory_item_id AND ORGANIZATION_ID = p_organization_id)
                             ),
         DESCRIPTION = Decode(p_status,G_CONF_NEW,Decode(DESCRIPTION,NULL,SOURCE_SYSTEM_REFERENCE_DESC,DESCRIPTION),DESCRIPTION),
         CONFIRM_STATUS =
            CASE
            WHEN CONFIRM_STATUS IN ( G_CONF_XREF_FAKE, G_CONF_MATCH_FAKE, G_FAKE_CONF_STATUS_FLAG
                                   , G_UNCONF_NO_MATCH_FAKE, G_UNCONF_MULTI_MATCH_FAKE, G_UNCONF_SINGLE_MATCH_FAKE )
            THEN (  CASE p_status
                    WHEN G_CONF_XREF            THEN G_CONF_XREF_FAKE
                    WHEN G_CONF_MATCH           THEN G_CONF_MATCH_FAKE
                    WHEN G_UNCONF_SIGL_MATCH    THEN G_UNCONF_SINGLE_MATCH_FAKE
                    WHEN G_UNCONF_MULT_MATCH    THEN G_UNCONF_MULTI_MATCH_FAKE
                    WHEN G_UNCONF_NONE_MATCH    THEN G_UNCONF_NO_MATCH_FAKE
                    ELSE p_status
                    END
                 )
            ELSE p_status
            END
        WHERE
         SET_PROCESS_ID = p_data_set_id AND
         SOURCE_SYSTEM_ID = p_source_system_id AND
         SOURCE_SYSTEM_REFERENCE = p_source_system_reference AND
         (PROCESS_FLAG = 0 OR PROCESS_FLAG IS NULL) AND
         (   (ORGANIZATION_ID IS NULL AND ORGANIZATION_CODE IS NULL) OR
              ORGANIZATION_ID = l_org_id OR
             (ORGANIZATION_ID IS NULL AND ORGANIZATION_CODE = l_org_code)
         );
    END Set_Confirm_Status;

    /*
     * this function checks if the user has to provide revision information
     * based on the data and revision import policy
     */
    FUNCTION IS_NEW_REVISION_INFO_NEEDED
    (
       p_batch_id                        IN  EGO_ITM_USR_ATTR_INTRFC.DATA_SET_ID%TYPE
     , p_source_system_id                IN  EGO_ITM_USR_ATTR_INTRFC.SOURCE_SYSTEM_ID%TYPE
     , p_source_system_reference         IN  EGO_ITM_USR_ATTR_INTRFC.SOURCE_SYSTEM_REFERENCE%TYPE
     , p_organization_id                 IN  EGO_ITM_USR_ATTR_INTRFC.ORGANIZATION_ID%TYPE
     , p_organization_code               IN  EGO_ITM_USR_ATTR_INTRFC.ORGANIZATION_CODE%TYPE
     , p_instance_rev_policy             IN  EGO_IMPORT_OPTION_SETS.REVISION_IMPORT_POLICY%TYPE
    )
    RETURN BOOLEAN IS
        l_temp VARCHAR2(1);
    BEGIN
        IF p_instance_rev_policy IN ('S', 'L')  THEN
          RETURN false;
        END IF;

        SELECT 'x' INTO l_temp
        FROM MTL_ITEM_REVISIONS_INTERFACE MIRI
        WHERE SET_PROCESS_ID = p_batch_id AND
              PROCESS_FLAG = 0 AND
              SOURCE_SYSTEM_ID = p_source_system_id AND
              SOURCE_SYSTEM_REFERENCE = p_source_system_reference AND
              (ORGANIZATION_ID = p_organization_id OR ORGANIZATION_CODE = p_organization_code) AND
              REVISION IS NOT NULL AND
              Upper(REVISION) NOT IN ( SELECT B.REVISION FROM MTL_ITEM_REVISIONS_B B, MTL_SYSTEM_ITEMS_INTERFACE MSII
                                  WHERE MSII.SOURCE_SYSTEM_REFERENCE = MIRI.SOURCE_SYSTEM_REFERENCE
                                    AND MSII.SOURCE_SYSTEM_ID = MIRI.SOURCE_SYSTEM_ID
                                    AND (MSII.ORGANIZATION_ID = MIRI.ORGANIZATION_ID
                                         OR MSII.ORGANIZATION_CODE = MIRI.ORGANIZATION_CODE)
                                    AND MSII.SET_PROCESS_ID = MIRI.SET_PROCESS_ID
                                    AND MSII.PROCESS_FLAG = 0
                                    AND B.INVENTORY_ITEM_ID = MSII.INVENTORY_ITEM_ID
                              ) AND
              EFFECTIVITY_DATE IS NOT NULL AND
              UPPER(TRANSACTION_TYPE) = 'CREATE' AND
              ROWNUM < 2;
        RETURN false;
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN true;
    END IS_NEW_REVISION_INFO_NEEDED;

-----------------------------------------------------------------------------------------
--R12C :  This Function returns varchar2 value to specify if the batch is
--        ready for Import.
FUNCTION Get_Import_Ready_Status ( p_data_set_id IN NUMBER,
                                   p_source_system_id IN VARCHAR2,
                                   p_source_system_reference IN VARCHAR2,
                                   p_bundle_id IN NUMBER
                                 )
RETURN VARCHAR2 IS
  l_is_batch_GDSN_enabled     VARCHAR2(1);
  l_confirm_status            VARCHAR2(50);

  CURSOR item_group_cr IS
    SELECT MSII.SOURCE_SYSTEM_ID,
           MSII.SOURCE_SYSTEM_REFERENCE,
           MSII.SET_PROCESS_ID,
           MSII.BUNDLE_ID
    FROM MTL_SYSTEM_ITEMS_INTERFACE MSII
    WHERE MSII.PROCESS_FLAG = 0
      AND MSII.SET_PROCESS_ID = p_data_set_id
      AND MSII.BUNDLE_ID = p_bundle_id;

BEGIN
  -- See if the batch is GDSN Enabled
  SELECT NVL(ENABLED_FOR_DATA_POOL, 'N') INTO l_is_batch_GDSN_enabled
  FROM EGO_IMPORT_OPTION_SETS
  WHERE BATCH_ID = p_data_set_id;

  IF l_is_batch_GDSN_enabled = 'Y' AND p_bundle_id IS NOT NULL THEN
    FOR rec in item_group_cr LOOP
      l_confirm_status := Get_Confirm_Status( rec.SET_PROCESS_ID ,
                                              rec.SOURCE_SYSTEM_ID ,
                                              rec.SOURCE_SYSTEM_REFERENCE,
                                              rec.bundle_id
                                            );
      IF l_confirm_status NOT IN ( 'CNR', 'CCR', 'CMR', 'CFCR', 'CFMR' ) THEN
        RETURN 'NotImportReady';
      END IF;
    END LOOP;
    RETURN 'ImportReady';
  ELSE
    l_confirm_status := Get_Confirm_Status( p_data_set_id ,
                                            p_source_system_id ,
                                            p_source_system_reference,
                                            p_bundle_id
                                          );
    IF l_confirm_status IN ( 'CNR', 'CCR', 'CMR', 'CFCR', 'CFMR' ) THEN
      RETURN 'ImportReady';
    ELSE
      RETURN 'NotImportReady';
    END IF;
  END IF;
END Get_Import_Ready_Status;
-----------------------------------------------------------------------------------------

 /*
  * This method gets the confirm status plus the extra letter to indicate
  * whether an item is ready to be passed on to IOI
  */
 FUNCTION Get_Confirm_Status( p_data_set_id IN NUMBER,
                              p_source_system_id IN VARCHAR2,
                              p_source_system_reference IN VARCHAR2,
                              p_bundle_id IN NUMBER
                            )
 RETURN VARCHAR2 IS
   l_pdh_item_number            MTL_SYSTEM_ITEMS_INTERFACE.ITEM_NUMBER%TYPE;
   l_pdh_description            MTL_SYSTEM_ITEMS_INTERFACE.DESCRIPTION%TYPE;
   l_pdh_item_catalog_group_id  MTL_SYSTEM_ITEMS_INTERFACE.ITEM_CATALOG_GROUP_ID%TYPE;
   l_confirm_status             MTL_SYSTEM_ITEMS_INTERFACE.CONFIRM_STATUS%TYPE;
   l_item_num_gen               MTL_ITEM_CATALOG_GROUPS_B.ITEM_NUM_GEN_METHOD%TYPE;
   l_item_desc_gen              MTL_ITEM_CATALOG_GROUPS_B.ITEM_DESC_GEN_METHOD%TYPE;
   l_organization_id            MTL_PARAMETERS.ORGANIZATION_ID%TYPE;
   l_organization_code          MTL_PARAMETERS.ORGANIZATION_CODE%TYPE;
   l_batch_rev_policy           EGO_IMPORT_OPTION_SETS.REVISION_IMPORT_POLICY%TYPE;
   l_instance_rev_policy        MTL_SYSTEM_ITEMS_INTERFACE.REVISION_IMPORT_POLICY%TYPE;
   l_style_item_flag            MTL_SYSTEM_ITEMS_INTERFACE.STYLE_ITEM_FLAG%TYPE;
 BEGIN
    SELECT
       MP.ORGANIZATION_ID,
       MP.ORGANIZATION_CODE,
       NVL(OPT.REVISION_IMPORT_POLICY, 'L')
    INTO l_organization_id, l_organization_code, l_batch_rev_policy
    FROM MTL_PARAMETERS MP,
       EGO_IMPORT_BATCHES_B ba,
       EGO_IMPORT_OPTION_SETS OPT
    WHERE BA.ORGANIZATION_ID = MP.ORGANIZATION_ID AND
       BA.BATCH_ID = OPT.BATCH_ID AND
       BA.BATCH_ID = p_data_set_id;

    SELECT ITEM_NUMBER,
           NVL(DESCRIPTION,
            ( SELECT  ATTRIBUTE_VALUE
              FROM MTL_ITEM_TEMPLATES_VL TEMP, MTL_ITEM_TEMPL_ATTRIBUTES ATTR
              WHERE (    (MSII.TEMPLATE_ID IS NOT NULL AND TEMP.TEMPLATE_ID = MSII.TEMPLATE_ID)
                      OR (MSII.TEMPLATE_ID IS NULL AND TEMP.TEMPLATE_NAME = MSII.TEMPLATE_NAME)
                    ) AND
                    (TEMP.CONTEXT_ORGANIZATION_ID = MSII.ORGANIZATION_ID OR TEMP.CONTEXT_ORGANIZATION_ID IS NULL) AND
                    TEMP.TEMPLATE_ID = ATTR.TEMPLATE_ID AND
                    ATTR.ENABLED_FLAG = 'Y' AND
                    ATTR.ATTRIBUTE_NAME LIKE 'MTL_SYSTEM_ITEMS.DESCRIPTION')),
           NVL(ITEM_CATALOG_GROUP_ID,
            ( SELECT MICG.ITEM_CATALOG_GROUP_ID
              FROM MTL_ITEM_CATALOG_GROUPS_B_KFV MICG
              WHERE MICG.CONCATENATED_SEGMENTS = MSII.ITEM_CATALOG_GROUP_NAME)),
           CONFIRM_STATUS,
           NVL(REVISION_IMPORT_POLICY, l_batch_rev_policy),
           MSII.STYLE_ITEM_FLAG
    INTO l_pdh_item_number, l_pdh_description, l_pdh_item_catalog_group_id, l_confirm_status, l_instance_rev_policy, l_style_item_flag
    FROM MTL_SYSTEM_ITEMS_INTERFACE MSII, EGO_IMPORT_BATCHES_B BATCH
    WHERE MSII.SET_PROCESS_ID = p_data_set_id AND
        MSII.SOURCE_SYSTEM_ID = p_source_system_id AND
        MSII.SOURCE_SYSTEM_REFERENCE = p_source_system_reference AND
        MSII.ORGANIZATION_ID = BATCH.ORGANIZATION_ID AND
        BATCH.BATCH_ID = p_data_set_id AND
        PROCESS_FLAG = 0 AND
        ( ( p_bundle_id IS NULL AND MSII.BUNDLE_ID IS NULL )                  --R12C:
          OR MSII.BUNDLE_ID = p_bundle_id
        ) AND
        ROWNUM = 1;
        -- eletuchy: note that this rownum = 1 introduced indeterminacy ...

    -- if confirm status is one of UN, US, UM (unconfirmed no match, unconfirmed single match, unconfirmed multiple matches) or null
    -- simply return it
    IF  l_confirm_status IN ( G_UNCONF_NONE_MATCH, G_UNCONF_SIGL_MATCH, G_UNCONF_MULT_MATCH
                            , G_UNCONF_NO_MATCH_FAKE, G_UNCONF_SINGLE_MATCH_FAKE, G_UNCONF_MULTI_MATCH_FAKE )
        OR l_confirm_status IS NULL
    THEN
        RETURN l_confirm_status;

    -- if confirm status is CN (confirmed new), we need to see if all required information for item creation is provided
    ELSIF l_confirm_status = G_CONF_NEW THEN
       -- if item catalog group id is specified, we look at the item number generation method, if any
       -- says U (user entered) and is not there, it is not ready
       Get_Item_Num_Desc_Gen_Method(l_pdh_item_catalog_group_id, l_item_num_gen, l_item_desc_gen);
       IF ( ( l_item_desc_gen <> 'F' AND l_pdh_description IS NULL ) OR
            ( l_item_desc_gen = 'F' AND l_pdh_description IS NULL AND NVL(l_style_item_flag, 'N') = 'Y' )
          ) THEN
         RETURN G_CONF_NEW_NOT_READY;
       END IF;

       -- if no item catalog group id is specified, these columns are required
       IF l_pdh_item_catalog_group_id IS NULL THEN
         IF l_pdh_item_number IS null THEN
           RETURN G_CONF_NEW_NOT_READY;
         ELSE
           RETURN G_CONF_NEW_READY;
         END IF;
       END IF;

       IF ( ( l_item_num_gen NOT IN ('S', 'F') AND l_pdh_item_number IS NULL ) OR
            ( l_item_num_gen IN ('S', 'F') AND l_pdh_item_number IS NULL AND NVL(l_style_item_flag, 'N') = 'Y' )
          ) THEN
         RETURN G_CONF_NEW_NOT_READY;
       ELSE
         RETURN G_CONF_NEW_READY;
       END IF;
    -- if confirm status is CM (confirmed match) or  CC (confirmed cross reference),
    -- we need to see if rev level attributes are loaded and check import policy
    ELSIF l_confirm_status in ( G_CONF_MATCH, G_CONF_XREF, G_CONF_MATCH_FAKE, G_CONF_XREF_FAKE )  THEN
       RETURN l_confirm_status
           || CASE WHEN IS_NEW_REVISION_INFO_NEEDED( p_data_set_id
                                                   , p_source_system_id
                                                   , p_source_system_reference
                                                   , l_organization_id
                                                   , l_organization_code
                                                   , l_instance_rev_policy ) THEN 'N'
                   ELSE 'R'
                   END;
    ELSE
       RETURN 'UNKNOWN';
    END IF;

 EXCEPTION
    WHEN NO_DATA_FOUND THEN -- no batch header info, or no matching msii rows
        RETURN 'UNKNOWN';
 END Get_Confirm_Status;

 PROCEDURE Get_Item_Num_Desc_Gen_Method(p_item_catalog_group_id IN NUMBER,
                                        x_item_num_gen_method OUT NOCOPY VARCHAR2,
                                        x_item_desc_gen_method OUT NOCOPY VARCHAR2) IS
    l_num_gen_resolved VARCHAR2(1) := 'N';
    l_desc_gen_resolved VARCHAR2(1) := 'N';
    l_item_num_gen_method MTL_ITEM_CATALOG_GROUPS_B.ITEM_NUM_GEN_METHOD%TYPE;
    l_item_desc_gen_method MTL_ITEM_CATALOG_GROUPS_B.ITEM_DESC_GEN_METHOD%TYPE;

    CURSOR c_gen_method IS
      SELECT
       DECODE(ICC.ITEM_NUM_GEN_METHOD,
              NULL, DECODE(ICC.PARENT_CATALOG_GROUP_ID, NULL, 'U', 'I'),
              ICC.ITEM_NUM_GEN_METHOD),
       DECODE(ICC.ITEM_DESC_GEN_METHOD,
              NULL, DECODE(ICC.PARENT_CATALOG_GROUP_ID, NULL, 'U', 'I'),
              ICC.ITEM_DESC_GEN_METHOD)
      FROM MTL_ITEM_CATALOG_GROUPS_B ICC
      CONNECT BY PRIOR ICC.PARENT_CATALOG_GROUP_ID = ICC.ITEM_CATALOG_GROUP_ID
         START WITH ICC.ITEM_CATALOG_GROUP_ID = p_item_catalog_group_id;
 BEGIN
    OPEN c_gen_method;
    LOOP
       FETCH c_gen_method INTO l_item_num_gen_method, l_item_desc_gen_method;
       -- exit loop if no more row exists or we have resolved both item number and description generation methods
       EXIT WHEN (l_num_gen_resolved = 'Y' AND l_desc_gen_resolved = 'Y') OR c_gen_method%NOTFOUND;
       -- if generation method hasn't been resolved yet
       IF l_num_gen_resolved = 'N' AND l_item_num_gen_method IN ('U', 'S', 'F') THEN
          l_num_gen_resolved := 'Y';
          x_item_num_gen_method := l_item_num_gen_method;
       END IF;

       IF l_desc_gen_resolved = 'N' AND l_item_desc_gen_method IN ('U', 'F') THEN
          l_desc_gen_resolved := 'Y';
          x_item_desc_gen_method := l_item_desc_gen_method;
       END IF;


    END LOOP;

    CLOSE c_gen_method;
 END Get_Item_Num_Desc_Gen_Method;


   /*
    * parse item segments into item number if item_number is null
    */
   PROCEDURE PARSE_ITEM_SEGMENTS   (  p_set_id            IN NUMBER
                                   ,  p_master_org_id     IN NUMBER
                                   ,  p_is_pdh_batch      IN FLAG DEFAULT FND_API.G_FALSE
                                   )
   IS
       CURSOR c_ss_items_table IS
         SELECT rowid rid
         FROM   mtl_system_items_interface
         WHERE  set_process_id  = p_set_id
           AND  process_flag    = 0
           AND  organization_id /*bug 6402904 parse for child items also*/
                            IN (SELECT organization_id
                                      FROM mtl_parameters mp
                                     WHERE mp.master_organization_id = p_master_org_id)
           AND  (  confirm_status IS NULL
                OR confirm_status = G_FAKE_CONF_STATUS_FLAG
                )
           AND  item_number IS null
         FOR UPDATE OF item_number;

       CURSOR c_pdh_items_table IS
         SELECT rowid rid
         FROM   mtl_system_items_interface
         WHERE  set_process_id  = p_set_id
           AND  process_flag    = 1
           AND  item_number IS null
         FOR UPDATE OF item_number;

       l_err_text       VARCHAR2(240) := NULL;
       l_item_number    MTL_SYSTEM_ITEMS_INTERFACE.ITEM_NUMBER%TYPE := NULL;
       l_item_id        MTL_SYSTEM_ITEMS_B.INVENTORY_ITEM_ID%TYPE := NULL;
       l_ret_code       INTEGER;
    BEGIN
        IF p_is_pdh_batch = FND_API.G_TRUE THEN
            FOR item_record IN c_pdh_items_table LOOP
                l_ret_code := INVPUOPI.MTL_PR_PARSE_ITEM_SEGMENTS ( p_row_id     =>item_record.rid
                                                                  , item_number  =>l_item_number
                                                                  , item_id      =>l_item_id
                                                                  , ERR_TEXT     =>l_err_text
                                                                  );
            END LOOP;
        ELSE
            FOR item_record IN c_ss_items_table LOOP
                l_ret_code := INVPUOPI.MTL_PR_PARSE_ITEM_SEGMENTS ( p_row_id     =>item_record.rid
                                                                  , item_number  =>l_item_number
                                                                  , item_id      =>l_item_id
                                                                  , ERR_TEXT     =>l_err_text
                                                                  );
            END LOOP;
        END IF;
    END PARSE_ITEM_SEGMENTS;

    /**
     * resolve the SYNC transaction_type into 'CREATE' or 'UPDATE'
     * using the same logic as INVPOPIB.pls for a PDH batch
     */
    PROCEDURE UPDATE_ITEM_SYNC_RECORDS_PDH
    (p_set_id  IN  NUMBER,
     p_org_id IN NUMBER
    ) IS
      CURSOR c_items_table IS
        SELECT  rowid
              , organization_id
              , inventory_item_id
              , item_number
              , transaction_id
              , transaction_type
        FROM   mtl_system_items_interface
        WHERE  set_process_id   = p_set_id
           AND organization_id = p_org_id
           AND process_flag     = 1
           AND UPPER(transaction_type) = 'SYNC'
           FOR UPDATE OF transaction_type;

      CURSOR c_item_exists(cp_item_id NUMBER) IS
        SELECT  1
        FROM   mtl_system_items_b
        WHERE  inventory_item_id = cp_item_id;

      l_item_exist NUMBER(10) := 0;
      l_err_text   VARCHAR2(200);
      l_status     NUMBER(10):= 0;
      l_item_id    mtl_system_items_b.inventory_item_id%TYPE;

   BEGIN
      FOR item_record IN c_items_table LOOP
         l_item_exist := 0;
         l_item_id    := NULL;

         IF item_record.inventory_item_id IS NULL THEN
            IF item_record.item_number IS NOT NULL THEN
               l_status  := INVPUOPI.MTL_PR_PARSE_ITEM_NUMBER
                  ( ITEM_NUMBER =>item_record.item_number
                  , ITEM_ID     =>item_record.inventory_item_id
                  , TRANS_ID    =>item_record.transaction_id
                  , ORG_ID      =>item_record.organization_id
                  , ERR_TEXT    =>l_err_text
                  , P_ROWID     =>item_record.rowid
                  );
            END IF;
            l_item_exist := INVUPD1B.EXISTS_IN_MSI
                ( ROW_ID      => item_record.rowid
                , ORG_ID      => item_record.organization_id
                , INV_ITEM_ID => l_item_id
                , TRANS_ID    => item_record.transaction_id
                , ERR_TEXT    => l_err_text
                , XSET_ID     => p_set_id
                );
         ELSE
            l_item_id := item_record.inventory_item_id;
            OPEN  c_item_exists(item_record.inventory_item_id);
            FETCH c_item_exists INTO l_item_exist;
            CLOSE c_item_exists;
            l_item_exist := NVL(l_item_exist,0);
         END IF;

         IF l_item_exist = 1 THEN
            UPDATE mtl_system_items_interface
            SET    transaction_type  = 'UPDATE'
            WHERE  rowid = item_record.rowid;
         ELSE
            UPDATE mtl_system_items_interface
            SET    transaction_type = 'CREATE', inventory_item_id = NULL
            WHERE  rowid = item_record.rowid;
         END IF;
      END LOOP;

   END UPDATE_ITEM_SYNC_RECORDS_PDH;

 /*
  * This procedure resolves source system item cross references
  * immediately after MTL_SYSTEM_ITEMS_INTERFACE is populated and
  * tries to resolve discrepencies between user entered CONFIRM_STATUS
  * (if any), TRANSACTION_TYPE (if any)  and other data.
  * This procedure needs to be safe for re-execution if data is loaded into an
  * active batch repeatedly.
  */
 PROCEDURE Resolve_SSXref_on_Data_load( p_data_set_id  IN  NUMBER
                                       ,p_commit       IN  FLAG    DEFAULT FND_API.G_TRUE
                                      )
 IS
   l_org_id                 MTL_PARAMETERS.ORGANIZATION_ID%TYPE;
   l_org_code               MTL_PARAMETERS.ORGANIZATION_CODE%TYPE;
   l_ss_id                  EGO_IMPORT_BATCHES_B.SOURCE_SYSTEM_id%TYPE;
   l_import_xref_only       EGO_IMPORT_OPTION_SETS.IMPORT_XREF_ONLY%TYPE;
   l_party_name             VARCHAR2(1000);
   l_security_predicate     VARCHAR2(4000);
   l_return_status          VARCHAR2(100);
   l_sql                    VARCHAR2(32000);

   l_insert_date            DATE;
   l_org                    VARCHAR2(100);
   l_enabled_for_data_pool  EGO_IMPORT_OPTION_SETS.ENABLED_FOR_DATA_POOL%TYPE;
 BEGIN
    Debug_Conc_Log( 'Resolve_SSXref_on_Data_load - Entering' );

    Debug_Conc_Log( 'Resolve_SSXref_on_Data_load - Gather Statistics' );
    Gather_Stats_For_Intf_Tables(p_data_set_id);
    Debug_Conc_Log( 'Resolve_SSXref_on_Data_load - Done Call for Gather Statistics' );
    l_party_name := Get_Current_Party_Name;

    -- get the organization_id, organization_code for this batch
    BEGIN
      SELECT
          MP.ORGANIZATION_ID,
          MP.ORGANIZATION_CODE,
          BA.SOURCE_SYSTEM_ID,
          NVL(OPT.IMPORT_XREF_ONLY, 'N'),
          NVL(ENABLED_FOR_DATA_POOL, 'N')
      INTO l_org_id, l_org_code, l_ss_id, l_import_xref_only, l_enabled_for_data_pool
      FROM MTL_PARAMETERS MP,
          EGO_IMPORT_BATCHES_B BA,
          EGO_IMPORT_OPTION_SETS OPT
      WHERE BA.ORGANIZATION_ID = MP.ORGANIZATION_ID
        AND BA.BATCH_ID = p_data_set_id
        AND BA.BATCH_ID = OPT.BATCH_ID;
    EXCEPTION WHEN NO_DATA_FOUND THEN
      -- IF batch not found then getting the default org_id from
      -- profile option for the user
      l_org := fnd_profile.value('EGO_USER_ORGANIZATION_CONTEXT');
      BEGIN
        SELECT mp.MASTER_ORGANIZATION_ID, mp1.ORGANIZATION_CODE
        INTO l_org_id, l_org_code
        FROM MTL_PARAMETERS mp, MTL_PARAMETERS mp1
        WHERE mp.ORGANIZATION_ID = TO_NUMBER(l_org)
          AND mp.MASTER_ORGANIZATION_ID = mp1.ORGANIZATION_ID;
      EXCEPTION WHEN OTHERS THEN
        l_org_id := NULL;
        l_org_code := NULL;
      END;
      l_ss_id := get_pdh_source_system_id();
      l_import_xref_only := 'N';
      l_enabled_for_data_pool := 'N';
    END;

    -- populate organization_id if it's null
    -- if organization_code is not null, derive from it otherwise use
    -- organization id for batch
    UPDATE MTL_SYSTEM_ITEMS_INTERFACE MSII
    SET ORGANIZATION_ID =
        CASE
            WHEN ORGANIZATION_CODE IS NOT NULL
            THEN (SELECT ORGANIZATION_ID FROM MTL_PARAMETERS WHERE ORGANIZATION_CODE =  MSII.ORGANIZATION_CODE)
            ELSE l_org_id
        END
    WHERE SET_PROCESS_ID = p_data_set_id AND
        (PROCESS_FLAG IS NULL OR PROCESS_FLAG IN (0, 1)) AND
        ORGANIZATION_ID IS NULL;


    UPDATE MTL_ITEM_REVISIONS_INTERFACE MIRI
    SET ORGANIZATION_ID =
        CASE
            WHEN ORGANIZATION_CODE IS NOT NULL
            THEN (SELECT ORGANIZATION_ID FROM MTL_PARAMETERS WHERE ORGANIZATION_CODE =  MIRI.ORGANIZATION_CODE)
            ELSE l_org_id
        END
    WHERE SET_PROCESS_ID = p_data_set_id AND
        (PROCESS_FLAG IS NULL OR PROCESS_FLAG IN (0, 1)) AND
        ORGANIZATION_ID IS NULL;


    UPDATE MTL_ITEM_CATEGORIES_INTERFACE MICI
    SET ORGANIZATION_ID =
        CASE
            WHEN ORGANIZATION_CODE IS NOT NULL
            THEN (SELECT ORGANIZATION_ID FROM MTL_PARAMETERS WHERE ORGANIZATION_CODE =  MICI.ORGANIZATION_CODE)
            ELSE l_org_id
        END
    WHERE SET_PROCESS_ID = p_data_set_id AND
        (PROCESS_FLAG IS NULL OR PROCESS_FLAG IN (0, 1)) AND
        ORGANIZATION_ID IS NULL;

    UPDATE EGO_ITM_USR_ATTR_INTRFC EIUAI
    SET ORGANIZATION_ID =
        CASE
            WHEN ORGANIZATION_CODE IS NOT NULL
            THEN (SELECT ORGANIZATION_ID FROM MTL_PARAMETERS WHERE ORGANIZATION_CODE =  EIUAI.ORGANIZATION_CODE)
            ELSE l_org_id
        END
    WHERE DATA_SET_ID = p_data_set_id AND
        (PROCESS_STATUS IS NULL OR PROCESS_STATUS IN (0, 1)) AND
        ORGANIZATION_ID IS NULL;

    UPDATE EGO_ITEM_PEOPLE_INTF EIPI
    SET ORGANIZATION_ID =
        CASE
            WHEN ORGANIZATION_CODE IS NOT NULL
            THEN (SELECT ORGANIZATION_ID FROM MTL_PARAMETERS WHERE ORGANIZATION_CODE =  EIPI.ORGANIZATION_CODE)
            ELSE l_org_id
        END
    WHERE DATA_SET_ID = p_data_set_id AND
        (PROCESS_STATUS IS NULL OR PROCESS_STATUS IN (0, 1)) AND
        ORGANIZATION_ID IS NULL;

    UPDATE EGO_AML_INTF EAI
    SET ORGANIZATION_ID =
        CASE
            WHEN ORGANIZATION_CODE IS NOT NULL
            THEN (SELECT ORGANIZATION_ID FROM MTL_PARAMETERS WHERE ORGANIZATION_CODE =  EAI.ORGANIZATION_CODE)
            ELSE l_org_id
        END
    WHERE DATA_SET_ID = p_data_set_id AND
        (PROCESS_FLAG IS NULL OR PROCESS_FLAG IN (0, 1)) AND
        ORGANIZATION_ID IS NULL;

    UPDATE EGO_ITEM_ASSOCIATIONS_INTF EIAI
    SET ORGANIZATION_ID =
        CASE
            WHEN ORGANIZATION_CODE IS NOT NULL
            THEN (SELECT ORGANIZATION_ID FROM MTL_PARAMETERS WHERE ORGANIZATION_CODE =  EIAI.ORGANIZATION_CODE)
            ELSE l_org_id
        END
    WHERE BATCH_ID = p_data_set_id AND
        (PROCESS_FLAG IS NULL OR PROCESS_FLAG IN (0, 1)) AND
        ORGANIZATION_ID IS NULL;

    Debug_Conc_Log( 'Resolve_SSXref_on_Data_load - Done populating organization_id' );

    Debug_Conc_Log( 'Resolve_SSXref_on_Data_load - Resolving data_level_name' );

    UPDATE EGO_ITEM_ASSOCIATIONS_INTF EIAI
    SET DATA_LEVEL_ID = (SELECT DATA_LEVEL_ID
                         FROM EGO_DATA_LEVEL_B EDLB
                         WHERE EDLB.APPLICATION_ID = 431
                           AND EDLB.ATTR_GROUP_TYPE = 'EGO_ITEMMGMT_GROUP'
                           AND EDLB.DATA_LEVEL_NAME = EIAI.DATA_LEVEL_NAME
                        )
    WHERE BATCH_ID = p_data_set_id
      AND (PROCESS_FLAG IS NULL OR PROCESS_FLAG IN (0, 1))
      AND DATA_LEVEL_ID IS NULL
      AND DATA_LEVEL_NAME IS NOT NULL;


    UPDATE EGO_ITM_USR_ATTR_INTRFC uai
       SET uai.DATA_LEVEL_ID = (SELECT edlb.DATA_LEVEL_ID
                                FROM EGO_DATA_LEVEL_B edlb
                                WHERE edlb.DATA_LEVEL_NAME = uai.DATA_LEVEL_NAME
                                  AND edlb.APPLICATION_ID  = 431
                                  AND edlb.ATTR_GROUP_TYPE = NVL(uai.ATTR_GROUP_TYPE, 'EGO_ITEMMGMT_GROUP')
                               )
    WHERE uai.DATA_SET_ID     = p_data_set_id
      AND (uai.PROCESS_STATUS IS NULL OR uai.PROCESS_STATUS IN (0, 1))
      AND uai.DATA_LEVEL_NAME IS NOT NULL
      AND uai.DATA_LEVEL_ID   IS NULL;

    UPDATE EGO_ITM_USR_ATTR_INTRFC uai
       SET uai.DATA_LEVEL_ID = (SELECT edlv.DATA_LEVEL_ID
                                FROM EGO_DATA_LEVEL_VL edlv
                                WHERE edlv.USER_DATA_LEVEL_NAME = uai.USER_DATA_LEVEL_NAME
                                  AND edlv.APPLICATION_ID       = 431
                                  AND edlv.ATTR_GROUP_TYPE      = NVL(uai.ATTR_GROUP_TYPE, 'EGO_ITEMMGMT_GROUP')
                               )
    WHERE uai.DATA_SET_ID          = p_data_set_id
      AND (uai.PROCESS_STATUS  IS NULL OR uai.PROCESS_STATUS IN (0, 1) )
      AND uai.USER_DATA_LEVEL_NAME IS NOT NULL
      AND uai.DATA_LEVEL_NAME      IS NULL
      AND uai.DATA_LEVEL_ID        IS NULL;

    -----------------------------------------------------------
    -- If all data level columns are null, then check if the --
    -- attribute group is associated at only one level, then --
    -- put that data level id here.                          --
    -----------------------------------------------------------
    UPDATE EGO_ITM_USR_ATTR_INTRFC uai
       SET DATA_LEVEL_ID = (SELECT DATA_LEVEL_ID
                            FROM EGO_ATTR_GROUP_DL eagd, EGO_FND_DSC_FLX_CTX_EXT ag_ext
                            WHERE eagd.ATTR_GROUP_ID                   = ag_ext.ATTR_GROUP_ID
                              AND ag_ext.APPLICATION_ID                = 431
                              AND ag_ext.DESCRIPTIVE_FLEXFIELD_NAME    = NVL(uai.ATTR_GROUP_TYPE, 'EGO_ITEMMGMT_GROUP')
                              AND ag_ext.DESCRIPTIVE_FLEX_CONTEXT_CODE = uai.ATTR_GROUP_INT_NAME
                           )
    WHERE uai.DATA_SET_ID          = p_data_set_id
      AND (uai.PROCESS_STATUS  IS NULL OR uai.PROCESS_STATUS IN (0, 1) )
      AND uai.DATA_LEVEL_ID        IS NULL
      AND uai.DATA_LEVEL_NAME      IS NULL
      AND uai.USER_DATA_LEVEL_NAME IS NULL
      AND (SELECT COUNT(*)
           FROM EGO_ATTR_GROUP_DL eagd, EGO_FND_DSC_FLX_CTX_EXT ag_ext
           WHERE eagd.ATTR_GROUP_ID                   = ag_ext.ATTR_GROUP_ID
             AND ag_ext.APPLICATION_ID                = 431
             AND ag_ext.DESCRIPTIVE_FLEXFIELD_NAME    = NVL(uai.ATTR_GROUP_TYPE, 'EGO_ITEMMGMT_GROUP')
             AND ag_ext.DESCRIPTIVE_FLEX_CONTEXT_CODE = uai.ATTR_GROUP_INT_NAME
          ) = 1;


    Debug_Conc_Log( 'Resolve_SSXref_on_Data_load - Done Resolving data_level_name' );

    UPDATE EGO_ITEM_ASSOCIATIONS_INTF eiai
    SET PK1_VALUE = ( SELECT VENDOR_ID
                      FROM AP_SUPPLIERS aas
                      WHERE aas.SEGMENT1 = eiai.SUPPLIER_NUMBER
                      AND NVL(aas.end_date_active,SYSDATE+1) > SYSDATE  --bug11072046
                    )
    WHERE eiai.BATCH_ID        = p_data_set_id
      AND (eiai.PROCESS_FLAG   IS NULL OR eiai.PROCESS_FLAG IN (0, 1) )
      AND eiai.PK1_VALUE       IS NULL
      AND eiai.SUPPLIER_NUMBER IS NOT NULL;

    UPDATE EGO_ITEM_ASSOCIATIONS_INTF eiai
    SET PK1_VALUE = ( SELECT VENDOR_ID
                      FROM AP_SUPPLIERS aas
                      WHERE aas.VENDOR_NAME = eiai.SUPPLIER_NAME
                      AND NVL(aas.end_date_active,SYSDATE+1) > SYSDATE  --bug11072046
                    )
    WHERE eiai.BATCH_ID        = p_data_set_id
      AND (eiai.PROCESS_FLAG   IS NULL OR eiai.PROCESS_FLAG IN (0, 1) )
      AND eiai.PK1_VALUE       IS NULL
      AND eiai.SUPPLIER_NAME   IS NOT NULL
      AND eiai.SUPPLIER_NUMBER IS NULL;

    UPDATE EGO_ITEM_ASSOCIATIONS_INTF eiai
    SET PK2_VALUE = ( SELECT VENDOR_SITE_ID
                      FROM AP_SUPPLIER_SITES_ALL asa
                      WHERE asa.VENDOR_ID        = eiai.PK1_VALUE
                        AND asa.VENDOR_SITE_CODE = eiai.SUPPLIER_SITE_NAME
                        AND asa.ORG_ID           = FND_PROFILE.Value('ORG_ID')
                        and nvl(asa.inactive_date,SYSDATE + 1) >SYSDATE    --bug11072046
                    )
    WHERE eiai.BATCH_ID           = p_data_set_id
      AND (eiai.PROCESS_FLAG      IS NULL OR eiai.PROCESS_FLAG IN (0, 1) )
      AND eiai.PK2_VALUE          IS NULL
      AND eiai.SUPPLIER_SITE_NAME IS NOT NULL;

    Debug_Conc_Log( 'Resolve_SSXref_on_Data_load - Done Resolving PK Values in Intersection Interface table' );

    UPDATE MTL_SYSTEM_ITEMS_INTERFACE MSII
    SET STYLE_ITEM_ID = (SELECT MSIK.INVENTORY_ITEM_ID
                         FROM MTL_SYSTEM_ITEMS_KFV MSIK
                         WHERE MSIK.CONCATENATED_SEGMENTS = MSII.STYLE_ITEM_NUMBER
                           AND MSIK.ORGANIZATION_ID = MSII.ORGANIZATION_ID
                        )
    WHERE SET_PROCESS_ID = p_data_set_id
      AND STYLE_ITEM_NUMBER IS NOT NULL
      AND STYLE_ITEM_ID IS NULL
      AND STYLE_ITEM_FLAG = 'N'
      AND (PROCESS_FLAG IS NULL OR PROCESS_FLAG IN (0, 1)) ;

    Debug_Conc_Log( 'Resolve_SSXref_on_Data_load - Done Resolving Style Item Id' );

    IF l_ss_id = get_pdh_source_system_id() THEN
        Debug_Conc_Log( 'Resolve_SSXref_on_Data_load - PDH batch, update item_number if inventory_item_id is populated' );
        -- if user does know the inventory_item_id, use it to overwrite
        -- item_number
        -- so in the imported tab, we can join to the child entities by item_number alone
        UPDATE MTL_SYSTEM_ITEMS_INTERFACE MSII
        SET item_number = (SELECT CONCATENATED_SEGMENTS
                           FROM MTL_SYSTEM_ITEMS_KFV
                           WHERE INVENTORY_ITEM_ID = MSII.INVENTORY_ITEM_ID
                               AND ORGANIZATION_ID = MSII.ORGANIZATION_ID)
        WHERE SET_PROCESS_ID = p_data_set_id
            AND PROCESS_FLAG = 1
            AND ITEM_NUMBER IS NULL
            AND INVENTORY_ITEM_ID IS NOT NULL;

        UPDATE MTL_ITEM_REVISIONS_INTERFACE MIRI
        SET item_number = (SELECT CONCATENATED_SEGMENTS
                           FROM MTL_SYSTEM_ITEMS_KFV
                           WHERE INVENTORY_ITEM_ID = MIRI.INVENTORY_ITEM_ID
                               AND ORGANIZATION_ID = MIRI.ORGANIZATION_ID)
        WHERE SET_PROCESS_ID = p_data_set_id
            AND PROCESS_FLAG = 1
            AND ITEM_NUMBER IS NULL
            AND INVENTORY_ITEM_ID IS NOT NULL;

        UPDATE MTL_ITEM_CATEGORIES_INTERFACE MICI
        SET item_number = (SELECT CONCATENATED_SEGMENTS
                           FROM MTL_SYSTEM_ITEMS_KFV
                           WHERE INVENTORY_ITEM_ID = MICI.INVENTORY_ITEM_ID
                               AND ORGANIZATION_ID = MICI.ORGANIZATION_ID)
        WHERE SET_PROCESS_ID = p_data_set_id
            AND PROCESS_FLAG = 1
            AND ITEM_NUMBER IS NULL
          AND INVENTORY_ITEM_ID IS NOT NULL;

        UPDATE EGO_ITM_USR_ATTR_INTRFC EIUAI
        SET item_number = (SELECT CONCATENATED_SEGMENTS
                           FROM MTL_SYSTEM_ITEMS_KFV
                           WHERE INVENTORY_ITEM_ID = EIUAI.INVENTORY_ITEM_ID
                               AND ORGANIZATION_ID = EIUAI.ORGANIZATION_ID)
        WHERE DATA_SET_ID = p_data_set_id
            AND PROCESS_STATUS = 1
            AND ITEM_NUMBER IS NULL
            AND INVENTORY_ITEM_ID IS NOT NULL;

        UPDATE EGO_AML_INTF EAI
        SET item_number = (SELECT CONCATENATED_SEGMENTS
                           FROM MTL_SYSTEM_ITEMS_KFV
                           WHERE INVENTORY_ITEM_ID = EAI.INVENTORY_ITEM_ID
                               AND ORGANIZATION_ID = EAI.ORGANIZATION_ID)
        WHERE DATA_SET_ID = p_data_set_id
            AND PROCESS_FLAG = 1
            AND ITEM_NUMBER IS NULL
            AND INVENTORY_ITEM_ID IS NOT NULL;

        UPDATE EGO_ITEM_PEOPLE_INTF MIPI
        SET item_number = (SELECT CONCATENATED_SEGMENTS
                           FROM MTL_SYSTEM_ITEMS_KFV
                           WHERE INVENTORY_ITEM_ID = MIPI.INVENTORY_ITEM_ID
                               AND ORGANIZATION_ID = MIPI.ORGANIZATION_ID)
        WHERE DATA_SET_ID = p_data_set_id
            AND PROCESS_STATUS = 1
            AND ITEM_NUMBER IS NULL
            AND INVENTORY_ITEM_ID IS NOT NULL;

        UPDATE EGO_ITEM_ASSOCIATIONS_INTF EIAI
        SET item_number = (SELECT CONCATENATED_SEGMENTS
                           FROM MTL_SYSTEM_ITEMS_KFV
                           WHERE INVENTORY_ITEM_ID = EIAI.INVENTORY_ITEM_ID
                               AND ORGANIZATION_ID = EIAI.ORGANIZATION_ID)
        WHERE BATCH_ID = p_data_set_id
            AND PROCESS_FLAG = 1
            AND ITEM_NUMBER IS NULL
            AND INVENTORY_ITEM_ID IS NOT NULL;

        Debug_Conc_Log( 'Resolve_SSXref_on_Data_load - PDH batch, done updating item_number if inventory_item_id is populated' );

        -- parse segments into item_number if item_number is null
        -- so that we can join to the child entities by item number alone
        PARSE_ITEM_SEGMENTS(p_data_set_id, l_org_id, FND_API.G_TRUE);
        Debug_Conc_Log( 'Resolve_SSXref_on_Data_load - PDH batch, done parsing item segments' );

        -- insert fake records ...
        l_insert_date := SYSDATE;
        -- ... 1. for attributes (no child orgs)
        INSERT INTO
            MTL_SYSTEM_ITEMS_INTERFACE MSII
            ( transaction_type, process_flag, set_process_id, organization_id, source_system_id
            , confirm_status, inventory_item_id, item_number
            , CREATION_DATE, LAST_UPDATE_DATE, CREATED_BY, LAST_UPDATED_BY, LAST_UPDATE_LOGIN
            , ITEM_CATALOG_GROUP_ID )
            SELECT G_TRANS_TYPE_SYNC, 1, p_data_set_id, EIUAI.organization_id, l_ss_id
               , G_FAKE_CONF_STATUS_FLAG
               , MAX( EIUAI.inventory_item_id ) KEEP ( DENSE_RANK FIRST ORDER BY INVENTORY_ITEM_ID NULLS LAST, LAST_UPDATE_DATE NULLS LAST )
               , EIUAI.item_number
               , l_insert_date -- CREATION_DATE
               , l_insert_date -- LAST_UPDATE_DATE
               , MAX( EIUAI.created_by ) KEEP ( DENSE_RANK FIRST ORDER BY INVENTORY_ITEM_ID NULLS LAST, LAST_UPDATE_DATE NULLS LAST ) CREATED_BY
               , MAX( EIUAI.last_updated_by ) KEEP ( DENSE_RANK FIRST ORDER BY INVENTORY_ITEM_ID NULLS LAST, LAST_UPDATE_DATE NULLS LAST ) UPDATED_BY
               , MAX( EIUAI.last_update_login ) KEEP ( DENSE_RANK FIRST ORDER BY INVENTORY_ITEM_ID NULLS LAST, LAST_UPDATE_DATE NULLS LAST ) LAST_UPDATE_LOGIN
               , MAX( EIUAI.item_catalog_group_id ) KEEP ( DENSE_RANK FIRST ORDER BY INVENTORY_ITEM_ID NULLS LAST, LAST_UPDATE_DATE NULLS LAST ) ITEM_CATALOG_GROUP_ID
            FROM EGO_ITM_USR_ATTR_INTRFC    EIUAI
--             , MTL_PARAMETERS             MP
            WHERE
                data_set_id = p_data_set_id
            AND process_status = 1
            AND EIUAI.organization_id = l_org_id
--          AND EIUAI.organization_id = MP.organization_id
--          AND MP.master_organization_id = l_org_id
            AND NOT EXISTS
                (
                select null from mtl_system_items_interface
                where set_process_id     = EIUAI.data_set_id
                  and item_number        = EIUAI.item_number
                  and process_flag       = EIUAI.process_status
                  and organization_id    = l_org_id
                )
            GROUP BY EIUAI.ITEM_NUMBER, EIUAI.organization_id;
            -- using GROUP BY rather than distinct for performance reasons (emulating merge code)
            Debug_Conc_Log( 'Resolve_SSXref_on_Data_load - PDH batch, parent rows inserted for UDAs: ' || SQL%ROWCOUNT );
        -- ... 2. for AMLs (no child orgs)
        INSERT INTO
            MTL_SYSTEM_ITEMS_INTERFACE MSII
            ( transaction_type, process_flag, set_process_id, organization_id, source_system_id
            , confirm_status, inventory_item_id, item_number
            , CREATION_DATE, LAST_UPDATE_DATE, CREATED_BY, LAST_UPDATED_BY, LAST_UPDATE_LOGIN )
            SELECT G_TRANS_TYPE_SYNC, 1, p_data_set_id, l_org_id, l_ss_id
               , G_FAKE_CONF_STATUS_FLAG
               , MAX( EAI.inventory_item_id ) KEEP ( DENSE_RANK FIRST ORDER BY INVENTORY_ITEM_ID NULLS LAST, LAST_UPDATE_DATE NULLS LAST )
               , EAI.item_number
               , l_insert_date -- CREATION_DATE
               , l_insert_date -- LAST_UPDATE_DATE
               , MAX( EAI.created_by ) KEEP ( DENSE_RANK FIRST ORDER BY INVENTORY_ITEM_ID NULLS LAST, LAST_UPDATE_DATE NULLS LAST ) CREATED_BY
               , MAX( EAI.last_updated_by ) KEEP ( DENSE_RANK FIRST ORDER BY INVENTORY_ITEM_ID NULLS LAST, LAST_UPDATE_DATE NULLS LAST ) UPDATED_BY
               , MAX( EAI.last_update_login ) KEEP ( DENSE_RANK FIRST ORDER BY INVENTORY_ITEM_ID NULLS LAST, LAST_UPDATE_DATE NULLS LAST ) LAST_UPDATE_LOGIN
            FROM EGO_AML_INTF    EAI
--             , MTL_PARAMETERS             MP
            WHERE
                EAI.data_set_id = p_data_set_id
            AND EAI.process_flag = 1
            AND EAI.organization_id = l_org_id
--          AND EAI.organization_id = MP.organization_id
--          AND MP.master_organization_id = l_org_id
            AND NOT EXISTS
                (
                select null from mtl_system_items_interface
                where set_process_id     = EAI.data_set_id
                  and item_number        = EAI.item_number
                  and process_flag       = EAI.process_flag
                  and organization_id    = l_org_id
                )
            GROUP BY EAI.ITEM_NUMBER;
            -- using GROUP BY rather than distinct for performance reasons (emulating merge code)
        Debug_Conc_Log( 'Resolve_SSXref_on_Data_load - PDH batch, parent rows inserted for AMLs: ' || SQL%ROWCOUNT );

         --R12C: Inseting Fake Row into MSII for orphan row in EGO_ITEM_ASSOCIATIONS_INTF.
        INSERT INTO
            MTL_SYSTEM_ITEMS_INTERFACE MSII
            ( transaction_type, process_flag, set_process_id, organization_id, source_system_id
            , confirm_status, inventory_item_id, item_number
            , CREATION_DATE, LAST_UPDATE_DATE, CREATED_BY, LAST_UPDATED_BY, LAST_UPDATE_LOGIN  )
            SELECT G_TRANS_TYPE_SYNC, 1, p_data_set_id, EIAI.organization_id, l_ss_id
               , G_FAKE_CONF_STATUS_FLAG
               , MAX( EIAI.inventory_item_id ) KEEP ( DENSE_RANK FIRST ORDER BY INVENTORY_ITEM_ID NULLS LAST, LAST_UPDATE_DATE NULLS LAST )
               , EIAI.item_number
               , l_insert_date -- CREATION_DATE
               , l_insert_date -- LAST_UPDATE_DATE
               , MAX( EIAI.created_by ) KEEP ( DENSE_RANK FIRST ORDER BY INVENTORY_ITEM_ID NULLS LAST, LAST_UPDATE_DATE NULLS LAST ) CREATED_BY
               , MAX( EIAI.last_updated_by ) KEEP ( DENSE_RANK FIRST ORDER BY INVENTORY_ITEM_ID NULLS LAST, LAST_UPDATE_DATE NULLS LAST ) UPDATED_BY
               , MAX( EIAI.last_update_login ) KEEP ( DENSE_RANK FIRST ORDER BY INVENTORY_ITEM_ID NULLS LAST, LAST_UPDATE_DATE NULLS LAST ) LAST_UPDATE_LOGIN
            FROM EGO_ITEM_ASSOCIATIONS_INTF    EIAI
            WHERE
                batch_id = p_data_set_id
            AND process_flag = 1
            AND EIAI.organization_id = l_org_id
            AND NOT EXISTS
                (
                select null from mtl_system_items_interface
                where set_process_id     = EIAI.batch_id
                  and item_number        = EIAI.item_number
                  and process_flag       = EIAI.process_flag
                  and organization_id    = l_org_id
                )
            GROUP BY EIAI.ITEM_NUMBER, EIAI.organization_id;
        Debug_Conc_Log( 'Resolve_SSXref_on_Data_load - PDH batch, parent rows inserted for ASSOCIATIONS: ' || SQL%ROWCOUNT );

        --R12C: Insertion of Fake row into MSII for a orphan row in MTL_ITEM_CATEGORIES_INTERFACE
        INSERT INTO
            MTL_SYSTEM_ITEMS_INTERFACE MSII
            ( transaction_type, process_flag, set_process_id, organization_id, source_system_id
            , confirm_status, inventory_item_id, item_number
            , CREATION_DATE, LAST_UPDATE_DATE, CREATED_BY, LAST_UPDATED_BY, LAST_UPDATE_LOGIN  )
            SELECT G_TRANS_TYPE_SYNC, 1, p_data_set_id, MICI.organization_id, l_ss_id
               , G_FAKE_CONF_STATUS_FLAG
               , MAX( MICI.inventory_item_id ) KEEP ( DENSE_RANK FIRST ORDER BY INVENTORY_ITEM_ID NULLS LAST, LAST_UPDATE_DATE NULLS LAST )
               , MICI.item_number
               , l_insert_date -- CREATION_DATE
               , l_insert_date -- LAST_UPDATE_DATE
               , MAX( MICI.created_by ) KEEP ( DENSE_RANK FIRST ORDER BY INVENTORY_ITEM_ID NULLS LAST, LAST_UPDATE_DATE NULLS LAST ) CREATED_BY
               , MAX( MICI.last_updated_by ) KEEP ( DENSE_RANK FIRST ORDER BY INVENTORY_ITEM_ID NULLS LAST, LAST_UPDATE_DATE NULLS LAST ) UPDATED_BY
               , MAX( MICI.last_update_login ) KEEP ( DENSE_RANK FIRST ORDER BY INVENTORY_ITEM_ID NULLS LAST, LAST_UPDATE_DATE NULLS LAST ) LAST_UPDATE_LOGIN
            FROM MTL_ITEM_CATEGORIES_INTERFACE    MICI
            WHERE
                set_process_id = p_data_set_id
            AND process_flag = 1
            AND MICI.organization_id = l_org_id
            AND NOT EXISTS
                (
                select null from mtl_system_items_interface
                where set_process_id     = MICI.set_process_id
                  and item_number        = MICI.item_number
                  and process_flag       = MICI.process_flag
                  and organization_id    = l_org_id
                )
            GROUP BY MICI.ITEM_NUMBER, MICI.organization_id;
        Debug_Conc_Log( 'Resolve_SSXref_on_Data_load - PDH batch, parent rows inserted for CATEGORY ASSIGNMENT rows: ' || SQL%ROWCOUNT );
        MERGE_BATCH(  p_batch_id        => p_data_set_id
                   ,  p_master_org_id   => l_org_id
                   ,  p_is_pdh_batch    => FND_API.G_TRUE
                   ,  p_commit          => FND_API.G_FALSE
                   );
        Debug_Conc_Log( 'Resolve_SSXref_on_Data_load - PDH batch, done merging batch' );

        -- resolve SYNC transaction_type into UPDATE or CREATE
        -- this is needed in the Confirmed Tab for a PDH batch to partition
        -- items into 'Matched' and 'New'
        UPDATE_ITEM_SYNC_RECORDS_PDH(p_data_set_id, l_org_id);
        Debug_Conc_Log( 'Resolve_SSXref_on_Data_load - PDH batch, done updating item sync records' );

        /* Bug 5283663: CREATE rows can have the FAKE confirm status,
           since those rows are moved to process flag 3 in resolve_child_entities;
           before IOI has a chance to process them
        UPDATE MTL_SYSTEM_ITEMS_INTERFACE MSII
            SET CONFIRM_STATUS  = NULL
            WHERE
                set_process_id  = p_data_set_id
            AND process_flag    = 1
            AND organization_id = l_org_id
            AND UPPER( transaction_type ) = G_TRANS_TYPE_CREATE
            AND confirm_status = G_FAKE_CONF_STATUS_FLAG;
        */

        -- that's it
        IF FND_API.G_TRUE = p_commit THEN
           COMMIT;
           Debug_Conc_Log( 'Resolve_SSXref_on_Data_load - PDH batch, committed' );
        END IF;

        RETURN;
    END IF;

    Debug_Conc_Log( 'Resolve_SSXref_on_Data_load - Source System batch, setting process_flag if null' );

    -- we need to look at all these columns
    -- Filter Conditions: set_process_id (batch), process_flag (0 -- unprocessed), organization_id (master org), process_flag (null)
    -- Source System Item Primary Keys: source_system_id, source_system_reference
    -- PDH Item Primary Key Possibilities: inventory_item_id, item_number, segment1, segment2, ... segment20
    -- User Directive: transaction_type

    -- Normalize the PROCESS_FLAG if it is null
    UPDATE MTL_SYSTEM_ITEMS_INTERFACE
    SET PROCESS_FLAG = 0
    WHERE SET_PROCESS_ID = p_data_set_id AND
        PROCESS_FLAG IS NULL;

    UPDATE MTL_ITEM_REVISIONS_INTERFACE
    SET PROCESS_FLAG = 0
    WHERE SET_PROCESS_ID = p_data_set_id AND
        PROCESS_FLAG IS NULL;

    UPDATE MTL_ITEM_CATEGORIES_INTERFACE
    SET PROCESS_FLAG = 0
    WHERE SET_PROCESS_ID = p_data_set_id AND
        PROCESS_FLAG IS NULL;

    UPDATE EGO_ITM_USR_ATTR_INTRFC
    SET PROCESS_STATUS = 0
    WHERE DATA_SET_ID = p_data_set_id AND
        PROCESS_STATUS IS NULL;

    UPDATE EGO_ITEM_PEOPLE_INTF
    SET PROCESS_STATUS = 0
    WHERE DATA_SET_ID = p_data_set_id AND
        PROCESS_STATUS IS NULL;

    UPDATE EGO_AML_INTF
    SET PROCESS_FLAG = 0
    WHERE DATA_SET_ID = p_data_set_id AND
        PROCESS_FLAG IS NULL;

    UPDATE EGO_ITEM_ASSOCIATIONS_INTF
    SET PROCESS_FLAG = 0
    WHERE BATCH_ID = p_data_set_id AND
        PROCESS_FLAG IS NULL;

    Debug_Conc_Log( 'Resolve_SSXref_on_Data_load - Source System batch, done setting process_flag if null' );

      IF l_enabled_for_data_pool = 'Y' THEN

     EGO_IMPORT_UTIL_PVT.check_for_duplicates(  p_batch_id        => p_data_set_id
               ,  p_commit          => FND_API.G_FALSE
                 );
      Debug_Conc_Log( 'Done checking duplicates for a data_pool batch ' );
    ELSE
         Debug_Conc_Log( 'Duplicates checked only for a data_pool entabled batch' );
    END IF;

    -- insert fake records ...
    l_insert_date := SYSDATE;
    -- ... 1. for attributes (no child orgs)
    INSERT INTO
        MTL_SYSTEM_ITEMS_INTERFACE MSII
        ( transaction_type, process_flag, set_process_id, organization_id, source_system_id, source_system_reference, bundle_id
        , confirm_status, inventory_item_id, item_number
        , CREATION_DATE, LAST_UPDATE_DATE, CREATED_BY, LAST_UPDATED_BY, LAST_UPDATE_LOGIN
        , ITEM_CATALOG_GROUP_ID )
        SELECT G_TRANS_TYPE_SYNC, 0, p_data_set_id, EIUAI.organization_id
           , EIUAI.source_system_id, EIUAI.source_system_reference, EIUAI.bundle_id
           , G_FAKE_CONF_STATUS_FLAG
           , MAX( EIUAI.inventory_item_id ) KEEP ( DENSE_RANK FIRST ORDER BY INVENTORY_ITEM_ID NULLS LAST, ITEM_NUMBER NULLS LAST, LAST_UPDATE_DATE NULLS LAST ) ITEM_ID
           , MAX( EIUAI.item_number ) KEEP ( DENSE_RANK FIRST ORDER BY INVENTORY_ITEM_ID NULLS LAST, ITEM_NUMBER NULLS LAST, LAST_UPDATE_DATE NULLS LAST ) ITEM_NUMBER
           , l_insert_date -- CREATION_DATE
           , l_insert_date -- LAST_UPDATE_DATE
           , MAX( EIUAI.created_by ) KEEP ( DENSE_RANK FIRST ORDER BY INVENTORY_ITEM_ID NULLS LAST, ITEM_NUMBER NULLS LAST, LAST_UPDATE_DATE NULLS LAST ) CREATED_BY
           , MAX( EIUAI.last_updated_by ) KEEP ( DENSE_RANK FIRST ORDER BY INVENTORY_ITEM_ID NULLS LAST, ITEM_NUMBER NULLS LAST, LAST_UPDATE_DATE NULLS LAST ) UPDATED_BY
           , MAX( EIUAI.last_update_login ) KEEP ( DENSE_RANK FIRST ORDER BY INVENTORY_ITEM_ID NULLS LAST, ITEM_NUMBER NULLS LAST, LAST_UPDATE_DATE NULLS LAST ) LAST_UPDATE_LOGIN
           , MAX( EIUAI.item_catalog_group_id ) KEEP ( DENSE_RANK FIRST ORDER BY INVENTORY_ITEM_ID NULLS LAST, ITEM_NUMBER NULLS LAST, LAST_UPDATE_DATE NULLS LAST ) ITEM_CATALOG_GROUP_ID
        FROM EGO_ITM_USR_ATTR_INTRFC    EIUAI
--         , MTL_PARAMETERS             MP
        WHERE
            data_set_id = p_data_set_id
        AND process_status = 0
        AND EIUAI.organization_id = l_org_id
--      AND EIUAI.organization_id = MP.organization_id
--      AND MP.master_organization_id = l_org_id
        AND source_system_id = l_ss_id
        AND source_system_reference IS NOT NULL
        AND NOT EXISTS
            (
            select null from mtl_system_items_interface
            where set_process_id          = EIUAI.data_set_id
              and source_system_id        = EIUAI.source_system_id
              and source_system_reference = EIUAI.source_system_reference
              and process_flag            = EIUAI.process_status
              and organization_id         = l_org_id
            )
        GROUP BY EIUAI.source_system_id, EIUAI.source_system_reference, EIUAI.organization_id, EIUAI.BUNDLE_ID;
        -- using GROUP BY rather than distinct for performance reasons (no load on merge code)
    Debug_Conc_Log( 'Resolve_SSXref_on_Data_load - Source System batch, parent rows inserted for UDAs: ' || SQL%ROWCOUNT );
    -- ... 2. for AMLs (no child orgs)
    INSERT INTO
        MTL_SYSTEM_ITEMS_INTERFACE MSII
        ( transaction_type, process_flag, set_process_id, organization_id, source_system_id, source_system_reference
        , source_system_reference_desc, confirm_status, inventory_item_id, item_number
        , CREATION_DATE, LAST_UPDATE_DATE, CREATED_BY, LAST_UPDATED_BY, LAST_UPDATE_LOGIN )
        SELECT G_TRANS_TYPE_SYNC, 0, p_data_set_id, l_org_id
           , EAI.source_system_id, EAI.source_system_reference
           , MAX( EAI.source_system_reference_desc ) KEEP ( DENSE_RANK FIRST ORDER BY INVENTORY_ITEM_ID NULLS LAST, ITEM_NUMBER NULLS LAST, LAST_UPDATE_DATE NULLS LAST ) SOURCE_SYSTEM_REFERENCE_DESC
           , G_FAKE_CONF_STATUS_FLAG
           , MAX( EAI.inventory_item_id ) KEEP ( DENSE_RANK FIRST ORDER BY INVENTORY_ITEM_ID NULLS LAST, ITEM_NUMBER NULLS LAST, LAST_UPDATE_DATE NULLS LAST ) ITEM_ID
           , MAX( EAI.item_number ) KEEP ( DENSE_RANK FIRST ORDER BY INVENTORY_ITEM_ID NULLS LAST, ITEM_NUMBER NULLS LAST, LAST_UPDATE_DATE NULLS LAST ) ITEM_NUMBER
           , l_insert_date -- CREATION_DATE
           , l_insert_date -- LAST_UPDATE_DATE
           , MAX( EAI.created_by ) KEEP ( DENSE_RANK FIRST ORDER BY INVENTORY_ITEM_ID NULLS LAST, ITEM_NUMBER NULLS LAST, LAST_UPDATE_DATE NULLS LAST ) CREATED_BY
           , MAX( EAI.last_updated_by ) KEEP ( DENSE_RANK FIRST ORDER BY INVENTORY_ITEM_ID NULLS LAST, ITEM_NUMBER NULLS LAST, LAST_UPDATE_DATE NULLS LAST ) UPDATED_BY
           , MAX( EAI.last_update_login ) KEEP ( DENSE_RANK FIRST ORDER BY INVENTORY_ITEM_ID NULLS LAST, ITEM_NUMBER NULLS LAST, LAST_UPDATE_DATE NULLS LAST ) LAST_UPDATE_LOGIN
        FROM EGO_AML_INTF    EAI
--         , MTL_PARAMETERS             MP
        WHERE
            EAI.data_set_id = p_data_set_id
        AND EAI.process_flag = 0
        AND EAI.organization_id = l_org_id
--      AND EAI.organization_id = MP.organization_id
--      AND MP.master_organization_id = l_org_id
        AND source_system_id = l_ss_id
        AND source_system_reference IS NOT NULL
        AND NOT EXISTS
            (
            select null from mtl_system_items_interface
            where set_process_id          = EAI.data_set_id
              and source_system_id        = EAI.source_system_id
              and source_system_reference = EAI.source_system_reference
              and process_flag            = EAI.process_flag
              and organization_id         = l_org_id
            )
        GROUP BY EAI.source_system_id, EAI.source_system_reference;
        -- using GROUP BY rather than distinct for performance reasons (no load on merge code)
    Debug_Conc_Log( 'Resolve_SSXref_on_Data_load - Source System batch, parent rows inserted for AMLs: ' || SQL%ROWCOUNT );

    --R12C: Inserting Fake Row (Parent Row in MSII) for Orphan row in EGO_ITEM_ASSOCIATIONS_INTF
    INSERT INTO
        MTL_SYSTEM_ITEMS_INTERFACE MSII
        ( transaction_type, process_flag, set_process_id, organization_id, source_system_id, source_system_reference, bundle_id
        ,  confirm_status, inventory_item_id, item_number
        , CREATION_DATE, LAST_UPDATE_DATE, CREATED_BY, LAST_UPDATED_BY, LAST_UPDATE_LOGIN )
        SELECT G_TRANS_TYPE_SYNC, 0, p_data_set_id, l_org_id
           , EIAI.source_system_id, EIAI.source_system_reference, EIAI.bundle_id
           , G_FAKE_CONF_STATUS_FLAG
           , MAX( EIAI.inventory_item_id ) KEEP ( DENSE_RANK FIRST ORDER BY INVENTORY_ITEM_ID NULLS LAST, ITEM_NUMBER NULLS LAST, LAST_UPDATE_DATE NULLS LAST ) ITEM_ID
           , MAX( EIAI.item_number ) KEEP ( DENSE_RANK FIRST ORDER BY INVENTORY_ITEM_ID NULLS LAST, ITEM_NUMBER NULLS LAST, LAST_UPDATE_DATE NULLS LAST ) ITEM_NUMBER
           , l_insert_date -- CREATION_DATE
           , l_insert_date -- LAST_UPDATE_DATE
           , MAX( EIAI.created_by ) KEEP ( DENSE_RANK FIRST ORDER BY INVENTORY_ITEM_ID NULLS LAST, ITEM_NUMBER NULLS LAST, LAST_UPDATE_DATE NULLS LAST ) CREATED_BY
           , MAX( EIAI.last_updated_by ) KEEP ( DENSE_RANK FIRST ORDER BY INVENTORY_ITEM_ID NULLS LAST, ITEM_NUMBER NULLS LAST, LAST_UPDATE_DATE NULLS LAST ) UPDATED_BY
           , MAX( EIAI.last_update_login ) KEEP ( DENSE_RANK FIRST ORDER BY INVENTORY_ITEM_ID NULLS LAST, ITEM_NUMBER NULLS LAST, LAST_UPDATE_DATE NULLS LAST ) LAST_UPDATE_LOGIN
        FROM EGO_ITEM_ASSOCIATIONS_INTF    EIAI
        WHERE
            EIAI.batch_id = p_data_set_id
        AND EIAI.process_flag = 0
        AND EIAI.organization_id = l_org_id
        AND source_system_id = l_ss_id
        AND source_system_reference IS NOT NULL
        AND NOT EXISTS
            (
            select null from mtl_system_items_interface
            where set_process_id          = EIAI.batch_id
              and source_system_id        = EIAI.source_system_id
              and source_system_reference = EIAI.source_system_reference
              and process_flag            = EIAI.process_flag
              and organization_id         = l_org_id
            )
        GROUP BY EIAI.source_system_id, EIAI.source_system_reference, EIAI.bundle_id;
    Debug_Conc_Log( 'Resolve_SSXref_on_Data_load - Source System batch, parent rows inserted for ASSOCIATIONS: ' || SQL%ROWCOUNT );


    --R12C: Inserting Fake Row (Parent Row in MSII) for Orphan row in EGO_ITEM_ASSOCIATIONS_INTF
    INSERT INTO
        MTL_SYSTEM_ITEMS_INTERFACE MSII
        ( transaction_type, process_flag, set_process_id, organization_id, source_system_id, source_system_reference, bundle_id
        ,  confirm_status, inventory_item_id, item_number
        , CREATION_DATE, LAST_UPDATE_DATE, CREATED_BY, LAST_UPDATED_BY, LAST_UPDATE_LOGIN )
        SELECT G_TRANS_TYPE_SYNC, 0, p_data_set_id, l_org_id
           , MICI.source_system_id, MICI.source_system_reference, MICI.bundle_id
           , G_FAKE_CONF_STATUS_FLAG
           , MAX( MICI.inventory_item_id ) KEEP ( DENSE_RANK FIRST ORDER BY INVENTORY_ITEM_ID NULLS LAST, ITEM_NUMBER NULLS LAST, LAST_UPDATE_DATE NULLS LAST ) ITEM_ID
           , MAX( MICI.item_number ) KEEP ( DENSE_RANK FIRST ORDER BY INVENTORY_ITEM_ID NULLS LAST, ITEM_NUMBER NULLS LAST, LAST_UPDATE_DATE NULLS LAST ) ITEM_NUMBER
           , l_insert_date -- CREATION_DATE
           , l_insert_date -- LAST_UPDATE_DATE
           , MAX( MICI.created_by ) KEEP ( DENSE_RANK FIRST ORDER BY INVENTORY_ITEM_ID NULLS LAST, ITEM_NUMBER NULLS LAST, LAST_UPDATE_DATE NULLS LAST ) CREATED_BY
           , MAX( MICI.last_updated_by ) KEEP ( DENSE_RANK FIRST ORDER BY INVENTORY_ITEM_ID NULLS LAST, ITEM_NUMBER NULLS LAST, LAST_UPDATE_DATE NULLS LAST ) UPDATED_BY
           , MAX( MICI.last_update_login ) KEEP ( DENSE_RANK FIRST ORDER BY INVENTORY_ITEM_ID NULLS LAST, ITEM_NUMBER NULLS LAST, LAST_UPDATE_DATE NULLS LAST ) LAST_UPDATE_LOGIN
        FROM MTL_ITEM_CATEGORIES_INTERFACE    MICI
        WHERE
            MICI.set_process_id = p_data_set_id
        AND MICI.process_flag = 0
        AND MICI.organization_id = l_org_id
        AND source_system_id = l_ss_id
        AND source_system_reference IS NOT NULL
        AND NOT EXISTS
            (
            select null from mtl_system_items_interface
            where set_process_id          = MICI.set_process_id
              and source_system_id        = MICI.source_system_id
              and source_system_reference = MICI.source_system_reference
              and process_flag            = MICI.process_flag
              and organization_id         = l_org_id
            )
        GROUP BY MICI.source_system_id, MICI.source_system_reference, MICI.bundle_id;
    Debug_Conc_Log( 'Resolve_SSXref_on_Data_load - Source System batch, parent rows inserted for CAT Assignments: ' || SQL%ROWCOUNT );
    -- R12C: End
    -- check for records that need to be marked excluded
    UPDATE
        MTL_SYSTEM_ITEMS_INTERFACE MSII
    SET CONFIRM_STATUS = CASE
                         WHEN CONFIRM_STATUS IS NULL THEN G_EXCLUDED
                         ELSE G_FAKE_EXCLUDED
                         END
    WHERE
            SET_PROCESS_ID = p_data_set_id
        AND (   CONFIRM_STATUS IS NULL
            OR  CONFIRM_STATUS = G_FAKE_CONF_STATUS_FLAG ) -- bug5303685: exclusion check for fake rows
        AND PROCESS_FLAG = 0
        AND ORGANIZATION_ID = l_org_id
        AND EXISTS
            ( SELECT NULL
              FROM  EGO_IMPORT_EXCLUDED_SS_ITEMS
              WHERE SOURCE_SYSTEM_ID        = MSII.SOURCE_SYSTEM_ID
                AND SOURCE_SYSTEM_REFERENCE = MSII.SOURCE_SYSTEM_REFERENCE
           );

    Debug_Conc_Log( 'Resolve_SSXref_on_Data_load - Source System batch, excluded items: ' || SQL%ROWCOUNT );

    -- parse segments into item number
    PARSE_ITEM_SEGMENTS(p_data_set_id, l_org_id);
    Debug_Conc_Log( 'Resolve_SSXref_on_Data_load - Source System batch, done parsing item segments' );

    Debug_Conc_Log( 'Resolve_SSXref_on_Data_load - Calling Err_null_ssxref_ssid' );
    --Bug 5352143
    --This Procedure errors out rows in interface table which have source system reference
    --as null or have invalid source system id

    Err_null_ssxref_ssid( p_data_set_id );

    Debug_Conc_Log( 'Resolve_SSXref_on_Data_load - Returned from Err_null_ssxref_ssid' );

    /*
     * Note that merging does not need to be aware of fake records,
     * since they will either not be created (if there are already records in MSII)
     * or will be the oldest records (if the user loads item info for previously fake
     * records).
     * Either way, the confirm status after merging will be NULL.
     */
    IF l_enabled_for_data_pool = 'N' THEN
      MERGE_BATCH(  p_batch_id        => p_data_set_id
                 ,  p_master_org_id   => l_org_id
                 ,  p_is_pdh_batch    => FND_API.G_FALSE
                 ,  p_commit          => FND_API.G_FALSE
                 );
      Debug_Conc_Log( 'Resolve_SSXref_on_Data_load - Source System batch, done merging rows' );
    ELSE
      Debug_Conc_Log( 'Resolve_SSXref_on_Data_load - Not calling merging, because batch is enabled for data pool' );
    END IF;

    -- check for records that need to be marked excluded among the merged records
    -- (for freshly merged records, confirm_status is NULL)
    -- fix for bug 5329665
    UPDATE
        MTL_SYSTEM_ITEMS_INTERFACE MSII
    SET CONFIRM_STATUS = G_EXCLUDED
    WHERE
            SET_PROCESS_ID = p_data_set_id
        AND CONFIRM_STATUS IS NULL
        AND PROCESS_FLAG   = 0
        AND ORGANIZATION_ID = l_org_id
        AND EXISTS
            ( SELECT NULL
              FROM  EGO_IMPORT_EXCLUDED_SS_ITEMS
              WHERE SOURCE_SYSTEM_ID        = MSII.SOURCE_SYSTEM_ID
                AND SOURCE_SYSTEM_REFERENCE = MSII.SOURCE_SYSTEM_REFERENCE
            );


    -- For every unprocessed master record in a batch which has transaction_type value of 'UPDATE' or 'SYNC'
    -- if it has no inventory_item_id
    --    if it has an item number, parse it into segments.
    --    determine if an item exists with these segments in MSI and if true, populate inventory_item_id
    -- else it has inventory_item_id
    --    determine if an item exists with this inventory_item_id in MSI

    -- if the current transaction_type is 'SYNC'
    --    change it to 'UPDATE' if there is a way to resolve it to an existing item.
    --    change it to 'CREATE' if there is no way to resolve it to an existing item
    UPDATE_ITEM_SYNC_RECORDS(p_data_set_id, l_org_id);
    Debug_Conc_Log( 'Resolve_SSXref_on_Data_load - Source System batch, done updating item sync records' );
    -- Now the records all have either 'UPDATE' or 'CREATE' as transaction_type
    -- UPDATE:
    --   1. Specified by user directly.
    --      a. with existent inventory_item_id -- GOOD.
    --      b. with nonexistent inventory_item_id -- BAD -- try getting it from xref
    --      c. with no inventory_item_id, some information on item number or segments
    --         c.1. is resolved to existent inventory_item_id -- GOOD
    --         c.2. can not resolve to existent inventory_item_id -- inventory_item_id is still null -- try getting it from xref
    --      d. with no PDH item key information at all -- inventory_item_id is null -- try getting it from xref
    --   2. Resolved from 'SYNC' -- may have inventory_item_id resolved. GOOD
    --                           -- may have a null inventory_item_id -- try getting it from xref

    -- CREATE:
    --   1. Specified by user directly.
    --   2. Resolved from 'SYNC'
    --      a. with nonexistent inventory_item_id
    --      b. with no inventory_item_id, some information on item number or segments which can not resolve to existent inventory_item_id
    --      c. with no PDH item key information at all.
    l_party_name := Get_Current_Party_Name;

    -- getting security predicate
    EGO_DATA_SECURITY.get_security_predicate(
      p_api_version      => 1.0
     ,p_function         => 'EGO_VIEW_SS_ITEM_XREFS'
     ,p_object_name      => 'EGO_ITEM'
     ,p_user_name        => l_party_name
     ,p_statement_type   => 'EXISTS'
     ,p_pk1_alias        => 'XREF.INVENTORY_ITEM_ID'
     ,p_pk2_alias        => l_org_id
     ,x_predicate        => l_security_predicate
     ,x_return_status    => l_return_status
    );

    l_security_predicate := NVL(l_security_predicate, '1=1');

    l_sql := q'#
    UPDATE
        MTL_SYSTEM_ITEMS_INTERFACE MSII
    SET TRANSACTION_TYPE = UPPER( TRANSACTION_TYPE )
      , INVENTORY_ITEM_ID =
                  (SELECT INVENTORY_ITEM_ID
                   FROM MTL_CROSS_REFERENCES_B XREF
                   WHERE XREF.CROSS_REFERENCE_TYPE = 'SS_ITEM_XREF' AND
                        XREF.CROSS_REFERENCE = MSII.SOURCE_SYSTEM_REFERENCE AND
                        XREF.SOURCE_SYSTEM_ID = MSII.SOURCE_SYSTEM_ID AND
                        SYSDATE BETWEEN NVL(XREF.START_DATE_ACTIVE, SYSDATE - 1) AND NVL(XREF.END_DATE_ACTIVE, SYSDATE + 1) AND #'
                        || l_security_predicate || q'# AND
                        ROWNUM < = 1)
    WHERE
        SET_PROCESS_ID = :p_data_set_id AND
        PROCESS_FLAG = 0 AND
        ORGANIZATION_ID = :l_org_id AND
        (  CONFIRM_STATUS IS NULL
        OR CONFIRM_STATUS = '#'||G_FAKE_CONF_STATUS_FLAG||q'#'
        )
        AND
        ( INVENTORY_ITEM_ID IS NULL OR NOT EXISTS
          (SELECT 1
            FROM MTL_SYSTEM_ITEMS_B
           WHERE INVENTORY_ITEM_ID = MSII.INVENTORY_ITEM_ID
          ) )
        AND UPPER( TRANSACTION_TYPE ) = 'UPDATE' #';

    execute immediate l_sql using p_data_set_id, l_org_id;
    Debug_Conc_Log( 'Resolve_SSXref_on_Data_load - Source System batch, resolved xrefs. Rows touched: ' || SQL%ROWCOUNT );
    -- determine if import policy applies to a source system item:
    -- the revision import policy should not apply if the user has given us a
    -- rev code or id in either EGO_ITM_USR_ATTR_INTRFC or MTL_ITEM_REVISIONS_INTERFACE: We set it to 'S' meaning specific.
    -- however, if the rev import policy is set to Specific already, we need to verify that
    -- the user has given us a rev code or id in either EGO_ITM_USR_ATTR_INTRFC or MTL_ITEM_REVISIONS_INTERFACE.
    UPDATE MTL_SYSTEM_ITEMS_INTERFACE MSII
    SET REVISION_IMPORT_POLICY =
        CASE
        WHEN EXISTS -- check the revision interface table
            (
            SELECT NULL
            FROM MTL_ITEM_REVISIONS_INTERFACE
            WHERE SET_PROCESS_ID = MSII.SET_PROCESS_ID
                AND SOURCE_SYSTEM_ID = MSII.SOURCE_SYSTEM_ID
                AND SOURCE_SYSTEM_REFERENCE = MSII.SOURCE_SYSTEM_REFERENCE
                AND ORGANIZATION_ID = MSII.ORGANIZATION_ID
                AND PROCESS_FLAG = MSII.PROCESS_FLAG
                AND
                (
                    REVISION_ID IS NOT NULL
                    OR REVISION IS NOT NULL
                )
            )
            THEN 'S'
        WHEN EXISTS -- check the user attrs interface table
            (
            SELECT NULL
            FROM EGO_ITM_USR_ATTR_INTRFC USR_ATTR
            WHERE DATA_SET_ID = MSII.SET_PROCESS_ID
                AND SOURCE_SYSTEM_ID = MSII.SOURCE_SYSTEM_ID
                AND SOURCE_SYSTEM_REFERENCE = MSII.SOURCE_SYSTEM_REFERENCE
                AND ORGANIZATION_ID = MSII.ORGANIZATION_ID
                AND PROCESS_STATUS = MSII.PROCESS_FLAG
                AND
                (
                    REVISION_ID IS NOT NULL
                    OR REVISION IS NOT NULL
                )
            )
            THEN 'S'
        ELSE NULL
        END
    WHERE SET_PROCESS_ID = p_data_set_id
       AND ORGANIZATION_ID = l_org_id
       AND PROCESS_FLAG = 0
       AND ( REVISION_IMPORT_POLICY = 'S' OR REVISION_IMPORT_POLICY IS NULL )
       --AND CONFIRM_STATUS IS NULL
       ;
    Debug_Conc_Log( 'Resolve_SSXref_on_Data_load - Source System batch, done resolving item import policy' );

    -- We will also try to harmonize CONFIRM_STATUS, TRANSACTION_TYPE with information the user provides on INVENTORY_ITEMID or
    -- ITEM_NUMBER, segments, et.al.
    -- CONFIRM_STATUS can have the following values: CN (confirmed new), CC (confirmed xref), CM (confirmed match),
    -- US (unconfirmed single match), UM (unconfirmed multiple match), UN (unconfirmed no match), EX (excluded), null.
    -- See spec (EGOVIMPS.pls) constants for list of confirm status values.
    -- Bug: 5458886 - If batch is cross references only batch, then New Item should not be allowed
    UPDATE -- for non-fake rows
        MTL_SYSTEM_ITEMS_INTERFACE MSII
      SET
        CONFIRM_STATUS =
        CASE
            WHEN UPPER( TRANSACTION_TYPE ) = G_TRANS_TYPE_CREATE AND l_import_xref_only = 'N' THEN G_CONF_NEW
            WHEN INVENTORY_ITEM_ID IS NOT NULL THEN G_CONF_XREF -- TRANSACTION_TYPE is 'UPDATE'
            ELSE G_UNCONF_NONE_MATCH
        END
      , TRANSACTION_TYPE = UPPER( TRANSACTION_TYPE )
    WHERE
        SET_PROCESS_ID = p_data_set_id AND
        PROCESS_FLAG = 0 AND
        ORGANIZATION_ID = l_org_id AND
        CONFIRM_STATUS IS NULL;

    UPDATE -- for fake rows
        MTL_SYSTEM_ITEMS_INTERFACE MSII
      SET
        CONFIRM_STATUS =
        CASE
            WHEN UPPER( TRANSACTION_TYPE ) = G_TRANS_TYPE_CREATE AND l_import_xref_only = 'N' THEN G_CONF_NEW
            WHEN INVENTORY_ITEM_ID IS NOT NULL THEN G_CONF_XREF_FAKE -- TRANSACTION_TYPE is 'UPDATE'
            ELSE G_UNCONF_NO_MATCH_FAKE
        END
      , TRANSACTION_TYPE = UPPER( TRANSACTION_TYPE )
    WHERE
        SET_PROCESS_ID = p_data_set_id AND
        PROCESS_FLAG = 0 AND
        ORGANIZATION_ID = l_org_id AND
        CONFIRM_STATUS = G_FAKE_CONF_STATUS_FLAG;

    -- update inventory_item_id to make sure their existence makes sense
    UPDATE
        MTL_SYSTEM_ITEMS_INTERFACE MSII
    SET
        INVENTORY_ITEM_ID =
        CASE
            WHEN CONFIRM_STATUS IN ( G_CONF_XREF, G_CONF_MATCH, G_UNCONF_SIGL_MATCH, G_UNCONF_MULT_MATCH
                                   , G_CONF_XREF_FAKE, G_CONF_MATCH_FAKE, G_UNCONF_SINGLE_MATCH_FAKE, G_UNCONF_MULTI_MATCH_FAKE )
                THEN INVENTORY_ITEM_ID
            -- if it's 'CN', 'UN', 'EX' or NULL, erase
            ELSE NULL
        END
    WHERE
        SET_PROCESS_ID = p_data_set_id AND
        PROCESS_FLAG = 0 AND
        ORGANIZATION_ID = l_org_id;

    Debug_Conc_Log( 'Resolve_SSXref_on_Data_load - Source System batch, done resolving confirm status' );
    -- for all records where item_catalog_group_name is present and item_catalog_group_id is not present
    -- update the item_catalog_group_id
    UPDATE
      MTL_SYSTEM_ITEMS_INTERFACE MSII
      SET ITEM_CATALOG_GROUP_ID = (SELECT MICG.ITEM_CATALOG_GROUP_ID
                                   FROM MTL_ITEM_CATALOG_GROUPS_B_KFV MICG
                                   WHERE MICG.CONCATENATED_SEGMENTS = MSII.ITEM_CATALOG_GROUP_NAME)
    WHERE MSII.SET_PROCESS_ID = p_data_set_id
      AND MSII.PROCESS_FLAG = 0
      AND MSII.ORGANIZATION_ID = l_org_id
      AND MSII.CONFIRM_STATUS IN ( G_CONF_NEW, G_CONF_XREF, G_CONF_MATCH, G_CONF_XREF_FAKE, G_CONF_MATCH_FAKE  )
      AND MSII.ITEM_CATALOG_GROUP_ID IS NULL
      AND MSII.ITEM_CATALOG_GROUP_NAME IS NOT NULL;

    Debug_Conc_Log('Resolve_SSXref_on_Data_load - After Updating Item Catalog Group ID' );


    IF FND_API.G_TRUE = p_commit THEN
       COMMIT;
       Debug_Conc_Log( 'Resolve_SSXref_on_Data_load - Source System batch, committed' );
    END IF;
 EXCEPTION
    WHEN NO_DATA_FOUND THEN
      IF FND_API.G_TRUE = p_commit THEN
          COMMIT;
      END IF;
      RETURN;

 END Resolve_SSXref_on_Data_load;


  /*
   * This method cleans up the row identifiers before the actual import process starts
   * Here we group the rows based on item_number or source_system_reference
   */
  PROCEDURE CLEAN_UP_UDA_ROW_IDENTS_PRE( p_batch_id             IN NUMBER,
                                         p_process_status       IN NUMBER,
                                         p_commit               IN VARCHAR2 DEFAULT FND_API.G_TRUE
                                       )
  IS
    CURSOR c_unmerged_rows(cp_ss_id IN NUMBER) IS
      SELECT ROW_IDENTIFIER FROM
      (
        SELECT
          ROW_IDENTIFIER,
          COUNT( DISTINCT ROW_IDENTIFIER )
                     OVER ( PARTITION BY
                              NVL(SOURCE_SYSTEM_ID, cp_ss_id),
                              NVL(ITEM_NUMBER, SOURCE_SYSTEM_REFERENCE),
                              REVISION,/*Bug:11887867*/
                              ATTR_GROUP_INT_NAME,
                              ATTR_INT_NAME,
                              DATA_LEVEL_ID,
                              PK1_VALUE,
                              PK2_VALUE,
                              PK3_VALUE,
                              PK4_VALUE,
                              PK5_VALUE,
                              ORGANIZATION_ID,
                              NVL( ATTR_GROUP_TYPE, G_DEFAULT_ATTR_GROUP_TYPE )
                          ) cnt
        FROM EGO_ITM_USR_ATTR_INTRFC eiuai
        WHERE DATA_SET_ID = p_batch_id
          AND PROCESS_STATUS = p_process_status
          AND (ITEM_NUMBER IS NOT NULL OR SOURCE_SYSTEM_REFERENCE IS NOT NULL)
          AND DATA_LEVEL_ID IS NOT NULL
          AND EXISTS( SELECT NULL
                      FROM EGO_FND_DSC_FLX_CTX_EXT FL_CTX_EXT
                      WHERE FL_CTX_EXT.DESCRIPTIVE_FLEXFIELD_NAME    = NVL( eiuai.ATTR_GROUP_TYPE, G_DEFAULT_ATTR_GROUP_TYPE )
                        AND FL_CTX_EXT.APPLICATION_ID                = 431
                        AND FL_CTX_EXT.DESCRIPTIVE_FLEX_CONTEXT_CODE = eiuai.ATTR_GROUP_INT_NAME
                        AND FL_CTX_EXT.MULTI_ROW                     = 'N'
                    )
      )
      WHERE CNT > 1;


    CURSOR c_intf_recs(cp_ss_id IN NUMBER) IS
      SELECT ROW_ID, MAX_ROW_IDENTIFIER FROM
      (
        SELECT
          ROWID ROW_ID,
          COUNT( DISTINCT ROW_IDENTIFIER ) OVER ( PARTITION BY
                              NVL(SOURCE_SYSTEM_ID, cp_ss_id),
                              NVL(ITEM_NUMBER, SOURCE_SYSTEM_REFERENCE),
                              REVISION,/*Bug:11887867*/
                              ATTR_GROUP_INT_NAME,
                              DATA_LEVEL_ID,
                              PK1_VALUE,
                              PK2_VALUE,
                              PK3_VALUE,
                              PK4_VALUE,
                              PK5_VALUE,
                              ORGANIZATION_ID,
                              NVL( ATTR_GROUP_TYPE, G_DEFAULT_ATTR_GROUP_TYPE )
                          ) cnt,
          MAX( ROW_IDENTIFIER ) OVER ( PARTITION BY
                                          NVL(SOURCE_SYSTEM_ID, cp_ss_id),
                                          NVL(ITEM_NUMBER, SOURCE_SYSTEM_REFERENCE),
                                          ATTR_GROUP_INT_NAME,
                                          DATA_LEVEL_ID,
                                          PK1_VALUE,
                                          PK2_VALUE,
                                          PK3_VALUE,
                                          PK4_VALUE,
                                          PK5_VALUE,
                                          ORGANIZATION_ID,
                                          NVL( ATTR_GROUP_TYPE, G_DEFAULT_ATTR_GROUP_TYPE )
                                     ) MAX_ROW_IDENTIFIER
        FROM EGO_ITM_USR_ATTR_INTRFC eiuai
        WHERE DATA_SET_ID = p_batch_id
          AND PROCESS_STATUS = p_process_status
          AND (ITEM_NUMBER IS NOT NULL OR SOURCE_SYSTEM_REFERENCE IS NOT NULL)
          AND DATA_LEVEL_ID IS NOT NULL
          AND EXISTS( SELECT NULL
                      FROM EGO_FND_DSC_FLX_CTX_EXT FL_CTX_EXT
                      WHERE FL_CTX_EXT.DESCRIPTIVE_FLEXFIELD_NAME    = NVL( eiuai.ATTR_GROUP_TYPE, G_DEFAULT_ATTR_GROUP_TYPE )
                        AND FL_CTX_EXT.APPLICATION_ID                = 431
                        AND FL_CTX_EXT.DESCRIPTIVE_FLEX_CONTEXT_CODE = eiuai.ATTR_GROUP_INT_NAME
                        AND FL_CTX_EXT.MULTI_ROW                     = 'N'
                    )
      )
      WHERE CNT > 1;

    CURSOR c_error_case_cursor IS
      SELECT /*+ INDEX(EGO_ITM_USR_ATTR_INTRFC, EGO_ITM_USR_ATTR_INTRFC_N3) */    /* Bug 9678667 */
        DISTINCT
        ORGANIZATION_ID,
        ITEM_NUMBER,
        SOURCE_SYSTEM_REFERENCE,
        INVENTORY_ITEM_ID,
        ATTR_GROUP_INT_NAME,
        TRANSACTION_ID
     FROM EGO_ITM_USR_ATTR_INTRFC
     WHERE DATA_SET_ID = p_batch_id
       AND PROCESS_STATUS = 3.475;

    l_msg_text               VARCHAR2(4000);
    dumm_status              VARCHAR2(100);
    l_user_id                NUMBER := FND_GLOBAL.USER_ID;
    l_login_id               NUMBER := FND_GLOBAL.LOGIN_ID;
    l_prog_appid             NUMBER := FND_GLOBAL.PROG_APPL_ID;
    l_prog_id                NUMBER := FND_GLOBAL.CONC_PROGRAM_ID;
    l_request_id             NUMBER := FND_GLOBAL.CONC_REQUEST_ID;
    l_err_text               VARCHAR2(4000);

    TYPE ROW_IDS IS TABLE OF ROWID INDEX BY BINARY_INTEGER;
    TYPE ROW_IDENTIFIERS IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
    l_unmerged_row_idents  ROW_IDENTIFIERS;

    l_row_ids              ROW_IDS;
    l_row_idents           ROW_IDENTIFIERS;
    l_ss_id                NUMBER;
  BEGIN
    Debug_Conc_Log('Clean_Up_UDA_Row_Idents_Pre - Starting');
    BEGIN
      SELECT SOURCE_SYSTEM_ID INTO l_ss_id
      FROM EGO_IMPORT_BATCHES_B
      WHERE BATCH_ID = p_batch_id;
    EXCEPTION WHEN NO_DATA_FOUND THEN
      l_ss_id := GET_PDH_SOURCE_SYSTEM_ID();
    END;

    Debug_Conc_Log('Clean_Up_UDA_Row_Idents_Pre - Updating item_number and revision, l_ss_id='||l_ss_id);
    UPDATE EGO_ITM_USR_ATTR_INTRFC eiuai
    SET ITEM_NUMBER = (SELECT CONCATENATED_SEGMENTS
                       FROM MTL_SYSTEM_ITEMS_KFV
                       WHERE INVENTORY_ITEM_ID = eiuai.INVENTORY_ITEM_ID
                         AND ORGANIZATION_ID = eiuai.ORGANIZATION_ID)
    WHERE DATA_SET_ID     = p_batch_id
      AND PROCESS_STATUS  = p_process_status
      AND INVENTORY_ITEM_ID IS NOT NULL
      AND ITEM_NUMBER       IS NULL;

    UPDATE EGO_ITM_USR_ATTR_INTRFC eiuai
    SET REVISION = ( SELECT R.REVISION
                     FROM MTL_ITEM_REVISIONS_B R
                     WHERE R.REVISION_ID = eiuai.REVISION_ID
                   )
    WHERE DATA_SET_ID     = p_batch_id
      AND PROCESS_STATUS  = p_process_status
      AND REVISION_ID     IS NOT NULL
      AND REVISION        IS NULL;

    Debug_Conc_Log('Clean_Up_UDA_Row_Idents_Pre - Erroring out Unmerged Rows' );
    OPEN c_unmerged_rows(l_ss_id);
    LOOP
      FETCH c_unmerged_rows BULK COLLECT INTO l_unmerged_row_idents LIMIT 1000;
      Debug_Conc_Log('Clean_Up_UDA_Row_Idents_Pre - fetched '||l_unmerged_row_idents.Count||' rows, ');

      FORALL idx IN l_unmerged_row_idents.FIRST..l_unmerged_row_idents.LAST
        UPDATE EGO_ITM_USR_ATTR_INTRFC
          SET process_status = 3.475
        WHERE DATA_SET_ID    = p_batch_id
          AND PROCESS_STATUS = p_process_status
          AND ROW_IDENTIFIER = l_unmerged_row_idents(idx);
      Debug_Conc_Log('Clean_Up_UDA_Row_Idents_Pre - Errored - '||SQL%ROWCOUNT||' rows');
      EXIT WHEN c_unmerged_rows%NOTFOUND;
    END LOOP;
    Debug_Conc_Log('Clean_Up_UDA_Row_Idents_Pre - Done Erroring unmerged rows');
    CLOSE c_unmerged_rows;

    Debug_Conc_Log('Clean_Up_UDA_Row_Idents_Pre - Logging errors for Errored out unmerged rows');
    FOR i IN c_error_case_cursor LOOP
      FND_MESSAGE.SET_NAME('EGO', 'EGO_EF_IDENTICAL_ROWS_ERR');
      FND_MESSAGE.SET_TOKEN('AG_NAME', i.ATTR_GROUP_INT_NAME);
      l_msg_text := FND_MESSAGE.GET;
      dumm_status  := INVPUOPI.mtl_log_interface_err(
                              i.ORGANIZATION_ID
                             ,l_user_id
                             ,l_login_id
                             ,l_prog_appid
                             ,l_prog_id
                             ,l_request_id
                             ,i.TRANSACTION_ID
                             ,l_msg_text
                             ,'ATTR_GROUP_INT_NAME'
                             ,'EGO_ITM_USR_ATTR_INTRFC'
                             ,'INV_IOI_ERR'
                             ,l_err_text);
    END LOOP;
    Debug_Conc_Log('Clean_Up_UDA_Row_Idents_Pre - Done Logging errors for Errored out unmerged rows');

    UPDATE /*+ INDEX(EGO_ITM_USR_ATTR_INTRFC, EGO_ITM_USR_ATTR_INTRFC_N3) */    /* Bug 9678667 */
      EGO_ITM_USR_ATTR_INTRFC
    SET
      PROCESS_STATUS = 3,
      REQUEST_ID     = l_request_id
    WHERE DATA_SET_ID    = p_batch_id
      AND PROCESS_STATUS = 3.475;

    Debug_Conc_Log('Clean_Up_UDA_Row_Idents_Pre - Done updating rows to 3');

    -- work around the following case by setting the row identifier to the same value
    --   item ids  attr_grp attr row_ident value
    --     xyz     item_sr  one  1         x
    --     xyz     item_sr  two  2         y
    -- UDA loader code throws an error ...
    Debug_Conc_Log('Clean_Up_UDA_Row_Idents_Pre - Updating row_identifiers to unique value where' );
    OPEN c_intf_recs(l_ss_id);
    LOOP
      FETCH c_intf_recs BULK COLLECT INTO l_row_ids, l_row_idents LIMIT 1000;
      Debug_Conc_Log('Clean_Up_UDA_Row_Idents_Pre - fetched '||l_unmerged_row_idents.Count||' rows, ');

      FORALL idx IN l_row_ids.FIRST..l_row_ids.LAST
        UPDATE EGO_ITM_USR_ATTR_INTRFC
          SET ROW_IDENTIFIER = l_row_idents(idx)
        WHERE ROWID = l_row_ids(idx);
      Debug_Conc_Log('Clean_Up_UDA_Row_Idents_Pre - Updated - '||SQL%ROWCOUNT||' rows');
      EXIT WHEN c_intf_recs%NOTFOUND;
    END LOOP;
    Debug_Conc_Log('Clean_Up_UDA_Row_Idents_Pre - Done updating row_identifiers');
    CLOSE c_intf_recs;

    IF FND_API.G_TRUE = p_commit THEN
      Debug_Conc_Log('Clean_Up_UDA_Row_Idents_Pre COMMITING');
      COMMIT;
    END IF;
  EXCEPTION WHEN OTHERS THEN
    IF c_unmerged_rows%ISOPEN THEN
      CLOSE c_unmerged_rows;
    END IF;
    IF c_intf_recs%ISOPEN THEN
      CLOSE c_intf_recs;
    END IF;
    Debug_Conc_Log('Clean_Up_UDA_Row_Idents_Pre Error - '||SQLERRM);
    RAISE;
  END CLEAN_UP_UDA_ROW_IDENTS_PRE;


  PROCEDURE CLEAN_UP_UDA_ROW_IDENTS_POST( p_batch_id             IN NUMBER,
                                          p_process_status       IN NUMBER,
                                          p_commit               IN VARCHAR2 DEFAULT FND_API.G_TRUE
                                        )
  IS
    CURSOR c_unmerged_rows IS
      SELECT ROW_IDENTIFIER FROM
      (
        SELECT
          ROW_IDENTIFIER,
          COUNT( DISTINCT ROW_IDENTIFIER )
                     OVER ( PARTITION BY
                              INVENTORY_ITEM_ID,
                              REVISION,/*Bug:11887867*/
                              ATTR_GROUP_INT_NAME,
                              ATTR_INT_NAME,
                              DATA_LEVEL_ID,
                              PK1_VALUE,
                              PK2_VALUE,
                              PK3_VALUE,
                              PK4_VALUE,
                              PK5_VALUE,
                              ORGANIZATION_ID,
                              NVL( ATTR_GROUP_TYPE, G_DEFAULT_ATTR_GROUP_TYPE )
                          ) cnt
        FROM EGO_ITM_USR_ATTR_INTRFC eiuai
        WHERE DATA_SET_ID = p_batch_id
          AND PROCESS_STATUS = p_process_status
          AND INVENTORY_ITEM_ID IS NOT NULL
          AND DATA_LEVEL_ID IS NOT NULL
          AND EXISTS( SELECT NULL
                      FROM EGO_FND_DSC_FLX_CTX_EXT FL_CTX_EXT
                      WHERE FL_CTX_EXT.DESCRIPTIVE_FLEXFIELD_NAME    = NVL( eiuai.ATTR_GROUP_TYPE, G_DEFAULT_ATTR_GROUP_TYPE )
                        AND FL_CTX_EXT.APPLICATION_ID                = 431
                        AND FL_CTX_EXT.DESCRIPTIVE_FLEX_CONTEXT_CODE = eiuai.ATTR_GROUP_INT_NAME
                        AND FL_CTX_EXT.MULTI_ROW                     = 'N'
                    )
      )
      WHERE CNT > 1;


    CURSOR c_intf_recs IS
      SELECT ROW_ID, MAX_ROW_IDENTIFIER FROM
      (
        SELECT
          ROWID ROW_ID,
          COUNT( DISTINCT ROW_IDENTIFIER ) OVER ( PARTITION BY
                              INVENTORY_ITEM_ID,
                              REVISION,/*Bug:11887867*/
                              ATTR_GROUP_INT_NAME,
                              DATA_LEVEL_ID,
                              PK1_VALUE,
                              PK2_VALUE,
                              PK3_VALUE,
                              PK4_VALUE,
                              PK5_VALUE,
                              ORGANIZATION_ID,
                              NVL( ATTR_GROUP_TYPE, G_DEFAULT_ATTR_GROUP_TYPE )
                          ) cnt,
          MAX( ROW_IDENTIFIER ) OVER ( PARTITION BY
                                          INVENTORY_ITEM_ID,
                                          ATTR_GROUP_INT_NAME,
                                          DATA_LEVEL_ID,
                                          PK1_VALUE,
                                          PK2_VALUE,
                                          PK3_VALUE,
                                          PK4_VALUE,
                                          PK5_VALUE,
                                          ORGANIZATION_ID,
                                          NVL( ATTR_GROUP_TYPE, G_DEFAULT_ATTR_GROUP_TYPE )
                                     ) MAX_ROW_IDENTIFIER
        FROM EGO_ITM_USR_ATTR_INTRFC eiuai
        WHERE DATA_SET_ID = p_batch_id
          AND PROCESS_STATUS = p_process_status
          AND INVENTORY_ITEM_ID IS NOT NULL
          AND DATA_LEVEL_ID IS NOT NULL
          AND EXISTS( SELECT NULL
                      FROM EGO_FND_DSC_FLX_CTX_EXT FL_CTX_EXT
                      WHERE FL_CTX_EXT.DESCRIPTIVE_FLEXFIELD_NAME    = NVL( eiuai.ATTR_GROUP_TYPE, G_DEFAULT_ATTR_GROUP_TYPE )
                        AND FL_CTX_EXT.APPLICATION_ID                = 431
                        AND FL_CTX_EXT.DESCRIPTIVE_FLEX_CONTEXT_CODE = eiuai.ATTR_GROUP_INT_NAME
                        AND FL_CTX_EXT.MULTI_ROW                     = 'N'
                    )
      )
      WHERE CNT > 1;

    CURSOR c_error_case_cursor IS
      SELECT /*+ INDEX(EGO_ITM_USR_ATTR_INTRFC, EGO_ITM_USR_ATTR_INTRFC_N3) */    /* Bug 9678667 */
      DISTINCT
        ORGANIZATION_ID,
        ITEM_NUMBER,
        SOURCE_SYSTEM_REFERENCE,
        INVENTORY_ITEM_ID,
        ATTR_GROUP_INT_NAME,
        TRANSACTION_ID
     FROM EGO_ITM_USR_ATTR_INTRFC
     WHERE DATA_SET_ID = p_batch_id
       AND PROCESS_STATUS = 3.475;

    l_msg_text               VARCHAR2(4000);
    dumm_status              VARCHAR2(100);
    l_user_id                NUMBER := FND_GLOBAL.USER_ID;
    l_login_id               NUMBER := FND_GLOBAL.LOGIN_ID;
    l_prog_appid             NUMBER := FND_GLOBAL.PROG_APPL_ID;
    l_prog_id                NUMBER := FND_GLOBAL.CONC_PROGRAM_ID;
    l_request_id             NUMBER := FND_GLOBAL.CONC_REQUEST_ID;
    l_err_text               VARCHAR2(4000);

    TYPE ROW_IDS IS TABLE OF ROWID INDEX BY BINARY_INTEGER;
    TYPE ROW_IDENTIFIERS IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
    l_unmerged_row_idents  ROW_IDENTIFIERS;

    l_row_ids              ROW_IDS;
    l_row_idents           ROW_IDENTIFIERS;
  BEGIN
    Debug_Conc_Log('Clean_Up_UDA_Row_Idents_Post - Starting');
    Debug_Conc_Log('Clean_Up_UDA_Row_Idents_Post - Erroring out Unmerged Rows' );
    OPEN c_unmerged_rows;
    LOOP
      FETCH c_unmerged_rows BULK COLLECT INTO l_unmerged_row_idents LIMIT 1000;
      Debug_Conc_Log('Clean_Up_UDA_Row_Idents_Post - fetched '||l_unmerged_row_idents.Count||' rows, ');

      FORALL idx IN l_unmerged_row_idents.FIRST..l_unmerged_row_idents.LAST
        UPDATE EGO_ITM_USR_ATTR_INTRFC
          SET process_status = 3.475
        WHERE DATA_SET_ID    = p_batch_id
          AND PROCESS_STATUS = p_process_status
          AND ROW_IDENTIFIER = l_unmerged_row_idents(idx);
      Debug_Conc_Log('Clean_Up_UDA_Row_Idents_Post - Errored - '||SQL%ROWCOUNT||' rows');
      EXIT WHEN c_unmerged_rows%NOTFOUND;
    END LOOP;
    Debug_Conc_Log('Clean_Up_UDA_Row_Idents_Post - Done Erroring unmerged rows');
    CLOSE c_unmerged_rows;

    Debug_Conc_Log('Clean_Up_UDA_Row_Idents_Post - Logging errors for Errored out unmerged rows');
    FOR i IN c_error_case_cursor LOOP
      FND_MESSAGE.SET_NAME('EGO', 'EGO_EF_IDENTICAL_ROWS_ERR');
      FND_MESSAGE.SET_TOKEN('AG_NAME', i.ATTR_GROUP_INT_NAME);
      l_msg_text := FND_MESSAGE.GET;
      dumm_status  := INVPUOPI.mtl_log_interface_err(
                              i.ORGANIZATION_ID
                             ,l_user_id
                             ,l_login_id
                             ,l_prog_appid
                             ,l_prog_id
                             ,l_request_id
                             ,i.TRANSACTION_ID
                             ,l_msg_text
                             ,'ATTR_GROUP_INT_NAME'
                             ,'EGO_ITM_USR_ATTR_INTRFC'
                             ,'INV_IOI_ERR'
                             ,l_err_text);
    END LOOP;
    Debug_Conc_Log('Clean_Up_UDA_Row_Idents_Post - Done Logging errors for Errored out unmerged rows');

    UPDATE /*+ INDEX(EGO_ITM_USR_ATTR_INTRFC, EGO_ITM_USR_ATTR_INTRFC_N3) */    /* Bug 9678667 */
      EGO_ITM_USR_ATTR_INTRFC
    SET
      PROCESS_STATUS = 3,
      REQUEST_ID     = l_request_id
    WHERE DATA_SET_ID    = p_batch_id
      AND PROCESS_STATUS = 3.475;

    Debug_Conc_Log('Clean_Up_UDA_Row_Idents_Post - Done updating rows to 3');

    -- work around the following case by setting the row identifier to the same value
    --   item ids  attr_grp attr row_ident value
    --     xyz     item_sr  one  1         x
    --     xyz     item_sr  two  2         y
    -- UDA loader code throws an error ...
    Debug_Conc_Log('Clean_Up_UDA_Row_Idents_Post - Updating row_identifiers to unique value where' );
    OPEN c_intf_recs;
    LOOP
      FETCH c_intf_recs BULK COLLECT INTO l_row_ids, l_row_idents LIMIT 1000;
      Debug_Conc_Log('Clean_Up_UDA_Row_Idents_Post - fetched '||l_unmerged_row_idents.Count||' rows, ');

      FORALL idx IN l_row_ids.FIRST..l_row_ids.LAST
        UPDATE EGO_ITM_USR_ATTR_INTRFC
          SET ROW_IDENTIFIER = l_row_idents(idx)
        WHERE ROWID = l_row_ids(idx);
      Debug_Conc_Log('Clean_Up_UDA_Row_Idents_Post - Updated - '||SQL%ROWCOUNT||' rows');
      EXIT WHEN c_intf_recs%NOTFOUND;
    END LOOP;
    Debug_Conc_Log('Clean_Up_UDA_Row_Idents_Post - Done updating row_identifiers');
    CLOSE c_intf_recs;

    IF FND_API.G_TRUE = p_commit THEN
      Debug_Conc_Log('Clean_Up_UDA_Row_Idents_Post COMMITING');
      COMMIT;
    END IF;
  EXCEPTION WHEN OTHERS THEN
    IF c_unmerged_rows%ISOPEN THEN
      CLOSE c_unmerged_rows;
    END IF;
    IF c_intf_recs%ISOPEN THEN
      CLOSE c_intf_recs;
    END IF;
    Debug_Conc_Log('Clean_Up_UDA_Row_Idents_Post Error - '||SQLERRM);
    RAISE;
  END CLEAN_UP_UDA_ROW_IDENTS_POST;

  /*
   * This method cleans up UDA row identifiers, ensuring that all single attr groups
   * are represented by only one row identifier in EGO_ITM_USR_ATTR_INTRFC
   *
   * Helper procedure for resolve_child_entities
   */
  PROCEDURE CLEAN_UP_UDA_ROW_IDENTS( p_batch_id             IN NUMBER,
                                     p_process_status       IN NUMBER,
                                     p_ignore_item_num_upd  IN VARCHAR2, --FND_API.G_TRUE
                                     p_commit               IN VARCHAR2 DEFAULT FND_API.G_TRUE
                                   )
  IS
  BEGIN
    Debug_Conc_Log('Clean_Up_UDA_Row_Idents - Starting');
    IF p_ignore_item_num_upd = FND_API.G_FALSE THEN
      Debug_Conc_Log('Clean_Up_UDA_Row_Idents - Calling CLEAN_UP_UDA_ROW_IDENTS_PRE');
      CLEAN_UP_UDA_ROW_IDENTS_PRE(p_batch_id       => p_batch_id,
                                  p_process_status => p_process_status,
                                  p_commit         => p_commit);
      Debug_Conc_Log('Clean_Up_UDA_Row_Idents - Done CLEAN_UP_UDA_ROW_IDENTS_PRE');
    ELSE
      Debug_Conc_Log('Clean_Up_UDA_Row_Idents - Calling CLEAN_UP_UDA_ROW_IDENTS_POST');
      CLEAN_UP_UDA_ROW_IDENTS_POST(p_batch_id       => p_batch_id,
                                   p_process_status => p_process_status,
                                   p_commit         => p_commit);
      Debug_Conc_Log('Clean_Up_UDA_Row_Idents - Done CLEAN_UP_UDA_ROW_IDENTS_POST');
    END IF;
  END CLEAN_UP_UDA_ROW_IDENTS;

 /*
  * This method populates the child entities with PK values.
  * This method populates the other interface tables like MTL_ITEM_REVISION_INTERFACE,
  * EGO_ITEM_PEOPLE_INTF, MTL_ITEM_CATEGORIES_INTERFACE, EGO_ITM_USR_ATTR_INTRFC etc.
  * with the inventory item id/number and organization id/code.
  */
  PROCEDURE Resolve_Child_Entities( p_data_set_id  IN  NUMBER
                                  , p_commit       IN  FLAG    DEFAULT FND_API.G_TRUE
                                  )
  IS
    CURSOR c_no_privilege_rows IS
      SELECT
        ROWID,
        SOURCE_SYSTEM_ID,
        SOURCE_SYSTEM_REFERENCE,
        ITEM_NUMBER,
        ORGANIZATION_CODE,
        INVENTORY_ITEM_ID,
        ORGANIZATION_ID,
        TRANSACTION_TYPE,
        TRANSACTION_ID
      FROM MTL_SYSTEM_ITEMS_INTERFACE MSII
      WHERE SET_PROCESS_ID = p_data_set_id
        AND PROCESS_FLAG = 33390;



    CURSOR c_old_xref_no_priv_row IS
      SELECT  KFV.CONCATENATED_SEGMENTS ITEM_NUMBER,
              MSII.ORGANIZATION_CODE,
              MSII.ORGANIZATION_ID,
              MSII.TRANSACTION_ID
      FROM    MTL_SYSTEM_ITEMS_B_KFV KFV,
              MTL_SYSTEM_ITEMS_INTERFACE MSII,
              MTL_CROSS_REFERENCES MCR
      WHERE   MSII.SET_PROCESS_ID          = p_data_set_id
              AND MCR.CROSS_REFERENCE_TYPE = 'SS_ITEM_XREF'
              AND MSII.SOURCE_SYSTEM_ID    = MCR.SOURCE_SYSTEM_ID
              AND MSII.ORGANIZATION_ID     = KFV.ORGANIZATION_ID
              AND MCR.CROSS_REFERENCE      = MSII.SOURCE_SYSTEM_REFERENCE
              AND MCR.INVENTORY_ITEM_ID    = KFV.INVENTORY_ITEM_ID
              AND SYSDATE BETWEEN NVL(MCR.START_DATE_ACTIVE, SYSDATE-1) AND NVL(MCR.END_DATE_ACTIVE, SYSDATE + 1)
              AND MSII.PROCESS_FLAG = 33391;



    l_msg_text               VARCHAR2(4000);
    dumm_status              VARCHAR2(100);
    l_user_id                NUMBER := FND_GLOBAL.USER_ID;
    l_login_id               NUMBER := FND_GLOBAL.LOGIN_ID;
    l_prog_appid             NUMBER := FND_GLOBAL.PROG_APPL_ID;
    l_prog_id                NUMBER := FND_GLOBAL.CONC_PROGRAM_ID;
    l_request_id             NUMBER := FND_GLOBAL.CONC_REQUEST_ID;
    l_err_text               VARCHAR2(4000);
    l_ss_id                  EGO_IMPORT_BATCHES_B.SOURCE_SYSTEM_ID%TYPE;
    l_org_id                 EGO_IMPORT_BATCHES_B.ORGANIZATION_ID%TYPE;
    l_item_id                NUMBER;
    l_revision               MTL_ITEM_REVISIONS_B.REVISION%TYPE;
    l_error                  BOOLEAN;
    l_import_policy          EGO_IMPORT_OPTION_SETS.REVISION_IMPORT_POLICY%TYPE;

    l_import_xref_only       EGO_IMPORT_OPTION_SETS.IMPORT_XREF_ONLY%TYPE;
    l_party_name             VARCHAR2(1000);
    l_security_predicate     VARCHAR2(4000);
    l_return_status          VARCHAR2(100);
    l_sql                    VARCHAR2(32000);
    l_enabled_for_data_pool  EGO_IMPORT_OPTION_SETS.ENABLED_FOR_DATA_POOL%TYPE;
    l_org                    VARCHAR2(100);
  BEGIN
    -- get the source_system_id for this batch
    Debug_Conc_Log( 'Resolve_Child_Entities START' );
    BEGIN
      SELECT
        BA.SOURCE_SYSTEM_ID,
        BA.ORGANIZATION_ID,
        NVL(OPT.REVISION_IMPORT_POLICY, 'L'),
        NVL(opt.IMPORT_XREF_ONLY, 'N'),
        NVL(opt.ENABLED_FOR_DATA_POOL, 'N')
      INTO l_ss_id, l_org_id, l_import_policy, l_import_xref_only, l_enabled_for_data_pool
      FROM EGO_IMPORT_BATCHES_B BA, EGO_IMPORT_OPTION_SETS OPT
      WHERE BA.BATCH_ID = p_data_set_id AND BA.BATCH_ID = OPT.BATCH_ID;
    EXCEPTION WHEN NO_DATA_FOUND THEN
      l_org := fnd_profile.value('EGO_USER_ORGANIZATION_CONTEXT');
      BEGIN
        SELECT mp.MASTER_ORGANIZATION_ID
        INTO l_org_id
        FROM MTL_PARAMETERS mp
        WHERE mp.ORGANIZATION_ID = TO_NUMBER(l_org);
      EXCEPTION WHEN OTHERS THEN
        l_org_id := NULL;
      END;
      l_ss_id := get_pdh_source_system_id();
      l_import_xref_only := 'N';
      l_enabled_for_data_pool := 'N';
      l_import_policy := NULL;
    END;

    -- no need to resolve child entities for a PDH batch
    -- no need to resolve child entities for a Non-PDH batch, if Import Only Cross References is true
    IF l_ss_id = get_pdh_source_system_id() THEN
      -- move fake rows to have the success process flag value
      -- so that they are not processed by IOI
      UPDATE MTL_SYSTEM_ITEMS_INTERFACE
      SET
          REQUEST_ID              = l_request_id
        , PROGRAM_APPLICATION_ID  = l_prog_appid
        , PROGRAM_ID              = l_prog_id
        , PROGRAM_UPDATE_DATE     = SYSDATE
        , PROCESS_FLAG            = CASE  -- bug 5283663: never leave fake rows in status 1
                                    WHEN  UPPER( TRANSACTION_TYPE ) <> G_TRANS_TYPE_CREATE   THEN 7
                                    ELSE  3
                                    END
      WHERE
          set_process_id  = p_data_set_id
      AND organization_id = l_org_id
      AND confirm_status  = G_FAKE_CONF_STATUS_FLAG
      AND (REQUEST_ID IS NULL OR REQUEST_ID = l_request_id)  --added for bug 8860381
--      AND UPPER( TRANSACTION_TYPE ) <> G_TRANS_TYPE_CREATE  -- bug 5283663: never leave fake rows in status 1
      ;

      Debug_Conc_Log('Resolve_Child_Entities - Calling Clean_Up_UDA_Row_Idents');
      Clean_Up_UDA_Row_Idents( p_batch_id            => p_data_set_id,
                               p_process_status      => 1,
                               p_ignore_item_num_upd => FND_API.G_FALSE,
                               p_commit              => FND_API.G_FALSE );
      Debug_Conc_Log('Resolve_Child_Entities - Clean_Up_UDA_Row_Idents Done.');

      Debug_Conc_Log('Resolve_Child_Entities - Resolving Style_Item_Flag');
      UPDATE MTL_SYSTEM_ITEMS_INTERFACE msii
      SET (STYLE_ITEM_FLAG, STYLE_ITEM_ID, INVENTORY_ITEM_ID) = (SELECT
                                                DECODE(MAX(NVL(msik.STYLE_ITEM_FLAG, '$NULL$')),
                                                       '$NULL$', msii.STYLE_ITEM_FLAG,
                                                       NULL, msii.STYLE_ITEM_FLAG,
                                                       'N', 'N',
                                                       'Y', 'Y'
                                                      ),
                                                NVL(MAX(msik.STYLE_ITEM_ID), msii.STYLE_ITEM_ID),
            NVL(msii.INVENTORY_ITEM_ID, MAX(msik.INVENTORY_ITEM_ID))
                                              FROM MTL_SYSTEM_ITEMS_KFV msik, MTL_PARAMETERS mp
                                              WHERE (msii.INVENTORY_ITEM_ID = msik.INVENTORY_ITEM_ID
                                                  OR msii.ITEM_NUMBER = msik.CONCATENATED_SEGMENTS)
                                                AND msik.ORGANIZATION_ID = mp.MASTER_ORGANIZATION_ID
                                                AND msii.ORGANIZATION_ID = mp.ORGANIZATION_ID
                                             )
      WHERE SET_PROCESS_ID = p_data_set_id
        AND PROCESS_FLAG   = 1;

      Debug_Conc_Log('Resolve_Child_Entities - Done Resolving Style_Item_Flag, rows processed='||SQL%ROWCOUNT);

      Debug_Conc_Log('Resolve_Child_Entities END');
      IF FND_API.G_TRUE = p_commit THEN
        Debug_Conc_Log('Resolve_Child_Entities COMMITING');
        COMMIT;
      END IF;
      RETURN;
    END IF;

    l_party_name := Get_Current_Party_Name;

    -- getting security predicate
    EGO_DATA_SECURITY.get_security_predicate(
      p_api_version      => 1.0
     ,p_function         => 'EGO_EDIT_SS_ITEM_XREFS'
     ,p_object_name      => 'EGO_ITEM'
     ,p_user_name        => l_party_name
     ,p_statement_type   => 'EXISTS'
     ,p_pk1_alias        => 'APPLYSEC.INVENTORY_ITEM_ID'
     ,p_pk2_alias        => l_org_id
     ,x_predicate        => l_security_predicate
     ,x_return_status    => l_return_status
    );

    Debug_Conc_Log('Resolve_Child_Entities - Security Predicate = '||l_security_predicate);
    IF NVL(l_import_xref_only, 'N') = 'Y' THEN
      Debug_Conc_Log('Resolve_Child_Entities - Import Cross References Only is true' );
      IF l_security_predicate IS NULL THEN
        RETURN;
      ELSE
        Debug_Conc_Log('Resolve_Child_Entities - Checking data security');
        --  For CN case, if one is importing cross-references only, the new item would not be
        --  created. Thus, there's no need to check security on the cross-references.

        --  CC/CM:
        --   old link and new link are the same:
        l_sql := q'#
          UPDATE MTL_SYSTEM_ITEMS_INTERFACE MSII
          SET PROCESS_FLAG = 33390
          WHERE SET_PROCESS_ID = :p_data_set_id
            AND PROCESS_FLAG = 0
            AND ORGANIZATION_ID = :org_id
            AND CONFIRM_STATUS IN ('CC', 'CM', 'CFC', 'CFM')
            AND EXISTS
                    (SELECT 1
                     FROM MTL_CROSS_REFERENCES_VL APPLYSEC
                     WHERE APPLYSEC.CROSS_REFERENCE = MSII.SOURCE_SYSTEM_REFERENCE
                       AND APPLYSEC.SOURCE_SYSTEM_ID = MSII.SOURCE_SYSTEM_ID
                       AND APPLYSEC.CROSS_REFERENCE_TYPE = 'SS_ITEM_XREF'
                       AND APPLYSEC.INVENTORY_ITEM_ID = MSII.INVENTORY_ITEM_ID
                       AND (APPLYSEC.DESCRIPTION <> MSII.SOURCE_SYSTEM_REFERENCE_DESC OR
                           (APPLYSEC.DESCRIPTION IS NULL AND MSII.SOURCE_SYSTEM_REFERENCE_DESC IS NOT NULL))
                       AND SYSDATE BETWEEN  NVL(APPLYSEC.START_DATE_ACTIVE, SYSDATE-1) AND NVL(APPLYSEC.END_DATE_ACTIVE, SYSDATE + 1)
                       AND NOT #' || l_security_predicate || ' )';

        EXECUTE IMMEDIATE l_sql USING p_data_set_id, l_org_id;

        Debug_Conc_Log( 'Resolve_Child_Entities - After checking security on the link where old link and new link are the same and
                         source system reference desc is being updated');
        --  old link and new link are not the same:
        --     check edit privilege on old item link (if any)
        l_sql := q'#
          UPDATE MTL_SYSTEM_ITEMS_INTERFACE MSII
          SET PROCESS_FLAG = 33391
          WHERE SET_PROCESS_ID = :p_data_set_id
            AND PROCESS_FLAG = 0
            AND ORGANIZATION_ID = :org_id
            AND CONFIRM_STATUS IN ('CC', 'CM', 'CFC', 'CFM')
            AND EXISTS ( SELECT 1
                         FROM MTL_CROSS_REFERENCES_B APPLYSEC
                         WHERE APPLYSEC.CROSS_REFERENCE = MSII.SOURCE_SYSTEM_REFERENCE
                           AND APPLYSEC.SOURCE_SYSTEM_ID = MSII.SOURCE_SYSTEM_ID
                           AND APPLYSEC.CROSS_REFERENCE_TYPE = 'SS_ITEM_XREF'
                           AND APPLYSEC.INVENTORY_ITEM_ID <> MSII.INVENTORY_ITEM_ID
                           AND SYSDATE BETWEEN  NVL(APPLYSEC.START_DATE_ACTIVE, SYSDATE-1) AND NVL(APPLYSEC.END_DATE_ACTIVE, SYSDATE + 1)
                           AND NOT #' || l_security_predicate || ' )';

        EXECUTE IMMEDIATE l_sql USING p_data_set_id, l_org_id;

        Debug_Conc_Log( 'Resolve_Child_Entities - After checking security on old item link (if any) where old link and new link are not the same' );
        --  old link and new link are not the same:
        --     check edit privilege on new item link
        l_sql := q'#
          UPDATE MTL_SYSTEM_ITEMS_INTERFACE APPLYSEC
          SET PROCESS_FLAG = 33390
          WHERE SET_PROCESS_ID = :p_data_set_id
            AND PROCESS_FLAG = 0
            AND ORGANIZATION_ID = :org_id
            AND CONFIRM_STATUS IN ('CC', 'CM', 'CFC', 'CFM')
            AND NOT #' || l_security_predicate  || q'#
            AND APPLYSEC.INVENTORY_ITEM_ID IS NOT NULL
            AND LNNVL (APPLYSEC.INVENTORY_ITEM_ID =
                            (SELECT XREF.INVENTORY_ITEM_ID
                             FROM MTL_CROSS_REFERENCES_B XREF
                             WHERE XREF.CROSS_REFERENCE = APPLYSEC.SOURCE_SYSTEM_REFERENCE
                               AND XREF.SOURCE_SYSTEM_ID = APPLYSEC.SOURCE_SYSTEM_ID
                               AND XREF.CROSS_REFERENCE_TYPE = 'SS_ITEM_XREF'
                               AND SYSDATE BETWEEN NVL(XREF.START_DATE_ACTIVE, SYSDATE-1) AND NVL(XREF.END_DATE_ACTIVE, SYSDATE + 1))) #';

        EXECUTE IMMEDIATE l_sql USING p_data_set_id, l_org_id;

        Debug_Conc_Log( 'Resolve_Child_Entities - After checking security on new item link where old link and new link are not the same' );

        FOR i IN c_no_privilege_rows LOOP
          FND_MESSAGE.SET_NAME('EGO', 'EGO_NO_EDIT_XREF_PRIV');
          FND_MESSAGE.SET_TOKEN('ITEM', i.ITEM_NUMBER);
          FND_MESSAGE.SET_TOKEN('ORG', i.ORGANIZATION_CODE);
          l_msg_text := FND_MESSAGE.GET;

          dumm_status  := INVPUOPI.mtl_log_interface_err(
                                i.ORGANIZATION_ID
                               ,l_user_id
                               ,l_login_id
                               ,l_prog_appid
                               ,l_prog_id
                               ,l_request_id
                               ,i.TRANSACTION_ID
                               ,l_msg_text
                               ,'SOURCE_SYSTEM_REFERENCE'
                               ,'MTL_SYSTEM_ITEMS_INTERFACE'
                               ,'INV_IOI_ERR'
                               ,l_err_text);

        END LOOP;

        FOR i IN c_old_xref_no_priv_row LOOP
          FND_MESSAGE.SET_NAME('EGO', 'EGO_NO_EDIT_XREF_PRIV');
          FND_MESSAGE.SET_TOKEN('ITEM', i.ITEM_NUMBER);
          FND_MESSAGE.SET_TOKEN('ORG', i.ORGANIZATION_CODE);
          l_msg_text := FND_MESSAGE.GET;

          dumm_status  := INVPUOPI.mtl_log_interface_err(
                          i.ORGANIZATION_ID
                         ,l_user_id
                         ,l_login_id
                         ,l_prog_appid
                         ,l_prog_id
                         ,l_request_id
                         ,i.TRANSACTION_ID
                         ,l_msg_text
                         ,'SOURCE_SYSTEM_REFERENCE'
                         ,'MTL_SYSTEM_ITEMS_INTERFACE'
                         ,'INV_IOI_ERR'
                         ,l_err_text);
        END LOOP;

        Debug_Conc_Log( 'Resolve_Child_Entities - After logging errors for records without privilege' );

        UPDATE MTL_SYSTEM_ITEMS_INTERFACE
        SET PROCESS_FLAG = 3
        WHERE SET_PROCESS_ID = p_data_set_id
          AND PROCESS_FLAG IN (33390, 33391)
          AND CONFIRM_STATUS IN ( 'CM', 'CC', 'CN', G_CONF_XREF_FAKE, G_CONF_MATCH_FAKE )
          AND ORGANIZATION_ID = l_org_id;

        Debug_Conc_Log( 'Resolve_Child_Entities - After erroring out records without privilege' );

        IF FND_API.G_TRUE = p_commit THEN
          Debug_Conc_Log( 'Resolve_Child_Entities COMMITING' );
          COMMIT;
        END IF;

        RETURN;
      END IF; --IF l_security_predicate IS NULL THEN
    END IF; --IF NVL(l_import_xref_only, 'N') = 'Y' THEN

    -- resolving transaction type for revisions
    UPDATE MTL_ITEM_REVISIONS_INTERFACE MIRI
    SET TRANSACTION_TYPE = (
         SELECT
           (CASE
              WHEN MSII.CONFIRM_STATUS = 'CN'
              THEN 'CREATE'
              WHEN (MSII.CONFIRM_STATUS IN ( 'CM', 'CC', G_CONF_XREF_FAKE, G_CONF_MATCH_FAKE )
                    AND EXISTS (SELECT NULL
                                FROM MTL_ITEM_REVISIONS_B MIR
                                WHERE MIR.INVENTORY_ITEM_ID = MSII.INVENTORY_ITEM_ID
                                  AND MIR.ORGANIZATION_ID = MIRI.ORGANIZATION_ID
                                  AND MIR.REVISION = MIRI.REVISION) )
              THEN 'UPDATE'
              ELSE 'CREATE'
            END)
         FROM MTL_SYSTEM_ITEMS_INTERFACE MSII
         WHERE MSII.SET_PROCESS_ID = p_data_set_id
           AND MSII.PROCESS_FLAG = 0
           AND MSII.CONFIRM_STATUS IN ('CN', 'CM', 'CC', G_CONF_XREF_FAKE, G_CONF_MATCH_FAKE)
           AND MSII.SOURCE_SYSTEM_ID = MIRI.SOURCE_SYSTEM_ID
           AND MSII.SOURCE_SYSTEM_REFERENCE = MIRI.SOURCE_SYSTEM_REFERENCE
           AND MSII.ORGANIZATION_ID = l_org_id
           AND ROWNUM = 1
        )
    WHERE MIRI.PROCESS_FLAG = 0
      AND MIRI.SET_PROCESS_ID = p_data_set_id
      AND EXISTS (SELECT NULL
                  FROM MTL_SYSTEM_ITEMS_INTERFACE MSII
                  WHERE MSII.SET_PROCESS_ID = p_data_set_id
                    AND MSII.PROCESS_FLAG = 0
                    AND MSII.CONFIRM_STATUS IN ( 'CN', 'CM', 'CC', G_CONF_XREF_FAKE, G_CONF_MATCH_FAKE )
                    AND MSII.SOURCE_SYSTEM_ID = MIRI.SOURCE_SYSTEM_ID
                    AND MSII.SOURCE_SYSTEM_REFERENCE = MIRI.SOURCE_SYSTEM_REFERENCE
                    AND MSII.ORGANIZATION_ID = l_org_id);

    Debug_Conc_Log('Resolve_Child_Entities - After resolving transaction_type for revisions' );

    -- update the confirm status to ready for all READY CN records
    UPDATE
      MTL_SYSTEM_ITEMS_INTERFACE MSII
      SET CONFIRM_STATUS = (
      CASE
        WHEN (MSII.DESCRIPTION IS NULL
              AND NOT EXISTS
                  (SELECT NULL
                   FROM MTL_ITEM_TEMPLATES_VL TEMP,
                     MTL_ITEM_TEMPL_ATTRIBUTES ATTR
                   WHERE ((MSII.TEMPLATE_ID IS NOT NULL AND TEMP.TEMPLATE_ID = MSII.TEMPLATE_ID)
                          OR (MSII.TEMPLATE_ID IS NULL AND TEMP.TEMPLATE_NAME = MSII.TEMPLATE_NAME)
                         )
                     AND (TEMP.CONTEXT_ORGANIZATION_ID = MSII.ORGANIZATION_ID OR TEMP.CONTEXT_ORGANIZATION_ID IS NULL)
                     AND TEMP.TEMPLATE_ID = ATTR.TEMPLATE_ID
                     AND ATTR.ENABLED_FLAG = 'Y'
                     AND ATTR.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.DESCRIPTION'
                  )
              AND 'F' <>
                  (SELECT DECODE(MSII.STYLE_ITEM_FLAG, 'Y', 'ZZZ', (MAX(ICC.ITEM_DESC_GEN_METHOD) KEEP (DENSE_RANK FIRST ORDER BY LEVEL) ) ) AS ITEM_DESC_GEN_METHOD
                   FROM MTL_ITEM_CATALOG_GROUPS_B ICC
                   WHERE ICC.ITEM_DESC_GEN_METHOD IS NOT NULL
                     AND ICC.ITEM_DESC_GEN_METHOD <> 'I'
                   CONNECT BY PRIOR ICC.PARENT_CATALOG_GROUP_ID = ICC.ITEM_CATALOG_GROUP_ID
                   START WITH ICC.ITEM_CATALOG_GROUP_ID = MSII.ITEM_CATALOG_GROUP_ID
                  )
             )
        THEN CONFIRM_STATUS
        WHEN
        (MSII.ITEM_NUMBER IS NULL AND MSII.ITEM_CATALOG_GROUP_ID IS NULL)
        THEN CONFIRM_STATUS
        WHEN
        (    MSII.ITEM_CATALOG_GROUP_ID IS NOT NULL
         AND MSII.ITEM_NUMBER IS NULL
         AND (SELECT DECODE(MSII.STYLE_ITEM_FLAG, 'Y', 'ZZZ', (MAX(ICC.ITEM_NUM_GEN_METHOD) KEEP (DENSE_RANK FIRST ORDER BY LEVEL) ) ) AS ITEM_NUM_GEN_METHOD
              FROM MTL_ITEM_CATALOG_GROUPS_B ICC
              WHERE ICC.ITEM_NUM_GEN_METHOD IS NOT NULL
                AND ICC.ITEM_NUM_GEN_METHOD <> 'I'
              CONNECT BY PRIOR ICC.PARENT_CATALOG_GROUP_ID = ICC.ITEM_CATALOG_GROUP_ID
              START WITH ICC.ITEM_CATALOG_GROUP_ID = MSII.ITEM_CATALOG_GROUP_ID
             ) NOT IN ('S', 'F')
        )
        THEN CONFIRM_STATUS
        ELSE CONFIRM_STATUS||'R'
      END
      )
    WHERE MSII.SET_PROCESS_ID = p_data_set_id
      AND MSII.PROCESS_FLAG = 0
      AND MSII.ORGANIZATION_ID = l_org_id
      AND MSII.CONFIRM_STATUS = 'CN';

    Debug_Conc_Log('Resolve_Child_Entities - After updating confirm status to CNR' );
    -- for all records with confirm_status = CN and item_number is null and is sequence generated
    -- update the item_number column.

    -- eletuchy:
    -- The item number must be generated here because the IOI doesn't know anything about source system references.
    -- Therefore, the parent-child linkages must be reported to IOI via inventory_item_id and item_number columns.
    -- For CN items with sequence-generated item_numbers, neither inventory_item_id not item_number contain any info,
    -- so IOI wouldn't know about the parent-child linkages unless the item number generation occurs here.

    -- dsakalle: For R12C, bug 6113606
    -- We are not honoring user entered item number values from R12C
    -- so the overwriting of item number must happen only from IOI
    /*
    UPDATE
      MTL_SYSTEM_ITEMS_INTERFACE MSII
      SET ITEM_NUMBER = EGO_IMPORT_PVT.GET_NEXT_ITEM_NUMBER(MSII.ITEM_CATALOG_GROUP_ID)
    WHERE MSII.ITEM_CATALOG_GROUP_ID IS NOT NULL
      AND MSII.ITEM_NUMBER IS NULL
      AND MSII.SET_PROCESS_ID = p_data_set_id
      AND MSII.PROCESS_FLAG = 0
      AND MSII.CONFIRM_STATUS = 'CNR'
      AND MSII.ORGANIZATION_ID = l_org_id
      AND 'S' = ( SELECT MAX( ICC.ITEM_NUM_GEN_METHOD ) KEEP (DENSE_RANK FIRST ORDER BY LEVEL)
                  FROM MTL_ITEM_CATALOG_GROUPS_B ICC
                  WHERE ICC.ITEM_NUM_GEN_METHOD IS NOT NULL
                    AND ICC.ITEM_NUM_GEN_METHOD <> 'I'
                  CONNECT BY PRIOR ICC.PARENT_CATALOG_GROUP_ID = ICC.ITEM_CATALOG_GROUP_ID
                    START WITH ICC.ITEM_CATALOG_GROUP_ID = MSII.ITEM_CATALOG_GROUP_ID
                );

    Debug_Conc_Log('Resolve_Child_Entities - After updating Sequence Generated Item Numbers' );
    */
    -- update all records with confirm_status='CC', 'CM' to ready, where conditions are satisfied
    UPDATE
      MTL_SYSTEM_ITEMS_INTERFACE MSII
      SET CONFIRM_STATUS = (
      CASE
        WHEN
          (NVL(MSII.REVISION_IMPORT_POLICY, l_import_policy) = 'N' AND
            1 <> (SELECT COUNT(*)
                  FROM MTL_ITEM_REVISIONS_INTERFACE MIRI
                  WHERE MIRI.SET_PROCESS_ID = MSII.SET_PROCESS_ID
                    AND MIRI.PROCESS_FLAG = 0
                    AND MIRI.SOURCE_SYSTEM_ID = MSII.SOURCE_SYSTEM_ID
                    AND MIRI.SOURCE_SYSTEM_REFERENCE = MSII.SOURCE_SYSTEM_REFERENCE
                    AND MIRI.ORGANIZATION_ID = MSII.ORGANIZATION_ID
                    AND MIRI.REVISION IS NOT NULL
                    AND MIRI.EFFECTIVITY_DATE IS NOT NULL
                    AND UPPER(MIRI.TRANSACTION_TYPE) = 'CREATE'))
        THEN CONFIRM_STATUS
        ELSE CONFIRM_STATUS||'R'
      END
      )
    WHERE MSII.SET_PROCESS_ID = p_data_set_id
      AND MSII.PROCESS_FLAG = 0
      AND MSII.ORGANIZATION_ID = l_org_id
      AND MSII.CONFIRM_STATUS IN ('CC', 'CM');

    UPDATE
      MTL_SYSTEM_ITEMS_INTERFACE MSII
      SET CONFIRM_STATUS = (
      CASE
        WHEN ( NVL(MSII.REVISION_IMPORT_POLICY, l_import_policy) = 'N' AND
               1 <> (SELECT COUNT(*)
                  FROM MTL_ITEM_REVISIONS_INTERFACE MIRI
                  WHERE MIRI.SET_PROCESS_ID = MSII.SET_PROCESS_ID
                    AND MIRI.PROCESS_FLAG = 0
                    AND MIRI.SOURCE_SYSTEM_ID = MSII.SOURCE_SYSTEM_ID
                    AND MIRI.SOURCE_SYSTEM_REFERENCE = MSII.SOURCE_SYSTEM_REFERENCE
                    AND MIRI.ORGANIZATION_ID = MSII.ORGANIZATION_ID
                    AND MIRI.REVISION IS NOT NULL
                    AND MIRI.EFFECTIVITY_DATE IS NOT NULL
                    AND UPPER(MIRI.TRANSACTION_TYPE) = G_TRANS_TYPE_CREATE )
             )
        THEN CONFIRM_STATUS
        ELSE G_FAKE_MATCH_READY
      END
      )
    WHERE MSII.SET_PROCESS_ID = p_data_set_id
      AND MSII.PROCESS_FLAG = 0
      AND MSII.ORGANIZATION_ID = l_org_id
      AND MSII.CONFIRM_STATUS IN ( G_CONF_MATCH_FAKE, G_CONF_XREF_FAKE );

    Debug_Conc_Log('Resolve_Child_Entities - After updating confirm status to CMR or CCR' );

    IF l_security_predicate IS NOT NULL THEN
      Debug_Conc_Log('Resolve_Child_Entities - Need to check privilege' );
      -- For the confirmed new case, if there exists an active cross reference which you cannot break
       -- update process_flag to 33391
      l_sql := q'#
        UPDATE MTL_SYSTEM_ITEMS_INTERFACE MSII
        SET PROCESS_FLAG = 33391
        WHERE SET_PROCESS_ID = :p_data_set_id
          AND PROCESS_FLAG = 0
          AND ORGANIZATION_ID = :org_id
          AND CONFIRM_status = 'CNR'
          AND EXISTS ( SELECT 1 FROM MTL_CROSS_REFERENCES_B APPLYSEC
                       WHERE APPLYSEC.CROSS_REFERENCE = MSII.SOURCE_SYSTEM_REFERENCE
                         AND APPLYSEC.SOURCE_SYSTEM_ID = MSII.SOURCE_SYSTEM_ID
                         AND APPLYSEC.CROSS_REFERENCE_TYPE = 'SS_ITEM_XREF'
                         AND SYSDATE BETWEEN NVL(APPLYSEC.START_DATE_ACTIVE, SYSDATE-1) AND NVL(APPLYSEC.END_DATE_ACTIVE, SYSDATE + 1)
                         AND NOT #' || l_security_predicate || ' )';

      EXECUTE IMMEDIATE l_sql USING p_data_set_id, l_org_id;

      Debug_Conc_Log('Resolve_Child_Entities - After checking for CNR' );
      --  CC/CM:
      --   old link and new link are the same:
      l_sql := q'#
          UPDATE MTL_SYSTEM_ITEMS_INTERFACE MSII
          SET PROCESS_FLAG = 33390
          WHERE SET_PROCESS_ID = :p_data_set_id
            AND PROCESS_FLAG = 0
            AND ORGANIZATION_ID = :org_id
            AND CONFIRM_STATUS IN ('CCR', 'CMR', 'FMR' )
            AND EXISTS
                    (SELECT 1
                     FROM MTL_CROSS_REFERENCES_VL APPLYSEC
                     WHERE APPLYSEC.CROSS_REFERENCE = MSII.SOURCE_SYSTEM_REFERENCE
                       AND APPLYSEC.SOURCE_SYSTEM_ID = MSII.SOURCE_SYSTEM_ID
                       AND APPLYSEC.CROSS_REFERENCE_TYPE = 'SS_ITEM_XREF'
                       AND APPLYSEC.INVENTORY_ITEM_ID = MSII.INVENTORY_ITEM_ID
                       AND (APPLYSEC.DESCRIPTION <> MSII.SOURCE_SYSTEM_REFERENCE_DESC OR
                           (APPLYSEC.DESCRIPTION IS NULL AND MSII.SOURCE_SYSTEM_REFERENCE_DESC IS NOT NULL))
                       AND SYSDATE BETWEEN  NVL(APPLYSEC.START_DATE_ACTIVE, SYSDATE-1) AND NVL(APPLYSEC.END_DATE_ACTIVE, SYSDATE + 1)
                       AND NOT #' || l_security_predicate || ' )';

        EXECUTE IMMEDIATE l_sql USING p_data_set_id, l_org_id;

        Debug_Conc_Log( 'Resolve_Child_Entities - After checking security on the link where old link and new link are the same and
                         source system reference desc is being updated' );
        --  old link and new link are not the same:
        --     check edit privilege on old item link (if any)
        l_sql := q'#
          UPDATE MTL_SYSTEM_ITEMS_INTERFACE MSII
          SET PROCESS_FLAG = 33391
          WHERE SET_PROCESS_ID = :p_data_set_id
            AND PROCESS_FLAG = 0
            AND ORGANIZATION_ID = :org_id
            AND CONFIRM_STATUS IN ( 'CCR', 'CMR', 'FMR' )
            AND EXISTS ( SELECT 1
                         FROM MTL_CROSS_REFERENCES_B APPLYSEC
                         WHERE APPLYSEC.CROSS_REFERENCE = MSII.SOURCE_SYSTEM_REFERENCE
                           AND APPLYSEC.SOURCE_SYSTEM_ID = MSII.SOURCE_SYSTEM_ID
                           AND APPLYSEC.CROSS_REFERENCE_TYPE = 'SS_ITEM_XREF'
                           AND APPLYSEC.INVENTORY_ITEM_ID <> MSII.INVENTORY_ITEM_ID
                           AND SYSDATE BETWEEN  NVL(APPLYSEC.START_DATE_ACTIVE, SYSDATE-1) AND NVL(APPLYSEC.END_DATE_ACTIVE, SYSDATE + 1)
                           AND NOT #' || l_security_predicate || ' )';

        EXECUTE IMMEDIATE l_sql USING p_data_set_id, l_org_id;

        Debug_Conc_Log( 'Resolve_Child_Entities - After checking security on old item link (if any) where old link and new link are not the same' );

        --  old link and new link are not the same:
        --     check edit privilege on new item link
        l_sql := q'#
          UPDATE MTL_SYSTEM_ITEMS_INTERFACE APPLYSEC
          SET PROCESS_FLAG = 33390
          WHERE SET_PROCESS_ID = :p_data_set_id
            AND PROCESS_FLAG = 0
            AND ORGANIZATION_ID = :org_id
            AND CONFIRM_STATUS IN ( 'CCR', 'CMR', 'FMR' )
            AND NOT #' || l_security_predicate  || q'#
            AND APPLYSEC.INVENTORY_ITEM_ID IS NOT NULL
            AND LNNVL (APPLYSEC.INVENTORY_ITEM_ID =
                            (SELECT XREF.INVENTORY_ITEM_ID
                             FROM MTL_CROSS_REFERENCES_B XREF
                             WHERE XREF.CROSS_REFERENCE = APPLYSEC.SOURCE_SYSTEM_REFERENCE
                               AND XREF.SOURCE_SYSTEM_ID = APPLYSEC.SOURCE_SYSTEM_ID
                               AND XREF.CROSS_REFERENCE_TYPE = 'SS_ITEM_XREF'
                               AND SYSDATE BETWEEN NVL(XREF.START_DATE_ACTIVE, SYSDATE-1) AND NVL(XREF.END_DATE_ACTIVE, SYSDATE + 1))) #';

        EXECUTE IMMEDIATE l_sql USING p_data_set_id, l_org_id;

        Debug_Conc_Log( 'Resolve_Child_Entities - After checking security on new item link where old link and new link are not the same' );

        Debug_Conc_Log( 'Resolve_Child_Entities - After updating records without privilege to status 33390' );

      FOR i IN c_no_privilege_rows LOOP
        FND_MESSAGE.SET_NAME('EGO', 'EGO_NO_EDIT_XREF_PRIV');
        FND_MESSAGE.SET_TOKEN('ITEM', i.ITEM_NUMBER);
        FND_MESSAGE.SET_TOKEN('ORG', i.ORGANIZATION_CODE);
        l_msg_text := FND_MESSAGE.GET;



        dumm_status  := INVPUOPI.mtl_log_interface_err(
                              i.ORGANIZATION_ID
                             ,l_user_id
                             ,l_login_id
                             ,l_prog_appid
                             ,l_prog_id
                             ,l_request_id
                             ,i.TRANSACTION_ID
                             ,l_msg_text
                             ,'SOURCE_SYSTEM_REFERENCE'
                             ,'MTL_SYSTEM_ITEMS_INTERFACE'
                             ,'INV_IOI_ERR'
                             ,l_err_text);
      END LOOP;

      FOR i IN c_old_xref_no_priv_row LOOP
        FND_MESSAGE.SET_NAME('EGO', 'EGO_NO_EDIT_XREF_PRIV');
        FND_MESSAGE.SET_TOKEN('ITEM', i.ITEM_NUMBER);
        FND_MESSAGE.SET_TOKEN('ORG', i.ORGANIZATION_CODE);
        l_msg_text := FND_MESSAGE.GET;

        dumm_status  := INVPUOPI.mtl_log_interface_err(
                        i.ORGANIZATION_ID
                       ,l_user_id
                       ,l_login_id
                       ,l_prog_appid
                       ,l_prog_id
                       ,l_request_id
                       ,i.TRANSACTION_ID
                       ,l_msg_text
                       ,'SOURCE_SYSTEM_REFERENCE'
                       ,'MTL_SYSTEM_ITEMS_INTERFACE'
                       ,'INV_IOI_ERR'
                       ,l_err_text);
      END LOOP;

      Debug_Conc_Log('Resolve_Child_Entities - After logging errors for no privilege' );
    END IF; --IF l_security_predicate IS NOT NULL THEN

    -- ELETUCHY XXX: seems wasteful to overwrite transaction type to sync rather than update, no?
    UPDATE MTL_SYSTEM_ITEMS_INTERFACE
    SET PROCESS_FLAG = 1
      , TRANSACTION_TYPE =  CASE
                            WHEN CONFIRM_STATUS = 'CNR' THEN G_TRANS_TYPE_CREATE
                            ELSE G_TRANS_TYPE_UPDATE
                            END
      -- ELETUCHY Bug 5316904: Should not attempt to change ICC from source system batch
      , ITEM_CATALOG_GROUP_ID = CASE
                                WHEN CONFIRM_STATUS = 'CNR' THEN ITEM_CATALOG_GROUP_ID
                                ELSE NULL
                                END
      , ITEM_CATALOG_GROUP_NAME =   CASE
                                    WHEN CONFIRM_STATUS = 'CNR' THEN ITEM_CATALOG_GROUP_NAME
                                    ELSE NULL
                                    END
    WHERE SET_PROCESS_ID = p_data_set_id
        AND PROCESS_FLAG = 0
        AND CONFIRM_STATUS IN ( 'CNR', 'CMR', 'CCR' )
        AND ORGANIZATION_ID = l_org_id;

    -- ELETUCHY: these fake rows will never be processed by IOI, so putting trans_type to UPDATE is reasonable
    UPDATE MTL_SYSTEM_ITEMS_INTERFACE
    SET PROCESS_FLAG     = 1,
        TRANSACTION_TYPE = G_TRANS_TYPE_UPDATE,
        CONFIRM_STATUS   = G_FAKE_CONF_STATUS_FLAG
    WHERE SET_PROCESS_ID = p_data_set_id
        AND PROCESS_FLAG = 0
        AND CONFIRM_STATUS = G_FAKE_MATCH_READY
        AND ORGANIZATION_ID = l_org_id;

    Debug_Conc_Log('Resolve_Child_Entities - Done with master item rows' );

    -- updating item_number, item_id from MSII table
    -- for child items
    UPDATE MTL_SYSTEM_ITEMS_INTERFACE MSII
    SET (PROCESS_FLAG, TRANSACTION_TYPE, INVENTORY_ITEM_ID, ITEM_NUMBER, ITEM_CATALOG_GROUP_ID, ITEM_CATALOG_GROUP_NAME, STYLE_ITEM_FLAG, STYLE_ITEM_ID ) =
        (SELECT
           1,
           (CASE
              WHEN MSII2.CONFIRM_STATUS = 'CNR'
              THEN 'CREATE'
              ELSE 'SYNC'
            END),
           MSII2.INVENTORY_ITEM_ID,
           MSII2.ITEM_NUMBER,
           MSII2.ITEM_CATALOG_GROUP_ID,
           MSII2.ITEM_CATALOG_GROUP_NAME,
           NVL(MSII.STYLE_ITEM_FLAG, MSII2.STYLE_ITEM_FLAG),
           NVL(MSII.STYLE_ITEM_ID, MSII2.STYLE_ITEM_ID)
         FROM MTL_SYSTEM_ITEMS_INTERFACE MSII2
         WHERE MSII2.SET_PROCESS_ID = p_data_set_id
           AND MSII2.PROCESS_FLAG = 1
           AND MSII2.SOURCE_SYSTEM_ID = MSII.SOURCE_SYSTEM_ID
           AND MSII2.SOURCE_SYSTEM_REFERENCE = MSII.SOURCE_SYSTEM_REFERENCE
           AND MSII2.CONFIRM_STATUS IN ( 'CNR', 'CMR', 'CCR', G_FAKE_CONF_STATUS_FLAG )
           AND MSII2.ORGANIZATION_ID = l_org_id
           AND ROWNUM = 1
        )
    WHERE MSII.PROCESS_FLAG = 0
      AND MSII.CONFIRM_STATUS IS NULL
      AND MSII.SET_PROCESS_ID = p_data_set_id
      AND EXISTS (SELECT NULL FROM MTL_PARAMETERS mp
                  WHERE mp.ORGANIZATION_ID = MSII.ORGANIZATION_ID
                    AND mp.MASTER_ORGANIZATION_ID = l_org_id
                    AND mp.MASTER_ORGANIZATION_ID <> mp.ORGANIZATION_ID
                 )
      AND EXISTS (SELECT NULL
                  FROM MTL_SYSTEM_ITEMS_INTERFACE MSII2
                  WHERE MSII2.SET_PROCESS_ID = p_data_set_id
                    AND MSII2.PROCESS_FLAG = 1
                    AND MSII2.CONFIRM_STATUS IN ( 'CNR', 'CMR', 'CCR', G_FAKE_CONF_STATUS_FLAG )
                    AND MSII2.SOURCE_SYSTEM_ID = MSII.SOURCE_SYSTEM_ID
                    AND MSII2.SOURCE_SYSTEM_REFERENCE = MSII.SOURCE_SYSTEM_REFERENCE
                    AND MSII2.ORGANIZATION_ID = l_org_id);

    Debug_Conc_Log('Resolve_Child_Entities - After resolving child items' );

    -- updating item_number, item_id from MSII table
    UPDATE MTL_ITEM_REVISIONS_INTERFACE MIRI
    SET (PROCESS_FLAG, TRANSACTION_TYPE, INVENTORY_ITEM_ID, ITEM_NUMBER) =
        (SELECT
           1,
           (CASE
              WHEN MSII.CONFIRM_STATUS = 'CNR'
              THEN 'CREATE'
              WHEN MIRI.TRANSACTION_TYPE <> 'SYNC'
              THEN MIRI.TRANSACTION_TYPE
              WHEN EXISTS (SELECT 1
                            FROM MTL_ITEM_REVISIONS_B MIR
                            WHERE MIR.INVENTORY_ITEM_ID = MSII.INVENTORY_ITEM_ID
                            AND MIR.ORGANIZATION_ID = MIRI.ORGANIZATION_ID
                            AND MIR.REVISION = MIRI.REVISION)
              THEN 'UPDATE'
              ELSE 'CREATE'
            END),
           MSII.INVENTORY_ITEM_ID,
           MSII.ITEM_NUMBER
         FROM MTL_SYSTEM_ITEMS_INTERFACE MSII
         WHERE MSII.SET_PROCESS_ID = p_data_set_id
           AND MSII.PROCESS_FLAG = 1
           AND MSII.CONFIRM_STATUS IN ('CNR', 'CMR', 'CCR', G_FAKE_CONF_STATUS_FLAG )
           AND MSII.SOURCE_SYSTEM_ID = MIRI.SOURCE_SYSTEM_ID
           AND MSII.SOURCE_SYSTEM_REFERENCE = MIRI.SOURCE_SYSTEM_REFERENCE
           AND MSII.ORGANIZATION_ID = l_org_id
           AND ROWNUM = 1
        )
    WHERE MIRI.PROCESS_FLAG = 0
      AND MIRI.SET_PROCESS_ID = p_data_set_id
      AND EXISTS (SELECT NULL
                  FROM MTL_SYSTEM_ITEMS_INTERFACE MSII
                  WHERE MSII.SET_PROCESS_ID = p_data_set_id
                    AND MSII.PROCESS_FLAG = 1
                    AND MSII.CONFIRM_STATUS IN ('CNR', 'CMR', 'CCR', G_FAKE_CONF_STATUS_FLAG)
                    AND MSII.SOURCE_SYSTEM_ID = MIRI.SOURCE_SYSTEM_ID
                    AND MSII.SOURCE_SYSTEM_REFERENCE = MIRI.SOURCE_SYSTEM_REFERENCE
                    AND MSII.ORGANIZATION_ID = l_org_id);

    Debug_Conc_Log('Resolve_Child_Entities - After resolving revision rows' );
    -- updating item_number, item_id from MSII table
    UPDATE MTL_ITEM_CATEGORIES_INTERFACE MICI
    SET (PROCESS_FLAG, TRANSACTION_TYPE, INVENTORY_ITEM_ID, ITEM_NUMBER) =
        (SELECT
           1,
           (CASE
              WHEN MSII.CONFIRM_STATUS = 'CNR'
              THEN 'CREATE'
              ELSE MICI.TRANSACTION_TYPE
            END),
           MSII.INVENTORY_ITEM_ID,
           MSII.ITEM_NUMBER
         FROM MTL_SYSTEM_ITEMS_INTERFACE MSII
         WHERE MSII.SET_PROCESS_ID = p_data_set_id
           AND MSII.PROCESS_FLAG = 1
           AND MSII.CONFIRM_STATUS IN ('CNR', 'CMR', 'CCR', G_FAKE_CONF_STATUS_FLAG)
           AND MSII.SOURCE_SYSTEM_ID = MICI.SOURCE_SYSTEM_ID
           AND MSII.SOURCE_SYSTEM_REFERENCE = MICI.SOURCE_SYSTEM_REFERENCE
           AND MSII.ORGANIZATION_ID = l_org_id
           AND ROWNUM = 1
        )
    WHERE MICI.PROCESS_FLAG = 0
      AND MICI.SET_PROCESS_ID = p_data_set_id
      AND EXISTS (SELECT NULL
                  FROM MTL_SYSTEM_ITEMS_INTERFACE MSII
                  WHERE MSII.SET_PROCESS_ID = p_data_set_id
                    AND MSII.PROCESS_FLAG = 1
                    AND MSII.CONFIRM_STATUS IN ('CNR', 'CMR', 'CCR', G_FAKE_CONF_STATUS_FLAG)
                    AND MSII.SOURCE_SYSTEM_ID = MICI.SOURCE_SYSTEM_ID
                    AND MSII.SOURCE_SYSTEM_REFERENCE = MICI.SOURCE_SYSTEM_REFERENCE
                    AND MSII.ORGANIZATION_ID = l_org_id);

    Debug_Conc_Log('Resolve_Child_Entities - After resolving categories rows' );
    -- updating item_number, item_id from MSII table
    UPDATE EGO_ITM_USR_ATTR_INTRFC ATTRS
    SET (PROCESS_STATUS, TRANSACTION_TYPE, INVENTORY_ITEM_ID, ITEM_NUMBER, ITEM_CATALOG_GROUP_ID) =
        (SELECT
           1,
           (CASE
              WHEN UPPER(ATTRS.TRANSACTION_TYPE) = G_TRANS_TYPE_DELETE THEN G_TRANS_TYPE_DELETE
              WHEN MSII.CONFIRM_STATUS = 'CNR' THEN G_TRANS_TYPE_CREATE
              ELSE G_TRANS_TYPE_SYNC
            END),
           MSII.INVENTORY_ITEM_ID,
           MSII.ITEM_NUMBER,
           NVL(ATTRS.ITEM_CATALOG_GROUP_ID, MSII.ITEM_CATALOG_GROUP_ID)
         FROM MTL_SYSTEM_ITEMS_INTERFACE MSII
         WHERE MSII.SET_PROCESS_ID = p_data_set_id
           AND MSII.PROCESS_FLAG = 1
           AND MSII.CONFIRM_STATUS IN ('CNR', 'CMR', 'CCR', G_FAKE_CONF_STATUS_FLAG)
           AND MSII.SOURCE_SYSTEM_ID = ATTRS.SOURCE_SYSTEM_ID
           AND MSII.SOURCE_SYSTEM_REFERENCE = ATTRS.SOURCE_SYSTEM_REFERENCE
           AND MSII.ORGANIZATION_ID = l_org_id
           AND ROWNUM = 1
        )
    WHERE ATTRS.PROCESS_STATUS = 0
      AND ATTRS.DATA_SET_ID = p_data_set_id
      AND EXISTS (SELECT NULL
                  FROM MTL_SYSTEM_ITEMS_INTERFACE MSII
                  WHERE MSII.SET_PROCESS_ID = p_data_set_id
                    AND MSII.PROCESS_FLAG = 1
                    AND MSII.CONFIRM_STATUS IN ('CNR', 'CMR', 'CCR', G_FAKE_CONF_STATUS_FLAG)
                    AND MSII.SOURCE_SYSTEM_ID = ATTRS.SOURCE_SYSTEM_ID
                    AND MSII.SOURCE_SYSTEM_REFERENCE = ATTRS.SOURCE_SYSTEM_REFERENCE
                    AND MSII.ORGANIZATION_ID = l_org_id);

    Debug_Conc_Log('Resolve_Child_Entities - After resolving user defined attrs rows' );

    UPDATE EGO_ITM_USR_ATTR_INTRFC ATTRS
      SET REVISION = (
      CASE (SELECT
              CASE
                WHEN MSII.CONFIRM_STATUS IN ('CMR', 'CCR', G_FAKE_CONF_STATUS_FLAG )
                     AND (MSII.REVISION_IMPORT_POLICY = 'L' OR (MSII.REVISION_IMPORT_POLICY IS NULL AND l_import_policy = 'L'))
                THEN '1'
                WHEN MSII.CONFIRM_STATUS IN ('CMR', 'CCR', G_FAKE_CONF_STATUS_FLAG )
                     AND (MSII.REVISION_IMPORT_POLICY = 'N' OR (MSII.REVISION_IMPORT_POLICY IS NULL AND l_import_policy = 'N'))
                THEN '2'
                WHEN MSII.CONFIRM_STATUS = 'CNR'
                THEN '3'
              END
            FROM MTL_SYSTEM_ITEMS_INTERFACE MSII
            WHERE MSII.SET_PROCESS_ID = p_data_set_id
              AND MSII.PROCESS_FLAG = 1
              AND MSII.CONFIRM_STATUS IN ( 'CNR', 'CMR', 'CCR', G_FAKE_CONF_STATUS_FLAG )
              AND MSII.SOURCE_SYSTEM_ID = ATTRS.SOURCE_SYSTEM_ID
              AND MSII.SOURCE_SYSTEM_REFERENCE = ATTRS.SOURCE_SYSTEM_REFERENCE
              AND MSII.ORGANIZATION_ID = l_org_id
           )
        WHEN '1'
        THEN (SELECT MAX(REVISION) KEEP (DENSE_RANK FIRST ORDER BY EFFECTIVITY_DATE DESC)
              FROM MTL_ITEM_REVISIONS_B
              WHERE INVENTORY_ITEM_ID = ATTRS.INVENTORY_ITEM_ID
                AND ORGANIZATION_ID = ATTRS.ORGANIZATION_ID)
        WHEN '2'
        THEN (SELECT REVISION
              FROM MTL_ITEM_REVISIONS_INTERFACE MIRI
              WHERE MIRI.SET_PROCESS_ID = ATTRS.DATA_SET_ID
                AND MIRI.SOURCE_SYSTEM_ID = ATTRS.SOURCE_SYSTEM_ID
                AND MIRI.SOURCE_SYSTEM_REFERENCE = ATTRS.SOURCE_SYSTEM_REFERENCE
                AND MIRI.ORGANIZATION_ID = ATTRS.ORGANIZATION_ID
                AND MIRI.REVISION IS NOT NULL
                AND MIRI.EFFECTIVITY_DATE IS NOT NULL
                AND UPPER(MIRI.TRANSACTION_TYPE) = 'CREATE'
                AND ROWNUM = 1
             )
        WHEN '3'
        THEN (SELECT STARTING_REVISION
              FROM MTL_PARAMETERS
              WHERE ORGANIZATION_ID = ATTRS.ORGANIZATION_ID
             )
      END)
    WHERE ATTRS.PROCESS_STATUS = 1
      AND ATTRS.DATA_SET_ID = p_data_set_id
      AND ATTRS.REVISION IS NULL
      AND EXISTS (SELECT NULL
                  FROM MTL_SYSTEM_ITEMS_INTERFACE MSII
                  WHERE MSII.SET_PROCESS_ID = p_data_set_id
                    AND MSII.PROCESS_FLAG = 1
                    AND MSII.CONFIRM_STATUS IN ( 'CNR', 'CMR', 'CCR', G_FAKE_CONF_STATUS_FLAG )
                    AND MSII.SOURCE_SYSTEM_ID = ATTRS.SOURCE_SYSTEM_ID
                    AND MSII.SOURCE_SYSTEM_REFERENCE = ATTRS.SOURCE_SYSTEM_REFERENCE
                    AND MSII.ORGANIZATION_ID = l_org_id)
      AND EXISTS (SELECT NULL
                  FROM EGO_OBJ_AG_ASSOCS_B A, EGO_FND_DSC_FLX_CTX_EXT EXT
                  WHERE A.ATTR_GROUP_ID = EXT.ATTR_GROUP_ID
                    AND A.OBJECT_ID = (SELECT OBJECT_ID FROM FND_OBJECTS WHERE OBJ_NAME = 'EGO_ITEM')
                    AND EXT.DESCRIPTIVE_FLEX_CONTEXT_CODE = ATTRS.ATTR_GROUP_INT_NAME
                    AND EXT.DESCRIPTIVE_FLEXFIELD_NAME = NVL(ATTRS.ATTR_GROUP_TYPE, 'EGO_ITEMMGMT_GROUP')
                    AND EXT.APPLICATION_ID = 431
                    AND A.DATA_LEVEL = 'ITEM_REVISION_LEVEL');

    Debug_Conc_Log('Resolve_Child_Entities - After resolving user attrs intf table for revision' );
    UPDATE MTL_ITEM_REVISIONS_INTERFACE MIRI
      SET (REVISION, TRANSACTION_TYPE) =
          (SELECT
              (CASE
                WHEN (EXISTS (SELECT NULL
                              FROM MTL_SYSTEM_ITEMS_INTERFACE MSII
                              WHERE MSII.SET_PROCESS_ID = p_data_set_id
                                AND MSII.PROCESS_FLAG = 1
                                AND MSII.CONFIRM_STATUS IN ('CMR', 'CCR', G_FAKE_CONF_STATUS_FLAG )
                                AND (MSII.REVISION_IMPORT_POLICY = 'L' OR (MSII.REVISION_IMPORT_POLICY IS NULL AND l_import_policy = 'L'))
                                AND MSII.SOURCE_SYSTEM_ID = MIRI.SOURCE_SYSTEM_ID
                                AND MSII.SOURCE_SYSTEM_REFERENCE = MIRI.SOURCE_SYSTEM_REFERENCE
                                AND MSII.ORGANIZATION_ID = l_org_id)
                     )
                THEN (SELECT MAX(REVISION) KEEP (DENSE_RANK FIRST ORDER BY EFFECTIVITY_DATE DESC)
                      FROM MTL_ITEM_REVISIONS_B
                      WHERE INVENTORY_ITEM_ID = MIRI.INVENTORY_ITEM_ID
                        AND ORGANIZATION_ID = MIRI.ORGANIZATION_ID)
                WHEN (EXISTS (SELECT NULL
                              FROM MTL_SYSTEM_ITEMS_INTERFACE MSII
                              WHERE MSII.SET_PROCESS_ID = p_data_set_id
                                AND MSII.PROCESS_FLAG = 1
                                AND MSII.CONFIRM_STATUS = 'CNR'
                                AND MSII.SOURCE_SYSTEM_ID = MIRI.SOURCE_SYSTEM_ID
                                AND MSII.SOURCE_SYSTEM_REFERENCE = MIRI.SOURCE_SYSTEM_REFERENCE
                                AND MSII.ORGANIZATION_ID = l_org_id)
                     )
                THEN (SELECT STARTING_REVISION
                      FROM MTL_PARAMETERS
                      WHERE ORGANIZATION_ID = MIRI.ORGANIZATION_ID
                     )
              END)   AS REVISION,
              'SYNC' AS TRANSACTION_TYPE
          FROM DUAL)
    WHERE MIRI.PROCESS_FLAG = 1
      AND MIRI.SET_PROCESS_ID = p_data_set_id
      AND MIRI.REVISION IS NULL
      AND EXISTS (SELECT NULL
                  FROM MTL_SYSTEM_ITEMS_INTERFACE MSII
                  WHERE MSII.SET_PROCESS_ID = p_data_set_id
                    AND MSII.PROCESS_FLAG = 1
                    AND MSII.CONFIRM_STATUS IN ('CNR', 'CMR', 'CCR', G_FAKE_CONF_STATUS_FLAG )
                    AND MSII.SOURCE_SYSTEM_ID = MIRI.SOURCE_SYSTEM_ID
                    AND MSII.SOURCE_SYSTEM_REFERENCE = MIRI.SOURCE_SYSTEM_REFERENCE
                    AND MSII.ORGANIZATION_ID = l_org_id);

    Debug_Conc_Log('Resolve_Child_Entities - After resolving item revisions interface table for revision' );
    -- updating item_number, item_id from MSII table
    UPDATE EGO_ITEM_PEOPLE_INTF EIPI
    SET (PROCESS_STATUS, TRANSACTION_TYPE, INVENTORY_ITEM_ID, ITEM_NUMBER) =
        (SELECT
           1,
           (CASE
              WHEN MSII.CONFIRM_STATUS = 'CNR'
              THEN 'CREATE'
              ELSE 'SYNC'
            END),
           MSII.INVENTORY_ITEM_ID,
           MSII.ITEM_NUMBER
         FROM MTL_SYSTEM_ITEMS_INTERFACE MSII
         WHERE MSII.SET_PROCESS_ID = p_data_set_id
           AND MSII.PROCESS_FLAG = 1
           AND MSII.CONFIRM_STATUS IN ('CNR', 'CMR', 'CCR', G_FAKE_CONF_STATUS_FLAG )
           AND MSII.SOURCE_SYSTEM_ID = EIPI.SOURCE_SYSTEM_ID
           AND MSII.SOURCE_SYSTEM_REFERENCE = EIPI.SOURCE_SYSTEM_REFERENCE
           AND MSII.ORGANIZATION_ID = l_org_id
           AND ROWNUM = 1
        )
    WHERE EIPI.PROCESS_STATUS = 0
      AND EIPI.DATA_SET_ID = p_data_set_id
      AND EXISTS (SELECT NULL
                  FROM MTL_SYSTEM_ITEMS_INTERFACE MSII
                  WHERE MSII.SET_PROCESS_ID = p_data_set_id
                    AND MSII.PROCESS_FLAG = 1
                    AND MSII.CONFIRM_STATUS IN ('CNR', 'CMR', 'CCR', G_FAKE_CONF_STATUS_FLAG)
                    AND MSII.SOURCE_SYSTEM_ID = EIPI.SOURCE_SYSTEM_ID
                    AND MSII.SOURCE_SYSTEM_REFERENCE = EIPI.SOURCE_SYSTEM_REFERENCE
                    AND MSII.ORGANIZATION_ID = l_org_id);

    Debug_Conc_Log('Resolve_Child_Entities - After resolving item people rows' );
    -- updating item_number, item_id from MSII table
    UPDATE EGO_AML_INTF EAI
    SET (PROCESS_FLAG, TRANSACTION_TYPE, INVENTORY_ITEM_ID, ITEM_NUMBER) =
        (SELECT
           1,
           (CASE
              WHEN UPPER(EAI.TRANSACTION_TYPE) = G_TRANS_TYPE_DELETE THEN G_TRANS_TYPE_DELETE
              WHEN MSII.CONFIRM_STATUS = 'CNR' THEN G_TRANS_TYPE_CREATE
              ELSE G_TRANS_TYPE_SYNC
            END),
           MSII.INVENTORY_ITEM_ID,
           MSII.ITEM_NUMBER
         FROM MTL_SYSTEM_ITEMS_INTERFACE MSII
         WHERE MSII.SET_PROCESS_ID = p_data_set_id
           AND MSII.PROCESS_FLAG = 1
           AND MSII.CONFIRM_STATUS IN ( 'CNR', 'CMR', 'CCR', G_FAKE_CONF_STATUS_FLAG )
           AND MSII.SOURCE_SYSTEM_ID = EAI.SOURCE_SYSTEM_ID
           AND MSII.SOURCE_SYSTEM_REFERENCE = EAI.SOURCE_SYSTEM_REFERENCE
           AND MSII.ORGANIZATION_ID = l_org_id
           AND ROWNUM = 1
        )
    WHERE EAI.PROCESS_FLAG = 0
      AND EAI.DATA_SET_ID = p_data_set_id
      AND EXISTS (SELECT NULL
                  FROM MTL_SYSTEM_ITEMS_INTERFACE MSII
                  WHERE MSII.SET_PROCESS_ID = p_data_set_id
                    AND MSII.PROCESS_FLAG = 1
                    AND MSII.CONFIRM_STATUS IN ('CNR', 'CMR', 'CCR', G_FAKE_CONF_STATUS_FLAG)
                    AND MSII.SOURCE_SYSTEM_ID = EAI.SOURCE_SYSTEM_ID
                    AND MSII.SOURCE_SYSTEM_REFERENCE = EAI.SOURCE_SYSTEM_REFERENCE
                    AND MSII.ORGANIZATION_ID = l_org_id);

    Debug_Conc_Log( 'Resolve_Child_Entities - After resolving aml rows' );

    -- updating item_number, item_id from MSII table
    UPDATE EGO_ITEM_ASSOCIATIONS_INTF EIAI
    SET (PROCESS_FLAG, TRANSACTION_TYPE, INVENTORY_ITEM_ID, ITEM_NUMBER) =
        (SELECT
           1,
           (CASE
              WHEN MSII.CONFIRM_STATUS = 'CNR'
              THEN 'CREATE'
              ELSE EIAI.TRANSACTION_TYPE
            END),
           MSII.INVENTORY_ITEM_ID,
           MSII.ITEM_NUMBER
         FROM MTL_SYSTEM_ITEMS_INTERFACE MSII
         WHERE MSII.SET_PROCESS_ID = p_data_set_id
           AND MSII.PROCESS_FLAG = 1
           AND MSII.CONFIRM_STATUS IN ('CNR', 'CMR', 'CCR', G_FAKE_CONF_STATUS_FLAG)
           AND MSII.SOURCE_SYSTEM_ID = EIAI.SOURCE_SYSTEM_ID
           AND MSII.SOURCE_SYSTEM_REFERENCE = EIAI.SOURCE_SYSTEM_REFERENCE
           AND MSII.ORGANIZATION_ID = l_org_id
           AND ROWNUM = 1
        )
    WHERE EIAI.PROCESS_FLAG = 0
      AND EIAI.BATCH_ID = p_data_set_id
      AND EXISTS (SELECT NULL
                  FROM MTL_SYSTEM_ITEMS_INTERFACE MSII
                  WHERE MSII.SET_PROCESS_ID = p_data_set_id
                    AND MSII.PROCESS_FLAG = 1
                    AND MSII.CONFIRM_STATUS IN ('CNR', 'CMR', 'CCR', G_FAKE_CONF_STATUS_FLAG)
                    AND MSII.SOURCE_SYSTEM_ID = EIAI.SOURCE_SYSTEM_ID
                    AND MSII.SOURCE_SYSTEM_REFERENCE = EIAI.SOURCE_SYSTEM_REFERENCE
                    AND MSII.ORGANIZATION_ID = l_org_id);

    Debug_Conc_Log('Resolve_Child_Entities - After resolving intersection rows' );
    -- getting security predicate
    EGO_DATA_SECURITY.get_security_predicate(
      p_api_version      => 1.0
     ,p_function         => 'EGO_VIEW_SS_ITEM_XREFS'
     ,p_object_name      => 'EGO_ITEM'
     ,p_user_name        => l_party_name
     ,p_statement_type   => 'EXISTS'
     ,p_pk1_alias        => 'MCR.INVENTORY_ITEM_ID'
     ,p_pk2_alias        => l_org_id
     ,x_predicate        => l_security_predicate
     ,x_return_status    => l_return_status
    );

    IF l_security_predicate IS NULL THEN
      l_security_predicate := ' AND 1=1 ';
    ELSE
      l_security_predicate := ' AND '||l_security_predicate;
    END IF;

    Debug_Conc_Log('Resolve_Child_Entities - Security Predicate - '||l_security_predicate);

    -- updating all the child entities, which do not have parent in mtl_system_items_interface
    -- updating the items and org assignments

    -- Note that using q'# is a new feature of 10g. By using this syntax, we can put as many single quotes within
    -- the string. for example q'# This is Devendra's code #'
    l_sql := q'#
               UPDATE MTL_SYSTEM_ITEMS_INTERFACE MSII
                 SET (PROCESS_FLAG, TRANSACTION_TYPE, INVENTORY_ITEM_ID) =
                     (SELECT
                        1,
                        NVL(MSII.TRANSACTION_TYPE, 'SYNC'),
                        MCR.INVENTORY_ITEM_ID
                      FROM MTL_CROSS_REFERENCES_B MCR
                      WHERE MCR.CROSS_REFERENCE_TYPE = 'SS_ITEM_XREF'
                        AND MCR.CROSS_REFERENCE = MSII.SOURCE_SYSTEM_REFERENCE
                        AND MCR.SOURCE_SYSTEM_ID = MSII.SOURCE_SYSTEM_ID
                        AND SYSDATE BETWEEN NVL(MCR.START_DATE_ACTIVE, SYSDATE - 1) AND NVL(MCR.END_DATE_ACTIVE, SYSDATE + 1)
                        AND ROWNUM = 1
                     )
               WHERE MSII.SET_PROCESS_ID = :p_data_set_id
                 AND MSII.PROCESS_FLAG = 0
                 -- PICK ONLY CHILD ITEMS
                 AND EXISTS (SELECT NULL
                             FROM MTL_PARAMETERS MP
                             WHERE MP.MASTER_ORGANIZATION_ID = :l_org_id
                               AND MP.ORGANIZATION_ID <> MP.MASTER_ORGANIZATION_ID
                               AND MP.ORGANIZATION_ID = MSII.ORGANIZATION_ID)
                 -- CHILD MUST NOT HAVE A MASTER RECORD IN CURRENT BATCH
                 AND NOT EXISTS (SELECT NULL
                                 FROM MTL_SYSTEM_ITEMS_INTERFACE MSII2
                                 WHERE MSII2.PROCESS_FLAG in (0, 1, 33390,33391)
                                   AND MSII2.SET_PROCESS_ID = :p_data_set_id1
                                   AND MSII2.SOURCE_SYSTEM_ID = MSII.SOURCE_SYSTEM_ID
                                   AND MSII2.SOURCE_SYSTEM_REFERENCE = MSII.SOURCE_SYSTEM_REFERENCE
                                   AND MSII2.ORGANIZATION_ID = :l_org_id1
                                )
                 -- HAS A CROSS REFERENCE
                 AND EXISTS (SELECT NULL
                             FROM MTL_CROSS_REFERENCES_B MCR
                             WHERE MCR.CROSS_REFERENCE_TYPE = 'SS_ITEM_XREF'
                               AND MCR.CROSS_REFERENCE = MSII.SOURCE_SYSTEM_REFERENCE
                               AND MCR.SOURCE_SYSTEM_ID = MSII.SOURCE_SYSTEM_ID
                               AND SYSDATE BETWEEN NVL(MCR.START_DATE_ACTIVE, SYSDATE - 1) AND NVL(MCR.END_DATE_ACTIVE, SYSDATE + 1)
                             #'||l_security_predicate||')';

    EXECUTE IMMEDIATE l_sql USING p_data_set_id, l_org_id, p_data_set_id, l_org_id;

    Debug_Conc_Log('Resolve_Child_Entities - After updating items intf table for child items that has XXref' );

    -- updating the item revisions
    l_sql := q'#
               UPDATE MTL_ITEM_REVISIONS_INTERFACE MIRI
                 SET (PROCESS_FLAG, TRANSACTION_TYPE, INVENTORY_ITEM_ID) =
                     (SELECT
                        1,
                        NVL(MIRI.TRANSACTION_TYPE, 'SYNC'),
                        MCR.INVENTORY_ITEM_ID
                      FROM MTL_CROSS_REFERENCES_B MCR
                      WHERE MCR.CROSS_REFERENCE_TYPE = 'SS_ITEM_XREF'
                        AND MCR.CROSS_REFERENCE = MIRI.SOURCE_SYSTEM_REFERENCE
                        AND MCR.SOURCE_SYSTEM_ID = MIRI.SOURCE_SYSTEM_ID
                        AND (MCR.START_DATE_ACTIVE < SYSDATE OR MCR.START_DATE_ACTIVE IS NULL)
                        AND (MCR.END_DATE_ACTIVE > SYSDATE OR MCR.END_DATE_ACTIVE IS NULL)
                        AND ROWNUM = 1
                     )
               WHERE MIRI.SET_PROCESS_ID = :p_data_set_id
                 AND MIRI.PROCESS_FLAG = 0
                 -- MUST NOT HAVE A MASTER ITEM RECORD IN CURRENT BATCH
                 AND NOT EXISTS (SELECT NULL
                                 FROM MTL_SYSTEM_ITEMS_INTERFACE MSII
                                 WHERE MSII.PROCESS_FLAG IN (0, 1, 33390,33391)
                                   AND MSII.SET_PROCESS_ID = :p_data_set_id1
                                   AND MSII.SOURCE_SYSTEM_ID =  MIRI.SOURCE_SYSTEM_ID
                                   AND MSII.SOURCE_SYSTEM_REFERENCE = MIRI.SOURCE_SYSTEM_REFERENCE
                                   AND MSII.ORGANIZATION_ID = :l_org_id
                                )
                 -- HAS A CROSS REFERENCE
                 AND EXISTS (SELECT NULL
                             FROM MTL_CROSS_REFERENCES_B MCR
                             WHERE MCR.CROSS_REFERENCE_TYPE = 'SS_ITEM_XREF'
                               AND MCR.CROSS_REFERENCE = MIRI.SOURCE_SYSTEM_REFERENCE
                               AND MCR.SOURCE_SYSTEM_ID = MIRI.SOURCE_SYSTEM_ID
                               AND (MCR.START_DATE_ACTIVE < SYSDATE OR MCR.START_DATE_ACTIVE IS NULL)
                               AND (MCR.END_DATE_ACTIVE > SYSDATE OR MCR.END_DATE_ACTIVE IS NULL)
                             #'||l_security_predicate||')';

    EXECUTE IMMEDIATE l_sql USING p_data_set_id, p_data_set_id, l_org_id;

    Debug_Conc_Log('Resolve_Child_Entities - After updating revisions intf table for items that has XXref' );

    -- updating the item revisions where revision is null and revision_import_policy is Update Latest
    -- Bug: 5476972
    IF l_import_policy = 'L' THEN
      l_sql := q'#
                 UPDATE MTL_ITEM_REVISIONS_INTERFACE MIRI
                   SET (REVISION, TRANSACTION_TYPE) =
                       (SELECT MAX(REVISION) KEEP (DENSE_RANK FIRST ORDER BY EFFECTIVITY_DATE DESC), 'UPDATE'
                        FROM MTL_ITEM_REVISIONS_B
                        WHERE INVENTORY_ITEM_ID = MIRI.INVENTORY_ITEM_ID
                          AND ORGANIZATION_ID = MIRI.ORGANIZATION_ID)
                 WHERE MIRI.SET_PROCESS_ID = :p_data_set_id
                   AND MIRI.PROCESS_FLAG = 1
                   AND MIRI.REVISION IS NULL
                   -- MUST NOT HAVE A MASTER ITEM RECORD IN CURRENT BATCH
                   AND NOT EXISTS (SELECT NULL
                                   FROM MTL_SYSTEM_ITEMS_INTERFACE MSII
                                   WHERE MSII.PROCESS_FLAG IN (0, 1, 33390,33391)
                                     AND MSII.SET_PROCESS_ID = :p_data_set_id1
                                     AND MSII.SOURCE_SYSTEM_ID =  MIRI.SOURCE_SYSTEM_ID
                                     AND MSII.SOURCE_SYSTEM_REFERENCE = MIRI.SOURCE_SYSTEM_REFERENCE
                                     AND MSII.ORGANIZATION_ID = :l_org_id
                                  )
                   -- HAS A CROSS REFERENCE
                   AND EXISTS (SELECT NULL
                               FROM MTL_CROSS_REFERENCES_B MCR
                               WHERE MCR.CROSS_REFERENCE_TYPE = 'SS_ITEM_XREF'
                                 AND MCR.CROSS_REFERENCE = MIRI.SOURCE_SYSTEM_REFERENCE
                                 AND MCR.SOURCE_SYSTEM_ID = MIRI.SOURCE_SYSTEM_ID
                                 AND (MCR.START_DATE_ACTIVE < SYSDATE OR MCR.START_DATE_ACTIVE IS NULL)
                                 AND (MCR.END_DATE_ACTIVE > SYSDATE OR MCR.END_DATE_ACTIVE IS NULL)
                               #'||l_security_predicate||')';

      EXECUTE IMMEDIATE l_sql USING p_data_set_id, p_data_set_id, l_org_id;

      Debug_Conc_Log('Resolve_Child_Entities - After updating REVISION in revisions intf table for items that has XXref' );
    END IF;

    -- updating the item category assignments
    l_sql := q'#
               UPDATE MTL_ITEM_CATEGORIES_INTERFACE MICI
                 SET (PROCESS_FLAG, TRANSACTION_TYPE, INVENTORY_ITEM_ID) =
                     (SELECT
                        1,
                        MICI.TRANSACTION_TYPE,
                        MCR.INVENTORY_ITEM_ID
                      FROM MTL_CROSS_REFERENCES_B MCR
                      WHERE MCR.CROSS_REFERENCE_TYPE = 'SS_ITEM_XREF'
                        AND MCR.CROSS_REFERENCE = MICI.SOURCE_SYSTEM_REFERENCE
                        AND MCR.SOURCE_SYSTEM_ID = MICI.SOURCE_SYSTEM_ID
                        AND (MCR.START_DATE_ACTIVE < SYSDATE OR MCR.START_DATE_ACTIVE IS NULL)
                        AND (MCR.END_DATE_ACTIVE > SYSDATE OR MCR.END_DATE_ACTIVE IS NULL)
                        AND ROWNUM = 1
                     )
               WHERE MICI.SET_PROCESS_ID = :p_data_set_id
                 AND MICI.PROCESS_FLAG = 0
                 -- MUST NOT HAVE A MASTER ITEM RECORD IN CURRENT BATCH
                 AND NOT EXISTS (SELECT NULL
                                 FROM MTL_SYSTEM_ITEMS_INTERFACE MSII
                                 WHERE MSII.PROCESS_FLAG IN (0, 1, 33390,33391)
                                   AND MSII.SET_PROCESS_ID = :p_data_set_id1
                                   AND MSII.SOURCE_SYSTEM_ID =  MICI.SOURCE_SYSTEM_ID
                                   AND MSII.SOURCE_SYSTEM_REFERENCE = MICI.SOURCE_SYSTEM_REFERENCE
                                   AND MSII.ORGANIZATION_ID = :l_org_id
                                )
                 -- HAS A CROSS REFERENCE
                 AND EXISTS (SELECT NULL
                             FROM MTL_CROSS_REFERENCES_B MCR
                             WHERE MCR.CROSS_REFERENCE_TYPE = 'SS_ITEM_XREF'
                               AND MCR.CROSS_REFERENCE = MICI.SOURCE_SYSTEM_REFERENCE
                               AND MCR.SOURCE_SYSTEM_ID = MICI.SOURCE_SYSTEM_ID
                               AND (MCR.START_DATE_ACTIVE < SYSDATE OR MCR.START_DATE_ACTIVE IS NULL)
                               AND (MCR.END_DATE_ACTIVE > SYSDATE OR MCR.END_DATE_ACTIVE IS NULL)
                            #'||l_security_predicate||')';

    EXECUTE IMMEDIATE l_sql USING p_data_set_id, p_data_set_id, l_org_id;

    Debug_Conc_Log('Resolve_Child_Entities - After updating categories intf table for items that has XXref');

    -- updating the item people
    l_sql := q'#
               UPDATE EGO_ITEM_PEOPLE_INTF EIPI
                 SET (PROCESS_STATUS, TRANSACTION_TYPE, INVENTORY_ITEM_ID) =
                     (SELECT
                        1,
                        NVL(EIPI.TRANSACTION_TYPE, 'SYNC'),
                        MCR.INVENTORY_ITEM_ID
                      FROM MTL_CROSS_REFERENCES_B MCR
                      WHERE MCR.CROSS_REFERENCE_TYPE = 'SS_ITEM_XREF'
                        AND MCR.CROSS_REFERENCE = EIPI.SOURCE_SYSTEM_REFERENCE
                        AND MCR.SOURCE_SYSTEM_ID = EIPI.SOURCE_SYSTEM_ID
                        AND (MCR.START_DATE_ACTIVE < SYSDATE OR MCR.START_DATE_ACTIVE IS NULL)
                        AND (MCR.END_DATE_ACTIVE > SYSDATE OR MCR.END_DATE_ACTIVE IS NULL)
                        AND ROWNUM = 1
                     )
               WHERE EIPI.DATA_SET_ID = :p_data_set_id
                 AND EIPI.PROCESS_STATUS = 0
                 -- MUST NOT HAVE A MASTER ITEM RECORD IN CURRENT BATCH
                 AND NOT EXISTS (SELECT NULL
                                 FROM MTL_SYSTEM_ITEMS_INTERFACE MSII
                                 WHERE MSII.PROCESS_FLAG IN (0, 1, 33390,33391)
                                   AND MSII.SET_PROCESS_ID = :p_data_set_id1
                                   AND MSII.SOURCE_SYSTEM_ID =  EIPI.SOURCE_SYSTEM_ID
                                   AND MSII.SOURCE_SYSTEM_REFERENCE = EIPI.SOURCE_SYSTEM_REFERENCE
                                   AND MSII.ORGANIZATION_ID = :l_org_id
                                )
                 -- HAS A CROSS REFERENCE
                 AND EXISTS (SELECT NULL
                             FROM MTL_CROSS_REFERENCES_B MCR
                             WHERE MCR.CROSS_REFERENCE_TYPE = 'SS_ITEM_XREF'
                               AND MCR.CROSS_REFERENCE = EIPI.SOURCE_SYSTEM_REFERENCE
                               AND MCR.SOURCE_SYSTEM_ID = EIPI.SOURCE_SYSTEM_ID
                               AND (MCR.START_DATE_ACTIVE < SYSDATE OR MCR.START_DATE_ACTIVE IS NULL)
                               AND (MCR.END_DATE_ACTIVE > SYSDATE OR MCR.END_DATE_ACTIVE IS NULL)
                            #'||l_security_predicate||')';

    EXECUTE IMMEDIATE l_sql USING p_data_set_id, p_data_set_id, l_org_id;

    Debug_Conc_Log('Resolve_Child_Entities - After updating item people intf table for items that has XXref');

    -- updating the item user defined attributes interface
    l_sql := q'#
               UPDATE EGO_ITM_USR_ATTR_INTRFC EIUAI
                 SET (PROCESS_STATUS, TRANSACTION_TYPE, INVENTORY_ITEM_ID) =
                     (SELECT
                        1,
                        NVL(EIUAI.TRANSACTION_TYPE, 'SYNC'),
                        MCR.INVENTORY_ITEM_ID
                      FROM MTL_CROSS_REFERENCES_B MCR
                      WHERE MCR.CROSS_REFERENCE_TYPE = 'SS_ITEM_XREF'
                        AND MCR.CROSS_REFERENCE = EIUAI.SOURCE_SYSTEM_REFERENCE
                        AND MCR.SOURCE_SYSTEM_ID = EIUAI.SOURCE_SYSTEM_ID
                        AND (MCR.START_DATE_ACTIVE < SYSDATE OR MCR.START_DATE_ACTIVE IS NULL)
                        AND (MCR.END_DATE_ACTIVE > SYSDATE OR MCR.END_DATE_ACTIVE IS NULL)
                        AND ROWNUM = 1
                     )
               WHERE EIUAI.DATA_SET_ID = :p_data_set_id
                 AND EIUAI.PROCESS_STATUS = 0
                 -- MUST NOT HAVE A MASTER ITEM RECORD IN CURRENT BATCH
                 AND NOT EXISTS (SELECT NULL
                                 FROM MTL_SYSTEM_ITEMS_INTERFACE MSII
                                 WHERE MSII.PROCESS_FLAG IN (0, 1, 33390, 33391)
                                   AND MSII.SET_PROCESS_ID = :p_data_set_id1
                                   AND MSII.SOURCE_SYSTEM_ID =  EIUAI.SOURCE_SYSTEM_ID
                                   AND MSII.SOURCE_SYSTEM_REFERENCE = EIUAI.SOURCE_SYSTEM_REFERENCE
                                   AND MSII.ORGANIZATION_ID = :l_org_id
                                )
                 -- HAS A CROSS REFERENCE
                 AND EXISTS (SELECT NULL
                             FROM MTL_CROSS_REFERENCES_B MCR
                             WHERE MCR.CROSS_REFERENCE_TYPE = 'SS_ITEM_XREF'
                               AND MCR.CROSS_REFERENCE = EIUAI.SOURCE_SYSTEM_REFERENCE
                               AND MCR.SOURCE_SYSTEM_ID = EIUAI.SOURCE_SYSTEM_ID
                               AND (MCR.START_DATE_ACTIVE < SYSDATE OR MCR.START_DATE_ACTIVE IS NULL)
                               AND (MCR.END_DATE_ACTIVE > SYSDATE OR MCR.END_DATE_ACTIVE IS NULL)
                            #'||l_security_predicate||')';

    EXECUTE IMMEDIATE l_sql USING p_data_set_id, p_data_set_id, l_org_id;

    Debug_Conc_Log('Resolve_Child_Entities - After updating user attrs intf table for items that has XXref');

    -- updating the item AML interface
    l_sql := q'#
               UPDATE EGO_AML_INTF EAI
                 SET (PROCESS_FLAG, TRANSACTION_TYPE, INVENTORY_ITEM_ID) =
                     (SELECT
                        1,
                        NVL(EAI.TRANSACTION_TYPE, 'SYNC'),
                        MCR.INVENTORY_ITEM_ID
                      FROM MTL_CROSS_REFERENCES_B MCR
                      WHERE MCR.CROSS_REFERENCE_TYPE = 'SS_ITEM_XREF'
                        AND MCR.CROSS_REFERENCE = EAI.SOURCE_SYSTEM_REFERENCE
                        AND MCR.SOURCE_SYSTEM_ID = EAI.SOURCE_SYSTEM_ID
                        AND (MCR.START_DATE_ACTIVE < SYSDATE OR MCR.START_DATE_ACTIVE IS NULL)
                        AND (MCR.END_DATE_ACTIVE > SYSDATE OR MCR.END_DATE_ACTIVE IS NULL)
                        AND ROWNUM = 1
                     )
               WHERE EAI.DATA_SET_ID = :p_data_set_id
                 AND EAI.PROCESS_FLAG = 0
                 -- MUST NOT HAVE A MASTER ITEM RECORD IN CURRENT BATCH
                 AND NOT EXISTS (SELECT NULL
                                 FROM MTL_SYSTEM_ITEMS_INTERFACE MSII
                                 WHERE MSII.PROCESS_FLAG IN (0, 1, 33390, 33391)
                                   AND MSII.SET_PROCESS_ID = :p_data_set_id1
                                   AND MSII.SOURCE_SYSTEM_ID =  EAI.SOURCE_SYSTEM_ID
                                   AND MSII.SOURCE_SYSTEM_REFERENCE = EAI.SOURCE_SYSTEM_REFERENCE
                                   AND MSII.ORGANIZATION_ID = :l_org_id
                                )
                 -- HAS A CROSS REFERENCE
                 AND EXISTS (SELECT NULL
                             FROM MTL_CROSS_REFERENCES_B MCR
                             WHERE MCR.CROSS_REFERENCE_TYPE = 'SS_ITEM_XREF'
                               AND MCR.CROSS_REFERENCE = EAI.SOURCE_SYSTEM_REFERENCE
                               AND MCR.SOURCE_SYSTEM_ID = EAI.SOURCE_SYSTEM_ID
                               AND (MCR.START_DATE_ACTIVE < SYSDATE OR MCR.START_DATE_ACTIVE IS NULL)
                               AND (MCR.END_DATE_ACTIVE > SYSDATE OR MCR.END_DATE_ACTIVE IS NULL)
                            #'||l_security_predicate||')';

    EXECUTE IMMEDIATE l_sql USING p_data_set_id, p_data_set_id, l_org_id;

    Debug_Conc_Log('Resolve_Child_Entities - After updating aml intf table for items that has XXref');

    -- updating the item intersections
    l_sql := q'#
               UPDATE EGO_ITEM_ASSOCIATIONS_INTF EIAI
                 SET (PROCESS_FLAG, TRANSACTION_TYPE, INVENTORY_ITEM_ID) =
                     (SELECT
                        1,
                        EIAI.TRANSACTION_TYPE,
                        MCR.INVENTORY_ITEM_ID
                      FROM MTL_CROSS_REFERENCES_B MCR
                      WHERE MCR.CROSS_REFERENCE_TYPE = 'SS_ITEM_XREF'
                        AND MCR.CROSS_REFERENCE = EIAI.SOURCE_SYSTEM_REFERENCE
                        AND MCR.SOURCE_SYSTEM_ID = EIAI.SOURCE_SYSTEM_ID
                        AND (MCR.START_DATE_ACTIVE < SYSDATE OR MCR.START_DATE_ACTIVE IS NULL)
                        AND (MCR.END_DATE_ACTIVE > SYSDATE OR MCR.END_DATE_ACTIVE IS NULL)
                        AND ROWNUM = 1
                     )
               WHERE EIAI.BATCH_ID = :p_data_set_id
                 AND EIAI.PROCESS_FLAG = 0
                 -- MUST NOT HAVE A MASTER ITEM RECORD IN CURRENT BATCH
                 AND NOT EXISTS (SELECT NULL
                                 FROM MTL_SYSTEM_ITEMS_INTERFACE MSII
                                 WHERE MSII.PROCESS_FLAG IN (0, 1, 33390,33391)
                                   AND MSII.SET_PROCESS_ID = :p_data_set_id1
                                   AND MSII.SOURCE_SYSTEM_ID =  EIAI.SOURCE_SYSTEM_ID
                                   AND MSII.SOURCE_SYSTEM_REFERENCE = EIAI.SOURCE_SYSTEM_REFERENCE
                                   AND MSII.ORGANIZATION_ID = :l_org_id
                                )
                 -- HAS A CROSS REFERENCE
                 AND EXISTS (SELECT NULL
                             FROM MTL_CROSS_REFERENCES_B MCR
                             WHERE MCR.CROSS_REFERENCE_TYPE = 'SS_ITEM_XREF'
                               AND MCR.CROSS_REFERENCE = EIAI.SOURCE_SYSTEM_REFERENCE
                               AND MCR.SOURCE_SYSTEM_ID = EIAI.SOURCE_SYSTEM_ID
                               AND (MCR.START_DATE_ACTIVE < SYSDATE OR MCR.START_DATE_ACTIVE IS NULL)
                               AND (MCR.END_DATE_ACTIVE > SYSDATE OR MCR.END_DATE_ACTIVE IS NULL)
                            #'||l_security_predicate||')';

    EXECUTE IMMEDIATE l_sql USING p_data_set_id, p_data_set_id, l_org_id;

    Debug_Conc_Log('Resolve_Child_Entities - After updating intersections intf table for items that has XXref');

    UPDATE MTL_SYSTEM_ITEMS_INTERFACE
    SET REQUEST_ID = CASE PROCESS_FLAG
                     WHEN 33390 THEN l_request_id
                     WHEN 33391 THEN l_request_id
                     ELSE REQUEST_ID
                     END,
        PROCESS_FLAG = CASE PROCESS_FLAG
                       WHEN 33390 THEN 3
                       WHEN 33391 THEN 3
                       ELSE PROCESS_FLAG
                       END,
        CONFIRM_STATUS = SUBSTR(CONFIRM_STATUS, 1, 2)
    WHERE SET_PROCESS_ID = p_data_set_id
      AND PROCESS_FLAG IN (1, 33390, 33391)
      AND CONFIRM_STATUS IN ('CNR', 'CMR', 'CCR')
      AND ORGANIZATION_ID = l_org_id;
    Debug_Conc_Log( 'Resolve_Child_Entities - Resolved pre-IOI process flag, request_id for ' || SQL%ROWCOUNT || ' rows' );

    /*
     * Note that setting the process flag to 7 does not interfere with the source system cross-reference
     * import because that bulk-loader looks for process flag 7 with the request id of the calling request.
     * Since both that code (Process_SSXref_Intf_Rows) and this chunk are executed within the auspices of
     * the same concurrent request, the cross-ref import will work correctly.
     */
    UPDATE MTL_SYSTEM_ITEMS_INTERFACE
    SET REQUEST_ID = l_request_id
      , PROCESS_FLAG = CASE PROCESS_FLAG
                       WHEN 33390 THEN 3
                       WHEN 33391 THEN 3
                       ELSE 7
                       END
    WHERE SET_PROCESS_ID = p_data_set_id
      AND PROCESS_FLAG IN (1, 33390, 33391)
      AND CONFIRM_STATUS IN ( G_FAKE_CONF_STATUS_FLAG, G_CONF_MATCH_FAKE, G_CONF_XREF_FAKE )
      AND ORGANIZATION_ID = l_org_id;
    Debug_Conc_Log( 'Resolve_Child_Entities - Stamped request_id and final process flag on ' || SQL%ROWCOUNT || ' inserted rows' );

    IF l_enabled_for_data_pool = 'N' THEN
      Debug_Conc_Log('Resolve_Child_Entities - Calling Merge_Batch_For_Import');
      Merge_Batch_For_Import(p_data_set_id, l_org_id);
      Debug_Conc_Log('Resolve_Child_Entities - Done Merge_Batch_For_Import');

      Debug_Conc_Log('Resolve_Child_Entities - Calling Clean_Up_UDA_Row_Idents');
      Clean_Up_UDA_Row_Idents( p_batch_id            => p_data_set_id,
                               p_process_status      => 1,
                               p_ignore_item_num_upd => FND_API.G_FALSE,
                               p_commit              => FND_API.G_FALSE );

      Debug_Conc_Log('Resolve_Child_Entities - Clean_Up_UDA_Row_Idents Done.');
    ELSE
      Debug_Conc_Log('Resolve_Child_Entities - Not calling Merge_Batch_For_Import, because this batch is enabled for data pool');
    END IF;

    Debug_Conc_Log('Resolve_Child_Entities - Resolving Style_Item_Flag');
    UPDATE MTL_SYSTEM_ITEMS_INTERFACE msii
    SET (STYLE_ITEM_FLAG, STYLE_ITEM_ID) = (SELECT
                                              DECODE(MAX(NVL(msik.STYLE_ITEM_FLAG, '$NULL$')),
                                                     '$NULL$', msii.STYLE_ITEM_FLAG,
                                                     NULL, msii.STYLE_ITEM_FLAG,
                                                     'N', 'N',
                                                     'Y', 'Y'
                                                    ),
                                              NVL(MAX(msik.STYLE_ITEM_ID), msii.STYLE_ITEM_ID)
                                            FROM MTL_SYSTEM_ITEMS_KFV msik, MTL_PARAMETERS mp
                                            WHERE (msii.INVENTORY_ITEM_ID = msik.INVENTORY_ITEM_ID
                                                OR msii.ITEM_NUMBER = msik.CONCATENATED_SEGMENTS)
                                              AND msik.ORGANIZATION_ID = mp.MASTER_ORGANIZATION_ID
                                              AND msii.ORGANIZATION_ID = mp.ORGANIZATION_ID
                                           )
    WHERE SET_PROCESS_ID = p_data_set_id
      AND PROCESS_FLAG   = 1;

    Debug_Conc_Log('Resolve_Child_Entities - Done Resolving Style_Item_Flag, rows processed='||SQL%ROWCOUNT);

    Debug_Conc_Log('Resolve_Child_Entities END');
    IF FND_API.G_TRUE = p_commit THEN
      Debug_Conc_Log('Resolve_Child_Entities COMMITING');
      COMMIT;
    END IF;

  END Resolve_Child_Entities;

    PROCEDURE Stamp_Row_RequestId( p_request_id    IN  MTL_SYSTEM_ITEMS_INTERFACE.REQUEST_ID%TYPE
                                 , p_target_rowid  IN  UROWID
                                 )
    IS
    BEGIN
        IF p_request_id IS NULL THEN RETURN; END IF;

        SAVEPOINT do_stamp_row;

        UPDATE  MTL_SYSTEM_ITEMS_INTERFACE MSII
        SET     REQUEST_ID = p_request_id
        WHERE   MSII.ROWID              = p_target_rowid
           AND  PROCESS_FLAG            = 7
           AND  (   SOURCE_SYSTEM_ID    IS NOT NULL
                OR  SOURCE_SYSTEM_REFERENCE IS NOT NULL
                );

        IF 1 <> SQL%ROWCOUNT THEN
            ROLLBACK TO do_stamp_row;
--      ELSE
--          COMMIT;
        END IF;

        RETURN;
    END;


    PROCEDURE Stamp_RequestId_For_ReImport( p_request_id    IN  MTL_SYSTEM_ITEMS_INTERFACE.REQUEST_ID%TYPE )
    IS
        l_index     PLS_INTEGER;
    BEGIN
        IF G_MSII_REIMPORT_ROWS IS NOT NULL THEN
            l_index := G_MSII_REIMPORT_ROWS.FIRST;
            WHILE l_index IS NOT NULL LOOP
                UPDATE MTL_SYSTEM_ITEMS_INTERFACE
                    SET REQUEST_ID = p_request_id
                WHERE   ROWID = G_MSII_REIMPORT_ROWS( l_index );
                l_index := G_MSII_REIMPORT_ROWS.next( l_index );
            END LOOP;
            G_MSII_REIMPORT_ROWS := NULL;
        END IF;
    END;

    PROCEDURE Log_Error_For_ReImport(p_request_id    IN  MTL_SYSTEM_ITEMS_INTERFACE.REQUEST_ID%TYPE
                                    , p_target_rowid  IN  UROWID
                                    , p_err_msg       IN  VARCHAR2
                                    )
    IS
      l_org_id            NUMBER;
      l_transaction_id    NUMBER;
      dumm_status         VARCHAR2(100);
      l_user_id           NUMBER := FND_GLOBAL.USER_ID;
      l_login_id          NUMBER := FND_GLOBAL.LOGIN_ID;
      l_prog_appid        NUMBER := FND_GLOBAL.PROG_APPL_ID;
      l_prog_id           NUMBER := FND_GLOBAL.CONC_PROGRAM_ID;
      l_err_text          VARCHAR2(4000);
    BEGIN
      UPDATE MTL_SYSTEM_ITEMS_INTERFACE
      SET REQUEST_ID = p_request_id
      WHERE ROWID = p_target_rowid
      RETURNING ORGANIZATION_ID, TRANSACTION_ID
      INTO l_org_id, l_transaction_id;

      dumm_status  := INVPUOPI.mtl_log_interface_err(
                            l_org_id
                           ,l_user_id
                           ,l_login_id
                           ,l_prog_appid
                           ,l_prog_id
                           ,p_request_id
                           ,l_transaction_id
                           ,p_err_msg
                           ,'GLOBAL_TRADE_ITEM_NUMBER'
                           ,'MTL_SYSTEM_ITEMS_INTERFACE'
                           ,'INV_IOI_ERR'
                           ,l_err_text);
    EXCEPTION WHEN OTHERS THEN
      NULL;
    END Log_Error_For_ReImport;

    PROCEDURE Prepare_Row_For_ReImport
        (   p_batch_id          IN          MTL_SYSTEM_ITEMS_INTERFACE.SET_PROCESS_ID%TYPE
        ,   p_organization_id   IN          MTL_SYSTEM_ITEMS_INTERFACE.ORGANIZATION_ID%TYPE
        ,   p_target_rowid      IN          UROWID
        ,   x_return_code       OUT NOCOPY  NUMBER
        ,   x_err_msg           OUT NOCOPY  VARCHAR2
        )
    IS
        l_process_flag      MTL_SYSTEM_ITEMS_INTERFACE.PROCESS_FLAG%TYPE;
        l_ssr               MTL_SYSTEM_ITEMS_INTERFACE.SOURCE_SYSTEM_REFERENCE%TYPE;
        l_ss_id             MTL_SYSTEM_ITEMS_INTERFACE.SOURCE_SYSTEM_ID%TYPE;
        l_ssr_desc          MTL_SYSTEM_ITEMS_INTERFACE.SOURCE_SYSTEM_REFERENCE_DESC%TYPE;
        l_batch_ss_id       EGO_IMPORT_BATCHES_B.SOURCE_SYSTEM_ID%TYPE;
        l_request_id        MTL_SYSTEM_ITEMS_INTERFACE.REQUEST_ID%TYPE;
        l_org_id            MTL_SYSTEM_ITEMS_INTERFACE.ORGANIZATION_ID%TYPE;
        l_item_number       MTL_SYSTEM_ITEMS_INTERFACE.ITEM_NUMBER%TYPE;
        l_item_id           MTL_SYSTEM_ITEMS_INTERFACE.INVENTORY_ITEM_ID%TYPE;
        l_ssxref_only       EGO_IMPORT_OPTION_SETS.IMPORT_XREF_ONLY%TYPE;

        l_is_pdh_batch      BOOLEAN;
        l_is_reimport       BOOLEAN;
        l_is_ssxref_only    BOOLEAN;
        l_reimport_process_status  MTL_SYSTEM_ITEMS_INTERFACE.PROCESS_FLAG%TYPE;
        l_priv_exists       VARCHAR2(1);
        l_msg_text          VARCHAR2(4000);
        l_xref_item_number  MTL_SYSTEM_ITEMS_INTERFACE.ITEM_NUMBER%TYPE;
        l_xref_item_id      MTL_SYSTEM_ITEMS_INTERFACE.INVENTORY_ITEM_ID%TYPE;
        l_xref_desc         MTL_CROSS_REFERENCES.DESCRIPTION%TYPE;
        l_org_code          MTL_SYSTEM_ITEMS_INTERFACE.ORGANIZATION_CODE%TYPE;
        l_party_name        VARCHAR2(1000); -- Bug: 5355759
    BEGIN
        x_return_code       := 0;
        BEGIN     -- CHECK THAT BATCH HAS A HEADER
            SELECT  BATCH.SOURCE_SYSTEM_ID
                ,   BATCH.ORGANIZATION_ID
                ,   NVL( OPT.IMPORT_XREF_ONLY, 'N' )
            INTO    l_batch_ss_id
                ,   l_org_id
                ,   l_ssxref_only
            FROM    EGO_IMPORT_BATCHES_B BATCH, EGO_IMPORT_OPTION_SETS OPT
            WHERE   BATCH.BATCH_ID          = p_batch_id
                AND BATCH.ORGANIZATION_ID   = p_organization_id
                AND BATCH.BATCH_ID          = OPT.BATCH_ID;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                x_return_code := 20; -- no batch header
                RETURN;
        END;

        l_is_reimport       := FALSE;
        l_is_pdh_batch      := ( l_batch_ss_id = get_pdh_source_system_id );
        l_is_ssxref_only    := NOT l_is_pdh_batch AND ( 'Y' = l_ssxref_only );
        l_party_name        := Get_Current_Party_Name; -- Bug: 5355759
        IF l_is_pdh_batch THEN
            SAVEPOINT do_prepare_master_row; -- ENSURES THAT THE UPDATES ARE AN ATOMIC UNIT WITHIN THE TRANSACTION
            -- XXX: Should child updates be attempted first?

            -- update/select master item row
            UPDATE  MTL_SYSTEM_ITEMS_INTERFACE MSII
            SET     PROCESS_FLAG =  CASE PROCESS_FLAG
                                    WHEN 3 THEN 1
--                                    WHEN 7 THEN G_IOI_STAMP_REQUEST_ID_FLAG
                                    ELSE PROCESS_FLAG END
            WHERE   SET_PROCESS_ID          = p_batch_id
               AND  ORGANIZATION_ID         = p_organization_id
               AND  MSII.ROWID              = p_target_rowid
               AND  PROCESS_FLAG            IN ( 3, 7 )
               AND  (   SOURCE_SYSTEM_ID    IS NULL
                    OR  SOURCE_SYSTEM_ID    = l_batch_ss_id
                    )
            RETURNING
                    MSII.PROCESS_FLAG
                ,   MSII.REQUEST_ID
                ,   MSII.INVENTORY_ITEM_ID
                ,   MSII.ITEM_NUMBER
                ,   MSII.ORGANIZATION_ID
            INTO
                    l_process_flag
                ,   l_request_id
                ,   l_item_id
                ,   l_item_number
                ,   l_org_id;

            IF 1 <> SQL%ROWCOUNT THEN
                ROLLBACK TO do_prepare_master_row;
                x_return_code := 10; -- update statement found too many matching master rows, or not enough
                RETURN;
            END IF;

            IF 7 = l_process_flag THEN
--              IF G_MSII_REIMPORT_ROWS IS NULL THEN
--                  G_MSII_REIMPORT_ROWS := UROWID_TABLE( );
--              END IF;
                x_return_code := G_NEEDS_REQUEST_ID_STAMP;
--              G_MSII_REIMPORT_ROWS.EXTEND( );
--              G_MSII_REIMPORT_ROWS( G_MSII_REIMPORT_ROWS.LAST ) := p_target_rowid;
            ELSE
                l_is_reimport := TRUE;
                SAVEPOINT do_prepare_master_row; -- move savepoint up since parent row was in error
            END IF;

            IF l_item_id IS NOT NULL THEN
                -- xxx: should the item number to use for comparison be fetched from the msii kfv?

                -- updating the item's org assignments
                UPDATE  MTL_SYSTEM_ITEMS_INTERFACE MSII
                SET     PROCESS_FLAG = 1
                WHERE   (   INVENTORY_ITEM_ID       = l_item_id
                        OR  (   ITEM_NUMBER         = l_item_number
                            AND INVENTORY_ITEM_ID   IS NULL
                            )
                        )
                    AND PROCESS_FLAG            = 3
                    AND SET_PROCESS_ID          = p_batch_id
                    AND REQUEST_ID              = l_request_id
                    AND ORGANIZATION_ID         IN  (   SELECT  MP.ORGANIZATION_ID
                                                        FROM    MTL_PARAMETERS MP
                                                        WHERE   MP.MASTER_ORGANIZATION_ID   =   l_org_id
                                                            AND MP.ORGANIZATION_ID          <>  l_org_id
                                                    );
                l_is_reimport := l_is_reimport OR ( 0 <> SQL%ROWCOUNT );

                -- updating item revisions
                UPDATE  MTL_ITEM_REVISIONS_INTERFACE miri
                SET     PROCESS_FLAG = 1
                WHERE   (   INVENTORY_ITEM_ID       = l_item_id
                        OR  (   ITEM_NUMBER         = l_item_number
                            AND INVENTORY_ITEM_ID   IS NULL
                            )
                        )
                    AND PROCESS_FLAG            = 3
                    AND SET_PROCESS_ID          = p_batch_id
                    AND REQUEST_ID              = l_request_id
                    AND ORGANIZATION_ID         IN  (   SELECT  MP.ORGANIZATION_ID
                                                        FROM    MTL_PARAMETERS MP
                                                        WHERE   MP.MASTER_ORGANIZATION_ID   =  l_org_id
                                                    );
                l_is_reimport := l_is_reimport OR ( 0 <> SQL%ROWCOUNT );

                -- updating item category assignments
                UPDATE MTL_ITEM_CATEGORIES_INTERFACE mici
                SET     PROCESS_FLAG = 1
                WHERE   (   INVENTORY_ITEM_ID       = l_item_id
                        OR  (   ITEM_NUMBER         = l_item_number
                            AND INVENTORY_ITEM_ID   IS NULL
                            )
                        )
                    AND PROCESS_FLAG            = 3
                    AND SET_PROCESS_ID          = p_batch_id
                    AND REQUEST_ID              = l_request_id
                    AND ORGANIZATION_ID         IN  (   SELECT  MP.ORGANIZATION_ID
                                                        FROM    MTL_PARAMETERS MP
                                                        WHERE   MP.MASTER_ORGANIZATION_ID   =  l_org_id
                                                    );
                l_is_reimport := l_is_reimport OR ( 0 <> SQL%ROWCOUNT );

                -- updating item user defined attributes
                UPDATE EGO_ITM_USR_ATTR_INTRFC
                SET     PROCESS_STATUS = 1
                WHERE   (   INVENTORY_ITEM_ID       = l_item_id
                        OR  (   ITEM_NUMBER         = l_item_number
                            AND INVENTORY_ITEM_ID   IS NULL
                            )
                        )
                    AND PROCESS_STATUS          = 3
                    AND DATA_SET_ID             = p_batch_id
                    AND REQUEST_ID              = l_request_id
                    AND ORGANIZATION_ID         IN  (   SELECT  MP.ORGANIZATION_ID
                                                        FROM    MTL_PARAMETERS MP
                                                        WHERE   MP.MASTER_ORGANIZATION_ID   =  l_org_id
                                                    );
                l_is_reimport := l_is_reimport OR ( 0 <> SQL%ROWCOUNT );

                -- updating item people
                UPDATE EGO_ITEM_PEOPLE_INTF eipi
                SET     PROCESS_STATUS = 1
                WHERE   (   INVENTORY_ITEM_ID       = l_item_id
                        OR  (   ITEM_NUMBER         = l_item_number
                            AND INVENTORY_ITEM_ID   IS NULL
                            )
                        )
                    AND PROCESS_STATUS          = 3
                    AND DATA_SET_ID             = p_batch_id
                    AND REQUEST_ID              = l_request_id
                    AND ORGANIZATION_ID         IN  (   SELECT  MP.ORGANIZATION_ID
                                                        FROM    MTL_PARAMETERS MP
                                                        WHERE   MP.MASTER_ORGANIZATION_ID   =  l_org_id
                                                    );
                l_is_reimport := l_is_reimport OR ( 0 <> SQL%ROWCOUNT );

                -- updating item AML
                UPDATE EGO_AML_INTF
                SET     PROCESS_FLAG = 1
                WHERE   (   INVENTORY_ITEM_ID       = l_item_id
                        OR  (   ITEM_NUMBER         = l_item_number
                            AND INVENTORY_ITEM_ID   IS NULL
                            )
                        )
                    AND PROCESS_FLAG            = 3
                    AND DATA_SET_ID             = p_batch_id
                    AND REQUEST_ID              = l_request_id
                    AND ORGANIZATION_ID         IN  (   SELECT  MP.ORGANIZATION_ID
                                                        FROM    MTL_PARAMETERS MP
                                                        WHERE   MP.MASTER_ORGANIZATION_ID   =  l_org_id
                                                    );
                l_is_reimport := l_is_reimport OR ( 0 <> SQL%ROWCOUNT );

                UPDATE EGO_ITEM_ASSOCIATIONS_INTF
                SET     PROCESS_FLAG = 1
                WHERE   (   INVENTORY_ITEM_ID       = l_item_id
                        OR  (   ITEM_NUMBER         = l_item_number
                            AND INVENTORY_ITEM_ID   IS NULL
                            )
                        )
                    AND PROCESS_FLAG            = 3
                    AND BATCH_ID             = p_batch_id
                    AND REQUEST_ID              = l_request_id
                    AND ORGANIZATION_ID         IN  (   SELECT  MP.ORGANIZATION_ID
                                                        FROM    MTL_PARAMETERS MP
                                                        WHERE   MP.MASTER_ORGANIZATION_ID   =  l_org_id
                                                    );
                l_is_reimport := l_is_reimport OR ( 0 <> SQL%ROWCOUNT );
            ELSE    -- item id is null
                -- updating the item's org assignments
                UPDATE  MTL_SYSTEM_ITEMS_INTERFACE MSII
                SET     PROCESS_FLAG = 1
                WHERE   ITEM_NUMBER             = l_item_number
                    AND PROCESS_FLAG            = 3
                    AND SET_PROCESS_ID          = p_batch_id
                    AND REQUEST_ID              = l_request_id
                    AND ORGANIZATION_ID         IN  (   SELECT  MP.ORGANIZATION_ID
                                                        FROM    MTL_PARAMETERS MP
                                                        WHERE   MP.MASTER_ORGANIZATION_ID   =   l_org_id
                                                            AND MP.ORGANIZATION_ID          <>  l_org_id
                                                    );
                l_is_reimport := l_is_reimport OR ( 0 <> SQL%ROWCOUNT );

                -- updating item revisions
                UPDATE  MTL_ITEM_REVISIONS_INTERFACE miri
                SET     PROCESS_FLAG = 1
                WHERE   ITEM_NUMBER             = l_item_number
                    AND PROCESS_FLAG            = 3
                    AND SET_PROCESS_ID          = p_batch_id
                    AND REQUEST_ID              = l_request_id
                    AND ORGANIZATION_ID         IN  (   SELECT  MP.ORGANIZATION_ID
                                                        FROM    MTL_PARAMETERS MP
                                                        WHERE   MP.MASTER_ORGANIZATION_ID   =  l_org_id
                                                    );
                l_is_reimport := l_is_reimport OR ( 0 <> SQL%ROWCOUNT );

                -- updating item category assignments
                UPDATE MTL_ITEM_CATEGORIES_INTERFACE mici
                SET     PROCESS_FLAG = 1
                WHERE   ITEM_NUMBER             = l_item_number
                    AND PROCESS_FLAG            = 3
                    AND SET_PROCESS_ID          = p_batch_id
                    AND REQUEST_ID              = l_request_id
                    AND ORGANIZATION_ID         IN  (   SELECT  MP.ORGANIZATION_ID
                                                        FROM    MTL_PARAMETERS MP
                                                        WHERE   MP.MASTER_ORGANIZATION_ID   =  l_org_id
                                                    );
                l_is_reimport := l_is_reimport OR ( 0 <> SQL%ROWCOUNT );

                -- updating item user defined attributes
                UPDATE EGO_ITM_USR_ATTR_INTRFC
                SET     PROCESS_STATUS = 1
                WHERE   ITEM_NUMBER             = l_item_number
                    AND PROCESS_STATUS          = 3
                    AND DATA_SET_ID             = p_batch_id
                    AND REQUEST_ID              = l_request_id
                    AND ORGANIZATION_ID         IN  (   SELECT  MP.ORGANIZATION_ID
                                                        FROM    MTL_PARAMETERS MP
                                                        WHERE   MP.MASTER_ORGANIZATION_ID   =  l_org_id
                                                    );
                l_is_reimport := l_is_reimport OR ( 0 <> SQL%ROWCOUNT );

                -- updating item people
                UPDATE EGO_ITEM_PEOPLE_INTF eipi
                SET     PROCESS_STATUS = 1
                WHERE   ITEM_NUMBER             = l_item_number
                    AND PROCESS_STATUS          = 3
                    AND DATA_SET_ID             = p_batch_id
                    AND REQUEST_ID              = l_request_id
                    AND ORGANIZATION_ID         IN  (   SELECT  MP.ORGANIZATION_ID
                                                        FROM    MTL_PARAMETERS MP
                                                        WHERE   MP.MASTER_ORGANIZATION_ID   =  l_org_id
                                                    );
                l_is_reimport := l_is_reimport OR ( 0 <> SQL%ROWCOUNT );

                -- updating item AML
                UPDATE EGO_AML_INTF
                SET     PROCESS_FLAG = 1
                WHERE   ITEM_NUMBER             = l_item_number
                    AND PROCESS_FLAG            = 3
                    AND DATA_SET_ID             = p_batch_id
                    AND REQUEST_ID              = l_request_id
                    AND ORGANIZATION_ID         IN  (   SELECT  MP.ORGANIZATION_ID
                                                        FROM    MTL_PARAMETERS MP
                                                        WHERE   MP.MASTER_ORGANIZATION_ID   =  l_org_id
                                                    );
                l_is_reimport := l_is_reimport OR ( 0 <> SQL%ROWCOUNT );
                -- updating item ITEM ASSOCIATIONS
                UPDATE EGO_ITEM_ASSOCIATIONS_INTF
                SET     PROCESS_FLAG = 1
                WHERE   ITEM_NUMBER             = l_item_number
                    AND PROCESS_FLAG            = 3
                    AND BATCH_ID             = p_batch_id
                    AND REQUEST_ID              = l_request_id
                    AND ORGANIZATION_ID         IN  (   SELECT  MP.ORGANIZATION_ID
                                                        FROM    MTL_PARAMETERS MP
                                                        WHERE   MP.MASTER_ORGANIZATION_ID   =  l_org_id
                                                    );
                l_is_reimport := l_is_reimport OR ( 0 <> SQL%ROWCOUNT );
            END IF;
        ELSE    -- source system is not PIMDH
            SAVEPOINT do_prepare_master_row; -- ENSURES THAT THE UPDATES ARE AN ATOMIC UNIT WITHIN THE TRANSACTION

            -- TODO: need to check for cross-reference related security.
            -- however, we can't trust confirm status for the errored rows...

            -- XXX: Should child updates be attempted first?

            -- Bug: 5355759
            IF l_is_ssxref_only THEN
                l_reimport_process_status := 11;
            ELSE
                l_reimport_process_status := 1;
            END IF;

            -- update/select master item row
            UPDATE  MTL_SYSTEM_ITEMS_INTERFACE MSII
            SET     PROCESS_FLAG =  CASE PROCESS_FLAG
                                    WHEN 3 THEN l_reimport_process_status
--                                    WHEN 7 THEN G_IOI_STAMP_REQUEST_ID_FLAG
                                    ELSE PROCESS_FLAG END
            WHERE   SET_PROCESS_ID          = p_batch_id
               AND  ORGANIZATION_ID         = p_organization_id
               AND  MSII.ROWID              = p_target_rowid
               AND  PROCESS_FLAG            IN ( 3, 7 )
               AND  SOURCE_SYSTEM_ID        IS NOT NULL
               AND  SOURCE_SYSTEM_REFERENCE IS NOT NULL
            RETURNING
                    MSII.PROCESS_FLAG
                ,   MSII.REQUEST_ID
                ,   MSII.SOURCE_SYSTEM_ID
                ,   MSII.SOURCE_SYSTEM_REFERENCE
                ,   MSII.SOURCE_SYSTEM_REFERENCE_DESC
                ,   MSII.ORGANIZATION_ID
                ,   MSII.INVENTORY_ITEM_ID
                ,   MSII.ITEM_NUMBER
            INTO
                    l_process_flag
                ,   l_request_id
                ,   l_ss_id
                ,   l_ssr
                ,   l_ssr_desc
                ,   l_org_id
                ,   l_item_id
                ,   l_item_number;

            IF 1 <> SQL%ROWCOUNT THEN
                ROLLBACK TO do_prepare_master_row;
                x_return_code := 10;
                RETURN;
            END IF;

            IF 7 = l_process_flag THEN
--              IF G_MSII_REIMPORT_ROWS IS NULL THEN
--                  G_MSII_REIMPORT_ROWS := UROWID_TABLE( );
--              END IF;
                x_return_code := G_NEEDS_REQUEST_ID_STAMP;
--              G_MSII_REIMPORT_ROWS.EXTEND( );
--              G_MSII_REIMPORT_ROWS( G_MSII_REIMPORT_ROWS.LAST ) := p_target_rowid;
            ELSE
                l_is_reimport := TRUE;
                SAVEPOINT do_prepare_master_row; -- move savepoint up since parent row was in error
                -- Bug: 5355759
                -- check for cross-reference related security

                BEGIN
                    SELECT ORGANIZATION_CODE
                    INTO l_org_code
                    FROM MTL_PARAMETERS
                    WHERE ORGANIZATION_ID = l_org_id;
                EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    NULL;
                END;

                BEGIN
                    SELECT  MSIK.CONCATENATED_SEGMENTS
                         ,  MSIK.INVENTORY_ITEM_ID
                         ,  MCR.DESCRIPTION
                    INTO    l_xref_item_number
                         ,  l_xref_item_id
                         ,  l_xref_desc
                    FROM  MTL_CROSS_REFERENCES MCR,
                          MTL_SYSTEM_ITEMS_KFV MSIK
                    WHERE   MCR.INVENTORY_ITEM_ID    = MSIK.INVENTORY_ITEM_ID
                        AND MSIK.ORGANIZATION_ID     = l_org_id
                        AND MCR.CROSS_REFERENCE_TYPE = 'SS_ITEM_XREF'
                        AND MCR.SOURCE_SYSTEM_ID     = l_ss_id
                        AND MCR.CROSS_REFERENCE      = l_ssr
                        AND SYSDATE BETWEEN NVL(MCR.START_DATE_ACTIVE, SYSDATE-1) AND NVL(MCR.END_DATE_ACTIVE, SYSDATE+1);

                    IF l_xref_item_id <> l_item_id THEN
                        -- old xref and new xref are not same, so check privilege on old item
                        l_priv_exists := EGO_DATA_SECURITY.CHECK_FUNCTION(1.0, 'EGO_EDIT_SS_ITEM_XREFS', 'EGO_ITEM', l_xref_item_id, l_org_id, NULL, NULL, NULL, l_party_name);
                        IF 'T'        <> l_priv_exists THEN
                            -- no privileges, logging error
                            FND_MESSAGE.SET_NAME('EGO', 'EGO_NO_EDIT_XREF_PRIV');
                            FND_MESSAGE.SET_TOKEN('ITEM', l_xref_item_number);
                            FND_MESSAGE.SET_TOKEN('ORG', l_org_code);
                            l_msg_text := FND_MESSAGE.GET;
                            UPDATE MTL_SYSTEM_ITEMS_INTERFACE
                                SET PROCESS_FLAG = 3
                            WHERE ROWID          = p_target_rowid;
                            x_return_code       := G_NEED_TO_LOG_ERROR;
                            x_err_msg           := l_msg_text;
                            RETURN;
                        ELSE
                            -- privilege exists on old item. Check privilege on new item
                            l_priv_exists := EGO_DATA_SECURITY.CHECK_FUNCTION(1.0, 'EGO_EDIT_SS_ITEM_XREFS', 'EGO_ITEM', l_item_id, l_org_id, NULL, NULL, NULL, l_party_name);
                            IF 'T'        <> l_priv_exists THEN
                                -- no privileges, logging error
                                FND_MESSAGE.SET_NAME('EGO', 'EGO_NO_EDIT_XREF_PRIV');
                                FND_MESSAGE.SET_TOKEN('ITEM', l_item_number);
                                FND_MESSAGE.SET_TOKEN('ORG', l_org_code);
                                l_msg_text := FND_MESSAGE.GET;

                                UPDATE MTL_SYSTEM_ITEMS_INTERFACE
                                    SET PROCESS_FLAG = 3
                                WHERE ROWID          = p_target_rowid;

                                x_return_code       := G_NEED_TO_LOG_ERROR;
                                x_err_msg           := l_msg_text;
                                RETURN;
                            END IF; -- IF 'T' <> l_priv_exists THEN
                        END IF;     -- IF 'T' <> l_priv_exists THEN
                    ELSIF l_xref_item_id = l_item_id AND NVL(l_ssr_desc, '!') <> NVL(l_xref_desc, '!') THEN
                        -- New and Old link are same, but description is different, so check privilege on item
                        l_priv_exists := EGO_DATA_SECURITY.CHECK_FUNCTION(1.0, 'EGO_EDIT_SS_ITEM_XREFS', 'EGO_ITEM', l_item_id, l_org_id, NULL, NULL, NULL, l_party_name);
                        IF 'T'        <> l_priv_exists THEN
                            -- no privileges, logging error
                            FND_MESSAGE.SET_NAME('EGO', 'EGO_NO_EDIT_XREF_PRIV');
                            FND_MESSAGE.SET_TOKEN('ITEM', l_item_number);
                            FND_MESSAGE.SET_TOKEN('ORG', l_org_code);
                            l_msg_text := FND_MESSAGE.GET;

                            UPDATE MTL_SYSTEM_ITEMS_INTERFACE
                                SET PROCESS_FLAG = 3
                            WHERE ROWID          = p_target_rowid;

                            x_return_code       := G_NEED_TO_LOG_ERROR;
                            x_err_msg           := l_msg_text;
                            RETURN;
                        END IF; -- IF 'T' <> l_priv_exists THEN
                    END IF;     -- IF l_xref_item_id <> l_item_id THEN
                EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    -- check privilege only for new item
                    l_priv_exists := EGO_DATA_SECURITY.CHECK_FUNCTION(1.0, 'EGO_EDIT_SS_ITEM_XREFS', 'EGO_ITEM', l_item_id, l_org_id, NULL, NULL, NULL, l_party_name);
                    IF 'T'        <> l_priv_exists THEN
                        -- no privileges, logging error
                        FND_MESSAGE.SET_NAME('EGO', 'EGO_NO_EDIT_XREF_PRIV');
                        FND_MESSAGE.SET_TOKEN('ITEM', l_item_number);
                        FND_MESSAGE.SET_TOKEN('ORG', l_org_code);
                        l_msg_text := FND_MESSAGE.GET;

                        UPDATE MTL_SYSTEM_ITEMS_INTERFACE
                            SET PROCESS_FLAG = 3
                        WHERE ROWID          = p_target_rowid;

                        x_return_code       := G_NEED_TO_LOG_ERROR;
                        x_err_msg           := l_msg_text;
                        RETURN;
                    END IF; -- IF 'T' <> l_priv_exists THEN
                END;
            END IF;

            IF NOT l_is_ssxref_only THEN
                -- updating item's org assignments
                UPDATE  MTL_SYSTEM_ITEMS_INTERFACE MSII
                SET     PROCESS_FLAG = 1
                WHERE   SOURCE_SYSTEM_ID        = l_ss_id
                    AND SOURCE_SYSTEM_REFERENCE = l_ssr
                    AND PROCESS_FLAG            = 3
                    AND SET_PROCESS_ID          = p_batch_id
                    AND REQUEST_ID              = l_request_id
                    AND ORGANIZATION_ID     IN  (   SELECT  MP.ORGANIZATION_ID          -- org assignment
                                                    FROM    MTL_PARAMETERS MP
                                                    WHERE   MP.MASTER_ORGANIZATION_ID   =   l_org_id
                                                        AND MP.ORGANIZATION_ID          <>  l_org_id
                                                );
                l_is_reimport := l_is_reimport OR ( 0 <> SQL%ROWCOUNT );

                -- updating item revisions
                UPDATE  MTL_ITEM_REVISIONS_INTERFACE miri
                SET     PROCESS_FLAG = 1
                WHERE   SOURCE_SYSTEM_ID        = l_ss_id
                    AND SOURCE_SYSTEM_REFERENCE = l_ssr
                    AND PROCESS_FLAG            = 3
                    AND SET_PROCESS_ID          = p_batch_id
                    AND REQUEST_ID              = l_request_id
                    AND ORGANIZATION_ID         IN  (   SELECT  MP.ORGANIZATION_ID
                                                        FROM    MTL_PARAMETERS MP
                                                        WHERE   MP.MASTER_ORGANIZATION_ID   =  l_org_id
                                                    );
                l_is_reimport := l_is_reimport OR ( 0 <> SQL%ROWCOUNT );

                -- updating item category assignments
                UPDATE MTL_ITEM_CATEGORIES_INTERFACE mici
                SET     PROCESS_FLAG = 1
                WHERE   SOURCE_SYSTEM_ID        = l_ss_id
                    AND SOURCE_SYSTEM_REFERENCE = l_ssr
                    AND PROCESS_FLAG            = 3
                    AND SET_PROCESS_ID          = p_batch_id
                    AND REQUEST_ID              = l_request_id
                    AND ORGANIZATION_ID         IN  (   SELECT  MP.ORGANIZATION_ID
                                                        FROM    MTL_PARAMETERS MP
                                                        WHERE   MP.MASTER_ORGANIZATION_ID   =  l_org_id
                                                    );
                l_is_reimport := l_is_reimport OR ( 0 <> SQL%ROWCOUNT );

                -- updating item user defined attributes
                UPDATE EGO_ITM_USR_ATTR_INTRFC
                SET     PROCESS_STATUS = 1
                WHERE   SOURCE_SYSTEM_ID        = l_ss_id
                    AND SOURCE_SYSTEM_REFERENCE = l_ssr
                    AND PROCESS_STATUS          = 3
                    AND DATA_SET_ID             = p_batch_id
                    AND REQUEST_ID              = l_request_id
                    AND ORGANIZATION_ID         IN  (   SELECT  MP.ORGANIZATION_ID
                                                        FROM    MTL_PARAMETERS MP
                                                        WHERE   MP.MASTER_ORGANIZATION_ID   =  l_org_id
                                                    );
                l_is_reimport := l_is_reimport OR ( 0 <> SQL%ROWCOUNT );

                -- updating item people
                UPDATE EGO_ITEM_PEOPLE_INTF eipi
                SET     PROCESS_STATUS = 1
                WHERE   SOURCE_SYSTEM_ID        = l_ss_id
                    AND SOURCE_SYSTEM_REFERENCE = l_ssr
                    AND PROCESS_STATUS          = 3
                    AND DATA_SET_ID             = p_batch_id
                    AND REQUEST_ID              = l_request_id
                    AND ORGANIZATION_ID         IN  (   SELECT  MP.ORGANIZATION_ID
                                                        FROM    MTL_PARAMETERS MP
                                                        WHERE   MP.MASTER_ORGANIZATION_ID   =  l_org_id
                                                    );
                l_is_reimport := l_is_reimport OR ( 0 <> SQL%ROWCOUNT );

                -- updating item AML
                UPDATE EGO_AML_INTF
                SET     PROCESS_FLAG = 1
                WHERE   SOURCE_SYSTEM_ID        = l_ss_id
                    AND SOURCE_SYSTEM_REFERENCE = l_ssr
                    AND PROCESS_FLAG            = 3
                    AND DATA_SET_ID             = p_batch_id
                    AND REQUEST_ID              = l_request_id
                    AND ORGANIZATION_ID         IN  (   SELECT  MP.ORGANIZATION_ID
                                                        FROM    MTL_PARAMETERS MP
                                                        WHERE   MP.MASTER_ORGANIZATION_ID   =  l_org_id
                                                    );
                l_is_reimport := l_is_reimport OR ( 0 <> SQL%ROWCOUNT );
                UPDATE EGO_ITEM_ASSOCIATIONS_INTF
                SET     PROCESS_FLAG = 1
                WHERE   SOURCE_SYSTEM_ID        = l_ss_id
                    AND SOURCE_SYSTEM_REFERENCE = l_ssr
                    AND PROCESS_FLAG            = 3
                    AND BATCH_ID             = p_batch_id
                    AND REQUEST_ID              = l_request_id
                    AND ORGANIZATION_ID         IN  (   SELECT  MP.ORGANIZATION_ID
                                                        FROM    MTL_PARAMETERS MP
                                                        WHERE   MP.MASTER_ORGANIZATION_ID   =  l_org_id
                                                    );
                l_is_reimport := l_is_reimport OR ( 0 <> SQL%ROWCOUNT );
            END IF; -- IF l_is_ssxref_only
        END IF;

        IF NOT l_is_reimport THEN
            ROLLBACK TO do_prepare_master_row;
            x_return_code := 50;
        END IF;
        SAVEPOINT do_prepare_master_row;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            ROLLBACK TO do_prepare_master_row;
            x_return_code := 30;
        WHEN TOO_MANY_ROWS THEN
            ROLLBACK TO do_prepare_master_row;
            x_return_code := 40;
        WHEN OTHERS THEN -- unanticipated error ( probably during update )
            ROLLBACK TO do_prepare_master_row;
            x_return_code := SQLCODE;
    END Prepare_Row_For_ReImport;

 ------------------------------------------------------------------------------------------
 -- This function returns the batch status of a batch                                    --
 ------------------------------------------------------------------------------------------
 FUNCTION GET_BATCH_STATUS(p_batch_id NUMBER) RETURN VARCHAR2 AS
   l_batch_status VARCHAR2(2);
 BEGIN
   SELECT
     (CASE  WHEN ( (crimp.PHASE_CODE IN ('P', 'I', 'R') AND (crimp.REQUESTED_START_DATE <= SYSDATE) )
                  OR crmatch.PHASE_CODE IN ('P', 'I', 'R')
                 )
            THEN 'P'
            ELSE impbat.BATCH_STATUS
      END
     ) BATCH_STATUS
     INTO l_batch_status
   FROM
     EGO_IMPORT_BATCHES_B impbat,
     FND_CONCURRENT_REQUESTS crimp,
     FND_CONCURRENT_REQUESTS crmatch
   WHERE impbat.BATCH_ID               = p_batch_id
     AND impbat.LAST_MATCH_REQUEST_ID  = crmatch.REQUEST_ID (+)
     AND impbat.LAST_IMPORT_REQUEST_ID = crimp.REQUEST_ID (+);

   RETURN l_batch_status;
 EXCEPTION
   WHEN NO_DATA_FOUND THEN
     RETURN NULL;
 END GET_BATCH_STATUS;

    ------------------------------------------------------------------------------------------------
    --  Functions GET_LATEST_EIUAI_REV_[SS/PDH]                                                   --
    --  Returns the the code of the latest LOGICAL revision row loaded for the item into the      --
    --  user defined attribute interface table                                                    --
    --  Note the lack of attribute-specific parameters - this is to ensure that contexts in       --
    --      which this proc gets called will only attempt to go after a single logical revision   --
    --      row, regardless of the possible absence of the required attributes in that row and    --
    --      their possible presence in other logical rows of the interface table                  --
    ------------------------------------------------------------------------------------------------
    FUNCTION GET_LATEST_EIUAI_REV_SS
        (
            p_batch_id                      IN      EGO_ITM_USR_ATTR_INTRFC.DATA_SET_ID%TYPE
        ,   p_source_system_id              IN      EGO_ITM_USR_ATTR_INTRFC.SOURCE_SYSTEM_ID%TYPE
        ,   p_source_system_reference       IN      EGO_ITM_USR_ATTR_INTRFC.SOURCE_SYSTEM_REFERENCE%TYPE
        ,   p_organization_id               IN      EGO_ITM_USR_ATTR_INTRFC.ORGANIZATION_ID%TYPE
        ,   p_do_processed_rows_flag        IN      FLAG                    DEFAULT FND_API.G_FALSE
        ,   p_request_id                    IN      EGO_ITM_USR_ATTR_INTRFC.REQUEST_ID%TYPE DEFAULT NULL
        )
    RETURN EGO_ITM_USR_ATTR_INTRFC.REVISION%TYPE
    IS
        l_rev_code EGO_ITM_USR_ATTR_INTRFC.REVISION%TYPE;
    BEGIN
        IF  p_do_processed_rows_flag = FND_API.G_TRUE THEN
           SELECT MAX( EIUAI.REVISION ) INTO  l_rev_code
           FROM EGO_ITM_USR_ATTR_INTRFC EIUAI
           WHERE   EIUAI.SOURCE_SYSTEM_REFERENCE   = p_source_system_reference
               AND EIUAI.SOURCE_SYSTEM_ID          = p_source_system_id
               AND EIUAI.ORGANIZATION_ID           = p_organization_id
               AND EIUAI.DATA_SET_ID               = p_batch_id
               AND EIUAI.REVISION                  IS NOT NULL
               AND EIUAI.PROCESS_STATUS            IN ( 3,4 )
               AND EIUAI.REQUEST_ID                = p_request_id
               AND EXISTS( SELECT NULL -- SEE DEFINITION OF EGO_OBJ_ATTR_GRP_ASSOCS_V
                       FROM EGO_FND_DSC_FLX_CTX_EXT FL_CTX_EXT
                          , EGO_OBJ_AG_ASSOCS_B A
                       WHERE
                           -- CHECK FOR REVISION LEVEL GROUPS ONLY
                           A.DATA_LEVEL                             = 'ITEM_REVISION_LEVEL'
                           AND FL_CTX_EXT.DESCRIPTIVE_FLEXFIELD_NAME    = NVL( EIUAI.ATTR_GROUP_TYPE, G_DEFAULT_ATTR_GROUP_TYPE )
                           AND FL_CTX_EXT.APPLICATION_ID                = 431
                           AND FL_CTX_EXT.DESCRIPTIVE_FLEX_CONTEXT_CODE = EIUAI.ATTR_GROUP_INT_NAME
                           AND A.ATTR_GROUP_ID                      = FL_CTX_EXT.ATTR_GROUP_ID
                           -- TO ENSURE A(OBJECT_ID, CLASS_CODE, ATTR_GROUP) IDX USED:
                           AND A.CLASSIFICATION_CODE                IS NOT NULL
                           AND A.OBJECT_ID                          IS NOT NULL
                           AND ROWNUM = 1
                       );
               -- the aggregate function MAX always returns one (possibly null) row, so
               -- no need to check for the NO_DATA_FOUND exception, or initialize l_rev_code
        ELSE
           SELECT MAX( EIUAI.REVISION ) INTO  l_rev_code
           FROM EGO_ITM_USR_ATTR_INTRFC EIUAI
           WHERE   EIUAI.SOURCE_SYSTEM_REFERENCE   = p_source_system_reference
               AND EIUAI.SOURCE_SYSTEM_ID          = p_source_system_id
               AND EIUAI.ORGANIZATION_ID           = p_organization_id
               AND EIUAI.DATA_SET_ID               = p_batch_id
               AND EIUAI.REVISION                  IS NOT NULL
               AND EIUAI.PROCESS_STATUS            = 0
               AND EXISTS( SELECT NULL -- SEE DEFINITION OF EGO_OBJ_ATTR_GRP_ASSOCS_V
                       FROM EGO_FND_DSC_FLX_CTX_EXT FL_CTX_EXT
                          , EGO_OBJ_AG_ASSOCS_B A
                       WHERE
                           -- CHECK FOR REVISION LEVEL GROUPS ONLY
                           A.DATA_LEVEL                             = 'ITEM_REVISION_LEVEL'
                           AND FL_CTX_EXT.DESCRIPTIVE_FLEXFIELD_NAME    = NVL( EIUAI.ATTR_GROUP_TYPE, G_DEFAULT_ATTR_GROUP_TYPE )
                           AND FL_CTX_EXT.APPLICATION_ID                = 431
                           AND FL_CTX_EXT.DESCRIPTIVE_FLEX_CONTEXT_CODE = EIUAI.ATTR_GROUP_INT_NAME
                           AND A.ATTR_GROUP_ID                      = FL_CTX_EXT.ATTR_GROUP_ID
                           -- TO ENSURE A(OBJECT_ID, CLASS_CODE, ATTR_GROUP) IDX USED:
                           AND A.CLASSIFICATION_CODE                IS NOT NULL
                           AND A.OBJECT_ID                          IS NOT NULL
                           AND ROWNUM = 1
                       );
               -- the aggregate function MAX always returns one (possibly null) row, so
               -- no need to check for the NO_DATA_FOUND exception, or initialize l_rev_code
        END IF;
        RETURN l_rev_code;
    END GET_LATEST_EIUAI_REV_SS;

   FUNCTION GET_LATEST_EIUAI_REV_PDH
       (
           p_batch_id                      IN      EGO_ITM_USR_ATTR_INTRFC.DATA_SET_ID%TYPE
       ,   p_inventory_item_id             IN      EGO_ITM_USR_ATTR_INTRFC.INVENTORY_ITEM_ID%TYPE
       ,   p_item_number                   IN      EGO_ITM_USR_ATTR_INTRFC.ITEM_NUMBER%TYPE
       ,   p_organization_id               IN      EGO_ITM_USR_ATTR_INTRFC.ORGANIZATION_ID%TYPE
       ,   p_do_processed_rows_flag        IN      FLAG                    DEFAULT FND_API.G_FALSE
       ,   p_request_id                    IN      EGO_ITM_USR_ATTR_INTRFC.REQUEST_ID%TYPE DEFAULT NULL
       )
   RETURN EGO_ITM_USR_ATTR_INTRFC.REVISION%TYPE
   IS
       l_rev_code          EGO_ITM_USR_ATTR_INTRFC.REVISION%TYPE;
       l_sql_stmt          VARCHAR2( 32000 );
   BEGIN
       -- the aggregate function MAX always returns one (possibly null) row, so
       -- no need to check for the NO_DATA_FOUND exception, or initialize l_rev_code

       IF   p_inventory_item_id IS NULL
       THEN
           IF p_do_processed_rows_flag = FND_API.G_TRUE THEN
               SELECT MAX( EIUAI.REVISION )
               INTO l_rev_code
               FROM EGO_ITM_USR_ATTR_INTRFC EIUAI
               WHERE   EIUAI.ITEM_NUMBER               = p_item_number
                   AND EIUAI.ORGANIZATION_ID           = p_organization_id
                   AND EIUAI.DATA_SET_ID               = p_batch_id
                   AND EIUAI.REVISION                  IS NOT NULL
                   AND EIUAI.PROCESS_STATUS            IN ( 3, 4 )
                   AND EIUAI.REQUEST_ID                = p_request_id
                   AND EXISTS( SELECT NULL -- SEE DEFINITION OF EGO_OBJ_ATTR_GRP_ASSOCS_V
                           FROM EGO_FND_DSC_FLX_CTX_EXT FL_CTX_EXT
                              , EGO_OBJ_AG_ASSOCS_B A
                           WHERE
                               -- CHECK FOR REVISION LEVEL GROUPS ONLY
                               A.DATA_LEVEL                             = 'ITEM_REVISION_LEVEL'
                               AND FL_CTX_EXT.DESCRIPTIVE_FLEXFIELD_NAME    = NVL( EIUAI.ATTR_GROUP_TYPE, G_DEFAULT_ATTR_GROUP_TYPE )
                               AND FL_CTX_EXT.APPLICATION_ID                = 431
                               AND FL_CTX_EXT.DESCRIPTIVE_FLEX_CONTEXT_CODE = EIUAI.ATTR_GROUP_INT_NAME
                               AND A.ATTR_GROUP_ID                      = FL_CTX_EXT.ATTR_GROUP_ID
                               -- TO ENSURE A(OBJECT_ID, CLASS_CODE, ATTR_GROUP) IDX USED:
                               AND A.CLASSIFICATION_CODE                IS NOT NULL
                               AND A.OBJECT_ID                          IS NOT NULL
                               AND ROWNUM = 1
                           );
                   -- the aggregate function MAX always returns one (possibly null) row, so
                   -- no need to check for the NO_DATA_FOUND exception, or initialize l_rev_code
           ELSE
               SELECT MAX( EIUAI.REVISION )
               INTO l_rev_code
               FROM EGO_ITM_USR_ATTR_INTRFC EIUAI
               WHERE   EIUAI.ITEM_NUMBER               = p_item_number
                   AND EIUAI.ORGANIZATION_ID           = p_organization_id
                   AND EIUAI.DATA_SET_ID               = p_batch_id
                   AND EIUAI.REVISION                  IS NOT NULL
                   AND EIUAI.PROCESS_STATUS            = 1
                   AND EXISTS( SELECT NULL -- SEE DEFINITION OF EGO_OBJ_ATTR_GRP_ASSOCS_V
                           FROM EGO_FND_DSC_FLX_CTX_EXT FL_CTX_EXT
                              , EGO_OBJ_AG_ASSOCS_B A
                           WHERE
                               -- CHECK FOR REVISION LEVEL GROUPS ONLY
                               A.DATA_LEVEL                             = 'ITEM_REVISION_LEVEL'
                               AND FL_CTX_EXT.DESCRIPTIVE_FLEXFIELD_NAME    = NVL( EIUAI.ATTR_GROUP_TYPE, G_DEFAULT_ATTR_GROUP_TYPE )
                               AND FL_CTX_EXT.APPLICATION_ID                = 431
                               AND FL_CTX_EXT.DESCRIPTIVE_FLEX_CONTEXT_CODE = EIUAI.ATTR_GROUP_INT_NAME
                               AND A.ATTR_GROUP_ID                      = FL_CTX_EXT.ATTR_GROUP_ID
                               -- TO ENSURE A(OBJECT_ID, CLASS_CODE, ATTR_GROUP) IDX USED:
                               AND A.CLASSIFICATION_CODE                IS NOT NULL
                               AND A.OBJECT_ID                          IS NOT NULL
                               AND ROWNUM = 1
                           );
                   -- the aggregate function MAX always returns one (possibly null) row, so
                   -- no need to check for the NO_DATA_FOUND exception, or initialize l_rev_code
           END IF;
       ELSE
           IF p_do_processed_rows_flag = FND_API.G_TRUE THEN
               SELECT MAX( EIUAI.REVISION )
               INTO l_rev_code
               FROM EGO_ITM_USR_ATTR_INTRFC EIUAI
               WHERE
                   (   (   EIUAI.INVENTORY_ITEM_ID     IS NULL
                       AND EIUAI.ITEM_NUMBER           = p_item_number
                       )
                   OR  EIUAI.INVENTORY_ITEM_ID         = p_inventory_item_id
                   )
                   AND EIUAI.ORGANIZATION_ID           = p_organization_id
                   AND EIUAI.DATA_SET_ID               = p_batch_id
                   AND EIUAI.REVISION                  IS NOT NULL
                   AND EIUAI.PROCESS_STATUS            IN ( 3, 4 )
                   AND EIUAI.REQUEST_ID                = p_request_id
                   AND EXISTS( SELECT NULL -- SEE DEFINITION OF EGO_OBJ_ATTR_GRP_ASSOCS_V
                           FROM EGO_FND_DSC_FLX_CTX_EXT FL_CTX_EXT
                              , EGO_OBJ_AG_ASSOCS_B A
                           WHERE
                               -- CHECK FOR REVISION LEVEL GROUPS ONLY
                               A.DATA_LEVEL                             = 'ITEM_REVISION_LEVEL'
                               AND FL_CTX_EXT.DESCRIPTIVE_FLEXFIELD_NAME    = NVL( EIUAI.ATTR_GROUP_TYPE, G_DEFAULT_ATTR_GROUP_TYPE )
                               AND FL_CTX_EXT.APPLICATION_ID                = 431
                               AND FL_CTX_EXT.DESCRIPTIVE_FLEX_CONTEXT_CODE = EIUAI.ATTR_GROUP_INT_NAME
                               AND A.ATTR_GROUP_ID                      = FL_CTX_EXT.ATTR_GROUP_ID
                               -- TO ENSURE A(OBJECT_ID, CLASS_CODE, ATTR_GROUP) IDX USED:
                               AND A.CLASSIFICATION_CODE                IS NOT NULL
                               AND A.OBJECT_ID                          IS NOT NULL
                               AND ROWNUM = 1
                           );
                   -- the aggregate function MAX always returns one (possibly null) row, so
                   -- no need to check for the NO_DATA_FOUND exception, or initialize l_rev_code
           ELSE
               SELECT MAX( EIUAI.REVISION )
               INTO l_rev_code
               FROM EGO_ITM_USR_ATTR_INTRFC EIUAI
               WHERE
                   (   (   EIUAI.INVENTORY_ITEM_ID     IS NULL
                       AND EIUAI.ITEM_NUMBER           = p_item_number
                       )
                   OR  EIUAI.INVENTORY_ITEM_ID         = p_inventory_item_id
                   )
                   AND EIUAI.ORGANIZATION_ID           = p_organization_id
                   AND EIUAI.DATA_SET_ID               = p_batch_id
                   AND EIUAI.REVISION                  IS NOT NULL
                   AND EIUAI.PROCESS_STATUS            = 1
                   AND EXISTS( SELECT NULL -- SEE DEFINITION OF EGO_OBJ_ATTR_GRP_ASSOCS_V
                           FROM EGO_FND_DSC_FLX_CTX_EXT FL_CTX_EXT
                              , EGO_OBJ_AG_ASSOCS_B A
                           WHERE
                               -- CHECK FOR REVISION LEVEL GROUPS ONLY
                               A.DATA_LEVEL                             = 'ITEM_REVISION_LEVEL'
                               AND FL_CTX_EXT.DESCRIPTIVE_FLEXFIELD_NAME    = NVL( EIUAI.ATTR_GROUP_TYPE, G_DEFAULT_ATTR_GROUP_TYPE )
                               AND FL_CTX_EXT.APPLICATION_ID                = 431
                               AND FL_CTX_EXT.DESCRIPTIVE_FLEX_CONTEXT_CODE = EIUAI.ATTR_GROUP_INT_NAME
                               AND A.ATTR_GROUP_ID                      = FL_CTX_EXT.ATTR_GROUP_ID
                               -- TO ENSURE A(OBJECT_ID, CLASS_CODE, ATTR_GROUP) IDX USED:
                               AND A.CLASSIFICATION_CODE                IS NOT NULL
                               AND A.OBJECT_ID                          IS NOT NULL
                               AND ROWNUM = 1
                           );
                   -- the aggregate function MAX always returns one (possibly null) row, so
                   -- no need to check for the NO_DATA_FOUND exception, or initialize l_rev_code
           END IF;
       END IF;
       RETURN l_rev_code;
   END GET_LATEST_EIUAI_REV_PDH;

    FUNCTION GET_LATEST_MIRI_REV_SS
    (
        p_batch_id                      IN  MTL_ITEM_REVISIONS_INTERFACE.SET_PROCESS_ID%TYPE
    ,   p_source_system_id              IN  MTL_ITEM_REVISIONS_INTERFACE.SOURCE_SYSTEM_ID%TYPE
    ,   p_source_system_reference       IN  MTL_ITEM_REVISIONS_INTERFACE.SOURCE_SYSTEM_REFERENCE%TYPE
    ,   p_organization_id               IN  MTL_ITEM_REVISIONS_INTERFACE.ORGANIZATION_ID%TYPE
    ,   p_do_processed_rows_flag        IN  FLAG                    DEFAULT FND_API.G_FALSE
    ,   p_request_id                    IN  MTL_ITEM_REVISIONS_INTERFACE.REQUEST_ID%TYPE DEFAULT NULL
    )
    RETURN MTL_ITEM_REVISIONS_INTERFACE.REVISION%TYPE IS
       l_revision MTL_ITEM_REVISIONS_INTERFACE.REVISION%TYPE;
   BEGIN
      IF p_do_processed_rows_flag = FND_API.G_FALSE THEN
            SELECT MAX( REVISION ) KEEP ( DENSE_RANK FIRST ORDER BY MIRI.EFFECTIVITY_DATE DESC NULLS LAST , MIRI.REVISION DESC NULLS LAST )
            INTO l_revision
            FROM
               MTL_ITEM_REVISIONS_INTERFACE MIRI
            WHERE   MIRI.SET_PROCESS_id             = p_batch_id
                AND MIRI.SOURCE_SYSTEM_ID           = p_source_system_id
                AND MIRI.SOURCE_SYSTEM_REFERENCE    = p_source_system_reference
                AND MIRI.ORGANIZATION_ID            = p_organization_id
                AND MIRI.PROCESS_FLAG               = 0;
      ELSE
            SELECT MAX( REVISION ) KEEP ( DENSE_RANK FIRST ORDER BY MIRI.EFFECTIVITY_DATE DESC NULLS LAST , MIRI.REVISION DESC NULLS LAST )
            INTO l_revision
            FROM
               MTL_ITEM_REVISIONS_INTERFACE MIRI
            WHERE
               MIRI.SET_PROCESS_id              = p_batch_id
               AND MIRI.SOURCE_SYSTEM_ID        = p_source_system_id
               AND MIRI.SOURCE_SYSTEM_REFERENCE = p_source_system_reference
               AND MIRI.ORGANIZATION_ID         = p_organization_id
               AND MIRI.REQUEST_ID              = p_request_id
               AND MIRI.PROCESS_FLAG            IN (3, 7);
      END IF;
      RETURN l_revision;
   EXCEPTION
       WHEN NO_DATA_FOUND THEN
           RETURN NULL;
   END GET_LATEST_MIRI_REV_SS;

    FUNCTION GET_LATEST_MIRI_REV_PDH
    (
        p_batch_id                      IN  MTL_ITEM_REVISIONS_INTERFACE.SET_PROCESS_ID%TYPE
    ,   p_inventory_item_id             IN  MTL_ITEM_REVISIONS_INTERFACE.INVENTORY_ITEM_ID%TYPE
    ,   p_item_number                   IN  MTL_ITEM_REVISIONS_INTERFACE.ITEM_NUMBER%TYPE
    ,   p_organization_id               IN  MTL_ITEM_REVISIONS_INTERFACE.ORGANIZATION_ID%TYPE
    ,   p_do_processed_rows_flag        IN  FLAG                    DEFAULT FND_API.G_FALSE
    ,   p_request_id                    IN  MTL_ITEM_REVISIONS_INTERFACE.REQUEST_ID%TYPE DEFAULT NULL
    )
   RETURN MTL_ITEM_REVISIONS_INTERFACE.REVISION%TYPE IS
       l_revision MTL_ITEM_REVISIONS_INTERFACE.REVISION%TYPE;
   BEGIN
      IF p_inventory_item_id IS NULL THEN
         IF p_do_processed_rows_flag = FND_API.G_FALSE THEN
            SELECT MAX( REVISION ) KEEP ( DENSE_RANK FIRST
                                        ORDER BY MIRI.EFFECTIVITY_DATE DESC NULLS LAST , MIRI.REVISION DESC NULLS LAST )
            INTO l_revision
            FROM MTL_ITEM_REVISIONS_INTERFACE MIRI
            WHERE  MIRI.SET_PROCESS_id      = p_batch_id
               AND MIRI.ITEM_NUMBER         = p_item_number
               AND MIRI.ORGANIZATION_ID     = p_organization_id
               AND MIRI.PROCESS_FLAG        = 1;
         ELSE
            SELECT MAX( REVISION ) KEEP ( DENSE_RANK FIRST
                                        ORDER BY MIRI.EFFECTIVITY_DATE DESC NULLS LAST , MIRI.REVISION DESC NULLS LAST )
            INTO l_revision
            FROM MTL_ITEM_REVISIONS_INTERFACE MIRI
            WHERE  MIRI.SET_PROCESS_id      = p_batch_id
               AND MIRI.ITEM_NUMBER         = p_item_number
               AND MIRI.ORGANIZATION_ID     = p_organization_id
               AND MIRI.REQUEST_ID          = p_request_id
               AND MIRI.PROCESS_FLAG        IN (3, 7);
         END IF;
      ELSE -- p_inventory_item_id is not null
         IF p_do_processed_rows_flag = FND_API.G_FALSE THEN
            SELECT MAX( REVISION ) KEEP ( DENSE_RANK FIRST
                                        ORDER BY MIRI.EFFECTIVITY_DATE DESC NULLS LAST , MIRI.REVISION DESC NULLS LAST )
            INTO l_revision
            FROM MTL_ITEM_REVISIONS_INTERFACE MIRI
            WHERE   MIRI.SET_PROCESS_id = p_batch_id
                AND (   ( MIRI.INVENTORY_ITEM_ID IS NULL AND MIRI.ITEM_NUMBER = p_item_number )
                    OR  MIRI.INVENTORY_ITEM_ID  = p_inventory_item_id
                    )
                AND MIRI.ORGANIZATION_ID        = p_organization_id
                AND MIRI.PROCESS_FLAG           = 1;
         ELSE
            SELECT MAX( REVISION ) KEEP ( DENSE_RANK FIRST
                                        ORDER BY MIRI.EFFECTIVITY_DATE DESC NULLS LAST , MIRI.REVISION DESC NULLS LAST )
            INTO l_revision
            FROM MTL_ITEM_REVISIONS_INTERFACE MIRI
            WHERE   MIRI.SET_PROCESS_id = p_batch_id
                AND (   ( MIRI.INVENTORY_ITEM_ID IS NULL AND MIRI.ITEM_NUMBER = p_item_number )
                    OR  MIRI.INVENTORY_ITEM_ID  = p_inventory_item_id
                    )
                AND MIRI.ORGANIZATION_ID        = p_organization_id
                AND PROCESS_FLAG                IN ( 3, 7 );
         END IF;
      END IF;
      RETURN l_revision;
   EXCEPTION
       WHEN NO_DATA_FOUND THEN
           RETURN NULL;
   END GET_LATEST_MIRI_REV_PDH;

   --------------------------------------------------------------------------------------------
   --  Function WRAPPED_TO_NUMBER                                                            --
   --      Wraps the to_number built-in to return null in case of conversion failure         --
   --------------------------------------------------------------------------------------------
   FUNCTION WRAPPED_TO_NUMBER( p_val VARCHAR2 )
   RETURN NUMBER
   DETERMINISTIC
   IS
       l_return_value  NUMBER;
   BEGIN
       l_return_value := to_number( p_val );
       RETURN l_return_value;
   EXCEPTION
       WHEN OTHERS THEN
           RETURN NULL;
   END WRAPPED_TO_NUMBER;

   --------------------------------------------------------------------------------------------
   --  Function WRAPPED_TO_DATE                                                              --
   --      Wraps the to_date built-in to return null in case of conversion failure           --
   --------------------------------------------------------------------------------------------
   FUNCTION WRAPPED_TO_DATE( p_val VARCHAR2 )
   RETURN DATE
   DETERMINISTIC
   IS
       l_return_value  DATE;
   BEGIN
       l_return_value := to_date( p_val, EGO_USER_ATTRS_COMMON_PVT.G_DATE_FORMAT );

       -- bug 5366882: substitute internal "null-out" value with excel "null-out" value
       RETURN CASE WHEN l_return_value = to_date( '1', 'J' ) THEN G_EXCEL_MISS_DATE_VAL -- to_date( '9999-12-31', 'YYYY-MM-DD' )
                   ELSE l_return_value
                   END;
   EXCEPTION
       WHEN OTHERS THEN
           RETURN NULL;
   END WRAPPED_TO_DATE;

   --------------------------------------------------------------------------------------------
   --  Function GET_REV_USR_ATTR                                                             --
   --  Returns the display value of the specified revision attribute; if there is no         --
   --      display value, it returns the appropriate value column, based on the              --
   --      p_attr_value_type parameter                                                       --
   --------------------------------------------------------------------------------------------
   FUNCTION GET_REV_USR_ATTR
   (   p_batch_id                          IN  EGO_ITM_USR_ATTR_INTRFC.DATA_SET_ID%TYPE
       , p_source_system_id                IN  EGO_ITM_USR_ATTR_INTRFC.SOURCE_SYSTEM_ID%TYPE
       , p_source_system_reference         IN  EGO_ITM_USR_ATTR_INTRFC.SOURCE_SYSTEM_REFERENCE%TYPE
       , p_organization_id                 IN  EGO_ITM_USR_ATTR_INTRFC.ORGANIZATION_ID%TYPE
       , p_revision_code                   IN  EGO_ITM_USR_ATTR_INTRFC.REVISION%TYPE
       , p_attr_group_type                 IN  EGO_ITM_USR_ATTR_INTRFC.ATTR_GROUP_TYPE%TYPE
       , p_attr_group_name                 IN  EGO_ITM_USR_ATTR_INTRFC.ATTR_GROUP_INT_NAME%TYPE
       , p_attr_name                       IN  EGO_ITM_USR_ATTR_INTRFC.ATTR_INT_NAME%TYPE
       , p_attr_value_type                 IN  FLAG
       )
   RETURN EGO_ITM_USR_ATTR_INTRFC.ATTR_DISP_VALUE%TYPE
   IS
       l_return_value      EGO_ITM_USR_ATTR_INTRFC.ATTR_DISP_VALUE%TYPE;
       l_revision_code     EGO_ITM_USR_ATTR_INTRFC.REVISION%TYPE;
   BEGIN
       l_return_value  := null;
       l_revision_code := p_revision_code;

       -- Check to see whether the revision code has been provided:
       -- If not, default it to be the code of the latest LOGICAL revision row
       IF l_revision_code IS NULL
       THEN
           l_revision_code := GET_LATEST_EIUAI_REV_SS( p_batch_id                  => p_batch_id
                                                     , p_source_system_id          => p_source_system_id
                                                     , p_source_system_reference   => p_source_system_reference
                                                     , p_organization_id           => p_organization_id
                                                     , p_do_processed_rows_flag    => FND_API.G_FALSE
                                                     );
       END IF;

       IF  l_revision_code IS NOT NULL
       THEN
           BEGIN -- start sub-query block
               CASE p_attr_value_type
                   -- text attr-type case
                   WHEN G_TEXT_DATA_TYPE THEN
                       SELECT NVL( EIUAI.ATTR_DISP_VALUE, EIUAI.ATTR_VALUE_STR ) INTO l_return_value
                       FROM EGO_ITM_USR_ATTR_INTRFC EIUAI
                       WHERE
                           NVL( EIUAI.ATTR_GROUP_TYPE, G_DEFAULT_ATTR_GROUP_TYPE ) = p_attr_group_type
                           AND EIUAI.ATTR_GROUP_INT_NAME       = p_attr_group_name
                           AND EIUAI.ATTR_INT_NAME             = p_attr_name
                           AND EIUAI.SOURCE_SYSTEM_REFERENCE   = p_source_system_reference
                           AND EIUAI.SOURCE_SYSTEM_ID          = p_source_system_id
                           AND EIUAI.ORGANIZATION_ID           = p_organization_id
                           AND EIUAI.DATA_SET_ID               = p_batch_id
                           AND EIUAI.REVISION                  = l_revision_code
                           AND rownum < 2
                           ;
                   -- end text attr-type case
                   -- number attr-type case
                   WHEN G_NUMBER_DATA_TYPE THEN
                       SELECT NVL( EIUAI.ATTR_DISP_VALUE, TO_CHAR( EIUAI.ATTR_VALUE_NUM ) ) INTO l_return_value
                       FROM EGO_ITM_USR_ATTR_INTRFC EIUAI
                       WHERE
                           NVL( EIUAI.ATTR_GROUP_TYPE, G_DEFAULT_ATTR_GROUP_TYPE ) = p_attr_group_type
                           AND EIUAI.ATTR_GROUP_INT_NAME       = p_attr_group_name
                           AND EIUAI.ATTR_INT_NAME             = p_attr_name
                           AND EIUAI.SOURCE_SYSTEM_REFERENCE   = p_source_system_reference
                           AND EIUAI.SOURCE_SYSTEM_ID          = p_source_system_id
                           AND EIUAI.ORGANIZATION_ID           = p_organization_id
                           AND EIUAI.DATA_SET_ID               = p_batch_id
                           AND EIUAI.REVISION                  = l_revision_code
                           AND rownum < 2
                           ;
                   -- end number attr-type case
                   -- date attr-type case
                   WHEN G_DATE_DATA_TYPE THEN
                       -- XXX: which date format to use? what about date-time type vs date-type?
                       SELECT NVL( EIUAI.ATTR_DISP_VALUE, TO_CHAR( EIUAI.ATTR_VALUE_DATE ) ) INTO l_return_value
                       FROM EGO_ITM_USR_ATTR_INTRFC EIUAI
                       WHERE
                           NVL( EIUAI.ATTR_GROUP_TYPE, G_DEFAULT_ATTR_GROUP_TYPE ) = p_attr_group_type
                           AND EIUAI.ATTR_GROUP_INT_NAME       = p_attr_group_name
                           AND EIUAI.ATTR_INT_NAME             = p_attr_name
                           AND EIUAI.SOURCE_SYSTEM_REFERENCE   = p_source_system_reference
                           AND EIUAI.SOURCE_SYSTEM_ID          = p_source_system_id
                           AND EIUAI.ORGANIZATION_ID           = p_organization_id
                           AND EIUAI.DATA_SET_ID               = p_batch_id
                           AND EIUAI.REVISION                  = l_revision_code
                           AND rownum < 2
                           ;
                   -- end date attr-type case
               END CASE;
           EXCEPTION
               WHEN NO_DATA_FOUND THEN -- this attribute is not present in the interface table!
                   l_return_value := null; -- 'no data found';
               WHEN OTHERS THEN
                   l_return_value := null; -- 'other error';
           END; -- query sub-block
       ELSE -- revision code is null
           BEGIN -- start sub-query block
               CASE p_attr_value_type
                   -- text attr-type case
                   WHEN G_TEXT_DATA_TYPE THEN
                       SELECT NVL( EIUAI.ATTR_DISP_VALUE, EIUAI.ATTR_VALUE_STR ) INTO l_return_value
                       FROM EGO_ITM_USR_ATTR_INTRFC EIUAI
                       WHERE
                           NVL( EIUAI.ATTR_GROUP_TYPE, G_DEFAULT_ATTR_GROUP_TYPE ) = p_attr_group_type
                           AND EIUAI.ATTR_GROUP_INT_NAME       = p_attr_group_name
                           AND EIUAI.ATTR_INT_NAME             = p_attr_name
                           AND EIUAI.SOURCE_SYSTEM_REFERENCE   = p_source_system_reference
                           AND EIUAI.SOURCE_SYSTEM_ID          = p_source_system_id
                           AND EIUAI.ORGANIZATION_ID           = p_organization_id
                           AND EIUAI.DATA_SET_ID               = p_batch_id
                           AND EIUAI.REVISION                  IS NULL
                           AND rownum < 2
                           ;
                   -- end text attr-type case
                   -- number attr-type case
                   WHEN G_NUMBER_DATA_TYPE THEN
                       SELECT NVL( EIUAI.ATTR_DISP_VALUE, TO_CHAR( EIUAI.ATTR_VALUE_NUM ) ) INTO l_return_value
                       FROM EGO_ITM_USR_ATTR_INTRFC EIUAI
                       WHERE
                           NVL( EIUAI.ATTR_GROUP_TYPE, G_DEFAULT_ATTR_GROUP_TYPE ) = p_attr_group_type
                           AND EIUAI.ATTR_GROUP_INT_NAME       = p_attr_group_name
                           AND EIUAI.ATTR_INT_NAME             = p_attr_name
                           AND EIUAI.SOURCE_SYSTEM_REFERENCE   = p_source_system_reference
                           AND EIUAI.SOURCE_SYSTEM_ID          = p_source_system_id
                           AND EIUAI.ORGANIZATION_ID           = p_organization_id
                           AND EIUAI.DATA_SET_ID               = p_batch_id
                           AND EIUAI.REVISION                  IS NULL
                           AND rownum < 2
                           ;
                   -- end number attr-type case
                   -- date attr-type case
                   WHEN G_DATE_DATA_TYPE THEN
                       -- XXX: which date format to use? what about date-time type vs date-type?
                       SELECT NVL( EIUAI.ATTR_DISP_VALUE, TO_CHAR( EIUAI.ATTR_VALUE_DATE ) ) INTO l_return_value
                       FROM EGO_ITM_USR_ATTR_INTRFC EIUAI
                       WHERE
                           NVL( EIUAI.ATTR_GROUP_TYPE, G_DEFAULT_ATTR_GROUP_TYPE ) = p_attr_group_type
                           AND EIUAI.ATTR_GROUP_INT_NAME       = p_attr_group_name
                           AND EIUAI.ATTR_INT_NAME             = p_attr_name
                           AND EIUAI.SOURCE_SYSTEM_REFERENCE   = p_source_system_reference
                           AND EIUAI.SOURCE_SYSTEM_ID          = p_source_system_id
                           AND EIUAI.ORGANIZATION_ID           = p_organization_id
                           AND EIUAI.DATA_SET_ID               = p_batch_id
                           AND EIUAI.REVISION                  IS NULL
                           AND rownum < 2
                           ;
                   -- end date attr-type case
               END CASE;
           EXCEPTION
               WHEN NO_DATA_FOUND THEN -- this attribute is not present in the interface table!
                   l_return_value := null; -- 'no data found';
               WHEN OTHERS THEN
                   l_return_value := null; -- 'other error';
           END; -- query sub-block
       END IF;

       RETURN l_return_value;
   END GET_REV_USR_ATTR;

    ----------------------------------------------------------------------------------------------
    --  Function GET_REV_USR_ATTR_TO_CHAR
    --  Returns the display value of the specified revision attribute, if the attribute is present
    --  in the interface table, or the internal value, interpreted as a display value.
    --  The assumption is that this will be called from a value set context ...
    ----------------------------------------------------------------------------------------------
    FUNCTION GET_REV_USR_ATTR_TO_CHAR
        (
          p_batch_id                        IN  EGO_ITM_USR_ATTR_INTRFC.DATA_SET_ID%TYPE
        , p_source_system_id                IN  EGO_ITM_USR_ATTR_INTRFC.SOURCE_SYSTEM_ID%TYPE           DEFAULT NULL
        , p_source_system_reference         IN  EGO_ITM_USR_ATTR_INTRFC.SOURCE_SYSTEM_REFERENCE%TYPE    DEFAULT NULL
        , p_organization_id                 IN  EGO_ITM_USR_ATTR_INTRFC.ORGANIZATION_ID%TYPE
        , p_revision_code                   IN  EGO_ITM_USR_ATTR_INTRFC.REVISION%TYPE
        , p_attr_group_type                 IN  EGO_ITM_USR_ATTR_INTRFC.ATTR_GROUP_TYPE%TYPE
        , p_attr_group_name                 IN  EGO_ITM_USR_ATTR_INTRFC.ATTR_GROUP_INT_NAME%TYPE
        , p_attr_name                       IN  EGO_ITM_USR_ATTR_INTRFC.ATTR_INT_NAME%TYPE
        , p_do_processed_rows_flag          IN  FLAG DEFAULT FND_API.G_FALSE
        , p_request_id                      IN  EGO_ITM_USR_ATTR_INTRFC.REQUEST_ID%TYPE                 DEFAULT NULL
        , p_inventory_item_id               IN  EGO_ITM_USR_ATTR_INTRFC.INVENTORY_ITEM_ID%TYPE          DEFAULT NULL
        , p_item_number                     IN  EGO_ITM_USR_ATTR_INTRFC.ITEM_NUMBER%TYPE                DEFAULT NULL
        , p_use_pdh_keys_to_join            IN  BOOLEAN
        , p_get_value_col                   IN  BOOLEAN
        , p_attr_type                       IN  FLAG
        , p_attr_miss_value                 IN  BOOLEAN DEFAULT TRUE
        )
    RETURN EGO_ITM_USR_ATTR_INTRFC.ATTR_DISP_VALUE%TYPE
    IS
        l_return_value      EGO_ITM_USR_ATTR_INTRFC.ATTR_DISP_VALUE%TYPE;
        l_revision_code     EGO_ITM_USR_ATTR_INTRFC.REVISION%TYPE;
        l_sql_stmt          VARCHAR2( 32000 );
        l_do_procd_rows_sql VARCHAR2( 200 );
        l_join_sql          VARCHAR2( 200 );
        l_select_sql        VARCHAR2( 200 );
        l_do_processed_rows BOOLEAN;
        l_miss_str          VARCHAR2( 30 );
        l_date_format       VARCHAR2( 30 ) := NULL;
    BEGIN
        l_return_value  := null; -- 'default';

        CASE -- order of WHEN clauses matters!
            WHEN p_USE_PDH_KEYS_TO_JOIN AND
                 p_inventory_item_id IS NULL AND
                 p_item_number IS NULL
                THEN RETURN l_return_value;
            WHEN p_USE_PDH_KEYS_TO_JOIN THEN
                l_join_sql :=
                    ' AND ( ( '
                ||  CASE
                    WHEN p_inventory_item_id IS NOT NULL THEN
                            ' EIUAI.INVENTORY_ITEM_ID     IS NULL AND'
                    ELSE    ''
                    END
                ||          ' EIUAI.ITEM_NUMBER           = :item_number '
                ||          ' ) '
                ||      ' OR  EIUAI.INVENTORY_ITEM_ID     = :item_id '
                ||      ' ) '
                ;
            WHEN p_source_system_reference IS NULL AND
                 p_source_system_id IS NULL
                 THEN RETURN l_return_value;
            ELSE
                l_join_sql := ' AND EIUAI.SOURCE_SYSTEM_REFERENCE   = :ss_ref '
                           || ' AND EIUAI.SOURCE_SYSTEM_ID          = :ss_id ';
        END CASE;

        l_do_processed_rows := ( p_do_processed_rows_flag = FND_API.G_TRUE );
        l_do_procd_rows_sql :=  ' AND EIUAI.PROCESS_STATUS'
                            ||  CASE
                                WHEN l_do_processed_rows                                    THEN ' IN ( 3, 4 ) AND EIUAI.REQUEST_ID = :req_id '
                                WHEN NOT l_do_processed_rows AND NOT p_use_pdh_keys_to_join THEN ' = 0 '
                                WHEN NOT l_do_processed_rows AND p_use_pdh_keys_to_join     THEN ' = 1 '
                                ELSE ''   -- XXX: hmmm, raise exception here?
                                END;

        l_date_format :=    CASE p_attr_type
                            WHEN G_DATE_TIME_DATA_TYPE THEN FND_PROFILE.VALUE( 'ICX_DATE_FORMAT_MASK' ) || ' HH24:MI:SS'
                            WHEN G_DATE_DATA_TYPE THEN FND_PROFILE.VALUE( 'ICX_DATE_FORMAT_MASK' )
                            ELSE NULL
                            END;

        l_miss_str  := CASE WHEN NOT p_attr_miss_value      THEN G_EXCEL_MISS_VS_VAL
                            WHEN p_attr_type = G_DATE_DATA_TYPE       THEN 'TO_CHAR('||G_EXCEL_MISS_DATE_STR||','''||l_date_format||''')'
                            WHEN p_attr_type = G_DATE_TIME_DATA_TYPE  THEN 'TO_CHAR('||G_EXCEL_MISS_DATE_STR||','''||l_date_format||''')'
                            WHEN p_attr_type = G_NUMBER_DATA_TYPE     THEN 'TO_CHAR('||G_EXCEL_MISS_NUM_STR||')'
                            WHEN p_attr_type = G_TEXT_DATA_TYPE       THEN ''''||G_EXCEL_MISS_CHAR_VAL||''''
                            END;

        IF p_get_value_col
        THEN
            l_select_sql := CASE
                            WHEN p_attr_type = G_DATE_DATA_TYPE OR p_attr_type = G_DATE_TIME_DATA_TYPE THEN
                                'DECODE( EIUAI.ATTR_VALUE_DATE'
                                    ||', NULL, ' || l_miss_str
                                    ||', '|| EGO_USER_ATTRS_BULK_PVT.G_NULL_DATE_VAL ||', '|| l_miss_str
                                    ||', TO_CHAR( EIUAI.ATTR_VALUE_DATE, '''|| l_date_format || ''')'
                                    ||')'
                            WHEN p_attr_type = G_NUMBER_DATA_TYPE THEN
                                -- ignore UOM column completely ... the assumption is that this
                                -- code is called for junk values only
                                'DECODE( EIUAI.ATTR_VALUE_NUM'
                                    ||', NULL, ' || l_miss_str
                                    ||', TO_CHAR( EIUAI.ATTR_VALUE_NUM )'
                                    ||')'
                            WHEN p_attr_type = G_TEXT_DATA_TYPE THEN
                                'NVL( EIUAI.ATTR_VALUE_STR, '|| l_miss_str || ')'
                            END;
        ELSE
            l_select_sql := ' EIUAI.ATTR_DISP_VALUE ';
        END IF;

        -- Check to see whether the revision code has been provided:
        -- If not, default it to be the code of the latest LOGICAL revision row
        l_revision_code :=
            CASE -- order of WHEN clauses matters!
            WHEN p_revision_code IS NOT NULL THEN p_revision_code
            WHEN p_use_pdh_keys_to_join THEN
                GET_LATEST_EIUAI_REV_PDH(   p_batch_id                  => p_batch_id
                                        ,   p_inventory_item_id         => p_inventory_item_id
                                        ,   p_item_number               => p_item_number
                                        ,   p_organization_id           => p_organization_id
                                        ,   p_do_processed_rows_flag    => p_do_processed_rows_flag
                                        ,   p_request_id                => p_request_id
                                        )
            ELSE
                GET_LATEST_EIUAI_REV_SS (   p_batch_id                  => p_batch_id
                                        ,   p_source_system_id          => p_source_system_id
                                        ,   p_source_system_reference   => p_source_system_reference
                                        ,   p_organization_id           => p_organization_id
                                        ,   p_do_processed_rows_flag    => p_do_processed_rows_flag
                                        ,   p_request_id                => p_request_id
                                        )
            END;

        l_sql_stmt := '
            SELECT ' || l_select_sql
        ||' FROM EGO_ITM_USR_ATTR_INTRFC EIUAI '
        ||' WHERE '
            ||' NVL( EIUAI.ATTR_GROUP_TYPE, :default_attr_grp ) = :attr_grp_type'
            ||' AND EIUAI.ATTR_GROUP_INT_NAME       = :attr_grp'
            ||' AND EIUAI.ATTR_INT_NAME             = :attr '
                || l_join_sql
            ||' AND EIUAI.ORGANIZATION_ID           = :org_id '
            ||' AND EIUAI.DATA_SET_ID               = :batch_id '
                || l_do_procd_rows_sql
            ||' AND DECODE( EIUAI.REVISION, :rev_code, 1, 0 ) = 1 '
            ||' AND rownum = 1 '
            ;
            -- note that decode does a null-safe comparision (i.e. ( NULL = NULL ) = TRUE ||||'')

        IF l_do_processed_rows THEN
            CASE
                WHEN p_USE_PDH_KEYS_TO_JOIN THEN
                    EXECUTE IMMEDIATE l_sql_stmt
                        INTO l_return_value
                        USING G_DEFAULT_ATTR_GROUP_TYPE
                            , p_attr_group_type, p_attr_group_name, p_attr_name
                            , p_item_number, p_inventory_item_id, p_organization_id, p_batch_id
                            , p_request_id
                            , l_revision_code
                        ;
                WHEN NOT p_USE_PDH_KEYS_TO_JOIN THEN
                    EXECUTE IMMEDIATE l_sql_stmt
                        INTO l_return_value
                        USING G_DEFAULT_ATTR_GROUP_TYPE
                            , p_attr_group_type, p_attr_group_name, p_attr_name
                            , p_source_system_reference, p_source_system_id, p_organization_id, p_batch_id
                            , p_request_id
                            , l_revision_code
                        ;
            END CASE;
        ELSE -- unprocessed rows
            CASE
                WHEN p_USE_PDH_KEYS_TO_JOIN THEN
                    EXECUTE IMMEDIATE l_sql_stmt
                        INTO l_return_value
                        USING G_DEFAULT_ATTR_GROUP_TYPE
                            , p_attr_group_type, p_attr_group_name, p_attr_name
                            , p_item_number, p_inventory_item_id, p_organization_id, p_batch_id
                            , l_revision_code
                        ;
                WHEN NOT p_USE_PDH_KEYS_TO_JOIN THEN
                    EXECUTE IMMEDIATE l_sql_stmt
                        INTO l_return_value
                        USING G_DEFAULT_ATTR_GROUP_TYPE
                            , p_attr_group_type, p_attr_group_name, p_attr_name
                            , p_source_system_reference, p_source_system_id, p_organization_id, p_batch_id
                            , l_revision_code
                        ;
            END CASE;
        END IF;

        RETURN l_return_value;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN -- this attribute is not present in the interface table !
            RETURN l_return_value;
        WHEN OTHERS THEN
            -- XXX: Log the error here?
            RETURN l_return_value;
    END GET_REV_USR_ATTR_TO_CHAR;

    FUNCTION GET_REV_USR_ATTR_SS_DISP
        (
          p_batch_id                        IN  EGO_ITM_USR_ATTR_INTRFC.DATA_SET_ID%TYPE
        , p_source_system_id                IN  EGO_ITM_USR_ATTR_INTRFC.SOURCE_SYSTEM_ID%TYPE
        , p_source_system_reference         IN  EGO_ITM_USR_ATTR_INTRFC.SOURCE_SYSTEM_REFERENCE%TYPE
        , p_organization_id                 IN  EGO_ITM_USR_ATTR_INTRFC.ORGANIZATION_ID%TYPE
        , p_revision_code                   IN  EGO_ITM_USR_ATTR_INTRFC.REVISION%TYPE
        , p_attr_group_type                 IN  EGO_ITM_USR_ATTR_INTRFC.ATTR_GROUP_TYPE%TYPE
        , p_attr_group_name                 IN  EGO_ITM_USR_ATTR_INTRFC.ATTR_GROUP_INT_NAME%TYPE
        , p_attr_name                       IN  EGO_ITM_USR_ATTR_INTRFC.ATTR_INT_NAME%TYPE
        , p_attr_type                       IN  FLAG
        , p_from_internal_column            IN  FLAG
        , p_do_processed_rows_flag          IN  FLAG                                    DEFAULT FND_API.G_FALSE
        , p_request_id                      IN  EGO_ITM_USR_ATTR_INTRFC.REQUEST_ID%TYPE DEFAULT NULL
        )
    RETURN EGO_ITM_USR_ATTR_INTRFC.ATTR_DISP_VALUE%TYPE
    IS
        l_get_value_col BOOLEAN := ( FND_API.G_TRUE = p_from_internal_column );
    BEGIN
        RETURN GET_REV_USR_ATTR_TO_CHAR
        (
          p_batch_id                        => p_batch_id
        , p_source_system_id                => p_source_system_id
        , p_source_system_reference         => p_source_system_reference
        , p_organization_id                 => p_organization_id
        , p_revision_code                   => p_revision_code
        , p_attr_group_type                 => p_attr_group_type
        , p_attr_group_name                 => p_attr_group_name
        , p_attr_name                       => p_attr_name
        , p_attr_type                       => p_attr_type
        , p_do_processed_rows_flag          => p_do_processed_rows_flag
        , p_request_id                      => p_request_id
        , p_use_pdh_keys_to_join            => FALSE
        , p_get_value_col                   => l_get_value_col
        , p_attr_miss_value                 => FALSE -- returns value set miss value if get_value_column TRUE
        );
    END;

    FUNCTION GET_REV_USR_ATTR_PDH_DISP
        (
          p_batch_id                        IN  EGO_ITM_USR_ATTR_INTRFC.DATA_SET_ID%TYPE
        , p_inventory_item_id               IN  EGO_ITM_USR_ATTR_INTRFC.INVENTORY_ITEM_ID%TYPE
        , p_item_number                     IN  EGO_ITM_USR_ATTR_INTRFC.ITEM_NUMBER%TYPE
        , p_organization_id                 IN  EGO_ITM_USR_ATTR_INTRFC.ORGANIZATION_ID%TYPE
        , p_revision_code                   IN  EGO_ITM_USR_ATTR_INTRFC.REVISION%TYPE
        , p_attr_group_type                 IN  EGO_ITM_USR_ATTR_INTRFC.ATTR_GROUP_TYPE%TYPE
        , p_attr_group_name                 IN  EGO_ITM_USR_ATTR_INTRFC.ATTR_GROUP_INT_NAME%TYPE
        , p_attr_name                       IN  EGO_ITM_USR_ATTR_INTRFC.ATTR_INT_NAME%TYPE
        , p_attr_type                       IN  FLAG
        , p_from_internal_column            IN  FLAG
        , p_do_processed_rows_flag          IN  FLAG                                    DEFAULT FND_API.G_FALSE
        , p_request_id                      IN  EGO_ITM_USR_ATTR_INTRFC.REQUEST_ID%TYPE DEFAULT NULL
        )
    RETURN EGO_ITM_USR_ATTR_INTRFC.ATTR_DISP_VALUE%TYPE
    IS
        l_get_value_col BOOLEAN := ( FND_API.G_TRUE = p_from_internal_column );
    BEGIN
        RETURN GET_REV_USR_ATTR_TO_CHAR
        (
          p_batch_id                        => p_batch_id
        , p_inventory_item_id               => p_inventory_item_id
        , p_item_number                     => p_item_number
        , p_organization_id                 => p_organization_id
        , p_revision_code                   => p_revision_code
        , p_attr_group_type                 => p_attr_group_type
        , p_attr_group_name                 => p_attr_group_name
        , p_attr_name                       => p_attr_name
        , p_attr_type                       => p_attr_type
        , p_do_processed_rows_flag          => p_do_processed_rows_flag
        , p_request_id                      => p_request_id
        , p_use_pdh_keys_to_join            => TRUE
        , p_get_value_col                   => l_get_value_col
        , p_attr_miss_value                 => FALSE -- returns value set miss value if get_value_column TRUE
        );
    END;


    ----------------------------------------------------------------------------------------------
    --  Function GET_REV_USR_ATTR_DISP_DATE
    --  Returns the date value of the specified revision attribute, if the attribute is present
    --  in the interface table, merging in an attempted conversion of the display column content.
    ----------------------------------------------------------------------------------------------
    FUNCTION GET_REV_USR_ATTR_DATE
        (
          p_batch_id                        IN  EGO_ITM_USR_ATTR_INTRFC.DATA_SET_ID%TYPE
        , p_source_system_id                IN  EGO_ITM_USR_ATTR_INTRFC.SOURCE_SYSTEM_ID%TYPE           DEFAULT NULL
        , p_source_system_reference         IN  EGO_ITM_USR_ATTR_INTRFC.SOURCE_SYSTEM_REFERENCE%TYPE    DEFAULT NULL
        , p_organization_id                 IN  EGO_ITM_USR_ATTR_INTRFC.ORGANIZATION_ID%TYPE
        , p_revision_code                   IN  EGO_ITM_USR_ATTR_INTRFC.REVISION%TYPE
        , p_attr_group_type                 IN  EGO_ITM_USR_ATTR_INTRFC.ATTR_GROUP_TYPE%TYPE
        , p_attr_group_name                 IN  EGO_ITM_USR_ATTR_INTRFC.ATTR_GROUP_INT_NAME%TYPE
        , p_attr_name                       IN  EGO_ITM_USR_ATTR_INTRFC.ATTR_INT_NAME%TYPE
        , p_do_processed_rows_flag          IN  FLAG DEFAULT FND_API.G_FALSE
        , p_request_id                      IN  EGO_ITM_USR_ATTR_INTRFC.REQUEST_ID%TYPE                 DEFAULT NULL
        , p_inventory_item_id               IN  EGO_ITM_USR_ATTR_INTRFC.INVENTORY_ITEM_ID%TYPE          DEFAULT NULL
        , p_item_number                     IN  EGO_ITM_USR_ATTR_INTRFC.ITEM_NUMBER%TYPE                DEFAULT NULL
        , p_use_pdh_keys_to_join            IN  BOOLEAN
        , p_get_value_column                IN  BOOLEAN
        )
    RETURN EGO_ITM_USR_ATTR_INTRFC.ATTR_VALUE_DATE%TYPE
    IS
        l_return_value      EGO_ITM_USR_ATTR_INTRFC.ATTR_VALUE_DATE%TYPE;
        l_revision_code     EGO_ITM_USR_ATTR_INTRFC.REVISION%TYPE;
        l_sql_stmt          VARCHAR2( 32000 );
        l_do_procd_rows_sql VARCHAR2( 200 );
        l_join_sql          VARCHAR2( 200 );
        l_select_sql        VARCHAR2( 300 );
        l_do_processed_rows BOOLEAN;
    BEGIN
        l_return_value  := null; -- 'default';

        CASE -- order of WHEN clauses matters!
            WHEN p_USE_PDH_KEYS_TO_JOIN AND
                 p_inventory_item_id IS NULL AND
                 p_item_number IS NULL
                THEN RETURN l_return_value;
            WHEN p_USE_PDH_KEYS_TO_JOIN THEN
                l_join_sql :=
                    ' AND ( ( '
                ||  CASE
                    WHEN p_inventory_item_id IS NOT NULL THEN
                            ' EIUAI.INVENTORY_ITEM_ID     IS NULL AND'
                    ELSE    ''
                    END
                ||          ' EIUAI.ITEM_NUMBER           = :item_number '
                ||          ' ) '
                ||      ' OR  EIUAI.INVENTORY_ITEM_ID     = :item_id '
                ||      ' ) '
                ;
            WHEN p_source_system_reference IS NULL AND
                 p_source_system_id IS NULL
                 THEN RETURN l_return_value;
            ELSE
                l_join_sql := ' AND EIUAI.SOURCE_SYSTEM_REFERENCE   = :ss_ref '
                           || ' AND EIUAI.SOURCE_SYSTEM_ID          = :ss_id ';
        END CASE;

        l_do_processed_rows := ( p_do_processed_rows_flag = FND_API.G_TRUE );
        l_do_procd_rows_sql :=  ' AND EIUAI.PROCESS_STATUS'
                            ||  CASE
                                WHEN l_do_processed_rows                                    THEN ' IN ( 3, 4 ) AND EIUAI.REQUEST_ID = :req_id '
                                WHEN NOT l_do_processed_rows AND NOT p_use_pdh_keys_to_join THEN ' = 0 '
                                WHEN NOT l_do_processed_rows AND p_use_pdh_keys_to_join     THEN ' = 1 '
                                ELSE ''   -- XXX: hmmm, raise exception here?
                                END;

        IF p_get_value_column THEN
            l_select_sql    := ' EIUAI.ATTR_VALUE_DATE ';
        ELSE
            l_select_sql    :=  ' NVL2( EIUAI.ATTR_DISP_VALUE '
                                ||  ' , EGO_IMPORT_PVT.wrapped_to_date( EIUAI.ATTR_DISP_VALUE ) '
                                ||  ' , CASE WHEN EIUAI.ATTR_VALUE_DATE IS NULL '
                                           || 'OR EIUAI.ATTR_VALUE_DATE = TO_DATE(''1'',''J'') THEN ' || G_EXCEL_MISS_DATE_STR
                                        || ' ELSE EIUAI.ATTR_VALUE_DATE END'
                                ||  ' ) '
                            ;
        END IF;

        -- Check to see whether the revision code has been provided:
        -- If not, default it to be the code of the latest LOGICAL revision row
        l_revision_code :=
            CASE -- order of WHEN clauses matters!
            WHEN p_revision_code IS NOT NULL THEN p_revision_code
            WHEN p_use_pdh_keys_to_join THEN
                GET_LATEST_EIUAI_REV_PDH(   p_batch_id                  => p_batch_id
                                        ,   p_inventory_item_id         => p_inventory_item_id
                                        ,   p_item_number               => p_item_number
                                        ,   p_organization_id           => p_organization_id
                                        ,   p_do_processed_rows_flag    => p_do_processed_rows_flag
                                        ,   p_request_id                => p_request_id
                                        )
            ELSE
                GET_LATEST_EIUAI_REV_SS (   p_batch_id                  => p_batch_id
                                        ,   p_source_system_id          => p_source_system_id
                                        ,   p_source_system_reference   => p_source_system_reference
                                        ,   p_organization_id           => p_organization_id
                                        ,   p_do_processed_rows_flag    => p_do_processed_rows_flag
                                        ,   p_request_id                => p_request_id
                                        )
            END;

        l_sql_stmt := '
            SELECT ' || l_select_sql
        ||' FROM EGO_ITM_USR_ATTR_INTRFC EIUAI '
        ||' WHERE '
            ||' NVL( EIUAI.ATTR_GROUP_TYPE, :default_attr_grp ) = :attr_grp_type'
            ||' AND EIUAI.ATTR_GROUP_INT_NAME       = :attr_grp'
            ||' AND EIUAI.ATTR_INT_NAME             = :attr '
                || l_join_sql
            ||' AND EIUAI.ORGANIZATION_ID           = :org_id '
            ||' AND EIUAI.DATA_SET_ID               = :batch_id '
                || l_do_procd_rows_sql
            ||' AND DECODE( EIUAI.REVISION, :rev_code, 1, 0 ) = 1 '
            ||' AND rownum = 1 '
            ;
            -- note that decode does a null-safe comparision (i.e. ( NULL = NULL ) = TRUE ||||'')

--      my_put_line( 'sql:' || l_sql_stmt );

        IF l_do_processed_rows THEN
            CASE
                WHEN p_USE_PDH_KEYS_TO_JOIN THEN
                    EXECUTE IMMEDIATE l_sql_stmt
                        INTO l_return_value
                        USING G_DEFAULT_ATTR_GROUP_TYPE
                            , p_attr_group_type, p_attr_group_name, p_attr_name
                            , p_item_number, p_inventory_item_id, p_organization_id, p_batch_id
                            , p_request_id
                            , l_revision_code
                        ;
                WHEN NOT p_USE_PDH_KEYS_TO_JOIN THEN
                    EXECUTE IMMEDIATE l_sql_stmt
                        INTO l_return_value
                        USING G_DEFAULT_ATTR_GROUP_TYPE
                            , p_attr_group_type, p_attr_group_name, p_attr_name
                            , p_source_system_reference, p_source_system_id, p_organization_id, p_batch_id
                            , p_request_id
                            , l_revision_code
                        ;
            END CASE;
        ELSE -- unprocessed rows
            CASE
                WHEN p_USE_PDH_KEYS_TO_JOIN THEN
                    EXECUTE IMMEDIATE l_sql_stmt
                        INTO l_return_value
                        USING G_DEFAULT_ATTR_GROUP_TYPE
                            , p_attr_group_type, p_attr_group_name, p_attr_name
                            , p_item_number, p_inventory_item_id, p_organization_id, p_batch_id
                            , l_revision_code
                        ;
                WHEN NOT p_USE_PDH_KEYS_TO_JOIN THEN
                    EXECUTE IMMEDIATE l_sql_stmt
                        INTO l_return_value
                        USING G_DEFAULT_ATTR_GROUP_TYPE
                            , p_attr_group_type, p_attr_group_name, p_attr_name
                            , p_source_system_reference, p_source_system_id, p_organization_id, p_batch_id
                            , l_revision_code
                        ;
            END CASE;
        END IF;

        RETURN l_return_value;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN -- this attribute is not present in the interface table !
            RETURN l_return_value;
        WHEN OTHERS THEN
--          MY_PUT_LINE( 'GET_REV_USR_ATTR_DATE Error code ' || SQLCODE || ': ' || SQLERRM );
            RETURN l_return_value;
    END GET_REV_USR_ATTR_DATE;

    FUNCTION GET_REV_USR_ATTR_SS_DDATE
        (
        p_batch_id                          IN  EGO_ITM_USR_ATTR_INTRFC.DATA_SET_ID%TYPE
        , p_source_system_id                IN  EGO_ITM_USR_ATTR_INTRFC.SOURCE_SYSTEM_ID%TYPE
        , p_source_system_reference         IN  EGO_ITM_USR_ATTR_INTRFC.SOURCE_SYSTEM_REFERENCE%TYPE
        , p_organization_id                 IN  EGO_ITM_USR_ATTR_INTRFC.ORGANIZATION_ID%TYPE
        , p_revision_code                   IN  EGO_ITM_USR_ATTR_INTRFC.REVISION%TYPE
        , p_attr_group_type                 IN  EGO_ITM_USR_ATTR_INTRFC.ATTR_GROUP_TYPE%TYPE
        , p_attr_group_name                 IN  EGO_ITM_USR_ATTR_INTRFC.ATTR_GROUP_INT_NAME%TYPE
        , p_attr_name                       IN  EGO_ITM_USR_ATTR_INTRFC.ATTR_INT_NAME%TYPE
        , p_do_processed_rows_flag          IN  FLAG                                DEFAULT FND_API.G_FALSE
        ,   p_request_id                    IN  EGO_ITM_USR_ATTR_INTRFC.REQUEST_ID%TYPE                 DEFAULT NULL
        )
    RETURN EGO_ITM_USR_ATTR_INTRFC.ATTR_VALUE_DATE%TYPE IS
    BEGIN
        RETURN GET_REV_USR_ATTR_DATE
        (
          p_batch_id                        => p_batch_id
        , p_source_system_id                => p_source_system_id
        , p_source_system_reference         => p_source_system_reference
        , p_organization_id                 => p_organization_id
        , p_revision_code                   => p_revision_code
        , p_attr_group_type                 => p_attr_group_type
        , p_attr_group_name                 => p_attr_group_name
        , p_attr_name                       => p_attr_name
        , p_do_processed_rows_flag          => p_do_processed_rows_flag
        , p_request_id                      => p_request_id
        , p_use_pdh_keys_to_join            => false
        , p_get_value_column                => false
        );
    END GET_REV_USR_ATTR_SS_DDATE;

    FUNCTION GET_REV_USR_ATTR_PDH_DDATE
        (   p_batch_id                      IN  EGO_ITM_USR_ATTR_INTRFC.DATA_SET_ID%TYPE
        ,   p_inventory_item_id             IN  EGO_ITM_USR_ATTR_INTRFC.INVENTORY_ITEM_ID%TYPE
        ,   p_item_number                   IN  EGO_ITM_USR_ATTR_INTRFC.ITEM_NUMBER%TYPE
        ,   p_organization_id               IN  EGO_ITM_USR_ATTR_INTRFC.ORGANIZATION_ID%TYPE
        ,   p_revision_code                 IN  EGO_ITM_USR_ATTR_INTRFC.REVISION%TYPE
        ,   p_attr_group_type               IN  EGO_ITM_USR_ATTR_INTRFC.ATTR_GROUP_TYPE%TYPE
        ,   p_attr_group_name               IN  EGO_ITM_USR_ATTR_INTRFC.ATTR_GROUP_INT_NAME%TYPE
        ,   p_attr_name                     IN  EGO_ITM_USR_ATTR_INTRFC.ATTR_INT_NAME%TYPE
        ,   p_do_processed_rows_flag        IN  FLAG                                DEFAULT FND_API.G_FALSE
        ,   p_request_id                    IN  EGO_ITM_USR_ATTR_INTRFC.REQUEST_ID%TYPE                 DEFAULT NULL
        )
    RETURN EGO_ITM_USR_ATTR_INTRFC.ATTR_VALUE_DATE%TYPE IS
    BEGIN
        RETURN GET_REV_USR_ATTR_DATE
        (
          p_batch_id                        => p_batch_id
        , p_inventory_item_id               => p_inventory_item_id
        , p_item_number                     => p_item_number
        , p_organization_id                 => p_organization_id
        , p_revision_code                   => p_revision_code
        , p_attr_group_type                 => p_attr_group_type
        , p_attr_group_name                 => p_attr_group_name
        , p_attr_name                       => p_attr_name
        , p_do_processed_rows_flag          => p_do_processed_rows_flag
        , p_request_id                      => p_request_id
        , p_use_pdh_keys_to_join            => true
        , p_get_value_column                => false
        );
    END GET_REV_USR_ATTR_PDH_DDATE;

    ----------------------------------------------------------------------------------------------
    --  Function GET_REV_USR_ATTR_DISP_STR
    --  Returns the string value of the specified revision attribute, if the attribute is present
    --  in the interface table, merging in an attempted conversion of the display column content.
    ----------------------------------------------------------------------------------------------
    FUNCTION GET_REV_USR_ATTR_STR
        (   p_batch_id                      IN  EGO_ITM_USR_ATTR_INTRFC.DATA_SET_ID%TYPE
        ,   p_source_system_id              IN  EGO_ITM_USR_ATTR_INTRFC.SOURCE_SYSTEM_ID%TYPE           DEFAULT NULL
        ,   p_source_system_reference       IN  EGO_ITM_USR_ATTR_INTRFC.SOURCE_SYSTEM_REFERENCE%TYPE    DEFAULT NULL
        ,   p_organization_id               IN  EGO_ITM_USR_ATTR_INTRFC.ORGANIZATION_ID%TYPE
        ,   p_revision_code                 IN  EGO_ITM_USR_ATTR_INTRFC.REVISION%TYPE
        ,   p_attr_group_type               IN  EGO_ITM_USR_ATTR_INTRFC.ATTR_GROUP_TYPE%TYPE
        ,   p_attr_group_name               IN  EGO_ITM_USR_ATTR_INTRFC.ATTR_GROUP_INT_NAME%TYPE
        ,   p_attr_name                     IN  EGO_ITM_USR_ATTR_INTRFC.ATTR_INT_NAME%TYPE
        ,   p_do_processed_rows_flag        IN  FLAG                                                    DEFAULT FND_API.G_FALSE
        ,   p_request_id                    IN  EGO_ITM_USR_ATTR_INTRFC.REQUEST_ID%TYPE                 DEFAULT NULL
        ,   p_inventory_item_id             IN  EGO_ITM_USR_ATTR_INTRFC.INVENTORY_ITEM_ID%TYPE          DEFAULT NULL
        ,   p_item_number                   IN  EGO_ITM_USR_ATTR_INTRFC.ITEM_NUMBER%TYPE                DEFAULT NULL
        ,   p_use_pdh_keys_to_join          IN  BOOLEAN
        ,   p_get_value_column              IN  BOOLEAN
        )
    RETURN EGO_ITM_USR_ATTR_INTRFC.ATTR_VALUE_STR%TYPE
    IS
        l_return_value      EGO_ITM_USR_ATTR_INTRFC.ATTR_VALUE_STR%TYPE;
        l_revision_code     EGO_ITM_USR_ATTR_INTRFC.REVISION%TYPE;
        l_sql_stmt          VARCHAR2( 32000 );
        l_do_procd_rows_sql VARCHAR2( 200 );
        l_join_sql          VARCHAR2( 200 );
        l_select_sql        VARCHAR2( 200 );
        l_do_processed_rows BOOLEAN;
    BEGIN
        l_return_value  := null; -- 'default';

        CASE -- order of WHEN clauses matters!
            WHEN p_USE_PDH_KEYS_TO_JOIN AND
                 p_inventory_item_id IS NULL AND
                 p_item_number IS NULL
                THEN RETURN l_return_value;
            WHEN p_USE_PDH_KEYS_TO_JOIN THEN
                l_join_sql :=
                    ' AND ( ( '
                ||  CASE
                    WHEN p_inventory_item_id IS NOT NULL THEN
                            ' EIUAI.INVENTORY_ITEM_ID     IS NULL AND'
                    ELSE    ''
                    END
                ||          ' EIUAI.ITEM_NUMBER           = :item_number '
                ||          ' ) '
                ||      ' OR  EIUAI.INVENTORY_ITEM_ID     = :item_id '
                ||      ' ) '
                ;
            WHEN p_source_system_reference IS NULL AND
                 p_source_system_id IS NULL
                 THEN RETURN l_return_value;
            ELSE
                l_join_sql := '
                    AND EIUAI.SOURCE_SYSTEM_REFERENCE   = :ss_ref
                    AND EIUAI.SOURCE_SYSTEM_ID          = :ss_id ';
        END CASE;

        l_do_processed_rows := ( p_do_processed_rows_flag = FND_API.G_TRUE );
        l_do_procd_rows_sql :=  ' AND EIUAI.PROCESS_STATUS'
                            ||  CASE
                                WHEN l_do_processed_rows                                    THEN ' IN ( 3, 4 ) AND EIUAI.REQUEST_ID = :req_id '
                                WHEN NOT l_do_processed_rows AND NOT p_use_pdh_keys_to_join THEN ' = 0 '
                                WHEN NOT l_do_processed_rows AND p_use_pdh_keys_to_join     THEN ' = 1 '
                                ELSE ''   -- XXX: hmmm, raise exception here?
                                END;

        IF p_get_value_column THEN
            l_select_sql := ' EIUAI.ATTR_VALUE_STR ';
        ELSE
            l_select_sql := ' COALESCE( EIUAI.ATTR_DISP_VALUE, EIUAI.ATTR_VALUE_STR, '''|| G_EXCEL_MISS_CHAR_VAL ||''' ) ';
        END IF;

        -- Check to see whether the revision code has been provided:
        -- If not, default it to be the code of the latest LOGICAL revision row
        l_revision_code :=
            CASE -- order of WHEN clauses matters!
            WHEN p_revision_code IS NOT NULL THEN p_revision_code
            WHEN p_use_pdh_keys_to_join THEN
                GET_LATEST_EIUAI_REV_PDH(   p_batch_id                  => p_batch_id
                                        ,   p_inventory_item_id         => p_inventory_item_id
                                        ,   p_item_number               => p_item_number
                                        ,   p_organization_id           => p_organization_id
                                        ,   p_do_processed_rows_flag    => p_do_processed_rows_flag
                                        ,   p_request_id                => p_request_id
                                        )
            ELSE
                GET_LATEST_EIUAI_REV_SS (   p_batch_id                  => p_batch_id
                                        ,   p_source_system_id          => p_source_system_id
                                        ,   p_source_system_reference   => p_source_system_reference
                                        ,   p_organization_id           => p_organization_id
                                        ,   p_do_processed_rows_flag    => p_do_processed_rows_flag
                                        ,   p_request_id                => p_request_id
                                        )
            END;

        l_sql_stmt := '
            SELECT ' || l_select_sql
            || '
            FROM EGO_ITM_USR_ATTR_INTRFC EIUAI
            WHERE
                NVL( EIUAI.ATTR_GROUP_TYPE, :default_attr_grp ) = :attr_grp_type
                AND EIUAI.ATTR_GROUP_INT_NAME       = :attr_grp
                AND EIUAI.ATTR_INT_NAME             = :attr '
                || l_join_sql
                || '
                AND EIUAI.ORGANIZATION_ID           = :org_id
                AND EIUAI.DATA_SET_ID               = :batch_id '
                ||  l_do_procd_rows_sql
/*                ||  '
                AND EIUAI.REVISION '
                ||  CASE l_revision_code
                    WHEN NULL THEN 'IS NULL '
                    ELSE '= :rev_code '
                    END */
                || '
                AND DECODE( EIUAI.REVISION, :rev_code, 1, 0 ) = 1
                AND rownum = 1
            ';

--        my_put_line( l_sql_stmt );

        CASE
            WHEN l_do_processed_rows AND p_USE_PDH_KEYS_TO_JOIN THEN
                EXECUTE IMMEDIATE l_sql_stmt
                    INTO l_return_value
                    USING G_DEFAULT_ATTR_GROUP_TYPE
                        , p_attr_group_type, p_attr_group_name, p_attr_name
                        , p_item_number, p_inventory_item_id, p_organization_id, p_batch_id
                        , p_request_id
                        , l_revision_code
                    ;
            WHEN l_do_processed_rows AND NOT p_USE_PDH_KEYS_TO_JOIN THEN
                EXECUTE IMMEDIATE l_sql_stmt
                    INTO l_return_value
                    USING G_DEFAULT_ATTR_GROUP_TYPE
                        , p_attr_group_type, p_attr_group_name, p_attr_name
                        , p_source_system_reference, p_source_system_id, p_organization_id, p_batch_id
                        , p_request_id
                        , l_revision_code
                    ;
            WHEN NOT l_do_processed_rows AND p_USE_PDH_KEYS_TO_JOIN THEN
                EXECUTE IMMEDIATE l_sql_stmt
                    INTO l_return_value
                    USING G_DEFAULT_ATTR_GROUP_TYPE
                        , p_attr_group_type, p_attr_group_name, p_attr_name
                        , p_item_number, p_inventory_item_id, p_organization_id, p_batch_id
                        , l_revision_code
                    ;
            WHEN NOT l_do_processed_rows AND NOT p_USE_PDH_KEYS_TO_JOIN THEN
                EXECUTE IMMEDIATE l_sql_stmt
                    INTO l_return_value
                    USING G_DEFAULT_ATTR_GROUP_TYPE
                        , p_attr_group_type, p_attr_group_name, p_attr_name
                        , p_source_system_reference, p_source_system_id, p_organization_id, p_batch_id
                        , l_revision_code
                    ;
        END CASE;
        RETURN l_return_value;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN -- this attribute is not present in the interface table !
            RETURN l_return_value;
        WHEN OTHERS THEN
--          MY_PUT_LINE( 'Error code ' || SQLCODE || ': ' || SQLERRM );
            RAISE;
    END GET_REV_USR_ATTR_STR;

    FUNCTION GET_REV_USR_ATTR_SS_DSTR
        (
        p_batch_id                          IN  EGO_ITM_USR_ATTR_INTRFC.DATA_SET_ID%TYPE
        , p_source_system_id                IN  EGO_ITM_USR_ATTR_INTRFC.SOURCE_SYSTEM_ID%TYPE
        , p_source_system_reference         IN  EGO_ITM_USR_ATTR_INTRFC.SOURCE_SYSTEM_REFERENCE%TYPE
        , p_organization_id                 IN  EGO_ITM_USR_ATTR_INTRFC.ORGANIZATION_ID%TYPE
        , p_revision_code                   IN  EGO_ITM_USR_ATTR_INTRFC.REVISION%TYPE
        , p_attr_group_type                 IN  EGO_ITM_USR_ATTR_INTRFC.ATTR_GROUP_TYPE%TYPE
        , p_attr_group_name                 IN  EGO_ITM_USR_ATTR_INTRFC.ATTR_GROUP_INT_NAME%TYPE
        , p_attr_name                       IN  EGO_ITM_USR_ATTR_INTRFC.ATTR_INT_NAME%TYPE
        , p_do_processed_rows_flag          IN  FLAG DEFAULT FND_API.G_FALSE
        ,   p_request_id                    IN  EGO_ITM_USR_ATTR_INTRFC.REQUEST_ID%TYPE                 DEFAULT NULL
        )
    RETURN EGO_ITM_USR_ATTR_INTRFC.ATTR_VALUE_STR%TYPE IS
    BEGIN
        RETURN GET_REV_USR_ATTR_STR
        (
          p_batch_id                        => p_batch_id
        , p_source_system_id                => p_source_system_id
        , p_source_system_reference         => p_source_system_reference
        , p_organization_id                 => p_organization_id
        , p_revision_code                   => p_revision_code
        , p_attr_group_type                 => p_attr_group_type
        , p_attr_group_name                 => p_attr_group_name
        , p_attr_name                       => p_attr_name
        , p_do_processed_rows_flag          => p_do_processed_rows_flag
        , p_request_id                      => p_request_id
        , p_use_pdh_keys_to_join            => false
        , p_get_value_column                => false
        );
    END GET_REV_USR_ATTR_SS_DSTR;

    FUNCTION GET_REV_USR_ATTR_PDH_DSTR
        (
        p_batch_id                          IN  EGO_ITM_USR_ATTR_INTRFC.DATA_SET_ID%TYPE
        , p_inventory_item_id               IN  EGO_ITM_USR_ATTR_INTRFC.INVENTORY_ITEM_ID%TYPE
        , p_item_number                     IN  EGO_ITM_USR_ATTR_INTRFC.ITEM_NUMBER%TYPE
        , p_organization_id                 IN  EGO_ITM_USR_ATTR_INTRFC.ORGANIZATION_ID%TYPE
        , p_revision_code                   IN  EGO_ITM_USR_ATTR_INTRFC.REVISION%TYPE
        , p_attr_group_type                 IN  EGO_ITM_USR_ATTR_INTRFC.ATTR_GROUP_TYPE%TYPE
        , p_attr_group_name                 IN  EGO_ITM_USR_ATTR_INTRFC.ATTR_GROUP_INT_NAME%TYPE
        , p_attr_name                       IN  EGO_ITM_USR_ATTR_INTRFC.ATTR_INT_NAME%TYPE
        , p_do_processed_rows_flag          IN  FLAG DEFAULT FND_API.G_FALSE
        ,   p_request_id                    IN  EGO_ITM_USR_ATTR_INTRFC.REQUEST_ID%TYPE                 DEFAULT NULL
        )
    RETURN EGO_ITM_USR_ATTR_INTRFC.ATTR_VALUE_STR%TYPE IS
    BEGIN
        RETURN GET_REV_USR_ATTR_STR
        (
          p_batch_id                        => p_batch_id
        , p_inventory_item_id               => p_inventory_item_id
        , p_item_number                     => p_item_number
        , p_organization_id                 => p_organization_id
        , p_revision_code                   => p_revision_code
        , p_attr_group_type                 => p_attr_group_type
        , p_attr_group_name                 => p_attr_group_name
        , p_attr_name                       => p_attr_name
        , p_do_processed_rows_flag          => p_do_processed_rows_flag
        , p_request_id                      => p_request_id
        , p_use_pdh_keys_to_join            => true
        , p_get_value_column                => false
        );
    END GET_REV_USR_ATTR_PDH_DSTR;

    ----------------------------------------------------------------------------------------------
    --  Function GET_REV_USR_ATTR_DISP_NUM
    --  Returns the number value of the specified revision attribute, if the attribute is present
    --  in the interface table, merging in an attempted conversion of the display column content.
    --------------------------------------------------------------------------------------------
    FUNCTION GET_REV_USR_ATTR_NUM
        (
        p_batch_id                          IN  EGO_ITM_USR_ATTR_INTRFC.DATA_SET_ID%TYPE
        , p_source_system_id                IN  EGO_ITM_USR_ATTR_INTRFC.SOURCE_SYSTEM_ID%TYPE           DEFAULT NULL
        , p_source_system_reference         IN  EGO_ITM_USR_ATTR_INTRFC.SOURCE_SYSTEM_REFERENCE%TYPE    DEFAULT NULL
        , p_organization_id                 IN  EGO_ITM_USR_ATTR_INTRFC.ORGANIZATION_ID%TYPE
        , p_revision_code                   IN  EGO_ITM_USR_ATTR_INTRFC.REVISION%TYPE
        , p_attr_group_type                 IN  EGO_ITM_USR_ATTR_INTRFC.ATTR_GROUP_TYPE%TYPE
        , p_attr_group_name                 IN  EGO_ITM_USR_ATTR_INTRFC.ATTR_GROUP_INT_NAME%TYPE
        , p_attr_name                       IN  EGO_ITM_USR_ATTR_INTRFC.ATTR_INT_NAME%TYPE
        , p_output_uom_code                 IN  EGO_ITM_USR_ATTR_INTRFC.ATTR_VALUE_UOM%TYPE             DEFAULT NULL
        , p_do_processed_rows_flag          IN  FLAG DEFAULT FND_API.G_FALSE
        , p_request_id                      IN  EGO_ITM_USR_ATTR_INTRFC.REQUEST_ID%TYPE                 DEFAULT NULL
        , p_inventory_item_id               IN  EGO_ITM_USR_ATTR_INTRFC.INVENTORY_ITEM_ID%TYPE          DEFAULT NULL
        , p_item_number                     IN  EGO_ITM_USR_ATTR_INTRFC.ITEM_NUMBER%TYPE                DEFAULT NULL
        , p_use_pdh_keys_to_join            IN  BOOLEAN
        , p_get_value_column                IN  BOOLEAN
        )
    RETURN EGO_ITM_USR_ATTR_INTRFC.ATTR_VALUE_NUM%TYPE
    IS
        l_return_value      EGO_ITM_USR_ATTR_INTRFC.ATTR_VALUE_NUM%TYPE;
        l_num_value         EGO_ITM_USR_ATTR_INTRFC.ATTR_VALUE_NUM%TYPE;
        l_revision_code     EGO_ITM_USR_ATTR_INTRFC.REVISION%TYPE;
        l_sql_stmt          VARCHAR2( 32000 );
        l_do_procd_rows_sql VARCHAR2( 200 );
        l_join_sql          VARCHAR2( 200 );
        l_select_sql        VARCHAR2( 200 );
        l_do_processed_rows BOOLEAN;

        l_uom_code          EGO_ITM_USR_ATTR_INTRFC.ATTR_VALUE_UOM%TYPE;
        l_uom_disp_value    EGO_ITM_USR_ATTR_INTRFC.ATTR_UOM_DISP_VALUE%TYPE;
        l_uom_rate          NUMBER := 1;
    BEGIN
        l_return_value  := null; -- 'default';

        CASE -- order of WHEN clauses matters!
            WHEN p_USE_PDH_KEYS_TO_JOIN AND
                 p_inventory_item_id IS NULL AND
                 p_item_number IS NULL
                THEN RETURN l_return_value;
            WHEN p_USE_PDH_KEYS_TO_JOIN THEN
                l_join_sql :=
                    ' AND ( ( '
                ||  CASE
                    WHEN p_inventory_item_id IS NOT NULL THEN
                            ' EIUAI.INVENTORY_ITEM_ID     IS NULL AND'
                    ELSE    ''
                    END
                ||          ' EIUAI.ITEM_NUMBER           = :item_number '
                ||          ' ) '
                ||      ' OR  EIUAI.INVENTORY_ITEM_ID     = :item_id '
                ||      ' ) '
                ;
            WHEN p_source_system_reference IS NULL AND
                 p_source_system_id IS NULL
                 THEN RETURN l_return_value;
            ELSE
                l_join_sql := ' AND EIUAI.SOURCE_SYSTEM_REFERENCE   = :ss_ref '
                           || ' AND EIUAI.SOURCE_SYSTEM_ID          = :ss_id ';
        END CASE;

        l_do_processed_rows := ( p_do_processed_rows_flag = FND_API.G_TRUE );
        l_do_procd_rows_sql :=  ' AND EIUAI.PROCESS_STATUS'
                            ||  CASE
                                WHEN l_do_processed_rows                                    THEN ' IN ( 3, 4 ) AND EIUAI.REQUEST_ID = :req_id '
                                WHEN NOT l_do_processed_rows AND NOT p_use_pdh_keys_to_join THEN ' = 0 '
                                WHEN NOT l_do_processed_rows AND p_use_pdh_keys_to_join     THEN ' = 1 '
                                ELSE ''   -- XXX: hmmm, raise exception here?
                                END;

        IF p_get_value_column THEN
            l_select_sql    := ' EIUAI.ATTR_VALUE_NUM ';
        ELSE
            l_select_sql    :=  ' NVL2( EIUAI.ATTR_DISP_VALUE '
                                ||  ' , to_number( EIUAI.ATTR_DISP_VALUE ) '
                                ||  ' , NVL( EIUAI.ATTR_VALUE_NUM, ' || G_EXCEL_MISS_NUM_STR
                                ||  ' ) ) '
                            ;
        END IF;

        -- Check to see whether the revision code has been provided:
        -- If not, default it to be the code of the latest LOGICAL revision row
        l_revision_code :=
            CASE -- order of WHEN clauses matters!
            WHEN p_revision_code IS NOT NULL THEN p_revision_code
            WHEN p_use_pdh_keys_to_join THEN
                GET_LATEST_EIUAI_REV_PDH(   p_batch_id                  => p_batch_id
                                        ,   p_inventory_item_id         => p_inventory_item_id
                                        ,   p_item_number               => p_item_number
                                        ,   p_organization_id           => p_organization_id
                                        ,   p_do_processed_rows_flag    => p_do_processed_rows_flag
                                        ,   p_request_id                => p_request_id
                                        )
            ELSE
                GET_LATEST_EIUAI_REV_SS (   p_batch_id                  => p_batch_id
                                        ,   p_source_system_id          => p_source_system_id
                                        ,   p_source_system_reference   => p_source_system_reference
                                        ,   p_organization_id           => p_organization_id
                                        ,   p_do_processed_rows_flag    => p_do_processed_rows_flag
                                        ,   p_request_id                => p_request_id
                                        )
            END;

        l_sql_stmt := '
            SELECT ' || l_select_sql
            || ', ATTR_VALUE_UOM
                , ATTR_UOM_DISP_VALUE
            FROM EGO_ITM_USR_ATTR_INTRFC EIUAI
            WHERE
                NVL( EIUAI.ATTR_GROUP_TYPE, :default_attr_grp ) = :attr_grp_type
                AND EIUAI.ATTR_GROUP_INT_NAME       = :attr_grp
                AND EIUAI.ATTR_INT_NAME             = :attr '
                || l_join_sql
                || '
                AND EIUAI.ORGANIZATION_ID           = :org_id
                AND EIUAI.DATA_SET_ID               = :batch_id '
                ||  l_do_procd_rows_sql
                || '
                AND DECODE( EIUAI.REVISION, :rev_code, 1, 0 ) = 1
                AND rownum = 1
            ';

--      my_put_line( l_sql_stmt );

        CASE
            WHEN l_do_processed_rows AND p_USE_PDH_KEYS_TO_JOIN THEN
                EXECUTE IMMEDIATE l_sql_stmt
                    INTO l_num_value, l_uom_code, l_uom_disp_value
                    USING G_DEFAULT_ATTR_GROUP_TYPE
                        , p_attr_group_type, p_attr_group_name, p_attr_name
                        , p_item_number, p_inventory_item_id, p_organization_id, p_batch_id
                        , p_request_id
                        , l_revision_code
                    ;
            WHEN l_do_processed_rows AND NOT p_USE_PDH_KEYS_TO_JOIN THEN
                EXECUTE IMMEDIATE l_sql_stmt
                    INTO l_num_value, l_uom_code, l_uom_disp_value
                    USING G_DEFAULT_ATTR_GROUP_TYPE
                        , p_attr_group_type, p_attr_group_name, p_attr_name
                        , p_source_system_reference, p_source_system_id, p_organization_id, p_batch_id
                        , p_request_id
                        , l_revision_code
                    ;
            WHEN NOT l_do_processed_rows AND p_USE_PDH_KEYS_TO_JOIN THEN
                EXECUTE IMMEDIATE l_sql_stmt
                    INTO l_num_value, l_uom_code, l_uom_disp_value
                    USING G_DEFAULT_ATTR_GROUP_TYPE
                        , p_attr_group_type, p_attr_group_name, p_attr_name
                        , p_item_number, p_inventory_item_id, p_organization_id, p_batch_id
                        , l_revision_code
                    ;
            WHEN NOT l_do_processed_rows AND NOT p_USE_PDH_KEYS_TO_JOIN THEN
                EXECUTE IMMEDIATE l_sql_stmt
                    INTO l_num_value, l_uom_code, l_uom_disp_value
                    USING G_DEFAULT_ATTR_GROUP_TYPE
                        , p_attr_group_type, p_attr_group_name, p_attr_name
                        , p_source_system_reference, p_source_system_id, p_organization_id, p_batch_id
                        , l_revision_code
                    ;
        END CASE;

        -- perform a uom conversion if one is necessary
        l_return_value := CASE WHEN p_output_uom_code IS NULL THEN l_num_value
                               ELSE WRAPPED_TO_UOM( p_val             => l_num_value
                                                  , p_to_uom_code     => p_output_uom_code
                                                  , p_from_uom_code   => l_uom_code
                                                  , p_from_uom_value  => l_uom_disp_value
                                                  )
                               END;
        RETURN l_return_value;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN -- this attribute is not present in the interface table !
            RETURN l_return_value;
        WHEN OTHERS THEN
--          MY_PUT_LINE( 'GET_REV_USR_ATTR_NUM Error code ' || SQLCODE || ': ' || SQLERRM );
            RETURN l_return_value;
    END GET_REV_USR_ATTR_NUM;

    --------------------------------------------------------------------------------------------
    --  Function WRAPPED_TO_UOM                                                               --
    --      Wraps inv_convert.uom_conversion to return null in case of conversion failure.    --
    --      If both of the from_uom params are null, no attempt to make the conversion is     --
    --        performed.                                                                      --
    --------------------------------------------------------------------------------------------
    FUNCTION WRAPPED_TO_UOM( p_val                  NUMBER
                           , p_to_uom_code          EGO_ITM_USR_ATTR_INTRFC.ATTR_VALUE_UOM%TYPE
                           , p_from_uom_code        EGO_ITM_USR_ATTR_INTRFC.ATTR_VALUE_UOM%TYPE
                           , p_from_uom_value       EGO_ITM_USR_ATTR_INTRFC.ATTR_UOM_DISP_VALUE%TYPE
                           , p_inventory_item_id    EGO_ITM_USR_ATTR_INTRFC.INVENTORY_ITEM_ID%TYPE      DEFAULT NULL
                           )
    RETURN NUMBER IS
        l_uom_code  EGO_ITM_USR_ATTR_INTRFC.ATTR_VALUE_UOM%TYPE := p_from_uom_code;
        l_uom_rate  NUMBER;
    BEGIN
        IF      p_val IS NULL
            OR  p_val = 0
            OR  p_val = 9.99e125 -- G_EXCEL_MISS_NUM we make sure that null out attempts are not UOM converted
            OR  (   p_from_uom_code     IS NULL
                AND p_from_uom_value    IS NULL
                )
        THEN
            RETURN p_val;
        END IF;

        IF l_uom_code IS NULL THEN
            SELECT  uom_code INTO l_uom_code
            FROM    mtl_units_of_measure_vl
            WHERE   unit_of_measure = p_from_uom_value;
        END IF;

        inv_convert.inv_um_conversion( from_unit => l_uom_code
                                     , to_unit   => p_to_uom_code
                                     , item_id   => p_inventory_item_id
                                     , uom_rate  => l_uom_rate
                                     );
        IF  l_uom_rate <> -99999 -- the error value in the inv_convert package
        THEN
            RETURN l_uom_rate * p_val;
        ELSE
            RETURN NULL;
        END IF;

    EXCEPTION
        WHEN OTHERS THEN
            RETURN NULL;
    END WRAPPED_TO_UOM;

    FUNCTION GET_REV_USR_ATTR_SS_DNUM
        (
          p_batch_id                        IN  EGO_ITM_USR_ATTR_INTRFC.DATA_SET_ID%TYPE
        , p_source_system_id                IN  EGO_ITM_USR_ATTR_INTRFC.SOURCE_SYSTEM_ID%TYPE
        , p_source_system_reference         IN  EGO_ITM_USR_ATTR_INTRFC.SOURCE_SYSTEM_REFERENCE%TYPE
        , p_organization_id                 IN  EGO_ITM_USR_ATTR_INTRFC.ORGANIZATION_ID%TYPE
        , p_revision_code                   IN  EGO_ITM_USR_ATTR_INTRFC.REVISION%TYPE
        , p_attr_group_type                 IN  EGO_ITM_USR_ATTR_INTRFC.ATTR_GROUP_TYPE%TYPE
        , p_attr_group_name                 IN  EGO_ITM_USR_ATTR_INTRFC.ATTR_GROUP_INT_NAME%TYPE
        , p_attr_name                       IN  EGO_ITM_USR_ATTR_INTRFC.ATTR_INT_NAME%TYPE
        , p_output_uom_code                 IN  EGO_ITM_USR_ATTR_INTRFC.ATTR_VALUE_UOM%TYPE
        , p_do_processed_rows_flag          IN  FLAG                                DEFAULT FND_API.G_FALSE
        , p_request_id                      IN  EGO_ITM_USR_ATTR_INTRFC.REQUEST_ID%TYPE DEFAULT NULL
        )
    RETURN EGO_ITM_USR_ATTR_INTRFC.ATTR_VALUE_NUM%TYPE IS
    BEGIN
        RETURN GET_REV_USR_ATTR_NUM
        (
          p_batch_id                        => p_batch_id
        , p_source_system_id                => p_source_system_id
        , p_source_system_reference         => p_source_system_reference
        , p_organization_id                 => p_organization_id
        , p_revision_code                   => p_revision_code
        , p_attr_group_type                 => p_attr_group_type
        , p_attr_group_name                 => p_attr_group_name
        , p_attr_name                       => p_attr_name
        , p_do_processed_rows_flag          => p_do_processed_rows_flag
        , p_request_id                      => p_request_id
        , p_use_pdh_keys_to_join            => FALSE
        , p_get_value_column                => FALSE
        , p_output_uom_code                 => p_output_uom_code
        );
    END GET_REV_USR_ATTR_SS_DNUM;

    FUNCTION GET_REV_USR_ATTR_PDH_DNUM
        (
          p_batch_id                        IN  EGO_ITM_USR_ATTR_INTRFC.DATA_SET_ID%TYPE
        , p_inventory_item_id               IN  EGO_ITM_USR_ATTR_INTRFC.INVENTORY_ITEM_ID%TYPE
        , p_item_number                     IN  EGO_ITM_USR_ATTR_INTRFC.ITEM_NUMBER%TYPE
        , p_organization_id                 IN  EGO_ITM_USR_ATTR_INTRFC.ORGANIZATION_ID%TYPE
        , p_revision_code                   IN  EGO_ITM_USR_ATTR_INTRFC.REVISION%TYPE
        , p_attr_group_type                 IN  EGO_ITM_USR_ATTR_INTRFC.ATTR_GROUP_TYPE%TYPE
        , p_attr_group_name                 IN  EGO_ITM_USR_ATTR_INTRFC.ATTR_GROUP_INT_NAME%TYPE
        , p_attr_name                       IN  EGO_ITM_USR_ATTR_INTRFC.ATTR_INT_NAME%TYPE
        , p_output_uom_code                 IN  EGO_ITM_USR_ATTR_INTRFC.ATTR_VALUE_UOM%TYPE
        , p_do_processed_rows_flag          IN  FLAG                                DEFAULT FND_API.G_FALSE
        , p_request_id                      IN  EGO_ITM_USR_ATTR_INTRFC.REQUEST_ID%TYPE DEFAULT NULL
        )
    RETURN EGO_ITM_USR_ATTR_INTRFC.ATTR_VALUE_NUM%TYPE IS
    BEGIN
        RETURN GET_REV_USR_ATTR_NUM
        (
          p_batch_id                        => p_batch_id
        , p_inventory_item_id               => p_inventory_item_id
        , p_item_number                     => p_item_number
        , p_organization_id                 => p_organization_id
        , p_revision_code                   => p_revision_code
        , p_attr_group_type                 => p_attr_group_type
        , p_attr_group_name                 => p_attr_group_name
        , p_attr_name                       => p_attr_name
        , p_do_processed_rows_flag          => p_do_processed_rows_flag
        , p_request_id                      => p_request_id
        , p_use_pdh_keys_to_join            => TRUE
        , p_get_value_column                => FALSE
        , p_output_uom_code                 => p_output_uom_code
        );
    END GET_REV_USR_ATTR_PDH_DNUM;

    --------------------------------------------------------------------------------------------
    --  Function GET_REV_USR_ATTR_STR                                                         --
    --  Returns the string value of the specified revision attribute, if the attribute is present
    --  in the interface table.
    --------------------------------------------------------------------------------------------
    FUNCTION GET_REV_USR_ATTR_SS_VSTR
        (
        p_batch_id                          IN  EGO_ITM_USR_ATTR_INTRFC.DATA_SET_ID%TYPE
        , p_source_system_id                IN  EGO_ITM_USR_ATTR_INTRFC.SOURCE_SYSTEM_ID%TYPE
        , p_source_system_reference         IN  EGO_ITM_USR_ATTR_INTRFC.SOURCE_SYSTEM_REFERENCE%TYPE
        , p_organization_id                 IN  EGO_ITM_USR_ATTR_INTRFC.ORGANIZATION_ID%TYPE
        , p_revision_code                   IN  EGO_ITM_USR_ATTR_INTRFC.REVISION%TYPE
        , p_attr_group_type                 IN  EGO_ITM_USR_ATTR_INTRFC.ATTR_GROUP_TYPE%TYPE
        , p_attr_group_name                 IN  EGO_ITM_USR_ATTR_INTRFC.ATTR_GROUP_INT_NAME%TYPE
        , p_attr_name                       IN  EGO_ITM_USR_ATTR_INTRFC.ATTR_INT_NAME%TYPE
        , p_do_processed_rows_flag          IN  FLAG DEFAULT FND_API.G_FALSE
        ,   p_request_id                    IN  EGO_ITM_USR_ATTR_INTRFC.REQUEST_ID%TYPE                 DEFAULT NULL
        )
    RETURN EGO_ITM_USR_ATTR_INTRFC.ATTR_VALUE_STR%TYPE IS
    BEGIN
        RETURN GET_REV_USR_ATTR_STR
        (
          p_batch_id                        => p_batch_id
        , p_source_system_id                => p_source_system_id
        , p_source_system_reference         => p_source_system_reference
        , p_organization_id                 => p_organization_id
        , p_revision_code                   => p_revision_code
        , p_attr_group_type                 => p_attr_group_type
        , p_attr_group_name                 => p_attr_group_name
        , p_attr_name                       => p_attr_name
        , p_do_processed_rows_flag          => p_do_processed_rows_flag
        , p_request_id                      => p_request_id
        , p_use_pdh_keys_to_join            => false
        , p_get_value_column                => true
        );
    END GET_REV_USR_ATTR_SS_VSTR;

    FUNCTION GET_REV_USR_ATTR_PDH_VSTR
        (
        p_batch_id                          IN  EGO_ITM_USR_ATTR_INTRFC.DATA_SET_ID%TYPE
        , p_inventory_item_id               IN  EGO_ITM_USR_ATTR_INTRFC.INVENTORY_ITEM_ID%TYPE
        , p_item_number                     IN  EGO_ITM_USR_ATTR_INTRFC.ITEM_NUMBER%TYPE
        , p_organization_id                 IN  EGO_ITM_USR_ATTR_INTRFC.ORGANIZATION_ID%TYPE
        , p_revision_code                   IN  EGO_ITM_USR_ATTR_INTRFC.REVISION%TYPE
        , p_attr_group_type                 IN  EGO_ITM_USR_ATTR_INTRFC.ATTR_GROUP_TYPE%TYPE
        , p_attr_group_name                 IN  EGO_ITM_USR_ATTR_INTRFC.ATTR_GROUP_INT_NAME%TYPE
        , p_attr_name                       IN  EGO_ITM_USR_ATTR_INTRFC.ATTR_INT_NAME%TYPE
        , p_do_processed_rows_flag          IN  FLAG DEFAULT FND_API.G_FALSE
        ,   p_request_id                    IN  EGO_ITM_USR_ATTR_INTRFC.REQUEST_ID%TYPE                 DEFAULT NULL
        )
    RETURN EGO_ITM_USR_ATTR_INTRFC.ATTR_VALUE_STR%TYPE IS
    BEGIN
        RETURN GET_REV_USR_ATTR_STR
        (
          p_batch_id                        => p_batch_id
        , p_inventory_item_id               => p_inventory_item_id
        , p_item_number                     => p_item_number
        , p_organization_id                 => p_organization_id
        , p_revision_code                   => p_revision_code
        , p_attr_group_type                 => p_attr_group_type
        , p_attr_group_name                 => p_attr_group_name
        , p_attr_name                       => p_attr_name
        , p_do_processed_rows_flag          => p_do_processed_rows_flag
        , p_request_id                      => p_request_id
        , p_use_pdh_keys_to_join            => true
        , p_get_value_column                => true
        );
    END GET_REV_USR_ATTR_PDH_VSTR;

    --------------------------------------------------------------------------------------------
    --  Function GET_REV_USR_ATTR_DATE
    --  Returns the date value of the specified revision attribute, if the attribute is present
    --  in the interface table.
    --------------------------------------------------------------------------------------------
    FUNCTION GET_REV_USR_ATTR_SS_VDATE
        (
        p_batch_id                          IN  EGO_ITM_USR_ATTR_INTRFC.DATA_SET_ID%TYPE
        , p_source_system_id                IN  EGO_ITM_USR_ATTR_INTRFC.SOURCE_SYSTEM_ID%TYPE
        , p_source_system_reference         IN  EGO_ITM_USR_ATTR_INTRFC.SOURCE_SYSTEM_REFERENCE%TYPE
        , p_organization_id                 IN  EGO_ITM_USR_ATTR_INTRFC.ORGANIZATION_ID%TYPE
        , p_revision_code                   IN  EGO_ITM_USR_ATTR_INTRFC.REVISION%TYPE
        , p_attr_group_type                 IN  EGO_ITM_USR_ATTR_INTRFC.ATTR_GROUP_TYPE%TYPE
        , p_attr_group_name                 IN  EGO_ITM_USR_ATTR_INTRFC.ATTR_GROUP_INT_NAME%TYPE
        , p_attr_name                       IN  EGO_ITM_USR_ATTR_INTRFC.ATTR_INT_NAME%TYPE
        , p_do_processed_rows_flag          IN  FLAG                                DEFAULT FND_API.G_FALSE
        ,   p_request_id                    IN  EGO_ITM_USR_ATTR_INTRFC.REQUEST_ID%TYPE                 DEFAULT NULL
        )
    RETURN EGO_ITM_USR_ATTR_INTRFC.ATTR_VALUE_DATE%TYPE IS
    BEGIN
        RETURN GET_REV_USR_ATTR_DATE
        (
          p_batch_id                        => p_batch_id
        , p_source_system_id                => p_source_system_id
        , p_source_system_reference         => p_source_system_reference
        , p_organization_id                 => p_organization_id
        , p_revision_code                   => p_revision_code
        , p_attr_group_type                 => p_attr_group_type
        , p_attr_group_name                 => p_attr_group_name
        , p_attr_name                       => p_attr_name
        , p_do_processed_rows_flag          => p_do_processed_rows_flag
        , p_request_id                      => p_request_id
        , p_use_pdh_keys_to_join            => false
        , p_get_value_column                => true
        );
    END GET_REV_USR_ATTR_SS_VDATE;

    FUNCTION GET_REV_USR_ATTR_PDH_VDATE
        (
        p_batch_id                          IN  EGO_ITM_USR_ATTR_INTRFC.DATA_SET_ID%TYPE
        , p_inventory_item_id               IN  EGO_ITM_USR_ATTR_INTRFC.INVENTORY_ITEM_ID%TYPE
        , p_item_number                     IN  EGO_ITM_USR_ATTR_INTRFC.ITEM_NUMBER%TYPE
        , p_organization_id                 IN  EGO_ITM_USR_ATTR_INTRFC.ORGANIZATION_ID%TYPE
        , p_revision_code                   IN  EGO_ITM_USR_ATTR_INTRFC.REVISION%TYPE
        , p_attr_group_type                 IN  EGO_ITM_USR_ATTR_INTRFC.ATTR_GROUP_TYPE%TYPE
        , p_attr_group_name                 IN  EGO_ITM_USR_ATTR_INTRFC.ATTR_GROUP_INT_NAME%TYPE
        , p_attr_name                       IN  EGO_ITM_USR_ATTR_INTRFC.ATTR_INT_NAME%TYPE
        , p_do_processed_rows_flag          IN  FLAG                                DEFAULT FND_API.G_FALSE
        ,   p_request_id                    IN  EGO_ITM_USR_ATTR_INTRFC.REQUEST_ID%TYPE                 DEFAULT NULL
        )
    RETURN EGO_ITM_USR_ATTR_INTRFC.ATTR_VALUE_DATE%TYPE IS
    BEGIN
        RETURN GET_REV_USR_ATTR_DATE
        (
          p_batch_id                        => p_batch_id
        , p_inventory_item_id               => p_inventory_item_id
        , p_item_number                     => p_item_number
        , p_organization_id                 => p_organization_id
        , p_revision_code                   => p_revision_code
        , p_attr_group_type                 => p_attr_group_type
        , p_attr_group_name                 => p_attr_group_name
        , p_attr_name                       => p_attr_name
        , p_do_processed_rows_flag          => p_do_processed_rows_flag
        , p_request_id                      => p_request_id
        , p_use_pdh_keys_to_join            => true
        , p_get_value_column                => true
        );
    END GET_REV_USR_ATTR_PDH_VDATE;

    --------------------------------------------------------------------------------------------
    --  Function GET_REV_USR_ATTR_NUM
    --  Returns the number value of the specified revision attribute, if the attribute is present
    --  in the interface table.
    --      p_output_uom_code parameter is ignored (no uom conversions performed)
    --------------------------------------------------------------------------------------------
    FUNCTION GET_REV_USR_ATTR_SS_VNUM
        (
          p_batch_id                        IN  EGO_ITM_USR_ATTR_INTRFC.DATA_SET_ID%TYPE
        , p_source_system_id                IN  EGO_ITM_USR_ATTR_INTRFC.SOURCE_SYSTEM_ID%TYPE
        , p_source_system_reference         IN  EGO_ITM_USR_ATTR_INTRFC.SOURCE_SYSTEM_REFERENCE%TYPE
        , p_organization_id                 IN  EGO_ITM_USR_ATTR_INTRFC.ORGANIZATION_ID%TYPE
        , p_revision_code                   IN  EGO_ITM_USR_ATTR_INTRFC.REVISION%TYPE
        , p_attr_group_type                 IN  EGO_ITM_USR_ATTR_INTRFC.ATTR_GROUP_TYPE%TYPE
        , p_attr_group_name                 IN  EGO_ITM_USR_ATTR_INTRFC.ATTR_GROUP_INT_NAME%TYPE
        , p_attr_name                       IN  EGO_ITM_USR_ATTR_INTRFC.ATTR_INT_NAME%TYPE
        , p_output_uom_code                 IN  EGO_ITM_USR_ATTR_INTRFC.ATTR_VALUE_UOM%TYPE
        , p_do_processed_rows_flag          IN  FLAG                                DEFAULT FND_API.G_FALSE
        , p_request_id                      IN  EGO_ITM_USR_ATTR_INTRFC.REQUEST_ID%TYPE DEFAULT NULL
        )
    RETURN EGO_ITM_USR_ATTR_INTRFC.ATTR_VALUE_NUM%TYPE IS
    BEGIN
        RETURN GET_REV_USR_ATTR_NUM
        (
          p_batch_id                        => p_batch_id
        , p_source_system_id                => p_source_system_id
        , p_source_system_reference         => p_source_system_reference
        , p_organization_id                 => p_organization_id
        , p_revision_code                   => p_revision_code
        , p_attr_group_type                 => p_attr_group_type
        , p_attr_group_name                 => p_attr_group_name
        , p_attr_name                       => p_attr_name
        , p_do_processed_rows_flag          => p_do_processed_rows_flag
        , p_request_id                      => p_request_id
        , p_use_pdh_keys_to_join            => false
        , p_get_value_column                => true
        , p_output_uom_code                 => NULL
        );
    END GET_REV_USR_ATTR_SS_VNUM;

    FUNCTION GET_REV_USR_ATTR_PDH_VNUM
        (
          p_batch_id                        IN  EGO_ITM_USR_ATTR_INTRFC.DATA_SET_ID%TYPE
        , p_inventory_item_id               IN  EGO_ITM_USR_ATTR_INTRFC.INVENTORY_ITEM_ID%TYPE
        , p_item_number                     IN  EGO_ITM_USR_ATTR_INTRFC.ITEM_NUMBER%TYPE
        , p_organization_id                 IN  EGO_ITM_USR_ATTR_INTRFC.ORGANIZATION_ID%TYPE
        , p_revision_code                   IN  EGO_ITM_USR_ATTR_INTRFC.REVISION%TYPE
        , p_attr_group_type                 IN  EGO_ITM_USR_ATTR_INTRFC.ATTR_GROUP_TYPE%TYPE
        , p_attr_group_name                 IN  EGO_ITM_USR_ATTR_INTRFC.ATTR_GROUP_INT_NAME%TYPE
        , p_attr_name                       IN  EGO_ITM_USR_ATTR_INTRFC.ATTR_INT_NAME%TYPE
        , p_output_uom_code                 IN  EGO_ITM_USR_ATTR_INTRFC.ATTR_VALUE_UOM%TYPE
        , p_do_processed_rows_flag          IN  FLAG                                DEFAULT FND_API.G_FALSE
        , p_request_id                      IN  EGO_ITM_USR_ATTR_INTRFC.REQUEST_ID%TYPE DEFAULT NULL
        )
    RETURN EGO_ITM_USR_ATTR_INTRFC.ATTR_VALUE_NUM%TYPE IS
    BEGIN
        RETURN GET_REV_USR_ATTR_NUM
        (
          p_batch_id                        => p_batch_id
        , p_inventory_item_id               => p_inventory_item_id
        , p_item_number                     => p_item_number
        , p_organization_id                 => p_organization_id
        , p_revision_code                   => p_revision_code
        , p_attr_group_type                 => p_attr_group_type
        , p_attr_group_name                 => p_attr_group_name
        , p_attr_name                       => p_attr_name
        , p_do_processed_rows_flag          => p_do_processed_rows_flag
        , p_request_id                      => p_request_id
        , p_use_pdh_keys_to_join            => true
        , p_get_value_column                => true
        , p_output_uom_code                 => NULL
        );
    END GET_REV_USR_ATTR_PDH_VNUM;

 FUNCTION Get_PDH_Source_System_Id RETURN NUMBER AS
 BEGIN
   RETURN G_PDH_SOURCE_SYSTEM_ID;
 END;

 -----------------------------------------------------------------------------------------
 -- Get_Tokens                                                                          --
 -- Takes a string and breaks it into tokens, returning them in another space-delimited --
 -- string; the tokens are determined according to the attributes/preferences of the    --
 -- intermedia text index on items, using its stoplist, lexer, etc.                     --
 -----------------------------------------------------------------------------------------
 PROCEDURE GET_TOKENS
 (
   p_string_val         IN        VARCHAR2
  ,x_tokens             OUT       NOCOPY VARCHAR2
 ) IS

   l_schema_name        VARCHAR2(30);
   l_policy_name        CONSTANT  VARCHAR2(30)    :=  'EGO_ITEM_TEXT_TL_POL1';

   l_token_table        CTX_DOC.token_tab;

 BEGIN

   -- initialization
   x_tokens := '';
   l_schema_name := EGO_COMMON_PVT.Get_Prod_Schema('EGO');

   -- retrieve tokens in a table
   CTX_DOC.Policy_Tokens(l_schema_name || '.' || l_policy_name
                        ,p_string_val
                        ,l_token_table
                        ,userenv('lang')  -- look into how to process other languages
                        ,NULL
                        ,NULL
   );

   -- for each token, put operators and join with the specified conjunction
   FOR i IN 1..l_token_table.count LOOP

     -- reset the clause
     x_tokens := x_tokens || ' ' || l_token_table(i).token;

   END LOOP;

 END GET_TOKENS;

 ------------------------------------------------------------------------------------------
 -- Convert_Org_And_Cat_Grp                                                              --
 -- This procedure converts a specified interface table row's organization code to an ID --
 -- and converts the item catalog category name to its corresponding ID; these           --
 -- conversions only occur if the org code/category name exactly match an existing name  --
 -- in PDH.                                                                              --
 ------------------------------------------------------------------------------------------
 PROCEDURE CONVERT_ORG_AND_CAT_GRP
 (
   p_batch_id           IN        NUMBER
  ,p_src_system_id      IN        NUMBER
  ,p_src_system_ref     IN        VARCHAR2
  ,p_commit             IN        BOOLEAN
 ) IS

   l_org_id             NUMBER;
   l_org_code           VARCHAR2(3);

   l_catalog_grp_id     NUMBER;
   l_catalog_grp_name   VARCHAR2(820);

   l_update_flag        BOOLEAN;

 BEGIN

   IF (p_batch_id IS NOT NULL AND p_src_system_id IS NOT NULL AND p_src_system_ref IS NOT NULL) THEN

     --------------------------------
     -- MTL_SYSTEM_ITEMS_INTERFACE --
     --------------------------------
     UPDATE MTL_SYSTEM_ITEMS_INTERFACE MSII
        SET ORGANIZATION_ID =
             NVL(ORGANIZATION_ID,
                 (SELECT MP.ORGANIZATION_ID
                    FROM MTL_PARAMETERS MP
                   WHERE MP.ORGANIZATION_CODE = MSII.ORGANIZATION_CODE))
           ,ITEM_CATALOG_GROUP_ID =
             NVL(ITEM_CATALOG_GROUP_ID,
                 (SELECT MICG.ITEM_CATALOG_GROUP_ID
                    FROM MTL_ITEM_CATALOG_GROUPS_B_KFV MICG
                   WHERE MICG.CONCATENATED_SEGMENTS = MSII.ITEM_CATALOG_GROUP_NAME))
      WHERE SET_PROCESS_ID = p_batch_id
        AND SOURCE_SYSTEM_ID = p_src_system_id
        AND SOURCE_SYSTEM_REFERENCE = p_src_system_ref
        AND PROCESS_FLAG = 0;

     ------------------
     -- EGO_AML_INTF --
     ------------------
     UPDATE EGO_AML_INTF EAI
        SET ORGANIZATION_ID =
             NVL(ORGANIZATION_ID,
                 (SELECT MP.ORGANIZATION_ID
                    FROM MTL_PARAMETERS MP
                   WHERE MP.ORGANIZATION_CODE = EAI.ORGANIZATION_CODE))
      WHERE DATA_SET_ID = p_batch_id
        AND SOURCE_SYSTEM_ID = p_src_system_id
        AND SOURCE_SYSTEM_REFERENCE = p_src_system_ref
        AND PROCESS_FLAG = 0;

     -----------------------------
     -- EGO_ITM_USR_ATTR_INTRFC --
     -----------------------------
     UPDATE EGO_ITM_USR_ATTR_INTRFC EIUAI
        SET ORGANIZATION_ID =
             NVL(ORGANIZATION_ID,
                 (SELECT MP.ORGANIZATION_ID
                    FROM MTL_PARAMETERS MP
                   WHERE MP.ORGANIZATION_CODE = EIUAI.ORGANIZATION_CODE))
      WHERE DATA_SET_ID = p_batch_id
        AND SOURCE_SYSTEM_ID = p_src_system_id
        AND SOURCE_SYSTEM_REFERENCE = p_src_system_ref
        AND PROCESS_STATUS = 0;

     IF (p_commit) THEN
       COMMIT WORK;
     END IF;

   END IF; -- if all parameters are not null

 END CONVERT_ORG_AND_CAT_GRP;


 ------------------------------------------------------------------------------------------
 -- Convert_Org_Cat_Grp_For_Batch                                                        --
 -- This is a wrapper procedure for the previous conversion procedure; this one accepts  --
 -- a batch ID and converts all unprocessed rows belonging to that batch.                --
 ------------------------------------------------------------------------------------------
 PROCEDURE CONVERT_ORG_CAT_GRP_FOR_BATCH
 (
   p_batch_id           IN        NUMBER
  ,p_commit             IN        BOOLEAN
 ) IS

   CURSOR c_batch_pks IS
     SELECT MSII.SOURCE_SYSTEM_ID SOURCE_SYSTEM_ID
           ,MSII.SOURCE_SYSTEM_REFERENCE SOURCE_SYSTEM_REFERENCE
       FROM MTL_SYSTEM_ITEMS_INTERFACE MSII
      WHERE MSII.SET_PROCESS_ID = p_batch_id
        AND MSII.PROCESS_FLAG = 0
        AND MSII.CONFIRM_STATUS IN ('US', 'UM', 'UN');

 BEGIN

   FOR v_pks IN c_batch_pks
   LOOP

     CONVERT_ORG_AND_CAT_GRP(p_batch_id, v_pks.SOURCE_SYSTEM_ID, v_pks.SOURCE_SYSTEM_REFERENCE, p_commit);

   END LOOP;

 END CONVERT_ORG_CAT_GRP_FOR_BATCH;


 ------------------------------------------------------------------------------------------
 -- Confirm_Matches                                                                      --
 -- This procedure takes care of setting the confirm status for a particular match in    --
 -- the item match table, depending on how many matches were found for a row in the      --
 -- interface table.                                                                     --
 ------------------------------------------------------------------------------------------
 PROCEDURE CONFIRM_MATCHES
 (
   p_batch_id           IN        NUMBER
  ,p_src_system_id      IN        NUMBER
  ,p_src_system_ref     IN        VARCHAR2
  ,p_match_count        IN        NUMBER
  ,p_inventory_item_id  IN        NUMBER
  ,p_organization_id    IN        NUMBER
 ) IS

   l_confirm_single_match         VARCHAR2(1);
   l_confirm_no_match         VARCHAR2(1);

 BEGIN

   IF (p_match_count < 1) THEN

     /* Bug 8621347. If item does not have any matches, get CONFIRM_NO_MATCH value of the Batch */
     SELECT NVL(CONFIRM_NO_MATCH,'N')
        INTO l_confirm_no_match
        FROM EGO_IMPORT_BATCH_DETAILS_V
        WHERE BATCH_ID=p_batch_id;

     /* Bug 8621347. Set the CONFIRM_STATUS to G_CONF_NEW (Confirm New), if CONFIRM_NO_MATCH i.e., 'Automatically Confirm New Item on No Match'
        is enabled. Otherwise, set CONFIRM_STATUS to G_UNCONF_NONE_MATCH (Unconfirm No Match).
     */
     IF (l_confirm_no_match = 'Y') THEN
             EGO_IMPORT_PVT.Set_Confirm_Status(p_batch_id
                                      ,p_src_system_id
                                      ,p_src_system_ref
                                      ,EGO_IMPORT_PVT.G_CONF_NEW);
     ELSE
             EGO_IMPORT_PVT.Set_Confirm_Status(p_batch_id
                                      ,p_src_system_id
                                      ,p_src_system_ref
                                      ,EGO_IMPORT_PVT.G_UNCONF_NONE_MATCH);
     END IF;

   ELSIF (p_match_count > 1) THEN

     EGO_IMPORT_PVT.Set_Confirm_Status(p_batch_id
                                      ,p_src_system_id
                                      ,p_src_system_ref
                                      ,EGO_IMPORT_PVT.G_UNCONF_MULT_MATCH);

   ELSE

     SELECT CONFIRM_SINGLE_MATCH
       INTO l_confirm_single_match
       FROM EGO_IMPORT_BATCH_DETAILS_V
      WHERE BATCH_ID = p_batch_id;

     IF (l_confirm_single_match = 'Y') THEN

       EGO_IMPORT_PVT.Set_Confirm_Status(p_batch_id
                                        ,p_src_system_id
                                        ,p_src_system_ref
                                        ,EGO_IMPORT_PVT.G_CONF_MATCH
                                        ,p_inventory_item_id
                                        ,p_organization_id);

     ELSE

       EGO_IMPORT_PVT.Set_Confirm_Status(p_batch_id
                                        ,p_src_system_id
                                        ,p_src_system_ref
                                        ,EGO_IMPORT_PVT.G_UNCONF_SIGL_MATCH
                                        ,p_inventory_item_id
                                        ,p_organization_id);

     END IF;

   END IF;

 END CONFIRM_MATCHES;

 ------------------------------------------------------------------------------------------
 -- Get_Latest_Revision_Func                                                             --
 -- This function returns the latest revision available for a particular spoke item.     --
 -- The function first checks for a revision in the item revision interface table, then  --
 -- MSI interface, and finally, the user-defined attributes interface table.             --
 ------------------------------------------------------------------------------------------
 FUNCTION GET_LATEST_REVISION_FUNC
 (
   p_batch_id                        IN          EGO_ITM_USR_ATTR_INTRFC.DATA_SET_ID%TYPE
 , p_source_system_id                IN          EGO_ITM_USR_ATTR_INTRFC.SOURCE_SYSTEM_ID%TYPE
 , p_source_system_reference         IN          EGO_ITM_USR_ATTR_INTRFC.SOURCE_SYSTEM_REFERENCE%TYPE
 , p_organization_id                 IN          EGO_ITM_USR_ATTR_INTRFC.ORGANIZATION_ID%TYPE
 )
 RETURN VARCHAR2
 IS

    l_revision_code                   VARCHAR2(3);


 BEGIN

   -- attempt to get the latest revision from the revision interface table
   -- according to latest effectivity date; in the case of equal effectivity
   -- dates, return that with the "greatest" revision code (ASCII sort order)
   l_revision_code := GET_LATEST_MIRI_REV_SS( p_batch_id, p_source_system_id, p_source_system_reference, p_organization_id, FND_API.G_FALSE );

   -- if the revision still could not be obtained, then obtain it from the
   -- user attrs interface table (ASCII sort order)
   IF (l_revision_code IS NULL) THEN
     l_revision_code := GET_LATEST_EIUAI_REV_SS( p_batch_id, p_source_system_id, p_source_system_reference, p_organization_id, FND_API.G_FALSE );
   END IF;

   RETURN l_revision_code;
 END GET_LATEST_REVISION_FUNC;

    /**
     * For every unprocessed master record in a batch which has transaction_type value of 'UPDATE' or 'SYNC'
     * if it has no inventory_item_id
     *    if it has an item number, parse it into segments.
     *    determine if an item exists with these segments in MSI and if true, populate inventory_item_id
     * else it has inventory_item_id
     *    determine if an item exists with this inventory_item_id in MSI
     *
     * if the current transaction_type is 'SYNC'
     *    change it to 'UPDATE' if there is a way to resolve it to an existing item.
     *    change it to 'CREATE' if there is no way to resolve it to an existing item
     */
    PROCEDURE UPDATE_ITEM_SYNC_RECORDS
    (p_set_id  IN  NUMBER
     ,p_org_id IN NUMBER
    ) IS
      CURSOR c_items_table IS
        SELECT rowid
              ,organization_id
              ,inventory_item_id
              ,item_number
              ,transaction_id
              ,transaction_type
        FROM   mtl_system_items_interface
        WHERE  set_process_id   = p_set_id
          AND    process_flag     = 0
          AND organization_id = p_org_id
          AND (     confirm_status IS NULL
              OR    confirm_status = G_FAKE_CONF_STATUS_FLAG ) -- for bug 5136989
          AND UPPER(transaction_type) in ('SYNC', 'UPDATE')
          FOR UPDATE OF transaction_type;

      CURSOR c_item_exists(cp_item_id NUMBER) IS
        SELECT  1
        FROM   mtl_system_items_b
        WHERE  inventory_item_id = cp_item_id;

      l_item_exist NUMBER(10) := 0;
      l_err_text   VARCHAR2(200);
      l_status      NUMBER(10):= 0;
      l_item_id    mtl_system_items_b.inventory_item_id%TYPE;

   BEGIN

      FOR item_record IN c_items_table LOOP
         l_item_exist :=0;
         l_item_id    := NULL;

         IF item_record.inventory_item_id IS NULL THEN
            IF item_record.item_number IS NOT NULL THEN
               l_status  := INVPUOPI.MTL_PR_PARSE_ITEM_NUMBER(
                               ITEM_NUMBER =>item_record.item_number
                  ,ITEM_ID     =>item_record.inventory_item_id
                  ,TRANS_ID    =>item_record.transaction_id
                  ,ORG_ID      =>item_record.organization_id
                  ,ERR_TEXT    =>l_err_text
                  ,P_ROWID     =>item_record.rowid);
            END IF;
            l_item_exist := INVUPD1B.EXISTS_IN_MSI(
                    ROW_ID      => item_record.rowid
                   ,ORG_ID      => item_record.organization_id
                   ,INV_ITEM_ID => l_item_id
                   ,TRANS_ID    => item_record.transaction_id
                   ,ERR_TEXT    => l_err_text
                   ,XSET_ID     => p_set_id);
         ELSE
            l_item_id := item_record.inventory_item_id;
            OPEN  c_item_exists(item_record.inventory_item_id);
            FETCH c_item_exists INTO l_item_exist;
            CLOSE c_item_exists;
            l_item_exist := NVL(l_item_exist,0);
         END IF;

         IF upper(item_record.transaction_type) = 'SYNC' THEN
            IF l_item_exist = 1 THEN
               UPDATE mtl_system_items_interface
               SET    transaction_type  = 'UPDATE'
               WHERE  rowid = item_record.rowid;
            ELSE
               IF item_record.item_number IS NOT NULL THEN
                  UPDATE mtl_system_items_interface
                  SET    transaction_type = 'CREATE', inventory_item_id = NULL
                  WHERE  rowid = item_record.rowid;
               ELSE
                  UPDATE mtl_system_items_interface
                  SET    transaction_type = 'UPDATE', inventory_item_id = NULL
                  WHERE  rowid = item_record.rowid;
               END IF;
            END IF;
         END IF;
      END LOOP;
   END UPDATE_ITEM_SYNC_RECORDS;


   PROCEDURE SET_CONFIRM_STATUS
    (p_batch_id                IN  MTL_SYSTEM_ITEMS_INTERFACE.SET_PROCESS_ID%TYPE
    ,p_source_system_id        IN  MTL_SYSTEM_ITEMS_INTERFACE.SOURCE_SYSTEM_ID%TYPE
    ,p_source_system_reference IN  MTL_SYSTEM_ITEMS_INTERFACE.SOURCE_SYSTEM_REFERENCE%TYPE
    ,p_new_status              IN  MTL_SYSTEM_ITEMS_INTERFACE.CONFIRM_STATUS%TYPE
    ,p_inventory_item_id       IN  MTL_SYSTEM_ITEMS_INTERFACE.INVENTORY_ITEM_ID%TYPE DEFAULT NULL
    ,p_organization_id         IN  MTL_SYSTEM_ITEMS_INTERFACE.ORGANIZATION_ID%TYPE DEFAULT NULL
    ,p_check_matching_table    IN  FLAG  DEFAULT FND_API.G_FALSE
    ,errmsg                    OUT NOCOPY VARCHAR2
    ,retcode                   OUT NOCOPY VARCHAR2
    ) IS
    CURSOR cur_old_status IS
     SELECT CONFIRM_STATUS
     FROM MTL_SYSTEM_ITEMS_INTERFACE MSII, EGO_IMPORT_BATCHES_B BA
     WHERE MSII.SET_PROCESS_ID = p_batch_id
        AND MSII.SOURCE_SYSTEM_ID = p_source_system_id
        AND MSII.SOURCE_SYSTEM_REFERENCE = p_source_system_reference
        AND MSII.ORGANIZATION_ID = BA.ORGANIZATION_ID
        AND BA.BATCH_ID = p_batch_id
        AND NVL(MSII.PROCESS_FLAG, 0) < 1
        AND ROWNUM < 2;

    l_old_status  MTL_SYSTEM_ITEMS_INTERFACE.CONFIRM_STATUS%TYPE;
    l_need_resolve_unconf_status FLAG := p_check_matching_table;
    l_resolved_status  MTL_SYSTEM_ITEMS_INTERFACE.CONFIRM_STATUS%TYPE := p_new_status;
    l_item_in_matching_table NUMBER;
    BEGIN
       OPEN cur_old_status;
       FETCH cur_old_status INTO l_old_status;
       CLOSE cur_old_status;

       IF l_old_status IS NOT NULL AND l_old_status NOT IN (G_CONF_MATCH,G_CONF_XREF,G_CONF_NEW, G_UNCONF_NONE_MATCH,
                                                            G_UNCONF_SIGL_MATCH,G_UNCONF_MULT_MATCH,G_EXCLUDED) THEN
          errmsg := 'Invalid old status';
          retcode := 'F';
          RETURN;
       END IF;

       IF p_new_status NOT IN (G_CONF_MATCH,G_CONF_NEW, G_UNCONF_NONE_MATCH,
                               G_UNCONF_SIGL_MATCH,G_UNCONF_MULT_MATCH,G_EXCLUDED,
                               G_UNCONF_ACTION, G_UNEXCLUDE_ACTION) THEN
          errmsg := 'Invalid new status or action';
          retcode := 'F';
          RETURN;
       END IF;

       IF (l_old_status = G_UNCONF_NONE_MATCH AND p_new_status = G_CONF_MATCH) OR
          (l_old_status = G_CONF_XREF AND p_new_status = G_UNCONF_SIGL_MATCH) OR
          (l_old_status = G_CONF_XREF AND p_new_status = G_UNCONF_MULT_MATCH) OR
          (l_old_status = G_CONF_XREF AND p_new_status = G_CONF_MATCH) OR
          (l_old_status = G_CONF_MATCH AND p_new_status = G_UNCONF_NONE_MATCH) OR
          (l_old_status = G_CONF_MATCH AND p_new_status = G_CONF_MATCH) OR
          (l_old_status = G_CONF_NEW AND p_new_status = G_CONF_MATCH) OR
          (l_old_status = G_CONF_NEW AND p_new_status = G_CONF_NEW) OR
          (l_old_status = G_EXCLUDED AND p_new_status = G_CONF_MATCH) OR
          (l_old_status = G_EXCLUDED AND p_new_status = G_CONF_NEW) OR
          (l_old_status = G_EXCLUDED AND p_new_status = G_EXCLUDED) THEN
          errmsg := 'Invalid status transition from ' || l_old_status || ' to ' || p_new_status || '.';
          retcode := 'F';
          RETURN;
       END IF;

       IF l_old_status NOT IN (G_CONF_MATCH,G_CONF_XREF,G_CONF_NEW) AND p_new_status = G_UNCONF_ACTION THEN
          errmsg := 'Invalid action: cannot unconfirm an item that is not confirmed.';
          retcode := 'F';
          RETURN;
       END IF;

       IF l_old_status <> G_EXCLUDED AND p_new_status = G_UNEXCLUDE_ACTION THEN
          errmsg := 'Invalid action: cannot unexclude an item that is not excluded';
          retcode := 'F';
          RETURN;
       END IF;

       IF p_new_status = G_CONF_MATCH AND (p_inventory_item_id IS NULL OR p_organization_id IS NULL) THEN
          errmsg := 'Insufficient parameters: need PDH item id and org id';
          retcode := 'F';
          RETURN;
       END IF;

       IF p_new_status <> G_CONF_MATCH AND p_inventory_item_id IS NOT NULL THEN
          errmsg := 'Invalid parameters: p_inventory_item_id must be null if item is not confirmed as matched';
          retcode := 'F';
          RETURN;
       END IF;

       IF p_new_status = G_CONF_MATCH THEN
          BEGIN
             SELECT 1 INTO l_item_in_matching_table
             FROM EGO_ITEM_MATCHES
             WHERE BATCH_ID = p_batch_id
                AND SOURCE_SYSTEM_ID = p_source_system_id
                AND SOURCE_SYSTEM_REFERENCE = p_source_system_reference
                AND INVENTORY_ITEM_ID = p_inventory_item_id
                AND ORGANIZATION_ID = p_organization_id;
          EXCEPTION WHEN NO_DATA_FOUND THEN
            errmsg := 'Invalid parameters: need to pick a PDH item that is matched';
            retcode := 'F';
            RETURN;
          END;
       END IF;

       IF p_new_status IN (G_CONF_MATCH, G_CONF_NEW, G_EXCLUDED) AND
          p_check_matching_table = FND_API.G_TRUE THEN
          errmsg := 'Invalid parameters: cannot check matching table when setting confirm_status to ' || p_new_status;
          retcode := 'F';
          RETURN;
       END IF;

       IF p_new_status IN (G_UNCONF_ACTION, G_UNEXCLUDE_ACTION) THEN
          l_need_resolve_unconf_status := FND_API.G_TRUE;
       END IF;

       IF l_need_resolve_unconf_status = FND_API.G_TRUE THEN
          SELECT decode(count(1), 0, G_UNCONF_NONE_MATCH, 1, G_UNCONF_SIGL_MATCH, G_UNCONF_MULT_match)
            INTO l_resolved_status
          FROM EGO_ITEM_MATCHES
          WHERE BATCH_ID = p_batch_id
             AND SOURCE_SYSTEM_ID = p_source_system_id
             AND SOURCE_SYSTEM_REFERENCE = p_source_system_reference;
       END IF;

       UPDATE MTL_SYSTEM_ITEMS_INTERFACE
       SET CONFIRM_STATUS = l_resolved_status, INVENTORY_ITEM_ID = p_inventory_item_id
       WHERE SET_PROCESS_ID = p_batch_id
          AND SOURCE_SYSTEM_ID = p_source_system_id
          AND SOURCE_SYSTEM_REFERENCE = p_source_system_reference
          AND ORGANIZATION_ID = (SELECT ORGANIZATION_id FROM EGO_IMPORT_BATCHES_B WHERE BATCH_ID = p_batch_id)
          AND NVL(PROCESS_FLAG, 0) < 1;

       IF l_old_status = G_EXCLUDED THEN
          DELETE FROM EGO_IMPORT_EXCLUDED_SS_ITEMS
          WHERE SOURCE_SYSTEM_ID = p_source_system_id
             AND SOURCE_SYSTEM_REFERENCE = p_source_system_reference;
       END IF;

       IF p_new_status = G_EXCLUDED THEN
          MERGE INTO EGO_IMPORT_EXCLUDED_SS_ITEMS
          USING dual
          ON (SOURCE_SYSTEM_ID = p_source_system_id AND SOURCE_SYSTEM_REFERENCE = p_source_system_reference)
          WHEN matched THEN
            UPDATE SET LAST_UPDATED_BY = FND_GLOBAL.USER_ID, LAST_UPDATE_DATE = SYSDATE,
                       LAST_UPDATE_LOGIN = FND_GLOBAL.LOGIN_ID, OBJECT_VERSION_NUMBER = OBJECT_VERSION_NUMBER + 1
          WHEN NOT matched THEN
            INSERT VALUES (p_source_system_id, p_source_system_reference, 1, FND_GLOBAL.USER_ID, SYSDATE, FND_GLOBAL.USER_ID, SYSDATE, FND_GLOBAL.LOGIN_ID);
       END IF;

       errmsg := NULL;
       retcode := 'S';
    END SET_CONFIRM_STATUS;

  ------------------------------------------------------------------
  -- Function for returning the change order flag for the batch
  -- Bug#4631349 (RSOUNDAR)
  ------------------------------------------------------------------
  FUNCTION getAddAllToChangeFlag (p_batch_id  IN  NUMBER)
  RETURN VARCHAR2 IS

  l_add_all_change_flag VARCHAR2(1);

  BEGIN
    SELECT NVL(ADD_ALL_TO_CHANGE_FLAG,'N')
    INTO l_add_all_change_flag
    FROM EGO_IMPORT_OPTION_SETS
    WHERE BATCH_ID = p_batch_id;
    RETURN l_add_all_change_flag;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN 'N';

  END  getAddAllToChangeFlag;

  FUNCTION Get_Lookup_Meaning(p_lookup_type IN VARCHAR2, p_lookup_code IN VARCHAR2)
  RETURN VARCHAR2 IS
    l_meaning VARCHAR2(1000);
  BEGIN
    SELECT MEANING INTO l_meaning
    FROM FND_LOOKUPS
    WHERE LOOKUP_TYPE = p_lookup_type
      AND LOOKUP_CODE = p_lookup_code;

    RETURN l_meaning;
  EXCEPTION WHEN OTHERS THEN
    RETURN NULL;
  END Get_Lookup_Meaning;

  ------------------------------------------------------------------
  --Function for returning batch details before import
  --Bug.:4933193
  ------------------------------------------------------------------
  FUNCTION GET_IMPORT_DETAILS_DATA
                            (     p_set_process_id                NUMBER,
                                  p_organization_id               NUMBER ,
                                  p_organization_code             VARCHAR2
                            )
                            RETURN  SYSTEM.EGO_IMPORT_CNT_TABLE
  IS
  CURSOR cr_item  ( p_set_process_id NUMBER, p_organization_id NUMBER , p_organization_code VARCHAR2) IS
    SELECT
      COUNT(1) CNT ,
      COUNT(
        CASE
        WHEN PROCESS_FLAG = 7
        AND UPPER(TRANSACTION_TYPE)= 'CREATE'
        THEN 1
        ELSE NULL
        END
        ) AS NEW_CNT ,
      COUNT(
        CASE
        WHEN PROCESS_FLAG = 7
        AND UPPER(TRANSACTION_TYPE)= 'UPDATE'
        THEN 1
        ELSE NULL
        END
        ) UPDATE_CNT
    FROM MTL_SYSTEM_ITEMS_INTERFACE
    WHERE SET_PROCESS_ID = p_set_process_id
    AND ( (ORGANIZATION_ID is not null and ORGANIZATION_ID = p_organization_id )
        OR
        (ORGANIZATION_ID is null and ORGANIZATION_CODE = p_organization_code )
        );


  CURSOR cr_org_assign (p_set_process_id NUMBER, p_organization_id NUMBER) IS
    SELECT
      COUNT(1) CNT ,
      COUNT(
        CASE
        WHEN PROCESS_FLAG = 7
        AND UPPER(TRANSACTION_TYPE)= 'CREATE'
        THEN 1
        ELSE NULL
        END
        ) AS NEW_CNT ,
      COUNT(
        CASE
        WHEN PROCESS_FLAG = 7
        AND UPPER(TRANSACTION_TYPE)= 'UPDATE'
        THEN 1
        ELSE NULL
        END
        ) UPDATE_CNT
    FROM MTL_SYSTEM_ITEMS_INTERFACE msii
    WHERE SET_PROCESS_ID = p_set_process_id
    AND EXISTS
      (
      SELECT NULL
      FROM MTL_PARAMETERS mp
      WHERE mp.MASTER_ORGANIZATION_ID = p_organization_id
        AND mp.ORGANIZATION_ID <> mp.MASTER_ORGANIZATION_ID
        AND (  (msii.ORGANIZATION_ID IS NOT NULL AND mp.ORGANIZATION_ID = msii.ORGANIZATION_ID)
            OR
            (msii.ORGANIZATION_ID IS NULL AND mp.ORGANIZATION_CODE = msii.ORGANIZATION_CODE)
            )
      );


  CURSOR cr_revision (p_set_process_id NUMBER, p_organization_id NUMBER) IS
    SELECT
      COUNT(1) AS CNT ,
      COUNT(
        CASE
        WHEN PROCESS_FLAG = 7
        AND UPPER(TRANSACTION_TYPE)= 'CREATE'
        THEN 1
        ELSE NULL
        END
        ) AS NEW_CNT ,
      COUNT(
        CASE
        WHEN PROCESS_FLAG = 7
        AND UPPER(TRANSACTION_TYPE)= 'UPDATE'
        THEN 1
        ELSE NULL
        END
        ) UPDATE_CNT
    FROM  MTL_ITEM_REVISIONS_INTERFACE miri
    WHERE SET_PROCESS_ID = p_set_process_id
      AND EXISTS
        (
          SELECT NULL
          FROM MTL_PARAMETERS mp
          WHERE mp.MASTER_ORGANIZATION_ID = p_organization_id
          AND (  (miri.ORGANIZATION_ID IS NOT NULL AND mp.ORGANIZATION_ID = miri.ORGANIZATION_ID)
              OR
              (miri.ORGANIZATION_ID IS NULL AND mp.ORGANIZATION_CODE = miri.ORGANIZATION_CODE)
              )
        );


  CURSOR cr_structure (p_set_process_id NUMBER, p_organization_id NUMBER) IS
    SELECT
      COUNT(
        CASE
        WHEN UPPER(TRANSACTION_TYPE) <> 'NO_OP'
        THEN 1
        ELSE NULL
        END
        ) AS CNT ,
      COUNT(
        CASE
        WHEN PROCESS_FLAG = 7
        AND UPPER(TRANSACTION_TYPE)= 'CREATE'
        THEN 1
        ELSE NULL
        END
        ) AS NEW_CNT ,
      COUNT(
        CASE
        WHEN PROCESS_FLAG = 7
        AND UPPER(TRANSACTION_TYPE) IN ( 'UPDATE', 'DELETE' )
        THEN 1
        ELSE NULL
        END
        ) UPDATE_CNT
    FROM BOM_INVENTORY_COMPS_INTERFACE bici
    WHERE bici.BATCH_ID = p_set_process_id
      AND EXISTS
          (
              SELECT NULL
              FROM MTL_PARAMETERS mp
              WHERE mp.MASTER_ORGANIZATION_ID = p_organization_id
              AND (  (bici.ORGANIZATION_ID IS NOT NULL AND mp.ORGANIZATION_ID = bici.ORGANIZATION_ID)
                     OR
                     (bici.ORGANIZATION_ID IS NULL AND mp.ORGANIZATION_CODE = bici.ORGANIZATION_CODE)
                  )
          );


  CURSOR cr_people (p_set_process_id NUMBER, p_organization_id NUMBER) IS
    SELECT
      COUNT(1) AS CNT ,
      COUNT(
        CASE
        WHEN PROCESS_STATUS = 4
        AND UPPER(TRANSACTION_TYPE)= 'CREATE'
        THEN 1
        ELSE NULL
        END
        ) AS NEW_CNT ,
      COUNT(
        CASE
        WHEN PROCESS_STATUS = 4
        AND ( UPPER(TRANSACTION_TYPE) IN ('UPDATE', 'DELETE') )
        THEN 1
        ELSE NULL
        END
        ) UPDATE_CNT
    FROM EGO_ITEM_PEOPLE_INTF eipi
    WHERE eipi.DATA_SET_ID = p_set_process_id
      AND EXISTS
      (
        SELECT NULL
        FROM MTL_PARAMETERS mp
        WHERE mp.MASTER_ORGANIZATION_ID = p_organization_id
          AND (  (eipi.ORGANIZATION_ID IS NOT NULL AND mp.ORGANIZATION_ID = eipi.ORGANIZATION_ID)
              OR
              (eipi.ORGANIZATION_ID IS NULL AND mp.ORGANIZATION_CODE = eipi.ORGANIZATION_CODE)
        )
      ) ;


  CURSOR cr_category_assignment (p_set_process_id NUMBER, p_organization_id NUMBER) IS
    SELECT
      COUNT(1) AS CNT ,
      COUNT(
        CASE
        WHEN PROCESS_FLAG = 7
        AND UPPER(TRANSACTION_TYPE)= 'CREATE'
        THEN 1
        ELSE NULL
        END
        ) AS NEW_CNT ,
      COUNT(
        CASE
        WHEN PROCESS_FLAG = 7
        AND ( UPPER(TRANSACTION_TYPE) IN ( 'UPDATE','DELETE') )
        THEN 1
        ELSE NULL
        END
        ) UPDATE_CNT
    FROM MTL_ITEM_CATEGORIES_INTERFACE mici
    WHERE mici.SET_PROCESS_ID = p_set_process_id
      AND EXISTS
        (
          SELECT NULL
          FROM MTL_PARAMETERS mp
          WHERE mp.MASTER_ORGANIZATION_ID = p_organization_id
            AND (  (mici.ORGANIZATION_ID IS NOT NULL AND mp.ORGANIZATION_ID = mici.ORGANIZATION_ID)
                    OR
                   (mici.ORGANIZATION_ID IS NULL AND mp.ORGANIZATION_CODE = mici.ORGANIZATION_CODE)
                )
        );


  CURSOR cr_aml (p_set_process_id NUMBER, p_organization_id NUMBER) IS
    SELECT
      COUNT(1) AS CNT ,
      COUNT(
        CASE
        WHEN PROCESS_FLAG = 7
        AND UPPER(TRANSACTION_TYPE)= 'CREATE'
        THEN 1
        ELSE NULL
        END
        ) AS NEW_CNT ,
      COUNT(
        CASE
        WHEN PROCESS_FLAG = 7
        AND UPPER(TRANSACTION_TYPE)= 'UPDATE'
        THEN 1
        ELSE NULL
        END
        ) UPDATE_CNT
    FROM EGO_AML_INTF eai
    WHERE eai.DATA_SET_ID = p_set_process_id
      AND EXISTS
        (
          SELECT NULL
          FROM MTL_PARAMETERS mp
          WHERE mp.MASTER_ORGANIZATION_ID = p_organization_id
            AND (  (eai.ORGANIZATION_ID IS NOT NULL AND mp.ORGANIZATION_ID = eai.ORGANIZATION_ID)
                OR
                (eai.ORGANIZATION_ID IS NULL AND mp.ORGANIZATION_CODE = eai.ORGANIZATION_CODE)
                )
        );


  CURSOR cr_component_ops (p_set_process_id NUMBER, p_organization_id NUMBER) IS
    SELECT
      COUNT(1) AS CNT ,
      COUNT(
        CASE
        WHEN PROCESS_FLAG = 7
        AND UPPER(TRANSACTION_TYPE)= 'CREATE'
        THEN 1
        ELSE NULL
        END
        ) AS NEW_CNT ,
      COUNT(
        CASE
        WHEN PROCESS_FLAG = 7
        AND UPPER(TRANSACTION_TYPE)= 'UPDATE'
        THEN 1
        ELSE NULL
        END
        ) UPDATE_CNT
    FROM BOM_COMPONENT_OPS_INTERFACE bcoi
    WHERE bcoi.BATCH_ID = p_set_process_id
      AND EXISTS
      (
        SELECT NULL
        FROM MTL_PARAMETERS mp
        WHERE mp.MASTER_ORGANIZATION_ID = p_organization_id
          AND (  (bcoi.ORGANIZATION_ID IS NOT NULL AND mp.ORGANIZATION_ID = bcoi.ORGANIZATION_ID)
                 OR
                 (bcoi.ORGANIZATION_ID IS NULL AND mp.ORGANIZATION_CODE = bcoi.ORGANIZATION_CODE)
              )
      );


  CURSOR cr_ref_desgs (p_set_process_id NUMBER, p_organization_id NUMBER) IS
    SELECT
      COUNT(1) AS CNT ,
      COUNT(
        CASE
        WHEN PROCESS_FLAG = 7
        AND UPPER(TRANSACTION_TYPE)= 'CREATE'
        THEN 1
        ELSE NULL
        END
        ) AS NEW_CNT ,
      COUNT(
        CASE
        WHEN PROCESS_FLAG = 7
        AND UPPER(TRANSACTION_TYPE)= 'UPDATE'
        THEN 1
        ELSE NULL
        END
        ) UPDATE_CNT
    FROM BOM_REF_DESGS_INTERFACE brdi
    WHERE brdi.BATCH_ID = p_set_process_id
      AND EXISTS
      (
        SELECT NULL
        FROM MTL_PARAMETERS mp
        WHERE mp.MASTER_ORGANIZATION_ID = p_organization_id
          AND (  (brdi.ORGANIZATION_ID IS NOT NULL AND mp.ORGANIZATION_ID = brdi.ORGANIZATION_ID)
                 OR
                 (brdi.ORGANIZATION_ID IS NULL AND mp.ORGANIZATION_CODE = brdi.ORGANIZATION_CODE)
              )
      );


  CURSOR cr_sub_comps (p_set_process_id NUMBER, p_organization_id NUMBER) IS
    SELECT
      COUNT(1) AS CNT ,
      COUNT(
        CASE
        WHEN PROCESS_FLAG = 7
        AND UPPER(TRANSACTION_TYPE)= 'CREATE'
        THEN 1
        ELSE NULL
        END
        ) AS NEW_CNT ,
      COUNT(
        CASE
        WHEN PROCESS_FLAG = 7
        AND UPPER(TRANSACTION_TYPE)= 'UPDATE'
        THEN 1
        ELSE NULL
        END
        ) UPDATE_CNT
    FROM BOM_SUB_COMPS_INTERFACE bsci
    WHERE bsci.BATCH_ID = p_set_process_id
      AND EXISTS
      (
        SELECT NULL
        FROM MTL_PARAMETERS mp
        WHERE mp.MASTER_ORGANIZATION_ID = p_organization_id
          AND (  (bsci.ORGANIZATION_ID IS NOT NULL AND mp.ORGANIZATION_ID = bsci.ORGANIZATION_ID)
                 OR
                 (bsci.ORGANIZATION_ID IS NULL AND mp.ORGANIZATION_CODE = bsci.ORGANIZATION_CODE)
              )
      );


  CURSOR cr_bill_of_mtls (p_set_process_id NUMBER, p_organization_id NUMBER) IS
    SELECT
        COUNT(
        CASE
        WHEN UPPER(TRANSACTION_TYPE) <> 'NO_OP'
        THEN 1
        ELSE NULL
        END
        ) AS CNT ,
      COUNT(
        CASE
        WHEN PROCESS_FLAG = 7
        AND UPPER(TRANSACTION_TYPE)= 'CREATE'
        THEN 1
        ELSE NULL
        END
        ) AS NEW_CNT ,
      COUNT(
        CASE
        WHEN PROCESS_FLAG = 7
        AND UPPER(TRANSACTION_TYPE)= 'UPDATE'
        THEN 1
        ELSE NULL
        END
        ) UPDATE_CNT
    FROM BOM_BILL_OF_MTLS_INTERFACE bomi
    WHERE bomi.BATCH_ID = p_set_process_id
      AND EXISTS
      (
        SELECT NULL
        FROM MTL_PARAMETERS mp
        WHERE mp.MASTER_ORGANIZATION_ID = p_organization_id
          AND (  (bomi.ORGANIZATION_ID IS NOT NULL AND mp.ORGANIZATION_ID = bomi.ORGANIZATION_ID)
                 OR
                 (bomi.ORGANIZATION_ID IS NULL AND mp.ORGANIZATION_CODE = bomi.ORGANIZATION_CODE)
              )
      );

  CURSOR cr_item_sup (p_set_process_id NUMBER, p_organization_id NUMBER) IS
    SELECT
      edlb.DATA_LEVEL_NAME AS DATA_LEVEL_NAME,
      COUNT(1) AS CNT ,
      COUNT(
        CASE
        WHEN PROCESS_FLAG = 7
        AND UPPER(TRANSACTION_TYPE)= 'CREATE'
        THEN 1
        ELSE NULL
        END
        ) AS NEW_CNT ,
      COUNT(
        CASE
        WHEN PROCESS_FLAG = 7
        AND UPPER(TRANSACTION_TYPE)= 'UPDATE'
        THEN 1
        ELSE NULL
        END
        ) UPDATE_CNT
    FROM EGO_ITEM_ASSOCIATIONS_INTF eiai, EGO_DATA_LEVEL_B edlb
    WHERE eiai.BATCH_ID = p_set_process_id
      AND eiai.DATA_LEVEL_ID = edlb.DATA_LEVEL_ID
      AND EXISTS
        (
          SELECT NULL
          FROM MTL_PARAMETERS mp
          WHERE mp.MASTER_ORGANIZATION_ID = p_organization_id
            AND (  (eiai.ORGANIZATION_ID IS NOT NULL AND mp.ORGANIZATION_ID = eiai.ORGANIZATION_ID)
                OR
                (eiai.ORGANIZATION_ID IS NULL AND mp.ORGANIZATION_CODE = eiai.ORGANIZATION_CODE)
                )
        )
    GROUP BY edlb.DATA_LEVEL_NAME;


  CURSOR cr_lookup  IS
    SELECT LOOKUP_CODE,
      MEANING,
      TAG
    FROM FND_LOOKUP_VALUES_VL
    WHERE LOOKUP_TYPE='EGO_PDH_ENTITY_TYPES'
      AND VIEW_APPLICATION_ID = 0
      AND SECURITY_GROUP_ID = fnd_global.lookup_security_group(LOOKUP_TYPE, VIEW_APPLICATION_ID);


  TYPE   TABLE_TAG_TYPE         IS TABLE OF VARCHAR2(150) INDEX BY VARCHAR2(30);
  TYPE   TABLE_MEANING_TYPE     IS TABLE OF VARCHAR2(80) INDEX BY VARCHAR2(30);


  l_row_type          SYSTEM.EGO_IMPORT_CNT_REC;
  l_return_table      SYSTEM.EGO_IMPORT_CNT_TABLE;
  l_tag               TABLE_TAG_TYPE;
  l_meaning           TABLE_MEANING_TYPE;
  l_import_xref_only  VARCHAR2(1);

  BEGIN
    l_return_table := SYSTEM.EGO_IMPORT_CNT_TABLE();
    l_row_type     := SYSTEM.EGO_IMPORT_CNT_REC('',0,0,0,0,0);

    -- Bug: 5262421, if IMPORT_XREF_ONLY is 'Y', then we will show 0 as after import count for AML
    BEGIN
      SELECT NVL(opt.IMPORT_XREF_ONLY, 'N') INTO l_import_xref_only
      FROM EGO_IMPORT_BATCHES_B b, EGO_IMPORT_OPTION_SETS opt
      WHERE b.BATCH_ID = p_set_process_id
        AND b.BATCH_ID = opt.BATCH_ID;
    EXCEPTION WHEN NO_DATA_FOUND THEN
      l_import_xref_only := 'N';
    END;

    FOR i IN cr_lookup
    LOOP
      l_tag(i.LOOKUP_CODE) := i.TAG;
      l_meaning(i.LOOKUP_CODE) := i.MEANING;
    END LOOP;

    FOR i IN cr_item( p_set_process_id, p_organization_id, p_organization_code)
    LOOP
      IF i.CNT > 0 THEN
        l_return_table.EXTEND();
        l_row_type.MEANING := l_meaning('ITEM');
        l_row_type.CNT := i.CNT;
        l_row_type.NEW_CNT := i.NEW_CNT;
        l_row_type.TAG := l_tag('ITEM');
        l_row_type.UPDATE_CNT := i.UPDATE_CNT;
        l_row_type.AFTER_IMPORT_TOTAL := i.NEW_CNT + i.UPDATE_CNT;
        l_return_table(l_return_table.LAST) := l_row_type;
      END IF;
    END LOOP;

    FOR i IN cr_org_assign (p_set_process_id, p_organization_id)
    LOOP
      IF i.CNT > 0 THEN
        l_return_table.EXTEND();
        l_row_type.MEANING := l_meaning('ORG_ASSIGN');
        l_row_type.CNT := i.CNT;
        l_row_type.NEW_CNT := i.NEW_CNT;
        l_row_type.TAG := l_tag('ORG_ASSIGN');
        l_row_type.UPDATE_CNT := i.UPDATE_CNT;
        l_row_type.AFTER_IMPORT_TOTAL := i.NEW_CNT + i.UPDATE_CNT;
        l_return_table(l_return_table.LAST) := l_row_type;
      END IF;
    END LOOP;

    FOR i IN cr_revision (p_set_process_id, p_organization_id)
    LOOP
      IF i.CNT > 0 THEN
        l_return_table.EXTEND();
        l_row_type.MEANING := l_meaning('REVISION');
        l_row_type.CNT := i.CNT;
        l_row_type.NEW_CNT := i.NEW_CNT;
        l_row_type.TAG := l_tag('REVISION');
        l_row_type.UPDATE_CNT := i.UPDATE_CNT;
        l_row_type.AFTER_IMPORT_TOTAL := i.NEW_CNT + i.UPDATE_CNT;
        l_return_table(l_return_table.LAST) := l_row_type;
      END IF;
    END LOOP;

    FOR i IN cr_structure (p_set_process_id, p_organization_id)
    LOOP
      IF i.CNT > 0 THEN
        l_return_table.EXTEND();
        l_row_type.MEANING := l_meaning('STRUCTURE');
        l_row_type.CNT := i.CNT;
        l_row_type.NEW_CNT := i.NEW_CNT;
        l_row_type.TAG := l_tag('STRUCTURE');
        l_row_type.UPDATE_CNT := i.UPDATE_CNT;
        l_row_type.AFTER_IMPORT_TOTAL := i.NEW_CNT + i.UPDATE_CNT;
        l_return_table(l_return_table.LAST) := l_row_type;
      END IF;
    END LOOP;

    FOR i IN cr_people (p_set_process_id, p_organization_id)
    LOOP
      IF i.CNT > 0 THEN
        l_return_table.EXTEND();
        l_row_type.MEANING := l_meaning('PEOPLE');
        l_row_type.CNT := i.CNT;
        l_row_type.NEW_CNT := i.NEW_CNT;
        l_row_type.TAG := l_tag('PEOPLE');
        l_row_type.UPDATE_CNT := i.UPDATE_CNT;
        l_row_type.AFTER_IMPORT_TOTAL := i.NEW_CNT + i.UPDATE_CNT;
        l_return_table(l_return_table.LAST) := l_row_type;
      END IF;
    END LOOP;

    FOR i IN cr_category_assignment (p_set_process_id, p_organization_id)
    LOOP
      IF i.CNT > 0 THEN
        l_return_table.EXTEND();
        l_row_type.MEANING := l_meaning('CATEGORY_ASSIGN');
        l_row_type.CNT := i.CNT;
        l_row_type.NEW_CNT := i.NEW_CNT;
        l_row_type.TAG := l_tag('CATEGORY_ASSIGN');
        l_row_type.UPDATE_CNT := i.UPDATE_CNT;
        l_row_type.AFTER_IMPORT_TOTAL := i.NEW_CNT + i.UPDATE_CNT;
        l_return_table(l_return_table.LAST) := l_row_type;
      END IF;
    END LOOP;

    FOR i IN cr_aml (p_set_process_id, p_organization_id)
    LOOP
      IF i.CNT > 0 THEN
        l_return_table.EXTEND();
        l_row_type.MEANING := l_meaning( 'AML');
        l_row_type.CNT := i.CNT;
        -- Bug: 5262421, if l_import_xref_only is Y, then in after import total only show 0
        IF NVL(l_import_xref_only, 'N') = 'Y' THEN
          l_row_type.NEW_CNT := 0;
          l_row_type.UPDATE_CNT := 0;
          l_row_type.AFTER_IMPORT_TOTAL := 0;
        ELSE
          l_row_type.NEW_CNT := i.NEW_CNT;
          l_row_type.UPDATE_CNT := i.UPDATE_CNT;
          l_row_type.AFTER_IMPORT_TOTAL := i.NEW_CNT + i.UPDATE_CNT;
        END IF;
        l_row_type.TAG := l_tag( 'AML');
        l_return_table(l_return_table.LAST) := l_row_type;
      END IF;
    END LOOP;

    FOR i IN cr_component_ops (p_set_process_id, p_organization_id)
    LOOP
      IF i.CNT > 0 THEN
        l_return_table.EXTEND();
        l_row_type.MEANING := l_meaning('COMPONENT_OPS');
        l_row_type.CNT := i.CNT;
        l_row_type.NEW_CNT := i.NEW_CNT;
        l_row_type.TAG := l_tag('COMPONENT_OPS');
        l_row_type.UPDATE_CNT := i.UPDATE_CNT;
        l_row_type.AFTER_IMPORT_TOTAL := i.NEW_CNT + i.UPDATE_CNT;
        l_return_table(l_return_table.LAST) := l_row_type;
      END IF;
    END LOOP;

    FOR i IN cr_ref_desgs (p_set_process_id, p_organization_id)
    LOOP
      IF i.CNT > 0 THEN
        l_return_table.EXTEND();
        l_row_type.MEANING := l_meaning('REF_DESGS');
        l_row_type.CNT := i.CNT;
        l_row_type.NEW_CNT := i.NEW_CNT;
        l_row_type.TAG := l_tag('REF_DESGS');
        l_row_type.UPDATE_CNT := i.UPDATE_CNT;
        l_row_type.AFTER_IMPORT_TOTAL := i.NEW_CNT + i.UPDATE_CNT;
        l_return_table(l_return_table.LAST) := l_row_type;
      END IF;
    END LOOP;

    FOR i IN cr_sub_comps (p_set_process_id, p_organization_id)
    LOOP
      IF i.CNT > 0 THEN
        l_return_table.EXTEND();
        l_row_type.MEANING := l_meaning('SUB_COMPS');
        l_row_type.CNT := i.CNT;
        l_row_type.NEW_CNT := i.NEW_CNT;
        l_row_type.TAG := l_tag('SUB_COMPS');
        l_row_type.UPDATE_CNT := i.UPDATE_CNT;
        l_row_type.AFTER_IMPORT_TOTAL := i.NEW_CNT + i.UPDATE_CNT;
        l_return_table(l_return_table.LAST) := l_row_type;
      END IF;
    END LOOP;

    FOR i IN cr_bill_of_mtls (p_set_process_id, p_organization_id )
    LOOP
      IF i.CNT > 0 THEN
        l_return_table.EXTEND();
        l_row_type.MEANING := l_meaning('BILL_OF_MTLS');
        l_row_type.CNT := i.CNT;
        l_row_type.NEW_CNT := i.NEW_CNT;
        l_row_type.TAG := l_tag('BILL_OF_MTLS');
        l_row_type.UPDATE_CNT := i.UPDATE_CNT;
        l_row_type.AFTER_IMPORT_TOTAL := i.NEW_CNT + i.UPDATE_CNT;
        l_return_table(l_return_table.LAST) := l_row_type;
      END IF;
    END LOOP;

    FOR i IN cr_item_sup (p_set_process_id, p_organization_id )
    LOOP
      IF i.CNT > 0 THEN
        l_return_table.EXTEND();
        IF i.DATA_LEVEL_NAME = 'ITEM_SUP' THEN
          l_row_type.MEANING := l_meaning('ITEM_SUP');
          l_row_type.TAG := l_tag('ITEM_SUP');
        ELSIF i.DATA_LEVEL_NAME = 'ITEM_SUP_SITE' THEN
          l_row_type.MEANING := l_meaning('ITEM_SUP_SITE');
          l_row_type.TAG := l_tag('ITEM_SUP_SITE');
        ELSIF i.DATA_LEVEL_NAME = 'ITEM_SUP_SITE_ORG' THEN
          l_row_type.MEANING := l_meaning('ITEM_ORG_SUP_SITE');
          l_row_type.TAG := l_tag('ITEM_ORG_SUP_SITE');
        END IF;
        l_row_type.CNT := i.CNT;
        l_row_type.NEW_CNT := i.NEW_CNT;
        l_row_type.UPDATE_CNT := i.UPDATE_CNT;
        l_row_type.AFTER_IMPORT_TOTAL := i.NEW_CNT + i.UPDATE_CNT;
        l_return_table(l_return_table.LAST) := l_row_type;
      END IF;
    END LOOP;

    RETURN  l_return_table ;
  EXCEPTION
    WHEN OTHERS THEN
      l_row_type := SYSTEM.EGO_IMPORT_CNT_REC('',0,0,0,0,0);
      l_return_table := SYSTEM.EGO_IMPORT_CNT_TABLE();
      l_row_type.MEANING := SQLERRM;
      l_return_table.EXTEND();
      l_return_table(l_return_table.LAST) := l_row_type;
      RETURN l_return_table;
  END GET_IMPORT_DETAILS_DATA;

  /*
   * This method updates the request_ids to ego_import_batches_b table.
   */
  PROCEDURE Update_Request_Id_To_Batch (
            p_import_request_id  IN NUMBER,
            p_match_request_id   IN NUMBER,
            p_batch_id           IN NUMBER)
  IS
  BEGIN
    IF ( NVL(p_import_request_id, 0) > 0 ) OR ( NVL(p_match_request_id, 0) > 0 ) THEN
      UPDATE EGO_IMPORT_BATCHES_B
      SET LAST_MATCH_REQUEST_ID = DECODE(p_match_request_id, NULL, LAST_MATCH_REQUEST_ID, 0, LAST_MATCH_REQUEST_ID, p_match_request_id),
          LAST_IMPORT_REQUEST_ID = DECODE(p_import_request_id, NULL, LAST_IMPORT_REQUEST_ID, 0, LAST_IMPORT_REQUEST_ID, p_import_request_id)
      WHERE BATCH_ID = p_batch_id;
    END IF; -- IF ( NVL(p_import_request_id, 0) > 0 ) OR ( NVL(p_match_request_id, 0) > 0 ) THEN
  END Update_Request_Id_To_Batch;

END EGO_IMPORT_PVT;

/
