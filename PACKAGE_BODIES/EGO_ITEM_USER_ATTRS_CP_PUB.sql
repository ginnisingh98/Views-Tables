--------------------------------------------------------
--  DDL for Package Body EGO_ITEM_USER_ATTRS_CP_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EGO_ITEM_USER_ATTRS_CP_PUB" AS
/* $Header: EGOCIUAB.pls 120.59.12010000.26 2011/03/04 10:38:35 nendrapu ship $ */


                      -----------------------
                      -- Private Data Type --
                      -----------------------

    TYPE LOCAL_MEDIUM_VARCHAR_TABLE IS TABLE OF VARCHAR2(4000)
      INDEX BY BINARY_INTEGER;

                   ------------------------------
                   -- Private Global Variables --
                   ------------------------------

    G_LOG_HEAD       CONSTANT VARCHAR2(50) := 'fnd.plsql.ego.EGO_ITEM_USER_ATTRS_CP_PUB.';
    G_PKG_NAME       CONSTANT VARCHAR2(30) := 'EGO_ITEM_USER_ATTRS_CP_PUB';
    G_API_VERSION             NUMBER       := 1.0;
    G_ITEM_NAME      CONSTANT VARCHAR2(10) := 'EGO_ITEM';
    G_ITEM_OBJECT_ID          NUMBER;

    /*** The following two variables are for Error_Handler ***/
    G_ENTITY_ID                  NUMBER;
    G_ENTITY_CODE      CONSTANT  VARCHAR2(30) := 'ITEM_USER_ATTRS_ENTITY_CODE';

    G_REQUEST_ID                 NUMBER;
    G_PROGAM_APPLICATION_ID      NUMBER;
    G_PROGAM_ID                  NUMBER;
    G_USER_NAME                  FND_USER.USER_NAME%TYPE;
    G_USER_ID                    NUMBER;
    G_LOGIN_ID                   NUMBER;
    G_HZ_PARTY_ID                VARCHAR2(30);

    G_NO_CURRVAL_YET             EXCEPTION;
    G_NO_USER_NAME_TO_VALIDATE   EXCEPTION;

    --To return new set of RETCODE
    L_CONC_RET_STS_SUCCESS       VARCHAR2(1):= '0';
    L_CONC_RET_STS_WARNING       VARCHAR2(1):= '1';
    L_CONC_RET_STS_ERROR         VARCHAR2(1):= '2';

    G_FND_RET_STS_WARNING        VARCHAR2(1) := 'W';

    G_DEBUG_LEVEL_UNEXPECTED CONSTANT NUMBER := FND_LOG.LEVEL_UNEXPECTED;
    G_DEBUG_LEVEL_ERROR      CONSTANT NUMBER := FND_LOG.LEVEL_ERROR;
    G_DEBUG_LEVEL_EXCEPTION  CONSTANT NUMBER := FND_LOG.LEVEL_EXCEPTION;
    G_DEBUG_LEVEL_EVENT      CONSTANT NUMBER := FND_LOG.LEVEL_EVENT;
    G_DEBUG_LEVEL_PROCEDURE  CONSTANT NUMBER := FND_LOG.LEVEL_PROCEDURE;
    G_DEBUG_LEVEL_STATEMENT  CONSTANT NUMBER := FND_LOG.LEVEL_STATEMENT;
    G_LOG_TIMESTAMP_FORMAT   CONSTANT VARCHAR2( 30 ) := 'dd-mon-yyyy hh:mi:ss.ff';

    G_CURRENT_DEBUG_LEVEL        NUMBER;
    G_TABLE_NAME                 VARCHAR2(30) := 'EGO_ITM_USR_ATTR_INTRFC';--BUG   5352217

               -------------------------------------
               -- Pragma for Data Set ID function --
               -------------------------------------
    PRAGMA EXCEPTION_INIT (G_NO_CURRVAL_YET, -08002);

                 ----------------------------------
                 -- Private Function Declaration --
                 ----------------------------------

  ----------------------------------------------------------------------
  -- Private Procedure
  ----------------------------------------------------------------------
  PROCEDURE code_debug (p_log_level  IN NUMBER
                       ,p_module     IN VARCHAR2
                       ,p_message    IN VARCHAR2
                      ) IS
  BEGIN
    IF (p_log_level >= G_CURRENT_DEBUG_LEVEL ) THEN
      IF NVL(FND_GLOBAL.conc_request_id, -1) <> -1 THEN
        FND_FILE.put_line(which => FND_FILE.LOG
                         ,buff  => '['||G_PKG_NAME||' - '||p_module||'] - '||p_message);
      ELSE
        fnd_log.string(log_level => p_log_level
                      ,module    => G_LOG_HEAD||p_module
                      ,message   => p_message
                      );
      END IF;
    END IF;
  /***
    IF p_module = 'Copy_data_to_Intf' THEN
    sri_debug(G_PKG_NAME||' - '||p_module||' - '||p_message);
    END IF;
  ***/
  EXCEPTION
    WHEN OTHERS THEN
      RAISE;
  END code_debug;


  /*
   * This method writes into concurrent program log
   */
  PROCEDURE Debug_Conc_Log( p_message IN VARCHAR2
                          , p_add_timestamp IN BOOLEAN DEFAULT TRUE )
  IS
    l_inv_debug_level  NUMBER := INVPUTLI.get_debug_level;     --Bug: 4667452
    l_message          VARCHAR2(3800);
  BEGIN
    IF l_inv_debug_level IN(101, 102) THEN
      IF LENGTH(p_message) > 3800 THEN
        FOR i IN 1..( CEIL(LENGTH(p_message)/3800) ) LOOP
          l_message := SUBSTR(p_message, ( 3800*(i-1) + 1 ), 3800 );
          INVPUTLI.info(  ( CASE
                            WHEN p_add_timestamp THEN to_char( systimestamp, G_LOG_TIMESTAMP_FORMAT ) || ': '
                            ELSE ''
                            END  )
                       ||   l_message );
        END LOOP;
      ELSE
        INVPUTLI.info(  ( CASE
                          WHEN p_add_timestamp THEN to_char( systimestamp, G_LOG_TIMESTAMP_FORMAT ) || ': '
                          ELSE ''
                          END  )
                     ||   p_message );
      END IF;
    END IF;
  END Debug_Conc_Log;

  ----------------------------------------------------------------------
  -- Private Procedure
  ----------------------------------------------------------------------
  PROCEDURE write_intf_records (p_data_set_id    in number
                               ,p_process_status in number
                               ,p_transaction_type in varchar2
                               ,p_data_level_id  in number
                               ,p_count   IN  NUMBER
                               ) IS
  -- PRAGMA AUTONOMOUS_TRANSACTION;

    l_rec  ego_itm_usr_attr_intrfc%ROWTYPE;
    l_dummy_number  NUMBER;
  BEGIN
  NULL;
  /*
    SELECT count(*)
    INTO l_dummy_number
    FROM ego_itm_usr_attr_intrfc
    WHERE data_set_id = p_data_set_id
      AND process_status = p_process_status
      AND transaction_type = p_transaction_type
      AND data_level_id = p_data_level_id;
    code_debug(p_log_level => 0
              ,p_module => 'Copy_data_to_Intf'
              ,p_message => p_count||' - No records in intf table '||l_dummy_number
              );
    IF l_dummy_number > 0 THEN
      code_debug(p_log_level => 0
                ,p_module => 'Copy_data_to_Intf'
                ,p_message => p_count||' Writing data in format '||
          ' inventory_item_id, organization_id, data_level_id, revision_id, pk1_value, pk2_value, '||
          ' attr_group_id, attr_group_int_name, attr_int_name, attr_value_str, attr_value_num, '||
          ' row_identifier');
      IF p_count < 100 THEN
        FOR cr in (SELECT * FROM ego_itm_usr_attr_intrfc
                    WHERE data_set_id = p_data_set_id
                      AND process_status = p_process_status
                      AND transaction_type = p_transaction_type
                      AND data_level_id = p_data_level_id
                ORDER BY inventory_item_id, organization_id, data_level_id,
                         revision_id, pk1_value, pk2_value, attr_group_id,
                         attr_int_name, row_identifier
                  ) LOOP
          code_debug(p_log_level => 0
                    ,p_module => 'Copy_data_to_Intf'
                    ,p_message => p_count||' - '||cr.inventory_item_id||', '||
                           cr.organization_id||', '||cr.data_level_id||', '||cr.revision_id||', '||
                           cr.pk1_value||',  '||cr.pk2_value||', '||cr.attr_group_id||', '||
                           cr.attr_group_int_name||', '||cr.attr_int_name||',  '||
                           cr.attr_value_str||', '||cr.attr_value_num||', '||cr.row_identifier);
        END LOOP;
      END IF;
    END IF;

    BEGIN
        SELECT count(*) abc
      into l_dummy_number
        FROM EGO_ITM_USR_ATTR_INTRFC
        WHERE data_set_id = p_data_set_id
  --        AND process_status = 1
  --        AND transaction_type = p_transaction_type
  --        AND data_level_id = p_data_level_id
          AND attr_int_name = 'QualityManual'
          HAVING count(*) > 2;

      IF l_dummy_number > 2 THEN
         commit;
         sri_debug('Copy_data_to_Intf: Returning now');
         RAISE TOO_MANY_ROWS;
      END IF;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        NULL;
    END;
  */

  END;

  ----------------------------------------------------------------------
  -- Private Procedure
  ----------------------------------------------------------------------
  PROCEDURE write_records (p_data_set_id IN NUMBER
                          ,p_module      IN VARCHAR2
                          ,p_message     IN VARCHAR2) IS
    l_rec  ego_itm_usr_attr_intrfc%ROWTYPE;
    CURSOR get_records IS
    SELECT *
    FROM ego_itm_usr_attr_intrfc
    WHERE data_set_id = p_data_set_id;
  begin
    FOR cr IN get_records LOOP
      code_debug (p_log_level => G_DEBUG_LEVEL_STATEMENT
                 ,p_module    => p_module
                 ,p_message   => 'Rec Info '||p_message||' : '||
                        ' inventory_item_id: '|| cr.inventory_item_id||
                        ' organization_id: '|| cr.organization_id||
                        ' row_identifier: ' ||cr.row_identifier||
                        ' process_status: ' ||cr.process_status||
                        ' attr_group_id: '||cr.attr_group_id||
                        ' attr_group_int_name: '||cr.attr_group_int_name||
                        ' attr_int_name: '||cr.attr_int_name||
                        ' item_catalog_group_id: '||cr.item_catalog_group_id||
                        ' parent_catalog_group_id: '||cr.prog_int_num1||
                        ' item_lc_id: '||cr.prog_int_num2||
                        ' item_phase_id: '||cr.prog_int_num3||
                        ' item_approval_status: '||cr.prog_int_char1||
                        ' item_rev_just_created: '||cr.prog_int_char2
                  );
    END LOOP;
  end write_records;
  ----------------------------------------------------------------------
  -- Private Procedure
  ----------------------------------------------------------------------

PROCEDURE SetGlobals IS
BEGIN
  G_REQUEST_ID              := FND_GLOBAL.CONC_REQUEST_ID;
  G_PROGAM_APPLICATION_ID   := FND_GLOBAL.PROG_APPL_ID;
  G_PROGAM_ID               := FND_GLOBAL.CONC_PROGRAM_ID;
  G_USER_NAME               := FND_GLOBAL.USER_NAME;
  G_USER_ID                 := FND_GLOBAL.USER_ID;
  G_LOGIN_ID                := FND_GLOBAL.LOGIN_ID;
  G_CURRENT_DEBUG_LEVEL     := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
END;

----------------------------------------------------------------------
-- Private Function
----------------------------------------------------------------------

FUNCTION Build_Parent_Cat_Group_List (
        p_catalog_group_id              IN   NUMBER
       ,p_entity_index                  IN   NUMBER
)
RETURN VARCHAR2
IS

  l_parent_cat_group_list  VARCHAR2(1000) := '';
  l_token_table            ERROR_HANDLER.Token_Tbl_Type;
  -------------------------------------------------------------------------
  -- For finding all parent catalog groups for the current catalog group --
  -------------------------------------------------------------------------
  CURSOR parent_catalog_group_cursor  IS
  SELECT ITEM_CATALOG_GROUP_ID, PARENT_CATALOG_GROUP_ID
    FROM MTL_ITEM_CATALOG_GROUPS_B
  CONNECT BY PRIOR PARENT_CATALOG_GROUP_ID = ITEM_CATALOG_GROUP_ID
   START WITH ITEM_CATALOG_GROUP_ID = p_catalog_group_id;

  BEGIN

    -------------------------------------------------------------------
    -- We build a list of all parent catalog groups, as long as the  --
    -- list is less than 151 characters long (the longest we can fit --
    -- into the EGO_COL_NAME_VALUE_PAIR_OBJ is 150 chars); if the    --
    -- list is too long to fully copy, we can only hope that the     --
    -- portion we copied will contain all the information we need.   --
    -------------------------------------------------------------------
    FOR cat_rec IN parent_catalog_group_cursor
    LOOP
      IF (cat_rec.PARENT_CATALOG_GROUP_ID IS NOT NULL) THEN
        l_parent_cat_group_list := l_parent_cat_group_list ||
                                   cat_rec.PARENT_CATALOG_GROUP_ID || ',';
      END IF;
    END LOOP;
    ---------------------------------------------------------------------
    -- Trim the trailing ',' from l_parent_cat_group_list if necessary --
    ---------------------------------------------------------------------
    IF (LENGTH(l_parent_cat_group_list) > 0) THEN
      l_parent_cat_group_list := SUBSTR(l_parent_cat_group_list, 1, LENGTH(l_parent_cat_group_list) - LENGTH(','));
    END IF;
    RETURN l_parent_cat_group_list;
  EXCEPTION
    WHEN OTHERS THEN
      l_token_table(1).TOKEN_NAME := 'CAT_GROUP_NAME';
      SELECT CONCATENATED_SEGMENTS
        INTO l_token_table(1).TOKEN_VALUE
        FROM MTL_ITEM_CATALOG_GROUPS_KFV
       WHERE ITEM_CATALOG_GROUP_ID = p_catalog_group_id;
      ERROR_HANDLER.Add_Error_Message(
        p_message_name                  => 'EGO_TOO_MANY_CAT_GROUPS'
       ,p_application_id                => 'EGO'
       ,p_token_tbl                     => l_token_table
       ,p_message_type                  => FND_API.G_RET_STS_ERROR
       ,p_entity_id                     => G_ENTITY_ID
       ,p_entity_index                  => p_entity_index
       ,p_entity_code                   => G_ENTITY_CODE
       ,p_table_name                  => G_TABLE_NAME
      );

    ---------------------------------------------------------------------
    -- Trim the trailing ',' from l_parent_cat_group_list if necessary --
    ---------------------------------------------------------------------
    IF (LENGTH(l_parent_cat_group_list) > 0) THEN
      l_parent_cat_group_list :=
            SUBSTR(l_parent_cat_group_list, 1,
                   LENGTH(l_parent_cat_group_list) - LENGTH(','));
    END IF;

    RETURN l_parent_cat_group_list;

END Build_Parent_Cat_Group_List;

----------------------------------------------------------------------

                 ----------------------------------
                 -- Public Function Declaration --
                 ----------------------------------

----------------------------------------------------------------------

PROCEDURE Get_Item_Security_Predicate (
        p_object_name                   IN   VARCHAR2
       ,p_party_id                      IN   VARCHAR2
       ,p_privilege_name                IN   VARCHAR2
       ,p_table_alias                   IN   VARCHAR2
       ,x_security_predicate            OUT NOCOPY VARCHAR2
) IS

  l_return_status         VARCHAR2(30);
  l_table_alias           VARCHAR2(100);
  l_security_predicate    VARCHAR2(32767);
  l_api_name              VARCHAR2(30);
  l_request_id_clause     VARCHAR2(500);
  l_process_flag          VARCHAR2(10);
 BEGIN
    l_api_name := 'Get_Item_Security_Predicate';
    SetGlobals();
    code_debug (p_log_level => G_DEBUG_LEVEL_PROCEDURE
               ,p_module    => l_api_name
               ,p_message   =>  'Started with 5 params '||
                   ' p_object_name: '|| p_object_name ||
                   ' - p_party_id: '|| p_party_id ||
                   ' - p_privilege_name: '|| p_privilege_name ||
                   ' - p_table_alias: '|| p_table_alias
               );

    IF (LENGTH(p_table_alias) > 0) THEN
      l_table_alias := p_table_alias || '.';
    END IF;

    EGO_DATA_SECURITY.get_security_predicate(
      p_api_version      => 1.0
     ,p_function         => p_privilege_name
     ,p_object_name      => p_object_name
     ,p_user_name        => p_party_id
     ,p_statement_type   => 'EXISTS'
     ,p_pk1_alias        => l_table_alias||'INVENTORY_ITEM_ID'
     ,p_pk2_alias        => l_table_alias||'ORGANIZATION_ID'
     ,x_predicate        => x_security_predicate
     ,x_return_status    => l_return_status
    );

    IF (x_security_predicate IS NULL) THEN
      x_security_predicate := ' 1=1 '; --for internal users the security predicate is returned as null.
    ELSE
      x_security_predicate := x_security_predicate ||
                                 ' AND NOT EXISTS
                                    (SELECT 1
                                     FROM MTL_SYSTEM_ITEMS_INTERFACE msii_e
                                     WHERE msii_e.TRANSACTION_TYPE  = ''CREATE''
                                       AND msii_e.PROCESS_FLAG      = 1
                                       AND msii_e.SET_PROCESS_ID    = UAI2.DATA_SET_ID
                                       AND msii_e.INVENTORY_ITEM_ID = UAI2.INVENTORY_ITEM_ID
                                       AND msii_e.ORGANIZATION_ID   = UAI2.ORGANIZATION_ID)';
    END IF;
    code_debug (p_log_level => G_DEBUG_LEVEL_PROCEDURE
               ,p_module    => l_api_name
               ,p_message   =>  'Returning params '||
                   ' x_security_predicate: '|| x_security_predicate
               );
END Get_Item_Security_Predicate;


                          ----------------
                          -- Procedures --
                          ----------------

----------------------------------------------------------------------

PROCEDURE Process_Item_User_Attrs_Data
(
        ERRBUF                          OUT NOCOPY VARCHAR2
       ,RETCODE                         OUT NOCOPY VARCHAR2
       ,p_data_set_id                   IN   NUMBER
       ,p_debug_level                   IN   NUMBER   DEFAULT 0
       ,p_purge_successful_lines        IN   VARCHAR2 DEFAULT FND_API.G_FALSE
       ,p_initialize_error_handler      IN   VARCHAR2 DEFAULT FND_API.G_TRUE
       ,p_validate_only                 IN   VARCHAR2 DEFAULT FND_API.G_FALSE
       ,p_ignore_security_for_validate  IN   VARCHAR2 DEFAULT FND_API.G_FALSE
       ,p_commit                        IN  VARCHAR2 DEFAULT   FND_API.G_TRUE   /* Added to fix Bug#7422423*/
       ,p_is_id_validations_reqd        IN  VARCHAR2 DEFAULT  FND_API.G_TRUE  /* Fix for bug#9660659 */
) IS
    l_api_name               VARCHAR2(30);
    l_error_message_name     VARCHAR2(30);
    l_entity_index_counter   NUMBER := 0;
    l_catalog_category_names_table LOCAL_MEDIUM_VARCHAR_TABLE;
    l_current_attr_group_obj EGO_ATTR_GROUP_METADATA_OBJ;
    l_policy_check_name      VARCHAR2(30);
    l_add_all_to_cm          VARCHAR2(1);
    l_current_attr_group_name   FND_DESCR_FLEX_CONTEXTS_TL.descriptive_flex_context_name%TYPE;
    l_current_category_name  MTL_ITEM_CATALOG_GROUPS_KFV.concatenated_segments%TYPE;
    l_current_life_cycle     VARCHAR2(240);
    l_current_phase_name     VARCHAR2(240);
    l_prev_loop_org_id       NUMBER;
    l_prev_loop_inv_item_id  NUMBER;
    l_prev_loop_row_identifier NUMBER;
    l_at_start_of_instance   BOOLEAN;
    l_can_edit_this_instance VARCHAR2(1);
    l_token_table            ERROR_HANDLER.Token_Tbl_Type;
    l_could_edit_prev_instance VARCHAR2(1);
    l_at_start_of_row        BOOLEAN;
    p_pk_column_name_value_pairs EGO_COL_NAME_VALUE_PAIR_ARRAY;
    p_class_code_name_value_pairs EGO_COL_NAME_VALUE_PAIR_ARRAY;
    p_attributes_row_table   EGO_USER_ATTR_ROW_TABLE;
    p_attributes_data_table  EGO_USER_ATTR_DATA_TABLE;
    l_user_privileges_table  EGO_DATA_SECURITY.EGO_PRIVILEGE_NAME_TABLE_TYPE;
    l_privilege_table_index  NUMBER;
    l_previous_privs_table   EGO_VARCHAR_TBL_TYPE;
    l_current_privs_table    EGO_VARCHAR_TBL_TYPE;
    l_failed_row_id_buffer   VARCHAR2(32767);
    l_failed_row_id_list     VARCHAR2(32767);
    l_failed_row_id_sql      VARCHAR2(32767);
    l_return_status          VARCHAR2(1);
    l_errorcode              NUMBER;
    l_msg_count              NUMBER;
    l_msg_data               VARCHAR2(1000);
    l_dynamic_sql            VARCHAR2(32767);
    l_policy_check_sql       VARCHAR2(32767);
    l_debug_rowcount         NUMBER := 0;
    l_rec_count              NUMBER;
    l_err_reporting_transaction_id NUMBER;
    l_related_class_codes_query      VARCHAR2(1000);
    l_user_attrs_return_status       VARCHAR2(1);
    l_item_return_status             VARCHAR2(1);
    l_attr_group_type                VARCHAR2(30);
    l_entity_sql                     VARCHAR2(5000);
    G_UNHANDLED_EXCEPTION            EXCEPTION;
    l_target_entity_sql              VARCHAR2(5000);
    l_excluded_ag_list               VARCHAR2(1000);
    l_gtinval_ret_code               VARCHAR2(1);
    l_user_id        NUMBER := FND_GLOBAL.USER_ID;
    l_login_id       NUMBER := FND_GLOBAL.LOGIN_ID;
    l_privilege_predicate_api_name   VARCHAR2(1000);
    l_item_sup_dl_id                 NUMBER;
    l_item_sup_site_dl_id            NUMBER;
    l_item_sup_site_org_dl_id        NUMBER;
    l_item_data_level_id_str         VARCHAR2(10000); --Bug 9325678
    l_erase_revision_sql             VARCHAR2(10000); --Bug 9325678

    /* Fix for bug#9660659 - Start */
    l_item_mgmt_count         NUMBER := 0;
    l_item_gtin_count         NUMBER := 0;
    l_item_gtin_multi_count   NUMBER := 0;
    /* Fix for bug#9660659 - End */

    -- Bug 10263673 : Start
    l_enabled_for_data_pool  VARCHAR2(1);
    l_copy_option_exists     VARCHAR2(1);
    l_retcode                VARCHAR2(1);
    l_errbuf                 VARCHAR2(4000);
    l_return                 BOOLEAN;
    -- Bug 10263673 : End

    -------------------------------------------------------------------------
    --                   PIM for Telco item uda validations                --
    -------------------------------------------------------------------------

    /*profile_value varchar2(1) := fnd_profile.value('EGO_ENABLE_P4T');
    l_com_attr_group_type VARCHAR2(40);
    l_com_attr_group_name VARCHAR2(30) := NULL;
    l_com_attr_group_id NUMBER;
    l_com_attr_int_name VARCHAR2(30);
    l_attributes_data_table  EGO_USER_ATTR_DATA_TABLE;
    l_pk_column_name_value_pairs EGO_COL_NAME_VALUE_PAIR_ARRAY;
    --l_class_code_name_value_pairs EGO_COL_NAME_VALUE_PAIR_ARRAY;
    l_telco_return_status VARCHAR2(1);
    l_error_messages EGO_COL_NAME_VALUE_PAIR_ARRAY := EGO_COL_NAME_VALUE_PAIR_ARRAY();
    l_error_col_name_pairs EGO_COL_NAME_VALUE_PAIR_ARRAY :=EGO_COL_NAME_VALUE_PAIR_ARRAY();

    l_old_com_attr_group_type VARCHAR2(30);
    l_old_com_attr_group_name VARCHAR2(30);
    l_old_com_attr_group_id NUMBER;
    l_old_inventory_item_id NUMBER;
    l_old_revision_id NUMBER;
    l_old_organization_id NUMBER;
    l_old_catalog_category_id NUMBER;

    l_curr_data_element                 EGO_USER_ATTR_DATA_OBJ;
    l_curr_pk_col_name_val_element      EGO_COL_NAME_VALUE_PAIR_OBJ;
    l_curr_class_cd_val_element         EGO_COL_NAME_VALUE_PAIR_OBJ;
    l_error_element                     EGO_COL_NAME_VALUE_PAIR_OBJ;

    l_inventory_item_id NUMBER;
    l_revision_id NUMBER;
    l_organization_id NUMBER;
    l_catalog_category_id NUMBER;

    l_value_str VARCHAR2(1000);
    l_value_num NUMBER;
    l_value_date DATE;
    l_value VARCHAR2(1000);
    l_next_attr_group BOOLEAN := FALSE;
    l_validate_data BOOLEAN := FALSE;
    l_mark_error_record BOOLEAN := FALSE;
    l_row_identifier NUMBER;

    l_error_attr_name  VARCHAR2(1000);
    l_error_attr_group_name VARCHAR2(30);
    l_name VARCHAR2(30);
    l_err_value VARCHAR2(150);
    l_error_message VARCHAR2(30);
    l_error_row_identifier NUMBER;
    l_dynamic_sqlt   VARCHAR2(32767);

    -- PIM for Telco item uda validations ends
    */
    -------------------------------------------------------------------------
    -- For finding Inventory Item ID using Organization ID and Item Number --
    -------------------------------------------------------------------------
    CURSOR item_num_to_id_cursor (cp_data_set_id IN NUMBER)
    IS
    SELECT DISTINCT
           ORGANIZATION_ID
          ,ITEM_NUMBER
      FROM EGO_ITM_USR_ATTR_INTRFC
     WHERE DATA_SET_ID = cp_data_set_id
       AND PROCESS_STATUS = G_PS_IN_PROCESS
       AND ITEM_NUMBER IS NOT NULL
       AND INVENTORY_ITEM_ID IS NULL;

    ---------------------------------------------------------------
    -- For reporting errors for all of the four conversion steps --
    ---------------------------------------------------------------

    CURSOR error_case_cursor (cp_data_set_id IN NUMBER)
    IS
    SELECT DISTINCT
           PROCESS_STATUS
          ,ORGANIZATION_CODE
          ,ORGANIZATION_ID
          ,ITEM_NUMBER
          ,INVENTORY_ITEM_ID
          ,ATTR_GROUP_ID
          ,ATTR_GROUP_INT_NAME
          ,REVISION
          ,REVISION_ID
          ,ITEM_CATALOG_GROUP_ID
          ,TRANSACTION_ID
          ,ATTR_GROUP_TYPE
          ,PROG_INT_NUM1
          ,PROG_INT_NUM2
          ,PROG_INT_NUM3
          ,ATTR_VALUE_STR
          ,ATTR_VALUE_NUM
          ,ATTR_VALUE_DATE
          ,ATTR_DISP_VALUE
          ,PK1_VALUE
          ,PK2_VALUE
          ,DATA_LEVEL_NAME
          ,USER_DATA_LEVEL_NAME
      FROM EGO_ITM_USR_ATTR_INTRFC
     WHERE DATA_SET_ID = cp_data_set_id
       AND PROCESS_STATUS IN (G_PS_BAD_ORG_ID,
                              G_PS_BAD_ORG_CODE,
                              G_PS_BAD_ITEM_ID,
                              G_PS_BAD_ITEM_NUMBER,
                              G_PS_BAD_REVISION_ID,
                              G_PS_BAD_REVISION_CODE,
                              G_PS_BAD_CATALOG_GROUP_ID,
                              G_PS_BAD_ATTR_GROUP_ID,
                              G_PS_BAD_ATTR_GROUP_NAME,
                              G_PS_CHG_POLICY_NOT_ALLOWED,
                              G_PS_DATA_LEVEL_INCORRECT,
                              G_PS_BAD_DATA_LEVEL,
                              G_PS_BAD_SUPPLIER,
                              G_PS_BAD_SUPPLIER_SITE,
                              G_PS_BAD_SUPPLIER_SITE_ORG,
                              G_PS_BAD_STYLE_VAR_VALUE_SET,
                              G_PS_VAR_VSET_CHG_NOT_ALLOWED,
                              G_PS_SKU_VAR_VALUE_NOT_UPD,
                              G_PS_INH_ATTR_FOR_SKU_NOT_UPD
                             );

    -------------------------------------------------------------------
    -- For processing all rows that passed the four conversion steps --
    -------------------------------------------------------------------
    CURSOR data_set_cursor (cp_data_set_id IN NUMBER)
    IS
    SELECT TRANSACTION_ID
          ,PROCESS_STATUS
          ,ORGANIZATION_CODE
          ,ITEM_NUMBER
          ,ATTR_GROUP_INT_NAME
          ,ROW_IDENTIFIER
          ,ATTR_INT_NAME
          ,ATTR_VALUE_STR
          ,ATTR_VALUE_NUM
          ,ATTR_VALUE_DATE
          ,ATTR_DISP_VALUE
          ,TRANSACTION_TYPE
          ,ORGANIZATION_ID
          ,INVENTORY_ITEM_ID
          ,ITEM_CATALOG_GROUP_ID
          ,REVISION_ID
          ,ATTR_GROUP_ID
      FROM EGO_ITM_USR_ATTR_INTRFC
     WHERE DATA_SET_ID = cp_data_set_id
       AND PROCESS_STATUS = G_PS_IN_PROCESS
    ORDER BY ORGANIZATION_ID,
             INVENTORY_ITEM_ID,
             (DECODE (UPPER(TRANSACTION_TYPE),
                      'DELETE', 1,
                      'UPDATE', 2,
                      'SYNC', 3,
                      'CREATE', 4, 5)),
             ROW_IDENTIFIER,
             ATTR_GROUP_INT_NAME;

    --------------------------------------------------------------------------
    -- For getting this distinct catalog groups passing all the validations --
    --------------------------------------------------------------------------
    CURSOR distinct_catalaog_groups (cp_data_set_id IN NUMBER)
    IS
    SELECT ITEM_CATALOG_GROUP_ID
      FROM EGO_ITM_USR_ATTR_INTRFC
     WHERE DATA_SET_ID = cp_data_set_id
       AND PROCESS_STATUS = G_PS_IN_PROCESS
    GROUP BY ITEM_CATALOG_GROUP_ID;

    --------------------------------------------------------
    -- For validations related to pk1_value and pk2_value --
    --------------------------------------------------------
    CURSOR c_data_levels IS
      SELECT DATA_LEVEL_ID, DATA_LEVEL_NAME
      FROM EGO_DATA_LEVEL_B
      WHERE ATTR_GROUP_TYPE = 'EGO_ITEMMGMT_GROUP'
        AND APPLICATION_ID = 431
        AND DATA_LEVEL_NAME IN ('ITEM_SUP', 'ITEM_SUP_SITE', 'ITEM_SUP_SITE_ORG');

    -------------------------------------------------------------
    -- For sending default privilege names for each data level --
    -------------------------------------------------------------
    CURSOR c_data_levels_for_sec IS
      SELECT DATA_LEVEL_ID, DATA_LEVEL_NAME, ATTR_GROUP_TYPE
      FROM EGO_DATA_LEVEL_B
      WHERE APPLICATION_ID  = 431
        AND ATTR_GROUP_TYPE = 'EGO_ITEMMGMT_GROUP';

    l_default_dl_view_priv_list   EGO_COL_NAME_VALUE_PAIR_ARRAY;
    l_default_dl_edit_priv_list   EGO_COL_NAME_VALUE_PAIR_ARRAY;
    l_default_dl_view_priv_obj    EGO_COL_NAME_VALUE_PAIR_OBJ;
    l_default_dl_edit_priv_obj    EGO_COL_NAME_VALUE_PAIR_OBJ;

    -------------------------------------------------------------------------
    --                   PIM for Telco item uda validations                --
    -------------------------------------------------------------------------

    /*CURSOR c_row_identfier (cp_data_set_id IN NUMBER)
    IS
    SELECT distinct ROW_IDENTIFIER
    FROM EGO_ITM_USR_ATTR_INTRFC
    WHERE DATA_SET_ID = cp_data_set_id
    AND PROCESS_STATUS = G_PS_IN_PROCESS;

    CURSOR c_com_attr_groups (cp_data_set_id IN NUMBER, cp_row_identifier NUMBER)
    IS
    SELECT PROCESS_STATUS
          ,TRANSACTION_ID
          ,ATTR_GROUP_INT_NAME
          ,ROW_IDENTIFIER
          ,ATTR_INT_NAME
          ,ATTR_VALUE_STR
          ,ATTR_VALUE_NUM
          ,ATTR_VALUE_DATE
          ,ATTR_DISP_VALUE
          ,TRANSACTION_TYPE
          ,ORGANIZATION_ID
          ,INVENTORY_ITEM_ID
          ,ITEM_CATALOG_GROUP_ID
          ,REVISION_ID
          ,ATTR_GROUP_ID
    ,ATTR_GROUP_TYPE
    FROM EGO_ITM_USR_ATTR_INTRFC
    WHERE DATA_SET_ID = cp_data_set_id
    AND PROCESS_STATUS = G_PS_IN_PROCESS
    AND ROW_IDENTIFIER = cp_row_identifier
    ORDER BY ORGANIZATION_ID,
             INVENTORY_ITEM_ID,
             (DECODE (UPPER(TRANSACTION_TYPE),
                      'DELETE', 1,
                      'UPDATE', 2,
                      'SYNC', 3,
                      'CREATE', 4, 5)),
             ROW_IDENTIFIER,
             ATTR_GROUP_INT_NAME;
  */
  -- PIM for Telco item uda validations ends here

   -- Fix for bug#9336604
   l_schema             VARCHAR2(30);
   l_status             VARCHAR2(1);
   l_industry           VARCHAR2(1);

  BEGIN
    l_api_name := 'Process_Item_User_Attrs_Data';
    SetGlobals();
    RETCODE := L_CONC_RET_STS_SUCCESS;
    code_debug (p_log_level => G_DEBUG_LEVEL_PROCEDURE
               ,p_module    => l_api_name
               ,p_message   =>  'Started with 7 params '||
                   ' p_data_set_id: '|| p_data_set_id ||
                   ' - p_purge_successful_lines: '|| p_purge_successful_lines ||
                   ' - p_initialize_error_handler: '|| p_initialize_error_handler ||
                   ' - p_validate_only: ' || p_validate_only
               );
