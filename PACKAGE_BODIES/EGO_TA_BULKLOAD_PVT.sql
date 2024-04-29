--------------------------------------------------------
--  DDL for Package Body EGO_TA_BULKLOAD_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EGO_TA_BULKLOAD_PVT" AS
/* $Header: EGOVTABB.pls 120.0.12010000.6 2010/05/27 11:57:39 ccsingh noship $ */

-----=================Import_TA_Intf===============------

PROCEDURE  Import_TA_Intf(
             p_api_version             IN         NUMBER,
             p_set_process_id          IN         NUMBER,
             p_item_catalog_group_id   IN         NUMBER,
             p_icc_version_number_intf IN         NUMBER,
             p_icc_version_number_act  IN         NUMBER,
             x_return_status           OUT NOCOPY VARCHAR2,
             x_return_msg              OUT NOCOPY VARCHAR2)
IS

l_return_status       VARCHAR2(1);
l_return_msg          VARCHAR2(2000);
l_ta_intf_tbl         TA_Intf_Tbl;
l_err_rec             NUMBER :=0;
l_rec_exists          NUMBER :=0;
l_proc_name           VARCHAR2(200) := 'Import_TA_Intf';
BEGIN

  ego_metadata_bulkload_pvt.Write_debug(G_PKG_NAME||'.'||l_proc_name||'->'||'Entering Import_TA_Intf');
  ego_metadata_bulkload_pvt.Write_debug(G_PKG_NAME||'.'||l_proc_name||'->'||'Setting G_FLOW_TYPE=G_EGO_MD_INTF');
  -- Initializing message --
  FND_MSG_PUB.INITIALIZE;
  -- setting flow type as interface
  G_FLOW_TYPE:=G_EGO_MD_INTF;
  x_return_status:=G_RET_STS_SUCCESS;

  /* has to be called through ICC versioning bulk validations.
  -- Initializing transaction_id, Upper(Transaction_type and
    -- setting G_APPLICATION_ID
  Initialize(p_set_process_id,l_return_status);
  --Bulk Validation on Interface table
  Bulk_Validate_Trans_Attrs(p_set_process_id);
  --*/
  BEGIN
     -- if any of the TA errored out during bulk,throw error
     SELECT 1 INTO l_err_rec
     FROM EGO_TRANS_ATTRS_VERS_INTF
     WHERE item_catalog_group_id= p_item_catalog_group_id
     AND   icc_version_number = p_icc_version_number_intf
     AND   process_status=G_ERROR_RECORD --3
	 AND    ((p_set_process_id IS NULL) OR (set_process_id = p_set_process_id))
     AND   ROWNUM=1;
  EXCEPTION
     WHEN No_Data_Found THEN
      l_err_rec:=0;
  END;

     IF l_err_rec=1 THEN
       x_return_status:=G_RET_STS_ERROR;
       RETURN ;
     ELSE
       -- checking if records are there to process or not
       SELECT Count(1) INTO l_rec_exists
       FROM EGO_TRANS_ATTRS_VERS_INTF
       WHERE item_catalog_group_id= p_item_catalog_group_id
       AND   icc_version_number= p_icc_version_number_intf
       AND   process_status=G_PROCESS_RECORD
	   AND    ((p_set_process_id IS NULL) OR (set_process_id = p_set_process_id))
	   AND   ROWNUM=1;

       IF l_rec_exists=0 THEN -- if no record exists for TA
         x_return_status:=G_RET_STS_SUCCESS;
         RETURN;
       ELSE
         -- Loading records in pl-sql
         Load_Trans_Attrs_recs(p_set_process_id    => p_set_process_id,
                         p_item_catalog_group_id   => p_item_catalog_group_id,
                         p_icc_version_number_intf => p_icc_version_number_intf,
                         p_icc_version_number_act  => p_icc_version_number_act,
                         x_ta_intf_tbl             => l_ta_intf_tbl,
                         x_return_status           => l_return_status ,
                         x_return_msg              => l_return_msg);

         -- Process_ta-- Main API which takes record table and do final transaction.
         Process_Trans_Attrs(p_api_version         => p_api_version,
                         p_ta_intf_tbl             => l_ta_intf_tbl,
                         p_item_catalog_group_id   => p_item_catalog_group_id,
                         p_icc_version_number_intf => p_icc_version_number_intf,
                         p_icc_version_number_act  => p_icc_version_number_act,
                         x_return_status           => l_return_status ,
                         x_return_msg              => l_return_msg);

         x_return_status:=l_return_status;
         x_return_msg:= l_return_msg;
        -- RETURN; -- no need to return from here.
       END IF ; --l_rec_exists=0
     END IF;--l_err_rec=1
  ego_metadata_bulkload_pvt.Write_debug(G_PKG_NAME||'.'||l_proc_name||'->'||'End Import_TA_Intf');
EXCEPTION
WHEN OTHERS THEN
x_return_status:=G_RET_STS_UNEXP_ERROR;
x_return_msg:= G_PKG_NAME||'.'||l_proc_name||'.'||SQLERRM;
ego_metadata_bulkload_pvt.Write_debug(G_PKG_NAME||'.'||l_proc_name||'->'||'Exception Import_TA_Intf');
END Import_TA_Intf ;

----=================Initialize =========-------

PROCEDURE Initialize(
            p_set_process_id IN         NUMBER,
            x_return_status  OUT NOCOPY VARCHAR2)
IS
l_proc_name           VARCHAR2(200) := 'Initialize';
BEGIN
ego_metadata_bulkload_pvt.Write_debug(G_PKG_NAME||'.'||l_proc_name||'->'||'Entering Initialize');

  /*Sets the EGO application ID*/
  SELECT application_id
  INTO   G_APPLICATION_ID
  FROM   fnd_application
  WHERE  application_short_name = G_APP_NAME;


  /*Sets the Transaction_id and upper case the transaction_type*/
  UPDATE EGO_TRANS_ATTRS_VERS_INTF
  SET    transaction_id     = mtl_system_items_interface_s.nextval,
         transaction_type   = Upper(transaction_type),
         created_by         = Nvl(created_by,g_user_id),
         creation_date      = Nvl(creation_date,SYSDATE),
         last_updated_by    = G_USER_ID,
         last_update_date   = SYSDATE,
         last_update_login  = G_LOGIN_ID,
	  /* bug 9752139*/
         request_id             = G_REQUEST_ID,
         program_application_id = G_PROG_APPL_ID,
         program_id             = G_PROGRAM_ID   ,
         program_update_date    = SYSDATE
  WHERE  transaction_id IS NULL
  AND    process_status = G_PROCESS_RECORD
  AND    ((p_set_process_id IS NULL) OR (set_process_id = p_set_process_id));

 ego_metadata_bulkload_pvt.Write_debug(G_PKG_NAME||'.'||l_proc_name||'->'||SQL%ROWCOUNT||' Rows Initialize');
 ego_metadata_bulkload_pvt.Write_debug(G_PKG_NAME||'.'||l_proc_name||'->'||'End Initialize');
EXCEPTION
  WHEN OTHERS THEN
  x_return_status:=G_RET_STS_ERROR;
  ego_metadata_bulkload_pvt.Write_debug(G_PKG_NAME||'.'||l_proc_name||'->'||'When Others Exception while Initialize');
END Initialize;

