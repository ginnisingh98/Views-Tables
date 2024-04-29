--------------------------------------------------------
--  DDL for Package Body EGO_AG_BULKLOAD_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EGO_AG_BULKLOAD_PVT" AS
  /* $Header: EGOVAGBB.pls 120.0.12010000.13 2010/06/03 10:39:39 jiabraha noship $ */

  /*This Procedure is used to initialize certain column values in the interface table.
    Used in the interface flow.
  	x_return_status OUT NOCOPY parameter that returns the status*/
  PROCEDURE Initialize
       (x_return_status OUT NOCOPY VARCHAR2, x_return_msg OUT NOCOPY VARCHAR2)
  IS
    lv_smt  NUMBER; --Statement counter

    lv_proc VARCHAR2(30) := 'Initialize';
  BEGIN
    write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Entered Initialize procedure');

    x_return_status := G_RET_STS_SUCCESS;

    lv_smt := 1;

    write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Statement 1');

    /*Sets the EGO application ID*/
    SELECT application_id
    INTO   g_ego_application_id
    FROM   fnd_application
    WHERE  application_short_name = 'EGO';

    lv_smt := 2;

    write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Statement 2');

    /*Sets the Transaction_id and upper case the transaction_type*/
    UPDATE ego_attr_groups_interface
    SET    transaction_id = mtl_system_items_interface_s.nextval,
           transaction_type = Upper(transaction_type),
           application_id = g_ego_application_id,
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
           AND ((G_SET_PROCESS_ID IS NULL)
                 OR (set_process_id = G_SET_PROCESS_ID));

    SELECT COUNT(1) INTO G_AG_COUNT
    FROM  ego_attr_groups_interface
    WHERE process_status = G_PROCESS_RECORD
           AND ((G_SET_PROCESS_ID IS NULL)
                 OR (set_process_id = G_SET_PROCESS_ID));

    lv_smt := 3;

    write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Statement 3');

    UPDATE ego_attr_groups_dl_interface
    SET    transaction_id = mtl_system_items_interface_s.nextval,
           transaction_type = Upper(transaction_type),
           application_id = g_ego_application_id,
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
           AND ((G_SET_PROCESS_ID IS NULL)
                 OR (set_process_id = G_SET_PROCESS_ID));

	SELECT COUNT(1) INTO G_DL_COUNT
    FROM  ego_attr_groups_dl_interface
    WHERE process_status = G_PROCESS_RECORD
           AND ((G_SET_PROCESS_ID IS NULL)
                 OR (set_process_id = G_SET_PROCESS_ID));

    lv_smt := 4;

    write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Statement 4');

    UPDATE ego_attr_group_cols_intf
    SET    transaction_id = mtl_system_items_interface_s.nextval,
           transaction_type = Upper(transaction_type),
           application_id = g_ego_application_id,
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
           AND ((G_SET_PROCESS_ID IS NULL)
                 OR (set_process_id = G_SET_PROCESS_ID));

	SELECT COUNT(1) INTO G_ATTR_COUNT
    FROM  ego_attr_group_cols_intf
    WHERE process_status = G_PROCESS_RECORD
           AND ((G_SET_PROCESS_ID IS NULL)
                 OR (set_process_id = G_SET_PROCESS_ID));

    write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Exit Initialize procedure');
  EXCEPTION
    WHEN OTHERS THEN
      write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Initialize - Exception when others'||SQLERRM);

      x_return_status := G_RET_STS_UNEXP_ERROR;

      x_return_msg := 'ego_ag_bulkload_pvt.initialize - '||SQLERRM;

      RETURN;
  END initialize;

  /*This procedure is used to validate the transaction type for all the interface tables.
  	Used in the interface flow.
  	x_return_status OUT NOCOPY parameter that returns the status*/
  PROCEDURE Validate_transaction_type
       (x_return_status OUT NOCOPY VARCHAR2, x_return_msg OUT NOCOPY VARCHAR2)
  IS
    lv_smt  NUMBER; --Statement counter

    lv_proc VARCHAR2(30) := 'Validate_transaction_type';
  BEGIN
    write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Entered Validate_transaction_type');

    x_return_status := G_RET_STS_SUCCESS;

    /* Update the interface records with process_status 3 and insert into
MTL_INTERFACE_ERRORS if TRANSACTION_TYPE passed is incorrect*/
    G_MESSAGE_NAME := 'EGO_TRANS_TYPE_INVALID';

    fnd_message.Set_name('EGO','EGO_TRANS_TYPE_INVALID');

    G_MESSAGE_TEXT := fnd_message.get;

    lv_smt := 1;

    write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Statement 1');

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
           G_ENTITY_AG_TAB,
           G_BO_IDENTIFIER_AG,
           G_ENTITY_AG,
           G_MESSAGE_NAME,
           G_MESSAGE_TEXT,
           Nvl(last_update_date,SYSDATE),
           Nvl(last_updated_by,G_USER_ID),
           Nvl(creation_date,SYSDATE),
           Nvl(created_by,G_USER_ID),
           Nvl(last_update_login,G_USER_ID),
           G_REQUEST_ID,
           Nvl(program_application_id,G_PROG_APPL_ID),
           Nvl(program_id,G_PROGRAM_ID),
           Nvl(program_update_date,SYSDATE)
    FROM   ego_attr_groups_interface
    WHERE  (transaction_type IS NULL
    	   OR transaction_type NOT IN (G_OPR_CREATE,G_OPR_UPDATE,G_OPR_DELETE,G_OPR_SYNC))
           AND transaction_id IS NOT NULL
           AND process_status = G_PROCESS_RECORD
           AND ((G_SET_PROCESS_ID IS NULL)
                 OR (set_process_id = G_SET_PROCESS_ID));

    UPDATE ego_attr_groups_interface
    SET    process_status = G_ERROR_RECORD,
           last_updated_by = G_USER_ID,
           last_update_date = SYSDATE,
           last_update_login = G_LOGIN_ID
    WHERE  (transaction_type IS NULL
    	   OR transaction_type NOT IN (G_OPR_CREATE,G_OPR_UPDATE,G_OPR_DELETE,G_OPR_SYNC))
           AND transaction_id IS NOT NULL
           AND process_status = G_PROCESS_RECORD
           AND ((G_SET_PROCESS_ID IS NULL)
                 OR (set_process_id = G_SET_PROCESS_ID));

    lv_smt := 2;

    write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Statement 2');

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
           G_ENTITY_DL_TAB,
           G_BO_IDENTIFIER_AG,
           G_ENTITY_DL,
           G_MESSAGE_NAME,
           G_MESSAGE_TEXT,
           Nvl(last_update_date,SYSDATE),
           Nvl(last_updated_by,G_USER_ID),
           Nvl(creation_date,SYSDATE),
           Nvl(created_by,G_USER_ID),
           Nvl(last_update_login,G_USER_ID),
           G_REQUEST_ID,
           Nvl(program_application_id,G_PROG_APPL_ID),
           Nvl(program_id,G_PROGRAM_ID),
           Nvl(program_update_date,SYSDATE)
    FROM   ego_attr_groups_dl_interface
    WHERE  (transaction_type IS NULL
    	   OR transaction_type NOT IN (G_OPR_CREATE,G_OPR_UPDATE,G_OPR_DELETE,G_OPR_SYNC))
           AND transaction_id IS NOT NULL
           AND process_status = G_PROCESS_RECORD
           AND ((G_SET_PROCESS_ID IS NULL)
                 OR (set_process_id = G_SET_PROCESS_ID));

    UPDATE ego_attr_groups_dl_interface
    SET    process_status = G_ERROR_RECORD,
           last_updated_by = G_USER_ID,
           last_update_date = SYSDATE,
           last_update_login = G_LOGIN_ID
    WHERE  (transaction_type IS NULL
    	   OR transaction_type NOT IN (G_OPR_CREATE,G_OPR_UPDATE,G_OPR_DELETE,G_OPR_SYNC))
           AND transaction_id IS NOT NULL
           AND process_status = G_PROCESS_RECORD
           AND ((G_SET_PROCESS_ID IS NULL)
                 OR (set_process_id = G_SET_PROCESS_ID));

    lv_smt := 3;

    write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Statement 3');

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
           G_ENTITY_ATTR_TAB,
           G_BO_IDENTIFIER_AG,
           G_ENTITY_ATTR,
           G_MESSAGE_NAME,
           G_MESSAGE_TEXT,
           Nvl(last_update_date,SYSDATE),
           Nvl(last_updated_by,G_USER_ID),
           Nvl(creation_date,SYSDATE),
           Nvl(created_by,G_USER_ID),
           Nvl(last_update_login,G_USER_ID),
           G_REQUEST_ID,
           Nvl(program_application_id,G_PROG_APPL_ID),
           Nvl(program_id,G_PROGRAM_ID),
           Nvl(program_update_date,SYSDATE)
    FROM   ego_attr_group_cols_intf
    WHERE  (transaction_type IS NULL
    	   OR transaction_type NOT IN (G_OPR_CREATE,G_OPR_UPDATE,G_OPR_DELETE,G_OPR_SYNC))
           AND transaction_id IS NOT NULL
           AND process_status = G_PROCESS_RECORD
           AND ((G_SET_PROCESS_ID IS NULL)
                 OR (set_process_id = G_SET_PROCESS_ID));

    UPDATE ego_attr_group_cols_intf
    SET    process_status = G_ERROR_RECORD,
           last_updated_by = G_USER_ID,
           last_update_date = SYSDATE,
           last_update_login = G_LOGIN_ID
    WHERE  (transaction_type IS NULL
    	   OR transaction_type NOT IN (G_OPR_CREATE,G_OPR_UPDATE,G_OPR_DELETE,G_OPR_SYNC))
           AND transaction_id IS NOT NULL
           AND process_status = G_PROCESS_RECORD
           AND ((G_SET_PROCESS_ID IS NULL)
                 OR (set_process_id = G_SET_PROCESS_ID));

    write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Exit Validatetransactiontype');
  EXCEPTION
    WHEN OTHERS THEN
      write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Validate_transaction_type Exception when others'||SQLERRM);

      x_return_status := G_RET_STS_UNEXP_ERROR;

      x_return_msg := 'ego_ag_bulkload_pvt.Validate_transaction_type - '||SQLERRM;

      RETURN;
  END Validate_transaction_type;

  /*This procedure is used to bulk validate attribute groups.
  	Used in the interface flow.
  	x_return_status OUT NOCOPY parameter that returns the status*/
  PROCEDURE bulk_validate_attr_groups
       (x_return_status OUT NOCOPY VARCHAR2, x_return_msg OUT NOCOPY VARCHAR2)
  IS
    lv_smt  NUMBER; --Statement counter

    lv_proc VARCHAR2(30) := 'bulk_validate_attr_groups';
  BEGIN
    write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Entered bulk_validate_attr_groups');

    x_return_status := G_RET_STS_SUCCESS;

    Value_to_id_ag(x_return_status, x_return_msg); IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN RETURN; END IF;

    Value_to_id_dl(x_return_status, x_return_msg); IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN RETURN; END IF;

    construct_attr_groups(x_return_status, x_return_msg); IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN RETURN; END IF;

    construct_ag_data_level(x_return_status, x_return_msg); IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN RETURN; END IF;

    lv_smt := 1;

    write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Statement 1');

    /* Update the interface records with process_status 3 and insert into
MTL_INTERFACE_ERRORS if internal name or the display name for AG is not
provided in the CREATE flow*/
    G_MESSAGE_NAME := 'EGO_AG_MANDATORY';

    fnd_message.Set_name('EGO','EGO_AG_MANDATORY');

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
    SELECT eagi.transaction_id,
           mtl_system_items_interface_s.nextval,
           NULL,
           NULL,
           G_ENTITY_AG_TAB,
           G_BO_IDENTIFIER_AG,
           G_ENTITY_AG,
           G_MESSAGE_NAME,
           G_MESSAGE_TEXT,
           Nvl(last_update_date,SYSDATE),
           Nvl(last_updated_by,G_USER_ID),
           Nvl(creation_date,SYSDATE),
           Nvl(created_by,G_USER_ID),
           Nvl(last_update_login,G_USER_ID),
           G_REQUEST_ID,
           Nvl(program_application_id,G_PROG_APPL_ID),
           Nvl(program_id,G_PROGRAM_ID),
           Nvl(program_update_date,SYSDATE)
    FROM   ego_attr_groups_interface eagi
    WHERE  (attr_group_name IS NULL
             OR attr_group_disp_name IS NULL)
           AND transaction_id IS NOT NULL
           AND transaction_type = G_OPR_CREATE
           AND process_status = G_PROCESS_RECORD
           AND ((G_SET_PROCESS_ID IS NULL)
                 OR (set_process_id = G_SET_PROCESS_ID));

    UPDATE ego_attr_groups_interface
    SET    process_status = G_ERROR_RECORD,
           last_updated_by = G_USER_ID,
           last_update_date = SYSDATE,
           last_update_login = G_LOGIN_ID
    WHERE  (attr_group_name IS NULL
             OR attr_group_disp_name IS NULL)
           AND transaction_id IS NOT NULL
           AND transaction_type = G_OPR_CREATE
           AND process_status = G_PROCESS_RECORD
           AND ((G_SET_PROCESS_ID IS NULL)
                 OR (set_process_id = G_SET_PROCESS_ID));

    lv_smt := 9;

    write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Statement 9');

    /* Update the interface records with process_status 3 and insert into
MTL_INTERFACE_ERRORS if Attribute Group Type in the AG interface table is other than EGO_ITEMMGMT_GROUP*/
    G_MESSAGE_NAME := 'EGO_AG_TYPE_INVALID';

    fnd_message.Set_name('EGO','EGO_AG_TYPE_INVALID');

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
    SELECT eagi.transaction_id,
           mtl_system_items_interface_s.nextval,
           NULL,
           NULL,
           G_ENTITY_AG_TAB,
           G_BO_IDENTIFIER_AG,
           G_ENTITY_ATTR,
           G_MESSAGE_NAME,
           G_MESSAGE_TEXT,
           Nvl(last_update_date,SYSDATE),
           Nvl(last_updated_by,G_USER_ID),
           Nvl(creation_date,SYSDATE),
           Nvl(created_by,G_USER_ID),
           Nvl(last_update_login,G_USER_ID),
           G_REQUEST_ID,
           Nvl(program_application_id,G_PROG_APPL_ID),
           Nvl(program_id,G_PROGRAM_ID),
           Nvl(program_update_date,SYSDATE)
    FROM   ego_attr_groups_interface eagi
    WHERE  attr_group_type <> G_EGO_ITEMMGMT_GROUP
           AND transaction_id IS NOT NULL
           AND process_status = G_PROCESS_RECORD
           AND ((G_SET_PROCESS_ID IS NULL)
                 OR (set_process_id = G_SET_PROCESS_ID));

    UPDATE ego_attr_groups_interface
    SET    process_status = G_ERROR_RECORD,
           last_updated_by = G_USER_ID,
           last_update_date = SYSDATE,
           last_update_login = G_LOGIN_ID
    WHERE  attr_group_type <> G_EGO_ITEMMGMT_GROUP
           AND transaction_id IS NOT NULL
           AND process_status = G_PROCESS_RECORD
           AND ((G_SET_PROCESS_ID IS NULL)
                 OR (set_process_id = G_SET_PROCESS_ID));

    lv_smt := 10;

    write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Statement 10');

    /* Update the interface records with process_status 3 and insert into
MTL_INTERFACE_ERRORS if Attribute Group Type in the DL interface is other than EGO_ITEMMGMT_GROUP*/
    G_MESSAGE_NAME := 'EGO_AG_TYPE_INVALID';

    fnd_message.Set_name('EGO','EGO_AG_TYPE_INVALID');

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
    SELECT eagi.transaction_id,
           mtl_system_items_interface_s.nextval,
           NULL,
           NULL,
           G_ENTITY_DL_TAB,
           G_BO_IDENTIFIER_AG,
           G_ENTITY_DL,
           G_MESSAGE_NAME,
           G_MESSAGE_TEXT,
           Nvl(last_update_date,SYSDATE),
           Nvl(last_updated_by,G_USER_ID),
           Nvl(creation_date,SYSDATE),
           Nvl(created_by,G_USER_ID),
           Nvl(last_update_login,G_USER_ID),
           G_REQUEST_ID,
           Nvl(program_application_id,G_PROG_APPL_ID),
           Nvl(program_id,G_PROGRAM_ID),
           Nvl(program_update_date,SYSDATE)
    FROM   ego_attr_groups_dl_interface eagi
    WHERE  attr_group_type <> G_EGO_ITEMMGMT_GROUP
           AND transaction_id IS NOT NULL
           AND process_status = G_PROCESS_RECORD
           AND ((G_SET_PROCESS_ID IS NULL)
                 OR (set_process_id = G_SET_PROCESS_ID));

    UPDATE ego_attr_groups_dl_interface
    SET    process_status = G_ERROR_RECORD,
           last_updated_by = G_USER_ID,
           last_update_date = SYSDATE,
           last_update_login = G_LOGIN_ID
    WHERE  attr_group_type <> G_EGO_ITEMMGMT_GROUP
           AND transaction_id IS NOT NULL
           AND process_status = G_PROCESS_RECORD
           AND ((G_SET_PROCESS_ID IS NULL)
                 OR (set_process_id = G_SET_PROCESS_ID));

    lv_smt := 2; --Added for 9625957

    write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Statement 2');

    /* Update the interface records with process_status 3 and insert into
MTL_INTERFACE_ERRORS if Attribute Group Type in the DL interface is other than EGO_ITEMMGMT_GROUP*/
    G_MESSAGE_NAME := 'EGO_DL_MANDATORY';

    fnd_message.Set_name('EGO','EGO_DL_MANDATORY');

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
    SELECT eagi.transaction_id,
           mtl_system_items_interface_s.nextval,
           NULL,
           NULL,
           G_ENTITY_DL_TAB,
           G_BO_IDENTIFIER_AG,
           G_ENTITY_DL,
           G_MESSAGE_NAME,
           G_MESSAGE_TEXT,
           Nvl(last_update_date,SYSDATE),
           Nvl(last_updated_by,G_USER_ID),
           Nvl(creation_date,SYSDATE),
           Nvl(created_by,G_USER_ID),
           Nvl(last_update_login,G_USER_ID),
           G_REQUEST_ID,
           Nvl(program_application_id,G_PROG_APPL_ID),
           Nvl(program_id,G_PROGRAM_ID),
           Nvl(program_update_date,SYSDATE)
    FROM   ego_attr_groups_dl_interface eagi
    WHERE  (attr_group_type IS NULL
    		OR attr_group_name IS NULL
    		OR data_level_name IS NULL)
    	   AND transaction_id IS NOT NULL
           AND process_status = G_PROCESS_RECORD
           AND ((G_SET_PROCESS_ID IS NULL)
                 OR (set_process_id = G_SET_PROCESS_ID));

    UPDATE ego_attr_groups_dl_interface
    SET    process_status = G_ERROR_RECORD,
           last_updated_by = G_USER_ID,
           last_update_date = SYSDATE,
           last_update_login = G_LOGIN_ID
    WHERE  (attr_group_type IS NULL
    		OR attr_group_name IS NULL
    		OR data_level_name IS NULL)
    	   AND transaction_id IS NOT NULL
           AND process_status = G_PROCESS_RECORD
           AND ((G_SET_PROCESS_ID IS NULL)
                 OR (set_process_id = G_SET_PROCESS_ID));


    lv_smt := 2.1;

    write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Statement 2.1');

    /* Update the interface records with process_status 3 and insert into
MTL_INTERFACE_ERRORS if internal name is not existing in the UPDATE flow.
Updates the AG interface table*/
    G_MESSAGE_NAME := 'EGO_AG_NOT_EXIST';

    fnd_message.Set_name('EGO','EGO_AG_NOT_EXIST');

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
    SELECT eagi.transaction_id,
           mtl_system_items_interface_s.nextval,
           NULL,
           NULL,
           G_ENTITY_AG_TAB,
           G_BO_IDENTIFIER_AG,
           G_ENTITY_AG,
           G_MESSAGE_NAME,
           G_MESSAGE_TEXT,
           Nvl(last_update_date,SYSDATE),
           Nvl(last_updated_by,G_USER_ID),
           Nvl(creation_date,SYSDATE),
           Nvl(created_by,G_USER_ID),
           Nvl(last_update_login,G_USER_ID),
           G_REQUEST_ID,
           Nvl(program_application_id,G_PROG_APPL_ID),
           Nvl(program_id,G_PROGRAM_ID),
           Nvl(program_update_date,SYSDATE)
    FROM   ego_attr_groups_interface eagi
    WHERE  (attr_group_id IS NULL
             OR attr_group_name IS NULL)
           AND transaction_id IS NOT NULL
           AND transaction_type IN (G_OPR_UPDATE,G_OPR_DELETE)
           AND process_status = G_PROCESS_RECORD
           AND ((G_SET_PROCESS_ID IS NULL)
                 OR (set_process_id = G_SET_PROCESS_ID));

    UPDATE ego_attr_groups_interface
    SET    process_status = G_ERROR_RECORD,
           last_updated_by = G_USER_ID,
           last_update_date = SYSDATE,
           last_update_login = G_LOGIN_ID
    WHERE  (attr_group_id IS NULL
             OR attr_group_name IS NULL)
           AND transaction_id IS NOT NULL
           AND transaction_type IN (G_OPR_UPDATE,G_OPR_DELETE)
           AND process_status = G_PROCESS_RECORD
           AND ((G_SET_PROCESS_ID IS NULL)
                 OR (set_process_id = G_SET_PROCESS_ID));

    lv_smt := 3;

    write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Statement 3');

    /* Update the interface records with process_status 3 and insert into
MTL_INTERFACE_ERRORS if internal name is not existing. Updates the DL
interface table*/
    G_MESSAGE_NAME := 'EGO_AG_NOT_EXIST';

    fnd_message.Set_name('EGO','EGO_AG_NOT_EXIST');

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
    SELECT eagdi.transaction_id,
           mtl_system_items_interface_s.nextval,
           NULL,
           NULL,
           G_ENTITY_DL_TAB,
           G_BO_IDENTIFIER_AG,
           G_ENTITY_DL,
           G_MESSAGE_NAME,
           G_MESSAGE_TEXT,
           Nvl(last_update_date,SYSDATE),
           Nvl(last_updated_by,G_USER_ID),
           Nvl(creation_date,SYSDATE),
           Nvl(created_by,G_USER_ID),
           Nvl(last_update_login,G_USER_ID),
           G_REQUEST_ID,
           Nvl(program_application_id,G_PROG_APPL_ID),
           Nvl(program_id,G_PROGRAM_ID),
           Nvl(program_update_date,SYSDATE)
    FROM   ego_attr_groups_dl_interface eagdi
    WHERE  (eagdi.attr_group_id IS NULL
             OR eagdi.attr_group_name IS NULL)
           AND eagdi.transaction_id IS NOT NULL
           AND NOT EXISTS (SELECT 1
                           FROM   ego_attr_groups_interface eagi
                           WHERE  eagi.attr_group_name = eagdi.attr_group_name
                                  AND eagi.transaction_type = G_OPR_CREATE
                                  AND eagi.process_status = G_PROCESS_RECORD)
           AND eagdi.process_status = G_PROCESS_RECORD
           AND ((G_SET_PROCESS_ID IS NULL)
                 OR (set_process_id = G_SET_PROCESS_ID));

    UPDATE ego_attr_groups_dl_interface eagdi
    SET    eagdi.process_status = G_ERROR_RECORD,
           last_updated_by = G_USER_ID,
           last_update_date = SYSDATE,
           last_update_login = G_LOGIN_ID
    WHERE  (eagdi.attr_group_id IS NULL
             OR eagdi.attr_group_name IS NULL)
           AND eagdi.transaction_id IS NOT NULL
           AND NOT EXISTS (SELECT 1
                           FROM   ego_attr_groups_interface eagi
                           WHERE  eagi.attr_group_name = eagdi.attr_group_name
                                  AND eagi.transaction_type = G_OPR_CREATE
                                  AND eagi.process_status = G_PROCESS_RECORD)
           AND eagdi.process_status = G_PROCESS_RECORD
           AND ((G_SET_PROCESS_ID IS NULL)
                 OR (set_process_id = G_SET_PROCESS_ID));

    lv_smt := 4;

    write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Statement 4');

    /* Update the interface records with process_status 3 and insert into
MTL_INTERFACE_ERRORS if for the CREATE flow if there already exists an AG with
the same internal attribute group name*/

    G_MESSAGE_NAME := 'EGO_EF_ATTR_GRP_EXIST';

    fnd_message.Set_name('EGO','EGO_EF_ATTR_GRP_EXIST');

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
    SELECT eagi.transaction_id,
           mtl_system_items_interface_s.nextval,
           NULL,
           NULL,
           G_ENTITY_AG_TAB,
           G_BO_IDENTIFIER_AG,
           G_ENTITY_AG,
           G_MESSAGE_NAME,
           G_MESSAGE_TEXT,
           Nvl(last_update_date,SYSDATE),
           Nvl(last_updated_by,G_USER_ID),
           Nvl(creation_date,SYSDATE),
           Nvl(created_by,G_USER_ID),
           Nvl(last_update_login,G_USER_ID),
           G_REQUEST_ID,
           Nvl(program_application_id,G_PROG_APPL_ID),
           Nvl(program_id,G_PROGRAM_ID),
           Nvl(program_update_date,SYSDATE)
    FROM   ego_attr_groups_interface eagi
    WHERE  EXISTS (SELECT 1
                   FROM   EGO_FND_DSC_FLX_CTX_EXT efdfce
                   WHERE  efdfce.DESCRIPTIVE_FLEX_CONTEXT_CODE = eagi.attr_group_name
                   AND efdfce.DESCRIPTIVE_FLEXFIELD_NAME = G_EGO_ITEMMGMT_GROUP
                   AND efdfce.APPLICATION_ID = G_EGO_APPLICATION_ID)
           AND eagi.transaction_id IS NOT NULL
           AND eagi.transaction_type = G_OPR_CREATE
           AND eagi.process_status = G_PROCESS_RECORD
           AND ((G_SET_PROCESS_ID IS NULL)
                 OR (set_process_id = G_SET_PROCESS_ID));

    UPDATE ego_attr_groups_interface eagi
    SET    eagi.process_status = G_ERROR_RECORD,
           last_updated_by = G_USER_ID,
           last_update_date = SYSDATE,
           last_update_login = G_LOGIN_ID
    WHERE  EXISTS (SELECT 1
                   FROM   EGO_FND_DSC_FLX_CTX_EXT efdfce
                   WHERE  efdfce.DESCRIPTIVE_FLEX_CONTEXT_CODE = eagi.attr_group_name
                   AND efdfce.DESCRIPTIVE_FLEXFIELD_NAME = G_EGO_ITEMMGMT_GROUP
                   AND efdfce.APPLICATION_ID = G_EGO_APPLICATION_ID)
           AND eagi.transaction_id IS NOT NULL
           AND eagi.transaction_type = G_OPR_CREATE
           AND eagi.process_status = G_PROCESS_RECORD
           AND ((G_SET_PROCESS_ID IS NULL)
                 OR (set_process_id = G_SET_PROCESS_ID));


    lv_smt := 4.1;

    write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Statement 4.1');

    /* Update the interface records with process_status 3 and insert into
MTL_INTERFACE_ERRORS if for the CREATE flow if there doesn't exist any DL
in the interface table*/
    G_MESSAGE_NAME := 'EGO_EF_DL_REQD_AG';

    fnd_message.Set_name('EGO','EGO_EF_DL_REQD_AG');

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
    SELECT eagi.transaction_id,
           mtl_system_items_interface_s.nextval,
           NULL,
           NULL,
           G_ENTITY_AG_TAB,
           G_BO_IDENTIFIER_AG,
           G_ENTITY_AG,
           G_MESSAGE_NAME,
           G_MESSAGE_TEXT,
           Nvl(last_update_date,SYSDATE),
           Nvl(last_updated_by,G_USER_ID),
           Nvl(creation_date,SYSDATE),
           Nvl(created_by,G_USER_ID),
           Nvl(last_update_login,G_USER_ID),
           G_REQUEST_ID,
           Nvl(program_application_id,G_PROG_APPL_ID),
           Nvl(program_id,G_PROGRAM_ID),
           Nvl(program_update_date,SYSDATE)
    FROM   ego_attr_groups_interface eagi
    WHERE  NOT EXISTS (SELECT 1
                       FROM   ego_attr_groups_dl_interface eagdi
                       WHERE  eagdi.attr_group_name = eagi.attr_group_name
                              AND eagdi.transaction_type = eagi.transaction_type
                              AND eagdi.process_status = G_PROCESS_RECORD
                              AND ((G_SET_PROCESS_ID IS NULL)
                                    OR (set_process_id = G_SET_PROCESS_ID)))
           AND eagi.transaction_id IS NOT NULL
           AND eagi.transaction_type = G_OPR_CREATE
           AND eagi.process_status = G_PROCESS_RECORD
           AND ((G_SET_PROCESS_ID IS NULL)
                 OR (set_process_id = G_SET_PROCESS_ID));

    UPDATE ego_attr_groups_interface eagi
    SET    eagi.process_status = G_ERROR_RECORD,
           last_updated_by = G_USER_ID,
           last_update_date = SYSDATE,
           last_update_login = G_LOGIN_ID
    WHERE  NOT EXISTS (SELECT 1
                       FROM   ego_attr_groups_dl_interface eagdi
                       WHERE  eagdi.attr_group_name = eagi.attr_group_name
                              AND eagdi.transaction_type = eagi.transaction_type
                              AND eagdi.process_status = G_PROCESS_RECORD
                              AND ((G_SET_PROCESS_ID IS NULL)
                                    OR (set_process_id = G_SET_PROCESS_ID)))
           AND eagi.transaction_id IS NOT NULL
           AND eagi.transaction_type = G_OPR_CREATE
           AND eagi.process_status = G_PROCESS_RECORD
           AND ((G_SET_PROCESS_ID IS NULL)
                 OR (set_process_id = G_SET_PROCESS_ID));

    lv_smt := 4.2;

    write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Statement 4.2');

    /* Update the interface records with process_status 3 and insert into
MTL_INTERFACE_ERRORS if Data Level passed is already enabled in the system*/
    G_MESSAGE_NAME := 'EGO_EF_DL_AG_EXISTS';

    fnd_message.Set_name('EGO','EGO_EF_DL_AG_EXISTS');

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
    SELECT eagi.transaction_id,
           mtl_system_items_interface_s.nextval,
           NULL,
           NULL,
           G_ENTITY_DL_TAB,
           G_BO_IDENTIFIER_AG,
           G_ENTITY_DL,
           G_MESSAGE_NAME,
           G_MESSAGE_TEXT,
           Nvl(last_update_date,SYSDATE),
           Nvl(last_updated_by,G_USER_ID),
           Nvl(creation_date,SYSDATE),
           Nvl(created_by,G_USER_ID),
           Nvl(last_update_login,G_USER_ID),
           G_REQUEST_ID,
           Nvl(program_application_id,G_PROG_APPL_ID),
           Nvl(program_id,G_PROGRAM_ID),
           Nvl(program_update_date,SYSDATE)
    FROM   ego_attr_groups_dl_interface eagi
    WHERE  EXISTS 	  (SELECT 1
                       FROM   EGO_ATTR_GROUP_DL eagdl
                       WHERE  eagdl.attr_group_id = eagi.attr_group_id
                       AND eagdl.data_level_id = (SELECT data_level_id FROM ego_data_level_b
												  WHERE data_level_name=eagi.data_level_name
												  AND attr_group_type = G_EGO_ITEMMGMT_GROUP
												  AND application_id = G_EGO_APPLICATION_ID
												  ))
           AND eagi.transaction_id IS NOT NULL
           AND eagi.transaction_type = G_OPR_CREATE
           AND eagi.process_status = G_PROCESS_RECORD
           AND ((G_SET_PROCESS_ID IS NULL)
                 OR (set_process_id = G_SET_PROCESS_ID));

    UPDATE ego_attr_groups_dl_interface eagi
    SET    eagi.process_status = G_ERROR_RECORD,
           last_updated_by = G_USER_ID,
           last_update_date = SYSDATE,
           last_update_login = G_LOGIN_ID
    WHERE  EXISTS 	  (SELECT 1
                       FROM   EGO_ATTR_GROUP_DL eagdl
                       WHERE  eagdl.attr_group_id = eagi.attr_group_id
                       AND eagdl.data_level_id = (SELECT data_level_id FROM ego_data_level_b
												  WHERE data_level_name=eagi.data_level_name
												  AND attr_group_type = G_EGO_ITEMMGMT_GROUP
												  AND application_id = G_EGO_APPLICATION_ID
												  ))
           AND eagi.transaction_id IS NOT NULL
           AND eagi.transaction_type = G_OPR_CREATE
           AND eagi.process_status = G_PROCESS_RECORD
           AND ((G_SET_PROCESS_ID IS NULL)
                 OR (set_process_id = G_SET_PROCESS_ID));

    lv_smt := 5;

    write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Statement 5');

    /* Update the interface records with process_status 3 and insert into
MTL_INTERFACE_ERRORS if Data Level passed is incorrect*/
    G_MESSAGE_NAME := 'EGO_DL_NOT_EXIST';

    fnd_message.Set_name('EGO','EGO_DL_NOT_EXIST');

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
           G_ENTITY_DL_TAB,
           G_BO_IDENTIFIER_AG,
           G_ENTITY_DL,
           G_MESSAGE_NAME,
           G_MESSAGE_TEXT,
           Nvl(last_update_date,SYSDATE),
           Nvl(last_updated_by,G_USER_ID),
           Nvl(creation_date,SYSDATE),
           Nvl(created_by,G_USER_ID),
           Nvl(last_update_login,G_USER_ID),
           G_REQUEST_ID,
           Nvl(program_application_id,G_PROG_APPL_ID),
           Nvl(program_id,G_PROGRAM_ID),
           Nvl(program_update_date,SYSDATE)
    FROM   ego_attr_groups_dl_interface
    WHERE  (data_level_id IS NULL
             OR data_level_name IS NULL)
           AND transaction_id IS NOT NULL
           AND process_status = G_PROCESS_RECORD
           AND ((G_SET_PROCESS_ID IS NULL)
                 OR (set_process_id = G_SET_PROCESS_ID));

    UPDATE ego_attr_groups_dl_interface
    SET    process_status = G_ERROR_RECORD,
           last_updated_by = G_USER_ID,
           last_update_date = SYSDATE,
           last_update_login = G_LOGIN_ID
    WHERE  (data_level_id IS NULL
             OR data_level_name IS NULL)
           AND transaction_id IS NOT NULL
           AND process_status = G_PROCESS_RECORD
           AND ((G_SET_PROCESS_ID IS NULL)
                 OR (set_process_id = G_SET_PROCESS_ID));

    lv_smt := 6;

    write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Statement 6');

    /* Update the interface records with process_status 3 and insert into
MTL_INTERFACE_ERRORS if the AG is of type Variant and Business entity is not ITEM or the Style to SKU is not NULL*/
    G_MESSAGE_NAME := 'EGO_VAR_DL_SKU';

    fnd_message.Set_name('EGO','EGO_VAR_DL_SKU');

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
    SELECT eagdi.transaction_id,
           mtl_system_items_interface_s.nextval,
           NULL,
           NULL,
           G_ENTITY_DL_TAB,
           G_BO_IDENTIFIER_AG,
           G_ENTITY_DL,
           G_MESSAGE_NAME,
           G_MESSAGE_TEXT,
           Nvl(last_update_date,SYSDATE),
           Nvl(last_updated_by,G_USER_ID),
           Nvl(creation_date,SYSDATE),
           Nvl(created_by,G_USER_ID),
           Nvl(last_update_login,G_USER_ID),
           G_REQUEST_ID,
           Nvl(program_application_id,G_PROG_APPL_ID),
           Nvl(program_id,G_PROGRAM_ID),
           Nvl(program_update_date,SYSDATE)
    FROM   ego_attr_groups_dl_interface eagdi
    WHERE  EXISTS (SELECT 1
                   FROM   ego_fnd_dsc_flx_ctx_ext eagd
                   WHERE  eagd.attr_group_id = eagdi.attr_group_id
                          AND eagd.variant = 'Y'
                   /*Added for bug 9719196*/
                   UNION ALL
                   SELECT 1
                   FROM ego_attr_groups_interface
                   WHERE attr_group_name = eagdi.attr_group_name
                   AND transaction_type = G_OPR_CREATE
                   AND variant = 'Y'
                   AND process_status = G_PROCESS_RECORD
                   AND ((G_SET_PROCESS_ID IS NULL)
                 		 OR (set_process_id = G_SET_PROCESS_ID))
                   /*End of bug 9719196*/	 )
           AND (eagdi.data_level_name <> G_DL_ITEM_LEVEL
                 OR eagdi.defaulting IS NOT NULL)
           AND eagdi.transaction_id IS NOT NULL
           AND eagdi.process_status = G_PROCESS_RECORD
           AND ((G_SET_PROCESS_ID IS NULL)
                 OR (set_process_id = G_SET_PROCESS_ID));

    UPDATE ego_attr_groups_dl_interface eagdi
    SET    eagdi.process_status = G_ERROR_RECORD,
           last_updated_by = G_USER_ID,
           last_update_date = SYSDATE,
           last_update_login = G_LOGIN_ID
    WHERE  EXISTS (SELECT 1
                   FROM   ego_fnd_dsc_flx_ctx_ext eagd
                   WHERE  eagd.attr_group_id = eagdi.attr_group_id
                          AND eagd.variant = 'Y'
                   /*Added for bug 9719196*/
                   UNION ALL
                   SELECT 1
                   FROM ego_attr_groups_interface
                   WHERE attr_group_name = eagdi.attr_group_name
                   AND transaction_type = G_OPR_CREATE
                   AND variant = 'Y'
                   AND process_status = G_PROCESS_RECORD
                   AND ((G_SET_PROCESS_ID IS NULL)
                 		 OR (set_process_id = G_SET_PROCESS_ID))
                   /*End of bug 9719196*/	 )
           AND (eagdi.data_level_name <> G_DL_ITEM_LEVEL
                 OR eagdi.defaulting IS NOT NULL)
           AND eagdi.transaction_id IS NOT NULL
           AND eagdi.process_status = G_PROCESS_RECORD
           AND ((G_SET_PROCESS_ID IS NULL)
                 OR (set_process_id = G_SET_PROCESS_ID));

    lv_smt := 7;

    write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Statement 7');

    /* Update the interface records with process_status 3 and insert into
MTL_INTERFACE_ERRORS if AG is of Single Row or MultiRow Business and the business entity is not any of the below
ITEM_LEVEL, ITEM_REVISION_LEVEL, ITEM_ORG, ITEM_SUP, ITEM_SUP_SITE, ITEM_SUP_SITE_ORG*/
    G_MESSAGE_NAME := 'EGO_DL_NOT_EXIST';

    fnd_message.Set_name('EGO','EGO_DL_NOT_EXIST');

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
    SELECT eagdi.transaction_id,
           mtl_system_items_interface_s.nextval,
           NULL,
           NULL,
           G_ENTITY_AG_TAB,
           G_BO_IDENTIFIER_AG,
           G_ENTITY_AG,
           G_MESSAGE_NAME,
           G_MESSAGE_TEXT,
           Nvl(last_update_date,SYSDATE),
           Nvl(last_updated_by,G_USER_ID),
           Nvl(creation_date,SYSDATE),
           Nvl(created_by,G_USER_ID),
           Nvl(last_update_login,G_USER_ID),
           G_REQUEST_ID,
           Nvl(program_application_id,G_PROG_APPL_ID),
           Nvl(program_id,G_PROGRAM_ID),
           Nvl(program_update_date,SYSDATE)
    FROM   ego_attr_groups_dl_interface eagdi
    WHERE  EXISTS (SELECT 1
                   FROM   ego_fnd_dsc_flx_ctx_ext eagd
                   WHERE  eagd.attr_group_id = eagdi.attr_group_id
                          AND Nvl(eagd.variant,'N') = 'N')
           AND eagdi.data_level_name NOT IN (G_DL_ITEM_LEVEL,G_DL_ITEM_REV_LEVEL,G_DL_ITEM_ORG,G_DL_ITEM_SUP,
                                             G_DL_ITEM_SUP_SITE,G_DL_ITEM_SUP_SITE_ORG)
           AND eagdi.transaction_id IS NOT NULL
           AND eagdi.process_status = G_PROCESS_RECORD
           AND ((G_SET_PROCESS_ID IS NULL)
                 OR (set_process_id = G_SET_PROCESS_ID));

    UPDATE ego_attr_groups_dl_interface eagdi
    SET    eagdi.process_status = G_ERROR_RECORD,
           last_updated_by = G_USER_ID,
           last_update_date = SYSDATE,
           last_update_login = G_LOGIN_ID
    WHERE  EXISTS (SELECT 1
                   FROM   ego_fnd_dsc_flx_ctx_ext eagd
                   WHERE  eagd.attr_group_id = eagdi.attr_group_id
                          AND Nvl(eagd.variant,'N') = 'N')
           AND eagdi.data_level_name NOT IN (G_DL_ITEM_LEVEL,G_DL_ITEM_REV_LEVEL,G_DL_ITEM_ORG,G_DL_ITEM_SUP,
                                             G_DL_ITEM_SUP_SITE,G_DL_ITEM_SUP_SITE_ORG)
           AND eagdi.transaction_id IS NOT NULL
           AND eagdi.process_status = G_PROCESS_RECORD
           AND ((G_SET_PROCESS_ID IS NULL)
                 OR (set_process_id = G_SET_PROCESS_ID));

    lv_smt := 8;

    write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Statement 8');

    /* Update the interface records with process_status 3 and insert into
MTL_INTERFACE_ERRORS if AG is of Single Row or MultiRow Business flag an error if the business entity and the
Style to SKU combination is invalid*/
    G_MESSAGE_NAME := 'EGO_MULROW_SKU';

    fnd_message.Set_name('EGO','EGO_MULROW_SKU');

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
    SELECT eagdi.transaction_id,
           mtl_system_items_interface_s.nextval,
           NULL,
           NULL,
           G_ENTITY_DL_TAB,
           G_BO_IDENTIFIER_AG,
           G_ENTITY_DL,
           G_MESSAGE_NAME,
           G_MESSAGE_TEXT,
           Nvl(last_update_date,SYSDATE),
           Nvl(last_updated_by,G_USER_ID),
           Nvl(creation_date,SYSDATE),
           Nvl(created_by,G_USER_ID),
           Nvl(last_update_login,G_USER_ID),
           G_REQUEST_ID,
           Nvl(program_application_id,G_PROG_APPL_ID),
           Nvl(program_id,G_PROGRAM_ID),
           Nvl(program_update_date,SYSDATE)
    FROM   ego_attr_groups_dl_interface eagdi
    WHERE  EXISTS (SELECT 1
                   FROM   ego_fnd_dsc_flx_ctx_ext eagd
                   WHERE  eagd.attr_group_id = eagdi.attr_group_id
                          AND Nvl(eagd.variant,'N') = 'N')
           AND ((eagdi.data_level_name IN (G_DL_ITEM_LEVEL,G_DL_ITEM_REV_LEVEL,G_DL_ITEM_ORG,G_DL_ITEM_SUP,
                                           G_DL_ITEM_SUP_SITE,G_DL_ITEM_SUP_SITE_ORG)
                 AND eagdi.defaulting NOT    IN ('D','I'))
                 OR eagdi.data_level_name = G_DL_ITEM_REV_LEVEL
                    AND eagdi.defaulting IS NOT NULL)
           AND eagdi.transaction_id IS NOT NULL
           AND eagdi.process_status = G_PROCESS_RECORD
           AND ((G_SET_PROCESS_ID IS NULL)
                 OR (set_process_id = G_SET_PROCESS_ID));

    UPDATE ego_attr_groups_dl_interface eagdi
    SET    eagdi.process_status = G_ERROR_RECORD,
           last_updated_by = G_USER_ID,
           last_update_date = SYSDATE,
           last_update_login = G_LOGIN_ID
    WHERE  EXISTS (SELECT 1
                   FROM   ego_fnd_dsc_flx_ctx_ext eagd
                   WHERE  eagd.attr_group_id = eagdi.attr_group_id
                          AND Nvl(eagd.variant,'N') = 'N')
           AND ((eagdi.data_level_name IN (G_DL_ITEM_LEVEL,G_DL_ITEM_REV_LEVEL,G_DL_ITEM_ORG,G_DL_ITEM_SUP,
                                           G_DL_ITEM_SUP_SITE,G_DL_ITEM_SUP_SITE_ORG)
                 AND eagdi.defaulting NOT    IN ('D','I'))
                 OR eagdi.data_level_name = G_DL_ITEM_REV_LEVEL
                    AND eagdi.defaulting IS NOT NULL)
           AND eagdi.transaction_id IS NOT NULL
           AND eagdi.process_status = G_PROCESS_RECORD
           AND ((G_SET_PROCESS_ID IS NULL)
                 OR (set_process_id = G_SET_PROCESS_ID));

    lv_smt := 11;

    write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Statement 11');

    /* Update the interface records with process_status 3 and insert into
MTL_INTERFACE_ERRORS if View Privilege is incorrect*/
    G_MESSAGE_NAME := 'EGO_VIEW_PRIV_NOT_EXIST';

    fnd_message.Set_name('EGO','EGO_VIEW_PRIV_NOT_EXIST');

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
           G_ENTITY_DL_TAB,
           G_BO_IDENTIFIER_AG,
           G_ENTITY_DL,
           G_MESSAGE_NAME,
           G_MESSAGE_TEXT,
           Nvl(last_update_date,SYSDATE),
           Nvl(last_updated_by,G_USER_ID),
           Nvl(creation_date,SYSDATE),
           Nvl(created_by,G_USER_ID),
           Nvl(last_update_login,G_USER_ID),
           G_REQUEST_ID,
           Nvl(program_application_id,G_PROG_APPL_ID),
           Nvl(program_id,G_PROGRAM_ID),
           Nvl(program_update_date,SYSDATE)
    FROM   ego_attr_groups_dl_interface
    WHERE  ((view_privilege_id IS NULL
             AND view_privilege_name IS NOT NULL
             and view_privilege_name <> G_NULL_CHAR)
             OR (view_privilege_name IS NULL
                 AND view_privilege_id IS NOT NULL
                 AND view_privilege_id <> G_NULL_NUM))
           AND transaction_id IS NOT NULL
           AND process_status = G_PROCESS_RECORD
           AND ((G_SET_PROCESS_ID IS NULL)
                 OR (set_process_id = G_SET_PROCESS_ID));

    UPDATE ego_attr_groups_dl_interface
    SET    process_status = G_ERROR_RECORD,
           last_updated_by = G_USER_ID,
           last_update_date = SYSDATE,
           last_update_login = G_LOGIN_ID
    WHERE  ((view_privilege_id IS NULL
             AND view_privilege_name IS NOT NULL
             and view_privilege_name <> G_NULL_CHAR)
             OR (view_privilege_name IS NULL
                 AND view_privilege_id IS NOT NULL
                 AND view_privilege_id <> G_NULL_NUM))
           AND transaction_id IS NOT NULL
           AND process_status = G_PROCESS_RECORD
           AND ((G_SET_PROCESS_ID IS NULL)
                 OR (set_process_id = G_SET_PROCESS_ID));

    lv_smt := 12;

    write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Statement 12');

    /* Update the interface records with process_status 3 and insert into
MTL_INTERFACE_ERRORS if Edit Privilege is incorrect*/
    G_MESSAGE_NAME := 'EGO_EDIT_PRIV_NOT_EXIST';

    fnd_message.Set_name('EGO','EGO_EDIT_PRIV_NOT_EXIST');

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
           G_ENTITY_DL_TAB,
           G_BO_IDENTIFIER_AG,
           G_ENTITY_DL,
           G_MESSAGE_NAME,
           G_MESSAGE_TEXT,
           Nvl(last_update_date,SYSDATE),
           Nvl(last_updated_by,G_USER_ID),
           Nvl(creation_date,SYSDATE),
           Nvl(created_by,G_USER_ID),
           Nvl(last_update_login,G_USER_ID),
           G_REQUEST_ID,
           Nvl(program_application_id,G_PROG_APPL_ID),
           Nvl(program_id,G_PROGRAM_ID),
           Nvl(program_update_date,SYSDATE)
    FROM   ego_attr_groups_dl_interface
    WHERE  ((edit_privilege_id IS NULL
             AND edit_privilege_name IS NOT NULL
             AND edit_privilege_name <> G_NULL_CHAR)
             OR (edit_privilege_name IS NULL
                 AND edit_privilege_id IS NOT NULL
                 AND edit_privilege_id <> G_NULL_CHAR))
           AND transaction_id IS NOT NULL
           AND process_status = G_PROCESS_RECORD
           AND ((G_SET_PROCESS_ID IS NULL)
                 OR (set_process_id = G_SET_PROCESS_ID));

    UPDATE ego_attr_groups_dl_interface
    SET    process_status = G_ERROR_RECORD,
           last_updated_by = G_USER_ID,
           last_update_date = SYSDATE,
           last_update_login = G_LOGIN_ID
    WHERE  ((edit_privilege_id IS NULL
             AND edit_privilege_name IS NOT NULL)
             OR (edit_privilege_name IS NULL
                 AND edit_privilege_id IS NOT NULL))
           AND transaction_id IS NOT NULL
           AND process_status = G_PROCESS_RECORD
           AND ((G_SET_PROCESS_ID IS NULL)
                 OR (set_process_id = G_SET_PROCESS_ID));

    lv_smt := 13;

    write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Statement 13');

    /* Update the interface records with process_status 3 and insert into
MTL_INTERFACE_ERRORS if Defaulting passed is incorrect*/
    G_MESSAGE_NAME := 'EGO_DEFAULTING_INVALID';

    fnd_message.Set_name('EGO','EGO_DEFAULTING_INVALID');

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
           G_ENTITY_DL_TAB,
           G_BO_IDENTIFIER_AG,
           G_ENTITY_DL,
           G_MESSAGE_NAME,
           G_MESSAGE_TEXT,
           Nvl(last_update_date,SYSDATE),
           Nvl(last_updated_by,G_USER_ID),
           Nvl(creation_date,SYSDATE),
           Nvl(created_by,G_USER_ID),
           Nvl(last_update_login,G_USER_ID),
           G_REQUEST_ID,
           Nvl(program_application_id,G_PROG_APPL_ID),
           Nvl(program_id,G_PROGRAM_ID),
           Nvl(program_update_date,SYSDATE)
    FROM   ego_attr_groups_dl_interface
    WHERE  data_level_name <> 'ITEM_REVISION_LEVEL'
    	   AND transaction_type <> G_OPR_DELETE
    	   AND (defaulting IS NULL
             OR defaulting_name IS NULL)
           AND transaction_id IS NOT NULL
           AND process_status = G_PROCESS_RECORD
           AND ((G_SET_PROCESS_ID IS NULL)
                 OR (set_process_id = G_SET_PROCESS_ID));

    UPDATE ego_attr_groups_dl_interface
    SET    process_status = G_ERROR_RECORD,
           last_updated_by = G_USER_ID,
           last_update_date = SYSDATE,
           last_update_login = G_LOGIN_ID
    WHERE  data_level_name <> 'ITEM_REVISION_LEVEL'
    	   AND transaction_type <> G_OPR_DELETE
    	   AND (defaulting IS NULL
             OR defaulting_name IS NULL)
           AND transaction_id IS NOT NULL
           AND process_status = G_PROCESS_RECORD
           AND ((G_SET_PROCESS_ID IS NULL)
                 OR (set_process_id = G_SET_PROCESS_ID));

	lv_smt := 14;

    write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Statement 14');

    /* Update the interface records with process_status 3 and insert into
MTL_INTERFACE_ERRORS if AG has associations and user is trying to delete a DL*/
    G_MESSAGE_NAME := 'EGO_EF_ASSOCS_EXIST3';

    fnd_message.Set_name('EGO','EGO_EF_ASSOCS_EXIST3');

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
           G_ENTITY_DL_TAB,
           G_BO_IDENTIFIER_AG,
           G_ENTITY_DL,
           G_MESSAGE_NAME,
           G_MESSAGE_TEXT,
           Nvl(last_update_date,SYSDATE),
           Nvl(last_updated_by,G_USER_ID),
           Nvl(creation_date,SYSDATE),
           Nvl(created_by,G_USER_ID),
           Nvl(last_update_login,G_USER_ID),
           G_REQUEST_ID,
           Nvl(program_application_id,G_PROG_APPL_ID),
           Nvl(program_id,G_PROGRAM_ID),
           Nvl(program_update_date,SYSDATE)
    FROM   ego_attr_groups_dl_interface eagdl
    WHERE  transaction_type = G_OPR_DELETE
    	   AND EXISTS (SELECT 1
      				   FROM EGO_OBJ_AG_ASSOCS_B
     				   WHERE ATTR_GROUP_ID = eagdl.attr_group_id
       				   AND ENABLED_FLAG = 'Y')
           AND transaction_id IS NOT NULL
           AND process_status = G_PROCESS_RECORD
           AND ((G_SET_PROCESS_ID IS NULL)
                 OR (set_process_id = G_SET_PROCESS_ID));

    UPDATE ego_attr_groups_dl_interface eagdl
    SET    process_status = G_ERROR_RECORD,
           last_updated_by = G_USER_ID,
           last_update_date = SYSDATE,
           last_update_login = G_LOGIN_ID
    WHERE  transaction_type = G_OPR_DELETE
    	   AND EXISTS (SELECT 1
      				   FROM EGO_OBJ_AG_ASSOCS_B
     				   WHERE ATTR_GROUP_ID = eagdl.attr_group_id
       				   AND ENABLED_FLAG = 'Y')
           AND transaction_id IS NOT NULL
           AND process_status = G_PROCESS_RECORD
           AND ((G_SET_PROCESS_ID IS NULL)
                 OR (set_process_id = G_SET_PROCESS_ID));

    lv_smt := 15;

    write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Statement 15');

    /* Update the interface records with process_status 3 and insert into
MTL_INTERFACE_ERRORS if AG has associations and user is trying to delete the AG*/
    G_MESSAGE_NAME := 'EGO_EF_ASSOCS_EXIST1';

    fnd_message.Set_name('EGO','EGO_EF_ASSOCS_EXIST1');

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
           G_ENTITY_AG_TAB,
           G_BO_IDENTIFIER_AG,
           G_ENTITY_AG,
           G_MESSAGE_NAME,
           G_MESSAGE_TEXT,
           Nvl(last_update_date,SYSDATE),
           Nvl(last_updated_by,G_USER_ID),
           Nvl(creation_date,SYSDATE),
           Nvl(created_by,G_USER_ID),
           Nvl(last_update_login,G_USER_ID),
           G_REQUEST_ID,
           Nvl(program_application_id,G_PROG_APPL_ID),
           Nvl(program_id,G_PROGRAM_ID),
           Nvl(program_update_date,SYSDATE)
    FROM   ego_attr_groups_interface eagdl
    WHERE  transaction_type = G_OPR_DELETE
    	   AND EXISTS (SELECT 1
      				   FROM EGO_OBJ_AG_ASSOCS_B
     				   WHERE ATTR_GROUP_ID = eagdl.attr_group_id
       				   AND ENABLED_FLAG = 'Y')
           AND transaction_id IS NOT NULL
           AND process_status = G_PROCESS_RECORD
           AND ((G_SET_PROCESS_ID IS NULL)
                 OR (set_process_id = G_SET_PROCESS_ID));

    UPDATE ego_attr_groups_interface eagdl
    SET    process_status = G_ERROR_RECORD,
           last_updated_by = G_USER_ID,
           last_update_date = SYSDATE,
           last_update_login = G_LOGIN_ID
    WHERE  transaction_type = G_OPR_DELETE
    	   AND EXISTS (SELECT 1
      				   FROM EGO_OBJ_AG_ASSOCS_B
     				   WHERE ATTR_GROUP_ID = eagdl.attr_group_id
       				   AND ENABLED_FLAG = 'Y')
           AND transaction_id IS NOT NULL
           AND process_status = G_PROCESS_RECORD
           AND ((G_SET_PROCESS_ID IS NULL)
                 OR (set_process_id = G_SET_PROCESS_ID));

    write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Exit bulk_validate_attr_groups');
  EXCEPTION
    WHEN OTHERS THEN
      write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'bulk_validate_attr_groups Exception when others'||SQLERRM);

      x_return_status := G_RET_STS_UNEXP_ERROR;

      x_return_msg := 'ego_ag_bulkload_pvt.bulk_validate_attr_groups - '||SQLERRM;

      RETURN;
  END bulk_validate_attr_groups;

  /*This procedure is used to bulk validate attributes.
  	Used in the interface flow.
  	x_return_status OUT NOCOPY parameter that returns the status*/
  PROCEDURE bulk_validate_attribute
       (x_return_status OUT NOCOPY VARCHAR2, x_return_msg OUT NOCOPY VARCHAR2)
  IS
    lv_smt  NUMBER; --Statement counter

    lv_proc VARCHAR2(30) := 'bulk_validate_attribute';
  BEGIN
    write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Entered bulk_validate_attribute');

    x_return_status := G_RET_STS_SUCCESS;

    lv_smt := 1;

    write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Statement 1');

    /* Update the interface records with process_status 3 and insert into
MTL_INTERFACE_ERRORS if Attribute Group Type in the Attribute interface table is other than EGO_ITEMMGMT_GROUP*/
    G_MESSAGE_NAME := 'EGO_AG_TYPE_INVALID';

    fnd_message.Set_name('EGO','EGO_AG_TYPE_INVALID');

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
    SELECT eagi.transaction_id,
           mtl_system_items_interface_s.nextval,
           NULL,
           NULL,
           G_ENTITY_ATTR_TAB,
           G_BO_IDENTIFIER_AG,
           G_ENTITY_ATTR,
           G_MESSAGE_NAME,
           G_MESSAGE_TEXT,
           Nvl(last_update_date,SYSDATE),
           Nvl(last_updated_by,G_USER_ID),
           Nvl(creation_date,SYSDATE),
           Nvl(created_by,G_USER_ID),
           Nvl(last_update_login,G_USER_ID),
           G_REQUEST_ID,
           Nvl(program_application_id,G_PROG_APPL_ID),
           Nvl(program_id,G_PROGRAM_ID),
           Nvl(program_update_date,SYSDATE)
    FROM   ego_attr_group_cols_intf eagi
    WHERE  attr_group_type <> G_EGO_ITEMMGMT_GROUP
           AND transaction_id IS NOT NULL
           AND process_status = G_PROCESS_RECORD
           AND ((G_SET_PROCESS_ID IS NULL)
                 OR (set_process_id = G_SET_PROCESS_ID));

    UPDATE ego_attr_group_cols_intf
    SET    process_status = G_ERROR_RECORD,
           last_updated_by = G_USER_ID,
           last_update_date = SYSDATE,
           last_update_login = G_LOGIN_ID
    WHERE  attr_group_type <> G_EGO_ITEMMGMT_GROUP
           AND transaction_id IS NOT NULL
           AND process_status = G_PROCESS_RECORD
           AND ((G_SET_PROCESS_ID IS NULL)
                 OR (set_process_id = G_SET_PROCESS_ID));

   lv_smt := 2;

    write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Statement 2');

    /* Update the interface records with process_status 3 and insert into
MTL_INTERFACE_ERRORS if the attribute with the internal name is already present in the system*/
    G_MESSAGE_NAME := 'EGO_EF_INTERNAL_NAME_UNIQUE';

    fnd_message.Set_name('EGO','EGO_EF_INTERNAL_NAME_UNIQUE');

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
    SELECT eagi.transaction_id,
           mtl_system_items_interface_s.nextval,
           NULL,
           NULL,
           G_ENTITY_ATTR_TAB,
           G_BO_IDENTIFIER_AG,
           G_ENTITY_ATTR,
           G_MESSAGE_NAME,
           G_MESSAGE_TEXT,
           Nvl(last_update_date,SYSDATE),
           Nvl(last_updated_by,G_USER_ID),
           Nvl(creation_date,SYSDATE),
           Nvl(created_by,G_USER_ID),
           Nvl(last_update_login,G_USER_ID),
           G_REQUEST_ID,
           Nvl(program_application_id,G_PROG_APPL_ID),
           Nvl(program_id,G_PROGRAM_ID),
           Nvl(program_update_date,SYSDATE)
    FROM   ego_attr_group_cols_intf eagi
    WHERE  EXISTS (SELECT 1
	      			  FROM FND_DESCR_FLEX_COLUMN_USAGES
				      WHERE APPLICATION_ID = G_EGO_APPLICATION_ID
				      AND DESCRIPTIVE_FLEXFIELD_NAME = G_EGO_ITEMMGMT_GROUP
				      AND DESCRIPTIVE_FLEX_CONTEXT_Code = eagi.attr_group_name
				      AND END_USER_COLUMN_NAME = eagi.internal_name
				   )
    	   AND transaction_type = G_OPR_CREATE
           AND transaction_id IS NOT NULL
           AND process_status = G_PROCESS_RECORD
           AND ((G_SET_PROCESS_ID IS NULL)
                 OR (set_process_id = G_SET_PROCESS_ID));

    UPDATE ego_attr_group_cols_intf eagi
    SET    process_status = G_ERROR_RECORD,
           last_updated_by = G_USER_ID,
           last_update_date = SYSDATE,
           last_update_login = G_LOGIN_ID
    WHERE  EXISTS (SELECT 1
	      			  FROM FND_DESCR_FLEX_COLUMN_USAGES
				      WHERE APPLICATION_ID = G_EGO_APPLICATION_ID
				      AND DESCRIPTIVE_FLEXFIELD_NAME = G_EGO_ITEMMGMT_GROUP
				      AND DESCRIPTIVE_FLEX_CONTEXT_Code = eagi.attr_group_name
				      AND END_USER_COLUMN_NAME = eagi.internal_name
				   )
    	   AND transaction_type = G_OPR_CREATE
           AND transaction_id IS NOT NULL
           AND process_status = G_PROCESS_RECORD
           AND ((G_SET_PROCESS_ID IS NULL)
                 OR (set_process_id = G_SET_PROCESS_ID));

    Value_to_id_attr(x_return_status, x_return_msg); IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN RETURN; END IF;

    construct_attribute(x_return_status, x_return_msg); IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN RETURN; END IF;

    lv_smt := 2;

    write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Statement 2');

    /* Update the interface records with process_status 3 and insert into
MTL_INTERFACE_ERRORS if Attribute group does exist in the system or
as a create flow in the AG interface table. Updates the DL interface table*/
    G_MESSAGE_NAME := 'EGO_AG_NOT_EXIST';

    fnd_message.Set_name('EGO','EGO_AG_NOT_EXIST');

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
           G_ENTITY_ATTR_TAB,
           G_BO_IDENTIFIER_AG,
           G_ENTITY_ATTR,
           G_MESSAGE_NAME,
           G_MESSAGE_TEXT,
           Nvl(last_update_date,SYSDATE),
           Nvl(last_updated_by,G_USER_ID),
           Nvl(creation_date,SYSDATE),
           Nvl(created_by,G_USER_ID),
           Nvl(last_update_login,G_USER_ID),
           G_REQUEST_ID,
           Nvl(program_application_id,G_PROG_APPL_ID),
           Nvl(program_id,G_PROGRAM_ID),
           Nvl(program_update_date,SYSDATE)
    FROM   ego_attr_group_cols_intf eagci
    WHERE  (eagci.attr_group_id IS NULL
             OR eagci.attr_group_name IS NULL)
           AND eagci.transaction_id IS NOT NULL
           AND NOT EXISTS (SELECT 1
                           FROM   ego_attr_groups_interface eagi
                           WHERE  eagi.attr_group_name = eagci.attr_group_name
                                  AND eagi.transaction_type = G_OPR_CREATE
                                  AND eagi.process_status = G_PROCESS_RECORD)
           AND eagci.process_status = G_PROCESS_RECORD
           AND ((G_SET_PROCESS_ID IS NULL)
                 OR (set_process_id = G_SET_PROCESS_ID));

    UPDATE ego_attr_group_cols_intf eagci
    SET    eagci.process_status = G_ERROR_RECORD,
           eagci.last_updated_by = G_USER_ID,
           eagci.last_update_date = SYSDATE,
           eagci.last_update_login = G_LOGIN_ID
    WHERE  (eagci.attr_group_id IS NULL
             OR eagci.attr_group_name IS NULL)
           AND eagci.transaction_id IS NOT NULL
           AND NOT EXISTS (SELECT 1
                           FROM   ego_attr_groups_interface eagi
                           WHERE  eagi.attr_group_name = eagci.attr_group_name
                                  AND eagi.transaction_type = G_OPR_CREATE
                                  AND eagi.process_status = G_PROCESS_RECORD)
           AND eagci.process_status = G_PROCESS_RECORD
           AND ((G_SET_PROCESS_ID IS NULL)
                 OR (set_process_id = G_SET_PROCESS_ID));

    lv_smt := 3;

    write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Statement 3');

    /*Sets the error EGO_ATTR_NOT_EXISTS if the attr_id or internal_name is null in the update flow*/
    G_MESSAGE_NAME := 'EGO_ATTR_NOT_EXISTS';

    fnd_message.Set_name('EGO','EGO_ATTR_NOT_EXISTS');

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
           G_ENTITY_ATTR_TAB,
           G_BO_IDENTIFIER_AG,
           G_ENTITY_ATTR,
           G_MESSAGE_NAME,
           G_MESSAGE_TEXT,
           Nvl(last_update_date,SYSDATE),
           Nvl(last_updated_by,G_USER_ID),
           Nvl(creation_date,SYSDATE),
           Nvl(created_by,G_USER_ID),
           Nvl(last_update_login,G_USER_ID),
           G_REQUEST_ID,
           Nvl(program_application_id,G_PROG_APPL_ID),
           Nvl(program_id,G_PROGRAM_ID),
           Nvl(program_update_date,SYSDATE)
    FROM   ego_attr_group_cols_intf eagci
    WHERE  ((eagci.attr_id IS NULL
             AND eagci.internal_name IS NOT NULL)
             OR (eagci.internal_name IS NULL
                 AND eagci.attr_id IS NOT NULL))
           AND eagci.transaction_type <> G_OPR_CREATE
           AND eagci.transaction_id IS NOT NULL
           AND eagci.process_status = G_PROCESS_RECORD
           AND ((G_SET_PROCESS_ID IS NULL)
                 OR (set_process_id = G_SET_PROCESS_ID));

    UPDATE ego_attr_group_cols_intf eagci
    SET    eagci.process_status = G_ERROR_RECORD,
           eagci.last_updated_by = G_USER_ID,
           eagci.last_update_date = SYSDATE,
           eagci.last_update_login = G_LOGIN_ID
    WHERE  ((eagci.attr_id IS NULL
             AND eagci.internal_name IS NOT NULL)
             OR (eagci.internal_name IS NULL
                 AND eagci.attr_id IS NOT NULL))
           AND eagci.transaction_type <> G_OPR_CREATE
           AND eagci.transaction_id IS NOT NULL
           AND eagci.process_status = G_PROCESS_RECORD
           AND ((G_SET_PROCESS_ID IS NULL)
                 OR (set_process_id = G_SET_PROCESS_ID));

    lv_smt := 4;

    write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Statement 4');

    /*Sets the error EGO_EF_BC_SEL_EXI_VALUE if the value set is defined in the system*/
    G_MESSAGE_NAME := 'EGO_EF_BC_SEL_EXI_VALUE';

    fnd_message.Set_name('EGO','EGO_EF_BC_SEL_EXI_VALUE');

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
           G_ENTITY_ATTR_TAB,
           G_BO_IDENTIFIER_AG,
           G_ENTITY_ATTR,
           G_MESSAGE_NAME,
           G_MESSAGE_TEXT,
           Nvl(last_update_date,SYSDATE),
           Nvl(last_updated_by,G_USER_ID),
           Nvl(creation_date,SYSDATE),
           Nvl(created_by,G_USER_ID),
           Nvl(last_update_login,G_USER_ID),
           G_REQUEST_ID,
           Nvl(program_application_id,G_PROG_APPL_ID),
           Nvl(program_id,G_PROGRAM_ID),
           Nvl(program_update_date,SYSDATE)
    FROM   ego_attr_group_cols_intf eagci
    WHERE  ((eagci.flex_value_set_id IS NULL
             AND eagci.flex_value_set_name IS NOT NULL
             AND eagci.flex_value_set_name <> G_NULL_CHAR)
             OR (eagci.flex_value_set_name IS NULL
                 AND eagci.flex_value_set_id IS NOT NULL
                 AND eagci.flex_value_set_id <> G_NULL_NUM))
           AND eagci.transaction_id IS NOT NULL
           AND eagci.process_status = G_PROCESS_RECORD
           AND ((G_SET_PROCESS_ID IS NULL)
                 OR (set_process_id = G_SET_PROCESS_ID));

    UPDATE ego_attr_group_cols_intf eagci
    SET    eagci.process_status = G_ERROR_RECORD,
           eagci.last_updated_by = G_USER_ID,
           eagci.last_update_date = SYSDATE,
           eagci.last_update_login = G_LOGIN_ID
    WHERE  ((eagci.flex_value_set_id IS NULL
             AND eagci.flex_value_set_name IS NOT NULL
             AND eagci.flex_value_set_name <> G_NULL_CHAR)
             OR (eagci.flex_value_set_name IS NULL
                 AND eagci.flex_value_set_id IS NOT NULL
                 AND eagci.flex_value_set_id <> G_NULL_NUM))
           AND eagci.transaction_id IS NOT NULL
           AND eagci.process_status = G_PROCESS_RECORD
           AND ((G_SET_PROCESS_ID IS NULL)
                 OR (set_process_id = G_SET_PROCESS_ID));

        lv_smt := 5;

    write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Statement 5');

    /* Update the interface records with process_status 3 and insert into
MTL_INTERFACE_ERRORS if AG has associations and user is trying to delete the attributes*/
    G_MESSAGE_NAME := 'EGO_EF_ASSOCS_EXIST2';

    fnd_message.Set_name('EGO','EGO_EF_ASSOCS_EXIST2');

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
           G_ENTITY_ATTR_TAB,
           G_BO_IDENTIFIER_AG,
           G_ENTITY_ATTR,
           G_MESSAGE_NAME,
           G_MESSAGE_TEXT,
           Nvl(last_update_date,SYSDATE),
           Nvl(last_updated_by,G_USER_ID),
           Nvl(creation_date,SYSDATE),
           Nvl(created_by,G_USER_ID),
           Nvl(last_update_login,G_USER_ID),
           G_REQUEST_ID,
           Nvl(program_application_id,G_PROG_APPL_ID),
           Nvl(program_id,G_PROGRAM_ID),
           Nvl(program_update_date,SYSDATE)
    FROM   ego_attr_group_cols_intf eagdl
    WHERE  transaction_type = G_OPR_DELETE
    	   AND EXISTS (SELECT 1
      				   FROM EGO_OBJ_AG_ASSOCS_B
     				   WHERE ATTR_GROUP_ID = eagdl.attr_group_id
       				   AND ENABLED_FLAG = 'Y')
           AND transaction_id IS NOT NULL
           AND process_status = G_PROCESS_RECORD
           AND ((G_SET_PROCESS_ID IS NULL)
                 OR (set_process_id = G_SET_PROCESS_ID));

    UPDATE ego_attr_group_cols_intf eagdl
    SET    process_status = G_ERROR_RECORD,
           last_updated_by = G_USER_ID,
           last_update_date = SYSDATE,
           last_update_login = G_LOGIN_ID
    WHERE  transaction_type = G_OPR_DELETE
    	   AND EXISTS (SELECT 1
      				   FROM EGO_OBJ_AG_ASSOCS_B
     				   WHERE ATTR_GROUP_ID = eagdl.attr_group_id
       				   AND ENABLED_FLAG = 'Y')
           AND transaction_id IS NOT NULL
           AND process_status = G_PROCESS_RECORD
           AND ((G_SET_PROCESS_ID IS NULL)
                 OR (set_process_id = G_SET_PROCESS_ID));


    write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Exit bulk_validate_attribute');
  EXCEPTION
    WHEN OTHERS THEN
      write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'bulk_validate_attribute Exception when others'||SQLERRM);

      x_return_status := G_RET_STS_UNEXP_ERROR;

      x_return_msg := 'ego_ag_bulkload_pvt.bulk_validate_attribute - '||SQLERRM;

      RETURN;
  END bulk_validate_attribute;

  /*This procedure is used for value to ID conversion for Attribute Groups.
  	Used in the interface flow.
  	x_return_status OUT NOCOPY parameter that returns the status*/
  PROCEDURE Value_to_id_ag
       (x_return_status OUT NOCOPY VARCHAR2, x_return_msg OUT NOCOPY VARCHAR2)
  IS
    lv_smt  NUMBER; --Statement counter

    lv_proc VARCHAR2(30) := 'Value_to_id_ag';
  BEGIN
    write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Entered Value_to_id_ag');

    x_return_status := G_RET_STS_SUCCESS;

    lv_smt := 1;

    write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Statement 1');

    /*Sets the Attribute group id when the Internal Attribute group name is given*/
    UPDATE ego_attr_groups_interface eagi
    SET    eagi.attr_group_id = (SELECT attr_group_id
                                 FROM   ego_fnd_dsc_flx_ctx_ext
                                 WHERE  application_id = g_ego_application_id
                                        AND descriptive_flexfield_name = eagi.attr_group_type
                                        AND descriptive_flex_context_code = eagi.attr_group_name),
           eagi.transaction_type = decode(transaction_type,G_OPR_SYNC,G_OPR_UPDATE,transaction_type),
           last_updated_by = G_USER_ID,
           last_update_date = SYSDATE,
           last_update_login = G_LOGIN_ID
    WHERE  eagi.transaction_type <> G_OPR_CREATE
           AND eagi.attr_group_id IS NULL
           AND eagi.attr_group_name IS NOT NULL
           AND eagi.process_status = G_PROCESS_RECORD
           AND ((G_SET_PROCESS_ID IS NULL)
                 OR (set_process_id = G_SET_PROCESS_ID));

    lv_smt := 2;

    write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Statement 2');

    /*Sets the SYNC transaction type to CREATE*/
    UPDATE ego_attr_groups_interface eagi
    SET    eagi.transaction_type = decode(attr_group_id,null,G_OPR_CREATE,G_OPR_UPDATE),
           last_updated_by = G_USER_ID,
           last_update_date = SYSDATE,
           last_update_login = G_LOGIN_ID
    WHERE  eagi.transaction_type NOT IN (G_OPR_CREATE,G_OPR_DELETE)
           AND eagi.attr_group_id IS NULL
           AND eagi.attr_group_name IS NOT NULL
           AND eagi.process_status = G_PROCESS_RECORD
           AND ((G_SET_PROCESS_ID IS NULL)
                 OR (set_process_id = G_SET_PROCESS_ID));


    /*As of now we dont support Owning party. When we support do value to id
converstion for that here*/
    write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Exit Value_to_id_ag');
  EXCEPTION
    WHEN OTHERS THEN
      write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Value_to_id_ag Exception when others'||SQLERRM);

      x_return_status := G_RET_STS_UNEXP_ERROR;

      x_return_msg := 'ego_ag_bulkload_pvt.Value_to_id_ag - '||SQLERRM;

      RETURN;
  END Value_to_id_ag;

  /*This procedure is used for value to ID conversion for Attribute Groups
    Data level.	Used in the interface flow.
  	x_return_status OUT NOCOPY parameter that returns the status*/
  PROCEDURE Value_to_id_dl
       (x_return_status OUT NOCOPY VARCHAR2, x_return_msg OUT NOCOPY VARCHAR2)
  IS
    lv_smt  NUMBER;

    lv_proc VARCHAR2(30) := 'Value_to_id_dl';
  BEGIN
    write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Entered Value_to_id_dl');

    x_return_status := G_RET_STS_SUCCESS;

    lv_smt := 1;

    write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Statement 1');

    /*Sets the Attribute group id when the Internal Attribute group name is given*/
    UPDATE ego_attr_groups_dl_interface eagdi
    SET    eagdi.attr_group_id = (SELECT attr_group_id
                                  FROM   ego_fnd_dsc_flx_ctx_ext
                                  WHERE  application_id = g_ego_application_id
                                         AND descriptive_flexfield_name = eagdi.attr_group_type
                                         AND descriptive_flex_context_code = eagdi.attr_group_name),
           last_updated_by = G_USER_ID,
           last_update_date = SYSDATE,
           last_update_login = G_LOGIN_ID
    WHERE  eagdi.attr_group_id IS NULL
           AND eagdi.attr_group_name IS NOT NULL
           AND eagdi.process_status = G_PROCESS_RECORD
           AND ((G_SET_PROCESS_ID IS NULL)
                 OR (set_process_id = G_SET_PROCESS_ID));


    lv_smt := 3;

    write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Statement 3');

    /*Set the View Privilege ID when the View Privilege Name or User View privilege name is given*/
    UPDATE ego_attr_groups_dl_interface eagdl
    SET    eagdl.view_privilege_id = (SELECT function_id
                                      FROM   fnd_form_functions
                                      WHERE  function_name = eagdl.view_privilege_name),
           last_updated_by = G_USER_ID,
           last_update_date = SYSDATE,
           last_update_login = G_LOGIN_ID
    WHERE  eagdl.view_privilege_id IS NULL
           AND eagdl.view_privilege_name IS NOT NULL
           AND eagdl.process_status = G_PROCESS_RECORD
           AND ((G_SET_PROCESS_ID IS NULL)
                 OR (set_process_id = G_SET_PROCESS_ID));

	UPDATE ego_attr_groups_dl_interface eagdl
    SET    view_privilege_id = (SELECT function_id
                                FROM   fnd_form_functions_vl
                                WHERE  user_function_name = eagdl.user_view_priv_name),
           last_updated_by = G_USER_ID,
           last_update_date = SYSDATE,
           last_update_login = G_LOGIN_ID
    WHERE  eagdl.view_privilege_id IS NULL
           AND eagdl.user_view_priv_name IS NOT NULL
           AND eagdl.process_status = G_PROCESS_RECORD
           AND ((G_SET_PROCESS_ID IS NULL)
                 OR (set_process_id = G_SET_PROCESS_ID));

    lv_smt := 4;

    write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Statement 4');

    /*Set the Edit Privilege ID when the Edit Privilege Name or user edit priviledge name is given*/
    UPDATE ego_attr_groups_dl_interface eagdl
    SET    edit_privilege_id = (SELECT function_id
                                FROM   fnd_form_functions
                                WHERE  function_name = eagdl.edit_privilege_name),
           last_updated_by = G_USER_ID,
           last_update_date = SYSDATE,
           last_update_login = G_LOGIN_ID
    WHERE  eagdl.edit_privilege_id IS NULL
           AND eagdl.edit_privilege_name IS NOT NULL
           AND eagdl.process_status = G_PROCESS_RECORD
           AND ((G_SET_PROCESS_ID IS NULL)
                 OR (set_process_id = G_SET_PROCESS_ID));

    UPDATE ego_attr_groups_dl_interface eagdl
    SET    edit_privilege_id = (SELECT function_id
                                FROM   fnd_form_functions_vl
                                WHERE  user_function_name = eagdl.user_edit_priv_name),
           last_updated_by = G_USER_ID,
           last_update_date = SYSDATE,
           last_update_login = G_LOGIN_ID
    WHERE  eagdl.edit_privilege_id IS NULL
           AND eagdl.user_edit_priv_name IS NOT NULL
           AND eagdl.process_status = G_PROCESS_RECORD
           AND ((G_SET_PROCESS_ID IS NULL)
                 OR (set_process_id = G_SET_PROCESS_ID));

    lv_smt := 5;

    write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Statement 5');

    /*Set the Data Level ID when the data level is given*/
    UPDATE ego_attr_groups_dl_interface eagdi
    SET    eagdi.data_level_id = (SELECT data_level_id
                                  FROM   ego_data_level_b
                                  WHERE  attr_group_type = eagdi.attr_group_type
                                         AND application_id = g_ego_application_id
                                         AND data_level_name = eagdi.data_level_name),
           last_updated_by = G_USER_ID,
           last_update_date = SYSDATE,
           last_update_login = G_LOGIN_ID
    WHERE  eagdi.data_level_id IS NULL
           AND eagdi.data_level_name IS NOT NULL
           AND eagdi.process_status = G_PROCESS_RECORD
           AND ((G_SET_PROCESS_ID IS NULL)
                 OR (set_process_id = G_SET_PROCESS_ID));

    lv_smt := 6;

    write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Statement 6');

    /*Sets the SYNC transaction type to UPDATE*/
    UPDATE ego_attr_groups_dl_interface eagdi
    SET    eagdi.transaction_type = G_OPR_UPDATE,
           last_updated_by = G_USER_ID,
           last_update_date = SYSDATE,
           last_update_login = G_LOGIN_ID
    WHERE  eagdi.data_level_id IS NOT NULL
           AND eagdi.attr_group_id IS NOT NULL
           AND transaction_type = G_OPR_SYNC
           AND EXISTS (SELECT 1
                       FROM   ego_attr_group_dl eagdl
                       WHERE  eagdl.attr_group_id = eagdi.attr_group_id
                              AND eagdl.data_level_id = eagdi.data_level_id)
           AND eagdi.process_status = G_PROCESS_RECORD
           AND ((G_SET_PROCESS_ID IS NULL)
                 OR (set_process_id = G_SET_PROCESS_ID));

    lv_smt := 7;

    write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Statement 7');

    /*Sets the SYNC transaction type to CREATE*/
    UPDATE ego_attr_groups_dl_interface eagdi
    SET    eagdi.transaction_type = G_OPR_CREATE,
           last_updated_by = G_USER_ID,
           last_update_date = SYSDATE,
           last_update_login = G_LOGIN_ID
    WHERE  eagdi.data_level_id IS NOT NULL
           AND eagdi.attr_group_id IS NOT NULL
           AND transaction_type = G_OPR_SYNC
           AND NOT EXISTS (SELECT 1
                           FROM   ego_attr_group_dl eagdl
                           WHERE  eagdl.attr_group_id = eagdi.attr_group_id
                                  AND eagdl.data_level_id = eagdi.data_level_id)
           AND eagdi.process_status = G_PROCESS_RECORD
           AND ((G_SET_PROCESS_ID IS NULL)
                 OR (set_process_id = G_SET_PROCESS_ID));

	lv_smt := 7.1;

    write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Statement 7.1');

    /*Sets the SYNC transaction type to CREATE*/
    UPDATE ego_attr_groups_dl_interface eagdi
    SET    eagdi.transaction_type = G_OPR_CREATE,
           last_updated_by = G_USER_ID,
           last_update_date = SYSDATE,
           last_update_login = G_LOGIN_ID
    WHERE  eagdi.attr_group_id IS NULL
           AND transaction_type = G_OPR_SYNC
           AND eagdi.process_status = G_PROCESS_RECORD
           AND ((G_SET_PROCESS_ID IS NULL)
                 OR (set_process_id = G_SET_PROCESS_ID));

    write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Exit Value_to_id_dl');
  EXCEPTION
    WHEN OTHERS THEN
      write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Value_to_id_dl Exception when others'||SQLERRM);

      x_return_status := G_RET_STS_UNEXP_ERROR;

      x_return_msg := 'ego_ag_bulkload_pvt.Value_to_id_dl - '||SQLERRM;

      RETURN;
  END Value_to_id_dl;

  /*This procedure is used for value to ID conversion for Attributes.
  	Used in the interface flow.
  	x_return_status OUT NOCOPY parameter that returns the status*/
  PROCEDURE Value_to_id_attr
       (x_return_status OUT NOCOPY VARCHAR2, x_return_msg OUT NOCOPY VARCHAR2)
  IS
    lv_smt  NUMBER; --Statement counter;

    lv_proc VARCHAR2(30) := 'Value_to_id_attr';
  BEGIN
    write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Entering Value_to_id_attr');

    x_return_status := G_RET_STS_SUCCESS;

    lv_smt := 1;

    write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Statement 1');

    /*Sets the Attribute group id when the Internal Attribute group name is given*/
    UPDATE ego_attr_group_cols_intf eagci
    SET    eagci.attr_group_id = (SELECT attr_group_id
                                  FROM   ego_fnd_dsc_flx_ctx_ext
                                  WHERE  application_id = g_ego_application_id
                                         AND descriptive_flexfield_name = eagci.attr_group_type
                                         AND descriptive_flex_context_code = eagci.attr_group_name),
           eagci.last_updated_by = G_USER_ID,
           eagci.last_update_date = SYSDATE,
           eagci.last_update_login = G_LOGIN_ID
    WHERE  eagci.attr_group_id IS NULL
           AND eagci.attr_group_name IS NOT NULL
           AND eagci.process_status = G_PROCESS_RECORD
           AND ((G_SET_PROCESS_ID IS NULL)
                 OR (set_process_id = G_SET_PROCESS_ID));

    lv_smt := 2;

    write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Statement 2');

    /*Set the application id*/
    UPDATE ego_attr_group_cols_intf
    SET    application_id = g_ego_application_id,
           last_updated_by = G_USER_ID,
           last_update_date = SYSDATE,
           last_update_login = G_LOGIN_ID
    WHERE  application_id IS NULL
           AND process_status = G_PROCESS_RECORD
           AND ((G_SET_PROCESS_ID IS NULL)
                 OR (set_process_id = G_SET_PROCESS_ID));

    lv_smt := 3;

    write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Statement 3');

    /*Sets the Attr_id for the update and sync flow*/
    UPDATE ego_attr_group_cols_intf eagci
    SET    eagci.attr_id = (SELECT efdcue.attr_id
                            FROM   fnd_descr_flex_column_usages fdfcu,
                                   ego_fnd_df_col_usgs_ext efdcue
                            WHERE  fdfcu.application_id = efdcue.application_id
                                   AND fdfcu.descriptive_flexfield_name = efdcue.descriptive_flexfield_name
                                   AND fdfcu.descriptive_flex_context_code = efdcue.descriptive_flex_context_code
                                   AND fdfcu.application_column_name = efdcue.application_column_name
                                   AND fdfcu.application_id = g_ego_application_id
                                   AND fdfcu.descriptive_flexfield_name = eagci.attr_group_type
                                   AND fdfcu.descriptive_flex_context_code = eagci.attr_group_name
                                   AND fdfcu.end_user_column_name = eagci.internal_name)
    WHERE  eagci.attr_id IS NULL
           AND eagci.internal_name IS NOT NULL
           AND eagci.transaction_type IN (G_OPR_UPDATE,G_OPR_SYNC,G_OPR_DELETE)
           AND eagci.process_status = G_PROCESS_RECORD
           AND ((G_SET_PROCESS_ID IS NULL)
                 OR (set_process_id = G_SET_PROCESS_ID));

    lv_smt := 4;

    write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Statement 4');

    /*Sets the value set id when the value set name is given*/
    UPDATE ego_attr_group_cols_intf eagci
    SET    eagci.flex_value_set_id = (SELECT ffvs.flex_value_set_id
                                      FROM   fnd_flex_value_sets ffvs
                                      WHERE  ffvs.flex_value_set_name = eagci.flex_value_set_name)
    WHERE  eagci.flex_value_set_id IS NULL
           AND eagci.flex_value_set_name IS NOT NULL
           AND eagci.process_status = G_PROCESS_RECORD
           AND ((G_SET_PROCESS_ID IS NULL)
                 OR (set_process_id = G_SET_PROCESS_ID));

    lv_smt := 5;

    write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Statement 5');

    /*Sets the Sync type to UPDATE*/
    UPDATE ego_attr_group_cols_intf
    SET    transaction_type = G_OPR_UPDATE
    WHERE  transaction_type = G_OPR_SYNC
           AND attr_id IS NOT NULL
           AND process_status = G_PROCESS_RECORD
           AND ((G_SET_PROCESS_ID IS NULL)
                 OR (set_process_id = G_SET_PROCESS_ID));

    lv_smt := 6;

    write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Statement 6');

    /*Sets the Sync type to CREATE*/
    UPDATE ego_attr_group_cols_intf
    SET    transaction_type = G_OPR_CREATE
    WHERE  transaction_type = G_OPR_SYNC
           AND attr_id IS NULL
           AND process_status = G_PROCESS_RECORD
           AND ((G_SET_PROCESS_ID IS NULL)
                 OR (set_process_id = G_SET_PROCESS_ID));

    write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Exit Value_to_id_attr');
  EXCEPTION
    WHEN OTHERS THEN
      write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Value_to_id_attr Exception when others'||SQLERRM);

      x_return_status := G_RET_STS_UNEXP_ERROR;

      x_return_msg := 'ego_ag_bulkload_pvt.Value_to_id_attr - '||SQLERRM;

      RETURN;
  END value_to_id_attr;

  /*This procedure is used construct attribute group records.
  	Used in the interface flow.
  	x_return_status OUT NOCOPY parameter that returns the status*/
  PROCEDURE construct_attr_groups
       (x_return_status OUT NOCOPY VARCHAR2, x_return_msg OUT NOCOPY VARCHAR2)
  IS
    lv_smt  NUMBER; --Statement counter

    lv_proc VARCHAR2(30) := 'construct_attr_groups';
  BEGIN
    write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Entering construct_attr_groups');

    x_return_status := G_RET_STS_SUCCESS;

    lv_smt := 1;

    write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Statement 1');

    /*Sets the Internal Attribute group name when the attribute group id is given*/
    UPDATE ego_attr_groups_interface eagi
    SET    eagi.attr_group_name = (SELECT attr_group_name
                                   FROM   ego_fnd_dsc_flx_ctx_ext
                                   WHERE  application_id = g_ego_application_id
                                          AND descriptive_flexfield_name = eagi.attr_group_type
                                          AND attr_group_id = eagi.attr_group_id),
           last_updated_by = G_USER_ID,
           last_update_date = SYSDATE,
           last_update_login = G_LOGIN_ID
    WHERE  eagi.transaction_type = G_OPR_UPDATE
           AND eagi.attr_group_id IS NOT NULL
           AND eagi.process_status = G_PROCESS_RECORD
           AND ((G_SET_PROCESS_ID IS NULL)
                 OR (set_process_id = G_SET_PROCESS_ID));

    lv_smt := 2;

    write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Statement 2');

    /*Set default for MULTIROW as N*/
    UPDATE ego_attr_groups_interface
    SET    multi_row = 'N',
           last_updated_by = G_USER_ID,
           last_update_date = SYSDATE,
           last_update_login = G_LOGIN_ID
    WHERE  multi_row IS NULL
           AND transaction_type = G_OPR_CREATE
           AND process_status = G_PROCESS_RECORD
           AND ((G_SET_PROCESS_ID IS NULL)
                 OR (set_process_id = G_SET_PROCESS_ID));

    write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Exit construct_attr_groups');
  EXCEPTION
    WHEN OTHERS THEN
      write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'construct_attr_groups Exception when others'||SQLERRM);

      x_return_status := G_RET_STS_UNEXP_ERROR;

      x_return_msg := 'ego_ag_bulkload_pvt.construct_attr_groups - '||SQLERRM;

      RETURN;
  END construct_attr_groups;

  /*This procedure is used construct attribute group data level records.
  	Used in the interface flow.
  	x_return_status OUT NOCOPY parameter that returns the status*/
  PROCEDURE construct_ag_data_level
       (x_return_status OUT NOCOPY VARCHAR2, x_return_msg OUT NOCOPY VARCHAR2)
  IS
    lv_smt  NUMBER;

    lv_proc VARCHAR2(30) := 'construct_ag_data_level';
  BEGIN
    write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Entering construct_ag_data_level');

    x_return_status := G_RET_STS_SUCCESS;

    lv_smt := 1;

    write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Statement 1');

    /*Sets the Internal Attribute group name when the attribute group id is given*/
    UPDATE ego_attr_groups_dl_interface eagdi
    SET    eagdi.attr_group_name = (SELECT attr_group_name
                                    FROM   ego_fnd_dsc_flx_ctx_ext
                                    WHERE  application_id = g_ego_application_id
                                           AND descriptive_flexfield_name = eagdi.attr_group_type
                                           AND attr_group_id = eagdi.attr_group_id),
           last_updated_by = G_USER_ID,
           last_update_date = SYSDATE,
           last_update_login = G_LOGIN_ID
    WHERE  eagdi.attr_group_id IS NOT NULL
           AND eagdi.process_status = G_PROCESS_RECORD
           AND ((G_SET_PROCESS_ID IS NULL)
                 OR (set_process_id = G_SET_PROCESS_ID));

    lv_smt := 2;

    write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Statement 2');

    /*Set the View Privilege when the id is given*/
    UPDATE ego_attr_groups_dl_interface eagdl
    SET    (view_privilege_name,user_view_priv_name) = (SELECT function_name, user_function_name
                                        				FROM   fnd_form_functions_vl
                                        				WHERE  function_id = eagdl.view_privilege_id),
           last_updated_by = G_USER_ID,
           last_update_date = SYSDATE,
           last_update_login = G_LOGIN_ID
    WHERE  eagdl.view_privilege_id IS NOT NULL
           AND eagdl.process_status = G_PROCESS_RECORD
           AND ((G_SET_PROCESS_ID IS NULL)
                 OR (set_process_id = G_SET_PROCESS_ID));

    lv_smt := 3;

    write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Statement 3');

    /*Set the Edit Privilege when the id is given*/
    UPDATE ego_attr_groups_dl_interface eagdl
    SET    (edit_privilege_name,user_edit_priv_name) = (SELECT function_name, user_function_name
                                        				FROM   fnd_form_functions_vl
                                        				WHERE  function_id = eagdl.edit_privilege_id),
           last_updated_by = G_USER_ID,
           last_update_date = SYSDATE,
           last_update_login = G_LOGIN_ID
    WHERE  eagdl.edit_privilege_id IS NOT NULL
           AND eagdl.process_status = G_PROCESS_RECORD
           AND ((G_SET_PROCESS_ID IS NULL)
                 OR (set_process_id = G_SET_PROCESS_ID));

    lv_smt := 4;

    write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Statement 4');

    /*Set the defaulting when defaulting name is given*/

    UPDATE ego_attr_groups_dl_interface eagdl
    SET    eagdl.defaulting = (SELECT lookup_code
                               FROM   fnd_lookup_values
                               WHERE  lookup_type = 'EGO_EF_AG_DL_BEHAVIOR'
                                      AND meaning = eagdl.defaulting_name
                                      AND language = Userenv('LANG')),
           last_updated_by = G_USER_ID,
           last_update_date = SYSDATE,
           last_update_login = G_LOGIN_ID
    WHERE  eagdl.defaulting IS NULL
           AND eagdl.defaulting_name IS NOT NULL
           AND eagdl.process_status = G_PROCESS_RECORD
           AND ((G_SET_PROCESS_ID IS NULL)
                 OR (set_process_id = G_SET_PROCESS_ID));


    lv_smt := 5;

    write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Statement 5');

    /*Set the defaulting name when defaulting is given*/
    UPDATE ego_attr_groups_dl_interface eagdl
    SET    eagdl.defaulting_name = (SELECT meaning
                                    FROM   fnd_lookup_values
                                    WHERE  lookup_type = 'EGO_EF_AG_DL_BEHAVIOR'
                                           AND lookup_code = eagdl.defaulting
                                           AND language = Userenv('LANG')),
           last_updated_by = G_USER_ID,
           last_update_date = SYSDATE,
           last_update_login = G_LOGIN_ID
    WHERE  eagdl.defaulting IS NOT NULL
           AND eagdl.process_status = G_PROCESS_RECORD
           AND ((G_SET_PROCESS_ID IS NULL)
                 OR (set_process_id = G_SET_PROCESS_ID));

    lv_smt := 6;

    write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Statement 6');

    /*Set the Data Level  when the data level id is given*/
    UPDATE ego_attr_groups_dl_interface eagdi
    SET    eagdi.data_level_name = (SELECT data_level_name
                                    FROM   ego_data_level_b
                                    WHERE  attr_group_type = eagdi.attr_group_type
                                           AND application_id = g_ego_application_id
                                           AND data_level_id = eagdi.data_level_id),
           last_updated_by = G_USER_ID,
           last_update_date = SYSDATE,
           last_update_login = G_LOGIN_ID
    WHERE  eagdi.data_level_id IS NOT NULL
           AND eagdi.process_status = G_PROCESS_RECORD
           AND ((G_SET_PROCESS_ID IS NULL)
                 OR (set_process_id = G_SET_PROCESS_ID));

    write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Exit construct_ag_data_level');
  EXCEPTION
    WHEN OTHERS THEN
      write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'construct_ag_data_level Exception when others'||SQLERRM);

      x_return_status := G_RET_STS_UNEXP_ERROR;

      x_return_msg := 'ego_ag_bulkload_pvt.construct_ag_data_level - '||SQLERRM;

      RETURN;
  END construct_ag_data_level;

  /*This procedure is used construct attributes records.
  	Used in the interface flow.
  	x_return_status OUT NOCOPY parameter that returns the status*/
  PROCEDURE construct_attribute
       (x_return_status OUT NOCOPY VARCHAR2, x_return_msg OUT NOCOPY VARCHAR2)
  IS
    lv_smt  NUMBER; --Statement counter

    lv_proc VARCHAR2(30) := 'construct_attribute';
  BEGIN
    write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Entering construct_attribute');

    x_return_status := G_RET_STS_SUCCESS;

    lv_smt := 1;

    write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Statement 1');

    /*Sets the Internal Attribute group name when the Attribute group id is given*/
    UPDATE ego_attr_group_cols_intf eagci
    SET    eagci.attr_group_name = (SELECT descriptive_flex_context_code
                                  FROM   ego_fnd_dsc_flx_ctx_ext
                                  WHERE  application_id = g_ego_application_id
                                         AND descriptive_flexfield_name = eagci.attr_group_type
                                         AND attr_group_id = eagci.attr_group_id),
           eagci.last_updated_by = G_USER_ID,
           eagci.last_update_date = SYSDATE,
           eagci.last_update_login = G_LOGIN_ID
    WHERE  eagci.attr_group_id IS NOT NULL
           AND eagci.process_status = G_PROCESS_RECORD
           AND ((G_SET_PROCESS_ID IS NULL)
                 OR (set_process_id = G_SET_PROCESS_ID));

    lv_smt := 2;

    write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Statement 2');

    /*Sets the Internal Attribute name when then Attr id is given*/
    UPDATE ego_attr_group_cols_intf eagci
    SET    eagci.internal_name = (SELECT fdfcu.end_user_column_name
                                  FROM   fnd_descr_flex_column_usages fdfcu,
                                         ego_fnd_df_col_usgs_ext efdcue
                                  WHERE  fdfcu.application_id = efdcue.application_id
                                         AND fdfcu.descriptive_flexfield_name = efdcue.descriptive_flexfield_name
                                         AND fdfcu.descriptive_flex_context_code = efdcue.descriptive_flex_context_code
                                         AND fdfcu.application_column_name = efdcue.application_column_name
                                         AND fdfcu.application_id = g_ego_application_id
                                         AND fdfcu.descriptive_flexfield_name = eagci.attr_group_type
                                         AND fdfcu.descriptive_flex_context_code = eagci.attr_group_name
                                         AND efdcue.attr_id = eagci.attr_id)
    WHERE  eagci.attr_id IS NOT NULL
           AND eagci.transaction_type IN (G_OPR_UPDATE,G_OPR_SYNC)
           AND eagci.process_status = G_PROCESS_RECORD
           AND ((G_SET_PROCESS_ID IS NULL)
                 OR (set_process_id = G_SET_PROCESS_ID));

    lv_smt := 3;

    write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Statement 3');

    /*Sets the value set name when the value set id is given*/
    UPDATE ego_attr_group_cols_intf eagci
    SET    eagci.flex_value_set_name = (SELECT ffvs.flex_value_set_name
                                        FROM   fnd_flex_value_sets ffvs
                                        WHERE  ffvs.flex_value_set_id = eagci.flex_value_set_id)
    WHERE  eagci.flex_value_set_id IS NOT NULL
           AND eagci.process_status = G_PROCESS_RECORD
           AND ((G_SET_PROCESS_ID IS NULL)
                 OR (set_process_id = G_SET_PROCESS_ID));

    write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Exit construct_attribute');
  EXCEPTION
    WHEN OTHERS THEN
      write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'construct_attribute Exception when others'||SQLERRM);

      x_return_status := G_RET_STS_UNEXP_ERROR;

      x_return_msg := 'ego_ag_bulkload_pvt.construct_attribute - '||SQLERRM;

      RETURN;
  END construct_attribute;

  /*This is the main procedure called to import attribute groups and data levels.
  	Used in the API flow.
  	p_ag_tbl        IN OUT NOCOPY Attribute groups plsql table
  	p_agdl_tbl      IN OUT NOCOPY Data level plsql table
  	p_commit        IN Pass true to commit within the API
  	x_return_status OUT NOCOPY parameter that returns the status*/
  PROCEDURE process_attr_groups
       (p_ag_tbl         IN OUT NOCOPY ego_metadata_pub.ego_attr_groups_tbl,
        p_agdl_tbl       IN OUT NOCOPY ego_metadata_pub.ego_attr_groups_dl_tbl,
        p_commit         IN BOOLEAN DEFAULT true,
        x_return_status OUT NOCOPY VARCHAR2, x_return_msg OUT NOCOPY VARCHAR2)
  IS

    lv_proc VARCHAR2(30) := 'process_attr_groups';
  BEGIN
    write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Entering process_attr_groups');

    x_return_status := G_RET_STS_SUCCESS;

    error_handler.Set_bo_identifier(G_BO_IDENTIFIER_AG);



    G_COMMIT := p_commit;

    G_FLOW_TYPE := g_ego_md_api;

    /*Sets the EGO application ID*/
    SELECT application_id
    INTO   g_ego_application_id
    FROM   fnd_application
    WHERE  application_short_name = 'EGO';

    /*Calls Additional Validations for AG and DL*/
    Additional_agdl_validations(p_ag_tbl,p_agdl_tbl,x_return_status, x_return_msg); IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN RETURN; END IF;

    IF (p_ag_tbl.COUNT <> 0) THEN
	    /*Send the AG table for processing*/
	    Process_ag(p_ag_tbl,x_return_status, x_return_msg); IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN RETURN; END IF;
	END IF;

	IF (p_agdl_tbl.COUNT <> 0) THEN
	    /*Send the DL table for processing*/
	    Process_dl(p_agdl_tbl,x_return_status, x_return_msg); IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN RETURN; END IF;
	END IF;

	delete_ag_none_dl(x_return_status => x_return_status, x_return_msg => x_return_msg); IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN RETURN; END IF;

    write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Exit process_attr_groups');
  EXCEPTION
    WHEN OTHERS THEN
      write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'process_attr_groups Exception when others'||SQLERRM);

      x_return_status := G_RET_STS_UNEXP_ERROR;

      x_return_msg := 'ego_ag_bulkload_pvt.process_attr_groups - '||SQLERRM;

      RETURN;
  END process_attr_groups;

  /*This procedure is used to do final processing of the attribute groups.
  	Used in the interface and API flow.
  	p_ag_tbl        IN OUT NOCOPY Attribute groups plsql table
  	x_return_status OUT NOCOPY parameter that returns the status*/
  PROCEDURE Process_ag
       (p_ag_tbl         IN OUT NOCOPY ego_metadata_pub.ego_attr_groups_tbl,
        x_return_status OUT NOCOPY VARCHAR2, x_return_msg OUT NOCOPY VARCHAR2)
  IS
    x_ag_id      NUMBER;
    x_errorcode  NUMBER;
    x_msg_count  NUMBER;
    x_msg_data   VARCHAR2(2000);

    lv_proc VARCHAR2(30) := 'Process_ag';
  BEGIN
    write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Entering Process_ag');

    x_return_status := G_RET_STS_SUCCESS;

    Common_ag_validations(p_ag_tbl => p_ag_tbl,x_return_status => x_return_status, x_return_msg => x_return_msg); IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN RETURN; END IF;

    handle_null_ag(p_ag_tbl => p_ag_tbl,x_return_status => x_return_status, x_return_msg => x_return_msg); IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN RETURN; END IF;

    FOR i IN p_ag_tbl.FIRST.. p_ag_tbl.LAST LOOP
      IF (P_ag_tbl(i).process_status = G_PROCESS_RECORD
          AND P_ag_tbl(i).transaction_type = 'CREATE') THEN
        write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Create AG');

        ego_ext_fwk_pub.Create_attribute_group(p_api_version => 1.0
        									   ,p_application_id => g_ego_application_id
        									   ,p_attr_group_type => P_ag_tbl(i).attr_group_type
        									   ,p_internal_name => P_ag_tbl(i).attr_group_name
        									   ,p_display_name => P_ag_tbl(i).attr_group_disp_name
        									   ,p_attr_group_desc => P_ag_tbl(i).description
        									   ,p_security_type => 'P' -- we always use PUBLIC for now
                                               ,p_multi_row_attrib_group => P_ag_tbl(i).multi_row
                                               ,p_variant_attrib_group => P_ag_tbl(i).variant
                                               ,p_num_of_cols => P_ag_tbl(i).num_of_cols
                                               ,p_num_of_rows => P_ag_tbl(i).num_of_rows
                                               ,p_owning_company_id => -100
                                               ,p_region_code => NULL
                                               ,p_view_privilege_id => NULL
                                               ,p_edit_privilege_id => NULL
                                               ,p_business_event_flag => NULL
                                               ,p_pre_business_event_flag => NULL
                                               ,p_owner => G_USER_ID
                                               ,p_lud => SYSDATE
                                               ,p_init_msg_list => fnd_api.g_false
                                               ,p_commit => fnd_api.g_false
                                               ,x_attr_group_id => x_ag_id
                                               ,x_return_status => x_return_status
                                               ,x_errorcode => x_errorcode
                                               ,x_msg_count => x_msg_count
                                               ,x_msg_data => x_msg_data);

        IF (x_return_status = G_RET_STS_SUCCESS) THEN
          P_ag_tbl(i).attr_group_id := x_ag_id;

          P_ag_tbl(i).process_status := G_SUCCESS_RECORD;
        ELSIF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
          x_return_msg := x_msg_data;
          RETURN;
        ELSE
          write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - Err_msg_TID: '||P_ag_tbl(i).transaction_id||' (AG) = ('||P_ag_tbl(i).attr_group_name||'). ' ||'Error in creating AG');

          P_ag_tbl(i).process_status := G_ERROR_RECORD;

          G_TOKEN_TABLE(1).Token_Name   :=  'Entity_Name';
          G_TOKEN_TABLE(1).Token_Value  :=  G_ENTITY_AG;
          G_TOKEN_TABLE(2).Token_Name   :=  'Transaction_Type';
          G_TOKEN_TABLE(2).Token_Value  :=  P_ag_tbl(i).transaction_type;
          G_TOKEN_TABLE(3).Token_Name   :=  'Package_Name';
          G_TOKEN_TABLE(3).Token_Value  :=  'ego_ext_fwk_pub';
          G_TOKEN_TABLE(4).Token_Name   :=  'Proc_Name';
          G_TOKEN_TABLE(4).Token_Value  :=  'Create_attribute_group';

          error_handler.Add_error_message(p_message_name => 'EGO_ENTITY_API_FAILED',p_application_id => 'EGO',
                                          p_token_tbl => g_token_table,p_message_type => G_RET_STS_ERROR,
                                          p_row_identifier => P_ag_tbl(i).transaction_id,
                                          p_entity_code => G_ENTITY_AG,p_table_name => G_ENTITY_AG_TAB);

          error_handler.Add_error_message(p_message_text => x_msg_data,p_application_id => 'EGO',
                                          p_token_tbl => g_token_table,p_message_type => G_RET_STS_ERROR,
                                          p_row_identifier => P_ag_tbl(i).transaction_id,
                                          p_entity_code => G_ENTITY_AG,p_table_name => G_ENTITY_AG_TAB);


          G_TOKEN_TABLE.DELETE;
        END IF;
      ELSIF (P_ag_tbl(i).process_status = G_PROCESS_RECORD
             AND P_ag_tbl(i).transaction_type = 'UPDATE') THEN
        write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Update AG');

        ego_ext_fwk_pub.Update_attribute_group(p_api_version => 1.0
        									   ,p_application_id => g_ego_application_id
        									   ,p_attr_group_type => P_ag_tbl(i).attr_group_type
        									   ,p_internal_name => P_ag_tbl(i).attr_group_name
        									   ,p_display_name => P_ag_tbl(i).attr_group_disp_name
        									   ,p_attr_group_desc => P_ag_tbl(i).description
        									   ,p_security_type => 'P' -- we always use PUBLIC for now
                                               /*Changes made for bug 9719202*/
        									   ,p_multi_row_attrib_group => null--P_ag_tbl(i).multi_row
                                               ,p_variant_attrib_group => null--P_ag_tbl(i).variant
                                               ,p_num_of_cols => P_ag_tbl(i).num_of_cols
                                               ,p_num_of_rows => P_ag_tbl(i).num_of_rows
                                               /*End of comment for bug 9719202*/
                                               ,p_owning_company_id => -100
                                               ,p_owner => G_USER_ID
                                               ,p_commit => fnd_api.g_false
                                               ,x_return_status => x_return_status
                                               ,x_errorcode => x_errorcode
                                               ,x_msg_count => x_msg_count
                                               ,x_msg_data => x_msg_data);

        IF (x_return_status = G_RET_STS_SUCCESS) THEN
          P_ag_tbl(i).process_status := g_success_record;
        ELSIF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
          x_return_msg := x_msg_data;
          RETURN;
        ELSE
          write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - Err_msg_TID: '||P_ag_tbl(i).transaction_id||' (AG) = ('||P_ag_tbl(i).attr_group_name||'). ' ||'Error in updating AG');

          P_ag_tbl(i).process_status := G_ERROR_RECORD;

          G_TOKEN_TABLE(1).Token_Name   :=  'Entity_Name';
          G_TOKEN_TABLE(1).Token_Value  :=  G_ENTITY_AG;
          G_TOKEN_TABLE(2).Token_Name   :=  'Transaction_Type';
          G_TOKEN_TABLE(2).Token_Value  :=  P_ag_tbl(i).transaction_type;
          G_TOKEN_TABLE(3).Token_Name   :=  'Package_Name';
          G_TOKEN_TABLE(3).Token_Value  :=  'ego_ext_fwk_pub';
          G_TOKEN_TABLE(4).Token_Name   :=  'Proc_Name';
          G_TOKEN_TABLE(4).Token_Value  :=  'Update_attribute_group';

          error_handler.Add_error_message(p_message_name => 'EGO_ENTITY_API_FAILED',p_application_id => 'EGO',
                                          p_token_tbl => g_token_table,p_message_type => G_RET_STS_ERROR,
                                          p_row_identifier => P_ag_tbl(i).transaction_id,
                                          p_entity_code => G_ENTITY_AG,p_table_name => G_ENTITY_AG_TAB);

          error_handler.Add_error_message(p_message_text => x_msg_data,p_application_id => 'EGO',
                                          p_token_tbl => g_token_table,p_message_type => G_RET_STS_ERROR,
                                          p_row_identifier => P_ag_tbl(i).transaction_id,
                                          p_entity_code => G_ENTITY_AG,p_table_name => G_ENTITY_AG_TAB);

          G_TOKEN_TABLE.DELETE;
        END IF;
      ELSIF (P_ag_tbl(i).process_status = G_PROCESS_RECORD
             AND P_ag_tbl(i).transaction_type = 'DELETE') THEN
        write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Delete AG');

        ego_ext_fwk_pub.Delete_attribute_group(p_api_version => 1.0
        									   ,p_application_id => g_ego_application_id
        									   ,p_attr_group_type => P_ag_tbl(i).attr_group_type
        									   ,p_attr_group_name => P_ag_tbl(i).attr_group_name
        									   ,p_commit => fnd_api.g_false
        									   ,x_return_status => x_return_status
        									   ,x_errorcode => x_errorcode
        									   ,x_msg_count => x_msg_count
        									   ,x_msg_data => x_msg_data);

        IF (x_return_status = G_RET_STS_SUCCESS) THEN
          P_ag_tbl(i).process_status := g_success_record;
        ELSIF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
          x_return_msg := x_msg_data;
          RETURN;
        ELSE
          write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - Err_msg_TID: '||P_ag_tbl(i).transaction_id||' (AG) = ('||P_ag_tbl(i).attr_group_name||'). ' ||'Error in deleting AG');

          P_ag_tbl(i).process_status := G_ERROR_RECORD;

          G_TOKEN_TABLE(1).Token_Name   :=  'Entity_Name';
          G_TOKEN_TABLE(1).Token_Value  :=  G_ENTITY_AG;
          G_TOKEN_TABLE(2).Token_Name   :=  'Transaction_Type';
          G_TOKEN_TABLE(2).Token_Value  :=  P_ag_tbl(i).transaction_type;
          G_TOKEN_TABLE(3).Token_Name   :=  'Package_Name';
          G_TOKEN_TABLE(3).Token_Value  :=  'ego_ext_fwk_pub';
          G_TOKEN_TABLE(4).Token_Name   :=  'Proc_Name';
          G_TOKEN_TABLE(4).Token_Value  :=  'Delete_attribute_group';

          error_handler.Add_error_message(p_message_name => 'EGO_ENTITY_API_FAILED',p_application_id => 'EGO',
                                          p_token_tbl => g_token_table,p_message_type => G_RET_STS_ERROR,
                                          p_row_identifier => P_ag_tbl(i).transaction_id,
                                          p_entity_code => G_ENTITY_AG,p_table_name => G_ENTITY_AG_TAB);

          error_handler.Add_error_message(p_message_text => x_msg_data,p_application_id => 'EGO',
                                          p_token_tbl => g_token_table,p_message_type => G_RET_STS_ERROR,
                                          p_row_identifier => P_ag_tbl(i).transaction_id,
                                          p_entity_code => G_ENTITY_AG,p_table_name => G_ENTITY_AG_TAB);

          G_TOKEN_TABLE.DELETE;
        END IF;
      END IF;
    END LOOP;

    IF (G_COMMIT = true AND G_FLOW_TYPE = G_EGO_MD_API) THEN
      write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'COMMIT issed after AG Processing');

      COMMIT;
    END IF;

    write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Exit Process_ag');
  EXCEPTION
    WHEN OTHERS THEN
      write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Process_ag Exception when others'||SQLERRM);

      x_return_status := G_RET_STS_UNEXP_ERROR;

      x_return_msg := 'ego_ag_bulkload_pvt.Process_ag - '||SQLERRM;

      RETURN;
  END Process_ag;

  /*This procedure is used to do final processing of the attribute group data level.
  	Used in the interface and API flow.
  	p_agdl_tbl        IN OUT NOCOPY Attribute group data level plsql table
  	x_return_status OUT NOCOPY parameter that returns the status*/
  PROCEDURE Process_dl
       (p_agdl_tbl       IN OUT NOCOPY ego_metadata_pub.ego_attr_groups_dl_tbl,
        x_return_status OUT NOCOPY VARCHAR2, x_return_msg OUT NOCOPY VARCHAR2)
  IS
    x_msg_count  NUMBER;
    x_msg_data   VARCHAR2(2000);
    lv_count 	 NUMBER := 0;
    lv_proc VARCHAR2(30) := 'Process_dl';
  BEGIN
    write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Entering Process_dl');

    x_return_status := G_RET_STS_SUCCESS;

    common_dl_validations(p_agdl_tbl => p_agdl_tbl,x_return_status => x_return_status, x_return_msg => x_return_msg); IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN RETURN; END IF;

    handle_null_dl(p_agdl_tbl => p_agdl_tbl,x_return_status => x_return_status, x_return_msg => x_return_msg); IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN RETURN; END IF;

    FOR i IN p_agdl_tbl.FIRST.. p_agdl_tbl.LAST LOOP
      IF (P_agdl_tbl(i).process_status = G_PROCESS_RECORD AND P_agdl_tbl(i).transaction_type IN (G_OPR_CREATE,G_OPR_UPDATE)) THEN

      /*Check for invalid combination of business entity*/
    		IF (p_agdl_tbl(i).data_level_name = G_DL_ITEM_LEVEL) THEN
	    		DECLARE
	    		lv_count NUMBER := 0;
	    		BEGIN
	    			SELECT count(1) INTO lv_count
                    FROM   EGO_ATTR_GROUP_DL eagdl
                    WHERE  eagdl.attr_group_id = p_agdl_tbl(i).attr_group_id
                    AND eagdl.data_level_id IN (SELECT data_level_id FROM ego_data_level_b
							  				   WHERE data_level_name IN (G_DL_ITEM_REV_LEVEL,G_DL_ITEM_ORG)
											   AND attr_group_type = G_EGO_ITEMMGMT_GROUP
											   AND application_id = G_EGO_APPLICATION_ID
											  );

					IF (lv_count > 0) THEN
						p_agdl_tbl(i).process_status := G_ERROR_RECORD;

				        x_return_status := G_RET_STS_ERROR;

				      	write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - Err_msg_TID: '||p_agdl_tbl(i).transaction_id
				      	||' (AG,DL) = ('||p_agdl_tbl(i).attr_group_name||','||p_agdl_tbl(i).data_level_name||'). '
				      	||'The combination of Business Entities choosen is Invalid for Item Level.');

				        error_handler.Add_error_message(p_message_name => 'EGO_EF_DL_INVALID_COMB',p_application_id => 'EGO',
				                                                  p_token_tbl => g_token_table,p_message_type => G_RET_STS_ERROR,
				                                                  p_row_identifier => p_agdl_tbl(i).transaction_id,
				                                                  p_entity_code => G_ENTITY_DL,p_table_name => G_ENTITY_DL_TAB);
					END IF;
			  END;
    		ELSIF (p_agdl_tbl(i).data_level_name = G_DL_ITEM_REV_LEVEL) THEN
	    		DECLARE
	    		lv_count NUMBER := 0;
	    		BEGIN
	    			SELECT count(1) INTO lv_count
                    FROM   EGO_ATTR_GROUP_DL eagdl
                    WHERE  eagdl.attr_group_id = p_agdl_tbl(i).attr_group_id
                    AND eagdl.data_level_id IN (SELECT data_level_id FROM ego_data_level_b
							  				   WHERE data_level_name IN (G_DL_ITEM_LEVEL,G_DL_ITEM_ORG)
											   AND attr_group_type = G_EGO_ITEMMGMT_GROUP
											   AND application_id = G_EGO_APPLICATION_ID
											  );

					IF (lv_count > 0) THEN
						p_agdl_tbl(i).process_status := G_ERROR_RECORD;

				        x_return_status := G_RET_STS_ERROR;

				      	write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - Err_msg_TID: '||p_agdl_tbl(i).transaction_id
				      	||' (AG,DL) = ('||p_agdl_tbl(i).attr_group_name||','||p_agdl_tbl(i).data_level_name||'). '
				      	||'The combination of Business Entities choosen is Invalid');

				        error_handler.Add_error_message(p_message_name => 'EGO_EF_DL_INVALID_COMB',p_application_id => 'EGO',
				                                                  p_token_tbl => g_token_table,p_message_type => G_RET_STS_ERROR,
				                                                  p_row_identifier => p_agdl_tbl(i).transaction_id,
				                                                  p_entity_code => G_ENTITY_DL,p_table_name => G_ENTITY_DL_TAB);
					END IF;
			  END;
    		ELSIF (p_agdl_tbl(i).data_level_name = G_DL_ITEM_ORG) THEN
	    		DECLARE
	    		lv_count NUMBER := 0;
	    		BEGIN
	    			SELECT count(1) INTO lv_count
                    FROM   EGO_ATTR_GROUP_DL eagdl
                    WHERE  eagdl.attr_group_id = p_agdl_tbl(i).attr_group_id
                    AND eagdl.data_level_id IN (SELECT data_level_id FROM ego_data_level_b
							  				   WHERE data_level_name IN (G_DL_ITEM_LEVEL,G_DL_ITEM_REV_LEVEL)
											   AND attr_group_type = G_EGO_ITEMMGMT_GROUP
											   AND application_id = G_EGO_APPLICATION_ID
											  );

					IF (lv_count > 0) THEN
						p_agdl_tbl(i).process_status := G_ERROR_RECORD;

				        x_return_status := G_RET_STS_ERROR;

				      	write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - Err_msg_TID: '||p_agdl_tbl(i).transaction_id
				      	||' (AG,DL) = ('||p_agdl_tbl(i).attr_group_name||','||p_agdl_tbl(i).data_level_name||'). '
				      	||'The combination of Business Entities choosen is Invalid.');

				        error_handler.Add_error_message(p_message_name => 'EGO_EF_DL_INVALID_COMB',p_application_id => 'EGO',
				                                                  p_token_tbl => g_token_table,p_message_type => G_RET_STS_ERROR,
				                                                  p_row_identifier => p_agdl_tbl(i).transaction_id,
				                                                  p_entity_code => G_ENTITY_DL,p_table_name => G_ENTITY_DL_TAB);
					END IF;
			  END;
    		END IF;


       /*Check to see if the Business entity is already enabled*/
        SELECT count(1) INTO lv_count
        FROM   EGO_ATTR_GROUP_DL
        WHERE  attr_group_id = P_agdl_tbl(i).attr_group_id
        AND data_level_id = P_agdl_tbl(i).data_level_id;

        IF (lv_count > 0 AND P_agdl_tbl(i).transaction_type = G_OPR_CREATE) THEN
        	P_agdl_tbl(i).process_status := G_ERROR_RECORD;

        	write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - Err_msg_TID: '||p_agdl_tbl(i).transaction_id||' (AG,DL) = ('
        	||p_agdl_tbl(i).attr_group_name||','||p_agdl_tbl(i).data_level_name||'). '
        	||'Business entity is already enabled for the attribute group.');

        	error_handler.Add_error_message(p_message_name => 'EGO_EF_DL_AG_EXISTS',p_application_id => 'EGO',
	                                          p_token_tbl => g_token_table,p_message_type => G_RET_STS_ERROR,
	                                          p_row_identifier => P_agdl_tbl(i).transaction_id,
	                                          p_entity_code => G_ENTITY_DL,p_table_name => G_ENTITY_DL_tab);
        ELSIF (P_agdl_tbl(i).process_status = G_PROCESS_RECORD) THEN
	        ego_ext_fwk_pub.Sync_dl_assoc(p_api_version => 1.0,
	        							  p_init_msg_list => fnd_api.g_false,
	                                      p_commit => fnd_api.g_false,
	                                      p_transaction_type => P_agdl_tbl(i).transaction_type,
	                                      p_attr_group_id => P_agdl_tbl(i).attr_group_id,
	                                      p_application_id => g_ego_application_id,
	                                      p_attr_group_type => P_agdl_tbl(i).attr_group_type,
	                                      p_attr_group_name => P_agdl_tbl(i).attr_group_name,
	                                      p_data_level_id => P_agdl_tbl(i).data_level_id,
	                                      p_data_level_name => P_agdl_tbl(i).data_level_name,
	                                      p_defaulting => P_agdl_tbl(i).defaulting,
	                                      p_defaulting_name => P_agdl_tbl(i).defaulting_name,
	                                      p_view_priv_id => P_agdl_tbl(i).view_privilege_id,
	                                      p_view_priv_name => P_agdl_tbl(i).view_privilege_name,
	                                      p_user_view_priv_name => P_agdl_tbl(i).user_view_priv_name,
	                                      p_edit_priv_id => P_agdl_tbl(i).edit_privilege_id,
	                                      p_edit_priv_name => P_agdl_tbl(i).edit_privilege_name,
	                                      p_user_edit_priv_name => P_agdl_tbl(i).user_edit_priv_name,
	                                      p_raise_pre_event => P_agdl_tbl(i).pre_business_event_flag,
	                                      p_raise_post_event => P_agdl_tbl(i).business_event_flag,
	                                      p_last_updated_by => G_USER_ID,
	                                      p_last_update_date => SYSDATE,
	                                      x_return_status => x_return_status,
	                                      x_msg_count => x_msg_count,
	                                      x_msg_data => x_msg_data);

	        IF (x_return_status = G_RET_STS_SUCCESS) THEN
	          P_agdl_tbl(i).process_status := g_success_record;
	        ELSIF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
	          x_return_msg := x_msg_data;
	          RETURN;
	        ELSE

	          write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - Err_msg_TID: '||p_agdl_tbl(i).transaction_id||' (AG,DL) = ('||p_agdl_tbl(i).attr_group_name||','||p_agdl_tbl(i).data_level_name||'). ' ||'Error in sync of DL - ' ||x_msg_data);

	          P_agdl_tbl(i).process_status := G_ERROR_RECORD;

	          G_TOKEN_TABLE(1).Token_Name   :=  'Entity_Name';
	          G_TOKEN_TABLE(1).Token_Value  :=  G_ENTITY_DL;
	          G_TOKEN_TABLE(2).Token_Name   :=  'Transaction_Type';
	          G_TOKEN_TABLE(2).Token_Value  :=  P_agdl_tbl(i).transaction_type;
	          G_TOKEN_TABLE(3).Token_Name   :=  'Package_Name';
	          G_TOKEN_TABLE(3).Token_Value  :=  'ego_ext_fwk_pub';
	          G_TOKEN_TABLE(4).Token_Name   :=  'Proc_Name';
	          G_TOKEN_TABLE(4).Token_Value  :=  'Sync_dl_assoc';

	          error_handler.Add_error_message(p_message_name => 'EGO_ENTITY_API_FAILED',p_application_id => 'EGO',
	                                          p_token_tbl => g_token_table,p_message_type => G_RET_STS_ERROR,
	                                          p_row_identifier => P_agdl_tbl(i).transaction_id,
	                                          p_entity_code => G_ENTITY_DL,p_table_name => G_ENTITY_DL_tab);

	          error_handler.Add_error_message(p_message_text => x_msg_data,p_application_id => 'EGO',
	                                          p_token_tbl => g_token_table,p_message_type => G_RET_STS_ERROR,
	                                          p_row_identifier => P_agdl_tbl(i).transaction_id,
	                                          p_entity_code => G_ENTITY_DL,p_table_name => G_ENTITY_DL_tab);

	          G_TOKEN_TABLE.DELETE;
	        END IF;
	  	END IF;
      ELSIF (P_agdl_tbl(i).process_status = G_PROCESS_RECORD AND P_agdl_tbl(i).transaction_type = G_OPR_DELETE) THEN
      	BEGIN
      		DELETE FROM EGO_ATTR_GROUP_DL
			WHERE attr_group_id = P_agdl_tbl(i).attr_group_id
			AND data_level_id = P_agdl_tbl(i).data_level_id;

      	EXCEPTION
      		WHEN OTHERS THEN
      			write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Exception when others');

              	x_return_status := G_RET_STS_UNEXP_ERROR;

            	x_return_msg := 'ego_ag_bulkload_pvt.Process_dl - '||SQLERRM;
      	END;
      END IF;

      lv_count := 0;
    END LOOP;

    IF (G_COMMIT = true AND G_FLOW_TYPE = G_EGO_MD_API) THEN
      write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'COMMIT issued for DL');

      COMMIT;
    END IF;

    write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Exit Process_dl');
  EXCEPTION
    WHEN OTHERS THEN
      write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Process_dl Exception when others'||SQLERRM);

      x_return_status := G_RET_STS_UNEXP_ERROR;

      x_return_msg := 'ego_ag_bulkload_pvt.Process_dl - '||SQLERRM;

      RETURN;
  END process_dl;

  /*This is the main procedure called to import attributes.
  	Used in the API flow.
  	p_attr_tbl        IN OUT NOCOPY Attributes plsql table
  	p_commit        IN Pass true to commit within the API
  	x_return_status OUT NOCOPY parameter that returns the status*/
  PROCEDURE process_attribute
       (p_attr_tbl       IN OUT NOCOPY ego_metadata_pub.ego_attr_group_cols_tbl,
        p_commit         IN BOOLEAN DEFAULT true,
        x_return_status OUT NOCOPY VARCHAR2, x_return_msg OUT NOCOPY VARCHAR2)
  IS

    lv_proc VARCHAR2(30) := 'process_attribute';
  BEGIN
    write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Entering process_attribute');

    x_return_status := G_RET_STS_SUCCESS;

    error_handler.Set_bo_identifier(G_BO_IDENTIFIER_AG);

    IF(p_attr_tbl.COUNT <> 0) THEN

	    G_COMMIT := p_commit;

	    G_FLOW_TYPE := g_ego_md_api;

	    /*Sets the EGO application ID*/
	    SELECT application_id
	    INTO   g_ego_application_id
	    FROM   fnd_application
	    WHERE  application_short_name = 'EGO';

	    /*Calls Additional Validations*/
	    Additional_attr_validations(p_attr_tbl,x_return_status, x_return_msg); IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN RETURN; END IF;

	    /*Send the AG table for processing*/
	    Process_attr(p_attr_tbl,x_return_status, x_return_msg); IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN RETURN; END IF;
    END IF;
    write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Exit process_attribute');
  EXCEPTION
    WHEN OTHERS THEN
      write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'process_attribute Exception when others'||SQLERRM);

      x_return_status := G_RET_STS_UNEXP_ERROR;

      x_return_msg := 'ego_ag_bulkload_pvt.process_attribute - '||SQLERRM;

      RETURN;
  END process_attribute;

  /*This procedure is used to do final processing of the attributes.
  	Used in the interface and API flow.
  	p_attr_tbl        IN OUT NOCOPY Attributes plsql table
  	x_return_status OUT NOCOPY parameter that returns the status*/
  PROCEDURE Process_attr
       (p_attr_tbl       IN OUT NOCOPY ego_metadata_pub.ego_attr_group_cols_tbl,
        x_return_status OUT NOCOPY VARCHAR2, x_return_msg OUT NOCOPY VARCHAR2)
  IS
    x_errorcode  NUMBER;
    x_msg_count  NUMBER;
    x_msg_data   VARCHAR2(2000);

    lv_proc VARCHAR2(30) := 'Process_attr';
  BEGIN
    write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Entering Process_attr');

    x_return_status := G_RET_STS_SUCCESS;

    common_attr_validations(p_attr_tbl => p_attr_tbl,x_return_status => x_return_status, x_return_msg => x_return_msg); IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN RETURN; END IF;
    handle_null_attr(p_attr_tbl => p_attr_tbl,x_return_status => x_return_status, x_return_msg => x_return_msg); IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN RETURN; END IF;

    FOR i IN p_attr_tbl.FIRST.. p_attr_tbl.LAST LOOP
      IF (P_attr_tbl(i).process_status = G_PROCESS_RECORD
          AND P_attr_tbl(i).transaction_type = 'CREATE') THEN
        write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Create Attribute');

        ego_ext_fwk_pub.Create_attribute(p_api_version => 1.0
        								 ,p_application_id => P_attr_tbl(i).application_id
        								 ,p_attr_group_type => P_attr_tbl(i).attr_group_type
        								 ,p_attr_group_name => P_attr_tbl(i).attr_group_name
        								 ,p_internal_name => P_attr_tbl(i).internal_name
        								 ,p_display_name => P_attr_tbl(i).display_name
        								 ,p_description => P_attr_tbl(i).description
        								 ,p_sequence => P_attr_tbl(i).SEQUENCE
        								 ,p_data_type => P_attr_tbl(i).data_type
        								 ,p_required => P_attr_tbl(i).required_flag
        								 ,p_searchable => P_attr_tbl(i).search_flag
        								 ,p_column => P_attr_tbl(i).application_column_name
        								 ,p_is_column_indexed => NULL
        								 ,p_value_set_id => P_attr_tbl(i).flex_value_set_id
        								 ,p_info_1 => P_attr_tbl(i).info_1
        								 ,p_default_value => P_attr_tbl(i).default_value
        								 ,p_unique_key_flag => P_attr_tbl(i).unique_key_flag
        								 ,p_enabled => P_attr_tbl(i).enabled_flag
        								 ,p_display => P_attr_tbl(i).display_code
        								 ,p_uom_class => P_attr_tbl(i).uom_class
        								 ,p_owner => G_USER_ID
        								 ,p_lud => SYSDATE
        								 ,p_init_msg_list => NULL
        								 ,p_commit => fnd_api.g_false
        								 ,x_return_status => x_return_status
        								 ,x_errorcode => x_errorcode
        								 ,x_msg_count => x_msg_count
        								 ,x_msg_data => x_msg_data);

        IF (x_return_status = G_RET_STS_SUCCESS) THEN
          P_attr_tbl(i).process_status := g_success_record;
        ELSIF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
          x_return_msg := x_msg_data;
          RETURN;
        ELSE
          write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - Err_msg_TID: '||P_attr_tbl(i).transaction_id||' (AG,ATTR) = ('||P_attr_tbl(i).attr_group_name||','||P_attr_tbl(i).internal_name||'). ' ||'Error in creating attribute');

          P_attr_tbl(i).process_status := G_ERROR_RECORD;

          G_TOKEN_TABLE(1).Token_Name   :=  'Entity_Name';
          G_TOKEN_TABLE(1).Token_Value  :=  G_ENTITY_ATTR;
          G_TOKEN_TABLE(2).Token_Name   :=  'Transaction_Type';
          G_TOKEN_TABLE(2).Token_Value  :=  P_attr_tbl(i).transaction_type;
          G_TOKEN_TABLE(3).Token_Name   :=  'Package_Name';
          G_TOKEN_TABLE(3).Token_Value  :=  'ego_ext_fwk_pub';
          G_TOKEN_TABLE(4).Token_Name   :=  'Proc_Name';
          G_TOKEN_TABLE(4).Token_Value  :=  'Create_attribute';

          error_handler.Add_error_message(p_message_name => 'EGO_ENTITY_API_FAILED',p_application_id => 'EGO',
                                          p_token_tbl => g_token_table,p_message_type => G_RET_STS_ERROR,
                                          p_row_identifier => P_attr_tbl(i).transaction_id,
                                          p_entity_code => G_ENTITY_ATTR,p_table_name => G_ENTITY_ATTR_TAB);

          error_handler.Add_error_message(p_message_text => x_msg_data,p_application_id => 'EGO',
                                          p_token_tbl => g_token_table,p_message_type => G_RET_STS_ERROR,
                                          p_row_identifier => P_attr_tbl(i).transaction_id,
                                          p_entity_code => G_ENTITY_ATTR,p_table_name => G_ENTITY_ATTR_TAB);

          G_TOKEN_TABLE.DELETE;
        END IF;
      ELSIF (P_attr_tbl(i).process_status = G_PROCESS_RECORD
             AND P_attr_tbl(i).transaction_type = 'UPDATE') THEN
        write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Update Attribute');

        ego_ext_fwk_pub.Update_attribute(p_api_version => 1.0
        								 ,p_application_id => P_attr_tbl(i).application_id
        								 ,p_attr_group_type => P_attr_tbl(i).attr_group_type
        								 ,p_attr_group_name => P_attr_tbl(i).attr_group_name
        								 ,p_internal_name => P_attr_tbl(i).internal_name
        								 ,p_display_name => P_attr_tbl(i).display_name
        								 ,p_description => P_attr_tbl(i).description
        								 ,p_sequence => P_attr_tbl(i).SEQUENCE
        								 ,p_required => P_attr_tbl(i).required_flag
        								 ,p_searchable => P_attr_tbl(i).search_flag
        								 ,p_column => P_attr_tbl(i).application_column_name
        								 ,p_value_set_id => P_attr_tbl(i).flex_value_set_id
        								 ,p_info_1 => P_attr_tbl(i).info_1
        								 ,p_default_value => P_attr_tbl(i).default_value
        								 ,p_unique_key_flag => P_attr_tbl(i).unique_key_flag
        								 ,p_enabled => P_attr_tbl(i).enabled_flag
        								 ,p_display => P_attr_tbl(i).display_code
        								 ,p_owner => G_USER_ID
        								 ,p_lud => SYSDATE
        								 ,p_init_msg_list => NULL
        								 ,p_commit => fnd_api.g_false
        								 ,p_is_nls_mode => NULL
        								 ,p_uom_class => P_attr_tbl(i).uom_class
        								 ,x_return_status => x_return_status
        								 ,x_errorcode => x_errorcode
        								 ,x_msg_count => x_msg_count
        								 ,x_msg_data => x_msg_data);

        IF (x_return_status = G_RET_STS_SUCCESS) THEN
          P_attr_tbl(i).process_status := g_success_record;
        ELSIF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
          x_return_msg := x_msg_data;
          RETURN;
        ELSE
          write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - Err_msg_TID: '||P_attr_tbl(i).transaction_id||' (AG,ATTR) = ('||P_attr_tbl(i).attr_group_name||','||P_attr_tbl(i).internal_name||'). ' ||'Error in updating attribute');

          P_attr_tbl(i).process_status := G_ERROR_RECORD;

          G_TOKEN_TABLE(1).Token_Name   :=  'Entity_Name';
          G_TOKEN_TABLE(1).Token_Value  :=  G_ENTITY_ATTR;
          G_TOKEN_TABLE(2).Token_Name   :=  'Transaction_Type';
          G_TOKEN_TABLE(2).Token_Value  :=  P_attr_tbl(i).transaction_type;
          G_TOKEN_TABLE(3).Token_Name   :=  'Package_Name';
          G_TOKEN_TABLE(3).Token_Value  :=  'ego_ext_fwk_pub';
          G_TOKEN_TABLE(4).Token_Name   :=  'Proc_Name';
          G_TOKEN_TABLE(4).Token_Value  :=  'Update_attribute';

          error_handler.Add_error_message(p_message_name => 'EGO_ENTITY_API_FAILED',p_application_id => 'EGO',
                                          p_token_tbl => g_token_table,p_message_type => G_RET_STS_ERROR,
                                          p_row_identifier => P_attr_tbl(i).transaction_id,
                                          p_entity_code => G_ENTITY_ATTR,p_table_name => G_ENTITY_ATTR_TAB);

          error_handler.Add_error_message(p_message_text => x_msg_data,p_application_id => 'EGO',
                                          p_token_tbl => g_token_table,p_message_type => G_RET_STS_ERROR,
                                          p_row_identifier => P_attr_tbl(i).transaction_id,
                                          p_entity_code => G_ENTITY_ATTR,p_table_name => G_ENTITY_ATTR_TAB);

          G_TOKEN_TABLE.DELETE;

        END IF;
      ELSIF (P_attr_tbl(i).process_status = G_PROCESS_RECORD
             AND P_attr_tbl(i).transaction_type = 'DELETE') THEN
        write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Delete Attribute');

        ego_ext_fwk_pub.Delete_attribute(p_api_version => 1.0
        								 ,p_application_id => P_attr_tbl(i).application_id
        								 ,p_attr_group_type => P_attr_tbl(i).attr_group_type
        								 ,p_attr_group_name => P_attr_tbl(i).attr_group_name
        								 ,p_attr_name => P_attr_tbl(i).internal_name
        								 ,p_init_msg_list => NULL
        								 ,p_commit => fnd_api.g_false
        								 ,x_return_status => x_return_status
        								 ,x_errorcode => x_errorcode
        								 ,x_msg_count => x_msg_count
        								 ,x_msg_data => x_msg_data);

        IF (x_return_status = G_RET_STS_SUCCESS) THEN
          P_attr_tbl(i).process_status := g_success_record;
        ELSIF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
          x_return_msg := x_msg_data;
          RETURN;
        ELSE
          write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - Err_msg_TID: '||P_attr_tbl(i).transaction_id||' (AG,ATTR) = ('||P_attr_tbl(i).attr_group_name||','||P_attr_tbl(i).internal_name||'). ' ||'Error is deleting attribute');

          P_attr_tbl(i).process_status := G_ERROR_RECORD;

          G_TOKEN_TABLE(1).Token_Name   :=  'Entity_Name';
          G_TOKEN_TABLE(1).Token_Value  :=  G_ENTITY_ATTR;
          G_TOKEN_TABLE(2).Token_Name   :=  'Transaction_Type';
          G_TOKEN_TABLE(2).Token_Value  :=  P_attr_tbl(i).transaction_type;
          G_TOKEN_TABLE(3).Token_Name   :=  'Package_Name';
          G_TOKEN_TABLE(3).Token_Value  :=  'ego_ext_fwk_pub';
          G_TOKEN_TABLE(4).Token_Name   :=  'Proc_Name';
          G_TOKEN_TABLE(4).Token_Value  :=  'Delete_attribute';

          error_handler.Add_error_message(p_message_name => 'EGO_ENTITY_API_FAILED',p_application_id => 'EGO',
                                          p_token_tbl => g_token_table,p_message_type => G_RET_STS_ERROR,
                                          p_row_identifier => P_attr_tbl(i).transaction_id,
                                          p_entity_code => G_ENTITY_ATTR,p_table_name => G_ENTITY_ATTR_TAB);

          error_handler.Add_error_message(p_message_text => x_msg_data,p_application_id => 'EGO',
                                          p_token_tbl => g_token_table,p_message_type => G_RET_STS_ERROR,
                                          p_row_identifier => P_attr_tbl(i).transaction_id,
                                          p_entity_code => G_ENTITY_ATTR,p_table_name => G_ENTITY_ATTR_TAB);

          G_TOKEN_TABLE.DELETE;
        END IF;
      END IF;
    END LOOP;

    IF (G_COMMIT = true AND G_FLOW_TYPE = G_EGO_MD_API) THEN
      write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'COMMIT issed after Attribute Processing');

      COMMIT;
    END IF;

    write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Exit Process_attr');
  EXCEPTION
    WHEN OTHERS THEN
      write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Process_attr Exception when others'||SQLERRM);

      x_return_status := G_RET_STS_UNEXP_ERROR;

      x_return_msg := 'ego_ag_bulkload_pvt.Process_attr - '||SQLERRM;

      RETURN;
  END Process_attr;

  /*This is the main procedure called to import attribute groups, data level and attributes
  	Used in the Interface flow.
  	p_set_process_id   IN   Set_Process_ID
  	x_return_status OUT NOCOPY parameter that returns the status*/
  PROCEDURE import_ag_intf
       (p_set_process_id    IN VARCHAR2,
        x_return_status     OUT NOCOPY VARCHAR2,
        x_return_msg        OUT NOCOPY VARCHAR2)
  IS
    /*Cursor to load plsql table from ego_attr_groups_interface table*/
    CURSOR c_ag IS
      SELECT *
      FROM   ego_attr_groups_interface
      WHERE  process_status = G_PROCESS_RECORD
      AND (p_set_process_id IS NULL OR set_process_id = p_set_process_id);
    /*Cursor to load plsql table from ego_attr_groups_dl_interface table*/
    CURSOR c_agdl IS
      SELECT *
      FROM   ego_attr_groups_dl_interface
      WHERE  process_status = G_PROCESS_RECORD
      AND (p_set_process_id IS NULL OR set_process_id = p_set_process_id);
    /*Cursor to load plsql table from ego_attr_group_cols_intf table*/
    CURSOR c_attr IS
      SELECT *
      FROM   ego_attr_group_cols_intf
      WHERE  process_status = G_PROCESS_RECORD
      AND (p_set_process_id IS NULL OR set_process_id = p_set_process_id);

    l_ego_ag_tbl    ego_metadata_pub.ego_attr_groups_tbl;
    l_ego_agdl_tbl  ego_metadata_pub.ego_attr_groups_dl_tbl;
    l_ego_attr_tbl  ego_metadata_pub.ego_attr_group_cols_tbl;

    lv_proc VARCHAR2(30) := 'import_ag_intf';
  BEGIN
    write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Entered import_ag_intf.');

    x_return_status := G_RET_STS_SUCCESS;

    error_handler.Set_bo_identifier(G_BO_IDENTIFIER_AG);

    G_FLOW_TYPE := G_EGO_MD_INTF;

    G_SET_PROCESS_ID := p_set_process_id;

    Initialize(x_return_status, x_return_msg); IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN RETURN; END IF;

    IF (G_AG_COUNT <> 0 OR G_DL_COUNT <> 0 OR G_ATTR_COUNT <> 0) THEN
	    Validate_transaction_type(x_return_status, x_return_msg); IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN RETURN; END IF;
	    IF (G_AG_COUNT <> 0 OR G_DL_COUNT <> 0) THEN
		    bulk_validate_attr_groups(x_return_status, x_return_msg); IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN RETURN; END IF;

		    write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Load and process AG');

		    /*Load PL/SQL tables for AG and then call processing method*/
		    OPEN c_ag;

		    LOOP
		      FETCH c_ag BULK COLLECT INTO l_ego_ag_tbl LIMIT 2000;

		      IF (l_ego_ag_tbl.COUNT <> 0) THEN

			      Process_ag(p_ag_tbl => l_ego_ag_tbl,x_return_status => x_return_status, x_return_msg => x_return_msg); IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN RETURN; END IF;

			      update_intf_attr_groups(p_ag_tbl => l_ego_ag_tbl,x_return_status => x_return_status, x_return_msg => x_return_msg); IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN RETURN; END IF;

			      COMMIT;
			  END IF;
		      EXIT WHEN l_ego_ag_tbl.COUNT < 2000;
		    END LOOP;

		    CLOSE c_ag;

		    write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'AG processed');

		    write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Load and process DL');

		    /*Load PL/SQL tables for DL and then call processing method*/
		    OPEN c_agdl;

		    LOOP
		      FETCH c_agdl BULK COLLECT INTO l_ego_agdl_tbl LIMIT 2000;

		      IF(l_ego_agdl_tbl.COUNT <> 0) THEN
			      Process_dl(p_agdl_tbl => l_ego_agdl_tbl,x_return_status => x_return_status, x_return_msg => x_return_msg); IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN RETURN; END IF;

			      update_intf_data_level(p_agdl_tbl => l_ego_agdl_tbl,x_return_status => x_return_status, x_return_msg => x_return_msg); IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN RETURN; END IF;

			      COMMIT;
		      END IF;
		      EXIT WHEN l_ego_agdl_tbl.COUNT < 2000;
		    END LOOP;

		    CLOSE c_agdl;

		    write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'DL Processed');

		    delete_ag_none_dl(x_return_status => x_return_status, x_return_msg => x_return_msg); IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN RETURN; END IF;
		END IF;

	    IF (G_ATTR_COUNT <> 0) THEN
		    bulk_validate_attribute(x_return_status, x_return_msg); IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN RETURN; END IF;

		    write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Load and process Attributes');

		    /*Load PL/SQL tables for Attributes and then call processing method*/
		    OPEN c_attr;

		    LOOP
		      FETCH c_attr BULK COLLECT INTO l_ego_attr_tbl LIMIT 2000;

		      IF (l_ego_attr_tbl.COUNT <> 0) THEN
			      Process_attr(p_attr_tbl => l_ego_attr_tbl,x_return_status => x_return_status, x_return_msg => x_return_msg); IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN RETURN; END IF;

			      update_intf_attribute(p_attr_tbl => l_ego_attr_tbl,x_return_status => x_return_status, x_return_msg => x_return_msg); IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN RETURN; END IF;

			      COMMIT;
			  END IF;
		      EXIT WHEN l_ego_attr_tbl.COUNT < 2000;
		    END LOOP;

		    CLOSE c_attr;

		    write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Processed Attributes');
		END IF;
  	END IF;
  	write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Exit import_ag_intf');
  EXCEPTION
    WHEN OTHERS THEN
      write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'import_ag_intf Exception when others'||SQLERRM);

      x_return_status := G_RET_STS_UNEXP_ERROR;

      x_return_msg := 'ego_ag_bulkload_pvt.import_ag_intf - '||SQLERRM;

      RETURN;
  END import_ag_intf;

  /*This procedure is used for value to ID conversion for Attribute group plsql tables.
  	Used in the API flow.
  	p_ag_tbl        IN OUT NOCOPY Attribute group plsql table
  	x_return_status OUT NOCOPY parameter that returns the status*/
  PROCEDURE Value_to_id_ag_tbl
       (p_ag_tbl         IN OUT NOCOPY ego_metadata_pub.ego_attr_groups_tbl,
        x_return_status OUT NOCOPY VARCHAR2, x_return_msg OUT NOCOPY VARCHAR2)
  IS
    lv_smt  NUMBER;

    lv_proc VARCHAR2(30) := 'Value_to_id_ag_tbl';
  BEGIN
    write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Entering Value_to_id_ag_tbl');

    x_return_status := G_RET_STS_SUCCESS;

    FOR i IN p_ag_tbl.FIRST.. p_ag_tbl.LAST LOOP
      IF (P_ag_tbl(i).process_status = G_PROCESS_RECORD) THEN
        lv_smt := 1;

        write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Statement 1');

        /*Sets the transaction_id*/
        SELECT mtl_system_items_interface_s.nextval
        INTO   P_ag_tbl(i).transaction_id
        FROM   dual;

        lv_smt := 2;

        write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Statement 2');

        /*Sets the Attribute ID if present for Update and Sync flow. If not present then flags an error EGO_AG_INVALID for UPDATE flow
and for sync flow updates the transaction type to CREATE*/
        IF ((P_ag_tbl(i).transaction_type = G_OPR_UPDATE
              OR P_ag_tbl(i).transaction_type = G_OPR_SYNC)
            AND P_ag_tbl(i).attr_group_id  IS NULL
            AND P_ag_tbl(i).attr_group_name  IS NOT NULL) THEN
          BEGIN
            SELECT attr_group_id,
                   'UPDATE'
            INTO   P_ag_tbl(i).attr_group_id,P_ag_tbl(i).transaction_type
            FROM   ego_fnd_dsc_flx_ctx_ext
            WHERE  application_id = g_ego_application_id
                   AND descriptive_flexfield_name = P_ag_tbl(i).attr_group_type
                   AND descriptive_flex_context_code = P_ag_tbl(i).attr_group_name;
          EXCEPTION
            WHEN no_data_found THEN
              IF (P_ag_tbl(i).transaction_type = G_OPR_SYNC) THEN
                P_ag_tbl(i).transaction_type := G_OPR_CREATE;
              ELSE
                write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - Err_msg_TID: '||P_ag_tbl(i).transaction_id||' (AG) = ('||P_ag_tbl(i).attr_group_name||'). ' ||'Attribute Group does not exist in the system');

                P_ag_tbl(i).process_status := G_ERROR_RECORD;

                x_return_status := G_RET_STS_ERROR;

                error_handler.Add_error_message(p_message_name => 'EGO_AG_INVALID',p_application_id => 'EGO',
                                                p_token_tbl => g_token_table,p_message_type => G_RET_STS_ERROR,
                                                p_row_identifier => P_ag_tbl(i).transaction_id,
                                                p_entity_code => G_ENTITY_AG,p_table_name => G_ENTITY_AG_TAB);
              END IF;
            WHEN OTHERS THEN
              write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Value_to_id_ag_tbl Exception when others smt 2');

              x_return_status := G_RET_STS_UNEXP_ERROR;

              x_return_msg := 'ego_ag_bulkload_pvt.Value_to_id_ag_tbl smt 2- '||SQLERRM;

      		  RETURN;
          END;
        END IF;
      END IF;
    END LOOP;

    write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Exit Value_to_id_ag_tbl');
  EXCEPTION
    WHEN OTHERS THEN
      write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Value_to_id_ag_tbl Exception when others'||SQLERRM);

      x_return_status := G_RET_STS_UNEXP_ERROR;

      x_return_msg := 'ego_ag_bulkload_pvt.Value_to_id_ag_tbl - '||SQLERRM;

      RETURN;
  END Value_to_id_ag_tbl;

  /*This procedure is used for value to ID conversion for Attribute group
    data level plsql tables. Used in the API flow.
    p_agdl_tbl      IN OUT NOCOPY Attribute group data level plsql table
  	x_return_status OUT NOCOPY parameter that returns the status*/
  PROCEDURE Value_to_id_dl_tbl
       (p_agdl_tbl       IN OUT NOCOPY ego_metadata_pub.ego_attr_groups_dl_tbl,
        x_return_status OUT NOCOPY VARCHAR2, x_return_msg OUT NOCOPY VARCHAR2)
  IS
    lv_smt   NUMBER;
    lv_flag  VARCHAR2(1);
    lv_proc VARCHAR2(30) := 'Value_to_id_dl_tbl';
  BEGIN
    write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Entering Value_to_id_dl_tbl');

    x_return_status := G_RET_STS_SUCCESS;

    FOR i IN p_agdl_tbl.FIRST.. p_agdl_tbl.LAST LOOP
      IF (P_agdl_tbl(i).process_status = G_PROCESS_RECORD) THEN
        lv_smt := 1;

        write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Statement 1');

        /*Sets the transaction_id*/
        SELECT mtl_system_items_interface_s.nextval
        INTO   P_agdl_tbl(i).transaction_id
        FROM   dual;

        lv_smt := 2;

        write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Statement 2');

        /*Sets the View Privilege ID and returns an error is it doesnt existing in the system*/
        IF (P_agdl_tbl(i).view_privilege_id  IS NULL
            AND P_agdl_tbl(i).view_privilege_name IS NOT NULL
            AND P_agdl_tbl(i).view_privilege_name <> G_NULL_CHAR) THEN
          BEGIN
            SELECT function_id
            INTO   P_agdl_tbl(i).view_privilege_id
            FROM   fnd_form_functions
            WHERE  function_name = P_agdl_tbl(i).view_privilege_name;
          EXCEPTION
            WHEN no_data_found THEN
              write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - Err_msg_TID: '||P_agdl_tbl(i).transaction_id||' (AG,DL,VS) = ('
              ||P_agdl_tbl(i).attr_group_name||','||P_agdl_tbl(i).data_level_name||','||P_agdl_tbl(i).view_privilege_name
              ||'). ' ||'View privilege does not exist in the system');

              P_agdl_tbl(i).process_status := G_ERROR_RECORD;

              x_return_status := G_RET_STS_ERROR;

              error_handler.Add_error_message(p_message_name => 'EGO_VIEW_PRIV_NOT_EXIST',
                                              p_application_id => 'EGO',p_token_tbl => g_token_table,
                                              p_message_type => G_RET_STS_ERROR,p_row_identifier => P_agdl_tbl(i).transaction_id,
                                              p_entity_code => G_ENTITY_DL,p_table_name => G_ENTITY_DL_tab);
            WHEN OTHERS THEN
              write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - Err_msg_TID: '||P_agdl_tbl(i).transaction_id||' (AG,DL,VS) = ('
              ||P_agdl_tbl(i).attr_group_name||','||P_agdl_tbl(i).data_level_name||','||P_agdl_tbl(i).view_privilege_name||'). '
              ||'Value_to_id_dl_tbl Exception when others smt 2');

              x_return_status := G_RET_STS_UNEXP_ERROR;

              error_handler.Add_error_message(p_message_text => sqlerrm,p_application_id => 'EGO',
                                              p_token_tbl => g_token_table,p_message_type => G_RET_STS_UNEXP_ERROR,
                                              p_row_identifier => P_agdl_tbl(i).transaction_id,
                                              p_entity_code => G_ENTITY_DL,p_table_name => G_ENTITY_DL_tab);

              x_return_msg := 'ego_ag_bulkload_pvt.Value_to_id_dl_tbl smt 2- '||SQLERRM;

      		  RETURN;
          END;
        END IF;

        lv_smt := 3;

        write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Statement 3');

        /*Sets the Edit Privilege ID and returns an error is it doesnt existing in the system*/
        IF (P_agdl_tbl(i).edit_privilege_id  IS NULL
            AND P_agdl_tbl(i).edit_privilege_name IS NOT NULL
            AND P_agdl_tbl(i).edit_privilege_name <> G_NULL_CHAR) THEN
          BEGIN
            SELECT function_id
            INTO   P_agdl_tbl(i).edit_privilege_id
            FROM   fnd_form_functions
            WHERE  function_name = P_agdl_tbl(i).edit_privilege_name;
          EXCEPTION
            WHEN no_data_found THEN
              write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - Err_msg_TID: '||P_agdl_tbl(i).transaction_id||' (AG,DL,VS) = ('
              ||P_agdl_tbl(i).attr_group_name||','||P_agdl_tbl(i).data_level_name||','||P_agdl_tbl(i).edit_privilege_name||'). '
              ||'Edit privilege does not exist in the system');

              P_agdl_tbl(i).process_status := G_ERROR_RECORD;

              x_return_status := G_RET_STS_ERROR;

              error_handler.Add_error_message(p_message_name => 'EGO_EDIT_PRIV_NOT_EXIST',
                                              p_application_id => 'EGO',p_token_tbl => g_token_table,
                                              p_message_type => G_RET_STS_ERROR,p_row_identifier => P_agdl_tbl(i).transaction_id,
                                              p_entity_code => G_ENTITY_DL,p_table_name => G_ENTITY_DL_tab);
            WHEN OTHERS THEN
              write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - Err_msg_TID: '||P_agdl_tbl(i).transaction_id||' (AG,DL,VS) = ('
              ||P_agdl_tbl(i).attr_group_name||','||P_agdl_tbl(i).data_level_name||','||P_agdl_tbl(i).edit_privilege_name||'). '
              ||'Exception: '||SQLERRM);

              x_return_status := G_RET_STS_UNEXP_ERROR;

              error_handler.Add_error_message(p_message_text => sqlerrm,p_application_id => 'EGO',
                                              p_token_tbl => g_token_table,p_message_type => G_RET_STS_UNEXP_ERROR,
                                              p_row_identifier => P_agdl_tbl(i).transaction_id,
                                              p_entity_code => G_ENTITY_DL,p_table_name => G_ENTITY_DL_tab);

			  x_return_msg := 'ego_ag_bulkload_pvt.Value_to_id_dl_tbl smt 3- '||SQLERRM;

      		  RETURN;
          END;
        END IF;

        lv_smt := 4;

        write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Statement 4');

        /*Sets the DATA LEVEL ID and returns an error is it doesnt existing in the system*/
        IF (P_agdl_tbl(i).data_level_id  IS NULL
            AND P_agdl_tbl(i).data_level_name  IS NOT NULL) THEN
          BEGIN
            SELECT data_level_id
            INTO   P_agdl_tbl(i).data_level_id
            FROM   ego_data_level_b
            WHERE  attr_group_type = P_agdl_tbl(i).attr_group_type
                   AND application_id = g_ego_application_id
                   AND data_level_name = P_agdl_tbl(i).data_level_name;
          EXCEPTION
            WHEN no_data_found THEN
              write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - Err_msg_TID: '||P_agdl_tbl(i).transaction_id||' (AG,DL) = ('||P_agdl_tbl(i).attr_group_name||','||P_agdl_tbl(i).data_level_name||'). ' ||'Data Level does not exist in the system');

              P_agdl_tbl(i).process_status := G_ERROR_RECORD;

              x_return_status := G_RET_STS_ERROR;

              error_handler.Add_error_message(p_message_name => 'EGO_DL_NOT_EXIST',p_application_id => 'EGO',
                                              p_token_tbl => g_token_table,p_message_type => G_RET_STS_ERROR,
                                              p_row_identifier => P_agdl_tbl(i).transaction_id,
                                              p_entity_code => G_ENTITY_DL,p_table_name => G_ENTITY_DL_tab);
            WHEN OTHERS THEN
              write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - Err_msg_TID: '||P_agdl_tbl(i).transaction_id||' (AG,DL) = ('||P_agdl_tbl(i).attr_group_name||','||P_agdl_tbl(i).data_level_name||'). ' ||'Exception: '||SQLERRM);

              x_return_status := G_RET_STS_UNEXP_ERROR;

              error_handler.Add_error_message(p_message_text => sqlerrm,p_application_id => 'EGO',
                                              p_token_tbl => g_token_table,p_message_type => G_RET_STS_UNEXP_ERROR,
                                              p_row_identifier => P_agdl_tbl(i).transaction_id,
                                              p_entity_code => G_ENTITY_DL,p_table_name => G_ENTITY_DL_tab);

              x_return_msg := 'ego_ag_bulkload_pvt.Value_to_id_dl_tbl smt 4 - '||SQLERRM;

      		  RETURN;
          END;
        END IF;

        lv_smt := 5;

        write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Statement 5');

        /*Sets the SYNC Transaction Type to CREATE or UPDATE*/
        IF (P_agdl_tbl(i).data_level_id  IS NOT NULL
            AND P_agdl_tbl(i).attr_group_id  IS NOT NULL
            AND P_agdl_tbl(i).transaction_type = G_OPR_SYNC) THEN
          BEGIN
            SELECT 'Y'
            INTO   lv_flag
            FROM   ego_attr_group_dl
            WHERE  data_level_id = P_agdl_tbl(i).data_level_id
                   AND attr_group_id = P_agdl_tbl(i).attr_group_id;

            IF lv_flag = 'Y' THEN
              P_agdl_tbl(i).transaction_type := G_OPR_UPDATE;
            END IF;
          EXCEPTION
            WHEN no_data_found THEN
              P_agdl_tbl(i).transaction_type := G_OPR_CREATE;
            WHEN OTHERS THEN
              write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Value_to_id_dl_tbl Exception when others smt 5');

              x_return_status := G_RET_STS_UNEXP_ERROR;

              error_handler.Add_error_message(p_message_text => sqlerrm,p_application_id => 'EGO',
                                              p_token_tbl => g_token_table,p_message_type => G_RET_STS_UNEXP_ERROR,
                                              p_row_identifier => P_agdl_tbl(i).transaction_id,
                                              p_entity_code => G_ENTITY_DL,p_table_name => G_ENTITY_DL_tab);

              x_return_msg := 'ego_ag_bulkload_pvt.Value_to_id_dl_tbl smt 5 - '||SQLERRM;

      		  RETURN;
          END;
        END IF;
      END IF;
    END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
      write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Value_to_id_dl_tbl Exception when others'||SQLERRM);

      x_return_status := G_RET_STS_UNEXP_ERROR;

      x_return_msg := 'ego_ag_bulkload_pvt.Value_to_id_dl_tbl - '||SQLERRM;

      RETURN;
  END Value_to_id_dl_tbl;

  /*This procedure is used for value to ID conversion for Attributes plsql tables.
  	Used in the API flow.
  	p_attr_tbl      IN OUT NOCOPY Attributes plsql table
  	x_return_status OUT NOCOPY parameter that returns the status*/
  PROCEDURE Value_to_id_attr_tbl
       (p_attr_tbl       IN OUT NOCOPY ego_metadata_pub.ego_attr_group_cols_tbl,
        x_return_status OUT NOCOPY VARCHAR2, x_return_msg OUT NOCOPY VARCHAR2)
  IS
    lv_smt  NUMBER; --Statement counter
  	lv_proc VARCHAR2(30) := 'Value_to_id_attr_tbl';
  BEGIN
    write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Entering Value_to_id_attr_tbl');

    x_return_status := G_RET_STS_SUCCESS;

    FOR i IN p_attr_tbl.FIRST.. p_attr_tbl.LAST LOOP
      IF (P_attr_tbl(i).process_status = G_PROCESS_RECORD) THEN
        lv_smt := 1;

        write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Statement 1');

        /*Sets the Attribute group id when the Internal Attribute group name is given*/
        IF (P_attr_tbl(i).attr_group_id IS NULL
            AND P_attr_tbl(i).attr_group_name IS NOT NULL) THEN
          BEGIN
            SELECT attr_group_id
            INTO   P_attr_tbl(i).attr_group_id
            FROM   ego_fnd_dsc_flx_ctx_ext
            WHERE  application_id = g_ego_application_id
                   AND descriptive_flexfield_name = P_attr_tbl(i).attr_group_type
                   AND descriptive_flex_context_code = P_attr_tbl(i).attr_group_name;
          EXCEPTION
            WHEN no_data_found THEN
              x_return_status := G_RET_STS_ERROR;

              write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - Err_msg_TID: '||P_attr_tbl(i).transaction_id||' (AG,ATTR) = ('||P_attr_tbl(i).attr_group_name||','||P_attr_tbl(i).internal_name||'). ' ||'Attribute Group does not exist in the system');

              error_handler.Add_error_message(p_message_name => 'EGO_AG_INVALID',p_application_id => 'EGO',
                                              p_token_tbl => g_token_table,p_message_type => G_RET_STS_ERROR,
                                              p_row_identifier => P_attr_tbl(i).transaction_id,
                                              p_entity_code => G_ENTITY_ATTR,p_table_name => G_ENTITY_ATTR_TAB);
            WHEN OTHERS THEN
              x_return_status := G_RET_STS_UNEXP_ERROR;

              write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - Err_msg_TID: '||P_attr_tbl(i).transaction_id||' (AG,ATTR) = ('||P_attr_tbl(i).attr_group_name||','||P_attr_tbl(i).internal_name||'). ' ||'Exception: '||SQLERRM);

              error_handler.Add_error_message(p_message_text => sqlerrm,p_application_id => 'EGO',
                                              p_token_tbl => g_token_table,p_message_type => G_RET_STS_UNEXP_ERROR,
                                              p_row_identifier => P_attr_tbl(i).transaction_id,
                                              p_entity_code => G_ENTITY_ATTR,p_table_name => G_ENTITY_ATTR_TAB);

              x_return_msg := 'ego_ag_bulkload_pvt.Value_to_id_attr_tbl smt 1 - '||SQLERRM;

      		  RETURN;
          END;
        END IF;

        lv_smt := 2;

        write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Statement 2');

        /*Sets the application ID*/
        P_attr_tbl(i).application_id := g_ego_application_id;

        lv_smt := 3;

        write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Statement 3');

        /*Sets the Attr_id for the update and sync flow. Also handles convert SYNC to CREATE/UPDATE flow*/
        IF (P_attr_tbl(i).attr_id IS NULL
            AND P_attr_tbl(i).internal_name IS NOT NULL
            AND (P_attr_tbl(i).transaction_type = G_OPR_UPDATE
                  OR P_attr_tbl(i).transaction_type = G_OPR_SYNC)) THEN
          BEGIN
            SELECT efdcue.attr_id
            INTO   P_attr_tbl(i).attr_id
            FROM   fnd_descr_flex_column_usages fdfcu,
                   ego_fnd_df_col_usgs_ext efdcue
            WHERE  fdfcu.application_id = efdcue.application_id
                   AND fdfcu.descriptive_flexfield_name = efdcue.descriptive_flexfield_name
                   AND fdfcu.descriptive_flex_context_code = efdcue.descriptive_flex_context_code
                   AND fdfcu.application_column_name = efdcue.application_column_name
                   AND fdfcu.application_id = g_ego_application_id
                   AND fdfcu.descriptive_flexfield_name = P_attr_tbl(i).attr_group_type
                   AND fdfcu.descriptive_flex_context_code = P_attr_tbl(i).attr_group_name
                   AND fdfcu.end_user_column_name = P_attr_tbl(i).internal_name;

            IF (P_attr_tbl(i).transaction_type = G_OPR_SYNC) THEN
              P_attr_tbl(i).transaction_type := G_OPR_UPDATE;
            END IF;
          EXCEPTION
            WHEN no_data_found THEN
              IF (P_attr_tbl(i).transaction_type = G_OPR_SYNC) THEN
                P_attr_tbl(i).transaction_type := G_OPR_CREATE;
              ELSE
                x_return_status := G_RET_STS_ERROR;

                write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - Err_msg_TID: '||P_attr_tbl(i).transaction_id||' (AG,ATTR) = ('||P_attr_tbl(i).attr_group_name||','||P_attr_tbl(i).internal_name||'). ' ||'Attribute does not exist in the system');

                error_handler.Add_error_message(p_message_name => 'EGO_ATTR_NOT_EXISTS',p_application_id => 'EGO',
                                                p_token_tbl => g_token_table,p_message_type => G_RET_STS_ERROR,
                                                p_row_identifier => P_attr_tbl(i).transaction_id,
                                                p_entity_code => G_ENTITY_ATTR,p_table_name => G_ENTITY_ATTR_TAB);
              END IF;
            WHEN OTHERS THEN
              x_return_status := G_RET_STS_UNEXP_ERROR;

              write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - Err_msg_TID: '||P_attr_tbl(i).transaction_id||' (AG,ATTR) = ('
              ||P_attr_tbl(i).attr_group_name||','||P_attr_tbl(i).internal_name||'). ' ||'Exception: '||SQLERRM);

              error_handler.Add_error_message(p_message_text => sqlerrm,p_application_id => 'EGO',
                                              p_token_tbl => g_token_table,p_message_type => G_RET_STS_ERROR,
                                              p_row_identifier => P_attr_tbl(i).transaction_id,
                                              p_entity_code => G_ENTITY_ATTR,p_table_name => G_ENTITY_ATTR_TAB);

              x_return_msg := 'ego_ag_bulkload_pvt.Value_to_id_attr_tbl smt 3 - '||SQLERRM;

      		  RETURN;
          END;
        END IF;

        lv_smt := 4;

        write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Statement 4');

        /*Sets value set id when the value set name is given*/
        IF (P_attr_tbl(i).flex_value_set_id IS NULL
            AND P_attr_tbl(i).flex_value_set_name IS NOT NULL
            AND P_attr_tbl(i).flex_value_set_name <> G_NULL_CHAR) THEN
          BEGIN
            SELECT ffvs.flex_value_set_id
            INTO   P_attr_tbl(i).flex_value_set_id
            FROM   fnd_flex_value_sets ffvs
            WHERE  ffvs.flex_value_set_name = P_attr_tbl(i).flex_value_set_name;
          EXCEPTION
            WHEN no_data_found THEN
              x_return_status := G_RET_STS_ERROR;

              write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - Err_msg_TID: '||P_attr_tbl(i).transaction_id||' (AG,ATTR,VS) = ('
              ||P_attr_tbl(i).attr_group_name||','||P_attr_tbl(i).internal_name||','||P_attr_tbl(i).flex_value_set_name||'). '
              ||'Value Set does not exist');

              error_handler.Add_error_message(p_message_name => 'EGO_EF_BC_SEL_EXI_VALUE',p_application_id => 'EGO',
                                              p_token_tbl => g_token_table,p_message_type => G_RET_STS_ERROR,
                                              p_row_identifier => P_attr_tbl(i).transaction_id,
                                              p_entity_code => G_ENTITY_ATTR,p_table_name => G_ENTITY_ATTR_TAB);
            WHEN OTHERS THEN
              x_return_status := G_RET_STS_UNEXP_ERROR;

              write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - Err_msg_TID: '||P_attr_tbl(i).transaction_id||' (AG,ATTR,VS) = ('
              ||P_attr_tbl(i).attr_group_name||','||P_attr_tbl(i).internal_name||','||P_attr_tbl(i).flex_value_set_name||'). '
              ||'Exception : '||SQLERRM);

              error_handler.Add_error_message(p_message_text => sqlerrm,p_application_id => 'EGO',
                                              p_token_tbl => g_token_table,p_message_type => G_RET_STS_UNEXP_ERROR,
                                              p_row_identifier => P_attr_tbl(i).transaction_id,
                                              p_entity_code => G_ENTITY_ATTR,p_table_name => G_ENTITY_ATTR_TAB);

              x_return_msg := 'ego_ag_bulkload_pvt.Value_to_id_attr_tbl smt 4 - '||SQLERRM;

      		  RETURN;
          END;
        END IF;
      END IF;
    END LOOP;

    write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Exit Value_to_id_attr_tbl');
  EXCEPTION
    WHEN OTHERS THEN
      write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||' Value_to_id_attr_tbl Exception when others'||SQLERRM);

      x_return_status := G_RET_STS_UNEXP_ERROR;

      x_return_msg := 'ego_ag_bulkload_pvt.Value_to_id_attr_tbl - '||SQLERRM;

   	  RETURN;

  END Value_to_id_attr_tbl;

  /*This procedure is used to do Common validations on attribute groups.
  	Used in the Interface and API flow.
  	p_ag_tbl        IN OUT NOCOPY  Attribute group plsql table
  	x_return_status OUT NOCOPY parameter that returns the status*/
  PROCEDURE Common_ag_validations
       (p_ag_tbl         IN OUT NOCOPY ego_metadata_pub.ego_attr_groups_tbl,
        x_return_status OUT NOCOPY VARCHAR2, x_return_msg OUT NOCOPY VARCHAR2)
  IS
    lv_smt  NUMBER; --Statement counter
  	lv_proc VARCHAR2(30) := 'Common_ag_validations';
  BEGIN
    write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Entering Common_ag_validations');

    x_return_status := G_RET_STS_SUCCESS;

    FOR i IN p_ag_tbl.FIRST.. p_ag_tbl.LAST LOOP
    	IF (p_ag_tbl(i).process_status = G_PROCESS_RECORD) THEN
		      /*Start of common validations*/
		      lv_smt := 1;

		      write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Statement 1');

		      IF P_ag_tbl(i).multi_row = 'N'
		         AND Nvl(P_ag_tbl(i).variant,'N') = 'N'
		         AND P_ag_tbl(i).num_of_cols = 0 THEN
		        P_ag_tbl(i).process_status := G_ERROR_RECORD;

		        x_return_status := G_RET_STS_ERROR;

		     	write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - Err_msg_TID: '||P_ag_tbl(i).transaction_id||' (AG) = ('||P_ag_tbl(i).attr_group_name||'). ' ||'Number of columns is not within acceptable range for Single Row Attribute group');

		      	error_handler.Add_error_message(p_message_name => 'EGO_EF_SIN_COL_VAL',p_application_id => 'EGO',
		                                                  p_token_tbl => g_token_table,p_message_type => G_RET_STS_ERROR,
		                                                  p_row_identifier => P_ag_tbl(i).transaction_id,
		                                                  p_entity_code => G_ENTITY_AG,p_table_name => G_ENTITY_AG_TAB);


		      END IF;

		      lv_smt := 2;

		      write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Statement 2');

		      IF P_ag_tbl(i).multi_row = 'Y'
		         AND P_ag_tbl(i).num_of_cols = 0 THEN
		        P_ag_tbl(i).process_status := G_ERROR_RECORD;

		        x_return_status := G_RET_STS_ERROR;

		        write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - Err_msg_TID: '||P_ag_tbl(i).transaction_id||' (AG) = ('||P_ag_tbl(i).attr_group_name||'). ' ||'Number of columns is not within acceptable range for Multi Row Attribute group');

		        error_handler.Add_error_message(p_message_name => 'EGO_EF_MUL_COL_VAL',p_application_id => 'EGO',
		                                                  p_token_tbl => g_token_table,p_message_type => G_RET_STS_ERROR,
		                                                  p_row_identifier => P_ag_tbl(i).transaction_id,
		                                                  p_entity_code => G_ENTITY_AG,p_table_name => G_ENTITY_AG_TAB);
		      END IF;

		      lv_smt := 3;

		      write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Statement 3');

		      IF P_ag_tbl(i).multi_row = 'Y'
		         AND P_ag_tbl(i).num_of_rows = 0 THEN
		        P_ag_tbl(i).process_status := G_ERROR_RECORD;

		        x_return_status := G_RET_STS_ERROR;

		        write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - Err_msg_TID: '||P_ag_tbl(i).transaction_id||' (AG) = ('||P_ag_tbl(i).attr_group_name||'). ' ||'Number of columns is not within acceptable range for Multi Row Attribute group');

		        error_handler.Add_error_message(p_message_name => 'EGO_EF_ROW_VAL',p_application_id => 'EGO',
		                                                  p_token_tbl => g_token_table,p_message_type => G_RET_STS_ERROR,
		                                                  p_row_identifier => P_ag_tbl(i).transaction_id,
		                                                  p_entity_code => G_ENTITY_AG,p_table_name => G_ENTITY_AG_TAB);
		      END IF;

		      lv_smt := 4;

		      write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Statement 4');

		      IF P_ag_tbl(i).multi_row = 'Y'
		         AND P_ag_tbl(i).variant = 'Y' THEN
		        P_ag_tbl(i).process_status := G_ERROR_RECORD;

		        x_return_status := G_RET_STS_ERROR;

		        write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - Err_msg_TID: '||P_ag_tbl(i).transaction_id||' (AG) = ('||P_ag_tbl(i).attr_group_name||'). ' ||'Invalid MultiRow Variant combination');

		        error_handler.Add_error_message(p_message_name => 'EGO_MULROW_VAR_COMB',p_application_id => 'EGO',
		                                                  p_token_tbl => g_token_table,p_message_type => G_RET_STS_ERROR,
		                                                  p_row_identifier => P_ag_tbl(i).transaction_id,
		                                                  p_entity_code => G_ENTITY_AG,p_table_name => G_ENTITY_AG_TAB);
		      END IF;

		      lv_smt := 5;

		      write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Statement 5');

		      IF (P_ag_tbl(i).transaction_type = G_OPR_UPDATE
		         AND (P_ag_tbl(i).multi_row  IS NOT NULL
		               OR P_ag_tbl(i).variant  IS NOT NULL)) THEN
		        P_ag_tbl(i).process_status := G_ERROR_RECORD;

		        x_return_status := G_RET_STS_ERROR;

		      	write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - Err_msg_TID: '||P_ag_tbl(i).transaction_id||' (AG) = ('||P_ag_tbl(i).attr_group_name||'). ' ||'Updating the behaviour of attribute group is not allowed');

		        error_handler.Add_error_message(p_message_name => 'EGO_UPD_BEHAVIOUR',p_application_id => 'EGO',
		                                                  p_token_tbl => g_token_table,p_message_type => G_RET_STS_ERROR,
		                                                  p_row_identifier => P_ag_tbl(i).transaction_id,
		                                                  p_entity_code => G_ENTITY_AG,p_table_name => G_ENTITY_AG_TAB);

		      END IF;

		END IF;
    END LOOP;

    write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Exit Common_ag_validations');
  EXCEPTION
    WHEN OTHERS THEN
      write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Common_ag_validations Exception when others'||SQLERRM);

      x_return_status := G_RET_STS_UNEXP_ERROR;

      x_return_msg := 'ego_ag_bulkload_pvt.Common_ag_validations - '||SQLERRM;

   	  RETURN;
  END Common_ag_validations;

  /*This procedure is used to do Common validations on attribute group data level.
  	Used in the Interface and API flow.
  	p_agdl_tbl        IN OUT NOCOPY  Attribute group plsql table
  	x_return_status OUT NOCOPY parameter that returns the status*/
  PROCEDURE Common_dl_validations
       (p_agdl_tbl       IN OUT NOCOPY ego_metadata_pub.ego_attr_groups_dl_tbl,
        x_return_status OUT NOCOPY VARCHAR2, x_return_msg OUT NOCOPY VARCHAR2)
  IS
    lv_smt  NUMBER; --Statement counter
  	lv_proc VARCHAR2(30) := 'Common_dl_validations';
  BEGIN
    write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Entering Common_dl_validations');

    x_return_status := G_RET_STS_SUCCESS;

    FOR i IN p_agdl_tbl.FIRST.. p_agdl_tbl.LAST LOOP
    	IF (p_agdl_tbl(i).process_status = G_PROCESS_RECORD) THEN
    		/*Check for invalid Pre Event*/
    		IF (NVL(p_agdl_tbl(i).pre_business_event_flag,'N') IN ('Y','N')) THEN
    			p_agdl_tbl(i).pre_business_event_flag := NVL(p_agdl_tbl(i).pre_business_event_flag,'N');
    		ELSE
    			p_agdl_tbl(i).process_status := G_ERROR_RECORD;

		        x_return_status := G_RET_STS_ERROR;

		      	write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - Err_msg_TID: '||p_agdl_tbl(i).transaction_id||' (AG,DL) = ('||p_agdl_tbl(i).attr_group_name||','||p_agdl_tbl(i).data_level_name||'). ' ||'Invalid Pre event flag.');

		        error_handler.Add_error_message(p_message_name => 'EGO_INVALID_PRE_EVENT',p_application_id => 'EGO',
		                                                  p_token_tbl => g_token_table,p_message_type => G_RET_STS_ERROR,
		                                                  p_row_identifier => p_agdl_tbl(i).transaction_id,
		                                                  p_entity_code => G_ENTITY_DL,p_table_name => G_ENTITY_DL_TAB);
    		END IF;

    		/*Check for invalid Post Event*/
    		IF (NVL(p_agdl_tbl(i).business_event_flag,'N') IN ('Y','N')) THEN
    			p_agdl_tbl(i).business_event_flag := NVL(p_agdl_tbl(i).business_event_flag,'N');
    		ELSE
    			p_agdl_tbl(i).process_status := G_ERROR_RECORD;

		        x_return_status := G_RET_STS_ERROR;

		      	write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - Err_msg_TID: '||p_agdl_tbl(i).transaction_id||' (AG,DL) = ('
		      	||p_agdl_tbl(i).attr_group_name||','||p_agdl_tbl(i).data_level_name||'). ' ||'Invalid post event flag.');

		        error_handler.Add_error_message(p_message_name => 'EGO_INVALID_POST_EVENT',p_application_id => 'EGO',
		                                                  p_token_tbl => g_token_table,p_message_type => G_RET_STS_ERROR,
		                                                  p_row_identifier => p_agdl_tbl(i).transaction_id,
		                                                  p_entity_code => G_ENTITY_DL,p_table_name => G_ENTITY_DL_TAB);
    		END IF;


    		/*Validation for deleting Business entity*/
    		IF (p_agdl_tbl(i).transaction_type = G_OPR_DELETE) THEN
    			DECLARE
    				lv_flag NUMBER;
    				lv_count NUMBER;
    			BEGIN
    				SELECT 1 INTO lv_flag
    				FROM EGO_ATTR_GROUP_DL
    				WHERE attr_group_id = p_agdl_tbl(i).attr_group_id
    				AND data_level_id = p_agdl_tbl(i).data_level_id;

    				IF (lv_flag = 1) THEN
    					SELECT COUNT(1) INTO lv_count
    					FROM EGO_ATTR_GROUP_DL
    					WHERE attr_group_id = p_agdl_tbl(i).attr_group_id;

    					IF (lv_count = 1) THEN
    						p_agdl_tbl(i).process_status := G_ERROR_RECORD;

					        x_return_status := G_RET_STS_ERROR;

					      	write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - Err_msg_TID: '||p_agdl_tbl(i).transaction_id||' (AG,DL) = ('
					      	||p_agdl_tbl(i).attr_group_name||','||p_agdl_tbl(i).data_level_name||'). '
					      	||'Cannot delete the business entity since there is only one business entity');

					        error_handler.Add_error_message(p_message_name => 'EGO_EF_DL_REQD_AG',p_application_id => 'EGO',
					                                                  p_token_tbl => g_token_table,p_message_type => G_RET_STS_ERROR,
					                                                  p_row_identifier => p_agdl_tbl(i).transaction_id,
					                                                  p_entity_code => G_ENTITY_DL,p_table_name => G_ENTITY_DL_TAB);
    					END IF;
    				END IF;
    			EXCEPTION
    				WHEN NO_DATA_FOUND THEN
    					p_agdl_tbl(i).process_status := G_ERROR_RECORD;

				        x_return_status := G_RET_STS_ERROR;

				      	write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - Err_msg_TID: '||p_agdl_tbl(i).transaction_id||' (AG,DL) = ('
				      	||p_agdl_tbl(i).attr_group_name||','||p_agdl_tbl(i).data_level_name||'). '
				      	||'Cannot delete the business entity since its not associated to the AG');

				        error_handler.Add_error_message(p_message_name => 'EGO_DL_NOT_ASSOC',p_application_id => 'EGO',
				                                                  p_token_tbl => g_token_table,p_message_type => G_RET_STS_ERROR,
				                                                  p_row_identifier => p_agdl_tbl(i).transaction_id,
				                                                  p_entity_code => G_ENTITY_DL,p_table_name => G_ENTITY_DL_TAB);
    				WHEN OTHERS THEN
    					x_return_status := G_RET_STS_UNEXP_ERROR;

				      	write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - Err_msg_TID: '||p_agdl_tbl(i).transaction_id||' (AG,DL) = ('
				      	||p_agdl_tbl(i).attr_group_name||','||p_agdl_tbl(i).data_level_name||'). ' ||'Exception -'||SQLERRM);

				        error_handler.Add_error_message(p_message_text => SQLERRM,p_application_id => 'EGO',
				                                                  p_token_tbl => g_token_table,p_message_type => G_RET_STS_UNEXP_ERROR,
				                                                  p_row_identifier => p_agdl_tbl(i).transaction_id,
				                                                  p_entity_code => G_ENTITY_DL,p_table_name => G_ENTITY_DL_TAB);
    			END;
    		END IF;

    		/*Sets the attr_group_id if its still NULL and if its present in the system.*/
    		IF (p_agdl_tbl(i).attr_group_id IS NULL) THEN
    			BEGIN
    				SELECT attr_group_id INTO p_agdl_tbl(i).attr_group_id
	                  FROM   ego_fnd_dsc_flx_ctx_ext
	                  WHERE  application_id = G_EGO_APPLICATION_ID
	                         AND descriptive_flexfield_name = p_agdl_tbl(i).attr_group_type
	                         AND descriptive_flex_context_code = p_agdl_tbl(i).attr_group_name;
    			EXCEPTION
    				WHEN NO_DATA_FOUND THEN
    					p_agdl_tbl(i).process_status := G_ERROR_RECORD;

				        x_return_status := G_RET_STS_ERROR;

				      	write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - Err_msg_TID: '||p_agdl_tbl(i).transaction_id||' (AG,DL) = ('
				      	||p_agdl_tbl(i).attr_group_name||','||p_agdl_tbl(i).data_level_name||'). ' ||'Attribute group does not exist');

				        error_handler.Add_error_message(p_message_name => 'EGO_AG_NOT_EXIST',p_application_id => 'EGO',
				                                                  p_token_tbl => g_token_table,p_message_type => G_RET_STS_ERROR,
				                                                  p_row_identifier => p_agdl_tbl(i).transaction_id,
				                                                  p_entity_code => G_ENTITY_DL,p_table_name => G_ENTITY_DL_TAB);
    				WHEN OTHERS THEN
    					x_return_status := G_RET_STS_UNEXP_ERROR;

				      	write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - Err_msg_TID: '||p_agdl_tbl(i).transaction_id||' (AG,DL) = ('
				      	||p_agdl_tbl(i).attr_group_name||','||p_agdl_tbl(i).data_level_name||'). ' ||'Exception -'||SQLERRM);

				        error_handler.Add_error_message(p_message_text => SQLERRM,p_application_id => 'EGO',
				                                                  p_token_tbl => g_token_table,p_message_type => G_RET_STS_UNEXP_ERROR,
				                                                  p_row_identifier => p_agdl_tbl(i).transaction_id,
				                                                  p_entity_code => G_ENTITY_DL,p_table_name => G_ENTITY_DL_TAB);
    			END;
    		END IF;

    	END IF;
    END LOOP;

    write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Exit Common_dl_validations');
  EXCEPTION
    WHEN OTHERS THEN
      write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Common_dl_validations Exception when others'||SQLERRM);

      x_return_status := G_RET_STS_UNEXP_ERROR;

      x_return_msg := 'ego_ag_bulkload_pvt.Common_dl_validations - '||SQLERRM;

   	  RETURN;
  END Common_dl_validations;

  /*This procedure is used to do Common validations on attributes.
  	Used in the Interface and API flow.
  	p_attr_tbl        IN OUT NOCOPY  Attribute group plsql table
  	x_return_status OUT NOCOPY parameter that returns the status*/
  PROCEDURE Common_attr_validations
       (p_attr_tbl       IN OUT NOCOPY ego_metadata_pub.ego_attr_group_cols_tbl,
        x_return_status OUT NOCOPY VARCHAR2, x_return_msg OUT NOCOPY VARCHAR2)
  IS
    lv_smt  NUMBER; --Statement counter
  	lv_proc VARCHAR2(30) := 'Common_attr_validations';
  	lv_flag VARCHAR2(1):= 'N';
  BEGIN
    write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Entering Common_attr_validations');

    x_return_status := G_RET_STS_SUCCESS;

    FOR i IN p_attr_tbl.FIRST.. p_attr_tbl.LAST LOOP
    	IF (p_attr_tbl(i).process_status = G_PROCESS_RECORD) THEN
		    	/*Checks for the mandatory columns during the CREATE flow*/
		    	IF ((p_attr_tbl(i).attr_group_type  IS NULL    --Changed for 9625957
		    	    OR p_attr_tbl(i).attr_group_name  IS NULL
		    	    OR p_attr_tbl(i).internal_name  IS NULL
		    		OR p_attr_tbl(i).display_name  IS NULL
		    		OR p_attr_tbl(i).sequence  IS NULL
		    		OR p_attr_tbl(i).data_type  IS NULL
		    		OR p_attr_tbl(i).display_code  IS NULL
		    		OR p_attr_tbl(i).application_column_name  IS NULL)
		    		AND p_attr_tbl(i).transaction_type = G_OPR_CREATE) THEN
		    		p_attr_tbl(i).process_status := G_ERROR_RECORD;

		    		x_return_status := G_RET_STS_ERROR;

		    		write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - Err_msg_TID: '||p_attr_tbl(i).transaction_id||' (AG,ATTR) = ('
		    		||p_attr_tbl(i).attr_group_name||','||p_attr_tbl(i).internal_name||'). ' ||'Mandatory columns for the attribute are not populated');

		    		error_handler.Add_error_message(p_message_name => 'EGO_ATTR_MANDATORY',p_application_id => 'EGO',
		                                                  p_token_tbl => g_token_table,p_message_type => G_RET_STS_ERROR,
		                                                  p_row_identifier => p_attr_tbl(i).transaction_id,
		                                                  p_entity_code => G_ENTITY_ATTR,p_table_name => G_ENTITY_ATTR_TAB);
		    	END IF;

		    	/*Checks whether the data type entered is valid*/
		    	IF (p_attr_tbl(i).data_type = G_TRANS_TEXT_DATA_TYPE
		    		OR p_attr_tbl(i).data_type = G_CHAR_DATA_TYPE
		    		OR p_attr_tbl(i).data_type = G_NUMBER_DATA_TYPE
		    		OR p_attr_tbl(i).data_type = G_DATE_DATA_TYPE
		    		OR p_attr_tbl(i).data_type = G_DATE_TIME_DATA_TYPE) THEN
		    		NULL;
		    	ELSIF (p_attr_tbl(i).transaction_type = G_OPR_DELETE) THEN
		    		NULL;
		    	ELSE
		    		p_attr_tbl(i).process_status := G_ERROR_RECORD;

		    		x_return_status := G_RET_STS_ERROR;

		    		write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - Err_msg_TID: '||p_attr_tbl(i).transaction_id||' (AG,ATTR) = ('
		    		||p_attr_tbl(i).attr_group_name||','||p_attr_tbl(i).internal_name||'). ' ||'Data type populated is invalid');

		    		error_handler.Add_error_message(p_message_name => 'EGO_DATA_TYPE_INVALID',p_application_id => 'EGO',
		                                                  p_token_tbl => g_token_table,p_message_type => G_RET_STS_ERROR,
		                                                  p_row_identifier => p_attr_tbl(i).transaction_id,
		                                                  p_entity_code => G_ENTITY_ATTR,p_table_name => G_ENTITY_ATTR_TAB);
		    	END IF;

		    	/*Checks for invalid data type and display as combination*/

		    	IF ((p_attr_tbl(i).data_type = g_char_data_type AND p_attr_tbl(i).display_code = g_attach_disp_type)
		             OR (p_attr_tbl(i).data_type = g_number_data_type AND (p_attr_tbl(i).display_code = g_checkbox_disp_type
		             													   OR p_attr_tbl(i).display_code = g_static_url_disp_type
		             													   OR p_attr_tbl(i).display_code = g_text_area_disp_type))
		             OR ((p_attr_tbl(i).data_type = g_date_data_type
		                 OR p_attr_tbl(i).data_type = g_date_time_data_type) AND (p_attr_tbl(i).display_code = g_checkbox_disp_type
		                 														  OR p_attr_tbl(i).display_code = g_dyn_url_disp_type
		                 														  OR p_attr_tbl(i).display_code = g_static_url_disp_type
		                 														  OR p_attr_tbl(i).display_code = g_text_area_disp_type
		                 														  OR p_attr_tbl(i).display_code = g_attach_disp_type))
		             OR (p_attr_tbl(i).data_type = g_trans_text_data_type AND (p_attr_tbl(i).display_code = g_attach_disp_type
		             														   OR p_attr_tbl(i).display_code = g_dyn_url_disp_type
		             														   OR p_attr_tbl(i).display_code = g_dyn_url_disp_type
		             														   OR p_attr_tbl(i).display_code = g_text_area_disp_type
		             														   OR p_attr_tbl(i).display_code = g_checkbox_disp_type))
		    		) THEN

		    		p_attr_tbl(i).process_status := G_ERROR_RECORD;

		    		x_return_status := G_RET_STS_ERROR;

		    		write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - Err_msg_TID: '||p_attr_tbl(i).transaction_id||' (AG,ATTR) = ('
		    		||p_attr_tbl(i).attr_group_name||','||p_attr_tbl(i).internal_name||'). ' ||'Data type and display as combination is invalid');

		    		error_handler.Add_error_message(p_message_name => 'EGO_DT_DISP_COMB_INVALID',p_application_id => 'EGO',
		                                                  p_token_tbl => g_token_table,p_message_type => G_RET_STS_ERROR,
		                                                  p_row_identifier => p_attr_tbl(i).transaction_id,
		                                                  p_entity_code => G_ENTITY_ATTR,p_table_name => G_ENTITY_ATTR_TAB);
		    	END IF;

		    	/*Checks if the value set is mandatory*/

		    	IF ((p_attr_tbl(i).display_code = g_attach_disp_type OR p_attr_tbl(i).display_code = g_radio_disp_type)
		           	 AND (p_attr_tbl(i).flex_value_set_name  IS NULL OR p_attr_tbl(i).flex_value_set_id  IS NULL)) THEN

		           	p_attr_tbl(i).process_status := G_ERROR_RECORD;

		        	x_return_status := G_RET_STS_ERROR;

		    		write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - Err_msg_TID: '||p_attr_tbl(i).transaction_id||' (AG,ATTR) = ('
		    		||p_attr_tbl(i).attr_group_name||','||p_attr_tbl(i).internal_name||'). ' ||'Value Set is mandatory for particular display');

		    		error_handler.Add_error_message(p_message_name => 'EGO_VALUE_SET_REQUIRED',p_application_id => 'EGO',
		                                                  p_token_tbl => g_token_table,p_message_type => G_RET_STS_ERROR,
		                                                  p_row_identifier => p_attr_tbl(i).transaction_id,
		                                                  p_entity_code => G_ENTITY_ATTR,p_table_name => G_ENTITY_ATTR_TAB);
		        END IF;

		        /*Checks if the dynamic URL is mandatory*/

		        IF (p_attr_tbl(i).display_code = g_dyn_url_disp_type AND p_attr_tbl(i).info_1  IS NULL) THEN

		        	p_attr_tbl(i).process_status := G_ERROR_RECORD;

		        	x_return_status := G_RET_STS_ERROR;

		    		write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - Err_msg_TID: '||p_attr_tbl(i).transaction_id||' (AG,ATTR) = ('
		    		||p_attr_tbl(i).attr_group_name||','||p_attr_tbl(i).internal_name||'). ' ||'Value Set is mandatory for particular display');

		    		error_handler.Add_error_message(p_message_name => 'EGO_DYN_URL_MANDATORY',p_application_id => 'EGO',
		                                                  p_token_tbl => g_token_table,p_message_type => G_RET_STS_ERROR,
		                                                  p_row_identifier => p_attr_tbl(i).transaction_id,
		                                                  p_entity_code => G_ENTITY_ATTR,p_table_name => G_ENTITY_ATTR_TAB);
		        END IF;

		        /*Checks for existing sequence number - CREATE flow*/  --Added for 9625957
		        IF (p_attr_tbl(i).sequence IS NOT NULL AND p_attr_tbl(i).transaction_type = G_OPR_CREATE) THEN
		        	BEGIN
			        	SELECT 'Y' INTO lv_flag
				        FROM FND_DESCR_FLEX_COLUMN_USAGES
				       	WHERE APPLICATION_ID = G_EGO_APPLICATION_ID
				        AND DESCRIPTIVE_FLEXFIELD_NAME = p_attr_tbl(i).attr_group_type
				        AND DESCRIPTIVE_FLEX_CONTEXT_Code = p_attr_tbl(i).attr_group_name
				        AND COLUMN_SEQ_NUM = p_attr_tbl(i).sequence;

				        IF (lv_flag = 'Y') THEN
				        	p_attr_tbl(i).process_status := G_ERROR_RECORD;

				        	x_return_status := G_RET_STS_ERROR;

				        	write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - Err_msg_TID: '||p_attr_tbl(i).transaction_id||' (AG,ATTR) = ('
				        	||p_attr_tbl(i).attr_group_name||','||p_attr_tbl(i).internal_name||'). ' ||'SEQUENCE already exists in the system - CREATE');

				    		error_handler.Add_error_message(p_message_name => 'EGO_EF_CR_ATTR_DUP_SEQ_ERR',p_application_id => 'EGO',
				                                                  p_token_tbl => g_token_table,p_message_type => G_RET_STS_ERROR,
				                                                  p_row_identifier => p_attr_tbl(i).transaction_id,
				                                                  p_entity_code => G_ENTITY_ATTR,p_table_name => G_ENTITY_ATTR_TAB);

				            lv_flag := 'N';
				        END IF;

				    EXCEPTION
				    	WHEN NO_DATA_FOUND THEN
				    		NULL;
				    	WHEN OTHERS THEN
				    		x_return_status := G_RET_STS_UNEXP_ERROR;

				    		write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - Err_msg_TID: '||p_attr_tbl(i).transaction_id||' (AG,ATTR) = ('
				    		||p_attr_tbl(i).attr_group_name||','||p_attr_tbl(i).internal_name||'). ' ||'Exception - '||SQLERRM);

				    		error_handler.Add_error_message(p_message_text => SQLERRM,p_application_id => 'EGO',
				                                                  p_token_tbl => g_token_table,p_message_type => G_RET_STS_UNEXP_ERROR,
				                                                  p_row_identifier => p_attr_tbl(i).transaction_id,
				                                                  p_entity_code => G_ENTITY_ATTR,p_table_name => G_ENTITY_ATTR_TAB);
				    END;
		        END IF;

		        /*Checks for existing sequence number - UPDATE flow*/  --Added for 9625957
		        IF (p_attr_tbl(i).sequence IS NOT NULL AND p_attr_tbl(i).transaction_type = G_OPR_UPDATE) THEN
		        	DECLARE
		        	l_sequence NUMBER;
		        	BEGIN
		        		SELECT COLUMN_SEQ_NUM
				        INTO l_sequence
				        FROM FND_DESCR_FLEX_COLUMN_USAGES
				       WHERE APPLICATION_ID = G_EGO_APPLICATION_ID
				         AND DESCRIPTIVE_FLEXFIELD_NAME = p_attr_tbl(i).attr_group_type
				         AND DESCRIPTIVE_FLEX_CONTEXT_Code = p_attr_tbl(i).attr_group_name
				         AND END_USER_COLUMN_NAME = p_attr_tbl(i).internal_name;

				      IF (l_sequence <> NVL(p_attr_tbl(i).sequence, l_sequence)) THEN
				        -- If the sequence is being updated to a NEW non-null value,
				        -- check for uniqueness

				        SELECT COUNT(*)
				          INTO l_sequence
				          FROM FND_DESCR_FLEX_COLUMN_USAGES
				         WHERE APPLICATION_ID = G_EGO_APPLICATION_ID
				           AND DESCRIPTIVE_FLEXFIELD_NAME = p_attr_tbl(i).attr_group_type
				           AND DESCRIPTIVE_FLEX_CONTEXT_Code = p_attr_tbl(i).attr_group_name
				           AND COLUMN_SEQ_NUM = p_attr_tbl(i).sequence;

				        IF (l_sequence > 0) THEN

				        	p_attr_tbl(i).process_status := G_ERROR_RECORD;

				        	x_return_status := G_RET_STS_ERROR;

				        	write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - Err_msg_TID: '||p_attr_tbl(i).transaction_id||' (AG,ATTR) = ('
				        	||p_attr_tbl(i).attr_group_name||','||p_attr_tbl(i).internal_name||'). ' ||'SEQUENCE already exists in the system - UPDATE');

				    		error_handler.Add_error_message(p_message_name => 'EGO_EF_UP_ATTR_DUP_SEQ_ERR',p_application_id => 'EGO',
				                                                  p_token_tbl => g_token_table,p_message_type => G_RET_STS_ERROR,
				                                                  p_row_identifier => p_attr_tbl(i).transaction_id,
				                                                  p_entity_code => G_ENTITY_ATTR,p_table_name => G_ENTITY_ATTR_TAB);

				        END IF;
				      END IF;
				    EXCEPTION
				    	WHEN OTHERS THEN
				    		x_return_status := G_RET_STS_UNEXP_ERROR;

				    		write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - Err_msg_TID: '||p_attr_tbl(i).transaction_id||' (AG,ATTR) = ('
				    		||p_attr_tbl(i).attr_group_name||','||p_attr_tbl(i).internal_name||'). ' ||'Exception - '||SQLERRM);

				    		error_handler.Add_error_message(p_message_text => SQLERRM,p_application_id => 'EGO',
				                                                  p_token_tbl => g_token_table,p_message_type => G_RET_STS_UNEXP_ERROR,
				                                                  p_row_identifier => p_attr_tbl(i).transaction_id,
				                                                  p_entity_code => G_ENTITY_ATTR,p_table_name => G_ENTITY_ATTR_TAB);
				    END;
		        END IF;

		        /*Checks for existing column name - CREATE flow*/  --Added for 9625957
		        IF (p_attr_tbl(i).application_column_name IS NOT NULL AND p_attr_tbl(i).transaction_type = G_OPR_CREATE) THEN
		        	BEGIN
			        	SELECT 'Y' INTO lv_flag
				        FROM FND_DESCR_FLEX_COLUMN_USAGES
				       	WHERE APPLICATION_ID = G_EGO_APPLICATION_ID
				        AND DESCRIPTIVE_FLEXFIELD_NAME = p_attr_tbl(i).attr_group_type
				        AND DESCRIPTIVE_FLEX_CONTEXT_Code = p_attr_tbl(i).attr_group_name
				        AND application_column_name = p_attr_tbl(i).application_column_name;

				        IF (lv_flag = 'Y') THEN
				        	p_attr_tbl(i).process_status := G_ERROR_RECORD;

				        	x_return_status := G_RET_STS_ERROR;

				        	write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - Err_msg_TID: '||p_attr_tbl(i).transaction_id||' (AG,ATTR) = ('
				        	||p_attr_tbl(i).attr_group_name||','||p_attr_tbl(i).internal_name||'). ' ||'SEQUENCE already exists in the system - CREATE');

				    		error_handler.Add_error_message(p_message_name => 'EGO_EF_CR_ATTR_DUP_COL_ERR',p_application_id => 'EGO',
				                                                  p_token_tbl => g_token_table,p_message_type => G_RET_STS_ERROR,
				                                                  p_row_identifier => p_attr_tbl(i).transaction_id,
				                                                  p_entity_code => G_ENTITY_ATTR,p_table_name => G_ENTITY_ATTR_TAB);

				            lv_flag := 'N';
				        END IF;

				    EXCEPTION
				    	WHEN NO_DATA_FOUND THEN
				    		NULL;
				    	WHEN OTHERS THEN
				    		x_return_status := G_RET_STS_UNEXP_ERROR;

				    		write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - Err_msg_TID: '||p_attr_tbl(i).transaction_id||' (AG,ATTR) = ('
				    		||p_attr_tbl(i).attr_group_name||','||p_attr_tbl(i).internal_name||'). ' ||'Exception - '||SQLERRM);

				    		error_handler.Add_error_message(p_message_text => SQLERRM,p_application_id => 'EGO',
				                                                  p_token_tbl => g_token_table,p_message_type => G_RET_STS_UNEXP_ERROR,
				                                                  p_row_identifier => p_attr_tbl(i).transaction_id,
				                                                  p_entity_code => G_ENTITY_ATTR,p_table_name => G_ENTITY_ATTR_TAB);
				    END;
		        END IF;

		        /*Checks for existing column name - UPDATE flow*/  --Added for 9625957
		        IF (p_attr_tbl(i).sequence IS NOT NULL AND p_attr_tbl(i).transaction_type = G_OPR_UPDATE) THEN
		        	DECLARE
		        	lv_column VARCHAR2(40);
		        	lv_count NUMBER;
		        	BEGIN
		        		SELECT application_column_name
				        INTO lv_column
				        FROM FND_DESCR_FLEX_COLUMN_USAGES
				       WHERE APPLICATION_ID = G_EGO_APPLICATION_ID
				         AND DESCRIPTIVE_FLEXFIELD_NAME = p_attr_tbl(i).attr_group_type
				         AND DESCRIPTIVE_FLEX_CONTEXT_Code = p_attr_tbl(i).attr_group_name
				         AND END_USER_COLUMN_NAME = p_attr_tbl(i).internal_name;

				      IF (lv_column <> NVL(p_attr_tbl(i).application_column_name, lv_column)) THEN
				        -- If the sequence is being updated to a NEW non-null value,
				        -- check for uniqueness

				        SELECT COUNT(*)
				          INTO lv_count
				          FROM FND_DESCR_FLEX_COLUMN_USAGES
				         WHERE APPLICATION_ID = G_EGO_APPLICATION_ID
				           AND DESCRIPTIVE_FLEXFIELD_NAME = p_attr_tbl(i).attr_group_type
				           AND DESCRIPTIVE_FLEX_CONTEXT_Code = p_attr_tbl(i).attr_group_name
				           AND application_column_name = p_attr_tbl(i).application_column_name;

				        IF (lv_count > 0) THEN

				        	p_attr_tbl(i).process_status := G_ERROR_RECORD;

				        	x_return_status := G_RET_STS_ERROR;

				        	write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - Err_msg_TID: '||p_attr_tbl(i).transaction_id||' (AG,ATTR) = ('
				        	||p_attr_tbl(i).attr_group_name||','||p_attr_tbl(i).internal_name||'). ' ||'SEQUENCE already exists in the system - UPDATE');

				    		error_handler.Add_error_message(p_message_name => 'EGO_EF_UP_ATTR_DUP_SEQ_ERR',p_application_id => 'EGO',
				                                                  p_token_tbl => g_token_table,p_message_type => G_RET_STS_ERROR,
				                                                  p_row_identifier => p_attr_tbl(i).transaction_id,
				                                                  p_entity_code => G_ENTITY_ATTR,p_table_name => G_ENTITY_ATTR_TAB);


				        END IF;
				      END IF;
				    EXCEPTION
				    	WHEN OTHERS THEN
				    		x_return_status := G_RET_STS_UNEXP_ERROR;

				    		write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - Err_msg_TID: '||p_attr_tbl(i).transaction_id||' (AG,ATTR) = ('
				    		||p_attr_tbl(i).attr_group_name||','||p_attr_tbl(i).internal_name||'). ' ||'Exception - '||SQLERRM);

				    		error_handler.Add_error_message(p_message_text => SQLERRM,p_application_id => 'EGO',
				                                                  p_token_tbl => g_token_table,p_message_type => G_RET_STS_UNEXP_ERROR,
				                                                  p_row_identifier => p_attr_tbl(i).transaction_id,
				                                                  p_entity_code => G_ENTITY_ATTR,p_table_name => G_ENTITY_ATTR_TAB);
				    END;
		        END IF;

		        /*Checks for the correct combination of column name and data type*/ --Added for 9625957

		        DECLARE
			    	l_table_name VARCHAR2(40);
			    	l_chg_table_name VARCHAR2(40);
			    	l_col_data_type VARCHAR2(1);
			    	l_col_width NUMBER;
		        BEGIN
					------------------------------------------------------------------------
				    -- Find the correct table name for use in validating column data type --
				    ------------------------------------------------------------------------

				    IF (p_attr_tbl(i).data_type = G_TRANS_TEXT_DATA_TYPE) THEN
				      l_table_name := Get_TL_Table_Name(G_EGO_APPLICATION_ID
				                                       ,p_attr_tbl(i).attr_group_type);
				      l_chg_table_name:=Get_Attr_Changes_TL_Table(p_application_id => G_EGO_APPLICATION_ID
				                                       ,p_attr_group_type => p_attr_tbl(i).attr_group_type);--for getting the pending table
				    ELSE
				      l_table_name := Get_Table_Name(G_EGO_APPLICATION_ID
				                                       ,p_attr_tbl(i).attr_group_type);
				      l_chg_table_name:=Get_Attr_Changes_B_Table(p_application_id => G_EGO_APPLICATION_ID
				                                       ,p_attr_group_type => p_attr_tbl(i).attr_group_type);--for getting the pending table

				    END IF;--IF (l_data_type_is_trans_text)

				      SELECT COLUMN_TYPE , WIDTH
				        INTO l_col_data_type, l_col_width
				        FROM FND_COLUMNS
				       WHERE COLUMN_NAME = p_attr_tbl(i).application_column_name
				         AND TABLE_ID = (SELECT TABLE_ID
				                           FROM FND_TABLES
				                          WHERE TABLE_NAME = l_table_name);

				      IF (p_attr_tbl(i).transaction_type <> G_OPR_DELETE AND
				      	   ((p_attr_tbl(i).data_type = G_CHAR_DATA_TYPE OR
				            p_attr_tbl(i).data_type = G_TRANS_TEXT_DATA_TYPE) AND
				           l_col_data_type <> 'V') OR
				          (p_attr_tbl(i).data_type = G_NUMBER_DATA_TYPE AND l_col_data_type <> 'N') OR
				          ((p_attr_tbl(i).data_type = G_DATE_DATA_TYPE OR
				            p_attr_tbl(i).data_type = G_DATE_TIME_DATA_TYPE) AND
				           l_col_data_type <> 'D')) THEN

							/***
							TO DO: right now we can't verify that TransText Attributes use TL-type columns,
							because we can't rely on the column being named 'TL_EXT_ATTR%' and we aren't
							using FND_COLUMNS's TRANSLATE_FLAG column yet; but we should be, and we should
							add to the IF check above that if the data type is TransText and the column's
							TRANSLATE_FLAG isn't 'Y' then we should error out.
							***/
							p_attr_tbl(i).process_status := G_ERROR_RECORD;

				        	x_return_status := G_RET_STS_ERROR;

				        	write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - Err_msg_TID: '||p_attr_tbl(i).transaction_id||' (AG,ATTR) = ('
				        	||p_attr_tbl(i).attr_group_name||','||p_attr_tbl(i).internal_name||'). ' ||'Column name and data type dont match');

				    		error_handler.Add_error_message(p_message_name => 'EGO_EF_CR_ATTR_COL_DT_ERR',p_application_id => 'EGO',
			                                                p_token_tbl => g_token_table,p_message_type => G_RET_STS_ERROR,
			                                                p_row_identifier => p_attr_tbl(i).transaction_id,
			                                                p_entity_code => G_ENTITY_ATTR,p_table_name => G_ENTITY_ATTR_TAB);


				      END IF;

				      IF ( (p_attr_tbl(i).data_type = G_CHAR_DATA_TYPE OR
				            p_attr_tbl(i).data_type = G_TRANS_TEXT_DATA_TYPE) AND
				            LENGTH(p_attr_tbl(i).default_value) >  l_col_width )THEN

				        	p_attr_tbl(i).process_status := G_ERROR_RECORD;

				        	x_return_status := G_RET_STS_ERROR;

				        	write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - Err_msg_TID: '||p_attr_tbl(i).transaction_id||' (AG,ATTR) = ('
				        	||p_attr_tbl(i).attr_group_name||','||p_attr_tbl(i).internal_name||'). ' ||'Default value exceeds the acceptable length');

				    		error_handler.Add_error_message(p_message_name => 'EGO_EF_DEFAULT_VAL_LEN_ERR',p_application_id => 'EGO',
				                                                  p_token_tbl => g_token_table,p_message_type => G_RET_STS_ERROR,
				                                                  p_row_identifier => p_attr_tbl(i).transaction_id,
				                                                  p_entity_code => G_ENTITY_ATTR,p_table_name => G_ENTITY_ATTR_TAB);


				      END IF;

			    EXCEPTION
			      WHEN NO_DATA_FOUND THEN
			      		IF (p_attr_tbl(i).transaction_type <> G_OPR_DELETE) THEN
			        -- whoever owns the table didn't seed the column correctly
			        		p_attr_tbl(i).process_status := G_ERROR_RECORD;

				        	x_return_status := G_RET_STS_ERROR;

				        	write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - Err_msg_TID: '||p_attr_tbl(i).transaction_id||' (AG,ATTR) = ('
				        	||p_attr_tbl(i).attr_group_name||','||p_attr_tbl(i).internal_name||'). ' ||'Column name and data type dont match');

				    		error_handler.Add_error_message(p_message_name => 'EGO_EF_CR_ATTR_COL_DT_ERR',p_application_id => 'EGO',
				                                                  p_token_tbl => g_token_table,p_message_type => G_RET_STS_ERROR,
				                                                  p_row_identifier => p_attr_tbl(i).transaction_id,
				                                                  p_entity_code => G_ENTITY_ATTR,p_table_name => G_ENTITY_ATTR_TAB);
				         END IF;
			    END;

			    /*Check for invalid Required flag*/
	    		IF (NVL(p_attr_tbl(i).required_flag,'N') IN ('Y','N')) THEN
	    			p_attr_tbl(i).required_flag := NVL(p_attr_tbl(i).required_flag,'N');
	    		ELSE
	    			p_attr_tbl(i).process_status := G_ERROR_RECORD;

			        x_return_status := G_RET_STS_ERROR;

			      	write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - Err_msg_TID: '||p_attr_tbl(i).transaction_id||' (AG,ATTR) = ('
			      	||p_attr_tbl(i).attr_group_name||','||p_attr_tbl(i).internal_name||'). ' ||'Invalid required flag.');

			      	G_TOKEN_TABLE(1).Token_Name   :=  'COL_NAME';
           			G_TOKEN_TABLE(1).Token_Value  :=  'REQUIRED_FLAG';

			        error_handler.Add_error_message(p_message_name => 'EGO_INVALID_VALUE_FOR_COL',p_application_id => 'EGO',
	                                                  p_token_tbl => g_token_table,p_message_type => G_RET_STS_ERROR,
	                                                  p_row_identifier => p_attr_tbl(i).transaction_id,
	                                                  p_entity_code => G_ENTITY_ATTR,p_table_name => G_ENTITY_ATTR_TAB);

	                G_TOKEN_TABLE.DELETE;

	    		END IF;

	    		/*Check for invalid enabled flag*/
	    		IF (NVL(p_attr_tbl(i).enabled_flag,'N') IN ('Y','N')) THEN
	    			p_attr_tbl(i).enabled_flag := NVL(p_attr_tbl(i).enabled_flag,'N');
	    		ELSE
	    			p_attr_tbl(i).process_status := G_ERROR_RECORD;

			        x_return_status := G_RET_STS_ERROR;

			      	write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - Err_msg_TID: '||p_attr_tbl(i).transaction_id||' (AG,ATTR) = ('
			      	||p_attr_tbl(i).attr_group_name||','||p_attr_tbl(i).internal_name||'). ' ||'Invalid enabled flag.');

			      	G_TOKEN_TABLE(1).Token_Name   :=  'COL_NAME';
           			G_TOKEN_TABLE(1).Token_Value  :=  'ENABLED_FLAG';

			        error_handler.Add_error_message(p_message_name => 'EGO_INVALID_VALUE_FOR_COL',p_application_id => 'EGO',
	                                                  p_token_tbl => g_token_table,p_message_type => G_RET_STS_ERROR,
	                                                  p_row_identifier => p_attr_tbl(i).transaction_id,
	                                                  p_entity_code => G_ENTITY_ATTR,p_table_name => G_ENTITY_ATTR_TAB);

	                G_TOKEN_TABLE.DELETE;

	    		END IF;

	    		/*Check for invalid security enabled flag*/
	    		IF (NVL(p_attr_tbl(i).security_enabled_flag,'N') IN ('Y','N')) THEN
	    			p_attr_tbl(i).security_enabled_flag := NVL(p_attr_tbl(i).security_enabled_flag,'N');
	    		ELSE
	    			p_attr_tbl(i).process_status := G_ERROR_RECORD;

			        x_return_status := G_RET_STS_ERROR;

			      	write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - Err_msg_TID: '||p_attr_tbl(i).transaction_id||' (AG,ATTR) = ('
			      	||p_attr_tbl(i).attr_group_name||','||p_attr_tbl(i).internal_name||'). ' ||'Invalid security enabled flag.');

			      	G_TOKEN_TABLE(1).Token_Name   :=  'COL_NAME';
           			G_TOKEN_TABLE(1).Token_Value  :=  'SECURITY_ENABLED_FLAG';

			        error_handler.Add_error_message(p_message_name => 'EGO_INVALID_VALUE_FOR_COL',p_application_id => 'EGO',
	                                                  p_token_tbl => g_token_table,p_message_type => G_RET_STS_ERROR,
	                                                  p_row_identifier => p_attr_tbl(i).transaction_id,
	                                                  p_entity_code => G_ENTITY_ATTR,p_table_name => G_ENTITY_ATTR_TAB);

	                G_TOKEN_TABLE.DELETE;

	    		END IF;

	    		/*Check for invalid searchable flag*/
	    		IF (NVL(p_attr_tbl(i).search_flag,'N') IN ('Y','N')) THEN
	    			p_attr_tbl(i).search_flag := NVL(p_attr_tbl(i).search_flag,'N');
	    		ELSE
	    			p_attr_tbl(i).process_status := G_ERROR_RECORD;

			        x_return_status := G_RET_STS_ERROR;

			      	write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - Err_msg_TID: '||p_attr_tbl(i).transaction_id||' (AG,ATTR) = ('
			      	||p_attr_tbl(i).attr_group_name||','||p_attr_tbl(i).internal_name||'). ' ||'Invalid searchable flag.');

			      	G_TOKEN_TABLE(1).Token_Name   :=  'COL_NAME';
           			G_TOKEN_TABLE(1).Token_Value  :=  'SEARCH_FLAG';

			        error_handler.Add_error_message(p_message_name => 'EGO_INVALID_VALUE_FOR_COL',p_application_id => 'EGO',
	                                                  p_token_tbl => g_token_table,p_message_type => G_RET_STS_ERROR,
	                                                  p_row_identifier => p_attr_tbl(i).transaction_id,
	                                                  p_entity_code => G_ENTITY_ATTR,p_table_name => G_ENTITY_ATTR_TAB);

	                G_TOKEN_TABLE.DELETE;

	    		END IF;

	    		/*Check for invalid Unique Key flag*/
	    		IF (NVL(p_attr_tbl(i).unique_key_flag,'N') IN ('Y','N')) THEN
	    			p_attr_tbl(i).unique_key_flag := NVL(p_attr_tbl(i).unique_key_flag,'N');
	    		ELSE
	    			p_attr_tbl(i).process_status := G_ERROR_RECORD;

			        x_return_status := G_RET_STS_ERROR;

			      	write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - Err_msg_TID: '||p_attr_tbl(i).transaction_id||' (AG,ATTR) = ('
			      	||p_attr_tbl(i).attr_group_name||','||p_attr_tbl(i).internal_name||'). ' ||'Invalid unique key flag.');

			      	G_TOKEN_TABLE(1).Token_Name   :=  'COL_NAME';
           			G_TOKEN_TABLE(1).Token_Value  :=  'UNIQUE_KEY_FLAG';

			        error_handler.Add_error_message(p_message_name => 'EGO_INVALID_VALUE_FOR_COL',p_application_id => 'EGO',
	                                                  p_token_tbl => g_token_table,p_message_type => G_RET_STS_ERROR,
	                                                  p_row_identifier => p_attr_tbl(i).transaction_id,
	                                                  p_entity_code => G_ENTITY_ATTR,p_table_name => G_ENTITY_ATTR_TAB);

	                G_TOKEN_TABLE.DELETE;

	    		END IF;
		END IF;
	END LOOP;
	write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Exit Common_attr_validations');
  EXCEPTION
    WHEN OTHERS THEN
      write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Common_attr_validations Exception when others'||SQLERRM);

      x_return_status := G_RET_STS_UNEXP_ERROR;

      x_return_msg := 'ego_ag_bulkload_pvt.Common_attr_validations - '||SQLERRM;

   	  RETURN;
  END Common_attr_validations;

  /*This procedure is used to do additional validations on attribute groups.
  	Used in the API flow.
  	p_ag_tbl        IN OUT NOCOPY  Attribute group plsql table
  	x_return_status OUT NOCOPY parameter that returns the status*/
  PROCEDURE Additional_agdl_validations
       (p_ag_tbl         IN OUT NOCOPY ego_metadata_pub.ego_attr_groups_tbl,
        p_agdl_tbl       IN OUT NOCOPY ego_metadata_pub.ego_attr_groups_dl_tbl,
        x_return_status OUT NOCOPY VARCHAR2, x_return_msg OUT NOCOPY VARCHAR2)
  IS
    lv_smt   NUMBER; --Statement counter
    lv_flag  VARCHAR2(1);
    lv_proc VARCHAR2(30) := 'Additional_agdl_validations';
  BEGIN
    write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Entering Additional_agdl_validations');

    x_return_status := G_RET_STS_SUCCESS;

    lv_smt := 1;

    write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Statement 1');

    /*Check for invalid transaction type in the AG table*/
    FOR i IN p_ag_tbl.FIRST.. p_ag_tbl.LAST LOOP
      /*Convert transaction type to upper case*/
      SELECT Upper(P_ag_tbl(i).transaction_type)
      INTO   P_ag_tbl(i).transaction_type
      FROM   dual;

      IF ( P_ag_tbl(i).transaction_type = G_OPR_CREATE
           OR P_ag_tbl(i).transaction_type = G_OPR_UPDATE
           OR P_ag_tbl(i).transaction_type = G_OPR_DELETE
           OR P_ag_tbl(i).transaction_type = G_OPR_SYNC) THEN
           NULL;
      ELSE
        write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Transaction type Invalid for AG');

        P_ag_tbl(i).process_status := G_ERROR_RECORD;

        x_return_status := G_RET_STS_ERROR;

      	error_handler.Add_error_message(p_message_name => 'EGO_TRANS_TYPE_INVALID',p_application_id => 'EGO',
                                      	p_token_tbl => g_token_table,p_message_type => G_RET_STS_ERROR,
                                      	p_row_identifier => P_ag_tbl(i).transaction_id,
                                      	p_entity_code => G_ENTITY_AG,p_table_name => G_ENTITY_AG_TAB);
      END IF;

      /*Checks if the attribute group type passed is EGO_ITEMMGMT_GROUP or else thows the error EGO_AG_TYPE_INVALID*/
      IF (P_ag_tbl(i).attr_group_type <> G_EGO_ITEMMGMT_GROUP) THEN
        P_ag_tbl(i).process_status := G_ERROR_RECORD;

        x_return_status := G_RET_STS_ERROR;

        write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Attribute group Type passed is incorrect');

      	error_handler.Add_error_message(p_message_name => 'EGO_AG_TYPE_INVALID',p_application_id => 'EGO',
                                      	p_token_tbl => g_token_table,p_message_type => G_RET_STS_ERROR,
                                      	p_row_identifier => P_ag_tbl(i).transaction_id,
                                      	p_entity_code => G_ENTITY_AG,p_table_name => G_ENTITY_AG_TAB);
      END IF;
    END LOOP;

    lv_smt := 2;

    write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Statement 2');

    /*Check for invalid transaction type in the DL table*/
    FOR i IN p_agdl_tbl.FIRST.. p_agdl_tbl.LAST LOOP
      /*Convert transaction type to upper case*/
      SELECT Upper(P_agdl_tbl(i).transaction_type)
      INTO   P_agdl_tbl(i).transaction_type
      FROM   dual;

      IF ( P_agdl_tbl(i).transaction_type = G_OPR_CREATE
           OR P_agdl_tbl(i).transaction_type = G_OPR_UPDATE
           OR P_agdl_tbl(i).transaction_type = G_OPR_SYNC) THEN
           NULL;
      ELSE
        write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Transaction type is invalid for DL');

        P_agdl_tbl(i).process_status := G_ERROR_RECORD;

        x_return_status := G_RET_STS_ERROR;

        write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Invalid transaction type for DL');

      	error_handler.Add_error_message(p_message_name => 'EGO_TRANS_TYPE_INVALID',p_application_id => 'EGO',
                                      	p_token_tbl => g_token_table,p_message_type => G_RET_STS_ERROR,
                                      	p_row_identifier => P_agdl_tbl(i).transaction_id,
                                      	p_entity_code => G_ENTITY_DL,p_table_name => G_ENTITY_DL_TAB);

      END IF;

      /*Checks if the attribute group type passed is EGO_ITEMMGMT_GROUP or else thows the error EGO_AG_TYPE_INVALID*/
      IF (P_agdl_tbl(i).attr_group_type <> G_EGO_ITEMMGMT_GROUP) THEN
        P_agdl_tbl(i).process_status := G_ERROR_RECORD;

        x_return_status := G_RET_STS_ERROR;

        write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Attribute group Type passed is incorrect');

      	error_handler.Add_error_message(p_message_name => 'EGO_AG_TYPE_INVALID',p_application_id => 'EGO',
                                      	p_token_tbl => g_token_table,p_message_type => G_RET_STS_ERROR,
                                      	p_row_identifier => P_agdl_tbl(i).transaction_id,
                                      	p_entity_code => G_ENTITY_DL,p_table_name => G_ENTITY_DL_TAB);

      END IF;
    END LOOP;

    /*Value to ID Conversions for AG*/
    Value_to_id_ag_tbl(p_ag_tbl,x_return_status, x_return_msg); IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN RETURN; END IF;

    lv_smt := 3;

    write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Statement 3');

    /*If the attribute group in the DL plsql table doesn't exist in the system as well in the AG plsql table then error OUT NOCOPY with message EGO_AG_INVALID*/
    FOR i IN p_agdl_tbl.FIRST.. p_ag_tbl.LAST LOOP
      IF (P_agdl_tbl(i).process_status = G_PROCESS_RECORD) THEN
        IF (P_agdl_tbl(i).attr_group_name  IS NOT NULL
            AND P_agdl_tbl(i).attr_group_id  IS NULL) THEN
          BEGIN
            SELECT attr_group_id
            INTO   P_agdl_tbl(i).attr_group_id
            FROM   ego_fnd_dsc_flx_ctx_ext
            WHERE  application_id = g_ego_application_id
                   AND descriptive_flexfield_name = P_agdl_tbl(i).attr_group_type
                   AND descriptive_flex_context_code = P_agdl_tbl(i).attr_group_name;
          EXCEPTION
            WHEN no_data_found THEN
              IF (P_agdl_tbl(i).transaction_type = G_OPR_UPDATE) THEN
                P_agdl_tbl(i).process_status := G_ERROR_RECORD;

                x_return_status := G_RET_STS_ERROR;

                write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Attribute Group does not exist');

                error_handler.Add_error_message(p_message_name => 'EGO_AG_INVALID',p_application_id => 'EGO',
                                                p_token_tbl => g_token_table,p_message_type => G_RET_STS_ERROR,
                                                p_row_identifier => P_agdl_tbl(i).transaction_id,
                                                p_entity_code => G_ENTITY_DL,p_table_name => G_ENTITY_DL_TAB);

              ELSE
                lv_flag := 'N';

                FOR i IN p_ag_tbl.FIRST.. p_agdl_tbl.LAST LOOP
                  IF (P_ag_tbl(i).process_status = G_PROCESS_RECORD
                      AND P_ag_tbl(i).transaction_type = G_OPR_CREATE
                      AND (G_SET_PROCESS_ID IS NULL
                            OR P_ag_tbl(i).set_process_id = G_SET_PROCESS_ID)) THEN
                    IF (P_agdl_tbl(i).attr_group_name = P_agdl_tbl(i).attr_group_name) THEN
                      lv_flag := 'Y';

                      IF (P_agdl_tbl(i).transaction_type = G_OPR_SYNC) THEN
                        P_agdl_tbl(i).transaction_type := G_OPR_CREATE;
                      END IF;
                    END IF;
                  END IF;
                END LOOP;

                IF (lv_flag = 'N') THEN
                  write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Attribute Group in the DL plsql table does not exist in the system or in the AG plsql table');

                  P_agdl_tbl(i).process_status := G_ERROR_RECORD;

                  x_return_status := G_RET_STS_ERROR;

                  error_handler.Add_error_message(p_message_name => 'EGO_AG_INVALID',p_application_id => 'EGO',
                                                  p_token_tbl => g_token_table,p_message_type => G_RET_STS_ERROR,
                                                  p_row_identifier => P_agdl_tbl(i).transaction_id,
                                                  p_entity_code => G_ENTITY_DL,p_table_name => G_ENTITY_DL_tab);
                END IF;
              END IF;
            WHEN OTHERS THEN
              write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Additional_agdl_validations Exception when others smt 3');

              x_return_status := G_RET_STS_UNEXP_ERROR;

              error_handler.Add_error_message(p_message_text => sqlerrm,p_application_id => 'EGO',
                                              p_token_tbl => g_token_table,p_message_type => G_RET_STS_UNEXP_ERROR,
                                              p_row_identifier => P_agdl_tbl(i).transaction_id,
                                              p_entity_code => G_ENTITY_DL,p_table_name => G_ENTITY_DL_tab);

              x_return_msg := 'ego_ag_bulkload_pvt.Additional_agdl_validations smt 3 - '||SQLERRM;

   	  		  RETURN;
          END;
        END IF;
      END IF;
    END LOOP;

    /*Value to ID Conversions for DL*/
    Value_to_id_dl_tbl(p_agdl_tbl,x_return_status, x_return_msg); IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN RETURN; END IF;

    lv_smt := 4;

    write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Statement 4');

    /*For a AG record of transaction Type CREATE there should be atleast one record in the DL record. Else error OUT NOCOPY EGO_EF_DL_REQD_AG*/
    FOR i IN p_ag_tbl.FIRST.. p_ag_tbl.LAST LOOP
      lv_flag := 'N';

      IF P_ag_tbl(i).transaction_type = G_OPR_CREATE THEN
        FOR i IN p_agdl_tbl.FIRST.. p_agdl_tbl.LAST LOOP
          IF P_agdl_tbl(i).attr_group_name = P_ag_tbl(i).attr_group_name THEN
            lv_flag := 'Y';
          END IF;
        END LOOP;

        IF (lv_flag = 'N') THEN
          write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Please insert at least one business entity when creating an Attribute Group');

          P_ag_tbl(i).process_status := G_ERROR_RECORD;

          x_return_status := G_RET_STS_ERROR;

          error_handler.Add_error_message(p_message_name => 'EGO_EF_DL_REQD_AG',p_application_id => 'EGO',
                                          p_token_tbl => g_token_table,p_message_type => G_RET_STS_ERROR,
                                          p_row_identifier => P_agdl_tbl(i).transaction_id,
                                          p_entity_code => G_ENTITY_DL,p_table_name => G_ENTITY_DL_tab);
        END IF;
      END IF;
    END LOOP;

    lv_smt := 5;

    write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Statement 5');

    /*Additional Validations for AG*/
    FOR i IN p_ag_tbl.FIRST.. p_ag_tbl.LAST LOOP
      IF (P_ag_tbl(i).process_status = G_PROCESS_RECORD) THEN
        /*Sets the Attribute Name if Attribute ID exists. If it doesn't exist, then flags an error EGO_AG_INVALID*/
        IF (P_ag_tbl(i).attr_group_id  IS NOT NULL
            AND P_ag_tbl(i).attr_group_name  IS NULL
            AND P_ag_tbl(i).transaction_type = G_OPR_UPDATE) THEN
          BEGIN
            SELECT descriptive_flex_context_code
            INTO   P_ag_tbl(i).attr_group_name
            FROM   ego_fnd_dsc_flx_ctx_ext
            WHERE  application_id = g_ego_application_id
                   AND descriptive_flexfield_name = P_ag_tbl(i).attr_group_type
                   AND descriptive_flex_context_code = P_ag_tbl(i).attr_group_id;
          EXCEPTION
            WHEN no_data_found THEN
              write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Attribute group does not exist in the system');

              P_ag_tbl(i).process_status := G_ERROR_RECORD;

              x_return_status := G_RET_STS_ERROR;

              error_handler.Add_error_message(p_message_name => 'EGO_AG_INVALID',p_application_id => 'EGO',
                                              p_token_tbl => g_token_table,p_message_type => G_RET_STS_ERROR,
                                              p_row_identifier => P_ag_tbl(i).transaction_id,
                                              p_entity_code => G_ENTITY_AG,p_table_name => G_ENTITY_AG_TAB);
            WHEN OTHERS THEN
              write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Additional_agdl_validations Exception when others smt 5');

              x_return_status := G_RET_STS_UNEXP_ERROR;

              error_handler.Add_error_message(p_message_text => sqlerrm,p_application_id => 'EGO',
                                              p_token_tbl => g_token_table,p_message_type => G_RET_STS_UNEXP_ERROR,
                                              p_row_identifier => P_ag_tbl(i).transaction_id,
                                              p_entity_code => G_ENTITY_AG,p_table_name => G_ENTITY_AG_TAB);

              x_return_msg := 'ego_ag_bulkload_pvt.Additional_agdl_validations smt 5 - '||SQLERRM;

   	  		  RETURN;
          END;
        END IF;

        /*Defaults the MULTROW column to N if not provided*/
        IF (P_ag_tbl(i).multi_row  IS NULL
            AND P_ag_tbl(i).transaction_type = G_OPR_CREATE) THEN
          P_ag_tbl(i).multi_row := 'N';
        END IF;

        /*If the attribute group internal name or the display name is null for the CREATE flow then flag an error EGO_AG_MANDATORY*/
        IF ((P_ag_tbl(i).attr_group_name  IS NULL
              OR P_ag_tbl(i).attr_group_disp_name  IS NULL)
            AND P_ag_tbl(i).transaction_type = G_OPR_CREATE) THEN
          write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Attribute group internal name and display name are not provided in the CREATE flow');

          P_agdl_tbl(i).process_status := G_ERROR_RECORD;

          x_return_status := G_RET_STS_ERROR;

          error_handler.Add_error_message(p_message_name => 'EGO_AG_MANDATORY',p_application_id => 'EGO',
                                          p_token_tbl => g_token_table,p_message_type => G_RET_STS_ERROR,
                                          p_row_identifier => P_ag_tbl(i).transaction_id,
                                          p_entity_code => G_ENTITY_AG,p_table_name => G_ENTITY_AG_TAB);
        END IF;
      END IF;
    END LOOP;

    lv_smt := 6;

    write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Statement 6');

    /*Additional Validation for DL*/
    FOR i IN p_agdl_tbl.FIRST.. p_agdl_tbl.LAST LOOP
      IF (P_agdl_tbl(i).process_status = G_PROCESS_RECORD) THEN
        /*Sets the Attribute Name if Attribute ID exists. If it doesn't exist, then flags an error EGO_AG_INVALID*/
        IF (P_agdl_tbl(i).attr_group_id  IS NOT NULL
            AND P_agdl_tbl(i).attr_group_name  IS NULL
            AND P_agdl_tbl(i).transaction_type = G_OPR_UPDATE) THEN
          BEGIN
            SELECT descriptive_flex_context_code
            INTO   P_agdl_tbl(i).attr_group_name
            FROM   ego_fnd_dsc_flx_ctx_ext
            WHERE  application_id = g_ego_application_id
                   AND descriptive_flexfield_name = P_agdl_tbl(i).attr_group_type
                   AND descriptive_flex_context_code = P_agdl_tbl(i).attr_group_id;
          EXCEPTION
            WHEN no_data_found THEN
              write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Attribute group does not exist in the system');

              P_agdl_tbl(i).process_status := G_ERROR_RECORD;

              x_return_status := G_RET_STS_ERROR;

              error_handler.Add_error_message(p_message_name => 'EGO_AG_INVALID',p_application_id => 'EGO',
                                              p_token_tbl => g_token_table,p_message_type => G_RET_STS_ERROR,
                                              p_row_identifier => P_agdl_tbl(i).transaction_id,
                                              p_entity_code => G_ENTITY_DL,p_table_name => G_ENTITY_DL_tab);
            WHEN OTHERS THEN
              write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Additional_agdl_validations Exception when others smt 6');

              x_return_status := G_RET_STS_UNEXP_ERROR;

              error_handler.Add_error_message(p_message_text => sqlerrm,p_application_id => 'EGO',
                                              p_token_tbl => g_token_table,p_message_type => G_RET_STS_UNEXP_ERROR,
                                              p_row_identifier => P_agdl_tbl(i).transaction_id,
                                              p_entity_code => G_ENTITY_DL,p_table_name => G_ENTITY_DL_tab);

              x_return_msg := 'ego_ag_bulkload_pvt.Additional_agdl_validations smt 6 - '||SQLERRM;

   	  		  RETURN;
          END;
        END IF;
      END IF;

      /*Sets the View Privilege when the ID is given then flags an error EGO_VIEW_PRIV_NOT_EXIST*/
      IF (P_agdl_tbl(i).view_privilege_id IS NOT NULL
      	  AND P_agdl_tbl(i).view_privilege_id <> G_NULL_CHAR
          AND P_agdl_tbl(i).view_privilege_name  IS NULL) THEN
        BEGIN
          SELECT function_name
          INTO   P_agdl_tbl(i).view_privilege_name
          FROM   fnd_form_functions
          WHERE  function_id = P_agdl_tbl(i).view_privilege_id;
        EXCEPTION
          WHEN no_data_found THEN
            write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'View Privilege provided is invalid');

            P_agdl_tbl(i).process_status := G_ERROR_RECORD;

            x_return_status := G_RET_STS_ERROR;

            error_handler.Add_error_message(p_message_name => 'EGO_VIEW_PRIV_NOT_EXIST',
                                            p_application_id => 'EGO',p_token_tbl => g_token_table,
                                            p_message_type => G_RET_STS_ERROR,p_row_identifier => P_agdl_tbl(i).transaction_id,
                                            p_entity_code => G_ENTITY_DL,p_table_name => G_ENTITY_DL_tab);
          WHEN OTHERS THEN
            write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Additional_agdl_validations Exception when others smt 7');

            x_return_status := G_RET_STS_UNEXP_ERROR;

            error_handler.Add_error_message(p_message_text => sqlerrm,p_application_id => 'EGO',
                                            p_token_tbl => g_token_table,p_message_type => G_RET_STS_UNEXP_ERROR,
                                            p_row_identifier => P_agdl_tbl(i).transaction_id,
                                            p_entity_code => G_ENTITY_DL,p_table_name => G_ENTITY_DL_tab);

            x_return_msg := 'ego_ag_bulkload_pvt.Additional_agdl_validations smt 7 - '||SQLERRM;

   	  		RETURN;
        END;
      END IF;

      /*Sets the Edit Privilege when the ID is given then flags an error EGO_EDITW_PRIV_NOT_EXIST*/
      IF (P_agdl_tbl(i).edit_privilege_id IS NOT NULL
      	  AND P_agdl_tbl(i).edit_privilege_id <> G_NULL_NUM
          AND P_agdl_tbl(i).edit_privilege_name  IS NULL) THEN
        BEGIN
          SELECT function_name
          INTO   P_agdl_tbl(i).edit_privilege_name
          FROM   fnd_form_functions
          WHERE  function_id = P_agdl_tbl(i).edit_privilege_id;
        EXCEPTION
          WHEN no_data_found THEN
            write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Edit Privilege provided is invalid');

            P_agdl_tbl(i).process_status := G_ERROR_RECORD;

            x_return_status := G_RET_STS_ERROR;

            error_handler.Add_error_message(p_message_name => 'EGO_EDIT_PRIV_NOT_EXIST',
                                            p_application_id => 'EGO',p_token_tbl => g_token_table,
                                            p_message_type => G_RET_STS_ERROR,p_row_identifier => P_agdl_tbl(i).transaction_id,
                                            p_entity_code => G_ENTITY_DL,p_table_name => G_ENTITY_DL_tab);
          WHEN OTHERS THEN
            write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Additional_agdl_validations Exception when others smt 8');

            x_return_status := G_RET_STS_UNEXP_ERROR;

            error_handler.Add_error_message(p_message_text => sqlerrm,p_application_id => 'EGO',
                                            p_token_tbl => g_token_table,p_message_type => G_RET_STS_UNEXP_ERROR,
                                            p_row_identifier => P_agdl_tbl(i).transaction_id,
                                            p_entity_code => G_ENTITY_DL,p_table_name => G_ENTITY_DL_tab);

            x_return_msg := 'ego_ag_bulkload_pvt.Additional_agdl_validations smt 8 - '||SQLERRM;

   	  		RETURN;
        END;
      END IF;

      /*Sets the Defaulting Name when the Defaulting is given then flags an error EGO_DEFAULTING_INVALID*/
      IF (P_agdl_tbl(i).defaulting  IS NOT NULL
          AND P_agdl_tbl(i).defaulting_name  IS NULL
          AND P_agdl_tbl(i).transaction_type <> G_OPR_DELETE) THEN
        BEGIN
          SELECT meaning
          INTO   P_agdl_tbl(i).defaulting_name
          FROM   fnd_lookup_values
          WHERE  lookup_type = 'EGO_EF_AG_DL_BEHAVIOR'
                 AND lookup_code = P_agdl_tbl(i).defaulting
                 AND language = Userenv('LANG');
        EXCEPTION
          WHEN no_data_found THEN
          	IF (P_agdl_tbl(i).data_level_name <> 'ITEM_REVISION_LEVEL') THEN
	            write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'The defaulting provided is invalid');

	            P_agdl_tbl(i).process_status := G_ERROR_RECORD;

	            x_return_status := G_RET_STS_ERROR;

	            error_handler.Add_error_message(p_message_name => 'EGO_DEFAULTING_INVALID',p_application_id => 'EGO',
	                                            p_token_tbl => g_token_table,p_message_type => G_RET_STS_ERROR,
	                                            p_row_identifier => P_agdl_tbl(i).transaction_id,
	                                            p_entity_code => G_ENTITY_DL,p_table_name => G_ENTITY_DL_tab);
	        END IF;
          WHEN OTHERS THEN
            write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Additional_agdl_validations Exception when others smt 9');

            x_return_status := G_RET_STS_UNEXP_ERROR;

            error_handler.Add_error_message(p_message_text => sqlerrm,p_application_id => 'EGO',
                                            p_token_tbl => g_token_table,p_message_type => G_RET_STS_UNEXP_ERROR,
                                            p_row_identifier => P_agdl_tbl(i).transaction_id,
                                            p_entity_code => G_ENTITY_DL,p_table_name => G_ENTITY_DL_tab);

            x_return_msg := 'ego_ag_bulkload_pvt.Additional_agdl_validations smt 9 - '||SQLERRM;

   	  		RETURN;
        END;
      END IF;

      /*Sets the Defaulting when the Defaulting Name is given then flags an error EGO_DEFAULTING_INVALID*/
      IF (P_agdl_tbl(i).defaulting  IS NULL
          AND P_agdl_tbl(i).defaulting_name  IS NOT NULL
          and P_agdl_tbl(i).transaction_type <> G_OPR_DELETE) THEN
        BEGIN
          SELECT lookup_code
          INTO   P_agdl_tbl(i).defaulting_name
          FROM   fnd_lookup_values
          WHERE  lookup_type = 'EGO_EF_AG_DL_BEHAVIOR'
                 AND meaning = P_agdl_tbl(i).defaulting_name
                 AND language = Userenv('LANG');
        EXCEPTION
          WHEN no_data_found THEN
          	IF (P_agdl_tbl(i).data_level_name <> 'ITEM_REVISION_LEVEL') THEN
	            write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'The defaulting name provided is invalid');

	            P_agdl_tbl(i).process_status := G_ERROR_RECORD;

	            x_return_status := G_RET_STS_ERROR;

	            error_handler.Add_error_message(p_message_name => 'EGO_DEFAULTING_INVALID',p_application_id => 'EGO',
	                                            p_token_tbl => g_token_table,p_message_type => G_RET_STS_ERROR,
	                                            p_row_identifier => P_agdl_tbl(i).transaction_id,
	                                            p_entity_code => G_ENTITY_DL,p_table_name => G_ENTITY_DL_tab);
	        END IF;
          WHEN OTHERS THEN
            write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Additional_agdl_validations Exception when others smt 10');

            x_return_status := G_RET_STS_UNEXP_ERROR;

            error_handler.Add_error_message(p_message_text => sqlerrm,p_application_id => 'EGO',
                                            p_token_tbl => g_token_table,p_message_type => G_RET_STS_UNEXP_ERROR,
                                            p_row_identifier => P_agdl_tbl(i).transaction_id,
                                            p_entity_code => G_ENTITY_DL,p_table_name => G_ENTITY_DL_tab);

            x_return_msg := 'ego_ag_bulkload_pvt.Additional_agdl_validations smt 10 - '||SQLERRM;

   	  		RETURN;
        END;
      END IF;

      /*Sets the data level when the data level id is given or else flags an error EGO_DL_NOT_EXIST*/
      IF (P_agdl_tbl(i).data_level_id  IS NOT NULL
          AND P_agdl_tbl(i).data_level_name  IS NULL) THEN
        BEGIN
          SELECT data_level_name
          INTO   P_agdl_tbl(i).data_level_name
          FROM   ego_data_level_b
          WHERE  attr_group_type = P_agdl_tbl(i).attr_group_type
                 AND application_id = g_ego_application_id
                 AND data_level_id = P_agdl_tbl(i).data_level_id;
        EXCEPTION
          WHEN no_data_found THEN
            write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Data Level provided is invalid');

            P_agdl_tbl(i).process_status := G_ERROR_RECORD;

            x_return_status := G_RET_STS_ERROR;

            error_handler.Add_error_message(p_message_name => 'EGO_DL_NOT_EXIST',p_application_id => 'EGO',
                                            p_token_tbl => g_token_table,p_message_type => G_RET_STS_ERROR,
                                            p_row_identifier => P_agdl_tbl(i).transaction_id,
                                            p_entity_code => G_ENTITY_DL,p_table_name => G_ENTITY_DL_tab);
          WHEN OTHERS THEN
            write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Additional_agdl_validations Exception when others smt 11');

            x_return_status := G_RET_STS_UNEXP_ERROR;

            error_handler.Add_error_message(p_message_text => sqlerrm,p_application_id => 'EGO',
                                            p_token_tbl => g_token_table,p_message_type => G_RET_STS_UNEXP_ERROR,
                                            p_row_identifier => P_agdl_tbl(i).transaction_id,
                                            p_entity_code => G_ENTITY_DL,p_table_name => G_ENTITY_DL_tab);

            x_return_msg := 'ego_ag_bulkload_pvt.Additional_agdl_validations smt 11 - '||SQLERRM;

   	  		RETURN;
        END;
      END IF;

      /*Throws an error EGO_VAR_DL_SKU if the AG is of type VARIANT and Business Entity is not ITEM and SKU NULL*/
      IF (P_agdl_tbl(i).attr_group_id  IS NOT NULL
          AND (P_agdl_tbl(i).data_level_name <> G_DL_ITEM_LEVEL
                OR P_agdl_tbl(i).defaulting  IS NOT NULL)) THEN
        BEGIN
          SELECT Nvl(variant,'N')
          INTO   lv_flag
          FROM   ego_fnd_dsc_flx_ctx_ext
          WHERE  attr_group_id = P_agdl_tbl(i).attr_group_id;

          IF (lv_flag = 'Y') THEN
            write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Attribute group of type Variant can only set ITEM as the business entity and with SKU as NULL');

            P_agdl_tbl(i).process_status := G_ERROR_RECORD;

            x_return_status := G_RET_STS_ERROR;

            error_handler.Add_error_message(p_message_name => 'EGO_VAR_DL_SKU',p_application_id => 'EGO',
                                            p_token_tbl => g_token_table,p_message_type => G_RET_STS_ERROR,
                                            p_row_identifier => P_agdl_tbl(i).transaction_id,
                                            p_entity_code => G_ENTITY_DL,p_table_name => G_ENTITY_DL_tab);
          END IF;
        EXCEPTION
          WHEN no_data_found THEN
            write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Attribute Group is invalid');

            x_return_status := G_RET_STS_ERROR;

            error_handler.Add_error_message(p_message_name => 'EGO_AG_INVALID',p_application_id => 'EGO',
                                            p_token_tbl => g_token_table,p_message_type => G_RET_STS_ERROR,
                                            p_row_identifier => P_agdl_tbl(i).transaction_id,
                                            p_entity_code => G_ENTITY_DL,p_table_name => G_ENTITY_DL_tab);
          WHEN OTHERS THEN
            write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Additional_agdl_validations Exception when others smt 12');

            x_return_status := G_RET_STS_UNEXP_ERROR;

            error_handler.Add_error_message(p_message_text => sqlerrm,p_application_id => 'EGO',
                                            p_token_tbl => g_token_table,p_message_type => G_RET_STS_UNEXP_ERROR,
                                            p_row_identifier => P_agdl_tbl(i).transaction_id,
                                            p_entity_code => G_ENTITY_DL,p_table_name => G_ENTITY_DL_tab);

            x_return_msg := 'ego_ag_bulkload_pvt.Additional_agdl_validations smt 12 - '||SQLERRM;

   	  		RETURN;
        END;
      END IF;

      /*Throws an error EGO_DL_NOT_EXIST if the AG is of type single row or Multi row and Business Entity is not
ITEM_LEVEL, ITEM_REVISION_LEVEL, ITEM_ORG, ITEM_SUP, ITEM_SUP_SITE, ITEM_SUP_SITE_ORG*/
      IF (P_agdl_tbl(i).attr_group_id  IS NOT NULL) THEN
          IF (P_agdl_tbl(i).data_level_name = G_DL_ITEM_LEVEL
                OR P_agdl_tbl(i).data_level_name = G_DL_ITEM_REV_LEVEL
                OR P_agdl_tbl(i).data_level_name = G_DL_ITEM_ORG
                OR P_agdl_tbl(i).data_level_name = G_DL_ITEM_SUP
                OR P_agdl_tbl(i).data_level_name = G_DL_ITEM_SUP_SITE
                OR P_agdl_tbl(i).data_level_name = G_DL_ITEM_SUP_SITE_ORG) THEN
                NULL;
           ELSE
		        BEGIN
		          SELECT Nvl(variant,'N')
		          INTO   lv_flag
		          FROM   ego_fnd_dsc_flx_ctx_ext
		          WHERE  attr_group_id = P_agdl_tbl(i).attr_group_id;

		          IF (lv_flag = 'N') THEN
		            write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'The Behaviour and Business Entity combination is incorrect');

		            P_agdl_tbl(i).process_status := G_ERROR_RECORD;

		            x_return_status := G_RET_STS_ERROR;

		            error_handler.Add_error_message(p_message_name => 'EGO_VAR_DL_SKU',p_application_id => 'EGO',
		                                            p_token_tbl => g_token_table,p_message_type => G_RET_STS_ERROR,
		                                            p_row_identifier => P_agdl_tbl(i).transaction_id,
		                                            p_entity_code => G_ENTITY_DL,p_table_name => G_ENTITY_DL_tab);
		          END IF;
		        EXCEPTION
		          WHEN no_data_found THEN
		            write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Attribute group is invalid');

		            x_return_status := G_RET_STS_ERROR;

		            error_handler.Add_error_message(p_message_name => 'EGO_AG_INVALID',p_application_id => 'EGO',
		                                            p_token_tbl => g_token_table,p_message_type => G_RET_STS_ERROR,
		                                            p_row_identifier => P_agdl_tbl(i).transaction_id,
		                                            p_entity_code => G_ENTITY_DL,p_table_name => G_ENTITY_DL_tab);
		          WHEN OTHERS THEN
		            write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Additional_agdl_validations Exception when others smt 13');

		            x_return_status := G_RET_STS_UNEXP_ERROR;

		            error_handler.Add_error_message(p_message_text => sqlerrm,p_application_id => 'EGO',
		                                            p_token_tbl => g_token_table,p_message_type => G_RET_STS_UNEXP_ERROR,
		                                            p_row_identifier => P_agdl_tbl(i).transaction_id,
		                                            p_entity_code => G_ENTITY_DL,p_table_name => G_ENTITY_DL_tab);

		            x_return_msg := 'ego_ag_bulkload_pvt.Additional_agdl_validations smt 13 - '||SQLERRM;

		   	  		RETURN;
		        END;
        END IF;
       END IF;
        /*Throws an error EGO_MULROW_SKU if the AG is of type single row or Multi row and Business Entity and SKU combination is invalid*/
        IF (P_agdl_tbl(i).attr_group_id  IS NOT NULL) THEN
            IF (((P_agdl_tbl(i).data_level_name = G_DL_ITEM_LEVEL
                    OR P_agdl_tbl(i).data_level_name = G_DL_ITEM_ORG
                    OR P_agdl_tbl(i).data_level_name = G_DL_ITEM_SUP
                    OR P_agdl_tbl(i).data_level_name = G_DL_ITEM_SUP_SITE
                    OR P_agdl_tbl(i).data_level_name = G_DL_ITEM_SUP_SITE_ORG)
                  AND (P_agdl_tbl(i).defaulting = 'D'
                        OR P_agdl_tbl(i).defaulting = 'I'))
                  OR (P_agdl_tbl(i).data_level_name = G_DL_ITEM_REV_LEVEL
                      AND P_agdl_tbl(i).defaulting  IS NULL)) THEN
	              NULL;
            ELSE
		          BEGIN
		            SELECT Nvl(variant,'N')
		            INTO   lv_flag
		            FROM   ego_fnd_dsc_flx_ctx_ext
		            WHERE  attr_group_id = P_agdl_tbl(i).attr_group_id;

		            IF (lv_flag = 'N') THEN
		              write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Attribute Group behaviour, business entity and the style to SKU combination in invalid');

		              P_agdl_tbl(i).process_status := G_ERROR_RECORD;

		              x_return_status := G_RET_STS_ERROR;

		              error_handler.Add_error_message(p_message_name => 'EGO_MULROW_SKU',p_application_id => 'EGO',
		                                              p_token_tbl => g_token_table,p_message_type => G_RET_STS_ERROR,
		                                              p_row_identifier => P_agdl_tbl(i).transaction_id,
		                                              p_entity_code => G_ENTITY_DL,p_table_name => G_ENTITY_DL_tab);
		            END IF;
		          EXCEPTION
		            WHEN no_data_found THEN
		              write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Attribute group is invalid');

		              x_return_status := G_RET_STS_ERROR;

		              error_handler.Add_error_message(p_message_name => 'EGO_AG_INVALID',p_application_id => 'EGO',
		                                              p_token_tbl => g_token_table,p_message_type => G_RET_STS_ERROR,
		                                              p_row_identifier => P_agdl_tbl(i).transaction_id,
		                                              p_entity_code => G_ENTITY_DL,p_table_name => G_ENTITY_DL_tab);
		            WHEN OTHERS THEN
		              write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Additional_agdl_validations Exception when others smt 14');

		              x_return_status := G_RET_STS_UNEXP_ERROR;

		              error_handler.Add_error_message(p_message_text => sqlerrm,p_application_id => 'EGO',
		                                              p_token_tbl => g_token_table,p_message_type => G_RET_STS_UNEXP_ERROR,
		                                              p_row_identifier => P_agdl_tbl(i).transaction_id,
		                                              p_entity_code => G_ENTITY_DL,p_table_name => G_ENTITY_DL_tab);

		              x_return_msg := 'ego_ag_bulkload_pvt.Additional_agdl_validations smt 14 - '||SQLERRM;

		   	  		  RETURN;
		          END;
          END IF;
        END IF;
    END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
      write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Additional_agdl_validations Exception when others'||SQLERRM);

      x_return_status := G_RET_STS_UNEXP_ERROR;

      x_return_msg := 'ego_ag_bulkload_pvt.Additional_agdl_validations - '||SQLERRM;

   	  RETURN;
  END Additional_agdl_validations;

  /*This procedure is used to do additional validations on attributes.
  	Used in the API flow.
  	p_attr_tbl        IN OUT NOCOPY  Attributes plsql table
  	x_return_status OUT NOCOPY parameter that returns the status*/
  PROCEDURE Additional_attr_validations
       (p_attr_tbl       IN OUT NOCOPY ego_metadata_pub.ego_attr_group_cols_tbl,
        x_return_status OUT NOCOPY VARCHAR2, x_return_msg OUT NOCOPY VARCHAR2)
  IS
    lv_smt  NUMBER; --Statement counter
  	lv_proc VARCHAR2(30) := 'Additional_attr_validations';
  BEGIN
    write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Entering Additional_attr_validations');

    x_return_status := G_RET_STS_SUCCESS;

    lv_smt := 1;

    write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Statement 1');

    FOR i IN p_attr_tbl.FIRST.. p_attr_tbl.LAST LOOP
      /*Convert transaction type to upper case*/
      SELECT Upper(P_attr_tbl(i).transaction_type)
      INTO   P_attr_tbl(i).transaction_type
      FROM   dual;

      /*Check for invalid transaction type in the Attribute table*/
      IF ( P_attr_tbl(i).transaction_type = G_OPR_CREATE
           OR P_attr_tbl(i).transaction_type = G_OPR_UPDATE
           OR P_attr_tbl(i).transaction_type = G_OPR_DELETE
           OR P_attr_tbl(i).transaction_type = G_OPR_SYNC) THEN
           NULL;
      ELSE
        write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Transaction type Invalid for Attributes');

        P_attr_tbl(i).process_status := G_ERROR_RECORD;

        x_return_status := G_RET_STS_ERROR;

        write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Transaction Type passed is incorrect');

        error_handler.Add_error_message(p_message_name => 'EGO_TRANS_TYPE_INVALID',p_application_id => 'EGO',
                                        p_token_tbl => g_token_table,p_message_type => G_RET_STS_ERROR,
                                        p_row_identifier => P_attr_tbl(i).transaction_id,
                                        p_entity_code => G_ENTITY_ATTR,p_table_name => G_ENTITY_ATTR_TAB);
      END IF;

      /*Checks if the attribute group type passed is EGO_ITEMMGMT_GROUP or else thows the error EGO_AG_TYPE_INVALID*/
      IF (P_attr_tbl(i).attr_group_type <> G_EGO_ITEMMGMT_GROUP) THEN
        P_attr_tbl(i).process_status := G_ERROR_RECORD;

        x_return_status := G_RET_STS_ERROR;

        write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Attribute group Type passed is incorrect');

        error_handler.Add_error_message(p_message_name => 'EGO_AG_TYPE_INVALID',p_application_id => 'EGO',
                                        p_token_tbl => g_token_table,p_message_type => G_RET_STS_ERROR,
                                        p_row_identifier => P_attr_tbl(i).transaction_id,
                                        p_entity_code => G_ENTITY_ATTR,p_table_name => G_ENTITY_ATTR_TAB);
      END IF;
    END LOOP;

    /*Value to ID Conversions for Attributes*/
    Value_to_id_attr_tbl(p_attr_tbl,x_return_status, x_return_msg); IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN RETURN; END IF;

    FOR i IN p_attr_tbl.FIRST.. p_attr_tbl.LAST LOOP
      IF (P_attr_tbl(i).process_status = G_PROCESS_RECORD) THEN
        lv_smt := 1;

        write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Statement 1');

        /*Sets the attribute group name when the attribute group id is given*/
        IF (P_attr_tbl(i).attr_group_id IS NOT NULL
            AND P_attr_tbl(i).attr_group_name IS NULL) THEN
          BEGIN
            SELECT descriptive_flex_context_code
            INTO   P_attr_tbl(i).attr_group_name
            FROM   ego_fnd_dsc_flx_ctx_ext
            WHERE  application_id = g_ego_application_id
                   AND descriptive_flexfield_name = P_attr_tbl(i).attr_group_type
                   AND attr_group_id = P_attr_tbl(i).attr_group_id;
          EXCEPTION
            WHEN no_data_found THEN
              x_return_status := G_RET_STS_ERROR;

              write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Attribute Group does not exist');

              error_handler.Add_error_message(p_message_name => 'EGO_AG_INVALID',p_application_id => 'EGO',
                                              p_token_tbl => g_token_table,p_message_type => G_RET_STS_ERROR,
                                              p_row_identifier => P_attr_tbl(i).transaction_id,
                                              p_entity_code => G_ENTITY_ATTR,p_table_name => G_ENTITY_ATTR_TAB);
            WHEN OTHERS THEN
              x_return_status := G_RET_STS_UNEXP_ERROR;

              write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Additional_attr_validations when others smt 1');

              error_handler.Add_error_message(p_message_text => sqlerrm,p_application_id => 'EGO',
                                              p_token_tbl => g_token_table,p_message_type => G_RET_STS_UNEXP_ERROR,
                                              p_row_identifier => P_attr_tbl(i).transaction_id,
                                              p_entity_code => G_ENTITY_ATTR,p_table_name => G_ENTITY_ATTR_TAB);

              x_return_msg := 'ego_ag_bulkload_pvt.Additional_attr_validations smt 1- '||SQLERRM;

   	  		  RETURN;
          END;
        END IF;

        lv_smt := 2;

        write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Statement 2');

        /*Sets the internal attribute name when the attribute id is given*/
        IF (P_attr_tbl(i).attr_id IS NOT NULL
            AND P_attr_tbl(i).internal_name IS NULL) THEN
          BEGIN
            SELECT fdfcu.end_user_column_name
            INTO   P_attr_tbl(i).internal_name
            FROM   fnd_descr_flex_column_usages fdfcu,
                   ego_fnd_df_col_usgs_ext efdcue
            WHERE  fdfcu.application_id = efdcue.application_id
                   AND fdfcu.descriptive_flexfield_name = efdcue.descriptive_flexfield_name
                   AND fdfcu.descriptive_flex_context_code = efdcue.descriptive_flex_context_code
                   AND fdfcu.application_column_name = efdcue.application_column_name
                   AND fdfcu.application_id = g_ego_application_id
                   AND fdfcu.descriptive_flexfield_name = P_attr_tbl(i).attr_group_type
                   AND fdfcu.descriptive_flex_context_code = P_attr_tbl(i).attr_group_name
                   AND efdcue.attr_id = P_attr_tbl(i).attr_id;

            IF (P_attr_tbl(i).transaction_type = G_OPR_SYNC) THEN
              P_attr_tbl(i).transaction_type := G_OPR_UPDATE;
            END IF;
          EXCEPTION
            WHEN no_data_found THEN
              IF (P_attr_tbl(i).transaction_type = G_OPR_SYNC) THEN
                P_attr_tbl(i).transaction_type := G_OPR_CREATE;
              ELSE
                x_return_status := G_RET_STS_ERROR;

                write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Attribute does not exist');

                error_handler.Add_error_message(p_message_name => 'EGO_ATTR_NOT_EXISTS',p_application_id => 'EGO',
                                                p_token_tbl => g_token_table,p_message_type => G_RET_STS_ERROR,
                                                p_row_identifier => P_attr_tbl(i).transaction_id,
                                                p_entity_code => G_ENTITY_ATTR,p_table_name => G_ENTITY_ATTR_TAB);
              END IF;
            WHEN OTHERS THEN
              x_return_status := G_RET_STS_UNEXP_ERROR;

              write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Additional_attr_validations Exception when others smt 2');

              error_handler.Add_error_message(p_message_text => sqlerrm,p_application_id => 'EGO',
                                              p_token_tbl => g_token_table,p_message_type => G_RET_STS_UNEXP_ERROR,
                                              p_row_identifier => P_attr_tbl(i).transaction_id,
                                              p_entity_code => G_ENTITY_ATTR,p_table_name => G_ENTITY_ATTR_TAB);

              x_return_msg := 'ego_ag_bulkload_pvt.Additional_attr_validations smt 2- '||SQLERRM;

   	  		  RETURN;
          END;
        END IF;

        lv_smt := 3;

        write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Statement 3');

        /*Sets the value set name when the value set id is given*/
        IF (P_attr_tbl(i).flex_value_set_id IS NOT NULL
        	AND P_attr_tbl(i).flex_value_set_id <> G_NULL_NUM
            AND P_attr_tbl(i).flex_value_set_name IS NULL) THEN
          BEGIN
            SELECT ffvs.flex_value_set_name
            INTO   P_attr_tbl(i).flex_value_set_name
            FROM   fnd_flex_value_sets ffvs
            WHERE  ffvs.flex_value_set_id = P_attr_tbl(i).flex_value_set_id;
          EXCEPTION
            WHEN no_data_found THEN
              x_return_status := G_RET_STS_ERROR;

              write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Value Set does not exist in the system');

              error_handler.Add_error_message(p_message_name => 'EGO_EF_BC_SEL_EXI_VALUE',p_application_id => 'EGO',
                                              p_token_tbl => g_token_table,p_message_type => G_RET_STS_ERROR,
                                              p_row_identifier => P_attr_tbl(i).transaction_id,
                                              p_entity_code => G_ENTITY_ATTR,p_table_name => G_ENTITY_ATTR_TAB);
            WHEN OTHERS THEN
              x_return_status := G_RET_STS_UNEXP_ERROR;

              write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Additional_attr_validations Exception when others smt 3');


              error_handler.Add_error_message(p_message_text => sqlerrm,p_application_id => 'EGO',
                                              p_token_tbl => g_token_table,p_message_type => G_RET_STS_UNEXP_ERROR,
                                              p_row_identifier => P_attr_tbl(i).transaction_id,
                                              p_entity_code => G_ENTITY_ATTR,p_table_name => G_ENTITY_ATTR_TAB);

              x_return_msg := 'ego_ag_bulkload_pvt.Additional_attr_validations smt 3 - '||SQLERRM;

   	  		  RETURN;
          END;
        END IF;
      END IF;
    END LOOP;

    write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Exit Additional_attr_validations');
  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := G_RET_STS_UNEXP_ERROR;

      write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Additional_attr_validations Exception when others'||SQLERRM);

      x_return_msg := 'ego_ag_bulkload_pvt.Additional_attr_validations - '||SQLERRM;

   	  RETURN;
  END Additional_attr_validations;

  /*This procedure is used to update the attribute group interface table
  	Used in the interface flow.
  	p_ag_tbl        IN OUT NOCOPY Attribute group plsql table
  	x_return_status OUT NOCOPY parameter that returns the status*/
  PROCEDURE update_intf_attr_groups
       (p_ag_tbl         IN OUT NOCOPY ego_metadata_pub.ego_attr_groups_tbl,
        x_return_status OUT NOCOPY VARCHAR2, x_return_msg OUT NOCOPY VARCHAR2)
  IS
  	lv_proc VARCHAR2(30) := 'update_intf_attr_groups';
  	trans_id dbms_sql.number_table;
  BEGIN
    write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Entering update_intf_attr_groups');

    x_return_status := G_RET_STS_SUCCESS;

    FOR i IN p_ag_tbl.FIRST..p_ag_tbl.LAST LOOP
    	trans_id(i) := p_ag_tbl(i).transaction_id;
  	END LOOP;

    FORALL i IN p_ag_tbl.FIRST..p_ag_tbl.LAST
      UPDATE ego_attr_groups_interface
      SET    ROW = p_ag_tbl(i)
      WHERE  transaction_id = trans_id(i);

    write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Exit update_intf_attr_groups');
  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := G_RET_STS_UNEXP_ERROR;

      write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'update_intf_attr_groups Exception when others'||SQLERRM);

      x_return_msg := 'ego_ag_bulkload_pvt.update_intf_attr_groups - '||SQLERRM;

   	  RETURN;
  END update_intf_attr_groups;

  /*This procedure is used to update the attribute group data level interface table
  	Used in the interface flow.
  	p_agdl_tbl        IN OUT NOCOPY Attribute group data level plsql table
  	x_return_status OUT NOCOPY parameter that returns the status*/
  PROCEDURE update_intf_data_level
       (p_agdl_tbl       IN OUT NOCOPY ego_metadata_pub.ego_attr_groups_dl_tbl,
        x_return_status OUT NOCOPY VARCHAR2, x_return_msg OUT NOCOPY VARCHAR2)
  IS
  	lv_proc VARCHAR2(30) := 'update_intf_data_level';
  	trans_id dbms_sql.number_table;
  BEGIN
    write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Entering update_intf_data_level');

    x_return_status := G_RET_STS_SUCCESS;

    FOR i IN p_agdl_tbl.FIRST..p_agdl_tbl.LAST LOOP
    	trans_id(i) := p_agdl_tbl(i).transaction_id;
  	END LOOP;

    FORALL i IN p_agdl_tbl.FIRST..p_agdl_tbl.LAST
      UPDATE ego_attr_groups_dl_interface
      SET    ROW = p_agdl_tbl(i)
      WHERE  transaction_id = trans_id(i);


    write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Exit update_intf_data_level');
  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := G_RET_STS_UNEXP_ERROR;

      write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'update_intf_data_level Exception when others'||SQLERRM);

      x_return_msg := 'ego_ag_bulkload_pvt.update_intf_data_level - '||SQLERRM;

   	  RETURN;
  END update_intf_data_level;

  /*This procedure is used to update the attributes interface table
  	Used in the Interface flow.
  	p_attr_tbl        IN OUT NOCOPY Attributes plsql table
  	x_return_status OUT NOCOPY parameter that returns the status*/
  PROCEDURE update_intf_attribute
       (p_attr_tbl       IN OUT NOCOPY ego_metadata_pub.ego_attr_group_cols_tbl,
        x_return_status OUT NOCOPY VARCHAR2, x_return_msg OUT NOCOPY VARCHAR2)
  IS
  	lv_proc VARCHAR2(30) := 'update_intf_attribute';
  	trans_id dbms_sql.number_table;
  BEGIN
    write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Entering update_intf_attribute');

    x_return_status := G_RET_STS_SUCCESS;

    FOR i IN p_attr_tbl.FIRST..p_attr_tbl.LAST LOOP
    	trans_id(i) := p_attr_tbl(i).transaction_id;
  	END LOOP;

    FORALL i IN p_attr_tbl.FIRST..p_attr_tbl.LAST
      UPDATE ego_attr_group_cols_intf
      SET    ROW = P_attr_tbl(i)
      WHERE  transaction_id = trans_id(i);

      write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Exit update_intf_attribute');
  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := G_RET_STS_UNEXP_ERROR;

      write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'update_intf_attribute Exception when others'||SQLERRM);

      x_return_msg := 'ego_ag_bulkload_pvt.update_intf_attribute - '||SQLERRM;

   	  RETURN;
  END update_intf_attribute;

  /*This procedure is used to delete processed records from the attribute group's interface table
  	Used in the interface flow.
  	x_set_process_id IN Set process id
  	x_return_status OUT NOCOPY parameter that returns the status*/
  PROCEDURE delete_processed_attr_groups(
    x_set_process_id IN NUMBER,
    x_return_status OUT NOCOPY VARCHAR2, x_return_msg OUT NOCOPY VARCHAR2)
    IS
    	lv_proc VARCHAR2(30) := 'delete_processed_attr_groups';
    BEGIN
    	write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Entering delete_processed_attr_groups');

    	x_return_status := G_RET_STS_SUCCESS;

    	DELETE FROM ego_attr_groups_interface
      	WHERE process_status = G_SUCCESS_RECORD
      	AND (x_set_process_id IS  NULL
      		 OR set_process_id = x_set_process_id);

    	write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Exit delete_processed_attr_groups');
    EXCEPTION
    	WHEN OTHERS THEN
    	   	x_return_status := G_RET_STS_UNEXP_ERROR;

         	write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'delete_processed_attr_groups Exception when others'||SQLERRM);

         	x_return_msg := 'ego_ag_bulkload_pvt.delete_processed_attr_groups - '||SQLERRM;

   	     RETURN;

    END delete_processed_attr_groups;

  /*This procedure is used to delete processed records from the AG Data level's interface table
  	Used in the interface flow.
	x_set_process_id IN Set process id
	x_return_status OUT NOCOPY parameter that returns the status*/
  PROCEDURE delete_processed_data_level(
    x_set_process_id IN NUMBER,
    x_return_status OUT NOCOPY VARCHAR2, x_return_msg OUT NOCOPY VARCHAR2)
    IS
    	lv_proc VARCHAR2(30) := 'delete_processed_data_level';
    BEGIN
    	write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Entering delete_processed_data_level');

    	x_return_status := G_RET_STS_SUCCESS;

    	DELETE FROM ego_attr_groups_dl_interface
      	WHERE process_status = G_SUCCESS_RECORD
      	AND (x_set_process_id IS  NULL
      		 OR set_process_id = x_set_process_id);

    	write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Exit delete_processed_data_level');
    EXCEPTION
    	WHEN OTHERS THEN
    	  	x_return_status := G_RET_STS_UNEXP_ERROR;

         	write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'delete_processed_data_level Exception when others'||SQLERRM);

         	x_return_msg := 'ego_ag_bulkload_pvt.delete_processed_data_level - '||SQLERRM;

   	     RETURN;
    END delete_processed_data_level;

  /*This procedure is used to delete processed records from the Attribute's interface table
  	Used in the Interface flow.
	x_set_process_id IN Set process id
	x_return_status OUT NOCOPY parameter that returns the status*/
  PROCEDURE delete_processed_attributes(
    x_set_process_id IN NUMBER,
    x_return_status OUT NOCOPY VARCHAR2, x_return_msg OUT NOCOPY VARCHAR2)
    IS
    	lv_proc VARCHAR2(30) := 'delete_processed_attributes';
    BEGIN
    	write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Entering delete_processed_attributes');

    	x_return_status := G_RET_STS_SUCCESS;

    	DELETE FROM ego_attr_group_cols_intf
      	WHERE process_status = G_SUCCESS_RECORD
      	AND (x_set_process_id IS  NULL
      		 OR set_process_id = x_set_process_id);

    	write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Exit delete_processed_attributes');
    EXCEPTION
    	WHEN OTHERS THEN
    	   	x_return_status := G_RET_STS_UNEXP_ERROR;

         	write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'delete_processed_attributes Exception when others'||SQLERRM);

         	x_return_msg := 'ego_ag_bulkload_pvt.delete_processed_attributes - '||SQLERRM;

   	     	RETURN;
    END delete_processed_attributes;

  /*This procedure is used in the update flow to handle null values for AG
  	Used in the interface and API flow.
  	p_ag_tbl        IN OUT NOCOPY Attribute groups plsql table
  	x_return_status OUT NOCOPY parameter that returns the status
  	x_return_msg OUT NOCOPY parameter that returns the error message*/
  PROCEDURE handle_null_ag(
    p_ag_tbl        IN OUT NOCOPY ego_metadata_pub.ego_attr_groups_tbl,
    x_return_status OUT NOCOPY VARCHAR2, x_return_msg OUT NOCOPY VARCHAR2)
    IS
    lv_display_name VARCHAR2(40);	/*Added for bug 9738246*/
    lv_num_of_cols NUMBER;
    lv_num_of_rows NUMBER;
    lv_multi_row   VARCHAR2(1);
    lv_variant	   VARCHAR2(1);
    lv_description VARCHAR2(240);	/*Added for bug 9738246*/
    lv_proc VARCHAR2(30) := 'handle_null_ag';
    BEGIN
    	write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Entering handle_null_ag');

    	x_return_status := G_RET_STS_SUCCESS;

    	FOR i IN p_ag_tbl.FIRST..p_ag_tbl.LAST LOOP
    		IF (p_ag_tbl(i).process_status = G_PROCESS_RECORD
    			AND p_ag_tbl(i).transaction_type = G_OPR_UPDATE) THEN
    			BEGIN
    				write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Smt 1');

    				SELECT NUM_OF_COLS, NUM_OF_ROWS, MULTI_ROW, VARIANT INTO lv_num_of_cols, lv_num_of_rows, lv_multi_row, lv_variant
    				FROM EGO_FND_DSC_FLX_CTX_EXT
    				WHERE DESCRIPTIVE_FLEXFIELD_NAME = p_ag_tbl(i).attr_group_type
        	 		AND DESCRIPTIVE_FLEX_CONTEXT_CODE = p_ag_tbl(i).attr_group_name
         			AND APPLICATION_ID = G_EGO_APPLICATION_ID;

         			write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'smt 2');

         			SELECT DESCRIPTIVE_FLEX_CONTEXT_NAME, DESCRIPTION INTO lv_display_name, lv_description
         			FROM FND_DESCR_FLEX_CONTEXTS_TL
         			WHERE APPLICATION_ID = G_EGO_APPLICATION_ID
       				AND DESCRIPTIVE_FLEXFIELD_NAME = p_ag_tbl(i).attr_group_type
       				AND DESCRIPTIVE_FLEX_CONTEXT_CODE = p_ag_tbl(i).attr_group_name
      				AND USERENV('LANG') = LANGUAGE;

      				write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'smt 3');

      				IF (p_ag_tbl(i).attr_group_disp_name  IS NULL
      					OR p_ag_tbl(i).attr_group_disp_name = G_NULL_CHAR) THEN
      					p_ag_tbl(i).attr_group_disp_name := lv_display_name;
      				END IF;

      				write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'smt 4');

      				IF p_ag_tbl(i).description  IS NULL THEN
      					p_ag_tbl(i).description := lv_description;
      				ELSIF p_ag_tbl(i).description = G_NULL_CHAR THEN
      					p_ag_tbl(i).description := NULL;
      				END IF;

      				write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'smt 5');

      				IF ((p_ag_tbl(i).num_of_rows  IS NULL
      					OR p_ag_tbl(i).num_of_rows = G_NULL_NUM)	/*Changed for bug 9719202*/
      					AND lv_num_of_rows  IS NOT NULL) THEN
      					p_ag_tbl(i).num_of_rows := lv_num_of_rows;
      				END IF;

      				write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'smt 6');

      				IF ((p_ag_tbl(i).num_of_cols  IS NULL
      					OR p_ag_tbl(i).num_of_cols = G_NULL_NUM)	/*Changed for bug 9719202*/
      					AND lv_num_of_cols  IS NOT NULL) THEN
      					p_ag_tbl(i).num_of_cols := lv_num_of_cols;
      				END IF;

      				/*Added for bug 9719202*/
      				write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'smt 7');

      				IF (NVL(lv_variant,'N') = 'N' AND lv_multi_row = 'N') THEN
      					p_ag_tbl(i).num_of_rows := null;
      				END IF;

      				write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'smt 8');

      				IF (NVL(lv_variant,'N') = 'Y' AND lv_multi_row = 'N') THEN
      					p_ag_tbl(i).num_of_rows := null;
      					p_ag_tbl(i).num_of_cols := null;
      				END IF;
         			/*End of comment for bug 9719202*/
      			EXCEPTION
      				WHEN OTHERS THEN
      					x_return_status := G_RET_STS_UNEXP_ERROR;

         				write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'handle_null_ag exception when others smt 1');

         				x_return_msg := 'ego_ag_bulkload_pvt.handle_null_ag - '||SQLERRM;

   	     				RETURN;
    			END;
    		END IF;
    	END LOOP;
    	write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Exit handle_null_ag');
    EXCEPTION
    	WHEN OTHERS THEN
    		write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'handle_null_ag Exception when others'||SQLERRM);
    END handle_null_ag;

  /*This procedure is used to do final processing of the attribute group data level.
  	Used in the interface and API flow.
  	p_agdl_tbl        IN OUT NOCOPY Attribute group data level plsql table
  	x_return_status OUT NOCOPY parameter that returns the status
  	x_return_msg OUT NOCOPY parameter that returns the error message*/
  PROCEDURE handle_null_dl(
    p_agdl_tbl      IN OUT NOCOPY ego_metadata_pub.ego_attr_groups_dl_tbl,
    x_return_status OUT NOCOPY VARCHAR2, x_return_msg OUT NOCOPY VARCHAR2)
    IS
    lv_defaulting VARCHAR2(1);
    lv_view_privilege_id NUMBER;
    lv_edit_privilege_id NUMBER;
    lv_raise_pre_event VARCHAR2(1);
    lv_raise_post_event VARCHAR2(1);
    lv_proc VARCHAR2(30) := 'handle_null_dl';
    BEGIN
    	write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Entering handle_null_dl');

    	x_return_status := G_RET_STS_SUCCESS;

    	FOR i IN p_agdl_tbl.FIRST..p_agdl_tbl.LAST LOOP
    		IF (p_agdl_tbl(i).process_status = G_PROCESS_RECORD
    			AND p_agdl_tbl(i).transaction_type = G_OPR_UPDATE) THEN
    			BEGIN
    				write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Smt 1');

    				SELECT defaulting ,view_privilege_id,edit_privilege_id,raise_pre_event,raise_post_event
    				INTO lv_defaulting, lv_view_privilege_id ,lv_edit_privilege_id,lv_raise_pre_event, lv_raise_post_event
    				FROM EGO_ATTR_GROUP_DL
    				WHERE attr_group_id = p_agdl_tbl(i).attr_group_id
    				AND data_level_id = p_agdl_tbl(i).data_level_id;

    				IF (p_agdl_tbl(i).defaulting  IS NULL
    					OR p_agdl_tbl(i).defaulting = G_NULL_CHAR
    					OR p_agdl_tbl(i).defaulting_name = G_NULL_CHAR) THEN
    					p_agdl_tbl(i).defaulting := lv_defaulting;
    				END IF;

    				IF (p_agdl_tbl(i).view_privilege_id = G_NULL_NUM OR p_agdl_tbl(i).view_privilege_name = G_NULL_CHAR) THEN
    					p_agdl_tbl(i).view_privilege_id := NULL;
    					p_agdl_tbl(i).view_privilege_name := NULL;
    				ELSIF p_agdl_tbl(i).view_privilege_id  IS NULL THEN
    					p_agdl_tbl(i).view_privilege_id :=  lv_view_privilege_id;
    				END IF;

    				IF (p_agdl_tbl(i).edit_privilege_id = G_NULL_NUM OR p_agdl_tbl(i).edit_privilege_name = G_NULL_CHAR) THEN
    					p_agdl_tbl(i).edit_privilege_id := NULL;
    					p_agdl_tbl(i).edit_privilege_name := NULL;
    				ELSIF p_agdl_tbl(i).edit_privilege_id  IS NULL THEN
    					p_agdl_tbl(i).edit_privilege_id :=  lv_edit_privilege_id;
    				END IF;

    				IF p_agdl_tbl(i).pre_business_event_flag = G_NULL_CHAR THEN
    					p_agdl_tbl(i).pre_business_event_flag := NULL;
    				ELSIF p_agdl_tbl(i).pre_business_event_flag  IS NULL THEN
    					p_agdl_tbl(i).pre_business_event_flag :=  lv_raise_pre_event;

    				END IF;

    				IF p_agdl_tbl(i).business_event_flag = G_NULL_CHAR THEN
    					p_agdl_tbl(i).business_event_flag := NULL;
    				ELSIF p_agdl_tbl(i).business_event_flag  IS NULL THEN
    					p_agdl_tbl(i).business_event_flag :=  lv_raise_post_event;

    				END IF;
    			EXCEPTION
    				WHEN OTHERS THEN
    					x_return_status := G_RET_STS_UNEXP_ERROR;

         				write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'handle_null_dl exception when others smt 1');

         				x_return_msg := 'ego_ag_bulkload_pvt.handle_null_dl - '||SQLERRM;

   	     				RETURN;
    			END;
    		END IF;
    	END LOOP;
    	write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Exit handle_null_dl');

    EXCEPTION
    	WHEN OTHERS THEN
    		write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'handle_null_dl Exception when others'||SQLERRM);
    END handle_null_dl;

  /*This procedure is used to do final processing of the attributes.
  	Used in the interface and API flow.
  	p_attr_tbl        IN OUT NOCOPY Attributes plsql table
  	x_return_status OUT NOCOPY parameter that returns the status
  	x_return_msg OUT NOCOPY parameter that returns the error message*/
  PROCEDURE handle_null_attr(
    p_attr_tbl      IN OUT NOCOPY ego_metadata_pub.ego_attr_group_cols_tbl,
    x_return_status OUT NOCOPY VARCHAR2, x_return_msg OUT NOCOPY VARCHAR2)
    IS
    lv_value_set_id NUMBER;
    lv_default_value VARCHAR2(2000); 	/*Added for bug 9738246 */
    lv_info_1 VARCHAR2(2048);			/*Added for bug 9738246 */
    lv_uom_class VARCHAR2(40);
    lv_proc VARCHAR2(30) := 'handle_null_attr';
    BEGIN
    	write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Entering handle_null_attr');

    	x_return_status := G_RET_STS_SUCCESS;

    	FOR i IN p_attr_tbl.FIRST..p_attr_tbl.LAST LOOP
    		IF (p_attr_tbl(i).process_status = G_PROCESS_RECORD
    			AND p_attr_tbl(i).transaction_type = G_OPR_UPDATE) THEN
    			BEGIN
    				SELECT FLEX_VALUE_SET_ID,DEFAULT_VALUE INTO lv_value_set_id, lv_default_value
    				FROM FND_DESCR_FLEX_COLUMN_USAGES
    				WHERE APPLICATION_ID =  G_EGO_APPLICATION_ID
         			AND DESCRIPTIVE_FLEXFIELD_NAME = p_attr_tbl(i).attr_group_type
         			AND DESCRIPTIVE_FLEX_CONTEXT_CODE = p_attr_tbl(i).attr_group_name
         			AND APPLICATION_COLUMN_NAME = p_attr_tbl(i).application_column_name;

         			SELECT INFO_1, UOM_CLASS INTO lv_info_1, lv_uom_class
         			FROM EGO_FND_DF_COL_USGS_EXT
         			WHERE APPLICATION_ID =  G_EGO_APPLICATION_ID
         			AND DESCRIPTIVE_FLEXFIELD_NAME = p_attr_tbl(i).attr_group_type
         			AND DESCRIPTIVE_FLEX_CONTEXT_CODE = p_attr_tbl(i).attr_group_name
         			AND APPLICATION_COLUMN_NAME = p_attr_tbl(i).application_column_name;

         			IF (p_attr_tbl(i).flex_value_set_id = G_NULL_NUM OR p_attr_tbl(i).flex_value_set_name = G_NULL_CHAR)THEN
         				p_attr_tbl(i).flex_value_set_id := NULL;
         			ELSIF p_attr_tbl(i).flex_value_set_id  IS NULL THEN
         				p_attr_tbl(i).flex_value_set_id := lv_value_set_id;

         			END IF;

         			IF p_attr_tbl(i).default_value = G_NULL_CHAR THEN
         				p_attr_tbl(i).default_value := NULL;
         			ELSIF p_attr_tbl(i).default_value  IS NULL THEN
         				p_attr_tbl(i).default_value := lv_default_value;

         			END IF;

         			IF (p_attr_tbl(i).info_1  IS NULL OR p_attr_tbl(i).info_1 = G_NULL_CHAR) THEN
         				p_attr_tbl(i).info_1 := lv_info_1;
         			END IF;

         			IF p_attr_tbl(i).uom_class = G_NULL_CHAR THEN
         				p_attr_tbl(i).uom_class := NULL;
         			ELSIF p_attr_tbl(i).uom_class  IS NULL THEN
         				p_attr_tbl(i).uom_class := lv_uom_class;
         			END IF;
    			EXCEPTION
    				WHEN OTHERS THEN
    				    x_return_status := G_RET_STS_UNEXP_ERROR;

         				write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'handle_null_attr exception when others smt 1');

         				x_return_msg := 'ego_ag_bulkload_pvt.handle_null_attr - '||SQLERRM;
    			END;
    		END IF;
    	END LOOP;
    	write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Exit handle_null_attr');
    EXCEPTION
    	WHEN OTHERS THEN
    		write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'handle_null_attr Exception when others'||SQLERRM);
    END handle_null_attr;

  /*This procedure is used to delete AG existing in the production table without a single DL associated
  	Used in the Interface flow and API flow.
	x_return_status OUT NOCOPY parameter that returns the status
	x_return_msg OUT NOCOPY parameter that returns the error message*/
  PROCEDURE delete_ag_none_dl(
  x_return_status OUT NOCOPY VARCHAR2, x_return_msg OUT NOCOPY VARCHAR2)
  IS
  CURSOR cur_ag_none_dl IS
  SELECT attr_group_id
	FROM ego_fnd_dsc_flx_ctx_ext efd
	WHERE application_id = G_EGO_APPLICATION_ID
	AND DESCRIPTIVE_FLEXFIELD_NAME = G_EGO_ITEMMGMT_GROUP
	AND NOT EXISTS (SELECT 1
    	            FROM EGO_ATTR_GROUP_DL
        	        WHERE attr_group_id = efd.attr_group_id);

  x_errorcode NUMBER;
  x_msg_count NUMBER;
  x_msg_data VARCHAR2(2000);
  lv_proc VARCHAR2(30) := 'delete_ag_none_dl';
  BEGIN
  	write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Enters delete_ag_none_dl');

  	x_return_status := G_RET_STS_SUCCESS;

  	FOR rec IN cur_ag_none_dl LOOP
  		EGO_EXT_FWK_PUB.Delete_Attribute_Group (
											        p_api_version => 1.0
											       ,p_attr_group_id =>  rec.attr_group_id
											       ,p_init_msg_list =>  fnd_api.g_FALSE
											       ,p_commit  =>  fnd_api.g_FALSE
											       ,x_return_status =>  x_return_status
											       ,x_errorcode  =>   x_errorcode
											       ,x_msg_count =>   x_msg_count
											       ,x_msg_data  =>    x_msg_data
											    );
    END LOOP;
    COMMIT;
    write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'Exits delete_ag_none_dl');
  EXCEPTION
  	WHEN OTHERS THEN
  		x_return_status := G_RET_STS_UNEXP_ERROR;

        write_debug('ego_ag_bulkload_pvt.'||lv_proc||' - '||'delete_ag_none_dl Exception when others'||SQLERRM);

        x_return_msg := 'ego_ag_bulkload_pvt.delete_ag_none_dl - '||SQLERRM;
  END delete_ag_none_dl;

  /*This local procedure will return the TL table name based on the attribute group Type
    p_application_id  IN EGO Application ID
    p_attr_group_type IN Attribute group Type*/
  FUNCTION Get_TL_Table_Name (
        p_application_id  IN   NUMBER
       ,p_attr_group_type IN   VARCHAR2
	)
	RETURN VARCHAR2
	IS
	    l_table_name             VARCHAR2(30);

	  BEGIN
	    SELECT EXT_TL_TABLE_NAME
	      INTO l_table_name
	      FROM EGO_ATTR_GROUP_TYPES_V
	     WHERE APPLICATION_ID = p_application_id
	       AND ATTR_GROUP_TYPE = p_attr_group_type;

	    RETURN l_table_name;

	  EXCEPTION
	    WHEN NO_DATA_FOUND THEN
	      RETURN NULL;

	END Get_TL_Table_Name;

	/*This local procedure will return the table name based on the attribute group Type
    p_application_id  IN EGO Application ID
    p_attr_group_type IN Attribute group Type*/
	FUNCTION Get_Table_Name (
        p_application_id  IN   NUMBER
       ,p_attr_group_type IN   VARCHAR2
	)
	RETURN VARCHAR2
	IS

	    l_table_name             VARCHAR2(30);

	  BEGIN
	    SELECT APPLICATION_TABLE_NAME
	      INTO l_table_name
	      FROM FND_DESCRIPTIVE_FLEXS
	     WHERE APPLICATION_ID = p_application_id
	       AND DESCRIPTIVE_FLEXFIELD_NAME = p_attr_group_type;

	    RETURN l_table_name;

	  EXCEPTION
	    WHEN NO_DATA_FOUND THEN
	      RETURN NULL;

	END Get_Table_Name;

	------------------------------------------------------------------------------------------
	-- Function: To return the  pending transalatable table name  for a given attribute group type
	--  an the application id
	--           If the table is not defined, NULL is returned
	--
	-- Parameters:
	--         IN
	--  p_attr_group_type:  attribute_group_type
	--  p_attr_group_type      application_id
	--        OUT
	--  l_table_name     : translatable table for attribute_changes
	------------------------------------------------------------------------------------------
	FUNCTION Get_Attr_Changes_TL_Table (
	        p_application_id                IN   NUMBER
	       ,p_attr_group_type               IN   VARCHAR2
	)
	RETURN VARCHAR2
	IS

	    l_table_name             VARCHAR2(30);
	    l_dynamic_sql            VARCHAR2(350);

	  BEGIN
	    l_dynamic_sql:='SELECT CHANGE_TL_TABLE_NAME'||
	'      FROM ENG_PENDING_CHANGE_CTX'||
	'     WHERE APPLICATION_ID = :1'||--p_application_id
	'    AND CHANGE_ATTRIBUTE_GROUP_TYPE =:2' ;--p_attr_group_type;

	    EXECUTE IMMEDIATE l_dynamic_sql INTO l_table_name USING p_application_id
	                                                            ,p_attr_group_type;

	    RETURN l_table_name;

	  EXCEPTION
	    WHEN OTHERS THEN
	      RETURN NULL;

	END Get_Attr_Changes_TL_Table;

	------------------------------------------------------------------------------------------
	-- Function: To return the  pending base table name  for a given attribute group type
	--  an the application id
	--           If the table is not defined, NULL is returned
	--
	-- Parameters:
	--         IN
	--  p_attr_group_type:  attribute_group_type
	--  p_attr_group_type      application_id
	--        OUT
	--  l_table_name     : base table for attribute_changes
	------------------------------------------------------------------------------------------
	FUNCTION Get_Attr_Changes_B_Table (
	        p_application_id                IN   NUMBER
	       ,p_attr_group_type               IN   VARCHAR2
	)
	RETURN VARCHAR2
	IS

	    l_table_name             VARCHAR2(30);
	    l_dynamic_sql            VARCHAR2(350);

	  BEGIN
	    l_dynamic_sql:='SELECT CHANGE_B_TABLE_NAME'||
	'      FROM ENG_PENDING_CHANGE_CTX'||
	'     WHERE APPLICATION_ID = :1'||--p_application_id
	'    AND CHANGE_ATTRIBUTE_GROUP_TYPE =:2' ;--p_attr_group_type;

	    EXECUTE IMMEDIATE l_dynamic_sql INTO l_table_name USING p_application_id
	                                                            ,p_attr_group_type;
	    RETURN l_table_name;

	  EXCEPTION
	    WHEN OTHERS THEN
	      RETURN NULL;
	END Get_Attr_Changes_B_Table;

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
END ego_ag_bulkload_pvt;

/