--    write_records(p_data_set_id => p_data_set_id, p_module => l_api_name, p_message=> 'As given');
    --If there are no rows to process for this data_set_id, return success.
    SELECT
      COUNT(DATA_SET_ID)
      INTO l_rec_count
    FROM EGO_ITM_USR_ATTR_INTRFC intf
    WHERE DATA_SET_ID = p_data_set_id
      AND (PROCESS_STATUS IS NULL OR PROCESS_STATUS IN (G_PS_TO_BE_PROCESSED, G_PS_IN_PROCESS, G_PS_STYLE_VARIANT_IN_PROCESS) );

    IF (l_rec_count = 0) THEN
      l_return := TRUE;   -- Bug 10263673, Set the falg to true, to identify that user didn't provide any values for UDAs.
      -- EGO_USER_ATTRS_DATA_PVT.Debug_Msg('Returning because no data exists in interface table to process', 0);
      -- RETURN;  -- Bug 10263673, Do not return now only.
    ELSE
      l_return := FALSE;  -- Bug 10263673, Set the falg to false, to identify that the user has given some UDA values.
    END IF;

    l_attr_group_type := 'EGO_ITEMMGMT_GROUP';
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

                     --======================--
                     -- ERROR_HANDLER SET-UP --
                     --======================--

    IF (FND_API.To_Boolean(p_initialize_error_handler)) THEN

      ERROR_HANDLER.Initialize();
      ERROR_HANDLER.Set_Bo_Identifier(EGO_USER_ATTRS_DATA_PVT.G_BO_IDENTIFIER);

      ---------------------------------------------------
      -- If we're debugging, we have to set up a Debug --
      -- session (unless our caller already did so)    --
      ---------------------------------------------------

      IF (p_debug_level > 0 AND ERROR_HANDLER.Get_Debug() = 'N') THEN
        EGO_USER_ATTRS_DATA_PVT.Set_Up_Debug_Session(G_ENTITY_ID, G_ENTITY_CODE, p_debug_level);
      END IF;
      EGO_USER_ATTRS_DATA_PVT.Debug_Msg('Starting Item/Item Revision Concurrent Program for data set ID: '||p_data_set_id, 0);
    END IF;
  --------------------------------------------------------
   -- Related classification query is required for
   -- User Attributes Bulk Load API
   --------------------------------------------------------

    l_related_class_codes_query :=
        ' (SELECT ITEM_CATALOG_GROUP_ID '||
        ' FROM MTL_ITEM_CATALOG_GROUPS_B ' ||
        ' CONNECT BY PRIOR ' ||
        ' PARENT_CATALOG_GROUP_ID = ITEM_CATALOG_GROUP_ID ' ||
        ' START WITH ' ||
        ' ITEM_CATALOG_GROUP_ID =  UAI2.ITEM_CATALOG_GROUP_ID)' ||
        ' UNION ALL ' ||
        ' (SELECT UAI2.ITEM_CATALOG_GROUP_ID FROM DUAL)' ;

              --===================================--
              -- GETTING THE INTERFACE TABLE READY --
              --===================================--

    IF (p_debug_level > 0) THEN
      EGO_USER_ATTRS_DATA_PVT.Debug_Msg('Preparing interface table', 0);
    END IF;

    -------------------------------------------------------------------
    -- Gather statistics: since the data in interface tables changes --
    -- frequently, our indexes are not very useful unless we gather  --
    -- statistics for the *current* data in the table.  (APPS has a  --
    -- standard to gather statistics at the beginning of interface   --
    -- import programs.)                                             --
    -------------------------------------------------------------------
    /*6602290 : Stats gather through profile : Stats are gathered in EGOVIMPB
    SELECT COUNT(data_set_id)
    INTO l_rec_count
    FROM EGO_ITM_USR_ATTR_INTRFC
    WHERE data_set_id = p_data_set_id;
    IF l_rec_count > 50 THEN
      FND_STATS.Gather_Table_Stats(
        ownname                    => 'EGO'
       ,tabname                    => 'EGO_ITM_USR_ATTR_INTRFC'
       ,cascade                    => TRUE
      );
    END IF;
    */
    --
    -- get the item id and store in global
    --
    BEGIN
      SELECT OBJECT_ID
      INTO G_ITEM_OBJECT_ID
      FROM FND_OBJECTS
      WHERE OBJ_NAME = G_ITEM_NAME;
    EXCEPTION
      WHEN OTHERS THEN
        IF (p_debug_level > 0) THEN
          EGO_USER_ATTRS_DATA_PVT.Debug_Msg('Cannot find object EGO_ITEM in fnd_objects ', 0);
        END IF;
        G_ITEM_OBJECT_ID := NULL;
    END;

  IF (l_return = FALSE) THEN -- Bug 10263673, If there exists user entered records, then validate them.
    ---------------------------------------------------------------------
    -- Mark all rows we'll be processing, and null out user input for  --
    -- the ITEM_CATALOG_GROUP_ID column (so we can validate it); also  --
    -- update Concurrent Request information for better user tracking  --
    -- and update the "WHO" columns on the assumption that the current --
    -- user is also the person who loaded this data set into the table --
    ---------------------------------------------------------------------
    UPDATE EGO_ITM_USR_ATTR_INTRFC
       SET PROCESS_STATUS = G_PS_IN_PROCESS
          ,ITEM_CATALOG_GROUP_ID = NULL
          ,PROG_INT_NUM1 = NULL
          ,PROG_INT_NUM2 = NULL
          ,PROG_INT_NUM3 = NULL
          ,PROG_INT_CHAR1 = 'N'
          ,PROG_INT_CHAR2 = 'N'
          ,REQUEST_ID = G_REQUEST_ID
          ,PROGRAM_APPLICATION_ID = G_PROGAM_APPLICATION_ID
          ,PROGRAM_ID = G_PROGAM_ID
          ,PROGRAM_UPDATE_DATE = SYSDATE
          ,CREATED_BY = NVL(CREATED_BY, G_USER_ID)
          ,CREATION_DATE = NVL(CREATION_DATE, SYSDATE)
          ,LAST_UPDATED_BY = G_USER_ID
          ,LAST_UPDATE_DATE = SYSDATE
          ,LAST_UPDATE_LOGIN = G_LOGIN_ID
          ,TRANSACTION_TYPE = UPPER(NVL(TRANSACTION_TYPE,EGO_USER_ATTRS_DATA_PVT.G_SYNC_MODE))
     WHERE DATA_SET_ID = p_data_set_id
       AND (PROCESS_STATUS IS NULL OR PROCESS_STATUS = G_PS_TO_BE_PROCESSED);

     -- Fix for bug#9336604
     -- Added gather stats based on profile
     IF SQL%ROWCOUNT > 0 THEN
       IF (FND_INSTALLATION.GET_APP_INFO('EGO', l_status, l_industry, l_schema)) THEN

         IF (nvl(fnd_profile.value('EGO_ENABLE_GATHER_STATS'),'N') >= 'Y') THEN

            FND_STATS.GATHER_TABLE_STATS(OWNNAME => l_schema,
                                   TABNAME => 'EGO_ITM_USR_ATTR_INTRFC',
                                   CASCADE => True);
         END IF;

       END IF;

     END IF;

               --==================================--
               -- THE FIVE PRELIMINARY CONVERSIONS --
               --==================================--

    IF (p_debug_level > 0) THEN
      EGO_USER_ATTRS_DATA_PVT.Debug_Msg('Starting conversions', 0);
    END IF;

    IF(p_is_id_validations_reqd = FND_API.G_TRUE) THEN   /* Fix for bug#9660659 */
      ----------------------------------------------
      -- 1). Validate passed-in Organization IDs  --
      -- and convert passed-in Organization Codes --
      ----------------------------------------------
      IF (p_debug_level > 0) THEN
        EGO_USER_ATTRS_DATA_PVT.Debug_Msg('Starting Org validation/conversion', 0);
      END IF;


      -----------------------------------------------------------------
      -- Next, try to turn Master Organization Codes into Master Org --
      -- IDs for those rows where the user didn't pass in an Org ID; --
      -- as above, if the AG is associated at the Rev level then the --
      -- Orgs don't have to be Master Orgs.                          --
      -----------------------------------------------------------------
      UPDATE EGO_ITM_USR_ATTR_INTRFC UAI
         SET UAI.ORGANIZATION_ID =
                     (SELECT MP.ORGANIZATION_ID
                        FROM MTL_PARAMETERS MP
                       WHERE MP.ORGANIZATION_CODE = UAI.ORGANIZATION_CODE)
       WHERE UAI.DATA_SET_ID = p_data_set_id
         AND UAI.PROCESS_STATUS = G_PS_IN_PROCESS
         AND UAI.ORGANIZATION_CODE IS NOT NULL
         AND UAI.ORGANIZATION_ID IS NULL;
  /*       AND EXISTS (SELECT MP2.ORGANIZATION_ID
                       FROM MTL_PARAMETERS MP2
                      WHERE MP2.ORGANIZATION_CODE = UAI.ORGANIZATION_CODE
                        AND ((UAI.REVISION_ID IS NOT NULL
                              OR
                              UAI.REVISION IS NOT NULL)
                              OR
                              MP2.ORGANIZATION_ID = MP2.MASTER_ORGANIZATION_ID));*/

      ------------------------------------------------------------------------------
      -- Finally, mark as errors all rows that are in the same logical Attribute  --
      -- Group row as any row whose Org Code doesn't correspond to a valid Master --
      -- Org ID (marking errors as we go avoids further processing of bad rows)   --
      ------------------------------------------------------------------------------
      UPDATE EGO_ITM_USR_ATTR_INTRFC UAI
         SET UAI.PROCESS_STATUS = G_PS_BAD_ORG_CODE
       WHERE UAI.DATA_SET_ID = p_data_set_id
         AND UAI.PROCESS_STATUS = G_PS_IN_PROCESS
         AND UAI.ROW_IDENTIFIER IN (SELECT DISTINCT
                                           UAI2.ROW_IDENTIFIER
                                      FROM EGO_ITM_USR_ATTR_INTRFC UAI2
                                     WHERE UAI2.DATA_SET_ID = p_data_set_id
                                       AND UAI2.PROCESS_STATUS = G_PS_IN_PROCESS
                                       AND UAI2.ORGANIZATION_ID IS NULL);

    END IF; /* end of IF(p_is_id_validations_reqd = FND_API.G_TRUE) - Bug 9696621
              ending the IF, so that the item_number/item_id are validated always */

      --------------------------------------------
      -- 2). Validate passed-in Inventory Item  --
      -- IDs and convert passed-in Item Numbers --
      --------------------------------------------
      IF (p_debug_level > 0) THEN
        EGO_USER_ATTRS_DATA_PVT.Debug_Msg('Starting Item Number validation/conversion', 0);
      END IF;

      ----------------------------------------------------------------------------
      -- First, verify that all passed-in Inventory Item IDs belong to existing --
      -- Items; if any row has an invalid Item ID, error it out along with all  --
      -- other rows in its logical Attribute Group row                          --
      ----------------------------------------------------------------------------
      IF p_validate_only = FND_API.G_FALSE THEN
        UPDATE EGO_ITM_USR_ATTR_INTRFC UAI
           SET UAI.PROCESS_STATUS    = G_PS_BAD_ITEM_ID
         WHERE UAI.DATA_SET_ID       = p_data_set_id
           AND UAI.PROCESS_STATUS    IN (G_PS_IN_PROCESS, G_PS_STYLE_VARIANT_IN_PROCESS)
           AND UAI.INVENTORY_ITEM_ID IS NOT NULL
           AND NOT EXISTS (SELECT 'X'
                             FROM MTL_SYSTEM_ITEMS_B MSIB
                            WHERE MSIB.INVENTORY_ITEM_ID = UAI.INVENTORY_ITEM_ID
                              AND MSIB.ORGANIZATION_ID   = UAI.ORGANIZATION_ID);
      ELSE
        UPDATE EGO_ITM_USR_ATTR_INTRFC UAI
           SET UAI.PROCESS_STATUS = G_PS_BAD_ITEM_ID
         WHERE UAI.DATA_SET_ID       = p_data_set_id
           AND UAI.PROCESS_STATUS    = G_PS_IN_PROCESS
           AND UAI.INVENTORY_ITEM_ID IS NOT NULL
           AND NOT EXISTS (SELECT 'X'
                           FROM MTL_SYSTEM_ITEMS_B MSIB
                           WHERE MSIB.INVENTORY_ITEM_ID = UAI.INVENTORY_ITEM_ID
                             AND MSIB.ORGANIZATION_ID   = UAI.ORGANIZATION_ID
                           UNION ALL
                           SELECT 'X'
                           FROM MTL_SYSTEM_ITEMS_INTERFACE MSII
                           WHERE MSII.INVENTORY_ITEM_ID = UAI.INVENTORY_ITEM_ID
                             AND MSII.ORGANIZATION_ID   = UAI.ORGANIZATION_ID
                             AND MSII.SET_PROCESS_ID    = UAI.DATA_SET_ID
                             AND MSII.PROCESS_FLAG      = 1
                             AND MSII.TRANSACTION_TYPE  = 'CREATE');
      END IF;

      -------------------------------------------------------
      -- Next, convert Item Number into Item ID for those  --
      -- rows where the user only passed in an Item Number --
      -- (Note that we only convert any Item Number/Org ID --
      -- combination once and then set the Item ID we find --
      -- to all rows with the same Item Number and Org ID) --
      -------------------------------------------------------
      IF p_validate_only = FND_API.G_FALSE THEN
        UPDATE EGO_ITM_USR_ATTR_INTRFC intrfc
           SET INVENTORY_ITEM_ID =
                (SELECT INVENTORY_ITEM_ID
                   FROM MTL_SYSTEM_ITEMS_B_KFV
                  WHERE CONCATENATED_SEGMENTS = intrfc.ITEM_NUMBER
                    AND ORGANIZATION_ID       = intrfc.ORGANIZATION_ID)
         WHERE DATA_SET_ID       = p_data_set_id
           AND PROCESS_STATUS    = G_PS_IN_PROCESS
           AND ITEM_NUMBER       IS NOT NULL
           AND INVENTORY_ITEM_ID IS NULL;
      ELSE
        UPDATE EGO_ITM_USR_ATTR_INTRFC intrfc
           SET INVENTORY_ITEM_ID =
                NVL( (SELECT INVENTORY_ITEM_ID
                      FROM MTL_SYSTEM_ITEMS_B_KFV
                      WHERE CONCATENATED_SEGMENTS = intrfc.ITEM_NUMBER
                        AND ORGANIZATION_ID       = intrfc.ORGANIZATION_ID
                     ),
                     (SELECT INVENTORY_ITEM_ID
                      FROM MTL_SYSTEM_ITEMS_INTERFACE msii
                      WHERE msii.SET_PROCESS_ID  = intrfc.DATA_SET_ID
                        AND msii.PROCESS_FLAG    = 1
                        AND (msii.ITEM_NUMBER     = intrfc.ITEM_NUMBER OR msii.SOURCE_SYSTEM_REFERENCE = intrfc.SOURCE_SYSTEM_REFERENCE)
                        AND msii.ORGANIZATION_ID = intrfc.ORGANIZATION_ID
                        AND ROWNUM = 1
                     )
                   )
         WHERE DATA_SET_ID       = p_data_set_id
           AND PROCESS_STATUS    = G_PS_IN_PROCESS
           AND (ITEM_NUMBER       IS NOT NULL OR SOURCE_SYSTEM_REFERENCE IS NOT NULL)
           AND INVENTORY_ITEM_ID IS NULL;
      END IF;

      ----------------------------------------------------------------
      -- As with the Organization step, we mark as errors all rows  --
      -- that share the same logical Attribute Group row with any   --
      -- rows where we didn't end up with a valid Inventory Item ID --
      ----------------------------------------------------------------
      UPDATE EGO_ITM_USR_ATTR_INTRFC UAI
         SET UAI.PROCESS_STATUS = G_PS_BAD_ITEM_NUMBER
       WHERE UAI.DATA_SET_ID    = p_data_set_id
         AND UAI.PROCESS_STATUS = G_PS_IN_PROCESS
         AND UAI.ROW_IDENTIFIER IN (SELECT DISTINCT
                                      UAI2.ROW_IDENTIFIER
                                    FROM EGO_ITM_USR_ATTR_INTRFC UAI2
                                    WHERE UAI2.DATA_SET_ID       = p_data_set_id
                                      AND UAI2.PROCESS_STATUS    = G_PS_IN_PROCESS
                                      AND UAI2.INVENTORY_ITEM_ID IS NULL);

    IF(p_is_id_validations_reqd = FND_API.G_TRUE) THEN /* Fix for bug#9660659 */
      -----------------------------------------
      -- 3). Validate passed-in Revision IDs --
      -- and convert passed-in Revisions     --
      -----------------------------------------
      IF (p_debug_level > 0) THEN
        EGO_USER_ATTRS_DATA_PVT.Debug_Msg('Starting Revision conversion', 0);
      END IF;

      ---------------------------------------------------------------
      -- First, verify that all passed-in Revision IDs are valid;  --
      -- if any row has an invalid Revision ID, error it out along --
      -- with all other rows in its logical Attribute Group row    --
      ---------------------------------------------------------------
      IF p_validate_only = FND_API.G_FALSE THEN
        UPDATE EGO_ITM_USR_ATTR_INTRFC UAI
           SET UAI.PROCESS_STATUS = G_PS_BAD_REVISION_ID
         WHERE UAI.DATA_SET_ID = p_data_set_id
           AND UAI.PROCESS_STATUS = G_PS_IN_PROCESS
           AND UAI.REVISION_ID IS NOT NULL
           AND NOT EXISTS (SELECT 'X'
                             FROM MTL_ITEM_REVISIONS MIR
                            WHERE MIR.INVENTORY_ITEM_ID = UAI.INVENTORY_ITEM_ID
                              AND MIR.ORGANIZATION_ID = UAI.ORGANIZATION_ID
                              AND MIR.REVISION_ID = UAI.REVISION_ID);
      ELSE
        UPDATE EGO_ITM_USR_ATTR_INTRFC UAI
           SET UAI.PROCESS_STATUS = G_PS_BAD_REVISION_ID
         WHERE UAI.DATA_SET_ID = p_data_set_id
           AND UAI.PROCESS_STATUS = G_PS_IN_PROCESS
           AND UAI.REVISION_ID IS NOT NULL
           AND NOT EXISTS (SELECT 'X'
                           FROM MTL_ITEM_REVISIONS MIR
                           WHERE MIR.INVENTORY_ITEM_ID = UAI.INVENTORY_ITEM_ID
                             AND MIR.ORGANIZATION_ID = UAI.ORGANIZATION_ID
                             AND MIR.REVISION_ID = UAI.REVISION_ID
                           UNION ALL
                           SELECT 'X'
                           FROM MTL_ITEM_REVISIONS_INTERFACE miri
                           WHERE miri.SET_PROCESS_ID = UAI.DATA_SET_ID
                             AND miri.PROCESS_FLAG = 1
                             AND miri.INVENTORY_ITEM_ID = UAI.INVENTORY_ITEM_ID
                             AND miri.ORGANIZATION_ID = UAI.ORGANIZATION_ID
                             AND miri.REVISION_ID = UAI.REVISION_ID
                          );
      END IF;

      ----------------------------------------------------------------
      -- Next, convert Revision to Revision ID for those rows where --
      -- the user passed in the Revision (note that by "Revision",  --
      -- we mean the Revision *Code* and not the Revision Label)    --
      ----------------------------------------------------------------
      IF p_validate_only = FND_API.G_FALSE THEN
        UPDATE EGO_ITM_USR_ATTR_INTRFC UAI
           SET UAI.REVISION_ID = (SELECT MIR.REVISION_ID
                                    FROM MTL_ITEM_REVISIONS MIR
                                   WHERE MIR.INVENTORY_ITEM_ID = UAI.INVENTORY_ITEM_ID
                                     AND MIR.ORGANIZATION_ID = UAI.ORGANIZATION_ID
                                     AND MIR.REVISION = UAI.REVISION)
         WHERE UAI.DATA_SET_ID = p_data_set_id
           AND UAI.PROCESS_STATUS = G_PS_IN_PROCESS
           AND UAI.REVISION IS NOT NULL
           AND UAI.REVISION_ID IS NULL
           AND EXISTS (SELECT MIR2.REVISION_ID
                         FROM MTL_ITEM_REVISIONS MIR2
                        WHERE MIR2.INVENTORY_ITEM_ID = UAI.INVENTORY_ITEM_ID
                          AND MIR2.ORGANIZATION_ID = UAI.ORGANIZATION_ID
                          AND MIR2.REVISION = UAI.REVISION);
      ELSE
        UPDATE EGO_ITM_USR_ATTR_INTRFC UAI
           SET UAI.REVISION_ID = NVL( (SELECT MIR.REVISION_ID
                                       FROM MTL_ITEM_REVISIONS MIR
                                       WHERE MIR.INVENTORY_ITEM_ID = UAI.INVENTORY_ITEM_ID
                                         AND MIR.ORGANIZATION_ID = UAI.ORGANIZATION_ID
                                         AND MIR.REVISION = UAI.REVISION
                                      ),
                                      (SELECT miri.REVISION_ID
                                       FROM MTL_ITEM_REVISIONS_INTERFACE miri
                                       WHERE miri.SET_PROCESS_ID = UAI.DATA_SET_ID
                                         AND miri.PROCESS_FLAG = 1
                                         AND miri.INVENTORY_ITEM_ID = UAI.INVENTORY_ITEM_ID
                                         AND miri.ORGANIZATION_ID = UAI.ORGANIZATION_ID
                                         AND miri.REVISION = UAI.REVISION
                                         AND ROWNUM = 1
                                      )
                                    )
         WHERE UAI.DATA_SET_ID = p_data_set_id
           AND UAI.PROCESS_STATUS = G_PS_IN_PROCESS
           AND UAI.REVISION IS NOT NULL
           AND UAI.REVISION_ID IS NULL
           AND EXISTS (SELECT 'X'
                       FROM MTL_ITEM_REVISIONS MIR2
                       WHERE MIR2.INVENTORY_ITEM_ID = UAI.INVENTORY_ITEM_ID
                         AND MIR2.ORGANIZATION_ID = UAI.ORGANIZATION_ID
                         AND MIR2.REVISION = UAI.REVISION
                       UNION ALL
                       SELECT 'X'
                       FROM MTL_ITEM_REVISIONS_INTERFACE miri
                       WHERE miri.SET_PROCESS_ID = UAI.DATA_SET_ID
                         AND miri.PROCESS_FLAG = 1
                         AND miri.INVENTORY_ITEM_ID = UAI.INVENTORY_ITEM_ID
                         AND miri.ORGANIZATION_ID = UAI.ORGANIZATION_ID
                         AND miri.REVISION = UAI.REVISION
                      );
      END IF;


      -------------------------------------------------------------------------
      -- Mark as errors all rows that share the same logical Attribute Group --
      -- row with any rows where we started with a Revision and didn't end   --
      -- up with a valid Revision ID (because many rows may not have either  --
      -- a Revision or a Revision ID, and that is not an error condition)    --
      -------------------------------------------------------------------------
      UPDATE EGO_ITM_USR_ATTR_INTRFC UAI
         SET UAI.PROCESS_STATUS = G_PS_BAD_REVISION_CODE
       WHERE UAI.DATA_SET_ID = p_data_set_id
         AND UAI.PROCESS_STATUS = G_PS_IN_PROCESS
         AND UAI.ROW_IDENTIFIER IN (SELECT DISTINCT
                                           UAI2.ROW_IDENTIFIER
                                      FROM EGO_ITM_USR_ATTR_INTRFC UAI2
                                     WHERE UAI2.DATA_SET_ID = p_data_set_id
                                       AND UAI2.PROCESS_STATUS = G_PS_IN_PROCESS
                                       AND UAI2.REVISION IS NOT NULL
                                       AND UAI2.REVISION_ID IS NULL);

    END IF; -- end of IF(p_is_id_validations_reqd = FND_API.G_TRUE) /* Fix for bug#9660659 */

    ---------------------------------------------------------
    -- 4). Find the Item Catalog Group ID for each Item    --
    ---------------------------------------------------------
    IF (p_debug_level > 0) THEN
      EGO_USER_ATTRS_DATA_PVT.Debug_Msg('Starting Catalog Group ID conversion', 0);
    END IF;

