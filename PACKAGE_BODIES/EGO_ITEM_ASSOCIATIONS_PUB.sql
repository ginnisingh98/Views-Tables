--------------------------------------------------------
--  DDL for Package Body EGO_ITEM_ASSOCIATIONS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EGO_ITEM_ASSOCIATIONS_PUB" AS
/* $Header: EGOPIASB.pls 120.30.12010000.6 2011/07/18 09:40:26 nendrapu ship $ */

  G_FILE_NAME                  VARCHAR2(12);
  G_PKG_NAME                   VARCHAR2(30);

  G_USER_ID                    fnd_user.user_id%TYPE;
  G_PARTY_ID                   hz_parties.party_id%TYPE;
  G_LOGIN_ID                   fnd_user.last_update_login%TYPE;
  G_REQUEST_ID                 NUMBER;
  G_PROG_APPID                 ego_item_associations_intf.program_application_id%TYPE;
  G_PROG_ID                    ego_item_associations_intf.program_id%TYPE;
  G_SYSDATE                    fnd_user.creation_date%TYPE;
  G_SESSION_LANG               VARCHAR2(99);
  G_DATA_LEVEL_NAMES           VARCHAR2_TBL_TYPE;
  G_LOG_TIMESTAMP_FORMAT       VARCHAR2(25) := 'DD-MM-YYYY HH24:MI:SS';
  G_SKIP_SECURIY_CHECK         NUMBER := -99;

  PROCEDURE write_log_message( p_message IN VARCHAR2
                          , p_add_timestamp IN BOOLEAN DEFAULT TRUE )
  IS
     l_inv_debug_level  NUMBER := INVPUTLI.get_debug_level;
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
  END write_log_message;

  /*
  -- Start of comments
  --  API name    : set_globals
  --  Type        : Private.
  --  Function    : Sets the global constant values used in this package.
  --  Pre-reqs    : None.
  --  Version     : Initial version     1.0
  --  Notes       : Sets the global constant values used in this package.
  --                1. G_USER_ID - user id
  --                2. G_SYSDATE - Creation Date and Update Date
  --                3. G_LOGIN_ID - Login which is used to create/update.
  -- End of comments
  */
  PROCEDURE set_globals IS
  BEGIN
    --
    -- file names
    --
    G_FILE_NAME  := NVL(G_FILE_NAME,'EGOPIASB.pls');
    G_PKG_NAME   := NVL(G_PKG_NAME,'EGO_ITEM_ASSOCIATIONS_PUB');
    --
    -- user values
    --
    G_USER_ID    := FND_GLOBAL.user_id;
    G_LOGIN_ID   := FND_GLOBAL.login_id;
    G_REQUEST_ID := NVL(FND_GLOBAL.conc_request_id, -1);
    G_PROG_APPID := FND_GLOBAL.prog_appl_id;
    G_PROG_ID    := FND_GLOBAL.conc_program_id;
    G_SYSDATE    := NVL(G_SYSDATE,SYSDATE);
    G_SESSION_LANG := USERENV('LANG');
    G_PARTY_ID := -1;
    G_DATA_LEVEL_NAMES(1) := G_ITEM_SUP_LEVEL_NAME;
    G_DATA_LEVEL_NAMES(2) := G_ITEM_SUP_SITE_LEVEL_NAME;
    G_DATA_LEVEL_NAMES(3) := G_ITEM_SUP_SITE_ORG_LEVEL_NAME;
    write_log_message(' After setting globals ' );
    BEGIN
      SELECT party_id
      INTO G_PARTY_ID
      FROM ego_user_v
      WHERE USER_ID = G_USER_ID;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        SELECT party_id, user_id
        INTO G_PARTY_ID, G_USER_ID
        FROM ego_user_v
        WHERE USER_NAME = FND_GLOBAL.USER_NAME;
    END;
  EXCEPTION
    WHEN OTHERS THEN
      write_log_message(' After setting globals end' || SQLERRM);
  END set_globals;

  /*
  -- Start of comments
  --  API name    : initialize
  --  Type        : Private.
  --  Function    : Initializes the import flow.
  --  Pre-reqs    : None.
  --  Parameters  :
  --  IN          : p_batch_id          IN NUMBER   Required
  --  Version     : Initial version     1.0
  --  Notes       : Initializes the import flow.
  --                1. Change the transaction type to UPPER
  --                2. Initialize the records to be G_REC_IN_PROCESS
  --                   where current status G_REC_TO_BE_PROCESSED
  --                3. Set Missing Required value if any of the following are null
  --                     i) Org Code and Org Id
  --                    ii) Item Number and Item Id
  --                   iii) pk1_value and pk1_name
  --                    iv) (Item-SupplierSite or Item-SupplierSite-Org)
  --                        and (pk2 value and pk2 name is null)
  --
  -- End of comments
  */
  PROCEDURE initialize( p_batch_id IN NUMBER )
  IS
  BEGIN
    FOR l_null_tx_rec IN ( SELECT ROWID
                             FROM ego_item_associations_intf
                            WHERE batch_id = p_batch_id
                              AND process_flag = G_REC_TO_BE_PROCESSED
                              AND transaction_id IS NULL
                         )
    LOOP
      UPDATE ego_item_associations_intf
         SET transaction_id = mtl_system_items_interface_s.nextval
       WHERE ROWID = l_null_tx_rec.ROWID;
    END LOOP;
    -- Set the process flag to in process
    UPDATE ego_item_associations_intf
       SET process_flag = G_REC_IN_PROCESS
     WHERE batch_id = p_batch_id
       AND process_flag = G_REC_TO_BE_PROCESSED;
    -- Check Required Values based on Transaction Type

    -- Atleast one of the item value and one of the org value should be populated
    UPDATE ego_item_associations_intf
       SET process_flag = G_REC_MISSING_REQ_VALUE
     WHERE batch_id = p_batch_id
       AND process_flag  = G_REC_IN_PROCESS
       AND transaction_type = G_CREATE
       AND ( ( inventory_item_id IS NULL AND item_number IS NULL )
              OR ( organization_id IS NULL AND organization_code IS NULL)
           );
    UPDATE ego_item_associations_intf
       SET process_flag = G_REC_MISSING_REQ_VALUE
     WHERE batch_id = p_batch_id
       AND process_flag  = G_REC_IN_PROCESS
       AND transaction_type = G_CREATE
       AND ( ( pk1_value IS NULL AND supplier_name IS NULL AND supplier_number IS NULL )
             OR ( ( data_level_id = G_ITEM_SUPPLIERSITE_LEVEL
                    OR data_level_id = G_ITEM_SUPPLIERSITE_ORG_LEVEL )
             AND  ( pk2_value IS NULL AND supplier_site_name IS NULL ) )
           );

  END initialize;

  /*
  -- Start of comments
  --  API name    : convert_values_to_ids
  --  Type        : Private.
  --  Function    : Converts user entered values to system ids.
  --  Pre-reqs    : None.
  --  Parameters  :
  --  IN          : p_batch_id          IN NUMBER   Required
  --  Version     : Initial version     1.0
  --  Notes       : Converts user entered values to system ids.
  --                1. Convert master org id and master org code
  --                          (Item-Supplier and Item-SupplierSite)
  --                2. Convert org id and org code (Item-SupplierSite-Org)
  --                3. Convert Item Id and Item Number
  --                4. Convert pk1 and pk2 values
  --                5. Convert SYNC to CREATE/UPDATE
  --                6. Populate UPDATE/DELETE records with association id
  --                7. Validate Duplicate
  --                8. After conversion set the record to error in following cases
  --                     i) If org is null
  --                    ii) If item is null
  --                   iii) If pk1 value is null
  --                    iv) If pk2 value is null for item-site and item-site-org
  --                    iv) association id is null for UPDATE/DELETE
  -- End of comments
  */
  PROCEDURE convert_values_to_ids( p_batch_id IN NUMBER )
  IS
  BEGIN
    /* Do not convert name to ids, which is required only for error reporting.
    -- Convert the master org values.  Convert Organization Id to Organization Code
    UPDATE ego_item_associations_intf eiai
       SET organization_code = ( SELECT mp.organization_code
                                   FROM mtl_parameters mp
                                  WHERE mp.organization_id = eiai.organization_id
                                    AND mp.master_organization_id = mp.organization_id)
     WHERE eiai.batch_id = p_batch_id
       AND ( eiai.data_level_id = G_ITEM_SUPPLIER_LEVEL OR eiai.data_level_id = G_ITEM_SUPPLIERSITE_LEVEL )
       AND eiai.process_flag = G_REC_IN_PROCESS
       AND eiai.organization_code IS NULL
       AND eiai.organization_id IS NOT NULL;

    -- Convert the org values.  Convert Organization Id to Organization Code
    UPDATE ego_item_associations_intf eiai
       SET organization_code = ( SELECT mp.organization_code
                                   FROM mtl_parameters mp
                                  WHERE mp.organization_id = eiai.organization_id)
     WHERE eiai.batch_id = p_batch_id
       AND eiai.data_level_id = G_ITEM_SUPPLIERSITE_ORG_LEVEL
       AND eiai.process_flag = G_REC_IN_PROCESS
       AND eiai.organization_code IS NULL
       AND eiai.organization_id IS NOT NULL;

    -- check whether item value converion is required..
    UPDATE ego_item_associations_intf eiai
       SET item_number = ( SELECT concatenated_segments
                            FROM mtl_system_items_b_kfv msibk
                           WHERE msibk.organization_id = eiai.organization_id
                             AND msibk.inventory_item_id = eiai.inventory_item_id
                         )
     WHERE eiai.batch_id = p_batch_id
       AND eiai.process_flag = G_REC_IN_PROCESS
       AND eiai.item_number IS NULL
       AND eiai.inventory_item_id IS NOT NULL;
    */
    UPDATE ego_item_associations_intf eiai
       SET inventory_item_id = ( SELECT inventory_item_id
                                    FROM mtl_system_items_b_kfv msibk
                                   WHERE msibk.organization_id = eiai.organization_id
                                     AND msibk.concatenated_segments = eiai.item_number
                                )
     WHERE eiai.batch_id = p_batch_id
       AND eiai.process_flag = G_REC_IN_PROCESS
       AND eiai.inventory_item_id IS NULL
       AND eiai.item_number IS NOT NULL;
    /*
    UPDATE ego_item_associations_intf eiai
       SET (supplier_number,supplier_name) = ( SELECT segment1, vendor_name
                                 FROM ap_suppliers aas
                                WHERE aas.vendor_id = eiai.pk1_value
                             )
     WHERE eiai.batch_id = p_batch_id
       AND eiai.process_flag = G_REC_IN_PROCESS
       AND eiai.supplier_number IS NULL
       AND eiai.pk1_value IS NOT NULL;
    UPDATE ego_item_associations_intf eiai
       SET supplier_site_name = ( SELECT vendor_site_code
                          FROM ap_supplier_sites_all asa
                         WHERE asa.vendor_site_id = eiai.pk2_value
                           AND asa.org_id = fnd_profile.value('ORG_ID')
                        )
     WHERE eiai.batch_id = p_batch_id
       AND eiai.process_flag = G_REC_IN_PROCESS
       AND eiai.supplier_site_name IS NULL
       AND eiai.pk2_value IS NOT NULL;

    UPDATE ego_item_associations_intf eiai
       SET item_number = ( SELECT concatenated_segments
                            FROM mtl_system_items_b_kfv msibk
                           WHERE msibk.organization_id = eiai.organization_id
                             AND msibk.inventory_item_id = eiai.inventory_item_id
                         )
     WHERE eiai.batch_id = p_batch_id
       AND eiai.process_flag = G_REC_IN_PROCESS
       AND eiai.item_number IS NULL
       AND eiai.inventory_item_id IS NOT NULL;
    */

    UPDATE ego_item_associations_intf eiai
       SET association_id = ( SELECT eia.association_id
                                FROM ego_item_associations eia
                               WHERE eia.data_level_id = eiai.data_level_id
                                 AND eia.organization_id = eiai.organization_id
                                 AND eia.inventory_item_id = eiai.inventory_item_id
                                 AND eia.pk1_value = eiai.pk1_value
                                 AND NVL(eia.pk2_value,-1) = NVL(eiai.pk2_value,-1)
                            )
     WHERE eiai.batch_id = p_batch_id
       AND eiai.process_flag = G_REC_IN_PROCESS
       AND ( eiai.transaction_type = G_UPDATE OR eiai.transaction_type = G_DELETE );
    /*
    UPDATE ego_item_associations_intf eiai1
       SET process_flag = G_REC_DUPLICATE
     WHERE eiai1.batch_id = p_batch_id
       AND EXISTS
       (
           SELECT 1
             FROM ego_item_associations_intf eiai2
            WHERE eiai2.transaction_type = eiai1.transaction_type
              AND eiai2.batch_id = eiai1.batch_id
              AND eiai2.transaction_id <> eiai1.transaction_id
              AND eiai2.inventory_item_id = eiai1.inventory_item_id
              AND eiai2.organization_id = eiai1.organization_id
              AND eiai2.data_level_id = eiai1.data_level_id
              AND eiai2.pk1_value = eiai1.pk1_value
              AND NVL(eiai1.pk2_value,-1) = NVL(eiai2.pk2_value,-1)
        );
    */
    UPDATE ego_item_associations_intf eiai
       SET process_flag = G_REC_INVALID_MASTER_ORG
     WHERE eiai.batch_id = p_batch_id
       AND eiai.process_flag = G_REC_IN_PROCESS
       AND ( eiai.data_level_id = G_ITEM_SUPPLIER_LEVEL OR eiai.data_level_id = G_ITEM_SUPPLIERSITE_LEVEL )
       AND ( eiai.organization_id IS NULL
             OR NOT EXISTS
             (
               SELECT 1
                 FROM mtl_parameters mp
                WHERE mp.master_organization_id = eiai.organization_id
             )
           );
    UPDATE ego_item_associations_intf eiai
       SET process_flag = G_REC_INVALID_ORG
     WHERE eiai.batch_id = p_batch_id
       AND eiai.process_flag = G_REC_IN_PROCESS
       AND eiai.data_level_id = G_ITEM_SUPPLIERSITE_ORG_LEVEL
       AND ( eiai.organization_id IS NULL
             OR NOT EXISTS
             (
               SELECT 1
                 FROM mtl_parameters mp
                WHERE mp.organization_id = eiai.organization_id
             )
           );
    UPDATE ego_item_associations_intf eiai
       SET process_flag = G_REC_INVALID_ITEM
     WHERE eiai.batch_id = p_batch_id
       AND eiai.process_flag = G_REC_IN_PROCESS
       AND ( eiai.inventory_item_id IS NULL
             OR NOT EXISTS
             (
               SELECT 1
                 FROM mtl_system_items_b msib
                WHERE msib.inventory_item_id = eiai.inventory_item_id
                  AND msib.organization_id = eiai.organization_id
             )
           );
    UPDATE ego_item_associations_intf eiai
       SET process_flag = G_REC_INVALID_PK1_VALUE
     WHERE eiai.batch_id = p_batch_id
       AND eiai.process_flag = G_REC_IN_PROCESS
       AND ( eiai.pk1_value IS NULL
             OR NOT EXISTS
             (
               SELECT 1
                 FROM ap_suppliers aas
                WHERE aas.vendor_id = eiai.pk1_value
                and NVL(aas.end_date_active,SYSDATE+1) > SYSDATE  --bug11072046
             )
           );
    UPDATE ego_item_associations_intf eiai
       SET process_flag = G_REC_INVALID_PK2_VALUE
     WHERE eiai.batch_id = p_batch_id
       AND eiai.process_flag = G_REC_IN_PROCESS
       AND ( eiai.data_level_id = G_ITEM_SUPPLIERSITE_ORG_LEVEL
       OR
       eiai.data_level_id = G_ITEM_SUPPLIERSITE_LEVEL   -- BUG 6322084
     )
       AND ( eiai.pk2_value IS NULL
             OR NOT EXISTS
             (
               SELECT 1
                 FROM ap_supplier_sites_all assa
                WHERE assa.vendor_site_id = eiai.pk2_value
                  --AND assa.vendor_id = eiai.vendor_id
      AND assa.vendor_id = eiai.pk1_value
      AND nvl(assa.inactive_date,SYSDATE + 1)>SYSDATE   --BUG 11072046
                  AND assa.org_id = fnd_profile.value('ORG_ID')
             )
           );
    UPDATE ego_item_associations_intf eiai
       SET process_flag = G_REC_ASSOCIATION_NOT_EXISTS
     WHERE eiai.batch_id = p_batch_id
       AND eiai.process_flag = G_REC_IN_PROCESS
       AND ( eiai.transaction_type = G_UPDATE OR eiai.transaction_type = G_DELETE )
       AND eiai.association_id IS NULL;
    UPDATE ego_item_associations_intf eiai
       SET process_flag = G_REC_INVALID_ASSOC_TYPE
     WHERE eiai.batch_id = p_batch_id
       AND eiai.process_flag = G_REC_IN_PROCESS
       AND NOT EXISTS
           (
             SELECT 1
               FROM ego_data_level_b edlb
              WHERE edlb.data_level_id = eiai.data_level_id
           );
    UPDATE ego_item_associations_intf eiai
       SET process_flag = G_REC_INVALID_STATUS
     WHERE eiai.batch_id = p_batch_id
       AND eiai.process_flag = G_REC_IN_PROCESS
       AND eiai.status_code IS NOT NULL
       AND NOT EXISTS
           (
             SELECT 1
               FROM fnd_lookups fl
              WHERE fl.lookup_type = 'EGO_ASSOCIATION_STATUS'
                AND fl.lookup_code = eiai.status_code
           );
    UPDATE ego_item_associations_intf eiai
       SET process_flag = G_REC_INVALID_PRIMARY
     WHERE eiai.batch_id = p_batch_id
       AND eiai.process_flag = G_REC_IN_PROCESS
       AND eiai.primary_flag IS NOT NULL
       AND eiai.primary_flag NOT IN(G_DEFAULT_PRIMARY_FLAG, G_PRIMARY);

  END convert_values_to_ids;

  /*
  -- Start of comments
  --  API name    : check_security
  --  Type        : Private.
  --  Function    : Performs the security check.
  --  Pre-reqs    : None.
  --  Parameters  :
  --  IN          : p_batch_id          IN NUMBER   Required
  --  Version     : Initial version     1.0
  --  Notes       : Performs the security check.
  --                Check create privilege(EGO_CREATE_ITEM_SUP_ASSIGN) for CREATE
  --                Check edit privilege(EGO_EDIT_ITEM_SUP_ASSIGN) for UPDATE/DELETE
  --                Check for supplier access for external user
  -- End of comments
  */
  PROCEDURE check_security(p_batch_id IN NUMBER)
  IS
    l_assoc_create_priv VARCHAR2(30);
    l_assoc_edit_priv VARCHAR2(30);
    l_item_org_edit_priv VARCHAR2(30);
    x_return_status VARCHAR2(1);
    l_sec_predicate VARCHAR2(32767);
    l_dynamic_sql VARCHAR2(32767);
    l_msg_data VARCHAR2(2000);
    l_vendor_contact VARCHAR2(1);
  BEGIN
    l_assoc_create_priv  := 'EGO_CREATE_ITEM_SUP_ASSIGN';
    l_assoc_edit_priv    := 'EGO_EDIT_ITEM_SUP_ASSIGN';
    l_item_org_edit_priv := 'EGO_EDIT_ITEM_ORG_ASSIGN';

    EGO_DATA_SECURITY.get_security_predicate
       (p_api_version      => 1.0
       ,p_function         => l_assoc_create_priv
       ,p_object_name      => 'EGO_ITEM'
       ,p_user_name        => 'HZ_PARTY:'||TO_CHAR(G_PARTY_ID)
       ,p_statement_type   => 'EXISTS'
       ,p_pk1_alias        => 'eiai.inventory_item_id'
       ,p_pk2_alias        => 'eiai.organization_id'
       ,p_pk3_alias        => NULL
       ,p_pk4_alias        => NULL
       ,p_pk5_alias        => NULL
       ,x_predicate        => l_sec_predicate
       ,x_return_status    => x_return_status );

    IF x_return_status IN ('T','F')  THEN
      IF l_sec_predicate IS NOT NULL THEN
        l_dynamic_sql :=
           ' UPDATE ego_item_associations_intf eiai ' ||
           ' SET process_flag = '||G_REC_NO_CREATE_ASSOC_PRIV ||
           ' WHERE batch_id = :p_batch_id '||
           ' AND process_flag = '||G_REC_IN_PROCESS||
           ' AND eiai.created_by <> '||G_SKIP_SECURIY_CHECK||
           ' AND transaction_type = '''||G_CREATE||''' AND NOT '|| l_sec_predicate;
        EXECUTE IMMEDIATE l_dynamic_sql
        USING IN p_batch_id;
      END IF;
    ELSE
      l_msg_data := FND_MESSAGE.GET_ENCODED();
      fnd_message.set_name ('EGO', 'EGO_PLSQL_ERR');
      fnd_message.set_token ('PKG_NAME', G_PKG_NAME);
      fnd_message.set_token ('API_NAME', 'check_security');
      fnd_message.set_token ('SQL_ERR_MSG', l_msg_data);
      APP_EXCEPTION.RAISE_EXCEPTION();
    END IF;
    EGO_DATA_SECURITY.get_security_predicate
       (p_api_version      => 1.0
       ,p_function         => l_assoc_edit_priv
       ,p_object_name      => 'EGO_ITEM'
       ,p_user_name        => 'HZ_PARTY:'||TO_CHAR(G_PARTY_ID)
       ,p_statement_type   => 'EXISTS'
       ,p_pk1_alias        => 'eiai.inventory_item_id'
       ,p_pk2_alias        => 'eiai.organization_id'
       ,p_pk3_alias        => NULL
       ,p_pk4_alias        => NULL
       ,p_pk5_alias        => NULL
       ,x_predicate        => l_sec_predicate
       ,x_return_status    => x_return_status );
    IF x_return_status IN ('T','F') THEN
      IF l_sec_predicate IS NOT NULL THEN
        l_dynamic_sql :=
           ' UPDATE ego_item_associations_intf eiai ' ||
           ' SET process_flag = '||G_REC_NO_EDIT_ASSOC_PRIV ||
           ' WHERE batch_id = :p_batch_id '||
           ' AND process_flag = '||G_REC_IN_PROCESS||
           ' AND eiai.created_by <> '||G_SKIP_SECURIY_CHECK||
           ' AND ( transaction_type = '''||G_UPDATE||''' OR transaction_type = '''||G_DELETE||''' )'||
           ' AND NOT '|| l_sec_predicate;
        EXECUTE IMMEDIATE l_dynamic_sql
        USING IN p_batch_id;
      END IF;
    ELSE
      l_msg_data := FND_MESSAGE.GET_ENCODED();
      fnd_message.set_name ('EGO', 'EGO_PLSQL_ERR');
      fnd_message.set_token ('PKG_NAME', G_PKG_NAME);
      fnd_message.set_token ('API_NAME', 'check_security');
      fnd_message.set_token ('SQL_ERR_MSG', l_msg_data);
      APP_EXCEPTION.RAISE_EXCEPTION();
    END IF;
    EGO_DATA_SECURITY.get_security_predicate
       (p_api_version      => 1.0
       ,p_function         => l_item_org_edit_priv
       ,p_object_name      => 'EGO_ITEM'
       ,p_user_name        => 'HZ_PARTY:'||TO_CHAR(G_PARTY_ID)
       ,p_statement_type   => 'EXISTS'
       ,p_pk1_alias        => 'eiai.inventory_item_id'
       ,p_pk2_alias        => 'eiai.organization_id'
       ,p_pk3_alias        => NULL
       ,p_pk4_alias        => NULL
       ,p_pk5_alias        => NULL
       ,x_predicate        => l_sec_predicate
       ,x_return_status    => x_return_status );
    IF x_return_status IN ('T','F') THEN
      IF l_sec_predicate IS NOT NULL THEN
        l_dynamic_sql :=
           ' UPDATE ego_item_associations_intf eiai ' ||
           ' SET process_flag = '||G_REC_NO_EDIT_ITEM_ORG_PRIV ||
           ' WHERE batch_id = :p_batch_id '||
           ' AND data_level_id = 43105 '||
           ' AND process_flag = '||G_REC_IN_PROCESS||
           ' AND eiai.created_by <> '||G_SKIP_SECURIY_CHECK||
           ' AND ( transaction_type = '''||G_UPDATE||''' OR transaction_type = '''||G_DELETE||''' )'||
           ' AND NOT '|| l_sec_predicate;
        EXECUTE IMMEDIATE l_dynamic_sql
        USING IN p_batch_id;
     END IF;
    ELSE
      l_msg_data := FND_MESSAGE.GET_ENCODED();
      fnd_message.set_name ('EGO', 'EGO_PLSQL_ERR');
      fnd_message.set_token ('PKG_NAME', G_PKG_NAME);
      fnd_message.set_token ('API_NAME', 'check_security');
      fnd_message.set_token ('SQL_ERR_MSG', l_msg_data);
      APP_EXCEPTION.RAISE_EXCEPTION();
    END IF;

    IF ego_item_associations_util.is_supplier_contact(G_PARTY_ID) = FND_API.G_TRUE THEN
        UPDATE ego_item_associations_intf eiai
           SET process_flag = G_REC_NO_SUPPL_ACCESS_PRIV
         WHERE eiai.batch_id = p_batch_id
           AND eiai.process_flag = G_REC_IN_PROCESS
           AND NOT EXISTS
               (
                 SELECT 1
                   FROM ego_vendor_v evv
                  WHERE evv.vendor_id = eiai.pk1_value
                    AND evv.user_id = G_USER_ID
               );
    END IF;
  END check_security;

  /*
  -- Start of comments
  --  API name    : validate_associations
  --  Type        : Private.
  --  Function    : Validates associaitons based on association type.
  --  Pre-reqs    : None.
  --  Parameters  :
  --  IN          : p_batch_id          IN NUMBER   Required
  --  Version     : Initial version     1.0
  --  Notes       : Validates associaitons based on association type.
  --                Check whether already exists
  --                Check whether site exists for the supplier
  --                Check whether Primary is active
  --                Check whether site already assigned for item-site-org
  --                Check whether item is assigned in org
  --                Check whether duplicate primary in the same batch
  --                Set other primary to 'N'
  -- End of comments
  */
  PROCEDURE validate_associations(p_batch_id IN NUMBER)
  IS
  BEGIN
    UPDATE ego_item_associations_intf eiai
       SET process_flag = G_REC_ORG_NO_ACCESS
     WHERE eiai.batch_id = p_batch_id
       AND eiai.process_flag = G_REC_IN_PROCESS
       AND NOT EXISTS
       (
         SELECT 1
           FROM org_access_view oav
          WHERE oav.organization_id = eiai.organization_id
            AND oav.responsibility_id = FND_PROFILE.Value('RESP_ID')
            AND oav.resp_application_id = FND_PROFILE.Value('RESP_APPL_ID')
       );
    UPDATE ego_item_associations_intf eiai
       SET process_flag = G_REC_ALREADY_ASSIGNED
     WHERE eiai.batch_id = p_batch_id
       AND eiai.process_flag = G_REC_IN_PROCESS
       AND eiai.transaction_type = G_CREATE
       AND EXISTS
       (
          SELECT 1
            FROM ego_item_associations eia
           WHERE eia.inventory_item_id = eiai.inventory_item_id
             AND eia.organization_id = eiai.organization_id
             AND eia.data_level_id = eiai.data_level_id
             AND eia.pk1_value = eiai.pk1_value
             AND ( ( eia.pk2_value IS NULL AND eiai.pk2_value IS NULL )
                  OR ( eia.pk2_value = eiai.pk2_value )
                  )
        );
    UPDATE ego_item_associations_intf eiai
       SET process_flag = G_REC_ASSOC_SITE_NOT_EXISTS
     WHERE eiai.batch_id = p_batch_id
       AND eiai.process_flag = G_REC_IN_PROCESS
       AND eiai.transaction_type = G_CREATE
       AND NOT EXISTS
       (
          SELECT 1
            FROM ap_supplier_sites_all assa
           WHERE assa.vendor_id = eiai.pk1_value
             AND assa.org_id = fnd_profile.value('ORG_ID')
             AND nvl(assa.inactive_date,SYSDATE + 1)>SYSDATE --BUG11072046
        );
    UPDATE ego_item_associations_intf eiai
       SET process_flag = G_REC_ASSOC_ITEM_NOT_IN_ORG
     WHERE eiai.batch_id = p_batch_id
       AND eiai.process_flag = G_REC_IN_PROCESS
       AND eiai.data_level_id = G_ITEM_SUPPLIERSITE_ORG_LEVEL
       AND eiai.transaction_type = G_CREATE
       AND NOT EXISTS
       (
         SELECT 1
           FROM mtl_system_items_b_kfv msibk
          WHERE msibk.inventory_item_id = eiai.inventory_item_id
            AND msibk.organization_id = eiai.organization_id
       );
    -- Primary has been set in Create-Create or Create-Update or Update - Update
    /*
    UPDATE ego_item_associations_intf eiai
       SET process_flag = G_REC_DUPLICATE_PRIMARY
     WHERE eiai.batch_id = p_batch_id
       AND eiai.process_flag = G_REC_IN_PROCESS
       AND eiai.primary_flag = 'Y'
       AND ( eiai.transaction_type = G_CREATE OR eiai.transaction_type = G_UPDATE)
       AND exists
           (
             SELECT 1
               FROM ego_item_associations_intf eiai2
              WHERE eiai2.batch_id = eiai.batch_id
                AND eiai2.process_flag = eiai.process_flag
                AND eiai2.primary_flag = eiai.primary_flag
                AND eiai2.inventory_item_id = eiai.inventory_item_id
                AND eiai2.organization_id = eiai.organization_id
                AND eiai2.data_level_id = eiai.data_level_id
                AND eiai2.pk1_value = eiai.pk1_value
                AND NVL(eiai2.pk2_value,-1) = NVL(eiai.pk2_value,-1)
                AND ( eiai2.transaction_type = G_CREATE OR eiai2.transaction_type = G_UPDATE )
                AND eiai2.ROWID <> eiai.ROWID
           );
    */
    -- If more than one row have primary flag set, then unset for all other records
    -- except the last one (mode CREATE)
    UPDATE ego_item_associations_intf eiai
       SET eiai.primary_flag = G_DEFAULT_PRIMARY_FLAG
     WHERE eiai.batch_id = p_batch_id
       AND eiai.process_flag = G_REC_IN_PROCESS
       AND eiai.data_level_id = G_ITEM_SUPPLIER_LEVEL
       AND eiai.transaction_type = G_CREATE
       AND eiai.ROWID NOT IN
           (
             SELECT MAX(eiai2.ROWID)
               FROM ego_item_associations_intf eiai2
              WHERE eiai2.batch_id = p_batch_id
                AND eiai2.process_flag = G_REC_IN_PROCESS
                AND eiai2.primary_flag = G_PRIMARY
                AND eiai2.transaction_type = G_CREATE
                AND eiai2.data_level_id = G_ITEM_SUPPLIER_LEVEL
              GROUP BY eiai2.inventory_item_id, eiai2.organization_id
             HAVING count(*) >= 1
           );
    UPDATE ego_item_associations_intf eiai
       SET eiai.primary_flag = G_DEFAULT_PRIMARY_FLAG
     WHERE eiai.batch_id = p_batch_id
       AND eiai.process_flag = G_REC_IN_PROCESS
       AND eiai.data_level_id = G_ITEM_SUPPLIERSITE_LEVEL
       AND eiai.transaction_type = G_CREATE
       AND eiai.ROWID NOT IN
           (
             SELECT MAX(eiai2.ROWID)
               FROM ego_item_associations_intf eiai2
              WHERE eiai2.batch_id = p_batch_id
                AND eiai2.process_flag = G_REC_IN_PROCESS
                AND eiai2.primary_flag = G_PRIMARY
                AND eiai2.transaction_type = G_CREATE
                AND eiai2.data_level_id = G_ITEM_SUPPLIERSITE_LEVEL
              GROUP BY eiai2.inventory_item_id, eiai2.organization_id, eiai2.pk1_value
             HAVING count(*) >= 1
           );

    -- If more than one row have primary flag set, then unset for all other records
    -- except the last one (mode UPDATE)
    UPDATE ego_item_associations_intf eiai
       SET eiai.primary_flag = G_DEFAULT_PRIMARY_FLAG
     WHERE eiai.batch_id = p_batch_id
       AND eiai.process_flag = G_REC_IN_PROCESS
       AND eiai.data_level_id = G_ITEM_SUPPLIER_LEVEL
       AND eiai.transaction_type = G_UPDATE
       AND eiai.ROWID NOT IN
           (
             SELECT MAX(eiai2.ROWID)
               FROM ego_item_associations_intf eiai2
              WHERE eiai2.batch_id = p_batch_id
                AND eiai2.process_flag = G_REC_IN_PROCESS
                AND eiai2.primary_flag = G_PRIMARY
                AND eiai2.transaction_type = G_UPDATE
                AND eiai2.data_level_id = G_ITEM_SUPPLIER_LEVEL
              GROUP BY eiai2.inventory_item_id, eiai2.organization_id
             HAVING count(*) >= 1
           )
       AND eiai.primary_flag = G_PRIMARY; -- fix for bug#8995869

    UPDATE ego_item_associations_intf eiai
       SET eiai.primary_flag = G_DEFAULT_PRIMARY_FLAG
     WHERE eiai.batch_id = p_batch_id
       AND eiai.process_flag = G_REC_IN_PROCESS
       AND eiai.data_level_id = G_ITEM_SUPPLIERSITE_LEVEL
       AND eiai.transaction_type = G_UPDATE
       AND eiai.ROWID NOT IN
           (
             SELECT MAX(eiai2.ROWID)
               FROM ego_item_associations_intf eiai2
              WHERE eiai2.batch_id = p_batch_id
                AND eiai2.process_flag = G_REC_IN_PROCESS
                AND eiai2.primary_flag = G_PRIMARY
                AND eiai2.transaction_type = G_UPDATE
                AND eiai2.data_level_id = G_ITEM_SUPPLIERSITE_LEVEL
              GROUP BY eiai2.inventory_item_id, eiai2.organization_id, eiai2.pk1_value
             HAVING count(*) >= 1
           )
       AND eiai.primary_flag = G_PRIMARY; -- fix for bug#8995869


    -- If the both CREATE and UPDATE has primary flag set then unset for CREATE operations
    -- because UPDATE is the last operation to be performed
    UPDATE ego_item_associations_intf eiai
       SET eiai.primary_flag = G_DEFAULT_PRIMARY_FLAG
     WHERE eiai.batch_id = p_batch_id
       AND eiai.process_flag = G_REC_IN_PROCESS
       AND eiai.data_level_id = G_ITEM_SUPPLIER_LEVEL
       AND eiai.transaction_type = G_CREATE
       AND EXISTS
           (
             SELECT 1
               FROM ego_item_associations_intf eiai2
              WHERE eiai2.batch_id = p_batch_id
                AND eiai2.process_flag = G_REC_IN_PROCESS
                AND eiai2.inventory_item_id = eiai.inventory_item_id
                AND eiai2.organization_id = eiai.organization_id
                AND eiai2.data_level_id = G_ITEM_SUPPLIER_LEVEL
                AND eiai2.primary_flag = G_PRIMARY
                AND eiai2.transaction_type = G_UPDATE
           );

    UPDATE ego_item_associations_intf eiai
       SET eiai.primary_flag = G_DEFAULT_PRIMARY_FLAG
     WHERE eiai.batch_id = p_batch_id
       AND eiai.process_flag = G_REC_IN_PROCESS
       AND eiai.data_level_id = G_ITEM_SUPPLIERSITE_LEVEL
       AND eiai.transaction_type = G_CREATE
       AND EXISTS
           (
             SELECT 1
               FROM ego_item_associations_intf eiai2
              WHERE eiai2.batch_id = p_batch_id
                AND eiai2.process_flag = G_REC_IN_PROCESS
                AND eiai2.inventory_item_id = eiai.inventory_item_id
                AND eiai2.organization_id = eiai.organization_id
                AND eiai2.data_level_id = G_ITEM_SUPPLIERSITE_LEVEL
                AND eiai2.pk1_value = eiai.pk1_value
                AND eiai2.primary_flag = G_PRIMARY
                AND eiai2.transaction_type = G_UPDATE
           );

    UPDATE ego_item_associations eia
       SET primary_flag = G_DEFAULT_PRIMARY_FLAG
     WHERE primary_flag = G_PRIMARY
       AND eia.data_level_id = G_ITEM_SUPPLIER_LEVEL
       AND EXISTS
           ( SELECT 1
               FROM ego_item_associations_intf eiai
              WHERE eiai.inventory_item_id = eia.inventory_item_id
                AND eiai.organization_id = eia.organization_id
                AND eiai.batch_id = p_batch_id
                AND eiai.process_flag = G_REC_IN_PROCESS
                AND eiai.primary_flag = G_PRIMARY
                AND eiai.transaction_type IN (G_CREATE, G_UPDATE)
                AND eiai.data_level_id = eia.data_level_id
            )
       AND NOT EXISTS
           ( SELECT 1
               FROM ego_item_associations_intf eiai
              WHERE eiai.inventory_item_id = eia.inventory_item_id
                AND eiai.organization_id = eia.organization_id
                AND eiai.pk1_value = eia.pk1_value
                AND eiai.batch_id = p_batch_id
                AND eiai.process_flag = G_REC_IN_PROCESS
                AND eiai.primary_flag = G_PRIMARY
                AND eiai.transaction_type IN (G_CREATE, G_UPDATE)
                AND eiai.data_level_id = eia.data_level_id
            );
--       Bug 6931470: fix performance issue, using EXIST and IN to substitute UNION operation
--       AND EXISTS
--           ( SELECT 1
--               FROM ego_item_associations_intf eiai
--              WHERE eiai.inventory_item_id = eia.inventory_item_id
--                AND eiai.organization_id = eia.organization_id
--                AND eiai.pk1_value <> eia.pk1_value
--                AND eiai.batch_id = p_batch_id
--                AND eiai.process_flag = G_REC_IN_PROCESS
--                AND eiai.primary_flag = G_PRIMARY
--                AND eiai.transaction_type = G_UPDATE
--                AND eiai.data_level_id = eia.data_level_id
--             UNION ALL
--             SELECT 1
--               FROM ego_item_associations_intf eiai
--              WHERE eiai.inventory_item_id = eia.inventory_item_id
--                AND eiai.organization_id = eia.organization_id
--                AND eiai.pk1_value <> eia.pk1_value
--                AND eiai.batch_id = p_batch_id
--                AND eiai.process_flag = G_REC_IN_PROCESS
--                AND eiai.primary_flag = G_PRIMARY
--                AND eiai.transaction_type = G_CREATE
--                AND eiai.data_level_id = eia.data_level_id
--            );
    UPDATE ego_item_associations eia
       SET primary_flag = G_DEFAULT_PRIMARY_FLAG
     WHERE eia.primary_flag = G_PRIMARY
       AND eia.data_level_id = G_ITEM_SUPPLIERSITE_LEVEL
       AND EXISTS
           ( SELECT 1
               FROM ego_item_associations_intf eiai
              WHERE eiai.inventory_item_id = eia.inventory_item_id
                AND eiai.organization_id = eia.organization_id
                AND eiai.pk1_value = eia.pk1_value
                AND eiai.batch_id = p_batch_id
                AND eiai.process_flag = G_REC_IN_PROCESS
                AND eiai.primary_flag = G_PRIMARY
                AND eiai.transaction_type IN (G_CREATE, G_UPDATE)
                AND eiai.data_level_id = eia.data_level_id
            )
       AND NOT EXISTS
           ( SELECT 1
               FROM ego_item_associations_intf eiai
              WHERE eiai.inventory_item_id = eia.inventory_item_id
                AND eiai.organization_id = eia.organization_id
                AND eiai.pk1_value = eia.pk1_value
                AND eiai.pk2_value = eia.pk2_value
                AND eiai.batch_id = p_batch_id
                AND eiai.process_flag = G_REC_IN_PROCESS
                AND eiai.primary_flag = G_PRIMARY
                AND eiai.transaction_type IN (G_CREATE, G_UPDATE)
                AND eiai.data_level_id = eia.data_level_id
            );
--       Bug 6931470: fix performance issue, using EXIST and IN to substitute UNION operation
--       AND EXISTS
--           ( SELECT 1
--               FROM ego_item_associations_intf eiai
--              WHERE eiai.inventory_item_id = eia.inventory_item_id
--                AND eiai.organization_id = eia.organization_id
--                AND eiai.pk1_value = eia.pk1_value
--                AND eiai.pk2_value <> eia.pk2_value
--                AND eiai.batch_id = p_batch_id
--                AND eiai.process_flag = G_REC_IN_PROCESS
--                AND eiai.primary_flag = G_PRIMARY
--                AND eiai.transaction_type = G_UPDATE
--                AND eiai.data_level_id = eia.data_level_id
--             UNION ALL
--             SELECT 1
--               FROM ego_item_associations_intf eiai
--              WHERE eiai.inventory_item_id = eia.inventory_item_id
--                AND eiai.organization_id = eia.organization_id
--                AND eiai.pk1_value = eia.pk1_value
--                AND eiai.pk2_value <> eia.pk2_value
--                AND eiai.batch_id = p_batch_id
--                AND eiai.process_flag = G_REC_IN_PROCESS
--                AND eiai.primary_flag = G_PRIMARY
--                AND eiai.transaction_type = G_CREATE
--                AND eiai.data_level_id = eia.data_level_id
--            );
    UPDATE ego_item_associations_intf eiai
       SET process_flag = G_REC_PRIMARY_NOT_ACTIVE
     WHERE eiai.batch_id = p_batch_id
       AND eiai.process_flag = G_REC_IN_PROCESS
       AND ( eiai.data_level_id = G_ITEM_SUPPLIER_LEVEL OR eiai.data_level_id = G_ITEM_SUPPLIERSITE_LEVEL )
       AND ( eiai.transaction_type = G_CREATE OR eiai.transaction_type = G_UPDATE )
       AND ( ( eiai.primary_flag = G_PRIMARY
             AND (( eiai.status_code <> G_ACTIVE
                    AND eiai.status_code IS NOT NULL ) -- Both attrs are from interface
             OR EXISTS (SELECT 1                       -- Primary flag is being updated and Staus inactive in prod
                           FROM ego_item_associations eia
                          WHERE eia.inventory_item_id = eiai.inventory_item_id
                            AND eia.organization_id = eiai.organization_id
                            AND eia.data_level_id = eiai.data_level_id
                            AND eia.pk1_value = eiai.pk1_value
                            AND NVL(eia.pk2_value,-1) = NVL(eiai.pk2_value,-1)
                            AND eiai.status_code IS NULL
                            AND eia.status_code <> G_ACTIVE
                        )
                 )
            )
            OR EXISTS -- Status being updated and primary flag is set in prod
              (
                SELECT 1
                  FROM ego_item_associations eia
                 WHERE eia.inventory_item_id = eiai.inventory_item_id
                   AND eia.organization_id = eiai.organization_id
                   AND eia.data_level_id = eiai.data_level_id
                   AND eia.pk1_value = eiai.pk1_value
                   AND NVL(eia.pk2_value,-1) = NVL(eiai.pk2_value,-1)
                   AND eiai.primary_flag IS NULL
                   AND eiai.status_code <> G_ACTIVE
                   AND eia.primary_flag = G_PRIMARY
              )
           );
    UPDATE ego_item_associations_intf eiai
       SET process_flag = G_REC_PARENT_NOT_ACTIVE
     WHERE eiai.batch_id = p_batch_id
       AND eiai.process_flag = G_REC_IN_PROCESS
       AND eiai.status_code = G_ACTIVE
       AND eiai.data_level_id = G_ITEM_SUPPLIERSITE_LEVEL
       AND NOT EXISTS
           (
             SELECT 1
               FROM ego_item_associations eia
              WHERE eia.data_level_id = G_ITEM_SUPPLIER_LEVEL
                AND eia.inventory_item_id = eiai.inventory_item_id
                AND eia.organization_id = eiai.organization_id
                AND eia.pk1_value = eiai.pk1_value
                AND eia.status_code = G_ACTIVE
              UNION ALL
             SELECT 1
               FROM ego_item_associations_intf eiai2
              WHERE eiai2.data_level_id = G_ITEM_SUPPLIER_LEVEL
                AND eiai2.inventory_item_id = eiai.inventory_item_id
                AND eiai2.organization_id = eiai.organization_id
                AND eiai2.pk1_value = eiai.pk1_value
                AND eiai2.batch_id = p_batch_id
                AND eiai2.process_flag = G_REC_IN_PROCESS
                AND eiai2.status_code = G_ACTIVE
           );
    UPDATE ego_item_associations_intf eiai
       SET process_flag = G_REC_PARENT_NOT_ACTIVE
     WHERE eiai.batch_id = p_batch_id
       AND eiai.process_flag = G_REC_IN_PROCESS
       AND eiai.status_code = G_ACTIVE
       AND eiai.data_level_id = G_ITEM_SUPPLIERSITE_ORG_LEVEL
       AND NOT EXISTS
           (
             SELECT 1
               FROM ego_item_associations eia, mtl_parameters mp
              WHERE eia.data_level_id = G_ITEM_SUPPLIERSITE_LEVEL
                AND eia.inventory_item_id = eiai.inventory_item_id
                AND eia.organization_id = mp.master_organization_id
                AND mp.organization_id = eiai.organization_id
                AND eia.pk1_value = eiai.pk1_value
                AND eia.pk2_value = eiai.pk2_value
                AND eia.status_code = G_ACTIVE
             UNION ALL
             SELECT 1
               FROM ego_item_associations_intf eiai2, mtl_parameters mp
              WHERE eiai2.data_level_id = G_ITEM_SUPPLIERSITE_LEVEL
                AND eiai2.inventory_item_id = eiai.inventory_item_id
                AND eiai2.organization_id = mp.master_organization_id
                AND mp.organization_id = eiai.organization_id
                AND eiai2.pk1_value = eiai.pk1_value
                AND eiai2.pk2_value = eiai.pk2_value
                AND eiai2.batch_id = p_batch_id
                AND eiai2.process_flag = G_REC_IN_PROCESS -- Means there is no validation error
                AND eiai2.status_code = G_ACTIVE
           );
      UPDATE ego_item_associations_intf eiai
       SET process_flag = G_REC_SUPPLIER_NOT_ASSIGNED
     WHERE eiai.batch_id = p_batch_id
       AND eiai.process_flag = G_REC_IN_PROCESS
       AND eiai.data_level_id = G_ITEM_SUPPLIERSITE_LEVEL
       AND eiai.transaction_type = G_CREATE
       AND NOT EXISTS
       (
         SELECT 1
           FROM ego_item_associations eia, mtl_parameters mp
          WHERE eia.inventory_item_id = eiai.inventory_item_id
            AND eia.organization_id = mp.master_organization_id
            AND mp.organization_id = eiai.organization_id
            AND eia.data_level_id = G_ITEM_SUPPLIER_LEVEL
            AND eia.pk1_value = eiai.pk1_value
            AND eia.pk2_value IS NULL
         UNION ALL
         SELECT 1
           FROM ego_item_associations_intf eiai1, mtl_parameters mp
          WHERE eiai1.inventory_item_id = eiai.inventory_item_id
            AND eiai1.organization_id = mp.master_organization_id
            AND mp.organization_id = eiai.organization_id
            AND eiai1.data_level_id = G_ITEM_SUPPLIER_LEVEL
            AND eiai1.pk1_value = eiai.pk1_value
            AND eiai1.pk2_value IS NULL
            AND eiai1.process_flag = G_REC_IN_PROCESS -- means there is not validation error
      AND eiai1.batch_id = p_batch_id     -- BUG 6322084
      AND eiai1.transaction_type = G_CREATE   -- BUG 6322084
       );
    UPDATE ego_item_associations_intf eiai
       SET process_flag = G_REC_SITE_NOT_ASSIGNED
     WHERE eiai.batch_id = p_batch_id
       AND eiai.process_flag = G_REC_IN_PROCESS
       AND eiai.data_level_id = G_ITEM_SUPPLIERSITE_ORG_LEVEL
       AND eiai.transaction_type = G_CREATE
       AND NOT EXISTS
       (
         SELECT 1
           FROM ego_item_associations eia, mtl_parameters mp
          WHERE eia.inventory_item_id = eiai.inventory_item_id
            AND eia.organization_id = mp.master_organization_id
            AND mp.organization_id = eiai.organization_id
            AND eia.data_level_id = G_ITEM_SUPPLIERSITE_LEVEL
            AND eia.pk1_value = eiai.pk1_value
            AND eia.pk2_value = eiai.pk2_value
         UNION ALL
         SELECT 1
           FROM ego_item_associations_intf eiai1, mtl_parameters mp
          WHERE eiai1.inventory_item_id = eiai.inventory_item_id
            AND eiai1.organization_id = mp.master_organization_id
            AND mp.organization_id = eiai.organization_id
            AND eiai1.data_level_id = G_ITEM_SUPPLIERSITE_LEVEL
            AND eiai1.pk1_value = eiai.pk1_value
            AND eiai1.pk2_value = eiai.pk2_value
            AND eiai1.process_flag = G_REC_IN_PROCESS -- means there is not validation error
      AND eiai1.batch_id = p_batch_id     -- BUG 6322084
      AND eiai1.transaction_type = G_CREATE   -- BUG 6322084
       );
END validate_associations;

  /*
  -- Start of comments
  --  API name    : perform_delete
  --  Type        : Private.
  --  Function    : Performs Delete for 'DELETE' transaction type records.
  --  Pre-reqs    : None.
  --  Parameters  :
  --  IN          : p_batch_id          IN NUMBER   Required
  --  Version     : Initial version     1.0
  --  Notes       : Performs Delete for 'DELETE' transaction type records.
  --                delete item-site-org with delete
  --                delete item-site-org associated with sites
  --                delete item-site-org associated with supplier
  --                delete item-site with delete
  --                delete item-site associated with supplier
  --                delete item-supplier with delete
  -- End of comments
  */
  PROCEDURE perform_delete(p_batch_id IN NUMBER)
  IS
  BEGIN
    -- Delete Item-Site-Org
    DELETE
      FROM ego_item_associations eia
     WHERE eia.data_level_id = G_ITEM_SUPPLIERSITE_ORG_LEVEL
       AND EXISTS
           (
              SELECT 1
                FROM ego_item_associations_intf eiai
               WHERE eiai.association_id = eia.association_id
                 AND eiai.batch_id = p_batch_id
                 AND eiai.process_flag = G_REC_IN_PROCESS
                 AND eiai.transaction_type = G_DELETE
                 AND eiai.data_level_id = G_ITEM_SUPPLIERSITE_ORG_LEVEL
            );
    -- Delete Item-Site-Org associated with Sites
    DELETE
      FROM ego_item_associations eia
     WHERE eia.data_level_id = G_ITEM_SUPPLIERSITE_ORG_LEVEL
       AND EXISTS
           (
              SELECT 1
                FROM ego_item_associations_intf eiai, mtl_parameters mp
               WHERE eiai.inventory_item_id = eia.inventory_item_id
                 AND eiai.batch_id = p_batch_id
                 AND eiai.process_flag = G_REC_IN_PROCESS
                 AND eiai.organization_id = mp.master_organization_id
                 AND mp.organization_id = eia.organization_id
                 AND eiai.pk1_value = eia.pk1_value
                 AND eiai.pk2_value = eia.pk2_value
                 AND eiai.data_level_id = G_ITEM_SUPPLIERSITE_LEVEL
                 AND eiai.transaction_type = G_DELETE
            );
    -- Delete Item-Site-Org associations with sites of supplier
    DELETE
      FROM ego_item_associations eia
     WHERE eia.data_level_id = G_ITEM_SUPPLIERSITE_ORG_LEVEL
       AND EXISTS
           (
              SELECT 1
                FROM ego_item_associations_intf eiai, mtl_parameters mp
               WHERE eiai.inventory_item_id = eia.inventory_item_id
                 AND eiai.batch_id = p_batch_id
                 AND eiai.process_flag = G_REC_IN_PROCESS
                 AND eiai.organization_id = mp.master_organization_id
                 AND mp.organization_id = eia.organization_id
                 AND eiai.pk1_value = eia.pk1_value
                 AND eiai.data_level_id = G_ITEM_SUPPLIER_LEVEL
                 AND eiai.transaction_type = G_DELETE
            );
    DELETE
      FROM ego_item_associations eia
     WHERE eia.data_level_id = G_ITEM_SUPPLIERSITE_LEVEL
       AND EXISTS
           (
              SELECT 1
                FROM ego_item_associations_intf eiai, mtl_parameters mp
               WHERE eiai.association_id = eia.association_id
                 AND eiai.batch_id = p_batch_id
                 AND eiai.process_flag = G_REC_IN_PROCESS
                 AND eiai.organization_id = mp.master_organization_id
                 AND mp.organization_id = eia.organization_id
                 AND eiai.pk1_value = eia.pk1_value
                 AND eiai.data_level_id = G_ITEM_SUPPLIERSITE_LEVEL
                 AND eiai.transaction_type = G_DELETE
            );
    DELETE
      FROM ego_item_associations eia
     WHERE eia.data_level_id = G_ITEM_SUPPLIERSITE_LEVEL
       AND EXISTS
           (
              SELECT 1
                FROM ego_item_associations_intf eiai, mtl_parameters mp
               WHERE eiai.inventory_item_id = eia.inventory_item_id
                 AND eiai.batch_id = p_batch_id
                 AND eiai.process_flag = G_REC_IN_PROCESS
                 AND eiai.organization_id = mp.master_organization_id
                 AND mp.organization_id = eia.organization_id
                 AND eiai.pk1_value = eia.pk1_value
                 AND eiai.data_level_id = G_ITEM_SUPPLIER_LEVEL
                 AND eiai.transaction_type = G_DELETE
            );
    DELETE
      FROM ego_item_associations eia
     WHERE EXISTS
           (
              SELECT 1
                FROM ego_item_associations_intf eiai
               WHERE eiai.association_id = eia.association_id
                 AND eiai.batch_id = p_batch_id
                 AND eiai.process_flag = G_REC_IN_PROCESS
                 AND eiai.data_level_id = G_ITEM_SUPPLIER_LEVEL
                 AND eiai.transaction_type = G_DELETE
            );
  END perform_delete;

  /*
  -- Start of comments
  --  API name    : perform_create
  --  Type        : Private.
  --  Function    : Performs create for 'CREATE' transaction type records.
  --  Pre-reqs    : None.
  --  Parameters  :
  --  IN          : p_batch_id          IN NUMBER   Required
  --  Version     : Initial version     1.0
  --  Notes       : Performs create for 'CREATE' transaction type records.
  --                insert from interface table which has process_flag as in process
  -- End of comments
  */
  PROCEDURE perform_create (p_batch_id IN NUMBER )
  IS
  BEGIN
    INSERT INTO
    ego_item_associations
    (
      association_id,
      organization_id,
      inventory_item_id,
      pk1_value,
      pk2_value,
      data_level_id,
      status_code,
      primary_flag,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      last_update_login,
      request_id,
      program_application_id,
      program_id,
      program_update_date
    )
    SELECT ego_item_associations_s.NEXTVAL,
           eiai.organization_id,
           eiai.inventory_item_id,
           eiai.pk1_value,
           CASE
             WHEN eiai.data_level_id = G_ITEM_SUPPLIER_LEVEL THEN
               NULL
             ELSE
               eiai.pk2_value
           END AS pk2_value,
           eiai.data_level_id,
           NVL(eiai.status_code,G_DEFAULT_STATUS_CODE),
           CASE
             WHEN eiai.data_level_id = G_ITEM_SUPPLIERSITE_ORG_LEVEL THEN
               NULL
             ELSE
               NVL(eiai.primary_flag,G_DEFAULT_PRIMARY_FLAG)
           END AS primary_flag,
           G_USER_ID,
           G_SYSDATE,
           G_USER_ID,
           G_SYSDATE,
           G_LOGIN_ID,
           G_REQUEST_ID,
           G_PROG_APPID,
           G_PROG_ID,
           G_SYSDATE
      FROM ego_item_associations_intf eiai
     WHERE eiai.batch_id = p_batch_id
       AND eiai.process_flag = G_REC_IN_PROCESS
       AND eiai.transaction_type = G_CREATE
       AND NOT EXISTS
           (
             SELECT 1
               FROM ego_item_associations eia1
              WHERE eia1.inventory_item_id = eiai.inventory_item_id
                AND eia1.organization_id = eiai.organization_id
                AND eia1.data_level_id = eiai.data_level_id
                AND eia1.pk1_value = eiai.pk1_value
                AND NVL(eia1.pk2_value,-1) = NVL(eiai.pk2_value,-1)
           );

  END perform_create;

  /*
  -- Start of comments
  --  API name    : perform_update
  --  Type        : Private.
  --  Function    : Performs update for 'UPDATE' transaction type records.
  --  Pre-reqs    : None.
  --  Parameters  :
  --  IN          : p_batch_id          IN NUMBER   Required
  --  Version     : Initial version     1.0
  --  Notes       : Performs update for 'UPDATE' transaction type records.
  --                update primary flag and status code with who columns
  -- End of comments
  */
  PROCEDURE perform_update ( p_batch_id IN NUMBER )
  IS
  BEGIN
    UPDATE ego_item_associations eia
       SET (primary_flag, status_code, last_updated_by, last_update_date, last_update_login, request_id) =
                         ( SELECT NVL(eiai.primary_flag, eia.primary_flag)
                                  ,NVL(eiai.status_code, eia.status_code)
                                  ,G_USER_ID
                                  ,G_SYSDATE
                                  ,G_LOGIN_ID
                                  ,G_REQUEST_ID
                                 FROM ego_item_associations_intf eiai
                                WHERE eiai.association_id = eia.association_id
                                  AND eiai.batch_id = p_batch_id
                                  AND eiai.process_flag = G_REC_IN_PROCESS
                                  AND eiai.transaction_type = G_UPDATE
                                  AND ROWNUM = 1
                          )
     WHERE EXISTS
           (
             SELECT 1
               FROM ego_item_associations_intf eiai
              WHERE eiai.batch_id = p_batch_id
                AND eiai.process_flag = G_REC_IN_PROCESS
                AND eiai.association_id = eia.association_id
                AND eiai.transaction_type = G_UPDATE
            );
    -- Update the status to child associations
    UPDATE ego_item_associations eia
       SET (status_code, primary_flag, last_updated_by, last_update_date, last_update_login, request_id) =
                         ( SELECT eiai.status_code
                                  ,G_DEFAULT_PRIMARY_FLAG
                                  ,G_USER_ID
                                  ,G_SYSDATE
                                  ,G_LOGIN_ID
                                  ,G_REQUEST_ID
                                 FROM ego_item_associations_intf eiai
                                WHERE eiai.inventory_item_id = eia.inventory_item_id
                                  AND eiai.organization_id = eia.organization_id
                                  AND eiai.data_level_id = G_ITEM_SUPPLIER_LEVEL
                                  AND eiai.pk1_value = eia.pk1_value
                                  AND eiai.batch_id = p_batch_id
                                  AND eiai.process_flag = G_REC_IN_PROCESS
                                  AND ROWNUM = 1
                          )
     WHERE EXISTS
           (
             SELECT 1
               FROM ego_item_associations_intf eiai
              WHERE eiai.inventory_item_id = eia.inventory_item_id
                AND eiai.organization_id = eia.organization_id
                AND eiai.data_level_id = G_ITEM_SUPPLIER_LEVEL
         --     AND eia.data_level_id = G_ITEM_SUPPLIERSITE_LEVEL -- Bug#6927009
                AND eiai.pk1_value = eia.pk1_value
                AND eiai.batch_id = p_batch_id
                AND eiai.process_flag = G_REC_IN_PROCESS
                AND eiai.status_code <> G_ACTIVE
            )
      AND eia.data_level_id = G_ITEM_SUPPLIERSITE_LEVEL;   --Bug#6927009
    UPDATE ego_item_associations eia
       SET (status_code, last_updated_by, last_update_date, last_update_login, request_id) =
                         ( SELECT eiai.status_code
                                  ,G_USER_ID
                                  ,G_SYSDATE
                                  ,G_LOGIN_ID
                                  ,G_REQUEST_ID
                                 FROM ego_item_associations_intf eiai, mtl_parameters mp
                                WHERE eiai.inventory_item_id = eia.inventory_item_id
                                  AND eiai.organization_id = mp.master_organization_id
                                  AND mp.organization_id = eia.organization_id
                                  AND eiai.data_level_id = G_ITEM_SUPPLIER_LEVEL
                                  AND eiai.pk1_value = eia.pk1_value
                                  AND eiai.batch_id = p_batch_id
                                  AND eiai.process_flag = G_REC_IN_PROCESS
                                  AND ROWNUM = 1
                          )
     WHERE EXISTS
           (
             SELECT 1
               FROM ego_item_associations_intf eiai, mtl_parameters mp
              WHERE eiai.inventory_item_id = eia.inventory_item_id
                AND eiai.organization_id = mp.master_organization_id
                AND eia.organization_id = mp.organization_id
                AND eiai.data_level_id = G_ITEM_SUPPLIER_LEVEL
        --      AND eia.data_level_id = G_ITEM_SUPPLIERSITE_ORG_LEVEL --Bug#6927009
                AND eiai.pk1_value = eia.pk1_value
                AND eiai.batch_id = p_batch_id
                AND eiai.process_flag = G_REC_IN_PROCESS
                AND eiai.status_code <> G_ACTIVE
            )
      AND eia.data_level_id = G_ITEM_SUPPLIERSITE_ORG_LEVEL;  --Bug#6927009

      UPDATE ego_item_associations eia
       SET (status_code, last_updated_by, last_update_date, last_update_login, request_id) =
                         ( SELECT eiai.status_code
                                  ,G_USER_ID
                                  ,G_SYSDATE
                                  ,G_LOGIN_ID
                                  ,G_REQUEST_ID
                                 FROM ego_item_associations_intf eiai, mtl_parameters mp
                                WHERE eiai.inventory_item_id = eia.inventory_item_id
                                  AND eiai.organization_id = mp.master_organization_id
                                  AND eia.organization_id = mp.organization_id
                                  AND eiai.data_level_id = G_ITEM_SUPPLIERSITE_LEVEL
                                  AND eiai.pk1_value = eia.pk1_value
                                  AND eiai.pk2_value = eia.pk2_value
                                  AND eiai.batch_id = p_batch_id
                                  AND eiai.process_flag = G_REC_IN_PROCESS
                                  AND ROWNUM = 1
                          )
     WHERE EXISTS
           (
             SELECT 1
               FROM ego_item_associations_intf eiai, mtl_parameters mp
              WHERE eiai.inventory_item_id = eia.inventory_item_id
                AND eiai.organization_id = mp.master_organization_id
                AND mp.organization_id = eia.organization_id
                AND eiai.data_level_id = G_ITEM_SUPPLIERSITE_LEVEL
--              AND eia.data_level_id = G_ITEM_SUPPLIERSITE_ORG_LEVEL  --Bug#6927009
                AND eiai.pk1_value = eia.pk1_value
                AND eiai.pk2_value = eia.pk2_value
                AND eiai.batch_id = p_batch_id
                AND eiai.process_flag = G_REC_IN_PROCESS
                AND eiai.status_code <> G_ACTIVE
            )
      AND eia.data_level_id = G_ITEM_SUPPLIERSITE_ORG_LEVEL;  --Bug#6927009
END perform_update;

  /*
  -- Start of comments
  --  API name    : insert_errors
  --  Type        : Private.
  --  Function    : Insert specific error messages for error records.
  --  Pre-reqs    : None.
  --  Parameters  :
  --  IN          : p_batch_id          IN NUMBER   Required
  --  Version     : Initial version     1.0
  --  Notes       : Insert specific error messages for error records.
  --                1. set the message names based on record status value
  --                2. insert the errors
  -- End of comments
  */
  PROCEDURE insert_errors (p_batch_id IN NUMBER)
  IS
    CURSOR l_err_rows_csr(p_batch_id IN NUMBER)
    IS
      SELECT process_flag, transaction_id, organization_id,
             CASE
              WHEN data_level_id IS NOT NULL
               THEN
                   (
                     SELECT user_data_level_name
                       FROM ego_data_level_tl edlt
                      WHERE edlt.data_level_id = eiai.data_level_id
                        AND edlt.language = USERENV('LANG')
                   )
              ELSE
                   (
                     SELECT user_data_level_name
                       FROM ego_data_level_vl eldt
                      WHERE eldt.application_id = 431
                        AND eldt.attr_group_type = 'EGO_ITEMMGMT_GROUP'
                        AND eldt.data_level_name = eiai.data_level_name
                   )
             END user_data_level_name,
             CASE
              WHEN supplier_name IS NOT NULL
               THEN supplier_name
              ELSE
               (
                 SELECT vendor_name
                   FROM ap_suppliers aas
                  WHERE aas.vendor_id = eiai.pk1_value
               )
             END AS supplier_name,
             CASE
              WHEN supplier_site_name IS NOT NULL
               THEN supplier_site_name
              ELSE
               (
                 SELECT vendor_site_code
                   FROM ap_supplier_sites_all assa
                  WHERE assa.vendor_site_id = eiai.pk2_value
               )
             END AS supplier_site_name,
             data_level_name
        FROM ego_item_associations_intf eiai
       WHERE eiai.batch_id = p_batch_id
         AND eiai.process_flag >= G_REC_MISSING_REQ_VALUE;
    l_err_msg VARCHAR2(2000);
  BEGIN
    FOR l_err_rec IN l_err_rows_csr(p_batch_id)
    LOOP
      IF l_err_rec.process_flag = G_REC_MISSING_REQ_VALUE THEN
        fnd_message.set_name('EGO','EGO_ASSOC_MISSING_REQ_VALUE');
      ELSIF l_err_rec.process_flag = G_REC_INVALID_TRAN_TYPE THEN
        fnd_message.set_name('EGO','EGO_ASSOC_INVALID_TRAN_TYPE');
      ELSIF l_err_rec.process_flag = G_REC_INVALID_MASTER_ORG THEN
        fnd_message.set_name('EGO','EGO_ASSOC_INVALID_MASTER_ORG');
      ELSIF l_err_rec.process_flag = G_REC_INVALID_ORG THEN
        fnd_message.set_name('EGO','EGO_ASSOC_INVALID_ORG');
      ELSIF l_err_rec.process_flag = G_REC_INVALID_ITEM THEN
        fnd_message.set_name('EGO','EGO_ASSOC_ITEM_NOT_IN_ORG');
      ELSIF l_err_rec.process_flag = G_REC_INVALID_PK1_VALUE THEN
        fnd_message.set_name('EGO','EGO_ASSOC_INVALID_PK1_VALUE');
      ELSIF l_err_rec.process_flag = G_REC_INVALID_PK2_VALUE THEN
        fnd_message.set_name('EGO','EGO_ASSOC_INVALID_PK2_VALUE');
      ELSIF l_err_rec.process_flag = G_REC_INVALID_ASSOC_TYPE THEN
        fnd_message.set_name('EGO','EGO_ASSOC_INVALID_ASSOC_TYPE');
      ELSIF l_err_rec.process_flag = G_REC_INVALID_STATUS THEN
        fnd_message.set_name('EGO','EGO_ASSOC_INVALID_STATUS');
      ELSIF l_err_rec.process_flag = G_REC_INVALID_PRIMARY THEN
        fnd_message.set_name('EGO','EGO_ASSOC_INVALID_PRIMARY');
      ELSIF l_err_rec.process_flag = G_REC_ASSOCIATION_NOT_EXISTS THEN
        fnd_message.set_name('EGO','EGO_ASSOC_NOT_EXISTS');
      ELSIF l_err_rec.process_flag = G_REC_ALREADY_ASSIGNED THEN
        fnd_message.set_name('EGO','EGO_ASSOC_ALREADY_ASSIGNED');
      ELSIF l_err_rec.process_flag = G_REC_ASSOC_SITE_NOT_EXISTS THEN
        fnd_message.set_name('EGO','EGO_ASSOC_INVALID_PK2_VALUE');
      ELSIF l_err_rec.process_flag = G_REC_ASSOC_ITEM_NOT_IN_ORG THEN
        fnd_message.set_name('EGO','EGO_ASSOC_ITEM_NOT_IN_ORG');
      ELSIF l_err_rec.process_flag = G_REC_PARENT_NOT_ASSIGNED THEN
        fnd_message.set_name('EGO','EGO_ASSOC_PARENT_NOT_ASSIGNED');
      ELSIF l_err_rec.process_flag = G_REC_PARENT_NOT_ACTIVE THEN
        fnd_message.set_name('EGO','EGO_ASSOC_PARENT_NOT_ACTIVE');
      ELSIF l_err_rec.process_flag = G_REC_PRIMARY_NOT_ACTIVE THEN
        fnd_message.set_name('EGO','EGO_ASSOC_PRIMARY_NOT_ACTIVE');
      /*
      ELSIF l_err_rec.process_flag = G_REC_DUPLICATE THEN
        fnd_message.set_name('EGO','EGO_ASSOC_DUPLICATE');
        fnd_message.set_token('TRANSACTION_ID',l_err_rec.transaction_id);
        fnd_message.set_token('ITEM_NAME',l_err_rec.item_number);
        fnd_message.set_token('ORG_CODE',l_err_rec.organization_code);
        fnd_message.set_token('DATA_LEVEL',l_err_rec.data_level_id);  -- Do we allow to enter user enterable field
      */
      ELSIF l_err_rec.process_flag = G_REC_NO_CREATE_ASSOC_PRIV THEN
        fnd_message.set_name('EGO','EGO_ASSOC_NO_CREATE_ASSOC_PRIV');
      ELSIF l_err_rec.process_flag = G_REC_NO_EDIT_ASSOC_PRIV THEN
        fnd_message.set_name('EGO','EGO_ASSOC_NO_EDIT_ASSOC_PRIV');
      ELSIF l_err_rec.process_flag = G_REC_NO_SUPPL_ACCESS_PRIV THEN
        fnd_message.set_name('EGO','EGO_ASSOC_NO_SUPPL_ACCESS_PRIV');
      ELSIF l_err_rec.process_flag = G_REC_SUPPLIER_NOT_ASSIGNED THEN
        fnd_message.set_name('EGO','EGO_ASSOC_SUPPL_NOT_ASSIGNED');
      ELSIF l_err_rec.process_flag = G_REC_SITE_NOT_ASSIGNED THEN
        fnd_message.set_name('EGO','EGO_ASSOC_SITE_NOT_ASSIGNED');
      ELSIF l_err_rec.process_flag = G_REC_NO_EDIT_ITEM_ORG_PRIV THEN
        fnd_message.set_name('EGO','EGO_ASSOC_NO_EDIT_ITEMORG_PRIV');
      /*
      ELSIF l_err_rec.process_flag = G_REC_DUPLICATE_PRIMARY THEN
        fnd_message.set_name('EGO','EGO_ASSOC_DUPLICATE_PRIMARY');
        fnd_message.set_token('TRANSACTION_ID',l_err_rec.transaction_id);
        fnd_message.set_token('PK1_VALUE',l_err_rec.pk1_value);
        fnd_message.set_token('PK2_VALUE',l_err_rec.pk2_value);
      */
      END IF;
      l_err_msg := l_err_rec.user_data_level_name || ':::'||l_err_rec.supplier_name||':::';
      IF l_err_rec.data_level_name <> G_ITEM_SUP_LEVEL_NAME THEN
        l_err_msg := l_err_msg || l_err_rec.supplier_site_name || ':::';
      END IF;
      l_err_msg := l_err_msg||fnd_message.get();
      fnd_msg_pub.add;
      INSERT INTO mtl_interface_errors
          ( transaction_id
            , organization_id
            , error_message
            , message_type
            , table_name
            , bo_identifier
            , last_update_date
            , last_updated_by
            , creation_date
            , created_by
            , request_id
          )
      VALUES
          (
            l_err_rec.transaction_id
            , l_err_rec.organization_id
            , l_err_msg
            , 'E'
            , 'EGO_ITEM_ASSOCIATIONS_INTF'
            , 'ITEM_ASSOC'
            , G_SYSDATE
            , G_USER_ID
            , G_SYSDATE
            , G_USER_ID
            , G_REQUEST_ID
          );
     /*
     IF (p_log_level >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
       fnd_log.string(log_level => p_log_level
         ,module    => G_DEBUG_LOG_HEAD||p_module
         ,message   => p_message
         );
     END IF;
     */
     --
     -- writing to concurrent log
     --
     /*
     IF G_REQUEST_ID <> -1
     --AND p_log_level >= G_DEBUG_LEVEL_PROCEDURE
      THEN
       FND_FILE.put_line(which => FND_FILE.LOG
         ,buff  => '['||To_Char(SYSDATE,'DD-MON-RRRR HH24:MI:SS')
         ||'] '||p_message);
     END IF;
     */


    END LOOP;
    UPDATE ego_item_associations_intf
       SET process_flag = G_REC_SUCCESS
     WHERE batch_id = p_batch_id
       AND process_flag = G_REC_IN_PROCESS;
    UPDATE ego_item_associations_intf
       SET process_flag = G_REC_ERROR
     WHERE batch_id = p_batch_id
       AND process_flag >= G_REC_UNEXPECTED_ERROR;
  END insert_errors;

  -- Start of comments
  --  API name    : pre_process
  --  Type        : Private.
  --  Function    :
  --  Pre-reqs    : None
  --  Parameters  :
  --  IN      :   p_api_version       IN NUMBER Required
  --              p_batch_id          IN NUMBER Required
  --  OUT     :   x_return_status     OUT NOCOPY VARCHAR2(1)
  --              x_msg_data          OUT NOCOPY VARCHAR2(2000)
  --  Version :   Initial version     1.0
  --  Notes   :  i) Inserts rows into ego_item_associations_intf for the new SKU's which
  --                are getting created.
  --             ii) Inserts rows into ego_item_associations_intf for the pack hierarchy
  --                 if there exists a packaging hierarchy for the item association's item.
  --             iii) Converts the processing independent values to Ids
  --                  a) Master Org Code and Master Org Id for ITEM_SUP and ITEM_SUP_SITE
  --                  b) Org Code and Org Id for ITEM_SUP_SITE_ORG
  --                  c) Convert Pk1_Name and Pk2_Name
  --
  -- End of comments
  PROCEDURE pre_process
  (
        p_api_version       IN NUMBER
        ,p_batch_id         IN NUMBER
        ,x_return_status    OUT NOCOPY VARCHAR2
        ,x_msg_count        OUT NOCOPY NUMBER
        ,x_msg_data         OUT NOCOPY VARCHAR2
  )
  IS
    l_organization_id NUMBER;
    l_api_name            CONSTANT VARCHAR2(30)   := 'pre_process';
    l_api_version         CONSTANT NUMBER         := 1.0;
    l_data_level_id       NUMBER                  := NULL;
    l_default_option_code VARCHAR2(50)            := NULL;
  BEGIN
    SAVEPOINT pre_process_pub;
    x_return_status := fnd_api.G_RET_STS_SUCCESS;
    set_globals();
    write_log_message(' ego_item_associations_pub.pre_process Batch Id ' || p_batch_id);
    --  Set the transaction type to UPPER case..
    UPDATE ego_item_associations_intf
       SET transaction_type = UPPER(transaction_type)
     WHERE batch_id = p_batch_id
       AND process_flag IN (G_REC_TO_BE_PROCESSED, G_REC_BEFORE_MATCH);
    UPDATE ego_item_associations_intf eiai
       SET data_level_id = G_ITEM_SUPPLIER_LEVEL
     WHERE eiai.batch_id = p_batch_id
       AND eiai.process_flag IN (G_REC_TO_BE_PROCESSED, G_REC_BEFORE_MATCH)
       AND eiai.data_level_name = G_ITEM_SUP_LEVEL_NAME
       AND eiai.transaction_type = G_CREATE;
    UPDATE ego_item_associations_intf eiai
       SET data_level_id = G_ITEM_SUPPLIERSITE_LEVEL
     WHERE eiai.batch_id = p_batch_id
       AND eiai.process_flag  IN (G_REC_TO_BE_PROCESSED, G_REC_BEFORE_MATCH)
       AND eiai.data_level_name = G_ITEM_SUP_SITE_LEVEL_NAME
       AND eiai.transaction_type = G_CREATE;
    UPDATE ego_item_associations_intf eiai
       SET data_level_id = G_ITEM_SUPPLIERSITE_ORG_LEVEL
     WHERE eiai.batch_id = p_batch_id
       AND eiai.process_flag  IN (G_REC_TO_BE_PROCESSED, G_REC_BEFORE_MATCH)
       AND eiai.data_level_name = G_ITEM_SUP_SITE_ORG_LEVEL_NAME
       AND eiai.transaction_type = G_CREATE;

    -- Convert the master org values.  Convert Organization Code to Organization Id
    UPDATE ego_item_associations_intf eiai
       SET organization_id = ( SELECT mp.organization_id
                                 FROM mtl_parameters mp
                                WHERE mp.organization_code = eiai.organization_code
                                  AND mp.master_organization_id = mp.organization_id)
     WHERE eiai.batch_id = p_batch_id
       AND eiai.process_flag  IN (G_REC_TO_BE_PROCESSED, G_REC_BEFORE_MATCH)
       AND ( eiai.data_level_id = G_ITEM_SUPPLIER_LEVEL OR eiai.data_level_id = G_ITEM_SUPPLIERSITE_LEVEL )
       AND eiai.organization_id IS NULL
       AND eiai.organization_code IS NOT NULL;

    -- Correct the organization id to master organization for double intersections
    UPDATE ego_item_associations_intf eiai
       SET organization_id =  ( SELECT mp.master_organization_id
                                 FROM mtl_parameters mp
                                WHERE mp.organization_id = eiai.organization_id)
     WHERE eiai.batch_id = p_batch_id
       AND eiai.process_flag  IN (G_REC_TO_BE_PROCESSED, G_REC_BEFORE_MATCH)
       AND ( eiai.data_level_id = G_ITEM_SUPPLIER_LEVEL OR eiai.data_level_id = G_ITEM_SUPPLIERSITE_LEVEL );

    -- Convert the master org values.  Convert Organization Code to Organization Id
    UPDATE ego_item_associations_intf eiai
       SET organization_id = ( SELECT mp.organization_id
                                 FROM mtl_parameters mp
                                WHERE mp.organization_code = eiai.organization_code)
     WHERE eiai.batch_id = p_batch_id
       AND eiai.process_flag  IN (G_REC_TO_BE_PROCESSED, G_REC_BEFORE_MATCH)
       AND eiai.data_level_id = G_ITEM_SUPPLIERSITE_ORG_LEVEL
       AND eiai.organization_id IS NULL
       AND eiai.organization_code IS NOT NULL;
    -- Convert the organization id to code in order to throw the errors for rules
    UPDATE ego_item_associations_intf eiai
       SET organization_code = ( SELECT mp.organization_code
                                   FROM mtl_parameters mp
                                  WHERE mp.organization_id = eiai.organization_id
                               )
     WHERE eiai.batch_id = p_batch_id
       AND eiai.process_flag IN (G_REC_TO_BE_PROCESSED, G_REC_BEFORE_MATCH)
       AND eiai.organization_code IS NULL
       AND eiai.organization_id IS NOT NULL;

    UPDATE ego_item_associations_intf eiai
       SET pk1_value = ( SELECT vendor_id
                           FROM ap_suppliers aas
                          WHERE aas.segment1 = eiai.supplier_number
                          and NVL(aas.end_date_active,SYSDATE+1) > SYSDATE  --bug11072046
                        )
     WHERE eiai.batch_id = p_batch_id
       AND eiai.process_flag  IN (G_REC_TO_BE_PROCESSED, G_REC_BEFORE_MATCH)
       AND eiai.pk1_value IS NULL
       AND eiai.supplier_number IS NOT NULL;
    UPDATE ego_item_associations_intf eiai
       SET pk1_value = ( SELECT vendor_id
                           FROM ap_suppliers aas
                          WHERE aas.vendor_name = eiai.supplier_name
                          and NVL(aas.end_date_active,SYSDATE+1) > SYSDATE  --bug11072046
                        )
     WHERE eiai.batch_id = p_batch_id
       AND eiai.process_flag  IN (G_REC_TO_BE_PROCESSED, G_REC_BEFORE_MATCH)
       AND eiai.pk1_value IS NULL
       AND eiai.supplier_name IS NOT NULL
       AND eiai.supplier_number IS NULL;
    UPDATE ego_item_associations_intf eiai
       SET supplier_name = ( SELECT vendor_name
                               FROM ap_suppliers aas
                              WHERE aas.vendor_id = eiai.pk1_value
                            )
     WHERE eiai.batch_id = p_batch_id
       AND eiai.process_flag IN (G_REC_TO_BE_PROCESSED, G_REC_BEFORE_MATCH)
       AND eiai.supplier_name IS NULL
       AND eiai.pk1_value IS NOT NULL;
    UPDATE ego_item_associations_intf eiai
       SET pk2_value = NVL(
           ( SELECT vendor_site_id
                           FROM ap_suppliers aas, ap_supplier_sites_all asa
                          WHERE aas.vendor_id = asa.vendor_id
                            AND asa.vendor_site_code = eiai.supplier_site_name
          AND asa.vendor_id = eiai.pk1_value      -- BUG 6322084
                            AND asa.org_id = fnd_profile.value('ORG_ID')
                            AND nvl(asa.inactive_date,SYSDATE + 1)>SYSDATE --BUG11072046
                        )
      , -1)
     WHERE eiai.batch_id = p_batch_id
       AND eiai.process_flag  IN (G_REC_TO_BE_PROCESSED, G_REC_BEFORE_MATCH)
       AND eiai.pk2_value IS NULL
       AND eiai.supplier_site_name IS NOT NULL;
    UPDATE ego_item_associations_intf eiai
       SET supplier_site_name = ( SELECT vendor_site_code
                                    FROM ap_supplier_sites_all asa
                                    WHERE asa.vendor_site_id = eiai.pk2_value
                                )
     WHERE eiai.batch_id = p_batch_id
       AND eiai.process_flag IN (G_REC_TO_BE_PROCESSED, G_REC_BEFORE_MATCH)
       AND eiai.supplier_site_name IS NULL
       AND eiai.pk2_value IS NOT NULL;

    UPDATE ego_item_associations_intf eiai
       SET inventory_item_id = ( SELECT inventory_item_id
                                    FROM mtl_system_items_b_kfv msibk
                                   WHERE msibk.organization_id = eiai.organization_id
                                     AND msibk.concatenated_segments = eiai.item_number
                                )
     WHERE eiai.batch_id = p_batch_id
       AND eiai.process_flag  IN (G_REC_TO_BE_PROCESSED, G_REC_BEFORE_MATCH)
       AND eiai.inventory_item_id IS NULL
       AND eiai.item_number IS NOT NULL;
    -- If Row EXISTS in production the its UPDATE
    UPDATE ego_item_associations_intf eiai
       SET transaction_type = G_UPDATE
     WHERE eiai.batch_id = p_batch_id
       AND eiai.process_flag  IN (G_REC_TO_BE_PROCESSED, G_REC_BEFORE_MATCH)
       AND eiai.transaction_type = G_SYNC
       AND EXISTS
       (
          SELECT 1
            FROM ego_item_associations eia
           WHERE eia.inventory_item_id = eiai.inventory_item_id
             AND eia.organization_id = eiai.organization_id
             AND eia.data_level_id = eiai.data_level_id
             AND eia.pk1_value = eiai.pk1_value
             AND NVL(eia.pk2_value,-1) = NVL(eiai.pk2_value,-1)
        );
    -- Rest of the SYNC are CREATE
    UPDATE ego_item_associations_intf eiai
       SET transaction_type = G_CREATE
     WHERE eiai.batch_id = p_batch_id
       AND eiai.process_flag  IN (G_REC_TO_BE_PROCESSED, G_REC_BEFORE_MATCH)
       AND eiai.transaction_type = G_SYNC;

    UPDATE ego_item_associations_intf eiai
       SET eiai.process_flag = G_REC_INVALID_TRAN_TYPE
     WHERE eiai.batch_id = p_batch_id
       AND eiai.process_flag  IN (G_REC_TO_BE_PROCESSED, G_REC_BEFORE_MATCH)
       AND eiai.transaction_type NOT IN (G_CREATE, G_UPDATE, G_DELETE);

    -- Bug 6438461.  Default the Status and Primary Flag if it is null.
    UPDATE ego_item_associations_intf eiai
       SET eiai.status_code = G_DEFAULT_STATUS_CODE
     WHERE eiai.batch_id = p_batch_id
       AND eiai.process_flag  IN (G_REC_TO_BE_PROCESSED, G_REC_BEFORE_MATCH)
       AND eiai.status_code IS NULL
       AND eiai.transaction_type = G_CREATE;

    UPDATE ego_item_associations_intf eiai
       SET eiai.primary_flag = G_DEFAULT_PRIMARY_FLAG
     WHERE eiai.batch_id = p_batch_id
       AND eiai.process_flag  IN (G_REC_TO_BE_PROCESSED, G_REC_BEFORE_MATCH)
       AND eiai.primary_flag IS NULL
       AND eiai.transaction_type = G_CREATE;

    FND_MSG_PUB.Count_And_Get
        (   p_count             =>      x_msg_count,
            p_data              =>      x_msg_data
        );
    write_log_message(' ego_item_associations_pub.pre_process Msg Count ' || x_msg_count);
    write_log_message(' ego_item_associations_pub.pre_process Msg Data ' || x_msg_data);
    write_log_message(' ego_item_associations_pub.pre_process Return Status ' || x_return_status);
EXCEPTION
    WHEN fnd_api.G_EXC_ERROR THEN
        ROLLBACK TO pre_process_pub;
        x_return_status := fnd_api.G_RET_STS_ERROR ;
        FND_MSG_PUB.Count_And_Get
            (   p_count             =>      x_msg_count ,
                p_data              =>      x_msg_data
            );
        write_log_message(' ego_item_associations_pub.pre_process Error Msg Count ' || x_msg_count);
        write_log_message(' ego_item_associations_pub.pre_process Error Msg Data ' || x_msg_data);
        write_log_message(' ego_item_associations_pub.pre_process Error Return Status ' || x_return_status);
    WHEN fnd_api.G_EXC_UNEXPECTED_ERROR THEN
        --dbms_output.put_line(' SQLERRM ' || SQLERRM);
        ROLLBACK TO pre_process_pub;
        UPDATE ego_item_associations_intf
           SET process_flag = G_REC_UNEXPECTED_ERROR
         WHERE batch_id = p_batch_id
           AND process_flag = G_REC_TO_BE_PROCESSED;
        x_return_status := fnd_api.G_RET_STS_UNEXP_ERROR ;
        FND_MSG_PUB.Count_And_Get
            (   p_count             =>      x_msg_count ,
                p_data              =>      x_msg_data
            );
        write_log_message(' ego_item_associations_pub.pre_process Unexpected Error Msg Count ' || x_msg_count);
        write_log_message(' ego_item_associations_pub.pre_process Unexpected Error Msg Data ' || x_msg_data);
        write_log_message(' ego_item_associations_pub.pre_process Unexpected Error Return Status ' || x_return_status);
    WHEN OTHERS THEN
       --dbms_output.put_line(' SQLERRM ' || SQLERRM);
      ROLLBACK TO pre_process_pub;
        UPDATE ego_item_associations_intf
           SET process_flag = G_REC_UNEXPECTED_ERROR
         WHERE batch_id = p_batch_id
           AND process_flag = G_REC_TO_BE_PROCESSED;
        x_return_status := fnd_api.G_RET_STS_UNEXP_ERROR ;
      IF  FND_MSG_PUB.Check_Msg_Level
          (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
       THEN
        FND_MSG_PUB.Add_Exc_Msg
                    (   G_PKG_NAME,
                        l_api_name
                );
      END IF;
      FND_MSG_PUB.Count_And_Get
        (   p_count             =>      x_msg_count,
            p_data              =>      x_msg_data
        );
      write_log_message(' ego_item_associations_pub.pre_process WHEN OTHERS Msg Count ' || x_msg_count);
      write_log_message(' ego_item_associations_pub.pre_process WHEN OTHERS Msg Data ' || x_msg_data);
      write_log_message(' ego_item_associations_pub.pre_process WHEN OTHERS Return Status ' || x_return_status);
      write_log_message(' ego_item_associations_pub.pre_process WHEN OTHERS SQLERRM ' || SQLERRM);
END pre_process;

  -- Start of comments
  --  API name    : import_item_associations
  --  Type        : Public.
  --  Function    : Imports the item associations into the systems.
  --  Pre-reqs    :   i) pre_process should have been called.
  --                 ii) Rows needs to be populated in EGO.EGO_ITEM_ASSOCIATIONS_INTF.
  --                iii) Errors will be grouped based on concurrent program's request id or batch_id.
  --                      Query the errors using batch_id for non-concurrent program flows and create a batch or use
  --                      unique batch id in order to group the errors properly.
  --  Parameters  :
  --  IN      :   p_api_version       IN NUMBER Required
  --  IN OUT  :   x_batch_id          IN OUT NOCOPY Optional
  --  OUT     :   x_return_status     OUT NOCOPY VARCHAR2(1)
  --              x_msg_count         OUT NOCOPY NUMBER
  --              x_msg_data          OUT NOCOPY VARCHAR2
  --  Version : Current version   1.0
  --            Initial version   1.0
  --  Notes       :
  --              x_batch_id          IN OUT NOCOPY Optional if p_data_from_temp_table is not set
  --                                  Returns batch_id of the batch if its not passed.
  --              x_return_status     OUT NOCOPY VARCHAR2(1) Return status of the program
  --                                  S - Success, E - Error, U - Unexpected Error
  -- End of comments
  PROCEDURE import_item_associations
  ( p_api_version  IN   NUMBER
    ,x_batch_id IN OUT NOCOPY VARCHAR2
    ,x_return_status OUT NOCOPY VARCHAR2
    ,x_msg_count     OUT NOCOPY NUMBER
    ,x_msg_data      OUT NOCOPY VARCHAR2
  )
  IS
    l_api_name          CONSTANT VARCHAR2(30)   := 'import_item_associations';
    l_api_version       CONSTANT NUMBER         := 1.0;
    --l_msg_count         NUMBER := 0;
    --l_msg_data          VARCHAR2(2000);
  BEGIN
    -- Set the Global Variables
    set_globals();
    -- Standard Start of API savepoint
    SAVEPOINT   import_item_associations_pub;
    -- Standard call to check for call compatibility.
    IF NOT fnd_api.Compatible_API_Call ( l_api_version,
                                         p_api_version,
                                         l_api_name,
                                         G_PKG_NAME )
    THEN
        RAISE fnd_api.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    /*
    IF fnd_api.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
    END IF;
    */
    FND_MSG_PUB.initialize;
    --  Initialize API return status to success
    x_return_status := fnd_api.G_RET_STS_SUCCESS;
    write_log_message(' ego_item_associations_pub.import_item_associations Batch Id ' || x_batch_id);
    -- API body

    -- Set records status as in process
    initialize(x_batch_id);
    -- Convert value to ID
    convert_values_to_ids(x_batch_id);
    -- Check Security
    check_security(x_batch_id);
    -- validate
    validate_associations(x_batch_id);
    -- perform_delete
    perform_delete(x_batch_id);
    -- perform_create
    perform_create(x_batch_id);
    -- perform_update
    perform_update(x_batch_id);
    -- insert errors
    insert_errors(x_batch_id);

    COMMIT WORK;
    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get
        (   p_count             =>      x_msg_count,
            p_data              =>      x_msg_data
        );
    write_log_message(' ego_item_associations_pub.import_item_associations Msg Count ' || x_msg_count);
    write_log_message(' ego_item_associations_pub.import_item_associations Msg Data ' || x_msg_data);
    write_log_message(' ego_item_associations_pub.import_item_associations Return Status ' || x_return_status);
  EXCEPTION
    WHEN fnd_api.G_EXC_ERROR THEN
        ROLLBACK TO import_item_associations_pub;
        x_return_status := fnd_api.G_RET_STS_ERROR ;
        FND_MSG_PUB.Count_And_Get
            (   p_count             =>      x_msg_count ,
                p_data              =>      x_msg_data
            );
        write_log_message(' ego_item_associations_pub.import_item_associations Error Msg Count ' || x_msg_count);
        write_log_message(' ego_item_associations_pub.import_item_associations Error Msg Data ' || x_msg_data);
        write_log_message(' ego_item_associations_pub.import_item_associations Error Return Status ' || x_return_status);
    WHEN fnd_api.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO import_item_associations_pub;
        UPDATE ego_item_associations_intf
           SET process_flag = G_REC_UNEXPECTED_ERROR
         WHERE batch_id = x_batch_id
           AND process_flag = G_REC_TO_BE_PROCESSED;
        x_return_status := fnd_api.G_RET_STS_UNEXP_ERROR ;
        FND_MSG_PUB.Count_And_Get
            (   p_count             =>      x_msg_count ,
                p_data              =>      x_msg_data
            );
        write_log_message(' ego_item_associations_pub.import_item_associations Unexpected Error Msg Count ' || x_msg_count);
        write_log_message(' ego_item_associations_pub.import_item_associations Unexpected Error Msg Data ' || x_msg_data);
        write_log_message(' ego_item_associations_pub.import_item_associations Unexpected Error Return Status ' || x_return_status);
    WHEN OTHERS THEN
        ROLLBACK TO import_item_associations_pub;
        UPDATE ego_item_associations_intf
           SET process_flag = G_REC_UNEXPECTED_ERROR
         WHERE batch_id = x_batch_id
           AND process_flag = G_REC_TO_BE_PROCESSED;
        x_return_status := fnd_api.G_RET_STS_UNEXP_ERROR ;
        IF  FND_MSG_PUB.Check_Msg_Level
            (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
                FND_MSG_PUB.Add_Exc_Msg
                    (   G_PKG_NAME,
                        l_api_name
                );
        END IF;
        FND_MSG_PUB.Count_And_Get
            (   p_count             =>      x_msg_count,
                p_data              =>      x_msg_data
            );
      write_log_message(' ego_item_associations_pub.import_item_associations WHEN OTHERS SQLERRM ' || SQLERRM);
      write_log_message(' ego_item_associations_pub.import_item_associations WHEN OTHERS Msg Count ' || x_msg_count);
      write_log_message(' ego_item_associations_pub.import_item_associations WHEN OTHERS Msggggg Data ' || x_msg_data);
      write_log_message(' ego_item_associations_pub.import_item_associations WHEN OTHERS Msg Data ' || x_msg_data);
      write_log_message(' ego_item_associations_pub.import_item_associations WHEN OTHERS Return Status ' || x_return_status);
  END import_item_associations;

  -- Start of comments
  --  API name    : import_item_associations
  --  Type        : private.
  --  Function    : Imports the item associations in the excel import flow.
  --  Pre-reqs    :
  --                 i) Rows needs to be populated in EGO.EGO_ITEM_ASSOCIATIONS_INTF if the data is not from temp tables.
  --                ii) Errors will be grouped based on concurrent program's request id.
  --  Parameters  :
  --  IN          : p_api_version       IN NUMBER Required
  --  IN OUT      : x_batch_id          IN OUT NOCOPY Optional
  --  OUT         : x_errbuf            OUT NOCOPY VARCHAR2
  --                x_retcode           OUT NOCOPY VARCHAR2
  --  Version     : Current version   1.0
  --                Initial version   1.0
  --  Notes       :
  --                x_errbuf          Returns the single error message if it is else null.
  --                x_retcode         0 - Success, 1 - Warning, 2 - Error
  -- End of comments
  PROCEDURE import_item_associations
  (
      p_api_version    IN   NUMBER
      ,x_batch_id      IN OUT NOCOPY VARCHAR2
      ,x_errbuf        OUT NOCOPY VARCHAR2
      ,x_retcode       OUT NOCOPY VARCHAR2
  )
  IS
  l_return_status VARCHAR2(1);
  l_msg_count NUMBER;
  BEGIN
    import_item_associations
    (
      p_api_version => p_api_version
      ,x_batch_id => x_batch_id
      ,x_return_status =>l_return_status
      ,x_msg_count => l_msg_count
      ,x_msg_data => x_errbuf
    );
    IF ( l_return_status = fnd_api.G_RET_STS_SUCCESS ) THEN
      x_retcode := '0';
    ELSIF ( l_return_status = fnd_api.G_RET_STS_ERROR ) THEN
      x_retcode := '2';
    END IF;
  END import_item_associations;


  -- Start of comments
  --  API name    : copy_associations_to_items
  --  Type        : Private.
  --  Function    : Insert interface rows for associations for the target items.
  --  Pre-reqs    : To Item Numbers are all new items.  So no associations exist.
  --  Parameters  :
  --  IN          : p_api_version       IN NUMBER Required
  --                p_batch_id          IN NUMBER Required
  --                p_src_item_id       IN NUMBER Required
  --                p_data_level_names  IN VARCHAR2_TBL_TYPE Required
  --  OUT         : x_return_status     OUT NOCOPY VARCHAR2(1)
  --                x_msg_count         OUT NOCOPY NUMBER
  --                x_msg_data          OUT NOCOPY VARCHAR2(2000)
  --  Version :   Initial version     1.0
  --  Notes   :   Note text
  --
  -- End of comments
  PROCEDURE copy_associations_to_items
  (
      p_api_version       IN NUMBER
      ,p_batch_id         IN NUMBER
      ,p_src_item_id      IN NUMBER
      ,p_data_level_names IN VARCHAR2_TBL_TYPE
      ,x_return_status    OUT NOCOPY VARCHAR2
      ,x_msg_count        OUT NOCOPY NUMBER
      ,x_msg_data         OUT NOCOPY VARCHAR2
  )
  IS
    l_src_entity_sql  VARCHAR2(32767);
    l_dst_entity_sql  VARCHAR2(32767);
    l_master_org_id   NUMBER;
    l_api_name        CONSTANT VARCHAR2(30)   := 'copy_associations_to_items';
    l_api_version     CONSTANT NUMBER         := 1.0;
    l_data_level_id   NUMBER                  := NULL;
  BEGIN
    -- Set the Global Variables
    set_globals();
    /*
    BEGIN
      SELECT master_organization_id
        INTO l_master_org_id
        FROM mtl_parameters
       WHERE organization_id = p_from_org_id;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          x_return_status := fnd_api.G_RET_STS_ERROR;
          RETURN;
    END;
    */
    --  Initialize API return status to success
    x_return_status := fnd_api.G_RET_STS_SUCCESS;
    SAVEPOINT copy_associations_to_items_pub;
    write_log_message(' Before looping data levels ');
    FOR I IN p_data_level_names.FIRST..p_data_level_names.LAST
    LOOP
      write_log_message(' p_data_level_names(I) ' || p_data_level_names(I));
      IF ( p_data_level_names(I) = G_ITEM_SUP_LEVEL_NAME ) THEN
        l_data_level_id := G_ITEM_SUPPLIER_LEVEL;
      ELSIF ( p_data_level_names(I) = G_ITEM_SUP_SITE_LEVEL_NAME ) THEN
        l_data_level_id := G_ITEM_SUPPLIERSITE_LEVEL;
      ELSIF ( p_data_level_names(I) = G_ITEM_SUP_SITE_ORG_LEVEL_NAME ) THEN
        l_data_level_id := G_ITEM_SUPPLIERSITE_ORG_LEVEL;
      END IF;
      write_log_message(' l_data_level_id ' || l_data_level_id);
      INSERT INTO ego_item_associations_intf
      (
        BATCH_ID
        ,ITEM_NUMBER
        ,INVENTORY_ITEM_ID
        ,ORGANIZATION_ID
        ,PK1_VALUE
        ,PK2_VALUE
        ,DATA_LEVEL_ID
        ,PRIMARY_FLAG
        ,STATUS_CODE
        ,TRANSACTION_TYPE
        ,PROCESS_FLAG
        ,TRANSACTION_ID
        ,SOURCE_SYSTEM_REFERENCE
        ,SOURCE_SYSTEM_ID
        ,BUNDLE_ID
        ,REQUEST_ID
      )
      SELECT p_batch_id
             ,msii.item_number
             ,msii.inventory_item_id
             ,msii.organization_id
             ,eia.pk1_value
             ,eia.pk2_value
             ,eia.data_level_id
             ,eia.primary_flag
             ,eia.status_code
             ,G_CREATE
             ,G_REC_TO_BE_PROCESSED
             ,msii.transaction_id
             ,msii.source_system_reference
             ,msii.source_system_id
             ,msii.bundle_id
             ,G_REQUEST_ID
        FROM ego_item_associations eia
             ,mtl_system_items_interface msii
             ,mtl_parameters mp
       WHERE eia.inventory_item_id = p_src_item_id
         -- AND msii.organization_id = mp.organization_id Copy_Item_Id will be populated only for master org items
         --AND mp.organization_id = mp.master_organization_id Copy all triple intersections
         AND msii.set_process_id = p_batch_id
         AND msii.copy_item_id = p_src_item_id
         AND eia.data_level_id = l_data_level_id
         AND msii.process_flag = G_REC_TO_BE_PROCESSED
         AND eia.organization_id = msii.organization_id
         AND msii.organization_id = mp.organization_id;
    write_log_message(' ego_item_associations_pub.copy_associations_to_items after insert ');
    END LOOP;
    FND_MSG_PUB.Count_And_Get
    (   p_count             =>      x_msg_count,
        p_data              =>      x_msg_data
    );
    write_log_message(' ego_item_associations_pub.copy_associations_to_items Msg Count ' || x_msg_count);
    write_log_message(' ego_item_associations_pub.copy_associations_to_items Msg Data ' || x_msg_data);
    write_log_message(' ego_item_associations_pub.copy_associations_to_items Return Status ' || x_return_status);
  EXCEPTION
    WHEN fnd_api.G_EXC_ERROR THEN
      ROLLBACK TO copy_associations_to_items_pub;
      x_return_status := fnd_api.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get
          (   p_count             =>      x_msg_count ,
              p_data              =>      x_msg_data
          );
      write_log_message(' ego_item_associations_pub.copy_associations_to_items Error Msg Count ' || x_msg_count);
      write_log_message(' ego_item_associations_pub.copy_associations_to_items Error Msg Data ' || x_msg_data);
      write_log_message(' ego_item_associations_pub.copy_associations_to_items Error Return Status ' || x_return_status);
    WHEN fnd_api.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO copy_associations_to_items_pub;
      UPDATE ego_item_associations_intf
         SET process_flag = G_REC_UNEXPECTED_ERROR
       WHERE batch_id = p_batch_id
         AND process_flag = G_REC_TO_BE_PROCESSED;
      x_return_status := fnd_api.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get
          (   p_count             =>      x_msg_count ,
              p_data              =>      x_msg_data
          );
      write_log_message(' ego_item_associations_pub.copy_associations_to_items Unexpected Error Msg Count ' || x_msg_count);
      write_log_message(' ego_item_associations_pub.copy_associations_to_items Unexpected Error Msg Data ' || x_msg_data);
      write_log_message(' ego_item_associations_pub.copy_associations_to_items Unexpected Error Return Status ' || x_return_status);
    WHEN OTHERS THEN
      ROLLBACK TO copy_associations_to_items_pub;
      UPDATE ego_item_associations_intf
         SET process_flag = G_REC_UNEXPECTED_ERROR
       WHERE batch_id = p_batch_id
         AND process_flag = G_REC_TO_BE_PROCESSED;
      x_return_status := fnd_api.G_RET_STS_UNEXP_ERROR ;
      IF  FND_MSG_PUB.Check_Msg_Level
          (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
              FND_MSG_PUB.Add_Exc_Msg
                  (   G_PKG_NAME,
                      l_api_name
              );
      END IF;
      FND_MSG_PUB.Count_And_Get
          (   p_count             =>      x_msg_count,
              p_data              =>      x_msg_data
          );
      write_log_message(' ego_item_associations_pub.copy_associations_to_items WHEN OTHERS Msg Count ' || x_msg_count);
      write_log_message(' ego_item_associations_pub.copy_associations_to_items WHEN OTHERS Msg Data ' || x_msg_data);
      write_log_message(' ego_item_associations_pub.copy_associations_to_items WHEN OTHERS Return Status ' || x_return_status);
      write_log_message(' ego_item_associations_pub.copy_associations_to_items WHEN OTHERS SQLERRM ' || SQLERRM);
  END copy_associations_to_items;

  -- Start of comments
  --  API name    : copy_from_style_to_SKUs
  --  Type        : Private.
  --  Function    : Insert interface rows for associations of the style items
  --                to the corresponding SKUs.
  --  Pre-reqs    : None
  --  Parameters  :
  --  IN          : p_api_version       IN NUMBER Required
  --                p_batch_id          IN NUMBER Required
  --  OUT         : x_return_status     OUT NOCOPY VARCHAR2(1)
  --                x_msg_count         OUT NOCOPY NUMBER
  --                x_msg_data          OUT NOCOPY VARCHAR2(2000)
  --  Version     : Initial version     1.0
  --  Notes       : Note text
  --
  -- End of comments
  PROCEDURE copy_from_style_to_SKUs
  (
    p_api_version       IN NUMBER
    ,p_batch_id         IN NUMBER
    ,x_return_status    OUT NOCOPY VARCHAR2
    ,x_msg_count        OUT NOCOPY NUMBER
    ,x_msg_data         OUT NOCOPY VARCHAR2
    ,p_msii_miri_process_flag  IN  NUMBER DEFAULT 1   -- Bug 12635842
  )
  IS
    l_api_name            CONSTANT VARCHAR2(30)   := 'copy_from_style_to_SKUs';
    l_api_version         CONSTANT NUMBER         := 1.0;
    l_data_level_id       NUMBER                  := NULL;
    l_default_option_code VARCHAR2(50)            := NULL;
  BEGIN
    -- Set the Global Variables
    set_globals();
    --  Initialize API return status to success
    x_return_status := fnd_api.G_RET_STS_SUCCESS;
    SAVEPOINT copy_from_style_to_SKUs_pub;
    FOR I IN G_DATA_LEVEL_NAMES.FIRST..G_DATA_LEVEL_NAMES.LAST
    LOOP
      IF ( G_DATA_LEVEL_NAMES(I) = G_ITEM_SUP_LEVEL_NAME ) THEN
        l_data_level_id := G_ITEM_SUPPLIER_LEVEL;
        l_default_option_code := G_ASSIGN_STYLE_SUP_SUPSITE;
      ELSIF ( G_DATA_LEVEL_NAMES(I) = G_ITEM_SUP_SITE_LEVEL_NAME ) THEN
        l_data_level_id := G_ITEM_SUPPLIERSITE_LEVEL;
        l_default_option_code := G_ASSIGN_STYLE_SUP_SUPSITE;
      ELSIF ( G_DATA_LEVEL_NAMES(I) = G_ITEM_SUP_SITE_ORG_LEVEL_NAME ) THEN
        l_data_level_id := G_ITEM_SUPPLIERSITE_ORG_LEVEL;
        l_default_option_code := G_ASSIGN_STYLE_SS_ORG;
        IF ego_common_pvt.get_option_value(l_default_option_code) = 'Y' THEN
          INSERT INTO ego_item_associations_intf
          (
            BATCH_ID
            ,ORGANIZATION_ID
            ,ORGANIZATION_CODE
            ,ITEM_NUMBER
            ,INVENTORY_ITEM_ID
            ,PK1_VALUE
            ,PK2_VALUE
            ,DATA_LEVEL_ID
            ,PRIMARY_FLAG
            ,STATUS_CODE
            ,TRANSACTION_TYPE
            ,PROCESS_FLAG
            ,TRANSACTION_ID
            ,SOURCE_SYSTEM_REFERENCE
            ,SOURCE_SYSTEM_ID
            ,BUNDLE_ID
            ,REQUEST_ID
            ,CREATED_BY -- Bug 6459846
          )
          SELECT p_batch_id
                 ,mp.organization_id
                 ,mp.organization_code
                 ,msii.item_number
                 ,msii.inventory_item_id
                 ,eia.pk1_value
                 ,eia.pk2_value
                 ,eia.data_level_id
                 ,eia.primary_flag
                 ,eia.status_code
                 ,G_CREATE
                 ,G_REC_TO_BE_PROCESSED
                 ,msii.transaction_id
                 ,msii.source_system_reference
                 ,msii.source_system_id
                 ,msii.bundle_id
                 ,G_REQUEST_ID
                 ,G_SKIP_SECURIY_CHECK -- Bug 6459846
            FROM ego_item_associations eia
                 ,mtl_system_items_interface msii
                 ,mtl_parameters mp
                 ,mtl_system_items_interface msii2
           WHERE eia.inventory_item_id = msii2.style_item_id
             AND msii.organization_id = mp.organization_id
             AND msii.set_process_id = p_batch_id
             AND eia.data_level_id = G_ITEM_SUPPLIERSITE_ORG_LEVEL
             AND msii.process_flag = p_msii_miri_process_flag   -- Bug 12635842
             AND eia.organization_id = mp.organization_id
             AND msii.inventory_item_id = msii2.inventory_item_id
             AND msii2.organization_id = mp.master_organization_id
             AND msii2.style_item_id IS NOT NULL
             AND msii2.set_process_id = p_batch_id
             AND msii2.process_flag = p_msii_miri_process_flag   -- Bug 12635842
             AND NOT EXISTS
                 (
                   SELECT 1
                     FROM ego_item_associations_intf eiai1
                    WHERE eiai1.inventory_item_id = msii.inventory_item_id
                      AND eiai1.organization_id = msii.organization_id
                      AND eiai1.data_level_id = G_ITEM_SUPPLIERSITE_ORG_LEVEL
                      AND eiai1.batch_id = p_batch_id
                      AND eiai1.process_flag = G_REC_TO_BE_PROCESSED
                      AND eiai1.pk1_value = eia.pk1_value
                      AND NVL(eiai1.pk2_value,-1) = NVL(eia.pk2_value,-1)
                   UNION ALL
                   SELECT 1
                     FROM ego_item_associations eia2
                    WHERE eia2.inventory_item_id = msii.inventory_item_id
                      AND eia2.organization_id = msii.organization_id
                      AND eia2.data_level_id = eia.data_level_id
                      AND eia2.pk1_value = eia.pk1_value
                      AND NVL(eia2.pk2_value,-1) = NVL(eia.pk2_value,-1)
                 );
        END IF;
      END IF;
      --dbms_output.put_line(' Defaulting option ' || ego_common_pvt.get_option_value(l_default_option_code) );
      IF ego_common_pvt.get_option_value(l_default_option_code) = 'Y' THEN
        INSERT INTO ego_item_associations_intf
        (
          BATCH_ID
          ,ORGANIZATION_ID
          ,ORGANIZATION_CODE
          ,ITEM_NUMBER
          ,INVENTORY_ITEM_ID
          ,PK1_VALUE
          ,PK2_VALUE
          ,DATA_LEVEL_ID
          ,PRIMARY_FLAG
          ,STATUS_CODE
          ,TRANSACTION_TYPE
          ,PROCESS_FLAG
          ,TRANSACTION_ID
          ,SOURCE_SYSTEM_REFERENCE
          ,SOURCE_SYSTEM_ID
          ,BUNDLE_ID
          ,REQUEST_ID
          ,CREATED_BY -- Bug 6459846
        )
        SELECT p_batch_id
               ,mp.organization_id
               ,mp.organization_code
               ,msii.item_number
               ,msii.inventory_item_id
               ,eia.pk1_value
               ,eia.pk2_value
               ,eia.data_level_id
               ,eia.primary_flag
               ,eia.status_code
               ,G_CREATE
               ,G_REC_TO_BE_PROCESSED
               ,msii.transaction_id
               ,msii.source_system_reference
               ,msii.source_system_id
               ,msii.bundle_id
               ,G_REQUEST_ID
               ,G_SKIP_SECURIY_CHECK -- Bug 6459846
          FROM ego_item_associations eia
               ,mtl_system_items_interface msii
               ,mtl_parameters mp
         WHERE eia.inventory_item_id = msii.style_item_id
           AND msii.organization_id = mp.organization_id
           --AND mp.organization_id = mp.master_organization_id
           AND msii.set_process_id = p_batch_id
           AND eia.data_level_id = l_data_level_id
           AND msii.process_flag = p_msii_miri_process_flag   -- Bug 12635842
           AND eia.organization_id = mp.organization_id
           AND NOT EXISTS
               (
                 SELECT 1
                   FROM ego_item_associations_intf eiai1
                  WHERE eiai1.inventory_item_id = msii.inventory_item_id
                    AND eiai1.organization_id = msii.organization_id
                    AND eiai1.data_level_id = l_data_level_id
                    AND eiai1.batch_id = p_batch_id
                    AND eiai1.process_flag = G_REC_TO_BE_PROCESSED
                    AND eiai1.pk1_value = eia.pk1_value
                    AND NVL(eiai1.pk2_value,-1) = NVL(eia.pk2_value,-1)
                 UNION ALL
                 SELECT 1
                   FROM ego_item_associations eia2
                  WHERE eia2.inventory_item_id = msii.inventory_item_id
                    AND eia2.organization_id = msii.organization_id
                    AND eia2.data_level_id = eia.data_level_id
                    AND eia2.pk1_value = eia.pk1_value
                    AND NVL(eia2.pk2_value,-1) = NVL(eia.pk2_value,-1)
               );
        -- Copy the rows to existing SKUs
        INSERT INTO ego_item_associations_intf
        (
          BATCH_ID
          ,ORGANIZATION_ID
          ,ORGANIZATION_CODE
          ,ITEM_NUMBER
          ,INVENTORY_ITEM_ID
          ,PK1_VALUE
          ,SUPPLIER_NAME
          ,SUPPLIER_NUMBER
          ,PK2_VALUE
          ,SUPPLIER_SITE_NAME
          ,DATA_LEVEL_ID
          ,DATA_LEVEL_NAME
          ,PRIMARY_FLAG
          ,STATUS_CODE
          ,TRANSACTION_TYPE
          ,PROCESS_FLAG
          ,TRANSACTION_ID
          ,SOURCE_SYSTEM_REFERENCE
          ,SOURCE_SYSTEM_ID
          ,BUNDLE_ID
          ,REQUEST_ID
          ,CREATED_BY -- Bug 6459846
        )
        SELECT p_batch_id
               ,eiai1.organization_id
               ,eiai1.organization_code
               ,msibk.concatenated_segments
               ,msibk.inventory_item_id
               ,eiai1.pk1_value
               ,eiai1.supplier_name
               ,eiai1.supplier_number
               ,eiai1.pk2_value
               ,eiai1.supplier_site_name
               ,eiai1.data_level_id
               ,eiai1.data_level_name
               ,eiai1.primary_flag
               ,eiai1.status_code
               ,G_CREATE
               ,G_REC_TO_BE_PROCESSED
               ,mtl_system_items_interface_s.NEXTVAL
               ,NULL
               ,NULL
               ,NULL
               ,G_REQUEST_ID
               ,G_SKIP_SECURIY_CHECK -- Bug 6459846
          FROM ego_item_associations_intf eiai1
               ,mtl_system_items_b_kfv msibk
               ,mtl_parameters mp
         WHERE eiai1.inventory_item_id = msibk.style_item_id
           AND eiai1.organization_id = msibk.organization_id
           AND msibk.organization_id = mp.organization_id
          -- AND mp.organization_id = mp.master_organization_id
           AND eiai1.batch_id = p_batch_id
           AND eiai1.data_level_id = l_data_level_id
           AND eiai1.process_flag = G_REC_SUCCESS
           AND NOT EXISTS
               (
                 SELECT 1
                   FROM ego_item_associations_intf eiai2
                  WHERE eiai2.inventory_item_id = msibk.inventory_item_id
                    AND eiai2.organization_id = msibk.organization_id
                    AND eiai2.data_level_id = l_data_level_id
                    AND eiai2.batch_id = p_batch_id
                    AND eiai2.process_flag = G_REC_TO_BE_PROCESSED
                    AND eiai2.pk1_value = eiai1.pk1_value
                    AND NVL(eiai2.pk2_value,-1) = NVL(eiai1.pk2_value,-1)
                 UNION ALL
                 SELECT 1
                   FROM ego_item_associations eia2
                  WHERE eia2.inventory_item_id = msibk.inventory_item_id
                    AND eia2.organization_id = msibk.organization_id
                    AND eia2.data_level_id = eiai1.data_level_id
                    AND eia2.pk1_value = eiai1.pk1_value
                    AND NVL(eia2.pk2_value,-1) = NVL(eiai1.pk2_value,-1)
               );
      END IF;
    END LOOP;
    FND_MSG_PUB.Count_And_Get
    (   p_count             =>      x_msg_count,
        p_data              =>      x_msg_data
    );
    write_log_message(' ego_item_associations_pub.copy_from_style_to_SKUs Msg Count ' || x_msg_count);
    write_log_message(' ego_item_associations_pub.copy_from_style_to_SKUs Msg Data ' || x_msg_data);
    write_log_message(' ego_item_associations_pub.copy_from_style_to_SKUs Return Status ' || x_return_status);
EXCEPTION
    WHEN fnd_api.G_EXC_ERROR THEN
      ROLLBACK TO copy_from_style_to_SKUs_pub;
      x_return_status := fnd_api.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get
          (   p_count             =>      x_msg_count ,
              p_data              =>      x_msg_data
          );
      write_log_message(' ego_item_associations_pub.copy_from_style_to_SKUs Error Msg Count ' || x_msg_count);
      write_log_message(' ego_item_associations_pub.copy_from_style_to_SKUs Error Msg Data ' || x_msg_data);
      write_log_message(' ego_item_associations_pub.copy_from_style_to_SKUs Error Return Status ' || x_return_status);
    WHEN fnd_api.G_EXC_UNEXPECTED_ERROR THEN
      --dbms_output.put_line(' Error Msg ' || SQLERRM);
      ROLLBACK TO copy_from_style_to_SKUs_pub;
      UPDATE ego_item_associations_intf
         SET process_flag = G_REC_UNEXPECTED_ERROR
       WHERE batch_id = p_batch_id
         AND process_flag = G_REC_TO_BE_PROCESSED;
      x_return_status := fnd_api.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get
          (   p_count             =>      x_msg_count ,
              p_data              =>      x_msg_data
          );
      write_log_message(' ego_item_associations_pub.copy_from_style_to_SKUs Unexpected Error Msg Count ' || x_msg_count);
      write_log_message(' ego_item_associations_pub.copy_from_style_to_SKUs Unexpected Error Msg Data ' || x_msg_data);
      write_log_message(' ego_item_associations_pub.copy_from_style_to_SKUs Unexpected Error Return Status ' || x_return_status);
    WHEN OTHERS THEN
      --dbms_output.put_line(' Error Msg ' || SQLERRM);
      ROLLBACK TO copy_from_style_to_SKUs_pub;
      UPDATE ego_item_associations_intf
         SET process_flag = G_REC_UNEXPECTED_ERROR
       WHERE batch_id = p_batch_id
         AND process_flag = G_REC_TO_BE_PROCESSED;
      x_return_status := fnd_api.G_RET_STS_UNEXP_ERROR ;
      IF  FND_MSG_PUB.Check_Msg_Level
          (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
              FND_MSG_PUB.Add_Exc_Msg
                  (   G_PKG_NAME,
                      l_api_name
              );
      END IF;
      FND_MSG_PUB.Count_And_Get
          (   p_count             =>      x_msg_count,
              p_data              =>      x_msg_data
          );
      write_log_message(' ego_item_associations_pub.copy_from_style_to_SKUs WHEN OTHERS Msg Count ' || x_msg_count);
      write_log_message(' ego_item_associations_pub.copy_from_style_to_SKUs WHEN OTHERS Msg Data ' || x_msg_data);
      write_log_message(' ego_item_associations_pub.copy_from_style_to_SKUs WHEN OTHERS Return Status ' || x_return_status);
      write_log_message(' ego_item_associations_pub.copy_from_style_to_SKUs WHEN OTHERS SQLERRM ' || SQLERRM);
  END copy_from_style_to_SKUs;

  -- Start of comments
  --  API name    : copy_to_packs
  --  Type        : Private.
  --  Function    : Insert interface rows for associations of the pack items
  --                to the corresponding pack hierarchy.
  --  Pre-reqs    : None
  --  Parameters  :
  --  IN          : p_api_version       IN NUMBER Required
  --                p_batch_id          IN NUMBER Required
  --  OUT         : x_return_status     OUT NOCOPY VARCHAR2(1)
  --                x_msg_count         OUT NOCOPY NUMBER
  --                x_msg_data          OUT NOCOPY VARCHAR2(2000)
  --  Version     : Initial version     1.0
  --  Notes       : Note text
  --
  -- End of comments
  PROCEDURE copy_to_packs
  (
    p_api_version       IN NUMBER
    ,p_batch_id         IN NUMBER
    ,x_return_status    OUT NOCOPY VARCHAR2
    ,x_msg_count        OUT NOCOPY NUMBER
    ,x_msg_data         OUT NOCOPY VARCHAR2
  )
  IS
    l_api_name            CONSTANT VARCHAR2(30)   := 'copy_to_packs';
    l_api_version         CONSTANT NUMBER         := 1.0;
    l_data_level_id       NUMBER                  := NULL;
    l_default_option_code VARCHAR2(50)            := NULL;
    l_explode_grp_id NUMBER;
    l_err_message VARCHAR2(2000);
    l_err_code NUMBER;
    CURSOR l_expl_csr
    IS
      SELECT component_item_id
        FROM bom_explosions_v;
    CURSOR l_pack_item_csr(p_batch_id IN NUMBER)
    IS
    SELECT msibk.inventory_item_id
           ,msibk.organization_id
      FROM ego_item_associations_intf eiai, mtl_system_items_b_kfv msibk
     WHERE msibk.concatenated_segments = eiai.item_number
       AND msibk.organization_id = eiai.organization_id
       AND eiai.batch_id = p_batch_id
       AND eiai.process_flag = G_REC_TO_BE_PROCESSED
       AND EXISTS
           (
             SELECT 1
               FROM bom_structures_b bsb
              WHERE bsb.assembly_item_id = msibk.inventory_item_id
                AND bsb.assembly_item_id = msibk.inventory_item_id
                AND bsb.organization_id = eiai.organization_id
                AND bsb.bill_sequence_id = bsb.common_bill_sequence_id
                AND bsb.alternate_bom_designator = ego_item_associations_pub.G_PACK_STR_NAME
           );
  BEGIN
    x_return_status := fnd_api.G_RET_STS_SUCCESS;
    -- Set the Global Variables
    set_globals();
    --  Initialize API return status to success
    SAVEPOINT copy_to_packs_pub;
    FOR I IN G_DATA_LEVEL_NAMES.FIRST..G_DATA_LEVEL_NAMES.LAST
    LOOP
      IF ( G_DATA_LEVEL_NAMES(I) = G_ITEM_SUP_LEVEL_NAME ) THEN
        l_data_level_id := G_ITEM_SUPPLIER_LEVEL;
        l_default_option_code := G_ASSIGN_PACK_SUPPLIER;
      ELSIF ( G_DATA_LEVEL_NAMES(I) = G_ITEM_SUP_SITE_LEVEL_NAME ) THEN
        l_data_level_id := G_ITEM_SUPPLIERSITE_LEVEL;
        l_default_option_code := G_ASSIGN_PACK_SUP_SITE;
      ELSIF ( G_DATA_LEVEL_NAMES(I) = G_ITEM_SUP_SITE_ORG_LEVEL_NAME ) THEN
        l_data_level_id := G_ITEM_SUPPLIERSITE_ORG_LEVEL;
        l_default_option_code := G_ASSIGN_PACK_SS_ORG;
      END IF;
      --dbms_output.put_line(' Defaulting option ' || ego_common_pvt.get_option_value(l_default_option_code) );
      FOR l_pack_rec IN l_pack_item_csr(p_batch_id)
      LOOP
        bom_exploder_pub.exploder_userexit(
          org_id             => l_pack_rec.organization_id,
          grp_id             => l_explode_grp_id,
          levels_to_explode  => 60,
          bom_or_eng         => 2,
          impl_flag          => 1,
          explode_option     => 2,
          rev_date           => G_SYSDATE,
          alt_desg           => G_PACK_STR_NAME,
          pk_value1          => l_pack_rec.inventory_item_id,
          pk_value2          => l_pack_rec.organization_id,
          err_msg            => l_err_message,
          error_code         => l_err_code,
          unit_number        => NULL
        );
        FOR l_item_rec IN l_expl_csr
        LOOP
          FOR I IN G_DATA_LEVEL_NAMES.FIRST..G_DATA_LEVEL_NAMES.LAST
          LOOP
            IF ( G_DATA_LEVEL_NAMES(I) = G_ITEM_SUP_LEVEL_NAME ) THEN
              l_data_level_id := G_ITEM_SUPPLIER_LEVEL;
              l_default_option_code := G_ASSIGN_PACK_SUPPLIER;
            ELSIF ( G_DATA_LEVEL_NAMES(I) = G_ITEM_SUP_SITE_LEVEL_NAME ) THEN
              l_data_level_id := G_ITEM_SUPPLIERSITE_LEVEL;
              l_default_option_code := G_ASSIGN_PACK_SUP_SITE;
            ELSIF ( G_DATA_LEVEL_NAMES(I) = G_ITEM_SUP_SITE_ORG_LEVEL_NAME ) THEN
              l_data_level_id := G_ITEM_SUPPLIERSITE_ORG_LEVEL;
              l_default_option_code := G_ASSIGN_PACK_SS_ORG;
            END IF;
            IF ego_common_pvt.get_option_value(l_default_option_code) = 'Y' THEN
              INSERT INTO ego_item_associations_intf
              (
                BATCH_ID
                ,SOURCE_SYSTEM_REFERENCE
                ,ITEM_NUMBER
                ,INVENTORY_ITEM_ID
                ,ORGANIZATION_ID
                ,ORGANIZATION_CODE
                ,PK1_VALUE
                ,SUPPLIER_NAME
                ,SUPPLIER_NUMBER
                ,PK2_VALUE
                ,SUPPLIER_SITE_NAME
                ,DATA_LEVEL_ID
                ,DATA_LEVEL_NAME
                ,PRIMARY_FLAG
                ,STATUS_CODE
                ,TRANSACTION_TYPE
                ,PROCESS_FLAG
                ,TRANSACTION_ID
                ,REQUEST_ID
                ,CREATED_BY -- Bug 6459846
              )
              SELECT p_batch_id
                     ,NULL
                     ,msibk.concatenated_segments
                     ,msibk.inventory_item_id
                     ,eiai.organization_id
                     ,eiai.organization_code
                     ,eiai.pk1_value
                     ,eiai.supplier_name
                     ,eiai.supplier_number
                     ,eiai.pk2_value
                     ,eiai.supplier_site_name
                     ,eiai.data_level_id
                     ,eiai.data_level_name
                     ,eiai.primary_flag
                     ,eiai.status_code
                     ,G_CREATE
                     ,G_REC_TO_BE_PROCESSED
                     ,mtl_system_items_interface_s.NEXTVAL
                     ,G_REQUEST_ID
                     ,G_SKIP_SECURIY_CHECK -- Bug 6459846
                FROM ego_item_associations_intf eiai, mtl_system_items_b_kfv msibk,
                     mtl_parameters mp
               WHERE eiai.inventory_item_id = l_pack_rec.inventory_item_id
                 AND eiai.organization_id = mp.organization_id
                 --AND mp.master_organization_id = mp.organization_id
                 AND eiai.batch_id = p_batch_id
                 AND eiai.process_flag = G_REC_TO_BE_PROCESSED
                 AND mp.organization_id = l_pack_rec.organization_id
                 AND eiai.data_level_id = l_data_level_id
                 AND msibk.inventory_item_id = l_item_rec.component_item_id
                 AND msibk.organization_id = mp.organization_id
                 AND NOT EXISTS
                     (
                       SELECT 1
                         FROM ego_item_associations_intf eiai1
                        WHERE eiai1.inventory_item_id = msibk.inventory_item_id
                          AND eiai1.organization_id = msibk.organization_id
                          AND eiai1.data_level_id = l_data_level_id
                          AND eiai1.batch_id = p_batch_id
                          AND eiai1.process_flag = G_REC_TO_BE_PROCESSED
                          AND eiai1.pk1_value = eiai.pk1_value
                          AND NVL(eiai1.pk2_value,-1) = NVL(eiai.pk2_value,-1)
                        UNION ALL
                       SELECT 1
                         FROM ego_item_associations eia2
                        WHERE eia2.inventory_item_id = msibk.inventory_item_id
                          AND eia2.organization_id = msibk.organization_id
                          AND eia2.data_level_id = l_data_level_id
                          AND eia2.pk1_value = eiai.pk1_value
                          AND NVL(eia2.pk2_value,-1) = NVL(eiai.pk2_value,-1)
                     );
            END IF;
          END LOOP;
        END LOOP;
      END LOOP;
    END LOOP;
    FND_MSG_PUB.Count_And_Get
    (   p_count             =>      x_msg_count,
        p_data              =>      x_msg_data
    );
    write_log_message(' ego_item_associations_pub.copy_to_packs Msg Count ' || x_msg_count);
    write_log_message(' ego_item_associations_pub.copy_to_packs Msg Data ' || x_msg_data);
    write_log_message(' ego_item_associations_pub.copy_to_packs Return Status ' || x_return_status);
  EXCEPTION
    WHEN fnd_api.G_EXC_ERROR THEN
      ROLLBACK TO copy_to_packs_pub;
      x_return_status := fnd_api.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get
          (   p_count             =>      x_msg_count ,
              p_data              =>      x_msg_data
          );
      write_log_message(' ego_item_associations_pub.copy_to_packs Error Msg Count ' || x_msg_count);
      write_log_message(' ego_item_associations_pub.copy_to_packs Error Msg Data ' || x_msg_data);
      write_log_message(' ego_item_associations_pub.copy_to_packs Error Return Status ' || x_return_status);
    WHEN fnd_api.G_EXC_UNEXPECTED_ERROR THEN
      --dbms_output.put_line(' Error Msg ' || SQLERRM);
      ROLLBACK TO copy_to_packs_pub;
      UPDATE ego_item_associations_intf
         SET process_flag = G_REC_UNEXPECTED_ERROR
       WHERE batch_id = p_batch_id
         AND process_flag = G_REC_TO_BE_PROCESSED;
      x_return_status := fnd_api.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get
          (   p_count             =>      x_msg_count ,
              p_data              =>      x_msg_data
          );
      write_log_message(' ego_item_associations_pub.copy_to_packs Unexpected Error Msg Count ' || x_msg_count);
      write_log_message(' ego_item_associations_pub.copy_to_packs Unexpected Error Msg Data ' || x_msg_data);
      write_log_message(' ego_item_associations_pub.copy_to_packs Unexpected Error Return Status ' || x_return_status);
    WHEN OTHERS THEN
      --dbms_output.put_line(' Error Msg ' || SQLERRM);
      ROLLBACK TO copy_to_packs_pub;
      UPDATE ego_item_associations_intf
         SET process_flag = G_REC_UNEXPECTED_ERROR
       WHERE batch_id = p_batch_id
         AND process_flag = G_REC_TO_BE_PROCESSED;
      x_return_status := fnd_api.G_RET_STS_UNEXP_ERROR ;
      IF  FND_MSG_PUB.Check_Msg_Level
          (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
              FND_MSG_PUB.Add_Exc_Msg
                  (   G_PKG_NAME,
                      l_api_name
              );
      END IF;
      FND_MSG_PUB.Count_And_Get
          (   p_count             =>      x_msg_count,
              p_data              =>      x_msg_data
          );
      write_log_message(' ego_item_associations_pub.copy_to_packs WHEN OTHERS Msg Count ' || x_msg_count);
      write_log_message(' ego_item_associations_pub.copy_to_packs WHEN OTHERS Msg Data ' || x_msg_data);
      write_log_message(' ego_item_associations_pub.copy_to_packs WHEN OTHERS Return Status ' || x_return_status);
      write_log_message(' ego_item_associations_pub.copy_to_packs WHEN OTHERS SQLERRM ' || SQLERRM);
  END copy_to_packs;

END ego_item_associations_pub;

/
