--------------------------------------------------------
--  DDL for Package Body EGO_PAGES_BULKLOAD_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EGO_PAGES_BULKLOAD_PVT" AS
/* $Header: EGOVPGBB.pls 120.0.12010000.9 2010/05/21 09:13:02 jiabraha noship $ */

  /*This Procedure is used to initialize certain column values in the interface table.
    Used in the interface flow.
  	x_return_status OUT NOCOPY parameter that returns the status*/
  PROCEDURE Initialize (x_return_status OUT NOCOPY VARCHAR2, x_return_msg OUT NOCOPY VARCHAR2)
  IS
    lv_smt NUMBER; --Statement counter
    lv_proc VARCHAR2(30) := 'Initialize';
  BEGIN
    write_debug('ego_pages_bulkload_pvt.'||lv_proc||' - '||'Entered Initialize procedure');

    x_return_status := G_RET_STS_SUCCESS;

    lv_smt := 1;

    write_debug('ego_pages_bulkload_pvt.'||lv_proc||' - '||'Statement 1');

    /*Sets the EGO Application ID*/
    SELECT application_id
    INTO   G_EGO_APPLICATION_ID
    FROM   fnd_application
    WHERE  application_short_name = 'EGO';

    /*Sets the EGO_ITEM OBJECT_ID*/
    SELECT object_id
    INTO   G_OBJECT_ID
    FROM   fnd_objects
    WHERE  obj_name = 'EGO_ITEM';

    lv_smt := 2;

    write_debug('ego_pages_bulkload_pvt.'||lv_proc||' - '||'Statement 2');

    /*Sets the Transaction_id and upper case the transaction_type for pages interface table*/
    UPDATE ego_pages_interface
    SET    transaction_id = mtl_system_items_interface_s.nextval,
           transaction_type = Upper(transaction_type),
           created_by = G_USER_ID,
           creation_date = SYSDATE,
           last_updated_by = G_USER_ID,
           last_update_date = SYSDATE,
           last_update_login = G_LOGIN_ID,
           request_id = G_REQUEST_ID,
           program_application_id = G_PROG_APPL_ID,
           program_id = G_PROGRAM_ID,
           program_update_date = SYSDATE
    WHERE  transaction_id IS NULL
    	   AND process_status = G_PROCESS_RECORD
           AND ( ( G_SET_PROCESS_ID IS NULL )
                  OR ( set_process_id = G_SET_PROCESS_ID ) );

    SELECT COUNT(1) INTO G_PAGES_COUNT
    FROM ego_pages_interface
    WHERE process_status = G_PROCESS_RECORD
           AND ( ( G_SET_PROCESS_ID IS NULL )
                  OR ( set_process_id = G_SET_PROCESS_ID ) );

    lv_smt := 2;

    write_debug('ego_pages_bulkload_pvt.'||lv_proc||' - '||'Statement 2');

    /*Sets the Transaction_id and upper case the transaction_type for page entries interface table*/
    UPDATE ego_page_entries_interface
    SET    transaction_id = mtl_system_items_interface_s.nextval,
           transaction_type = Upper(transaction_type),
           created_by = G_USER_ID,
           creation_date = SYSDATE,
           last_updated_by = G_USER_ID,
           last_update_date = SYSDATE,
           last_update_login = G_LOGIN_ID,
           request_id = G_REQUEST_ID,
           program_application_id = G_PROG_APPL_ID,
           program_id = G_PROGRAM_ID,
           program_update_date = SYSDATE
    WHERE  transaction_id IS NULL
    	   AND process_status = G_PROCESS_RECORD
           AND ( ( G_SET_PROCESS_ID IS NULL )
                  OR ( set_process_id = G_SET_PROCESS_ID ) );

    SELECT COUNT(1) INTO G_PAGE_ENTRIES_COUNT
    FROM ego_page_entries_interface
    WHERE process_status = G_PROCESS_RECORD
           AND ( ( G_SET_PROCESS_ID IS NULL )
                  OR ( set_process_id = G_SET_PROCESS_ID ) );

  write_debug('ego_pages_bulkload_pvt.'||lv_proc||' - '||'Exit Initialize procedure');
  EXCEPTION
    WHEN OTHERS THEN
               write_debug('ego_pages_bulkload_pvt.'||lv_proc||' - '||'Initialize - Exception when others'||SQLERRM);

               x_return_status := G_RET_STS_UNEXP_ERROR;

               x_return_msg := 'ego_pages_bulkload_pvt.Initialize - '||SQLERRM;

               RETURN;
  END Initialize;

  /*This procedure is used to validate the transaction type for all the interface tables.
  	Used in the interface flow.
  	x_return_status OUT NOCOPY parameter that returns the status*/
  PROCEDURE Validate_transaction_type (x_return_status OUT NOCOPY VARCHAR2, x_return_msg OUT NOCOPY VARCHAR2)
  IS
    lv_smt NUMBER; --Statement counter
    lv_proc VARCHAR2(30) := 'Validate_transaction_type';
  BEGIN
    write_debug('ego_pages_bulkload_pvt.'||lv_proc||' - '||'Entered Validate_transaction_type');

    x_return_status := G_RET_STS_SUCCESS;

    /* Update the interface records with process_status 3 and insert into
    MTL_INTERFACE_ERRORS if TRANSACTION_TYPE passed is incorrect*/
    G_MESSAGE_NAME := 'EGO_TRANS_TYPE_INVALID';

    fnd_message.Set_name(G_EGO_APPLICATION_ID, 'EGO_TRANS_TYPE_INVALID');

    G_MESSAGE_TEXT := fnd_message.get;

    lv_smt := 1;

    write_debug('ego_pages_bulkload_pvt.'||lv_proc||' - '||'Statement 1');

    INSERT INTO mtl_interface_errors
                (transaction_id,
                 unique_id,
                 organization_id,
                 column_name,
                 table_name,
                 bo_identifier,
                 entity_identifier,
                 message_name,
                 error_message,
                 last_update_date,
                 last_updated_by,
                 creation_date,
                 created_by,
                 last_update_login,
                 request_id,
                 program_application_id,
                 program_id,
                 program_update_date)
    SELECT transaction_id,
           mtl_system_items_interface_s.nextval,
           NULL,
           NULL,
           G_ENTITY_PG_TAB,
           G_BO_IDENTIFIER_PG,
           G_ENTITY_PG,
           G_MESSAGE_NAME,
           G_MESSAGE_TEXT,
           Nvl(last_update_date, SYSDATE),
           Nvl(last_updated_by, G_USER_ID),
           Nvl(creation_date, SYSDATE),
           Nvl(created_by, G_USER_ID),
           Nvl(last_update_login, G_USER_ID),
           G_REQUEST_ID,
           Nvl(program_application_id, G_PROG_APPL_ID),
           Nvl(program_id, G_PROGRAM_ID),
           Nvl(program_update_date, SYSDATE)
    FROM   ego_pages_interface
    WHERE  (transaction_type IS NULL
    	   OR transaction_type NOT IN ( G_OPR_CREATE, G_OPR_UPDATE, G_OPR_DELETE, G_OPR_SYNC ))
           AND transaction_id IS NOT NULL
           AND process_status = G_PROCESS_RECORD
           AND ( ( G_SET_PROCESS_ID IS NULL )
                  OR ( set_process_id = G_SET_PROCESS_ID ) );

    UPDATE ego_pages_interface
    SET    process_status = G_ERROR_RECORD,
           last_updated_by = G_USER_ID,
           last_update_date = SYSDATE,
           last_update_login = G_LOGIN_ID
    WHERE  (transaction_type IS NULL
    	   OR transaction_type NOT IN ( G_OPR_CREATE, G_OPR_UPDATE, G_OPR_DELETE, G_OPR_SYNC ))
           AND transaction_id IS NOT NULL
           AND process_status = G_PROCESS_RECORD
           AND ( ( G_SET_PROCESS_ID IS NULL )
                  OR ( set_process_id = G_SET_PROCESS_ID ) );

    lv_smt := 2;

    write_debug('ego_pages_bulkload_pvt.'||lv_proc||' - '||'Statement 2');

    INSERT INTO mtl_interface_errors
                (transaction_id,
                 unique_id,
                 organization_id,
                 column_name,
                 table_name,
                 bo_identifier,
                 entity_identifier,
                 message_name,
                 error_message,
                 last_update_date,
                 last_updated_by,
                 creation_date,
                 created_by,
                 last_update_login,
                 request_id,
                 program_application_id,
                 program_id,
                 program_update_date)
    SELECT transaction_id,
           mtl_system_items_interface_s.nextval,
           NULL,
           NULL,
           G_ENTITY_ENT_TAB,
           G_BO_IDENTIFIER_PG,
           G_ENTITY_ENT,
           G_MESSAGE_NAME,
           G_MESSAGE_TEXT,
           Nvl(last_update_date, SYSDATE),
           Nvl(last_updated_by, G_USER_ID),
           Nvl(creation_date, SYSDATE),
           Nvl(created_by, G_USER_ID),
           Nvl(last_update_login, G_USER_ID),
           G_REQUEST_ID,
           Nvl(program_application_id, G_PROG_APPL_ID),
           Nvl(program_id, G_PROGRAM_ID),
           Nvl(program_update_date, SYSDATE)
    FROM   ego_page_entries_interface
    WHERE  (transaction_type IS NULL
     	   OR transaction_type NOT IN ( G_OPR_CREATE, G_OPR_UPDATE, G_OPR_SYNC, G_OPR_DELETE ))
           AND transaction_id IS NOT NULL
           AND process_status = G_PROCESS_RECORD
           AND ( ( G_SET_PROCESS_ID IS NULL )
                  OR ( set_process_id = G_SET_PROCESS_ID ) );

    UPDATE ego_page_entries_interface
    SET    process_status = G_ERROR_RECORD,
           last_updated_by = G_USER_ID,
           last_update_date = SYSDATE,
           last_update_login = G_LOGIN_ID
    WHERE  (transaction_type IS NULL
     	   OR transaction_type NOT IN ( G_OPR_CREATE, G_OPR_UPDATE, G_OPR_SYNC, G_OPR_DELETE ))
           AND transaction_id IS NOT NULL
           AND process_status = G_PROCESS_RECORD
           AND ( ( G_SET_PROCESS_ID IS NULL )
                  OR ( set_process_id = G_SET_PROCESS_ID ) );

    write_debug('ego_pages_bulkload_pvt.'||lv_proc||' - '||'Exit Validate_transaction_type');
  EXCEPTION
    WHEN OTHERS THEN
               write_debug('ego_pages_bulkload_pvt.'||lv_proc||' - '||'Validate_transaction_type Exception when others'||SQLERRM);

               x_return_status := G_RET_STS_UNEXP_ERROR;

               x_return_msg := 'ego_pages_bulkload_pvt.Validate_transaction_type - '||SQLERRM;

               RETURN;
  END Validate_transaction_type;

  /*This procedure is used for value to ID conversion for Pages.
  	Used in the interface flow.
  	x_return_status OUT NOCOPY parameter that returns the status*/
  PROCEDURE value_to_id_pages (x_return_status OUT NOCOPY VARCHAR2, x_return_msg OUT NOCOPY VARCHAR2)
  IS
    lv_smt NUMBER; --Statement counter
    lv_proc VARCHAR2(30) := 'value_to_id_pages';
  BEGIN
    write_debug('ego_pages_bulkload_pvt.'||lv_proc||' - '||'Entering Value_to_id_pg');

    x_return_status := G_RET_STS_SUCCESS;

    /*Get the ICC ID from the Concatenated ICC Name*/
    lv_smt := 1;

    write_debug('ego_pages_bulkload_pvt.'||lv_proc||' - '||'Statement 1');

    UPDATE ego_pages_interface epi
    SET    classification_code = EGO_ICC_BULKLOAD_PVT.Get_Catalog_Group_Id(classification_name,'FIND_COMBINATION'),
           last_updated_by = G_USER_ID,
           last_update_date = SYSDATE,
           last_update_login = G_LOGIN_ID
    WHERE  classification_name IS NOT NULL
    	   AND classification_code IS NULL
           AND process_status = G_PROCESS_RECORD
           AND ( ( G_SET_PROCESS_ID IS NULL )
                  OR ( set_process_id = G_SET_PROCESS_ID ) );

    /*Get the page ID and set SYNC to UPDATE*/
    lv_smt := 2;

    write_debug('ego_pages_bulkload_pvt.'||lv_proc||' - '||'Statement 2');

    UPDATE ego_pages_interface epi
    SET    page_id = (SELECT page_id
                      FROM   ego_pages_b
                      WHERE  object_id = G_OBJECT_ID
                             AND internal_name = epi.internal_name
                             AND classification_code = epi.classification_code),
           last_updated_by = G_USER_ID,
           last_update_date = SYSDATE,
           last_update_login = G_LOGIN_ID
    WHERE  transaction_type <> G_OPR_CREATE
           AND ( ( page_id IS NULL
                   AND internal_name IS NOT NULL
                   AND classification_code IS NOT NULL )
                  OR page_id IS NOT NULL )
           AND process_status = G_PROCESS_RECORD
           AND ( ( G_SET_PROCESS_ID IS NULL )
                  OR ( set_process_id = G_SET_PROCESS_ID ) );

    /*Set SYNC to CREATE and UPDATE*/
    lv_smt := 3;

    write_debug('ego_pages_bulkload_pvt.'||lv_proc||' - '||'Statement 3');

    UPDATE ego_pages_interface epi
    SET    transaction_type = decode(page_id,NULL,G_OPR_CREATE,G_OPR_UPDATE),
           last_updated_by = G_USER_ID,
           last_update_date = SYSDATE,
           last_update_login = G_LOGIN_ID
    WHERE  transaction_type = G_OPR_SYNC
           AND process_status = G_PROCESS_RECORD
           AND ( ( G_SET_PROCESS_ID IS NULL )
                  OR ( set_process_id = G_SET_PROCESS_ID ) );

  write_debug('ego_pages_bulkload_pvt.'||lv_proc||' - '||'Exit Value_to_id_pg');
  EXCEPTION
    WHEN OTHERS THEN
               write_debug('ego_pages_bulkload_pvt.'||lv_proc||' - '||'value_to_id_pages Exception when others'||SQLERRM);

               x_return_status := G_RET_STS_UNEXP_ERROR;

               x_return_msg := 'ego_pages_bulkload_pvt.value_to_id_pages - '||SQLERRM;

               RETURN;
  END value_to_id_pages;

  /*This procedure is used for the value to ID conversion for Page Entries.
  	Used in the interface flow.
  	x_return_status OUT NOCOPY parameter that returns the status*/
  PROCEDURE value_to_id_pg_entries (x_return_status OUT NOCOPY VARCHAR2, x_return_msg OUT NOCOPY VARCHAR2)
  IS
    lv_smt NUMBER; --Statement counter
    lv_proc VARCHAR2(30) := 'value_to_id_pg_entries';
  BEGIN

  	write_debug('ego_pages_bulkload_pvt.'||lv_proc||' - '||'Entering value_to_id_pg_entries');

    /*Get the ICC ID from the Concatenated ICC Name*/
    lv_smt := 1;

    write_debug('ego_pages_bulkload_pvt.'||lv_proc||' - '||'Statement 1');

    x_return_status := G_RET_STS_SUCCESS;

    UPDATE ego_page_entries_interface epi
    SET    classification_code = EGO_ICC_BULKLOAD_PVT.Get_Catalog_Group_Id(classification_name,'FIND_COMBINATION'),
           last_updated_by = G_USER_ID,
           last_update_date = SYSDATE,
           last_update_login = G_LOGIN_ID
    WHERE  classification_name IS NOT NULL
    	   AND classification_code IS NULL
           AND process_status = G_PROCESS_RECORD
           AND ( ( G_SET_PROCESS_ID IS NULL )
                  OR ( set_process_id = G_SET_PROCESS_ID ) );

    /*Get the page ID*/
    lv_smt := 2;

    write_debug('ego_pages_bulkload_pvt.'||lv_proc||' - '||'Statement 2');

    UPDATE ego_page_entries_interface epi
    SET    page_id = (SELECT page_id
                      FROM   ego_pages_b
                      WHERE  object_id = G_OBJECT_ID
                             AND internal_name = epi.internal_name
                             AND classification_code = epi.classification_code),
           last_updated_by = G_USER_ID,
           last_update_date = SYSDATE,
           last_update_login = G_LOGIN_ID
    WHERE  page_id IS NULL
    	   AND internal_name IS NOT NULL
           AND classification_code IS NOT NULL
           AND process_status = G_PROCESS_RECORD
           AND ( ( G_SET_PROCESS_ID IS NULL )
                  OR ( set_process_id = G_SET_PROCESS_ID ) );

    /*Sets the old_attr_group_id*/
    lv_smt := 3;

    write_debug('ego_pages_bulkload_pvt.'||lv_proc||' - '||'Statement 3');

    UPDATE ego_page_entries_interface epi
    SET    old_attr_group_id = (SELECT attr_group_id
                                FROM   ego_fnd_dsc_flx_ctx_ext
                                WHERE  application_id = (SELECT application_id
                                                         FROM   fnd_application
                                                         WHERE  application_short_name = 'EGO')
                                       AND descriptive_flexfield_name = 'EGO_ITEMMGMT_GROUP'
                                       AND descriptive_flex_context_code = epi.old_attr_group_name),
           last_updated_by = G_USER_ID,
           last_update_date = SYSDATE,
           last_update_login = G_LOGIN_ID
    WHERE  old_attr_group_id IS NULL
           AND old_attr_group_name IS NOT NULL
           AND process_status = G_PROCESS_RECORD
           AND ( ( G_SET_PROCESS_ID IS NULL )
                  OR ( set_process_id = G_SET_PROCESS_ID ) );

    /*Sets the new_attr_group_id*/
    lv_smt := 4;

    write_debug('ego_pages_bulkload_pvt.'||lv_proc||' - '||'Statement 4');

    UPDATE ego_page_entries_interface epi
    SET    new_attr_group_id = (SELECT attr_group_id
                                FROM   ego_fnd_dsc_flx_ctx_ext
                                WHERE  application_id = (SELECT application_id
                                                         FROM   fnd_application
                                                         WHERE  application_short_name = 'EGO')
                                       AND descriptive_flexfield_name = 'EGO_ITEMMGMT_GROUP'
                                       AND descriptive_flex_context_code = epi.new_attr_group_name),
           last_updated_by = G_USER_ID,
           last_update_date = SYSDATE,
           last_update_login = G_LOGIN_ID
    WHERE  new_attr_group_id IS NULL
           AND new_attr_group_name IS NOT NULL
           AND process_status = G_PROCESS_RECORD
           AND ( ( G_SET_PROCESS_ID IS NULL )
                  OR ( set_process_id = G_SET_PROCESS_ID ) );

    lv_smt := 5;

    write_debug('ego_pages_bulkload_pvt.'||lv_proc||' - '||'Statement 5');

    /*Sets the old_association_id*/
    UPDATE ego_page_entries_interface epi
    SET    old_association_id = (SELECT association_id
    							 FROM EGO_OBJ_AG_ASSOCS_B
    							 WHERE classification_code IN ( SELECT PARENT_CATALOG_GROUP_ID
																FROM EGO_ITEM_CAT_DENORM_HIER
																WHERE CHILD_CATALOG_GROUP_ID = epi.classification_code)
    							 AND attr_group_id = epi.old_attr_group_id
    							 AND data_level = (SELECT data_level
    							 				   FROM ego_pages_b
    							 				   WHERE page_id = epi.page_id)),
           last_updated_by = G_USER_ID,
           last_update_date = SYSDATE,
           last_update_login = G_LOGIN_ID
    WHERE  old_association_id IS NULL
    	   AND old_attr_group_id IS NOT NULL
    	   AND classification_code IS NOT NULL
           AND process_status = G_PROCESS_RECORD
           AND ( ( G_SET_PROCESS_ID IS NULL )
                  OR ( set_process_id = G_SET_PROCESS_ID ) );

    lv_smt := 6;

    write_debug('ego_pages_bulkload_pvt.'||lv_proc||' - '||'Statement 6');

    /*Sets the new_association_id*/
    UPDATE ego_page_entries_interface epi
    SET    new_association_id = (SELECT association_id
    							 FROM EGO_OBJ_AG_ASSOCS_B
    							 WHERE classification_code  IN ( SELECT PARENT_CATALOG_GROUP_ID
																FROM EGO_ITEM_CAT_DENORM_HIER
																WHERE CHILD_CATALOG_GROUP_ID = epi.classification_code)
    							 AND attr_group_id = epi.new_attr_group_id
    							 AND data_level = (SELECT data_level
    							 				   FROM ego_pages_b
    							 				   WHERE page_id = epi.page_id)),
           last_updated_by = G_USER_ID,
           last_update_date = SYSDATE,
           last_update_login = G_LOGIN_ID
    WHERE  new_association_id IS NULL
    	   AND new_attr_group_id IS NOT NULL
    	   AND classification_code IS NOT NULL
           AND process_status = G_PROCESS_RECORD
           AND ( ( G_SET_PROCESS_ID IS NULL )
                  OR ( set_process_id = G_SET_PROCESS_ID ) );

    /*Sets the SYNC to UPDATE*/
    lv_smt := 7;

    write_debug('ego_pages_bulkload_pvt.'||lv_proc||' - '||'Statement 7');

    UPDATE ego_page_entries_interface epi
    SET    transaction_type = G_OPR_UPDATE,
           last_updated_by = G_USER_ID,
           last_update_date = SYSDATE,
           last_update_login = G_LOGIN_ID
    WHERE  EXISTS (SELECT 1
                   FROM   ego_page_entries_b
                   WHERE  page_id = epi.page_id
                          AND association_id = epi.old_association_id)
           AND transaction_type = G_OPR_SYNC
           AND process_status = G_PROCESS_RECORD
           AND ( ( G_SET_PROCESS_ID IS NULL )
                  OR ( set_process_id = G_SET_PROCESS_ID ) );

    /*Sets the SYNC to CREATE*/
    lv_smt := 8;

    write_debug('ego_pages_bulkload_pvt.'||lv_proc||' - '||'Statement 8');

    UPDATE ego_page_entries_interface epi
    SET    transaction_type = G_OPR_CREATE,
           last_updated_by = G_USER_ID,
           last_update_date = SYSDATE,
           last_update_login = G_LOGIN_ID
    WHERE  transaction_type = G_OPR_SYNC
           AND process_status = G_PROCESS_RECORD
           AND ( ( G_SET_PROCESS_ID IS NULL )
                  OR ( set_process_id = G_SET_PROCESS_ID ) );

    write_debug('ego_pages_bulkload_pvt.'||lv_proc||' - '||'Exit value_to_id_pg_entries');
  EXCEPTION
    WHEN OTHERS THEN
       write_debug('ego_pages_bulkload_pvt.'||lv_proc||' - '||'value_to_id_pg_entries Exception when others'||SQLERRM);

       x_return_status := G_RET_STS_UNEXP_ERROR;

       x_return_msg := 'ego_pages_bulkload_pvt.value_to_id_pg_entries - '||SQLERRM;

       RETURN;
  END value_to_id_pg_entries;

  /*This procedure is used for constructing the records for pages.
  	Used in the interface flow.
  	x_return_status OUT NOCOPY parameter that returns the status*/
  PROCEDURE construct_pages (x_return_status OUT NOCOPY VARCHAR2, x_return_msg OUT NOCOPY VARCHAR2)
  IS
    lv_smt NUMBER; --Statement counter
    lv_proc VARCHAR2(30) := 'construct_pages';
  BEGIN
    write_debug('ego_pages_bulkload_pvt.'||lv_proc||' - '||'Entering construct_pages');

    /*Set the Page internal name when the page id is given*/
    lv_smt := 1;

    write_debug('ego_pages_bulkload_pvt.'||lv_proc||' - '||'Statement 1');

    x_return_status := G_RET_STS_SUCCESS;

    UPDATE ego_pages_interface epi
    SET    (internal_name, classification_code) = (SELECT internal_name, classification_code
				                                    FROM   ego_pages_v
				                                    WHERE  page_id = epi.page_id),
           last_updated_by = G_USER_ID,
           last_update_date = SYSDATE,
           last_update_login = G_LOGIN_ID
    WHERE  page_id IS NOT NULL
           AND process_status = G_PROCESS_RECORD
           AND ( ( G_SET_PROCESS_ID IS NULL )
                  OR ( set_process_id = G_SET_PROCESS_ID ) );

    /*Sets the classification name if the classification code is given*/
    lv_smt := 2;

    write_debug('ego_pages_bulkload_pvt.'||lv_proc||' - '||'Statement 2');

    UPDATE ego_pages_interface epi
    SET    classification_name = (SELECT icc_kfv.concatenated_segments
                                  FROM   mtl_item_catalog_groups_kfv icc_kfv
                                  WHERE icc_kfv.item_catalog_group_id = epi.classification_code),
           last_updated_by = G_USER_ID,
           last_update_date = SYSDATE,
           last_update_login = G_LOGIN_ID
    WHERE  classification_code IS NOT NULL
           AND process_status = G_PROCESS_RECORD
           AND ( ( G_SET_PROCESS_ID IS NULL )
                  OR ( set_process_id = G_SET_PROCESS_ID ) );

  	 write_debug('ego_pages_bulkload_pvt.'||lv_proc||' - '||'Exit construct_pages');
  EXCEPTION
    WHEN OTHERS THEN
       write_debug('ego_pages_bulkload_pvt.'||lv_proc||' - '||'construct_pages Exception when others'||SQLERRM);

       x_return_status := G_RET_STS_UNEXP_ERROR;

       x_return_msg := 'ego_pages_bulkload_pvt.construct_pages - '||SQLERRM;

       RETURN;
  END construct_pages;

  /*This procedure is used for constrcting the records for page entries.
  	Used in the interface flow.
  	x_return_status OUT NOCOPY parameter that returns the status*/
  PROCEDURE construct_pg_entries (x_return_status OUT NOCOPY VARCHAR2, x_return_msg OUT NOCOPY VARCHAR2)
  IS
    lv_smt NUMBER; --Statement counter
    lv_proc VARCHAR2(30) := 'construct_pg_entries';
  BEGIN

    write_debug('ego_pages_bulkload_pvt.'||lv_proc||' - '||'Entering construct_pg_entries');

    /*Sets the internal_name and the classification_code with the page_id is given*/

  	lv_smt := 1;

    write_debug('ego_pages_bulkload_pvt.'||lv_proc||' - '||'Statement 1');

    x_return_status := G_RET_STS_SUCCESS;

    UPDATE ego_page_entries_interface epi
    SET    ( internal_name, classification_code ) = (SELECT internal_name,
                                                            classification_code
                                                     FROM   ego_pages_b
                                                     WHERE  page_id = epi.page_id),
           last_updated_by = G_USER_ID,
           last_update_date = SYSDATE,
           last_update_login = G_LOGIN_ID
    WHERE  page_id IS NOT NULL
           AND process_status = G_PROCESS_RECORD
           AND ( ( G_SET_PROCESS_ID IS NULL )
                  OR ( set_process_id = G_SET_PROCESS_ID ) );

    /*Sets the classification name if the classification code is given*/
    lv_smt := 2;

    write_debug('ego_pages_bulkload_pvt.'||lv_proc||' - '||'Statement 2');

    UPDATE ego_page_entries_interface epi
    SET    classification_name = (SELECT icc_kfv.concatenated_segments
                                  FROM   mtl_item_catalog_groups_kfv icc_kfv
                                  WHERE icc_kfv.item_catalog_group_id = epi.classification_code),
           last_updated_by = G_USER_ID,
           last_update_date = SYSDATE,
           last_update_login = G_LOGIN_ID
    WHERE  classification_code IS NOT NULL
           AND process_status = G_PROCESS_RECORD
           AND ( ( G_SET_PROCESS_ID IS NULL )
                  OR ( set_process_id = G_SET_PROCESS_ID ) );

    /*Sets the old_attr_group_id and old_attr_group_name, if the old_association_id is given*/
    lv_smt := 3;

    write_debug('ego_pages_bulkload_pvt.'||lv_proc||' - '||'Statement 3');

    UPDATE ego_page_entries_interface epi
    SET    ( old_attr_group_id, old_attr_group_name ) = (SELECT attr_group_id,
                                                                attr_group_name
                                                         FROM   ego_obj_attr_grp_assocs_v
                                                         WHERE  association_id = epi.old_association_id),
           last_updated_by = G_USER_ID,
           last_update_date = SYSDATE,
           last_update_login = G_LOGIN_ID
    WHERE  old_association_id IS NOT NULL
           AND process_status = G_PROCESS_RECORD
           AND ( ( G_SET_PROCESS_ID IS NULL )
                  OR ( set_process_id = G_SET_PROCESS_ID ) );

    /*Sets the new_attr_group_id and new_attr_group_name, if the new_association_id is given*/
    lv_smt := 4;

    write_debug('ego_pages_bulkload_pvt.'||lv_proc||' - '||'Statement 4');

    UPDATE ego_page_entries_interface epi
    SET    ( new_attr_group_id, new_attr_group_name ) = (SELECT attr_group_id,
                                                                attr_group_name
                                                         FROM   ego_obj_attr_grp_assocs_v
                                                         WHERE  association_id = epi.new_association_id),
           last_updated_by = G_USER_ID,
           last_update_date = SYSDATE,
           last_update_login = G_LOGIN_ID
    WHERE  new_association_id IS NOT NULL
           AND process_status = G_PROCESS_RECORD
           AND ( ( G_SET_PROCESS_ID IS NULL )
                  OR ( set_process_id = G_SET_PROCESS_ID ) );

	/*Sets the old_attr_group_name and old_association_id, if the old_attr_group_id is given*/
    lv_smt := 5;

    write_debug('ego_pages_bulkload_pvt.'||lv_proc||' - '||'Statement 5');

    UPDATE ego_page_entries_interface epi
    SET    ( old_association_id, old_attr_group_name ) = (SELECT association_id,
                                                                attr_group_name
                                                         FROM   ego_obj_attr_grp_assocs_v
                                                         WHERE  attr_group_id = epi.old_attr_group_id
                                                         AND classification_code = epi.classification_code),
           last_updated_by = G_USER_ID,
           last_update_date = SYSDATE,
           last_update_login = G_LOGIN_ID
    WHERE  old_attr_group_id IS NOT NULL
    	   AND old_attr_group_name IS NULL
    	   AND old_association_id IS NULL
           AND process_status = G_PROCESS_RECORD
           AND ( ( G_SET_PROCESS_ID IS NULL )
                  OR ( set_process_id = G_SET_PROCESS_ID ) );

    /*Sets the new_attr_group_name and new_association_id, if the new_attr_group_id is given*/
    lv_smt := 5;

    write_debug('ego_pages_bulkload_pvt.'||lv_proc||' - '||'Statement 5');

    UPDATE ego_page_entries_interface epi
    SET    ( new_association_id, new_attr_group_name ) = (SELECT association_id,
                                                                attr_group_name
                                                         FROM   ego_obj_attr_grp_assocs_v
                                                         WHERE  attr_group_id = epi.new_attr_group_id),
           last_updated_by = G_USER_ID,
           last_update_date = SYSDATE,
           last_update_login = G_LOGIN_ID
    WHERE  new_attr_group_id IS NOT NULL
    	   AND new_attr_group_name IS NULL
    	   AND new_association_id IS NULL
           AND process_status = G_PROCESS_RECORD
           AND ( ( G_SET_PROCESS_ID IS NULL )
                  OR ( set_process_id = G_SET_PROCESS_ID ) );

  write_debug('ego_pages_bulkload_pvt.'||lv_proc||' - '||'Exit construct_pg_entries');
  EXCEPTION
    WHEN OTHERS THEN
       write_debug('ego_pages_bulkload_pvt.'||lv_proc||' - '||'construct_pg_entries Exception when others'||SQLERRM);

       x_return_status := G_RET_STS_UNEXP_ERROR;

       x_return_msg := 'ego_pages_bulkload_pvt.construct_pg_entries - '||SQLERRM;

       RETURN;
  END construct_pg_entries;

  /*This procedure is used to construct the records for page pl/sql table.
    p_pg_tbl        IN OUT NOCOPY Pages table
  	x_return_status OUT NOCOPY parameter that returns the status*/
  PROCEDURE construct_page_tbl(
   p_pg_tbl        IN OUT NOCOPY ego_metadata_pub.ego_pg_tbl,
   x_return_status OUT NOCOPY VARCHAR2, x_return_msg OUT NOCOPY VARCHAR2)
   IS
   	lv_proc VARCHAR2(30) := 'construct_page_tbl';
   BEGIN
   	write_debug('ego_pages_bulkload_pvt.'||lv_proc||' - '||'Entering construct_page_tbl');

    x_return_status := G_RET_STS_SUCCESS;

    FOR i IN p_pg_tbl.FIRST.. p_pg_tbl.LAST LOOP
    	IF (p_pg_tbl(i).process_status = G_PROCESS_RECORD) THEN
    		/*Set the Page internal name when the page id is given*/
    		IF (p_pg_tbl(i).page_id  IS NOT NULL) THEN
    			BEGIN
    				SELECT internal_name, classification_code INTO p_pg_tbl(i).internal_name, p_pg_tbl(i).classification_code
				    FROM   ego_pages_v
				    WHERE  page_id = p_pg_tbl(i).page_id;
    			EXCEPTION
    				WHEN NO_DATA_FOUND THEN
    					x_return_status := G_RET_STS_ERROR;

						write_debug('ego_pages_bulkload_pvt.'||lv_proc||' - Err_msg_TID: '||p_pg_tbl(i).transaction_id||' (PG) = ('||p_pg_tbl(i).internal_name||'). ' ||'Page is not defined in the system');

						error_handler.Add_error_message(p_message_name => 'EGO_PG_NOT_EXIST',p_application_id => G_EGO_APPLICATION_ID,
	                                                  p_token_tbl => G_TOKEN_TABLE,p_message_type => G_RET_STS_ERROR,
	                                                  p_row_identifier => p_pg_tbl(i).transaction_id,
	                                                  p_entity_code => G_ENTITY_PG,p_table_name => G_ENTITY_PG_TAB);
                 	WHEN OTHERS THEN
    					x_return_status := G_RET_STS_UNEXP_ERROR;

						write_debug('ego_pages_bulkload_pvt.'||lv_proc||' - Err_msg_TID: '||p_pg_tbl(i).transaction_id||' (PG) = ('||p_pg_tbl(i).internal_name||'). ' ||'Exception: '||SQLERRM);

						error_handler.Add_error_message(p_message_text => SQLERRM,p_application_id => G_EGO_APPLICATION_ID,
                                                  p_token_tbl => G_TOKEN_TABLE,p_message_type => G_RET_STS_UNEXP_ERROR,
                                                  p_row_identifier => p_pg_tbl(i).transaction_id,
                                                  p_entity_code => G_ENTITY_PG,p_table_name => G_ENTITY_PG_TAB);

						x_return_msg := 'ego_pages_bulkload_pvt.construct_page_tbl smt 1 - '||SQLERRM;

       					RETURN;

    			END;
    		END IF;

    		/*Sets the classification name if the classification code is given*/
    		IF (p_pg_tbl(i).classification_code  IS NOT NULL) THEN
    			BEGIN
    				SELECT icc_kfv.concatenated_segments INTO p_pg_tbl(i).classification_name
                    FROM   mtl_item_catalog_groups_kfv icc_kfv
                    WHERE icc_kfv.item_catalog_group_id = p_pg_tbl(i).classification_code;
    			EXCEPTION
    				WHEN NO_DATA_FOUND THEN
    					x_return_status := G_RET_STS_ERROR;

						write_debug('ego_pages_bulkload_pvt.'||lv_proc||' - Err_msg_TID: '||p_pg_tbl(i).transaction_id||' (PG,ICC) = ('||p_pg_tbl(i).internal_name||','||p_pg_tbl(i).classification_code||'). ' ||'ICC is not defined in the system');

						error_handler.Add_error_message(p_message_name => 'EGO_PG_ICC_INVALID',p_application_id => G_EGO_APPLICATION_ID,
	                                                  p_token_tbl => G_TOKEN_TABLE,p_message_type => G_RET_STS_ERROR,
	                                                  p_row_identifier => p_pg_tbl(i).transaction_id,
	                                                  p_entity_code => G_ENTITY_PG,p_table_name => G_ENTITY_PG_TAB);
                 	WHEN OTHERS THEN
    					x_return_status := G_RET_STS_UNEXP_ERROR;

						write_debug('ego_pages_bulkload_pvt.'||lv_proc||' - Err_msg_TID: '||p_pg_tbl(i).transaction_id||' (PG,ICC) = ('||p_pg_tbl(i).internal_name||','||p_pg_tbl(i).classification_code||'). ' ||'Exception: '||SQLERRM);

						error_handler.Add_error_message(p_message_text => SQLERRM,p_application_id => G_EGO_APPLICATION_ID,
                                                  p_token_tbl => G_TOKEN_TABLE,p_message_type => G_RET_STS_UNEXP_ERROR,
                                                  p_row_identifier => p_pg_tbl(i).transaction_id,
                                                  p_entity_code => G_ENTITY_PG,p_table_name => G_ENTITY_PG_TAB);

                        x_return_msg := 'ego_pages_bulkload_pvt.construct_page_tbl smt 2 - '||SQLERRM;

       					RETURN;
    			END;
    		END IF;
    	END IF;
    END LOOP;

    write_debug('ego_pages_bulkload_pvt.'||lv_proc||' - '||'Exit construct_page_tbl');
   EXCEPTION
   	WHEN OTHERS THEN
   	   write_debug('ego_pages_bulkload_pvt.'||lv_proc||' - '||'construct_page_tbl Exception when others'||SQLERRM);

       x_return_status := G_RET_STS_UNEXP_ERROR;

       x_return_msg := 'ego_pages_bulkload_pvt.construct_page_tbl - '||SQLERRM;

       RETURN;
   END construct_page_tbl;

   /*This procedure is used sed to construct the records for page entries pl/sql table.
  	Used in the API flow.
  	p_ent_tbl       IN OUT NOCOPY Page Entries table
  	x_return_status OUT NOCOPY parameter that returns the status*/
  PROCEDURE construct_pg_entries_tbl(
   p_ent_tbl       IN OUT NOCOPY ego_metadata_pub.ego_ent_tbl,
   x_return_status OUT NOCOPY VARCHAR2, x_return_msg OUT NOCOPY VARCHAR2)
   IS
   	lv_proc VARCHAR2(30) := 'construct_pg_entries_tbl';
   BEGIN
   	write_debug('ego_pages_bulkload_pvt.'||lv_proc||' - '||'Entering construct_pg_entries_tbl');

    x_return_status := G_RET_STS_SUCCESS;

    FOR i IN p_ent_tbl.FIRST.. p_ent_tbl.LAST LOOP
    	IF (p_ent_tbl(i).process_status = G_PROCESS_RECORD) THEN
    		/*Set the Page internal name when the page id is given*/
    		IF (p_ent_tbl(i).page_id  IS NOT NULL) THEN
    			BEGIN
    				SELECT internal_name, classification_code INTO p_ent_tbl(i).internal_name, p_ent_tbl(i).classification_code
				    FROM   ego_pages_v
				    WHERE  page_id = p_ent_tbl(i).page_id;
    			EXCEPTION
    				WHEN NO_DATA_FOUND THEN
    					x_return_status := G_RET_STS_ERROR;

						write_debug('ego_pages_bulkload_pvt.'||lv_proc||' - Err_msg_TID: '||p_ent_tbl(i).transaction_id||' (PG) = ('||p_ent_tbl(i).internal_name||'). ' ||'Page is not defined in the system');

						error_handler.Add_error_message(p_message_name => 'EGO_PG_NOT_EXIST',p_application_id => G_EGO_APPLICATION_ID,
	                                                  p_token_tbl => G_TOKEN_TABLE,p_message_type => G_RET_STS_ERROR,
	                                                  p_row_identifier => p_ent_tbl(i).transaction_id,
	                                                  p_entity_code => G_ENTITY_ENT,p_table_name => G_ENTITY_ENT_TAB);
                 	WHEN OTHERS THEN
    					x_return_status := G_RET_STS_UNEXP_ERROR;

						write_debug('ego_pages_bulkload_pvt.'||lv_proc||' - Err_msg_TID: '||p_ent_tbl(i).transaction_id||' (PG) = ('||p_ent_tbl(i).internal_name||'). ' ||'Exception: '||SQLERRM);

						error_handler.Add_error_message(p_message_text => SQLERRM,p_application_id => G_EGO_APPLICATION_ID,
                                                  p_token_tbl => G_TOKEN_TABLE,p_message_type => G_RET_STS_UNEXP_ERROR,
                                                  p_row_identifier => p_ent_tbl(i).transaction_id,
                                                  p_entity_code => G_ENTITY_ENT,p_table_name => G_ENTITY_ENT_TAB);

                        x_return_msg := 'ego_pages_bulkload_pvt.construct_pg_entries_tbl smt 1 - '||SQLERRM;

       					RETURN;

    			END;
    		END IF;

    		/*Sets the classification name if the classification code is given*/
    		IF (p_ent_tbl(i).classification_code  IS NOT NULL) THEN
    			BEGIN
    				SELECT icc_kfv.concatenated_segments INTO p_ent_tbl(i).classification_name
                    FROM   mtl_item_catalog_groups_kfv icc_kfv
                    WHERE icc_kfv.item_catalog_group_id = p_ent_tbl(i).classification_code;
    			EXCEPTION
    				WHEN NO_DATA_FOUND THEN
    					x_return_status := G_RET_STS_ERROR;

						write_debug('ego_pages_bulkload_pvt.'||lv_proc||' - Err_msg_TID: '||p_ent_tbl(i).transaction_id||' (PG,ICC) = ('||p_ent_tbl(i).internal_name||','||p_ent_tbl(i).classification_code||'). ' ||'ICC is not defined in the system');

						error_handler.Add_error_message(p_message_name => 'EGO_PG_ICC_INVALID',p_application_id => G_EGO_APPLICATION_ID,
	                                                  p_token_tbl => G_TOKEN_TABLE,p_message_type => G_RET_STS_ERROR,
	                                                  p_row_identifier => p_ent_tbl(i).transaction_id,
	                                                  p_entity_code => G_ENTITY_ENT,p_table_name => G_ENTITY_ENT_TAB);
                 	WHEN OTHERS THEN
    					x_return_status := G_RET_STS_UNEXP_ERROR;

						write_debug('ego_pages_bulkload_pvt.'||lv_proc||' - '||'construct_pg_entries_tbl exception when others smt 2');

						error_handler.Add_error_message(p_message_text => SQLERRM,p_application_id => G_EGO_APPLICATION_ID,
                                                  p_token_tbl => G_TOKEN_TABLE,p_message_type => G_RET_STS_UNEXP_ERROR,
                                                  p_row_identifier => p_ent_tbl(i).transaction_id,
                                                  p_entity_code => G_ENTITY_ENT,p_table_name => G_ENTITY_ENT_TAB);

                        x_return_msg := 'ego_pages_bulkload_pvt.construct_pg_entries_tbl smt 2 - '||SQLERRM;

       					RETURN;
    			END;
    		END IF;

    		/*Sets the old_attr_group_id and old_attr_group_name, if the old_association_id is given*/
    		IF (p_ent_tbl(i).old_association_id  IS NOT NULL) THEN
    			BEGIN
    				SELECT attr_group_id,attr_group_name INTO p_ent_tbl(i).old_attr_group_id, p_ent_tbl(i).old_attr_group_name
                    FROM   ego_obj_attr_grp_assocs_v
                    WHERE  association_id = p_ent_tbl(i).old_association_id;
    			EXCEPTION
    				WHEN NO_DATA_FOUND THEN
    					x_return_status := G_RET_STS_ERROR;

						write_debug('ego_pages_bulkload_pvt.'||lv_proc||' - Err_msg_TID: '||p_ent_tbl(i).transaction_id||' (PG,AG) = ('||p_ent_tbl(i).internal_name||','||p_ent_tbl(i).old_association_id||'). ' ||'Attribute Association is not defined in the system');

						error_handler.Add_error_message(p_message_name => 'EGO_PG_ASSOC_NOT_EXIST',p_application_id => G_EGO_APPLICATION_ID,
	                                                  p_token_tbl => G_TOKEN_TABLE,p_message_type => G_RET_STS_ERROR,
	                                                  p_row_identifier => p_ent_tbl(i).transaction_id,
	                                                  p_entity_code => G_ENTITY_ENT,p_table_name => G_ENTITY_ENT_TAB);
                 	WHEN OTHERS THEN
    					x_return_status := G_RET_STS_UNEXP_ERROR;

						write_debug('ego_pages_bulkload_pvt.'||lv_proc||' - '||'construct_pg_entries_tbl exception when others smt 3');

						error_handler.Add_error_message(p_message_text => SQLERRM,p_application_id => G_EGO_APPLICATION_ID,
                                                  p_token_tbl => G_TOKEN_TABLE,p_message_type => G_RET_STS_UNEXP_ERROR,
                                                  p_row_identifier => p_ent_tbl(i).transaction_id,
                                                  p_entity_code => G_ENTITY_ENT,p_table_name => G_ENTITY_ENT_TAB);

                        x_return_msg := 'ego_pages_bulkload_pvt.construct_pg_entries_tbl smt 3 - '||SQLERRM;

       					RETURN;
    			END;
    		END IF;

    		/*Sets the new_attr_group_id and new_attr_group_name, if the new_association_id is given*/
    		IF (p_ent_tbl(i).old_association_id  IS NOT NULL) THEN
    			BEGIN
    				SELECT attr_group_id,attr_group_name INTO p_ent_tbl(i).new_attr_group_id, p_ent_tbl(i).new_attr_group_name
                    FROM   ego_obj_attr_grp_assocs_v
                    WHERE  association_id = p_ent_tbl(i).new_association_id;
    			EXCEPTION
    				WHEN NO_DATA_FOUND THEN
    					x_return_status := G_RET_STS_ERROR;

						write_debug('ego_pages_bulkload_pvt.'||lv_proc||' - Err_msg_TID: '||p_ent_tbl(i).transaction_id||' (PG,ICC) = ('||p_ent_tbl(i).internal_name||','||p_ent_tbl(i).new_association_id||'). ' ||'Attribute Association is not defined in the system');

						error_handler.Add_error_message(p_message_name => 'EGO_PG_ASSOC_NOT_EXIST',p_application_id => G_EGO_APPLICATION_ID,
	                                                  p_token_tbl => G_TOKEN_TABLE,p_message_type => G_RET_STS_ERROR,
	                                                  p_row_identifier => p_ent_tbl(i).transaction_id,
	                                                  p_entity_code => G_ENTITY_ENT,p_table_name => G_ENTITY_ENT_TAB);
                 	WHEN OTHERS THEN
    					x_return_status := G_RET_STS_UNEXP_ERROR;

						write_debug('ego_pages_bulkload_pvt.'||lv_proc||' - '||'construct_pg_entries_tbl exception when others smt 4');

						error_handler.Add_error_message(p_message_text => SQLERRM,p_application_id => G_EGO_APPLICATION_ID,
                                                  p_token_tbl => G_TOKEN_TABLE,p_message_type => G_RET_STS_UNEXP_ERROR,
                                                  p_row_identifier => p_ent_tbl(i).transaction_id,
                                                  p_entity_code => G_ENTITY_ENT,p_table_name => G_ENTITY_ENT_TAB);

                        x_return_msg := 'ego_pages_bulkload_pvt.construct_pg_entries_tbl smt 4 - '||SQLERRM;

       					RETURN;
    			END;
    		END IF;

    		/*Sets the old_attr_group_name and old_association_id, if the old_attr_group_id is given*/
    		IF (p_ent_tbl(i).old_attr_group_id  IS NOT NULL AND p_ent_tbl(i).old_attr_group_name IS NULL AND p_ent_tbl(i).old_association_id IS NULL) THEN
    			BEGIN
    				SELECT association_id,attr_group_name INTO p_ent_tbl(i).old_association_id, p_ent_tbl(i).old_attr_group_name
                    FROM   ego_obj_attr_grp_assocs_v
                    WHERE  attr_group_id = p_ent_tbl(i).old_attr_group_id
                    AND classification_code = p_ent_tbl(i).classification_code;
    			EXCEPTION
    				WHEN NO_DATA_FOUND THEN
    					x_return_status := G_RET_STS_ERROR;

						write_debug('ego_pages_bulkload_pvt.'||lv_proc||' - Err_msg_TID: '||p_ent_tbl(i).transaction_id||' (PG,AG) = ('||p_ent_tbl(i).internal_name||','||p_ent_tbl(i).old_association_id||'). ' ||'Attribute Association is not defined in the system');

						error_handler.Add_error_message(p_message_name => 'EGO_PG_ASSOC_NOT_EXIST',p_application_id => G_EGO_APPLICATION_ID,
	                                                  p_token_tbl => G_TOKEN_TABLE,p_message_type => G_RET_STS_ERROR,
	                                                  p_row_identifier => p_ent_tbl(i).transaction_id,
	                                                  p_entity_code => G_ENTITY_ENT,p_table_name => G_ENTITY_ENT_TAB);
                 	WHEN OTHERS THEN
    					x_return_status := G_RET_STS_UNEXP_ERROR;

						write_debug('ego_pages_bulkload_pvt.'||lv_proc||' - '||'construct_pg_entries_tbl exception when others smt 5');

						error_handler.Add_error_message(p_message_text => SQLERRM,p_application_id => G_EGO_APPLICATION_ID,
                                                  p_token_tbl => G_TOKEN_TABLE,p_message_type => G_RET_STS_UNEXP_ERROR,
                                                  p_row_identifier => p_ent_tbl(i).transaction_id,
                                                  p_entity_code => G_ENTITY_ENT,p_table_name => G_ENTITY_ENT_TAB);

                        x_return_msg := 'ego_pages_bulkload_pvt.construct_pg_entries_tbl smt 5 - '||SQLERRM;

       					RETURN;
    			END;
    		END IF;

    		/*Sets the new_attr_group_name and new_association_id, if the new_attr_group_id is given*/
    		IF (p_ent_tbl(i).new_attr_group_id  IS NOT NULL AND p_ent_tbl(i).new_attr_group_name IS NULL AND p_ent_tbl(i).new_association_id IS NULL) THEN
    			BEGIN
    				SELECT association_id,attr_group_name INTO p_ent_tbl(i).new_association_id, p_ent_tbl(i).new_attr_group_name
                    FROM   ego_obj_attr_grp_assocs_v
                    WHERE  attr_group_id = p_ent_tbl(i).new_attr_group_id
                    AND classification_code = p_ent_tbl(i).classification_code;
    			EXCEPTION
    				WHEN NO_DATA_FOUND THEN
    					x_return_status := G_RET_STS_ERROR;

						write_debug('ego_pages_bulkload_pvt.'||lv_proc||' - Err_msg_TID: '||p_ent_tbl(i).transaction_id||' (PG,ICC) = ('||p_ent_tbl(i).internal_name||','||p_ent_tbl(i).new_association_id||'). ' ||'Attribute Association is not defined in the system');

						error_handler.Add_error_message(p_message_name => 'EGO_PG_ASSOC_NOT_EXIST',p_application_id => G_EGO_APPLICATION_ID,
	                                                  p_token_tbl => G_TOKEN_TABLE,p_message_type => G_RET_STS_ERROR,
	                                                  p_row_identifier => p_ent_tbl(i).transaction_id,
	                                                  p_entity_code => G_ENTITY_ENT,p_table_name => G_ENTITY_ENT_TAB);
                 	WHEN OTHERS THEN
    					x_return_status := G_RET_STS_UNEXP_ERROR;

						write_debug('ego_pages_bulkload_pvt.'||lv_proc||' - '||'construct_pg_entries_tbl exception when others smt 6');

						error_handler.Add_error_message(p_message_text => SQLERRM,p_application_id => G_EGO_APPLICATION_ID,
                                                  p_token_tbl => G_TOKEN_TABLE,p_message_type => G_RET_STS_UNEXP_ERROR,
                                                  p_row_identifier => p_ent_tbl(i).transaction_id,
                                                  p_entity_code => G_ENTITY_ENT,p_table_name => G_ENTITY_ENT_TAB);

                        x_return_msg := 'ego_pages_bulkload_pvt.construct_pg_entries_tbl smt 6 - '||SQLERRM;

       					RETURN;
    			END;
    		END IF;

    	END IF;
    END LOOP;
    write_debug('ego_pages_bulkload_pvt.'||lv_proc||' - '||'Exit construct_pg_entries_tbl');
   EXCEPTION
   	WHEN OTHERS THEN
   		write_debug('ego_pages_bulkload_pvt.'||lv_proc||' - '||'construct_pg_entries_tbl Exception when others'||SQLERRM);

        x_return_status := G_RET_STS_UNEXP_ERROR;

        x_return_msg := 'ego_pages_bulkload_pvt.construct_pg_entries_tbl - '||SQLERRM;

       	RETURN;
   END construct_pg_entries_tbl;


  /*This procedure is used for value to ID conversion for pages.
  	Used in the API flow.
  	p_pg_tbl        IN OUT NOCOPY Pages table
  	x_return_status OUT NOCOPY parameter that returns the status*/
  PROCEDURE value_to_id_page_tbl (p_pg_tbl        IN OUT NOCOPY ego_metadata_pub.ego_pg_tbl,
                                x_return_status OUT NOCOPY VARCHAR2, x_return_msg OUT NOCOPY VARCHAR2)
  IS
  	lv_proc VARCHAR2(30) := 'value_to_id_page_tbl';
  BEGIN
    write_debug('ego_pages_bulkload_pvt.'||lv_proc||' - '||'Entering value_to_id_page_tbl');

    x_return_status := G_RET_STS_SUCCESS;

    FOR i IN p_pg_tbl.FIRST.. p_pg_tbl.LAST LOOP
    	IF (p_pg_tbl(i).process_status = G_PROCESS_RECORD) THEN
    		/*Get the ICC ID from the Concatenated ICC Name*/
    		IF (p_pg_tbl(i).classification_name  IS NOT NULL AND p_pg_tbl(i).classification_code IS NULL) THEN
    			p_pg_tbl(i).classification_code := EGO_ICC_BULKLOAD_PVT.Get_Catalog_Group_Id(p_pg_tbl(i).classification_name,'FIND_COMBINATION');
    		END IF;

    		/*Get the page ID and set SYNC to UPDATE*/
    		IF (p_pg_tbl(i).transaction_type <> G_OPR_CREATE) THEN
    			IF (p_pg_tbl(i).page_id IS NULL AND p_pg_tbl(i).internal_name  IS NOT NULL AND p_pg_tbl(i).classification_code  IS NOT NULL) THEN
    				BEGIN
    					SELECT page_id INTO p_pg_tbl(i).page_id
                      	FROM   ego_pages_b
                      	WHERE  object_id = G_OBJECT_ID
                        AND internal_name = p_pg_tbl(i).internal_name
                        AND classification_code = p_pg_tbl(i).classification_code;

                        IF (p_pg_tbl(i).transaction_type = G_OPR_SYNC) THEN
                        	p_pg_tbl(i).transaction_type := G_OPR_UPDATE;
                        END IF;
    				EXCEPTION
    					WHEN NO_DATA_FOUND THEN
    						IF (p_pg_tbl(i).transaction_type = G_OPR_SYNC) THEN
                        		p_pg_tbl(i).transaction_type := G_OPR_CREATE;
                        	ELSE
	    						x_return_status := G_RET_STS_ERROR;

								write_debug('ego_pages_bulkload_pvt.'||lv_proc||' - '||'Page is not defined in the system');

								error_handler.Add_error_message(p_message_name => 'EGO_PG_NOT_EXIST',p_application_id => G_EGO_APPLICATION_ID,
	                                                  p_token_tbl => G_TOKEN_TABLE,p_message_type => G_RET_STS_ERROR,
	                                                  p_row_identifier => p_pg_tbl(i).transaction_id,
	                                                  p_entity_code => G_ENTITY_PG,p_table_name => G_ENTITY_PG_TAB);
                            END IF;
    					WHEN OTHERS THEN
    						x_return_status := G_RET_STS_UNEXP_ERROR;

							write_debug('ego_pages_bulkload_pvt.'||lv_proc||' - '||'value_to_id_page_tbl exception when others smt 1');

							error_handler.Add_error_message(p_message_text => SQLERRM,p_application_id => G_EGO_APPLICATION_ID,
                                                  p_token_tbl => G_TOKEN_TABLE,p_message_type => G_RET_STS_UNEXP_ERROR,
                                                  p_row_identifier => p_pg_tbl(i).transaction_id,
                                                  p_entity_code => G_ENTITY_PG,p_table_name => G_ENTITY_PG_TAB);

                            x_return_msg := 'ego_pages_bulkload_pvt.value_to_id_page_tbl smt 1 - '||SQLERRM;

       						RETURN;
    				END;
    			END IF;
    		END IF;
    	END IF;
    END LOOP;

    write_debug('ego_pages_bulkload_pvt.'||lv_proc||' - '||'Exit value_to_id_page_tbl');
  EXCEPTION
    WHEN OTHERS THEN
       write_debug('ego_pages_bulkload_pvt.'||lv_proc||' - '||'value_to_id_page_tbl Exception when others'||SQLERRM);

       x_return_status := G_RET_STS_UNEXP_ERROR;

       x_return_msg := 'ego_pages_bulkload_pvt.value_to_id_page_tbl - '||SQLERRM;

       RETURN;
  END value_to_id_page_tbl;

  /*This procedure is used for value to ID conversion for page entries.
  	Used in the API flow.
  	p_ent_tbl       IN OUT NOCOPY Page Entries table
  	x_return_status OUT NOCOPY parameter that returns the status*/
  PROCEDURE value_to_id_pg_entries_tbl (p_ent_tbl       IN OUT NOCOPY ego_metadata_pub.ego_ent_tbl,
                                 x_return_status OUT NOCOPY VARCHAR2, x_return_msg OUT NOCOPY VARCHAR2)
  IS
  	lv_proc VARCHAR2(30) := 'value_to_id_pg_entries_tbl';
  	lv_flag VARCHAR2(1);
  BEGIN
    write_debug('ego_pages_bulkload_pvt.'||lv_proc||' - '||'Entering value_to_id_pg_entries_tbl');

    x_return_status := G_RET_STS_SUCCESS;

    FOR i IN p_ent_tbl.FIRST.. p_ent_tbl.LAST LOOP
    	IF (p_ent_tbl(i).process_status = G_PROCESS_RECORD) THEN
    		/*Get the ICC ID from the Concatenated ICC Name*/
    		IF (p_ent_tbl(i).classification_name  IS NOT NULL AND p_ent_tbl(i).classification_code IS NULL) THEN
    			p_ent_tbl(i).classification_code := EGO_ICC_BULKLOAD_PVT.Get_Catalog_Group_Id(p_ent_tbl(i).classification_name,'FIND_COMBINATION');
    		END IF;

    		/*Get the page ID*/
    		IF (p_ent_tbl(i).page_id IS NULL AND p_ent_tbl(i).internal_name  IS NOT NULL AND p_ent_tbl(i).classification_code  IS NOT NULL) THEN
    			BEGIN
    				SELECT page_id INTO p_ent_tbl(i).page_id
                    FROM   ego_pages_b
                    WHERE  object_id = G_OBJECT_ID
                    AND internal_name = p_ent_tbl(i).internal_name
                    AND classification_code = p_ent_tbl(i).classification_code;
    			EXCEPTION
    				WHEN NO_DATA_FOUND THEN
    					x_return_status := G_RET_STS_ERROR;

						write_debug('ego_pages_bulkload_pvt.'||lv_proc||' - '||'Page is not defined in the system');

						error_handler.Add_error_message(p_message_name => 'EGO_PG_NOT_EXIST',p_application_id => G_EGO_APPLICATION_ID,
	                                                  p_token_tbl => G_TOKEN_TABLE,p_message_type => G_RET_STS_ERROR,
	                                                  p_row_identifier => p_ent_tbl(i).transaction_id,
	                                                  p_entity_code => G_ENTITY_ENT,p_table_name => G_ENTITY_ENT_TAB);
    				WHEN OTHERS THEN
    					x_return_status := G_RET_STS_UNEXP_ERROR;

						write_debug('ego_pages_bulkload_pvt.'||lv_proc||' - '||'value_to_id_pg_entries_tbl exception when others smt 1');

						error_handler.Add_error_message(p_message_text => SQLERRM,p_application_id => G_EGO_APPLICATION_ID,
                                                  p_token_tbl => G_TOKEN_TABLE,p_message_type => G_RET_STS_UNEXP_ERROR,
                                                  p_row_identifier => p_ent_tbl(i).transaction_id,
                                                  p_entity_code => G_ENTITY_ENT,p_table_name => G_ENTITY_ENT_TAB);

                        x_return_msg := 'ego_pages_bulkload_pvt.value_to_id_pg_entries_tbl smt 1 - '||SQLERRM;

       					RETURN;
    			END;
    		END IF;

    		/*Sets the old_attr_group_id*/
    		IF (p_ent_tbl(i).old_attr_group_id IS NULL AND p_ent_tbl(i).old_attr_group_name  IS NOT NULL) THEN
    			BEGIN
    				SELECT attr_group_id INTO p_ent_tbl(i).old_attr_group_id
                    FROM   ego_fnd_dsc_flx_ctx_ext
                    WHERE  application_id = (SELECT application_id
                                             FROM   fnd_application
                                             WHERE  application_short_name = 'EGO')
                    AND descriptive_flexfield_name = 'EGO_ITEMMGMT_GROUP'
                    AND descriptive_flex_context_code = p_ent_tbl(i).old_attr_group_name;
    			EXCEPTION
    				WHEN NO_DATA_FOUND THEN
    					x_return_status := G_RET_STS_ERROR;

						write_debug('ego_pages_bulkload_pvt.'||lv_proc||' - '||'Association does not exist');

						error_handler.Add_error_message(p_message_name => 'EGO_PG_ASSOC_NOT_EXIST',p_application_id => G_EGO_APPLICATION_ID,
	                                                  p_token_tbl => G_TOKEN_TABLE,p_message_type => G_RET_STS_ERROR,
	                                                  p_row_identifier => p_ent_tbl(i).transaction_id,
	                                                  p_entity_code => G_ENTITY_ENT,p_table_name => G_ENTITY_ENT_TAB);
    				WHEN OTHERS THEN
    					x_return_status := G_RET_STS_UNEXP_ERROR;

						write_debug('ego_pages_bulkload_pvt.'||lv_proc||' - '||'value_to_id_pg_entries_tbl exception when others smt 2');

						error_handler.Add_error_message(p_message_text => SQLERRM,p_application_id => G_EGO_APPLICATION_ID,
                                                  p_token_tbl => G_TOKEN_TABLE,p_message_type => G_RET_STS_UNEXP_ERROR,
                                                  p_row_identifier => p_ent_tbl(i).transaction_id,
                                                  p_entity_code => G_ENTITY_ENT,p_table_name => G_ENTITY_ENT_TAB);

                        x_return_msg := 'ego_pages_bulkload_pvt.value_to_id_pg_entries_tbl smt 2 - '||SQLERRM;

       					RETURN;

    			END;
    		END IF;

    		/*Sets the new_attr_group_id*/
    		IF (p_ent_tbl(i).new_attr_group_id IS NULL AND p_ent_tbl(i).new_attr_group_name  IS NOT NULL) THEN
    			BEGIN
    				SELECT attr_group_id INTO p_ent_tbl(i).new_attr_group_id
                    FROM   ego_fnd_dsc_flx_ctx_ext
                    WHERE  application_id = (SELECT application_id
                                             FROM   fnd_application
                                             WHERE  application_short_name = 'EGO')
                    AND descriptive_flexfield_name = 'EGO_ITEMMGMT_GROUP'
                    AND descriptive_flex_context_code = p_ent_tbl(i).new_attr_group_name;
    			EXCEPTION
    				WHEN NO_DATA_FOUND THEN
    					x_return_status := G_RET_STS_ERROR;

						write_debug('ego_pages_bulkload_pvt.'||lv_proc||' - '||'Association does not exist');

						error_handler.Add_error_message(p_message_name => 'EGO_PG_ASSOC_NOT_EXIST',p_application_id => G_EGO_APPLICATION_ID,
	                                                  p_token_tbl => G_TOKEN_TABLE,p_message_type => G_RET_STS_ERROR,
	                                                  p_row_identifier => p_ent_tbl(i).transaction_id,
	                                                  p_entity_code => G_ENTITY_ENT,p_table_name => G_ENTITY_ENT_TAB);
    				WHEN OTHERS THEN
    					x_return_status := G_RET_STS_UNEXP_ERROR;

						write_debug('ego_pages_bulkload_pvt.'||lv_proc||' - '||'value_to_id_pg_entries_tbl exception when others smt 3');

						error_handler.Add_error_message(p_message_text => SQLERRM,p_application_id => G_EGO_APPLICATION_ID,
                                                  p_token_tbl => G_TOKEN_TABLE,p_message_type => G_RET_STS_UNEXP_ERROR,
                                                  p_row_identifier => p_ent_tbl(i).transaction_id,
                                                  p_entity_code => G_ENTITY_ENT,p_table_name => G_ENTITY_ENT_TAB);

                        x_return_msg := 'ego_pages_bulkload_pvt.value_to_id_pg_entries_tbl smt 3 - '||SQLERRM;

       					RETURN;

    			END;
    		END IF;

    		/*Sets the old_attr_group_id*/
    		IF (p_ent_tbl(i).old_attr_group_id  IS NOT NULL AND p_ent_tbl(i).classification_code  IS NOT NULL) THEN
    			BEGIN
    				SELECT association_id INTO p_ent_tbl(i).old_association_id
					FROM EGO_OBJ_AG_ASSOCS_B
					WHERE classification_code = p_ent_tbl(i).classification_code
					AND attr_group_id = p_ent_tbl(i).old_attr_group_id;
    			EXCEPTION
    				WHEN NO_DATA_FOUND THEN
    					x_return_status := G_RET_STS_ERROR;

						write_debug('ego_pages_bulkload_pvt.'||lv_proc||' - '||'Association does not exist');

						error_handler.Add_error_message(p_message_name => 'EGO_PG_ASSOC_NOT_EXIST',p_application_id => G_EGO_APPLICATION_ID,
	                                                  p_token_tbl => G_TOKEN_TABLE,p_message_type => G_RET_STS_ERROR,
	                                                  p_row_identifier => p_ent_tbl(i).transaction_id,
	                                                  p_entity_code => G_ENTITY_ENT,p_table_name => G_ENTITY_ENT_TAB);
    				WHEN OTHERS THEN
    					x_return_status := G_RET_STS_UNEXP_ERROR;

						write_debug('ego_pages_bulkload_pvt.'||lv_proc||' - '||'value_to_id_pg_entries_tbl exception when others smt 4');

						error_handler.Add_error_message(p_message_text => SQLERRM,p_application_id => G_EGO_APPLICATION_ID,
                                                  p_token_tbl => G_TOKEN_TABLE,p_message_type => G_RET_STS_UNEXP_ERROR,
                                                  p_row_identifier => p_ent_tbl(i).transaction_id,
                                                  p_entity_code => G_ENTITY_ENT,p_table_name => G_ENTITY_ENT_TAB);

                        x_return_msg := 'ego_pages_bulkload_pvt.value_to_id_pg_entries_tbl smt 4 - '||SQLERRM;

       					RETURN;

    			END;
    		END IF;

    		/*Sets the new_attr_group_id*/
    		IF (p_ent_tbl(i).new_attr_group_id  IS NOT NULL AND p_ent_tbl(i).classification_code  IS NOT NULL) THEN
    			BEGIN
    				SELECT association_id INTO p_ent_tbl(i).new_association_id
					FROM EGO_OBJ_AG_ASSOCS_B
					WHERE classification_code = p_ent_tbl(i).classification_code
					AND attr_group_id = p_ent_tbl(i).new_attr_group_id;
    			EXCEPTION
    				WHEN NO_DATA_FOUND THEN
    					x_return_status := G_RET_STS_ERROR;

						write_debug('ego_pages_bulkload_pvt.'||lv_proc||' - '||'Association does not exist');

						error_handler.Add_error_message(p_message_name => 'EGO_PG_ASSOC_NOT_EXIST',p_application_id => G_EGO_APPLICATION_ID,
	                                                  p_token_tbl => G_TOKEN_TABLE,p_message_type => G_RET_STS_ERROR,
	                                                  p_row_identifier => p_ent_tbl(i).transaction_id,
	                                                  p_entity_code => G_ENTITY_ENT,p_table_name => G_ENTITY_ENT_TAB);
    				WHEN OTHERS THEN
    					x_return_status := G_RET_STS_UNEXP_ERROR;

						write_debug('ego_pages_bulkload_pvt.'||lv_proc||' - '||'value_to_id_pg_entries_tbl exception when others smt 5');

						error_handler.Add_error_message(p_message_text => SQLERRM,p_application_id => G_EGO_APPLICATION_ID,
                                                  p_token_tbl => G_TOKEN_TABLE,p_message_type => G_RET_STS_UNEXP_ERROR,
                                                  p_row_identifier => p_ent_tbl(i).transaction_id,
                                                  p_entity_code => G_ENTITY_ENT,p_table_name => G_ENTITY_ENT_TAB);

                        x_return_msg := 'ego_pages_bulkload_pvt.value_to_id_pg_entries_tbl smt 5 - '||SQLERRM;

       					RETURN;

    			END;
    		END IF;

    		/*Sets the SYNC to CREATE or UPDATE*/
    		IF (p_ent_tbl(i).transaction_type = G_OPR_SYNC) THEN
    			BEGIN
    			   SELECT 'Y' INTO lv_flag
                   FROM   ego_page_entries_b
                   WHERE  page_id = p_ent_tbl(i).page_id
                   AND association_id = p_ent_tbl(i).old_association_id;

                   p_ent_tbl(i).transaction_type := G_OPR_UPDATE;
    			EXCEPTION
    				WHEN NO_DATA_FOUND THEN
    					p_ent_tbl(i).transaction_type := G_OPR_DELETE;
    				WHEN OTHERS THEN
    			  		x_return_status := G_RET_STS_UNEXP_ERROR;

						write_debug('ego_pages_bulkload_pvt.'||lv_proc||' - '||'value_to_id_pg_entries_tbl exception when others smt 6');

						error_handler.Add_error_message(p_message_text => SQLERRM,p_application_id => G_EGO_APPLICATION_ID,
                                                  p_token_tbl => G_TOKEN_TABLE,p_message_type => G_RET_STS_UNEXP_ERROR,
                                                  p_row_identifier => p_ent_tbl(i).transaction_id,
                                                  p_entity_code => G_ENTITY_ENT,p_table_name => G_ENTITY_ENT_TAB);

                        x_return_msg := 'ego_pages_bulkload_pvt.value_to_id_pg_entries_tbl smt 6 - '||SQLERRM;

       					RETURN;
    			END;
    		END IF;
    	END IF;
    END LOOP;

    write_debug('ego_pages_bulkload_pvt.'||lv_proc||' - '||'Exit value_to_id_pg_entries_tbl');
  EXCEPTION
    WHEN OTHERS THEN
        write_debug('ego_pages_bulkload_pvt.'||lv_proc||' - '||'value_to_id_pg_entries_tbl Exception when others'||SQLERRM);

        x_return_status := G_RET_STS_UNEXP_ERROR;

        x_return_msg := 'ego_pages_bulkload_pvt.value_to_id_pg_entries_tbl - '||SQLERRM;

      	RETURN;
  END value_to_id_pg_entries_tbl;

  /*This procedure is used for bulk validation of the pages.
  	Used in the interface flow.
  	x_return_status OUT NOCOPY parameter that returns the status*/
  PROCEDURE Bulk_validate_pages (x_return_status OUT NOCOPY VARCHAR2, x_return_msg OUT NOCOPY VARCHAR2)
  IS
    lv_smt NUMBER; --Statement counter
    lv_proc VARCHAR2(30) := 'Bulk_validate_pages';
  BEGIN
    write_debug('ego_pages_bulkload_pvt.'||lv_proc||' - '||'Entered Bulk_validate_pages');

    x_return_status := G_RET_STS_SUCCESS;

    Value_to_id_pages(x_return_status, x_return_msg => x_return_msg); IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN RETURN; END IF;

    Construct_pages(x_return_status, x_return_msg => x_return_msg); IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN RETURN; END IF;

    lv_smt := 1;

    write_debug('ego_pages_bulkload_pvt.'||lv_proc||' - '||'Statement 1.1');

    /* Update the interface records with process_status 3 and insert into
    MTL_INTERFACE_ERRORS if the ICC name passed is invalid*/
    G_MESSAGE_NAME := 'EGO_ICC_ID_INVALID';

    fnd_message.Set_name(G_EGO_APPLICATION_ID, 'EGO_ICC_ID_INVALID');

    G_MESSAGE_TEXT := fnd_message.get;

    INSERT INTO mtl_interface_errors
                (transaction_id,
                 unique_id,
                 organization_id,
                 column_name,
                 table_name,
                 bo_identifier,
                 entity_identifier,
                 message_name,
                 error_message,
                 last_update_date,
                 last_updated_by,
                 creation_date,
                 created_by,
                 last_update_login,
                 request_id,
                 program_application_id,
                 program_id,
                 program_update_date)
    SELECT transaction_id,
           mtl_system_items_interface_s.nextval,
           NULL,
           NULL,
           G_ENTITY_PG_TAB,
           G_BO_IDENTIFIER_PG,
           G_ENTITY_PG,
           G_MESSAGE_NAME,
           G_MESSAGE_TEXT,
           Nvl(last_update_date, SYSDATE),
           Nvl(last_updated_by, G_USER_ID),
           Nvl(creation_date, SYSDATE),
           Nvl(created_by, G_USER_ID),
           Nvl(last_update_login, G_USER_ID),
           G_REQUEST_ID,
           Nvl(program_application_id, G_PROG_APPL_ID),
           Nvl(program_id, G_PROGRAM_ID),
           Nvl(program_update_date, SYSDATE)
    FROM   ego_pages_interface epi
    WHERE  (classification_code IS NULL OR classification_name IS NULL)
           AND transaction_id IS NOT NULL
           AND process_status = G_PROCESS_RECORD
           AND ( ( G_SET_PROCESS_ID IS NULL )
                  OR ( set_process_id = G_SET_PROCESS_ID ) );

    UPDATE ego_pages_interface
    SET    process_status = G_ERROR_RECORD,
           last_updated_by = G_USER_ID,
           last_update_date = SYSDATE,
           last_update_login = G_LOGIN_ID
    WHERE  (classification_code IS NULL OR classification_name IS NULL)
           AND transaction_id IS NOT NULL
           AND process_status = G_PROCESS_RECORD
           AND ( ( G_SET_PROCESS_ID IS NULL )
                  OR ( set_process_id = G_SET_PROCESS_ID ) );

    lv_smt := 1.1;

    write_debug('ego_pages_bulkload_pvt.'||lv_proc||' - '||'Statement 1.1');

    /* Update the interface records with process_status 3 and insert into
    MTL_INTERFACE_ERRORS if the page does not exist for update and delete flow*/
    G_MESSAGE_NAME := 'EGO_EF_ATTR_PAGE_NOT_FOUND';

    fnd_message.Set_name(G_EGO_APPLICATION_ID, 'EGO_EF_ATTR_PAGE_NOT_FOUND');

    G_MESSAGE_TEXT := fnd_message.get;

    INSERT INTO mtl_interface_errors
                (transaction_id,
                 unique_id,
                 organization_id,
                 column_name,
                 table_name,
                 bo_identifier,
                 entity_identifier,
                 message_name,
                 error_message,
                 last_update_date,
                 last_updated_by,
                 creation_date,
                 created_by,
                 last_update_login,
                 request_id,
                 program_application_id,
                 program_id,
                 program_update_date)
    SELECT transaction_id,
           mtl_system_items_interface_s.nextval,
           NULL,
           NULL,
           G_ENTITY_PG_TAB,
           G_BO_IDENTIFIER_PG,
           G_ENTITY_PG,
           G_MESSAGE_NAME,
           G_MESSAGE_TEXT,
           Nvl(last_update_date, SYSDATE),
           Nvl(last_updated_by, G_USER_ID),
           Nvl(creation_date, SYSDATE),
           Nvl(created_by, G_USER_ID),
           Nvl(last_update_login, G_USER_ID),
           G_REQUEST_ID,
           Nvl(program_application_id, G_PROG_APPL_ID),
           Nvl(program_id, G_PROGRAM_ID),
           Nvl(program_update_date, SYSDATE)
    FROM   ego_pages_interface epi
    WHERE  (page_id IS NULL OR internal_name IS NULL)
           AND transaction_type <> G_OPR_CREATE
           AND transaction_id IS NOT NULL
           AND process_status = G_PROCESS_RECORD
           AND ( ( G_SET_PROCESS_ID IS NULL )
                  OR ( set_process_id = G_SET_PROCESS_ID ) );

    UPDATE ego_pages_interface
    SET    process_status = G_ERROR_RECORD,
           last_updated_by = G_USER_ID,
           last_update_date = SYSDATE,
           last_update_login = G_LOGIN_ID
    WHERE  (page_id IS NULL OR internal_name IS NULL)
           AND transaction_type <> G_OPR_CREATE
           AND transaction_id IS NOT NULL
           AND process_status = G_PROCESS_RECORD
           AND ( ( G_SET_PROCESS_ID IS NULL )
                  OR ( set_process_id = G_SET_PROCESS_ID ) );

    lv_smt := 1.1;

    write_debug('ego_pages_bulkload_pvt.'||lv_proc||' - '||'Statement 1.1');

    /* Update the interface records with process_status 3 and insert into
    MTL_INTERFACE_ERRORS if the page with the internal name already exists in the system*/
    G_MESSAGE_NAME := 'EGO_INTERNAL_NAME_EXISTS';

    fnd_message.Set_name(G_EGO_APPLICATION_ID, 'EGO_INTERNAL_NAME_EXISTS');

    G_MESSAGE_TEXT := fnd_message.get;

    INSERT INTO mtl_interface_errors
                (transaction_id,
                 unique_id,
                 organization_id,
                 column_name,
                 table_name,
                 bo_identifier,
                 entity_identifier,
                 message_name,
                 error_message,
                 last_update_date,
                 last_updated_by,
                 creation_date,
                 created_by,
                 last_update_login,
                 request_id,
                 program_application_id,
                 program_id,
                 program_update_date)
    SELECT transaction_id,
           mtl_system_items_interface_s.nextval,
           NULL,
           NULL,
           G_ENTITY_PG_TAB,
           G_BO_IDENTIFIER_PG,
           G_ENTITY_PG,
           G_MESSAGE_NAME,
           G_MESSAGE_TEXT,
           Nvl(last_update_date, SYSDATE),
           Nvl(last_updated_by, G_USER_ID),
           Nvl(creation_date, SYSDATE),
           Nvl(created_by, G_USER_ID),
           Nvl(last_update_login, G_USER_ID),
           G_REQUEST_ID,
           Nvl(program_application_id, G_PROG_APPL_ID),
           Nvl(program_id, G_PROGRAM_ID),
           Nvl(program_update_date, SYSDATE)
    FROM   ego_pages_interface epi
    WHERE  EXISTS (SELECT 1
    			   FROM EGO_PAGES_B
    			   WHERE internal_name = epi.internal_name
    			   AND classification_code = epi.classification_code)
           AND transaction_type = G_OPR_CREATE
           AND transaction_id IS NOT NULL
           AND process_status = G_PROCESS_RECORD
           AND ( ( G_SET_PROCESS_ID IS NULL )
                  OR ( set_process_id = G_SET_PROCESS_ID ) );

    UPDATE ego_pages_interface epi
    SET    process_status = G_ERROR_RECORD,
           last_updated_by = G_USER_ID,
           last_update_date = SYSDATE,
           last_update_login = G_LOGIN_ID
    WHERE EXISTS (SELECT 1
    			   FROM EGO_PAGES_B
    			   WHERE internal_name = epi.internal_name
    			   AND classification_code = epi.classification_code)
           AND transaction_type = G_OPR_CREATE
           AND transaction_id IS NOT NULL
           AND process_status = G_PROCESS_RECORD
           AND ( ( G_SET_PROCESS_ID IS NULL )
                  OR ( set_process_id = G_SET_PROCESS_ID ) );

    lv_smt := 2;

    write_debug('ego_pages_bulkload_pvt.'||lv_proc||' - '||'Statement 2');

    /* Update the interface records with process_status 3 and insert into
    MTL_INTERFACE_ERRORS if SEQUENCE IS already existing for the ICC*/
    G_MESSAGE_NAME := 'EGO_PG_SEQ_DUP';

    fnd_message.Set_name(G_EGO_APPLICATION_ID, 'EGO_PG_SEQ_DUP');

    G_MESSAGE_TEXT := fnd_message.get;

    INSERT INTO mtl_interface_errors
                (transaction_id,
                 unique_id,
                 organization_id,
                 column_name,
                 table_name,
                 bo_identifier,
                 entity_identifier,
                 message_name,
                 error_message,
                 last_update_date,
                 last_updated_by,
                 creation_date,
                 created_by,
                 last_update_login,
                 request_id,
                 program_application_id,
                 program_id,
                 program_update_date)
    SELECT transaction_id,
           mtl_system_items_interface_s.nextval,
           NULL,
           NULL,
           G_ENTITY_PG_TAB,
           G_BO_IDENTIFIER_PG,
           G_ENTITY_PG,
           G_MESSAGE_NAME,
           G_MESSAGE_TEXT,
           Nvl(last_update_date, SYSDATE),
           Nvl(last_updated_by, G_USER_ID),
           Nvl(creation_date, SYSDATE),
           Nvl(created_by, G_USER_ID),
           Nvl(last_update_login, G_USER_ID),
           G_REQUEST_ID,
           Nvl(program_application_id, G_PROG_APPL_ID),
           Nvl(program_id, G_PROGRAM_ID),
           Nvl(program_update_date, SYSDATE)
    FROM   ego_pages_interface epi
    WHERE  EXISTS (SELECT 1
                   FROM   ego_pages_b
                   WHERE  classification_code = epi.classification_code
                   AND SEQUENCE = epi.SEQUENCE
                   AND page_id <> nvl(epi.page_id,-1))
           AND transaction_id IS NOT NULL
           AND process_status = G_PROCESS_RECORD
           AND ( ( G_SET_PROCESS_ID IS NULL )
                  OR ( set_process_id = G_SET_PROCESS_ID ) );

    UPDATE ego_pages_interface epi
    SET    process_status = G_ERROR_RECORD,
           last_updated_by = G_USER_ID,
           last_update_date = SYSDATE,
           last_update_login = G_LOGIN_ID
    WHERE  EXISTS (SELECT 1
                   FROM   ego_pages_b
                   WHERE  classification_code = epi.classification_code
                   AND SEQUENCE = epi.SEQUENCE
                   AND page_id <> nvl(epi.page_id,-1))
           AND transaction_id IS NOT NULL
           AND process_status = G_PROCESS_RECORD
           AND ( ( G_SET_PROCESS_ID IS NULL )
                  OR ( set_process_id = G_SET_PROCESS_ID ) );

  write_debug('ego_pages_bulkload_pvt.'||lv_proc||' - '||'Exit Bulk_validate_pages');
  EXCEPTION
    WHEN OTHERS THEN
        write_debug('ego_pages_bulkload_pvt.'||lv_proc||' - '||'Bulk_validate_pages Exception when others'||SQLERRM);

        x_return_status := G_RET_STS_UNEXP_ERROR;

        x_return_msg := 'ego_pages_bulkload_pvt.Bulk_validate_pages - '||SQLERRM;

      	RETURN;
  END Bulk_validate_pages;

  /*This procedure is used for the bulk validation for the page entries.
    Used in the interface flow.
    x_return_status OUT NOCOPY parameter that returns the status*/
  PROCEDURE bulk_validate_pg_entries (x_return_status OUT NOCOPY VARCHAR2, x_return_msg OUT NOCOPY VARCHAR2)
  IS
  lv_smt NUMBER; --Statement counter
  lv_proc VARCHAR2(30) := 'bulk_validate_pg_entries';
  BEGIN
    write_debug('ego_pages_bulkload_pvt.'||lv_proc||' - '||'Entered bulk_validate_pg_entries');

    x_return_status := G_RET_STS_SUCCESS;

    Value_to_id_pg_entries(x_return_status, x_return_msg => x_return_msg); IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN RETURN; END IF;

    Construct_pg_entries(x_return_status, x_return_msg => x_return_msg); IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN RETURN; END IF;

    lv_smt := 1;

    write_debug('ego_pages_bulkload_pvt.'||lv_proc||' - '||'Statement 1');

    /* Update the interface records with process_status 3 and insert into
    MTL_INTERFACE_ERRORS if flow is UPDATE or DELETE and the page entry does not exist*/
    G_MESSAGE_NAME := 'EGO_PG_ENT_NOT_EXIST';

    fnd_message.Set_name(G_EGO_APPLICATION_ID, 'EGO_PG_ENT_NOT_EXIST');

    G_MESSAGE_TEXT := fnd_message.get;

    INSERT INTO mtl_interface_errors
                (transaction_id,
                 unique_id,
                 organization_id,
                 column_name,
                 table_name,
                 bo_identifier,
                 entity_identifier,
                 message_name,
                 error_message,
                 last_update_date,
                 last_updated_by,
                 creation_date,
                 created_by,
                 last_update_login,
                 request_id,
                 program_application_id,
                 program_id,
                 program_update_date)
    SELECT transaction_id,
           mtl_system_items_interface_s.nextval,
           NULL,
           NULL,
           G_ENTITY_ENT_TAB,
           G_BO_IDENTIFIER_PG,
           G_ENTITY_ENT,
           G_MESSAGE_NAME,
           G_MESSAGE_TEXT,
           Nvl(last_update_date, SYSDATE),
           Nvl(last_updated_by, G_USER_ID),
           Nvl(creation_date, SYSDATE),
           Nvl(created_by, G_USER_ID),
           Nvl(last_update_login, G_USER_ID),
           G_REQUEST_ID,
           Nvl(program_application_id, G_PROG_APPL_ID),
           Nvl(program_id, G_PROGRAM_ID),
           Nvl(program_update_date, SYSDATE)
    FROM   ego_page_entries_interface epei
    WHERE  NOT EXISTS (SELECT 1
	                   FROM   ego_page_entries_b
	                   WHERE  page_id = epei.page_id
                   	   AND association_id = epei.old_association_id
                   	   AND classification_code = epei.classification_code)
           AND transaction_type <> G_OPR_CREATE
           AND transaction_id IS NOT NULL
           AND process_status = G_PROCESS_RECORD
           AND ( ( G_SET_PROCESS_ID IS NULL )
                  OR ( set_process_id = G_SET_PROCESS_ID ) );

    UPDATE ego_page_entries_interface epi
    SET    process_status = G_ERROR_RECORD,
           last_updated_by = G_USER_ID,
           last_update_date = SYSDATE,
           last_update_login = G_LOGIN_ID
    WHERE  NOT EXISTS (SELECT 1
	                   FROM   ego_page_entries_b
	                   WHERE  page_id = epi.page_id
                   	   AND association_id = epi.old_association_id
                   	   AND classification_code = epi.classification_code)
           AND transaction_type <> G_OPR_CREATE
           AND transaction_id IS NOT NULL
           AND process_status = G_PROCESS_RECORD
           AND ( ( G_SET_PROCESS_ID IS NULL )
                  OR ( set_process_id = G_SET_PROCESS_ID ) );

    lv_smt := 2;

    write_debug('ego_pages_bulkload_pvt.'||lv_proc||' - '||'Statement 2');

    /* Update the interface records with process_status 3 and insert into
    MTL_INTERFACE_ERRORS if SEQ already exists in the page*/
    G_MESSAGE_NAME := 'EGO_PAGE_ENTRY_SAME_SEQ';

    fnd_message.Set_name(G_EGO_APPLICATION_ID, 'EGO_PAGE_ENTRY_SAME_SEQ');

    G_MESSAGE_TEXT := fnd_message.get;

    INSERT INTO mtl_interface_errors
                (transaction_id,
                 unique_id,
                 organization_id,
                 column_name,
                 table_name,
                 bo_identifier,
                 entity_identifier,
                 message_name,
                 error_message,
                 last_update_date,
                 last_updated_by,
                 creation_date,
                 created_by,
                 last_update_login,
                 request_id,
                 program_application_id,
                 program_id,
                 program_update_date)
    SELECT transaction_id,
           mtl_system_items_interface_s.nextval,
           NULL,
           NULL,
           G_ENTITY_ENT_TAB,
           G_BO_IDENTIFIER_PG,
           G_ENTITY_ENT,
           G_MESSAGE_NAME,
           G_MESSAGE_TEXT,
           Nvl(last_update_date, SYSDATE),
           Nvl(last_updated_by, G_USER_ID),
           Nvl(creation_date, SYSDATE),
           Nvl(created_by, G_USER_ID),
           Nvl(last_update_login, G_USER_ID),
           G_REQUEST_ID,
           Nvl(program_application_id, G_PROG_APPL_ID),
           Nvl(program_id, G_PROGRAM_ID),
           Nvl(program_update_date, SYSDATE)
    FROM   ego_page_entries_interface epi
    WHERE  EXISTS (SELECT 1
	                   FROM   ego_page_entries_b
	                   WHERE  page_id = epi.page_id
                   	   AND sequence = epi.sequence)
           AND transaction_id IS NOT NULL
           AND transaction_type = G_OPR_CREATE   				/*Added this for bug 9733398*/
           AND process_status = G_PROCESS_RECORD
           AND ( ( G_SET_PROCESS_ID IS NULL )
                  OR ( set_process_id = G_SET_PROCESS_ID ) );

    UPDATE ego_page_entries_interface epi
    SET    process_status = G_ERROR_RECORD,
           last_updated_by = G_USER_ID,
           last_update_date = SYSDATE,
           last_update_login = G_LOGIN_ID
    WHERE  EXISTS (SELECT 1
	                   FROM   ego_page_entries_b
	                   WHERE  page_id = epi.page_id
                   	   AND sequence = epi.sequence)
           AND transaction_id IS NOT NULL
           AND transaction_type = G_OPR_CREATE					/*Added this for bug 9733398*/
           AND process_status = G_PROCESS_RECORD
           AND ( ( G_SET_PROCESS_ID IS NULL )
                  OR ( set_process_id = G_SET_PROCESS_ID ) );

      write_debug('ego_pages_bulkload_pvt.'||lv_proc||' - '||'Exit bulk_validate_pg_entries');
  EXCEPTION
    WHEN OTHERS THEN
        write_debug('ego_pages_bulkload_pvt.'||lv_proc||' - '||'bulk_validate_pg_entries Exception when others'||SQLERRM);

        x_return_status := G_RET_STS_UNEXP_ERROR;

        x_return_status := G_RET_STS_UNEXP_ERROR;

        x_return_msg := 'ego_pages_bulkload_pvt.bulk_validate_pg_entries - '||SQLERRM;

      	RETURN;
  END bulk_validate_pg_entries;


  /*This procedure is used to handle the additional validations for Pages.
  	Used in the API flow.
  	p_pg_tbl        IN OUT NOCOPY Pages table
  	x_return_status OUT NOCOPY parameter that returns the status*/
  PROCEDURE Additional_pg_validations (p_pg_tbl        IN OUT NOCOPY ego_metadata_pub.ego_pg_tbl,
                                       x_return_status OUT NOCOPY VARCHAR2, x_return_msg OUT NOCOPY VARCHAR2)
  IS
  lv_smt NUMBER; --Statement counter
  lv_flag VARCHAR2(1);
  lv_proc VARCHAR2(30) := 'Additional_pg_validations';
  BEGIN
    write_debug('ego_pages_bulkload_pvt.'||lv_proc||' - '||'Entering Additional_pg_validations');

    x_return_status := G_RET_STS_SUCCESS;

	FOR i IN p_pg_tbl.FIRST.. p_pg_tbl.LAST LOOP
		IF (p_pg_tbl(i).process_status = G_PROCESS_RECORD) THEN

		    lv_smt := 1;
			/*For the update or delete flow if the page is not existing in the system then Error out*/
			IF(p_pg_tbl(i).transaction_type <> G_OPR_CREATE AND p_pg_tbl(i).page_id IS NULL) THEN
				x_return_status := G_RET_STS_ERROR;

				write_debug('ego_pages_bulkload_pvt.'||lv_proc||' - '||'Page is not defined in the system');

				error_handler.Add_error_message(p_message_name => 'EGO_PG_NOT_EXIST',p_application_id => G_EGO_APPLICATION_ID,
                                                  p_token_tbl => G_TOKEN_TABLE,p_message_type => G_RET_STS_ERROR,
                                                  p_row_identifier => p_pg_tbl(i).transaction_id,
                                                  p_entity_code => G_ENTITY_PG,p_table_name => G_ENTITY_PG_TAB);
			END IF;

			lv_smt := 2;
			/*Error OUT if the same sequence exists in the system for the ICC*/
			BEGIN
				SELECT 'Y' INTO lv_flag
                FROM   ego_pages_b
                WHERE  classification_code = p_pg_tbl(i).classification_code
                AND SEQUENCE = p_pg_tbl(i).SEQUENCE
                AND page_id <> NVL(p_pg_tbl(i).page_id,-1);

                x_return_status := G_RET_STS_ERROR;

				write_debug('ego_pages_bulkload_pvt.'||lv_proc||' - '||'Sequence exists in the system');

				error_handler.Add_error_message(p_message_name => 'EGO_PG_SEQ_DUP',p_application_id => G_EGO_APPLICATION_ID,
                                                  p_token_tbl => G_TOKEN_TABLE,p_message_type => G_RET_STS_ERROR,
                                                  p_row_identifier => p_pg_tbl(i).transaction_id,
                                                  p_entity_code => G_ENTITY_PG,p_table_name => G_ENTITY_PG_TAB);
			EXCEPTION
				WHEN NO_DATA_FOUND THEN
					NULL;
				WHEN OTHERS THEN
					x_return_status := G_RET_STS_UNEXP_ERROR;

					write_debug('ego_pages_bulkload_pvt.'||lv_proc||' - '||'Additional_pg_validations exception when others smt 2');

					error_handler.Add_error_message(p_message_text => SQLERRM,p_application_id => G_EGO_APPLICATION_ID,
                                                  p_token_tbl => G_TOKEN_TABLE,p_message_type => G_RET_STS_ERROR,
                                                  p_row_identifier => p_pg_tbl(i).transaction_id,
                                                  p_entity_code => G_ENTITY_PG,p_table_name => G_ENTITY_PG_TAB);

                    x_return_msg := 'ego_pages_bulkload_pvt.Additional_pg_validations smt 2 - '||SQLERRM;

      				RETURN;
			END;

			lv_smt := 3;
			/*Convert transaction type to upper case*/
		      SELECT Upper(p_pg_tbl(i).transaction_type)
		      INTO   p_pg_tbl(i).transaction_type
		      FROM   dual;
		    /*check for invalid transaction type for PG*/
			IF (p_pg_tbl(i).transaction_type = 	G_OPR_CREATE
				OR p_pg_tbl(i).transaction_type = 	G_OPR_UPDATE
				OR p_pg_tbl(i).transaction_type = 	G_OPR_DELETE
				OR p_pg_tbl(i).transaction_type = 	G_OPR_SYNC) THEN
				NULL;
			ELSE
				write_debug('ego_pages_bulkload_pvt.'||lv_proc||' - '||'Transaction type is invalid for PG');

		        p_pg_tbl(i).process_status := G_ERROR_RECORD;

		        x_return_status := G_RET_STS_ERROR;

		        write_debug('ego_pages_bulkload_pvt.'||lv_proc||' - '||'Invalid transaction type for PG');

		      	error_handler.Add_error_message(p_message_name => 'EGO_TRANS_TYPE_INVALID',p_application_id => 'EGO',
		                                      	p_token_tbl => g_token_table,p_message_type => G_RET_STS_ERROR,
		                                      	p_row_identifier => p_pg_tbl(i).transaction_id,
		                                      	p_entity_code => G_ENTITY_PG,p_table_name => G_ENTITY_PG_TAB);
			END IF;
		END IF;
	END LOOP;

  	write_debug('ego_pages_bulkload_pvt.'||lv_proc||' - '||'Exit Additional_pg_validations');
  EXCEPTION
    WHEN OTHERS THEN
        write_debug('ego_pages_bulkload_pvt.'||lv_proc||' - '||'Additional_pg_validations Exception when others'||SQLERRM);

        x_return_status := G_RET_STS_UNEXP_ERROR;

        x_return_msg := 'ego_pages_bulkload_pvt.Additional_pg_validations - '||SQLERRM;

      	RETURN;
  END Additional_pg_validations;

  /*This procedure is used to handle the additional validations for Page Entries
  	Used in the API flow.
  	p_ent_tbl       IN OUT NOCOPY Page Entries table
  	x_return_status OUT NOCOPY parameter that returns the status*/
  PROCEDURE Additional_ent_validations (p_ent_tbl       IN OUT NOCOPY ego_metadata_pub.ego_ent_tbl,
                                        x_return_status OUT NOCOPY VARCHAR2, x_return_msg OUT NOCOPY VARCHAR2)
  IS
  lv_smt NUMBER; --Statement counter
  lv_flag VARCHAR2(1);
  lv_proc VARCHAR2(30) := 'Additional_ent_validations';
  BEGIN
   write_debug('ego_pages_bulkload_pvt.'||lv_proc||' - '||'Entering Additional_ent_validations');

   x_return_status := G_RET_STS_SUCCESS;

   FOR i IN p_ent_tbl.FIRST.. p_ent_tbl.LAST LOOP
   	IF (p_ent_tbl(i).process_status = G_PROCESS_RECORD) THEN
   		/*Error out if flow is UPDATE or DELETE and the page entry does not exist*/
   		IF (p_ent_tbl(i).transaction_type <> G_OPR_CREATE) THEN
   			BEGIN
   				SELECT 'Y' INTO lv_flag
               	FROM   ego_page_entries_b
              	WHERE  page_id = p_ent_tbl(i).page_id
           	   	AND association_id = p_ent_tbl(i).old_association_id
           	   	AND classification_code = p_ent_tbl(i).classification_code;
   			EXCEPTION
   				WHEN NO_DATA_FOUND THEN
   					x_return_status := G_RET_STS_ERROR;

					write_debug('ego_pages_bulkload_pvt.'||lv_proc||' - '||'Sequence exists in the system');

					error_handler.Add_error_message(p_message_name => 'EGO_PG_ENT_NOT_EXIST',p_application_id => G_EGO_APPLICATION_ID,
                                                  p_token_tbl => G_TOKEN_TABLE,p_message_type => G_RET_STS_ERROR,
                                                  p_row_identifier => p_ent_tbl(i).transaction_id,
                                                  p_entity_code => G_ENTITY_ENT,p_table_name => G_ENTITY_ENT_TAB);
   				WHEN OTHERS THEN
   					x_return_status := G_RET_STS_UNEXP_ERROR;

					write_debug('ego_pages_bulkload_pvt.'||lv_proc||' - '||'Additional_ent_validations exception when others smt 1');

					error_handler.Add_error_message(p_message_text => SQLERRM,p_application_id => G_EGO_APPLICATION_ID,
                                                  p_token_tbl => G_TOKEN_TABLE,p_message_type => G_RET_STS_UNEXP_ERROR,
                                                  p_row_identifier => p_ent_tbl(i).transaction_id,
                                                  p_entity_code => G_ENTITY_ENT,p_table_name => G_ENTITY_ENT_TAB);

                    x_return_msg := 'ego_pages_bulkload_pvt.Additional_ent_validations smt 1- '||SQLERRM;

      				RETURN;
   			END;
   		END IF;

   		lv_smt := 2;
   		/*Error if SEQ already exists in the page*/
   		BEGIN
   			SELECT 'Y' INTO lv_flag
            FROM   ego_page_entries_b
            WHERE  page_id = p_ent_tbl(i).page_id
        	AND sequence = p_ent_tbl(i).sequence;

        	IF (lv_flag = 'Y') THEN
        		x_return_status := G_RET_STS_ERROR;

				write_debug('ego_pages_bulkload_pvt.'||lv_proc||' - '||'Sequence exists in the system for the same page');

				error_handler.Add_error_message(p_message_name => 'EGO_PAGE_ENTRY_SAME_SEQ',p_application_id => G_EGO_APPLICATION_ID,
                                                  p_token_tbl => G_TOKEN_TABLE,p_message_type => G_RET_STS_ERROR,
                                                  p_row_identifier => p_ent_tbl(i).transaction_id,
                                                  p_entity_code => G_ENTITY_ENT,p_table_name => G_ENTITY_ENT_TAB);
        	END IF;
   		EXCEPTION
   			WHEN NO_DATA_FOUND THEN
   				NULL;
   			WHEN OTHERS THEN
   				x_return_status := G_RET_STS_UNEXP_ERROR;

					write_debug('ego_pages_bulkload_pvt.'||lv_proc||' - '||'Additional_ent_validations exception when others smt 2');

					error_handler.Add_error_message(p_message_text => SQLERRM,p_application_id => G_EGO_APPLICATION_ID,
                                                  p_token_tbl => G_TOKEN_TABLE,p_message_type => G_RET_STS_UNEXP_ERROR,
                                                  p_row_identifier => p_ent_tbl(i).transaction_id,
                                                  p_entity_code => G_ENTITY_ENT,p_table_name => G_ENTITY_ENT_TAB);

                    x_return_msg := 'ego_pages_bulkload_pvt.Additional_ent_validations smt 2 - '||SQLERRM;

      				RETURN;
   		END;

   		lv_smt := 3;
   		/*Convert transaction type to upper case*/
	      SELECT Upper(p_ent_tbl(i).transaction_type)
	      INTO   p_ent_tbl(i).transaction_type
	      FROM   dual;
	    /*check for invalid transaction type for PG*/
		IF (p_ent_tbl(i).transaction_type = 	G_OPR_CREATE
			OR p_ent_tbl(i).transaction_type = 	G_OPR_UPDATE
			OR p_ent_tbl(i).transaction_type = 	G_OPR_DELETE
			OR p_ent_tbl(i).transaction_type = 	G_OPR_SYNC) THEN
			NULL;
		ELSE
			write_debug('ego_pages_bulkload_pvt.'||lv_proc||' - '||'Transaction type is invalid for PG Entries');

	        p_ent_tbl(i).process_status := G_ERROR_RECORD;

	        x_return_status := G_RET_STS_ERROR;

	        write_debug('ego_pages_bulkload_pvt.'||lv_proc||' - '||'Invalid transaction type for PG Entries');

	      	error_handler.Add_error_message(p_message_name => 'EGO_TRANS_TYPE_INVALID',p_application_id => 'EGO',
	                                      	p_token_tbl => g_token_table,p_message_type => G_RET_STS_ERROR,
	                                      	p_row_identifier => p_ent_tbl(i).transaction_id,
	                                      	p_entity_code => G_ENTITY_ENT,p_table_name => G_ENTITY_ENT_TAB);
		END IF;
   	END IF;
   END LOOP;

   write_debug('ego_pages_bulkload_pvt.'||lv_proc||' - '||'Exit Additional_ent_validations');
  EXCEPTION
    WHEN OTHERS THEN
      write_debug('ego_pages_bulkload_pvt.'||lv_proc||' - '||'Additional_ent_validations Exception when others'||SQLERRM);

      x_return_status := G_RET_STS_UNEXP_ERROR;

      x_return_msg := 'ego_pages_bulkload_pvt.Additional_ent_validations - '||SQLERRM;

      RETURN;
  END Additional_ent_validations;


  /*This procedure is used to handle the common validations pertaining to Pages.
  	Used in the both the flows.
  	p_pg_tbl        IN OUT NOCOPY Pages table
  	x_return_status OUT NOCOPY parameter that returns the status*/
  PROCEDURE Common_pg_validations (p_pg_tbl        IN OUT NOCOPY ego_metadata_pub.ego_pg_tbl,
                                   x_return_status OUT NOCOPY VARCHAR2, x_return_msg OUT NOCOPY VARCHAR2)
  IS
  lv_smt NUMBER; --Statement counter
  lv_proc VARCHAR2(30) := 'Common_pg_validations';
  BEGIN
    write_debug('ego_pages_bulkload_pvt.'||lv_proc||' - '||'Entered Common_pg_validations');

    x_return_status := G_RET_STS_SUCCESS;

    FOR i IN p_pg_tbl.FIRST.. p_pg_tbl.LAST LOOP
    	IF (p_pg_tbl(i).process_status = G_PROCESS_RECORD) THEN
                /*Error OUT if all the mandatory columns are not populated for the create flow*/
                IF (p_pg_tbl(i).transaction_type = G_OPR_CREATE
                	AND (p_pg_tbl(i).display_name IS NULL
                	     OR p_pg_tbl(i).internal_name IS NULL
                	     OR p_pg_tbl(i).classification_code IS NULL
                	     OR p_pg_tbl(i).data_level IS NULL
                	     OR p_pg_tbl(i).sequence IS NULL)) THEN
                	write_debug('ego_pages_bulkload_pvt.'||lv_proc||' - Err_msg_TID: '||p_pg_tbl(i).transaction_id||' (PG,ICC) = ('
                	||p_pg_tbl(i).internal_name||','||p_pg_tbl(i).classification_code||'). ' ||'Mandatory columns for create flow are not populated');

                	p_pg_tbl(i).process_status := G_ERROR_RECORD;

                	error_handler.Add_error_message(p_message_name => 'EGO_PG_MANDATORY',p_application_id => G_EGO_APPLICATION_ID,
                                                  p_token_tbl => G_TOKEN_TABLE,p_message_type => G_RET_STS_ERROR,
                                                  p_row_identifier => p_pg_tbl(i).transaction_id,
                                                  p_entity_code => G_ENTITY_PG,p_table_name => G_ENTITY_PG_TAB);

                 END IF;

                 /*Error out if the data level populated is invalid*/
                 IF ((p_pg_tbl(i).data_level = G_DL_ITEM_LEVEL
                 	 OR p_pg_tbl(i).data_level = G_DL_ITEM_REV_LEVEL
                 	 OR p_pg_tbl(i).data_level = G_DL_ITEM_ORG
                 	 OR p_pg_tbl(i).data_level = G_DL_ITEM_SUP
                 	 OR p_pg_tbl(i).data_level = G_DL_ITEM_SUP_SITE
                 	 OR p_pg_tbl(i).data_level = G_DL_ITEM_SUP_SITE_ORG)) THEN
                 	NULL;
                 ELSIF (p_pg_tbl(i).transaction_type <> G_OPR_DELETE) THEN
                 	write_debug('ego_pages_bulkload_pvt.'||lv_proc||' - Err_msg_TID: '||p_pg_tbl(i).transaction_id||' (PG,DL) = ('
                 	||p_pg_tbl(i).internal_name||','||p_pg_tbl(i).data_level||'). ' ||'Data Level passed is invalid');

                 	p_pg_tbl(i).process_status := G_ERROR_RECORD;

                	error_handler.Add_error_message(p_message_name => 'EGO_DL_NOT_EXIST',p_application_id => G_EGO_APPLICATION_ID,
                                                  p_token_tbl => G_TOKEN_TABLE,p_message_type => G_RET_STS_ERROR,
                                                  p_row_identifier => p_pg_tbl(i).transaction_id,
                                                  p_entity_code => G_ENTITY_PG,p_table_name => G_ENTITY_PG_TAB);
   				 END IF;

   				 /*Error out if ICC id or name passed is invalid populated is invalid*/
   				 IF (p_pg_tbl(i).classification_code IS NULL OR p_pg_tbl(i).classification_name IS NULL) THEN
					write_debug('ego_pages_bulkload_pvt.'||lv_proc||' - Err_msg_TID: '||p_pg_tbl(i).transaction_id||' (PG,ICC) = ('
					||p_pg_tbl(i).internal_name||','||p_pg_tbl(i).classification_code||'). ' ||'ICC code or name passed is invalid');

   				 	p_pg_tbl(i).process_status := G_ERROR_RECORD;

                	error_handler.Add_error_message(p_message_name => 'EGO_PG_ICC_INVALID',p_application_id => G_EGO_APPLICATION_ID,
                                                  p_token_tbl => G_TOKEN_TABLE,p_message_type => G_RET_STS_ERROR,
                                                  p_row_identifier => p_pg_tbl(i).transaction_id,
                                                  p_entity_code => G_ENTITY_PG,p_table_name => G_ENTITY_PG_TAB);
   				 END IF;
        END IF;
    END LOOP;
    write_debug('ego_pages_bulkload_pvt.'||lv_proc||' - '||'Exit Common_pg_validations');
  EXCEPTION
    WHEN OTHERS THEN
        write_debug('ego_pages_bulkload_pvt.'||lv_proc||' - '||'Common_pg_validations Exception when others'||SQLERRM);

        x_return_status := G_RET_STS_UNEXP_ERROR;

        x_return_msg := 'ego_pages_bulkload_pvt.Common_pg_validations - '||SQLERRM;

      	RETURN;
  END Common_pg_validations;

  /*This procedure is used to handle the common validations pertaining to page entries.
  	Used in both flows.
  	p_ent_tbl       IN OUT NOCOPY Page Entries table
  	x_return_status OUT NOCOPY parameter that returns the status*/
  PROCEDURE Common_ent_validations (p_ent_tbl       IN OUT NOCOPY ego_metadata_pub.ego_ent_tbl,
                                    x_return_status OUT NOCOPY VARCHAR2, x_return_msg OUT NOCOPY VARCHAR2)
  IS
  lv_smt NUMBER; --Statement counter
  lv_proc VARCHAR2(30) := 'Common_ent_validations';
  BEGIN
    write_debug('ego_pages_bulkload_pvt.'||lv_proc||' - '||'Entered Common_ent_validations');

    x_return_status := G_RET_STS_SUCCESS;

    FOR i IN p_ent_tbl.FIRST.. p_ent_tbl.LAST LOOP
    	IF (p_ent_tbl(i).process_status = G_PROCESS_RECORD) THEN
          /*Error out if the page id or the internal name or the classification code is null*/
          lv_smt := 1;

          write_debug('ego_pages_bulkload_pvt.'||lv_proc||' - '||'Statement 1');

          IF (p_ent_tbl(i).page_id IS NULL OR p_ent_tbl(i).internal_name IS NULL OR p_ent_tbl(i).classification_code IS NULL) THEN
          	write_debug('ego_pages_bulkload_pvt.'||lv_proc||' - Err_msg_TID: '||p_ent_tbl(i).transaction_id||' (PG) = ('
          	||p_ent_tbl(i).internal_name||'). ' ||'Page does not exist');

   			p_ent_tbl(i).process_status := G_ERROR_RECORD;

            error_handler.Add_error_message(p_message_name => 'EGO_PG_NOT_EXIST',p_application_id => G_EGO_APPLICATION_ID,
                                                  p_token_tbl => G_TOKEN_TABLE,p_message_type => G_RET_STS_ERROR,
                                                  p_row_identifier => p_ent_tbl(i).transaction_id,
                                                  p_entity_code => G_ENTITY_ENT,p_table_name => G_ENTITY_ENT_TAB);
          END IF;

          /*Error out if the classification code or the classification name is null*/
          lv_smt := 2;

          write_debug('ego_pages_bulkload_pvt.'||lv_proc||' - '||'Statement 2');

          IF (p_ent_tbl(i).classification_code IS NULL OR p_ent_tbl(i).classification_name IS NULL) THEN
          	write_debug('ego_pages_bulkload_pvt.'||lv_proc||' - Err_msg_TID: '||p_ent_tbl(i).transaction_id||' (PG,ICC) = ('
          	||p_ent_tbl(i).internal_name||','||p_ent_tbl(i).classification_code||'). ' ||'ICC does not exist');

   			p_ent_tbl(i).process_status := G_ERROR_RECORD;

            error_handler.Add_error_message(p_message_name => 'EGO_PG_ICC_INVALID',p_application_id => G_EGO_APPLICATION_ID,
                                                  p_token_tbl => G_TOKEN_TABLE,p_message_type => G_RET_STS_ERROR,
                                                  p_row_identifier => p_ent_tbl(i).transaction_id,
                                                  p_entity_code => G_ENTITY_ENT,p_table_name => G_ENTITY_ENT_TAB);
          END IF;

          /*Error out if the old_association_id or the old_attr_group_id or the old_attr_group_name is null*/
          lv_smt := 3;

          write_debug('ego_pages_bulkload_pvt.'||lv_proc||' - '||'Statement 3');

          IF (p_ent_tbl(i).old_association_id IS NULL AND (p_ent_tbl(i).old_attr_group_id IS NOT NULL OR p_ent_tbl(i).old_attr_group_name IS NOT NULL)) THEN
          	write_debug('ego_pages_bulkload_pvt.'||lv_proc||' - Err_msg_TID: '||p_ent_tbl(i).transaction_id||' (PG,AG) = ('
          	||p_ent_tbl(i).internal_name||','||p_ent_tbl(i).old_association_id||'). ' ||'Old Association does not exist');

   			p_ent_tbl(i).process_status := G_ERROR_RECORD;

            error_handler.Add_error_message(p_message_name => 'EGO_PG_ASSOC_NOT_EXIST',p_application_id => G_EGO_APPLICATION_ID,
                                                  p_token_tbl => G_TOKEN_TABLE,p_message_type => G_RET_STS_ERROR,
                                                  p_row_identifier => p_ent_tbl(i).transaction_id,
                                                  p_entity_code => G_ENTITY_ENT,p_table_name => G_ENTITY_ENT_TAB);
          END IF;

          /*Error out if the new_association_id or the new_attr_group_id or the new_attr_group_name is null*/
          lv_smt := 4;

          write_debug('ego_pages_bulkload_pvt.'||lv_proc||' - '||'Statement 4');

          IF (p_ent_tbl(i).new_association_id IS NULL AND (p_ent_tbl(i).new_attr_group_id IS NOT NULL OR p_ent_tbl(i).new_attr_group_name IS NOT NULL)) THEN
          	write_debug('ego_pages_bulkload_pvt.'||lv_proc||' - Err_msg_TID: '||p_ent_tbl(i).transaction_id||' (PG,ICC) = ('
          	||p_ent_tbl(i).internal_name||','||p_ent_tbl(i).new_association_id||'). ' ||'New association does not exist');

   			p_ent_tbl(i).process_status := G_ERROR_RECORD;

            error_handler.Add_error_message(p_message_name => 'EGO_PG_ASSOC_NOT_EXIST',p_application_id => G_EGO_APPLICATION_ID,
                                                  p_token_tbl => G_TOKEN_TABLE,p_message_type => G_RET_STS_ERROR,
                                                  p_row_identifier => p_ent_tbl(i).transaction_id,
                                                  p_entity_code => G_ENTITY_ENT,p_table_name => G_ENTITY_ENT_TAB);
          END IF;

          /*Error out if the mandatory columns for the create flow are not present*/
          IF (p_ent_tbl(i).transaction_type = G_OPR_CREATE AND (p_ent_tbl(i).page_id IS NULL
          														OR p_ent_tbl(i).old_association_id IS NULL
          														OR p_ent_tbl(i).sequence IS NULL
          														OR p_ent_tbl(i).classification_code IS NULL)) THEN
          	write_debug('ego_pages_bulkload_pvt.'||lv_proc||' - Err_msg_TID: '||p_ent_tbl(i).transaction_id||' (PG,ICC) = ('
          	||p_ent_tbl(i).internal_name||','||p_ent_tbl(i).classification_code||'). ' ||'Mandatory columns for Page Entry creation is not populated');

   			p_ent_tbl(i).process_status := G_ERROR_RECORD;

            error_handler.Add_error_message(p_message_name => 'EGO_PG_ENT_MANDATORY',p_application_id => G_EGO_APPLICATION_ID,
                                                  p_token_tbl => G_TOKEN_TABLE,p_message_type => G_RET_STS_ERROR,
                                                  p_row_identifier => p_ent_tbl(i).transaction_id,
                                                  p_entity_code => G_ENTITY_ENT,p_table_name => G_ENTITY_ENT_TAB);
          END IF;


          /*Checks whether the attribute group is already associated to the page.*/
          lv_smt := 5;

          write_debug('ego_pages_bulkload_pvt.'||lv_proc||' - '||'Statement 5');

          IF (p_ent_tbl(i).transaction_type = G_OPR_CREATE
          	  AND p_ent_tbl(i).old_association_id IS NOT NULL) THEN
          	  DECLARE
          	  lv_count NUMBER;
          	  BEGIN
          	  	SELECT COUNT(1) INTO lv_count
          	  	FROM EGO_PAGE_ENTRIES_B
          	  	WHERE page_id = p_ent_tbl(i).page_id
          	  	AND association_id = p_ent_tbl(i).old_association_id;

          	  	IF (lv_count = 1) THEN
          	  		write_debug('ego_pages_bulkload_pvt.'||lv_proc||' - Err_msg_TID: '||p_ent_tbl(i).transaction_id||' (PG,AG) = ('
          	  		||p_ent_tbl(i).internal_name||','||p_ent_tbl(i).old_association_id||'). ' ||'Cannot associate the same AG twice.');

		   			p_ent_tbl(i).process_status := G_ERROR_RECORD;

		            error_handler.Add_error_message(p_message_name => 'EGO_ATTRIBUTE_GROUP_CONSTRAINT',p_application_id => G_EGO_APPLICATION_ID,
		                                                  p_token_tbl => G_TOKEN_TABLE,p_message_type => G_RET_STS_ERROR,
		                                                  p_row_identifier => p_ent_tbl(i).transaction_id,
		                                                  p_entity_code => G_ENTITY_ENT,p_table_name => G_ENTITY_ENT_TAB);
          	  	END IF;
          	  EXCEPTION
          	  	WHEN OTHERS THEN
          	  			write_debug('ego_pages_bulkload_pvt.'||lv_proc||' - '||'Exception'||SQLERRM);

   						p_ent_tbl(i).process_status := G_RET_STS_UNEXP_ERROR;

            			error_handler.Add_error_message(p_message_text => SQLERRM,p_application_id => G_EGO_APPLICATION_ID,
                                                  p_token_tbl => G_TOKEN_TABLE,p_message_type => G_RET_STS_UNEXP_ERROR,
                                                  p_row_identifier => p_ent_tbl(i).transaction_id,
                                                  p_entity_code => G_ENTITY_ENT,p_table_name => G_ENTITY_ENT_TAB);

                        x_return_msg := 'ego_pages_bulkload_pvt.'||lv_proc||' - '||'Exception'||SQLERRM;

      					RETURN;
          	  END;
          END IF;

        END IF;
    END LOOP;
    write_debug('ego_pages_bulkload_pvt.'||lv_proc||' - '||'Exit Common_ent_validations');
  EXCEPTION
    WHEN OTHERS THEN
        write_debug('ego_pages_bulkload_pvt.'||lv_proc||' - '||'Common_ent_validations Exception when others'||SQLERRM);

        x_return_status := G_RET_STS_UNEXP_ERROR;

        x_return_msg := 'ego_pages_bulkload_pvt.Common_ent_validations - '||SQLERRM;

      	RETURN;
  END Common_ent_validations;

  /*This is the main procedure that is called by the interface flow.
    p_set_process_id   IN set_process_id
    x_return_status    OUT NOCOPY parameter that returns the status
    x_return_msg OUT NOCOPY parameter that returns the error message*/
  PROCEDURE import_pg_intf (	p_set_process_id   IN VARCHAR2,
                            	x_return_status    OUT NOCOPY VARCHAR2,
                              	x_return_msg       OUT NOCOPY VARCHAR2)
  IS
    /*Cursor to load plsql table from ego_pages_interface table*/
    CURSOR c_pg IS
      SELECT *
      FROM   ego_pages_interface
      WHERE  process_status = G_PROCESS_RECORD
      AND (p_set_process_id IS NULL
      	   OR set_process_id = p_set_process_id);
    /*Cursor to load plsql table from ego_page_entries_interface table*/
    CURSOR c_ent IS
      SELECT *
      FROM   ego_page_entries_interface
      WHERE  process_status = G_PROCESS_RECORD
      AND (p_set_process_id IS NULL
      	   OR set_process_id = p_set_process_id);

    l_ego_pg_tbl  ego_metadata_pub.ego_pg_tbl;
    l_ego_ent_tbl ego_metadata_pub.ego_ent_tbl;
    lv_proc VARCHAR2(30) := 'import_pg_intf';
  BEGIN
    write_debug('ego_pages_bulkload_pvt.'||lv_proc||' - '||'Entered import_pg_intf.');

    x_return_status := G_RET_STS_SUCCESS;

    error_handler.Set_bo_identifier(G_BO_IDENTIFIER_PG);

    G_SET_PROCESS_ID := p_set_process_id;

    Initialize(x_return_status => x_return_status, x_return_msg => x_return_msg); IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN RETURN; END IF;

    IF (G_PAGES_COUNT <> 0 OR G_PAGE_ENTRIES_COUNT <> 0) THEN
	    Validate_transaction_type(x_return_status => x_return_status, x_return_msg => x_return_msg); IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN RETURN; END IF;

	    IF (G_PAGES_COUNT <> 0) THEN
		    Bulk_validate_pages(x_return_status => x_return_status, x_return_msg => x_return_msg); IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN RETURN; END IF;

		    write_debug('ego_pages_bulkload_pvt.'||lv_proc||' - '||'Load and process PG');

		    /*Load PL/SQL tables for PG and then call processing method*/
		    OPEN c_pg;

		    LOOP
		        FETCH c_pg BULK COLLECT INTO l_ego_pg_tbl LIMIT 2000;

		        IF (l_ego_pg_tbl.COUNT <> 0) THEN
			        Process_pg(p_pg_tbl => l_ego_pg_tbl, x_return_status => x_return_status, x_return_msg => x_return_msg); IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN RETURN; END IF;

			        update_intf_pages(p_pg_tbl => l_ego_pg_tbl, x_return_status => x_return_status, x_return_msg => x_return_msg); IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN RETURN; END IF;

			        COMMIT;
		        END IF;
		        EXIT WHEN l_ego_pg_tbl.COUNT < 2000;
		    END LOOP;

		    CLOSE c_pg;

		    write_debug('ego_pages_bulkload_pvt.'||lv_proc||' - '||'PG processed');
		END IF;
		IF (G_PAGE_ENTRIES_COUNT <> 0) THEN
		    Bulk_validate_pg_entries(x_return_status, x_return_msg => x_return_msg); IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN RETURN; END IF;

		    write_debug('ego_pages_bulkload_pvt.'||lv_proc||' - '||'Load and process Page Entries');

		    /*Load PL/SQL tables for Page Entries and then call processing method*/
		    OPEN c_ent;

		    LOOP
		        FETCH c_ent BULK COLLECT INTO l_ego_ent_tbl LIMIT 2000;

		        IF (l_ego_ent_tbl.COUNT <> 0) THEN
			        Process_ent(p_ent_tbl => l_ego_ent_tbl, x_return_status => x_return_status, x_return_msg => x_return_msg); IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN RETURN; END IF;

			        update_intf_pg_entries(p_ent_tbl => l_ego_ent_tbl, x_return_status => x_return_status, x_return_msg => x_return_msg); IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN RETURN; END IF;

			        COMMIT;
		        END IF;
		        EXIT WHEN l_ego_ent_tbl.COUNT < 2000;
		    END LOOP;

		    CLOSE c_ent;

		    write_debug('ego_pages_bulkload_pvt.'||lv_proc||' - '||'Page Entries Processed');
		END IF;
    END IF;

    write_debug('ego_pages_bulkload_pvt.'||lv_proc||' - '||'Exit import_pg_intf.');
  EXCEPTION
    WHEN OTHERS THEN
        write_debug('ego_pages_bulkload_pvt.'||lv_proc||' - '||'import_pg_intf Exception when others'||SQLERRM);

        x_return_status := G_RET_STS_UNEXP_ERROR;

        x_return_msg := 'ego_pages_bulkload_pvt.import_pg_intf - '||SQLERRM;

      	RETURN;
  END import_pg_intf;


  /*This the main procedure called by the public API to create pages.
    p_pg_tbl        IN OUT NOCOPY Pages table
    p_commit        IN  controls whether commit to be executed or not
    x_return_status OUT NOCOPY  parameter that returns the status
    x_return_msg OUT NOCOPY parameter that returns the error message*/
  PROCEDURE Process_pages (	p_pg_tbl        IN OUT NOCOPY ego_metadata_pub.ego_pg_tbl,
                       		p_commit        IN BOOLEAN DEFAULT true,
                       		x_return_status OUT NOCOPY VARCHAR2, x_return_msg OUT NOCOPY VARCHAR2)
  IS
  	lv_proc VARCHAR2(30) := 'Process_pages';
  BEGIN
    write_debug('ego_pages_bulkload_pvt.'||lv_proc||' - '||'Entering Process_pages');

    x_return_status := G_RET_STS_SUCCESS;

    error_handler.Set_bo_identifier(G_BO_IDENTIFIER_PG);

    G_COMMIT := p_commit;

   	IF (p_pg_tbl.COUNT <> 0) THEN

	    /*Sets the EGO_ITEM OBJECT_ID*/
	    SELECT object_id
	    INTO   G_OBJECT_ID
	    FROM   fnd_objects
	    WHERE  obj_name = 'EGO_ITEM';

	    /*Calls Additional Validations*/
	    Additional_pg_validations(p_pg_tbl, x_return_status, x_return_msg => x_return_msg); IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN RETURN; END IF;

	    /*Send the PG table for processing*/
	    Process_pg(p_pg_tbl, x_return_status, x_return_msg => x_return_msg); IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN RETURN; END IF;
	END IF;
    write_debug('ego_pages_bulkload_pvt.'||lv_proc||' - '||'Exit Process_pages');
  EXCEPTION
    WHEN OTHERS THEN
        write_debug('ego_pages_bulkload_pvt.'||lv_proc||' - '||'Process_pages Exception when others'||SQLERRM);

        x_return_status := G_RET_STS_UNEXP_ERROR;

        x_return_msg := 'ego_pages_bulkload_pvt.Process_pages - '||SQLERRM;

      	RETURN;
  END Process_pages;

  /*This the main procedure called by the public API to create pages.
    p_ent_tbl        IN OUT NOCOPY Pages Entries table
    p_commit        IN  controls whether commit to be executed or not
    x_return_status OUT NOCOPY  parameter that returns the status
    x_return_msg OUT NOCOPY parameter that returns the error message*/
  PROCEDURE Process_pg_entries (p_ent_tbl       IN OUT NOCOPY ego_metadata_pub.ego_ent_tbl,
                        		p_commit        IN BOOLEAN DEFAULT true,
                        		x_return_status OUT NOCOPY VARCHAR2, x_return_msg OUT NOCOPY VARCHAR2)
  IS
  	lv_proc VARCHAR2(30) := 'Process_pg_entries';
  BEGIN
    write_debug('ego_pages_bulkload_pvt.'||lv_proc||' - '||'Entering Process_pg_entries');

    x_return_status := G_RET_STS_SUCCESS;

    error_handler.Set_bo_identifier(G_BO_IDENTIFIER_PG);

    G_COMMIT := p_commit;

    IF (p_ent_tbl.COUNT <> 0) THEN
	    /*Sets the EGO_ITEM OBJECT_ID*/
	    SELECT object_id
	    INTO   G_OBJECT_ID
	    FROM   fnd_objects
	    WHERE  obj_name = 'EGO_ITEM';

	    /*Calls Additional Validations*/
	    Additional_ent_validations(p_ent_tbl, x_return_status, x_return_msg => x_return_msg); IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN RETURN; END IF;

	    /*Send the Page Entries table for processing*/
	    Process_ent(p_ent_tbl, x_return_status, x_return_msg => x_return_msg); IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN RETURN; END IF;
	END IF;
    write_debug('ego_pages_bulkload_pvt.'||lv_proc||' - '||'Exit Process_pg_entries');
  EXCEPTION
    WHEN OTHERS THEN
        write_debug('ego_pages_bulkload_pvt.'||lv_proc||' - '||'Process_pg_entries Exception when others'||SQLERRM);

        x_return_status := G_RET_STS_UNEXP_ERROR;

        x_return_msg := 'ego_pages_bulkload_pvt.Process_pg_entries - '||SQLERRM;

      	RETURN;
  END Process_pg_entries;

  /*This procedure is used to process the Pages.
  	Used by both the flows.
  	p_pg_tbl        IN OUT NOCOPY Pages table
    x_return_status OUT NOCOPY parameter that returns the status
    x_return_msg OUT NOCOPY parameter that returns the error message*/
  PROCEDURE Process_pg (p_pg_tbl        IN OUT NOCOPY ego_metadata_pub.ego_pg_tbl,
                        x_return_status OUT NOCOPY VARCHAR2, x_return_msg OUT NOCOPY VARCHAR2)
  IS
    x_page_id   NUMBER;
    x_errorcode NUMBER;
    x_msg_count NUMBER;
    x_msg_data  VARCHAR2(2000);
    lv_count_pg 	NUMBER;
    lv_count_seq	NUMBER;
    lv_proc VARCHAR2(30) := 'Process_pg';
  BEGIN
    write_debug('ego_pages_bulkload_pvt.'||lv_proc||' - '||'Entering Process_pg');

    x_return_status := G_RET_STS_SUCCESS;

    Common_pg_validations(p_pg_tbl => p_pg_tbl, x_return_status => x_return_status, x_return_msg => x_return_msg); IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN RETURN; END IF;

    handle_null_pg(p_pg_tbl => p_pg_tbl, x_return_status => x_return_status, x_return_msg => x_return_msg); IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN RETURN; END IF;

    FOR i IN p_pg_tbl.first..p_pg_tbl.last LOOP
        IF ( P_pg_tbl(i).process_status = G_PROCESS_RECORD
             AND P_pg_tbl(i).transaction_type = G_OPR_CREATE ) THEN
          write_debug('ego_pages_bulkload_pvt.'||lv_proc||' - '||'Create Page');

          /*Check if the page with the internal name already exists. This repeated check is required*/
          SELECT count(1) INTO lv_count_pg
          FROM EGO_PAGES_B
          WHERE internal_name = P_pg_tbl(i).internal_name
          AND classification_code = P_pg_tbl(i).classification_code;

          /*Check if the sequence for the page is already used. This repeated check is also required*/
          SELECT count(1) INTO lv_count_seq
          FROM   ego_pages_b
          WHERE  classification_code = P_pg_tbl(i).classification_code
          AND SEQUENCE = P_pg_tbl(i).SEQUENCE;

          IF (lv_count_pg > 0) THEN
          	write_debug('ego_pages_bulkload_pvt.'||lv_proc||' - '||'Page already exists');

            p_pg_tbl(i).process_status := G_ERROR_RECORD;

            error_handler.Add_error_message(p_message_name => 'EGO_INTERNAL_NAME_EXISTS',p_application_id => G_EGO_APPLICATION_ID,
                                            p_token_tbl => G_TOKEN_TABLE,p_message_type => G_RET_STS_ERROR,
                                            p_row_identifier => p_pg_tbl(i).transaction_id,
                                            p_entity_code => G_ENTITY_PG,p_table_name => G_ENTITY_PG_TAB);
          ELSIF (lv_count_seq > 0) THEN
          	write_debug('ego_pages_bulkload_pvt.'||lv_proc||' - '||'Page sequence already exists');

            p_pg_tbl(i).process_status := G_ERROR_RECORD;

            error_handler.Add_error_message(p_message_name => 'EGO_PG_SEQ_DUP',p_application_id => G_EGO_APPLICATION_ID,
                                            p_token_tbl => G_TOKEN_TABLE,p_message_type => G_RET_STS_ERROR,
                                            p_row_identifier => p_pg_tbl(i).transaction_id,
                                            p_entity_code => G_ENTITY_PG,p_table_name => G_ENTITY_PG_TAB);
          ELSE

	          ego_ext_fwk_pub.Create_page (	  p_api_version => 1.0,
									          p_page_id => NULL,
									          p_object_id => G_OBJECT_ID,
									          p_classification_code => P_pg_tbl(i).classification_code,
									          p_data_level => P_pg_tbl(i).data_level,
									          p_internal_name => P_pg_tbl(i).internal_name,
									          p_display_name => P_pg_tbl(i).display_name,
									          p_description => P_pg_tbl(i).description,
									          p_sequence => P_pg_tbl(i).SEQUENCE,
									          p_init_msg_list => fnd_api.g_false,
									          p_commit => fnd_api.g_false,
									          x_page_id => x_page_id,
									          x_return_status => x_return_status,
									          x_errorcode => x_errorcode,
									          x_msg_count => x_msg_count,
									          x_msg_data => x_msg_data);
				IF (x_return_status = G_RET_STS_SUCCESS) THEN
	          		P_pg_tbl(i).page_id := x_page_id;

	          		P_pg_tbl(i).process_status := G_SUCCESS_RECORD;
	        	ELSIF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
	         		x_return_msg := x_msg_data;

	          		RETURN;
	        	ELSE
	          		write_debug('ego_pages_bulkload_pvt.'||lv_proc||' - '||'Error in creating PG');

	          		P_pg_tbl(i).process_status := G_ERROR_RECORD;

	          		G_TOKEN_TABLE(1).Token_Name   :=  'Entity_Name';
		            G_TOKEN_TABLE(1).Token_Value  :=  G_ENTITY_PG;
		            G_TOKEN_TABLE(2).Token_Name   :=  'Transaction_Type';
		            G_TOKEN_TABLE(2).Token_Value  :=  P_pg_tbl(i).transaction_type;
		            G_TOKEN_TABLE(3).Token_Name   :=  'Package_Name';
		            G_TOKEN_TABLE(3).Token_Value  :=  'ego_ext_fwk_pub';
		            G_TOKEN_TABLE(4).Token_Name   :=  'Proc_Name';
		            G_TOKEN_TABLE(4).Token_Value  :=  'Create_page';

	          		error_handler.Add_error_message(p_message_name => 'EGO_ENTITY_API_FAILED',p_application_id => G_EGO_APPLICATION_ID,
	                                          		p_token_tbl => g_token_table,p_message_type => G_RET_STS_ERROR,
	                                          		p_row_identifier => P_pg_tbl(i).transaction_id,
	                                          		p_entity_code => G_ENTITY_PG,p_table_name => G_ENTITY_PG_TAB);

	                error_handler.Add_error_message(p_message_text => x_msg_data,p_application_id => G_EGO_APPLICATION_ID,
	                                          		p_token_tbl => g_token_table,p_message_type => G_RET_STS_ERROR,
	                                          		p_row_identifier => P_pg_tbl(i).transaction_id,
	                                          		p_entity_code => G_ENTITY_PG,p_table_name => G_ENTITY_PG_TAB);

	                G_TOKEN_TABLE.DELETE;
	        	END IF;
			END IF;
        ELSIF ( P_pg_tbl(i).process_status = G_PROCESS_RECORD
                AND P_pg_tbl(i).transaction_type = G_OPR_UPDATE ) THEN
          write_debug('ego_pages_bulkload_pvt.'||lv_proc||' - '||'Update Page');

          ego_ext_fwk_pub.Update_page (	  p_api_version => 1.0,
								          p_page_id => P_pg_tbl(i).page_id,
								          p_internal_name => P_pg_tbl(i).internal_name,
								          p_display_name => P_pg_tbl(i).display_name,
								          p_description => P_pg_tbl(i).description,
								          p_sequence => P_pg_tbl(i).SEQUENCE,
								          p_init_msg_list => fnd_api.g_false,
								          p_commit => fnd_api.g_false,
								          p_is_nls_mode => fnd_api.g_false,
								          x_return_status => x_return_status,
								          x_errorcode => x_errorcode,
								          x_msg_count => x_msg_count,
								          x_msg_data => x_msg_data);

		  	    IF (x_return_status = G_RET_STS_SUCCESS) THEN
          		P_pg_tbl(i).process_status := G_SUCCESS_RECORD;
          	ELSIF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
          		x_return_msg := x_msg_data;

          		RETURN;
          	ELSE
          		write_debug('ego_pages_bulkload_pvt.'||lv_proc||' - '||'Error in creating PG');

          		P_pg_tbl(i).process_status := G_ERROR_RECORD;

          		G_TOKEN_TABLE(1).Token_Name   :=  'Entity_Name';
	            G_TOKEN_TABLE(1).Token_Value  :=  G_ENTITY_PG;
	            G_TOKEN_TABLE(2).Token_Name   :=  'Transaction_Type';
	            G_TOKEN_TABLE(2).Token_Value  :=  P_pg_tbl(i).transaction_type;
	            G_TOKEN_TABLE(3).Token_Name   :=  'Package_Name';
	            G_TOKEN_TABLE(3).Token_Value  :=  'ego_ext_fwk_pub';
	            G_TOKEN_TABLE(4).Token_Name   :=  'Proc_Name';
	            G_TOKEN_TABLE(4).Token_Value  :=  'Update_page';

          		error_handler.Add_error_message(p_message_name => 'EGO_ENTITY_API_FAILED',p_application_id => G_EGO_APPLICATION_ID,
                                          		p_token_tbl => g_token_table,p_message_type => G_RET_STS_ERROR,
                                         		p_row_identifier => P_pg_tbl(i).transaction_id,
                                          		p_entity_code => G_ENTITY_PG,p_table_name => G_ENTITY_PG_TAB);

                error_handler.Add_error_message(p_message_text => x_msg_data,p_application_id => G_EGO_APPLICATION_ID,
                                          		p_token_tbl => g_token_table,p_message_type => G_RET_STS_ERROR,
                                         		p_row_identifier => P_pg_tbl(i).transaction_id,
                                          		p_entity_code => G_ENTITY_PG,p_table_name => G_ENTITY_PG_TAB);

                G_TOKEN_TABLE.DELETE;
            END IF;
        ELSIF ( P_pg_tbl(i).process_status = G_PROCESS_RECORD
                AND P_pg_tbl(i).transaction_type = G_OPR_DELETE ) THEN
          write_debug('ego_pages_bulkload_pvt.'||lv_proc||' - '||'Delete Page');

          ego_ext_fwk_pub.Delete_page (	  p_api_version => 1.0,
								          p_object_id => G_OBJECT_ID,
								          p_classification_code => P_pg_tbl(i).classification_code,
								          p_internal_name => P_pg_tbl(i).internal_name,
								          p_init_msg_list => fnd_api.g_false,
								          p_commit => fnd_api.g_false,
								          x_return_status => x_return_status,
								          x_errorcode => x_errorcode,
								          x_msg_count => x_msg_count,
								          x_msg_data => x_msg_data);

		  	    IF (x_return_status = G_RET_STS_SUCCESS) THEN
          		P_pg_tbl(i).process_status := G_SUCCESS_RECORD;
          	ELSIF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
          		x_return_msg := x_msg_data;

          		RETURN;
          	ELSE
          		write_debug('ego_pages_bulkload_pvt.'||lv_proc||' - '||'Error in creating PG');

          		P_pg_tbl(i).process_status := G_ERROR_RECORD;

          		G_TOKEN_TABLE(1).Token_Name   :=  'Entity_Name';
	            G_TOKEN_TABLE(1).Token_Value  :=  G_ENTITY_PG;
	            G_TOKEN_TABLE(2).Token_Name   :=  'Transaction_Type';
	            G_TOKEN_TABLE(2).Token_Value  :=  P_pg_tbl(i).transaction_type;
	            G_TOKEN_TABLE(3).Token_Name   :=  'Package_Name';
	            G_TOKEN_TABLE(3).Token_Value  :=  'ego_ext_fwk_pub';
	            G_TOKEN_TABLE(4).Token_Name   :=  'Proc_Name';
	            G_TOKEN_TABLE(4).Token_Value  :=  'Delete_page';

          		error_handler.Add_error_message(p_message_name => 'EGO_ENTITY_API_FAILED',p_application_id => G_EGO_APPLICATION_ID,
                                          		p_token_tbl => g_token_table,p_message_type => G_RET_STS_ERROR,
                                         		p_row_identifier => P_pg_tbl(i).transaction_id,
                                          		p_entity_code => G_ENTITY_PG,p_table_name => G_ENTITY_PG_TAB);

                error_handler.Add_error_message(p_message_text => x_msg_data,p_application_id => G_EGO_APPLICATION_ID,
                                          		p_token_tbl => g_token_table,p_message_type => G_RET_STS_ERROR,
                                         		p_row_identifier => P_pg_tbl(i).transaction_id,
                                          		p_entity_code => G_ENTITY_PG,p_table_name => G_ENTITY_PG_TAB);

                G_TOKEN_TABLE.DELETE;
            END IF;

        END IF;
    END LOOP;

    IF ( G_COMMIT = true AND G_FLOW_TYPE = G_EGO_MD_API) THEN
      write_debug('ego_pages_bulkload_pvt.'||lv_proc||' - '||'Commit Process_pg');

      COMMIT;
    END IF;

    write_debug('ego_pages_bulkload_pvt.'||lv_proc||' - '||'Exit Process_pg');
  EXCEPTION
    WHEN OTHERS THEN
        x_return_status := G_RET_STS_UNEXP_ERROR;

        write_debug('ego_pages_bulkload_pvt.'||lv_proc||' - '||'Process_pg Exception when others'||SQLERRM);

        x_return_msg := 'ego_pages_bulkload_pvt.Process_pg - '||SQLERRM;

      	RETURN;
  END Process_pg;

  /*This procedure is used to process the page entries.
  	Used in both flows.
  	p_ent_tbl       IN OUT NOCOPY Page Entries table
    x_return_status OUT NOCOPY parameter that returns the status
    x_return_msg OUT NOCOPY parameter that returns the error message*/
  PROCEDURE Process_ent (p_ent_tbl       IN OUT NOCOPY ego_metadata_pub.ego_ent_tbl,
                         x_return_status OUT NOCOPY VARCHAR2, x_return_msg OUT NOCOPY VARCHAR2)
  IS
    x_page_id   NUMBER;
    x_errorcode NUMBER;
    x_msg_count NUMBER;
    x_msg_data  VARCHAR2(2000);
    lv_count_ag	NUMBER;
    lv_count_seq NUMBER;
    lv_proc VARCHAR2(30) := 'Process_ent';
  BEGIN
    write_debug('ego_pages_bulkload_pvt.'||lv_proc||' - '||'Entering Process_ent');

    x_return_status := G_RET_STS_SUCCESS;

    Common_ent_validations(p_ent_tbl => p_ent_tbl, x_return_status => x_return_status, x_return_msg => x_return_msg); IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN RETURN; END IF;

    handle_null_pg_entries(p_ent_tbl => p_ent_tbl, x_return_status => x_return_status, x_return_msg => x_return_msg); IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN RETURN; END IF;

    FOR i IN p_ent_tbl.first..p_ent_tbl.last LOOP
        IF ( P_ent_tbl(i).process_status = G_PROCESS_RECORD
             AND P_ent_tbl(i).transaction_type = G_OPR_CREATE ) THEN
          write_debug('ego_pages_bulkload_pvt.'||lv_proc||' - '||'Create Page Entity');

          /*check if the same AG is being reassociated to the page. This repeat check is required*/
          SELECT count(1) INTO lv_count_ag
          FROM EGO_PAGE_ENTRIES_B
          WHERE page_id = P_ent_tbl(i).page_id
          AND classification_code = P_ent_tbl(i).classification_code
          AND association_id =  P_ent_tbl(i).old_association_id;

          /*check if the same sequence is already used. This repeat check is required.*/
          SELECT count(1) INTO lv_count_seq
           FROM   ego_page_entries_b
           WHERE  page_id = P_ent_tbl(i).page_id
       	   AND sequence = P_ent_tbl(i).sequence;

          IF (lv_count_ag > 0) THEN
          	write_debug('ego_pages_bulkload_pvt.'||lv_proc||' - '||'Page Entry association already exists');

            P_ent_tbl(i).process_status := G_ERROR_RECORD;

            error_handler.Add_error_message(p_message_name => 'EGO_PG_AG_DUP',p_application_id => G_EGO_APPLICATION_ID,
                                            p_token_tbl => G_TOKEN_TABLE,p_message_type => G_RET_STS_ERROR,
                                            p_row_identifier => P_ent_tbl(i).transaction_id,
                                            p_entity_code => G_ENTITY_ENT,p_table_name => G_ENTITY_ENT_TAB);
          ELSIF (lv_count_seq > 0) THEN
          	write_debug('ego_pages_bulkload_pvt.'||lv_proc||' - '||'Page Entry sequence already exists');

            P_ent_tbl(i).process_status := G_ERROR_RECORD;

            error_handler.Add_error_message(p_message_name => 'EGO_PAGE_ENTRY_SAME_SEQ',p_application_id => G_EGO_APPLICATION_ID,
                                            p_token_tbl => G_TOKEN_TABLE,p_message_type => G_RET_STS_ERROR,
                                            p_row_identifier => P_ent_tbl(i).transaction_id,
                                            p_entity_code => G_ENTITY_ENT,p_table_name => G_ENTITY_ENT_TAB);
          ELSE

	          ego_ext_fwk_pub.Create_page_entry ( p_api_version => 1.0,
										          p_page_id => P_ent_tbl(i).page_id,
										          p_association_id => P_ent_tbl(i).old_association_id,
										          p_sequence => P_ent_tbl(i).SEQUENCE,
										          p_classification_code => P_ent_tbl(i).classification_code,
										          p_init_msg_list => fnd_api.g_false,
										          p_commit => fnd_api.g_false,
										          x_return_status => x_return_status,
										          x_errorcode => x_errorcode,
										          x_msg_count => x_msg_count,
										          x_msg_data => x_msg_data);

			  	IF (x_return_status = G_RET_STS_SUCCESS) THEN
	          		P_ent_tbl(i).process_status := G_SUCCESS_RECORD;
	          	ELSIF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
	          		x_return_msg := x_msg_data;

	          		RETURN;
	          	ELSE
	          		write_debug('ego_pages_bulkload_pvt.'||lv_proc||' - '||'Error in creating PG');

	          		P_ent_tbl(i).process_status := G_ERROR_RECORD;

	          		G_TOKEN_TABLE(1).Token_Name   :=  'Entity_Name';
		            G_TOKEN_TABLE(1).Token_Value  :=  G_ENTITY_ENT;
		            G_TOKEN_TABLE(2).Token_Name   :=  'Transaction_Type';
		            G_TOKEN_TABLE(2).Token_Value  :=  P_ent_tbl(i).transaction_type;
		            G_TOKEN_TABLE(3).Token_Name   :=  'Package_Name';
		            G_TOKEN_TABLE(3).Token_Value  :=  'ego_ext_fwk_pub';
		            G_TOKEN_TABLE(4).Token_Name   :=  'Proc_Name';
		            G_TOKEN_TABLE(4).Token_Value  :=  'Create_page_entry';

	          		error_handler.Add_error_message(p_message_name => 'EGO_ENTITY_API_FAILED',p_application_id => G_EGO_APPLICATION_ID,
	                                          		p_token_tbl => g_token_table,p_message_type => G_RET_STS_ERROR,
	                                         		p_row_identifier => P_ent_tbl(i).transaction_id,
	                                          		p_entity_code => G_ENTITY_ENT,p_table_name => G_ENTITY_ENT_TAB);

	                error_handler.Add_error_message(p_message_text => x_msg_data,p_application_id => G_EGO_APPLICATION_ID,
	                                          		p_token_tbl => g_token_table,p_message_type => G_RET_STS_ERROR,
	                                         		p_row_identifier => P_ent_tbl(i).transaction_id,
	                                          		p_entity_code => G_ENTITY_ENT,p_table_name => G_ENTITY_ENT_TAB);

	                G_TOKEN_TABLE.DELETE;
	            END IF;
			END IF;
        ELSIF ( P_ent_tbl(i).process_status = G_PROCESS_RECORD
                AND P_ent_tbl(i).transaction_type = G_OPR_UPDATE ) THEN
          write_debug('ego_pages_bulkload_pvt.'||lv_proc||' - '||'Update Page Entity');

          /*Added for bug 9733398*/
          /*check if the same sequence is already used.*/
          SELECT count(1) INTO lv_count_seq
           FROM   ego_page_entries_b
           WHERE  page_id = P_ent_tbl(i).page_id
       	   AND sequence = P_ent_tbl(i).sequence
       	   AND association_id <> P_ent_tbl(i).old_association_id;

       	  IF (lv_count_seq > 0) THEN
          	write_debug('ego_pages_bulkload_pvt.'||lv_proc||' - '||'Page Entry sequence already exists');

            P_ent_tbl(i).process_status := G_ERROR_RECORD;

            error_handler.Add_error_message(p_message_name => 'EGO_PAGE_ENTRY_SAME_SEQ',p_application_id => G_EGO_APPLICATION_ID,
                                            p_token_tbl => G_TOKEN_TABLE,p_message_type => G_RET_STS_ERROR,
                                            p_row_identifier => P_ent_tbl(i).transaction_id,
                                            p_entity_code => G_ENTITY_ENT,p_table_name => G_ENTITY_ENT_TAB);
          ELSE
          /*End of comment for bug 9733398*/
	          ego_ext_fwk_pub.Update_page_entry ( p_api_version => 1.0,
										          p_page_id => P_ent_tbl(i).page_id,
										          p_new_association_id => NVL(P_ent_tbl(i).new_association_id,P_ent_tbl(i).old_association_id),
										          p_old_association_id => P_ent_tbl(i).old_association_id,
										          p_sequence => P_ent_tbl(i).SEQUENCE,
										          p_init_msg_list => fnd_api.g_false,
										          p_commit => fnd_api.g_false,
										          x_return_status => x_return_status,
										          x_errorcode => x_errorcode,
										          x_msg_count => x_msg_count,
										          x_msg_data => x_msg_data);

			  	IF (x_return_status = G_RET_STS_SUCCESS) THEN
	          		P_ent_tbl(i).process_status := G_SUCCESS_RECORD;
	          	ELSIF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
	          		x_return_msg := x_msg_data;

	          		RETURN;
	          	ELSE
	          		write_debug('ego_pages_bulkload_pvt.'||lv_proc||' - '||'Error in creating PG');

	          		P_ent_tbl(i).process_status := G_ERROR_RECORD;

	          		G_TOKEN_TABLE(1).Token_Name   :=  'Entity_Name';
		            G_TOKEN_TABLE(1).Token_Value  :=  G_ENTITY_ENT;
		            G_TOKEN_TABLE(2).Token_Name   :=  'Transaction_Type';
		            G_TOKEN_TABLE(2).Token_Value  :=  P_ent_tbl(i).transaction_type;
		            G_TOKEN_TABLE(3).Token_Name   :=  'Package_Name';
		            G_TOKEN_TABLE(3).Token_Value  :=  'ego_ext_fwk_pub';
		            G_TOKEN_TABLE(4).Token_Name   :=  'Proc_Name';
		            G_TOKEN_TABLE(4).Token_Value  :=  'Update_page_entry';

	          		error_handler.Add_error_message(p_message_name => 'EGO_ENTITY_API_FAILED',p_application_id => G_EGO_APPLICATION_ID,
	                                          		p_token_tbl => g_token_table,p_message_type => G_RET_STS_ERROR,
	                                         		p_row_identifier => P_ent_tbl(i).transaction_id,
	                                          		p_entity_code => G_ENTITY_ENT,p_table_name => G_ENTITY_ENT_TAB);

	                error_handler.Add_error_message(p_message_text => x_msg_data,p_application_id => G_EGO_APPLICATION_ID,
	                                          		p_token_tbl => g_token_table,p_message_type => G_RET_STS_ERROR,
	                                         		p_row_identifier => P_ent_tbl(i).transaction_id,
	                                          		p_entity_code => G_ENTITY_ENT,p_table_name => G_ENTITY_ENT_TAB);

	                G_TOKEN_TABLE.DELETE;
	            END IF;
			END IF;	  /*Added for bug 9733398*/
        ELSIF ( P_ent_tbl(i).process_status = G_PROCESS_RECORD
                AND P_ent_tbl(i).transaction_type = G_OPR_DELETE ) THEN
          write_debug('ego_pages_bulkload_pvt.'||lv_proc||' - '||'Delete Page Entity');

          ego_ext_fwk_pub.Delete_page_entry ( p_api_version => 1.0,
									          p_page_id => P_ent_tbl(i).page_id,
									          p_association_id => P_ent_tbl(i).old_association_id,
									          p_classification_code => P_ent_tbl(i).classification_code,
									          p_init_msg_list => fnd_api.g_false,
									          p_commit => fnd_api.g_false,
									          x_return_status => x_return_status,
									          x_errorcode => x_errorcode,
									          x_msg_count => x_msg_count,
									          x_msg_data => x_msg_data);

			IF (x_return_status = G_RET_STS_SUCCESS) THEN
          		P_ent_tbl(i).process_status := G_SUCCESS_RECORD;
          	ELSIF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
          		x_return_msg := x_msg_data;

          		RETURN;
          	ELSE
          		write_debug('ego_pages_bulkload_pvt.'||lv_proc||' - '||'Error in creating PG');

          		P_ent_tbl(i).process_status := G_ERROR_RECORD;

          		G_TOKEN_TABLE(1).Token_Name   :=  'Entity_Name';
	            G_TOKEN_TABLE(1).Token_Value  :=  G_ENTITY_ENT;
	            G_TOKEN_TABLE(2).Token_Name   :=  'Transaction_Type';
	            G_TOKEN_TABLE(2).Token_Value  :=  P_ent_tbl(i).transaction_type;
	            G_TOKEN_TABLE(3).Token_Name   :=  'Package_Name';
	            G_TOKEN_TABLE(3).Token_Value  :=  'ego_ext_fwk_pub';
	            G_TOKEN_TABLE(4).Token_Name   :=  'Proc_Name';
	            G_TOKEN_TABLE(4).Token_Value  :=  'Delete_page_entry';

          		error_handler.Add_error_message(p_message_name => 'EGO_ENTITY_API_FAILED',p_application_id => G_EGO_APPLICATION_ID,
                                          		p_token_tbl => g_token_table,p_message_type => G_RET_STS_ERROR,
                                         		p_row_identifier => P_ent_tbl(i).transaction_id,
                                          		p_entity_code => G_ENTITY_ENT,p_table_name => G_ENTITY_ENT_TAB);

                error_handler.Add_error_message(p_message_text => x_msg_data,p_application_id => G_EGO_APPLICATION_ID,
                                          		p_token_tbl => g_token_table,p_message_type => G_RET_STS_ERROR,
                                         		p_row_identifier => P_ent_tbl(i).transaction_id,
                                          		p_entity_code => G_ENTITY_ENT,p_table_name => G_ENTITY_ENT_TAB);

                G_TOKEN_TABLE.DELETE;
            END IF;

        END IF;
    END LOOP;

    IF ( G_COMMIT = true AND G_FLOW_TYPE = G_EGO_MD_API ) THEN
      write_debug('ego_pages_bulkload_pvt.'||lv_proc||' - '||'Commit Process_ent');

      COMMIT;
    END IF;

    write_debug('ego_pages_bulkload_pvt.'||lv_proc||' - '||'Exit Process_ent');
  EXCEPTION
    WHEN OTHERS THEN
        x_return_status := G_RET_STS_UNEXP_ERROR;

        write_debug('ego_pages_bulkload_pvt.'||lv_proc||' - '||'Process_ent Exception when others'||SQLERRM);

        x_return_msg := 'ego_pages_bulkload_pvt.Process_ent - '||SQLERRM;

      	RETURN;
  END Process_ent;

  /*This procedure is used to update the Pages interface table.
    Used in the interface flow.
    p_pg_tbl        IN OUT NOCOPY Pages table
    x_return_status OUT NOCOPY  parameter that returns the status
    x_return_msg OUT NOCOPY parameter that returns the error message*/
  PROCEDURE update_intf_pages (p_pg_tbl        IN OUT NOCOPY ego_metadata_pub.ego_pg_tbl,
                                 x_return_status OUT NOCOPY VARCHAR2, x_return_msg OUT NOCOPY VARCHAR2)
  IS
  	lv_proc VARCHAR2(30) := 'update_intf_pages';
  	trans_id dbms_sql.number_table;
  BEGIN
    write_debug('ego_pages_bulkload_pvt.'||lv_proc||' - '||'Entering update_intf_pages');

    x_return_status := G_RET_STS_SUCCESS;

    FOR i IN p_pg_tbl.FIRST..p_pg_tbl.LAST LOOP
    	trans_id(i) := p_pg_tbl(i).transaction_id;
  	END LOOP;

    FORALL i IN p_pg_tbl.first..p_pg_tbl.last
      UPDATE ego_pages_interface
      SET    ROW = P_pg_tbl(i)
      WHERE  transaction_id = trans_id(i);

   write_debug('ego_pages_bulkload_pvt.'||lv_proc||' - '||'Exit update_intf_pages');
  EXCEPTION
    WHEN OTHERS THEN
        x_return_status := G_RET_STS_UNEXP_ERROR;

        write_debug('ego_pages_bulkload_pvt.'||lv_proc||' - '||'update_intf_pages Exception when others'||SQLERRM);

        x_return_msg := 'ego_pages_bulkload_pvt.update_intf_pages - '||SQLERRM;

      	RETURN;
  END update_intf_pages;

  /*This procedure is used to update the page entries interface table.
  	Used in the interface flow.
  	p_ent_tbl        IN OUT NOCOPY Page Entries table
    x_return_status OUT NOCOPY  parameter that returns the status
    x_return_msg OUT NOCOPY parameter that returns the error message*/
  PROCEDURE update_intf_pg_entries (p_ent_tbl       IN OUT NOCOPY ego_metadata_pub.ego_ent_tbl,
                                  x_return_status OUT NOCOPY VARCHAR2, x_return_msg OUT NOCOPY VARCHAR2)
  IS
  	lv_proc VARCHAR2(30) := 'update_intf_pg_entries';
  	trans_id dbms_sql.number_table;
  BEGIN
    write_debug('ego_pages_bulkload_pvt.'||lv_proc||' - '||'Entering update_intf_pg_entries');

    x_return_status := G_RET_STS_SUCCESS;

    FOR i IN p_ent_tbl.FIRST..p_ent_tbl.LAST LOOP
    	trans_id(i) := p_ent_tbl(i).transaction_id;
  	END LOOP;

    FORALL i IN p_ent_tbl.first..p_ent_tbl.last
      UPDATE ego_page_entries_interface
      SET    ROW = P_ent_tbl(i)
      WHERE  transaction_id = trans_id(i);

    write_debug('ego_pages_bulkload_pvt.'||lv_proc||' - '||'Exit update_intf_pg_entries');


  EXCEPTION
    WHEN OTHERS THEN
        x_return_status := G_RET_STS_UNEXP_ERROR;

        write_debug('ego_pages_bulkload_pvt.'||lv_proc||' - '||'update_intf_pg_entries Exception when others'||SQLERRM);

        x_return_msg := 'ego_pages_bulkload_pvt.update_intf_pg_entries - '||SQLERRM;

      	RETURN;
  END update_intf_pg_entries;

  /*This procedure is used to delete processed records from the pages interface
    Used in the interface flow.
    x_set_process_id IN Set Process ID
    x_return_status OUT NOCOPY  parameter that returns the status
    x_return_msg OUT NOCOPY parameter that returns the error message*/
  PROCEDURE delete_processed_pages(
    x_set_process_id IN NUMBER,
    x_return_status OUT NOCOPY VARCHAR2, x_return_msg OUT NOCOPY VARCHAR2)
    IS
    	lv_proc VARCHAR2(30) := 'delete_processed_pages';
    BEGIN
    	write_debug('ego_pages_bulkload_pvt.'||lv_proc||' - '||'Entering delete_processed_pages');

    	x_return_status := G_RET_STS_SUCCESS;

    	DELETE FROM ego_pages_interface
    	WHERE process_status = G_SUCCESS_RECORD
    	AND (x_set_process_id IS NULL
    		 OR set_process_id = x_set_process_id);

    	write_debug('ego_pages_bulkload_pvt.'||lv_proc||' - '||'Exit delete_processed_pages');
    EXCEPTION
    	WHEN OTHERS THEN
    		write_debug('ego_pages_bulkload_pvt.'||lv_proc||' - '||'delete_processed_pages Exception when others'||SQLERRM);

    		x_return_status := G_RET_STS_UNEXP_ERROR;

    		x_return_msg := 'ego_pages_bulkload_pvt.delete_processed_pages - '||SQLERRM;

    		RETURN;
    END delete_processed_pages;

  /*This procedure is used to deleted processed records from the page entries interface
  	Used in the interface flow.
  	x_set_process_id IN Set Process ID
    x_return_status OUT NOCOPY  parameter that returns the status
    x_return_msg OUT NOCOPY parameter that returns the error message*/
  PROCEDURE delete_processed_pg_entries(
    x_set_process_id IN NUMBER,
    x_return_status OUT NOCOPY VARCHAR2, x_return_msg OUT NOCOPY VARCHAR2)
    IS
    	lv_proc VARCHAR2(30) := 'delete_processed_pg_entries';
    BEGIN
    	write_debug('ego_pages_bulkload_pvt.'||lv_proc||' - '||'Entering delete_processed_pg_entries');

    	x_return_status := G_RET_STS_SUCCESS;

    	DELETE FROM ego_page_entries_interface
    	WHERE process_status = G_SUCCESS_RECORD
    	AND (x_set_process_id IS NULL
    		 OR set_process_id = x_set_process_id);

    	write_debug('ego_pages_bulkload_pvt.'||lv_proc||' - '||'Exit delete_processed_pg_entries');
    EXCEPTION
    	WHEN OTHERS THEN
    		write_debug('ego_pages_bulkload_pvt.'||lv_proc||' - '||'delete_processed_pg_entries Exception when others'||SQLERRM);

    		x_return_status := G_RET_STS_UNEXP_ERROR;

    		x_return_msg := 'ego_pages_bulkload_pvt.delete_processed_pg_entries - '||SQLERRM;

    		RETURN;
    END delete_processed_pg_entries;

  /*This procedure is used in the update flow to handle null values for PG
        Used in the interface and API flow.
        p_pg_tbl        IN OUT NOCOPY Pages plsql table
        x_return_status OUT NOCOPY parameter that returns the status
        x_return_msg OUT NOCOPY parameter that returns the error message*/
  PROCEDURE handle_null_pg(
    p_pg_tbl        IN OUT NOCOPY ego_metadata_pub.ego_pg_tbl,
    x_return_status OUT NOCOPY VARCHAR2, x_return_msg OUT NOCOPY VARCHAR2)
    IS
    lv_sequence NUMBER;
    lv_display_name VARCHAR2(40);
    lv_description VARCHAR2(40);
    lv_proc VARCHAR2(30) := 'handle_null_pg';
    BEGIN
        write_debug('ego_pages_bulkload_pvt.'||lv_proc||' - '||'Entering handle_null_pg');

        x_return_status := G_RET_STS_SUCCESS;

        FOR i IN p_pg_tbl.FIRST..p_pg_tbl.LAST LOOP
                IF (p_pg_tbl(i).process_status = G_PROCESS_RECORD
                        AND p_pg_tbl(i).transaction_type = G_OPR_UPDATE) THEN
                        BEGIN
                                write_debug('ego_pages_bulkload_pvt.'||lv_proc||' - '||'Smt 1');

                                SELECT sequence INTO lv_sequence
                                FROM EGO_PAGES_B
                                WHERE page_id = p_pg_tbl(i).page_id;

                                write_debug('ego_pages_bulkload_pvt.'||lv_proc||' - '||'Smt 2');

                                SELECT display_name, description INTO lv_display_name, lv_description
                                FROM EGO_PAGES_TL
                                WHERE page_id = p_pg_tbl(i).page_id
                                AND USERENV('LANG') = LANGUAGE;

                                write_debug('ego_pages_bulkload_pvt.'||lv_proc||' - '||'Smt 3');
                                IF (p_pg_tbl(i).display_name IS NULL or p_pg_tbl(i).display_name = G_NULL_CHAR) THEN
                                	p_pg_tbl(i).display_name := lv_display_name;
                                END IF;
                                write_debug('ego_pages_bulkload_pvt.'||lv_proc||' - '||'Smt 4');
                                IF (p_pg_tbl(i).description = G_NULL_CHAR) THEN
                                write_debug('1');
                            		p_pg_tbl(i).description := NULL;
                            	ELSIF (p_pg_tbl(i).description IS NULL) THEN
                            		write_debug('2');
                            		p_pg_tbl(i).description := lv_description;
                                END IF;
                                write_debug('ego_pages_bulkload_pvt.'||lv_proc||' - '||'Smt 5');
                                IF (p_pg_tbl(i).sequence IS NULL OR p_pg_tbl(i).sequence = G_NULL_NUM) THEN
                                	p_pg_tbl(i).sequence := lv_sequence;
                                END IF;
                        EXCEPTION
                        	WHEN OTHERS THEN
                        		x_return_status := G_RET_STS_UNEXP_ERROR;

                                write_debug('ego_pages_bulkload_pvt.'||lv_proc||' - '||'handle_null_pg exception when others smt 1');

                                x_return_msg := 'ego_pages_bulkload_pvt.handle_null_pg - '||SQLERRM;

                                RETURN;
                        END;
                END IF;
        END LOOP;
        write_debug('ego_pages_bulkload_pvt.'||lv_proc||' - '||'Exit handle_null_pg');
   EXCEPTION
   	WHEN OTHERS THEN
   		write_debug('ego_pages_bulkload_pvt.'||lv_proc||' - '||'handle_null_pg Exception when others'||SQLERRM);
   END handle_null_pg;


     /*This procedure is used in the update flow to handle null values for PG Entries
        Used in the interface and API flow.
        p_ent_tbl        IN OUT NOCOPY Page Entries plsql table
        x_return_status OUT NOCOPY parameter that returns the status
        x_return_msg OUT NOCOPY parameter that returns the error message*/
  PROCEDURE handle_null_pg_entries(
    p_ent_tbl        IN OUT NOCOPY ego_metadata_pub.ego_ent_tbl,
    x_return_status OUT NOCOPY VARCHAR2, x_return_msg OUT NOCOPY VARCHAR2)
    IS
    lv_sequence NUMBER;
    lv_proc VARCHAR2(30) := 'handle_null_pg_entries';
    BEGIN
        write_debug('ego_pages_bulkload_pvt.'||lv_proc||' - '||'Entering handle_null_pg_entries');

        x_return_status := G_RET_STS_SUCCESS;

        FOR i IN p_ent_tbl.FIRST..p_ent_tbl.LAST LOOP
                IF (p_ent_tbl(i).process_status = G_PROCESS_RECORD
                        AND p_ent_tbl(i).transaction_type = G_OPR_UPDATE) THEN
                        BEGIN
                                write_debug('ego_pages_bulkload_pvt.'||lv_proc||' - '||'Smt 1');

                                SELECT sequence INTO lv_sequence
                                FROM EGO_PAGE_ENTRIES_B
                                WHERE page_id = p_ent_tbl(i).page_id
                                AND association_id = p_ent_tbl(i).old_association_id;

                                write_debug('ego_pages_bulkload_pvt.'||lv_proc||' - '||'Smt 2');

                                IF (p_ent_tbl(i).sequence IS NULL or p_ent_tbl(i).sequence = G_NULL_NUM) THEN
                                	p_ent_tbl(i).sequence := lv_sequence;
                                END IF;
                        EXCEPTION
                        	WHEN OTHERS THEN
                        		x_return_status := G_RET_STS_UNEXP_ERROR;

                                write_debug('ego_pages_bulkload_pvt.'||lv_proc||' - '||'handle_null_pg_entries exception when others smt 1');

                                x_return_msg := 'ego_pages_bulkload_pvt.handle_null_pg_entries - '||SQLERRM;

                                RETURN;
                        END;
                END IF;
        END LOOP;
        write_debug('ego_pages_bulkload_pvt.'||lv_proc||' - '||'Exit handle_null_pg_entries');
   EXCEPTION
   	WHEN OTHERS THEN
   		write_debug('ego_pages_bulkload_pvt.'||lv_proc||' - '||'handle_null_pg_entries Exception when others'||SQLERRM);
   END handle_null_pg_entries;

  /*This procedure will log debug messages
    x_msg IN Input message name*/
  Procedure write_debug(x_msg IN VARCHAR2)
  IS
  BEGIN
  	ego_metadata_bulkload_pvt.write_debug(x_msg);
  	--debug_proc(x_msg);
  EXCEPTION
  	WHEN OTHERS THEN
  		NULL;
  END write_debug;
END ego_pages_bulkload_pvt;

/