--    write_records(p_data_set_id => p_data_set_id,  p_module => l_api_name, p_message => 'After init');
    -- Fix for bug#9660659
    IF p_validate_only = FND_API.G_FALSE THEN
      UPDATE EGO_ITM_USR_ATTR_INTRFC UAI
         SET (UAI.ITEM_CATALOG_GROUP_ID, UAI.PROG_INT_CHAR1,
              UAI.PROG_INT_NUM2, UAI.PROG_INT_NUM3)
                  = (SELECT NVL(MSI.ITEM_CATALOG_GROUP_ID,-1), NVL(MSI.APPROVAL_STATUS,'A'),
                            MSI.LIFECYCLE_ID, MSI.CURRENT_PHASE_ID
                       FROM MTL_SYSTEM_ITEMS_B MSI
                      WHERE MSI.INVENTORY_ITEM_ID = UAI.INVENTORY_ITEM_ID
                        AND MSI.ORGANIZATION_ID = UAI.ORGANIZATION_ID
                    ),
              PROG_INT_CHAR2 =
                 NVL((SELECT 'Y'
                        FROM MTL_SYSTEM_ITEMS_INTERFACE MSII
                        WHERE MSII.INVENTORY_ITEM_ID = UAI.INVENTORY_ITEM_ID
                          AND MSII.ORGANIZATION_ID = UAI.ORGANIZATION_ID
                          AND MSII.REQUEST_ID = UAI.REQUEST_ID
                          AND MSII.TRANSACTION_TYPE = 'CREATE'
                          AND MSII.PROCESS_FLAG = 7
                          AND MSII.SET_PROCESS_ID = UAI.DATA_SET_ID
                     ),PROG_INT_CHAR2)
       WHERE UAI.DATA_SET_ID = p_data_set_id
         AND PROCESS_STATUS = G_PS_IN_PROCESS
         AND EXISTS (SELECT /*+ NO_UNNEST */ MSI.ITEM_CATALOG_GROUP_ID
                       FROM MTL_SYSTEM_ITEMS_B MSI
                      WHERE MSI.INVENTORY_ITEM_ID = UAI.INVENTORY_ITEM_ID
                        AND MSI.ORGANIZATION_ID = UAI.ORGANIZATION_ID);
    ELSE
      -- Bug 11719885 : Start
      -- For ICC, check the value in MSII first then check in MSIB
      -- (as in case of ICC change for an item, the correct value will be present in MSII)
      UPDATE EGO_ITM_USR_ATTR_INTRFC UAI
         SET (UAI.ITEM_CATALOG_GROUP_ID,
              UAI.PROG_INT_NUM2, UAI.PROG_INT_NUM3)
                  = (SELECT
                       NVL(UAI.ITEM_CATALOG_GROUP_ID, MSII.ITEM_CATALOG_GROUP_ID),
                       NVL( UAI.PROG_INT_NUM2, MSII.LIFECYCLE_ID),
                       NVL( UAI.PROG_INT_NUM3, MSII.CURRENT_PHASE_ID)
                     FROM MTL_SYSTEM_ITEMS_INTERFACE MSII
                     WHERE MSII.INVENTORY_ITEM_ID = UAI.INVENTORY_ITEM_ID
                       AND MSII.ORGANIZATION_ID = UAI.ORGANIZATION_ID
                       AND MSII.SET_PROCESS_ID = UAI.DATA_SET_ID
                       AND MSII.PROCESS_FLAG = 1
                       AND ROWNUM = 1
                    ),
              PROG_INT_CHAR2 =
                 NVL((SELECT 'Y'
                        FROM MTL_SYSTEM_ITEMS_INTERFACE MSII
                        WHERE MSII.INVENTORY_ITEM_ID = UAI.INVENTORY_ITEM_ID
                          AND MSII.ORGANIZATION_ID = UAI.ORGANIZATION_ID
                          AND MSII.TRANSACTION_TYPE = 'CREATE'
                          AND MSII.PROCESS_FLAG = 1
                          AND MSII.SET_PROCESS_ID = UAI.DATA_SET_ID
                          AND ROWNUM = 1
                     ),PROG_INT_CHAR2)
      WHERE UAI.DATA_SET_ID = p_data_set_id
        AND PROCESS_STATUS = G_PS_IN_PROCESS
        AND EXISTS (SELECT 'X'
                    FROM MTL_SYSTEM_ITEMS_INTERFACE MSII2
                    WHERE MSII2.INVENTORY_ITEM_ID = UAI.INVENTORY_ITEM_ID
                      AND MSII2.ORGANIZATION_ID = UAI.ORGANIZATION_ID
                      AND MSII2.SET_PROCESS_ID = UAI.DATA_SET_ID
                      AND MSII2.PROCESS_FLAG = 1
                   );


      UPDATE EGO_ITM_USR_ATTR_INTRFC UAI
         SET (UAI.ITEM_CATALOG_GROUP_ID, UAI.PROG_INT_CHAR1,
              UAI.PROG_INT_NUM2, UAI.PROG_INT_NUM3)
                  = (SELECT NVL(Nvl(UAI.ITEM_CATALOG_GROUP_ID,MSI.ITEM_CATALOG_GROUP_ID),-1) ,
                        NVL(MSI.APPROVAL_STATUS,'A'),
                        MSI.LIFECYCLE_ID, MSI.CURRENT_PHASE_ID
                       FROM MTL_SYSTEM_ITEMS_B MSI
                      WHERE MSI.INVENTORY_ITEM_ID = UAI.INVENTORY_ITEM_ID
                        AND MSI.ORGANIZATION_ID = UAI.ORGANIZATION_ID
                    ),
              PROG_INT_CHAR2 =
                 NVL((SELECT 'Y'
                        FROM MTL_SYSTEM_ITEMS_INTERFACE MSII
                        WHERE MSII.INVENTORY_ITEM_ID = UAI.INVENTORY_ITEM_ID
                          AND MSII.ORGANIZATION_ID = UAI.ORGANIZATION_ID
                          AND MSII.TRANSACTION_TYPE = 'CREATE'
                          AND MSII.PROCESS_FLAG = 1
                          AND MSII.SET_PROCESS_ID = UAI.DATA_SET_ID
                          AND ROWNUM = 1
                     ),PROG_INT_CHAR2)
      WHERE UAI.DATA_SET_ID = p_data_set_id
        AND PROCESS_STATUS = G_PS_IN_PROCESS
        AND EXISTS (SELECT MSI.ITEM_CATALOG_GROUP_ID
                    FROM MTL_SYSTEM_ITEMS_B MSI
                    WHERE MSI.INVENTORY_ITEM_ID = UAI.INVENTORY_ITEM_ID
                      AND MSI.ORGANIZATION_ID = UAI.ORGANIZATION_ID);
      /*
      UPDATE EGO_ITM_USR_ATTR_INTRFC UAI
         SET (UAI.ITEM_CATALOG_GROUP_ID, UAI.PROG_INT_CHAR1,
              UAI.PROG_INT_NUM2, UAI.PROG_INT_NUM3)
                  = (SELECT MSI.ITEM_CATALOG_GROUP_ID, NVL(MSI.APPROVAL_STATUS,'A'),  -- Fix by bug 11782276
                            MSI.LIFECYCLE_ID, MSI.CURRENT_PHASE_ID
                       FROM MTL_SYSTEM_ITEMS_B MSI
                      WHERE MSI.INVENTORY_ITEM_ID = UAI.INVENTORY_ITEM_ID
                        AND MSI.ORGANIZATION_ID = UAI.ORGANIZATION_ID
                    ),
              PROG_INT_CHAR2 =
                 NVL((SELECT 'Y'
                        FROM MTL_SYSTEM_ITEMS_INTERFACE MSII
                        WHERE MSII.INVENTORY_ITEM_ID = UAI.INVENTORY_ITEM_ID
                          AND MSII.ORGANIZATION_ID = UAI.ORGANIZATION_ID
                          AND MSII.TRANSACTION_TYPE = 'CREATE'
                          AND MSII.PROCESS_FLAG = 1
                          AND MSII.SET_PROCESS_ID = UAI.DATA_SET_ID
                          AND ROWNUM = 1
                     ),PROG_INT_CHAR2)
      WHERE UAI.DATA_SET_ID = p_data_set_id
        AND PROCESS_STATUS = G_PS_IN_PROCESS
        AND EXISTS (SELECT MSI.ITEM_CATALOG_GROUP_ID
                    FROM MTL_SYSTEM_ITEMS_B MSI
                    WHERE MSI.INVENTORY_ITEM_ID = UAI.INVENTORY_ITEM_ID
                      AND MSI.ORGANIZATION_ID = UAI.ORGANIZATION_ID);

      -- If item is not found in production then get the values from interface
      UPDATE EGO_ITM_USR_ATTR_INTRFC UAI
         SET (UAI.ITEM_CATALOG_GROUP_ID,
              UAI.PROG_INT_NUM2, UAI.PROG_INT_NUM3)
                  = (SELECT
                       NVL( NVL(UAI.ITEM_CATALOG_GROUP_ID, MSII.ITEM_CATALOG_GROUP_ID), -1),
                       NVL( UAI.PROG_INT_NUM2, MSII.LIFECYCLE_ID),
                       NVL( UAI.PROG_INT_NUM3, MSII.CURRENT_PHASE_ID)
                     FROM MTL_SYSTEM_ITEMS_INTERFACE MSII
                     WHERE MSII.INVENTORY_ITEM_ID = UAI.INVENTORY_ITEM_ID
                       AND MSII.ORGANIZATION_ID = UAI.ORGANIZATION_ID
                       AND MSII.SET_PROCESS_ID = UAI.DATA_SET_ID
                       AND MSII.PROCESS_FLAG = 1
                       AND ROWNUM = 1
                    ),
              PROG_INT_CHAR2 =
                 NVL((SELECT 'Y'
                        FROM MTL_SYSTEM_ITEMS_INTERFACE MSII
                        WHERE MSII.INVENTORY_ITEM_ID = UAI.INVENTORY_ITEM_ID
                          AND MSII.ORGANIZATION_ID = UAI.ORGANIZATION_ID
                          AND MSII.TRANSACTION_TYPE = 'CREATE'
                          AND MSII.PROCESS_FLAG = 1
                          AND MSII.SET_PROCESS_ID = UAI.DATA_SET_ID
                          AND ROWNUM = 1
                     ),PROG_INT_CHAR2)
      WHERE UAI.DATA_SET_ID = p_data_set_id
        AND PROCESS_STATUS = G_PS_IN_PROCESS
        AND EXISTS (SELECT 'X'
                    FROM MTL_SYSTEM_ITEMS_INTERFACE MSII2
                    WHERE MSII2.INVENTORY_ITEM_ID = UAI.INVENTORY_ITEM_ID
                      AND MSII2.ORGANIZATION_ID = UAI.ORGANIZATION_ID
                      AND MSII2.SET_PROCESS_ID = UAI.DATA_SET_ID
                      AND MSII2.PROCESS_FLAG = 1
                   );
      */
      -- Bug 11719885 : End
    END IF;
--  write_records(p_data_set_id => p_data_set_id,  p_module => l_api_name, p_message => 'After item init');

    ----------------------------------------------------------------------------
    -- Mark as errors all rows that share the same logical Attribute Group    --
    -- row with any rows where we didn't end up with a valid Catalog Group ID --
    ----------------------------------------------------------------------------
    UPDATE EGO_ITM_USR_ATTR_INTRFC UAI
       SET UAI.PROCESS_STATUS = G_PS_BAD_CATALOG_GROUP_ID
     WHERE UAI.DATA_SET_ID = p_data_set_id
       AND UAI.PROCESS_STATUS = G_PS_IN_PROCESS
       AND UAI.ROW_IDENTIFIER IN (SELECT DISTINCT
                                         UAI2.ROW_IDENTIFIER
                                    FROM EGO_ITM_USR_ATTR_INTRFC UAI2
                                   WHERE UAI2.DATA_SET_ID = p_data_set_id
                                     AND UAI2.PROCESS_STATUS = G_PS_IN_PROCESS
                                     AND UAI2.ITEM_CATALOG_GROUP_ID IS NULL);

    IF (p_is_id_validations_reqd = FND_API.G_TRUE)  THEN /* Fix for bug#9660659 */
      ---------------------------------------------------------
      --  Find the Attr Group Type for Attribute Name        --
      ---------------------------------------------------------
      UPDATE EGO_ITM_USR_ATTR_INTRFC UAI
         SET ATTR_GROUP_TYPE = NVL(ATTR_GROUP_TYPE,(SELECT DESCRIPTIVE_FLEXFIELD_NAME
                                     FROM EGO_FND_DSC_FLX_CTX_EXT
                                    WHERE APPLICATION_ID = 431
                                      AND DESCRIPTIVE_FLEX_CONTEXT_CODE = UAI.ATTR_GROUP_INT_NAME
                                      AND ROWNUM = 1))
             ,PROCESS_STATUS = DECODE((SELECT COUNT(DESCRIPTIVE_FLEXFIELD_NAME)
                                         FROM EGO_FND_DSC_FLX_CTX_EXT
                                        WHERE APPLICATION_ID = 431
                                          AND (UAI.ATTR_GROUP_TYPE IS NULL OR UAI.ATTR_GROUP_TYPE=DESCRIPTIVE_FLEXFIELD_NAME)
                                          AND DESCRIPTIVE_FLEX_CONTEXT_CODE = UAI.ATTR_GROUP_INT_NAME),
                                      1,PROCESS_STATUS
                                      ,G_PS_BAD_ATTR_GROUP_NAME)
       WHERE UAI.DATA_SET_ID = p_data_set_id
         AND UAI.PROCESS_STATUS = G_PS_IN_PROCESS
         AND UAI.ATTR_GROUP_ID IS NULL;

      ---------------------------------------------------------
      --  Find the Bad Attr Group Id for Attribute Name  --
      ---------------------------------------------------------
      IF (p_debug_level > 0) THEN
        EGO_USER_ATTRS_DATA_PVT.Debug_Msg('Starting Attr Group ID validation', 0);
      END IF;
      ----------------------------------------------------------------------------
      -- Note: Attribute Internal Name take precidence over Attribute Group Id  --
      ----------------------------------------------------------------------------
  -- to do check the performance       cost 35
  --    UPDATE EGO_ITM_USR_ATTR_INTRFC UAI
  --       SET UAI.PROCESS_STATUS = G_PS_BAD_ATTR_GROUP_ID
  --     WHERE UAI.DATA_SET_ID = p_data_set_id
  --       AND UAI.PROCESS_STATUS = G_PS_IN_PROCESS
  --       AND UAI.ATTR_GROUP_ID IS NOT NULL
  --       AND UAI.ATTR_GROUP_ID <> ( SELECT ATTR_GROUP_ID
  --                                FROM EGO_FND_DSC_FLX_CTX_EXT FLX_EXT
  --                               WHERE APPLICATION_ID = 431
  --                                 AND DESCRIPTIVE_FLEXFIELD_NAME = l_attr_group_type
  --                                 AND DESCRIPTIVE_FLEX_CONTEXT_CODE = UAI.ATTR_GROUP_INT_NAME);

  -- to do check the performance       cost 3
     UPDATE EGO_ITM_USR_ATTR_INTRFC UAI
         SET UAI.PROCESS_STATUS = G_PS_BAD_CATALOG_GROUP_ID
       WHERE UAI.DATA_SET_ID = p_data_set_id
         AND UAI.PROCESS_STATUS = G_PS_IN_PROCESS
         AND UAI.ATTR_GROUP_ID IS NOT NULL
         AND NOT EXISTS
            ( SELECT 'X'
              FROM EGO_FND_DSC_FLX_CTX_EXT FLX_EXT
              WHERE APPLICATION_ID = 431
              AND DESCRIPTIVE_FLEXFIELD_NAME = UAI.ATTR_GROUP_TYPE --l_attr_group_type
              AND DESCRIPTIVE_FLEX_CONTEXT_CODE = UAI.ATTR_GROUP_INT_NAME
              AND ATTR_GROUP_ID = UAI.ATTR_GROUP_ID);

      ---------------------------------------------------------
      --  Find the Attr Group Id for Attribute Name       --
      ---------------------------------------------------------
      IF (p_debug_level > 0) THEN
        EGO_USER_ATTRS_DATA_PVT.Debug_Msg('Starting Attr Group ID conversion', 0);
      END IF;
      UPDATE EGO_ITM_USR_ATTR_INTRFC UAI
         SET ATTR_GROUP_ID = (SELECT ATTR_GROUP_ID
                                FROM EGO_FND_DSC_FLX_CTX_EXT FLX_EXT
                               WHERE APPLICATION_ID = 431
                                 AND DESCRIPTIVE_FLEXFIELD_NAME = UAI.ATTR_GROUP_TYPE --l_attr_group_type
                                 AND DESCRIPTIVE_FLEX_CONTEXT_CODE = UAI.ATTR_GROUP_INT_NAME)
       WHERE UAI.DATA_SET_ID = p_data_set_id
         AND UAI.PROCESS_STATUS = G_PS_IN_PROCESS
         AND UAI.ATTR_GROUP_ID IS NULL;

      ------------------------------------------------------------------------------
      -- Mark as errors all rows that didn't end up with a valid Attr Group ID    --
      ------------------------------------------------------------------------------

      UPDATE EGO_ITM_USR_ATTR_INTRFC UAI
         SET UAI.PROCESS_STATUS = G_PS_BAD_ATTR_GROUP_NAME
       WHERE UAI.DATA_SET_ID = p_data_set_id
         AND UAI.PROCESS_STATUS = G_PS_IN_PROCESS
         AND UAI.ATTR_GROUP_ID IS NULL;

     END IF;  -- end of IF(p_is_id_validations_reqd = FND_API.G_TRUE) /* Fix for bug#9660659 */
     -------------------------------------------------------------------------
     -- Erase Revision information for Attr Groups associated at ITEM_LEVEL --
     -------------------------------------------------------------------------
     /*
     UPDATE EGO_ITM_USR_ATTR_INTRFC
        SET REVISION = NULL, REVISION_ID = NULL
      WHERE ROWID IN (SELECT I.ROWID
                        FROM EGO_OBJ_AG_ASSOCS_B     A,
                             EGO_ITM_USR_ATTR_INTRFC I
                       WHERE A.CLASSIFICATION_CODE = I.ITEM_CATALOG_GROUP_ID
                         AND A.OBJECT_ID = G_ITEM_OBJECT_ID
                         AND A.ATTR_GROUP_ID = I.ATTR_GROUP_ID
                         AND A.DATA_LEVEL = 'ITEM_LEVEL'
                         AND I.DATA_SET_ID = p_data_set_id
                         AND I.PROCESS_STATUS = G_PS_IN_PROCESS);
      */
    --Bug 9325678 begin
    l_item_data_level_id_str := '';
    for x in (SELECT DATA_LEVEL_ID
                    FROM EGO_DATA_LEVEL_B
                   WHERE DATA_LEVEL_NAME = 'ITEM_LEVEL')
    loop
      if length(l_item_data_level_id_str) > 0 then
        l_item_data_level_id_str := l_item_data_level_id_str || ',';
      end if;
      l_item_data_level_id_str := l_item_data_level_id_str || x.DATA_LEVEL_ID;
    end loop;
    Debug_Conc_Log('l_item_data_level_id_str: '||l_item_data_level_id_str);

    l_erase_revision_sql :=
        q'#UPDATE EGO_ITM_USR_ATTR_INTRFC S
             SET REVISION = NULL, REVISION_ID = NULL
           WHERE EXISTS (SELECT A.ROWID
                 FROM EGO_OBJ_AG_ASSOCS_B A
                 WHERE A.CLASSIFICATION_CODE = S.ITEM_CATALOG_GROUP_ID
                   AND A.OBJECT_ID = :1
                   AND A.ATTR_GROUP_ID = S.ATTR_GROUP_ID
                   AND TO_CHAR(A.DATA_LEVEL_ID) in (:2))
           AND DATA_SET_ID = :3
           AND PROCESS_STATUS = :4 #';
    Debug_Conc_Log('Erase Revision sql statement: '||l_erase_revision_sql);
    EXECUTE IMMEDIATE l_erase_revision_sql USING G_ITEM_OBJECT_ID,
                                                 l_item_data_level_id_str,
                                                 p_data_set_id,
                                                 G_PS_IN_PROCESS;
    --Bug 9325678 end