--=================Bulk_Validate_Trans_Attrs========
PROCEDURE  Bulk_Validate_Trans_Attrs (p_set_process_id   IN     NUMBER)
IS
l_proc_name           VARCHAR2(200) := 'Bulk_Validate_Trans_Attrs';
BEGIN
   ego_metadata_bulkload_pvt.Write_debug(G_PKG_NAME||'.'||l_proc_name||'->'||'Entered Bulk_Validate_Trans_Attrs');
   ego_metadata_bulkload_pvt.Write_debug(G_PKG_NAME||'.'||l_proc_name||'->'||'Checking valid transaction types');

   /* Invalid Transaction type */
  G_MESSAGE_NAME := 'EGO_TRANS_TYPE_INVALID';
  FND_MESSAGE.SET_NAME('EGO',G_MESSAGE_NAME);
  G_MESSAGE_TEXT := fnd_message.get;

  INSERT INTO mtl_interface_errors(
              transaction_id,
              unique_id,
              organization_id,
              column_name,
              table_name,
              message_name,
              error_message,
              BO_IDENTIFIER,
              ENTITY_IDENTIFIER,
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
              'EGO_TRANS_ATTRS_VERS_INTF',
              G_MESSAGE_NAME,
              G_MESSAGE_TEXT,
              G_BO_IDENTIFIER,
              G_ENTITY_IDENTIFIER,
              NVL(last_update_date,SYSDATE),
              NVL(last_updated_by,G_USER_ID),
              NVL(creation_date,SYSDATE),
              NVL(created_by,G_USER_ID),
              NVL(last_update_login,G_LOGIN_ID),
              G_REQUEST_ID,
              NVL(program_application_id,G_PROG_APPL_ID),
              NVL(program_id,G_PROGRAM_ID),
              NVL(program_update_date,SYSDATE)
  FROM EGO_TRANS_ATTRS_VERS_INTF
  WHERE ((transaction_type is NULL) or (transaction_type  NOT IN (G_CREATE,G_UPDATE,G_DELETE,G_SYNC)))
  AND   transaction_id    IS NOT NULL
  AND   process_status    =       G_PROCESS_RECORD
  AND   ((p_set_process_id IS NULL) OR (set_process_id=p_set_process_id));

  /* Invalid Transaction type */
  UPDATE EGO_TRANS_ATTRS_VERS_INTF
  SET    process_status     =G_ERROR_RECORD,
         last_updated_by      = G_USER_ID,
         last_update_date     = SYSDATE,
         last_update_login    = G_LOGIN_ID
  WHERE  ((transaction_type is NULL) or (transaction_type  NOT IN (G_CREATE,G_UPDATE,G_DELETE,G_SYNC))) /* bug 9752139 */
  AND    transaction_id    IS NOT NULL
  AND    process_status=G_PROCESS_RECORD
  AND    ((p_set_process_id IS NULL) OR (set_process_id=p_set_process_id));
    -------------------------------------------
  ego_metadata_bulkload_pvt.Write_debug(G_PKG_NAME||'.'||l_proc_name||'->'||'Calling Value_to_Id for ICC,Value Set and Attr name');
/* calling value to id for icc,valueset and attr name to id conversion*/

  Value_to_Id(p_set_process_id);

  -------------------------------------------
  G_MESSAGE_NAME := 'EGO_NOT_SUPP_TRANS';
  FND_MESSAGE.SET_NAME('EGO',G_MESSAGE_NAME);
  G_MESSAGE_TEXT := fnd_message.get;
   -- restricting updation and deletion right now as we are not supporting them for now
   -- commenting this will allow update and delete valid cases work properly
    INSERT INTO mtl_interface_errors(
              transaction_id,
              unique_id,
              organization_id,
              column_name,
              table_name,
              message_name,
              error_message,
              BO_IDENTIFIER,
              ENTITY_IDENTIFIER,
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
              'EGO_TRANS_ATTRS_VERS_INTF',
              G_MESSAGE_NAME,
              G_MESSAGE_TEXT,
              G_BO_IDENTIFIER,
              G_ENTITY_IDENTIFIER,
              NVL(last_update_date,SYSDATE),
              NVL(last_updated_by,G_USER_ID),
              NVL(creation_date,SYSDATE),
              NVL(created_by,G_USER_ID),
              NVL(last_update_login,G_LOGIN_ID),
              G_REQUEST_ID,
              NVL(program_application_id,G_PROG_APPL_ID),
              NVL(program_id,G_PROGRAM_ID),
              NVL(program_update_date,SYSDATE)
  FROM EGO_TRANS_ATTRS_VERS_INTF
  WHERE transaction_type  IN (G_UPDATE,G_DELETE,G_SYNC)
  AND   transaction_id    IS NOT NULL
  AND   process_status    =  G_PROCESS_RECORD
  AND   ((p_set_process_id IS NULL) OR (set_process_id=p_set_process_id));

  /* not supporting now */
  UPDATE EGO_TRANS_ATTRS_VERS_INTF
  SET    process_status     =G_ERROR_RECORD,
         last_updated_by      = G_USER_ID,
         last_update_date     = SYSDATE,
         last_update_login    = G_LOGIN_ID
  WHERE  transaction_type IN (G_UPDATE,G_DELETE,G_SYNC)
  AND    transaction_id    IS NOT NULL
  AND    process_status=G_PROCESS_RECORD
  AND    ((p_set_process_id IS NULL) OR (set_process_id=p_set_process_id));
---------------------------------------------------------
  G_MESSAGE_NAME := 'EGO_NOT_SUPP_DFT_CREATE';
  FND_MESSAGE.SET_NAME('EGO',G_MESSAGE_NAME);
  G_MESSAGE_TEXT := fnd_message.get;
  -- for now not supporting creation of TA for draft.
  -- commenting this will allow create TA on draft version
  INSERT INTO mtl_interface_errors(
              transaction_id,
              unique_id,
              organization_id,
              column_name,
              table_name,
              message_name,
              error_message,
              BO_IDENTIFIER,
              ENTITY_IDENTIFIER,
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
              'EGO_TRANS_ATTRS_VERS_INTF',
              G_MESSAGE_NAME,
              G_MESSAGE_TEXT,
              G_BO_IDENTIFIER,
              G_ENTITY_IDENTIFIER,
              NVL(last_update_date,SYSDATE),
              NVL(last_updated_by,G_USER_ID),
              NVL(creation_date,SYSDATE),
              NVL(created_by,G_USER_ID),
              NVL(last_update_login,G_LOGIN_ID),
              G_REQUEST_ID,
              NVL(program_application_id,G_PROG_APPL_ID),
              NVL(program_id,G_PROGRAM_ID),
              NVL(program_update_date,SYSDATE)
  FROM EGO_TRANS_ATTRS_VERS_INTF
  WHERE transaction_type  IN (G_CREATE)
  AND   transaction_id    IS NOT NULL
  AND   icc_version_number=0
  AND   process_status    =  G_PROCESS_RECORD
  AND   ((p_set_process_id IS NULL) OR (set_process_id=p_set_process_id));

  /* not supporting now */
  UPDATE EGO_TRANS_ATTRS_VERS_INTF
  SET    process_status     =G_ERROR_RECORD,
         last_updated_by      = G_USER_ID,
         last_update_date     = SYSDATE,
         last_update_login    = G_LOGIN_ID
  WHERE transaction_type  IN (G_CREATE)
  AND   transaction_id    IS NOT NULL
  AND   icc_version_number=0
  AND   process_status=G_PROCESS_RECORD
  AND   ((p_set_process_id IS NULL) OR (set_process_id=p_set_process_id));

  --------------------------------------------------
  --ego_metadata_bulkload_pvt.Write_debug(G_PKG_NAME||'.'||l_proc_name||'->'||' Checking ICC name provided doesnt exists in table');

 /* commented as now decided to process ICC one by one
 so not validated ICC at table level as that not be there and set to 3*/
  /*G_MESSAGE_NAME := 'EGO_ITEMCATALOG_INVALID';
  FND_MESSAGE.SET_NAME('EGO',G_MESSAGE_NAME);
  G_MESSAGE_TEXT := fnd_message.get;
  INSERT INTO mtl_interface_errors(
              transaction_id,
              unique_id,
              organization_id,
              column_name,
              table_name,
              message_name,
              error_message,
              BO_IDENTIFIER,
              ENTITY_IDENTIFIER,
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
              'EGO_TRANS_ATTRS_VERS_INTF',
              G_MESSAGE_NAME,
              G_MESSAGE_TEXT,
              G_BO_IDENTIFIER,
              G_ENTITY_IDENTIFIER,
              NVL(last_update_date,SYSDATE),
              NVL(last_updated_by,G_USER_ID),
              NVL(creation_date,SYSDATE),
              NVL(created_by,G_USER_ID),
              NVL(last_update_login,G_LOGIN_ID),
              G_REQUEST_ID,
              NVL(program_application_id,G_PROG_APPL_ID),
              NVL(program_id,G_PROGRAM_ID),
              NVL(program_update_date,SYSDATE)
       FROM   EGO_TRANS_ATTRS_VERS_INTF
       WHERE  item_catalog_group_id IS NULL
       AND    item_catalog_group_name IS NOT NULL
       AND    transaction_id    IS NOT NULL
       AND    process_status    =       G_PROCESS_RECORD
       AND    ((p_set_process_id IS NULL) OR (set_process_id=p_set_process_id));

  UPDATE EGO_TRANS_ATTRS_VERS_INTF
  SET   process_status       = G_ERROR_RECORD,
        last_updated_by      = G_USER_ID,
        last_update_date     = SYSDATE,
        last_update_login    = G_LOGIN_ID
  WHERE item_catalog_group_id   IS NULL
  AND   item_catalog_group_name IS NOT NULL
  AND   transaction_id          IS NOT NULL
  AND   process_status=G_PROCESS_RECORD
  AND   ((p_set_process_id IS NULL) OR (set_process_id=p_set_process_id));*/

  ego_metadata_bulkload_pvt.Write_debug(G_PKG_NAME||'.'||l_proc_name||'->'||'Checking if both icc_id and icc_name are null');

  G_MESSAGE_NAME := 'EGO_ICC_REQUIRED_FIELD';
  FND_MESSAGE.SET_NAME('EGO',G_MESSAGE_NAME);
  G_MESSAGE_TEXT := fnd_message.get;
  /* if both icc_id and icc_name are null*/
  INSERT INTO mtl_interface_errors(
              transaction_id,
              unique_id,
              organization_id,
              column_name,
              table_name,
              message_name,
              error_message,
              BO_IDENTIFIER,
              ENTITY_IDENTIFIER,
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
              'EGO_TRANS_ATTRS_VERS_INTF',
              G_MESSAGE_NAME,
              G_MESSAGE_TEXT,
              G_BO_IDENTIFIER,
              G_ENTITY_IDENTIFIER,
              NVL(last_update_date,SYSDATE),
              NVL(last_updated_by,G_USER_ID),
              NVL(creation_date,SYSDATE),
              NVL(created_by,G_USER_ID),
              NVL(last_update_login,G_LOGIN_ID),
              G_REQUEST_ID,
              NVL(program_application_id,G_PROG_APPL_ID),
              NVL(program_id,G_PROGRAM_ID),
              NVL(program_update_date,SYSDATE)
       FROM   EGO_TRANS_ATTRS_VERS_INTF
       WHERE  item_catalog_group_id IS NULL
       AND    item_catalog_group_name IS NULL
       AND    transaction_id    IS NOT NULL
       AND    process_status    =       G_PROCESS_RECORD
       AND    ((p_set_process_id IS NULL) OR (set_process_id=p_set_process_id));

    /* if both icc_id and icc_name are null*/
  UPDATE EGO_TRANS_ATTRS_VERS_INTF
  SET   process_status       = G_ERROR_RECORD,
        last_updated_by      = G_USER_ID,
        last_update_date     = SYSDATE,
        last_update_login    = G_LOGIN_ID
  WHERE item_catalog_group_id   IS NULL
  AND   item_catalog_group_name IS NULL
  AND   transaction_id          IS NOT NULL
  AND   process_status=G_PROCESS_RECORD
  AND   ((p_set_process_id IS NULL) OR (set_process_id=p_set_process_id));


  ego_metadata_bulkload_pvt.Write_debug(G_PKG_NAME||'.'||l_proc_name||'->'||'Checking if passed icc_id dosent exists');

  G_MESSAGE_NAME := 'EGO_ITEMCATALOG_INVALID';
  FND_MESSAGE.SET_NAME('EGO',G_MESSAGE_NAME);
  G_MESSAGE_TEXT := fnd_message.get;
   /* If passed icc_id dosent exists*/
  INSERT INTO mtl_interface_errors(
              transaction_id,
              unique_id,
              organization_id,
              column_name,
              table_name,
              message_name,
              error_message,
              BO_IDENTIFIER,
              ENTITY_IDENTIFIER,
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
              'EGO_TRANS_ATTRS_VERS_INTF',
              G_MESSAGE_NAME,
              G_MESSAGE_TEXT,
              G_BO_IDENTIFIER,
              G_ENTITY_IDENTIFIER,
              NVL(last_update_date,SYSDATE),
              NVL(last_updated_by,G_USER_ID),
              NVL(creation_date,SYSDATE),
              NVL(created_by,G_USER_ID),
              NVL(last_update_login,G_LOGIN_ID),
              G_REQUEST_ID,
              NVL(program_application_id,G_PROG_APPL_ID),
              NVL(program_id,G_PROGRAM_ID),
              NVL(program_update_date,SYSDATE)
       FROM   EGO_TRANS_ATTRS_VERS_INTF ETAVI
       WHERE  ETAVI.item_catalog_group_id IS NOT NULL
       AND    NOT EXISTS (
                    SELECT 1
                    FROM mtl_item_catalog_groups micg
                    WHERE micg.ITEM_CATALOG_GROUP_ID=ETAVI.ITEM_CATALOG_GROUP_ID)
       AND    ETAVI.transaction_id    IS NOT NULL
       AND    ETAVI.process_status    =       G_PROCESS_RECORD
       AND    ((p_set_process_id IS NULL) OR (ETAVI.set_process_id=p_set_process_id));

   /* If passed icc_id dosent exists*/
  UPDATE EGO_TRANS_ATTRS_VERS_INTF ETAVI
  SET   ETAVI.process_status       = G_ERROR_RECORD,
        ETAVI.last_updated_by      = G_USER_ID,
        ETAVI.last_update_date     = SYSDATE,
        ETAVI.last_update_login    = G_LOGIN_ID
  WHERE ETAVI.item_catalog_group_id IS NOT NULL
  AND   NOT EXISTS (
                    SELECT 1
                    FROM mtl_item_catalog_groups micg
                    WHERE micg.ITEM_CATALOG_GROUP_ID=ETAVI.ITEM_CATALOG_GROUP_ID)
  AND   ETAVI.transaction_id    IS NOT NULL
  AND   ETAVI.process_status    =       G_PROCESS_RECORD
  AND   ((p_set_process_id IS NULL) OR (ETAVI.set_process_id=p_set_process_id));
   -------------------------------------------
  ego_metadata_bulkload_pvt.Write_debug(G_PKG_NAME||'.'||l_proc_name||'->'||'Checking if VS name provided doesnt exists');

  G_MESSAGE_NAME := 'EGO_EF_NO_VALUE_SETS_FOUND';
  FND_MESSAGE.SET_NAME('EGO',G_MESSAGE_NAME);
  G_MESSAGE_TEXT := fnd_message.get;
  /*if VS name provided doesnt exists in table */
  INSERT INTO mtl_interface_errors(
              transaction_id,
              unique_id,
              organization_id,
              column_name,
              table_name,
              message_name,
              error_message,
              BO_IDENTIFIER,
              ENTITY_IDENTIFIER,
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
              'EGO_TRANS_ATTRS_VERS_INTF',
              G_MESSAGE_NAME,
              G_MESSAGE_TEXT,
              G_BO_IDENTIFIER,
              G_ENTITY_IDENTIFIER,
              NVL(last_update_date,SYSDATE),
              NVL(last_updated_by,G_USER_ID),
              NVL(creation_date,SYSDATE),
              NVL(created_by,G_USER_ID),
              NVL(last_update_login,G_LOGIN_ID),
              G_REQUEST_ID,
              NVL(program_application_id,G_PROG_APPL_ID),
              NVL(program_id,G_PROGRAM_ID),
              NVL(program_update_date,SYSDATE)
       FROM   EGO_TRANS_ATTRS_VERS_INTF
       WHERE  value_set_id   IS NULL
       AND    Value_set_name IS NOT NULL
       AND    transaction_type IN (G_CREATE,G_UPDATE,G_SYNC)
       AND    transaction_id IS NOT NULL
       AND    process_status    =  G_PROCESS_RECORD
       AND    ((p_set_process_id IS NULL) OR (set_process_id=p_set_process_id));


  /*if value set name provided doesnt exists in table */
  UPDATE EGO_TRANS_ATTRS_VERS_INTF
  SET   process_status       = G_ERROR_RECORD,
        last_updated_by      = G_USER_ID,
        last_update_date     = SYSDATE,
        last_update_login    = G_LOGIN_ID
  WHERE value_set_id   IS NULL
  AND   Value_set_name IS NOT NULL
  AND   transaction_type IN (G_CREATE,G_UPDATE,G_SYNC)
  AND   transaction_id IS NOT NULL
  AND   process_status   =   G_PROCESS_RECORD
  AND   ((p_set_process_id IS NULL) OR (set_process_id=p_set_process_id));


  ego_metadata_bulkload_pvt.Write_debug(G_PKG_NAME||'.'||l_proc_name||'->'||'Checking if given value set id is valid or not');

  G_MESSAGE_NAME := 'EGO_EF_NO_VALUE_SETS_FOUND';
  FND_MESSAGE.SET_NAME('EGO',G_MESSAGE_NAME);
  G_MESSAGE_TEXT := fnd_message.get;
  INSERT INTO mtl_interface_errors(
              transaction_id,
              unique_id,
              organization_id,
              column_name,
              table_name,
              message_name,
              error_message,
              BO_IDENTIFIER,
              ENTITY_IDENTIFIER,
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
              'EGO_TRANS_ATTRS_VERS_INTF',
              G_MESSAGE_NAME,
              G_MESSAGE_TEXT,
              G_BO_IDENTIFIER,
              G_ENTITY_IDENTIFIER,
              NVL(last_update_date,SYSDATE),
              NVL(last_updated_by,G_USER_ID),
              NVL(creation_date,SYSDATE),
              NVL(created_by,G_USER_ID),
              NVL(last_update_login,G_LOGIN_ID),
              G_REQUEST_ID,
              NVL(program_application_id,G_PROG_APPL_ID),
              NVL(program_id,G_PROGRAM_ID),
              NVL(program_update_date,SYSDATE)
       FROM   EGO_TRANS_ATTRS_VERS_INTF ETAVT
       WHERE  value_set_id IS NOT NULL
       AND    NOT EXISTS (
                    SELECT 1
                    FROM fnd_flex_value_sets  ffvs
                    WHERE ffvs.flex_value_set_id = ETAVT.value_set_id)
       AND    transaction_type IN (G_CREATE,G_UPDATE,G_SYNC)
       AND    ETAVT.transaction_id    IS NOT NULL
       AND    ETAVT.process_status    =       G_PROCESS_RECORD
       AND    ((p_set_process_id IS NULL) OR (ETAVT.set_process_id=p_set_process_id));

    /*given value set id is valid or not*/
  UPDATE EGO_TRANS_ATTRS_VERS_INTF ETAVT
  SET   ETAVT.process_status       =G_ERROR_RECORD,
        ETAVT.last_updated_by      = G_USER_ID,
        ETAVT.last_update_date     = SYSDATE,
        ETAVT.last_update_login    = G_LOGIN_ID
  WHERE ETAVT.value_set_id IS NOT NULL
  AND   NOT EXISTS (
                    SELECT 1
                    FROM fnd_flex_value_sets
                    WHERE flex_value_set_id = ETAVT.value_set_id)
  AND   transaction_type IN (G_CREATE,G_UPDATE,G_SYNC)
  AND   ETAVT.transaction_id IS NOT NULL
  AND   ETAVT.process_status = G_PROCESS_RECORD
  AND   ((p_set_process_id IS NULL) OR (ETAVT.set_process_id=p_set_process_id));

   -------------------------------------------
  ego_metadata_bulkload_pvt.Write_debug(G_PKG_NAME||'.'||l_proc_name||'->'||'Checking if given attr_name is valid');

  G_MESSAGE_NAME := 'EGO_ATTR_NOT_EXISTS';
  FND_MESSAGE.SET_NAME('EGO',G_MESSAGE_NAME);
  G_MESSAGE_TEXT := fnd_message.get;
  /* Attrname provided is valid or not*/
  INSERT INTO mtl_interface_errors(
              transaction_id,
              unique_id,
              organization_id,
              column_name,
              table_name,
              message_name,
              error_message,
              BO_IDENTIFIER,
              ENTITY_IDENTIFIER,
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
              'EGO_TRANS_ATTRS_VERS_INTF',
              G_MESSAGE_NAME,
              G_MESSAGE_TEXT,
              G_BO_IDENTIFIER,
              G_ENTITY_IDENTIFIER,
              NVL(last_update_date,SYSDATE),
              NVL(last_updated_by,G_USER_ID),
              NVL(creation_date,SYSDATE),
              NVL(created_by,G_USER_ID),
              NVL(last_update_login,G_LOGIN_ID),
              G_REQUEST_ID,
              NVL(program_application_id,G_PROG_APPL_ID),
              NVL(program_id,G_PROGRAM_ID),
              NVL(program_update_date,SYSDATE)
       FROM   EGO_TRANS_ATTRS_VERS_INTF
       WHERE  attr_id IS NULL
       AND    attr_name IS NOT NULL
       AND    transaction_type IN (G_UPDATE,G_DELETE)
       AND    transaction_id    IS NOT NULL
       AND    process_status    =       G_PROCESS_RECORD
       AND    ((p_set_process_id IS NULL) OR (set_process_id=p_set_process_id));

   /*if attr name provided doesnt exists in table */
  UPDATE EGO_TRANS_ATTRS_VERS_INTF
  SET   process_status       = G_ERROR_RECORD,
        last_updated_by      = G_USER_ID,
        last_update_date     = SYSDATE,
        last_update_login    = G_LOGIN_ID
  WHERE attr_id IS NULL
  AND   attr_name IS NOT NULL
  AND   transaction_type IN (G_UPDATE,G_DELETE)
  AND   transaction_id  IS NOT NULL
  AND   process_status = G_PROCESS_RECORD
  AND   ((p_set_process_id IS NULL) OR (set_process_id=p_set_process_id));

  ego_metadata_bulkload_pvt.Write_debug(G_PKG_NAME||'.'||l_proc_name||'->'||'if attr_name is given with sync and not exists- convert to Create');
   /* converting sync to create or update */
     /* if attr_name is given with sync and not exists */
     UPDATE EGO_TRANS_ATTRS_VERS_INTF ETAVT
     SET   transaction_type     = G_CREATE,
           last_updated_by      = G_USER_ID,
           last_update_date     = SYSDATE,
           last_update_login    = G_LOGIN_ID
     WHERE attr_id   IS NULL
     AND   attr_name IS NOT NULL
     AND   transaction_type =G_SYNC
     AND   transaction_id IS NOT NULL
     AND   process_status = G_PROCESS_RECORD
     AND   ((p_set_process_id IS NULL) OR (ETAVT.set_process_id=p_set_process_id));

  ego_metadata_bulkload_pvt.Write_debug(G_PKG_NAME||'.'||l_proc_name||'->'||'Checking if given attr_id is valid or not');

  G_MESSAGE_NAME := 'EGO_INVALID_TA';
  FND_MESSAGE.SET_NAME('EGO',G_MESSAGE_NAME);
  G_MESSAGE_TEXT := fnd_message.get;
	/*given attr_id is invalid or not*/
  INSERT INTO mtl_interface_errors(
              transaction_id,
              unique_id,
              organization_id,
              column_name,
              table_name,
              message_name,
              error_message,
              BO_IDENTIFIER,
              ENTITY_IDENTIFIER,
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
              'EGO_TRANS_ATTRS_VERS_INTF',
              G_MESSAGE_NAME,
              G_MESSAGE_TEXT,
              G_BO_IDENTIFIER,
              G_ENTITY_IDENTIFIER,
              NVL(last_update_date,SYSDATE),
              NVL(last_updated_by,G_USER_ID),
              NVL(creation_date,SYSDATE),
              NVL(created_by,G_USER_ID),
              NVL(last_update_login,G_LOGIN_ID),
              G_REQUEST_ID,
              NVL(program_application_id,G_PROG_APPL_ID),
              NVL(program_id,G_PROGRAM_ID),
              NVL(program_update_date,SYSDATE)
       FROM   EGO_TRANS_ATTRS_VERS_INTF ETAVT
       WHERE  attr_id IS NOT NULL
       AND    NOT EXISTS (
                    SELECT 1
                    FROM EGO_TRANS_ATTR_VERS_B ETAVB
                    WHERE ETAVB.attr_id = ETAVT.attr_id
                    AND   ETAVB.item_catalog_group_id=ETAVT.item_catalog_group_id
                    AND   ETAVB.icc_version_number=0)
       AND    ETAVT.transaction_type IN (G_UPDATE,G_DELETE,G_SYNC)
       AND    ETAVT.transaction_id    IS NOT NULL
       AND    ETAVT.process_status    =       G_PROCESS_RECORD
       AND    ((p_set_process_id IS NULL) OR (ETAVT.set_process_id=p_set_process_id));

  /*given attr id is valid or not*/
  UPDATE EGO_TRANS_ATTRS_VERS_INTF ETAVT
  SET   ETAVT.process_status       = G_ERROR_RECORD,
        ETAVT.last_updated_by      = G_USER_ID,
        ETAVT.last_update_date     = SYSDATE,
        ETAVT.last_update_login    = G_LOGIN_ID
  WHERE attr_id IS NOT NULL
  AND   NOT EXISTS (
                    SELECT 1
                    FROM EGO_TRANS_ATTR_VERS_B ETAVB
                    WHERE ETAVB.attr_id = ETAVT.attr_id
                    AND   ETAVB.item_catalog_group_id=ETAVT.item_catalog_group_id
                    AND   ETAVB.icc_version_number=0)
  AND   ETAVT.transaction_type IN (G_UPDATE,G_DELETE,G_SYNC)
  AND   ETAVT.transaction_id    IS NOT NULL
  AND   ETAVT.process_status    =       G_PROCESS_RECORD
  AND   ((p_set_process_id IS NULL) OR (ETAVT.set_process_id=p_set_process_id));

  ego_metadata_bulkload_pvt.Write_debug(G_PKG_NAME||'.'||l_proc_name||'->'||'Checking if attr_name given with sync - convert to Update');
   /* if attr_name is given with sync and exists */
     UPDATE EGO_TRANS_ATTRS_VERS_INTF ETAVT
     SET   transaction_type     = G_UPDATE,
           last_updated_by      = G_USER_ID,
           last_update_date     = SYSDATE,
           last_update_login    = G_LOGIN_ID
     WHERE attr_id   IS NOT NULL
     AND   EXISTS (
                    SELECT 1
                    FROM EGO_TRANS_ATTR_VERS_B ETAVB
                    WHERE ETAVB.attr_id = ETAVT.attr_id
                    AND   ETAVB.item_catalog_group_id=ETAVT.item_catalog_group_id
                    AND   ETAVB.icc_version_number=0)
     --AND   attr_name IS NOT NULL
     AND   transaction_type =G_SYNC
     AND   transaction_id IS NOT NULL
     AND   process_status = G_PROCESS_RECORD
     AND   ((p_set_process_id IS NULL) OR (ETAVT.set_process_id=p_set_process_id));

     ego_metadata_bulkload_pvt.Write_debug(G_PKG_NAME||'.'||l_proc_name||'->'||'Getting attr_name if only display_name is given');
     /* if attr_display name and sync given and it got converted into
      update as here we are sure we got the attr_id so populating attr_name
      if not given*/
     UPDATE EGO_TRANS_ATTRS_VERS_INTF ETAVT
     SET    attr_name= (SELECT attr_name
                           FROM ego_attrs_v  EAV
                           WHERE EAV.attr_id= ETAVT.attr_id
                           )
     WHERE  ETAVT.attr_id IS NOT NULL
     AND    ETAVT.attr_display_name IS NOT NULL
     AND    ETAVT.transaction_type IN (G_UPDATE)
     AND    ETAVT.process_status = G_PROCESS_RECORD
     AND    ((p_set_process_id IS NULL) OR (set_process_id = p_set_process_id));

    ego_metadata_bulkload_pvt.Write_debug(G_PKG_NAME||'.'||l_proc_name||'->'||'Getting other metadata from main table if not provided by user to complete the record');
     /* to copy rest of the meta data for same attr_id,icc_id and version */
      UPDATE EGO_TRANS_ATTRS_VERS_INTF ETAVT
      SET  (uom_class,
            default_value,
            rejected_value,
            required_flag,
            readonly_flag,
            hidden_flag,
            searchable_flag,
            check_eligibility,
            value_set_id,
            attr_display_name,
            sequence) =
        (SELECT nvl(a.uom_class,b.uom_class),
                nvl(a.default_value,b.default_value),
                nvl(a.rejected_value,b.rejected_value),
                nvl(a.required_flag,b.required_flag),
                nvl(a.readonly_flag,b.readonly_flag),
                nvl(a.hidden_flag,b.hidden_flag),
                nvl(a.searchable_flag,b.searchable_flag),
                nvl(a.check_eligibility,b.check_eligibility),
                nvl(a.value_set_id,b.value_set_id),
                nvl(a.attr_display_name,b.attr_display_name),
                b.sequence
         FROM   EGO_TRANS_ATTRS_VERS_INTF a,EGO_TRANS_ATTR_VERS_B b
         WHERE  a.attr_id=b.attr_id
         AND    a.item_catalog_group_id=b.item_catalog_group_id
         AND    b.icc_version_number=0
         AND    a.attr_id=ETAVT.attr_id)
      WHERE attr_id IS NOT NULL
      AND   ETAVT.attr_name IS NOT NULL
      AND   ETAVT.transaction_type IN (G_UPDATE)
      AND   ETAVT.process_status = G_PROCESS_RECORD
      AND   ((p_set_process_id IS NULL) OR (set_process_id = p_set_process_id));

     -------------------------------------------
  ego_metadata_bulkload_pvt.Write_debug(G_PKG_NAME||'.'||l_proc_name||'->'||'Checking given attr_display name is valid or not.');

  G_MESSAGE_NAME := 'EGO_ATTR_DISP_NAME_MISSING';
  FND_MESSAGE.SET_NAME('EGO',G_MESSAGE_NAME);
  G_MESSAGE_TEXT := fnd_message.get;
  /* given attr_display name is valid or not and getting id or not */

  INSERT INTO mtl_interface_errors(
              transaction_id,
              unique_id,
              organization_id,
              column_name,
              table_name,
              message_name,
              error_message,
              BO_IDENTIFIER,
              ENTITY_IDENTIFIER,
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
              'EGO_TRANS_ATTRS_VERS_INTF',
              G_MESSAGE_NAME,
              G_MESSAGE_TEXT,
              G_BO_IDENTIFIER,
              G_ENTITY_IDENTIFIER,
              NVL(last_update_date,SYSDATE),
              NVL(last_updated_by,G_USER_ID),
              NVL(creation_date,SYSDATE),
              NVL(created_by,G_USER_ID),
              NVL(last_update_login,G_LOGIN_ID),
              G_REQUEST_ID,
              NVL(program_application_id,G_PROG_APPL_ID),
              NVL(program_id,G_PROGRAM_ID),
              NVL(program_update_date,SYSDATE)
       FROM   EGO_TRANS_ATTRS_VERS_INTF
       WHERE  attr_id IS NULL
       AND    attr_display_name  IS NOT NULL
       AND    transaction_type   IN (G_UPDATE,G_DELETE)
       AND    transaction_id     IS NOT NULL
       AND    process_status     =       G_PROCESS_RECORD
       AND    ((p_set_process_id IS NULL) OR (set_process_id=p_set_process_id));


    /*if attr disp name provided doesnt exists in table */
  UPDATE EGO_TRANS_ATTRS_VERS_INTF
  SET   process_status       = G_ERROR_RECORD,
        last_updated_by      = G_USER_ID,
        last_update_date     = SYSDATE,
        last_update_login    = G_LOGIN_ID
  WHERE attr_id IS NULL
  AND   attr_display_name IS NOT NULL
  AND   transaction_type  IN (G_UPDATE,G_DELETE)
  AND   transaction_id    IS NOT NULL
  AND   process_status    =       G_PROCESS_RECORD
  AND   ((p_set_process_id IS NULL) OR (set_process_id=p_set_process_id));

  ego_metadata_bulkload_pvt.Write_debug(G_PKG_NAME||'.'||l_proc_name||'->'||'If attr_display_name is given with sync and not exists- convert to Create .');
    /* converting sync to create or update */
     /* if attr_display_name is given with sync and not exists */
     UPDATE EGO_TRANS_ATTRS_VERS_INTF ETAVT
     SET   transaction_type     = G_CREATE,
           last_updated_by      = G_USER_ID,
           last_update_date     = SYSDATE,
           last_update_login    = G_LOGIN_ID
     WHERE attr_id   IS NULL
     AND   attr_display_name IS NOT NULL
     AND   transaction_type =G_SYNC
     AND   transaction_id IS NOT NULL
     AND   process_status = G_PROCESS_RECORD
     AND   ((p_set_process_id IS NULL) OR (ETAVT.set_process_id=p_set_process_id));

  ego_metadata_bulkload_pvt.Write_debug(G_PKG_NAME||'.'||l_proc_name||'->'||'Checking if All Attr_name, Attr_Display_Name,Attr_id are NULL For Upd,Del,Sync');
  /* if attr_name is null,attr_display_name is null and attr_id is null
     with sync then error out */

  UPDATE EGO_TRANS_ATTRS_VERS_INTF
  SET   process_status       =G_ERROR_RECORD,
        last_updated_by      = G_USER_ID,
        last_update_date     = SYSDATE,
        last_update_login    = G_LOGIN_ID
  WHERE attr_id IS NULL
  AND   attr_display_name IS NULL
  AND   attr_name IS NULL
  AND   transaction_type  IN (G_UPDATE,G_DELETE,G_SYNC)
  AND   transaction_id    IS NOT NULL
  AND   process_status    =       G_PROCESS_RECORD
  AND   ((p_set_process_id IS NULL) OR (set_process_id=p_set_process_id));

       -------------------------------------------
  ego_metadata_bulkload_pvt.Write_debug(G_PKG_NAME||'.'||l_proc_name||'->'||'Checking if Association_id is Valid or not');

  G_MESSAGE_NAME := 'EGO_TA_ASSOC_FAILED';
  FND_MESSAGE.SET_NAME('EGO',G_MESSAGE_NAME);
  G_MESSAGE_TEXT := fnd_message.get;
  /* Association id not able to convert in case of upate,delete,sync
   or association id provided doesnt exists in table*/

  INSERT INTO mtl_interface_errors(
              transaction_id,
              unique_id,
              organization_id,
              column_name,
              table_name,
              message_name,
              error_message,
              BO_IDENTIFIER,
              ENTITY_IDENTIFIER,
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
              'EGO_TRANS_ATTRS_VERS_INTF',
              G_MESSAGE_NAME,
              G_MESSAGE_TEXT,
              G_BO_IDENTIFIER,
              G_ENTITY_IDENTIFIER,
              NVL(last_update_date,SYSDATE),
              NVL(last_updated_by,G_USER_ID),
              NVL(creation_date,SYSDATE),
              NVL(created_by,G_USER_ID),
              NVL(last_update_login,G_LOGIN_ID),
              G_REQUEST_ID,
              NVL(program_application_id,G_PROG_APPL_ID),
              NVL(program_id,G_PROGRAM_ID),
              NVL(program_update_date,SYSDATE)
       FROM   EGO_TRANS_ATTRS_VERS_INTF
       WHERE  attr_id IS NOT NULL
       AND    item_catalog_group_id  IS NOT NULL
       AND    association_id IS NULL
       AND    transaction_type IN (G_UPDATE,G_DELETE,G_SYNC)
       AND    transaction_id    IS NOT NULL
       AND    process_status    =       G_PROCESS_RECORD
       AND    ((p_set_process_id IS NULL) OR (set_process_id=p_set_process_id));


  /*if not able to convert association id from given attr_id and icc_id
   in case of upd,del,sync */
  UPDATE EGO_TRANS_ATTRS_VERS_INTF
  SET   process_status       =G_ERROR_RECORD,
        last_updated_by      = G_USER_ID,
        last_update_date     = SYSDATE,
        last_update_login    = G_LOGIN_ID
  WHERE attr_id IS NOT NULL
  AND   item_catalog_group_id  IS NOT NULL
  AND   association_id IS NULL
  AND   transaction_type IN (G_UPDATE,G_DELETE,G_SYNC)
  AND   transaction_id    IS NOT NULL
  AND   process_status    =       G_PROCESS_RECORD
  AND   ((p_set_process_id IS NULL) OR (set_process_id=p_set_process_id));


  G_MESSAGE_NAME := 'EGO_ASSOC_ID_MISSING';
  FND_MESSAGE.SET_NAME('EGO',G_MESSAGE_NAME);
  G_MESSAGE_TEXT := fnd_message.get;
  /*given association is valid or not*/
  INSERT INTO mtl_interface_errors(
              transaction_id,
              unique_id,
              organization_id,
              column_name,
              table_name,
              message_name,
              error_message,
              BO_IDENTIFIER,
              ENTITY_IDENTIFIER,
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
              'EGO_TRANS_ATTRS_VERS_INTF',
              G_MESSAGE_NAME,
              G_MESSAGE_TEXT,
              G_BO_IDENTIFIER,
              G_ENTITY_IDENTIFIER,
              NVL(last_update_date,SYSDATE),
              NVL(last_updated_by,G_USER_ID),
              NVL(creation_date,SYSDATE),
              NVL(created_by,G_USER_ID),
              NVL(last_update_login,G_LOGIN_ID),
              G_REQUEST_ID,
              NVL(program_application_id,G_PROG_APPL_ID),
              NVL(program_id,G_PROGRAM_ID),
              NVL(program_update_date,SYSDATE)
       FROM   EGO_TRANS_ATTRS_VERS_INTF ETAVT
       WHERE  attr_id IS NOT NULL
       AND    item_catalog_group_id  IS NOT NULL
       AND    association_id IS NOT NULL
       AND    NOT EXISTS (
                    SELECT 1
                    FROM  EGO_TRANS_ATTR_VERS_B ETAVB
                    WHERE ETAVB.association_id = ETAVT.association_id
                    AND   ETAVB.item_Catalog_group_id= ETAVT.item_Catalog_group_id
                    AND   ETAVB.icc_version_number=0)
       AND    ETAVT.transaction_type IN (G_UPDATE,G_DELETE,G_SYNC)
       AND    ETAVT.transaction_id   IS NOT NULL
       AND    ETAVT.process_status   =  G_PROCESS_RECORD
       AND    ((p_set_process_id IS NULL) OR (ETAVT.set_process_id=p_set_process_id));

      /*if association provided and it is not valid*/
  UPDATE EGO_TRANS_ATTRS_VERS_INTF ETAVT
  SET   process_status       =G_ERROR_RECORD,
        last_updated_by      = G_USER_ID,
        last_update_date     = SYSDATE,
        last_update_login    = G_LOGIN_ID
  WHERE attr_id IS NOT NULL
  AND   item_catalog_group_id  IS NOT NULL
  AND   association_id IS NOT NULL
  AND   NOT EXISTS (
                    SELECT 1
                    FROM EGO_TRANS_ATTR_VERS_B ETAVB
                    WHERE ETAVB.association_id = ETAVT.association_id
                    AND   ETAVB.item_Catalog_group_id= ETAVT.item_Catalog_group_id
                    AND ETAVB.icc_version_number=0)
  AND   transaction_type IN (G_UPDATE,G_DELETE,G_SYNC)
  AND   transaction_id    IS NOT NULL
  AND   process_status    =       G_PROCESS_RECORD
  AND   ((p_set_process_id IS NULL) OR (set_process_id=p_set_process_id));

    -------------------------------------------

  ego_metadata_bulkload_pvt.Write_debug(G_PKG_NAME||'.'||l_proc_name||'->'||'Checking  Metadata Flag Values');

  G_MESSAGE_NAME := 'EGO_METADATA_FLAGS_INVALID';
  FND_MESSAGE.SET_NAME('EGO',G_MESSAGE_NAME);
  G_MESSAGE_TEXT := fnd_message.get;

  INSERT INTO mtl_interface_errors(
              transaction_id,
              unique_id,
              organization_id,
              column_name,
              table_name,
              message_name,
              error_message,
              BO_IDENTIFIER,
              ENTITY_IDENTIFIER,
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
              'EGO_TRANS_ATTRS_VERS_INTF',
              G_MESSAGE_NAME,
              G_MESSAGE_TEXT,
              G_BO_IDENTIFIER,
              G_ENTITY_IDENTIFIER,
              NVL(last_update_date,SYSDATE),
              NVL(last_updated_by,G_USER_ID),
              NVL(creation_date,SYSDATE),
              NVL(created_by,G_USER_ID),
              NVL(last_update_login,G_LOGIN_ID),
              G_REQUEST_ID,
              NVL(program_application_id,G_PROG_APPL_ID),
              NVL(program_id,G_PROGRAM_ID),
              NVL(program_update_date,SYSDATE)
  FROM  EGO_TRANS_ATTRS_VERS_INTF
  WHERE transaction_type IN (G_CREATE,G_UPDATE,G_DELETE,G_SYNC)
  AND   transaction_id    IS NOT NULL
  AND ((required_flag IS NOT NULL) OR (readonly_flag IS NOT NULL)
        OR (hidden_flag IS NOT NULL) OR (searchable_flag IS NOT NULL)
        OR (check_eligibility IS NOT NULL))
  AND  ( (required_flag NOT IN ('Y','N')) OR (readonly_flag NOT IN ('Y','N')) OR (hidden_flag NOT IN ('Y','N')) OR (searchable_flag NOT IN ('Y','N'))
        OR (check_eligibility NOT IN ('Y','N')))
  AND   process_status    =       G_PROCESS_RECORD
  AND   ((p_set_process_id IS NULL) OR (set_process_id=p_set_process_id));

        /*IF any of the flag has value other than 'Y' or 'N'*/
  UPDATE EGO_TRANS_ATTRS_VERS_INTF ETAVT
  SET   process_status       = G_ERROR_RECORD,
        last_updated_by      = G_USER_ID,
        last_update_date     = SYSDATE,
        last_update_login    = G_LOGIN_ID
  WHERE ((required_flag IS NOT NULL) OR (readonly_flag IS NOT NULL)
        OR (hidden_flag IS NOT NULL) OR (searchable_flag IS NOT NULL)
        OR (check_eligibility IS NOT NULL))
  AND   ((Upper(required_flag) NOT IN ('Y','N')) OR (Upper(readonly_flag) NOT IN ('Y','N'))
        OR (Upper(hidden_flag) NOT IN ('Y','N')) OR (Upper(searchable_flag) NOT IN ('Y','N'))
        OR (Upper(check_eligibility) NOT IN ('Y','N')))
  AND   transaction_type IN (G_CREATE,G_UPDATE,G_DELETE,G_SYNC)
  AND   transaction_id    IS NOT NULL
  AND   process_status    =       G_PROCESS_RECORD
  AND   ((p_set_process_id IS NULL) OR (set_process_id=p_set_process_id));

    -------------------------------------------

  ego_metadata_bulkload_pvt.Write_debug(G_PKG_NAME||'.'||l_proc_name||'->'||'Checking Valid Values for data type while CREATE');

  G_MESSAGE_NAME := 'EGO_DATA_TYPE_INVALID';
  FND_MESSAGE.SET_NAME('EGO',G_MESSAGE_NAME);
  G_MESSAGE_TEXT := fnd_message.get;

  INSERT INTO mtl_interface_errors(
              transaction_id,
              unique_id,
              organization_id,
              column_name,
              table_name,
              message_name,
              error_message,
              BO_IDENTIFIER,
              ENTITY_IDENTIFIER,
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
              'EGO_TRANS_ATTRS_VERS_INTF',
              G_MESSAGE_NAME,
              G_MESSAGE_TEXT,
              G_BO_IDENTIFIER,
              G_ENTITY_IDENTIFIER,
              NVL(last_update_date,SYSDATE),
              NVL(last_updated_by,G_USER_ID),
              NVL(creation_date,SYSDATE),
              NVL(created_by,G_USER_ID),
              NVL(last_update_login,G_LOGIN_ID),
              G_REQUEST_ID,
              NVL(program_application_id,G_PROG_APPL_ID),
              NVL(program_id,G_PROGRAM_ID),
              NVL(program_update_date,SYSDATE)
  FROM  EGO_TRANS_ATTRS_VERS_INTF
  WHERE transaction_type  IN (G_CREATE)
  AND   transaction_id    IS NOT NULL
  AND   data_type         IS NOT NULL
  AND   Upper(data_type) NOT IN ('C','A','N','X','Y')
  AND   process_status    =       G_PROCESS_RECORD
  AND   ((p_set_process_id IS NULL) OR (set_process_id=p_set_process_id));

        /*if association provided and it is not valid*/
  UPDATE EGO_TRANS_ATTRS_VERS_INTF ETAVT
  SET   process_status       = G_ERROR_RECORD,
        last_updated_by      = G_USER_ID,
        last_update_date     = SYSDATE,
        last_update_login    = G_LOGIN_ID
  WHERE data_type    IS NOT NULL
  AND   Upper(data_type) NOT IN ('C','A','N','X','Y')
  AND   transaction_type IN (G_CREATE)
  AND   transaction_id    IS NOT NULL
  AND   process_status    =    G_PROCESS_RECORD
  AND   ((p_set_process_id IS NULL) OR (set_process_id=p_set_process_id));

    -------------------------------------------

  ego_metadata_bulkload_pvt.Write_debug(G_PKG_NAME||'.'||l_proc_name||'->'||'Checking Association_id and attr_id should be null while T_Type is CREATE');

  G_MESSAGE_NAME := 'EGO_INCRRCT_VAL_ASSO_ATTR_ID';
  FND_MESSAGE.SET_NAME('EGO',G_MESSAGE_NAME);
  G_MESSAGE_TEXT := fnd_message.get;

  INSERT INTO mtl_interface_errors(
              transaction_id,
              unique_id,
              organization_id,
              column_name,
              table_name,
              message_name,
              error_message,
              BO_IDENTIFIER,
              ENTITY_IDENTIFIER,
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
              'EGO_TRANS_ATTRS_VERS_INTF',
              G_MESSAGE_NAME,
              G_MESSAGE_TEXT,
              G_BO_IDENTIFIER,
              G_ENTITY_IDENTIFIER,
              NVL(last_update_date,SYSDATE),
              NVL(last_updated_by,G_USER_ID),
              NVL(creation_date,SYSDATE),
              NVL(created_by,G_USER_ID),
              NVL(last_update_login,G_LOGIN_ID),
              G_REQUEST_ID,
              NVL(program_application_id,G_PROG_APPL_ID),
              NVL(program_id,G_PROGRAM_ID),
              NVL(program_update_date,SYSDATE)
       FROM   EGO_TRANS_ATTRS_VERS_INTF
       WHERE  transaction_type  IN (G_CREATE)
       AND    transaction_id    IS NOT NULL
       AND    process_status    =       G_PROCESS_RECORD
       AND    ((p_set_process_id IS NULL) OR (set_process_id=p_set_process_id))
       AND    ((Association_id IS NOT NULL) OR (Attr_id IS NOT NULL));

  /* Association_id and Attr_id should be NULL if CREATING TA */
  UPDATE EGO_TRANS_ATTRS_VERS_INTF
  SET    process_status       = G_ERROR_RECORD,
         last_updated_by      = G_USER_ID,
         last_update_date     = SYSDATE,
         last_update_login    = G_LOGIN_ID
  WHERE  transaction_type  IN (G_CREATE)
  AND    transaction_id    IS NOT NULL
  AND    process_status    =   G_PROCESS_RECORD
  AND    ((p_set_process_id IS NULL) OR (set_process_id=p_set_process_id))
  AND   ((Association_id IS NOT NULL) OR (Attr_id IS NOT NULL));

-------------------------------------------
  ego_metadata_bulkload_pvt.Write_debug(G_PKG_NAME||'.'||l_proc_name||'->'||'Checking ATTR_NAME,ATTR_DISPLAY_NAME,SEQUENCE Should not be null while CREATE');

  G_MESSAGE_NAME := 'EGO_TA_PK_NULL';
  FND_MESSAGE.SET_NAME('EGO',G_MESSAGE_NAME);
  G_MESSAGE_TEXT := fnd_message.get;
  /* ATTR_NAME,ATTR_DISPLAY_NAME,SEQUENCE Should not be null if CREATE*/
  INSERT INTO mtl_interface_errors(
              transaction_id,
              unique_id,
              organization_id,
              column_name,
              table_name,
              message_name,
              error_message,
              BO_IDENTIFIER,
              ENTITY_IDENTIFIER,
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
              'EGO_TRANS_ATTRS_VERS_INTF',
              G_MESSAGE_NAME,
              G_MESSAGE_TEXT,
              G_BO_IDENTIFIER,
              G_ENTITY_IDENTIFIER,
              NVL(last_update_date,SYSDATE),
              NVL(last_updated_by,G_USER_ID),
              NVL(creation_date,SYSDATE),
              NVL(created_by,G_USER_ID),
              NVL(last_update_login,G_LOGIN_ID),
              G_REQUEST_ID,
              NVL(program_application_id,G_PROG_APPL_ID),
              NVL(program_id,G_PROGRAM_ID),
              NVL(program_update_date,SYSDATE)
       FROM   EGO_TRANS_ATTRS_VERS_INTF
       WHERE  transaction_type  IN (G_CREATE)
       AND    transaction_id    IS NOT NULL
       AND    process_status    =   G_PROCESS_RECORD
       AND    ((p_set_process_id IS NULL) OR (set_process_id=p_set_process_id))
       AND    ((attr_name IS NULL) OR (attr_display_name IS NULL) OR (SEQUENCE IS NULL)) ;

  /* ATTR_NAME,ATTR_DISPLAY_NAME,SEQUENCE Should not be null if CREATE*/
  UPDATE EGO_TRANS_ATTRS_VERS_INTF
  SET    process_status       = G_ERROR_RECORD,
         last_updated_by      = G_USER_ID,
         last_update_date     = SYSDATE,
         last_update_login    = G_LOGIN_ID
  WHERE  transaction_type  IN (G_CREATE)
  AND    transaction_id    IS NOT NULL
  AND    process_status=G_PROCESS_RECORD
  AND    ((p_set_process_id IS NULL) OR (set_process_id=p_set_process_id))
  AND   ((attr_name IS NULL) OR (attr_display_name IS NULL) OR (SEQUENCE IS NULL));

-------------------------------------------------
  ego_metadata_bulkload_pvt.Write_debug(G_PKG_NAME||'.'||l_proc_name||'->'||'Checking if ICC version is NULL while CREATE');

  G_MESSAGE_NAME := 'EGO_ICC_VERSION_NULL';
  FND_MESSAGE.SET_NAME('EGO',G_MESSAGE_NAME);
  G_MESSAGE_TEXT := fnd_message.get;
  /* ICC_VERSION NUMBER should not be NULL in CREATE flow */
  INSERT INTO mtl_interface_errors(
              transaction_id,
              unique_id,
              organization_id,
              column_name,
              table_name,
              message_name,
              error_message,
              BO_IDENTIFIER,
              ENTITY_IDENTIFIER,
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
              'EGO_TRANS_ATTRS_VERS_INTF',
              G_MESSAGE_NAME,
              G_MESSAGE_TEXT,
              G_BO_IDENTIFIER,
              G_ENTITY_IDENTIFIER,
              NVL(last_update_date,SYSDATE),
              NVL(last_updated_by,G_USER_ID),
              NVL(creation_date,SYSDATE),
              NVL(created_by,G_USER_ID),
              NVL(last_update_login,G_LOGIN_ID),
              G_REQUEST_ID,
              NVL(program_application_id,G_PROG_APPL_ID),
              NVL(program_id,G_PROGRAM_ID),
              NVL(program_update_date,SYSDATE)
       FROM   EGO_TRANS_ATTRS_VERS_INTF
       WHERE  transaction_type  IN (G_CREATE)
       AND    transaction_id    IS NOT NULL
       AND    process_status    =       G_PROCESS_RECORD
       AND    ((p_set_process_id IS NULL) OR (set_process_id=p_set_process_id))
       AND    icc_version_number IS NULL;
       --AND    item_catalog_group_id IS NOT NULL;/* bug 9752139 */

  /* ICC_VERSION NUMBER should not be NULL in CREATE flow */
  UPDATE EGO_TRANS_ATTRS_VERS_INTF
  SET    process_status       = G_ERROR_RECORD,
         last_updated_by      = G_USER_ID,
         last_update_date     = SYSDATE,
         last_update_login    = G_LOGIN_ID
  WHERE  transaction_type  IN (G_CREATE)
  AND    transaction_id    IS NOT NULL
  AND    process_status    =   G_PROCESS_RECORD
  AND    ((p_set_process_id IS NULL) OR (set_process_id=p_set_process_id))
  AND    icc_version_number IS NULL;
  --AND    item_catalog_group_id IS NOT NULL; /* bug 9752139 */

-------------------------------------------------
  ego_metadata_bulkload_pvt.Write_debug(G_PKG_NAME||'.'||l_proc_name||'->'||'Defaulting Data Type and Display Flag while CREATE');

 /*Defaulting data_type to'C' if not passed*/
  UPDATE EGO_TRANS_ATTRS_VERS_INTF
  SET    data_type = G_CHAR_DATA_TYPE
  WHERE  transaction_type=G_CREATE
  AND    transaction_id IS NOT NULL
  AND    process_status = G_PROCESS_RECORD
  AND    ((p_set_process_id IS NULL) OR (set_process_id = p_set_process_id))
  AND    data_type IS NULL;

 /*Sets the display_flag as 'T'*/
  UPDATE EGO_TRANS_ATTRS_VERS_INTF
  SET    display_flag = 'T'
  WHERE  transaction_type=G_CREATE
  AND    transaction_id IS NOT NULL
  AND    process_status = G_PROCESS_RECORD
  AND    ((p_set_process_id IS NULL) OR (set_process_id = p_set_process_id));

 /*Sets the Metadata_level as 'ICC'*/
  UPDATE EGO_TRANS_ATTRS_VERS_INTF
  SET    Metadata_level = 'ICC'
  WHERE  transaction_type=G_CREATE
  AND    transaction_id IS NOT NULL
  AND    process_status = G_PROCESS_RECORD
  AND    ((p_set_process_id IS NULL) OR (set_process_id = p_set_process_id));

   /*Assigning icc_version_no as 0 if not provided in update and delete*/
  UPDATE EGO_TRANS_ATTRS_VERS_INTF
  SET    icc_version_number = 0
  WHERE  transaction_type IN (G_UPDATE,G_DELETE)
  AND    transaction_id IS NOT NULL
  AND    process_status = G_PROCESS_RECORD
  AND    ((p_set_process_id IS NULL) OR (set_process_id = p_set_process_id))
  AND    icc_version_number IS NULL;


-------------------------------------------------
  ego_metadata_bulkload_pvt.Write_debug(G_PKG_NAME||'.'||l_proc_name||'->'||'Icc_Version_Number greater than zero not allowed while UPDATE and DELETE');

  G_MESSAGE_NAME := 'EGO_VER_GR_ZERO';
  FND_MESSAGE.SET_NAME('EGO',G_MESSAGE_NAME);
  G_MESSAGE_TEXT := fnd_message.get;
  /* Icc_Version_Number greater than zero not allowed while UPDATE and DELETE*/
  INSERT INTO mtl_interface_errors(
              transaction_id,
              unique_id,
              organization_id,
              column_name,
              table_name,
              message_name,
              error_message,
              BO_IDENTIFIER,
              ENTITY_IDENTIFIER,
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
              'EGO_TRANS_ATTRS_VERS_INTF',
              G_MESSAGE_NAME,
              G_MESSAGE_TEXT,
              G_BO_IDENTIFIER,
              G_ENTITY_IDENTIFIER,
              NVL(last_update_date,SYSDATE),
              NVL(last_updated_by,G_USER_ID),
              NVL(creation_date,SYSDATE),
              NVL(created_by,G_USER_ID),
              NVL(last_update_login,G_LOGIN_ID),
              G_REQUEST_ID,
              NVL(program_application_id,G_PROG_APPL_ID),
              NVL(program_id,G_PROGRAM_ID),
              NVL(program_update_date,SYSDATE)
       FROM   EGO_TRANS_ATTRS_VERS_INTF
       WHERE  transaction_type  IN (G_UPDATE,G_DELETE)
       AND    transaction_id    IS NOT NULL
       AND    process_status    =       G_PROCESS_RECORD
       AND    ((p_set_process_id IS NULL) OR (set_process_id=p_set_process_id))
       AND    icc_version_number>0;

  /* Icc_Version_Number greater than zero not allowed while UPDATE and DELETE*/
  UPDATE EGO_TRANS_ATTRS_VERS_INTF
  SET    process_status       = G_ERROR_RECORD,
         last_updated_by      = G_USER_ID,
         last_update_date     = SYSDATE,
         last_update_login    = G_LOGIN_ID
  WHERE  transaction_type  IN (G_UPDATE,G_DELETE)
  AND    transaction_id    IS NOT NULL
  AND    process_status=G_PROCESS_RECORD
  AND    ((p_set_process_id IS NULL) OR (set_process_id=p_set_process_id))
  AND   Nvl(icc_version_number,0)>0;

  -------------------------------------------------
  ego_metadata_bulkload_pvt.Write_debug(G_PKG_NAME||'.'||l_proc_name||'->'||'Association_id and attr_id should not be null for DELETE');

  G_MESSAGE_NAME := 'EGO_ASSO_ATTR_NULL_DEL';
  FND_MESSAGE.SET_NAME('EGO',G_MESSAGE_NAME);
  G_MESSAGE_TEXT := fnd_message.get;
  /*Association_id and attr_id should not be null for DELETE*/
  INSERT INTO mtl_interface_errors(
              transaction_id,
              unique_id,
              organization_id,
              column_name,
              table_name,
              message_name,
              error_message,
              BO_IDENTIFIER,
              ENTITY_IDENTIFIER,
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
              'EGO_TRANS_ATTRS_VERS_INTF',
              G_MESSAGE_NAME,
              G_MESSAGE_TEXT,
              G_BO_IDENTIFIER,
              G_ENTITY_IDENTIFIER,
              NVL(last_update_date,SYSDATE),
              NVL(last_updated_by,G_USER_ID),
              NVL(creation_date,SYSDATE),
              NVL(created_by,G_USER_ID),
              NVL(last_update_login,G_LOGIN_ID),
              G_REQUEST_ID,
              NVL(program_application_id,G_PROG_APPL_ID),
              NVL(program_id,G_PROGRAM_ID),
              NVL(program_update_date,SYSDATE)
       FROM   EGO_TRANS_ATTRS_VERS_INTF
       WHERE  transaction_type  IN (G_DELETE)
       AND    transaction_id    IS NOT NULL
       AND    process_status    =       G_PROCESS_RECORD
       AND    ((p_set_process_id IS NULL) OR (set_process_id=p_set_process_id))
       AND    ((association_id IS NULL) OR (attr_id IS NULL));

  /*Association_id and attr_id should not be null for DELETE */
  UPDATE EGO_TRANS_ATTRS_VERS_INTF
  SET    process_status       = G_ERROR_RECORD,
         last_updated_by      = G_USER_ID,
         last_update_date     = SYSDATE,
         last_update_login    = G_LOGIN_ID
  WHERE  transaction_type  IN (G_DELETE)
  AND    transaction_id    IS NOT NULL
  AND    process_status    =   G_PROCESS_RECORD
  AND    ((p_set_process_id IS NULL) OR (set_process_id=p_set_process_id))
  AND   ((association_id IS NULL) OR (attr_id IS NULL));

  ego_metadata_bulkload_pvt.Write_debug(G_PKG_NAME||'.'||l_proc_name||'->'||'End Bulk_Validate_Trans_Attrs ');
EXCEPTION
  WHEN OTHERS THEN
  ego_metadata_bulkload_pvt.Write_debug(G_PKG_NAME||'.'||l_proc_name||'->'||'Exception When Others Bulk_Validate_Trans_Attrs ');
END Bulk_Validate_Trans_Attrs;

--================= Bulk_Validate_Trans_Attrs_ICC ========----

PROCEDURE Bulk_Validate_Trans_Attrs_ICC (
        p_set_process_id          IN         NUMBER,
        p_item_catalog_group_id   IN         NUMBER,
        p_item_catalog_group_name IN         VARCHAR2)
IS
l_proc_name           VARCHAR2(200) := 'Bulk_Validate_Trans_Attrs_ICC';
BEGIN

  ego_metadata_bulkload_pvt.Write_debug(G_PKG_NAME||'.'||l_proc_name||'->'||'Entering Bulk_Validate_Trans_Attrs_ICC');
  ego_metadata_bulkload_pvt.Write_debug(G_PKG_NAME||'.'||l_proc_name||'->'||'Updating ICC name from ICC id');
  /* ICC name to ICC id conversion */
  UPDATE EGO_TRANS_ATTRS_VERS_INTF ETAVT
  SET item_catalog_group_id = p_item_catalog_group_id
  WHERE  ETAVT.item_catalog_group_name IS NOT NULL
  AND    ETAVT.item_catalog_group_id IS NULL
  AND    ETAVT.process_status = G_PROCESS_RECORD
  AND    ((p_set_process_id IS NULL) OR (set_process_id = p_set_process_id))
  AND     Upper(ETAVT.item_catalog_group_name) =Upper(p_item_catalog_group_name); -- added to make it ICC specific.

 ego_metadata_bulkload_pvt.Write_debug(G_PKG_NAME||'.'||l_proc_name||'->'||' End Bulk_Validate_Trans_Attrs_ICC');

EXCEPTION
  WHEN OTHERS THEN
  ego_metadata_bulkload_pvt.Write_debug(G_PKG_NAME||'.'||l_proc_name||'->'||'Exception Bulk_Validate_Trans_Attrs_ICC');
END Bulk_Validate_Trans_Attrs_ICC;


--================= Value_to_Id ========----

PROCEDURE Value_to_Id(
            p_set_process_id  IN            NUMBER)
IS
l_proc_name           VARCHAR2(200) := 'Value_to_Id';
BEGIN
    ego_metadata_bulkload_pvt.Write_debug(G_PKG_NAME||'.'||l_proc_name||'->'||'Entering Value_to_Id');
  --ego_metadata_bulkload_pvt.Write_debug(G_PKG_NAME||'.'||l_proc_name||'->'||'Converting ICC name to ICC id');
  /* ICC name to ICC id conversion */
  /* NOt Req now are we are doing this in Bulk_Validate_Trans_Attrs_ICC */
  /*
  UPDATE EGO_TRANS_ATTRS_VERS_INTF ETAVT
  SET item_catalog_group_id = (SELECt icc_kfv.item_catalog_group_id
                               FROM   mtl_item_catalog_groups_kfv icc_kfv
                               where Upper(icc_kfv.concatenated_segments) = Upper(ETAVT.item_catalog_group_name)
                               )
  WHERE  ETAVT.item_catalog_group_name IS NOT NULL
  AND    ETAVT.item_catalog_group_id IS NULL
  --AND    ETAVT.transaction_type IN (G_CREATE,G_UPDATE,G_DELETE_G_SYNC)
  AND    ETAVT.process_status = G_PROCESS_RECORD
  AND ((p_set_process_id IS NULL) OR (set_process_id = p_set_process_id));*/

  ego_metadata_bulkload_pvt.Write_debug(G_PKG_NAME||'.'||l_proc_name||'->'||'Converting Value set name to value set id');
  /*Value set name to value set id conversion*/
  UPDATE EGO_TRANS_ATTRS_VERS_INTF ETAVT
  SET value_set_id = ( SELECT flex_value_set_id
                                FROM fnd_flex_value_sets
                                WHERE Upper(flex_value_set_name) = Upper(ETAVT.value_set_name)
                               )
  WHERE  ETAVT.value_set_name IS NOT NULL
  AND    ETAVT.value_set_id IS NULL
  AND    ETAVT.transaction_type IN (G_CREATE,G_UPDATE,G_SYNC)
  AND    ETAVT.process_status = G_PROCESS_RECORD
  AND ((p_set_process_id IS NULL) OR (set_process_id = p_set_process_id));

  ego_metadata_bulkload_pvt.Write_debug(G_PKG_NAME||'.'||l_proc_name||'->'||'Converting Attr_Name to Attr_id');
  /* Attr_Name to Attr_id conversion */
  UPDATE EGO_TRANS_ATTRS_VERS_INTF ETAVT
  SET (attr_id/*,attr_display_name,sequence*/) = ( SELECT attr_id/*,attr_display_name,sequence*/
                  FROM ego_trans_attr_vers_b
                  WHERE attr_id IN ( SELECT efdcue.attr_id
                                     FROM   fnd_descr_flex_column_usages fdfcu,
                                            ego_fnd_df_col_usgs_ext efdcue
                                     WHERE  fdfcu.application_id = efdcue.application_id
                                     AND fdfcu.descriptive_flexfield_name = efdcue.descriptive_flexfield_name
                                     AND fdfcu.descriptive_flex_context_code = efdcue.descriptive_flex_context_code
                                     AND fdfcu.application_column_name = efdcue.application_column_name
                                     AND fdfcu.application_id = G_APPLICATION_ID
                                     AND fdfcu.descriptive_flexfield_name = 'EGO_ITEM_TRANS_ATTR_GROUP'
                                     AND fdfcu.descriptive_flex_context_code IN (SELECT attr_group_name
                                                                                 FROM EGO_OBJ_ATTR_GRP_ASSOCS_V
                                                                                 WHERE association_id in (SELECT association_id
                                                                                                          FROM EGO_OBJ_AG_ASSOCS_B
                                                                                                          WHERE classification_code=ETAVT.item_catalog_group_id)
                                                                                 AND ATTR_GROUP_TYPE= 'EGO_ITEM_TRANS_ATTR_GROUP'
                                                                                 )
                                     AND Upper(fdfcu.end_user_column_name) = Upper(ETAVT.attr_name)
                                   )
                  AND item_catalog_group_id=ETAVT.item_catalog_group_id
                  AND icc_version_number=0 -- we only allow update on draft
                )
  WHERE  ETAVT.attr_name IS NOT NULL
  AND    ETAVT.attr_id IS NULL
  AND    ETAVT.transaction_type IN (G_CREATE,G_UPDATE,G_DELETE,G_SYNC)
  AND    ETAVT.process_status = G_PROCESS_RECORD
  AND    ((p_set_process_id IS NULL) OR (set_process_id = p_set_process_id));


  ego_metadata_bulkload_pvt.Write_debug(G_PKG_NAME||'.'||l_proc_name||'->'||'Converting attr display name to attr_id ');
  /*attr display name to attr_id conversion*/
  UPDATE EGO_TRANS_ATTRS_VERS_INTF ETAVT
  SET    attr_id = ( SELECT attr_id
                     FROM EGO_TRANS_ATTR_VERS_B
                     WHERE Upper(attr_display_name) = Upper(ETAVT.attr_display_name)
                     AND item_catalog_group_id=ETAVT.item_catalog_group_id
                     AND icc_version_number=0
                   )
  WHERE  ETAVT.attr_display_name IS NOT NULL
  AND    ETAVT.attr_id IS NULL
  AND    ETAVT.transaction_type IN (G_CREATE,G_UPDATE,G_DELETE,G_SYNC)
  AND    ETAVT.process_status = G_PROCESS_RECORD
  AND    ((p_set_process_id IS NULL) OR (set_process_id = p_set_process_id));

  ego_metadata_bulkload_pvt.Write_debug(G_PKG_NAME||'.'||l_proc_name||'->'||'Converting associaton_id from icc_id,attr_id ');
  /* associaton_id from icc_id */
  UPDATE EGO_TRANS_ATTRS_VERS_INTF ETAVT
  SET    association_id = ( SELECT association_id
                            FROM EGO_TRANS_ATTR_VERS_B
                            WHERE attr_id= ETAVT.attr_id
                            AND   item_catalog_group_id=ETAVT.item_catalog_group_id
                            AND icc_version_number=0
                          )
  WHERE  ETAVT.attr_id IS NOT NULL
  AND    ETAVT.item_catalog_group_id IS NOT NULL
  AND    ETAVT.association_id IS NULL
  AND    ETAVT.icc_version_number=0
  AND    ETAVT.transaction_type IN (G_UPDATE,G_DELETE,G_SYNC)
  AND    ETAVT.process_status = G_PROCESS_RECORD
  AND    ((p_set_process_id IS NULL) OR (set_process_id = p_set_process_id));

  ego_metadata_bulkload_pvt.Write_debug(G_PKG_NAME||'.'||l_proc_name||'->'||'End Value_to_Id');
EXCEPTION
  WHEN OTHERS THEN
  ego_metadata_bulkload_pvt.Write_debug(G_PKG_NAME||'.'||l_proc_name||'->'||'Exception Value_to_Id');
END Value_to_Id;

--=================Load_Trans_Attrs_recs ========

PROCEDURE Load_Trans_Attrs_recs(
           p_set_process_id          IN            NUMBER,
           p_item_catalog_group_id   IN            NUMBER,
           p_icc_version_number_intf IN            NUMBER,
           p_icc_version_number_act  IN            NUMBER,
           x_ta_intf_tbl             IN OUT NOCOPY TA_Intf_Tbl,
           x_return_status           OUT    NOCOPY VARCHAR2,
           x_return_msg              OUT    NOCOPY VARCHAR2)
IS
   CURSOR c_ta IS
      SELECT *
      FROM ego_trans_attrs_vers_intf
      WHERE ((p_set_process_id IS NULL) OR (set_process_id = p_set_process_id))
      AND transaction_id IS NOT NULL
      AND process_status=G_PROCESS_RECORD
      AND item_catalog_group_id=p_item_catalog_group_id /* for integration with version*/
      AND icc_version_number= p_icc_version_number_intf
      ORDER BY transaction_type,icc_version_number;

      l_proc_name VARCHAR2(30):= 'Load_Trans_Attrs_recs';

BEGIN
  ego_metadata_bulkload_pvt.Write_debug(G_PKG_NAME||'.'||l_proc_name||'->'||'Entering Load_Trans_Attrs_recs');

  OPEN c_ta;
      FETCH c_ta BULK COLLECT INTO x_ta_intf_tbl; --LIMIT 2000;
  CLOSE c_ta;
  ego_metadata_bulkload_pvt.Write_debug(G_PKG_NAME||'.'||l_proc_name||'->'||'End Load_Trans_Attrs_recs.No of rec in intf pl-sql tbl :'||x_ta_intf_tbl.count );

EXCEPTION
  WHEN OTHERS THEN
    x_return_status:= G_RET_STS_UNEXP_ERROR;
    x_return_msg:= G_PKG_NAME||'.'||l_proc_name||'.'||SQLERRM;
    ego_metadata_bulkload_pvt.Write_debug(G_PKG_NAME||'.'||l_proc_name||'->'||'Exception when Others in  Load_Trans_Attrs_recs');
END Load_Trans_Attrs_recs;

--=================convert_intf_rec_to_api_rec========

PROCEDURE convert_intf_rec_to_api_rec (
           p_ta_intf_tbl      IN         TA_Intf_Tbl,
           x_ego_ta_tbl       OUT NOCOPY ego_tran_attr_tbl)
IS
l_proc_name           VARCHAR2(200) := 'convert_intf_rec_to_api_rec';
BEGIN
  ego_metadata_bulkload_pvt.Write_debug(G_PKG_NAME||'.'||l_proc_name||'->'||'Entering convert_intf_rec_to_api_rec');
  ego_metadata_bulkload_pvt.Write_debug(G_PKG_NAME||'.'||l_proc_name||'->'||'Converting interface rec to prod rec type');
  -- Initializing table type
  x_ego_ta_tbl:=   EGO_TRAN_ATTR_TBL(NULL);

  FOR i IN p_ta_intf_tbl.first..p_ta_intf_tbl.last LOOP

  --x_ego_ta_tbl.extend;
  x_ego_ta_tbl(1):= ego_tran_attr_rec(  p_ta_intf_tbl(i).Association_Id,
                                        p_ta_intf_tbl(i).Attr_Id,
                                        p_ta_intf_tbl(i).icc_version_number,
                                        p_ta_intf_tbl(i).revision_id,
                                        p_ta_intf_tbl(i).SEQUENCE,
                                        p_ta_intf_tbl(i).Value_Set_Id,
                                        p_ta_intf_tbl(i).Uom_Class,
                                        p_ta_intf_tbl(i).default_value,
                                        p_ta_intf_tbl(i).Rejected_Value,
                                        p_ta_intf_tbl(i).Required_Flag,
                                        p_ta_intf_tbl(i).Readonly_Flag,
                                        p_ta_intf_tbl(i).Hidden_Flag,
                                        p_ta_intf_tbl(i).Searchable_Flag,
                                        p_ta_intf_tbl(i).Check_Eligibility,
                                        p_ta_intf_tbl(i).Inventory_Item_Id,
                                        p_ta_intf_tbl(i).Organization_Id,
                                        p_ta_intf_tbl(i).Metadata_Level,
                                        p_ta_intf_tbl(i).Created_By,
                                        p_ta_intf_tbl(i).Creation_Date,
                                        p_ta_intf_tbl(i).Last_Updated_By,
                                        p_ta_intf_tbl(i).Last_Update_Date,
                                        p_ta_intf_tbl(i).Last_Update_Login,
                                        p_ta_intf_tbl(i).Program_Application_Id,
                                        p_ta_intf_tbl(i).Program_Id,
                                        p_ta_intf_tbl(i).Program_Update_Date,
                                        p_ta_intf_tbl(i).Request_Id,
                                        p_ta_intf_tbl(i).Item_Catalog_Group_Id,
                                        p_ta_intf_tbl(i).Attr_Name,
                                        p_ta_intf_tbl(i).Attr_Display_Name,
                                        p_ta_intf_tbl(i).Data_Type,
                                        p_ta_intf_tbl(i).display_flag,
                                        p_ta_intf_tbl(i).Value_Set_Name
                                        );

  END LOOP;
  ego_metadata_bulkload_pvt.Write_debug(G_PKG_NAME||'.'||l_proc_name||'->'||'End convert_intf_rec_to_api_rec');
EXCEPTION
  WHEN OTHERS THEN
  ego_metadata_bulkload_pvt.Write_debug(G_PKG_NAME||'.'||l_proc_name||'->'||'Exception when Others in convert_intf_rec_to_api_rec');
END convert_intf_rec_to_api_rec;

--=================Process_Trans_Attrs  ========
PROCEDURE Process_Trans_Attrs (
           p_api_version             IN                NUMBER,
           p_ta_intf_tbl             IN OUT NOCOPY     TA_Intf_Tbl,
           p_item_catalog_group_id   IN                NUMBER,
           p_icc_version_number_intf IN                NUMBER,
           p_icc_version_number_act  IN                NUMBER,
           x_return_status           OUT NOCOPY        VARCHAR2,
           x_return_msg              OUT NOCOPY        VARCHAR2)
IS
 l_ta_intf_rec ego_trans_attrs_vers_intf%ROWTYPE;
 l_ta_intf_tbl TA_Intf_Tbl;
 l_return_status VARCHAR2(1);
 l_proc_name     VARCHAR2(200):= 'Process_Trans_Attrs';
BEGIN
   ego_metadata_bulkload_pvt.Write_debug(G_PKG_NAME||'.'||l_proc_name||'->'||'Entering Process_Trans_Attrs');

   /* when coming from Public API*/
   IF G_FLOW_TYPE=G_EGO_MD_API THEN
     ego_metadata_bulkload_pvt.Write_debug(G_PKG_NAME||'.'||l_proc_name||'->'||'In to API Flow');
     l_ta_intf_tbl:= p_ta_intf_tbl;

     ego_metadata_bulkload_pvt.Write_debug(G_PKG_NAME||'.'||l_proc_name||'->'||'Calling Construct_TA');
     /* same as initialize and value_to_id */
     Construct_Trans_Attrs(p_api_version=>p_api_version,
                    p_ta_intf_tbl     => l_ta_intf_tbl,
                    x_return_status   => x_return_status,
                    x_return_msg      => x_return_msg);

     ego_metadata_bulkload_pvt.Write_debug(G_PKG_NAME||'.'||l_proc_name||'->'||'Calling Validate_TA');
     /* same as bulk validation*/
     Validate_Trans_Attrs(p_api_version => p_api_version,
                  p_ta_intf_tbl       => l_ta_intf_tbl,
                  x_return_status     => x_return_status,
                  x_return_msg        => x_return_msg);

     p_ta_intf_tbl:= l_ta_intf_tbl;
   END IF;
   ego_metadata_bulkload_pvt.Write_debug(G_PKG_NAME||'.'||l_proc_name||'->'||'Loop for Transact_TA record by record');
   -- loop to transact record by record
   FOR i IN p_ta_intf_tbl.first..p_ta_intf_tbl.last LOOP
     /* Assigning intf record to process*/
     l_ta_intf_rec:=p_ta_intf_tbl(i);
       -- changing icc_version_number to actual as passed
       IF l_ta_intf_rec.TRANSACTION_type=G_CREATE THEN
          l_ta_intf_rec.icc_version_number:=p_icc_version_number_act;
       END IF ;

       Transact_Trans_Attrs(p_api_version     =>p_api_version,
                   p_ta_intf_rec     =>l_ta_intf_rec,
                   x_return_status   =>x_return_status,
                   x_return_msg      =>x_return_msg);
       -- changing icc_version_number back to intf so no change in interface table
       IF l_ta_intf_rec.TRANSACTION_type=G_CREATE THEN
          l_ta_intf_rec.icc_version_number:=p_icc_version_number_intf;
       END IF ;

     /*Assiging back to table after transact_ta */
     p_ta_intf_tbl(i):= l_ta_intf_rec;
	   G_MESSAGE_TEXT:=x_return_msg;

     IF (Nvl(x_return_status,G_RET_STS_SUCCESS)= G_RET_STS_ERROR)
              OR (p_ta_intf_tbl(i).process_status=G_ERROR_RECORD) THEN
         -- LOG the error in interface table
         G_TOKEN_TBL(1).Token_Name   :=  'Entity_Name';
         G_TOKEN_TBL(1).Token_Value  :=  G_ENTITY_IDENTIFIER;
         G_TOKEN_TBL(2).Token_Name   :=  'Transaction_Type';
         G_TOKEN_TBL(2).Token_Value  :=  p_ta_intf_tbl(i).transaction_type;
         G_TOKEN_TBL(3).Token_Name   :=  'Package_Name';
         G_TOKEN_TBL(3).Token_Value  :=  'EGO_TRANSACTION_ATTRS_PVT';
         G_TOKEN_TBL(4).Token_Name   :=  'Proc_Name';
         SELECT Decode(p_ta_intf_tbl(i).transaction_type,'CREATE','Create_Transaction_Attribute',
                                                         'UPDATE','Update_Transaction_Attribute',
                                                         'DELETE','Delete_Transaction_Attribute') INTO G_TOKEN_TBL(4).Token_Value
         FROM dual;

         /* added p_addto_fnd_stack because in case of error ICC API will rollback the TA
            so messages will also get rollback. So if it get added to stack we can print and insert
            to interface_error table again*/

         Error_Handler.Add_Error_Message
             (
              p_message_name   =>  'EGO_ENTITY_API_FAILED'
             ,p_application_id =>  G_APP_NAME
             ,p_message_type   =>  G_RET_STS_ERROR
             ,p_entity_code    =>  G_Entity_Identifier
             ,p_row_identifier =>  p_ta_intf_tbl(i).transaction_id
             ,p_table_name     =>  G_Table_Name
             ,p_token_tbl      =>  G_TOKEN_TBL
	     ,p_addto_fnd_stack=> 'Y'
             );

         G_TOKEN_TBL.DELETE;

         RETURN;
     END IF ;
   END LOOP;
  /* if record successful then update the intf table with success(7)*/
  IF G_FLOW_TYPE=G_EGO_MD_INTF THEN
     Update_Intf_Trans_Attrs(p_ta_intf_tbl    => p_ta_intf_tbl,
                             x_return_status  => l_return_status,
                             x_return_msg     => x_return_msg);
  END IF;
  ego_metadata_bulkload_pvt.Write_debug(G_PKG_NAME||'.'||l_proc_name||'->'||'End Process_Trans_Attrs');
EXCEPTION
  WHEN OTHERS THEN
  x_return_status:= G_RET_STS_UNEXP_ERROR;
  x_return_msg:= G_PKG_NAME||'.'||l_proc_name||'.'||SQLERRM;
  ego_metadata_bulkload_pvt.Write_debug(G_PKG_NAME||'.'||l_proc_name||'->'||'Exception when others Process_Trans_Attrs');

END Process_Trans_Attrs;

--=================Construct_Trans_Attrs ========
/* This is same as initialize and value_to_id during interface flow */
PROCEDURE Construct_Trans_Attrs(
           p_api_version      IN         NUMBER,
           p_ta_intf_tbl      IN OUT NOCOPY  TA_Intf_Tbl,
           x_return_status    OUT NOCOPY VARCHAR2,
           x_return_msg       OUT NOCOPY VARCHAR2)
IS
l_proc_name VARCHAR2(200):='Construct_Trans_Attrs';
BEGIN
  ego_metadata_bulkload_pvt.Write_debug(G_PKG_NAME||'.'||l_proc_name||'->'||'Entering Construct_Trans_Attrs');

FOR i IN p_ta_intf_tbl.first..p_ta_intf_tbl.last LOOP

 IF (p_ta_intf_tbl(i).process_status = G_PROCESS_RECORD) THEN


     /* setting G_APPLICATION_ID*/
     SELECT application_id INTO   G_APPLICATION_ID
     FROM   fnd_application
     WHERE  application_short_name=G_APP_NAME;

    /*Sets the transaction_id*/
     SELECT mtl_system_items_interface_s.NEXTVAL,Upper(p_ta_intf_tbl(i).transaction_type)
     INTO   p_ta_intf_tbl(i).transaction_id,p_ta_intf_tbl(i).transaction_type
     FROM   dual;

     /* if not a valid transaction type*/
     IF p_ta_intf_tbl(i).transaction_type NOT IN (G_CREATE,G_UPDATE,G_DELETE,G_SYNC) THEN
        ego_metadata_bulkload_pvt.Write_debug(G_PKG_NAME||'.'||l_proc_name||'->'||'Transaction Type  '
                                                      ||p_ta_intf_tbl(i).transaction_type
                                                      ||'Is not Valid');

        p_ta_intf_tbl(i).process_status := G_ERROR_RECORD;
        x_return_status := G_RET_STS_ERROR;
        /*error_handler.Add_error_message(p_message_name => 'EGO_ICC_INVALID',p_application_id => 'EGO',
                                                p_token_tbl => g_token_table,p_message_type => g_ret_sts_error,
                                                p_row_identifier => P_ag_tbl(i).transaction_id,
                                                p_entity_code => g_entity_ag,p_table_name => g_entity_ag_tab);*/
     END IF;

     ego_metadata_bulkload_pvt.Write_debug(G_PKG_NAME||'.'||l_proc_name||'->'||'Icc_name to Icc_id conversion');

     /* Getting ICC_id from icc_name */
     IF  (p_ta_intf_tbl(i).transaction_type IN (G_CREATE,G_UPDATE,G_DELETE,G_SYNC)
            AND p_ta_intf_tbl(i).item_catalog_group_id IS NULL
            AND p_ta_intf_tbl(i).item_catalog_group_name IS NOT  NULL) THEN

          BEGIN
             SELECt icc_kfv.item_catalog_group_id INTO p_ta_intf_tbl(i).item_catalog_group_id
             FROM   mtl_item_catalog_groups_kfv icc_kfv
             WHERE  Upper(icc_kfv.concatenated_segments) = Upper(p_ta_intf_tbl(i).item_catalog_group_name);
          EXCEPTION
            WHEN no_data_found THEN
                ego_metadata_bulkload_pvt.Write_debug(G_PKG_NAME||'.'||l_proc_name||'->'||'ICC '
                                                      ||p_ta_intf_tbl(i).item_catalog_group_name
                                                      ||'does not exist in the system');

                p_ta_intf_tbl(i).process_status := G_ERROR_RECORD;
                x_return_status := G_RET_STS_ERROR;
                /*error_handler.Add_error_message(p_message_name => 'EGO_ICC_INVALID',p_application_id => 'EGO',
                                                p_token_tbl => g_token_table,p_message_type => g_ret_sts_error,
                                                p_row_identifier => P_ag_tbl(i).transaction_id,
                                                p_entity_code => g_entity_ag,p_table_name => g_entity_ag_tab);*/
            WHEN OTHERS THEN
              ego_metadata_bulkload_pvt.Write_debug(G_PKG_NAME||'.'||l_proc_name||'->'||'ICC_NAME to ICC_ID Exception when others');
              x_return_status := G_RET_STS_UNEXP_ERROR;
          END;
     END IF;/*icc_name to icc_id */

     ego_metadata_bulkload_pvt.Write_debug(G_PKG_NAME||'.'||l_proc_name||'->'||'Value_set_id from Value_set_name');
     /* Getting value_set_id from value_set_name */
     IF  (p_ta_intf_tbl(i).transaction_type IN (G_CREATE,G_UPDATE,G_DELETE,G_SYNC)
            AND p_ta_intf_tbl(i).value_set_id IS  NULL
            AND p_ta_intf_tbl(i).value_set_name IS NOT NULL) THEN
          BEGIN
             SELECT flex_value_set_id INTO p_ta_intf_tbl(i).value_set_id
             FROM fnd_flex_value_sets
             WHERE Upper(flex_value_set_name) = Upper(p_ta_intf_tbl(i).value_set_name);
          EXCEPTION
            WHEN no_data_found THEN
                ego_metadata_bulkload_pvt.Write_debug(G_PKG_NAME||'.'||l_proc_name||'->'||'Value Set '
                                                      ||p_ta_intf_tbl(i).value_set_name
                                                      ||'does not exist in the system');

                p_ta_intf_tbl(i).process_status := G_ERROR_RECORD;
                x_return_status := G_RET_STS_ERROR;
                /*error_handler.Add_error_message(p_message_name => 'EGO_ICC_INVALID',p_application_id => 'EGO',
                                                p_token_tbl => g_token_table,p_message_type => g_ret_sts_error,
                                                p_row_identifier => P_ag_tbl(i).transaction_id,
                                                p_entity_code => g_entity_ag,p_table_name => g_entity_ag_tab);*/
            WHEN OTHERS THEN
              ego_metadata_bulkload_pvt.Write_debug(G_PKG_NAME||'.'||l_proc_name||'->'||'Value Set Name to ID Exception when others');
              x_return_status := G_RET_STS_UNEXP_ERROR;
          END;
     END IF;/*value_set_name to value_set_id */

     ego_metadata_bulkload_pvt.Write_debug(G_PKG_NAME||'.'||l_proc_name||'->'||'Getting Attr_id from Attr_name');
     /* Getting Attr_id from Attr_name */
     IF  (p_ta_intf_tbl(i).transaction_type IN (G_CREATE,G_UPDATE,G_DELETE,G_SYNC)
            AND p_ta_intf_tbl(i).attr_id IS  NULL
            AND p_ta_intf_tbl(i).attr_name IS NOT NULL) THEN

			BEGIN
             SELECT attr_id  INTO p_ta_intf_tbl(i).attr_id
             FROM EGO_TRANS_ATTR_VERS_B
             WHERE attr_id IN ( SELECT efdcue.attr_id
                                FROM   fnd_descr_flex_column_usages fdfcu,
                                       ego_fnd_df_col_usgs_ext efdcue
                                 WHERE  fdfcu.application_id = efdcue.application_id
                                 AND fdfcu.descriptive_flexfield_name = efdcue.descriptive_flexfield_name
                                 AND fdfcu.descriptive_flex_context_code = efdcue.descriptive_flex_context_code
                                 AND fdfcu.application_column_name = efdcue.application_column_name
                                 AND fdfcu.application_id = G_APPLICATION_ID
                                 AND fdfcu.descriptive_flexfield_name = 'EGO_ITEM_TRANS_ATTR_GROUP'
                                 AND fdfcu.descriptive_flex_context_code IN (SELECT attr_group_name
                                                                             FROM EGO_OBJ_ATTR_GRP_ASSOCS_V
                                                                             WHERE association_id in (SELECT association_id
                                                                                                      FROM EGO_OBJ_AG_ASSOCS_B
                                                                                                      WHERE classification_code=p_ta_intf_tbl(i).item_catalog_group_id)
                                                                             AND ATTR_GROUP_TYPE= 'EGO_ITEM_TRANS_ATTR_GROUP'
                                                                                 )
                                     AND Upper(fdfcu.end_user_column_name) = Upper(p_ta_intf_tbl(i).attr_name)
                                   )
             AND item_catalog_group_id=p_ta_intf_tbl(i).item_catalog_group_id
             AND icc_version_number=0; -- we only allow update on draft;

          EXCEPTION
            WHEN no_data_found THEN
              IF (p_ta_intf_tbl(i).transaction_type = G_SYNC) THEN
                  p_ta_intf_tbl(i).transaction_type := G_CREATE;
              ELSE
                ego_metadata_bulkload_pvt.Write_debug(G_PKG_NAME||'.'||l_proc_name||'->'||'Attribute Name'
                                                      ||p_ta_intf_tbl(i).attr_name
                                                      ||'does not exist in the system');

                p_ta_intf_tbl(i).process_status := G_ERROR_RECORD;
                x_return_status := G_RET_STS_ERROR;
                /*error_handler.Add_error_message(p_message_name => 'EGO_ICC_INVALID',p_application_id => 'EGO',
                                                p_token_tbl => g_token_table,p_message_type => g_ret_sts_error,
                                                p_row_identifier => P_ag_tbl(i).transaction_id,
                                                p_entity_code => g_entity_ag,p_table_name => g_entity_ag_tab);*/
              END IF;
            WHEN OTHERS THEN
              ego_metadata_bulkload_pvt.Write_debug(G_PKG_NAME||'.'||l_proc_name||'->'||'Attribute Name to ID Exception when others');
              x_return_status := G_RET_STS_UNEXP_ERROR;
          END;
     END IF; /*attr_name to attr_id */

     ego_metadata_bulkload_pvt.Write_debug(G_PKG_NAME||'.'||l_proc_name||'->'||'Getting Attr_id from Attr_Display_name');
     /* Getting Attr_id from Attr_Display_name */
     IF  (p_ta_intf_tbl(i).transaction_type IN (G_CREATE,G_UPDATE,G_DELETE,G_SYNC)
            AND p_ta_intf_tbl(i).attr_id IS NULL
            AND p_ta_intf_tbl(i).attr_display_name IS NOT NULL
            AND p_ta_intf_tbl(i).attr_name IS NULL)/* extra condition becoz if attr_name is given then i could have*/
            THEN                                  /* resolved sync and get the attr_id in previour attr_name to attr_id*/

          BEGIN
             SELECT attr_id INTO p_ta_intf_tbl(i).attr_id
             FROM EGO_TRANS_ATTR_VERS_B
             WHERE Upper(attr_display_name) = Upper(p_ta_intf_tbl(i).attr_display_name)
             AND item_catalog_group_id=p_ta_intf_tbl(i).item_catalog_group_id
             AND icc_version_number=0;


          EXCEPTION
            WHEN no_data_found THEN
              IF (p_ta_intf_tbl(i).transaction_type = G_SYNC) THEN
                  p_ta_intf_tbl(i).transaction_type := G_CREATE;
              ELSE
                ego_metadata_bulkload_pvt.Write_debug(G_PKG_NAME||'.'||l_proc_name||'->'||'Attribute Display Name'
                                                      ||p_ta_intf_tbl(i).attr_display_name
                                                      ||'does not exist in the system');

                p_ta_intf_tbl(i).process_status := G_ERROR_RECORD;
                x_return_status := G_RET_STS_ERROR;
                /*error_handler.Add_error_message(p_message_name => 'EGO_ICC_INVALID',p_application_id => 'EGO',
                                                p_token_tbl => g_token_table,p_message_type => g_ret_sts_error,
                                                p_row_identifier => P_ag_tbl(i).transaction_id,
                                                p_entity_code => g_entity_ag,p_table_name => g_entity_ag_tab);*/
              END IF;
            WHEN OTHERS THEN
              ego_metadata_bulkload_pvt.Write_debug(G_PKG_NAME||'.'||l_proc_name||'->'||'Attribute Name to ID Exception when others');
              x_return_status := G_RET_STS_UNEXP_ERROR;
          END;
     END IF; /*attr_display_name to attr_id */

     ego_metadata_bulkload_pvt.Write_debug(G_PKG_NAME||'.'||l_proc_name||'->'||'Getting associaton_id from icc_id and attr_id');
     /* Getting associaton_id from icc_id and attr_id, need this for update and delete*/
     IF  (p_ta_intf_tbl(i).transaction_type IN (G_UPDATE,G_DELETE,G_SYNC)
            AND p_ta_intf_tbl(i).attr_id IS NOT NULL
            AND p_ta_intf_tbl(i).item_catalog_group_id IS NOT NULL
            AND p_ta_intf_tbl(i).association_id is NULL) THEN

          BEGIN
             SELECT association_id INTO p_ta_intf_tbl(i).association_id
             FROM   EGO_TRANS_ATTR_VERS_B
             WHERE  attr_id=  p_ta_intf_tbl(i).attr_id
             AND    item_catalog_group_id= p_ta_intf_tbl(i).item_catalog_group_id
             AND    icc_version_number=0;


          EXCEPTION
            WHEN no_data_found THEN
                ego_metadata_bulkload_pvt.Write_debug(G_PKG_NAME||'.'||l_proc_name||'->'||'Not able to get association id frrom '
                                                      ||p_ta_intf_tbl(i).attr_id ||' ' || p_ta_intf_tbl(i).item_catalog_group_id
                                                      ||'Unexpected');

                p_ta_intf_tbl(i).process_status := G_ERROR_RECORD;
                x_return_status := G_RET_STS_ERROR;
                /*error_handler.Add_error_message(p_message_name => 'EGO_ICC_INVALID',p_application_id => 'EGO',
                                                p_token_tbl => g_token_table,p_message_type => g_ret_sts_error,
                                                p_row_identifier => P_ag_tbl(i).transaction_id,
                                                p_entity_code => g_entity_ag,p_table_name => g_entity_ag_tab);*/
            WHEN OTHERS THEN
              ego_metadata_bulkload_pvt.Write_debug(G_PKG_NAME||'.'||l_proc_name||'->'||'Attribute Name to ID Exception when others');
              x_return_status := G_RET_STS_UNEXP_ERROR;
          END;
     END IF; /*association id from attr_id and icc_id */
  END IF;-- process status
END LOOP;
ego_metadata_bulkload_pvt.Write_debug(G_PKG_NAME||'.'||l_proc_name||'->'||'End Construct_Trans_Attrs');

EXCEPTION WHEN OTHERS THEN
  x_return_status:= G_RET_STS_UNEXP_ERROR;
  x_return_msg:= G_PKG_NAME||'.'||l_proc_name||'.'||SQLERRM;
  ego_metadata_bulkload_pvt.Write_debug(G_PKG_NAME||'.'||l_proc_name||'->'||'Exception when others Construct_Trans_Attrs');
END Construct_Trans_Attrs;

--=================Validate_Trans_Attrs ========
 /* This is same as Bulk Validation TA during interface flow */
 PROCEDURE Validate_Trans_Attrs(
           p_api_version      IN         NUMBER,
           p_ta_intf_tbl      IN OUT NOCOPY TA_Intf_Tbl,
           x_return_status    OUT NOCOPY VARCHAR2,
           x_return_msg       OUT NOCOPY VARCHAR2)
IS
l_return_status VARCHAR2(1):=G_RET_STS_SUCCESS;
l_msg_count NUMBER :=G_MISS_NUM;
l_msg_data VARCHAR(2000):=G_MISS_CHAR;
l_proc_name VARCHAR2(200):='Validate_Trans_Attrs';

l_id_exists NUMBER;

BEGIN
  ego_metadata_bulkload_pvt.Write_debug(G_PKG_NAME||'.'||l_proc_name||'->'||'Entering Validate_Trans_Attrs');
  x_return_status  := G_RET_STS_SUCCESS;
  x_return_msg     := G_MISS_CHAR;

FOR i IN p_ta_intf_tbl.first..p_ta_intf_tbl.last LOOP
 IF (p_ta_intf_tbl(i).process_status = G_PROCESS_RECORD
         AND p_ta_intf_tbl(i).TRANSACTION_ID IS NOT NULL
          ) THEN

            ego_metadata_bulkload_pvt.Write_debug(G_PKG_NAME||'.'||l_proc_name||'->'||'ICC_validations');
            /* ICC_validations*/
            IF   p_ta_intf_tbl(i).transaction_type IN (G_CREATE,G_UPDATE,G_DELETE,G_SYNC) THEN
               IF  (p_ta_intf_tbl(i).item_catalog_group_id IS  NULL
                   AND p_ta_intf_tbl(i).item_catalog_group_name IS NULL) THEN /*if both ICC_ID and ICC_NAME is NULL*/
                       ego_metadata_bulkload_pvt.Write_debug(G_PKG_NAME||'.'||l_proc_name||'->'||'ERR : ICC Id and ICC_NAME both NULL ');
                       p_ta_intf_tbl(i).process_status := G_ERROR_RECORD;
                       x_return_status := G_RET_STS_ERROR;
                       /*error_handler.Add_error_message(p_message_name => 'EGO_ICC_INVALID',p_application_id => 'EGO',
                                                          p_token_tbl => g_token_table,p_message_type => g_ret_sts_error,
                                                          p_row_identifier => P_ag_tbl(i).transaction_id,
                                                          p_entity_code => g_entity_ag,p_table_name => g_entity_ag_tab);*/

               ELSIF (p_ta_intf_tbl(i).item_catalog_group_id IS NOT NULL) THEN /* if ICC_ID provided doesn't exists*/

                      BEGIN
                        SELECT item_catalog_group_id INTO l_id_exists
                        FROM mtl_item_catalog_groups micg
                        WHERE micg.ITEM_CATALOG_GROUP_ID=p_ta_intf_tbl(i).item_catalog_group_id;

                      EXCEPTION
                      WHEN no_data_found THEN
                        ego_metadata_bulkload_pvt.Write_debug(G_PKG_NAME||'.'||l_proc_name||'->'||'ICC '
                                                      ||p_ta_intf_tbl(i).item_catalog_group_id
                                                      ||'does not exist in the system');

                        p_ta_intf_tbl(i).process_status := G_ERROR_RECORD;
                        x_return_status := G_RET_STS_ERROR;
                        /*error_handler.Add_error_message(p_message_name => 'EGO_ICC_INVALID',p_application_id => 'EGO',
                                                          p_token_tbl => g_token_table,p_message_type => g_ret_sts_error,
                                                          p_row_identifier => P_ag_tbl(i).transaction_id,
                                                          p_entity_code => g_entity_ag,p_table_name => g_entity_ag_tab);*/
                      WHEN OTHERS THEN
                        ego_metadata_bulkload_pvt.Write_debug(G_PKG_NAME||'.'||l_proc_name||'->'||'ICC_ID provided Exception when others');
                        x_return_status := G_RET_STS_UNEXP_ERROR;
                      END;
               END IF;
            END IF;-- If Transaction_type in ALL

            ego_metadata_bulkload_pvt.Write_debug(G_PKG_NAME||'.'||l_proc_name||'->'||'Value_set_Validations ');
            /* Value_set Validations*/
            IF   p_ta_intf_tbl(i).transaction_type IN (G_CREATE,G_UPDATE,G_SYNC) THEN
               /* if given value_set_id not exists */
               IF (p_ta_intf_tbl(i).value_set_id IS NOT  NULL) THEN
                      BEGIN
                        SELECT flex_value_set_id INTO l_id_exists
                        FROM fnd_flex_value_sets  ffvs
                        WHERE ffvs.flex_value_set_id = p_ta_intf_tbl(i).value_set_id ;

                      EXCEPTION
                      WHEN no_data_found THEN
                        ego_metadata_bulkload_pvt.Write_debug(G_PKG_NAME||'.'||l_proc_name||'->'||'Value Set Id '
                                                      ||p_ta_intf_tbl(i).value_set_id
                                                      ||'does not exist in the system');

                        p_ta_intf_tbl(i).process_status := G_ERROR_RECORD;
                        x_return_status := G_RET_STS_ERROR;
                        /*error_handler.Add_error_message(p_message_name => 'EGO_ICC_INVALID',p_application_id => 'EGO',
                                                          p_token_tbl => g_token_table,p_message_type => g_ret_sts_error,
                                                          p_row_identifier => P_ag_tbl(i).transaction_id,
                                                          p_entity_code => g_entity_ag,p_table_name => g_entity_ag_tab);*/
                      WHEN OTHERS THEN
                        ego_metadata_bulkload_pvt.Write_debug(G_PKG_NAME||'.'||l_proc_name||'->'||'value_Set_id provided Exception when others');
                        x_return_status := G_RET_STS_UNEXP_ERROR;
                      END;
               END IF;
            END IF;-- If Transaction_type in except delete

             ego_metadata_bulkload_pvt.Write_debug(G_PKG_NAME||'.'||l_proc_name||'->'||'attr_id Validations and conversion of sync to create/update ');
            /* attr_id Validations*/
            IF   p_ta_intf_tbl(i).transaction_type IN (G_UPDATE,G_DELETE,G_SYNC) THEN
               /* if given attr_id not exists */
               IF (p_ta_intf_tbl(i).attr_id IS NOT NULL) THEN

                   BEGIN
                        SELECT attr_id INTO l_id_exists
                        FROM EGO_TRANS_ATTR_VERS_B ETAVB
                        WHERE ETAVB.attr_id = p_ta_intf_tbl(i).attr_id
                        AND  item_catalog_group_id=p_ta_intf_tbl(i).item_catalog_group_id
                        AND icc_version_number=0;

                        IF (p_ta_intf_tbl(i).transaction_type = G_SYNC) THEN
                            p_ta_intf_tbl(i).transaction_type := G_UPDATE;
                        END IF;
                           /* assigning defaults required for update*/
                           IF p_ta_intf_tbl(i).attr_display_name IS NOT NULL  THEN
                            BEGIN
                              SELECT attr_name INTO p_ta_intf_tbl(i).attr_name
                              FROM ego_attrs_v  EAV
                              WHERE EAV.attr_id= p_ta_intf_tbl(i).attr_id;
                            END ;
                           END IF;

                           IF p_ta_intf_tbl(i).attr_name IS NOT NULL  THEN
                            BEGIN
                               ego_metadata_bulkload_pvt.Write_debug(G_PKG_NAME||'.'||l_proc_name||'->'||'assining rest of defaults');
                              SELECT nvl(p_ta_intf_tbl(i).uom_class,b.uom_class),nvl(p_ta_intf_tbl(i).default_value,b.default_value),
                                     nvl(p_ta_intf_tbl(i).rejected_value,b.rejected_value),nvl(p_ta_intf_tbl(i).required_flag,b.required_flag),
                                     nvl(p_ta_intf_tbl(i).readonly_flag,b.readonly_flag),nvl(p_ta_intf_tbl(i).hidden_flag,b.hidden_flag),
                                     nvl(p_ta_intf_tbl(i).searchable_flag,b.searchable_flag), nvl(p_ta_intf_tbl(i).check_eligibility,b.check_eligibility),
                                     nvl(p_ta_intf_tbl(i).value_set_id,b.value_set_id), nvl(p_ta_intf_tbl(i).attr_display_name,b.attr_display_name),b.SEQUENCE
                                     INTO
                                     p_ta_intf_tbl(i).uom_class,p_ta_intf_tbl(i).default_value,p_ta_intf_tbl(i).rejected_value,
                                     p_ta_intf_tbl(i).required_flag,p_ta_intf_tbl(i).readonly_flag,p_ta_intf_tbl(i).hidden_flag,
                                     p_ta_intf_tbl(i).searchable_flag, p_ta_intf_tbl(i).check_eligibility,
                                     p_ta_intf_tbl(i).value_set_id,p_ta_intf_tbl(i).attr_display_name,p_ta_intf_tbl(i).SEQUENCE
                             FROM EGO_TRANS_ATTR_VERS_B b
                             WHERE b.item_catalog_group_id=p_ta_intf_tbl(i).item_catalog_group_id
                             AND   b.icc_version_number=0
                             AND   b.attr_id= p_ta_intf_tbl(i).attr_id;

							              END ;
                           END IF;

                   EXCEPTION
                   WHEN no_data_found THEN
                        ego_metadata_bulkload_pvt.Write_debug(G_PKG_NAME||'.'||l_proc_name||'->'||'Attr Id provided '
                                                      ||p_ta_intf_tbl(i).attr_id
                                                      ||'does not exist in the system');

                        p_ta_intf_tbl(i).process_status := G_ERROR_RECORD;
                        x_return_status := G_RET_STS_ERROR;
                        /*error_handler.Add_error_message(p_message_name => 'EGO_ICC_INVALID',p_application_id => 'EGO',
                                                          p_token_tbl => g_token_table,p_message_type => g_ret_sts_error,
                                                          p_row_identifier => P_ag_tbl(i).transaction_id,
                                                          p_entity_code => g_entity_ag,p_table_name => g_entity_ag_tab);*/
                      WHEN OTHERS THEN
                        ego_metadata_bulkload_pvt.Write_debug(G_PKG_NAME||'.'||l_proc_name||'->'||'attr_id provided Exception when others');
                        x_return_status := G_RET_STS_UNEXP_ERROR;

                   END;

               ELSIF (p_ta_intf_tbl(i).attr_id IS NULL AND p_ta_intf_tbl(i).attr_name IS  NULL AND p_ta_intf_tbl(i).attr_display_name IS NULL ) THEN
                     ego_metadata_bulkload_pvt.Write_debug(G_PKG_NAME||'.'||l_proc_name||'->'||'ALL Attr_id, Attr_name and Attr_Display Name cannot be NULL for UPDATE,DEL and SYNC');
                     p_ta_intf_tbl(i).process_status := G_ERROR_RECORD;
                     x_return_status := G_RET_STS_ERROR;
                     /*error_handler.Add_error_message(p_message_name => 'EGO_ICC_INVALID',p_application_id => 'EGO',
                                                          p_token_tbl => g_token_table,p_message_type => g_ret_sts_error,
                                                          p_row_identifier => P_ag_tbl(i).transaction_id,
                                                          p_entity_code => g_entity_ag,p_table_name => g_entity_ag_tab);*/

               END IF; -- if attr_id is not NULL

              ego_metadata_bulkload_pvt.Write_debug(G_PKG_NAME||'.'||l_proc_name||'->'||'If association id provided is not valid');
               /* if association id provided is not valid*/
               IF ( p_ta_intf_tbl(i).association_id IS NOT NULL AND p_ta_intf_tbl(i).attr_id IS NOT NULL AND p_ta_intf_tbl(i).item_catalog_group_id IS NOT NULL) THEN

                   BEGIN
                     SELECT association_id INTO l_id_exists
                     FROM EGO_TRANS_ATTR_VERS_B ETAVB
                     WHERE ETAVB.association_id = p_ta_intf_tbl(i).association_id
                     AND   item_catalog_group_id= p_ta_intf_tbl(i).item_catalog_group_id
                     AND   icc_version_number=0
                     AND  attr_id=p_ta_intf_tbl(i).attr_id;

                   EXCEPTION
                   WHEN no_data_found THEN
                        ego_metadata_bulkload_pvt.Write_debug(G_PKG_NAME||'.'||l_proc_name||'->'||'Association provided '
                                                      ||p_ta_intf_tbl(i).attr_id
                                                      ||'does not exist in the system');

                        p_ta_intf_tbl(i).process_status := G_ERROR_RECORD;
                        x_return_status := G_RET_STS_ERROR;
                        /*error_handler.Add_error_message(p_message_name => 'EGO_ICC_INVALID',p_application_id => 'EGO',
                                                          p_token_tbl => g_token_table,p_message_type => g_ret_sts_error,
                                                          p_row_identifier => P_ag_tbl(i).transaction_id,
                                                          p_entity_code => g_entity_ag,p_table_name => g_entity_ag_tab);*/
                      WHEN OTHERS THEN
                        ego_metadata_bulkload_pvt.Write_debug(G_PKG_NAME||'.'||l_proc_name||'->'||'value_Set_id provided Exception when others');
                        x_return_status := G_RET_STS_UNEXP_ERROR;

                   END;
               END IF;
            END IF;-- If transaction_type

            /* ============ Specific Validations ======== */
            /* CREATE */
           ego_metadata_bulkload_pvt.Write_debug(G_PKG_NAME||'.'||l_proc_name||'->'||'Create Specific Validations');
            IF   p_ta_intf_tbl(i).transaction_type IN (G_CREATE) THEN

               IF  (p_ta_intf_tbl(i).Association_id  IS NOT NULL
                    OR p_ta_intf_tbl(i).Attr_id  IS NOT NULL ) THEN /*if association_id or attr_id is NOT NULL*/
                       ego_metadata_bulkload_pvt.Write_debug(G_PKG_NAME||'.'||l_proc_name||'->'||'ERR : Association_Is and Attr_id shud be NULL for CREATE');
                       p_ta_intf_tbl(i).process_status := G_ERROR_RECORD;
                       x_return_status := G_RET_STS_ERROR;
                       /*error_handler.Add_error_message(p_message_name => 'EGO_ICC_INVALID',p_application_id => 'EGO',
                                                          p_token_tbl => g_token_table,p_message_type => g_ret_sts_error,
                                                          p_row_identifier => P_ag_tbl(i).transaction_id,
                                                          p_entity_code => g_entity_ag,p_table_name => g_entity_ag_tab);*/


               ELSIF ((p_ta_intf_tbl(i).attr_name IS  NULL)
                      OR (p_ta_intf_tbl(i).attr_display_name  IS  NULL)
                       OR (p_ta_intf_tbl(i).SEQUENCE  IS  NULL)) THEN /* if ICC_ID provided doesn't exists*/
                       ego_metadata_bulkload_pvt.Write_debug(G_PKG_NAME||'.'||l_proc_name||'->'||'Attr_Name and ATT_DISPLAY_NAM and Seq shud not be NULL for CREATE');
                        p_ta_intf_tbl(i).process_status := G_ERROR_RECORD;
                        x_return_status := G_RET_STS_ERROR;
                        /*error_handler.Add_error_message(p_message_name => 'EGO_ICC_INVALID',p_application_id => 'EGO',
                                                          p_token_tbl => g_token_table,p_message_type => g_ret_sts_error,
                                                          p_row_identifier => P_ag_tbl(i).transaction_id,
                                                          p_entity_code => g_entity_ag,p_table_name => g_entity_ag_tab);*/

               ELSIF  (p_ta_intf_tbl(i).icc_version_number IS  NULL) THEN /*If ICC version is NULL while create*/
                       ego_metadata_bulkload_pvt.Write_debug(G_PKG_NAME||'.'||l_proc_name||'->'||'ERR : ICC_VERSION_NUMBER cannot be NULL while CREATE');
                       p_ta_intf_tbl(i).process_status := G_ERROR_RECORD;
                       x_return_status := G_RET_STS_ERROR;
                       /*error_handler.Add_error_message(p_message_name => 'EGO_ICC_INVALID',p_application_id => 'EGO',
                                                          p_token_tbl => g_token_table,p_message_type => g_ret_sts_error,
                                                          p_row_identifier => P_ag_tbl(i).transaction_id,
                                                          p_entity_code => g_entity_ag,p_table_name => g_entity_ag_tab);*/

               END IF;

                ego_metadata_bulkload_pvt.Write_debug(G_PKG_NAME||'.'||l_proc_name||'->'||'Defaulting of data type and dispaly_name');
                /* Defaulting data type to 'C' if NULL */
               IF (p_ta_intf_tbl(i).data_type IS  NULL) THEN
                   p_ta_intf_tbl(i).data_type:='C';
               END IF ;

               IF (Nvl(p_ta_intf_tbl(i).display_flag,'ZZZ')  <> 'T') THEN
                   p_ta_intf_tbl(i).display_flag:='T';
               END IF ;
            END IF;-- If Transaction_type CREATE

            ego_metadata_bulkload_pvt.Write_debug(G_PKG_NAME||'.'||l_proc_name||'->'||'Icc_Version_Number greater than zero not allowed while UPDATE and DELETE');
            /* Both UPDATE and DELETE NOT SYNC */
            IF   p_ta_intf_tbl(i).transaction_type IN (G_UPDATE, G_DELETE) THEN

               IF (p_ta_intf_tbl(i).icc_version_number>0) then /*Icc_Version_Number greater than zero not allowed while UPDATE and DELETE*/

                       ego_metadata_bulkload_pvt.Write_debug(G_PKG_NAME||'.'||l_proc_name||'->'||'Icc_Version_Number greater than zero not allowed while UPDATE and DELETE');
                        p_ta_intf_tbl(i).process_status := G_ERROR_RECORD;
                        x_return_status := G_RET_STS_ERROR;
                        /*error_handler.Add_error_message(p_message_name => 'EGO_ICC_INVALID',p_application_id => 'EGO',
                                                          p_token_tbl => g_token_table,p_message_type => g_ret_sts_error,
                                                          p_row_identifier => P_ag_tbl(i).transaction_id,
                                                          p_entity_code => g_entity_ag,p_table_name => g_entity_ag_tab);*/
                END IF;
            END IF ;

            ego_metadata_bulkload_pvt.Write_debug(G_PKG_NAME||'.'||l_proc_name||'->'||'Association_id and attr_id should not be null for DELETE');
            /* DELETE*/
            IF   p_ta_intf_tbl(i).transaction_type IN (G_DELETE) THEN

               IF  ((p_ta_intf_tbl(i).association_id  IS NULL)
                 OR  (p_ta_intf_tbl(i).attr_id  IS  NULL)) THEN /*Association_id and attr_id should not be null for DELETE */

                       ego_metadata_bulkload_pvt.Write_debug(G_PKG_NAME||'.'||l_proc_name||'->'||'ERR : Association_id and attr_id should not be null for DELETE');
                       p_ta_intf_tbl(i).process_status := G_ERROR_RECORD;
                       x_return_status := G_RET_STS_ERROR;
               END IF;
            END IF ;

 END IF;
END LOOP;
 ego_metadata_bulkload_pvt.Write_debug(G_PKG_NAME||'.'||l_proc_name||'->'||'End Validate_Trans_Attrs');
EXCEPTION
WHEN OTHERS THEN
   x_return_status:= G_RET_STS_UNEXP_ERROR;
   x_return_msg := G_PKG_NAME||'.'||l_proc_name||'.'||SQLERRM;
   ego_metadata_bulkload_pvt.Write_debug(G_PKG_NAME||'.'||l_proc_name||'->'||'Exception when others Validate_Trans_Attrs');
END Validate_Trans_Attrs;

--=================Transact_Trans_Attrs ========

PROCEDURE Transact_Trans_Attrs(
           p_api_version      IN         NUMBER,
           p_ta_intf_rec      IN OUT NOCOPY ego_trans_attrs_vers_intf%ROWTYPE,
           x_return_status    OUT NOCOPY VARCHAR2,
           x_return_msg       OUT NOCOPY VARCHAR2)
IS
l_ego_ta_tbl EGO_TRAN_ATTR_TBL;
l_ta_intf_tbl TA_Intf_Tbl;

l_return_status VARCHAR2(1):=G_RET_STS_SUCCESS;
l_msg_count NUMBER :=G_MISS_NUM;
l_msg_data VARCHAR(2000):=G_MISS_CHAR;

l_proc_name VARCHAR2(200):='Transact_Trans_Attrs';

l_is_child_icc NUMBER;
l_is_ta_there  NUMBER;

e_ta_int_name_exist  EXCEPTION;
e_ta_disp_name_exist EXCEPTION;
e_ta_sequence_exist  EXCEPTION;

BEGIN
  ego_metadata_bulkload_pvt.Write_debug(G_PKG_NAME||'.'||l_proc_name||'->'||'Entering Transact_Trans_Attrs');
  x_return_status  := G_RET_STS_SUCCESS;
  x_return_msg       := G_MISS_CHAR ;

-----================ /* MAIN LOGIC FOR TRANSACT */ =============------------

    IF   p_ta_intf_rec.process_status=G_PROCESS_RECORD THEN

      IF     p_ta_intf_rec.transaction_type=G_CREATE THEN
              ego_metadata_bulkload_pvt.Write_debug(G_PKG_NAME||'.'||l_proc_name||'->'||'Entering CREATE');

	      /* Check  if att_int_name already exist*/
             IF (    Check_TA_IS_INVALID (p_item_cat_group_id   => p_ta_intf_rec.item_catalog_group_id,
                                          p_icc_version_number  => p_ta_intf_rec.icc_version_number,
                                          p_attr_id             => p_ta_intf_rec.attr_id,
                                          p_attr_name           => p_ta_intf_rec.attr_name) ) THEN
               p_ta_intf_rec.process_status:=G_ERROR_RECORD;
               RAISE  e_ta_int_name_exist;
             END IF;

             /* Check  if att_disp_name already exist*/
             IF (    Check_TA_IS_INVALID (p_item_cat_group_id   => p_ta_intf_rec.item_catalog_group_id,
                                          p_icc_version_number  => p_ta_intf_rec.icc_version_number,
                                          p_attr_id             => p_ta_intf_rec.attr_id,
                                          p_attr_disp_name      => p_ta_intf_rec.attr_display_name) ) THEN
               p_ta_intf_rec.process_status:=G_ERROR_RECORD;
               RAISE  e_ta_disp_name_exist;
             END IF;

             /* Check  if sequence already exist*/
             IF (    Check_TA_IS_INVALID (p_item_cat_group_id   => p_ta_intf_rec.item_catalog_group_id,
                                          p_icc_version_number => p_ta_intf_rec.icc_version_number,
                                          p_attr_id             => p_ta_intf_rec.attr_id,
                                          p_attr_sequence       => p_ta_intf_rec.sequence) ) THEN
               p_ta_intf_rec.process_status:=G_ERROR_RECORD;
               RAISE  e_ta_sequence_exist;
             END IF;

             /* for passing only one record at a time to convert*/
             l_ta_intf_tbl(1):= p_ta_intf_rec;

            /*calling proc to convert intf collection to original which calls create api*/
             convert_intf_rec_to_api_rec(p_ta_intf_tbl=>l_ta_intf_tbl,
                               x_ego_ta_tbl=>l_ego_ta_tbl);

             /* calling API to Create TA */
             ego_transaction_attrs_pvt.Create_Transaction_Attribute (
                                      p_api_version    => p_api_version,
                                      p_tran_attrs_tbl => l_ego_ta_tbl,
                                      x_return_status  => l_return_status,
                                      x_msg_count      => l_msg_count,
                                      x_msg_data       => l_msg_data);

             /* Check if x_return_status is sucess or not otherwise set process_status
             of l_ta_intf_rec with 3 and log error message*/
             IF (Nvl(l_return_status,G_RET_STS_SUCCESS) IN (G_RET_STS_ERROR,G_RET_STS_UNEXP_ERROR) )THEN
                p_ta_intf_rec.process_status:=G_ERROR_RECORD;
                x_return_status:= G_RET_STS_ERROR;
                x_return_msg:=  l_msg_data;
             ELSE
                p_ta_intf_rec.process_status:=G_SUCCESS_RECORD;
                x_return_status:= G_RET_STS_SUCCESS;
             END IF;

      ELSIF  p_ta_intf_rec.transaction_type=G_UPDATE THEN
              ego_metadata_bulkload_pvt.Write_debug(G_PKG_NAME||'.'||l_proc_name||'->'||'Entering UPDATE');
              /* for passing only one record at a time to convert*/
              l_ta_intf_tbl(1):= p_ta_intf_rec;

             /*calling proc to convert intf collection to original which calls create api*/
              convert_intf_rec_to_api_rec(p_ta_intf_tbl=>l_ta_intf_tbl,
                                x_ego_ta_tbl=>l_ego_ta_tbl);

              BEGIN /* Checking if ICC is child ICC */
                SELECT 1 INTO l_is_child_icc
                FROM mtl_item_catalog_groups
                WHERE ITEM_CATALOG_GROUP_ID=p_ta_intf_rec.item_catalog_group_id
                AND   PARENT_CATALOG_GROUP_ID IS NOT NULL;

              EXCEPTION
              WHEN No_Data_Found THEN
                l_is_child_icc:=0;
              END;

              IF  l_is_child_icc=1 THEN

                  BEGIN  /* Checking is TA thre for same icc, iccversion*/
                    SELECT 1 INTO l_is_ta_there
                    FROM EGO_TRANS_ATTR_VERS_B
                    WHERE item_catalog_group_id=p_ta_intf_rec.item_catalog_group_id
                    AND icc_version_number=p_ta_intf_rec.icc_version_number
                    AND attr_id= p_ta_intf_rec.attr_id;

                  EXCEPTION
                  WHEN No_Data_Found THEN
                    l_is_ta_there:=0;
                  END ;

                  IF l_is_ta_there=1 THEN /* if there then usual update */

                     ego_transaction_attrs_pvt.Update_Transaction_Attribute (
                                              p_api_version      => p_api_version,
                                              p_tran_attrs_tbl   => l_ego_ta_tbl,
                                              x_return_status    => l_return_status,
                                              x_msg_count        => l_msg_count,
                                              x_msg_data         => l_msg_data);
                  ELSE  /* calling Create_Inherited_Trans_Attr*/

                     ego_transaction_attrs_pvt.Create_Inherited_Trans_Attr (
                                              p_api_version      => p_api_version,
                                              p_tran_attrs_tbl   => l_ego_ta_tbl,
                                              x_return_status    => l_return_status,
                                              x_msg_count        => l_msg_count,
                                              x_msg_data         => l_msg_data);
                  END IF ; --l_is_ta_there=1

              ELSE
                   /* calling API to Update TA */
                   ego_transaction_attrs_pvt.Update_Transaction_Attribute (
                                              p_api_version      => p_api_version,
                                              p_tran_attrs_tbl   => l_ego_ta_tbl,
                                              x_return_status    => l_return_status,
                                              x_msg_count        => l_msg_count,
                                              x_msg_data         => l_msg_data);
              END IF; --l_is_child_icc=1

             /* Check if x_return_status is sucess or not otherwise set process_status
             of l_ta_intf_rec with 3 and log error message*/
              IF (Nvl(l_return_status,G_RET_STS_SUCCESS) IN (G_RET_STS_ERROR,G_RET_STS_UNEXP_ERROR) )THEN
                p_ta_intf_rec.process_status:=G_ERROR_RECORD;
                x_return_status:= G_RET_STS_ERROR;
                x_return_msg:=  l_msg_data;
             ELSE
                p_ta_intf_rec.process_status:=G_SUCCESS_RECORD;
                x_return_status:= G_RET_STS_SUCCESS;
             END IF;

      ELSIF  p_ta_intf_rec.transaction_type=G_DELETE THEN

              ego_metadata_bulkload_pvt.Write_debug(G_PKG_NAME||'.'||l_proc_name||'->'||'Entering DELETE');

             /* for passing only one record at a time to convert*/
             l_ta_intf_tbl(1):= p_ta_intf_rec;

             /*calling proc to convert intf collection to original which calls create api*/
              convert_intf_rec_to_api_rec(p_ta_intf_tbl=>l_ta_intf_tbl,
                                x_ego_ta_tbl=>l_ego_ta_tbl);

             /* calling API to Delete TA */
             ego_transaction_attrs_pvt.Delete_Transaction_Attribute (
                                      p_api_version      => p_api_version,
                                      p_association_id   => l_ego_ta_tbl(1).associationid,
                                      p_attr_id          => l_ego_ta_tbl(1).attrid,
                                      --p_tran_attrs_tbl   => l_ego_ta_tbl,
                                      x_return_status    => l_return_status,
                                      x_msg_count        => l_msg_count,
                                      x_msg_data         => l_msg_data);
             /* Check if x_return_status is sucess or not otherwise set process_status
             of l_ta_intf_rec with 3 and log error message*/
             IF (Nvl(l_return_status,G_RET_STS_SUCCESS) IN (G_RET_STS_ERROR,G_RET_STS_UNEXP_ERROR) )THEN
                p_ta_intf_rec.process_status:=G_ERROR_RECORD;
                x_return_status:= G_RET_STS_ERROR;
                x_return_msg:=  l_msg_data;
             ELSE
                p_ta_intf_rec.process_status:=G_SUCCESS_RECORD;
                x_return_status:= G_RET_STS_SUCCESS;
             END IF;
      END IF ; -- transaction type checking;
    END IF; --l_ego_ta_rec.process_status=G_PROCESS_RECORD

  ego_metadata_bulkload_pvt.Write_debug(G_PKG_NAME||'.'||l_proc_name||'->'||'End Transact_Trans_Attrs');
EXCEPTION
    WHEN e_ta_int_name_exist THEN
      x_return_status   :=  G_RET_STS_ERROR;
         Error_Handler.Add_Error_Message
             (
              p_message_name	 =>  'EGO_EF_INTERNAL_NAME_UNIQUE'
             ,p_application_id =>  G_APP_NAME
             ,p_message_type	 =>  G_RET_STS_ERROR
             ,p_entity_code		 =>  G_Entity_Identifier
             ,p_row_identifier =>  p_ta_intf_rec.transaction_id
             ,p_table_name     =>  G_Table_Name
             --,p_token_tbl      =>  G_TOKEN_TBL
             ,p_addto_fnd_stack=> 'Y'
             );

  WHEN e_ta_disp_name_exist THEN
      x_return_status   :=  G_RET_STS_ERROR;
          Error_Handler.Add_Error_Message
             (
              p_message_name	 =>  'EGO_TA_DISPLAY_NAME_UNIQUE'
             ,p_application_id =>  G_APP_NAME
             ,p_message_type	 =>  G_RET_STS_ERROR
             ,p_entity_code		 =>  G_Entity_Identifier
             ,p_row_identifier =>  p_ta_intf_rec.transaction_id
             ,p_table_name     =>  G_Table_Name
             --,p_token_tbl      =>  G_TOKEN_TBL
             ,p_addto_fnd_stack=> 'Y'
             );

  WHEN e_ta_sequence_exist THEN
      x_return_status   :=  G_RET_STS_ERROR;
          Error_Handler.Add_Error_Message
             (
              p_message_name	 =>  'EGO_EF_CR_ATTR_DUP_SEQ_ERR'
             ,p_application_id =>  G_APP_NAME
             ,p_message_type	 =>  G_RET_STS_ERROR
             ,p_entity_code		 =>  G_Entity_Identifier
             ,p_row_identifier =>  p_ta_intf_rec.transaction_id
             ,p_table_name     =>  G_Table_Name
             --,p_token_tbl      =>  G_TOKEN_TBL
             ,p_addto_fnd_stack=> 'Y'
             );
  WHEN OTHERS THEN
  x_return_status:= G_RET_STS_UNEXP_ERROR;
  x_return_msg := G_PKG_NAME||'.'||l_proc_name||'.'||SQLERRM;
  ego_metadata_bulkload_pvt.Write_debug(G_PKG_NAME||'.'||l_proc_name||'->'||'Exception Transact_Trans_Attrs');
END  Transact_Trans_Attrs;

PROCEDURE Update_Intf_Trans_Attrs(
           p_ta_intf_tbl      IN OUT NOCOPY  TA_Intf_Tbl,
           x_return_status    OUT NOCOPY     VARCHAR2,
           x_return_msg       OUT NOCOPY     VARCHAR2)
IS
l_proc_name VARCHAR2(200):='Update_Intf_Trans_Attrs';
trans_id dbms_sql.number_table; --bug 9701271
BEGIN
ego_metadata_bulkload_pvt.Write_debug(G_PKG_NAME||'.'||l_proc_name||'->'||'Entering Update_Intf_Trans_Attrs');

-- bug 9701271
FOR i IN p_ta_intf_tbl.FIRST..p_ta_intf_tbl.LAST LOOP
        trans_id(i) := p_ta_intf_tbl(i).transaction_id;
END LOOP;


FORALL I IN  p_ta_intf_tbl.first..p_ta_intf_tbl.last -- LOOP
    UPDATE EGO_TRANS_ATTRS_VERS_INTF
    SET  ROW= p_ta_intf_tbl(i) -- bug 9701271
    WHERE
    transaction_id = trans_id(i);

ego_metadata_bulkload_pvt.Write_debug(G_PKG_NAME||'.'||l_proc_name||'->'||'End Update_Intf_Trans_Attrs');

EXCEPTION
  WHEN OTHERS THEN
  x_return_status:= G_RET_STS_UNEXP_ERROR;
  x_return_msg    := G_PKG_NAME||'.'||l_proc_name||'.'||SQLERRM;
  ego_metadata_bulkload_pvt.Write_debug(G_PKG_NAME||'.'||l_proc_name||'->'||'Exception Update_Intf_Trans_Attrs');

END Update_Intf_Trans_Attrs;

/* This has to be called through ICC_versions if any of the TA fails we return from here.
so Icc_version fails and we set all the TA's also to error*/

PROCEDURE Update_Intf_Err_Trans_Attrs(
           p_set_process_id          IN                  NUMBER,
           p_item_catalog_group_id   IN                  NUMBER,
           p_icc_version_number_intf IN                  NUMBER,
           x_return_status           OUT NOCOPY          VARCHAR2,
           x_return_msg              OUT NOCOPY          VARCHAR2)
IS
l_proc_name VARCHAR2(200) :='Update_Intf_Err_Trans_Attrs';
BEGIN
  x_return_status:=G_RET_STS_SUCCESS;
  ego_metadata_bulkload_pvt.Write_debug(G_PKG_NAME||'.'||l_proc_name||'->'||'Entering Update_Intf_Err_Trans_Attrs');

   UPDATE EGO_TRANS_ATTRS_VERS_INTF
   SET process_status= G_ERROR_RECORD
   WHERE item_catalog_group_id = p_item_catalog_group_id
   AND   icc_version_number    = p_icc_version_number_intf
   AND   ((p_set_process_id IS NULL) OR (set_process_id=p_set_process_id));

  ego_metadata_bulkload_pvt.Write_debug(G_PKG_NAME||'.'||l_proc_name||'->'||'End Update_Intf_Err_Trans_Attrs');

EXCEPTION
  WHEN OTHERS THEN
  x_return_status:= G_RET_STS_UNEXP_ERROR;
  x_return_msg    := G_PKG_NAME||'.'||l_proc_name||'.'||SQLERRM;
  ego_metadata_bulkload_pvt.Write_debug(G_PKG_NAME||'.'||l_proc_name||'->'||'Exception Update_Intf_Err_Trans_Attrs');

END Update_Intf_Err_Trans_Attrs;

/* This has to be called by main API of CP based on the parameter passed by user
while running cp, if user says delete all processed records then this will get called */

PROCEDURE Delete_Processed_Trans_Attrs(
           p_set_process_id          IN                  NUMBER,
	   x_return_status           OUT NOCOPY          VARCHAR2,
	   x_return_msg              OUT NOCOPY          VARCHAR2
           )
IS
l_proc_name varchar2(200):='Delete_Processed_Trans_Attrs';
BEGIN
   x_return_status:=G_RET_STS_SUCCESS;
  ego_metadata_bulkload_pvt.Write_debug(G_PKG_NAME||'.'||l_proc_name||'->'||'Entering Delete_Processed_Trans_Attrs');

   DELETE FROM EGO_TRANS_ATTRS_VERS_INTF
   WHERE  process_status = G_SUCCESS_RECORD
   AND   ((p_set_process_id IS NULL) OR (set_process_id=p_set_process_id));

  ego_metadata_bulkload_pvt.Write_debug(G_PKG_NAME||'.'||l_proc_name||'->'||'End Delete_Processed_Trans_Attrs');
EXCEPTION
  WHEN OTHERS THEN
  x_return_status:= G_RET_STS_UNEXP_ERROR;
  x_return_msg    := G_PKG_NAME||'.'||l_proc_name||'.'||SQLERRM;
  ego_metadata_bulkload_pvt.Write_debug(G_PKG_NAME||'.'||l_proc_name||'->'||'Exception Delete_Processed_Trans_Attrs');

END Delete_Processed_Trans_Attrs;

--=================Check_TA_IS_INVALID===============--------
FUNCTION Check_TA_IS_INVALID (
        p_item_cat_group_id  IN NUMBER,
        p_icc_version_number IN NUMBER,
        p_attr_id            IN NUMBER,
        p_attr_name          IN VARCHAR2,
        p_attr_disp_name     IN VARCHAR2,
        p_attr_sequence      IN NUMBER
)
RETURN BOOLEAN
  IS

  l_attr_id NUMBER;
  l_attr_name VARCHAR2(80);
  l_attr_disp_name VARCHAR2(80);
  l_attr_sequence NUMBER;
  l_ta_is_invalid BOOLEAN := FALSE;
  l_proc_name varchar2(200):='Check_TA_IS_INVALID';
/**------Query to fetch all associated attribute with passed in ICC--------**/
CURSOR cur_list
IS
        SELECT item_catalog_group_id,
               icc_version_NUMBER   ,
               SEQUENCE             ,
               attr_display_name    ,
               attr_name            ,
               attr_id              ,
               lev
        FROM
               (SELECT versions.item_catalog_group_id,
                      versions.icc_version_NUMBER    ,
                      versions.SEQUENCE              ,
                      attrs.attr_display_name        ,
                      attrs.attr_name                ,
                      attrs.attr_id                  ,
                      hier.lev
               FROM   ego_obj_AG_assocs_b assocs      ,
                      ego_attrs_v attrs               ,
                      ego_attr_groups_v ag            ,
                      EGO_TRANS_ATTR_VERS_B versions  ,
                      mtl_item_catalog_groups_kfv icv ,
                      (SELECT item_catalog_group_id   ,
                             LEVEL lev
                      FROM   mtl_item_catalog_groups_b START
                      WITH item_catalog_group_id = p_item_cat_group_id CONNECT BY PRIOR parent_catalog_group_id = item_catalog_group_id
                      ) hier
        WHERE  ag.attr_group_type                      = 'EGO_ITEM_TRANS_ATTR_GROUP'
           AND assocs.attr_group_id                    = ag.attr_group_id
           AND assocs.classification_code              = TO_CHAR(hier.item_catalog_group_id)
           AND attrs.attr_group_name                   = ag.attr_group_name
           AND TO_CHAR(icv.item_catalog_group_id)      = assocs.classification_code
           AND TO_CHAR(versions.association_id)        = assocs.association_id
           AND TO_CHAR(versions.item_catalog_group_id) = assocs.classification_code
           AND attrs.attr_id                           = versions.attr_id
               )
        WHERE
               (
                      (
                             LEV                = 1
                         AND ICC_VERSION_NUMBER = p_icc_version_number
                      )
                   OR
                      (
                             LEV <> 1
                         AND
                             (
                                    item_catalog_group_id, ICC_VERSION_NUMBER
                             )
                             IN
                             (SELECT item_catalog_group_id,
                                    VERSION_SEQ_ID
                             FROM   EGO_MTL_CATALOG_GRP_VERS_B
                             WHERE  start_active_date <=
                                    (SELECT NVL(start_active_date,SYSDATE)
                                    FROM   EGO_MTL_CATALOG_GRP_VERS_B
                                    WHERE  ITEM_CATALOG_GROUP_ID = p_item_cat_group_id
                                       AND VERSION_SEQ_ID        = p_icc_version_number
                                    )
                                AND NVL(end_active_date, sysdate) >=
                                    (SELECT NVL(start_active_date,SYSDATE)
                                    FROM   EGO_MTL_CATALOG_GRP_VERS_B
                                    WHERE  ITEM_CATALOG_GROUP_ID = p_item_cat_group_id
                                       AND VERSION_SEQ_ID        = p_icc_version_number
                                    )
                                AND version_seq_id > 0
                             )
                      )
               ); --end CURSOR cur_list


/**------Query to fetch overridden values for a transaction attribute------**/
CURSOR cur_metadata
IS
        SELECT *
        FROM
               (SELECT *
               FROM
                      (SELECT versions.item_catalog_group_id,
                             versions.ICC_VERSION_NUMBER    ,
                             versions.ATTR_ID               ,
                             versions.SEQUENCE              ,
                             versions.attr_display_name     ,
                             versions.metadata_level        ,
                             attrs.attr_name                ,
                             Hier.lev
                      FROM   EGO_TRANS_ATTR_VERS_B VERSIONS,
                             EGO_ATTRS_V ATTRS             ,
                             (SELECT ITEM_CATALOG_GROUP_ID ,
                                    LEVEL LEV
                             FROM   MTL_ITEM_CATALOG_GROUPS_B START
                             WITH ITEM_CATALOG_GROUP_ID = p_item_cat_group_id CONNECT BY PRIOR PARENT_CATALOG_GROUP_ID =ITEM_CATALOG_GROUP_ID
                             ) HIER
               WHERE  HIER.ITEM_CATALOG_GROUP_ID = versions.item_catalog_group_id
                  AND attrs.attr_id              = versions.attr_id
                  AND attrs.attr_group_type      ='EGO_ITEM_TRANS_ATTR_GROUP'
                  AND versions.metadata_level    ='ICC'
                      )
               WHERE
                      (
                             (
                                    LEV                = 1
                                AND ICC_VERSION_number = p_icc_version_number
                             )
                          OR
                             (
                                    LEV <> 1
                                AND
                                    (
                                           item_catalog_group_id, ICC_VERSION_NUMBER
                                    )
                                    IN
                                    (SELECT item_catalog_group_id,
                                           VERSION_SEQ_ID
                                    FROM   EGO_MTL_CATALOG_GRP_VERS_B
                                    WHERE
                                           (
                                                  item_catalog_group_id,start_active_date
                                           )
                                           IN
                                           (SELECT  item_catalog_group_id,
                                                    MAX(start_active_date) start_active_date
                                           FROM     EGO_MTL_CATALOG_GRP_VERS_B
                                           WHERE    NVL(end_active_date, sysdate) >=
                                                    (SELECT NVL(start_active_date,SYSDATE)
                                                    FROM   EGO_MTL_CATALOG_GRP_VERS_B
                                                    WHERE  ITEM_CATALOG_GROUP_ID = p_item_cat_group_id
                                                       AND VERSION_SEQ_ID        = p_icc_version_number
                                                    )
                                                AND version_seq_id > 0

                                                AND  start_active_date <=
                                                    (SELECT NVL(start_active_date,SYSDATE)
                                                    FROM   EGO_MTL_CATALOG_GRP_VERS_B
                                                    WHERE  ITEM_CATALOG_GROUP_ID = p_item_cat_group_id
                                                       AND VERSION_SEQ_ID        = p_icc_version_number
                                                    )



                                           GROUP BY item_catalog_group_id
                                           HAVING   MAX(start_active_date)<=
                                                    (SELECT NVL(start_active_date,SYSDATE)
                                                    FROM   EGO_MTL_CATALOG_GRP_VERS_B
                                                    WHERE  ITEM_CATALOG_GROUP_ID = p_item_cat_group_id
                                                       AND VERSION_SEQ_ID        = p_icc_version_number
                                                    )
                                           )
                                    )
                             )
                      )
               )
        WHERE
               (
                      lev,attr_id
               )
               IN
               (SELECT  MIN(lev),
                        attr_id
               FROM
                        (SELECT versions.item_catalog_group_id,
                               versions.ICC_VERSION_NUMBER    ,
                               versions.ATTR_ID               ,
                               versions.SEQUENCE              ,
                               versions.attr_display_name     ,
                               versions.metadata_level        ,
                               Hier.lev
                        FROM   EGO_TRANS_ATTR_VERS_B VERSIONS,
                               (SELECT ITEM_CATALOG_GROUP_ID ,
                                      LEVEL LEV
                               FROM   MTL_ITEM_CATALOG_GROUPS_B
                                START  WITH ITEM_CATALOG_GROUP_ID = p_item_cat_group_id
                                CONNECT BY PRIOR PARENT_CATALOG_GROUP_ID =ITEM_CATALOG_GROUP_ID
                               ) HIER
                        WHERE  HIER.ITEM_CATALOG_GROUP_ID = versions.item_catalog_group_id
                           AND versions.metadata_level    ='ICC'
                           AND versions.attr_display_name IS NOT NULL
                        )
               WHERE
                        (
                                 (
                                          LEV                =1
                                      AND ICC_VERSION_number = p_icc_version_number
                                 )
                              OR
                                 (
                                          LEV <> 1
                                      AND
                                          (
                                                   item_catalog_group_id, ICC_VERSION_NUMBER
                                          )
                                          IN
                                          (SELECT item_catalog_group_id,
                                                 VERSION_SEQ_ID
                                          FROM   EGO_MTL_CATALOG_GRP_VERS_B
                                          WHERE
                                                 (
                                                        item_catalog_group_id,start_active_date
                                                 )
                                                 IN
                                                 (SELECT  item_catalog_group_id,
                                                          MAX(start_active_date) start_active_date
                                                 FROM     EGO_MTL_CATALOG_GRP_VERS_B
                                                 WHERE    NVL(end_active_date, sysdate) >=
                                                          (SELECT NVL(start_active_date,SYSDATE)
                                                          FROM   EGO_MTL_CATALOG_GRP_VERS_B
                                                          WHERE  ITEM_CATALOG_GROUP_ID = p_item_cat_group_id
                                                             AND VERSION_SEQ_ID        = p_icc_version_number
                                                          )
                                                      AND version_seq_id > 0


                                                      AND  start_active_date <=
                                                      (SELECT NVL(start_active_date,SYSDATE)
                                                      FROM   EGO_MTL_CATALOG_GRP_VERS_B
                                                      WHERE  ITEM_CATALOG_GROUP_ID = p_item_cat_group_id
                                                        AND VERSION_SEQ_ID        = p_icc_version_number
                                                      )




                                                 GROUP BY item_catalog_group_id
                                                 HAVING   MAX(start_active_date)<=
                                                          (SELECT NVL(start_active_date,SYSDATE)
                                                          FROM   EGO_MTL_CATALOG_GRP_VERS_B
                                                          WHERE  ITEM_CATALOG_GROUP_ID = p_item_cat_group_id
                                                             AND VERSION_SEQ_ID        = p_icc_version_number
                                                          )
                                                 )
                                          )
                                 )
                             --AND metadata_level ='ICC'
                        )
               GROUP BY attr_id
               )
           AND attr_id=l_attr_id
           AND attr_id<>Nvl(p_attr_id,0000); --end cur_metadata
BEGIN
     ego_metadata_bulkload_pvt.Write_debug(G_PKG_NAME||'.'||l_proc_name||'->'||'Entering Check_TA_IS_INVALID');
        FOR i IN cur_list
        LOOP
                l_attr_id := i.attr_id;
                FOR j IN cur_metadata
                LOOP
                        l_attr_name      := j.attr_name;
                        l_attr_disp_name := j.attr_display_name;
                        l_attr_sequence  := j.SEQUENCE;

                       /** Validate if any transaction atrribute exist with same
                       internal name while creating/ updating a transaction attribute**/
                       IF (p_attr_name IS NOT NULL ) THEN
                          IF (p_attr_name= l_attr_name) THEN
                            l_ta_is_invalid := TRUE;
                          END IF; --IF (p_attr_name= l_attr_name) THEN
                       END IF ; --IF (p_attr_name IS NOT NULL ) THEN

                       /** Validate if any transaction atrribute exist with same
                       display name while creating/ updating a transaction attribute**/
                       IF (p_attr_disp_name IS NOT NULL ) THEN
                          IF (p_attr_disp_name= l_attr_disp_name) THEN
                            l_ta_is_invalid := TRUE;
                          END IF; --IF (p_attr_disp_name= l_attr_disp_name) THEN
                       END IF; --IF (p_attr_disp_name IS NOT NULL ) THEN

                        /** Validate if any transaction atrribute exist with same
                       sequence while creating/ updating a transaction attribute**/
                       IF (p_attr_sequence IS NOT NULL ) THEN
                          IF (p_attr_sequence = l_attr_sequence) THEN
                            l_ta_is_invalid := TRUE;
                          END IF; --IF (p_attr_sequence= l_attr_sequence) THEN
                       END IF ; --IF (p_attr_sequence IS NOT NULL )

                END LOOP;--FOR j IN cur_metadata

        END LOOP; --FOR i IN cur_list
        RETURN l_ta_is_invalid;
     ego_metadata_bulkload_pvt.Write_debug(G_PKG_NAME||'.'||l_proc_name||'->'||'End Check_TA_IS_INVALID');
END Check_TA_IS_INVALID;

END EGO_TA_BULKLOAD_PVT;

/
