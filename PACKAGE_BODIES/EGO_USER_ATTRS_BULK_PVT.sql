--------------------------------------------------------
--  DDL for Package Body EGO_USER_ATTRS_BULK_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EGO_USER_ATTRS_BULK_PVT" AS
/* $Header: EGOVBUAB.pls 120.75.12010000.74 2012/07/30 13:12:26 pnagasur ship $ */

                      ------------------------
                      -- Private Data Types --
                      ------------------------

    TYPE DIST_ATTR_IN_DATA_SET_REC IS RECORD
    (
      ATTR_GROUP_ID                     NUMBER
     ,ATTR_INT_NAME                     VARCHAR2(30)
     ,ATTR_GROUP_INT_NAME               VARCHAR2(30)
    );
    TYPE DIST_ATTR_IN_DATA_SET_TABLE IS TABLE OF DIST_ATTR_IN_DATA_SET_REC
      INDEX BY BINARY_INTEGER;

    TYPE PK_COL_REC IS RECORD  (PK_COL_1  VARCHAR2(300)
                               ,PK_COL_2  VARCHAR2(300)
                               ,PK_COL_3  VARCHAR2(300)
                               ,PK_COL_4  VARCHAR2(300)
                               ,PK_COL_5  VARCHAR2(300)
                               );
    TYPE PK_COL_TABLE IS TABLE OF PK_COL_REC INDEX BY BINARY_INTEGER;


                   ------------------------------
                   -- Private Global Variables --
                   ------------------------------

    G_PKG_NAME           CONSTANT VARCHAR2(30) := 'EGO_USER_ATTRS_BULK_PVT';

    G_CURRENT_USER_ID             NUMBER;
    G_CURRENT_LOGIN_ID            NUMBER;
    G_API_VERSION                 NUMBER;

    G_USER_NAME                   FND_USER.USER_NAME%TYPE;
    G_HZ_PARTY_ID                 VARCHAR2(30);

    G_NO_USER_NAME_TO_VALIDATE    EXCEPTION;

    -- used for error handling.
    G_ADD_ERRORS_TO_FND_STACK     VARCHAR2(1);
    G_APPLICATION_CONTEXT         VARCHAR2(30);
    G_ENTITY_ID                   NUMBER;
    G_ENTITY_CODE                 VARCHAR2(30);

    G_PK_COLS_TABLE               PK_COL_TABLE;

    G_REQUEST_ID                  NUMBER := FND_GLOBAL.CONC_REQUEST_ID;

    G_FND_RET_STS_WARNING         VARCHAR2(1):= 'W';

                          -------------------------
                          -- Private Procedures  --
                          -------------------------

----------------------------------------------------------------------

procedure code_debug (msg   IN  VARCHAR2
                     ,debug_level  IN  NUMBER  default 3
                     ) IS
BEGIN
null;
--  IF (INSTR(msg, 'Insert_Default_Val_Rows') <> 0 ) THEN
--    sri_debug('EGOVBUAB '||msg);
--  END IF;
--  EGO_USER_ATTRS_DATA_PVT.Debug_Msg(msg , debug_level);

IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
  IF NVL(FND_GLOBAL.conc_request_id, -1) <> -1 THEN

    FND_FILE.put_line(which => FND_FILE.LOG
                     ,buff  => '[EGOVBUAB] '||msg);
  END IF;
END IF;
EXCEPTION
  WHEN OTHERS THEN
    NULL;
END code_debug;

----------------------------------------------------------------------

PROCEDURE write_intf_records (p_data_set_id    in number
                             ,p_count   IN  NUMBER
                             ) IS
-- PRAGMA AUTONOMOUS_TRANSACTION;

  l_rec  ego_itm_usr_attr_intrfc%ROWTYPE;
  l_dummy_number  NUMBER;
BEGIN
NULL;
/***
  SELECT count(*)
  INTO l_dummy_number
  FROM ego_itm_usr_attr_intrfc
  WHERE data_set_id = p_data_set_id;
  code_debug(p_log_level => 0
            ,p_module => 'write_intf_records'
            ,p_message => p_count||' - No records in intf table '||l_dummy_number
            );
  IF l_dummy_number > 0 THEN
    code_debug(p_log_level => 0
              ,p_module => 'write_intf_records'
              ,p_message => p_count||' Writing data in format '||
        ' inventory_item_id, organization_id, data_level_id, revision_id, pk1_value, pk2_value, '||
        ' attr_group_id, attr_group_int_name, attr_int_name, attr_value_str, attr_value_num, '||
        ' row_identifier');
    IF p_count < 100 THEN
      FOR cr in (SELECT * FROM ego_itm_usr_attr_intrfc
                  WHERE data_set_id = p_data_set_id
              ORDER BY inventory_item_id, organization_id, data_level_id,
                       revision_id, pk1_value, pk2_value, attr_group_id,
                       attr_int_name, row_identifier
                ) LOOP
        code_debug(p_log_level => 0
                  ,p_module => 'write_intf_records'
                  ,p_message => p_count||' - '||cr.inventory_item_id||', '||
                         cr.organization_id||', '||cr.data_level_id||', '||cr.revision_id||', '||
                         cr.pk1_value||',  '||cr.pk2_value||', '||cr.attr_group_id||', '||
                         cr.attr_group_int_name||', '||cr.attr_int_name||',  '||
                         cr.attr_value_str||', '||cr.attr_value_num||', '||cr.row_identifier);
      END LOOP;
    END IF;
  END IF;
***/
END write_intf_records;

----------------------------------------------------------------------

FUNCTION Attr_Is_In_Data_Set (
        p_attr_metadata_obj             IN   EGO_ATTR_METADATA_OBJ
       ,p_dist_attrs_in_data_set_table  IN   DIST_ATTR_IN_DATA_SET_TABLE
) RETURN BOOLEAN
IS

    l_is_in_data_set                    BOOLEAN;

  BEGIN

    l_is_in_data_set := FALSE;
    IF (p_dist_attrs_in_data_set_table.COUNT > 0) THEN
      FOR i IN p_dist_attrs_in_data_set_table.FIRST .. p_dist_attrs_in_data_set_table.LAST
      LOOP
        EXIT WHEN l_is_in_data_set;
        IF (p_dist_attrs_in_data_set_table(i).ATTR_INT_NAME = p_attr_metadata_obj.ATTR_NAME) THEN
          l_is_in_data_set := TRUE;
        END IF;
      END LOOP;
    END IF;

    RETURN l_is_in_data_set;

END Attr_Is_In_Data_Set;

----------------------------------------------------------------------

Function GET_ATTR_OBJECT
  (p_attr_grp_meta_obj IN EGO_ATTR_GROUP_METADATA_OBJ
  ,p_attr_int_name     IN VARCHAR2)
  RETURN EGO_ATTR_METADATA_OBJ IS
  --
  -- used by log_error_messages
  -- returns the attribute metadata object
  --
    l_attr_metadata_obj     EGO_ATTR_METADATA_TABLE;
  BEGIN
    l_attr_metadata_obj := p_attr_grp_meta_obj.ATTR_METADATA_TABLE;
    IF l_attr_metadata_obj.count > 0 THEN
      FOR i IN l_attr_metadata_obj.FIRST .. l_attr_metadata_obj.LAST LOOP
        IF l_attr_metadata_obj(i).attr_name = p_attr_int_name THEN
          RETURN l_attr_metadata_obj(i);
        END IF;
      END LOOP;
    END IF;
    RETURN NULL;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END GET_ATTR_OBJECT;

----------------------------------------------------------------------

Function GET_ENTITY_INDEX
  (p_entity_index        IN  NUMBER
  ,p_instance_pk1_value  IN  VARCHAR2
  ,p_instance_pk2_value  IN  VARCHAR2
  ,p_instance_pk3_value  IN  VARCHAR2
  ,p_instance_pk4_value  IN  VARCHAR2
  ,p_instance_pk5_value  IN  VARCHAR2
  ) RETURN NUMBER IS
  --
  -- used to get the entity index for error logging
  --
    l_entity_index     NUMBER;
    l_pk_col_rec       PK_COL_REC;
    l_null_char_value  VARCHAR2(10);
  BEGIN
    IF NVL(p_entity_index,0) <> 0 THEN
      RETURN p_entity_index;
    ELSE
      l_entity_index := NULL;
      l_null_char_value := FND_API.G_MISS_CHAR;
      l_pk_col_rec.pk_col_1 := NVL(p_instance_pk1_value, l_null_char_value);
      l_pk_col_rec.pk_col_2 := NVL(p_instance_pk2_value, l_null_char_value);
      l_pk_col_rec.pk_col_3 := NVL(p_instance_pk3_value, l_null_char_value);
      l_pk_col_rec.pk_col_4 := NVL(p_instance_pk4_value, l_null_char_value);
      l_pk_col_rec.pk_col_5 := NVL(p_instance_pk5_value, l_null_char_value);
      IF (G_PK_COLS_TABLE.COUNT > 0) THEN
        FOR i IN G_PK_COLS_TABLE.FIRST .. G_PK_COLS_TABLE.LAST LOOP
          EXIT WHEN l_entity_index IS NOT NULL;
          IF (G_PK_COLS_TABLE(i).pk_col_1 = l_pk_col_rec.pk_col_1 AND
              G_PK_COLS_TABLE(i).pk_col_2 = l_pk_col_rec.pk_col_2 AND
              G_PK_COLS_TABLE(i).pk_col_3 = l_pk_col_rec.pk_col_3 AND
              G_PK_COLS_TABLE(i).pk_col_4 = l_pk_col_rec.pk_col_4 AND
              G_PK_COLS_TABLE(i).pk_col_5 = l_pk_col_rec.pk_col_5 ) THEN
            l_entity_index := i;
          END IF;
        END LOOP;
      ELSE
        -- no records exist
        NULL;
      END IF;
      IF l_entity_index IS NULL THEN
        l_entity_index := G_PK_COLS_TABLE.COUNT+1;
        G_PK_COLS_TABLE(l_entity_index) := l_pk_col_rec;
      END IF;
      RETURN l_entity_index;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN -1;
  END GET_ENTITY_INDEX;

----------------------------------------------------------------------

PROCEDURE Log_Errors_Now (
        p_entity_id                     IN   NUMBER
       ,p_entity_index                  IN   NUMBER
       ,p_entity_code                   IN   VARCHAR2
       ,p_object_name                   IN   VARCHAR2
       ,p_pk1_column_name               IN   VARCHAR2
       ,p_pk2_column_name               IN   VARCHAR2
       ,p_pk3_column_name               IN   VARCHAR2
       ,p_pk4_column_name               IN   VARCHAR2
       ,p_pk5_column_name               IN   VARCHAR2
       ,p_classification_col_name       IN   VARCHAR2
       ,p_interface_table_name          IN   VARCHAR2
       ,p_err_col_static_sql            IN   VARCHAR2
       ,p_err_where_static_sql          IN   VARCHAR2
       ,p_attr_grp_meta_obj             IN   EGO_ATTR_GROUP_METADATA_OBJ
       ,p_data_set_id                   IN   NUMBER DEFAULT NULL /*Fix for bug#9678667. Literal to bind*/
) IS
  --
  -- no exception is thrown
  -- calling program will handle the exceptions.
  --
    l_err_token_table             ERROR_HANDLER.Token_Tbl_Type;
    l_err_col_dynamic_sql         VARCHAR2(32767);
    l_err_where_dynamic_sql       VARCHAR2(32767);
    l_err_sql                     VARCHAR2(32767);
    l_err_msg_name                VARCHAR2(99);
    l_attr_grp_disp_name          FND_DESCR_FLEX_CONTEXTS_TL.descriptive_flex_context_name%TYPE;
    l_attr_metadata_obj           EGO_ATTR_METADATA_OBJ;
    l_attr_disp_name              FND_DESCR_FLEX_CONTEXTS_TL.descriptive_flex_context_name%TYPE;
    l_comma_message               VARCHAR2(99);
    l_msg_token_value             VARCHAR2(32767);
    l_attr_table                  EGO_ATTR_METADATA_TABLE;
    l_entity_index                NUMBER;

    TYPE DYNAMIC_CUR IS REF CURSOR;
    c_err_cursor                  DYNAMIC_CUR;

    TYPE error_record_type IS RECORD
       (process_status       NUMBER
       ,row_identifier       NUMBER
       ,attr_group_int_name  VARCHAR2(999)
       ,attr_int_name        VARCHAR2(999)
       ,attr_value_str       VARCHAR2(32767)
       ,attr_value_num       NUMBER
       ,attr_value_date      DATE
       ,attr_disp_value      VARCHAR2(32767)
       ,transaction_type     VARCHAR2(99)
       ,transaction_id       NUMBER
       ,attr_group_id        NUMBER
       ,pk_col_1             VARCHAR2(256)
       ,pk_col_2             VARCHAR2(256)
       ,pk_col_3             VARCHAR2(256)
       ,pk_col_4             VARCHAR2(256)
       ,pk_col_5             VARCHAR2(256)
       ,class_code_value     VARCHAR2(256)
       );

    error_rec   error_record_type;

  BEGIN
    -- add the key value into the fetch columns.
    IF (p_pk1_column_name IS NOT NULL) THEN
      l_err_col_dynamic_sql := ', '||p_pk1_column_name||' AS pk_col_1 ';
    ELSE
      l_err_col_dynamic_sql := ', NULL AS pk_col_1 ';
    END IF;
    IF (p_pk2_column_name IS NOT NULL) THEN
      l_err_col_dynamic_sql := l_err_col_dynamic_sql || ', '||p_pk2_column_name||' AS pk_col_2 ';
    ELSE
      l_err_col_dynamic_sql := l_err_col_dynamic_sql || ', NULL AS pk_col_2 ';
    END IF;
    IF (p_pk3_column_name IS NOT NULL) THEN
      l_err_col_dynamic_sql := l_err_col_dynamic_sql || ', '||p_pk3_column_name||' AS pk_col_3 ';
    ELSE
      l_err_col_dynamic_sql := l_err_col_dynamic_sql || ', NULL AS pk_col_3 ';
    END IF;
    IF (p_pk4_column_name IS NOT NULL) THEN
      l_err_col_dynamic_sql := l_err_col_dynamic_sql || ', '||p_pk4_column_name||' AS pk_col_4 ';
    ELSE
      l_err_col_dynamic_sql := l_err_col_dynamic_sql || ', NULL AS pk_col_4 ';
    END IF;
    IF (p_pk5_column_name IS NOT NULL) THEN
      l_err_col_dynamic_sql := l_err_col_dynamic_sql || ', '||p_pk5_column_name||' AS pk_col_5 ';
    ELSE
      l_err_col_dynamic_sql := l_err_col_dynamic_sql || ', NULL AS pk_col_5 ';
    END IF;
    IF (p_classification_col_name IS NOT NULL) THEN
      l_err_col_dynamic_sql := l_err_col_dynamic_sql || ', '||p_classification_col_name||' AS class_code_value ';
    ELSE
      l_err_col_dynamic_sql := l_err_col_dynamic_sql || ', NULL AS class_code_value ';
    END IF;

    -- add something if reqd
    l_err_where_dynamic_sql  := NULL;

    l_err_sql := p_err_col_static_sql||l_err_col_dynamic_sql||' FROM '||p_interface_table_name
                 ||p_err_where_static_sql||l_err_where_dynamic_sql;
    -- the error tokens are used in multiple places
    IF p_attr_grp_meta_obj IS NOT NULL THEN
      l_attr_grp_disp_name := p_attr_grp_meta_obj.attr_group_disp_name;
    ELSE
      l_attr_grp_disp_name := NULL;
    END IF;

    OPEN c_err_cursor FOR l_err_sql USING p_data_set_id, p_attr_grp_meta_obj.attr_group_name;   /*Fix for bug#9678667. Literal to bind*/

    LOOP
      FETCH c_err_cursor INTO error_rec;
      EXIT WHEN c_err_cursor%NOTFOUND;
      -- some variables that will be used over the messages
      l_attr_metadata_obj := GET_ATTR_OBJECT (p_attr_grp_meta_obj => p_attr_grp_meta_obj
                                             ,p_attr_int_name     => error_rec.attr_int_name);
      IF l_attr_metadata_obj IS NULL THEN
        --Bug 5144368:START
        --we should not retun from here but has to log the errors in the
        --MTL_INTERFACE_ERRORS with the wrong attribute internal name as the
        --attribute display name
        l_attr_metadata_obj := EGO_ATTR_METADATA_OBJ(null,null,null,null,null,
                                                     null,null,null,null,null,
                                                     null,null,null,null,null,
                                                     null,null,null,null,null,
                                                     null,null,null,null,null);
        l_attr_metadata_obj.attr_disp_name := error_rec.attr_int_name;
        --Bug 5144368:END
      END IF;

      l_entity_index := get_entity_index(p_entity_index       => p_entity_id
                                        ,p_instance_pk1_value => error_rec.pk_col_1
                                        ,p_instance_pk2_value => error_rec.pk_col_2
                                        ,p_instance_pk3_value => error_rec.pk_col_3
                                        ,p_instance_pk4_value => error_rec.pk_col_4
                                        ,p_instance_pk5_value => error_rec.pk_col_5
                                        );

      IF BITAND(error_rec.PROCESS_STATUS,G_PS_BAD_ATTR_OR_AG_METADATA) <> 0 THEN
        l_err_msg_name := 'EGO_EF_ATTR_DOES_NOT_EXIST';
        l_err_token_table(1).TOKEN_NAME := 'BAD_ATTR_NAME';
        l_err_token_table(1).TOKEN_VALUE := l_attr_metadata_obj.attr_disp_name;
        l_err_token_table(2).TOKEN_NAME := 'AG_NAME';
        l_err_token_table(2).TOKEN_VALUE := l_attr_grp_disp_name;
        ERROR_HANDLER.Add_Error_Message
           (p_message_name              => l_err_msg_name
           ,p_application_id            =>'EGO'--Bug 7507091 Orig value: G_APPLICATION_CONTEXT
           ,p_token_tbl                 => l_err_token_table
           ,p_message_type              => FND_API.G_RET_STS_ERROR
           ,p_row_identifier            => error_rec.TRANSACTION_ID
           ,p_entity_id                 => G_ENTITY_ID
           ,p_entity_index              => l_entity_index
           ,p_table_name                => p_interface_table_name
           ,p_entity_code               => G_ENTITY_CODE
           ,p_addto_fnd_stack           => G_ADD_ERRORS_TO_FND_STACK
          );
        l_err_token_table.DELETE();
      END IF;

      IF BITAND(error_rec.PROCESS_STATUS,G_PS_MULTIPLE_ENTRIES) <> 0 THEN
        l_err_msg_name := 'EGO_EF_MULT_VALUES_FOR_ATTR';
        l_err_token_table(1).TOKEN_NAME := 'ATTR_NAME';
        l_err_token_table(1).TOKEN_VALUE := l_attr_metadata_obj.attr_disp_name;
        l_err_token_table(2).TOKEN_NAME := 'AG_NAME';
        l_err_token_table(2).TOKEN_VALUE := l_attr_grp_disp_name;
        ERROR_HANDLER.Add_Error_Message
           (p_message_name              => l_err_msg_name
           ,p_application_id            =>'EGO'--Bug 7507091 Orig value: G_APPLICATION_CONTEXT
           ,p_token_tbl                 => l_err_token_table
           ,p_message_type              => FND_API.G_RET_STS_ERROR
           ,p_row_identifier            => error_rec.TRANSACTION_ID
           ,p_entity_id                 => G_ENTITY_ID
           ,p_entity_index              => l_entity_index
           ,p_table_name                => p_interface_table_name
           ,p_entity_code               => G_ENTITY_CODE
           ,p_addto_fnd_stack           => G_ADD_ERRORS_TO_FND_STACK
          );
        l_err_token_table.DELETE();
      END IF;

      IF BITAND(error_rec.PROCESS_STATUS,G_PS_MULTIPLE_VALUES) <> 0 THEN
        l_err_msg_name := 'EGO_EF_INT_AND_DISP_VAL_EXIST';
        l_err_token_table(1).TOKEN_NAME := 'ATTR_NAME';
        l_err_token_table(1).TOKEN_VALUE := l_attr_metadata_obj.attr_disp_name;
        l_err_token_table(2).TOKEN_NAME := 'AG_NAME';
        l_err_token_table(2).TOKEN_VALUE := l_attr_grp_disp_name;
        ERROR_HANDLER.Add_Error_Message
           (p_message_name              => l_err_msg_name
           ,p_application_id            => 'EGO'--Bug 7507091 Orig value: G_APPLICATION_CONTEXT
           ,p_token_tbl                 => l_err_token_table
           ,p_message_type              => FND_API.G_RET_STS_ERROR
           ,p_row_identifier            => error_rec.TRANSACTION_ID
           ,p_entity_id                 => G_ENTITY_ID
           ,p_entity_index              => l_entity_index
           ,p_table_name                => p_interface_table_name
           ,p_entity_code               => G_ENTITY_CODE
           ,p_addto_fnd_stack           => G_ADD_ERRORS_TO_FND_STACK
          );
        l_err_token_table.DELETE();
      END IF;

      IF BITAND(error_rec.PROCESS_STATUS,G_PS_NO_PRIVILEGES) <> 0 THEN
        l_err_msg_name := 'EGO_EF_AG_USER_PRIV_ERR';
        l_err_token_table(1).TOKEN_NAME := 'USER_NAME';
        l_err_token_table(1).TOKEN_VALUE := G_USER_NAME;
        l_err_token_table(2).TOKEN_NAME := 'AG_NAME';
        l_err_token_table(2).TOKEN_VALUE := l_attr_grp_disp_name;
        ERROR_HANDLER.Add_Error_Message
           (p_message_name              => l_err_msg_name
           ,p_application_id            => 'EGO'--Bug 7507091 Orig value: G_APPLICATION_CONTEXT
           ,p_token_tbl                 => l_err_token_table
           ,p_message_type              => FND_API.G_RET_STS_ERROR
           ,p_row_identifier            => error_rec.TRANSACTION_ID
           ,p_entity_id                 => G_ENTITY_ID
           ,p_entity_index              => l_entity_index
           ,p_table_name                => p_interface_table_name
           ,p_entity_code               => G_ENTITY_CODE
           ,p_addto_fnd_stack           => G_ADD_ERRORS_TO_FND_STACK
          );
        l_err_token_table.DELETE();
      END IF;

      IF BITAND(error_rec.PROCESS_STATUS,G_PS_VALUE_NOT_IN_VS) <> 0 THEN
        IF (l_attr_metadata_obj.validation_code = EGO_EXT_FWK_PUB.G_INDEPENDENT_VALIDATION_CODE
            OR
            l_attr_metadata_obj.validation_code = EGO_EXT_FWK_PUB.G_TRANS_IND_VALIDATION_CODE
            OR
            l_attr_metadata_obj.validation_code = EGO_EXT_FWK_PUB.G_TABLE_VALIDATION_CODE
           ) THEN
          l_err_msg_name := 'EGO_EF_INDEPENDENT_VS_VIOLATED';
          l_err_token_table(1).TOKEN_NAME := 'VALUE';
          IF (l_attr_metadata_obj.data_type_code = EGO_EXT_FWK_PUB.G_NUMBER_DATA_TYPE) THEN
            l_err_token_table(1).TOKEN_VALUE := NVL(error_rec.ATTR_DISP_VALUE,error_rec.attr_value_num);
          ELSIF (l_attr_metadata_obj.data_type_code = EGO_EXT_FWK_PUB.G_DATE_DATA_TYPE
                 OR
                 l_attr_metadata_obj.data_type_code = EGO_EXT_FWK_PUB.G_DATE_TIME_DATA_TYPE
                ) THEN
            l_err_token_table(1).TOKEN_VALUE := NVL(error_rec.ATTR_DISP_VALUE,error_rec.attr_value_date);
          ELSE
            l_err_token_table(1).TOKEN_VALUE := NVL(error_rec.ATTR_DISP_VALUE,error_rec.attr_value_str);
          END IF;
          l_err_token_table(2).TOKEN_NAME := 'ATTR_NAME';
          l_err_token_table(2).TOKEN_VALUE := l_attr_metadata_obj.attr_disp_name;
          l_err_token_table(3).TOKEN_NAME := 'AG_NAME';
          l_err_token_table(3).TOKEN_VALUE := l_attr_grp_disp_name;
          ERROR_HANDLER.Add_Error_Message
           (p_message_name              => l_err_msg_name
           ,p_application_id            => 'EGO'--Bug 7507091 Orig value: G_APPLICATION_CONTEXT
           ,p_token_tbl                 => l_err_token_table
           ,p_message_type              => FND_API.G_RET_STS_ERROR
           ,p_row_identifier            => error_rec.TRANSACTION_ID
           ,p_entity_id                 => G_ENTITY_ID
           ,p_entity_index              => l_entity_index
           ,p_table_name                => p_interface_table_name
           ,p_entity_code               => G_ENTITY_CODE
           ,p_addto_fnd_stack           => G_ADD_ERRORS_TO_FND_STACK
          );
          l_err_token_table.DELETE();
        END IF;
      END IF;

      IF BITAND(error_rec.PROCESS_STATUS,G_PS_MIN_VAL_VIOLATION) <> 0 THEN
        l_err_token_table(1).TOKEN_NAME := 'ATTR_NAME';
        l_err_token_table(1).TOKEN_VALUE := l_attr_metadata_obj.attr_disp_name;
        l_err_token_table(2).TOKEN_NAME := 'AG_NAME';
        l_err_token_table(2).TOKEN_VALUE := l_attr_grp_disp_name;
        IF (l_attr_metadata_obj.data_type_code = EGO_EXT_FWK_PUB.G_NUMBER_DATA_TYPE) THEN
          l_err_msg_name := 'EGO_EF_MIN_VAL_NUM_VIOLATED';
          l_err_token_table(3).TOKEN_NAME := 'MIN_NUM_VALUE';
          l_err_token_table(3).TOKEN_VALUE := l_attr_metadata_obj.MINIMUM_VALUE;
        ELSE
          l_err_msg_name := 'EGO_EF_MIN_VAL_DATE_VIOLATED';
          l_err_token_table(3).TOKEN_NAME := 'MIN_DATE_VALUE';
          l_err_token_table(3).TOKEN_VALUE := l_attr_metadata_obj.MINIMUM_VALUE;
        END IF;
        ERROR_HANDLER.Add_Error_Message
           (p_message_name              => l_err_msg_name
           ,p_application_id            => 'EGO'--Bug 7507091 Orig value: G_APPLICATION_CONTEXT
           ,p_token_tbl                 => l_err_token_table
           ,p_message_type              => FND_API.G_RET_STS_ERROR
           ,p_row_identifier            => error_rec.TRANSACTION_ID
           ,p_entity_id                 => G_ENTITY_ID
           ,p_entity_index              => l_entity_index
           ,p_table_name                => p_interface_table_name
           ,p_entity_code               => G_ENTITY_CODE
           ,p_addto_fnd_stack           => G_ADD_ERRORS_TO_FND_STACK
          );
        l_err_token_table.DELETE();
      END IF;

      IF BITAND(error_rec.PROCESS_STATUS,G_PS_MAX_VAL_VIOLATION) <> 0 THEN
        l_err_token_table(1).TOKEN_NAME := 'ATTR_NAME';
        l_err_token_table(1).TOKEN_VALUE := l_attr_metadata_obj.attr_disp_name;
        l_err_token_table(2).TOKEN_NAME := 'AG_NAME';
        l_err_token_table(2).TOKEN_VALUE := l_attr_grp_disp_name;
        IF (l_attr_metadata_obj.data_type_code = EGO_EXT_FWK_PUB.G_NUMBER_DATA_TYPE) THEN
          l_err_msg_name := 'EGO_EF_MAX_VAL_NUM_VIOLATED';
          l_err_token_table(3).TOKEN_NAME := 'MAX_NUM_VALUE';
          l_err_token_table(3).TOKEN_VALUE := l_attr_metadata_obj.MAXIMUM_VALUE;
        ELSE
          l_err_msg_name := 'EGO_EF_MAX_VAL_DATE_VIOLATED';
          l_err_token_table(3).TOKEN_NAME := 'MAX_DATE_VALUE';
          l_err_token_table(3).TOKEN_VALUE := l_attr_metadata_obj.MAXIMUM_VALUE;
        END IF;
        ERROR_HANDLER.Add_Error_Message
           (p_message_name              => l_err_msg_name
           ,p_application_id            => 'EGO'--Bug 7507091 Orig value: G_APPLICATION_CONTEXT
           ,p_token_tbl                 => l_err_token_table
           ,p_message_type              => FND_API.G_RET_STS_ERROR
           ,p_row_identifier            => error_rec.TRANSACTION_ID
           ,p_entity_id                 => G_ENTITY_ID
           ,p_entity_index              => l_entity_index
           ,p_table_name                => p_interface_table_name
           ,p_entity_code               => G_ENTITY_CODE
           ,p_addto_fnd_stack           => G_ADD_ERRORS_TO_FND_STACK
          );
        l_err_token_table.DELETE();
      END IF;

      IF BITAND(error_rec.PROCESS_STATUS,G_PS_VAL_RANGE_VIOLATION) <> 0 THEN
        l_err_token_table(1).TOKEN_NAME := 'ATTR_NAME';
        l_err_token_table(1).TOKEN_VALUE := l_attr_metadata_obj.attr_disp_name;
        l_err_token_table(2).TOKEN_NAME := 'AG_NAME';
        l_err_token_table(2).TOKEN_VALUE := l_attr_grp_disp_name;
        l_err_msg_name := 'EGO_VAL_OUT_OF_RANGE';
        l_err_token_table(3).TOKEN_NAME := 'MINVALUE';
        l_err_token_table(3).TOKEN_VALUE := l_attr_metadata_obj.MINIMUM_VALUE;
        l_err_token_table(4).TOKEN_NAME := 'MAXVALUE';
        l_err_token_table(4).TOKEN_VALUE := l_attr_metadata_obj.MAXIMUM_VALUE;

        ERROR_HANDLER.Add_Error_Message
           (p_message_name              => l_err_msg_name
           ,p_application_id            => 'EGO'--Bug 7507091 Orig value: G_APPLICATION_CONTEXT
           ,p_token_tbl                 => l_err_token_table
           ,p_message_type              => FND_API.G_RET_STS_ERROR
           ,p_row_identifier            => error_rec.TRANSACTION_ID
           ,p_entity_id                 => G_ENTITY_ID
           ,p_entity_index              => l_entity_index
           ,p_table_name                => p_interface_table_name
           ,p_entity_code               => G_ENTITY_CODE
           ,p_addto_fnd_stack           => G_ADD_ERRORS_TO_FND_STACK
          );
        l_err_token_table.DELETE();
      END IF;

      IF BITAND(error_rec.PROCESS_STATUS,G_PS_INVALID_NUMBER_DATA) <> 0 THEN
        l_err_msg_name := 'EGO_EF_DATA_TYPE_INCORRECT';
        l_err_token_table(1).TOKEN_NAME := 'ATTR_NAME';
        l_err_token_table(1).TOKEN_VALUE := l_attr_metadata_obj.attr_disp_name;
        l_err_token_table(2).TOKEN_NAME := 'AG_NAME';
        l_err_token_table(2).TOKEN_VALUE := l_attr_grp_disp_name;
        l_err_token_table(3).TOKEN_NAME := 'DATA_TYPE';
        l_err_token_table(3).TOKEN_VALUE := l_attr_metadata_obj.data_type_meaning;
        l_err_token_table(4).TOKEN_NAME := 'VALUE';
        l_err_token_table(4).TOKEN_VALUE := NVL(error_rec.ATTR_DISP_VALUE,error_rec.attr_value_num);
        ERROR_HANDLER.Add_Error_Message
           (p_message_name              => l_err_msg_name
           ,p_application_id            => 'EGO'--Bug 7507091 Orig value: G_APPLICATION_CONTEXT
           ,p_token_tbl                 => l_err_token_table
           ,p_message_type              => FND_API.G_RET_STS_ERROR
           ,p_row_identifier            => error_rec.TRANSACTION_ID
           ,p_entity_id                 => G_ENTITY_ID
           ,p_entity_index              => l_entity_index
           ,p_table_name                => p_interface_table_name
           ,p_entity_code               => G_ENTITY_CODE
           ,p_addto_fnd_stack           => G_ADD_ERRORS_TO_FND_STACK
          );
        l_err_token_table.DELETE();
      END IF;

      IF BITAND(error_rec.PROCESS_STATUS,G_PS_INVALID_DATE_DATA) <> 0 THEN
        l_err_msg_name := 'EGO_EF_DATA_TYPE_INCORRECT';
        l_err_token_table(1).TOKEN_NAME := 'ATTR_NAME';
        l_err_token_table(1).TOKEN_VALUE := l_attr_metadata_obj.attr_disp_name;
        l_err_token_table(2).TOKEN_NAME := 'AG_NAME';
        l_err_token_table(2).TOKEN_VALUE := l_attr_grp_disp_name;
        l_err_token_table(3).TOKEN_NAME := 'DATA_TYPE';
        l_err_token_table(3).TOKEN_VALUE := l_attr_metadata_obj.data_type_meaning;
        l_err_token_table(4).TOKEN_NAME := 'VALUE';
        l_err_token_table(4).TOKEN_VALUE := NVL(error_rec.ATTR_DISP_VALUE,error_rec.attr_value_date);
        ERROR_HANDLER.Add_Error_Message
           (p_message_name              => l_err_msg_name
           ,p_application_id            => 'EGO'--Bug 7507091 Orig value: G_APPLICATION_CONTEXT
           ,p_token_tbl                 => l_err_token_table
           ,p_message_type              => FND_API.G_RET_STS_ERROR
           ,p_row_identifier            => error_rec.TRANSACTION_ID
           ,p_entity_id                 => G_ENTITY_ID
           ,p_entity_index              => l_entity_index
           ,p_table_name                => p_interface_table_name
           ,p_entity_code               => G_ENTITY_CODE
           ,p_addto_fnd_stack           => G_ADD_ERRORS_TO_FND_STACK
          );
        l_err_token_table.DELETE();
      END IF;

      IF BITAND(error_rec.PROCESS_STATUS,G_PS_INVALID_DATE_TIME_DATA) <> 0 THEN
        l_err_msg_name := 'EGO_EF_DATA_TYPE_INCORRECT';
        l_err_token_table(1).TOKEN_NAME := 'ATTR_NAME';
        l_err_token_table(1).TOKEN_VALUE := l_attr_metadata_obj.attr_disp_name;
        l_err_token_table(2).TOKEN_NAME := 'AG_NAME';
        l_err_token_table(2).TOKEN_VALUE := l_attr_grp_disp_name;
        l_err_token_table(3).TOKEN_NAME := 'DATA_TYPE';
        l_err_token_table(3).TOKEN_VALUE := l_attr_metadata_obj.data_type_meaning;
        l_err_token_table(4).TOKEN_NAME := 'VALUE';
        l_err_token_table(4).TOKEN_VALUE := NVL(error_rec.ATTR_DISP_VALUE,error_rec.attr_value_date);
        ERROR_HANDLER.Add_Error_Message
           (p_message_name              => l_err_msg_name
           ,p_application_id            => 'EGO'--Bug 7507091 Orig value: G_APPLICATION_CONTEXT
           ,p_token_tbl                 => l_err_token_table
           ,p_message_type              => FND_API.G_RET_STS_ERROR
           ,p_row_identifier            => error_rec.TRANSACTION_ID
           ,p_entity_id                 => G_ENTITY_ID
           ,p_entity_index              => l_entity_index
           ,p_table_name                => p_interface_table_name
           ,p_entity_code               => G_ENTITY_CODE
           ,p_addto_fnd_stack           => G_ADD_ERRORS_TO_FND_STACK
          );
        l_err_token_table.DELETE();
      END IF;

      IF BITAND(error_rec.PROCESS_STATUS,G_PS_MAX_LENGTH_VIOLATION) <> 0 THEN
        l_err_msg_name := 'EGO_EF_MAX_SIZE_VIOLATED';
        l_err_token_table(1).TOKEN_NAME := 'VALUE';
        IF (l_attr_metadata_obj.data_type_code = EGO_EXT_FWK_PUB.G_NUMBER_DATA_TYPE) THEN
          l_err_token_table(1).TOKEN_VALUE := NVL(error_rec.ATTR_DISP_VALUE,error_rec.attr_value_num);
        ELSIF (l_attr_metadata_obj.data_type_code = EGO_EXT_FWK_PUB.G_DATE_DATA_TYPE
               OR
               l_attr_metadata_obj.data_type_code = EGO_EXT_FWK_PUB.G_DATE_TIME_DATA_TYPE
              ) THEN
          l_err_token_table(1).TOKEN_VALUE := NVL(error_rec.ATTR_DISP_VALUE,error_rec.attr_value_date);
        ELSE
          l_err_token_table(1).TOKEN_VALUE := NVL(error_rec.ATTR_DISP_VALUE,error_rec.attr_value_str);
        END IF;

        l_err_token_table(2).TOKEN_NAME := 'ATTR_NAME';
        l_err_token_table(2).TOKEN_VALUE := l_attr_metadata_obj.attr_disp_name;
        l_err_token_table(3).TOKEN_NAME := 'AG_NAME';
        l_err_token_table(3).TOKEN_VALUE := l_attr_grp_disp_name;
        ERROR_HANDLER.Add_Error_Message
           (p_message_name              => l_err_msg_name
           ,p_application_id            => 'EGO'--Bug 7507091 Orig value: G_APPLICATION_CONTEXT
           ,p_token_tbl                 => l_err_token_table
           ,p_message_type              => FND_API.G_RET_STS_ERROR
           ,p_row_identifier            => error_rec.TRANSACTION_ID
           ,p_entity_id                 => G_ENTITY_ID
           ,p_entity_index              => l_entity_index
           ,p_table_name                => p_interface_table_name
           ,p_entity_code               => G_ENTITY_CODE
           ,p_addto_fnd_stack           => G_ADD_ERRORS_TO_FND_STACK
          );
        l_err_token_table.DELETE();
      END IF;

      IF BITAND(error_rec.PROCESS_STATUS,G_PS_BAD_TTYPE_UPDATE) <> 0 THEN
        l_err_msg_name := 'EGO_EF_ROW_NOT_FOUND';
        l_err_token_table(1).TOKEN_NAME := 'AG_NAME';
        l_err_token_table(1).TOKEN_VALUE := l_attr_grp_disp_name;
        ERROR_HANDLER.Add_Error_Message
           (p_message_name              => l_err_msg_name
           ,p_application_id            => 'EGO'--Bug 7507091 Orig value: G_APPLICATION_CONTEXT
           ,p_token_tbl                 => l_err_token_table
           ,p_message_type              => FND_API.G_RET_STS_ERROR
           ,p_row_identifier            => error_rec.TRANSACTION_ID
           ,p_entity_id                 => G_ENTITY_ID
           ,p_entity_index              => l_entity_index
           ,p_table_name                => p_interface_table_name
           ,p_entity_code               => G_ENTITY_CODE
           ,p_addto_fnd_stack           => G_ADD_ERRORS_TO_FND_STACK
          );
        l_err_token_table.DELETE();
      END IF;

      IF BITAND(error_rec.PROCESS_STATUS,G_PS_BAD_TTYPE_CREATE) <> 0 THEN
        l_err_token_table(1).TOKEN_NAME := 'AG_NAME';
        l_err_token_table(1).TOKEN_VALUE := l_attr_grp_disp_name;
        IF p_attr_grp_meta_obj.multi_row_code = 'Y' THEN
          -- multi row error.
          l_attr_table := p_attr_grp_meta_obj.ATTR_METADATA_TABLE;
          IF l_attr_table.count > 0 THEN
            FND_MESSAGE.set_name(application => 'EGO'
                                ,name        => 'EGO_COMMA');
            l_comma_message := FND_MESSAGE.GET;
            l_msg_token_value := NULL;
            FOR i IN l_attr_table.FIRST .. l_attr_table.LAST LOOP
              IF l_attr_table(i).unique_key_flag = 'Y' THEN
                l_msg_token_value := l_msg_token_value ||l_attr_table(i).attr_disp_name|| l_comma_message;
              END IF;
            END LOOP;
            IF l_msg_token_value IS NULL THEN
              l_err_msg_name := 'EGO_EF_NO_UK_FOR_CREATE';
            ELSE
              l_err_msg_name := 'EGO_EF_MULTIROW_EXISTS';
              l_msg_token_value := SUBSTR(l_msg_token_value, 1 ,
                           (INSTR(l_msg_token_value, l_comma_message,-1)-1));
              l_err_token_table(2).TOKEN_NAME := 'ATTR_NAMES';
              l_err_token_table(2).TOKEN_VALUE := l_msg_token_value;
            END IF;
          END IF;
        ELSE
          -- single row error.
          l_err_msg_name := 'EGO_EF_ROW_ALREADY_EXISTS';
        END IF;
        ERROR_HANDLER.Add_Error_Message
           (p_message_name              => l_err_msg_name
           ,p_application_id            => 'EGO'--Bug 7507091 Orig value: G_APPLICATION_CONTEXT
           ,p_token_tbl                 => l_err_token_table
           ,p_message_type              => FND_API.G_RET_STS_ERROR
           ,p_row_identifier            => error_rec.TRANSACTION_ID
           ,p_entity_id                 => G_ENTITY_ID
           ,p_entity_index              => l_entity_index
           ,p_table_name                => p_interface_table_name
           ,p_entity_code               => G_ENTITY_CODE
           ,p_addto_fnd_stack           => G_ADD_ERRORS_TO_FND_STACK
          );
        l_err_token_table.DELETE();
      END IF;

      IF BITAND(error_rec.PROCESS_STATUS,G_PS_BAD_TTYPE_DELETE) <> 0 THEN
        l_err_msg_name := 'EGO_EF_ROW_NOT_FOUND';
        l_err_token_table(1).TOKEN_NAME := 'AG_NAME';
        l_err_token_table(1).TOKEN_VALUE := l_attr_grp_disp_name;
        ERROR_HANDLER.Add_Error_Message
           (p_message_name              => l_err_msg_name
           ,p_application_id            => 'EGO'--Bug 7507091 Orig value: G_APPLICATION_CONTEXT
           ,p_token_tbl                 => l_err_token_table
           ,p_message_type              => FND_API.G_RET_STS_ERROR
           ,p_row_identifier            => error_rec.TRANSACTION_ID
           ,p_entity_id                 => G_ENTITY_ID
           ,p_entity_index              => l_entity_index
           ,p_table_name                => p_interface_table_name
           ,p_entity_code               => G_ENTITY_CODE
           ,p_addto_fnd_stack           => G_ADD_ERRORS_TO_FND_STACK
          );
        l_err_token_table.DELETE();
      END IF;

      IF BITAND(error_rec.PROCESS_STATUS,G_PS_REQUIRED_ATTRIBUTE) <> 0 THEN
        l_err_msg_name := 'EGO_EF_NO_VAL_FOR_REQ_ATTR';
        l_err_token_table(1).TOKEN_NAME := 'ATTR_NAME';
        l_err_token_table(1).TOKEN_VALUE := l_attr_metadata_obj.attr_disp_name;
        l_err_token_table(2).TOKEN_NAME := 'AG_NAME';
        l_err_token_table(2).TOKEN_VALUE := l_attr_grp_disp_name;
        ERROR_HANDLER.Add_Error_Message
           (p_message_name              => l_err_msg_name
           ,p_application_id            => 'EGO'--Bug 7507091 Orig value: G_APPLICATION_CONTEXT
           ,p_token_tbl                 => l_err_token_table
           ,p_message_type              => FND_API.G_RET_STS_ERROR
           ,p_row_identifier            => error_rec.TRANSACTION_ID
           ,p_entity_id                 => G_ENTITY_ID
           ,p_entity_index              => l_entity_index
           ,p_table_name                => p_interface_table_name
           ,p_entity_code               => G_ENTITY_CODE
           ,p_addto_fnd_stack           => G_ADD_ERRORS_TO_FND_STACK
          );
        l_err_token_table.DELETE();
      END IF;

      IF BITAND(error_rec.PROCESS_STATUS,G_PS_AG_NOT_ASSOCIATED) <> 0 THEN
        l_err_msg_name := 'EGO_EF_AG_NOT_ASSOCIATED';
        l_err_token_table(1).TOKEN_NAME := 'AG_NAME';
        l_err_token_table(1).TOKEN_VALUE := l_attr_grp_disp_name;
        l_err_token_table(2).TOKEN_NAME := 'CLASS_MEANING';
        BEGIN
          SELECT EGO_EXT_FWK_PUB.Get_Class_Meaning(p_object_name, error_rec.class_code_value)
            INTO l_err_token_table(2).TOKEN_VALUE
            FROM DUAL;
        EXCEPTION
          WHEN OTHERS THEN
            l_err_token_table(2).TOKEN_VALUE :=  error_rec.class_code_value;
        END;
        ERROR_HANDLER.Add_Error_Message
           (p_message_name              => l_err_msg_name
           ,p_application_id            => 'EGO'--Bug 7507091 Orig value: G_APPLICATION_CONTEXT
           ,p_token_tbl                 => l_err_token_table
           ,p_message_type              => FND_API.G_RET_STS_ERROR
           ,p_row_identifier            => error_rec.TRANSACTION_ID
           ,p_entity_id                 => G_ENTITY_ID
           ,p_entity_index              => l_entity_index
           ,p_table_name                => p_interface_table_name
           ,p_entity_code               => G_ENTITY_CODE
           ,p_addto_fnd_stack           => G_ADD_ERRORS_TO_FND_STACK
          );
        l_err_token_table.DELETE();
      END IF;

     IF BITAND(error_rec.PROCESS_STATUS, G_PS_IDENTICAL_ROWS) <> 0 THEN

/*
       EGO_USER_ATTRS_DATA_PVT.Get_Err_Info_For_UK_Violation
       (p_attr_group_metadata_obj       IN    -- EGO_ATTR_GROUP_METADATA_OBJ
         ,p_attr_name_value_pairs         IN    -- EGO_USER_ATTR_DATA_TABLE
         ,p_is_err_in_production_table    => true -- boolean
         ,x_unique_key_err_msg            => l_err_msg_name
         ,x_token_table                   => l_err_token_table
         );
       EGO_USER_ATTRS_DATA_PVT.Get_Err_Info_For_UK_Not_Resp
        (p_attr_group_metadata_obj       IN   EGO_ATTR_GROUP_METADATA_OBJ
        ,p_is_err_in_production_table    IN   BOOLEAN
        ,x_unique_key_err_msg            OUT NOCOPY VARCHAR2
        ,x_token_table                   OUT NOCOPY ERROR_HANDLER.Token_Tbl_Type
        );
*/

        l_err_msg_name := 'EGO_EF_IDENTICAL_ROWS_ERR';
        l_err_token_table(1).TOKEN_NAME := 'AG_NAME';
        l_err_token_table(1).TOKEN_VALUE := l_attr_grp_disp_name;
        ERROR_HANDLER.Add_Error_Message
           (p_message_name              => l_err_msg_name
           ,p_application_id            => 'EGO'--Bug 7507091 Orig value: G_APPLICATION_CONTEXT
           ,p_token_tbl                 => l_err_token_table
           ,p_message_type              => FND_API.G_RET_STS_ERROR
           ,p_row_identifier            => error_rec.TRANSACTION_ID
           ,p_entity_id                 => G_ENTITY_ID
           ,p_entity_index              => l_entity_index
           ,p_table_name                => p_interface_table_name
           ,p_entity_code               => G_ENTITY_CODE
           ,p_addto_fnd_stack           => G_ADD_ERRORS_TO_FND_STACK
          );
        l_err_token_table.DELETE();
      END IF;

      IF BITAND(error_rec.PROCESS_STATUS,G_PS_BAD_PK_VAL) <> 0 THEN
        IF p_pk5_column_name IS NOT NULL THEN
          l_err_msg_name := 'EGO_EF_NO_PK_VALUES_5';
          l_err_token_table(1).TOKEN_NAME := 'PK1_COL_NAME';
          l_err_token_table(1).TOKEN_VALUE := p_pk1_column_name;
          l_err_token_table(2).TOKEN_NAME := 'PK2_COL_NAME';
          l_err_token_table(2).TOKEN_VALUE := p_pk2_column_name;
          l_err_token_table(3).TOKEN_NAME := 'PK3_COL_NAME';
          l_err_token_table(3).TOKEN_VALUE := p_pk3_column_name;
          l_err_token_table(4).TOKEN_NAME := 'PK4_COL_NAME';
          l_err_token_table(4).TOKEN_VALUE := p_pk4_column_name;
          l_err_token_table(5).TOKEN_NAME := 'PK5_COL_NAME';
          l_err_token_table(5).TOKEN_VALUE := p_pk5_column_name;
          l_err_token_table(6).TOKEN_NAME := 'OBJ_NAME';
          l_err_token_table(6).TOKEN_VALUE := p_object_name;
        ELSIF p_pk4_column_name IS NOT NULL THEN
          l_err_msg_name := 'EGO_EF_NO_PK_VALUES_4';
          l_err_token_table(1).TOKEN_NAME := 'PK1_COL_NAME';
          l_err_token_table(1).TOKEN_VALUE := p_pk1_column_name;
          l_err_token_table(2).TOKEN_NAME := 'PK2_COL_NAME';
          l_err_token_table(2).TOKEN_VALUE := p_pk2_column_name;
          l_err_token_table(3).TOKEN_NAME := 'PK3_COL_NAME';
          l_err_token_table(3).TOKEN_VALUE := p_pk3_column_name;
          l_err_token_table(4).TOKEN_NAME := 'PK4_COL_NAME';
          l_err_token_table(4).TOKEN_VALUE := p_pk4_column_name;
          l_err_token_table(5).TOKEN_NAME := 'OBJ_NAME';
          l_err_token_table(5).TOKEN_VALUE := p_object_name;
        ELSIF p_pk3_column_name IS NOT NULL THEN
          l_err_msg_name := 'EGO_EF_NO_PK_VALUES_3';
          l_err_token_table(1).TOKEN_NAME := 'PK1_COL_NAME';
          l_err_token_table(1).TOKEN_VALUE := p_pk1_column_name;
          l_err_token_table(2).TOKEN_NAME := 'PK2_COL_NAME';
          l_err_token_table(2).TOKEN_VALUE := p_pk2_column_name;
          l_err_token_table(3).TOKEN_NAME := 'PK3_COL_NAME';
          l_err_token_table(3).TOKEN_VALUE := p_pk3_column_name;
          l_err_token_table(4).TOKEN_NAME := 'OBJ_NAME';
          l_err_token_table(4).TOKEN_VALUE := p_object_name;
        ELSIF p_pk2_column_name IS NOT NULL THEN
          l_err_msg_name := 'EGO_EF_NO_PK_VALUES_2';
          l_err_token_table(1).TOKEN_NAME := 'PK1_COL_NAME';
          l_err_token_table(1).TOKEN_VALUE := p_pk1_column_name;
          l_err_token_table(2).TOKEN_NAME := 'PK2_COL_NAME';
          l_err_token_table(2).TOKEN_VALUE := p_pk2_column_name;
          l_err_token_table(3).TOKEN_NAME := 'OBJ_NAME';
          l_err_token_table(3).TOKEN_VALUE := p_object_name;
        ELSIF p_pk1_column_name IS NOT NULL THEN
          l_err_msg_name := 'EGO_EF_NO_PK_VALUES_1';
          l_err_token_table(1).TOKEN_NAME := 'PK1_COL_NAME';
          l_err_token_table(1).TOKEN_VALUE := p_pk1_column_name;
          l_err_token_table(2).TOKEN_NAME := 'OBJ_NAME';
          l_err_token_table(2).TOKEN_VALUE := p_object_name;
        END IF;
        ERROR_HANDLER.Add_Error_Message
           (p_message_name              => l_err_msg_name
           ,p_application_id            => 'EGO'--Bug 7507091 Orig value: G_APPLICATION_CONTEXT
           ,p_token_tbl                 => l_err_token_table
           ,p_message_type              => FND_API.G_RET_STS_ERROR
           ,p_row_identifier            => error_rec.TRANSACTION_ID
           ,p_entity_id                 => G_ENTITY_ID
           ,p_entity_index              => l_entity_index
           ,p_table_name                => p_interface_table_name
           ,p_entity_code               => G_ENTITY_CODE
           ,p_addto_fnd_stack           => G_ADD_ERRORS_TO_FND_STACK
          );
        l_err_token_table.DELETE();
      END IF;

      IF BITAND(error_rec.PROCESS_STATUS,G_PS_DATA_IN_WRONG_COL) <> 0 THEN
        IF (l_attr_metadata_obj.data_type_code = EGO_EXT_FWK_PUB.G_NUMBER_DATA_TYPE) THEN
          l_err_msg_name := 'EGO_EF_NUM_IN_WRONG_COL';
        ELSIF (l_attr_metadata_obj.data_type_code = EGO_EXT_FWK_PUB.G_DATE_DATA_TYPE
               OR
               l_attr_metadata_obj.data_type_code = EGO_EXT_FWK_PUB.G_DATE_TIME_DATA_TYPE
              ) THEN
          l_err_msg_name := 'EGO_EF_DATE_IN_WRONG_COL';
        ELSE
          l_err_msg_name := 'EGO_EF_CHAR_IN_WRONG_COL';
        END IF;
        l_err_token_table(1).TOKEN_NAME := 'ATTR_NAME';
        l_err_token_table(1).TOKEN_VALUE := l_attr_metadata_obj.attr_disp_name;
        l_err_token_table(2).TOKEN_NAME := 'AG_NAME';
        l_err_token_table(2).TOKEN_VALUE := l_attr_grp_disp_name;
        ERROR_HANDLER.Add_Error_Message
           (p_message_name              => l_err_msg_name
           ,p_application_id            => 'EGO'--Bug 7507091 Orig value: G_APPLICATION_CONTEXT
           ,p_token_tbl                 => l_err_token_table
           ,p_message_type              => FND_API.G_RET_STS_ERROR
           ,p_row_identifier            => error_rec.TRANSACTION_ID
           ,p_entity_id                 => G_ENTITY_ID
           ,p_entity_index              => l_entity_index
           ,p_table_name                => p_interface_table_name
           ,p_entity_code               => G_ENTITY_CODE
           ,p_addto_fnd_stack           => G_ADD_ERRORS_TO_FND_STACK
          );
        l_err_token_table.DELETE();
      END IF;

      IF BITAND(error_rec.PROCESS_STATUS,G_PS_VALUE_NOT_IN_TVS) <> 0 THEN
-- this condition is not required
--        IF (l_attr_metadata_obj.validation_code = EGO_EXT_FWK_PUB.G_INDEPENDENT_VALIDATION_CODE
--            OR
--            l_attr_metadata_obj.validation_code = EGO_EXT_FWK_PUB.G_TABLE_VALIDATION_CODE
--           ) THEN
          l_err_msg_name := 'EGO_EF_INDEPENDENT_VS_VIOLATED';
          l_err_token_table(1).TOKEN_NAME := 'VALUE';
          IF (l_attr_metadata_obj.data_type_code = EGO_EXT_FWK_PUB.G_NUMBER_DATA_TYPE) THEN
            l_err_token_table(1).TOKEN_VALUE := NVL(error_rec.ATTR_DISP_VALUE,error_rec.attr_value_num);
          ELSIF (l_attr_metadata_obj.data_type_code = EGO_EXT_FWK_PUB.G_DATE_DATA_TYPE
                 OR
                 l_attr_metadata_obj.data_type_code = EGO_EXT_FWK_PUB.G_DATE_TIME_DATA_TYPE
                ) THEN
            l_err_token_table(1).TOKEN_VALUE := NVL(error_rec.ATTR_DISP_VALUE,error_rec.attr_value_date);
          ELSE
            l_err_token_table(1).TOKEN_VALUE := NVL(error_rec.ATTR_DISP_VALUE,error_rec.attr_value_str);
          END IF;
          l_err_token_table(2).TOKEN_NAME := 'ATTR_NAME';
          l_err_token_table(2).TOKEN_VALUE := l_attr_metadata_obj.attr_disp_name;
          l_err_token_table(3).TOKEN_NAME := 'AG_NAME';
          l_err_token_table(3).TOKEN_VALUE := l_attr_grp_disp_name;
          ERROR_HANDLER.Add_Error_Message
           (p_message_name              => l_err_msg_name
           ,p_application_id            => 'EGO'--Bug 7507091 Orig value: G_APPLICATION_CONTEXT
           ,p_token_tbl                 => l_err_token_table
           ,p_message_type              => FND_API.G_RET_STS_ERROR
           ,p_row_identifier            => error_rec.TRANSACTION_ID
           ,p_entity_id                 => G_ENTITY_ID
           ,p_entity_index              => l_entity_index
           ,p_table_name                => p_interface_table_name
           ,p_entity_code               => G_ENTITY_CODE
           ,p_addto_fnd_stack           => G_ADD_ERRORS_TO_FND_STACK
          );
          l_err_token_table.DELETE();
--        END IF;
      END IF;

      IF BITAND(error_rec.PROCESS_STATUS,G_PS_BAD_ATTRS_IN_TVS_WHERE) <> 0 THEN
        l_err_msg_name := 'EGO_EF_VS_INVALID_BIND';
        l_err_token_table(1).TOKEN_NAME := 'ATTR_NAME';
        l_err_token_table(1).TOKEN_VALUE := l_attr_metadata_obj.attr_disp_name;
        l_err_token_table(2).TOKEN_NAME := 'AG_NAME';
        l_err_token_table(2).TOKEN_VALUE := l_attr_grp_disp_name;
        ERROR_HANDLER.Add_Error_Message
           (p_message_name              => l_err_msg_name
           ,p_application_id            => 'EGO'--Bug 7507091 Orig value: G_APPLICATION_CONTEXT
           ,p_token_tbl                 => l_err_token_table
           ,p_message_type              => FND_API.G_RET_STS_ERROR
           ,p_row_identifier            => error_rec.TRANSACTION_ID
           ,p_entity_id                 => G_ENTITY_ID
           ,p_entity_index              => l_entity_index
           ,p_table_name                => p_interface_table_name
           ,p_entity_code               => G_ENTITY_CODE
           ,p_addto_fnd_stack           => G_ADD_ERRORS_TO_FND_STACK
          );
        l_err_token_table.DELETE();
      END IF;

      IF BITAND(error_rec.PROCESS_STATUS,G_PS_BAD_ATTR_GRP_ID) <> 0 THEN
        l_err_msg_name := 'EGO_EF_BAD_AG_ID';
        l_err_token_table(1).TOKEN_NAME := 'AG_ID';
        l_err_token_table(1).TOKEN_VALUE := error_rec.ATTR_GROUP_ID;
        l_err_token_table(2).TOKEN_NAME := 'AG_NAME';
        l_err_token_table(2).TOKEN_VALUE := l_attr_grp_disp_name;
        ERROR_HANDLER.Add_Error_Message
           (p_message_name              => l_err_msg_name
           ,p_application_id            => 'EGO'--Bug 7507091 Orig value: G_APPLICATION_CONTEXT
           ,p_token_tbl                 => l_err_token_table
           ,p_message_type              => FND_API.G_RET_STS_ERROR
           ,p_row_identifier            => error_rec.TRANSACTION_ID
           ,p_entity_id                 => G_ENTITY_ID
           ,p_entity_index              => l_entity_index
           ,p_table_name                => p_interface_table_name
           ,p_entity_code               => G_ENTITY_CODE
           ,p_addto_fnd_stack           => G_ADD_ERRORS_TO_FND_STACK
          );
        l_err_token_table.DELETE();
      END IF;

      IF BITAND(error_rec.PROCESS_STATUS,G_PS_TL_COL_IS_A_UK) <> 0 THEN
        l_err_msg_name := 'EGO_EF_TL_COL_IS_A_UK';
        l_err_token_table(1).TOKEN_NAME := 'AG_NAME';
        l_err_token_table(1).TOKEN_VALUE := l_attr_grp_disp_name;
        ERROR_HANDLER.Add_Error_Message
           (p_message_name              => l_err_msg_name
           ,p_application_id            => 'EGO'--Bug 7507091 Orig value: G_APPLICATION_CONTEXT
           ,p_token_tbl                 => l_err_token_table
           ,p_message_type              => FND_API.G_RET_STS_ERROR
           ,p_row_identifier            => error_rec.TRANSACTION_ID
           ,p_entity_id                 => G_ENTITY_ID
           ,p_entity_index              => l_entity_index
           ,p_table_name                => p_interface_table_name
           ,p_entity_code               => G_ENTITY_CODE
           ,p_addto_fnd_stack           => G_ADD_ERRORS_TO_FND_STACK
          );
        l_err_token_table.DELETE();
      END IF;

      IF BITAND(error_rec.PROCESS_STATUS,G_PS_PRE_EVENT_FAILED) <> 0 THEN
        l_err_msg_name := 'EGO_EF_PRE_EVENT_FAILED';
        l_err_token_table(1).TOKEN_NAME := 'AG_NAME';
        l_err_token_table(1).TOKEN_VALUE := l_attr_grp_disp_name;
        ERROR_HANDLER.Add_Error_Message
           (p_message_name              => l_err_msg_name
           ,p_application_id            => 'EGO'--Bug 7507091 Orig value: G_APPLICATION_CONTEXT
           ,p_token_tbl                 => l_err_token_table
           ,p_message_type              => FND_API.G_RET_STS_ERROR
           ,p_row_identifier            => error_rec.TRANSACTION_ID
           ,p_entity_id                 => G_ENTITY_ID
           ,p_entity_index              => l_entity_index
           ,p_table_name                => p_interface_table_name
           ,p_entity_code               => G_ENTITY_CODE
           ,p_addto_fnd_stack           => G_ADD_ERRORS_TO_FND_STACK
          );
        l_err_token_table.DELETE();
      END IF;

--BugFix : 4171705
      IF BITAND(error_rec.PROCESS_STATUS,G_PS_BAD_TVS_SETUP) <> 0 THEN
        l_err_msg_name := 'EGO_EF_BAD_TVS_SETUP';
        l_err_token_table(1).TOKEN_NAME := 'AG_NAME';
        l_err_token_table(1).TOKEN_VALUE := l_attr_grp_disp_name;
        l_err_token_table(2).TOKEN_NAME := 'ATTR_NAME';
        l_err_token_table(2).TOKEN_VALUE := l_attr_metadata_obj.attr_disp_name;
        ERROR_HANDLER.Add_Error_Message
           (p_message_name              => l_err_msg_name
           ,p_application_id            => 'EGO'--Bug 7507091 Orig value: G_APPLICATION_CONTEXT
           ,p_token_tbl                 => l_err_token_table
           ,p_message_type              => FND_API.G_RET_STS_ERROR
           ,p_row_identifier            => error_rec.TRANSACTION_ID
           ,p_entity_id                 => G_ENTITY_ID
           ,p_entity_index              => l_entity_index
           ,p_table_name                => p_interface_table_name
           ,p_entity_code               => G_ENTITY_CODE
           ,p_addto_fnd_stack           => G_ADD_ERRORS_TO_FND_STACK
          );
        l_err_token_table.DELETE();
      END IF;

      IF BITAND(error_rec.PROCESS_STATUS,G_PS_INVALID_UOM) <> 0 THEN
        l_err_msg_name := 'EGO_EF_BAD_UOM';
        l_err_token_table(1).TOKEN_NAME := 'AG_NAME';
        l_err_token_table(1).TOKEN_VALUE := l_attr_grp_disp_name;
        l_err_token_table(2).TOKEN_NAME := 'ATTR_NAME';
        l_err_token_table(2).TOKEN_VALUE := l_attr_metadata_obj.attr_disp_name;
        ERROR_HANDLER.Add_Error_Message
           (p_message_name              => l_err_msg_name
           ,p_application_id            => 'EGO'--Bug 7507091 Orig value: G_APPLICATION_CONTEXT
           ,p_token_tbl                 => l_err_token_table
           ,p_message_type              => FND_API.G_RET_STS_ERROR
           ,p_row_identifier            => error_rec.TRANSACTION_ID
           ,p_entity_id                 => G_ENTITY_ID
           ,p_entity_index              => l_entity_index
           ,p_table_name                => p_interface_table_name
           ,p_entity_code               => G_ENTITY_CODE
           ,p_addto_fnd_stack           => G_ADD_ERRORS_TO_FND_STACK
          );
        l_err_token_table.DELETE();
      END IF;

    END LOOP;
    -- Bug : 4099546
    CLOSE c_err_cursor;

END log_errors_now;

/* Bug 10151142 : Start
 -- Private procedure - Prepare_Dynamic_Sqls_Clob:
 -- This procedure builds dynamic sql for dependent table value sets.
 -- the query built may have size more that 32k in which case execute immediate doesn't work,
 -- so we will put this query in an array of type dbms_sql.varchar2a so that we can use DBMS_SQL api.
*/
PROCEDURE Prepare_Dynamic_Sqls_Clob (
    p_data_set_id                   IN NUMBER,
    p_data_type_code                IN VARCHAR2,
    p_interface_table_name          IN   VARCHAR2,
    p_tvs_val_check_sel_clob        IN   CLOB,
    p_tvs_select_clob               IN   CLOB,
    p_attr_name                     IN   VARCHAR2,
    p_attr_group_name               IN   VARCHAR2,
    x_return_status                 OUT NOCOPY VARCHAR2,
    x_msg_data                      OUT NOCOPY VARCHAR2,
    x_sql_1_ub                      OUT NOCOPY NUMBER,
    x_sql_ub                        OUT NOCOPY NUMBER,
    x_dynamic_sql_1_v_type          OUT NOCOPY dbms_sql.varchar2a,
    x_dynamic_sql_v_type            OUT NOCOPY dbms_sql.varchar2a
  ) IS

  l_api_name    VARCHAR2(30)  := 'Prepare_Dynamic_Sqls_Clob';
  l_buffer      varchar2(8191):= '';
  l_amount      number := 8191;
  l_offset      number :=1;
  l_clob_length number;

  l_dynamic_sql_1_clob_part1  CLOB;
  l_dynamic_sql_clob_part1    CLOB;
  l_dynamic_sql_clob_part2    CLOB;

  l_dynamic_sql_v_type    dbms_sql.varchar2a;
  l_dynamic_sql_1_v_type  dbms_sql.varchar2a;

  l_clob_length_1 NUMBER;
  l_index_1       NUMBER;
  l_index         NUMBER;
  l_count         NUMBER ;

  l_data_type_clause  VARCHAR2(100);
  l_dynamic_sql       VARCHAR2(32767);
  l_dummy             NUMBER;
  l_message           VARCHAR2(3800);

BEGIN
  code_debug(l_api_name|| '  Starting  ');

  IF (p_data_type_code = EGO_EXT_FWK_PUB.G_NUMBER_DATA_TYPE) THEN
    l_data_type_clause := 'ATTR_VALUE_NUM';
  ELSIF (p_data_type_code = EGO_EXT_FWK_PUB.G_DATE_DATA_TYPE OR p_data_type_code = EGO_EXT_FWK_PUB.G_DATE_TIME_DATA_TYPE) THEN
    l_data_type_clause := 'ATTR_VALUE_DATE';
  ELSE
    l_data_type_clause  := 'ATTR_VALUE_STR';
  END IF;

  code_debug('          Preparing l_dynamic_sql_1_v_type ' ,3);
  l_dynamic_sql_1_v_type(1) := 'UPDATE '||p_interface_table_name||' UAI1 SET PROCESS_STATUS = PROCESS_STATUS + DECODE((';

  l_dynamic_sql_1_clob_part1 := p_tvs_val_check_sel_clob;
  l_clob_length_1 := dbms_lob.getlength(l_dynamic_sql_1_clob_part1);

  code_debug('           Length of l_dynamic_sql_1_clob_part1 :'||l_clob_length_1, 3);

  /* Read 8191 characters from clob sequentially and append them to the VARCHAR2 table
  using DBMS_LOB.READ function */
  l_offset := 1;
  l_count := 0;
  l_index_1 := 2;
  l_amount := 8191;
  l_dynamic_sql_1_v_type(l_index_1) := '';

  code_debug('          Processing l_dynamic_sql_1_clob_part1 ' ,3);
  while l_offset <= l_clob_length_1 LOOP
    l_buffer := '';
    l_count := l_count + 1;

    dbms_lob.read(l_dynamic_sql_1_clob_part1, l_amount, l_offset, l_buffer);

    IF (l_count = 4) THEN
      l_count := 0;
      l_index_1 := l_index_1 + 1 ;
      l_dynamic_sql_1_v_type(l_index_1) := '';
    END IF;

    l_dynamic_sql_1_v_type(l_index_1) := l_dynamic_sql_1_v_type(l_index_1)||l_buffer;
    l_offset := l_offset + l_amount;
  end loop;

  l_index_1 := l_index_1 + 1;
  l_dynamic_sql_1_v_type(l_index_1) := ') ,0,'||G_PS_VALUE_NOT_IN_TVS||',0)  WHERE DATA_SET_ID = :data_set_id '||'
    AND (PROCESS_STATUS = '||G_PS_IN_PROCESS||' OR PROCESS_STATUS > '||G_PS_BAD_ATTR_OR_AG_METADATA||' )
    AND BITAND(PROCESS_STATUS, '||G_PS_NO_PRIVILEGES||') = 0
    AND ATTR_INT_NAME = '''||p_attr_name||'''
    AND ATTR_GROUP_INT_NAME = '''||p_attr_group_name||'''
    AND '||l_data_type_clause||' IS NOT NULL AND TRANSACTION_TYPE <> '''||EGO_USER_ATTRS_DATA_PVT.G_DELETE_MODE||''''; -- bug 13774267
    /*
       No need to check attribute value against value set in case of Delete. The check is skipped only for ATTR_VALUE*.
       The validation need to be done if the user passes ATTR_DISP_VALUE. hence didn't add the condition for  l_dynamic_sql_v_type
    */

  x_sql_1_ub := l_index_1;
  x_dynamic_sql_1_v_type := l_dynamic_sql_1_v_type;

  code_debug('          Preparing l_dynamic_sql_1_v_type is done ' ,3);

  code_debug('          Preparing l_dynamic_sql_v_type :' ,3);
  l_dynamic_sql_v_type(1) := 'UPDATE '||p_interface_table_name||' UAI1 SET '||l_data_type_clause||' = NVL(';

  l_dynamic_sql_clob_part1 := p_tvs_select_clob;
  l_clob_length := dbms_lob.getlength(l_dynamic_sql_clob_part1);

  code_debug('           Length of l_dynamic_sql_clob_part1 :'||l_clob_length, 3);

  /* Read 8191 characters from clob sequentially and append them to the VARCHAR2 variable
  using DBMS_LOB.READ function */
  l_offset := 1;
  l_count := 0;
  l_index := 2;
  l_amount := 8191;
  l_dynamic_sql_v_type(l_index) := '';

  code_debug('          Processing l_dynamic_sql_clob_part1 :' ,3);
  while l_offset <= l_clob_length LOOP
    l_buffer := '';
    l_count := l_count + 1;

    dbms_lob.read(l_dynamic_sql_clob_part1, l_amount, l_offset, l_buffer);

    IF (l_count = 4) THEN
      l_count := 0;
      l_index := l_index + 1 ;
      l_dynamic_sql_v_type(l_index) := '';
    END IF;

    l_dynamic_sql_v_type(l_index) := l_dynamic_sql_v_type(l_index)||l_buffer;
    l_offset := l_offset + l_amount;
  end loop;

  l_index := l_index + 1;
  l_dynamic_sql_v_type(l_index) := ' ,NULL), PROCESS_STATUS = PROCESS_STATUS + DECODE((';

  l_dynamic_sql_clob_part2 :=  p_tvs_select_clob;
  l_clob_length := dbms_lob.getlength(l_dynamic_sql_clob_part2);

  code_debug('           Length of l_dynamic_sql_clob_part2 :'||l_clob_length, 3);

  /* Read 8191 characters from clob sequentially and append them to the VARCHAR2 variable
  using DBMS_LOB.READ function */
  l_offset := 1;
  l_count := 0;
  l_index := l_index + 1;
  l_amount := 8191;
  l_dynamic_sql_v_type(l_index) := '';

  code_debug('          Processing l_dynamic_sql_clob_part2 :' ,3);
  while l_offset <= l_clob_length LOOP
    l_buffer := '';
    l_count := l_count + 1;

    dbms_lob.read(l_dynamic_sql_clob_part2, l_amount, l_offset, l_buffer);

    IF (l_count = 4) THEN
      l_count := 0;
      l_index := l_index + 1 ;
      l_dynamic_sql_v_type(l_index) := '';
    END IF;

    l_dynamic_sql_v_type(l_index) := l_dynamic_sql_v_type(l_index)||l_buffer;
    l_offset := l_offset + l_amount;
  end loop;

  l_index := l_index+1;
  l_dynamic_sql_v_type(l_index) := ' ),NULL,'||G_PS_VALUE_NOT_IN_TVS||',0) WHERE DATA_SET_ID = :data_set_id '||'
    AND (PROCESS_STATUS = '||G_PS_IN_PROCESS||' OR PROCESS_STATUS > '||G_PS_BAD_ATTR_OR_AG_METADATA||' )
    AND BITAND(PROCESS_STATUS, '||G_PS_NO_PRIVILEGES||') = 0
    AND ATTR_INT_NAME = '''||p_attr_name||'''
    AND ATTR_GROUP_INT_NAME = '''||p_attr_group_name||'''
    AND ATTR_DISP_VALUE IS NOT NULL ';

  x_sql_ub := l_index;
  x_dynamic_sql_v_type := l_dynamic_sql_v_type;

  code_debug('          Preparing l_dynamic_sql_v_type is done ' ,3);

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  code_debug(l_api_name||' Done ',0);
EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    x_msg_data := 'Executing - '||G_PKG_NAME||'.'||l_api_name||' - '||SQLERRM;
    code_debug('          When others block - '||x_msg_data ,3);

    l_dynamic_sql :=
      'SELECT TRANSACTION_ID
         FROM '||p_interface_table_name||' UAI1
        WHERE UAI1.DATA_SET_ID = :data_set_id
          AND ROWNUM = 1';
      EXECUTE IMMEDIATE l_dynamic_sql
      INTO l_dummy
      USING p_data_set_id;

    ERROR_HANDLER.Add_Error_Message(
        p_message_text                  => x_msg_data
       ,p_row_identifier                => l_dummy
       ,p_application_id                => 'EGO'
       ,p_message_type                  => FND_API.G_RET_STS_ERROR
       ,p_entity_id                     => G_ENTITY_ID
       ,p_table_name                    => p_interface_table_name
       ,p_entity_code                   => G_ENTITY_CODE
      );
      RAISE;
END Prepare_Dynamic_Sqls_Clob;
/* Bug 10151142 : End */


----------------------------------------------------------------------


                          ----------------
                          -- Procedures --
                          ----------------

----------------------------------------------------------------------

PROCEDURE Bulk_Load_User_Attrs_Data (
     p_api_version                   IN   NUMBER
    ,p_application_id                IN   NUMBER
    ,p_attr_group_type               IN   VARCHAR2
    ,p_object_name                   IN   VARCHAR2
    ,p_hz_party_id                   IN   VARCHAR2
    ,p_interface_table_name          IN   VARCHAR2
    ,p_data_set_id                   IN   NUMBER
    ,p_entity_id                     IN   NUMBER     DEFAULT NULL
    ,p_entity_index                  IN   NUMBER     DEFAULT NULL
    ,p_entity_code                   IN   VARCHAR2   DEFAULT NULL
    ,p_debug_level                   IN   NUMBER     DEFAULT 0
    ,p_init_error_handler            IN   VARCHAR2   DEFAULT FND_API.G_TRUE
    ,p_init_fnd_msg_list             IN   VARCHAR2   DEFAULT FND_API.G_FALSE
    ,p_log_errors                    IN   VARCHAR2   DEFAULT FND_API.G_FALSE
    ,p_add_errors_to_fnd_stack       IN   VARCHAR2   DEFAULT FND_API.G_FALSE
    ,p_commit                        IN   VARCHAR2   DEFAULT FND_API.G_FALSE
    ,p_default_dl_view_priv_list     IN   EGO_COL_NAME_VALUE_PAIR_ARRAY DEFAULT NULL
    ,p_default_dl_edit_priv_list     IN   EGO_COL_NAME_VALUE_PAIR_ARRAY DEFAULT NULL
    ,p_default_view_privilege        IN   VARCHAR2   DEFAULT NULL
    ,p_default_edit_privilege        IN   VARCHAR2   DEFAULT NULL
    ,p_privilege_predicate_api_name  IN   VARCHAR2   DEFAULT NULL
    ,p_related_class_codes_query     IN   VARCHAR2   DEFAULT '-100'
    ,p_validate                      IN   BOOLEAN    DEFAULT TRUE
    ,p_do_dml                        IN   BOOLEAN    DEFAULT TRUE
    ,p_do_req_def_valiadtion         IN   BOOLEAN    DEFAULT TRUE
    ,x_return_status                 OUT NOCOPY VARCHAR2
    ,x_errorcode                     OUT NOCOPY NUMBER
    ,x_msg_count                     OUT NOCOPY NUMBER
    ,x_msg_data                      OUT NOCOPY VARCHAR2
) IS

    l_api_name               CONSTANT VARCHAR2(30) := 'Bulk_Load_User_Attrs_Data';

    --we don't use l_api_version yet, but eventually we might:
    --if we change required parameters, version goes FROM n.x to (n+1).x
    --if we change optional parameters, version goes FROM x.n to x.(n+1)
    l_api_version            CONSTANT NUMBER := 1.0;

    l_view_priv_to_check                FND_FORM_FUNCTIONS.FUNCTION_NAME%TYPE;  --4105308
    l_edit_priv_to_check                FND_FORM_FUNCTIONS.FUNCTION_NAME%TYPE;  --4105308

    l_class_blk_tbl_declare             VARCHAR2(1000);
    l_class_blk_tbl_list                VARCHAR2(100);
    l_class_blk_tbl_list_2              VARCHAR2(100);

    l_dl_blk_tbl_declare                VARCHAR2(1000);
    l_dl_blk_tbl_list                   VARCHAR2(100);
    l_dl_blk_tbl_list_2                 VARCHAR2(100);

    l_pk_blk_tbl_declare                VARCHAR2(1000);
    l_pk_blk_tbl_list                   VARCHAR2(100);
    l_pk_blk_tbl_list_2                 VARCHAR2(100);
    l_dynamic_sql                       VARCHAR2(32767);
    l_dynamic_query                     VARCHAR2(32767);
    l_dynamic_sql_clob                  CLOB; /** added to bug 14145164 */
    cur_l_dynamic_sql_clob              INTEGER;/** added to bug 14145164 */
    l_dummy_ret_val                     INTEGER;/** added to bug 14145164 */
    l_pre_event_failed_sql              VARCHAR2(5000);
    l_defaltening_sql                   VARCHAR2(20000);
    l_defaltening_sql_create            VARCHAR2(32767);
    l_dynamic_sql_delete_post           VARCHAR2(32767); /*Uncommeneted code for bug 8485287*/
    l_deflatening_sql_where             VARCHAR2(10000);
    l_dynamic_group_by                  VARCHAR2(2000);
    l_dynamic_sql_1                     VARCHAR2(32767);
    --Bug 13923293 /* We are going to use a new variable to avoid size issue,
    -- However for future perspective we will CLOB so that such issue does not occurs.*/
    l_dynamic_sql_2                     VARCHAR2(32767);
    l_ext_table_select                  VARCHAR2(32767);
    l_dummy                             NUMBER;
   l_priv_predicate                    VARCHAR2(32767);

    -- 6070367 this must be more than double fnd_form_functions.function_name
    l_prev_ag_id_priv                   VARCHAR2(1000);
    l_do_dml_for_this_ag                BOOLEAN;

    l_no_of_err_recs                    NUMBER;

    l_priv_func_cursor_id               NUMBER;
    l_ivs_num_cursor_id                 NUMBER;
    l_ivs_date_cursor_id                NUMBER;
    l_ivs_date_time_cursor_id           NUMBER;
    l_ivs_char_cursor_id                NUMBER;
    l_nvs_num_cursor_id                 NUMBER;
    l_nvs_date_cursor_id                NUMBER;
    l_nvs_datetime_cursor_id            NUMBER;
    l_nvs_char_cursor_id                NUMBER;
    l_req_num_cursor_id                 NUMBER;
    l_req_char_cursor_id                NUMBER;
    l_req_date_cursor_id                NUMBER;
    l_default_num_cursor_id             NUMBER;
    l_default_date_cursor_id            NUMBER;
    l_default_char_cursor_id            NUMBER;
    l_max_size_char_cursor              NUMBER;
    l_max_size_num_cursor               NUMBER;
    l_colcheck_num_cursor_id            NUMBER;
    l_colcheck_char_cursor_id           NUMBER;
    l_colcheck_date_cursor_id           NUMBER;
    l_bad_tvs_sql_cursor_id             NUMBER;
    l_sr_tvs_num_cursor_id1             NUMBER;
    l_sr_tvs_num_cursor_id2             NUMBER;
    l_sr_tvs_date_cursor_id1            NUMBER;
    l_sr_tvs_date_cursor_id2            NUMBER;
    l_sr_tvs_str_cursor_id1             NUMBER;
    l_sr_tvs_str_cursor_id2             NUMBER;
    l_tvs_char_cursor_id                NUMBER;
    l_tvs_num_cursor_id                 NUMBER;
    l_tvs_date_cursor_id                NUMBER;
    l_bad_bindattrs_tvs_cursor_id       NUMBER;
    l_pre_event_failed_cursor_id        NUMBER;

    wierd_constant                      VARCHAR2(100);
    wierd_constant_2                    VARCHAR2(100);

    l_attr_group_metadata_obj           EGO_ATTR_GROUP_METADATA_OBJ;
    l_attr_metadata_table               EGO_ATTR_METADATA_TABLE;
    l_attr_metadata_table_sr            EGO_ATTR_METADATA_TABLE;
    l_attr_metadata_table_1             EGO_ATTR_METADATA_TABLE;
    l_add_all_to_cm            VARCHAR2(1); --added by Maychen for ER 9489112
    l_item_rev_dl_id           NUMBER := 43106;

/*
DYLAN: Gaurav, why do we have three Attr metadata table variables?  Surely we only need one...?
*/

    l_intf_tbl_select                   VARCHAR2(32767);
    l_intf_column_name                  VARCHAR2(50);

    l_ext_b_table_name                  VARCHAR2(30);
    l_ext_tl_table_name                 VARCHAR2(30);
    l_ext_vl_name                       VARCHAR2(30);

    l_num_data_level_columns            NUMBER := 0;
    l_class_code_column_name            VARCHAR2(30);
    l_class_code_column_type            VARCHAR2(30);

    l_data_level_1                      VARCHAR2(30);
    l_data_level_column_1               VARCHAR2(150);
    l_dl_col_data_type_1                VARCHAR2(150);
    l_data_level_1_disp_name            VARCHAR2(80);

    l_data_level_2                      VARCHAR2(30);
    l_data_level_column_2               VARCHAR2(150);
    l_dl_col_data_type_2                VARCHAR2(150);
    l_data_level_2_disp_name            VARCHAR2(80);

    l_data_level_3                      VARCHAR2(30);
    l_data_level_column_3               VARCHAR2(150);
    l_dl_col_data_type_3                VARCHAR2(150);
    l_data_level_3_disp_name            VARCHAR2(80);

    l_pk1_column_name                   VARCHAR2(30);
    l_pk2_column_name                   VARCHAR2(30);
    l_pk3_column_name                   VARCHAR2(30);
    l_pk4_column_name                   VARCHAR2(30);
    l_pk5_column_name                   VARCHAR2(30);
    l_pk1_column_type                   VARCHAR2(8);
    l_pk2_column_type                   VARCHAR2(8);
    l_pk3_column_type                   VARCHAR2(8);
    l_pk4_column_type                   VARCHAR2(8);
    l_pk5_column_type                   VARCHAR2(8);
    l_concat_pk_cols_sel                VARCHAR2(2000);
    l_concat_pk_cols_UAI2               VARCHAR2(32767);
/*
DYLAN: perhaps at some point we can consolidate and re-use
variables wherever possible to reduce the memory footprint
of this procedure.  But for now, let's leave it.
*/

 --
 -- Bug 12765998. Making the size of variables to MAX.
 -- For TL cols with decoded statements, the size
 -- of SELECT and WHERE clause can easily surpass
 -- existing values.
 -- sreharih. Mon Sep 26 12:58:32 PDT 2011
 --
    l_rtcq_alias_cc_pk_dl_list          VARCHAR2(32767);
    l_rtcq_alias_b_cols_list            VARCHAR2(32767);
    l_rtcq_alias_b_cols_list_1          VARCHAR2(32767);
    l_final_b_col_list                  VARCHAR2(32767);
    l_final_tl_col_list                 VARCHAR2(32767);
    l_rtcq_alias_tl_cols_list           VARCHAR2(32767);
    l_rtcq_alias_tl_cols_list_1         VARCHAR2(32767);
    l_no_alias_cc_pk_dl_list            VARCHAR2(32767);
    l_no_alias_b_values_list            VARCHAR2(32767);
    l_no_alias_b_cols_list              VARCHAR2(32767);
    l_no_alias_tl_cols_list             VARCHAR2(32767);
    l_no_alias_tl_cols_sel_list         VARCHAR2(32767);
    l_row_to_column_query_base          VARCHAR2(32767);
    l_row_to_column_query_ag_part       VARCHAR2(32767);
    l_row_to_column_attr_decode         VARCHAR2(32767);
    l_rtcq_to_ext_where_base            VARCHAR2(32767);
    l_rtcq_to_ext_where_uks             VARCHAR2(32767);
    l_rtcq_to_ext_whr_uks_idnt_chk      VARCHAR2(32767);
    l_row_to_column_query               VARCHAR2(32767);
    l_rn_index_for_ag                   NUMBER;
    l_uom_column                        VARCHAR2(30);
    l_uom_column1                       VARCHAR2(30);
    l_db_col_tbl_declare_ext_id         VARCHAR2(400);
    l_db_col_tbl_declare_attrs          VARCHAR2(8000);
    l_db_col_tbl_collect_ext_id         VARCHAR2(20);
    l_db_col_tbl_collect_b_attrs        VARCHAR2(1400);
    l_db_col_tbl_collect_tl_attrs       VARCHAR2(800);
    l_db_col_tbl_set_b_attrs            VARCHAR2(10000);
    l_db_col_tbl_set_tl_attrs           VARCHAR2(5000);
    l_db_col_tbl_where_ext_id           VARCHAR2(80);

    l_tvs_table_name                    VARCHAR2(240);
    l_tvs_val_col                       VARCHAR2(240);
    l_tvs_id_col                        VARCHAR2(240);
    l_tvs_mean_col                      VARCHAR2(240);
    l_tvs_where_clause                  VARCHAR2(32767);
    l_tvs_select                        VARCHAR2(32767);
    l_tvs_num_val_check_select          VARCHAR2(32767);
    l_tvs_date_val_check_select         VARCHAR2(32767);
    l_tvs_str_val_check_select          VARCHAR2(32767);

    l_attrname_start_index              NUMBER;
    l_attrname_end_index                NUMBER;
    l_tvs_col                           VARCHAR2(240);
    l_bind_attr_name                    VARCHAR2(30);
    l_ext_attr_col_name                 VARCHAR2(1000);
    l_bind_attr_data_type               VARCHAR2(30);
    --bug 9952371  increasing the size of the two local varchar2 variable from 5000 to 32767
    l_value_from_ext_table              VARCHAR2(32767);
    l_value_from_intftbl                VARCHAR2(32767);
    l_tvs_metadata_fetched              BOOLEAN;

    l_attr_exists_in_intf               VARCHAR2(10);
    l_null_date_time_value              VARCHAR2(100);
    l_null_date_value                   VARCHAR2(100);
    l_ag_id_col_exists                  BOOLEAN;

    l_dist_attr_in_data_set_rec         DIST_ATTR_IN_DATA_SET_REC;
    l_dist_attrs_in_data_set_table      DIST_ATTR_IN_DATA_SET_TABLE;
    --bug9846845 added one CLOB parameter
    l_tvs_where_clause_clob             CLOB;

    TYPE DYNAMIC_CUR IS REF CURSOR;
    l_dynamic_cursor                    DYNAMIC_CUR;
    l_dynamic_dist_ag_cursor            DYNAMIC_CUR;
    l_mr_dynamic_cursor                 DYNAMIC_CUR;

    TYPE ATTR_METADATA_RECORD IS RECORD
    (
      ATTR_ID                 NUMBER,
      ATTR_GROUP_ID           NUMBER,
      ATTR_GROUP_INT_NAME     VARCHAR2(30),
      MULTI_ROW_CODE          VARCHAR2(1),
      ATTR_INT_NAME           VARCHAR2(30),
      DATA_TYPE               VARCHAR2(30),
      UNIQUE_KEY_FLAG         VARCHAR2(1),
      DEFAULT_VALUE           VARCHAR2(2000) ,
      MAXIMUM_SIZE            NUMBER(4), --Bug12907500
      REQUIRED_FLAG           VARCHAR2(1),
      VALUE_SET_ID            NUMBER(10),
      VALIDATION_TYPE         VARCHAR2(1),
      MINIMUM_VALUE           VARCHAR2(150),
      MAXIMUM_VALUE           VARCHAR2(150),
      UOM_CODE                VARCHAR2(3),
      UOM_CLASS               VARCHAR2(10),
      DATA_LEVEL_ID           NUMBER,
      VIEW_PRIVILEGE          FND_FORM_FUNCTIONS.FUNCTION_NAME%TYPE, --4105308
      EDIT_PRIVILEGE          FND_FORM_FUNCTIONS.FUNCTION_NAME%TYPE --4105308
    );

    -- Fix for bug#9336604
    -- l_attr_metadata_rec                 ATTR_METADATA_RECORD;
    TYPE l_cursor  IS TABLE OF ATTR_METADATA_RECORD;
    l_attr_metadata_rec l_cursor;

    TYPE AG_RECORD IS RECORD
    (
      EXTENSION_ID           NUMBER,
      ATTR_GROUP_INT_NAME    VARCHAR2(30),
      TRANSACTION_TYPE       VARCHAR2(10),
      ROW_IDENTIFIER         NUMBER,
      PK1                    VARCHAR2(30),
      PK2                    VARCHAR2(30),
      PK3                    VARCHAR2(30),
      PK4                    VARCHAR2(30),
      PK5                    VARCHAR2(30),
      DATA_LEVEL_ID          NUMBER,
      DL1                    VARCHAR2(30),
      DL2                    VARCHAR2(30),
      DL3                    VARCHAR2(30),
      DL4                    VARCHAR2(30),
      DL5                    VARCHAR2(30),
      ATTR_NAME_VALUES       VARCHAR2(30000)
    );

    l_ag_deflatened_row            AG_RECORD;

    TYPE AG_RECORD_TABLE IS TABLE OF AG_RECORD;
    l_ag_deflatened_row_table      AG_RECORD_TABLE;

    l_attr_name                  VARCHAR2(30);
    l_old_value                  VARCHAR2(1000);
    l_new_value                  VARCHAR2(1000);
    l_attr_name_val_str          VARCHAR2(30000);
    l_event_name                 VARCHAR2(240);
    l_is_pre_event_enabled_flag  VARCHAR2(1);
    l_pre_event_name             VARCHAR2(240);
  /*code added for bug 8485287*/
    l_new_post_event_enabled_flag  VARCHAR2(1);
    l_new_post_event_name          VARCHAR2(240);
  /*end code added for bug 8485287*/
    attr_name_val_pair             EGO_ATTR_TABLE;
    l_event_key                  VARCHAR2(300);
    l_group_by_pre               VARCHAR2(200);
    l_successful_rowcount        NUMBER;

/*
DYLAN: There's no reason to have the following record type: just declare a variable:
e.g., l_attr_group_int_name VARCHAR2(30);
*/
    TYPE DIST_MR_ATTR_GR_REC IS RECORD
    (
     ATTR_GROUP_INT_NAME      VARCHAR2(30)
    );

    l_attr_group_intf_rec               DIST_MR_ATTR_GR_REC;

    l_err_col_static_sql          VARCHAR2(32767);
    l_err_where_static_sql        VARCHAR2(32767);

    G_NO_ROWS_IN_INTF_TABLE       EXCEPTION;

    l_attr_base_uom_code          VARCHAR2(10);

    l_is_post_event_enabled_flag  VARCHAR2(1);
    l_is_second_post_event_flag   VARCHAR2(1);

    -- Bug 10097738 : Start
     l_column_exists               VARCHAR2(1);
     l_unique_value_col            VARCHAR2(20);
     l_unique_value                VARCHAR2(30);
     -- Bug 10097738 : End

    l_data_level_col_exists       BOOLEAN;
    l_object_id                   NUMBER;
    l_list_of_dl_for_ag_type      EGO_DATA_LEVEL_METADATA_TABLE;

    l_dl_pk_col1_sql              VARCHAR2(32000);
    l_dl_pk_col2_sql              VARCHAR2(32000);
    l_dl_pk_col3_sql              VARCHAR2(32000);
    l_dl_pk_col4_sql              VARCHAR2(32000);
    l_dl_pk_col5_sql              VARCHAR2(32000);
    l_dl_pk1_col_name             VARCHAR2(30);
    l_dl_pk2_col_name             VARCHAR2(30);
    l_dl_pk3_col_name             VARCHAR2(30);
    l_dl_pk4_col_name             VARCHAR2(30);
    l_dl_pk5_col_name             VARCHAR2(30);

    l_priv_attr_id                NUMBER := -1;
    l_correct_date_time_sql_uai      VARCHAR2(240); -- abedajna
    l_correct_date_time_sql_extvl    VARCHAR2(240); -- abedajna
    l_concat_pk_cols              VARCHAR2(32767);  -- Bug 9851212

    --bug 12397223 begin
    CURSOR enabled_data_level_cols(p_attr_group_id IN NUMBER)
    IS
    SELECT  DATA_LEVEL_ID
           ,DATA_LEVEL_NAME
           ,USER_DATA_LEVEL_NAME
           ,PK1_COLUMN_NAME
           ,PK2_COLUMN_NAME
           ,PK3_COLUMN_NAME
           ,PK4_COLUMN_NAME
           ,PK5_COLUMN_NAME
           ,PK1_COLUMN_TYPE
           ,PK2_COLUMN_TYPE
           ,PK3_COLUMN_TYPE
           ,PK4_COLUMN_TYPE
           ,PK5_COLUMN_TYPE
     FROM EGO_DATA_LEVEL_VL
    WHERE DATA_LEVEL_ID IN (    SELECT DATA_LEVEL_ID
    FROM EGO_ATTR_GROUP_DL
    WHERE ATTR_GROUP_ID = p_attr_group_id);

    l_data_level_cols_rec enabled_data_level_cols%ROWTYPE;
    --bug 12397223 end

    l_ext_table_select1           VARCHAR2(32767); -- Bug 13414358

    -- Bug 10151142 : Start
    l_buffer                    VARCHAR2(8191)  := '';
    l_tvs_where_clause_buffer   VARCHAR2(32767);
    l_return_status             VARCHAR2(1);
    l_msg_data                  VARCHAR2(4000);

    l_amount                    NUMBER;
    l_offset                    NUMBER  :=  1;
    l_dynamic_sql_1_cursor_id   NUMBER;
    l_dynamic_sql_cursor_id     NUMBER;
    l_clob_length               NUMBER;
    l_tvs_string_length         NUMBER;
    l_tvs_colb_length_diff      NUMBER;
    l_sql_1_ub                  NUMBER;
    l_sql_ub                    NUMBER;

    l_tvs_where_clause_clob1        CLOB;
    l_tvs_where_clause_clob2        CLOB;
    l_tvs_select_clob               CLOB;
    l_tvs_num_val_check_sel_clob    CLOB;
    l_tvs_date_val_check_sel_clob   CLOB;
    l_tvs_str_val_check_sel_clob    CLOB;

    l_dynamic_sql_v_type    dbms_sql.varchar2a;
    l_dynamic_sql_1_v_type  dbms_sql.varchar2a;
    -- Bug 10151142 : End

  BEGIN
    code_debug(l_api_name|| 'Starting  ');

    -- Standard start of API savepoint
    IF FND_API.To_Boolean(p_commit) THEN
      SAVEPOINT Bulk_Load_User_Attrs_Data_PVT;
    END IF;

    -- Check for call compatibility
    IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version,
                                       l_api_name, G_PKG_NAME)
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    G_CURRENT_USER_ID  := FND_GLOBAL.User_Id;
    G_CURRENT_LOGIN_ID := FND_GLOBAL.Login_Id;
    G_USER_NAME        := FND_GLOBAL.USER_NAME;

    --ER 9489112, to get data_level_id for item revision level
    --and get 'Add All Imported Items to Change Order' option when change order option enabled
    l_add_all_to_cm := EGO_IMPORT_PVT.getAddAllToChangeFlag(p_batch_id => p_data_set_id);

    SELECT DATA_LEVEL_ID
    INTO  l_item_rev_dl_id
    FROM EGO_DATA_LEVEL_B
    WHERE ATTR_GROUP_TYPE = 'EGO_ITEMMGMT_GROUP'
      AND APPLICATION_ID = 431
      AND DATA_LEVEL_NAME = 'ITEM_REVISION_LEVEL';
    ---------------------------------
    -- Error Handler Initialization --
    ---------------------------------
    IF (FND_API.To_Boolean(p_add_errors_to_fnd_stack)) THEN
      G_ADD_ERRORS_TO_FND_STACK := 'Y';
    ELSE
      G_ADD_ERRORS_TO_FND_STACK := 'N';
    END IF;
    BEGIN
      SELECT application_short_name
      INTO  G_APPLICATION_CONTEXT
      FROM  fnd_application
      WHERE application_id = p_application_id;
    EXCEPTION
      WHEN OTHERS THEN
        G_APPLICATION_CONTEXT := p_application_id;
    END;
    -- Initialize message list even though we don't currently use it
    IF FND_API.To_Boolean(p_init_fnd_msg_list) THEN
      FND_MSG_PUB.Initialize;
    END IF;

    G_ENTITY_ID        := p_entity_id;
    -- entity code will take precedence over entity_id
    SELECT NVL(p_entity_code, DECODE(G_ENTITY_ID, NULL, G_APPLICATION_CONTEXT||'_EXTFWK_USER_ATTRS',NULL))
    INTO G_ENTITY_CODE
    FROM DUAL;

    -- Initialize error handler
    IF FND_API.To_Boolean(p_init_error_handler) THEN
      ERROR_HANDLER.Initialize;
      ERROR_HANDLER.Set_Bo_Identifier(EGO_USER_ATTRS_DATA_PVT.G_BO_IDENTIFIER);
      IF (p_debug_level > 0 AND ERROR_HANDLER.Get_Debug() = 'N') THEN
        EGO_USER_ATTRS_DATA_PVT.Set_Up_Debug_Session(G_ENTITY_ID, G_ENTITY_CODE, p_debug_level);
      END IF;
      -- test the message initialization.
      code_debug('Starting Bulk load concurrent program '||p_data_set_id, 0);
    END IF;

    -- select cols for
    l_err_col_static_sql := ' SELECT process_status, row_identifier, '
              ||' attr_group_int_name, attr_int_name, attr_value_str, '
              ||' attr_value_num, attr_value_date, attr_disp_value, '
              ||' transaction_type, transaction_id, attr_group_id ';
    l_err_where_static_sql := ' WHERE data_set_id = :data_set_id '  --||p_data_set_id /*Fix for bug#9678667. Literal to bind*/
              ||' AND process_status >= '||G_PS_BAD_ATTR_OR_AG_METADATA
    -- Bug 12895265
    --          ||' AND (process_status - '||G_PS_OTHER_ATTRS_INVALID ||') > '||G_PS_IN_PROCESS
              ||' AND attr_group_int_name = :attr_group_int_name ';

    l_no_of_err_recs := ERROR_HANDLER.Get_Message_Count ;

    ----------------------------------
    -- Fetching the object_id      --
    ----------------------------------
    SELECT OBJECT_ID
      INTO l_object_id
      FROM FND_OBJECTS
     WHERE OBJ_NAME = p_object_name;

    -----------------------------------------
    -- Fetch the PK column names and data  --
    -- types for the passed-in object name --
    -----------------------------------------
    SELECT PK1_COLUMN_NAME, PK1_COLUMN_TYPE,
           PK2_COLUMN_NAME, PK2_COLUMN_TYPE,
           PK3_COLUMN_NAME, PK3_COLUMN_TYPE,
           PK4_COLUMN_NAME, PK4_COLUMN_TYPE,
           PK5_COLUMN_NAME, PK5_COLUMN_TYPE
      INTO l_pk1_column_name, l_pk1_column_type,
           l_pk2_column_name, l_pk2_column_type,
           l_pk3_column_name, l_pk3_column_type,
           l_pk4_column_name, l_pk4_column_type,
           l_pk5_column_name, l_pk5_column_type
      FROM FND_OBJECTS
     WHERE OBJ_NAME = p_object_name;

    --------------------------------------
    -- Fetching the class code col name --
    --------------------------------------
    SELECT CLASSIFICATION_COL_NAME, CLASSIFICATION_COL_TYPE
      INTO l_class_code_column_name, l_class_code_column_type
      FROM EGO_FND_OBJECTS_EXT
     WHERE OBJECT_NAME = p_object_name;

    ----------------------------------------------------------
    -- Get the B, TL, and VL names for this Attr Group Type --
    ----------------------------------------------------------
    SELECT FLEX.APPLICATION_TABLE_NAME        EXT_TABLE_NAME,
           FLEX_EXT.APPLICATION_TL_TABLE_NAME EXT_TL_TABLE_NAME,
           FLEX_EXT.APPLICATION_VL_NAME       EXT_VL_NAME
      INTO l_ext_b_table_name,
           l_ext_tl_table_name,
           l_ext_vl_name
      FROM FND_DESCRIPTIVE_FLEXS              FLEX,
           EGO_FND_DESC_FLEXS_EXT             FLEX_EXT
     WHERE FLEX.APPLICATION_ID = FLEX_EXT.APPLICATION_ID(+)
       AND FLEX.DESCRIPTIVE_FLEXFIELD_NAME = FLEX_EXT.DESCRIPTIVE_FLEXFIELD_NAME(+)
       AND FLEX.APPLICATION_ID = p_application_id
       AND FLEX.DESCRIPTIVE_FLEXFIELD_NAME = p_attr_group_type;

    -----------------------------------------------------------
    -- Some callers don't have TL tables (and hence no VLs); --
    -- in such cases we use the B table name instead         --
    -----------------------------------------------------------
    IF (l_ext_vl_name IS NULL) THEN
      l_ext_vl_name := l_ext_b_table_name;
    END IF;

    IF FND_API.TO_BOOLEAN(EGO_USER_ATTRS_COMMON_PVT.has_column_in_table(
              p_table_name => p_interface_table_name,
              p_column_name => 'DATA_LEVEL_ID')) THEN
      -------------------------------------------------------
      -- Populating the the data_level_id in case there is --
      -- only one enabled data level for it                --
      -------------------------------------------------------
      EXECUTE IMMEDIATE
      'UPDATE '||p_interface_table_name||' UAI1                          '||
      '   SET DATA_LEVEL_ID = (SELECT DATA_LEVEL_ID                      '||
      '                          FROM EGO_ATTR_GROUP_DL                  '||
      '                         WHERE ATTR_GROUP_ID = UAI1.ATTR_GROUP_ID '||
      '                        )                                         '||
      ' WHERE UAI1.DATA_SET_ID = :data_set_id                            '||
      '   AND UAI1.PROCESS_STATUS = '||G_PS_IN_PROCESS||'                '||
      '   AND UAI1.ATTR_GROUP_TYPE = :attr_group_type                    '||
      '   AND (SELECT COUNT(*) FROM EGO_ATTR_GROUP_DL                    '||
      '         WHERE ATTR_GROUP_ID = UAI1.ATTR_GROUP_ID) < 2            '||
      '   AND DATA_LEVEL_ID IS NULL                                      '||
      '   AND DATA_LEVEL_NAME IS NULL                                    '||
      '   AND USER_DATA_LEVEL_NAME IS NULL                               '
      USING p_data_set_id, p_attr_group_type;
      ------------------------------------------------------
      -- Converting the data level internal name to id    --
      ------------------------------------------------------
      EXECUTE IMMEDIATE
      '  UPDATE '||p_interface_table_name||' UAI1                        '||
      '     SET DATA_LEVEL_ID = (SELECT DATA_LEVEL_ID                    '||
      '                         FROM EGO_DATA_LEVEL_VL                   '||
      '                        WHERE (DATA_LEVEL_NAME = NVL(UAI1.DATA_LEVEL_NAME, CHR(0)) '||
      '                               OR USER_DATA_LEVEL_NAME = NVL(UAI1.USER_DATA_LEVEL_NAME, CHR(0)))'||
      '                          AND APPLICATION_ID = :application_id    '||
      '                          AND ATTR_GROUP_TYPE = :attr_group_type  '||
      '                       )                                          '||
      '   WHERE UAI1.DATA_SET_ID = :data_set_id                          '||
      '     AND UAI1.PROCESS_STATUS = '||G_PS_IN_PROCESS                  ||
      '     AND UAI1.ATTR_GROUP_TYPE = :attr_group_type                  '||
      '     AND DATA_LEVEL_ID IS NULL                                    '||
      '     AND NOT( DATA_LEVEL_NAME IS NULL AND USER_DATA_LEVEL_NAME IS NULL) '
      USING p_application_id, p_attr_group_type, p_data_set_id, p_attr_group_type;
      ----------------------------------------------------------
      -- Erroring out the rows wid invalid/null data level id --
      ----------------------------------------------------------

      EXECUTE IMMEDIATE
      'UPDATE '||p_interface_table_name||' UAI1                          '||
      '   SET PROCESS_STATUS = PROCESS_STATUS +'||G_PS_INVALID_DATA_LEVEL ||
      ' WHERE UAI1.DATA_SET_ID = :data_set_id                            '||
      '   AND UAI1.PROCESS_STATUS = '||G_PS_IN_PROCESS||'                '||
      '   AND UAI1.ATTR_GROUP_TYPE = :attr_group_type                    '||
      '   AND (   DATA_LEVEL_ID IS NULL                                  '||
      '         OR NOT EXISTS(SELECT NULL                                '||
      '                        FROM EGO_ATTR_GROUP_DL                    '||
      '                       WHERE ATTR_GROUP_ID = UAI1.ATTR_GROUP_ID   '||
      '                         AND DATA_LEVEL_ID = UAI1.DATA_LEVEL_ID) )'
      USING p_data_set_id, p_attr_group_type;
    END IF;

    -------------------------------------------------------
    -- Checking weather the ext table has data_level_id  --
    -- column or not.                                    --
    -------------------------------------------------------

    l_data_level_col_exists :=  FND_API.TO_BOOLEAN(
            EGO_USER_ATTRS_COMMON_PVT.has_column_in_table(
              p_table_name => l_ext_b_table_name,
              p_column_name => 'DATA_LEVEL_ID'));

    l_list_of_dl_for_ag_type := EGO_USER_ATTRS_COMMON_PVT.Get_Data_Levels_For_AGType( p_application_id  => p_application_id
                                                                                     ,p_attr_group_type => p_attr_group_type);

    ------------------------------------------------------------
    -- Get data level information for the given object name   --
    -- R12C onwards the data level info wud not be stored in  --
    -- lookups table. Hence we get it from the dl meta data   --
    -- table fetched. We assume here that there can be only 3 --
    -- data levels with only one pk column. This assumption is -
    -- as per the support offered prior to R12C               --
    ------------------------------------------------------------
    l_dummy := 0;
    FOR i IN l_list_of_dl_for_ag_type.FIRST .. l_list_of_dl_for_ag_type.LAST
    LOOP

      IF(l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME1 <> 'NONE'
         AND l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME1 IS NOT NULL) THEN

          l_dummy := l_dummy + 1;

          IF (l_dummy = 1) THEN

            l_data_level_1           := l_list_of_dl_for_ag_type(i).DATA_LEVEL_NAME;
            l_data_level_column_1    := l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME1;
            l_dl_col_data_type_1     := l_list_of_dl_for_ag_type(i).PK_COLUMN_TYPE1;
            l_data_level_1_disp_name := l_list_of_dl_for_ag_type(i).USER_DATA_LEVEL_NAME;
            l_num_data_level_columns := 1;

          ELSIF (l_dummy = 2) THEN

            l_data_level_2           := l_list_of_dl_for_ag_type(i).DATA_LEVEL_NAME;
            l_data_level_column_2    := l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME1;
            l_dl_col_data_type_2     := l_list_of_dl_for_ag_type(i).PK_COLUMN_TYPE1;
            l_data_level_2_disp_name := l_list_of_dl_for_ag_type(i).USER_DATA_LEVEL_NAME;
            l_num_data_level_columns := 2;

          ELSIF (l_dummy = 3) THEN
            l_data_level_3           := l_list_of_dl_for_ag_type(i).DATA_LEVEL_NAME;
            l_data_level_column_3    := l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME1;
            l_dl_col_data_type_3     := l_list_of_dl_for_ag_type(i).PK_COLUMN_TYPE1;
            l_data_level_3_disp_name := l_list_of_dl_for_ag_type(i).USER_DATA_LEVEL_NAME;
            l_num_data_level_columns := 3;

          END IF;

      END IF;

    END LOOP;

    -------------------------------------------------------------
    -- Find out weather the ATTR_GROUP_ID column exists in the --
    -- table where attribute data is to be uploaded or not     --
    -------------------------------------------------------------

    l_ag_id_col_exists :=  FND_API.TO_BOOLEAN(
            EGO_USER_ATTRS_COMMON_PVT.has_column_in_table(
              p_table_name => l_ext_b_table_name,
              p_column_name => 'ATTR_GROUP_ID'));

    l_pk_blk_tbl_declare := '';
    l_pk_blk_tbl_list := '';
    ---------------------------------------------------------
    --Building the concatenated pks for select and where   --
    ---------------------------------------------------------
    IF (l_pk1_column_name IS NOT NULL) THEN
       l_concat_pk_cols_sel := l_concat_pk_cols_sel||l_pk1_column_name||',';
       l_concat_pk_cols_UAI2 := l_concat_pk_cols_UAI2 || ' AND '||l_pk1_column_name||' = UAI2.'||l_pk1_column_name;
       l_pk_blk_tbl_list := l_pk_blk_tbl_list || '  pk_1_tbl ';
       l_pk_blk_tbl_list_2 := l_pk_blk_tbl_list_2 || '  pk_1_tbl(i) ';
       IF(l_pk1_column_type = 'INTEGER') THEN
          l_pk_blk_tbl_declare := l_pk_blk_tbl_declare || ' pk_1_tbl EGO_USER_ATTRS_BULK_PVT.EGO_USER_ATTRS_BULK_NUM_TBL; ';
       ELSE
          l_pk_blk_tbl_declare := l_pk_blk_tbl_declare || ' pk_1_tbl EGO_USER_ATTRS_BULK_PVT.EGO_USER_ATTRS_BULK_STR_TBL; ';
       END IF;
    END IF;

    IF (l_pk2_column_name IS NOT NULL) THEN
       l_concat_pk_cols_sel := l_concat_pk_cols_sel ||l_pk2_column_name||',';
       l_concat_pk_cols_UAI2 := l_concat_pk_cols_UAI2 || ' AND '||l_pk2_column_name||' = UAI2.'||l_pk2_column_name;
       l_pk_blk_tbl_list := l_pk_blk_tbl_list || ' ,pk_2_tbl ';
       l_pk_blk_tbl_list_2 := l_pk_blk_tbl_list_2 || '  ,pk_2_tbl(i) ';
       IF(l_pk2_column_type = 'INTEGER') THEN
          l_pk_blk_tbl_declare := l_pk_blk_tbl_declare || ' pk_2_tbl EGO_USER_ATTRS_BULK_PVT.EGO_USER_ATTRS_BULK_NUM_TBL; ';
       ELSE
          l_pk_blk_tbl_declare := l_pk_blk_tbl_declare || ' pk_2_tbl EGO_USER_ATTRS_BULK_PVT.EGO_USER_ATTRS_BULK_STR_TBL; ';
       END IF;
    END IF;

    IF (l_pk3_column_name IS NOT NULL) THEN
      l_concat_pk_cols_sel := l_concat_pk_cols_sel ||l_pk3_column_name||',';
      l_concat_pk_cols_UAI2 := l_concat_pk_cols_UAI2 || ' AND '||l_pk3_column_name||' = UAI2.'||l_pk3_column_name;
      l_pk_blk_tbl_list := l_pk_blk_tbl_list || ' ,pk_3_tbl ';
      l_pk_blk_tbl_list_2 := l_pk_blk_tbl_list_2 || '  ,pk_3_tbl(i) ';
      IF(l_pk3_column_type = 'INTEGER') THEN
         l_pk_blk_tbl_declare := l_pk_blk_tbl_declare || ' pk_3_tbl EGO_USER_ATTRS_BULK_PVT.EGO_USER_ATTRS_BULK_NUM_TBL; ';
      ELSE
        l_pk_blk_tbl_declare := l_pk_blk_tbl_declare || ' pk_3_tbl EGO_USER_ATTRS_BULK_PVT.EGO_USER_ATTRS_BULK_STR_TBL; ';
      END IF;
    END IF;

    IF (l_pk4_column_name IS NOT NULL) THEN
      l_concat_pk_cols_sel := l_concat_pk_cols_sel ||l_pk4_column_name||',';
      l_concat_pk_cols_UAI2 := l_concat_pk_cols_UAI2 || ' AND '||l_pk4_column_name||' = UAI2.'||l_pk4_column_name;
      l_pk_blk_tbl_list := l_pk_blk_tbl_list || ' ,pk_4_tbl ';
      l_pk_blk_tbl_list_2 := l_pk_blk_tbl_list_2 || '  ,pk_4_tbl(i) ';
      IF(l_pk4_column_type = 'INTEGER') THEN
         l_pk_blk_tbl_declare := l_pk_blk_tbl_declare || ' pk_4_tbl EGO_USER_ATTRS_BULK_PVT.EGO_USER_ATTRS_BULK_NUM_TBL; ';
      ELSE
         l_pk_blk_tbl_declare := l_pk_blk_tbl_declare || ' pk_4_tbl EGO_USER_ATTRS_BULK_PVT.EGO_USER_ATTRS_BULK_STR_TBL; ';
      END IF;
    END IF;
    IF (l_pk5_column_name IS NOT NULL) THEN
      l_concat_pk_cols_sel := l_concat_pk_cols_sel ||l_pk5_column_name||',';
      l_concat_pk_cols_UAI2 := l_concat_pk_cols_UAI2 || ' AND '||l_pk5_column_name||' = UAI2.'||l_pk5_column_name;
      l_pk_blk_tbl_list := l_pk_blk_tbl_list || ' ,pk_5_tbl ';
      l_pk_blk_tbl_list_2 := l_pk_blk_tbl_list_2 || '  ,pk_5_tbl(i) ';
      IF(l_pk5_column_type = 'INTEGER') THEN
        l_pk_blk_tbl_declare := l_pk_blk_tbl_declare || ' pk_5_tbl EGO_USER_ATTRS_BULK_PVT.EGO_USER_ATTRS_BULK_NUM_TBL; ';
      ELSE
        l_pk_blk_tbl_declare := l_pk_blk_tbl_declare || ' pk_5_tbl EGO_USER_ATTRS_BULK_PVT.EGO_USER_ATTRS_BULK_STR_TBL; ';
      END IF;
    END IF;
    ---------------------------------------------
    -- adding datalevel columns   --
    ---------------------------------------------
    IF(l_data_level_col_exists) THEN

      l_concat_pk_cols_sel := l_concat_pk_cols_sel||' DATA_LEVEL_ID , ';
      l_concat_pk_cols_UAI2 := l_concat_pk_cols_UAI2 || ' AND NVL(DATA_LEVEL_ID,'||G_NULL_TOKEN_NUM||') '||
                                                        '   = NVL(UAI2.DATA_LEVEL_ID,'||G_NULL_TOKEN_NUM||')';

      FOR i IN l_list_of_dl_for_ag_type.FIRST .. l_list_of_dl_for_ag_type.LAST
      LOOP

         IF (l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME1 IS NOT NULL AND l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME1 <> 'NONE'
            AND INSTR(l_concat_pk_cols_sel,l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME1) = 0) THEN

                 IF(l_list_of_dl_for_ag_type(i).PK_COLUMN_TYPE1 = 'NUMBER') THEN
                   wierd_constant := G_NULL_TOKEN_NUM;
                 ELSIF (l_list_of_dl_for_ag_type(i).PK_COLUMN_TYPE1 = 'DATE' OR l_list_of_dl_for_ag_type(i).PK_COLUMN_TYPE1 = 'DATETIME') THEN
                   wierd_constant := G_NULL_TOKEN_DATE;
                 ELSE
                   wierd_constant := G_NULL_TOKEN_STR;
                 END IF;
                 l_concat_pk_cols_sel := l_concat_pk_cols_sel||l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME1||' , ';

                 l_concat_pk_cols_UAI2 := l_concat_pk_cols_UAI2 || ' AND NVL('||l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME1||','||wierd_constant||') '||
                                                                   '   = NVL(UAI2.'||l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME1||','||wierd_constant||')';
         END IF;
         IF (l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME2 IS NOT NULL AND l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME2 <> 'NONE'
            AND INSTR(l_concat_pk_cols_sel,l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME2) = 0) THEN
                 IF(l_list_of_dl_for_ag_type(i).PK_COLUMN_TYPE2 = 'NUMBER') THEN
                   wierd_constant := G_NULL_TOKEN_NUM;
                 ELSIF (l_list_of_dl_for_ag_type(i).PK_COLUMN_TYPE2 = 'DATE' OR l_list_of_dl_for_ag_type(i).PK_COLUMN_TYPE2 = 'DATETIME') THEN
                   wierd_constant := G_NULL_TOKEN_DATE;
                 ELSE
                   wierd_constant := G_NULL_TOKEN_STR;
                 END IF;
                 l_concat_pk_cols_sel := l_concat_pk_cols_sel||l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME2||' , ';
                 l_concat_pk_cols_UAI2 := l_concat_pk_cols_UAI2 || ' AND NVL('||l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME2||','||wierd_constant||') '||
                                                                   '   = NVL(UAI2.'||l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME2||','||wierd_constant||')';
         END IF;
         IF (l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME3 IS NOT NULL AND l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME3 <> 'NONE'
            AND INSTR(l_concat_pk_cols_sel,l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME3) = 0) THEN
                 IF(l_list_of_dl_for_ag_type(i).PK_COLUMN_TYPE3 = 'NUMBER') THEN
                   wierd_constant := G_NULL_TOKEN_NUM;
                 ELSIF (l_list_of_dl_for_ag_type(i).PK_COLUMN_TYPE3 = 'DATE' OR l_list_of_dl_for_ag_type(i).PK_COLUMN_TYPE3 = 'DATETIME') THEN
                   wierd_constant := G_NULL_TOKEN_DATE;
                 ELSE
                   wierd_constant := G_NULL_TOKEN_STR;
                 END IF;
                 l_concat_pk_cols_sel := l_concat_pk_cols_sel||l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME3||' , ';
                 l_concat_pk_cols_UAI2 := l_concat_pk_cols_UAI2 || ' AND NVL('||l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME3||','||wierd_constant||') '||
                                                                   '   = NVL(UAI2.'||l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME3||','||wierd_constant||')';
         END IF;
         IF (l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME4 IS NOT NULL AND l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME4 <> 'NONE'
            AND INSTR(l_concat_pk_cols_sel,l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME4) = 0) THEN
                 IF(l_list_of_dl_for_ag_type(i).PK_COLUMN_TYPE4 = 'NUMBER') THEN
                   wierd_constant := G_NULL_TOKEN_NUM;
                 ELSIF (l_list_of_dl_for_ag_type(i).PK_COLUMN_TYPE4 = 'DATE' OR l_list_of_dl_for_ag_type(i).PK_COLUMN_TYPE4 = 'DATETIME') THEN
                   wierd_constant := G_NULL_TOKEN_DATE;
                 ELSE
                   wierd_constant := G_NULL_TOKEN_STR;
                 END IF;
                 l_concat_pk_cols_sel := l_concat_pk_cols_sel||l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME4||' , ';
                 l_concat_pk_cols_UAI2 := l_concat_pk_cols_UAI2 || ' AND NVL('||l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME4||','||wierd_constant||') '||
                                                                   '   = NVL(UAI2.'||l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME4||','||wierd_constant||')';
         END IF;
         IF (l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME5 IS NOT NULL AND l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME5 <> 'NONE'
            AND INSTR(l_concat_pk_cols_sel,l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME5) = 0) THEN
                 IF(l_list_of_dl_for_ag_type(i).PK_COLUMN_TYPE5 = 'NUMBER') THEN
                   wierd_constant := G_NULL_TOKEN_NUM;
                 ELSIF (l_list_of_dl_for_ag_type(i).PK_COLUMN_TYPE5 = 'DATE' OR l_list_of_dl_for_ag_type(i).PK_COLUMN_TYPE5 = 'DATETIME') THEN
                   wierd_constant := G_NULL_TOKEN_DATE;
                 ELSE
                   wierd_constant := G_NULL_TOKEN_STR;
                 END IF;
                 l_concat_pk_cols_sel := l_concat_pk_cols_sel||l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME5||' , ';
                 l_concat_pk_cols_UAI2 := l_concat_pk_cols_UAI2 || ' AND NVL('||l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME5||','||wierd_constant||') '||
                                                                   '   = NVL(UAI2.'||l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME5||','||wierd_constant||')';
         END IF;
      END LOOP;
    ELSE
       IF (l_num_data_level_columns = 1) THEN
          l_concat_pk_cols_sel := l_concat_pk_cols_sel ||l_data_level_column_1||' , ';
          l_concat_pk_cols_UAI2 := l_concat_pk_cols_UAI2 || ' AND NVL('||l_data_level_column_1||',-1) = NVL(UAI2.'||l_data_level_column_1||',-1 )';
       ELSIF (l_num_data_level_columns = 2) THEN
         l_concat_pk_cols_sel := l_concat_pk_cols_sel ||l_data_level_column_1||' , '||l_data_level_column_2||',';
         l_concat_pk_cols_UAI2 := l_concat_pk_cols_UAI2 || ' AND NVL('||l_data_level_column_1||',-1) = NVL(UAI2.'||l_data_level_column_1||',-1 )'||
                                ' AND NVL('||l_data_level_column_2||',-1) = NVL(UAI2.'||l_data_level_column_2||',-1 )';

       ELSIF (l_num_data_level_columns = 3) THEN
         l_concat_pk_cols_sel := l_concat_pk_cols_sel ||l_data_level_column_1||' , '||l_data_level_column_2||','||l_data_level_column_3||',';
         l_concat_pk_cols_UAI2 := l_concat_pk_cols_UAI2 || ' AND NVL('||l_data_level_column_1||',-1) = NVL(UAI2.'||l_data_level_column_1||',-1 )'||
                               ' AND NVL('||l_data_level_column_2||',-1) = NVL(UAI2.'||l_data_level_column_2||',-1 ) AND NVL('||l_data_level_column_3||',-1) = NVL(UAI2.'
                                 ||l_data_level_column_3||',-1 )';
       END IF;
    END IF;

    ---------------------------------------------------------------
    -- Constructing the sql code snippets for dl's and class code
    ---------------------------------------------------------------
    IF (l_data_level_column_1 IS NOT NULL AND l_data_level_column_1 <> 'NONE') THEN
      l_dl_blk_tbl_list := l_dl_blk_tbl_list || '  ,dl_1_tbl ';
      l_dl_blk_tbl_list_2 := l_dl_blk_tbl_list_2 || '  ,dl_1_tbl(i) ';
      IF(l_dl_col_data_type_1 = 'NUMBER') THEN
         l_dl_blk_tbl_declare := l_dl_blk_tbl_declare || ' dl_1_tbl EGO_USER_ATTRS_BULK_PVT.EGO_USER_ATTRS_BULK_NUM_TBL; ';
      ELSE
         l_dl_blk_tbl_declare := l_dl_blk_tbl_declare || ' dl_1_tbl EGO_USER_ATTRS_BULK_PVT.EGO_USER_ATTRS_BULK_STR_TBL; ';
      END IF;
    END IF;

    IF (l_data_level_column_2 IS NOT NULL AND l_data_level_column_2 <> 'NONE') THEN
      l_dl_blk_tbl_list := l_dl_blk_tbl_list || '  dl_2_tbl ';
      l_dl_blk_tbl_list_2 := l_dl_blk_tbl_list_2 || '  dl_2_tbl(i) ';
      IF(l_dl_col_data_type_2 = 'NUMBER') THEN
         l_dl_blk_tbl_declare := l_dl_blk_tbl_declare || ' dl_2_tbl EGO_USER_ATTRS_BULK_PVT.EGO_USER_ATTRS_BULK_NUM_TBL; ';
      ELSE
         l_dl_blk_tbl_declare := l_dl_blk_tbl_declare || ' dl_2_tbl EGO_USER_ATTRS_BULK_PVT.EGO_USER_ATTRS_BULK_STR_TBL; ';
      END IF;
    END IF;

    IF (l_data_level_column_3 IS NOT NULL AND l_data_level_column_3 <> 'NONE') THEN
      l_dl_blk_tbl_list := l_dl_blk_tbl_list || '  dl_3_tbl ';
      l_dl_blk_tbl_list_2 := l_dl_blk_tbl_list_2 || '  dl_3_tbl(i) ';
      IF(l_dl_col_data_type_3 = 'NUMBER') THEN
         l_dl_blk_tbl_declare := l_dl_blk_tbl_declare || ' dl_3_tbl EGO_USER_ATTRS_BULK_PVT.EGO_USER_ATTRS_BULK_NUM_TBL; ';
      ELSE
         l_dl_blk_tbl_declare := l_dl_blk_tbl_declare || ' dl_3_tbl EGO_USER_ATTRS_BULK_PVT.EGO_USER_ATTRS_BULK_STR_TBL; ';
      END IF;
    END IF;

    IF (l_class_code_column_name IS NOT NULL ) THEN
      l_class_blk_tbl_list := l_class_blk_tbl_list || '  class_tbl ';
      l_class_blk_tbl_list_2 := l_class_blk_tbl_list_2 || '  class_tbl(i) ';
      IF(l_class_code_column_type = 'NUMBER') THEN
         l_class_blk_tbl_declare := l_class_blk_tbl_declare || ' class_tbl EGO_USER_ATTRS_BULK_PVT.EGO_USER_ATTRS_BULK_NUM_TBL; ';
      ELSE
         l_class_blk_tbl_declare := l_class_blk_tbl_declare || ' class_tbl EGO_USER_ATTRS_BULK_PVT.EGO_USER_ATTRS_BULK_STR_TBL; ';
      END IF;
    END IF;


/*
DYLAN: why are we selecting this?  We don't treat CC as a constraint;
do we need it for any purpose in the query that's being built here?
(I can't tell.)
*/
    IF l_class_code_column_name IS NOT NULL THEN
      l_concat_pk_cols_sel := l_concat_pk_cols_sel ||l_class_code_column_name||',';
    END IF;

    IF (G_HZ_PARTY_ID IS NULL) THEN
      G_HZ_PARTY_ID := p_hz_party_id;
    END IF;

/*
    -----------------------------------------------
    -- Set this global variable once per session --
    -----------------------------------------------
    IF (G_HZ_PARTY_ID IS NULL) THEN
      IF (G_USER_NAME IS NOT NULL) THEN

        SELECT 'HZ_PARTY:'||TO_CHAR(PERSON_ID)
          INTO G_HZ_PARTY_ID
          FROM EGO_PEOPLE_V
         WHERE USER_NAME = G_USER_NAME;

      ELSE
         RAISE G_NO_USER_NAME_TO_VALIDATE;
      END IF;
    END IF;
*/

/*
DYLAN: we need to remember to confirm whether ERROR_HANDLER
init is required or will be taken care of by calling APIs
*/

/***
                     --======================--
                     -- ERROR_HANDLER SET-UP --
                     --======================--

    IF (FND_API.To_Boolean(p_init_error_handler)) THEN

      ERROR_HANDLER.Initialize();
      ERROR_HANDLER.Set_Bo_Identifier(EGO_USER_ATTRS_DATA_PVT.G_BO_IDENTIFIER);

      ---------------------------------------------------
      -- If we're debugging, we have to set up a Debug --
      -- session (unless our caller already did so)    --
      ---------------------------------------------------
      IF (p_debug_level > 0 AND ERROR_HANDLER.Get_Debug() = 'N') THEN

        EGO_USER_ATTRS_DATA_PVT.Set_Up_Debug_Session(p_entity_id
                                                    ,p_entity_code
                                                    ,p_debug_level);

      END IF;
      code_debug('Starting Bulk Load for data set ID: '||p_data_set_id, 1);

    END IF;
***/

code_debug(' Starting non-loop validations ',1);

  ---------------------------------------------------
  -- Validations are done only if the API has been --
  -- called with the parameter p_validate as TRUE  --
  -- This IF would end after the attr level validation loop --
  ------------------------------------------------------------
  IF (p_validate) THEN   -- Search for    *p_validate-IF-1* to find the END IF for this one.
                     --======================--
                     -- NON-LOOP VALIDATIONS --
                     --======================--

    -----------------------------------------------
    -- Update the interface table populating the --
    -- attribute group id for the given data     --
    -----------------------------------------------

    EXECUTE IMMEDIATE
      'UPDATE '||p_interface_table_name||' UAI1
       SET PROCESS_STATUS  =  PROCESS_STATUS + '||G_PS_BAD_ATTR_GRP_ID||'
     WHERE UAI1.DATA_SET_ID = :data_set_id
       AND UAI1.PROCESS_STATUS = '||G_PS_IN_PROCESS||'
       AND ATTR_GROUP_ID IS NOT NULL
       AND NVL(UAI1.ATTR_GROUP_TYPE,:attr_group_type)=:attr_group_type
       AND ATTR_GROUP_ID <> ( SELECT ATTR_GROUP_ID
                                FROM EGO_FND_DSC_FLX_CTX_EXT FLX_EXT
                               WHERE APPLICATION_ID = :application_id
                                 AND DESCRIPTIVE_FLEXFIELD_NAME = :attr_group_type
                                 AND DESCRIPTIVE_FLEX_CONTEXT_CODE = UAI1.ATTR_GROUP_INT_NAME) '
    USING  p_data_set_id, p_attr_group_type, p_attr_group_type, p_application_id, p_attr_group_type ;

    EXECUTE IMMEDIATE
      'UPDATE '||p_interface_table_name||' UAI1
       SET ATTR_GROUP_ID =   (SELECT ATTR_GROUP_ID
                                FROM EGO_FND_DSC_FLX_CTX_EXT FLX_EXT
                               WHERE APPLICATION_ID = :application_id
                                 AND DESCRIPTIVE_FLEXFIELD_NAME = :attr_group_type
                                 AND DESCRIPTIVE_FLEX_CONTEXT_CODE = UAI1.ATTR_GROUP_INT_NAME)
     WHERE UAI1.DATA_SET_ID = :data_set_id
       AND UAI1.PROCESS_STATUS = '||G_PS_IN_PROCESS||'
       AND ATTR_GROUP_ID IS NULL '
    USING p_application_id, p_attr_group_type, p_data_set_id;

    -----------------------------------------------
    -- Update the interface table populating the --
    -- attribute group type for the given data   --
    -----------------------------------------------

    EXECUTE IMMEDIATE
      'UPDATE '||p_interface_table_name||' UAI1
       SET ATTR_GROUP_TYPE = (SELECT DESCRIPTIVE_FLEXFIELD_NAME
                                FROM EGO_FND_DSC_FLX_CTX_EXT FLX_EXT
                               WHERE APPLICATION_ID = :application_id
                                 AND ATTR_GROUP_ID = UAI1.ATTR_GROUP_ID)
     WHERE UAI1.DATA_SET_ID = :data_set_id
       AND UAI1.PROCESS_STATUS = '||G_PS_IN_PROCESS||'
       AND UAI1.ATTR_GROUP_TYPE IS NULL '
    USING p_application_id, p_data_set_id;

  END IF;

    -------------------------------------------------
    -- We would not go any further if we dont have --
    -- any rows to process in this call.           --
    -------------------------------------------------

    BEGIN
      EXECUTE IMMEDIATE ' SELECT DATA_SET_ID FROM '||p_interface_table_name||
                        '  WHERE DATA_SET_ID = :data_set_id
                             AND ROWNUM = 1
                             AND PROCESS_STATUS = '||G_PS_IN_PROCESS||'
                             AND ATTR_GROUP_TYPE = :attr_group_type '
                  INTO l_dummy
                 USING p_data_set_id, p_attr_group_type;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
      ----------------------------------------------
      -- There are no rows in the attr intf table --
      -- lets push off ...                        --
      ----------------------------------------------
        RAISE G_NO_ROWS_IN_INTF_TABLE;
    END;

  -------------------------------------------
  -- The above validations should be there --
  -- for dml mode and validate mode        --
  -------------------------------------------
  IF (p_validate) THEN
    ------------------------------------------------
    -- Mark as errors all logical Attribute Group --
    -- rows for which we cannot find metadata     --
    ------------------------------------------------
    -- Fix for bug#9336604
    -- Added no_unnest hint
    -- Changed bind variable p_data_set_id to literal
    EXECUTE IMMEDIATE
    'UPDATE '||p_interface_table_name||' UAI1
        SET UAI1.PROCESS_STATUS = UAI1.PROCESS_STATUS + '||G_PS_BAD_ATTR_OR_AG_METADATA||'
      WHERE UAI1.DATA_SET_ID = :p_data_set_id
        AND UAI1.PROCESS_STATUS = '||G_PS_IN_PROCESS||'
        AND UAI1.ATTR_GROUP_TYPE = :attr_group_type
        AND UAI1.ROW_IDENTIFIER IN
            (SELECT DISTINCT UAI2.ROW_IDENTIFIER
               FROM '||p_interface_table_name||' UAI2
              WHERE UAI2.DATA_SET_ID = :p_data_set_id
                AND UAI2.PROCESS_STATUS = '||G_PS_IN_PROCESS||'
                AND NOT EXISTS (SELECT /*+ no_unnest */ NULL
                                  FROM EGO_FND_DSC_FLX_CTX_EXT AG,
                                       FND_DESCR_FLEX_COLUMN_USAGES A
                                 WHERE AG.ATTR_GROUP_ID = UAI2.ATTR_GROUP_ID
                                   AND A.DESCRIPTIVE_FLEX_CONTEXT_CODE = AG.DESCRIPTIVE_FLEX_CONTEXT_CODE
                                   AND A.APPLICATION_ID =  :p_application_id
                                   AND A.DESCRIPTIVE_FLEXFIELD_NAME = :p_attr_group_type
                                   AND A.END_USER_COLUMN_NAME = UAI2.ATTR_INT_NAME
                                   AND A.ENABLED_FLAG = ''Y''))'
    USING p_data_set_id, p_attr_group_type, p_data_set_id, p_application_id, p_attr_group_type;

code_debug(' After validations for G_PS_BAD_ATTR_OR_AG_METADATA',1);


/*
DYLAN: I need to check--is the multiple entries validation step required
if intf_U1 is unique?
*/
/*
Gaurav: we dont need this check since we have a unique index
        which wont allow duplicate rows
    ------------------------------------------------------------------
    -- Mark as errors all logical Attribute Group rows that contain --
    -- multiple interface table rows for any single Attribute       --
    ------------------------------------------------------------------
    EXECUTE IMMEDIATE
    'UPDATE '||p_interface_table_name||' UAI1
        SET UAI1.PROCESS_STATUS = UAI1.PROCESS_STATUS + '||G_PS_MULTIPLE_ENTRIES||'
      WHERE UAI1.DATA_SET_ID = :p_data_set_id
        AND UAI1.PROCESS_STATUS = '||G_PS_IN_PROCESS||'
        AND UAI1.ROW_IDENTIFIER IN
            (SELECT ROW_IDENTIFIER
               FROM (SELECT UAI2.ROW_IDENTIFIER
                           ,UAI2.ATTR_INT_NAME
                           ,COUNT(*) NUMBER_OF_ENTRIES
                       FROM '||p_interface_table_name||' UAI2
                      WHERE UAI2.DATA_SET_ID = :p_data_set_id
                        AND UAI2.PROCESS_STATUS = '||G_PS_IN_PROCESS||'
                   GROUP BY UAI2.ROW_IDENTIFIER, UAI2.ATTR_INT_NAME)
              WHERE NUMBER_OF_ENTRIES > 1)'
    USING p_data_set_id, p_data_set_id;
*/

    --------------------------------------------------------------------
    -- Mark as errors all logical Attribute Group rows that contain   --
    -- any interface table rows with multiple values for an Attribute --
    --------------------------------------------------------------------
    EXECUTE IMMEDIATE
    'UPDATE '||p_interface_table_name||' UAI1
        SET UAI1.PROCESS_STATUS = UAI1.PROCESS_STATUS + '||G_PS_MULTIPLE_VALUES||'
      WHERE UAI1.DATA_SET_ID = :p_data_set_id
        AND UAI1.ATTR_GROUP_TYPE = :attr_group_type
        AND UAI1.PROCESS_STATUS = '||G_PS_IN_PROCESS||'
        AND UAI1.ROW_IDENTIFIER IN
            (SELECT /*+ UNNEST HASH_SJ */ DISTINCT UAI2.ROW_IDENTIFIER  /* bug#9678667 Change apr30 */
               FROM '||p_interface_table_name||' UAI2
              WHERE UAI2.DATA_SET_ID = :p_data_set_id
                AND UAI2.PROCESS_STATUS = '||G_PS_IN_PROCESS||'
                AND ((UAI2.ATTR_VALUE_STR IS NOT NULL AND
                      (UAI2.ATTR_VALUE_NUM IS NOT NULL OR
                       UAI2.ATTR_VALUE_DATE IS NOT NULL))
                     OR
                     (UAI2.ATTR_VALUE_NUM IS NOT NULL AND
                      (UAI2.ATTR_VALUE_STR IS NOT NULL OR
                       UAI2.ATTR_VALUE_DATE IS NOT NULL))
                     OR
                     (UAI2.ATTR_VALUE_DATE IS NOT NULL AND
                      (UAI2.ATTR_VALUE_NUM IS NOT NULL OR
                       UAI2.ATTR_VALUE_STR IS NOT NULL))))'
    USING p_data_set_id, p_attr_group_type, p_data_set_id;

    code_debug(' After validations for G_PS_MULTIPLE_VALUES',1);

    ---------------------------------------------------------------------
    -- Mark as errors all logical Attribute Group rows for which there --
    -- is no association of the Attribute Group to any of the related  --
    -- classification codes (as defined by the passed-in query), or    --
    -- for which the logical Attribute Group row is not passed in at   --
    -- the correct data level for the association (e.g., if the object --
    -- is 'EGO_ITEM' and the row is being passed in with a REVISION_ID --
    -- value for an Attribute Group associated at the Item level)      --
    ---------------------------------------------------------------------
    l_dynamic_sql :=
    'UPDATE '||p_interface_table_name||' UAI1
        SET UAI1.PROCESS_STATUS = UAI1.PROCESS_STATUS + '||G_PS_AG_NOT_ASSOCIATED||'
      WHERE UAI1.DATA_SET_ID = :data_set_id
        AND UAI1.ATTR_GROUP_TYPE = :attr_group_type
        AND UAI1.PROCESS_STATUS = '||G_PS_IN_PROCESS||'
        AND UAI1.ROW_IDENTIFIER IN
            (SELECT DISTINCT UAI2.ROW_IDENTIFIER
               FROM '||p_interface_table_name||' UAI2
              WHERE UAI2.DATA_SET_ID = :data_set_id
                -- AND UAI2.DATA_SET_ID = UAI1.DATA_SET_ID -- Commenting for Bug 9336604
                AND UAI2.PROCESS_STATUS = '||G_PS_IN_PROCESS||'
                AND NOT EXISTS (SELECT NULL
                                  FROM EGO_OBJ_AG_ASSOCS_B      A
                                 WHERE A.ATTR_GROUP_ID = UAI2.ATTR_GROUP_ID
                                   AND A.OBJECT_ID =  '||l_object_id||'
                                   AND A.CLASSIFICATION_CODE IN ('||p_related_class_codes_query||')';
--R12C

    IF(l_data_level_col_exists) THEN

      l_dynamic_sql := l_dynamic_sql||' AND NVL(A.DATA_LEVEL_ID,-1) = NVL(UAI2.DATA_LEVEL_ID,-1) ';

      l_dummy := 0;
      FOR i IN l_list_of_dl_for_ag_type.FIRST .. l_list_of_dl_for_ag_type.LAST
      LOOP
        IF (l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME1 IS NOT NULL AND l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME1 <> 'NONE') THEN

          l_dummy := l_dummy+1;
          IF(l_dummy = 1) THEN
            l_dynamic_sql := l_dynamic_sql ||' AND (( ';
          ELSE
            l_dynamic_sql := l_dynamic_sql ||' OR  (  ';
          END IF;
          l_dynamic_sql := l_dynamic_sql || '           UAI2.DATA_LEVEL_ID = '||l_list_of_dl_for_ag_type(i).DATA_LEVEL_ID
                                         || '           AND UAI2.'||l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME1||' IS NOT NULL ';
        ELSE
          l_dummy := l_dummy+1;
          IF(l_dummy = 1) THEN
            l_dynamic_sql := l_dynamic_sql ||' AND (( ';
          ELSE
            l_dynamic_sql := l_dynamic_sql ||' OR  (  ';
          END IF;
            l_dynamic_sql := l_dynamic_sql || '           UAI2.DATA_LEVEL_ID = '||l_list_of_dl_for_ag_type(i).DATA_LEVEL_ID||'  ';

        END IF;

        IF (l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME2 IS NOT NULL AND l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME2 <> 'NONE') THEN
             l_dynamic_sql := l_dynamic_sql || '          AND UAI2.'||l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME2||' IS NOT NULL ';
        END IF;

        IF (l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME3 IS NOT NULL AND l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME3 <> 'NONE') THEN
             l_dynamic_sql := l_dynamic_sql || '          AND UAI2.'||l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME3||' IS NOT NULL ';
        END IF;
        IF (l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME4 IS NOT NULL AND l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME4 <> 'NONE') THEN
             l_dynamic_sql := l_dynamic_sql || '          AND UAI2.'||l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME4||' IS NOT NULL ';
        END IF;
        IF (l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME5 IS NOT NULL AND l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME5 <> 'NONE') THEN
             l_dynamic_sql := l_dynamic_sql || '          AND UAI2.'||l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME5||' IS NOT NULL ';
        END IF;

        --IF (l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME1 IS NOT NULL AND l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME1 <> 'NONE') THEN
           l_dynamic_sql := l_dynamic_sql ||' ) ';
        --END IF;

      END LOOP;

        l_dynamic_sql := l_dynamic_sql ||' ) ';
    END IF;
--R12C end

    IF (l_num_data_level_columns = 1 AND NOT l_data_level_col_exists) THEN
      l_dynamic_sql := l_dynamic_sql||
                       ' AND  ((A.DATA_LEVEL = '''||l_data_level_1||'''
                                    AND UAI2.'||l_data_level_column_1||' IS NOT NULL )
                               OR
                                   (     A.DATA_LEVEL <> '''||l_data_level_1||'''
                                     AND UAI2.'||l_data_level_column_1||' IS NULL) )';

    ELSIF (l_num_data_level_columns = 2 AND NOT l_data_level_col_exists) THEN
      l_dynamic_sql := l_dynamic_sql||
                       ' AND  (   (     A.DATA_LEVEL = '''||l_data_level_2||'''
                                    AND UAI2.'||l_data_level_column_1||' IS NOT NULL
                                    AND UAI2.'||l_data_level_column_2||' IS NOT NULL )
                               OR
                                  (     A.DATA_LEVEL = '''||l_data_level_1||'''
                                    AND UAI2.'||l_data_level_column_1||' IS NOT NULL
                                    AND UAI2.'||l_data_level_column_2||' IS NULL )
                               OR
                                  (     A.DATA_LEVEL <> '''||l_data_level_1||'''
                                    AND A.DATA_LEVEL <> '''||l_data_level_2||'''
                                    AND UAI2.'||l_data_level_column_1||' IS NULL
                                    AND UAI2.'||l_data_level_column_2||' IS NULL ))';

    ELSIF (l_num_data_level_columns = 3 AND NOT l_data_level_col_exists) THEN
      l_dynamic_sql := l_dynamic_sql||

                       ' AND  (   (     A.DATA_LEVEL = '''||l_data_level_3||'''
                                    AND UAI2.'||l_data_level_column_1||' IS NOT NULL
                                    AND UAI2.'||l_data_level_column_2||' IS NOT NULL
                                    AND UAI2.'||l_data_level_column_3||' IS NOT NULL )
                               OR
                                  (     A.DATA_LEVEL = '''||l_data_level_2||'''
                                    AND UAI2.'||l_data_level_column_1||' IS NOT NULL
                                    AND UAI2.'||l_data_level_column_2||' IS NOT NULL
                                    AND UAI2.'||l_data_level_column_3||' IS NULL )
                               OR
                                  (     A.DATA_LEVEL = '''||l_data_level_1||'''
                                    AND UAI2.'||l_data_level_column_1||' IS NOT NULL
                                    AND UAI2.'||l_data_level_column_2||' IS NULL
                                    AND UAI2.'||l_data_level_column_3||' IS NULL )

                               OR
                                  (     A.DATA_LEVEL <> '''||l_data_level_1||'''
                                    AND A.DATA_LEVEL <> '''||l_data_level_2||'''
                                    AND A.DATA_LEVEL <> '''||l_data_level_3||'''
                                    AND UAI2.'||l_data_level_column_1||' IS NULL
                                    AND UAI2.'||l_data_level_column_2||' IS NULL
                                    AND UAI2.'||l_data_level_column_3||' IS NULL ))';

    END IF;
    IF(l_data_level_col_exists) THEN
      l_dynamic_sql := l_dynamic_sql||'))';
    ELSE
      l_dynamic_sql := l_dynamic_sql||'))';
    END IF;
    code_debug('before the assoc chk sql');
    code_debug(l_dynamic_sql);

    EXECUTE IMMEDIATE l_dynamic_sql
    USING p_data_set_id, p_attr_group_type, p_data_set_id;

    code_debug(' After validations for G_PS_AG_NOT_ASSOCIATED',1);
    code_debug(' The sql for validation for G_PS_AG_NOT_ASSOCIATED sql is :'||l_dynamic_sql,3);
    ---------------------------------------------------------------------
    -- Mark the rows having inappropriate non-SYNC transaction_types   --
    -- for that attr grp in the destination table as errored           --
    -- In the TRANSACTION_TYPE processing we assume that for multi-row --
    -- attr grps the user has provided all the necessary UK's and the  --
    -- user cannot update the UK values                                --
    ---------------------------------------------------------------------

    -- Bug 9336604 : Start - Commenting the below code
    /*
    l_dynamic_sql :=
    ' UPDATE '||p_interface_table_name||' UAI1
         SET UAI1.PROCESS_STATUS = PROCESS_STATUS +
                                   DECODE(UAI1.TRANSACTION_TYPE,
                                          '''||EGO_USER_ATTRS_DATA_PVT.G_CREATE_MODE||''', '||G_PS_BAD_TTYPE_CREATE||',
                                          '''||EGO_USER_ATTRS_DATA_PVT.G_UPDATE_MODE||''', '||G_PS_BAD_TTYPE_UPDATE||',
                                          '''||EGO_USER_ATTRS_DATA_PVT.G_DELETE_MODE||''', '||G_PS_BAD_TTYPE_DELETE||')
       WHERE UAI1.DATA_SET_ID = :data_set_id
         AND UAI1.ATTR_GROUP_TYPE = :attr_group_type
         AND UAI1.PROCESS_STATUS = '||G_PS_IN_PROCESS||'
         AND UAI1.TRANSACTION_TYPE <> '''||EGO_USER_ATTRS_DATA_PVT.G_SYNC_MODE||'''
         AND (SELECT MULTI_ROW FROM EGO_FND_DSC_FLX_CTX_EXT FLX_EXT
              WHERE DESCRIPTIVE_FLEX_CONTEXT_CODE = UAI1.ATTR_GROUP_INT_NAME
                AND APPLICATION_ID = '||p_application_id||'
                AND DESCRIPTIVE_FLEXFIELD_NAME = '''||p_attr_group_type||''') <> ''Y''
     AND UAI1.ROW_IDENTIFIER IN (
             SELECT DISTINCT UAI2.ROW_IDENTIFIER
               FROM '||p_interface_table_name||' UAI2
              WHERE UAI2.DATA_SET_ID = :data_set_id
                AND UAI2.PROCESS_STATUS = '||G_PS_IN_PROCESS;

    */ -- Bug 9336604 : End

    l_ext_table_select :=
    '(SELECT COUNT(*)
        FROM '||l_ext_vl_name||'
       WHERE ATTR_GROUP_ID = UAI2.ATTR_GROUP_ID
         AND ROWNUM < 2 ';

    l_ext_table_select := l_ext_table_select ||l_concat_pk_cols_UAI2;

    /*
    IF (l_pk1_column_name IS NOT NULL) THEN
      l_ext_table_select := l_ext_table_select || ' AND '||l_pk1_column_name||' = UAI2.'||l_pk1_column_name;
    END IF;
    IF (l_pk2_column_name IS NOT NULL) THEN
      l_ext_table_select := l_ext_table_select || ' AND '||l_pk2_column_name||' = UAI2.'||l_pk2_column_name;
    END IF;
    IF (l_pk3_column_name IS NOT NULL) THEN
      l_ext_table_select := l_ext_table_select || ' AND '||l_pk3_column_name||' = UAI2.'||l_pk3_column_name;
    END IF;
    IF (l_pk4_column_name IS NOT NULL) THEN
      l_ext_table_select := l_ext_table_select || ' AND '||l_pk4_column_name||' = UAI2.'||l_pk4_column_name;
    END IF;
    IF (l_pk5_column_name IS NOT NULL) THEN
      l_ext_table_select := l_ext_table_select || ' AND '||l_pk5_column_name||' = UAI2.'||l_pk5_column_name;
    END IF;

    --add dl check to the sql
--R12C
    IF(l_data_level_col_exists) THEN

      l_ext_table_select := l_ext_table_select||' AND NVL(DATA_LEVEL_ID,-1) = NVL(UAI2.DATA_LEVEL_ID,-1) ';
      l_dummy := 0;
      FOR i IN l_list_of_dl_for_ag_type.FIRST .. l_list_of_dl_for_ag_type.LAST
      LOOP
        IF (l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME1 IS NOT NULL AND l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME1 <> 'NONE') THEN
          l_dummy := l_dummy+1;
          IF(l_dummy = 1) THEN
            l_ext_table_select := l_ext_table_select ||' AND (( ';
          ELSE
          l_ext_table_select := l_ext_table_select ||' OR  (  ';
          END IF;
          l_ext_table_select := l_ext_table_select || '           UAI2.DATA_LEVEL_ID = '||l_list_of_dl_for_ag_type(i).DATA_LEVEL_ID
                                           || '          AND '||l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME1||' = UAI2.'||l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME1;
        END IF;

        IF (l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME2 IS NOT NULL AND l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME2 <> 'NONE') THEN
             l_ext_table_select := l_ext_table_select || '          AND '||l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME2||' = UAI2.'||l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME2;
        END IF;

        IF (l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME3 IS NOT NULL AND l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME3 <> 'NONE') THEN
             l_ext_table_select := l_ext_table_select ||'           AND '||l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME3||' = UAI2.'||l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME3;
        END IF;
        IF (l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME4 IS NOT NULL AND l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME4 <> 'NONE') THEN
             l_ext_table_select := l_ext_table_select || '          AND '||l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME4||' = UAI2.'||l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME4;
        END IF;
        IF (l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME5 IS NOT NULL AND l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME5 <> 'NONE') THEN
             l_ext_table_select := l_ext_table_select || '          AND '||l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME5||' = UAI2.'||l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME5;
        END IF;

        IF (l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME1 IS NOT NULL AND l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME1 <> 'NONE') THEN
           l_ext_table_select := l_ext_table_select ||' ) ';
        END IF;
      END LOOP;
      l_ext_table_select := l_ext_table_select ||' ) ';
      --R12C end
    ELSE

      IF (l_num_data_level_columns = 1) THEN
        l_ext_table_select := l_ext_table_select || ' AND NVL('||l_data_level_column_1||',-1) = NVL(UAI2.'||l_data_level_column_1||',-1 )';

      ELSIF (l_num_data_level_columns = 2) THEN
        l_ext_table_select := l_ext_table_select || ' AND NVL('||l_data_level_column_1||',-1) = NVL(UAI2.'||l_data_level_column_1||',-1 )';
        l_ext_table_select := l_ext_table_select || ' AND NVL('||l_data_level_column_2||',-1) = NVL(UAI2.'||l_data_level_column_2||',-1 )';

      ELSIF (l_num_data_level_columns = 3) THEN
        l_ext_table_select := l_ext_table_select || ' AND NVL('||l_data_level_column_1||',-1) = NVL(UAI2.'||l_data_level_column_1||',-1 )';
        l_ext_table_select := l_ext_table_select || ' AND NVL('||l_data_level_column_2||',-1) = NVL(UAI2.'||l_data_level_column_2||',-1 )';
        l_ext_table_select := l_ext_table_select || ' AND NVL('||l_data_level_column_3||',-1) = NVL(UAI2.'||l_data_level_column_3||',-1 )';
      END IF;
    END IF; --l_data_level_col_exists
    */
    l_ext_table_select := l_ext_table_select||')';

    -- Bug 9336604 : Start
    l_dynamic_sql :=
    'DECLARE
      l_row_ids   dbms_sql.number_table;
      BEGIN
        SELECT DISTINCT UAI2.ROW_IDENTIFIER
        BULK COLLECT INTO l_row_ids
      FROM '||p_interface_table_name||' UAI2
      WHERE UAI2.DATA_SET_ID = :data_set_id
        AND UAI2.PROCESS_STATUS = '||G_PS_IN_PROCESS||'
        AND '||l_ext_table_select||'
                  = DECODE(UAI2.TRANSACTION_TYPE,
                          '''||EGO_USER_ATTRS_DATA_PVT.G_CREATE_MODE||''', 1,
                          '''||EGO_USER_ATTRS_DATA_PVT.G_UPDATE_MODE||''', 0,
                          '''||EGO_USER_ATTRS_DATA_PVT.G_DELETE_MODE||''', 0); '||
      '
      IF (l_row_ids.Count > 0) THEN
        FORALL i in l_row_ids.FIRST .. l_row_ids.LAST
          UPDATE '||p_interface_table_name||' UAI1
            SET UAI1.PROCESS_STATUS = PROCESS_STATUS +
                                    DECODE(UAI1.TRANSACTION_TYPE,
                                            '''||EGO_USER_ATTRS_DATA_PVT.G_CREATE_MODE||''', '||G_PS_BAD_TTYPE_CREATE||',
                                            '''||EGO_USER_ATTRS_DATA_PVT.G_UPDATE_MODE||''', '||G_PS_BAD_TTYPE_UPDATE||',
                                            '''||EGO_USER_ATTRS_DATA_PVT.G_DELETE_MODE||''', '||G_PS_BAD_TTYPE_DELETE||')
          WHERE UAI1.DATA_SET_ID = '||p_data_set_id||'
            AND UAI1.ATTR_GROUP_TYPE = '''||p_attr_group_type||'''
            AND UAI1.PROCESS_STATUS = '||G_PS_IN_PROCESS||'
            AND UAI1.TRANSACTION_TYPE <> '''||EGO_USER_ATTRS_DATA_PVT.G_SYNC_MODE||'''
            AND (SELECT MULTI_ROW FROM EGO_FND_DSC_FLX_CTX_EXT FLX_EXT
                WHERE DESCRIPTIVE_FLEX_CONTEXT_CODE = UAI1.ATTR_GROUP_INT_NAME
                  AND APPLICATION_ID = '||p_application_id||'
                  AND DESCRIPTIVE_FLEXFIELD_NAME = '''||p_attr_group_type||''') <> ''Y''
          AND UAI1.ROW_IDENTIFIER = l_row_ids(i);
      END IF;
    END;';
    -- Bug 9336604 : End

    -- Bug 9336604 : Start - Commenting
    /*
    l_dynamic_sql := l_dynamic_sql||' AND '||l_ext_table_select||
                     ' = DECODE(UAI2.TRANSACTION_TYPE,
                         '''||EGO_USER_ATTRS_DATA_PVT.G_CREATE_MODE||''', 1,
                         '''||EGO_USER_ATTRS_DATA_PVT.G_UPDATE_MODE||''', 0,
                         '''||EGO_USER_ATTRS_DATA_PVT.G_DELETE_MODE||''', 0))';
    */
    -- Bug 9336604 : End - Commenting

    --------------------------------------------------------------------------
    -- We do the transaction_type validation only for user defined attributes,
    -- for developer defined attributes the trans type is updated to UPDATE
    -- and a dummy row is created in the production table before doing the DML.
    -- i.e., if l_ag_id_col_exists is FALSE
    -- For all developer defined attr rows the transaction type is updated to
    -- UPDATE.
    --------------------------------------------------------------------------
    IF (l_ag_id_col_exists) THEN

      -- Bug 9336604 : Start
      code_debug(l_dynamic_sql);
      EXECUTE IMMEDIATE l_dynamic_sql
      USING p_data_set_id;/*Fix for bug#9678667. Literal to bind*/
      -- Bug 9336604 : End

      -- Bug 9336604 : Start - Commenting
      /*
      code_debug(l_dynamic_sql);

      EXECUTE IMMEDIATE l_dynamic_sql
      USING p_data_set_id, p_attr_group_type, p_data_set_id;
      */
      -- Bug 9336604 : End - Commenting

      code_debug(' After validating the transaction type for Single Row AGs ',1);
      code_debug(' The sql for validating transaction type for SR AGs is :'||l_dynamic_sql,3);

    ELSE

     l_dynamic_sql :=
    ' UPDATE '||p_interface_table_name||' UAI1
         SET UAI1.PROCESS_STATUS = PROCESS_STATUS +
                                   DECODE(UAI1.TRANSACTION_TYPE,
                                          '''||EGO_USER_ATTRS_DATA_PVT.G_UPDATE_MODE||''', '||G_PS_BAD_TTYPE_UPDATE||',
                                          '''||EGO_USER_ATTRS_DATA_PVT.G_DELETE_MODE||''', '||G_PS_BAD_TTYPE_DELETE||')
       WHERE UAI1.DATA_SET_ID = :data_set_id
         AND UAI1.ATTR_GROUP_TYPE = :attr_group_type
         AND UAI1.PROCESS_STATUS = '||G_PS_IN_PROCESS||'
         AND UAI1.TRANSACTION_TYPE <> '''||EGO_USER_ATTRS_DATA_PVT.G_SYNC_MODE||'''
         AND UAI1.TRANSACTION_TYPE <> '''||EGO_USER_ATTRS_DATA_PVT.G_CREATE_MODE||'''
         AND (SELECT MULTI_ROW FROM EGO_FND_DSC_FLX_CTX_EXT FLX_EXT
              WHERE DESCRIPTIVE_FLEX_CONTEXT_CODE = UAI1.ATTR_GROUP_INT_NAME
                AND APPLICATION_ID = '||p_application_id||'
                AND DESCRIPTIVE_FLEXFIELD_NAME = :attr_group_type) <> ''Y''
         AND UAI1.ROW_IDENTIFIER IN (
             SELECT DISTINCT UAI2.ROW_IDENTIFIER
               FROM '||p_interface_table_name||' UAI2
              WHERE UAI2.DATA_SET_ID = :data_set_id
                AND UAI2.PROCESS_STATUS = '||G_PS_IN_PROCESS||'
                AND (SELECT COUNT(*) FROM '|| l_ext_vl_name||'
                                    WHERE 1=1 '||l_concat_pk_cols_UAI2||'
                                      AND ROWNUM <2 ) =  DECODE(UAI2.TRANSACTION_TYPE,
                                                           '''||EGO_USER_ATTRS_DATA_PVT.G_UPDATE_MODE||''', 0,
                                                           '''||EGO_USER_ATTRS_DATA_PVT.G_DELETE_MODE||''', 0)
                                    )';
      EXECUTE IMMEDIATE l_dynamic_sql
      USING p_data_Set_id, p_attr_group_type, p_attr_group_type, p_data_Set_id ;

    END IF;

/*
DYLAN: is there a reason we need to do this SYNC -> CREATE/UPDATE switch
here rather than after our initial validation loop?  If we did it there,
we could use UKs and go for SR and MR all together.  Let's talk about
this.
*/
    -------------------------------------------------------
    -- Update the transaction type column for single-row --
    -- Attr Group rows from SYNC to UPDATE or CREATE     --
    -------------------------------------------------------

    /* Bug 13414358 - Start */
    -- Modifed the query to use exists caluse for performance bug 13414358.
    l_ext_table_select1 :=
    '(SELECT 1
        FROM '||l_ext_b_table_name||'
       WHERE ATTR_GROUP_ID = UAI2.ATTR_GROUP_ID
         AND ROWNUM < 2 ';

    l_ext_table_select1 := l_ext_table_select1 ||l_concat_pk_cols_UAI2;
    l_ext_table_select1 := l_ext_table_select1||')';
    /* Bug 13414358 - End */

    IF (l_ag_id_col_exists) THEN

      l_dynamic_sql :=
      /* Bug 13414358 - Bug commenting the below query and modifying as below */
      /*
      ' UPDATE '||p_interface_table_name||' UAI2
          SET UAI2.TRANSACTION_TYPE = DECODE('||l_ext_table_select||
                                             ',0,'''||
                                             EGO_USER_ATTRS_DATA_PVT.G_CREATE_MODE||''','''||
                                             EGO_USER_ATTRS_DATA_PVT.G_UPDATE_MODE||''')
        WHERE UAI2.DATA_SET_ID = :data_set_id
          AND UAI2.ATTR_GROUP_TYPE = :attr_group_type
          AND UAI2.PROCESS_STATUS = '||G_PS_IN_PROCESS||'
          AND UAI2.TRANSACTION_TYPE = '''||EGO_USER_ATTRS_DATA_PVT.G_SYNC_MODE||'''
          AND (SELECT MULTI_ROW FROM EGO_FND_DSC_FLX_CTX_EXT FLX_EXT
                WHERE DESCRIPTIVE_FLEX_CONTEXT_CODE = UAI2.ATTR_GROUP_INT_NAME
                  AND APPLICATION_ID = :application_id
                  AND DESCRIPTIVE_FLEXFIELD_NAME = :attr_group_type) <> ''Y'' ';
      */ -- Tesco - Bug Commenting Done

      /* Bug 13414358 - Start */
      ' UPDATE '||p_interface_table_name||' UAI2
          SET UAI2.TRANSACTION_TYPE = Nvl(( SELECT '''||EGO_USER_ATTRS_DATA_PVT.G_UPDATE_MODE||'''
                                            FROM   DUAL
                                            WHERE EXISTS '||l_ext_table_select1||
                                           '), '''||EGO_USER_ATTRS_DATA_PVT.G_CREATE_MODE||''')
        WHERE UAI2.DATA_SET_ID = :data_set_id
          AND UAI2.ATTR_GROUP_TYPE = :attr_group_type
          AND UAI2.PROCESS_STATUS = '||G_PS_IN_PROCESS||'
          AND UAI2.TRANSACTION_TYPE = '''||EGO_USER_ATTRS_DATA_PVT.G_SYNC_MODE||'''
          AND (SELECT MULTI_ROW FROM EGO_FND_DSC_FLX_CTX_EXT FLX_EXT
                WHERE DESCRIPTIVE_FLEX_CONTEXT_CODE = UAI2.ATTR_GROUP_INT_NAME
                  AND APPLICATION_ID = :application_id
                  AND DESCRIPTIVE_FLEXFIELD_NAME = :attr_group_type) <> ''Y'' ';
      /* Bug 13414358 - End */

      --ER 9489112, do not convert SYNC to CREATE/UPDATE for item rev level Single Row UDA when change order be created
      --Current UDA chanage be put in change order controll since rev level UDA will defaulted from
      --current revision when new revision created in java code. For this case, rev level UDA defauled when the new revision
      --is created by change Service ChangeImportManager.createItemRevChangeMethodRequests.
      IF  l_data_level_col_exists  AND l_add_all_to_cm = 'Y' THEN
        l_dynamic_sql := l_dynamic_sql || ' AND NVL(UAI2.DATA_LEVEL_ID,'||G_NULL_TOKEN_NUM||') <> ' ||l_item_rev_dl_id ;
      END IF;
    ELSE

      l_dynamic_sql :=
      ' UPDATE '||p_interface_table_name||' UAI2
          SET UAI2.TRANSACTION_TYPE = DECODE((SELECT COUNT(*) FROM '|| l_ext_vl_name ||' WHERE 1=1 '||l_concat_pk_cols_UAI2||' AND ROWNUM<2 )'||
                                             ',0,'''||
                                             EGO_USER_ATTRS_DATA_PVT.G_CREATE_MODE||''','''||
                                             EGO_USER_ATTRS_DATA_PVT.G_UPDATE_MODE||''')
        WHERE UAI2.DATA_SET_ID = :data_set_id
          AND UAI2.ATTR_GROUP_TYPE = :attr_group_type
          AND UAI2.PROCESS_STATUS = '||G_PS_IN_PROCESS||'
          AND UAI2.TRANSACTION_TYPE = '''||EGO_USER_ATTRS_DATA_PVT.G_SYNC_MODE||'''
          AND (SELECT MULTI_ROW FROM EGO_FND_DSC_FLX_CTX_EXT FLX_EXT
                WHERE DESCRIPTIVE_FLEX_CONTEXT_CODE = UAI2.ATTR_GROUP_INT_NAME
                  AND APPLICATION_ID = :application_id
                  AND DESCRIPTIVE_FLEXFIELD_NAME = :attr_group_type) <> ''Y'' ';

    END IF;
    code_debug(' After updating the transaction type for Single Row AGs ');
    code_debug(l_dynamic_sql);
   EXECUTE IMMEDIATE l_dynamic_sql
    USING p_data_set_id, p_attr_group_type, p_application_id, p_attr_group_type;
    l_dynamic_sql := ' ';

    code_debug(' After updating the transaction type for Single Row AGs ',1);
    code_debug(' The sql for updating transaction type for SR AGs is :'||l_dynamic_sql,3);

    -------------------------------------------------------------------------
    -- Update other attributes if at least one attribute is failed for
    -- all attr group
    -------------------------------------------------------------------------
     -- considering the G_PS_BAD_ATTR_OR_AG_METADATA is the starting point
     -- for the intermittent errors.

     /* Fix for bug#9678667 - Start */
     /*
      EXECUTE IMMEDIATE
            'UPDATE '||p_interface_table_name||' UAI1' ||
                ' SET UAI1.PROCESS_STATUS = UAI1.PROCESS_STATUS + '||G_PS_OTHER_ATTRS_INVALID||
                ' WHERE UAI1.DATA_SET_ID = '||p_data_set_id||
                ' AND BITAND(PROCESS_STATUS,'||G_PS_OTHER_ATTRS_INVALID||') = 0'||
                ' AND UAI1.ROW_IDENTIFIER  IN'||
                '     (SELECT DISTINCT UAI2.ROW_IDENTIFIER'||
                '        FROM '||p_interface_table_name||' UAI2'||
                '        WHERE UAI2.DATA_SET_ID = '||p_data_set_id||
                '         AND UAI2.PROCESS_STATUS >= '||G_PS_BAD_ATTR_OR_AG_METADATA ||
                '         AND UAI2.ATTR_GROUP_INT_NAME = UAI1.ATTR_GROUP_INT_NAME)';
      */

      EXECUTE IMMEDIATE
            'UPDATE '||p_interface_table_name||' UAI1' ||
                ' SET UAI1.PROCESS_STATUS = UAI1.PROCESS_STATUS + '||G_PS_OTHER_ATTRS_INVALID||
                ' WHERE UAI1.DATA_SET_ID = :data_set_id '||
                ' AND BITAND(PROCESS_STATUS,'||G_PS_OTHER_ATTRS_INVALID||') = 0'||
                ' AND (UAI1.ROW_IDENTIFIER, UAI1.ATTR_GROUP_INT_NAME)  IN '||
                '       (SELECT /*+ UNNEST CARDINALITY(UAI2,10) INDEX(UAI2,EGO_ITM_USR_ATTR_INTRFC_N3) */ '|| /* Bug 9678667 */
                '           UAI2.ROW_IDENTIFIER, UAI2.ATTR_GROUP_INT_NAME '||
                '        FROM '||p_interface_table_name||' UAI2'||
                '        WHERE UAI2.DATA_SET_ID = :data_set_id '||
                '           AND UAI2.PROCESS_STATUS >= '||G_PS_BAD_ATTR_OR_AG_METADATA ||
                '      )'
      USING p_data_set_id, p_data_set_id;
      /* Fix for bug#9678667 - End */



                 --=============================--
                 -- ERRORING OUT OF FAILED ROWS --
                 --=============================--

    OPEN l_dynamic_dist_ag_cursor FOR
        ' SELECT /*+ use_concat index(UAI1,EGO_ITM_USR_ATTR_INTRFC_N3) */ /* Bug 9678667 */
            DISTINCT ATTR_GROUP_INT_NAME
            FROM '||p_interface_table_name||' UAI1
           WHERE DATA_SET_ID = :data_set_id
             AND (UAI1.PROCESS_STATUS < '||G_PS_IN_PROCESS||' OR UAI1.PROCESS_STATUS > '||G_PS_IN_PROCESS||')'  /* Bug 9678667 */
    USING p_data_set_id;
    LOOP
      FETCH l_dynamic_dist_ag_cursor INTO l_attr_group_intf_rec;
      EXIT WHEN l_dynamic_dist_ag_cursor%NOTFOUND;

      l_attr_group_metadata_obj := EGO_USER_ATTRS_COMMON_PVT.Get_Attr_Group_Metadata(
                                     p_attr_group_id   => NULL
                                    ,p_application_id  => p_application_id
                                    ,p_attr_group_type => p_attr_group_type
                                    ,p_attr_group_name => l_attr_group_intf_rec.ATTR_GROUP_INT_NAME
                                   );

      ----------------------------------------------------
      -- reporting of errors for all failed rows belonging
      -- to this attr grp.
      ----------------------------------------------------
      Log_Errors_Now(
        p_entity_id               => p_entity_id
       ,p_entity_index            => p_entity_index
       ,p_entity_code             => p_entity_code
       ,p_object_name             => p_object_name
       ,p_pk1_column_name         => l_pk1_column_name
       ,p_pk2_column_name         => l_pk2_column_name
       ,p_pk3_column_name         => l_pk3_column_name
       ,p_pk4_column_name         => l_pk4_column_name
       ,p_pk5_column_name         => l_pk5_column_name
       ,p_classification_col_name => l_class_code_column_name
       ,p_interface_table_name    => p_interface_table_name
       ,p_err_col_static_sql      => l_err_col_static_sql
       ,p_err_where_static_sql    => l_err_where_static_sql
       ,p_attr_grp_meta_obj       => l_attr_group_metadata_obj
       ,p_data_set_id             => p_data_set_id /*Fix for bug#9678667. Literal to bind*/
      );

    END LOOP;
    -- Bug : 4099546
    CLOSE l_dynamic_dist_ag_cursor;
    --------------------------------------------------
    -- MARKING ALL THE ROWS AS 3 WHICH HAVE ERRORED --
    --------------------------------------------------
    --considering the G_PS_BAD_ATTR_OR_AG_METADATA is the starting point for the intermittent errors.
    l_dynamic_sql :=
        'UPDATE /*+ INDEX(UAI1,EGO_ITM_USR_ATTR_INTRFC_N3) */ '||p_interface_table_name||' UAI1 '||
 /* Bug 9678667 */
        ' SET UAI1.PROCESS_STATUS =  '||G_PS_GENERIC_ERROR||
        ' WHERE UAI1.DATA_SET_ID = :data_set_id '||--p_data_set_id||
        ' AND UAI1.ROW_IDENTIFIER  IN '||
        '         (SELECT DISTINCT UAI2.ROW_IDENTIFIER'||
        '            FROM '||p_interface_table_name||' UAI2 '||
        '        WHERE UAI2.DATA_SET_ID = :data_set_id '||--p_data_set_id||
        '        AND UAI2.PROCESS_STATUS >= '||G_PS_BAD_ATTR_OR_AG_METADATA ||')';
    EXECUTE IMMEDIATE l_dynamic_sql
      USING p_data_set_id, p_data_set_id;/*Fix for bug#9678667. Literal to bind*/

    code_debug(' After error reporting and status updation of rows failed till now and before entering the attr levle validation loop',1);

  END IF; --*p_validate-IF-1*   Ending the IF for p_validate
                 --=============================--
                 -- ATTR-LEVEL LOOP VALIDATIONS --
                 --=============================--

    ----------------------------------------------------------------
    -- We will perform subsequent validations on a per-Attribute  --
    -- basis, so we open a dynamic cursor to process all still-   --
    -- valid lines in the data set; this cursor will have as many --
    -- rows as there are distinct Attributes in the data set      --
    ----------------------------------------------------------------
    -- Fix for bug#9336604
    -- Changed the index hint
    --bug 13873323, improve performance
    OPEN l_dynamic_cursor FOR
    'SELECT -- /*+ LEADING(A, EXT, UOM, FLX_EXT, DISTINCT_ATTRS,AG_DL) INDEX(FLX_EXT EGO_FND_DSC_FLX_CTX_EXT_U2) INDEX(a  FND_DESCR_FLEX_COL_USAGES_U2) USE_HASH(DISTINCT_ATTRS)*/
            -- /*+ LEADING(DISTINCT_ATTRS, FLX_EXT, A, EXT) */
      EXT.ATTR_ID,
            FLX_EXT.ATTR_GROUP_ID,
            DISTINCT_ATTRS.ATTR_GROUP_INT_NAME,
            FLX_EXT.MULTI_ROW              MULTI_ROW_CODE,
            A.END_USER_COLUMN_NAME         ATTR_INT_NAME,
            EXT.DATA_TYPE,
            EXT.UNIQUE_KEY_FLAG,
            A.DEFAULT_VALUE,
            VS.MAXIMUM_SIZE,
            A.REQUIRED_FLAG,
            VS.FLEX_VALUE_SET_ID VALUE_SET_ID,
            VS.VALIDATION_TYPE,
            VS.MINIMUM_VALUE,
            VS.MAXIMUM_VALUE,
            UOM.UOM_CODE,
            UOM.UOM_CLASS,
            DISTINCT_ATTRS.DATA_LEVEL_ID,
            FNV.FUNCTION_NAME              VIEW_PRIVILEGE,
            FNE.FUNCTION_NAME              EDIT_PRIVILEGE
       FROM (SELECT /*+ NO_MERGE */
                DISTINCT ATTR_GROUP_INT_NAME, ATTR_GROUP_ID
                            ,ATTR_INT_NAME
                            ,DATA_LEVEL_ID
               FROM '||p_interface_table_name||'
              WHERE DATA_SET_ID = :data_set_id
                    AND ATTR_GROUP_TYPE = :attr_group_type
                    AND PROCESS_STATUS = '||G_PS_IN_PROCESS||') DISTINCT_ATTRS,
      EGO_FND_DSC_FLX_CTX_EXT        FLX_EXT,
            (SELECT application_id, descriptive_flexfield_name, descriptive_flex_context_code,
                 application_column_name, end_user_column_name, DEFAULT_VALUE,
                 required_flag, flex_value_set_id, column_seq_num
            FROM fnd_descr_flex_column_usages
           WHERE ''Y'' = enabled_flag
                 AND application_id IN (SELECT DISTINCT application_id
                                          FROM ego_fnd_dsc_flx_ctx_ext)) a,
            EGO_FND_DF_COL_USGS_EXT        EXT,
            EGO_ATTR_GROUP_DL              AG_DL,
            FND_FLEX_VALUE_SETS            VS,
            MTL_UNITS_OF_MEASURE           UOM,
            FND_FORM_FUNCTIONS             FNV,
            FND_FORM_FUNCTIONS             FNE
      WHERE DISTINCT_ATTRS.ATTR_GROUP_ID = FLX_EXT.ATTR_GROUP_ID
      AND flx_ext.application_id = ext.application_id
      AND flx_ext.descriptive_flexfield_name = ext.descriptive_flexfield_name
      AND flx_ext.descriptive_flex_context_code = ext.descriptive_flex_context_code
      --AND ''Y'' = a.enabled_flag
      AND a.application_id = flx_ext.application_id
      AND a.descriptive_flexfield_name = flx_ext.descriptive_flexfield_name
      AND a.descriptive_flex_context_code = flx_ext.descriptive_flex_context_code
      AND a.application_column_name = ext.application_column_name
      AND a.end_user_column_name = distinct_attrs.attr_int_name
      AND A.FLEX_VALUE_SET_ID = VS.FLEX_VALUE_SET_ID(+)
      AND EXT.UOM_CLASS = UOM.UOM_CLASS(+)
      AND ''Y'' = UOM.BASE_UOM_FLAG(+)
      AND AG_DL.ATTR_GROUP_ID = FLX_EXT.ATTR_GROUP_ID
      AND AG_DL.DATA_LEVEL_ID = DISTINCT_ATTRS.DATA_LEVEL_ID
      AND AG_DL.VIEW_PRIVILEGE_ID = FNV.FUNCTION_ID(+)
      AND AG_DL.EDIT_PRIVILEGE_ID = FNE.FUNCTION_ID(+)
      ORDER BY FLX_EXT.ATTR_GROUP_ID, A.COLUMN_SEQ_NUM'
    USING p_data_set_id, p_attr_group_type;

    -- Fix for bug#9336604
    --LOOP
    --  FETCH l_dynamic_cursor INTO l_attr_metadata_rec;
    --  EXIT WHEN l_dynamic_cursor%NOTFOUND;
    FETCH l_dynamic_cursor BULK COLLECT INTO l_attr_metadata_rec;
    CLOSE l_dynamic_cursor;

    FOR l_var IN l_attr_metadata_rec.FIRST .. l_attr_metadata_rec.LAST
    LOOP

      code_debug('---------Inside the ATTR-LEVEL Validation loop: processing the attribute '||l_attr_metadata_rec(l_var).ATTR_INT_NAME||' in attribute group '||l_attr_metadata_rec(l_var).ATTR_GROUP_INT_NAME,2);

      ------------------------------------------------------------
      -- First, we add this Attribute to our list of distinct   --
      -- Attributes in the data set for use in later processing --
      ------------------------------------------------------------
      l_dist_attr_in_data_set_rec.ATTR_GROUP_ID :=
        l_attr_metadata_rec(l_var).ATTR_GROUP_ID;
      l_dist_attr_in_data_set_rec.ATTR_INT_NAME :=
        l_attr_metadata_rec(l_var).ATTR_INT_NAME;
      l_dist_attr_in_data_set_rec.ATTR_GROUP_INT_NAME :=
        l_attr_metadata_rec(l_var).ATTR_GROUP_INT_NAME;
      l_dist_attrs_in_data_set_table(l_dist_attrs_in_data_set_table.COUNT+1) :=
        l_dist_attr_in_data_set_rec;

      ------------------------------------------------------
      -- We do all the validations only if p_validate has --
      -- been passed as true to the API                   --
      ------------------------------------------------------
      IF (p_validate) THEN -- search for --*p_validate-IF-1.5*

        ------------------------------------------------
        -- We only want to check privileges for each  --
        -- Attribute Group when we first encounter it --
        ------------------------------------------------
        IF (l_prev_ag_id_priv IS NULL OR
            l_prev_ag_id_priv <> (l_attr_metadata_rec(l_var).ATTR_GROUP_ID||l_attr_metadata_rec(l_var).VIEW_PRIVILEGE||l_attr_metadata_rec(l_var).EDIT_PRIVILEGE)) THEN

          -------------------------------------------------------------
          -- We update this so that the check above won't pass again --
          -- until we begin processing for another attribute group   --
          -------------------------------------------------------------
          l_prev_ag_id_priv := l_attr_metadata_rec(l_var).ATTR_GROUP_ID||l_attr_metadata_rec(l_var).VIEW_PRIVILEGE||l_attr_metadata_rec(l_var).EDIT_PRIVILEGE;

          ---------------------------------------------------------
          -- If the caller passed a predicate API name, we will  --
          -- mark as errors all logical Attribute Group rows for --
          -- which the user does not have sufficient privileges  --
          ---------------------------------------------------------
          IF (p_privilege_predicate_api_name IS NOT NULL) THEN
            --Bug NO :6433569 start
      --Getting the view privilege corresponding to the data level Id, if tha array is not null
            IF ( p_default_dl_view_priv_list IS NOT NULL AND p_default_dl_view_priv_list.COUNT <>0) THEN
        FOR i IN 1 .. p_default_dl_view_priv_list.COUNT
        LOOP
          IF (p_default_dl_view_priv_list(i).NAME = l_attr_metadata_rec(l_var).DATA_LEVEL_ID)  THEN
            l_view_priv_to_check := NVL(l_attr_metadata_rec(l_var).VIEW_PRIVILEGE, p_default_dl_view_priv_list(i).VALUE);
          END IF;
        END LOOP;
      ELSE -- if the array is null or count is 0 then take the passed in view privilege.
              l_view_priv_to_check := NVL(l_attr_metadata_rec(l_var).VIEW_PRIVILEGE, p_default_view_privilege);
            END IF;

            --Getting the edit privilege corresponding to the data level Id, if tha array is not null
            IF ( p_default_dl_edit_priv_list IS NOT NULL AND p_default_dl_edit_priv_list.COUNT <>0) THEN
       FOR i IN 1 .. p_default_dl_edit_priv_list.COUNT
       LOOP
         IF (p_default_dl_edit_priv_list(i).NAME = l_attr_metadata_rec(l_var).DATA_LEVEL_ID)  THEN
           l_edit_priv_to_check := NVL(l_attr_metadata_rec(l_var).EDIT_PRIVILEGE, p_default_dl_edit_priv_list(i).VALUE);
         END IF;
       END LOOP;
      ELSE -- if the array is null or count is 0 then take the passed in edit privilege.
              l_edit_priv_to_check := NVL(l_attr_metadata_rec(l_var).EDIT_PRIVILEGE, p_default_edit_privilege);
            END IF;

            --shifting them to the else condition above.
            --l_view_priv_to_check := NVL(l_attr_metadata_rec(l_var).VIEW_PRIVILEGE, p_default_view_privilege);
            --l_edit_priv_to_check := NVL(l_attr_metadata_rec(l_var).EDIT_PRIVILEGE, p_default_edit_privilege);
            --Bug NO :6433569 end

            IF (l_view_priv_to_check IS NOT NULL OR
                l_edit_priv_to_check IS NOT NULL) THEN

              -----------------------------------------------------------
              -- If we have not yet parsed the statement, we do so now --
              -- and keep the cursor open throughout our processing    --
              -----------------------------------------------------------
              IF (l_priv_func_cursor_id IS NULL) THEN

                l_priv_func_cursor_id := DBMS_SQL.Open_Cursor;
                l_dynamic_sql :=
                  'BEGIN '||
                  p_privilege_predicate_api_name||
                  '(:obj_name, :party_id, :priv_name, :table_alias, :predicate); END;';

                DBMS_SQL.Parse(l_priv_func_cursor_id, l_dynamic_sql, DBMS_SQL.NATIVE);

                --------------------------------------------------------------
                -- These variables will not change across calls, so we only --
                -- need to bind them the first time we parse the statement  --
                --------------------------------------------------------------
                DBMS_SQL.Bind_Variable(l_priv_func_cursor_id, ':obj_name', p_object_name);
                DBMS_SQL.Bind_Variable(l_priv_func_cursor_id, ':party_id', G_HZ_PARTY_ID);
                DBMS_SQL.Bind_Variable(l_priv_func_cursor_id, ':table_alias', 'UAI2');
                DBMS_SQL.Bind_Variable(l_priv_func_cursor_id, ':predicate', l_priv_predicate, 32767);

              END IF;

              IF (l_view_priv_to_check IS NOT NULL) THEN

                code_debug('          Checking for View privelege '||l_view_priv_to_check,2);

                DBMS_SQL.Bind_Variable(l_priv_func_cursor_id, ':priv_name', l_view_priv_to_check);
                l_dummy := DBMS_SQL.Execute(l_priv_func_cursor_id);

                DBMS_SQL.Variable_Value(l_priv_func_cursor_id, ':predicate', l_priv_predicate);

                code_debug('          The View privlege predicate is :'||l_priv_predicate,3);

                ----------------------------------------------------------
                -- We interpret a NULL predicate as a pass for the user --
                ----------------------------------------------------------
                IF (l_priv_predicate IS NULL) THEN
                  l_priv_predicate := '1=1';
                END IF;
                --------------------------------------------------------------
                -- We needn't use DBMS_SQL here because this statement will --
                -- change too much in each loop (because of the predicate)  --
                -- for us to gain anything by keeping the cursor open       --
                --------------------------------------------------------------
                EXECUTE IMMEDIATE
                'UPDATE '||p_interface_table_name||' UAI1
                    SET UAI1.PROCESS_STATUS = '||G_PS_NO_PRIVILEGES||'
                  WHERE UAI1.DATA_SET_ID = :p_data_set_id
                    AND UAI1.PROCESS_STATUS = '||G_PS_IN_PROCESS||'
                    AND UAI1.ROW_IDENTIFIER IN
                        (
                         /* Fix for bug#9678667 - added below hint */
                         SELECT /*+ index(UAI2,EGO_ITM_USR_ATTR_INTRFC_N1) */
                                DISTINCT UAI2.ROW_IDENTIFIER
                           FROM '||p_interface_table_name||' UAI2
                          WHERE UAI2.DATA_SET_ID = :p_data_set_id
                            AND UAI2.PROCESS_STATUS = '||G_PS_IN_PROCESS||'
                            AND (UAI2.ATTR_GROUP_INT_NAME = :attr_group_name OR
                                 UAI2.ATTR_GROUP_ID = :attr_group_id)
                            AND NVL(UAI2.DATA_LEVEL_ID,-1) = NVL(:data_level_id,-1)
                            AND NOT '||l_priv_predicate||'
                        )'
                USING p_data_set_id, p_data_set_id,
                      l_attr_metadata_rec(l_var).ATTR_GROUP_INT_NAME,
                      l_attr_metadata_rec(l_var).ATTR_GROUP_ID,
                      l_attr_metadata_rec(l_var).DATA_LEVEL_ID;

              code_debug('          After validation for view privilege ',2);
              END IF;

              IF (l_edit_priv_to_check IS NOT NULL) THEN

                code_debug('          Checking for Edit privelege '||l_edit_priv_to_check,2);

                DBMS_SQL.Bind_Variable(l_priv_func_cursor_id, ':priv_name', l_edit_priv_to_check);
                l_dummy := DBMS_SQL.Execute(l_priv_func_cursor_id);
                DBMS_SQL.Variable_Value(l_priv_func_cursor_id, ':predicate', l_priv_predicate);

                code_debug('          The Edit privlege predicate is :'||l_priv_predicate,3);

                --------------------------------------------------------------
                -- As above, we needn't use DBMS_SQL because the statement  --
                -- changes too much in each loop (because of the predicate) --
                -- for us to gain anything by keeping the cursor open       --
                --------------------------------------------------------------

                EXECUTE IMMEDIATE
                'UPDATE '||p_interface_table_name||' UAI1
                    SET UAI1.PROCESS_STATUS = '||G_PS_NO_PRIVILEGES||'
                  WHERE UAI1.DATA_SET_ID = :p_data_set_id
                    AND UAI1.PROCESS_STATUS = '||G_PS_IN_PROCESS||'
                    AND UAI1.ROW_IDENTIFIER IN
                        (
                         /* Fix for bug#9678667 - added below hint */
                         SELECT /*+ index(UAI2,EGO_ITM_USR_ATTR_INTRFC_N1) */
                                DISTINCT UAI2.ROW_IDENTIFIER
                           FROM '||p_interface_table_name||' UAI2
                          WHERE UAI2.DATA_SET_ID = :p_data_set_id
                            AND UAI2.PROCESS_STATUS = '||G_PS_IN_PROCESS||'
                            AND (UAI2.ATTR_GROUP_INT_NAME = :attr_group_name OR
                                 UAI2.ATTR_GROUP_ID = :attr_group_id)
                            AND NVL(UAI2.DATA_LEVEL_ID,-1) = NVL(:data_level_id,-1)
                            AND NOT '||l_priv_predicate||'
                        )'
                USING p_data_set_id, p_data_set_id,
                      l_attr_metadata_rec(l_var).ATTR_GROUP_INT_NAME,
                      l_attr_metadata_rec(l_var).ATTR_GROUP_ID,
                      l_attr_metadata_rec(l_var).DATA_LEVEL_ID;

                code_debug('          After validation for edit privilege ',2);

              END IF;
            END IF;
          END IF;
        END IF;


        ------------------------------------------------------------------
        -- We would do rest of the validations only once per attribute  --
        -- It should not be repeated for every data level.              --
        ------------------------------------------------------------------
        IF(l_priv_attr_id <> l_attr_metadata_rec(l_var).ATTR_ID) THEN -- if not previously processed

           -----------------------------------------------------
           -- Validating, replacing the NULL characters here.
           -----------------------------------------------------

           EXECUTE IMMEDIATE 'SELECT TO_CHAR('||G_NULL_DATE_VAL||','''||EGO_USER_ATTRS_COMMON_PVT.G_DATE_FORMAT||'''), TO_CHAR('||G_NULL_DATE_VAL||', ''SYYYY-MM-DD'')  FROM DUAL '
           INTO l_null_date_time_value,l_null_date_value;

           l_dynamic_sql := 'UPDATE ';
           IF (l_attr_metadata_rec(l_var).DATA_TYPE = EGO_EXT_FWK_PUB.G_NUMBER_DATA_TYPE) THEN
             l_dynamic_sql := l_dynamic_sql ||p_interface_table_name||' SET '||' ATTR_VALUE_NUM = DECODE(ATTR_DISP_VALUE, '''||G_NULL_NUM_VAL_STR||''', NULL, '''||G_NULL_CHAR_VAL||''', NULL, NULL, NULL, ATTR_VALUE_NUM) '||
                              ' ,ATTR_DISP_VALUE = DECODE(ATTR_DISP_VALUE, '''||G_NULL_NUM_VAL_STR||''', NULL, '''||G_NULL_CHAR_VAL||''', NULL, NULL, NULL, ATTR_DISP_VALUE) '||
                              ' ,PROCESS_STATUS = PROCESS_STATUS + DECODE (ATTR_DISP_VALUE,'''||G_NULL_NUM_VAL_STR||''', 0 , '''||G_NULL_CHAR_VAL||''', 0 , '||
                                                                                          ' NULL, 0 , '||G_PS_INVALID_NUMBER_DATA||' )'||
                              ' WHERE  DATA_SET_ID = :data_set_id              '||
                              ' AND PROCESS_STATUS = '||G_PS_IN_PROCESS||'     '||
                              ' AND ATTR_INT_NAME = :attr_int_name             '||
                              ' AND ATTR_GROUP_INT_NAME = :attr_group_int_name '||
                              ' AND ATTR_GROUP_TYPE = :attr_group_type         '||
                              ' AND ( ATTR_VALUE_NUM = :null_num               '||
                              '      OR ATTR_DISP_VALUE = :null_num_val_disp   '||
                              '      OR ATTR_DISP_VALUE = :null_num_disp       '||
                              '      OR ATTR_DISP_VALUE = :null_date_disp      '||
                              '      OR ATTR_DISP_VALUE = :null_date_val_disp  '||
                              '      OR ATTR_DISP_VALUE = :null_char_val)       ';
             EXECUTE IMMEDIATE l_dynamic_sql
             USING p_data_set_id, l_attr_metadata_rec(l_var).ATTR_INT_NAME, l_attr_metadata_rec(l_var).ATTR_GROUP_INT_NAME,
                   p_attr_group_type, TO_NUMBER(G_NULL_NUM_VAL_STR),--bugFix:5297926
                   G_NULL_NUM_VAL_STR , G_NULL_NUM_VAL, G_NULL_DATE_VAL,l_null_date_time_value, G_NULL_CHAR_VAL;

           ELSIF (l_attr_metadata_rec(l_var).DATA_TYPE = EGO_EXT_FWK_PUB.G_DATE_DATA_TYPE
                  OR l_attr_metadata_rec(l_var).DATA_TYPE = EGO_EXT_FWK_PUB.G_DATE_TIME_DATA_TYPE) THEN
             l_dynamic_sql :=  l_dynamic_sql ||p_interface_table_name||' SET '||' ATTR_VALUE_DATE = DECODE(ATTR_DISP_VALUE, '''||l_null_date_time_value||''', NULL,'||
                              '                                            '''||l_null_date_value||''', NULL, '''||G_NULL_CHAR_VAL||''', NULL, NULL, NULL, ATTR_VALUE_DATE) '||
                              ' ,ATTR_DISP_VALUE = DECODE(ATTR_DISP_VALUE, '''||l_null_date_time_value||''', NULL, '||
                              '                                            '''||l_null_date_value||''',NULL, '''||G_NULL_CHAR_VAL||''', NULL, NULL, NULL, ATTR_DISP_VALUE) '||
                              ' ,PROCESS_STATUS = PROCESS_STATUS + DECODE (ATTR_DISP_VALUE,'''||l_null_date_time_value||''', 0 , '||
                                                                                          ' '''||l_null_date_value||''',0 , '''||G_NULL_CHAR_VAL||''', 0, '||
                                                                                          ' NULL, 0 , '||G_PS_INVALID_DATE_DATA||' )'||
                              ' WHERE  DATA_SET_ID = :data_set_id              '||
                              ' AND PROCESS_STATUS = '||G_PS_IN_PROCESS||'     '||
                              ' AND ATTR_INT_NAME = :attr_int_name             '||
                              ' AND ATTR_GROUP_INT_NAME = :attr_group_int_name '||
                              ' AND ATTR_GROUP_TYPE = :attr_group_type         '||
                              ' AND ( ATTR_VALUE_DATE = :null_date             '||
                              '      OR ATTR_DISP_VALUE = :null_num_val_disp   '||
                              '      OR ATTR_DISP_VALUE = :null_num_disp       '||
                              '      OR ATTR_DISP_VALUE = :null_date_disp      '||
                              '      OR ATTR_DISP_VALUE = :null_date_time_val_disp  '||
                              '      OR ATTR_DISP_VALUE = :null_date_val_disp  '||
                              '      OR ATTR_DISP_VALUE = :null_char_val)      ';

             EXECUTE IMMEDIATE l_dynamic_sql
             USING p_data_set_id, l_attr_metadata_rec(l_var).ATTR_INT_NAME, l_attr_metadata_rec(l_var).ATTR_GROUP_INT_NAME,
                   p_attr_group_type, TO_DATE(l_null_date_time_value,EGO_USER_ATTRS_COMMON_PVT.G_DATE_FORMAT),
                   G_NULL_NUM_VAL_STR , G_NULL_NUM_VAL, G_NULL_DATE_VAL,l_null_date_time_value,l_null_date_value,G_NULL_CHAR_VAL;

           ELSE
              /* Fix for bug#9678667 - Added below hint */
             l_dynamic_sql := l_dynamic_sql ||' /*+ index(EGO_ITM_USR_ATTR_INTRFC, EGO_ITM_USR_ATTR_INTRFC_N1) */ ' ||p_interface_table_name||
                              ' SET '||' ATTR_VALUE_STR = NULL          '||
                              ' ,  ATTR_DISP_VALUE = NULL                      '||
                              ' WHERE  DATA_SET_ID = :data_set_id              '||
                              ' AND PROCESS_STATUS = '||G_PS_IN_PROCESS||'     '||
                              ' AND ATTR_INT_NAME = :attr_int_name             '||
                              ' AND ATTR_GROUP_INT_NAME = :attr_group_int_name '||
                              ' AND ATTR_GROUP_TYPE = :attr_group_type         '||
                              ' AND (ATTR_VALUE_STR = :null_str                '||
                              '     OR ATTR_DISP_VALUE = :null_char_val)       ';

             EXECUTE IMMEDIATE l_dynamic_sql
             USING p_data_set_id, l_attr_metadata_rec(l_var).ATTR_INT_NAME, l_attr_metadata_rec(l_var).ATTR_GROUP_INT_NAME,
                   p_attr_group_type, G_NULL_CHAR_VAL,
                   G_NULL_CHAR_VAL;

           END IF;




           ----------------------------------------------------------------------------------
           -- UOM VALIDATIONS FOR NUMBER TYPE ATTRIBUTES HAVING A UOM CLASS DEFINED.
           ----------------------------------------------------------------------------------
           IF(l_attr_metadata_rec(l_var).UOM_CLASS IS NOT NULL) THEN

             ----------------------------------------------------------------------------------
             -- Here we validate the UOM column Display/internal value in the interface table
             ----------------------------------------------------------------------------------
             l_dynamic_sql :=
             'UPDATE '||p_interface_table_name||' INTF
                 SET PROCESS_STATUS = PROCESS_STATUS + '||G_PS_INVALID_UOM||'
               WHERE DATA_SET_ID = :data_set_id
                 AND PROCESS_STATUS = '||G_PS_IN_PROCESS||'
                 AND ATTR_INT_NAME = :attr_internal_name
                 AND ATTR_GROUP_INT_NAME = :attr_group_int_name
                 AND ( (ATTR_UOM_DISP_VALUE IS NOT NULL AND ATTR_VALUE_UOM IS NULL
                         AND NOT EXISTS (SELECT ''X'' FROM MTL_UNITS_OF_MEASURE_TL
                                          WHERE UOM_CLASS = :uom_class
                                            AND UNIT_OF_MEASURE_TL = INTF.ATTR_UOM_DISP_VALUE
                                            AND ROWNUM =1 ))
                      OR(ATTR_VALUE_UOM IS NOT NULL
                         AND NOT EXISTS (SELECT ''X'' FROM MTL_UNITS_OF_MEASURE_TL
                                          WHERE UOM_CLASS = :uom_class
                                            AND UOM_CODE = INTF.ATTR_VALUE_UOM
                                            AND ROWNUM =1 ))
                     )' ;
             EXECUTE IMMEDIATE l_dynamic_sql
             USING p_data_Set_id, l_attr_metadata_rec(l_var).ATTR_INT_NAME, l_attr_metadata_rec(l_var).ATTR_GROUP_INT_NAME,
                   l_attr_metadata_rec(l_var).UOM_CLASS, l_attr_metadata_rec(l_var).UOM_CLASS;

             ----------------------------------------------
             -- Here we populate the internal UOM value
             ----------------------------------------------
             l_dynamic_sql :=
             'UPDATE '||p_interface_table_name||' INTF
                 SET ATTR_VALUE_UOM = NVL2(ATTR_UOM_DISP_VALUE,
                                           (SELECT UOM_CODE FROM MTL_UNITS_OF_MEASURE_TL
                                             WHERE UOM_CLASS = :uom_class
                                               AND UNIT_OF_MEASURE_TL = INTF.ATTR_UOM_DISP_VALUE
                                               AND LANGUAGE = USERENV(''LANG'')),null
                                          )
               WHERE DATA_SET_ID = :data_set_id
                 AND PROCESS_STATUS = '||G_PS_IN_PROCESS||'
                 AND ATTR_INT_NAME = :attr_internal_name
                 AND ATTR_GROUP_INT_NAME = :attr_group_int_name
                 AND ATTR_GROUP_TYPE = :attr_group_type
                 AND ATTR_VALUE_UOM IS NULL ';

             EXECUTE IMMEDIATE l_dynamic_sql
             USING l_attr_metadata_rec(l_var).UOM_CLASS, p_data_Set_id,
                   l_attr_metadata_rec(l_var).ATTR_INT_NAME, l_attr_metadata_rec(l_var).ATTR_GROUP_INT_NAME,p_attr_group_type;

           END IF;



           -- 4043670 added for trans independent type value sets as well
           IF (l_attr_metadata_rec(l_var).VALIDATION_TYPE IN
                 (EGO_EXT_FWK_PUB.G_INDEPENDENT_VALIDATION_CODE, EGO_EXT_FWK_PUB.G_TRANS_IND_VALIDATION_CODE)
              ) THEN

           code_debug('          This attribute has an indipendednt value set, validating for value set id -'||l_attr_metadata_rec(l_var).VALUE_SET_ID ,2);

             IF (l_attr_metadata_rec(l_var).DATA_TYPE = EGO_EXT_FWK_PUB.G_NUMBER_DATA_TYPE) THEN
               IF (l_ivs_num_cursor_id IS NULL) THEN
                 l_ivs_num_cursor_id := DBMS_SQL.Open_Cursor;
                 l_dynamic_sql :=
                 'UPDATE '||p_interface_table_name||'
                     SET ATTR_VALUE_NUM = TO_NUMBER((SELECT DISTINCT FLEX_VALUE
                                                           FROM FND_FLEX_VALUES_VL
                                                          WHERE ENABLED_FLAG = ''Y''
                                                            AND (NVL(START_DATE_ACTIVE, SYSDATE - 1) < SYSDATE)
                                                            AND (NVL(END_DATE_ACTIVE, SYSDATE + 1) > SYSDATE)
                                                            AND FLEX_VALUE_SET_ID = :value_set_id
                                                            AND (FLEX_VALUE_MEANING = ATTR_DISP_VALUE OR TO_NUMBER(FLEX_VALUE) = ATTR_VALUE_NUM))  /**bug 13589373**/
                                                         ),
                         PROCESS_STATUS = NVL2(ATTR_VALUE_NUM,-- IF THE ATTR VALUE IS NULL WE VALIDATE THE VS ACCORDING TO ATTR_DISP_VAL OTHERWISE VALIDATION IS AGAINST THE ATTR_VALUE_* TAKEN AS INTERNAL_NAME OF VS
                              (NVL2((SELECT DISTINCT FLEX_VALUE
                                       FROM FND_FLEX_VALUES_VL
                                      WHERE ENABLED_FLAG = ''Y''
                                        AND (NVL(START_DATE_ACTIVE, SYSDATE - 1) < SYSDATE)
                                        AND (NVL(END_DATE_ACTIVE, SYSDATE + 1) > SYSDATE)
                                        AND FLEX_VALUE_SET_ID = :value_set_id
                                        --AND FLEX_VALUE = TO_CHAR(ATTR_VALUE_NUM)),
                                        AND (TO_NUMBER(FLEX_VALUE) = ATTR_VALUE_NUM OR FLEX_VALUE_MEANING = ATTR_DISP_VALUE)),/*Bug:9735836,if number is decimal and less than 1,to char will remove "0" */
                                     (PROCESS_STATUS),
                                     (PROCESS_STATUS + '||G_PS_VALUE_NOT_IN_VS||'))
                              ),
                              (NVL2((SELECT DISTINCT FLEX_VALUE
                                       FROM FND_FLEX_VALUES_VL
                                      WHERE ENABLED_FLAG = ''Y''
                                        AND (NVL(START_DATE_ACTIVE, SYSDATE - 1) < SYSDATE)
                                        AND (NVL(END_DATE_ACTIVE, SYSDATE + 1) > SYSDATE)
                                        AND FLEX_VALUE_SET_ID = :value_set_id
                                        AND FLEX_VALUE_MEANING = ATTR_DISP_VALUE),
                                      (PROCESS_STATUS),
                                      (PROCESS_STATUS + '||G_PS_VALUE_NOT_IN_VS||'))
                              )
                             )
                   WHERE DATA_SET_ID = :data_set_id
                     AND (PROCESS_STATUS = '||G_PS_IN_PROCESS||' OR PROCESS_STATUS > '||G_PS_BAD_ATTR_OR_AG_METADATA||' )
                     AND BITAND(PROCESS_STATUS, '||G_PS_NO_PRIVILEGES||') = 0
                     AND ATTR_INT_NAME = :attr_int_name
                     AND (ATTR_DISP_VALUE IS NOT NULL OR ATTR_VALUE_NUM IS NOT NULL)
                     AND ATTR_GROUP_INT_NAME = :attr_group_int_name';

                 DBMS_SQL.Parse(l_ivs_num_cursor_id, l_dynamic_sql, DBMS_SQL.NATIVE);

                 -----------------------------------------------------------
                 -- Data set ID will not change across calls, so we only  --
                 -- need to bind it the first time we parse the statement --
                 -----------------------------------------------------------
                 DBMS_SQL.Bind_Variable(l_ivs_num_cursor_id, ':data_set_id', p_data_set_id);

               END IF;
               DBMS_SQL.Bind_Variable(l_ivs_num_cursor_id, ':value_set_id', l_attr_metadata_rec(l_var).VALUE_SET_ID);
               DBMS_SQL.Bind_Variable(l_ivs_num_cursor_id, ':attr_int_name', l_attr_metadata_rec(l_var).ATTR_INT_NAME);
               DBMS_SQL.Bind_Variable(l_ivs_num_cursor_id, ':attr_group_int_name', l_attr_metadata_rec(l_var).ATTR_GROUP_INT_NAME);
               l_dummy := DBMS_SQL.Execute(l_ivs_num_cursor_id);

             ELSIF (l_attr_metadata_rec(l_var).DATA_TYPE = EGO_EXT_FWK_PUB.G_DATE_DATA_TYPE) THEN
               IF (l_ivs_date_cursor_id IS NULL) THEN

                 l_ivs_date_cursor_id := DBMS_SQL.Open_Cursor;
                 l_dynamic_sql :=
                 'UPDATE '||p_interface_table_name||'
                     SET ATTR_VALUE_DATE = (SELECT DISTINCT TRUNC(EGO_USER_ATTRS_BULK_PVT.Get_Date(FLEX_VALUE,'''||EGO_USER_ATTRS_COMMON_PVT.G_DATE_FORMAT||'''))
                                                              FROM FND_FLEX_VALUES_VL
                                                             WHERE ENABLED_FLAG = ''Y''
                                                               AND (NVL(START_DATE_ACTIVE, SYSDATE - 1) < SYSDATE)
                                                               AND (NVL(END_DATE_ACTIVE, SYSDATE + 1) > SYSDATE)
                                                               AND FLEX_VALUE_SET_ID = :value_set_id
                                                               AND (FLEX_VALUE_MEANING = ATTR_DISP_VALUE OR FLEX_VALUE = TO_CHAR(ATTR_VALUE_DATE,''YYYY-MM-DD HH24:MI:SS''))  /**bug 13589373**/
                                                            ),
                         PROCESS_STATUS = NVL2(ATTR_VALUE_DATE,-- IF THE ATTR VALUE IS NULL WE VALIDATE THE VS ACCORDING TO ATTR_DISP_VAL OTHERWISE VALIDATION IS AGAINST THE ATTR_VALUE_* TAKEN AS INTERNAL_NAME OF VS
                                                              (NVL2((SELECT DISTINCT FLEX_VALUE
                                                                     FROM FND_FLEX_VALUES_VL
                                                                     WHERE ENABLED_FLAG = ''Y''
                                                                     AND (NVL(START_DATE_ACTIVE, SYSDATE - 1) < SYSDATE)
                                                                     AND (NVL(END_DATE_ACTIVE, SYSDATE + 1) > SYSDATE)
                                                                     AND FLEX_VALUE_SET_ID = :value_set_id
                                                                     AND (FLEX_VALUE = TO_CHAR(ATTR_VALUE_DATE,''YYYY-MM-DD HH24:MI:SS'') OR FLEX_VALUE_MEANING = ATTR_DISP_VALUE)),
                                                                     (PROCESS_STATUS),
                                                                     (PROCESS_STATUS + '||G_PS_VALUE_NOT_IN_VS||'))
                                                              ),
                                                              (NVL2((SELECT DISTINCT FLEX_VALUE
                                                                     FROM FND_FLEX_VALUES_VL
                                                                     WHERE ENABLED_FLAG = ''Y''
                                                                     AND (NVL(START_DATE_ACTIVE, SYSDATE - 1) < SYSDATE)
                                                                     AND (NVL(END_DATE_ACTIVE, SYSDATE + 1) > SYSDATE)
                                                                     AND FLEX_VALUE_SET_ID = :value_set_id
                                                                     AND FLEX_VALUE_MEANING = ATTR_DISP_VALUE),
                                                                    (PROCESS_STATUS),
                                                                    (PROCESS_STATUS + '||G_PS_VALUE_NOT_IN_VS||'))
                                                              )
                                              )
                   WHERE DATA_SET_ID = :data_set_id
                     AND (PROCESS_STATUS = '||G_PS_IN_PROCESS||' OR PROCESS_STATUS > '||G_PS_BAD_ATTR_OR_AG_METADATA||' )
                     AND BITAND(PROCESS_STATUS, '||G_PS_NO_PRIVILEGES||') = 0
                     AND ATTR_INT_NAME = :attr_int_name
                     AND (ATTR_DISP_VALUE IS NOT NULL OR ATTR_VALUE_DATE IS NOT NULL)
                     AND ATTR_GROUP_INT_NAME = :attr_group_int_name';

                 DBMS_SQL.Parse(l_ivs_date_cursor_id, l_dynamic_sql, DBMS_SQL.NATIVE);

                 -----------------------------------------------------------
                 -- Data set ID will not change across calls, so we only  --
                 -- need to bind it the first time we parse the statement --
                 -----------------------------------------------------------
                 DBMS_SQL.Bind_Variable(l_ivs_date_cursor_id, ':data_set_id', p_data_set_id);
               END IF;

               DBMS_SQL.Bind_Variable(l_ivs_date_cursor_id, ':value_set_id', l_attr_metadata_rec(l_var).VALUE_SET_ID);
               DBMS_SQL.Bind_Variable(l_ivs_date_cursor_id, ':attr_int_name', l_attr_metadata_rec(l_var).ATTR_INT_NAME);
               DBMS_SQL.Bind_Variable(l_ivs_date_cursor_id, ':attr_group_int_name', l_attr_metadata_rec(l_var).ATTR_GROUP_INT_NAME);
               l_dummy := DBMS_SQL.Execute(l_ivs_date_cursor_id);

             ELSIF (l_attr_metadata_rec(l_var).DATA_TYPE = EGO_EXT_FWK_PUB.G_DATE_TIME_DATA_TYPE) THEN

               IF (l_ivs_date_time_cursor_id IS NULL) THEN

                 l_ivs_date_time_cursor_id := DBMS_SQL.Open_Cursor;
                 l_dynamic_sql :=
                 'UPDATE '||p_interface_table_name||'
                     SET ATTR_VALUE_DATE = (EGO_USER_ATTRS_BULK_PVT.Get_Date(
                                                      (SELECT DISTINCT FLEX_VALUE
                                                         FROM FND_FLEX_VALUES_VL
                                                        WHERE ENABLED_FLAG = ''Y''
                                                          AND (NVL(START_DATE_ACTIVE, SYSDATE - 1) < SYSDATE)
                                                          AND (NVL(END_DATE_ACTIVE, SYSDATE + 1) > SYSDATE)
                                                          AND FLEX_VALUE_SET_ID = :value_set_id
                                                          AND (FLEX_VALUE_MEANING = ATTR_DISP_VALUE OR FLEX_VALUE = TO_CHAR(ATTR_VALUE_DATE,''YYYY-MM-DD HH24:MI:SS''))) /**bug 13589373**/
                                                     )
                                                 ),
                         PROCESS_STATUS = NVL2(ATTR_VALUE_DATE,-- IF THE ATTR VALUE IS NULL WE VALIDATE THE VS ACCORDING TO ATTR_DISP_VAL OTHERWISE VALIDATION IS AGAINST THE ATTR_VALUE_* TAKEN AS INTERNAL_NAME OF VS
                                                              (NVL2((SELECT DISTINCT FLEX_VALUE
                                                                     FROM FND_FLEX_VALUES_VL
                                                                     WHERE ENABLED_FLAG = ''Y''
                                                                     AND (NVL(START_DATE_ACTIVE, SYSDATE - 1) < SYSDATE)
                                                                     AND (NVL(END_DATE_ACTIVE, SYSDATE + 1) > SYSDATE)
                                                                     AND FLEX_VALUE_SET_ID = :value_set_id
                                                                     AND (FLEX_VALUE = TO_CHAR(ATTR_VALUE_DATE,''YYYY-MM-DD HH24:MI:SS'') OR FLEX_VALUE_MEANING = ATTR_DISP_VALUE)),
                                                                     (PROCESS_STATUS),
                                                                     (PROCESS_STATUS + '||G_PS_VALUE_NOT_IN_VS||'))
                                                              ),
                                                              (NVL2((SELECT DISTINCT FLEX_VALUE
                                                                     FROM FND_FLEX_VALUES_VL
                                                                     WHERE ENABLED_FLAG = ''Y''
                                                                     AND (NVL(START_DATE_ACTIVE, SYSDATE - 1) < SYSDATE)
                                                                     AND (NVL(END_DATE_ACTIVE, SYSDATE + 1) > SYSDATE)
                                                                     AND FLEX_VALUE_SET_ID = :value_set_id
                                                                     AND FLEX_VALUE_MEANING = ATTR_DISP_VALUE),
                                                                    (PROCESS_STATUS),
                                                                    (PROCESS_STATUS + '||G_PS_VALUE_NOT_IN_VS||'))
                                                              )
                                              )
                   WHERE DATA_SET_ID = :data_set_id
                     AND (PROCESS_STATUS = '||G_PS_IN_PROCESS||' OR PROCESS_STATUS > '||G_PS_BAD_ATTR_OR_AG_METADATA||' )
                     AND BITAND(PROCESS_STATUS, '||G_PS_NO_PRIVILEGES||') = 0
                     AND ATTR_INT_NAME = :attr_int_name
                     AND (ATTR_DISP_VALUE IS NOT NULL OR ATTR_VALUE_DATE IS NOT NULL)
                     AND ATTR_GROUP_INT_NAME = :attr_group_int_name';

                 DBMS_SQL.Parse(l_ivs_date_time_cursor_id, l_dynamic_sql, DBMS_SQL.NATIVE);

                 -----------------------------------------------------------
                 -- Data set ID will not change across calls, so we only  --
                 -- need to bind it the first time we parse the statement --
                 -----------------------------------------------------------
                 DBMS_SQL.Bind_Variable(l_ivs_date_time_cursor_id, ':data_set_id', p_data_set_id);

               END IF;

               DBMS_SQL.Bind_Variable(l_ivs_date_time_cursor_id, ':value_set_id', l_attr_metadata_rec(l_var).VALUE_SET_ID);
               DBMS_SQL.Bind_Variable(l_ivs_date_time_cursor_id, ':attr_int_name', l_attr_metadata_rec(l_var).ATTR_INT_NAME);
               DBMS_SQL.Bind_Variable(l_ivs_date_time_cursor_id, ':attr_group_int_name', l_attr_metadata_rec(l_var).ATTR_GROUP_INT_NAME);
               l_dummy := DBMS_SQL.Execute(l_ivs_date_time_cursor_id);

             ELSE -- must be Char or Trans Text

               IF (l_ivs_char_cursor_id IS NULL) THEN

                 l_ivs_char_cursor_id := DBMS_SQL.Open_Cursor;
                 l_dynamic_sql :=
                 'UPDATE '||p_interface_table_name||'
                    SET ATTR_VALUE_STR =           (SELECT DISTINCT FLEX_VALUE
                                                           FROM FND_FLEX_VALUES_VL
                                                          WHERE ENABLED_FLAG = ''Y''
                                                            AND (NVL(START_DATE_ACTIVE, SYSDATE - 1) < SYSDATE)
                                                            AND (NVL(END_DATE_ACTIVE, SYSDATE + 1) > SYSDATE)
                                                            AND FLEX_VALUE_SET_ID = :value_set_id
                                                            AND (FLEX_VALUE_MEANING = ATTR_DISP_VALUE OR FLEX_VALUE = ATTR_VALUE_STR)  /**bug 13589373**/
                                                         ),
                         PROCESS_STATUS = NVL2(ATTR_VALUE_STR,-- IF THE ATTR VALUE IS NULL WE VALIDATE THE VS ACCORDING TO ATTR_DISP_VAL OTHERWISE VALIDATION IS AGAINST THE ATTR_VALUE_* TAKEN AS FLEX_VALUE OF VS
                                                              (NVL2((SELECT DISTINCT FLEX_VALUE
                                                                     FROM FND_FLEX_VALUES_VL
                                                                     WHERE ENABLED_FLAG = ''Y''
                                                                     AND (NVL(START_DATE_ACTIVE, SYSDATE - 1) < SYSDATE)
                                                                     AND (NVL(END_DATE_ACTIVE, SYSDATE + 1) > SYSDATE)
                                                                     AND FLEX_VALUE_SET_ID = :value_set_id
                                                                     AND (FLEX_VALUE = ATTR_VALUE_STR OR FLEX_VALUE_MEANING = ATTR_DISP_VALUE)),
                                                                     (PROCESS_STATUS),
                                                                     (PROCESS_STATUS + '||G_PS_VALUE_NOT_IN_VS||'))
                                                              ),
                                                              (NVL2((SELECT DISTINCT FLEX_VALUE
                                                                     FROM FND_FLEX_VALUES_VL
                                                                     WHERE ENABLED_FLAG = ''Y''
                                                                     AND (NVL(START_DATE_ACTIVE, SYSDATE - 1) < SYSDATE)
                                                                     AND (NVL(END_DATE_ACTIVE, SYSDATE + 1) > SYSDATE)
                                                                     AND FLEX_VALUE_SET_ID = :value_set_id
                                                                     AND FLEX_VALUE_MEANING = ATTR_DISP_VALUE),
                                                                    (PROCESS_STATUS),
                                                                    (PROCESS_STATUS + '||G_PS_VALUE_NOT_IN_VS||'))
                                                              )
                                              )
                   WHERE DATA_SET_ID = :data_set_id
                     AND (PROCESS_STATUS = '||G_PS_IN_PROCESS||' OR PROCESS_STATUS > '||G_PS_BAD_ATTR_OR_AG_METADATA||' )
                     AND BITAND(PROCESS_STATUS, '||G_PS_NO_PRIVILEGES||') = 0
                     AND ATTR_INT_NAME = :attr_int_name
                     AND (ATTR_DISP_VALUE IS NOT NULL OR ATTR_VALUE_STR IS NOT NULL)
                     AND ATTR_GROUP_INT_NAME = :attr_group_int_name';

                 DBMS_SQL.Parse(l_ivs_char_cursor_id, l_dynamic_sql, DBMS_SQL.NATIVE);

                 -----------------------------------------------------------
                 -- Data set ID will not change across calls, so we only  --
                 -- need to bind it the first time we parse the statement --
                 -----------------------------------------------------------
                 DBMS_SQL.Bind_Variable(l_ivs_char_cursor_id, ':data_set_id', p_data_set_id);

               END IF;

               DBMS_SQL.Bind_Variable(l_ivs_char_cursor_id, ':value_set_id', l_attr_metadata_rec(l_var).VALUE_SET_ID);
               DBMS_SQL.Bind_Variable(l_ivs_char_cursor_id, ':attr_int_name', l_attr_metadata_rec(l_var).ATTR_INT_NAME);
               DBMS_SQL.Bind_Variable(l_ivs_char_cursor_id, ':attr_group_int_name', l_attr_metadata_rec(l_var).ATTR_GROUP_INT_NAME);
               l_dummy := DBMS_SQL.Execute(l_ivs_char_cursor_id);

             END IF;
           ELSIF (l_attr_metadata_rec(l_var).VALIDATION_TYPE = EGO_EXT_FWK_PUB.G_TABLE_VALIDATION_CODE) THEN

             ------------------------------------------------------------------------------------
             -- HERE WE UPDATE THE INTERFACE TABLE SETTING THE ATTR_VAL_(NUM/STR/DATE) COLUMNS --
             -- WITH VALUES FETCHED FROM THE TABLE FOR THE VALUE ENTERED AS DISPLAY VALUE i.e. --
             -- VALIDATION_TYPE='F' and logging errors for all logical AG rows that don't pass --
             ------------------------------------------------------------------------------------
             /*
               The TVS validation is shifted in the second loop
               do nothing over here
             */
             l_dynamic_sql := ' ';

           ELSE

           code_debug('          This attribute has a none value set, validating for before populating the attr_Value* columns from attr_disp_value column' ,2);
             ------------------------------------------------------------------------------------
             -- HERE WE UPDATE THE INTERFACE TABLE SETTING THE ATTR_VAL_(NUM/STR/DATE) COLUMNS --
             -- FROM ATTR_DISP_VALUE FOR ATTRS WITHOUT ANY VALUE SET *OR* WITH VALIDATION TYPE --
             -- ='N' (i.e., EGO_EXT_FWK_PUB.G_NONE_VALIDATION_CODE)                            --
             -- WE ALSO DO THE MAX/MIN VALIDATION IN THIS SEGMENT                              --
             ------------------------------------------------------------------------------------
             IF (l_attr_metadata_rec(l_var).DATA_TYPE = EGO_EXT_FWK_PUB.G_NUMBER_DATA_TYPE) THEN

               IF (l_nvs_num_cursor_id is NULL) THEN
                 l_nvs_num_cursor_id := DBMS_SQL.Open_Cursor;
                 l_dynamic_sql :=
                 'UPDATE '||p_interface_table_name||'
                     SET ATTR_VALUE_NUM = DECODE(EGO_USER_ATTRS_BULK_PVT.Get_Datatype_Error_Val(ATTR_DISP_VALUE, :attr_datatype),0,NVL(TO_NUMBER(ATTR_DISP_VALUE),ATTR_VALUE_NUM),NULL),
                         PROCESS_STATUS = PROCESS_STATUS +
                                          EGO_USER_ATTRS_BULK_PVT.Get_Datatype_Error_Val(ATTR_DISP_VALUE, :attr_datatype) + --returns 0 if datatype conversion happens correctly
                                          EGO_USER_ATTRS_BULK_PVT.Get_Max_Min_Error_Val( NVL(ATTR_DISP_VALUE,ATTR_VALUE_NUM) * NVL((SELECT CONVERSION_RATE FROM MTL_UOM_CONVERSIONS
                                                                                                                                     WHERE UOM_CLASS = :uom_class AND UOM_CODE = ATTR_VALUE_UOM AND ROWNUM = 1),1),
                                                                                         :attr_datatype,
                                                                                         :attr_min_allowed_val,
                                                                                         :attr_max_allowed_val) --returns 0 if max/min is honoured or datatype conversion fails
                   WHERE DATA_SET_ID = :data_set_id
                     AND (PROCESS_STATUS = '||G_PS_IN_PROCESS||' OR PROCESS_STATUS > '||G_PS_BAD_ATTR_OR_AG_METADATA||' )
                     AND BITAND(PROCESS_STATUS, '||G_PS_NO_PRIVILEGES||') = 0
                     AND ATTR_INT_NAME = :attr_internal_name
                     AND ATTR_GROUP_INT_NAME = :attr_group_int_name
                     AND (ATTR_DISP_VALUE IS NOT NULL OR ATTR_VALUE_NUM IS NOT NULL)';

                 DBMS_SQL.Parse(l_nvs_num_cursor_id, l_dynamic_sql, DBMS_SQL.NATIVE);
                 DBMS_SQL.Bind_Variable(l_nvs_num_cursor_id, ':data_set_id', p_data_set_id);

               END IF;
               DBMS_SQL.Bind_Variable(l_nvs_num_cursor_id, ':uom_class', l_attr_metadata_rec(l_var).UOM_CLASS);
               DBMS_SQL.Bind_Variable(l_nvs_num_cursor_id, ':attr_datatype', l_attr_metadata_rec(l_var).DATA_TYPE);
               DBMS_SQL.Bind_Variable(l_nvs_num_cursor_id, ':attr_min_allowed_val', l_attr_metadata_rec(l_var).MINIMUM_VALUE);
               DBMS_SQL.Bind_Variable(l_nvs_num_cursor_id, ':attr_max_allowed_val', l_attr_metadata_rec(l_var).MAXIMUM_VALUE);
               DBMS_SQL.Bind_Variable(l_nvs_num_cursor_id, ':attr_internal_name', l_attr_metadata_rec(l_var).ATTR_INT_NAME);
               DBMS_SQL.Bind_Variable(l_nvs_num_cursor_id, ':attr_group_int_name', l_attr_metadata_rec(l_var).ATTR_GROUP_INT_NAME);

               l_dummy := DBMS_SQL.Execute(l_nvs_num_cursor_id);

             ELSIF(l_attr_metadata_rec(l_var).DATA_TYPE = EGO_EXT_FWK_PUB.G_DATE_DATA_TYPE) THEN

               IF (l_nvs_date_cursor_id IS NULL) THEN
                 l_nvs_date_cursor_id := DBMS_SQL.Open_Cursor;
                 l_dynamic_sql :=
                 'UPDATE '||p_interface_table_name||'
                     SET ATTR_VALUE_DATE = TRUNC(NVL(EGO_USER_ATTRS_BULK_PVT.Get_Date(ATTR_DISP_VALUE),ATTR_VALUE_DATE)),--WE SHOULD REMOVE THE TIME PART FROM THE DATE IF DATATYPE IS NOT DATE TIME
                         PROCESS_STATUS = PROCESS_STATUS +
                                          EGO_USER_ATTRS_BULK_PVT.Get_Datatype_Error_Val(ATTR_DISP_VALUE, :attr_datatype) + --returns 0 if datatype conversion happens correctly
                                          EGO_USER_ATTRS_BULK_PVT.Get_Max_Min_Error_Val(NVL(ATTR_DISP_VALUE,ATTR_VALUE_DATE), :attr_datatype, :attr_min_allowed_val, :attr_max_allowed_val) --returns 0 if max/min is honoured or datatype conv fails
                   WHERE DATA_SET_ID = :data_set_id
                     AND (PROCESS_STATUS = '||G_PS_IN_PROCESS||' OR PROCESS_STATUS > '||G_PS_BAD_ATTR_OR_AG_METADATA||' )
                     AND BITAND(PROCESS_STATUS, '||G_PS_NO_PRIVILEGES||') = 0
                     AND ATTR_INT_NAME = :attr_internal_name
                     AND ATTR_GROUP_INT_NAME = :attr_group_int_name
                     AND (ATTR_DISP_VALUE IS NOT NULL OR ATTR_VALUE_DATE IS NOT NULL)';

                 DBMS_SQL.Parse(l_nvs_date_cursor_id, l_dynamic_sql, DBMS_SQL.NATIVE);
                 DBMS_SQL.Bind_Variable(l_nvs_date_cursor_id, ':data_set_id', p_data_set_id);

               END IF;

               DBMS_SQL.Bind_Variable(l_nvs_date_cursor_id, ':attr_datatype', l_attr_metadata_rec(l_var).DATA_TYPE);
               DBMS_SQL.Bind_Variable(l_nvs_date_cursor_id, ':attr_group_int_name', l_attr_metadata_rec(l_var).ATTR_GROUP_INT_NAME);
               DBMS_SQL.Bind_Variable(l_nvs_date_cursor_id, ':attr_internal_name', l_attr_metadata_rec(l_var).ATTR_INT_NAME);
               DBMS_SQL.Bind_Variable(l_nvs_date_cursor_id, ':attr_min_allowed_val', l_attr_metadata_rec(l_var).MINIMUM_VALUE);
               DBMS_SQL.Bind_Variable(l_nvs_date_cursor_id, ':attr_max_allowed_val', l_attr_metadata_rec(l_var).MAXIMUM_VALUE);
               l_dummy := DBMS_SQL.Execute(l_nvs_date_cursor_id);

             ELSIF(l_attr_metadata_rec(l_var).DATA_TYPE = EGO_EXT_FWK_PUB.G_DATE_TIME_DATA_TYPE) THEN

               IF (l_nvs_datetime_cursor_id is NULL) THEN
                 l_nvs_datetime_cursor_id := DBMS_SQL.Open_Cursor;
                 l_dynamic_sql :=
                 'UPDATE '||p_interface_table_name||'
                     SET ATTR_VALUE_DATE = NVL(EGO_USER_ATTRS_BULK_PVT.Get_Date(ATTR_DISP_VALUE,'''||EGO_USER_ATTRS_COMMON_PVT.G_DATE_FORMAT||'''),ATTR_VALUE_DATE),
                         PROCESS_STATUS = PROCESS_STATUS +
                                          EGO_USER_ATTRS_BULK_PVT.Get_Datatype_Error_Val(ATTR_DISP_VALUE, :attr_datatype) + --returns 0 if datatype conversion happens correctly
                                          EGO_USER_ATTRS_BULK_PVT.Get_Max_Min_Error_Val(NVL(ATTR_DISP_VALUE,ATTR_VALUE_DATE), :attr_datatype, :attr_min_allowed_val, :attr_max_allowed_val) --returns 0 if max/min is honoured or datatype conv fails
                   WHERE DATA_SET_ID = :data_set_id
                     AND (PROCESS_STATUS = '||G_PS_IN_PROCESS||' OR PROCESS_STATUS > '||G_PS_BAD_ATTR_OR_AG_METADATA||' )
                     AND BITAND(PROCESS_STATUS, '||G_PS_NO_PRIVILEGES||') = 0
                     AND ATTR_INT_NAME = :attr_internal_name
                     AND ATTR_GROUP_INT_NAME = :attr_group_int_name
                     AND (ATTR_DISP_VALUE IS NOT NULL OR ATTR_VALUE_DATE IS NOT NULL)';

                 DBMS_SQL.Parse(l_nvs_datetime_cursor_id, l_dynamic_sql, DBMS_SQL.NATIVE);
                 DBMS_SQL.Bind_Variable(l_nvs_datetime_cursor_id, ':data_set_id', p_data_set_id);

               END IF;

               DBMS_SQL.Bind_Variable(l_nvs_datetime_cursor_id, ':attr_datatype', l_attr_metadata_rec(l_var).DATA_TYPE);
               DBMS_SQL.Bind_Variable(l_nvs_datetime_cursor_id, ':attr_group_int_name', l_attr_metadata_rec(l_var).ATTR_GROUP_INT_NAME);
               DBMS_SQL.Bind_Variable(l_nvs_datetime_cursor_id, ':attr_internal_name', l_attr_metadata_rec(l_var).ATTR_INT_NAME);
               DBMS_SQL.Bind_Variable(l_nvs_datetime_cursor_id, ':attr_min_allowed_val', l_attr_metadata_rec(l_var).MINIMUM_VALUE);
               DBMS_SQL.Bind_Variable(l_nvs_datetime_cursor_id, ':attr_max_allowed_val', l_attr_metadata_rec(l_var).MAXIMUM_VALUE);

               l_dummy := DBMS_SQL.Execute(l_nvs_datetime_cursor_id);

             ELSE -- must be char and translateble text
               IF (l_nvs_char_cursor_id is NULL) THEN

                 l_nvs_char_cursor_id := DBMS_SQL.Open_Cursor;
                 /* Fix for bug#9678667 : Added the below hint */
                 l_dynamic_sql :=
                 'UPDATE /*+ index(EGO_ITM_USR_ATTR_INTRFC, EGO_ITM_USR_ATTR_INTRFC_N1) */ '||p_interface_table_name||'
                     SET ATTR_VALUE_STR = ATTR_DISP_VALUE
                   WHERE DATA_SET_ID = :data_set_id
                     AND (PROCESS_STATUS = '||G_PS_IN_PROCESS||' OR PROCESS_STATUS > '||G_PS_BAD_ATTR_OR_AG_METADATA||' )
                     AND BITAND(PROCESS_STATUS, '||G_PS_NO_PRIVILEGES||') = 0
                     AND ATTR_INT_NAME = :attr_internal_name
                     AND ATTR_GROUP_INT_NAME = :attr_group_int_name
                     AND ATTR_DISP_VALUE IS NOT NULL';

                 DBMS_SQL.Parse(l_nvs_char_cursor_id, l_dynamic_sql, DBMS_SQL.NATIVE);
                 DBMS_SQL.Bind_Variable(l_nvs_char_cursor_id, ':data_set_id', p_data_set_id);

               END IF;

               DBMS_SQL.Bind_Variable(l_nvs_char_cursor_id, ':attr_group_int_name', l_attr_metadata_rec(l_var).ATTR_GROUP_INT_NAME);
               DBMS_SQL.Bind_Variable(l_nvs_char_cursor_id, ':attr_internal_name', l_attr_metadata_rec(l_var).ATTR_INT_NAME);

               l_dummy := DBMS_SQL.Execute(l_nvs_char_cursor_id);

             END IF;
           END IF;

           --------------------------------------------------------------------------
           -- HERE WE UPDATE THE INTERFACE TABLE ERRORING OUT ALL THE ROWS HAVING  --
           -- ATTRIBUTE DATA HAVING LENGTH GREATER THAN THE MAXIMUM ALLOWED LENGTH --
           -- WE DO THIS CHECK ONLY FOR NUMBER, CHAR AND DATE/DATETIME DATA TYPE   --
           --------------------------------------------------------------------------

                 -- swuppala: START : bug fix 12907500 There is no validation  on data type before setting the maximum value. Hence transalatable text which execeeds 150 size is erroring out.
      -- with ora-06502: pl/sql: numeric or value error: character string
        IF (l_attr_metadata_rec(l_var).MAXIMUM_SIZE IS NULL OR l_attr_metadata_rec(l_var).MAXIMUM_SIZE = 0) THEN
          IF(l_attr_metadata_rec(l_var).DATA_TYPE = EGO_EXT_FWK_PUB.G_CHAR_DATA_TYPE) THEN
            l_attr_metadata_rec(l_var).MAXIMUM_SIZE := 150;  -- 150 is the default Max length of UDA per functional design
          ELSIF(l_attr_metadata_rec(l_var).DATA_TYPE = EGO_EXT_FWK_PUB.G_TRANS_TEXT_DATA_TYPE) THEN
            l_attr_metadata_rec(l_var).MAXIMUM_SIZE := 1000;  -- 1000 is the default Max length of Translatable text type UDA.
          END IF;
        END IF;

      -- swuppala : END :  bug fix 12907500

           IF (l_attr_metadata_rec(l_var).MAXIMUM_SIZE > 0) THEN

             code_debug('          This attribute has a maximum size of '||l_attr_metadata_rec(l_var).MAXIMUM_SIZE,2);

             --------- FOR NUMBER DATATYPE
             IF (l_attr_metadata_rec(l_var).DATA_TYPE = EGO_EXT_FWK_PUB.G_NUMBER_DATA_TYPE) THEN
               IF (l_max_size_num_cursor IS NULL) THEN
                 l_max_size_num_cursor := DBMS_SQL.Open_Cursor;
                 l_dynamic_sql :=
                 'UPDATE '||p_interface_table_name||'
                     SET PROCESS_STATUS = PROCESS_STATUS + '||G_PS_MAX_LENGTH_VIOLATION||'
                     WHERE DATA_SET_ID = :data_set_id
                       AND (PROCESS_STATUS = '||G_PS_IN_PROCESS||' OR PROCESS_STATUS > '||G_PS_BAD_ATTR_OR_AG_METADATA||' )
                       AND BITAND(PROCESS_STATUS, '||G_PS_NO_PRIVILEGES||') = 0
                       AND ATTR_INT_NAME = :attr_internal_name
                       AND ATTR_GROUP_INT_NAME = :attr_group_int_name
                       AND ATTR_VALUE_NUM IS NOT NULL
                       AND LENGTH(ATTR_VALUE_NUM) > :max_allowed_size';
                   DBMS_SQL.Parse(l_max_size_num_cursor, l_dynamic_sql, DBMS_SQL.NATIVE);
                   DBMS_SQL.Bind_Variable(l_max_size_num_cursor, ':data_set_id', p_data_set_id);

               END IF;

               DBMS_SQL.Bind_Variable(l_max_size_num_cursor, ':attr_group_int_name', l_attr_metadata_rec(l_var).ATTR_GROUP_INT_NAME);
               DBMS_SQL.Bind_Variable(l_max_size_num_cursor, ':attr_internal_name', l_attr_metadata_rec(l_var).ATTR_INT_NAME);
               DBMS_SQL.Bind_Variable(l_max_size_num_cursor, ':max_allowed_size', l_attr_metadata_rec(l_var).MAXIMUM_SIZE);
               l_dummy := DBMS_SQL.Execute(l_max_size_num_cursor);
             --------- FOR CHAR OR TRANSLATEBLE TEXT DATATYPE
             ELSIF(l_attr_metadata_rec(l_var).DATA_TYPE = EGO_EXT_FWK_PUB.G_CHAR_DATA_TYPE OR
                   l_attr_metadata_rec(l_var).DATA_TYPE = EGO_EXT_FWK_PUB.G_TRANS_TEXT_DATA_TYPE) THEN

               IF ( l_max_size_char_cursor IS NULL) THEN
                 l_max_size_char_cursor := DBMS_SQL.Open_Cursor;
                 l_dynamic_sql :=
                 'UPDATE '||p_interface_table_name||'
                     SET PROCESS_STATUS = PROCESS_STATUS + '||G_PS_MAX_LENGTH_VIOLATION||'
                     WHERE DATA_SET_ID = :data_set_id
                       AND (PROCESS_STATUS = '||G_PS_IN_PROCESS||' OR PROCESS_STATUS > '||G_PS_BAD_ATTR_OR_AG_METADATA||' )
                       AND BITAND(PROCESS_STATUS, '||G_PS_NO_PRIVILEGES||') = 0
                       AND ATTR_INT_NAME = :attr_internal_name
                       AND ATTR_GROUP_INT_NAME = :attr_group_int_name
                       AND ATTR_VALUE_STR IS NOT NULL
                       AND LENGTHB(ATTR_VALUE_STR) > :max_allowed_size'; --for bug 9748517, use byte size to determin size for multi-byte language
                   DBMS_SQL.Parse(l_max_size_char_cursor, l_dynamic_sql, DBMS_SQL.NATIVE);
                   DBMS_SQL.Bind_Variable(l_max_size_char_cursor, ':data_set_id', p_data_set_id);

               END IF;
               DBMS_SQL.Bind_Variable(l_max_size_char_cursor, ':attr_group_int_name', l_attr_metadata_rec(l_var).ATTR_GROUP_INT_NAME);
               DBMS_SQL.Bind_Variable(l_max_size_char_cursor, ':attr_internal_name', l_attr_metadata_rec(l_var).ATTR_INT_NAME);
               DBMS_SQL.Bind_Variable(l_max_size_char_cursor, ':max_allowed_size', l_attr_metadata_rec(l_var).MAXIMUM_SIZE);

               l_dummy := DBMS_SQL.Execute(l_max_size_char_cursor);

             END IF;
           END IF;

           --------------------------------------------------------------------------
           -- We need to see that the user has not entered data in a wrong column  --
           -- for an attribute. e.g for a number type attribute the data should    --
           -- only be in ATT_VALUE_NUM or ATTR_DISP_VALUE                          --
           --------------------------------------------------------------------------

           code_debug('          Before validating the rows for data in wrong column ' ,2);

           --------- FOR NUMBER DATATYPE
           IF(l_attr_metadata_rec(l_var).DATA_TYPE = EGO_EXT_FWK_PUB.G_NUMBER_DATA_TYPE) THEN
             IF (l_colcheck_num_cursor_id IS NULL) THEN
               l_colcheck_num_cursor_id := DBMS_SQL.Open_Cursor;
               l_dynamic_sql :=
               'UPDATE '||p_interface_table_name||'
                   SET PROCESS_STATUS = PROCESS_STATUS + '||G_PS_DATA_IN_WRONG_COL||'
                 WHERE DATA_SET_ID = :data_set_id
                   AND (PROCESS_STATUS = '||G_PS_IN_PROCESS||' OR PROCESS_STATUS > '||G_PS_BAD_ATTR_OR_AG_METADATA||' )
                   AND BITAND(PROCESS_STATUS, '||G_PS_NO_PRIVILEGES||') = 0
                   AND ATTR_INT_NAME = :attr_internal_name
                   AND ATTR_GROUP_INT_NAME = :attr_group_int_name
                   AND ATTR_VALUE_NUM IS NULL
                   AND ATTR_DISP_VALUE IS NULL
                   AND (ATTR_VALUE_STR IS NOT NULL OR ATTR_VALUE_DATE IS NOT NULL)' ;
               DBMS_SQL.Parse(l_colcheck_num_cursor_id, l_dynamic_sql, DBMS_SQL.NATIVE);
               DBMS_SQL.Bind_Variable(l_colcheck_num_cursor_id, ':data_set_id', p_data_set_id);
             END IF;

             DBMS_SQL.Bind_Variable(l_colcheck_num_cursor_id, ':attr_group_int_name', l_attr_metadata_rec(l_var).ATTR_GROUP_INT_NAME);
             DBMS_SQL.Bind_Variable(l_colcheck_num_cursor_id, ':attr_internal_name', l_attr_metadata_rec(l_var).ATTR_INT_NAME);

             l_dummy := DBMS_SQL.Execute(l_colcheck_num_cursor_id);

           --------- FOR DATE/DATETIME DATATYPE
           ELSIF (l_attr_metadata_rec(l_var).DATA_TYPE = EGO_EXT_FWK_PUB.G_DATE_DATA_TYPE OR l_attr_metadata_rec(l_var).DATA_TYPE = EGO_EXT_FWK_PUB.G_DATE_TIME_DATA_TYPE) THEN
             IF (l_colcheck_date_cursor_id IS NULL) THEN
               l_colcheck_date_cursor_id := DBMS_SQL.Open_Cursor;
               l_dynamic_sql :=
               'UPDATE '||p_interface_table_name||'
                   SET PROCESS_STATUS = PROCESS_STATUS + '||G_PS_DATA_IN_WRONG_COL||'
                 WHERE DATA_SET_ID = :data_set_id
                   AND (PROCESS_STATUS = '||G_PS_IN_PROCESS||' OR PROCESS_STATUS > '||G_PS_BAD_ATTR_OR_AG_METADATA||' )
                   AND BITAND(PROCESS_STATUS, '||G_PS_NO_PRIVILEGES||') = 0
                   AND ATTR_INT_NAME = :attr_internal_name
                   AND ATTR_GROUP_INT_NAME = :attr_group_int_name
                   AND ATTR_VALUE_DATE IS NULL
                   AND ATTR_DISP_VALUE IS NULL
                   AND (ATTR_VALUE_STR IS NOT NULL OR ATTR_VALUE_NUM IS NOT NULL)' ;
               DBMS_SQL.Parse(l_colcheck_date_cursor_id, l_dynamic_sql, DBMS_SQL.NATIVE);
               DBMS_SQL.Bind_Variable(l_colcheck_date_cursor_id, ':data_set_id', p_data_set_id);
             END IF;

             DBMS_SQL.Bind_Variable(l_colcheck_date_cursor_id, ':attr_group_int_name', l_attr_metadata_rec(l_var).ATTR_GROUP_INT_NAME);
             DBMS_SQL.Bind_Variable(l_colcheck_date_cursor_id, ':attr_internal_name', l_attr_metadata_rec(l_var).ATTR_INT_NAME);

             l_dummy := DBMS_SQL.Execute(l_colcheck_date_cursor_id);
           --------- FOR CHAR/TRANSLATEBLE TEXT DATATYPE
           ELSE
             IF (l_colcheck_char_cursor_id IS NULL) THEN
               l_colcheck_char_cursor_id := DBMS_SQL.Open_Cursor;
               /* Fix for bug#9678667 - Added below hint */
               l_dynamic_sql :=
               'UPDATE /*+ index(EGO_ITM_USR_ATTR_INTRFC, EGO_ITM_USR_ATTR_INTRFC_N1) NO_EXPAND */ '||p_interface_table_name||'
                   SET PROCESS_STATUS = PROCESS_STATUS + '||G_PS_DATA_IN_WRONG_COL||'
                 WHERE DATA_SET_ID = :data_set_id
                   AND (PROCESS_STATUS = '||G_PS_IN_PROCESS||' OR PROCESS_STATUS > '||G_PS_BAD_ATTR_OR_AG_METADATA||' )
                   AND BITAND(PROCESS_STATUS, '||G_PS_NO_PRIVILEGES||') = 0
                   AND ATTR_INT_NAME = :attr_internal_name
                   AND ATTR_GROUP_INT_NAME = :attr_group_int_name
                   AND ATTR_VALUE_STR IS NULL
                   AND ATTR_DISP_VALUE IS NULL
                   AND (ATTR_VALUE_NUM IS NOT NULL OR ATTR_VALUE_DATE IS NOT NULL)' ;
               DBMS_SQL.Parse(l_colcheck_char_cursor_id, l_dynamic_sql, DBMS_SQL.NATIVE);
               DBMS_SQL.Bind_Variable(l_colcheck_char_cursor_id, ':data_set_id', p_data_set_id);
             END IF;

             DBMS_SQL.Bind_Variable(l_colcheck_char_cursor_id, ':attr_group_int_name', l_attr_metadata_rec(l_var).ATTR_GROUP_INT_NAME);
             DBMS_SQL.Bind_Variable(l_colcheck_char_cursor_id, ':attr_internal_name', l_attr_metadata_rec(l_var).ATTR_INT_NAME);

             l_dummy := DBMS_SQL.Execute(l_colcheck_char_cursor_id);

           END IF;

        END IF; -- if not previously processed
      END IF; --*p_validate-IF-1.5*   Ending the IF for p_validate

      IF (p_do_dml AND l_priv_attr_id <> l_attr_metadata_rec(l_var).ATTR_ID) THEN
        IF(l_attr_metadata_rec(l_var).UOM_CLASS IS NOT NULL) THEN
          ----------------------------------------------
          -- Converting the attr value to base UOM
          ----------------------------------------------

          l_dynamic_sql :=
          'UPDATE '||p_interface_table_name||' INTF
              SET ATTR_VALUE_NUM = ATTR_VALUE_NUM * NVL((SELECT CONVERSION_RATE FROM MTL_UOM_CONVERSIONS
                                                      WHERE UOM_CLASS = :uom_class
                                                        AND UOM_CODE = INTF.ATTR_VALUE_UOM
                                                        AND ROWNUM = 1),1)
            WHERE DATA_SET_ID = :data_set_id
              AND PROCESS_STATUS = '||G_PS_IN_PROCESS||'
              AND ATTR_INT_NAME = :attr_internal_name
              AND ATTR_GROUP_INT_NAME = :attr_group_int_name
              AND ATTR_VALUE_UOM <> :base_uom ';

          EXECUTE IMMEDIATE l_dynamic_sql
          USING l_attr_metadata_rec(l_var).UOM_CLASS, p_data_Set_id,l_attr_metadata_rec(l_var).ATTR_INT_NAME,
                l_attr_metadata_rec(l_var).ATTR_GROUP_INT_NAME,l_attr_metadata_rec(l_var).UOM_CODE;
        END IF;
      END IF;
      l_priv_attr_id := l_attr_metadata_rec(l_var).ATTR_ID;

    END LOOP;--End 1st loop
    -- Fix for bug#9336604
    -- CLOSE l_dynamic_cursor;

    code_debug('          After the ATTR LEVEL validation loop ' ,1);

    -- CLOSING ALL OPEN CURSORS
    IF (l_priv_func_cursor_id IS NOT NULL) THEN
      DBMS_SQL.Close_Cursor(l_priv_func_cursor_id);
    END IF;
    IF (l_ivs_num_cursor_id IS NOT NULL) THEN
      DBMS_SQL.Close_Cursor(l_ivs_num_cursor_id);
    END IF;
    IF (l_ivs_date_cursor_id IS NOT NULL) THEN
      DBMS_SQL.Close_Cursor(l_ivs_date_cursor_id);
    END IF;
    IF (l_ivs_date_time_cursor_id IS NOT NULL) THEN
      DBMS_SQL.Close_Cursor(l_ivs_date_time_cursor_id);
    END IF;
    IF (l_ivs_char_cursor_id IS NOT NULL) THEN
      DBMS_SQL.Close_Cursor(l_ivs_char_cursor_id);
    END IF;
    IF (l_nvs_num_cursor_id IS NOT NULL) THEN
      DBMS_SQL.Close_Cursor(l_nvs_num_cursor_id);
    END IF;
    IF (l_nvs_date_cursor_id IS NOT NULL) THEN
      DBMS_SQL.Close_Cursor(l_nvs_date_cursor_id);
    END IF;
    IF (l_nvs_datetime_cursor_id IS NOT NULL) THEN
      DBMS_SQL.Close_Cursor(l_nvs_datetime_cursor_id);
    END IF;
    IF (l_nvs_char_cursor_id IS NOT NULL) THEN
      DBMS_SQL.Close_Cursor(l_nvs_char_cursor_id);
    END IF;
    IF (l_max_size_char_cursor IS NOT NULL) THEN
      DBMS_SQL.Close_Cursor(l_max_size_char_cursor);
    END IF;
    IF (l_max_size_num_cursor IS NOT NULL) THEN
      DBMS_SQL.Close_Cursor(l_max_size_num_cursor);
    END IF;
    IF (l_colcheck_num_cursor_id IS NOT NULL) THEN
      DBMS_SQL.Close_Cursor(l_colcheck_num_cursor_id);
    END IF;
    IF (l_colcheck_char_cursor_id IS NOT NULL) THEN
      DBMS_SQL.Close_Cursor(l_colcheck_char_cursor_id);
    END IF;
    IF (l_colcheck_date_cursor_id IS NOT NULL) THEN
      DBMS_SQL.Close_Cursor(l_colcheck_date_cursor_id);
    END IF;

    IF (p_validate) THEN -- *p_validate-IF-1.75*
    -------------------------------------------------------------------------------------
    -- Update other attributes if at least one attribute is failed for all attr group
    -------------------------------------------------------------------------------------
     --considering the G_PS_BAD_ATTR_OR_AG_METADATA is the starting point for the intermittent errors.

     /* Fix for bug#9678667 - Start */
     /*
      EXECUTE IMMEDIATE
            'UPDATE '||p_interface_table_name||' UAI1' ||
                ' SET UAI1.PROCESS_STATUS = UAI1.PROCESS_STATUS + '||G_PS_OTHER_ATTRS_INVALID||
                ' WHERE UAI1.DATA_SET_ID = :data_set_id '||
                ' AND BITAND(PROCESS_STATUS,'||G_PS_OTHER_ATTRS_INVALID||') = 0'||
                ' AND UAI1.ROW_IDENTIFIER  IN'||
                '     (SELECT DISTINCT UAI2.ROW_IDENTIFIER'||
                '        FROM '||p_interface_table_name||' UAI2'||
                '        WHERE UAI2.DATA_SET_ID = :data_set_id '||
                '         AND UAI2.PROCESS_STATUS >= '||G_PS_BAD_ATTR_OR_AG_METADATA ||
                '         AND UAI2.ATTR_GROUP_INT_NAME = UAI1.ATTR_GROUP_INT_NAME)'
      USING p_data_set_id, p_data_set_id;
      */

      EXECUTE IMMEDIATE
            'UPDATE '||p_interface_table_name||' UAI1' ||
                ' SET UAI1.PROCESS_STATUS = UAI1.PROCESS_STATUS + '||G_PS_OTHER_ATTRS_INVALID||
                ' WHERE UAI1.DATA_SET_ID = :data_set_id '||
                ' AND BITAND(PROCESS_STATUS,'||G_PS_OTHER_ATTRS_INVALID||') = 0'||
                ' AND (UAI1.ROW_IDENTIFIER, UAI1.ATTR_GROUP_INT_NAME)  IN '||
                '       (SELECT /*+ UNNEST CARDINALITY(UAI2,10) INDEX(UAI2,EGO_ITM_USR_ATTR_INTRFC_N3) */ '|| /* Bug 9678667 */
                '           UAI2.ROW_IDENTIFIER, UAI2.ATTR_GROUP_INT_NAME '||
                '        FROM '||p_interface_table_name||' UAI2'||
                '        WHERE UAI2.DATA_SET_ID = :data_set_id '||
                '           AND UAI2.PROCESS_STATUS >= '||G_PS_BAD_ATTR_OR_AG_METADATA ||
                '      )'
      USING p_data_set_id, p_data_set_id;
      /* Fix for bug#9678667 - End */

    END IF; --*p_validate-IF-1.75*   Ending the IF for p_validate


                  --===========================--
                  -- AG-LEVEL LOOP VALIDATIONS --
                  --===========================--
    code_debug(' Before entering the Attr Group Level Validation Loop ' ,1);
    ------------------------------------------------
    -- Now we fetch all distinct Attr Groups that --
    -- still have valid rows in the data set      --
    ------------------------------------------------
    OPEN l_dynamic_dist_ag_cursor FOR
        ' SELECT DISTINCT ATTR_GROUP_INT_NAME
            FROM '||p_interface_table_name||' UAI1
           WHERE DATA_SET_ID = :data_set_id
             AND ATTR_GROUP_TYPE = :attr_group_type
             AND (UAI1.PROCESS_STATUS = '||G_PS_IN_PROCESS||' OR UAI1.PROCESS_STATUS > '||G_PS_BAD_ATTR_OR_AG_METADATA||' )'
    USING p_data_set_id, p_attr_group_type;
    LOOP
      FETCH l_dynamic_dist_ag_cursor INTO l_attr_group_intf_rec;
      EXIT WHEN l_dynamic_dist_ag_cursor%NOTFOUND;

      code_debug('----------Inside Attribute Group level validation loop: processing Attribute Group-'||l_attr_group_intf_rec.ATTR_GROUP_INT_NAME||'-'||p_attr_group_type ,2);

      l_do_dml_for_this_ag := true;

      l_attr_group_metadata_obj := EGO_USER_ATTRS_COMMON_PVT.Get_Attr_Group_Metadata(
                                     p_attr_group_id   => NULL
                                    ,p_application_id  => p_application_id
                                    ,p_attr_group_type => p_attr_group_type
                                    ,p_attr_group_name => l_attr_group_intf_rec.ATTR_GROUP_INT_NAME
                                   );

      l_attr_metadata_table := l_attr_group_metadata_obj.ATTR_METADATA_TABLE;
      l_attr_metadata_table_sr := l_attr_group_metadata_obj.ATTR_METADATA_TABLE;
      l_attr_metadata_table_1 := l_attr_group_metadata_obj.ATTR_METADATA_TABLE;

      code_debug('          After the required and defaulting validations ' ,2);

      --------------------------------------------------------
      -- in this loop we do the MR specific validations
      -- these are basically the ones which require UK's
      --------------------------------------------------------
      IF (l_attr_group_metadata_obj.MULTI_ROW_CODE = 'Y') THEN

        code_debug('          This attribute group is a multi-row attribute group, reached inside the MR specific validation loop ', 2);
        -------------------------------------------
        -- at the end of this loop we will get the query
        -- to identify a row in the EXT table
        -- with the UK's
        -------------------------------------------
        l_ext_table_select := '  '||l_ext_vl_name ||
        ' EXTVL1 WHERE EXTVL1.ATTR_GROUP_ID='||l_attr_group_metadata_obj.ATTR_GROUP_ID||' ';
/*
TO DO: Dylan hard-coded the AG ID, because there's already so much hard-coding
going on.  But ultimately this is incorrect; everything needs to be bind variables.
*/

        --LOOP THROUGH ALL THE ATTRS METADATA FOR THIS AG
        FOR i IN l_attr_metadata_table.FIRST .. l_attr_metadata_table.LAST
        LOOP
          IF (l_attr_metadata_table(i).UNIQUE_KEY_FLAG = 'Y' ) THEN

            --IF ( l_attr_metadata_table(i).DATA_TYPE_CODE <> EGO_EXT_FWK_PUB.G_TRANS_TEXT_DATA_TYPE OR 1=1) THEN
              --GNANDA : Since now we are supporting TL UK's we do not need to error out the AG rows with
              --TL attrs as UK's in them.
              IF (l_attr_metadata_table(i).DATA_TYPE_CODE = EGO_EXT_FWK_PUB.G_NUMBER_DATA_TYPE ) THEN
                l_intf_column_name := ' ATTR_VALUE_NUM ';
                wierd_constant := G_NULL_TOKEN_NUM;
              ELSIF (l_attr_metadata_table(i).DATA_TYPE_CODE = EGO_EXT_FWK_PUB.G_DATE_DATA_TYPE OR l_attr_metadata_table(i).DATA_TYPE_CODE = EGO_EXT_FWK_PUB.G_DATE_TIME_DATA_TYPE ) THEN
                l_intf_column_name := ' ATTR_VALUE_DATE ';
                wierd_constant := G_NULL_TOKEN_DATE;
              ELSE
                l_intf_column_name := ' ATTR_VALUE_STR ';
                wierd_constant := G_NULL_TOKEN_STR;
              END IF;

              l_intf_tbl_select :=
              ' (SELECT '||l_intf_column_name||' FROM '||p_interface_table_name||
                ' WHERE DATA_SET_ID = '||p_data_set_id||
                  ' AND ATTR_GROUP_INT_NAME = '''||
                        l_attr_group_metadata_obj.ATTR_GROUP_NAME||
                ''' AND ATTR_INT_NAME = '''||
                        l_attr_metadata_table(i).ATTR_NAME||
                ''' AND ROW_IDENTIFIER = UAI1.ROW_IDENTIFIER';

              l_intf_tbl_select := l_intf_tbl_select || ')';

              l_ext_table_select := l_ext_table_select || ' AND NVL(EXTVL1.'||l_attr_metadata_table(i).DATABASE_COLUMN||','||wierd_constant||') = NVL('||l_intf_tbl_select||','||wierd_constant||')';
            /*
            ELSE
              l_dynamic_sql :=
                 'UPDATE '||p_interface_table_name||'
                  SET PROCESS_STATUS = PROCESS_STATUS + '||G_PS_TL_COL_IS_A_UK||'
                WHERE DATA_SET_ID = :data_set_id
                  AND PROCESS_STATUS <> 3
                  AND BITAND(PROCESS_STATUS, '||G_PS_NO_PRIVILEGES||') = 0
                  AND ATTR_GROUP_INT_NAME = :attr_group_int_name ';

              EXECUTE IMMEDIATE l_dynamic_sql
              USING p_data_set_id, l_attr_group_metadata_obj.ATTR_GROUP_NAME;

              l_do_dml_for_this_ag := false;

            END IF;
            */
          END IF;
        END LOOP;

        IF (l_pk1_column_name IS NOT NULL) THEN
          l_ext_table_select := l_ext_table_select || ' AND EXTVL1.'||l_pk1_column_name||' = UAI1.'||l_pk1_column_name;
        END IF;
        IF (l_pk2_column_name IS NOT NULL) THEN
          l_ext_table_select := l_ext_table_select || ' AND EXTVL1.'||l_pk2_column_name||' = UAI1.'||l_pk2_column_name;
        END IF;
        IF (l_pk3_column_name IS NOT NULL) THEN
          l_ext_table_select := l_ext_table_select || ' AND EXTVL1.'||l_pk3_column_name||' = UAI1.'||l_pk3_column_name;
        END IF;
        IF (l_pk4_column_name IS NOT NULL) THEN
          l_ext_table_select := l_ext_table_select || ' AND EXTVL1.'||l_pk4_column_name||' = UAI1.'||l_pk4_column_name;
        END IF;
        IF (l_pk5_column_name IS NOT NULL) THEN
          l_ext_table_select := l_ext_table_select || ' AND EXTVL1.'||l_pk5_column_name||' = UAI1.'||l_pk5_column_name;
        END IF;

        -- adding datalevel columns to the query
        IF(l_data_level_col_exists) THEN
          l_ext_table_select := l_ext_table_select || ' AND NVL(EXTVL1.DATA_LEVEL_ID,'||G_NULL_TOKEN_NUM||') '||
                                                            '   = NVL(UAI1.DATA_LEVEL_ID,'||G_NULL_TOKEN_NUM||')';

          FOR i IN l_list_of_dl_for_ag_type.FIRST .. l_list_of_dl_for_ag_type.LAST
          LOOP

             IF (l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME1 IS NOT NULL AND l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME1 <> 'NONE'
                AND INSTR(l_ext_table_select,l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME1) = 0) THEN

                     IF(l_list_of_dl_for_ag_type(i).PK_COLUMN_TYPE1 = 'NUMBER') THEN
                       wierd_constant := G_NULL_TOKEN_NUM;
                     ELSIF (l_list_of_dl_for_ag_type(i).PK_COLUMN_TYPE1 = 'DATE' OR l_list_of_dl_for_ag_type(i).PK_COLUMN_TYPE1 = 'DATETIME') THEN
                       wierd_constant := G_NULL_TOKEN_DATE;
                     ELSE
                       wierd_constant := G_NULL_TOKEN_STR;
                     END IF;

                     l_ext_table_select := l_ext_table_select || ' AND NVL(EXTVL1.'||l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME1||','||wierd_constant||') '||
                                                                       '   = NVL(UAI1.'||l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME1||','||wierd_constant||')';
             END IF;
             IF (l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME2 IS NOT NULL AND l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME2 <> 'NONE'
                AND INSTR(l_ext_table_select,l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME2) = 0) THEN
                     IF(l_list_of_dl_for_ag_type(i).PK_COLUMN_TYPE2 = 'NUMBER') THEN
                       wierd_constant := G_NULL_TOKEN_NUM;
                     ELSIF (l_list_of_dl_for_ag_type(i).PK_COLUMN_TYPE2 = 'DATE' OR l_list_of_dl_for_ag_type(i).PK_COLUMN_TYPE2 = 'DATETIME') THEN
                       wierd_constant := G_NULL_TOKEN_DATE;
                     ELSE
                       wierd_constant := G_NULL_TOKEN_STR;
                     END IF;
                     l_ext_table_select := l_ext_table_select || ' AND NVL(EXTVL1.'||l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME2||','||wierd_constant||') '||
                                                                       '   = NVL(UAI1.'||l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME2||','||wierd_constant||')';
             END IF;
             IF (l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME3 IS NOT NULL AND l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME3 <> 'NONE'
                AND INSTR(l_ext_table_select,l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME3) = 0) THEN
                     IF(l_list_of_dl_for_ag_type(i).PK_COLUMN_TYPE3 = 'NUMBER') THEN
                       wierd_constant := G_NULL_TOKEN_NUM;
                     ELSIF (l_list_of_dl_for_ag_type(i).PK_COLUMN_TYPE3 = 'DATE' OR l_list_of_dl_for_ag_type(i).PK_COLUMN_TYPE3 = 'DATETIME') THEN
                       wierd_constant := G_NULL_TOKEN_DATE;
                     ELSE
                       wierd_constant := G_NULL_TOKEN_STR;
                     END IF;
                     l_ext_table_select := l_ext_table_select || ' AND NVL(EXTVL1.'||l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME3||','||wierd_constant||') '||
                                                                       '   = NVL(UAI1.'||l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME3||','||wierd_constant||')';
             END IF;
             IF (l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME4 IS NOT NULL AND l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME4 <> 'NONE'
                AND INSTR(l_ext_table_select,l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME4) = 0) THEN
                     IF(l_list_of_dl_for_ag_type(i).PK_COLUMN_TYPE4 = 'NUMBER') THEN
                       wierd_constant := G_NULL_TOKEN_NUM;
                     ELSIF (l_list_of_dl_for_ag_type(i).PK_COLUMN_TYPE4 = 'DATE' OR l_list_of_dl_for_ag_type(i).PK_COLUMN_TYPE4 = 'DATETIME') THEN
                       wierd_constant := G_NULL_TOKEN_DATE;
                     ELSE
                       wierd_constant := G_NULL_TOKEN_STR;
                     END IF;
                     l_ext_table_select := l_ext_table_select || ' AND NVL(EXTVL1.'||l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME4||','||wierd_constant||') '||
                                                                       '   = NVL(UAI1.'||l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME4||','||wierd_constant||')';
             END IF;
             IF (l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME5 IS NOT NULL AND l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME5 <> 'NONE'
                AND INSTR(l_ext_table_select,l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME5) = 0) THEN
                     IF(l_list_of_dl_for_ag_type(i).PK_COLUMN_TYPE5 = 'NUMBER') THEN
                       wierd_constant := G_NULL_TOKEN_NUM;
                     ELSIF (l_list_of_dl_for_ag_type(i).PK_COLUMN_TYPE5 = 'DATE' OR l_list_of_dl_for_ag_type(i).PK_COLUMN_TYPE5 = 'DATETIME') THEN
                       wierd_constant := G_NULL_TOKEN_DATE;
                     ELSE
                       wierd_constant := G_NULL_TOKEN_STR;
                     END IF;
                     l_ext_table_select := l_ext_table_select || ' AND NVL(EXTVL1.'||l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME5||','||wierd_constant||') '||
                                                                       '   = NVL(UAI1.'||l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME5||','||wierd_constant||')';
             END IF;
          END LOOP;
        ELSE

              IF (l_num_data_level_columns = 1) THEN
                l_ext_table_select := l_ext_table_select || ' AND NVL(EXTVL1.'||l_data_level_column_1||',-1) =  NVL(UAI1.'||l_data_level_column_1||',-1)';

              ELSIF (l_num_data_level_columns = 2) THEN
                l_ext_table_select := l_ext_table_select || ' AND NVL(EXTVL1.'||l_data_level_column_1||',-1) =  NVL(UAI1.'||l_data_level_column_1||',-1)';
                l_ext_table_select := l_ext_table_select || ' AND NVL(EXTVL1.'||l_data_level_column_2||',-1) =  NVL(UAI1.'||l_data_level_column_2||',-1)';

              ELSIF (l_num_data_level_columns = 3) THEN
                l_ext_table_select := l_ext_table_select || ' AND NVL(EXTVL1.'||l_data_level_column_1||',-1) =  NVL(UAI1.'||l_data_level_column_1||',-1)';
                l_ext_table_select := l_ext_table_select || ' AND NVL(EXTVL1.'||l_data_level_column_2||',-1) =  NVL(UAI1.'||l_data_level_column_2||',-1)';
                l_ext_table_select := l_ext_table_select || ' AND NVL(EXTVL1.'||l_data_level_column_3||',-1) =  NVL(UAI1.'||l_data_level_column_3||',-1)';
              END IF;


        END IF;

        code_debug('          The query generated for identifying the UKs is :'||l_ext_table_select ,3);

        ---------------------------------------------------------------
        -- We go on with the AG loop validations only if the         --
        -- API has been called with the parameter p_validate as TRUE --
        ---------------------------------------------------------------
        IF (p_validate = TRUE ) THEN --  search for  *p_validate-IF-2* for finding the end of this IF
        --------------------------------------------------------
        -- HERE WE DO THE TABLE VALUE SET VALIDATION FOR MR AG
        --------------------------------------------------------
        FOR y IN l_attr_metadata_table.FIRST .. l_attr_metadata_table.LAST
        LOOP
          IF (Attr_Is_In_Data_Set(l_attr_metadata_table(y),
                                  l_dist_attrs_in_data_set_table)) THEN
             l_attr_exists_in_intf := 'EXISTS';
          ELSE
            l_attr_exists_in_intf := 'NOTEXISTS';
          END IF;

          l_tvs_where_clause := ' ';
    --bug9846845, initialization the l_tvs_where_clause_clob
    l_tvs_where_clause_clob := ' ';
          IF (l_attr_exists_in_intf = 'EXISTS') THEN --WE DO THE TVC VALIDATION FOR SRAG ONLY IF THIS ATTR HAS ATLEAST ONE VALID INSTANCE IN THE INTF TABLE
            IF (l_attr_metadata_table(y).VALIDATION_CODE = EGO_EXT_FWK_PUB.G_TABLE_VALIDATION_CODE) THEN

              code_debug('          The attribute '||l_attr_metadata_table(y).ATTR_NAME||' has a table value set attached with value set id :'||l_attr_metadata_table(y).VALUE_SET_ID ,2);

              SELECT APPLICATION_TABLE_NAME,
                       VALUE_COLUMN_NAME,--VALUE_COLUMN_TYPE,VALUE_COLUMN_SIZE,
                       ID_COLUMN_NAME, --ID_COLUMN_TYPE, ID_COLUMN_SIZE,
                       MEANING_COLUMN_NAME, --MEANING_COLUMN_TYPE,
                       ADDITIONAL_WHERE_CLAUSE
                INTO   l_tvs_table_name,
                       l_tvs_val_col, --l_tvs_val_col_type, l_tvs_val_col_size,
                       l_tvs_id_col, --l_tvs_id_col_type, l_tvs_id_col_size
                       l_tvs_mean_col, --l_tvs_mean_col_type,
                       l_tvs_where_clause
                FROM FND_FLEX_VALIDATION_TABLES
               WHERE FLEX_VALUE_SET_ID = l_attr_metadata_table(y).VALUE_SET_ID;

        --By GEGUO for bug 9218013
        l_tvs_where_clause := trim(l_tvs_where_clause) || '  ';--BugFix:4609213: in case we have a bind at the end it fails because of the assimption mentioned below !
              IF (l_tvs_id_col IS NOT NULL) THEN
                 l_tvs_col := l_tvs_id_col;
              ELSE
                 l_tvs_col := l_tvs_val_col;
              END IF;


    -- abedajna Bug 6207675
                --if ( l_tvs_where_clause is not null ) then
                --  l_tvs_where_clause := '('||l_tvs_where_clause||')';
                --end if;
    -- abedajna Bug 6322809

    --bug 9646916 if additional whereclause simply start with ORDER BY don't do anything
    IF (INSTR(UPPER(LTRIM(l_tvs_where_clause)), 'ORDER ') <> 1) THEN
      l_tvs_where_clause := process_whereclause(l_tvs_where_clause);
    END IF;




              IF(INSTR(UPPER(LTRIM(l_tvs_where_clause)),'WHERE ')) = 1 THEN --BugFix : 4171705
                l_tvs_where_clause := SUBSTR(l_tvs_where_clause, INSTR(UPPER(l_tvs_where_clause),'WHERE ')+5 );
              ELSIF (INSTR(UPPER(LTRIM(l_tvs_where_clause)),'(WHERE ')) = 1 THEN  /*Added one more condition for bug 7508982*/
                l_tvs_where_clause := '('||SUBSTR(l_tvs_where_clause, INSTR(UPPER(l_tvs_where_clause),'WHERE ')+5 );
              END IF;

              ------------------------------------------------------
               -- In case the where clause has new line or tabs    --
               -- we need to remove it BugFix:4101091              --
               ------------------------------------------------------
               SELECT REPLACE(l_tvs_where_clause,FND_GLOBAL.LOCAL_CHR(10),FND_GLOBAL.LOCAL_CHR(32)) INTO l_tvs_where_clause FROM dual; --replacing new line character
               SELECT REPLACE(l_tvs_where_clause,FND_GLOBAL.LOCAL_CHR(13),FND_GLOBAL.LOCAL_CHR(32)) INTO l_tvs_where_clause FROM dual; --removing carriage return

              IF(INSTR(UPPER(l_tvs_where_clause),' ORDER ')) <> 0 THEN --Bug:4065857 gnanda we need to remove the order by clause if any in the where clause
                l_tvs_where_clause := SUBSTR(l_tvs_where_clause, 1 , INSTR(UPPER(l_tvs_where_clause),' ORDER '));
              END IF;

              IF(INSTR(UPPER(l_tvs_where_clause),')ORDER ')) <> 0 THEN --BugFix:6133202
                l_tvs_where_clause := SUBSTR(l_tvs_where_clause, 1 , INSTR(UPPER(l_tvs_where_clause),')ORDER '));
              END IF;


              IF(INSTR(UPPER(LTRIM(l_tvs_where_clause)),'ORDER ')) = 1 THEN --Bug:4065857 gnanda we need to remove the order by if where clause has only an order by
                l_tvs_where_clause := SUBSTR(l_tvs_where_clause, 1 , INSTR(UPPER(l_tvs_where_clause),' ORDER '));
                l_tvs_where_clause := ' 1=1 '|| l_tvs_where_clause;
              END IF;

              l_tvs_metadata_fetched := TRUE;
        --bug9846845, using l_tvs_where_clause_clob instead of l_tvs_where_clause to deal with following loop
        l_tvs_where_clause := l_tvs_where_clause || '  ';
        l_tvs_where_clause_clob := l_tvs_where_clause;


              --WHILE (INSTR(l_tvs_where_clause, ':$ATTRIBUTEGROUP$') > 0)
        WHILE (DBMS_LOB.INSTR(l_tvs_where_clause_clob, ':$ATTRIBUTEGROUP$') > 0)
              LOOP

                --l_attrname_start_index := INSTR(l_tvs_where_clause,':$ATTRIBUTEGROUP$') +18;
    l_attrname_start_index := DBMS_LOB.INSTR(l_tvs_where_clause_clob,':$ATTRIBUTEGROUP$') +18;
                -- NOTE: WE ASSUME THAT WE WILL HAVE A SPACE AFTER THE ATTR NAME (will look into this later)
                --l_attrname_end_index   := INSTR(l_tvs_where_clause,' ',l_attrname_start_index,1);
    l_attrname_end_index   := DBMS_LOB.INSTR(l_tvs_where_clause_clob,' ',l_attrname_start_index,1);

                --l_bind_attr_name := SUBSTR(l_tvs_where_clause,l_attrname_start_index,l_attrname_end_index-l_attrname_start_index);
    l_bind_attr_name := DBMS_LOB.SUBSTR(l_tvs_where_clause_clob,l_attrname_end_index-l_attrname_start_index,l_attrname_start_index);

                -- HERE WE GET THE COLNAME AND DATATYPE OF THE ATTRIBUTE USED AS BIND VARIABLE

                FOR k IN l_attr_metadata_table.FIRST .. l_attr_metadata_table.LAST
                LOOP
                  IF (l_attr_metadata_table(k).ATTR_NAME = l_bind_attr_name) THEN
                    l_ext_attr_col_name := l_attr_metadata_table(k).DATABASE_COLUMN;
                    l_bind_attr_data_type := l_attr_metadata_table(k).DATA_TYPE_CODE;
                  END IF;
                END LOOP;

                IF (l_ext_attr_col_name IS NULL OR l_bind_attr_data_type IS NULL) THEN
                  l_tvs_metadata_fetched := FALSE;
                ELSE
                  l_tvs_metadata_fetched := TRUE;
                END IF;

                -- we already have the query to identify the row for MR AG's using the UK's (l_ext_table_select)
                -- so we can use this query to find the value to bind from the production table.

                l_value_from_ext_table := ' (SELECT '|| l_ext_attr_col_name ||'
                                               FROM '||l_ext_table_select||'
                                                AND ATTR_GROUP_ID = UAI1.ATTR_GROUP_ID) ';

                IF (l_bind_attr_data_type = EGO_EXT_FWK_PUB.G_NUMBER_DATA_TYPE) THEN
                  l_value_from_intftbl := '(SELECT ATTR_VALUE_NUM FROM '||p_interface_table_name||'
                                            WHERE ROW_IDENTIFIER = UAI1.ROW_IDENTIFIER
                          AND DATA_SET_ID = '||p_data_set_id||'
                                              AND ATTR_INT_NAME = '''||l_bind_attr_name||''' )';
                ELSIF (l_bind_attr_data_type = EGO_EXT_FWK_PUB.G_DATE_DATA_TYPE  OR
                       l_bind_attr_data_type = EGO_EXT_FWK_PUB.G_DATE_TIME_DATA_TYPE) THEN
                  l_value_from_intftbl := '(SELECT ATTR_VALUE_DATE FROM '||p_interface_table_name||'
                                            WHERE ROW_IDENTIFIER = UAI1.ROW_IDENTIFIER
                          AND DATA_SET_ID = '||p_data_set_id||'
                                              AND ATTR_INT_NAME = '''||l_bind_attr_name||''' )';
                ELSE
                  l_value_from_intftbl := '(SELECT ATTR_VALUE_STR FROM '||p_interface_table_name||'
                                            WHERE ROW_IDENTIFIER = UAI1.ROW_IDENTIFIER
                          AND DATA_SET_ID = '||p_data_set_id||'
                                              AND ATTR_INT_NAME = '''||l_bind_attr_name||''' )';
                END IF;
                -- now we replace the :$ATTRIBUTEGROUP$.attrname with the query to find the value.

                -- Bug 10151142 : Start
                l_tvs_string_length  := DBMS_LOB.INSTR(l_tvs_where_clause_clob, ':$ATTRIBUTEGROUP$')-1;

                l_offset := 1;
                l_tvs_where_clause_clob1 := '';
                l_amount := 8191;

                WHILE l_offset <= l_tvs_string_length LOOP
                  l_buffer := '';

                  IF ( l_tvs_string_length > l_amount) THEN
                    l_tvs_colb_length_diff := l_tvs_string_length - l_offset +1;

                    IF (l_tvs_colb_length_diff >= l_amount) THEN
                      dbms_lob.read(l_tvs_where_clause_clob, l_amount, l_offset, l_buffer);
                      l_offset := l_offset + l_amount;
                    ELSE
                      dbms_lob.read(l_tvs_where_clause_clob, l_tvs_colb_length_diff, l_offset, l_buffer);
                      l_offset := l_offset + l_tvs_colb_length_diff;
                    END IF;
                  ELSE
                    dbms_lob.read(l_tvs_where_clause_clob, l_tvs_string_length, l_offset, l_buffer);
                    l_offset := l_offset + l_tvs_string_length;
                  END IF;

                  l_tvs_where_clause_clob1 := l_tvs_where_clause_clob1||l_buffer;
                END LOOP;

                l_offset := 1;
                l_clob_length := DBMS_LOB.GETLENGTH(l_tvs_where_clause_clob) - l_attrname_end_index;
                l_amount := 32767;
                l_tvs_where_clause_clob2 := '';

                WHILE l_offset <= l_clob_length LOOP
                  l_tvs_where_clause_buffer := '';
                  dbms_lob.read(l_tvs_where_clause_clob, l_amount, (l_attrname_end_index + (l_offset - 1)), l_tvs_where_clause_buffer);
                  l_tvs_where_clause_clob2 := l_tvs_where_clause_clob2 || l_tvs_where_clause_buffer;
                  l_offset := l_offset + l_amount;
                END loop;

                l_tvs_where_clause_clob := l_tvs_where_clause_clob1 ||'(NVL('||l_value_from_intftbl||',
                                                    DECODE(UAI1.TRANSACTION_TYPE, ''UPDATE'','||l_value_from_ext_table||'
                                                    ,''CREATE'',NULL
                                                    , ''SYNC'','||l_value_from_ext_table||'
                                                    ,NULL)
                                                   )
                                               )'||
                                               l_tvs_where_clause_clob2;

                /*l_tvs_where_clause_clob := DBMS_LOB.SUBSTR(l_tvs_where_clause_clob,DBMS_LOB.INSTR(l_tvs_where_clause_clob, ':$ATTRIBUTEGROUP$')-1,1) ||
                                           '(NVL('||l_value_from_intftbl||',
                                                    DECODE(UAI1.TRANSACTION_TYPE, ''UPDATE'','||l_value_from_ext_table||'
                                                    ,''CREATE'',NULL
                                                    , ''SYNC'','||l_value_from_ext_table||'
                                                    ,NULL)
                                                   )
                                               )'||
                                             DBMS_LOB.SUBSTR(l_tvs_where_clause_clob,DBMS_LOB.GETLENGTH(l_tvs_where_clause_clob), l_attrname_end_index);
                */
                -- Bug 10151142 : End
              END LOOP;

              WHILE (DBMS_LOB.INSTR(l_tvs_where_clause_clob, ':$OBJECT$') > 0)
              LOOP
                SELECT REPLACE(l_tvs_where_clause_clob,':$OBJECT$','UAI1') INTO l_tvs_where_clause_clob FROM DUAL;
              END LOOP;

        -- l_tvs_where_clause := l_tvs_where_clause_clob; -- Bug 10151142 : Commented
        --end of bug9846845

      /*
      NOTE ...
      THERE COULD BE A POSSIBILITY THAT THE TVS QUERY RETURNS MORE THAN ONE ROWS
      IN THIS CASE WE JUST TAKE THE FIRST ROW : ( i.e. WHERE ROWNUM = 1)
      */
              /* Bug 10151142 : Start
                  Use l_tvs_where_clause_clob instead of l_tvs_where_clause
                  Use l_tvs_select_clob instead of l_tvs_select
                  Use l_tvs_num_val_check_sel_clob instead of l_tvs_num_val_check_select
                  Use l_tvs_date_val_check_sel_clob instead of l_tvs_date_val_check_select
                  Use l_tvs_str_val_check_sel_clob instead of l_tvs_str_val_check_select
              */
              l_tvs_where_clause_clob := RTRIM(LTRIM(l_tvs_where_clause_clob));

              IF LENGTH(l_tvs_where_clause_clob)<3 OR LENGTH(l_tvs_where_clause_clob) IS NULL THEN                 --added for bugFix:4609213
                l_tvs_where_clause_clob := ' 1=1 '||l_tvs_where_clause_clob;
              END IF;

              l_tvs_select_clob := '(SELECT DISTINCT '||l_tvs_col||' FROM '||l_tvs_table_name||'
                                 WHERE '||l_tvs_where_clause_clob||'
                                   AND ROWNUM = 1
                       AND '||l_tvs_val_col||' = UAI1.ATTR_DISP_VALUE )';

              l_tvs_num_val_check_sel_clob := '(SELECT COUNT(*) FROM '||l_tvs_table_name||'
                                 WHERE '||l_tvs_where_clause_clob||'
                                   AND ROWNUM = 1
                       AND '||l_tvs_col||' = UAI1.ATTR_VALUE_NUM )';

              l_tvs_date_val_check_sel_clob := '(SELECT COUNT(*) FROM '||l_tvs_table_name||'
                                 WHERE '||l_tvs_where_clause_clob||'
                                   AND ROWNUM = 1
                       AND '||l_tvs_col||' = UAI1.ATTR_DATE_VALUE )';

              l_tvs_str_val_check_sel_clob := '(SELECT COUNT(*) FROM '||l_tvs_table_name||'
                                 WHERE '||l_tvs_where_clause_clob||'
                                   AND ROWNUM = 1
                       AND '||l_tvs_col||' = UAI1.ATTR_VALUE_STR )';

              -- code_debug('          The TVS query constructed is :'||l_tvs_select ,3);
              code_debug('          The Length of TVS query constructed is :'||dbms_lob.getlength(l_tvs_select_clob), 3);
              code_debug('          The TVS query constructed is :');

              /* Print TVS Query - Start
                Below Code is for printing the TVS query in the debug log */
              l_clob_length := dbms_lob.getlength(l_tvs_select_clob);
              l_offset := 1;
              l_amount := 8191;

              /* Read 8191 characters from clob sequentially and append them to the VARCHAR2 variable
              using DBMS_LOB.READ function */
              while l_offset <= l_clob_length loop
                l_buffer := '';
                dbms_lob.read(l_tvs_select_clob, l_amount, l_offset, l_buffer);
                l_offset := l_offset + l_amount;
                code_debug(l_buffer, 3);
              end loop;
              /* Print TVS Query - End */

              code_debug('          TVS query constructed - Done');

              IF(l_tvs_metadata_fetched = FALSE) THEN
                IF (l_bad_bindattrs_tvs_cursor_id IS NULL) THEN
                  l_bad_bindattrs_tvs_cursor_id := DBMS_SQL.Open_Cursor;
                  l_dynamic_sql :=
                  'UPDATE '||p_interface_table_name||'
                      SET PROCESS_STATUS = PROCESS_STATUS + '||G_PS_BAD_ATTRS_IN_TVS_WHERE||'
                    WHERE DATA_SET_ID = :data_set_id
                      AND ATTR_INT_NAME = :attr_internal_name
                      AND ATTR_GROUP_INT_NAME = :attr_group_int_name';

                  DBMS_SQL.Parse(l_bad_bindattrs_tvs_cursor_id, l_dynamic_sql, DBMS_SQL.NATIVE);
                  DBMS_SQL.Bind_Variable(l_bad_bindattrs_tvs_cursor_id, ':data_set_id', p_data_set_id);
                END IF;

                DBMS_SQL.Bind_Variable(l_bad_bindattrs_tvs_cursor_id, ':attr_group_int_name', l_attr_group_metadata_obj.ATTR_GROUP_NAME);
                DBMS_SQL.Bind_Variable(l_bad_bindattrs_tvs_cursor_id, ':attr_internal_name', l_attr_metadata_table(y).ATTR_NAME);

                l_dummy := DBMS_SQL.Execute(l_bad_bindattrs_tvs_cursor_id);

              ELSE -- now we do the interface table update since we are sure we have the metadata for bound variables
/*
Note: we are assuming that the setup is correct i.e. the column of the TVS are of correct data type
the id col is of datatype same as the attribute
the meanin col is of type character.
another assumtion is that the user cannot enter the value directly in to the attr_val_* col
he has to enter the data in attr_disp_Value column for which we get the actual attr val.
*/
                IF (l_attr_metadata_table(y).DATA_TYPE_CODE = EGO_EXT_FWK_PUB.G_NUMBER_DATA_TYPE) THEN

                  -- Bug 10151142 : Start
                  /*
                  l_dynamic_sql_1 :=
                  'UPDATE '||p_interface_table_name||' UAI1
                      SET PROCESS_STATUS = PROCESS_STATUS + DECODE(('||l_tvs_num_val_check_select||'),0,'||G_PS_VALUE_NOT_IN_TVS||',0)
                    WHERE DATA_SET_ID = :data_set_id '||'
                      AND (PROCESS_STATUS = '||G_PS_IN_PROCESS||' OR PROCESS_STATUS > '||G_PS_BAD_ATTR_OR_AG_METADATA||' )
                      AND BITAND(PROCESS_STATUS, '||G_PS_NO_PRIVILEGES||') = 0
                      AND ATTR_INT_NAME = '''||l_attr_metadata_table(y).ATTR_NAME||'''
                      AND ATTR_GROUP_INT_NAME = '''||l_attr_group_metadata_obj.ATTR_GROUP_NAME||'''
                      AND ATTR_VALUE_NUM IS NOT NULL';

                  l_dynamic_sql :=
                  'UPDATE '||p_interface_table_name||' UAI1
                      SET ATTR_VALUE_NUM = NVL('||l_tvs_select||',NULL),
                          PROCESS_STATUS = PROCESS_STATUS + DECODE(('||l_tvs_select||'),NULL,'||G_PS_VALUE_NOT_IN_TVS||',0)
                    WHERE DATA_SET_ID = :data_set_id '||'
                      AND (PROCESS_STATUS = '||G_PS_IN_PROCESS||' OR PROCESS_STATUS > '||G_PS_BAD_ATTR_OR_AG_METADATA||' )
                      AND BITAND(PROCESS_STATUS, '||G_PS_NO_PRIVILEGES||') = 0
                      AND ATTR_INT_NAME = '''||l_attr_metadata_table(y).ATTR_NAME||'''
                      AND ATTR_GROUP_INT_NAME = '''||l_attr_group_metadata_obj.ATTR_GROUP_NAME||'''
                      AND ATTR_DISP_VALUE IS NOT NULL ';
                    -- We execute the above cursor in a PL/SQL block since we know that if this fails
                    -- it is because of wrong setup the user has created for table value sets, so we
                    -- need to mark the row as errored due to bad TVS setup.
                  BEGIN
                    EXECUTE IMMEDIATE l_dynamic_sql_1
                      USING p_data_set_id;
                    EXECUTE IMMEDIATE l_dynamic_sql
                      USING p_data_set_id;

                  EXCEPTION
                    WHEN OTHERS THEN
                      IF (l_bad_tvs_sql_cursor_id IS NULL) THEN
                        l_bad_tvs_sql_cursor_id := DBMS_SQL.Open_Cursor;
                        l_dynamic_sql :=
                        'UPDATE '||p_interface_table_name||'
                            SET PROCESS_STATUS = PROCESS_STATUS + '||G_PS_BAD_TVS_SETUP||'
                          WHERE DATA_SET_ID = :data_set_id
                            AND ATTR_INT_NAME = :attr_internal_name
                            AND ATTR_GROUP_INT_NAME = :attr_group_int_name';

                        DBMS_SQL.Parse(l_bad_tvs_sql_cursor_id, l_dynamic_sql, DBMS_SQL.NATIVE);
                        DBMS_SQL.Bind_Variable(l_bad_tvs_sql_cursor_id, ':data_set_id', p_data_set_id);
                      END IF;
                      DBMS_SQL.Bind_Variable(l_bad_tvs_sql_cursor_id, ':attr_group_int_name', l_attr_group_metadata_obj.ATTR_GROUP_NAME);
                      DBMS_SQL.Bind_Variable(l_bad_tvs_sql_cursor_id, ':attr_internal_name', l_attr_metadata_table(y).ATTR_NAME);
                      l_dummy := DBMS_SQL.Execute(l_bad_tvs_sql_cursor_id);
                  END;
                  */

                  Prepare_Dynamic_Sqls_Clob ( p_data_set_id               => p_data_set_id,
                                              p_data_type_code            => EGO_EXT_FWK_PUB.G_NUMBER_DATA_TYPE,
                                              p_interface_table_name      => p_interface_table_name,
                                              p_tvs_val_check_sel_clob    => l_tvs_num_val_check_sel_clob,
                                              p_tvs_select_clob           => l_tvs_select_clob,
                                              p_attr_name                 => l_attr_metadata_table(y).ATTR_NAME,
                                              p_attr_group_name           => l_attr_group_metadata_obj.ATTR_GROUP_NAME,
                                              x_return_status             => l_return_status,
                                              x_msg_data                  => l_msg_data,
                                              x_sql_1_ub                  => l_sql_1_ub,
                                              x_sql_ub                    => l_sql_ub,
                                              x_dynamic_sql_1_v_type      => l_dynamic_sql_1_v_type,
                                              x_dynamic_sql_v_type        => l_dynamic_sql_v_type
                                            );

                  code_debug('          After Prepare_Dynamic_Sqls_Clob - l_return_status :'||l_return_status ,3);

                  IF (l_dynamic_sql_1_cursor_id IS NULL) THEN
                    l_dynamic_sql_1_cursor_id := DBMS_SQL.Open_Cursor;
                  END IF;

                  IF (l_dynamic_sql_cursor_id IS NULL) THEN
                    l_dynamic_sql_cursor_id := DBMS_SQL.Open_Cursor;
                  END IF;

                  code_debug('          Before parse  l_dynamic_sql_1_cursor_id - l_sql_1_ub :'||l_sql_1_ub ,3);

                  BEGIN
                    DBMS_SQL.PARSE( c                  => l_dynamic_sql_1_cursor_id,
                                    statement          => l_dynamic_sql_1_v_type,
                                    lb                 => 1,
                                    ub                 => l_sql_1_ub,
                                    lfflg              => false,
                                    language_flag      => dbms_sql.native );


                    DBMS_SQL.Bind_Variable(l_dynamic_sql_1_cursor_id, ':data_set_id', p_data_set_id);
                    code_debug('          EXECUTING l_dynamic_sql_1_cursor_id' ,3);

                    l_dummy := DBMS_SQL.Execute(l_dynamic_sql_1_cursor_id);

                    code_debug('          Before parse  l_dynamic_sql_cursor_id - l_sql_ub :'||l_sql_ub ,3);

                    DBMS_SQL.PARSE( c                  => l_dynamic_sql_cursor_id,
                                    statement          => l_dynamic_sql_v_type,
                                    lb                 => 1,
                                    ub                 => l_sql_ub,
                                    lfflg              => false,
                                    language_flag      => dbms_sql.native );

                    DBMS_SQL.Bind_Variable(l_dynamic_sql_cursor_id, ':data_set_id', p_data_set_id);
                    code_debug('          EXECUTING l_dynamic_sql_cursor_id' ,3);

                    l_dummy := DBMS_SQL.Execute(l_dynamic_sql_cursor_id);
                    code_debug('          EXECUTING DONE' ,3);

                  EXCEPTION
                    WHEN OTHERS THEN
                      IF (l_dynamic_sql_cursor_id) IS NOT NULL THEN
                        DBMS_SQL.Close_Cursor(l_dynamic_sql_cursor_id);
                      END IF;

                      IF (l_dynamic_sql_1_cursor_id) IS NOT NULL THEN
                        DBMS_SQL.Close_Cursor(l_dynamic_sql_1_cursor_id);
                      END IF;
                      code_debug('          ERROR  :'||SQLERRM  ,3);

                      IF (l_bad_tvs_sql_cursor_id IS NULL) THEN
                        l_bad_tvs_sql_cursor_id := DBMS_SQL.Open_Cursor;
                        l_dynamic_sql :=
                        'UPDATE '||p_interface_table_name||'
                            SET PROCESS_STATUS = PROCESS_STATUS + '||G_PS_BAD_TVS_SETUP||'
                          WHERE DATA_SET_ID = :data_set_id
                            AND ATTR_INT_NAME = :attr_internal_name
                            AND ATTR_GROUP_INT_NAME = :attr_group_int_name';

                        DBMS_SQL.Parse(l_bad_tvs_sql_cursor_id, l_dynamic_sql, DBMS_SQL.NATIVE);
                        DBMS_SQL.Bind_Variable(l_bad_tvs_sql_cursor_id, ':data_set_id', p_data_set_id);
                      END IF;
                      DBMS_SQL.Bind_Variable(l_bad_tvs_sql_cursor_id, ':attr_group_int_name', l_attr_group_metadata_obj.ATTR_GROUP_NAME);
                      DBMS_SQL.Bind_Variable(l_bad_tvs_sql_cursor_id, ':attr_internal_name', l_attr_metadata_table(y).ATTR_NAME);
                      l_dummy := DBMS_SQL.Execute(l_bad_tvs_sql_cursor_id);
                  END;
                  -- Bug 10151142 : End

                ELSIF (l_attr_metadata_table(y).DATA_TYPE_CODE = EGO_EXT_FWK_PUB.G_DATE_DATA_TYPE OR l_attr_metadata_table(y).DATA_TYPE_CODE = EGO_EXT_FWK_PUB.G_DATE_TIME_DATA_TYPE) THEN

                  -- Bug 10151142 : Start
                  /*
                  l_dynamic_sql_1 :=
                  'UPDATE '||p_interface_table_name||' UAI1
                      SET PROCESS_STATUS = PROCESS_STATUS + DECODE(('||l_tvs_date_val_check_select||'),0,'||G_PS_VALUE_NOT_IN_TVS||',0)
                    WHERE DATA_SET_ID = :data_set_id '||'
                      AND (PROCESS_STATUS = '||G_PS_IN_PROCESS||' OR PROCESS_STATUS > '||G_PS_BAD_ATTR_OR_AG_METADATA||' )
                      AND BITAND(PROCESS_STATUS, '||G_PS_NO_PRIVILEGES||') = 0
                      AND ATTR_INT_NAME = '''||l_attr_metadata_table(y).ATTR_NAME||'''
                      AND ATTR_GROUP_INT_NAME = '''||l_attr_group_metadata_obj.ATTR_GROUP_NAME||'''
                      AND ATTR_VALUE_DATE IS NOT NULL';

                  l_dynamic_sql :=
                  'UPDATE '||p_interface_table_name||' UAI1
                      SET ATTR_VALUE_DATE = NVL('||l_tvs_select||',NULL),
                          PROCESS_STATUS = PROCESS_STATUS + DECODE(('||l_tvs_select||'),NULL,'||G_PS_VALUE_NOT_IN_TVS||',0)
                    WHERE DATA_SET_ID = :data_set_id '||'
                      AND (PROCESS_STATUS = '||G_PS_IN_PROCESS||' OR PROCESS_STATUS > '||G_PS_BAD_ATTR_OR_AG_METADATA||' )
                      AND BITAND(PROCESS_STATUS, '||G_PS_NO_PRIVILEGES||') = 0
                      AND ATTR_INT_NAME = '''||l_attr_metadata_table(y).ATTR_NAME||'''
                      AND ATTR_GROUP_INT_NAME = '''||l_attr_group_metadata_obj.ATTR_GROUP_NAME||'''
                      AND ATTR_DISP_VALUE IS NOT NULL ';
                    -- We execute the above cursor in a PL/SQL block since we know that if this fails
                  -- it is because of wrong setup the user has created for table value sets, so we
                  -- need to mark the row as errored due to bad TVS setup.
                  BEGIN
                    EXECUTE IMMEDIATE l_dynamic_sql_1
                      USING p_data_set_id;
                    EXECUTE IMMEDIATE l_dynamic_sql
                      USING p_data_set_id;
                  EXCEPTION
                    WHEN OTHERS THEN
                      IF (l_bad_tvs_sql_cursor_id IS NULL) THEN
                        l_bad_tvs_sql_cursor_id := DBMS_SQL.Open_Cursor;
                        l_dynamic_sql :=
                        'UPDATE '||p_interface_table_name||'
                            SET PROCESS_STATUS = PROCESS_STATUS + '||G_PS_BAD_TVS_SETUP||'
                          WHERE DATA_SET_ID = :data_set_id
                            AND ATTR_INT_NAME = :attr_internal_name
                            AND ATTR_GROUP_INT_NAME = :attr_group_int_name';

                        DBMS_SQL.Parse(l_bad_tvs_sql_cursor_id, l_dynamic_sql, DBMS_SQL.NATIVE);
                        DBMS_SQL.Bind_Variable(l_bad_tvs_sql_cursor_id, ':data_set_id', p_data_set_id);
                      END IF;
                      DBMS_SQL.Bind_Variable(l_bad_tvs_sql_cursor_id, ':attr_group_int_name', l_attr_group_metadata_obj.ATTR_GROUP_NAME);
                      DBMS_SQL.Bind_Variable(l_bad_tvs_sql_cursor_id, ':attr_internal_name', l_attr_metadata_table(y).ATTR_NAME);
                      l_dummy := DBMS_SQL.Execute(l_bad_tvs_sql_cursor_id);
                  END;
                  */

                  Prepare_Dynamic_Sqls_Clob ( p_data_set_id               => p_data_set_id,
                                              p_data_type_code            => EGO_EXT_FWK_PUB.G_DATE_DATA_TYPE,
                                              p_interface_table_name      => p_interface_table_name,
                                              p_tvs_val_check_sel_clob    => l_tvs_date_val_check_sel_clob,
                                              p_tvs_select_clob           => l_tvs_select_clob,
                                              p_attr_name                 => l_attr_metadata_table(y).ATTR_NAME,
                                              p_attr_group_name           => l_attr_group_metadata_obj.ATTR_GROUP_NAME,
                                              x_return_status             => l_return_status,
                                              x_msg_data                  => l_msg_data,
                                              x_sql_1_ub                  => l_sql_1_ub,
                                              x_sql_ub                    => l_sql_ub,
                                              x_dynamic_sql_1_v_type      => l_dynamic_sql_1_v_type,
                                              x_dynamic_sql_v_type        => l_dynamic_sql_v_type
                                            );

                  code_debug('          After Prepare_Dynamic_Sqls_Clob - l_return_status :'||l_return_status ,3);

                  IF (l_dynamic_sql_1_cursor_id IS NULL) THEN
                    l_dynamic_sql_1_cursor_id := DBMS_SQL.Open_Cursor;
                  END IF;

                  IF (l_dynamic_sql_cursor_id IS NULL) THEN
                    l_dynamic_sql_cursor_id := DBMS_SQL.Open_Cursor;
                  END IF;

                  code_debug('          Before parse  l_dynamic_sql_1_cursor_id - l_sql_1_ub :'||l_sql_1_ub ,3);

                  BEGIN
                    DBMS_SQL.PARSE( c                  => l_dynamic_sql_1_cursor_id,
                                    statement          => l_dynamic_sql_1_v_type,
                                    lb                 => 1,
                                    ub                 => l_sql_1_ub,
                                    lfflg              => false,
                                    language_flag      => dbms_sql.native );


                    DBMS_SQL.Bind_Variable(l_dynamic_sql_1_cursor_id, ':data_set_id', p_data_set_id);
                    code_debug('          EXECUTING l_dynamic_sql_1_cursor_id' ,3);

                    l_dummy := DBMS_SQL.Execute(l_dynamic_sql_1_cursor_id);

                    code_debug('          Before parse  l_dynamic_sql_cursor_id - l_sql_ub :'||l_sql_ub ,3);

                    DBMS_SQL.PARSE( c                  => l_dynamic_sql_cursor_id,
                                    statement          => l_dynamic_sql_v_type,
                                    lb                 => 1,
                                    ub                 => l_sql_ub,
                                    lfflg              => false,
                                    language_flag      => dbms_sql.native );

                    DBMS_SQL.Bind_Variable(l_dynamic_sql_cursor_id, ':data_set_id', p_data_set_id);
                    code_debug('          EXECUTING l_dynamic_sql_cursor_id' ,3);

                    l_dummy := DBMS_SQL.Execute(l_dynamic_sql_cursor_id);
                    code_debug('          EXECUTING DONE' ,3);
                  EXCEPTION
                    WHEN OTHERS THEN
                      IF (l_dynamic_sql_cursor_id) IS NOT NULL THEN
                        DBMS_SQL.Close_Cursor(l_dynamic_sql_cursor_id);
                      END IF;

                      IF (l_dynamic_sql_1_cursor_id) IS NOT NULL THEN
                        DBMS_SQL.Close_Cursor(l_dynamic_sql_1_cursor_id);
                      END IF;

                      code_debug('          ERROR  :'||SQLERRM  ,3);
                      IF (l_bad_tvs_sql_cursor_id IS NULL) THEN
                        l_bad_tvs_sql_cursor_id := DBMS_SQL.Open_Cursor;
                        l_dynamic_sql :=
                        'UPDATE '||p_interface_table_name||'
                            SET PROCESS_STATUS = PROCESS_STATUS + '||G_PS_BAD_TVS_SETUP||'
                          WHERE DATA_SET_ID = :data_set_id
                            AND ATTR_INT_NAME = :attr_internal_name
                            AND ATTR_GROUP_INT_NAME = :attr_group_int_name';

                        DBMS_SQL.Parse(l_bad_tvs_sql_cursor_id, l_dynamic_sql, DBMS_SQL.NATIVE);
                        DBMS_SQL.Bind_Variable(l_bad_tvs_sql_cursor_id, ':data_set_id', p_data_set_id);
                      END IF;
                      DBMS_SQL.Bind_Variable(l_bad_tvs_sql_cursor_id, ':attr_group_int_name', l_attr_group_metadata_obj.ATTR_GROUP_NAME);
                      DBMS_SQL.Bind_Variable(l_bad_tvs_sql_cursor_id, ':attr_internal_name', l_attr_metadata_table(y).ATTR_NAME);
                      l_dummy := DBMS_SQL.Execute(l_bad_tvs_sql_cursor_id);
                  END;
                  -- Bug 10151142 : End

                ELSE
/*                  l_dynamic_sql :=
                  'UPDATE '||p_interface_table_name||' UAI1
                      SET ATTR_VALUE_STR = NVL(ATTR_VALUE_STR,'||l_tvs_select||'),
                          PROCESS_STATUS = PROCESS_STATUS + DECODE(NVL2(ATTR_VALUE_STR,
                                                            '||l_tvs_str_val_check_select||',
                                                            NVL2('||l_tvs_select||',1,NULL)
                                                            ),
                                    NULL,
                                '||G_PS_VALUE_NOT_IN_TVS||'
                                ,0)
                    WHERE DATA_SET_ID = '||p_data_set_id||'
                      AND PROCESS_STATUS <> 3
                      AND BITAND(PROCESS_STATUS, '||G_PS_NO_PRIVILEGES||') = 0
                      AND ATTR_INT_NAME = '''||l_attr_metadata_table(y).ATTR_NAME||'''
                      AND ATTR_GROUP_INT_NAME = '''||l_attr_group_metadata_obj.ATTR_GROUP_NAME||''' ';
*/
                  -- Bug 10151142 : Start
                  /*
                  l_dynamic_sql_1 :=
                  'UPDATE '||p_interface_table_name||' UAI1
                      SET PROCESS_STATUS = PROCESS_STATUS + DECODE(('||l_tvs_str_val_check_select||'),0,'||G_PS_VALUE_NOT_IN_TVS||',0)
                    WHERE DATA_SET_ID = :data_set_id '||'
                      AND (PROCESS_STATUS = '||G_PS_IN_PROCESS||' OR PROCESS_STATUS > '||G_PS_BAD_ATTR_OR_AG_METADATA||' )
                      AND BITAND(PROCESS_STATUS, '||G_PS_NO_PRIVILEGES||') = 0
                      AND ATTR_INT_NAME = '''||l_attr_metadata_table(y).ATTR_NAME||'''
                      AND ATTR_GROUP_INT_NAME = '''||l_attr_group_metadata_obj.ATTR_GROUP_NAME||'''
                      AND ATTR_VALUE_STR IS NOT NULL';

                  l_dynamic_sql :=
                  'UPDATE '||p_interface_table_name||' UAI1
                      SET ATTR_VALUE_STR = NVL('||l_tvs_select||',NULL),
                          PROCESS_STATUS = PROCESS_STATUS + DECODE(('||l_tvs_select||'),NULL,'||G_PS_VALUE_NOT_IN_TVS||',0)
                    WHERE DATA_SET_ID = :data_set_id '||'
                      AND (PROCESS_STATUS = '||G_PS_IN_PROCESS||' OR PROCESS_STATUS > '||G_PS_BAD_ATTR_OR_AG_METADATA||' )
                      AND BITAND(PROCESS_STATUS, '||G_PS_NO_PRIVILEGES||') = 0
                      AND ATTR_INT_NAME = '''||l_attr_metadata_table(y).ATTR_NAME||'''
                      AND ATTR_GROUP_INT_NAME = '''||l_attr_group_metadata_obj.ATTR_GROUP_NAME||'''
                      AND ATTR_DISP_VALUE IS NOT NULL ';
                  -- We execute the above cursor in a PL/SQL block since we know that if this fails
                  -- it is because of wrong setup the user has created for table value sets, so we
                  -- need to mark the row as errored due to bad TVS setup.
                  BEGIN
                    EXECUTE IMMEDIATE l_dynamic_sql_1
                      USING p_data_set_id;
                    EXECUTE IMMEDIATE l_dynamic_sql
                      USING p_data_set_id;
                  EXCEPTION
                    WHEN OTHERS THEN
                      IF (l_bad_tvs_sql_cursor_id IS NULL) THEN
                        l_bad_tvs_sql_cursor_id := DBMS_SQL.Open_Cursor;
                        l_dynamic_sql :=
                        'UPDATE '||p_interface_table_name||'
                            SET PROCESS_STATUS = PROCESS_STATUS + '||G_PS_BAD_TVS_SETUP||'
                          WHERE DATA_SET_ID = :data_set_id
                            AND ATTR_INT_NAME = :attr_internal_name
                            AND ATTR_GROUP_INT_NAME = :attr_group_int_name';

                        DBMS_SQL.Parse(l_bad_tvs_sql_cursor_id, l_dynamic_sql, DBMS_SQL.NATIVE);
                        DBMS_SQL.Bind_Variable(l_bad_tvs_sql_cursor_id, ':data_set_id', p_data_set_id);
                      END IF;
                      DBMS_SQL.Bind_Variable(l_bad_tvs_sql_cursor_id, ':attr_group_int_name', l_attr_group_metadata_obj.ATTR_GROUP_NAME);
                      DBMS_SQL.Bind_Variable(l_bad_tvs_sql_cursor_id, ':attr_internal_name', l_attr_metadata_table(y).ATTR_NAME);
                      l_dummy := DBMS_SQL.Execute(l_bad_tvs_sql_cursor_id);
                  END;
                  */

                  Prepare_Dynamic_Sqls_Clob ( p_data_set_id               => p_data_set_id,
                                              p_data_type_code            => EGO_EXT_FWK_PUB.G_CHAR_DATA_TYPE,
                                              p_interface_table_name      => p_interface_table_name,
                                              p_tvs_val_check_sel_clob    => l_tvs_str_val_check_sel_clob,
                                              p_tvs_select_clob           => l_tvs_select_clob,
                                              p_attr_name                 => l_attr_metadata_table(y).ATTR_NAME,
                                              p_attr_group_name           => l_attr_group_metadata_obj.ATTR_GROUP_NAME,
                                              x_return_status             => l_return_status,
                                              x_msg_data                  => l_msg_data,
                                              x_sql_1_ub                  => l_sql_1_ub,
                                              x_sql_ub                    => l_sql_ub,
                                              x_dynamic_sql_1_v_type      => l_dynamic_sql_1_v_type,
                                              x_dynamic_sql_v_type        => l_dynamic_sql_v_type
                                            );

                  code_debug('          After Prepare_Dynamic_Sqls_Clob - l_return_status :'||l_return_status ,3);

                  IF (l_dynamic_sql_1_cursor_id IS NULL) THEN
                    l_dynamic_sql_1_cursor_id := DBMS_SQL.Open_Cursor;
                  END IF;

                  IF (l_dynamic_sql_cursor_id IS NULL) THEN
                    l_dynamic_sql_cursor_id := DBMS_SQL.Open_Cursor;
                  END IF;

                  code_debug('          Before parse  l_dynamic_sql_1_cursor_id - l_sql_1_ub :'||l_sql_1_ub ,3);

                  BEGIN
                    DBMS_SQL.PARSE( c                  => l_dynamic_sql_1_cursor_id,
                                    statement          => l_dynamic_sql_1_v_type,
                                    lb                 => 1,
                                    ub                 => l_sql_1_ub,
                                    lfflg              => false,
                                    language_flag      => dbms_sql.native );


                    DBMS_SQL.Bind_Variable(l_dynamic_sql_1_cursor_id, ':data_set_id', p_data_set_id);
                    code_debug('          EXECUTING l_dynamic_sql_1_cursor_id' ,3);

                    l_dummy := DBMS_SQL.Execute(l_dynamic_sql_1_cursor_id);

                    code_debug('          Before parse  l_dynamic_sql_1_cursor_id - l_sql_ub :'||l_sql_ub ,3);

                    DBMS_SQL.PARSE( c                  => l_dynamic_sql_cursor_id,
                                    statement          => l_dynamic_sql_v_type,
                                    lb                 => 1,
                                    ub                 => l_sql_ub,
                                    lfflg              => false,
                                    language_flag      => dbms_sql.native );

                    DBMS_SQL.Bind_Variable(l_dynamic_sql_cursor_id, ':data_set_id', p_data_set_id);
                    code_debug('          EXECUTING l_dynamic_sql_cursor_id' ,3);

                    l_dummy := DBMS_SQL.Execute(l_dynamic_sql_cursor_id);
                    code_debug('          EXECUTING DONE' ,3);
                  EXCEPTION
                    WHEN OTHERS THEN
                        IF (l_dynamic_sql_cursor_id) IS NOT NULL THEN
                          DBMS_SQL.Close_Cursor(l_dynamic_sql_cursor_id);
                        END IF;

                        IF (l_dynamic_sql_1_cursor_id) IS NOT NULL THEN
                          DBMS_SQL.Close_Cursor(l_dynamic_sql_1_cursor_id);
                        END IF;

                    code_debug('          ERROR  :'||SQLERRM  ,3);
                    IF (l_bad_tvs_sql_cursor_id IS NULL) THEN
                      l_bad_tvs_sql_cursor_id := DBMS_SQL.Open_Cursor;
                      l_dynamic_sql :=
                      'UPDATE '||p_interface_table_name||'
                          SET PROCESS_STATUS = PROCESS_STATUS + '||G_PS_BAD_TVS_SETUP||'
                        WHERE DATA_SET_ID = :data_set_id
                          AND ATTR_INT_NAME = :attr_internal_name
                          AND ATTR_GROUP_INT_NAME = :attr_group_int_name';

                      DBMS_SQL.Parse(l_bad_tvs_sql_cursor_id, l_dynamic_sql, DBMS_SQL.NATIVE);
                      DBMS_SQL.Bind_Variable(l_bad_tvs_sql_cursor_id, ':data_set_id', p_data_set_id);
                    END IF;
                    DBMS_SQL.Bind_Variable(l_bad_tvs_sql_cursor_id, ':attr_group_int_name', l_attr_group_metadata_obj.ATTR_GROUP_NAME);
                    DBMS_SQL.Bind_Variable(l_bad_tvs_sql_cursor_id, ':attr_internal_name', l_attr_metadata_table(y).ATTR_NAME);
                    l_dummy := DBMS_SQL.Execute(l_bad_tvs_sql_cursor_id);
                  END;
                  -- Bug 10151142 : End

                END IF;
              END IF; --l_attr_metadata fetched TRUE/FALSE
            END IF; -- if validation_code is TVS
          END IF;--the if attr exists in the intf table ends.
        END LOOP;

        code_debug('          After the TVS check ' ,2);

        ------------------------------------------------
        -- Here we error out the MR AG rows which have
        -- a wrong transaction type (UPDATE, CREATE)
        ------------------------------------------------
        l_dynamic_sql :=
        ' UPDATE /*+ INDEX(UAI1,EGO_ITM_USR_ATTR_INTRFC_N3) */  /* Bug 9678667 */ '||p_interface_table_name||' UAI1
            SET UAI1.PROCESS_STATUS = PROCESS_STATUS +
                                      DECODE(UAI1.TRANSACTION_TYPE,
                                             '''||EGO_USER_ATTRS_DATA_PVT.G_CREATE_MODE||''', '||G_PS_BAD_TTYPE_CREATE||',
                                             '''||EGO_USER_ATTRS_DATA_PVT.G_UPDATE_MODE||''', '||G_PS_BAD_TTYPE_UPDATE||',
                                             '''||EGO_USER_ATTRS_DATA_PVT.G_DELETE_MODE||''', '||G_PS_BAD_TTYPE_DELETE||',0)
          WHERE UAI1.DATA_SET_ID = :data_set_id '||--p_data_set_id||
          ' AND UAI1.PROCESS_STATUS = '||G_PS_IN_PROCESS||
          ' AND UAI1.ATTR_GROUP_TYPE = '''||p_attr_group_type||''' '||
          ' AND UAI1.TRANSACTION_TYPE <> '''||EGO_USER_ATTRS_DATA_PVT.G_SYNC_MODE||
        ''' AND UAI1.ATTR_GROUP_INT_NAME = '''||
                l_attr_group_metadata_obj.ATTR_GROUP_NAME||
        ''' AND UAI1.ROW_IDENTIFIER IN (
                SELECT DISTINCT UAI2.ROW_IDENTIFIER
                  FROM '||p_interface_table_name||' UAI2
                 WHERE UAI2.DATA_SET_ID = :data_set_id '||--p_data_set_id||
                 ' AND UAI2.PROCESS_STATUS = '||G_PS_IN_PROCESS;

        l_dynamic_sql := l_dynamic_sql||' AND (SELECT COUNT(*) FROM '||l_ext_table_select||')
                          = DECODE(UAI2.TRANSACTION_TYPE,
                             '''||EGO_USER_ATTRS_DATA_PVT.G_CREATE_MODE||''', 1,
                             '''||EGO_USER_ATTRS_DATA_PVT.G_UPDATE_MODE||''', 0,
                             '''||EGO_USER_ATTRS_DATA_PVT.G_DELETE_MODE||''', 0))';

        EXECUTE IMMEDIATE l_dynamic_sql
        USING p_data_set_id, p_data_set_id;/*Fix for bug#9678667. Literal to bind*/
        code_debug('          After transaction type validation ' ,2);

        --------------------------------------------------
        -- Here we update the INTF table transaction_type
        -- from SYNC to CREATE or UPDATE
        --------------------------------------------------
        l_dynamic_sql :=
        ' UPDATE '||p_interface_table_name||' UAI1
            SET UAI1.TRANSACTION_TYPE = DECODE((SELECT COUNT(*) FROM '||l_ext_table_select||'),0,'''||
                                               EGO_USER_ATTRS_DATA_PVT.G_CREATE_MODE||''','''||
                                               EGO_USER_ATTRS_DATA_PVT.G_UPDATE_MODE||''')
          WHERE UAI1.DATA_SET_ID = '||p_data_set_id||
          ' AND UAI1.ATTR_GROUP_INT_NAME = '''||l_attr_group_metadata_obj.ATTR_GROUP_NAME||
       '''  AND UAI1.PROCESS_STATUS = '||G_PS_IN_PROCESS||
          ' AND UAI1.TRANSACTION_TYPE = '''||EGO_USER_ATTRS_DATA_PVT.G_SYNC_MODE||'''';

          --ER 9489112, do not convert SYNC to CREATE/UPDATE for item rev level Multi Row UDA when change order be created
          --Current UDA chanage be put in change order controll since rev level UDA will defaulted from
          --current revision when new revision created. rev level UDA defauled when the new revision
          --is created by change Service ChangeImportManager.createItemRevChangeMethodRequests later.
          IF  l_data_level_col_exists  AND l_add_all_to_cm = 'Y' THEN
            l_dynamic_sql := l_dynamic_sql || ' AND UAI1.DATA_LEVEL_ID <> ' ||l_item_rev_dl_id ;
          END IF;
        code_debug('l_dynamic_sql to update Transaction type for MR Row '||l_attr_group_metadata_obj.ATTR_GROUP_NAME ||':' || l_dynamic_sql,2);
        EXECUTE IMMEDIATE l_dynamic_sql;

        code_debug('          After transaction type updation ' ,2);

        END IF; -- *p_validate-IF-2* ending the IF for p_validate...
      END IF; -- ending MR specific work

      ----------------------------------------------------
      -- Folowing validations are also done only if the --
      -- API is called with p_validate = TRUE           --
      ----------------------------------------------------
      IF (p_validate OR p_do_req_def_valiadtion) THEN   -- Search for *p_validate-IF-3.1* to find the ending of this loop

        /* Bug 9678667 - Start
        -- Below query inserts the Default UDAs for a given AG in a single query instead of looping through the attributes.
        */
        code_debug('          Before Inserting Default rows for AG :'||l_attr_group_intf_rec.ATTR_GROUP_INT_NAME );
		/* Bug 14044344
		-- Add setting value for column CHANGE_ID,CHANGE_LINE_ID,PROG_INT_CHAR2,PROG_INT_NUM4, so that default value line will go with the original change line in implementation phase.
		-- By QIXIA 2012-07-05
		*/
        l_dynamic_sql :=
                'INSERT INTO '||p_interface_table_name||'
                            ( TRANSACTION_ID,
                              ATTR_GROUP_TYPE,
                              PROCESS_STATUS,
                              DATA_SET_ID,
                              ROW_IDENTIFIER,
                              ATTR_GROUP_INT_NAME,
                              ATTR_INT_NAME,
                              ATTR_VALUE_NUM,
                              ATTR_VALUE_STR,
                              ATTR_VALUE_DATE,
                              TRANSACTION_TYPE,
                              '||l_concat_pk_cols_sel||'
                              ATTR_GROUP_ID,
                              CREATED_BY,
                              CREATION_DATE,
                              LAST_UPDATED_BY,
                              LAST_UPDATE_DATE
                            )
                  SELECT DISTINCT TRANSACTION_ID,
                                  FL_COL.DESCRIPTIVE_FLEXFIELD_NAME,
                                  '||G_PS_IN_PROCESS||',
                                  DATA_SET_ID,
                                  ROW_IDENTIFIER,
                                  ATTR_GROUP_INT_NAME,
                                  FL_COL.END_USER_COLUMN_NAME,
                                  TO_NUMBER(DECODE(ATTR_EXT.DATA_TYPE, ''N'', FL_COL.DEFAULT_VALUE,
                                                                        NULL)),
                                  DECODE(ATTR_EXT.DATA_TYPE, ''A'', FL_COL.DEFAULT_VALUE,
                                                              ''C'', FL_COL.DEFAULT_VALUE,
                                                              NULL),
                                  DECODE(ATTR_EXT.DATA_TYPE, ''X'', EGO_USER_ATTRS_BULK_PVT.GET_DATE(FL_COL.DEFAULT_VALUE, NULL),
                                                              ''Y'', EGO_USER_ATTRS_BULK_PVT.GET_DATE(FL_COL.DEFAULT_VALUE, NULL),
                                                              NULL),
                                  '''|| EGO_USER_ATTRS_DATA_PVT.G_CREATE_MODE||''',
                                  '|| l_concat_pk_cols_sel ||'
                                  ATTR_GROUP_ID,
                                  FND_GLOBAL.USER_ID,
                                  SYSDATE,
                                  FND_GLOBAL.USER_ID,
                                  SYSDATE
                  FROM  (SELECT /*+ NO_MERGE index(A,EGO_ITM_USR_ATTR_INTRFC_N1) */
                         MAX(TRANSACTION_ID) TRANSACTION_ID,
                                  DATA_SET_ID,
                                  ROW_IDENTIFIER,
                                  ATTR_GROUP_INT_NAME,
                                  '|| l_concat_pk_cols_sel ||'
                                  ATTR_GROUP_ID
                          FROM   '||p_interface_table_name||' A
                          WHERE  DATA_SET_ID = :data_set_id
                                 AND PROCESS_STATUS = '||G_PS_IN_PROCESS|| '
                                 AND ATTR_GROUP_INT_NAME = :attr_group_int_name
                                 AND Bitand(PROCESS_STATUS, 64) = 0
                                 AND TRANSACTION_TYPE = '''|| EGO_USER_ATTRS_DATA_PVT.G_CREATE_MODE||'''
                                 AND ATTR_GROUP_TYPE = :attr_group_type
                          GROUP  BY DATA_SET_ID,
                                    ROW_IDENTIFIER,
                                    ATTR_GROUP_INT_NAME,
                                    '|| l_concat_pk_cols_sel ||'
                                    ATTR_GROUP_ID
                        ) A,
                        FND_DESCR_FLEX_COLUMN_USAGES FL_COL,
                        EGO_FND_DF_COL_USGS_EXT ATTR_EXT
                  WHERE NOT EXISTS (SELECT /*+ no_unnest index(B,EGO_ITM_USR_ATTR_INTRFC_U1) */ NULL
                                    FROM   '||p_interface_table_name||' B
                                    WHERE  DATA_SET_ID = :data_set_id
                                           AND B.ATTR_INT_NAME = FL_COL.END_USER_COLUMN_NAME
                                           AND A.ROW_IDENTIFIER = B.ROW_IDENTIFIER
                                           AND B.ATTR_GROUP_INT_NAME = :attr_group_int_name
                                   )
                        AND :attr_group_int_name = FL_COL.DESCRIPTIVE_FLEX_CONTEXT_CODE
                        AND FL_COL.APPLICATION_ID  = '||p_application_id||'
                        AND FL_COL.DESCRIPTIVE_FLEXFIELD_NAME =  :attr_group_type
                        AND FL_COL.ENABLED_FLAG = ''Y''
                        AND (FL_COL.DEFAULT_VALUE IS NOT NULL OR FL_COL.REQUIRED_FLAG = ''Y'')
                        AND ATTR_EXT.APPLICATION_ID = FL_COL.APPLICATION_ID
                        AND ATTR_EXT.DESCRIPTIVE_FLEXFIELD_NAME = FL_COL.DESCRIPTIVE_FLEXFIELD_NAME
                        AND ATTR_EXT.DESCRIPTIVE_FLEX_CONTEXT_CODE = FL_COL.DESCRIPTIVE_FLEX_CONTEXT_CODE
                        AND ATTR_EXT.APPLICATION_COLUMN_NAME = FL_COL.APPLICATION_COLUMN_NAME';

        EXECUTE IMMEDIATE l_dynamic_sql
        USING p_data_set_id
             ,l_attr_group_intf_rec.ATTR_GROUP_INT_NAME
             ,p_attr_group_type
             ,p_data_set_id
             ,l_attr_group_intf_rec.ATTR_GROUP_INT_NAME
             ,l_attr_group_intf_rec.ATTR_GROUP_INT_NAME
             ,p_attr_group_type;

        code_debug('           After Inserting Default rows for AG :'||l_attr_group_intf_rec.ATTR_GROUP_INT_NAME );
        /* Bug 9678667 - End */

        ------------------------------------------------------------------------------
        -- HERE WE COPY THE DEFAULT VALUE FOR THE ATTRIBUTE FROM THE METADATA IF NO --
        -- VALUE HAS BEEN PROVIDED FOR THE ATTRIBUTE                                --
        ------------------------------------------------------------------------------
        --rathna LOOP THROUGH ALL THE ATTRS METADATA FOR THIS AG
        FOR z IN l_attr_metadata_table_1.FIRST .. l_attr_metadata_table_1.LAST
        LOOP

          IF (l_attr_metadata_table_1(z).DEFAULT_VALUE IS NOT NULL OR
              l_attr_metadata_table_1(z).REQUIRED_FLAG = 'Y' AND p_do_req_def_valiadtion) THEN

            /* Bug 9678667 : Start - Commenting the below Code
            -- The below logic of inserting Default UDAs is done above out of the loop as a single query per AG
            */
            /*

            code_debug('          Attribute '||l_attr_metadata_table_1(z).ATTR_NAME|| ' has a default value or is a required attribute' ,2);
            --------- FOR NUMBER DATATYPE
            IF(l_attr_metadata_table_1(z).DATA_TYPE_CODE = EGO_EXT_FWK_PUB.G_NUMBER_DATA_TYPE) THEN
              IF (l_default_num_cursor_id IS NULL) THEN
                l_default_num_cursor_id := DBMS_SQL.Open_Cursor;
                l_dynamic_sql :=
                'INSERT INTO '||p_interface_table_name||' ( TRANSACTION_ID,
                      PROCESS_STATUS                 ,
                      DATA_SET_ID                    ,
                      ROW_IDENTIFIER                 ,
                      ATTR_GROUP_INT_NAME            ,
                      ATTR_INT_NAME                  ,
                      ATTR_VALUE_NUM                 ,
                      TRANSACTION_TYPE               ,'||l_concat_pk_cols_sel||'
                      ATTR_GROUP_ID,CREATED_BY,CREATION_DATE,LAST_UPDATED_BY,LAST_UPDATE_DATE)
                  SELECT /*+ index(A,EGO_ITM_USR_ATTR_INTRFC_N1) */   /* Fix for bug#9678667 */
           /* Bug 9678667           MAX(TRANSACTION_ID),'||G_PS_IN_PROCESS||',DATA_SET_ID,ROW_IDENTIFIER,:attr_group_int_name,:attr_internal_name,
                                  :default_value,'''|| EGO_USER_ATTRS_DATA_PVT.G_CREATE_MODE||''','|| l_concat_pk_cols_sel ||'
                                  ATTR_GROUP_ID,MAX(CREATED_BY),SYSDATE,MAX(LAST_UPDATED_BY),SYSDATE
                  FROM '||p_interface_table_name||' A
                  WHERE NOT EXISTS (
                          SELECT  /*+ no_unnest index(B,EGO_ITM_USR_ATTR_INTRFC_U1) */  /* Fix for bug#9678667 */
           /* Bug 9678667                     NULL
                            FROM '||p_interface_table_name||' B
                           WHERE DATA_SET_ID = A.DATA_SET_ID
                             AND B.ATTR_INT_NAME = :attr_internal_name
                             -- AND B.ATTR_GROUP_INT_NAME = A.ATTR_GROUP_INT_NAME /* Fix for bug#9678667 */
                             --AND B.TRANSACTION_TYPE = A.TRANSACTION_TYPE
          /* Bug 9678667                   AND A.ROW_IDENTIFIER = B.ROW_IDENTIFIER)
                    AND DATA_SET_ID = :data_set_id
                    AND ATTR_GROUP_INT_NAME = :attr_group_int_name
                    AND PROCESS_STATUS = '||G_PS_IN_PROCESS|| '
                    AND BITAND(PROCESS_STATUS, '||G_PS_NO_PRIVILEGES||') = 0
                    AND TRANSACTION_TYPE = '''|| EGO_USER_ATTRS_DATA_PVT.G_CREATE_MODE||'''
                  GROUP BY DATA_SET_ID,ROW_IDENTIFIER,'|| l_concat_pk_cols_sel ||' ATTR_GROUP_ID' ;
                DBMS_SQL.Parse(l_default_num_cursor_id, l_dynamic_sql, DBMS_SQL.NATIVE);
                DBMS_SQL.Bind_Variable(l_default_num_cursor_id, ':data_set_id', p_data_set_id);
              END IF;

              DBMS_SQL.Bind_Variable(l_default_num_cursor_id, ':attr_group_int_name', l_attr_metadata_table_1(z).ATTR_GROUP_NAME);
              DBMS_SQL.Bind_Variable(l_default_num_cursor_id, ':attr_internal_name', l_attr_metadata_table_1(z).ATTR_NAME);
              DBMS_SQL.Bind_Variable(l_default_num_cursor_id, ':default_value', l_attr_metadata_table_1(z).DEFAULT_VALUE);
              l_dummy := DBMS_SQL.Execute(l_default_num_cursor_id);
              -- We need to add the attr in the distinct attrs table, since now we have to process this one also
              IF (l_attr_metadata_table_1(z).DEFAULT_VALUE IS NOT NULL AND l_dummy > 0 ) THEN
                l_dist_attr_in_data_set_rec.ATTR_GROUP_ID := l_attr_metadata_table_1(z).ATTR_GROUP_ID;
                l_dist_attr_in_data_set_rec.ATTR_INT_NAME := l_attr_metadata_table_1(z).ATTR_NAME;
                l_dist_attr_in_data_set_rec.ATTR_GROUP_INT_NAME := l_attr_metadata_table_1(z).ATTR_GROUP_NAME;

                l_dist_attrs_in_data_set_table(l_dist_attrs_in_data_set_table.COUNT+1) := l_dist_attr_in_data_set_rec;
              END IF;

            --------- FOR DATE DATATYPE
            ELSIF(l_attr_metadata_table_1(z).DATA_TYPE_CODE = EGO_EXT_FWK_PUB.G_DATE_DATA_TYPE OR
                  l_attr_metadata_table_1(z).DATA_TYPE_CODE = EGO_EXT_FWK_PUB.G_DATE_TIME_DATA_TYPE) THEN
              IF (l_default_date_cursor_id IS NULL) THEN
                l_default_date_cursor_id := DBMS_SQL.Open_Cursor;
                l_dynamic_sql :=
                'INSERT INTO '||p_interface_table_name||' ( TRANSACTION_ID,
                      PROCESS_STATUS                 ,
                      DATA_SET_ID                    ,
                      ROW_IDENTIFIER                 ,
                      ATTR_GROUP_INT_NAME            ,
                      ATTR_INT_NAME                  ,
                      ATTR_VALUE_DATE                ,
                      TRANSACTION_TYPE               ,'||l_concat_pk_cols_sel||'
                      ATTR_GROUP_ID,CREATED_BY,CREATION_DATE,LAST_UPDATED_BY,LAST_UPDATE_DATE)
                  SELECT /*+ index(A,EGO_ITM_USR_ATTR_INTRFC_N1) */   /* Fix for bug#9678667 */
           /* Bug 9678667           MAX(TRANSACTION_ID),'||G_PS_IN_PROCESS||',DATA_SET_ID,ROW_IDENTIFIER,:attr_group_int_name,:attr_internal_name,
                                  :default_value,'''|| EGO_USER_ATTRS_DATA_PVT.G_CREATE_MODE||''','|| l_concat_pk_cols_sel ||'
                                  ATTR_GROUP_ID,MAX(CREATED_BY),SYSDATE,MAX(LAST_UPDATED_BY),SYSDATE
                  FROM '||p_interface_table_name||' A
                  WHERE NOT EXISTS (
                          SELECT /*+ no_unnest index(B,EGO_ITM_USR_ATTR_INTRFC_U1) */ /* Fix for bug#9678667 */
          /* Bug 9678667                      NULL
                            FROM '||p_interface_table_name||' B
                           WHERE DATA_SET_ID = A.DATA_SET_ID
                             AND B.ATTR_INT_NAME = :attr_internal_name
                             -- AND B.ATTR_GROUP_INT_NAME = A.ATTR_GROUP_INT_NAME /* Fix for bug#9678667 */
                             --AND B.TRANSACTION_TYPE = A.TRANSACTION_TYPE
         /* Bug 9678667                    AND A.ROW_IDENTIFIER = B.ROW_IDENTIFIER)
                    AND DATA_SET_ID = :data_set_id
                    AND ATTR_GROUP_INT_NAME = :attr_group_int_name
                    AND PROCESS_STATUS = '||G_PS_IN_PROCESS|| '
                    AND BITAND(PROCESS_STATUS, '||G_PS_NO_PRIVILEGES||') = 0
                    AND TRANSACTION_TYPE = '''|| EGO_USER_ATTRS_DATA_PVT.G_CREATE_MODE||'''
                  GROUP BY DATA_SET_ID,ROW_IDENTIFIER,'|| l_concat_pk_cols_sel ||' ATTR_GROUP_ID' ;
                DBMS_SQL.Parse(l_default_date_cursor_id, l_dynamic_sql, DBMS_SQL.NATIVE);
                DBMS_SQL.Bind_Variable(l_default_date_cursor_id, ':data_set_id', p_data_set_id);
              END IF;

              DBMS_SQL.Bind_Variable(l_default_date_cursor_id, ':attr_group_int_name', l_attr_metadata_table_1(z).ATTR_GROUP_NAME);
              DBMS_SQL.Bind_Variable(l_default_date_cursor_id, ':attr_internal_name', l_attr_metadata_table_1(z).ATTR_NAME);
              DBMS_SQL.Bind_Variable(l_default_date_cursor_id, ':default_value', Get_Date(l_attr_metadata_table_1(z).DEFAULT_VALUE));
-- bug 3902395
--              l_dummy := DBMS_SQL.Execute(l_default_num_cursor_id);
              l_dummy := DBMS_SQL.Execute(l_default_date_cursor_id);
              -- We need to add the attr in the distinct attrs table, since now we have to process this one also
              IF (l_attr_metadata_table_1(z).DEFAULT_VALUE IS NOT NULL AND l_dummy > 0 ) THEN
                l_dist_attr_in_data_set_rec.ATTR_GROUP_ID := l_attr_metadata_table_1(z).ATTR_GROUP_ID;
                l_dist_attr_in_data_set_rec.ATTR_INT_NAME := l_attr_metadata_table_1(z).ATTR_NAME;
                l_dist_attr_in_data_set_rec.ATTR_GROUP_INT_NAME := l_attr_metadata_table_1(z).ATTR_GROUP_NAME;

                l_dist_attrs_in_data_set_table(l_dist_attrs_in_data_set_table.COUNT+1) := l_dist_attr_in_data_set_rec;
              END IF;

            --------- FOR CHAR/TRANS DATATYPE
            ELSE
              IF (l_default_char_cursor_id IS NULL) THEN
                l_default_char_cursor_id := DBMS_SQL.Open_Cursor;
                l_dynamic_sql :=
                'INSERT INTO '||p_interface_table_name||' ( TRANSACTION_ID,
                      PROCESS_STATUS                 ,
                      DATA_SET_ID                    ,
                      ROW_IDENTIFIER                 ,
                      ATTR_GROUP_INT_NAME            ,
                      ATTR_INT_NAME                  ,
                      ATTR_VALUE_STR                 ,
                      TRANSACTION_TYPE               ,'||l_concat_pk_cols_sel||'
                      ATTR_GROUP_ID,CREATED_BY,CREATION_DATE,LAST_UPDATED_BY,LAST_UPDATE_DATE)
                  SELECT /*+ index(A,EGO_ITM_USR_ATTR_INTRFC_N1) */   /* Fix for bug#9678667 */
         /* Bug 9678667             MAX(TRANSACTION_ID),'||G_PS_IN_PROCESS||',DATA_SET_ID,ROW_IDENTIFIER,:attr_group_int_name,:attr_internal_name,
                                  :default_value,'''|| EGO_USER_ATTRS_DATA_PVT.G_CREATE_MODE||''','|| l_concat_pk_cols_sel ||'
                                  ATTR_GROUP_ID,MAX(CREATED_BY),SYSDATE,MAX(LAST_UPDATED_BY),SYSDATE
                  FROM '||p_interface_table_name||' A
                  WHERE NOT EXISTS (
                          SELECT /*+ no_unnest index(B,EGO_ITM_USR_ATTR_INTRFC_U1) */ /* Fix for bug#9678667 */
          /* Bug 9678667                      NULL
                            FROM '||p_interface_table_name||' B
                           WHERE DATA_SET_ID = A.DATA_SET_ID
                             AND B.ATTR_INT_NAME = :attr_internal_name
                             -- AND B.ATTR_GROUP_INT_NAME = A.ATTR_GROUP_INT_NAME   /* Fix for bug#9678667 */
                             --AND B.TRANSACTION_TYPE = A.TRANSACTION_TYPE
         /* Bug 9678667                    AND A.ROW_IDENTIFIER = B.ROW_IDENTIFIER)
                    AND DATA_SET_ID = :data_set_id
                    AND ATTR_GROUP_INT_NAME = :attr_group_int_name
                    AND PROCESS_STATUS = '||G_PS_IN_PROCESS|| '
                    AND BITAND(PROCESS_STATUS, '||G_PS_NO_PRIVILEGES||') = 0
                    AND TRANSACTION_TYPE = '''|| EGO_USER_ATTRS_DATA_PVT.G_CREATE_MODE||'''
                  GROUP BY DATA_SET_ID,ROW_IDENTIFIER,'|| l_concat_pk_cols_sel ||' ATTR_GROUP_ID' ;
                DBMS_SQL.Parse(l_default_char_cursor_id, l_dynamic_sql, DBMS_SQL.NATIVE);
                DBMS_SQL.Bind_Variable(l_default_char_cursor_id, ':data_set_id', p_data_set_id);
              END IF;

              DBMS_SQL.Bind_Variable(l_default_char_cursor_id, ':attr_group_int_name', l_attr_metadata_table_1(z).ATTR_GROUP_NAME);
              DBMS_SQL.Bind_Variable(l_default_char_cursor_id, ':attr_internal_name', l_attr_metadata_table_1(z).ATTR_NAME);
              DBMS_SQL.Bind_Variable(l_default_char_cursor_id, ':default_value', l_attr_metadata_table_1(z).DEFAULT_VALUE);

              l_dummy := DBMS_SQL.Execute(l_default_char_cursor_id);
              -- We need to add the attr in the distinct attrs table, since now we have to process this one also
              IF (l_attr_metadata_table_1(z).DEFAULT_VALUE IS NOT NULL AND l_dummy > 0 ) THEN
                l_dist_attr_in_data_set_rec.ATTR_GROUP_ID := l_attr_metadata_table_1(z).ATTR_GROUP_ID;
                l_dist_attr_in_data_set_rec.ATTR_INT_NAME := l_attr_metadata_table_1(z).ATTR_NAME;
                l_dist_attr_in_data_set_rec.ATTR_GROUP_INT_NAME := l_attr_metadata_table_1(z).ATTR_GROUP_NAME;

                l_dist_attrs_in_data_set_table(l_dist_attrs_in_data_set_table.COUNT+1) := l_dist_attr_in_data_set_rec;
              END IF;

            END IF;--inserting row

            code_debug('          After inserting rows where ever required for attribute '||l_attr_metadata_table_1(z).ATTR_NAME ,2);
          */ -- Bug 9678667 : End - Commenting Ends

            ----------------------------------------------------------
            -- HERE WE CHECK FOR REQUIRED FIELD VALIDATIONS FOR ROWS
            -- HAVING TRANSACTION TYPE AS UPDATE OR CREATE
            -- BY NOW WE HAVE THE ATTR_VAL_* COLUMNS FILLED UP WITH
            -- APPROPRIATE VALUES.
            ----------------------------------------------------------
            IF (l_attr_metadata_table_1(z).REQUIRED_FLAG = 'Y') THEN

              code_debug('          Attribute '||l_attr_metadata_table_1(z).ATTR_NAME|| ' is a required attribute' ,2);

              --------- FOR NUMBER DATATYPE
              IF(l_attr_metadata_table_1(z).DATA_TYPE_CODE = EGO_EXT_FWK_PUB.G_NUMBER_DATA_TYPE) THEN
                IF (l_req_num_cursor_id IS NULL) THEN
                  l_req_num_cursor_id := DBMS_SQL.Open_Cursor;
                  l_dynamic_sql :=
                  'UPDATE '||p_interface_table_name||'
                      SET PROCESS_STATUS = PROCESS_STATUS + '||G_PS_REQUIRED_ATTRIBUTE||'
                    WHERE DATA_SET_ID = :data_set_id
                      AND PROCESS_STATUS = '||G_PS_IN_PROCESS|| '
                      AND BITAND(PROCESS_STATUS, '||G_PS_NO_PRIVILEGES||') = 0
                      AND ATTR_INT_NAME = :attr_internal_name
                      AND ATTR_GROUP_INT_NAME = :attr_group_int_name
                      AND ATTR_VALUE_NUM IS NULL
                      AND ATTR_DISP_VALUE IS NULL ' ;--BugFix : 4171705
                  DBMS_SQL.Parse(l_req_num_cursor_id, l_dynamic_sql, DBMS_SQL.NATIVE);
                  DBMS_SQL.Bind_Variable(l_req_num_cursor_id, ':data_set_id', p_data_set_id);
                END IF;

                DBMS_SQL.Bind_Variable(l_req_num_cursor_id, ':attr_group_int_name', l_attr_metadata_table_1(z).ATTR_GROUP_NAME);
                DBMS_SQL.Bind_Variable(l_req_num_cursor_id, ':attr_internal_name', l_attr_metadata_table_1(z).ATTR_NAME);

                l_dummy := DBMS_SQL.Execute(l_req_num_cursor_id);

              --------- FOR DATE AND DATE TIME DATATYPE
              ELSIF (l_attr_metadata_table_1(z).DATA_TYPE_CODE = EGO_EXT_FWK_PUB.G_DATE_DATA_TYPE OR l_attr_metadata_table_1(z).DATA_TYPE_CODE = EGO_EXT_FWK_PUB.G_DATE_TIME_DATA_TYPE) THEN
                IF (l_req_date_cursor_id IS NULL) THEN
                  l_req_date_cursor_id := DBMS_SQL.Open_Cursor;
                  l_dynamic_sql :=
                  'UPDATE '||p_interface_table_name||'
                      SET PROCESS_STATUS = PROCESS_STATUS + '||G_PS_REQUIRED_ATTRIBUTE||'
                    WHERE DATA_SET_ID = :data_set_id
                      AND PROCESS_STATUS = '||G_PS_IN_PROCESS|| '
                      AND BITAND(PROCESS_STATUS, '||G_PS_NO_PRIVILEGES||') = 0
                      AND ATTR_INT_NAME = :attr_internal_name
                      AND ATTR_GROUP_INT_NAME = :attr_group_int_name
                      AND ATTR_VALUE_DATE IS NULL
                      AND ATTR_DISP_VALUE IS NULL ' ;--BugFix : 4171705
                  DBMS_SQL.Parse(l_req_date_cursor_id, l_dynamic_sql, DBMS_SQL.NATIVE);
                  DBMS_SQL.Bind_Variable(l_req_date_cursor_id, ':data_set_id', p_data_set_id);
                END IF;

                DBMS_SQL.Bind_Variable(l_req_date_cursor_id, ':attr_group_int_name', l_attr_metadata_table_1(z).ATTR_GROUP_NAME);
                DBMS_SQL.Bind_Variable(l_req_date_cursor_id, ':attr_internal_name', l_attr_metadata_table_1(z).ATTR_NAME);

                l_dummy := DBMS_SQL.Execute(l_req_date_cursor_id);
                --------- FOR CHAR AND TRANSLATEBLE TEXT DATATYPE
                ELSE
                  IF (l_req_char_cursor_id IS NULL) THEN
                    l_req_char_cursor_id := DBMS_SQL.Open_Cursor;
                    l_dynamic_sql :=
                    'UPDATE '||p_interface_table_name||'
                        SET PROCESS_STATUS = PROCESS_STATUS + '||G_PS_REQUIRED_ATTRIBUTE||'
                      WHERE DATA_SET_ID = :data_set_id
                        AND PROCESS_STATUS = '||G_PS_IN_PROCESS|| '
                        AND BITAND(PROCESS_STATUS, '||G_PS_NO_PRIVILEGES||') = 0
                        AND ATTR_INT_NAME = :attr_internal_name
                        AND ATTR_GROUP_INT_NAME = :attr_group_int_name
                        AND ATTR_VALUE_STR IS NULL
                        AND ATTR_DISP_VALUE IS NULL ' ;--BugFix : 4171705
                    DBMS_SQL.Parse(l_req_char_cursor_id, l_dynamic_sql, DBMS_SQL.NATIVE);
                    DBMS_SQL.Bind_Variable(l_req_char_cursor_id, ':data_set_id', p_data_set_id);
                  END IF;

                  DBMS_SQL.Bind_Variable(l_req_char_cursor_id, ':attr_group_int_name', l_attr_metadata_table_1(z).ATTR_GROUP_NAME);
                  DBMS_SQL.Bind_Variable(l_req_char_cursor_id, ':attr_internal_name', l_attr_metadata_table_1(z).ATTR_NAME);

                  l_dummy := DBMS_SQL.Execute(l_req_char_cursor_id);
                END IF;
              END IF;--Required flag
           END IF;
        END LOOP;

      END IF;-- *p_validate-IF-3.1*
--Rathna ended

        -----------------------------------------------
        -- HERE ER FO TVS VALIDATION FOR SR AG
        ----------------------------------------------
      IF(p_validate) THEN --- Search for p_validate-IF-3.2 to find the ending of this loop

        IF (l_attr_group_metadata_obj.MULTI_ROW_CODE <> 'Y') THEN  -- i.e., if MULTI_ROW_CODE <> 'Y'

          code_debug('          Inside single row specific validations for Attribute Group :'||l_attr_group_intf_rec.ATTR_GROUP_INT_NAME ,2);

          -- now we go for doing the TVS validation if the AG is SR
          FOR x IN l_attr_metadata_table_sr.FIRST .. l_attr_metadata_table_sr.LAST
          LOOP

            IF (Attr_Is_In_Data_Set(l_attr_metadata_table_sr(X),
                                    l_dist_attrs_in_data_set_table)) THEN
              l_attr_exists_in_intf := 'EXISTS';
            ELSE
              l_attr_exists_in_intf := 'NOTEXISTS';
            END IF;

 --WE DO THE TVC VALIDATION FOR SRAG ONLY IF THIS ATTR HAS ATLEAST ONE VALID INSTANCE IN THE INTF TABLE
            IF (l_attr_exists_in_intf = 'EXISTS') THEN
              IF (l_attr_metadata_table_sr(x).VALIDATION_CODE = EGO_EXT_FWK_PUB.G_TABLE_VALIDATION_CODE) THEN

                code_debug('          The attribute :'||l_attr_metadata_table_sr(x).ATTR_NAME||' has a table value set attached to it with value set id :'||l_attr_metadata_table_sr(x).VALUE_SET_ID ,2);

                SELECT APPLICATION_TABLE_NAME,
                       VALUE_COLUMN_NAME,--VALUE_COLUMN_TYPE,VALUE_COLUMN_SIZE,
                       ID_COLUMN_NAME, --ID_COLUMN_TYPE, ID_COLUMN_SIZE,
                       MEANING_COLUMN_NAME, --MEANING_COLUMN_TYPE,
                       ADDITIONAL_WHERE_CLAUSE
                  INTO l_tvs_table_name,
                       l_tvs_val_col, --l_tvs_val_col_type, l_tvs_val_col_size,
                       l_tvs_id_col, --l_tvs_id_col_type, l_tvs_id_col_size
                       l_tvs_mean_col, --l_tvs_mean_col_type,
                       l_tvs_where_clause
                  FROM FND_FLEX_VALIDATION_TABLES
                 WHERE FLEX_VALUE_SET_ID = l_attr_metadata_table_sr(x).VALUE_SET_ID;

    --By GEGUO for bug 9218013
    l_tvs_where_clause := trim(l_tvs_where_clause) || '  ';--BugFix:4609213: in case we have a bind at the end it fails because of the assimption mentioned below !
                IF (l_tvs_id_col IS NOT NULL) THEN
                  l_tvs_col := l_tvs_id_col;
                ELSE
                  l_tvs_col := l_tvs_val_col;
                END IF;


    -- abedajna Bug 6207675
                --if ( l_tvs_where_clause is not null ) then
                --  l_tvs_where_clause := '('||l_tvs_where_clause||')';
                --end if;
    -- abedajna Bug 6322809

   -- bug 12889614, 13011041, system will not process the where clause if the
   --where clause does not start with order by statement.
   IF (INSTR(UPPER(LTRIM(l_tvs_where_clause)), 'ORDER ') <> 1) THEN
    l_tvs_where_clause := process_whereclause(l_tvs_where_clause);
   END IF;


                IF(INSTR(UPPER(LTRIM(l_tvs_where_clause)),'WHERE ')) = 1 THEN --BugFix : 4171705
                  l_tvs_where_clause := SUBSTR(l_tvs_where_clause, INSTR(UPPER(l_tvs_where_clause),'WHERE ')+5 );
                ELSIF (INSTR(UPPER(LTRIM(l_tvs_where_clause)),'(WHERE ')) = 1 THEN  /*Added one more condition for bug 7508982*/
                  l_tvs_where_clause := '('||SUBSTR(l_tvs_where_clause, INSTR(UPPER(l_tvs_where_clause),'WHERE ')+5 );
                END IF;

                ------------------------------------------------------
                -- In case the where clause has new line or tabs    --
                -- we need to remove it BugFix:4101091              --
                ------------------------------------------------------
                SELECT REPLACE(l_tvs_where_clause,FND_GLOBAL.LOCAL_CHR(10),FND_GLOBAL.LOCAL_CHR(32)) INTO l_tvs_where_clause FROM dual; --replacing new line character
                SELECT REPLACE(l_tvs_where_clause,FND_GLOBAL.LOCAL_CHR(13),FND_GLOBAL.LOCAL_CHR(32)) INTO l_tvs_where_clause FROM dual; --removing carriage return

                IF(INSTR(UPPER(l_tvs_where_clause),' ORDER ')) <> 0 THEN --Bug:4065857 gnanda we need to remove the order by clause if any in the where clause
                  l_tvs_where_clause := SUBSTR(l_tvs_where_clause, 1 , INSTR(UPPER(l_tvs_where_clause),' ORDER '));
                END IF;

                IF(INSTR(UPPER(l_tvs_where_clause),')ORDER ')) <> 0 THEN --BugFix:6133202
                  l_tvs_where_clause := SUBSTR(l_tvs_where_clause, 1 , INSTR(UPPER(l_tvs_where_clause),')ORDER '));
                END IF;


                IF(INSTR(UPPER(LTRIM(l_tvs_where_clause)),'ORDER ')) = 1 THEN --Bug:4065857 gnanda we need to remove the order by if where clause has only an order by
                  l_tvs_where_clause := SUBSTR(l_tvs_where_clause, 1 , INSTR(UPPER(l_tvs_where_clause),' ORDER '));
                  l_tvs_where_clause := ' 1=1 '|| l_tvs_where_clause;
                END IF;

                l_tvs_metadata_fetched := TRUE;

                WHILE (INSTR(l_tvs_where_clause, ':$ATTRIBUTEGROUP$') > 0)
                LOOP
                  l_attrname_start_index := INSTR(l_tvs_where_clause,':$ATTRIBUTEGROUP$') +18;
                  -- NOTE: WE ASSUME THAT WE WILL HAVE A SPACE AFTER THE ATTR NAME (will look into this later)
                  l_attrname_end_index   := INSTR(l_tvs_where_clause,' ',l_attrname_start_index,1);

                  l_bind_attr_name := SUBSTR(l_tvs_where_clause,l_attrname_start_index,l_attrname_end_index-l_attrname_start_index);

                  -- HERE WE GET THE COLNAME AND DATATYPE OF THE ATTRIBUTE USED AS BIND VARIABLE
                  FOR j IN l_attr_metadata_table_sr.FIRST .. l_attr_metadata_table_sr.LAST LOOP
                    IF (l_attr_metadata_table_sr(j).ATTR_NAME = l_bind_attr_name) THEN
                      l_ext_attr_col_name := l_attr_metadata_table_sr(j).DATABASE_COLUMN;
                      l_bind_attr_data_type := l_attr_metadata_table_sr(j).DATA_TYPE_CODE;
                    END IF;
                  END LOOP;

                  IF (l_ext_attr_col_name IS NULL OR l_bind_attr_data_type IS NULL) THEN
                    l_tvs_metadata_fetched := FALSE;
                  ELSE
                    l_tvs_metadata_fetched := TRUE;
                  END IF;
                  l_value_from_ext_table := '( SELECT '|| l_ext_attr_col_name ||'
                                                 FROM '||l_ext_vl_name||'
                                                WHERE ATTR_GROUP_ID = UAI1.ATTR_GROUP_ID ';

                  -- add the pk's
                  IF (l_pk1_column_name IS NOT NULL) THEN
                    l_value_from_ext_table := l_value_from_ext_table || ' AND '||l_pk1_column_name||' = UAI1.'||l_pk1_column_name;
                  END IF;
                  IF (l_pk2_column_name IS NOT NULL) THEN
                    l_value_from_ext_table := l_value_from_ext_table || ' AND '||l_pk2_column_name||' = UAI1.'||l_pk2_column_name;
                  END IF;
                  IF (l_pk3_column_name IS NOT NULL) THEN
                    l_value_from_ext_table := l_value_from_ext_table || ' AND '||l_pk3_column_name||' = UAI1.'||l_pk3_column_name;
                  END IF;
                  IF (l_pk4_column_name IS NOT NULL) THEN
                    l_value_from_ext_table := l_value_from_ext_table || ' AND '||l_pk4_column_name||' = UAI1.'||l_pk4_column_name;
                  END IF;
                  IF (l_pk5_column_name IS NOT NULL) THEN
                    l_value_from_ext_table := l_value_from_ext_table || ' AND '||l_pk5_column_name||' = UAI1.'||l_pk5_column_name;
                  END IF;

                  --bug 12397223 begin
                  OPEN enabled_data_level_cols(l_attr_group_metadata_obj.ATTR_GROUP_ID);
                  LOOP
                    FETCH enabled_data_level_cols INTO l_data_level_cols_rec;
                    EXIT WHEN enabled_data_level_cols%NOTFOUND;
                      IF(l_data_level_cols_rec.PK1_COLUMN_NAME IS NOT NULL) THEN
                        l_value_from_ext_table := l_value_from_ext_table || ' AND NVL('||l_data_level_cols_rec.PK1_COLUMN_NAME||',-1) =  NVL(UAI1.'||l_data_level_cols_rec.PK1_COLUMN_NAME||',-1)';
                      END IF;
                      IF(l_data_level_cols_rec.PK2_COLUMN_NAME IS NOT NULL) THEN
                        l_value_from_ext_table := l_value_from_ext_table || ' AND NVL('||l_data_level_cols_rec.PK2_COLUMN_NAME||',-1) =  NVL(UAI1.'||l_data_level_cols_rec.PK2_COLUMN_NAME||',-1)';
                      END IF;
                      IF(l_data_level_cols_rec.PK3_COLUMN_NAME IS NOT NULL) THEN
                        l_value_from_ext_table := l_value_from_ext_table || ' AND NVL('||l_data_level_cols_rec.PK3_COLUMN_NAME||',-1) =  NVL(UAI1.'||l_data_level_cols_rec.PK3_COLUMN_NAME||',-1)';
                      END IF;
                      IF(l_data_level_cols_rec.PK4_COLUMN_NAME IS NOT NULL) THEN
                        l_value_from_ext_table := l_value_from_ext_table || ' AND NVL('||l_data_level_cols_rec.PK4_COLUMN_NAME||',-1) =  NVL(UAI1.'||l_data_level_cols_rec.PK4_COLUMN_NAME||',-1)';
                      END IF;
                      IF(l_data_level_cols_rec.PK5_COLUMN_NAME IS NOT NULL) THEN
                        l_value_from_ext_table := l_value_from_ext_table || ' AND NVL('||l_data_level_cols_rec.PK5_COLUMN_NAME||',-1) =  NVL(UAI1.'||l_data_level_cols_rec.PK5_COLUMN_NAME||',-1)';
                      END IF;
                  END LOOP;
                  CLOSE enabled_data_level_cols;

                  /*IF (l_num_data_level_columns = 1) THEN
                    l_value_from_ext_table := l_value_from_ext_table || ' AND NVL('||l_data_level_column_1||',-1) =  NVL(UAI1.'||l_data_level_column_1||',-1)';

                  ELSIF (l_num_data_level_columns = 2) THEN
                    l_value_from_ext_table := l_value_from_ext_table || ' AND NVL('||l_data_level_column_1||',-1) =  NVL(UAI1.'||l_data_level_column_1||',-1)';
                    l_value_from_ext_table := l_value_from_ext_table || ' AND NVL('||l_data_level_column_2||',-1) =  NVL(UAI1.'||l_data_level_column_2||',-1)';

                  ELSIF (l_num_data_level_columns = 3) THEN
                    l_value_from_ext_table := l_value_from_ext_table || ' AND NVL('||l_data_level_column_1||',-1) =  NVL(UAI1.'||l_data_level_column_1||',-1)';
                    l_value_from_ext_table := l_value_from_ext_table || ' AND NVL('||l_data_level_column_2||',-1) =  NVL(UAI1.'||l_data_level_column_2||',-1)';
                    l_value_from_ext_table := l_value_from_ext_table || ' AND NVL('||l_data_level_column_3||',-1) =  NVL(UAI1.'||l_data_level_column_3||',-1)';
                  END IF;
                  */
                  --bug 12397223 end

                  IF (l_bind_attr_data_type = EGO_EXT_FWK_PUB.G_NUMBER_DATA_TYPE) THEN
                    l_value_from_intftbl := '(SELECT ATTR_VALUE_NUM FROM '||p_interface_table_name||'
                                                WHERE ROW_IDENTIFIER = UAI1.ROW_IDENTIFIER
                                                  AND DATA_SET_ID = :data_set_id
                                                  AND ATTR_INT_NAME = '''||l_bind_attr_name||''' )';
                  ELSIF (l_bind_attr_data_type = EGO_EXT_FWK_PUB.G_DATE_DATA_TYPE  OR l_bind_attr_data_type = EGO_EXT_FWK_PUB.G_DATE_TIME_DATA_TYPE) THEN
                    l_value_from_intftbl := '(SELECT ATTR_VALUE_DATE FROM '||p_interface_table_name||'
                                                WHERE ROW_IDENTIFIER = UAI1.ROW_IDENTIFIER
                                                  AND DATA_SET_ID = :data_set_id
                                                  AND ATTR_INT_NAME = '''||l_bind_attr_name||''' )';
                  ELSE
                    l_value_from_intftbl := '(SELECT ATTR_VALUE_STR FROM '||p_interface_table_name||'
                                                WHERE ROW_IDENTIFIER = UAI1.ROW_IDENTIFIER
                                                  AND DATA_SET_ID = :data_set_id
                                                  AND ATTR_INT_NAME = '''||l_bind_attr_name||''' )';
                  END IF;

                  l_value_from_ext_table := l_value_from_ext_table || ' )';
                  -- now we replace the :$ATTRIBUTEGROUP$.attrname with the query to find the value.

                  l_tvs_where_clause := SUBSTR(l_tvs_where_clause,1,INSTR(l_tvs_where_clause, ':$ATTRIBUTEGROUP$')-1) ||
                                                 '(NVL('||l_value_from_intftbl||',
                                                        DECODE(UAI1.TRANSACTION_TYPE, ''UPDATE'','||l_value_from_ext_table||',''CREATE'',NULL,NULL)
                                                       )
                                                   )'||
                                                 SUBSTR(l_tvs_where_clause,l_attrname_end_index);

                END LOOP;
                WHILE (INSTR(l_tvs_where_clause, ':$OBJECT$') > 0)
                LOOP
                  SELECT REPLACE(l_tvs_where_clause,':$OBJECT$','UAI1') INTO l_tvs_where_clause FROM DUAL;
                END LOOP;
  /*
THERE COULD BE A POSSIBILITY THAT THE TVS QUERY RETURNS MORE THAN ONE ROW
IN THIS CASE WE JUST TAKE THE FIRST ROW : ( i.e. WHERE ROWNUM = 1)
  */
                l_tvs_where_clause := RTRIM(LTRIM(l_tvs_where_clause));

                IF LENGTH(l_tvs_where_clause)<3 OR LENGTH(l_tvs_where_clause) IS NULL THEN                  --added for bugFix:4609213
                  l_tvs_where_clause := ' 1=1 '||l_tvs_where_clause;
                END IF;

                l_tvs_select := '(SELECT DISTINCT '||l_tvs_col||' FROM '||l_tvs_table_name||'
                                   WHERE '||l_tvs_where_clause||'
                                     AND ROWNUM = 1
                         AND '||l_tvs_val_col||' = UAI1.ATTR_DISP_VALUE )';--BugFix : 4171705

                l_tvs_num_val_check_select := '(SELECT COUNT(*) FROM '||l_tvs_table_name||'
                                   WHERE '||l_tvs_where_clause||'
                                     AND ROWNUM = 1
                         AND '||l_tvs_col||' = UAI1.ATTR_VALUE_NUM )';

                l_tvs_date_val_check_select := '(SELECT COUNT(*) FROM '||l_tvs_table_name||'
                                   WHERE '||l_tvs_where_clause||'
                                     AND ROWNUM = 1
                         AND '||l_tvs_col||' = UAI1.ATTR_VALUE_DATE )';

                l_tvs_str_val_check_select := '(SELECT COUNT(*) FROM '||l_tvs_table_name||'
                                   WHERE '||l_tvs_where_clause||'
                                     AND ROWNUM = 1
                         AND '||l_tvs_col||' = UAI1.ATTR_VALUE_STR )';

                code_debug('          The TVS select constructed is :'||l_tvs_select ,3);

                IF (l_tvs_metadata_fetched = FALSE) THEN
                  IF (l_bad_bindattrs_tvs_cursor_id IS NULL) THEN
                    l_bad_bindattrs_tvs_cursor_id := DBMS_SQL.Open_Cursor;
                    l_dynamic_sql :=
                    'UPDATE '||p_interface_table_name||'
                        SET PROCESS_STATUS = PROCESS_STATUS + '||G_PS_BAD_ATTRS_IN_TVS_WHERE||'
                      WHERE DATA_SET_ID = :data_set_id
                        AND ATTR_INT_NAME = :attr_internal_name
                        AND ATTR_GROUP_INT_NAME = :attr_group_int_name';

                    DBMS_SQL.Parse(l_bad_bindattrs_tvs_cursor_id, l_dynamic_sql, DBMS_SQL.NATIVE);
                    DBMS_SQL.Bind_Variable(l_bad_bindattrs_tvs_cursor_id, ':data_set_id', p_data_set_id);
                  END IF;

                  DBMS_SQL.Bind_Variable(l_bad_bindattrs_tvs_cursor_id, ':attr_group_int_name', l_attr_group_metadata_obj.ATTR_GROUP_NAME);
                  DBMS_SQL.Bind_Variable(l_bad_bindattrs_tvs_cursor_id, ':attr_internal_name', l_attr_metadata_table_sr(x).ATTR_NAME);
                  l_dummy := DBMS_SQL.Execute(l_bad_bindattrs_tvs_cursor_id);
                ELSE -- now we do the interface table update since we are sure we have the metadata for bound variables

  /*
Note: we are assuming that the setup is correct i.e. the column of the TVS are of correct data type
the id col is of datatype same as the attribute
the meanin col is of type character.
another assumtion is that the user cannot enter the value directly in to the attr_val_* col
he has to enter the data in attr_disp_Value column for which we get the actual attr val.
  */
                  IF (l_attr_metadata_table_sr(x).DATA_TYPE_CODE = EGO_EXT_FWK_PUB.G_NUMBER_DATA_TYPE) THEN

                    l_dynamic_sql_1 :=
                    'UPDATE '||p_interface_table_name||' UAI1
                        SET PROCESS_STATUS = PROCESS_STATUS + DECODE(('||l_tvs_num_val_check_select||'),0,'||G_PS_VALUE_NOT_IN_TVS||',0)
                      WHERE DATA_SET_ID = :data_set_id
                        AND (PROCESS_STATUS = '||G_PS_IN_PROCESS||' OR PROCESS_STATUS > '||G_PS_BAD_ATTR_OR_AG_METADATA||' )
                        AND BITAND(PROCESS_STATUS, '||G_PS_NO_PRIVILEGES||') = 0
                        AND ATTR_INT_NAME = '''||l_attr_metadata_table_sr(x).ATTR_NAME||'''
                        AND ATTR_GROUP_INT_NAME = '''||l_attr_group_metadata_obj.ATTR_GROUP_NAME||'''
                        AND ATTR_VALUE_NUM IS NOT NULL';

                    l_dynamic_sql :=
                    'UPDATE '||p_interface_table_name||' UAI1
                        SET ATTR_VALUE_NUM = NVL('||l_tvs_select||',NULL),
                            PROCESS_STATUS = PROCESS_STATUS + DECODE(('||l_tvs_select||'),NULL,'||G_PS_VALUE_NOT_IN_TVS||',0)
                      WHERE DATA_SET_ID = :data_set_id
                        AND (PROCESS_STATUS = '||G_PS_IN_PROCESS||' OR PROCESS_STATUS > '||G_PS_BAD_ATTR_OR_AG_METADATA||' )
                        AND BITAND(PROCESS_STATUS, '||G_PS_NO_PRIVILEGES||') = 0
                        AND ATTR_INT_NAME = '''||l_attr_metadata_table_sr(x).ATTR_NAME||'''
                        AND ATTR_GROUP_INT_NAME = '''||l_attr_group_metadata_obj.ATTR_GROUP_NAME||'''
                        AND ATTR_DISP_VALUE IS NOT NULL ';
                    -- We execute the above cursor in a PL/SQL block since we know that if this fails
                    -- it is because of wrong setup the user has created for table value sets, so we
                    -- need to mark the row as errored due to bad TVS setup.

                    BEGIN
                      --EXECUTE IMMEDIATE l_dynamic_sql_1;
                      IF (l_sr_tvs_num_cursor_id1 IS NULL) THEN
                        l_sr_tvs_num_cursor_id1 := DBMS_SQL.Open_Cursor;
                      END IF;
                      DBMS_SQL.Parse(l_sr_tvs_num_cursor_id1, l_dynamic_sql_1, DBMS_SQL.NATIVE);
                      DBMS_SQL.Bind_Variable(l_sr_tvs_num_cursor_id1, ':data_set_id', p_data_set_id);
                      l_dummy := DBMS_SQL.Execute(l_sr_tvs_num_cursor_id1);

                      --EXECUTE IMMEDIATE l_dynamic_sql;
                      IF (l_sr_tvs_num_cursor_id2 IS NULL) THEN
                        l_sr_tvs_num_cursor_id2 := DBMS_SQL.Open_Cursor;
                      END IF;
                      DBMS_SQL.Parse(l_sr_tvs_num_cursor_id2, l_dynamic_sql, DBMS_SQL.NATIVE);
                      DBMS_SQL.Bind_Variable(l_sr_tvs_num_cursor_id2, ':data_set_id', p_data_set_id);
                      l_dummy := DBMS_SQL.Execute(l_sr_tvs_num_cursor_id2);

                    EXCEPTION
                      WHEN OTHERS THEN
                        IF (l_bad_tvs_sql_cursor_id IS NULL) THEN
                          l_bad_tvs_sql_cursor_id := DBMS_SQL.Open_Cursor;
                          l_dynamic_sql :=
                          'UPDATE '||p_interface_table_name||'
                              SET PROCESS_STATUS = PROCESS_STATUS + '||G_PS_BAD_TVS_SETUP||'
                            WHERE DATA_SET_ID = :data_set_id
                              AND ATTR_INT_NAME = :attr_internal_name
                              AND ATTR_GROUP_INT_NAME = :attr_group_int_name';

                          DBMS_SQL.Parse(l_bad_tvs_sql_cursor_id, l_dynamic_sql, DBMS_SQL.NATIVE);
                          DBMS_SQL.Bind_Variable(l_bad_tvs_sql_cursor_id, ':data_set_id', p_data_set_id);
                        END IF;
                        DBMS_SQL.Bind_Variable(l_bad_tvs_sql_cursor_id, ':attr_group_int_name', l_attr_group_metadata_obj.ATTR_GROUP_NAME);
                        DBMS_SQL.Bind_Variable(l_bad_tvs_sql_cursor_id, ':attr_internal_name', l_attr_metadata_table_sr(x).ATTR_NAME);
                        l_dummy := DBMS_SQL.Execute(l_bad_tvs_sql_cursor_id);
                    END;

                  ELSIF (l_attr_metadata_table_sr(x).DATA_TYPE_CODE = EGO_EXT_FWK_PUB.G_DATE_DATA_TYPE OR l_attr_metadata_table_sr(x).DATA_TYPE_CODE = EGO_EXT_FWK_PUB.G_DATE_TIME_DATA_TYPE) THEN

                    l_dynamic_sql_1 :=
                    'UPDATE '||p_interface_table_name||' UAI1
                        SET PROCESS_STATUS = PROCESS_STATUS + DECODE(('||l_tvs_date_val_check_select||'),0,'||G_PS_VALUE_NOT_IN_TVS||',0)
                      WHERE DATA_SET_ID = :data_set_id
                        AND (PROCESS_STATUS = '||G_PS_IN_PROCESS||' OR PROCESS_STATUS > '||G_PS_BAD_ATTR_OR_AG_METADATA||' )
                        AND BITAND(PROCESS_STATUS, '||G_PS_NO_PRIVILEGES||') = 0
                        AND ATTR_INT_NAME = '''||l_attr_metadata_table_sr(x).ATTR_NAME||'''
                        AND ATTR_GROUP_INT_NAME = '''||l_attr_group_metadata_obj.ATTR_GROUP_NAME||'''
                        AND ATTR_VALUE_DATE IS NOT NULL';

                    l_dynamic_sql :=
                    'UPDATE '||p_interface_table_name||' UAI1
                        SET ATTR_VALUE_DATE = NVL('||l_tvs_select||',NULL),
                            PROCESS_STATUS = PROCESS_STATUS + DECODE(('||l_tvs_select||'),NULL,'||G_PS_VALUE_NOT_IN_TVS||',0)
                      WHERE DATA_SET_ID = :data_set_id
                        AND (PROCESS_STATUS = '||G_PS_IN_PROCESS||' OR PROCESS_STATUS > '||G_PS_BAD_ATTR_OR_AG_METADATA||' )
                        AND BITAND(PROCESS_STATUS, '||G_PS_NO_PRIVILEGES||') = 0
                        AND ATTR_INT_NAME = '''||l_attr_metadata_table_sr(x).ATTR_NAME||'''
                        AND ATTR_GROUP_INT_NAME = '''||l_attr_group_metadata_obj.ATTR_GROUP_NAME||'''
                        AND ATTR_DISP_VALUE IS NOT NULL ';

                    -- We execute the above cursor in a PL/SQL block since we know that if this fails
                    -- it is because of wrong setup the user has created for table value sets, so we
                    -- need to mark the row as errored due to bad TVS setup.
                    BEGIN

                      --EXECUTE IMMEDIATE l_dynamic_sql_1;
                      IF (l_sr_tvs_date_cursor_id1 IS NULL) THEN
                        l_sr_tvs_date_cursor_id1 := DBMS_SQL.Open_Cursor;
                      END IF;
                      DBMS_SQL.Parse(l_sr_tvs_date_cursor_id1, l_dynamic_sql_1, DBMS_SQL.NATIVE);
                      DBMS_SQL.Bind_Variable(l_sr_tvs_date_cursor_id1, ':data_set_id', p_data_set_id);
                      l_dummy := DBMS_SQL.Execute(l_sr_tvs_date_cursor_id1);

                      --EXECUTE IMMEDIATE l_dynamic_sql;
                      IF (l_sr_tvs_date_cursor_id2 IS NULL) THEN
                        l_sr_tvs_date_cursor_id2 := DBMS_SQL.Open_Cursor;
                      END IF;
                      DBMS_SQL.Parse(l_sr_tvs_date_cursor_id2, l_dynamic_sql, DBMS_SQL.NATIVE);
                      DBMS_SQL.Bind_Variable(l_sr_tvs_date_cursor_id2, ':data_set_id', p_data_set_id);
                      l_dummy := DBMS_SQL.Execute(l_sr_tvs_date_cursor_id2);

                    EXCEPTION
                      WHEN OTHERS THEN
                        IF (l_bad_tvs_sql_cursor_id IS NULL) THEN
                          l_bad_tvs_sql_cursor_id := DBMS_SQL.Open_Cursor;
                          l_dynamic_sql :=
                          'UPDATE '||p_interface_table_name||'
                              SET PROCESS_STATUS = PROCESS_STATUS + '||G_PS_BAD_TVS_SETUP||'
                            WHERE DATA_SET_ID = :data_set_id
                              AND ATTR_INT_NAME = :attr_internal_name
                              AND ATTR_GROUP_INT_NAME = :attr_group_int_name';

                          DBMS_SQL.Parse(l_bad_tvs_sql_cursor_id, l_dynamic_sql, DBMS_SQL.NATIVE);
                          DBMS_SQL.Bind_Variable(l_bad_tvs_sql_cursor_id, ':data_set_id', p_data_set_id);
                        END IF;
                        DBMS_SQL.Bind_Variable(l_bad_tvs_sql_cursor_id, ':attr_group_int_name', l_attr_group_metadata_obj.ATTR_GROUP_NAME);
                        DBMS_SQL.Bind_Variable(l_bad_tvs_sql_cursor_id, ':attr_internal_name', l_attr_metadata_table_sr(x).ATTR_NAME);
                        l_dummy := DBMS_SQL.Execute(l_bad_tvs_sql_cursor_id);
                    END;
                  ELSE
                    l_dynamic_sql_1 :=
                    'UPDATE '||p_interface_table_name||' UAI1
                        SET PROCESS_STATUS = PROCESS_STATUS + DECODE(('||l_tvs_str_val_check_select||'),0,'||G_PS_VALUE_NOT_IN_TVS||',0)
                      WHERE DATA_SET_ID = :data_set_id
                        AND (PROCESS_STATUS = '||G_PS_IN_PROCESS||' OR PROCESS_STATUS > '||G_PS_BAD_ATTR_OR_AG_METADATA||' )
                        AND BITAND(PROCESS_STATUS, '||G_PS_NO_PRIVILEGES||') = 0
                        AND ATTR_INT_NAME = '''||l_attr_metadata_table_sr(x).ATTR_NAME||'''
                        AND ATTR_GROUP_INT_NAME = '''||l_attr_group_metadata_obj.ATTR_GROUP_NAME||'''
                        AND ATTR_VALUE_STR IS NOT NULL';

                    l_dynamic_sql :=
                    'UPDATE '||p_interface_table_name||' UAI1
                        SET ATTR_VALUE_STR = NVL('||l_tvs_select||',NULL),
                            PROCESS_STATUS = PROCESS_STATUS + DECODE(('||l_tvs_select||'),NULL,'||G_PS_VALUE_NOT_IN_TVS||',0)
                      WHERE DATA_SET_ID = :data_set_id
                        AND (PROCESS_STATUS = '||G_PS_IN_PROCESS||' OR PROCESS_STATUS > '||G_PS_BAD_ATTR_OR_AG_METADATA||' )
                        AND BITAND(PROCESS_STATUS, '||G_PS_NO_PRIVILEGES||') = 0
                        AND ATTR_INT_NAME = '''||l_attr_metadata_table_sr(x).ATTR_NAME||'''
                        AND ATTR_GROUP_INT_NAME = '''||l_attr_group_metadata_obj.ATTR_GROUP_NAME||'''
                        AND ATTR_DISP_VALUE IS NOT NULL ';
                    -- We execute the above cursor in a PL/SQL block since we know that if this fails
                    -- it is because of wrong setup the user has created for table value sets, so we
                    -- need to mark the row as errored due to bad TVS setup.
                    BEGIN
                      --EXECUTE IMMEDIATE l_dynamic_sql_1;
                      IF (l_sr_tvs_str_cursor_id1 IS NULL) THEN
                        l_sr_tvs_str_cursor_id1 := DBMS_SQL.Open_Cursor;
                      END IF;
                      DBMS_SQL.Parse(l_sr_tvs_str_cursor_id1, l_dynamic_sql_1, DBMS_SQL.NATIVE);
                      DBMS_SQL.Bind_Variable(l_sr_tvs_str_cursor_id1, ':data_set_id', p_data_set_id);
                      l_dummy := DBMS_SQL.Execute(l_sr_tvs_str_cursor_id1);

                      --EXECUTE IMMEDIATE l_dynamic_sql;
                      IF (l_sr_tvs_str_cursor_id2 IS NULL) THEN
                        l_sr_tvs_str_cursor_id2 := DBMS_SQL.Open_Cursor;
                      END IF;
                      DBMS_SQL.Parse(l_sr_tvs_str_cursor_id2, l_dynamic_sql, DBMS_SQL.NATIVE);
                      DBMS_SQL.Bind_Variable(l_sr_tvs_str_cursor_id2, ':data_set_id', p_data_set_id);
                      l_dummy := DBMS_SQL.Execute(l_sr_tvs_str_cursor_id2);

                    EXCEPTION
                      WHEN OTHERS THEN
                        IF (l_bad_tvs_sql_cursor_id IS NULL) THEN
                          l_bad_tvs_sql_cursor_id := DBMS_SQL.Open_Cursor;
                          l_dynamic_sql :=
                          'UPDATE '||p_interface_table_name||'
                              SET PROCESS_STATUS = PROCESS_STATUS + '||G_PS_BAD_TVS_SETUP||'
                            WHERE DATA_SET_ID = :data_set_id
                              AND ATTR_INT_NAME = :attr_internal_name
                              AND ATTR_GROUP_INT_NAME = :attr_group_int_name';

                          DBMS_SQL.Parse(l_bad_tvs_sql_cursor_id, l_dynamic_sql, DBMS_SQL.NATIVE);
                          DBMS_SQL.Bind_Variable(l_bad_tvs_sql_cursor_id, ':data_set_id', p_data_set_id);
                        END IF;
                        DBMS_SQL.Bind_Variable(l_bad_tvs_sql_cursor_id, ':attr_group_int_name', l_attr_group_metadata_obj.ATTR_GROUP_NAME);
                        DBMS_SQL.Bind_Variable(l_bad_tvs_sql_cursor_id, ':attr_internal_name', l_attr_metadata_table_sr(x).ATTR_NAME);
                        l_dummy := DBMS_SQL.Execute(l_bad_tvs_sql_cursor_id);
                    END;
                  END IF;
                END IF; --l_attr_metadata TRUE/FALSE
              END IF; -- if validation_code is TVS
            END IF;--the if attr exists in the intf table ends.
          END LOOP; --end of all attr loop.
        END IF; -- ending of  single row OR MULTI ROW if

        code_debug('          Now done with the validations for ATTR GROUP LEVEL validations ',2);

      END IF;  --  *p_validate-IF-3.3* ending the p_validate IF

      -----------------------------------------------------
      -- NOW WE WILL RAISE PRE-EVENTS FOR THE PASSED AG's
      -- (if the pre_events are enabled for the ag)
      -- ONLY IF THE PARAMETER p_do_dml IS TRUE
      -----------------------------------------------------
      IF (p_do_dml) THEN --search for *p_do_dml-IF-1* to locate the END

        BEGIN
          SELECT PRE_BUSINESS_EVENT_NAME
            INTO l_pre_event_name
            FROM EGO_FND_DESC_FLEXS_EXT
           WHERE APPLICATION_ID = p_application_id
             AND DESCRIPTIVE_FLEXFIELD_NAME = p_attr_group_type;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            l_pre_event_name := NULL;
        END;

       SELECT COUNT(*)
          INTO l_dummy
          FROM EGO_ATTR_GROUP_DL
         WHERE ATTR_GROUP_ID = l_attr_group_metadata_obj.ATTR_GROUP_ID
           AND RAISE_PRE_EVENT = 'Y';

        IF (l_dummy > 0) THEN
          l_is_pre_event_enabled_flag := 'Y';
        ELSE
          l_is_pre_event_enabled_flag := 'N';
        END IF;

        code_debug('inside raising events   l_is_pre_event_enabled_flag-'||l_is_pre_event_enabled_flag);

        /*Code changes for bug 8485287*/
           /* Added code to raise postAttributeChange BE for call of public API to create Item. */
           BEGIN
             SELECT BUSINESS_EVENT_NAME
               INTO l_new_post_event_name
             FROM EGO_FND_DESC_FLEXS_EXT
             WHERE APPLICATION_ID = p_application_id
               AND DESCRIPTIVE_FLEXFIELD_NAME = p_attr_group_type;
           EXCEPTION
             WHEN NO_DATA_FOUND THEN
               l_new_post_event_name := NULL;
           END;

        -- Bug 10090254 Changes : Start
        /*
        SELECT BUSINESS_EVENT_FLAG
         INTO l_new_post_event_enabled_flag
        FROM EGO_FND_DSC_FLX_CTX_EXT
        WHERE ATTR_GROUP_ID = l_attr_group_metadata_obj.ATTR_GROUP_ID;
        */

        SELECT COUNT(*)
        INTO  l_dummy
        FROM  EGO_ATTR_GROUP_DL
        WHERE ATTR_GROUP_ID = l_attr_group_metadata_obj.ATTR_GROUP_ID
          AND RAISE_POST_EVENT = 'Y';

        IF (l_dummy > 0) THEN
          l_new_post_event_enabled_flag := 'Y';
        ELSE
          l_new_post_event_enabled_flag := 'N';
        END IF;

        code_debug('inside raising events   l_new_post_event_enabled_flag - '||l_new_post_event_enabled_flag);
        -- Bug 10090254 Changes : End


           IF ((l_new_post_event_name IS NOT NULL AND l_new_post_event_enabled_flag = 'Y')  ) THEN

             l_dynamic_sql := ' SELECT EXTVL1.EXTENSION_ID , UAI1.ATTR_GROUP_INT_NAME, UAI1.TRANSACTION_TYPE, UAI1.ROW_IDENTIFIER ';
             l_group_by_pre := ' GROUP BY EXTVL1.EXTENSION_ID , UAI1.ATTR_GROUP_INT_NAME, UAI1.TRANSACTION_TYPE, UAI1.ROW_IDENTIFIER ';
                     l_dynamic_sql_delete_post := ' SELECT NULL , UAI1.ATTR_GROUP_INT_NAME, UAI1.TRANSACTION_TYPE, UAI1.ROW_IDENTIFIER ';
             l_dynamic_group_by := ' ';
             l_deflatening_sql_where := ' ';
             l_dynamic_query := ' ';

             IF (l_pk1_column_name IS NOT NULL) THEN
               l_dynamic_query := l_dynamic_query || ' , UAI1.' ||l_pk1_column_name;
               l_dynamic_group_by := l_dynamic_group_by || ' , UAI1.' ||l_pk1_column_name;
               l_deflatening_sql_where := l_deflatening_sql_where || ' AND UAI1.'||l_pk1_column_name||' = '||' EXTVL1.'||l_pk1_column_name;
             ELSE
               l_dynamic_query := l_dynamic_query || ' , NULL ';
             END IF;

             IF (l_pk2_column_name IS NOT NULL) THEN
               l_dynamic_query := l_dynamic_query || ' , UAI1.' ||l_pk2_column_name;
               l_dynamic_group_by := l_dynamic_group_by || ' , UAI1.' ||l_pk2_column_name;
               l_deflatening_sql_where := l_deflatening_sql_where || ' AND UAI1.'||l_pk2_column_name||' = '||' EXTVL1.'||l_pK2_column_name;
             ELSE
               l_dynamic_query := l_dynamic_query || ' , NULL ';
             END IF;

             IF (l_pk3_column_name IS NOT NULL) THEN
               l_dynamic_query := l_dynamic_query || ' , UAI1.' ||l_pk3_column_name;
               l_dynamic_group_by := l_dynamic_group_by || ' , UAI1.' ||l_pk3_column_name;
               l_deflatening_sql_where := l_deflatening_sql_where || ' AND UAI1.'||l_pk3_column_name||' = '||' EXTVL1.'||l_pk3_column_name;
             ELSE
               l_dynamic_query := l_dynamic_query || ' , NULL ';
             END IF;

             IF (l_pk4_column_name IS NOT NULL) THEN
               l_dynamic_query := l_dynamic_query || ' , UAI1.' ||l_pk4_column_name;
               l_dynamic_group_by := l_dynamic_group_by || ' , UAI1.' ||l_pk4_column_name;
               l_deflatening_sql_where := l_deflatening_sql_where || ' AND UAI1.'||l_pk4_column_name||' = '||' EXTVL1.'||l_pk4_column_name;
             ELSE
               l_dynamic_query := l_dynamic_query || ' , NULL ';
             END IF;
             IF (l_pk5_column_name IS NOT NULL) THEN
               l_dynamic_query := l_dynamic_query || ' , UAI1.' ||l_pk5_column_name;
               l_dynamic_group_by := l_dynamic_group_by || ' , UAI1.' ||l_pk5_column_name;
               l_deflatening_sql_where := l_deflatening_sql_where || ' AND UAI1.'||l_pk5_column_name||' = '||' EXTVL1.'||l_pk5_column_name;
             ELSE
               l_dynamic_query := l_dynamic_query || ' , NULL ';
             END IF;

             -- Bug 10090254 Code changes : Start
             /*
             IF (l_num_data_level_columns = 0) THEN
                l_dynamic_query := l_dynamic_query ||' , NULL ';
                l_dynamic_query := l_dynamic_query ||' , NULL ';
                l_dynamic_query := l_dynamic_query ||' , NULL ';
             ELSIF (l_num_data_level_columns = 1) THEN
                l_dynamic_query := l_dynamic_query ||' , UAI1.' ||l_data_level_column_1;
                l_dynamic_query := l_dynamic_query ||' , NULL ';
                l_dynamic_query := l_dynamic_query ||' , NULL ';
                l_dynamic_group_by := l_dynamic_group_by ||' , UAI1.' ||l_data_level_column_1;
                l_deflatening_sql_where := l_deflatening_sql_where || ' AND (UAI1.'||l_data_level_column_1||' = '||' EXTVL1.'||l_data_level_column_1||' OR ('||'UAI1.'||l_data_level_column_1|| ' IS NULL AND EXTVL1.'||l_data_level_column_1||' IS NULL))' ;
             ELSIF (l_num_data_level_columns = 2) THEN
                l_dynamic_query := l_dynamic_query ||' , UAI1.' ||l_data_level_column_1;
                l_dynamic_query := l_dynamic_query ||' , UAI1.' ||l_data_level_column_2;
                l_dynamic_query := l_dynamic_query ||' , NULL ';
                l_dynamic_group_by := l_dynamic_group_by ||' , UAI1.' ||l_data_level_column_1;
                l_dynamic_group_by := l_dynamic_group_by ||' , UAI1.' ||l_data_level_column_2;
                l_deflatening_sql_where := l_deflatening_sql_where || ' AND (UAI1.'||l_data_level_column_1||' = '||' EXTVL1.'||l_data_level_column_1||' OR ('||'UAI1.'||l_data_level_column_1|| ' IS NULL AND EXTVL1.'||l_data_level_column_1||' IS NULL))' ;
                l_deflatening_sql_where := l_deflatening_sql_where || ' AND (UAI1.'||l_data_level_column_2||' = '||' EXTVL1.'||l_data_level_column_2||' OR ('||'UAI1.'||l_data_level_column_2|| ' IS NULL AND EXTVL1.'||l_data_level_column_2||' IS NULL))' ;
             ELSIF (l_num_data_level_columns = 3) THEN
                l_dynamic_query := l_dynamic_query ||' , UAI1.' ||l_data_level_column_1;
                l_dynamic_query := l_dynamic_query ||' , UAI1.' ||l_data_level_column_2;
                l_dynamic_query := l_dynamic_query ||' , UAI1.' ||l_data_level_column_3;
                l_dynamic_group_by := l_dynamic_group_by ||' , UAI1.' ||l_data_level_column_1;
                l_dynamic_group_by := l_dynamic_group_by ||' , UAI1.' ||l_data_level_column_2;
                l_dynamic_group_by := l_dynamic_group_by ||' , UAI1.' ||l_data_level_column_3;
                l_deflatening_sql_where := l_deflatening_sql_where || ' AND (UAI1.'||l_data_level_column_1||' = '||' EXTVL1.'||l_data_level_column_1||' OR ('||'UAI1.'||l_data_level_column_1|| ' IS NULL AND EXTVL1.'||l_data_level_column_1||' IS NULL))' ;
                l_deflatening_sql_where := l_deflatening_sql_where || ' AND (UAI1.'||l_data_level_column_2||' = '||' EXTVL1.'||l_data_level_column_2||' OR ('||'UAI1.'||l_data_level_column_2|| ' IS NULL AND EXTVL1.'||l_data_level_column_2||' IS NULL))' ;
                l_deflatening_sql_where := l_deflatening_sql_where || ' AND (UAI1.'||l_data_level_column_3||' = '||' EXTVL1.'||l_data_level_column_3||' OR ('||'UAI1.'||l_data_level_column_3|| ' IS NULL AND EXTVL1.'||l_data_level_column_3||' IS NULL))' ;
             END IF;
             */

              --------------------------------------
              -- Adding the data level columns ...
              --------------------------------------
              IF(l_data_level_col_exists) THEN

                l_dynamic_query := l_dynamic_query||' , UAI1.DATA_LEVEL_ID ';
                l_dynamic_group_by := l_dynamic_group_by ||' , UAI1.DATA_LEVEL_ID ';
                l_deflatening_sql_where := l_deflatening_sql_where || ' AND NVL(UAI1.DATA_LEVEL_ID,-1) = NVL(EXTVL1.DATA_LEVEL_ID,-1) ';

               l_dl_pk_col1_sql:=NULL;
               l_dl_pk_col2_sql:=NULL;
               l_dl_pk_col3_sql:=NULL;
               l_dl_pk_col4_sql:=NULL;
               l_dl_pk_col5_sql:=NULL;

               FOR i IN l_list_of_dl_for_ag_type.FIRST .. l_list_of_dl_for_ag_type.LAST
               LOOP
                  l_dl_pk_col1_sql := l_dl_pk_col1_sql||' , '||l_list_of_dl_for_ag_type(i).DATA_LEVEL_ID||' ';
                  l_dl_pk_col2_sql := l_dl_pk_col2_sql||' , '||l_list_of_dl_for_ag_type(i).DATA_LEVEL_ID||' ';
                  l_dl_pk_col3_sql := l_dl_pk_col3_sql||' , '||l_list_of_dl_for_ag_type(i).DATA_LEVEL_ID||' ';
                  l_dl_pk_col4_sql := l_dl_pk_col4_sql||' , '||l_list_of_dl_for_ag_type(i).DATA_LEVEL_ID||' ';
                  l_dl_pk_col5_sql := l_dl_pk_col5_sql||' , '||l_list_of_dl_for_ag_type(i).DATA_LEVEL_ID||' ';

                  IF (l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME1 IS NOT NULL AND l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME1 <> 'NONE'
                     AND INSTR(l_dynamic_query,l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME1) = 0) THEN

                          l_dl_pk_col1_sql := l_dl_pk_col1_sql||' , UAI1.' ||l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME1;
                          l_dynamic_group_by := l_dynamic_group_by ||' , UAI1.' ||l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME1;
                          l_deflatening_sql_where := l_deflatening_sql_where || ' AND (UAI1.'||l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME1||
                                                                                       ' = '||' EXTVL1.'||l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME1||
                                                                                ' OR  ('||'UAI1.'||l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME1|| ' IS NULL '||
                                                                                       'AND EXTVL1.'||l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME1||' IS NULL))' ;
                  ELSE
                          l_dl_pk_col1_sql := l_dl_pk_col1_sql||' , NULL ';
                  END IF;
                  IF (l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME2 IS NOT NULL AND l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME2 <> 'NONE'
                     AND INSTR(l_dynamic_query,l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME2) = 0) THEN
                          l_dl_pk_col2_sql := l_dl_pk_col2_sql||' , UAI1.' ||l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME2;
                          l_dynamic_group_by := l_dynamic_group_by ||' , UAI1.' ||l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME2;
                          l_deflatening_sql_where := l_deflatening_sql_where || ' AND (UAI1.'||l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME2||
                                                                                       ' = '||' EXTVL1.'||l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME2||
                                                                                ' OR  ('||'UAI1.'||l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME2|| ' IS NULL '||
                                                                                       'AND EXTVL1.'||l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME2||' IS NULL))' ;

                  ELSE
                          l_dl_pk_col2_sql := l_dl_pk_col2_sql||' , NULL ';
                  END IF;
                  IF (l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME3 IS NOT NULL AND l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME3 <> 'NONE'
                     AND INSTR(l_dynamic_query,l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME3) = 0) THEN
                          l_dl_pk_col3_sql := l_dl_pk_col3_sql||' , UAI1.' ||l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME3;
                          l_dynamic_group_by := l_dynamic_group_by ||' , UAI1.' ||l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME3;
                          l_deflatening_sql_where := l_deflatening_sql_where || ' AND (UAI1.'||l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME3||
                                                                                       ' = '||' EXTVL1.'||l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME3||
                                                                                ' OR  ('||'UAI1.'||l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME3|| ' IS NULL '||
                                                                                       'AND EXTVL1.'||l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME3||' IS NULL))' ;

                  ELSE
                          l_dl_pk_col3_sql := l_dl_pk_col3_sql||' , NULL ';
                  END IF;
                  IF (l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME4 IS NOT NULL AND l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME4 <> 'NONE'
                     AND INSTR(l_dynamic_query,l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME4) = 0) THEN
                          l_dl_pk_col4_sql := l_dl_pk_col4_sql||' , UAI1.' ||l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME4;
                          l_dynamic_group_by := l_dynamic_group_by ||' , UAI1.' ||l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME4;
                          l_deflatening_sql_where := l_deflatening_sql_where || ' AND (UAI1.'||l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME4||
                                                                                       ' = '||' EXTVL1.'||l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME4||
                                                                                ' OR  ('||'UAI1.'||l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME4|| ' IS NULL '||
                                                                                       'AND EXTVL1.'||l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME4||' IS NULL))' ;

                  ELSE
                          l_dl_pk_col4_sql := l_dl_pk_col4_sql||' , NULL ';
                  END IF;
                  IF (l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME5 IS NOT NULL AND l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME5 <> 'NONE'
                     AND INSTR(l_dynamic_query,l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME5) = 0) THEN
                          l_dl_pk_col5_sql := l_dl_pk_col5_sql||' , UAI1.' ||l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME5;
                          l_dynamic_group_by := l_dynamic_group_by ||' , UAI1.' ||l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME5;
                          l_deflatening_sql_where := l_deflatening_sql_where || ' AND (UAI1.'||l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME5||
                                                                                       ' = '||' EXTVL1.'||l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME5||
                                                                                ' OR  ('||'UAI1.'||l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME5|| ' IS NULL '||
                                                                                       'AND EXTVL1.'||l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME5||' IS NULL))' ;

                  ELSE
                          l_dl_pk_col5_sql := l_dl_pk_col5_sql||' , NULL ';
                  END IF;
               END LOOP;
               l_dynamic_query := l_dynamic_query||', DECODE(UAI1.DATA_LEVEL_ID '||l_dl_pk_col1_sql||' ) DL_PK1_VAL ';
               l_dynamic_query := l_dynamic_query||', DECODE(UAI1.DATA_LEVEL_ID '||l_dl_pk_col2_sql||' ) DL_PK2_VAL ';
               l_dynamic_query := l_dynamic_query||', DECODE(UAI1.DATA_LEVEL_ID '||l_dl_pk_col3_sql||' ) DL_PK3_VAL ';
               l_dynamic_query := l_dynamic_query||', DECODE(UAI1.DATA_LEVEL_ID '||l_dl_pk_col4_sql||' ) DL_PK4_VAL ';
               l_dynamic_query := l_dynamic_query||', DECODE(UAI1.DATA_LEVEL_ID '||l_dl_pk_col5_sql||' ) DL_PK5_VAL ';

              ELSE
                 l_dynamic_query := l_dynamic_query||' ,NULL '; --this is one is to compensate for the data_level_id
                 IF (l_num_data_level_columns = 0) THEN
                     l_dynamic_query := l_dynamic_query ||' , NULL ';
                     l_dynamic_query := l_dynamic_query ||' , NULL ';
                     l_dynamic_query := l_dynamic_query ||' , NULL ';
                     l_dynamic_query := l_dynamic_query ||' , NULL ';
                     l_dynamic_query := l_dynamic_query ||' , NULL ';
                 ELSIF (l_num_data_level_columns = 1) THEN
                     l_dynamic_query := l_dynamic_query ||' , UAI1.' ||l_data_level_column_1;
                     l_dynamic_query := l_dynamic_query ||' , NULL ';
                     l_dynamic_query := l_dynamic_query ||' , NULL ';
                     l_dynamic_query := l_dynamic_query ||' , NULL ';
                     l_dynamic_query := l_dynamic_query ||' , NULL ';
                     l_dynamic_group_by := l_dynamic_group_by ||' , UAI1.' ||l_data_level_column_1;
                     l_deflatening_sql_where := l_deflatening_sql_where ||
                         ' AND (UAI1.'||l_data_level_column_1||' = '||' EXTVL1.'||l_data_level_column_1||
                         ' OR ('||'UAI1.'||l_data_level_column_1|| ' IS NULL AND EXTVL1.'||l_data_level_column_1||' IS NULL))' ;
                  ELSIF (l_num_data_level_columns = 2) THEN
                     l_dynamic_query := l_dynamic_query ||' , UAI1.' ||l_data_level_column_1;
                     l_dynamic_query := l_dynamic_query ||' , UAI1.' ||l_data_level_column_2;
                     l_dynamic_query := l_dynamic_query ||' , NULL ';
                     l_dynamic_query := l_dynamic_query ||' , NULL ';
                     l_dynamic_query := l_dynamic_query ||' , NULL ';
                     l_dynamic_group_by := l_dynamic_group_by ||' , UAI1.' ||l_data_level_column_1;
                     l_dynamic_group_by := l_dynamic_group_by ||' , UAI1.' ||l_data_level_column_2;
                     l_deflatening_sql_where := l_deflatening_sql_where ||
                         ' AND (UAI1.'||l_data_level_column_1||' = '||' EXTVL1.'||l_data_level_column_1||
                         ' OR ('||'UAI1.'||l_data_level_column_1|| ' IS NULL AND EXTVL1.'||l_data_level_column_1||' IS NULL))' ;
                     l_deflatening_sql_where := l_deflatening_sql_where ||
                         ' AND (UAI1.'||l_data_level_column_2||' = '||' EXTVL1.'||l_data_level_column_2||
                         ' OR ('||'UAI1.'||l_data_level_column_2|| ' IS NULL AND EXTVL1.'||l_data_level_column_2||' IS NULL))' ;
                  ELSIF (l_num_data_level_columns = 3) THEN
                     l_dynamic_query := l_dynamic_query ||' , UAI1.' ||l_data_level_column_1;
                     l_dynamic_query := l_dynamic_query ||' , UAI1.' ||l_data_level_column_2;
                     l_dynamic_query := l_dynamic_query ||' , UAI1.' ||l_data_level_column_3;
                     l_dynamic_query := l_dynamic_query ||' , NULL ';
                     l_dynamic_query := l_dynamic_query ||' , NULL ';
                     l_dynamic_group_by := l_dynamic_group_by ||' , UAI1.' ||l_data_level_column_1;
                     l_dynamic_group_by := l_dynamic_group_by ||' , UAI1.' ||l_data_level_column_2;
                     l_dynamic_group_by := l_dynamic_group_by ||' , UAI1.' ||l_data_level_column_3;
                     l_deflatening_sql_where := l_deflatening_sql_where ||
                         ' AND (UAI1.'||l_data_level_column_1||' = '||' EXTVL1.'||l_data_level_column_1||
                         ' OR ('||'UAI1.'||l_data_level_column_1|| ' IS NULL AND EXTVL1.'||l_data_level_column_1||' IS NULL))' ;
                     l_deflatening_sql_where := l_deflatening_sql_where ||
                         ' AND (UAI1.'||l_data_level_column_2||' = '||' EXTVL1.'||l_data_level_column_2||
                         ' OR ('||'UAI1.'||l_data_level_column_2|| ' IS NULL AND EXTVL1.'||l_data_level_column_2||' IS NULL))' ;
                     l_deflatening_sql_where := l_deflatening_sql_where ||
                         ' AND (UAI1.'||l_data_level_column_3||' = '||' EXTVL1.'||l_data_level_column_3||
                         ' OR ('||'UAI1.'||l_data_level_column_3|| ' IS NULL AND EXTVL1.'||l_data_level_column_3||' IS NULL))' ;
                  END IF;
              END IF;
              -- Bug 10090254 Code changes : End

             l_deflatening_sql_where := l_deflatening_sql_where || ' AND EXTVL1.ATTR_GROUP_ID ='||l_attr_group_metadata_obj.ATTR_GROUP_ID;

             l_defaltening_sql := ' ';
             l_defaltening_sql_create := ' ';
             FOR i IN l_attr_metadata_table.FIRST .. l_attr_metadata_table.LAST
             LOOP

                  l_defaltening_sql := l_defaltening_sql ||
                                    '||  MAX(DECODE(UAI1.ATTR_INT_NAME'||
                                                 ','||' '''||l_attr_metadata_table(i).ATTR_NAME||''' '||
                                                 ','||'''#*'||l_attr_metadata_table(i).ATTR_NAME||'*#'||
                                                 ' NEWVALUE:$['''|| '||' ||'UAI1.ATTR_VALUE_NUM'||'||'||'UAI1.ATTR_VALUE_DATE'||'||'||'UAI1.ATTR_VALUE_STR'||' || '']$OLDVALUE${''||'||'EXTVL1.'||l_attr_metadata_table(i).DATABASE_COLUMN||'||''}$'' '||
                                                 ',NULL)) ';
                  l_defaltening_sql_create := l_defaltening_sql_create ||
                                    '||  MAX(DECODE(UAI1.ATTR_INT_NAME'||
                                                 ','||' '''||l_attr_metadata_table(i).ATTR_NAME||''' '||
                                                 ','||'''#*'||l_attr_metadata_table(i).ATTR_NAME||'*#'||' NEWVALUE:$['''|| '||' ||'UAI1.ATTR_VALUE_NUM'||'||'||'UAI1.ATTR_VALUE_DATE'||'||'||'UAI1.ATTR_VALUE_STR'||' || '']$'' '||
                                                 ',NULL)) ';

             END LOOP;

             l_dynamic_sql := l_dynamic_sql || l_dynamic_query;
             l_dynamic_sql_1 := l_dynamic_sql || ' ,NULL ';
             -------------------------------------------------
             -- Building the query for post event raising on
             -- rows with TT as DELETE
             -------------------------------------------------
             l_dynamic_sql_delete_post := l_dynamic_sql_delete_post || l_dynamic_query || ' ,NULL';
             l_dynamic_sql_delete_post := l_dynamic_sql_delete_post || ' FROM '||p_interface_table_name||' UAI1 ';
             l_dynamic_sql_delete_post := l_dynamic_sql_delete_post || ' WHERE UAI1.DATA_SET_ID = :data_set_id '||
                                                                       '  AND UAI1.PROCESS_STATUS = '||G_PS_IN_PROCESS||
                                                                       '  AND UAI1.ATTR_GROUP_INT_NAME = :attr_group_int_name '||
                                                                       '  AND UAI1.TRANSACTION_TYPE = '''||EGO_USER_ATTRS_DATA_PVT.G_DELETE_MODE||'''';
             l_dynamic_sql_delete_post := l_dynamic_sql_delete_post || '  GROUP BY UAI1.ATTR_GROUP_INT_NAME, UAI1.TRANSACTION_TYPE, UAI1.ROW_IDENTIFIER ';

             l_dynamic_sql_delete_post := l_dynamic_sql_delete_post ||'  '|| l_dynamic_group_by;

             IF (l_attr_group_metadata_obj.MULTI_ROW_CODE = 'Y') THEN
                l_dynamic_sql_1 := l_dynamic_sql_1 ||
                                ' FROM '||p_interface_table_name||' UAI1,';
                l_dynamic_sql_1 := l_dynamic_sql_1 || l_ext_table_select;
             ELSE
                l_dynamic_sql_1 := l_dynamic_sql_1 ||
                                ' FROM '||p_interface_table_name||' UAI1, '|| l_ext_vl_name || '  EXTVL1  WHERE';
                l_dynamic_sql_1 := l_dynamic_sql_1 || ' 1 = 1 ';
             END IF;

             l_dynamic_sql_1 := l_dynamic_sql_1 ||'  AND UAI1.DATA_SET_ID = :data_set_id '||
                                                  '  AND UAI1.PROCESS_STATUS = '||G_PS_IN_PROCESS||
                                                  '  AND UAI1.ATTR_GROUP_INT_NAME = :attr_group_int_name '||
                                                  '  AND UAI1.TRANSACTION_TYPE <> '''||EGO_USER_ATTRS_DATA_PVT.G_DELETE_MODE||'''';


             l_dynamic_sql_1 := l_dynamic_sql_1 || l_deflatening_sql_where;
             l_dynamic_sql_1 := l_dynamic_sql_1 || '   ' || l_group_by_pre || l_dynamic_group_by;


           END IF;-- IF ((l_new_post_event_name IS NOT NULL AND l_new_post_event_enabled_flag = 'Y')  ) THEN

        /*End code changes for bug 8485287*/

        ----------------------------------------------------------------------------------------------------------
        -- HERE WE BUILD THE REQUIRED QUERIES FOR THE CURSORS TO BE EXECUTED TO DEFLATEN THE DATA IN THE INTERFACE
        -- TABLE AND RAISE EVENT ONCE PER AG (We build the sql's only if atleast one of pre or post is enabled.)
        ----------------------------------------------------------------------------------------------------------
        IF ((l_pre_event_name IS NOT NULL AND l_is_pre_event_enabled_flag = 'Y') ) THEN

          l_dynamic_sql := ' SELECT EXTVL1.EXTENSION_ID , UAI1.ATTR_GROUP_INT_NAME, UAI1.TRANSACTION_TYPE, UAI1.ROW_IDENTIFIER ';
          l_group_by_pre := ' GROUP BY EXTVL1.EXTENSION_ID , UAI1.ATTR_GROUP_INT_NAME, UAI1.TRANSACTION_TYPE, UAI1.ROW_IDENTIFIER ';
          --l_dynamic_sql_delete_post := ' SELECT NULL , UAI1.ATTR_GROUP_INT_NAME, UAI1.TRANSACTION_TYPE, UAI1.ROW_IDENTIFIER ';
          l_dynamic_group_by := ' ';
          l_deflatening_sql_where := ' ';
          l_dynamic_query := ' ';

          IF (l_pk1_column_name IS NOT NULL) THEN
            l_dynamic_query := l_dynamic_query || ' , UAI1.' ||l_pk1_column_name;
            l_dynamic_group_by := l_dynamic_group_by || ' , UAI1.' ||l_pk1_column_name;
            l_deflatening_sql_where := l_deflatening_sql_where || ' AND UAI1.'||l_pk1_column_name||' = '||' EXTVL1.'||l_pk1_column_name;
          ELSE
            l_dynamic_query := l_dynamic_query || ' , NULL ';
          END IF;
          IF (l_pk2_column_name IS NOT NULL) THEN
            l_dynamic_query := l_dynamic_query || ' , UAI1.' ||l_pk2_column_name;
            l_dynamic_group_by := l_dynamic_group_by || ' , UAI1.' ||l_pk2_column_name;
            l_deflatening_sql_where := l_deflatening_sql_where || ' AND UAI1.'||l_pk2_column_name||' = '||' EXTVL1.'||l_pK2_column_name;
          ELSE
            l_dynamic_query := l_dynamic_query || ' , NULL ';
          END IF;
          IF (l_pk3_column_name IS NOT NULL) THEN
            l_dynamic_query := l_dynamic_query || ' , UAI1.' ||l_pk3_column_name;
            l_dynamic_group_by := l_dynamic_group_by || ' , UAI1.' ||l_pk3_column_name;
            l_deflatening_sql_where := l_deflatening_sql_where || ' AND UAI1.'||l_pk3_column_name||' = '||' EXTVL1.'||l_pk3_column_name;
          ELSE
            l_dynamic_query := l_dynamic_query || ' , NULL ';
          END IF;
          IF (l_pk4_column_name IS NOT NULL) THEN
            l_dynamic_query := l_dynamic_query || ' , UAI1.' ||l_pk4_column_name;
            l_dynamic_group_by := l_dynamic_group_by || ' , UAI1.' ||l_pk4_column_name;
            l_deflatening_sql_where := l_deflatening_sql_where || ' AND UAI1.'||l_pk4_column_name||' = '||' EXTVL1.'||l_pk4_column_name;
          ELSE
            l_dynamic_query := l_dynamic_query || ' , NULL ';
          END IF;
          IF (l_pk5_column_name IS NOT NULL) THEN
            l_dynamic_query := l_dynamic_query || ' , UAI1.' ||l_pk5_column_name;
            l_dynamic_group_by := l_dynamic_group_by || ' , UAI1.' ||l_pk5_column_name;
            l_deflatening_sql_where := l_deflatening_sql_where || ' AND UAI1.'||l_pk5_column_name||' = '||' EXTVL1.'||l_pk5_column_name;
          ELSE
            l_dynamic_query := l_dynamic_query || ' , NULL ';
          END IF;

          --------------------------------------
          -- Adding the data level columns ...
          --------------------------------------
          IF(l_data_level_col_exists) THEN

            l_dynamic_query := l_dynamic_query||' , UAI1.DATA_LEVEL_ID ';
            l_dynamic_group_by := l_dynamic_group_by ||' , UAI1.DATA_LEVEL_ID ';
            l_deflatening_sql_where := l_deflatening_sql_where || ' AND NVL(UAI1.DATA_LEVEL_ID,-1) = NVL(EXTVL1.DATA_LEVEL_ID,-1) ';

      /* Bug 8488861. The following FOR loop will execute multiple times because of outer FOR loop over the Cursor l_dynamic_dist_ag_cursor.
                Initializing the varibales (l_dl_pk_col1_sql etc.,) to NULL to avoid adding duplicate values, as these
                variables will be used in Decode() function, which accepts only 255 parameters in some Database versions. */
             l_dl_pk_col1_sql:=NULL;
             l_dl_pk_col2_sql:=NULL;
             l_dl_pk_col3_sql:=NULL;
             l_dl_pk_col4_sql:=NULL;
             l_dl_pk_col5_sql:=NULL;

             FOR i IN l_list_of_dl_for_ag_type.FIRST .. l_list_of_dl_for_ag_type.LAST
             LOOP
                l_dl_pk_col1_sql := l_dl_pk_col1_sql||' , '||l_list_of_dl_for_ag_type(i).DATA_LEVEL_ID||' ';
                l_dl_pk_col2_sql := l_dl_pk_col2_sql||' , '||l_list_of_dl_for_ag_type(i).DATA_LEVEL_ID||' ';
                l_dl_pk_col3_sql := l_dl_pk_col3_sql||' , '||l_list_of_dl_for_ag_type(i).DATA_LEVEL_ID||' ';
                l_dl_pk_col4_sql := l_dl_pk_col4_sql||' , '||l_list_of_dl_for_ag_type(i).DATA_LEVEL_ID||' ';
                l_dl_pk_col5_sql := l_dl_pk_col5_sql||' , '||l_list_of_dl_for_ag_type(i).DATA_LEVEL_ID||' ';

                IF (l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME1 IS NOT NULL AND l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME1 <> 'NONE'
                   AND INSTR(l_dynamic_query,l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME1) = 0) THEN

                        l_dl_pk_col1_sql := l_dl_pk_col1_sql||' , UAI1.' ||l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME1;
                        l_dynamic_group_by := l_dynamic_group_by ||' , UAI1.' ||l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME1;
                        l_deflatening_sql_where := l_deflatening_sql_where || ' AND (UAI1.'||l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME1||
                                                                                     ' = '||' EXTVL1.'||l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME1||
                                                                              ' OR  ('||'UAI1.'||l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME1|| ' IS NULL '||
                                                                                     'AND EXTVL1.'||l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME1||' IS NULL))' ;
                ELSE
                        l_dl_pk_col1_sql := l_dl_pk_col1_sql||' , NULL ';
                END IF;
                IF (l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME2 IS NOT NULL AND l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME2 <> 'NONE'
                   AND INSTR(l_dynamic_query,l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME2) = 0) THEN
                        l_dl_pk_col2_sql := l_dl_pk_col2_sql||' , UAI1.' ||l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME2;
                        l_dynamic_group_by := l_dynamic_group_by ||' , UAI1.' ||l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME2;
                        l_deflatening_sql_where := l_deflatening_sql_where || ' AND (UAI1.'||l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME2||
                                                                                     ' = '||' EXTVL1.'||l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME2||
                                                                              ' OR  ('||'UAI1.'||l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME2|| ' IS NULL '||
                                                                                     'AND EXTVL1.'||l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME2||' IS NULL))' ;

                ELSE
                        l_dl_pk_col2_sql := l_dl_pk_col2_sql||' , NULL ';
                END IF;
                IF (l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME3 IS NOT NULL AND l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME3 <> 'NONE'
                   AND INSTR(l_dynamic_query,l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME3) = 0) THEN
                        l_dl_pk_col3_sql := l_dl_pk_col3_sql||' , UAI1.' ||l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME3;
                        l_dynamic_group_by := l_dynamic_group_by ||' , UAI1.' ||l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME3;
                        l_deflatening_sql_where := l_deflatening_sql_where || ' AND (UAI1.'||l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME3||
                                                                                     ' = '||' EXTVL1.'||l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME3||
                                                                              ' OR  ('||'UAI1.'||l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME3|| ' IS NULL '||
                                                                                     'AND EXTVL1.'||l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME3||' IS NULL))' ;

                ELSE
                        l_dl_pk_col3_sql := l_dl_pk_col3_sql||' , NULL ';
                END IF;
                IF (l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME4 IS NOT NULL AND l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME4 <> 'NONE'
                   AND INSTR(l_dynamic_query,l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME4) = 0) THEN
                        l_dl_pk_col4_sql := l_dl_pk_col4_sql||' , UAI1.' ||l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME4;
                        l_dynamic_group_by := l_dynamic_group_by ||' , UAI1.' ||l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME4;
                        l_deflatening_sql_where := l_deflatening_sql_where || ' AND (UAI1.'||l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME4||
                                                                                     ' = '||' EXTVL1.'||l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME4||
                                                                              ' OR  ('||'UAI1.'||l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME4|| ' IS NULL '||
                                                                                     'AND EXTVL1.'||l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME4||' IS NULL))' ;

                ELSE
                        l_dl_pk_col4_sql := l_dl_pk_col4_sql||' , NULL ';
                END IF;
                IF (l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME5 IS NOT NULL AND l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME5 <> 'NONE'
                   AND INSTR(l_dynamic_query,l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME5) = 0) THEN
                        l_dl_pk_col5_sql := l_dl_pk_col5_sql||' , UAI1.' ||l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME5;
                        l_dynamic_group_by := l_dynamic_group_by ||' , UAI1.' ||l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME5;
                        l_deflatening_sql_where := l_deflatening_sql_where || ' AND (UAI1.'||l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME5||
                                                                                     ' = '||' EXTVL1.'||l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME5||
                                                                              ' OR  ('||'UAI1.'||l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME5|| ' IS NULL '||
                                                                                     'AND EXTVL1.'||l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME5||' IS NULL))' ;

                ELSE
                        l_dl_pk_col5_sql := l_dl_pk_col5_sql||' , NULL ';
                END IF;
             END LOOP;
             l_dynamic_query := l_dynamic_query||', DECODE(UAI1.DATA_LEVEL_ID '||l_dl_pk_col1_sql||' ) DL_PK1_VAL ';
             l_dynamic_query := l_dynamic_query||', DECODE(UAI1.DATA_LEVEL_ID '||l_dl_pk_col2_sql||' ) DL_PK2_VAL ';
             l_dynamic_query := l_dynamic_query||', DECODE(UAI1.DATA_LEVEL_ID '||l_dl_pk_col3_sql||' ) DL_PK3_VAL ';
             l_dynamic_query := l_dynamic_query||', DECODE(UAI1.DATA_LEVEL_ID '||l_dl_pk_col4_sql||' ) DL_PK4_VAL ';
             l_dynamic_query := l_dynamic_query||', DECODE(UAI1.DATA_LEVEL_ID '||l_dl_pk_col5_sql||' ) DL_PK5_VAL ';

          ELSE
               l_dynamic_query := l_dynamic_query||' ,NULL '; --this is one is to compensate for the data_level_id
               IF (l_num_data_level_columns = 0) THEN
                   l_dynamic_query := l_dynamic_query ||' , NULL ';
                   l_dynamic_query := l_dynamic_query ||' , NULL ';
                   l_dynamic_query := l_dynamic_query ||' , NULL ';
                   l_dynamic_query := l_dynamic_query ||' , NULL ';
                   l_dynamic_query := l_dynamic_query ||' , NULL ';
               ELSIF (l_num_data_level_columns = 1) THEN
                   l_dynamic_query := l_dynamic_query ||' , UAI1.' ||l_data_level_column_1;
                   l_dynamic_query := l_dynamic_query ||' , NULL ';
                   l_dynamic_query := l_dynamic_query ||' , NULL ';
                   l_dynamic_query := l_dynamic_query ||' , NULL ';
                   l_dynamic_query := l_dynamic_query ||' , NULL ';
                   l_dynamic_group_by := l_dynamic_group_by ||' , UAI1.' ||l_data_level_column_1;
                   l_deflatening_sql_where := l_deflatening_sql_where ||
                       ' AND (UAI1.'||l_data_level_column_1||' = '||' EXTVL1.'||l_data_level_column_1||
                       ' OR ('||'UAI1.'||l_data_level_column_1|| ' IS NULL AND EXTVL1.'||l_data_level_column_1||' IS NULL))' ;
                ELSIF (l_num_data_level_columns = 2) THEN
                   l_dynamic_query := l_dynamic_query ||' , UAI1.' ||l_data_level_column_1;
                   l_dynamic_query := l_dynamic_query ||' , UAI1.' ||l_data_level_column_2;
                   l_dynamic_query := l_dynamic_query ||' , NULL ';
                   l_dynamic_query := l_dynamic_query ||' , NULL ';
                   l_dynamic_query := l_dynamic_query ||' , NULL ';
                   l_dynamic_group_by := l_dynamic_group_by ||' , UAI1.' ||l_data_level_column_1;
                   l_dynamic_group_by := l_dynamic_group_by ||' , UAI1.' ||l_data_level_column_2;
                   l_deflatening_sql_where := l_deflatening_sql_where ||
                       ' AND (UAI1.'||l_data_level_column_1||' = '||' EXTVL1.'||l_data_level_column_1||
                       ' OR ('||'UAI1.'||l_data_level_column_1|| ' IS NULL AND EXTVL1.'||l_data_level_column_1||' IS NULL))' ;
                   l_deflatening_sql_where := l_deflatening_sql_where ||
                       ' AND (UAI1.'||l_data_level_column_2||' = '||' EXTVL1.'||l_data_level_column_2||
                       ' OR ('||'UAI1.'||l_data_level_column_2|| ' IS NULL AND EXTVL1.'||l_data_level_column_2||' IS NULL))' ;
                ELSIF (l_num_data_level_columns = 3) THEN
                   l_dynamic_query := l_dynamic_query ||' , UAI1.' ||l_data_level_column_1;
                   l_dynamic_query := l_dynamic_query ||' , UAI1.' ||l_data_level_column_2;
                   l_dynamic_query := l_dynamic_query ||' , UAI1.' ||l_data_level_column_3;
                   l_dynamic_query := l_dynamic_query ||' , NULL ';
                   l_dynamic_query := l_dynamic_query ||' , NULL ';
                   l_dynamic_group_by := l_dynamic_group_by ||' , UAI1.' ||l_data_level_column_1;
                   l_dynamic_group_by := l_dynamic_group_by ||' , UAI1.' ||l_data_level_column_2;
                   l_dynamic_group_by := l_dynamic_group_by ||' , UAI1.' ||l_data_level_column_3;
                   l_deflatening_sql_where := l_deflatening_sql_where ||
                       ' AND (UAI1.'||l_data_level_column_1||' = '||' EXTVL1.'||l_data_level_column_1||
                       ' OR ('||'UAI1.'||l_data_level_column_1|| ' IS NULL AND EXTVL1.'||l_data_level_column_1||' IS NULL))' ;
                   l_deflatening_sql_where := l_deflatening_sql_where ||
                       ' AND (UAI1.'||l_data_level_column_2||' = '||' EXTVL1.'||l_data_level_column_2||
                       ' OR ('||'UAI1.'||l_data_level_column_2|| ' IS NULL AND EXTVL1.'||l_data_level_column_2||' IS NULL))' ;
                   l_deflatening_sql_where := l_deflatening_sql_where ||
                       ' AND (UAI1.'||l_data_level_column_3||' = '||' EXTVL1.'||l_data_level_column_3||
                       ' OR ('||'UAI1.'||l_data_level_column_3|| ' IS NULL AND EXTVL1.'||l_data_level_column_3||' IS NULL))' ;
                END IF;
          END IF;

          l_deflatening_sql_where := l_deflatening_sql_where || ' AND EXTVL1.ATTR_GROUP_ID ='||l_attr_group_metadata_obj.ATTR_GROUP_ID;

          l_defaltening_sql := ' ';
          l_defaltening_sql_create := ' ';
          FOR i IN l_attr_metadata_table.FIRST .. l_attr_metadata_table.LAST
          LOOP
                -- abedajna begin
               if l_attr_metadata_table(i).DATA_TYPE_CODE = EGO_EXT_FWK_PUB.G_DATE_TIME_DATA_TYPE then
                    l_correct_date_time_sql_uai := 'to_char(UAI1.ATTR_VALUE_DATE , '||''''||EGO_USER_ATTRS_COMMON_PVT.G_DATE_FORMAT ||''')';
                    l_correct_date_time_sql_extvl := 'to_char(EXTVL1.'||l_attr_metadata_table(i).DATABASE_COLUMN||', '''||EGO_USER_ATTRS_COMMON_PVT.G_DATE_FORMAT ||''')';
               else
                    l_correct_date_time_sql_uai := 'UAI1.ATTR_VALUE_DATE';
                    l_correct_date_time_sql_extvl := 'EXTVL1.'||l_attr_metadata_table(i).DATABASE_COLUMN;
               end if;
                -- abedajna end

               l_defaltening_sql := l_defaltening_sql ||
                                 '||  MAX(DECODE(UAI1.ATTR_INT_NAME'||
                                              ','||' '''||l_attr_metadata_table(i).ATTR_NAME||''' '||
                                              ','||'''#*'||l_attr_metadata_table(i).ATTR_NAME||'*#'||
               -- abedajna delete             ' NEWVALUE:$['''|| '||' ||'UAI1.ATTR_VALUE_NUM'||'||'||'UAI1.ATTR_VALUE_DATE'||'||'||'UAI1.ATTR_VALUE_STR'||' || '']$OLDVALUE${''||'||'EXTVL1.'||l_attr_metadata_table(i).DATABASE_COLUMN||'||''}$'' '||
               -- abedajna add
                                              ' NEWVALUE:$['''|| '||' ||'UAI1.ATTR_VALUE_NUM'||'||'||l_correct_date_time_sql_uai||'||'||'UAI1.ATTR_VALUE_STR'||
            ' ||'']$OLDVALUE${''||'||l_correct_date_time_sql_extvl||'||''}$'' '|| ',NULL)) ';

               l_defaltening_sql_create := l_defaltening_sql_create ||
                                 '||  MAX(DECODE(UAI1.ATTR_INT_NAME'||
                                              ','||' '''||l_attr_metadata_table(i).ATTR_NAME||''' '||
               -- abedajna delete             ','||'''#*'||l_attr_metadata_table(i).ATTR_NAME||'*#'||' NEWVALUE:$['''|| '||' ||'UAI1.ATTR_VALUE_NUM'||'||'||'UAI1.ATTR_VALUE_DATE'||'||'||'UAI1.ATTR_VALUE_STR'||' || '']$'' '||
               -- abedajna add
                                              ','||'''#*'||l_attr_metadata_table(i).ATTR_NAME||'*#'||' NEWVALUE:$['''|| '||' ||'UAI1.ATTR_VALUE_NUM'||'||'||l_correct_date_time_sql_uai||'||'||'UAI1.ATTR_VALUE_STR'||' || '']$'' '||
                                              ',NULL)) ';

           END LOOP;

          l_dynamic_sql := l_dynamic_sql || l_dynamic_query;
          --l_dynamic_sql_1 := l_dynamic_sql || ' ,NULL ';
          l_dynamic_sql := l_dynamic_sql || ' ,  ' ||' '' '' ' || l_defaltening_sql;
          /*
          -------------------------------------------------
          -- Building the query for post event raising on
          -- rows with TT as DELETE
          -------------------------------------------------
          l_dynamic_sql_delete_post := l_dynamic_sql_delete_post || l_dynamic_query || ' ,NULL';
          l_dynamic_sql_delete_post := l_dynamic_sql_delete_post || ' FROM '||p_interface_table_name||' UAI1 ';
          l_dynamic_sql_delete_post := l_dynamic_sql_delete_post || ' WHERE UAI1.DATA_SET_ID = :data_set_id '||
                                                                    '  AND UAI1.PROCESS_STATUS = '||G_PS_IN_PROCESS||
                                                                    '  AND UAI1.ATTR_GROUP_INT_NAME = :attr_group_int_name '||
                                                                    '  AND UAI1.TRANSACTION_TYPE = '''||EGO_USER_ATTRS_DATA_PVT.G_DELETE_MODE||'''';
          l_dynamic_sql_delete_post := l_dynamic_sql_delete_post || '  GROUP BY UAI1.ATTR_GROUP_INT_NAME, UAI1.TRANSACTION_TYPE, UAI1.ROW_IDENTIFIER ';

          l_dynamic_sql_delete_post := l_dynamic_sql_delete_post ||'  '|| l_dynamic_group_by;
          */
          IF (l_attr_group_metadata_obj.MULTI_ROW_CODE = 'Y') THEN
             l_dynamic_sql := l_dynamic_sql ||
                             ' FROM '||p_interface_table_name||' UAI1,';
             l_dynamic_sql := l_dynamic_sql || l_ext_table_select;
             --l_dynamic_sql_1 := l_dynamic_sql_1 ||
             --                ' FROM '||p_interface_table_name||' UAI1,';
             --l_dynamic_sql_1 := l_dynamic_sql_1 || l_ext_table_select;
          ELSE
             l_dynamic_sql := l_dynamic_sql ||
                             ' FROM '||p_interface_table_name||' UAI1, '|| l_ext_vl_name || '  EXTVL1  WHERE';
             l_dynamic_sql := l_dynamic_sql || ' 1 = 1 ';
             --l_dynamic_sql_1 := l_dynamic_sql_1 ||
             --                ' FROM '||p_interface_table_name||' UAI1, '|| l_ext_vl_name || '  EXTVL1  WHERE';
             --l_dynamic_sql_1 := l_dynamic_sql_1 || ' 1 = 1 ';
          END IF;

          --- Added Code  '  AND UAI1.PROCESS_STATUS <> '||G_PS_SUCCESS|| for bug 7460377
          l_dynamic_sql := l_dynamic_sql ||'  AND UAI1.DATA_SET_ID = :data_set_id '||
                                           '  AND UAI1.PROCESS_STATUS <> '||G_PS_GENERIC_ERROR||
             '  AND UAI1.PROCESS_STATUS <> '||G_PS_SUCCESS||
                                           '  AND UAI1.ATTR_GROUP_INT_NAME = :attr_group_int_name '||
                                           '  AND UAI1.TRANSACTION_TYPE <> '''||EGO_USER_ATTRS_DATA_PVT.G_CREATE_MODE||'''';
          --l_dynamic_sql_1 := l_dynamic_sql_1 ||'  AND UAI1.DATA_SET_ID = :data_set_id '||
          --                                     '  AND UAI1.PROCESS_STATUS = '||G_PS_IN_PROCESS||
          --                                     '  AND UAI1.ATTR_GROUP_INT_NAME = :attr_group_int_name '||
          --                                     '  AND UAI1.TRANSACTION_TYPE <> '''||EGO_USER_ATTRS_DATA_PVT.G_DELETE_MODE||'''';

          l_dynamic_sql := l_dynamic_sql || l_deflatening_sql_where;
          l_dynamic_sql := l_dynamic_sql || '   ' || l_group_by_pre || l_dynamic_group_by;

          --l_dynamic_sql_1 := l_dynamic_sql_1 || l_deflatening_sql_where;
          --l_dynamic_sql_1 := l_dynamic_sql_1 || '   ' || l_group_by_pre || l_dynamic_group_by;

          -- WE GENERATE THE DML FOR ERRORING OUT THE AG'S FOR WHICH PRE-EVENT RAISING HAS FAILED.

          IF (l_attr_group_metadata_obj.MULTI_ROW_CODE = 'Y') THEN
                l_pre_event_failed_sql :=
                'UPDATE '||p_interface_table_name||' UAI1
                SET PROCESS_STATUS = PROCESS_STATUS + '||G_PS_PRE_EVENT_FAILED||'
                WHERE DATA_SET_ID = :data_set_id
                AND ATTR_GROUP_INT_NAME = :attr_group_int_name
              AND ROW_IDENTIFIER = :row_identifier';
          ELSE
              l_pre_event_failed_sql :=
              'UPDATE '||p_interface_table_name||' UAI1
              SET PROCESS_STATUS = PROCESS_STATUS + '||G_PS_PRE_EVENT_FAILED||'
              WHERE DATA_SET_ID = :data_set_id
              AND ATTR_GROUP_INT_NAME = :attr_group_int_name
            AND ROWNUM = 1';
          END IF;

          IF(l_pk1_column_name IS NOT NULL ) THEN
            l_pre_event_failed_sql := l_pre_event_failed_sql || ' AND '||l_pk1_column_name||' = :pk1_value ' ;
          END IF;
          IF(l_pk2_column_name IS NOT NULL ) THEN
            l_pre_event_failed_sql := l_pre_event_failed_sql || ' AND '||l_pk2_column_name||' = :pk2_value ';
          END IF;
          IF(l_pk3_column_name IS NOT NULL ) THEN
            l_pre_event_failed_sql := l_pre_event_failed_sql || ' AND '||l_pk3_column_name||' = :pk3_value ' ;
          END IF;
          IF(l_pk4_column_name IS NOT NULL ) THEN
            l_pre_event_failed_sql := l_pre_event_failed_sql || ' AND '||l_pk4_column_name||' = :pk4_value ' ;
          END IF;
          IF(l_pk5_column_name IS NOT NULL ) THEN
            l_pre_event_failed_sql := l_pre_event_failed_sql || ' AND '||l_pk5_column_name||' = :pk5_value ' ;
          END IF;

          IF(l_data_level_col_exists) THEN

            l_pre_event_failed_sql := l_pre_event_failed_sql || ' AND ';

            FOR i IN l_list_of_dl_for_ag_type.FIRST .. l_list_of_dl_for_ag_type.LAST
            LOOP

              IF(i=1) THEN
                l_pre_event_failed_sql := l_pre_event_failed_sql || ' (DATA_LEVEL_ID = :dl_id ' ;
              ELSE
                l_pre_event_failed_sql := l_pre_event_failed_sql || ' OR (DATA_LEVEL_ID = :dl_id ' ;
              END IF;

              IF (l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME1 IS NOT NULL AND l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME1 <> 'NONE' ) THEN
                l_pre_event_failed_sql := l_pre_event_failed_sql || ' AND '||l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME1||' = :dl_pk1_val ' ;
              ELSE
                l_pre_event_failed_sql := l_pre_event_failed_sql || ' AND :dl_pk1_val IS NULL ' ;
              END IF;

              IF (l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME2 IS NOT NULL AND l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME2 <> 'NONE' ) THEN
                l_pre_event_failed_sql := l_pre_event_failed_sql || ' AND '||l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME2||' = :dl_pk2_val ' ;
              ELSE
                l_pre_event_failed_sql := l_pre_event_failed_sql || ' AND :dl_pk2_val IS NULL ' ;
              END IF;
              IF (l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME3 IS NOT NULL AND l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME3 <> 'NONE' ) THEN
                l_pre_event_failed_sql := l_pre_event_failed_sql || ' AND '||l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME3||' = :dl_pk3_val ' ;
              ELSE
                l_pre_event_failed_sql := l_pre_event_failed_sql || ' AND :dl_pk3_val IS NULL ' ;
              END IF;
              IF (l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME4 IS NOT NULL AND l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME4 <> 'NONE' ) THEN
                l_pre_event_failed_sql := l_pre_event_failed_sql || ' AND '||l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME4||' = :dl_pk4_val ' ;
              ELSE
                l_pre_event_failed_sql := l_pre_event_failed_sql || ' AND :dl_pk4_val IS NULL ' ;
              END IF;
              IF (l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME5 IS NOT NULL AND l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME5 <> 'NONE' ) THEN
                l_pre_event_failed_sql := l_pre_event_failed_sql || ' AND '||l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME5||' = :dl_pk5_val ' ;
              ELSE
                l_pre_event_failed_sql := l_pre_event_failed_sql || ' AND :dl_pk5_val IS NULL ' ;
              END IF;

          END LOOP;

              l_pre_event_failed_sql := l_pre_event_failed_sql || ' ) ';

          ELSE
            IF(l_data_level_column_1 IS NOT NULL ) THEN
              l_pre_event_failed_sql := l_pre_event_failed_sql || ' AND ( ('||l_data_level_column_1||' = :dl1_value) OR ('||l_data_level_column_1||' IS NULL AND :dl1_value IS NULL)) ' ;
            END IF;
            IF(l_data_level_column_2 IS NOT NULL ) THEN
              l_pre_event_failed_sql := l_pre_event_failed_sql || ' AND ( ('||l_data_level_column_2||' = :dl2_value) OR ('||l_data_level_column_2||' IS NULL AND :dl2_value IS NULL)) ' ;
            END IF;
            IF(l_data_level_column_3 IS NOT NULL ) THEN
              l_pre_event_failed_sql := l_pre_event_failed_sql || ' AND ( ('||l_data_level_column_3||' = :dl3_value) OR ('||l_data_level_column_3||' IS NULL AND :dl3_value IS NULL)) ' ;
            END IF;
          END IF;

       END IF;-- ending if for checking weather or not raise pre/post events

          -----------------------------------------------------------------------
          -- WE ARE DONE WITH BUILDING TEH QUERIES ... NOW WE RAISE EVENTS ...
          -- RAISING EVENT FOR ALL THE AG ROWS WHICH ARE *NOT* BEING CREATED
          -----------------------------------------------------------------------

        IF (l_pre_event_name IS NOT NULL AND l_is_pre_event_enabled_flag = 'Y') THEN
          --------------------------------------------------------------
          -- Here we raise events only for AG Rows not in CREATE Mode
          --------------------------------------------------------------

          OPEN l_dynamic_cursor FOR l_dynamic_sql
          USING p_data_set_id, l_attr_group_metadata_obj.ATTR_GROUP_NAME;
          LOOP
            FETCH l_dynamic_cursor INTO l_ag_deflatened_row;
            EXIT WHEN l_dynamic_cursor%NOTFOUND;
            -- Loop through the deflatened string containing the old and new values and
            -- prepare the table to be passed in as a parameter to pre-event
            l_attr_name_val_str := l_ag_deflatened_row.ATTR_NAME_VALUES;
            attr_name_val_pair := EGO_ATTR_TABLE();
            WHILE (INSTR(l_attr_name_val_str,'#') <> 0 AND l_ag_deflatened_row.TRANSACTION_TYPE <> EGO_USER_ATTRS_DATA_PVT.G_DELETE_MODE)
            LOOP
              l_attr_name := SUBSTR(l_attr_name_val_str
                                    ,INSTR(l_attr_name_val_str,'#*')+2
                                    ,INSTR(l_attr_name_val_str,'*#')-INSTR(l_attr_name_val_str,'#*')-2
                                    );
              l_old_value := SUBSTR(l_attr_name_val_str
                                    ,INSTR(l_attr_name_val_str,'${')+2
                                    ,INSTR(l_attr_name_val_str,'}$')-INSTR(l_attr_name_val_str,'${')-2
                                    );
              l_new_value := SUBSTR(l_attr_name_val_str
                                    ,INSTR(l_attr_name_val_str,'$[')+2
                                    ,INSTR(l_attr_name_val_str,']$')-INSTR(l_attr_name_val_str,'$[')-2
                                    );

              l_attr_name_val_str := SUBSTR(l_attr_name_val_str
                                            ,INSTR(l_attr_name_val_str,'}$')+2
                                            ,LENGTH(l_attr_name_val_str)-INSTR(l_attr_name_val_str,'}$')+2
                                            );
              IF (l_old_value = l_new_value OR (l_old_value IS NULL AND l_new_value IS NULL) ) THEN
                NULL;
              ELSE
                attr_name_val_pair.EXTEND();
                attr_name_val_pair(attr_name_val_pair.LAST) := EGO_ATTR_REC(l_attr_name, l_new_value);
              END IF;
            END LOOP; -- while for extracting name value pairs ends here

            -------------------------------------------------
            -- NOW WE HAVE ALL THE DATA TO RAISE THE EVENT --
            -- HERE WE RAISE PRE-EVENTS FOR AG ROWS BEING
            -- UPDATED OR DELETED.
            -------------------------------------------------
            BEGIN
              IF(l_data_level_col_exists) THEN
                FOR i IN l_list_of_dl_for_ag_type.FIRST .. l_list_of_dl_for_ag_type.LAST
                LOOP
                   IF(l_ag_deflatened_row.DATA_LEVEL_ID = l_list_of_dl_for_ag_type(i).DATA_LEVEL_ID) THEN
                     l_dl_pk1_col_name := l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME1;
                     l_dl_pk2_col_name := l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME2;
                     l_dl_pk3_col_name := l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME3;
                     l_dl_pk4_col_name := l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME4;
                     l_dl_pk5_col_name := l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME5;
                   END IF;
                END LOOP;
              ELSE
                l_dl_pk1_col_name := l_data_level_column_1;
                l_dl_pk2_col_name := l_data_level_column_2;
                l_dl_pk3_col_name := l_data_level_column_3;
                l_dl_pk4_col_name := null;
                l_dl_pk5_col_name := null;
              END IF;

              l_event_key := SUBSTRB(l_pre_event_name, 1, 225) || '-' || TO_CHAR(SYSDATE, 'J.SSSSS');

              EGO_WF_WRAPPER_PVT.Raise_WF_Business_Event(
               p_event_name                    => l_pre_event_name
              ,p_event_key                     => l_event_key
              ,p_pre_event_flag                => 'T'
              ,p_dml_type                      => l_ag_deflatened_row.TRANSACTION_TYPE
              ,p_attr_group_name               => l_ag_deflatened_row.ATTR_GROUP_INT_NAME
              ,p_extension_id                  => l_ag_deflatened_row.EXTENSION_ID
              ,p_primary_key_1_col_name        => l_pk1_column_name
              ,p_primary_key_1_value           => l_ag_deflatened_row.PK1
              ,p_primary_key_2_col_name        => l_pk2_column_name
              ,p_primary_key_2_value           => l_ag_deflatened_row.PK2
              ,p_primary_key_3_col_name        => l_pk3_column_name
              ,p_primary_key_3_value           => l_ag_deflatened_row.PK3
              ,p_primary_key_4_col_name        => l_pk4_column_name
              ,p_primary_key_4_value           => l_ag_deflatened_row.PK4
              ,p_primary_key_5_col_name        => l_pk5_column_name
              ,p_primary_key_5_value           => l_ag_deflatened_row.PK5
              ,p_data_level_id                 => l_ag_deflatened_row.DATA_LEVEL_ID
              ,p_data_level_1_col_name         => l_dl_pk1_col_name
              ,p_data_level_1_value            => l_ag_deflatened_row.DL1
              ,p_data_level_2_col_name         => l_dl_pk2_col_name
              ,p_data_level_2_value            => l_ag_deflatened_row.DL2
              ,p_data_level_3_col_name         => l_dl_pk3_col_name
              ,p_data_level_3_value            => l_ag_deflatened_row.DL3
              ,p_data_level_4_col_name         => l_dl_pk4_col_name
              ,p_data_level_4_value            => l_ag_deflatened_row.DL4
              ,p_data_level_5_col_name         => l_dl_pk5_col_name
              ,p_data_level_5_value            => l_ag_deflatened_row.DL5
              ,p_user_row_identifier           => l_ag_deflatened_row.ROW_IDENTIFIER
              ,p_attr_name_val_tbl             => attr_name_val_pair
              ,p_entity_id                     => p_entity_id
              ,p_entity_index                  => p_entity_index
              ,p_entity_code                   => p_entity_code
              ,p_add_errors_to_fnd_stack       => G_ADD_ERRORS_TO_FND_STACK
              );
            EXCEPTION
              WHEN EGO_USER_ATTRS_COMMON_PVT.G_SUBSCRIPTION_EXC THEN
                IF (l_pre_event_failed_cursor_id IS NULL) THEN
                  l_pre_event_failed_cursor_id := DBMS_SQL.Open_Cursor;
                END IF;


                DBMS_SQL.Parse(l_pre_event_failed_cursor_id, l_pre_event_failed_sql, DBMS_SQL.NATIVE);

                DBMS_SQL.Bind_Variable(l_pre_event_failed_cursor_id, ':data_set_id', p_data_set_id);
                DBMS_SQL.Bind_Variable(l_pre_event_failed_cursor_id, ':attr_group_int_name', l_ag_deflatened_row.ATTR_GROUP_INT_NAME);
                IF (l_attr_group_metadata_obj.MULTI_ROW_CODE = 'Y') THEN
                    DBMS_SQL.Bind_Variable(l_pre_event_failed_cursor_id,':row_identifier',l_ag_deflatened_row.ROW_IDENTIFIER) ;
                END IF;

                IF(l_pk1_column_name IS NOT NULL ) THEN
                  DBMS_SQL.Bind_Variable(l_pre_event_failed_cursor_id,':pk1_value',l_ag_deflatened_row.PK1) ;
                END IF;
                IF(l_pk2_column_name IS NOT NULL ) THEN
                  DBMS_SQL.Bind_Variable(l_pre_event_failed_cursor_id,':pk2_value',l_ag_deflatened_row.PK2) ;
                END IF;
                IF(l_pk3_column_name IS NOT NULL ) THEN
                  DBMS_SQL.Bind_Variable(l_pre_event_failed_cursor_id,':pk3_value',l_ag_deflatened_row.PK3) ;
                END IF;
                IF(l_pk4_column_name IS NOT NULL ) THEN
                  DBMS_SQL.Bind_Variable(l_pre_event_failed_cursor_id,':pk4_value',l_ag_deflatened_row.PK4) ;
                END IF;
                IF(l_pk5_column_name IS NOT NULL ) THEN
                  DBMS_SQL.Bind_Variable(l_pre_event_failed_cursor_id,':pk5_value',l_ag_deflatened_row.PK5) ;
                END IF;

                IF(l_data_level_col_exists) THEN
                  DBMS_SQL.Bind_Variable(l_pre_event_failed_cursor_id,':dl_id',l_ag_deflatened_row.DATA_LEVEL_ID) ;
                  DBMS_SQL.Bind_Variable(l_pre_event_failed_cursor_id,':dl_pk1_val',l_ag_deflatened_row.DL1) ;
                  DBMS_SQL.Bind_Variable(l_pre_event_failed_cursor_id,':dl_pk2_val',l_ag_deflatened_row.DL2) ;
                  DBMS_SQL.Bind_Variable(l_pre_event_failed_cursor_id,':dl_pk3_val',l_ag_deflatened_row.DL3) ;
                  DBMS_SQL.Bind_Variable(l_pre_event_failed_cursor_id,':dl_pk4_val',l_ag_deflatened_row.DL4) ;
                  DBMS_SQL.Bind_Variable(l_pre_event_failed_cursor_id,':dl_pk5_val',l_ag_deflatened_row.DL5) ;
                ELSE
                  IF(l_data_level_column_1 IS NOT NULL ) THEN
                    DBMS_SQL.Bind_Variable(l_pre_event_failed_cursor_id,':dl1_value',l_ag_deflatened_row.DL1) ;
                  END IF;
                  IF(l_data_level_column_2 IS NOT NULL ) THEN
                    DBMS_SQL.Bind_Variable(l_pre_event_failed_cursor_id,':dl2_value',l_ag_deflatened_row.DL2) ;
                  END IF;
                  IF(l_data_level_column_3 IS NOT NULL ) THEN
                    DBMS_SQL.Bind_Variable(l_pre_event_failed_cursor_id,':dl3_value',l_ag_deflatened_row.DL3) ;
                  END IF;
                END IF;

                l_dummy := DBMS_SQL.Execute(l_pre_event_failed_cursor_id);
                DBMS_SQL.Close_Cursor (l_pre_event_failed_cursor_id);

            END;
          END LOOP;--iteration in l_dynamic_cursor ends

          CLOSE l_dynamic_cursor;
          ----------------------------------------------------------------------------------------
          -- WE NEED TO BUILD THE SQL FOR THE CURSOR FOR RAISING EVENTS FOR AG ROWS BEING CREATED
          -- SINCE FOR THE ROWS BEING CREATED THE SQL CHANGES AS WE DO NOT HAVE TO GO TO THE EXT
          -- TABLE TO GET THE EXTENSION ID.
          ----------------------------------------------------------------------------------------

          --- Added Code  '  AND UAI1.PROCESS_STATUS <> '||G_PS_SUCCESS|| for bug 7460377
          l_dynamic_sql := ' SELECT NULL , UAI1.ATTR_GROUP_INT_NAME, UAI1.TRANSACTION_TYPE, UAI1.ROW_IDENTIFIER ';
          l_dynamic_sql := l_dynamic_sql || l_dynamic_query;
          l_dynamic_sql := l_dynamic_sql || ' ,  ' ||' '' '' ' || l_defaltening_sql_create;
          l_dynamic_sql := l_dynamic_sql || ' FROM '||p_interface_table_name||' UAI1 ';
          l_dynamic_sql := l_dynamic_sql || '  WHERE UAI1.DATA_SET_ID = :data_set_id '||
                                            '  AND UAI1.PROCESS_STATUS <> '||G_PS_GENERIC_ERROR||
              '  AND UAI1.PROCESS_STATUS <> '||G_PS_SUCCESS||
                                            '  AND UAI1.ATTR_GROUP_INT_NAME = :attr_group_int_name '||
                                            '  AND UAI1.TRANSACTION_TYPE = '''||EGO_USER_ATTRS_DATA_PVT.G_CREATE_MODE||'''';
          l_dynamic_sql := l_dynamic_sql || '  GROUP BY  UAI1.ATTR_GROUP_INT_NAME, UAI1.TRANSACTION_TYPE, UAI1.ROW_IDENTIFIER '
                                         || l_dynamic_group_by;

          -------------------------------------------------------------------
          -- RAISING EVENT FOR ALL THE AG ROWS WHICH ARE *BEING* CREATED
          -------------------------------------------------------------------
          code_debug('before raising event for create rows ...');
          code_debug(l_dynamic_sql);
          OPEN l_dynamic_cursor FOR l_dynamic_sql
          USING p_data_set_id, l_attr_group_metadata_obj.ATTR_GROUP_NAME;
          LOOP
            FETCH l_dynamic_cursor INTO l_ag_deflatened_row;
            EXIT WHEN l_dynamic_cursor%NOTFOUND;
            -- Loop through the deflatened string containing the old values and
            -- prepare the table to be passed in as a parameter to pre-event
            l_attr_name_val_str := l_ag_deflatened_row.ATTR_NAME_VALUES;
            attr_name_val_pair := EGO_ATTR_TABLE();
            WHILE (INSTR(l_attr_name_val_str,'#*') <> 0)
            LOOP
              l_attr_name := SUBSTR(l_attr_name_val_str
                                    ,INSTR(l_attr_name_val_str,'#*')+2
                                    ,INSTR(l_attr_name_val_str,'*#')-INSTR(l_attr_name_val_str,'#*')-2
                                    );
              l_new_value := SUBSTR(l_attr_name_val_str
                                    ,INSTR(l_attr_name_val_str,'$[')+2
                                    ,INSTR(l_attr_name_val_str,']$')-INSTR(l_attr_name_val_str,'$[')-2
                                    );

              l_attr_name_val_str := SUBSTR(l_attr_name_val_str
                                            ,INSTR(l_attr_name_val_str,']$')+2
                                            ,LENGTH(l_attr_name_val_str)-INSTR(l_attr_name_val_str,'}$')+2
                                            );
              attr_name_val_pair.EXTEND();
              attr_name_val_pair(attr_name_val_pair.LAST) := EGO_ATTR_REC(l_attr_name, l_new_value);
            END LOOP; -- while for extracting name value pairs ends here
            -- We need to pass null as a value for all those attrs which are not
            -- entered by the user.
            FOR i IN l_attr_metadata_table.FIRST .. l_attr_metadata_table.LAST
            LOOP
              IF(INSTR(l_ag_deflatened_row.ATTR_NAME_VALUES,l_attr_metadata_table(i).ATTR_NAME) = 0) THEN
                 attr_name_val_pair.EXTEND();
                 attr_name_val_pair(attr_name_val_pair.LAST) := EGO_ATTR_REC(l_attr_metadata_table(i).ATTR_NAME, NULL);
              END IF;
            END LOOP;

           ----------------------------------------------------------------------
           -- NOW WE HAVE ALL THE DATA TO RAISE THE EVENT (Lets do it now ...) --
           ----------------------------------------------------------------------
            BEGIN

              IF(l_data_level_col_exists) THEN
                FOR i IN l_list_of_dl_for_ag_type.FIRST .. l_list_of_dl_for_ag_type.LAST
                LOOP
                   IF(l_ag_deflatened_row.DATA_LEVEL_ID = l_list_of_dl_for_ag_type(i).DATA_LEVEL_ID) THEN
                     l_dl_pk1_col_name := l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME1;
                     l_dl_pk2_col_name := l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME2;
                     l_dl_pk3_col_name := l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME3;
                     l_dl_pk4_col_name := l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME4;
                     l_dl_pk5_col_name := l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME5;
                   END IF;
                END LOOP;
              ELSE
                l_dl_pk1_col_name := l_data_level_column_1;
                l_dl_pk2_col_name := l_data_level_column_2;
                l_dl_pk3_col_name := l_data_level_column_3;
                l_dl_pk4_col_name := null;
                l_dl_pk5_col_name := null;
              END IF;
              l_event_key := SUBSTRB(l_pre_event_name, 1, 225) || '-' || TO_CHAR(SYSDATE, 'J.SSSSS');

               EGO_WF_WRAPPER_PVT.Raise_WF_Business_Event(
               p_event_name                    => l_pre_event_name
              ,p_event_key                     => l_event_key
              ,p_pre_event_flag                => 'T'
              ,p_dml_type                      => l_ag_deflatened_row.TRANSACTION_TYPE
              ,p_attr_group_name               => l_ag_deflatened_row.ATTR_GROUP_INT_NAME
              ,p_extension_id                  => l_ag_deflatened_row.EXTENSION_ID
              ,p_primary_key_1_col_name        => l_pk1_column_name
              ,p_primary_key_1_value           => l_ag_deflatened_row.PK1
              ,p_primary_key_2_col_name        => l_pk2_column_name
              ,p_primary_key_2_value           => l_ag_deflatened_row.PK2
              ,p_primary_key_3_col_name        => l_pk3_column_name
              ,p_primary_key_3_value           => l_ag_deflatened_row.PK3
              ,p_primary_key_4_col_name        => l_pk4_column_name
              ,p_primary_key_4_value           => l_ag_deflatened_row.PK4
              ,p_primary_key_5_col_name        => l_pk5_column_name
              ,p_primary_key_5_value           => l_ag_deflatened_row.PK5
              ,p_data_level_id                 => l_ag_deflatened_row.DATA_LEVEL_ID
              ,p_data_level_1_col_name         => l_dl_pk1_col_name
              ,p_data_level_1_value            => l_ag_deflatened_row.DL1
              ,p_data_level_2_col_name         => l_dl_pk2_col_name
              ,p_data_level_2_value            => l_ag_deflatened_row.DL2
              ,p_data_level_3_col_name         => l_dl_pk3_col_name
              ,p_data_level_3_value            => l_ag_deflatened_row.DL3
              ,p_data_level_4_col_name         => l_dl_pk4_col_name
              ,p_data_level_4_value            => l_ag_deflatened_row.DL4
              ,p_data_level_5_col_name         => l_dl_pk5_col_name
              ,p_data_level_5_value            => l_ag_deflatened_row.DL5
              ,p_user_row_identifier           => l_ag_deflatened_row.ROW_IDENTIFIER
              ,p_attr_name_val_tbl             => attr_name_val_pair
              ,p_entity_id                     => p_entity_id
              ,p_entity_index                  => p_entity_index
              ,p_entity_code                   => p_entity_code
              ,p_add_errors_to_fnd_stack       => G_ADD_ERRORS_TO_FND_STACK
              );
            EXCEPTION
              WHEN EGO_USER_ATTRS_COMMON_PVT.G_SUBSCRIPTION_EXC THEN
                IF (l_pre_event_failed_cursor_id IS NULL) THEN
                  l_pre_event_failed_cursor_id := DBMS_SQL.Open_Cursor;
                END IF;

                DBMS_SQL.Parse(l_pre_event_failed_cursor_id, l_pre_event_failed_sql, DBMS_SQL.NATIVE);

                DBMS_SQL.Bind_Variable(l_pre_event_failed_cursor_id, ':data_set_id', p_data_set_id);
                DBMS_SQL.Bind_Variable(l_pre_event_failed_cursor_id, ':attr_group_int_name', l_ag_deflatened_row.ATTR_GROUP_INT_NAME);
                  IF (l_attr_group_metadata_obj.MULTI_ROW_CODE = 'Y') THEN
                          DBMS_SQL.Bind_Variable(l_pre_event_failed_cursor_id,':row_identifier',l_ag_deflatened_row.ROW_IDENTIFIER) ;
                END IF   ;

                IF(l_pk1_column_name IS NOT NULL ) THEN
                  DBMS_SQL.Bind_Variable(l_pre_event_failed_cursor_id,':pk1_value',l_ag_deflatened_row.PK1) ;
                END IF;
                IF(l_pk2_column_name IS NOT NULL ) THEN
                  DBMS_SQL.Bind_Variable(l_pre_event_failed_cursor_id,':pk2_value',l_ag_deflatened_row.PK2) ;
                END IF;
                IF(l_pk3_column_name IS NOT NULL ) THEN
                  DBMS_SQL.Bind_Variable(l_pre_event_failed_cursor_id,':pk3_value',l_ag_deflatened_row.PK3) ;
                END IF;
                IF(l_pk4_column_name IS NOT NULL ) THEN
                  DBMS_SQL.Bind_Variable(l_pre_event_failed_cursor_id,':pk4_value',l_ag_deflatened_row.PK4) ;
                END IF;
                IF(l_pk5_column_name IS NOT NULL ) THEN
                  DBMS_SQL.Bind_Variable(l_pre_event_failed_cursor_id,':pk5_value',l_ag_deflatened_row.PK5) ;
                END IF;

                IF(l_data_level_col_exists) THEN
                  DBMS_SQL.Bind_Variable(l_pre_event_failed_cursor_id,':dl_id',l_ag_deflatened_row.DATA_LEVEL_ID) ;
                  DBMS_SQL.Bind_Variable(l_pre_event_failed_cursor_id,':dl_pk1_val',l_ag_deflatened_row.DL1) ;
                  DBMS_SQL.Bind_Variable(l_pre_event_failed_cursor_id,':dl_pk2_val',l_ag_deflatened_row.DL2) ;
                  DBMS_SQL.Bind_Variable(l_pre_event_failed_cursor_id,':dl_pk3_val',l_ag_deflatened_row.DL3) ;
                  DBMS_SQL.Bind_Variable(l_pre_event_failed_cursor_id,':dl_pk4_val',l_ag_deflatened_row.DL4) ;
                  DBMS_SQL.Bind_Variable(l_pre_event_failed_cursor_id,':dl_pk5_val',l_ag_deflatened_row.DL5) ;
                ELSE
                  IF(l_data_level_column_1 IS NOT NULL ) THEN
                    DBMS_SQL.Bind_Variable(l_pre_event_failed_cursor_id,':dl1_value',l_ag_deflatened_row.DL1) ;
                  END IF;
                  IF(l_data_level_column_2 IS NOT NULL ) THEN
                    DBMS_SQL.Bind_Variable(l_pre_event_failed_cursor_id,':dl2_value',l_ag_deflatened_row.DL2) ;
                  END IF;
                  IF(l_data_level_column_3 IS NOT NULL ) THEN
                    DBMS_SQL.Bind_Variable(l_pre_event_failed_cursor_id,':dl3_value',l_ag_deflatened_row.DL3) ;
                  END IF;
                END IF;

                l_dummy := DBMS_SQL.Execute(l_pre_event_failed_cursor_id);
                DBMS_SQL.Close_Cursor (l_pre_event_failed_cursor_id);

            END;

          END LOOP;--iteration in l_dynamic_cursor ends
          CLOSE l_dynamic_cursor;

          -------------------------------------------------
          --
          -------------------------------------------------
        END IF;

      ------- WE ARE DONE WITH RAISING PRE EVENTS
      END IF; --*p_do_dml-IF-1* ending the p_do_dml IF


                          --===========--
                          -- DML SETUP --
                          --===========--

      code_debug('          Before the DML for ATTR GROUP '||l_attr_group_intf_rec.ATTR_GROUP_INT_NAME ,2);

      ----------------------------------------------------------------
      -- Build a row-to-column transformation query and the various --
      -- bits and pieces needed for our DMLs; we can build the base --
      -- parts once and re-use them throughout our looping, but we  --
      -- will need to build the Attr Group-specific parts for each  --
      -- distinct Attr Group we process                             --
      ----------------------------------------------------------------
      IF (l_row_to_column_query_base IS NULL) THEN

        -------------------------------------------------------------
        -- Start the query base, CC/PK/DL lists, etc. from scratch --
        -- as they will only be built once per call and re-used    --
        -------------------------------------------------------------
        -- GNANDA: the extension_id col added in the select below is just a dummy column, we donot use it anywhere
        -- this was added coz for supporting TL UK cols we had to add the extension_id column in the UK where clause
        -- and hence it was reqd. in the RTCQ
        l_row_to_column_query_base := 'SELECT 2910 EXTENSION_ID, MAX(ROW_IDENTIFIER) ROW_IDENTIFIER,MAX(TRANSACTION_TYPE) TRANSACTION_TYPE,MAX(ATTR_GROUP_ID) ATTR_GROUP_ID,MAX('||l_class_code_column_name||') '||l_class_code_column_name;
        l_rtcq_alias_cc_pk_dl_list := ',RTCQ.'||l_class_code_column_name;
        l_no_alias_cc_pk_dl_list := ','||l_class_code_column_name;
        IF(l_ag_id_col_exists) THEN
          l_rtcq_to_ext_where_base := ' AND RTCQ.ATTR_GROUP_ID=EXT.ATTR_GROUP_ID AND EXT.ATTR_GROUP_ID=:curr_attr_group_id';
        ELSE
          l_rtcq_to_ext_where_base := ' AND 2=2 ';
        END IF;

        l_db_col_tbl_declare_ext_id := 'ext_id_tbl EGO_USER_ATTRS_BULK_PVT.EGO_USER_ATTRS_BULK_NUM_TBL;';
        l_db_col_tbl_collect_ext_id := 'ext_id_tbl';

        IF(l_ag_id_col_exists) THEN
          l_db_col_tbl_where_ext_id := 'EXT.ATTR_GROUP_ID=:curr_attr_group_id AND EXT.EXTENSION_ID=ext_id_tbl(i)';
        ELSE
          l_db_col_tbl_where_ext_id := ' 1=1 AND EXT.EXTENSION_ID=ext_id_tbl(i)';
        END IF;

        ------------------------
        -- Add the PK columns --
        ------------------------
        l_concat_pk_cols := '';  -- Bug 9851212

        IF (l_pk1_column_name IS NOT NULL) THEN
          l_row_to_column_query_base := l_row_to_column_query_base||
                                        ',MAX('||l_pk1_column_name||') '||
                                        l_pk1_column_name;
          l_rtcq_alias_cc_pk_dl_list := l_rtcq_alias_cc_pk_dl_list||
                                        ',RTCQ.'||l_pk1_column_name;
          l_no_alias_cc_pk_dl_list := l_no_alias_cc_pk_dl_list||','||l_pk1_column_name;
          l_rtcq_to_ext_where_base := l_rtcq_to_ext_where_base||
                                      ' AND RTCQ.'||l_pk1_column_name||'=EXT.'||l_pk1_column_name;
          l_concat_pk_cols := l_concat_pk_cols||', '||l_pk1_column_name;    -- Bug 9851212
        END IF;
        IF (l_pk2_column_name IS NOT NULL) THEN
          l_row_to_column_query_base := l_row_to_column_query_base||
                                        ',MAX('||l_pk2_column_name||') '||
                                        l_pk2_column_name;
          l_rtcq_alias_cc_pk_dl_list := l_rtcq_alias_cc_pk_dl_list||
                                        ',RTCQ.'||l_pk2_column_name;
          l_no_alias_cc_pk_dl_list := l_no_alias_cc_pk_dl_list||','||l_pk2_column_name;
          l_rtcq_to_ext_where_base := l_rtcq_to_ext_where_base||
                                      ' AND RTCQ.'||l_pk2_column_name||'=EXT.'||l_pk2_column_name;
          l_concat_pk_cols := l_concat_pk_cols||', '||l_pk2_column_name;    -- Bug 9851212
        END IF;
        IF (l_pk3_column_name IS NOT NULL) THEN
          l_row_to_column_query_base := l_row_to_column_query_base||
                                        ',MAX('||l_pk3_column_name||') '||
                                        l_pk3_column_name;
          l_rtcq_alias_cc_pk_dl_list := l_rtcq_alias_cc_pk_dl_list||
                                        ',RTCQ.'||l_pk3_column_name;
          l_no_alias_cc_pk_dl_list := l_no_alias_cc_pk_dl_list||','||l_pk3_column_name;
          l_rtcq_to_ext_where_base := l_rtcq_to_ext_where_base||
                                      ' AND RTCQ.'||l_pk3_column_name||'=EXT.'||l_pk3_column_name;
          l_concat_pk_cols := l_concat_pk_cols||', '||l_pk3_column_name;    -- Bug 9851212
        END IF;
        IF (l_pk4_column_name IS NOT NULL) THEN
          l_row_to_column_query_base := l_row_to_column_query_base||
                                        ',MAX('||l_pk4_column_name||') '||
                                        l_pk4_column_name;
          l_rtcq_alias_cc_pk_dl_list := l_rtcq_alias_cc_pk_dl_list||
                                        ',RTCQ.'||l_pk4_column_name;
          l_no_alias_cc_pk_dl_list := l_no_alias_cc_pk_dl_list||','||l_pk4_column_name;
          l_rtcq_to_ext_where_base := l_rtcq_to_ext_where_base||
                                      ' AND RTCQ.'||l_pk4_column_name||'=EXT.'||l_pk4_column_name;
          l_concat_pk_cols := l_concat_pk_cols||', '||l_pk4_column_name;    -- Bug 9851212
        END IF;
        IF (l_pk5_column_name IS NOT NULL) THEN
          l_row_to_column_query_base := l_row_to_column_query_base||
                                        ',MAX('||l_pk5_column_name||') '||
                                        l_pk5_column_name;
          l_rtcq_alias_cc_pk_dl_list := l_rtcq_alias_cc_pk_dl_list||
                                        ',RTCQ.'||l_pk5_column_name;
          l_no_alias_cc_pk_dl_list := l_no_alias_cc_pk_dl_list||','||l_pk5_column_name;
          l_rtcq_to_ext_where_base := l_rtcq_to_ext_where_base||
                                      ' AND RTCQ.'||l_pk5_column_name||'=EXT.'||l_pk5_column_name;
          l_concat_pk_cols := l_concat_pk_cols||', '||l_pk5_column_name;    -- Bug 9851212
        END IF;

        ------------------------------------------------
        -- Finally, add the DL columns (if necessary) --
        ------------------------------------------------
        IF(l_data_level_col_exists) THEN

          l_row_to_column_query_base := l_row_to_column_query_base||',MAX(DATA_LEVEL_ID) DATA_LEVEL_ID ';
          l_rtcq_alias_cc_pk_dl_list := l_rtcq_alias_cc_pk_dl_list||',RTCQ.DATA_LEVEL_ID ';
          l_no_alias_cc_pk_dl_list := l_no_alias_cc_pk_dl_list||', DATA_LEVEL_ID ';
          l_rtcq_to_ext_where_base := l_rtcq_to_ext_where_base||
                                      ' AND NVL(RTCQ.DATA_LEVEL_ID,-1)=NVL(EXT.DATA_LEVEL_ID ,-1)';

          FOR i IN l_list_of_dl_for_ag_type.FIRST .. l_list_of_dl_for_ag_type.LAST
          LOOP
              IF (l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME1 IS NOT NULL AND l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME1 <> 'NONE'
                  AND INSTR(l_row_to_column_query_base,l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME1) = 0) THEN

                  l_row_to_column_query_base := l_row_to_column_query_base||',MAX('||l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME1||') '||
                                                l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME1;
                  l_rtcq_alias_cc_pk_dl_list := l_rtcq_alias_cc_pk_dl_list||',RTCQ.'||l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME1;
                  l_no_alias_cc_pk_dl_list := l_no_alias_cc_pk_dl_list||','||l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME1;
                  l_rtcq_to_ext_where_base := l_rtcq_to_ext_where_base||
                                              ' AND NVL(RTCQ.'||l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME1||
                                              ',-1)=NVL(EXT.'||l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME1||',-1)';
              END IF;
              IF (l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME2 IS NOT NULL AND l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME2 <> 'NONE'
                  AND INSTR(l_row_to_column_query_base,l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME2) = 0) THEN

                  l_row_to_column_query_base := l_row_to_column_query_base||',MAX('||l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME2||') '||
                                                l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME2;
                  l_rtcq_alias_cc_pk_dl_list := l_rtcq_alias_cc_pk_dl_list||',RTCQ.'||l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME2;
                  l_no_alias_cc_pk_dl_list := l_no_alias_cc_pk_dl_list||','||l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME2;
                  l_rtcq_to_ext_where_base := l_rtcq_to_ext_where_base||
                                              ' AND NVL(RTCQ.'||l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME2||
                                              ',-1)=NVL(EXT.'||l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME2||',-1)';
              END IF;
              IF (l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME3 IS NOT NULL AND l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME3 <> 'NONE'
                  AND INSTR(l_row_to_column_query_base,l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME3) = 0) THEN

                  l_row_to_column_query_base := l_row_to_column_query_base||',MAX('||l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME3||') '||
                                                l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME3;
                  l_rtcq_alias_cc_pk_dl_list := l_rtcq_alias_cc_pk_dl_list||',RTCQ.'||l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME3;
                  l_no_alias_cc_pk_dl_list := l_no_alias_cc_pk_dl_list||','||l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME3;
                  l_rtcq_to_ext_where_base := l_rtcq_to_ext_where_base||
                                              ' AND NVL(RTCQ.'||l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME3||
                                              ',-1)=NVL(EXT.'||l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME3||',-1)';
              END IF;
              IF (l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME4 IS NOT NULL AND l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME4 <> 'NONE'
                  AND INSTR(l_row_to_column_query_base,l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME4) = 0) THEN

                  l_row_to_column_query_base := l_row_to_column_query_base||',MAX('||l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME4||') '||
                                                l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME4;
                  l_rtcq_alias_cc_pk_dl_list := l_rtcq_alias_cc_pk_dl_list||',RTCQ.'||l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME4;
                  l_no_alias_cc_pk_dl_list := l_no_alias_cc_pk_dl_list||','||l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME4;
                  l_rtcq_to_ext_where_base := l_rtcq_to_ext_where_base||
                                              ' AND NVL(RTCQ.'||l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME4||
                                              ',-1)=NVL(EXT.'||l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME4||',-1)';
              END IF;
              IF (l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME5 IS NOT NULL AND l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME5 <> 'NONE'
                  AND INSTR(l_row_to_column_query_base,l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME5) = 0) THEN

                  l_row_to_column_query_base := l_row_to_column_query_base||',MAX('||l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME5||') '||
                                                l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME5;
                  l_rtcq_alias_cc_pk_dl_list := l_rtcq_alias_cc_pk_dl_list||',RTCQ.'||l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME5;
                  l_no_alias_cc_pk_dl_list := l_no_alias_cc_pk_dl_list||','||l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME5;
                  l_rtcq_to_ext_where_base := l_rtcq_to_ext_where_base||
                                              ' AND NVL(RTCQ.'||l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME5||
                                              ',-1)=NVL(EXT.'||l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME5||',-1)';
              END IF;
          END LOOP;
        ELSE
          IF (l_num_data_level_columns >= 1) THEN
            l_row_to_column_query_base := l_row_to_column_query_base||
                                          ',MAX('||l_data_level_column_1||') '||
                                          l_data_level_column_1;
            l_rtcq_alias_cc_pk_dl_list := l_rtcq_alias_cc_pk_dl_list||
                                          ',RTCQ.'||l_data_level_column_1;
            l_no_alias_cc_pk_dl_list := l_no_alias_cc_pk_dl_list||
                                        ','||l_data_level_column_1;
            l_rtcq_to_ext_where_base := l_rtcq_to_ext_where_base||
                                        ' AND NVL(RTCQ.'||l_data_level_column_1||
                                        ',-1)=NVL(EXT.'||l_data_level_column_1||',-1)';
          END IF;
          IF (l_num_data_level_columns >= 2) THEN
            l_row_to_column_query_base := l_row_to_column_query_base||
                                          ',MAX('||l_data_level_column_2||') '||
                                          l_data_level_column_2;
            l_rtcq_alias_cc_pk_dl_list := l_rtcq_alias_cc_pk_dl_list||
                                          ',RTCQ.'||l_data_level_column_2;
            l_no_alias_cc_pk_dl_list := l_no_alias_cc_pk_dl_list||
                                        ','||l_data_level_column_2;
            l_rtcq_to_ext_where_base := l_rtcq_to_ext_where_base||
                                        ' AND NVL(RTCQ.'||l_data_level_column_2||
                                        ',-1)=NVL(EXT.'||l_data_level_column_2||',-1)';
          END IF;
          IF (l_num_data_level_columns = 3) THEN
            l_row_to_column_query_base := l_row_to_column_query_base||
                                          ',MAX('||l_data_level_column_3||') '||
                                          l_data_level_column_3;
            l_rtcq_alias_cc_pk_dl_list := l_rtcq_alias_cc_pk_dl_list||
                                          ',RTCQ.'||l_data_level_column_3;
            l_no_alias_cc_pk_dl_list := l_no_alias_cc_pk_dl_list||
                                        ','||l_data_level_column_3;
            l_rtcq_to_ext_where_base := l_rtcq_to_ext_where_base||
                                        ' AND NVL(RTCQ.'||l_data_level_column_3||
                                        ',-1)=NVL(EXT.'||l_data_level_column_3||',-1)';
          END IF;
        END IF;
      END IF;
      ----------------------------------------------------------------------
      -- Now we build our DML and query pieces that differ by Attr Group; --
      -- we reset all of these variables for each distinct Attr Group     --
      ----------------------------------------------------------------------
      l_rn_index_for_ag := 0;
      l_row_to_column_query_ag_part := NULL;
      l_row_to_column_attr_decode := NULL;
      l_rtcq_to_ext_where_uks := NULL;
      l_rtcq_to_ext_whr_uks_idnt_chk := NULL;
      l_rtcq_alias_b_cols_list := NULL;
      l_final_b_col_list := NULL;
      l_final_tl_col_list := NULL;
      l_rtcq_alias_b_cols_list_1 := NULL;
      l_rtcq_alias_tl_cols_list := NULL;
      l_rtcq_alias_tl_cols_list_1 := NULL;
      l_no_alias_b_cols_list := NULL;
      l_no_alias_b_values_list := NULL;
      l_no_alias_tl_cols_list := NULL;
      l_no_alias_tl_cols_sel_list := NULL;
      l_db_col_tbl_declare_attrs := NULL;
      l_db_col_tbl_collect_b_attrs := NULL;
      l_db_col_tbl_collect_tl_attrs := NULL;
      l_db_col_tbl_set_b_attrs := NULL;
      l_db_col_tbl_set_tl_attrs := NULL;

      FOR d IN l_attr_metadata_table_sr.FIRST .. l_attr_metadata_table_sr.LAST
      LOOP

        IF (Attr_Is_In_Data_Set(l_attr_metadata_table_sr(d), l_dist_attrs_in_data_set_table)
            OR
            l_attr_metadata_table_sr(d).UNIQUE_KEY_FLAG = 'Y' --BugFix: 5361255 : we need to add the uk attr in the where clause weather
           ) THEN                                             --                  or not we have data for it in the intf table.

          l_rn_index_for_ag := l_rn_index_for_ag + 1;

          -------------------------------------------------------
          -- lets get ready with the correct wierd constant    --
          -------------------------------------------------------

          IF (l_attr_metadata_table_sr(d).DATA_TYPE_CODE = EGO_EXT_FWK_PUB.G_NUMBER_DATA_TYPE) THEN
           wierd_constant :=  G_NULL_TOKEN_NUM;
           wierd_constant_2 := '8.88E125';
          ELSIF (   l_attr_metadata_table_sr(d).DATA_TYPE_CODE = EGO_EXT_FWK_PUB.G_DATE_DATA_TYPE
                 OR l_attr_metadata_table_sr(d).DATA_TYPE_CODE = EGO_EXT_FWK_PUB.G_DATE_TIME_DATA_TYPE ) THEN
           wierd_constant :=  G_NULL_TOKEN_DATE;
           wierd_constant_2 := 'TO_DATE(''2'',''J'')';
          ELSE
           wierd_constant := G_NULL_TOKEN_STR;
           wierd_constant_2 := 'CHR(2)';
          END IF;

          -------------------------------------------------------
          -- UK clause (note that we only update non-UK Attrs) --
          -------------------------------------------------------
          IF (l_attr_metadata_table_sr(d).UNIQUE_KEY_FLAG = 'Y') THEN

            IF (l_attr_metadata_table_sr(d).DATA_TYPE_CODE = EGO_EXT_FWK_PUB.G_TRANS_TEXT_DATA_TYPE) THEN
              --GNANDA: While inserting rows in the TL table for a case where we have a TL Uk we insert rows for
              --all the rows int he B table for the given pk's and uk's which do not have a corresponding rows in the TL table.

              --While checking for identical rows in the data_set there is a self join in RTCQ (RTCQ and EXT), contrary to the DML's
              --where EXT is the actual EXT base table, hence we need to build a seperate where clause for identical check
              --i.e. l_rtcq_to_ext_whr_uks_idnt_chk.
              l_rtcq_to_ext_where_uks := l_rtcq_to_ext_where_uks||
                                         ' AND NVL(RTCQ.'||l_attr_metadata_table_sr(d).DATABASE_COLUMN||','||wierd_constant||')'||
                                         '= DECODE (RTCQ.TRANSACTION_TYPE, '''||EGO_USER_ATTRS_DATA_PVT.G_CREATE_MODE||''' , '||
                                         'NVL((SELECT NVL(RTCQ.'||l_attr_metadata_table_sr(d).DATABASE_COLUMN||','||wierd_constant||') FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM '||
                                                                                          l_ext_tl_table_name||' WHERE  EXTENSION_ID = EXT.EXTENSION_ID AND ROWNUM = 1 )), '||wierd_constant_2||' ) '||
                                         ',NVL((SELECT '||l_attr_metadata_table_sr(d).DATABASE_COLUMN || ' FROM '||l_ext_tl_table_name||' WHERE LANGUAGE = USERENV(''LANG'') AND EXTENSION_ID = EXT.EXTENSION_ID),'||wierd_constant||' ) '||
                                         ')';
              l_rtcq_to_ext_whr_uks_idnt_chk := l_rtcq_to_ext_whr_uks_idnt_chk||
                                         ' AND NVL(RTCQ.'||l_attr_metadata_table_sr(d).DATABASE_COLUMN||','||wierd_constant||')'||
                                         '= NVL(EXT.'||l_attr_metadata_table_sr(d).DATABASE_COLUMN||','||wierd_constant||')';
            ELSE
              l_rtcq_to_ext_where_uks := l_rtcq_to_ext_where_uks||
                                         ' AND NVL(RTCQ.'||l_attr_metadata_table_sr(d).DATABASE_COLUMN||','||wierd_constant||')'||
                                         '= NVL(EXT.'||l_attr_metadata_table_sr(d).DATABASE_COLUMN||','||wierd_constant||')';

              l_rtcq_to_ext_whr_uks_idnt_chk := l_rtcq_to_ext_whr_uks_idnt_chk||
                                         ' AND NVL(RTCQ.'||l_attr_metadata_table_sr(d).DATABASE_COLUMN||','||wierd_constant||')'||
                                         '= NVL(EXT.'||l_attr_metadata_table_sr(d).DATABASE_COLUMN||','||wierd_constant||')';
            END IF;

          END IF;

          -----------------------------------
          -- Data type-independent clauses --
          -----------------------------------
          l_row_to_column_attr_decode := l_row_to_column_attr_decode||
                                         ','''||l_attr_metadata_table_sr(d).ATTR_NAME||
                                         ''','||l_rn_index_for_ag;

          -- this one is closed below...
          l_row_to_column_query_ag_part := l_row_to_column_query_ag_part||
                                           ',MAX(DECODE(RN,'||l_rn_index_for_ag||',';

          ---------------------------------
          -- Data type-dependent clauses --
          ---------------------------------
          IF (l_attr_metadata_table_sr(d).DATA_TYPE_CODE =
              EGO_EXT_FWK_PUB.G_NUMBER_DATA_TYPE) THEN

            l_row_to_column_query_ag_part := l_row_to_column_query_ag_part||
                                             'DECODE(TRANSACTION_TYPE,'''||EGO_USER_ATTRS_DATA_PVT.G_CREATE_MODE||''',DECODE(ATTR_VALUE_NUM,'||wierd_constant||',NULL,ATTR_VALUE_NUM), ATTR_VALUE_NUM)';
            -- ...this closes what started above
            l_row_to_column_query_ag_part := l_row_to_column_query_ag_part||')) '||
                                             l_attr_metadata_table_sr(d).DATABASE_COLUMN;

            IF (l_attr_metadata_table_sr(d).UNIT_OF_MEASURE_CLASS IS NOT NULL) THEN
              l_row_to_column_query_ag_part := l_row_to_column_query_ag_part||
                                               ',MAX(DECODE(RN,'||l_rn_index_for_ag||',';
              l_row_to_column_query_ag_part := l_row_to_column_query_ag_part||
                                               'DECODE(TRANSACTION_TYPE,'''||EGO_USER_ATTRS_DATA_PVT.G_CREATE_MODE||''',DECODE(ATTR_VALUE_UOM,'||G_NULL_TOKEN_STR||',NULL,ATTR_VALUE_UOM), ATTR_VALUE_UOM)';
              l_row_to_column_query_ag_part := l_row_to_column_query_ag_part||')) '||
                                             l_attr_metadata_table_sr(d).DATABASE_COLUMN||'_UOM';
            END IF;

            l_db_col_tbl_declare_attrs := l_db_col_tbl_declare_attrs||
                                          'attr_'||l_rn_index_for_ag||
                                          '_tbl EGO_USER_ATTRS_BULK_PVT.EGO_USER_ATTRS_BULK_NUM_TBL;';
            l_db_col_tbl_declare_attrs := l_db_col_tbl_declare_attrs||
                                          'attr_'||l_rn_index_for_ag||
                                          '_uom_tbl EGO_USER_ATTRS_BULK_PVT.EGO_USER_ATTRS_BULK_STR_TBL;';

            -- we only update non-UK Attrs
            IF (l_attr_metadata_table_sr(d).UNIQUE_KEY_FLAG IS NULL
                OR l_attr_metadata_table_sr(d).UNIQUE_KEY_FLAG <> 'Y') THEN

                IF ( l_attr_metadata_table_sr(d).UNIT_OF_MEASURE_CLASS IS NOT NULL) THEN

                    IF (INSTR(l_attr_metadata_table_sr(d).DATABASE_COLUMN, 'N_EXT_ATTR') = 1) THEN
                      l_uom_column1 := 'UOM_' || SUBSTR(l_attr_metadata_table_sr(d).DATABASE_COLUMN, 3);
                    ELSE
                      l_uom_column1 := 'UOM_' || l_attr_metadata_table_sr(d).DATABASE_COLUMN;
                    END IF;

                    l_db_col_tbl_set_b_attrs := l_db_col_tbl_set_b_attrs||
                                                 ',EXT.'||
                                                 l_attr_metadata_table_sr(d).DATABASE_COLUMN||
                                                 '=DECODE(attr_'||l_rn_index_for_ag||
                                                 '_tbl(i),'||EGO_USER_ATTRS_BULK_PVT.G_NULL_TOKEN_NUM||
                                                 ',NULL,NULL,EXT.'||l_attr_metadata_table_sr(d).DATABASE_COLUMN||
             ','||G_NULL_TOKEN_NUM_1||',EXT.'||l_attr_metadata_table_sr(d).DATABASE_COLUMN||--bugfix:6526366
                                                 ',attr_'||l_rn_index_for_ag||'_tbl(i))'||
                                                 ',EXT.'||l_uom_column1 ||
                                                 '= DECODE(attr_'||l_rn_index_for_ag||'_uom_tbl(i) ,NULL, '||'NVL (EXT.'||l_uom_column1||' ,'''||l_attr_metadata_table_sr(d).UNIT_OF_MEASURE_BASE||''')  '
                                                                                                 ||','||EGO_USER_ATTRS_BULK_PVT.G_NULL_TOKEN_STR||','||'NVL (EXT.'||l_uom_column1||' ,'''||l_attr_metadata_table_sr(d).UNIT_OF_MEASURE_BASE||''')  '
                         ||','||EGO_USER_ATTRS_BULK_PVT.G_NULL_TOKEN_STR_1||','||'NVL (EXT.'||l_uom_column1||' ,'''||l_attr_metadata_table_sr(d).UNIT_OF_MEASURE_BASE||''')  '--bugfix:6526366
                                                                                                 ||',attr_'||l_rn_index_for_ag||'_uom_tbl(i) )';--BugFux:5509743
                ELSE
                    l_db_col_tbl_set_b_attrs := l_db_col_tbl_set_b_attrs||
                                                ',EXT.'||
                                                l_attr_metadata_table_sr(d).DATABASE_COLUMN||
                                                '=DECODE(attr_'||l_rn_index_for_ag||
                                                '_tbl(i),'||EGO_USER_ATTRS_BULK_PVT.G_NULL_TOKEN_NUM||
                                                ',NULL,NULL,EXT.'||l_attr_metadata_table_sr(d).DATABASE_COLUMN||
            ','||G_NULL_TOKEN_NUM_1||',EXT.'||l_attr_metadata_table_sr(d).DATABASE_COLUMN||--bugfix:6526366
                                                ',attr_'||l_rn_index_for_ag||'_tbl(i))';

               END IF;
            END IF;

          ELSIF (l_attr_metadata_table_sr(d).DATA_TYPE_CODE =
                 EGO_EXT_FWK_PUB.G_DATE_DATA_TYPE OR
                 l_attr_metadata_table_sr(d).DATA_TYPE_CODE =
                 EGO_EXT_FWK_PUB.G_DATE_TIME_DATA_TYPE) THEN

            --Bug 4473391(gnanda) : we need to convert the attr_value_date to char in the decode and then convert the final value into
            --date otherwise decode would remove the time part from date time attribute.
            l_row_to_column_query_ag_part := l_row_to_column_query_ag_part||
                             'DECODE(TRANSACTION_TYPE,'''||EGO_USER_ATTRS_DATA_PVT.G_UPDATE_MODE||''',ATTR_VALUE_DATE,TO_DATE(DECODE(ATTR_VALUE_DATE,'||wierd_constant||
                             ',NULL,TO_CHAR(ATTR_VALUE_DATE,''DD/MM/YYYY HH24:MI:SS'')),''DD/MM/YYYY HH24:MI:SS'') )';
            -- ...this closes what started above
            l_row_to_column_query_ag_part := l_row_to_column_query_ag_part||')) '||
                                             l_attr_metadata_table_sr(d).DATABASE_COLUMN;

            l_db_col_tbl_declare_attrs := l_db_col_tbl_declare_attrs||
                                          'attr_'||l_rn_index_for_ag||
                                          '_tbl EGO_USER_ATTRS_BULK_PVT.EGO_USER_ATTRS_BULK_DATE_TBL;';

            -- we only update non-UK Attrs
            IF (l_attr_metadata_table_sr(d).UNIQUE_KEY_FLAG IS NULL
                OR l_attr_metadata_table_sr(d).UNIQUE_KEY_FLAG <> 'Y') THEN

              --Bug 4473391(gnanda) : we need to convert the attr_value_date to char in the decode and then convert the final value into
              --date otherwise decode would remove the time part from date time attribute.
              l_db_col_tbl_set_b_attrs := l_db_col_tbl_set_b_attrs||
                                          ',EXT.'||
                                          l_attr_metadata_table_sr(d).DATABASE_COLUMN||
                                          --FP bug 8270556 with base bug 8238064
                                          '=DECODE(attr_'||l_rn_index_for_ag||'_tbl(i) ,NULL, EXT.'||l_attr_metadata_table_sr(d).DATABASE_COLUMN||' , '||
                                          'TO_DATE(DECODE(attr_'||l_rn_index_for_ag||
                                          '_tbl(i),'||EGO_USER_ATTRS_BULK_PVT.G_NULL_TOKEN_DATE||
                                          ',NULL,NULL,EXT.'||l_attr_metadata_table_sr(d).DATABASE_COLUMN||
            ','||G_NULL_TOKEN_DATE_1||',EXT.'||l_attr_metadata_table_sr(d).DATABASE_COLUMN||--bugfix:6526366
                                          ',TO_CHAR(attr_'||l_rn_index_for_ag||'_tbl(i), ''DD/MM/YYYY HH24:MI:SS'') ),''DD/MM/YYYY HH24:MI:SS''))';

            END IF;
          ELSE

            l_row_to_column_query_ag_part := l_row_to_column_query_ag_part||
                             'DECODE(TRANSACTION_TYPE,'''||EGO_USER_ATTRS_DATA_PVT.G_CREATE_MODE||''',DECODE(ATTR_VALUE_STR,'||wierd_constant||',NULL,ATTR_VALUE_STR), ATTR_VALUE_STR)';
            -- ...this closes what started above
            l_row_to_column_query_ag_part := l_row_to_column_query_ag_part||')) '||
                                             l_attr_metadata_table_sr(d).DATABASE_COLUMN;

            l_db_col_tbl_declare_attrs := l_db_col_tbl_declare_attrs||
                                          'attr_'||l_rn_index_for_ag||
                                          '_tbl EGO_USER_ATTRS_BULK_PVT.EGO_USER_ATTRS_BULK_STR_TBL;';

            -- we only update non-UK Attrs
            IF (l_attr_metadata_table_sr(d).UNIQUE_KEY_FLAG IS NULL
                OR l_attr_metadata_table_sr(d).UNIQUE_KEY_FLAG <> 'Y') THEN

              IF (l_attr_metadata_table_sr(d).DATA_TYPE_CODE =
                  EGO_EXT_FWK_PUB.G_TRANS_TEXT_DATA_TYPE) THEN

                l_db_col_tbl_set_tl_attrs := l_db_col_tbl_set_tl_attrs||
                                             ',EXT.'||
                                             l_attr_metadata_table_sr(d).DATABASE_COLUMN||
                                             '=DECODE(attr_'||l_rn_index_for_ag||
                                             '_tbl(i),'||EGO_USER_ATTRS_BULK_PVT.G_NULL_TOKEN_STR||
                                             ',NULL,NULL,EXT.'||l_attr_metadata_table_sr(d).DATABASE_COLUMN||
                                             ',attr_'||l_rn_index_for_ag||'_tbl(i))';

              ELSE

                l_db_col_tbl_set_b_attrs := l_db_col_tbl_set_b_attrs||
                                             ',EXT.'||
                                             l_attr_metadata_table_sr(d).DATABASE_COLUMN||
                                             '=DECODE(attr_'||l_rn_index_for_ag||
                                             '_tbl(i),'||EGO_USER_ATTRS_BULK_PVT.G_NULL_TOKEN_STR||
                                             ',NULL,NULL,EXT.'||l_attr_metadata_table_sr(d).DATABASE_COLUMN||
                                             ','||G_NULL_TOKEN_STR_1||',EXT.'||l_attr_metadata_table_sr(d).DATABASE_COLUMN||--bugfix:6526366
                                             ',attr_'||l_rn_index_for_ag||'_tbl(i))';

              END IF;
            END IF;
          END IF;

          ----------------------
          -- B vs. TL clauses --
          ----------------------
          IF (l_attr_metadata_table_sr(d).DATA_TYPE_CODE =
              EGO_EXT_FWK_PUB.G_TRANS_TEXT_DATA_TYPE) THEN

            l_rtcq_alias_tl_cols_list := l_rtcq_alias_tl_cols_list||',RTCQ.'||
                                         l_attr_metadata_table_sr(d).DATABASE_COLUMN;
            l_rtcq_alias_tl_cols_list_1 := l_rtcq_alias_tl_cols_list_1||',DECODE(INTF_TL.COLUMN_NAME, '''||l_attr_metadata_table_sr(d).ATTR_NAME||''' ,'
                                                                      ||' INTF_TL.COLUMN_VALUE , '||G_NULL_TOKEN_STR||' ) '||l_attr_metadata_table_sr(d).DATABASE_COLUMN;

            l_no_alias_tl_cols_list := l_no_alias_tl_cols_list||','||
                                       l_attr_metadata_table_sr(d).DATABASE_COLUMN;
            l_no_alias_tl_cols_sel_list := l_no_alias_tl_cols_sel_list||'  , '||' NVL( (SELECT COLUMN_VALUE            '
                                                                              ||'         FROM EGO_INTERFACE_TL        '
                                                                              ||'        WHERE SET_PROCESS_ID = '||p_data_set_id
                                                                              ||'          AND TABLE_NAME = '''||p_interface_table_name||'''  '
                                                                              ||'          AND COLUMN_NAME = '''||l_attr_metadata_table_sr(d).ATTR_NAME||''' '
                                                                              ||'          AND UNIQUE_ID = RTCQ.ROW_IDENTIFIER '
                                                                              ||'          AND LANGUAGE = L.LANGUAGE_CODE) ,'||l_attr_metadata_table_sr(d).DATABASE_COLUMN||') ';

            l_db_col_tbl_collect_tl_attrs := l_db_col_tbl_collect_tl_attrs||
                                             ',attr_'||l_rn_index_for_ag||'_tbl';

            l_final_tl_col_list := l_final_tl_col_list ||','||l_attr_metadata_table_sr(d).DATABASE_COLUMN;

          ELSE

            l_final_b_col_list := l_final_b_col_list ||','||l_attr_metadata_table_sr(d).DATABASE_COLUMN;

            l_rtcq_alias_b_cols_list := l_rtcq_alias_b_cols_list||',RTCQ.'||
                                        l_attr_metadata_table_sr(d).DATABASE_COLUMN;

            IF (l_attr_metadata_table_sr(d).DATA_TYPE_CODE =
                EGO_EXT_FWK_PUB.G_NUMBER_DATA_TYPE) THEN
                l_rtcq_alias_b_cols_list_1 := l_rtcq_alias_b_cols_list_1||', '''||EGO_USER_ATTRS_BULK_PVT.G_NULL_TOKEN_NUM_1||''' '
                                                                        ||l_attr_metadata_table_sr(d).DATABASE_COLUMN;
            ELSIF (l_attr_metadata_table_sr(d).DATA_TYPE_CODE = EGO_EXT_FWK_PUB.G_DATE_TIME_DATA_TYPE OR
                   l_attr_metadata_table_sr(d).DATA_TYPE_CODE = EGO_EXT_FWK_PUB.G_DATE_DATA_TYPE ) THEN
                l_rtcq_alias_b_cols_list_1 := l_rtcq_alias_b_cols_list_1||', '||EGO_USER_ATTRS_BULK_PVT.G_NULL_TOKEN_DATE_1||' '
                                                                        ||l_attr_metadata_table_sr(d).DATABASE_COLUMN;
            ELSE
                l_rtcq_alias_b_cols_list_1 := l_rtcq_alias_b_cols_list_1||', '||EGO_USER_ATTRS_BULK_PVT.G_NULL_TOKEN_STR_1||' '
                                                                        ||l_attr_metadata_table_sr(d).DATABASE_COLUMN;

            END IF;
            l_no_alias_b_cols_list := l_no_alias_b_cols_list||','||
                                      l_attr_metadata_table_sr(d).DATABASE_COLUMN;
            l_no_alias_b_values_list := l_no_alias_b_values_list||','||
                                        l_attr_metadata_table_sr(d).DATABASE_COLUMN;
            l_db_col_tbl_collect_b_attrs := l_db_col_tbl_collect_b_attrs||
                                            ',attr_'||l_rn_index_for_ag||'_tbl';

            IF (l_attr_metadata_table_sr(d).UNIT_OF_MEASURE_CLASS IS NOT NULL) THEN

              l_final_b_col_list := l_final_b_col_list ||','||l_attr_metadata_table_sr(d).DATABASE_COLUMN||'_UOM ';

              l_rtcq_alias_b_cols_list := l_rtcq_alias_b_cols_list||',RTCQ.'||
                                          l_attr_metadata_table_sr(d).DATABASE_COLUMN||'_UOM';
              l_rtcq_alias_b_cols_list_1 := l_rtcq_alias_b_cols_list_1||', '||G_NULL_TOKEN_STR_1||
                                          l_attr_metadata_table_sr(d).DATABASE_COLUMN||'_UOM';

              l_db_col_tbl_collect_b_attrs := l_db_col_tbl_collect_b_attrs||
                                              ',attr_'||l_rn_index_for_ag||'_uom_tbl';
              -------------------------------------------------------
              -- If it's a UOM Attr, we need to add the UOM column --
              -- and its base value into our no-alias lists, too   --
              -------------------------------------------------------
              IF (INSTR(l_attr_metadata_table_sr(d).DATABASE_COLUMN, 'N_EXT_ATTR') = 1) THEN
                l_uom_column := 'UOM_' || SUBSTR(l_attr_metadata_table_sr(d).DATABASE_COLUMN, 3);
              ELSE
                l_uom_column := 'UOM_' || l_attr_metadata_table_sr(d).DATABASE_COLUMN;
              END IF;

              l_no_alias_b_cols_list := l_no_alias_b_cols_list||
                                        ','||l_uom_column;
              l_no_alias_b_values_list := l_no_alias_b_values_list||
                                          ', NVL('||l_attr_metadata_table_sr(d).DATABASE_COLUMN||'_UOM ,'''||
                                          l_attr_metadata_table_sr(d).UNIT_OF_MEASURE_BASE||
                                          ''' )';
            END IF;
          END IF;
        END IF;
      END LOOP;

      l_row_to_column_query :=
        l_row_to_column_query_base||
        l_row_to_column_query_ag_part||
        ' FROM (SELECT DECODE(ATTR_INT_NAME'||l_row_to_column_attr_decode||
                             ') RN,TRANSACTION_TYPE,ATTR_GROUP_ID'||
        l_no_alias_cc_pk_dl_list||
        ',ATTR_INT_NAME,NVL(ATTR_VALUE_NUM,'||
                            EGO_USER_ATTRS_BULK_PVT.G_NULL_TOKEN_NUM||
                            ')ATTR_VALUE_NUM, NVL(ATTR_VALUE_UOM,'||
                            EGO_USER_ATTRS_BULK_PVT.G_NULL_TOKEN_STR||
                            ') ATTR_VALUE_UOM, NVL(ATTR_VALUE_STR,'||
                            EGO_USER_ATTRS_BULK_PVT.G_NULL_TOKEN_STR||
                            ')ATTR_VALUE_STR,NVL(ATTR_VALUE_DATE,'||
                            EGO_USER_ATTRS_BULK_PVT.G_NULL_TOKEN_DATE||
                            ')ATTR_VALUE_DATE,ROW_IDENTIFIER FROM '||
        p_interface_table_name||
        ' WHERE DATA_SET_ID = :data_set_id AND PROCESS_STATUS = '||G_PS_IN_PROCESS||
        ' AND ATTR_GROUP_INT_NAME = :attr_group_name AND ATTR_GROUP_TYPE = '''||p_attr_group_type||''') GROUP BY ROW_IDENTIFIER';

      --------------------------------------------------
      -- If p_validate = TRUE do the final validation --
      --------------------------------------------------

      -- The validation for erroring dupicate rows has been moved to the DML phase R12C
      -- onwards, this was needed by the items team.

      IF (p_do_dml) THEN --*p_validate-IF-4*

        code_debug('          Before validation for more than one logical AG rows int the interface table pointing to same row in the EXT table ' ,2);
        -----------------------------------------------------------------
        -- The final validation step is to error out all logical Attr  --
        -- Group rows in the data set that map to the same destination --
        -- table row; we have to do this per AG because of UKs, and we --
        -- do it here because we have the RTCQ and its where clause(s) --
        -----------------------------------------------------------------

        IF (l_ag_id_col_exists) THEN
          code_debug(          'UPDATE '||p_interface_table_name||
            ' SET PROCESS_STATUS = PROCESS_STATUS + '||G_PS_IDENTICAL_ROWS||
          ' WHERE DATA_SET_ID = :data_set_id
              AND PROCESS_STATUS <> '||G_PS_GENERIC_ERROR||'
              AND PROCESS_STATUS <> '||G_PS_SUCCESS||'
              AND BITAND(PROCESS_STATUS, '||G_PS_NO_PRIVILEGES||') = 0
              AND ROW_IDENTIFIER IN (SELECT DISTINCT RTCQ.ROW_IDENTIFIER
                                       FROM ('||l_row_to_column_query||') RTCQ,
                                            ('||l_row_to_column_query||') EXT
                                      WHERE RTCQ.ATTR_GROUP_ID = EXT.ATTR_GROUP_ID
                                            AND RTCQ.ROW_IDENTIFIER <> EXT.ROW_IDENTIFIER'||
                                            l_rtcq_to_ext_where_base||
                                            l_rtcq_to_ext_whr_uks_idnt_chk||')'

          );
          EXECUTE IMMEDIATE
          'UPDATE '||p_interface_table_name||
            ' SET PROCESS_STATUS = PROCESS_STATUS + '||G_PS_IDENTICAL_ROWS||
          ' WHERE DATA_SET_ID = :data_set_id
              AND PROCESS_STATUS <> '||G_PS_GENERIC_ERROR||'
              AND PROCESS_STATUS <> '||G_PS_SUCCESS||'
              AND BITAND(PROCESS_STATUS, '||G_PS_NO_PRIVILEGES||') = 0
              AND ROW_IDENTIFIER IN (SELECT DISTINCT RTCQ.ROW_IDENTIFIER
                                       FROM ('||l_row_to_column_query||') RTCQ,
                                            ('||l_row_to_column_query||') EXT
                                      WHERE RTCQ.ATTR_GROUP_ID = EXT.ATTR_GROUP_ID
                                            AND RTCQ.ROW_IDENTIFIER <> EXT.ROW_IDENTIFIER'||
                                            l_rtcq_to_ext_where_base||
                                            l_rtcq_to_ext_whr_uks_idnt_chk||')'
          USING p_data_set_id,
                p_data_set_id,
                l_attr_group_metadata_obj.ATTR_GROUP_NAME,
                p_data_set_id,
                l_attr_group_metadata_obj.ATTR_GROUP_NAME,
                l_attr_group_metadata_obj.ATTR_GROUP_ID;
        ELSE

          EXECUTE IMMEDIATE
          'UPDATE '||p_interface_table_name||
            ' SET PROCESS_STATUS = PROCESS_STATUS + '||G_PS_IDENTICAL_ROWS||
          ' WHERE DATA_SET_ID = :data_set_id
              AND PROCESS_STATUS <> '||G_PS_GENERIC_ERROR||'
              AND PROCESS_STATUS <> '||G_PS_SUCCESS||'
              AND BITAND(PROCESS_STATUS, '||G_PS_NO_PRIVILEGES||') = 0
              AND ROW_IDENTIFIER IN (SELECT DISTINCT RTCQ.ROW_IDENTIFIER
                                       FROM ('||l_row_to_column_query||') RTCQ,
                                            ('||l_row_to_column_query||') EXT
                                      WHERE RTCQ.ATTR_GROUP_ID = EXT.ATTR_GROUP_ID
                                            AND RTCQ.ROW_IDENTIFIER <> EXT.ROW_IDENTIFIER'||
                                            l_rtcq_to_ext_where_base||
                                            l_rtcq_to_ext_whr_uks_idnt_chk||')'
          USING p_data_set_id,
                p_data_set_id,
                l_attr_group_metadata_obj.ATTR_GROUP_NAME,
                p_data_set_id,
                l_attr_group_metadata_obj.ATTR_GROUP_NAME;

        END IF;

        code_debug('          After validation for more than one logical AG rows int the interface table pointing to same row in the EXT table ' ,2);

      END IF; --*p_validate-IF-4*

      IF(p_validate OR p_do_req_def_valiadtion) THEN --*p_validate-IF-4.5* BugFix:5355722
        -------------------------------------------------------------------------
        -- Update other attributes i ag if atleast one of attribute has failed
        -------------------------------------------------------------------------
     --considering the G_PS_BAD_ATTR_OR_AG_METADATA is the starting point for the intermittent errors.

      /* Fix for bug#9678667 - Start */
      /*
        EXECUTE IMMEDIATE
            'UPDATE '||p_interface_table_name||' UAI1' ||
                ' SET UAI1.PROCESS_STATUS = UAI1.PROCESS_STATUS + '||G_PS_OTHER_ATTRS_INVALID||
                ' WHERE UAI1.DATA_SET_ID = :data_set_id '||--p_data_set_id||
                ' AND BITAND(PROCESS_STATUS,'||G_PS_OTHER_ATTRS_INVALID||') = 0'||
                ' AND UAI1.ROW_IDENTIFIER  IN'||
                '     (SELECT DISTINCT UAI2.ROW_IDENTIFIER'||
                '        FROM '||p_interface_table_name||' UAI2'||
                '        WHERE UAI2.DATA_SET_ID = :data_set_id '||--p_data_set_id||
                '         AND UAI2.PROCESS_STATUS >= '||G_PS_BAD_ATTR_OR_AG_METADATA ||
                '         AND UAI2.ATTR_GROUP_INT_NAME = UAI1.ATTR_GROUP_INT_NAME)'
      USING p_data_set_id, p_data_set_id; */  /*Fix for bug#9678667. Literal to bind*/

        EXECUTE IMMEDIATE
              'UPDATE '||p_interface_table_name||' UAI1' ||
                  ' SET UAI1.PROCESS_STATUS = UAI1.PROCESS_STATUS + '||G_PS_OTHER_ATTRS_INVALID||
                  ' WHERE UAI1.DATA_SET_ID = :data_set_id '||
                  ' AND BITAND(PROCESS_STATUS,'||G_PS_OTHER_ATTRS_INVALID||') = 0'||
                  ' AND (UAI1.ROW_IDENTIFIER, UAI1.ATTR_GROUP_INT_NAME)  IN '||
                '       (SELECT /*+ UNNEST CARDINALITY(UAI2,10) INDEX(UAI2,EGO_ITM_USR_ATTR_INTRFC_N3) */ '|| /* Bug 9678667 */
                  '           UAI2.ROW_IDENTIFIER, UAI2.ATTR_GROUP_INT_NAME '||
                  '        FROM '||p_interface_table_name||' UAI2'||
                  '        WHERE UAI2.DATA_SET_ID = :data_set_id '||
                  '           AND UAI2.PROCESS_STATUS >= '||G_PS_BAD_ATTR_OR_AG_METADATA ||
                  '      )'
        USING p_data_set_id, p_data_set_id;
        /* Fix for bug#9678667 - End */

      END IF; --*p_validate-IF-4.5*

        -------------------------------------------------------
        -- Before we do the DML for developer defined attr
        -- we gotta make sure that there exists a row in the
        -- production table for the processed attributes.
        -------------------------------------------------------

        IF(NOT l_ag_id_col_exists AND p_do_dml ) THEN

          l_dynamic_Sql := ' DECLARE ext_id_tbl EGO_USER_ATTRS_BULK_PVT.EGO_USER_ATTRS_BULK_NUM_TBL; '||l_pk_blk_tbl_declare||
                           '         created_by_tbl EGO_USER_ATTRS_BULK_PVT.EGO_USER_ATTRS_BULK_NUM_TBL; '||
                           ' creation_date_tbl EGO_USER_ATTRS_BULK_PVT.EGO_USER_ATTRS_BULK_DATE_TBL; lu_by_tbl EGO_USER_ATTRS_BULK_PVT.EGO_USER_ATTRS_BULK_NUM_TBL; '||
                           ' lu_date_tbl EGO_USER_ATTRS_BULK_PVT.EGO_USER_ATTRS_BULK_DATE_TBL; '||l_dl_blk_tbl_declare||l_class_blk_tbl_declare||
                           '
                              '||
                           ' BEGIN '||
                           ' SELECT EGO_EXTFWK_S.NEXTVAL, '||l_concat_pk_cols_sel||
                           '        CREATED_BY,CREATION_DATE,LAST_UPDATED_BY,LAST_UPDATE_DATE '||
                           ' BULK COLLECT INTO ext_id_tbl, '||l_pk_blk_tbl_list||l_dl_blk_tbl_list||','||l_class_blk_tbl_list||
                           ', created_by_tbl, creation_date_tbl, lu_by_tbl, lu_date_tbl '||
                           ' FROM ( SELECT '|| l_concat_pk_cols_sel ||
                           '          MAX(CREATED_BY) CREATED_BY, MAX(CREATION_DATE) CREATION_DATE, MAX(LAST_UPDATED_BY) LAST_UPDATED_BY, MAX(LAST_UPDATE_DATE) LAST_UPDATE_DATE '||
                           '                 FROM '||p_interface_table_name||' UAI2           '||
                           '                WHERE NOT EXISTS (                                '||
                           '                          SELECT NULL                             '||
                           '                            FROM '||l_ext_b_table_name||' B       '||
                           '                           WHERE 1=1 '||l_concat_pk_cols_UAI2|| ' ) '||
                           '                  AND DATA_SET_ID = :data_set_id                  '||
                           '                  AND ATTR_GROUP_TYPE = :attr_group_type          '||
                           '                  AND PROCESS_STATUS = '||G_PS_IN_PROCESS||'      '||
                           '                  AND BITAND(PROCESS_STATUS, '||G_PS_NO_PRIVILEGES||') = 0 '||
                           '             GROUP BY ' || l_concat_pk_cols_sel ||' NULL );       '||
                           ' IF (ext_id_tbl.COUNT > 0) THEN                                   '||
                           '   FORALL i IN ext_id_tbl.FIRST .. ext_id_tbl.LAST                '||
                           '   INSERT INTO '||l_ext_b_table_name||
                           '              ( EXTENSION_ID, '||l_concat_pk_cols_sel||
                           '                CREATED_BY,CREATION_DATE,LAST_UPDATED_BY,LAST_UPDATE_DATE) '||
                           '              VALUES ( ext_id_tbl(i) , '||l_pk_blk_tbl_list_2||l_dl_blk_tbl_list_2||','||l_class_blk_tbl_list_2||
                           '                      ,created_by_tbl(i), creation_date_tbl(i), '||
                           '                       lu_by_tbl(i) , lu_date_tbl(i) ); '||
                           '   FORALL i IN ext_id_tbl.FIRST .. ext_id_tbl.LAST '||
                           '   INSERT INTO '||l_ext_tl_table_name||
                           '              ( EXTENSION_ID, '||l_concat_pk_cols_sel||
                           '                CREATED_BY,CREATION_DATE,LAST_UPDATED_BY,LAST_UPDATE_DATE, '||
                           '                SOURCE_LANG,LANGUAGE ) '||
                           '              SELECT  ext_id_tbl(i) , '||l_pk_blk_tbl_list_2||l_dl_blk_tbl_list_2||','||l_class_blk_tbl_list_2||
                           '                     ,created_by_tbl(i), creation_date_tbl(i), '||
                           '                      lu_by_tbl(i) , lu_date_tbl(i),USERENV(''LANG''),LANGUAGE_CODE '||
                           '                FROM  FND_LANGUAGES WHERE INSTALLED_FLAG IN (''I'', ''B'')'||
                           ' ; '||
                           ' END IF;'||
                           ' END;';

        code_debug('          DML for inserting dummy rows for dev defined attrs:'||l_dynamic_Sql,3);
         EXECUTE IMMEDIATE l_dynamic_sql
         USING p_data_Set_id, p_attr_group_type;
        code_debug('          After DML for inserting dummy rows for dev defined attrs.'||l_dynamic_Sql,2);
         EXECUTE IMMEDIATE
          'UPDATE '||p_interface_table_name||' UAI1
              SET TRANSACTION_TYPE  =  '''||EGO_USER_ATTRS_DATA_PVT.G_UPDATE_MODE||'''
            WHERE UAI1.DATA_SET_ID = :data_set_id
              AND UAI1.PROCESS_STATUS = '||G_PS_IN_PROCESS||'
              AND ATTR_GROUP_INT_NAME = :attr_grp_int_name
              AND ATTR_GROUP_TYPE = :attr_group_type  '
         USING  p_data_set_id, l_attr_group_metadata_obj.ATTR_GROUP_NAME, p_attr_group_type ;

      END IF;

/*
DYLAN: TO DO: This will mark every interface table row in the logical
AG rows as an error; our error reporting will have to take care of that.
*/

    IF (l_do_dml_for_this_ag AND p_do_dml) THEN -- *p_do_dml-IF-2*

      code_debug('          Before Delete DML ' ,2);

                            --========--
                            -- DELETE --
                            --========--
      ---------------------------------------------------------------
      -- For deletion we fetch the extension IDs we'll be deleting --
      -- and then delete from both tables using a FORALL statement --
      ---------------------------------------------------------------
      l_dynamic_sql :=
      'DECLARE '||l_db_col_tbl_declare_ext_id||
      ' BEGIN SELECT EXT.EXTENSION_ID'||
      ' BULK COLLECT INTO '||l_db_col_tbl_collect_ext_id||
      ' FROM '||
      l_ext_vl_name||
      ' EXT, ('||l_row_to_column_query||') RTCQ WHERE 1=1'||
      l_rtcq_to_ext_where_base||
      l_rtcq_to_ext_where_uks||
      ' AND RTCQ.TRANSACTION_TYPE='''||
      EGO_USER_ATTRS_DATA_PVT.G_DELETE_MODE||
      '''; IF (ext_id_tbl.COUNT > 0) THEN
             FORALL i IN ext_id_tbl.FIRST .. ext_id_tbl.LAST
               DELETE FROM '||l_ext_b_table_name||' EXT
                WHERE '||l_db_col_tbl_where_ext_id||
      '; END IF;';

      IF (l_ext_tl_table_name IS NOT NULL) THEN
        l_dynamic_sql := l_dynamic_sql||
        'IF (ext_id_tbl.COUNT > 0) THEN
           FORALL i IN ext_id_tbl.FIRST .. ext_id_tbl.LAST
             DELETE FROM '||l_ext_tl_table_name||' EXT
              WHERE '||l_db_col_tbl_where_ext_id||
        '; END IF;';
      END IF;

      l_dynamic_sql := l_dynamic_sql||'END;';

      code_debug('          Delete DML for AG '||l_attr_group_metadata_obj.ATTR_GROUP_NAME ,3);
      code_debug('          :--:'||l_dynamic_sql ,3);

      IF(l_ag_id_col_exists) THEN
        EXECUTE IMMEDIATE l_dynamic_sql
        USING p_data_set_id,
              l_attr_group_metadata_obj.ATTR_GROUP_NAME,
              l_attr_group_metadata_obj.ATTR_GROUP_ID;
      ELSE
        EXECUTE IMMEDIATE l_dynamic_sql
        USING p_data_set_id,
              l_attr_group_metadata_obj.ATTR_GROUP_NAME;
      END IF;

      code_debug('          After Delete DML ' ,2);

                            --========--
                            -- UPDATE --
                            --========--

/*
DYLAN: TO DO:
done    1159: Shalu's bug with multiple MR AG rows with same UKs in SYNC mode
done    1159: Look at UPDATE behavior for LANGs
done    1159: Set explicit NULLs
done?    1159: need to ensure that MD code sorts Attrs by sequence
11510: Also look into only firing DMLs for TTs we have in DS
11510: we need to use IF (l_attr_group_metadata_obj.ATTR_GROUP_ID_FLAG ='Y') THEN
11510+: deal with no-CC case (throughout the code)
11510+: get rid of PK, DL data type fetches
*/

      code_debug('          Before Update DML ' ,2);
            /**bug 14145164 start **/
    IF (LENGTH(l_db_col_tbl_set_b_attrs) > 0 OR
          LENGTH(l_db_col_tbl_set_tl_attrs) > 0) THEN
      BEGIN
        cur_l_dynamic_sql_clob := dbms_sql.open_cursor;
        l_dynamic_sql_clob :=
        'DECLARE '||l_db_col_tbl_declare_ext_id||' lang_tbl EGO_USER_ATTRS_BULK_PVT.EGO_USER_ATTRS_BULK_STR_TBL;'||
                    l_db_col_tbl_declare_attrs||
        ' BEGIN SELECT LANGUAGE, EXTENSION_ID'||
        l_final_b_col_list                    ||
        l_final_tl_col_list                   ||
        ' BULK COLLECT INTO lang_tbl,'||l_db_col_tbl_collect_ext_id||
                               l_db_col_tbl_collect_b_attrs||
                               l_db_col_tbl_collect_tl_attrs||
        ' FROM '||
        '(SELECT USERENV(''LANG'') LANGUAGE, EXT.EXTENSION_ID'||
                       l_rtcq_alias_b_cols_list||
                       l_rtcq_alias_tl_cols_list||
        ' FROM '||
        l_ext_vl_name||
        ' EXT, ('||l_row_to_column_query||') RTCQ WHERE 1=1'||
        l_rtcq_to_ext_where_base||
        l_rtcq_to_ext_where_uks||
        ' AND RTCQ.TRANSACTION_TYPE='''||
        EGO_USER_ATTRS_DATA_PVT.G_UPDATE_MODE||''' )'||
        ' UNION '||
        '(SELECT INTF_TL.LANGUAGE LANGUAGE,          '||  --Added the following UNIONED Query for R12C.. this wud bring bak
        '        INTFRTCQ.EXTENSION_ID EXTENSION_ID  '||  --the results from the intf_tl table as well for updating records
        l_rtcq_alias_b_cols_list_1         ||             --in other languages. We assume that the Row_identifier in the itnf table
        l_rtcq_alias_tl_cols_list_1        ||             --is unique for ag rows and we can join it with unique_identifier in tl tbl
        ' FROM EGO_INTERFACE_TL INTF_TL,  '||             --to get the correct joins.
        '      (  SELECT USERENV(''LANG'') LANGUAGE, RTCQ.ROW_IDENTIFIER, EXT.EXTENSION_ID'||
                                l_rtcq_alias_b_cols_list||
                                l_rtcq_alias_tl_cols_list||
                 ' FROM '||
                 l_ext_vl_name||
                 ' EXT, ('||l_row_to_column_query||') RTCQ WHERE 1=1'||
                 l_rtcq_to_ext_where_base||
                 l_rtcq_to_ext_where_uks||
                 ' AND RTCQ.TRANSACTION_TYPE='''||
                 EGO_USER_ATTRS_DATA_PVT.G_UPDATE_MODE||''''||
        '      ) INTFRTCQ                 '||
        'WHERE INTF_TL.SET_PROCESS_ID = :data_set_id '||
        '  AND UPPER(INTF_TL.TABLE_NAME) = '''||UPPER(p_interface_table_name)||''' '||
        '  AND INTF_TL.UNIQUE_ID =  INTFRTCQ.ROW_IDENTIFIER ) ;';

        code_debug('Before updating B table Length of l_dynamic_sql_clob :'||dbms_lob.getlength(l_dynamic_sql_clob),3);
        ------------------------------------------------
        -- If we need to update the B table, we do so --
        ------------------------------------------------
        IF (LENGTH(l_db_col_tbl_set_b_attrs) > 1) THEN
          l_dynamic_sql_clob := l_dynamic_sql_clob||                -- Bug 13923293
          'IF (ext_id_tbl.COUNT > 0) THEN
             FORALL i IN ext_id_tbl.FIRST .. ext_id_tbl.LAST
               UPDATE '||l_ext_b_table_name||' EXT
                  SET '||SUBSTR(l_db_col_tbl_set_b_attrs, 2)||
                      ',LAST_UPDATED_BY=:current_user_id,
                       LAST_UPDATE_DATE=:current_date,
                       LAST_UPDATE_LOGIN=:current_login_id,
                       REQUEST_ID = :request_id
                WHERE '||l_db_col_tbl_where_ext_id||';
           END IF;';
        END IF;
        code_debug('Before updating TL table Length of l_dynamic_sql_clob: '||dbms_lob.getlength(l_dynamic_sql_clob),3);
        -------------------------------------------------
        -- If we need to update the TL table, we do so --
        -------------------------------------------------
        IF (l_ext_tl_table_name IS NOT NULL AND
            LENGTH(l_db_col_tbl_set_tl_attrs) > 1) THEN

          l_dynamic_sql_clob := l_dynamic_sql_clob||            -- Bug 13923293
          'IF (ext_id_tbl.COUNT > 0) THEN
             FORALL i IN ext_id_tbl.FIRST .. ext_id_tbl.LAST
               UPDATE '||l_ext_tl_table_name||' EXT
                  SET '||SUBSTR(l_db_col_tbl_set_tl_attrs, 2)||
                      ',LAST_UPDATED_BY=:current_user_id,
                       LAST_UPDATE_DATE=:current_date,
                       LAST_UPDATE_LOGIN=:current_login_id,
                       SOURCE_LANG=lang_tbl(i)
                WHERE '||l_db_col_tbl_where_ext_id||
                ' AND (LANGUAGE=lang_tbl(i) OR SOURCE_LANG=lang_tbl(i));
           END IF;';
          --Added for bug 4473128(gnanda): In case there are no B table columns to be updated but we have some TL
          --                               table columns being updated the request id should still be updated in the
          --                               B table so that events can be raised properly, if required.
          IF (LENGTH(l_db_col_tbl_set_b_attrs) <= 1 OR l_db_col_tbl_set_b_attrs IS NULL) THEN
            l_dynamic_sql_clob := l_dynamic_sql_clob||          -- Bug 13923293
            ' IF (ext_id_tbl.COUNT > 0) THEN
              FORALL i IN ext_id_tbl.FIRST .. ext_id_tbl.LAST
                UPDATE '||l_ext_b_table_name||' EXT '||
                   ' SET LAST_UPDATED_BY=:current_user_id,
                         LAST_UPDATE_DATE=:current_date,
                         LAST_UPDATE_LOGIN=:current_login_id,
                         REQUEST_ID = :request_id
                   WHERE '||l_db_col_tbl_where_ext_id||';
               END IF; ';
          END IF;

        END IF;

        l_dynamic_sql_clob := l_dynamic_sql_clob||'END;';
        -----------------------------------------------
        -- Even though there are either 7 or 11 bind --
        -- variables in this statement, we only need --
        -- to bind the 5 distinct variables, because --
        -- dynamic PL/SQL blocks bind by name        --
        -----------------------------------------------

        code_debug('          Update DML for AG '||l_attr_group_metadata_obj.ATTR_GROUP_NAME ,3);
        code_debug('          :--: final length : '||dbms_lob.getlength(l_dynamic_sql_clob) ,3);

        DBMS_SQL.PARSE(cur_l_dynamic_sql_clob, l_dynamic_sql_clob,
                   DBMS_SQL.NATIVE);

        IF(l_ag_id_col_exists) THEN
          DBMS_SQL.BIND_VARIABLE(cur_l_dynamic_sql_clob, ':data_set_id', p_data_set_id);
          DBMS_SQL.BIND_VARIABLE(cur_l_dynamic_sql_clob, ':attr_group_name', l_attr_group_metadata_obj.ATTR_GROUP_NAME);
          DBMS_SQL.BIND_VARIABLE(cur_l_dynamic_sql_clob, ':curr_attr_group_id', l_attr_group_metadata_obj.ATTR_GROUP_ID);
          DBMS_SQL.BIND_VARIABLE(cur_l_dynamic_sql_clob, ':current_user_id', G_CURRENT_USER_ID);
          DBMS_SQL.BIND_VARIABLE(cur_l_dynamic_sql_clob, ':current_date', SYSDATE);
          DBMS_SQL.BIND_VARIABLE(cur_l_dynamic_sql_clob, ':current_login_id', G_CURRENT_LOGIN_ID);
          DBMS_SQL.BIND_VARIABLE(cur_l_dynamic_sql_clob, ':request_id', G_REQUEST_ID);
          l_dummy_ret_val := DBMS_SQL.EXECUTE(cur_l_dynamic_sql_clob);

        ELSE
          DBMS_SQL.BIND_VARIABLE(cur_l_dynamic_sql_clob, ':data_set_id', p_data_set_id);
          DBMS_SQL.BIND_VARIABLE(cur_l_dynamic_sql_clob, ':curr_attr_group_id', l_attr_group_metadata_obj.ATTR_GROUP_ID);
          DBMS_SQL.BIND_VARIABLE(cur_l_dynamic_sql_clob, ':current_user_id', G_CURRENT_USER_ID);
          DBMS_SQL.BIND_VARIABLE(cur_l_dynamic_sql_clob, ':current_date', SYSDATE);
          DBMS_SQL.BIND_VARIABLE(cur_l_dynamic_sql_clob, ':current_login_id', G_CURRENT_LOGIN_ID);
          DBMS_SQL.BIND_VARIABLE(cur_l_dynamic_sql_clob, ':request_id', G_REQUEST_ID);
          l_dummy_ret_val :=  DBMS_SQL.EXECUTE(cur_l_dynamic_sql_clob);

        END IF;

        code_debug('          Don with executing the update DML ' ,2);
        DBMS_SQL.CLOSE_CURSOR(cur_l_dynamic_sql_clob);
      EXCEPTION
      WHEN OTHERS THEN
      DBMS_SQL.CLOSE_CURSOR(cur_l_dynamic_sql_clob);
      RAISE;
      END;

    END IF;
    /**bug 14145164 end **/

      /** start comment for bug 14145164

      IF (LENGTH(l_db_col_tbl_set_b_attrs) > 0 OR
          LENGTH(l_db_col_tbl_set_tl_attrs) > 0) THEN
        l_dynamic_sql :=
        'DECLARE '||l_db_col_tbl_declare_ext_id||' lang_tbl EGO_USER_ATTRS_BULK_PVT.EGO_USER_ATTRS_BULK_STR_TBL;'||
                    l_db_col_tbl_declare_attrs||
        ' BEGIN SELECT LANGUAGE, EXTENSION_ID'||
        l_final_b_col_list                    ||
        l_final_tl_col_list                   ||
        ' BULK COLLECT INTO lang_tbl,'||l_db_col_tbl_collect_ext_id||
                               l_db_col_tbl_collect_b_attrs||
                               l_db_col_tbl_collect_tl_attrs||
        ' FROM '||
        '(SELECT USERENV(''LANG'') LANGUAGE, EXT.EXTENSION_ID'||
                       l_rtcq_alias_b_cols_list||
                       l_rtcq_alias_tl_cols_list||
        ' FROM '||
        l_ext_vl_name||
        ' EXT, ('||l_row_to_column_query||') RTCQ WHERE 1=1'||
        l_rtcq_to_ext_where_base||
        l_rtcq_to_ext_where_uks||
        ' AND RTCQ.TRANSACTION_TYPE='''||
        EGO_USER_ATTRS_DATA_PVT.G_UPDATE_MODE||''' )'||
        ' UNION '||
        '(SELECT INTF_TL.LANGUAGE LANGUAGE,          '||  --Added the following UNIONED Query for R12C.. this wud bring bak
        '        INTFRTCQ.EXTENSION_ID EXTENSION_ID  '||  --the results from the intf_tl table as well for updating records
        l_rtcq_alias_b_cols_list_1         ||             --in other languages. We assume that the Row_identifier in the itnf table
        l_rtcq_alias_tl_cols_list_1        ||             --is unique for ag rows and we can join it with unique_identifier in tl tbl
        ' FROM EGO_INTERFACE_TL INTF_TL,  '||             --to get the correct joins.
        '      (  SELECT USERENV(''LANG'') LANGUAGE, RTCQ.ROW_IDENTIFIER, EXT.EXTENSION_ID'||
                                l_rtcq_alias_b_cols_list||
                                l_rtcq_alias_tl_cols_list||
                 ' FROM '||
                 l_ext_vl_name||
                 ' EXT, ('||l_row_to_column_query||') RTCQ WHERE 1=1'||
                 l_rtcq_to_ext_where_base||
                 l_rtcq_to_ext_where_uks||
                 ' AND RTCQ.TRANSACTION_TYPE='''||
                 EGO_USER_ATTRS_DATA_PVT.G_UPDATE_MODE||''''||
        '      ) INTFRTCQ                 '||
        'WHERE INTF_TL.SET_PROCESS_ID = :data_set_id '||
        '  AND UPPER(INTF_TL.TABLE_NAME) = '''||UPPER(p_interface_table_name)||''' '||
        '  AND INTF_TL.UNIQUE_ID =  INTFRTCQ.ROW_IDENTIFIER ) ;';

        l_dynamic_sql_2 := '';  --clear l_dynamic_sql_2 since we are in a loop, for bug 14335411
        ------------------------------------------------
        -- If we need to update the B table, we do so --
        ------------------------------------------------
        IF (LENGTH(l_db_col_tbl_set_b_attrs) > 1) THEN
          l_dynamic_sql_2 := l_dynamic_sql_2||                -- Bug 13923293
          'IF (ext_id_tbl.COUNT > 0) THEN
             FORALL i IN ext_id_tbl.FIRST .. ext_id_tbl.LAST
               UPDATE '||l_ext_b_table_name||' EXT
                  SET '||SUBSTR(l_db_col_tbl_set_b_attrs, 2)||
                      ',LAST_UPDATED_BY=:current_user_id,
                       LAST_UPDATE_DATE=:current_date,
                       LAST_UPDATE_LOGIN=:current_login_id,
                       REQUEST_ID = :request_id
                WHERE '||l_db_col_tbl_where_ext_id||';
           END IF;';
        END IF;
        -------------------------------------------------
        -- If we need to update the TL table, we do so --
        -------------------------------------------------
        IF (l_ext_tl_table_name IS NOT NULL AND
            LENGTH(l_db_col_tbl_set_tl_attrs) > 1) THEN

          l_dynamic_sql_2 := l_dynamic_sql_2||            -- Bug 13923293
          'IF (ext_id_tbl.COUNT > 0) THEN
             FORALL i IN ext_id_tbl.FIRST .. ext_id_tbl.LAST
               UPDATE '||l_ext_tl_table_name||' EXT
                  SET '||SUBSTR(l_db_col_tbl_set_tl_attrs, 2)||
                      ',LAST_UPDATED_BY=:current_user_id,
                       LAST_UPDATE_DATE=:current_date,
                       LAST_UPDATE_LOGIN=:current_login_id,
                       SOURCE_LANG=lang_tbl(i)
                WHERE '||l_db_col_tbl_where_ext_id||
                ' AND (LANGUAGE=lang_tbl(i) OR SOURCE_LANG=lang_tbl(i));
           END IF;';

          --Added for bug 4473128(gnanda): In case there are no B table columns to be updated but we have some TL
          --                               table columns being updated the request id should still be updated in the
          --                               B table so that events can be raised properly, if required.
          IF (LENGTH(l_db_col_tbl_set_b_attrs) <= 1 OR l_db_col_tbl_set_b_attrs IS NULL) THEN
            l_dynamic_sql_2 := l_dynamic_sql_2||          -- Bug 13923293
            ' IF (ext_id_tbl.COUNT > 0) THEN
              FORALL i IN ext_id_tbl.FIRST .. ext_id_tbl.LAST
                UPDATE '||l_ext_b_table_name||' EXT '||
                   ' SET LAST_UPDATED_BY=:current_user_id,
                         LAST_UPDATE_DATE=:current_date,
                         LAST_UPDATE_LOGIN=:current_login_id,
                         REQUEST_ID = :request_id
                   WHERE '||l_db_col_tbl_where_ext_id||';
               END IF; ';
          END IF;

        END IF;

        l_dynamic_sql_2 := l_dynamic_sql_2||'END;';
        -----------------------------------------------
        -- Even though there are either 7 or 11 bind --
        -- variables in this statement, we only need --
        -- to bind the 5 distinct variables, because --
        -- dynamic PL/SQL blocks bind by name        --
        -----------------------------------------------

        code_debug('          Update DML for AG '||l_attr_group_metadata_obj.ATTR_GROUP_NAME ,3);
        code_debug('          :--:'||l_dynamic_sql||l_dynamic_sql_2 ,3);


  IF(l_ag_id_col_exists) THEN
          EXECUTE IMMEDIATE l_dynamic_sql||l_dynamic_sql_2  -- Bug 13923293
          USING p_data_set_id,
                l_attr_group_metadata_obj.ATTR_GROUP_NAME,
                l_attr_group_metadata_obj.ATTR_GROUP_ID,
                G_CURRENT_USER_ID,
                SYSDATE,
                G_CURRENT_LOGIN_ID,
                G_REQUEST_ID;
        ELSE

           EXECUTE IMMEDIATE l_dynamic_sql||l_dynamic_sql_2  -- Bug 13923293
           USING p_data_set_id,
                 l_attr_group_metadata_obj.ATTR_GROUP_NAME,
                 G_CURRENT_USER_ID,
                 SYSDATE,
                 G_CURRENT_LOGIN_ID,
                 G_REQUEST_ID;
        END IF;

        code_debug('          Don with executing the update DML ' ,2);

      END IF;
      /** end comment for bug 14145164 **/


                            --========--
                            -- INSERT --
                            --========--

      --------------------------------------------
      -- First we insert rows into the B table  --
      -- (even if there are no non-trans Attrs) --
      --------------------------------------------
/*
GNANDA:
Note:Since we had to support TL UK's and we had to insert the row_identifier*-2
     temporarily in the REQUEST_ID column so that while inserting rows in the
     TL table we can identify the exact extension_id's inserted for the rows in
     the B table. We would set the request_id back to the correct value after
     we are done with the TL table inserions.
     Without this it was failing if the AG had TL UK and more than
     one rows were being inserted for the MR AG.
*/

      -- Bug 10097738 : Start
      IF (l_attr_group_metadata_obj.MULTI_ROW_CODE = 'Y') THEN
        -- The below function returns 'T' or 'F'
        l_column_exists:=EGO_USER_ATTRS_DATA_PVT.HAS_COLUMN_IN_TABLE_VIEW(l_ext_b_table_name,'UNIQUE_VALUE');
      END IF;

      IF (l_attr_group_metadata_obj.MULTI_ROW_CODE = 'Y' AND FND_API.TO_BOOLEAN(l_column_exists)) THEN
        l_unique_value_col := ', UNIQUE_VALUE ';
        l_unique_value := ', EGO_EXTFWK_S.CURRVAL '; -- inserting the ext id value in UNIQUE_VALUE column for MR UDAs
      ELSE
        l_unique_value_col := '';
        l_unique_value := '';
      END IF;
      -- Bug 10097738 : End

      l_dynamic_sql :=
      'INSERT INTO '||l_ext_b_table_name||
      '(REQUEST_ID, EXTENSION_ID'||
       l_no_alias_cc_pk_dl_list||
       l_unique_value_col||' ';   /* Bug 10097738 */

      IF (l_ag_id_col_exists) THEN
        l_dynamic_sql := l_dynamic_sql|| ',ATTR_GROUP_ID, ';
      ELSE
        l_dynamic_sql := l_dynamic_sql|| ' , ';
      END IF;

      l_dynamic_sql := l_dynamic_sql|| ' CREATED_BY,
       CREATION_DATE,
       LAST_UPDATED_BY,
       LAST_UPDATE_DATE,
       LAST_UPDATE_LOGIN'||
       l_no_alias_b_cols_list||
      ') SELECT RTCQ.ROW_IDENTIFIER*-2 , EGO_EXTFWK_S.NEXTVAL'||
      l_rtcq_alias_cc_pk_dl_list||
      l_unique_value||' ';   /* Bug 10097738 */
      IF (l_ag_id_col_exists) THEN
        l_dynamic_sql := l_dynamic_sql||',:curr_attr_group_id, ';
      ELSE
        l_dynamic_sql := l_dynamic_sql||', ';
      END IF;
      l_dynamic_sql := l_dynamic_sql|| ' :current_user_id,
      :current_date,
      :current_user_id,
      :current_date,
      :current_login_id'||
      l_no_alias_b_values_list||
      ' FROM ('||l_row_to_column_query||') RTCQ
      WHERE RTCQ.TRANSACTION_TYPE = '''||
      EGO_USER_ATTRS_DATA_PVT.G_CREATE_MODE||'''';

      code_debug('          Before Inserting into B table ' ,2);
      code_debug('          B table Insert DML for AG '||l_attr_group_metadata_obj.ATTR_GROUP_NAME ,3);
      code_debug('          :--:'||l_dynamic_sql ,3);

      IF(l_ag_id_col_exists) THEN


        EXECUTE IMMEDIATE l_dynamic_sql
        USING l_attr_group_metadata_obj.ATTR_GROUP_ID,
              G_CURRENT_USER_ID,
              SYSDATE,
              G_CURRENT_USER_ID,
              SYSDATE,
              G_CURRENT_LOGIN_ID,
              p_data_set_id,
              l_attr_group_metadata_obj.ATTR_GROUP_NAME;
      ELSE


        EXECUTE IMMEDIATE l_dynamic_sql
        USING G_CURRENT_USER_ID,
              SYSDATE,
              G_CURRENT_USER_ID,
              SYSDATE,
              G_CURRENT_LOGIN_ID,
              p_data_set_id,
              l_attr_group_metadata_obj.ATTR_GROUP_NAME;
      END IF;

      code_debug('          After Inserting into B table ' ,2);

      -----------------------------------------------
      -- Next we insert rows into the TL table, if --
      -- there is one (again, we insert even if    --
      -- there are no trans Attrs, for VL joining) --
      -----------------------------------------------

      code_debug('          Before Inserting into TL table ' ,2);

      IF (l_ext_tl_table_name IS NOT NULL) THEN

        l_dynamic_sql :=
        'INSERT INTO '||l_ext_tl_table_name||
        '(EXTENSION_ID'||
        l_no_alias_cc_pk_dl_list||' ';

        IF (l_ag_id_col_exists) THEN
          l_dynamic_sql := l_dynamic_sql|| ',ATTR_GROUP_ID, ';
        ELSE
          l_dynamic_sql := l_dynamic_sql|| ' , ';
        END IF;

        l_dynamic_sql := l_dynamic_sql|| ' CREATED_BY,
         CREATION_DATE,
         LAST_UPDATED_BY,
         LAST_UPDATE_DATE,
         LAST_UPDATE_LOGIN,
         SOURCE_LANG,
         LANGUAGE'||
         l_no_alias_tl_cols_list||
        ') SELECT EXT.EXTENSION_ID'||
        l_rtcq_alias_cc_pk_dl_list||' ';

        IF (l_ag_id_col_exists) THEN
          l_dynamic_sql := l_dynamic_sql||',EXT.ATTR_GROUP_ID, ';
        ELSE
          l_dynamic_sql := l_dynamic_sql||', ';
        END IF;

        l_dynamic_sql := l_dynamic_sql||'EXT.CREATED_BY,
        EXT.CREATION_DATE,
        EXT.LAST_UPDATED_BY,
        EXT.LAST_UPDATE_DATE,
        EXT.LAST_UPDATE_LOGIN,
        USERENV(''LANG''),
        L.LANGUAGE_CODE'||
        l_no_alias_tl_cols_sel_list||
        ' FROM '||l_ext_b_table_name||
        ' EXT, FND_LANGUAGES L, ('||l_row_to_column_query||') RTCQ
        WHERE
        (RTCQ.ROW_IDENTIFIER*-2) = EXT.REQUEST_ID
        AND L.INSTALLED_FLAG IN (''I'', ''B'')'||
        l_rtcq_to_ext_where_base||
        l_rtcq_to_ext_where_uks||
        ' AND RTCQ.TRANSACTION_TYPE='''||
        EGO_USER_ATTRS_DATA_PVT.G_CREATE_MODE||'''';

        code_debug('          TL table Insert DML for AG '||l_attr_group_metadata_obj.ATTR_GROUP_NAME ,3);
        code_debug('          :--:'||l_dynamic_sql ,3);

        IF(l_ag_id_col_exists) THEN
          EXECUTE IMMEDIATE l_dynamic_sql
          USING p_data_set_id,
                l_attr_group_metadata_obj.ATTR_GROUP_NAME,
                l_attr_group_metadata_obj.ATTR_GROUP_ID;
        ELSE
          EXECUTE IMMEDIATE l_dynamic_sql
          USING p_data_set_id,
                l_attr_group_metadata_obj.ATTR_GROUP_NAME;
        END IF;

      code_debug('          After Inserting into TL table ' ,2);

/*
GNANDA:
Note:As mentioned above we had populated the request_id column with the row_identifier*-2
     in the INTF table we need to set it back to the correqt value now, since we are done
     with inserting rows in the TL table.
*/
      IF (l_ag_id_col_exists) THEN
       -- Bug 9851212 : Removed product specific table name.
        l_dynamic_sql := ' UPDATE '||l_ext_b_table_name||'
                           SET REQUEST_ID = :REQUEST_ID
                           WHERE ATTR_GROUP_ID = :atr_grp_id
                           AND (REQUEST_ID'||l_concat_pk_cols||') IN
                                    ( SELECT /*+ cardinality(EGO_ITM_USR_ATTR_INTRFC,10) */
                                      (ROW_IDENTIFIER * -2)'||l_concat_pk_cols||'
                                      FROM '||p_interface_table_name||'
                                      WHERE DATA_SET_ID = :DATA_SET_ID
                                            AND ATTR_GROUP_ID = :ATTR_GROUP_ID
                                            AND PROCESS_STATUS = '||G_PS_IN_PROCESS||' )';
                        -- '   AND REQUEST_ID <-1 ';
        EXECUTE IMMEDIATE l_dynamic_sql
        USING G_REQUEST_ID,l_attr_group_metadata_obj.ATTR_GROUP_ID, p_data_set_id, l_attr_group_metadata_obj.ATTR_GROUP_ID ; /* Fix for bug#9678667 */
      END IF;

      END IF;

    END IF; --ending l_do_dml_for_this_ag and p_do_dml check (*p_do_dml-IF-2*)

      -- Following If condition is fix for bug 5842178
      IF (l_is_post_event_enabled_flag IS NULL OR l_is_post_event_enabled_flag <> 'Y') THEN
          l_dummy := 0;

    SELECT COUNT(*)
      INTO l_dummy
      FROM EGO_ATTR_GROUP_DL
           WHERE ATTR_GROUP_ID = l_attr_group_metadata_obj.ATTR_GROUP_ID
       AND RAISE_POST_EVENT = 'Y';

          IF(l_dummy > 0)THEN
            l_is_post_event_enabled_flag := 'Y';
    END IF;
      END IF;
      -- End of fix for bug 5842178.
      ----------------------------------------------------
      -- reporting of errors for all failed rows belonging
      -- to this attr grp.
      ----------------------------------------------------
     -- Bug 9705869 : Added p_do_dml, so that the errors are logged even while doing DML (i.e to log errors for duplicate records etc..)
     IF (p_validate OR p_do_req_def_valiadtion OR p_do_dml) THEN --*p-validate-IF-5* BugFix:5355722

        code_debug('          In validate mode: Before logging errors ' ,2);

        Log_Errors_Now(
          p_entity_id               => p_entity_id
         ,p_entity_index            => p_entity_index
         ,p_entity_code             => p_entity_code
         ,p_object_name             => p_object_name
         ,p_pk1_column_name         => l_pk1_column_name
         ,p_pk2_column_name         => l_pk2_column_name
         ,p_pk3_column_name         => l_pk3_column_name
         ,p_pk4_column_name         => l_pk4_column_name
         ,p_pk5_column_name         => l_pk5_column_name
         ,p_classification_col_name => l_class_code_column_name
         ,p_interface_table_name    => p_interface_table_name
         ,p_err_col_static_sql      => l_err_col_static_sql
         ,p_err_where_static_sql    => l_err_where_static_sql
         ,p_attr_grp_meta_obj       => l_attr_group_metadata_obj
         ,p_data_set_id             => p_data_set_id /*Fix for bug#9678667. Literal to bind*/
        );

        code_debug('          After logging errors ' ,2);

     END IF; -- *p-validate-IF-5* ending p_validate IF

/*Code changes for bug 8485287*/
/* Added code to raise postAttributeChange BE for call of public API to create Item. */
      ----------------------------------------------------
      -- AFTER THE DML, NOW WE WILL RAISE THE POST EVENT
      -- (if we need to ...) gnanda
      ----------------------------------------------------

  IF (p_do_dml) THEN --search for *p_do_dml-IF-YJain* to locate the END
           BEGIN
             SELECT BUSINESS_EVENT_NAME
                 INTO l_new_post_event_name
             FROM EGO_FND_DESC_FLEXS_EXT
             WHERE APPLICATION_ID = p_application_id
                AND DESCRIPTIVE_FLEXFIELD_NAME = p_attr_group_type;
           EXCEPTION
             WHEN NO_DATA_FOUND THEN
                l_new_post_event_name := NULL;
           END;

        -- Bug 10090254 Changes : Start
        /*
        SELECT BUSINESS_EVENT_FLAG
         INTO l_new_post_event_enabled_flag
        FROM EGO_FND_DSC_FLX_CTX_EXT
        WHERE ATTR_GROUP_ID = l_attr_group_metadata_obj.ATTR_GROUP_ID;
        */

        SELECT COUNT(*)
        INTO  l_dummy
        FROM  EGO_ATTR_GROUP_DL
        WHERE ATTR_GROUP_ID = l_attr_group_metadata_obj.ATTR_GROUP_ID
          AND RAISE_POST_EVENT = 'Y';

        IF (l_dummy > 0) THEN
          l_new_post_event_enabled_flag := 'Y';
        ELSE
          l_new_post_event_enabled_flag := 'N';
        END IF;

        code_debug('inside raising events   l_new_post_event_enabled_flag - '||l_new_post_event_enabled_flag);
        -- Bug 10090254 Changes : End

  IF (l_new_post_event_name IS NOT NULL AND l_new_post_event_enabled_flag = 'Y' AND G_REQUEST_ID =-1) THEN
      -- IF (l_event_name IS NOT NULL AND l_is_event_enabled_flag = 'Y') THEN

         --------------------------------------------------------------------
         -- HERE WE RAISE POST EVENT FOR ALL THE AG ROWS *NOT* BEING DELETED
         --------------------------------------------------------------------
         OPEN l_dynamic_cursor FOR l_dynamic_sql_1
         USING p_data_set_id, l_attr_group_metadata_obj.ATTR_GROUP_NAME;
         LOOP
           FETCH l_dynamic_cursor INTO l_ag_deflatened_row;
           EXIT WHEN l_dynamic_cursor%NOTFOUND;

     l_event_key := SUBSTRB(l_new_post_event_name, 1, 225) || '-' || TO_CHAR(SYSDATE, 'J.SSSSS');
           EGO_WF_WRAPPER_PVT.Raise_WF_Business_Event(
            p_event_name                    => l_new_post_event_name
           ,p_event_key                     => l_event_key
           ,p_dml_type                      => l_ag_deflatened_row.TRANSACTION_TYPE
           ,p_attr_group_name               => l_ag_deflatened_row.ATTR_GROUP_INT_NAME
           ,p_extension_id                  => l_ag_deflatened_row.EXTENSION_ID
           ,p_primary_key_1_col_name        => l_pk1_column_name
           ,p_primary_key_1_value           => l_ag_deflatened_row.PK1
           ,p_primary_key_2_col_name        => l_pk2_column_name
           ,p_primary_key_2_value           => l_ag_deflatened_row.PK2
           ,p_primary_key_3_col_name        => l_pk3_column_name
           ,p_primary_key_3_value           => l_ag_deflatened_row.PK3
           ,p_primary_key_4_col_name        => l_pk4_column_name
           ,p_primary_key_4_value           => l_ag_deflatened_row.PK4
           ,p_primary_key_5_col_name        => l_pk5_column_name
           ,p_primary_key_5_value           => l_ag_deflatened_row.PK5
           ,p_data_level_1_col_name         => l_data_level_column_1
           ,p_data_level_1_value            => l_ag_deflatened_row.DL1
           ,p_data_level_2_col_name         => l_data_level_column_2
           ,p_data_level_2_value            => l_ag_deflatened_row.DL1
           ,p_data_level_3_col_name         => l_data_level_column_3
           ,p_data_level_3_value            => l_ag_deflatened_row.DL1
           ,p_user_row_identifier           => l_ag_deflatened_row.ROW_IDENTIFIER
           ,p_entity_id                     => p_entity_id
           ,p_entity_index                  => p_entity_index
           ,p_entity_code                   => p_entity_code
           ,p_add_errors_to_fnd_stack       => G_ADD_ERRORS_TO_FND_STACK
           );
         END LOOP;
         CLOSE l_dynamic_cursor;
         ----------------------------------------------------------------
         -- HERE WE RAISE POST EVENT FOR ALL THE AG ROWS *BEING* DELETED
         ----------------------------------------------------------------
         OPEN l_dynamic_cursor FOR l_dynamic_sql_delete_post
         USING p_data_set_id, l_attr_group_metadata_obj.ATTR_GROUP_NAME;
         LOOP
           FETCH l_dynamic_cursor INTO l_ag_deflatened_row;
           EXIT WHEN l_dynamic_cursor%NOTFOUND;
            l_event_key := SUBSTRB(l_new_post_event_name, 1, 225) || '-' || TO_CHAR(SYSDATE, 'J.SSSSS');
           EGO_WF_WRAPPER_PVT.Raise_WF_Business_Event(
            p_event_name                    => l_new_post_event_name
           ,p_event_key                     => l_event_key
           ,p_dml_type                      => l_ag_deflatened_row.TRANSACTION_TYPE
           ,p_attr_group_name               => l_ag_deflatened_row.ATTR_GROUP_INT_NAME
           ,p_extension_id                  => l_ag_deflatened_row.EXTENSION_ID
           ,p_primary_key_1_col_name        => l_pk1_column_name
           ,p_primary_key_1_value           => l_ag_deflatened_row.PK1
           ,p_primary_key_2_col_name        => l_pk2_column_name
           ,p_primary_key_2_value           => l_ag_deflatened_row.PK2
           ,p_primary_key_3_col_name        => l_pk3_column_name
           ,p_primary_key_3_value           => l_ag_deflatened_row.PK3
           ,p_primary_key_4_col_name        => l_pk4_column_name
           ,p_primary_key_4_value           => l_ag_deflatened_row.PK4
           ,p_primary_key_5_col_name        => l_pk5_column_name
           ,p_primary_key_5_value           => l_ag_deflatened_row.PK5
           ,p_data_level_1_col_name         => l_data_level_column_1
           ,p_data_level_1_value            => l_ag_deflatened_row.DL1
           ,p_data_level_2_col_name         => l_data_level_column_2
           ,p_data_level_2_value            => l_ag_deflatened_row.DL1
           ,p_data_level_3_col_name         => l_data_level_column_3
           ,p_data_level_3_value            => l_ag_deflatened_row.DL1
           ,p_user_row_identifier           => l_ag_deflatened_row.ROW_IDENTIFIER
           ,p_entity_id                     => p_entity_id
           ,p_entity_index                  => p_entity_index
           ,p_entity_code                   => p_entity_code
           ,p_add_errors_to_fnd_stack       => G_ADD_ERRORS_TO_FND_STACK
           );
         END LOOP;
         CLOSE l_dynamic_cursor;
      END IF; -- IF (l_new_post_event_name IS NOT NULL AND l_new_post_event_enabled_flag = 'Y' AND G_REQUEST_ID =-1) THEN
      END IF ; --end for  *p_do_dml-IF-YJain*
/* End code changes for bug 8485287*/

    END LOOP;

    -- Bug : 4099546
    CLOSE l_dynamic_dist_ag_cursor;
    code_debug(' After the Attr Group Level Validation loop ' ,1);

    IF (ERROR_HANDLER.Get_Message_Count > l_no_of_err_recs) THEN
      x_return_status := G_FND_RET_STS_WARNING;
    ELSE
      x_return_status := FND_API.G_RET_STS_SUCCESS;
    END IF;

    --
    -- let us write the error logs first
    --
    IF (FND_API.To_Boolean(p_init_error_handler)) THEN
      ERROR_HANDLER.Log_Error
       (p_write_err_to_inttable    => 'Y'
       ,p_write_err_to_conclog     => 'Y'
       ,p_write_err_to_debugfile   => ERROR_HANDLER.Get_Debug()
      );
      IF (ERROR_HANDLER.Get_Debug() = 'Y') THEN
        ERROR_HANDLER.Close_Debug_Session();
      END IF;
    END IF;

    IF (l_req_num_cursor_id) IS NOT NULL THEN
      DBMS_SQL.Close_Cursor(l_req_num_cursor_id);
    END IF;
    IF (l_req_char_cursor_id) IS NOT NULL THEN
      DBMS_SQL.Close_Cursor(l_req_char_cursor_id);
    END IF;
    IF (l_req_date_cursor_id) IS NOT NULL THEN
      DBMS_SQL.Close_Cursor(l_req_date_cursor_id);
    END IF;
    IF (l_default_num_cursor_id) IS NOT NULL THEN
      DBMS_SQL.Close_Cursor(l_default_num_cursor_id);
    END IF;
    IF (l_default_date_cursor_id) IS NOT NULL THEN
      DBMS_SQL.Close_Cursor(l_default_date_cursor_id);
    END IF;
    IF (l_default_char_cursor_id) IS NOT NULL THEN
      DBMS_SQL.Close_Cursor(l_default_char_cursor_id);
    END IF;
    IF (l_bad_tvs_sql_cursor_id) IS NOT NULL THEN
      DBMS_SQL.Close_Cursor(l_bad_tvs_sql_cursor_id);
    END IF;

    IF (l_sr_tvs_num_cursor_id1) IS NOT NULL THEN
      DBMS_SQL.Close_Cursor(l_sr_tvs_num_cursor_id1);
    END IF;
    IF (l_sr_tvs_num_cursor_id2) IS NOT NULL THEN
      DBMS_SQL.Close_Cursor(l_sr_tvs_num_cursor_id2);
    END IF;
    IF (l_sr_tvs_date_cursor_id1) IS NOT NULL THEN
      DBMS_SQL.Close_Cursor(l_sr_tvs_date_cursor_id1);
    END IF;
    IF (l_sr_tvs_date_cursor_id2) IS NOT NULL THEN
      DBMS_SQL.Close_Cursor(l_sr_tvs_date_cursor_id2);
    END IF;
    IF (l_sr_tvs_str_cursor_id1) IS NOT NULL THEN
      DBMS_SQL.Close_Cursor(l_sr_tvs_str_cursor_id1);
    END IF;
    IF (l_sr_tvs_str_cursor_id2) IS NOT NULL THEN
      DBMS_SQL.Close_Cursor(l_sr_tvs_str_cursor_id2);
    END IF;

    IF (l_tvs_char_cursor_id) IS NOT NULL THEN
      DBMS_SQL.Close_Cursor(l_tvs_char_cursor_id);
    END IF;
    IF (l_tvs_num_cursor_id) IS NOT NULL THEN
      DBMS_SQL.Close_Cursor(l_tvs_num_cursor_id);
    END IF;
    IF (l_tvs_date_cursor_id) IS NOT NULL THEN
      DBMS_SQL.Close_Cursor(l_tvs_date_cursor_id);
    END IF;
    IF (l_bad_bindattrs_tvs_cursor_id) IS NOT NULL THEN
      DBMS_SQL.Close_Cursor(l_bad_bindattrs_tvs_cursor_id);
    END IF;

    -- Bug 10151142: Start
    IF (l_dynamic_sql_cursor_id) IS NOT NULL THEN
      DBMS_SQL.Close_Cursor(l_dynamic_sql_cursor_id);
    END IF;
    IF (l_dynamic_sql_1_cursor_id) IS NOT NULL THEN
      DBMS_SQL.Close_Cursor(l_dynamic_sql_1_cursor_id);
    END IF;
    -- Bug 10151142: End

    --------------------------------------------------
    -- MARKING ALL THE ROWS AS 3 WHICH HAVE ERRORED --
    --------------------------------------------------
    --considering the G_PS_BAD_ATTR_OR_AG_METADATA is the starting point for the intermittent errors.
    -- Bug 9705869  : Added p_do_dml, so that the errors are logged even while doing DML (i.e to log errors for duplicate records etc..)
    IF (p_validate OR p_do_req_def_valiadtion OR p_do_dml) THEN -- *p_validate-IF-6* BugFix:5355722
      l_dynamic_sql :=
          'UPDATE '||p_interface_table_name||' UAI1 '||
          '    SET UAI1.PROCESS_STATUS =  '||G_PS_GENERIC_ERROR||
          '    WHERE UAI1.DATA_SET_ID = :data_set_id '||--p_data_set_id||
          '    AND UAI1.ROW_IDENTIFIER  IN '||
          '      (SELECT DISTINCT UAI2.ROW_IDENTIFIER'||
          '         FROM '||p_interface_table_name||' UAI2'||
          '          WHERE UAI2.DATA_SET_ID = :data_set_id '||--p_data_set_id||
          '                AND UAI2.PROCESS_STATUS >= '||G_PS_BAD_ATTR_OR_AG_METADATA ||')';
      EXECUTE IMMEDIATE l_dynamic_sql
      USING p_data_set_id, p_data_set_id;/*Fix for bug#9678667. Literal to bind*/
    END IF; -- *p_validate-IF-6* ending p_validate

    ------------------------------------------------------------------------
    -- WE ARE DONE WITH THE PROCESSING... NOW IF THERE EXIST SUCCESSFUL   --
    -- ROWS IN THE INTERFACE TABLE AND POST EVENT FLAG IS ENABLED         --
    -- WE NEED TO RAISE A POST EVENT. THERE IS JUST ONE POST EVENT RAISED --
    -- WITH REQUEST_ID AS A PARAMER.                                      --
    ------------------------------------------------------------------------
    IF (p_do_dml) THEN -- *p_do_dml-IF-3*

      BEGIN
        SELECT BUSINESS_EVENT_NAME
          INTO l_event_name
          FROM EGO_FND_DESC_FLEXS_EXT
         WHERE APPLICATION_ID = p_application_id
           AND DESCRIPTIVE_FLEXFIELD_NAME = p_attr_group_type;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          l_event_name := NULL;
      END;

      l_successful_rowcount := 0;
      EXECUTE IMMEDIATE  ' SELECT COUNT(*) FROM '|| p_interface_table_name ||
                         ' WHERE DATA_SET_ID = :data_set_id '||
                         '   AND ATTR_GROUP_TYPE = '''||p_attr_group_type||''' '||
                         ' AND PROCESS_STATUS = '||G_PS_IN_PROCESS
      INTO l_successful_rowcount
      USING p_data_set_id;
      l_is_second_post_event_flag := EGO_WF_WRAPPER_PVT.Get_PostAttr_Change_Event ();
       IF (l_event_name IS NOT NULL AND l_is_post_event_enabled_flag = 'Y' AND l_successful_rowcount > 0 AND G_REQUEST_ID IS NOT NULL   AND G_REQUEST_ID <>-1)
       THEN  --code changes for bug 8485287

         l_event_key := SUBSTRB(l_event_name, 1, 225) || '-' || TO_CHAR(SYSDATE, 'J.SSSSS');
         EGO_WF_WRAPPER_PVT.Raise_WF_Business_Event(
          p_event_name                    => l_event_name
         ,p_event_key                     => l_event_key
         ,p_request_id                    => G_REQUEST_ID
         ,p_entity_id                     => p_entity_id
         ,p_entity_index                  => p_entity_index
         ,p_entity_code                   => p_entity_code
         ,p_add_errors_to_fnd_stack       => G_ADD_ERRORS_TO_FND_STACK
         );
      END IF;
      ----------------------------------
      -- DONE WITH RAISING POST EVENT
      ----------------------------------
    END IF; -- *p_do_dml-IF-3*

    -- Standard check of p_commit
    IF FND_API.To_Boolean(p_commit) THEN
      COMMIT WORK;
    END IF;

    code_debug(l_api_name|| 'Done  ');

  EXCEPTION
    WHEN G_NO_ROWS_IN_INTF_TABLE THEN
      -- We need not do any thing since there are no rows in the intf table to process.
      NULL;

    WHEN OTHERS THEN
      code_debug('######## Oops ... came into the when others block-'||SQLERRM ,2);
      IF FND_API.To_Boolean(p_commit) THEN
        ROLLBACK TO Bulk_Load_User_Attrs_Data_PVT;
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_data := 'Executing - '||G_PKG_NAME||'.'||l_api_name||' '||SQLERRM;
      -----------------------------------------------------
      -- MARKING ALL THE ROWS AS SINCE UN-EXPECTED ERROR --
      -- HAS OCCURED AND WE ARE ROLLING BACK             --
      -----------------------------------------------------
      /* FOR TESTING COMMENTING THIS OUT

      l_dynamic_sql :=
          'UPDATE '||p_interface_table_name||' UAI1
              SET UAI1.PROCESS_STATUS =  '||G_PS_GENERIC_ERROR||'
            WHERE UAI1.DATA_SET_ID = :data_set_id
              AND UAI1.PROCESS_STATUS = '||G_PS_IN_PROCESS;

      --EXECUTE IMMEDIATE l_dynamic_sql USING p_data_set_id;

      */
      -----------------------------------------------------------------
      -- Get a default row identifier to use in logging this message --
      -----------------------------------------------------------------
      l_dynamic_sql :=
      'SELECT TRANSACTION_ID
         FROM '||p_interface_table_name||' UAI1
        WHERE UAI1.DATA_SET_ID = :data_set_id
          AND ROWNUM = 1';
      EXECUTE IMMEDIATE l_dynamic_sql
      INTO l_dummy
      USING p_data_set_id;

      ERROR_HANDLER.Add_Error_Message(
        p_message_text                  => x_msg_data
       ,p_row_identifier                => l_dummy
       ,p_application_id                => 'EGO'
       ,p_message_type                  => FND_API.G_RET_STS_ERROR
       ,p_entity_id                     => G_ENTITY_ID
       ,p_table_name                    => p_interface_table_name
       ,p_entity_code                   => G_ENTITY_CODE
      );

END Bulk_Load_User_Attrs_Data;

------------------------------------------------------------------












---------------------------------------------------------------------------------------------------------------------
--API Name    : Apply_Template_On_Intf_Table
--Description : The api would apply the attribute values in the template to the interface
--              table, this api should be called after the rows in the interface table are
--              validated.
--parameters required :  p_api_version
--                        p_application_id
--                        p_object_name
--                        p_interface_table_name
--                        p_data_set_id
--                        p_template_id
--                        p_Classification_code
--                        p_attr_group_type
--                        p_target_entity_sql : this parameter should contain a query which would give a list of
--                                              entities on which the template is to be applied and which template
--                                              is to be applied and a rownum column.
--                                              e.g. 'SELECT ROWNUM ENTITYNUMBER,
--                                                           Decode(ROWNUM, 1,256678,2,256679,null) INVENTORY_ITEM_ID,
--                                                           204 ORGANIZATION_ID, 14978 ITEM_CATALOG_GROUP_ID, -
--                                                           1 TEMPLATE_ID
--                                                           FROM ego_itm_usr_Attr_intrfc WHERE ROWNUM<3';
--Return parameter    : x_return_status = 1 if no associations exist
--                                            0 in all other cases
--                       x_return_status
--                       x_errorcode
--                       x_msg_count
--                       x_msg_data
--
--
----------------------------------------------------------------------------------------------------------------------

 PROCEDURE Apply_Template_On_Intf_Table (
        p_api_version                   IN   NUMBER
       ,p_application_id                IN   NUMBER
       ,p_object_name                   IN   VARCHAR2
       ,p_interface_table_name          IN   VARCHAR2
       ,p_data_set_id                   IN   NUMBER
       ,p_attr_group_type               IN   VARCHAR2
       ,p_request_id                    IN   NUMBER
       ,p_program_application_id        IN   NUMBER
       ,p_program_id                    IN   NUMBER
       ,p_program_update_date           IN   DATE
       ,p_current_user_party_id         IN   NUMBER
       ,p_target_entity_sql             IN   VARCHAR2
       ,p_process_status                IN   NUMBER    DEFAULT G_PS_IN_PROCESS
       ,p_class_code_hierarchy_sql      IN   VARCHAR2  DEFAULT NULL
       ,p_hierarchy_template_tbl_sql    IN   VARCHAR2  DEFAULT NULL
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
) IS

    l_api_name      CONSTANT VARCHAR2(30) := 'Apply_template_on_intf_table';
    l_api_version   CONSTANT NUMBER       := 1.0;

    CURSOR data_level_cols_cursor (cp_application_id  IN NUMBER
                                  ,cp_attr_group_type IN VARCHAR2)
    IS
    SELECT data_level_id
          ,data_level_name
          ,pk1_column_name
          ,pk1_column_type
          ,pk2_column_name
          ,pk2_column_type
          ,pk3_column_name
          ,pk3_column_type
          ,pk4_column_name
          ,pk4_column_type
          ,pk5_column_name
          ,pk5_column_type
      FROM EGO_DATA_LEVEL_B
     WHERE application_id  = cp_application_id
       AND attr_group_type = cp_attr_group_type
  ORDER BY data_level_id;

    G_NO_ROWS_IN_INTF_TABLE     EXCEPTION;

    l_num_dl_columns            NUMBER := 0;
    l_class_code_column_name    VARCHAR2(30);
    l_class_code_column_type    VARCHAR2(30);

    l_ext_vl_name               VARCHAR2(30);

    l_pk1_column_name           VARCHAR2(30);
    l_pk2_column_name           VARCHAR2(30);
    l_pk3_column_name           VARCHAR2(30);
    l_pk4_column_name           VARCHAR2(30);
    l_pk5_column_name           VARCHAR2(30);

    l_dl_col_decode_list        VARCHAR2(1000);
    l_dl_col_list               VARCHAR2(1000);
    l_temp                      VARCHAR2(100);

    l_has_data_level_id         BOOLEAN;
    l_dl_col_templrtcq_list     VARCHAR2(1000);

    TYPE data_level_info IS RECORD
      (dl_id            NUMBER
      ,dl_name          VARCHAR2(150)
      ,dl_column1       VARCHAR2(150)
      ,dl_column2       VARCHAR2(150)
      ,dl_column3       VARCHAR2(150)
      ,dl_column4       VARCHAR2(150)
      ,dl_column5       VARCHAR2(150)
--      ,dl_column_type1  VARCHAR2(150)
--      ,dl_column_type2  VARCHAR2(150)
--      ,dl_column_type3  VARCHAR2(150)
--      ,dl_column_type4  VARCHAR2(150)
--      ,dl_column_type5  VARCHAR2(150)
--      ,dl_disp_name     VARCHAR2(240)
      ,dl_concat_pk_cols  VARCHAR2(1000)
      ,dl_col_list                VARCHAR2(1000)
      ,dl_intfrtcq_trtcq_join     VARCHAR2(1000)
      ,dl_ext_trtcq_join          VARCHAR2(1000)
      );

    TYPE data_level_table IS TABLE OF data_level_info;

    l_dl_record  DATA_LEVEL_TABLE;

    l_dynamic_sql                       VARCHAR2(32767);
    l_ag_to_process                     EGO_USER_ATTRS_BULK_NUM_TBL;
    l_template_to_process               EGO_USER_ATTRS_BULK_NUM_TBL;
    l_cc_to_process                     EGO_USER_ATTRS_BULK_NUM_TBL;

    l_ag_to_process_list                VARCHAR2(10000);
    l_template_to_process_list          VARCHAR2(10000);
    l_cc_to_process_list                VARCHAR2(10000);

    l_concat_pk_cols                    VARCHAR2(400) := '';
    l_concat_pk_cols_entities           VARCHAR2(800) := '';
    l_pk_col_where_ent_uartcq           VARCHAR2(1500) := '';
    l_ext_templrtcq_join                VARCHAR2(3000);
    l_ext_templrtcq_pk_join             VARCHAR2(1000);
    l_ext_templrtcq_uk_join             VARCHAR2(2000);
    l_dl_intfrtcq_trtcq_join            VARCHAR2(200);
    l_dl_ext_trtcq_join                 VARCHAR2(400);
    l_uk_tmpl_intf_rtcq_where           VARCHAR2(5000);
    l_attr_null_chk_decode              VARCHAR2(10000);

    l_attr_group_metadata_obj           EGO_ATTR_GROUP_METADATA_OBJ;
    l_attr_metadata_table               EGO_ATTR_METADATA_TABLE;
    l_template_table_RTCQ               VARCHAR2(32767);
    l_intf_table_RTCQ                   VARCHAR2(32767);
    l_ag_row_cursor                     INTEGER;
    l_dummy_number                      NUMBER;
    l_num_value                         NUMBER;
    l_str_value                         VARCHAR2(4000);
    l_date_value                        DATE;
    l_value                             VARCHAR2(32767);
    l_union_tbl_value                   VARCHAR2(3000);
    l_rows_to_insert_sql                VARCHAR2(32767);
    l_max_trans_id                      NUMBER;
    l_max_row_identifier                NUMBER;
    l_ag_id_col_exists                  BOOLEAN;
    l_ag_id_clause                      VARCHAR2(100);
    l_ag_assoc_data_level_id            NUMBER;
    l_assoc_data_level                  NUMBER;
    l_num_val_col                       VARCHAR2(2000);
    l_template_table_sql                VARCHAR2(10000);
    l_ext_b_table_name                  VARCHAR2(100);

BEGIN

code_debug(l_api_name||' Starting ',0);
code_debug(l_api_name||'   p_application_id         '|| p_application_id        );
code_debug(l_api_name||'   p_object_name            '|| p_object_name           );
code_debug(l_api_name||'   p_interface_table_name   '|| p_interface_table_name  );
code_debug(l_api_name||'   p_data_set_id            '|| p_data_set_id           );
code_debug(l_api_name||'   p_attr_group_type        '|| p_attr_group_type       );
code_debug(l_api_name||'   p_request_id             '|| p_request_id            );
code_debug(l_api_name||'   p_program_application_id '|| p_program_application_id);
code_debug(l_api_name||'   p_program_id             '|| p_program_id            );
code_debug(l_api_name||'   p_program_update_date    '|| p_program_update_date   );
code_debug(l_api_name||'   p_current_user_party_id  '|| p_current_user_party_id );
code_debug(l_api_name||'   p_target_entity_sql      '|| p_target_entity_sql     );

  IF(p_hierarchy_template_tbl_sql IS NULL) THEN
     l_template_table_sql := ' EGO_TEMPL_ATTRIBUTES ';
  ELSE
     l_template_table_sql := p_hierarchy_template_tbl_sql;
  END IF;

  l_dynamic_sql := ' SELECT count(*) FROM ( '||p_target_entity_sql||') ';
  EXECUTE IMMEDIATE l_dynamic_sql INTO l_dummy_number;
  code_debug (l_api_name ||' no records to be processed '||l_dummy_number);
  IF l_dummy_number = 0 THEN
    code_debug (l_api_name ||' returning as there are no records to process ');
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    RETURN;
  END IF;

  l_dynamic_sql :=
      ' SELECT MAX(ROW_IDENTIFIER),MAX(TRANSACTION_ID)'||
        ' FROM '||p_interface_table_name||
       ' WHERE DATA_SET_ID = :data_Set_id ';

  -----------------------------------------
  -- Fetch the PK column names and data  --
  -- types for the passed-in object name --
  -----------------------------------------
  SELECT PK1_COLUMN_NAME,
         PK2_COLUMN_NAME,
         PK3_COLUMN_NAME,
         PK4_COLUMN_NAME,
         PK5_COLUMN_NAME
    INTO l_pk1_column_name,
         l_pk2_column_name,
         l_pk3_column_name,
         l_pk4_column_name,
         l_pk5_column_name
    FROM FND_OBJECTS
   WHERE OBJ_NAME = p_object_name;

  ----------------------------------------------------------------------------
  -- CONSTRUCTING THE PK, DL AND THE CLASS CODE COLUMN SELECT LIST.         --
  ----------------------------------------------------------------------------

  IF (l_pk1_column_name IS NOT NULL) THEN
     l_concat_pk_cols := l_pk1_column_name||',';
     l_concat_pk_cols_entities := l_concat_pk_cols_entities||' TEMPLRTCQ.'||l_pk1_column_name||',';
     l_pk_col_where_ent_uartcq := l_pk_col_where_ent_uartcq || ' AND TEMPLRTCQ.'||l_pk1_column_name||' = INTFRTCQ.'||l_pk1_column_name||'(+)';
     -- l_ext_templrtcq_pk_join := l_ext_templrtcq_pk_join||' TEMPLRTCQ.'||l_pk1_column_name||' = EXT.'||l_pk1_column_name||'(+) '; -- Bug 13414358
  END IF;

  IF (l_pk2_column_name IS NOT NULL) THEN
     l_concat_pk_cols := l_concat_pk_cols ||l_pk2_column_name||',';
     l_concat_pk_cols_entities := l_concat_pk_cols_entities||' TEMPLRTCQ.'||l_pk2_column_name||',';
     l_pk_col_where_ent_uartcq := l_pk_col_where_ent_uartcq || ' AND TEMPLRTCQ.'||l_pk2_column_name||' = INTFRTCQ.'||l_pk2_column_name||'(+)';
     -- l_ext_templrtcq_pk_join := l_ext_templrtcq_pk_join||' AND TEMPLRTCQ.'||l_pk2_column_name||' = EXT.'||l_pk2_column_name||'(+) '; -- Bug 13414358
  END IF;

  IF (l_pk3_column_name IS NOT NULL) THEN
    l_concat_pk_cols := l_concat_pk_cols ||l_pk3_column_name||',';
    l_concat_pk_cols_entities := l_concat_pk_cols_entities||' TEMPLRTCQ.'||l_pk3_column_name||',';
    l_pk_col_where_ent_uartcq := l_pk_col_where_ent_uartcq || ' AND TEMPLRTCQ.'||l_pk3_column_name||' = INTFRTCQ.'||l_pk3_column_name||'(+)';
    -- l_ext_templrtcq_pk_join := l_ext_templrtcq_pk_join||' AND TEMPLRTCQ.'||l_pk3_column_name||' = EXT.'||l_pk3_column_name||'(+) '; -- Bug 13414358
  END IF;

  IF (l_pk4_column_name IS NOT NULL) THEN
    l_concat_pk_cols := l_concat_pk_cols ||l_pk4_column_name||',';
    l_concat_pk_cols_entities := l_concat_pk_cols_entities||' TEMPLRTCQ.'||l_pk4_column_name||',';
    l_pk_col_where_ent_uartcq := l_pk_col_where_ent_uartcq || ' AND TEMPLRTCQ.'||l_pk4_column_name||' = INTFRTCQ.'||l_pk4_column_name||'(+)';
    -- l_ext_templrtcq_pk_join := l_ext_templrtcq_pk_join||' AND TEMPLRTCQ.'||l_pk4_column_name||' = EXT.'||l_pk4_column_name||'(+) '; -- Bug 13414358
  END IF;

  IF (l_pk5_column_name IS NOT NULL) THEN
    l_concat_pk_cols := l_concat_pk_cols ||l_pk5_column_name||',';
    l_concat_pk_cols_entities := l_concat_pk_cols_entities||' TEMPLRTCQ.'||l_pk5_column_name||',';
    l_pk_col_where_ent_uartcq := l_pk_col_where_ent_uartcq || ' AND TEMPLRTCQ.'||l_pk5_column_name||' = INTFRTCQ.'||l_pk5_column_name||'(+)';
    -- l_ext_templrtcq_pk_join := l_ext_templrtcq_pk_join||' AND TEMPLRTCQ.'||l_pk5_column_name||' = EXT.'||l_pk5_column_name||'(+) '; -- Bug 13414358
  END IF;

code_debug(l_api_name||' Phase 1');
code_debug(l_api_name||' l_concat_pk_cols: '||l_concat_pk_cols);
code_debug(l_api_name||' l_concat_pk_cols_entities: '||l_concat_pk_cols_entities);
code_debug(l_api_name||' l_pk_col_where_ent_uartcq: '||l_pk_col_where_ent_uartcq);
-- code_debug(l_api_name||' l_ext_templrtcq_pk_join: '||l_ext_templrtcq_pk_join); -- Bug 13414358

  SELECT classification_col_name, classification_col_type
   INTO l_class_code_column_name, l_class_code_column_type
   FROM ego_fnd_objects_ext
  WHERE object_name = p_object_name;
code_debug(l_api_name||' l_class_code_column_name: ' ||l_class_code_column_name);

  -- adding the class code column
  IF l_class_code_column_name IS NOT NULL THEN
    l_concat_pk_cols := l_concat_pk_cols ||l_class_code_column_name||' ';
    l_concat_pk_cols_entities := l_concat_pk_cols_entities || ' TEMPLRTCQ.'||l_class_code_column_name||' , ';
    l_pk_col_where_ent_uartcq := l_pk_col_where_ent_uartcq ||' AND TEMPLRTCQ.'||l_class_code_column_name||' = INTFRTCQ.'||l_class_code_column_name||'(+) ';
    -- l_ext_templrtcq_pk_join := l_ext_templrtcq_pk_join || ' AND TEMPLRTCQ.'||l_class_code_column_name||' = EXT.'||l_class_code_column_name||'(+) '; -- Bug 13414358
  END IF;

code_debug(l_api_name||' Phase 2 after class code ');
code_debug(l_api_name||' l_concat_pk_cols: '||l_concat_pk_cols);
code_debug(l_api_name||' l_concat_pk_cols_entities: '||l_concat_pk_cols_entities);
code_debug(l_api_name||' l_pk_col_where_ent_uartcq: '||l_pk_col_where_ent_uartcq);
-- code_debug(l_api_name||' l_ext_templrtcq_pk_join: '|| l_ext_templrtcq_pk_join); -- Bug 13414358
  ------------------------------------------------------------
  -- Get data level information for the given attribute group type, aplication
  -- The assumption is that the template table has the DL columns if requested
  -- for application into the template
  ------------------------------------------------------------
  l_dl_record := DATA_LEVEL_TABLE();

  FOR dl_rec IN data_level_cols_cursor(cp_application_id  => p_application_id
                                      ,cp_attr_group_type => p_attr_group_type)
  LOOP
    l_dl_record.EXTEND();
    l_num_dl_columns := l_dl_record.LAST;
    l_dl_record(l_num_dl_columns).dl_id           := dl_rec.data_level_id;
    l_dl_record(l_num_dl_columns).dl_name         := dl_rec.data_level_name;
    l_dl_record(l_num_dl_columns).dl_column1      := dl_rec.pk1_column_name;
    l_dl_record(l_num_dl_columns).dl_column2      := dl_rec.pk2_column_name;
    l_dl_record(l_num_dl_columns).dl_column3      := dl_rec.pk3_column_name;
    l_dl_record(l_num_dl_columns).dl_column4      := dl_rec.pk4_column_name;
    l_dl_record(l_num_dl_columns).dl_column5      := dl_rec.pk5_column_name;
    l_dl_record(l_num_dl_columns).dl_col_list := null;
    l_dl_record(l_num_dl_columns).dl_intfrtcq_trtcq_join := ' 1=1 ';
    l_dl_record(l_num_dl_columns).dl_ext_trtcq_join := ' 1=1 ';

    IF dl_rec.pk1_column_name IS NOT NULL THEN
      l_dl_record(l_num_dl_columns).dl_col_list := ' ' ||dl_rec.pk1_column_name||' ';
      l_dl_record(l_num_dl_columns).dl_intfrtcq_trtcq_join := ' NVL(INTFRTCQ.'||dl_rec.pk1_column_name||'(+),-1) = NVL2(INTFRTCQ.'||dl_rec.pk1_column_name||'(+),TEMPLRTCQ.'||dl_rec.pk1_column_name||',-1)';
      -- l_dl_record(l_num_dl_columns).dl_ext_trtcq_join   := ' NVL(EXT.'||dl_rec.pk1_column_name||'(+),-1) = NVL(TEMPLRTCQ.'||dl_rec.pk1_column_name||',-1)'; -- Bug 13414358
    END IF;
    IF dl_rec.pk2_column_name IS NOT NULL THEN
      l_dl_record(l_num_dl_columns).dl_col_list :=
          l_dl_record(l_num_dl_columns).dl_col_list||','||dl_rec.pk2_column_name||' ';
      l_dl_record(l_num_dl_columns).dl_intfrtcq_trtcq_join :=
         l_dl_record(l_num_dl_columns).dl_intfrtcq_trtcq_join || ' AND NVL(INTFRTCQ.'||dl_rec.pk2_column_name||'(+),-1) = NVL2(INTFRTCQ.'||dl_rec.pk2_column_name||'(+),TEMPLRTCQ.'||dl_rec.pk2_column_name||',-1)';
      -- Bug 13414358
      /*
      l_dl_record(l_num_dl_columns).dl_ext_trtcq_join  :=
         l_dl_record(l_num_dl_columns).dl_ext_trtcq_join ||' AND NVL(EXT.'||dl_rec.pk2_column_name||'(+),-1) = NVL(TEMPLRTCQ.'||dl_rec.pk2_column_name||',-1)';
      */
    END IF;
    IF dl_rec.pk3_column_name IS NOT NULL THEN
      l_dl_record(l_num_dl_columns).dl_col_list :=
          l_dl_record(l_num_dl_columns).dl_col_list||','||dl_rec.pk3_column_name||' ';
      l_dl_record(l_num_dl_columns).dl_intfrtcq_trtcq_join :=
         l_dl_record(l_num_dl_columns).dl_intfrtcq_trtcq_join || ' AND NVL(INTFRTCQ.'||dl_rec.pk3_column_name||'(+),-1) = NVL2(INTFRTCQ.'||dl_rec.pk3_column_name||'(+),TEMPLRTCQ.'||dl_rec.pk3_column_name||',-1)';
      -- Bug 13414358
      /*
      l_dl_record(l_num_dl_columns).dl_ext_trtcq_join  :=
        l_dl_record(l_num_dl_columns).dl_ext_trtcq_join ||' AND NVL(EXT.'||dl_rec.pk3_column_name||'(+),-1) = NVL(TEMPLRTCQ.'||dl_rec.pk3_column_name||',-1)';
      */
    END IF;
    IF dl_rec.pk4_column_name IS NOT NULL THEN
      l_dl_record(l_num_dl_columns).dl_col_list :=
          l_dl_record(l_num_dl_columns).dl_col_list||','||dl_rec.pk4_column_name||' ';
      l_dl_record(l_num_dl_columns).dl_intfrtcq_trtcq_join :=
         l_dl_record(l_num_dl_columns).dl_intfrtcq_trtcq_join || ' AND NVL(INTFRTCQ.'||dl_rec.pk4_column_name||'(+),-1) = NVL2(INTFRTCQ.'||dl_rec.pk4_column_name||'(+),TEMPLRTCQ.'||dl_rec.pk4_column_name||',-1)';
      -- Bug 13414358
      /*
      l_dl_record(l_num_dl_columns).dl_ext_trtcq_join  :=
        l_dl_record(l_num_dl_columns).dl_ext_trtcq_join ||' AND NVL(EXT.'||dl_rec.pk4_column_name||'(+),-1) = NVL(TEMPLRTCQ.'||dl_rec.pk4_column_name||',-1)';
      */
    END IF;
    IF dl_rec.pk5_column_name IS NOT NULL THEN
      l_dl_record(l_num_dl_columns).dl_col_list :=
          l_dl_record(l_num_dl_columns).dl_col_list||','||dl_rec.pk5_column_name||' ';
      l_dl_record(l_num_dl_columns).dl_intfrtcq_trtcq_join :=
         l_dl_record(l_num_dl_columns).dl_intfrtcq_trtcq_join || ' AND NVL(INTFRTCQ.'||dl_rec.pk5_column_name||'(+),-1) = NVL2(INTFRTCQ.'||dl_rec.pk5_column_name||'(+),TEMPLRTCQ.'||dl_rec.pk5_column_name||',-1)';
      -- Bug 13414358
      /*
      l_dl_record(l_num_dl_columns).dl_ext_trtcq_join  :=
        l_dl_record(l_num_dl_columns).dl_ext_trtcq_join ||' AND NVL(EXT.'||dl_rec.pk5_column_name||'(+),-1) = NVL(TEMPLRTCQ.'||dl_rec.pk5_column_name||',-1)';
      */
    END IF;

    l_num_dl_columns := l_num_dl_columns + 1;
  END LOOP;

  SELECT application_table_name
    INTO l_ext_b_table_name
    FROM FND_DESCRIPTIVE_FLEXS
   WHERE application_id = p_application_id
     AND descriptive_flexfield_name = p_attr_group_type;

  l_has_data_level_id := FND_API.TO_BOOLEAN(EGO_USER_ATTRS_COMMON_PVT.has_column_in_table(l_ext_b_table_name, 'DATA_LEVEL_ID'));

  ------------------------------
  -- dl level column query part
  ------------------------------
  l_dl_col_list := NULL;
  l_dl_col_templrtcq_list := NULL;
  IF l_has_data_level_id THEN
    l_dl_col_list := EGO_USER_ATTRS_COMMON_PVT.Get_All_Data_Level_PK_Names (p_application_id  => p_application_id
                                                                           ,p_attr_group_type => p_attr_group_type);
    IF l_dl_col_list IS NOT NULL THEN
      l_dl_col_templrtcq_list := ' TEMPLRTCQ.'||REPLACE(l_dl_col_list, ', ', ' , TEMPLRTCQ.');
    ELSE
      l_dl_col_templrtcq_list := NULL;
    END IF;
  ELSE
    FOR cr IN data_level_cols_cursor(cp_application_id  => p_application_id
                                    ,cp_attr_group_type => p_attr_group_type) LOOP
      IF l_dl_col_list IS NULL THEN
        l_dl_col_list := ' '||cr.data_level_name||' ';
      ELSE
        l_dl_col_list := l_dl_col_list||', '||cr.data_level_name||' ';
      END IF;
    END LOOP;
  END IF;  -- l_has_data_level_id - 1

code_debug(l_api_name||' Phase 3 ');
code_debug(l_api_name||' l_dl_col_list: ' ||l_dl_col_list);
code_debug(l_api_name||' l_dl_intfrtcq_trtcq_join: '||l_dl_intfrtcq_trtcq_join);
code_debug(l_api_name||' l_dl_ext_trtcq_join: '||l_dl_ext_trtcq_join);

  SELECT flex_ext.application_vl_name
    INTO l_ext_vl_name
    FROM ego_fnd_desc_flexs_ext flex_ext
   WHERE flex_ext.application_id = p_application_id
     AND flex_ext.descriptive_flexfield_name = p_attr_group_type;

  ----------------------------------------------------------------------------
  -- WE ARE ASSUMING THAT THE ROWS IN THE INTERFACE TABLE ARE ALREADY       --
  -- VALIDATED BY NOW. AND HENCE THE ATTR GROUP ID COLUMN IS ALREADY        --
  -- POPULATED.                                                             --
  ----------------------------------------------------------------------------

  ----------------------------------------------------------------------------
  --                    Collect the atttributes                             --
  ----------------------------------------------------------------------------

  l_dynamic_sql :=
           ' SELECT DISTINCT ATTRIBUTE_GROUP_ID, TEMPL.TEMPLATE_ID, TEMPL.CLASSIFICATION_CODE '||
           '   FROM EGO_TEMPL_ATTRIBUTES TEMPL,              '||
           '        EGO_FND_DSC_FLX_CTX_EXT AGMDATA,         '||
           '      ('||p_target_entity_sql||') ENTITIES       '||
           '  WHERE TEMPL.TEMPLATE_ID = ENTITIES.TEMPLATE_ID ';
  IF (p_class_code_hierarchy_sql IS NOT NULL) THEN
    l_dynamic_sql := l_dynamic_sql ||' AND (  TEMPL.CLASSIFICATION_CODE = ENTITIES.'||l_class_code_column_name
                                   ||'       OR TEMPL.CLASSIFICATION_CODE IN ('||p_class_code_hierarchy_sql||' ) ) ';
  ELSE
    l_dynamic_sql := l_dynamic_sql ||'    AND TEMPL.CLASSIFICATION_CODE = ENTITIES.'||l_class_code_column_name;
  END IF;

    l_dynamic_sql := l_dynamic_sql ||
           '    AND AGMDATA.ATTR_GROUP_ID = TEMPL.ATTRIBUTE_GROUP_ID '||
           '    AND AGMDATA.DESCRIPTIVE_FLEXFIELD_NAME = :ag_type    '||
           '    AND ENABLED_FLAG = ''Y''                             ';

code_debug(l_api_name||' Phase 4 ');
code_debug(l_api_name||' l_dynamic_sql: '|| l_dynamic_sql);
code_debug(l_api_name||' executed using bind: '|| p_attr_group_type);
  BEGIN

     EXECUTE IMMEDIATE l_dynamic_sql
     BULK COLLECT INTO l_ag_to_process,l_template_to_process,l_cc_to_process
     USING p_attr_group_type;
  EXCEPTION
      WHEN NO_DATA_FOUND THEN
          code_debug('      ...... No row to process in the for this template  ',1);
          RAISE G_NO_ROWS_IN_INTF_TABLE;
  END;

  ----------------------------------------------------------------------------
  -- BUILD THE LIST OF AG_ID,CLASS_CODE AND TEMPL_ID TO BE USED IN THE      --
  -- TEMPLATE RTCQ (this will reduce the records in the RTCQ tbale and the  --
  -- index will be picked up.)                                              --
  ----------------------------------------------------------------------------
  l_ag_to_process_list := ' -2910 ';
  l_template_to_process_list := ' -2910 ';
  l_cc_to_process_list :=  ' -2910 ';

  IF (l_ag_to_process.COUNT >0) THEN
    FOR x IN l_ag_to_process.FIRST .. l_ag_to_process.LAST
    LOOP
      l_ag_to_process_list := l_ag_to_process_list || ','|| l_ag_to_process(x);
      l_template_to_process_list := l_template_to_process_list ||','||l_template_to_process(x);
      l_cc_to_process_list := l_cc_to_process_list||','||l_cc_to_process(x);
    END LOOP;
  END IF;

  -- Bug 10125885 - Start
  -- Add all the ICC ids available in the interface table.
  l_dynamic_sql := 'SELECT DISTINCT ITEM_CATALOG_GROUP_ID '||
                   ' FROM ('||p_target_entity_sql||')';

  EXECUTE IMMEDIATE l_dynamic_sql
     BULK COLLECT INTO l_cc_to_process;

  IF (l_cc_to_process.Count > 0) THEN
    FOR x IN l_cc_to_process.FIRST .. l_cc_to_process.LAST
    LOOP
      l_cc_to_process_list := l_cc_to_process_list||','||l_cc_to_process(x);
    END LOOP;
  END IF;
  -- Bug 10125885 - End

code_debug(l_api_name||' Phase 5 ');
code_debug(l_api_name||' l_ag_to_process_list: '|| l_ag_to_process_list);
code_debug(l_api_name||' l_template_to_process_list: '|| l_template_to_process_list);
code_debug(l_api_name||' l_cc_to_process_list: '|| l_cc_to_process_list);
  ----------------------------------------------------------------------------
  -- Now we will loop thru this list of ag id's to process each AG .        --
  ----------------------------------------------------------------------------

  IF (l_ag_to_process.COUNT >0) THEN

    FOR x IN l_ag_to_process.FIRST .. l_ag_to_process.LAST
    LOOP


      l_attr_group_metadata_obj := EGO_USER_ATTRS_COMMON_PVT.Get_Attr_Group_Metadata(
                                   p_attr_group_id   => l_ag_to_process(x)
                                  ,p_application_id  => p_application_id
                                  ,p_attr_group_type => null
                                  ,p_attr_group_name => NULL
                                 );

      ------------------------------------------------------------------------
      -- Checking the data level at which the attr group is associated      --
      ------------------------------------------------------------------------
      IF l_has_data_level_id THEN  -- l_has_data_level_id - 2
        l_dl_col_decode_list := l_dl_col_templrtcq_list;
        --
        -- do we really need this?
        --
        l_dl_ext_trtcq_join := ' 0 = 0 ';
        l_dl_intfrtcq_trtcq_join := ' 0 = 0 ';
      ELSE
        -- existing code which takes in the
        SELECT DATA_LEVEL_ID
          INTO l_ag_assoc_data_level_id
          FROM EGO_OBJ_AG_ASSOCS_B
         WHERE ATTR_GROUP_ID = l_attr_group_metadata_obj.ATTR_GROUP_ID
           AND ROWNUM = 1;

        FOR loop_dl_count IN l_dl_record.first .. l_dl_record.last LOOP
          IF l_dl_record(loop_dl_count).dl_id = l_ag_assoc_data_level_id THEN
            IF l_dl_record(loop_dl_count).dl_column1 IS NULL THEN
              l_assoc_data_level := 0;
            ELSE
              l_assoc_data_level := 1;
            END IF;
            ------------------------------------------------------------------
            -- Building the data level col decode for pluggin into the      --
            -- select                                                       --
            ------------------------------------------------------------------
            IF l_dl_record(loop_dl_count).dl_column1 IS NOT NULL THEN
              l_dl_col_decode_list := ' DECODE(1,'||l_assoc_data_level||',TEMPLRTCQ.'||l_dl_record(loop_dl_count).dl_column1||',null) '||l_dl_record(loop_dl_count).dl_column1||' ';
              IF l_dl_record(loop_dl_count).dl_column1 IS NOT NULL THEN
                l_dl_col_decode_list := ', DECODE(1,'||l_assoc_data_level||',TEMPLRTCQ.'||l_dl_record(loop_dl_count).dl_column2||',null) '||l_dl_record(loop_dl_count).dl_column2||' ';
                IF l_dl_record(loop_dl_count).dl_column3 IS NOT NULL THEN
                  l_dl_col_decode_list := ', DECODE(1,'||l_assoc_data_level||',TEMPLRTCQ.'||l_dl_record(loop_dl_count).dl_column3||',null) '||l_dl_record(loop_dl_count).dl_column3||' ';
                END IF;
              END IF;
            END IF;
            EXIT; -- loop
          END IF;
        END LOOP;

        ----------------------------------------------------------------------
        -- In case the AG is associated at entity level there is no need to --
        -- have the data level clause                                       --
        ----------------------------------------------------------------------
        IF(l_assoc_data_level = 0) THEN
           l_dl_ext_trtcq_join := ' 0 = 0 ';
           l_dl_intfrtcq_trtcq_join := ' 0 = 0 ';
        END IF;

      END IF; -- l_has_data_level_id - 2
code_debug(l_api_name||' ATTR_GROUP_NAME: '|| l_attr_group_metadata_obj.ATTR_GROUP_NAME);
code_debug(l_api_name||' l_assoc_data_level: '|| l_assoc_data_level);
code_debug(l_api_name||' l_dl_col_decode_list: '|| l_dl_col_decode_list);

      ------------------------------------------------------------------------
      -- LET US FIRST BUILD THE RTCQ QUERY FOR TEMPLATE AND INTF TABLE      --
      ------------------------------------------------------------------------
      l_attr_metadata_table := l_attr_group_metadata_obj.ATTR_METADATA_TABLE;

      l_template_table_RTCQ := 'SELECT '||l_attr_group_metadata_obj.ATTR_GROUP_ID||', CLASSIFICATION_CODE CLASSIFICATION_CODE1,'||
                               'MAX(TEMPLATE_ID) TEMPLATE_ID1, ATTRIBUTE_GROUP_ID, ROW_NUMBER ';

      -- l_ext_templrtcq_uk_join := ' AND 3=3 '; -- Bug 13414358

      l_intf_table_RTCQ := 'SELECT ROW_IDENTIFIER, ATTR_GROUP_ID, '||l_concat_pk_cols;

      IF l_has_data_level_id THEN -- l_has_data_level_id - 3
        l_intf_table_RTCQ := l_intf_table_RTCQ ||', DATA_LEVEL_ID ';
      END IF;  -- l_has_data_level_id - 3

      IF(l_dl_col_list IS NOT NULL) THEN
        l_intf_table_RTCQ := l_intf_table_RTCQ ||','||l_dl_col_list;
      END IF;
      l_intf_table_RTCQ := l_intf_table_RTCQ||
                           ',MAX(TRANSACTION_TYPE) TRANSACTION_TYPE ,MAX(REQUEST_ID) REQUEST_ID '||
                           ',MAX(PROGRAM_APPLICATION_ID) PROGRAM_APPLICATION_ID '||
                           ',MAX(PROGRAM_ID) PROGRAM_ID, MAX(PROGRAM_UPDATE_DATE) PROGRAM_UPDATE_DATE '||
                           ',MAX(CREATED_BY) CREATED_BY,MAX(CREATION_DATE) CREATION_DATE '||
                           ',MAX(LAST_UPDATED_BY) LAST_UPDATED_BY, MAX(LAST_UPDATE_DATE) LAST_UPDATE_DATE '||
                           ',MAX(LAST_UPDATE_LOGIN) LAST_UPDATE_LOGIN ';
      l_uk_tmpl_intf_rtcq_where := ' 2=2 ';

      l_attr_null_chk_decode := ' AND DECODE(TEMPL.ATTRIBUTE_ID,';
code_debug(l_api_name||' Phase 6 ');
code_debug(l_api_name||' l_template_table_RTCQ: '|| l_template_table_RTCQ);
code_debug(l_api_name||' l_intf_table_RTCQ: '|| l_intf_table_RTCQ);

      l_num_val_col := NULL;
      ------------------------------------------------------------------------
      -- Looping thru all the attrs to build the RTCQ for the template      --
      -- table.                                                             --
      ------------------------------------------------------------------------
      FOR i IN l_attr_metadata_table.FIRST .. l_attr_metadata_table.LAST
      LOOP

        l_attr_null_chk_decode := l_attr_null_chk_decode||l_attr_metadata_table(i).ATTR_ID||
                                  ', NVL2(INTFRTCQ.'||l_attr_metadata_table(i).ATTR_NAME||',CHR(0),NULL) , ';

        ----------------------------------------------------------------------
        -- Add SELECT list attributes that are specific to NUMBER type      --
        ----------------------------------------------------------------------

        IF (l_attr_metadata_table(i).DATA_TYPE_CODE = EGO_EXT_FWK_PUB.G_NUMBER_DATA_TYPE) THEN
            l_template_table_RTCQ := l_template_table_RTCQ ||
                                   ',  MAX(DECODE(TEMPL.ATTRIBUTE_ID '||
                                                ','||TO_CHAR(l_attr_metadata_table(i).ATTR_ID)||
                                                ','||'TEMPL.ATTRIBUTE_NUMBER_VALUE'||
                                                ',NULL)) '||TO_CHAR(l_attr_metadata_table(i).ATTR_NAME);

            l_intf_table_RTCQ := l_intf_table_RTCQ ||
                                   ',  MAX(DECODE(INTF.ATTR_INT_NAME '||
                                                ','''||l_attr_metadata_table(i).ATTR_NAME||''' '||
                                                ','||'NVL(INTF.ATTR_VALUE_NUM,'||G_NULL_TOKEN_NUM||') '||
                                                ',NULL)) '||TO_CHAR(l_attr_metadata_table(i).ATTR_NAME);

            -- BUILDING THE UK MATCHING WHERE SEGMENT
            IF (l_attr_metadata_table(i).UNIQUE_KEY_FLAG = 'Y' AND l_attr_group_metadata_obj.MULTI_ROW_CODE='Y') THEN
              l_uk_tmpl_intf_rtcq_where := l_uk_tmpl_intf_rtcq_where||' AND NVL(TEMPLRTCQ.'||l_attr_metadata_table(i).ATTR_NAME||','||G_NULL_TOKEN_NUM||')'||
                                          '= NVL(INTFRTCQ.'||l_attr_metadata_table(i).ATTR_NAME||'(+),'||G_NULL_TOKEN_NUM||' ) ';

              -- Bug 13414358
              /*
              l_ext_templrtcq_uk_join := l_ext_templrtcq_uk_join||' AND NVL(TEMPLRTCQ.'||l_attr_metadata_table(i).ATTR_NAME||','||G_NULL_TOKEN_NUM||')'||
                                          '= NVL(EXT.'||l_attr_metadata_table(i).DATABASE_COLUMN||'(+),'||G_NULL_TOKEN_NUM||')  ';
              */
            END IF;

            --IF THE ATTRIBUTE HAS A UOM ATTACHED THE VALUE SHOULD BE CONVERTED TO USER ENTERED
            --UOM FROM THE BASE UOM BugFix:5704230
            IF(l_attr_metadata_table(i).UNIT_OF_MEASURE_CLASS IS NOT NULL) THEN
               l_num_val_col := l_num_val_col||', '''||l_attr_metadata_table(i).ATTR_NAME||''' '||
                                                  ', ATTR_VALUE_NUM / (SELECT CONVERSION_RATE FROM MTL_UOM_CONVERSIONS '||
                                                                        ' WHERE UOM_CLASS = '''||l_attr_metadata_table(i).UNIT_OF_MEASURE_CLASS||''' '||
                                                                        '   AND UOM_CODE = NVL(ATTR_VALUE_UOM,'''||l_attr_metadata_table(i).UNIT_OF_MEASURE_BASE||''') '||
                                                                        '   AND ROWNUM = 1)';
            END IF;

        ----------------------------------------------------------------------
        -- Add SELECT list attributes that are specific to DATE TIME type   --
        ----------------------------------------------------------------------

        ELSIF (   l_attr_metadata_table(i).DATA_TYPE_CODE = EGO_EXT_FWK_PUB.G_DATE_TIME_DATA_TYPE
               OR l_attr_metadata_table(i).DATA_TYPE_CODE = EGO_EXT_FWK_PUB.G_DATE_DATA_TYPE) THEN
            l_template_table_RTCQ := l_template_table_RTCQ ||
                                   ',  MAX(DECODE(TEMPL.ATTRIBUTE_ID '||
                                                ','||TO_CHAR(l_attr_metadata_table(i).ATTR_ID)||
                                                ','||'TEMPL.ATTRIBUTE_DATE_VALUE'||
                                                ',NULL)) '||TO_CHAR(l_attr_metadata_table(i).ATTR_NAME);
            l_intf_table_RTCQ := l_intf_table_RTCQ ||
                                   ',  MAX(DECODE(INTF.ATTR_INT_NAME '||
                                                ','''||l_attr_metadata_table(i).ATTR_NAME||''' '||
                                                ','||'NVL(INTF.ATTR_VALUE_DATE,'||G_NULL_TOKEN_DATE||')'||
                                                ',NULL)) '||TO_CHAR(l_attr_metadata_table(i).ATTR_NAME);

            -- BUILDING THE UK MATCHING WHERE SEGMENT
            IF (l_attr_metadata_table(i).UNIQUE_KEY_FLAG = 'Y' AND l_attr_group_metadata_obj.MULTI_ROW_CODE='Y') THEN
              l_uk_tmpl_intf_rtcq_where := l_uk_tmpl_intf_rtcq_where||' AND NVL(TEMPLRTCQ.'||l_attr_metadata_table(i).ATTR_NAME||','||G_NULL_TOKEN_DATE||')'||
                                          '= NVL(INTFRTCQ.'||l_attr_metadata_table(i).ATTR_NAME||'(+),'||G_NULL_TOKEN_DATE||' ) ';

              -- Bug 13414358
              /*
              l_ext_templrtcq_uk_join := l_ext_templrtcq_uk_join||' AND NVL(TEMPLRTCQ.'||l_attr_metadata_table(i).ATTR_NAME||','||G_NULL_TOKEN_DATE||')'||
                                          '= NVL(EXT.'||l_attr_metadata_table(i).DATABASE_COLUMN||'(+),'||G_NULL_TOKEN_DATE||')  ';
              */
            END IF;

        ----------------------------------------------------------------------
        -- Add SELECT list attributes that are specific to STRING type      --
        ----------------------------------------------------------------------

        ELSE
            l_template_table_RTCQ := l_template_table_RTCQ ||
                                   ',  MAX(DECODE(TEMPL.ATTRIBUTE_ID '||
                                                ','||TO_CHAR(l_attr_metadata_table(i).ATTR_ID)||
                                                ','||'TEMPL.ATTRIBUTE_STRING_VALUE'||
                                                ',NULL)) '||TO_CHAR(l_attr_metadata_table(i).ATTR_NAME);
            l_intf_table_RTCQ := l_intf_table_RTCQ ||
                                   ',  MAX(DECODE(INTF.ATTR_INT_NAME '||
                                                ','''||l_attr_metadata_table(i).ATTR_NAME||''' '||
                                                ','||'NVL(INTF.ATTR_VALUE_STR,'||G_NULL_TOKEN_STR||')'||
                                                ',NULL)) '||TO_CHAR(l_attr_metadata_table(i).ATTR_NAME);

            -- BUILDING THE UK MATCHING WHERE SEGMENT
            IF (l_attr_metadata_table(i).UNIQUE_KEY_FLAG = 'Y' AND l_attr_group_metadata_obj.MULTI_ROW_CODE='Y') THEN
              l_uk_tmpl_intf_rtcq_where := l_uk_tmpl_intf_rtcq_where||' AND NVL(TEMPLRTCQ.'||l_attr_metadata_table(i).ATTR_NAME||','||G_NULL_TOKEN_STR||')'||
                                          '= NVL(INTFRTCQ.'||l_attr_metadata_table(i).ATTR_NAME||'(+),'||G_NULL_TOKEN_STR||' ) ';

              -- Bug 13414358
              /*
              l_ext_templrtcq_uk_join := l_ext_templrtcq_uk_join||' AND NVL(TEMPLRTCQ.'||l_attr_metadata_table(i).ATTR_NAME||','||G_NULL_TOKEN_STR||')'||
                                          '= NVL(EXT.'||l_attr_metadata_table(i).DATABASE_COLUMN||'(+),'||G_NULL_TOKEN_STR||')  ';
              */
            END IF;

        END IF;

      ------------------------------------------------------------------------
      -- WE DONOT HAVE THE ATTR NAME IN THE TEMPL TABLE SO WE WILL USE THE  --
      -- FOLLOWING DECODE IN THE FINAL QUERY TO AVOID JOINING TO            --
      -- EGO_ATTRS_V                                                        --
      ------------------------------------------------------------------------

      END LOOP;-- Attr loop
code_debug(l_api_name||' Phase 7 After attribute loop ');
code_debug(l_api_name||' l_template_table_RTCQ: '|| l_template_table_RTCQ);
code_debug(l_api_name||' l_intf_table_RTCQ: '|| l_intf_table_RTCQ);
code_debug(l_api_name||' l_uk_tmpl_intf_rtcq_where: '|| l_uk_tmpl_intf_rtcq_where);
-- code_debug(l_api_name||' l_ext_templrtcq_uk_join: '|| l_ext_templrtcq_uk_join); -- Bug 13414358

        IF (l_num_val_col IS NOT NULL) THEN --Bugfix:5704230
           l_num_val_col := ' DECODE(ATTR_INT_NAME '||l_num_val_col||', ATTR_VALUE_NUM )';
        ELSE
           l_num_val_col := ' ATTR_VALUE_NUM';
        END IF;

        -- l_ext_templrtcq_join := l_ext_templrtcq_pk_join || l_ext_templrtcq_uk_join; -- Bug 13414358

        ----------------------------------------------------------------------
        --                        FROM and WHERE clause                       --
        ----------------------------------------------------------------------

        l_template_table_RTCQ := l_template_table_RTCQ ||'  FROM ('||l_template_table_sql||') TEMPL                  '||
                                                         ' WHERE TEMPLATE_ID IN ('||l_template_to_process_list||')   '||
                                                         '   AND CLASSIFICATION_CODE IN ('||l_cc_to_process_list||') '||
                                                         '   AND ATTRIBUTE_GROUP_ID IN ('||l_ag_to_process_list||')  '||
                                                         '   AND ENABLED_FLAG = ''Y''                '||
                                                         ' GROUP BY CLASSIFICATION_CODE, ATTRIBUTE_GROUP_ID, ROW_NUMBER ';

        l_intf_table_RTCQ := l_intf_table_RTCQ || '  FROM '||p_interface_table_name||' INTF '||
                                                  ' WHERE DATA_SET_ID = '||p_data_set_id||' '||
                                                 -- '   AND PROCESS_STATUS = '||p_process_status|| /*Commented to fix Bug#8349855*/
              ' AND REQUEST_ID = '||p_request_id|| /*Added to fix Bug#8349855*/
                                                  '   AND ATTR_GROUP_ID = :ag_id            '||
                                                  '   AND ATTR_GROUP_INT_NAME = :ag_name    '||
                                                  --'   AND '||l_dl_intfrtcq_trtcq_join||'             '||
                                                  'GROUP BY ROW_IDENTIFIER, ATTR_GROUP_ID, '||l_concat_pk_cols;
        IF l_has_data_level_id THEN
          l_intf_table_RTCQ := l_intf_table_RTCQ ||', DATA_LEVEL_ID';
        END IF;
        IF l_dl_col_list IS NOT NULL THEN
          l_intf_table_RTCQ := l_intf_table_RTCQ ||', '||l_dl_col_list;
        END IF;

        l_attr_null_chk_decode := l_attr_null_chk_decode||' chr(0)) IS NULL ';

code_debug(l_api_name||' Phase 8 Complete queries ');
code_debug(l_api_name||' l_template_table_RTCQ: '|| l_template_table_RTCQ);
code_debug(l_api_name||' l_intf_table_RTCQ: '|| l_intf_table_RTCQ);
-- code_debug(l_api_name||' l_ext_templrtcq_join: '|| l_ext_templrtcq_join); -- Bug 13414358
code_debug(l_api_name||' l_attr_null_chk_decode: '|| l_attr_null_chk_decode);

        l_dynamic_sql :=
           ' SELECT MAX(ROW_IDENTIFIER),MAX(TRANSACTION_ID) '||
           '   FROM '||p_interface_table_name||
           '  WHERE DATA_SET_ID = :data_Set_id ';

        BEGIN
           EXECUTE IMMEDIATE l_dynamic_sql
           INTO l_max_row_identifier,l_max_trans_id
           USING p_data_set_id;
        EXCEPTION
           WHEN NO_DATA_FOUND THEN
               l_max_row_identifier := 0;
               l_max_trans_id := 0;
        END;

        IF(l_max_row_identifier IS NULL) THEN
          l_max_row_identifier := 0;
        END IF;

        IF(l_max_trans_id IS NULL) THEN
          l_max_trans_id := 0;
        END IF;

        l_max_trans_id := l_max_trans_id +1;
        l_max_row_identifier := l_max_row_identifier + 1;

        ----------------------------------------------------------------------
        -- Find out weather the ATTR_GROUP_ID column exists in the EXT      --
        -- table or not                                                     --
        ----------------------------------------------------------------------
        BEGIN
          l_dynamic_sql := ' SELECT ATTR_GROUP_ID FROM '||l_ext_vl_name||' WHERE ROWNUM=1 ';
          EXECUTE IMMEDIATE l_dynamic_sql;
          l_ag_id_col_exists := TRUE;
        EXCEPTION
          WHEN OTHERS THEN
            l_ag_id_col_exists := FALSE;
        END;

        -- Bug 13414358 : Start
        /*
        IF(l_ag_id_col_exists) THEN
           l_ag_id_clause :='  AND EXT.ATTR_GROUP_ID(+) = TEMPLRTCQ.ATTRIBUTE_GROUP_ID ';
        ELSE
           l_ag_id_clause :='  AND 1=1 ';
        END IF;
        */
        -- Bug 13414358 : End

        l_rows_to_insert_sql :=
              'SELECT (TRANSACTION_ID+'||l_max_trans_id||') TRANSACTION_ID,PROCESS_STATUS,DATA_SET_ID ,ROW_IDENTIFIER, '||
                    ' ATTR_GROUP_INT_NAME,  ATTR_INT_NAME, ATTR_VALUE_STR,'||l_num_val_col||', ATTR_VALUE_UOM, ATTR_VALUE_DATE, '||
                    ' ATTR_DISP_VALUE, TRANSACTION_TYPE, ATTR_GROUP_ID, REQUEST_ID, PROGRAM_APPLICATION_ID, PROGRAM_ID, '||
                    ' PROGRAM_UPDATE_DATE,CREATED_BY, CREATION_DATE, LAST_UPDATED_BY, LAST_UPDATE_DATE, '||
                    ' LAST_UPDATE_LOGIN,  '||l_concat_pk_cols||', ATTR_GROUP_TYPE ';

        IF l_has_data_level_id THEN
          l_rows_to_insert_sql := l_rows_to_insert_sql ||', DATA_LEVEL_ID ';
        END IF;

        IF(l_dl_col_list IS NOT NULL) THEN
          l_rows_to_insert_sql := l_rows_to_insert_sql ||','||l_dl_col_list;
        END IF;

        l_rows_to_insert_sql := l_rows_to_insert_sql||
              ' FROM '||
              '(SELECT ROWNUM TRANSACTION_ID, '||
                   p_process_status||' PROCESS_STATUS, '||
                   p_data_set_id||' DATA_SET_ID, '||
                   ' NVL(INTFRTCQ.ROW_IDENTIFIER,'||l_max_row_identifier||'+TEMPLRTCQ.ENTITY_ROWID) ROW_IDENTIFIER, '||
                   ''''||l_attr_group_metadata_obj.ATTR_GROUP_NAME||'''  ATTR_GROUP_INT_NAME, '||
                   ' ATTRSV.ATTR_NAME ATTR_INT_NAME, '||
                   ' NVL(TEMPL.ATTRIBUTE_STRING_VALUE,TEMPL.ATTRIBUTE_TRANSLATED_VALUE) ATTR_VALUE_STR , '||
                   ' TEMPL.ATTRIBUTE_NUMBER_VALUE ATTR_VALUE_NUM , '||
                   ' TEMPL.ATTRIBUTE_UOM_CODE ATTR_VALUE_UOM , '||
                   ' TEMPL.ATTRIBUTE_DATE_VALUE ATTR_VALUE_DATE , '||
                   ' NULL ATTR_DISP_VALUE, '||
                   -- Bug 13414358 : Start
                   /* Instead of inserting transaction type as CREATE/UPDATE insert as SYNC directly, so that the later part of the
                      code will take care of resolving the TRANSACTION type. */
                   -- ' NVL(INTFRTCQ.TRANSACTION_TYPE,NVL2(EXT.EXTENSION_ID,''UPDATE'',''CREATE'')) TRANSACTION_TYPE, ';
                   ' NVL(INTFRTCQ.TRANSACTION_TYPE,'''||EGO_USER_ATTRS_DATA_PVT.G_SYNC_MODE||''') TRANSACTION_TYPE, ';
                   -- Bug 13414358 : End
        IF l_has_data_level_id THEN
          l_rows_to_insert_sql := l_rows_to_insert_sql ||' TEMPLRTCQ.DATA_LEVEL_ID, ';
          IF l_dl_col_templrtcq_list IS NOT NULL THEN
            l_rows_to_insert_sql := l_rows_to_insert_sql ||l_dl_col_templrtcq_list||', ';
          END IF;
        ELSE
          IF(l_dl_col_decode_list IS NOT NULL)THEN   --the data level joins bugfix:5401212
            l_rows_to_insert_sql := l_rows_to_insert_sql||l_dl_col_decode_list||', ';
          END IF;
        END IF;

        l_rows_to_insert_sql := l_rows_to_insert_sql||
                   l_attr_group_metadata_obj.ATTR_GROUP_ID||' ATTR_GROUP_ID, '||
                   p_request_id||' REQUEST_ID, '||
                   p_program_application_id||' PROGRAM_APPLICATION_ID, '||
                   p_program_id||' PROGRAM_ID, '||
                   'SYSDATE  PROGRAM_UPDATE_DATE, '||
                   p_current_user_party_id||' CREATED_BY, '||
                   'SYSDATE CREATION_DATE, '||
                   p_current_user_party_id||' LAST_UPDATED_BY, '||
                   'SYSDATE LAST_UPDATE_DATE, '||
                   p_current_user_party_id||'  LAST_UPDATE_LOGIN, '||
                   l_concat_pk_cols_entities||' '||
                   ''''||p_attr_group_type||'''  ATTR_GROUP_TYPE '||
              ' FROM ('||l_intf_table_RTCQ||') INTFRTCQ, '||
                  '   ('||l_template_table_sql||')        TEMPL, '||
                  '   EGO_ATTRS_V                 ATTRSV, '||
                  ' (SELECT ROWNUM ENTITY_ROWID, TEMPLRTCQ.* FROM  '||
                  ' (SELECT * FROM ('||p_target_entity_sql||')   ENTITIES, '||
                  '                ('||l_template_table_RTCQ||')   TEMPLRTCQ '||
                  '   WHERE TEMPLRTCQ.TEMPLATE_ID1 = ENTITIES.TEMPLATE_ID '||
                  '     AND TEMPLRTCQ.CLASSIFICATION_CODE1 = ENTITIES.'||l_class_code_column_name  ||
                  -- Bug 13414358 : Start
                  /* Removing the join to the view l_ext_vl_name, as we do not need to resolve the transaction type at this point. */
                  --' ) TEMPLRTCQ) TEMPLRTCQ, '||
                  --' '||l_ext_vl_name||' EXT '||
                  ' ) TEMPLRTCQ) TEMPLRTCQ '||
                  -- Bug 13414358 : Start
              'WHERE 1 = 1 '||
              -- l_ag_id_clause||' '|| -- Bug 13414358
              '  AND '||l_dl_ext_trtcq_join||' AND '||l_dl_intfrtcq_trtcq_join||--the data level joins bugfix:5401212
              -- ' AND '|| -- Bug 13414358
              -- l_ext_templrtcq_join||' '|| -- Bug 13414358
              ' AND TEMPL.ATTRIBUTE_GROUP_ID = '||l_attr_group_metadata_obj.ATTR_GROUP_ID||' '||
              ' AND TEMPL.CLASSIFICATION_CODE = TEMPLRTCQ.'||l_class_code_column_name||' '||
              ' AND TEMPL.TEMPLATE_ID = TEMPLRTCQ.TEMPLATE_ID '||
              ' AND TEMPL.ATTRIBUTE_GROUP_ID = TEMPLRTCQ.ATTRIBUTE_GROUP_ID '||
              ' AND TEMPL.ENABLED_FLAG = ''Y'' '||
              ' AND TEMPL.ROW_NUMBER = TEMPLRTCQ.ROW_NUMBER '||
              ' AND TEMPLRTCQ.'||l_class_code_column_name||'= INTFRTCQ.'||l_class_code_column_name||'(+)'||
                ' '||l_pk_col_where_ent_uartcq||' '||
              ' AND '||l_uk_tmpl_intf_rtcq_where||' '||--for unique key joi in intf and templ
              ' AND ATTRSV.ATTR_ID = TEMPL.ATTRIBUTE_ID '||
              l_attr_null_chk_decode||' ';
        IF l_has_data_level_id THEN
          l_rows_to_insert_sql := l_rows_to_insert_sql ||' AND EXISTS (SELECT 1 FROM ego_attr_group_dl WHERE attr_group_id = :ag_id2 AND data_level_id = TEMPLRTCQ.data_level_id) ';
        END IF;
        l_rows_to_insert_sql := l_rows_to_insert_sql || ')';

        IF l_has_data_level_id THEN
          l_temp := ', DATA_LEVEL_ID ';
        ELSE
          l_temp := ' ';
        END IF;
        IF(l_dl_col_list IS NOT NULL) THEN
          l_temp := l_temp||','||l_dl_col_list;
        END IF;

        ----------------------------------------------------------------------
        -- Build the INSERT statement to insert the attribute values into   --
        -- the interface table                                              --
        ----------------------------------------------------------------------

        l_rows_to_insert_sql := ' INSERT INTO '||p_interface_table_name||' ( '||
              ' TRANSACTION_ID,PROCESS_STATUS,DATA_SET_ID ,ROW_IDENTIFIER,ATTR_GROUP_INT_NAME, '||
              ' ATTR_INT_NAME, ATTR_VALUE_STR,ATTR_VALUE_NUM,ATTR_VALUE_UOM,ATTR_VALUE_DATE, '||
              ' ATTR_DISP_VALUE, TRANSACTION_TYPE, ATTR_GROUP_ID, REQUEST_ID, PROGRAM_APPLICATION_ID, PROGRAM_ID, '||
              ' PROGRAM_UPDATE_DATE,CREATED_BY, CREATION_DATE, LAST_UPDATED_BY, LAST_UPDATE_DATE, '||
              ' LAST_UPDATE_LOGIN,  '||l_concat_pk_cols||', ATTR_GROUP_TYPE  '||l_temp||' ) '||
              l_rows_to_insert_sql;

code_debug(l_api_name||' Phase 8 SQL to insert ');
code_debug(l_api_name||'  '|| l_rows_to_insert_sql);

              ----------------------------------------------------------------
              -- Finally, execute the query to insert the attribute values  --
              -- into the interface table.                                  --
              ----------------------------------------------------------------
              IF l_has_data_level_id THEN
code_debug(l_api_name||' binds:  ATTR_GROUP_ID: '||l_attr_group_metadata_obj.ATTR_GROUP_ID||' ATTR_GROUP_NAME: '||l_attr_group_metadata_obj.ATTR_GROUP_NAME||' ATTR_GROUP_ID2 '||l_attr_group_metadata_obj.ATTR_GROUP_ID);
                EXECUTE IMMEDIATE l_rows_to_insert_sql
                USING l_attr_group_metadata_obj.ATTR_GROUP_ID,
                      l_attr_group_metadata_obj.ATTR_GROUP_NAME,
                      l_attr_group_metadata_obj.ATTR_GROUP_ID;
              ELSE
code_debug(l_api_name||' binds:  ATTR_GROUP_ID: '||l_attr_group_metadata_obj.ATTR_GROUP_ID||' ATTR_GROUP_NAME: '||l_attr_group_metadata_obj.ATTR_GROUP_NAME);
                EXECUTE IMMEDIATE l_rows_to_insert_sql
                USING l_attr_group_metadata_obj.ATTR_GROUP_ID,
                      l_attr_group_metadata_obj.ATTR_GROUP_NAME;
              END IF;
    END LOOP;
 END IF;
 x_return_status := FND_API.G_RET_STS_SUCCESS;
 code_debug(l_api_name||' Done ',0);

 EXCEPTION
  WHEN G_NO_ROWS_IN_INTF_TABLE THEN
    code_debug(l_api_name||' Exception: '||SQLERRM,0);
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    x_msg_data := 'Executing - '||G_PKG_NAME||'.'||l_api_name||' - '||SQLERRM;

END Apply_Template_On_Intf_Table;

------------------------------------------------------------------

FUNCTION Get_Datatype_Error_Val (
        p_value_to_convert             IN   VARCHAR2
       ,p_datatype                     IN   VARCHAR2
) RETURN NUMBER
IS
     l_num_value                       NUMBER;
     l_date_value                      DATE;
     l_error_code                      NUMBER;
     l_dynamic_sql                     VARCHAR2(200);
     l_formated_String                 VARCHAR2(500);
BEGIN

    IF (p_datatype =  EGO_EXT_FWK_PUB.G_DATE_DATA_TYPE ) THEN
      l_error_code := G_PS_INVALID_DATE_DATA ;
      IF (INSTR(p_value_to_convert,'$SYSDATE$') > 0 ) THEN
        l_formated_string := TRIM(REPLACE(p_value_to_convert, '$'));
        l_dynamic_sql := 'SELECT TO_CHAR('||l_formated_string||', '''||
                       EGO_USER_ATTRS_COMMON_PVT.G_DATE_FORMAT||''') FROM DUAL';
        EXECUTE IMMEDIATE l_dynamic_sql INTO l_formated_string;
        l_date_value := TO_DATE(l_formated_string,EGO_USER_ATTRS_COMMON_PVT.G_DATE_FORMAT);
      ELSE
        l_date_value := TO_DATE(p_value_to_convert, EGO_USER_ATTRS_COMMON_PVT.G_DATE_FORMAT);
      END IF;

    ELSIF (p_datatype = EGO_EXT_FWK_PUB.G_DATE_TIME_DATA_TYPE) THEN
      l_error_code := G_PS_INVALID_DATE_TIME_DATA ;
      IF (INSTR(p_value_to_convert,'$SYSDATE$') > 0 ) THEN
        l_formated_string := TRIM(REPLACE(p_value_to_convert, '$'));
        l_dynamic_sql := 'SELECT TO_CHAR('||l_formated_string||', '''||
                       EGO_USER_ATTRS_COMMON_PVT.G_DATE_FORMAT||''') FROM DUAL';
        EXECUTE IMMEDIATE l_dynamic_sql INTO l_formated_string;
        l_date_value := TO_DATE(l_formated_string,EGO_USER_ATTRS_COMMON_PVT.G_DATE_FORMAT);
      ELSE
        l_date_value := TO_DATE(p_value_to_convert,EGO_USER_ATTRS_COMMON_PVT.G_DATE_FORMAT);
      END IF;

    ELSIF (p_datatype =  EGO_EXT_FWK_PUB.G_NUMBER_DATA_TYPE) THEN
      l_error_code := G_PS_INVALID_NUMBER_DATA ;
      l_num_value := TO_NUMBER(p_value_to_convert);
    END IF;

    RETURN 0;

EXCEPTION
  WHEN OTHERS THEN
       RETURN l_error_code;

END Get_Datatype_Error_Val;

---------------------------------------------------------------------

FUNCTION Get_Date (
  p_date                      IN   VARCHAR2
 ,p_format                    IN   VARCHAR2 DEFAULT NULL
) RETURN DATE
IS
     l_date                           DATE;
     l_dynamic_sql                    VARCHAR2(200);
     l_formated_string                VARCHAR2(500);
BEGIN

    IF (INSTR(UPPER(p_date),'$SYSDATE$') > 0 ) THEN
      l_formated_string := TRIM(REPLACE(p_date, '$'));
      l_dynamic_sql := 'SELECT TO_CHAR('||l_formated_string||', '''||
                     'YYYY-MM-DD HH24:MI:SS'||''') FROM DUAL';
      EXECUTE IMMEDIATE l_dynamic_sql INTO l_formated_string;
      l_date := TO_DATE(l_formated_string,EGO_USER_ATTRS_COMMON_PVT.G_DATE_FORMAT);
      RETURN l_date;
    ELSE
      IF (p_format IS NOT NULL ) THEN
        l_date := TO_DATE(p_date, p_format);
      ELSE
        l_date := TO_DATE(p_date,EGO_USER_ATTRS_COMMON_PVT.G_DATE_FORMAT);
      END IF;
      RETURN l_date;
    END IF;
    RETURN l_date;

EXCEPTION
  WHEN OTHERS THEN
       RETURN NULL;
END Get_Date;

-------------------------------------------------------------------

---------------------------------------------------------------------
--NOTE: the function would return a 0 even if the conversion to
--      appropriate datatype throws an exception.
---------------------------------------------------------------------

FUNCTION Get_Max_Min_Error_Val (
        p_value_to_check               IN   VARCHAR2
       ,p_datatype                     IN   VARCHAR2
       ,p_min_value                    IN   VARCHAR2
       ,p_max_value                    IN   VARCHAR2
) RETURN NUMBER
IS
     l_num_value                       NUMBER;
     l_date_value                      DATE;
     l_error_code                      NUMBER;
     l_max_date                        DATE;
     l_min_date                        DATE;
     l_index_min                       NUMBER;
     l_index_max                       NUMBER;
     l_dynamic_sql                     VARCHAR2(200);
     l_formated_string                 VARCHAR2(500);
BEGIN
/*
   the conversion of max min date fails since the format they are in is 2004-07-01 00:00:00.0
   this is the format in which the date string we get from the Value set, since this format
   for date is not supported in 8i I
*/
    IF (p_datatype =  EGO_EXT_FWK_PUB.G_DATE_DATA_TYPE OR  p_datatype = EGO_EXT_FWK_PUB.G_DATE_TIME_DATA_TYPE) THEN

      IF (INSTR(p_value_to_check,'$SYSDATE$') > 0 ) THEN
        l_formated_string := TRIM(REPLACE(p_value_to_check, '$'));
        l_dynamic_sql := 'SELECT TO_CHAR('||l_formated_string||', '''||
                         EGO_USER_ATTRS_COMMON_PVT.G_DATE_FORMAT||''') FROM DUAL';--'SYYYY-MM-DD HH24:MI:SS'
        EXECUTE IMMEDIATE l_dynamic_sql INTO l_formated_string;
        l_date_value := TO_DATE(l_formated_string,EGO_USER_ATTRS_COMMON_PVT.G_DATE_FORMAT);--'SYYYY-MM-DD HH24:MI:SS'
      ELSE
        l_date_value := TO_DATE(p_value_to_check,EGO_USER_ATTRS_COMMON_PVT.G_DATE_FORMAT);
      END IF;

      IF (INSTR(p_max_value,'$SYSDATE$') > 0 ) THEN
        l_formated_string := TRIM(REPLACE(p_max_value, '$'));
        l_dynamic_sql := 'SELECT TO_CHAR('||l_formated_string||', '''||
                         EGO_USER_ATTRS_COMMON_PVT.G_DATE_FORMAT||''') FROM DUAL';--'SYYYY-MM-DD HH24:MI:SS'
        EXECUTE IMMEDIATE l_dynamic_sql INTO l_formated_string;
        l_max_date := TO_DATE(l_formated_string,EGO_USER_ATTRS_COMMON_PVT.G_DATE_FORMAT);--'YYYY-MM-DD HH24:MI:SS'
      ELSE
        l_index_max := INSTR(p_max_value,'.');
        IF ( l_index_max = 0 ) THEN
          l_max_date := TO_DATE(p_max_value,EGO_USER_ATTRS_COMMON_PVT.G_DATE_FORMAT);--'SYYYY-MM-DD HH24:MI:SS'
        ELSE
          l_max_date := TO_DATE(SUBSTR(p_max_value,1,l_index_max-1),EGO_USER_ATTRS_COMMON_PVT.G_DATE_FORMAT);--'SYYYY-MM-DD HH24:MI:SS'
        END IF;
     END IF;


      IF (INSTR(p_min_value,'$SYSDATE$') > 0 ) THEN
        l_formated_string := TRIM(REPLACE(p_min_value, '$'));
        l_dynamic_sql := 'SELECT TO_CHAR('||l_formated_string||', '''||
                         EGO_USER_ATTRS_COMMON_PVT.G_DATE_FORMAT||''') FROM DUAL';
        EXECUTE IMMEDIATE l_dynamic_sql INTO l_formated_string;
        l_min_date := TO_DATE(l_formated_string,EGO_USER_ATTRS_COMMON_PVT.G_DATE_FORMAT);
      ELSE
        l_index_min := INSTR(p_min_value,'.');
        IF (l_index_min = 0) THEN
          l_min_date := TO_DATE(p_min_value,EGO_USER_ATTRS_COMMON_PVT.G_DATE_FORMAT);
        ELSE
          l_min_date := TO_DATE(SUBSTR(p_min_value,1,l_index_min-1),EGO_USER_ATTRS_COMMON_PVT.G_DATE_FORMAT);
        END IF;
      END IF;

      IF (l_date_value > NVL(l_max_date, l_date_value) ) THEN
        RETURN G_PS_MAX_VAL_VIOLATION;
      END IF;

      IF ( l_date_value < NVL(l_min_date, l_date_value) ) THEN
        RETURN G_PS_MIN_VAL_VIOLATION;
      END IF;

    ELSIF (p_datatype =  EGO_EXT_FWK_PUB.G_NUMBER_DATA_TYPE ) THEN
      l_num_value := TO_NUMBER(p_value_to_check);

      IF (l_num_value > NVL(TO_NUMBER(p_max_value), l_num_value) ) THEN
        IF p_min_value IS NULL THEN
          RETURN G_PS_MAX_VAL_VIOLATION;
        ELSE
          RETURN G_PS_VAL_RANGE_VIOLATION;
        END IF;
      END IF;

      IF (l_num_value < NVL(TO_NUMBER(p_min_value), l_num_value) ) THEN
        IF p_max_value IS NULL THEN
          RETURN G_PS_MIN_VAL_VIOLATION;
        ELSE
          RETURN G_PS_VAL_RANGE_VIOLATION;
        END IF;
      END IF;

    END IF;

    RETURN 0;

EXCEPTION
  WHEN OTHERS THEN
       RETURN 0;
END Get_Max_Min_Error_Val;


-------------------------------------------------------------------------------------------------------
--API Name    : Insert_Default_Val_Rows
--Description : This API would insert rows with default values for attributes in attribute
--              groups not present in the interface table. Here only single row attr groups
--              with no required attrs are processed.

--parameters :  p_api_version       : Api version
--parameters :  p_application_id    : Application Id
--parameters :  p_attr_group_type   : The type of attr groups to be processed for the given
--                                     data set id.
--parameters :  p_object_name       : Object name.
--parameters :  p_interface_table_name : Interface table name for the UDA.
--parameters :  p_data_set_id       : Data set to be processed.
--parameters :  p_target_entity_sql : This SQL should return all the entities to be processed,
--                                     it should give the pk's, class code and data level of
--                                     the entity. Sample SQL:
--                                     'SELECT INVENTORY_ITEM_ID,
--                                             ORGANIZATION_ID,
--                                             ITEM_CATALOG_GROUP_ID,
--                                             DATA_LEVEL_ID,
--                                             PK1_VALUE,
--                                             PK2_VALUE,
--                                             REVISION_ID
--                                             FROM MTL_SYSTEM_ITEMS_INTERFACE
--                                            WHERE SET_PROCESS_ID = 2910
--                                              AND PROCESS_FLAG = 7'

--parameters :  p_additional_class_Code_query : This sQL should return all the classification
--                                     codes for which attr group associations are to be
--                                     considered, for example this can give all the parent
--                                     class codes for an entity. Sampl SQL:
--                                     SELECT CHILD_CATALOG_GROUP_ID
--                                       FROM EGO_ITEM_CAT_DENORM_HIER
--                                      WHERE PARENT_CATALOG_GROUP_ID = ENTITY.ITEM_CATALOG_GROUP_ID
--parameters :  p_commit            : Should the changes made be commited in the API
------------------------------------------------------------------------------------------


PROCEDURE Insert_Default_Val_Rows (
         p_api_version                   IN   NUMBER
        ,p_application_id                IN   NUMBER
        ,p_attr_group_type               IN   VARCHAR2
        ,p_object_name                   IN   VARCHAR2
        ,p_interface_table_name          IN   VARCHAR2
        ,p_data_set_id                   IN   NUMBER
        ,p_target_entity_sql             IN   VARCHAR2
        ,p_attr_groups_to_exclude        IN   VARCHAR2   DEFAULT NULL
        ,p_additional_class_Code_query   IN   VARCHAR2   DEFAULT NULL
        ,p_extra_column_names            IN   VARCHAr2   DEFAULT NULL
        ,p_extra_column_values           IN   VARCHAR2   DEFAULT NULL
        ,p_commit                        IN   VARCHAR2   DEFAULT FND_API.G_FALSE
        ,p_process_status                IN   NUMBER    DEFAULT G_PS_IN_PROCESS
        /* Begin Bug 13729672 */
        ,p_comp_seq_id                   IN   NUMBER DEFAULT NULL
        ,p_bill_seq_id                   IN   NUMBER DEFAULT NULL
        ,p_structure_type_id             IN   NUMBER DEFAULT NULL
        ,p_data_level_column             IN   VARCHAR2 DEFAULT NULL
        ,p_datalevel_id                  IN   NUMBER DEFAULT NULL
        ,p_context_id                    IN   NUMBER DEFAULT NULL
        ,p_transaction_id                IN   NUMBER DEFAULT NULL
        /* End Bug 13729672 */
        ,x_return_status                 OUT NOCOPY VARCHAR2
        ,x_msg_data                      OUT NOCOPY VARCHAR2
                                  )
IS

    l_api_name                          VARCHAR2(30)  := 'Insert_Default_Val_Rows';
    l_pk1_column_name                   VARCHAR2(30);
    l_pk2_column_name                   VARCHAR2(30);
    l_pk3_column_name                   VARCHAR2(30);
    l_pk4_column_name                   VARCHAR2(30);
    l_pk5_column_name                   VARCHAR2(30);
    l_pk1_column_type                   VARCHAR2(8);
    l_pk2_column_type                   VARCHAR2(8);
    l_pk3_column_type                   VARCHAR2(8);
    l_pk4_column_type                   VARCHAR2(8);
    l_pk5_column_type                   VARCHAR2(8);

    l_num_data_level_columns            NUMBER := 0;
    l_max_row_id                        NUMBER := 0;

    l_data_level_none                   VARCHAR2(30);
    l_data_level_column_1               VARCHAR2(150);
    l_data_level_column_2               VARCHAR2(150);
    l_data_level_column_3               VARCHAR2(150);

    l_class_code_column_name            VARCHAR2(30);
    l_dynamic_sql                       VARCHAR2(10000);
    l_object_id                         NUMBER;

    l_ag_presence_chk_sql               VARCHAR2(5000);
    l_additional_class_Code_query       VARCHAR2(1000);
    l_all_dl_cols                       VARCHAR2(500);
    l_pk_cc_select_list                 VARCHAR2(500);
    l_pk_cc_dl_col_list                 VARCHAR2(300);
    l_inner_pk_cc_dl_col_list           VARCHAR2(400);
    l_col_to_insert_list                VARCHAR2(800);
    l_attr_groups_to_exclude            VARCHAR2(2000);

    l_has_data_level_id    BOOLEAN := FALSE;
    l_dummy_number         NUMBER;
    l_ext_b_table_name     VARCHAR2(100);
    wierd_constant                      VARCHAR2(100);
    l_list_of_dl_for_ag_type      EGO_DATA_LEVEL_METADATA_TABLE;


    CURSOR data_level_cols_cursor (cp_application_id  IN NUMBER
                                  ,cp_attr_group_type IN VARCHAR2)
    IS
    SELECT data_level_id
          ,data_level_name
          ,pk1_column_name
          ,pk1_column_type
          ,pk2_column_name
          ,pk2_column_type
          ,pk3_column_name
          ,pk3_column_type
          ,pk4_column_name
          ,pk4_column_type
          ,pk5_column_name
          ,pk5_column_type
      FROM EGO_DATA_LEVEL_B
     WHERE application_id  = cp_application_id
       AND attr_group_type = cp_attr_group_type
  ORDER BY data_level_id;

  -- Fix for bug#9336604
  l_schema             VARCHAR2(30);
  l_status             VARCHAR2(1);
  l_industry           VARCHAR2(1);

BEGIN

  code_debug (l_api_name ||' Started with params ');
  code_debug (l_api_name ||' p_attr_group_type               '||p_attr_group_type             );
  code_debug (l_api_name ||' p_object_name                   '||p_object_name                 );
  code_debug (l_api_name ||' p_interface_table_name          '||p_interface_table_name        );
  code_debug (l_api_name ||' p_data_set_id                   '||p_data_set_id                 );
  code_debug (l_api_name ||' p_target_entity_sql             '||p_target_entity_sql           );
  code_debug (l_api_name ||' p_attr_groups_to_exclude        '||p_attr_groups_to_exclude      );
  code_debug (l_api_name ||' p_additional_class_Code_query   '||p_additional_class_Code_query );
  code_debug (l_api_name ||' p_extra_column_names            '||p_extra_column_names          );
  code_debug (l_api_name ||' p_extra_column_values           '||p_extra_column_values         );

  l_dynamic_sql := ' SELECT count(*) FROM ( '||p_target_entity_sql||') ';
  /*Bug 13729672*/
  IF p_datalevel_id IS NULL THEN
    EXECUTE IMMEDIATE l_dynamic_sql INTO l_dummy_number;
  ELSE
    EXECUTE IMMEDIATE l_dynamic_sql INTO l_dummy_number
    USING p_comp_seq_id,
      p_bill_seq_id,
      p_structure_type_id,
      p_data_level_column,
      p_datalevel_id,
      p_context_id,
      p_transaction_id;
  END IF;

  code_debug (l_api_name ||' no records to be processed '||l_dummy_number);
  IF l_dummy_number = 0 THEN
    code_debug (l_api_name ||' returning as there are no records to process ');
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    RETURN;
  END IF;

  -----------------------------------------
  -- Fetch the PK column names and data  --
  -- types for the passed-in object name --
  -----------------------------------------
  SELECT pk1_column_name, pk1_column_type,
         pk2_column_name, pk2_column_type,
         pk3_column_name, pk3_column_type,
         pk4_column_name, pk4_column_type,
         pk5_column_name, pk5_column_type
    INTO l_pk1_column_name, l_pk1_column_type,
         l_pk2_column_name, l_pk2_column_type,
         l_pk3_column_name, l_pk3_column_type,
         l_pk4_column_name, l_pk4_column_type,
         l_pk5_column_name, l_pk5_column_type
    FROM FND_OBJECTS
   WHERE OBJ_NAME = p_object_name;

  SELECT application_table_name
    INTO l_ext_b_table_name
    FROM FND_DESCRIPTIVE_FLEXS
   WHERE application_id = p_application_id
     AND descriptive_flexfield_name = p_attr_group_type;

  l_has_data_level_id := FND_API.TO_BOOLEAN(
               EGO_USER_ATTRS_COMMON_PVT.has_column_in_table(
                                p_table_name  => l_ext_b_table_name
                               ,p_column_name => 'DATA_LEVEL_ID'
                                                            )
                                           );
  IF l_has_data_level_id THEN
    code_debug (l_api_name ||' data level id IS present ');
  ELSE
    code_debug (l_api_name ||' data level id is NOT present ');
  END IF;
  ------------------------------------------------------------
  -- Geting the classification code for the given object    --
  ------------------------------------------------------------

  SELECT CLASSIFICATION_COL_NAME
    INTO l_class_code_column_name
    FROM EGO_FND_OBJECTS_EXT
   WHERE OBJECT_NAME = p_object_name;

  ----------------------------------------------------------
  -- Building the SQL                                     --
  ----------------------------------------------------------

  l_pk_cc_select_list := ' , ENTITYAG_TBL.'|| l_class_code_column_name;
  l_pk_cc_dl_col_list := ' , '||l_class_code_column_name;
  l_inner_pk_cc_dl_col_list := ' , ENTITY.'||l_class_code_column_name;
    /*Added Hint to improve performance for bug 8598093,9660659  -Added space*/
   l_ag_presence_chk_sql := ' SELECT /*+ index(uai EGO_ITM_USR_ATTR_INTRFC_N2  ) */ 1 FROM '||p_interface_table_name||'  UAI                        '||
                           ' WHERE NVL(UAI.ATTR_GROUP_ID,ATTR_GROUP_TBL.ATTR_GROUP_ID) = ATTR_GROUP_TBL.ATTR_GROUP_ID'||
                           '   AND NVL(UAI.ATTR_GROUP_TYPE,ATTR_GROUP_TBL.DESCRIPTIVE_FLEXFIELD_NAME) = ATTR_GROUP_TBL.DESCRIPTIVE_FLEXFIELD_NAME'||
                             ' AND UAI.DATA_SET_ID = :data_set_id '||
                             ' AND UAI.ATTR_GROUP_INT_NAME = ATTR_GROUP_TBL.DESCRIPTIVE_FLEX_CONTEXT_CODE ';
code_debug(l_api_name ||' phase 1 ');
code_debug(l_api_name ||' l_pk_cc_select_list '||l_pk_cc_select_list);
code_debug(l_api_name ||' l_pk_cc_dl_col_list '|| l_pk_cc_dl_col_list );
code_debug(l_api_name ||' l_inner_pk_cc_dl_col_list '|| l_inner_pk_cc_dl_col_list );
code_debug(l_api_name ||' l_ag_presence_chk_sql '|| l_ag_presence_chk_sql );

  IF (l_pk1_column_name IS NOT NULL) THEN
     l_ag_presence_chk_sql := l_ag_presence_chk_sql || ' AND  UAI.'||l_pk1_column_name||' = ENTITY.'||l_pk1_column_name;
     l_pk_cc_select_list := l_pk_cc_select_list || ',ENTITYAG_TBL.'||l_pk1_column_name;
     l_pk_cc_dl_col_list := l_pk_cc_dl_col_list || ',' || l_pk1_column_name;
     l_inner_pk_cc_dl_col_list := l_inner_pk_cc_dl_col_list || ', ENTITY.'||l_pk1_column_name;
  END IF;
  IF (l_pk2_column_name IS NOT NULL) THEN
     l_ag_presence_chk_sql := l_ag_presence_chk_sql || ' AND  UAI.'||l_pk2_column_name||' = ENTITY.'||l_pk2_column_name;
     l_pk_cc_select_list := l_pk_cc_select_list || ',ENTITYAG_TBL.'||l_pk2_column_name;
     l_pk_cc_dl_col_list := l_pk_cc_dl_col_list || ',' || l_pk2_column_name;
     l_inner_pk_cc_dl_col_list := l_inner_pk_cc_dl_col_list || ', ENTITY.'||l_pk2_column_name;
  END IF;
  IF (l_pk3_column_name IS NOT NULL) THEN
     l_ag_presence_chk_sql := l_ag_presence_chk_sql || ' AND  UAI.'||l_pk3_column_name||' = ENTITY.'||l_pk3_column_name;
     l_pk_cc_select_list := l_pk_cc_select_list || ',ENTITYAG_TBL.'||l_pk3_column_name;
     l_pk_cc_dl_col_list := l_pk_cc_dl_col_list || ',' || l_pk3_column_name;
     l_inner_pk_cc_dl_col_list := l_inner_pk_cc_dl_col_list || ', ENTITY.'||l_pk3_column_name;
  END IF;
  IF (l_pk4_column_name IS NOT NULL) THEN
     l_ag_presence_chk_sql := l_ag_presence_chk_sql || ' AND  UAI.'||l_pk4_column_name||' = ENTITY.'||l_pk4_column_name;
     l_pk_cc_select_list := l_pk_cc_select_list || ',ENTITYAG_TBL.'||l_pk4_column_name;
     l_pk_cc_dl_col_list := l_pk_cc_dl_col_list || ',' || l_pk4_column_name;
     l_inner_pk_cc_dl_col_list := l_inner_pk_cc_dl_col_list || ', ENTITY.'||l_pk4_column_name;
  END IF;
  IF (l_pk5_column_name IS NOT NULL) THEN
     l_ag_presence_chk_sql := l_ag_presence_chk_sql || ' AND  UAI.'||l_pk5_column_name||' = ENTITY.'||l_pk5_column_name;
     l_pk_cc_select_list := l_pk_cc_select_list || ',ENTITYAG_TBL.'||l_pk5_column_name;
     l_pk_cc_dl_col_list := l_pk_cc_dl_col_list || ',' || l_pk5_column_name;
     l_inner_pk_cc_dl_col_list := l_inner_pk_cc_dl_col_list || ', ENTITY.'||l_pk5_column_name;
  END IF;



  l_list_of_dl_for_ag_type := EGO_USER_ATTRS_COMMON_PVT.Get_Data_Levels_For_AGType( p_application_id  => p_application_id
                                                                                   ,p_attr_group_type => p_attr_group_type);
  IF(l_has_data_level_id) THEN
    l_ag_presence_chk_sql := l_ag_presence_chk_sql || ' AND NVL(UAI.DATA_LEVEL_ID,'||G_NULL_TOKEN_NUM||') '||
                                                      '   = NVL(ENTITY.DATA_LEVEL_ID,'||G_NULL_TOKEN_NUM||')';

    FOR i IN l_list_of_dl_for_ag_type.FIRST .. l_list_of_dl_for_ag_type.LAST
    LOOP

       IF (l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME1 IS NOT NULL AND l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME1 <> 'NONE'
          AND INSTR(l_ag_presence_chk_sql,l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME1) = 0) THEN

               IF(l_list_of_dl_for_ag_type(i).PK_COLUMN_TYPE1 = 'NUMBER') THEN
                 wierd_constant := G_NULL_TOKEN_NUM;
               ELSIF (l_list_of_dl_for_ag_type(i).PK_COLUMN_TYPE1 = 'DATE' OR l_list_of_dl_for_ag_type(i).PK_COLUMN_TYPE1 = 'DATETIME') THEN
                 wierd_constant := G_NULL_TOKEN_DATE;
               ELSE
                 wierd_constant := G_NULL_TOKEN_STR;
               END IF;

               l_ag_presence_chk_sql := l_ag_presence_chk_sql || ' AND NVL(UAI.'||l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME1||','||wierd_constant||') '||
                                                                 '   = NVL(ENTITY.'||l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME1||','||wierd_constant||')';
       END IF;
       IF (l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME2 IS NOT NULL AND l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME2 <> 'NONE'
          AND INSTR(l_ag_presence_chk_sql,l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME2) = 0) THEN
               IF(l_list_of_dl_for_ag_type(i).PK_COLUMN_TYPE2 = 'NUMBER') THEN
                 wierd_constant := G_NULL_TOKEN_NUM;
               ELSIF (l_list_of_dl_for_ag_type(i).PK_COLUMN_TYPE2 = 'DATE' OR l_list_of_dl_for_ag_type(i).PK_COLUMN_TYPE2 = 'DATETIME') THEN
                 wierd_constant := G_NULL_TOKEN_DATE;
               ELSE
                 wierd_constant := G_NULL_TOKEN_STR;
               END IF;
               l_ag_presence_chk_sql := l_ag_presence_chk_sql || ' AND NVL(UAI.'||l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME2||','||wierd_constant||') '||
                                                                 '   = NVL(ENTITY.'||l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME2||','||wierd_constant||')';
       END IF;
       IF (l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME3 IS NOT NULL AND l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME3 <> 'NONE'
          AND INSTR(l_ag_presence_chk_sql,l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME3) = 0) THEN
               IF(l_list_of_dl_for_ag_type(i).PK_COLUMN_TYPE3 = 'NUMBER') THEN
                 wierd_constant := G_NULL_TOKEN_NUM;
               ELSIF (l_list_of_dl_for_ag_type(i).PK_COLUMN_TYPE3 = 'DATE' OR l_list_of_dl_for_ag_type(i).PK_COLUMN_TYPE3 = 'DATETIME') THEN
                 wierd_constant := G_NULL_TOKEN_DATE;
               ELSE
                 wierd_constant := G_NULL_TOKEN_STR;
               END IF;
               l_ag_presence_chk_sql := l_ag_presence_chk_sql || ' AND NVL(UAI.'||l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME3||','||wierd_constant||') '||
                                                                 '   = NVL(ENTITY.'||l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME3||','||wierd_constant||')';
       END IF;
       IF (l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME4 IS NOT NULL AND l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME4 <> 'NONE'
          AND INSTR(l_ag_presence_chk_sql,l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME4) = 0) THEN
               IF(l_list_of_dl_for_ag_type(i).PK_COLUMN_TYPE4 = 'NUMBER') THEN
                 wierd_constant := G_NULL_TOKEN_NUM;
               ELSIF (l_list_of_dl_for_ag_type(i).PK_COLUMN_TYPE4 = 'DATE' OR l_list_of_dl_for_ag_type(i).PK_COLUMN_TYPE4 = 'DATETIME') THEN
                 wierd_constant := G_NULL_TOKEN_DATE;
               ELSE
                 wierd_constant := G_NULL_TOKEN_STR;
               END IF;
               l_ag_presence_chk_sql := l_ag_presence_chk_sql || ' AND NVL(UAI.'||l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME4||','||wierd_constant||') '||
                                                                 '   = NVL(ENTITY.'||l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME4||','||wierd_constant||')';
       END IF;
       IF (l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME5 IS NOT NULL AND l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME5 <> 'NONE'
          AND INSTR(l_ag_presence_chk_sql,l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME5) = 0) THEN
               IF(l_list_of_dl_for_ag_type(i).PK_COLUMN_TYPE5 = 'NUMBER') THEN
                 wierd_constant := G_NULL_TOKEN_NUM;
               ELSIF (l_list_of_dl_for_ag_type(i).PK_COLUMN_TYPE5 = 'DATE' OR l_list_of_dl_for_ag_type(i).PK_COLUMN_TYPE5 = 'DATETIME') THEN
                 wierd_constant := G_NULL_TOKEN_DATE;
               ELSE
                 wierd_constant := G_NULL_TOKEN_STR;
               END IF;
               l_ag_presence_chk_sql := l_ag_presence_chk_sql || ' AND NVL(UAI.'||l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME5||','||wierd_constant||') '||
                                                                 '   = NVL(ENTITY.'||l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME5||','||wierd_constant||')';
       END IF;
    END LOOP;
  END IF;





  IF l_has_data_level_id THEN -- R12C specific code
    l_all_dl_cols := EGO_USER_ATTRS_COMMON_PVT.Get_All_Data_Level_PK_Names
                                   (p_application_id  => p_application_id
                                   ,p_attr_group_type => p_attr_group_type);

    l_pk_cc_select_list := l_pk_cc_select_list || ', ENTITYAG_TBL.DATA_LEVEL_ID ';
    l_pk_cc_dl_col_list := l_pk_cc_dl_col_list || ', DATA_LEVEL_ID ';
    l_inner_pk_cc_dl_col_list := l_inner_pk_cc_dl_col_list ||', ENTITY.DATA_LEVEL_ID ';
    -- l_all_dl_cols are in the format a,b,c
    IF l_all_dl_cols IS NOT NULL THEN
      l_all_dl_cols := ','||l_all_dl_cols;
      l_pk_cc_select_list := l_pk_cc_select_list || REPLACE(l_all_dl_cols,',',', ENTITYAG_TBL.');
      l_pk_cc_dl_col_list := l_pk_cc_dl_col_list || l_all_dl_cols;
      l_inner_pk_cc_dl_col_list := l_inner_pk_cc_dl_col_list ||REPLACE(l_all_dl_cols,',',', ENTITY.');
    ELSE
      l_all_dl_cols := ' ';
    END IF;

  ELSE -- R12 code
    ------------------------------------------------------------
    -- Get data level information for the given object name   --
    ------------------------------------------------------------
    FOR d_l_rec IN data_level_cols_cursor(cp_application_id  => p_application_id
                                         ,cp_attr_group_type => p_attr_group_type)
    LOOP

      IF (data_level_cols_cursor%ROWCOUNT = 1) THEN
        l_data_level_none        := d_l_rec.data_level_name;
        l_num_data_level_columns := 0;
      ELSIF (data_level_cols_cursor%ROWCOUNT = 2) THEN
        l_data_level_column_1    := d_l_rec.data_level_name;
        l_num_data_level_columns := 1;
      ELSIF (data_level_cols_cursor%ROWCOUNT = 3) THEN
        l_data_level_column_2    := d_l_rec.data_level_name;
        l_num_data_level_columns := 2;
      ELSIF (data_level_cols_cursor%ROWCOUNT = 4) THEN
        l_data_level_column_3    := d_l_rec.data_level_name;
        l_num_data_level_columns := 3;
      END IF;
    END LOOP;
  END IF;  -- l_has_data_level_id

  IF (p_additional_class_Code_query IS NULL) THEN
    l_additional_class_Code_query := ' SELECT -2910 FROM DUAL ';
  ELSE
    l_additional_class_Code_query := p_additional_class_Code_query;
  END IF;
code_debug(l_api_name ||' phase 2 ');
code_debug(l_api_name ||' l_pk_cc_select_list '||l_pk_cc_select_list);
code_debug(l_api_name ||' l_pk_cc_dl_col_list '|| l_pk_cc_dl_col_list );
code_debug(l_api_name ||' l_inner_pk_cc_dl_col_list '|| l_inner_pk_cc_dl_col_list );
code_debug(l_api_name ||' l_ag_presence_chk_sql '|| l_ag_presence_chk_sql );
  ----------------------------------------------------------
  -- Getting the max ROW_IDENTIFIER in the given data set --
  -- All the inserted rows will have ROW_IDENTIFIERS in a --
  -- series starting with this number                     --
  ----------------------------------------------------------

  BEGIN
    l_dynamic_sql := 'SELECT MAX(ROW_IDENTIFIER)+1 FROM '||p_interface_table_name||
                     ' WHERE DATA_SET_ID = :data_Set_id ';
    EXECUTE IMMEDIATE l_dynamic_sql
    INTO l_max_row_id
    USING p_Data_Set_id;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
       l_max_row_id := 1;
  END;

  IF(l_max_row_id IS NULL) THEN
    l_max_row_id := 1;
  END IF;

  IF (p_extra_column_names IS NOT NULL) THEN
     l_dynamic_sql:= ' SELECT /*+ leading(ATTR_EXT_TBL,ATTR_TBL,INNER_ATTR_TBL) */  /* Bug 9678667 */ '||p_extra_column_values||', '||p_process_status; -- p_extra_column_values, PROCESS_STATUS
  ELSE
     l_dynamic_sql:= ' SELECT /*+ leading(ATTR_EXT_TBL,ATTR_TBL,INNER_ATTR_TBL) */  /* Bug 9678667 */ '||p_process_status||' ';                         -- PROCESS_STATUS
  END IF;

  l_dynamic_sql := l_dynamic_sql||
                      ' ,'''||p_attr_group_type||''' '||   --ATTR_GROUP_TYPE
                      ' ,:data_set_id                '||   --DATA_SET_ID
                      ' ,:request_id                 '||   --REQUEST_ID
                      ' ,:max_row_id + ROW_ID        '||   --ROW_IDENTIFIER
                      ' ,ATTR_TBL.DESCRIPTIVE_FLEX_CONTEXT_CODE    '||   --ATTR_GROUP_INT_NAME
                      ' ,ATTR_TBL.END_USER_COLUMN_NAME             '||   --ATTR_INT_NAME
                      ' ,TO_NUMBER(DECODE(ATTR_EXT_TBL.DATA_TYPE, '''||EGO_EXT_FWK_PUB.G_NUMBER_DATA_TYPE||'''  '||--ATTR_VALUE_NUM
                      '                               ,ATTR_TBL.DEFAULT_VALUE '||
                      '                               ,NULL))                 '||
                      ' ,DECODE(ATTR_EXT_TBL.DATA_TYPE, '''||EGO_EXT_FWK_PUB.G_TRANS_TEXT_DATA_TYPE||'''        '||--ATTR_VALUE_STR
                      '                               ,ATTR_TBL.DEFAULT_VALUE '||
                      '                               , '''||EGO_EXT_FWK_PUB.G_CHAR_DATA_TYPE||'''              '||
                      '                               ,ATTR_TBL.DEFAULT_VALUE '||
                      '                               ,NULL)                  '||
                      ' ,DECODE(ATTR_EXT_TBL.DATA_TYPE, '''||EGO_EXT_FWK_PUB.G_DATE_DATA_TYPE||'''              '||--ATTR_VALUE_DATE
                      '                           ,EGO_USER_ATTRS_BULK_PVT.Get_Date(ATTR_TBL.DEFAULT_VALUE,NULL)'||
                      '                           , '''||EGO_EXT_FWK_PUB.G_DATE_TIME_DATA_TYPE||'''             '||
                      '                           ,EGO_USER_ATTRS_BULK_PVT.Get_Date(ATTR_TBL.DEFAULT_VALUE,NULL)'||
                      '                           ,NULL)                                                        ';

  l_dynamic_sql := l_dynamic_sql || l_pk_cc_select_list;
code_debug(l_api_name ||' phase 3 ');
code_debug(l_api_name ||' l_dynamic_sql '||l_dynamic_sql);

  IF NOT l_has_data_level_id THEN -- R12 CODE
    -------------------------------------------------
    -- Adding Data Level data columns to the query --
    -------------------------------------------------
    IF (l_num_data_level_columns = 1 OR l_num_data_level_columns = 2 OR l_num_data_level_columns = 3) THEN
       l_dynamic_sql := l_dynamic_sql || ' , DECODE(ENTITYAG_TBL.DATA_LEVEL                 '||
                                         '          ,'''||l_data_level_none||'''         '||
                                         '          ,NULL                                '||
                                         '          ,ENTITYAG_TBL.'||l_data_level_column_1||') ';
       l_pk_cc_dl_col_list := l_pk_cc_dl_col_list||' , '||l_data_level_column_1;
       l_inner_pk_cc_dl_col_list := l_inner_pk_cc_dl_col_list || ', ENTITY.'||l_data_level_column_1;
    END IF;

    IF (l_num_data_level_columns = 2 OR l_num_data_level_columns = 3) THEN
       l_dynamic_sql := l_dynamic_sql || ' , DECODE(ENTITYAG_TBL.DATA_LEVEL                 '||
                                         '          ,'''||l_data_level_none||'''         '||
                                         '          ,NULL                                '||
                                         '          ,ENTITYAG_TBL.'||l_data_level_column_2||') ';
       l_pk_cc_dl_col_list := l_pk_cc_dl_col_list||' , '||l_data_level_column_2;
       l_inner_pk_cc_dl_col_list := l_inner_pk_cc_dl_col_list || ', ENTITY.'||l_data_level_column_2;
    END IF;

    IF (l_num_data_level_columns = 3) THEN
       l_dynamic_sql := l_dynamic_sql || ' , DECODE(ENTITYAG_TBL.DATA_LEVEL                 '||
                                         '          ,'''||l_data_level_none||'''         '||
                                         '          ,NULL                                '||
                                         '          ,ENTITYAG_TBL.'||l_data_level_column_3||') ';
       l_pk_cc_dl_col_list := l_pk_cc_dl_col_list||' , '||l_data_level_column_3;
       l_inner_pk_cc_dl_col_list := l_inner_pk_cc_dl_col_list || ', ENTITY.'||l_data_level_column_3;
    END IF;
  END IF;

code_debug(l_api_name ||' phase 4 ');
code_debug(l_api_name ||' l_pk_cc_dl_col_list '|| l_pk_cc_dl_col_list );
code_debug(l_api_name ||' l_inner_pk_cc_dl_col_list '|| l_inner_pk_cc_dl_col_list );
code_debug(l_api_name ||' l_dynamic_sql '||l_dynamic_sql);

  l_dynamic_sql := l_dynamic_sql ||
                           ' ,'''||EGO_USER_ATTRS_DATA_PVT.G_CREATE_MODE||'''    '||--TRANSACTION_TYPE
                           ' ,ENTITYAG_TBL.ATTR_GROUP_ID '||--ATTR_GROUP_ID
                           ' ,ENTITYAG_TBL.TRANSACTION_ID '||--TRANSACTION_ID
                           ' ,:current_user_id           '||--CREATED_BY
                           ' ,SYSDATE                    '||--CREATION_DATE
                           ' ,:current_user_id           '||--LAST_UPDATED_BY
                           ' ,SYSDATE                    '||--LAST_UPDATE_DATE
                           ' ,:current_login_id          '||--LAST_UPDATE_LOGIN
                      ' FROM FND_DESCR_FLEX_COLUMN_USAGES ATTR_TBL, '||
                          '  EGO_FND_DF_COL_USGS_EXT ATTR_EXT_TBL,  '||
                          ' (SELECT /*+ FULL (ASSOC_TBL) */  TRANSACTION_ID, '||
        --Bug7315142,hint added to increase the performance
                          '         ROWNUM ROW_ID,                  '||
                          '         APPLICATION_ID,                 '||
                          '         ATTR_GROUP_TBL.DESCRIPTIVE_FLEXFIELD_NAME,    '||
                          '         ATTR_GROUP_TBL.DESCRIPTIVE_FLEX_CONTEXT_CODE, '||
                          '         ATTR_GROUP_TBL.ATTR_GROUP_ID,           '||
                          '         ASSOC_TBL.DATA_LEVEL                    '||
                          '      '||l_inner_pk_cc_dl_col_list||'            '||
                          '    FROM EGO_FND_DSC_FLX_CTX_EXT ATTR_GROUP_TBL, '||
                          '         EGO_OBJ_AG_ASSOCS_B ASSOC_TBL,          '||
                          '         ('||p_target_entity_sql||') ENTITY      '||
                          '   WHERE                                         '||
                          '         ATTR_GROUP_TBL.DESCRIPTIVE_FLEXFIELD_NAME = :attr_group_type ';
  IF l_has_data_level_id THEN
    l_dynamic_sql := l_dynamic_sql ||
                          '     AND ASSOC_TBL.DATA_LEVEL_ID = ENTITY.DATA_LEVEL_ID ';
  END IF;
  IF (p_attr_groups_to_exclude IS NOT NULL) THEN
     l_dynamic_sql := l_dynamic_sql||
                          '     AND ATTR_GROUP_TBL.ATTR_GROUP_ID NOT IN ('||p_attr_groups_to_exclude||')          ';
  END IF;

  l_dynamic_sql := l_dynamic_sql||
                           '    AND ATTR_GROUP_TBL.ATTR_GROUP_ID = ASSOC_TBL.ATTR_GROUP_ID                        '||
                           '    AND ATTR_GROUP_TBL.APPLICATION_ID = :app_id                                       '||
                           '    AND ASSOC_TBL.OBJECT_ID = :object_id                                              '||
                           '    AND ATTR_GROUP_TBL.MULTI_ROW = ''N''                                              '||
                           '    AND (    ASSOC_TBL.CLASSIFICATION_CODE IN ('||l_additional_class_Code_query||')   '||
                           '          OR ASSOC_TBL.CLASSIFICATION_CODE = ENTITY.'||l_class_code_column_name||')   '||
                           '    AND NOT EXISTS ('||l_ag_presence_chk_sql||')                                      '||
                           ' ) ENTITYAG_TBL                                                                       '||
                     ' WHERE ATTR_TBL.APPLICATION_ID = ENTITYAG_TBL.APPLICATION_ID                                '||
                     '   AND ATTR_TBL.DESCRIPTIVE_FLEXFIELD_NAME = ENTITYAG_TBL.DESCRIPTIVE_FLEXFIELD_NAME        '||
                     '   AND ATTR_TBL.DESCRIPTIVE_FLEX_CONTEXT_CODE = ENTITYAG_TBL.DESCRIPTIVE_FLEX_CONTEXT_CODE  '||
                     '   AND ATTR_TBL.DEFAULT_VALUE IS NOT NULL                                                   '||
                     '   AND ATTR_TBL.ENABLED_FLAG = ''Y''                                                        '||
                     '   AND ATTR_EXT_TBL.APPLICATION_ID = :app_id                                                '||
                     '   AND ATTR_EXT_TBL.DESCRIPTIVE_FLEXFIELD_NAME = :attr_group_type                           '||
                     '   AND ATTR_EXT_TBL.DESCRIPTIVE_FLEX_CONTEXT_CODE = ATTR_TBL.DESCRIPTIVE_FLEX_CONTEXT_CODE  '||
                     '   AND ATTR_EXT_TBL.APPLICATION_COLUMN_NAME = ATTR_TBL.APPLICATION_COLUMN_NAME              '||
                     '   AND NOT EXISTS                                                                           '||
                     '      ( SELECT 1                                                                                      '||
                     '           FROM FND_DESCR_FLEX_COLUMN_USAGES INNER_ATTR_TBL                                           '||
                     '          WHERE INNER_ATTR_TBL.APPLICATION_ID                = ATTR_TBL.APPLICATION_ID                '||
                     '            AND INNER_ATTR_TBL.DESCRIPTIVE_FLEXFIELD_NAME    = ATTR_TBL.DESCRIPTIVE_FLEXFIELD_NAME    '||
                     '            AND INNER_ATTR_TBL.DESCRIPTIVE_FLEX_CONTEXT_CODE = ATTR_TBL.DESCRIPTIVE_FLEX_CONTEXT_CODE '||
                     '            AND INNER_ATTR_TBL.REQUIRED_FLAG = ''Y''                                                  '||
                     '            AND INNER_ATTR_TBL.DEFAULT_VALUE IS NULL                                                  '||
                     '       )  ';
code_debug(l_api_name ||' phase 5 ');
code_debug(l_api_name ||' l_dynamic_sql '||l_dynamic_sql);

  IF (p_extra_column_names IS NOT NULL) THEN
     l_col_to_insert_list:= p_extra_column_names||' ,PROCESS_STATUS ';
  ELSE
     l_col_to_insert_list:= ' PROCESS_STATUS ';
  END IF;

  l_col_to_insert_list:= l_col_to_insert_list    ||
                         ' ,ATTR_GROUP_TYPE     '||
                         ' ,DATA_SET_ID         '||
                         ' ,REQUEST_ID          '||
                         ' ,ROW_IDENTIFIER      '||
                         ' ,ATTR_GROUP_INT_NAME '||
                         ' ,ATTR_INT_NAME       '||
                         ' ,ATTR_VALUE_NUM      '||
                         ' ,ATTR_VALUE_STR      '||
                         ' ,ATTR_VALUE_DATE     '||
                          l_pk_cc_dl_col_list    ||
                         ' ,TRANSACTION_TYPE    '||
                         ' ,ATTR_GROUP_ID       '||
                         ' ,TRANSACTION_ID      '||
                         ' ,CREATED_BY          '||
                         ' ,CREATION_DATE       '||
                         ' ,LAST_UPDATED_BY     '||
                         ' ,LAST_UPDATE_DATE    '||
                         ' ,LAST_UPDATE_LOGIN   ';

  ---------------------------
  -- The final DML         --
  ---------------------------
  --Bug No:5386049
  --Getting the currnet userid and loginid
  --if not initialised.so that they are not inserted as null
  IF (G_CURRENT_USER_ID IS NULL ) THEN
    G_CURRENT_USER_ID  := FND_GLOBAL.User_Id;
  END IF;
  IF (G_CURRENT_LOGIN_ID IS NULL ) THEN
    G_CURRENT_LOGIN_ID := FND_GLOBAL.Login_Id;
  END IF;

  l_dynamic_sql :=   ' INSERT INTO '||p_interface_table_name||
                     ' (   '||l_col_to_insert_list  ||' )  '||
                     l_dynamic_sql;
  l_object_id := EGO_USER_ATTRS_DATA_PVT.Get_Object_Id_From_Name(p_object_name);

code_debug(l_api_name ||' Final SQL ');
code_debug(l_api_name ||l_dynamic_sql);
code_debug(l_api_name ||'params 1: '||p_data_Set_id||' 2: '||FND_GLOBAL.CONC_REQUEST_ID||
           ' 3: '||l_max_row_id||' 4: '||G_CURRENT_USER_ID||
           ' 5: '||G_CURRENT_USER_ID||' 6: '||G_CURRENT_LOGIN_ID||
           ' 7: '||p_attr_group_type||' 8: '||p_application_id||
           ' 9: '||l_object_id||' 10: '||p_data_set_id||
           ' 11: '||p_application_id||' 12: '||p_attr_group_type
           );

  /* Begin Bug 13729672*/
  IF p_datalevel_id IS NULL THEN
    EXECUTE IMMEDIATE l_dynamic_sql
    USING p_data_Set_id,
          FND_GLOBAL.CONC_REQUEST_ID,
          l_max_row_id,
          G_CURRENT_USER_ID,
          G_CURRENT_USER_ID,
          G_CURRENT_LOGIN_ID,
          p_attr_group_type,
          p_application_id,
          l_object_id,
          p_data_set_id,
          p_application_id,
          p_attr_group_type;
  ELSE
    EXECUTE IMMEDIATE l_dynamic_sql
    USING p_data_Set_id,
          FND_GLOBAL.CONC_REQUEST_ID,
          l_max_row_id,
          G_CURRENT_USER_ID,
          G_CURRENT_USER_ID,
          G_CURRENT_LOGIN_ID,
          p_comp_seq_id,
          p_bill_seq_id,
          p_structure_type_id,
          p_data_level_column,
          p_datalevel_id,
          p_context_id,
          p_transaction_id,
          p_attr_group_type,
          p_application_id,
          l_object_id,
          p_data_set_id,
          p_application_id,
          p_attr_group_type;
  END IF;
  /* End Bug 1379672 */

    -- Fix for bug#9336604
    -- Added gather stats based on profile
    IF SQL%ROWCOUNT > 0 THEN
       IF (FND_INSTALLATION.GET_APP_INFO('EGO', l_status, l_industry, l_schema)) THEN

         IF (nvl(fnd_profile.value('EGO_ENABLE_GATHER_STATS'),'N') = 'Y') THEN

            FND_STATS.GATHER_TABLE_STATS(OWNNAME => l_schema,
                                   TABNAME => 'EGO_ITM_USR_ATTR_INTRFC',
                                   CASCADE => True);
         END IF;

       END IF;
    END IF;
  --------------------------------
  -- Standard check of p_commit --
  --------------------------------
  IF FND_API.To_Boolean(p_commit) THEN
    COMMIT WORK;
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  code_debug(l_api_name ||' Returning with status '||x_return_status);

EXCEPTION
  WHEN OTHERS THEN
   code_debug(l_api_name ||' Returning EXCEPTION '||SQLERRM);
   x_return_status  := FND_API.G_RET_STS_UNEXP_ERROR;
   x_msg_data := 'Executing - EGO_USER_ATTRS_BULK_PVT.Insert_Default_Val_Rows: '||SQLERRM;

END Insert_Default_Val_Rows;

----------------------------------------------------------------------

PROCEDURE Mark_Unchanged_Attr_Rows (  p_api_version            IN   NUMBER
                                     ,p_application_id         IN   NUMBER
                                     ,p_attr_group_type        IN   VARCHAR2
                                     ,p_object_name            IN   VARCHAR2
                                     ,p_interface_table_name   IN   VARCHAR2
                                     ,p_data_set_id            IN   NUMBER
                                     ,p_new_status             IN   NUMBER
                                     ,p_commit                 IN   VARCHAR2   DEFAULT FND_API.G_FALSE
                                     ,x_return_status          OUT NOCOPY VARCHAR2
                                     ,x_msg_data               OUT NOCOPY VARCHAR2
                                   )
IS

  TYPE DYNAMIC_CUR IS REF CURSOR;

  l_attr_group_int_name               VARCHAR2(30);
  l_dynamic_dist_ag_cursor            DYNAMIC_CUR;
  l_dynamic_sql                       VARCHAR2(30000);
  l_ext_vl_table_name                 VARCHAR2(30);
  l_ext_b_table_name                  VARCHAR2(30);
  l_ext_intf_pk_join_sql              VARCHAR2(2000);
  l_ext_intf_dl_join_sql              VARCHAR2(2000);
  l_uk_where_caluse                   VARCHAR2(32000); -- VARCHAR2(10000);  bug# 9448576
  l_ag_id_col_exists                  BOOLEAN;
  l_uk_attr_list                      VARCHAR2(32000); -- VARCHAR2(7000);   bug# 9448576

  l_str_attr_decode_list_Ext          VARCHAR2(10000);
  l_num_attr_decode_list_Ext          VARCHAR2(10000);
  l_date_attr_decode_list_Ext         VARCHAR2(10000);

  l_str_attr_decode_list_Intf          VARCHAR2(10000);
  l_num_attr_decode_list_Intf          VARCHAR2(10000);
  l_date_attr_decode_list_Intf         VARCHAR2(10000);

  l_pk1_column_name                   VARCHAR2(30);
  l_pk2_column_name                   VARCHAR2(30);
  l_pk3_column_name                   VARCHAR2(30);
  l_pk4_column_name                   VARCHAR2(30);
  l_pk5_column_name                   VARCHAR2(30);

  l_num_data_level_columns            NUMBER := 0;
  l_data_level_1                      VARCHAR2(30);
  l_data_level_column_1               VARCHAR2(150);
  l_data_level_2                      VARCHAR2(30);
  l_data_level_column_2               VARCHAR2(150);
  l_data_level_3                      VARCHAR2(30);
  l_data_level_column_3               VARCHAR2(150);
  l_object_id                         NUMBER;

  l_dyn_cursor                        NUMBER;
  l_dummy                             NUMBER;
  l_attr_group_metadata_obj           EGO_ATTR_GROUP_METADATA_OBJ;
  l_attr_metadata_table               EGO_ATTR_METADATA_TABLE;
  l_list_of_dl_for_ag_type            EGO_DATA_LEVEL_METADATA_TABLE;
  l_data_level_col_exists             BOOLEAN;
  wierd_constant                      VARCHAR2(100);

  CURSOR data_level_cols_cursor (cp_object_name VARCHAR2)
  IS
  SELECT LOOKUP_CODE  DATA_LEVEL_INTERNAL_NAME
        ,MEANING      DATA_LEVEL_DISPLAY_NAME
        ,DECODE(ATTRIBUTE2, 1, ATTRIBUTE3,
                            2, ATTRIBUTE5,
                            3, ATTRIBUTE7,
                            'NONE') DATA_LEVEL_COLUMN
        ,DECODE(ATTRIBUTE2, 1, ATTRIBUTE4,
                            2, ATTRIBUTE6,
                            3, ATTRIBUTE8,
                            'NONE') DL_COL_DATA_TYPE
   FROM FND_LOOKUP_VALUES
  WHERE LOOKUP_TYPE = 'EGO_EF_DATA_LEVEL'
    AND ATTRIBUTE1 = cp_object_name
    AND LANGUAGE = USERENV('LANG')
  ORDER BY ATTRIBUTE2;

BEGIN

  code_debug('*** Inside Mark_Unchanged_Attr_Rows ...',2);

  -----------------------------------------
  -- Fetch the PK column names and data  --
  -- types for the passed-in object name --
  -----------------------------------------
  SELECT PK1_COLUMN_NAME,
         PK2_COLUMN_NAME,
         PK3_COLUMN_NAME,
         PK4_COLUMN_NAME,
         PK5_COLUMN_NAME
    INTO l_pk1_column_name,
         l_pk2_column_name,
         l_pk3_column_name,
         l_pk4_column_name,
         l_pk5_column_name
    FROM FND_OBJECTS
   WHERE OBJ_NAME = p_object_name;

  --------------------------------------------
  -- Fetching the ext table/vl name         --
  --------------------------------------------
  SELECT FLEX_EXT.APPLICATION_VL_NAME       EXT_VL_NAME,
         FLEX.APPLICATION_TABLE_NAME        EXT_TABLE_NAME
    INTO l_ext_vl_table_name,
         l_ext_b_table_name
    FROM FND_DESCRIPTIVE_FLEXS              FLEX,
         EGO_FND_DESC_FLEXS_EXT             FLEX_EXT
   WHERE FLEX.APPLICATION_ID = FLEX_EXT.APPLICATION_ID(+)
     AND FLEX.DESCRIPTIVE_FLEXFIELD_NAME = FLEX_EXT.DESCRIPTIVE_FLEXFIELD_NAME(+)
     AND FLEX.APPLICATION_ID = p_application_id
     AND FLEX.DESCRIPTIVE_FLEXFIELD_NAME = p_attr_group_type;

  IF(l_ext_vl_table_name IS NULL) THEN
    l_ext_vl_table_name := l_ext_b_table_name;
  END IF;


/**********************
***********************/
  ------------------------------------------------------------
  -- Get data level information for the given object name   --
  ------------------------------------------------------------
    l_data_level_col_exists :=  FND_API.TO_BOOLEAN(
            EGO_USER_ATTRS_COMMON_PVT.has_column_in_table(
              p_table_name => l_ext_b_table_name,
              p_column_name => 'DATA_LEVEL_ID'));

    l_list_of_dl_for_ag_type := EGO_USER_ATTRS_COMMON_PVT.Get_Data_Levels_For_AGType( p_application_id  => p_application_id
                                                                                     ,p_attr_group_type => p_attr_group_type);

    ------------------------------------------------------------
    -- Get data level information for the given object name   --
    -- R12C onwards the data level info wud not be stored in  --
    -- lookups table. Hence we get it from the dl meta data   --
    -- table fetched. We assume here that there can be only 3 --
    -- data levels with only one pk column. This assumption is -
    -- as per the support offered prior to R12C               --
    ------------------------------------------------------------
    l_dummy := 0;
    FOR i IN l_list_of_dl_for_ag_type.FIRST .. l_list_of_dl_for_ag_type.LAST
    LOOP

      IF(l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME1 <> 'NONE'
         AND l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME1 IS NOT NULL) THEN

          l_dummy := l_dummy + 1;

          IF (l_dummy = 1) THEN

            l_data_level_1           := l_list_of_dl_for_ag_type(i).DATA_LEVEL_NAME;
            l_data_level_column_1    := l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME1;
            l_num_data_level_columns := 1;

          ELSIF (l_dummy = 2) THEN

            l_data_level_2           := l_list_of_dl_for_ag_type(i).DATA_LEVEL_NAME;
            l_data_level_column_2    := l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME1;
            l_num_data_level_columns := 2;

          ELSIF (l_dummy = 3) THEN
            l_data_level_3           := l_list_of_dl_for_ag_type(i).DATA_LEVEL_NAME;
            l_data_level_column_3    := l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME1;
            l_num_data_level_columns := 3;

          END IF;

      END IF;

    END LOOP;

  ------------------------------------------------
  -- Building the PK Join for the where clause  --
  ------------------------------------------------

  l_ext_intf_pk_join_sql := ' ';

  IF (l_pk1_column_name IS NOT NULL) THEN
     l_ext_intf_pk_join_sql := l_ext_intf_pk_join_sql || ' AND '||l_pk1_column_name||' = INTRFC.'||l_pk1_column_name;
  END IF;
  IF (l_pk2_column_name IS NOT NULL) THEN
     l_ext_intf_pk_join_sql := l_ext_intf_pk_join_sql || ' AND '||l_pk2_column_name||' = INTRFC.'||l_pk2_column_name;
  END IF;
  IF (l_pk3_column_name IS NOT NULL) THEN
     l_ext_intf_pk_join_sql := l_ext_intf_pk_join_sql || ' AND '||l_pk3_column_name||' = INTRFC.'||l_pk3_column_name;
  END IF;
  IF (l_pk4_column_name IS NOT NULL) THEN
     l_ext_intf_pk_join_sql := l_ext_intf_pk_join_sql || ' AND '||l_pk4_column_name||' = INTRFC.'||l_pk4_column_name;
  END IF;
  IF (l_pk5_column_name IS NOT NULL) THEN
     l_ext_intf_pk_join_sql := l_ext_intf_pk_join_sql || ' AND '||l_pk5_column_name||' = INTRFC.'||l_pk5_column_name;
  END IF;

  --------------------------------------------------------
  -- Building the Data Level Join for the where clause  --
  --------------------------------------------------------

  l_ext_intf_dl_join_sql := ' ';


  IF(l_data_level_col_exists) THEN
    l_ext_intf_dl_join_sql := l_ext_intf_dl_join_sql || ' AND NVL(DATA_LEVEL_ID,'||G_NULL_TOKEN_NUM||') '||
                                                      '   = NVL(INTRFC.DATA_LEVEL_ID,'||G_NULL_TOKEN_NUM||')';

    FOR i IN l_list_of_dl_for_ag_type.FIRST .. l_list_of_dl_for_ag_type.LAST
    LOOP

       IF (l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME1 IS NOT NULL AND l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME1 <> 'NONE'
          AND INSTR(l_ext_intf_dl_join_sql,l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME1) = 0) THEN

               IF(l_list_of_dl_for_ag_type(i).PK_COLUMN_TYPE1 = 'NUMBER') THEN
                 wierd_constant := G_NULL_TOKEN_NUM;
               ELSIF (l_list_of_dl_for_ag_type(i).PK_COLUMN_TYPE1 = 'DATE' OR l_list_of_dl_for_ag_type(i).PK_COLUMN_TYPE1 = 'DATETIME') THEN
                 wierd_constant := G_NULL_TOKEN_DATE;
               ELSE
                 wierd_constant := G_NULL_TOKEN_STR;
               END IF;

               l_ext_intf_dl_join_sql := l_ext_intf_dl_join_sql || ' AND NVL('||l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME1||','||wierd_constant||') '||
                                                                 '   = NVL(INTRFC.'||l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME1||','||wierd_constant||')';
       END IF;
       IF (l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME2 IS NOT NULL AND l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME2 <> 'NONE'
          AND INSTR(l_ext_intf_dl_join_sql,l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME2) = 0) THEN
               IF(l_list_of_dl_for_ag_type(i).PK_COLUMN_TYPE2 = 'NUMBER') THEN
                 wierd_constant := G_NULL_TOKEN_NUM;
               ELSIF (l_list_of_dl_for_ag_type(i).PK_COLUMN_TYPE2 = 'DATE' OR l_list_of_dl_for_ag_type(i).PK_COLUMN_TYPE2 = 'DATETIME') THEN
                 wierd_constant := G_NULL_TOKEN_DATE;
               ELSE
                 wierd_constant := G_NULL_TOKEN_STR;
               END IF;
               l_ext_intf_dl_join_sql := l_ext_intf_dl_join_sql || ' AND NVL('||l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME2||','||wierd_constant||') '||
                                                                 '   = NVL(INTRFC.'||l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME2||','||wierd_constant||')';
       END IF;
       IF (l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME3 IS NOT NULL AND l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME3 <> 'NONE'
          AND INSTR(l_ext_intf_dl_join_sql,l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME3) = 0) THEN
               IF(l_list_of_dl_for_ag_type(i).PK_COLUMN_TYPE3 = 'NUMBER') THEN
                 wierd_constant := G_NULL_TOKEN_NUM;
               ELSIF (l_list_of_dl_for_ag_type(i).PK_COLUMN_TYPE3 = 'DATE' OR l_list_of_dl_for_ag_type(i).PK_COLUMN_TYPE3 = 'DATETIME') THEN
                 wierd_constant := G_NULL_TOKEN_DATE;
               ELSE
                 wierd_constant := G_NULL_TOKEN_STR;
               END IF;
               l_ext_intf_dl_join_sql := l_ext_intf_dl_join_sql || ' AND NVL('||l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME3||','||wierd_constant||') '||
                                                                 '   = NVL(INTRFC.'||l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME3||','||wierd_constant||')';
       END IF;
       IF (l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME4 IS NOT NULL AND l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME4 <> 'NONE'
          AND INSTR(l_ext_intf_dl_join_sql,l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME4) = 0) THEN
               IF(l_list_of_dl_for_ag_type(i).PK_COLUMN_TYPE4 = 'NUMBER') THEN
                 wierd_constant := G_NULL_TOKEN_NUM;
               ELSIF (l_list_of_dl_for_ag_type(i).PK_COLUMN_TYPE4 = 'DATE' OR l_list_of_dl_for_ag_type(i).PK_COLUMN_TYPE4 = 'DATETIME') THEN
                 wierd_constant := G_NULL_TOKEN_DATE;
               ELSE
                 wierd_constant := G_NULL_TOKEN_STR;
               END IF;
               l_ext_intf_dl_join_sql := l_ext_intf_dl_join_sql || ' AND NVL('||l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME4||','||wierd_constant||') '||
                                                                 '   = NVL(INTRFC.'||l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME4||','||wierd_constant||')';
       END IF;
       IF (l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME5 IS NOT NULL AND l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME5 <> 'NONE'
          AND INSTR(l_ext_intf_dl_join_sql,l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME5) = 0) THEN
               IF(l_list_of_dl_for_ag_type(i).PK_COLUMN_TYPE5 = 'NUMBER') THEN
                 wierd_constant := G_NULL_TOKEN_NUM;
               ELSIF (l_list_of_dl_for_ag_type(i).PK_COLUMN_TYPE5 = 'DATE' OR l_list_of_dl_for_ag_type(i).PK_COLUMN_TYPE5 = 'DATETIME') THEN
                 wierd_constant := G_NULL_TOKEN_DATE;
               ELSE
                 wierd_constant := G_NULL_TOKEN_STR;
               END IF;
               l_ext_intf_dl_join_sql := l_ext_intf_dl_join_sql || ' AND NVL('||l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME5||','||wierd_constant||') '||
                                                                 '   = NVL(INTRFC.'||l_list_of_dl_for_ag_type(i).PK_COLUMN_NAME5||','||wierd_constant||')';
       END IF;
    END LOOP;
  ELSE
    IF(l_num_data_level_columns = 1 ) THEN
      l_ext_intf_dl_join_sql := l_ext_intf_dl_join_sql || ' AND NVL('||l_data_level_column_1||',-1) = NVL(INTRFC.'||l_data_level_column_1||', -1) ';
    ELSIF(l_num_data_level_columns = 2 ) THEN
      l_ext_intf_dl_join_sql := l_ext_intf_dl_join_sql || ' AND NVL('||l_data_level_column_1||',-1) = NVL(INTRFC.'||l_data_level_column_1||', -1) ';
      l_ext_intf_dl_join_sql := l_ext_intf_dl_join_sql || ' AND NVL('||l_data_level_column_2||',-1) = NVL(INTRFC.'||l_data_level_column_2||', -1) ';
    ELSIF(l_num_data_level_columns = 3 ) THEN
      l_ext_intf_dl_join_sql := l_ext_intf_dl_join_sql || ' AND NVL('||l_data_level_column_1||',-1) = NVL(INTRFC.'||l_data_level_column_1||', -1) ';
      l_ext_intf_dl_join_sql := l_ext_intf_dl_join_sql || ' AND NVL('||l_data_level_column_2||',-1) = NVL(INTRFC.'||l_data_level_column_2||', -1) ';
      l_ext_intf_dl_join_sql := l_ext_intf_dl_join_sql || ' AND NVL('||l_data_level_column_3||',-1) = NVL(INTRFC.'||l_data_level_column_3||', -1) ';
    END IF;
  END IF;




  -----------------------------------------------------------------------
  -- Looping thru distinct attr groups to be present in the intf table --
  -----------------------------------------------------------------------
  OPEN l_dynamic_dist_ag_cursor FOR
      ' SELECT DISTINCT ATTR_GROUP_INT_NAME
          FROM '||p_interface_table_name||' UAI1
         WHERE DATA_SET_ID = :data_set_id
           AND ATTR_GROUP_TYPE = :attr_group_type
           AND UAI1.PROCESS_STATUS = '||G_PS_IN_PROCESS||' '
  USING p_data_set_id, p_attr_group_type;
  LOOP
    FETCH l_dynamic_dist_ag_cursor INTO l_attr_group_int_name;
    EXIT WHEN l_dynamic_dist_ag_cursor%NOTFOUND;

    code_debug('        ... Processing attr group '||l_attr_group_int_name ,2);

    -------------------------------------------------------------
    -- Find out weather the ATTR_GROUP_ID column exists in the --
    -- table where attribute data is to be uploaded or not     --
    -------------------------------------------------------------
    /* bug 9849770 we can't use this API since it is querying all_tables to find out if col exists or not, while l_ext_vl_table_name is actually a view
       it will always return false for this API. Change back to the code R12.0 used in determine if attrGroup id exists
    l_ag_id_col_exists :=  FND_API.TO_BOOLEAN(
            EGO_USER_ATTRS_COMMON_PVT.has_column_in_table(
              p_table_name => l_ext_vl_table_name,
              p_column_name => 'ATTR_GROUP_ID')); */
    BEGIN
      l_dynamic_sql := ' SELECT ATTR_GROUP_ID FROM '||l_ext_vl_table_name||' WHERE ROWNUM=1 ';
      EXECUTE IMMEDIATE l_dynamic_sql;
      l_ag_id_col_exists := TRUE;
    EXCEPTION
      WHEN OTHERS THEN
        l_ag_id_col_exists := FALSE;
    END;
    -- End bug 9849770

    l_attr_group_metadata_obj := EGO_USER_ATTRS_COMMON_PVT.Get_Attr_Group_Metadata(
                                   p_attr_group_id   => NULL
                                  ,p_application_id  => p_application_id
                                  ,p_attr_group_type => p_attr_group_type
                                  ,p_attr_group_name => l_attr_group_int_name
                                 );

    --------------------------------------------------------------------
    -- Here we build the SQL to be executed for each of the attribute --
    -- groups present in the interface table                          --
    --------------------------------------------------------------------
    l_dynamic_sql := ' UPDATE '||p_interface_table_name||' INTRFC '||
                     '    SET PROCESS_STATUS = '||p_new_status||
                     '  WHERE PROCESS_STATUS = '||G_PS_IN_PROCESS||
                     '    AND ATTR_GROUP_INT_NAME = '''||l_attr_group_int_name||''' '||
                     '    AND ATTR_GROUP_TYPE = '''||p_attr_group_type||''' '||
                     '    AND DATA_SET_ID = :data_set_id '||
                     '    AND EXISTS ( SELECT 1 '||
                     '                   FROM '||l_ext_vl_table_name||
                     '                  WHERE 1=1 ';

    IF(l_ag_id_col_exists) THEN
        l_dynamic_sql := l_dynamic_sql||'  AND ATTR_GROUP_ID = INTRFC.ATTR_GROUP_ID ';
    END IF;

    l_dynamic_sql := l_dynamic_sql||l_ext_intf_pk_join_sql||l_ext_intf_dl_join_sql;

    l_uk_where_caluse := '';
    l_str_attr_decode_list_Ext := '';
    l_num_attr_decode_list_Ext := '';
    l_date_attr_decode_list_Ext := '';
    l_uk_attr_list := '';
    --FP bug 8274031
    l_str_attr_decode_list_Intf := '';
    l_num_attr_decode_list_Intf := '';
    l_date_attr_decode_list_Intf := '';
    --FP bug 8274031
    l_attr_metadata_table := l_attr_group_metadata_obj.ATTR_METADATA_TABLE;
    ------------------------------------------------------
    -- Looping through the attrs for building the SQL
    ------------------------------------------------------
    FOR i IN l_attr_metadata_table.FIRST .. l_attr_metadata_table.LAST
    LOOP

      IF (l_attr_group_metadata_obj.MULTI_ROW_CODE = 'Y' AND l_attr_metadata_table(i).UNIQUE_KEY_FLAG = 'Y') THEN

          l_uk_attr_list := l_uk_attr_list||' '''||l_attr_metadata_table(i).ATTR_NAME||''', ';
          IF (l_attr_metadata_table(i).DATA_TYPE_CODE = EGO_EXT_FWK_PUB.G_NUMBER_DATA_TYPE) THEN

              l_uk_where_caluse := l_uk_where_caluse||
                       ' AND NVL('||l_attr_metadata_table(i).DATABASE_COLUMN||', '||G_NULL_TOKEN_NUM||' ) '||
                       '   = NVL((SELECT ATTR_VALUE_NUM '||
                       '            FROM '||p_interface_table_name||' UAI '||
                       '           WHERE UAI.DATA_SET_ID = :data_set_id '||
                       '             AND UAI.ATTR_GROUP_INT_NAME = '''||l_attr_group_int_name||''' '||
                       '             AND UAI.PROCESS_STATUS = '||G_PS_IN_PROCESS||
                       '             AND UAI.ATTR_INT_NAME = '''||l_attr_metadata_table(i).ATTR_NAME||''' '||
                       '             AND UAI.ROW_IDENTIFIER = INTRFC.ROW_IDENTIFIER '||
                       '          ) '||
                       '          ,'||G_NULL_TOKEN_NUM||' ) ';

           ELSIF (l_attr_metadata_table(i).DATA_TYPE_CODE = EGO_EXT_FWK_PUB.G_DATE_DATA_TYPE OR
                 l_attr_metadata_table(i).DATA_TYPE_CODE = EGO_EXT_FWK_PUB.G_DATE_TIME_DATA_TYPE) THEN

              l_uk_where_caluse := l_uk_where_caluse||
                       ' AND NVL('||l_attr_metadata_table(i).DATABASE_COLUMN||', '||G_NULL_TOKEN_DATE||' ) '||
                       '   = NVL((SELECT ATTR_VALUE_DATE '||
                       '            FROM '||p_interface_table_name||' UAI '||
                       '           WHERE UAI.DATA_SET_ID = :data_set_id '||
                       '             AND UAI.ATTR_GROUP_INT_NAME = '''||l_attr_group_int_name||''' '||
                       '             AND UAI.PROCESS_STATUS = '||G_PS_IN_PROCESS||
                       '             AND UAI.ATTR_INT_NAME = '''||l_attr_metadata_table(i).ATTR_NAME||''' '||
                       '             AND UAI.ROW_IDENTIFIER = INTRFC.ROW_IDENTIFIER '||
                       '          ) '||
                       '          ,'||G_NULL_TOKEN_DATE||' ) ';

          ELSE

              l_uk_where_caluse := l_uk_where_caluse||
                       ' AND NVL('||l_attr_metadata_table(i).DATABASE_COLUMN||', '||G_NULL_TOKEN_STR||' ) '||
                       '   = NVL((SELECT ATTR_VALUE_STR '||
                       '            FROM '||p_interface_table_name||' UAI '||
                       '           WHERE UAI.DATA_SET_ID = :data_set_id '||
                       '             AND UAI.ATTR_GROUP_INT_NAME = '''||l_attr_group_int_name||''' '||
                       '             AND UAI.PROCESS_STATUS = '||G_PS_IN_PROCESS||
                       '             AND UAI.ATTR_INT_NAME = '''||l_attr_metadata_table(i).ATTR_NAME||''' '||
                       '             AND UAI.ROW_IDENTIFIER = INTRFC.ROW_IDENTIFIER '||
                       '          ) '||
                       '          ,'||G_NULL_TOKEN_STR||' ) ';

          END IF;

      ELSE -- If the AG is not multi row and the attr being processed is not a UK

          IF (l_attr_metadata_table(i).DATA_TYPE_CODE = EGO_EXT_FWK_PUB.G_NUMBER_DATA_TYPE) THEN
              l_num_attr_decode_list_Ext := l_num_attr_decode_list_Ext||' ,'''||l_attr_metadata_table(i).ATTR_NAME||''' ,'||l_attr_metadata_table(i).DATABASE_COLUMN;
              l_num_attr_decode_list_Intf := l_num_attr_decode_list_Intf||' ,'''||l_attr_metadata_table(i).ATTR_NAME||''' , INTRFC.ATTR_VALUE_NUM ';
          ELSIF (l_attr_metadata_table(i).DATA_TYPE_CODE = EGO_EXT_FWK_PUB.G_DATE_DATA_TYPE OR
                 l_attr_metadata_table(i).DATA_TYPE_CODE = EGO_EXT_FWK_PUB.G_DATE_TIME_DATA_TYPE) THEN
              l_date_attr_decode_list_Ext := l_date_attr_decode_list_Ext||' ,'''||l_attr_metadata_table(i).ATTR_NAME||''' ,'||l_attr_metadata_table(i).DATABASE_COLUMN;
              l_date_attr_decode_list_Intf := l_date_attr_decode_list_Intf||' ,'''||l_attr_metadata_table(i).ATTR_NAME||''' , INTRFC.ATTR_VALUE_DATE ';
          ELSE
              l_str_attr_decode_list_Ext := l_str_attr_decode_list_Ext||' ,'''||l_attr_metadata_table(i).ATTR_NAME||''' ,'||l_attr_metadata_table(i).DATABASE_COLUMN;
              l_str_attr_decode_list_Intf := l_str_attr_decode_list_Intf||' ,'''||l_attr_metadata_table(i).ATTR_NAME||''' , INTRFC.ATTR_VALUE_STR ';
          END IF;

      END IF;

    END LOOP;

    -------------------------------------------------------------------
    -- Appending whatever we built in the attr loop above to the DML --
    -------------------------------------------------------------------
    IF( LENGTH(l_num_attr_decode_list_Ext)>2 ) THEN
      l_dynamic_sql := l_dynamic_sql||'  AND NVL(DECODE(INTRFC.ATTR_INT_NAME '||l_num_attr_decode_list_Intf||', NULL),'||G_NULL_TOKEN_NUM||' ) '||
                                      '   =  NVL(DECODE(INTRFC.ATTR_INT_NAME '||l_num_attr_decode_list_Ext||', NULL),'||G_NULL_TOKEN_NUM||' ) ';
    END IF;

    IF( LENGTH(l_date_attr_decode_list_Ext)>2 ) THEN
      l_dynamic_sql := l_dynamic_sql||'  AND NVL(DECODE(INTRFC.ATTR_INT_NAME '||l_date_attr_decode_list_Intf||', NULL),'||G_NULL_TOKEN_DATE||' ) '||
                                      '   =  NVL(DECODE(INTRFC.ATTR_INT_NAME '||l_date_attr_decode_list_Ext||', NULL),'||G_NULL_TOKEN_DATE||' ) ';
    END IF;

    IF( LENGTH(l_str_attr_decode_list_Ext)>2 ) THEN
      l_dynamic_sql := l_dynamic_sql||'  AND NVL(DECODE(INTRFC.ATTR_INT_NAME '||l_str_attr_decode_list_Intf||', NULL),'||G_NULL_TOKEN_STR||' ) '||
                                      '   =  NVL(DECODE(INTRFC.ATTR_INT_NAME '||l_str_attr_decode_list_Ext||', NULL),'||G_NULL_TOKEN_STR||' ) ';
    END IF;

    l_dynamic_sql := l_dynamic_sql||l_uk_where_caluse||')';

    IF(LENGTH(l_uk_attr_list)>3) THEN
      l_dynamic_sql := l_dynamic_sql||' AND ATTR_INT_NAME NOT IN ('||l_uk_attr_list||' ''!@#$%^'')';
    END IF;

    ---------------------------------
    -- Executing the Final DML     --
    ----------------------------------
    IF(l_dyn_cursor IS NULL ) THEN
      l_dyn_cursor := DBMS_SQL.Open_Cursor;
    END IF;
    DBMS_SQL.Parse(l_dyn_cursor, l_dynamic_sql, DBMS_SQL.NATIVE);
    DBMS_SQL.Bind_Variable(l_dyn_cursor, ':data_set_id', p_data_set_id);
    l_dummy := DBMS_SQL.Execute(l_dyn_cursor);
   END LOOP; --Ending the loop for distinct AG's

   IF (l_dyn_cursor IS NOT NULL) THEN
     DBMS_SQL.Close_Cursor(l_dyn_cursor);
   END IF;

  --------------------------------
  -- Standard check of p_commit --
  --------------------------------
  IF FND_API.To_Boolean(p_commit) THEN
    COMMIT WORK;
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
  WHEN OTHERS THEN
   x_return_status  := FND_API.G_RET_STS_UNEXP_ERROR;
   x_msg_data := 'Executing - EGO_USER_ATTRS_BULK_PVT.Mark_Unchanged_Attr_Rows: '||SQLERRM;


END Mark_Unchanged_Attr_Rows;

-- abedajna Bug 6322809

-- This procedure finds the starting index of the 'final' order by clause in a sql.
-- Consider the following sql:
-- select * from (select * from abb_vs order by id desc) where rownum < 4 order by
-- ( select id from (select id from abb_vs order by id) where rownum = 1 ) asc
-- In this case, this method will return the starting index of the last order by clause
-- that is used to "order" the query result, in contrast with the order by clause
-- which is used as an integral part of the query to "determine" the query result

-- Algorithm used:
-- Is the whereclause null? exit ; else continue
-- Does the whereclause start with order by? exit ; else continue
-- Only /* ... */ type of comments are allowed in value set whereclauses. Parse the query to strip
-- it of all comments. Users may put parentheses in comments that can interefere with the following algorithm.
-- Start investigating the remaining whereclause from the end.
-- Get the position of the first order by clause (i.e. the last one).
-- Calculate the number of '(' and the number of ')' after the order by clause.
-- Are they equal? If yes, that's the last order by.
-- No? Get the order by prior to that, from the end of the string, backwards, and repeat the same calculation.
-- When you get the target order by clause, seperate it out, take the rest of the whereclause,
-- assuming it's not null, wrap it around parenthesis, add it back to the whereclause and return the result.

function process_whereclause (p_whereclausein in varchar2) return varchar2 is
len number;
pos number;
cls varchar2(32767);
startcomment number;
endcomment number;
l_whereclausein varchar2(32767);
begin

--Bug 9733672, adding the validations about where clause with null value
/*if p_whereclausein is null then
    return null;
end if;*/
IF (Length(Trim(p_whereclausein)) IS NULL OR Length(Trim(p_whereclausein)) < 3) THEN
  RETURN p_whereclausein;
ELSE

--if ( ( instr(p_whereclausein, '(', 1,1) = 1 ) AND ( instr(p_whereclausein,')', -1,1) = length(p_whereclausein) ) ) then
--    return p_whereclausein;
--end if;

startcomment := instr(p_whereclausein, '/*', 1,1);
endcomment := instr(p_whereclausein, '*/', 1,1);
if (( startcomment <> 0 ) OR (endcomment <> 0)) then
    if (( startcomment <> 0 ) AND (endcomment <> 0) AND (startcomment <
endcomment))  then
        l_whereclausein := substr(p_whereclausein, 1, startcomment - 1) ||
substr(p_whereclausein, endcomment + 2);
    else
        return p_whereclausein; -- unlikely case
    end if;
else
    l_whereclausein := p_whereclausein;
end if;

len := length(l_whereclausein);

pos := get_order_by( l_whereclausein, len );

if pos <> 0 then
    cls := substr( l_whereclausein, 1, pos-1 );
    if ( cls is not null ) then
        return '('||cls||')'||substr(l_whereclausein, pos);
    -- Sean, bug 12910136, add the return value for else case
    else
        return '('||l_whereclausein||')';
    end if;
else
    return '('||l_whereclausein||')';
end if;
END IF;  --end if for 'IF (Length(Trim(p_whereclausein)) IS NULL ) THEN'
end process_whereclause;


-- abedajna Bug 6322809
function get_num_occur (p_string in varchar2, p_char in varchar2) return number
is
startpos number := 1;
currentpos number := 0;
num_occur number := 0;
begin
loop
    currentpos := instr(p_string, p_char, startpos);
    exit when currentpos = 0;
    num_occur := num_occur + 1;
    startpos := currentpos + 1;
end loop;
return num_occur;
end get_num_occur;


-- abedajna Bug 6322809
function get_order_by (p_whereclause in varchar2, p_len in number) return number
is
pos number := 0;
startpos number := -1;
begin
loop
    pos := instr(upper(p_whereclause), 'ORDER BY', startpos, 1);
    exit when pos = 0;
    if ( get_num_occur( substr(p_whereclause, pos), '(' ) = get_num_occur( substr(p_whereclause, pos), ')' ) ) then
        return pos;
    end if;
    startpos := (-1) * (p_len - pos + 2);
end loop;
return 0;
end get_order_by;

END EGO_USER_ATTRS_BULK_PVT;

/