/*
    ------------------------------------------------------------------------------
    -- Verify that all passed-in Organization IDs belong to Master Orgs  --
    -- if they are for AGs associated at the Item level and that the Org IDs at --
    -- least exist for AGs associated at the Item Revision level.               --
    -- if any row has an invalid Org ID, error it out along with all other rows --
    -- in its logical Attribute Group row (because it won't make sense to keep  --
    -- processing the errored-out row's companions without the errored-out row) --
    ------------------------------------------------------------------------------
    UPDATE EGO_ITM_USR_ATTR_INTRFC UAI
       SET UAI.PROCESS_STATUS = G_PS_BAD_ORG_ID
     WHERE UAI.DATA_SET_ID = p_data_set_id
       AND UAI.PROCESS_STATUS = G_PS_IN_PROCESS
       AND UAI.ROW_IDENTIFIER IN
             (SELECT DISTINCT  UAI2.ROW_IDENTIFIER
                FROM EGO_ITM_USR_ATTR_INTRFC UAI2
               WHERE UAI2.DATA_SET_ID = p_data_set_id
                 AND UAI2.PROCESS_STATUS = G_PS_IN_PROCESS
                 AND UAI2.ORGANIZATION_ID IS NOT NULL
                 AND NOT EXISTS
                     (SELECT 'X'
                      FROM MTL_PARAMETERS MP
                     WHERE MP.ORGANIZATION_ID = UAI2.ORGANIZATION_ID
                       AND (UAI2.REVISION_ID IS NOT NULL
                            OR
                            UAI2.REVISION IS NOT NULL
                            OR
                            MP.MASTER_ORGANIZATION_ID = UAI2.ORGANIZATION_ID
                            )
                     )
             );

*/

    ----------------------------------------------------
    -- Validate and convert data level entered        --
    -- First convert DATA_LEVEL_NAME to data_level_id --
    -- where data_level_id is not populated           --
    ----------------------------------------------------
    UPDATE EGO_ITM_USR_ATTR_INTRFC uai
       SET uai.DATA_LEVEL_ID = (SELECT edlb.DATA_LEVEL_ID
                                FROM EGO_DATA_LEVEL_B edlb
                                WHERE edlb.DATA_LEVEL_NAME = uai.DATA_LEVEL_NAME
                                  AND edlb.APPLICATION_ID  = 431
                                  AND edlb.ATTR_GROUP_TYPE = NVL(uai.ATTR_GROUP_TYPE, 'EGO_ITEMMGMT_GROUP')
                               )
    WHERE uai.DATA_SET_ID     = p_data_set_id
      AND uai.PROCESS_STATUS  = G_PS_IN_PROCESS
      AND uai.DATA_LEVEL_NAME IS NOT NULL
      AND uai.DATA_LEVEL_ID   IS NULL;


    ----------------------------------------------------------
    -- Then convert USER_DATA_LEVEL_NAME to                 --
    -- data_level_id where data_level_id is not             --
    -- populated and data_level_name is also not populated  --
    ----------------------------------------------------------
    UPDATE EGO_ITM_USR_ATTR_INTRFC uai
       SET uai.DATA_LEVEL_ID = (SELECT edlv.DATA_LEVEL_ID
                                FROM EGO_DATA_LEVEL_VL edlv
                                WHERE edlv.USER_DATA_LEVEL_NAME = uai.USER_DATA_LEVEL_NAME
                                  AND edlv.APPLICATION_ID       = 431
                                  AND edlv.ATTR_GROUP_TYPE      = NVL(uai.ATTR_GROUP_TYPE, 'EGO_ITEMMGMT_GROUP')
                               )
    WHERE uai.DATA_SET_ID          = p_data_set_id
      AND uai.PROCESS_STATUS       = G_PS_IN_PROCESS
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
                            FROM EGO_ATTR_GROUP_DL
                            WHERE ATTR_GROUP_ID = uai.ATTR_GROUP_ID
                           )
    WHERE uai.DATA_SET_ID          = p_data_set_id
      AND uai.PROCESS_STATUS       = G_PS_IN_PROCESS
      AND uai.DATA_LEVEL_ID        IS NULL
      AND uai.DATA_LEVEL_NAME      IS NULL
      AND uai.USER_DATA_LEVEL_NAME IS NULL
      AND (SELECT COUNT(*)
           FROM EGO_ATTR_GROUP_DL
           WHERE ATTR_GROUP_ID = uai.ATTR_GROUP_ID) = 1;


    -------------------------------------------------
    -- Now, mark all the rows that does not have a --
    -- valid data_level_id populated               --
    -------------------------------------------------
    UPDATE EGO_ITM_USR_ATTR_INTRFC uai
    SET uai.PROCESS_STATUS = G_PS_BAD_DATA_LEVEL
    WHERE uai.DATA_SET_ID = p_data_set_id
      AND uai.PROCESS_STATUS = G_PS_IN_PROCESS
      AND uai.ROW_IDENTIFIER IN (SELECT DISTINCT
                                         uai2.ROW_IDENTIFIER
                                 FROM EGO_ITM_USR_ATTR_INTRFC uai2
                                 WHERE uai2.DATA_SET_ID    = p_data_set_id
                                   AND uai2.PROCESS_STATUS = G_PS_IN_PROCESS
                                   AND NOT EXISTS (SELECT NULL
                                                   FROM EGO_DATA_LEVEL_B edlb
                                                   WHERE edlb.DATA_LEVEL_ID = uai2.DATA_LEVEL_ID
                                                  )
                                );

    --------------------------------------------------
    -- Validating the Orag Id to be master org for  --
    -- item, supplier and supplier site level       --
    --------------------------------------------------

    UPDATE EGO_ITM_USR_ATTR_INTRFC UAI
       --SET UAI.PROCESS_STATUS = G_PS_BAD_ORG_ID
       -- bug 8649262 Restore to Pre-R12C behavior, mark with Generic Error so
       -- this line will not be processed
       SET UAI.PROCESS_STATUS = G_PS_GENERIC_ERROR

     WHERE UAI.DATA_SET_ID = p_data_set_id
       AND UAI.PROCESS_STATUS = G_PS_IN_PROCESS
       AND UAI.DATA_LEVEL_ID IN (43101, 43103,43104,43107,43108)
       AND EXISTS (SELECT MP2.ORGANIZATION_ID
                     FROM MTL_PARAMETERS MP2
                    WHERE MP2.ORGANIZATION_ID = UAI.ORGANIZATION_ID
                      AND MP2.ORGANIZATION_ID <> MP2.MASTER_ORGANIZATION_ID);



    ----------------------------------------------------------------
    -- Get data_level_ids to validate PK1_VALUE and PK2_VALUE     --
    ----------------------------------------------------------------
    FOR i IN c_data_levels LOOP
      IF i.DATA_LEVEL_NAME = 'ITEM_SUP' THEN
        l_item_sup_dl_id := i.DATA_LEVEL_ID;
      ELSIF i.DATA_LEVEL_NAME = 'ITEM_SUP_SITE' THEN
        l_item_sup_site_dl_id := i.DATA_LEVEL_ID;
      ELSIF i.DATA_LEVEL_NAME = 'ITEM_SUP_SITE_ORG' THEN
        l_item_sup_site_org_dl_id := i.DATA_LEVEL_ID;
      END IF; -- IF i.DATA_LEVEL_NAME
    END LOOP; -- FOR i IN c_data_levels LOOP

    ----------------------------------------------------------------
    -- Next, validate the Item Supplier attrs. Validate that the  --
    -- pk1_value exists in ego_item_associations for this item    --
    ----------------------------------------------------------------
    IF p_validate_only = FND_API.G_FALSE THEN
      UPDATE EGO_ITM_USR_ATTR_INTRFC uai
         SET uai.PROCESS_STATUS = G_PS_BAD_SUPPLIER
      WHERE uai.DATA_SET_ID    = p_data_set_id
        AND uai.PROCESS_STATUS = G_PS_IN_PROCESS
        AND uai.ROW_IDENTIFIER IN (SELECT DISTINCT
                                           UAI2.ROW_IDENTIFIER
                                    FROM EGO_ITM_USR_ATTR_INTRFC uai2
                                    WHERE uai2.DATA_SET_ID    = p_data_set_id
                                      AND uai2.PROCESS_STATUS = G_PS_IN_PROCESS
                                      AND uai2.DATA_LEVEL_ID  = l_item_sup_dl_id
                                      AND ( uai2.PK1_VALUE  IS NULL
                                            OR
                                            (    uai2.PK1_VALUE IS NOT NULL
                                             AND uai2.PK2_VALUE IS NOT NULL
                                            )
                                            OR
                                            (    uai2.PK1_VALUE IS NOT NULL
                                             AND uai2.PK2_VALUE IS NULL
                                             AND NOT EXISTS (SELECT NULL
                                                             FROM EGO_ITEM_ASSOCIATIONS eia
                                                             WHERE eia.INVENTORY_ITEM_ID = uai2.INVENTORY_ITEM_ID
                                                               AND eia.ORGANIZATION_ID   = uai2.ORGANIZATION_ID
                                                               AND eia.PK1_VALUE         = uai2.PK1_VALUE
                                                               AND eia.DATA_LEVEL_ID     = uai2.DATA_LEVEL_ID
                                                            )
                                            )
                                          )
                                   );
    ELSE
      UPDATE EGO_ITM_USR_ATTR_INTRFC uai
         SET uai.PROCESS_STATUS = G_PS_BAD_SUPPLIER
      WHERE uai.DATA_SET_ID    = p_data_set_id
        AND uai.PROCESS_STATUS = G_PS_IN_PROCESS
        AND uai.ROW_IDENTIFIER IN (SELECT DISTINCT
                                           UAI2.ROW_IDENTIFIER
                                    FROM EGO_ITM_USR_ATTR_INTRFC uai2
                                    WHERE uai2.DATA_SET_ID    = p_data_set_id
                                      AND uai2.PROCESS_STATUS = G_PS_IN_PROCESS
                                      AND uai2.DATA_LEVEL_ID  = l_item_sup_dl_id
                                      AND ( uai2.PK1_VALUE  IS NULL
                                            OR
                                            (    uai2.PK1_VALUE IS NOT NULL
                                             AND uai2.PK2_VALUE IS NOT NULL
                                            )
                                            OR
                                            (    uai2.PK1_VALUE IS NOT NULL
                                             AND uai2.PK2_VALUE IS NULL
                                             AND NOT EXISTS (SELECT NULL
                                                             FROM EGO_ITEM_ASSOCIATIONS eia
                                                             WHERE eia.INVENTORY_ITEM_ID = uai2.INVENTORY_ITEM_ID
                                                               AND eia.ORGANIZATION_ID   = uai2.ORGANIZATION_ID
                                                               AND eia.PK1_VALUE         = uai2.PK1_VALUE
                                                               AND eia.DATA_LEVEL_ID     = uai2.DATA_LEVEL_ID
                                                             UNION ALL
                                                             SELECT NULL
                                                             FROM EGO_ITEM_ASSOCIATIONS_INTF eiai
                                                             WHERE eiai.INVENTORY_ITEM_ID = uai2.INVENTORY_ITEM_ID
                                                               AND eiai.ORGANIZATION_ID   = uai2.ORGANIZATION_ID
                                                               AND eiai.PK1_VALUE         = uai2.PK1_VALUE
                                                               AND eiai.DATA_LEVEL_ID     = uai2.DATA_LEVEL_ID
                                                               AND eiai.BATCH_ID          = uai2.DATA_SET_ID
                                                               AND eiai.PROCESS_FLAG      = 1
                                                            )
                                            )
                                          )
                                   );
    END IF;

    -----------------------------------------------------------------
    -- Next, validate the Item Supplier site attrs. Validate that  --
    -- the pk2_value exists in ego_item_associations for this item --
    -----------------------------------------------------------------
    IF p_validate_only = FND_API.G_FALSE THEN
      UPDATE EGO_ITM_USR_ATTR_INTRFC uai
         SET uai.PROCESS_STATUS = G_PS_BAD_SUPPLIER_SITE
      WHERE uai.DATA_SET_ID    = p_data_set_id
        AND uai.PROCESS_STATUS = G_PS_IN_PROCESS
        AND uai.ROW_IDENTIFIER IN (SELECT DISTINCT
                                           UAI2.ROW_IDENTIFIER
                                    FROM EGO_ITM_USR_ATTR_INTRFC uai2
                                    WHERE uai2.DATA_SET_ID    = p_data_set_id
                                      AND uai2.PROCESS_STATUS = G_PS_IN_PROCESS
                                      AND uai2.DATA_LEVEL_ID  = l_item_sup_site_dl_id
                                      AND ( uai2.PK1_VALUE  IS NULL
                                            OR
                                            uai2.PK2_VALUE  IS NULL
                                            OR
                                            (    uai2.PK1_VALUE IS NOT NULL
                                             AND uai2.PK2_VALUE IS NOT NULL
                                             AND NOT EXISTS (SELECT NULL
                                                             FROM EGO_ITEM_ASSOCIATIONS eia
                                                             WHERE eia.INVENTORY_ITEM_ID = uai2.INVENTORY_ITEM_ID
                                                               AND eia.ORGANIZATION_ID   = uai2.ORGANIZATION_ID
                                                               AND eia.PK1_VALUE         = uai2.PK1_VALUE
                                                               AND eia.PK2_VALUE         = uai2.PK2_VALUE
                                                               AND eia.DATA_LEVEL_ID     = uai2.DATA_LEVEL_ID
                                                            )
                                            )
                                          )
                                   );
    ELSE
      UPDATE EGO_ITM_USR_ATTR_INTRFC uai
         SET uai.PROCESS_STATUS = G_PS_BAD_SUPPLIER_SITE
      WHERE uai.DATA_SET_ID    = p_data_set_id
        AND uai.PROCESS_STATUS = G_PS_IN_PROCESS
        AND uai.ROW_IDENTIFIER IN (SELECT DISTINCT
                                           UAI2.ROW_IDENTIFIER
                                    FROM EGO_ITM_USR_ATTR_INTRFC uai2
                                    WHERE uai2.DATA_SET_ID    = p_data_set_id
                                      AND uai2.PROCESS_STATUS = G_PS_IN_PROCESS
                                      AND uai2.DATA_LEVEL_ID  = l_item_sup_site_dl_id
                                      AND ( uai2.PK1_VALUE  IS NULL
                                            OR
                                            uai2.PK2_VALUE  IS NULL
                                            OR
                                            (    uai2.PK1_VALUE IS NOT NULL
                                             AND uai2.PK2_VALUE IS NOT NULL
                                             AND NOT EXISTS (SELECT NULL
                                                             FROM EGO_ITEM_ASSOCIATIONS eia
                                                             WHERE eia.INVENTORY_ITEM_ID = uai2.INVENTORY_ITEM_ID
                                                               AND eia.ORGANIZATION_ID   = uai2.ORGANIZATION_ID
                                                               AND eia.PK1_VALUE         = uai2.PK1_VALUE
                                                               AND eia.PK2_VALUE         = uai2.PK2_VALUE
                                                               AND eia.DATA_LEVEL_ID     = uai2.DATA_LEVEL_ID
                                                             UNION ALL
                                                             SELECT NULL
                                                             FROM EGO_ITEM_ASSOCIATIONS_INTF eiai
                                                             WHERE eiai.INVENTORY_ITEM_ID = uai2.INVENTORY_ITEM_ID
                                                               AND eiai.ORGANIZATION_ID   = uai2.ORGANIZATION_ID
                                                               AND eiai.PK1_VALUE         = uai2.PK1_VALUE
                                                               AND eiai.PK2_VALUE         = uai2.PK2_VALUE
                                                               AND eiai.DATA_LEVEL_ID     = uai2.DATA_LEVEL_ID
                                                               AND eiai.BATCH_ID          = uai2.DATA_SET_ID
                                                               AND eiai.PROCESS_FLAG      = 1
                                                            )
                                            )
                                          )
                                   );
    END IF;


    ------------------------------------------------------------------
    -- Next, validate the Item Supplier site Org attrs. Validate    --
    -- that the pk1,pk2_value along with the organization_id exists --
    -- in ego_item_associations for this item                       --
    ------------------------------------------------------------------
    IF p_validate_only = FND_API.G_FALSE THEN
      UPDATE EGO_ITM_USR_ATTR_INTRFC uai
         SET uai.PROCESS_STATUS = G_PS_BAD_SUPPLIER_SITE_ORG
      WHERE uai.DATA_SET_ID    = p_data_set_id
        AND uai.PROCESS_STATUS = G_PS_IN_PROCESS
        AND uai.ROW_IDENTIFIER IN (SELECT DISTINCT
                                           UAI2.ROW_IDENTIFIER
                                    FROM EGO_ITM_USR_ATTR_INTRFC uai2
                                    WHERE uai2.DATA_SET_ID    = p_data_set_id
                                      AND uai2.PROCESS_STATUS = G_PS_IN_PROCESS
                                      AND uai2.DATA_LEVEL_ID  = l_item_sup_site_org_dl_id
                                      AND ( uai2.PK1_VALUE  IS NULL
                                            OR
                                            uai2.PK2_VALUE  IS NULL
                                            OR
                                            (    uai2.PK1_VALUE IS NOT NULL
                                             AND uai2.PK2_VALUE IS NOT NULL
                                             AND NOT EXISTS (SELECT NULL
                                                             FROM EGO_ITEM_ASSOCIATIONS eia
                                                             WHERE eia.INVENTORY_ITEM_ID = uai2.INVENTORY_ITEM_ID
                                                               AND eia.ORGANIZATION_ID   = uai2.ORGANIZATION_ID
                                                               AND eia.PK1_VALUE         = uai2.PK1_VALUE
                                                               AND eia.PK2_VALUE         = uai2.PK2_VALUE
                                                               AND eia.DATA_LEVEL_ID     = uai2.DATA_LEVEL_ID
                                                            )
                                            )
                                          )
                                   );
    ELSE
      UPDATE EGO_ITM_USR_ATTR_INTRFC uai
         SET uai.PROCESS_STATUS = G_PS_BAD_SUPPLIER_SITE_ORG
      WHERE uai.DATA_SET_ID    = p_data_set_id
        AND uai.PROCESS_STATUS = G_PS_IN_PROCESS
        AND uai.ROW_IDENTIFIER IN (SELECT DISTINCT
                                           UAI2.ROW_IDENTIFIER
                                    FROM EGO_ITM_USR_ATTR_INTRFC uai2
                                    WHERE uai2.DATA_SET_ID    = p_data_set_id
                                      AND uai2.PROCESS_STATUS = G_PS_IN_PROCESS
                                      AND uai2.DATA_LEVEL_ID  = l_item_sup_site_org_dl_id
                                      AND ( uai2.PK1_VALUE  IS NULL
                                            OR
                                            uai2.PK2_VALUE  IS NULL
                                            OR
                                            (    uai2.PK1_VALUE IS NOT NULL
                                             AND uai2.PK2_VALUE IS NOT NULL
                                             AND NOT EXISTS (SELECT NULL
                                                             FROM EGO_ITEM_ASSOCIATIONS eia
                                                             WHERE eia.INVENTORY_ITEM_ID = uai2.INVENTORY_ITEM_ID
                                                               AND eia.ORGANIZATION_ID   = uai2.ORGANIZATION_ID
                                                               AND eia.PK1_VALUE         = uai2.PK1_VALUE
                                                               AND eia.PK2_VALUE         = uai2.PK2_VALUE
                                                               AND eia.DATA_LEVEL_ID     = uai2.DATA_LEVEL_ID
                                                             UNION ALL
                                                             SELECT NULL
                                                             FROM EGO_ITEM_ASSOCIATIONS_INTF eiai
                                                             WHERE eiai.INVENTORY_ITEM_ID = uai2.INVENTORY_ITEM_ID
                                                               AND eiai.ORGANIZATION_ID   = uai2.ORGANIZATION_ID
                                                               AND eiai.PK1_VALUE         = uai2.PK1_VALUE
                                                               AND eiai.PK2_VALUE         = uai2.PK2_VALUE
                                                               AND eiai.DATA_LEVEL_ID     = uai2.DATA_LEVEL_ID
                                                               AND eiai.BATCH_ID          = uai2.DATA_SET_ID
                                                               AND eiai.PROCESS_FLAG      = 1
                                                            )
                                            )
                                          )
                                   );
    END IF;


    --------------------------------------------------------------------------------
    -- Mark as errors all rows that share the same logical Attribute Group        --
    -- Variant attribute values for existing SKUs can not be updated              --
    --------------------------------------------------------------------------------
    IF p_validate_only = FND_API.G_TRUE THEN
      UPDATE EGO_ITM_USR_ATTR_INTRFC
      SET PROCESS_STATUS = G_PS_SKU_VAR_VALUE_NOT_UPD
      WHERE DATA_SET_ID = p_data_set_id
        AND PROCESS_STATUS = G_PS_IN_PROCESS
        AND ROW_IDENTIFIER IN (SELECT ROW_IDENTIFIER
                               FROM
                                 EGO_ITM_USR_ATTR_INTRFC intf,
                                 EGO_FND_DSC_FLX_CTX_EXT ag_ext,
                                 MTL_SYSTEM_ITEMS_B msib
                               WHERE intf.DATA_SET_ID         = p_data_set_id
                                 AND intf.PROCESS_STATUS      = G_PS_IN_PROCESS
                                 AND intf.ATTR_GROUP_ID       = ag_ext.ATTR_GROUP_ID
                                 AND ag_ext.VARIANT           = 'Y'
                                 AND intf.INVENTORY_ITEM_ID   = msib.INVENTORY_ITEM_ID
                                 AND intf.ORGANIZATION_ID     = msib.ORGANIZATION_ID
                                 AND msib.STYLE_ITEM_FLAG     = 'N'
                                 AND EXISTS (SELECT NULL
                                             FROM EGO_MTL_SY_ITEMS_EXT_B ext_prod
                                             WHERE ext_prod.INVENTORY_ITEM_ID = msib.INVENTORY_ITEM_ID
                                               AND ext_prod.ORGANIZATION_ID   = msib.ORGANIZATION_ID
                                               AND ext_prod.ATTR_GROUP_ID     = ag_ext.ATTR_GROUP_ID
                                            )
                              );

      EGO_USER_ATTRS_DATA_PVT.Debug_Msg('Marked all SKU records to error, if trying to update variant value, count='||SQL%ROWCOUNT, 1);
    END IF;

    --------------------------------------------------------------------------------
    -- Mark as errors all rows that share the same logical Attribute Group        --
    -- Inherited attribute values can not be processed for SKUs                   --
    --------------------------------------------------------------------------------
    UPDATE EGO_ITM_USR_ATTR_INTRFC
    SET PROCESS_STATUS = G_PS_INH_ATTR_FOR_SKU_NOT_UPD
    WHERE DATA_SET_ID = p_data_set_id
      AND PROCESS_STATUS = G_PS_IN_PROCESS
      AND ROW_IDENTIFIER IN (SELECT ROW_IDENTIFIER
                             FROM
                               EGO_ITM_USR_ATTR_INTRFC intf,
                               EGO_ATTR_GROUP_DL eagd
                             WHERE intf.DATA_SET_ID          = p_data_set_id
                               AND intf.PROCESS_STATUS       = G_PS_IN_PROCESS
                               AND intf.ATTR_GROUP_ID        = eagd.ATTR_GROUP_ID
                               AND intf.DATA_LEVEL_ID        = eagd.DATA_LEVEL_ID
                               AND NVL(eagd.DEFAULTING, 'D') = 'I'
                               AND EXISTS (SELECT NULL FROM MTL_SYSTEM_ITEMS_INTERFACE msii
                                           WHERE msii.SET_PROCESS_ID    = intf.DATA_SET_ID
                                             AND msii.PROCESS_FLAG      = 1
                                             AND msii.INVENTORY_ITEM_ID = intf.INVENTORY_ITEM_ID
                                             AND msii.ORGANIZATION_ID   = intf.ORGANIZATION_ID
                                             AND msii.STYLE_ITEM_FLAG   = 'N'
                                           UNION ALL
                                           SELECT NULL FROM MTL_SYSTEM_ITEMS_B msib
                                           WHERE intf.INVENTORY_ITEM_ID = msib.INVENTORY_ITEM_ID
                                             AND intf.ORGANIZATION_ID   = msib.ORGANIZATION_ID
                                             AND msib.STYLE_ITEM_FLAG   = 'N'
                                          )
                            );

    EGO_USER_ATTRS_DATA_PVT.Debug_Msg('Marked all SKU records to error, if trying to update inherited attribute value, count='||SQL%ROWCOUNT, 1);


    ---------------------------------------
    -- Set Lifecycle of the revision items.
    ---------------------------------------
    IF p_validate_only = FND_API.G_FALSE THEN
      UPDATE EGO_ITM_USR_ATTR_INTRFC UAI
         SET (UAI.PROG_INT_NUM3)
                = NVL((SELECT MIR.CURRENT_PHASE_ID
                       FROM MTL_ITEM_REVISIONS MIR
                       WHERE MIR.REVISION_ID = UAI.REVISION_ID
                      ), UAI.PROG_INT_NUM3),
              PROG_INT_CHAR2 =
                  NVL((SELECT 'Y'
                     FROM MTL_ITEM_REVISIONS_INTERFACE MIRI
                    WHERE MIRI.REVISION_ID = UAI.REVISION_ID
                      AND MIRI.request_id = UAI.REQUEST_ID
                      AND MIRI.TRANSACTION_TYPE = 'CREATE'
                      AND MIRI.PROCESS_FLAG = 7
                      AND ROWNUM = 1
                      ),PROG_INT_CHAR2)
       WHERE UAI.DATA_SET_ID = p_data_set_id
         AND UAI.PROCESS_STATUS = G_PS_IN_PROCESS
         AND UAI.REVISION_ID IS NOT NULL
         AND UAI.ITEM_CATALOG_GROUP_ID IS NOT NULL;
    ELSE
      UPDATE EGO_ITM_USR_ATTR_INTRFC UAI
         SET UAI.PROG_INT_NUM3
                = NVL((CASE WHEN EXISTS (SELECT 1
                                         FROM MTL_ITEM_REVISIONS mir
                                         WHERE mir.REVISION_ID = UAI.REVISION_ID
                                        )
                            THEN (SELECT mir1.CURRENT_PHASE_ID
                                  FROM MTL_ITEM_REVISIONS mir1
                                  WHERE mir1.REVISION_ID = UAI.REVISION_ID
                                 )
                            ELSE (SELECT miri.CURRENT_PHASE_ID
                                  FROM MTL_ITEM_REVISIONS_INTERFACE miri
                                  WHERE miri.REVISION_ID = UAI.REVISION_ID
                                    AND miri.SET_PROCESS_ID = UAI.DATA_SET_ID
                                    AND miri.PROCESS_FLAG = 1
                                    AND ROWNUM = 1
                                 )
                       END
                      ), UAI.PROG_INT_NUM3),
              PROG_INT_CHAR2 =
                  NVL((SELECT 'Y'
                     FROM MTL_ITEM_REVISIONS_INTERFACE MIRI1
                    WHERE MIRI1.REVISION_ID = UAI.REVISION_ID
                      AND MIRI1.SET_PROCESS_ID = UAI.DATA_SET_ID
                      AND MIRI1.TRANSACTION_TYPE = 'CREATE'
                      AND MIRI1.PROCESS_FLAG = 1
                      AND ROWNUM = 1
                      ),PROG_INT_CHAR2)
       WHERE UAI.DATA_SET_ID = p_data_set_id
         AND UAI.PROCESS_STATUS = G_PS_IN_PROCESS
         AND UAI.REVISION_ID IS NOT NULL
         AND UAI.ITEM_CATALOG_GROUP_ID IS NOT NULL;
    END IF;
--    write_records(p_data_set_id => p_data_set_id,  p_module => l_api_name, p_message => 'After rev lc');

    ----------------------------------------------
    -- Set the actual cc where LC is associated --
    ----------------------------------------------
    UPDATE EGO_ITM_USR_ATTR_INTRFC UAI
       SET UAI.PROG_INT_NUM1 =
              (SELECT ic.item_catalog_group_id
                 FROM mtl_item_catalog_groups_b ic
                WHERE EXISTS
                    ( SELECT olc.object_classification_code CatalogId
                      FROM  ego_obj_type_lifecycles olc
                      WHERE olc.object_id = G_ITEM_OBJECT_ID
                      AND olc.lifecycle_id = UAI.PROG_INT_NUM2
                      AND olc.object_classification_code = ic.item_catalog_group_id
                    )
                AND ROWNUM = 1
                CONNECT BY PRIOR parent_catalog_group_id = item_catalog_group_id
                START WITH item_catalog_group_id = UAI.item_catalog_group_id
                )
     WHERE UAI.DATA_SET_ID = p_data_set_id
       AND UAI.PROCESS_STATUS = G_PS_IN_PROCESS
       AND UAI.ITEM_CATALOG_GROUP_ID IS NOT NULL
       AND UAI.PROG_INT_NUM2 IS NOT NULL
       AND UAI.PROG_INT_CHAR1 = 'A'
       AND UAI.PROG_INT_CHAR2 = 'N';
--    write_records(p_data_set_id => p_data_set_id,  p_module => l_api_name, p_message => 'After hier init');

    l_policy_check_sql :=
    ' UPDATE EGO_ITM_USR_ATTR_INTRFC UAI '||
      ' SET UAI.PROCESS_STATUS = :1 '||
    ' WHERE UAI.DATA_SET_ID = :2 '||
      ' AND UAI.PROCESS_STATUS = :3 '||
      ' AND UAI.ROW_IDENTIFIER IN  '||
          ' (SELECT DISTINCT UAI2.ROW_IDENTIFIER '||
             ' FROM EGO_ITM_USR_ATTR_INTRFC UAI2, ENG_CHANGE_POLICIES_V  ECP '||
            ' WHERE UAI2.DATA_SET_ID = :4 '||
              ' AND UAI2.PROCESS_STATUS = :5 '||
              ' AND UAI2.ITEM_CATALOG_GROUP_ID IS NOT NULL '||
              ' AND UAI2.PROG_INT_NUM2 IS NOT NULL '||
              ' AND UAI2.PROG_INT_CHAR1 = ''A''' ||
              ' AND UAI2.PROG_INT_CHAR2 = ''N''' ||
              ' AND ECP.ATTRIBUTE_OBJECT_NAME = ''EGO_CATALOG_GROUP'' '||
              ' AND ECP.ATTRIBUTE_CODE = ''ATTRIBUTE_GROUP'' '||
              ' AND ECP.POLICY_OBJECT_NAME = ''CATALOG_LIFECYCLE_PHASE'' '||
              ' AND ECP.POLICY_CHAR_VALUE IS NOT NULL '||
              ' AND ECP.POLICY_CHAR_VALUE = :6 '||
              ' AND ECP.ATTRIBUTE_NUMBER_VALUE = UAI2.ATTR_GROUP_ID '||
              ' AND ECP.POLICY_OBJECT_PK1_VALUE = TO_CHAR(UAI2.PROG_INT_NUM1) '||
              ' AND ECP.POLICY_OBJECT_PK2_VALUE = TO_CHAR(UAI2.PROG_INT_NUM2) '||
              ' AND ECP.POLICY_OBJECT_PK3_VALUE = TO_CHAR(UAI2.PROG_INT_NUM3) '||
              ' AND DATA_LEVEL_ID IN ( SELECT DATA_LEVEL_ID FROM EGO_DATA_LEVEL_B '||
              ' WHERE APPLICATION_ID = ''431'' '||
              ' AND DATA_LEVEL_NAME IN ( ''ITEM_LEVEL'', ''ITEM_REVISION_LEVEL'', ''ITEM_ORG'')) '||
           ' )';



    IF (p_debug_level > 0) THEN
      EGO_USER_ATTRS_DATA_PVT.Debug_Msg('Starting Change Policy conversion/erroring', 0);
    END IF;
    -------------------------------------------------------------------------------
    -- 5). Mark as errors all rows that share the same logical Attribute Group   --
    -- row with any rows for which the Change Policy is defined as NOT_ALLOWED   --
    -- (we do not process such rows; they cannot be modified);                   --
    -- the exception to this is rows for pending Items, which we still processed --
    -------------------------------------------------------------------------------

    BEGIN
      l_policy_check_name := 'NOT_ALLOWED';
      EXECUTE IMMEDIATE l_policy_check_sql USING G_PS_CHG_POLICY_NOT_ALLOWED,
                                                 p_data_set_id,
                                                 G_PS_IN_PROCESS,
                                                 p_data_set_id,
                                                 G_PS_IN_PROCESS,
                                                 l_policy_check_name;
    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;

    -------------------------------------------------------------------------------
    -- Processing variant attribute groups for Style item                        --
    -- Assumption is that STYLE_ITEM_FLAG in MSII will be populated always       --
    -- before this call, even for items that exists in production                --
    -- We are changing the process_status of all the variant attribute groups    --
    -- to G_PS_STYLE_VARIANT_IN_PROCESS so that they are not picked up by        --
    -- UDA bulkloader.                                                           --
    -------------------------------------------------------------------------------
    EGO_USER_ATTRS_DATA_PVT.Debug_Msg('Starting Style value set processing', 1);

    -- Fix for bug#9336604
    -- Added index hint
    UPDATE /*+ index(INTF, EGO_ITM_USR_ATTR_INTRFC_N3 ) */ EGO_ITM_USR_ATTR_INTRFC INTF
    SET PROCESS_STATUS = G_PS_STYLE_VARIANT_IN_PROCESS
    WHERE INTF.DATA_SET_ID = p_data_set_id
      AND INTF.PROCESS_STATUS = G_PS_IN_PROCESS
      AND EXISTS (SELECT NULL
                  FROM EGO_FND_DSC_FLX_CTX_EXT AG_EXT, MTL_SYSTEM_ITEMS_INTERFACE MSII
                  WHERE AG_EXT.VARIANT = 'Y'
                    AND AG_EXT.DESCRIPTIVE_FLEXFIELD_NAME    = NVL(INTF.ATTR_GROUP_TYPE, 'EGO_ITEMMGMT_GROUP')
                    AND AG_EXT.DESCRIPTIVE_FLEX_CONTEXT_CODE = INTF.ATTR_GROUP_INT_NAME
                    AND INTF.ORGANIZATION_ID                 = MSII.ORGANIZATION_ID
                    AND MSII.STYLE_ITEM_FLAG                 = 'Y'
                    AND INTF.INVENTORY_ITEM_ID               = MSII.INVENTORY_ITEM_ID
                    AND AG_EXT.APPLICATION_ID                = 431    /* Bug 9678667 */
                  UNION ALL
                  SELECT NULL
                  FROM EGO_FND_DSC_FLX_CTX_EXT AG_EXT1, MTL_SYSTEM_ITEMS_B MSIB
                  WHERE AG_EXT1.VARIANT = 'Y'
                    AND AG_EXT1.DESCRIPTIVE_FLEXFIELD_NAME    = NVL(INTF.ATTR_GROUP_TYPE, 'EGO_ITEMMGMT_GROUP')
                    AND AG_EXT1.DESCRIPTIVE_FLEX_CONTEXT_CODE = INTF.ATTR_GROUP_INT_NAME
                    AND INTF.ORGANIZATION_ID                  = MSIB.ORGANIZATION_ID
                    AND MSIB.STYLE_ITEM_FLAG                  = 'Y'
                    AND INTF.INVENTORY_ITEM_ID                = MSIB.INVENTORY_ITEM_ID
                    AND AG_EXT1.APPLICATION_ID                = 431    /* Bug 9678667 */
                 );

    EGO_USER_ATTRS_DATA_PVT.Debug_Msg('Updated Style records count='||SQL%ROWCOUNT, 1);

    -------------------------------------------------------------------------------
    -- Mark as errors all rows that share the same logical Attribute Group       --
    -- Associated value set can not be changed if any sku exists for the style   --
    -------------------------------------------------------------------------------
    UPDATE EGO_ITM_USR_ATTR_INTRFC
    SET PROCESS_STATUS = G_PS_VAR_VSET_CHG_NOT_ALLOWED
    WHERE DATA_SET_ID = p_data_set_id
      AND PROCESS_STATUS = G_PS_STYLE_VARIANT_IN_PROCESS
      AND ROW_IDENTIFIER IN (SELECT ROW_IDENTIFIER
                             FROM EGO_ITM_USR_ATTR_INTRFC INTF, MTL_SYSTEM_ITEMS_KFV MSIK
                             WHERE INTF.DATA_SET_ID     = p_data_set_id
                               AND INTF.PROCESS_STATUS  = G_PS_STYLE_VARIANT_IN_PROCESS
                               AND MSIK.STYLE_ITEM_ID   = INTF.INVENTORY_ITEM_ID
                               AND MSIK.ORGANIZATION_ID = INTF.ORGANIZATION_ID
                            );

    EGO_USER_ATTRS_DATA_PVT.Debug_Msg('Updated records to error where SKU exists for style, count='||SQL%ROWCOUNT, 1);

    -------------------------------------------------------------------------------
    -- Converting all the value set names entered by user to value set id        --
    -- Value set name is expected in ATTR_DISP_VALUE column, we convert it to    --
    -- value set id and store it in ATTR_VALUE_NUM col.                          --
    -------------------------------------------------------------------------------
    UPDATE EGO_ITM_USR_ATTR_INTRFC INTF
    SET ATTR_VALUE_NUM = (SELECT VALUE_SET_ID FROM EGO_VALUE_SETS_V VS
                          WHERE VALUE_SET_NAME = INTF.ATTR_DISP_VALUE)
    WHERE INTF.DATA_SET_ID     = p_data_set_id
      AND INTF.PROCESS_STATUS  = G_PS_STYLE_VARIANT_IN_PROCESS
      AND INTF.ATTR_DISP_VALUE IS NOT NULL;


    EGO_USER_ATTRS_DATA_PVT.Debug_Msg('Converted value set name to value set Id for styles, count='||SQL%ROWCOUNT, 1);
    --------------------------------------------------------------------------------
    -- Mark as errors all rows that share the same logical Attribute Group        --
    -- If not a valid value set i.e. Only value set associated at attribute level --
    -- or its child value set can be associated.                                  --
    --------------------------------------------------------------------------------
    UPDATE EGO_ITM_USR_ATTR_INTRFC
    SET PROCESS_STATUS = G_PS_BAD_STYLE_VAR_VALUE_SET
    WHERE DATA_SET_ID    = p_data_set_id
      AND PROCESS_STATUS = G_PS_STYLE_VARIANT_IN_PROCESS
      AND ROW_IDENTIFIER IN (SELECT ROW_IDENTIFIER
                             FROM EGO_ITM_USR_ATTR_INTRFC INTF
                             WHERE INTF.DATA_SET_ID    = p_data_set_id
                               AND INTF.PROCESS_STATUS = G_PS_STYLE_VARIANT_IN_PROCESS
                               AND NOT EXISTS (SELECT NULL
                                               FROM FND_DESCR_FLEX_COLUMN_USAGES FL_COL
                                               WHERE FL_COL.DESCRIPTIVE_FLEXFIELD_NAME    = INTF.ATTR_GROUP_TYPE
                                                 AND FL_COL.DESCRIPTIVE_FLEX_CONTEXT_CODE = INTF.ATTR_GROUP_INT_NAME
                                                 AND FL_COL.END_USER_COLUMN_NAME          = INTF.ATTR_INT_NAME
                                                 AND FL_COL.APPLICATION_ID                = 431
                                                 AND (INTF.ATTR_VALUE_NUM                 = FL_COL.FLEX_VALUE_SET_ID
                                                  OR  INTF.ATTR_VALUE_NUM IN (SELECT VS.VALUE_SET_ID
                                                                             FROM EGO_VALUE_SET_EXT VS
                                                                             WHERE VS.PARENT_VALUE_SET_ID = FL_COL.FLEX_VALUE_SET_ID)
                                                     )
                                              )
                            );

    EGO_USER_ATTRS_DATA_PVT.Debug_Msg('Marked error for invalid value sets, for styles, count='||SQL%ROWCOUNT, 1);

    --------------------------------------------------------------------------------
    -- Processing Style variant value sets. Using a merge statement so that bulk  --
    -- feature can be used                                                        --
    --------------------------------------------------------------------------------
    IF p_validate_only = FND_API.G_FALSE THEN
      MERGE INTO EGO_STYLE_VARIANT_ATTR_VS ESVAV
      USING (SELECT
               INTF.INVENTORY_ITEM_ID AS INVENTORY_ITEM_ID,
               INTF.ATTR_VALUE_NUM    AS VALUE_SET_ID,
               ATTR.ATTR_ID           AS ATTRIBUTE_ID
             FROM
               EGO_ITM_USR_ATTR_INTRFC INTF,
               EGO_FND_DF_COL_USGS_EXT ATTR,
               FND_DESCR_FLEX_COLUMN_USAGES FL_COL,
               MTL_SYSTEM_ITEMS_B MSIB
             WHERE INTF.ATTR_GROUP_TYPE               = ATTR.DESCRIPTIVE_FLEXFIELD_NAME
               AND INTF.ATTR_GROUP_INT_NAME           = ATTR.DESCRIPTIVE_FLEX_CONTEXT_CODE
               AND ATTR.APPLICATION_ID                = 431
               AND ATTR.APPLICATION_ID                = FL_COL.APPLICATION_ID
               AND ATTR.DESCRIPTIVE_FLEXFIELD_NAME    = FL_COL.DESCRIPTIVE_FLEXFIELD_NAME
               AND ATTR.DESCRIPTIVE_FLEX_CONTEXT_CODE = FL_COL.DESCRIPTIVE_FLEX_CONTEXT_CODE
               AND ATTR.APPLICATION_COLUMN_NAME       = FL_COL.APPLICATION_COLUMN_NAME
               AND INTF.ATTR_INT_NAME                 = FL_COL.END_USER_COLUMN_NAME
               AND INTF.DATA_SET_ID                   = p_data_set_id
               AND INTF.PROCESS_STATUS                = G_PS_STYLE_VARIANT_IN_PROCESS
               AND MSIB.INVENTORY_ITEM_ID             = INTF.INVENTORY_ITEM_ID
               AND MSIB.ORGANIZATION_ID               = INTF.ORGANIZATION_ID) INTRFC
      ON (ESVAV.INVENTORY_ITEM_ID = INTRFC.INVENTORY_ITEM_ID
          AND ESVAV.ATTRIBUTE_ID  = INTRFC.ATTRIBUTE_ID)
      WHEN MATCHED THEN
        UPDATE SET ESVAV.VALUE_SET_ID = INTRFC.VALUE_SET_ID
      WHEN NOT MATCHED THEN
        INSERT
          (
            INVENTORY_ITEM_ID,
            VALUE_SET_ID,
            ATTRIBUTE_ID,
            LAST_UPDATE_LOGIN,
            CREATION_DATE,
            CREATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATED_BY
          )
        VALUES
          (
            INTRFC.INVENTORY_ITEM_ID,
            INTRFC.VALUE_SET_ID,
            INTRFC.ATTRIBUTE_ID,
            l_login_id,
            SYSDATE,
            l_user_id,
            SYSDATE,
            l_user_id
          );

      EGO_USER_ATTRS_DATA_PVT.Debug_Msg('Inserted value sets to EGO_STYLE_VARIANT_ATTR_VS, for styles, count='||SQL%ROWCOUNT, 1);

      ---------------------------------------------------------------------------------
      -- Marking all these records as processed                                      --
      -- All the records that are in status G_PS_STYLE_VARIANT_IN_PROCESS to success --
      ---------------------------------------------------------------------------------
      UPDATE EGO_ITM_USR_ATTR_INTRFC
      SET PROCESS_STATUS = G_PS_SUCCESS
      WHERE DATA_SET_ID = p_data_set_id
        AND PROCESS_STATUS = G_PS_STYLE_VARIANT_IN_PROCESS;

      EGO_USER_ATTRS_DATA_PVT.Debug_Msg('Marked all style records to success, count='||SQL%ROWCOUNT, 1);
    END IF; --IF p_validate_only = FND_API.G_FALSE THEN



            --========================================--
            -- ERROR REPORTING FOR FAILED CONVERSIONS --
            --========================================--
    IF (p_debug_level > 0) THEN
      EGO_USER_ATTRS_DATA_PVT.Debug_Msg('Starting conversion error-reporting', 0);
    END IF;

    -------------------------------------------------------------------------
    --                   PIM for Telco item uda validations                --
    -------------------------------------------------------------------------

    /*IF (profile_value = 'Y') THEN
      l_row_identifier := NULL;
      FOR c_row_identfier_rec IN c_row_identfier(p_data_set_id)
      LOOP
        l_row_identifier := c_row_identfier_rec.ROW_IDENTIFIER;
        FOR c_com_atttr_groups_rec IN c_com_attr_groups(p_data_set_id, l_row_identifier)
        LOOP

          -- get attribute group
          l_com_attr_group_type := c_com_atttr_groups_rec.ATTR_GROUP_TYPE;
          l_com_attr_group_name := c_com_atttr_groups_rec.ATTR_GROUP_INT_NAME;
          l_com_attr_group_id := c_com_atttr_groups_rec.ATTR_GROUP_ID;
    -- get inventory_item_id, organization_id, revision_id
    l_inventory_item_id := c_com_atttr_groups_rec.INVENTORY_ITEM_ID;
    l_revision_id := c_com_atttr_groups_rec.REVISION_ID;
          l_organization_id := c_com_atttr_groups_rec.ORGANIZATION_ID;
    l_com_attr_int_name := c_com_atttr_groups_rec.ATTR_INT_NAME;
    IF (c_com_atttr_groups_rec.ATTR_VALUE_STR IS NOT NULL) THEN
      l_value_str := c_com_atttr_groups_rec.ATTR_VALUE_STR;
    ELSIF (c_com_atttr_groups_rec.ATTR_VALUE_NUM IS NOT NULL) THEN
      l_value_num := c_com_atttr_groups_rec.ATTR_VALUE_NUM;
    ELSIF (c_com_atttr_groups_rec.ATTR_VALUE_DATE IS NOT NULL) THEN
      l_value_date := c_com_atttr_groups_rec.ATTR_VALUE_DATE;
          ELSE
      l_value := TO_CHAR(c_com_atttr_groups_rec.ATTR_DISP_VALUE);
          END IF;
    l_curr_data_element := EGO_USER_ATTR_DATA_OBJ( NULL
            , l_com_attr_int_name
            , l_value_str
            , l_value_num
            , l_value_date
            , l_value
            , NULL  -- ATTR_UNIT_OF_MEASURE
            , NULL  -- USER_ROW_IDENTIFIER
            );
          IF (l_attributes_data_table IS NULL) THEN
      l_attributes_data_table := EGO_USER_ATTR_DATA_TABLE();
    END IF;
          l_attributes_data_table.EXTEND();
    l_attributes_data_table(l_attributes_data_table.LAST) := l_curr_data_element;
        END LOOP; -- loop for interface records for COM item uda for row_identifer ends
  l_pk_column_name_value_pairs := EGO_COL_NAME_VALUE_PAIR_ARRAY(
          EGO_COL_NAME_VALUE_PAIR_OBJ('INVENTORY_ITEM_ID', l_inventory_item_id)
               ,EGO_COL_NAME_VALUE_PAIR_OBJ('ORGANIZATION_ID', l_organization_id)
         ,EGO_COL_NAME_VALUE_PAIR_OBJ('REVISION_ID', l_revision_id));
          -- call package.procedure
        IF (EGO_COM_ATTR_VALIDATION.Is_Attribute_Group_Telco(l_com_attr_group_name,l_com_attr_group_type)) THEN
    EGO_COM_ATTR_VALIDATION.Validate_Attributes (
                        p_attr_group_type                  => l_com_attr_group_type
                       ,p_attr_group_name                  => l_com_attr_group_name
                       ,p_attr_group_id                    => l_com_attr_group_id
                       ,p_attr_name_value_pairs            => l_attributes_data_table
                       ,p_pk_column_name_value_pairs       => l_pk_column_name_value_pairs
                       ,x_return_status                    => l_telco_return_status
                       ,x_error_messages                   => l_error_messages
                 );
        END IF;
  -- get error message varray
  IF (l_telco_return_status = 'E') THEN
          FOR i IN l_error_messages.FIRST .. l_error_messages.LAST
    LOOP
      l_mark_error_record := FALSE;
            l_name := l_error_messages(i).NAME;
      l_err_value := l_error_messages(i).VALUE;
      l_error_row_identifier := l_row_identifier;
      IF (l_name = 'ATTR_GROUP_NAME') THEN
        l_error_attr_group_name := l_err_value;
            END IF;
      IF (l_name = 'ERROR_MESSAGE_NAME') THEN
        l_error_message := l_err_value;
            END IF;
      IF (l_name = 'ATTR_INT_NAME') THEN
        l_error_attr_name := l_err_value;
        l_mark_error_record := TRUE;
            END IF;
            IF (l_mark_error_record) THEN
              UPDATE EGO_ITM_USR_ATTR_INTRFC UAI
        SET UAI.PROCESS_STATUS = G_COM_VALDN_FAIL
        WHERE UAI.DATA_SET_ID = p_data_set_id
        AND UAI.PROCESS_STATUS = G_PS_IN_PROCESS
        AND UAI.ROW_IDENTIFIER = l_error_row_identifier
        AND UAI.ATTR_GROUP_INT_NAME = l_com_attr_group_name
        AND UAI.ATTR_INT_NAME = l_error_attr_name;

        l_token_table(1).TOKEN_NAME := 'ATTR_GROUP_NAME';
              l_token_table(1).TOKEN_VALUE := l_error_attr_group_name;
              l_error_message_name := l_error_message;
              l_item_return_status := FND_API.G_RET_STS_ERROR;
              ERROR_HANDLER.Add_Error_Message(
                p_message_name                  => l_error_message_name
               ,p_application_id                => 'EGO'
               ,p_token_tbl                     => l_token_table
               ,p_message_type                  => FND_API.G_RET_STS_ERROR
               ,p_row_identifier                => l_error_row_identifier
               ,p_entity_id                     => G_ENTITY_ID
               ,p_entity_code                   => G_ENTITY_CODE
               ,p_table_name                    => G_TABLE_NAME
               );
               l_token_table.DELETE();
            END IF;
    END LOOP;
        END IF;
        -- do validations ends
      END LOOP; -- loop for interface records for row_identifier ends
    END IF;
    */
    -- PIM for Telco item uda validations code ends

    --------------------------------------------------------------------------
    -- We fetch representative rows marked as errors and add error messages --
    -- explaining the point in our conversion process at which each failed; --
    -- note that to avoid multiple error messages for the same missing data --
    -- we use DISTINCT in our cursor query and thus should only get one row --
    -- for each ROW_IDENTIFIER (since Org Code, Item Number, Revision and   --
    -- Catalog Group Name should be the same for a given ROW_IDENTIFIER).   --
    --------------------------------------------------------------------------
    FOR error_rec IN error_case_cursor(p_data_set_id)
    LOOP
      -- there is an error in processing.
      RETCODE := L_CONC_RET_STS_WARNING;
      ------------------------------------------------------------------------------------
      -- Increment our debugging row counter so we can report how many rows have failed --
      ------------------------------------------------------------------------------------
      l_debug_rowcount := l_debug_rowcount + 1;
      --
      -- get the attribute group display name
      --
      IF error_rec.PROCESS_STATUS IN (G_PS_BAD_ATTR_GROUP_ID, G_PS_BAD_ATTR_GROUP_NAME,
                                      G_PS_CHG_POLICY_NOT_ALLOWED,G_PS_DATA_LEVEL_INCORRECT,
                                      G_PS_BAD_DATA_LEVEL, G_PS_INH_ATTR_FOR_SKU_NOT_UPD)
      THEN
        l_current_attr_group_obj := EGO_USER_ATTRS_COMMON_PVT.Get_Attr_Group_Metadata(
                                      p_attr_group_id   => error_rec.ATTR_GROUP_ID
                                     ,p_application_id  => 431
                                     ,p_attr_group_type => error_rec.ATTR_GROUP_TYPE --l_attr_group_type
                                     ,p_attr_group_name => error_rec.ATTR_GROUP_INT_NAME
                                    );
        IF l_current_attr_group_obj IS NULL THEN
          l_current_attr_group_name := error_rec.attr_group_int_name;
        ELSE
          l_current_attr_group_name := l_current_attr_group_obj.ATTR_GROUP_DISP_NAME;
        END IF;
      END IF;
      -----------------------------------------------
      -- 1). It may be a bad Org ID or Org Code... --
      -----------------------------------------------
      IF (error_rec.PROCESS_STATUS = G_PS_BAD_ORG_ID) THEN

        l_token_table(1).TOKEN_NAME := 'ORG_ID';
        l_token_table(1).TOKEN_VALUE := error_rec.ORGANIZATION_ID;

        l_error_message_name := 'EGO_EF_BL_ORG_ID_ERR';

      ELSIF (error_rec.PROCESS_STATUS = G_PS_BAD_ORG_CODE) THEN

        l_token_table(1).TOKEN_NAME := 'ORG_CODE';
        l_token_table(1).TOKEN_VALUE := error_rec.ORGANIZATION_CODE;

        l_error_message_name := 'EGO_EF_BL_ORG_CODE_ERR';

      ---------------------------------------------------------
      -- 2). ...or it may be a bad Item ID or Item Number... --
      ---------------------------------------------------------
      ELSIF (error_rec.PROCESS_STATUS = G_PS_BAD_ITEM_ID) THEN

        l_token_table(1).TOKEN_NAME := 'ITEM_ID';
        l_token_table(1).TOKEN_VALUE := error_rec.INVENTORY_ITEM_ID;

        l_error_message_name := 'EGO_EF_BL_INV_ITEM_ID_ERR';

      ELSIF (error_rec.PROCESS_STATUS = G_PS_BAD_ITEM_NUMBER) THEN

        l_token_table(1).TOKEN_NAME := 'ITEM_NUMBER';
        l_token_table(1).TOKEN_VALUE := error_rec.ITEM_NUMBER;

        l_error_message_name := 'EGO_EF_BL_ITEM_NUM_ERR';

      ---------------------------------------------------------------
      -- 3). ...or it may be a bad Revision ID or Revision Code... --
      ---------------------------------------------------------------
      ELSIF (error_rec.PROCESS_STATUS = G_PS_BAD_REVISION_ID) THEN

        l_token_table(1).TOKEN_NAME := 'REVISION_ID';
        l_token_table(1).TOKEN_VALUE := error_rec.REVISION_ID;

        l_error_message_name := 'EGO_EF_BL_REV_ID_ERR';

      ELSIF (error_rec.PROCESS_STATUS = G_PS_BAD_REVISION_CODE) THEN

        l_token_table(1).TOKEN_NAME := 'REVISION';
        l_token_table(1).TOKEN_VALUE := error_rec.REVISION;

        l_error_message_name := 'EGO_EF_BL_REV_CODE_ERR';

      ------------------------------------------------
      -- 4). ...or it may be a bad Catalog Group ID --
      ------------------------------------------------
      ELSIF (error_rec.PROCESS_STATUS = G_PS_BAD_CATALOG_GROUP_ID) THEN

        l_token_table(1).TOKEN_NAME := 'ITEM_NUMBER';
        l_token_table(1).TOKEN_VALUE := error_rec.ITEM_NUMBER;
        l_token_table(2).TOKEN_NAME := 'ORG_CODE';
        l_token_table(2).TOKEN_VALUE := error_rec.ORGANIZATION_CODE;

        l_error_message_name := 'EGO_EF_BL_CAT_GROUP_ID_ERR';

      -------------------------------------------
      -- . ...or it may be a bad Attr Group ID --
      -------------------------------------------
      ELSIF (error_rec.PROCESS_STATUS = G_PS_BAD_ATTR_GROUP_ID) THEN
        l_token_table(1).TOKEN_NAME := 'AG_ID';
        l_token_table(1).TOKEN_VALUE := error_rec.ATTR_GROUP_ID;
        l_token_table(2).TOKEN_NAME := 'AG_NAME';
        l_token_table(2).TOKEN_VALUE := l_current_attr_group_name;

        l_error_message_name := 'EGO_EF_BAD_AG_ID';

      ---------------------------------------------
      -- . ...or it may be a bad Attr Group Name --
      ---------------------------------------------
      ELSIF (error_rec.PROCESS_STATUS = G_PS_BAD_ATTR_GROUP_NAME) THEN
        l_token_table(1).TOKEN_NAME := 'AG_NAME';
        l_token_table(1).TOKEN_VALUE := l_current_attr_group_name;

        l_error_message_name := 'EGO_EF_BAD_AG_NAME';
      ------------------------------------------------
      -- 5)...If the incorrect data level changes
      ------------------------------------------------
      ELSIF (error_rec.PROCESS_STATUS = G_PS_DATA_LEVEL_INCORRECT) THEN
        l_token_table(1).TOKEN_NAME := 'AG_NAME';
        l_token_table(1).TOKEN_VALUE := l_current_attr_group_name;

        l_error_message_name := 'EGO_EF_DATA_LEVEL_INCORRECT';
      ------------------------------------------------
      -- 6)...If data level is not correct
      ------------------------------------------------
      ELSIF (error_rec.PROCESS_STATUS = G_PS_BAD_DATA_LEVEL) THEN
        l_token_table(1).TOKEN_NAME := 'ITEM_NUMBER';
        l_token_table(1).TOKEN_VALUE := error_rec.ITEM_NUMBER;

        l_token_table(2).TOKEN_NAME := 'AG_NAME';
        l_token_table(2).TOKEN_VALUE := l_current_attr_group_name;

        l_error_message_name := 'EGO_EF_BAD_DATA_LEVEL';
      ------------------------------------------------
      -- 7)...If supplier is not correct
      ------------------------------------------------
      ELSIF (error_rec.PROCESS_STATUS = G_PS_BAD_SUPPLIER) THEN
        l_token_table(1).TOKEN_NAME := 'ITEM_NUMBER';
        l_token_table(1).TOKEN_VALUE := error_rec.ITEM_NUMBER;

        l_token_table(2).TOKEN_NAME := 'SUPPLIER';
        l_token_table(2).TOKEN_VALUE := error_rec.PK1_VALUE;

        l_error_message_name := 'EGO_EF_BAD_SUPPLIER';
      ------------------------------------------------
      -- 8)...If supplier site is not correct
      ------------------------------------------------
      ELSIF (error_rec.PROCESS_STATUS = G_PS_BAD_SUPPLIER_SITE) THEN
        l_token_table(1).TOKEN_NAME := 'ITEM_NUMBER';
        l_token_table(1).TOKEN_VALUE := error_rec.ITEM_NUMBER;

        l_token_table(2).TOKEN_NAME := 'SUP';
        l_token_table(2).TOKEN_VALUE := error_rec.PK1_VALUE;

        l_token_table(3).TOKEN_NAME := 'SUP_SITE';
        l_token_table(3).TOKEN_VALUE := error_rec.PK2_VALUE;

        l_error_message_name := 'EGO_EF_BAD_SUPPLIER_SITE';
      ------------------------------------------------
      -- 9)...If supplier is not correct
      ------------------------------------------------
      ELSIF (error_rec.PROCESS_STATUS = G_PS_BAD_SUPPLIER_SITE_ORG) THEN
        l_token_table(1).TOKEN_NAME := 'ITEM_NUMBER';
        l_token_table(1).TOKEN_VALUE := error_rec.ITEM_NUMBER;

        l_token_table(2).TOKEN_NAME := 'SUP';
        l_token_table(2).TOKEN_VALUE := error_rec.PK1_VALUE;

        l_token_table(3).TOKEN_NAME := 'SUP_SITE';
        l_token_table(3).TOKEN_VALUE := error_rec.PK2_VALUE;

        l_error_message_name := 'EGO_EF_BAD_SUPPLIER_SITE_ORG';
      ------------------------------------------------
      -- 10)...If value set name for variant attribute
      --      for style item is not correct
      ------------------------------------------------
      ELSIF (error_rec.PROCESS_STATUS = G_PS_BAD_STYLE_VAR_VALUE_SET ) THEN
        l_token_table(1).TOKEN_NAME := 'ITEM_NUMBER';
        l_token_table(1).TOKEN_VALUE := error_rec.ITEM_NUMBER;

        l_token_table(2).TOKEN_NAME := 'VSET_NAME';
        l_token_table(2).TOKEN_VALUE := error_rec.ATTR_DISP_VALUE;

        l_error_message_name := 'EGO_BAD_VAR_VALUE_SET';
      -------------------------------------------------------
      -- 11)...If changing of variant value set is not allowed
      -------------------------------------------------------
      ELSIF (error_rec.PROCESS_STATUS = G_PS_VAR_VSET_CHG_NOT_ALLOWED ) THEN
        l_token_table(1).TOKEN_NAME := 'ITEM_NUMBER';
        l_token_table(1).TOKEN_VALUE := error_rec.ITEM_NUMBER;

        l_error_message_name := 'EGO_VAR_VSET_CHG_NOT_ALLOWED';
      ------------------------------------------------
      -- 12)...If changing SKU variant attribute value
      --      is not allowed
      ------------------------------------------------
      ELSIF (error_rec.PROCESS_STATUS = G_PS_SKU_VAR_VALUE_NOT_UPD ) THEN
        l_token_table(1).TOKEN_NAME := 'ITEM_NUMBER';
        l_token_table(1).TOKEN_VALUE := error_rec.ITEM_NUMBER;

        l_token_table(2).TOKEN_NAME := 'VALUE';
        l_token_table(2).TOKEN_VALUE := COALESCE(error_rec.ATTR_VALUE_STR, TO_CHAR(error_rec.ATTR_VALUE_NUM), TO_CHAR(error_rec.ATTR_VALUE_DATE), error_rec.ATTR_DISP_VALUE);

        l_error_message_name := 'EGO_VAR_VALUE_CHG_NOT_ALLOWED';
      ------------------------------------------------
      -- 13)...Inherited attribute value for SKU
      --      is not allowed
      ------------------------------------------------
      ELSIF (error_rec.PROCESS_STATUS = G_PS_INH_ATTR_FOR_SKU_NOT_UPD ) THEN
        l_token_table(1).TOKEN_NAME := 'ITEM_NUMBER';
        l_token_table(1).TOKEN_VALUE := error_rec.ITEM_NUMBER;

        l_token_table(2).TOKEN_NAME := 'AG_NAME';
        l_token_table(2).TOKEN_VALUE := l_current_attr_group_name;

        l_error_message_name := 'EGO_INH_ATTR_FOR_SKU_NOT_UPD';

      ----------------------------------------------------
      -- 14). ...or else the row is under Change control --
      ----------------------------------------------------
      ELSIF (error_rec.PROCESS_STATUS = G_PS_CHG_POLICY_NOT_ALLOWED ) THEN
        --------------------------------------------------------------
        -- We fetch the Attr Group metadata object (which is cached --
        -- by EGO_USER_ATTRS_COMMON_PVT after it's fetched once)    --
        --------------------------------------------------------------
        -- decide the message based upon
        -- item /item revision
        -- change order required OR changes not allowed
        l_token_table(1).TOKEN_NAME := 'ATTR_GROUP_NAME';
        l_token_table(1).TOKEN_VALUE := l_current_attr_group_name;
        l_token_table(2).TOKEN_NAME := 'ITEM_NUMBER';
        l_token_table(2).TOKEN_VALUE := error_rec.ITEM_NUMBER;
        ----------------------------------------------------------------
        -- If we've already fetched the Catalog Group name, we reuse  --
        -- it; otherwise, we fetch it and store it in our local table --
        ----------------------------------------------------------------
        IF (l_catalog_category_names_table.EXISTS(error_rec.prog_int_num1)) THEN
          l_current_category_name := l_catalog_category_names_table(error_rec.prog_int_num1);--Bugfix:5343821
        ELSE
          SELECT concatenated_segments
            INTO l_current_category_name
            FROM MTL_ITEM_CATALOG_GROUPS_KFV
           WHERE ITEM_CATALOG_GROUP_ID = error_rec.prog_int_num1;
          l_catalog_category_names_table(error_rec.prog_int_num1) := l_current_category_name;
        END IF;
        l_token_table(3).TOKEN_NAME := 'CATALOG_CATEGORY_NAME';
        l_token_table(3).TOKEN_VALUE := l_current_category_name;
        SELECT PEP.NAME
          INTO l_current_life_cycle
          FROM PA_EGO_LIFECYCLES_V     PEP
         WHERE PEP.PROJ_ELEMENT_ID = error_rec.prog_int_num2;
        l_token_table(4).TOKEN_NAME := 'LIFE_CYCLE';
        l_token_table(4).TOKEN_VALUE := l_current_life_cycle;

        IF error_rec.revision_id IS NULL THEN
          -- error is in context of item.
          --IF (error_rec.PROCESS_STATUS = G_PS_CHG_POLICY_CO_REQUIRED) THEN
            --l_error_message_name := 'EGO_EF_BL_ITM_CO_REQD_ERR';
         -- ELSE
            l_error_message_name := 'EGO_EF_BL_ITM_NOT_ALLOW_ERR';
          --END IF;
          -----------------------------------------------------------------
          -- Since it's not as convenient, we don't have a local storing --
          -- scheme for Phase name; but we can create one if necessary   --
          -----------------------------------------------------------------
          SELECT PEP.NAME
            INTO l_current_phase_name
            FROM PA_EGO_PHASES_V         PEP
           WHERE PEP.PROJ_ELEMENT_ID = error_rec.prog_int_num3;
          l_token_table(5).TOKEN_NAME := 'PHASE';
          l_token_table(5).TOKEN_VALUE := l_current_phase_name;
        ELSE
          -- error is in context of item revision.
          --IF (error_rec.PROCESS_STATUS = G_PS_CHG_POLICY_CO_REQUIRED) THEN
            --l_error_message_name := 'EGO_EF_BL_REV_CO_REQD_ERR';
          --ELSE
            l_error_message_name := 'EGO_EF_BL_REV_NOT_ALLOW_ERR';
          --END IF;
          -----------------------------------------------------------------
          -- Since it's not as convenient, we don't have a local storing --
          -- scheme for Phase name; but we can create one if necessary   --
          -----------------------------------------------------------------
          SELECT PEP.NAME
            INTO l_current_phase_name
            FROM PA_EGO_PHASES_V         PEP
           WHERE PEP.PROJ_ELEMENT_ID = error_rec.prog_int_num3;
          l_token_table(5).TOKEN_NAME := 'PHASE';
          l_token_table(5).TOKEN_VALUE := l_current_phase_name;
          l_token_table(6).TOKEN_NAME := 'ITEM_REV';
          l_token_table(6).TOKEN_VALUE := error_rec.REVISION;
        END IF;
      END IF;

      l_item_return_status := FND_API.G_RET_STS_ERROR;
      ERROR_HANDLER.Add_Error_Message(
        p_message_name                  => l_error_message_name
       ,p_application_id                => 'EGO'
       ,p_token_tbl                     => l_token_table
       ,p_message_type                  => FND_API.G_RET_STS_ERROR
       ,p_row_identifier                => error_rec.TRANSACTION_ID
       ,p_entity_id                     => G_ENTITY_ID
       ,p_entity_code                   => G_ENTITY_CODE
       ,p_table_name                    => G_TABLE_NAME
      );
      l_token_table.DELETE();

    END LOOP;

    IF (p_debug_level > 0) THEN
      EGO_USER_ATTRS_DATA_PVT.Debug_Msg('Reported errors with '||l_debug_rowcount||' interface table rows', 0);
    END IF;

             --=====================================--
             -- LOOP PROCESSING OF STILL-VALID ROWS --
             --=====================================--
    IF (p_debug_level > 0) THEN
      EGO_USER_ATTRS_DATA_PVT.Debug_Msg('Starting loop processing of valid rows', 0);
    END IF;

    ---------------------------------------------------------------
    -- ...and then use it to mark as errors all rows in the list --
    -- (note that we have to use dynamic SQL because 1). static  --
    -- SQL treats the failed Row ID list as a string instead of  --
    -- a list of numbers, and 2). bulk-binding would cause us to --
    -- execute one SQL statement per failed Row ID.  Dynamic SQL --
    -- only executes one SQL statement for a given call to our   --
    -- concurrent program--so the fact that our failed Row IDs   --
    -- aren't passed as a bind variable doesn't matter, because  --
    -- the statement won't get parsed more than once anyway).    --
    ---------------------------------------------------------------

    l_dynamic_sql := ' UPDATE EGO_ITM_USR_ATTR_INTRFC'||
                     ' SET PROCESS_STATUS = '||G_PS_GENERIC_ERROR||
                     ' WHERE DATA_SET_ID = :1'||
                     '   AND (PROCESS_STATUS IN ('||G_PS_BAD_ORG_ID||', '||
                                                    G_PS_BAD_ORG_CODE||', '||
                                                    G_PS_BAD_ITEM_ID||', '||
                                                    G_PS_BAD_ITEM_NUMBER||', '||
                                                    G_PS_BAD_REVISION_ID||', '||
                                                    G_PS_BAD_REVISION_CODE||', '||
                                                    G_PS_BAD_CATALOG_GROUP_ID||', '||
                                                    G_PS_BAD_ATTR_GROUP_ID||', '||
                                                    G_PS_BAD_ATTR_GROUP_NAME||', '||
                                                    G_PS_CHG_POLICY_NOT_ALLOWED||', '||
                                                    G_PS_BAD_DATA_LEVEL||', '||
                                                    G_PS_BAD_SUPPLIER||', '||
                                                    G_PS_BAD_SUPPLIER_SITE||', '||
                                                    G_PS_BAD_SUPPLIER_SITE_ORG||', '||
                                                    G_PS_BAD_STYLE_VAR_VALUE_SET||', '||
                                                    G_PS_VAR_VSET_CHG_NOT_ALLOWED||', '||
                                                    G_PS_SKU_VAR_VALUE_NOT_UPD||', '||
                                                    G_PS_INH_ATTR_FOR_SKU_NOT_UPD||', '||
                                                    G_PS_DATA_LEVEL_INCORRECT||' ) )';

    EXECUTE IMMEDIATE l_dynamic_sql USING p_data_set_id;
  END IF; -- End of l_return = FALSE;   -- Bug 10263673

    -- Telco Item UDA validation --
    /*IF (profile_value = 'Y') THEN

      l_dynamic_sqlt := ' UPDATE EGO_ITM_USR_ATTR_INTRFC'||
                        ' SET PROCESS_STATUS = '||G_PS_GENERIC_ERROR||
                        ' WHERE DATA_SET_ID = :1'||
                        '   AND (PROCESS_STATUS IN ('||G_COM_VALDN_FAIL||') )';

      EXECUTE IMMEDIATE l_dynamic_sqlt USING p_data_set_id;

    END IF; */

    -- Bug 10263673 : Start
    /* Doing the TEMPLATE APPLICATION for UDAs before calling EGO_USER_ATTRS_BULK_PVT.Bulk_Load_User_Attrs_Data,
       the below peice of code will be executed only in import flow.
       This code will be executed always in import flow.
    */

    IF (INV_EGO_REVISION_VALIDATE.Get_Process_Control_HTML_API() = 'IMPORT')
    THEN
      BEGIN
        SELECT NVL(ENABLED_FOR_DATA_POOL, 'N')
        INTO l_enabled_for_data_pool
        FROM EGO_IMPORT_OPTION_SETS
        WHERE BATCH_ID = p_data_set_id;
      EXCEPTION WHEN OTHERS THEN
        l_enabled_for_data_pool := 'N';
      END;

      BEGIN
        SELECT 'Y' INTO l_copy_option_exists
        FROM EGO_IMPORT_COPY_OPTIONS
        WHERE BATCH_ID = p_data_set_id
          AND ROWNUM = 1;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          l_copy_option_exists := 'N';
      END;

      IF l_enabled_for_data_pool = 'N' THEN
        -- call process copy options for UDAs
        -- this will do the Apply Multiple Templates
        -- and copying of attributes if any
        EGO_IMPORT_UTIL_PVT.Process_Copy_Options_For_UDAs(retcode               => l_retcode,
                                                          errbuf                => l_errbuf,
                                                          p_batch_id            => p_data_set_id,
                                                          p_copy_options_exist  => l_copy_option_exists);

        EGO_USER_ATTRS_DATA_PVT.Debug_Msg(' Done Process_Copy_Options_For_UDAs with l_retcode, l_errbuf='||l_retcode||','||l_errbuf, 1);

        IF NVL(l_retcode, '0') > 0 THEN
          RETCODE := l_retcode;
          ERRBUF := l_errbuf;
        END IF;

        IF RETCODE = '2' THEN
          RETURN;
        END IF;
      END IF;   -- End of l_enabled_for_data_pool = 'N'

      EGO_IMPORT_UTIL_PVT.INSERT_FUN_GEN_SETUP_UDAS( p_data_set_id );
    END IF;

    /* If no data exists in interface table before template application.
       Check if data exists after template application, If no data exists then do not progress.
    */
    IF (l_return = TRUE) THEN
      SELECT
        COUNT(DATA_SET_ID)
        INTO l_rec_count
      FROM EGO_ITM_USR_ATTR_INTRFC intf
      WHERE DATA_SET_ID = p_data_set_id
        AND (PROCESS_STATUS IS NULL OR PROCESS_STATUS IN (G_PS_TO_BE_PROCESSED, G_PS_IN_PROCESS, G_PS_STYLE_VARIANT_IN_PROCESS) );

      IF (l_rec_count = 0) THEN
         EGO_USER_ATTRS_DATA_PVT.Debug_Msg('Returning because no data exists in interface table to process', 0);
         RETURN;
      END IF;
    END IF; -- End of l_return = TRUE -- Bug 10263673
     -- Bug 10263673 : End

    -- Call the EGO_USER_ATTRS_BULK_PVT.Bulk_Load_User_Attrs_Data  API instead of
    -- EGO_USER_ATTRS_DATA_PUB.Process_User_Attrs_Data

    EGO_USER_ATTRS_DATA_PVT.Debug_Msg('Starting User Attributes Bulk Load', 1);

    IF p_validate_only = FND_API.G_TRUE AND p_ignore_security_for_validate = FND_API.G_FALSE THEN
      l_privilege_predicate_api_name := 'EGO_ITEM_USER_ATTRS_CP_PUB.Get_Item_Security_Predicate';
    ELSE
      l_privilege_predicate_api_name := NULL;
    END IF;

    -- creating default privileges
    l_default_dl_view_priv_list := EGO_COL_NAME_VALUE_PAIR_ARRAY();
    l_default_dl_edit_priv_list := EGO_COL_NAME_VALUE_PAIR_ARRAY();
    FOR i IN c_data_levels_for_sec LOOP
      IF i.ATTR_GROUP_TYPE = 'EGO_ITEMMGMT_GROUP' AND i.DATA_LEVEL_NAME IN ('ITEM_SUP', 'ITEM_SUP_SITE', 'ITEM_SUP_SITE_ORG') THEN
        l_default_dl_view_priv_obj := EGO_COL_NAME_VALUE_PAIR_OBJ(i.DATA_LEVEL_ID, 'EGO_VIEW_ITEM_SUP_ASSIGN');
        l_default_dl_edit_priv_obj := EGO_COL_NAME_VALUE_PAIR_OBJ(i.DATA_LEVEL_ID, 'EGO_EDIT_ITEM_SUP_ASSIGN');
      ELSE
        l_default_dl_view_priv_obj := EGO_COL_NAME_VALUE_PAIR_OBJ(i.DATA_LEVEL_ID, 'EGO_VIEW_ITEM');
        l_default_dl_edit_priv_obj := EGO_COL_NAME_VALUE_PAIR_OBJ(i.DATA_LEVEL_ID, 'EGO_EDIT_ITEM');
      END IF;
      l_default_dl_view_priv_list.EXTEND;
      l_default_dl_view_priv_list(l_default_dl_view_priv_list.COUNT) := l_default_dl_view_priv_obj;

      l_default_dl_edit_priv_list.EXTEND;
      l_default_dl_edit_priv_list(l_default_dl_edit_priv_list.COUNT) := l_default_dl_edit_priv_obj;
    END LOOP;

    /* Fix for bug#9660659 - Start*/
    SELECT Count(1)
      INTO l_item_mgmt_count
    FROM  EGO_ITM_USR_ATTR_INTRFC
    WHERE data_set_id = p_data_set_id
      AND attr_group_type = 'EGO_ITEMMGMT_GROUP'
      AND ROWNUM = 1;

    IF(l_item_mgmt_count = 1) THEN
    /* Fix for bug#9660659 - End */

      EGO_USER_ATTRS_BULK_PVT.Bulk_Load_User_Attrs_Data (
          p_api_version                   =>  G_API_VERSION                    --IN   NUMBER
         ,p_application_id                =>  431                              --IN   NUMBER
         ,p_attr_group_type               =>  'EGO_ITEMMGMT_GROUP'             --IN   VARCHAR2
         ,p_object_name                   =>  G_ITEM_NAME                      --IN   VARCHAR2
         ,p_hz_party_id                   =>  G_HZ_PARTY_ID                    --IN   VARCHAR2
         ,p_interface_table_name          =>  'EGO_ITM_USR_ATTR_INTRFC'        --IN   VARCHAR2
         ,p_data_set_id                   =>  p_data_set_id                    --IN   NUMBER
         ,p_entity_id                     =>  G_ENTITY_ID                      --IN   NUMBER
         ,p_entity_index                  =>  l_entity_index_counter           --IN   NUMBER
         ,p_entity_code                   =>  G_ENTITY_CODE                    --IN   VARCHAR2
         ,p_debug_level                   =>  p_debug_level                    --IN   NUMBER
         ,p_init_error_handler            =>  FND_API.G_FALSE                  --IN   VARCHAR2
         ,p_init_fnd_msg_list             =>  FND_API.G_FALSE                  --IN   VARCHAR2
         ,p_log_errors                    =>  FND_API.G_TRUE                   --IN   VARCHAR2
         ,p_add_errors_to_fnd_stack       =>  FND_API.G_TRUE                   --IN   VARCHAR2
         ,p_commit                        =>  p_commit  -- FND_API.G_TRUE                   --IN   VARCHAR2/* Added to fix Bug#7422423*/
         ,p_default_dl_view_priv_list     =>  l_default_dl_view_priv_list
         ,p_default_dl_edit_priv_list     =>  l_default_dl_edit_priv_list
         ,p_privilege_predicate_api_name  =>  l_privilege_predicate_api_name   --IN   VARCHAR2
         ,p_related_class_codes_query     =>  l_related_class_codes_query      --IN   VARCHAR2
         ,p_validate                      =>  TRUE
         ,p_do_dml                        =>  FALSE
         ,p_do_req_def_valiadtion         =>  TRUE -- Fix for bug#9660659 FALSE --we will do this validation after the template is applied
         ,x_return_status                 =>  l_user_attrs_return_status       --OUT NOCOPY VARCHAR2
         ,x_errorcode                     =>  l_errorcode                      --OUT NOCOPY NUMBER
         ,x_msg_count                     =>  l_msg_count                      --OUT NOCOPY NUMBER
         ,x_msg_data                      =>  l_msg_data                       --OUT NOCOPY VARCHAR2
      );

      IF (l_user_attrs_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
         ERRBUF    :=  l_msg_data;
         RETCODE   :=  FND_API.G_RET_STS_UNEXP_ERROR;
         RAISE G_UNHANDLED_EXCEPTION;
      ELSIF l_user_attrs_return_status = G_FND_RET_STS_WARNING THEN
        RETCODE := L_CONC_RET_STS_WARNING;
      END IF;

    END IF; -- end of IF (l_item_mgmt_count = 1)   /* Fix for bug#9660659 */

    ---------------------------------------------------------------------------------
    -- Mark as errors all rows that share the same logical Attribute Group         --
    -- If attribute value does not belong to a valid value set i.e. in case of     --
    -- variant attributes, user can associate a child value set as well. So this   --
    -- validation will check that value belongs to child value set also,else error --
    --                                                                             --
    -- This validation needs to be done after the normal UDA validations are over  --
    ---------------------------------------------------------------------------------

    UPDATE EGO_ITM_USR_ATTR_INTRFC
    SET PROCESS_STATUS = G_PS_BAD_SKU_VAR_VALUE
    WHERE DATA_SET_ID    = p_data_set_id
      AND PROCESS_STATUS = G_PS_IN_PROCESS
      AND ROW_IDENTIFIER IN (SELECT ROW_IDENTIFIER
                             FROM
                               EGO_FND_DSC_FLX_CTX_EXT AG_EXT,
                               EGO_ITM_USR_ATTR_INTRFC INTF,
                               EGO_STYLE_VARIANT_ATTR_VS SVA,
                               EGO_FND_DF_COL_USGS_EXT ATTR,
                               FND_DESCR_FLEX_COLUMN_USAGES FL_COL,
                               MTL_SYSTEM_ITEMS_INTERFACE MSII
                             WHERE INTF.DATA_SET_ID                      = p_data_set_id
                               AND INTF.PROCESS_STATUS                   = G_PS_IN_PROCESS
                               AND INTF.ATTR_GROUP_TYPE                  = ATTR.DESCRIPTIVE_FLEXFIELD_NAME
                               AND INTF.ATTR_GROUP_INT_NAME              = ATTR.DESCRIPTIVE_FLEX_CONTEXT_CODE
                               AND ATTR.APPLICATION_ID                   = 431
                               AND ATTR.APPLICATION_ID                   = FL_COL.APPLICATION_ID
                               AND ATTR.DESCRIPTIVE_FLEXFIELD_NAME       = FL_COL.DESCRIPTIVE_FLEXFIELD_NAME
                               AND ATTR.DESCRIPTIVE_FLEX_CONTEXT_CODE    = FL_COL.DESCRIPTIVE_FLEX_CONTEXT_CODE
                               AND ATTR.APPLICATION_COLUMN_NAME          = FL_COL.APPLICATION_COLUMN_NAME
                               AND AG_EXT.APPLICATION_ID                 = ATTR.APPLICATION_ID
                               AND AG_EXT.DESCRIPTIVE_FLEXFIELD_NAME     = ATTR.DESCRIPTIVE_FLEXFIELD_NAME
                               AND AG_EXT.DESCRIPTIVE_FLEX_CONTEXT_CODE  = ATTR.DESCRIPTIVE_FLEX_CONTEXT_CODE
                               AND Nvl(AG_EXT.VARIANT, 'N')              = 'Y'
                               AND INTF.ATTR_INT_NAME                    = FL_COL.END_USER_COLUMN_NAME
                               AND SVA.ATTRIBUTE_ID                      = ATTR.ATTR_ID
                               AND SVA.INVENTORY_ITEM_ID                 = MSII.STYLE_ITEM_ID
                               AND SVA.VALUE_SET_ID                      <> FL_COL.FLEX_VALUE_SET_ID
                               AND INTF.INVENTORY_ITEM_ID                = MSII.INVENTORY_ITEM_ID
                               AND INTF.ORGANIZATION_ID                  = MSII.ORGANIZATION_ID
                               AND (CASE WHEN ATTR.DATA_TYPE IN ('A', 'C') THEN INTF.ATTR_VALUE_STR
                                         WHEN ATTR.DATA_TYPE = 'N'         THEN TO_CHAR(INTF.ATTR_VALUE_NUM)
                                         WHEN ATTR.DATA_TYPE IN ('X', 'Y') THEN TO_CHAR(INTF.ATTR_VALUE_DATE)
                                         ELSE NULL
                                    END) NOT IN ( SELECT val.FLEX_VALUE
                                                  FROM
                                                    FND_FLEX_VALUES_VL val,
                                                    EGO_VS_VALUES_DISP_ORDER disp_order,
                                                    EGO_VALUE_SET_EXT ext
                                                  WHERE val.FLEX_VALUE_ID                   = disp_order.VALUE_SET_VALUE_ID
                                                    AND disp_order.VALUE_SET_ID             = SVA.VALUE_SET_ID
                                                    AND val.FLEX_VALUE_SET_ID               = ext.PARENT_VALUE_SET_ID
                                                    AND ext.VALUE_SET_ID                    = disp_order.VALUE_SET_ID
                                                    AND Nvl(val.ENABLED_FLAG,'Y')           = 'Y'
                                                    AND Nvl(val.START_DATE_ACTIVE, SYSDATE) <= SYSDATE
                                                    AND Nvl(val.END_DATE_ACTIVE, SYSDATE)   >= SYSDATE
                                                )
                            );




    ---------------------------------------------------------------------------------
    -- Adding validation errors for Style/SKU related validations                  --
    ---------------------------------------------------------------------------------
    FOR i IN (SELECT /*+ INDEX(EGO_ITM_USR_ATTR_INTRFC, EGO_ITM_USR_ATTR_INTRFC_N3) */    /* Bug 9678667 */
                PROCESS_STATUS, TRANSACTION_ID, ATTR_VALUE_STR, ATTR_VALUE_NUM, ATTR_VALUE_DATE, ATTR_DISP_VALUE, ITEM_NUMBER
              FROM EGO_ITM_USR_ATTR_INTRFC
              WHERE DATA_SET_ID = p_data_set_id
                AND PROCESS_STATUS = G_PS_BAD_SKU_VAR_VALUE
             )
    LOOP
      RETCODE := L_CONC_RET_STS_WARNING;
      IF (i.PROCESS_STATUS = G_PS_BAD_SKU_VAR_VALUE ) THEN
        l_token_table(1).TOKEN_NAME := 'ITEM_NUMBER';
        l_token_table(1).TOKEN_VALUE := i.ITEM_NUMBER;

        l_token_table(2).TOKEN_NAME := 'VALUE';
        l_token_table(2).TOKEN_VALUE := COALESCE(i.ATTR_VALUE_STR, TO_CHAR(i.ATTR_VALUE_NUM), TO_CHAR(i.ATTR_VALUE_DATE));

        l_error_message_name := 'EGO_BAD_VAR_VALUE';
      END IF;

      ERROR_HANDLER.Add_Error_Message(
        p_message_name                  => l_error_message_name
       ,p_application_id                => 'EGO'
       ,p_token_tbl                     => l_token_table
       ,p_message_type                  => FND_API.G_RET_STS_ERROR
       ,p_row_identifier                => i.TRANSACTION_ID
       ,p_entity_id                     => G_ENTITY_ID
       ,p_entity_code                   => G_ENTITY_CODE
       ,p_table_name                    => G_TABLE_NAME
      );
      l_token_table.DELETE();
    END LOOP;


    ---------------------------------------------------
    -- Marking all these rows to process_status = 3  --
    ---------------------------------------------------
    UPDATE EGO_ITM_USR_ATTR_INTRFC
    SET PROCESS_STATUS = G_PS_GENERIC_ERROR
    WHERE DATA_SET_ID = p_data_set_id
      AND PROCESS_STATUS = G_PS_BAD_SKU_VAR_VALUE;



    ----------------------------------------------------
    -- Processing data for GDSN Attribute group types --
    ----------------------------------------------------

    /* Fix for bug#9660659 - Start*/
    SELECT Count(1)
      INTO l_item_gtin_count
    FROM  EGO_ITM_USR_ATTR_INTRFC
    WHERE data_set_id = p_data_set_id
      AND attr_group_type = 'EGO_ITEM_GTIN_ATTRS'
      AND ROWNUM = 1;

    IF(l_item_gtin_count = 1) THEN
    /* Fix for bug#9660659 - End */

      EGO_USER_ATTRS_BULK_PVT.Bulk_Load_User_Attrs_Data (
          p_api_version                   =>  G_API_VERSION                    --IN   NUMBER
        ,p_application_id                =>  431                              --IN   NUMBER
        ,p_attr_group_type               =>  'EGO_ITEM_GTIN_ATTRS'                --IN   VARCHAR2
        ,p_object_name                   =>  G_ITEM_NAME                      --IN   VARCHAR2
        ,p_hz_party_id                   =>  G_HZ_PARTY_ID                    --IN   VARCHAR2
        ,p_interface_table_name          =>  'EGO_ITM_USR_ATTR_INTRFC'        --IN   VARCHAR2
        ,p_data_set_id                   =>  p_data_set_id                    --IN   NUMBER
        ,p_entity_id                     =>  G_ENTITY_ID                      --IN   NUMBER
        ,p_entity_index                  =>  l_entity_index_counter           --IN   NUMBER
        ,p_entity_code                   =>  G_ENTITY_CODE                    --IN   VARCHAR2
        ,p_debug_level                   =>  p_debug_level                    --IN   NUMBER
        ,p_init_error_handler            =>  FND_API.G_FALSE                  --IN   VARCHAR2
        ,p_init_fnd_msg_list             =>  FND_API.G_FALSE                  --IN   VARCHAR2
        ,p_log_errors                    =>  FND_API.G_TRUE                   --IN   VARCHAR2
        ,p_add_errors_to_fnd_stack       =>  FND_API.G_TRUE                   --IN   VARCHAR2
        ,p_commit                        =>  p_commit -- bug 10060587 FND_API.G_TRUE                   --IN   VARCHAR2
        ,p_default_view_privilege        =>  'EGO_VIEW_ITEM'                  --IN   VARCHAR2
        ,p_default_edit_privilege        =>  'EGO_EDIT_ITEM'                  --IN   VARCHAR2
        ,p_privilege_predicate_api_name  =>  l_privilege_predicate_api_name   --IN   VARCHAR2
        ,p_related_class_codes_query     =>  l_related_class_codes_query      --IN   VARCHAR2
        ,p_validate                      =>  TRUE
        ,p_do_dml                        =>  FALSE
        ,p_do_req_def_valiadtion         =>  FALSE --we will do this validation after the template is applied
        ,x_return_status                 =>  l_user_attrs_return_status       --OUT NOCOPY VARCHAR2
        ,x_errorcode                     =>  l_errorcode                      --OUT NOCOPY NUMBER
        ,x_msg_count                     =>  l_msg_count                      --OUT NOCOPY NUMBER
        ,x_msg_data                      =>  l_msg_data                       --OUT NOCOPY VARCHAR2
      );

      IF (l_user_attrs_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        ERRBUF    :=  l_msg_data;
        RETCODE   :=  FND_API.G_RET_STS_UNEXP_ERROR;
        RAISE G_UNHANDLED_EXCEPTION;
      ELSIF l_user_attrs_return_status = G_FND_RET_STS_WARNING THEN
        RETCODE := L_CONC_RET_STS_WARNING;
      END IF;
    END IF; -- end of IF (l_item_gtin_count = 1)   /* Fix for bug#9660659 */


    /* Fix for bug#9660659 - Start*/
    SELECT Count(1)
      INTO l_item_gtin_multi_count
    FROM  EGO_ITM_USR_ATTR_INTRFC
    WHERE data_set_id = p_data_set_id
      AND attr_group_type = 'EGO_ITEM_GTIN_MULTI_ATTRS'
      AND ROWNUM = 1;

    IF(l_item_gtin_multi_count = 1) THEN
    /* Fix for bug#9660659 - End */

      EGO_USER_ATTRS_BULK_PVT.Bulk_Load_User_Attrs_Data (
          p_api_version                   =>  G_API_VERSION                    --IN   NUMBER
        ,p_application_id                =>  431                              --IN   NUMBER
        ,p_attr_group_type               =>  'EGO_ITEM_GTIN_MULTI_ATTRS'      --IN   VARCHAR2
        ,p_object_name                   =>  G_ITEM_NAME                      --IN   VARCHAR2
        ,p_hz_party_id                   =>  G_HZ_PARTY_ID                    --IN   VARCHAR2
        ,p_interface_table_name          =>  'EGO_ITM_USR_ATTR_INTRFC'        --IN   VARCHAR2
        ,p_data_set_id                   =>  p_data_set_id                    --IN   NUMBER
        ,p_entity_id                     =>  G_ENTITY_ID                      --IN   NUMBER
        ,p_entity_index                  =>  l_entity_index_counter           --IN   NUMBER
        ,p_entity_code                   =>  G_ENTITY_CODE                    --IN   VARCHAR2
        ,p_debug_level                   =>  p_debug_level                    --IN   NUMBER
        ,p_init_error_handler            =>  FND_API.G_FALSE                  --IN   VARCHAR2
        ,p_init_fnd_msg_list             =>  FND_API.G_FALSE                  --IN   VARCHAR2
        ,p_log_errors                    =>  FND_API.G_TRUE                   --IN   VARCHAR2
        ,p_add_errors_to_fnd_stack       =>  FND_API.G_TRUE                   --IN   VARCHAR2
        ,p_commit                        =>  p_commit -- bug 10060587 FND_API.G_TRUE                   --IN   VARCHAR2
        ,p_default_view_privilege        =>  'EGO_VIEW_ITEM'                  --IN   VARCHAR2
        ,p_default_edit_privilege        =>  'EGO_EDIT_ITEM'                  --IN   VARCHAR2
        ,p_privilege_predicate_api_name  =>  l_privilege_predicate_api_name   --IN   VARCHAR2
        ,p_related_class_codes_query     =>  l_related_class_codes_query      --IN   VARCHAR2
        ,p_validate                      =>  TRUE
        ,p_do_dml                        =>  FALSE
        ,p_do_req_def_valiadtion         =>  FALSE --we will do this validation after the template is applied
        ,x_return_status                 =>  l_user_attrs_return_status       --OUT NOCOPY VARCHAR2
        ,x_errorcode                     =>  l_errorcode                      --OUT NOCOPY NUMBER
        ,x_msg_count                     =>  l_msg_count                      --OUT NOCOPY NUMBER
        ,x_msg_data                      =>  l_msg_data                       --OUT NOCOPY VARCHAR2
      );

      IF (l_user_attrs_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        ERRBUF    :=  l_msg_data;
        RETCODE   :=  FND_API.G_RET_STS_UNEXP_ERROR;
        RAISE G_UNHANDLED_EXCEPTION;
      ELSIF l_user_attrs_return_status = G_FND_RET_STS_WARNING THEN
        RETCODE := L_CONC_RET_STS_WARNING;
      END IF;
    END IF; -- end of IF (l_item_gtin_multi_count = 1)   /* Fix for bug#9660659 */


    IF p_validate_only = FND_API.G_FALSE THEN
      ---------------------------------------------------------------------
      -- Calling the API to Mark all such rows which have the same data  --
      -- as we have for the attribute in the production tables.          --
      ---------------------------------------------------------------------

      EGO_USER_ATTRS_DATA_PVT.Debug_Msg('Calling EGO_USER_ATTRS_BULK_PVT.Mark_Unchanged_Attr_Rows for EGO_ITEMMGMT_GROUP ', 1);
      EGO_USER_ATTRS_BULK_PVT.Mark_Unchanged_Attr_Rows (
                                        p_api_version                   =>1.0
                                       ,p_application_id                =>431
                                       ,p_attr_group_type               =>'EGO_ITEMMGMT_GROUP'
                                       ,p_object_name                   =>'EGO_ITEM'
                                       ,p_interface_table_name          =>'EGO_ITM_USR_ATTR_INTRFC'
                                       ,p_data_set_id                   =>p_data_set_id
                                       ,p_new_status                    =>4
                                       ,x_return_status                 =>l_return_status
                                       ,x_msg_data                      =>l_msg_data
                                     );
      EGO_USER_ATTRS_DATA_PVT.Debug_Msg('  ... Completed EGO_USER_ATTRS_BULK_PVT.Mark_Unchanged_Attr_Rows Return Status-'||l_return_status||' '||l_msg_data, 1);

      IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
         ERRBUF    :=  l_msg_data;
         RETCODE   :=  FND_API.G_RET_STS_UNEXP_ERROR;
         ERROR_HANDLER.Add_Error_Message(
           p_message_text                  => l_msg_data
          ,p_application_id                => 'EGO'
          ,p_message_type                  => FND_API.G_RET_STS_ERROR
          ,p_row_identifier                => l_err_reporting_transaction_id
          ,p_entity_id                     => G_ENTITY_ID
          ,p_entity_code                   => G_ENTITY_CODE
          ,p_table_name                    => G_TABLE_NAME
         );
         RAISE G_UNHANDLED_EXCEPTION;
      ELSIF l_return_status = G_FND_RET_STS_WARNING THEN
        RETCODE := L_CONC_RET_STS_WARNING;
      END IF;




      EGO_USER_ATTRS_DATA_PVT.Debug_Msg('Calling EGO_USER_ATTRS_BULK_PVT.Mark_Unchanged_Attr_Rows for EGO_ITEM_GTIN_ATTRS ', 1);
      EGO_USER_ATTRS_BULK_PVT.Mark_Unchanged_Attr_Rows (
                                        p_api_version                   =>1.0
                                       ,p_application_id                =>431
                                       ,p_attr_group_type               =>'EGO_ITEM_GTIN_ATTRS'
                                       ,p_object_name                   =>'EGO_ITEM'
                                       ,p_interface_table_name          =>'EGO_ITM_USR_ATTR_INTRFC'
                                       ,p_data_set_id                   =>p_data_set_id
                                       ,p_new_status                    =>4
                                       ,x_return_status                 =>l_return_status
                                       ,x_msg_data                      =>l_msg_data
                                     );
      EGO_USER_ATTRS_DATA_PVT.Debug_Msg('  ... Completed EGO_USER_ATTRS_BULK_PVT.Mark_Unchanged_Attr_Rows Return Status-'||l_return_status||' '||l_msg_data, 1);

      IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
         ERRBUF    :=  l_msg_data;
         RETCODE   :=  FND_API.G_RET_STS_UNEXP_ERROR;
         ERROR_HANDLER.Add_Error_Message(
           p_message_text                  => l_msg_data
          ,p_application_id                => 'EGO'
          ,p_message_type                  => FND_API.G_RET_STS_ERROR
          ,p_row_identifier                => l_err_reporting_transaction_id
          ,p_entity_id                     => G_ENTITY_ID
          ,p_entity_code                   => G_ENTITY_CODE
          ,p_table_name                    => G_TABLE_NAME
         );
         RAISE G_UNHANDLED_EXCEPTION;
      ELSIF l_return_status = G_FND_RET_STS_WARNING THEN
        RETCODE := L_CONC_RET_STS_WARNING;
      END IF;

      EGO_USER_ATTRS_DATA_PVT.Debug_Msg('Calling EGO_USER_ATTRS_BULK_PVT.Mark_Unchanged_Attr_Rows for EGO_ITEM_GTIN_MULTI_ATTRS ', 1);
      EGO_USER_ATTRS_BULK_PVT.Mark_Unchanged_Attr_Rows (
                                        p_api_version                   =>1.0
                                       ,p_application_id                =>431
                                       ,p_attr_group_type               =>'EGO_ITEM_GTIN_MULTI_ATTRS'
                                       ,p_object_name                   =>'EGO_ITEM'
                                       ,p_interface_table_name          =>'EGO_ITM_USR_ATTR_INTRFC'
                                       ,p_data_set_id                   =>p_data_set_id
                                       ,p_new_status                    =>4
                                       ,x_return_status                 =>l_return_status
                                       ,x_msg_data                      =>l_msg_data
                                     );
      EGO_USER_ATTRS_DATA_PVT.Debug_Msg('  ... Completed EGO_USER_ATTRS_BULK_PVT.Mark_Unchanged_Attr_Rows Return Status-'||l_return_status||' '||l_msg_data, 1);

      IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
         ERRBUF    :=  l_msg_data;
         RETCODE   :=  FND_API.G_RET_STS_UNEXP_ERROR;
         ERROR_HANDLER.Add_Error_Message(
           p_message_text                  => l_msg_data
          ,p_application_id                => 'EGO'
          ,p_message_type                  => FND_API.G_RET_STS_ERROR
          ,p_row_identifier                => l_err_reporting_transaction_id
          ,p_entity_id                     => G_ENTITY_ID
          ,p_entity_code                   => G_ENTITY_CODE
          ,p_table_name                    => G_TABLE_NAME
         );
         RAISE G_UNHANDLED_EXCEPTION;
      ELSIF l_return_status = G_FND_RET_STS_WARNING THEN
        RETCODE := L_CONC_RET_STS_WARNING;
      END IF;
    END IF; --IF p_validate_only = FND_API.G_FALSE THEN

    ---------------------------------------------------------------------------------------
    -- Mark all rows to satus 5 that share the same logical Attribute Group row          --
    -- with any rows for which the Change Policy is defined as CHANGE_ORDER_REQUIRED     --
    -- (we do not process such rows; they must be bulkloaded through Change Management); --
    -- the exception to this is rows for pending Items, which we still processed         --
    -- The user attrs API would not do the DML for these                                 --
    ---------------------------------------------------------------------------------------
    IF (p_debug_level > 0) THEN
      EGO_USER_ATTRS_DATA_PVT.Debug_Msg('Starting Change Policy conversion/erroring', 0);
    END IF;

    BEGIN
      --------------------------------------------------------------------------------------
      -- Bug#4679902 (If the user wants to have Change Order, Change ALLOWED attributes
      -- will also be forced to undergo Change Order)
      --------------------------------------------------------------------------------------
      l_add_all_to_cm := EGO_IMPORT_PVT.getAddAllToChangeFlag(p_batch_id => p_data_set_id);
      EGO_USER_ATTRS_DATA_PVT.Debug_Msg(' Add all to Change flag is '||l_add_all_to_cm, 0);
      IF( l_add_all_to_cm = 'Y' ) THEN
          /*UPDATE EGO_ITM_USR_ATTR_INTRFC UAI
          SET   UAI.PROCESS_STATUS = G_PS_CHG_POLICY_CO_REQUIRED
          WHERE UAI.DATA_SET_ID = p_data_set_id
          AND   UAI.PROCESS_STATUS = G_PS_IN_PROCESS
          AND   UAI.PROG_INT_CHAR2 = 'N' OR UAI.DATA_LEVEL_ID = 43106;--BugFix:6315828(for revisions even in case revision is created in the batch
                                                                      --the attrs should go through the CO int his case.*/
        -- Bug 9705689 adding condition to the filter for revision level updated item
          UPDATE EGO_ITM_USR_ATTR_INTRFC UAI
          SET   UAI.PROCESS_STATUS = G_PS_CHG_POLICY_CO_REQUIRED
          WHERE UAI.DATA_SET_ID = p_data_set_id
          AND   UAI.PROCESS_STATUS = G_PS_IN_PROCESS
          AND   UAI.PROG_INT_CHAR2 = 'N';

          UPDATE EGO_ITM_USR_ATTR_INTRFC UAI
          SET   UAI.PROCESS_STATUS = G_PS_CHG_POLICY_CO_REQUIRED
          WHERE UAI.DATA_LEVEL_ID = 43106
          AND   UAI.DATA_SET_ID = p_data_set_id
          AND   UAI.PROCESS_STATUS = G_PS_IN_PROCESS
          AND   EXISTS
                (
                 SELECT 1
                 FROM MTL_SYSTEM_ITEMS_INTERFACE MSII
                 WHERE MSII.INVENTORY_ITEM_ID = UAI.INVENTORY_ITEM_ID
                 AND MSII.ORGANIZATION_ID   = UAI.ORGANIZATION_ID
                 AND MSII.SET_PROCESS_ID    = UAI.DATA_SET_ID
                 AND MSII.PROCESS_FLAG      IN (1, 7)
                 AND MSII.TRANSACTION_TYPE  = 'UPDATE'
                );

          UPDATE EGO_ITM_USR_ATTR_INTRFC UAI
          SET   UAI.TRANSACTION_TYPE = 'CREATE'
          WHERE UAI.DATA_LEVEL_ID = 43106
          AND   UAI.DATA_SET_ID = p_data_set_id
          AND   UAI.PROCESS_STATUS = G_PS_IN_PROCESS
          AND   UAI.TRANSACTION_TYPE='SYNC'
          AND   EXISTS
                (
                 SELECT 1
                 FROM MTL_SYSTEM_ITEMS_INTERFACE MSII
                 WHERE MSII.INVENTORY_ITEM_ID = UAI.INVENTORY_ITEM_ID
                 AND MSII.ORGANIZATION_ID   = UAI.ORGANIZATION_ID
                 AND MSII.SET_PROCESS_ID    = UAI.DATA_SET_ID
                 AND MSII.PROCESS_FLAG      = 1
                 AND MSII.TRANSACTION_TYPE  = 'CREATE'
                );
        -- end of bug 9705689 code changes

      ELSE
        l_policy_check_name := 'CHANGE_ORDER_REQUIRED';
        EXECUTE IMMEDIATE l_policy_check_sql USING G_PS_CHG_POLICY_CO_REQUIRED,
                                                  p_data_set_id,
                                                  G_PS_IN_PROCESS,
                                                  p_data_set_id,
                                                  G_PS_IN_PROCESS,
                                                  l_policy_check_name;
      END IF;
--    write_records(p_data_set_id => p_data_set_id,  p_module => l_api_name, p_message => 'After CO REQD policy');

      EXCEPTION
         WHEN OTHERS THEN
           NULL;
    END;
/*  Dont need this right now.
    --------------------------------------------------------------
    -- Loop through all the distinct catalog group id's in the  --
    -- current data set and mark the rows for catalog's which   --
    -- have a NIR required and leave them in status 5 for CM    --
    --------------------------------------------------------------
    FOR catalog_groups IN distinct_catalaog_groups(p_data_set_id)
    LOOP
      IF (INVIDIT3.CHECK_NPR_CATALOG(catalog_groups.ITEM_CATALOG_GROUP_ID)) THEN
        UPDATE EGO_ITM_USR_ATTR_INTRFC UAI
           SET UAI.PROCESS_STATUS = G_PS_CHG_POLICY_CO_REQUIRED
         WHERE UAI.DATA_SET_ID = p_data_set_id
           AND UAI.PROCESS_STATUS = G_PS_IN_PROCESS
           AND UAI.ITEM_CATALOG_GROUP_ID = catalog_groups.ITEM_CATALOG_GROUP_ID;
      END IF;
    END LOOP;
*/

    ------------------------------------------------------------


    EGO_USER_ATTRS_DATA_PVT.Debug_Msg('Before calling the GTIN validation API', 0);

    EGO_GTIN_ATTRS_PVT.VALIDATE_INTF_ROWS(
        p_data_set_id                   => p_data_set_id
       ,p_entity_id                     => G_ENTITY_ID
       ,p_entity_code                   => G_ENTITY_CODE
       ,p_add_errors_to_fnd_stack       => FND_API.G_TRUE
       ,x_return_status                 => l_gtinval_ret_code
    );
    IF (l_gtinval_ret_code = 'U') THEN
        RETCODE   :=  L_CONC_RET_STS_ERROR;
    ELSIF (l_gtinval_ret_code = 'E') THEN
        RETCODE   :=  L_CONC_RET_STS_WARNING;
    END IF;

    EGO_USER_ATTRS_DATA_PVT.Debug_Msg('After calling the GTIN validation API', 0);

    ------------------------------------------------
    -- Here we call the API in DML only mode for  --
    -- all the attr group types                   --
    ------------------------------------------------
    IF p_validate_only = FND_API.G_FALSE THEN
      IF(l_item_mgmt_count = 1) THEN       /* Fix for bug#9660659 */
        EGO_USER_ATTRS_BULK_PVT.Bulk_Load_User_Attrs_Data (
            p_api_version                   =>  G_API_VERSION                    --IN   NUMBER
          ,p_application_id                =>  431                              --IN   NUMBER
          ,p_attr_group_type               =>  'EGO_ITEMMGMT_GROUP'             --IN   VARCHAR2
          ,p_object_name                   =>  G_ITEM_NAME                      --IN   VARCHAR2
          ,p_hz_party_id                   =>  G_HZ_PARTY_ID                    --IN   VARCHAR2
          ,p_interface_table_name          =>  'EGO_ITM_USR_ATTR_INTRFC'        --IN   VARCHAR2
          ,p_data_set_id                   =>  p_data_set_id                    --IN   NUMBER
          ,p_entity_id                     =>  G_ENTITY_ID                      --IN   NUMBER
          ,p_entity_index                  =>  l_entity_index_counter           --IN   NUMBER
          ,p_entity_code                   =>  G_ENTITY_CODE                    --IN   VARCHAR2
          ,p_debug_level                   =>  p_debug_level                    --IN   NUMBER
          ,p_init_error_handler            =>  FND_API.G_FALSE                  --IN   VARCHAR2
          ,p_init_fnd_msg_list             =>  FND_API.G_FALSE                  --IN   VARCHAR2
          ,p_log_errors                    =>  FND_API.G_TRUE                   --IN   VARCHAR2
          ,p_add_errors_to_fnd_stack       =>  FND_API.G_TRUE                   --IN   VARCHAR2
          ,p_commit                        =>  p_commit -- bug 10060587 FND_API.G_TRUE                   --IN   VARCHAR2
          ,p_default_dl_view_priv_list     =>  l_default_dl_view_priv_list
          ,p_default_dl_edit_priv_list     =>  l_default_dl_edit_priv_list
          ,p_privilege_predicate_api_name  =>  'EGO_ITEM_USER_ATTRS_CP_PUB.Get_Item_Security_Predicate'   --IN   VARCHAR2
          ,p_related_class_codes_query     =>  l_related_class_codes_query      --IN   VARCHAR2
          ,p_validate                      =>  FALSE
          ,p_do_dml                        =>  TRUE
          ,p_do_req_def_valiadtion         =>  FALSE -- Fix for bug#9336604 TRUE --Doing this validation here since the value may have come from template
          ,x_return_status                 =>  l_user_attrs_return_status       --OUT NOCOPY VARCHAR2
          ,x_errorcode                     =>  l_errorcode                      --OUT NOCOPY NUMBER
          ,x_msg_count                     =>  l_msg_count                      --OUT NOCOPY NUMBER
          ,x_msg_data                      =>  l_msg_data                       --OUT NOCOPY VARCHAR2
        );
        IF (l_user_attrs_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
          ERRBUF    :=  l_msg_data;
          RETCODE   :=  FND_API.G_RET_STS_UNEXP_ERROR;
          RAISE G_UNHANDLED_EXCEPTION;
        ELSIF l_user_attrs_return_status = G_FND_RET_STS_WARNING THEN
          RETCODE := L_CONC_RET_STS_WARNING;
        END IF;
      END IF; -- end of IF (l_item_mgmt_count = 1)   /* Fix for bug#9660659 */

      IF(l_item_gtin_count = 1) THEN       /* Fix for bug#9660659 */
        EGO_USER_ATTRS_BULK_PVT.Bulk_Load_User_Attrs_Data (
            p_api_version                   =>  G_API_VERSION                    --IN   NUMBER
          ,p_application_id                =>  431                              --IN   NUMBER
          ,p_attr_group_type               =>  'EGO_ITEM_GTIN_ATTRS'            --IN   VARCHAR2
          ,p_object_name                   =>  G_ITEM_NAME                      --IN   VARCHAR2
          ,p_hz_party_id                   =>  G_HZ_PARTY_ID                    --IN   VARCHAR2
          ,p_interface_table_name          =>  'EGO_ITM_USR_ATTR_INTRFC'        --IN   VARCHAR2
          ,p_data_set_id                   =>  p_data_set_id                    --IN   NUMBER
          ,p_entity_id                     =>  G_ENTITY_ID                      --IN   NUMBER
          ,p_entity_index                  =>  l_entity_index_counter           --IN   NUMBER
          ,p_entity_code                   =>  G_ENTITY_CODE                    --IN   VARCHAR2
          ,p_debug_level                   =>  p_debug_level                    --IN   NUMBER
          ,p_init_error_handler            =>  FND_API.G_FALSE                  --IN   VARCHAR2
          ,p_init_fnd_msg_list             =>  FND_API.G_FALSE                  --IN   VARCHAR2
          ,p_log_errors                    =>  FND_API.G_TRUE                   --IN   VARCHAR2
          ,p_add_errors_to_fnd_stack       =>  FND_API.G_TRUE                   --IN   VARCHAR2
          ,p_commit                        =>  p_commit -- bug 10060587 FND_API.G_TRUE                   --IN   VARCHAR2
          ,p_default_view_privilege        =>  'EGO_VIEW_ITEM'                  --IN   VARCHAR2
          ,p_default_edit_privilege        =>  'EGO_EDIT_ITEM'                  --IN   VARCHAR2
          ,p_privilege_predicate_api_name  =>  'EGO_ITEM_USER_ATTRS_CP_PUB.Get_Item_Security_Predicate'   --IN   VARCHAR2
          ,p_related_class_codes_query     =>  l_related_class_codes_query      --IN   VARCHAR2
          ,p_validate                      =>  FALSE
          ,p_do_dml                        =>  TRUE
          ,p_do_req_def_valiadtion         =>  TRUE --Doing this validation here since the value may have come from template
          ,x_return_status                 =>  l_user_attrs_return_status       --OUT NOCOPY VARCHAR2
          ,x_errorcode                     =>  l_errorcode                      --OUT NOCOPY NUMBER
          ,x_msg_count                     =>  l_msg_count                      --OUT NOCOPY NUMBER
          ,x_msg_data                      =>  l_msg_data                       --OUT NOCOPY VARCHAR2
        );

        IF (l_user_attrs_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
          ERRBUF    :=  l_msg_data;
          RETCODE   :=  FND_API.G_RET_STS_UNEXP_ERROR;
          RAISE G_UNHANDLED_EXCEPTION;
        ELSIF l_user_attrs_return_status = G_FND_RET_STS_WARNING THEN
          RETCODE := L_CONC_RET_STS_WARNING;
        END IF;
      END IF; -- end of IF (l_item_gtin_count = 1)   /* Fix for bug#9660659 */

      IF(l_item_gtin_multi_count = 1) THEN       /* Fix for bug#9660659 */
        EGO_USER_ATTRS_BULK_PVT.Bulk_Load_User_Attrs_Data (
            p_api_version                   =>  G_API_VERSION                    --IN   NUMBER
          ,p_application_id                =>  431                              --IN   NUMBER
          ,p_attr_group_type               =>  'EGO_ITEM_GTIN_MULTI_ATTRS'      --IN   VARCHAR2
          ,p_object_name                   =>  G_ITEM_NAME                      --IN   VARCHAR2
          ,p_hz_party_id                   =>  G_HZ_PARTY_ID                    --IN   VARCHAR2
          ,p_interface_table_name          =>  'EGO_ITM_USR_ATTR_INTRFC'        --IN   VARCHAR2
          ,p_data_set_id                   =>  p_data_set_id                    --IN   NUMBER
          ,p_entity_id                     =>  G_ENTITY_ID                      --IN   NUMBER
          ,p_entity_index                  =>  l_entity_index_counter           --IN   NUMBER
          ,p_entity_code                   =>  G_ENTITY_CODE                    --IN   VARCHAR2
          ,p_debug_level                   =>  p_debug_level                    --IN   NUMBER
          ,p_init_error_handler            =>  FND_API.G_FALSE                  --IN   VARCHAR2
          ,p_init_fnd_msg_list             =>  FND_API.G_FALSE                  --IN   VARCHAR2
          ,p_log_errors                    =>  FND_API.G_TRUE                   --IN   VARCHAR2
          ,p_add_errors_to_fnd_stack       =>  FND_API.G_TRUE                   --IN   VARCHAR2
          ,p_commit                        =>  p_commit -- bug 10060587 FND_API.G_TRUE                   --IN   VARCHAR2
          ,p_default_view_privilege        =>  'EGO_VIEW_ITEM'                  --IN   VARCHAR2
          ,p_default_edit_privilege        =>  'EGO_EDIT_ITEM'                  --IN   VARCHAR2
          ,p_privilege_predicate_api_name  =>  'EGO_ITEM_USER_ATTRS_CP_PUB.Get_Item_Security_Predicate'   --IN   VARCHAR2
          ,p_related_class_codes_query     =>  l_related_class_codes_query      --IN   VARCHAR2
          ,p_validate                      =>  FALSE
          ,p_do_dml                        =>  TRUE
          ,p_do_req_def_valiadtion         =>  TRUE --Doing this validation here since the value may have come from template
          ,x_return_status                 =>  l_user_attrs_return_status       --OUT NOCOPY VARCHAR2
          ,x_errorcode                     =>  l_errorcode                      --OUT NOCOPY NUMBER
          ,x_msg_count                     =>  l_msg_count                      --OUT NOCOPY NUMBER
          ,x_msg_data                      =>  l_msg_data                       --OUT NOCOPY VARCHAR2
        );

        IF (l_user_attrs_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
          ERRBUF    :=  l_msg_data;
          RETCODE   :=  FND_API.G_RET_STS_UNEXP_ERROR;
          RAISE G_UNHANDLED_EXCEPTION;
        ELSIF l_user_attrs_return_status = G_FND_RET_STS_WARNING THEN
          RETCODE := L_CONC_RET_STS_WARNING;
        END IF;
      END IF; -- end of IF (l_item_gtin_multi_count = 1)   /* Fix for bug#9660659 */

      EGO_USER_ATTRS_DATA_PVT.Debug_Msg('Completing User Attributes Bulk Load return status is ' || l_user_attrs_return_status, 1);

      --------------------------------------------------------
      -- This takes care of rolling up of GDSN attributes  --
      -- and registration/publication status.              --
      --------------------------------------------------------

      EGO_USER_ATTRS_DATA_PVT.Debug_Msg('Starting EGO_GTIN_ATTRS_PVT.Do_Post_UCCnet_Attrs_Action', 1);

      EGO_GTIN_ATTRS_PVT.Do_Post_UCCnet_Attrs_Action ( p_data_set_id               => p_data_set_id
                                                      ,p_entity_id                 => G_ENTITY_ID
                                                      ,p_entity_code               => G_ENTITY_CODE
                                                      ,p_add_errors_to_fnd_stack   => FND_API.G_TRUE
                                                     );


      EGO_USER_ATTRS_DATA_PVT.Debug_Msg('Done EGO_GTIN_ATTRS_PVT.Do_Post_UCCnet_Attrs_Action', 1);


      IF (FND_API.To_Boolean(p_purge_successful_lines)) THEN
        -----------------------------------------------
        -- Delete all successful rows from the table --
        -- (they're the only rows still in process)  --
        -----------------------------------------------
        DELETE FROM EGO_ITM_USR_ATTR_INTRFC
         WHERE DATA_SET_ID = p_data_set_id
           AND PROCESS_STATUS = G_PS_IN_PROCESS;
      ELSE
        ----------------------------------------------
        -- Mark all rows we've processed as success --
        -- if they weren't marked as failure above  --
        ----------------------------------------------
        UPDATE EGO_ITM_USR_ATTR_INTRFC
           SET PROCESS_STATUS = G_PS_SUCCESS
         WHERE DATA_SET_ID = p_data_set_id
           AND PROCESS_STATUS = G_PS_IN_PROCESS;
      END IF;

      IF (p_debug_level > 0) THEN
        EGO_USER_ATTRS_DATA_PVT.Debug_Msg('Done with Item/Item Revision Concurrent Program', 0);
      END IF;
    END IF;  -- IF p_validate_only = FND_API.G...

    IF (FND_API.To_Boolean(p_initialize_error_handler)) THEN

      -------------------------------------------------------------------
      -- Finally, we log any errors that we've accumulated throughout  --
      -- our conversions and looping (including all errors encountered --
      -- within our Business Object's processing)                      --
      -------------------------------------------------------------------
      ERROR_HANDLER.Log_Error(
        p_write_err_to_inttable         => 'Y'
       ,p_write_err_to_conclog          => 'Y'
       ,p_write_err_to_debugfile        => ERROR_HANDLER.Get_Debug()
      );

      IF (ERROR_HANDLER.Get_Debug() = 'Y') THEN
        ERROR_HANDLER.Close_Debug_Session();
      END IF;
    END IF;
 IF FND_API.To_Boolean( p_commit ) THEN   /* Added to fix Bug#7422423*/
    COMMIT WORK;
 END IF;
  EXCEPTION
    WHEN G_NO_USER_NAME_TO_VALIDATE THEN

      ----------------------------------------
      -- Mark all rows in process as errors --
      ----------------------------------------
      UPDATE EGO_ITM_USR_ATTR_INTRFC
         SET PROCESS_STATUS = G_PS_GENERIC_ERROR
       WHERE DATA_SET_ID = p_data_set_id
         AND PROCESS_STATUS = G_PS_IN_PROCESS;

      ---------------------------------------------------------------------
      -- Use any random transaction ID in the data set to log this error --
      -- If no rows are found, please use -1 as transaction_id           --
      ---------------------------------------------------------------------
      IF SQL%ROWCOUNT > 0 THEN
        SELECT TRANSACTION_ID
          INTO l_err_reporting_transaction_id
          FROM EGO_ITM_USR_ATTR_INTRFC
         WHERE DATA_SET_ID = p_data_set_id
           AND ROWNUM = 1;
      ELSE
        l_err_reporting_transaction_id := -1;
      END IF;

      ERROR_HANDLER.Add_Error_Message(
        p_message_name                  => 'EGO_EF_NO_NAME_TO_VALIDATE'
       ,p_application_id                => 'EGO'
       ,p_message_type                  => FND_API.G_RET_STS_ERROR
       ,p_row_identifier                => l_err_reporting_transaction_id
       ,p_entity_id                     => G_ENTITY_ID
       ,p_entity_code                   => G_ENTITY_CODE
       ,p_table_name                  => G_TABLE_NAME
      );

      IF (FND_API.To_Boolean(p_initialize_error_handler)) THEN

        ---------------------------------------------------------------
        -- No matter what the error, we want to make sure everything --
        -- we've logged gets to the appropriate error locations      --
        ---------------------------------------------------------------
        ERROR_HANDLER.Log_Error(
          p_write_err_to_inttable         => 'Y'
         ,p_write_err_to_conclog          => 'Y'
         ,p_write_err_to_debugfile        => ERROR_HANDLER.Get_Debug()
        );

        IF (ERROR_HANDLER.Get_Debug() = 'Y') THEN
          ERROR_HANDLER.Close_Debug_Session();
        END IF;
      END IF;

      RETCODE := L_CONC_RET_STS_WARNING;

    WHEN OTHERS THEN

      ----------------------------------------
      -- Mark all rows in process as errors --
      ----------------------------------------
      UPDATE EGO_ITM_USR_ATTR_INTRFC
         SET PROCESS_STATUS = G_PS_GENERIC_ERROR
       WHERE DATA_SET_ID = p_data_set_id
         AND PROCESS_STATUS = G_PS_IN_PROCESS;

      ---------------------------------------------------------------------
      -- Use any random transaction ID in the data set to log this error --
      -- If no rows are found, please use -1 as transaction_id           --
      ---------------------------------------------------------------------
      IF SQL%ROWCOUNT > 0 THEN
        SELECT TRANSACTION_ID
          INTO l_err_reporting_transaction_id
          FROM EGO_ITM_USR_ATTR_INTRFC
         WHERE DATA_SET_ID = p_data_set_id
           AND ROWNUM = 1;
      ELSE
        l_err_reporting_transaction_id := -1;
      END IF;

      ERROR_HANDLER.Add_Error_Message(
        p_message_text                  => 'Unexpected error in '||G_PKG_NAME||'.Process_Item_User_Attrs_Data: '||SQLERRM
       ,p_application_id                => 'EGO'
       ,p_message_type                  => FND_API.G_RET_STS_ERROR
       ,p_row_identifier                => l_err_reporting_transaction_id
       ,p_entity_id                     => G_ENTITY_ID
       ,p_entity_code                   => G_ENTITY_CODE
       ,p_table_name                    => G_TABLE_NAME
      );

      IF (FND_API.To_Boolean(p_initialize_error_handler)) THEN

        ---------------------------------------------------------------
        -- No matter what the error, we want to make sure everything --
        -- we've logged gets to the appropriate error locations      --
        ---------------------------------------------------------------
        ERROR_HANDLER.Log_Error(
          p_write_err_to_inttable         => 'Y'
         ,p_write_err_to_conclog          => 'Y'
         ,p_write_err_to_debugfile        => ERROR_HANDLER.Get_Debug()
        );

        IF (ERROR_HANDLER.Get_Debug() = 'Y') THEN
          ERROR_HANDLER.Close_Debug_Session();
        END IF;
      END IF;

      RETCODE := L_CONC_RET_STS_ERROR;

END Process_Item_User_Attrs_Data;

----------------------------------------------------------------------

PROCEDURE Get_Related_Class_Codes (
        p_classification_code           IN   VARCHAR2
       ,x_related_class_codes_list      OUT NOCOPY VARCHAR2
) IS

BEGIN

  x_related_class_codes_list :=
    Build_Parent_Cat_Group_List(TO_NUMBER(p_classification_code), NULL);

END Get_Related_Class_Codes;

----------------------------------------------------------------------

PROCEDURE Impl_Item_Attr_Change_Line (
        p_api_version                   IN   NUMBER
       ,p_change_id                     IN   NUMBER
       ,p_change_line_id                IN   NUMBER
       ,p_old_revision_id               IN   NUMBER     DEFAULT NULL
       ,p_new_revision_id               IN   NUMBER     DEFAULT NULL
       ,p_init_msg_list                 IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,p_commit                        IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
) IS

    l_old_data_level_nv_pairs EGO_COL_NAME_VALUE_PAIR_ARRAY;
    l_new_data_level_nv_pairs EGO_COL_NAME_VALUE_PAIR_ARRAY;
    l_api_name     VARCHAR2(30);

BEGIN
  l_api_name := 'Impl_Item_Attr_Change_Line';
  SetGlobals();
  code_debug (p_log_level => G_DEBUG_LEVEL_PROCEDURE
             ,p_module    => l_api_name
             ,p_message   =>  'Started with 11 params '||
                 ' p_api_version: '|| to_char(p_api_version) ||
                 ' - p_change_id: '|| p_change_id ||
                 ' - p_change_line_id: '|| p_change_line_id ||
                 ' - p_old_revision_id: '|| p_old_revision_id ||
                 ' - p_new_revision_id: '|| p_new_revision_id ||
                 ' - p_init_msg_list: '|| p_init_msg_list ||
                 ' - p_commit: '|| p_commit
             );
  ---------------------------------------------------------------------
  -- Build data structures to pass in Data Level info, if applicable --
  ---------------------------------------------------------------------
  IF (p_old_revision_id IS NOT NULL) THEN
    l_old_data_level_nv_pairs := EGO_COL_NAME_VALUE_PAIR_ARRAY(
                                   EGO_COL_NAME_VALUE_PAIR_OBJ('REVISION_ID',
                                   p_old_revision_id)
                                 );
  END IF;
  IF (p_new_revision_id IS NOT NULL) THEN
    l_new_data_level_nv_pairs := EGO_COL_NAME_VALUE_PAIR_ARRAY(
                                   EGO_COL_NAME_VALUE_PAIR_OBJ('REVISION_ID',
                                   p_new_revision_id)
                                 );
  END IF;

  -------------------------------------------------------------------------
  -- Now we invoke the UserAttrs procedure, passing Item-specific params --
  -------------------------------------------------------------------------
  EGO_USER_ATTRS_DATA_PVT.Implement_Change_Line(
        p_api_version                   => 1.0
       ,p_object_name                   => G_ITEM_NAME
       ,p_production_b_table_name       => 'EGO_MTL_SY_ITEMS_EXT_B'
       ,p_production_tl_table_name      => 'EGO_MTL_SY_ITEMS_EXT_TL'
       ,p_change_b_table_name           => 'EGO_ITEMS_ATTRS_CHANGES_B'
       ,p_change_tl_table_name          => 'EGO_ITEMS_ATTRS_CHANGES_TL'
       ,p_tables_application_id         => 431
       ,p_change_line_id                => p_change_line_id
       ,p_old_data_level_nv_pairs       => l_old_data_level_nv_pairs
       ,p_new_data_level_nv_pairs       => l_new_data_level_nv_pairs
       ,p_related_class_code_function   => 'EGO_ITEM_USER_ATTRS_CP_PUB.Get_Related_Class_Codes'
       ,p_init_msg_list                 => p_init_msg_list
       ,p_commit                        => p_commit
       ,x_return_status                 => x_return_status
       ,x_errorcode                     => x_errorcode
       ,x_msg_count                     => x_msg_count
       ,x_msg_data                      => x_msg_data
  );
  code_debug (p_log_level => G_DEBUG_LEVEL_PROCEDURE
             ,p_module    => l_api_name
             ,p_message   =>  'Returning with params '||
                 ' x_return_status: '|| x_return_status ||
                 ' - x_errorcode: '|| x_errorcode ||
                 ' - x_msg_count: '|| x_msg_count ||
                 ' - x_msg_data: '|| x_msg_data
             );

END Impl_Item_Attr_Change_Line;

  ----------------------------------------------------------------------
  /*
   * Copy_data_to_Intf
   * --------------------------
   * A procedure for ITEMS use
   * which copies data from production/interface table to interface table
   * The inherited attribute groups are filtered at the source sql only.
   *
   */
  PROCEDURE Copy_data_to_Intf
      (
        p_api_version                   IN  NUMBER
       ,p_commit                        IN  VARCHAR2
       ,p_copy_from_intf_table          IN  VARCHAR2  -- T/F
       ,p_source_entity_sql             IN  VARCHAR2
       ,p_source_attr_groups_sql        IN  VARCHAR2
       ,p_dest_process_status           IN  VARCHAR2
       ,p_dest_data_set_id              IN  VARCHAR2
       ,p_dest_transaction_type         IN  VARCHAR2
       ,p_cleanup_row_identifiers       IN  VARCHAR2 DEFAULT FND_API.G_TRUE  -- T/F
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
      )
  IS
    TYPE DYNAMIC_CUR IS REF CURSOR;
    l_dynamic_cursor         DYNAMIC_CUR;
    l_prog_int_char1_value   VARCHAR2(100);
    l_prog_int_num4_value    NUMBER;
    l_attr_group_sql         VARCHAR2(32767);
    l_dynamic_sql            VARCHAR2(32767);
    l_dummy_char             VARCHAR2(32767);
    l_dest_transaction_type  VARCHAR2(50);
    l_multi_row              VARCHAR2(10);

    l_insert_cols            VARCHAR2(32767);
    l_select_sql             VARCHAR2(32767);
    l_where_clause           VARCHAR2(32767);
    l_when_matched           VARCHAR2(32767);
    l_when_not_matched       VARCHAR2(32767);

    l_attr_value_str_sql         VARCHAR2(32767);
    l_attr_value_date_sql        VARCHAR2(32767);
    l_attr_value_num_sql         VARCHAR2(32767);
    l_attr_value_uom_sql         VARCHAR2(32767);

    /* Bug 10263673 : Start */
    l_attr_str_where_sql         VARCHAR2(32767);
    l_attr_date_where_sql        VARCHAR2(32767);
    l_attr_num_where_sql         VARCHAR2(32767);
    /* Bug 10263673 : End */

    l_max_row_identifier         NUMBER;

    l_curr_attr_grp_id    NUMBER;
    l_data_level_id       NUMBER;

    CURSOR c_attr_rec(c_attr_group_id  IN  NUMBER)
    IS
      SELECT
        attr_ext.ATTR_ID,
        attr_col.END_USER_COLUMN_NAME AS ATTR_NAME,
        attr_ext.DATA_TYPE AS DATA_TYPE_CODE,
        attr_ext.APPLICATION_COLUMN_NAME AS DATABASE_COLUMN,
        attr_ext.UOM_CLASS AS UOM_CLASS,
        ag_ext.MULTI_ROW
      FROM
        FND_DESCR_FLEX_COLUMN_USAGES attr_col,
        EGO_FND_DF_COL_USGS_EXT attr_ext,
        EGO_FND_DSC_FLX_CTX_EXT ag_ext
      WHERE ag_ext.ATTR_GROUP_ID                   = c_attr_group_id
        AND ag_ext.DESCRIPTIVE_FLEXFIELD_NAME      = attr_ext.DESCRIPTIVE_FLEXFIELD_NAME
        AND ag_ext.DESCRIPTIVE_FLEX_CONTEXT_CODE   = attr_ext.DESCRIPTIVE_FLEX_CONTEXT_CODE
        AND ag_ext.APPLICATION_ID                  = attr_ext.APPLICATION_ID
        AND attr_ext.APPLICATION_ID                = attr_col.APPLICATION_ID
        AND attr_ext.DESCRIPTIVE_FLEXFIELD_NAME    = attr_col.DESCRIPTIVE_FLEXFIELD_NAME
        AND attr_ext.DESCRIPTIVE_FLEX_CONTEXT_CODE = attr_col.DESCRIPTIVE_FLEX_CONTEXT_CODE
        AND attr_ext.APPLICATION_COLUMN_NAME       = attr_col.APPLICATION_COLUMN_NAME
        AND attr_col.ENABLED_FLAG                  = 'Y';
  BEGIN
    SetGlobals();
    Debug_Conc_Log('Starting Copy_data_to_Intf');
     -- Standard start of API savepoint
    IF FND_API.To_Boolean(p_commit) THEN
      SAVEPOINT Copy_data_to_Intf_SP;
    END IF;

    BEGIN
      SELECT NVL(MAX(row_identifier),0)
      INTO l_max_row_identifier
      FROM EGO_ITM_USR_ATTR_INTRFC
      WHERE DATA_SET_ID = p_dest_data_set_id;
    EXCEPTION
      WHEN OTHERS THEN
        l_max_row_identifier := 0;
    END;

    l_dest_transaction_type := q'# '#'||p_dest_transaction_type||q'#'#';
    Debug_Conc_Log('Copy_data_to_Intf: l_max_row_identifier='||l_max_row_identifier);
    l_insert_cols := q'#
                     ( TRANSACTION_ID,
                       PROCESS_STATUS,
                       DATA_SET_ID,
                       TRANSACTION_TYPE,
                       ORGANIZATION_ID,
                       ORGANIZATION_CODE,
                       INVENTORY_ITEM_ID,
                       ITEM_NUMBER,
                       ITEM_CATALOG_GROUP_ID,
                       DATA_LEVEL_ID,
                       REVISION_ID,
                       REVISION,
                       PK1_VALUE,
                       PK2_VALUE,
                       PK3_VALUE,
                       PK4_VALUE,
                       PK5_VALUE,
                       ROW_IDENTIFIER,
                       ATTR_GROUP_TYPE,
                       ATTR_GROUP_INT_NAME,
                       ATTR_GROUP_ID,
                       ATTR_INT_NAME,
                       ATTR_VALUE_STR,
                       ATTR_VALUE_NUM,
                       ATTR_VALUE_DATE,
                       ATTR_VALUE_UOM,
                       CREATED_BY,
                       CREATION_DATE,
                       LAST_UPDATED_BY,
                       LAST_UPDATE_DATE,
                       LAST_UPDATE_LOGIN,
                       REQUEST_ID,
                       CHANGE_ID,
                       CHANGE_LINE_ID,
                       SOURCE_SYSTEM_ID,
                       SOURCE_SYSTEM_REFERENCE,
                       PROG_INT_CHAR1,
                       PROG_INT_NUM4,
                       BUNDLE_ID ) #';

    Debug_Conc_Log('Copy_data_to_Intf: p_copy_from_intf_table='||p_copy_from_intf_table);
    IF FND_API.to_boolean(p_copy_from_intf_table) THEN
      l_prog_int_char1_value := q'#'FROM_INTF'#';
      l_prog_int_num4_value := 2;
      l_select_sql := q'#
                      ( SELECT
                          src.TRANSACTION_ID,
                          #'|| p_dest_process_status || q'# AS PROCESS_STATUS,
                          #'|| p_dest_data_set_id    || q'# AS DATA_SET_ID,
                          #'|| l_dest_transaction_type|| q'# AS TRANSACTION_TYPE,
                          src.ORGANIZATION_ID,
                          src.ORGANIZATION_CODE,
                          src.INVENTORY_ITEM_ID,
                          src.ITEM_NUMBER,
                          src.ITEM_CATALOG_GROUP_ID,
                          src.DATA_LEVEL_ID,
                          src.REVISION_ID,
                          src.REVISION,
                          src.PK1_VALUE,
                          src.PK2_VALUE,
                          src.PK3_VALUE,
                          src.PK4_VALUE,
                          src.PK5_VALUE,
                          #'|| l_max_row_identifier || q'# + src.ROW_IDENTIFIER AS ROW_IDENTIFIER,
                          src.ATTR_GROUP_TYPE,
                          src.ATTR_GROUP_INT_NAME,
                          src.ATTR_GROUP_ID,
                          src.ATTR_INT_NAME,
                          src.ATTR_VALUE_STR,
                          src.ATTR_VALUE_NUM,
                          src.ATTR_VALUE_DATE,
                          src.ATTR_VALUE_UOM,
                          #' || G_USER_ID || q'# AS CREATED_BY,
                          SYSDATE AS CREATION_DATE,
                          #' || G_USER_ID || q'# AS LAST_UPDATED_BY,
                          SYSDATE AS LAST_UPDATE_DATE,
                          #' || G_LOGIN_ID || q'# AS LAST_UPDATE_LOGIN,
                          #' || G_REQUEST_ID || q'# AS REQUEST_ID,
                          src.CHANGE_ID,
                          src.CHANGE_LINE_ID,
                          src.SOURCE_SYSTEM_ID,
                          src.SOURCE_SYSTEM_REFERENCE,
                          #'|| l_prog_int_char1_value|| q'# AS PROG_INT_CHAR1,
                          #'|| l_prog_int_num4_value|| q'# AS PROG_INT_NUM4,
                          src.BUNDLE_ID
                        FROM (#' || p_source_entity_sql || q'#) src, EGO_FND_DSC_FLX_CTX_EXT ag_ext
                        WHERE ag_ext.DESCRIPTIVE_FLEXFIELD_NAME    = NVL(src.ATTR_GROUP_TYPE, 'EGO_ITEMMGMT_GROUP')
                          AND ag_ext.DESCRIPTIVE_FLEX_CONTEXT_CODE = src.ATTR_GROUP_INT_NAME
                          AND ag_ext.APPLICATION_ID                = 431
                          AND ( ag_ext.MULTI_ROW= 'N'
                              OR NOT EXISTS (SELECT NULL FROM EGO_ITM_USR_ATTR_INTRFC intfx
                                             WHERE intfx.DATA_SET_ID                                = src.DATA_SET_ID
                                               AND intfx.PROCESS_STATUS                             = #'|| p_dest_process_status || q'#
                                               AND intfx.INVENTORY_ITEM_ID                          = src.INVENTORY_ITEM_ID
                                               AND intfx.ORGANIZATION_ID                            = src.ORGANIZATION_ID
                                               AND intfx.DATA_LEVEL_ID                              = src.DATA_LEVEL_ID
                                               AND NVL(intfx.BUNDLE_ID, -1)                         = NVL(src.BUNDLE_ID, -1)
                                               AND NVL(intfx.REVISION_ID, -1)                       = NVL(src.REVISION_ID, -1)
                                               AND NVL(intfx.PK1_VALUE, -1)                         = NVL(src.PK1_VALUE, -1)
                                               AND NVL(intfx.PK2_VALUE, -1)                         = NVL(src.PK2_VALUE, -1)
                                               AND NVL(intfx.PK3_VALUE, -1)                         = NVL(src.PK3_VALUE, -1)
                                               AND NVL(intfx.PK4_VALUE, -1)                         = NVL(src.PK4_VALUE, -1)
                                               AND NVL(intfx.PK5_VALUE, -1)                         = NVL(src.PK5_VALUE, -1)
                                               AND NVL(intfx.ATTR_GROUP_TYPE, 'EGO_ITEMMGMT_GROUP') = NVL(src.ATTR_GROUP_TYPE, 'EGO_ITEMMGMT_GROUP')
                                               AND intfx.ATTR_GROUP_INT_NAME                        = src.ATTR_GROUP_INT_NAME
                                            )
                              )
                          ) source #';

      l_where_clause := q'#
                          ON
                         (     intf.DATA_SET_ID                                = source.DATA_SET_ID
                           AND intf.PROCESS_STATUS                             = source.PROCESS_STATUS
                           AND intf.INVENTORY_ITEM_ID                          = source.INVENTORY_ITEM_ID
                           AND intf.ORGANIZATION_ID                            = source.ORGANIZATION_ID
                           AND intf.DATA_LEVEL_ID                              = source.DATA_LEVEL_ID
                           AND NVL(intf.BUNDLE_ID, -1)                         = NVL(source.BUNDLE_ID, -1)
                           AND NVL(intf.REVISION_ID, -1)                       = NVL(source.REVISION_ID, -1)
                           AND NVL(intf.PK1_VALUE, -1)                         = NVL(source.PK1_VALUE, -1)
                           AND NVL(intf.PK2_VALUE, -1)                         = NVL(source.PK2_VALUE, -1)
                           AND NVL(intf.PK3_VALUE, -1)                         = NVL(source.PK3_VALUE, -1)
                           AND NVL(intf.PK4_VALUE, -1)                         = NVL(source.PK4_VALUE, -1)
                           AND NVL(intf.PK5_VALUE, -1)                         = NVL(source.PK5_VALUE, -1)
                           AND NVL(intf.ATTR_GROUP_TYPE, 'EGO_ITEMMGMT_GROUP') = NVL(source.ATTR_GROUP_TYPE, 'EGO_ITEMMGMT_GROUP')
                           AND intf.ATTR_GROUP_INT_NAME                        = source.ATTR_GROUP_INT_NAME
                           AND intf.ATTR_INT_NAME                              = source.ATTR_INT_NAME
                         ) #';

      l_when_matched := q'#
                        WHEN MATCHED THEN
                          UPDATE SET
                            intf.ATTR_VALUE_STR  = source.ATTR_VALUE_STR,
                            intf.ATTR_VALUE_NUM  = source.ATTR_VALUE_NUM,
                            intf.ATTR_VALUE_UOM  = source.ATTR_VALUE_UOM,
                            intf.ATTR_VALUE_DATE = source.ATTR_VALUE_DATE,
                            intf.PROG_INT_NUM4   = 3
                          WHERE NVL(intf.PROG_INT_NUM4, -1) <> 0
                         #';

      l_when_not_matched := q'#
                            WHEN NOT MATCHED THEN
                              INSERT #' || l_insert_cols || q'# VALUES
                               ( source.TRANSACTION_ID,
                                 source.PROCESS_STATUS,
                                 source.DATA_SET_ID,
                                 source.TRANSACTION_TYPE,
                                 source.ORGANIZATION_ID,
                                 source.ORGANIZATION_CODE,
                                 source.INVENTORY_ITEM_ID,
                                 source.ITEM_NUMBER,
                                 source.ITEM_CATALOG_GROUP_ID,
                                 source.DATA_LEVEL_ID,
                                 source.REVISION_ID,
                                 source.REVISION,
                                 source.PK1_VALUE,
                                 source.PK2_VALUE,
                                 source.PK3_VALUE,
                                 source.PK4_VALUE,
                                 source.PK5_VALUE,
                                 source.ROW_IDENTIFIER,
                                 source.ATTR_GROUP_TYPE,
                                 source.ATTR_GROUP_INT_NAME,
                                 source.ATTR_GROUP_ID,
                                 source.ATTR_INT_NAME,
                                 source.ATTR_VALUE_STR,
                                 source.ATTR_VALUE_NUM,
                                 source.ATTR_VALUE_DATE,
                                 source.ATTR_VALUE_UOM,
                                 source.CREATED_BY,
                                 source.CREATION_DATE,
                                 source.LAST_UPDATED_BY,
                                 source.LAST_UPDATE_DATE,
                                 source.LAST_UPDATE_LOGIN,
                                 source.REQUEST_ID,
                                 source.CHANGE_ID,
                                 source.CHANGE_LINE_ID,
                                 source.SOURCE_SYSTEM_ID,
                                 source.SOURCE_SYSTEM_REFERENCE,
                                 source.PROG_INT_CHAR1,
                                 source.PROG_INT_NUM4,
                                 source.BUNDLE_ID )
                              #';
      l_dynamic_sql := 'MERGE INTO EGO_ITM_USR_ATTR_INTRFC intf USING ' ||
                       l_select_sql || l_where_clause || l_when_matched || l_when_not_matched;

      Debug_Conc_Log('Copy_data_to_Intf: l_dynamic_sql='||l_dynamic_sql);
      EXECUTE IMMEDIATE l_dynamic_sql;
      Debug_Conc_Log('Copy_data_to_Intf: Processed '||SQL%ROWCOUNT||' rows');
    ELSE  -- FND_API.to_boolean(p_copy_from_intf_table)
      l_prog_int_char1_value := q'#'FROM_PROD'#';
      l_prog_int_num4_value := 1;
      l_attr_group_sql := 'SELECT DISTINCT ATTR_GROUP_ID FROM ( '|| p_source_attr_groups_sql ||' ) ';
      OPEN l_dynamic_cursor FOR l_attr_group_sql;
      LOOP
        FETCH l_dynamic_cursor INTO l_curr_attr_grp_id;
        EXIT WHEN l_dynamic_cursor%NOTFOUND;
        Debug_Conc_Log('Copy_data_to_Intf: Processing AG, ID='||l_curr_attr_grp_id);

        l_attr_value_str_sql   := '(CASE';
        l_attr_value_date_sql  := '(CASE';
        l_attr_value_num_sql   := '(CASE';
        l_attr_value_uom_sql   := '(CASE';
        FOR i IN c_attr_rec(l_curr_attr_grp_id)
        LOOP
          l_attr_value_str_sql  := l_attr_value_str_sql  || q'# WHEN attr_col.END_USER_COLUMN_NAME = '#'|| i.ATTR_NAME || q'#' #';
          l_attr_value_date_sql := l_attr_value_date_sql || q'# WHEN attr_col.END_USER_COLUMN_NAME = '#'|| i.ATTR_NAME || q'#' #';
          l_attr_value_num_sql  := l_attr_value_num_sql  || q'# WHEN attr_col.END_USER_COLUMN_NAME = '#'|| i.ATTR_NAME || q'#' #';
          l_attr_value_uom_sql  := l_attr_value_uom_sql  || q'# WHEN attr_col.END_USER_COLUMN_NAME = '#'|| i.ATTR_NAME || q'#' #';
          l_multi_row := i.MULTI_ROW;

          IF i.DATA_TYPE_CODE IN (EGO_EXT_FWK_PUB.G_TRANS_TEXT_DATA_TYPE, EGO_EXT_FWK_PUB.G_CHAR_DATA_TYPE) THEN
            l_attr_value_str_sql  := l_attr_value_str_sql  || ' THEN src.'||i.DATABASE_COLUMN;
            l_attr_value_date_sql := l_attr_value_date_sql || ' THEN NULL ';
            l_attr_value_num_sql  := l_attr_value_num_sql  || ' THEN NULL ';
            l_attr_value_uom_sql  := l_attr_value_uom_sql  || ' THEN NULL ';
          ELSIF i.DATA_TYPE_CODE IN (EGO_EXT_FWK_PUB.G_DATE_DATA_TYPE, EGO_EXT_FWK_PUB.G_DATE_TIME_DATA_TYPE) THEN
            l_attr_value_str_sql  := l_attr_value_str_sql  || ' THEN NULL ';
            l_attr_value_date_sql := l_attr_value_date_sql || ' THEN src.'||i.DATABASE_COLUMN;
            l_attr_value_num_sql  := l_attr_value_num_sql  || ' THEN NULL ';
            l_attr_value_uom_sql  := l_attr_value_uom_sql  || ' THEN NULL ';
          ELSE
            l_attr_value_str_sql  := l_attr_value_str_sql  || ' THEN NULL ';
            l_attr_value_date_sql := l_attr_value_date_sql || ' THEN NULL ';
            IF i.UOM_CLASS IS NULL THEN
              l_attr_value_num_sql  := l_attr_value_num_sql || ' THEN src.'||i.DATABASE_COLUMN;
              l_attr_value_uom_sql  := l_attr_value_uom_sql || ' THEN NULL ';
            ELSE
              l_dummy_char := 'UOM'||SUBSTR(i.DATABASE_COLUMN, 2);
              l_attr_value_num_sql  := l_attr_value_num_sql || q'# THEN src.#' || i.DATABASE_COLUMN || q'#
                                        /(SELECT CONVERSION_RATE
                                          FROM MTL_UOM_CONVERSIONS
                                          WHERE UOM_CLASS = '#' || i.UOM_CLASS ||q'#'
                                            AND UOM_CODE = src.#' || l_dummy_char || q'#
                                            AND ROWNUM = 1)#';
              l_attr_value_uom_sql  := l_attr_value_uom_sql || ' THEN src.'|| l_dummy_char ||' ';
            END IF; --IF i.UOM_CLASS IS NULL THEN
          END IF; --IF i.DATA_TYPE_CODE IN
        END LOOP;

        /* Bug 10263673 : Start */
        l_attr_str_where_sql  :=  l_attr_value_str_sql || ' END)';
        l_attr_date_where_sql :=  l_attr_value_date_sql || ' END)';
        l_attr_num_where_sql  :=  l_attr_value_num_sql  || ' END)';
        /* Bug 10263673 : End */

        l_attr_value_str_sql  := l_attr_value_str_sql  || ' END) AS ATTR_VALUE_STR,  ';
        l_attr_value_date_sql := l_attr_value_date_sql || ' END) AS ATTR_VALUE_DATE, ';
        l_attr_value_num_sql  := l_attr_value_num_sql  || ' END) AS ATTR_VALUE_NUM,  ';
        l_attr_value_uom_sql  := l_attr_value_uom_sql  || ' END) AS ATTR_VALUE_UOM,  ';

        l_select_sql := q'#
                        SELECT
                          src.TRANSACTION_ID,
                          #'|| p_dest_process_status || q'# AS PROCESS_STATUS,
                          #'|| p_dest_data_set_id    || q'# AS DATA_SET_ID,
                          #'|| l_dest_transaction_type|| q'# AS TRANSACTION_TYPE,
                          src.ORGANIZATION_ID,
                          src.ORGANIZATION_CODE,
                          src.INVENTORY_ITEM_ID,
                          src.ITEM_NUMBER,
                          src.ITEM_CATALOG_GROUP_ID,
                          src.DATA_LEVEL_ID,
                          src.REVISION_ID,
                          src.REVISION,
                          src.PK1_VALUE,
                          src.PK2_VALUE,
                          src.PK3_VALUE,
                          src.PK4_VALUE,
                          src.PK5_VALUE,
                          #'|| l_max_row_identifier || q'# + src.ROW_IDENTIFIER AS ROW_IDENTIFIER,
                          ag_ext.DESCRIPTIVE_FLEXFIELD_NAME,
                          ag_ext.DESCRIPTIVE_FLEX_CONTEXT_CODE,
                          ag_ext.ATTR_GROUP_ID,
                          attr_col.END_USER_COLUMN_NAME, #' ||
                          l_attr_value_str_sql  ||
                          l_attr_value_num_sql  ||
                          l_attr_value_date_sql ||
                          l_attr_value_uom_sql  ||
                          G_USER_ID || q'# AS CREATED_BY,
                          SYSDATE AS CREATION_DATE,
                          #' || G_USER_ID || q'# AS LAST_UPDATED_BY,
                          SYSDATE AS LAST_UPDATE_DATE,
                          #' || G_LOGIN_ID || q'# AS LAST_UPDATE_LOGIN,
                          #' || G_REQUEST_ID || q'# AS REQUEST_ID,
                          src.CHANGE_ID,
                          src.CHANGE_LINE_ID,
                          src.SOURCE_SYSTEM_ID,
                          src.SOURCE_SYSTEM_REFERENCE,
                          #'|| l_prog_int_char1_value|| q'# AS PROG_INT_CHAR1,
                          #'|| l_prog_int_num4_value|| q'# AS PROG_INT_NUM4,
                          src.BUNDLE_ID
                        FROM (#' || p_source_entity_sql || q'#) src,
                          FND_DESCR_FLEX_COLUMN_USAGES attr_col,
                          EGO_FND_DSC_FLX_CTX_EXT ag_ext #';

        l_where_clause := q'#
                          WHERE src.ATTR_GROUP_ID                      = #' || l_curr_attr_grp_id || q'#
                            AND src.ATTR_GROUP_ID                      = ag_ext.ATTR_GROUP_ID
                            AND ag_ext.DESCRIPTIVE_FLEXFIELD_NAME      = attr_col.DESCRIPTIVE_FLEXFIELD_NAME
                            AND ag_ext.DESCRIPTIVE_FLEX_CONTEXT_CODE   = attr_col.DESCRIPTIVE_FLEX_CONTEXT_CODE
                            AND ag_ext.APPLICATION_ID                  = attr_col.APPLICATION_ID
                            AND attr_col.ENABLED_FLAG                  = 'Y'
                            AND NOT EXISTS (SELECT NULL FROM EGO_ITM_USR_ATTR_INTRFC intf
                                            WHERE intf.DATA_SET_ID                                = src.DATA_SET_ID
                                              AND intf.PROCESS_STATUS                             = #' || p_dest_process_status || q'#
                                              AND intf.INVENTORY_ITEM_ID                          = src.INVENTORY_ITEM_ID
                                              AND intf.ORGANIZATION_ID                            = src.ORGANIZATION_ID
                                              AND intf.DATA_LEVEL_ID                              = src.DATA_LEVEL_ID
                                              AND NVL(intf.BUNDLE_ID, -1)                         = NVL(src.BUNDLE_ID, -1)
                                              AND NVL(intf.REVISION_ID, -1)                       = NVL(src.REVISION_ID, -1)
                                              AND NVL(intf.PK1_VALUE, -1)                         = NVL(src.PK1_VALUE, -1)
                                              AND NVL(intf.PK2_VALUE, -1)                         = NVL(src.PK2_VALUE, -1)
                                              AND NVL(intf.PK3_VALUE, -1)                         = NVL(src.PK3_VALUE, -1)
                                              AND NVL(intf.PK4_VALUE, -1)                         = NVL(src.PK4_VALUE, -1)
                                              AND NVL(intf.PK5_VALUE, -1)                         = NVL(src.PK5_VALUE, -1)
                                              AND NVL(intf.ATTR_GROUP_TYPE, 'EGO_ITEMMGMT_GROUP') = ag_ext.DESCRIPTIVE_FLEXFIELD_NAME
                                              AND intf.ATTR_GROUP_INT_NAME                        = ag_ext.DESCRIPTIVE_FLEX_CONTEXT_CODE #';
        IF l_multi_row = 'Y' THEN
          l_where_clause := l_where_clause || ' ) ';
        ELSE
          l_where_clause := l_where_clause || ' AND intf.ATTR_INT_NAME                              = attr_col.END_USER_COLUMN_NAME ) ';
        END IF;

        -- Bug 10263673 : Do not insert the attrs which have null values.
        -- Bug 11816309 : Changes
        l_where_clause := l_where_clause || '
                            AND (' || l_attr_str_where_sql  || ' IS NOT NULL OR
                                  '|| l_attr_date_where_sql || ' IS NOT NULL OR
                                  '|| l_attr_num_where_sql  || ' IS NOT NULL
                                 )';


        l_dynamic_sql := 'INSERT INTO EGO_ITM_USR_ATTR_INTRFC ' || l_insert_cols || l_select_sql || l_where_clause;
        Debug_Conc_Log('Copy_data_to_Intf: l_dynamic_sql='||l_dynamic_sql);
        EXECUTE IMMEDIATE l_dynamic_sql;
        Debug_Conc_Log('Copy_data_to_Intf: Inserted '||SQL%ROWCOUNT||' rows');
      END LOOP; -- attr_group_id LOOP
      CLOSE l_dynamic_cursor;
    END IF; -- FND_API.to_boolean(p_copy_from_intf_table)

    Debug_Conc_Log('Copy_data_to_Intf: Done inserting');

    /* Fix for bug#9678667 - Start: Commenting the below code - the below code should be done after this api call */
    /*
    IF p_dest_process_status = G_PS_IN_PROCESS  THEN
      UPDATE ego_itm_usr_attr_intrfc
       SET PROG_INT_NUM1          = NULL
          ,PROG_INT_NUM2          = NULL
          ,PROG_INT_NUM3          = NULL
          ,PROG_INT_CHAR1         = 'N'
          ,PROG_INT_CHAR2         = 'N'
          ,REQUEST_ID             = FND_GLOBAL.CONC_REQUEST_ID
          ,PROGRAM_APPLICATION_ID = FND_GLOBAL.PROG_APPL_ID
          ,PROGRAM_ID             = FND_GLOBAL.CONC_PROGRAM_ID
          ,PROGRAM_UPDATE_DATE    = SYSDATE
      WHERE PROCESS_STATUS   = p_dest_process_status
        AND DATA_SET_ID      = p_dest_data_set_id
        AND TRANSACTION_TYPE = p_dest_transaction_type
        AND PROG_INT_CHAR1   IN ('FROM_INTF', 'FROM_PROD');
    END IF;
    */ /* Fix for bug#9678667 : End */

    IF p_cleanup_row_identifiers = FND_API.G_TRUE THEN
      Debug_Conc_Log('Copy_data_to_Intf: Calling Clean_Up_UDA_Row_Idents with process_status='||p_dest_process_status);
      EGO_IMPORT_PVT.Clean_Up_UDA_Row_Idents(
                               p_batch_id            => p_dest_data_set_id,
                               p_process_status      => p_dest_process_status,
                               p_ignore_item_num_upd => FND_API.G_TRUE,
                               p_commit              => FND_API.G_FALSE );
      Debug_Conc_Log('Copy_data_to_Intf: Clean_Up_UDA_Row_Idents Done.');
    END IF;
    Debug_Conc_Log('Copy_data_to_Intf: Done');
    x_return_status := FND_API.G_RET_STS_SUCCESS;
  EXCEPTION WHEN OTHERS THEN
    IF FND_API.To_Boolean(p_commit) THEN
      ROLLBACK TO Copy_data_to_Intf_SP;
    END IF;
    IF l_dynamic_cursor%ISOPEN THEN
      CLOSE l_dynamic_cursor;
    END IF;
    Debug_Conc_Log('Copy_data_to_Intf: Error-'||SQLERRM);
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    x_msg_data := SQLERRM;
  END Copy_data_to_Intf;

  ----------------------------------------------------------------------

END EGO_ITEM_USER_ATTRS_CP_PUB;

/
